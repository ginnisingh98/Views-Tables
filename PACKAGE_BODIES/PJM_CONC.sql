--------------------------------------------------------
--  DDL for Package Body PJM_CONC
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PJM_CONC" AS
/* $Header: PJMCONCB.pls 115.6 2002/08/14 01:16:26 alaw ship $ */
--  ---------------------------------------------------------------------
--  Public Functions / Procedures
--  ---------------------------------------------------------------------

PROCEDURE PUT_LINE (mesg IN VARCHAR2) IS
BEGIN
   if fnd_global.conc_request_id > 0 then
      fnd_file.put_line(fnd_file.log, mesg);
   end if;
END PUT_LINE;


PROCEDURE NEW_LINE (num IN NUMBER) IS
BEGIN
   if fnd_global.conc_request_id > 0 then
      fnd_file.new_line(fnd_file.log, 1);
   end if;
END NEW_LINE;


END PJM_CONC;

/
