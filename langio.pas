{**************************************************************************}
{      FILE ERRORS WILL HALT PROGRAM PREMATURELY                           }
{**************************************************************************}
procedure FileIO;
     var
        WkIO : integer;
        errmsg : string[80];
     begin;
           WkIO := IOResult;
           case WkIO of
              000 : ;
              002 : errmsg := 'File not found';
              003 : errmsg := 'Path not found';
              004 : errmsg := 'Too many open files';
              005 : errmsg := 'File access denied - invalid i/o mode';
              006 : errmsg := 'Invalid file handle - file variable trashed';
              012 : errmsg := 'Invalid file access code - filemode invalid';
              015 : errmsg := 'Invalid drive number';
              016 : errmsg := 'Cannot remove current directory';
              017 : errmsg := 'Cannot rename across drives';
              100 : errmsg := 'Disk read error - read past end of file';
              101 : errmsg := 'Disk write error - disk full';
              102 : errmsg := 'File not assigned';
              103 : errmsg := 'Not open';
              104 : errmsg := 'File not open for input';
              105 : errmsg := 'File not open for output';
              106 : errmsg := 'Invalid numeric format';
              150 : errmsg := 'Disk is write protected';
              151 : errmsg := 'Unknown unit';
              152 : errmsg := 'Drive not ready';
              153 : errmsg := 'Unknown command';
              154 : errmsg := 'CRC error in data';
              155 : errmsg := 'Bad drive request structure length';
              156 : errmsg := 'Disk seek error';
              157 : errmsg := 'Unknown media type';
              158 : errmsg := 'Sector not found';
              159 : errmsg := 'Printer out of paper';
              160 : errmsg := 'Device write fault';
              161 : errmsg := 'Device read fault';
              162 : errmsg := 'Hardware failure';
              else  errmsg := 'Unknown error';
           end;
           if WkIO <> 0 then
              begin
                 writeln;
                 writeln('File error ', WkIO, '. ', errmsg);
                 writeln;
                 
                 halt; {************* STOP PROGRAM PREMATURELY ***************}
              end;
     end;
{**************************************************************************}
procedure FileStat(var FileMsg : string; var WkIO : integer);
     begin;
           WkIO := IOResult;
           case WkIO of
              000 : FileMsg := '';
              002 : FileMsg := 'File not found';
              003 : FileMsg := 'Path not found';
              004 : FileMsg := 'Too many open files';
              005 : FileMsg := 'File access denied - invalid i/o mode';
              006 : FileMsg := 'Invalid file handle - file variable trashed';
              012 : FileMsg := 'Invalid file access code - filemode invalid';
              015 : FileMsg := 'Invalid drive number';
              016 : FileMsg := 'Cannot remove current directory';
              017 : FileMsg := 'Cannot rename across drives';
              100 : FileMsg := 'Disk read error - read past end of file';
              101 : FileMsg := 'Disk write error - disk full';
              102 : FileMsg := 'File not assigned';
              103 : FileMsg := 'Not open';
              104 : FileMsg := 'File not open for input';
              105 : FileMsg := 'File not open for output';
              106 : FileMsg := 'Invalid numeric format';
              150 : FileMsg := 'Disk is write protected';
              151 : FileMsg := 'Unknown unit';
              152 : FileMsg := 'Drive not ready';
              153 : FileMsg := 'Unknown command';
              154 : FileMsg := 'CRC error in data';
              155 : FileMsg := 'Bad drive request structure length';
              156 : FileMsg := 'Disk seek error';
              157 : FileMsg := 'Unknown media type';
              158 : FileMsg := 'Sector not found';
              159 : FileMsg := 'Printer out of paper';
              160 : FileMsg := 'Device write fault';
              161 : FileMsg := 'Device read fault';
              162 : FileMsg := 'Hardware failure';
              else  FileMsg := 'Unknown error';
           end;
     end;
