--------------------------------------------------------
--  DDL for Package Body HR_LEGISLATION_BENEFITS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."HR_LEGISLATION_BENEFITS" AS
/* $Header: pelegben.pkb 120.2.12000000.1 2007/01/21 23:59:22 appldev ship $ */
--
-- Copyright (c) Oracle Corporation 1991, 1992, 1993. All rights reserved.
--
--
-- NAME
--    pelegben.pkb
--
-- DESCRIPTION
--     Procedures required to deliver startup data for
--     COBRA Qualifying Events
--     Benefit Classifications
--     Valid Dependent Types
--
-- MODIFIED
--	80.1  J.Rhodes     07-10-1993	- Created
--	80.2  I.Carline    15-11-1993   - Debugged for US Bechtel delivery
--	80.3  Rod Fine     16-12-1993   - Put AS on same line as CREATE stmt
--					  to workaround export WWBUG #178613.
--
--      70.1  Ian Carline  06-Jun-1994  - per 7.0 merged with 8.0
--                                        rewrite.
--      70.2  Ian Carline  07-Jun-1994  - Added check_next_sequence logic
--      70.3  Ian Carline  09-Jun-1994  - Extended check_next_sequence logic.
--      70.4  Rod Fine     19-Sep-1994  - Removed the unnecessary cartesian
--                                        product join on all selects to get
--                                        the starting point for the sequence
--                                        number - improves performance.
--      70.6  Rod Fine     23-Nov-1994  - Suppressed index on business_group_id
--      70.6  M. Stewart   23-Sep-1996  - Updated table names from STU_ to HR_S_
--	70.7  Tim Eyres	   02-01-1997	- Moved arcs header to directly after
--                                        'create or replace' line
--                                        Fix to bug 434902
--      70.9  Tim Eyres    02-01-1997     Correction to version number
--     110.1  mstewart     23-07-1997     Removed show error and select from
--                                        user errors statements (R11)
--                                        (R10 version # 70.10)
--     11.5.4 tmathers     07/20/99       Made v_seq_number and others size
--                                        15, as 9 creates numeric overflow.
--     115.5  T.Battoo     08-Feb-2000    changed crt_exc so calls
--                                        hr_legislation.insert_hr_stu_exceptions
--     115.6  D.Vickers    May 2001       Support for parallel hrglobal and
--                                        better debugging into HR_STU_EXCEPTIONS
--     115.7  D.Vickers    14-Jun-2001    Bug fix 1803867
--     115.8  D.Vickers    18-Jun-2001    to_chars on hr_s_app_ownerships
--     115.9  D.Vickers    25-OCT-2001    performance-use temp HR_S indexes
--     115.10 D.Vickers    21-NOV-2001    del hr_s_app_ownerships commented
--     115.11 D.VIckers    18-NOV-2002    added check_next_sequence call to
--                                        benefit_classifications
-- 115.12     DVickers     12-DEC-2002    added check_next_sequence call to bc
-- 115.13     DVickers     14-MAR-2003  explicit hrsao.key_value conversion
-- 115.14     DVickers     24-FEB-2005  Trace improved
-- 115.15     DVickers     12-MAY-2005  remove auto trace in exceptions
-- 115.16     DVickers     10-AUG-2005  debug switch
-- 115.17     divicker     21-NOV-2005  short term fix for 4728513 - make
--                                      update_uid use 50000000
---------------------------------------------------------------------------

--****************************************************************************
-- INSTALLATION PROCEDURE FOR : PER_COBRA_QFYING_EVENTS
--****************************************************************************


PROCEDURE install_cobra_qfying_events(p_phase IN NUMBER)
--------------------------------------------------------
IS
    -- Install procedure to transfer startup delivered per_cobra_qfying_events_f
    -- into a live account, and remove the then delivered rows from the delivery
    -- account.
    -- This procedure is called in two phase. Only in the second phase are
    -- details transferred into live tables. The parameter p_phase holds
    -- the phase number.

    row_in_error exception;
    l_current_proc varchar2(80) := 'hr_legislation.install_cobra_qfying_events';
    l_new_cqe_id number(15);
    l_null_return varchar2(1);

    CURSOR c_distinct
    IS
	-- Select statement used for the main loop. Each row return is used
	-- as the commit unit, since each true primary key may have many date
	-- effective rows for it.

	-- The selected primary key is then passed into the second driving
	-- cursor statement as a parameter, and all date effective rows for
	-- this primary key are then selected.

        select max(effective_end_date) c_end
        ,      qualifying_event_id c_surrogate_key
        ,      qualifying_event c_true_key
        ,      legislation_code c_leg_code
        ,      legislation_subgroup c_leg_sgrp
        from   hr_s_cobra_qfying_events_f
        group  by qualifying_event_id
        ,         qualifying_event
        ,         legislation_code
        ,         legislation_subgroup;

    CURSOR c_each_row (pc_qualifying_event_id varchar2)
    IS
	-- selects all date effective rows for the current true primary key
	-- The primary key has already been selected using the above cursor.
	-- This cursor accepts the primary key as a parameter and selects all
	-- date effective rows for it.

	select *
        from hr_s_cobra_qfying_events_f
	where  qualifying_event_id = pc_qualifying_event_id;

    -- These records are defined here so all sub procedures may use the
    -- values selected. This saves the need for all sub procedures to have
    -- a myriad of parameters passed. The cursors are controlled in FOR
    -- cursor LOOPs. When a row is returned the whole record is copied into
    -- these record definitions.

    r_distinct c_distinct%ROWTYPE;
    r_each_row c_each_row%ROWTYPE;


    PROCEDURE check_next_sequence
    -----------------------------
    IS

	v_sequence_number number(15);
	v_min_delivered number(15);
	v_max_delivered number(15);

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


	    select distinct null
	    into   l_null_return
	    from   per_cobra_qfying_events_f a
	    where  exists
		(select null
		 from   hr_s_cobra_qfying_events_f b
		 where  a.qualifying_event_id = b.qualifying_event_id
		);

	    --conflict may exist
	    --update all qualifying_event_id's to remove conflict

	    update hr_s_cobra_qfying_events_f
	    set    qualifying_event_id = qualifying_event_id - 50000000;

	    update hr_s_application_ownerships
	    set    key_value = key_value - 50000000
	    where  key_name = 'QUALIFYING_EVENT_ID';

	EXCEPTION WHEN NO_DATA_FOUND THEN NULL;

	END; --check of qualifying_event_id



	select min(qualifying_event_id) - (count(*) *3)
	,      max(qualifying_event_id) + (count(*) *3)
	into   v_min_delivered
	,      v_max_delivered
	from   hr_s_cobra_qfying_events_f;

	select per_cobra_qfying_events_s.nextval
	into   v_sequence_number
	from   dual;

	WHILE v_sequence_number BETWEEN v_min_delivered AND v_max_delivered LOOP


	    select per_cobra_qfying_events_s.nextval
	    into   v_sequence_number
	    from   dual;

	END LOOP;

    END check_next_sequence;


    PROCEDURE crt_exc (exception_type IN varchar2)
    ----------------------------------------------
    IS
	-- Reports any exceptions during the delivery of startup data to
	-- PER_COBRA_QFYING_EVENTS

    BEGIN
	-- When the installation procedures encounter an error that cannot
	-- be handled, an exception is raised and all work is rolled back
	-- to the last savepoint. The installation process then continues
	-- with the next primary key to install. The same exception will
	-- not be raised more than once.


   	rollback to new_qualifying_event;

	hr_legislation.insert_hr_stu_exceptions('per_cobra_qfying_events_f'
        ,      r_distinct.c_surrogate_key
        ,      exception_type
        ,      r_distinct.c_true_key);

    END crt_exc;

    PROCEDURE remove(v_id IN number)
    --------------------------------
    IS
	-- Subprogram to delete a row from the delivery tables, and all child
	-- application ownership rows

    BEGIN


   	delete from hr_s_cobra_qfying_events_f
   	where  qualifying_event_id = v_id;

    END remove;

    PROCEDURE update_uid
    --------------------
    IS
	-- Subprogram to update surrogate UID and all occurrences in child rows

    BEGIN

	-- See if this primary key is already installed. If so then the sorrogate
	-- key of the delivered row must be updated to the value in the installed
	-- tables. If the row is not already present then select the next value
	-- from the sequence. In either case all rows for this primary key must
	-- be updated, as must all child references to the old surrogate uid.


   	BEGIN
	    select distinct qualifying_event_id
	    into   l_new_cqe_id
	    from   per_cobra_qfying_events_f
	    where  qualifying_event = r_distinct.c_true_key
	    and    business_Group_id is null
	    and    legislation_code = r_distinct.c_leg_code;

	EXCEPTION WHEN NO_DATA_FOUND THEN


	   select per_cobra_qfying_events_s.nextval
	   into   l_new_cqe_id
	   from   dual;

           WHEN TOO_MANY_ROWS THEN
           hr_legislation.hrrunprc_trace_on;
           hr_utility.trace('qualifying_event_id TMR: ' || r_distinct.c_true_key);
           hr_legislation.hrrunprc_trace_off;
           raise;


   	END;

   	update hr_s_cobra_qfying_events_f
   	set    qualifying_event_id = l_new_cqe_id
   	where  qualifying_event_id = r_distinct.c_surrogate_key;

   	update hr_s_application_ownerships
   	set    key_value = to_char(l_new_cqe_id)
   	where  key_value = to_char(r_distinct.c_surrogate_key)
   	and    key_name = 'QUALIFYING_EVENT_ID';

    END update_uid;

    FUNCTION valid_ownership RETURN BOOLEAN
    ---------------------------------------
    IS
	-- Test ownership of this current row

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


	BEGIN

	    -- Perform a check to see if the primary key has been created within
	    -- a visible business group. Ie: the business group is for the same
	    -- legislation as the delivered row, or the delivered row has a null
	    -- legislation. If no rows are returned then the primary key has not
	    -- already been created by a user.


	    select distinct null
	    into   l_null_return
	    from   per_cobra_qfying_events_f a
	    where  a.business_group_id is not null
	    and    a.qualifying_event = r_distinct.c_true_key
            and exists (select null from per_business_groups b
              where b.business_group_id = a.business_group_id
              and b.legislation_code = nvl(r_distinct.c_leg_code,b.legislation_code));


	    crt_exc('Row already created in a business group');

	    -- Indicate this row is not to be transferred

	    return FALSE;

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
	    from   per_cobra_qfying_events_f
	    where  qualifying_event = r_distinct.c_true_key
	    and    legislation_code <> r_distinct.c_leg_code
	    and   (legislation_code is null
		   or r_distinct.c_leg_code is null );



	    crt_exc('Row already created for a visible legislation');

	    -- Indicates this row is not to be transferred

	    return FALSE;

	EXCEPTION WHEN NO_DATA_FOUND THEN

	    null;

	END;

	-- The last check examines the product installation table, and the
	-- ownership details for the delivered row. By examining these
	-- tables the row is either deleted or not. If the delivered row
	-- is 'stamped' with a legislation subgroup, then a chweck must be
	-- made to see if that subgroup is active or not. This check only
	-- needs to be performed in phase 1, since once this decision is
	-- made, it is pontless to perform this logic again.
	-- The exception is raised within this procedure if no rows are returned
	-- in this select statement. If no rows are returned then one of the
	-- following is true:
	--     1. No ownership parameters are defined.
	--     2. The products, for which owning parameters are defined, are not
	--        installed with as status of 'I'.
	--     3. The data is defined for a legislation subgroup that is not active.

   	IF p_phase <> 1 THEN
	    return TRUE;
	END IF;


       if (r_distinct.c_leg_sgrp is null) then
	select null --if exception raised then this row is not needed
	into   l_null_return
	from   dual
	where  exists
	(select null
	from   hr_s_application_ownerships a
	,      fnd_product_installations b
	,      fnd_application c
	where  a.key_name = 'QUALIFYING_EVENT_ID'
	and    a.key_value = r_distinct.c_surrogate_key
	and    a.product_name = c.application_short_name
	and    c.application_id = b.application_id
        and    ((b.status = 'I' and c.application_short_name <> 'PQP')
                or
                (b.status in ('I', 'S') and c.application_short_name = 'PQP')));
      else
        select null --if exception raised then this row is not needed
        into   l_null_return
        from   dual
        where  exists
        (select null
        from   hr_s_application_ownerships a
        ,      fnd_product_installations b
        ,      fnd_application c
        where  a.key_name = 'QUALIFYING_EVENT_ID'
        and    a.key_value = r_distinct.c_surrogate_key
        and    a.product_name = c.application_short_name
        and    c.application_id = b.application_id
        and    ((b.status = 'I' and c.application_short_name <> 'PQP')
                or
                (b.status in ('I', 'S') and c.application_short_name = 'PQP')))
        and  exists (
               select null
               from hr_legislation_subgroups d
               where d.legislation_code = r_distinct.c_leg_code
                and  d.legislation_subgroup = r_distinct.c_leg_sgrp
                and  d.active_inactive_flag = 'A' );
      end if;


	-- Indicates row is required

   	return TRUE;

    EXCEPTION WHEN NO_DATA_FOUND THEN

	-- Row not needed for any installed product


	remove(r_distinct.c_surrogate_key);

	-- Indicates row not needed

	return FALSE;

    END valid_ownership;

BEGIN

    -- Two loops are used here. The main loop which select distinct primary
    -- key rows and an inner loop which selects all date effective rows for the
    -- primary key. The inner loop is only required in phase two, since only
    -- in phase 2 are rows actually transferred. The logic reads as follows:

    --    - Only deal with rows which have correct ownership details and will
    --      not cause integrity problems (valid_ownership).

    --    - In Phase 1:
    --               - Delete delivery rows where the installed rows are identicle.
    --               - The UNION satement compares delivery rows to installed rows.
    --                 If the sub query returns any rows, then the delivered
    --                 tables and the installed tables are different.

    --    - In Phase 2:
    --               - Delete from the installed tables using the surrogate id.
    --               - If an installed row is to be replaced, the values of
    --                 the surrogate keys will be identicle at this stage.
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

    IF p_phase = 1 THEN
	check_next_sequence;
    END IF;

    FOR qualifying_events IN c_distinct LOOP

   	savepoint new_qualifying_event;

   	r_distinct := qualifying_events;

   	BEGIN

	    IF valid_ownership THEN

		-- This row is wanted


	   	IF p_phase = 1 THEN


		    -- Get new surrogate id and update child references

		    update_uid;

		ELSE

		    -- Phase = 2


		    delete from per_cobra_qfying_events_f
		    where  qualifying_event_id = r_distinct.c_surrogate_key;

		    FOR each_row IN c_each_row(r_distinct.c_surrogate_key)
		    LOOP

			r_each_row := each_row;


		  	insert into per_cobra_qfying_events_f
                   	(qualifying_event_id
                   	,effective_start_date
                   	,effective_end_date
                   	,business_group_id
                   	,legislation_code
                   	,elector
                   	,event_coverage
                   	,qualifying_event
                   	,legislation_subgroup
	           	,last_update_date
	           	,last_updated_by
	           	,last_update_login
	           	,created_by
	           	,creation_date
		   	)
		   	values
                   	(r_each_row.qualifying_event_id
                   	,r_each_row.effective_start_date
                   	,r_each_row.effective_end_date
                   	,r_each_row.business_group_id
                  	,r_each_row.legislation_code
                   	,r_each_row.elector
                   	,r_each_row.event_coverage
                   	,r_each_row.qualifying_event
                   	,r_each_row.legislation_subgroup
	           	,r_each_row.last_update_date
	           	,r_each_row.last_updated_by
	           	,r_each_row.last_update_login
	           	,r_each_row.created_by
	           	,r_each_row.creation_date
                   	);

		   	remove(r_distinct.c_surrogate_key);

		    END LOOP each_row;

		END IF;

	    END IF;

	EXCEPTION WHEN row_in_error THEN

	    rollback to new_formula_name;

	END;

    END LOOP formula_names;

END install_cobra_qfying_events;

--****************************************************************************
-- INSTALLATION PROCEDURE FOR : BEN_BENEFIT_CLASSIFICATIONS
--****************************************************************************

PROCEDURE install_ben_class(p_phase IN number)
----------------------------------------------
IS
    -- Install procedure to transfer startup benefit classifications into
    -- a live account.

    l_null_return varchar2(1); 		-- For 'select null' statements
    l_new_surrogate_key number(15); 	-- New surrogate key for the delivery row

    CURSOR stu			-- Selects all rows from startup entity
    IS
	select benefit_classification_name c_true_key
	,      rowid
	,      benefit_classification_id  c_surrogate_key
	,      business_group_id
	,      legislation_code           c_leg_code
	,      active_flag
	,      beneficiary_allowed_flag
	,      benefit_classification_type
	,      chargeable_flag
	,      cobra_flag
	,      contributions_used
	,      dependents_allowed_flag
	,      dflt_post_termination_rule
	,      dflt_processing_type
	,      ben_class_processing_rule
	,      comments
	,      last_update_date
	,      last_updated_by
	,      last_update_login
	,      created_by
	,      creation_date
	from   hr_s_benefit_classifications;

    stu_rec stu%ROWTYPE;


    PROCEDURE check_next_sequence
    -----------------------------
    IS

	v_sequence_number number(15);
	v_min_delivered number(15);
	v_max_delivered number(15);

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


	    select distinct null
	    into   l_null_return
	    from   ben_benefit_classifications a
	    where  exists
		(select null
		 from   hr_s_benefit_classifications b
		 where  a.benefit_classification_id=b.benefit_classification_id
		);

	    --conflict may exist
	    --update all benefit_classification_id's to remove conflict

	    update hr_s_benefit_classifications
	    set  benefit_classification_id=benefit_classification_id-50000000;

	   update hr_s_application_ownerships
	   set    key_value = key_value - 50000000
	   where  key_name = 'BENEFIT_CLASSIFICATION_ID';

	EXCEPTION WHEN NO_DATA_FOUND THEN NULL;

	END; --check of benefit_classification_id



	select min(benefit_classification_id) - (count(*) *3)
	,      max(benefit_classification_id) + (count(*) *3)
	into   v_min_delivered
	,      v_max_delivered
	from   hr_s_benefit_classifications;

	select ben_benefit_classifications_s.nextval
	into   v_sequence_number
	from   dual;

	WHILE
 	    v_sequence_number BETWEEN v_min_delivered AND v_max_delivered
	LOOP


	    select ben_benefit_classifications_s.nextval
	    into   v_sequence_number
	    from   dual;

	END LOOP;

    END check_next_sequence;

    PROCEDURE crt_exc (exception_type IN varchar2)
    ----------------------------------------------
    IS
	-- Reports any exceptions during the delivery of startup data to
	-- BEN_BENEFIT_CLASSIFICATIONS

    BEGIN
	-- When the installation procedures encounter an error that cannot
	-- be handled, an exception is raised and all work is rolled back
	-- to the last savepoint. The installation process then continues
	-- with the next primary key to install. The same exception will
	-- not be raised more than once.

	rollback to new_classification_name;

	hr_legislation.insert_hr_stu_exceptions('ben_benefit_classifications'
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


	    select distinct benefit_classification_id
	    into   l_new_surrogate_key
	    from   ben_benefit_classifications
	    where  benefit_classification_name = stu_rec.c_true_key
	    and    business_group_id is null
            and  ( (legislation_code is null
                 and  stu_rec.c_leg_code is null)
                 or (legislation_code = stu_rec.c_leg_code) );

	EXCEPTION WHEN NO_DATA_FOUND THEN


	   select ben_benefit_classifications_s.nextval
	   into   l_new_surrogate_key
	   from   dual;

	END;

	-- Update all child entities


   	update hr_s_benefit_classifications
   	set    benefit_classification_id = l_new_surrogate_key
   	where  benefit_classification_id = stu_rec.c_surrogate_key;


   	update hr_s_application_ownerships
   	set    key_value = to_char(l_new_surrogate_key)
   	where  key_value = to_char(stu_rec.c_surrogate_key)
   	and    key_name = 'BENEFIT_CLASSIFICATION_ID';


   	update hr_s_element_types_f
   	set    benefit_classification_id = l_new_surrogate_key
   	where  benefit_classification_id = stu_rec.c_surrogate_key;

    END update_uid;

    PROCEDURE remove
    ----------------
    IS
	-- Remove a row from either the startup tables or the installed tables

    BEGIN


	delete from hr_s_benefit_classifications
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
	-- returns a rowm then this data is required, and the function will
	-- return true. If no rows are returned and an exception is raised,
	-- then this row is not required and may be deleted from the delivery
	-- tables.

	-- If legislation code and subgroup code are included on the delivery
	-- tables, a check must be made to determine if the data is defined for
	-- a specific subgroup. If so the subgroup must be 'A'ctive for this
	-- installation.

	-- A return code of TRUE indicates that thhe row is required.

	-- The exception is raised within this procedure if no rows are returned
	-- in this select statement. If no rows are returned then one of the
	-- following is true:
	--     1. No ownership parameters are defined.
	--     2. The products, for which owning parameters are defined, are not
	--        installed with as status of 'I'.
	--     3. The data is defined for a legislation subgroup that is not active.


	IF p_phase <> 1 THEN
	    return TRUE;
	END IF;


	-- If exception raised below then this row is not needed

	select null
	into   l_null_return
	from   dual
	where  exists
	(select null
	from   hr_s_application_ownerships a
	,      fnd_product_installations b
	,      fnd_application c
	where  a.key_name = 'BENEFIT_CLASSIFICATION_ID'
	and    a.key_value = stu_rec.c_surrogate_key
	and    a.product_name = c.application_short_name
	and    c.application_id = b.application_id
        and    ((b.status = 'I' and c.application_short_name <> 'PQP')
                or
                (b.status in ('I', 'S') and c.application_short_name = 'PQP')));

	-- Indicates row is required

	return TRUE;

    EXCEPTION WHEN NO_DATA_FOUND THEN

	-- Row not needed for any installed product


	remove;

	-- Indicates row not needed

       return FALSE;

    END valid_ownership;

    PROCEDURE transfer_row
    ----------------------
    IS
	-- Check if a delivered row is needed and insert into the
	-- live tables if it is

    BEGIN


	BEGIN

	    -- Perform a check to see if the primary key has been creeated within
	    -- a visible business group. Ie: the business group is for the same
	    -- legislation as the delivered row, or the delivered row has a null
	    -- legislation. If no rows are returned then the primary key has not
	    -- already been created by a user.

            select distinct null
            into   l_null_return
            from   ben_benefit_classifications a
            where  a.business_group_id is not null
            and    a.benefit_classification_name = stu_rec.c_true_key
            and exists (select null from per_business_groups b
              where b.business_group_id = a.business_group_id
              and b.legislation_code = nvl(stu_rec.c_leg_code,b.legislation_code));

	    crt_exc('Row already created in a business group');

	    -- Indicates this row is not to be transferred

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

            select distinct null
            into   l_null_return
            from   ben_benefit_classifications
            where  benefit_classification_name = stu_rec.c_true_key
            and    nvl(legislation_code,'x') <> nvl(stu_rec.c_leg_code,'x')
            and  ( legislation_code is null
                 or stu_rec.c_leg_code is null );

	    crt_exc('Row already created for a visible legislation');

	    -- Indicates this row is not to be transferred

            return;

        EXCEPTION WHEN NO_DATA_FOUND THEN

	    null;

	END;

	-- When the procedure is called in phase 1, there is no need to
	-- actually perform the transfer from the delivery tables into the
	-- live. Hence if phase = 1 control is returned to the calling
	-- procedure and the next row is returned.

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

   	IF p_phase = 1 THEN
	    return;
	END IF;


   	update ben_benefit_classifications
   	set    benefit_classification_name = stu_rec.c_true_key
   	,      business_group_id           = stu_rec.business_group_id
   	,      legislation_code            = stu_rec.c_leg_code
   	,      active_flag                 = stu_rec.active_flag
   	,      beneficiary_allowed_flag    = stu_rec.beneficiary_allowed_flag
   	,      benefit_classification_type = stu_rec.benefit_classification_type
   	,      chargeable_flag             = stu_rec.chargeable_flag
   	,      cobra_flag                  = stu_rec.cobra_flag
   	,      contributions_used          = stu_rec.contributions_used
   	,      dependents_allowed_flag     = stu_rec.dependents_allowed_flag
   	,      dflt_post_termination_rule  = stu_rec.dflt_post_termination_rule
   	,      dflt_processing_type        = stu_rec.dflt_processing_type
   	,      ben_class_processing_rule   = stu_rec.ben_class_processing_rule
   	,      comments                    = stu_rec.comments
   	,      last_update_date            = stu_rec.last_update_date
   	,      last_updated_by             = stu_rec.last_updated_by
   	,      last_update_login           = stu_rec.last_update_login
   	,      created_by                  = stu_rec.created_by
   	,      creation_date               = stu_rec.creation_date
   	where  benefit_classification_id = stu_rec.c_surrogate_key;

   	IF SQL%NOTFOUND THEN


	    insert into ben_benefit_classifications
            ( benefit_classification_name
	    , benefit_classification_id
            , business_group_id
            , legislation_code
            , active_flag
            , beneficiary_allowed_flag
            , benefit_classification_type
            , chargeable_flag
            , cobra_flag
	    , contributions_used
            , dependents_allowed_flag
            , dflt_post_termination_rule
            , dflt_processing_type
            , ben_class_processing_rule
            , comments
            , last_update_date
            , last_updated_by
            , last_update_login
            , created_by
            , creation_date
	    )
	    values
            ( stu_rec.c_true_key
	    , stu_rec.c_surrogate_key
            , stu_rec.business_group_id
            , stu_rec.c_leg_code
            , stu_rec.active_flag
            , stu_rec.beneficiary_allowed_flag
            , stu_rec.benefit_classification_type
            , stu_rec.chargeable_flag
            , stu_rec.cobra_flag
	    , stu_rec.contributions_used
            , stu_rec.dependents_allowed_flag
            , stu_rec.dflt_post_termination_rule
            , stu_rec.dflt_processing_type
            , stu_rec.ben_class_processing_rule
            , stu_rec.comments
            , stu_rec.last_update_date
            , stu_rec.last_updated_by
            , stu_rec.last_update_login
            , stu_rec.created_by
            , stu_rec.creation_date
	    );

   	END IF;


     	remove;

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

    IF p_phase = 1 THEN
        check_next_sequence;
    END IF;

    FOR delivered IN stu LOOP

	-- Uses main cursor stu to impilicity define a record


   	savepoint new_classification_name;

   	stu_rec := delivered;

	IF p_phase = 2 THEN
	    l_new_surrogate_key := stu_rec.c_surrogate_key;
	END IF;

	IF valid_ownership THEN

	    -- Test the row onerships for the current row


	    IF p_phase = 1 THEN
		update_uid;
	    END IF;

	    transfer_row;

        END IF;

    END LOOP;

END install_ben_class;

--****************************************************************************
-- INSTALLATION PROCEDURE FOR : BEN_VALID_DEPENDANT_TYPES
--****************************************************************************

PROCEDURE install_valid_dep_type(p_phase IN number)
---------------------------------------------------
IS
    -- Install procedure to transfer startup Valid Dependent Types into
    -- a live account.

    l_null_return varchar2(1); 		-- For 'select null' statements
    l_new_surrogate_key number(15); 	-- New surrogate key for the delivery row

    CURSOR stu			-- Selects all rows from startup entity
    IS

	select contact_type||coverage_type c_true_key
	,      rowid
	,      valid_dependent_type_id     c_surrogate_key
	,      business_group_id
	,      legislation_code            c_leg_code
	,      contact_type
	,      coverage_type
	,      maximum_number
	,      last_update_date
	,      last_updated_by
	,      last_update_login
	,      created_by
	,      creation_date
	from   hr_s_valid_dependent_types;

    stu_rec stu%ROWTYPE;

    PROCEDURE crt_exc (exception_type IN varchar2)
    ----------------------------------------------
    IS
	-- Reports any exceptions during the delivery of startup data to
	-- BEN_VALID_DEPENDANT_TYPES

    BEGIN
	-- When the installation procedures encounter an error that cannot
	-- be handled, an exception is raised and all work is rolled back
	-- to the last savepoint. The installation process then continues
	-- with the next primary key to install. The same exception will
	-- not be raised more than once.

	rollback to vdt;

	hr_legislation.insert_hr_stu_exceptions('ben_valid_dependent_types'
        ,      stu_rec.c_surrogate_key
        ,      exception_type
        ,      stu_rec.c_true_key);

    END crt_exc;

    PROCEDURE update_uid
    IS
	-- Subprogram to update surrogate UID and all occurrences in child rows

    BEGIN

        BEGIN


	    select distinct valid_dependent_type_id
	    into   l_new_surrogate_key
	    from   ben_valid_dependent_types
	    where  contact_type||coverage_type = stu_rec.c_true_key
	    and    business_group_id is null
	    and  ( (legislation_code is null
	       and  stu_rec.c_leg_code is null)
	  	or (legislation_code = stu_rec.c_leg_code) );

        EXCEPTION WHEN NO_DATA_FOUND THEN


	    select ben_valid_dependent_types_s.nextval
	    into   l_new_surrogate_key
	    from   dual;

        END;

	--update all child entities

	update hr_s_valid_dependent_types
	set    valid_dependent_type_id = l_new_surrogate_key
	where  valid_dependent_type_id = stu_rec.c_surrogate_key;

	update hr_s_application_ownerships
	set    key_value = to_char(l_new_surrogate_key)
	where  key_value = to_char(stu_rec.c_surrogate_key)
	and    key_name = 'VALID_DEPENDENT_TYPE_ID';

    END update_uid;

    PROCEDURE remove
    IS
	-- Remove a row from either the startup tables or the installed tables

    BEGIN

   	delete from hr_s_valid_dependent_types
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
	-- returns a rowm then this data is required, and the function will
	-- return true. If no rows are returned and an exception is raised,
	-- then this row is not required and may be deleted from the delivery
	-- tables.

	-- If legislation code and subgroup code are included on the delivery
	-- tables, a check must be made to determine if the data is defined for
	-- a specific subgroup. If so the subgroup must be 'A'ctive for this
	-- installation.

	-- A return code of TRUE indicates that thhe row is required.

	-- The exception is raised within this procedure if no rows are returned
	-- in this select statement. If no rows are returned then one of the
	-- following is true:

	--     1. No ownership parameters are defined.
	--     2. The products, for which owning parameters are defined, are not
	--        installed with as status of 'I'.
	--     3. The data is defined for a legislation subgroup that is not active.


	IF p_phase <> 1 THEN
	    return TRUE;
	END IF;


	select null --if exception raised then this row is not needed
	into   l_null_return
	from   dual
	where  exists
	(select null
	from   hr_s_application_ownerships a
	,      fnd_product_installations b
	,      fnd_application c
	where  a.key_name = 'VALID_DEPENDENT_TYPE_ID'
	and    a.key_value = stu_rec.c_surrogate_key
	and    a.product_name = c.application_short_name
	and    c.application_id = b.application_id
        and    ((b.status = 'I' and c.application_short_name <> 'PQP')
                or
                (b.status in ('I', 'S') and c.application_short_name = 'PQP')));

	-- Indicates row is required

	return TRUE;

    EXCEPTION WHEN NO_DATA_FOUND THEN

	-- Row not needed for any installed product


        remove;

	-- Indicates row not needed

        return FALSE;

    END valid_ownership;

    PROCEDURE transfer_row
    ----------------------
    IS
	-- Check if a delivered row is needed and insert into the
	-- live tables if it is

    BEGIN


	BEGIN

	    -- Perform a check to see if the primary key has been created within
	    -- a visible business group. Ie: the business group is for the same
	    -- legislation as the delivered row, or the delivered row has a null
	    -- legislation. If no rows are returned then the primary key has not
	    -- already been created by a user.

            select distinct null
            into   l_null_return
            from   ben_valid_dependent_types a
            where  a.business_group_id is not null
            and    a.contact_type||a.coverage_type = stu_rec.c_true_key
            and exists (select null from per_business_groups b
              where b.business_group_id = a.business_group_id
              and b.legislation_code = nvl(stu_rec.c_leg_code,b.legislation_code));

            crt_exc('Row already created in a business group');

	    -- Indicates this row is not to be transferred

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

        select distinct null
        into   l_null_return
        from   ben_valid_dependent_types
        where  contact_type||coverage_type = stu_rec.c_true_key
        and    nvl(legislation_code,'x') <> nvl(stu_rec.c_leg_code,'x')
        and   (
               legislation_code is null
            or stu_rec.c_leg_code is null
              );
        crt_exc('Row already created for a visible legislation');
        return; --indicates this row is not to be transferred

	EXCEPTION WHEN NO_DATA_FOUND THEN

	    null;

	END;

	-- When the procedure is called in phase 1, there is no need to
	-- actually perform the transfer from the delivery tables into the
	-- live. Hence if phase = 1 control is returned to the calling
	-- procedure and the next row is returned.

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

	IF p_phase = 1 THEN
	    return;
	END IF;


	update ben_valid_dependent_types
   	set    business_group_id           = stu_rec.business_group_id
   	,      legislation_code            = stu_rec.c_leg_code
   	,      contact_type                = stu_rec.contact_type
   	,      coverage_type               = stu_rec.coverage_type
   	,      maximum_number              = stu_rec.maximum_number
   	,      last_update_date            = stu_rec.last_update_date
   	,      last_updated_by             = stu_rec.last_updated_by
   	,      last_update_login           = stu_rec.last_update_login
   	,      created_by                  = stu_rec.created_by
   	,      creation_date               = stu_rec.creation_date
  	where  valid_dependent_type_id   = stu_rec.c_surrogate_key;

   	IF SQL%NOTFOUND THEN


	    insert into ben_valid_dependent_types
            ( valid_dependent_type_id
            , business_group_id
	    , legislation_code
            , contact_type
            , coverage_type
            , maximum_number
            , last_update_date
            , last_updated_by
            , last_update_login
            , created_by
            , creation_date
	    )
	    values
            ( stu_rec.c_surrogate_key
            , stu_rec.business_group_id
	    , stu_rec.c_leg_code
            , stu_rec.contact_type
            , stu_rec.coverage_type
            , stu_rec.maximum_number
            , stu_rec.last_update_date
            , stu_rec.last_updated_by
            , stu_rec.last_update_login
            , stu_rec.created_by
            , stu_rec.creation_date
	    );

       END IF;


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

	-- Uses main cursor stu to impilicity define a record


	savepoint vdt;

	stu_rec := delivered;

	IF p_phase = 2 THEN
	    l_new_surrogate_key := stu_rec.c_surrogate_key;
	END IF;

	IF valid_ownership THEN

	    -- Test the row onerships for the current row


	    IF p_phase = 1 THEN
		update_uid;
	    END IF;

	    transfer_row;

	END IF;

    END LOOP;

END install_valid_dep_type;

--****************************************************************************
-- OVERALL INSTALLATION PROCEDURE
--****************************************************************************

PROCEDURE install(p_phase number)
---------------------------------
IS
    -- Driver procedure to control the execution of all installation
    -- procedures in this package.

BEGIN

   IF p_phase = 1 OR p_phase =2 THEN

     hr_legislation.hrrunprc_trace_on;
     hr_utility.trace('start ben_install: ' || to_char(p_phase));

     hr_utility.trace('start install_cobra_qfying_events : ' || to_char(p_phase));
     hr_legislation.hrrunprc_trace_off;

	install_cobra_qfying_events(p_phase); -- Cobra Qualifying Events

     hr_legislation.hrrunprc_trace_on;
     hr_utility.trace('start install_ben_class : ' || to_char(p_phase));
     hr_legislation.hrrunprc_trace_off;

	install_ben_class(p_phase);           -- Benefit Classifications

     hr_legislation.hrrunprc_trace_on;
     hr_utility.trace('start install_valid_dep_type : ' || to_char(p_phase));
     hr_legislation.hrrunprc_trace_off;

	install_valid_dep_type(p_phase);      -- Valid Dependent Types

     hr_legislation.hrrunprc_trace_on;
     hr_utility.trace('exit ben_install: ' || to_char(p_phase));
     hr_legislation.hrrunprc_trace_off;

   END IF;

END install;

end hr_legislation_benefits;

/
