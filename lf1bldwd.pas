{$R-}    {Range checking off}
{$B+}    {Boolean complete evaluation on}
{$S+}    {Stack checking on}
{$I+}    {I/O checking on}
{$N-}    {No numeric coprocessor}
{$M 65500,16384,655360} {Turbo 3 default stack and heap}

program LF1BLDWD;
{$V-}
{***********************************************************************}
{  COPYRIGHT 1986 - 1991                   by Nora and Bob LeChevalier  }
{***********************************************************************}
{************************************************************************}

Uses
  Crt, Dos, scrio;

{************************************************************************}
{$I lf1vars.pas}

{$I lf1varix.pas}
  type
     NdxPtr  = ^AlphaNdxItem;
     NdxArray = array[1..2500] of NdxPtr;
  var
     EngNdxArray : NdxArray;
     LgNdxArray  : NdxArray;
     rawfile : text;
     ix      : integer;
{************************************************************************}
{$I langio.pas}
{************************************************************************}
{$I lf1strg.pas}
{************************************************************************}

procedure initvalues;
begin
     fillchar(blanklgwd,lgwdlen+1,' ');      {initialize to blank}
     fillchar(blanklgsup,lgsuplen+1,' ');    {initialize to blank}
     fillchar(blankenwd,enwdlen+1,' ');      {initialize to blank}
     fillchar(blankenclue,encluelen+1,' ');  {initialize to blank}
     fillchar(blankensup1,ensuplen1+1,' ');  {initialize to blank}
     fillchar(blankensup2,ensuplen2+1,' ');  {initialize to blank}
     fillchar(blankeloth,elothlen+1,' ');    {initialize to blank}
     blanklgwd[0]   := chr(lgwdlen);
     blanklgsup[0]  := chr(lgsuplen);
     blankenwd[0]   := chr(enwdlen);
     blankenclue[0] := chr(encluelen);
     blankensup1[0] := chr(ensuplen1);
     blankensup2[0] := chr(ensuplen2);
     blankeloth[0]  := chr(elothlen);
end;
{************************************************************************}

procedure BUILDHDR(rawrec : string);  {set common header data}

var
   dummy : integer;
   xx    : integer;

begin
     val(copy(rawrec,1,5),xx,dummy); {make # entries (rcds) in file to integer;
                                      excludes this record in count}
     fillchar(wordrec,512,0);
     with wordrec do                     {set up for initial session}
          begin
          filelang := copy(rawrec,7,15);
          numwds := xx;              {# wds on file. If wrong, will get
                                          fixed later}
          numrcds := trunc(xx/subperwdrec) + 1;  {number of records =
                                           # of wds/wds per record +
                                           1 control}
          if (xx > (trunc(xx/subperwdrec) * subperwdrec))
             then numrcds := numrcds + 1;    {add 1 if extra records}
          comments := copy(rawrec,22,59);
          end;
end;

{************************************************************************}

procedure BREAKSUPP(WkEngSup : string; var out1, out2: string);
 var
    Min1stLine : integer;
    Max1stLine : integer;
    WkStr      : string[96];
    BrkPos     : integer;
    BrkType    : string[10];
    WkPos      : integer;
begin
    WkStr := TRIM_TRAIL(WkEngSup);
    Min1stLine := Length(WkStr) - ensuplen2;
    Max1stLine := Length(WkStr);
    if ensuplen1 < Max1stLine then
       Max1stLine := ensuplen1;

    {----Break at end, if possible----------------------------}
    BrkPos := 0;
    if length(WkStr) <= ensuplen1 then
       begin
       BrkPos := length(WkStr);
       BrkType := 'whole';
       end;

    {----Break at space, if possible--------------------------}
    if BrkPos = 0 then
       for WkPos := Max1stLine + 1 downto Min1stLine do
           if BrkPos = 0 then
              if WkStr[WkPos] = ' ' then
                 begin
                 BrkPos := WkPos;
                 BrkType := 'space';
                 end;

    {----Break after / if cannot break at space---------------}
    if BrkPos = 0 then
       for WkPos := Max1stLine downto Min1stLine do
           if BrkPos = 0 then
              if WkStr[WkPos] = '/' then
                 begin
                 BrkPos := WkPos;
                 BrkType := 'slash';
                 end;

    {----Otherwise, Force break anywhere----------------------}
    if BrkPos = 0 then
       begin
       write(wordrec.words[j].lg,' ');
       BrkPos := Max1stLine - 1;
       BrkType := 'hyphen';
       end;

    if BrkType = 'whole' then
       begin
       out1 := copy(WkStr,1,BrkPos);
       out2 := '';
       end
    else
    if BrkType = 'space' then
       begin
       out1 := copy(WkStr,1,BrkPos - 1);
       out2 := copy(WkStr,(BrkPos + 1),length(WkStr));
       end
    else
    if BrkType = 'slash' then
       begin
       out1 := copy(WkStr,1,BrkPos);
       out2 := copy(WkStr,(BrkPos + 1),length(WkStr));
       end
    else
    if BrkType = 'hyphen' then
       begin
       out1 := copy(WkStr,1,BrkPos) + '-';
       out2 := copy(WkStr,(BrkPos + 1),length(WkStr));
       end
    else
       writeln('******** awful error in BREAKSUPP *********');
end;
{************************************************************************}

procedure BUILDWD(rawrec : string);  {build 1 word onto random access file}
  const
     WkEnsuplen : integer = 96;
  var
     WkPos : integer;  {starting position of data in raw file}
     WkEngSup : string[96];

begin
     with wordrec,words[j] do
        begin
        rawrec := rawrec
          + '                                                               ';
        { One space is expected between fields on raw data file. }
        WkPos := 1;
        lg := copy(rawrec,WkPos,lgwdlen);
        WkPos := WkPos + lgwdlen + 1;
        lgs := copy(rawrec,WkPos,lgsuplen);
        WkPos := WkPos + lgsuplen + 1;
        en  := copy(rawrec,WkPos,enwdlen);
        WkPos := WkPos + enwdlen + 1;
        ec  := copy(rawrec,WkPos,encluelen);
        WkPos := WkPos + encluelen + 1;

        {----break Eng Suppl into 2 peices------------}

        WkEngSup := copy(rawrec,WkPos,WkEnsuplen);
        BREAKSUPP(WkEngSup,es1,es2);

        WkPos := WkPos + WkEnsuplen + 1;
        elother := copy(rawrec,WkPos,elothlen);
        end;
end;

{************************************************************************}

procedure CLEARWDS; {clear empty array items}

begin
     if (j > 1) then                     {unwritten record}
        if j < subperwdrec then                    {incomplete record}
           begin
           for i := j to subperwdrec do    {pad record out before writing it}
              begin
              with wordrec,words[i] do
                 begin
                 lg  := blanklgwd;
                 lgs := blanklgsup;
                 en  := blankenwd;
                 ec  := blankenclue;
                 es1 := blankensup1;
                 es2 := blankensup2;
                 elother := blankeloth;
                 end;                    {other fields are 0 due to prefill}
              end;
           end;
end;

{************************************************************************}
procedure ADDNDX(wdno, subrec : integer);
begin
   new(EngNdxArray[i]);
   EngNdxArray[i]^.NdxWord  := TRIM_TRAIL(wordrec.words[j].en);
   EngNdxArray[i]^.NdxRecNo := i;

   new(LgNdxArray[i]);
   LgNdxArray[i]^.NdxWord   := TRIM_TRAIL(wordrec.words[j].lg);
   LgNdxArray[i]^.NdxRecNo  := i;
end;
{************************************************************************}

procedure BUILDFIL;       {control building of word file}

   const
      fraw : string[80] = 'logdata.raw';
   var
      rawrec : string[255];
begin
     {----open----------------------------------------------------------}
     {$I-} assign(rawfile,fraw); {$I+} fileio;     {open raw text file}
     {$I-} reset(rawfile); {$I+} fileio;
     {$I-} readln(rawfile,rawrec); {$I+} fileio;             {read control record}

     {$I-} assign(wordfile,wordfname); {$I+} fileio; {open wd data access file}
     {$I-} rewrite(wordfile); {$I+} fileio;

     {----build wd header rec-------------------------------------------}
     val(copy(rawrec,1,5),ix,dummy); {chg # entries (rcds) in file to integer;
                                      excludes this record in count}
     BUILDHDR(rawrec);
     {$I-} write(wordfile,wordrec); {$I+} fileio;   {write control record}

     {----build wd detail recs------------------------------------------}
     j := 1;                        {counts 1 to subperrec to pack wordfile}
     fillchar(wordrec,512,0);
     for i := 1 to ix do                 {step through raw file}
         begin
         {$I-} readln(rawfile,rawrec); {$I+} fileio;    {get raw record}
         BUILDWD(rawrec);
         ADDNDX(i,j);                    {add item to Eng & Lg indexes}
         j := j + 1;                     {increment pointer in record}
         if (j > subperwdrec) then                 {record full}
            begin
            j := 1;                      {reset pointer}
            {$I-} write(wordfile,wordrec); {$I+} fileio;  {write record to working file}
            fillchar(wordrec,512,0);
            end;
         end;                            {1 word from raw file}

     {----finish wd detail recs-----------------------------------------}
     CLEARWDS;
     if j > 1 then
        begin
        {$I-} write(wordfile,wordrec); {$I-} fileio;   {write the unwritten}
        end;

     {----close---------------------------------------------------------}
     {$I-} close(rawfile); {$I+} fileio;
     {$I-} close(wordfile); {$I+} fileio;

end;

{************************************************************************}
procedure SORTNDX(var WkNdxArray : NdxArray);
   procedure sort(first,last: integer);
   var
     i,j    : integer;
     WkPtr  : NdxPtr;
     a      : string[20];
   begin
     i := first; j := last;
     a := upcases(WkNdxArray[(first + last) DIV 2]^.NdxWord);
     repeat
       while upcases(WkNdxArray[i]^.NdxWord) < a do
          i := i + 1;
       while a < upcases(WkNdxArray[j]^.NdxWord) do
          j := j - 1;
       if i <= j then
       begin
         WkPtr := WkNdxArray[i];
         WkNdxArray[i] := WkNdxArray[j];
         WkNdxArray[j] := WkPtr;
         i := i + 1; j := j - 1;
       end;
     until i>j;
     if first < j then sort(first,j);
     if i < last then sort(i,last);
   end;

begin {quicksort};
  sort(1,ix);
end;

{************************************************************************}
procedure BUILDNDX(wkndxname : string; WkNdxArray : NdxArray);
begin
     {$I-} assign(NdxFile,wkndxname); {$I+} fileio; {open eng ndx file}
     {$I-} rewrite(NdxFile); {$I+} fileio;
     fillchar(NdxRec,512,0);
     j := 1;
     for i := 1 to ix do                 {step through raw file}
         begin
         NdxRec.NdxItem[j] := WkNdxArray[i]^;
         j := j + 1;                     {increment pointer in record}
         if (j > subperndxrec) then                 {record full}
            begin
            j := 1;                      {reset pointer}
            {$I-} write(NdxFile,NdxRec); {$I+} fileio;  {write record to working file}
            fillchar(NdxRec,512,0);
            end;
         end;                            {1 word from raw file}

     {----finish index recs-----------------------------------------}
     if j > 1 then
        begin
        {$I-} write(NdxFile,NdxRec); {$I+} fileio;  {write last rcd}
        end;

     {$I-} close(NdxFile); {$I+} fileio;
end;
{************************************************************************}

{************************************************************************}
begin
     INITVALUES;
     BUILDFIL;
     writeln;
     writeln('English Index: sort');
     SORTNDX(EngNdxArray);
     writeln('English Index: write');
     BUILDNDX(engndxname,EngNdxArray);
     writeln('Lg Index: sort');
     SORTNDX(LgNdxArray);
     writeln('Lg Index: write');
     BUILDNDX(lgndxname,LgNdxArray);
     {release(heaporg); {release all heap (index arrays are on heap)}}
     writeln('Done.');
end.
