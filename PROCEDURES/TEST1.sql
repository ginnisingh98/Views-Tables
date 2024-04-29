--------------------------------------------------------
--  DDL for Procedure TEST1
--------------------------------------------------------
set define off;

  CREATE OR REPLACE EDITIONABLE PROCEDURE "APPS"."TEST1" AUTHID CURRENT_USER as
BEGIN
  Begin
      dbms_output.put_line('Testing');
  end;
END;

 

/
