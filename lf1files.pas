{***********************************************************************}
{  COPYRIGHT 1986 - 1991            by Nora and Bob LeChevalier         }
{***********************************************************************}
{************************************************************************}

procedure writehist(WkRec : string);
   {write rcd to history file}
   var
      DateTime    : string[16];
      DummySearch : SearchRec;
begin

     if HdrRec.HistoryOn then
        begin
        DateTime := FMT_DT_TIME;
        FindFirst(histfname,AnyFile,DummySearch);
        if DosError <> 0 then
           begin
           {$I-} assign(histfile,histfname); {$I+} fileio; {open historylog}
           {$I-} rewrite(histfile); {$I+} fileio;  {set up history log file}
           {$I-} writeln(histfile,
                   '                                        ',
                   '  NUM   NUM    %                        '); {$I+} fileio;
           {$I-} writeln(histfile,
                   '  DATE     TIME   SESS  LESSON          ',
                   ' CORR   WDS  CORR  NOTES                '); {$I+} fileio;
           {$I-} writeln(histfile,
                   '---------- -----  ----  --------------- ',
                   ' ----  ----  ----  ---------------------'); {$I+} fileio;
           {$I-} writeln(histfile,' ');                         {$I+} fileio;
           {$I-} writeln(histfile,
                   DateTime, ' ',
                   '*** Personal file set up for ',f1, '***');  {$I+} fileio;
           end
        else
           begin
           {$I-} assign(histfile,histfname); {$I+} fileio; {open historylog file}
           {$I-} append(histfile); {$I+} fileio;
           end;
        {$I-} writeln(histfile,
                WkRec); {$I+} fileio;
        {$I-} close(histfile); {$I+} fileio;
        end;

end;

{************************************************************************}

procedure getfdata;                      {get file data to start session}

begin
     {$I-} assign(HdrFile,f); {$I+} fileio;
     {$I-} reset(HdrFile); {$I+} fileio;       {open and reset file}
     {$I-} read(HdrFile,HdrRec); {$I+} fileio;  {read first record}
     {$I-} close(HdrFile); {$I+} fileio;        {close file at the end of each proc}
     NormColor  := HdrRec.NormColorH;
     BriteColor := HdrRec.BriteColorH;
     EntryColor := HdrRec.EntryColorH;

end;

{************************************************************************}

procedure checkftot;
begin
     {$I-} assign(YourFile,f); {$I+} fileio;
     {$I-} reset(YourFile); {$I+} fileio;
     {$I-} ie := filesize(YourFile); {$I+} fileio;
     HdrRec.FileRcdCnt := ie;
     for i := 1 to 14 do
        HdrRec.wdcnt[i] := 0;
     HdrRec.filenumwds := 0;
     {$I-} seek(YourFile,1); {$I+} fileio;
     for i := 1 to (ie - 1) do  {file has 'ie' rcds, numbered 0 (hdr) to 'ie-1'}
        begin
        {$I-} read(YourFile,YourRec); {$I+} fileio;
        for j := 1 to subperyourrec do
           with YourRec, Yours[j] do
              if (sr > 0) then
                 begin
                 HdrRec.filenumwds := HdrRec.filenumwds + 1;
                 if (fp = 13) and skw then
                    {do not count in new word pile}
                 else
                    HdrRec.wdcnt[fp] := HdrRec.wdcnt[fp] + 1;
                 end;
        end;
     {$I-} close(YourFile); {$I+} fileio;

     {$I-} assign(HdrFile,f); {$I+} fileio;
     {$I-} reset(HdrFile); {$I+} fileio;
     {$I-} seek(HdrFile,0); {$I+} fileio;
     {$I-} write(HdrFile,HdrRec); {$I+} fileio;
     {$I-} close(HdrFile); {$I+} fileio;
end;

{**************************************************************************}

procedure REGROUP(PileNo : integer;
                  NewSess : integer;
                  RegroupType : char;     {L=lesson order, R=random order}
                  NumForLesson : integer);
{regroup words in PileNo; chg sess # to NewSess>0; order based on RegroupType}

var
   numinlesson  :  integer;
   currlesson   :  integer;
   WkNumLessons :  integer;
   WriteNeeded  :  boolean;
   StartLess    :  integer;

begin
     {--------------Hdr Rec Data-------------------------------------------}
     {$I-} assign(HdrFile,f); {$I+} fileio;
     {$I-} reset(HdrFile); {$I+} fileio;      {position to #0 rcd}
     WkNumLessons := trunc((HdrRec.wdcnt[PileNo] - 1) / NumForLesson) + 1;
     if PileNo = 13 then
        begin
        HdrRec.NWBlkLeft := WkNumLessons;
        HdrRec.NWperLess := NumForLesson;
        HdrRec.NWOrder   := RegroupType;
        if NumForLesson > HdrRec.MaxNWused then
           HdrRec.MaxNWused := NumForLesson;
        end;
     if HdrRec.More4Less = PileNo then
        begin
        HdrRec.More4Less := 0;
        HdrRec.morecount := 0;
        end;
     if NewSess > 0 then
        begin
        HdrRec.SessNo := NewSess;           {old session #}
        if NewSess = 1 then
           HdrRec.LastLess := 12;          {old lesson #}
        end;
     {UC for non-Maintenance starts looking at sessno - 3}
     {UC for Maintenance just looks for oldest group}
     if PileNo = 1 then
        if (HdrRec.SessNo - WkNumLessons - 1 > 0) then
           StartLess := HdrRec.SessNo - WkNumLessons - 1
        else
            StartLess := 1
     else
        StartLess := HdrRec.SessNo;
     {$I-} write(HdrFile,HdrRec); {$I+} fileio;   {write updated hdr data}
     {$I-} close(HdrFile); {$I+} fileio;

     {--------------Detail Rcd Data----------------------------------------}
     {$I-} assign(YourFile,f); {$I+} fileio;
     {$I-} reset(YourFile); {$I+} fileio;
     numinlesson := 0;
     currlesson := HdrRec.SessNo;

     for i := 2 to HdrRec.FileRcdCnt do  {loop thru each word record}
         begin
         {$I-} seek(YourFile,i-1); {$I+} fileio;
         {$I-} read(YourFile,YourRec); {$I+} fileio;  {read word record}
         WriteNeeded := false;
         for j := 1 to subperyourrec do      {loop thru each word in record}
             begin
             with YourRec,Yours[j] do
                  begin
                  if (sr > 0) and (fp = PileNo) and not skw then
                     begin               {reset each non-blank word}
                     WriteNeeded := true;
                     if RegroupType = 'L' then   {regroup by lesson}
                        if numinlesson < NumForLesson then
                           begin
                           ym := currlesson;     {class ordr}
                           numinlesson := numinlesson + 1;
                           end
                        else
                           begin
                           currlesson := currlesson + 1;
                           ym := currlesson;     {class ordr}
                           numinlesson := 1;
                           end
                     else
                        {randomly assign wds to new wd sets}
                        ym := random(WkNumLessons)+StartLess;
                     end;
                  end;                   {with}
             end;                        {next word}
         if WriteNeeded then
            begin
            {$I-} seek(YourFile,i-1); {$I+} fileio;
            {$I-} write(YourFile,YourRec); {$I+} fileio;
            end;
         end;                            {record loop}
     {$I-} close(YourFile); {$I+} fileio;


end;                                     {in main routine must go to '310'}

{**************************************************************************}

procedure RESETF(OldType : integer; NewType : integer;
                 WkWdperLess : integer; WkOrder : char);

  const
                       {from,to}
    MoveType :    array[1..4,1..5] of integer =
    {Gives 0 if not allowed, otherwise indicator of word movement type}
    {0 = no word movement                                  }
    {1 = all words to new word pile (will need new "ym"'s) }
    {2 = lessons 3 to 8 move into lesson 9                 }
    {3 = lessons 5 & 6 move into lesson 7                  }
    {4 = a;; wprds to new word pile (pre-set order)        }
    {5 = a;; wprds to new word pile (random  order)        }
                                   {N,G,M,B,  restart}
                  {NW review}    ( (0,1,0,1,   1     ),
                  {Gain Control}   (2,0,3,1,   1     ),
                  {Maintenance}    (2,0,0,1,   1     ),
                  {Brush-up}       (2,0,0,0,   1     ));
    HistLogMsg : array[0..3] of string[48] =
        ('**************** No words moved ***************',
         '****** All words moved to New Word pile *******',
         '*** Intermediate pile words moved to Recog1 ***',
         '********* Recog3 words moved to Recog2 ********');

  var
    ChgDone   :  boolean;

begin
    if WkWdperLess = 0 then
       WkWdperLess := HdrRec.NWperLess;
    if MoveType[OldType,NewType] > 0 then
       begin
       {$I-} assign(YourFile,f); {$I+} fileio;    {open file for word access}
       {$I-} reset(YourFile); {$I+} fileio;


       {file has FileRcdCnt rcds, numbered 0 (hdr) to FileRcdCnt-1}
       for i := 1 to (HdrRec.FileRcdCnt - 1) do
          begin
          {$I-} seek(YourFile,i); {$I+} fileio;
          {$I-} read(YourFile,YourRec); {$I+} fileio;
          ChgDone := false;
          for j := 1 to subperyourrec do
             with YourRec, Yours[j] do
                if (sr > 0) then
                   case MoveType[OldType,NewType] of
                     1 : begin
                         if (fp <> 13) then
                            begin
                            HdrRec.wdcnt[fp] := HdrRec.Wdcnt[fp] - 1;
                            HdrRec.wdcnt[13] := HdrRec.Wdcnt[13] + 1;
                            fp := 13;
                            ChgDone := true;
                            end;
                         end;
                     2 : begin
                         if (fp >= 3) and (fp <= 8) then
                            begin
                            HdrRec.wdcnt[fp] := HdrRec.Wdcnt[fp] - 1;
                            HdrRec.wdcnt[09] := HdrRec.Wdcnt[09] + 1;
                            fp := 09;
                            ChgDone := true;
                            end;
                         end;
                     3 : begin
                         if (fp = 5) or (fp = 6) then
                            begin
                            HdrRec.wdcnt[fp] := HdrRec.Wdcnt[fp] - 1;
                            HdrRec.wdcnt[07] := HdrRec.Wdcnt[07] + 1;
                            fp := 07;
                            ChgDone := true;
                            end;
                         end;
                   end;
          if ChgDone then
             begin
             {$I-} seek(YourFile,i); {$I+} fileio;
             {$I-} write(YourFile,YourRec); {$I+} fileio;
             end;
          end;
       {$I-} close(YourFile); {$I+} fileio;
       case MoveType[OldType,NewType] of
         1 : begin
                HdrRec.More4Less := 0;
                HdrRec.morecount := 0;
                if OldType > 1 then
                   HdrRec.ResetCnt := HdrRec.ResetCnt + 1;
             end;
         2 : if (HdrRec.More4Less >= 3) and (HdrRec.More4Less <= 9) then
                begin
                HdrRec.More4Less := 0;
                HdrRec.morecount := 0;
                end;
         3 : if (HdrRec.More4Less >= 5) or (HdrRec.More4Less <= 7) then
                begin
                HdrRec.More4Less := 0;
                HdrRec.morecount := 0;
                end;
         end;
       end;

    case NewType of
       2: if HdrRec.Csess = 0 then
             HdrRec.Csess := HdrRec.TrueSess;
       3: if HdrRec.Msess = 0 then
             HdrRec.Msess := HdrRec.TrueSess
          else
             if (HdrRec.Addsess > 0) and (HdrRec.reMsess = 0) then
                HdrRec.reMsess := HdrRec.TrueSess;
    end;

    case NewType of
       1,2,3,4 : HdrRec.SessType := NewType;
       5       : HdrRec.SessType := 2;   {for restart, put in Gain Cntl mode}
    end;

    {$I-} assign(HdrFile,f); {$I+} fileio;
    {$I-} reset(HdrFile); {$I+} fileio;
    {$I-} write(HdrFile,HdrRec); {$I+} fileio;
    {$I-} close(HdrFile); {$I+} fileio;

    {assumes that date & time already written by whatever called RESETF}
    WkLine := blankline;
    insert(HistLogMsg[MoveType[OldType,NewType]],WkLine,19);
    writehist(WkLine);

    if MoveType[OldType,NewType] = 1 then
       REGROUP(13,1,WkOrder,WkWdperLess);
end;

{************************************************************************}

function GETOLDEST(WkLess : integer) : integer;

  var
     WkOldest : integer;
begin
     {$I-} assign(YourFile,f); {$I+} fileio;    {open file for word access}
     {$I-} reset(YourFile); {$I+} fileio;

     WkOldest := 9999;

     {$I-} seek(YourFile,1); {$I+} fileio;

     {file has FileRcdCnt rcds, numbered 0 (hdr) to FileRcdCnt-1}
     for i := 1 to (HdrRec.FileRcdCnt - 1) do
        begin
        {$I-} read(YourFile,YourRec); {$I+} fileio;
        for j := 1 to subperyourrec do
           with YourRec, Yours[j] do
              if (sr > 0) then
                 if (fp = WkLess) and (ym < WkOldest) then
                    WkOldest := ym;
        end;
     {$I-} close(YourFile); {$I+} fileio;
     GETOLDEST := WkOldest;
end;

{************************************************************************}

procedure GETWDS;                        {6000-6299, get words}

var
     hw       :  integer;
     rn       :  integer;
     sb       :  integer;
     numextra :  integer;    {num extra under ctl to select out}
     DoneLoop :  boolean;

begin

     {--------------YOURFILE----------------------------------------------}
     {$I-} assign(YourFile,f); {$I+} fileio;    {open file for word access}
     {$I-} reset(YourFile); {$I+} fileio;

     {---for overflow error lesson, may have to skip already done wds---}
     if not odd(ThisLess) then
        hr := (arrsize * HdrRec.morecount)
     else
        hr := 0;

     nw := 0;                            {reset number of words}
     hw := 0;                            {set counter to compare to hr limit}

     if (ThisLess = 1) and
        ( (HdrRec.SessType = 2) or (HdrRec.SessType = 4) ) then
        numextra := HdrRec.UCrandoms
     else
         numextra := 0;

     DoneLoop := false;
     i := 1;

     repeat
         {$I-} seek(YourFile,i); {$I+} fileio;      {read it}
         {$I-} read(YourFile,YourRec); {$I+} fileio;
         for j := 1 to subperyourrec do      {get each word}
             with YourRec,Yours[j] do
                  if DoneLoop then
                     {don't do anything}
                  else
                  if sr = 0 then         {unused subrecord means end-of-file}
                     DoneLoop := true
                  else

                  {Check for item in correct pile for lesson}
                  if fp = ThisLess then

                     {Check session updated for correct number}
                     if ( (ThisLess = 13) and (ym = oldestset) ) or
                        ( (ThisLess = 1)  and (ym = oldestset) ) or
                        ( (ThisLess = 1) and
                          (random(HdrRec.filenumwds) + 1 <= numextra) ) or
                        ( (ThisLess <> 1) and
                          (ThisLess <> 13) and
                          (ym <= oldestset) ) then

                           {skip 'More' lesson words already done}
                           if (not odd(ThisLess)) and (hw < hr) then
                              hw := hw + 1
                           else

                           {set 'More' flag}
                           if (nw = arrsize) then
                              begin
                              HdrRec.More4Less := ThisLess;
                              HdrRec.morecount := HdrRec.morecount + 1;
                              DoneLoop := true;
                              end
                           else
                              {take word}
                              begin
                              nw := nw + 1;
                              arr[nw]^.you := YourRec.Yours[j];
                              HdrRec.More4Less := 0;
                              {stop regular ladder lesson at MaxLess #wds}
                              if (ThisLess <> 13) and (HdrRec.MaxLess > 0) and
                                 (odd(ThisLess)) and
                                 (nw = HdrRec.MaxLess) then
                                   DoneLoop := true;
                              end;
         i := i + 1;
     {file has FileRcdCnt rcds, numbered 0 (hdr) to FileRcdCnt-1}
     until (DoneLoop) or (i > HdrRec.FileRcdCnt - 1);

     {$I-} close(YourFile); {$I+} fileio;


     {--------------WORDFILE----------------------------------------------}
     {$I-} assign(WordFile,wordfname); {$I+} fileio; {open file for word access}
     {$I-} reset(WordFile); {$I+} fileio;
     for i := 1 to nw do
         begin

         rn := trunc((arr[i]^.you.sr-1) / subperwdrec);{determine rcd number(-1)}
         sb := arr[i]^.you.sr - rn * subperwdrec; {and position in record}
         {$I-} seek(WordFile,rn+1); {$I+} fileio; {go to that file position}
         {$I-} read(WordFile,WordRec); {$I+} fileio;       {and read record}
         arr[i]^.wd := WordRec.Words[sb];
         arr[i]^.pii := 0;
     end;
     {$I-} close(WordFile); {$I+} fileio;
end;

{************************************************************************}
procedure MOVE_ERRORS;    {put errs in appropriate fallback lessons}
begin

    {Assure that HdrRec is correct}
    {$I-} assign(HdrFile,f); {$I+} fileio;
    {$I-} reset(HdrFile); {$I+} fileio;
    {$I-} seek(HdrFile,0); {$I+} fileio;
    {$I-} read(HdrFile,HdrRec); {$I+} fileio;

    {$I-} assign(YourFile,f); {$I+} fileio;
    {$I-} reset(YourFile); {$I+} fileio;
    {file has FileRcdCnt records, numbered 0 (HdrRec) to FileRcdCnt-1}
    for i := 1 to (HdrRec.FileRcdCnt - 1) do
       begin
       {$I-} seek(YourFile,i); {$I+} fileio;
       {$I-} read(YourFile,YourRec); {$I+} fileio;
       chgflag := false;
       for j := 1 to subperyourrec do
          with YourRec, Yours[j] do
             if (sr > 0) then
                if not odd(fp) then            {error piles are even}
                   begin
                   dcnt := dcnt + 1;           {1 more time in error pile}
                   HdrRec.wdcnt[fp] := HdrRec.wdcnt[fp] - 1;
                   if (HdrRec.DropbackOn) and (HdrRec.SessType <> 1) then
                      fp := 11                 {put all in DropBack pile}
                   else
                      fp := NewPile[HdrRec.SessType,fp];
                   HdrRec.wdcnt[fp] := HdrRec.wdcnt[fp] + 1;
                   chgflag := true;
                   end;
       if chgflag then
          begin
          {$I-} seek(YourFile,i); {$I+} fileio;
          {$I-} write(YourFile,YourRec); {$I+} fileio;
          end;
       end;
    {$I-} close(YourFile); {$I+} fileio;

    {$I-} seek(HdrFile,0); {$I+} fileio;
    {$I-} write(HdrFile,HdrRec); {$I+} fileio;
    {$I-} close(HdrFile); {$I+} fileio;
end;
{************************************************************************}

procedure UPDATE_WDS;                     {6700-6999, update file}
  var
     rn       :  integer;
     sb       :  integer;

begin

     {---Update YourFile------------------------------------------------}
     {$I-} assign(YourFile,f); {$I+} fileio;  {open file for word update}
     {$I-} reset(YourFile); {$I+} fileio;
     for i := 1 to nw do
         begin
         rn := trunc((arr[i]^.you.sr-1) / subperyourrec);{determine rcd number(-1)}
         sb := arr[i]^.you.sr - rn * subperyourrec; {and position in record}
         {$I-} seek(YourFile,rn+1); {$I+} fileio; {go to that file position}
         {$I-} read(YourFile,YourRec); {$I+} fileio;       {and read record}
         YourRec.Yours[sb] := arr[i]^.you;
         {$I-} seek(YourFile,rn+1); {$I+} fileio;
         {$I-} write(YourFile,YourRec); {$I+}   {write updated word record}
         end;
     {$I-} close(YourFile); {$I+} fileio;
end;

{************************************************************************}

procedure UPDATE_HDR;                     {6700-6999, update file}
begin
     {---Update Hdrfile-------------------------------------------------}
     {$I-} assign(HdrFile,f); {$I+} fileio;
     {$I-} reset(HdrFile); {$I+} fileio;       {open and reset file}
     {$I-} write(HdrFile,HdrRec); {$I+} fileio;  {read first record}
     {$I-} close(HdrFile); {$I+} fileio;        {close file at the end of each proc}
end;

{************************************************************************}
   procedure GET_FLAGS(SelectPile,SelectSubPile : integer;
                       SelectOrder : string;
                      var DsplyData : dsplyptr;
                      var TotNumWords : integer);
      var
        WdsOnPage      :  integer;
        WdsPerPage     :  integer;
        i              :  integer;
        j              :  integer;

      begin
      TotNumWords   := 0;

      {$I-} assign(YourFile,f); {$I+} fileio;
      {$I-} reset(YourFile); {$I+} fileio;
      for i := 1 to HdrRec.FileRcdCnt - 1 do    {FileRcdCnt includes Hdr}
         begin
         {$I-} seek(YourFile,i); {$I+} fileio;
         {$I-} read(YourFile,YourRec); {$I+} fileio;  {read word record}
         for j := 1 to subperyourrec do      {loop thru each word in record}
           with YourRec, Yours[j] do
              if sr > 0 then
                 if (fp = SelectPile) or (SelectPile = 0) then
                    if (ym = SelectSubPile) or (SelectSubPile = 0) then
                       begin
                       TotNumWords := TotNumWords + 1;
                       DsplyData^.DsplyFlags[sr] := '1';
                       end;
         end;
     {$I-} close(YourFile); {$I+} fileio;
     end;
{************************************************************************}
procedure GET_DSPLY_LIST(TotNumWords : integer;
                         SelectOrder : string;
                         var DsplyData : dsplyptr);
{$I lf1varix.pas}

      var
        i              :  integer;
        rn             :  integer;
        sb             :  integer;
        SelectCnt      :  integer;

      begin

      if SelectOrder = 'E' then
         begin
         {$I-} assign(NdxFile,engndxname); {$I+} fileio;
         {$I-} reset(NdxFile); {$I+} fileio;
         end
      else
      if SelectOrder = 'L' then
         begin
         {$I-} assign(NdxFile,lgndxname); {$I+} fileio;
         {$I-} reset(NdxFile); {$I+} fileio;
         end;
      rn := 0;
      sb := subperndxrec;
      SelectCnt := 0;
      for i := 1 to HdrRec.FileNumWds do    {FileRcdCnt includes Hdr}
         begin
         if SelectOrder = 'P' then
            begin
            if DsplyData^.DsplyFlags[i] = '1' then
               begin
               SelectCnt := SelectCnt + 1;
               DsplyData^.DsplyWdNum[SelectCnt] := i;
               end;
            end
         else
            begin
            sb := sb + 1;
            if sb > subperndxrec then
               begin
               rn := rn + 1;
               sb := 1;
               {$I-} seek(NdxFile,rn-1); {$I+} fileio;  {1st rcd is #0}
               {$I-} read(NdxFile,NdxRec); {$I+} fileio;  {read word record}
               end;
            with NdxRec, NdxItem[sb] do
              if DsplyData^.DsplyFlags[NdxRecNo] = '1' then
                 begin
                 SelectCnt := SelectCnt + 1;
                 DsplyData^.DsplyWdNum[SelectCnt] := NdxRecNo;
                 DsplyData^.DsplyWd[SelectCnt] := NdxWord;
                 end;
            end
         end;
      if (SelectOrder = 'E') or (SelectOrder = 'L') then
         {$I-} close(NdxFile); {$I+} fileio;
     end;
{************************************************************************}
   procedure GET_YOUR_PAGE(var DsplyData : dsplyptr;
                               WdsPerPage, PageNo, TotNumWords : integer;
                           var WdsThisPage : integer);
      var
        i              :  integer;
        rn             :  integer;
        sb             :  integer;
        wkndx          :  integer;
        wknum          :  integer;

      begin
      {$I-} assign(YourFile,f); {$I+} fileio;
      {$I-} reset(YourFile); {$I+} fileio;
      WdsThisPage := 0;
      wkndx := (WdsPerPage * (PageNo - 1)) + 1;
      for i := 1 to WdsPerPage do
         begin
         wknum := DsplyData^.DsplyWdNum[wkndx];
         if (wkndx <= TotNumWords) and
            (wknum > 0) then
            begin
            WdsThisPage := WdsThisPage + 1;
            rn := trunc((wknum - 1) / subperyourrec); {rcd number(-1)}
            sb := wknum - rn * subperyourrec; {and position in record}
            {$I-} seek(YourFile,rn+1); {$I+} fileio; {go to that file position}
            {$I-} read(YourFile,YourRec); {$I+} fileio;       {and read record}
              with YourRec, Yours[sb] do
                 arr[WdsThisPage]^.you := Yours[sb];
            end;
         wkndx := wkndx + 1;
         end;
     {$I-} close(YourFile); {$I+} fileio;
     end;
{**************************************************************************}
   procedure GET_WD_DATA(WdsThisPage : integer);

      var
        i              :  integer;
        rn             :  integer;  {record number}
        sb             :  integer;  {subrecord number}

      begin

      {$I-} assign(WordFile,wordfname); {$I+} fileio;
      {$I-} reset(WordFile); {$I+} fileio;
      for i := 1 to WdsThisPage do
         begin
         rn := trunc((arr[i]^.you.sr-1) / subperwdrec);{determine rcd number(-1)}
         sb := arr[i]^.you.sr - rn * subperwdrec; {and position in record}
         {$I-} seek(WordFile,rn+1); {$I+} fileio; {go to that file position}
         {$I-} read(WordFile,WordRec); {$I+} fileio;       {and read record}
         arr[i]^.wd := WordRec.Words[sb];
         arr[i]^.pii := 0;
         end;
     {$I-} close(wordfile); {$I+} fileio;
     end;
{************************************************************************}
procedure GETNDX(var DsplyData   :  dsplyptr);
     var
        i        :  integer;
        sb       :  integer;
        rn       :  integer;
begin
   rn := 1;
   {$I-} assign(WordFile,wordfname); {$I+} fileio; {open file for word access}
   {$I-} reset(WordFile); {$I+} fileio;
   {$I-} seek(WordFile,1); {$I+} fileio;
   {$I-} read(WordFile,WordRec); {$I+} fileio;
   sb := 0;
   for i := 1 to HdrRec.FileNumWds do
      begin
      if sb = subperwdrec then
         begin
         sb := 1;
         rn := rn + 1;
         {$I-} seek(WordFile,rn); {$I+} fileio;
         {$I-} read(WordFile,WordRec); {$I+} fileio;
         end
      else
         sb := sb + 1;
      DsplyData^.DsplyWd[i]    := TRIM_TRAIL(wordrec.words[sb].en);
      DsplyData^.DsplyWdNum[i] := i;
      end;
   {$I-} close(WordFile); {$I+} fileio;
end;
{************************************************************************}
procedure BUILDENGNDX(var DsplyData : dsplyptr);
{$I lf1varix.pas}
begin
     {$I-} assign(NdxFile,engndxname); {$I+} fileio; {open eng ndx file}
     {$I-} rewrite(NdxFile); {$I+} fileio;
     fillchar(NdxRec,512,0);
     j := 1;
     for i := 1 to HdrRec.FileNumWds do  {step through raw file}
         begin
         NdxRec.NdxItem[j].NdxWord := DsplyData^.DsplyWd[i];
         NdxRec.NdxItem[j].NdxRecNo := DsplyData^.DsplyWdNum[i];
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
procedure UPDTWDFILE(arrnum  :  integer);   {updt wd in arrnum item of arr}
     var
        rn    :  integer;
        sb    :  integer;
begin
  {$I-} assign(WordFile,wordfname); {$I+} fileio; {open file for word access}
  {$I-} reset(WordFile); {$I+} fileio;

  rn := trunc((arr[arrnum]^.you.sr-1) / subperwdrec);{determine rcd number(-1)}
  sb := arr[arrnum]^.you.sr - rn * subperwdrec; {and position in record}

  {$I-} seek(WordFile,rn+1); {$I+} fileio; {go to that file position}
  {$I-} read(WordFile,WordRec); {$I+} fileio;       {and read record}

  WordRec.Words[sb] := arr[arrnum]^.wd;

  {$I-} seek(WordFile,rn+1); {$I+} fileio; {go to that file position}
  {$I-} write(WordFile,WordRec); {$I+} fileio;       {and write new record}
  {$I-} close(WordFile); {$I+} fileio;
end;
{************************************************************************}
procedure  OPENPRINT(PrintDevice : string;
                     var WkErr : string);
var
        WkIO       :    integer;
begin
   {open "file" for printer}
   {$I-} assign(Printer,PrintDevice); {$I+} filestat(WkErr,WkIO);
   if WkIO = 0 then
      begin
      {$I-} rewrite(Printer); {$I+} filestat(WkErr,WkIO);
      end;
end;
{************************************************************************}
procedure  CLOSEPRINT(PrntDevice : string);
var
        DummyErr   :    string[2];
        WkIO       :    integer;
begin
   {close "file" for printer}
   {$I-} close(Printer); {$I+} filestat(DummyErr,WkIO);
end;
{************************************************************************}
procedure  PRINTPAGE(PageNo, PageCnt, WdsThisPage, WdsPerPage : integer;
                     PrintFmt : char;
                     SelectOrder : string;
                     PrintDevice, PageTitle : string;
                     TotNumWords : integer;
                     var WkErr : string);
{
           PRINT OF ...                                     Page x of xxx
  LOJBAN  RAFSI            ENGLISH                      CLUE WORD

  lllll | aaaaaaaaaaaa   | eeeeeeeeeeeeeeeeeeee       | cccccccccccccccccccc
                         | ddddddddddddddddddddddddddddddddddddddddddddddddd
        llllllllllllllll | ddddddddddddddddddddddddddddddddddddddddddddddddddd



           PRINT OF ...                                     Page x of xxx
  ENGLISH                  LOJBAN  RAFSI                CLUE WORD

  eeeeeeeeeeeeeeeeeeee   | lllll | aaaaaaaaaaaa       | cccccccccccccccccccc
                         | ddddddddddddddddddddddddddddddddddddddddddddddddd
        llllllllllllllll | ddddddddddddddddddddddddddddddddddddddddddddddddddd
}
var
        DummyErr   :    string[2];
        DummyChar  :    char;
        LessonName :    string[16];
        WdSub      :    integer;
        WkIO       :    integer;
begin
   WkIO := 0;
   {page heading}
    WkLine := blankline;
    insert(PageTitle,WkLine,12);
    insert( ('Page ' + NUMSTRING(PageNo)
              + ' of ' + NUMSTRING(PageCnt) ), WkLine,61);
    if WkErr = '' then
       begin
       {$I-} writeln(Printer,WkLine); {$I+} filestat(WkErr,WkIO);
       end;

   {column headings}
    WkLine := blankline;
    if SelectOrder = 'E' then
       insert('ENGLISH                  LOJBAN  RAFSI                CLUE WORD',
               WkLine, 3)
    else
       insert('LOJBAN  RAFSI            ENGLISH                      CLUE WORD',
               WkLine, 3);
    if WkErr = '' then
       begin
       {$I-} writeln(Printer,WkLine); {$I+} filestat(WkErr,WkIO);
       end;
    if WkErr = '' then
       begin
       {$I-} writeln(Printer,' '); {$I+} filestat(WkErr,WkIO);
       end;

   {detail lines}
    WdSub := 0;
    repeat

        if keypressed then
           begin
           DummyChar := readkey;
           WkErr := 'Print cancelled';
           end;

        WdSub := WdSub + 1;

        WkLine := blankline;
        if SelectOrder = 'E' then
           begin
           insert(arr[WdSub]^.wd.en,Wkline,3);
           insert('|',Wkline,26);
           insert(arr[WdSub]^.wd.lg,Wkline,28);
           insert('|',Wkline,34);
           insert(arr[WdSub]^.wd.lgs,Wkline,36);
           insert('|',Wkline,55);
           insert(arr[WdSub]^.wd.ec,Wkline,57);
           end
        else
           begin
           insert(arr[WdSub]^.wd.lg,Wkline,3);
           insert('|',Wkline,9);
           insert(arr[WdSub]^.wd.lgs,Wkline,11);
           insert('|',Wkline,26);
           insert(arr[WdSub]^.wd.en,Wkline,28);
           insert('|',Wkline,55);
           insert(arr[WdSub]^.wd.ec,Wkline,57);
           end;
        if WkErr = '' then
           begin
           {$I-} writeln(Printer,WkLine); {$I+} filestat(WkErr,WkIO);
           end;

        if PrintFmt = 'C' then
           begin

           WkLine := blankline;
           insert('|',Wkline,26);
           insert(arr[WdSub]^.wd.es1,Wkline,28);
           if WkErr = '' then
              begin
              {$I-} writeln(Printer,WkLine); {$I+} filestat(WkErr,WkIO);
              end;

           if arr[WdSub]^.you.skw then
              LessonName := 'skipped'
           else
           if odd(arr[WdSub]^.you.fp) then
              LessonName := s[arr[Wdsub]^.you.fp]
           else
              LessonName := s[arr[Wdsub]^.you.fp]
                          + ' Errors';
           WkLine := blankline;
           insert(LessonName,Wkline,9);
           insert('|',Wkline,26);
           insert(arr[WdSub]^.wd.es2,Wkline,28);
           if WkErr = '' then
              begin
              {$I-} writeln(Printer,WkLine); {$I+} filestat(WkErr,WkIO);
              end;

           if WkErr = '' then
              begin
              {$I-} writeln(Printer,' '); {$I+} filestat(WkErr,WkIO);
              end;
           end;
        if keypressed then
           begin
           DummyChar := readkey;
           WkErr := 'Print cancelled';
           end;
    until (WdSub >= WdsThisPage) or (WkErr <> '');

   {form feed}
   if WkErr = '' then
      begin
      {$I-} writeln(Printer,#12); {$I+} filestat(WkErr,WkIO);
      end;
end;
{************************************************************************}
