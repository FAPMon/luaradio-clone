import numpy
import scipy.signal
from generate import *


def firwin_complex_bandstop(num_taps, cutoffs, window='hamming'):
    width, center = max(cutoffs) - min(cutoffs), (cutoffs[0] + cutoffs[1]) / 2
    scale_freq = 1.0 if (0.0 > cutoffs[0] and 0.0 < cutoffs[1]) else 0.0
    b = scipy.signal.firwin(num_taps, width / 2, pass_zero=False, window='rectangular', scale=False)
    b = b * numpy.exp(1j * numpy.pi * center * numpy.arange(len(b)))
    b = b * scipy.signal.get_window(window, num_taps, False)
    b = b / numpy.sum(b * numpy.exp(-1j * numpy.pi * scale_freq * (numpy.arange(num_taps) - (num_taps - 1) / 2)))
    return b.astype(numpy.complex64)


def generate():
    def process(num_taps, cutoffs, nyquist, window, x):
        b = firwin_complex_bandstop(num_taps, [cutoffs[0] / nyquist, cutoffs[1] / nyquist], window)
        return [scipy.signal.lfilter(b, 1, x).astype(type(x[0]))]

    vectors = []

    x = random_complex64(256)
    vectors.append(TestVector([129, [0.1, 0.3]], [x], process(129, [0.1, 0.3], 1.0, "hamming", x), "129 taps, {0.1, 0.3} cutoff, 256 ComplexFloat32 input, 256 ComplexFloat32 output"))
    vectors.append(TestVector([129, [-0.1, -0.3]], [x], process(129, [-0.1, -0.3], 1.0, "hamming", x), "129 taps, {-0.1, -0.3} cutoff, 256 ComplexFloat32 input, 256 ComplexFloat32 output"))
    vectors.append(TestVector([129, [-0.2, 0.2]], [x], process(129, [-0.2, 0.2], 1.0, "hamming", x), "129 taps, {-0.2, 0.2} cutoff, 256 ComplexFloat32 input, 256 ComplexFloat32 output"))
    vectors.append(TestVector([129, [0.1, 0.3], 3.0, '"bartlett"'], [x], process(129, [0.1, 0.3], 3.0, "bartlett", x), "129 taps, {0.1, 0.3} cutoff, 3.0 nyquist, bartlett window, 256 ComplexFloat32 input, 256 ComplexFloat32 output"))
    vectors.append(TestVector([129, [-0.1, -0.3], 3.0, '"bartlett"'], [x], process(129, [-0.1, -0.3], 3.0, "bartlett", x), "129 taps, {-0.1, -0.3} cutoff, 3.0 nyquist, bartlett window, 256 ComplexFloat32 input, 256 ComplexFloat32 output"))
    vectors.append(TestVector([129, [-0.2, 0.2], 3.0, '"bartlett"'], [x], process(129, [-0.2, 0.2], 3.0, "bartlett", x), "129 taps, {-0.2, 0.2} cutoff, 3.0 nyquist, bartlett window, 256 ComplexFloat32 input, 256 ComplexFloat32 output"))

    return BlockSpec("ComplexBandstopFilterBlock", vectors, 1e-6)
