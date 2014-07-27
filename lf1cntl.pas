{***********************************************************************}
{  COPYRIGHT 1986 - 1991            by Nora and Bob LeChevalier         }
{***********************************************************************}

{************************************************************************}
procedure CHGSESS; {10000-10299, allow change session type only if all nw done}
  const
                       {from,to}
    SessChgType : array[1..4,1..5] of integer =
    {Gives 0 if not allowed, otherwise # off which to base msg, processing}
                                   {N,G,M,B,  recommended}
                  {NW review}    ( (0,1,0,1,  2),
                  {Gain Control}   (2,0,4,1,  3),
                  {Maintenance}    (2,5,0,1,  4),
                  {Brush-up}       (2,5,3,0,  3) );

    SessChgTypeChar : array [1..4] of string[1] = ('R','G','M','B');

    SessChgMsg : array[1..5] of string[80] =
    {note - second msg also needed if going to NW review}
    {1} ( 'BEWARE: All words will be put in the new word pile!',
    {2}   'NOTE: Intermediate piles will be put in "Recognized 1x"',
    {3}   'NOTE: New Words will be skipped; Recog 3x will drop to Recog 2x.',
    {4}   'NOTE: New Words will be skipped.',
    {5}   ''  {no msg necessary} );

    SessDisplay : array[1..4] of string[15] =
                  ('New Word Review',
                   'Gaining Control',
                   'Maintenance',
                   'Brush-up'       );
  var
    WkChgChar :  char;
    WkChgNum  :  integer;

begin
     GETFDATA;               {ensure header rcd data correct}

     {--present initial screen------------------------------}
     FMTCHGSESS(scrn_misc_data);
     with scrn_misc_data do
        begin

        {----Heading-----------------------------------------}
        with scrn_fld_def[1] do
          fld_entry := 'CHANGE SESSION TYPE';
        with scrn_fld_def[2] do
          fld_entry := 'Current Session Type:' + SessDisplay[HdrRec.SessType];

        {----Options-----------------------------------------}
        with scrn_fld_def[3] do
          fld_entry := 'R';
        with scrn_fld_def[4] do
          fld_entry := ': ' + SessDisplay[1];
        with scrn_fld_def[5] do
          fld_entry := 'Familiarize yourself with the range of words for the first time.';
        with scrn_fld_def[6] do
          fld_entry := 'Tests recognition (twice).';

        with scrn_fld_def[7] do
          fld_entry := 'G';
        with scrn_fld_def[8] do
          fld_entry := ': ' + SessDisplay[2];
        with scrn_fld_def[9] do
          fld_entry := 'Drill the words thoroughly.  The most complete testing given.';
        with scrn_fld_def[10] do
          fld_entry := 'Tests recognition (3 times) and recall (twice). ';

        with scrn_fld_def[11] do
          fld_entry := 'M';
        with scrn_fld_def[12] do
          fld_entry := ': ' + SessDisplay[3];
        with scrn_fld_def[13] do
          fld_entry := 'Master the words, when done all New Words.';
        with scrn_fld_def[14] do
          fld_entry := 'Tests recognition (twice) and recall (twice); no New Words tested.';

        with scrn_fld_def[15] do
          fld_entry := 'B';
        with scrn_fld_def[16] do
          fld_entry := ': ' + SessDisplay[4];
        with scrn_fld_def[17] do
          fld_entry := 'Refresh words once mastered, after a long absence.';
        with scrn_fld_def[18] do
          fld_entry := 'Tests recognition (twice) and recall (twice); all start in New Word pile.';

        {----Bottom------------------------------------------}
        with scrn_fld_def[19] do
          fld_entry := 'SELECT ONE:';
        with scrn_fld_def[20] do         {entry line}
          fld_entry := SessChgTypeChar[SessChgType[HdrRec.SessType,5]];
        with scrn_fld_def[21] do
          fld_entry := '("';
        with scrn_fld_def[22] do
          fld_entry := SessChgTypeChar[SessChgType[HdrRec.SessType,5]];
        with scrn_fld_def[23] do
          fld_entry := '" suggested; "*" to cancel)';

        with scrn_fld_def[24] do       {Warning/error line}
          fld_entry := '';
        with scrn_fld_def[25] do       {Verify prompt}
          fld_entry := '';
        with scrn_fld_def[26] do       {Verify ans}
          fld_entry := '';
        end;

     repeat
        LANGENTR(scrn_misc_data);

        {--present error msg-----------------------------------}
        with scrn_misc_data do
           begin
           scrn_clrscrn  := false;
           scrn_fld_def[24].fld_entry := '';
           curs_pos_fld  := 0;
           WkChgChar := upcase(scrn_fld_def[20].fld_entry[1]);
           WkChgNum := 0;
           case WkChgChar of
              '*' : ;
              'R' : WkChgNum := 1;
              'G' : WkChgNum := 2;
              'M' : WkChgNum := 3;
              'B' : WkChgNum := 4;
              else scrn_fld_def[24].fld_entry := 'Please select R,G,M,B or *';
              end;
           if WkChgNum > 0 then
              if SessChgType[HdrRec.SessType,WkChgNum] = 0 then
                 scrn_fld_def[24].fld_entry := 'Cannot change to this type.  Try again.';
           if scrn_fld_def[24].fld_entry = '' then
              scrn_fld_def[24].fld_color := NormColor
           else
              scrn_fld_def[24].fld_color := BriteColor;
           end;
     until (scrn_misc_data.scrn_fld_def[24].fld_entry = '') or
           (scrn_misc_data.scrn_hot_keyhit = 'aster');

     {--present verify  screen------------------------------}

     if (scrn_misc_data.scrn_hot_keyhit <> 'aster') then
     if (WkChgNum > 0) then
        begin
        with scrn_misc_data do
           begin
           scrn_fld_def[20].fld_editable := false;
           scrn_fld_def[24].fld_entry :=
                           SessChgMsg[SessChgType[HdrRec.SessType,WkChgNum]];
           scrn_fld_def[25].fld_entry := 'Please verify if you want this change (y/n):';
           scrn_fld_def[25].fld_color := BriteColor;
           scrn_fld_def[26].fld_entry := 'N';
           scrn_fld_def[26].fld_color := EntryColor;
           scrn_fld_def[26].fld_editable := true;
           if scrn_fld_def[24].fld_entry = '' then
              scrn_fld_def[24].fld_color := NormColor
           else
              scrn_fld_def[24].fld_color := BriteColor;
           end;
        repeat
           LANGENTR(scrn_misc_data);
        until (upcases(scrn_misc_data.scrn_fld_def[26].fld_entry) = 'Y') or
              (upcases(scrn_misc_data.scrn_fld_def[26].fld_entry) = 'N') or
              (scrn_misc_data.scrn_hot_keyhit = 'aster');

        {--update file-----------------------------------------}
        if (scrn_misc_data.scrn_hot_keyhit <> 'aster') then
        if upcases(scrn_misc_data.scrn_fld_def[26].fld_entry) = 'Y' then
           begin
           WkLine := blankline;
           insert(FMT_DT_TIME, WkLine,1);
           insert('Session mode changed from ' +
                  SessDisplay[HdrRec.SessType] + ' to ' +
                  SessDisplay[WkChgNum] + '.',
                  WkLine,19);
           writehist(WkLine);
           {0==>if UC or NW, use Hdr #wds}
           RESETF(HdrRec.SessType,WkChgNum,0,HdrRec.NWOrder);
           end;
        end;
end;

{************************************************************************}
procedure TOGGLENWLESS;       {toggle NW skip on/off}
begin
     GETFDATA;
     HdrRec.NWSkipOn := not HdrRec.NWSkipOn;
     UPDATE_HDR;
     WkLine := blankline;
     insert(FMT_DT_TIME, WkLine,1);
     insert('New word skip=' +
            BOOLSTRING(HdrRec.NWSkipOn),
            WkLine,60);
     writehist(WkLine);
end;

{************************************************************************}
procedure CHG_OPTIONS;
  var
     wkerr       :  string[74];
     wkquit      :  boolean;
     wkhdr       :  YourHdr;

  procedure VALIDATE_OPTS;
    var
       dummy  :  integer;
       WkNumChar : string[3];

     begin

     if upcases(scrn_misc_data.scrn_fld_def[21].fld_entry) = 'Y' then
        begin
        wkhdr.MaxLess     :=  0;
        wkhdr.ErrRptCnt   :=  6;
        wkhdr.TypoOnRg    := false;
        wkhdr.TypoOnRc    := false;
        wkhdr.DropbackOn  := true;
        wkhdr.NWskipOn    := false;
        wkhdr.HistoryOn   := true;
        scrn_misc_data.scrn_fld_def[14].fld_entry := '0';
        scrn_misc_data.scrn_fld_def[15].fld_entry := '6';
        scrn_misc_data.scrn_fld_def[16].fld_entry := 'N';
        scrn_misc_data.scrn_fld_def[17].fld_entry := 'N';
        scrn_misc_data.scrn_fld_def[18].fld_entry := 'Y';
        scrn_misc_data.scrn_fld_def[19].fld_entry := 'N';
        scrn_misc_data.scrn_fld_def[20].fld_entry := 'N'; {On=Y->disable=N}
        end;


     if wkerr = '' then
        begin
        WkNumChar := scrn_misc_data.scrn_fld_def[14].fld_entry;
        WkNumChar := TRIM_FRONT(TRIM_TRAIL(WkNumChar));
        val(WkNumChar,wkhdr.MaxLess,dummy);
        if (dummy > 0) or
           (wkhdr.MaxLess < 0) or (wkhdr.MaxLess > 999) then
           wkerr := 'Invalid maximum lesson size.  Please enter 0 or 1 - 999.';
        end;

     if wkerr = '' then
        begin
        WkNumChar := scrn_misc_data.scrn_fld_def[15].fld_entry;
        WkNumChar := TRIM_FRONT(TRIM_TRAIL(WkNumChar));
        val(WkNumChar,wkhdr.ErrRptCnt,dummy);
        if (dummy > 0) or
           (wkhdr.ErrRptCnt < 0) or (wkhdr.ErrRptCnt > 99) then
           wkerr := 'Invalid number error practices.  Please enter 1 - 99.';
        end;

     if wkerr = '' then
        if upcases(scrn_misc_data.scrn_fld_def[16].fld_entry) = 'Y' then
           wkhdr.TypoOnRg := true
        else
        if upcases(scrn_misc_data.scrn_fld_def[16].fld_entry) = 'N' then
           wkhdr.TypoOnRg := false
        else
           wkerr := 'Enter Y (=yes) or N (=no) for typo retry for RECOG.';

     if wkerr = '' then
        if upcases(scrn_misc_data.scrn_fld_def[17].fld_entry) = 'Y' then
           wkhdr.TypoOnRc := true
        else
        if upcases(scrn_misc_data.scrn_fld_def[17].fld_entry) = 'N' then
           wkhdr.TypoOnRc := false
        else
           wkerr := 'Enter Y (=yes) or N (=no) for typo retry for RECALL.';

     if wkerr = '' then
        if upcases(scrn_misc_data.scrn_fld_def[18].fld_entry) = 'Y' then
           wkhdr.DropbackOn := true
        else
        if upcases(scrn_misc_data.scrn_fld_def[18].fld_entry) = 'N' then
           wkhdr.DropbackOn := false
        else
           wkerr := 'Enter Y (=yes) or N (=no) for error dropback.';

     if wkerr = '' then
        if upcases(scrn_misc_data.scrn_fld_def[19].fld_entry) = 'Y' then
           wkhdr.NWskipOn := true
        else
        if upcases(scrn_misc_data.scrn_fld_def[19].fld_entry) = 'N' then
           wkhdr.NWskipOn := false
        else
           wkerr := 'Enter Y (=yes) or N (=no) for skip of New Word lesson.';

     { note: disable-log=y means HistoryOn=false}
     if wkerr = '' then
        if upcases(scrn_misc_data.scrn_fld_def[20].fld_entry) = 'Y' then
           wkhdr.HistoryOn := false
        else
        if upcases(scrn_misc_data.scrn_fld_def[20].fld_entry) = 'N' then
           wkhdr.HistoryOn := true
        else
           wkerr := 'Enter Y (=yes) or N (=no) for disabling history log.';
     if wkerr = '' then
          if wkerr = '' then
             if (wkhdr.MaxLess      = HdrRec.MaxLess    )  and
                (wkhdr.ErrRptCnt    = HdrRec.ErrRptCnt  )  and
                (wkhdr.TypoOnRg     = HdrRec.TypoOnRg   )  and
                (wkhdr.TypoOnRc     = HdrRec.TypoOnRc   )  and
                (wkhdr.DropbackOn   = HdrRec.DropbackOn )  and
                (wkhdr.NWskipOn     = HdrRec.NWskipOn   )  and
                (wkhdr.HistoryOn    = HdrRec.HistoryOn  )  then
                wkerr := 'No changes made from current options.';
     end;
  procedure HISTOPT;
     begin
       WkLine := blankline;
       insert(FMT_DT_TIME, WkLine,1);
       insert('Session options changed:',WkLine,20);
       writehist(WkLine);
       if (wkhdr.MaxLess     <> HdrRec.MaxLess    )  then
          begin
          WkLine := blankline;
          insert('Maximum words for ladder lessons changed from ' +
                 NUMSTRING(HdrRec.MaxLess) +
                 ' to ' +
                 NUMSTRING(wkhdr.MaxLess) +
                 '.',
                 WkLine,20);
          writehist(WkLine);
          end;
       if (wkhdr.ErrRptCnt   <> HdrRec.ErrRptCnt  )  then
          begin
          WkLine := blankline;
          insert(
                 'Number of times to practice errors changed from ' +
                 NUMSTRING(HdrRec.ErrRptCnt) +
                 ' to ' +
                 NUMSTRING(wkhdr.ErrRptCnt) +
                 '.',
                 WkLine,20);
          writehist(WkLine);
          end;
       if (wkhdr.TypoOnRg    <> HdrRec.TypoOnRg   )  then
          begin
          WkLine := blankline;
          insert('Second try for Recog typos = ' +
                 BOOLSTRING(wkhdr.TypoOnRg),
                 WkLine,20);
          writehist(WkLine);
          end;
       if (wkhdr.TypoOnRc    <> HdrRec.TypoOnRc   )  then
          begin
          WkLine := blankline;
          insert('Second try for Recall typos = ' +
                 BOOLSTRING(wkhdr.TypoOnRc),
                 WkLine,20);
          writehist(WkLine);
          end;
       if (wkhdr.DropbackOn  <> HdrRec.DropbackOn )  then
          begin
          WkLine := blankline;
          insert(
                 'Error drop back to Dropback Pile = ' +
                 BOOLSTRING(wkhdr.DropbackOn),
                 WkLine,20);
          writehist(WkLine);
          end;
       if (wkhdr.NWskipOn    <> HdrRec.NWskipOn   )  then
          begin
          WkLine := blankline;
          insert(
                 'New word skipped = ' +
                 BOOLSTRING(wkhdr.NWskipOn),
                 WkLine,20);
          writehist(WkLine);
          end;
       if (wkhdr.HistoryOn   <> HdrRec.HistoryOn  )  then
          begin
          WkLine := blankline;
          insert(
                 'History Log on = ' +
                 BOOLSTRING(wkhdr.HistoryOn),
                 WkLine,20);
          writehist(WkLine);
          end;
     end;

begin
   GETFDATA;
   wkhdr := HdrRec;
   wkquit := false;
   FMT_OPTIONS;

   str(HdrRec.MaxLess,  scrn_misc_data.scrn_fld_def[14].fld_entry);
   str(HdrRec.ErrRptCnt,scrn_misc_data.scrn_fld_def[15].fld_entry);

   if HdrRec.TypoOnRg then
     scrn_misc_data.scrn_fld_def[16].fld_entry := 'Y'
   else
     scrn_misc_data.scrn_fld_def[16].fld_entry := 'N';

   if HdrRec.TypoOnRc then
     scrn_misc_data.scrn_fld_def[17].fld_entry := 'Y'
   else
     scrn_misc_data.scrn_fld_def[17].fld_entry := 'N';

   if HdrRec.DropbackOn then
     scrn_misc_data.scrn_fld_def[18].fld_entry := 'Y'
   else
     scrn_misc_data.scrn_fld_def[18].fld_entry := 'N';

   if HdrRec.NWskipOn then
     scrn_misc_data.scrn_fld_def[19].fld_entry := 'Y'
   else
     scrn_misc_data.scrn_fld_def[19].fld_entry := 'N';

   if HdrRec.HistoryOn then         {On=yes->disable=no}
     scrn_misc_data.scrn_fld_def[20].fld_entry := 'N'
   else
     scrn_misc_data.scrn_fld_def[20].fld_entry := 'Y';

   scrn_misc_data.scrn_fld_def[21].fld_entry := 'N';

   {----get values-----------------------------}
   repeat
      LANGENTR(scrn_misc_data);
      if scrn_misc_data.scrn_hot_keyhit = 'aster' then
         wkquit := true
      else
         begin
         scrn_misc_data.scrn_clrscrn := false;
         wkerr := '';
         VALIDATE_OPTS;
         scrn_misc_data.scrn_fld_def[24].fld_entry := wkerr;
         if wkerr > '' then
            scrn_misc_data.scrn_fld_def[24].fld_color := BriteColor
         else
            scrn_misc_data.scrn_fld_def[24].fld_color := NormColor;
         end;
   until wkquit or (wkerr = '');

   if wkquit then exit;

   {----confirm change-------------------------}
   for i := 13 to 21 do
       scrn_misc_data.scrn_fld_def[i].fld_editable := false;

   scrn_misc_data.scrn_fld_def[22].fld_entry :=
             'Confirm update of file with above information? (Y/N):';
   scrn_misc_data.scrn_fld_def[23].fld_editable := true;
   scrn_misc_data.scrn_fld_def[23].fld_entry := 'N';
   scrn_misc_data.scrn_fld_def[23].fld_color := EntryColor;

   repeat
      LANGENTR(scrn_misc_data);
      wkerr := '';
      if scrn_misc_data.scrn_hot_keyhit = 'aster' then
         q := '*'
      else
         begin
         if length(scrn_misc_data.scrn_fld_def[23].fld_entry) > 0 then
            q := scrn_misc_data.scrn_fld_def[23].fld_entry[1]
         else
            q := ' ';
         q := upcase(q);
         end;
      case q of
        'Y' : begin
              HISTOPT;
              {--report history turned off---}
              if (not wkhdr.HistoryOn) and (HdrRec.HistoryOn)  then
                 begin
                 HdrRec := wkhdr;
                 WkLine := blankline;
                 insert(
                        'History Log on = ' +
                        BOOLSTRING(wkhdr.HistoryOn),
                        WkLine,20);
                 writehist(WkLine);
                 end
              else
                 HdrRec := wkhdr;
              if HdrRec.SessType <> 1 then
                 with HdrRec do
                   begin
                   if ErrRptCnt > MaxErrRptUsed then
                      MaxErrRptUsed := ErrRptCnt;
                   if MaxLess   > MaxLessUsed then
                      MaxLessUsed := MaxLess;
                   if TypoOnRg then
                      RgTypoUsed := true;
                   if TypoOnRc then
                      RcTypoUsed := true;
                   if not DropbackOn then
                      DropbackStop := true;
                   end;
              UPDATE_HDR;
              end;
        'N' : {no action};
        '*' : {no action};
        else begin
             wkerr := 'Invalid response.  Please enter Y or N.';
             scrn_misc_data.scrn_fld_def[24].fld_entry := wkerr;
             if wkerr > '' then
                scrn_misc_data.scrn_fld_def[24].fld_color := BriteColor
             else
                scrn_misc_data.scrn_fld_def[24].fld_color := NormColor;
             end;
        end;
   until (wkerr = '');

end;
{************************************************************************}
procedure CHG_COLORS;
   const
      grid_0_x      :  integer = 06;        {add colorgridx for real position}
      grid_0_y      :  integer = 05;        {add colorgridy for real position}
   var
      fld_type      :  integer;
      key1          :  char;
      key2          :  char;
      new_x         :  integer;
      new_y         :  integer;
      old_x         :  integer;
      old_y         :  integer;
      wk_color      :  integer;
      wk_done       :  boolean;
      wk_norm       :  integer;
      wk_brite      :  integer;
      wk_entry      :  integer;
      wk_retry      :  boolean;
      wkerr         :  string[80];

   {------------------------------------------------------------------}
   procedure SHOW_GRID(first_y : integer);
     var
        wk_scrn       :  scrn_def;
        x             :  integer;
        y             :  integer;

      begin
      with wk_scrn do
        begin;
        extra_char    := true;
        scrn_num_flds := 64;
        scrn_order[1] := 0;
        if first_y = 0 then
           scrn_clrscrn  := true
        else
           scrn_clrscrn  := false;
        curs_pos_fld  := 1;   {cursor on 1st pos for now}
        scrn_hotkey_cnt := 0;
        scrn_hot_keyhit  := '';
        scrn_clr_color   := NormColor;
        scrn_order[1]    := 0;
        i := 0;
        for y := first_y to (first_y + 3) do
            for x := 0 to 15 do
               begin
               i := i + 1;
               with scrn_fld_def[i] do
                 begin
                 fld_entry := ' X ';
                 fld_len   := 3;
                 fld_row   := y + grid_0_y;
                 fld_col_start := (3 * x) + grid_0_x;
                 fld_editable := false;
                 fld_color := x + (16 * y);
                 end;
               end;
        end;
      SCREENIO(wk_scrn);
      end; {show grid}

   {------------------------------------------------------------------}
   procedure FMT_TEXT;
     const
        LineText : array [1..33] of string[80] =   {other than grid}
(
{-----------------------------------------------------------------------------}

{1-5}
                              'COLOR CHANGE SCREEN',
'TAB-select Color type:',
      'Normal display items',    'Emphasized Items',  'Your entry items',
{6-9}
'TABs   for color type',
'ARROWs for color grid',
'ENTER when done',
'* to cancel',
{10-16}
'  ','   ',               {OLD row, column pointers: right-arrow, down-arrow}
#45#26,#32#25#32,               {NEW row, column pointers: right-arrow, down-arrow}
'', '',                 {confirm request}
'',                     {error msg}
{17-33}
'様様様様様様様様様様様様様様様様様様様様様様様様様様様様様様様様様様様様様様様',
'                             SAMPLE SCREEN                                    ',
'                                                                              ',
' ','foreign-word    ','                       auxiliary info on foreign word        ',
'                                                                              ',
' Please enter the English translation:                                        ',
'                                                                              ',
' ','You enter here        ','                                                       ',
'                                                                              ',
' ','Error - It should be:  ','real-answer     def=English definition.               ',
'                                                                              '
);
{-----------------------------------------------------------------------------}

        LineRow : array[1..33] of integer =
                  ( 1, 2,
                    3, 3, 3,
                    7, 8,10, 11,
                    0, 4,          {OLD row-ptr to be assigned later}
                    0, 4,          {NEW row-ptr to be assigned later}
                   13,13,14,       {confirm & response; error}
                   15,
                   16,17,
                   18,18,18,
                   19,20,21,
                   22,22,22,
                   23,
                   24,24,24,
                   25);

        LineLen : array[1..33] of integer =
                  (19,22,
                   20,16,16,
                   21,21,21,21,
                    2, 3,          {OLD row-ptr to be assigned later}
                    2, 3,          {NEW row-ptr to be assigned later}
                   46, 1,80,       {confirm & response; error}
                   78,
                   78,78,
                    1,16,61,
                   78,78,78,
                    1,22,55,
                   78,
                    1,23,54,
                   78);

        LineCol : array[1..33] of integer =
                  (32, 1 ,
                    9,34,55,
                   58,58,58,58,
                    4, 0,          {OLD col-ptr to be assigned later}
                    4, 0,          {NEW col-ptr to be assigned later}
                    1,48, 1,       {confirm & response; error}
                    2,
                    2, 2,
                    2, 3,19,
                    2, 2, 2,
                    2, 3,25,
                    2,
                    2, 3,26,
                    2);

      begin
      with scrn_misc_data do
        begin;
        extra_char    := true;
        scrn_num_flds := 35;             {2 extra for color grid undo/do}
        scrn_order[1] := 0;
        scrn_clrscrn  := false;
        curs_pos_fld  := 2 + fld_type;   {cursor on color type}
        scrn_hotkey_cnt := 0;
        scrn_hot_keyhit  := '';
      for i := 1 to 33 do
       with scrn_fld_def[i] do
         begin
         fld_entry := LineText[i];
         fld_len   := LineLen[i];
         fld_row   := LineRow[i];
         fld_col_start := LineCol[i];
         fld_editable := false;
         fld_color := NormColor;
         end;
      end;
   end; {fmt text}

   {------------------------------------------------------------------}
   procedure FMT_COLOR;
      begin
      with scrn_misc_data do
         begin
         curs_pos_fld  := 2 + fld_type;   {cursor on color type}

         {undo old color grid position}
         with scrn_fld_def[34] do
            begin
            fld_entry := ' X ';
            fld_len   := 3;
            fld_row   := old_y + grid_0_y;
            fld_col_start := (3 * old_x) + grid_0_x;
            fld_editable := false;
            fld_color := old_x + (16 * old_y);
            end;

         {do new color grid position}
         with scrn_fld_def[35] do
            begin
            fld_entry := #26 + 'O' + #27;
            fld_len   := 3;
            fld_row   := new_y + grid_0_y;
            fld_col_start := (3 * new_x) + grid_0_x;
            fld_editable := false;
            fld_color := new_x + (16 * new_y);
            case fld_type of
               1 : wk_norm  := fld_color;
               2 : wk_brite := fld_color;
               3 : wk_entry := fld_color;
               end;
            end;

         {sample screen fields}
         scrn_fld_def[18].fld_color := wk_norm;
         scrn_fld_def[19].fld_color := wk_norm;
         scrn_fld_def[20].fld_color := wk_norm;
         scrn_fld_def[21].fld_color := wk_brite;
         scrn_fld_def[22].fld_color := wk_norm;
         scrn_fld_def[23].fld_color := wk_norm;
         scrn_fld_def[24].fld_color := wk_norm;
         scrn_fld_def[25].fld_color := wk_norm;
         scrn_fld_def[26].fld_color := wk_norm;
         scrn_fld_def[27].fld_color := wk_entry;
         scrn_fld_def[28].fld_color := wk_norm;
         scrn_fld_def[29].fld_color := wk_norm;
         scrn_fld_def[30].fld_color := wk_norm;
         scrn_fld_def[31].fld_color := wk_brite;
         scrn_fld_def[32].fld_color := wk_norm;
         scrn_fld_def[33].fld_color := wk_norm;

         scrn_fld_def[01].fld_color := NormColor;   {screen title}
         scrn_fld_def[02].fld_color := NormColor;

         {tab-able color types}
         if fld_type = 1 then
            scrn_fld_def[03].fld_color := BriteColor
         else
            scrn_fld_def[03].fld_color := NormColor;

         if fld_type = 2 then
            scrn_fld_def[04].fld_color := BriteColor
         else
            scrn_fld_def[04].fld_color := NormColor;

         if fld_type = 3 then
            scrn_fld_def[05].fld_color := BriteColor
         else
            scrn_fld_def[05].fld_color := NormColor;

         {screen instructions}
         scrn_fld_def[06].fld_color := NormColor;
         scrn_fld_def[07].fld_color := NormColor;
         scrn_fld_def[08].fld_color := NormColor;
         scrn_fld_def[09].fld_color := NormColor;

         {color grid pointers on outside}
         scrn_fld_def[10].fld_color := NormColor;
         scrn_fld_def[11].fld_color := NormColor;
         scrn_fld_def[12].fld_color := BriteColor;
         scrn_fld_def[13].fld_color := BriteColor;

         {undo old color grid position outside markers}
         scrn_fld_def[10].fld_row       := old_y + grid_0_y;
         scrn_fld_def[11].fld_col_start := (3 * old_x) + grid_0_x;

         {do new color grid position}
         scrn_fld_def[12].fld_row       := new_y + grid_0_y;
         scrn_fld_def[13].fld_col_start := (3 * new_x) + grid_0_x;

         {screen divider between work scrren and sample screen}
         scrn_fld_def[17].fld_color := NormColor;

         {Error msg}
         if wkerr > '' then
            begin
            scrn_fld_def[16].fld_color := BriteColor;
            scrn_fld_def[16].fld_entry := wkerr;
            end
         else
            begin
            scrn_fld_def[16].fld_color := NormColor;
            scrn_fld_def[16].fld_entry := '';
            end;

         end;
      end;

   {------------------------------------------------------------------}
begin
   wk_norm  := NormColor;
   wk_brite := BriteColor;
   wk_entry := EntryColor;
   fld_type := 1; {on normal color to start}
   old_x := NormColor mod 16;
   old_y := NormColor div 16;
   new_x := old_x;
   new_y := old_y;
   wkerr := '';

   FMT_TEXT;
   {color grid divided in half to keep array under 65}
   SHOW_GRID(0);  {top half of grid (0-0 to 3-16)}
   SHOW_GRID(4);  {bottom half of grid (0-4 to 7-15)}

   repeat
      FMT_COLOR;
      SCREENIO(scrn_misc_data);
      old_x := new_x;
      old_y := new_y;
      wkerr := '';
      wk_done := false;
      quietread(key1,key2);
      case key1 of
         #0 :
             case key2 of
               #15 : {backtab}
                     begin
                     case fld_type of
                        1 : begin
                            fld_type := 3;
                            wk_color := wk_entry;
                            end;
                        2 : begin
                            fld_type := 1;
                            wk_color := wk_norm;
                            end;
                        3 : begin
                            fld_type := 2;
                            wk_color := wk_brite;
                            end;
                        end;
                     new_x := wk_color mod 16;
                     new_y := wk_color div 16;
                     end;
               #16 : {Alt-Q} EXIT_ROUTINE;
               #72 : {up arrow}
                     if old_y > 0 then
                        new_y := old_y - 1;
               #80 : {down arrow}
                     if old_y < 7 then
                        new_y := old_y + 1;
               #75 : {left arrow}
                     if old_x > 0 then
                        new_x := old_x - 1;
               #77 : {right arrow}
                     if old_x < 15 then
                        new_x := old_x + 1;
                else
                   wkerr := 'Invalid key.  Use TABs, ARROWs, ENTER or *.';
               end;
         #9 : {tab}
              begin
              case fld_type of
                 1 : begin
                     fld_type := 2;
                     wk_color := wk_brite;
                     end;
                 2 : begin
                     fld_type := 3;
                     wk_color := wk_entry;
                     end;
                 3 : begin
                     fld_type := 1;
                     wk_color := wk_norm;
                     end;
                 end;
              new_x := wk_color mod 16;
              new_y := wk_color div 16;
              end;
         #13 : {enter}
               begin
               with scrn_misc_data do
                begin
                curs_pos_fld  := 0;
                scrn_hotkey_cnt  := 1;
                scrn_hot_keyhit  := '';
                scrn_hot_keys[1] := 'aster';
                with scrn_fld_def[14] do
                  begin
                  fld_entry := 'Confirm update of file with new colors? (Y/N):';
                  fld_color := BriteColor;
                  end;
                with scrn_fld_def[15] do
                  begin
                  fld_entry := 'N';
                  fld_color := EntryColor;
                  fld_editable := true;
                  end;
                scrn_fld_def[16].fld_entry := '';
                scrn_fld_def[16].fld_color := NormColor;
                end;
               wk_retry := false;
               repeat
                  SCREENIO(scrn_misc_data);
                 with scrn_misc_data do
                   begin
                   scrn_fld_def[16].fld_entry := '';
                   scrn_fld_def[16].fld_color := NormColor;
                   if scrn_hot_keyhit = 'aster' then
                      wk_done := true
                   else
                   if upcases(scrn_fld_def[15].fld_entry) = 'N' then
                      begin
                      scrn_fld_def[14].fld_entry := '';
                      scrn_fld_def[14].fld_color := NormColor;
                      scrn_fld_def[15].fld_entry := '';
                      scrn_fld_def[15].fld_color := NormColor;
                      scrn_fld_def[15].fld_editable := false;
                      scrn_fld_def[16].fld_entry := '';
                      scrn_fld_def[16].fld_color := NormColor;
                      wk_retry := true;
                      end
                   else
                   if upcases(scrn_fld_def[15].fld_entry) = 'Y' then
                      begin
                      HdrRec.NormColorH  := wk_norm;
                      HdrRec.BriteColorH := wk_brite;
                      HdrRec.EntryColorH := wk_entry;
                      NormColor          := wk_norm;
                      BriteColor         := wk_brite;
                      EntryColor         := wk_entry;
                      UPDATE_HDR;
                      wk_done := true;
                      end
                   else
                   if scrn_fld_def[15].fld_entry = '*' then
                      wk_done := true
                   else
                      scrn_fld_def[16].fld_entry :=
                                      'Please answer Y (=yes) or N (=no).';
                      scrn_fld_def[16].fld_color := BriteColor;
                   end;
               until wk_done or (wk_retry);
               end;
         '*' : wk_done := true;
         #17 : {Alt-Q} EXIT_ROUTINE;
         else
            wkerr := 'Invalid key.  Use TABs, ARROWs, ENTER or *.';
         end;
   until (wk_done);
end;
{************************************************************************}
procedure DISPLAY_WORDS(DisplayRequest, LookupOrder, StartWord: string);
   var
      i                      :  integer;
      DsplyData              :  dsplyptr;
      KeywdEdited            :  boolean;
      LinesPerWd             :  integer;
      PageCnt                :  integer;
      PageNo                 :  integer;
      PageTitle              :  string[45];
      PrintFmt               :  char;
      PrintLinesPerPage      :  integer;
      PrintDevice            :  string[4];
      PrintOpen              :  boolean;
      QuitSelect             :  boolean;
      SelectLetter           :  string[1];
      SelectOrder            :  string[1];
      SelectPile             :  integer;
      SelectSubPile          :  integer;
      QuitDisplay            :  boolean;
      SavePrintFmt           :  char;
      SavePrintLines         :  integer;
      SavePrinter            :  string[4];
      SaveOrder              :  string[1];
      StartSub               :  integer;
      TotNumWords            :  integer;
      WdNo                   :  integer;
      WdsPerPage             :  integer;
      WdsPerScreen           :  integer;
      WdsThisPage            :  integer;
      wk                     :  integer;
      WkErr                  :  string[80];
   {==================================================================}
   procedure VALIDATE_DISPLAY_SELECTION;
     var
        dummy : integer;
     begin
     SelectPile := 0;
     SelectSubPile := 0;
     with scrn_misc_data do
        begin
        SelectOrder  := upcases(scrn_fld_def[49].fld_entry);
        if (SelectOrder = 'E') or
           (SelectOrder = 'L') or
           (SelectOrder = 'P') then
           begin
           SelectLetter := upcases(scrn_fld_def[58].fld_entry);
           if SelectLetter = 'A' then
              begin
              SelectPile := 0;
              SelectSubPile := 0;
              end
           else
           if SelectLetter = 'B' then
              begin
              val(scrn_fld_def[06].fld_entry, SelectPile, dummy);
              if scrn_fld_def[06].fld_entry = '' then
                 WkErr := 'Lesson number must be entered for selection B'
              else
              if (dummy <> 0) then
                 WkErr := 'Lesson number must be numeric for selection B'
              else
              if (SelectPile < 1) or (SelectPile > 14) then
                 WkErr := 'Lesson number must be 1 to 14 for selection B'
              else
                 if SelectPile = 1 then
                    if upcases(scrn_fld_def[10].fld_entry) = 'Y' then
                       SelectSubPile := GETOLDEST(SelectPile)
                    else
                    if upcases(scrn_fld_def[10].fld_entry) = 'N' then
                       SelectSubPile := 0
                    else
                       WkErr := 'Enter Y or N for Under Control next lesson only'
                 else
                 if SelectPile = 13 then
                    if upcases(scrn_fld_def[35].fld_entry) = 'Y' then
                       SelectSubPile := GETOLDEST(SelectPile)
                    else
                    if upcases(scrn_fld_def[35].fld_entry) = 'N' then
                       SelectSubPile := 0
                    else
                       WkErr := 'Enter Y or N for New Word next lesson only'
                 else
                    SelectSubPile := 0;
              end
           else
              WkErr := 'Invalid selection for display type.  Must be A or B';
           end
        else
           WkErr := 'Ordering must be E, L, or P';
        if (DisplayRequest = 'print') and (WkErr = '') then
           begin
           PrintFmt := upcase(char(scrn_fld_def[43].fld_entry[1]));
           if (PrintFmt <> 'B') and (PrintFmt <> 'C') then
              WkErr := 'Please enter "B" or "C" for print format'
           else
              begin
              val(scrn_fld_def[45].fld_entry, PrintLinesPerPage, dummy);
              if scrn_fld_def[45].fld_entry = '' then
                 WkErr := 'Please enter number of lines to print per page'
              else
              if (dummy <> 0) then
                 WkErr := 'Number of lines per page must be numeric'
              else
                 begin
                 PrintDevice := upcases(scrn_fld_def[47].fld_entry);
                 if (PrintDevice <= '    ') then
                    WkErr := 'Please enter name of printer device';
                 end;
              if PrintFmt = 'C' then
                 LinesPerWd := 4
              else
                 LinesPerWd := 1;
              if (WkErr = '') then
                 begin
                 if PrintOpen then
                    begin
                    CLOSEPRINT(PrintDevice);
                    PrintOpen := false;
                    end;
                 OPENPRINT(PrintDevice,WkErr);
                 if WkErr = '' then
                    PrintOpen := true;
                 end;
              end;
           end;
        end;
     end;
   {==================================================================}
   procedure GET_DISPLAY_SELECTION;
   begin
      FMT_DISPLAY_SELECTION(DisplayRequest);
      if SaveOrder              > '' then
         scrn_misc_data.scrn_fld_def[49].fld_entry := SaveOrder;
      if (DisplayRequest = 'print') then
         begin
         if SavePrintFmt           > ' ' then
            scrn_misc_data.scrn_fld_def[43].fld_entry := SavePrintFmt;
         if SavePrintLines         > 0  then
            scrn_misc_data.scrn_fld_def[45].fld_entry := NUMSTRING(SavePrintLines);
         if SavePrinter            > '' then
            scrn_misc_data.scrn_fld_def[47].fld_entry := SavePrinter;
         end
      else
         begin
         scrn_misc_data.scrn_fld_def[43].fld_entry := ' ';
         scrn_misc_data.scrn_fld_def[45].fld_entry := '';
         scrn_misc_data.scrn_fld_def[47].fld_entry := '';
         end;
      repeat
         scrn_misc_data.scrn_fld_def[59].fld_entry := WkErr;
         {---get display type----------}
         if WkErr = '' then
            scrn_misc_data.scrn_fld_def[59].fld_color := NormColor
         else
            scrn_misc_data.scrn_fld_def[59].fld_color := BriteColor;
         LANGENTR(scrn_misc_data);
         WkErr := '';
         if scrn_misc_data.scrn_hot_keyhit = 'aster' then
            QuitDisplay := true
         else
            VALIDATE_DISPLAY_SELECTION;

      until (Quitdisplay) or (WkErr = '');
      SaveOrder      := SelectOrder;
      if (DisplayRequest = 'print') then
         begin
         SavePrintFmt   := PrintFmt;
         SavePrintLines := PrintLinesPerPage;
         SavePrinter    := PrintDevice;
         end
      else
         begin
         SavePrintFmt   := ' ';
         SavePrintLines := 0;
         SavePrinter    := '';
         end;
   end;
   {==================================================================}
   procedure EDITWD;
   begin
       {disregard number of spaces}
       with scrn_misc_data, scrn_fld_def[16] do
          fld_entry := TRIM_FRONT(TRIM_TRAIL(fld_entry));
       with scrn_misc_data, scrn_fld_def[18] do
          fld_entry := TRIM_FRONT(TRIM_TRAIL(fld_entry));
       arr[1]^.wd.en := TRIM_FRONT(TRIM_TRAIL(arr[1]^.wd.en));
       arr[1]^.wd.ec := TRIM_FRONT(TRIM_TRAIL(arr[1]^.wd.ec));

       if ((scrn_misc_data.scrn_fld_def[16].fld_entry = arr[1]^.wd.en) or
           (scrn_misc_data.scrn_fld_def[16].fld_entry = '')          ) and
          (scrn_misc_data.scrn_fld_def[18].fld_entry = arr[1]^.wd.ec) then
          {no change}
       else
          begin
          with scrn_misc_data do
             begin
             scrn_hotkey_cnt := 0;
             scrn_fld_def[8].fld_editable := false;
             scrn_fld_def[16].fld_editable := false;
             scrn_fld_def[18].fld_editable := false;
             scrn_fld_def[5].fld_len   := 35;
             scrn_fld_def[5].fld_color := BriteColor;
             scrn_fld_def[5].fld_entry := 'Please verify update to word (Y/N):';
             scrn_fld_def[6].fld_len   := 1;
             scrn_fld_def[6].fld_col_start := 40;
             scrn_fld_def[6].fld_color := EntryColor;
             scrn_fld_def[6].fld_editable := true;
             scrn_fld_def[6].fld_entry := 'N';
             end;
          repeat
             LANGENTR(scrn_misc_data);
          until (upcases(scrn_misc_data.scrn_fld_def[6].fld_entry) = 'Y') or
                (upcases(scrn_misc_data.scrn_fld_def[6].fld_entry) = 'N');

          if (upcases(scrn_misc_data.scrn_fld_def[6].fld_entry) = 'Y') then
             with scrn_misc_data do
                begin
                if (scrn_fld_def[16].fld_entry <> arr[1]^.wd.en) then
                   begin
                   arr[1]^.wd.en := scrn_fld_def[16].fld_entry;
                   KeywdEdited := true;
                   end;
                if (scrn_fld_def[18].fld_entry <> arr[1]^.wd.ec) then
                   arr[1]^.wd.ec := scrn_fld_def[18].fld_entry;
                UPDTWDFILE(1);
                end;
          end;
   end;
   {==================================================================}
begin
   new(DsplyData);
   for wk := 1 to 4 do
       new(arr[wk]);
   QuitDisplay := false;
   PrintOpen   := false;
   WdsPerScreen := 1;
   if DisplayRequest = 'edit' then
      WdsPerPage := 1
   else
      WdsPerPage := 4;
   StartSub := 1;
   WkErr := '';
   SavePrintFmt           := ' ';
   SavePrintLines         := 0;
   SavePrinter            := '';
   SaveOrder              := '';

   KeywdEdited := false;
   repeat  {until QuitDisplay}
      for wk := 1 to HdrRec.filenumwds do
         begin
         DsplyData^.DsplyFlags[wk] := '0';
         DsplyData^.DsplyWd[wk] := '';
         DsplyData^.DsplyWdNum[wk] := 0;
         end;
      if (DisplayRequest = 'lookup') or (DisplayRequest = 'edit') then
         begin
         SelectLetter  := 'A';         {Use all words}
         SelectOrder   := LookupOrder;
         SelectPile    := 0;
         SelectSubPile := 0;
         WkErr         := '';
         end
      else
         GET_DISPLAY_SELECTION;

      if (WkErr = '') and (not QuitDisplay) then
        begin
        {---get page starts-----------}
        GET_FLAGS(SelectPile, SelectSubPile, SelectOrder,
                  DsplyData, TotNumWords);
        if DisplayRequest = 'print' then
           begin
           WdsPerPage := trunc((PrintLinesPerPage - 3)/LinesPerWd);
           for wk := 5 to WdsPerPage do
               new(arr[wk]);
           end;
        PageCnt := trunc((TotNumWords-1)/WdsPerPage) + 1;
        WdsThisPage := 1;
        if TotNumWords = 0 then
           WkErr := 'No words selected';
        end;

      if (WkErr = '') and (not QuitDisplay) then
         begin
         GET_DSPLY_LIST(TotNumWords, SelectOrder, DsplyData);

         if (DisplayRequest = 'lookup') or (DisplayRequest = 'edit') then
            begin
            WdsPerScreen := 1;
            SEARCH_NDX(StartWord,
                       DsplyData,
                       WdNo);
            if WdNo > TotNumWords then
               WdNo := TotNumWords;
            PageNo := trunc((WdNo - 1) / WdsPerPage) + 1;
            StartSub := WdNo - (WdsPerPage * (PageNo - 1));
            end
         else
            PageNo := 1;

         if DisplayRequest = 'print' then
            PageTitle := 'PRINT OF'
         else
         if DisplayRequest = 'edit' then
            PageTitle := 'EDIT'
         else
            PageTitle := 'DISPLAY';
         if SelectLetter = 'A' then
            PageTitle := PageTitle + ' ALL WORDS'
         else
         if SelectLetter = 'B' then
            begin
            if SelectSubPile > 0 then
               PageTitle := PageTitle + ' NEXT '
            else
               PageTitle := PageTitle + ' ALL ';
            PageTitle := PageTitle + upcases(s[SelectPile]);
            if odd(SelectPile) then
               PageTitle := PageTitle + ' WORDS'
            else
               PageTitle := PageTitle + ' ERRORS';
            end;

         PageTitle := PageTitle + ' (' + NUMSTRING(TotNumWords) + ')';
         QuitSelect := false;

         {for print, display msg of tot # pages}
         if DisplayRequest = 'print' then
            begin
            scrn_misc_data.scrn_fld_def[06].fld_editable := false;
            scrn_misc_data.scrn_fld_def[10].fld_editable := false;
            scrn_misc_data.scrn_fld_def[35].fld_editable := false;
            scrn_misc_data.scrn_fld_def[43].fld_editable := false;
            scrn_misc_data.scrn_fld_def[45].fld_editable := false;
            scrn_misc_data.scrn_fld_def[47].fld_editable := false;
            scrn_misc_data.scrn_fld_def[49].fld_editable := false;
            scrn_misc_data.scrn_fld_def[58].fld_editable := false;
            scrn_misc_data.scrn_fld_def[59].fld_color := BriteColor;
            scrn_misc_data.scrn_fld_def[59].fld_entry :=
                       'Printing ' + NUMSTRING(PageCnt) + ' pages, with '
                       + NUMSTRING(TotNumWords) + ' words.';
            scrn_misc_data.scrn_fld_def[60].fld_entry :=
                       'Hit any key to cancel print';
            LANGENTR(scrn_misc_data);
            WkErr := '';
            end;

         repeat   {until QuitSelect}
           {---get page "your" and word data--------}
           GET_YOUR_PAGE(DsplyData,WdsPerPage,PageNo,TotNumWords,WdsThisPage);
           GET_WD_DATA(WdsThisPage);

           if DisplayRequest = 'print' then
              begin
              {---print page data-----------}
              PRINTPAGE(PageNo,PageCnt,WdsThisPage,WdsPerPage, PrintFmt,
                       {Pg#,   #pgs,   wds/pg,     wds/page,   B/C    }
                        SelectOrder, PrintDevice, PageTitle,TotNumWords,
                       {L/E/P,       LPT1...      title,    # wds all pgs}
                        WkErr);
                       {errmsg}
              if WkErr = '' then
                 if PageNo < PageCnt then
                    PageNo := PageNo + 1
                 else
                    begin
                    QuitSelect := true;
                    WkErr := 'Done printing';
                    end
              else
                 QuitSelect := true;
              end
           else
              {---show page data------------}
              SHOWPAGE(PageNo,PageCnt,WdsThisPage,WdsPerPage, WdsPerScreen,
                      {Pg#,   #pgs,   wds/pg,     wds/page,   wds/scrn}
                       SelectOrder, DisplayRequest,
                      {L/E/P        ''/lookup/edit   }
                       StartSub,
                      {sub-item to start on}
                       PageTitle,TotNumWords);
                      {title,    # wds all pgs}

           StartSub := 1;
           if (not QuitDisplay) and (DisplayRequest <> 'print') then
              begin
                 {---determine next page-------}
                 if scrn_misc_data.scrn_hot_keyhit = 'aster' then
                    QuitSelect := true
                 else
                 if scrn_misc_data.scrn_hot_keyhit = 'pgup' then
                    PageNo := PageNo - 1
                 else
                 if scrn_misc_data.scrn_hot_keyhit = 'pgdn' then
                    PageNo := PageNo + 1
                 else
                 if scrn_misc_data.scrn_hot_keyhit = 'top' then
                    PageNo := 1
                 else
                 if scrn_misc_data.scrn_hot_keyhit = 'bottom' then
                    PageNo := PageCnt
                 else
                 if scrn_misc_data.scrn_fld_def[8].fld_entry > '' then
                    begin
                    WdsPerScreen := 1;
                    SEARCH_NDX(scrn_misc_data.scrn_fld_def[8].fld_entry,
                               DsplyData,
                               WdNo);
                    if WdNo > TotNumWords then
                       WdNo := TotNumWords;
                    PageNo := trunc((WdNo - 1) / WdsPerPage) + 1;
                    StartSub := WdNo - (WdsPerPage * (PageNo - 1));
                    end
                 else
                 if DisplayRequest = 'edit' then
                    EDITWD;
              end;
         until QuitSelect;
         if PrintOpen then
            begin
            CLOSEPRINT(PrintDevice);
            PrintOpen := false;
            end;
         if (DisplayRequest = 'lookup') or (DisplayRequest = 'edit') then
            Quitdisplay := true;
         end;
   until (Quitdisplay);
   release(heaporg); {release all heap (arr is on heap)}
   if KeywdEdited then
      begin
      with scrn_misc_data do
         begin
           scrn_num_flds    := 2;
           scrn_clrscrn     := true;
           scrn_clr_color   := NormColor;
           curs_pos_fld     := 2;
           scrn_hotkey_cnt  := 0;
           scrn_hot_keyhit  := '';
           scrn_order[1]    := 0;
           with scrn_fld_def[1] do
              begin
              fld_row          := 10;
              fld_col_start    := 10;
              fld_entry        := 'Please wait while the index is updated.';
              fld_len          := 50;
              fld_color        := BriteColor;
              fld_editable     := false;
              end;
           with scrn_fld_def[2] do
              begin
              fld_row          := 10;
              fld_col_start    := 70;
              fld_entry        := '';
              fld_len          := 0;
              fld_color        := NormColor;
              fld_editable     := false;
              end;
           end;
      LANGENTR(scrn_misc_data);
      REDO_NDX;
      end;
end;
{************************************************************************}
procedure LOOKUP_EDIT(DisplayRequest  :  string);
     var
        QuitScrn :  boolean;
        LookupOrder :  string[1];
        StartWord   :  enwdtype;
begin
     QuitScrn := false;
     repeat
        with scrn_misc_data do
           begin
           scrn_num_flds    := 7;
           scrn_clrscrn     := true;
           scrn_clr_color   := NormColor;
           curs_pos_fld     := 0;
           scrn_hotkey_cnt  := 1;
           scrn_hot_keys[1] := 'aster';
           scrn_hot_keyhit  := '';
           scrn_order[1]    := 0;
           with scrn_fld_def[1] do
              begin
              fld_row          := 1;
              fld_col_start    := 28;
              if DisplayRequest = 'edit' then
                 fld_entry        := 'EDIT MENU'
              else
                 fld_entry        := 'LOOK-UP MENU';
              fld_len          := 12;
              fld_color        := NormColor;
              fld_editable     := false;
              end;
           with scrn_fld_def[2] do
              begin
              fld_row          := 7;
              fld_col_start    := 1;
              fld_entry        := TRIM_TRAIL(langname) + ' word:';
              fld_len          := length(fld_entry);
              fld_color        := NormColor;
              fld_editable     := false;
              end;
           with scrn_fld_def[3] do
              begin
              fld_row          := 10;
              fld_col_start    := 1;
              fld_entry        := 'English word:';
              fld_len          := length(fld_entry);
              fld_color        := NormColor;
              fld_editable     := false;
              end;
           with scrn_fld_def[4] do
              begin
              fld_row          := 7;
              if scrn_fld_def[2].fld_len > scrn_fld_def[3].fld_len then
                 fld_col_start    := scrn_fld_def[2].fld_len + 2
              else
                 fld_col_start    := scrn_fld_def[3].fld_len + 2;
              fld_entry        := '';
              fld_len          := lgwdlen;
              fld_color        := EntryColor;
              fld_editable     := true;
              end;
           with scrn_fld_def[5] do
              begin
              fld_row          := 10;
              fld_col_start    := scrn_fld_def[4].fld_col_start;
              fld_entry        := '';
              fld_len          := enwdlen;
              fld_color        := EntryColor;
              fld_editable     := true;
              end;
           with scrn_fld_def[6] do
              begin
              fld_row          := 20;
              fld_col_start    := 1;
              if DisplayRequest = 'edit' then
                 fld_entry        := 'Type in either ' +
                                     TRIM_TRAIL(langname) +
                                     ' or English word ' +
                                     'to edit (* to exit)'
              else
                 fld_entry        := 'Type in either ' +
                                     TRIM_TRAIL(langname) +
                                     ' or English word ' +
                                     'to look up (* to exit)';
              fld_len          := length(fld_entry);
              fld_color        := NormColor;
              fld_editable     := false;
              end;
           with scrn_fld_def[7] do
              begin
              fld_row          := 22;
              fld_col_start    := 1;
              fld_entry        := '';
              fld_len          := 80;
              fld_color        := NormColor;
              fld_editable     := false;
              end;
           end;
        if scrn_misc_data.scrn_fld_def[7].fld_entry > '' then
           scrn_misc_data.scrn_fld_def[7].fld_color := BriteColor
        else
           scrn_misc_data.scrn_fld_def[7].fld_color := NormColor;
        LANGENTR(scrn_misc_data);
        Scrn_misc_data.Scrn_fld_def[7].fld_entry := '';
        if scrn_misc_data.scrn_hot_keyhit = 'aster' then
           QuitScrn := true
        else
           begin
           with scrn_misc_data do
              begin
              with scrn_fld_def[4] do
                 fld_entry := TRIM_FRONT(TRIM_TRAIL(fld_entry));
              with scrn_fld_def[5] do
                 fld_entry := TRIM_FRONT(TRIM_TRAIL(fld_entry));

              if (scrn_fld_def[4].fld_entry > '') and
                 (scrn_fld_def[5].fld_entry > '') then
                 scrn_fld_def[7].fld_entry := 'Enter only ' +
                                               TRIM_TRAIL(langname) +
                                              ' OR English, '
                                            + 'not both'
              else
              if (scrn_fld_def[4].fld_entry > '') then
                 begin
                 LookupOrder := 'L';
                 StartWord  := scrn_fld_def[4].fld_entry;
                 DISPLAY_WORDS(DisplayRequest, LookupOrder, StartWord);
                 end
              else
              if (scrn_fld_def[5].fld_entry > '') then
                 begin
                 LookupOrder := 'E';
                 StartWord  := scrn_fld_def[5].fld_entry;
                 DISPLAY_WORDS(DisplayRequest, LookupOrder, StartWord);
                 end
              else
                 scrn_fld_def[7].fld_entry := 'Enter ' +
                                               TRIM_TRAIL(langname) +
                                               ' or English '
                                            + 'word, or * to end';
              end;
           end;
     until(QuitScrn);
end;
{************************************************************************}
procedure REGROUP_MENU(RegroupType : integer);
     var
        WkErr       :  string[80];
        WkNumChar   :  string[3];
        WkWdperLess :  integer;
        WkOrder     :  char;
        WkQuit      :  boolean;
     procedure VALIDATE_REGROUP;
     begin
        WkNumChar := scrn_misc_data.scrn_fld_def[4].fld_entry;
        WkNumChar := TRIM_FRONT(TRIM_TRAIL(WkNumChar));
        val(WkNumChar,WkWdperLess,dummy);
        if (dummy > 0) or
           (WkWdperLess < 1) or (WkWdperLess > 250) then
           WkErr := 'Invalid number words per lesson.  Please enter 1 - 250.'
        else
           if (RegroupType = 1) or (RegroupType = 2) then
              begin
              WkOrder := upcase(char(scrn_misc_data.scrn_fld_def[7].fld_entry[1]));
              if (WkOrder <> 'R') and (WkOrder <> 'P') then
                 WkErr := 'Please enter "R" or "P" for ordering type.'
              end;
     end;

begin
     FMT_REGROUP(RegroupType);
     WkQuit := false;
     WkErr := '';
     repeat
        {get reorder options & validate}
        repeat
           scrn_misc_data.curs_pos_fld  := 0;
           scrn_misc_data.scrn_fld_def[9].fld_entry := '';
           scrn_misc_data.scrn_fld_def[9].fld_color := NormColor;
           scrn_misc_data.scrn_fld_def[10].fld_entry := '';
           scrn_misc_data.scrn_fld_def[10].fld_color := NormColor;
           scrn_misc_data.scrn_fld_def[10].fld_editable := false;
           LANGENTR(scrn_misc_data);
           if scrn_misc_data.scrn_hot_keyhit = 'aster' then
              WkQuit := true
           else
              begin
              WkErr := '';
              VALIDATE_REGROUP;
              scrn_misc_data.scrn_fld_def[12].fld_entry := WkErr;
              if WkErr = '' then
                 scrn_misc_data.scrn_fld_def[12].fld_color := NormColor
              else
                 scrn_misc_data.scrn_fld_def[12].fld_color := BriteColor;
              end;
        until (WkErr = '') or (WkQuit);

        {confirm reorder options & validate confirmation}
        if not WkQuit then
           repeat
              WkErr := '';
              scrn_misc_data.scrn_fld_def[9].fld_entry :=
                        'Confirm update of file with regrouping (Y/N)';
              scrn_misc_data.scrn_fld_def[9].fld_color := BriteColor;
              scrn_misc_data.scrn_fld_def[10].fld_color := EntryColor;
              scrn_misc_data.scrn_fld_def[10].fld_editable := true;
              scrn_misc_data.curs_pos_fld  := 10;
              LANGENTR(scrn_misc_data);
              if scrn_misc_data.scrn_hot_keyhit = 'aster' then
                 WkQuit := true
              else
                 begin
                 if upcases(scrn_misc_data.scrn_fld_def[10].fld_entry) = 'N' then
                    begin
                    WkErr := '';
                    scrn_misc_data.scrn_fld_def[9].fld_entry := '';
                    scrn_misc_data.scrn_fld_def[9].fld_color := NormColor;
                    scrn_misc_data.scrn_fld_def[10].fld_color := NormColor;
                    scrn_misc_data.scrn_fld_def[10].fld_editable := false;
                    end
                 else
                 if upcases(scrn_misc_data.scrn_fld_def[10].fld_entry) = 'Y' then

                    case RegroupType of
                        1  :  {restart with all in NW pile}
                          begin
                          WkLine := blankline;
                          insert(FMT_DT_TIME,WkLine,1);
                          insert('Restarting from session 1',WkLine,20);
                          insert('   by '
                                 + NUMSTRING(WkWdperLess)
                                 + 's',
                                 WkLine,60);
                          writehist(WkLine);
                          WkLine := blankline;
                          if WkOrder = 'R' then
                             insert('   in random order.',Wkline,60)
                          else
                             insert('   in pre-set order.',Wkline,60);
                          writehist(WkLine);
                          if WkOrder = 'R' then
                             {Restart - random}
                             RESETF(HdrRec.SessType,5,WkWdperLess,'R')
                          else
                             {Restart - preset}
                             RESETF(HdrRec.SessType,5,WkWdperLess,'L');
                          end;
                        2  :  {regroup new words}
                          begin
                          WkLine := blankline;
                          insert(FMT_DT_TIME,WkLine,1);
                          insert('Regrouping New Words',WkLine,20);
                          insert('   by '
                                 + NUMSTRING(WkWdperLess)
                                 + 's',
                                 WkLine,60);
                          writehist(WkLine);
                          WkLine := blankline;
                          if WkOrder = 'R' then
                             insert('   in random order.',Wkline,60)
                          else
                             insert('   in pre-set order.',Wkline,60);
                          writehist(WkLine);
                          if WkOrder = 'R' then
                             REGROUP(13,0,'R',WkWdperLess)
                          else
                             REGROUP(13,0,'L',WkWdperLess);
                          end;
                        3  :  {regroup under control words}
                          begin
                          WkLine := blankline;
                          insert(FMT_DT_TIME,WkLine,1);
                          insert('Regrouping Under Control',WkLine,20);
                          insert('   by '
                                 + NUMSTRING(WkWdperLess)
                                 + 's',
                                 WkLine,60);
                          writehist(WkLine);
                          WkLine := blankline;
                          if WkOrder = 'R' then
                             insert('   in random order.',Wkline,60)
                          else
                             insert('   in pre-set order.',Wkline,60);
                          writehist(WkLine);
                          REGROUP(1,0,'R',WkWdperLess);
                          end;
                    end
                 else
                    WkErr := 'Please enter "Y" (regroup) or "N" (do not regroup)';

                 scrn_misc_data.scrn_fld_def[12].fld_entry := WkErr;
                 if WkErr = '' then
                    scrn_misc_data.scrn_fld_def[12].fld_color := NormColor
                 else
                    scrn_misc_data.scrn_fld_def[12].fld_color := BriteColor;
                 end;

           until (WkErr = '') or (WkQuit);
     until (WkErr = '') or (WkQuit);

end;
{************************************************************************}
