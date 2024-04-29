--------------------------------------------------------
--  DDL for Package AP_WEB_AUDIT_LIST_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."AP_WEB_AUDIT_LIST_PVT" AUTHID CURRENT_USER AS
/* $Header: apwvalls.pls 120.3 2006/05/04 07:49:16 sbalaji noship $ */

 /*==================================================*
  | Type definitions for structures used in the API  |
  *==================================================*/
  TYPE Date_Range_Type   IS  RECORD
    (start_date          DATE,
     end_date            DATE,
     audit_reason_code   VARCHAR2(30)
    );

  TYPE range_table          IS TABLE OF Date_Range_Type INDEX BY BINARY_INTEGER;

 /*============================================*
  | Definitions for constants used in the API  |
  *============================================*/
  c_min_date CONSTANT DATE DEFAULT to_date('1','J'); -- 01-Jan-4712 BC
  c_max_date CONSTANT DATE DEFAULT to_date('3442447','J'); -- 31-DEC-4712 AD
  -- Supported after oracle 8.0 c_max_date DATE := to_date('5373484','J'); -- 31-DEC-9999

  c_termination CONSTANT VARCHAR2(11) DEFAULT 'TERMINATION';
  c_loa         CONSTANT VARCHAR2(16) DEFAULT 'LEAVE_OF_ABSENCE';

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
                    p_date2     IN DATE) RETURN BOOLEAN;

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
                    p_date2_rec IN  Date_Range_Type) RETURN BOOLEAN;

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
                      p_date2_rec IN  Date_Range_Type) RETURN BOOLEAN;

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
  FUNCTION open_date(p_date IN DATE) RETURN BOOLEAN;

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
  FUNCTION open_end(p_date_rec IN  Date_Range_Type) RETURN BOOLEAN;

/*========================================================================
 | PUBLIC FUNCTION start_end
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
  FUNCTION open_start(p_date_rec IN  Date_Range_Type) RETURN BOOLEAN;

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
                   p_date2_rec IN  Date_Range_Type) RETURN BOOLEAN;

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
                                   p_date2_rec IN  Date_Range_Type) RETURN Date_Range_Type;

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
  FUNCTION empty(p_date_rec IN  Date_Range_Type) RETURN BOOLEAN;

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
                  p_date2_rec IN  Date_Range_Type) RETURN BOOLEAN;

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
                  p_date2 IN  DATE) RETURN BOOLEAN;

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
                  p_date2_rec IN  Date_Range_Type) RETURN BOOLEAN;

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
                 p_date2 IN  DATE) RETURN BOOLEAN;

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
                 p_date2_rec IN  Date_Range_Type) RETURN BOOLEAN;

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
                          p_audit_reason_code IN VARCHAR2) RETURN Date_Range_Type;

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
  FUNCTION get_date_range(p_audit_rec IN AP_WEB_AUDIT_LIST_PUB.Audit_Rec_Type) RETURN Date_Range_Type;

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
                                          p_end_date      IN DATE);

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
  PROCEDURE delete_audit_list_entry(p_auto_audit_id NUMBER);

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
                                 p_auto_audit_id     OUT NOCOPY  NUMBER);

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
                                p_old_date_range  IN Date_Range_Type);

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
                           p_old_date_range  IN            Date_Range_Type);

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
                                 p_old_date_range  IN Date_Range_Type);

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
                            p_counter           IN OUT NOCOPY NUMBER);


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
                                     counter       IN OUT NOCOPY NUMBER);

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
                                p_audit_rec     IN  AP_WEB_AUDIT_LIST_PUB.Audit_Rec_Type);

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
 |   p_emp_rec        IN  Record containing employee information.
 |   p_audit_rec      IN  Record containing the new audit list entry information.
 |   p_return_status  OUT Status whether the action was succesful or not
 |   p_auto_audit_id  OUT Identifier of the new record created, if multiple created returns -1.
 |
 | MODIFICATION HISTORY
 | Date                  Author            Description of Changes
 | 28-Jun-2004           J Rautiainen      Created
 |
 *=======================================================================*/
  PROCEDURE process_entry(p_emp_rec       IN          AP_WEB_AUDIT_LIST_PUB.Employee_Rec_Type,
                          p_audit_rec     IN          AP_WEB_AUDIT_LIST_PUB.Audit_Rec_Type,
                          p_return_status OUT NOCOPY  VARCHAR2,
                          p_auto_audit_id OUT NOCOPY  NUMBER);

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
                           p_return_status  OUT NOCOPY  VARCHAR2);

END AP_WEB_AUDIT_LIST_PVT;


 

/
