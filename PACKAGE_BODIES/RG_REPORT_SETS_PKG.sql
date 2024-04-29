--------------------------------------------------------
--  DDL for Package Body RG_REPORT_SETS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."RG_REPORT_SETS_PKG" AS
/* $Header: rgirsetb.pls 120.1 2003/04/29 01:29:29 djogg ship $ */
  --
  -- PUBLIC FUNCTION
  --

  FUNCTION new_report_set_id
                  RETURN        NUMBER
  IS
	new_sequence_number     NUMBER;
  BEGIN
        SELECT rg_report_sets_s.nextval
        INTO   new_sequence_number
        FROM   dual;

        RETURN(new_sequence_number);
  END new_report_set_id;


  FUNCTION check_dup_report_set_name(   cur_application_id IN   NUMBER,
				        cur_report_set_id  IN	NUMBER,
					new_name           IN   VARCHAR2)
                  RETURN        BOOLEAN
  IS
	rec_returned	NUMBER;
  BEGIN
     SELECT count(*)
     INTO   rec_returned
     FROM   rg_report_sets
     WHERE  report_set_id <> cur_report_set_id
     AND    name = new_name
     AND    application_id = cur_application_id;

     IF rec_returned > 0 THEN
            RETURN(TRUE);
     ELSE
            RETURN(FALSE);
     END IF;
  END check_dup_report_set_name;

END rg_report_sets_pkg;

/
