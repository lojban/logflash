procedure LF1BLD;
var
     create   :  string[1];
     numin3   :  string[3];
     nnw      :  integer;

procedure BUILDWD;        {build word data on random file for lessons}

begin
     with YourRec,Yours[j] do
        begin
        {Control data}
          fp       := 13;     {lesson pile}
          sr       := i;      {word number on file}
          if (HdrRec.SessType = 1) or (HdrRec.SessType = 2) then
             ym := trunc((i - 1) / nnw) + 1  {put in new word pile by lesson}
          else
             ym := random(nnw) + 1;      {put in random new word pile}
          skw      := false;          {skip word flag for nw pile item}
        {Logging data}
          nws      := 0;                    {1st nw sess used in}
          rg1s     := 0;                    {1st recog1 sess used in}
          rg2s     := 0;                    {1st recog2 sess used in}
          rg3s     := 0;                    {1st recog3 sess used in}
          rc1s     := 0;                    {1st recall1 sess used in}
          ucs      := 0;                    {1st under control sess used in}
          dcnt     := 0;                    {# sessions in dropback pile}
          rggd     := 0;                    {tot recogs correct}
          rgerr    := 0;                    {tot recogs errors}
          rcgd     := 0;                    {tot recall correct}
          rcerr    := 0;                    {tot recall errors}
        end;
end;

{************************************************************************}
procedure GET_NAME(var errmsgin: string);
  var
      DummySearchRec : SearchRec;

begin
    checkaccent := false;               {don't use ":" as umlaut, etc}
    with scrn_misc_data do
       begin
       extra_char    := true;
       scrn_num_flds := 7;
       scrn_order[1] := 0;
       if errmsgin = '' then
          scrn_clrscrn  := true
       else
          scrn_clrscrn  := false;
       {Cursor position set if no error; error cursor pos set in error section}
       if errmsgin = '' then
          curs_pos_fld := 0;

       {------hdr---------------------------------------------------------}
       with scrn_fld_def[1] do
         begin
         fld_entry := 'BUILD INDIVIDUAL LESSON FILE';
         fld_len   := 28;
         fld_row   := 1;
         fld_col_start := 32;
         fld_editable := false;
         fld_color := DefaultColor;
         end;

       {------name--------------------------------------------------------}
       with scrn_fld_def[2] do
         begin
         fld_entry := 'Lesson data for ' + f1 + ' does not exist.  ' +
                      'Create it? (Y/N):';
         fld_len   := 57;
         fld_row   := 3;
         fld_col_start := 1;
         fld_editable := false;
         fld_color := DefaultColor;
         end;
       with scrn_fld_def[3] do
          begin
          fld_entry := 'Y';
          fld_len   := 1;
          fld_row   := 3;
          fld_col_start := 60;
          fld_editable := true;
          fld_color := DefaultEntryColor;
          end;

       {------number words------------------------------------------------}
       with scrn_fld_def[4] do
         begin
         fld_entry := 'Enter average number of New Words per lesson (maximum of 250): ';
         fld_len   := 63;
         fld_row   := 5;
         fld_col_start := 1;
         fld_editable := false;
         fld_color := DefaultColor;
         end;
       with scrn_fld_def[5] do
          begin
          fld_entry := numin3;
          fld_len   := 3;
          fld_row   := 5;
          fld_col_start := 64;
          fld_editable := true;
          fld_color := DefaultEntryColor;
          end;

       {------error message-----------------------------------------------}
       with scrn_fld_def[6] do
         begin
         fld_entry := errmsgin;
         fld_len   := 80;
         fld_row   := 10;
         fld_col_start := 1;
         fld_editable := false;
         fld_color := DefaultColor;
         end;

       {------general instructions----------------------------------------}
       with scrn_fld_def[7] do
         begin
         fld_entry := 'TABs, ARROWs to move; "*" to cancel; hit ENTER when done.';
         fld_len   := 80;
         fld_row   := 15;
         fld_col_start := 1;
         fld_editable := false;
         fld_color := DefaultColor;
         end;
       scrn_hotkey_cnt := 1;
       scrn_hot_keys[1] := 'aster';
       scrn_hot_keyhit  := '';
       end; {with scrn_misc_data}

       errmsgin := '';
       LANGENTR(scrn_misc_data);

    if scrn_misc_data.scrn_hot_keyhit = 'aster' then
       quit := true
    else
       begin
       numin3 := TRIM_TRAIL(scrn_misc_data.scrn_fld_def[5].fld_entry);
       create := (scrn_misc_data.scrn_fld_def[3].fld_entry);
       end;
    if not quit then
       begin
       if (upcases(create) = 'Y') and
          (errmsgin = '') then
          with scrn_misc_data do
          begin
             val(numin3,nnw,dummy);
             if (dummy <> 0 ) then
                begin
                curs_pos_fld := 7;
                errmsgin := 'Enter numeric value less than 250 for number New Words';
                end
             else
             if (nnw < 1) then
                begin
                curs_pos_fld := 7;
                errmsgin := 'Enter positive value less than 250 for number New Words';
                end
             else
             if (nnw > 250) then
                begin
                curs_pos_fld := 7;
                errmsgin := 'Enter numeric value less than 250 for number New Words';
                end;
          end;
       end;
end;
{************************************************************************}
procedure BUILDHDR;  {set individual control record data}

begin
     {$I-} assign(HdrFile,f); {$I+} fileio;     {open new file by this name}
     {$I-} rewrite(HdrFile); {$I+} fileio;      {overwrite any previous of this name}
     fillchar(HdrRec,512,0);
     with HdrRec do                     {set up for initial seesion}
          begin
          {---Control information---}
          SessNo     := 1;                  {last session #, initially 0}
          SessType   := 1;   {NW Review}    {last session type, initially 1}
          LastLess   := 12;                 {last lesson #, initially 12}
          More4Less  := 0;   {indicates a pile which was incomplete due to
                             array overflow, the lessons should start there,
                             initially 0}
          NWBlkLeft  := trunc((ie-1)/nnw) + 1; {# nw blocks left}
          FileRcdCnt := trunc((ie-1)/subperyourrec) + 2;  {# rcds in file + cntl}
          wdcnt[13]  := ie;                          {#wds in piles}
          filelang   := wordrec.filelang;   {language from comment on raw file}
          comments   := wordrec.comments;   {copy any comment in raw file}
          filenumwds := ie;                 {number of words on random file}
          morecount  := 0;                  {# times More4Less used this lesson}
          TypoOnRg   := false;             {Allow retry for typo on recog}
          TypoOnRc   := false;             {Allow retry for typo on recall}
          NWskipOn   := false;              {Flag to Skip NW lesson}
          DropbackOn := true;    {Flag to put errs in Dropback (vs 1 lesson back)}
          HistoryOn  := true;               {Flag to keep History file}
          ErrRptCnt  := 6;                  {# times to repeat for errs}
          UCrandoms  := 8;                  {# Under Control random wds}
          MaxLess    := 0;                  {Max wds per lesson (other than NW)}
          NWperLess  := nnw;                {Number NWs per NW lesson - average}
          NormColorH := DefaultColor;       {for norm displays}
          BriteColorH := DefaultBriteColor; {for bright displays}
          EntryColorH := DefaultEntryColor; {for entry fields}
          {---Logging information---}
          TrueSess   := 1;                  {True sess #}
          ResetCnt   := 0;                  {# times file reset}
          Csess      := 0;                  {Session first Gain Ctl}
          Msess      := 0;                  {Session first Maintenance}
          Addsess    := 0;                  {Session first add wds}
          reMsess    := 0;                  {Session reMaintenance after add wds}
          MaxErrRptUsed := 0;               {Max of error rpt # used}
          MaxNWused    := 0;                {Max of # nw per lesson used}
          MaxLessUsed  := 0;                {Max of # wd per other lesson used}
          RgTypoUsed   := false;            {Typo fixing ever used in Recog}
          RcTypoUsed   := false;            {Typo fixing ever used in Recall}
          DropbackStop := false;            {Dropback shortening ever used}
          NWskipCnt    := 0;                {# sessions NW pile skipping used}
          end;
     {$I-} write(HdrFile,HdrRec); {$I+} fileio;  {write control record}
     {$I-} close(HdrFile); {$I+} fileio;
end;

{************************************************************************}
procedure BUILDFIL;       {control building of word file}

begin
     {$I-} assign(wordfile,wordfname); {$I+} fileio;     {open raw text file}
     {$I-} reset(wordfile); {$I+} fileio;
     {$I-} read(wordfile,wordrec); {$I+} fileio;       {read control record}

     ie := wordrec.numwds;
     BUILDHDR;

     {$I-} close(wordfile); {$I+} fileio;

     {$I-} assign(YourFile,f); {$I+} fileio;  {open file for word data access}
     {$I-} reset(YourFile); {$I+} fileio;
     {$I-} seek(YourFile,1); {$I+} fileio;  {skip the control record just made}
     j := 0;                        {counts 1 to subperyourrec to pack YourFile}
     fillchar(YourRec,512,0);
     for i := 1 to ie do                 {step through word file}
         begin
         if (j = subperyourrec) then                 {record full}
            begin
            j := 0;                      {reset pointer}
            {$I-} write(YourFile,YourRec); {$I+} fileio; {write rcd to YourFile}
            fillchar(YourRec,512,0);
            end;
         j := j + 1;                     {increment pointer in record}
         BUILDWD;
         end;                            {1 word from raw file}

     {$I-} write(YourFile,YourRec); {$I+} fileio; {write last rcd to YourFile}
     {$I-} close(YourFile); {$I+} fileio;
end;

{************************************************************************}
begin

     nnw := 20;
     errmsg := '';
     numin3 := '20';
     for i := 1 to 11 do
        with scrn_misc_data.scrn_fld_def[i] do
           fld_entry := '';
     quit := false;
     repeat
       GET_NAME(errmsg);
     until (errmsg = '') or quit;
     if (upcases(create) = 'Y') and not quit then
        begin
        BUILDFIL;
        end
     else
        f := '';
end;
