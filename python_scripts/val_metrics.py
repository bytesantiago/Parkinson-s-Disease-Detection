import seaborn as sns
import numpy as np
import matplotlib.pyplot as plt
from sklearn.metrics import auc
from sklearn.metrics import plot_roc_curve
from sklearn.model_selection import cross_val_score

def boxplots(EO, comparison, accdf, f1df):
    if EO == False:
        label = ''
    elif EO == True:
        label = ''
        
    #10-folds Shuffle Split Accuraccy Bloxplots
    plt.subplot(2, 1, 1)
    sns.boxplot(data=accdf.iloc[:,0:8], width=0.8, orient = 'v', palette= 'bone')
    if comparison == 1:
        plt.title('PD Off Medication vs Healthy Subjects' + label)
    elif comparison == 2:
        plt.title('PD On Medication vs Healthy Subjects' + label)
    elif comparison == 3:
        plt.title('PD Off Medication vs PD On Medication' + label)
    plt.ylabel('Accuraccy')

    #10-folds Shuffle Split F1-Score Bloxplot
    fig= plt.subplot(2, 1, 2)
    sns.boxplot(data=f1df.iloc[:,0:8], width=0.8, orient = 'v', palette= 'gist_yarg')
    plt.xlabel('Classifiers')
    plt.ylabel('F1-Score')

    plt.show()
    figure = fig.get_figure() 

    if comparison == 1:
        figure.savefig('figures/Off-med_vs_Control_' + label, dpi=500, bbox_inches="tight")
    elif comparison == 2:
        figure.savefig('figures/On-med_vs_Control_' + label, dpi=500, bbox_inches="tight")
    elif comparison == 3:
        figure.savefig('figures/Off-med_vs_On-med_' + label, dpi=500, bbox_inches="tight")

def roc_curve(classifier, cv, X, y):
    tprs = []
    aucs = []
    mean_fpr = np.linspace(0, 1, 100)

    fig, ax = plt.subplots()
    for i, (train, test) in enumerate(cv.split(X, y)):
        classifier.fit(X[train], np.ravel(y[train]))
        viz = plot_roc_curve(classifier, X[test], y[test],
                            name='ROC fold {}'.format(i),
                            alpha=0.3, lw=1, ax=ax)
        interp_tpr = np.interp(mean_fpr, viz.fpr, viz.tpr)
        interp_tpr[0] = 0.0
        tprs.append(interp_tpr)
        aucs.append(viz.roc_auc)

    ax.plot([0, 1], [0, 1], linestyle='--', lw=2, color='r',
            label='Chance', alpha=.8)

    mean_tpr = np.mean(tprs, axis=0)
    mean_tpr[-1] = 1.0
    mean_auc = auc(mean_fpr, mean_tpr)
    std_auc = np.std(aucs)
    ax.plot(mean_fpr, mean_tpr, color='b',
            label=r'Mean ROC (AUC = %0.2f $\pm$ %0.2f)' % (mean_auc, std_auc),
            lw=2, alpha=.8)

    std_tpr = np.std(tprs, axis=0)
    tprs_upper = np.minimum(mean_tpr + std_tpr, 1)
    tprs_lower = np.maximum(mean_tpr - std_tpr, 0)
    fig =ax.fill_between(mean_fpr, tprs_lower, tprs_upper, color='grey', alpha=.2,
                    label=r'$\pm$ 1 std. dev.')

    ax.set(xlim=[-0.05, 1.05], ylim=[-0.05, 1.05],
        title="Receiver operating characteristic example")
    ax.legend(loc="lower right")
    plt.show()

def cross_vald(clf, cv, X, y):
    accuracy = cross_val_score(clf, X, np.ravel(y), cv = cv)
    f1_scr = cross_val_score(clf, X, np.ravel(y), cv = cv , scoring = 'f1')
    precision = cross_val_score(clf, X, np.ravel(y), cv = cv , scoring = 'precision')
    recall = cross_val_score(clf, X, np.ravel(y), cv = cv , scoring = 'recall')
    print("Accuracy: %0.3f (+/- %0.3f)" % (accuracy.mean(), accuracy.std() * 2))
    print("F1-Score: %0.3f (+/- %0.3f)" % (f1_scr.mean(), f1_scr.std() * 2))
    print("Precision: %0.3f (+/- %0.3f)" % (precision.mean(), precision.std() * 2))
    print("Recall: %0.3f (+/- %0.3f)" % (recall.mean(), recall.std() * 2))
    return accuracy, f1_scr#, precision, recall