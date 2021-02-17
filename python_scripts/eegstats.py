def eegstats(signals, samples, statistic):

    import cupy as cp
    from scipy.stats import skew, kurtosis

    if statistic == 'mean':
        means = cp.zeros(samples)
        for i in range(len(signals)):
            means[i] = cp.mean(signals[i])
        return means

    elif statistic == 'std':
        std = cp.zeros(samples)
        for i in range(len(signals)):
            std[i] = cp.std(signals[i])
        return std

    elif statistic == 'skewness':
        skewness = cp.zeros(samples)
        for i in range(len(signals)):
            skewness[i] = skew(signals[i])
        return skewness

    elif statistic == 'kurtosis':
        kurt = cp.zeros(samples)
        for i in range(len(signals)):
            kurt[i] = kurtosis(signals[i])
        return kurt

    elif statistic == 'maximum':
        maxim = cp.zeros(samples)
        for i in range(len(signals)):
            maxim[i] = cp.amax(signals[i])
        return maxim

    elif statistic == 'minimum':
        minim = cp.zeros(samples)
        for i in range(len(signals)):
            minim[i] = cp.amin(signals[i])
        return minim
    ########
    elif statistic == 'n5':
        n5 = cp.zeros(samples)
        for i in range(len(signals)):
            n5[i] = cp.percentile(cp.asarray(signals[i]),5)
        return n5
    
    elif statistic == 'n25':
        n25 = cp.zeros(samples)
        for i in range(len(signals)):
            n25[i] = cp.percentile(cp.asarray(signals[i]),25)
        return n25
    
    elif statistic == 'n75':
        n75 = cp.zeros(samples)
        for i in range(len(signals)):
            n75[i] = cp.percentile(cp.asarray(signals[i]),75)
        return n75
    
    elif statistic == 'n95':
        n95 = cp.zeros(samples)
        for i in range(len(signals)):
            n95[i] = cp.percentile(cp.asarray(signals[i]),95)
        return n95
    
    elif statistic == 'median':
        median = cp.zeros(samples)
        for i in range(len(signals)):
            median[i] = cp.percentile(cp.asarray(signals[i]),50)
        return median
    
    elif statistic == 'variance':
        variance = cp.zeros(samples)
        for i in range(len(signals)):
            variance[i] = cp.var(cp.asarray(signals[i]))
        return variance
    
    elif statistic == 'rms':
        rms = cp.zeros(samples)
        for i in range(len(signals)):
            rms[i] = cp.mean(cp.sqrt(cp.asarray(signals[i])**2))
        return rms
