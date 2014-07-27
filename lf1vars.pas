
const
      s : array [1..14] of string[13] = ('Under Control','Under Control',
         'Recalled 1x','Recalled 1x','Recognized 3x','Recognized 3x',
         'Recognized 2x','Recognized 2x',
         'Recognized 1x','Recognized 1x','Drop Back','Drop Back',
         'New Word','New Word');
      arrsize =  250;
      DefaultColor : integer = 2; {green}
      DefaultEntryColor : integer = 32; {black, green background}
      DefaultBriteColor : integer = 10; {light green}
      subperwdrec   = 3;
      subperyourrec = 17;
      langname  : string[16] = 'Lojban';
      lgwdlen   : integer = 5;
      lgsuplen  : integer = 12;
      enwdlen   : integer = 20;
      ensuplen1 : integer = 50;
      ensuplen2 : integer = 52;
      encluelen : integer = 20;
      elothlen  : integer = 2;
      LessChart : array [1..4,1..14] of integer =  {Chart of next lessons}
          {#1   2   3   4   5   6   7   8   9  10  11  12  13  14       }
          {UC     Rc1     Rg3     Rg2     Rg1     Drp      NW       type}
         ( (2,  9,  9,  9,  9,  9,  9,  9, 10, 11, 12, 13, 14,  1),   {R}
           (2,  3,  4,  5,  6,  7,  8,  9, 10, 11, 12, 13, 14,  1),   {C}
           (2,  3,  4,  7,  7,  7,  8,  9, 10, 11, 12,  1,  1,  1),   {M}
           (2,  3,  4,  7,  7,  7,  8,  9, 10, 11, 12, 13, 14,  1) ); {B}
      NewPile   : array [1..4,1..14] of integer =  {Chart of advancement piles}
      {dropback assumed OFF for this table.  If on, drop to pile #11 unless 'R'}
      {Also, error pile listing is not used until new session moves them}
          {#1   2   3   4   5   6   7   8   9  10  11  12  13  14       }
          {UC     Rc1     Rg3     Rg2     Rg1     Drp      NW       type}
         ( (1,  9,  9,  9,  9,  9,  9,  9,  1,  9,  9, 11,  9, 11),   {R}
           (1,  3,  1,  5,  3,  7,  5,  9,  7, 11,  9, 11,  9, 11),   {C}
           (1,  3,  1,  7,  3,  7,  3,  9,  7, 11,  9, 11,  9, 11),   {M}
           (1,  3,  1,  7,  3,  7,  3,  9,  7, 11,  9, 11,  9, 11) ); {B}
      wordfname : string[12] = 'LOGDATA.FL1';   {word data file, random}
      yoursuff  : string[5] = 'l.fl1';      {ell; suffix for personal file}
      histsuff  : string[5] = 'h.fl1';   {suffix for personal history log file}
      heading   : string[14] = '      LOGFLASH';

type

    lgwdtype   = string [5];
    lgsuptype  = string [12];
    enwdtype   = string [20];
    ensuptype1 = string [50];
    ensuptype2 = string [52];
    encluetype = string [20];
    elothtype  = string [2];
    str80     = string[80];
    YourHdr  = record                    {first record of file}
     {Control information}
       SessNo     : integer;             {last session #, initially 1}
       SessType   : byte;                {last session type, initially 1}
       LastLess   : integer;             {last lesson #, initially 12}
       More4Less  : integer; {indicates a pile which was incomplete due to
                            array overflow, the lessons should start there,
                            initially 0}
       NWBlkLeft  : integer; {# nw blocks left, initially approx #-of-words/20}
       FileRcdCnt : integer;             {number of records in file}
       wdcnt      : array[1..14] of integer;      {#wds in piles}
       filelang   : string[15];          {language from comment on raw file}
       comments   : string[59];          {copy any comment in raw file}
       filenumwds : integer;             {number of words on random file}
       morecount  : integer;             {# times More4Less used this lesson}
       TypoOnRg   : boolean;             {Allow retry for typo on recog}
       TypoOnRc   : boolean;             {Allow retry for typo on recall}
       NWskipOn   : boolean;             {Flag to Skip NW lesson}
       DropbackOn : boolean;  {Flag to put errs in Dropback (vs 1 lesson back)}
       HistoryOn  : boolean;             {Flag to keep History file}
       ErrRptCnt  : integer;             {# times to repeat for errs}
       UCrandoms  : integer;             {# Under Control random wds}
       MaxLess    : integer;             {Max wds per lesson (other than NW)}
       NWperLess  : integer;             {Number NWs per NW lesson}
       NormColorH : integer;             {Color for normal displays, Hdr}
       BriteColorH : integer;            {Color for bright displays, Hdr}
       EntryColorH : integer;            {Color for entry fields, Hdr}
       NWOrder    : char;                {R=Random; space or L=Lesson (preset)}
       dummycntl  : array[1..99] of char; {save for future}
     {Logging information}
       TrueSess   : integer;             {True sess #}
       ResetCnt   : integer;             {# times file reset}
       Csess      : integer;             {Session first Gain Ctl}
       Msess      : integer;             {Session first Maintenance}
       Addsess    : integer;             {Session first add wds}
       reMsess    : integer;             {Session reMaintenance after add wds}
       MaxErrRptUsed : integer;          {Max of error rpt # used}
       MaxNWused    : integer;           {Max of # nw per lesson used}
       MaxLessUsed  : integer;           {Max of # wd per other lesson used}
       RgTypoUsed   : boolean;           {Typo fixing ever used in Recog}
       RcTypoUsed   : boolean;           {Typo fixing ever used in Recall}
       DropbackStop : boolean;           {Dropback shortening ever used}
       NWskipCnt    : integer;           {# sessions NW pile skipping used}
       dummylog : array[1..251] of char;        {512 byte records}
      end;
    wordtext = record      {word layout, subperwdrec of these per record}
       lg       : lgwdtype;              {foreign language word}
       lgs      : lgsuptype;             {foreign language supplement data}
       en       : enwdtype;              {english keyword}
       ec       : encluetype;            {english clueword}
       es1      : ensuptype1;            {supplement for english}
       es2      : ensuptype2;            {more supplement for english}
       elother  : elothtype;             {misc: used for lesson select #}

      end;                        {168 chars net * subperwdrec = 504}
    YourData = record      {word control layout, subperyourrec per record}
     {Control data}
       fp       : integer;               {current File Pile}
       sr       : integer;               {word number in file}
       ym       : integer; {nw block number gives session # to first use it;
                            or last session # used in}
       skw      : boolean;               {skip word flag for nw pile item}
     {Logging data}
       nws      : integer;               {1st nw sess used in}
       rg1s     : integer;               {1st recog1 sess used in}
       rg2s     : integer;               {1st recog2 sess used in}
       rg3s     : integer;               {1st recog3 sess used in}
       rc1s     : integer;               {1st recall1 sess used in}
       ucs      : integer;               {1st under control sess used in}
       dcnt     : integer;               {# sessions in dropback pile}
       rggd     : integer;               {tot recogs correct}
       rgerr    : integer;               {tot recogs errors}
       rcgd     : integer;               {tot recall correct}
       rcerr    : integer;               {tot recall errors}
       filler   : byte;                  {not used}
      end;                        {30 chars net * subperyourrec = 510}
    wordinfo = record             {word record, contains subperwdrec wds}
       case integer of
         1: (filelang : string[15];
             numwds   : integer;
             numrcds  : integer;
             comments : string[59];
             hdrdummy : array[1..432] of byte);
         2: (words : array[1..subperwdrec] of wordtext;
             wddummy : array[1..8] of char);
             end;                        {total 512 bytes}
    YourInfo = record             {word record, contains subperwdrec wds}
             Yours : array[1..subperyourrec] of YourData;
             yrdummy : array[1..2] of char;
             end;                        {total 512 bytes}
    arritem = record                      {used to solve string access probs}
             wd : wordtext;              {a word}
             you : YourData;             {its control & results data for indiv}
             pii : integer;              {pile #}
             end;
    arrptr  = ^arritem;
    dsply_rcd = record
                DsplyFlags :  array[1..2000] of char;
                DsplyWdNum :  array[1..2000] of integer;
                DsplyWd    :  array[1..2000] of enwdtype;
                end;
    dsplyptr                =  ^dsply_rcd;
var
   arr : array[1..arrsize] of arrptr;   {used to solve string array access}
   blanklgwd   : lgwdtype;
   blanklgsup  : lgsuptype;
   blankenwd   : enwdtype;
   blankensup1 : ensuptype1;
   blankensup2 : ensuptype2;
   blankenclue : encluetype;
   blankeloth  : elothtype;
   blankline   : string[80];
   BriteColor : integer;                 {color for bright displays}
   chgflag : boolean;                   {true-> updt file when making error wds}
   dummy : integer;                     {return error from val}
   ep  : integer;                       {pile to put errors in}
   errmsg : string[80];
   f   : string[30];                     {file name for your personal file}
   fd  : boolean; {in error practice, indicates that at least 1 word
                   was practiced (<6 times right) this time thru deck}
                  {in main routine, indicates that file update is required}
   fdrv: string[1];                      {file drive}
   EntryColor : integer;                 {color for entry fields}
   gs  : integer;                   {number of correct words on a test}
   gt  : integer;                   {total number of words on a test}
   Hdrfile : file of YourHdr;       {file reference for 1st record for indiv}
   HdrRec  : YourHdr;               {item in file HdrFile}
   histfname    : string[30];   {file name for your personal history log file}
   histfile     : text;         {file for your personal history log file}
   hr  : integer;  {temporary for word # in file}
                   {Also, in getwds, counter end for hw extraction of ovflw wds}
   i   : integer;                   {loop counter}
   ie  : integer;                   {number of records in working file}
   j   : integer;                   {loop counter}
   Printer      : text;         {"file" for printer}
   k   : integer;  {loop counter, temp variable, used in
                   finding oldest, or next session data decks}
   n   : integer;                        {loop counter}
   NewSessCnt    :  integer;   {counter of new sess in FINDNEXTLESS}
                               {used to prevent infinite looping}
   NormColor : integer;                  {color for regular displays}
   np  : integer;                {pile to put non-errors in (advancement pile)}
   numin4 : string[4];                   {input to allow numeric check,4 digits}
   nw  : integer; {number of new word blocks of about 20 per session/block}
                  {also used to count number of words in memory word array}
   oldestset : integer;                  {under control oldest pile found}
   q   : char;                           {answer to user queries}
   recallflag : boolean; {indicates lesson is recall(T) or recognize(F)}
   sc  : integer;                        {percent score on a test}
   scrn_misc_data : scrn_def;            {array for misc screen entry}
   ThisLess : integer;                   {curr lesson number not yet done}
   WkLine   : string[80];                {used for formating history line}
   wordfile : file of wordinfo;          {file reference for word records}
   wordrec : wordinfo;                   {record reference for word records}
   YourFile : file of YourInfo;          {file of individual's data on wds}
   YourRec  : YourInfo;                  {item in file YourFile}

{***************************************************************************}
