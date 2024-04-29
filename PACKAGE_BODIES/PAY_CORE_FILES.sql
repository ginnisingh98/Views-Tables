--------------------------------------------------------
--  DDL for Package Body PAY_CORE_FILES
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PAY_CORE_FILES" as
/* $Header: pycofile.pkb 120.11.12010000.4 2010/05/20 06:33:30 phattarg ship $ */
--
-- Setup Datatypes
--
type t_file_list_rec is record
(file_detail_id     pay_file_details.file_detail_id%type,
 file_type          pay_file_details.file_type%type,
 int_file_name      varchar2(30),
 position           number,
 nxtptr             number,
 prvptr             number,
 sequence             number,
 file_locator  blob
);

type t_file_list_tab is table of t_file_list_rec index by binary_integer;

g_head_file_ptr number;
--
-- Setup Globals
--
g_file_list t_file_list_tab;
--
g_tmp_clob clob;
g_tmp_blob blob;

-- Bug 6729909 For Deleting Multiple Root Tag

g_source_type varchar2(10);
g_file_type varchar2(10);
g_flag  number;
g_payroll_id number;
g_chld_act number;
g_char_set varchar2(30);
g_bot_root_tag varchar2(30);
--
--------------------------- open_file -------------------------
/*
   NAME
      open_file - Opene a file fragment clob
   DESCRIPTION
      Open a clob.
   NOTES
      <none>
*/
procedure open_file
                  (p_source_id     in            number,
                   p_source_type   in            varchar2,
                   p_file_location in            varchar2,
                   p_file_type     in            varchar2,
                   p_int_file_name in            varchar2,
                   p_sequence      in            number,
                   p_file_id          out nocopy number
                  )
is
--
file_id number;
--
begin
--
/* chk if an open file already exits */

begin

-- Assign values to Global Variable for deleting Mul root tag
g_source_type := p_source_type;
g_file_type   := p_file_type;
g_payroll_id  := p_source_id;
g_char_set    := hr_mx_utility.get_IANA_charset;

select file_detail_id
into file_id
from pay_file_details
where source_id=p_source_id
and source_type=p_source_type
and internal_file_name=p_int_file_name
and sequence=p_sequence;

g_file_list(file_id).file_detail_id := file_id;

select blob_file_fragment
into  g_file_list(file_id).file_locator
from pay_file_details
where file_detail_id=file_id
for update of blob_file_fragment;


if (dbms_lob.isopen(g_file_list(file_id).file_locator)<>1)
then
   dbms_lob.open(g_file_list(file_id).file_locator, DBMS_LOB.LOB_READWRITE);
   dbms_lob.trim(g_file_list(file_id).file_locator, 0);
  g_file_list(file_id).position := 1;
end if;

exception
when no_data_found then
  select pay_file_details_s.nextval
    into file_id
    from dual;
--
  g_file_list(file_id).file_detail_id := file_id;
  g_file_list(file_id).position := 1;
  g_file_list(file_id).file_type := p_file_type;
  g_file_list(file_id).int_file_name := p_int_file_name;
  g_file_list(file_id).sequence := p_sequence;
--
  insert into pay_file_details
    (file_detail_id,
     source_id,
     source_type,
     file_location,
     file_type,
     internal_file_name,
     blob_file_fragment,
     sequence
    )
    values
    (file_id,
     p_source_id,
     p_source_type,
     p_file_location,
     p_file_type,
     p_int_file_name,
     empty_blob(),
     p_sequence
    );

    select blob_file_fragment
    into g_file_list(file_id).file_locator
    from pay_file_details
    where file_detail_id = file_id
      for update of blob_file_fragment;

    dbms_lob.open(g_file_list(file_id).file_locator, DBMS_LOB.LOB_READWRITE);

end;
--
  if (g_head_file_ptr is not null) then
    g_file_list(g_head_file_ptr).prvptr := file_id;
  end if;
  g_file_list(file_id).nxtptr := g_head_file_ptr;
  g_file_list(file_id).prvptr := null;
  g_head_file_ptr := file_id;
--
  p_file_id := file_id;
--
end open_file;

--
------------------------- delete_mul_root_tag -------------------------
/*
   Bug : 6729909
   NAME
      delete_mul_root_tag -
   DESCRIPTION This procedure gets called from read_from_clob
               and will delete root tag from the text except from the first fragment
	       of first file and last fragment of last file.
   NOTES
      <none>

   Bug : 6795217
   NAME
      delete_mul_root_tag -

   DESCRIPTION : Modified procedure to remove the end tags in the cases where
                 end tags is broken in 2 fragments,
		 Example End tag is '</ARCHIVE_CHEQUE_WRITER>'
                 Case 1: </ARCHIVE_CHEQUE is coming in second last fragment
                         and remaining _WRITER> is coming in last fragment
                 Case 2: < is coming in second last fragment
                         and remaining /ARCHIVE_CHEQUE_WRITER> is coming in last fragment

                 Fix : a.) Identify the Second last segment by searching for '</CHEQUE>' or '</PAYSLIP>'
                           in the last 32 or 26 character (Worse case scenario "</CHEQUE></ARCHIVE_CHEQUE_WRITER" is 32 Characters,
                           similary for Deposit Device its "</PAYSLIP></PAYSLIP_REPORT" is 26 characters).
                       b.) Strip "/" from the fragment after '</CHEQUE>' or '</PAYSLIP>' .
                       c.) Identify the last fragment , if the length of the fragment is less then the Bottom End Root Tag.
                       d.) In the last fragment if the first character is "/" remove that .
                       e.) Replace the last '>' by 'Z/>' making it a dummy tag .

   NOTES
      <none>
*/
procedure delete_mul_root_tag(p_text in out nocopy raw)
is

l_top_root_tag varchar2(30);
l_bot_root_tag varchar2(30);
l_broken_text  varchar2(30);
l_text         varchar2(2000);

begin

hr_utility.trace('Entering delete_mul_root_tag ');
l_text := utl_raw.cast_to_varchar2(p_text);
if g_source_type = 'PPA' then


   if (substr(l_text,1,5) ='<?xml') then
      if instr(l_text,'<PAYSLIP_REPORT>') <> 0 then
         l_top_root_tag := '<PAYSLIP_REPORT>' ;
         g_bot_root_tag := '</PAYSLIP_REPORT>' ;
      elsif instr(l_text,'<ARCHIVE_CHEQUE_WRITER>') <> 0 then
         l_top_root_tag := '<ARCHIVE_CHEQUE_WRITER>';
          g_bot_root_tag := '</ARCHIVE_CHEQUE_WRITER>';
      end if;

     if l_top_root_tag in ('<PAYSLIP_REPORT>', '<ARCHIVE_CHEQUE_WRITER>') then

         if g_flag <> 1 then
	    if l_top_root_tag = '<PAYSLIP_REPORT>' then
              select count(*)
              into g_chld_act
              from pay_temp_object_actions
              where payroll_action_id = g_payroll_id
              and action_status = 'C';
            elsif l_top_root_tag = '<ARCHIVE_CHEQUE_WRITER>' then

              select count(*)
              into g_chld_act
              from pay_assignment_actions
              where payroll_action_id = g_payroll_id
              and action_status IN ('C', 'S');
            end if;
         end if;

         g_chld_act := g_chld_act - 1 ;

         if g_flag = 1 then
            l_text := replace(l_text,('<?xml version="1.0" encoding="'||g_char_set||'"?>')||l_top_root_tag);
         end if;
         g_flag := 1;
     end if;

   end if;

   if (substr(l_text,-17,17) ='</PAYSLIP_REPORT>') and  g_chld_act <> 0 then
         l_bot_root_tag := '</PAYSLIP_REPORT>' ;
       l_text := replace(l_text,l_bot_root_tag);

   elsif (substr(l_text,-24,24) ='</ARCHIVE_CHEQUE_WRITER>') and  g_chld_act <> 0 then
       l_bot_root_tag := '</ARCHIVE_CHEQUE_WRITER>';
       l_text := replace(l_text,l_bot_root_tag);

/* Begin Bug 6795217 */
   elsif (instr(substr(l_text,-32,32),'</CHEQUE>') <> 0) and  g_chld_act <> 0 then

        l_broken_text := substr(l_text,(instr(l_text,'</CHEQUE>')+9));
        l_broken_text := replace(l_broken_text,'/');
        l_text        := substr(l_text,1,(instr(l_text,'</CHEQUE>')+8))||l_broken_text;

   elsif (instr(substr(l_text,-26,26),'</PAYSLIP>') <> 0) and  g_chld_act <> 0 then

        l_broken_text := substr(l_text,(instr(l_text,'</PAYSLIP>')+10));
        l_broken_text := replace(l_broken_text,'/');
        l_text        := substr(l_text,1,(instr(l_text,'</PAYSLIP>')+9))||l_broken_text;

   elsif (length(l_text) < length(g_bot_root_tag) and g_chld_act <> 0 ) then

       if substr(l_text,1,1) = '/' then
        l_text := substr(l_text,2);
       end if;

       l_text := replace(l_text,'>','Z/>');
   end if;
/* End Bug 6795217 */

end if;
p_text := utl_raw.cast_to_raw(l_text);
hr_utility.trace('Leaving delete_mul_root_tag ');

end delete_mul_root_tag;

--
--------------------------- open_clob_direct -------------------------
/*
   NAME
      open_clob_direct -
   DESCRIPTION
   NOTES
      <none>
*/
procedure open_clob_direct(p_file_id in number)
is
begin
--
    select file_fragment
    into g_tmp_clob
    from pay_file_details
   where file_detail_id = p_file_id;
--
   dbms_lob.open(g_tmp_clob, DBMS_LOB.LOB_READONLY);
--
end open_clob_direct;

procedure open_blob_direct(p_file_id in number)
is
begin
--
    select blob_file_fragment
    into g_tmp_blob
    from pay_file_details
   where file_detail_id = p_file_id;
--
   dbms_lob.open(g_tmp_blob, DBMS_LOB.LOB_READONLY);

end open_blob_direct;
--
--------------------------- read_from_clob_direct ----------------
/*
   NAME
      read_from_clob_direct - Reads directly from a clob
   DESCRIPTION
   NOTES
      <none>
*/
procedure read_from_clob_direct
          ( p_clob    in            clob,
           p_size     in out nocopy number,
           p_position in            number,
           p_text        out nocopy varchar2
          )
is
--
begin
--
   dbms_lob.read(p_clob,
                 p_size,
                 p_position,
                 p_text
                );
--
exception
    when no_data_found then
      p_text := null;
--
end read_from_clob_direct;


procedure read_from_blob_direct
          ( p_blob    in            blob,
           p_size     in out nocopy number,
           p_position in            number,
           p_text        out nocopy varchar2
          )
is
raw_data raw(8000);    --changed raw_data size from 2000 bug no 4775422
--
begin
--
   dbms_lob.read(p_blob,
                 p_size,
                 p_position,
                 raw_data
                );
   p_text:=utl_raw.cast_to_varchar2(raw_data);
--
exception
    when no_data_found then
      p_text := null;
--
end read_from_blob_direct;
--
--------------------------- close_clob_direct ----------------
/*
   NAME
      close_clob_direct - Closes the global clob
   DESCRIPTION
   NOTES
      <none>
*/
procedure close_clob_direct
is
begin
--
   dbms_lob.close(g_tmp_clob);
   g_tmp_clob := null;
--
end close_clob_direct;
--

procedure close_blob_direct
is
begin
--
   dbms_lob.close(g_tmp_blob);
   g_tmp_blob := null;
--
end close_blob_direct;
--
--------------------------- read_from_clob ----------------
/*
   NAME
      read_from_clob - Read from a specified clob
   DESCRIPTION
      This reads from a specified file/clob in the
      global pointer.
   NOTES
      <none>
*/
procedure read_from_clob
          (
           p_file_id  in            number,
           p_size     in out nocopy number,
           p_position in            number,
           p_text        out nocopy varchar2
          )
is
l_size number;
l_file_type pay_file_details.file_type%type;
l_raw_text raw(8000);
begin
--

   if (g_tmp_blob is null) then
       open_blob_direct(p_file_id);
   end if;
--
   l_size := p_size;
   read_from_blob_direct
          (g_tmp_blob,
           l_size,
           p_position,
           p_text
          );

  /* Bug 6729909 Calling  delete_mul_root_tag(p_text) to remove the top Level tag for merging of XML */
   l_raw_text := utl_raw.cast_to_raw(p_text);
   delete_mul_root_tag(l_raw_text);
   p_text := utl_raw.cast_to_varchar2(l_raw_text);

      close_blob_direct;
  /* commented for bug no 4775422
   if (p_text is null or p_size <> l_size) then
     close_blob_direct;
   end if;*/
--
   p_size := l_size;
--
end;
--
procedure read_from_clob
          (
           p_clob     in            clob,
           p_size     in out nocopy number,
           p_position in            number,
           p_text        out nocopy varchar2
          )
is
l_size number;
begin
--
   l_size := p_size;
   read_from_clob_direct
          (p_clob,
           l_size,
           p_position,
           p_text
          );
--
   p_size := l_size;
--
end;
--------------------------- read_from_clob_raw ----------------
/*
   NAME
      read_from_clob_raw - Read from a specified clob
   DESCRIPTION
      This reads from a specified file/clob in the
      global pointer and returns raw chunk for File types
      PDF and CATPDF.
   NOTES
      <none>
*/
procedure read_from_clob_raw
          (
           p_file_id  in            number,
           p_size     in out nocopy number,
           p_position in            number,
           p_text        out nocopy raw
          )
is
l_size number;
l_file_type pay_file_details.file_type%type;
raw_data raw(8000);
begin
--
   if (g_tmp_blob is null) then
       open_blob_direct(p_file_id);
   end if;
--
Begin
   l_size := p_size;
   dbms_lob.read(g_tmp_blob,
                 l_size,
                 p_position,
                 raw_data
                );
   p_text:=raw_data;

exception
    when no_data_found then
      p_text := null;
      l_size := 0;
end;
--
      delete_mul_root_tag(p_text);
      close_blob_direct;
--
   p_size := l_size;
--
end;
--
--
--------------------------- write_to_file -------------------------
/*
   NAME
      write_to_file - Write text to the clob
   DESCRIPTION
      Write text to the specified clob
   NOTES
      <none>
*/
procedure write_to_file
          (p_file_id in number,
           p_text    in varchar2
          )
is
--
text_size number;
raw_data raw(8000);
lob_len  number;
--
begin
--
    raw_data:=utl_raw.cast_to_raw(p_text);
    text_size:=utl_raw.length(raw_data);
    hr_utility.trace('p_text size = ' || to_char(length(p_text)));
    hr_utility.trace('raw_data Size = ' || text_size);

    dbms_lob.write(g_file_list(p_file_id).file_locator,
                  text_size,
                  g_file_list(p_file_id).position,
                  raw_data
                 );
   g_file_list(p_file_id).position := g_file_list(p_file_id).position
                                     + text_size;
   hr_utility.trace('Blob Size = ' ||
                    to_char(dbms_lob.getlength(g_file_list(p_file_id).file_locator)));
--
end write_to_file;
--
--------------------------- write_to_file_raw -------------------------
/*
   NAME
      write_to_file_raw - Write text to the clob
   DESCRIPTION
      Write text to the specified clob
   NOTES
      <none>
*/
procedure write_to_file_raw
          (p_file_id in number,
           p_text    in raw
          )
is
--
text_size number;
raw_data raw(8000);
lob_len  number;
--
begin
--
--
    raw_data:= p_text;
    text_size:=utl_raw.length(raw_data);
    hr_utility.trace('p_text size = ' || to_char(length(p_text)));
    hr_utility.trace('raw_data Size = ' || text_size);

    dbms_lob.write(g_file_list(p_file_id).file_locator,
                  text_size,
                  g_file_list(p_file_id).position,
                  raw_data
                 );
   g_file_list(p_file_id).position := g_file_list(p_file_id).position
                                     + text_size;
   hr_utility.trace('Blob Size = ' ||
                    to_char(dbms_lob.getlength(g_file_list(p_file_id).file_locator)));
--
end write_to_file_raw;
--
--------------------------- close_file -------------------------
/*
   NAME
      close_file - Close the clob
   DESCRIPTION
      Close teh specified clob and delete the row from the plsql
      table.
   NOTES
      <none>
*/
procedure close_file
               (p_file_id in number)
is
prvptr number;
nxtptr number;
begin
--
     dbms_lob.close(g_file_list(p_file_id).file_locator);

--
  prvptr := g_file_list(p_file_id).prvptr ;
  nxtptr := g_file_list(p_file_id).nxtptr ;
--
  if (prvptr is not null) then
     g_file_list(prvptr).nxtptr := g_file_list(p_file_id).nxtptr;
  else
     g_head_file_ptr := g_file_list(p_file_id).nxtptr;
  end if;
--
  if (nxtptr is not null) then
     g_file_list(nxtptr).prvptr := g_file_list(p_file_id).prvptr;
  end if;
--
  g_file_list.delete(p_file_id);
--
end close_file;
--
--------------------------- open_temp_file -------------------------
/*
   NAME
      open_temp_file - Open temporary file
   DESCRIPTION
      open a temporary file
   NOTES
      <none>
*/
procedure open_temp_file
               (p_file in out nocopy clob)
is
begin
   dbms_lob.createtemporary(p_file, TRUE);
end open_temp_file;
--
--------------------------- close_temp_file -------------------------
/*
   NAME
      close_temp_file - Close temporary file
   DESCRIPTION
      close a temporary file
   NOTES
      <none>
*/
procedure close_temp_file(p_file in out nocopy clob)
is
begin
   dbms_lob.freetemporary(p_file);
end close_temp_file;
--
-- Added for Bug # 3688801.
--------------------------- form_read_clob ---------------------
/*
   NAME
      form_read_clob - Read from a clob
   DESCRIPTION
      This reads from a clob and is called from the form.

   NOTES
      <none>
*/
procedure form_read_clob
          (
           p_file_id  in            number,
           p_size     in out nocopy number,
           p_position in            number,
           p_text        out nocopy varchar2
          )
is
l_size number;
l_clob clob;
begin
--
  select file_fragment
    into l_clob
    from pay_file_details
   where file_detail_id = p_file_id;
--
   if l_clob is null then
      p_size := 0;
      p_text := null;
      return;
   end if;
--
   dbms_lob.open(l_clob, DBMS_LOB.LOB_READONLY);
--
   l_size := p_size;
   read_from_clob_direct
          (l_clob,
           l_size,
           p_position,
           p_text
          );
--
   dbms_lob.close(l_clob);
--
   p_size := l_size;
--
end form_read_clob;
--
--------------------------- return_clob_length --------------
/*
   NAME
      return_clob_length - Get the length of the clob
   DESCRIPTION
      This returns the length of the specified file/clob.
   NOTES
      <none>
*/
function return_clob_length
          ( p_file_id  in  number )
return number
is
--
l_clob clob;
l_length number;
--
begin
--
   select file_fragment
     into l_clob
     from pay_file_details
     where file_detail_id = p_file_id;
--
   if l_clob is null then
      return null;
   end if;
--
    dbms_lob.open(l_clob, DBMS_LOB.LOB_READONLY);
--
    l_length := DBMS_LOB.GETLENGTH(l_clob);

    dbms_lob.close(l_clob);
--
    return l_length;
--
end return_clob_length;

function return_length
          ( p_file_id  in  number )
return number
is
--
l_blob blob;
l_length number;
--
begin
--
   select blob_file_fragment
     into l_blob
     from pay_file_details
     where file_detail_id = p_file_id;
--
   if l_blob is null then
      return null;
   end if;
--
    dbms_lob.open(l_blob, DBMS_LOB.LOB_READONLY);
--
    l_length := DBMS_LOB.GETLENGTH(l_blob);

    dbms_lob.close(l_blob);
--
    return l_length;
--
end return_length;

procedure write_to_magtape_lob(p_text in varchar)
is
text_size number;
raw_data raw(32767);
begin
raw_data:=utl_raw.cast_to_raw(p_text);
text_size:=utl_raw.length(raw_data);
   dbms_lob.writeappend(pay_mag_tape.g_blob_value,
                  text_size,
                  raw_data
                 );
end;

procedure write_to_magtape_lob(p_data in blob)
is
begin
   dbms_lob.append(pay_mag_tape.g_blob_value,
                  p_data);
end;

--
begin
--
  g_head_file_ptr := null;
  g_tmp_clob := null;
--

--Bug 6729909 Initializae Variable for Deleting Mul root tag
  g_source_type := null;
  g_file_type := null;
  g_flag  := 0;
  g_payroll_id := 0;
  g_chld_act := null;
  g_char_set := null;

end pay_core_files;

/
