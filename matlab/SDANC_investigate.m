
in = linspace(-1, 1); %the inputs must be less than the quantization levels in order for 
% the negative feedback loop in the QNS block diagram to make a valid
% approximation of the input
NQNS = 1;
QNSx = cell(NQNS,1);
iterations = 32; % this is the OSR

% Levels = [2 1/iterations 4 10];
% Levels = [2 3 4 10];
Levels = [1];
for i=1:NQNS
    QNSx{i} = QNS(Levels(i));
end
qnsOut = zeros(4, length(in), iterations);
qnsErr = zeros(4, length(in), iterations);

for qnsIdx = 1:NQNS
    for sampleIdx = 1:length(in)
        reset(QNSx{qnsIdx});
        for it = 1:iterations
            qnsOut(qnsIdx, sampleIdx, it) = stepx(QNSx{qnsIdx}, in(sampleIdx), true);
            qnsErr(qnsIdx, sampleIdx, it) = qnsOut(qnsIdx, sampleIdx, it) - in(sampleIdx);
        end
    end
end

qnsOutAvg = mean(qnsOut, 3); % averaging over all iterations of stepx
qnsOutMSE = mean((in - qnsOutAvg).^2, 2);
qnsOutMSE

figure(213123); clf;
colorMarker = ["-o", '-+', '-*', '-x'];
for i = 1:length(Levels)
    subplot(length(Levels),1,i)
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

figure(213124); clf;
colorMarker = ["-o", '-+', '-*', '-x'];
for i = 1:length(Levels)
    subplot(length(Levels),1,i)
    plot(in, qnsErr(i,:,end), colorMarker(i));
    grid on
    xlabel('sample index')
    ylabel(sprintf('QNS(%d) error', i))
    hold off
    legend('input', sprintf('QNS(%d) Level: %d', i, Levels(i)))
    title(sprintf('MSE: %e',qnsOutMSE(i)))
end
