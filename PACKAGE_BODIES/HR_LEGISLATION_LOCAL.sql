--------------------------------------------------------
--  DDL for Package Body HR_LEGISLATION_LOCAL
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."HR_LEGISLATION_LOCAL" AS
/* $Header: pelegloc.pkb 120.1.12000000.1 2007/01/21 23:59:37 appldev ship $ */
--
-- Copyright (c) Oracle Corporation 1991, 1992, 1993. All rights reserved.
--
-- NAME : hr_legislation_local.pkb
--
-- DESCRIPTION
--	Procedures used for the delivery of legislative startup data. The
--	same procedures are also used for legislative refreshes.
--	This package is used to make specific calls to packages or procedures
--	created by localization teams.
-- MODIFIED
--  	80.1  Ian Carline  14-09-1993	- Created
--	80.2  Ian Carline  15-11-1993   - Debugged for US Bechtel delivery
--	80.3  Ian Carline  23-11-1993   - Removed Geocodes logic
--	80.4  Ian Carline  07-12-1993   - Added show errors logic Geocodes logic
--	80.5  Rod Fine     16-12-1993   - Put AS on same line as CREATE stmt
--					  to workaround export WWBUG #178613.
--
--      70.6  Ian Carline  06-jun-1994  - per 7.0 and 8.0 merged.
--                                        rewrite.
--      70.8  Ian Carline  04-Aug-1994  - Added GB specific logic to delete
--                                        from some control tables when payroll
--                                        is not installed.
--	70.9  Rod Fine     06-Oct-1994  - Added column FS_LOOKUP_TYPE to
--					  PAY_STATE_RULES table installation
--					  procedure.
--	70.10 Rod Fine     23-Mar-1995  - Added column CLASSIFICATION_ID to
--					  PAY_TAXABILITY_RULES table
--					  installation procedure.
--	70.11 Rod Fine     07-Apr-1995  - Added extra check on classification_id
--					  to PAY_TAXABILITY_RULES transfer_row
--					  procedure.
-- 70.12  rfine     27-Mar-96  353225	When delivering PAY_STATE_RULES, update
--					the row if it already exists, rather
--					than simply not delivering it.
--    70.12  M. Stewart    23-Sep-1996  - Updated table names from STU_ to HR_S_
--    70.13  Tim Eyres	   02-Jan-1997  - Moved arcs header to directly after
--                                      'create or replace' line
--                                      Fix to bug 434902
--    70.15  Tim Eyres     02-Jan-1997  Correction to version number
--     110.1    mstewart    23-07-1997  Removed show error and select from
--                                      user errors statements (R11)
--                                      (R10 version # 70.16)
--     115.1    RAMURTHY    17-03-1999  Modified procedure install_tax_rules
--                                      to insert with taxability_rules_date_id
--                                      and legislation_code, since these new
--                                      column are not in startup yet.  This is
--                                      a temporary fix.
--     115.12   VMehta      14-06-1999  Commented out code to get the formula id
--                                      while inserting into
--                                      pay_magnetic_records in
--                                      install_us_new procedure
--     115.13   MReid       24-06-1999  Added missing columns to report format
--                                      mappings
--     115.14   meshah/vmehta  09-29-1999 Modified install_us_new procedure
--                                      added the logic to include hr_report_
--			                      		lookups in the startup data.
--                                      Added logic to conditionally insert data into
--                                      JIT Tables. The data is to be inserted only if
--                                      this is a fresh install (not to be done during
--                                      upgrade from a previous release).
--     115.15   tbattoo     27-oct-1999 Removed installation of hr_magnetic_blocks,
--					hr_s_magnetic_Records,
--					hr_s_report_format_mappings
--					They have been added to pelegins.pkb
--    115.16     vmehta     10-nov-1999  Added two new functions
--                                       (decode_us_element_information and
--                                       translate_us_ele_dev_df) to tranfer the
--                                       balance_type_id and element_type_id
--                                       stored in the element_information*
--                                       columns of pay_element_types_f table
--    115.17     vmehta     26-dec-1999  Changed function install_us_new to
--                                       correctly populate the ids in various
--                                       tables to maintain a history of the
--                                       date-tracked changes in the correct
--                                       fashion
--    115.18     vmehta     03-feb-2000  Modified install_us_new to delete from
--                                       the tables only if need to transfer
--                                       data
--    115.19     tbattoo    08-Feb-2000  changed crt_exc so calls
--                                       hr_legislation.insert_hr_stu_exceptions
--    115.20     RThirlby   11-APR-2000  Added translate_ca_ele_dev_df. This is
--                                       a copy of translate_us_ele_dev_df
--                                       modified for CA use.
--    115.22     RThirlby   16-JUN-2000  Modifiled install_tax_rules so that it
--                                       can be used by Canada.
--    115.23     JARTHURT   28-OCT-2000  Modified procedure install_tax_rules
--                                       to insert with taxability_rules_date_id
--                                       and legislation_code for Canadian
--                                       legislation as it currently works for
--                                       US.
--    115.24     VMEHTA     31-OCT-2000  Modified install_us_new to correctly
--                                       install garnishment_fee_rules
--                                       (pay_us_garn_fee_rules_f). Inserted the
--                                       logic to exit from the pgfr loop when
--                                       a record is found and also to set the
--                                       gfr_exist flag to 'N' at the beginning
--                                       of each iteration of the gfr loop.
--                                       Ref Bug 1459362.
--    115.25     ALOGUE     06-NOV-2000  Only installs legislation_rules from
--                                       hr_s tables if the pay table is empty.
--    115.26    SSattini    30-Jan-2001  Modified procedure install_tax_rules
--                                       to fix bug: 1618263. Pay_Taxability_
--                                       rules data not installed for
--                                       legislation_code 'CA' if there is
--                                       another legislation_code data already
--                                       installed.
--    115.27    divicker     May 2001    Support for parallel hrglobal
--    115.28    divicker     01-Jun-2001 Fix to install_tax_rules
--    115.29    divicker     05-Jun-2001 Added valid_date_from,to to
--                                       ID selection in install_tax_rules
--    115.30    vmehta       12-Jun-2001 Commented out delivering of US JIT
--                                       data from install_us_new proc.
--                                       This is now done through the
--                                       'parallel' hrglobal.drv
--    115.31    divicker     25-OCT-2001 remove commented out code
--    115.32    divicker     21-NOV-2001 performance
--    115.33    ekim         06-MAY-2002 Removed update of
--                                       WC_EXECUTIVE_WEEKLY_MAX
--                                       in install_state_rules procedure.
--    115.34    divicker     09-MAY-2002 Support for dual rule_mode LEG_RULES
--    115.35    divicker     09-MAY-2002 dbdrv added
--    115.36    pganguly     31-MAY-2002 Added a call to install_us_new in
--                                       the Canadian section.
--    115.37    pganguly     13-JUN-2002 Added set verify off/whenever
--                                       oserror
--    115.38    mreid        24-JUN-2002 Modified update_uid for wc surcharge
--                                       due to bug 2429360
--    115.39    pganguly     18-JUL-2002 Removed the call to install_us_new
--                                       from Canadian Section.
--    115.40    divicker     15-JUL-2003 Added support for translation of
--                                       CWK_S rule types in pay_leg_rules
--    115.41    ahanda       16-OCT-2004 Changed procedure install_us_new
--                                       The values assigned to hr_s_tab and
--                                       pay_tab were not in sync causing an
--                                       issue (Bug 3955832).
--    115.42    divicker     24-FEB-2005 Trace improvements.
--    115.43    divicker     10-AUG-2005 Debug switch
------------------------------------------------------------------------------

   driving_legislation varchar2(30);

--****************************************************************************
-- INSTALLATION PROCEDURE FOR : PAY_STATE_RULES
--****************************************************************************

PROCEDURE install_state_rules(p_phase IN number)
------------------------------------------------
IS
    -- Install procedure to transfer startup state tax rules into the live
    -- tables. This routine is written purely for the US localization team.
    -- The object PAY_STATE_RULES is used only in the US payroll system

    l_null_return varchar2(1); 		-- For 'select null' statements
    l_new_surrogate_key number(15); 	-- New surrogate key for the delivery row


    CURSOR stu			-- Selects all rows from startup entity
    IS
   	select STATE_CODE c_true_key
   	,      FIPS_CODE
   	,      NAME
   	,      JURISDICTION_CODE
   	,      HEAD_TAX_PERIOD
   	,      WC_EXECUTIVE_WEEKLY_MAX
   	,      FS_LOOKUP_TYPE
   	,      LAST_UPDATE_DATE
   	,      LAST_UPDATED_BY
   	,      LAST_UPDATE_LOGIN
   	,      CREATED_BY
   	,      CREATION_DATE
   	,      rowid
   	from   hr_s_state_rules;

    stu_rec stu%ROWTYPE;

    PROCEDURE remove
    ----------------
    IS

    -- Remove a row from either the startup tables or the installed tables

    BEGIN


        delete from hr_s_state_rules
        where  rowid = stu_rec.rowid;

    END remove;

    PROCEDURE transfer_row
    ----------------------
    IS
	-- Check if a delivered row is needed and insert into the
	-- live tables if it is

    BEGIN


	IF p_phase = 1 THEN
	    return;
	END IF;


	--
	-- #353225. See if the state information exists. If so then update it.
	-- This is new code put in at the request of
	-- US Pay - previously the code wouldn't handle updates - it
	-- only inserted new rows. RMF 27-Mar-96.
	--

	update pay_state_rules
	set    FIPS_CODE		= stu_rec.FIPS_CODE
	,      NAME			= stu_rec.NAME
	,      JURISDICTION_CODE	= stu_rec.JURISDICTION_CODE
	,      HEAD_TAX_PERIOD		= stu_rec.HEAD_TAX_PERIOD
	,      FS_LOOKUP_TYPE		= stu_rec.FS_LOOKUP_TYPE
	,      LAST_UPDATE_DATE		= stu_rec.LAST_UPDATE_DATE
	,      LAST_UPDATED_BY		= stu_rec.LAST_UPDATED_BY
	,      LAST_UPDATE_LOGIN	= stu_rec.LAST_UPDATE_LOGIN
	,      CREATED_BY		= stu_rec.CREATED_BY
   	,      CREATION_DATE		= stu_rec.CREATION_DATE
   	where  state_code		= stu_rec.c_true_key;

   	IF SQL%NOTFOUND THEN

	    -- Row does not exist so insert


	    insert into pay_state_rules
	    (STATE_CODE
	    ,FIPS_CODE
	    ,NAME
	    ,JURISDICTION_CODE
	    ,HEAD_TAX_PERIOD
	    ,WC_EXECUTIVE_WEEKLY_MAX
   	    ,FS_LOOKUP_TYPE
	    ,LAST_UPDATE_DATE
	    ,LAST_UPDATED_BY
	    ,LAST_UPDATE_LOGIN
	    ,CREATED_BY
	    ,CREATION_DATE
	    )
	    values
	    (stu_rec.c_true_key
	    ,stu_rec.FIPS_CODE
	    ,stu_rec.NAME
	    ,stu_rec.JURISDICTION_CODE
	    ,stu_rec.HEAD_TAX_PERIOD
	    ,stu_rec.WC_EXECUTIVE_WEEKLY_MAX
	    ,stu_rec.FS_LOOKUP_TYPE
	    ,stu_rec.LAST_UPDATE_DATE
	    ,stu_rec.LAST_UPDATED_BY
	    ,stu_rec.LAST_UPDATE_LOGIN
	    ,stu_rec.CREATED_BY
	    ,stu_rec.CREATION_DATE
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

    FOR delivered IN stu LOOP

	-- Uses main cursor stu to impilicity define a record


	savepoint new_state_rule;

	stu_rec := delivered;


	transfer_row;

    END LOOP;

END install_state_rules;

--****************************************************************************
-- INSTALLATION PROCEDURE FOR : PAY_TAXABILITY_RULES
--****************************************************************************

PROCEDURE install_tax_rules(p_phase IN number)
----------------------------------------------
IS
   -- Install procedure to transfer startup taxability rules into the live
   -- tables. This routine is written purely for the US localization team.
   -- The object PAY_TAXABILITY_RULES is used only in the US payroll system
   --
   -- Canadian Payroll also uses pay_taxability_rules, so I have updated
   -- RM's changes so they can be used for CA.

   l_null_return varchar2(1);		-- For 'select null' statements
   l_new_surrogate_key number(15); 	-- New surrogate key for the delivery row


/* *** */   l_trd_id number;
    l_num_rules number;
    l_leg_code varchar2(5);

    CURSOR stu			-- Selects all rows from startup entity
    IS

   	select jurisdiction_code
   	,      tax_type
   	,      tax_category
   	,      classification_id
   	,      last_update_date
   	,      last_updated_by
   	,      last_update_login
   	,      created_by
   	,      creation_date
   	,      rowid
        ,      legislation_code
        ,      taxability_rules_date_id
   	from   hr_s_taxability_rules;

    stu_rec stu%ROWTYPE;

    CURSOR c_legs is
      select legislation_code
      from hr_s_history;

    PROCEDURE remove
    ----------------
    IS
        -- Remove a row from either the startup tables or the installed
	-- tables

    BEGIN


	delete from hr_s_taxability_rules
	where  rowid = stu_rec.rowid;

    END remove;

    PROCEDURE transfer_row
    ----------------------
    IS
	-- Check if a delivered row is needed and insert into the
	-- live tables if it is

    BEGIN


	-- See if the taxability information exists. If so then remove from the
	-- delivery tables, otherwise insert into the live table.

/* *** Added by RAMURTHY *** */

  BEGIN
  select taxability_rules_date_id
  into l_trd_id
  from pay_taxability_rules_dates
  where legislation_code = stu_rec.legislation_code
  and trunc(valid_date_from) = trunc(to_date('0001/01/01', 'YYYY/MM/DD'))
  and trunc(valid_date_to) = trunc(to_date('4712/12/31', 'YYYY/MM/DD'));

  EXCEPTION
     when NO_DATA_FOUND then

     select pay_taxability_rules_dates_s.nextval
     into l_trd_id
     from dual;

     insert into pay_taxability_rules_dates
     (     taxability_rules_date_id,
           valid_date_from,
           valid_date_to,
           legislation_code)
     Values
     (     l_trd_id,
           to_date('0001/01/01', 'YYYY/MM/DD'),
           to_date('4712/12/31', 'YYYY/MM/DD'),
           stu_rec.legislation_code);
   END;

/* *** End of code ddded by RAMURTHY *** */


	BEGIN

	    select null
	    into   l_null_return
	    from   pay_taxability_rules
	    where  jurisdiction_code = stu_rec.jurisdiction_code
	    and    tax_type = stu_rec.tax_type
            and    classification_id = stu_rec.classification_id
	    and    tax_category = stu_rec.tax_category;

	    -- The row exists

	    remove;

	    return;

	EXCEPTION WHEN NO_DATA_FOUND THEN

	    -- Needs to be inserted

	    IF p_phase = 1 THEN
	        return;
	    END IF;


            --
	    insert into pay_taxability_rules
	    (jurisdiction_code
	    ,tax_type
	    ,tax_category
	    ,classification_id
	    ,last_update_date
	    ,last_updated_by
	    ,last_update_login
	    ,created_by
	    ,creation_date
/* *** */   ,legislation_code
/* *** */   ,taxability_rules_date_id
	    )
	    values
	    (stu_rec.jurisdiction_code
	    ,stu_rec.tax_type
	    ,stu_rec.tax_category
	    ,stu_rec.classification_id
	    ,stu_rec.last_update_date
	    ,stu_rec.last_updated_by
	    ,stu_rec.last_update_login
	    ,stu_rec.created_by
	    ,stu_rec.creation_date
/* *** */   ,stu_rec.legislation_code
/* *** */   ,l_trd_id
	    );

	   remove;

	END;

    END transfer_row;

BEGIN

    --
    -- If any rows in pay_taxability_rules do not deliver any rows
    -- from hr_s_taxability_rules
    --
    --  Bug fix for bug no: 1618263
    --  Added this code because it was not populating the records into pay_
    --  taxability_rules table for legislation_code 'CA',
    --  if there is another legislation_code data already
    --  installed .  Earlier the count(*) from pay_taxability_rules
    --  will show the count irrespecitve of legislation_code and deletes the
    --  hr_s_taxability_rules data and the 'stu' cursor will not
    --  get executed.
  /*  Started code here for bug fix: 1618263 */

  for legs in c_legs loop

    l_leg_code := legs.legislation_code;

    select count(*)
    into l_num_rules
    from pay_taxability_rules
    where legislation_code = l_leg_code;

  /* End code here for bug fix: 1618263 */

    if (l_num_rules <> 0) then

        delete from hr_s_taxability_rules
        where legislation_code = l_leg_code;

    end if;

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

	-- Uses main cursor stu to impilicity define a record


	savepoint new_tax_rule;

	stu_rec := delivered;


	transfer_row;

    END LOOP;

 end loop; -- leg loop

END install_tax_rules;

--****************************************************************************
-- INSTALLATION PROCEDURE FOR : PAY_WC_STATE_SURCHARGES
--****************************************************************************

PROCEDURE install_surcharges(p_phase IN number)
-----------------------------------------------
IS
    -- Install procedure to transfer startup wc state surcharges into
    -- a live account.

    l_null_return varchar2(1);		-- For 'select null' statements
    l_add_to_rt varchar2(30);		-- For likeness test
    l_name varchar2(30);		-- ditto
    l_rate number(10,7);		-- ditto
    l_new_surrogate_key number(9);

    CURSOR stu			-- Selects all rows from startup entity
    IS
   	select SURCHARGE_ID
   	,      STATE_CODE
   	,      ADD_TO_RT
   	,      NAME
   	,      POSITION
   	,      RATE
   	,      LAST_UPDATE_DATE
   	,      LAST_UPDATED_BY
   	,      LAST_UPDATE_LOGIN
   	,      CREATED_BY
   	,      CREATION_DATE
   	,      rowid
   	from   hr_s_wc_state_surcharges;

    stu_rec stu%ROWTYPE;

    PROCEDURE remove
    ----------------
    IS
	-- Remove a row from either the startup tables or the installed tables

    BEGIN


   	delete from hr_s_wc_state_surcharges
   	where  rowid = stu_rec.rowid;

    END remove;

    FUNCTION update_uid RETURN boolean
    ----------------------------------
    IS
	-- Subprogram to update surrogate UID and all occurrences in child rows

    BEGIN


	BEGIN

	    IF p_phase = 2 THEN
		RETURN true;
	    END IF;

		select surcharge_id
		,      add_to_rt
		,      rate
        	,      name
		into   l_new_surrogate_key
		,      l_add_to_rt
		,      l_rate
		,      l_name
		from   pay_wc_state_surcharges
		where  state_code = stu_rec.state_code
		and    position = stu_rec.position;

	    IF stu_rec.add_to_rt = l_add_to_rt AND
	       stu_rec.rate = l_rate AND
	       stu_rec.name = l_name THEN

		-- Delete delivered row

		remove;

		-- Indicates this row is not required

		RETURN false;

	    END IF;

	EXCEPTION WHEN NO_DATA_FOUND THEN

	    -- Must be a new surcharge

	    select pay_wc_state_surcharges_s.nextval
	    into   l_new_surrogate_key
	    from   dual;

        END;

	-- Update all child entities

        update hr_s_wc_state_surcharges
        set    surcharge_id = l_new_surrogate_key
        where  surcharge_id = stu_rec.surcharge_id;

        IF p_phase = 2 THEN
           return TRUE;
        ELSE
           return FALSE;
        END IF;

    END update_uid;

    PROCEDURE transfer_row
    ----------------------
    IS
    -- Check if a delivered row is needed and insert into the
    -- live tables if it is

    BEGIN


	IF p_phase = 1 THEN
	    return;
	END IF;

	-- Attempt update first

	update pay_wc_state_surcharges
	set    SURCHARGE_ID = stu_rec.SURCHARGE_ID
	,      STATE_CODE = stu_rec.STATE_CODE
	,      ADD_TO_RT = stu_rec.ADD_TO_RT
	,      NAME = stu_rec.NAME
	,      POSITION = stu_rec.POSITION
	,      RATE = stu_rec.RATE
	,      LAST_UPDATE_DATE = stu_rec.LAST_UPDATE_DATE
	,      LAST_UPDATED_BY = stu_rec.LAST_UPDATED_BY
	,      LAST_UPDATE_LOGIN = stu_rec.LAST_UPDATE_LOGIN
	,      CREATED_BY = stu_rec.CREATED_BY
   	,      CREATION_DATE = stu_rec.CREATION_DATE
   	where  surcharge_id = stu_rec.surcharge_id;

   	IF SQL%NOTFOUND THEN

	    -- Row does not exist so insert


	    insert into pay_wc_state_surcharges
	    (SURCHARGE_ID
	    ,STATE_CODE
	    ,ADD_TO_RT
	    ,NAME
	    ,POSITION
	    ,RATE
	    ,LAST_UPDATE_DATE
	    ,LAST_UPDATED_BY
	    ,LAST_UPDATE_LOGIN
	    ,CREATED_BY
	    ,CREATION_DATE
	    )
	    values
	    (pay_wc_state_surcharges_s.nextval -- changes for nextval
	    ,stu_rec.STATE_CODE
	    ,stu_rec.ADD_TO_RT
	    ,stu_rec.NAME
	    ,stu_rec.POSITION
	    ,stu_rec.RATE
	    ,stu_rec.LAST_UPDATE_DATE
	    ,stu_rec.LAST_UPDATED_BY
	    ,stu_rec.LAST_UPDATE_LOGIN
	    ,stu_rec.CREATED_BY
	    ,stu_rec.CREATION_DATE
	    );

	END IF;

	-- Delete delivered row now it has been installed

   	remove;

    END transfer_row;

BEGIN
    -- This is the main loop to perform the installation logic. A cursor
    -- is opened to control the loop, and each row returned is placed
    -- into a record defined within the main procedure so each sub
    -- procedure has full access to all returrned columns. For each
    -- new row returned, a new savepoint is declared. If at any time
    -- the row is in error a rollback iss performed to the savepoint
    -- and the next row is returned. If the row differs to that installed
    -- or if the delivered row is not present, then the row is required and
    -- the surrogate id is updated and the main transfer logic is called.

    FOR delivered IN stu LOOP

	-- Uses main cursor stu to impilicity define a record


	savepoint new_primary_key;

	stu_rec := delivered;


	IF update_uid THEN
	    transfer_row;
	END IF;

    END LOOP;

END install_surcharges;

--****************************************************************************
-- INSTALLATION PROCEDURE FOR : PAY_LEGISLATION_RULES
--****************************************************************************

PROCEDURE install_leg_rules(p_phase IN number)
----------------------------------------------
IS
    -- Procedure to install legislation rules for a given legislation. This
    -- routine will compare the value of RULE_MODE for the same RULE_TYPE
    -- and legislatrion code. If the delivered row is diferent to the one
    -- installed, or there is not one installed, the delivered row will be
    -- placed in the live tables.

    l_null_return varchar2(1); 		-- For 'select null' statements
    l_rule_mode varchar2(30); 		-- Holds the value from live
    l_hrs_rule_mode varchar2(30);       -- Holds the possibly translated
                                        -- rule mode from HR_S
    l_new_surrogate_key number(9);

    CURSOR stu			-- selects all rows from startup entity
    IS
   	select legislation_code
   	,      rule_type
   	,      rule_mode
   	,      rowid
   	from   hr_s_legislation_rules;

    stu_rec stu%ROWTYPE;

    PROCEDURE remove
    ----------------
    IS
	-- Remove a row from either the startup tables or the installed tables

    BEGIN

   	delete from hr_s_legislation_rules
   	where  rowid = stu_rec.rowid;

    END remove;

    PROCEDURE transfer_row
    ----------------------
    IS
	-- Check if a delivered row is needed and insert into the
	-- live tables if it is

	-- The logic performed is simple. If the rule exists, compare the
	-- value of the rule_mode. Update the rule mode if the the values
	-- are different.

	-- If the rule does not exist then insert the row into the live tables.
	-- Updates and inserts only take place in phase 2.

    BEGIN

      BEGIN

        -- Translate the structure_code to a id_flex_num value if the
        -- rule_mode has been passed in as such

        select distinct id_flex_num
        into   l_hrs_rule_mode
        from   fnd_id_flex_structures fifs
        where  fifs.id_flex_structure_code = stu_rec.rule_mode
        and    stu_rec.rule_type in ('E', 'S', 'CWK_S')
        and    decode(stu_rec.rule_type, 'E', 'BANK',
                                         'S', 'SCL',
                                         'CWK_S', 'SCL',
                                         'X') = fifs.id_flex_code;

      EXCEPTION WHEN OTHERS THEN
        -- rule_type was passed in as a id_flex_num anyway so leave.
        l_hrs_rule_mode := stu_rec.rule_mode;
      END;

      select rule_mode
      into   l_rule_mode
      from   pay_legislation_rules
      where  rule_type = stu_rec.rule_type
      and    legislation_code = stu_rec.legislation_code;

      IF l_rule_mode = l_hrs_rule_mode THEN

	-- The values are the same, this row not needed
        remove;
	return;

      END IF;

      -- The row is different and must be updated

      IF p_phase = 1 THEN --only update in phase 2
        return;
      END IF;

      update pay_legislation_rules
      set    rule_mode = l_hrs_rule_mode
      where  rule_type = stu_rec.rule_type
      and    legislation_code = stu_rec.legislation_code;

      -- Delete the delivered row from the delivery tables
      remove;

    EXCEPTION WHEN NO_DATA_FOUND THEN

      IF p_phase = 1 THEN
        return;
      END IF;

      insert into pay_legislation_rules
      (legislation_code
      ,rule_mode
      ,rule_type
      )
      values
      (stu_rec.legislation_code
      ,l_hrs_rule_mode
      ,stu_rec.rule_type
      );

      remove;

    END transfer_row;

BEGIN
    -- This is the main loop to perform the installation logic. A cursor
    -- is opened to control the loop, and each row returned is placed
    -- into a record defined within the main procedure so each sub
    -- procedure has full access to all returned columns. For each
    -- new row returned, a new savepoint is declared. If at any time
    -- the row is in error a rollback is performed to the savepoint
    -- and the next row is returned. If the row differs to that installed
    -- or if the delivered row is not present, then the row is required and
    -- the surrogate id is updated and the main transfer logic is called.

    FOR delivered IN stu LOOP

	-- Uses main cursor stu to impilicity define a record


   	savepoint new_primary_key;

   	stu_rec := delivered;

	transfer_row;

    END LOOP;

END install_leg_rules;


PROCEDURE install_us_new(p_phase IN number)
    ----------------
    IS
        hr_s_tab  character_data_table;
        pay_tab   character_data_table;
        cid     integer;
        deltabid  integer;
        lc_cnt    number;
        gfr_exist  varchar2(1) := 'N';
		insert_jit_data varchar2(1) := 'N';
		l_patch_count number(5);
        l_max_val number(15) := 0;
        l_next_val number(15) := 0;
        l_prev_seq number(15) := 0;

        cursor cti  is select * from HR_S_US_CITY_TAX_INFO_F;
        cursor coti  is select * from HR_S_US_COUNTY_TAX_INFO_F;
        cursor sti  is select * from HR_S_US_STATE_TAX_INFO_F;
        cursor fti  is select * from HR_S_US_FEDERAL_TAX_INFO_F;
        cursor ger  is select * from HR_S_US_GARN_EXEMPTION_RULES_F;
        cursor gfr  is select * from HR_S_US_GARN_FEE_RULES_F
                       order by fee_rule_id;
        cursor pgfr  is select creator_type, garn_category, state_code
                        FROM PAY_US_GARN_FEE_RULES_F
    		        WHERE sysdate between effective_start_date
     			and effective_end_date;

        cursor glr  is select * from HR_S_US_GARN_LIMIT_RULES_F;
	cursor hrl is select * from HR_S_REPORT_LOOKUPS;
        l_magnetic_block_id number;
        l_next_block_id     number;
        l_formula_id     number;
        sqlstr varchar2(2000);
BEGIN
  if p_phase = 2 then

  begin
  hr_s_tab(1) := 'HR_S_US_CITY_TAX_INFO_F';
  hr_s_tab(2) := 'HR_S_US_COUNTY_TAX_INFO_F';
  hr_s_tab(3) := 'HR_S_US_STATE_TAX_INFO_F';
  hr_s_tab(4) := 'HR_S_US_FEDERAL_TAX_INFO_F';
  hr_s_tab(5) := 'HR_S_US_GARN_EXEMPTION_RULES_F';
  hr_s_tab(6) := 'HR_S_US_GARN_FEE_RULES_F';
  hr_s_tab(7) := 'HR_S_US_GARN_LIMIT_RULES_F';
  hr_s_tab(8) := 'HR_S_REPORT_LOOKUPS';

  pay_tab(1) := 'PAY_US_CITY_TAX_INFO_F';
  pay_tab(2) := 'PAY_US_COUNTY_TAX_INFO_F';
  pay_tab(3) := 'PAY_US_STATE_TAX_INFO_F';
  pay_tab(4) := 'PAY_US_FEDERAL_TAX_INFO_F';
  pay_tab(5) := 'PAY_US_GARN_EXEMPTION_RULES_F';
  pay_tab(6) := 'PAY_US_GARN_FEE_RULES_F';
  pay_tab(7) := 'PAY_US_GARN_LIMIT_RULES_F';
  pay_tab(8) := 'HR_REPORT_LOOKUPS';

  select count(*)
  into l_patch_count
  from pay_patch_status
  where patch_name like 'JIT%';

  for lc_cnt in 5..8 loop
    if pay_tab(lc_cnt) = 'PAY_US_GARN_FEE_RULES_F' then
	  DELETE FROM PAY_US_GARN_FEE_RULES_F
      WHERE creator_type = 'SYSTEM'
      AND 0 <> (SELECT COUNT(*) FROM
                 HR_S_US_GARN_FEE_RULES_F);
    else
      begin
		if ((l_patch_count > 0 ) and  (pay_tab(lc_cnt) like 'PAY_US%INFO_F' )) then
			null; /* do not transfer JIT data if not fresh install */
		else

           sqlstr := 'delete from '|| pay_tab(lc_cnt) || ' where ';
           sqlstr := sqlstr || ' 0 <> ( ';
           sqlstr := sqlstr || 'select count(*) from '|| hr_s_tab(lc_cnt)||' )';

           cid := dbms_sql.open_cursor;
           dbms_sql.parse(cid, sqlstr, dbms_sql.v7);
           deltabid := dbms_sql.execute(cid);
           dbms_sql.close_cursor(cid);
        end if;
      exception
        when others then
          dbms_sql.close_cursor(cid);
      end;

    end if;


  end loop;

   for ger_rec in ger loop
	savepoint new_primary_key;
      insert into PAY_US_GARN_EXEMPTION_RULES_F
      (
	MIN_WAGE_FACTOR,
	PRORATION_RULE,
	LAST_UPDATE_DATE,
	LAST_UPDATED_BY,
	LAST_UPDATE_LOGIN,
	CREATED_BY,
	CREATION_DATE,
	EXEMPTION_RULE_ID,
	EFFECTIVE_START_DATE,
	EFFECTIVE_END_DATE,
	GARN_CATEGORY,
	STATE_CODE,
	ADDL_DEP_AMOUNT_VALUE,
	AMOUNT_VALUE,
	CALC_RULE,
	CREATOR_TYPE,
	DEPENDENTS_CALC_RULE,
	DEPENDENT_AMOUNT_VALUE,
	DI_PCT,
	DI_PCT_DEPENDENTS,
	DI_PCT_DEPENDENTS_IN_ARREARS,
	DI_PCT_IN_ARREARS,
	EXEMPTION_BALANCE,
	EXEMPTION_BALANCE_MAX_PCT,
	EXEMPTION_BALANCE_MIN_PCT,
	MARITAL_STATUS)values
      (
	ger_rec.MIN_WAGE_FACTOR,
	ger_rec.PRORATION_RULE,
	ger_rec.LAST_UPDATE_DATE,
	ger_rec.LAST_UPDATED_BY,
	ger_rec.LAST_UPDATE_LOGIN,
	ger_rec.CREATED_BY,
	ger_rec.CREATION_DATE,
    ger_rec.EXEMPTION_RULE_ID,
   /* Since we have already deleted all rows from
      pay_us_garn_exemption_rules_f, there cannot be any conflict of ids. It is
      therefore safe to use the ids from the hr_s table. This will help in
      maintainig the correct ids for date-tracked rows. After inserting
      all the rows we will set the sequence to start at a value higher than the
      max value of the id in pay_us_garn_exemption_rules_f.
	PAY_US_GARN_EXEMPTION_RULES_S.nextval,   -- changes for nextval */
	ger_rec.EFFECTIVE_START_DATE,
	ger_rec.EFFECTIVE_END_DATE,
	ger_rec.GARN_CATEGORY,
	ger_rec.STATE_CODE,
	ger_rec.ADDL_DEP_AMOUNT_VALUE,
	ger_rec.AMOUNT_VALUE,
	ger_rec.CALC_RULE,
	ger_rec.CREATOR_TYPE,
	ger_rec.DEPENDENTS_CALC_RULE,
	ger_rec.DEPENDENT_AMOUNT_VALUE,
	ger_rec.DI_PCT,
	ger_rec.DI_PCT_DEPENDENTS,
	ger_rec.DI_PCT_DEPENDENTS_IN_ARREARS,
	ger_rec.DI_PCT_IN_ARREARS,
	ger_rec.EXEMPTION_BALANCE,
	ger_rec.EXEMPTION_BALANCE_MAX_PCT,
	ger_rec.EXEMPTION_BALANCE_MIN_PCT,
	ger_rec.MARITAL_STATUS);

  end loop;

  select max(exemption_rule_id)
  into l_max_val
  from pay_us_garn_exemption_rules_f;

  l_next_val := 0;

  /* consume sequence till there is no conflict */
  while l_next_val < l_max_val
  loop
    select PAY_US_GARN_EXEMPTION_RULES_S.nextval
    into l_next_val
    from dual;
  end loop;

  /* reset l_max_val, l_next_val  for the next table */
  l_max_val := 0;
  l_next_val := 0;


  for gfr_rec in gfr loop
     gfr_exist := 'N';
     for pgfr_rec in pgfr loop
	    if (pgfr_rec.state_code = gfr_rec.state_code
            and pgfr_rec.garn_category = gfr_rec.garn_category
            and pgfr_rec.creator_type <> 'SYSTEM') then
	        gfr_exist := 'Y';
            exit;
        end if;
     end loop;
     /* In order to maintain correct history of date tracked changes
        and to also avoid any conflict of ids with user update rows
        ( creator_type <> 'SYSTEM'), we need to compare the current
        fee_rule_id with the row processed in the previous iteration.
        If the ids are the same we will use currval from the sequence as
        the new fee rule id else we will use nextval. */
     if l_prev_seq = gfr_rec.fee_rule_id
     then
       select PAY_US_GARN_FEE_RULES_S.currval
       into l_next_val
       from dual;
     else
       select PAY_US_GARN_FEE_RULES_S.nextval
       into l_next_val
       from dual;
     end if;

     l_prev_seq := gfr_rec.fee_rule_id;

     if gfr_exist = 'N' then
	savepoint new_primary_key;
     insert into PAY_US_GARN_FEE_RULES_F
	(
     FEE_RULE_ID,
     EFFECTIVE_START_DATE,
     EFFECTIVE_END_DATE,
     GARN_CATEGORY,
     STATE_CODE,
     ADDL_GARN_FEE_AMOUNT,
     CORRESPONDENCE_FEE,
     CREATOR_TYPE,
     FEE_AMOUNT,
     FEE_RULE,
     MAX_FEE_AMOUNT,
     PCT_CURRENT,
     LAST_UPDATE_DATE,
     LAST_UPDATED_BY,
     LAST_UPDATE_LOGIN,
     CREATED_BY,
     CREATION_DATE) values
	(
     /* use the l_next_val generated
        in the previous step to populte the
        fee_rule_id
     pay_us_garn_fee_rules_s.nextval,*/
     l_next_val,
     to_date('01/01/0001', 'DD/MM/YYYY'),
     to_date('31/12/4712', 'DD/MM/YYYY'),
     gfr_rec.GARN_CATEGORY,
     gfr_rec.STATE_CODE,
     gfr_rec.ADDL_GARN_FEE_AMOUNT,
     gfr_rec.CORRESPONDENCE_FEE,
     'SYSTEM',
     gfr_rec.FEE_AMOUNT,
     gfr_rec.FEE_RULE,
     gfr_rec.MAX_FEE_AMOUNT,
     gfr_rec.PCT_CURRENT,
     gfr_rec.LAST_UPDATE_DATE,
     gfr_rec.LAST_UPDATED_BY,
     gfr_rec.LAST_UPDATE_LOGIN,
     gfr_rec.CREATED_BY,
     gfr_rec.CREATION_DATE);

     gfr_exist := 'N';
     end if;
  end loop;

  select max(fee_rule_id)
  into l_max_val
  from pay_us_garn_fee_rules_f;

  l_next_val := 0;

  /* consume sequence till there is no conflict */
  while l_next_val < l_max_val
  loop
    select PAY_US_GARN_FEE_RULES_S.nextval
    into l_next_val
    from dual;
  end loop;

  /* reset l_max_val, l_next_val  for the next table */
  l_max_val := 0;
  l_next_val := 0;





  for glr_rec in glr loop
	savepoint new_primary_key;
     insert into PAY_US_GARN_LIMIT_RULES_F
   	(
     LIMIT_RULE_ID,
     EFFECTIVE_START_DATE,
     EFFECTIVE_END_DATE,
     GARN_CATEGORY,
     STATE_CODE,
     MAX_WITHHOLDING_AMOUNT,
     MAX_WITHHOLDING_DURATION_DAYS,
     MIN_WITHHOLDING_AMOUNT,
     LAST_UPDATE_DATE,
     LAST_UPDATED_BY,
     LAST_UPDATE_LOGIN,
     CREATED_BY,
     CREATION_DATE) values
	(
    glr_rec.LIMIT_RULE_ID,
   /* Since we have already deleted all rows from
      pay_us_garn_limit_rules_f, there cannot be any conflict of ids. It is
      therefore safe to use the ids from the hr_s table. This will help in
      maintainig the correct ids for date-tracked rows. After inserting
      all the rows we will set the sequence to start at a value higher than the
      max value of the id in pay_us_garn_limit_rules_f.
    PAY_US_GARN_LIMIT_RULES_S.nextval,  -- cahnges for nextval */
    glr_rec.EFFECTIVE_START_DATE,
    glr_rec.EFFECTIVE_END_DATE,
    glr_rec.GARN_CATEGORY,
    glr_rec.STATE_CODE,
    glr_rec.MAX_WITHHOLDING_AMOUNT,
    glr_rec.MAX_WITHHOLDING_DURATION_DAYS,
    glr_rec.MIN_WITHHOLDING_AMOUNT,
    glr_rec.LAST_UPDATE_DATE,
    glr_rec.LAST_UPDATED_BY,

    glr_rec.LAST_UPDATE_LOGIN,
    glr_rec.CREATED_BY,
    glr_rec.CREATION_DATE);

   end loop;

  select max(limit_rule_id)
  into l_max_val
  from pay_us_garn_limit_rules_f;

  l_next_val := 0;

  /* consume sequence till there is no conflict */
  while l_next_val < l_max_val
  loop
    select PAY_US_GARN_LIMIT_RULES_S.nextval
    into l_next_val
    from dual;
  end loop;

  /* reset l_max_val, l_next_val  for the next table */
  l_max_val := 0;
  l_next_val := 0;


  for hrl_rec in hrl  loop
	savepoint new_primary_key;
	insert into hr_report_lookups (
		REPORT_NAME,
		REPORT_LOOKUP_TYPE,
		LOOKUP_CODE,
		ENABLED_FLAG,
		CREATED_BY,
		CREATION_DATE,
		LAST_UPDATED_BY,
		LAST_UPDATE_DATE,
		LAST_UPDATE_LOGIN  )
	values  (
		hrl_rec.REPORT_NAME,
		hrl_rec.REPORT_LOOKUP_TYPE,
		hrl_rec.LOOKUP_CODE,
		hrl_rec.ENABLED_FLAG,
		hrl_rec.CREATED_BY,
		hrl_rec.CREATION_DATE,
		hrl_rec.LAST_UPDATED_BY,
		hrl_rec.LAST_UPDATE_DATE,
		hrl_rec.LAST_UPDATE_LOGIN  );
   end loop;

EXCEPTION
    when others then
       rollback to new_primary_key;

	/* temp. workaround  for unique key violation */
	   delete HR_STU_EXCEPTIONS
	   where table_name = 'HR_S_NEW';

        hr_legislation.insert_hr_stu_exceptions('HR_S_NEW',
         1000,
         'Error in new US tables',
         null);



 end;
 end if;

END install_us_new;

FUNCTION decode_elmnt_bal_information (p_legislation_code VARCHAR2,
   p_information_type VARCHAR2,
   p_code NUMBER DEFAULT NULL,
   p_meaning VARCHAR2 DEFAULT NULL)
RETURN VARCHAR2 IS

   CURSOR csr_element_name IS
   SELECT element_name
   FROM hr_s_element_types_f
   WHERE element_type_id = p_code;

   CURSOR csr_element_id IS
   SELECT element_type_id
   FROM pay_element_types_f
   WHERE element_name = p_meaning
   AND legislation_code = p_legislation_code;

   CURSOR csr_balance_name IS
   SELECT balance_name
   FROM hr_s_balance_types
   WHERE balance_type_id = p_code;

   CURSOR csr_balance_id IS
   SELECT balance_type_id
   FROM pay_balance_types
   WHERE balance_name = p_meaning
   AND legislation_code = p_legislation_code;

   l_return VARCHAR2(80);

BEGIN
   IF p_information_type = 'BALANCE'
   THEN
      IF p_code IS NULL THEN
         OPEN csr_balance_id;

         FETCH csr_balance_id
         INTO l_return;

         IF csr_balance_id%NOTFOUND THEN
            l_return := NULL;
         END IF;
      ELSE
         OPEN csr_balance_name;

         FETCH csr_balance_name
         INTO l_return;

         IF csr_balance_name%NOTFOUND THEN
            l_return := NULL;
         END IF;
      END IF;
   ELSE
      IF p_code IS NULL THEN
         OPEN csr_element_id;

         FETCH csr_element_id
         INTO l_return;

         IF csr_element_id%NOTFOUND THEN
            l_return := NULL;
         END IF;
      ELSE
         OPEN csr_element_name;

         FETCH csr_element_name
         INTO l_return;

         IF csr_balance_name%NOTFOUND THEN
            l_return := NULL;
         END IF;
      END IF;
   END IF;
   return l_return;
END decode_elmnt_bal_information;

PROCEDURE translate_us_ele_dev_df(p_mode VARCHAR2)
IS
   CURSOR csr_hr_s_element_details IS
   SELECT element_type_id,
      element_information_category,
      element_information10
   FROM hr_s_element_types_f
   WHERE legislation_code = 'US'
   AND element_information_category IS NOT NULL
   FOR UPDATE OF element_information10 NOWAIT;

   CURSOR csr_pay_element_details IS
   SELECT element_type_id,
      element_information_category,
      element_information10
   FROM pay_element_types_f
   WHERE legislation_code = 'US'
   AND element_information_category IS NOT NULL
   FOR UPDATE OF element_information10 NOWAIT;

/*
** VMehta - Commented out the update for element_tyupe ids for the time being
** as this runs into  mutating table condition in the 'NAME_TO_ID' condition
** We can get away with this for 11i as we are not delivering any element ids.
** in the Element Developer DF fort the time being.
**
*/

BEGIN
   IF p_mode = 'ID_TO_NAME' THEN
   FOR hr_s_rec IN csr_hr_s_element_details
   LOOP
      IF hr_s_rec.element_information_category = 'US_EARNINGS'
      THEN

         UPDATE hr_s_element_types_f
         SET element_information10 = NVL(decode_elmnt_bal_information('US',
                                         'BALANCE'
                                         , element_information10, NULL),
                                         element_information10),
           element_information12 = NVL(decode_elmnt_bal_information('US',
                                         'BALANCE'
                                         , element_information12, NULL),
                                         element_information12),
           element_information16 = NVL(decode_elmnt_bal_information('US',
                                         'BALANCE'
                                         , element_information16, NULL),
                                         element_information16),
           element_information17 = NVL(decode_elmnt_bal_information('US',
                                         'BALANCE'
                                         , element_information17, NULL),
                                         element_information17)--,
           --element_information18 = NVL(decode_elmnt_bal_information('US',
           --                              'ELEMENT'
           --                              , element_information18, NULL),
           --                              element_information18),
           --element_information19 = NVL(decode_elmnt_bal_information('US',
           --                              'ELEMENT'
           --                              , element_information19, NULL),
           --                              element_information19),
           --element_information20 = NVL(decode_elmnt_bal_information('US',
           --                              'ELEMENT'
           --                              , element_information20, NULL),
           --                              element_information20)
         WHERE element_type_id = hr_s_rec.element_type_id;

      ELSIF hr_s_rec.element_information_category = 'US_IMPUTED EARNINGS'
      THEN

         UPDATE hr_s_element_types_f
         SET element_information10 = NVL(decode_elmnt_bal_information('US',
                                         'BALANCE'
                                         , element_information10, NULL),
                                         element_information10),
           element_information12 = NVL(decode_elmnt_bal_information('US',
                                         'BALANCE'
                                         , element_information12, NULL),
                                         element_information12),
           element_information16 = NVL(decode_elmnt_bal_information('US',
                                         'BALANCE'
                                         , element_information16, NULL),
                                         element_information16),
           element_information17 = NVL(decode_elmnt_bal_information('US',
                                         'BALANCE'
                                         , element_information17, NULL),
                                         element_information17)--,
           --element_information18 = NVL(decode_elmnt_bal_information('US',
           --                              'ELEMENT'
           --                              , element_information18, NULL),
           --                              element_information18),
           --element_information19 = NVL(decode_elmnt_bal_information('US',
           --                              'ELEMENT'
           --                              , element_information19, NULL),
           --                              element_information19),
           --element_information20 = NVL(decode_elmnt_bal_information('US',
           --                              'ELEMENT'
           --                              , element_information20, NULL),
           --                              element_information20)
         WHERE element_type_id = hr_s_rec.element_type_id;

      ELSIF hr_s_rec.element_information_category = 'US_INVOLUNTARY DEDUCTIONS'  THEN
         UPDATE hr_s_element_types_f
         SET
           --     element_information5 = NVL(decode_elmnt_bal_information('US',
           --                              'ELEMENT'
           --                              , element_information5, NULL),
           --                              element_information5),
           element_information8 = NVL(decode_elmnt_bal_information('US',
                                         'BALANCE'
                                         , element_information8, NULL),
                                         element_information8),
           element_information10 = NVL(decode_elmnt_bal_information('US',
                                         'BALANCE'
                                         , element_information10, NULL),
                                         element_information10),
           element_information11 = NVL(decode_elmnt_bal_information('US',
                                         'BALANCE'
                                         , element_information11, NULL),
                                         element_information11),
           element_information12 = NVL(decode_elmnt_bal_information('US',
                                         'BALANCE'
                                         , element_information12, NULL),
                                         element_information12),
           element_information13 = NVL(decode_elmnt_bal_information('US',
                                         'BALANCE'
                                         , element_information13, NULL),
                                         element_information13),
           element_information14 = NVL(decode_elmnt_bal_information('US',
                                         'BALANCE'
                                         , element_information14, NULL),
                                         element_information14),
           element_information15 = NVL(decode_elmnt_bal_information('US',
                                         'BALANCE'
                                         , element_information15, NULL),
                                         element_information15),
           element_information16 = NVL(decode_elmnt_bal_information('US',
                                         'BALANCE'
                                         , element_information16, NULL),
                                         element_information16),
           element_information17 = NVL(decode_elmnt_bal_information('US',
                                         'BALANCE'
                                         , element_information17, NULL),
                                         element_information17)--,
           --element_information18 = NVL(decode_elmnt_bal_information('US',
           --                              'ELEMENT'
           --                              , element_information18, NULL),
           --                              element_information18),
           --element_information19 = NVL(decode_elmnt_bal_information('US',
           --                              'ELEMENT'
           --                              , element_information19, NULL),
           --                              element_information19),
           --element_information20 = NVL(decode_elmnt_bal_information('US',
           --                              'ELEMENT'
           --                              , element_information20, NULL),
           --                              element_information20)
         WHERE element_type_id = hr_s_rec.element_type_id;

      ELSIF hr_s_rec.element_information_category = 'US_NON-PAYROLL PAYMENTS'
      THEN
         UPDATE hr_s_element_types_f
         SET element_information10 = NVL(decode_elmnt_bal_information('US',
                                         'BALANCE'
                                         , element_information10, NULL),
                                         element_information10),
           element_information16 = NVL(decode_elmnt_bal_information('US',
                                         'BALANCE'
                                         , element_information16, NULL),
                                         element_information16),
           element_information17 = NVL(decode_elmnt_bal_information('US',
                                         'BALANCE'
                                         , element_information17, NULL),
                                         element_information17)--,
           --element_information18 = NVL(decode_elmnt_bal_information('US',
           --                              'ELEMENT'
           --                              , element_information18, NULL),
           --                              element_information18),
           --element_information19 = NVL(decode_elmnt_bal_information('US',
           --                              'ELEMENT'
           --                              , element_information19, NULL),
           --                              element_information19),
           --element_information20 = NVL(decode_elmnt_bal_information('US',
           --                              'ELEMENT'
           --                              , element_information20, NULL),
           --                              element_information20)
         WHERE element_type_id = hr_s_rec.element_type_id;

      ELSIF hr_s_rec.element_information_category = 'US_PRE-TAX DEDUCTIONS'
      THEN
         UPDATE hr_s_element_types_f
         SET element_information10 = NVL(decode_elmnt_bal_information('US',
                                         'BALANCE'
                                         , element_information10, NULL),
                                         element_information10),
           element_information11 = NVL(decode_elmnt_bal_information('US',
                                         'BALANCE'
                                         , element_information11, NULL),
                                         element_information11),
           element_information12 = NVL(decode_elmnt_bal_information('US',
                                         'BALANCE'
                                         , element_information12, NULL),
                                         element_information12),
           element_information13 = NVL(decode_elmnt_bal_information('US',
                                         'BALANCE'
                                         , element_information13, NULL),
                                         element_information13),
           element_information14 = NVL(decode_elmnt_bal_information('US',
                                         'BALANCE'
                                         , element_information14, NULL),
                                         element_information14),
           element_information15 = NVL(decode_elmnt_bal_information('US',
                                         'BALANCE'
                                         , element_information15, NULL),
                                         element_information15),
           element_information16 = NVL(decode_elmnt_bal_information('US',
                                         'BALANCE'
                                         , element_information16, NULL),
                                         element_information16),
           element_information17 = NVL(decode_elmnt_bal_information('US',
                                         'BALANCE'
                                         , element_information17, NULL),
                                         element_information17)--,
           --element_information18 = NVL(decode_elmnt_bal_information('US',
           --                              'ELEMENT'
           --                              , element_information18, NULL),
           --                              element_information18),
           --element_information19 = NVL(decode_elmnt_bal_information('US',
           --                              'ELEMENT'
           --                              , element_information19, NULL),
           --                              element_information19),
           --element_information20 = NVL(decode_elmnt_bal_information('US',
           --                              'ELEMENT'
           --                              , element_information20, NULL),
           --                              element_information20)
         WHERE element_type_id = hr_s_rec.element_type_id;

      ELSIF hr_s_rec.element_information_category = 'US_PTO ACCRUALS'
      THEN
         UPDATE hr_s_element_types_f
         SET element_information10 = NVL(decode_elmnt_bal_information('US',
                                         'BALANCE'
                                         , element_information10, NULL),
                                         element_information10)
         WHERE element_type_id = hr_s_rec.element_type_id;

      ELSIF hr_s_rec.element_information_category = 'US_SUPPLEMENTAL EARNINGS'
      THEN
         UPDATE hr_s_element_types_f
         SET element_information10 = NVL(decode_elmnt_bal_information('US',
                                         'BALANCE'
                                         , element_information10, NULL),
                                         element_information10),
           element_information12 = NVL(decode_elmnt_bal_information('US',
                                         'BALANCE'
                                         , element_information12, NULL),
                                         element_information12),
           element_information16 = NVL(decode_elmnt_bal_information('US',
                                         'BALANCE'
                                         , element_information16, NULL),
                                         element_information16),
           element_information17 = NVL(decode_elmnt_bal_information('US',
                                         'BALANCE'
                                         , element_information17, NULL),
                                         element_information17)--,
           --element_information18 = NVL(decode_elmnt_bal_information('US',
           --                              'ELEMENT'
           --                              , element_information18, NULL),
           --                              element_information18),
           --element_information19 = NVL(decode_elmnt_bal_information('US',
           --                              'ELEMENT'
           --                              , element_information19, NULL),
           --                              element_information19),
           --element_information20 = NVL(decode_elmnt_bal_information('US',
           --                              'ELEMENT'
           --                              , element_information20, NULL),
           --                              element_information20)
         WHERE element_type_id = hr_s_rec.element_type_id;

      ELSIF hr_s_rec.element_information_category = 'US_TAX DEDUCTIONS'
      THEN
         UPDATE hr_s_element_types_f
         SET element_information10 = NVL(decode_elmnt_bal_information('US',
                                         'BALANCE'
                                         , element_information10, NULL),
                                         element_information10),
           element_information11 = NVL(decode_elmnt_bal_information('US',
                                         'BALANCE'
                                         , element_information11, NULL),
                                         element_information11),
           element_information12 = NVL(decode_elmnt_bal_information('US',
                                         'BALANCE'
                                         , element_information12, NULL),
                                         element_information12),
           element_information13 = NVL(decode_elmnt_bal_information('US',
                                         'BALANCE'
                                         , element_information13, NULL),
                                         element_information13),
           element_information14 = NVL(decode_elmnt_bal_information('US',
                                         'BALANCE'
                                         , element_information14, NULL),
                                         element_information14),
           element_information15 = NVL(decode_elmnt_bal_information('US',
                                         'BALANCE'
                                         , element_information15, NULL),
                                         element_information15),
           element_information16 = NVL(decode_elmnt_bal_information('US',
                                         'BALANCE'
                                         , element_information16, NULL),
                                         element_information16),
           element_information17 = NVL(decode_elmnt_bal_information('US',
                                         'BALANCE'
                                         , element_information17, NULL),
                                         element_information17),
           element_information18 = NVL(decode_elmnt_bal_information('US',
                                         'BALANCE'
                                         , element_information18, NULL),
                                         element_information18),
           element_information19 = NVL(decode_elmnt_bal_information('US',
                                         'BALANCE'
                                         , element_information19, NULL),
                                         element_information19)
         WHERE element_type_id = hr_s_rec.element_type_id;

      ELSIF hr_s_rec.element_information_category = 'US_VOLUNTARY DEDUCTIONS'
      THEN
         UPDATE hr_s_element_types_f
         SET element_information10 = NVL(decode_elmnt_bal_information('US',
                                         'BALANCE'
                                         , element_information10, NULL),
                                         element_information10),
           element_information11 = NVL(decode_elmnt_bal_information('US',
                                         'BALANCE'
                                         , element_information11, NULL),
                                         element_information11),
           element_information12 = NVL(decode_elmnt_bal_information('US',
                                         'BALANCE'
                                         , element_information12, NULL),
                                         element_information12),
           element_information13 = NVL(decode_elmnt_bal_information('US',
                                         'BALANCE'
                                         , element_information13, NULL),
                                         element_information13),
           element_information14 = NVL(decode_elmnt_bal_information('US',
                                         'BALANCE'
                                         , element_information14, NULL),
                                         element_information14),
           element_information16 = NVL(decode_elmnt_bal_information('US',
                                         'BALANCE'
                                         , element_information16, NULL),
                                         element_information16),
           element_information17 = NVL(decode_elmnt_bal_information('US',
                                         'BALANCE'
                                         , element_information17, NULL),
                                         element_information17)--,
           --element_information18 = NVL(decode_elmnt_bal_information('US',
           --                              'ELEMENT'
           --                              , element_information18, NULL),
           --                              element_information18),
           --element_information19 = NVL(decode_elmnt_bal_information('US',
           --                              'ELEMENT'
           --                              , element_information19, NULL),
           --                              element_information19),
           --element_information20 = NVL(decode_elmnt_bal_information('US',
           --                              'ELEMENT'
           --                              , element_information20, NULL),
           --                              element_information20)
         WHERE element_type_id = hr_s_rec.element_type_id;

      END IF;
   END LOOP;
   ELSE /* NAME_TO_ID */
   FOR pay_rec IN csr_pay_element_details
   LOOP
      IF pay_rec.element_information_category = 'US_EARNINGS'
      THEN

         UPDATE pay_element_types_f
         SET element_information10 = NVL(decode_elmnt_bal_information('US',

                                       'BALANCE', NULL, element_information10),
                                           element_information10),
           element_information12 = NVL(decode_elmnt_bal_information('US',

                                      'BALANCE', NULL, element_information12),
                                           element_information12),
           element_information16 = NVL(decode_elmnt_bal_information('US',
                                         'BALANCE'
                                         , NULL, element_information16),
                                         element_information16),
           element_information17 = NVL(decode_elmnt_bal_information('US',
                                         'BALANCE'
                                         , NULL, element_information17),
                                         element_information17)--,
           --element_information18 = NVL(decode_elmnt_bal_information('US',
           --                              'ELEMENT'
           --                              , NULL, element_information18),
           --                              element_information18),
           --element_information19 = NVL(decode_elmnt_bal_information('US',
           --                              'ELEMENT'
           --                              , NULL, element_information19),
           --                              element_information19),
           --element_information20 = NVL(decode_elmnt_bal_information('US',
           --                              'ELEMENT'
           --                              , NULL, element_information20),
           --                              element_information20)
         WHERE element_type_id = pay_rec.element_type_id;

      ELSIF pay_rec.element_information_category = 'US_IMPUTED EARNINGS'
      THEN

         UPDATE pay_element_types_f
         SET element_information10 = NVL(decode_elmnt_bal_information('US',
                                         'BALANCE'
                                         , NULL, element_information10),
                                         element_information10),
           element_information12 = NVL(decode_elmnt_bal_information('US',
                                         'BALANCE'
                                         , NULL, element_information12),
                                         element_information12),
           element_information16 = NVL(decode_elmnt_bal_information('US',
                                         'BALANCE'
                                         , NULL, element_information16),
                                         element_information16),
           element_information17 = NVL(decode_elmnt_bal_information('US',
                                         'BALANCE'
                                         , NULL, element_information17),
                                         element_information17)--,
           --element_information18 = NVL(decode_elmnt_bal_information('US',
           --                              'ELEMENT'
           --                              , NULL, element_information18),
           --                              element_information18),
           --element_information19 = NVL(decode_elmnt_bal_information('US',
           --                              'ELEMENT'
           --                              , NULL, element_information19),
           --                              element_information19),
           --element_information20 = NVL(decode_elmnt_bal_information('US',
           --                              'ELEMENT'
           --                              , NULL, element_information20),
           --                              element_information20)
         WHERE element_type_id = pay_rec.element_type_id;

      ELSIF pay_rec.element_information_category = 'US_INVOLUNTARY DEDUCTIONS'  THEN
         UPDATE pay_element_types_f
         SET
           --element_information5 = NVL(decode_elmnt_bal_information('US',
           --                              'ELEMENT'
           --                              , NULL, element_information5),
           --                              element_information5),
           element_information8 = NVL(decode_elmnt_bal_information('US',
                                         'BALANCE'
                                         , NULL, element_information8),
                                         element_information8),
           element_information10 = NVL(decode_elmnt_bal_information('US',
                                         'BALANCE'
                                         , NULL, element_information10),
                                         element_information10),
           element_information11 = NVL(decode_elmnt_bal_information('US',
                                         'BALANCE'
                                         , NULL, element_information11),
                                         element_information11),
           element_information12 = NVL(decode_elmnt_bal_information('US',
                                         'BALANCE'
                                         , NULL, element_information12),
                                         element_information12),
           element_information13 = NVL(decode_elmnt_bal_information('US',
                                         'BALANCE'
                                         , NULL, element_information13),
                                         element_information13),
           element_information14 = NVL(decode_elmnt_bal_information('US',
                                         'BALANCE'
                                         , NULL, element_information14),
                                         element_information14),
           element_information15 = NVL(decode_elmnt_bal_information('US',
                                         'BALANCE'
                                         , NULL, element_information15),
                                         element_information15),
           element_information16 = NVL(decode_elmnt_bal_information('US',
                                         'BALANCE'
                                         , NULL, element_information16),
                                         element_information16),
           element_information17 = NVL(decode_elmnt_bal_information('US',
                                         'BALANCE'
                                         , NULL, element_information17),
                                         element_information17)--,
           --element_information18 = NVL(decode_elmnt_bal_information('US',
           --                              'ELEMENT'
           --                              , NULL, element_information18),
           --                              element_information18),
           --element_information19 = NVL(decode_elmnt_bal_information('US',
           --                              'ELEMENT'
           --                              , NULL, element_information19),
           --                              element_information19),
           --element_information20 = NVL(decode_elmnt_bal_information('US',
           --                              'ELEMENT'
           --                              , NULL, element_information20),
           --                              element_information20)
         WHERE element_type_id = pay_rec.element_type_id;

      ELSIF pay_rec.element_information_category = 'US_NON-PAYROLL PAYMENTS'
      THEN
         UPDATE pay_element_types_f
         SET element_information10 = NVL(decode_elmnt_bal_information('US',
                                         'BALANCE'
                                         , NULL, element_information10),
                                         element_information10),
           element_information16 = NVL(decode_elmnt_bal_information('US',
                                         'BALANCE'
                                         , NULL, element_information16),
                                         element_information16),
           element_information17 = NVL(decode_elmnt_bal_information('US',
                                         'BALANCE'
                                         , NULL, element_information17),
                                         element_information17)--,
           --element_information18 = NVL(decode_elmnt_bal_information('US',
           --                              'ELEMENT'
           --                              , NULL, element_information18),
           --                              element_information18),
           --element_information19 = NVL(decode_elmnt_bal_information('US',
           --                              'ELEMENT'
           --                              , NULL, element_information19),
           --                              element_information19),
           --element_information20 = NVL(decode_elmnt_bal_information('US',
           --                              'ELEMENT'
           --                              , NULL, element_information20),
           --                              element_information20)
         WHERE element_type_id = pay_rec.element_type_id;

      ELSIF pay_rec.element_information_category = 'US_PRE-TAX DEDUCTIONS'
      THEN
         UPDATE pay_element_types_f
         SET element_information10 = NVL(decode_elmnt_bal_information('US',
                                         'BALANCE'
                                         , NULL, element_information10),
                                         element_information10),
           element_information11 = NVL(decode_elmnt_bal_information('US',
                                         'BALANCE'
                                         , NULL, element_information11),
                                         element_information11),
           element_information12 = NVL(decode_elmnt_bal_information('US',
                                         'BALANCE'
                                         , NULL, element_information12),
                                         element_information12),
           element_information13 = NVL(decode_elmnt_bal_information('US',
                                         'BALANCE'
                                         , NULL, element_information13),
                                         element_information13),
           element_information14 = NVL(decode_elmnt_bal_information('US',
                                         'BALANCE'
                                         , NULL, element_information14),
                                         element_information14),
           element_information15 = NVL(decode_elmnt_bal_information('US',
                                         'BALANCE'
                                         , NULL, element_information15),
                                         element_information15),
           element_information16 = NVL(decode_elmnt_bal_information('US',
                                         'BALANCE'
                                         , NULL, element_information16),
                                         element_information16),
           element_information17 = NVL(decode_elmnt_bal_information('US',
                                         'BALANCE'
                                         , NULL, element_information17),
                                         element_information17)--,
           --element_information18 = NVL(decode_elmnt_bal_information('US',
           --                              'ELEMENT'
           --                              , NULL, element_information18),
           --                              element_information18),
           --element_information19 = NVL(decode_elmnt_bal_information('US',
           --                              'ELEMENT'
           --                              , NULL, element_information19),
           --                              element_information19),
           --element_information20 = NVL(decode_elmnt_bal_information('US',
           --                              'ELEMENT'
           --                              , NULL, element_information20),
           --                              element_information20)
         WHERE element_type_id = pay_rec.element_type_id;

      ELSIF pay_rec.element_information_category = 'US_PTO ACCRUALS'
      THEN
         UPDATE pay_element_types_f
         SET element_information10 = NVL(decode_elmnt_bal_information('US',
                                         'BALANCE'
                                         , NULL, element_information10),
                                         element_information10)
         WHERE element_type_id = pay_rec.element_type_id;

      ELSIF pay_rec.element_information_category = 'US_SUPPLEMENTAL EARNINGS'
      THEN
         UPDATE pay_element_types_f
         SET element_information10 = NVL(decode_elmnt_bal_information('US',
                                         'BALANCE'
                                         , NULL, element_information10),
                                         element_information10),
           element_information12 = NVL(decode_elmnt_bal_information('US',
                                         'BALANCE'
                                         , NULL, element_information12),
                                         element_information12),
           element_information16 = NVL(decode_elmnt_bal_information('US',
                                         'BALANCE'
                                         , NULL, element_information16),
                                         element_information16),
           element_information17 = NVL(decode_elmnt_bal_information('US',
                                         'BALANCE'
                                         , NULL, element_information17),
                                         element_information17)--,
           --element_information18 = NVL(decode_elmnt_bal_information('US',
           --                              'ELEMENT'
           --                              , NULL, element_information18),
           --                              element_information18),
           --element_information19 = NVL(decode_elmnt_bal_information('US',
           --                              'ELEMENT'
           --                              , NULL, element_information19),
           --                              element_information19),
           --element_information20 = NVL(decode_elmnt_bal_information('US',
           --                              'ELEMENT'
           --                              , NULL, element_information20),
           --                              element_information20)
         WHERE element_type_id = pay_rec.element_type_id;

      ELSIF pay_rec.element_information_category = 'US_TAX DEDUCTIONS'
      THEN
         UPDATE pay_element_types_f
         SET element_information10 = NVL(decode_elmnt_bal_information('US',
                                         'BALANCE'
                                         , NULL, element_information10),
                                         element_information10),
           element_information11 = NVL(decode_elmnt_bal_information('US',
                                         'BALANCE'
                                         , NULL, element_information11),
                                         element_information11),
           element_information12 = NVL(decode_elmnt_bal_information('US',
                                         'BALANCE'
                                         , NULL, element_information12),
                                         element_information12),
           element_information13 = NVL(decode_elmnt_bal_information('US',
                                         'BALANCE'
                                         , NULL, element_information13),
                                         element_information13),
           element_information14 = NVL(decode_elmnt_bal_information('US',
                                         'BALANCE'
                                         , NULL, element_information14),
                                         element_information14),
           element_information15 = NVL(decode_elmnt_bal_information('US',
                                         'BALANCE'
                                         , NULL, element_information15),
                                         element_information15),
           element_information16 = NVL(decode_elmnt_bal_information('US',
                                         'BALANCE'
                                         , NULL, element_information16),
                                         element_information16),
           element_information17 = NVL(decode_elmnt_bal_information('US',
                                         'BALANCE'
                                         , NULL, element_information17),
                                         element_information17),
           element_information18 = NVL(decode_elmnt_bal_information('US',
                                         'BALANCE'
                                         , NULL, element_information18),
                                         element_information18),
           element_information19 = NVL(decode_elmnt_bal_information('US',
                                         'BALANCE'
                                         , NULL, element_information19),
                                         element_information19)
         WHERE element_type_id = pay_rec.element_type_id;

      ELSIF pay_rec.element_information_category = 'US_VOLUNTARY DEDUCTIONS'
      THEN
         UPDATE pay_element_types_f
         SET element_information10 = NVL(decode_elmnt_bal_information('US',
                                         'BALANCE'
                                         , NULL, element_information10),
                                         element_information10),
           element_information11 = NVL(decode_elmnt_bal_information('US',
                                         'BALANCE'
                                         , NULL, element_information11),
                                         element_information11),
           element_information12 = NVL(decode_elmnt_bal_information('US',
                                         'BALANCE'
                                         , NULL, element_information12),
                                         element_information12),
           element_information13 = NVL(decode_elmnt_bal_information('US',
                                         'BALANCE'
                                         , NULL, element_information13),
                                         element_information13),
           element_information14 = NVL(decode_elmnt_bal_information('US',
                                         'BALANCE'
                                         , NULL, element_information14),
                                         element_information14),
           element_information16 = NVL(decode_elmnt_bal_information('US',
                                         'BALANCE'
                                         , NULL, element_information16),
                                         element_information16),
           element_information17 = NVL(decode_elmnt_bal_information('US',
                                         'BALANCE'
                                         , NULL, element_information17),
                                         element_information17)--,
           --element_information18 = NVL(decode_elmnt_bal_information('US',
           --                              'ELEMENT'
           --                              , NULL, element_information18),
           --                              element_information18),
           --element_information19 = NVL(decode_elmnt_bal_information('US',
           --                              'ELEMENT'
           --                              , NULL, element_information19),
           --                              element_information19),
           --element_information20 = NVL(decode_elmnt_bal_information('US',
           --                              'ELEMENT'
           --                              , NULL, element_information20),
           --                              element_information20)
         WHERE element_type_id = pay_rec.element_type_id;

      END IF;
   END LOOP;
END IF;

END translate_us_ele_dev_df;
----------------------------------------------------------------------
-- PROCEDURE TRANSLATE_CA_ELE_DEV_DF
-- This is a copy of translate_us_ele_dev_df, modified for CA use
----------------------------------------------------------------------
PROCEDURE translate_ca_ele_dev_df(p_mode VARCHAR2)
IS
   CURSOR csr_hr_s_element_details IS
   SELECT element_type_id,
      element_information_category,
      element_information10
   FROM hr_s_element_types_f
   WHERE legislation_code = 'CA'
   AND element_information_category IS NOT NULL
   FOR UPDATE OF element_information10 NOWAIT;

   CURSOR csr_pay_element_details IS
   SELECT element_type_id,
      element_information_category,
      element_information10
   FROM pay_element_types_f
   WHERE legislation_code = 'CA'
   AND element_information_category IS NOT NULL
   FOR UPDATE OF element_information10 NOWAIT;

BEGIN
   IF p_mode = 'ID_TO_NAME' THEN
   FOR hr_s_rec IN csr_hr_s_element_details
   LOOP
      IF hr_s_rec.element_information_category = 'CA_EARNINGS'
      THEN
--
         UPDATE hr_s_element_types_f
         SET element_information10 = NVL(decode_elmnt_bal_information('CA',
                                         'BALANCE'
                                         , element_information10, NULL),
                                         element_information10),
           element_information12 = NVL(decode_elmnt_bal_information('CA',
                                         'BALANCE'
                                         , element_information12, NULL),
                                         element_information12)
         WHERE element_type_id = hr_s_rec.element_type_id;

      ELSIF hr_s_rec.element_information_category = 'CA_TAXABLE BENEFITS'
      THEN

         UPDATE hr_s_element_types_f
         SET element_information10 = NVL(decode_elmnt_bal_information('CA',
                                         'BALANCE'
                                         , element_information10, NULL),
                                         element_information10),
           element_information12 = NVL(decode_elmnt_bal_information('CA',
                                         'BALANCE'
                                         , element_information12, NULL),
                                         element_information12)
         WHERE element_type_id = hr_s_rec.element_type_id;

      ELSIF hr_s_rec.element_information_category = 'CA_INVOLUNTARY DEDUCTIONS'
 THEN
         UPDATE hr_s_element_types_f
         SET
           element_information10 = NVL(decode_elmnt_bal_information('CA',
                                         'BALANCE'
                                         , element_information10, NULL),
                                         element_information10),
           element_information11 = NVL(decode_elmnt_bal_information('CA',
                                         'BALANCE'
                                         , element_information11, NULL),
                                         element_information11),
           element_information12 = NVL(decode_elmnt_bal_information('CA',
                                         'BALANCE'
                                         , element_information12, NULL),
                                         element_information12),
           element_information13 = NVL(decode_elmnt_bal_information('CA',
                                         'BALANCE'
                                         , element_information13, NULL),
                                         element_information13),
           element_information15 = NVL(decode_elmnt_bal_information('CA',
                                         'BALANCE'
                                         , element_information15, NULL),
                                         element_information15),
           element_information16 = NVL(decode_elmnt_bal_information('CA',
                                         'BALANCE'
                                         , element_information16, NULL),
                                         element_information16),
           element_information17 = NVL(decode_elmnt_bal_information('CA',
                                         'BALANCE'
                                         , element_information17, NULL),
                                         element_information17)
         WHERE element_type_id = hr_s_rec.element_type_id;

      ELSIF hr_s_rec.element_information_category = 'CA_NON-PAYROLL PAYMENTS'
      THEN
         UPDATE hr_s_element_types_f
         SET element_information10 = NVL(decode_elmnt_bal_information('CA',
                                         'BALANCE'
                                         , element_information10, NULL),
                                         element_information10)
         WHERE element_type_id = hr_s_rec.element_type_id;

      ELSIF hr_s_rec.element_information_category = 'CA_PRE-TAX DEDUCTIONS'
      THEN
         UPDATE hr_s_element_types_f
         SET element_information10 = NVL(decode_elmnt_bal_information('CA',
                                         'BALANCE'
                                         , element_information10, NULL),
                                         element_information10),
           element_information11 = NVL(decode_elmnt_bal_information('CA',
                                         'BALANCE'
                                         , element_information11, NULL),
                                         element_information11),
           element_information12 = NVL(decode_elmnt_bal_information('CA',
                                         'BALANCE'
                                         , element_information12, NULL),
                                         element_information12),
           element_information13 = NVL(decode_elmnt_bal_information('CA',
                                         'BALANCE'
                                         , element_information13, NULL),
                                         element_information13)
         WHERE element_type_id = hr_s_rec.element_type_id;


      ELSIF hr_s_rec.element_information_category = 'CA_SUPPLEMENTAL EARNINGS'
      THEN
         UPDATE hr_s_element_types_f
         SET element_information10 = NVL(decode_elmnt_bal_information('CA',
                                         'BALANCE'
                                         , element_information10, NULL),
                                         element_information10),
           element_information12 = NVL(decode_elmnt_bal_information('CA',
                                         'BALANCE'
                                         , element_information12, NULL),
                                         element_information12)
         WHERE element_type_id = hr_s_rec.element_type_id;


      ELSIF hr_s_rec.element_information_category = 'CA_VOLUNTARY DEDUCTIONS'
      THEN
         UPDATE hr_s_element_types_f
         SET element_information10 = NVL(decode_elmnt_bal_information('CA',
                                         'BALANCE'
                                         , element_information10, NULL),
                                         element_information10),
           element_information11 = NVL(decode_elmnt_bal_information('CA',
                                         'BALANCE'
                                         , element_information11, NULL),
                                         element_information11),
           element_information12 = NVL(decode_elmnt_bal_information('CA',
                                         'BALANCE'
                                         , element_information12, NULL),
                                         element_information12),
           element_information13 = NVL(decode_elmnt_bal_information('CA',
                                         'BALANCE'
                                         , element_information13, NULL),
                                         element_information13)
         WHERE element_type_id = hr_s_rec.element_type_id;

      END IF;
   END LOOP;
   ELSE /* NAME_TO_ID */
   FOR pay_rec IN csr_pay_element_details
   LOOP
      IF pay_rec.element_information_category = 'CA_EARNINGS'
      THEN

         UPDATE pay_element_types_f
         SET element_information10 = NVL(decode_elmnt_bal_information('CA',
                                       'BALANCE', NULL, element_information10),
                                           element_information10),
           element_information12 = NVL(decode_elmnt_bal_information('CA',
                                      'BALANCE', NULL, element_information12),
                                           element_information12)
         WHERE element_type_id = pay_rec.element_type_id;

      ELSIF pay_rec.element_information_category = 'CA_TAXABLE BENEFITS'
      THEN

         UPDATE pay_element_types_f
         SET element_information10 = NVL(decode_elmnt_bal_information('CA',
                                         'BALANCE'
                                         , NULL, element_information10),
                                         element_information10),
           element_information12 = NVL(decode_elmnt_bal_information('CA',
                                         'BALANCE'
                                         , NULL, element_information12),
                                         element_information12)
         WHERE element_type_id = pay_rec.element_type_id;

      ELSIF pay_rec.element_information_category = 'CA_INVOLUNTARY DEDUCTIONS'
THEN
         UPDATE pay_element_types_f
         SET
           element_information10 = NVL(decode_elmnt_bal_information('CA',
                                         'BALANCE'
                                         , NULL, element_information10),
                                         element_information10),
           element_information11 = NVL(decode_elmnt_bal_information('CA',
                                         'BALANCE'
                                         , NULL, element_information11),
                                         element_information11),
           element_information12 = NVL(decode_elmnt_bal_information('CA',
                                         'BALANCE'
                                         , NULL, element_information12),
                                         element_information12),
           element_information13 = NVL(decode_elmnt_bal_information('CA',
                                         'BALANCE'
                                         , NULL, element_information13),
                                         element_information13),
           element_information15 = NVL(decode_elmnt_bal_information('CA',
                                         'BALANCE'
                                         , NULL, element_information15),
                                         element_information15),
           element_information16 = NVL(decode_elmnt_bal_information('CA',
                                         'BALANCE'
                                         , NULL, element_information16),
                                         element_information16),
           element_information17 = NVL(decode_elmnt_bal_information('CA',
                                         'BALANCE'
                                         , NULL, element_information17),
                                         element_information17)
         WHERE element_type_id = pay_rec.element_type_id;

      ELSIF pay_rec.element_information_category = 'CA_NON-PAYROLL PAYMENTS'
      THEN
         UPDATE pay_element_types_f
         SET element_information10 = NVL(decode_elmnt_bal_information('CA',
                                         'BALANCE'
                                         , NULL, element_information10),
                                         element_information10)
         WHERE element_type_id = pay_rec.element_type_id;

      ELSIF pay_rec.element_information_category = 'CA_PRE-TAX DEDUCTIONS'
      THEN
         UPDATE pay_element_types_f
         SET element_information10 = NVL(decode_elmnt_bal_information('CA',
                                         'BALANCE'
                                         , NULL, element_information10),
                                         element_information10),
           element_information11 = NVL(decode_elmnt_bal_information('CA',
                                         'BALANCE'
                                         , NULL, element_information11),
                                         element_information11),
           element_information12 = NVL(decode_elmnt_bal_information('CA',
                                         'BALANCE'
                                         , NULL, element_information12),
                                         element_information12),
           element_information13 = NVL(decode_elmnt_bal_information('CA',
                                         'BALANCE'
                                         , NULL, element_information13),
                                         element_information13)
         WHERE element_type_id = pay_rec.element_type_id;


      ELSIF pay_rec.element_information_category = 'CA_SUPPLEMENTAL EARNINGS'
      THEN
         UPDATE pay_element_types_f
         SET element_information10 = NVL(decode_elmnt_bal_information('CA',
                                         'BALANCE'
                                         , NULL, element_information10),
                                         element_information10),
           element_information12 = NVL(decode_elmnt_bal_information('CA',
                                         'BALANCE'
                                         , NULL, element_information12),
                                         element_information12)
         WHERE element_type_id = pay_rec.element_type_id;


      ELSIF pay_rec.element_information_category = 'CA_VOLUNTARY DEDUCTIONS'
      THEN
         UPDATE pay_element_types_f
         SET element_information10 = NVL(decode_elmnt_bal_information('CA',
                                         'BALANCE'
                                         , NULL, element_information10),
                                         element_information10),
           element_information11 = NVL(decode_elmnt_bal_information('CA',
                                         'BALANCE'
                                         , NULL, element_information11),
                                         element_information11),
           element_information12 = NVL(decode_elmnt_bal_information('CA',
                                         'BALANCE'
                                         , NULL, element_information12),
                                         element_information12),
           element_information13 = NVL(decode_elmnt_bal_information('CA',
                                         'BALANCE'
                                         , NULL, element_information13),
                                         element_information13)
         WHERE element_type_id = pay_rec.element_type_id;

      END IF;
   END LOOP;
END IF;

END translate_ca_ele_dev_df;

--****************************************************************************
-- OVERALL INSTALLATION PROCEDURE FOR LEGISLATIVE DELIVERY
--****************************************************************************

PROCEDURE install(p_phase number)
---------------------------------
IS
    -- Main driving procedure to execute specific legislative routines.

 CURSOR c_legs IS
  select legislation_code
  from   hr_s_history;

   BEGIN

    hr_legislation.hrrunprc_trace_on;
    hr_utility.trace('start install_leg_loc: ' || to_char(p_phase));
    hr_legislation.hrrunprc_trace_off;

    FOR r_legs IN c_legs LOOP

        hr_legislation.hrrunprc_trace_on;
        hr_utility.trace('start install_leg_loc: leg_code: ' || r_legs.legislation_code ||
                         ': ' || to_char(p_phase));
        hr_legislation.hrrunprc_trace_off;

	driving_legislation := r_legs.legislation_code;

   	IF p_phase = 1 OR p_phase = 2 THEN


            hr_legislation.hrrunprc_trace_on;
            hr_utility.trace('start install_leg_rules: ' || to_char(p_phase));
            hr_legislation.hrrunprc_trace_off;

	    install_leg_rules(p_phase); 	--install legislation rules

	    IF driving_legislation = 'US' THEN


                hr_legislation.hrrunprc_trace_on;
                hr_utility.trace('start install_state_rules: ' || to_char(p_phase));
                hr_legislation.hrrunprc_trace_off;

   	        install_state_rules(p_phase); --install pay_state_rules

                hr_legislation.hrrunprc_trace_on;
                hr_utility.trace('start install_tax_rules: ' || to_char(p_phase));
                hr_legislation.hrrunprc_trace_off;

   	        install_tax_rules(p_phase);   --install pay_taxability_rules

                hr_legislation.hrrunprc_trace_on;
                hr_utility.trace('start install_surcharges: ' || to_char(p_phase));
                hr_legislation.hrrunprc_trace_off;

   	        install_surcharges(p_phase);  --install Wcomp state surcharges

                hr_legislation.hrrunprc_trace_on;
                hr_utility.trace('start install_us_new: ' || to_char(p_phase));
                hr_legislation.hrrunprc_trace_off;

		install_us_new(p_phase);      --install new US misc

	    END IF;

            IF driving_legislation = 'CA' THEN
            --

              hr_legislation.hrrunprc_trace_on;
              hr_utility.trace('start install_tax_rules: ' || to_char(p_phase));
              hr_legislation.hrrunprc_trace_off;

              install_tax_rules(p_phase); -- install pay_taxability_rules
              --
            END IF;
            --
            IF driving_legislation = 'GB' THEN

                hr_legislation.hrrunprc_trace_on;
                hr_utility.trace('start gb scl flex delete: ' || to_char(p_phase));
                hr_legislation.hrrunprc_trace_off;

                 --the gb scl flex only needs to appear at payroll sites
                 delete from pay_legislation_rules
                 where  legislation_code = 'GB'
                 and    rule_type = 'S'
                 and    not exists
                        (select null
                         from   fnd_product_installations
                         where  application_id = 801
                         and    status = 'I'
                        );


                 --The GB org tax details only needs to appear at payroll sites
                 delete from hr_org_info_types_by_class
                 where  org_information_type = 'Tax Details References'
                 and    ORG_CLASSIFICATION = 'HR_BG'
                 and    not exists
                        (select null
                         from   fnd_product_installations
                         where  application_id = 801
                         and    status = 'I'
                        );

            END IF; --end GB specific logic


	END IF; --end phase control check

        hr_legislation.hrrunprc_trace_on;
        hr_utility.trace('end install_leg_loc: leg_code: ' || r_legs.legislation_code ||
                         ': ' || to_char(p_phase));
        hr_legislation.hrrunprc_trace_off;

    END LOOP;  -- c_legs cursor

    hr_legislation.hrrunprc_trace_on;
    hr_utility.trace('exit install_leg_loc: ' || to_char(p_phase));
    hr_legislation.hrrunprc_trace_off;

    END install;

END hr_legislation_local;

/
