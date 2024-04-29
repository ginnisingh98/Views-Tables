--------------------------------------------------------
--  DDL for Package Body HR_LEGISLATION
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."HR_LEGISLATION" AS
/* $Header: pelegins.pkb 120.15.12010000.3 2009/07/28 06:05:09 sivanara ship $ */
--
-- Copyright (c) Oracle Corporation 1991, 1992, 1993. All rights reserved.
--
------------------------------------------------------------------------------
-- NAME : pelegins.pkb
--
-- DESCRIPTION
--	Procedures used for the delivery of legislative startup data. The
--	same procedures are also used for legislative refreshes.
--	This is the main driving package to call all other startup
--	packages and procedures.
-- MODIFIED
--	80.0  Ian Carline  14-09-1993	- Created
--      80.2  Ian Carline  03-11-1993   - Corrected order of balance routines
--      80.3  Ian Carline  03-11-1993   - Altered table definition of ass info
--                                        information types to include new
--                                        column.
--      80.4  Ian Carline  11-11-1993   - Debugged for the US delivery test.
--                                        Including lookups delivery.
--      80.5  Ian Carline  15-11-1993   - Further debugging and new delivery
--					  blocks for US Bechtel delivery.
--      80.6  Ian Carline  10-12-1993   - Added monetary units to delivery
--                                        scripts.
--	80.7  Ian Carline  13-12-1993   - Corrections to syntax
--	80.8  Rod Fine     16-12-1993   - Put AS on same line as CREATE stmt
--					  to workaround export WWBUG #178613.
--      80.9  Ian Carline  17-03-1994   - Changed the delivery of balance
--                                        dimensions, to compare details
--                                        using a reduced list of columns.
--      80.10 Ian Carline  18-04-1994   - Added the recreate DB items logic
--                                        as supplied by MWCALLAG.
--      80.11 Ian Carline  21-04-1994   - Install of user rows must consider
--                                        parent table id when looking for
--                                        duplicates.
--
--      70.9  Ian Carline  06-Jun-1994  - per 7.0 and 8.0 merged.
--                                        Rewrite.
--      70.10 Ian Carline  07-Jun-1994  - Amended check_next_sequence logic.
--      70.11 Ian Carline  08-Jun-1994  - Extended check_next_sequence logic.
--      70.12 Ian Carline  09-Jun-1994  - Corrected check_next_sequence logic.
--      70.13 Ian Carline  13-Jun-1994  - New install driving procedure.
--                                        Balance_feeds are only installed if
--                                        payroll is instaled with status of I.
--      70.15 Ian Carline  02-Aug-1994  - Altered check on assignment status
--                                         types. When looking for valid leg
--                                         subgroups, the statement used to
--                                         use 'IS NULL'. This caused an error
--                                         in Oracle 7.1.3 . Now the statement
--                                         uses an NVL statement to catch a
--                                         null condition.
--      70.16 Ian Carline  27-Jul-1994  - Checks on balance type name now view
--                                        '_' as ' ' .
--      70.17 Rod Fine     19-Sep-1994  - Removed the unnecessary cartesian
--                                        product join on all selects to get
--                                        the starting point for the sequence
--                                        number - improves performance.
--                                        Also added two new columns to
--					  installation procedures:
--					  - FEED_CHECKING_TYPE in
--					    PAY_BALANCE_DIMENSIONS;
--					  - JURISDICTION_LEVEL in
--					    PAY_BALANCE_TYPES.
--      70.18 Rod Fine     23-Nov-1994  - Suppressed index on business_group_id
--      70.19 Rod Fine     27-Mar-1995  - Added tax_type column to
--					  pay_balance_types table.
--      70.20 Rod Fine     07-Apr-1995  - Changed order in which hr_leg_loc is
--					  called, so that the new classn_id is
--					  updated BEFORE the table is
--					  transferred.
--      70.21 Rod Fine     14-Nov-1995  - #271139: install_urows wrongly omitted
--					  to include the user table id and row
--					  high range as part of the true key.
--					  Also added maintenance of the
--					  display_sequence column in the user
--					  rows table.
--      70.22 Rod Fine     03-Jan-96  - #331831 Add NVLs to the check for
--					identical pay_balance_types wherever
--					values may be null, to prevent flagging
--					as different rows which are identical
--					but have some null values.
--      70.23 Rod Fine     09-Jan-96  - #331831 Chngd NVL on jurisdiction_level
--					from ' ' to 0, as it's a number.
-- 70.24  rfine     27-Mar-96  n/a   	Removed call to the code which delivers
--					lookups. These are no longer delivered
--					by the HR mechanism: they're all
--					delivered by Datamerge.
--			       310520	Change to update pay_payment_types rows
--					if they already exist. This differs
--					from the previous functionality, which
--					only ever did inserts, no updates.
-- 70.25  rfine     01-Apr-96  n/a   	Fixed side-effect of previous fix to
--					271139. It did not allow for the
--					possibility that row_high_range could
--					be null. Need to add NVL.
--    70.25   M. Stewart   23-Sep-1996  - Updated table names from STU_ to HR_S_
-- 70.26  mhoyes    15-OCT-96  n/a   	Added code to procedure install which
--                                      loops through all exceptions raised
--                                      during phase 1 and outputs details of
--                                      these exceptions to the terminal using
--                                      dbms_output.
--    70.27   Tim Eyres	   02-Jan-1997	- Moved arcs header to directly after
--                                        'create or replace' line
--                                        Fix to bug 434902
--    70.30   Tim Eyres    02-Jan-1997  Correction to version number
--   110.1    mstewart     23-JUL-1997  Removed show error and select from
--                                      user errors statements
--                                      (R11 version # 70.31)
--   110.2    mfender      30-DEC-1997  bug 603778 - workaround in p.a.s.t.
--                                      to bump up sequence.
--   110.3    A. Mills     27-APR-1998  Bug 648835. Added a housekeeping
--                                      measure into install_bal_types
--                                      that removes any balance feeds
--                                      from the delivery table where
--                                      they are unnecessary because
--                                      they already exist on the live tables,
--                                      to ensure that latest balances are not
--                                      trashed by the live table's
--                                      update insert and delete triggers.
--  110.4     A.Mills      11-Sep-1998  Bug 724540. ORA-01722 Invalid Number
--                                      error fixed by ensuring proper
--                                      type-compare in remove/transfer row
--                                      (local) procedures between hr_application
--                                      ownerships and surrogate keys.
--  110.5     A.Mills      30-Sep-1998  Added extra validation on delete
--				        from pay_balance_feeds_f to ensure
--				        the legislative rows aren't deleted
--					incorrectly.
--  110.6     I. Harding   16/11/98     Commented out calls that insert lookups.
--  110.7     M.Reid       27/01/99     Tidied up balance checks for visible
--                                      legislations.  Although Core do not
--                                      seed balances currently the script did
--                                      not cater for core and legislation
--                                      balances clashing.
--  110.8     A.Mills      17/02/99     Added to_chars around surrogate id's
--                                      for comparison and entry into the
--                                      hr_application_ownerships table, in
--                                      response to ZA install problem.
--  110.9     A.Mills      05-Mar-1999  Changed implicit cursors to explicit
--                                      cursors, due to implicit cursor's
--                                      'select into null where exists'
--                                      type queries not working correctly.
--  110.10    S.Sivasub	   15-Mar-1999  Created additional procedures to seed
--                                      seven MLS's TL tables.
--  110.11    S.Sivasub	   12-Apr-1999  Modified procedures to seed seven MLS's
--                                      TL tables with a double check on the not exist.
--  115.14    A.Alogue	   12-May-1999  Fix to handling of pay_user_rows_f
--                                      to cope with null legislation_codes
--                                      in the seeding of core data.
--  115.15    I.Harding    21-May-99    removed dbms_output.put_line
--  115.16    IHARDING     26-may-99    replaced dbms_output.put_line by null
--  115.18    IHARDING     20-Jul-99    made all 9 numbers 15.
--  115.19    tbattoo      27-OCT-99    added procedure install_magnetic_block,
--					install_report_mappings
--  115.20    tbattoo      01-NOV-99    bug 1058335, moved installation of mag_records
--					to a seperate procedure, and not as a child
--					of magnetic_records
--  115.21    vmehta       10-nov-1999  added the call to
--                                      hr_legislation_local.translate_ele_dev_df
--                                      for transferring the balance type ids
--                                      element_type_ids stored in the
--                                      Element Developer DF
--  115.22    tbattoo      01-NOV-99    bug 1058335, moved installation of mag_records
--                                      to a seperate procedure, and not as a child
--                                      of magnetic_records
--  115.22    tbattoo      01-NOV-99    bug 1034683, changed instal_bal_types,
--					check_next_sequence, to update
--					pay_defined_balance_s
--  115.24    vmehta       07-DEC-99    Added report_format in
--                                      pay_report_format_mappings_f update
--                                      clause in transfer_row procedure.
--  115.25    ablinko      08-DEC-99    Only delete rows with no buisness group
--                                      from pay_user_column_instances_f
--  115.26    tbattoo      08-Feb-00    changed crt_exc so calls
--                                      hr_legislation.insert_hr_stu_exceptions
--					This is an autonomous transaction procedure
--					, so we dont loose error messages on rollback
--  115.27    mreid        24-Feb-00    Added territory code to payment types
--                                      unique key checking.
--  115.29    tbattoo      07-Mar-00    changed to check for null territory code
--					to payment types
--  115.30    tbattoo      03-Apr-00    bug 1234525 - insert translated value for
--					input value name 'Pay Vaue'
--  115.31    RThirlby     11-APR-2000  Added call to translate_ca_ele_dev_df
--                                      for transferrind CA balance type ids
--                                      stored in the Element Developer DF.
--  115.32    tbattoo      12-APr-2000  Added new columns to install
--      				pay_legislative_field_info
--  115.33    tbattoo      18-Apr-2000  Added updatable_flag column to
--					install_report_mappings
--  115.34    tbattoo      25-Apr-2000  Added support for pay_report_format_items_f
--  115.35    mreid        19-Jun-2000  Added to update_sequence in case
--                                      sequence has been rebuilt and is less
--                                      than the installed rows.
--  115.36    divicker     11-Sep-2000  Performace changes
--  115.37    alogue       03-Nov-2000  Temporary fix for bug 1485136 : random
--                                      loss of balance_feeds.
--  115.39    alogue       06-Nov-2000  Permanent fix for bug 1485136.
--                                      Reimplemented code to avoid needless
--                                      deletion and recreation of balance
--                                      feeds (thereby avoiding needless loss
--                                      of latest balances). We don't now delete
--                                      from hr_s_balance_feeds_f ... we only
--                                      select back those feeds that don't match
--                                      rows in pay_balance_feeds_f instead.
--                                      Bug 1490386.
--  115.40    amills       21-Dec-2000  1550308. Handle exception whereby
--                                      legislative user rows on live table
--                                      have same row_low_range_or_name or
--                                      rlron and high range combination but
--                                      more than one user_row_id in Phase 1.
--                                      Previously caused ora-1422.
--  115.41    alogue       21-Feb-2001  Performance fix to install_bal_types
--                                      transfer_row.
--  115.42    divicker     25-APR-2001  Added GROSSUP_ALLOWED_FLAG processing
--                                      to balance_type transfer
--  115.43    divicker     May 2001     Support for parallel hrglobal and
--                                      better debugging into HR_STU_EXCEPTIONS
--  115.44    divicker     14-Jun-2001  Bug fix 1803867
--  115.45    mreid        02-Jul-2001  Fixed monetary unit app ownership
--  115.46    divicker     07-Jul-2001  Fix to maintain_history PK violation
--  115.47    divicker     11-Jul-2001  Fix to add distinct to hr_s_defined_balances
--  115.48    divicker     19-Jul-2001  Fix to hr_s_defined_balances again so
--                                      that we don't update the defined_bal_id
--                                      by the seq for all values of the orig
--                                      def_bal_id but only those matching
--                                      the original balance_type_id as well
--  115.49    divicker     19-JUL-2001  Version sync up
--  115.50    divicker     26-JUL-2001  speed up sequence setting
--  115.51    divicker     26-JUL-2001  pay_magnetic_blocks fix for installing
--                                      data over a previous install for APAC
--  115.52    tbattoo      15-Aug-2001  fixed issue with check_seq on empty hr_s
--					tables.
--  115.53    vmehta       25-Aug-2001  Removed calls to translate_us_ele_dev_df
--  115.54    tbattoo      29-Aug-2001  Fix to install_report_format_mappings
--  115.55    divicker     03-SEP-2001  nvl added to munge sequence for fresh
--                                      installs (1967626). remove owner hr
--  115.56    divicker     03-SEP-2001  munge_sequence owner selection added
--  115.57    divicker     07-SEP-2001  2 fixes to install_leg_field
--  115.58    divicker     13-SEP-2001  fix so that hr_stu_history contains info
--                                      on all legislations selected
--  115.59    divicker     14-SEP-2001  nvl added to validation_name in select
--                                      stmt in install_leg_field proc.
--  115.60    divicker     24-SEP-2001  fix for munge_sequence where same named
--                                      sequence has more than one owner
--  115.61    divicker     29-SEP-2001  performance fixes
--  115.62    divicker     01-OCT-2001  remove sho err and uncomment exit from end
--  115.63    divicker     02-OCT-2001  more performance fixes
--  115.64    divicker     15-OCT-2001  fix to install_magnetic_blocks
--  115.65    divicker     16-OCT-2001  another fix for magnetic_records
--  115.66    divicker     17-OCT-2001  big speed up
--  115.67    divicker     25-OCT-2001  performance-use temp HR_S indexes
--  115.68    divicker     21-NOV-2001  del hr_s_app_ownerships commented
--  115.69    divicker     21-NOV-2001  performance
--  115.70    divicker     14-FEB-2002  fix to pet tl
--  115.71    divicker     19-MAR-2002  added support for PAY_REPORT_FORMAT_
--                                      MAPPINGS_F.DEINITIALIZATION_CODE
--  115.72    divicker     19-MAR-2002  Added dbdrv checkfile commands
--  115.73    divicker     07-MAY-2002  Added w/around for situation where
--                                      customer has Core balance feeds
--                                      2323024
--  115.74    mreid        21-JUN-2002  Added support for run balance
--                                      architecture
--  115.75    divicker     25-JUN-2002  defined balances now don't get deleted
--                                      simply if the hr_s and pay IDs match
--                                      so that changes to any column will get
--                                      transferred to live
-- 115.77     RThirlby     30-JUL-2002  Bug 2430399 After insert of balance
--                                      classification, added call to
--                                      hr_balance_feeds.ins_bf_bal_class, to
--                                      create balance feeds for existing
--                                      elements with same classification as
--                                      the balance classification inserted.
-- 115.78     RThirlby     06-AUG-2002  Bug 2496207 - changed update of
--                                      pay_defined_balances to not included
--                                      RUN_BALANCE_STATUS, so this column will
--                                      retain its original value.
-- 115.79     DVickers     12-AUG-2002  Managed db sequence fix
-- 115.80     DVickers     27-SEP-2002  HR_S->HR_APP_OWN move for ZZ leg
--                                      Internation Payroll requirement
-- 115.81     DVickers     07-OCT-2002  Added distinct to c_main legislative
--                                      driver cursor
-- 115.81.1159.2 DVickers  24-OCT-2002  Fix to create_zz_leg_rule proc to nable
--                                      rerun
-- 115.84     DVickers     06-JAN-2003  Support for PAY_DIMENSION_ROUTES
-- 115.85     DVickers     06-JAN-2003  Add a call to install_dimension_routes
-- 115.86     DVickers     14-JAN-2003  Fixes to install_dimension_routes
-- 115.87     DVickers     07-FEB-2003  Add bal_type columns
-- 115.88     DVickers     13-FEB-2003  Add support for pay_balance_categories
-- 115.89     DVickers     04-MAR-2003  Corrected for null bal cat in bal type
-- 115.90     DVickers     14-MAR-2003  explicit hrsao.key_value conversion
-- 115.91     DVickers     17-MAR-2003  Fix for correcting sync up of base_
--                                      balance_type_id
-- 115.92     DVickers     15-APR-2003  Added bg null check for update_uid
--                                      pay_defined_balances. Bug 2906340
-- 115.93     DVickers     24-APR-2003  Fix for delete of dt user_rows, cols
-- 115.94     DVickers     06-MAY-2003  del dim routes based on bal dim id
--                                      and priority not route_id
-- 115.95     DVickers     04-JUN-2003  new_category_name rollback correction
-- 115.95.11510.2 DVickers 17-JUL-2003  user_category_name col support for
--                                      pay_balance_categories_f
-- 115.95.11510.3 DVickers 18-JUL-2003  insert category_name if
--                                      user_category_name is null
-- 115.96     Scchakra     16-JUL-2003  Bug 2982582. Added code in install_att
--                                      to install startup data in table
--                                      pay_monetary_units_tl.
-- 115.97     DVickers     30-SEP-2003  Added distinct to create_zz_leg_rule
-- 115.98     DVickers     02-OCT-2003  Added 4 new cols to
--                                      HR_S_LEGISLATIVE_FIELD_INFO
-- 115.99     DVickers     02-SEP-2003  Added CATEGORY as well
-- 115.100    DVickers     05-NOV-2003  check for existence of pay_dimension
--                                      route parents before insertion
-- 115.101    DVickers     17-MAR-2004  Bug 3510411. gscc fixes
-- 115.102    DVickers     18-MAR-2004  Refix to 115.101
-- 115.103    DVickers     29-APR-2004  HRRUNPRC named PIPE for all common
--                                      unhandled exceptions
-- 115.104    DVickers     06-MAY-2004  Ensure Phase exceptions will retain the --                                      original error data and not cause
--                                      adpatch to rerun the whole process but
--                                      abort immediately
-- 115.105    DVickers     12-MAY-2004  Fix for 8i
-- 115.106    DVickers     16-JUN-2004  Close pipe on ins pay_user_col_inst
--                                      and reraise
-- 115.107    tvankayl     10-AUG-2004  Added code in install_report_items
--                                      and install_report_mappings to
--                                      include the newly added columns.
--                                      Changes done for Bug 3730528.
-- 115.108    divicker     28-SEP-2004  Check install language when deleting
--                                      element type tl or bal type tl rows
--                                      based on a changed certain field
--                                      bug 3280179
-- 115.109    divicker     28-SEP-2004  Remove sho err. oops!
-- 115.110    divicker     10-NOV-2004  Add TEMP_ACTION_FLAG to HR_S_RFM
-- 115.111    divicker     02-FEB-2005  Full col list for org info type
-- 115.112    divicker     02-FEB-2005  Remove legislative loop so we
--                                      process everything at the same time
--                                      Trace to show progress
-- 115.113    divicker     24-FEB-2005  Minor trace tidy up
-- 115.114    divicker     12-APR-2005  Fix for changed base reporting name
--                                      and description columns to TL version
--                                      for balance types and element types
-- 115.115    divicker     12-APR-2005  Add element class description fix
--                                      similar to 114
-- 115.116    divicker     29-APR-2005  Delete user entities owned by defined
--                                      balances whose balance dimensions
--                                      route_id is going to change.
--                                      Bug 4328538.
-- 115.117    mmukherj     03-MAY-2005  Commented out calls to
--                                      translate_ca_ele_dev_df. The updates
--                                      are being done in pycaearn.sql.
--                                      Calling these
--                                      procedure was causing HRGLOBAL to
--                                      error out if hrrunprc restars for some
--                                      other reason.
-- 115.118    divicker     06-MAY-2005  Ensure bal dim exists on live if
--                                      checking route id
-- 115.119    divicker     12-MAY-2005  remove auto trace in exceptions
-- 115.120    divicker     21-JUN-2005  Need to ensure user entity and route
--                                      parameter value rebuild in reib if the
--                                      dimension route has changed
--                                      also if run_dimension_id changes
-- 115.121    divicker     24-JUN-2005  Frther fix to 4417200 and del form usa
-- 115.122    divicker     26-JUL-2005  Fix for picking up extra route changed
--                                      formula usages
-- 115.123    divicker     03-AUG-2005  Programattic debugging via pay patch s
-- 115.124    divicker     10-AUG-2005  Extension to debug
-- 115.125    divicker     28-SEP-2005  Trace off added to one stmt
-- 115.126    divicker     26-OCT-2005  Bug 4701028. Correct urow insert
--                                      behaviour when date track change adds
--                                      a new row with existing low high range
-- 115.127    divicker     26-OCT-2005  Fix gscc to_date
-- 115.128    divicker     09-NOV-2005  install_urow fix for bug 4725573
-- 115.129    divicker     21-NOV-2005  short term fix for 4728513 - make
--                                      update_uid use 50000000
-- 115.130    divicker     12-DEC-2005  identical to 115.129
-- 115.131    divicker     12-DEC-2005  trash latest balance conditional
-- 115.132    divicker     16-DEC-2005  ect fix
-- 115.133    divicker     09-JAN-2006  balance related performance fixes
-- 115.134    divicker     11-JAN-2006  check on new bal type
-- 115.135    divicker     26-JAN-2006  switch order of del comp info and usg
-- 115.136    divicker     23-MAR-2006  hrrunprc rerunnability
-- 115.137    divicker     30-AUG-2006  Extra col chk on leg field
-- 115.138    divicker     01-SEP-2006  fix for 115.137 - bug 5507103
-- 115.139    divicker     04-SEP-2006  Remove sho err
-- 115.140    divicker     21-SEP-2006  Add index_ff to balance_types fts
-- 115.142    divicker     30-OCT-2006  bal feed scale check skip
-- 115.143    divicker     13-DEC-2006  support for pay_bal_cat_f_tl
-- 120.13.1200000.2 divicker 08-FEB-2007 Sync up to 115.,143 with org_info_type diff
-- 1200000.2  divicker     10-JUL-2007  pbtt row fetch cursor was not picking
--                                      up rows changing from null reporting
--                                      name - bug 6146653
-- 120.13.12000000.3 sivanara 24-JUL-2007 Added reconciliation_function column
--                                     to cursor stu inside Procedure
--                                     install_payment_types -- bug 8726506
--                                     Modified insert and update statement
--                                     inside procedure transfer_row
-- 120.13.12000000.4 sivanara 27-JUL-2007 Removed empty line from cursor
--                                     stu inside Procedure install_payment_types
--
------------------------------------------------------------------------------

PROCEDURE hrrunprc_trace_on is
begin
  if hr_legislation.g_debug_cnt > 0 then
    hr_utility.trace_on(null, 'HRRUNPRC');
  end if;
end;

PROCEDURE hrrunprc_trace_off is
begin
  if hr_legislation.g_debug_cnt > 0 then
    hr_utility.trace_off;
  end if;
end;

PROCEDURE insert_hr_stu_exceptions (p_table_name varchar2,
                                   p_surrogate_id number,
                                   p_text varchar2,
                                   p_true_key varchar2)
IS
 PRAGMA AUTONOMOUS_TRANSACTION;
BEGIN

        insert into HR_STU_EXCEPTIONS
            (table_name
            ,surrogate_id
            ,exception_text
            ,true_key)
	select
	    upper(p_table_name)
            ,p_surrogate_id
            ,p_text
            ,p_true_key
	from dual
            where not exists
                (select null
			 from   hr_stu_exceptions
			 where  p_surrogate_id = surrogate_id
			 and    table_name = upper(p_table_name));

	commit;
END insert_hr_stu_exceptions;


PROCEDURE munge_sequence (p_seq_name varchar2,
                          p_seq_val number,
                          p_req_val number)
IS
  old_inc number;
  new_inc number;
  l_sql_stmt varchar2(2000);
  l_cursor   number;
  l_ret   number;
  dummy   number;
  l_seq_managed number;

  l_status    varchar2(50);
  l_industry  varchar2(50);
  l_per_owner varchar2(30);
  l_ret_per   boolean := FND_INSTALLATION.GET_APP_INFO ('PER', l_status,
                                                      l_industry, l_per_owner);

  cursor c_seq is
    select increment_by
    from   all_sequences
    where  sequence_name = p_seq_name
    and    sequence_owner = l_per_owner;

BEGIN

 -- If a database is sequence managed, we must not modify
 -- the sequence values. A sequence managed database will
 -- have entries in the table hr_dm_databases (this table
 -- is not used for any other purpose), ie. a count of
 -- zero indicates it is safe to modify sequences.

 SELECT COUNT(*)
 INTO l_seq_managed
 FROM hr_dm_databases;

 IF l_seq_managed = 0 THEN

  FOR lp_c_seq in c_seq LOOP

    -- Set new increment_by value to be the difference
    -- between our current sequence value and the
    -- required value plus a bit
    -- Use nvl on p_req_val in case of fresh installs where no live
    -- data currently present
    old_inc := lp_c_seq.increment_by;
    new_inc := nvl(p_req_val, 1) + 30 - p_seq_val;

    -- Alter the sequence to use this inc value
    l_sql_stmt := 'ALTER SEQUENCE ' || l_per_owner || '.' || p_seq_name ||
                    ' INCREMENT BY '|| new_inc;
    l_cursor := dbms_sql.open_cursor;
    dbms_sql.parse(l_cursor, l_sql_stmt, DBMS_SQL.V7);
    l_ret := dbms_sql.execute(l_cursor);
    dbms_sql.close_cursor(l_cursor);

    -- Now select the sequence once to bump it past our target
    l_sql_stmt := 'SELECT ' || l_per_owner || '.' || p_seq_name || '.NEXTVAL FROM DUAL';
    EXECUTE IMMEDIATE l_sql_stmt INTO dummy;

    -- Reset the sequence to use the old value
    l_sql_stmt := 'ALTER SEQUENCE ' || l_per_owner || '.' || p_seq_name ||
                    ' INCREMENT BY '|| old_inc;
    l_cursor := dbms_sql.open_cursor;
    dbms_sql.parse(l_cursor, l_sql_stmt, DBMS_SQL.V7);
    l_ret := dbms_sql.execute(l_cursor);
    dbms_sql.close_cursor(l_cursor);

  END LOOP;

 END IF;

END munge_sequence;



PROCEDURE create_zz_leg_rule
IS
BEGIN

hrrunprc_trace_on;
hr_utility.trace('enter: zz_leg_rule');
hrrunprc_trace_off;

INSERT INTO hr_application_ownerships
(key_name
,product_name
,key_value)
SELECT distinct ao.key_name
      ,ao.product_name
      ,ao.key_value
FROM   hr_s_application_ownerships   ao
      ,pay_element_classifications pec
WHERE  pec.legislation_code     = 'ZZ'
  AND  ao.key_name             = 'CLASSIFICATION_ID'
  AND  TO_NUMBER(ao.key_value) = pec.classification_id
  AND  NOT EXISTS (SELECT null
                   FROM   hr_application_ownerships ao2
                   WHERE  ao2.key_name     = ao.key_name
                     AND  ao2.product_name = ao.product_name
                     AND  ao2.key_value    = ao.key_value)
UNION ALL
SELECT distinct ao.key_name
      ,ao.product_name
      ,ao.key_value
FROM   hr_s_application_ownerships ao
      ,pay_balance_types         pbt
WHERE  pbt.legislation_code     = 'ZZ'
  AND  ao.key_name             = 'BALANCE_TYPE_ID'
  AND  TO_NUMBER(ao.key_value) = pbt.balance_type_id
  AND  NOT EXISTS (SELECT null
                   FROM   hr_application_ownerships ao2
                   WHERE  ao2.key_name     = ao.key_name
                     AND  ao2.product_name = ao.product_name
                     AND  ao2.key_value    = ao.key_value)
UNION ALL
SELECT distinct ao.key_name
      ,ao.product_name
      ,ao.key_value
FROM   hr_s_application_ownerships ao
      ,pay_balance_dimensions pbd
WHERE  pbd.legislation_code ='ZZ'
  AND  ao.key_name          = 'BALANCE_DIMENSION_ID'
  AND  TO_NUMBER(ao.key_value) = pbd.balance_dimension_id
  AND  NOT EXISTS (SELECT null
                   FROM   hr_application_ownerships ao2
                   WHERE  ao2.key_name     = ao.key_name
                     AND  ao2.product_name = ao.product_name
                     AND  ao2.key_value    = ao.key_value)
UNION ALL
SELECT distinct ao.key_name
      ,ao.product_name
      ,ao.key_value
FROM   hr_s_application_ownerships ao
      ,pay_defined_balances pdb
WHERE  pdb.legislation_code ='ZZ'
  AND  ao.key_name          = 'DEFINED_BALANCE_ID'
  AND  TO_NUMBER(ao.key_value) = pdb.defined_balance_id
  AND  NOT EXISTS (SELECT null
                   FROM   hr_application_ownerships ao2
                   WHERE  ao2.key_name     = ao.key_name
                     AND  ao2.product_name = ao.product_name
                     AND  ao2.key_value    = ao.key_value)
UNION ALL
SELECT distinct ao.key_name
      ,ao.product_name
      ,ao.key_value
FROM   hr_s_application_ownerships ao
      ,ff_routes fr
      ,pay_balance_dimensions pbd
WHERE  pbd.legislation_code ='ZZ'
  AND  ao.key_name          = 'ROUTE_ID'
  AND  TO_NUMBER(ao.key_value) = fr.route_id
  AND  fr.route_id = pbd.route_id
  AND  NOT EXISTS (SELECT null
                   FROM   hr_application_ownerships ao2
                   WHERE  ao2.key_name     = ao.key_name
                     AND  ao2.product_name = ao.product_name
                     AND  ao2.key_value    = ao.key_value);

hrrunprc_trace_on;
hr_utility.trace('exit: zz_leg_rule');
hrrunprc_trace_off;

END create_zz_leg_rule;


--****************************************************************************
-- INSTALLATION PROCEDURE FOR : PER_ASSIGNMENT_STATUS_TYPES
--****************************************************************************

	PROCEDURE install_past (p_phase IN number)
	------------------------------------------
	IS
    -- This procedure does not support the changing of the default flag. It
    -- can insert new assignment status types, and update child refereences
    -- to status types, to ensure the integrity of other delivered objects.

    l_inst_rowid	 rowid;		-- rowid of the installed row to update
    l_null_return varchar2(1);  	-- used for 'select null' statements
    l_new_surrogate_key number(15);	-- new uid.

    CURSOR stu				-- Selects all rows from startup entity
    IS
	select user_status
	,      per_system_status
	,      pay_system_status
	,      default_flag
	,      rowid
	,      assignment_status_type_id c_surrogate_key
	,      last_update_date
	,      legislation_code c_leg_code
	,      null c_leg_sgrp
	from   hr_s_assignment_status_types;

    stu_rec stu%ROWTYPE;			-- Record for above SELECT

    PROCEDURE crt_exc (exception_type IN varchar2)
    ----------------------------------------------
    IS
	-- Reports any exceptions during the delivery of startup data to
	-- PER_ASSIGNMENT_STATUS_TYPES

    BEGIN
	-- When the installation procedures encounter an error that cannot
	-- be handled, an exception is raised and all work is rolled back
	-- to the last savepoint. The installation process then continues
	-- with the next primary key to install. The same exception will
	-- not be raised more than once.

	rollback to new_primary_key;
               insert_hr_stu_exceptions('per_assignment_status_types'
               ,      stu_rec.c_surrogate_key
               ,      exception_type
               ,      'User: ' || stu_rec.user_status ||
                      ' PER: ' || stu_rec.per_system_status ||
                      ' PAY: ' || stu_rec.pay_system_status);

    END crt_exc;


    PROCEDURE check_next_sequence
    -----------------------------
    IS

	v_sequence_number number(15);
	v_min_delivered number(15);
	v_max_delivered number(15);
        v_max_live      number(15);
        cnt             number(15);

	-- Surrogate id conflicts may arise from two scenario's:
	-- 1. Where the newly select sequence value conflicts with values
	--    in the STU tables.
	-- 2. Where selected surrogate keys, from the installed tables,
	--    conflict with other rows in the STU tables.
	--
	-- Both of the above scenario's are tested for.
	-- The first is a simple match, where if a value is detected in the
	-- STU tables and the installed tables then a conflict is detected. In
	-- This instance all STU surrogate keys, for this table, are updated.
	-- The second is tested for using the sequences.
	-- If the next value from the live sequence is within the range of
	-- delivered surrogate id's then the live sequence must be incremented.
	-- If no action is taken, then duplicates may be introduced into the
	-- delivered tables, and child rows may be totally invalidated.

    BEGIN


	BEGIN	--check that the installed id's will not conflict
		--with the delivered values

            select count(*)
            into cnt
            from hr_s_assignment_status_types;

            If cnt=0 then return; end if;

	    select distinct null
	    into   l_null_return
	    from   per_assignment_status_types a
	    where  exists
		(select null
		 from   hr_s_assignment_status_types b
		 where a.assignment_status_type_id=b.assignment_status_type_id
		);

	    --conflict may exist
	    --update all assignment_status_type_id's to remove conflict

	    update /*+NO_INDEX*/ hr_s_assignment_status_types
	    set assignment_status_type_id=assignment_status_type_id - 50000000;

            update /*+NO_INDEX*/ hr_s_status_processing_rules_f
            set assignment_status_type_id=assignment_status_type_id - 50000000;

	    update hr_s_application_ownerships
	    set    key_value = key_value - 50000000
	    where  key_name = 'ASSIGNMENT_STATUS_TYPE_ID';

	EXCEPTION WHEN NO_DATA_FOUND THEN NULL;

	END; --check of assignment_status_type_id

	select min(assignment_status_type_id) - (count(*) *3)
	,      max(assignment_status_type_id) + (count(*) *3)
	into   v_min_delivered
	,      v_max_delivered
	from   hr_s_assignment_status_types;

        select max(assignment_status_type_id)
        into   v_max_live
        from   per_assignment_status_types;

	select per_assignment_status_types_s.nextval
	into   v_sequence_number
	from   dual;

	-- bug 603778
	-- There is a problem with delivery mechanism for
	-- per_assignment_status_types.  We are delivering one
	-- legislative row for R11 with an assignment_status_type_id of
	-- 50002.  Existing code appears to assume that a row will be delivered
	-- with an id of 1.  This workaround will bump up the sequence
	-- past 50002 so that the p.a.s.t. constraint will not be
	-- violated.

        if v_min_delivered > 1 then v_min_delivered := 1; end if;

        --

	IF (v_sequence_number BETWEEN v_min_delivered AND v_max_delivered)
           OR (v_sequence_number < v_max_live) THEN

           IF v_max_live > v_max_delivered THEN

             hr_legislation.munge_sequence('PER_ASSIGNMENT_STATUS_TYPES_S',
                                           v_sequence_number,
                                           v_max_live);
           ELSE

             hr_legislation.munge_sequence('PER_ASSIGNMENT_STATUS_TYPES_S',
                                           v_sequence_number,
                                           v_max_delivered);
           END IF;
        END IF;

    END check_next_sequence;


    PROCEDURE update_uid
    --------------------
    IS

    BEGIN

	BEGIN
	    select distinct assignment_status_type_id
	    into   l_new_surrogate_key
	    from   per_assignment_status_types
	    where  user_status = stu_rec.user_status
	    and    per_system_status = stu_rec.per_system_status
	    and    business_group_id is null
	    and (  (pay_system_status is null and stu_rec.pay_system_status is null)
	        or (pay_system_status = stu_rec.pay_system_status) )
            and (  (legislation_code is null and  stu_rec.c_leg_code is null)
                or (legislation_code = stu_rec.c_leg_code) );

   	EXCEPTION WHEN NO_DATA_FOUND THEN

	    select per_assignment_status_types_s.nextval
	    into   l_new_surrogate_key
	    from   dual;
                 WHEN TOO_MANY_ROWS THEN
                        hrrunprc_trace_on;
                        hr_utility.trace('sel per_assignment_status_types TMR');

                        hr_utility.trace('user_status  ' ||
                          stu_rec.user_status);
                        hr_utility.trace('per_system_status  ' ||
                          stu_rec.per_system_status);
                        hr_utility.trace('pay_system_status  ' ||
                          stu_rec.pay_system_status);
                        hr_utility.trace(':lc: ' || ':' ||
                          stu_rec.c_leg_code || ':');
                        hrrunprc_trace_off;
                        raise;
	END;

	update hr_s_assignment_status_types
	set    assignment_status_type_id = l_new_surrogate_key
	where  assignment_status_type_id = stu_rec.c_surrogate_key;

	update hr_s_status_processing_rules_f
	set    assignment_status_type_id = l_new_surrogate_key
	where  assignment_status_type_id = stu_rec.c_surrogate_key;

	update hr_s_application_ownerships
	set    key_value = to_char(l_new_surrogate_key)
	where  key_value = to_char(stu_rec.c_surrogate_key)
	and    key_name = 'ASSIGNMENT_STATUS_TYPE_ID';

    END update_uid;

    PROCEDURE remove (subject IN varchar2)
    --------------------------------------
    IS
        -- Remove a row from either the startup/delivered tables (D) or the installed
	-- tables (I) as specified by the parameter.

    BEGIN

	IF subject = 'D' THEN
	    delete from hr_s_assignment_status_types
	    where  rowid = stu_rec.rowid;
	ELSE
	    IF p_phase = 1 THEN return; END IF;
	    delete from per_assignment_status_types
	    where  rowid = l_inst_rowid;
	END IF;

    END remove;

    FUNCTION valid_ownership RETURN BOOLEAN
    ---------------------------------------
    IS
	-- Test ownership of this current row

    BEGIN
	-- This routine only operates in phase 1. Rows are present in the
	-- table hr_application_ownerships in the delivery account, which
	-- dictate which products a piece of data is used for. If the query
	-- returns a row, then this data is required, and the function will
	-- return true. If no rows are returned and an exception is raised,
	-- then this row is not required and may be deleted from the delivery
	-- tables.

	-- If legislation code and subgroup code are included on the delivery
	-- tables, a check must be made to determine if the data is defined for
	-- a specific subgroup. If so the subgroup must be 'A'ctive for this
	-- installation.

	-- A return code of TRUE indicates that the row is required.

	-- The exception is raised within this procedure if no rows are returned
	-- in this select statement. If no rows are returned then one of the
	-- following is true:
	--     1. No ownership parameters are defined.
	--     2. The products, for which owning parameters are defined, are not
	--        installed with as status of 'I'.
	--     3. The data is defined for a legislation subgroup that is not active.

	IF p_phase <> 1 THEN return TRUE; END IF;

	-- Cause an exception to be raised if this row is not needed

	select null
	into l_null_return
        from dual
	where exists (
	    select null
	    from   hr_s_application_ownerships a
	    ,      fnd_product_installations b
	    ,      fnd_application c
	    where  a.key_name = 'ASSIGNMENT_STATUS_TYPE_ID'
	    and    a.key_value = l_new_surrogate_key
	    and    a.product_name = c.application_short_name
	    and    c.application_id = b.application_id
            and    ((b.status = 'I' and c.application_short_name <> 'PQP')
                    or
                    (b.status in ('I', 'S') and c.application_short_name = 'PQP')));


	return TRUE;		-- Row is required

    EXCEPTION WHEN NO_DATA_FOUND THEN

	-- The row is not needed for any installed product. Remove it from the
	-- delivery tables and return false to indicate it is not required.

	remove('D');
	return FALSE;  -- Row not required

    END valid_ownership;

    PROCEDURE transfer_row
    ----------------------
    IS
	-- Check if a delivered row is needed and insert into the
	-- live tables if it is.

	l_inst_row number(1);

    BEGIN
   	l_inst_row := null;

	BEGIN

	    -- Perform a check to see if the primary key has been created within
	    -- a visible business group. Ie: the business group is for the same
	    -- legislation as the delivered row, or the delivered row has a null
	    -- legislation. If no rows are returned then the primary key has not
	    -- already been created by a user.


	    select distinct 1
	    into   l_inst_row
	    from   per_assignment_status_types
	    where  user_status = stu_rec.user_status
	    and    per_system_status = stu_Rec.per_system_status
	    and    business_group_id is null
	    and (  (pay_system_status is null and stu_rec.pay_system_status is null)
	        or (pay_system_status = stu_rec.pay_system_status) )
	    and (  (legislation_code is null and stu_rec.c_leg_code is null)
                or (legislation_code = stu_rec.c_leg_code) );

	    -- If the flow drops to here, then this row is not needed.

	    remove('D');

	EXCEPTION WHEN NO_DATA_FOUND THEN


	    IF stu_rec.default_flag = 'Y' THEN

	        BEGIN

		    select null
		    into   l_null_return
		    from   dual
		    where  exists (

			select null
			from   per_assignment_status_types a
			,      per_business_groups b
			where  a.default_flag = 'Y'
			and    a.per_system_status = stu_rec.per_system_status
			and    ( (a.business_group_id is not null
		    	   and b.business_group_id = a.business_group_id
		       	   and b.legislation_code =
			       nvl(stu_rec.c_leg_code,b.legislation_code) )
			or     (a.business_group_id is null
		       	   and nvl(a.legislation_code,'X') =
		               nvl(stu_rec.c_leg_code,'X') ) ));

		    crt_exc('This PER_SYSTEM_TYPE has a default defined');

		EXCEPTION WHEN NO_DATA_FOUND THEN

		    null;

		END;

	    END IF;

	END;

	-- When the procedure is called in phase 1, there is no need to
	-- actually perform the transfer from the delivery tables into the
	-- live. Hence if phase = 1 control is returned to the calling
	-- procedure and the next row is returned.

	IF p_phase = 1 THEN return; END IF;

	-- If the procedure is called in phase 2, then the live row is updated
	-- with the values on the delivered row.

	-- The routine check_parents validates foreign key references and
	-- ensures referential integrity. The routine checks to see if the
	-- parents of a given row have been transfered to the live tables.

	-- This may only be called in phase two since in phase one all
	-- parent rows will remain in the delivery tables.

	-- The local variable 'l_inst_rowid' is used to decide if there is
	-- a live row present or not. If this variable is not null it will
	-- contain the rowid of the installed row to  be updated.

	-- The last step of the transfer, in phase 2, is to delete the now
	-- transfered row from the delivery tables.

	IF l_inst_row is null THEN

	    insert into per_assignment_status_types
		(ASSIGNMENT_STATUS_TYPE_ID
		,BUSINESS_GROUP_ID
		,LEGISLATION_CODE
		,ACTIVE_FLAG
		,DEFAULT_FLAG
		,PRIMARY_FLAG
		,USER_STATUS
		,PAY_SYSTEM_STATUS
		,PER_SYSTEM_STATUS
		,LAST_UPDATE_DATE
		,LAST_UPDATED_BY
		,LAST_UPDATE_LOGIN
		,CREATED_BY
		,CREATION_DATE)
		select ASSIGNMENT_STATUS_TYPE_ID
		    ,BUSINESS_GROUP_ID
		    ,LEGISLATION_CODE
		    ,ACTIVE_FLAG
		    ,DEFAULT_FLAG
		    ,PRIMARY_FLAG
		    ,USER_STATUS
		    ,PAY_SYSTEM_STATUS
		    ,PER_SYSTEM_STATUS
		    ,LAST_UPDATE_DATE
		    ,LAST_UPDATED_BY
		    ,LAST_UPDATE_LOGIN
		    ,CREATED_BY
		    ,CREATION_DATE
		from hr_s_assignment_status_types
		where rowid = stu_rec.rowid;

	END IF;

	-- Delete delivered row now it has been installed

	remove('D');

    END transfer_row;

BEGIN

    -- This is the main loop to perform the installation logic. A cursor
    -- is opened to control the loop, and each row returned is placed
    -- into a record defined within the main procedure so each sub
    -- procedure has full access to all returrned columns. For each
    -- new row returned, a new savepoint is declared. If at any time
    -- the row is in error a rollback is performed to the savepoint
    -- and the next row is returned. Ownership details are checked and
    -- if the row is required then the surrogate id is updated and the
    -- main transfer logic is called.

    IF p_phase = 1 THEN check_next_sequence; END IF;

    FOR delivered IN stu LOOP

	savepoint new_primary_key;

	-- Make all cursor columns available to all procedures

   	stu_rec := delivered;

	IF p_phase = 1 THEN update_uid; END IF;

	-- Test the row ownerships for the current row

	IF valid_ownership THEN

	    transfer_row;

	END IF;

    END LOOP;

END install_past;

--****************************************************************************
-- INSTALLATION PROCEDURE FOR : PAY_BALANCE_CATEGORIES
--****************************************************************************
PROCEDURE install_bal_categories (p_phase IN NUMBER)
----------------------------------------------------
IS
    row_in_error                exception;
    l_current_proc              varchar2(80) := 'hr_legislation.install_bal_categories';
    l_new_balance_category_id   number(15);
    l_null_return               varchar2(1);

    CURSOR c_distinct
    IS
        select max(effective_end_date) c_end
        ,      BALANCE_CATEGORY_ID c_surrogate_key
        ,      CATEGORY_NAME c_true_key
        ,      legislation_code
        from   hr_s_balance_categories_f
        group  by BALANCE_CATEGORY_ID
        ,         CATEGORY_NAME
        ,         legislation_code;

    CURSOR c_each_row (pc_bal_cat_id varchar2)
    IS
        -- The primary key has already been selected using the above cursor.
        -- This cursor accepts the primary key as a parameter and selects all
        -- date effective rows for it.

        select *
        from   hr_s_balance_categories_f
        where  BALANCE_CATEGORY_ID = pc_bal_cat_id;

    r_distinct          c_distinct%ROWTYPE;
    r_each_row          c_each_row%ROWTYPE;

    PROCEDURE check_next_sequence
    -----------------------------
    IS

        v_sequence_number number(15);
        v_min_delivered number(15);
        v_max_delivered number(15);
        v_max_live      number(15);
        cnt      number(15);

    BEGIN

        BEGIN

            select count(*)
            into cnt
            from hr_s_balance_categories_f;

            If cnt=0 then return; end if;

            select distinct null
            into   l_null_return
            from   pay_balance_categories_f a
            where  exists
                (select null
                 from   hr_s_balance_categories_f b
                 where  a.BALANCE_CATEGORY_ID = b.BALANCE_CATEGORY_ID
                );

            --conflict may exist
            --update all user_row_id's to remove conflict

            update /*+NO_INDEX*/ hr_s_balance_categories_f
            set    BALANCE_CATEGORY_ID = BALANCE_CATEGORY_ID - 50000000;

            update /*+NO_INDEX*/ hr_s_balance_types
            set    BALANCE_CATEGORY_ID = BALANCE_CATEGORY_ID - 50000000;

        EXCEPTION WHEN NO_DATA_FOUND THEN NULL;

        END;

        select min(BALANCE_CATEGORY_ID) - (count(*) *3)
        ,      max(BALANCE_CATEGORY_ID) + (count(*) *3)
        into   v_min_delivered
        ,      v_max_delivered
        from   hr_s_balance_categories_f;

        select max(BALANCE_CATEGORY_ID)
        into   v_max_live
        from   pay_balance_categories_f;

        select pay_balance_categories_s.nextval
        into   v_sequence_number
        from   dual;

        IF (v_sequence_number BETWEEN v_min_delivered AND v_max_delivered)
           OR (v_sequence_number < v_max_live) THEN

           IF v_max_live > v_max_delivered THEN

             hr_legislation.munge_sequence('PAY_BALANCE_CATEGORIES_S',
                                           v_sequence_number,
                                           v_max_live);
           ELSE

             hr_legislation.munge_sequence('PAY_BALANCE_CATEGORIES_S',
                                           v_sequence_number,
                                           v_max_delivered);
           END IF;
        END IF;

    END check_next_sequence;

    PROCEDURE crt_exc (exception_type IN varchar2)
    ----------------------------------------------
    IS
    BEGIN

        -- When the installation procedures encounter an error that cannot
        -- be handled, an exception is raised and all work is rolled back
        -- to the last savepoint. The installation process then continues
        -- with the next primary key to install. The same exception will
        -- not be raised more than once.

        rollback to new_category_name;

        insert_hr_stu_exceptions('pay_balance_categories_f'
        ,      r_distinct.c_surrogate_key
        ,      exception_type
        ,      r_distinct.c_true_key);

    END crt_exc;

    PROCEDURE remove (v_id IN number)
    ---------------------------------
    IS
        -- subprogram to delete a row from the delivery tables, and all child
        -- application ownership rows

    BEGIN

        delete from hr_s_balance_categories_f
        where  BALANCE_CATEGORY_ID = v_id;

    END remove;

    PROCEDURE update_uid
    --------------------
    IS

    BEGIN

        BEGIN

            select distinct BALANCE_CATEGORY_ID
            into   l_new_balance_category_id
            from   pay_balance_categories_f
            where  category_name = r_distinct.c_true_key
            and    business_Group_id is null
            and    nvl(legislation_code, 'x') = nvl(r_distinct.legislation_code,'x');

        EXCEPTION WHEN NO_DATA_FOUND THEN

            select pay_balance_categories_s.nextval
            into   l_new_balance_category_id
            from   dual;
        --
        WHEN TOO_MANY_ROWS THEN

            crt_exc('Non unique balance category ID for category name ' ||
                    r_distinct.c_true_key);
        --
        END;

        update hr_s_balance_categories_f
        set    balance_category_id = l_new_balance_category_id
        where  balance_category_id = r_distinct.c_surrogate_key;

        update hr_s_balance_types
        set    balance_category_id = l_new_balance_category_id
        where  balance_category_id = r_distinct.c_surrogate_key;

    END update_uid;

    FUNCTION check_parents RETURN BOOLEAN
    -------------------------------------
    IS

    BEGIN

      return TRUE;

    END check_parents;

    FUNCTION valid_ownership RETURN BOOLEAN
    ---------------------------------------
    IS
        -- Test ownership of this current row
    BEGIN

        BEGIN

            select distinct null
            into   l_null_return
            from   pay_balance_categories_f a
            where  a.category_name = r_distinct.c_true_key
            and   a.business_group_id is not null
            and   exists (select null from per_business_groups b
              where b.business_group_id = a.business_group_id
              and b.legislation_code = nvl(r_distinct.legislation_code,b.legislation_code));

            crt_exc('Row already created in a business group');

            return FALSE;       -- Indicates this row is not to be transferred

        EXCEPTION WHEN NO_DATA_FOUND THEN
            null;

        END;

        -- Now perform a check to see if this primary key has been installed
        -- with a legislation code that would make it visible at the same time
        -- as this row. Ie: if any legislation code is null within the set of
        -- returned rows, then the transfer may not go ahead. If no rows are
        -- returned then the delivered row is fine.

        BEGIN
            --
            select distinct null
            into   l_null_return
            from   pay_balance_categories_f
            where  category_name = r_distinct.c_true_key
            and    nvl(legislation_code,'x') <>
                                       nvl(r_distinct.legislation_code,'x')
            and   (legislation_code is null
                    or r_distinct.legislation_code is null);

            crt_exc('Row already created for a visible legislation');
            return FALSE;

        EXCEPTION WHEN NO_DATA_FOUND THEN
            null;

        END;

        IF p_phase <> 1 THEN return TRUE; END IF;

        return TRUE;            -- Indicates row is required

    EXCEPTION WHEN NO_DATA_FOUND THEN

        remove(r_distinct.c_surrogate_key);

        return FALSE;           -- Indicates row not needed

    END valid_ownership;

BEGIN
    -- Two loops are used here. The main loop which select distinct primary
    -- key rows and an inner loop which selects all date effective rows for the
    -- primary key. The inner loop is only required in phase two, since only
    IF p_phase = 1 THEN check_next_sequence; END IF;

    FOR category_names IN c_distinct LOOP

        savepoint new_category_name;
        r_distinct := category_names;

        BEGIN

            IF valid_ownership THEN
                -- This row is wanted
                IF p_phase = 1 THEN
                    -- Get new surrogate id and update child references
                    update_uid;
                ELSE
                    -- Phase = 2
                    delete from pay_balance_categories_f
                    where  balance_category_id = r_distinct.c_surrogate_key;

                    FOR each_row IN c_each_row(r_distinct.c_surrogate_key) LOOP
                        r_each_row := each_row;

                        IF NOT check_parents THEN RAISE row_in_error; END IF;

                        BEGIN
                        insert into pay_balance_categories_f
                        ( BALANCE_CATEGORY_ID
                          ,CATEGORY_NAME
                          ,EFFECTIVE_START_DATE
                          ,EFFECTIVE_END_DATE
                          ,LEGISLATION_CODE
                          ,BUSINESS_GROUP_ID
                          ,SAVE_RUN_BALANCE_ENABLED
                          ,PBC_INFORMATION_CATEGORY
                          ,PBC_INFORMATION1
                          ,PBC_INFORMATION2
                          ,PBC_INFORMATION3
                          ,PBC_INFORMATION4
                          ,PBC_INFORMATION5
                          ,PBC_INFORMATION6
                          ,PBC_INFORMATION7
                          ,PBC_INFORMATION8
                          ,PBC_INFORMATION9
                          ,PBC_INFORMATION10
                          ,PBC_INFORMATION11
                          ,PBC_INFORMATION12
                          ,PBC_INFORMATION13
                          ,PBC_INFORMATION14
                          ,PBC_INFORMATION15
                          ,PBC_INFORMATION16
                          ,PBC_INFORMATION17
                          ,PBC_INFORMATION18
                          ,PBC_INFORMATION19
                          ,PBC_INFORMATION20
                          ,PBC_INFORMATION21
                          ,PBC_INFORMATION22
                          ,PBC_INFORMATION23
                          ,PBC_INFORMATION24
                          ,PBC_INFORMATION25
                          ,PBC_INFORMATION26
                          ,PBC_INFORMATION27
                          ,PBC_INFORMATION28
                          ,PBC_INFORMATION29
                          ,PBC_INFORMATION30
                          ,LAST_UPDATE_DATE
                          ,LAST_UPDATED_BY
                          ,LAST_UPDATE_LOGIN
                          ,CREATED_BY
                          ,CREATION_DATE
                          ,OBJECT_VERSION_NUMBER
                          ,USER_CATEGORY_NAME)
                        values
                        (each_row.BALANCE_CATEGORY_ID
                        ,each_row.CATEGORY_NAME
                        ,each_row.EFFECTIVE_START_DATE
                        ,each_row.EFFECTIVE_END_DATE
                        ,each_row.LEGISLATION_CODE
                        ,each_row.BUSINESS_GROUP_ID
                        ,each_row.SAVE_RUN_BALANCE_ENABLED
                        ,each_row.PBC_INFORMATION_CATEGORY
                        ,each_row.PBC_INFORMATION1
                        ,each_row.PBC_INFORMATION2
                        ,each_row.PBC_INFORMATION3
                        ,each_row.PBC_INFORMATION4
                        ,each_row.PBC_INFORMATION5
                        ,each_row.PBC_INFORMATION6
                        ,each_row.PBC_INFORMATION7
                        ,each_row.PBC_INFORMATION8
                        ,each_row.PBC_INFORMATION9
                        ,each_row.PBC_INFORMATION10
                        ,each_row.PBC_INFORMATION11
                        ,each_row.PBC_INFORMATION12
                        ,each_row.PBC_INFORMATION13
                        ,each_row.PBC_INFORMATION14
                        ,each_row.PBC_INFORMATION15
                        ,each_row.PBC_INFORMATION16
                        ,each_row.PBC_INFORMATION17
                        ,each_row.PBC_INFORMATION18
                        ,each_row.PBC_INFORMATION19
                        ,each_row.PBC_INFORMATION20
                        ,each_row.PBC_INFORMATION21
                        ,each_row.PBC_INFORMATION22
                        ,each_row.PBC_INFORMATION23
                        ,each_row.PBC_INFORMATION24
                        ,each_row.PBC_INFORMATION25
                        ,each_row.PBC_INFORMATION26
                        ,each_row.PBC_INFORMATION27
                        ,each_row.PBC_INFORMATION28
                        ,each_row.PBC_INFORMATION29
                        ,each_row.PBC_INFORMATION30
                        ,each_row.LAST_UPDATE_DATE
                        ,each_row.LAST_UPDATED_BY
                        ,each_row.LAST_UPDATE_LOGIN
                        ,each_row.CREATED_BY
                        ,each_row.CREATION_DATE
                        ,each_row.OBJECT_VERSION_NUMBER
                        ,nvl(each_row.USER_CATEGORY_NAME,
                             each_row.CATEGORY_NAME));
                      EXCEPTION WHEN OTHERS THEN
                        hrrunprc_trace_on;
                        hr_utility.trace('ins pay_balance_categories');
                        hr_utility.trace('cat id: ' ||
                          to_char(each_row.BALANCE_CATEGORY_ID));
                        hr_utility.trace('cat name  ' ||
                          each_row.CATEGORY_NAME);
                        hr_utility.trace(':lc:bg: ' || ':' ||
                          each_row.LEGISLATION_CODE || ':' ||
                          to_char(each_row.BUSINESS_GROUP_ID) || ':');
                        hrrunprc_trace_off;
                        raise;
                      END;

                      END LOOP each_row;

                      remove(r_distinct.c_surrogate_key);

                     END IF;                 -- End phase checking

                    END IF; --(valid ownership test)

                EXCEPTION WHEN row_in_error THEN
                    rollback to new_category_name;

                END;

            END LOOP category_names;

END install_bal_categories;

--****************************************************************************
-- INSTALLATION PROCEDURE FOR : PAY_BALANCE_TYPES
--****************************************************************************

PROCEDURE install_bal_types (p_phase IN number)
-----------------------------------------------
IS

    -- Install procedure to insert required balance types/defined balances
    -- and balance classifications.

    -- The child rows of defined balances and classifications, are only
    -- installed if the balance type itself has changed.

    -- To protect integrity, the defined_balance_id must be derived from the
    -- live table. Therfore the values of balance_type_id and dimension_id
    -- must be relied upon as a true composite key. This is not desirable as
    -- this key is composed of two surrogate keys. If the balance type is to
    -- be installed, then a test will be performed and only those defined
    -- balances not already installed will be inserted. This logic is used
    -- since the only not null columns on defined balances are the two
    -- foreign keys that comprise the true key.

    l_null_return varchar2(1); 		-- For 'select null' statements
    l_new_surrogate_key number(15); 	-- New surrogate key for the delivery row
    l_bal_class_id pay_balance_classifications.balance_classification_id%type;

    CURSOR stu				-- Selects all rows from startup entity
    IS

	select balance_name c_true_key
	,      balance_type_id c_surrogate_key
	,      legislation_code c_leg_code
	,      legislation_subgroup c_leg_sgrp
	,      assignment_remuneration_flag
	,      currency_code
	,      balance_uom
	,      reporting_name
	,      jurisdiction_level
        ,      tax_type
	,      last_update_date
	,      last_updated_by
	,      last_update_login
	,      created_by
	,      creation_date
        ,      input_value_id
        ,      base_balance_type_id
        ,      balance_category_id
	,      rowid
        ,      new_balance_type_flag
	from   hr_s_balance_types;

    CURSOR class (bal_type_id number)
    IS
	-- Cursor for installation of classification rules
        -- ADDED DISTINCT so that ldts that contains same bal_class
        -- for same legislation wont trigger PK error
	select distinct *
	from   hr_s_balance_classifications hsbc
	where  balance_type_id = bal_type_id
        and not exists
          ( select 1
            from  pay_balance_classifications pbc
            where nvl(hsbc.business_group_id, -1) = nvl(pbc.business_group_id, -1)
            and   hsbc.legislation_code     = pbc.legislation_code
            and   hsbc.balance_type_id      = pbc.balance_type_id
            and   hsbc.classification_id    = pbc.classification_id
            and   hsbc.scale                = pbc.scale
            and   nvl(hsbc.legislation_subgroup, 'X') = nvl(pbc.legislation_subgroup, 'X'));

    CURSOR defined (bal_type_id number)
    IS
	-- Cursor for installation of child 'defined balances'
        -- ADDED DISTINCT so that ldts that contains same defined
        -- balance for same legislation wont trigger PK error
	select distinct *
	from   hr_s_defined_balances
	where  balance_type_id = bal_type_id;

    CURSOR feed (bal_type_id number)
    IS
	-- Cursor to install child balance feeds
        -- that don't already exist in pay_balance_feeds_f

	select distinct *
   	from   hr_s_balance_feeds_f hrs
   	where  hrs.balance_type_id = bal_type_id
        and not exists (
                select null
                from pay_balance_feeds_f pbf
                where pbf.balance_type_id = hrs.balance_type_id
                and pbf.input_value_id = hrs.input_value_id
                and pbf.effective_start_date = hrs.effective_start_date
                and pbf.effective_end_date = hrs.effective_end_date);

    stu_rec stu%ROWTYPE;			-- Cursor for earlier select


    PROCEDURE check_next_sequence
    -----------------------------
    IS

	v_sequence_number number(15);
	v_min_delivered number(15);
	v_max_delivered number(15);
        v_max_live      number(15);
        cnt             number(15);

	-- Surrogate id conflicts may arise from two scenario's:
	-- 1. Where the newly select sequence value conflicts with values
	--    in the STU tables.
	-- 2. Where selected surrogate keys, from the installed tables,
	--    conflict with other rows in the STU tables.
	--
	-- Both of the above scenario's are tested for.
	-- The first is a simple match, where if a value is detected in the
	-- STU tables and the installed tables then a conflict is detected. In
	-- This instance all STU surrogate keys, for this table, are updated.
	-- The second is tested for using the sequences.
	-- If the next value from the live sequence is within the range of
	-- delivered surrogate id's then the live sequence must be incremented.
	-- If no action is taken, then duplicates may be introduced into the
	-- delivered tables, and child rows may be totally invalidated.

    BEGIN

	BEGIN	--check that the installed id's will not conflict
		--with the delivered values

            select count(*)
            into cnt
            from hr_s_balance_types;

            If cnt=0 then return; end if;


	    select distinct null
	    into   l_null_return
	    from   pay_balance_types a
	    where  exists
		(select null
		 from   hr_s_balance_types b
		 where  a.balance_type_id = b.balance_type_id
		);

	    --conflict may exist
	    --update all balance_type_id's to remove conflict

	    update /*+NO_INDEX*/ hr_s_BALANCE_CLASSIFICATIONS
	    set    balance_type_id = balance_type_id - 50000000;

            update /*+NO_INDEX*/ hr_s_BALANCE_FEEDS_F
            set    balance_type_id = balance_type_id - 50000000;

            update /*+NO_INDEX*/ hr_s_BALANCE_TYPES
            set    balance_type_id = balance_type_id - 50000000;

            update /*+NO_INDEX*/ hr_s_BALANCE_TYPES
            set    base_balance_type_id = base_balance_type_id - 50000000;

            update /*+NO_INDEX*/ hr_s_DEFINED_BALANCES
            set    balance_type_id = balance_type_id - 50000000;

	    update hr_s_application_ownerships
	    set    key_value = key_value - 50000000
	    where  key_name = 'BALANCE_TYPE_ID';

	EXCEPTION WHEN NO_DATA_FOUND THEN NULL;

	END; --check of balance_type_id


	BEGIN	--check that the installed defined balance id's will
		--not conflict with the delivered values

            select count(*)
            into cnt
            from hr_s_defined_balances;

            If cnt=0 then return; end if;


	    select distinct null
	    into   l_null_return
	    from   pay_defined_balances a
	    where  exists
		(select null
		 from   hr_s_defined_balances b
		 where  a.defined_balance_id = b.defined_balance_id
		);

	    --conflict may exist
	    --update all balance_type_id's to remove conflict

	    update /*+NO_INDEX*/ hr_s_DEFINED_BALANCES
	    set    defined_balance_id = defined_balance_id - 50000000;

	EXCEPTION WHEN NO_DATA_FOUND THEN NULL;

	END; --check of balance_type_id

	select min(balance_type_id) - (count(*) *3)
	,      max(balance_type_id) + (count(*) *3)
	into   v_min_delivered
	,      v_max_delivered
	from   hr_s_balance_types;

        select max(balance_type_id)
        into   v_max_live
        from   pay_balance_types;

	select pay_balance_types_s.nextval
	into   v_sequence_number
	from   dual;

	IF (v_sequence_number BETWEEN v_min_delivered AND v_max_delivered)
           OR (v_sequence_number < v_max_live) THEN

           IF v_max_live > v_max_delivered THEN

             hr_legislation.munge_sequence('PAY_BALANCE_TYPES_S',
                                           v_sequence_number,
                                           v_max_live);
           ELSE

             hr_legislation.munge_sequence('PAY_BALANCE_TYPES_S',
                                           v_sequence_number,
                                           v_max_delivered);
           END IF;
        END IF;


        select min(defined_balance_id) - (count(*) *3)
        ,      max(defined_balance_id) +(count(*) *3)
        into   v_min_delivered
        ,      v_max_delivered
        from   hr_s_defined_balances;

        select pay_defined_balances_s.nextval
        into   v_sequence_number
        from   dual;

        IF v_sequence_number BETWEEN v_min_delivered AND v_max_delivered THEN

             hr_legislation.munge_sequence('PAY_DEFINED_BALANCES_S',
                                           v_sequence_number,
                                           v_max_delivered);

        END IF;

    END check_next_sequence;


    PROCEDURE crt_exc (exception_type IN varchar2)
    ----------------------------------------------
    IS
	-- Reports any exceptions during the delivery of startup data to
	-- PER_ASSIGNMENT_STATUS_TYPES. See crt_exc in procedure install_past
	-- for further, generic operational details.

    BEGIN

	rollback to new_balance_name;
        insert_hr_stu_exceptions('pay_balance_types'
            ,      stu_rec.c_surrogate_key
            ,      exception_type
            ,      stu_rec.c_true_key);

    END crt_exc;

    PROCEDURE update_uid
    --------------------
    IS
	v_new_def_bal_id number(15);
        v_new_balance_type_flag varchar2 (1);

    BEGIN

	BEGIN

	    select distinct balance_type_id
	    into   l_new_surrogate_key
	    from   pay_balance_types
            where  replace(ltrim(rtrim(upper(balance_name))), ' ', '_') =
                   replace(ltrim(rtrim(upper(stu_rec.c_true_key))), ' ', '_')
	    and    business_group_id is null
            and (  (legislation_code is null and stu_rec.c_leg_code is null)
                or (legislation_code = stu_rec.c_leg_code) );

            v_new_balance_type_flag := 'N';

	EXCEPTION WHEN NO_DATA_FOUND THEN


	    select pay_balance_types_s.nextval
	    into   l_new_surrogate_key
	    from   dual;

            v_new_balance_type_flag := 'Y';

                  WHEN TOO_MANY_ROWS THEN
                        hrrunprc_trace_on;
                        hr_utility.trace('sel pay_balance_types TMR');
                        hr_utility.trace('balance_name  ' ||
                          stu_rec.c_true_key);
                        hr_utility.trace(':lc: ' || ':' ||
                          stu_rec.c_leg_code || ':');
                        hrrunprc_trace_off;
                        raise;
	END;

	-- Update all child entities

	update hr_s_balance_types
	set    balance_type_id = l_new_surrogate_key
	where  balance_type_id = stu_rec.c_surrogate_key;

        update hr_s_balance_types
        set    base_balance_type_id = l_new_surrogate_key,
               new_balance_type_flag = v_new_balance_type_flag
        where  base_balance_type_id = stu_rec.c_surrogate_key;

	update hr_s_application_ownerships
	set    key_value = to_char(l_new_surrogate_key)
	where  key_value = to_char(stu_rec.c_surrogate_key)
	and    key_name = 'BALANCE_TYPE_ID';

	update hr_s_balance_classifications
	set    balance_type_id = l_new_surrogate_key
	where  balance_type_id = stu_rec.c_surrogate_key;

	update hr_s_balance_feeds_f
	set    balance_type_id = l_new_surrogate_key,
               new_balance_type_flag = v_new_balance_type_flag
	where  balance_type_id = stu_rec.c_surrogate_key;

	-- Select the currently installed defined balance id, using
	-- the by now updated balance_dimension_id and the new balance_type_id.
	-- The balance_type_id will find its way onto the defined_balance row
	-- when the row is updated with a new surrogate key.

	FOR def_bals IN defined(stu_rec.c_surrogate_key) LOOP

	    BEGIN

		select defined_balance_id
		into   v_new_def_bal_id
		from   pay_defined_balances
		where  balance_type_id = l_new_surrogate_key
		and    balance_dimension_id = def_bals.balance_dimension_id
                and    business_group_id is null
                and (  (legislation_code is null and def_bals.legislation_code is null)
                    or (legislation_code = def_bals.legislation_code) );

	    EXCEPTION WHEN NO_DATA_FOUND THEN

		select pay_defined_balances_s.nextval
		into   v_new_def_bal_id
		from   dual;

                      WHEN TOO_MANY_ROWS THEN
                        hrrunprc_trace_on;
                        hr_utility.trace('sel pay_defined_balances TMR');
                        hr_utility.trace('balance_type_id  ' ||
                          to_char(l_new_surrogate_key));
                        hr_utility.trace('balance_name  ' ||
                          stu_rec.c_true_key);
                        hr_utility.trace('balance_dimension_id  ' ||
                          to_char(def_bals.balance_dimension_id));
                        hr_utility.trace(':lc: ' || ':' ||
                          def_bals.legislation_code || ':');
                        hrrunprc_trace_off;
                        raise;
	    END;

	    update hr_s_defined_balances
	    set    defined_balance_id = v_new_def_bal_id
            ,      balance_type_id = l_new_surrogate_key
            where  defined_balance_id = def_bals.defined_balance_id
	    and    balance_type_id    = def_bals.balance_type_id;

	END LOOP def_bals;

    END update_uid;

    PROCEDURE remove
    ----------------
    IS
	-- Remove a row from either the startup tables or the installed tables

    BEGIN


	delete from hr_s_balance_classifications
	where  balance_type_id = stu_Rec.c_surrogate_key;


	delete from hr_s_defined_balances
	where  balance_type_id = stu_Rec.c_surrogate_key;


	delete from hr_s_balance_feeds_f
	where  balance_type_id = stu_Rec.c_surrogate_key;

	delete from hr_s_balance_types
	where  rowid = stu_rec.rowid;


    END remove;

    FUNCTION valid_ownership RETURN BOOLEAN
    ---------------------------------------
    IS
	-- Test ownership of this current row

    BEGIN


	IF p_phase <> 1 THEN return TRUE; END IF;


	-- Cause an exception to be raised if this row is not needed

        if (stu_rec.c_leg_sgrp is null) then
        select null
        into   l_null_return
        from   dual
        where  exists
               (select null
        from   hr_s_application_ownerships a
        ,      fnd_product_installations b
        ,      fnd_application c
        where  a.key_name = 'BALANCE_TYPE_ID'
        and    a.key_value = stu_rec.c_surrogate_key
        and    a.product_name = c.application_short_name
        and    c.application_id = b.application_id
        and    ((b.status = 'I' and c.application_short_name <> 'PQP')
                or
                (b.status in ('I', 'S') and c.application_short_name = 'PQP')));
        else
	select null
	into   l_null_return
	from   dual
	where  exists
	       (select null
	from   hr_s_application_ownerships a
	,      fnd_product_installations b
	,      fnd_application c
	where  a.key_name = 'BALANCE_TYPE_ID'
	and    a.key_value = stu_rec.c_surrogate_key
	and    a.product_name = c.application_short_name
	and    c.application_id = b.application_id
        and    ((b.status = 'I' and c.application_short_name <> 'PQP')
                or
                (b.status in ('I', 'S') and c.application_short_name = 'PQP')))
	and    exists (
	       select null
	       from hr_legislation_subgroups d
               where d.legislation_code = stu_rec.c_leg_code
               and d.legislation_subgroup = stu_rec.c_leg_sgrp
               and d.active_inactive_flag = 'A' );
        end if;

	return TRUE;		-- Row is required

    EXCEPTION WHEN NO_DATA_FOUND THEN

	-- Row not needed for any installed product

	remove; --+++

	return FALSE;		-- Row not needed

    END valid_ownership;


    PROCEDURE transfer_row
    ----------------------
    IS

    v_payroll_install_status varchar2(10);
    l_initbfid number;

    CURSOR balance_clash
    IS
        -- Cursor to fetch balances with same name

        select /*+ INDEX_FFS(pb) */ business_group_id
        from   pay_balance_types pb
        where  business_group_id is not null
        and    replace(ltrim(rtrim(upper(balance_name))), ' ', '_') =
               replace(ltrim(rtrim(upper(stu_rec.c_true_key))), ' ', '_');

	-- See procedure transfer_row in procedure install_past above for
	--generic comments.

    BEGIN


	-- See if payroll is installed or not. This is in order to
	-- determine whether child feeds and classifications need to be
	-- installed.

	select status
	into   v_payroll_install_status
	from   fnd_product_installations
	where  application_id = 801;

        --
        -- Following checks only need to be made if the balance type
        -- is a new one and hence doesn't exist yet.
        -- If it does already exist theres no point looking for potential
        -- clashes with existing data!
        --
        if stu_rec.new_balance_type_flag = 'Y' then

           if stu_rec.c_leg_code is null then

	   BEGIN

	       select distinct null
	       into   l_null_return
	       from   pay_balance_types a
	       where  a.business_group_id is not null
               and    replace(ltrim(rtrim(upper(a.balance_name))), ' ', '_') =
                      replace(ltrim(rtrim(upper(stu_rec.c_true_key))), ' ', '_');

               crt_exc('Row already created in a business group');

	       return; --indicates this row is not to be transferred +++

	   EXCEPTION WHEN NO_DATA_FOUND THEN

	       null;

	   END;

           else

               for bals in balance_clash loop

	       BEGIN

                   select distinct null
                   into   l_null_return
                   from   per_business_groups pbg
                   where  pbg.business_group_id = bals.business_group_id
                   and    pbg.legislation_code = stu_rec.c_leg_code;

                   crt_exc('Row already created in a business group');

	           return; --indicates this row is not to be transferred +++

    	       EXCEPTION WHEN NO_DATA_FOUND THEN

	           null;

	       END;

               end loop;

           end if;

	   -- Now perform a check to see if this primary key has been installed
	   -- with a legislation code that would make it visible at the same time
	   -- as this row. Ie: if any legislation code is null within the set of
	   -- returned rows, then the transfer may not go ahead. If no rows are
	   -- returned then the delivered row is fine.

	   BEGIN
	       select distinct null
	       into   l_null_return
	       from   pay_balance_types
	       where  balance_name = stu_rec.c_true_key
	       and    nvl(legislation_code,'x') <> nvl(stu_rec.c_leg_code,'x')
	       and    (legislation_code is null or stu_rec.c_leg_code is null)
               and    business_group_id is null;

	       crt_exc('Row already created for a visible legislation');

	       return; --indicates this row is not to be transferred

	   EXCEPTION WHEN NO_DATA_FOUND THEN
	       null;

	   END;

        end if;

	-- After the above two checks, no contention exists with the same
	-- true primary key. Now compare the row details. If the rows are
	-- identical the delivered row will be deleted.

	-- The child rows will be deleted in the 'remove' function.

	-- If the balance type is to be installed, check the child
	-- defined balances. These children should be removed from the delivery
	-- tables if they match the installed rows. This check is performed in
	-- the exception handler, since this is where the installation of the
	-- balance type is first identified.
	--
	-- #331831. Add NVLs wherever values may be null, to prevent flagging
	-- rows which are identical but have some null values as different.
	--
	-- See comments in transfer_row procedure within install_past
	-- procedure.


	IF p_phase = 1 THEN return; END IF;

        IF stu_rec.balance_category_id IS NOT NULL THEN
        BEGIN
          select distinct null
          into   l_null_return
          from   pay_balance_categories_f
          where  balance_category_id = stu_rec.balance_category_id;

         EXCEPTION WHEN NO_DATA_FOUND THEN
           crt_exc('Parent balance category does not exist');
           return;
         END;
        END IF;

	update pay_balance_types
	set    business_group_id = null
	,      legislation_code = stu_rec.c_leg_code
	,      legislation_subgroup = stu_rec.c_leg_sgrp
	,      assignment_remuneration_flag=stu_rec.assignment_remuneration_flag
	,      currency_code = stu_rec.currency_code
	,      balance_uom = stu_rec.balance_uom
	,      reporting_name = stu_rec.reporting_name
	,      jurisdiction_level = stu_rec.jurisdiction_level
        ,      tax_type = stu_rec.tax_type
	,      last_update_date = stu_rec.last_update_date
	,      last_updated_by = stu_rec.last_updated_by
	,      last_update_login = stu_rec.last_update_login
	,      created_by = stu_rec.created_by
	,      creation_date = stu_rec.creation_date
        ,      input_value_id = stu_rec.input_value_id
        ,      base_balance_type_id = stu_rec.base_balance_type_id
        ,      balance_category_id = stu_rec.balance_category_id
	where  balance_type_id = stu_rec.c_surrogate_key;

	--+++ Will the code below work or won't there be an exception ??

	IF SQL%NOTFOUND THEN

	    -- No row there to update, must insert

           BEGIN
	    insert into pay_balance_types
	    (balance_name
	    ,balance_type_id
	    ,legislation_code
	    ,legislation_subgroup
	    ,assignment_remuneration_flag
	    ,currency_code
	    ,balance_uom
	    ,reporting_name
	    ,jurisdiction_level
            ,tax_type
	    ,last_update_date
	    ,last_updated_by
	    ,last_update_login
	    ,created_by
	    ,creation_date
            ,input_value_id
            ,base_balance_type_id
            ,balance_category_id )
	    values
	    (stu_rec.c_true_key
	    ,stu_rec.c_surrogate_key
	    ,stu_rec.c_leg_code
	    ,stu_rec.c_leg_sgrp
	    ,stu_rec.assignment_remuneration_flag
	    ,stu_rec.currency_code
	    ,stu_rec.balance_uom
	    ,stu_rec.reporting_name
	    ,stu_rec.jurisdiction_level
            ,stu_rec.tax_type
	    ,stu_rec.last_update_date
	    ,stu_rec.last_updated_by
	    ,stu_rec.last_update_login
	    ,stu_rec.created_by
	    ,stu_rec.creation_date
            ,stu_rec.input_value_id
            ,stu_rec.base_balance_type_id
            ,stu_rec.balance_category_id);
                      EXCEPTION WHEN OTHERS THEN
                        hrrunprc_trace_on;
                        hr_utility.trace('ins pay_balance_types');
                        hr_utility.trace('bal type id: ' ||
                          to_char(stu_rec.c_surrogate_key));
                        hr_utility.trace('bal type name  ' ||
                          stu_rec.c_true_key);
                        hr_utility.trace(':lc: ' || ':' ||
                          stu_rec.c_leg_code || ':');
                        hrrunprc_trace_off;
                        raise;
                      END;

	END IF;

	-- START INSTALL OF CHILD BALANCE_CLASSIFICATIONS

	-- At this stage the balance type is either installed new or updated.
	-- Therefore all balance classifications will be refreshed. The first
	-- stage is to delete those already there, then insert all
	-- classification rows in the delivery tables.
	--

    -- store balance feed currval for latest use - so don't delete any of the
    -- classification feeds created (if don't exist in hr_s)
    select pay_balance_feeds_s.nextval
    into   l_initbfid
    from   dual;

    -- THESE ROWS SHOULD ONLY BE DELIVERED IF PAYROLL IS FULLY INSTALLED.

    IF v_payroll_install_status = 'I' THEN


	delete from pay_balance_classifications pbc
	where  balance_type_id = stu_rec.c_surrogate_key
        and not exists
          ( select 1
            from hr_s_balance_classifications hsbc
            where nvl(hsbc.business_group_id, -1) = nvl(pbc.business_group_id, -1)
            and   hsbc.legislation_code     = pbc.legislation_code
            and   hsbc.balance_type_id      = pbc.balance_type_id
            and   hsbc.classification_id    = pbc.classification_id
            and   hsbc.scale                = pbc.scale
            and   nvl(hsbc.legislation_subgroup, 'X') = nvl(pbc.legislation_subgroup, 'X'));


	-- Install all associated child classification rows.
	-- Test to see if the parent classification exists in the live tables.
	-- If the select raises an exception then the classification does not
	-- exist. Otherwise the row will be inserted.

	FOR bal_classes IN class(stu_rec.c_surrogate_key) LOOP


	    BEGIN
	        select distinct null
	        into   l_null_return
	        from   pay_element_classifications
	        where  classification_id = bal_classes.classification_id;

	    EXCEPTION WHEN NO_DATA_FOUND THEN
	  	crt_exc('Parent element classification does not exist');
	        return;

	    END;

            BEGIN
	    insert into pay_balance_classifications
	    (BALANCE_CLASSIFICATION_ID
	    ,BUSINESS_GROUP_ID
	    ,LEGISLATION_CODE
	    ,BALANCE_TYPE_ID
	    ,CLASSIFICATION_ID
	    ,SCALE
	    ,LEGISLATION_SUBGROUP
	    ,LAST_UPDATE_DATE
	    ,LAST_UPDATED_BY
	    ,LAST_UPDATE_LOGIN
	    ,CREATED_BY
	    ,CREATION_DATE)
	    select pay_balance_classifications_s.nextval
	    ,      bal_classes.business_group_id
	    ,      bal_classes.legislation_code
	    ,      bal_classes.balance_type_id
	    ,      bal_classes.classification_id
	    ,      bal_classes.scale
	    ,      bal_classes.legislation_subgroup
	    ,      bal_classes.last_update_date
	    ,      bal_classes.last_updated_by
	    ,      bal_classes.last_update_login
	    ,      bal_classes.created_by
	    ,      bal_classes.creation_date
	    from dual;
                      EXCEPTION WHEN OTHERS THEN
                        hrrunprc_trace_on;
                        hr_utility.trace('ins pay_balance_class');
                        hr_utility.trace('bal type id  ' ||
                          to_char(bal_classes.balance_type_id));
                        hr_utility.trace('bal type name  ' ||
                          stu_rec.c_true_key);
                        hr_utility.trace('bal class id  ' ||
                          to_char(bal_classes.classification_id));
                        hr_utility.trace('bal class scale  ' ||
                          to_char(bal_classes.scale));
                        hr_utility.trace(':lc: ' || ':' ||
                          bal_classes.legislation_code || ':');
                        hrrunprc_trace_off;
                        raise;
                      END;

        --
        -- need to insert balance feeds to those existing elements that have the
        -- same classification as the balance classification just inserted.
        --
           select pay_balance_classifications_s.currval
           into   l_bal_class_id
           from   dual;
           --
           hr_balance_feeds.ins_bf_bal_class
           (p_balance_type_id           => stu_rec.c_surrogate_key
           ,p_balance_classification_id => l_bal_class_id
           ,p_mode                      => 'STARTUP'
            );

	END LOOP;

    END IF; --end check on payroll installation status


	-- START INSTALL OF CHILD 'DEFINED BALANCES'

	-- Install all associated child 'defined balances' rows.
	-- Test to see if the parent dimension exists in the live tables. If
	-- the select raises an exception then the dimension does not exist.
	-- Otherwise the row will be inserted. At this stage the
	-- defined_balance_id will not exist in the live tables. Consequently
	-- only new defined_balances will remain in the delivery tables.

	FOR def_bals IN defined(stu_rec.c_surrogate_key) LOOP


	    BEGIN
		select distinct null
		into   l_null_return
		from   pay_balance_dimensions
		where  balance_dimension_id = def_bals.balance_dimension_id;

	    EXCEPTION WHEN NO_DATA_FOUND THEN
		crt_exc('Parent balance dimension does not exist');
		return;

	    END;

            update pay_defined_balances
            set BUSINESS_GROUP_ID = null,
                LEGISLATION_CODE = def_bals.LEGISLATION_CODE,
                BALANCE_TYPE_ID = def_bals.BALANCE_TYPE_ID,
                BALANCE_DIMENSION_ID = def_bals.BALANCE_DIMENSION_ID,
                FORCE_LATEST_BALANCE_FLAG = def_bals.FORCE_LATEST_BALANCE_FLAG,
                LEGISLATION_SUBGROUP = def_bals.LEGISLATION_SUBGROUP,
                LAST_UPDATE_DATE = def_bals.LAST_UPDATE_DATE,
                LAST_UPDATED_BY = def_bals.LAST_UPDATED_BY,
                LAST_UPDATE_LOGIN = def_bals.LAST_UPDATE_LOGIN,
                CREATED_BY = def_bals.CREATED_BY,
                CREATION_DATE = def_bals.CREATION_DATE,
                GROSSUP_ALLOWED_FLAG = def_bals.GROSSUP_ALLOWED_FLAG,
                SAVE_RUN_BALANCE = def_bals.SAVE_RUN_BALANCE
            --    RUN_BALANCE_STATUS = def_bals.RUN_BALANCE_STATUS
            where DEFINED_BALANCE_ID = def_bals.defined_balance_id;

            IF SQL%NOTFOUND THEN
              -- doesn't exist so do insert
             BEGIN
	      insert into pay_defined_balances
	      (DEFINED_BALANCE_ID
	      ,BUSINESS_GROUP_ID
	      ,LEGISLATION_CODE
	      ,BALANCE_TYPE_ID
	      ,BALANCE_DIMENSION_ID
	      ,FORCE_LATEST_BALANCE_FLAG
	      ,LEGISLATION_SUBGROUP
	      ,LAST_UPDATE_DATE
	      ,LAST_UPDATED_BY
	      ,LAST_UPDATE_LOGIN
	      ,CREATED_BY
	      ,CREATION_DATE
	      ,GROSSUP_ALLOWED_FLAG
              ,SAVE_RUN_BALANCE
              ,RUN_BALANCE_STATUS)
	      values
	      (def_bals.defined_balance_id
	      ,null
	      ,def_bals.legislation_code
	      ,def_bals.balance_type_id
	      ,def_bals.balance_dimension_id
	      ,def_bals.force_latest_balance_flag
	      ,def_bals.legislation_subgroup
	      ,def_bals.last_update_date
	      ,def_bals.last_updated_by
	      ,def_bals.last_update_login
	      ,def_bals.created_by
	      ,def_bals.creation_date
	      ,def_bals.grossup_allowed_flag
              ,def_bals.save_run_balance
              ,def_bals.run_balance_status);
                      EXCEPTION WHEN OTHERS THEN
                        hrrunprc_trace_on;
                        hr_utility.trace('ins pay_def_bal');
                        hr_utility.trace('def bal id  ' ||
                          to_char(def_bals.defined_balance_id));
                        hr_utility.trace('bal type id  ' ||
                          to_char(def_bals.balance_type_id));
                        hr_utility.trace('bal type name  ' ||
                          stu_rec.c_true_key);
                        hr_utility.trace('bal dim id  ' ||
                          to_char(def_bals.balance_dimension_id));
                        hr_utility.trace('save_run_balance  ' ||
                          def_bals.save_run_balance);
                        hr_utility.trace(':lc: ' || ':' ||
                          def_bals.legislation_code || ':');
                        hrrunprc_trace_off;
                        raise;
                      END;

            END IF;

        END LOOP;


	-- START INSTALL OF CHILD 'BALANCE FEEDS'

    -- THESE FEEDS SHOULD ONLY BE INSTALLED IF THE PAYROLL INSTALL STATUS
    -- IS SET TO 'I'.

    IF v_payroll_install_status = 'I' THEN

	-- Start by deleting balance feeds currently installed

        --
        -- This statement removes any balance feeds from
        -- pay_balance_feeds_f that belong to a balance_type_id
        -- in hr_s_balance_types but do not exist in
        -- hr_s_balance_feeds_f.

        delete from pay_balance_feeds_f pbf
        where pbf.balance_type_id = stu_rec.c_surrogate_key
        and   pbf.business_group_id is null
        and   pbf.legislation_code is not null
        and   pbf.balance_feed_id <= l_initbfid
             and not exists (
                select null
                from hr_s_balance_feeds_f hrs
                where pbf.balance_type_id = hrs.balance_type_id
                and pbf.input_value_id = hrs.input_value_id
                and pbf.effective_start_date = hrs.effective_start_date
                and pbf.effective_end_date = hrs.effective_end_date);

        --
	-- Install all associated child 'balance feed' rows.
	-- Test to see if the parent input vlue exists in the live tables. If
	-- the select raises an exception then the input value does not exist.
	-- Otherwise the row will be inserted.

	FOR bal_feeds IN feed(stu_rec.c_surrogate_key) LOOP


	    BEGIN
	        select distinct null
	        into   l_null_return
	        from   pay_input_values_f
	        where  input_value_id = bal_feeds.input_value_id;

	    EXCEPTION WHEN NO_DATA_FOUND THEN
	        crt_exc('Parent input value does not exist');
	        return;

	    END;

           BEGIN

            if (bal_feeds.new_input_value_flag = 'Y' OR
                bal_feeds.new_balance_type_flag = 'Y') then
               HRASSACT.CHECK_LATEST_BALANCES := FALSE;
            end if;


	    insert into pay_balance_feeds_f
	    (balance_feed_id
	    ,effective_start_date
	    ,effective_end_date
	    ,business_group_id
	    ,legislation_code
	    ,balance_type_id
	    ,input_value_id
	    ,scale
	    ,legislation_subgroup
	    ,last_update_date
	    ,last_updated_by
	    ,last_update_login
	    ,created_by
	    ,creation_date)
	    select pay_balance_feeds_s.nextval
	    ,bal_feeds.effective_start_date
	    ,bal_feeds.effective_end_date
	    ,bal_feeds.business_group_id
	    ,bal_feeds.legislation_code
	    ,bal_feeds.balance_type_id
	    ,bal_feeds.input_value_id
	    ,bal_feeds.scale
	    ,bal_feeds.legislation_subgroup
	    ,bal_feeds.last_update_date
	    ,bal_feeds.last_updated_by
	    ,bal_feeds.last_update_login
	    ,bal_feeds.created_by
	    ,bal_feeds.creation_date
	    from dual;
                     EXCEPTION WHEN OTHERS THEN
                        hrrunprc_trace_on;
                        hr_utility.trace('ins pay_bal_feed');
                        hr_utility.trace('bal type id  ' ||
                          to_char(bal_feeds.balance_type_id));
                        hr_utility.trace('bal type name  ' ||
                          stu_rec.c_true_key);
                        hr_utility.trace('input value id  ' ||
                          to_char(bal_feeds.input_value_id));
                        hr_utility.trace(':lc: ' || ':' ||
                          bal_feeds.legislation_code || ':');
                        hrrunprc_trace_off;
                        raise;
                      END;

            HRASSACT.CHECK_LATEST_BALANCES := TRUE;

	END LOOP;

    END IF; -- end payroll install status check

	remove;
	--+++

    END transfer_row;

BEGIN

    -- This is the main loop to perform the installation logic. A cursor
    -- is opened to control the loop, and each row returned is placed
    -- into a record defined within the main procedure so each sub
    -- procedure has full access to all returrned columns. For each
    -- new row returned, a new savepoint is declared. If at any time
    -- the row is in error a rollback is performed to the savepoint
    -- and the next row is returned. Ownership details are checked and
    -- if the row is required then the surrogate id is updated and the
    -- main transfer logic is called.

    IF p_phase = 1 THEN check_next_sequence; END IF;

    FOR delivered IN stu LOOP

	savepoint new_balance_name;
	stu_rec := delivered;

	IF p_phase = 2 THEN l_new_surrogate_key := stu_rec.c_surrogate_key; END IF;

	-- Test the row onerships for the current row

	IF (p_phase = 2 OR valid_ownership) THEN
	    IF p_phase = 1 THEN update_uid; END IF;
	    transfer_row;
	END IF;

    END LOOP;
    --
--
END install_bal_types;

--****************************************************************************
-- INSTALLATION PROCEDURE FOR : PAY_BALANCE_DIMENSIONS
--****************************************************************************

PROCEDURE install_dimensions (p_phase IN number)
------------------------------------------------
IS
    l_null_return varchar2(1);		-- used for 'select null' statements
    l_new_surrogate_key number(15); 	-- new surrogate key for the delivery row
    l_route_id ff_routes.route_id%type;

    CURSOR stu				-- selects all rows from startup entity
    IS
	select dimension_name c_true_key
	,      balance_dimension_id c_surrogate_key
	,      route_id
	,      legislation_code c_leg_code
	,      legislation_subgroup c_leg_sgrp
	,      database_item_suffix
	,      dimension_type
	,      description
	,      feed_checking_code
	,      feed_checking_type
	,      payments_flag
	,      expiry_checking_code
	,      expiry_checking_level
        ,      dimension_level
        ,      period_type
        ,      asg_action_balance_dim_id
        ,      database_item_function
        ,      save_run_balance_enabled
        ,      start_date_code
	,      rowid
	from   hr_s_balance_dimensions;

    stu_rec stu%ROWTYPE;			-- Record for the above select


    PROCEDURE check_next_sequence
   ------------------------------
    IS

	v_sequence_number number(15);
	v_min_delivered number(15);
	v_max_delivered number(15);
        v_max_live      number(15);
        cnt      number(15);

	-- Surrogate id conflicts may arise from two scenario's:
	-- 1. Where the newly select sequence value conflicts with values
	--    in the STU tables.
	-- 2. Where selected surrogate keys, from the installed tables,
	--    conflict with other rows in the STU tables.
	--
	-- Both of the above scenario's are tested for.
	-- The first is a simple match, where if a value is detected in the
	-- STU tables and the installed tables then a conflict is detected. In
	-- This instance all STU surrogate keys, for this table, are updated.
	-- The second is tested for using the sequences.
	-- If the next value from the live sequence is within the range of
	-- delivered surrogate id's then the live sequence must be incremented.
	-- If no action is taken, then duplicates may be introduced into the
	-- delivered tables, and child rows may be totally invalidated.

    BEGIN


	BEGIN	--check that the installed id's will not conflict
		--with the delivered values


            select count(*)
            into cnt
            from hr_s_balance_dimensions;

            If cnt=0 then return; end if;


	    select distinct null
	    into   l_null_return
	    from   pay_balance_dimensions a
	    where  exists
		(select null
		 from   hr_s_balance_dimensions b
		 where  a.balance_dimension_id = b.balance_dimension_id
		);

	    --conflict may exist
	    --update all balance_dimension_id's to remove conflict

	    update /*+NO_INDEX*/ hr_s_balance_dimensions
	    set    balance_dimension_id = balance_dimension_id - 50000000;

	    update /*+NO_INDEX*/  hr_s_defined_balances
            set    balance_dimension_id = balance_dimension_id - 50000000;

            update /*+NO_INDEX*/ hr_s_balance_dimensions
            set    asg_action_balance_dim_id = asg_action_balance_dim_id
                                                   - 50000000;

            update /*+NO_INDEX*/ hr_s_dimension_routes
            set    balance_dimension_id = balance_dimension_id - 50000000;

            update /*+NO_INDEX*/ hr_s_dimension_routes
            set    run_dimension_id = run_dimension_id - 50000000;

	    update hr_s_application_ownerships
	    set    key_value = key_value - 50000000
	    where  key_name = 'BALANCE_DIMENSION_ID';

	EXCEPTION WHEN NO_DATA_FOUND THEN NULL;

	END; --check of balance_dimension_id



	select min(balance_dimension_id) - (count(*) *3)
	,      max(balance_dimension_id) + (count(*) *3)
	into   v_min_delivered
	,      v_max_delivered
	from   hr_s_balance_dimensions;

        select max(balance_dimension_id)
        into   v_max_live
        from   pay_balance_dimensions;

	select pay_balance_dimensions_s.nextval
	into   v_sequence_number
	from   dual;

	IF (v_sequence_number BETWEEN v_min_delivered AND v_max_delivered)
           OR (v_sequence_number < v_max_live) THEN

           IF v_max_live > v_max_delivered THEN

             hr_legislation.munge_sequence('PAY_BALANCE_DIMENSIONS_S',
                                           v_sequence_number,
                                           v_max_live);
           ELSE

             hr_legislation.munge_sequence('PAY_BALANCE_DIMENSIONS_S',
                                           v_sequence_number,
                                           v_max_delivered);
           END IF;
        END IF;

    END check_next_sequence;

    PROCEDURE crt_exc (exception_type IN varchar2)
    ----------------------------------------------
    IS
	-- Reports any exceptions during the delivery of startup data to
	-- PAY_BALANCE_DIMENSIONS

    BEGIN
	-- See procedure crt_exc in procedure install_past above for generic
	-- details.

	rollback to new_dimension_name;
        insert_hr_stu_exceptions('pay_balance_dimensions'
        ,      stu_rec.c_surrogate_key
        ,      exception_type
        ,      stu_rec.c_true_key);


    END crt_exc;

    PROCEDURE update_uid
    --------------------
    IS
	-- Subprogram to update surrogate UID and all occurrences in child rows

    BEGIN

	BEGIN
	    select distinct balance_dimension_id
	    into   l_new_surrogate_key
	    from   pay_balance_dimensions
	    where  dimension_name = stu_rec.c_true_key
	    and    business_group_id is null
            and (  (legislation_code is null and stu_rec.c_leg_code is null)
		or (legislation_code = stu_rec.c_leg_code) );

	EXCEPTION WHEN NO_DATA_FOUND THEN

	    select pay_balance_dimensions_s.nextval
	    into   l_new_surrogate_key
	    from   dual;

                  WHEN TOO_MANY_ROWS THEN
                        hrrunprc_trace_on;
                        hr_utility.trace('sel pay_balance_dimensions TMR');
                        hr_utility.trace('dimension_name  ' ||
                          stu_rec.c_true_key);
                        hr_utility.trace(':lc: ' || ':' ||
                          stu_rec.c_leg_code || ':');
                        hrrunprc_trace_off;
                        raise;
	END;

	-- Update all child entities


	update hr_s_balance_dimensions
	set    balance_dimension_id = l_new_surrogate_key
	where  balance_dimension_id = stu_rec.c_surrogate_key;

	update hr_s_application_ownerships
	set    key_value = to_char(l_new_surrogate_key)
	where  key_value = to_char(stu_rec.c_surrogate_key)
	and    key_name = 'BALANCE_DIMENSION_ID';

	update hr_s_defined_balances
	set    balance_dimension_id = l_new_surrogate_key
	where  balance_dimension_id = stu_rec.c_surrogate_key;

        update hr_s_dimension_routes
        set    balance_dimension_id = l_new_surrogate_key
        where  balance_dimension_id = stu_rec.c_surrogate_key;

        update hr_s_dimension_routes
        set    run_dimension_id = l_new_surrogate_key
        where  run_dimension_id = stu_rec.c_surrogate_key;

        update hr_s_balance_dimensions
        set    asg_action_balance_dim_id = l_new_surrogate_key
        where  asg_action_balance_dim_id = stu_rec.c_surrogate_key;


    END update_uid;

    PROCEDURE remove
    ----------------
    IS
	--+++ Comment used to say remove from either s/u or installed

    BEGIN

	delete from hr_s_balance_dimensions
	where  rowid = stu_rec.rowid;


    END remove;

    FUNCTION valid_ownership RETURN BOOLEAN
    ---------------------------------------
    IS
	-- Test ownership of this current row
    l_null_return varchar2(1);          -- used for 'select null' statements

    BEGIN
	-- See valid_ownership procedure within install_past above for generic
	-- details of this procedure.


	IF p_phase <> 1 THEN return TRUE; END IF;


	-- Cause an exception to be raised if this row is not needed
        if (stu_rec.c_leg_sgrp is null) then
        select distinct null
        into l_null_return
        from   dual
        where  exists
            (select null
            from   hr_s_application_ownerships a
            ,      fnd_product_installations b
            ,      fnd_application c
            where  a.key_name = 'BALANCE_DIMENSION_ID'
            and    a.key_value = stu_rec.c_surrogate_key
            and    a.product_name = c.application_short_name
            and    c.application_id = b.application_id
            and    ((b.status = 'I' and c.application_short_name <> 'PQP')
                    or
                   (b.status in ('I', 'S') and c.application_short_name = 'PQP')));
        else
        select distinct null
        into l_null_return
        from   dual
        where  exists
            (select null
            from   hr_s_application_ownerships a
            ,      fnd_product_installations b
            ,      fnd_application c
            where  a.key_name = 'BALANCE_DIMENSION_ID'
            and    a.key_value = stu_rec.c_surrogate_key
            and    a.product_name = c.application_short_name
            and    c.application_id = b.application_id
            and    ((b.status = 'I' and c.application_short_name <> 'PQP')
                    or
                   (b.status in ('I', 'S') and c.application_short_name = 'PQP')))
        and   exists (
                   select null
                   from hr_legislation_subgroups d
                   where d.legislation_code = stu_rec.c_leg_code
                   and d.legislation_subgroup = stu_rec.c_leg_sgrp
                   and d.active_inactive_flag = 'A' );
        end if;

        --
	return TRUE;		-- Row is required

	EXCEPTION WHEN NO_DATA_FOUND THEN

	    -- Row not needed for any installed product

	    remove;
	    return FALSE;	-- Row not needed

	END valid_ownership;

    FUNCTION check_parents RETURN BOOLEAN
    -------------------------------------
    IS
	-- Check if parent data is correct

    BEGIN

	-- This procedure is only called in phase 2. The logic to check if
	-- a given parental foriegn key exists is split into two parts for
	-- every foriegn key. The first select from the delivery tables.

	-- If a row is founnd then the installation of the parent must have
	-- failed, and this installation must not go ahead. If no data is
	-- found, ie: an exception is raised, the installation is valid.

	-- The second check looks for a row in the live tables. If no rows
	-- are returned then this installation is invalid, since this means
	-- that the parent referenced by this row is not present in the
	-- live tables.

	-- The distinct is used in case the parent is date effective and many rows
	-- may be returned by the same parent id.


   	BEGIN

	    -- Start the checking against the first parent table

	    select distinct null
	    into   l_null_return
	    from   hr_s_routes
	    where  route_id = stu_rec.route_id;

	    crt_exc('Parent route remains in delivery tables');

	    return FALSE;		-- Parent row still in startup account

   	EXCEPTION WHEN NO_DATA_FOUND THEN
	    null;

	END;


	-- Now check the live account

	BEGIN
	    select null
	    into   l_null_return
	    from   ff_routes
	    where  route_id = stu_rec.route_id;

	    return TRUE;

	EXCEPTION WHEN NO_DATA_FOUND THEN

	   crt_exc('Parent route not installed in live tables');

	   return FALSE;

   	END;

    END check_parents;

    PROCEDURE transfer_row
    ----------------------
    IS

	-- See procedure transfer_row in procedure install_past above for generic
	-- comments.

	v_inst_update date;  		-- Hold update details of installed row
        form_count number;
        --
        cursor c_get_baldim is
            select distinct null
            from pay_balance_dimensions a
            where a.dimension_name = stu_rec.c_true_key
            and   a.business_group_id is not null
            and   exists (select null from per_business_groups b
              where b.business_group_id = a.business_group_id
              and b.legislation_code = nvl(stu_rec.c_leg_code,b.legislation_code));

        cursor c_get_baldim_null is
            select distinct null
            from   pay_balance_dimensions
            where  dimension_name = stu_rec.c_true_key
            and    legislation_code <> stu_rec.c_leg_code
            and    (legislation_code is null or stu_rec.c_leg_code is null);
        --
    BEGIN

	BEGIN
	    open c_get_baldim;
	    fetch c_get_baldim into l_null_return;
	       IF c_get_baldim%NOTFOUND OR c_get_baldim%NOTFOUND IS NULL THEN
		  RAISE NO_DATA_FOUND;
                END IF;
            close c_get_baldim;
	    --
	    crt_exc('Row already created in a business group');

	    return;

	EXCEPTION WHEN NO_DATA_FOUND THEN
	    null;

	END;


	-- Now perform a check to see if this primary key has been installed
	-- with a legislation code that would make it visible at the same time
	-- as this row. Ie: if any legislation code is null within the set of
	-- returned rows, then the transfer may not go ahead. If no rows are
	-- returned then the delivered row is fine.

	BEGIN
	    --
	    open c_get_baldim_null;
	    fetch c_get_baldim_null into l_null_return;
	    IF c_get_baldim_null%NOTFOUND OR c_get_baldim_null%NOTFOUND IS NULL THEN
	       RAISE NO_DATA_FOUND;
            END IF;
	    close c_get_baldim_null;
            --
	    crt_exc('Row already created for a visible legislation');
	    return;	 	-- Indicates this row is not to be transferred
            --
	EXCEPTION WHEN NO_DATA_FOUND THEN
	    null;

	END;


	-- After the above two checks, no contention exists with the same
	-- true primary key. Now compare the row details. If the rows are
	-- identical the delivered row will be deleted.

	delete from hr_s_balance_dimensions a
	where  a.balance_dimension_id = stu_rec.c_surrogate_key
	and    exists (
         select 1 from pay_balance_dimensions b
         where  a.ROUTE_ID = b.route_id
         and    a.DATABASE_ITEM_SUFFIX = b.DATABASE_ITEM_SUFFIX
         and    a.DIMENSION_TYPE = b.DIMENSION_TYPE
         and    length(a.FEED_CHECKING_CODE) = length(b.FEED_CHECKING_CODE)
         and    a.FEED_CHECKING_TYPE = b.FEED_CHECKING_TYPE
         and    a.PAYMENTS_FLAG = b.PAYMENTS_FLAG
         and    length(a.EXPIRY_CHECKING_CODE) = length(b.EXPIRY_CHECKING_CODE)
         and    a.EXPIRY_CHECKING_LEVEL = b.EXPIRY_CHECKING_LEVEL
         and    a.DIMENSION_LEVEL = b.DIMENSION_LEVEL
         and    a.PERIOD_TYPE = b.PERIOD_TYPE);

	-- When the procedure is called in phase 1, there is no need to
	-- actually perform the transfer from the delivery tables into the
	-- live. Hence if phase = 1 control is returned to the calling
	-- procedure and the next row is returned.

	IF p_phase = 1 THEN return; END IF;

	-- If the procedure is called in phase 2, then the live row is updated
	-- with the values on the delivered row.

	-- The routine check_parents validates foreign key references and
	-- ensures referential integrity. The routine checks to see if the
	-- parents of a given row have been transfered to the live tables.

	IF NOT check_parents THEN return; END IF;

	-- This may only be called in phase two since in phase one all
	-- parent rows will remain in the delivery tables.

	-- After the above checks only data that has been chanegd or is new
	-- will be left in the delivery tables. At this stage if the row is
	-- already present then it must be updated to ensure referential
	-- integrity. Therefore an update will be performed and if SQL%FOUND
	-- is FALSE an insert will be performed.

	-- The last step of the transfer, in phase 2, is to delete the now
	-- transferred row from the delivery tables.

        -- Delete the user entity for a dimension if its
        -- about to have its route_id changed.  Bug 4328538.

        BEGIN

        select route_id
        into l_route_id
        from pay_balance_dimensions
        where balance_dimension_id = stu_rec.c_surrogate_key;

        EXCEPTION WHEN NO_DATA_FOUND THEN
         l_route_id := stu_rec.route_id;
        END;

        if l_route_id <> stu_rec.route_id then

          delete ff_compiled_info_f
          where formula_id in (
           select fdi.formula_id
           from   ff_fdi_usages_f fdi,
                  ff_user_entities ue,
                  pay_defined_balances db,
                  pay_balance_dimensions bd,
                  ff_database_items di
           where fdi.item_name = di.user_name
           and   ue.creator_type = 'B'
           and   ue.creator_id = db.defined_balance_id
           and   bd.balance_dimension_id = db.balance_dimension_id
           and   bd.balance_dimension_id = stu_rec.c_surrogate_key
           and   di.user_entity_id = ue.user_entity_id);

          delete from ff_fdi_usages_f fdi2
          where fdi2.formula_id in
          (select fdi.formula_id
           from   ff_fdi_usages_f fdi,
                  ff_user_entities ue,
                  pay_defined_balances db,
                  pay_balance_dimensions bd,
                  ff_database_items di
           where fdi.item_name = di.user_name
           and   ue.creator_type = 'B'
           and   ue.creator_id = db.defined_balance_id
           and   bd.balance_dimension_id = db.balance_dimension_id
           and   bd.balance_dimension_id = stu_rec.c_surrogate_key
           and   di.user_entity_id = ue.user_entity_id);

          delete from ff_user_entities
          where creator_type = 'B'
          and creator_id in
              (select defined_balance_id
               from pay_defined_balances pdb
               where pdb.balance_dimension_id = stu_rec.c_surrogate_key);

        end if;

	update pay_balance_dimensions
	set route_id = stu_rec.route_id
	,   database_item_suffix = stu_rec.database_item_suffix
	,   dimension_type = stu_rec.dimension_type
	,   description = stu_rec.description
	,   feed_checking_code = stu_rec.feed_checking_code
	,   feed_checking_type = stu_rec.feed_checking_type
	,   payments_flag = stu_rec.payments_flag
	,   expiry_checking_code = stu_rec.expiry_checking_code
	,   expiry_checking_level = stu_rec.expiry_checking_level
        ,   dimension_level = stu_rec.dimension_level
        ,   period_type = stu_rec.period_type
        ,   asg_action_balance_dim_id = stu_rec.asg_action_balance_dim_id
        ,   database_item_function = stu_rec.database_item_function
        ,   save_run_balance_enabled = stu_rec.save_run_balance_enabled
        ,   start_date_code = stu_rec.start_date_code
	where  balance_dimension_id = stu_rec.c_surrogate_key;

	IF NOT SQL%FOUND THEN
           BEGIN
	    insert into pay_balance_dimensions
	    (dimension_name
	    ,balance_dimension_id
	    ,route_id
	    ,legislation_code
	    ,legislation_subgroup
	    ,database_item_suffix
	    ,dimension_type
	    ,description
	    ,feed_checking_code
	    ,feed_checking_type
	    ,payments_flag
	    ,expiry_checking_code
	    ,expiry_checking_level
            ,dimension_level
            ,period_type
            ,asg_action_balance_dim_id
            ,database_item_function
            ,save_run_balance_enabled
            ,start_date_code
	    )
	    values
	    (stu_rec.c_true_key
	    ,stu_rec.c_surrogate_key
	    ,stu_rec.route_id
	    ,stu_rec.c_leg_code
	    ,stu_rec.c_leg_sgrp
	    ,stu_rec.database_item_suffix
	    ,stu_rec.dimension_type
	    ,stu_rec.description
	    ,stu_rec.feed_checking_code
	    ,stu_rec.feed_checking_type
	    ,stu_rec.payments_flag
	    ,stu_rec.expiry_checking_code
	    ,stu_rec.expiry_checking_level
            ,stu_rec.dimension_level
            ,stu_rec.period_type
            ,stu_rec.asg_action_balance_dim_id
            ,stu_rec.database_item_function
            ,stu_rec.save_run_balance_enabled
            ,stu_rec.start_date_code);
                     EXCEPTION WHEN OTHERS THEN
                        hrrunprc_trace_on;
                        hr_utility.trace('ins pay_bal_dim');
                        hr_utility.trace('bal dim id  ' ||
                          to_char(stu_rec.c_surrogate_key));
                        hr_utility.trace('dimension name  ' ||
                          stu_rec.c_true_key);
                        hr_utility.trace('dbi suffix ' ||
                          stu_rec.database_item_suffix);
                        hr_utility.trace('save_run_balance_enabled  ' ||
                          stu_rec.save_run_balance_enabled);
                        hr_utility.trace(':lc: ' || ':' ||
                          stu_rec.c_leg_code || ':');
                        hrrunprc_trace_off;
                        raise;
                      END;

        END IF;

        remove;

    END transfer_row;

BEGIN

    -- This is the main loop to perform the installation logic. A cursor
    -- is opened to control the loop, and each row returned is placed
    -- into a record defined within the main procedure so each sub
    -- procedure has full access to all returned columns. For each
    -- new row returned, a new savepoint is declared. If at any time
    -- the row is in error a rollback is performed to the savepoint
    -- and the next row is returned. Ownership details are checked and
    -- if the row is required then the surrogate id is updated and the
    -- main transfer logic is called.

    IF p_phase = 1 THEN check_next_sequence; END IF;

    FOR delivered IN stu LOOP

	savepoint new_dimension_name;

	stu_rec := delivered;

	IF p_phase = 2 THEN l_new_surrogate_key := stu_rec.c_surrogate_key; END IF;

	-- Test the row onerships for the current row

	IF valid_ownership THEN
	    IF p_phase = 1 THEN update_uid; END IF;
	    transfer_row;
	END IF;

    END LOOP;

END install_dimensions;

--****************************************************************************
-- INSTALLATION PROCEDURE FOR : PAY_DIMENSION_ROUTES
--****************************************************************************
PROCEDURE install_dimension_routes(p_phase IN number) IS

    l_null_return varchar2(1);       -- used for select null stmts
    l_new_surrogate_key number(15);  -- new surrogate key for the delivery row
    form_count number;

    CURSOR stu                       -- selects all rows from startup entity
    IS
        select BALANCE_DIMENSION_ID
        ,      ROUTE_ID
        ,      ROUTE_TYPE
        ,      PRIORITY
        ,      RUN_DIMENSION_ID
        ,      BALANCE_TYPE_COLUMN
        ,      DECODE_REQUIRED
        ,      rowid
        from   hr_s_dimension_routes;

    stu_rec stu%ROWTYPE;                        -- Record for the above select
    l_route_id ff_routes.route_id%type;
    l_run_dimension_id pay_dimension_routes.run_dimension_id%type;

    PROCEDURE remove IS
    -------------------
    -- Remove a row from either the startup tables or the installed tables
    BEGIN
        delete from hr_s_dimension_routes
        where  rowid = stu_rec.rowid;
    END remove;

    PROCEDURE crt_exc (exception_type IN varchar2)
    ----------------------------------------------
    IS
        -- Reports any exceptions during the delivery of startup data to
        -- PAY_DIMENSION_ROUTES

    BEGIN
        -- See procedure crt_exc in procedure install_past above for generic
        -- details.

        rollback to new_dimension_route;
        insert_hr_stu_exceptions('pay_dimension_routes'
        ,      stu_rec.BALANCE_DIMENSION_ID
        ,      exception_type
        ,      to_char(stu_rec.ROUTE_ID));

    END crt_exc;

    FUNCTION check_parents RETURN BOOLEAN IS
    ----------------------------------------
    -- Check if parent data is correct
    BEGIN

        -- Start the checking bal dim against delivered

        BEGIN

            select distinct null
            into   l_null_return
            from   hr_s_balance_dimensions
            where  balance_dimension_id = stu_rec.balance_dimension_id;

            crt_exc('Parent balance dimension remains in delivery tables');
            return FALSE;         -- Parent row still in startup account

        EXCEPTION WHEN NO_DATA_FOUND THEN
            null;
        END;

        -- Start the checking bal dim against live

        BEGIN

            select distinct null
            into   l_null_return
            from   pay_balance_dimensions
            where  balance_dimension_id = stu_rec.balance_dimension_id;

        EXCEPTION WHEN NO_DATA_FOUND THEN
            remove;
            return FALSE;         -- Parent row still in startup account
        END;

        -- Now check the same for the route id

        BEGIN

            select distinct null
            into   l_null_return
            from   hr_s_routes
            where  route_id = stu_rec.route_id;

            crt_exc('Parent route remains in delivery tables');
            return FALSE;         -- Parent row still in startup account

        EXCEPTION WHEN NO_DATA_FOUND THEN
            null;
        END;

        -- Start the checking bal dim against live

        BEGIN

            select distinct null
            into   l_null_return
            from   ff_routes
            where  route_id = stu_rec.route_id;

        EXCEPTION WHEN NO_DATA_FOUND THEN
            remove;
            return FALSE;         -- Parent row still in startup account
        END;

        return TRUE;

    END check_parents;

    PROCEDURE transfer_row IS
    -------------------------
    BEGIN

        -- First do a parental integrity check
        IF NOT check_parents THEN
          return;
        END IF;

        -- Need to ensure user entity and route parameter value
        -- rebuild in rebuild_ele_input_bal if the dimension route
        -- has changed
        BEGIN

            select route_id, run_dimension_id
            into l_route_id, l_run_dimension_id
            from pay_dimension_routes
            where BALANCE_DIMENSION_ID=stu_rec.BALANCE_DIMENSION_ID
            and   PRIORITY = stu_rec.PRIORITY;

            if (l_route_id <> stu_rec.ROUTE_ID or
                l_run_dimension_id <> stu_rec.RUN_DIMENSION_ID) then

              delete ff_compiled_info_f fci
              where  fci.formula_id in (
                select fdi.formula_id
                from ff_fdi_usages_f fdi
                where  FDI.usage = 'D'
                and exists (select null from
                  ff_database_items dbi
                  where fdi.item_name  = dbi.user_name
                  and exists (select null from
                    ff_user_entities ent
                    where   ent.user_entity_id = dbi.user_entity_id
                    and     ent.creator_type in ('B', 'RB')
                    and     ent.route_id = stu_rec.route_id)));

               delete ff_fdi_usages_f fdi
               where  FDI.usage = 'D'
               and exists (select null from
                ff_database_items dbi
                where fdi.item_name  = dbi.user_name
                and exists (select null from
                  ff_user_entities ent
                  where   ent.user_entity_id = dbi.user_entity_id
                  and     ent.creator_type in ('B', 'RB')
                  and     ent.route_id = stu_rec.route_id));

               delete from ff_user_entities ue
               where creator_type in ('B', 'RB')
               and route_id = stu_rec.ROUTE_ID;
            end if;

        EXCEPTION WHEN NO_DATA_FOUND THEN
            null;
        END;

        -- Delete potentially existing live dimension route
        delete pay_dimension_routes
        where  BALANCE_DIMENSION_ID=stu_rec.BALANCE_DIMENSION_ID
        and    PRIORITY = stu_rec.PRIORITY;

        BEGIN
        insert into pay_dimension_routes
        (BALANCE_DIMENSION_ID
        ,ROUTE_ID
        ,ROUTE_TYPE
        ,PRIORITY
        ,RUN_DIMENSION_ID
        ,BALANCE_TYPE_COLUMN
        ,DECODE_REQUIRED)
        values
        (stu_rec.BALANCE_DIMENSION_ID
        ,stu_rec.ROUTE_ID
        ,stu_rec.ROUTE_TYPE
        ,stu_rec.PRIORITY
        ,stu_rec.RUN_DIMENSION_ID
        ,stu_rec.BALANCE_TYPE_COLUMN
        ,stu_rec.DECODE_REQUIRED);
                     EXCEPTION WHEN OTHERS THEN
                        hrrunprc_trace_on;
                        hr_utility.trace('ins pay dim routes');
                        hr_utility.trace('bal dim id  ' ||
                          to_char(stu_rec.BALANCE_DIMENSION_ID));
                        hr_utility.trace('route id  ' ||
                          to_char(stu_rec.ROUTE_ID));
                        hr_utility.trace('priority ' ||
                          to_char(stu_rec.PRIORITY));
                        hr_utility.trace('route type ' ||
                          stu_rec.ROUTE_TYPE);
                        hrrunprc_trace_off;
                        raise;
                      END;

        remove;

     END transfer_row;

BEGIN
     FOR delivered IN stu LOOP
         savepoint new_dimension_route;
         stu_rec := delivered;
         IF p_phase = 2 THEN transfer_row; END IF;
     END LOOP;

END install_dimension_routes;

--****************************************************************************
-- INSTALLATION PROCEDURE FOR : PER_ORG_INFORMATION_TYPES
--****************************************************************************

PROCEDURE install_org_info (p_phase IN number)
----------------------------------------------
IS
    -- Install procedure to transfer startup element classifications into
    -- a live account.

    l_null_return varchar2(1);          -- For 'select null' statements

    CURSOR stu                          -- Selects all rows from startup entity
    IS
        select org_information_type
        ,      description
        ,      destination
        ,      displayed_org_information_type doit
        ,      legislation_code
        ,      navigation_method
        ,      fnd_application_id
        ,      rowid
        from   hr_s_org_information_types;

    stu_rec stu%ROWTYPE;                        -- Record for above SELECT

    PROCEDURE remove
    ----------------
    IS
        -- Remove row from startup/delivery tables

    BEGIN

        delete from hr_s_org_information_types
        where  rowid = stu_rec.rowid;

        delete from hr_s_org_info_types_by_class
        where  org_information_type = stu_rec.org_information_type;

    END remove;

    PROCEDURE transfer_row
    ----------------------
    IS
        -- Check if a delivered row is needed and insert into the
        -- live tables if it is

    BEGIN

        -- Now comapre the row details. If the rows are identical the delivered row
        -- will be deleted.

        select null
        into   l_null_return
        from   hr_org_information_types
        where  org_information_type = stu_rec.org_information_type
        and    nvl(destination,'X') = nvl(stu_rec.destination,'X')
        and    nvl(displayed_org_information_type,'X') = nvl(stu_rec.doit,'X')
        and    nvl(legislation_code,'X') = nvl(stu_rec.legislation_code,'X')
        and    nvl(navigation_method,'X') = nvl(stu_rec.navigation_method,'X');


        -- The org information row is exactly the same as installed, so now
        -- check the installed types by class. If the next sql statement returns
        -- a row, then the installed info types by class are identical to those
       -- in the delivery tables.

        select null
        into   l_null_return
        from   dual
        where  not exists
               ((select ORG_CLASSIFICATION,
                        ORG_INFORMATION_TYPE,
                        MANDATORY_FLAG,
                        ENABLED_FLAG
                 from   hr_s_org_info_types_by_class
                 where  org_information_type = stu_rec.org_information_type
                 MINUS
                 select ORG_CLASSIFICATION,
                        ORG_INFORMATION_TYPE,
                        MANDATORY_FLAG,
                        ENABLED_FLAG
                 from   hr_org_info_types_by_class
                 where  org_information_type = stu_rec.org_information_type
                )
                 UNION
                (select ORG_CLASSIFICATION,
                        ORG_INFORMATION_TYPE,
                        MANDATORY_FLAG,
                        ENABLED_FLAG
                 from   hr_org_info_types_by_class
                 where  org_information_type = stu_rec.org_information_type
                 MINUS
                 select ORG_CLASSIFICATION,
                        ORG_INFORMATION_TYPE,
                        MANDATORY_FLAG,
                        ENABLED_FLAG
                 from   hr_s_org_info_types_by_class
                 where  org_information_type = stu_rec.org_information_type
               ));

        remove;

        return;

    EXCEPTION WHEN NO_DATA_FOUND THEN

        -- This exception is called when one of the statements above returns no
        -- rows. If this happens then all the org_information row and all child
        -- types_by_class rows will be inserted. No actual data transfer is to
        -- take place in phase 1. The first step is to perform an update
        -- on the info type row. If SQL%NOTFOUND is true then the row needs to be
        -- inserted. After the info type has been inserted/updated, refresh all
        -- child types_by_class rows.

        IF p_phase = 1 THEN return; END IF;


        update hr_org_information_types
        set    destination = stu_rec.destination
        ,      displayed_org_information_type = stu_rec.doit
        ,      legislation_code = stu_rec.legislation_code
        ,      navigation_method = stu_rec.navigation_method
        where  org_information_type = stu_rec.org_information_type;

        IF SQL%NOTFOUND THEN


            insert into hr_org_information_types
            (org_information_type
            ,description
            ,destination
            ,displayed_org_information_type
            ,fnd_application_id
            ,legislation_code
            ,navigation_method
             )
             values
             (stu_rec.org_information_type
             ,stu_rec.description
             ,stu_rec.destination
             ,stu_rec.doit
             ,stu_rec.fnd_application_id
             ,stu_rec.legislation_code
             ,stu_rec.navigation_method
             );

        END IF;


        delete from hr_org_info_types_by_class
        where  org_information_type = stu_rec.org_information_type;


        insert into hr_org_info_types_by_class
        (ORG_CLASSIFICATION
        ,ORG_INFORMATION_TYPE
        ,MANDATORY_FLAG
        ,ENABLED_FLAG
        )
        select org_classification
        ,      org_information_type
        ,      mandatory_flag
        ,      'Y' -- default to Y at least for now
        from   hr_s_org_info_types_by_class
        where  org_information_type = stu_rec.org_information_type;

        remove;

    END transfer_row;

BEGIN

    -- This is the main loop to perform the installation logic. A cursor
    -- is opened to control the loop, and each row returned is placed
    -- into a record defined within the main procedure so each sub
    -- procedure has full access to all returrned columns. For each
    -- new row returned, a new savepoint is declared. If at any time
    -- the row is in error a rollback iss performed to the savepoint
    -- and the next row is returned. Ownership details are checked and
    -- if the row is required then the surrogate id is updated and the
    -- main transfer logic is called.

    FOR delivered IN stu LOOP
        savepoint new_org_information_type;

        -- Make all cursor columns available to all procedures

        stu_rec := delivered;

        transfer_row;

    END LOOP;

END install_org_info;

--****************************************************************************
-- INSTALLATION PROCEDURE FOR : PER_ASSIGNMENT_INFO_TYPES
--****************************************************************************

PROCEDURE install_ass_info (p_phase IN number)
----------------------------------------------
IS
    -- Install procedure to transfer assignment information into a live account.

    l_null_return varchar2(1); 		-- For 'select null' statements
    l_new_surrogate_key number(15);	-- New surrogate key for the delivery row

    CURSOR stu				-- Selects all rows from startup entity
    IS
	select information_type c_true_key
	,      active_inactive_flag
	,      description
	,      legislation_code c_leg_code
	,      request_id
	,      program_application_id
	,      program_id
	,      program_update_date
	,      last_update_date
	,      last_updated_by
	,      last_update_login
	,      created_by
	,      creation_date
	,      rowid
	,      multiple_occurences_flag
	from   hr_s_assignment_info_types;

    stu_rec stu%ROWTYPE;			-- Cursor for earlier select

    PROCEDURE crt_exc (exception_type IN varchar2)
    ----------------------------------------------
    IS
	-- Reports any exceptions during the delivery of startup data to
	-- PER_ASSIGNMENT_INFO_TYPES.

    BEGIN

	-- When the installation procedures encounter an error that cannot
	-- be handled, an exception is raised and all work is rolled back
	-- to the last savepoint. The installation process then continues
	-- with the next primary key to install. The same exception will
	-- not be raised more than once.

	rollback to new_information_type;

        insert_hr_stu_exceptions('per_assignment_info_types'
        ,      0
        ,      exception_type
        ,      stu_rec.c_true_key);


    END crt_exc;

    PROCEDURE remove
    ----------------
    IS
	-- Remove a row from either the startup tables or the installed tables

    BEGIN

	delete from hr_s_assignment_info_types
	where  rowid = stu_rec.rowid;

    END remove;

    PROCEDURE transfer_row
    ----------------------
    IS
	-- Check if a delivered row is needed and insert into the
	-- live tables if it is

    BEGIN

	-- Perform a check to see if this primary key has been installed
	-- with a legislation code that would make it visible at the same time
	-- as this row. Ie: if any legislation code is null within the set of
	-- returned rows, then the transfer may not go ahead. If no rows are
	-- returned then the delivered row is fine.

	BEGIN
	    select distinct null
	    into   l_null_return
	    from   per_assignment_info_types
	    where  information_type = stu_rec.c_true_key
	    and    nvl(legislation_code,'X') <> nvl(stu_rec.c_leg_code,'X')
	    and    (legislation_code is null or stu_rec.c_leg_code is null);

	    crt_exc('Row already created for a visible legislation');

            return; 			-- Row is not to be transferred

	EXCEPTION WHEN NO_DATA_FOUND THEN
	    null;

	END;

	-- See if the assignment information type exists. If so then remove from the
	-- delivery tables, otherwise insert into the live table.


	BEGIN
	    select distinct null
	    into   l_null_return
	    from   per_assignment_info_types
	    where  legislation_code = stu_rec.c_leg_code
	    and    information_type = stu_rec.c_true_key;

	    remove; 		-- The row exists

	    return;

	EXCEPTION WHEN NO_DATA_FOUND THEN

	    IF p_phase = 1 THEN return; END IF;


	    --+++ Has occurences below meant to have 2 rs ?
           BEGIN
	    insert into per_assignment_info_types
	    (information_type
	    ,active_inactive_flag
	    ,description
	    ,legislation_code
	    ,request_id
	    ,program_application_id
	    ,program_id
	    ,program_update_date
	    ,last_update_date
	    ,last_updated_by
	    ,last_update_login
	    ,created_by
	    ,creation_date
	    ,multiple_occurences_flag
	    )
	    values
	    (stu_rec.c_true_key
	    ,stu_rec.active_inactive_flag
	    ,stu_rec.description
	    ,stu_rec.c_leg_code
	    ,stu_rec.request_id
	    ,stu_rec.program_application_id
	    ,stu_rec.program_id
	    ,stu_rec.program_update_date
	    ,stu_rec.last_update_date
	    ,stu_rec.last_updated_by
	    ,stu_rec.last_update_login
	    ,stu_rec.created_by
	    ,stu_rec.creation_date
	    ,stu_rec.multiple_occurences_flag
	    );
                     EXCEPTION WHEN OTHERS THEN
                        hrrunprc_trace_on;
                        hr_utility.trace('ins per_ass_info_type');
                        hr_utility.trace('information_type  ' ||
                          stu_rec.c_true_key);
                        hr_utility.trace(':lc: ' || ':' ||
                          stu_rec.c_leg_code || ':');
                        hrrunprc_trace_off;
                        raise;
                      END;


	   remove;

	END;

    END transfer_row;

BEGIN

    -- This is the main loop to perform the installation logic. A cursor
    -- is opened to control the loop, and each row returned is placed
    -- into a record defined within the main procedure so each sub
    -- procedure has full access to all returned columns. For each
    -- new row returned, a new savepoint is declared. If at any time
    -- the row is in error a rollback is performed to the savepoint
    -- and the next row is returned. Ownership details are checked and
    -- if the row is required then the surrogate id is updated and the
    -- main transfer logic is called.

    FOR delivered IN stu LOOP
	savepoint new_information_type;

	-- Make all cursor columns available to all procedures
	stu_rec := delivered;

	transfer_row;

    END LOOP;

END install_ass_info;

--****************************************************************************
-- INSTALLATION PROCEDURE FOR : PAY_LEGISLATIVE FIELD INFO
--****************************************************************************

    PROCEDURE install_leg_field (phase IN number)
    ---------------------------------------------
    IS
	l_null_return     varchar2(1);	-- used for 'select null' statements

	CURSOR stu			-- Selects all rows from startup entity
	IS
	    select field_name
	    ,      legislation_code
	    ,      prompt
	    ,      validation_name
	    ,      validation_type
	    ,	   target_location
            ,      rule_mode
            ,      rule_type
            ,      PROMPT_MESSAGE
            ,      IN_LINE_MESSAGE
            ,      QUICK_TIP_MESSAGE
            ,      BUBBLE_TIP_MESSAGE
            ,      category
	    ,      rowid
	    from   hr_s_legislative_field_info;

    stu_rec stu%ROWTYPE;			-- Record for the above select

    PROCEDURE remove
    ----------------
    IS
    BEGIN

	delete from hr_s_legislative_field_info
	where  rowid = stu_rec.rowid;

    END remove;

    PROCEDURE transfer_row
    ----------------------
    IS
	-- Check if a delivered row is needed and insert into the
	-- live tables if it is.

	l_prompt    pay_legislative_field_info.prompt%type;
	l_val_type  pay_legislative_field_info.validation_type%type;
        l_rule_mode pay_legislative_field_info.rule_mode%type;
        l_PROMPT_MESSAGE     pay_legislative_field_info.PROMPT_MESSAGE%type;
        l_IN_LINE_MESSAGE    pay_legislative_field_info.IN_LINE_MESSAGE%type;
        l_QUICK_TIP_MESSAGE  pay_legislative_field_info.QUICK_TIP_MESSAGE%type;
        l_BUBBLE_TIP_MESSAGE pay_legislative_field_info.BUBBLE_TIP_MESSAGE%type;
        l_category           pay_legislative_field_info.category%type;
        l_target_location    pay_legislative_field_info.target_location%type;
        l_rowid     rowid;
    BEGIN

       BEGIN
	select prompt
	,      validation_type
        ,      rule_mode
        ,      PROMPT_MESSAGE
        ,      IN_LINE_MESSAGE
        ,      QUICK_TIP_MESSAGE
        ,      BUBBLE_TIP_MESSAGE
        ,      category
        ,      target_location
        ,      rowid
	into   l_prompt
	,      l_val_type
        ,      l_rule_mode
        ,      l_PROMPT_MESSAGE
        ,      l_IN_LINE_MESSAGE
        ,      l_QUICK_TIP_MESSAGE
        ,      l_BUBBLE_TIP_MESSAGE
        ,      l_category
        ,      l_target_location
        ,      l_rowid
	from   pay_legislative_field_info
	where  field_name = stu_rec.field_name
	and    legislation_code = stu_rec.legislation_code
        and    rule_type = stu_rec.rule_type
        and    nvl(target_location,'~') = nvl(stu_rec.target_location,'~')
        and    nvl(validation_name,'~') = nvl(stu_rec.validation_name,'~');
       EXCEPTION WHEN TOO_MANY_ROWS THEN
                        hrrunprc_trace_on;
                        hr_utility.trace('sel pay_legislative_field_info TMR');
                        hr_utility.trace('field_name  ' ||
                          stu_rec.field_name);
                        hr_utility.trace('rule_type  ' ||
                          stu_rec.rule_type);
                        hr_utility.trace('target_location  ' ||
                          stu_rec.target_location);
                        hr_utility.trace('validation_name  ' ||
                          stu_rec.validation_name);
                        hr_utility.trace(':lc: ' || ':' ||
                          stu_rec.legislation_code || ':');
                        hrrunprc_trace_off;
                        raise;
       END;

	IF l_prompt <> stu_rec.prompt
        OR l_val_type <> stu_rec.validation_type
        OR l_rule_mode <> stu_rec.rule_mode
        OR l_PROMPT_MESSAGE <> stu_rec.PROMPT_MESSAGE
        OR l_IN_LINE_MESSAGE <> stu_rec.IN_LINE_MESSAGE
        OR l_QUICK_TIP_MESSAGE <> stu_rec.QUICK_TIP_MESSAGE
        OR l_BUBBLE_TIP_MESSAGE <> stu_rec.BUBBLE_TIP_MESSAGE
        OR l_category <> stu_rec.category
        OR l_target_location <> stu_rec.target_location THEN


	    IF phase = 1 THEN return; END IF;


	    update pay_legislative_field_info
	    set
	           prompt = stu_rec.prompt
	    ,      validation_name    = stu_rec.validation_name
	    ,      validation_type    = stu_rec.validation_type
            ,      target_location    = stu_rec.target_location
            ,      rule_mode          = stu_rec.rule_mode
            ,      PROMPT_MESSAGE     = stu_rec.PROMPT_MESSAGE
            ,      IN_LINE_MESSAGE    = stu_rec.IN_LINE_MESSAGE
            ,      QUICK_TIP_MESSAGE  = stu_rec.QUICK_TIP_MESSAGE
            ,      BUBBLE_TIP_MESSAGE = stu_rec.BUBBLE_TIP_MESSAGE
            ,      CATEGORY           = stu_rec.CATEGORY
            where  rowid = l_rowid;

	END IF;

	remove;

	EXCEPTION WHEN NO_DATA_FOUND THEN

	    -- Row needs to be inserted

	    IF phase = 1 THEN return; END IF;


            BEGIN
	    insert into pay_legislative_field_info
	    (field_name
	    ,legislation_code
	    ,prompt
	    ,validation_name
	    ,validation_type
            ,target_location
            ,rule_mode
            ,rule_type
            ,PROMPT_MESSAGE
            ,IN_LINE_MESSAGE
            ,QUICK_TIP_MESSAGE
            ,BUBBLE_TIP_MESSAGE
            ,CATEGORY
	    )
	    values
	    (stu_rec.field_name
	    ,stu_rec.legislation_code
	    ,stu_rec.prompt
	    ,stu_rec.validation_name
	    ,stu_rec.validation_type
	    ,stu_rec.target_location
            ,stu_rec.rule_mode
            ,stu_rec.rule_type
            ,stu_rec.PROMPT_MESSAGE
            ,stu_rec.IN_LINE_MESSAGE
            ,stu_rec.QUICK_TIP_MESSAGE
            ,stu_rec.BUBBLE_TIP_MESSAGE
            ,stu_rec.CATEGORY
	    );
                      EXCEPTION WHEN OTHERS THEN
                        hrrunprc_trace_on;
                        hr_utility.trace('ins pay_leg_field_info');
                        hr_utility.trace('field_name  ' ||
                          stu_rec.field_name);
                        hr_utility.trace('rule_type  ' ||
                          stu_rec.rule_type);
                        hr_utility.trace('rule_mode  ' ||
                          stu_rec.rule_mode);
                        hr_utility.trace(':lc: ' || ':' ||
                          stu_rec.legislation_code || ':');
                        hrrunprc_trace_off;
                        raise;
                      END;



            -- Delete the row now it has been inserted

	    remove;

	END transfer_row;

BEGIN

    FOR delivered IN stu LOOP
	stu_rec := delivered;
	transfer_row;
    END LOOP;

END install_leg_field;

--****************************************************************************
-- INSTALLATION PROCEDURE FOR : PAY_PAYMENT_TYPES
--****************************************************************************


PROCEDURE install_payment_types (p_phase IN number)
---------------------------------------------------
IS
    l_null_return varchar2(1);	 	-- Used for 'select null' statements
    l_new_surrogate_key number(15); 	-- New surrogate key for the delivery row

    CURSOR stu
    IS
	select payment_type_id c_surrogate_key
	,      territory_code
	,      currency_code
	,      category
	,      payment_type_name c_true_key
	,      allow_as_default
	,      description
	,      pre_validation_required
	,      procedure_name
	,      validation_days
	,      validation_value
	,      last_update_date
	,      last_updated_by
	,      last_update_login
	,      created_by
	,      creation_date
	,      rowid
        ,      reconciliation_function -- Added for bug 8726506
	from   hr_s_payment_types;

    stu_rec stu%ROWTYPE;			-- Record for above SELECT


    PROCEDURE check_next_sequence
    -----------------------------
    IS

	v_sequence_number number(15);
	v_min_delivered number(15);
	v_max_delivered number(15);
        v_max_live      number(15);
        cnt      number(15);

	-- Surrogate id conflicts may arise from two scenario's:
	-- 1. Where the newly select sequence value conflicts with values
	--    in the STU tables.
	-- 2. Where selected surrogate keys, from the installed tables,
	--    conflict with other rows in the STU tables.
	--
	-- Both of the above scenario's are tested for.
	-- The first is a simple match, where if a value is detected in the
	-- STU tables and the installed tables then a conflict is detected. In
	-- This instance all STU surrogate keys, for this table, are updated.
	-- The second is tested for using the sequences.
	-- If the next value from the live sequence is within the range of
	-- delivered surrogate id's then the live sequence must be incremented.
	-- If no action is taken, then duplicates may be introduced into the
	-- delivered tables, and child rows may be totally invalidated.

    BEGIN


	BEGIN	--check that the installed id's will not conflict
		--with the delivered values


            select count(*)
            into cnt
            from hr_s_payment_types;

            If cnt=0 then return; end if;


	    select distinct null
	    into   l_null_return
	    from   pay_payment_types a
	    where  exists
		(select null
		 from   hr_s_payment_types b
		 where  a.payment_type_id = b.payment_type_id
		);

	    --conflict may exist
	    --update all payment_type_id's to remove conflict

	    update /*+NO_INDEX*/  hr_s_payment_types
	    set    payment_type_id = payment_type_id - 50000000;

	    update hr_s_application_ownerships
	    set    key_value = key_value - 50000000
	    where  key_name = 'PAYMENT_TYPE_ID';

	EXCEPTION WHEN NO_DATA_FOUND THEN NULL;

	END; --check of payment_type_id

	select min(payment_type_id) - (count(*) *3)
	,      max(payment_type_id) + (count(*) *3)
	into   v_min_delivered
	,      v_max_delivered
	from   hr_s_payment_types;

        select max(payment_type_id)
        into   v_max_live
        from   pay_payment_types;

	select pay_payment_types_s.nextval
	into   v_sequence_number
	from   dual;

	IF (v_sequence_number BETWEEN v_min_delivered AND v_max_delivered)
           OR (v_sequence_number < v_max_live) THEN

           IF v_max_live > v_max_delivered THEN

             hr_legislation.munge_sequence('PAY_PAYMENT_TYPES_S',
                                           v_sequence_number,
                                           v_max_live);
           ELSE

             hr_legislation.munge_sequence('PAY_PAYMENT_TYPES_S',
                                           v_sequence_number,
                                           v_max_delivered);
           END IF;
        END IF;

    END check_next_sequence;

    PROCEDURE crt_exc (exception_type IN varchar2)
    ----------------------------------------------
    IS

    BEGIN

	-- When the installation procedures encounter an error that cannot
	-- be handled, an exception is raised and all work is rolled back
	-- to the last savepoint. The installation process then continues
	-- with the next primary key to install. The same exception will
	-- not be raised more than once.

	rollback to new_payment_type_name;

        insert_hr_stu_exceptions ('pay_payment_types'
        ,      stu_rec.c_surrogate_key
        ,      exception_type
        ,      stu_rec.c_true_key);


    END crt_exc;

    PROCEDURE update_uid
    --------------------
    IS
	-- Subprogram to update surrogate UID and all occurrences in child rows

    BEGIN

	BEGIN

	    select distinct payment_type_id
	    into   l_new_surrogate_key
	    from   pay_payment_types
	    where  payment_type_name = stu_rec.c_true_key
            and     ((territory_code is NULL and stu_rec.territory_code is NULL)
                      or stu_rec.territory_code= territory_code);


	EXCEPTION WHEN NO_DATA_FOUND THEN

	    select pay_payment_types_s.nextval
	    into   l_new_surrogate_key
	    from   dual;
	END;

	-- Update all child entities


	update hr_s_payment_types
	set    payment_type_id = l_new_surrogate_key
	where  payment_type_id = stu_rec.c_surrogate_key;

	update hr_s_application_ownerships
	set    key_value = to_char(l_new_surrogate_key)
	where  key_value = to_char(stu_rec.c_surrogate_key)
	and    key_name = 'PAYMENT_TYPE_ID';
    END update_uid;

    PROCEDURE remove
    ----------------
    IS
	-- Remove a row from either the startup tables or the installed tables

    BEGIN

	delete from hr_s_payment_types
	where  rowid = stu_rec.rowid;


    END remove;

    PROCEDURE transfer_row
    ----------------------
    IS
	-- Check if a delivered row is needed and insert into the
	-- live tables if it is.
	--
	-- #310520. Change to update the row if it already exists. This
	-- differs from the previous functionality, which only ever did
	-- inserts, and wouldn't handle updates.
	--
    BEGIN
	IF p_phase = 1 THEN
	    return;
	END IF;

	update	pay_payment_types
	set	payment_type_id		= stu_rec.c_surrogate_key
	,	currency_code		= stu_rec.currency_code
	,	category		= stu_rec.category
	,	allow_as_default	= stu_rec.allow_as_default
	,	description		= stu_rec.description
	,	pre_validation_required	= stu_rec.pre_validation_required
	,	procedure_name		= stu_rec.procedure_name
	,	validation_days		= stu_rec.validation_days
	,	validation_value	= stu_rec.validation_value
	,	last_update_date	= stu_rec.last_update_date
	,	last_updated_by		= stu_rec.last_updated_by
	,	last_update_login	= stu_rec.last_update_login
	,	created_by		= stu_rec.created_by
	,	creation_date		= stu_rec.creation_date
	,       reconciliation_function = stu_rec.reconciliation_function
	where	payment_type_name	= stu_rec.c_true_key
        and     ((territory_code is NULL and stu_rec.territory_code is NULL)
                 or stu_rec.territory_code= territory_code);
	IF SQL%NOTFOUND THEN

            -- Row does not exist so insert

            BEGIN
	    insert into pay_payment_types
	    (payment_type_id
	    ,territory_code
	    ,currency_code
	    ,category
	    ,payment_type_name
	    ,allow_as_default
	    ,description
	    ,pre_validation_required
	    ,procedure_name
	    ,validation_days
	    ,validation_value
	    ,last_update_date
	    ,last_updated_by
	    ,last_update_login
	    ,created_by
	    ,creation_date
	    ,reconciliation_function
	    )
	    values
	    (stu_rec.c_surrogate_key
	    ,stu_rec.territory_code
	    ,stu_rec.currency_code
	    ,stu_rec.category
	    ,stu_rec.c_true_key
	    ,stu_rec.allow_as_default
	    ,stu_rec.description
	    ,stu_rec.pre_validation_required
	    ,stu_rec.procedure_name
	    ,stu_rec.validation_days
	    ,stu_rec.validation_value
	    ,stu_rec.last_update_date
	    ,stu_rec.last_updated_by
	    ,stu_rec.last_update_login
	    ,stu_rec.created_by
	    ,stu_rec.creation_date
	    ,stu_rec.reconciliation_function
	    );
                       EXCEPTION WHEN OTHERS THEN
                        hrrunprc_trace_on;
                        hr_utility.trace('ins payment_types');
                        hr_utility.trace('type_id  ' ||
                          to_char(stu_rec.c_surrogate_key));
                        hr_utility.trace('type_name  ' ||
                          stu_rec.c_true_key);
                        hr_utility.trace('currency_code ' ||
                          stu_rec.currency_code);
                        hrrunprc_trace_off;
                        raise;
                      END;

	END IF;
	remove;
    END transfer_row;

BEGIN

    -- This is the main loop to perform the installation logic. A cursor
    -- is opened to control the loop, and each row returned is placed
    -- into a record defined within the main procedure so each sub
    -- procedure has full access to all returned columns. For each
    -- new row returned, a new savepoint is declared. If at any time
    -- the row is in error a rollback is performed to the savepoint
    -- and the next row is returned. Ownership details are checked and
    -- if the row is required then the surrogate id is updated and the
    -- main transfer logic is called.

    IF p_phase = 1 THEN check_next_sequence; END IF;

    FOR delivered IN stu LOOP
	savepoint new_payment_type_name;
	stu_rec := delivered;

	IF p_phase = 2 THEN
	    l_new_surrogate_key := stu_rec.c_surrogate_key;
	END IF;

	IF p_phase = 1 THEN update_uid; END IF;
	transfer_row;
    END LOOP;

END install_payment_types;

--****************************************************************************
-- INSTALLATION PROCEDURE FOR : PER_USER_ROWS
--****************************************************************************

PROCEDURE install_urows (p_phase IN NUMBER)
-------------------------------------------
IS
    row_in_error			exception;
    l_current_proc		varchar2(80) := 'hr_legislation.install_urows';
    l_new_user_row_id       	number(15);
    l_null_return           	varchar2(1);
    l_last_urow_id              number(15);

--  This cursor returns the earliest record for each user_row_id,
--  which is mandatory to examine matching between pay_user_rows_f
--  and hr_s_user_rows_f.

    CURSOR c_distinct
    IS
	--
	select r1.effective_start_date
	,      r1.user_row_id c_surrogate_key
	,      r1.row_low_range_or_name c_true_key
	,      r1.row_high_range
	,      r1.legislation_code
	,      r1.legislation_subgroup
	,      r1.user_table_id
        from   hr_s_user_rows_f r1
        where  not exists(
               select null
               from hr_s_user_rows_f r2
               where r2.user_row_id = r1.user_row_id
               and r2.effective_start_date < r1.effective_start_date);

    CURSOR c_each_row (pc_user_row_id varchar2)
    IS
	-- The primary key has already been selected using the above cursor.
	-- This cursor accepts the primary key as a parameter and selects all
	-- date effective rows for it.

	select *
	from   hr_s_user_rows_f
	where  user_row_id = pc_user_row_id;

    CURSOR c_col_inst (p_user_row_id number)
    IS
	-- select all child user column instances for the current user row

	select *
	from   hr_s_user_column_instances_f
	where  user_row_id = p_user_row_id;

    r_distinct		c_distinct%ROWTYPE;
    r_each_row		c_each_row%ROWTYPE;


    PROCEDURE check_next_sequence
    -----------------------------
    IS

	v_sequence_number number(15);
	v_min_delivered number(15);
	v_max_delivered number(15);
        v_max_live      number(15);
        cnt      number(15);

	-- Surrogate id conflicts may arise from two scenario's:
	-- 1. Where the newly select sequence value conflicts with values
	--    in the STU tables.
	-- 2. Where selected surrogate keys, from the installed tables,
	--    conflict with other rows in the STU tables.
	--
	-- Both of the above scenario's are tested for.
	-- The first is a simple match, where if a value is detected in the
	-- STU tables and the installed tables then a conflict is detected. In
	-- This instance all STU surrogate keys, for this table, are updated.
	-- The second is tested for using the sequences.
	-- If the next value from the live sequence is within the range of
	-- delivered surrogate id's then the live sequence must be incremented.
	-- If no action is taken, then duplicates may be introduced into the
	-- delivered tables, and child rows may be totally invalidated.

    BEGIN


	BEGIN	--check that the installed id's will not conflict
		--with the delivered values


            select count(*)
            into cnt
            from hr_s_user_rows_f;

            If cnt=0 then return; end if;


	    select distinct null
	    into   l_null_return
	    from   pay_user_rows_f a
	    where  exists
		(select null
		 from   hr_s_user_rows_f b
		 where  a.user_row_id = b.user_row_id
		);

	    --conflict may exist
	    --update all user_row_id's to remove conflict

	    update /*+NO_INDEX*/ hr_s_user_rows_f
	    set    user_row_id = user_row_id - 50000000;

            update /*+NO_INDEX*/ hr_s_user_column_instances_f
            set    user_row_id = user_row_id - 50000000;

	    update hr_s_application_ownerships
	    set    key_value = key_value - 50000000
	    where  key_name = 'USER_ROW_ID';

	EXCEPTION WHEN NO_DATA_FOUND THEN NULL;

	END; --check of user_row_id



	select min(user_row_id) - (count(*) *3)
	,      max(user_row_id) + (count(*) *3)
	into   v_min_delivered
	,      v_max_delivered
	from   hr_s_user_rows_f;

        select max(user_row_id)
        into   v_max_live
        from   pay_user_rows_f;

	select pay_user_rows_s.nextval
	into   v_sequence_number
	from   dual;

	IF (v_sequence_number BETWEEN v_min_delivered AND v_max_delivered)
           OR (v_sequence_number < v_max_live) THEN

           IF v_max_live > v_max_delivered THEN

             hr_legislation.munge_sequence('PAY_USER_ROWS_S',
                                           v_sequence_number,
                                           v_max_live);
           ELSE

             hr_legislation.munge_sequence('PAY_USER_ROWS_S',
                                           v_sequence_number,
                                           v_max_delivered);
           END IF;
        END IF;

    END check_next_sequence;


    PROCEDURE crt_exc (exception_type IN varchar2)
    ----------------------------------------------
    IS
    BEGIN

	-- When the installation procedures encounter an error that cannot
	-- be handled, an exception is raised and all work is rolled back
	-- to the last savepoint. The installation process then continues
	-- with the next primary key to install. The same exception will
	-- not be raised more than once.

	rollback to new_row_low_range_or_name;

 	insert_hr_stu_exceptions('pay_user_rows_f'
	,      r_distinct.c_surrogate_key
        ,      exception_type
        ,      r_distinct.c_true_key);


    END crt_exc;

    PROCEDURE remove (v_id IN number)
    ---------------------------------
    IS
	-- subprogram to delete a row from the delivery tables, and all child
	-- application ownership rows

    BEGIN

	delete from hr_s_user_rows_f
	where  user_row_id = v_id;

	delete from hr_s_user_column_instances_f
	where  user_row_id = v_id;

    END remove;

    PROCEDURE update_uid
    --------------------
    IS
	-- subprogram to update surrogate UID and all occurrences in child rows

    BEGIN

	-- See if this primary key is already installed. If so then the sorrogate
	-- key of the delivered row must be updated to the value in the installed
	-- tables. If the row is not already present then select the next value
	-- from the sequence. In either case all rows for this primary key must
	-- be updated, as must all child references to the old surrogate uid.

        --
        --
	BEGIN
	   --
          select distinct user_row_id
          into   l_new_user_row_id
          from   pay_user_rows_f
          where  user_table_id         = r_distinct.user_table_id
          and    row_low_range_or_name = r_distinct.c_true_key
          and    nvl(row_high_range, 'NULL') =
                    nvl(r_distinct.row_high_range, 'NULL')
          and    effective_start_date  = r_distinct.effective_start_date
          and    business_Group_id is null
          and    nvl(legislation_code, 'x') = nvl(r_distinct.legislation_code, 'x');

	EXCEPTION WHEN NO_DATA_FOUND THEN

	    select pay_user_rows_s.nextval
	    into   l_new_user_row_id
	    from   dual;
        --
        WHEN TOO_MANY_ROWS THEN
        --
        -- 1550308. Trap the error whereby there is more than one
        -- User Row ID for a row_low_range_or_name or rlron and
        -- row_high_range combination in the live table.
        --
            crt_exc('Non unique User Row ID for user row range or name');
        --
        END;


	update hr_s_user_rows_f
	set    user_row_id = l_new_user_row_id
	where  user_row_id = r_distinct.c_surrogate_key;


	update hr_s_application_ownerships
	set    key_value = to_char(l_new_user_row_id)
	where  key_value = to_char(r_distinct.c_surrogate_key)
	and    key_name = 'USER_ROW_ID';


	update hr_s_user_column_instances_f
	set    user_row_id = l_new_user_row_id
	where  user_row_id = r_distinct.c_surrogate_key;

    END update_uid;

    FUNCTION check_parents RETURN BOOLEAN
    -------------------------------------
    IS
	-- Check the integrity of the references to parent data, before allowing
	-- data to be installed. No parents can exist in the startup tables, since
	-- this will violate constraints when the row is installed, also the
	-- parent uid's must exist in the installed tables already.
	-- This function will RETURN TRUE if a parent row still exists in the
	-- delivery account. All statements drop through to a RETURN FALSE.

    BEGIN

	-- This procedure is only called in phase 2. The logic to check if
	-- a given parental foriegn key exists is split into two parts for
	-- every foreign key. The first select from the delivery tables.

	-- If a row is found then the installation of the parent must have
	-- failed, and this installation must not go ahead. If no data is
	-- found, ie: an exception is raised, the installation is valid.
	-- The second check looks for a row in the live tables. If no rows
	-- are returned then this installation is invalid, since this means
	-- that the parent referenced by this row is not present in the
	-- live tables.

	-- Return code of true indicates that all parental data is correct.

	BEGIN
	    -- Check first parent does not exist in the delivery tables

	    select null
	    into   l_null_return
	    from   hr_s_user_tables
	    where  user_table_id = r_each_row.user_table_id;


	    crt_exc('Parent user table still exists in delivery tables');

	    return FALSE;	-- Parent still exists, ignore this row

	EXCEPTION WHEN NO_DATA_FOUND THEN
	    null;

 	END;

	BEGIN
	    -- Check that the parent exists in the live tables


	    select null
	    into   l_null_return
	    from   pay_user_tables
	    where  user_table_id = r_each_row.user_table_id;

	EXCEPTION WHEN NO_DATA_FOUND THEN

	    crt_exc('Parent user table does not exist in live tables');
	    return FALSE;

	END;

	return TRUE;		-- Logic drops through to this statement

    END check_parents;

    FUNCTION valid_ownership RETURN BOOLEAN
    ---------------------------------------
    IS
	-- Test ownership of this current row

    BEGIN
	-- This function is split into three distinct parts. The first
	-- checks to see if a row exists with the same primary key, for a
	-- business group that would have access to the delivered row. The
	-- second checks details for data created in other legislations,
	-- in case data is either created with a null legislation or the
	-- delivered row has a null legislation. The last check examines
	-- if this data is actually required for a given install by examining
	-- the product installation table, and the ownership details for
	-- this row.

	-- A return code of TRUE indicates that the row is required.


	BEGIN
	    -- Perform a check to see if the primary key has been created within
	    -- a visible business group. Ie: the business group is for the same
	    -- legislation as the delivered row, or the delivered row has a null
	    -- legislation. If no rows are returned then the primary key has not
	    -- already been created by a user.

	    --
	    -- #271139 - hitting a problem because the row_low_range_or_name is
	    -- not the true key on its own; it's only unique for the user table.
	    -- Add the user table id and row high range to the select criteria.
	    --
	    -- Further fix necessary to cater for the possibility that the
	    -- high range may be null. Must put NVL on both sides, otherwise
	    -- matching rows with null row_high_ranges are not detected.
	    --
            select distinct null
            into   l_null_return
            from  pay_user_rows_f a
            where a.user_table_id = r_distinct.user_table_id
            and   a.effective_start_date  = r_distinct.effective_start_date
            and   a.row_low_range_or_name = r_distinct.c_true_key
            and    nvl(row_high_range, 'NULL') =
                    nvl(r_distinct.row_high_range, 'NULL')
            and   a.business_group_id is not null
            and   exists (select null from per_business_groups b
              where b.business_group_id = a.business_group_id
              and b.legislation_code = nvl(r_distinct.legislation_code,b.legislation_code));

	    crt_exc('Row already created in a business group');

	    return FALSE; 	-- Indicates this row is not to be transferred

	EXCEPTION WHEN NO_DATA_FOUND THEN
	    null;

	END;

	-- Now perform a check to see if this primary key has been installed
	-- with a legislation code that would make it visible at the same time
	-- as this row. Ie: if any legislation code is null within the set of
	-- returned rows, then the transfer may not go ahead. If no rows are
	-- returned then the delivered row is fine.

	BEGIN
	    --
	    -- #271139 - hitting a problem because the row_low_range_or_name is
	    -- not the true key on its own; it's only unique for the user table.
	    -- Add the user table id and row high range to the select criteria.
	    --
	    --
	    -- Further fix necessary to cater for the possibility that the
	    -- high range may be null. Must put NVL on both sides, otherwise
	    -- matching rows with null row_high_ranges are not detected.
	    --
	    select distinct null
	    into   l_null_return
	    from   pay_user_rows_f
	    where  row_low_range_or_name = r_distinct.c_true_key
            and    effective_start_date  = r_distinct.effective_start_date
            and    nvl(row_high_range, 'NULL') =
                    nvl(r_distinct.row_high_range, 'NULL')
	    and    user_table_id         = r_distinct.user_table_id
	    and    nvl(legislation_code,'x') <>
                                       nvl(r_distinct.legislation_code,'x')
	    and   (
	           legislation_code is null
	        or r_distinct.legislation_code is null
	          );


	    crt_exc('Row already created for a visible legislation');
	    return FALSE;

	EXCEPTION WHEN NO_DATA_FOUND THEN
	    null;

	END;

	-- The last check examines the product installation table, and the
	-- ownership details for the delivered row. By examining these
	-- tables the row is either deleted or not. If the delivered row
	-- is 'stamped' with a legislation subgroup, then a check must be
	-- made to see if that subgroup is active or not. This check only
	-- needs to be performed in phase 1, since once this decision is
	-- made, it is pointless to perform this logic again.

	-- The exception is raised within this procedure if no rows are returned
	-- in this select statement. If no rows are returned then one of the
	-- following is true:
	--     1. No ownership parameters are defined.
	--     2. The products, for which owning parameters are defined, are not
	--        installed with as status of 'I'.
	--     3. The data is defined for a legislation subgroup that is not active.

	IF p_phase <> 1 THEN return TRUE; END IF;


	-- If exception raised then this row is not needed

        if (r_distinct.legislation_subgroup is null) then
        select distinct null
        into   l_null_return
        from   dual
        where  exists (
         select null
         from   hr_s_application_ownerships a
        ,      fnd_product_installations b
        ,      fnd_application c
        where  a.key_name = 'USER_ROW_ID'
        and    a.key_value = r_distinct.c_surrogate_key
        and    a.product_name = c.application_short_name
        and    c.application_id = b.application_id
        and    ((b.status = 'I' and c.application_short_name <> 'PQP')
                or
                (b.status in ('I', 'S') and c.application_short_name = 'PQP')));
        else
        select distinct null
        into   l_null_return
        from   dual
        where  exists (
         select null
	 from   hr_s_application_ownerships a
	,      fnd_product_installations b
	,      fnd_application c
	where  a.key_name = 'USER_ROW_ID'
	and    a.key_value = r_distinct.c_surrogate_key
	and    a.product_name = c.application_short_name
	and    c.application_id = b.application_id
        and    ((b.status = 'I' and c.application_short_name <> 'PQP')
                or
                (b.status in ('I', 'S') and c.application_short_name = 'PQP')))
	and    exists (
	       select null
	       from hr_legislation_subgroups d
	              where d.legislation_code = r_distinct.legislation_code
	              and d.legislation_subgroup = r_distinct.legislation_subgroup
	              and d.active_inactive_flag = 'A'
	       );
        end if;


	return TRUE;		-- Indicates row is required

    EXCEPTION WHEN NO_DATA_FOUND THEN

	-- Row not needed for any installed product


	remove(r_distinct.c_surrogate_key);

	return FALSE;		-- Indicates row not needed

    END valid_ownership;

BEGIN
    -- Two loops are used here. The main loop which select distinct primary
    -- key rows and an inner loop which selects all date effective rows for the
    -- primary key. The inner loop is only required in phase two, since only
    -- in phase 2 are rows actually transferred. The logic reads as follows:
    --    Only deal with rows which have correct ownership details and will
    --    not cause integrity problems (valid_ownership).
    --    In Phase 1:
    --               - Delete delivery rows where the installed rows are identical.
    --               - The UNION satement compares delivery rows to installed rows.
    --                 If the sub query returns any rows, then the delivered
    --                 tables and the installed tables are different.
    --    In Phase 2:
    --               - Delete from the installed tables using the surrogate id.
    --               - If an installed row is to be replaced, the values of
    --                 the surrogate keys will be identical at this stage.
    --               - Data will then be deleted from the delivery tables.
    --               - Call the installation procedure for any child tables, that
    --                 must be installed within the same commit unit. If any
    --                 errors occur then rollback to the last declared savepoint.
    --               - Check that all integrity rules are still obeyed at the end
    --                 of the installation (validity_checks).
    -- An exception is used with this procedure 'row_in_error' in case an error
    -- is encountered from calling any function. If this is raised, then an
    -- exception is entered into the control tables (crt_exc();) and a rollback
    -- is performed.

    IF p_phase = 1 THEN check_next_sequence; END IF;

    FOR row_low_range_or_names IN c_distinct LOOP

	savepoint new_row_low_range_or_name;
	r_distinct := row_low_range_or_names;

	BEGIN

	    IF valid_ownership THEN
		-- This row is wanted

		IF p_phase = 1 THEN

		    -- Get new surrogate id and update child references

		    update_uid;

		ELSE
		    -- Phase = 2

		    delete from pay_user_column_instances_f
		    where  user_row_id = r_distinct.c_surrogate_key
		    and    business_group_id is null;

		    delete from pay_user_rows_f
		    where  user_row_id = r_distinct.c_surrogate_key;

		    FOR each_row IN c_each_row(r_distinct.c_surrogate_key) LOOP
			r_each_row := each_row;

			IF NOT check_parents THEN RAISE row_in_error; END IF;

                        BEGIN
			insert into pay_user_rows_f
			(user_row_id
			,effective_start_date
			,effective_end_date
			,business_group_id
			,legislation_code
			,user_table_id
			,row_low_range_or_name
			,display_sequence
			,legislation_subgroup
			,row_high_range
			,last_update_date
			,last_updated_by
			,last_update_login
			,created_by
			,creation_date
			)
			values
			(each_row.user_row_id
			,each_row.effective_start_date
			,each_row.effective_end_date
			,each_row.business_group_id
			,each_row.legislation_code
			,each_row.user_table_id
			,each_row.row_low_range_or_name
			,each_row.display_sequence
			,each_row.legislation_subgroup
			,each_row.row_high_range
			,each_row.last_update_date
			,each_row.last_updated_by
			,each_row.last_update_login
			,each_row.created_by
			,each_row.creation_date
			);
                      EXCEPTION WHEN OTHERS THEN
                        hrrunprc_trace_on;
                        hr_utility.trace('ins pay_user_rows');
                        hr_utility.trace('table_id  ' ||
                          to_char(each_row.user_table_id));
                        hr_utility.trace('name ' ||
                          each_row.row_low_range_or_name);
                        hr_utility.trace('high_range ' ||
                          each_row.row_high_range);
                        hr_utility.trace(':lc: ' || ':' ||
                          each_row.legislation_code || ':');
                        hr_utility.trace('eff start date ' ||
                          to_date(each_row.effective_start_date,'DD-MM-YYYY'));
                        hrrunprc_trace_off;
                        raise;
                      END;

			    END LOOP each_row;

			    FOR each_child IN c_col_inst(r_distinct.c_surrogate_key) LOOP

				BEGIN

				    select distinct null
				    into   l_null_return
				    from   pay_user_columns
				    where  user_column_id = each_child.user_column_id;

				    insert into pay_user_column_instances_f
				    (user_column_instance_id
				    ,effective_start_date
				    ,effective_end_date
				    ,user_row_id
				    ,user_column_id
				    ,business_group_id
				    ,legislation_code
				    ,legislation_subgroup
				    ,value
				    ,last_update_date
				    ,last_updated_by
				    ,last_update_login
				    ,created_by
				    ,creation_date)
				    select pay_user_column_instances_s.nextval
				    ,each_child.effective_start_date
				    ,each_child.effective_end_date
				    ,each_child.user_row_id
				    ,each_child.user_column_id
				    ,each_child.business_group_id
				    ,each_child.legislation_code
				    ,each_child.legislation_subgroup
				    ,each_child.value
				    ,each_child.last_update_date
				    ,each_child.last_updated_by
				    ,each_child.last_update_login
				    ,each_child.created_by
				    ,each_child.creation_date
				    from dual;

				EXCEPTION WHEN NO_DATA_FOUND THEN
				    crt_exc('Parent Column not in live tables');
				    RAISE row_in_error;
                                   WHEN OTHERS THEN
                        hrrunprc_trace_on;
                        hr_utility.trace('ins pay_user_col_inst');
                        hr_utility.trace('value  ' ||
                          each_child.value);
                        hr_utility.trace('column_id  ' ||
                          to_char(each_child.user_column_id));
                        hr_utility.trace('row id ' ||
                          to_char(r_distinct.c_surrogate_key));
                        hr_utility.trace('row low range ' ||
                          r_distinct.c_true_key);
                        hr_utility.trace('row eff start date ' ||
                          to_date(r_distinct.effective_start_date, 'DD-MM-YYYY'));
                        hr_utility.trace('col eff start date ' ||
                          to_date(each_child.effective_start_date, 'DD-MM-YYYY'));
                        hrrunprc_trace_off;
                        raise;
				END;

			    END LOOP;

			    remove(r_distinct.c_surrogate_key);

			END IF;			-- End phase checking


		    END IF; --(valid ownership test)

		EXCEPTION WHEN row_in_error THEN
		    rollback to new_row_low_range_or_name;

		END;

	    END LOOP row_low_range_or_names;

	END install_urows;

	--****************************************************************************
	-- INSTALLATION PROCEDURE FOR : HR_STU_HISTORY
	--****************************************************************************

	    FUNCTION maintain_history (p_phase IN number) RETURN BOOLEAN
	    ------------------------------------------------------------
	    IS
		-- Checks and validates the value of the passed parameter. If the value
		-- is within the correct range, rows will be inserted/updated to the
		-- history table. If the routine has been called in pahse 2, a row must
		-- exist in the history table.

		cursor c_legs is
		  select package_name
		  from   hr_s_history;

		v_package_name varchar2(30);

	    BEGIN

		-- First insert a row into the hr_stu_history table

		FOR r_legs in c_legs loop

		  v_package_name := r_legs.package_name;

		  IF p_phase = 1 OR p_phase = 2 THEN

		    delete from hr_stu_exceptions;

                    -- Used to error oinly if in phase 1 but to stop
                    -- situations where we lose legit Phase 1 exceptions
                    -- because an adpatch rerun then fails in Phase 2
                    -- (implit commit due to a resequence?) we will do the
                    -- removal of stu exception data prior to the adpatch
                    -- hrrunprc line in the hrglobal driver
		    IF SQL%FOUND THEN
			rollback;
			return FALSE;
		     END IF;

		    update hr_stu_history
		    set    status = 'Phase '||p_phase
		    where  package_name = v_package_name;

		    IF SQL%NOTFOUND THEN
			 -- History row must exist for phase 2
			 IF p_phase = 2 THEN return FALSE; END IF;

			insert into hr_stu_history
			(package_name
			,date_of_export
			,date_of_import
			,status
			,legislation_code
			)
			select distinct package_name
			,      date_of_export
			,      sysdate
			,      'Phase 1'
			,      legislation_code
			from   hr_s_history
			where package_name = v_package_name;

		    END IF;

		ELSE
		    return FALSE; 	-- Phase value is incorrect.

		END IF; --end phase check

	    END LOOP;

            return TRUE;

	    END maintain_history;

	--****************************************************************************
	-- INSTALLATION PROCEDURE FOR : PAY_MONETARY_UNITS
	--****************************************************************************

	    PROCEDURE install_monetary (p_phase IN number)
	    ----------------------------------------------
	    IS
		l_null_return varchar2(1); 	-- Used for 'select null' statements
		l_new_surrogate_key number(15); -- Used to hold the new uid.

	    CURSOR stu
	    IS
		select monetary_unit_id c_surrogate_key
		,      currency_code
		,      business_group_id
		,      legislation_code c_leg_code
		,      monetary_unit_name c_true_key
		,      relative_value
		,      last_update_date
		,      last_updated_by
		,      last_update_login
		,      created_by
		,      creation_date
		,      rowid
		from   hr_s_monetary_units;

	    stu_rec	stu%ROWTYPE;		-- Record definition for above SELECT

	    PROCEDURE crt_exc (exception_type IN varchar2)
	    ----------------------------------------------
	    IS
		-- When the installation procedures encounter an error that cannot
		-- be handled, an exception is raised and all work is rolled back
		-- to the last savepoint. The installation process then continues
		-- with the next primary key to install. The same exception will
		-- not be raised more than once.

	    BEGIN
		rollback to new_primary_key;

		insert_hr_stu_exceptions('PAY_MONETARY_UNITS'
		,      stu_rec.c_surrogate_key
		,      exception_type
		,      stu_rec.c_true_key);


	    END crt_exc;

	    PROCEDURE check_next_sequence
	    -----------------------------
	    IS

		v_sequence_number number(15);
		v_min_delivered number(15);
		v_max_delivered number(15);
                v_max_live      number(15);
                cnt      number(15);

		-- Surrogate id conflicts may arise from two scenario's:
		-- 1. Where the newly select sequence value conflicts with values
		--    in the STU tables.
		-- 2. Where selected surrogate keys, from the installed tables,
		--    conflict with other rows in the STU tables.
		--
		-- Both of the above scenario's are tested for.
		-- The first is a simple match, where if a value is detected in the
		-- STU tables and the installed tables then a conflict is detected. In
		-- This instance all STU surrogate keys, for this table, are updated.
		-- The second is tested for using the sequences.
		-- If the next value from the live sequence is within the range of
		-- delivered surrogate id's then the live sequence must be incremented.
		-- If no action is taken, then duplicates may be introduced into the
		-- delivered tables, and child rows may be totally invalidated.

	    BEGIN


		BEGIN	--check that the installed id's will not conflict
			--with the delivered values


	            select count(*)
       		     into cnt
       		     from hr_s_monetary_units;

       		     If cnt=0 then return; end if;


		    select distinct null
		    into   l_null_return
		    from   pay_monetary_units a
		    where  exists
			(select null
			 from   hr_s_monetary_units b
			 where  a.monetary_unit_id = b.monetary_unit_id
			);

		    --conflict may exist
		    --update all monetary_unit_id's to remove conflict

		    update hr_s_monetary_units
		    set    monetary_unit_id = monetary_unit_id - 50000000;

		    update hr_s_application_ownerships
		    set    key_value = key_value - 50000000
		    where  key_name = 'MONETARY_UNIT_ID';

		EXCEPTION WHEN NO_DATA_FOUND THEN NULL;

		END; --check of monetary_unit_id


		select min(monetary_unit_id) - (count(*) *3)
		,      max(monetary_unit_id) + (count(*) *3)
		into   v_min_delivered
		,      v_max_delivered
		from   hr_s_monetary_units;

                select max(monetary_unit_id)
                into   v_max_live
                from   pay_monetary_units;

		select pay_monetary_units_s.nextval
		into   v_sequence_number
		from   dual;

	        IF (v_sequence_number BETWEEN v_min_delivered AND v_max_delivered)
                  OR (v_sequence_number < v_max_live) THEN

                  IF v_max_live > v_max_delivered THEN

                    hr_legislation.munge_sequence('PAY_MONETARY_UNITS_S',
                                                  v_sequence_number,
                                                  v_max_live);
                  ELSE

                    hr_legislation.munge_sequence('PAY_MONETARY_UNITS_S',
                                                  v_sequence_number,
                                                  v_max_delivered);
                 END IF;
               END IF;

	    END check_next_sequence;

	    PROCEDURE update_uid
	    --------------------
	    IS
		-- Subprogram to update surrogate UID and all occurrences in child rows

	    BEGIN

		BEGIN
		    select distinct monetary_unit_id
		    into   l_new_surrogate_key
		    from   pay_monetary_units
		    where  currency_code = stu_rec.currency_code
		    and    monetary_unit_name = stu_rec.c_true_key
		    and    business_group_id is null
		    and  (
			     (legislation_code is null
			 and  stu_rec.c_leg_code is null)
			  or (legislation_code = stu_rec.c_leg_code)
			 );

		EXCEPTION WHEN NO_DATA_FOUND THEN

		    select pay_monetary_units_s.nextval
			    into   l_new_surrogate_key
			    from   dual;

		END;

		-- Update all child entities


		update hr_s_monetary_units
		set    monetary_unit_id = l_new_surrogate_key
		where  monetary_unit_id = stu_rec.c_surrogate_key;

		update hr_s_application_ownerships
		set    key_value = to_char(l_new_surrogate_key)
		where  key_value = to_char(stu_rec.c_surrogate_key)
		and    key_name = 'MONETARY_UNIT_ID';

	    END update_uid;

	    PROCEDURE remove
	    ----------------
	    IS
		-- Remove a row from either the startup tables or the installed tables

	    BEGIN

		delete from hr_s_monetary_units
		where  rowid = stu_rec.rowid;

	    END remove;

	    FUNCTION valid_ownership RETURN BOOLEAN
	    ---------------------------------------
	    IS
		-- Test ownership of this current row

	    BEGIN

		-- This routine only operates in phase 1. Rows are present in the
		-- table hr_application_ownerships in the delivery account, which
		-- dictate which products a piece of data is used for. If the query
		-- returns a row then this data is required, and the function will
		-- return true. If no rows are returned and an exception is raised,
		-- then this row is not required and may be deleted from the delivery
		-- tables.

		-- If legislation code and subgroup code are included on the delivery
		-- tables, a check must be made to determine if the data is defined for
		-- a specific subgroup. If so the subgroup must be 'A'ctive for this
		-- installation.

		-- A return code of TRUE indicates that the row is required.

		-- The exception is raised within this procedure if no rows are returned
		-- in this select statement. If no rows are returned then one of the
		-- following is true:
		--     1. No ownership parameters are defined.
		--     2. The products, for which owning parameters are defined, are not
		--        installed with as status of 'I'.
		--     3. The data is defined for a legislation subgroup that is not active.


		IF p_phase <> 1 THEN return TRUE; END IF;


		select null
		into   l_null_return
		from   dual
		where  exists
		       (select null
			from   hr_s_application_ownerships a
			,      fnd_product_installations b
			,      fnd_application c
			where  a.key_name = 'MONETARY_UNIT_ID'
			and    a.key_value = stu_rec.c_surrogate_key
			and    a.product_name = c.application_short_name
			and    c.application_id = b.application_id
                        and    ((b.status = 'I' and c.application_short_name <> 'PQP')
                                or
                                (b.status in ('I', 'S') and c.application_short_name = 'PQP')));

		return TRUE;		-- Indicates row is required

	    EXCEPTION WHEN NO_DATA_FOUND THEN

		-- Row not needed for any installed product

		remove;

		return FALSE;		-- Indicates row not needed

	    END valid_ownership;

	    PROCEDURE transfer_row
	    IS
		-- Check if a delivered row is needed and insert into the
		-- live tables if it is.

		-- The procedure checks to see if the same monetary unit has been
		-- installed in a contentious business group or legislation.

	    BEGIN

		BEGIN

		    -- Perform a check to see if the primary key has been creeated within
		    -- a visible business group. Ie: the business group is for the same
		    -- legislation as the delivered row, or the delivered row has a null
		    -- legislation. If no rows are returned then the primary key has not
		    -- already been created by a user.

                    select distinct null
                    into   l_null_return
                    from pay_monetary_units a
                    where a.monetary_unit_name = stu_rec.c_true_key
                    and    a.currency_code = stu_rec.currency_code
                    and   a.business_group_id is not null
                    and   exists (select null from per_business_groups b
                      where b.business_group_id = a.business_group_id
                      and b.legislation_code = nvl(stu_rec.c_leg_code,b.legislation_code));

		    crt_exc('Row already created in a business group');

		    return; 		-- Indicates this row is not to be transferred

		EXCEPTION WHEN NO_DATA_FOUND THEN
		    null;

		END;


		-- Now perform a check to see if this primary key has been installed
		-- with a legislation code that would make it visible at the same time
		-- as this row. Ie: if any legislation code is null within the set of
		-- returned rows, then the transfer may not go ahead. If no rows are
		-- returned then the delivered row is fine.

		BEGIN
		    select distinct null
		    into   l_null_return
		    from   pay_monetary_units
		    where  monetary_unit_name = stu_rec.c_true_key
		    and    currency_code = stu_rec.currency_code
		    and    nvl(legislation_code,'X') <> nvl(stu_rec.c_leg_code,'X')
		    and   (
			   legislation_code is null
			or stu_rec.c_leg_code is null
			  )
		    and    business_group_id is null;

		    crt_exc('Row already created for a visible legislation');

		    return; 		-- Indicates this row is not to be transferred

		EXCEPTION WHEN NO_DATA_FOUND THEN
		    null;

		END;


		-- When the procedure is called in phase 1, there is no need to
		-- actually perform the transfer from the delivery tables into the
		-- live. Hence if phase = 1 control is returned to the calling
		-- procedure and the next row is returned.

		IF p_phase = 1 THEN return; END IF;  --only insert on phase 2

		-- If the procedure is called in phase 2, then the live row is updated
		-- with the values on the delivered row.

		-- The routine check_parents validates foreign key references and
		-- ensures referential integrity. The routine checks to see if the
		-- parents of a given row have been transfered to the live tables.

		-- This may only be called in phase two since in phase one all
		-- parent rows will remain in the delivery tables.

		-- After the above checks only data that has been chanegd or is new
		-- will be left in the delivery tables. At this stage if the row is
		-- already present then it must be updated to ensure referential
		-- integrity. Therefore an update will be performed and if SQL%FOUND
		-- is FALSE an insert will be performed.

		-- The last step of the transfer, in phase 2, is to delete the now
		-- transfered row from the delivery tables.


		update pay_monetary_units
		set    currency_code = stu_rec.currency_code
		,      business_group_id = null
		,      legislation_code = stu_rec.c_leg_code
		,      relative_value = stu_rec.relative_value
		,      last_update_date = stu_rec.last_update_date
		,      last_updated_by = stu_rec.last_updated_by
		,      last_update_login = stu_rec.last_update_login
		,      created_by = stu_rec.created_by
		,      creation_date = stu_rec.creation_date
		where  monetary_unit_id = stu_rec.c_surrogate_key;

		IF SQL%NOTFOUND THEN

		    insert into pay_monetary_units
		    (monetary_unit_id
		    ,currency_code
		    ,business_group_id
		    ,legislation_code
		    ,monetary_unit_name
		    ,relative_value
		    ,last_update_date
		    ,last_updated_by
		    ,last_update_login
		    ,created_by
		    ,creation_date
		    )
		    values
		    (stu_rec.c_surrogate_key
		    ,stu_rec.currency_code
		    ,stu_rec.business_group_id
		    ,stu_rec.c_leg_code
		    ,stu_rec.c_true_key
		    ,stu_rec.relative_value
		    ,stu_rec.last_update_date
		    ,stu_rec.last_updated_by
		    ,stu_rec.last_update_login
		    ,stu_rec.created_by
		    ,stu_rec.creation_date
		    );

		END IF;


		remove;

	    END transfer_row;

	BEGIN

	    -- This is the main loop to perform the installation logic. A cursor
	    -- is opened to control the loop, and each row returned is placed
	    -- into a record defined within the main procedure so each sub
	    -- procedure has full access to all returned columns. For each
	    -- new row returned, a new savepoint is declared. If at any time
	    -- the row is in error a rollback is performed to the savepoint
	    -- and the next row is returned. Ownership details are checked and
	    -- if the row is required then the surrogate id is updated and the
	    -- main transfer logic is called.

	    IF p_phase = 1 THEN check_next_sequence; END IF;

	    FOR delivered IN stu LOOP

		savepoint new_primary_key;

		stu_rec := delivered;

		IF valid_ownership THEN

		    -- Test the row onerships for the current row


		    IF p_phase = 1 THEN update_uid; END IF;

		    transfer_row;

		END IF;

	    END LOOP;

	END install_monetary;


	--****************************************************************************
	-- INSTALLATION PROCEDURE FOR : PAY_REPORT_FORMAT_MAPPINGS
	--****************************************************************************
	PROCEDURE install_report_mappings(p_phase IN number)

	-- as this table does not have a primary key, but uses a cpomposite key,
	-- we do not need to check the id

	IS
	   l_null_return varchar2(1);                  -- used for 'select null' statements
	    l_new_surrogate_key number(15);     -- new uid.

	    CURSOR stu                          -- Selects all rows from startup entity
	    IS
		select   report_type            ,
			 report_qualifier       ,
			 report_format          ,
			 effective_start_date   ,
			 effective_end_date     ,
			 range_code             ,
			 assignment_action_code ,
			 initialization_code    ,
			 archive_code           ,
			 magnetic_code          ,
			 report_category        ,
			 report_name            ,
			 sort_code              ,
			 updatable_flag         ,
                         deinitialization_code  ,
			 last_update_date       ,
			 last_updated_by        ,
			 last_update_login      ,
			 created_by             ,
			 creation_date          ,
                         temporary_action_flag  ,
			 rowid
		from hr_s_report_format_mappings_f;

	    stu_rec stu%ROWTYPE;

	    PROCEDURE remove
	    ----------------
	    IS
		-- Remove a row from either the startup tables or the installed tables

	    BEGIN

		delete from hr_s_report_format_mappings_f
		where  rowid = stu_rec.rowid;


	    END remove;

	    PROCEDURE transfer_row
	    ----------------------
	    IS

	    BEGIN

		-- this updates uses only report_type,qualifier,category as its primary key
		-- it may be that effective start and end dates will need to be added
		-- but as of know we can see no need for this

		update pay_report_format_mappings_f
		set  effective_start_date=stu_rec.effective_start_date
		,    effective_end_date=stu_rec.effective_end_date
		,    range_code=stu_rec.range_code
		,    assignment_action_code=stu_rec.assignment_action_code
		,    initialization_code=stu_rec.initialization_code
		,    archive_code=stu_rec.archive_code
		,    magnetic_code=stu_rec.magnetic_code
		,    report_name=stu_rec.report_name
		,    sort_code=stu_rec.sort_code
		,    updatable_flag=stu_rec.updatable_flag
		,    report_format=stu_rec.report_format
                ,    deinitialization_code=stu_rec.deinitialization_code
                ,    last_update_date = stu_rec.last_update_date
                ,    last_updated_by = stu_rec.last_updated_by
                ,    last_update_login = stu_rec.last_update_login
                ,    created_by = stu_rec.created_by
                ,    creation_date = stu_rec.creation_date
                ,    temporary_action_flag = stu_rec.temporary_action_flag
		where report_type= stu_rec.report_type
		and   report_qualifier=stu_rec.report_qualifier
		and   report_category=stu_rec.report_category
		and   effective_start_date = stu_rec.effective_start_date
		and   effective_end_date = stu_rec.effective_end_date;

		IF SQL%NOTFOUND THEN

                    BEGIN
		    insert into pay_report_format_mappings_f
		    ( report_type            ,
		      report_qualifier       ,
		      report_format          ,
		      effective_start_date   ,
		      effective_end_date     ,
		      range_code             ,
		      assignment_action_code ,
		      initialization_code    ,
		      archive_code           ,
		      magnetic_code          ,
		      report_category        ,
		      report_name            ,
		      sort_code              ,
		      updatable_flag         ,
                      deinitialization_code  ,
                      last_update_date       ,
                      last_updated_by        ,
                      last_update_login      ,
                      created_by             ,
                      creation_date          ,
                      temporary_action_flag
		    )
		    values
		    ( stu_rec.report_type            ,
		      stu_rec.report_qualifier       ,
		      stu_rec.report_format          ,
		      stu_rec.effective_start_date   ,
		      stu_rec.effective_end_date     ,
		      stu_rec.range_code             ,
		      stu_rec.assignment_action_code ,
		      stu_rec.initialization_code    ,
		      stu_rec.archive_code           ,
		      stu_rec.magnetic_code          ,
		      stu_rec.report_category        ,
		      stu_rec.report_name            ,
		      stu_rec.sort_code              ,
		      stu_rec.updatable_flag         ,
                      stu_rec.deinitialization_code  ,
                      stu_rec.last_update_date       ,
                      stu_rec.last_updated_by        ,
                      stu_rec.last_update_login      ,
                      stu_rec.created_by             ,
                      stu_rec.creation_date          ,
                      stu_rec.temporary_action_flag
		    );

                    EXCEPTION WHEN OTHERS THEN
                        hrrunprc_trace_on;
                        hr_utility.trace('ins pay_rep_format_map');
                        hr_utility.trace('report_type  ' ||
                          stu_rec.report_type);
                        hr_utility.trace('report_qualifier  ' ||
                          stu_rec.report_qualifier);
                        hr_utility.trace('report_format  ' ||
                          stu_rec.report_format);
                        hrrunprc_trace_off;
                        raise;
                      END;

                  END IF;

		remove;

	    END transfer_row;

	BEGIN

	    FOR delivered IN stu LOOP
		savepoint new_primary_key;
		stu_rec := delivered;
		IF p_phase = 2 THEN transfer_row; END IF;
	    END LOOP;


	END install_report_mappings;


	PROCEDURE install_magnetic_blocks(p_phase IN number)
	-----------------------------------------------
	IS
	   l_null_return varchar2(1);                  -- used for 'select null' statements
	    l_new_surrogate_key number(15);     -- new uid.



	    CURSOR stu                          -- Selects all rows from startup entity
	    IS
		select  distinct magnetic_block_id  	c_surrogate_key,
			block_name		c_true_key,
			main_block_flag,
			report_format,
			cursor_name,
			no_column_returned
		from hr_s_magnetic_blocks;

	   stu_rec stu%ROWTYPE;


	    PROCEDURE check_next_sequence
	    -----------------------------
	    IS

		v_sequence_number number(15);
		v_min_delivered number(15);
		v_max_delivered number(15);
                v_max_live      number(15);
                cnt      number(15);

	   BEGIN


		BEGIN   --check that the installed id's will not conflict
			--with the delivered values

	            select count(*)
	            into cnt
       		    from hr_s_magnetic_blocks;

       		    If cnt=0 then return; end if;

		    select distinct null
		    into   l_null_return
		    from   pay_magnetic_blocks a
		    where  exists
			(select null
			 from   hr_s_magnetic_blocks b
			 where  a.magnetic_block_id = b.magnetic_block_id
			);

		    update hr_s_magnetic_blocks
		    set magnetic_block_id=magnetic_block_id -50000000;

		    update hr_s_magnetic_records
		    set magnetic_block_id=magnetic_block_id -50000000;

		    update hr_s_magnetic_records
		    set next_block_id=next_block_id -50000000;

		EXCEPTION WHEN NO_DATA_FOUND THEN NULL;

		END; --check of magnetic_block_id


		select min(magnetic_block_id) - (count(*) *3)
		,      max(magnetic_block_id) + (count(*) *3)
		into   v_min_delivered
		,      v_max_delivered
		from   hr_s_magnetic_blocks;

                select max(magnetic_block_id)
                into   v_max_live
                from   pay_magnetic_blocks;

		select pay_magnetic_blocks_s.nextval
		into   v_sequence_number
		from   dual;

	        IF (v_sequence_number BETWEEN v_min_delivered AND v_max_delivered)
                  OR (v_sequence_number < v_max_live) THEN

                IF v_max_live > v_max_delivered THEN

                  hr_legislation.munge_sequence('PAY_MAGNETIC_BLOCKS_S',
                                                v_sequence_number,
                                                v_max_live);
                ELSE

                  hr_legislation.munge_sequence('PAY_MAGNETIC_BLOCKS_S',
                                                v_sequence_number,
                                                v_max_delivered);
                END IF;
              END IF;


	    END check_next_sequence;


	    PROCEDURE crt_exc (exception_type IN varchar2)
	    ----------------------------------------------
	    IS
		-- Reports any exceptions during the delivery of startup data to
		-- PER_ASSIGNMENT_STATUS_TYPES. See crt_exc in procedure install_past
		-- for further, generic operational details.

	    BEGIN

		rollback to new_magnetic_blocks;

		insert_hr_stu_exceptions('pay_magnetic_blocks'
		    ,      stu_rec.c_surrogate_key
		    ,      exception_type
		    ,      stu_rec.c_true_key);




	    END crt_exc;


	    PROCEDURE update_uid
	    --------------------
	    IS

	    BEGIN


		BEGIN

                    select distinct magnetic_block_id
		    into   l_new_surrogate_key
		    from   pay_magnetic_blocks
		    where  replace(ltrim(rtrim(upper(block_name))), ' ', '_') =
			   replace(ltrim(rtrim(upper(stu_rec.c_true_key))), ' ', '_')
		    and    replace(ltrim(rtrim(upper(report_format))), ' ', '_') =
			   replace(ltrim(rtrim(upper(stu_rec.report_format))), ' ', '_')
		    and    replace(ltrim(rtrim(upper(nvl(cursor_name,'X')))), ' ', '_') =
			   replace(ltrim(rtrim(upper(nvl(stu_rec.cursor_name,'X')))), ' ', '_');

		    EXCEPTION WHEN NO_DATA_FOUND THEN

		    select pay_magnetic_blocks_s.nextval
		    into l_new_surrogate_key
		    from   dual;

	            WHEN TOO_MANY_ROWS THEN
                        hrrunprc_trace_on;
                        hr_utility.trace('sel pay_mag_blocks TMR');
                        hr_utility.trace('block_name  ' ||
                          stu_rec.c_true_key);
                        hr_utility.trace('report_format  ' ||
                          stu_rec.report_format);
                        hr_utility.trace('cursor_name  ' ||
                          stu_rec.cursor_name);
                        hrrunprc_trace_off;
                        raise;
                END;

		-- Update all child entities

		update hr_s_magnetic_blocks
		set	magnetic_block_id = l_new_surrogate_key
		where   magnetic_block_id = stu_rec.c_surrogate_key;

		update hr_s_application_ownerships
		set    key_value = to_char(l_new_surrogate_key)
		where  key_value = to_char(stu_rec.c_surrogate_key)
		and    key_name = 'MAGNETIC_BLOCK_ID';

		update hr_s_magnetic_records
		set  magnetic_block_id = l_new_surrogate_key
		where   magnetic_block_id = stu_rec.c_surrogate_key;

		update hr_s_magnetic_records
		set  next_block_id= l_new_surrogate_key
		where   next_block_id=stu_rec.c_surrogate_key;

	    END update_uid;

	    PROCEDURE remove
	    ----------------
	    IS
		-- Remove a row from either the startup tables or the installed tables

	    BEGIN

	      delete from hr_s_magnetic_blocks
	      where  magnetic_block_id = stu_rec.c_surrogate_key;

	    END remove;


	    PROCEDURE transfer_row
	    ----------------------
	    -- if a magnetic_block has changed then the row will be updated,
	    -- if it is new , it gets inserted.

	    IS

	    BEGIN


		BEGIN
		    select distinct null
		    into   l_null_return
		    from   pay_magnetic_blocks
		    where  magnetic_block_id =l_new_surrogate_key
		    and    block_name = stu_rec.c_true_key
		    and    main_block_flag =stu_rec.main_block_flag
		    and    report_format =stu_rec.report_format
		    and    nvl(cursor_name,'')=nvl(stu_rec.cursor_name,'')
		    and    nvl(no_column_returned,0)=nvl(stu_rec.no_column_returned,0);

		EXCEPTION WHEN NO_DATA_FOUND THEN

		    IF p_phase = 1 THEN return; END IF;

		    update pay_magnetic_blocks
		    set block_name=stu_rec.c_true_key
		    ,	main_block_flag=stu_rec.main_block_flag
		    ,	report_format=stu_rec.report_format
		    ,	cursor_name=stu_rec.cursor_name
		    ,	no_column_returned=stu_rec.no_column_returned
		    where magnetic_block_id =stu_rec.c_surrogate_key;

		    IF SQL%NOTFOUND THEN

			-- No row there to update, must insert

                       BEGIN
			insert into pay_magnetic_blocks
			 ( magnetic_block_id  ,
			   block_name         ,
			   main_block_flag    ,
			   report_format      ,
			   cursor_name        ,
			   no_column_returned)
			values
			( stu_rec.c_surrogate_key    ,
			  stu_rec.c_true_key         ,
			  stu_rec.main_block_flag    ,
			  stu_rec.report_format      ,
			  stu_rec.cursor_name        ,
			  stu_rec.no_column_returned);
                       EXCEPTION WHEN OTHERS THEN
                        hrrunprc_trace_on;
                        hr_utility.trace('ins pay_mag_blocks');
                        hr_utility.trace('block_name  ' ||
                          stu_rec.c_true_key);
                        hr_utility.trace('report_format  ' ||
                          stu_rec.report_format);
                        hr_utility.trace('cursor_name  ' ||
                          stu_rec.cursor_name);
                        hrrunprc_trace_off;
                        raise;
                       END;

		     END IF;
		END;
		remove;

	    END transfer_row;

	BEGIN

	    IF p_phase = 1 THEN check_next_sequence; END IF;

	    FOR delivered IN stu LOOP

		savepoint new_magnetic_blocks;
		stu_rec := delivered;
		IF p_phase = 2 THEN l_new_surrogate_key := stu_rec.c_surrogate_key; END IF;

		IF p_phase = 1 THEN update_uid; END IF;
		transfer_row;

	    END LOOP;

	END install_magnetic_blocks;


	PROCEDURE install_magnetic_records(p_phase IN number)
	-----------------------------------------------
	IS
	    l_null_return varchar2(1);                  -- used for 'select null' statements
	    l_new_surrogate_key number(15);     -- new uid.

	    CURSOR stu                          -- Selects all rows from startup entity
	    IS
		select distinct
		     formula_id           ,
		     magnetic_block_id    ,
		     next_block_id        ,
		     overflow_mode        ,
		     sequence             ,
		     frequency            ,
		     last_run_executed_mode
		from hr_s_magnetic_records;

	   stu_rec stu%ROWTYPE;


	    PROCEDURE remove
	    ----------------
	    IS
		-- Remove a row from either the startup tables or the installed tables
	    BEGIN
	      delete from hr_s_magnetic_records
	      where  magnetic_block_id = stu_rec.magnetic_block_id
              and    sequence = stu_rec.sequence;
	    END remove;


	    PROCEDURE transfer_row
	    ----------------------
	    IS
	    BEGIN


		BEGIN

		    select distinct null
		    into   l_null_return
		    from   pay_magnetic_records
		    where  formula_id=stu_rec.formula_id
		    and	   magnetic_block_id=stu_rec.magnetic_block_id
		    and    next_block_id=stu_rec.next_block_id
		    and    overflow_mode=stu_rec.overflow_mode
		    and    sequence=stu_rec.sequence
		    and    frequency=stu_rec.frequency
		    and    last_run_executed_mode=stu_rec.last_run_executed_mode;

		EXCEPTION WHEN NO_DATA_FOUND THEN

		    IF p_phase = 1 THEN return; END IF;

		    update pay_magnetic_records
		    set formula_id=stu_rec.formula_id
		    ,	next_block_id=stu_rec.next_block_id
		    ,   overflow_mode=stu_rec.overflow_mode
		    ,   frequency=stu_rec.frequency
		    ,   last_run_executed_mode=stu_rec.last_run_executed_mode
		    where magnetic_block_id=stu_rec.magnetic_block_id
		    and   sequence=stu_rec.sequence;


		    IF SQL%NOTFOUND THEN

			-- No row there to update, must insert


                     BEGIN
			insert into pay_magnetic_records
			 ( formula_id           ,
			   magnetic_block_id    ,
			   next_block_id        ,
			   overflow_mode        ,
			   sequence             ,
			   frequency            ,
			   last_run_executed_mode)
			 values
			 ( stu_rec.formula_id           ,
			   stu_rec.magnetic_block_id    ,
			   stu_rec.next_block_id        ,
			   stu_rec.overflow_mode        ,
			   stu_rec.sequence             ,
			   stu_rec.frequency            ,
			   stu_rec.last_run_executed_mode);
                      EXCEPTION WHEN OTHERS THEN
                        hrrunprc_trace_on;
                        hr_utility.trace('ins pay_magnetic_records');
                        hr_utility.trace('mag block id: ' ||
                          to_char(stu_rec.magnetic_block_id));
                        hr_utility.trace('next blk id: ' ||
                          to_char(stu_rec.next_block_id));
                        hr_utility.trace('sequence: ' ||
                          to_char(stu_rec.sequence));
                        hrrunprc_trace_off;
                        raise;
                      END;

		     END IF;
		END;
		remove;
	    END transfer_row;



	BEGIN

	    FOR delivered IN stu LOOP
		savepoint new_magnetic_blocks;
		stu_rec := delivered;
		transfer_row;
	    END LOOP;

	END install_magnetic_records;


	--****************************************************************************
	-- INSTALLATION PROCEDURE FOR : PAY_REPORT_FORMAT_ITEMS_F
	--****************************************************************************
	PROCEDURE install_report_items(p_phase IN number)

	-- as this table does not have a primary key, but uses a cpomposite key,
	-- we do not need to check the id

	IS
	   l_null_return varchar2(1);                  -- used for 'select null' statements
	    l_new_surrogate_key number(15);     -- new uid.



	    CURSOR stu                          -- Selects all rows from startup entity
	    IS
		select   report_type            ,
			 report_qualifier       ,
			 report_category        ,
			 user_entity_id		,
			 effective_start_date	,
			 effective_end_date	,
			 archive_type		,
			 updatable_flag		,
			 display_sequence	,
			 report_format_item_id  c_surrogate_key,
			 last_update_date       ,
			 last_updated_by        ,
			 last_update_login      ,
			 created_by             ,
			 creation_date          ,
                 rowid
        from hr_s_report_format_items_f;


    stu_rec stu%ROWTYPE;


    PROCEDURE check_next_sequence
	    -----------------------------
	    IS

		v_sequence_number number(15);
		v_min_delivered number(15);
		v_max_delivered number(15);
                v_max_live      number(15);
                cnt      number(15);

	   BEGIN


		BEGIN   --check that the installed id's will not conflict
			--with the delivered values

	            select count(*)
	            into cnt
       		    from  hr_s_report_format_items_f;

       		    If cnt=0 then return; end if;

		    select distinct null
		    into   l_null_return
		    from   pay_report_format_items_f a
		    where  exists
			(select null
			 from   hr_s_report_format_items_f b
			 where  a.report_format_item_id = b.report_format_item_id
			);

		    update hr_s_report_format_items_f
		    set report_format_item_id=report_format_item_id -50000000;

		EXCEPTION WHEN NO_DATA_FOUND THEN NULL;

		END;


		select min(report_format_item_id) - (count(*) *3)
		,      max(report_format_item_id) + (count(*) *3)
		into   v_min_delivered
		,      v_max_delivered
		from   hr_s_report_format_items_f;

                select max(report_format_item_id)
                into   v_max_live
                from   pay_report_format_items_f;

		select pay_report_format_items_s.nextval
		into   v_sequence_number
		from   dual;

	        IF (v_sequence_number BETWEEN v_min_delivered AND v_max_delivered)
                  OR (v_sequence_number < v_max_live) THEN

                IF v_max_live > v_max_delivered THEN

                  hr_legislation.munge_sequence('PAY_REPORT_FORMAT_ITEMS_S',
                                                v_sequence_number,
                                                v_max_live);
                ELSE

                  hr_legislation.munge_sequence('PAY_REPORT_FORMAT_ITEMS_S',
                                                v_sequence_number,
                                                v_max_delivered);
                END IF;
              END IF;


	    END check_next_sequence;

PROCEDURE update_uid
	    --------------------
	    IS

	    BEGIN


		BEGIN

                    select distinct report_format_item_id
		    into   l_new_surrogate_key
		    from   pay_report_format_items_f
		    where  report_type = stu_rec.report_type
		    and    report_qualifier = stu_rec.report_qualifier
		    and    report_category  = stu_rec.report_category
		    and    user_entity_id = stu_rec.user_entity_id;


		    EXCEPTION WHEN NO_DATA_FOUND THEN

		    select pay_report_format_items_s.nextval
		    into l_new_surrogate_key
		    from   dual;

	            WHEN TOO_MANY_ROWS THEN
                        hrrunprc_trace_on;
                        hr_utility.trace('sel pay_report_format_items_f TMR');
                        hr_utility.trace('report_type  ' ||
                          stu_rec.report_type);
                        hr_utility.trace('report_qualifier  ' ||
                          stu_rec.report_qualifier);
                        hr_utility.trace('report_category  ' ||
                          stu_rec.report_category);
                        hr_utility.trace('user_entity_id  ' ||
                          stu_rec.user_entity_id);
                        hrrunprc_trace_off;
                        raise;
                END;

		if l_new_surrogate_key is null then

		     select pay_report_format_items_s.nextval
		     into l_new_surrogate_key
		     from   dual;

		end if;

		update hr_s_report_format_items_f
		set	report_format_item_id = l_new_surrogate_key
		where   report_type = stu_rec.report_type
		  and   report_qualifier = stu_rec.report_qualifier
		  and   report_category  = stu_rec.report_category
		  and   user_entity_id = stu_rec.user_entity_id;

	    END update_uid;

    PROCEDURE remove
    ----------------
    IS
        -- Remove a row from either the startup tables or the installed tables

    BEGIN

        delete from hr_s_report_format_items_f
        where  rowid = stu_rec.rowid;


    END remove;

    PROCEDURE transfer_row
    ----------------------
    IS

    BEGIN

        -- this updates uses only report_type,qualifier,category as its primary key
        -- it may be that effective start and end dates will need to be added
        -- but as of know we can see no need for this

        update pay_report_format_items_f
        set  effective_start_date=stu_rec.effective_start_date
        ,    effective_end_date=stu_rec.effective_end_date
        ,    archive_type=stu_rec.archive_type
        ,    updatable_flag=stu_rec.updatable_flag
        ,    display_sequence=stu_rec.display_sequence
        ,    report_format_item_id = stu_rec.c_surrogate_key
        ,    last_update_date = stu_rec.last_update_date
        ,    last_updated_by = stu_rec.last_updated_by
        ,    last_update_login = stu_rec.last_update_login
        ,    created_by = stu_rec.created_by
        ,    creation_date = stu_rec.creation_date
        where report_type= stu_rec.report_type
        and   report_qualifier=stu_rec.report_qualifier
        and   report_category=stu_rec.report_category
	and   user_entity_id=stu_rec.user_entity_id
	and   effective_start_date = stu_rec.effective_start_date
	and   effective_end_date = stu_rec.effective_end_date ;

        IF SQL%NOTFOUND THEN
           BEGIN
            insert into pay_report_format_items_f
            ( report_type            ,
              report_qualifier       ,
              report_category        ,
	      user_entity_id	     ,
              effective_start_date   ,
              effective_end_date     ,
              archive_type           ,
              updatable_flag	     ,
	      display_sequence       ,
	      report_format_item_id  ,
              last_update_date       ,
	      last_updated_by        ,
	      last_update_login      ,
	      created_by             ,
	      creation_date
            )
            values
            ( stu_rec.report_type            ,
              stu_rec.report_qualifier       ,
              stu_rec.report_category        ,
	      stu_rec.user_entity_id	     ,
              stu_rec.effective_start_date   ,
              stu_rec.effective_end_date     ,
              stu_rec.archive_type           ,
              stu_rec.updatable_flag         ,
	      stu_rec.display_sequence       ,
              stu_rec.c_surrogate_key        ,
              stu_rec.last_update_date       ,
	      stu_rec.last_updated_by        ,
	      stu_rec.last_update_login      ,
	      stu_rec.created_by             ,
	      stu_rec.creation_date
            );

                EXCEPTION WHEN OTHERS THEN
                        hrrunprc_trace_on;
                        hr_utility.trace('ins pay_report_format_items_f');
                        hr_utility.trace('report_type  ' ||
                          stu_rec.report_type);
                        hr_utility.trace('report_qualifier  ' ||
                          stu_rec.report_qualifier);
                        hr_utility.trace('report_category  ' ||
                          stu_rec.report_category);
                        hr_utility.trace('ue_id  ' ||
                          to_char(stu_rec.user_entity_id));
                        hrrunprc_trace_off;
                        raise;
                      END;

          END IF;


        remove;

    END transfer_row;

BEGIN

    IF p_phase = 1 THEN check_next_sequence; END IF;

    FOR delivered IN stu LOOP
        savepoint new_primary_key;
        stu_rec := delivered;

        IF p_phase = 2 THEN l_new_surrogate_key := stu_rec.c_surrogate_key; END IF;

        IF p_phase = 1 THEN update_uid; END IF;

        IF p_phase=2 THEN transfer_row; end if;

    END LOOP;

END install_report_items;


--****************************************************************************
-- INITIAL ENTRY POINT FOR THE INSTALLATION/DELIVERY OF STARTUP DATA
--****************************************************************************


PROCEDURE install (p_phase number)
----------------------------------
IS

-- Driver procedure to control the execution of all installation procedures.
-- The function call to 'maintain_history' decides if the phase value is
-- correct. It also inserts/updates the history table.

-- This install procedure accepts the phase number, and is for the caller
-- to control the execution of the phases themselves.
-- There is another procedure called install.

-- The final part of this procedure updates the history row, if the phase
-- just completed had exceptions raised.

-- The order in which the following procedures and packages are called
-- is very important. Please refer to the startup low level design.

    v_exception_counter number(15);

BEGIN

    IF maintain_history(p_phase) THEN

	-- Install all formula ditionary
hrrunprc_trace_on;
hr_utility.trace('start hr_legislation.install: ' || to_char(p_phase));
hr_utility.trace('start ff_data_dict.install: ' || to_char(p_phase));
hrrunprc_trace_off;
	ff_data_dict.install(p_phase);

	-- Install assignment status types
hrrunprc_trace_on;
hr_utility.trace('start install_past: ' || to_char(p_phase));
hrrunprc_trace_off;
	install_past(p_phase);

	-- Benefits
hrrunprc_trace_on;
hr_utility.trace('start hr_legislation_benefits.install: ' || to_char(p_phase));
hrrunprc_trace_off;
	hr_legislation_benefits.install(p_phase);

	-- Elements
hrrunprc_trace_on;
hr_utility.trace('start hr_legislation_elements.install: ' || to_char(p_phase));
hrrunprc_trace_off;
	hr_legislation_elements.install(p_phase);

	-- Install payment types
hrrunprc_trace_on;
hr_utility.trace('start install_payment_types: ' || to_char(p_phase));
hrrunprc_trace_off;
	install_payment_types(p_phase);

	-- Install user rows
hrrunprc_trace_on;
hr_utility.trace('start install_urows: ' || to_char(p_phase));
hrrunprc_trace_off;
	install_urows(p_phase);

	-- Balance dimensions
hrrunprc_trace_on;
hr_utility.trace('start install_dimensions: ' || to_char(p_phase));
hrrunprc_trace_off;
	install_dimensions(p_phase);

	-- Install dimension routes
hrrunprc_trace_on;
hr_utility.trace('start install_dimension_routes: ' || to_char(p_phase));
hrrunprc_trace_off;
        install_dimension_routes(p_phase);

        -- Install balance categories
hrrunprc_trace_on;
hr_utility.trace('start install_bal_categories: ' || to_char(p_phase));
hrrunprc_trace_off;
        install_bal_categories(p_phase);

        -- Install balances,classes,defined,feeds
hrrunprc_trace_on;
hr_utility.trace('start install_bal_types: ' || to_char(p_phase));
hrrunprc_trace_off;
	install_bal_types(p_phase);

	-- Localization hook
hrrunprc_trace_on;
hr_utility.trace('start hr_legislation_local: ' || to_char(p_phase));
hrrunprc_trace_off;
	hr_legislation_local.install(p_phase);

	-- Install hr org info details
hrrunprc_trace_on;
hr_utility.trace('start install_org_info: ' || to_char(p_phase));
hrrunprc_trace_off;
	install_org_info(p_phase);

	-- Install assignment extra info
hrrunprc_trace_on;
hr_utility.trace('start install_ass_info: ' || to_char(p_phase));
hrrunprc_trace_off;
	install_ass_info(p_phase);

	-- Install legislative field info
hrrunprc_trace_on;
hr_utility.trace('start install_leg_field: ' || to_char(p_phase));
hrrunprc_trace_off;
	install_leg_field(p_phase);

	-- Install monetary units
hrrunprc_trace_on;
hr_utility.trace('start install_monetary: ' || to_char(p_phase));
hrrunprc_trace_off;
	install_monetary(p_phase);

        -- install report_format_mappings
hrrunprc_trace_on;
hr_utility.trace('start install_report_mappings: ' || to_char(p_phase));
hrrunprc_trace_off;
	install_report_mappings(p_phase);

        -- install report_items
hrrunprc_trace_on;
hr_utility.trace('start install_report_items: ' || to_char(p_phase));
hrrunprc_trace_off;
	install_report_items(p_phase);

	-- install magnetic blocks and records
hrrunprc_trace_on;
hr_utility.trace('start install_magnetic_blocks: ' || to_char(p_phase));
hrrunprc_trace_off;
	install_magnetic_blocks(p_phase);

        -- install magnetic_records
hrrunprc_trace_on;
hr_utility.trace('start install_magnetic_records: ' || to_char(p_phase));
hrrunprc_trace_off;
	install_magnetic_records(p_phase);

	-- Install lookup types/codes/usages
	--
	-- Commented out. Lookups are no longer delivered by this code;
	-- they're now all delivered via Datamerge. RMF 27-Mar-96.
	--
	-- install_lookups(p_phase);
	--

	-- Check for any exceptions during above installation

	select count(*)
	into   v_exception_counter
	from   hr_stu_exceptions;

	IF v_exception_counter > 0 THEN
          --
          -- Output information for all rows in hr_stu_exceptions
          --
	    update hr_stu_history
	    set    status = 'Phase '||p_phase||' has exceptions raised'
	    where  package_name in
	           (select package_name
		   from   hr_s_history);

	ELSE -- number of exceptions = 0

	    -- No exceptions have been raised, phase must have been successful

	    IF p_phase = 2 THEN

		update hr_stu_history a
		set    a.status = 'Complete'
		where  exists
			(select null
			 from   hr_s_history b
			 where  b.package_name = a.package_name
			 and    b.date_of_export = a.date_of_export
			);

	    END IF;

	END IF; -- end exception check

      hrrunprc_trace_on;
      hr_utility.trace('exit hr_legislation.install: ' || to_char(p_phase));
      hrrunprc_trace_off;

    ELSE	-- error occured in maintain history
        rollback;

    END IF;

END install;


--****************************************************************************
-- INSTALLATION PROCEDURE FOR : ALL TL Tables
--****************************************************************************
   PROCEDURE install_att
   ---------------------
   IS
       -- Install all startup data for multilingual tables.
       -- They are:
       -- PAY_BALANCE_TYPES_TL
       -- PAY_ELEMENT_CLASSIFICATIONS_TL
       -- PAY_ELEMENT_TYPES_F_TL
       -- PAY_INPUT_VALUES_F_TL
       -- PAY_PAYMENT_TYPES_TL
       -- PER_ASSIGNMENT_STATUS_TYPES_TL
       -- PER_ASSIGNMENT_INFO_TYPES_TL
       -- PAY_MONETARY_UNITS_TL
       -- PAY_BALANCE_CATEGORIES_F_TL


       PROCEDURE install_pbtt
       ----------------------
       IS
            -- Seeds the PAY_BALANCE_TYPES_TL table.

            CURSOR c_input_values IS
            select
              BT.BALANCE_TYPE_ID,
              L.LANGUAGE_CODE TRANS_LANG,
              B.LANGUAGE_CODE BASE_LANG,
              BT.BALANCE_NAME,
              BT.REPORTING_NAME,
              BT.LAST_UPDATE_DATE,
              BT.LAST_UPDATED_BY,
              BT.LAST_UPDATE_LOGIN,
              BT.CREATED_BY,
              BT.CREATION_DATE
            from PAY_BALANCE_TYPES BT,
              FND_LANGUAGES L,
              FND_LANGUAGES B
            where L.INSTALLED_FLAG in ('I', 'B')
              and B.INSTALLED_FLAG = 'B'
              and NVL(TO_CHAR(BT.BUSINESS_GROUP_ID),'Null Value')='Null Value'
              and (
                  not exists (
                      select '1'
                        from pay_balance_types_tl btt
                        where btt.balance_type_id = bt.balance_type_id
                        and btt.language = l.language_code)
               or exists (select '1' from pay_balance_types_tl btt2
                          where btt2.balance_type_id = bt.balance_type_id
                          and   btt2.language = b.language_code
                          and   nvl(btt2.reporting_name,'XXX') <>
                                 nvl(bt.reporting_name,'XXX'))
              );

            l_counter NUMBER(3) := 0;

       BEGIN


            FOR l_rec IN c_input_values LOOP

            -- If reporting name for installed lang has changed then remove it
            -- before inserting updated reporting name for that installed lang
            -- Bug 3280179

            delete PAY_BALANCE_TYPES_TL
            where rowid in (select pbttl.rowid
             from pay_balance_types pbt,
                  pay_balance_types_tl pbttl
             where pbt.balance_type_id = pbttl.balance_type_id
             and nvl(pbt.reporting_name, 'XXX') <>
                 nvl(pbttl.reporting_name, 'XXX')
             and NVL(TO_CHAR(PBT.BUSINESS_GROUP_ID),'Null Value')='Null Value'
             and pbttl.BALANCE_TYPE_ID = l_rec.BALANCE_TYPE_ID
             and pbttl.language = l_rec.trans_lang);

            -- Insert all selected rows into the TL table.
            -- If the row exist in the TL table then it will be ignored.
            insert into PAY_BALANCE_TYPES_TL
            (
              BALANCE_TYPE_ID,
              LANGUAGE,
              SOURCE_LANG,
              BALANCE_NAME,
              REPORTING_NAME,
              LAST_UPDATE_DATE,
              LAST_UPDATED_BY,
              LAST_UPDATE_LOGIN,
              CREATED_BY,
              CREATION_DATE
            )
            select
              l_rec.BALANCE_TYPE_ID,
              l_rec.TRANS_LANG,
              l_rec.BASE_LANG,
              l_rec.BALANCE_NAME,
              l_rec.REPORTING_NAME,
              l_rec.LAST_UPDATE_DATE,
              l_rec.LAST_UPDATED_BY,
              l_rec.LAST_UPDATE_LOGIN,
              l_rec.CREATED_BY,
              l_rec.CREATION_DATE
            from dual
            where not exists (
                      select '1'
                        from pay_balance_types_tl btt
                       where btt.balance_type_id = l_rec.balance_type_id
                         and btt.language = l_rec.trans_lang);

            l_counter := l_counter + 1;
            IF l_counter = 100 THEN
              --COMMIT;
              l_counter := 0;
            END IF;

            END LOOP;

            --COMMIT;


       EXCEPTION
            -- Exception must handle the no_data_found error raised when no rows were
            -- found within select statement within the cursor declaration.
            WHEN no_data_found THEN
                 null;
            WHEN others THEN
                 RAISE;
       END install_pbtt;






       PROCEDURE install_pect
       ----------------------
       IS
            -- Seeds the PAY_ELEMENT_CLASSIFICATIONS_TL table.

            CURSOR c_input_values IS
            select
              EC.CLASSIFICATION_ID,
              EC.CLASSIFICATION_NAME,
              EC.DESCRIPTION,
              L.LANGUAGE_CODE TRANS_LANG,
              B.LANGUAGE_CODE BASE_LANG,
              EC.LAST_UPDATE_DATE,
              EC.LAST_UPDATED_BY,
              EC.LAST_UPDATE_LOGIN,
              EC.CREATED_BY,
              EC.CREATION_DATE
            from PAY_ELEMENT_CLASSIFICATIONS EC,
              FND_LANGUAGES L,
              FND_LANGUAGES B
            where L.INSTALLED_FLAG in ('I', 'B')
              and B.INSTALLED_FLAG = 'B'
              and NVL(TO_CHAR(EC.BUSINESS_GROUP_ID),'Null Value')='Null Value'
              and
              ( not exists (
                      select '1'
                        from PAY_ELEMENT_CLASSIFICATIONS_TL ECT
                       where ECT.CLASSIFICATION_ID = EC.CLASSIFICATION_ID
                         and ECT.language = l.language_code)
               or exists (select '1' from PAY_ELEMENT_CLASSIFICATIONS_TL ect2
                          where ect2.CLASSIFICATION_ID = ec.CLASSIFICATION_ID
                          and   ect2.language = b.language_code
               and  nvl( ect2.description,'ec.description' ||'1') <> nvl(ec.description,ect2.description || '-1'))
              );

            l_counter NUMBER(3) := 0;

       BEGIN


            FOR l_rec IN c_input_values LOOP

            delete PAY_ELEMENT_CLASSIFICATIONS_TL
            where rowid in (select ectl.rowid
             from PAY_ELEMENT_CLASSIFICATIONS ec,
                  PAY_ELEMENT_CLASSIFICATIONS_TL ectl
             where ec.CLASSIFICATION_ID = ectl.CLASSIFICATION_ID
             and nvl(ec.DESCRIPTION, 'XXX') <>
                 nvl(ectl.DESCRIPTION, 'XXX')
             and NVL(TO_CHAR(ec.BUSINESS_GROUP_ID),'Null Value')='Null Value'
             and ectl.CLASSIFICATION_ID = l_rec.CLASSIFICATION_ID
             and ectl.language = l_rec.trans_lang);

            -- Insert all selected rows into the TL table.
            -- If the row exist in the TL table then it will be ignored.
            insert into PAY_ELEMENT_CLASSIFICATIONS_TL
            (
            CLASSIFICATION_ID,
            CLASSIFICATION_NAME,
            DESCRIPTION,
            LANGUAGE,
            SOURCE_LANG,
            LAST_UPDATE_DATE,
            LAST_UPDATED_BY,
            LAST_UPDATE_LOGIN,
            CREATED_BY,
            CREATION_DATE
            )
            select
              l_rec.CLASSIFICATION_ID,
              l_rec.CLASSIFICATION_NAME,
              l_rec.DESCRIPTION,
              l_rec.TRANS_LANG,
              l_rec.base_lang,
              l_rec.LAST_UPDATE_DATE,
              l_rec.LAST_UPDATED_BY,
              l_rec.LAST_UPDATE_LOGIN,
              l_rec.CREATED_BY,
              l_rec.CREATION_DATE
            from dual
            where not exists (
                      select '1'
                        from PAY_ELEMENT_CLASSIFICATIONS_TL ECT
                       where ECT.CLASSIFICATION_ID = l_rec.CLASSIFICATION_ID
                         and ECT.language = l_rec.trans_lang);

            l_counter := l_counter + 1;
            IF l_counter = 100 THEN
              --COMMIT;
              l_counter := 0;
            END IF;

            END LOOP;

            --COMMIT;


       EXCEPTION
            -- Exception must handle the no_data_found error raised when no rows were
            -- found within select statement within the cursor declaration.
            WHEN no_data_found THEN
                 null;
            WHEN others THEN
                 RAISE;

       END install_pect;





       PROCEDURE install_petft
       ----------------------
       IS
            -- Seeds the PAY_ELEMENT_TYPES_F_TL table.

            CURSOR c_input_values IS
            select
              ET.ELEMENT_TYPE_ID,
              ET.ELEMENT_NAME,
              ET.REPORTING_NAME,
              ET.DESCRIPTION,
              L.LANGUAGE_CODE TRANS_LANG,
              B.LANGUAGE_CODE BASE_LANG,
              ET.LAST_UPDATE_DATE,
              ET.LAST_UPDATED_BY,
              ET.LAST_UPDATE_LOGIN,
              ET.CREATED_BY,
              ET.CREATION_DATE
            from PAY_ELEMENT_TYPES_F ET,
              FND_LANGUAGES L,
              FND_LANGUAGES B
            where L.INSTALLED_FLAG in ('I', 'B')
              and B.INSTALLED_FLAG = 'B'
              and NVL(TO_CHAR(ET.BUSINESS_GROUP_ID),'Null Value')='Null Value'
              and
              (       not exists (
                      select '1'
                        from PAY_ELEMENT_TYPES_F_TL ETT
                       where ETT.ELEMENT_TYPE_ID = ET.ELEMENT_TYPE_ID
                         and ETT.language = l.language_code)
               or exists (select '1' from PAY_ELEMENT_TYPES_F_TL ett2
                          where ett2.ELEMENT_TYPE_ID = et.ELEMENT_TYPE_ID
                          and   ett2.language = b.language_code
                          and   (nvl(ett2.reporting_name, 'XXX') <> nvl(et.reporting_name, 'XXX')
                                 or
                                 nvl(ett2.description, 'XXX') <> nvl(et.description, 'XXX')))
              );

            l_counter NUMBER(3) := 0;

       BEGIN

            FOR l_rec IN c_input_values LOOP

            -- If reporting name or description field for installed lang
            -- has changed then remove it before inserting updated
            -- value for that installed lang
            -- Bug 3280179

            delete PAY_ELEMENT_TYPES_F_TL
            where rowid in (select pettl.rowid
             from pay_element_types_f pet,
                  pay_element_types_f_tl pettl
             where pet.element_type_id = pettl.element_type_id
             and (
                  (nvl(pet.reporting_name, 'XXX') <>
                   nvl(pettl.reporting_name, 'XXX'))
                 or
                  (nvl(pet.description, 'XXX') <>
                   nvl(pettl.description, 'XXX'))
                 )
             and NVL(TO_CHAR(PET.BUSINESS_GROUP_ID),'Null Value')='Null Value'
             and pettl.ELEMENT_TYPE_ID = l_rec.ELEMENT_TYPE_ID
             and pettl.language = l_rec.trans_lang);

            -- Insert all selected rows into the TL table.
            -- If the row exist in the TL table then it will be ignored.

            insert into PAY_ELEMENT_TYPES_F_TL
            (
            ELEMENT_TYPE_ID,
            ELEMENT_NAME,
            REPORTING_NAME,
            DESCRIPTION,
            LANGUAGE,
            SOURCE_LANG,
            LAST_UPDATE_DATE,
            LAST_UPDATED_BY,
            LAST_UPDATE_LOGIN,
            CREATED_BY,
            CREATION_DATE
            )
            select
              l_rec.ELEMENT_TYPE_ID,
              l_rec.ELEMENT_NAME,
              l_rec.REPORTING_NAME,
              l_rec.DESCRIPTION,
              l_rec.TRANS_LANG,
              l_rec.base_lang,
              l_rec.LAST_UPDATE_DATE,
              l_rec.LAST_UPDATED_BY,
              l_rec.LAST_UPDATE_LOGIN,
              l_rec.CREATED_BY,
              l_rec.CREATION_DATE
            from dual
            where not exists (
                      select '1'
                        from PAY_ELEMENT_TYPES_F_TL ETT
                       where ETT.ELEMENT_TYPE_ID = l_rec.ELEMENT_TYPE_ID
                         and ETT.language = l_rec.trans_lang);

            l_counter := l_counter + 1;
            IF l_counter = 100 THEN
              --COMMIT;
              l_counter := 0;
            END IF;

            END LOOP;

            --COMMIT;


       EXCEPTION
            -- Exception must handle the no_data_found error raised when no rows were
            -- found within select statement within the cursor declaration.
            WHEN no_data_found THEN
                 null;
            WHEN others THEN
                 RAISE;

       END install_petft;




       PROCEDURE install_pivft
       -----------------------
       IS
            -- Seeds the PAY_INPUT_VALUES_F_TL table.

            CURSOR c_input_values IS
            select
              IV.INPUT_VALUE_ID,
              IV.NAME,
              L.LANGUAGE_CODE TRANS_LANG,
              B.LANGUAGE_CODE BASE_LANG,
              IV.LAST_UPDATE_DATE,
              IV.LAST_UPDATED_BY,
              IV.LAST_UPDATE_LOGIN,
              IV.CREATED_BY,
              IV.CREATION_DATE
            from PAY_INPUT_VALUES_F IV,
              FND_LANGUAGES L,
              FND_LANGUAGES B
            where  L.INSTALLED_FLAG in ('I', 'B')
              and B.INSTALLED_FLAG = 'B'
              and NVL(TO_CHAR(IV.BUSINESS_GROUP_ID),'Null Value')='Null Value'
              and not exists (
                      select '1'
                        from PAY_INPUT_VALUES_F_TL IVT
                       where IVT.INPUT_VALUE_ID = IV.INPUT_VALUE_ID
                         and IVT.language = l.language_code);

            l_counter NUMBER(3) := 0;
            l_translated_value VARCHAR2(80);

       BEGIN


            FOR l_rec IN c_input_values LOOP


            -- bug 1234525 - insert translated value for pay_value input type
            if (replace(upper(l_rec.NAME),' ','_')='PAY_VALUE')
            then
              select flv.meaning
	      into l_translated_value
              from fnd_lookup_values       flv
              where flv.lookup_type = 'NAME_TRANSLATIONS'
              and     flv.lookup_code = 'PAY VALUE'
              and     flv.view_application_id = 3
              and     flv.security_group_id = 0
              and     flv.language = l_rec.trans_lang;
            else
                l_translated_value:=l_rec.NAME;
            end if;
            -- Insert all selected rows into the TL table.
            -- If the row exist in the TL table then it will be ignored.
            insert into PAY_INPUT_VALUES_F_TL
            (
            INPUT_VALUE_ID,
            NAME,
            LANGUAGE,
            SOURCE_LANG,
            LAST_UPDATE_DATE,
            LAST_UPDATED_BY,
            LAST_UPDATE_LOGIN,
            CREATED_BY,
            CREATION_DATE
            )
            select
              l_rec.INPUT_VALUE_ID,
              l_translated_value,
              l_rec.TRANS_LANG,
              l_rec.base_lang,
              l_rec.LAST_UPDATE_DATE,
              l_rec.LAST_UPDATED_BY,
              l_rec.LAST_UPDATE_LOGIN,
              l_rec.CREATED_BY,
              l_rec.CREATION_DATE
            from dual
            where not exists (
                      select '1'
                        from PAY_INPUT_VALUES_F_TL IVT
                       where IVT.INPUT_VALUE_ID = l_rec.INPUT_VALUE_ID
                         and IVT.language = l_rec.trans_lang);

            l_counter := l_counter + 1;
            IF l_counter = 100 THEN
              --COMMIT;
              l_counter := 0;
            END IF;

            END LOOP;

            --COMMIT;


       EXCEPTION
            -- Exception must handle the no_data_found error raised when no rows
            -- found within select statement within the cursor declaration.
            WHEN no_data_found THEN
                 null;
            WHEN others THEN
                 RAISE;

       END install_pivft;

       PROCEDURE install_pptt
       ----------------------
       IS
            -- Seeds the PAY_PAYMENT_TYPES_TL table.

            CURSOR c_input_values IS
            select
              PT.PAYMENT_TYPE_ID,
              PT.PAYMENT_TYPE_NAME,
              PT.DESCRIPTION,
              L.LANGUAGE_CODE TRANS_LANG,
              B.LANGUAGE_CODE BASE_LANG,
              PT.LAST_UPDATE_DATE,
              PT.LAST_UPDATED_BY,
              PT.LAST_UPDATE_LOGIN,
              PT.CREATED_BY,
              PT.CREATION_DATE
            from PAY_PAYMENT_TYPES PT,
              FND_LANGUAGES L,
              FND_LANGUAGES B
            where L.INSTALLED_FLAG in ('I', 'B')
              and B.INSTALLED_FLAG = 'B'
              and not exists (
                      select '1'
                        from PAY_PAYMENT_TYPES_TL PTT
                       where PTT.PAYMENT_TYPE_ID = PT.PAYMENT_TYPE_ID
                         and PTT.language = l.language_code);

            l_counter NUMBER(3) := 0;

       BEGIN


            FOR l_rec IN c_input_values LOOP

            -- Insert all selected rows into the TL table.
            -- If the row exist in the TL table then it will be ignored.
            insert into PAY_PAYMENT_TYPES_TL
            (
            PAYMENT_TYPE_ID,
            PAYMENT_TYPE_NAME,
            DESCRIPTION,
            LANGUAGE,
            SOURCE_LANG,
            LAST_UPDATE_DATE,
            LAST_UPDATED_BY,
            LAST_UPDATE_LOGIN,
            CREATED_BY,
            CREATION_DATE
            )
            select
              l_rec.PAYMENT_TYPE_ID,
              l_rec.PAYMENT_TYPE_NAME,
              l_rec.DESCRIPTION,
              l_rec.TRANS_LANG,
              l_rec.base_lang,
              l_rec.LAST_UPDATE_DATE,
              l_rec.LAST_UPDATED_BY,
              l_rec.LAST_UPDATE_LOGIN,
              l_rec.CREATED_BY,
              l_rec.CREATION_DATE
            from dual
            where not exists (
                      select '1'
                        from PAY_PAYMENT_TYPES_TL PTT
                       where PTT.PAYMENT_TYPE_ID = l_rec.PAYMENT_TYPE_ID
                         and PTT.language = l_rec.trans_lang);

            l_counter := l_counter + 1;
            IF l_counter = 100 THEN
              --COMMIT;
              l_counter := 0;
            END IF;

            END LOOP;

            --COMMIT;


       EXCEPTION
            -- Exception must handle the no_data_found error raised when no rows
            -- were found within select statement within the cursor declaration.
            WHEN no_data_found THEN
                 null;
            WHEN others THEN
                 RAISE;

       END install_pptt;





       PROCEDURE install_paitt
       ----------------------
       IS
            -- Seeds the PER_ASSIGNMENT_INFO_TYPES_TL table.

            CURSOR c_input_values IS
            select
              M.INFORMATION_TYPE,
              L.LANGUAGE_CODE TRANS_LANG,
              B.LANGUAGE_CODE BASE_LANG,
              M.DESCRIPTION,
              M.LAST_UPDATE_DATE,
              M.LAST_UPDATED_BY,
              M.LAST_UPDATE_LOGIN,
              M.CREATED_BY,
              M.CREATION_DATE
            from PER_ASSIGNMENT_INFO_TYPES M,
              FND_LANGUAGES L,
              FND_LANGUAGES B
            where L.INSTALLED_FLAG in ('I', 'B')
              and B.INSTALLED_FLAG = 'B'
              and not exists ( select '1'
                                 from per_assignment_info_types_tl pait
                                where pait.information_type = m.information_type
                                  and pait.language         = l.language_code);

            l_counter NUMBER(3) := 0;

       BEGIN


            FOR l_rec IN c_input_values LOOP

            -- Insert all selected rows into the TL table.
            -- If the row exist in the TL table then it will be ignored.
            insert into PER_ASSIGNMENT_INFO_TYPES_TL
            (
            INFORMATION_TYPE,
            LANGUAGE,
            SOURCE_LANG,
            DESCRIPTION,
            LAST_UPDATE_DATE,
            LAST_UPDATED_BY,
            LAST_UPDATE_LOGIN,
            CREATED_BY,
            CREATION_DATE
            )
            select
              l_rec.INFORMATION_TYPE,
              l_rec.TRANS_LANG,
              l_rec.base_lang,
              l_rec.DESCRIPTION,
              l_rec.LAST_UPDATE_DATE,
              l_rec.LAST_UPDATED_BY,
              l_rec.LAST_UPDATE_LOGIN,
              l_rec.CREATED_BY,
              l_rec.CREATION_DATE
            from dual
            where not exists ( select '1'
                                 from per_assignment_info_types_tl pait
                                where pait.information_type =
                                                        l_rec.information_type
                                  and pait.language         = l_rec.trans_lang);

            l_counter := l_counter + 1;
            IF l_counter = 100 THEN
              --COMMIT;
              l_counter := 0;
            END IF;

            END LOOP;

            --COMMIT;


       EXCEPTION
            -- Exception must handle the no_data_found error raised when no rows
            -- were found within select statement within the cursor declaration.
            WHEN no_data_found THEN
                 null;
            WHEN others THEN
                 RAISE;

       END install_paitt;





       PROCEDURE install_pastt
       ----------------------
       IS
            -- Seeds the PER_ASSIGNMENT_STATUS_TYPES_TL table.

            CURSOR c_input_values IS
            select
              M.ASSIGNMENT_STATUS_TYPE_ID,
              L.LANGUAGE_CODE TRANS_LANG,
              B.LANGUAGE_CODE BASE_LANG,
              M.USER_STATUS,
              M.LAST_UPDATE_DATE,
              M.LAST_UPDATED_BY,
              M.LAST_UPDATE_LOGIN,
              M.CREATED_BY,
              M.CREATION_DATE
            from PER_ASSIGNMENT_STATUS_TYPES M,
              FND_LANGUAGES L,
              FND_LANGUAGES B
            where L.INSTALLED_FLAG in ('I', 'B')
              and B.INSTALLED_FLAG = 'B'
              and NVL(TO_CHAR(M.BUSINESS_GROUP_ID),'Null Value')='Null Value'
              and not exists (
                      select '1'
                        from per_assignment_status_types_tl past
                       where past.assignment_status_type_id =
                                              m.assignment_status_type_id
                         and past.language = l.language_code);

            l_counter NUMBER(3) := 0;

       BEGIN


            FOR l_rec IN c_input_values LOOP

            -- Insert all selected rows into the TL table.
            -- If the row exist in the TL table then it will be ignored.
            insert into PER_ASSIGNMENT_STATUS_TYPES_TL
            (
            ASSIGNMENT_STATUS_TYPE_ID,
            LANGUAGE,
            SOURCE_LANG,
            USER_STATUS,
            LAST_UPDATE_DATE,
            LAST_UPDATED_BY,
            LAST_UPDATE_LOGIN,
            CREATED_BY,
            CREATION_DATE
            )
            select
              l_rec.ASSIGNMENT_STATUS_TYPE_ID,
              l_rec.TRANS_LANG,
              l_rec.base_lang,
              l_rec.USER_STATUS,
              l_rec.LAST_UPDATE_DATE,
              l_rec.LAST_UPDATED_BY,
              l_rec.LAST_UPDATE_LOGIN,
              l_rec.CREATED_BY,
              l_rec.CREATION_DATE
            from dual
            where not exists (
                      select '1'
                        from per_assignment_status_types_tl past
                       where past.assignment_status_type_id =
                                             l_rec.assignment_status_type_id
                         and past.language = l_rec.trans_lang);

            l_counter := l_counter + 1;
            IF l_counter = 100 THEN
              --COMMIT;
              l_counter := 0;
            END IF;

            END LOOP;

            --COMMIT;


       EXCEPTION
            -- Exception must handle the no_data_found error raised when no rows
            -- were found within select statement within the cursor declaration.
            WHEN no_data_found THEN
                 null;
            WHEN others THEN
                 RAISE;

       END install_pastt;
--
       PROCEDURE install_pmut
       ----------------------
       IS
            -- Seeds the PAY_MONETARY_UNITS_TL table.

            CURSOR c_monetary_units IS
            select
              M.MONETARY_UNIT_ID,
              L.LANGUAGE_CODE TRANS_LANG,
              B.LANGUAGE_CODE BASE_LANG,
              M.MONETARY_UNIT_NAME,
              M.LAST_UPDATE_DATE,
              M.LAST_UPDATED_BY,
              M.LAST_UPDATE_LOGIN,
              M.CREATED_BY,
              M.CREATION_DATE
            from PAY_MONETARY_UNITS M,
                 FND_LANGUAGES L,
                 FND_LANGUAGES B
            where L.INSTALLED_FLAG in ('I', 'B')
              and B.INSTALLED_FLAG = 'B'
              and NVL(TO_CHAR(M.BUSINESS_GROUP_ID),'Null Value')='Null Value'
              and not exists (
                      select '1'
                        from PAY_MONETARY_UNITS_TL pmut
                       where pmut.monetary_unit_id =
                                              m.monetary_unit_id
                         and pmut.language = l.language_code);

            l_counter NUMBER(3) := 0;

       BEGIN


            FOR l_rec IN c_monetary_units LOOP

            -- Insert all selected rows into the TL table.
            -- If the row exist in the TL table then it will be ignored.
            insert into PAY_MONETARY_UNITS_TL
            (
            MONETARY_UNIT_ID,
            LANGUAGE,
            SOURCE_LANG,
            MONETARY_UNIT_NAME,
            LAST_UPDATE_DATE,
            LAST_UPDATED_BY,
            LAST_UPDATE_LOGIN,
            CREATED_BY,
            CREATION_DATE
            )
            select
              l_rec.MONETARY_UNIT_ID,
              l_rec.TRANS_LANG,
              l_rec.base_lang,
              l_rec.MONETARY_UNIT_NAME,
              l_rec.LAST_UPDATE_DATE,
              l_rec.LAST_UPDATED_BY,
              l_rec.LAST_UPDATE_LOGIN,
              l_rec.CREATED_BY,
              l_rec.CREATION_DATE
            from dual
            where not exists (
                      select '1'
                        from PAY_MONETARY_UNITS_TL pmut
                       where pmut.monetary_unit_id =
                                              l_rec.monetary_unit_id
                         and pmut.language = l_rec.trans_lang);

            l_counter := l_counter + 1;
            IF l_counter = 100 THEN
              --COMMIT;
              l_counter := 0;
            END IF;

            END LOOP;

            --COMMIT;


       EXCEPTION
            -- Exception must handle the no_data_found error raised when no rows
            -- were found within select statement within the cursor declaration.
            WHEN no_data_found THEN
                 null;
            WHEN others THEN
                 RAISE;
       END install_pmut;
--
       PROCEDURE install_pbct
       ----------------------
       IS
            -- Seeds the PAY_BALANCE_CATEGORIES_F_TL table.

            CURSOR c_balance_categories IS
            select
              bc.BALANCE_CATEGORY_ID,
              L.LANGUAGE_CODE TRANS_LANG,
              B.LANGUAGE_CODE BASE_LANG,
              bc.CATEGORY_NAME,
              bc.LAST_UPDATE_DATE,
              bc.LAST_UPDATED_BY,
              bc.LAST_UPDATE_LOGIN,
              bc.CREATED_BY,
              bc.CREATION_DATE
            from PAY_BALANCE_CATEGORIES_F bc,
                 FND_LANGUAGES L,
                 FND_LANGUAGES B
            where L.INSTALLED_FLAG in ('I', 'B')
              and B.INSTALLED_FLAG = 'B'
              and not exists (
                      select '1'
                        from PAY_BALANCE_CATEGORIES_F_TL bct
                       where bct.BALANCE_CATEGORY_ID = bc.BALANCE_CATEGORY_ID
                         and bct.language = l.language_code);

            l_counter NUMBER(3) := 0;

       BEGIN


            FOR l_rec IN c_balance_categories LOOP

            -- Insert all selected rows into the TL table.
            -- If the row exist in the TL table then it will be ignored.
            insert into PAY_BALANCE_CATEGORIES_F_TL
            (
            BALANCE_CATEGORY_ID,
            LANGUAGE,
            SOURCE_LANG,
            USER_CATEGORY_NAME,
            LAST_UPDATE_DATE,
            LAST_UPDATED_BY,
            LAST_UPDATE_LOGIN,
            CREATED_BY,
            CREATION_DATE
            )
            select
              l_rec.BALANCE_CATEGORY_ID,
              l_rec.TRANS_LANG,
              l_rec.base_lang,
              l_rec.CATEGORY_NAME,
              l_rec.LAST_UPDATE_DATE,
              l_rec.LAST_UPDATED_BY,
              l_rec.LAST_UPDATE_LOGIN,
              l_rec.CREATED_BY,
              l_rec.CREATION_DATE
            from dual
            where not exists (
                      select '1'
                        from PAY_BALANCE_CATEGORIES_F_TL bct
                       where bct.BALANCE_CATEGORY_ID = l_rec.BALANCE_CATEGORY_ID
                         and bct.language = l_rec.trans_lang);

            l_counter := l_counter + 1;
            IF l_counter = 100 THEN
              --COMMIT;
              l_counter := 0;
            END IF;

            END LOOP;

            --COMMIT;


       EXCEPTION
            -- Exception must handle the no_data_found error raised when no rows
            -- were found within select statement within the cursor declaration.
            WHEN no_data_found THEN
                 null;
            WHEN others THEN
                 RAISE;
       END install_pbct;
--

    BEGIN

       -- Install the startup data for all the required 'TL' tables.

       install_pbtt;
       install_pect;
       install_petft;
       install_pivft;
       install_pptt;
       install_paitt;
       install_pastt;
       install_pmut;
       install_pbct;

    END install_att;

--****************************************************************************
-- END OF PROCEDURE
--****************************************************************************



--****************************************************************************
-- ENTRY POINT FOR THE AUTOMATIC INSTALLATION/DELIVERY OF STARTUP DATA
--****************************************************************************

PROCEDURE install
-----------------
IS

   cursor c_main is
     select distinct legislation_code
     from hr_s_history;

   v_exception_counter number (15);

   -- This install procedure calls the parameterised install procedure.
   -- The order of processing is as follows:
   --	1. call install in phase 1
   --   2. if exceptions exist, rollback, warn user and exit.
   --   3. call install in phase 2
   --   4. if exceptions exist, rollback, warn user and exit.
   --   5. commit.

l_leg_code VARCHAR2(3);

BEGIN

  ff_data_dict.disable_ffuebru_trig;

  -- call installation in phase 1

  g_debug_cnt := 0;

  select count(*)
  into g_debug_cnt
  from pay_patch_status
  where patch_name = 'HRGLOBAL_DEBUG';

  install(1);

  -- check for the existance of any exceptions after phase 1

  hr_utility.set_Location('hr_legislation.install2',20);

  select count(*)
  into   v_exception_counter
  from   hr_stu_exceptions;

  IF v_exception_counter > 0 THEN

    hr_utility.set_message(801,'HR_7129_STARTUP_EXCEPTIONS');
    hr_utility.set_message_token('PHASE_NUMBER','1');
    hr_utility.raise_error;

  END IF;

  -- perform phase 2 of the installation

  hr_utility.set_Location('hr_legislation.install2',40);

  install(2);

  -- check for the existance of exceptions after phase 2

  hr_utility.set_Location('hr_legislation.install2',50);

  select count(*)
  into   v_exception_counter
  from   hr_stu_exceptions;

  IF v_exception_counter > 0 THEN

    hr_utility.set_message(801,'HR_7129_STARTUP_EXCEPTIONS');
    hr_utility.set_message_token('PHASE_NUMBER','2');
    hr_utility.raise_error;

  END IF;

  -- Move the hr_s_application_ownership data to the HR_APPLICATION_OWNERSHIP
  -- tables for the International Payroll project (leg_code ZZ)

  BEGIN
    select distinct legislation_code
    into   l_leg_code
    from   hr_s_history
    where  legislation_code = 'ZZ';

    create_zz_leg_rule;

  EXCEPTION WHEN OTHERS THEN NULL;
  END;

  -- Populate the TL tables with the installed data.
  install_att;

  -- The whole installation was performed with no exceptions
  -- so it is now safe to commit.

  ff_data_dict.enable_ffuebru_trig;
  commit;

END install;

END hr_legislation;


/
