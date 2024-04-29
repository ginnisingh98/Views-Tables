--------------------------------------------------------
--  DDL for Package Body AP_WEB_DB_EXP_ATTENDEES_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."AP_WEB_DB_EXP_ATTENDEES_PKG" AS
/* $Header: apwdbeab.pls 120.2 2006/09/22 08:38:12 mvadera noship $ */

-----------------------------------------------------------------------------
PROCEDURE DeleteAttendees(P_ReportID             IN NUMBER) IS
--------------------------------------------------------------------------------
  l_temp    OIE_ATTENDEES.EMPLOYEE_FLAG%type;
  l_curr_calling_sequence VARCHAR2(100) := 'DeleteAttendees';

  -- Selects report lines to delete.  The actual value being selected does not
  -- matter.  For some reason the compiler complains when the OF column-name
  -- in the FOR UPDATE is missing and NOWAIT is used, so the OF
  -- EMPLOYEE_FLAG is used as a place holder.
  CURSOR ExpAttendees IS
    SELECT EMPLOYEE_FLAG
      FROM OIE_ATTENDEES oat, AP_EXPENSE_REPORT_LINES el
      WHERE (el.REPORT_HEADER_ID = P_ReportID AND
             el.REPORT_LINE_ID = oat.REPORT_LINE_ID)
      FOR UPDATE OF EMPLOYEE_FLAG NOWAIT;

BEGIN
  -- Delete the report distributions from table.  An exception will occur if the row
  -- locks cannot be attained because of the NOWAIT argument for select.
  -- We are guaranteed a lock on the records because of the FOR UPDATE
  OPEN ExpAttendees;

  LOOP
    FETCH ExpAttendees into l_temp;
    EXIT WHEN ExpAttendees%NOTFOUND;

    -- Delete matching line
    DELETE OIE_ATTENDEES WHERE CURRENT OF ExpAttendees;
  END LOOP;

  CLOSE ExpAttendees;


EXCEPTION
  WHEN NO_DATA_FOUND THEN
    NULL;
  WHEN OTHERS THEN
    AP_WEB_DB_UTIL_PKG.RaiseException('DeleteAttendees');
    APP_EXCEPTION.RAISE_EXCEPTION;
END DeleteAttendees;

PROCEDURE DuplicateAttendeeInfo(p_user_id IN NUMBER,
                                p_source_report_line_id IN AP_WEB_DB_EXPLINE_PKG.expLines_report_line_id,
				p_target_report_line_id IN AP_WEB_DB_EXPLINE_PKG.expLines_report_line_id) IS

  l_new_attendee_id NUMBER(15);
  l_attendee_id NUMBER(15);

  CURSOR Attendees IS
     SELECT ATTENDEE_LINE_ID
     FROM OIE_ATTENDEES
     WHERE REPORT_LINE_ID = p_source_report_line_id;


BEGIN

 -- Find all attendees
  OPEN Attendees;

  LOOP

    FETCH Attendees into l_attendee_id;

    EXIT WHEN Attendees%NOTFOUND;

   -- Get new ID from sequence
    SELECT OIE_ATTENDEES_S.NEXTVAL
    INTO l_new_attendee_id
    FROM DUAL;

   -- For each line, duplicate its columns
   INSERT INTO OIE_ATTENDEES
    (
      ATTENDEE_LINE_ID,
      REPORT_LINE_ID,
      EMPLOYEE_FLAG,
      EMPLOYEE_ID,
      ATTENDEE_TYPE,
      NAME,
      TITLE,
      EMPLOYER,
      EMPLOYER_ADDRESS,
      TAX_ID,
      ORG_ID,
      LAST_UPDATE_DATE,
      LAST_UPDATED_BY,
      CREATION_DATE,
      CREATED_BY
     )
    SELECT l_new_attendee_id AS ATTENDEE_LINE_ID,
           p_target_report_line_id AS REPORT_LINE_ID,
           EMPLOYEE_FLAG,
	   EMPLOYEE_ID,
           ATTENDEE_TYPE,
           NAME,
           TITLE,
           EMPLOYER,
           EMPLOYER_ADDRESS,
           TAX_ID,
           ORG_ID,
           sysdate AS CREATION_DATE,
           p_user_id AS CREATED_BY,
           sysdate AS LAST_UPDATE_DATE,
           p_user_id AS LAST_UPDATED_BY
    FROM  OIE_ATTENDEES
    WHERE ATTENDEE_LINE_ID = l_attendee_id;

  END LOOP;

 CLOSE Attendees;

END DuplicateAttendeeInfo;


END AP_WEB_DB_EXP_ATTENDEES_PKG;

/
