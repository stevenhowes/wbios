{$i-,r-,s-}

{ paste user logo file into BIOS binary

  Text structure:

  ## signature	(2 bytes, at multiple of 4096)

  checksum	(1 byte, to avoid messing up main checksum)

  text		(253 bytes, terminated / padded by 0)

  Compiler:	Borland Pascal 7.0

  History:

  pd 040220	initial code
}

const
  biosstart=$18000;
  sig1=ord('#');
  sig2=ord('#');

var
  fi:file;
  fn:string;
  i,base:word;
  newsum,oldsum:byte;
  buf:array[0..32767] of byte;
  newtext:array[0..252] of byte;

procedure iochk;
begin
  if ioresult<>0 then begin
    writeln('I/O error: ',fn);
    halt(1);
  end;
end;

begin
  if paramcount<>2 then begin
    write('Usage: <ROM file> <text file>');
    halt(1);
  end;

  { read new text file }

  assign(fi,paramstr(2));
  reset(fi,1); iochk;
  fillchar(newtext,sizeof(newtext),0);
  blockread(fi,newtext,sizeof(newtext),i); iochk;
  close(fi); iochk;
  newsum:=0;
  for i:=0 to 252 do
    inc(newsum,newtext[i]);

  { open ROM file }

  assign(fi,paramstr(1));
  reset(fi,1); iochk;
  seek(fi,biosstart); iochk;
  blockread(fi,buf,sizeof(buf)); iochk;
  write('BIOS date: ');
  for i:=$7ff5 to $7ffc do
    write(char(buf[i]));
  writeln;

  { find message base }

  base:=0;
  while (buf[base]<>sig1) or (buf[base+1]<>sig2) do begin
    inc(base,$1000);
    if base=sizeof(buf) then begin
      write('Signature not found !');
      halt(1);
    end;
  end;

  { calculate old checksum }

  oldsum:=0;
  for i:=base+3 to base+255 do
    inc(oldsum,buf[i]);

  { insert new text }

  move(newtext,buf[base+3],253);
  inc(buf[base+2],oldsum-newsum);	{ update checksum }

  { write back to file }

  seek(fi,biosstart+base); iochk;
  blockwrite(fi,buf[base],256); iochk;
  close(fi); iochk;
  writeln('BIOS file updated.');
end.
