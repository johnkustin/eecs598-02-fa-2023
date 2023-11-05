function [v] = bpquantizer(y,nlevels, maxY, minY)
%quantizer a function which quantizes a multi-leveled input into nlevels
%number of discrete levels, based on the full scale of y
%   y: the signed, floating or fixed point input to be quantized
%   nlevels: the number of quantization levels on one side of the x axis.
%   this is a bipolar quantizer, so the real # levels is 2* what is written

nsteps = nlevels - 1;
mid_tread = rem(nsteps,2) == 0;
mid_riser = rem(nsteps,2) == 1;

nbits = ceil(log2(nlevels));

if ~isempty(maxY) && ~isempty(minY)
    LSB = (maxY - minY) ./ 2.^nbits;
else
    LSB = (max(y) - min(y)) ./ 2.^nbits;
end


if mid_tread
    mantissa = sign(y + eps).*(floor(abs(y)./LSB + 1/2)); % implement in hardware by ignoring the sign bit, doing the floor operation, then reapplying the sign bit
elseif mid_riser
    mantissa = sign(y + eps).*(floor(abs(y)./LSB) + 1/2);
end


if any(y < 0) || minY < 0
    mantissa(mantissa < -2.^(nbits-1)) = -2.^(nbits-1); % bipolar quantizer is talked about in terms of nbits, which means nbits for each polarity
    mantissa(mantissa > 2.^(nbits-1)) = 2.^(nbits-1);
else
    mantissa(mantissa < -2.^(nbits-1)) = -2.^(nbits-1);
    mantissa(mantissa > 2.^(nbits)) = 2.^(nbits);
end

v = LSB .* mantissa;
end
