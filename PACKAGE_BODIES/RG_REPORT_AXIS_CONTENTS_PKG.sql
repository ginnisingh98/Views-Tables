--------------------------------------------------------
--  DDL for Package Body RG_REPORT_AXIS_CONTENTS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."RG_REPORT_AXIS_CONTENTS_PKG" AS
/* $Header: rgiracnb.pls 120.1 2002/11/14 03:34:32 djogg ship $ */
-- Name
--   RG_REPORT_AXIS_CONTENTS_PKG
-- Purpose
--   to include all sever side procedures and packages for table
--   RG_REPORT_AXIS_CONTENTS
-- Notes
--
-- History
--   11/01/93	A Chen	Created
--
-- PRIVATE VARIABLES
--   None.
--
-- PRIVATE FUNCTIONS
--   None.
--
-- PUBLIC FUNCTIONS
--
  FUNCTION check_existence(X_axis_set_id NUMBER,
                           X_axis_seq NUMBER) RETURN BOOLEAN IS
    dummy NUMBER;
  BEGIN

    IF (X_axis_seq IS NOT NULL) THEN
      select 1 into dummy
      from rg_report_axis_contents
      where axis_set_id = X_axis_set_id
      and axis_seq = X_axis_seq
      and rownum < 2;
      RETURN (TRUE);
    ELSE
      select 1 into dummy
      from rg_report_axis_contents
      where axis_set_id = X_axis_set_id
      and rownum < 2;
      RETURN (TRUE);
    END IF;
    EXCEPTION
      WHEN NO_DATA_FOUND THEN
        RETURN (FALSE);
  END check_existence;

  PROCEDURE delete_rows(X_axis_set_id NUMBER,
                        X_axis_seq NUMBER) IS
  BEGIN
    IF (X_axis_seq = -1) THEN
      delete from rg_report_axis_contents
       where axis_set_id = X_axis_set_id;
    ELSE
      delete from rg_report_axis_contents
      where axis_set_id = X_axis_set_id
        and axis_seq = X_axis_seq;
    END IF;
  END delete_rows;

END RG_REPORT_AXIS_CONTENTS_PKG;

/
