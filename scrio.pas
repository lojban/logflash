unit scrio;
interface
Uses
  Crt, Dos;
type
    scrn_fld             =  record
        fld_row          :  integer;
        fld_col_start    :  integer;
        fld_entry        :  string[80];
        fld_len          :  integer;
        fld_color        :  integer;
        fld_editable     :  boolean;
        end;
    scrn_def               =  record
        extra_char       :  boolean;
        scrn_num_flds    :  integer;
        scrn_fld_def     :  array[1..65] of scrn_fld;
        scrn_clrscrn     :  boolean;
        scrn_clr_color   :  integer;
        curs_pos_fld     :  integer;
        scrn_hot_keys    :  array[1..10] of string[10];
        scrn_hotkey_cnt  :  integer;
        scrn_hot_keyhit  :  string[10];
        scrn_order       :  array[1..65] of integer;
        end;
var
   checkaccent : boolean;               {true-> use special proc'g for accents}

function  readchr(in_color : integer): char;
procedure quietread(var out1, out2 : char);
procedure scrn_init(var scrn_data: scrn_def);
procedure SCREENIO(var scrn_data: scrn_def);

implementation
{***********************************************************************}
{  COPYRIGHT 1986, 1987, 1988, 1989 by Nora and Bob LeChevalier         }
{***********************************************************************}
{***************************************************************************}
function readchr(in_color : integer): char;

var
  inchr : char;
  start_color : integer;
begin
     start_color := textattr;
     inchr := readkey;
     textattr := in_color;
     if inchr <> #0 then
        begin
        write(inchr);
        writeln;
        end;
     readchr := inchr;
     textattr := start_color;
end;
{***************************************************************************}
procedure quietread(var out1, out2 : char);

begin
     out1 := #0;
     out2 := #0;
     out1 := readkey;
     if out1 = #0 then
        out2 := readkey;
end;
{***************************************************************************}
 procedure scrn_init(var scrn_data: scrn_def);
   var
        ctr : integer;

     begin;
     with scrn_data do
        for ctr := 1 to scrn_num_flds do
           with scrn_fld_def[ctr] do
             if fld_editable then
                fld_entry := '';
     end;

{***************************************************************************}
 procedure SCREENIO(var scrn_data: scrn_def);
   const
       Accents     :  string[8] = '/\^:@%~_';
       FromChar    :  array[1..8] of string[10]
           = ( 'aeiouE','aeiou','aeiou','aeiouAOUy','aA','cC','nN','ao' );
       ToChar      :  array[1..8] of string[10]
           = ( ' ‚¡¢£','…Š•—','ƒˆŒ“–','„‰‹”Ž™š˜','†','‡€','¤¥','¦§' );
       HotKeyCnt   :  integer = 11;
       HotKeyNames :  array[1..11] of string[10] =
                      ( 'keyhelp', 'pgdn',   'pgup',    'aster',   'any',
                        'exit'   , 'keyhelp', 'top',    'bottom',  'pound',
                        'aster');

                      { #-hotkeys, 2-keys/hotkey }
       HotKeyList  :  array[1..11,1..2] of char =
                      ( (#0, #59), (#0,#81), (#0,#73),  ('*',#0),  (#0,#0),
                        (#0, #16), (#0,#35), (#0,#132), (#0,#118), ('#',#0),
                        (#27,#00)  );
label
     alldone;
   var
       AccentType             :     integer;
       at_end                 :     boolean;
       beyond_end             :     boolean;
       blankline              :     string[80];
       ctr                    :     integer;
       CharPos                :     integer;
       done                   :     boolean;
       insert_mode            :     boolean;
       key1                   :     char;
       key2                   :     char;
       start_color            :     integer;
       there_are_editables    :     boolean;
       this_item              :     integer;
       this_char              :     integer;
       this_col               :     integer;
       this_color             :     integer;
       this_row               :     integer;
       trail_blanks           :     integer;
       wk_entry               :     string[80];
       wk_order               :     array[1..100] of integer;
       WkToChar               :     string[10];
       WkChar                 :     char;

       procedure check_hot_keys;
        var
           wkavail  :  integer;
           wkused   :  integer;
        begin
          scrn_data.scrn_hot_keyhit := '';
          if (key1 = #0) and (key2 = #0) then
             {no action}
          else
          for wkused := 1 to scrn_data.scrn_hotkey_cnt do
            if scrn_data.scrn_hot_keyhit = '' then
               if scrn_data.scrn_hot_keys[wkused] = 'any' then
                  scrn_data.scrn_hot_keyhit := scrn_data.scrn_hot_keys[wkused]
               else
               for wkavail := 1 to HotKeyCnt do
                    if (HotKeyNames[wkavail] = scrn_data.scrn_hot_keys[wkused])
                       and (scrn_data.scrn_hot_keyhit = '')
                       and (HotKeyList[wkavail,1] = key1)
                       and (HotKeyList[wkavail,2] = key2)   then
                      scrn_data.scrn_hot_keyhit :=
                               scrn_data.scrn_hot_keys[wkused];
        end;

       procedure previous_item;
        begin
        with scrn_data do
        begin
           repeat
              if this_item > 1 then
                 this_item := this_item - 1
              else
                 this_item := scrn_num_flds;
           until scrn_fld_def[wk_order[this_item]].fld_editable;
           with scrn_fld_def[wk_order[this_item]] do
           begin
           this_row := fld_row;
           textattr := fld_color;
           if this_char > length(fld_entry) then
              this_char := length(fld_entry) + 1;
           if this_char > fld_len then
              if extra_char then
                 this_char := fld_len + 1
              else
                 this_char := fld_len;
           this_col := fld_col_start + this_char - 1;
           end;
        end;
        end;

       procedure next_item;
        begin
        with scrn_data do
        begin
           repeat
              if this_item < scrn_num_flds then
                 this_item := this_item + 1
              else
                 this_item := 1;
           until scrn_fld_def[wk_order[this_item]].fld_editable;
           with scrn_fld_def[wk_order[this_item]] do
           begin
           this_row := fld_row;
           textattr := fld_color;
           if this_char > length(fld_entry) then
              this_char := length(fld_entry) + 1;
           if this_char > fld_len then
              if extra_char then
                 this_char := fld_len + 1
              else
                 this_char := fld_len;
           this_col := fld_col_start + this_char - 1;
           end;
        end;
        end;

       procedure previous_line;
       {Item with nearest previous line; if more than one field on that line, }
       {   take the one with the nearest previous-or-equal column start       }
       {Only editable fields considered.                                      }
       {Cursor position on same screen column or end-of-entry                 }
        var
          AnsItem :  integer;
          AnsRow  :  integer;
          AnsCol  :  integer;
          WkItem  :  integer;
          WkPos   :  integer;
        begin
        with scrn_data do
           begin
           AnsItem := 0;
           AnsRow  := 0;
           AnsCol  := 0;
           for WkItem := 1 to scrn_num_flds do
             if scrn_fld_def[wk_order[WkItem]].fld_editable
                and (scrn_fld_def[wk_order[WkItem]].fld_row
                    < scrn_fld_def[wk_order[this_item]].fld_row) then
                if (scrn_fld_def[wk_order[WkItem]].fld_row > AnsRow) then
                   begin
                   AnsRow := scrn_fld_def[wk_order[WkItem]].fld_row;
                   AnsCol := scrn_fld_def[wk_order[WkItem]].fld_col_start;
                   AnsItem := WkItem;
                   end
                else
                if (scrn_fld_def[wk_order[WkItem]].fld_row = AnsRow)
                   and (scrn_fld_def[wk_order[WkItem]].fld_col_start
                       <= scrn_fld_def[wk_order[this_item]].fld_col_start)
                   and (scrn_fld_def[wk_order[WkItem]].fld_row > AnsCol) then
                   begin
                   AnsRow := scrn_fld_def[wk_order[WkItem]].fld_row;
                   AnsCol := scrn_fld_def[wk_order[WkItem]].fld_col_start;
                   AnsItem := WkItem;
                   end;
           if AnsItem > 0 then
              begin
              WkPos := scrn_fld_def[wk_order[this_item]].fld_col_start + this_char - 1;
              this_item := AnsItem;
              with scrn_fld_def[wk_order[this_item]] do
                 begin
                 this_row := fld_row;
                 textattr := fld_color;
                 {screen pos after end of new field}
                 if WkPos > (length(fld_entry) + fld_col_start - 1) then
                    this_char := length(fld_entry) + 1
                 else
                 {screen pos before beginning of new field}
                 if WkPos < (fld_col_start) then
                    this_char := 1
                 else
                 {screen pos inside new field}
                    this_char := WkPos - fld_col_start + 1;
                 if this_char > fld_len then
                    if extra_char then
                       this_char := fld_len + 1
                    else
                       this_char := fld_len;
                 this_col := fld_col_start + this_char - 1;
                 end;
              end;
           end;
        end;

       procedure next_line;
       {Item with next nearest line; if more than one field on that line,     }
       {   take the one with the nearest previous-or-equal column start       }
       {Only editable fields considered.                                      }
       {Cursor position on column 1 always                                    }
        var
          AnsItem :  integer;
          AnsRow  :  integer;
          AnsCol  :  integer;
          WkItem  :  integer;
          WkPos   :  integer;
        begin
        with scrn_data do
        begin
           AnsItem := 0;
           AnsRow  := 9999;
           AnsCol  := 0;

           for WkItem := 1 to scrn_num_flds do
             if scrn_fld_def[wk_order[WkItem]].fld_editable
                and (scrn_fld_def[wk_order[WkItem]].fld_row
                    > scrn_fld_def[wk_order[this_item]].fld_row) then
                if (scrn_fld_def[wk_order[WkItem]].fld_row < AnsRow) then
                   begin
                   AnsRow := scrn_fld_def[wk_order[WkItem]].fld_row;
                   AnsCol := scrn_fld_def[wk_order[WkItem]].fld_col_start;
                   AnsItem := WkItem;
                   end
                else
                if (scrn_fld_def[wk_order[WkItem]].fld_row = AnsRow)
                   and (scrn_fld_def[wk_order[WkItem]].fld_col_start
                       <= scrn_fld_def[wk_order[this_item]].fld_col_start)
                   and (scrn_fld_def[wk_order[WkItem]].fld_row > AnsCol) then
                   begin
                   AnsRow := scrn_fld_def[wk_order[WkItem]].fld_row;
                   AnsCol := scrn_fld_def[wk_order[WkItem]].fld_col_start;
                   AnsItem := WkItem;
                   end;
           if AnsItem > 0 then
              begin
              WkPos := scrn_fld_def[wk_order[this_item]].fld_col_start + this_char - 1;
              this_item := AnsItem;
              with scrn_fld_def[wk_order[this_item]] do
                 begin
                 this_row := fld_row;
                 textattr := fld_color;
                 {screen pos after end of new field}
                 if WkPos > (length(fld_entry) + fld_col_start - 1) then
                    this_char := length(fld_entry) + 1
                 else
                 {screen pos before beginning of new field}
                 if WkPos < (fld_col_start) then
                    this_char := 1
                 else
                 {screen pos inside new field}
                    this_char := WkPos - fld_col_start + 1;
                 if this_char > fld_len then
                    if extra_char then
                       this_char := fld_len + 1
                    else
                       this_char := fld_len;
                 this_col := fld_col_start + this_char - 1;
                 end;
              end;
           end;
        end;

       procedure end_of_line;
        begin
           with scrn_data, scrn_fld_def[wk_order[this_item]] do
              begin
              if length(fld_entry) < fld_len then
                 this_char := length(fld_entry) + 1
              else
                 if extra_char then
                    this_char := fld_len + 1
                 else
                    this_char := fld_len;
              this_col := fld_col_start + this_char - 1;
              end;
        end;

       procedure move_left;
        begin
          if this_char > 1 then
             this_char := this_char - 1
          else
             begin
             previous_item;
             end_of_line;
             end;
           with scrn_data, scrn_fld_def[wk_order[this_item]] do
              this_col := fld_col_start + this_char - 1;
        end;

       procedure move_right;
        begin
           with scrn_data, scrn_fld_def[wk_order[this_item]] do
              if (this_char > length(fld_entry)) then
                 at_end := true
              else
                 if extra_char then
                    if (this_char > fld_len) then
                       at_end := true
                    else
                       at_end := false
                 else
                    if (this_char > fld_len - 1) then
                       at_end := true
                    else
                       at_end := false;
           if at_end then
              begin
              this_char := 1;
              next_item;
              end
           else
              this_char := this_char + 1;
           with scrn_data, scrn_fld_def[wk_order[this_item]] do
              this_col := fld_col_start + this_char - 1;
        end;

     begin
        fillchar(blankline,81,' ');    {initialize to blank}
        blankline[0]  := chr(80);
        start_color := textattr;
        if scrn_data.scrn_clrscrn then
           begin
           textattr := scrn_data.scrn_clr_color;
           clrscr;
           end;
        there_are_editables := false;

        {* SCREEN ORDER default to field order *}
        for this_item := 1 to scrn_data.scrn_num_flds do
            if scrn_data.scrn_order[1] = 0 then
               wk_order[this_item] := this_item
            else
               wk_order[this_item] := scrn_data.scrn_order[this_item];

        {* SCREEN DISPLAY *}
        for this_item := 1 to scrn_data.scrn_num_flds do
           with scrn_data, scrn_fld_def[wk_order[this_item]] do
              begin
              trail_blanks := fld_len - length(fld_entry);
              wk_entry := fld_entry + copy(blankline, 1, trail_blanks);
              gotoxy(fld_col_start,fld_row);
              textattr := fld_color;
              write(wk_entry);
              if fld_editable then
                 there_are_editables := true;
              end;

        {* SCREEN RECEIVE *}
        insert_mode := false;
        if there_are_editables then
           begin
           if (scrn_data.curs_pos_fld > 0) and
              scrn_data.scrn_fld_def[scrn_data.curs_pos_fld].fld_editable then
              begin
              done := false;
              this_item := 0;
              repeat
                this_item := this_item + 1
              until (wk_order[this_item] = scrn_data.curs_pos_fld) or
                    (this_item >= scrn_data.scrn_num_flds);
              end
           else
              begin
              done := false;
              this_item := 0;
              repeat
                 this_item := this_item + 1;
              until scrn_data.scrn_fld_def[wk_order[this_item]].fld_editable;
              end;
           this_char := 1;
           with scrn_data, scrn_fld_def[wk_order[this_item]] do
              begin
                 this_col := fld_col_start;
                 this_row := fld_row;
                 textattr := fld_color;
              end;
           gotoxy(this_col,this_row);
           end
        else
           begin
           done := true;
           if scrn_data.curs_pos_fld > 0 then
              this_item := scrn_data.curs_pos_fld
           else
              this_item := scrn_data.scrn_num_flds;
           with scrn_data, scrn_fld_def[wk_order[this_item]] do
              begin
                 this_col := fld_col_start;
                 this_row := fld_row;
                 textattr := fld_color;
              end;
           gotoxy(this_col,this_row);
           goto alldone;
           end;
        repeat
         quietread(key1,key2);
         scrn_data.scrn_hot_keyhit := '';
         if scrn_data.scrn_hotkey_cnt > 0 then
            check_hot_keys;
         if scrn_data.scrn_hot_keyhit > '' then
            done := true
         else
           case ord(key1) of
     {2keycd} 0:
                 case ord(key2) of
     {backtab}   15:  begin;
                       previous_item;
                       this_char := 1;
                       with scrn_data, scrn_fld_def[wk_order[this_item]] do
                          this_col := fld_col_start;
                       gotoxy(this_col,this_row);
                       end;
     {insert}    82:  begin;
                       this_color := textattr;
                       textattr := scrn_data.scrn_clr_color;
                       if insert_mode then
                          begin
                          insert_mode := false;
                          gotoxy(60,24);
                          write('   ');
                          gotoxy(this_col,this_row);
                          end
                       else
                          begin
                          insert_mode := true;
                          gotoxy(60,24);
                          write('INS');
                          gotoxy(this_col,this_row);
                          end;
                       textattr   := this_color;
                       end;
     {delete}     83:  begin;
                        with scrn_data, scrn_fld_def[wk_order[this_item]] do
                        begin
                         delete(fld_entry,this_char,1);
                         for ctr := this_char to fld_len do
                            if ctr > length(fld_entry) then
                               write(' ')
                            else write(fld_entry[ctr]);
                        end;
                       gotoxy(this_col,this_row);
                       end;
     {up}         72:  begin;
                       previous_line;
                       gotoxy(this_col,this_row);
                       end;
     {down}       80:  begin;
                       next_line;
                       gotoxy(this_col,this_row);
                       end;
     {left}       75:  begin;
                       move_left;
                       gotoxy(this_col,this_row);
                       end;
     {right}      77:  begin;
                       move_right;
                       gotoxy(this_col,this_row);
                       end;
     {home}       71:  begin;
                       this_char := 1;
                       with scrn_data, scrn_fld_def[wk_order[this_item]] do
                          this_col := fld_col_start;
                       gotoxy(this_col,this_row);
                       end;
     {end}        79:  begin;
                       end_of_line;
                       gotoxy(this_col,this_row);
                       end;
     {ctrl-left} 115:  with scrn_data do               {prev word}
                       if this_char > 1 then
                       begin
                       repeat
                          move_left;
                       until (this_char = 1) or
                       ((scrn_fld_def[wk_order[this_item]].fld_entry[this_char - 1] = ' ')
                       and
                       (scrn_fld_def[wk_order[this_item]].fld_entry[this_char] <> ' '));
                       gotoxy(this_col,this_row);
                       end;
     {ctrl-rght} 116:  with scrn_data do               {prev word}
                       if (this_char <=
                             length(scrn_fld_def[wk_order[this_item]].fld_entry)) then
                       begin
                       repeat
                          move_right;
                       until (this_char > length(scrn_fld_def[wk_order[this_item]].fld_entry))
                          or ((scrn_fld_def[wk_order[this_item]].fld_entry[this_char - 1] = ' ')
                             and
                              (scrn_fld_def[wk_order[this_item]].fld_entry[this_char] <> ' '));
                       gotoxy(this_col,this_row);
                       end;
     {ctrl-end}  117:  begin;
                       with scrn_data, scrn_fld_def[wk_order[this_item]] do
                          begin;
                          if this_char <= length(fld_entry) then
                             delete(fld_entry,this_char,
                                    length(fld_entry) - this_char + 1);
                          for ctr := this_char to fld_len do
                             write(' ');
                          end;
                       gotoxy(this_col,this_row);
                       end;
                 end; {case for key2}
     {enter}  13: begin
                  done := true;
                  textattr := scrn_data.scrn_clr_color;
                  if insert_mode then
                     begin
                     insert_mode := false;
                     gotoxy(60,24);
                     write('   ');
                     gotoxy(this_col,this_row);
                     end;
                  end;
     {backsp}  8: begin;
                  if (this_char = 1) and scrn_data.extra_char then
                     write(^G)   {beep}
                  else
                    begin
                    move_left;
                    with scrn_data, scrn_fld_def[wk_order[this_item]] do
                       begin
                        if (this_char > length(fld_entry)) and
                           (length(fld_entry) > 0) then
                            move_left;
                        if length(fld_entry) > 0 then
                          begin
                          delete(fld_entry,this_char,1);
                          gotoxy(this_col,this_row);
                          for ctr := this_char to fld_len do
                             if ctr > length(fld_entry) then
                                write(' ')
                             else write(fld_entry[ctr]);
                          end;
                       end;
                    end;
                  gotoxy(this_col,this_row);
                  end;
     {tab}     9: begin;
                  next_item;
                  this_char := 1;
                  with scrn_data, scrn_fld_def[wk_order[this_item]] do
                     this_col := fld_col_start;
                  gotoxy(this_col,this_row);
                  end;
     {key}   else begin; {regular key}
                  if CheckAccent then
                     AccentType := pos(key1,Accents)
                  else AccentType := 0;
                  if AccentType = 0 then
                    begin;
                    if insert_mode then
                       begin
                       with scrn_data, scrn_fld_def[wk_order[this_item]] do
                          if this_char > fld_len then
                             beyond_end := true
                          else
                             begin;
                             insert(key1,fld_entry,this_char);
                             if length(fld_entry) > fld_len then
                                delete(fld_entry,fld_len + 1, 1);
                             for ctr := this_char to fld_len do
                                if ctr > length(fld_entry) then
                                   write(' ')
                                else write(fld_entry[ctr]);
                             beyond_end := false;
                             end;
                       if beyond_end then
                          write(^G)   {beep}
                       else
                          move_right;
                       end
                    else
                       begin
                       with scrn_data, scrn_fld_def[wk_order[this_item]] do
                          if this_char > fld_len then
                             beyond_end := true
                          else
                             begin
                             beyond_end := false;
                             if this_char > length(fld_entry) then
                                fld_entry := fld_entry + key1
                             else fld_entry[this_char] := key1;
                             write(key1);
                             end;
                       if beyond_end then
                          write(^G)   {beep}
                       else
                          move_right;
                       end;
                    gotoxy(this_col,this_row);
                    end  {end accent-type=0}
                  else
                    begin; {accent-type > 0}
                    if scrn_data.extra_char and (this_char < 2) then
                       write(^G)   {beep}
                    else
                       begin
                       move_left;
                       with scrn_data, scrn_fld_def[wk_order[this_item]] do
                          CharPos := pos(fld_entry[this_char],
                                         FromChar[AccentType]);
                       if CharPos > 0 then
                          begin
                          WkToChar := ToChar[AccentType];
                          WkChar := WkToChar[CharPos];
                          with scrn_data, scrn_fld_def[wk_order[this_item]] do
                             fld_entry[this_char] := WkChar;
                          gotoxy(this_col,this_row);
                          write(WkChar);
                          move_right;
                          gotoxy(this_col,this_row);
                          end
                       else
                          begin
                          write(^G); {beep}
                          move_right;
                          gotoxy(this_col,this_row);
                          end;
                       end;
                    end; {end accent-type <> 0}
                  end; {regular char; "other" for key1}
           end; {case}
        until done;
  alldone:
        textattr := start_color;
     end;

end.
