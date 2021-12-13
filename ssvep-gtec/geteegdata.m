function geteegdata(~,~)
global gds_interface        
global samples_acquired
global data_received
global buffSize

      [scans_received, data] = gds_interface.GetData(4);
      
      if samples_acquired + scans_received < buffSize || samples_acquired + scans_received == buffSize
         data_received((samples_acquired + 1) : (samples_acquired + scans_received), :) = data;
         samples_acquired = samples_acquired + scans_received;
      else
      end
     
 end
