--------------------------------------------------------
--  DDL for Package Body ECX_ENG_UTILS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."ECX_ENG_UTILS" as
-- $Header: ECXENUTB.pls 120.3 2006/05/24 16:24:01 susaha ship $

l_procedure          PLS_INTEGER := ecx_debug.g_procedure;
l_statement          PLS_INTEGER := ecx_debug.g_statement;
l_unexpected         PLS_INTEGER := ecx_debug.g_unexpected;
l_procedureEnabled   boolean     := ecx_debug.g_procedureEnabled;
l_statementEnabled   boolean     := ecx_debug.g_statementEnabled;
l_unexpectedEnabled  boolean     := ecx_debug.g_unexpectedEnabled;

-- generates a cXML standard conforming payloadID
procedure generate_cXML_payloadID (p_document_number  in     varchar2,
                                   x_payload_id       out    NOCOPY varchar2)
is


i_method_name   varchar2(2000) := 'ecx_eng_utils.generate_cXML_payloadID';

   random_number NUMBER := null;
   logical_id    VARCHAR2(2000) := null;
   date_time     VARCHAR2(100) := null;
   invalid_input EXCEPTION;

begin

   if (l_procedureEnabled) then
     ecx_debug.push(i_method_name);
   end if;

   if (p_document_number is null) then
     raise invalid_input;
   end if;

   random_number := wf_core.random;
   logical_id := ecx_trading_partner_pvt.getOAGLOGICALID();
   date_time := to_char(sysdate, 'YYYY-MM-DD-HH24-MI-SS');

   x_payload_id := (date_time || '.' || p_document_number || '.' || random_number || '@' || logical_id);

  if (l_procedureEnabled) then
    ecx_debug.pop(i_method_name);
  end if;

exception

  when invalid_input then
     ecx_debug.setErrorInfo(2, 30, SQLERRM || ' - ECX_ENG_UTILS.GENERATE_CXML_PAYLOADID INVALID INPUT DOCUMENT NUMBER');
     if(l_unexpectedEnabled) then
         ecx_debug.log(l_unexpected,'ECX', SQLERRM || ' - ECX_ENG_UTILS.GENERATE_CXML_PAYLOADID',
	              i_method_name);
     end if;
     if (l_procedureEnabled) then
      ecx_debug.pop(i_method_name);
     end if;
     raise ecx_utils.program_exit;

  when others then
     ecx_debug.setErrorInfo(2, 30, SQLERRM || ' - ECX_ENG_UTILS.GENERATE_CXML_PAYLOADID');
     if(l_unexpectedEnabled) then
       ecx_debug.log(l_unexpected,'ECX', SQLERRM || ' - ECX_ENG_UTILS.GENERATE_CXML_PAYLOADID',
                    i_method_name);
     end if;
     if (l_procedureEnabled) then
      ecx_debug.pop(i_method_name);
     end if;
     raise ecx_utils.program_exit;


end generate_cXML_payloadID;


-- validates the date against various cXML formats and returns the
-- converted datetime as per the specified timezone
Function getDate (cXMLdate varchar2, dbTimezone varchar2)
return varchar2
is language java
name 'oracle.apps.ecx.util.cXMLDateTimeFormat.getDate(java.lang.String, java.lang.String)
returns java.lang.String';


-- converts oracle date into cXML date format
procedure convert_to_cxml_date (p_ora_date	in	date,
				x_cxml_date	out	NOCOPY varchar2
				)
is

   i_method_name   varchar2(2000) := 'ecx_eng_utils.convert_to_cxml_date';
   l_year	varchar2(200);
   l_month	varchar2(200);
   l_day	varchar2(200);
begin
    if (l_procedureEnabled) then
     ecx_debug.push(i_method_name);
   end if;
   if (p_ora_date is not null)
   then
      l_year := to_char(p_ora_date, 'YYYY');
      l_month := to_char(p_ora_date, 'MM');
      l_day := to_char(p_ora_date, 'DD');

      x_cxml_date := l_year || '-' || l_month || '-' || l_day;
   else
      x_cxml_date := null;
   end if;

   if (l_procedureEnabled) then
    ecx_debug.pop(i_method_name);
   end if;

exception
when others then
   ecx_debug.setErrorInfo(2, 30, SQLERRM || ' - ECX_ENG_UTILS.CONVERT_TO_CXML_DATE');
   if(l_unexpectedEnabled) then
     ecx_debug.log(l_unexpected,'ECX', SQLERRM || ' - ECX_ENG_UTILS.CONVERT_TO_CXML_DATE',
                  i_method_name);
   end if;
   if (l_procedureEnabled) then
    ecx_debug.pop(i_method_name);
   end if;
   raise ecx_utils.program_exit;
end convert_to_cxml_date;


-- converts oracle date into cXML datetime format
procedure convert_to_cXML_datetime (p_ora_date	in	date,
				    x_cxml_date	out	NOCOPY varchar2
				    )
is

   i_method_name   varchar2(2000) := 'ecx_eng_utils.convert_to_cXML_datetime';
   l_ora_date		varchar2(200);
   l_install_mode	varchar2(200);
   l_year		varchar2(200);
   l_month		varchar2(200);
   l_day		varchar2(200);
   l_hour		varchar2(200);
   l_min		varchar2(200);
   l_sec		varchar2(200);
   l_string             varchar2(2000);
   l_offset		number;
   l_offset_hours	number;
   l_offset_mins	number;
   l_timezone		varchar2(200);
   l_timezone_sign	varchar2(200);

begin
   if (l_procedureEnabled) then
     ecx_debug.push(i_method_name);
   end if;

   l_ora_date := to_char(p_ora_date, 'YYYYMMDD HH24MISS');

   if (l_ora_date is not null)
   then

      if (ecx_eng_utils.g_server_tz is null) then
         -- get the timezone string
         -- Check for the Installation Type ( Standalone or Embedded );
         l_install_mode := wf_core.translate('WF_INSTALL');
         if l_install_mode = 'EMBEDDED'
         then
            l_string := 'begin
              fnd_profile.get(' || '''ECX_SERVER_TIMEZONE''' || ', ecx_eng_utils.g_server_tz);
              end;';
            execute immediate l_string ;
         else
            ecx_eng_utils.g_server_tz:= wf_core.translate('ECX_SERVER_TIMEZONE');
         end if;
      end if;

      if (ecx_eng_utils.g_server_tz is null)
      then
         ecx_eng_utils.g_server_tz := 'GMT';
      end if;

      l_year := to_char(p_ora_date, 'YYYY');
      l_month := to_char(p_ora_date, 'MM');
      l_day := to_char(p_ora_date, 'DD');
      l_hour := to_char(p_ora_date, 'HH');
      l_min := to_char(p_ora_date, 'MI');
      l_sec := to_char(p_ora_date, 'SS');

      -- get the deviation
      l_offset := ecx_actions.getTimezoneOffset( to_number(l_year), to_number(l_month),
                                                 to_number(l_day), to_number(l_hour),
                                                 to_number(l_min), to_number(l_sec),
                                                 ecx_eng_utils.g_server_tz);

      if l_offset >= 0 then
         l_timezone_sign := '+';
      end if;

      -- calculate the timezone in the required format
      l_offset_hours := floor(l_offset);

      l_offset_mins := (l_offset * 60)  mod 60;

      l_timezone := rtrim(ltrim(to_char(l_offset_hours, '09'))) ||':'||
                    rtrim(ltrim(to_char(l_offset_mins, '09')));

      if l_timezone_sign is NOT NULL then
         l_timezone := l_timezone_sign || l_timezone;
      end if;

      x_cxml_date := l_year  || '-' || l_month || '-' || l_day || 'T' || l_hour || ':' ||
                     l_min || ':' || l_sec || l_timezone;
   else
      x_cxml_date := null;
   end if;
  if (l_procedureEnabled) then
    ecx_debug.pop(i_method_name);
  end if;
exception
when ecx_utils.program_exit then
   if (l_procedureEnabled) then
     ecx_debug.pop(i_method_name);
   end if;
   raise ecx_utils.program_exit;
when others then
   ecx_debug.setErrorInfo(2, 30, SQLERRM || ' - ECX_ENG_UTILS.CONVERT_TO_CXML_DATETIME');
   if(l_unexpectedEnabled) then
     ecx_debug.log(l_unexpected,'ECX', SQLERRM || ' - ECX_ENG_UTILS.CONVERT_TO_CXML_DATETIME',
                  i_method_name);
   end if;
   if (l_procedureEnabled) then
    ecx_debug.pop(i_method_name);
   end if;
   raise ecx_utils.program_exit;
end convert_to_cXML_datetime;


-- converts the cxml datetime to oracle date
procedure convert_from_cXML_datetime (p_cxml_date	in	varchar2,
                                      x_ora_date	out	NOCOPY date
	     			      )
is

   i_method_name   varchar2(2000) := 'ecx_eng_utils.convert_from_cXML_datetime';
   l_format_date	varchar2(200);
   l_string             varchar2(2000);
   l_install_mode	varchar2(200);
begin
   if (l_procedureEnabled) then
     ecx_debug.push(i_method_name);
   end if;
   if (p_cxml_date is not null)
   then

      if (ecx_eng_utils.g_server_tz is null) then
         -- get the DB timezone ID
         -- Check for the Installation Type ( Standalone or Embedded );
         l_install_mode := wf_core.translate('WF_INSTALL');

         if l_install_mode = 'EMBEDDED'
         then
            l_string := 'begin
              fnd_profile.get(' || '''ECX_SERVER_TIMEZONE''' || ', ecx_eng_utils.g_server_tz);
              end;';
            execute immediate l_string ;
         else
            ecx_eng_utils.g_server_tz:= wf_core.translate('ECX_SERVER_TIMEZONE');
         end if;
      end if;

      if (ecx_eng_utils.g_server_tz is null)
      then
         ecx_eng_utils.g_server_tz := 'GMT';
      end if;

      l_format_date := getDate(p_cxml_date, ecx_eng_utils.g_server_tz);

      if (l_format_date is null)
      then
         ecx_debug.setErrorInfo(1, 30, 'ECX_INVALID_CXML_DATE_FORMAT', 'DATE', p_cxml_date);

	 if(l_unexpectedEnabled) then
            ecx_debug.log(l_unexpected, 'ECX', 'ECX_INVALID_CXML_DATE_FORMAT', i_method_name, 'DATE', p_cxml_date);
	 end if;

         raise ecx_utils.program_exit;
      else
         x_ora_date := to_date(l_format_date, 'YYYYMMDD HH24MISS');
      end if;
   else
      x_ora_date := null;
   end if;
   if (l_procedureEnabled) then
    ecx_debug.pop(i_method_name);
  end if;
exception
when ecx_utils.program_exit then
   if (l_procedureEnabled) then
     ecx_debug.pop(i_method_name);
   end if;
   raise ecx_utils.program_exit;

when others then
   ecx_debug.setErrorInfo(2, 30, SQLERRM || ' - ECX_ENG_UTILS.CONVERT_FROM_CXML_DATETIME');
   if(l_unexpectedEnabled) then
      ecx_debug.log(l_unexpected,'ECX', SQLERRM || ' - ECX_ENG_UTILS.CONVERT_FROM_CXML_DATETIME',i_method_name);
   end if;
   if (l_procedureEnabled) then
     ecx_debug.pop(i_method_name);
   end if;
   raise ecx_utils.program_exit;
end convert_from_cXML_datetime;


/*
   Return the password from ecx_tp_details based on the tp_detail_id
   stored in ecx_utils.g_tp_dtl_id
*/
procedure get_tp_pwd (
                     x_password         OUT NOCOPY Varchar2
                     )
is

i_method_name   varchar2(2000) := 'ecx_eng_utils.get_tp_pwd';
begin
   if (l_procedureEnabled) then
     ecx_debug.push(i_method_name);
   end if;

   if(l_statementEnabled) then
    ecx_debug.log(l_statement, 'tp_detail_id', ecx_utils.g_tp_dtl_id,i_method_name);
   end if;
   select  password
   into    x_password
   from    ecx_tp_details
   where   tp_detail_id = ecx_utils.g_tp_dtl_id;

   if (x_password is not null)
   then
      x_password := ecx_eng_utils.PWD_SPEC_CODE || x_password ||
                    ecx_eng_utils.PWD_SPEC_CODE;
   end if;
   if(l_statementEnabled) then
     ecx_debug.log(l_statement,'password', x_password,i_method_name);
   end if;
   if (l_procedureEnabled) then
    ecx_debug.pop(i_method_name);
  end if;
exception
when no_data_found then
   ecx_debug.setErrorInfo(1, 30, 'ECX_TP_DTL_ID_NOT_FOUND', 'TP_DTL_ID', ecx_utils.g_tp_dtl_id);
   if(l_unexpectedEnabled) then
      ecx_debug.log(l_unexpected,'ECX', 'ECX_TP_DTL_ID_NOT_FOUND', 'TP_DTL_ID', ecx_utils.g_tp_dtl_id,i_method_name);
   end if;
   if (l_procedureEnabled) then
      ecx_debug.pop(i_method_name);
   end if;
   raise ecx_utils.program_exit;

when ecx_utils.program_exit then
   if (l_procedureEnabled) then
    ecx_debug.pop(i_method_name);
   end if;
   raise ecx_utils.program_exit;

when others then
   ecx_debug.setErrorInfo(2, 30, SQLERRM || ' - ECX_ENG_UTILS.GET_TP_PASSWORD');
   if(l_unexpectedEnabled) then
      ecx_debug.log(l_unexpected,'ECX', SQLERRM || ' - ECX_ENG_UTILS.GET_TP_PASSWORD',i_method_name);
   end if;
   if (l_procedureEnabled) then
     ecx_debug.pop(i_method_name);
   end if;
   raise ecx_utils.program_exit;

end get_tp_pwd;


procedure convertEncryCodeClob(
   p_clob      IN           CLOB,
   x_clob      OUT  NOCOPY  CLOB
   ) is

   i_method_name   varchar2(2000) := 'ecx_eng_utils.convertEncryCodeClob';
   l_in_clob_len    number := 0;
   l_start_code     varchar2(50);
   l_start_code_len pls_integer;
   l_start_code_pos number := 0;
   l_end_code       varchar2(50);
   l_end_code_len   pls_integer;
   l_end_code_pos   number := 0;
   l_offset         number := 1;
   l_spec_str       varchar2(2000);
   l_spec_str_len   number := 0;
   l_out_string     Varchar2(2000);
   l_amount         number := 0;
   l_errmsg         Varchar2(2000);
   l_errcode        pls_integer;

begin

   if (l_procedureEnabled) then
     ecx_debug.push(i_method_name);
   end if;

   if (p_clob is null) then
      return;
   end if;

   l_in_clob_len    := dbms_lob.getlength(p_clob);
   if (l_in_clob_len = 0) then
      return;
   end if;

   l_start_code     := ecx_eng_utils.PWD_SPEC_CODE;
   l_start_code_len := length(l_start_code);
   l_end_code       := ecx_eng_utils.PWD_SPEC_CODE;
   l_end_code_len   := length(l_end_code);

   if (x_clob is null) then
      dbms_lob.createtemporary(x_clob, true, dbms_lob.session);
   end if;

   loop
      if (l_offset >= l_in_clob_len) then
         exit;
      end if;

      -- Get the start offset of special character field.
      l_start_code_pos := dbms_lob.instr(p_clob, l_start_code, l_offset);

      if(l_statementEnabled) then
          ecx_debug.log(l_statement,'l_start_code_pos', l_start_code_pos,i_method_name);
      end if;

      -- if cannot find the special char anymore, then write the rest of the clob.
      if (l_start_code_pos = 0 or l_start_code_pos is null) then
         dbms_lob.copy(x_clob, p_clob, l_in_clob_len - l_offset + 1,
                       dbms_lob.getlength(x_clob)+1, l_offset);
         exit;
      else
         -- write all the data that is before the special code.
         l_amount := l_start_code_pos - l_offset;
         if (l_amount > 0) then
            dbms_lob.copy(x_clob, p_clob, l_amount,
                          dbms_lob.getlength(x_clob)+1, l_offset);
         end if;

         -- find the end of the special code and figure out the special string.
         l_end_code_pos   := dbms_lob.instr(p_clob, l_end_code,
                                            l_start_code_pos + l_start_code_len);

         if(l_statementEnabled) then
             ecx_debug.log(l_statement,'l_end_code_pos', l_end_code_pos,i_method_name);
	 end if;
         l_spec_str_len := l_end_code_pos - (l_start_code_pos + l_start_code_len);

         if (l_spec_str_len > 0) then
            -- we assume that between two special set of character is the
            -- password and this need to be call the ecx_data_encrypt.
            -- get the string between two set of special characters.
            l_spec_str := dbms_lob.substr(p_clob, l_spec_str_len,
                                          l_start_code_pos + l_start_code_len);

            l_out_string := l_spec_str;
            ecx_print_local.replace_spec_char(p_value => l_out_string,
                                              x_value => l_spec_str);

            if(l_statementEnabled) then
                 ecx_debug.log(l_statement,'String before decryption', l_spec_str,i_method_name);
            end if;
            ecx_obfuscate.ecx_data_encrypt(l_input_string  => l_spec_str,
                                           l_qual_code     => 'D',
                                           l_output_string => l_out_string,
                                           errmsg          => l_errmsg,
                                           retcode         => l_errcode);

            if (l_errcode <> 0) then
               if(l_unexpectedEnabled) then
                   ecx_debug.log(l_unexpected,'Decryption API Error', l_errmsg,i_method_name);
	       end if;
               ecx_debug.setErrorInfo(l_errcode, ecx_utils.error_type, l_errmsg);
               raise ecx_utils.program_exit;
            end if;

            -- if it is not a valid encrypted password, ecx_data_encrypt returns null.
            -- we want to keep the same value if this is not able to decrypt.
            if (l_out_string is null) then
               l_out_string := l_spec_str;
            end if;

            ecx_print_local.escape_spec_char(p_value => l_out_string,
                                           x_value => l_spec_str);

            dbms_lob.writeappend(x_clob, length(l_spec_str), l_spec_str);
         end if;

         l_offset := l_end_code_pos + l_end_code_len;
      end if;
   end loop;
  if (l_procedureEnabled) then
    ecx_debug.pop(i_method_name);
  end if;

exception
   when others then
      ecx_debug.setErrorInfo(2, 30, SQLERRM || ' - ECX_ENG_UTILS.convertEncryCodeClob');
      if(l_unexpectedEnabled) then
          ecx_debug.log(l_unexpected,'ECX', SQLERRM || ' - ECX_ENG_UTILS.convertEncryCodeClob',
	               i_method_name);
      end if;
      if (l_procedureEnabled) then
       ecx_debug.pop(i_method_name);
      end if;
      raise ecx_utils.program_exit;
end convertEncryCodeClob;


end ecx_eng_utils;

/
