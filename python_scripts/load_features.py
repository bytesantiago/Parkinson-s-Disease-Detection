import pickle
from eegstats import eegstats
from bandpower import bandpower
import numpy as np
import cupy as cp
from scipy import signal
from entropy import * 

def load_WaveformShape_features(EO, dataset):
    if dataset == 'UNM':
        if EO == True:
            shape_featuresStr = ["ShR_eo", "PTR_eo", "StR_eo", "RDR_eo", "pac_eo"]
        elif EO == False:
            shape_featuresStr = ["ShR_ec", "PTR_ec", "StR_ec", "RDR_ec", "pac_ec"]

        shape_features = []
        for i in range(len(shape_featuresStr)):
            infile = open("features/" + shape_featuresStr[i] + ".pkl",'rb')
            shape_features.append(pickle.load(infile))
            infile.close()
            
    elif dataset == 'USDiego':
        shape_featuresStr = ["ShR_USD","PTR_USD","StR_USD","RDR_USD","pac_USD"]
        shape_features = []
        for i in range(len(shape_featuresStr)):
            infile = open("features/" + shape_featuresStr[i] + ".pkl",'rb')
            shape_features.append(pickle.load(infile))
            infile.close()

    ShR = shape_features[0]
    PTR = shape_features[1]
    StR = shape_features[2]
    RDR = shape_features[3]
    pac = shape_features[4]

    return ShR, PTR, StR, RDR, pac

def Bandpower_features(signal, Fs, bands, samples, relativ, metodo):
    bandpower_feat = np.zeros((samples,5))
    for i in range(len(signal)): 
        delta_power = bandpower(signal[i], Fs, bands[0], relative = relativ, method = metodo)
        theta_power = bandpower(signal[i], Fs, bands[1], relative = relativ, method = metodo)
        alpha_power = bandpower(signal[i], Fs, bands[2], relative = relativ, method = metodo)
        beta_power = bandpower(signal[i], Fs, bands[3], relative = relativ, method = metodo)
        gamma_power = bandpower(signal[i], Fs, bands[4], relative = relativ, method = metodo)
        bandpower_feat[i,:] = [delta_power, theta_power, alpha_power, beta_power, gamma_power]
    return bandpower_feat

def mean_and_peak_freqs(data, sf, samples):
    meanFreqs = np.zeros((samples, 1))
    peakFreqs = np.zeros((samples, 1))
    for i in range(len(data)):
        win = 4 * sf
        freqs, psd = signal.welch(data[i], sf, nperseg=win)
        mean_freq = np.divide(sum(np.multiply(freqs, psd)), sum(psd))
        peak_freq = freqs[np.argmax(psd)]
        meanFreqs[i,0] = mean_freq
        peakFreqs[i,0] = peak_freq
    return meanFreqs, peakFreqs

def statistics(data, samples):
    stats = cp.zeros((samples, 13))
    stats[:,0] = eegstats(data, samples, 'mean')
    stats[:,1] = eegstats(data, samples, 'std')
    stats[:,2] = eegstats(data, samples, 'skewness')
    stats[:,3] = eegstats(data, samples, 'kurtosis')
    stats[:,4] = eegstats(data, samples, 'maximum')
    stats[:,5] = eegstats(data, samples, 'minimum')
    stats[:,6] = eegstats(data, samples, 'n5')
    stats[:,7] = eegstats(data, samples, 'n25')
    stats[:,8] = eegstats(data, samples, 'n75')
    stats[:,9] = eegstats(data, samples, 'n95')
    stats[:,10] = eegstats(data, samples, 'median')
    stats[:,11] = eegstats(data, samples, 'variance')
    stats[:,12] = eegstats(data, samples, 'rms')
    return stats

def fractal_dimensions(data, samples):
    fractals = np.zeros((samples, 4))
    for i in range(len(data)):
        det_fluc = detrended_fluctuation(data[i])
        hig = higuchi_fd(data[i])
        katz = katz_fd(data[i])
        pet_fd = petrosian_fd(data[i])
        fractals[i,:] = [det_fluc, hig, katz, pet_fd]
    return fractals

def entropies(data, samples, fs):
    ent = np.zeros((samples, 2))
    for i in range(len(data)):
#         ap_ent = app_entropy(data[i])
#         lziv = lziv_complexity(data[i])
        perm_ent = perm_entropy(data[i])
#         samp_ent= sample_entropy(data[i])
#         s_ent = spectral_entropy(data[i], fs)
        svd_ent = svd_entropy(data[i])
        ent[i,:] = [perm_ent, svd_ent]
    return ent