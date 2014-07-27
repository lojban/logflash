procedure lf1dril;
label
     restart;

begin
 randomize;
 INITVALUES;
restart:
     GETFDATA;                           {get file control data}
     CHECKFTOT;                          {check file pile cts vs tot # wds}

     WkLine := blankline;
     insert(FMT_DT_TIME,WkLine,1);
     insert(RightJust(HdrRec.SessNo),WkLine,17);
     insert('Lessons started',WkLine,60);
     writehist(WkLine);

     errmsg := '';
     repeat
       begin

       GETFDATA;                           {get file control data}

       NewSessCnt := 0;
       ThisLess := FINDNEXTLESS(HdrRec.LastLess);
       if (NewSessCnt = 1) and (errmsg = '') then
          begin
          errmsg := 'You have completed session ' +
                    NUMSTRING(HdrRec.SessNo)
                    + '.  Use option #1 to start the next session.';
          if (HdrRec.SessType <> 3) and
             (HdrRec.wdcnt[13] + HdrRec.wdcnt[14] = 0) then
               if (HdrRec.wdcnt[3]  < HdrRec.NWperLess) and
                  (HdrRec.wdcnt[4]  < HdrRec.NWperLess) and
                  (HdrRec.wdcnt[5]  < HdrRec.NWperLess) and
                  (HdrRec.wdcnt[6]  < HdrRec.NWperLess) and
                  (HdrRec.wdcnt[7]  < HdrRec.NWperLess) and
                  (HdrRec.wdcnt[8]  < HdrRec.NWperLess) and
                  (HdrRec.wdcnt[9]  < HdrRec.NWperLess) and
                  (HdrRec.wdcnt[10] < HdrRec.NWperLess) and
                  (HdrRec.wdcnt[11] < HdrRec.NWperLess) and
                  (HdrRec.wdcnt[12] < HdrRec.NWperLess) then
                  errmsg := 'Done session ' + NUMSTRING(HdrRec.SessNo)
                          + '. You have no new words; '
                          + 'you may want to change session type.';
          end
       else
       if (NewSessCnt > 1) and (errmsg = '') then
          errmsg := 'No words available.  Please change session type.';

       SCRN_STATUS_BUILD;

       LANGENTR(scrn_misc_data);

       if scrn_misc_data.scrn_hot_keyhit = 'aster' then
          q := '*'
       else
          if scrn_misc_data.scrn_fld_def[58].fld_entry = '' then
              q := ' '
          else
              q := char(scrn_misc_data.scrn_fld_def[58].fld_entry[1]);
       errmsg := '';
       case q of
            '1' : SESSION;
            '2' : CHGSESS;
            '3' : TOGGLENWLESS;
            '*' : {done};
           else errmsg := 'Invalid Entry - Please enter 1, 2, or 3';
            end;
       end;
     until (q = '*') or quit;                   {menu loop}
     release(heaporg); {release all heap (arr is on heap)}
end;
