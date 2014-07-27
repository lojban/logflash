
const
      subperndxrec = 22;
      engndxname : string[12] = 'ENGNDX.FL1';   {index file for English order}
      lgndxname  : string[12] = 'LGNDX.FL1';   {index file for Language order}

type

    AlphaNdxItem = record      {layout of index file item}
       NdxWord  : enwdtype;              {english keyword/lojban word}
       NdxRecNo : integer;               {file record number}
      end;                        {23 chars net * subperndxrec = 506}
    AlphaNdx = record      {layout of index file record}
       NdxItem  : array[1..subperndxrec] of AlphaNdxItem;
       NdxDummy : array[1..6] of char
      end;                        {23 chars net * subperndxrec = 506}
var
   NdxFile  : file of AlphaNdx;          {file of individual's data on wds}
   NdxRec   : AlphaNdx;              {item in file YourFile}

{***************************************************************************}
