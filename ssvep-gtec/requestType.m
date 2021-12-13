function  r = requestType(type)

r = -1;
   
if      strcmp('RequestVersion',        type)
    r = 1;
elseif  strcmp('RequestChannelInfo',    type)
    r = 3;
elseif  strcmp('RequestBasicInfoAcq',   type)
    r = 6;
elseif  strcmp('RequestStreamingStart', type)
    r = 8;
elseif  strcmp('RequestStreamingStop',  type)
    r = 9; 
    
end

