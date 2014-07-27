{LF1STRG}
{************************************************************************}
function NUMSTRING(InNum: integer) : string;
   var
     Wkstring       :  string[80];
   begin
     str(InNum,Wkstring);
     NUMSTRING := Wkstring;
   end;
{************************************************************************}
function BOOLSTRING(InBool: boolean) : string;
   var
     Wkstring       :  string[80];
   begin
     if InBool then
        BOOLSTRING := 'true'
     else
        BOOLSTRING := 'false';
   end;
{************************************************************************}
function TRIM_FRONT(WkString: string) : string;
   var
     WkPos          :  integer;
   begin
     WkPos   := 0;
     repeat
        if WkPos <= length(WkString) then
           WkPos := WkPos + 1;
     until (WkPos > length(WkString)) or (WkString[WkPos] > ' ');
     if (WkPos > length(WkString)) then
        WkPos := 0;
     TRIM_FRONT := copy(WkString,WkPos,length(WkString));
   end;
{************************************************************************}
function TRIM_TRAIL(WkString: string) : string;
   var
     WkPos          :  integer;
     LastPos        :  integer;
   begin
     LastPos := 0;
     WkPos   := 0;
     for WkPos := 1 to length(WkString) do
        if WkString[WkPos] > ' ' then
           LastPos := WkPos;
     TRIM_TRAIL := copy(WkString,1,LastPos);
   end;
{************************************************************************}
function upcases(strg : string) : string;

var
    ll : integer;
    stchr : char;
    ststr : string[1];
    stwk  : string[80];

begin
     stwk := '';
     if length(strg) = 0 then upcases := ''
        else begin
        for ll := 1 to length(strg) do
            begin
            ststr := copy(strg,ll,1);
            stchr := ststr[1];
            stchr := upcase(stchr);
            stwk := stwk + stchr;
            end;
         upcases := stwk;
         end;
end;
{************************************************************************}


function  RightJust(InVal : integer) : string;
  var
     WkJust : string[6];
     WkVal  : string[6];
     WkPos  : integer;
begin
     WkJust := '      ';
     str(InVal, WkVal);
     WkPos := 7 - length(WkVal);
     Insert(WkVal, WkJust, WkPos);
     RightJust := WkJust;
end;
{************************************************************************}

function FMT_DT_TIME : string;
   var
      year    : word;
      month   : word;
      day     : word;
      wkday   : word;
      hour    : word;
      minute  : word;
      second  : word;
      decisec : word;

  function STRG_2(InWord : word) : string;
     var
        WkVal :  string[2];
     begin
        if InWord < 10 then
           WkVal := '0' + NUMSTRING(integer(InWord))
        else
           WkVal := NUMSTRING(integer(InWord));
        STRG_2 := WkVal;
     end;

begin
     getdate(year,month,day,wkday);
     gettime(hour,minute,second,decisec);
     FMT_DT_TIME := STRG_2(month) + '/'
                  + STRG_2(day)   + '/'
                  + NUMSTRING(year) + ' '
                  + STRG_2(hour)  + ':'
                  + STRG_2(minute);

end;
{************************************************************************}
