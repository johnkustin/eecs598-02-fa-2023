function T = mytypes(dt)
  switch dt
    case 'double'
      T.AAF = double([]);
      T.wop = double([]);
      T.sp  = double([]);
      T.sh  = double([]);
      T.up  = double([]);
      T.yp  = double([]);
      T.dp  = double([]);
      T.ep  = double([]);
      T.u0  = double([]);
      T.yq  = double([]);
      T.y0  = double([]);
      T.e0  = double([]);
      T.d = double([]);
      T.u = double([]);
      T.u1  = double([]);
      T.e = double([]);
      T.y = double([]);
      T.dh  = double([]);
      T.eh  = double([]);
      T.mu  = double([]);
      T.w = double([]);
      T.w0  = double([]);


    case 'single'
      T.b = single([]);
      T.x = single([]);
      T.y = single([]);

    case 'fixed8'
      T.b = fi([],true,8,7);
      T.x = fi([],true,8,7);
      T.y = fi([],true,8,6);

    case 'fixed16'
      
      T.AAF = fi([],true,32,36);
      T.wop = fi([],true,32,32);
      T.sp  = fi([],true,32,31);
      T.sh  = fi([],true,32,30);
      T.up  = fi([],true,32,28);
      T.yp  = fi([],true,32,29);
      T.dp  = fi([],true,32,28);
      T.ep  = fi([],true,32,26);
      T.u0  = fi([],true,3,0);
      T.yq  = fi([],true,32,31);
      T.y0  = fi([],true,4,0);
      T.e0  = fi([],true,5,0);
      T.d = fi([],true,32,31);
      T.u = fi([],true,32,31);
      T.u1  = fi([],true,32,31);
      T.e = fi([],true,32,32);
      T.y = fi([],true,32,31);
      T.dh  = fi([],true,32,31);
      T.eh  = fi([],true,32,32);
      T.mu  = fi([],true,32,33);
      T.w = fi([],true,32,31);
      T.w0  = fi([],true,32,31);


    case 'fixed32'
      T.AAF = fi([],true,32,36);
      T.wop = fi([],true,32,32);
      T.sp  = fi([],true,32,31);
      T.sh  = fi([],true,32,30);
      T.up  = fi([],true,32,28);
      T.yp  = fi([],true,32,29);
      T.dp  = fi([],true,32,28);
      T.ep  = fi([],true,32,26);
      T.u0  = fi([],true,3,0);
      T.yq  = fi([],true,32,31);
      T.y0  = fi([],true,4,0);
      T.e0  = fi([],true,5,0);
      T.d = fi([],true,32,31);
      T.u = fi([],true,32,31);
      T.u1  = fi([],true,32,31);
      T.e = fi([],true,32,32);
      T.y = fi([],true,32,31);
      T.dh  = fi([],true,32,31);
      T.eh  = fi([],true,32,32);
      T.mu  = fi([],true,32,33);
      T.w = fi([],true,32,31);
      T.w0  = fi([],true,32,31);
  end
end
