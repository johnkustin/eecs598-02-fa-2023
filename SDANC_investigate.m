clear; close all

in = linspace(-10,10); %the inputs must be less than the quantization levels in order for 
% the negative feedback loop in the QNS block diagram to make a valid
% approximation of the input
NQNS = 4;
QNSx = cell(NQNS,1);
iterations = 32; % this is the OSR

% Levels = [2 1/iterations 4 10];
Levels = [2 3 4 10 iterations];
for i=1:NQNS
    QNSx{i} = QNS(Levels(i));
end
qnsOut = zeros(4, length(in), iterations);

for qnsIdx = 1:4
    for sampleIdx = 1:length(in)
        for it = 1:iterations
            qnsOut(qnsIdx, sampleIdx, it) = stepx(QNSx{qnsIdx}, in(sampleIdx), true);
        end
        reset(QNSx{qnsIdx});
    end
end

qnsOutAvg = mean(qnsOut, 3); % averaging over all iterations of stepx
qnsOutMSE = mean((in - qnsOutAvg).^2, 2);
qnsOutMSE

figure(213123); clf;
colorMarker = ["-o", '-+', '-*', '-x'];
for i = 1:4
    subplot(4,1,i)
    plot(in, in, 'b');
    hold on
    plot(in, qnsOutAvg(i,:), colorMarker(i));
    grid on
    xlabel('sample index')
    ylabel(sprintf('mean(QNS(%d) output)', i))
    hold off
    legend('input', sprintf('QNS(%d) Level: %d', i, Levels(i)))
    title(sprintf('MSE: %e',qnsOutMSE(i)))
end