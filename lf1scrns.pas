{************************************************************************}
procedure EXIT_ROUTINE;
begin
    with scrn_misc_data do
       begin
       extra_char    := true;
       scrn_num_flds := 01;
       scrn_order[1] := 0;
       scrn_clrscrn  := true;
       scrn_clr_color := DefaultColor;
       curs_pos_fld  := 1;
       with scrn_fld_def[1] do
         begin
         fld_entry := 'DONE';
         fld_len   := 4;
         fld_row   := 12;
         fld_col_start := 38;
         fld_editable := false;
         fld_color := DefaultColor;
         end;
       end;
    SCREENIO(scrn_misc_data);
    textattr := system_color;
    release(heaporg); {release all heap (arr is on heap)}
    halt;
end;
{************************************************************************}

procedure SHOWKEYS;       {show help screen for keys allowed}

{
              KEY ASSIGNMENTS (unless otherwise specified on current screen)

ARROWs        Move left/right within current item, or up/down one item.
CTRL-ARROWs   Move left/right one word.
TABs          Move to next/previous item.
HOME          Move to beginning of current item.
END           Move to end of text in current item.

INSert        Toggle insert mode; characters will be inserted at cursor.
DELete        Delete one character (at cursor).
BACKSPACE     Move left 1 character, deleting what was there.
CTRL-END      Delete to end of item (from cursor).

ALT-H         Show this screen for key definitions.
ALT-Q         Quick quit.  Immediately back to DOS.

ษอออออออออออออออออออออออออออออออออออออออออออัออออออออออออออออออออออออออออออออป
บ KEY  USED AFTER         CHANGES IT TO     ณ KEY  USED AFTER  CHANGES IT TO บ
บ  /   a,e,i,o,u,E         ,,ก,ข,ฃ,       ณ  @   a,A         ,           บ
บ  \   a,e,i,o,u          …,,,•,—         ณ  %   c,C         ,€           บ
บ  ^   a,e,i,o,u          ,,,“,–         ณ  ~   n,N         ค,ฅ           บ
บ  :   a,e,i,o,u,A,O,U,y  ,,,”,,,,, ณ  _   a,o         ฆ,ง           บ
ศอออออออออออออออออออออออออออออออออออออออออออฯออออออออออออออออออออออออออออออออผ
                      Hit any key to return.
}

const
    temp_order : array[1..48] of integer =
                ( 2, 4, 6, 8,10,12,14,16,18,20,22,
                 27,32,37,42,   29,34,39,44,
                  1,
                  3, 5, 7, 9,11,13,15,17,19,21,23,
                 24,25,
                 26,28,30, 31,33,35, 36,38,40, 41,43,45,
                 46,
                 47, 48);

    temp_line : array[1..48] of integer =
                ( 3, 4, 5, 6, 7, 9,10,11,12,14,15,
                 19,20,21,22,   19,20,21,22,
                  1,
                  3, 4, 5, 6, 7, 9,10,11,12,14,15,
                 17,18,
                 19,19,19, 20,20,20, 21,21,21, 22,22,22,
                 23,
                 24, 24);
    temp_col  : array[1..48] of integer =
                ( 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1,
                  4, 4, 4, 4,   48,48,48,48,
                 15,
                 15,15,15,15,15,15,15,15,15,15,15,
                  1, 1,
                  1, 8,52,  1, 8,52,  1, 8,52,  1, 8,52,
                  1,
                 23, 70);
    temp_len  : array[1..48] of integer =
                (11,11,11,11,11,11,11,11,11,11,11,
                  1, 1, 1, 1,    1, 1, 1, 1,
                 62,
                 58,58,58,58,58,58,58,58,58,58,58,
                 78,78,
                  1,38,27,  1,38,27,  1,38,27,  1,38,27,
                 78,
                 22, 1);
    temp_text : array[1..48] of string[80] =
      ('ARROWs     '                                               ,
       'CTRL-ARROWs'                                               ,
       'TABs       '                                               ,
       'HOME       '                                               ,
       'END        '                                               ,
       'INSert     '                                               ,
       'DELete     '                                               ,
       'BACKSPACE  '                                               ,
       'CTRL-END   '                                               ,
       'ALT-H      '                                               ,
       'ALT-Q      '                                               ,
       '/'                                                         ,
       '\'                                                         ,
       '^'                                                         ,
       ':'                                                         ,
       '@'                                                         ,
       '%'                                                         ,
       '~'                                                         ,
       '_'                                                         ,

       'KEY ASSIGNMENTS (unless otherwise specified on current screen)' ,
       'Move left/right within current item, or up/down one item. ',
       'Move left/right one word.                                 ',
       'Move to next/previous item.                               ',
       'Move to beginning of current item.                        ',
       'Move to end of text in current item.                      ',
       'Toggle insert mode; characters will be inserted at cursor.',
       'Delete one character (at cursor).                         ',
       'Move left 1 character, deleting what was there.           ',
       'Delete to end of item (from cursor).                      ',
       'Show this screen for key definitions.                     ',
       'Quick quit.  Immediately back to DOS.                     ',
'ษอออออออออออออออออออออออออออออออออออออออออออัออออออออออออออออออออออออออออออออป',
'บ KEY  USED AFTER         CHANGES IT TO     ณ KEY  USED AFTER  CHANGES IT TO บ',
'บ',   'a,e,i,o,u,E         ,,ก,ข,ฃ,       ณ',   'a,A         ,           บ',
'บ',   'a,e,i,o,u          …,,,•,—         ณ',   'c,C         ,€           บ',
'บ',   'a,e,i,o,u          ,,,“,–         ณ',   'n,N         ค,ฅ           บ',
'บ',   'a,e,i,o,u,A,O,U,y  ,,,”,,,,, ณ',   'a,o         ฆ,ง           บ',
'ศอออออออออออออออออออออออออออออออออออออออออออฯออออออออออออออออออออออออออออออออผ',
                     'Hit any key to return.', ' ' );
var
    garbage   : char;
    scrn_temp : scrn_def;
    i         : integer;
begin
    with scrn_temp do
       begin
       extra_char    := true;
       scrn_num_flds := 48;
       scrn_clrscrn  := true;
       scrn_clr_color := NormColor;
       curs_pos_fld  := 48;
       scrn_order[1] := 0;

       {------------------------------------------------------------------}
       for i := 1 to 48 do
          with scrn_fld_def[i] do
            begin
            scrn_order[i] := temp_order[i];
            fld_entry := temp_text[i];
            fld_len   := temp_len[i];
            fld_row   := temp_line[i];
            fld_col_start := temp_col[i];
            fld_editable := false;
            if i > 19 then
               fld_color := NormColor
            else
               fld_color := BriteColor;
            end;

       end; {with scrn_temp}

       SCREENIO(scrn_temp);
       garbage := readchr(0);
       if garbage = #0 then
          garbage := readchr(0);
end;
{************************************************************************}

procedure SCRN_STATUS_BUILD;
  const
     SessDisplay : array[1..4] of string[15] =
                   ('New Word Review',
                    'Gaining Control',
                    'Maintenance',
                    'Brush-up'       );
     StatusFldRows : array[1..59] of integer =
                                                           {--fld #s---}
        {--title,   sess,   less,   colhdr1,   colhdr2}    { 1- 5}
        (   1,       1,      2,       4,         4,
        {---less name,    #in pile,    'NEXT',    #errors}
              6,            6,           6,        6,      { 6, 7, 8, 9}
              7,            7,           7,        7,      {10,11,12,13}
              8,            8,           8,        8,      {14,15,16,17}
              9,            9,           9,        9,      {18,19,20,21}
             10,           10,          10,        10,     {22,23,24,25}
             11,           11,          11,        11,     {26,27,28,29}
             12,           12,          12,        12,     {30,31,32,33}
                   {------options------------}
                   5, 6, 7, 8, 9,10,11,12,13,              {34-42}
            {------action numbers-----}
            14,15,16,17,18,19,20,                          {43-49}
            {------actions------------}
            14,15,16,17,18,19,20,21,                       {50-57}
        {space-for-entry, err-msg}
               21,          23);                           {58,59}
     StatusFldCols : array[1..59] of integer =
                                                           {--fld #s---}
        {--title,   sess,   less,   colhdr1,   colhdr2}    { 1- 5}
        (   9,      37,     37,      21,        38,
        {---less name,    #in pile,    'NEXT',    #errors}
              4,           21,          29,       37,      { 6, 7, 8, 9}
              4,           21,          29,       37,      {10,11,12,13}
              4,           21,          29,       37,      {14,15,16,17}
              4,           21,          29,       37,      {18,19,20,21}
              4,           21,          29,       37,      {22,23,24,25}
              4,           21,          29,       37,      {26,27,28,29}
              4,           21,          29,       37,      {30,31,32,33}
                   {------options------------}
                  55,55,55,55,55,55,55,55,55,              {34-42}
            {------action numbers-----}
            11,11,11,11,11,11,11,                          {43-49}
            {------actions------------}
            13,13,13,13,13,13,13, 4,                       {50-57}
        {space-for-entry, err-msg}
               28,           1);                           {58,59}
     StatusFldLens : array[1..59] of integer =
                                                           {--fld #s---}
        {--title,   sess,   less,   colhdr1,   colhdr2}    { 1- 5}
        (   3,      41,     41,       9,         9,
        {---less name,    #in pile,    'NEXT',    #errors}
             14,            6,           7,       6,       { 6, 7, 8, 9}
             14,            6,           7,       6,       {10,11,12,13}
             14,            6,           7,       6,       {14,15,16,17}
             14,            6,           7,       6,       {18,19,20,21}
             14,            6,           7,       6,       {22,23,24,25}
             14,            6,           7,       6,       {26,27,28,29}
             14,            6,           7,       6,       {30,31,32,33}
                   {------options------------}
                  26,26,26,26,26,26,26,26,26,              {34-42}
            {------action numbers-----}
             1, 1, 1, 1, 1, 1, 1,                          {43-49}
            {------actions------------}
            33,33,33,33,33,33,33,23,                       {50-57}
        {space-for-entry, err-msg}
                1,          80);                           {58,59}
  var
     ChartCurr : integer;
     ChartNext : integer;
     ScrnSub   : integer;
     WkDone    : boolean;
     WkIntStr  : string[6];
begin
      with scrn_misc_data do
        begin;
        extra_char    := true;
        scrn_num_flds :=  59;
        scrn_order[1] := 0;
        scrn_clrscrn  := true;
        curs_pos_fld  := 58;
        scrn_hotkey_cnt := 1;
        scrn_hot_keys[1] := 'aster';
        scrn_hot_keyhit  := '';
        for i := 1 to scrn_num_flds do
           with scrn_fld_def[i] do
           begin
             fld_col_start := StatusFldCols[i];
             fld_entry := '';
             fld_len   := StatusFldLens[i];
             fld_row   := StatusFldRows[i];
             fld_color := NormColor;
             fld_editable := false;
           end;
        end;

       { HEADINGS }
       ScrnSub := 1;
       with scrn_misc_data, scrn_fld_def[ScrnSub] do
            fld_entry := 'LESSON STATUS';
       ScrnSub := ScrnSub + 1;
       with scrn_misc_data, scrn_fld_def[ScrnSub] do
            fld_entry := 'MOST RECENT SESSION:' + RightJust(HdrRec.SessNo);
       ScrnSub := ScrnSub + 1;
       with scrn_misc_data, scrn_fld_def[ScrnSub] do
           if odd(HdrRec.LastLess) then
              fld_entry := 'MOST RECENT LESSON : ' + s[HdrRec.LastLess]
           else
              fld_entry := 'MOST RECENT LESSON : ' + s[HdrRec.LastLess] + ' errors';
       ScrnSub := ScrnSub + 1;
       with scrn_misc_data, scrn_fld_def[ScrnSub] do
            fld_entry := '# in pile';
       ScrnSub := ScrnSub + 1;
       with scrn_misc_data, scrn_fld_def[ScrnSub] do
            fld_entry := '# errors';

       { LESSON COUNTS }
       WkDone := false;
       ChartCurr := 14;
       ChartNext := LessChart[HdrRec.SessType,ChartCurr];
       repeat
           with scrn_misc_data do
              begin
              if odd(ChartNext) then
                 begin
                 ScrnSub := ScrnSub + 1;
                 scrn_fld_def[ScrnSub].fld_entry := s[ChartNext];
                 ScrnSub := ScrnSub + 1;
                 scrn_fld_def[ScrnSub].fld_entry :=
                      RightJust(HdrRec.wdcnt[ChartNext]);
                 end
              else
                 begin
                 ScrnSub := ScrnSub + 1;
                 if ThisLess = ChartCurr then
                    begin
                    scrn_fld_def[ScrnSub].fld_entry := '<--NEXT';
                    scrn_fld_def[ScrnSub].fld_color := BriteColor;
                    end
                 else
                 if ThisLess = ChartNext then
                    begin
                    scrn_fld_def[ScrnSub].fld_entry := 'NEXT-->';
                    scrn_fld_def[ScrnSub].fld_color := BriteColor;
                    end
                 else
                    begin
                    scrn_fld_def[ScrnSub].fld_entry := '';
                    scrn_fld_def[ScrnSub].fld_color := NormColor;
                    end;
                 ScrnSub := ScrnSub + 1;
                 scrn_fld_def[ScrnSub].fld_entry :=
                      RightJust(HdrRec.wdcnt[ChartNext]);
                 end;
              end;
           ChartCurr := ChartNext;
           ChartNext := LessChart[HdrRec.SessType,ChartCurr];
           if ChartNext < ChartCurr then
              WkDone := true;
       until WkDone;

       {Blank out rest of lessons}
       for i := ScrnSub + 1 to 33 do
           scrn_misc_data.scrn_fld_def[i].fld_entry := '';

       { OPTIONS DISPLAY }
       ScrnSub := 34;
       with scrn_misc_data, scrn_fld_def[ScrnSub] do
            fld_entry := '| OPTIONS IN USE:';

       ScrnSub := ScrnSub + 1;
       str(HdrRec.ErrRptCnt, WkIntStr);
       scrn_misc_data.scrn_fld_def[ScrnSub].fld_entry := '| Practice errors '
                                                    + WkIntStr
                                                    + ' times';
       ScrnSub := ScrnSub + 1;
       scrn_misc_data.scrn_fld_def[ScrnSub].fld_entry := '| Mode: '
                                   + SessDisplay[HdrRec.SessType];
       If HdrRec.MaxLess > 0 then
          begin
          ScrnSub := ScrnSub + 1;
          str(HdrRec.MaxLess, WkIntStr);
          scrn_misc_data.scrn_fld_def[ScrnSub].fld_entry := '| Max Lesson Size: '
                                                      + WkIntStr;
          end;
       If HdrRec.TypoOnRg then
          begin
          ScrnSub := ScrnSub + 1;
          scrn_misc_data.scrn_fld_def[ScrnSub].fld_entry := '| 2nd try RECOG typos';
          end;
       If HdrRec.TypoOnRc then
          begin
          ScrnSub := ScrnSub + 1;
          scrn_misc_data.scrn_fld_def[ScrnSub].fld_entry := '| 2nd try RECALL typos';
          end;
       If not HdrRec.DropbackOn then
          begin
          ScrnSub := ScrnSub + 1;
          scrn_misc_data.scrn_fld_def[ScrnSub].fld_entry := '| Errors don''t dropback';
          end;
       If not HdrRec.HistoryOn then
          begin
          ScrnSub := ScrnSub + 1;
          scrn_misc_data.scrn_fld_def[ScrnSub].fld_entry := '| History log disabled';
          end;
       If HdrRec.NWskipOn then
          begin
          ScrnSub := ScrnSub + 1;
          scrn_misc_data.scrn_fld_def[ScrnSub].fld_entry := '| Skip new words';
          end;

       {Blank out rest of options}
       for i := ScrnSub + 1 to 42 do
           scrn_misc_data.scrn_fld_def[i].fld_entry := '';


       { ACTION NUMBERS DISPLAY}
       ScrnSub := 43;
       scrn_misc_data.scrn_fld_def[ScrnSub].fld_entry := '1';
       scrn_misc_data.scrn_fld_def[ScrnSub].fld_color := BriteColor;
       ScrnSub := ScrnSub + 1;
       scrn_misc_data.scrn_fld_def[ScrnSub].fld_entry := '2';
       scrn_misc_data.scrn_fld_def[ScrnSub].fld_color := BriteColor;
       ScrnSub := ScrnSub + 1;
       scrn_misc_data.scrn_fld_def[ScrnSub].fld_entry := '3';
       scrn_misc_data.scrn_fld_def[ScrnSub].fld_color := BriteColor;
          {the rest reserved for future use}

       { ACTIONS DISPLAY }
       ScrnSub := 50;
       scrn_misc_data.scrn_fld_def[ScrnSub].fld_entry :=
              'NEXT LESSON                             ';
       ScrnSub := ScrnSub + 1;
       scrn_misc_data.scrn_fld_def[ScrnSub].fld_entry :=
              'CHANGE SESSION TYPE                     ';
       ScrnSub := ScrnSub + 1;
       scrn_misc_data.scrn_fld_def[ScrnSub].fld_entry :=
              'SKIP/RESTORE NEW WORD LESSON            ';
          {the rest reserved for future use}

       ScrnSub := 57;
       scrn_misc_data.scrn_fld_def[ScrnSub].fld_entry := 'Choose one (* to exit):';
       ScrnSub := ScrnSub + 1;
       scrn_misc_data.scrn_fld_def[ScrnSub].fld_entry    := '';
       scrn_misc_data.scrn_fld_def[ScrnSub].fld_color    := EntryColor;
       scrn_misc_data.scrn_fld_def[ScrnSub].fld_editable := true;
       { ERROR MSG }
       ScrnSub := 59;
       if errmsg > '' then
          begin
          scrn_misc_data.scrn_fld_def[ScrnSub].fld_entry := errmsg;
          scrn_misc_data.scrn_fld_def[ScrnSub].fld_color := BriteColor;
          end
       else
          begin
          scrn_misc_data.scrn_fld_def[ScrnSub].fld_entry := errmsg;
          scrn_misc_data.scrn_fld_def[ScrnSub].fld_color := NormColor;
          end;

end;

{************************************************************************}
procedure FMTDRILL(var WkLang : string);    {Set len, etc for fields}
    {Note: field values to be filled in later; some to be changed.}
begin
    checkaccent := true;               {don't use ":" as umlaut, etc}
    with scrn_misc_data do
       begin
       extra_char    := true;
       scrn_num_flds := 13;
       scrn_order[1] := 0;
       scrn_clrscrn  := true;
       curs_pos_fld  := 0;

       {set up hot keys for 'hit any key...', but cnt=0 to not use yet}
       scrn_hotkey_cnt := 0;
       scrn_hot_keys[1] := 'aster';
       scrn_hot_keys[2] := 'any';
       scrn_hot_keyhit  := '';

       {----Headings----------------------------------------}
       with scrn_fld_def[1] do
         begin
         fld_len   := 55;
         fld_row   := 1;
         fld_col_start := 16;
         fld_editable := false;
         fld_color := NormColor;
         end;
       with scrn_fld_def[2] do
         begin
         fld_len   := 55;
         fld_row   := 2;
         fld_col_start := 16;
         fld_editable := false;
         fld_color := NormColor;
         end;
       {----Body--------------------------------------------}
       with scrn_fld_def[3] do   {prompt language}
         begin
         fld_len   := enwdlen;
         fld_row   := 5;
         fld_col_start := 1;
         fld_editable := false;
         fld_color := BriteColor;
         end;
       with scrn_fld_def[4] do   {prompt/instructions}
         begin
         fld_entry := 'Type the ' + upcases(TRIM_TRAIL(WkLang)) + ' translation';
         fld_len   := 79;
         fld_row   := 10;
         fld_col_start := 1;
         fld_editable := false;
         fld_color := NormColor;
         end;
       with scrn_fld_def[5] do   {place for answer to be entered}
         begin
         fld_len   := enwdlen;
         fld_row   := 13;
         fld_col_start := 1;
         fld_editable := true;
         fld_color := EntryColor;
         end;
       with scrn_fld_def[6] do   {correct/incorrect/try-again}
         begin
         fld_len   := 26;
         fld_row   := 15;
         fld_col_start := 1;
         fld_editable := false;
         fld_color := NormColor;
         end;
       with scrn_fld_def[7] do   {correct answer if wrong}
         begin
         fld_len   := enwdlen;
         fld_row   := 18;
         fld_col_start := 1;
         fld_editable := false;
         fld_color := NormColor;
         end;
       with scrn_fld_def[8] do   {rafsi - location to be determined}
         begin
         fld_len   := 55;
         fld_row   := 5;
         fld_col_start := 25;
         fld_editable := false;
         fld_color := NormColor;
         end;
       with scrn_fld_def[9] do   {clue - location to be determined}
         begin
         fld_len   := 11 + encluelen;
         fld_row   := 18;
         fld_col_start := 25;
         fld_editable := false;
         fld_color := NormColor;
         end;
       with scrn_fld_def[10] do  {definition, line1 - location to be determined}
         begin
         fld_len   := 5 + ensuplen1;
         fld_row   := 19;
         fld_col_start := 25;
         fld_editable := false;
         fld_color := NormColor;
         end;
       with scrn_fld_def[11] do  {definition, line2 - location to be determined}
         begin
         fld_len   := ensuplen2;
         fld_row   := 20;
         fld_col_start := 28;
         fld_editable := false;
         fld_color := NormColor;
         end;
       {----msgs--------------------------------------------}
       with scrn_fld_def[12] do  {movement/hit-any-key instructions}
         begin
         fld_len   := 79;
         fld_row   := 23;
         fld_col_start := 1;
         fld_editable := false;
         fld_color := NormColor;
         end;
       {----fake entry--------------------------------------}
       with scrn_fld_def[13] do  {dummy field to position cursor, wait for key}
         begin
         fld_entry := '';
         fld_len   := 0;
         fld_row   := 24;
         fld_col_start := 1;
         fld_editable := false;
         fld_color := NormColor;
         end;
       end;
end;

{************************************************************************}
procedure FMTCHGSESS(var scrn_misc_data : scrn_def);
    {Set initial len, etc for fields; not entry values }
begin
     {--present initial screen------------------------------}
     with scrn_misc_data do
        begin
        extra_char    := true;
        scrn_num_flds := 26;
        scrn_order[1] := 0;
        scrn_clrscrn  := true;
        curs_pos_fld  := 0;

        scrn_hotkey_cnt := 1;
        scrn_hot_keys[1] := 'aster';
        scrn_hot_keyhit  := '';

        {----Headings----------------------------------------}
        with scrn_fld_def[1] do
          begin
          fld_len   := 20;
          fld_row   := 01;
          fld_col_start := 26;
          fld_editable := false;
          fld_color := NormColor;
          end;
        with scrn_fld_def[2] do
          begin
          fld_len   := 22;
          fld_row   := 03;
          fld_col_start := 14;
          fld_editable := false;
          fld_color := NormColor;
          end;

        {----Options-----------------------------------------}
        with scrn_fld_def[3] do
          begin
          fld_len   := 01;
          fld_row   := 05;
          fld_col_start := 01;
          fld_editable := false;
          fld_color := BriteColor;
          end;
        with scrn_fld_def[4] do
          begin
          fld_len   := 17;
          fld_row   := 05;
          fld_col_start := 3;
          fld_editable := false;
          fld_color := NormColor;
          end;
        with scrn_fld_def[5] do
          begin
          fld_len   := 73;
          fld_row   := 06;
          fld_col_start := 7;
          fld_editable := false;
          fld_color := NormColor;
          end;
        with scrn_fld_def[6] do
          begin
          fld_len   := 73;
          fld_row   := 07;
          fld_col_start := 7;
          fld_editable := false;
          fld_color := NormColor;
          end;


        with scrn_fld_def[7] do
          begin
          fld_len   := 01;
          fld_row   := 09;
          fld_col_start := 01;
          fld_editable := false;
          fld_color := BriteColor;
          end;
        with scrn_fld_def[8] do
          begin
          fld_len   := 17;
          fld_row   := 09;
          fld_col_start := 3;
          fld_editable := false;
          fld_color := NormColor;
          end;
        with scrn_fld_def[9] do
          begin
          fld_len   := 73;
          fld_row   := 10;
          fld_col_start := 7;
          fld_editable := false;
          fld_color := NormColor;
          end;
        with scrn_fld_def[10] do
          begin
          fld_len   := 73;
          fld_row   := 11;
          fld_col_start := 7;
          fld_editable := false;
          fld_color := NormColor;
          end;

        with scrn_fld_def[11] do
          begin
          fld_len   := 01;
          fld_row   := 13;
          fld_col_start := 01;
          fld_editable := false;
          fld_color := BriteColor;
          end;
        with scrn_fld_def[12] do
          begin
          fld_len   := 17;
          fld_row   := 13;
          fld_col_start := 3;
          fld_editable := false;
          fld_color := NormColor;
          end;
        with scrn_fld_def[13] do
          begin
          fld_len   := 73;
          fld_row   := 14;
          fld_col_start := 7;
          fld_editable := false;
          fld_color := NormColor;
          end;
        with scrn_fld_def[14] do
          begin
          fld_len   := 73;
          fld_row   := 15;
          fld_col_start := 7;
          fld_editable := false;
          fld_color := NormColor;
          end;

        with scrn_fld_def[15] do
          begin
          fld_len   := 01;
          fld_row   := 17;
          fld_col_start := 01;
          fld_editable := false;
          fld_color := BriteColor;
          end;
        with scrn_fld_def[16] do
          begin
          fld_len   := 17;
          fld_row   := 17;
          fld_col_start := 3;
          fld_editable := false;
          fld_color := NormColor;
          end;
        with scrn_fld_def[17] do
          begin
          fld_len   := 73;
          fld_row   := 18;
          fld_col_start := 7;
          fld_editable := false;
          fld_color := NormColor;
          end;
        with scrn_fld_def[18] do
          begin
          fld_len   := 73;
          fld_row   := 19;
          fld_col_start := 7;
          fld_editable := false;
          fld_color := NormColor;
          end;

        {----Bottom------------------------------------------}
        with scrn_fld_def[19] do
          begin
          fld_len   := 11;
          fld_row   := 21;
          fld_col_start := 7;
          fld_editable := false;
          fld_color := NormColor;
          end;
        with scrn_fld_def[20] do         {entry line}
          begin
          fld_len   := 1;
          fld_row   := 21;
          fld_col_start := 19;
          fld_editable := true;
          fld_color := EntryColor;
          end;
        with scrn_fld_def[21] do
          begin
          fld_len   := 2;
          fld_row   := 21;
          fld_col_start := 22;
          fld_editable := false;
          fld_color := NormColor;
          end;
        with scrn_fld_def[22] do
          begin
          fld_len   := 1;
          fld_row   := 21;
          fld_col_start := 24;
          fld_editable := false;
          fld_color := BriteColor;
          end;
        with scrn_fld_def[23] do
          begin
          fld_len   := 24;
          fld_row   := 21;
          fld_col_start := 25;
          fld_editable := false;
          fld_color := NormColor;
          end;

        with scrn_fld_def[24] do       {Warning/error line}
          begin
          fld_len   := 79;
          fld_row   := 22;
          fld_col_start := 1;
          fld_editable := false;
          fld_color := NormColor;
          end;
        with scrn_fld_def[25] do       {Verify prompt}
          begin
          fld_len   := 44;
          fld_row   := 23;
          fld_col_start := 1;
          fld_editable := false;
          fld_color := NormColor;
          end;
        with scrn_fld_def[26] do       {Verify ans}
          begin
          fld_len   := 1;
          fld_row   := 23;
          fld_col_start := 46;
          fld_editable := false;
          fld_color := NormColor;
          end;
        end;
end;

{************************************************************************}
procedure FMT_OPTIONS;
  const
    LineText : array[1..12] of string[80] =
    (
      '                    LESSON CONTROL OPTIONS',
      '                                                        Default',

      '                                                          ', {unused}
      'Maximum lesson size for other lessons is    .            0 (0=no max)',
      'Practice errors    times.                                6',
      'Allow 2nd try on RECOG  typos (Y/N):                     N',
      'Allow 2nd try on RECALL typos (Y/N):                     N',
      'Drop back errors to Dropback Pile (Y/N):                 Y',
      'Skip new words (Y/N):                                    N',
      'Disable history log (Y/N):                               N',

      'Reset all options to defaults (Y/N): ',


      'TABs, ARROWs to move; ENTER when done; "*" to cancel.'
    );
    LineStart : array[1..24] of integer =
      (5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5,        {constant lines}
            50,46,21,42,42,46,27,32,42,           {entries on const lines}
       5, 59,                                     {confirm line}
       5);                                        {errmsg}
    LineLine : array[1..24] of integer =
      (1, 2, 4, 5, 6, 7, 8, 9,10,11,13,16,        {constant lines}
             4, 5, 6, 7, 8, 9,10,11,13,           {entries on const lines}
       18,18,                                     {confirm line}
       19);                                       {errmsg}
    LineLen  : array[1..24] of integer =
     (70,70,70,70,70,70,70,70,70,70,70,70,        {constant lines}
             3, 3, 2, 1, 1, 1, 1, 1, 1,           {entries on const lines}
      52, 1,                                      {confirm line}
      74);                                        {errmsg}

begin
    with scrn_misc_data do
      begin;
      extra_char    := false;
      scrn_num_flds :=  24;
      scrn_order[1] := 0;
      scrn_clrscrn  := true;
      curs_pos_fld  := 0;
      scrn_hotkey_cnt := 1;
      scrn_hot_keys[1] := 'aster';
      scrn_hot_keyhit  := '';

      for i := 1 to 12 do                       {constant lines}
         with scrn_fld_def[i] do
           begin
           fld_col_start := LineStart[i];
           fld_len       := LineLen[i];
           fld_row       := LineLine[i];
           fld_entry     := LineText[i];
           fld_editable  := false;
           fld_color     := NormColor;
           end;
      with scrn_fld_def[13] do
        begin
        fld_col_start := LineStart[13];
        fld_len       := LineLen[13];
        fld_row       := LineLine[13];
        fld_entry     := '';
        fld_editable  := false;
        fld_color     := NormColor;
        end;
      for i := 14 to 21 do                      {entries on const lines}
         with scrn_fld_def[i] do
           begin
           fld_col_start := LineStart[i];
           fld_len       := LineLen[i];
           fld_row       := LineLine[i];
           fld_editable  := true;
           fld_color     := EntryColor;
           end;
      for i := 22 to 24 do                      {confirm, errmsg lines}
         with scrn_fld_def[i] do
           begin
           fld_entry     := '';
           fld_col_start := LineStart[i];
           fld_len       := LineLen[i];
           fld_row       := LineLine[i];
           fld_editable  := false;
           fld_color     := NormColor;
           end;
      end;

end;
{************************************************************************}
   procedure FMT_DISPLAY_SELECTION(DisplayType : string);
{
                           DISPLAY MENU                                01-01

A   All words.                                                         02-03
B   All words for lesson pile #__.                                     04-07
      1 Under Control pile.    ------- Next lesson only? (Y/N) _       08-10
      2 Under Control Errors.                                          11-12
      3 Recalled 1x pile.                                              13-14
      4 Recalled 1x Errors.                                            15-16
      5 Recognized 3x pile                                             17-18
      6 Recognized 3x Errors.                                          19-20
      7 Recognized 2x pile.                                            21-22
      8 Recognized 2x Errors.                                          23-24
      9 Recognized 1x pile.                                            25-26
     10 Recognized 1x Errors.                                          27-28
     11 Failure pile.                                                  29-30
     12 Failure Errors.                                                31-32
     13 New Word pile.         ------- Next lesson only? (Y/N) _       33-35
     14 New Words Errors.                                              36-37

 Print format (B=Brief C=Complete): _   Lines/Page: __    Printer: ____38-47 was
                          Ordering: _   (E=English L=lojban P=pre-set) 48-56 38-46
        Please select one (A or B): _                                  57-58 47-48
                                                   errmsg              59    49
           TABs, ARROWs to move; "*" end; hit ENTER when done.         60    50



}
     const
       wk_row    : array[1..60] of integer =
                    ( 1,
                      3, 3,
                      4, 4, 4, 4,
                      5, 5, 5,
                      6, 6,    7, 7,   8, 8,    9, 9,   10,10,   11,11,
                     12,12,   13,13,  14,14,   15,15,   16,16,
                     17,17,17,
                     18,18,
                     {printing}
                     20,20,20,20,20,20,    20,20,    20,20,
                     {ordering}
                     21,21,  21, 21,21, 21,21, 21,21,
                     22,22,
                     23,
                     24);
       wk_col    : array[1..60] of integer =
                    (28,
                      1, 5,
                      1, 5,32,34,
                      6, 9,64,
                      6, 9,    6, 9,   6, 9,    6, 9,    6, 9,    6, 9,
                      6, 9,    6, 9,   6, 9,    6, 9,    6, 9,
                      6, 9,64,
                      6, 9,
                     {printing}
                      2,16,17,24,25,37,    41,53,    59,68,
                     {ordering - some to be set later}
                     18,29, 33, 34,35, 44,45, 45,46,
                      1,29,
                      1,
                      12);
       wk_len    : array[1..60] of integer =
                    (12,
                      1,10,
                      1,27, 2, 1,
                      2,54, 1,
                      2,54,    2,54,   2,54,    2,54,    2,54,    2,54,
                      2,54,    2,54,   2,54,    2,54,    2,54,
                      2,54, 1,
                      2,54,
                     {printing}
                     14, 1, 6, 1,11, 1,    11, 2,     8, 4,
                     {ordering - other language to be set later}
                     10, 1,  1,  1,9,   1,0,  1,9,
                     27, 1,
                     80,
                     51);

       wk_text   : array[1..60] of string[80] =
         (                      'DISPLAY MENU',

         'A','All words.',

         'B','All words for lesson pile #',  '',  ' ',
              ' 1','Under Control pile     ------- Next lesson only? (Y/N)',  'N',
              ' 2','Under Control errors',
              ' 3','Recalled 1x pile',
              ' 4','Recalled 1x errors',
              ' 5','Recognized 3x pile',
              ' 6','Recognized 3x errors',
              ' 7','Recognized 2x pile',
              ' 8','Recognized 2x errors',
              ' 9','Recognized 1x pile',
              '10','Recognized 1x errors',
              '11','Failure pile',
              '12','Failure errors',
              '13','New Word pile          ------- Next lesson only? (Y/N)',  'N',
              '14','New Words errors',

             {printing}
             'Print format (','B','=Brief','C','=Complete):','B',
             'Lines/Page:','63',  'Printer:','LPT1',

             {ordering - other language to be set later}
         'Ordering :','L', '(', 'E','=English','L','=','P','=pre-set)',
             'Please select one (A or B):',  '',
          '',
          'TABs, ARROWs to move; "*" end; hit ENTER when done.');
     var
        i     :  integer;
        LangLen : integer;
     begin
     with scrn_misc_data do
       begin;
       extra_char    := false;
       scrn_num_flds :=  60;
       scrn_order[1] := 0;
       scrn_clrscrn  := true;
       curs_pos_fld  := 58;
       scrn_hotkey_cnt := 1;
       scrn_hot_keys[1] := 'aster';
       scrn_hot_keyhit  := '';
       for i := 1 to scrn_num_flds do
          with scrn_fld_def[i] do
             begin
               fld_col_start := wk_col[i];
               fld_entry     := wk_text[i];
               fld_len       := wk_len[i];
               fld_row       := wk_row[i];
               fld_color     := NormColor;
               fld_editable  := false;
             end;

       if DisplayType = 'print' then
          scrn_misc_data.scrn_fld_def[1].fld_entry := 'PRINT MENU'
       else
          for i := 38 to 47  do
             with scrn_fld_def[i] do
                begin
                  fld_col_start := wk_col[i];
                  fld_entry     := '';
                  fld_len       := wk_len[i];
                  fld_row       := wk_row[i];
                  fld_color     := NormColor;
                  fld_editable  := false;
                end;

       with scrn_fld_def[06] do
          begin
            fld_color     := EntryColor;
            fld_editable  := true;
          end;
       with scrn_fld_def[10] do
          begin
            fld_color     := EntryColor;
            fld_editable  := true;
          end;
       with scrn_fld_def[35] do
          begin
            fld_color     := EntryColor;
            fld_editable  := true;
          end;

       if DisplayType = 'print' then
          begin
          with scrn_fld_def[43] do
             begin
               fld_color     := EntryColor;
               fld_editable  := true;
             end;
          with scrn_fld_def[45] do
             begin
               fld_color     := EntryColor;
               fld_editable  := true;
             end;
          with scrn_fld_def[47] do
             begin
               fld_color     := EntryColor;
               fld_editable  := true;
             end;
          end;

       with scrn_fld_def[49] do
          begin
            fld_color     := EntryColor;
            fld_editable  := true;
          end;
       with scrn_fld_def[58] do
          begin
            fld_color     := EntryColor;
            fld_editable  := true;
          end;
       scrn_misc_data.scrn_fld_def[02].fld_color := BriteColor;
       scrn_misc_data.scrn_fld_def[04].fld_color := BriteColor;
       scrn_misc_data.scrn_fld_def[08].fld_color := BriteColor;
       scrn_misc_data.scrn_fld_def[11].fld_color := BriteColor;
       scrn_misc_data.scrn_fld_def[13].fld_color := BriteColor;
       scrn_misc_data.scrn_fld_def[15].fld_color := BriteColor;
       scrn_misc_data.scrn_fld_def[17].fld_color := BriteColor;
       scrn_misc_data.scrn_fld_def[19].fld_color := BriteColor;
       scrn_misc_data.scrn_fld_def[21].fld_color := BriteColor;
       scrn_misc_data.scrn_fld_def[23].fld_color := BriteColor;
       scrn_misc_data.scrn_fld_def[25].fld_color := BriteColor;
       scrn_misc_data.scrn_fld_def[27].fld_color := BriteColor;
       scrn_misc_data.scrn_fld_def[29].fld_color := BriteColor;
       scrn_misc_data.scrn_fld_def[31].fld_color := BriteColor;
       scrn_misc_data.scrn_fld_def[33].fld_color := BriteColor;
       scrn_misc_data.scrn_fld_def[36].fld_color := BriteColor;

       if DisplayType = 'print' then
          begin
          scrn_misc_data.scrn_fld_def[39].fld_color := BriteColor;
          scrn_misc_data.scrn_fld_def[41].fld_color := BriteColor;
          end;

       scrn_misc_data.scrn_fld_def[51].fld_color := BriteColor;
       scrn_misc_data.scrn_fld_def[53].fld_color := BriteColor;
       scrn_misc_data.scrn_fld_def[55].fld_color := BriteColor;


       with scrn_fld_def[54] do
          begin
            fld_entry     := fld_entry + TRIM_TRAIL(langname) + ' ';
            fld_len       := length(fld_entry);
            LangLen       := fld_len;
          end;
       with scrn_fld_def[55] do
            fld_col_start := fld_col_start + LangLen;
       with scrn_fld_def[56] do
            fld_col_start := fld_col_start + LangLen;

       end;
     end;
{************************************************************************}
procedure LANGENTR(var scrn_data: scrn_def);
   var
        i              :  integer;
        keyhelp_sw     :  boolean;
        exit_sw        :  boolean;
begin
   keyhelp_sw := true;
   exit_sw    := true;
   with scrn_data do
      begin
      for i := 1 to scrn_hotkey_cnt do
         if scrn_hot_keys[i] = 'no-keyhelp' then
            keyhelp_sw := false
         else
         if scrn_hot_keys[i] = 'no-exit' then
            exit_sw    := false;
      if scrn_hotkey_cnt < 10 then
         if keyhelp_sw then
            begin
            scrn_hotkey_cnt := scrn_hotkey_cnt + 1;
            scrn_hot_keys[scrn_hotkey_cnt] := 'keyhelp';
            end;
      if scrn_hotkey_cnt < 10 then
         if exit_sw then
            begin
            scrn_hotkey_cnt := scrn_hotkey_cnt + 1;
            scrn_hot_keys[scrn_hotkey_cnt] := 'exit';
            end;
   end;
      SCREENIO(scrn_data);
   repeat
      if scrn_data.scrn_hot_keyhit = 'exit' then
         EXIT_ROUTINE
      else
      if scrn_data.scrn_hot_keyhit = 'keyhelp' then
         begin
         SHOWKEYS;
         scrn_data.scrn_hot_keyhit := '';
         scrn_data.scrn_clrscrn := true;
         SCREENIO(scrn_data);
         end;
   until (scrn_data.scrn_hot_keyhit <> 'keyhelp') and
         (scrn_data.scrn_hot_keyhit <> 'exit');
end;

{************************************************************************}
procedure SHOWPAGE(PageNo, PageCnt, WdsThisPage, WdsPerPage : integer;
                   var WdsPerScreen : integer;
                   Order, DisplayRequest                    : string;
                {  L/E/T  ''/lookup/edit                   }
                   StartSub  :  integer;
                   Heading : string; TotNumWds : integer);
  {a "page" is an arrayful of data}
  var
      GoBack  :  boolean;           {true==>go back to caller for next page}
      WkFld   :  integer;
      WdSub   :  integer;
      ScrnSub :  integer;
      WkLang  :  string[15];
      ThisScreen : integer;
      LastScreen : integer;

    procedure FMT_SHOWPAGE;
       begin
       with scrn_misc_data do
          begin
          extra_char    := true;
          scrn_num_flds := 10 + (11 * WdsPerScreen);
          scrn_order[1] := 0;
          scrn_clrscrn  := true;
          curs_pos_fld  := 6;

          if WdsPerPage > 3 then
             scrn_hotkey_cnt := 6
          else
             scrn_hotkey_cnt := 5;

          scrn_hot_keys[1] := 'pgdn';
          scrn_hot_keys[2] := 'pgup';
          scrn_hot_keys[3] := 'aster';
          scrn_hot_keys[4] := 'top';
          scrn_hot_keys[5] := 'bottom';

          if WdsPerPage > 3 then
             scrn_hot_keys[6] := 'pound';
          if DisplayRequest = 'edit' then
             begin
             scrn_hotkey_cnt := scrn_hotkey_cnt + 1;
             scrn_hot_keys[scrn_hotkey_cnt] := 'no-exit';
             end;

          {----Heading-----------------------------------------}
          with scrn_fld_def[1] do
            begin
            fld_entry := Heading;
            fld_len   := 45;
            fld_row   := 1;
            fld_col_start := 11;
            fld_editable := false;
            fld_color := NormColor;
            end;
          with scrn_fld_def[2] do
            begin
            fld_entry := '';   {to be filled in later}
            fld_len   := 20;
            fld_row   := 1;
            fld_col_start := 60;
            fld_editable := false;
            fld_color := NormColor;
            end;
          {----Footing-----------------------------------------}
          {Error message}
          with scrn_fld_def[3] do
            begin
            fld_entry := '';
            fld_len   := 40;
            fld_row   := 22;
            fld_col_start := 3;
            fld_editable := false;
            fld_color := NormColor;
            end;
          {key explanations}
          with scrn_fld_def[4] do
            begin
            fld_entry :=
            'Scroll with PGUP, PGDN, CTRL-PGUP (top), CTRL-PGDN (bottom); * to end review.';
            fld_len   := 77;
            fld_row   := 23;
            fld_col_start := 3;
            fld_editable := false;
            fld_color := NormColor;
            end;
          {further key explanations}
          with scrn_fld_def[5] do
            begin
            if DisplayRequest = 'edit' then
               fld_entry := 'ENTER to accept word changes)'
            else
            if WdsPerPage > 3 then
               fld_entry := '("#" toggles 1-word/4-word display)'
            else
               fld_entry := '';
            fld_len   := 40;
            fld_row   := 24;
            fld_col_start := 3;
            fld_editable := false;
            fld_color := NormColor;
            end;
          {cursor spot if no entry items}
          with scrn_fld_def[6] do
            begin
            fld_entry := '';
            fld_len   := 0;
            fld_row   := 24;
            fld_col_start := 66;
            fld_editable := true;
            fld_color := NormColor;
            end;
          {go to word}
          if Order = 'P' then
             begin
             with scrn_fld_def[7] do
               begin
               fld_entry := '';
               fld_len   := 0;
               fld_row   := 21;
               fld_col_start := 1;
               fld_editable := true;
               fld_color := NormColor;
               end;
             with scrn_fld_def[8] do
               begin
               fld_entry := '';
               fld_len   := 0;
               fld_row   := 21;
               fld_col_start := 1;
               fld_editable := true;
               fld_color := NormColor;
               end;
             end
          else
             begin
             with scrn_fld_def[7] do
               begin
               if Order = 'L' then
                  fld_entry := 'Go to ' + langname + ' word:'
               else
                  fld_entry := 'Go to English word:';
               fld_len   := 12 + length(langname);
               fld_row   := 21;
               fld_col_start := 1;
               fld_editable := false;
               fld_color := NormColor;
               end;
             with scrn_fld_def[8] do
               begin
               fld_entry := '';
               fld_len   := enwdlen;
               fld_row   := 21;
               fld_col_start := scrn_fld_def[7].fld_len + 2;
               fld_editable := true;
               fld_color := EntryColor;
               end;
             {don't use extra dummy field for cursor}
             scrn_fld_def[6].fld_editable := false;
             curs_pos_fld  := 8;
             end;
          {reserved for future}
          with scrn_fld_def[9] do
            begin
            fld_entry := '';
            fld_len   := 0;
            fld_row   := 21;
            fld_col_start := 1;
            fld_editable := false;
            fld_color := NormColor;
            end;
          with scrn_fld_def[10] do
            begin
            fld_entry := '';
            fld_len   := 0;
            fld_row   := 21;
            fld_col_start := 1;
            fld_editable := false;
            fld_color := NormColor;
            end;
          WkFld := 10;
          {----Word data init----------------------------------}
          for i := 1 to WdsPerScreen do
            begin
              {Lojban}
              WkFld := WkFld + 1;
              with scrn_fld_def[WkFld] do
                begin
                fld_entry := '';
                fld_len   := 8;
                fld_row   := (i - 1) * 5 + 2;
                fld_col_start := 1;
                fld_editable := false;
                fld_color := NormColor;
                end;
              WkFld := WkFld + 1;
              with scrn_fld_def[WkFld] do
                begin
                fld_entry := '';
                fld_len   := lgwdlen;
                fld_row   := (i - 1) * 5 + 2;
                fld_col_start := 10;
                fld_editable := false;
                fld_color := BriteColor;
                end;
              {rafsi}
              WkFld := WkFld + 1;
              with scrn_fld_def[WkFld] do
                begin
                fld_entry := '';
                fld_len   := 7 + lgsuplen;
                fld_row   := (i - 1) * 5 + 2;
                fld_col_start := 36;
                fld_editable := false;
                fld_color := NormColor;
                end;
              {lesson}
              WkFld := WkFld + 1;
              with scrn_fld_def[WkFld] do
                begin
                fld_entry := '';
                fld_len   := 20;
                fld_row   := (i - 1) * 5 + 2;
                fld_col_start := 59;
                fld_editable := false;
                fld_color := NormColor;
                end;
              {English}
              WkFld := WkFld + 1;
              with scrn_fld_def[WkFld] do
                begin
                fld_entry := '';
                fld_len   := 8;
                fld_row   := (i - 1) * 5 + 3;
                fld_col_start := 1;
                fld_editable := false;
                fld_color := NormColor;
                end;
              WkFld := WkFld + 1;
              with scrn_fld_def[WkFld] do
                begin
                fld_entry := '';
                fld_len   := enwdlen;
                fld_row   := (i - 1) * 5 + 3;
                fld_col_start := 10;
                if DisplayRequest = 'edit' then
                   begin
                   fld_editable := true;
                   fld_color := EntryColor;
                   end
                else
                   begin
                   fld_editable := false;
                   fld_color := BriteColor;
                   end;
                end;
              {clue}
              WkFld := WkFld + 1;
              with scrn_fld_def[WkFld] do
                begin
                fld_entry := '';
                fld_len   := 6;
                fld_row   := (i - 1) * 5 + 3;
                fld_col_start := 36;
                fld_editable := false;
                fld_color := NormColor;
                end;
              WkFld := WkFld + 1;
              with scrn_fld_def[WkFld] do
                begin
                fld_entry := '';
                fld_len   := encluelen;
                fld_row   := (i - 1) * 5 + 3;
                fld_col_start := 42;
                if DisplayRequest = 'edit' then
                   begin
                   fld_editable := true;
                   fld_color := EntryColor;
                   end
                else
                   begin
                   fld_editable := false;
                   fld_color := NormColor;
                   end;
                end;
              {book lesson code}
              WkFld := WkFld + 1;
              with scrn_fld_def[WkFld] do
                begin
                fld_entry := '';
                fld_len   := elothlen;
                fld_row   := (i - 1) * 5 + 3;
                fld_col_start := 75;
                fld_editable := false;
                fld_color := NormColor;
                end;
              {definition, line 1}
              WkFld := WkFld + 1;
              with scrn_fld_def[WkFld] do
                begin
                fld_entry := '';
                fld_len   := 12 + ensuplen1;
                fld_row   := (i - 1) * 5 + 4;
                fld_col_start := 16;
                fld_editable := false;
                fld_color := NormColor;
                end;
              {definition, line 2}
              WkFld := WkFld + 1;
              with scrn_fld_def[WkFld] do
                begin
                fld_entry := '';
                fld_len   := ensuplen2;
                fld_row   := (i - 1) * 5 + 5;
                fld_col_start := 16;
                fld_editable := false;
                fld_color := NormColor;
                end;
            end; {for i + 1 to WdsPerScreen}
          end; {with scrn_misc_data}
          LastScreen := trunc( (TotNumWds - 1) / WdsPerScreen) + 1;
       end; {fmt_showpage}
begin

    WkLang := upcases(copy(HdrRec.filelang,1,7));
    GoBack := false;
    checkaccent := true;                {use ":" as umlaut, etc}
    FMT_SHOWPAGE;


       if (scrn_misc_data.scrn_hot_keyhit = 'bottom') or
          (scrn_misc_data.scrn_hot_keyhit = 'pgup') then
            ScrnSub := trunc( (WdsThisPage - 1)/WdsPerScreen ) + 1
       else
          ScrnSub := StartSub;

       repeat
         {WdsPerPage always a multiple of WdsPerScreen}
         ThisScreen := trunc((PageNo - 1) * WdsPerPage / WdsPerScreen) + ScrnSub;
         with scrn_misc_data do
            begin

            {------heading screen numbers-------------------}
            scrn_fld_def[2].fld_entry := 'Screen ' + NumString(ThisScreen)
                                        + ' of '    + NumString(LastScreen);

            {------scroll-----------------------------------}
            if (scrn_fld_def[3].fld_entry > '') then
               scrn_fld_def[3].fld_color := BriteColor
            else
            if not GoBack then
               begin
               scrn_fld_def[3].fld_color := NormColor;
               WkFld := 10;
               for i := 1 to WdsPerScreen do
                  begin
                  WdSub := ((ScrnSub - 1) * WdsPerScreen) + i;
                  {---Beyond end of words--------------------------}
                  if WdSub > WdsThisPage then
                     begin
                     for j := 1 to 11 do   {11 items per word}
                       begin
                         WkFld := WkFld + 1;
                         with scrn_fld_def[WkFld] do
                           begin
                           fld_entry := '';
                           fld_color := NormColor;
                           end;
                       end;
                     end
                  else
                  {---Format data for word-------------------------}
                     begin
                       {Lojban}
                       WkFld := WkFld + 1;
                       with scrn_fld_def[WkFld] do
                         fld_entry := WkLang + ':';
                       WkFld := WkFld + 1;
                       with scrn_fld_def[WkFld] do
                         begin
                         fld_entry := arr[WdSub]^.wd.lg;
                         fld_color := BriteColor;
                         end;
                       {rafsi}
                       WkFld := WkFld + 1;
                       with scrn_fld_def[WkFld] do
                         fld_entry := 'RAFSI: ' + arr[WdSub]^.wd.lgs;
                       {lesson}
                       WkFld := WkFld + 1;
                       with scrn_fld_def[WkFld] do
                         if arr[WdSub]^.you.skw then
                            fld_entry := '(skipped)'
                         else
                            if odd(arr[WdSub]^.you.fp) then
                               fld_entry := upcases(s[arr[Wdsub]^.you.fp])
                            else
                               fld_entry := upcases(s[arr[Wdsub]^.you.fp])
                                          + ' ERRORS';
                       {English}
                       WkFld := WkFld + 1;
                       with scrn_fld_def[WkFld] do
                         fld_entry := 'ENGLISH:';
                       WkFld := WkFld + 1;
                       with scrn_fld_def[WkFld] do
                         begin
                         fld_entry := arr[WdSub]^.wd.en;
                         if DisplayRequest = 'edit' then
                            fld_color := EntryColor
                         else
                            fld_color := BriteColor;
                         end;
                       {clue}
                       WkFld := WkFld + 1;
                       with scrn_fld_def[WkFld] do
                         fld_entry := 'CLUE: ';
                       WkFld := WkFld + 1;
                       with scrn_fld_def[WkFld] do
                         begin
                         fld_entry := arr[WdSub]^.wd.ec;
                         if DisplayRequest = 'edit' then
                            fld_color := EntryColor
                         else
                            fld_color := NormColor;
                         end;
                       {book lesson code}
                       WkFld := WkFld + 1;
                       with scrn_fld_def[WkFld] do
                         fld_entry := arr[WdSub]^.wd.elother;
                       {definition, line 1}
                       WkFld := WkFld + 1;
                       with scrn_fld_def[WkFld] do
                         fld_entry := 'DEFINITION: ' + arr[WdSub]^.wd.es1;
                       {definition, line 2}
                       WkFld := WkFld + 1;
                       with scrn_fld_def[WkFld] do
                         fld_entry := arr[WdSub]^.wd.es2;
                     end;
                  end; {for i=1 to WdsPerScreen}
               end; {scroll}

            end;    {with scrn_misc_data}
         if not GoBack then
            LANGENTR(scrn_misc_data);
         with scrn_misc_data do
            begin
            scrn_clrscrn  := false;
            scrn_fld_def[3].fld_entry := '';
            {------determine processing by key pressed------}
            if scrn_hot_keyhit = 'aster' then
               {done}
            else
            if PageCnt = 0 then
               scrn_fld_def[3].fld_entry := 'No words to display'
            else
            if scrn_hot_keyhit = 'pgdn' then
               if ((ScrnSub * WdsPerScreen) < WdsThisPage) then
                  ScrnSub := ScrnSub + 1
               else
               if PageNo >= PageCnt then
                  scrn_fld_def[3].fld_entry := 'No more words'
               else
                  GoBack := true {go back for more words}
            else
            if scrn_hot_keyhit = 'pgup' then
               if (ScrnSub > 1) then
                  ScrnSub := ScrnSub - 1
               else
                  if PageNo = 1 then
                     scrn_fld_def[3].fld_entry := 'No previous words'
                  else
                     GoBack := true {go back for more words}
            else
            if scrn_hot_keyhit = 'top' then
               if (PageNo = 1) then
                  ScrnSub := 1
               else
                  GoBack := true
            else
            if scrn_hot_keyhit = 'bottom' then
               if (PageNo = PageCnt) then
                  ScrnSub := trunc( (WdsThisPage - 1)/WdsPerScreen ) + 1
               else
                  GoBack := true
            else
            if scrn_hot_keyhit = 'pound' then
               begin
               WdSub := ((ScrnSub - 1) * WdsPerScreen) + 1;
               if WdsPerScreen = 1 then
                  WdsPerScreen := 4
               else
                  WdsPerScreen := 1;
               ScrnSub := trunc( (WdSub - 1)/WdsPerScreen ) + 1;
               FMT_SHOWPAGE;
               scrn_misc_data.scrn_clrscrn  := true;
               end
            else
            if (Order <> 'P') and
               (TRIM_FRONT(TRIM_TRAIL(scrn_fld_def[8].fld_entry)) > '') then
               GoBack := true
            else
            if DisplayRequest = 'edit' then
               GoBack := true
            else
               scrn_fld_def[3].fld_entry := 'Invalid key pressed.';
            end; {with scrn misc data for keyhit}
       until (scrn_misc_data.scrn_hot_keyhit = 'aster') or GoBack;
end;
{************************************************************************}
procedure FMT_REGROUP(RegroupType : integer);
     const
        MenuTitle      :  array[1..3] of string[40] =
            ('RESTART WITH NEW WORDS',
             'REGROUP NEW WORDS',
             'REGROUP UNDER CONTROL WORDS');

{
                      Regroup New Word Pile

                                               (current)

Average number words per lesson: ___           (___)

    Order (R=Random, P=Pre-set): _             (R)


Confirm update of file with regrouping (Y/N): _


Tabs, arrows ...

errmsg


}
begin
    with scrn_misc_data do
       begin
       extra_char    := true;
       scrn_num_flds := 12;
       scrn_order[1] := 0;
       scrn_clrscrn  := true;
       scrn_clr_color := NormColor;
       curs_pos_fld  := 0;
       scrn_hotkey_cnt := 1;
       scrn_hot_keys[1] := 'aster';
       scrn_hot_keyhit  := '';
       with scrn_fld_def[1] do
         begin
         fld_entry := MenuTitle[RegroupType];
         fld_len   := 40;
         fld_row   := 1;
         fld_col_start := 23;
         fld_editable := false;
         fld_color := NormColor;
         end;
       with scrn_fld_def[3] do
         begin
         fld_entry := 'Average number words per lesson:';
         fld_len   := 32;
         fld_row   := 5;
         fld_col_start := 1;
         fld_editable := false;
         fld_color := NormColor;
         end;
       with scrn_fld_def[4] do
         begin
         fld_entry := '   ';
         fld_len   := 3;
         fld_row   := 5;
         fld_col_start := 34;
         fld_editable := true;
         fld_color := EntryColor;
         end;
       if (RegroupType = 1) or (RegroupType = 2) then
          begin
          with scrn_fld_def[2] do
            begin
            fld_entry := '(current)';
            fld_len   := 9;
            fld_row   := 3;
            fld_col_start := 48;
            fld_editable := false;
            fld_color := NormColor;
            end;
          with scrn_fld_def[5] do
            begin
            fld_entry := '(' + NumString(HdrRec.NWperLess) + ')';
            fld_len   := length(fld_entry);
            fld_row   := 5;
            fld_col_start := 48;
            fld_editable := false;
            fld_color := NormColor;
            end;
          with scrn_fld_def[6] do
            begin
            fld_entry := '    Order (R=Random, P=Pre-set):';
            fld_len   := 32;
            fld_row   := 7;
            fld_col_start := 1;
            fld_editable := false;
            fld_color := NormColor;
            end;
          with scrn_fld_def[7] do
            begin
            if HdrRec.NWOrder = 'R' then
               fld_entry := 'R'
            else
               fld_entry := 'P';
            fld_len   := 1;
            fld_row   := 7;
            fld_col_start := 34;
            fld_editable := true;
            fld_color := EntryColor;
            end;
          with scrn_fld_def[8] do
            begin
            if HdrRec.NWOrder = 'R' then
               fld_entry := '(R)'
            else
               fld_entry := '(P)';
            fld_len   := 32;
            fld_row   := 7;
            fld_col_start := 48;
            fld_editable := false;
            fld_color := NormColor;
            end;
          end
       else
          begin
          with scrn_fld_def[2] do
            begin
            fld_entry := '';
            fld_len   := 9;
            fld_row   := 3;
            fld_col_start := 48;
            fld_editable := false;
            fld_color := NormColor;
            end;
          with scrn_fld_def[5] do
            begin
            fld_entry := '';
            fld_len   := length(fld_entry);
            fld_row   := 5;
            fld_col_start := 48;
            fld_editable := false;
            fld_color := NormColor;
            end;
          with scrn_fld_def[6] do
            begin
            fld_entry := '';
            fld_len   := 32;
            fld_row   := 7;
            fld_col_start := 1;
            fld_editable := false;
            fld_color := NormColor;
            end;
          with scrn_fld_def[7] do
            begin
            fld_entry := '';
            fld_len   := 1;
            fld_row   := 7;
            fld_col_start := 34;
            fld_editable := false;
            fld_color := NormColor;
            end;
          with scrn_fld_def[8] do
            begin
            fld_entry := '';
            fld_len   := 32;
            fld_row   := 4;
            fld_col_start := 1;
            fld_editable := false;
            fld_color := NormColor;
            end;

          end;

       with scrn_fld_def[9] do
         begin
         fld_entry := '';
         fld_len   := 45;
         fld_row   := 10;
         fld_col_start := 1;
         fld_editable := false;
         fld_color := NormColor;
         end;
       with scrn_fld_def[10] do
         begin
         fld_entry := '';
         fld_len   := 1;
         fld_row   := 10;
         fld_col_start := 47;
         fld_editable := false;
         fld_color := NormColor;
         end;
       with scrn_fld_def[11] do
         begin
         fld_entry := 'TABs, ARROWs to move; ENTER when done; "*" to cancel.';
         fld_len   := 53;
         fld_row   := 13;
         fld_col_start := 1;
         fld_editable := false;
         fld_color := NormColor;
         end;
       with scrn_fld_def[12] do
         begin
         fld_entry := '';
         fld_len   := 80;
         fld_row   := 15;
         fld_col_start := 1;
         fld_editable := false;
         fld_color := NormColor;
         end;

       end;

end;
