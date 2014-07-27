procedure MAIN_MENU(first_selection : char);

var
     WkErrMsg       :  string[80];
     WkNWperLessStr :  string[3];
     WkUCperLessStr :  string[3];
     WkNWperLess    : integer;
     WkUCperLess    : integer;

  procedure FMT_MAIN_MENU;
{                              MAIN MENU
                             Name: xxxxxxx

A  Lesson Menu


B  Display words
C  Print words
D  Edit word file
E  Word lookup

   Set Options
      1  Lesson Control Options
      2  Change Session Type
      3  Restart with all words in New Word pile
      4  Reorder New Word Pile
      5  Reorder Under Control
      6  Change screen colors

*  Exit LogFlash

Select option (A-F, 1-6, *): _      (TAB to change "Number in each lesson")
errmsg
}
  begin
   with scrn_misc_data do
      begin
      extra_char    := true;
      scrn_num_flds := 34;
      scrn_order[1] := 0;
      scrn_clrscrn  := true;
      scrn_clr_color := NormColor;
      curs_pos_fld  := 32;
      scrn_hotkey_cnt := 1;
      scrn_hot_keys[1] := 'aster';
      scrn_hot_keyhit  := '';
      with scrn_fld_def[1] do
        begin
        fld_entry := 'MAIN MENU';
        fld_len   := 9;
        fld_row   := 1;
        fld_col_start := 32;
        fld_editable := false;
        fld_color := NormColor;
        end;
      with scrn_fld_def[2] do
        begin
        fld_entry := 'Name:';
        fld_len   := 5;
        fld_row   := 2;
        fld_col_start := 30;
        fld_editable := false;
        fld_color := NormColor;
        end;
      with scrn_fld_def[3] do
        begin
        fld_entry := copy(f,1,(pos('.',f) - 2));
        fld_len   := 7;
        fld_row   := 2;
        fld_col_start := 36;
        fld_editable := false;
        fld_color := NormColor;
        end;
      with scrn_fld_def[4] do
        begin
        fld_entry := 'A';
        fld_len   := 1;
        fld_row   := 4;
        fld_col_start := 1;
        fld_editable := false;
        fld_color := BriteColor;
        end;
      with scrn_fld_def[5] do
        begin
        fld_entry := 'Lesson Menu';
        fld_len   := 61;
        fld_row   := 4;
        fld_col_start := 4;
        fld_editable := false;
        fld_color := NormColor;
        end;
      with scrn_fld_def[6] do
        begin
        fld_entry := 'B';
        fld_len   := 1;
        fld_row   := 7;
        fld_col_start := 1;
        fld_editable := false;
        fld_color := BriteColor;
        end;
      with scrn_fld_def[7] do
        begin
        fld_entry := 'Display words';
        fld_len   := 61;
        fld_row   := 7;
        fld_col_start := 4;
        fld_editable := false;
        fld_color := NormColor;
        end;
      with scrn_fld_def[8] do
        begin
        fld_entry := 'C';
        fld_len   := 1;
        fld_row   := 8;
        fld_col_start := 1;
        fld_editable := false;
        fld_color := BriteColor;
        end;
      with scrn_fld_def[9] do
        begin
        fld_entry := 'Print words';
        fld_len   := 61;
        fld_row   := 8;
        fld_col_start := 4;
        fld_editable := false;
        fld_color := NormColor;
        end;
      with scrn_fld_def[10] do
        begin
        fld_entry := 'D';
        fld_len   := 1;
        fld_row   := 9;
        fld_col_start := 1;
        fld_editable := false;
        fld_color := BriteColor;
        end;
      with scrn_fld_def[11] do
        begin
        fld_entry := 'Edit word file';
        fld_len   := 61;
        fld_row   := 9;
        fld_col_start := 4;
        fld_editable := false;
        fld_color := NormColor;
        end;
      with scrn_fld_def[12] do
        begin
        fld_entry := 'E';
        fld_len   := 1;
        fld_row   := 10;
        fld_col_start := 1;
        fld_editable := false;
        fld_color := BriteColor;
        end;
      with scrn_fld_def[13] do
        begin
        fld_entry := 'Word lookup';
        fld_len   := 61;
        fld_row   := 10;
        fld_col_start := 4;
        fld_editable := false;
        fld_color := NormColor;
        end;
      with scrn_fld_def[14] do
        begin
        fld_entry := 'Set Options';
        fld_len   := 61;
        fld_row   := 12;
        fld_col_start := 4;
        fld_editable := false;
        fld_color := NormColor;
        end;
      with scrn_fld_def[15] do
        begin
        fld_entry := '1';
        fld_len   := 1;
        fld_row   := 13;
        fld_col_start := 7;
        fld_editable := false;
        fld_color := BriteColor;
        end;
      with scrn_fld_def[16] do
        begin
        fld_entry := 'Lesson Control Options';
        fld_len   := 61;
        fld_row   := 13;
        fld_col_start := 10;
        fld_editable := false;
        fld_color := NormColor;
        end;
      with scrn_fld_def[17] do
        begin
        fld_entry := '2';
        fld_len   := 1;
        fld_row   := 14;
        fld_col_start := 7;
        fld_editable := false;
        fld_color := BriteColor;
        end;
      with scrn_fld_def[18] do
        begin
        fld_entry := 'Change Session Type';
        fld_len   := 61;
        fld_row   := 14;
        fld_col_start := 10;
        fld_editable := false;
        fld_color := NormColor;
        end;
      with scrn_fld_def[19] do
        begin
        fld_entry := '3';
        fld_len   := 1;
        fld_row   := 15;
        fld_col_start := 7;
        fld_editable := false;
        fld_color := BriteColor;
        end;
      with scrn_fld_def[20] do
        begin
        fld_entry := 'Restart with all words in New Word pile';
        fld_len   := 61;
        fld_row   := 15;
        fld_col_start := 10;
        fld_editable := false;
        fld_color := NormColor;
        end;
      with scrn_fld_def[21] do
        begin
        fld_entry := '4';
        fld_len   := 1;
        fld_row   := 16;
        fld_col_start := 7;
        fld_editable := false;
        fld_color := BriteColor;
        end;
      with scrn_fld_def[22] do
        begin
        fld_entry :=
          'Reorder New Word Pile';
        fld_len   := 61;
        fld_row   := 16;
        fld_col_start := 10;
        fld_editable := false;
        fld_color := NormColor;
        end;
      {remove this entry}
      with scrn_fld_def[23] do
        begin
        fld_entry := '';
        fld_len   := 1;
        fld_row   := 16;
        fld_col_start := 72;
        fld_editable := false;
        fld_color := NormColor;
        end;
      with scrn_fld_def[24] do
        begin
        fld_entry := '5';
        fld_len   := 1;
        fld_row   := 17;
        fld_col_start := 7;
        fld_editable := false;
        fld_color := BriteColor;
        end;
      with scrn_fld_def[25] do
        begin
        fld_entry :=
            'Reorder Under Control Pile';
        fld_len   := 61;
        fld_row   := 17;
        fld_col_start := 10;
        fld_editable := false;
        fld_color := NormColor;
        end;
      {remove this entry}
      with scrn_fld_def[26] do
        begin
        fld_entry := '';
        fld_len   := 1;
        fld_row   := 17;
        fld_col_start := 72;
        fld_editable := false;
        fld_color := NormColor;
        end;
      with scrn_fld_def[27] do
        begin
        fld_entry := '6';
        fld_len   := 1;
        fld_row   := 18;
        fld_col_start := 7;
        fld_editable := false;
        fld_color := BriteColor;
        end;
      with scrn_fld_def[28] do
        begin
        fld_entry := 'Change screen colors';
        fld_len   := 61;
        fld_row   := 18;
        fld_col_start := 10;
        fld_editable := false;
        fld_color := NormColor;
        end;
      with scrn_fld_def[29] do
        begin
        fld_entry := '*';
        fld_len   := 1;
        fld_row   := 20;
        fld_col_start := 1;
        fld_editable := false;
        fld_color := BriteColor;
        end;
      with scrn_fld_def[30] do
        begin
        fld_entry := 'Exit LogFlash';
        fld_len   := 61;
        fld_row   := 20;
        fld_col_start := 4;
        fld_editable := false;
        fld_color := NormColor;
        end;
      with scrn_fld_def[31] do
        begin
        fld_entry := 'Select option (A-E, 1-6, *):';
        fld_len   := 28;
        fld_row   := 22;
        fld_col_start := 1;
        fld_editable := false;
        fld_color := NormColor;
        end;
      with scrn_fld_def[32] do
        begin
        fld_entry := '';
        fld_len   := 1;
        fld_row   := 22;
        fld_col_start := 30;
        fld_editable := true;
        fld_color := EntryColor;
        end;
      with scrn_fld_def[33] do
        begin
        fld_entry := '(TAB to change "Number in each lesson")';
        fld_len   := 39;
        fld_row   := 22;
        fld_col_start := 37;
        fld_editable := false;
        fld_color := NormColor;
        end;
      with scrn_fld_def[34] do
        begin
        fld_entry := WkErrMsg;
        fld_len   := 79;
        fld_row   := 23;
        fld_col_start := 1;
        fld_editable := false;
        if WkErrMsg = '' then
           fld_color := NormColor
        else
           fld_color := BriteColor;
        end;
      end;
  end;
{--------------------------------------------------------------------}
begin
  WkErrMsg := '';
  GETFDATA;
  str(HdrRec.NWperLess,WkNWperLessStr);
  str(HdrRec.NWperLess,WkUCperLessStr);
  repeat
     GETFDATA;
     str(HdrRec.NWperLess,WkNWperLessStr);
     str(HdrRec.NWperLess,WkUCperLessStr);
     if WkErrMsg > '' then
        scrn_misc_data.scrn_clrscrn := false
     else
        scrn_misc_data.scrn_clrscrn := true;
     q := ' ';
     FMT_MAIN_MENU;
     if first_selection = ' ' then
        begin
        LANGENTR(scrn_misc_data);
        if scrn_misc_data.scrn_hot_keyhit = 'aster' then
           quit := true;
        end;
     WkErrMsg := '';

     if (first_selection = ' ') and
        ((length(scrn_misc_data.scrn_fld_def[32].fld_entry) = 0) or
         (scrn_misc_data.scrn_fld_def[32].fld_entry = ' ')) then
        WkErrMsg := 'Please enter option: A-E, 1-6, or *'
     else
        begin
        if first_selection = ' ' then
           q := scrn_misc_data.scrn_fld_def[32].fld_entry[1]
        else
           begin
           q := first_selection;
           first_selection := ' ';
           end;
        q := upcase(q);
        case q of
             'A' : LF1DRIL;
             'B' : DISPLAY_WORDS('','','');  {dsply-type, dsply-order, startwd}
             'C' : DISPLAY_WORDS('print','','');
             'D' : LOOKUP_EDIT('edit');
             'E' : LOOKUP_EDIT('lookup');
             '1' : begin
                   CHG_OPTIONS;
                   str(HdrRec.NWperLess,WkNWperLessStr);
                   str(HdrRec.NWperLess,WkUCperLessStr);
                   end;
             '2' : CHGSESS;
             '3' : REGROUP_MENU(1);   {Reset file}
             '4' : REGROUP_MENU(2);   {reorder NW}
             '5' : REGROUP_MENU(3);   {reorder UC randomly}
             '6' : CHG_COLORS;
             '*' : quit := true;
            else
               WkErrMsg := 'Illegal Entry - Please enter A-E, 1-6, or *';
            end;
        end;
  until quit;
end;
