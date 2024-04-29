--------------------------------------------------------
--  DDL for Package Body AP_WEB_AUDIT_LIST_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."AP_WEB_AUDIT_LIST_PVT" AS
/* $Header: apwvallb.pls 115.2 2004/07/02 08:56:06 jrautiai noship $ */

/*========================================================================
 | PUBLIC FUNCTION get_date_range
 |
 | DESCRIPTION
 |   This function returns a date range type populated with the values
 |   passed in as parameters.
 |
 | CALLED FROM PROCEDURES/FUNCTIONS (local to this package body)
 |   audit list API
 |
 | CALLS PROCEDURES/FUNCTIONS (local to this package body)
 |
 | RETURNS
 |   Date range type populated with the values passed as parameters.
 |
 | PARAMETERS
 |   p_date1             IN  Start date of the range.
 |   p_date2             IN  End date of the range.
 |   p_audit_reason_code OUT Audit reason for the date range
 |
 | MODIFICATION HISTORY
 | Date                  Author            Description of Changes
 | 28-Jun-2004           J Rautiainen      Created
 |
 *=======================================================================*/
  FUNCTION get_date_range(p_date1             IN  DATE,
                          p_date2             IN  DATE,
                          p_audit_reason_code IN VARCHAR2) RETURN Date_Range_Type IS
   result Date_Range_Type;
  BEGIN
    result.start_date := trunc(NVL(p_date1,c_min_date));
    result.end_date   := trunc(NVL(p_date2,c_max_date));
    result.audit_reason_code   := p_audit_reason_code;
    return result;
  END get_date_range;

/*========================================================================
 | PUBLIC FUNCTION get_date_range
 |
 | DESCRIPTION
 |   This function returns a date range type populated with the values
 |   passed in as parameters.
 |
 | CALLED FROM PROCEDURES/FUNCTIONS (local to this package body)
 |   audit list API
 |
 | CALLS PROCEDURES/FUNCTIONS (local to this package body)
 |
 | RETURNS
 |   Date range type populated with the values passed as parameters.
 |
 | PARAMETERS
 |   p_audit_rec         IN  Audit record the API was called with.
 |
 | MODIFICATION HISTORY
 | Date                  Author            Description of Changes
 | 28-Jun-2004           J Rautiainen      Created
 |
 *=======================================================================*/
  FUNCTION get_date_range(p_audit_rec IN AP_WEB_AUDIT_LIST_PUB.Audit_Rec_Type) RETURN Date_Range_Type IS
  BEGIN
    return get_date_range(p_audit_rec.start_date, p_audit_rec.end_date, p_audit_rec.audit_reason_code);
  END get_date_range;

/*========================================================================
 | PUBLIC FUNCTION includes
 |
 | DESCRIPTION
 |   This function detects whether a date range includes a specific date.
 |   Equal dates are considered to be included.
 |
 | CALLED FROM PROCEDURES/FUNCTIONS (local to this package body)
 |   audit list API
 |
 | CALLS PROCEDURES/FUNCTIONS (local to this package body)
 |
 | RETURNS
 |   Boolean indicating whether the date range includes the date.
 |
 | PARAMETERS
 |   p_date1_rec         IN  Date range which is checked.
 |   p_date2             IN  Date which is checked.
 |
 | MODIFICATION HISTORY
 | Date                  Author            Description of Changes
 | 28-Jun-2004           J Rautiainen      Created
 |
 *=======================================================================*/
  FUNCTION includes(p_date1_rec IN Date_Range_Type,
                    p_date2     IN DATE) RETURN BOOLEAN IS
  BEGIN
    IF (    before(p_date1_rec.start_date,p_date2)
        AND after(p_date1_rec.end_date,p_date2))
        OR  p_date1_rec.start_date = p_date2
        OR  p_date1_rec.end_date = p_date2 THEN
      RETURN TRUE;
    ELSE
      RETURN FALSE;
    END IF;
  END includes;

/*========================================================================
 | PUBLIC FUNCTION includes
 |
 | DESCRIPTION
 |   This function detects whether a date range includes another date range.
 |   Equal dates are considered to be included.
 |
 | CALLED FROM PROCEDURES/FUNCTIONS (local to this package body)
 |   audit list API
 |
 | CALLS PROCEDURES/FUNCTIONS (local to this package body)
 |
 | RETURNS
 |   Boolean indicating whether the date range includes the other date range.
 |
 | PARAMETERS
 |   p_date1_rec         IN  Date range which is checked whether includes.
 |   p_date2_rec         IN  Date range which is checked whether included.
 |
 | MODIFICATION HISTORY
 | Date                  Author            Description of Changes
 | 28-Jun-2004           J Rautiainen      Created
 |
 *=======================================================================*/
  FUNCTION includes(p_date1_rec IN  Date_Range_Type,
                    p_date2_rec IN  Date_Range_Type) RETURN BOOLEAN IS
  BEGIN
    IF     includes(p_date1_rec,p_date2_rec.start_date)
       AND includes(p_date1_rec,p_date2_rec.end_date) THEN
      RETURN TRUE;
    ELSE
      RETURN FALSE;
    END IF;
  END includes;

/*========================================================================
 | PUBLIC FUNCTION continuous
 |
 | DESCRIPTION
 |   This function detects whether two date ranges are continuous eg.
 |   whether the later date range continues immediately after the other.
 |
 | CALLED FROM PROCEDURES/FUNCTIONS (local to this package body)
 |   audit list API
 |
 | CALLS PROCEDURES/FUNCTIONS (local to this package body)
 |
 | RETURNS
 |   Boolean indicating whether the date ranges are continuous.
 |
 | PARAMETERS
 |   p_date1_rec         IN  Date range which is checked.
 |   p_date2_rec         IN  Date range which is checked.
 |
 | MODIFICATION HISTORY
 | Date                  Author            Description of Changes
 | 28-Jun-2004           J Rautiainen      Created
 |
 *=======================================================================*/
  FUNCTION continuous(p_date1_rec IN  Date_Range_Type,
                      p_date2_rec IN  Date_Range_Type) RETURN BOOLEAN IS
  BEGIN
    IF     NOT overlap(p_date1_rec,p_date2_rec) THEN
      IF (    before(p_date1_rec.start_date,p_date2_rec.start_date)
          AND p_date1_rec.end_date+1 = p_date2_rec.start_date)
         OR
         (    after(p_date1_rec.start_date,p_date2_rec.start_date)
          AND p_date2_rec.end_date+1 = p_date1_rec.start_date) THEN
        RETURN TRUE;
      ELSE
        RETURN FALSE;
      END IF;
    ELSE
      RETURN FALSE;
    END IF;
  END continuous;

/*========================================================================
 | PUBLIC FUNCTION open_date
 |
 | DESCRIPTION
 |   This function detects whether a date is a open date eg. NULL which is
 |   considered as infinite.
 |
 | CALLED FROM PROCEDURES/FUNCTIONS (local to this package body)
 |   audit list API
 |
 | CALLS PROCEDURES/FUNCTIONS (local to this package body)
 |
 | RETURNS
 |   Boolean indicating whether the date is a open date.
 |
 | PARAMETERS
 |   p_date1         IN  Date to be checked.
 |
 | MODIFICATION HISTORY
 | Date                  Author            Description of Changes
 | 28-Jun-2004           J Rautiainen      Created
 |
 *=======================================================================*/
  FUNCTION open_date(p_date IN DATE) RETURN BOOLEAN IS
  BEGIN
    IF    p_date = c_min_date
       OR p_date = c_max_date
       OR p_date IS NULL THEN
      RETURN TRUE;
    ELSE
      RETURN FALSE;
    END IF;
  END open_date;

/*========================================================================
 | PUBLIC FUNCTION open_end
 |
 | DESCRIPTION
 |   This function detects whether range has a open end date.
 |
 | CALLED FROM PROCEDURES/FUNCTIONS (local to this package body)
 |   audit list API
 |
 | CALLS PROCEDURES/FUNCTIONS (local to this package body)
 |
 | RETURNS
 |   Boolean indicating whether the range has a open end date.
 |
 | PARAMETERS
 |   p_date_rec         IN  Date range to be checked.
 |
 | MODIFICATION HISTORY
 | Date                  Author            Description of Changes
 | 28-Jun-2004           J Rautiainen      Created
 |
 *=======================================================================*/
  FUNCTION open_end(p_date_rec IN  Date_Range_Type) RETURN BOOLEAN IS
  BEGIN
    RETURN open_date(p_date_rec.end_date);
  END open_end;

/*========================================================================
 | PUBLIC FUNCTION open_start
 |
 | DESCRIPTION
 |   This function detects whether range has a open start date.
 |
 | CALLED FROM PROCEDURES/FUNCTIONS (local to this package body)
 |   audit list API
 |
 | CALLS PROCEDURES/FUNCTIONS (local to this package body)
 |
 | RETURNS
 |   Boolean indicating whether the range has a open start date.
 |
 | PARAMETERS
 |   p_date_rec         IN  Date range to be checked.
 |
 | MODIFICATION HISTORY
 | Date                  Author            Description of Changes
 | 28-Jun-2004           J Rautiainen      Created
 |
 *=======================================================================*/
  FUNCTION open_start(p_date_rec IN  Date_Range_Type) RETURN BOOLEAN IS
  BEGIN
    RETURN open_date(p_date_rec.start_date);
  END open_start;

/*========================================================================
 | PUBLIC FUNCTION overlap
 |
 | DESCRIPTION
 |   This function detects whether two ranges overlap each other.
 |
 | CALLED FROM PROCEDURES/FUNCTIONS (local to this package body)
 |   audit list API
 |
 | CALLS PROCEDURES/FUNCTIONS (local to this package body)
 |
 | RETURNS
 |   Boolean indicating whether the two ranges overlap each other.
 |
 | PARAMETERS
 |   p_date1_rec         IN  Date range to be checked.
 |   p_date2_rec         IN  Date range to be checked.
 |
 | MODIFICATION HISTORY
 | Date                  Author            Description of Changes
 | 28-Jun-2004           J Rautiainen      Created
 |
 *=======================================================================*/
  FUNCTION overlap(p_date1_rec IN  Date_Range_Type,
                   p_date2_rec IN  Date_Range_Type) RETURN BOOLEAN IS
  BEGIN
    IF (    includes(p_date1_rec,p_date2_rec) = TRUE
        OR  includes(p_date1_rec,p_date2_rec.start_date) = TRUE
        OR  includes(p_date1_rec,p_date2_rec.end_date) = TRUE
        OR  includes(p_date2_rec,p_date1_rec) = TRUE
        OR  includes(p_date2_rec,p_date1_rec.start_date) = TRUE
        OR  includes(p_date2_rec,p_date1_rec.end_date) = TRUE) THEN
      RETURN TRUE;
    ELSE
      RETURN FALSE;
    END IF;
  END overlap;

/*========================================================================
 | PUBLIC FUNCTION gap_between_start_dates
 |
 | DESCRIPTION
 |   This function returns the gap between the start dates of two ranges.
 |   Note this is only detected if the first record includes the second.
 |
 | CALLED FROM PROCEDURES/FUNCTIONS (local to this package body)
 |   audit list API
 |
 | CALLS PROCEDURES/FUNCTIONS (local to this package body)
 |
 | RETURNS
 |   Date range for the gap between the start dates.
 |
 | PARAMETERS
 |   p_date1_rec         IN  Date range to be checked.
 |   p_date2_rec         IN  Date range to be checked.
 |
 | MODIFICATION HISTORY
 | Date                  Author            Description of Changes
 | 28-Jun-2004           J Rautiainen      Created
 |
 *=======================================================================*/
  FUNCTION gap_between_start_dates(p_date1_rec IN  Date_Range_Type,
                                   p_date2_rec IN  Date_Range_Type) RETURN Date_Range_Type IS
    result Date_Range_Type;
  BEGIN
    result.start_date := NULL;
    result.end_date   := NULL;
    IF    NOT includes(p_date1_rec, p_date2_rec)
       OR p_date1_rec.start_date = p_date2_rec.start_date THEN
      RETURN result;
    ELSE
      result.start_date := p_date1_rec.start_date;
      result.end_date := p_date2_rec.start_date-1;
    END IF;
    return result;
  END gap_between_start_dates;

/*========================================================================
 | PUBLIC FUNCTION empty
 |
 | DESCRIPTION
 |   This function detects whether a range record is empty.
 |
 | CALLED FROM PROCEDURES/FUNCTIONS (local to this package body)
 |   audit list API
 |
 | CALLS PROCEDURES/FUNCTIONS (local to this package body)
 |
 | RETURNS
 |   Boolean indicating whether the range is empty.
 |
 | PARAMETERS
 |   p_date_rec         IN  Date range to be checked.
 |
 | MODIFICATION HISTORY
 | Date                  Author            Description of Changes
 | 28-Jun-2004           J Rautiainen      Created
 |
 *=======================================================================*/
  FUNCTION empty(p_date_rec IN  Date_Range_Type) RETURN BOOLEAN IS
  BEGIN
    IF p_date_rec.start_date IS NULL AND p_date_rec.end_date IS NULL THEN
      RETURN TRUE;
    ELSE
      RETURN FALSE;
    END IF;
  END empty;

/*========================================================================
 | PUBLIC FUNCTION equals
 |
 | DESCRIPTION
 |   This function detects whether two ranges are equal.
 |
 | CALLED FROM PROCEDURES/FUNCTIONS (local to this package body)
 |   audit list API
 |
 | CALLS PROCEDURES/FUNCTIONS (local to this package body)
 |
 | RETURNS
 |   Boolean indicating whether the ranges are equal.
 |
 | PARAMETERS
 |   p_date1_rec         IN  Date range to be checked.
 |   p_date2_rec         IN  Date range to be checked.
 |
 | MODIFICATION HISTORY
 | Date                  Author            Description of Changes
 | 28-Jun-2004           J Rautiainen      Created
 |
 *=======================================================================*/
  FUNCTION equals(p_date1_rec IN  Date_Range_Type,
                  p_date2_rec IN  Date_Range_Type) RETURN BOOLEAN IS
  BEGIN
    IF     NVL(p_date1_rec.start_date, c_min_date) = NVL(p_date2_rec.start_date, c_min_date)
       AND NVL(p_date1_rec.end_date, c_max_date)   = NVL(p_date2_rec.end_date, c_max_date) THEN
      RETURN TRUE;
    ELSE
      RETURN FALSE;
    END IF;
  END equals;

/*========================================================================
 | PUBLIC FUNCTION before
 |
 | DESCRIPTION
 |   This function detects whether a date is before than another date.
 |
 | CALLED FROM PROCEDURES/FUNCTIONS (local to this package body)
 |   audit list API
 |
 | CALLS PROCEDURES/FUNCTIONS (local to this package body)
 |
 | RETURNS
 |   Boolean indicating whether the first date is before the second.
 |
 | PARAMETERS
 |   p_date1         IN  Date to be checked.
 |   p_date2         IN  Date to be checked.
 |
 | MODIFICATION HISTORY
 | Date                  Author            Description of Changes
 | 28-Jun-2004           J Rautiainen      Created
 |
 *=======================================================================*/
  FUNCTION before(p_date1 IN  DATE,
                  p_date2 IN  DATE) RETURN BOOLEAN IS
  BEGIN
    IF (p_date1 < p_date2) THEN
      RETURN TRUE;
    ELSE
      RETURN FALSE;
    END IF;
  END before;

/*========================================================================
 | PUBLIC FUNCTION before
 |
 | DESCRIPTION
 |   This function detects whether a date range is before than another
 |   date range.
 |
 | CALLED FROM PROCEDURES/FUNCTIONS (local to this package body)
 |   audit list API
 |
 | CALLS PROCEDURES/FUNCTIONS (local to this package body)
 |
 | RETURNS
 |   Boolean indicating whether the first date range is before the second.
 |
 | PARAMETERS
 |   p_date1_rec         IN  Date range to be checked.
 |   p_date2_rec         IN  Date range to be checked.
 |
 | MODIFICATION HISTORY
 | Date                  Author            Description of Changes
 | 28-Jun-2004           J Rautiainen      Created
 |
 *=======================================================================*/
  FUNCTION before(p_date1_rec IN  Date_Range_Type,
                  p_date2_rec IN  Date_Range_Type) RETURN BOOLEAN IS
  BEGIN
    IF overlap(p_date1_rec, p_date2_rec) THEN
      RETURN FALSE;
    ELSE
      IF before(p_date1_rec.end_date, p_date2_rec.start_date) THEN
        RETURN TRUE;
      ELSE
        RETURN FALSE;
      END IF;
    END IF;
  END before;

/*========================================================================
 | PUBLIC FUNCTION after
 |
 | DESCRIPTION
 |   This function detects whether a date is after than another date.
 |
 | CALLED FROM PROCEDURES/FUNCTIONS (local to this package body)
 |   audit list API
 |
 | CALLS PROCEDURES/FUNCTIONS (local to this package body)
 |
 | RETURNS
 |   Boolean indicating whether the first date is after the second.
 |
 | PARAMETERS
 |   p_date1         IN  Date to be checked.
 |   p_date2         IN  Date to be checked.
 |
 | MODIFICATION HISTORY
 | Date                  Author            Description of Changes
 | 28-Jun-2004           J Rautiainen      Created
 |
 *=======================================================================*/
  FUNCTION after(p_date1 IN  DATE,
                 p_date2 IN  DATE) RETURN BOOLEAN IS
  BEGIN
    IF (p_date1 > p_date2) THEN
      RETURN TRUE;
    ELSE
      RETURN FALSE;
    END IF;
  END after;

/*========================================================================
 | PUBLIC FUNCTION after
 |
 | DESCRIPTION
 |   This function detects whether a date range is after than another
 |   date range.
 |
 | CALLED FROM PROCEDURES/FUNCTIONS (local to this package body)
 |   audit list API
 |
 | CALLS PROCEDURES/FUNCTIONS (local to this package body)
 |
 | RETURNS
 |   Boolean indicating whether the first date range is after the second.
 |
 | PARAMETERS
 |   p_date1_rec         IN  Date range to be checked.
 |   p_date2_rec         IN  Date range to be checked.
 |
 | MODIFICATION HISTORY
 | Date                  Author            Description of Changes
 | 28-Jun-2004           J Rautiainen      Created
 |
 *=======================================================================*/
  FUNCTION after(p_date1_rec IN  Date_Range_Type,
                 p_date2_rec IN  Date_Range_Type) RETURN BOOLEAN IS
  BEGIN
    IF overlap(p_date1_rec, p_date2_rec) THEN
      RETURN FALSE;
    ELSE
      IF after(p_date1_rec.start_date, p_date2_rec.end_date) THEN
        RETURN TRUE;
      ELSE
        RETURN FALSE;
      END IF;
    END IF;
  END after;

/*========================================================================
 | PUBLIC PROCEDURE insert_to_audit_list
 |
 | DESCRIPTION
 |   This procedure inserts date ranges included in a array into the
 |   database.
 |
 | CALLED FROM PROCEDURES/FUNCTIONS (local to this package body)
 |   audit list API
 |
 | CALLS PROCEDURES/FUNCTIONS (local to this package body)
 |
 | RETURNS
 |   None.
 |
 | PARAMETERS
 |   p_person_id         IN  Person to be added.
 |   p_range_table       IN  Array containing the entries to be created.
 |   p_auto_audit_id     OUT Identifier of the new record created, if multiple created returns -1.
 |
 | MODIFICATION HISTORY
 | Date                  Author            Description of Changes
 | 28-Jun-2004           J Rautiainen      Created
 |
 *=======================================================================*/
  PROCEDURE insert_to_audit_list(p_person_id         IN  NUMBER,
                                 p_range_table       IN  range_table,
                                 p_auto_audit_id     OUT NOCOPY  NUMBER) IS
    l_auto_audit_id NUMBER;

  BEGIN
    p_auto_audit_id := null;

    IF p_range_table.COUNT = 0 THEN
      RETURN;
    END IF;

    FOR i IN p_range_table.FIRST..p_range_table.LAST LOOP
      select AP_AUD_AUTO_AUDITS_S.nextval INTO l_auto_audit_id from sys.DUAL;

      INSERT INTO AP_AUD_AUTO_AUDITS(
        AUTO_AUDIT_ID,
        EMPLOYEE_ID,
        AUDIT_REASON_CODE,
        START_DATE,
        END_DATE,
        CREATION_DATE,
        CREATED_BY,
        LAST_UPDATE_LOGIN,
        LAST_UPDATE_DATE,
        LAST_UPDATED_BY)
      VALUES (
        l_auto_audit_id,
        p_person_id,
        p_range_table(i).audit_reason_code,
        decode(p_range_table(i).start_date,
               c_min_date, SYSDATE,
               p_range_table(i).start_date),
        decode(p_range_table(i).end_date,
               c_max_date, NULL,
               p_range_table(i).end_date),
        SYSDATE,
        nvl(fnd_global.user_id, -1),
        fnd_global.conc_login_id,
        SYSDATE,
        nvl(fnd_global.user_id, -1));

    END LOOP;

    IF p_range_table.COUNT = 1 THEN
      p_auto_audit_id := l_auto_audit_id;
    ELSE
      p_auto_audit_id := -1;
    END IF;
  END insert_to_audit_list;

/*========================================================================
 | PUBLIC PROCEDURE update_audit_list_entry_dates
 |
 | DESCRIPTION
 |   This procedure updates a audit list entry data.
 |
 | CALLED FROM PROCEDURES/FUNCTIONS (local to this package body)
 |   audit list API
 |
 | CALLS PROCEDURES/FUNCTIONS (local to this package body)
 |
 | RETURNS
 |   None.
 |
 | PARAMETERS
 |   p_auto_audit_id     IN  Identifier of the record to be updated.
 |   p_start_date        IN  Start date for the record.
 |   p_end_date        IN  End date for the record.
 |
 | MODIFICATION HISTORY
 | Date                  Author            Description of Changes
 | 28-Jun-2004           J Rautiainen      Created
 |
 *=======================================================================*/
  PROCEDURE update_audit_list_entry_dates(p_auto_audit_id IN NUMBER,
                                          p_start_date    IN DATE,
                                          p_end_date      IN DATE) IS
  BEGIN
      IF before(p_end_date,p_start_date) THEN
        delete_audit_list_entry(p_auto_audit_id);
      END IF;

      UPDATE AP_AUD_AUTO_AUDITS
      SET START_DATE = p_start_date,
          END_DATE   = decode(p_end_date,
                              c_max_date, NULL,
                              p_end_date),
          LAST_UPDATE_LOGIN = fnd_global.conc_login_id,
          LAST_UPDATE_DATE  = SYSDATE,
          LAST_UPDATED_BY   = nvl(fnd_global.user_id, -1)
      WHERE AUTO_AUDIT_ID = p_auto_audit_id;

  END update_audit_list_entry_dates;

/*========================================================================
 | PUBLIC PROCEDURE move_existing_entry
 |
 | DESCRIPTION
 |   This procedure moves an audit list entry so that it does not overlap
 |   with the new entry.
 |
 | CALLED FROM PROCEDURES/FUNCTIONS (local to this package body)
 |   audit list API
 |
 | CALLS PROCEDURES/FUNCTIONS (local to this package body)
 |
 | RETURNS
 |   None.
 |
 | PARAMETERS
 |   p_auto_audit_id     IN  Identifier of the record to be updated.
 |   p_new_date_range    IN  The new entry date range.
 |   p_old_date_range    IN  The old entry date range.
 |
 | MODIFICATION HISTORY
 | Date                  Author            Description of Changes
 | 28-Jun-2004           J Rautiainen      Created
 |
 *=======================================================================*/
  PROCEDURE move_existing_entry(p_auto_audit_id   IN NUMBER,
                                p_new_date_range  IN Date_Range_Type,
                                p_old_date_range  IN Date_Range_Type) IS
  BEGIN
    IF    before(p_new_date_range.start_date, p_old_date_range.start_date)
       OR p_new_date_range.start_date = p_old_date_range.start_date THEN
      update_audit_list_entry_dates(p_auto_audit_id,
                                    p_new_date_range.end_date + 1,
                                    p_old_date_range.end_date);
    ELSE

      update_audit_list_entry_dates(p_auto_audit_id,
                                    p_old_date_range.start_date,
                                    p_new_date_range.start_date - 1);
    END IF;

  END move_existing_entry;

/*========================================================================
 | PUBLIC PROCEDURE move_new_entry
 |
 | DESCRIPTION
 |   This procedure moves the new entry so that it does not overlap
 |   with the audit list entries.
 |
 | CALLED FROM PROCEDURES/FUNCTIONS (local to this package body)
 |   audit list API
 |
 | CALLS PROCEDURES/FUNCTIONS (local to this package body)
 |
 | RETURNS
 |   None.
 |
 | PARAMETERS
 |   p_new_date_range    IN  The new entry date range.
 |   p_old_date_range    IN  The old entry date range.
 |
 | MODIFICATION HISTORY
 | Date                  Author            Description of Changes
 | 28-Jun-2004           J Rautiainen      Created
 |
 *=======================================================================*/
  PROCEDURE move_new_entry(p_new_date_range  IN OUT NOCOPY Date_Range_Type,
                           p_old_date_range  IN            Date_Range_Type) IS
  BEGIN
    IF before(p_new_date_range.start_date, p_old_date_range.start_date) THEN
      p_new_date_range.end_date := p_old_date_range.start_date - 1;
    ELSE
      IF open_end(p_old_date_range) THEN
        /*====================================================================================*
         | The existing entry is stronger than the new one and it does not have a end date,   |
         | this means that there is no point processing further. Here we set the date range   |
         | of the new record so that when inserting the new record it is disregarded.         |
         | The dates are set to the limits on purpose (start to latest and end to earliest).  |
         *====================================================================================*/
        p_new_date_range.start_date := c_max_date;
        p_new_date_range.end_date   := c_min_date;
      ELSE
        p_new_date_range.start_date := p_old_date_range.end_date + 1;
      END IF;
    END IF;

  END move_new_entry;

/*========================================================================
 | PUBLIC PROCEDURE split_existing_entry
 |
 | DESCRIPTION
 |   This procedure adds the new entry in the middle of an existing audit
 |   list entry.
 |
 | CALLED FROM PROCEDURES/FUNCTIONS (local to this package body)
 |   audit list API
 |
 | CALLS PROCEDURES/FUNCTIONS (local to this package body)
 |
 | RETURNS
 |   None.
 |
 | PARAMETERS
 |   p_overlap_rec       IN  The overlapping record.
 |   p_new_date_range    IN  The new entry date range.
 |   p_old_date_range    IN  The old entry date range.
 |
 | MODIFICATION HISTORY
 | Date                  Author            Description of Changes
 | 28-Jun-2004           J Rautiainen      Created
 |
 *=======================================================================*/
  PROCEDURE split_existing_entry(p_overlap_rec     IN ap_aud_auto_audits%ROWTYPE,
                                 p_new_date_range  IN Date_Range_Type,
                                 p_old_date_range  IN Date_Range_Type) IS
    temp_range      Date_Range_Type;
    insert_ranges   range_table;
    counter         NUMBER := 0;
    l_auto_audit_id NUMBER;
  BEGIN
    IF NOT includes(p_old_date_range, p_new_date_range) THEN
      RETURN;
    END IF;

    update_audit_list_entry_dates(p_overlap_rec.auto_audit_id,
                                  p_old_date_range.start_date,
                                  p_new_date_range.start_date - 1);

    IF (NOT open_end(p_new_date_range)) THEN
      temp_range.start_date        := p_new_date_range.end_date + 1;
      temp_range.end_date          := p_old_date_range.end_date;
      temp_range.audit_reason_code := p_overlap_rec.audit_reason_code;

      add_range_to_be_inserted(temp_range, insert_ranges, counter);

      insert_to_audit_list(p_overlap_rec.employee_id, insert_ranges, l_auto_audit_id);
    END IF;

  END split_existing_entry;

/*========================================================================
 | PUBLIC PROCEDURE split_new_entry
 |
 | DESCRIPTION
 |   This procedure splits the new entry so that an existing audit list
 |   entry remains in the middle of it.
 |
 | CALLED FROM PROCEDURES/FUNCTIONS (local to this package body)
 |   audit list API
 |
 | CALLS PROCEDURES/FUNCTIONS (local to this package body)
 |
 | RETURNS
 |   None.
 |
 | PARAMETERS
 |   p_new_date_range    IN     The new entry date range.
 |   p_old_date_range    IN     The old entry date range.
 |   p_range_table       IN OUT Array containing the new entries to be created.
 |   p_counter           IN OUT Counter storing the count of lines in the array.
 |
 | MODIFICATION HISTORY
 | Date                  Author            Description of Changes
 | 28-Jun-2004           J Rautiainen      Created
 |
 *=======================================================================*/
  PROCEDURE split_new_entry(p_new_date_range  IN OUT NOCOPY Date_Range_Type,
                            p_old_date_range  IN Date_Range_Type,
                            p_range_table     IN OUT NOCOPY range_table,
                            p_counter           IN OUT NOCOPY NUMBER) IS
    temp_range     Date_Range_Type;
  BEGIN

    temp_range := gap_between_start_dates(p_new_date_range, p_old_date_range);
    temp_range.audit_reason_code := p_new_date_range.audit_reason_code;
    add_range_to_be_inserted(temp_range, p_range_table, p_counter);

    IF open_end(p_old_date_range) THEN
      -- if old record is open ended do not do anything
      p_new_date_range.start_date := c_max_date;
      p_new_date_range.end_date   := c_min_date;
    ELSE
      p_new_date_range.start_date := p_old_date_range.end_date + 1;
    END IF;

  END split_new_entry;

/*========================================================================
 | PUBLIC PROCEDURE delete_audit_list_entry
 |
 | DESCRIPTION
 |   This procedure deletes a given audit list entry.
 |
 | CALLED FROM PROCEDURES/FUNCTIONS (local to this package body)
 |   audit list API
 |
 | CALLS PROCEDURES/FUNCTIONS (local to this package body)
 |
 | RETURNS
 |   None.
 |
 | PARAMETERS
 |   p_auto_audit_id    IN  Identifier of the record to be deleted.
 |
 | MODIFICATION HISTORY
 | Date                  Author            Description of Changes
 | 28-Jun-2004           J Rautiainen      Created
 |
 *=======================================================================*/
  PROCEDURE delete_audit_list_entry(p_auto_audit_id NUMBER) IS
  BEGIN

    DELETE AP_AUD_AUTO_AUDITS
    WHERE AUTO_AUDIT_ID = p_auto_audit_id;

  END delete_audit_list_entry;

/*========================================================================
 | PUBLIC PROCEDURE end_date_open_entry
 |
 | DESCRIPTION
 |   This procedure end dates a existing open end dated record.
 |
 | CALLED FROM PROCEDURES/FUNCTIONS (local to this package body)
 |   audit list API
 |
 | CALLS PROCEDURES/FUNCTIONS (local to this package body)
 |
 | RETURNS
 |   None.
 |
 | PARAMETERS
 |   p_emp_rec    IN  Record containing employee information.
 |   p_audit_rec  IN  Record containing the new audit list entry information.
 |
 | MODIFICATION HISTORY
 | Date                  Author            Description of Changes
 | 28-Jun-2004           J Rautiainen      Created
 |
 *=======================================================================*/
  PROCEDURE end_date_open_entry(p_emp_rec       IN  AP_WEB_AUDIT_LIST_PUB.Employee_Rec_Type,
                                p_audit_rec     IN  AP_WEB_AUDIT_LIST_PUB.Audit_Rec_Type) IS
  CURSOR target_cur IS
    SELECT auto_audit_id, start_date, end_date
    FROM ap_aud_auto_audits
    WHERE employee_id = p_emp_rec.person_id
    AND   audit_reason_code = p_audit_rec.audit_reason_code
    AND   end_date is NULL;

    target_rec target_cur%ROWTYPE;

  BEGIN
    OPEN target_cur;
    FETCH target_cur INTO target_rec;
    IF target_cur%FOUND THEN
      update_audit_list_entry_dates(target_rec.auto_audit_id,
                                    target_rec.start_date,
                                    p_audit_rec.end_date);
    END IF;
    CLOSE target_cur;
  END end_date_open_entry;

/*========================================================================
 | PUBLIC PROCEDURE process_entry
 |
 | DESCRIPTION
 |   This procedure processes new audit list entry.
 |
 | CALLED FROM PROCEDURES/FUNCTIONS (local to this package body)
 |   audit list API
 |
 | CALLS PROCEDURES/FUNCTIONS (local to this package body)
 |
 | RETURNS
 |   None.
 |
 | PARAMETERS
 |   p_emp_rec       IN  Record containing employee information.
 |   p_audit_rec     IN  Record containing the new audit list entry information.
 |   p_return_status OUT Status whether the action was succesful or not
 |   p_auto_audit_id OUT Identifier of the new record created, if multiple created returns -1.
 |
 | MODIFICATION HISTORY
 | Date                  Author            Description of Changes
 | 28-Jun-2004           J Rautiainen      Created
 |
 *=======================================================================*/
  PROCEDURE process_entry(p_emp_rec       IN          AP_WEB_AUDIT_LIST_PUB.Employee_Rec_Type,
                          p_audit_rec     IN          AP_WEB_AUDIT_LIST_PUB.Audit_Rec_Type,
                          p_return_status OUT NOCOPY  VARCHAR2,
                          p_auto_audit_id OUT NOCOPY  NUMBER) IS

   /*=====================================================================*
    | Cursor containing all records that a date range overlaps.           |
    | Note to detect continuous records the dates passed in as parameters |
    | are start_date-1 and end_date+1                                     |
    *====================================================================*/
  CURSOR overlap_cur(p_start_date DATE, p_end_date DATE) IS
    SELECT *
    FROM ap_aud_auto_audits
    WHERE employee_id = p_emp_rec.person_id
    AND  ( ( trunc(start_date) between p_start_date
                                  and p_end_date
             OR
             trunc(NVL(end_date,c_max_date)) between p_start_date
                                                 and p_end_date

           )
           OR
           ( p_start_date between trunc(start_date)
                            and   trunc(NVL(end_date, c_max_date))
             OR
             p_end_date between trunc(start_date)
                            and   trunc(NVL(end_date, c_max_date))

            )
         )
    order by start_date;

    overlap_rec    ap_aud_auto_audits%ROWTYPE;
    b_termination  BOOLEAN := p_audit_rec.audit_reason_code = c_termination;
    b_loa          BOOLEAN := p_audit_rec.audit_reason_code = c_loa;
    b_regular      BOOLEAN := p_audit_rec.audit_reason_code NOT IN (c_termination,c_loa);
    new_date_range Date_Range_Type;
    old_date_range Date_Range_Type;
    temp_range     Date_Range_Type;
    temp_date      DATE;
    insert_ranges  range_table;
    counter        NUMBER := 0;

  BEGIN
   p_return_status := FND_API.G_RET_STS_SUCCESS;

   /*================================*
    | Check for overlapping records. |
    *================================*/
    new_date_range := get_date_range(p_audit_rec);
    IF (open_start(new_date_range)) THEN
     /*======================================================================*
      | If the new record is open start dated, then a record with open end   |
      | date must exist and that record is end dated.                        |
      *======================================================================*/
      end_date_open_entry(p_emp_rec,p_audit_rec);
    ELSE
     /*=====================================================================*
      | To detect continuous records the dates passed in as parameters      |
      | are start_date-1 and end_date+1                                     |
      *====================================================================*/
      IF new_date_range.end_date = c_max_date THEN
        temp_date := c_max_date;
      ELSE
        temp_date := new_date_range.end_date+1;
      END IF;

      FOR overlap_rec IN overlap_cur(new_date_range.start_date-1, temp_date) LOOP
        old_date_range := get_date_range(overlap_rec.start_date, overlap_rec.end_date, overlap_rec.audit_reason_code);

        IF     overlap_rec.audit_reason_code = p_audit_rec.audit_reason_code
           AND ( overlap(new_date_range, old_date_range) OR continuous(new_date_range, old_date_range)) THEN
         /*====================================================================================*
          | When the new record and any overlapping or continuing record has the same          |
          | audit reason, the records are merged.                                              |
          *====================================================================================*/
          new_date_range.start_date := least(new_date_range.start_date, old_date_range.start_date);
          new_date_range.end_date   := greatest(new_date_range.end_date, old_date_range.end_date);
          delete_audit_list_entry(overlap_rec.auto_audit_id);
        ELSIF b_termination THEN
         /*====================================================================================*
          | When creating termination any old entry included in the new date range is deleted. |
          | In overlap case with any other status than termination, the overlap is removed with|
          | termination taking precedence.                                                     |
          *====================================================================================*/
          IF includes(new_date_range, old_date_range) THEN
            delete_audit_list_entry(overlap_rec.auto_audit_id);
          ELSIF overlap(new_date_range, old_date_range) THEN
            IF includes(old_date_range, new_date_range) THEN
              split_existing_entry(overlap_rec, new_date_range, old_date_range);
            ELSE
              move_existing_entry(overlap_rec.auto_audit_id, new_date_range,old_date_range);
            END IF;
          END IF;
        ELSIF b_loa THEN
         /*====================================================================================*
          | When creating loa any old entry included in the new date range is deleted, unless  |
          | the old record is termination, in which case the termination takes precedence and  |
          | the new loa record is updated so that there is no overlap.                         |
          | If the there is overlap and the old record is not termination the overlap is       |
          | removed with loa taking precedence.                                                |
          *====================================================================================*/
          IF includes(new_date_range, old_date_range) THEN
            IF overlap_rec.audit_reason_code = c_termination THEN
              split_new_entry(new_date_range, old_date_range,insert_ranges, counter);
            ELSE
              delete_audit_list_entry(overlap_rec.auto_audit_id);
            END IF;
          ELSIF overlap(new_date_range, old_date_range) THEN
            IF overlap_rec.audit_reason_code = c_termination THEN
              move_new_entry(new_date_range,old_date_range);
            ELSIF includes(old_date_range, new_date_range) THEN
              split_existing_entry(overlap_rec, new_date_range, old_date_range);
            ELSE
              move_existing_entry(overlap_rec.auto_audit_id, new_date_range,old_date_range);
            END IF;
          END IF;
        ELSE -- b_regular
         /*====================================================================================*
          | For all other statuses the new record takes precedence of any other record than    |
          | termination and loa.                                                               |
          *====================================================================================*/
          IF includes(new_date_range, old_date_range) THEN
            IF overlap_rec.audit_reason_code IN (c_termination, c_loa) THEN
              split_new_entry(new_date_range, old_date_range,insert_ranges, counter);
            ELSE
              delete_audit_list_entry(overlap_rec.auto_audit_id);
            END IF;
          ELSIF overlap(new_date_range, old_date_range) THEN
            IF overlap_rec.audit_reason_code IN (c_termination, c_loa) THEN
              move_new_entry(new_date_range,old_date_range);
            ELSIF includes(old_date_range, new_date_range) THEN
              split_existing_entry(overlap_rec, new_date_range, old_date_range);
            ELSE
              move_existing_entry(overlap_rec.auto_audit_id, new_date_range,old_date_range);
            END IF;
          END IF;
        END IF; -- b_termination - b_loa - b_regular ...
      END LOOP;

      /*====================================================================================*
      | Once all the existing records are processed create add the remaining date range of  |
      | the new record in to the array od records to be created.                            |
      *====================================================================================*/
      temp_range.start_date        := new_date_range.start_date;
      temp_range.end_date          := new_date_range.end_date;
      temp_range.audit_reason_code := p_audit_rec.audit_reason_code;
      add_range_to_be_inserted(temp_range, insert_ranges, counter);

      insert_to_audit_list(p_emp_rec.person_id, insert_ranges, p_auto_audit_id);

    END IF; -- open_start
  EXCEPTION
    WHEN others THEN
      p_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
  END process_entry;

/*========================================================================
 | PUBLIC PROCEDURE add_range_to_be_inserted
 |
 | DESCRIPTION
 |   This procedure adds a range to the array used to store the ranges to
 |   be inserted as audit list entries.
 |
 | CALLED FROM PROCEDURES/FUNCTIONS (local to this package body)
 |   audit list API
 |
 | CALLS PROCEDURES/FUNCTIONS (local to this package body)
 |
 | RETURNS
 |   None.
 |
 | PARAMETERS
 |   p_date_range    IN     The entry date range.
 |   p_range_table   IN OUT Array containing the new entries to be created.
 |   p_counter       IN OUT Counter storing the count of lines in the array.
 |
 | MODIFICATION HISTORY
 | Date                  Author            Description of Changes
 | 28-Jun-2004           J Rautiainen      Created
 |
 *=======================================================================*/
  PROCEDURE add_range_to_be_inserted(p_range       IN Date_Range_Type,
                                     p_range_table IN OUT NOCOPY range_table,
                                     counter       IN OUT NOCOPY NUMBER) IS
  BEGIN
    IF   empty(p_range)
      OR before(p_range.end_date,p_range.start_date) THEN
      RETURN;
    END IF;

    p_range_table(counter).start_date := p_range.start_date;
    p_range_table(counter).end_date   := p_range.end_date;
    p_range_table(counter).audit_reason_code   := p_range.audit_reason_code;
    counter := counter + 1;

  END add_range_to_be_inserted;

/*========================================================================
 | PUBLIC PROCEDURE remove_entries
 |
 | DESCRIPTION
 |   This procedure processes audit list entry removal.
 |
 | CALLED FROM PROCEDURES/FUNCTIONS (local to this package body)
 |   audit list API
 |
 | CALLS PROCEDURES/FUNCTIONS (local to this package body)
 |
 | RETURNS
 |   None.
 |
 | PARAMETERS
 |   p_emp_rec        IN  Record containing employee information.
 |   p_date_range_rec IN  Record containg date range
 |   p_return_status  OUT Status whether the action was succesful or not
 |
 | MODIFICATION HISTORY
 | Date                  Author            Description of Changes
 | 28-Jun-2004           J Rautiainen      Created
 |
 *=======================================================================*/
  PROCEDURE remove_entries(p_emp_rec        IN          AP_WEB_AUDIT_LIST_PUB.Employee_Rec_Type,
                           p_date_range_rec IN          AP_WEB_AUDIT_LIST_PUB.Date_Range_Type,
                           p_return_status  OUT NOCOPY  VARCHAR2) IS

   /*=====================================================================*
    | Cursor containing all records that a date range overlaps.           |
    *====================================================================*/
  CURSOR overlap_cur(p_start_date DATE, p_end_date DATE) IS
    SELECT *
    FROM ap_aud_auto_audits
    WHERE employee_id = p_emp_rec.person_id
    AND  ( ( trunc(start_date) between p_start_date
                                   and p_end_date
             OR
             trunc(NVL(end_date,c_max_date)) between p_start_date
                                                 and p_end_date

           )
           OR
           ( p_start_date between trunc(start_date)
                            and   trunc(NVL(end_date, c_max_date))
             OR
             p_end_date between trunc(start_date)
                          and   trunc(NVL(end_date, c_max_date))

            )
          )
    order by start_date;

    new_date_range Date_Range_Type;
    old_date_range Date_Range_Type;
  BEGIN
    p_return_status := FND_API.G_RET_STS_SUCCESS;
    new_date_range := get_date_range(p_date_range_rec.start_date, p_date_range_rec.end_date, NULL);

    FOR overlap_rec IN overlap_cur(new_date_range.start_date, new_date_range.end_date) LOOP
      old_date_range := get_date_range(overlap_rec.start_date, overlap_rec.end_date, overlap_rec.audit_reason_code);

      /*====================================================================================*
       | When deleting a data range any old entry included in the date range is deleted.    |
       | In overlap case the overlap is removed.                                            |
       *====================================================================================*/
      IF includes(new_date_range, old_date_range) THEN
        delete_audit_list_entry(overlap_rec.auto_audit_id);
      ELSIF overlap(new_date_range, old_date_range) THEN
        IF includes(old_date_range, new_date_range) THEN
          split_existing_entry(overlap_rec, new_date_range, old_date_range);
        ELSE
          move_existing_entry(overlap_rec.auto_audit_id, new_date_range,old_date_range);
        END IF;
      END IF;
    END LOOP;

  EXCEPTION
    WHEN others THEN
      p_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
  END remove_entries;

END AP_WEB_AUDIT_LIST_PVT;

/
