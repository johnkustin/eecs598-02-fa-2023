% Anex to the Paper:
% Low Delay and Low Cost Sigma-Delta Adaptive Controller for Active Noise Control
% Paulo Lopes

classdef QNS < handle
    properties
        mem
        yd
        L
        q
        x
    end
    methods
        function obj = QNS(L)
            obj.L = L;
            reset(obj);
        end
        
        function reset(obj)
            global P;
            obj.mem = zeros(P,1);
            obj.yd = 0;
            obj.q = 0;
            obj.x = 0;
        end
        
        function  y = step(obj, x, quantizerType)
            y = stepx(obj, x, true, quantizerType);
        end
               
        function  y = stepx(obj, x, quantization, quantizerType)
            global P M
            % P: order; M: number of levels
            obj.x = x;
                        
            obj.mem(1) = obj.mem(1) + x - obj.yd;
            for i=2:P
                obj.mem(i) = obj.mem(i) + obj.mem(i-1) - obj.yd;
            end
            
            if quantization
                level_i = min(max(round(M/4*(obj.mem(i)/obj.L+2)-1/2),0),M-1);
                level_i_tread = ceil(obj.mem(i)/obj.L - 1/2); % forward quantization stage of mid-tread quantizer
                level_i_riser = ceil(obj.mem(i)/obj.L) - 1/2; % forward quantization stage of mid-riser quantizer
                % i thinik max(round(M/4*(obj.mem(i)/obj.L+2)-1/2),0)
                % implements a "dead zone quantizer"
                % https://en.wikipedia.org/wiki/Quantization_(signal_processing)#Dead-zone_quantizers
                % but his deadzone width is same as LSB size (obj.L) so it
                % is a uniform quantizer
                y = obj.L*(4/M*(level_i'+1/2)-2);
                
                y_riser = obj.L * (level_i_riser + 1/2); % inverse quantization stage of mid-riser 
                y_tread = obj.L * level_i_tread; % inverse quantization stage of mid-tread
                if y_riser > obj.L * 3/2 % 
                    y_riser = obj.L *3/2;
                elseif y_riser < -obj.L * 3/2
                    y_riser = obj.L * -3/2;
                end

                if y_tread > obj.L * 3/2 % 
                    y_tread = obj.L *3/2;
                elseif y_tread < -obj.L * 3/2
                    y_tread = obj.L * -3/2;
                end

%                 my_level_i = 1/2 + ceil(obj.mem(i)./obj.L);
%                 my_y = obj.L * (my_level_i + 1/2);
%                 my_y = obj.L * my_level_i;
%                 if y_my ~= y
%                     sprintf("y=%f my_y=%f", y, y_my)
% %                     sprintf("L=%f obj.mem(i)=%f", obj.L, obj.mem(i))
%                 end
                if quantizerType == "mid-riser"
                    y = y_riser;
                elseif quantizerType == "mid-tread"
                    y = y_tread;
                elseif quantizerType == "orig"
                    % do nothing. y = y
                end
                
                
            else
                y = obj.mem(P);
            end
            obj.q = y - obj.mem(P);
            obj.yd = y;
        end
    end
end