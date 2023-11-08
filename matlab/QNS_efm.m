

classdef QNS_efm < handle
    properties
        reg
        yd
        L
        q
        x
        FS
    end
    methods
        function obj = QNS_efm(L, FS)
            obj.L = L;
            obj.FS = FS;
            reset(obj);
        end
        
        function reset(obj)
            global P;
            obj.reg = zeros(P,1);
            obj.yd = 0;
            obj.q = 0;
            obj.x = 0;
        end
        
        function  y = step(obj, x, quantizerType)
            y = stepx(obj, x, true);
        end
               
        function  y = stepx(obj, x, quantization)
            global P M
            % P: order; M: number of levels
            obj.x = x;
                        
            
%             obj.reg(1) = obj.reg(1) + x - obj.yd;
%             for i=2:P
%                 obj.reg(i) = obj.reg(i) + obj.reg(i-1) - obj.yd;
%             end
            yy = x - 2 * obj.reg(1) + obj.reg(2);
            y_dith = yy;% + sign(1/2 - rand()) * round(rand()) * obj.FS/2;
            if quantization
                
                if y_dith >= 0 % random LSB
                        v = 0.5;%2^(-1);
                    if y_dith > obj.FS % pos full scale
                        v = 1.5;%2^0;
                    end
%                 elseif y_dith < 0
                else
                    v = -0.5;%-2^(-1);
                    if y_dith < -obj.FS % neg full scale
                        v = -1.5;%-2^0;
                    end
%                 else
%                     v = 0;
                end
                
                v_scaled = v * obj.FS; 
                e = yy - v_scaled;
                obj.reg(2) = obj.reg(1); % careful here. must update reg(2) before reg(1) to maintain 2nd ord noise shaping (in matlab model)
                obj.reg(1) = -e;
                
                y = v_scaled;
            else
%                 y = obj.reg(P);
                y = yy;
            end % if quantization
%             obj.q = y - obj.reg(P);
%             obj.yd = y;
            obj.q = e;
            obj.yd = v_scaled;
        end
    end
end