--------------------------------------------------------
--  DDL for Package Body FND_HTTP
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."FND_HTTP" AS
/* $Header: AFSCHTPB.pls 115.3 99/07/16 23:28:56 porting ship  $ */

chr_newline varchar2(1) := '
';

-- Makes a http request to a java servlet. Parses the returned HTML
-- page and stores the values in the OUT parameters.
-- p_result is the value returned from the java servlet.This is
-- usually true or false, but it may also be error codes.
-- If the java program had any other information to return, these are
-- returned as a PL/SQL table of name-value pairs.
-- If the call failed, then the errors from the error stack are
-- returned in a PL/SQL table of encoded messages.
-- The caller should call fnd_message.set_encoded and fnd_message.get
-- to get the entire translated message.

PROCEDURE java_serv( p_url IN VARCHAR2,
		     p_result OUT VARCHAR2,
		     p_output_tab OUT output_tab_type,
		     p_encoded_errors_tab OUT error_tab_type)
  IS
     serv_result VARCHAR2(25000);

     res_start INTEGER;
     res_end INTEGER;

     out_list_start INTEGER;
     out_list_end INTEGER;
     out_start INTEGER;
     out_end INTEGER;
     out_list VARCHAR2(10000);
     out_name_value VARCHAR2(300);
     equal_pos INTEGER;
     name VARCHAR2(30);
     value VARCHAR2(240);


     err_stack_start INTEGER;
     err_stack_end INTEGER;
     err_start INTEGER;
     err_end INTEGER;
     err_stack VARCHAR2(10000);
     i INTEGER;

BEGIN

   serv_result:=utl_http.request(p_url);
   res_start:=Instr(serv_result,'<P>',1,1);
   IF res_start=0 THEN
      p_result:='false';
      RETURN;
   END IF;
   res_start:=res_start+3;
   res_end:=Instr(serv_result,'</P>',res_start,1);
   p_result:=Ltrim(Rtrim(Substr(serv_result,res_start,res_end-res_start),fnd_http.chr_newline),fnd_http.chr_newline);


   I:=1;
   out_list_start:=Instr(serv_result,'<P>',1,2);
   IF out_list_start=0 THEN
      p_result:='false';
      RETURN;
   END IF;
   out_list_start:=out_list_start+3;
   out_list_end:=Instr(serv_result,'</P>',out_list_start,1);
   out_list:=Substr(serv_result,out_list_start,out_list_end-out_list_start);
   out_start:=1;
   out_end:=out_list_end;

   WHILE true LOOP
      out_end:=Instr(out_list,'<BR>',out_start,1);
      EXIT WHEN out_start>out_end;
      out_name_value:=Substr(out_list,out_start,out_end-out_start);
      equal_pos:=Instr(out_name_value,'=',1,1);
      p_output_tab(i).name:=Ltrim(Rtrim(Substr(out_name_value,1,equal_pos-1),fnd_http.chr_newline),fnd_http.chr_newline);
      p_output_tab(i).value:=Ltrim(Rtrim(Substr(out_name_value,equal_pos+1,out_end-equal_pos),fnd_http.chr_newline),fnd_http.chr_newline);
      out_start:=out_end+4;
      i:=i+1;
   END LOOP;

   i:=1;
   err_stack_start:=Instr(serv_result,'<P>',1,3);
   IF err_stack_start=0  THEN
      p_result:='false';
      RETURN;
   END IF;
   err_stack_start:=err_stack_start+3;
   err_stack_end:=Instr(serv_result,'</P>',err_stack_start,1);
   err_stack:=Substr(serv_result,err_stack_start,err_stack_end-err_stack_start);
   err_start:=1;
   err_end:=err_stack_end;
   WHILE TRUE LOOP
      err_end:=Instr(err_stack,'<BR>',err_start,1);
      EXIT WHEN err_start>err_end;
      p_encoded_errors_tab(i):=Ltrim(Rtrim(Substr(err_stack,err_start,err_end-err_start),fnd_http.chr_newline),fnd_http.chr_newline);
      err_start:=err_end+4;
      i:=i+1;
   END LOOP;

  EXCEPTION WHEN OTHERS THEN
     p_result:='false';
END;
  END fnd_http;

/
