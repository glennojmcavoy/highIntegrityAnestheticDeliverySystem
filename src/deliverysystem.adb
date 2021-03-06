package body deliverySystem with SPARK_Mode is

   -- ## Functions ##
   
   -- # Calculates the AVG number of Beats Per Minute (BPM) using the last 3 Time Between Beats Readings (Deciseconds)
   --   For example: (10,10,10) = 60 BPM
   function CalcBPM(ecgR: in ecgReadings) return Natural is
      
      counter: Natural := 0;
      divisor: Integer := ecgReadingsSize'Last; -- Used to workout average of values in the array

   begin
        
      -- Loops through values of array
      for Index in ecgR'First.. ecgR'Last loop 
         
         -- Creates a running total of the BPM
         counter := ((Minute/ecgR(Index)) * CONVERT_TO_SECONDS) + counter;
         
         -- At each iteration counter is less than number of iterations * MAXIMUM_BPM
         pragma Loop_Invariant
           (for some I in ecgR'First .. Index => 
            counter <= I * MAXIMUM_BPM); -- Max = 3 * 300
         
      end loop;
      
      -- Return average BPM 
      return (counter / divisor);

   end CalcBPM;
   
   
   -- # Calculates the number of seconds the brain is in a suppressed state (indicated by a 0)
   --  For example: (0,0,0,0,0,0,0,0,1,0) = 9 seconds
   function CalcST(eegR: in eegReadings) return Natural is 
      
      supT: Integer := eegR(eegR'First);
      
   begin
      
      -- Loops through values of the array
      for Index in eegR'First + 1 .. eegR'Last  loop
         
         -- At each iteration supT is equal to value in partialArray at previous Index
         pragma Loop_Invariant -- 
           (supT = sumEEGR (eegR) (Index - 1));

         -- supT can never be greater than the number of iterations - 1 
         pragma Loop_Invariant 
           (supT <= Index - 1);
         
         -- if brain suppressed at this second i.e. 1
         if eegR(Index) = 1
           
           -- supT is equal to itself plus the current reading
           then supT := supT + eegR(Index);
            
         end if;
         
      end loop;
      
      return eegReadings'Length - supT;
      
   end CalcST;
   
   
   -- # Decides if to sound the Tocsin
   -- For example: bpm = 60 will return FALSE 
   function IsSoundTocsin(bpm: in Integer) return Boolean is

    begin
      
      if bpm < TOCSIN_MINIMUM_BPM or bpm > TOCSIN_MAXIMIM_BPM
        
        then return true;
         
      end if;
      
      return false;
      
   end IsSoundTocsin;
   
   
   procedure soundTocsin is
      
   begin
      
      Tocsin := true;
   
   end soundTocsin;
   
   procedure resetTocsin is
      
   begin
      
      Tocsin := true;
   
   end resetTocsin;
   
   -- # Decides if to infuse patient with medicine
   -- For example: supT = 9 will return false
   function IsInfuse(suppressionTime: in Integer) return Boolean is
   begin
      
        if suppressionTime < MINIMUM_ST
        
          then return true;
         
          else return false;
         
         end if;
         
   end IsInfuse;
    
   procedure InfusionPumpOn()
     
   begin
      
      InfusionPump = true;
      
   end IsInfuse;   
   
   procedure InfusionPumpOff()
     
   begin
      
      InfusionPump = false;
      
   end IsInfuse;   
   
   -- # Auxillary function Ghost function which sums the values of an array to produce the supression time
   function sumEEGR (eegR : eegReadings) return eegPartialSums is
      
      PS : eegPartialSums := (others => 0);
      
   begin
     
      PS (eegR'First) := eegR (eegR'First);

      -- loop through all values in array
      for Index in eegR'First + 1 .. eegR'Last loop

         -- At each iteration eegR and eegPartialSums share the same first element
         pragma Loop_Invariant
           (PS (eegR'First) = eegR (eegR'First));

         -- At each iteration Partial sums value is it's previous index value plus current index value of eegR
         pragma Loop_Invariant
           (for all I in eegR'First + 1 .. Index - 1 =>
              PS (I) = PS (I - 1) + eegR (I)); 

         -- At each iteration PS(I) has a value <= I * maximum allowed value for eegReadings
         pragma Loop_Invariant 
           (for all I in eegR'First .. Index - 1 =>
               abs (PS (I)) <= I * eegReading'Last); --Max = 10 * 1
         
         -- PS current index = value of its previous index + value of current index of eggR
         PS (Index) := PS (Index - 1) + eegR (Index);
         

      end loop;

      return PS;

   end sumEEGR;
   
   
end deliverySystem;

