--------------------------------------------------------
--  DDL for Package PNUTLPKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PNUTLPKG" AUTHID CURRENT_USER as
  -- $Header: PNUTLPKS.pls 115.7 2002/11/14 20:26:01 stripath ship $

  v_handle utl_file.file_type;

  procedure pnutlput (dir in varchar2, file in varchar2, buff in varchar2);

end;

 

/
