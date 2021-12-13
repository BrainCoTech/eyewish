function data=pGetData_curry8(con,dataBuffer,chanNum,sampleRate)
% data0 = fread(con,20,'uint8');
if (get(con, 'BytesAvailable')==dataBuffer)
    dataOri = fread(con,dataBuffer,'uint8');
    dataOri = uint8(dataOri);
    temp1=typecast(dataOri, 'single');
    temp1(1:5,:)=[];
    temp2 = reshape(temp1,chanNum+1,0.2*sampleRate);
    data1 = temp2';
    data=double(data1);    
else
    data=[];
end