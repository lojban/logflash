{***********************************************************************}
{  COPYRIGHT 1986 - 1991                  by Nora and Bob LeChevalier         }
{************************************************************************}

procedure initvalues;
begin
     gs := 0;                            {init test score before all lessons}
     sc := 0;
     gt := 0;
     fillchar(blanklgwd,lgwdlen+1,' ');      {initialize to blank}
     fillchar(blanklgsup,lgsuplen+1,' ');    {initialize to blank}
     fillchar(blankenwd,enwdlen+1,' ');      {initialize to blank}
     fillchar(blankenclue,encluelen+1,' ');  {initialize to blank}
     fillchar(blankensup1,ensuplen1+1,' ');  {initialize to blank}
     fillchar(blankensup2,ensuplen2+1,' ');  {initialize to blank}
     fillchar(blankeloth,elothlen+1,' ');    {initialize to blank}
     blanklgwd[0]  := chr(lgwdlen);
     blanklgsup[0] := chr(lgsuplen);
     blankenwd[0]  := chr(enwdlen);
     blankenclue[0]  := chr(encluelen);
     blankensup1[0] := chr(ensuplen1);
     blankensup2[0] := chr(ensuplen2);
     blankeloth[0]  := chr(elothlen);
     checkaccent := true;                    {allow for accented letters}
     oldestset   := 0;                       {init oldest set und ctl wds}
     scrn_misc_data.scrn_clr_color := NormColor;
     release(heaporg); {release all heap (arr is on heap)}
     for i := 1 to arrsize do
         new(arr[i]);
end;
{************************************************************************}

function  FINDNEXTLESS(WkLast : integer) : integer;
  var
     WkNext : integer;
begin
     if (HdrRec.More4Less > 0) and (HdrRec.wdcnt[WkLast] > 0) then
        WkNext := WkLast
     else
        begin
        WkNext := LessChart[HdrRec.SessType,WkLast];
        if WkNext < WkLast then
           begin;
           NewSessCnt := NewSessCnt + 1;
           MOVE_ERRORS;
           end;
        if (HdrRec.SessNo < 8) and
           (WkNext = 1) and
           ( (HdrRec.wdcnt[3] > 0) or
             (HdrRec.wdcnt[4] > 0) or
             (HdrRec.wdcnt[5] > 0) or
             (HdrRec.wdcnt[6] > 0) or
             (HdrRec.wdcnt[7] > 0) or
             (HdrRec.wdcnt[8] > 0) or
             (HdrRec.wdcnt[9] > 0) or
             (HdrRec.wdcnt[10] > 0) or
             (HdrRec.wdcnt[11] > 0) or
             (HdrRec.wdcnt[12] > 0) or
             (HdrRec.wdcnt[13] > 0) or
             (HdrRec.wdcnt[14] > 0) ) then
           WkNext := 3;
        if (HdrRec.SessType = 1) and
           (WkNext = 1) and
           ( (HdrRec.wdcnt[9] > 0) or
             (HdrRec.wdcnt[10] > 0) or
             (HdrRec.wdcnt[11] > 0) or
             (HdrRec.wdcnt[12] > 0) or
             (HdrRec.wdcnt[13] > 0) or
             (HdrRec.wdcnt[14] > 0) ) then
           WkNext := 9;


        while ( ((HdrRec.SessType = 1) and (WkNext = 1)) or
                ((HdrRec.SessType = 1) and (WkNext = 2)) or
                ((WkNext > 12) and HdrRec.NWSkipOn) or
                (HdrRec.wdcnt[WkNext] = 0) )
          and ( NewSessCnt < 2 ) do
              WkNext := FINDNEXTLESS(WkNext);
        end;
     FINDNEXTLESS := WkNext;
end;

{************************************************************************}

procedure MOVE_WORDS;
begin

     {------Update header data-------------------------------------------}
     HdrRec.LastLess := ThisLess;
     with HdrRec do
        if ThisLess = 13 then               {NW less done, so decrease #left}
           NWBlkLeft := NWBlkLeft - 1;

     {------Update word detail data in arr[i]----------------------------}
     if odd(HdrRec.LastLess) then
        for i := 1 to nw do
           with arr[i]^,you do
              begin
              {---Hdr wd counts-----------------------------}
              HdrRec.wdcnt[HdrRec.LastLess] := HdrRec.wdcnt[HdrRec.LastLess] - 1;
              HdrRec.wdcnt[pii]      := HdrRec.wdcnt[pii] + 1;
              {---Dtl fields--------------------------------}
              fp := pii;
              if (HdrRec.LastLess = 1) and
                 (HdrRec.SessType <> 3) and
                 (fp = 1) then
                 {no change in ym - leave as is}
              else
                 ym := HdrRec.SessNo;
              if HdrRec.SessType <> 1 then
                 begin
                 {---Logging-------------------------------}
                 if fp = np then
                    if recallflag then
                       rcgd := rcgd + 1
                    else
                       rggd := rggd + 1
                 else
                    if recallflag then
                       rcerr := rcerr + 1
                    else
                       rgerr := rgerr + 1;
                 case HdrRec.LastLess of
                    1 : if ucs  = 0 then
                           ucs  := HdrRec.TrueSess;
                    3 : if rc1s = 0 then
                           rc1s := HdrRec.TrueSess;
                    5 : if rg3s = 0 then
                           rg3s := HdrRec.TrueSess;
                    7 : if rg2s = 0 then
                           rg2s := HdrRec.TrueSess;
                    9 : if rg1s = 0 then
                           rg1s := HdrRec.TrueSess;
                   13 : if nws  = 0 then
                           nws  := HdrRec.TrueSess;
                   end;
                 end;
              end;
end;

{************************************************************************}
procedure SEARCH_NDX(SearchWord    : string;
                    var DsplyData : dsplyptr;
                    var WdNo      : integer);
     var
        cnt   :  integer;
        InWord : enwdtype;
begin
     WdNo := 0;
     cnt  := 1;
     InWord := upcases(TRIM_FRONT(TRIM_TRAIL(SearchWord)));
     while (WdNo = 0) and (DsplyData^.DsplyWdNum[cnt] > 0) do
        begin
        if upcases(TRIM_TRAIL(DsplyData^.DsplyWd[cnt])) >= InWord then
           WdNo := cnt
        else
           cnt := cnt + 1;
        end;
     if WdNo = 0 then
        WdNo := cnt - 1;
end;
{************************************************************************}
procedure REDO_NDX;
     var
        DsplyData   :  dsplyptr;
     {-------------------------------------------------------------------}
     procedure SORTNDX(var DsplyData : dsplyptr);
        procedure sort(first,last: integer);
        var
          i,j       : integer;
          ix        : integer;
          WkWd      : enwdtype;
          WkWdNum   : integer;
          a         : enwdtype;
        begin
          i := first; j := last;
          a := upcases(DsplyData^.DsplyWd[(first + last) DIV 2]);
          repeat
            while upcases(DsplyData^.DsplyWd[i]) < a do
               i := i + 1;
            while a < upcases(DsplyData^.DsplyWd[j]) do
               j := j - 1;
            if i <= j then
            begin
              WkWd                     := DsplyData^.DsplyWd   [i];
              WkWdNum                  := DsplyData^.DsplyWdNum[i];
              DsplyData^.DsplyWd   [i] := DsplyData^.DsplyWd   [j];
              DsplyData^.DsplyWdNum[i] := DsplyData^.DsplyWdNum[j];
              DsplyData^.DsplyWd   [j] := WkWd;
              DsplyData^.DsplyWdNum[j] := WkWdNum;
              i := i + 1; j := j - 1;
            end;
          until i>j;
          if first < j then sort(first,j);
          if i < last then sort(i,last);
        end;

     begin {quicksort};
       sort(1,HdrRec.filenumwds);
     end;

     {-------------------------------------------------------------------}
begin
new(DsplyData);
GETNDX(DsplyData);
SORTNDX(DsplyData);
BUILDENGNDX(DsplyData);
release(heaporg); {release all heap (arr is on heap)}
end;
