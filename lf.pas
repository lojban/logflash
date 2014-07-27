{$R-}    {Range checking off}
{$B+}    {Boolean complete evaluation on}
{$S+}    {Stack checking on}
{$I+}    {I/O checking on}
{$N-}    {No numeric coprocessor}
{$M 65500,16384,655360} {Turbo 3 default stack and heap}

{***********************************************************************}
{  COPYRIGHT 1986 - 1991            by Nora and Bob LeChevalier         }
{***********************************************************************}
{      THIS PROGRAM WILL HALT PREMATURELY FOR ANY FILE I/O ERRORS       }
{           where "fileio" procedure is called.                         }
{***********************************************************************}
program LOGFLASH;
{$V-}

{***************************************************************************}

Uses
  Crt, Dos,
  scrio;


{$I lf1vars.pas}
     f1 : string[30]; {your name, for file name building}
     quit : boolean;
     system_color : integer;    {to save & reset before leaving program}
{***************************************************************************}
{$I lf1strg.pas}
{***************************************************************************}
{$I langio.pas}
{***************************************************************************}
{$I lf1scrns.pas}
{************************************************************************}
{$I lf1files.pas}
{************************************************************************}
{$I lf1gen.pas}
{************************************************************************}
{$I lf1less.pas}
{************************************************************************}
{$I lf1cntl.pas}
{************************************************************************}
{$I lf1bld.pas}
{************************************************************************}
{$I lf1dril.pas}
{************************************************************************}
{$I lf1main.pas}
{************************************************************************}

{------------------------------------------------------------------------}
  procedure COPYRIGHT;
    const
       Copyright_Line : array[1..13] of string[80] =
      ('*********************************************************************',
       '                LOGFLASH 1:  LOJBAN LEARNING - gismu                 ',
       '                     Revision 7: June, 1991                          ',
       '*********************************************************************',
       '*                    Copyright 1986 to 1991 by:                     *',
       '*     Nora & Bob LeChevalier, 2904 Beau Lane, Fairfax VA 22031      *',
       '*                   ($20 contribution requested)                    *',
       '*                                                                   *',
       '* Permission is granted to make and distribute copies of this       *',
       '* program provided the copyright notice and this permission notice  *',
       '* are preserved on all copies.                                      *',
       '*                                                                   *',
       '*********************************************************************');
     var
       WkLine1   :  integer;
  begin
  with scrn_misc_data do
     begin
     extra_char    := true;
     scrn_num_flds := 13;
     scrn_order[1] := 0;
     scrn_clrscrn  := true;
     scrn_clr_color := DefaultColor;
     curs_pos_fld  := 0;
     for WkLine1 := 1 to 13 do
        with scrn_fld_def[WkLine1] do
          begin
          fld_entry := Copyright_Line[WkLine1];
          fld_len   := 72;
          fld_row   := WkLine1;
          fld_col_start := 5;
          fld_editable := false;
          fld_color := DefaultColor;
        end;
     end;
  end;
{------------------------------------------------------------------------}
  procedure GET_FILE_NAME;
  var
      DummySearch : SearchRec;
    begin
    with scrn_misc_data do
       begin
       extra_char    := true;
       scrn_num_flds := 5;
       scrn_order[1] := 0;
       scrn_clr_color := DefaultColor;
       curs_pos_fld  := 0;
       {------name------------------------------}
       with scrn_fld_def[1] do
         begin
         fld_entry := 'Enter your name (7 characters maximum): ';
         fld_len   := 40;
         fld_row   := 16;
         fld_col_start := 1;
         fld_editable := false;
         fld_color := DefaultColor;
         end;
       with scrn_fld_def[2] do
          begin
          fld_entry := f1;
          fld_len   := 7;
          fld_row   := 16;
          fld_col_start := 41;
          fld_editable := true;
          fld_color := DefaultEntryColor;
          end;
       {------drive-----------------------------}
       with scrn_fld_def[3] do
         begin
         fld_entry := 'What drive for your lesson data (blank for default drive)? : ';
         fld_len   := 61;
         fld_row   := 18;
         fld_col_start := 1;
         fld_editable := false;
         fld_color := DefaultColor;
         end;
       with scrn_fld_def[4] do
          begin
          fld_entry := fdrv;
          fld_len   := 1;
          fld_row   := 18;
          fld_col_start := 62;
          fld_editable := true;
          fld_color := DefaultEntryColor;
          end;
       {------general instructions----------------------------------------}
       with scrn_fld_def[5] do
         begin
         fld_entry := 'TABs, ARROWs to move; "*" to cancel; hit ENTER when done.';
         fld_len   := 80;
         fld_row   := 20;
         fld_col_start := 1;
         fld_editable := false;
         fld_color := DefaultColor;
         end;
       scrn_hotkey_cnt := 1;
       scrn_hot_keys[1] := 'aster';
       scrn_hot_keyhit  := '';
       end; {with scrn_misc_data}

    if q = ' ' then
       LANGENTR(scrn_misc_data);
    if scrn_misc_data.scrn_hot_keyhit = 'aster' then
       quit := true
    else
       begin
       f1   := TRIM_TRAIL(scrn_misc_data.scrn_fld_def[2].fld_entry);
       fdrv := scrn_misc_data.scrn_fld_def[4].fld_entry;
       if (f1 = '')
          then f := 'noname' + yoursuff
          else f := f1 + yoursuff;
       if (fdrv > ' ') then
          f := fdrv + ':' + f;

       {---set up history file name------------}
       if (f1 = '')
          then histfname := 'noname' + histsuff
          else histfname := f1 + histsuff;
       if (fdrv > ' ') then
          histfname := fdrv + ':' + histfname;

       {---check if file exists----------------}
       FindFirst(f,AnyFile,DummySearch);
       if DosError <> 0 then
          LF1BLD;
          scrn_misc_data.scrn_clrscrn  := true;
       end;
    end;
{********  MAIN  PROGRAM  ***********************************************}
begin

   NormColor := DefaultColor;
   EntryColor := DefaultEntryColor;
   BriteColor := DefaultBriteColor;
   checkbreak := true;
   system_color := textattr;
   fillchar(blankline,81,' ');
   blankline[0] := chr(80);
   scrn_misc_data.scrn_hot_keyhit := '';
   scrn_misc_data.scrn_order[1] := 0;
   COPYRIGHT;
   LANGENTR(scrn_misc_data);
   f := '';
   if paramcount > 0 then
     begin
     f1 := copy(paramstr(1),1,7);
     q := 'A';
     delay(2000);
     end
   else
     begin
     f1 := '';
     q := ' ';
     end;
   fdrv := '';
   quit := false;
   scrn_misc_data.scrn_clrscrn  := false;
   repeat
     GET_FILE_NAME;
   until (quit) or (f > '');
   if not quit then
      if paramcount > 0 then
         MAIN_MENU(q)
      else
         MAIN_MENU(q);
   textattr := system_color;
   clrscr;
end.
