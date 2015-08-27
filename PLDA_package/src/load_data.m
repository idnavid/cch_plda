% Aleksandr Sizov, UEF 2014

function [train_data train_labels enrol_data enrol_labels test_data ...
         test_labels] = load_data(fname)

z = load(fname);

train_data = z.train_data;
train_labels = z.train_labels;
enrol_data = z.enrol_data;
enrol_labels = z.enrol_labels;
test_data = z.test_data;
test_labels = z.test_labels;

clear('z');