{***********************************************************************}
{  COPYRIGHT 1986 - 1991            by Nora and Bob LeChevalier         }
{***********************************************************************}
{************************************************************************}

procedure MIX;                           {6300-6499, randomize deck order}
 var
   helpr : arrptr;                 {replaces he,hl,hm,hr for temp store}
   i     : integer;
   x     : integer;

begin
     clrscr;
     if nw > 0 then
        begin
        for i := nw downto 1 do              {for each word}
            begin
            x := random(nw) + 1;         {get a random other word}
            helpr := arr[i];             {and switch the two}
            arr[i] := arr[x];
            arr[x] := helpr;
            end;
        end;
end;

{************************************************************************}
procedure REVIEW;                        {6500-6699, review deck}
   var WdsPerScreen :  integer;
begin
       WdsPerScreen := 1;
       scrn_misc_data.scrn_hot_keyhit  := '';
       SHOWPAGE(1,      1,     nw,    250,       WdsPerScreen,
               {Pg#, #pgs, wdsthispg,wds/"page", wds/scrn}
                'P',          '',
               {selectorder, dsplyreq=''/lookup/edit}
                1,
               {startsub}
               '                 REVIEW', nw);
               {                title,    tot #wds}
end;
{************************************************************************}
procedure RECOGPRAC; {8500-9499, proc's to practice recognize errors}

  var
     WkErrRptCnt :  string[1];
     Wk1   :  string[1];
     Wk3   :  string[3];
     TrimPrompt : string[80];
     TrimAnswer : string[80];
     WkLang     : string[15];
     xx         : integer;

begin
     if nw > 0 then
{1}     begin
        n:= 0;                           {initialize mixed array item to use}
        WkLang := 'English';
        FMTDRILL(WkLang);                {Set len, etc for fields}
        scrn_misc_data.scrn_fld_def[8].fld_row   := 5;

        for j := 1 to nw do
           arr[j]^.pii := 0;

        str(HdrRec.ErrRptCnt, WkErrRptCnt);
        xx := 0;
        for j := 1 to nw do
            if arr[j]^.pii < HdrRec.ErrRptCnt then
               xx := xx + 1;   {count practice wds}

        repeat
           if n < nw then
              n := n + 1
           else
              n := 1;
           if ((n = 1) and (xx > 0)) then MIX;  {randomize error words}
           with arr[n]^ do
  {2}         begin
              if pii < HdrRec.ErrRptCnt then  {each wd = ErrRptCnt x's straight}
   {3}           begin
                 {-----------present word for translation--------------}
                 scrn_misc_data.scrn_clrscrn  := true;
                 scrn_misc_data.curs_pos_fld  := 0;
                 scrn_misc_data.scrn_hotkey_cnt := 0;
                 str(xx, Wk3);
                 scrn_misc_data.scrn_fld_def[1].fld_entry :=
                               'Practice ' + Wk3 + ' ' + s[ThisLess] +
                               ' Recognize Errors ' + WkErrRptCnt + ' times';
                 str(pii, Wk1);
                 scrn_misc_data.scrn_fld_def[2].fld_entry :=
                               Wk1 + ' times correct on this word';
                 scrn_misc_data.scrn_fld_def[3].fld_entry := wd.lg;
                 scrn_misc_data.scrn_fld_def[5].fld_entry := '';
                 scrn_misc_data.scrn_fld_def[5].fld_editable := true;
                 scrn_misc_data.scrn_fld_def[6].fld_entry := '';
                 scrn_misc_data.scrn_fld_def[6].fld_color := NormColor;
                 scrn_misc_data.scrn_fld_def[7].fld_entry := '';
                 scrn_misc_data.scrn_fld_def[8].fld_entry := 'RAFSI: ' + wd.lgs;
                 scrn_misc_data.scrn_fld_def[9].fld_entry := '';
                 scrn_misc_data.scrn_fld_def[10].fld_entry := '';
                 scrn_misc_data.scrn_fld_def[11].fld_entry := '';
                 scrn_misc_data.scrn_fld_def[12].fld_entry :=
                    'Move with ARROWs, HOME, END; may INSert and DELete';
                 scrn_misc_data.scrn_fld_def[13].fld_editable := false;

                 {-----------get answer--------------------------------}
                 LANGENTR(scrn_misc_data);
                 TrimPrompt := upcases(TRIM_TRAIL(wd.en));
                 with scrn_misc_data.scrn_fld_def[5] do
                    TrimAnswer := upcases(TRIM_FRONT(TRIM_TRAIL(fld_entry)));

                 scrn_misc_data.scrn_clrscrn  := false;

                 {-----------get second try----------------------------}
                 if (TrimPrompt <> TrimAnswer) and
                     HdrRec.TypoOnRg then
                       begin
                       with scrn_misc_data.scrn_fld_def[6] do
                          fld_entry := 'No. One more try.';
                       scrn_misc_data.scrn_fld_def[6].fld_color := BriteColor;
                       LANGENTR(scrn_misc_data);
                       with scrn_misc_data.scrn_fld_def[5] do
                          TrimAnswer := upcases(TRIM_FRONT(TRIM_TRAIL(fld_entry)));
                       end;

                 {-----------check answer------------------------------}
                 scrn_misc_data.scrn_fld_def[6].fld_color := BriteColor;
                 if (TrimPrompt = TrimAnswer) then
                    begin
                    pii := pii + 1;
                    if pii >= HdrRec.ErrRptCnt then
                       xx := xx - 1;
                    with scrn_misc_data.scrn_fld_def[6] do
                       fld_entry := '*** CORRECT ***';
                    with scrn_misc_data.scrn_fld_def[9] do
                       begin
                       fld_entry := 'CLUE WORD: ' + wd.ec;
                       fld_row   := 13;
                       end;
                    with scrn_misc_data.scrn_fld_def[10] do
                       begin
                       fld_entry := 'DEF: ' + wd.es1;
                       fld_row   := 14;
                       end;
                    with scrn_misc_data.scrn_fld_def[11] do
                       begin
                       fld_entry := wd.es2;
                       fld_row   := 15;
                       end;
                    end
                 else
                    begin
                    pii := 0;
                    with scrn_misc_data.scrn_fld_def[6] do
                       fld_entry := 'No. The correct answer is:';
                    with scrn_misc_data.scrn_fld_def[7] do
                       fld_entry := wd.en;
                    with scrn_misc_data.scrn_fld_def[9] do
                       begin
                       fld_entry := 'CLUE WORD: ' + wd.ec;
                       fld_row   := 18;
                       end;
                    with scrn_misc_data.scrn_fld_def[10] do
                       begin
                       fld_entry := 'DEF: ' + wd.es1;
                       fld_row   := 19;
                       end;
                    with scrn_misc_data.scrn_fld_def[11] do
                       begin
                       fld_entry := wd.es2;
                       fld_row   := 20;
                       end;
                    end;

                 {-----------show answer-------------------------------}
                 with scrn_misc_data.scrn_fld_def[5] do
                    fld_editable := false;
                 scrn_misc_data.scrn_clrscrn  := false;
                 scrn_misc_data.curs_pos_fld  := 12;
                 scrn_misc_data.scrn_hotkey_cnt := 2;
                 scrn_misc_data.scrn_hot_keys[1] := 'aster';
                 scrn_misc_data.scrn_hot_keys[2] := 'any';
                 str(xx, Wk3);
                 scrn_misc_data.scrn_fld_def[1].fld_entry :=
                               'Practice ' + Wk3 + ' ' + s[ThisLess] +
                               ' Recognize Errors ' + WkErrRptCnt + ' times';
                 {reset Wk1 to new value of pii = new # times correct}
                 str(pii, Wk1);
                 scrn_misc_data.scrn_fld_def[2].fld_entry :=
                               Wk1 + ' times correct on this word';
                 with scrn_misc_data.scrn_fld_def[12] do
                    fld_entry := ' Hit any key to continue, * to end';
                 scrn_misc_data.scrn_fld_def[13].fld_editable := true;
                 LANGENTR(scrn_misc_data);

   {3}           end;      {end of processing for 1 word's practice}
  {2}         end;                       {end of arr[n] with..do}
        until (xx = 0) or (scrn_misc_data.scrn_hot_keyhit = 'aster');
        if scrn_misc_data.scrn_hot_keyhit <> 'aster' then
           begin
           {------Log error practice done to history----------------------}
           WkLine := blankline;
           insert(FMT_DT_TIME,WkLine,1);
           insert(RightJust(HdrRec.SessNo),WkLine,17);
           insert(s[ThisLess],WkLine,25);
           insert('Error Practice done',WkLine,60);
           writehist(WkLine);
           end;
{1}     end;                             {end of practice deck processing}
end;

{************************************************************************}
procedure RECALLPRAC; {8500-9499, proc's to practice recall errors}

  var
     WkErrRptCnt :  string[1];
     Wk1   :  string[1];
     Wk3   :  string[3];
     TrimPrompt : string[80];
     TrimAnswer : string[80];
     xx         : integer;

begin
     if nw > 0 then
{1}     begin
        n:= 0;                           {initialize mixed array item to use}
        FMTDRILL(langname);              {Set len, etc for fields}
        scrn_misc_data.scrn_fld_def[9].fld_row   := 5;
        scrn_misc_data.scrn_fld_def[10].fld_row  := 6;
        scrn_misc_data.scrn_fld_def[11].fld_row  := 7;

        for j := 1 to nw do
           arr[j]^.pii := 0;

        str(HdrRec.ErrRptCnt, WkErrRptCnt);
        xx := 0;
        for j := 1 to nw do
            if arr[j]^.pii < HdrRec.ErrRptCnt then
               xx := xx + 1;   {count practice wds}

        repeat
           if n < nw then
              n := n + 1
           else
              n := 1;
           if ((n = 1) and (xx > 0)) then MIX;  {randomize error words}
           with arr[n]^ do
  {2}         begin
              if pii < HdrRec.ErrRptCnt then  {each wd = ErrRptCnt x's straight}
   {3}           begin
                 {-----------present word for translation--------------}
                 scrn_misc_data.scrn_clrscrn  := true;
                 scrn_misc_data.curs_pos_fld  := 0;
                 scrn_misc_data.scrn_hotkey_cnt := 0;
                 str(xx, Wk3);
                 scrn_misc_data.scrn_fld_def[1].fld_entry :=
                               'Practice ' + Wk3 + ' ' + s[ThisLess] +
                               ' Recall Errors ' + WkErrRptCnt + ' times';
                 str(pii, Wk1);
                 scrn_misc_data.scrn_fld_def[2].fld_entry :=
                               Wk1 + ' times correct on this word';
                 scrn_misc_data.scrn_fld_def[3].fld_entry := wd.en;
                 scrn_misc_data.scrn_fld_def[5].fld_entry := '';
                 scrn_misc_data.scrn_fld_def[5].fld_editable := true;
                 scrn_misc_data.scrn_fld_def[6].fld_entry := '';
                 scrn_misc_data.scrn_fld_def[6].fld_color := NormColor;
                 scrn_misc_data.scrn_fld_def[7].fld_entry := '';
                 scrn_misc_data.scrn_fld_def[8].fld_entry := '';
                 scrn_misc_data.scrn_fld_def[9].fld_entry := 'CLUE: ' + wd.ec;
                 scrn_misc_data.scrn_fld_def[10].fld_entry := 'DEF: ' + wd.es1;
                 scrn_misc_data.scrn_fld_def[11].fld_entry := wd.es2;
                 scrn_misc_data.scrn_fld_def[12].fld_entry :=
                    'Move with ARROWs, HOME, END; may INSert and DELete';
                 scrn_misc_data.scrn_fld_def[13].fld_editable := false;

                 {-----------get answer--------------------------------}
                 LANGENTR(scrn_misc_data);
                 TrimPrompt := upcases(TRIM_TRAIL(wd.lg));
                 with scrn_misc_data.scrn_fld_def[5] do
                    TrimAnswer := upcases(TRIM_FRONT(TRIM_TRAIL(fld_entry)));

                 scrn_misc_data.scrn_clrscrn  := false;

                 {-----------get second try----------------------------}
                 if (TrimPrompt <> TrimAnswer) and
                     HdrRec.TypoOnRc then
                       begin
                       with scrn_misc_data.scrn_fld_def[6] do
                          fld_entry := 'No. One more try.';
                       scrn_misc_data.scrn_fld_def[6].fld_color := BriteColor;
                       LANGENTR(scrn_misc_data);
                       with scrn_misc_data.scrn_fld_def[5] do
                          TrimAnswer := upcases(TRIM_FRONT(TRIM_TRAIL(fld_entry)));
                       end;

                 {-----------check answer------------------------------}
                 scrn_misc_data.scrn_fld_def[6].fld_color := BriteColor;
                 if (TrimPrompt = TrimAnswer) then
                    begin
                    pii := pii + 1;
                    if pii >= HdrRec.ErrRptCnt then
                       xx := xx - 1;
                    with scrn_misc_data.scrn_fld_def[6] do
                       fld_entry := '*** CORRECT ***';
                    with scrn_misc_data.scrn_fld_def[8] do
                       begin
                       fld_entry := 'RAFSI: ' + wd.lgs;
                       fld_row   := 13;
                       end;
                    end
                 else
                    begin
                    pii := 0;
                    with scrn_misc_data.scrn_fld_def[6] do
                       fld_entry := 'No. The correct answer is:';
                    with scrn_misc_data.scrn_fld_def[7] do
                       fld_entry := wd.lg;
                    with scrn_misc_data.scrn_fld_def[8] do
                       begin
                       fld_entry := 'RAFSI: ' + wd.lgs;
                       fld_row   := 18;
                       end;
                    end;

                 {-----------show answer-------------------------------}
                 with scrn_misc_data.scrn_fld_def[5] do
                    fld_editable := false;
                 scrn_misc_data.scrn_clrscrn  := false;
                 scrn_misc_data.curs_pos_fld  := 12;
                 scrn_misc_data.scrn_hotkey_cnt := 2;
                 scrn_misc_data.scrn_hot_keys[1] := 'aster';
                 scrn_misc_data.scrn_hot_keys[2] := 'any';
                 str(xx, Wk3);
                 scrn_misc_data.scrn_fld_def[1].fld_entry :=
                               'Practice ' + Wk3 + ' ' + s[ThisLess] +
                               ' Recall Errors ' + WkErrRptCnt + ' times';
                 str(pii, Wk1);
                 scrn_misc_data.scrn_fld_def[2].fld_entry :=
                               Wk1 + ' times correct on this word';
                 with scrn_misc_data.scrn_fld_def[12] do
                    fld_entry := ' Hit any key to continue, * to end';
                 scrn_misc_data.scrn_fld_def[13].fld_editable := true;
                 LANGENTR(scrn_misc_data);

   {3}           end;      {end of processing for 1 word's practice}
  {2}         end;                       {end of arr[n] with..do}
        until (xx = 0) or (scrn_misc_data.scrn_hot_keyhit = 'aster');
        if scrn_misc_data.scrn_hot_keyhit <> 'aster' then
           begin
           {------Log error practice done to history----------------------}
           WkLine := blankline;
           insert(FMT_DT_TIME,WkLine,1);
           insert(RightJust(HdrRec.SessNo),WkLine,17);
           insert(s[ThisLess],WkLine,25);
           insert('Error Practice done',WkLine,60);
           writehist(WkLine);
           end;
{1}     end;                             {end of practice deck processing}
end;

{************************************************************************}
procedure TESTRECOG;                     {7000-7999, test recognition}

  var
     WkGood     :  string[3];
     WkLeft     :  string[3];
     WkPct      :  string[3];
     WkTot      :  string[3];
     TrimPrompt : string[80];
     TrimAnswer : string[80];
     WkLang     : string[15];

begin
     WkLang := 'English';
     FMTDRILL(WkLang);             {Set len, etc for fields}
     scrn_misc_data.scrn_fld_def[8].fld_row   := 5;

     for j := 1 to nw do
        arr[j]^.pii := 0;

     MIX;
     i := 0;
     sc := 0;
     gs := 0;
     gt := 0;

     repeat
        i := i + 1;
        with arr[i]^ do
           begin

           {-----------present word for translation--------------}
           scrn_misc_data.scrn_clrscrn  := true;
           scrn_misc_data.curs_pos_fld  := 0;
           scrn_misc_data.scrn_hotkey_cnt := 0;

           str(sc, WkPct);
           str(gs, WkGood);
           str(gt, WkTot);
           str((nw-i+1), WkLeft);
           with scrn_misc_data.scrn_fld_def[1] do
              fld_entry := WkPct + '% correct on ' + s[ThisLess] + ' recognition';
           with scrn_misc_data.scrn_fld_def[2] do
              fld_entry := WkGood + ' correct out of ' +
                           WkTot + ' with ' + WkLeft + ' left';

           scrn_misc_data.scrn_fld_def[3].fld_entry := wd.lg;
           scrn_misc_data.scrn_fld_def[5].fld_entry := '';
           scrn_misc_data.scrn_fld_def[5].fld_editable := true;
           scrn_misc_data.scrn_fld_def[6].fld_entry := '';
           scrn_misc_data.scrn_fld_def[6].fld_color := NormColor;
           scrn_misc_data.scrn_fld_def[7].fld_entry := '';
           scrn_misc_data.scrn_fld_def[8].fld_entry := 'RAFSI: ' + wd.lgs;
           scrn_misc_data.scrn_fld_def[9].fld_entry := '';
           scrn_misc_data.scrn_fld_def[10].fld_entry := '';
           scrn_misc_data.scrn_fld_def[11].fld_entry := '';
           scrn_misc_data.scrn_fld_def[12].fld_entry :=
              'Move with ARROWs, HOME, END; may INSert and DELete';
                 scrn_misc_data.scrn_fld_def[13].fld_editable := false;


           {-----------get answer--------------------------------}
           LANGENTR(scrn_misc_data);
           TrimPrompt := upcases(TRIM_TRAIL(wd.en));
           with scrn_misc_data.scrn_fld_def[5] do
              TrimAnswer := upcases(TRIM_FRONT(TRIM_TRAIL(fld_entry)));

           scrn_misc_data.scrn_clrscrn  := false;

           {-----------get second try----------------------------}
           if (TrimPrompt <> TrimAnswer) and
               HdrRec.TypoOnRg then
                 begin
                 with scrn_misc_data.scrn_fld_def[6] do
                    fld_entry := 'No. One more try.';
                 scrn_misc_data.scrn_fld_def[6].fld_color := BriteColor;
                 LANGENTR(scrn_misc_data);
                 with scrn_misc_data.scrn_fld_def[5] do
                    TrimAnswer := upcases(TRIM_FRONT(TRIM_TRAIL(fld_entry)));
                 end;

           {-----------check answer------------------------------}
           scrn_misc_data.scrn_fld_def[6].fld_color := BriteColor;
           if (TrimPrompt = TrimAnswer) then
              begin
              gt := gt + 1;
              gs := gs + 1;
              pii := np;
              with scrn_misc_data.scrn_fld_def[6] do
                 fld_entry := '*** CORRECT ***';
              with scrn_misc_data.scrn_fld_def[9] do
                 begin
                 fld_entry := 'CLUE WORD: ' + wd.ec;
                 fld_row   := 13;
                 end;
              with scrn_misc_data.scrn_fld_def[10] do
                 begin
                 fld_entry := 'DEF: ' + wd.es1;
                 fld_row   := 14;
                 end;
              with scrn_misc_data.scrn_fld_def[11] do
                 begin
                 fld_entry := wd.es2;
                 fld_row   := 15;
                 end;
              end
           else
              begin
              gt := gt + 1;
              pii := ep;
              with scrn_misc_data.scrn_fld_def[6] do
                 fld_entry := 'No. The correct answer is:';
              with scrn_misc_data.scrn_fld_def[7] do
                 fld_entry := wd.en;
              with scrn_misc_data.scrn_fld_def[9] do
                 begin
                 fld_entry := 'CLUE WORD: ' + wd.ec;
                 fld_row   := 18;
                 end;
              with scrn_misc_data.scrn_fld_def[10] do
                 begin
                 fld_entry := 'DEF: ' + wd.es1;
                 fld_row   := 19;
                 end;
              with scrn_misc_data.scrn_fld_def[11] do
                 begin
                 fld_entry := wd.es2;
                 fld_row   := 20;
                 end;
              end;

           sc := round(gs * 100 / gt);  {calculate score}
           {-----------show answer-------------------------------}
           with scrn_misc_data.scrn_fld_def[5] do
              fld_editable := false;
           scrn_misc_data.scrn_clrscrn  := false;
           scrn_misc_data.curs_pos_fld  := 12;
           scrn_misc_data.scrn_hotkey_cnt := 2;
           scrn_misc_data.scrn_hot_keys[1] := 'aster';
           scrn_misc_data.scrn_hot_keys[2] := 'any';
           str(sc, WkPct);
           str(gs, WkGood);
           str(gt, WkTot);
           str((nw-i+1), WkLeft);
           with scrn_misc_data.scrn_fld_def[1] do
              fld_entry := WkPct + '% correct on ' + s[ThisLess] + ' recognition';
           with scrn_misc_data.scrn_fld_def[2] do
              fld_entry := WkGood + ' correct out of ' +
                           WkTot + ' with ' + WkLeft + ' left';
           sc := round(gs * 100 / gt);  {calculate score}

           with scrn_misc_data.scrn_fld_def[12] do
              fld_entry := ' Hit any key to continue, * to end';
                 scrn_misc_data.scrn_fld_def[13].fld_editable := true;
           LANGENTR(scrn_misc_data);

           end;                       {end of arr[n] with..do}
     until(i = nw) or (scrn_misc_data.scrn_hot_keyhit = 'aster');

     {----Final Score---------------------------------------------------}
     if scrn_misc_data.scrn_hot_keyhit <> 'aster' then
        begin
        sc := round(gs * 100 / gt);  {calculate score}
        str(sc, WkPct);
        str(gs, WkGood);
        str(gt, WkTot);
        with scrn_misc_data do
           begin
           extra_char    := true;
           scrn_num_flds := 04;
           scrn_order[1] := 0;
           scrn_clrscrn  := true;
           curs_pos_fld  := 3;

           with scrn_fld_def[1] do
             begin
             fld_entry := 'Your score was ' + WkPct + '% correct on ' +
                          s[ThisLess] + ' recognition';
             fld_len   := 55;
             fld_row   := 1;
             fld_col_start := 16;
             fld_editable := false;
             fld_color := NormColor;
             end;

           with scrn_fld_def[2] do
             begin
             fld_entry := WkGood + ' correct out of ' + WkTot;
             fld_len   := 55;
             fld_row   := 2;
             fld_col_start := 16;
             fld_editable := false;
             fld_color := NormColor;
             end;

           with scrn_fld_def[3] do
             begin
             fld_entry := ' Hit any key to continue';
             fld_len   := 23;
             fld_row   := 15;
             fld_col_start := 5;
             fld_editable := false;
             fld_color := NormColor;
             end;

           with scrn_fld_def[4] do
             begin
             fld_entry := '';
             fld_len   := 0;
             fld_row   := 24;
             fld_col_start := 1;
             fld_editable := true;
             fld_color := NormColor;
             end;

           scrn_hotkey_cnt := 1;
           scrn_hot_keys[1] := 'any';
           scrn_hot_keyhit := '';
           end; {with scrn_misc_data}
           LANGENTR(scrn_misc_data);
           {------Log lesson completion to history----------------------}
           WkLine := blankline;
           insert(FMT_DT_TIME,WkLine,1);
           insert(RightJust(HdrRec.SessNo),WkLine,17);
           insert(s[ThisLess],WkLine,25);
           insert(RightJust(gs),WkLine,40);
           insert(RightJust(gt),WkLine,46);
           insert(RightJust(sc),WkLine,52);
           insert('Recognition',WkLine,60);
           writehist(WkLine);

        end;

end;

{************************************************************************}
procedure TESTRECALL;                    {7000-7999, test recognition}

  var
     WkGood     :  string[3];
     WkLeft     :  string[3];
     WkPct      :  string[3];
     WkTot      :  string[3];
     TrimPrompt : string[80];
     TrimAnswer : string[80];

begin
     FMTDRILL(langname);             {Set len, etc for fields}
     scrn_misc_data.scrn_fld_def[9].fld_row   := 5;
     scrn_misc_data.scrn_fld_def[10].fld_row  := 6;
     scrn_misc_data.scrn_fld_def[11].fld_row  := 7;

     for j := 1 to nw do
        arr[j]^.pii := 0;

     MIX;
     i := 0;
     sc := 0;
     gs := 0;
     gt := 0;

     repeat
        i := i + 1;
        with arr[i]^ do
           begin

           {-----------present word for translation--------------}
           scrn_misc_data.scrn_clrscrn  := true;
           scrn_misc_data.curs_pos_fld  := 0;
           scrn_misc_data.scrn_hotkey_cnt := 0;

           str(sc, WkPct);
           str(gs, WkGood);
           str(gt, WkTot);
           str((nw-i+1), WkLeft);
           with scrn_misc_data.scrn_fld_def[1] do
              fld_entry := WkPct + '% correct on ' + s[ThisLess] + ' recall';
           with scrn_misc_data.scrn_fld_def[2] do
              fld_entry := WkGood + ' correct out of ' +
                           WkTot + ' with ' + WkLeft + ' left';

           scrn_misc_data.scrn_fld_def[3].fld_entry := wd.en;
           scrn_misc_data.scrn_fld_def[5].fld_entry := '';
           scrn_misc_data.scrn_fld_def[5].fld_editable := true;
           scrn_misc_data.scrn_fld_def[6].fld_entry := '';
           scrn_misc_data.scrn_fld_def[6].fld_color := NormColor;
           scrn_misc_data.scrn_fld_def[7].fld_entry := '';
           scrn_misc_data.scrn_fld_def[8].fld_entry := '';
           scrn_misc_data.scrn_fld_def[9].fld_entry := 'CLUE: ' + wd.ec;
           scrn_misc_data.scrn_fld_def[10].fld_entry := 'DEF: ' + wd.es1;
           scrn_misc_data.scrn_fld_def[11].fld_entry := wd.es2;
           scrn_misc_data.scrn_fld_def[12].fld_entry :=
              'Move with ARROWs, HOME, END; may INSert and DELete';
                 scrn_misc_data.scrn_fld_def[13].fld_editable := false;

           {-----------get answer--------------------------------}
           LANGENTR(scrn_misc_data);
           TrimPrompt := upcases(TRIM_TRAIL(wd.lg));
           with scrn_misc_data.scrn_fld_def[5] do
              TrimAnswer := upcases(TRIM_FRONT(TRIM_TRAIL(fld_entry)));

           scrn_misc_data.scrn_clrscrn  := false;

           {-----------get second try----------------------------}
           if (TrimPrompt <> TrimAnswer) and
               HdrRec.TypoOnRc then
                 begin
                 with scrn_misc_data.scrn_fld_def[6] do
                    fld_entry := 'No. One more try.';
                 scrn_misc_data.scrn_fld_def[6].fld_color := BriteColor;
                 LANGENTR(scrn_misc_data);
                 with scrn_misc_data.scrn_fld_def[5] do
                    TrimAnswer := upcases(TRIM_FRONT(TRIM_TRAIL(fld_entry)));
                 end;

           {-----------check answer------------------------------}
           scrn_misc_data.scrn_fld_def[6].fld_color := BriteColor;
           if (TrimPrompt = TrimAnswer) then
              begin
              gt := gt + 1;
              gs := gs + 1;
              pii := np;
              with scrn_misc_data.scrn_fld_def[6] do
                 fld_entry := '*** CORRECT ***';
              with scrn_misc_data.scrn_fld_def[8] do
                 begin
                 fld_entry := 'RAFSI: ' + wd.lgs;
                 fld_row   := 13;
                 end;
              end
           else
              begin
              gt := gt + 1;
              pii := ep;
              with scrn_misc_data.scrn_fld_def[6] do
                 fld_entry := 'No. The correct answer is:';
              with scrn_misc_data.scrn_fld_def[7] do
                 fld_entry := wd.lg;
              with scrn_misc_data.scrn_fld_def[8] do
                 begin
                 fld_entry := 'RAFSI: ' + wd.lgs;
                 fld_row   := 18;
                 end;
              end;

           sc := round(gs * 100 / gt);  {calculate score}
           {-----------show answer-------------------------------}
           with scrn_misc_data.scrn_fld_def[5] do
              fld_editable := false;
           scrn_misc_data.scrn_clrscrn  := false;
           scrn_misc_data.curs_pos_fld  := 12;
           scrn_misc_data.scrn_hotkey_cnt := 2;
           scrn_misc_data.scrn_hot_keys[1] := 'aster';
           scrn_misc_data.scrn_hot_keys[2] := 'any';
           str(sc, WkPct);
           str(gs, WkGood);
           str(gt, WkTot);
           str((nw-i+1), WkLeft);
           with scrn_misc_data.scrn_fld_def[1] do
              fld_entry := WkPct + '% correct on ' + s[ThisLess] + ' recall';
           with scrn_misc_data.scrn_fld_def[2] do
              fld_entry := WkGood + ' correct out of ' +
                           WkTot + ' with ' + WkLeft + ' left';
           sc := round(gs * 100 / gt);  {calculate score}

           with scrn_misc_data.scrn_fld_def[12] do
              fld_entry := ' Hit any key to continue, * to end';
                 scrn_misc_data.scrn_fld_def[13].fld_editable := true;
           LANGENTR(scrn_misc_data);

           end;                       {end of arr[n] with..do}
     until(i = nw) or (scrn_misc_data.scrn_hot_keyhit = 'aster');

     {----Final Score---------------------------------------------------}
     if scrn_misc_data.scrn_hot_keyhit <> 'aster' then
        begin
        sc := round(gs * 100 / gt);  {calculate score}
        str(sc, WkPct);
        str(gs, WkGood);
        str(gt, WkTot);
        with scrn_misc_data do
           begin
           extra_char    := true;
           scrn_num_flds := 04;
           scrn_order[1] := 0;
           scrn_clrscrn  := true;
           curs_pos_fld  := 3;

           with scrn_fld_def[1] do
             begin
             fld_entry := 'Your score was ' + WkPct + '% correct on ' +
                          s[ThisLess] + ' recall';
             fld_len   := 55;
             fld_row   := 1;
             fld_col_start := 16;
             fld_editable := false;
             fld_color := NormColor;
             end;

           with scrn_fld_def[2] do
             begin
             fld_entry := WkGood + ' correct out of ' + WkTot;
             fld_len   := 55;
             fld_row   := 1;
             fld_col_start := 16;
             fld_editable := false;
             fld_color := NormColor;
             end;

           with scrn_fld_def[3] do
             begin
             fld_entry := ' Hit any key to continue';
             fld_len   := 23;
             fld_row   := 15;
             fld_col_start := 5;
             fld_editable := false;
             fld_color := NormColor;
             end;

           with scrn_fld_def[4] do
             begin
             fld_entry := '';
             fld_len   := 0;
             fld_row   := 24;
             fld_col_start := 1;
             fld_editable := true;
             fld_color := NormColor;
             end;

           scrn_hotkey_cnt := 1;
           scrn_hot_keys[1] := 'any';
           scrn_hot_keyhit := '';
           end; {with scrn_misc_data}
           LANGENTR(scrn_misc_data);

           {------Log lesson completion to history----------------------}
           WkLine := blankline;
           insert(FMT_DT_TIME,WkLine,1);
           insert(RightJust(HdrRec.SessNo),WkLine,17);
           insert(s[ThisLess],WkLine,25);
           insert(RightJust(gs),WkLine,40);
           insert(RightJust(gt),WkLine,46);
           insert(RightJust(sc),WkLine,52);
           insert('Recall     ',WkLine,60);
           writehist(WkLine);

        end;

end;

{************************************************************************}

procedure SESSION;   {main controlling procedure for lessons and sessions}
begin
     {---Finish previous session, if new session-------------}
     if (ThisLess < HdrRec.LastLess) then {new session}
        begin
        HdrRec.SessNo := HdrRec.SessNo + 1;
        HdrRec.TrueSess := HdrRec.TrueSess + 1;
        if HdrRec.NWSkipOn then
           HdrRec.NWSkipCnt := HdrRec.NWSkipCnt + 1;
        end;

     {---Start this lesson-----------------------------------}
     HdrRec.LastLess := ThisLess;
     case HdrRec.SessType of
              {----NW Review----------------}
        1   : recallflag := false;       {all recog}
              {----Gain Control-------------}
        2   : if ThisLess < 7 then       {recall starts at RECOG3}
                 recallflag := true
              else
                 recallflag := false;
              {----Maintenance--------------}
        3   : if ThisLess < 9 then       {recall starts at RECOG2}
                 recallflag := true
              else
                 recallflag := false;
              {----Brush-up-----------------}
        4   : if ThisLess < 9 then       {recall starts at RECOG2}
                 recallflag := true
              else
                 recallflag := false;
     end;

     if (ThisLess = 13) or        {NW, and UC for Maint, need oldest pile}
        ( (ThisLess = 1) and (HdrRec.SessType = 3) ) then
        oldestset := GETOLDEST(ThisLess)
     else
     if ThisLess = 1 then
        oldestset := HdrRec.SessNo - 3    {non-Maint: use 3-sessions ago wds}
     else
     if odd(ThisLess) then
        oldestset := HdrRec.SessNo - 1    {use words up to last session}
     else
        oldestset := HdrRec.SessNo;       {use words up to this session}

     if odd(ThisLess) then
        begin
        np := NewPile[HdrRec.SessType,ThisLess];  {pile for correct words}
        ep := ThisLess + 1;              {pile for error words}
        end
     else
        ep := ThisLess;                  {err prac wds go back to err pile}
                                         {until end of session}

     if HdrRec.More4Less = 0 then
        begin
        gs := 0;
        sc := 0;
        gt := 0;
        end;
     GETWDS;
     if nw > 0 then
        begin
        if (not odd(ThisLess)) or (ThisLess = 13) then {review for errs, NW}
           REVIEW;
        if odd(ThisLess) then
           {---regular-------}
           if recallflag then
              TESTRECALL
           else
              TESTRECOG
        else
           {---error-prac----}
           if recallflag then
              RECALLPRAC
           else
              RECOGPRAC;
        end;

        if scrn_misc_data.scrn_hot_keyhit <> 'aster' then  { * = quit early }
           begin
           MOVE_WORDS;
           if odd(ThisLess) then
              UPDATE_WDS;
           if HdrRec.More4Less > 0 then
      {       HdrRec.morecount := HdrRec.morecount + 1  }
           else
              HdrRec.morecount := 0;
           UPDATE_HDR;
           end;

end;
{************************************************************************}
