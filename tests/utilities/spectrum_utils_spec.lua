local radio = require('radio')
local jigs = require('tests.jigs')

local spectrum_utils = require('radio.utilities.spectrum_utils')
local test_vectors = dofile('tests/utilities/spectrum_utils_vectors.gen.lua')

describe("spectrum_utils", function ()
    -- Wrapper for using DFT class
    function dft(samples)
        -- Create input and output sample buffers and DFT context
        local output_samples = radio.types.ComplexFloat32.vector(samples.length)
        local dft = spectrum_utils.DFT(samples, output_samples)

        -- Compute DFT
        dft:compute()

        return output_samples
    end

    -- Wrapper for using IDFT class
    function idft(samples, output_type)
        -- Create input and output sample buffers and DFT context
        local output_samples = output_type.vector(samples.length)
        local idft = spectrum_utils.IDFT(samples, output_samples)

        -- Compute DFT
        idft:compute()

        return output_samples
    end

    -- Wrapper for using PSD class
    function psd(samples, window_type, sample_rate, logarithmic)
        -- Create input and output sample buffers and PSD context
        local output_samples = radio.types.Float32.vector(samples.length)
        local psd = spectrum_utils.PSD(samples, output_samples, window_type, sample_rate, logarithmic)

        -- Compute PSD
        psd:compute()

        return output_samples
    end

    -- Wrapper for using fftshift()
    function fftshift(samples)
        -- Create a copy of the samples
        local output_samples = samples.data_type.vector(samples.length)
        for i = 0, samples.length-1 do
            output_samples.data[i] = samples.data[i]
        end

        -- Perform FFT shift
        spectrum_utils.fftshift(output_samples)

        return output_samples
    end

    it("test complex dft", function ()
        jigs.assert_vector_equal(dft(test_vectors.complex_test_vector), test_vectors.complex_test_vector_dft, 1e-5)
    end)

    it("test complex idft", function ()
        jigs.assert_vector_equal(idft(test_vectors.complex_test_vector_dft, radio.types.ComplexFloat32), test_vectors.complex_test_vector, 1e-5)
    end)

    it("test real dft", function ()
        jigs.assert_vector_equal(dft(test_vectors.real_test_vector), test_vectors.real_test_vector_dft, 1e-5)
    end)

    it("test real idft", function ()
        jigs.assert_vector_equal(idft(test_vectors.real_test_vector_dft, radio.types.Float32), test_vectors.real_test_vector, 1e-5)
    end)

    it("test complex psd", function ()
        jigs.assert_vector_equal(psd(test_vectors.complex_test_vector, 'rectangular', 44100, false), test_vectors.complex_test_vector_rectangular_psd, 1e-5)
        jigs.assert_vector_equal(psd(test_vectors.complex_test_vector, 'rectangular', 44100, true), test_vectors.complex_test_vector_rectangular_psd_log, 3)
        jigs.assert_vector_equal(psd(test_vectors.complex_test_vector, 'hamming', 44100, false), test_vectors.complex_test_vector_hamming_psd, 1e-5)
        jigs.assert_vector_equal(psd(test_vectors.complex_test_vector, 'hamming', 44100, true), test_vectors.complex_test_vector_hamming_psd_log, 3)
    end)

    it("test real psd", function ()
        jigs.assert_vector_equal(psd(test_vectors.real_test_vector, 'rectangular', 44100, false), test_vectors.real_test_vector_rectangular_psd, 1e-5)
        jigs.assert_vector_equal(psd(test_vectors.real_test_vector, 'rectangular', 44100, true), test_vectors.real_test_vector_rectangular_psd_log, 3)
        jigs.assert_vector_equal(psd(test_vectors.real_test_vector, 'hamming', 44100, false), test_vectors.real_test_vector_hamming_psd, 1e-5)
        jigs.assert_vector_equal(psd(test_vectors.real_test_vector, 'hamming', 44100, true), test_vectors.real_test_vector_hamming_psd_log, 3)
    end)

    it("test fftshift", function ()
        jigs.assert_vector_equal(fftshift(test_vectors.complex_test_vector), test_vectors.complex_test_vector_fftshift, 1e-6)
        jigs.assert_vector_equal(fftshift(test_vectors.real_test_vector), test_vectors.real_test_vector_fftshift, 1e-6)
    end)
end)
