--------------------------------------------------------
--  DDL for Package Body PNUTLPKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PNUTLPKG" as
  -- $Header: PNUTLPKB.pls 115.8 2002/01/16 15:01:57 pkm ship    $

procedure pnutlput (dir in varchar2, file in varchar2, buff in varchar2) is

begin
  v_handle := utl_file.fopen(dir, file, 'w');

  utl_file.put_line(v_handle, buff);
  utl_file.fflush(v_handle);
  utl_file.fclose(v_handle);

exception
  when utl_file.invalid_path then
    raise_application_error(-20100, '-- pnutlput: invalid path');

  when utl_file.invalid_mode then
    raise_application_error(-20101, '-- pnutlput: invalid mode');

  when utl_file.invalid_filehandle then
    raise_application_error(-20102, '-- pnutlput: invalid filehandle');

  when utl_file.invalid_operation then
    raise_application_error(-20103, '-- pnutlput: invalid operation');

  when utl_file.write_error then
    raise_application_error(-20104, '-- pnutlput: write error');

  when utl_file.internal_error then
    raise_application_error(-20105, '-- pnutlput: internal_error');

end;

end;

/
