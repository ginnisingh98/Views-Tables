--------------------------------------------------------
--  DDL for Package Body HR_LEGISLATION_ELEMENTS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."HR_LEGISLATION_ELEMENTS" AS
/* $Header: pelegele.pkb 120.8.12000000.1 2007/01/21 23:59:27 appldev ship $ */
--****************************************************************************
-- INSTALLATION PROCEDURE FOR : PAY_ELEMENT_CLASSIFICATIONS
--****************************************************************************

PROCEDURE install_ele_class(p_phase IN number)
----------------------------------------------
IS
    -- Install procedure to transfer startup element classifications into
    -- a live account.

    l_null_return varchar2(1); 		-- For 'select null' statements
    l_new_surrogate_key number(15); 	-- New surrogate key for the delivery row

    CURSOR stu				-- Selects all rows from startup entity
    IS
	select classification_name c_true_key
	,      rowid
	,      classification_id c_surrogate_key
	,      legislation_code c_leg_code
	,      legislation_subgroup c_leg_sgrp
	,      business_group_id
	,      description
	,      costing_debit_or_credit
	,      default_high_priority
	,      default_low_priority
	,      default_priority
	,      distributable_over_flag
	,      non_payments_flag
	,      parent_classification_id
	,      costable_flag
	,      create_by_default_flag
	,      last_update_date
	,      last_updated_by
	,      last_update_login
	,      created_by
	,      creation_date
        ,      balance_initialization_flag
        ,      FREQ_RULE_ENABLED
	from   hr_s_element_classifications
	order  by parent_classification_id desc;

    stu_rec stu%ROWTYPE;

    PROCEDURE crt_exc (exception_type IN varchar2)
    ----------------------------------------------
    IS
	-- Reports any exceptions during the delivery of startup data to
	-- FF_CONTEXTS_F

    BEGIN
	-- When the installation procedures encounter an error that cannot
	-- be handled, an exception is raised and all work is rolled back
	-- to the last savepoint. The installation process then continues
	-- with the next primary key to install. The same exception will
	-- not be raised more than once.

	rollback to new_classification_name;

	hr_legislation.insert_hr_stu_exceptions('pay_element_classifications'
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
	    from   pay_element_classifications a
	    where  exists
		(select null
		 from   hr_s_element_classifications b
		 where  a.classification_id = b.classification_id
		);

	    --conflict may exist
	    --update all classification_id's to remove conflict

	    update /*+NO_INDEX*/ hr_s_element_classifications
	    set    classification_id = classification_id - 50000000
	    ,parent_classification_id = parent_classification_id - 50000000;

            update /*+NO_INDEX*/ hr_s_BALANCE_CLASSIFICATIONS
            set    classification_id = classification_id - 50000000;

            update /*+NO_INDEX*/ hr_s_ELEMENT_TYPES_F
            set    classification_id = classification_id - 50000000;

            update /*+NO_INDEX*/ hr_s_ELE_CLASSN_RULES
            set    classification_id = classification_id - 50000000;

            update /*+NO_INDEX*/ hr_s_SUB_CLASSN_RULES_F
            set    classification_id = classification_id - 50000000;

	    --
	    -- #346359 ensure STU_TAXABILITY_RULES classification_id is kept
	    -- in step along with the rest of the children.
	    --
            update /*+NO_INDEX*/ hr_s_TAXABILITY_RULES
            set    classification_id = classification_id - 50000000;

	    update hr_s_application_ownerships
	    set    key_value = key_value - 50000000
	    where  key_name = 'CLASSIFICATION_ID';

	EXCEPTION WHEN NO_DATA_FOUND THEN NULL;

	END; --check of classification_id



	select min(classification_id) - (count(*) *3)
	,      max(classification_id) + (count(*) *3)
	into   v_min_delivered
	,      v_max_delivered
	from   hr_s_element_classifications;

	select pay_element_classifications_s.nextval
	into   v_sequence_number
	from   dual;

	IF (v_sequence_number BETWEEN v_min_delivered AND v_max_delivered) THEN

          hr_legislation.munge_sequence('PAY_ELEMENT_CLASSIFICATIONS_S',
                                           v_sequence_number,
                                           v_max_delivered);
        END IF;

    END check_next_sequence;

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


	IF stu_rec.parent_classification_id is null THEN
	    -- No need to check parent
	    return TRUE;
	END IF;

	BEGIN

	    -- Start the checking against the first parent table

	    select distinct null
	    into   l_null_return
	    from   hr_s_element_classifications
	    where  classification_id = stu_rec.parent_classification_id;

	    crt_exc('Parent classification remains in delivery tables');

	    -- Parent row still in startup account

	    return FALSE;

        EXCEPTION WHEN NO_DATA_FOUND THEN

	    null;

        END;


	--Now check the live account

	BEGIN

	    select null
	    into   l_null_return
	    from   pay_element_classifications
	    where  classification_id = stu_rec.parent_classification_id;

	    return TRUE;

        EXCEPTION WHEN NO_DATA_FOUND THEN


	    crt_exc('Parent classification not installed');

	    return FALSE;

    	END;

    END check_parents;

    PROCEDURE update_uid
    --------------------
    IS
	-- Subprogram to update surrogate UID and all occurrences in child rows

    BEGIN

	BEGIN


	    select distinct classification_id
	    into   l_new_surrogate_key
	    from   pay_element_classifications
	    where  classification_name = stu_rec.c_true_key
	    and    business_group_id is null
            and  ( (legislation_code is null
                    and  stu_rec.c_leg_code is null)
                or (legislation_code = stu_rec.c_leg_code) );

     	EXCEPTION WHEN NO_DATA_FOUND THEN


	    select pay_element_classifications_s.nextval
	    into   l_new_surrogate_key
	    from   dual;

                  WHEN TOO_MANY_ROWS THEN

                        hr_legislation.hrrunprc_trace_on;
                        hr_utility.trace('sel pay_element_classifications TMR');

                        hr_utility.trace('classification_name  ' ||
                          stu_rec.c_true_key);
                        hr_utility.trace(':lc: ' || ':' ||
                          stu_rec.c_leg_code || ':');
                        hr_legislation.hrrunprc_trace_off;
                        raise;
	END;

	-- Update all child entities

   	update hr_s_element_classifications
   	set    classification_id = l_new_surrogate_key
   	where  classification_id = stu_rec.c_surrogate_key;

   	update hr_s_element_classifications
   	set    parent_classification_id = l_new_surrogate_key
   	where  parent_classification_id = stu_rec.c_surrogate_key;

   	update hr_s_application_ownerships
   	set    key_value = to_char(l_new_surrogate_key)
   	where  key_value = to_char(stu_rec.c_surrogate_key)
   	and    key_name = 'CLASSIFICATION_ID';

   	update hr_s_element_types_f
   	set    classification_id = l_new_surrogate_key
   	where  classification_id = stu_rec.c_surrogate_key;

   	update hr_s_balance_classifications
   	set    classification_id = l_new_surrogate_key
   	where  classification_id = stu_rec.c_surrogate_key;

   	update hr_s_sub_classn_rules_f
   	set    classification_id = l_new_surrogate_key
   	where  classification_id = stu_rec.c_surrogate_key;

   	update hr_s_ele_classn_rules
   	set    classification_id = l_new_surrogate_key
   	where  classification_id = stu_rec.c_surrogate_key;

   	update hr_s_taxability_rules
   	set    classification_id = l_new_surrogate_key
   	where  classification_id = stu_rec.c_surrogate_key;

    END update_uid;

    PROCEDURE remove (p_delivered IN varchar2)
    ------------------------------------------
    IS
	-- Remove a row from either the startup tables or the installed tables

    BEGIN


	delete from hr_s_element_classifications
	where  rowid = stu_rec.rowid;

	-- #334582 If the row is being removed 'undelivered' i.e. it's not
	-- required in this installation, remove its child
	-- hr_s_taxability_rules rows here, so we don't get a later FKEY
	-- constraint violation.
	--
	if (p_delivered = 'N') then
	  delete from hr_s_taxability_rules
	  where  classification_id = stu_rec.c_surrogate_key;
	end if;

    END remove;

    FUNCTION valid_ownership RETURN BOOLEAN
    ---------------------------------------
    IS
	-- Table hr_application_ownerships in the delivery account, which
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

    BEGIN

	IF p_phase <> 1 THEN	--only perform in phase 1
		return TRUE;
	END IF;


 	-- If exception raised below then this row is not needed
        if (stu_rec.c_leg_sgrp is null) then
        select null
        into   l_null_return
        from   dual
        where  exists
        (select null
        from   hr_s_application_ownerships a
        ,      fnd_product_installations b
        ,      fnd_application c
        where  a.key_name = 'CLASSIFICATION_ID'
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
	where  a.key_name = 'CLASSIFICATION_ID'
	and    a.key_value = stu_rec.c_surrogate_key
	and    a.product_name = c.application_short_name
	and    c.application_id = b.application_id
        and    ((b.status = 'I' and c.application_short_name <> 'PQP')
                or
                (b.status in ('I', 'S') and c.application_short_name = 'PQP')))
	and exists (select null from hr_legislation_subgroups d
	         where d.legislation_code = stu_rec.c_leg_code
	     and  d.legislation_subgroup = stu_rec.c_leg_sgrp
	     and  d.active_inactive_flag = 'A'
	         );
        end if;

	return TRUE;	--indicates row is required

    EXCEPTION WHEN NO_DATA_FOUND THEN

	-- Row not needed for any installed product


	remove ('N');

	-- Indicate row not needed

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
            from pay_element_classifications a
            where a.classification_name = stu_rec.c_true_key
            and   a.business_group_id is not null
            and   exists (select null from per_business_groups b
              where b.business_group_id = a.business_group_id
              and b.legislation_code = nvl(stu_rec.c_leg_code,b.legislation_code));

            crt_exc('Row already created in a business group');

 	    -- Indicate this row is not to be transferred

            return;

       EXCEPTION WHEN NO_DATA_FOUND THEN

	   null;

       END;


	-- Now perform a check to see if this primary key has been installed
	-- with a legislation code that would make it visible at the same time
	-- as this row. Ie: if any legislation code is null within the set of
	-- returned rows, then the transfer may not go ahead. If no rows are
	-- returned then the delivered row is fine.
	-- G1746. Add the check for business_group_id is null, otherwise the
	-- row may be wrongly rejected because it already exists for a
	-- specific business group in another legislation. This, though
	-- unlikely, is permissible. RMF 05.01.95.

        BEGIN

            select distinct null
            into   l_null_return
            from   pay_element_classifications
            where  classification_name = stu_rec.c_true_key
            and    nvl(legislation_code,'x') <> nvl(stu_rec.c_leg_code,'x')
            and   (legislation_code is null or stu_rec.c_leg_code is null )
	    and    business_group_id is null;

            crt_exc('Row already created for a visible legislation');

	    -- Indicate this row is not to be transferred

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

   	IF NOT check_parents THEN
	    -- Fails of parents exist
	    return;
	END IF;


   	update pay_element_classifications
   	set    classification_name = stu_rec.c_true_key
   	,      legislation_code = stu_rec.c_leg_code
   	,      legislation_subgroup = stu_rec.c_leg_sgrp
   	,      business_group_id = stu_rec.business_group_id
   	,      description = stu_rec.description
   	,      costing_debit_or_credit = stu_rec.costing_debit_or_credit
   	,      default_high_priority = stu_rec.default_high_priority
  	,      default_low_priority = stu_rec.default_low_priority
  	,      default_priority = stu_rec.default_priority
   	,      distributable_over_flag = stu_rec.distributable_over_flag
   	,      non_payments_flag = stu_rec.non_payments_flag
   	,      parent_classification_id = stu_rec.parent_classification_id
   	,      costable_flag = stu_rec.costable_flag
   	,      create_by_default_flag = stu_rec.create_by_default_flag
   	,      last_update_date = stu_rec.last_update_date
  	,      last_updated_by = stu_rec.last_updated_by
   	,      last_update_login = stu_rec.last_update_login
   	,      created_by = stu_rec.created_by
   	,      creation_date = stu_rec.creation_date
        ,      balance_initialization_flag = stu_rec.balance_initialization_flag
        ,      FREQ_RULE_ENABLED = stu_rec.FREQ_RULE_ENABLED
   	where  classification_id = stu_rec.c_surrogate_key;

        IF SQL%NOTFOUND THEN

           BEGIN
	    insert into pay_element_classifications
	    (classification_name
	    ,classification_id
	    ,legislation_code
	    ,legislation_subgroup
	    ,business_group_id
	    ,description
	    ,costing_debit_or_credit
	    ,default_high_priority
	    ,default_low_priority
	    ,default_priority
	    ,distributable_over_flag
	    ,non_payments_flag
	    ,parent_classification_id
	    ,costable_flag
	    ,create_by_default_flag
	    ,last_update_date
	    ,last_updated_by
	    ,last_update_login
	    ,created_by
	    ,creation_date
            ,balance_initialization_flag
            ,FREQ_RULE_ENABLED
	    )
	    values
	    (stu_rec.c_true_key
	    ,stu_rec.c_surrogate_key
	    ,stu_rec.c_leg_code
	    ,stu_rec.c_leg_sgrp
	    ,stu_rec.business_group_id
	    ,stu_rec.description
	    ,stu_rec.costing_debit_or_credit
	    ,stu_rec.default_high_priority
	    ,stu_rec.default_low_priority
	    ,stu_rec.default_priority
	    ,stu_rec.distributable_over_flag
	    ,stu_rec.non_payments_flag
	    ,stu_rec.parent_classification_id
	    ,stu_rec.costable_flag
	    ,stu_rec.create_by_default_flag
	    ,stu_rec.last_update_date
	    ,stu_rec.last_updated_by
	    ,stu_rec.last_update_login
	    ,stu_rec.created_by
	    ,stu_rec.creation_date
            ,stu_rec.balance_initialization_flag
            ,stu_rec.FREQ_RULE_ENABLED);
                      EXCEPTION WHEN OTHERS THEN
                        hr_legislation.hrrunprc_trace_on;
                        hr_utility.trace('ins pay_element_classifications');
                        hr_utility.trace('classification_name  ' ||
                          stu_rec.c_true_key);
                        hr_utility.trace('classification_id  ' ||
                          to_char(stu_rec.c_surrogate_key));
                        hr_utility.trace(':lc: ' || ':' ||
                          stu_rec.c_leg_code || ':');
                        hr_legislation.hrrunprc_trace_off;
                        raise;
                      END;

	END IF;


   	remove ('Y');

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
	    l_new_Surrogate_key := stu_rec.c_surrogate_key;
	END IF;

	IF valid_ownership THEN

	    -- Test the row onerships for the current row


	    IF p_phase = 1 THEN
		update_uid;
	    END IF;

	    transfer_row;

	END IF;

    END LOOP;

END install_ele_class;

--****************************************************************************
-- INSTALLATION PROCEDURE FOR : PAY_ELEMENT_TYPES
--****************************************************************************

    PROCEDURE install_elements (p_phase IN NUMBER)
    ----------------------------------------------
    IS
	-- Install procedure to transfer startup delivered pay_element_typess into a
	-- live account, and remove the then delivered rows from the delivery
	-- account.

	-- This procedure is called in two phase. Only in the second phase are
	-- details transferred into live tables. The parameter p_phase holds
	-- the phase number.

	-- The element are installed if differences are found between the delivered
	-- rows and the installed rows. Also if there are differences between the
	-- input values, defined for the element, in the delivered tables and
	-- the live tables.

	row_in_error exception;
	l_current_proc varchar2(80) := 'hr_legislation.install_elements';
	l_new_element_type_id number(15);
	l_null_return varchar2(1);
	l_payroll_install_status varchar2 (1);
	l_formula_id number (15);
	l_end_of_time date := hr_general.end_of_time;
        l_flex_value_set_id number(10);

    CURSOR c_distinct_name
    IS
	-- Select distinct element names. The element name can no longer be
	-- guarenteed to be unique. This cursor selects all distinct names
	-- for the next cusrsor to select distinct element_type_id's from.

   	select distinct element_name
   	from   hr_s_element_types_f;

    CURSOR c_distinct_element(pc_ele_name varchar2)
    IS
	-- Retrieve all distinct element type id's for the current element.
	-- This row is then used to select all date effective rows for this id.

	select max(effective_end_date) c_end
	,      min(effective_start_date) c_start
	,      element_type_id c_surrogate_key
	,      element_name c_true_key
	,      legislation_code
	,      legislation_subgroup
        ,      nvl(new_element_type_flag, 'Y') new_element_type_flag
	from   hr_s_element_types_f
	where  element_name = pc_ele_name
	group  by element_type_id
	,         element_name
	,         legislation_code
	,         legislation_subgroup
        ,         nvl(new_element_type_flag, 'Y');

    CURSOR c_each_element_row(pc_element_type_id varchar2)
    IS
	-- Selects all date effective rows for the current true primary key

	-- The primary key has already been selected using the above cursor.
	-- This cursor accepts the primary key as a parameter and selects all
	-- date effective rows for it.

   	select *
   	from   hr_s_element_types_f
   	where  element_type_id = pc_element_type_id;

    CURSOR sub_rules(pc_element_id number)
    IS
	-- Retrieves sub classification rules for the current element

   	select *
   	from   hr_s_sub_classn_rules_f
   	where  element_type_id = pc_element_id;

    CURSOR proc_rules(pc_element_id number)
    IS
	-- Retrieves the distinct id's from status rules for this element
	-- Used for the update of uid's.
	--
	-- #346366. Also pull back the assignment_status_type_id, as we
	-- could have different rules for different statuses for the
	-- same element type.
	--
   	select distinct status_processing_rule_id s_rule_id,
	       assignment_status_type_id,processing_rule
   	from   hr_s_status_processing_rules_f
   	where  element_Type_id = pc_element_id;

    CURSOR all_p_rules(pc_stat_rule_id number)
    IS
	-- Retrieves full details of processing rules for the insertiion into
	-- live tables.

   	select *
   	from   hr_s_status_processing_rules_f
   	where  status_processing_rule_id = pc_stat_rule_id;

    CURSOR frrs(pc_stat_rule_id number)
    IS
	-- Retrieves formula result rules for a given status processing rule

   	select *
   	from   hr_s_formula_result_rules_f
   	where  status_processing_rule_id = pc_stat_rule_id;

    CURSOR d_frrs(pc_stat_rule_id number)
    IS
	-- Retrieves distinct id's from formula result rules for a given status
	-- processing rule.

   	select distinct formula_result_rule_id
   	from   hr_s_formula_result_rules_f
   	where  status_processing_rule_id = pc_stat_rule_id;

    CURSOR inputs(pc_element_id number)
    IS
	-- Retrieve distinct input value details for this element

   	select distinct input_value_id
   	,      name
        ,      value_set_name
        ,      new_input_value_flag
   	from   hr_s_input_values_f
   	where  element_Type_id = pc_element_id;

	-- These records are defined here so all sub procedures may use the
	-- values selected. This saves the need for all sub procedures to have
	-- a myriad of parameters passed. The cursors are controlled in FOR
	-- cursor LOOPs. When a row is returned the whole record is copied into
	-- these record definitions.

	r_distinct c_distinct_element%ROWTYPE;
	r_each_row c_each_element_row%ROWTYPE;


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
	    from   pay_element_types_f a
	    where  exists
		(select null
		 from   hr_s_element_types_f b
		 where  a.element_type_id = b.element_type_id
		);

	    --conflict may exist
	    --update all element_type_id's to remove conflict

	    update /*+NO_INDEX*/ hr_s_ELEMENT_TYPES_F
	    set    element_type_id = element_type_id - 50000000,
                   retro_summ_ele_id = retro_summ_ele_id - 50000000;

            update /*+NO_INDEX*/ hr_s_ELEMENT_TYPE_RULES
            set    element_type_id = element_type_id - 50000000;

            update /*+NO_INDEX*/ hr_s_FORMULA_RESULT_RULES_F
            set    element_type_id = element_type_id - 50000000;

            update /*+NO_INDEX*/ hr_s_INPUT_VALUES_F
            set    element_type_id = element_type_id - 50000000;

            update /*+NO_INDEX*/ hr_s_STATUS_PROCESSING_RULES_F
            set    element_type_id = element_type_id - 50000000;

            update /*+NO_INDEX*/ hr_s_SUB_CLASSN_RULES_F
            set    element_type_id = element_type_id - 50000000;

	    update hr_s_application_ownerships
	    set    key_value = key_value - 50000000
	    where  key_name = 'ELEMENT_TYPE_ID';

	EXCEPTION WHEN NO_DATA_FOUND THEN NULL;

	END; --check of element_type_id


	BEGIN	--Now check input_values_F


	    select distinct null
	    into   l_null_return
	    from   pay_input_values_f a
	    where  exists
		(select null
		 from   hr_s_input_values_f b
		 where  a.input_value_id = b.input_value_id
		);

	    --conflict may exist
	    --update all input_value_id's to remove conflict

	    update /*+NO_INDEX*/ hr_s_INPUT_VALUES_F
            set    input_value_id = input_value_id - 50000000;

	    update /*+NO_INDEX*/ hr_s_BALANCE_FEEDS_F
	    set    input_value_id = input_value_id - 50000000;

            update /*+NO_INDEX*/ hr_s_FORMULA_RESULT_RULES_F
            set    input_value_id = input_value_id - 50000000;

            update /*+NO_INDEX*/ hr_s_balance_types
            set    input_value_id = input_value_id - 50000000;

	    --
	    -- #347569 Removed two lines here, which were an exact copy of
	    -- the update STU_FORMULA_RESULT_RULES_F statement immediately
	    -- above, resulting in the input_value_id being decremented
	    -- twice, thereby breaking the fkey link.
	    --

	EXCEPTION WHEN NO_DATA_FOUND THEN NULL;

	END; --check of input_value_id


	BEGIN	--now check status processing riles


	    select distinct null
	    into   l_null_return
	    from   pay_status_processing_rules_f a
	    where  exists
		(select null
		 from   hr_s_status_processing_rules_f b
		 where  a.status_processing_rule_id=b.status_processing_rule_id
		);

	    --conflict may exist
	    --update all status_processing_rule_id's to remove conflict

	    update hr_s_FORMULA_RESULT_RULES_F
	    set status_processing_rule_id=status_processing_rule_id-50000000;

            update hr_s_STATUS_PROCESSING_RULES_F
            set status_processing_rule_id=status_processing_rule_id-50000000;

	EXCEPTION WHEN NO_DATA_FOUND THEN NULL;

	END; --check of status_processing_rule_id


	BEGIN	--now check formula result rules


	    select distinct null
	    into   l_null_return
	    from   pay_formula_result_rules_f a
	    where  exists
		(select null
		 from   hr_s_formula_result_rules_f b
		 where  a.formula_result_rule_id = b.formula_result_rule_id
		);

	    --conflict may exist
	    --update all formula_result_rule_id's to remove conflict

	    update /*+NO_INDEX*/ hr_s_FORMULA_RESULT_RULES_F
	    set    formula_result_rule_id = formula_result_rule_id - 50000000;

	EXCEPTION WHEN NO_DATA_FOUND THEN NULL;

	END; --check of formula_result_rule_id


	BEGIN	--now check sub classification rules


	    select distinct null
	    into   l_null_return
	    from   pay_sub_classification_rules_f a
	    where  exists
		(select null
		 from   hr_s_sub_classn_rules_f b
		 where a.sub_classification_rule_id=b.sub_classification_rule_id
		);

	    --conflict may exist
	    --update all sub_classification_rule_id's to remove conflict

	    update /*+NO_INDEX*/ hr_s_sub_classn_rules_f
	    set sub_classification_rule_id=sub_classification_rule_id-50000000;

	EXCEPTION WHEN NO_DATA_FOUND THEN NULL;

	END; --check of sub_classification_rule_id



	select min(element_type_id) - (count(*) *3)
	,      max(element_type_id) + (count(*) *3)
	into   v_min_delivered
	,      v_max_delivered
	from   hr_s_element_types_f;

	select pay_element_types_s.nextval
	into   v_sequence_number
	from   dual;

        WHILE v_sequence_number
	  BETWEEN v_min_delivered AND v_max_delivered
	LOOP


	    select pay_element_types_s.nextval
            into   v_sequence_number
            from   dual;

        END LOOP;

	--Now check input values


	select min(input_value_id) - (count(*) *3)
	,      max(input_value_id) + (count(*) *3)
	into   v_min_delivered
        ,      v_max_delivered
	from   hr_s_input_values_f;

	select pay_input_Values_s.nextval
        into   v_sequence_number
        from   dual;

        IF v_sequence_number
          BETWEEN v_min_delivered AND v_max_delivered
        THEN

          hr_legislation.munge_sequence('PAY_INPUT_VALUES_S',
                                        v_sequence_number,
                                        v_max_delivered);

        END IF;

	--now check status_processing_rules

        select min(status_processing_rule_id) - (count(*) *3)
        ,      max(status_processing_rule_id) + (count(*) *3)
        into   v_min_delivered
        ,      v_max_delivered
        from   hr_s_status_processing_rules_f;

        select pay_status_processing_rules_s.nextval
        into   v_sequence_number
        from   dual;

        IF v_sequence_number
          BETWEEN v_min_delivered AND v_max_delivered
        THEN

          hr_legislation.munge_sequence('PAY_STATUS_PROCESSING_RULES_S',
                                        v_sequence_number,
                                        v_max_delivered);

        END IF;

        --now check formula_result_rules

        select min(formula_result_rule_id) - (count(*) *3)
        ,      max(formula_result_rule_id) + (count(*) *3)
        into   v_min_delivered
        ,      v_max_delivered
        from   hr_s_formula_result_rules_f;

        select pay_formula_result_rules_s.nextval
        into   v_sequence_number
        from   dual;

        IF v_sequence_number
          BETWEEN v_min_delivered AND v_max_delivered
        THEN

          hr_legislation.munge_sequence('PAY_FORMULA_RESULT_RULES_S',
                                        v_sequence_number,
                                        v_max_delivered);

        END IF;


        --now check sub_classification_rules_f

        select min(sub_classification_rule_id) - (count(*) *3)
        ,      max(sub_classification_rule_id) + (count(*) *3)
        into   v_min_delivered
        ,      v_max_delivered
        from   hr_s_sub_classn_rules_f;

        select pay_sub_classification_rules_s.nextval
        into   v_sequence_number
        from   dual;

        IF v_sequence_number
          BETWEEN v_min_delivered AND v_max_delivered
        THEN

          hr_legislation.munge_sequence('PAY_SUB_CLASSIFICATION_RULES_S',
                                        v_sequence_number,
                                        v_max_delivered);

        END IF;

    END check_next_sequence;


    PROCEDURE crt_exc (exception_type IN varchar2,rollback_to IN varchar2)
    ----------------------------------------------------------------------
    IS
	-- Reports any exceptions during the delivery of startup data to
	-- PAY_ELEMENT_TYPES

    BEGIN
	-- When the installation procedures encounter an error that cannot
	-- be handled, an exception is raised and all work is rolled back
	-- to the last savepoint. The installation process then continues
	-- with the next primary key to install. The same exception will
	-- not be raised more than once.


   	IF rollback_to = 'N' THEN
   	    rollback to new_element_name;
   	ELSE
	    rollback to new_distinct_id;
   	END IF;

	hr_legislation.insert_hr_stu_exceptions('pay_element_types_f'
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

   	delete from hr_s_element_types_f
   	where  element_type_id = v_id;

   	delete from hr_s_sub_classn_rules_f
   	where  element_type_id = v_id;

   	delete from hr_s_input_values_f
   	where  element_type_id = v_id;

   	delete from hr_s_formula_result_rules_f a
   	where  exists
          (select null
           from   hr_s_status_processing_rules_f b
           where  b.status_processing_rule_id = a.status_processing_rule_id
           and    b.element_type_id = v_id
          );

   	delete from hr_s_status_processing_rules_f
   	where  element_type_id = v_id;

    END remove;

    PROCEDURE update_uid
    --------------------
    IS
	-- Subprogram to update surrogate UID and all occurrences in child rows

	v_new_sub_class_id number(15);
	v_new_input_id number(15);
	v_new_spr_id number(15);
	v_new_frr_id number(15);
        v_new_input_value_flag varchar2 (1);
        v_new_element_type_flag varchar2 (1);
        v_new_sub_class_rule_flag varchar2 (1);
        v_dummy number(15);

    BEGIN
	-- See if this primary key is already installed. If so then the sorrogate
	-- key of the delivered row must be updated to the value in the installed
	-- tables. If the row is not already present then select the next value
	-- from the sequence. In either case all rows for this primary key must
	-- be updated, as must all child references to the old surrogate uid.


   	BEGIN
	    select distinct element_type_id
	    into   l_new_element_type_id
	    from   pay_element_types_f
            where  replace(ltrim(rtrim(upper(element_name))), ' ', '_') =
                   replace(ltrim(rtrim(upper(r_distinct.c_true_key))), ' ', '_')
	    and    business_Group_id is null
	    and    legislation_code = r_distinct.legislation_code;

            v_new_element_type_flag := 'N';

    	EXCEPTION WHEN NO_DATA_FOUND THEN


	    select pay_element_types_s.nextval
	    into   l_new_element_type_id
	    from   dual;

            v_new_element_type_flag := 'Y';

                  WHEN TOO_MANY_ROWS THEN
                        hr_legislation.hrrunprc_trace_on;
                        hr_utility.trace('sel pay_element_types_f TMR');
                        hr_utility.trace('element_name  ' ||
                          r_distinct.c_true_key);
                        hr_utility.trace(':lc: ' || ':' ||
                          r_distinct.legislation_code || ':');
                        hr_legislation.hrrunprc_trace_off;
                        raise;
        END;

   	update hr_s_element_types_f
   	set    element_type_id = l_new_element_type_id,
               new_element_type_flag = v_new_element_type_flag
   	where  element_type_id = r_distinct.c_surrogate_key;

        update hr_s_element_types_f
        set    retro_summ_ele_id = l_new_element_type_id
        where  retro_summ_ele_id = r_distinct.c_surrogate_key;

   	update hr_s_element_type_rules
   	set    element_type_id = l_new_element_type_id
   	where  element_type_id = r_distinct.c_surrogate_key;

   	update hr_s_formula_result_rules_f
   	set    element_type_id = l_new_element_type_id
   	where  element_type_id = r_distinct.c_surrogate_key;

   	update hr_s_application_ownerships
   	set    key_value = to_char(l_new_element_type_id)
   	where  key_value = to_char(r_distinct.c_surrogate_key)
   	and    key_name = 'ELEMENT_TYPE_ID';

   	-- update the uid of associated input values

   	FOR i_vals IN inputs(r_distinct.c_surrogate_key) LOOP


	    BEGIN
		-- Test if input value already exists
		-- #331823. Add 'distinct' to prevent a 'too many rows'
		--          error if there is more than one datetracked
		--          version of the input values row.

	   	select distinct input_value_id
	   	into   v_new_input_id
	   	from   pay_input_values_f
                where  replace(ltrim(rtrim(upper(name))), ' ', '_') =
                       replace(ltrim(rtrim(upper(i_vals.name))), ' ', '_')
	   	and    business_group_id is null
	   	and    element_type_id = l_new_element_Type_id;

                v_new_input_value_flag := 'N';

	    EXCEPTION WHEN NO_DATA_FOUND THEN
		-- New input value, so new get new _id
		select pay_input_values_s.nextval
		into   v_new_input_id
		from   dual;

                v_new_input_value_flag := 'Y';

                      WHEN TOO_MANY_ROWS THEN
                        hr_legislation.hrrunprc_trace_on;
                        hr_utility.trace('sel pay_input_values_f TMR');
                        hr_utility.trace('iv name  ' ||
                          i_vals.name);
                        hr_utility.trace('element_type_id  ' ||
                          to_char(l_new_element_Type_id));
                        hr_utility.trace('element_name  ' ||
                          r_distinct.c_true_key);
                        hr_legislation.hrrunprc_trace_off;
                        raise;
	    END;

	    update hr_s_input_values_f
	    set    input_value_id = v_new_input_id
	    ,      element_type_id = l_new_element_type_id
	    ,      new_input_value_flag = v_new_input_value_flag
	    where  input_value_id = i_vals.input_value_id;

	    update hr_s_balance_feeds_f
	    set    input_value_id = v_new_input_id,
                   new_input_value_flag = v_new_input_value_flag
	    where  input_value_id = i_vals.input_value_id;

	    update hr_s_formula_result_rules_f
            set    input_value_id = v_new_input_id
            where  input_value_id = i_vals.input_value_id;

            update hr_s_balance_types
            set    input_value_id = v_new_input_id
            where  input_value_id = i_vals.input_value_id;

     	END LOOP i_vals;

        -- Update the uid of sub classification rules

        FOR s_class IN sub_rules(r_distinct.c_surrogate_key) LOOP

	    select pay_sub_classification_rules_s.nextval
	    into   v_new_sub_class_id
	    from dual;

	    update hr_s_sub_classn_rules_f
	    set    sub_classification_rule_id = v_new_sub_class_id
	    ,      element_type_id = l_new_element_type_id
	    where  sub_classification_rule_id = s_class.sub_classification_rule_id;

            BEGIN

               select sub_classification_rule_id
               into v_dummy
               from hr_s_sub_classn_rules_f hscr
               where hscr.sub_classification_rule_id = v_new_sub_class_id
               and exists
                 ( select 1
                   from pay_sub_classification_rules_f pscr
                   where pscr.element_type_id = hscr.element_type_id
                   and   pscr.classification_id = hscr.classification_id
                   and   nvl(pscr.business_group_id, -1) = nvl(hscr.business_group_id, -1)
                   and   nvl(pscr.legislation_code, 'X') = nvl(hscr.legislation_code, 'X')
                   and   pscr.effective_start_date = hscr.effective_start_date
                   and   pscr.effective_end_date = hscr.effective_end_date);

               v_new_sub_class_rule_flag := 'N';

            EXCEPTION WHEN NO_DATA_FOUND THEN

               v_new_sub_class_rule_flag := 'Y';

            END;

	    update hr_s_sub_classn_rules_f
	    set    new_sub_class_rule_flag = v_new_sub_class_rule_flag
	    where  sub_classification_rule_id = s_class.sub_classification_rule_id;

	END LOOP s_class;

        -- update the uids of status processing rules and child result rules

        FOR sprs IN proc_rules(r_distinct.c_surrogate_key) LOOP

	    --
	    -- #346366. Test if status processing rule already exists
	    -- and use its id if it does, rather than always getting
	    -- the next number from the sequence. This means that user-entered
	    -- formula result rules are not orphaned through the parent spr's
	    -- id being changed.
	    --
            -- 2971029
            -- need to consider null = null case seperately else we miss existing
            -- data when the assignment_status_type_id is null
            -- Also need the select max in case datetrack data can return more
            -- than 1 distinct status_processing_rule_id for a given leg_code,bg,
            -- assignment_status_type_id and element_type_id combination.
            -- Guarantee return of the ID of only the live row  that has the max
            -- EED for this combination

	    BEGIN

  		select distinct status_processing_rule_id
		into   v_new_spr_id
		from   pay_status_processing_rules_f spr
        	where  spr.legislation_code = r_distinct.legislation_code
		and    spr.business_group_id is null
                and    spr.processing_rule = sprs.processing_rule
                and    ((spr.assignment_status_type_id is null
                        and
                        sprs.assignment_status_type_id is null)
                       or
                       (spr.assignment_status_type_id =
                        sprs.assignment_status_type_id))
                and    spr.effective_end_date = (select max(spr2.effective_end_date)
                                                 from  pay_status_processing_rules_f spr2
                                                 where spr2.element_type_id = spr.element_type_id
                                                 and spr2.processing_rule = spr.processing_rule
                                                 and   spr2.legislation_code = r_distinct.legislation_code
		                                 and   spr2.business_group_id is null
		                                 and   ((spr.assignment_status_type_id is null
                                                         and spr2.assignment_status_type_id is null)
                                                        or
                                                        (spr.assignment_status_type_id =
                                                         spr2.assignment_status_type_id)))
		and   element_type_id = l_new_element_type_id;

	    EXCEPTION WHEN NO_DATA_FOUND THEN

		-- New input value, so new get new _id

		select pay_status_processing_rules_s.nextval
		into   v_new_spr_id
		from   dual;

                     WHEN TOO_MANY_ROWS THEN
                        hr_legislation.hrrunprc_trace_on;
                        hr_utility.trace('sel pay_status_processing_rules TMR');

                        hr_utility.trace('assignment_status_type_id  ' ||
                          to_char(sprs.assignment_status_type_id));
                        hr_utility.trace(':lc: ' || ':' ||
                          r_distinct.legislation_code || ':');
                        hr_legislation.hrrunprc_trace_off;
                        raise;
	    END;

	    update hr_s_status_processing_rules_f
	    set    status_processing_rule_id = v_new_spr_id
	    ,      element_type_id = l_new_element_type_id
	    where  status_processing_rule_id = sprs.s_rule_id;

	    FOR results IN d_frrs(sprs.s_rule_id) LOOP

	       select pay_formula_Result_rules_s.nextval
	       into   v_new_frr_id
	       from   dual;

	       update hr_s_formula_result_rules_f
	       set    formula_result_rule_id = v_new_frr_id
	       ,      status_processing_rule_id = v_new_spr_id
	       where  formula_result_rule_id = results.formula_result_rule_id;

	    END LOOP results;

   	END LOOP sprs;

    END update_uid;

    PROCEDURE integrity_checks
    --------------------------
    IS
	-- After all rows for a primary key have been delivered, entity specific
	-- checks must be performed to check to validity of the data that has
	-- just been installed.

       l_iv_exists boolean;
       l_input_value_id  pay_input_values_f.input_value_id%type;

    BEGIN


	IF r_distinct.c_end = l_end_of_time THEN
	  null;
	ELSE
	  BEGIN
	    -- Check balance feeds
	    select distinct null
	    into   l_null_return
	    from   pay_balance_feeds_f a
	    ,      pay_input_values_f b
	    where  b.element_type_id = l_new_element_type_id
	    and    a.input_value_id = b.input_value_id
	    and    a.effective_end_Date > r_distinct.c_end
	    and    a.business_group_id is not null;

	    crt_exc('User created balance feeds exist after the new end date','I');
	    return;

   	  EXCEPTION WHEN NO_DATA_FOUND THEN

	    -- No invalid child data

	    null;

	  END;

   	  -- check element links

	  BEGIN

            select distinct null
            into   l_null_return
            from   pay_element_links_f
            where  element_type_id = l_new_element_type_id
            and    effective_end_Date > r_distinct.c_end
	    and    business_group_id is not null;

            crt_exc('User created element links exist after the new end date','I');

            return;

          EXCEPTION WHEN NO_DATA_FOUND THEN

	    null;

  	  END;

   	  -- Check formula result rules

	  BEGIN

            select distinct null
            into   l_null_return
            from   pay_status_processing_rules_f a
	    ,      pay_formula_result_rules_f b
            where  a.element_type_id = l_new_element_type_id
	    and    b.status_processing_rule_id = a.status_processing_rule_id
            and    b.effective_end_Date > r_distinct.c_end
	    and    b.business_group_id is not null;

            crt_exc('User created formula rules exist after the new end date','I');

            return;

   	  EXCEPTION WHEN NO_DATA_FOUND THEN

	    null;

	  END;

   	  -- Check payroll run results

	  BEGIN

            BEGIN

              select input_value_id
              into   l_input_value_id
              from   pay_input_values_f
              where  element_type_id = l_new_element_type_id
              and    rownum = 1;

              l_iv_exists := TRUE;

	    EXCEPTION WHEN NO_DATA_FOUND THEN

	      l_iv_exists := FALSE;

	    END;


            if l_iv_exists = TRUE then

              select 1
              into   l_null_return
              from   dual
              where exists
              (select /*+ ORDERED INDEX(a PAY_RUN_RESULTS_PK)
                         USE_NL(a b c) */ null
              from   pay_run_result_values v
              ,      pay_run_results a
              ,      pay_assignment_actions b
              ,      pay_payroll_actions c
              where  v.input_value_id = l_input_value_id
              and    a.run_result_id = v.run_result_id
              and    b.assignment_action_id = a.assignment_action_id
              and    c.payroll_action_id = b.payroll_action_id
              and    c.effective_date > r_distinct.c_end);

            else

              select 1
	      into   l_null_return
              from   dual
              where exists
	      (select null
	      from   pay_run_results a
	      ,      pay_assignment_actions b
	      ,      pay_payroll_actions c
	      where  a.element_Type_id = l_new_element_type_id
	      and    b.assignment_action_id = a.assignment_action_id
	      and    c.payroll_action_id = b.payroll_action_id
	      and    c.effective_date > r_distinct.c_end);

            end if;

	    crt_exc('Run results after the new end date of the element','I');

	    return;

	  EXCEPTION WHEN NO_DATA_FOUND THEN

	    null;

	  END;

      END IF; -- end of time

    END integrity_checks;

    FUNCTION check_parents RETURN BOOLEAN
    -------------------------------------
    IS
	-- Check the integrity of the references to parent data, before allowing
	-- data to be installed. No parents can exist in the startup tables, since
	-- this will violate constraints when the row is installed, also the
	-- parent uid's must exist in the installed tables already.

	-- This function will RETURN TRUE if a parent row still exists in the
	-- delivery account. All statements drop through to a RETURN FALSE.

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

	-- Return code of true indicates that all parental data is correct.

    BEGIN


	-- Start first parent check

   	BEGIN

	    -- Check first parent does not exist in the delivery tables

	    select null
	    into   l_null_return
	    from   hr_s_element_classifications
	    where  classification_id  = r_each_row.classification_id;


	    crt_exc('Parent classification still exists in delivery tables','I');

	    -- Parent still exists, ignore this row

	    return FALSE;

	EXCEPTION WHEN NO_DATA_FOUND THEN

	    null;

	END;

   	BEGIN

	    -- Check that the parent exists in the live tables


	    select null
	    into   l_null_return
	    from   pay_element_classifications
	    where  classification_id = r_each_row.classification_id;

        EXCEPTION WHEN NO_DATA_FOUND THEN


	    crt_exc('Parent classification does not exist in live tables','I');

	   return FALSE;

	END;

	-- Start 2nd parental check

	--
	-- #292675. Only do the check on parent formulas if payroll
	-- is installed, otherwise don't bother.
	--
   	IF  r_each_row.formula_id is not null
	AND l_payroll_install_status = 'I' THEN

	    BEGIN

		-- Check parent formula is not in the delivery tables

	   	select distinct null
	   	into   l_null_return
	   	from   hr_s_formulas_f
	   	where  formula_id = r_each_row.formula_id;

	   	crt_exc('Parent formula remains in the startup tables','I');

	        return FALSE;

	    EXCEPTION WHEN NO_DATA_FOUND THEN

		null;

	    END;

	    BEGIN

		-- Check parent formula is present in the live tables

	        select distinct null
	        into   l_null_Return
		from   ff_formulas_f
	   	where  formula_id = r_each_row.formula_id;

	    EXCEPTION WHEN NO_DATA_FOUND THEN

		crt_exc('Parent formula does not exist in live tables','I');
		return FALSE;

	    END;

	END IF;

	-- Start 3rd parental check

        IF r_each_row.benefit_classification_id is not null THEN

	    BEGIN

		-- Check parent ben class is not in the delivery tables

	   	select null
	   	into   l_null_return
	   	from   hr_s_benefit_classifications
	   	where r_each_row.benefit_classification_id=benefit_classification_id;

	   	crt_exc('Parent benefit class remains in startup tables','I');

		return FALSE;

	    EXCEPTION WHEN NO_DATA_FOUND THEN

		null;

	    END;

	    BEGIN

	        -- Check parent ben class is present in the live tables

	        select null
	        into   l_null_return
	        from   ben_benefit_classifications
	        where r_each_row.benefit_classification_id=benefit_classification_id;

	    EXCEPTION WHEN NO_DATA_FOUND THEN

	        crt_exc('Parent benefit class not in live tables','I');

	        return FALSE;

	    END;

        END IF;

	-- Logic drops through to this statement

       return TRUE;

    END check_parents;

    FUNCTION valid_ownership RETURN BOOLEAN
    ---------------------------------------
    IS
	-- Test ownership of this current row
        --
        -- Order changed as part of bugfix 555175:
	-- This function is split into three distinct parts.
        -- The first check examines if this data is actually required
        -- for a given install by examining the product installation
        -- table, and the ownership details for this row.
        -- The next checks to see if a row exists with the same primary
        -- key, for a business group that would have access to the
        -- delivered row. The last checks details for data created in
        -- other legislations, in case data is either created with a null
        -- legislation or the delivered row has a null legislation.

	-- A return code of TRUE indicates that the row is required.

    CURSOR element_clash
    IS
        -- Cursor to fetch elements with same name

        select /*+ INDEX_FFS(pe) */ business_group_id
        from   pay_element_types_f pe
        where  business_group_id is not null
        and    replace(ltrim(rtrim(upper(element_name))), ' ', '_') =
               replace(ltrim(rtrim(upper(r_distinct.c_true_key))), ' ', '_');


    BEGIN


        -- Bugfix 555175:  This used to be the last of the 3 checks performed.
        -- Now moved to be the first - if the product which requires this row
        -- is not even installed then it is OK for the primary key to already
        -- exist in the users tables.
	-- The check examines the product installation table, and the
	-- ownership details for the delivered row. By examining these
	-- tables the row is either deleted or not. If the delivered row
	-- is 'stamped' with a legislation subgroup, then a check must be
	-- made to see if that subgroup is active or not. This check only
	-- needs to be performed in phase 1, since once this decision is
	-- made, it is pointless to perform this logic again.

	-- An exception is raised if no rows are returned in this select
        -- statement. If no rows are returned then one of the following
        -- is true:
	--     1. No ownership parameters are defined.
	--     2. The products, for which owning parameters are defined, are
        --        not installed with as status of 'I'.
	--     3. The data is defined for a legislation subgroup that is not
        --        active.

        BEGIN

   	    IF p_phase = 1 THEN
               --
               --if exception raised then this row is not needed
               if (r_distinct.legislation_subgroup is null) then
               select distinct null
               into   l_null_Return
               from   dual
               where exists (
                select null
                from   hr_s_application_ownerships a
               ,      fnd_product_installations b
               ,      fnd_application c
               where  a.key_name = 'ELEMENT_TYPE_ID'
               and    a.key_value = r_distinct.c_surrogate_key
               and    a.product_name = c.application_short_name
               and    c.application_id = b.application_id
               and    ((b.status = 'I' and c.application_short_name <> 'PQP')
                       or
                       (b.status in ('I', 'S') and c.application_short_name = 'PQP')));
               else
               select distinct null
               into   l_null_Return
               from   dual
               where exists (
                select null
                from   hr_s_application_ownerships a
               ,      fnd_product_installations b
               ,      fnd_application c
               where  a.key_name = 'ELEMENT_TYPE_ID'
               and    a.key_value = r_distinct.c_surrogate_key
   	       and    a.product_name = c.application_short_name
   	       and    c.application_id = b.application_id
               and    ((b.status = 'I' and c.application_short_name <> 'PQP')
                       or
                       (b.status in ('I', 'S') and c.application_short_name = 'PQP')))
   	       and  exists
	             (select null
	              from hr_legislation_subgroups d
                      where d.legislation_code = r_distinct.legislation_code
                      and d.legislation_subgroup =
                                             r_distinct.legislation_subgroup
                      and d.active_inactive_flag = 'A'
                     );
               end if;
            END IF;


        EXCEPTION WHEN NO_DATA_FOUND THEN

	    -- Row not needed for any installed product


	    remove(r_distinct.c_surrogate_key);

	    -- Indicate row not needed

	    return FALSE;

        END;


        --
        -- Following checks only need to be made if the element type
        -- is a new one and hence doesn't exist yet.
        -- If it does already exist theres no point looking for potential
        -- clashes with existing data!
        --
        if r_distinct.new_element_type_flag = 'Y' then

	   -- Perform a check to see if the primary key has been created within
	   -- a visible business group. Ie: the business group is for the same
	   -- legislation as the delivered row, or the delivered row has a null
	   -- legislation. If no rows are returned then the primary key has not
	   -- already been created by a user.

           if r_distinct.legislation_code is null then

           BEGIN


	       select distinct null
	       into   l_null_return
	       from   pay_element_types_f a
	       where  a.business_group_id is not null
	       and    replace(ltrim(rtrim(upper(a.element_name))), ' ', '_') =
                      replace(ltrim(rtrim(upper(r_distinct.c_true_key))), ' ', '_');


	       crt_exc('Row already created in a business group','I');

	       -- Indicate this row is not to be transferred

	       return FALSE;

	   EXCEPTION WHEN NO_DATA_FOUND THEN

	       null;

	   END;

           else

               for elts in element_clash loop

               BEGIN


                   select distinct null
                   into   l_null_return
                   from   per_business_groups pbg
                   where  pbg.business_group_id = elts.business_group_id
                   and    pbg.legislation_code = r_distinct.legislation_code;


                   crt_exc('Row already created in a business group','I');

                   -- Indicate this row is not to be transferred

                   return FALSE;

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
	   -- G1746. Add the check for business_group_id is null, otherwise the
	   -- row may be wrongly rejected because it already exists for a
	   -- specific business group in another legislation. This, though
	   -- unlikely, is permissible. RMF 05.01.95.

   	   BEGIN


	       select distinct null
	       into   l_null_return
	       from   pay_element_types_f
	       where  element_name = r_distinct.c_true_key
	       and    nvl (legislation_code, 'x') <>
		      nvl (r_distinct.legislation_code, 'x')
	       and   (legislation_code is null
	      	      or r_distinct.legislation_code is null )
	       and    business_group_id is null;


	       crt_exc('Row already created for a visible legislation','I');

	       -- Indicate this row is not to be transferred

	       return FALSE;

           EXCEPTION WHEN NO_DATA_FOUND THEN

	       return TRUE;

	   END;

        else
          return TRUE;
        end if;

    END valid_ownership;

    PROCEDURE delete_live_children
    ------------------------------
    IS
    -- Deletes rows from a live account in readiness for them to be installed

    BEGIN

   	delete from pay_sub_classification_rules_f
   	where  element_type_id = r_distinct.c_surrogate_key
   	and    business_group_id is null;

   	delete from pay_formula_result_rules_f a
   	where  a.business_group_id is null
   	and    exists
          (select null
           from   pay_status_processing_rules_f b
           where  b.status_processing_rule_id = a.status_processing_rule_id
           and    b.element_type_id = r_distinct.c_surrogate_key
	   and    b.business_group_id is null
          );

   	delete from pay_status_processing_rules_f
   	where  element_type_id = r_distinct.c_surrogate_key
   	and    business_Group_id is null;

   	delete from pay_element_types_f
   	where  element_type_id = r_distinct.c_surrogate_key
   	and    business_Group_id is null;

    END delete_live_children;

    FUNCTION install_inputs RETURN BOOLEAN
    --------------------------------------
    IS
	-- Install all associated input values for this element type

    BEGIN

      IF p_phase = 2 THEN

	FOR i_values IN inputs(l_new_element_type_id) LOOP

		delete from pay_input_values_f
	   	where  business_group_id is null
	   	and    input_value_id = i_values.input_value_id;

                BEGIN

                  -- Get the correct value set id from FND_FLEX_VALUES_SETS
                  -- to populate the HR_S_INPUT_VALUES_F.VALUE_SET_ID col with

                  select FLEX_VALUE_SET_ID
                  into   l_flex_value_set_id
                  from   fnd_flex_value_sets
                  where  FLEX_VALUE_SET_NAME = i_values.value_set_name;

                EXCEPTION
                  -- any exception will just use a null not break hrglobal
                  when others then
                    l_flex_value_set_id := null;
                END;

                BEGIN
	   	insert into pay_input_values_f
	   	(input_value_id
	   	,effective_start_date
	   	,effective_end_date
	  	,element_type_id
	   	,lookup_type
	   	,business_group_id
	   	,legislation_code
	  	,formula_id
	  	,display_sequence
	   	,generate_db_items_flag
	  	,hot_default_flag
	  	,mandatory_flag
	  	,name
	   	,uom
	   	,default_value
	   	,legislation_subgroup
	   	,max_value
	   	,min_value
	   	,warning_or_error
	   	,last_update_date
	   	,last_updated_by
	   	,last_update_login
	   	,created_by
	   	,creation_date
                ,value_set_id
	   	)
	   	select input_value_id
	   	,effective_start_date
	   	,effective_end_date
	   	,element_type_id
	   	,lookup_type
	   	,business_group_id
	   	,legislation_code
	  	,formula_id
	  	,display_sequence
	   	,generate_db_items_flag
	   	,hot_default_flag
	   	,mandatory_flag
	   	,name
	   	,uom
	   	,default_value
	   	,legislation_subgroup
	   	,max_value
	   	,min_value
	   	,warning_or_error
	   	,last_update_date
	   	,last_updated_by
	   	,last_update_login
	   	,created_by
	   	,creation_date
                ,l_flex_value_set_id
	   	from hr_s_input_values_f
	   	where input_value_id = i_values.input_value_id;
                EXCEPTION WHEN OTHERS THEN
                        hr_legislation.hrrunprc_trace_on;
                        hr_utility.trace('ins pay_input_values_f');
                        hr_utility.trace('iv id  ' ||
                          to_char(i_values.input_value_id));
                        hr_utility.trace('iv name  ' ||
                          i_values.name);
                        hr_legislation.hrrunprc_trace_off;
                        raise;
                      END;

	   	delete from hr_s_input_values_f
	   	where  input_value_id = i_values.input_value_id;
          --
          -- Bug 2888183 - need to insert balance feeds
          --
          if i_values.name = 'Pay Value' then
          --
            if i_values.new_input_value_flag = 'Y' then
               HRASSACT.CHECK_LATEST_BALANCES := FALSE;
            end if;
            --
            hr_balance_feeds.ins_bf_pay_value
                            (p_input_value_id => i_values.input_value_id
                            ,p_mode           => 'STARTUP'
                            );
            --
            HRASSACT.CHECK_LATEST_BALANCES := TRUE;
            --
          end if;
          --
   	END LOOP i_values;

    ELSE  -- phase 1
      -- If any input values remain, indicate to calling proc

	    select distinct null
	    into   l_null_Return
	    from   hr_s_input_values_f
	    where  element_type_id = l_new_element_type_id;

    END IF;

    -- If values exist, or in phase 2 return success
    return TRUE;

    EXCEPTION WHEN NO_DATA_FOUND THEN

      -- No input values exist no need to proceed
      return FALSE;

    END install_inputs;

    PROCEDURE name_integrity_checks(p_element_name varchar2)
    --------------------------------------------------------
    IS
	-- After all element type id's have been installed for a given element name
	-- check to see if any contention exists with those just installed.

    BEGIN

   	select distinct null
   	into   l_null_return
   	from   pay_element_types_f a
   	where  a.business_Group_id is null
   	and    a.element_name = p_element_name
   	and    exists
		(select null
		 from   pay_element_types_f b
	 	where  b.element_type_id <> a.element_Type_id
	 	and    b.element_name = a.element_name
	 	and    b.business_Group_id is null
	 	and    b.legislation_code = a.legislation_code
	 	and    a.effective_start_date between b.effective_start_date and
		                               b.effective_end_date
		);


	crt_exc('Installed element dates overlap','N');

    EXCEPTION WHEN NO_DATA_FOUND THEN

	null;

    END name_integrity_checks;

    FUNCTION install_element_rows RETURN BOOLEAN
    --------------------------------------------
    IS
	-- Function to insert date effective element rows for a given element type id

    BEGIN

   	IF NOT valid_ownership THEN
	    return FALSE;
	END IF;

        IF p_phase = 1 THEN

	    update_uid;

            return true;

        ELSE

	    -- Phase = 2

	    --
	    -- Find out if payroll is fully installed. If not, i.e. it's
	    -- effectively an HR-only install, do not install the formula_id.
	    -- It causes too many side-effects to deliver with HR.
	    --
	    SELECT status
	    INTO   l_payroll_install_status
	    FROM   fnd_product_installations
	    WHERE  application_id = 801;

	    delete_live_children;

	    FOR each_row IN c_each_element_row(r_distinct.c_surrogate_key) LOOP

	    	r_each_row := each_row;

	    	IF NOT check_parents THEN
		    return FALSE;
	    	END IF;

		--
		-- clear out the formula_id unless payroll is fully installed
		--
		if l_payroll_install_status = 'I' then
		    l_formula_id := each_row.formula_id;
		else
		    l_formula_id := NULL;
		end if;

                BEGIN
	    	insert into pay_element_types_f
	    	(element_type_id
	    	,effective_start_date
	    	,effective_end_date
	   	,business_group_id
	   	,legislation_code
	    	,input_currency_code
	    	,output_currency_code
	    	,classification_id
	    	,benefit_classification_iD
	    	,additional_entry_allowed_flag
	    	,adjustment_only_flag
	    	,closed_for_entry_flag
	    	,element_name
	    	,indirect_only_flag
	    	,multiply_value_flag
	    	,post_termination_rule
	    	,process_in_run_flag
	    	,processing_priority
	    	,processing_type
	    	,standard_link_flag
	    	,formula_id
	    	,comment_id
	    	,description
	    	,legislation_subgroup
	    	,qualifying_age
	    	,qualifying_length_of_service
	    	,qualifying_units
	    	,reporting_name
		,third_party_pay_only_flag
	    	,last_update_date
	    	,last_updated_by
	    	,last_update_login
	    	,created_by
	    	,creation_date
	    	,multiple_entries_allowed_flag
	    	,element_information_category
	   	,element_information1
	    	,element_information2
	    	,element_information3
	    	,element_information4
	    	,element_information5
	    	,element_information6
	    	,element_information7
	    	,element_information8
	    	,element_information9
	    	,element_information10
	    	,element_information11
	    	,element_information12
	    	,element_information13
	    	,element_information14
	    	,element_information15
	    	,element_information16
	    	,element_information17
	    	,element_information18
	    	,element_information19
	    	,element_information20
                ,iterative_flag
                ,iterative_formula_id
                ,iterative_priority
                ,retro_summ_ele_id
                ,grossup_flag
                ,process_mode
                ,proration_group_id
                ,proration_formula_id
                ,TIME_DEFINITION_TYPE
                ,TIME_DEFINITION_ID
	    	)
	   	values
	    	(each_row.element_type_id
	    	,each_row.effective_start_date
	   	,each_row.effective_end_date
	    	,each_row.business_group_id
	    	,each_row.legislation_code
	    	,each_row.input_currency_code
	    	,each_row.output_currency_code
	    	,each_row.classification_id
	    	,each_row.benefit_classification_iD
	    	,each_row.additional_entry_allowed_flag
	    	,each_row.adjustment_only_flag
	    	,each_row.closed_for_entry_flag
	    	,each_row.element_name
	    	,each_row.indirect_only_flag
	    	,each_row.multiply_value_flag
	    	,each_row.post_termination_rule
	    	,each_row.process_in_run_flag
	    	,each_row.processing_priority
	    	,each_row.processing_type
	    	,each_row.standard_link_flag
	    	,l_formula_id
	    	,each_row.comment_id
	    	,each_row.description
	    	,each_row.legislation_subgroup
	    	,each_row.qualifying_age
	    	,each_row.qualifying_length_of_service
	    	,each_row.qualifying_units
	    	,each_row.reporting_name
	    	,each_row.third_party_pay_only_flag
	    	,each_row.last_update_date
	    	,each_row.last_updated_by
	    	,each_row.last_update_login
	    	,each_row.created_by
	    	,each_row.creation_date
	    	,each_row.multiple_entries_allowed_flag
	    	,each_row.element_information_category
	    	,each_row.element_information1
	    	,each_row.element_information2
	    	,each_row.element_information3
	    	,each_row.element_information4
	    	,each_row.element_information5
	    	,each_row.element_information6
	    	,each_row.element_information7
	    	,each_row.element_information8
	    	,each_row.element_information9
	    	,each_row.element_information10
	    	,each_row.element_information11
	    	,each_row.element_information12
	    	,each_row.element_information13
	    	,each_row.element_information14
	    	,each_row.element_information15
	    	,each_row.element_information16
	    	,each_row.element_information17
	    	,each_row.element_information18
	    	,each_row.element_information19
	    	,each_row.element_information20
                ,each_row.iterative_flag
                ,each_row.iterative_formula_id
                ,each_row.iterative_priority
                ,each_row.retro_summ_ele_id
                ,each_row.grossup_flag
                ,each_row.process_mode
                ,each_row.proration_group_id
                ,each_row.proration_formula_id
                ,each_row.TIME_DEFINITION_TYPE
                ,each_row.TIME_DEFINITION_ID
	    	);
                EXCEPTION WHEN OTHERS THEN
                        hr_legislation.hrrunprc_trace_on;
                        hr_utility.trace('ins pay_element_types_f');
                        hr_utility.trace('element type name  ' ||
                          each_row.element_name);
                        hr_utility.trace('element_type_id  ' ||
                          to_char(each_row.element_type_id));
                        hr_utility.trace(':lc: ' || ':' ||
                          each_row.legislation_code || ':');
                        hr_legislation.hrrunprc_trace_off;
                        raise;
                      END;

	    END LOOP each_row;

	    IF NOT install_inputs THEN
	        return FALSE;
	    END IF;

	    BEGIN

	    	-- Installation of sub class rules

	    	FOR s_rules IN sub_rules(r_distinct.c_surrogate_key) LOOP

		    select null
		    into   l_null_return
		    from   pay_element_classifications
		    where  classification_id = s_rules.classification_id;

                   BEGIN
                    insert into pay_sub_classification_rules_f
		    (sub_classification_rule_id
		    ,effective_start_date
		    ,effective_end_date
		    ,element_type_id
		    ,classification_id
		    ,business_group_id
		    ,legislation_code
		    ,last_update_date
		    ,last_updated_by
		    ,last_update_login
		    ,created_by
		    ,creation_date
		    )
		    values
		    (s_rules.sub_classification_rule_id
		    ,s_rules.effective_start_date
		    ,s_rules.effective_end_date
		    ,s_rules.element_type_id
		    ,s_rules.classification_id
		    ,s_rules.business_group_id
		    ,s_rules.legislation_code
		    ,s_rules.last_update_date
		    ,s_rules.last_updated_by
		    ,s_rules.last_update_login
		    ,s_rules.created_by
		    ,s_rules.creation_date
		    );
                      EXCEPTION WHEN OTHERS THEN
                        hr_legislation.hrrunprc_trace_on;
                        hr_utility.trace('ins pay_sub_classification_rules_f');
                        hr_utility.trace('sub_classification_rule_id  ' ||
                          to_char(s_rules.sub_classification_rule_id));
                        hr_utility.trace('element_type_id  ' ||
                          to_char(s_rules.element_type_id));
                        hr_utility.trace('classification_id  ' ||
                          to_char(s_rules.classification_id));
                        hr_utility.trace(':lc: ' || ':' ||
                          s_rules.legislation_code || ':');
                        hr_legislation.hrrunprc_trace_off;
                        raise;
                      END;
                --
                -- Bug 2888183 need to insert balances feeds
                --
                  if (s_rules.new_sub_class_rule_flag = 'Y') then
                     hr_balance_feeds.ins_bf_sub_class_rule
                       (s_rules.sub_classification_rule_id
                       ,'STARTUP');
                  end if;
                  --
	        END LOOP s_rules;

	    EXCEPTION WHEN NO_DATA_FOUND THEN

	        crt_exc('Classifcation in sub class rules, not installed','I');

	        return FALSE;

	    END;

	    -- The installation of processing rules loops distinct rule_ids
	    -- and for each id then installs each date effective row. Each date
	    -- effective row is tested for parental data. When each date effective
	    -- row has been installed, child formula result rules are installed.

	    BEGIN

	        -- Installation of status processing rules

	        FOR p_rules IN proc_rules(r_distinct.c_surrogate_key) LOOP

		     FOR all_rules IN all_p_rules(p_rules.s_rule_id) LOOP

                       BEGIN
		   	insert into pay_status_processing_rules_f
		  	 (STATUS_PROCESSING_RULE_ID
		   	,EFFECTIVE_START_DATE
		  	,EFFECTIVE_END_DATE
		   	,BUSINESS_GROUP_ID
		   	,LEGISLATION_CODE
		   	,ELEMENT_TYPE_ID
		   	,ASSIGNMENT_STATUS_TYPE_ID
		   	,FORMULA_ID
		   	,PROCESSING_RULE
		   	,COMMENT_ID
		   	,LEGISLATION_SUBGROUP
		   	,LAST_UPDATE_DATE
		   	,LAST_UPDATED_BY
		   	,LAST_UPDATE_LOGIN
		   	,CREATED_BY
		   	,CREATION_DATE
		   	)
		   	values
		   	(all_rules.STATUS_PROCESSING_RULE_ID
		   	,all_rules.EFFECTIVE_START_DATE
		   	,all_rules.EFFECTIVE_END_DATE
		   	,all_rules.BUSINESS_GROUP_ID
		   	,all_rules.LEGISLATION_CODE
		   	,all_rules.ELEMENT_TYPE_ID
		   	,all_rules.ASSIGNMENT_STATUS_TYPE_ID
		   	,all_rules.FORMULA_ID
		   	,all_rules.PROCESSING_RULE
		   	,all_rules.COMMENT_ID
		   	,all_rules.LEGISLATION_SUBGROUP
		   	,all_rules.LAST_UPDATE_DATE
		   	,all_rules.LAST_UPDATED_BY
		   	,all_rules.LAST_UPDATE_LOGIN
		   	,all_rules.CREATED_BY
		   	,all_rules.CREATION_DATE
		   	);
                      EXCEPTION WHEN OTHERS THEN
                        hr_legislation.hrrunprc_trace_on;
                        hr_utility.trace('ins pay_status_processing_rules_f');
                        hr_utility.trace('STATUS_PROCESSING_RULE_ID  ' ||
                          to_char(all_rules.STATUS_PROCESSING_RULE_ID));
                        hr_utility.trace('ELEMENT_TYPE_ID  ' ||
                          to_char(all_rules.element_type_id));
                        hr_utility.trace('PROCESSING_RULE  ' ||
                          all_rules.PROCESSING_RULE);
                        hr_utility.trace('ASSIGNMENT_STATUS_TYPE_ID  ' ||
                          to_char(all_rules.ASSIGNMENT_STATUS_TYPE_ID));
                        hr_utility.trace(':lc: ' || ':' ||
                          all_rules.legislation_code || ':');
                        hr_legislation.hrrunprc_trace_off;
                        raise;
                      END;


		    END LOOP all_rules;

		    FOR all_frrs IN frrs(p_rules.s_rule_id) LOOP

                       BEGIN
		   	insert into pay_formula_result_rules_f
		   	(FORMULA_RESULT_RULE_ID
		   	,EFFECTIVE_START_DATE
		   	,EFFECTIVE_END_DATE
		   	,BUSINESS_GROUP_ID
		   	,LEGISLATION_CODE
		   	,STATUS_PROCESSING_RULE_ID
		   	,RESULT_NAME
		  	 ,RESULT_RULE_TYPE
		  	 ,LEGISLATION_SUBGROUP
		  	 ,SEVERITY_LEVEL
		  	 ,INPUT_VALUE_ID
		  	 ,ELEMENT_TYPE_ID
		  	 ,LAST_UPDATE_DATE
		   	,LAST_UPDATED_BY
		   	,LAST_UPDATE_LOGIN
		   	,CREATED_BY
		   	,CREATION_DATE
		   	)
		   	values
		   	(all_frrs.FORMULA_RESULT_RULE_ID
		   	,all_frrs.EFFECTIVE_START_DATE
		   	,all_frrs.EFFECTIVE_END_DATE
		   	,all_frrs.BUSINESS_GROUP_ID
		   	,all_frrs.LEGISLATION_CODE
		   	,all_frrs.STATUS_PROCESSING_RULE_ID
		   	,all_frrs.RESULT_NAME
		   	,all_frrs.RESULT_RULE_TYPE
		   	,all_frrs.LEGISLATION_SUBGROUP
		   	,all_frrs.SEVERITY_LEVEL
		   	,all_frrs.INPUT_VALUE_ID
		   	,all_frrs.ELEMENT_TYPE_ID
		   	,all_frrs.LAST_UPDATE_DATE
		   	,all_frrs.LAST_UPDATED_BY
		   	,all_frrs.LAST_UPDATE_LOGIN
		   	,all_frrs.CREATED_BY
		   	,all_frrs.CREATION_DATE
		  	 );
                      EXCEPTION WHEN OTHERS THEN
                        hr_legislation.hrrunprc_trace_on;
                        hr_utility.trace('ins pay_formula_result_rules_f');
                        hr_utility.trace('FORMULA_RESULT_RULE_ID  ' ||
                          to_char(all_frrs.FORMULA_RESULT_RULE_ID));
                        hr_utility.trace('STATUS_PROCESSING_RULE_ID  ' ||
                          to_char(all_frrs.STATUS_PROCESSING_RULE_ID));
                        hr_utility.trace('RESULT_NAME  ' ||
                          all_frrs.RESULT_NAME);
                        hr_utility.trace(':lc: ' || ':' ||
                          all_frrs.legislation_code || ':');
                        hr_legislation.hrrunprc_trace_off;
                        raise;
                      END;

		    END LOOP all_frrs;

	    	END LOOP p_rules; --end the distinct loop

	    EXCEPTION WHEN NO_DATA_FOUND THEN

	    	crt_exc('Child status rules has parent data not installed','I');

	    	return FALSE;

	    END;

	    remove(r_distinct.c_surrogate_key);

	    return TRUE;

   	END IF;

    END install_element_rows;

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
    --     In Phase 2:
    --               - Delete from the installed tables using the surrogate id.
    --               - If an installed row is to be replaced, the values of
    --                 the surrogate keys will be identicle at this stage.
    --               - Data will then be deleted from the delivery tables.
    --               - Call the installation procedure for any child tables, that
    --                 must be installed within the same commit unit. If any
    --                 errors occur then rollback to the last declared savepoint.
    --               - Check that all integrity rules are still obeyed at the end
    --                 of the installation (integrity_checks).

    -- An exception is used with this procedure 'row_in_error' in case an error
    -- is encountered from calling any function. If this is raised, then an
    -- exception is entered into the control tables (crt_exc();) and a rollback
    -- is performed.

    IF p_phase = 1 THEN
	check_next_sequence;
    END IF;

    FOR element_names IN c_distinct_name LOOP


	savepoint new_element_name;

  	FOR element_ids IN c_distinct_element(element_names.element_name) LOOP

	    savepoint new_distinct_id;

	    r_distinct := element_ids;

	    IF p_phase = 2 THEN
	        l_new_element_type_id := r_distinct.c_surrogate_key;
	    END IF;

	    -- Ensure both phases use the same value for the surrogate id

	    IF install_element_rows THEN
		integrity_checks;
	    END IF;

        END LOOP element_ids;

       	IF p_phase = 2 THEN
	    name_integrity_checks(element_names.element_name);
   	END IF;

    END LOOP element_names;

END install_elements;

--****************************************************************************
-- INSTALLATION PROCEDURE FOR : PAY_ELEMENT_SETS
--****************************************************************************

PROCEDURE install_ele_sets(p_phase IN number)
---------------------------------------------
IS
    l_null_return varchar2(1);		-- For 'select null' statements
    l_new_surrogate_key number(15); 	-- New surrogate key for the delivery row

    CURSOR stu				-- Selects all rows from startup entity
    IS
	select element_set_name c_true_key
	,      element_set_id c_surrogate_key
	,      legislation_code c_leg_code
	,      element_set_type
	,      last_update_date
	,      last_updated_by
	,      last_update_login
	,      created_by
	,      creation_date
	,      rowid
	from   hr_s_element_sets;

    CURSOR child_type(ele_set_id number)
    IS
	-- Cursor to install child element type rules

	select *
	from   hr_s_element_type_rules
	where  element_set_id = ele_set_id;

    CURSOR child_class(ele_set_id number)
    IS
	-- Cursor to install child element classification rules

	select *
	from   hr_s_ele_classn_rules
	where  element_set_id = ele_set_id;

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
	    from   pay_element_sets a
	    where  exists
		(select null
		 from   hr_s_element_sets b
		 where  a.element_set_id = b.element_set_id
		);

	    --conflict may exist
	    --update all element_set_id's to remove conflict

	    update /*+NO_INDEX*/ hr_s_element_sets
	    set    element_set_id = element_set_id - 50000000;

            update /*+NO_INDEX*/ hr_s_element_type_rules
            set    element_set_id = element_set_id - 50000000;

            update /*+NO_INDEX*/ hr_s_ele_classn_rules
            set    element_set_id = element_set_id - 50000000;

	    update hr_s_application_ownerships
	    set    key_value = key_value - 50000000
	    where  key_name = 'ELEMENT_SET_ID';

	EXCEPTION WHEN NO_DATA_FOUND THEN NULL;

	END; --check of element_set_id



	select min(element_set_id) - (count(*) *3)
	,      max(element_set_id) + (count(*) *3)
	into   v_min_delivered
	,      v_max_delivered
	from   hr_s_element_sets;

	select pay_element_sets_s.nextval
	into   v_sequence_number
	from   dual;

        IF v_sequence_number
	  BETWEEN v_min_delivered AND v_max_delivered
	THEN

          hr_legislation.munge_sequence('PAY_ELEMENT_SETS_S',
                                        v_sequence_number,
                                        v_max_delivered);

        END IF;

    END check_next_sequence;


    PROCEDURE crt_exc (exception_type IN varchar2)
    ----------------------------------------------
    IS
	-- Reports any exceptions during the delivery of startup data to
	-- PAY_ELEMENT_SETS

    BEGIN
	-- When the installation procedures encounter an error that cannot
	-- be handled, an exception is raised and all work is rolled back
	-- to the last savepoint. The installation process then continues
	-- with the next primary key to install. The same exception will
	-- not be raised more than once.


	rollback to new_element_set_name;

	hr_legislation.insert_hr_stu_exceptions('pay_element_sets'
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

	    select distinct element_set_id
	    into   l_new_surrogate_key
	    from   pay_element_sets
	    where  element_set_name = stu_rec.c_true_key
	    and    business_group_id is null
            and  ( (legislation_code is null
                 and  stu_rec.c_leg_code is null)
                 or (legislation_code = stu_rec.c_leg_code) );

	EXCEPTION WHEN NO_DATA_FOUND THEN


	   select pay_element_sets_s.nextval
	   into   l_new_surrogate_key
	   from   dual;

                  WHEN TOO_MANY_ROWS THEN

                        hr_legislation.hrrunprc_trace_on;
                        hr_utility.trace('sel pay_element_sets TMR');
                        hr_utility.trace('element_set_name  ' ||
                          stu_rec.c_true_key);
                        hr_utility.trace(':lc: ' || ':' ||
                          stu_rec.c_leg_code || ':');
                        hr_legislation.hrrunprc_trace_off;
                        raise;
	END;

	--update all child entities
   	update hr_s_element_sets
   	set    element_set_id = l_new_surrogate_key
   	where  element_set_id = stu_rec.c_surrogate_key;

   	update hr_s_application_ownerships
   	set    key_value = to_char(l_new_surrogate_key)
   	where  key_value = to_char(stu_rec.c_surrogate_key)
   	and    key_name = 'ELEMENT_SET_ID';

   	update hr_s_element_type_rules
   	set    element_set_id = l_new_surrogate_key
   	where  element_set_id = stu_rec.c_surrogate_key;

   	update hr_s_ele_classn_rules
   	set    element_set_id = l_new_surrogate_key
   	where  element_set_id = stu_rec.c_surrogate_key;

    END update_uid;

    PROCEDURE remove
    ----------------
    IS
	-- Remove a row from either the startup tables or the installed tables

        v_number number;

    BEGIN

   	delete from hr_s_element_type_rules
   	where  element_set_id = l_new_surrogate_key;

   	delete from hr_s_ele_classn_rules
   	where  element_set_id = l_new_surrogate_key;

   	delete from hr_s_element_sets
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

	IF p_phase <> 1 THEN	-- Only perform in phase 1
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
	where  a.key_name = 'ELEMENT_SET_ID'
	and    a.key_value = stu_rec.c_surrogate_key
	and    a.product_name = c.application_short_name
	and    c.application_id = b.application_id
        and    ((b.status = 'I' and c.application_short_name <> 'PQP')
                or
                (b.status in ('I', 'S') and c.application_short_name = 'PQP')));

	return TRUE;	--indicates row is required

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

	v_inst_update date;	-- Holds update details of installed row

    BEGIN


	BEGIN

	    -- Perform a check to see if the primary key has been creeated within
	    -- a visible business group. Ie: the business group is for the same
	    -- legislation as the delivered row, or the delivered row has a null
	    -- legislation. If no rows are returned then the primary key has not
	    -- already been created by a user.

            select distinct null
            into   l_null_return
            from pay_element_sets a
            where a.element_set_name = stu_rec.c_true_key
            and   a.business_group_id is not null
            and   exists (select null from per_business_groups b
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
	-- G1746. Add the check for business_group_id is null, otherwise the
	-- row may be wrongly rejected because it already exists for a
	-- specific business group in another legislation. This, though
	-- unlikely, is permissible. RMF 05.01.95.

        BEGIN
            select distinct null
            into   l_null_return
            from   pay_element_sets
            where  element_set_name = stu_rec.c_true_key
            and    nvl(legislation_code,'x') <> nvl(stu_rec.c_leg_code,'x')
            and   (legislation_code is null
                  or stu_rec.c_leg_code is null )
	    and    business_group_id is null;

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

   	delete from pay_element_type_rules
   	where  element_set_id = l_new_surrogate_key;

   	delete from pay_ele_classification_rules
   	where  element_set_id = l_new_surrogate_key;

   	update pay_element_sets
   	set    element_set_type = stu_rec.element_set_type
   	,      last_update_date = stu_rec.last_update_date
   	,      last_updated_by = stu_rec.last_updated_by
   	,      last_update_login = stu_rec.last_update_login
   	,      created_by = stu_rec.created_by
   	,      creation_date = stu_rec.creation_date
   	where  element_set_id = stu_rec.c_surrogate_key;

   	IF NOT SQL%FOUND THEN


           BEGIN
	    insert into pay_element_sets
	    (element_set_name
	    ,element_set_id
	    ,legislation_code
	    ,element_set_type
	    ,last_update_date
	    ,last_updated_by
	    ,last_update_login
	    ,created_by
	    ,creation_date
	    )
	    values
	    (stu_rec.c_true_key
	    ,stu_rec.c_surrogate_key
	    ,stu_rec.c_leg_code
	    ,stu_rec.element_set_type
	    ,stu_rec.last_update_date
	    ,stu_rec.last_updated_by
	    ,stu_rec.last_update_login
	    ,stu_rec.created_by
	    ,stu_rec.creation_date
	    );
                      EXCEPTION WHEN OTHERS THEN
                        hr_legislation.hrrunprc_trace_on;
                        hr_utility.trace('ins pay_element_sets');
                        hr_utility.trace('element_set_name  ' ||
                          stu_rec.c_true_key);
                        hr_utility.trace('element_set_id  ' ||
                          to_char(stu_rec.c_surrogate_key));
                        hr_utility.trace('element_set_type  ' ||
                          stu_rec.element_set_type);
                        hr_utility.trace(':lc: ' || ':' ||
                          stu_rec.c_leg_code || ':');
                        hr_legislation.hrrunprc_trace_off;
                        raise;
                      END;

	END IF;

   	-- Now install all child element type rules


   	FOR ele_types IN child_type(stu_rec.c_surrogate_key) LOOP

	    BEGIN


	   	select null
	   	into   l_null_return
	   	from   pay_element_types_f
	   	where  element_type_id = ele_types.element_type_id;

               BEGIN
	   	insert into pay_element_type_rules
	   	(element_type_id
	   	,element_set_id
	   	,include_or_exclude
	   	,last_update_date
	   	,last_updated_by
	   	,last_update_login
	   	,created_by
	   	,creation_date)
	   	values
           	(ele_types.element_Type_id
           	,ele_types.element_Set_id
           	,ele_types.include_or_exclude
           	,ele_types.last_update_date
           	,ele_types.last_updated_by
           	,ele_types.last_update_login
           	,ele_types.created_by
           	,ele_types.creation_date);
                 EXCEPTION    WHEN OTHERS THEN
                        hr_legislation.hrrunprc_trace_on;
                        hr_utility.trace('ins pay_element_type_rules');
                        hr_utility.trace('element_type_id  ' ||
                          to_char(ele_types.element_Type_id));
                        hr_utility.trace('element_set_id  ' ||
                          to_char(ele_types.element_Set_id));
                        hr_legislation.hrrunprc_trace_off;
                        raise;
                 END;


	    EXCEPTION WHEN NO_DATA_FOUND THEN

		crt_exc('Parent element type not installed');

		return;

	    END;

        END LOOP;

	-- Now install all classification rules


   	FOR ele_class IN child_class(stu_Rec.c_surrogate_key) LOOP

	    BEGIN


	    	select null
	    	into   l_null_return
	    	from   pay_element_classifications
	    	where  classification_id = ele_class.classification_id;

               BEGIN
	    	insert into pay_ele_classification_rules
	    	(element_set_id
	    	,classification_id
	    	,last_update_date
	    	,last_updated_by
	    	,last_update_login
	    	,created_by
	    	,creation_date)
	    	values
            	(ele_class.element_set_id
            	,ele_class.classification_id
            	,ele_class.last_update_date
            	,ele_class.last_updated_by
            	,ele_class.last_update_login
            	,ele_class.created_by
            	,ele_class.creation_date);
                      EXCEPTION WHEN OTHERS THEN
                        hr_legislation.hrrunprc_trace_on;
                        hr_utility.trace('ins pay_ele_classification_rules');
                        hr_utility.trace('element_set_id  ' ||
                          to_char(ele_class.element_set_id));
                        hr_utility.trace('classification_id  ' ||
                          to_char(ele_class.classification_id));
                        hr_legislation.hrrunprc_trace_off;
                        raise;
                      END;

	    EXCEPTION WHEN NO_DATA_FOUND THEN

	    	crt_exc('Parent classification not installed');

                return;

	    END;

       END LOOP;


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

    IF p_phase = 1 THEN
	check_next_sequence;
    END IF;

    FOR delivered IN stu LOOP

	-- Uses main cursor stu to impilicity define a record


   	savepoint new_element_set_name;

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

END install_ele_sets;

--****************************************************************************
-- INSTALLATION PROCEDURE FOR : PAY_USER_TABLES
--****************************************************************************

PROCEDURE install_utables(p_phase IN number)
--------------------------------------------
IS
    -- Install procedure to transfer startup element classifications into
    -- a live account.

    l_null_return varchar2(1);		-- For 'select null' statements
    l_new_surrogate_key number(15); 	-- New surrogate key for the delivery row

    CURSOR stu				-- Selects all rows from startup entity
    IS
	select user_table_id c_surrogate_key
	,      business_group_id
	,      legislation_code c_leg_code
	,      range_or_match
	,      user_key_units
	,      user_table_name c_true_key
	,      legislation_subgroup c_leg_sgrp
	,      last_update_date
	,      last_updated_by
	,      last_update_login
	,      created_by
	,      creation_date
	,      rowid
	,      user_row_title
	from   hr_s_user_tables;

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
	    from   pay_user_tables a
	    where  exists
		(select null
		 from   hr_s_user_tables b
		 where  a.user_table_id = b.user_table_id
		);

	    --conflict may exist
	    --update all user_table_id's to remove conflict

	    update /*+NO_INDEX*/ hr_s_user_columns
	    set    user_table_id = user_table_id - 50000000;

            update /*+NO_INDEX*/ hr_s_user_rows_f
            set    user_table_id = user_table_id - 50000000;

            update /*+NO_INDEX*/ hr_s_user_tables
            set    user_table_id = user_table_id - 50000000;

	    update hr_s_application_ownerships
	    set    key_value = key_value - 50000000
	    where  key_name = 'USER_TABLE_ID';

	EXCEPTION WHEN NO_DATA_FOUND THEN NULL;

	END; --check of user_table_id



	select min(user_table_id) - (count(*) *3)
	,      max(user_table_id) + (count(*) *3)
	into   v_min_delivered
	,      v_max_delivered
	from   hr_s_user_tables;

	select pay_user_tables_s.nextval
	into   v_sequence_number
	from   dual;

        IF v_sequence_number
	  BETWEEN v_min_delivered AND v_max_delivered
	THEN

          hr_legislation.munge_sequence('PAY_USER_TABLES_S',
                                        v_sequence_number,
                                        v_max_delivered);

        END IF;

    END check_next_sequence;


    PROCEDURE crt_exc (exception_type IN varchar2)
    ----------------------------------------------
    IS
	-- Reports any exceptions during the delivery of startup data to
	-- PAY_USER_TABLES

    BEGIN
	-- When the installation procedures encounter an error that cannot
	-- be handled, an exception is raised and all work is rolled back
	-- to the last savepoint. The installation process then continues
	-- with the next primary key to install. The same exception will
	-- not be raised more than once.


	rollback to new_user_table_name;

	hr_legislation.insert_hr_stu_exceptions('pay_user_tables'
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

	    select distinct user_table_id
	    into   l_new_surrogate_key
	    from   pay_user_tables
	    where  user_table_name = stu_rec.c_true_key
	    and    business_group_id is null
            and  ( (legislation_code is null
                 and  stu_rec.c_leg_code is null)
                 or (legislation_code = stu_rec.c_leg_code) );

   	EXCEPTION WHEN NO_DATA_FOUND THEN


	    select pay_user_tables_s.nextval
	    into   l_new_surrogate_key
	    from   dual;

                  WHEN TOO_MANY_ROWS THEN
                        hr_legislation.hrrunprc_trace_on;
                        hr_utility.trace('sel pay_user_tables TMR');
                        hr_utility.trace('user_table_name  ' ||
                          stu_rec.c_true_key);
                        hr_utility.trace(':lc: ' || ':' ||
                          stu_rec.c_leg_code || ':');
                        hr_legislation.hrrunprc_trace_off;
                        raise;

        END;

	-- Update all child entities
   	update hr_s_user_tables
   	set    user_table_id = l_new_surrogate_key
   	where  user_table_id = stu_rec.c_surrogate_key;

   	update hr_s_application_ownerships
   	set    key_value = to_char(l_new_surrogate_key)
   	where  key_value = to_char(stu_rec.c_surrogate_key)
   	and    key_name = 'USER_TABLE_ID';

   	update hr_s_user_columns
   	set    user_table_id = l_new_surrogate_key
   	where  user_table_id = stu_rec.c_surrogate_key;

   	update hr_s_user_rows_f
   	set    user_table_id = l_new_surrogate_key
   	where  user_table_id = stu_rec.c_surrogate_key;

    END update_uid;

    PROCEDURE remove
    ----------------
    IS
	-- Remove a row from either the startup tables or the installed tables

    BEGIN

   	delete from hr_s_user_tables
   	where  rowid = stu_rec.rowid;

    END remove;

    FUNCTION valid_ownership RETURN BOOLEAN
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

	IF p_phase <> 1 THEN	-- Only perform in phase 1
	    return TRUE;
	END IF;


        -- If exception raised below then this row is not needed
        if (stu_rec.c_leg_sgrp is null) then
        select null
        into   l_null_return
        from   dual
        where  exists
        (select null
        from   hr_s_application_ownerships a
        ,      fnd_product_installations b
        ,      fnd_application c
        where  a.key_name = 'USER_TABLE_ID'
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
	where  a.key_name = 'USER_TABLE_ID'
	and    a.key_value = stu_rec.c_surrogate_key
	and    a.product_name = c.application_short_name
	and    c.application_id = b.application_id
        and    ((b.status = 'I' and c.application_short_name <> 'PQP')
                or
                (b.status in ('I', 'S') and c.application_short_name = 'PQP')))
	and  exists (select null from hr_legislation_subgroups d
	      where  d.legislation_code = stu_rec.c_leg_code
	     and  d.legislation_subgroup = stu_rec.c_leg_sgrp
	     and  d.active_inactive_flag = 'A'
	         );
        end if;

	return TRUE;	--indicates row is required

    EXCEPTION WHEN NO_DATA_FOUND THEN

	-- Row not needed for any installed product


	remove;

	-- Indicate row not needed

	return FALSE;

    END valid_ownership;

    PROCEDURE transfer_row
    ----------------------
    IS
	-- Check if a delivered row is needed and insert into the
	-- live tables if it is

    v_inst_update date;		-- Holds update details of installed row

    BEGIN


   	BEGIN

	    -- Perform a check to see if the primary key has been creeated within
	    -- a visible business group. Ie: the business group is for the same
	    -- legislation as the delivered row, or the delivered row has a null
	    -- legislation. If no rows are returned then the primary key has not
	    -- already been created by a user.

            select distinct null
            into   l_null_return
            from pay_user_tables a
            where a.user_table_name = stu_rec.c_true_key
            and   a.business_group_id is not null
            and   exists (select null from per_business_groups b
              where b.business_group_id = a.business_group_id
              and b.legislation_code = nvl(stu_rec.c_leg_code,b.legislation_code));

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
	-- G1746. Add the check for business_group_id is null, otherwise the
	-- row may be wrongly rejected because it already exists for a
	-- specific business group in another legislation. This, though
	-- unlikely, is permissible. RMF 05.01.95.

        BEGIN

            select distinct null
            into   l_null_return
            from   pay_user_tables
            where  user_table_name = stu_rec.c_true_key
            and    nvl(legislation_code,'x') <> nvl(stu_rec.c_leg_code,'x')
            and   (legislation_code is null or stu_rec.c_leg_code is null )
	    and    business_group_id is null;

            crt_exc('Row already created for a visible legislation');

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


   	update pay_user_tables
   	set range_or_match = stu_rec.range_or_match
   	,   user_key_units = stu_rec.user_key_units
   	,   last_update_date = stu_rec.last_update_date
   	,   last_updated_by = stu_rec.last_updated_by
   	,   last_update_login = stu_rec.last_update_login
   	,   created_by = stu_rec.created_by
   	,   creation_date = stu_rec.creation_date
   	,   user_row_title = stu_rec.user_row_title
   	where  user_table_id = stu_rec.c_surrogate_key;

   	IF NOT SQL%FOUND THEN

           BEGIN
	    insert into pay_user_tables
	    (user_table_id
	    ,business_group_id
	    ,legislation_code
	    ,range_or_match
	    ,user_key_units
	    ,user_table_name
	    ,legislation_subgroup
	    ,last_update_date
	    ,last_updated_by
	    ,last_update_login
	    ,created_by
	    ,creation_date
	    ,user_row_title
	    )
	    values
	    (stu_rec.c_surrogate_key
	    ,stu_rec.business_group_id
	    ,stu_rec.c_leg_code
	    ,stu_rec.range_or_match
	    ,stu_rec.user_key_units
	    ,stu_rec.c_true_key
	    ,stu_rec.c_leg_sgrp
	    ,stu_rec.last_update_date
	    ,stu_rec.last_updated_by
	    ,stu_rec.last_update_login
	    ,stu_rec.created_by
	    ,stu_rec.creation_date
	    ,stu_rec.user_row_title
	    );
                      EXCEPTION WHEN OTHERS THEN
                        hr_legislation.hrrunprc_trace_on;
                        hr_utility.trace('ins pay_user_tables');
                        hr_utility.trace('user_table_id  ' ||
                          to_char(stu_rec.c_surrogate_key));
                        hr_utility.trace('user_table_name  ' ||
                          stu_rec.c_true_key);
                        hr_utility.trace(':lc: ' || ':' ||
                          stu_rec.c_leg_code || ':');
                        hr_legislation.hrrunprc_trace_off;
                        raise;
                      END;

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

    IF p_phase = 1 THEN
	check_next_sequence;
    END IF;

    FOR delivered IN stu LOOP

	-- Uses main cursor stu to impilicity define a record


   	savepoint new_user_table_name;

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

END install_utables;

--****************************************************************************
-- INSTALLATION PROCEDURE FOR : PAY_USER_COLUMNS
--****************************************************************************

PROCEDURE install_ucolumns (p_phase IN number)
----------------------------------------------
IS
    -- Install procedure to transfer startup element classifications into
    -- a live account.

    l_null_return varchar2(1);		-- For 'select null' statements
    l_new_surrogate_key number(15);	-- New surrogate key for the delivery row


    CURSOR stu				-- Selects all rows from startup entity
    IS
	--
	-- #271139 - note that the user column name is not the true key on
	-- its own; it's only unique for the user table.
	-- Must use the user table id in select criteria for the true key.
	--
	select user_column_id c_surrogate_key
	,      business_group_id
	,      legislation_code c_leg_code
	,      user_table_id
	,      formula_id
	,      user_column_name c_true_key
	,      legislation_subgroup c_leg_sgrp
	,      last_update_date
	,      last_updated_by
	,      last_update_login
	,      created_by
	,      creation_date
	,      rowid
	from   hr_s_user_columns;

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
	    from   pay_user_columns a
	    where  exists
		(select null
		 from   hr_s_user_columns b
		 where  a.user_column_id = b.user_column_id
		);

	    --conflict may exist
	    --update all user_column_id's to remove conflict

	    update /*+NO_INDEX*/ hr_s_user_columns
	    set    user_column_id = user_column_id - 50000000;

            update /*+NO_INDEX*/ hr_s_user_column_instances_f
            set    user_column_id = user_column_id - 50000000;

	    update hr_s_application_ownerships
	    set    key_value = key_value - 50000000
	    where  key_name = 'USER_COLUMN_ID';

	EXCEPTION WHEN NO_DATA_FOUND THEN NULL;

	END; --check of user_column_id



	select min(user_column_id) - (count(*) *3)
	,      max(user_column_id) + (count(*) *3)
	into   v_min_delivered
	,      v_max_delivered
	from   hr_s_user_columns;

	select pay_user_columns_s.nextval
	into   v_sequence_number
	from   dual;

        IF v_sequence_number
	  BETWEEN v_min_delivered AND v_max_delivered
	THEN

          hr_legislation.munge_sequence('PAY_USER_COLUMNS_S',
                                        v_sequence_number,
                                        v_max_delivered);

        END IF;

    END check_next_sequence;


    PROCEDURE crt_exc (exception_type IN varchar2)
    ----------------------------------------------
    IS
	-- Reports any exceptions during the delivery of startup data to
	-- PAY_USER_COLUMNS

    BEGIN
	-- When the installation procedures encounter an error that cannot
	-- be handled, an exception is raised and all work is rolled back
	-- to the last savepoint. The installation process then continues
	-- with the next primary key to install. The same exception will
	-- not be raised more than once.


	rollback to new_user_column_name;

	hr_legislation.insert_hr_stu_exceptions('pay_user_columns'
        ,      stu_rec.c_surrogate_key
        ,      exception_type
        ,      stu_rec.c_true_key);


    END crt_exc;

    PROCEDURE update_uid
    --------------------
    IS
    	-- subprogram to update surrogate UID and all occurrences in child rows

    BEGIN


	BEGIN
	   --
	   -- #271139 - hitting a problem because the user column name is
	   -- not the true key on its own; it's only unique for the user table.
	   -- Add the user table id to the select criteria.
	   --
	    select distinct user_column_id
	    into   l_new_surrogate_key
	    from   pay_user_columns
	    where  user_column_name = stu_rec.c_true_key
	    and    user_table_id    = stu_rec.user_table_id
	    and    business_group_id is null
            and  ( (legislation_code is null
                 and  stu_rec.c_leg_code is null)
                 or (legislation_code = stu_rec.c_leg_code) );

        EXCEPTION WHEN NO_DATA_FOUND THEN


	    select pay_user_columns_s.nextval
	    into   l_new_surrogate_key
	    from   dual;

                 WHEN TOO_MANY_ROWS THEN
                        hr_legislation.hrrunprc_trace_on;
                        hr_utility.trace('sel pay_user_columns TMR');
                        hr_utility.trace('user_column_name  ' ||
                          stu_rec.c_true_key);
                        hr_utility.trace('user_table_id  ' ||
                          to_char(stu_rec.user_table_id));
                        hr_utility.trace(':lc: ' || ':' ||
                          stu_rec.c_leg_code || ':');
                        hr_legislation.hrrunprc_trace_off;
                        raise;
   	END;

	-- Update all child entities

   	update hr_s_user_columns
   	set    user_column_id = l_new_surrogate_key
   	where  user_column_id = stu_rec.c_surrogate_key;

   	update hr_s_application_ownerships
   	set    key_value = to_char(l_new_surrogate_key)
   	where  key_value = to_char(stu_rec.c_surrogate_key)
   	and    key_name = 'USER_COLUMN_ID';

   	update hr_s_user_column_instances_f
   	set    user_column_id = l_new_surrogate_key
   	where  user_column_id = stu_rec.c_surrogate_key;

    END update_uid;

    PROCEDURE remove
    ----------------
    IS
	-- Remove a row from either the startup tables or the installed tables

    BEGIN

   	delete from hr_s_user_columns
   	where  rowid = stu_rec.rowid;

    END remove;

    FUNCTION valid_ownership RETURN BOOLEAN
    ---------------------------------------
    IS
	-- Test ownership of this current row

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

	-- A return code of TRUE indicates that the row is required.

	-- The exception is raised within this procedure if no rows are returned
	-- in this select statement. If no rows are returned then one of the
	-- following is true:
	--     1. No ownership parameters are defined.
	--     2. The products, for which owning parameters are defined, are not
	--        installed with as status of 'I'.
	--     3. The data is defined for a legislation subgroup that is not active.

    BEGIN


	IF p_phase <> 1 THEN
	    return TRUE;
	END IF;


	-- If exception raised below hen this row is not needed
        if (stu_rec.c_leg_sgrp is null) then
        select null
        into   l_null_return
        from   dual
        where  exists
        (select null
        from   hr_s_application_ownerships a
        ,      fnd_product_installations b
        ,      fnd_application c
        where  a.key_name = 'USER_COLUMN_ID'
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
	where  a.key_name = 'USER_COLUMN_ID'
	and    a.key_value = stu_rec.c_surrogate_key
	and    a.product_name = c.application_short_name
	and    c.application_id = b.application_id
        and    ((b.status = 'I' and c.application_short_name <> 'PQP')
                or
                (b.status in ('I', 'S') and c.application_short_name = 'PQP')))
	and  exists (select null from hr_legislation_subgroups d
            where d.legislation_code = stu_rec.c_leg_code
	     and  d.legislation_subgroup = stu_rec.c_leg_sgrp
	     and  d.active_inactive_flag = 'A'
	         );
        end if;

	return TRUE;	--indicates row is required

    EXCEPTION WHEN NO_DATA_FOUND THEN

	-- Row not needed for any installed product


	remove;

	-- Indicates row not needed

	return FALSE;

    END valid_ownership;

    FUNCTION check_parents RETURN BOOLEAN
    -------------------------------------
    IS
	-- Check if parent data is correct

    BEGIN

	-- This procedure is only called in phase 2. The logic to check if
	-- a given parental foreign key exists is split into two parts for
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

	-- Start with checking the parent PAY_USER_TABLES


   	BEGIN

	    -- Check the tables in the delivery account

	    select distinct null
	    into   l_null_return
	    from   hr_s_user_tables
	    where  user_table_id = stu_rec.user_table_id;

	    crt_exc('Parent user table remains in delivery tables');

	    -- Parent row still in startup account

	    return FALSE;

        EXCEPTION WHEN NO_DATA_FOUND THEN

	    -- Probably transferred?

	    null;

   	END;


        BEGIN

	    select null
	    into   l_null_return
	    from   pay_user_tables
	    where  user_table_id = stu_rec.user_table_id;

	EXCEPTION WHEN NO_DATA_FOUND THEN

	    -- Parent not installed


	    crt_exc('Parent user table not installed');

	    return FALSE;

   	END;

   	IF stu_rec.formula_id is null THEN
	    -- No need to check parent formula
	    return TRUE;
   	END IF;

	-- Now check the parent FF_FORMULAS_F


	BEGIN

	    -- Check the tables in the delivery account

	    select distinct null
	    into   l_null_return
	    from   hr_s_formulas_f
	    where  formula_id = stu_rec.formula_id;

	    crt_exc('Parent formula remains in delivery tables');

	    -- Parent row still in startup account

	    return FALSE;

	EXCEPTION WHEN NO_DATA_FOUND THEN

	    -- Probably transferred?

	    null;

	END;


   	BEGIN
	    select null
	    into   l_null_return
	    from   ff_Formulas_f
	    where  formula_id = stu_rec.formula_id;
	    return TRUE;

        EXCEPTION WHEN NO_DATA_FOUND THEN

	    -- Parent not installed


	    crt_exc('Parent formula not installed');

	    return FALSE;

	END;

    END check_parents;

    PROCEDURE transfer_row
    ----------------------
    IS
	-- Check if a delivered row is needed and insert into the
	-- live tables if it is

        v_inst_update date;	-- Holds update details of installed row

	BEGIN


	    BEGIN

		-- Perform a check to see if the primary key has been created within
		-- a visible business group. Ie: the business group is for the same
		-- legislation as the delivered row, or the delivered row has a null
		-- legislation. If no rows are returned then the primary key has not
		-- already been created by a user.
	   --
	   -- #271139 - hitting a problem because the user column name is
	   -- not the true key on its own; it's only unique for the user table.
	   -- Add the user table id to the select criteria.
	   --
                select distinct null
                into   l_null_return
                from pay_user_columns a
                where a.user_table_id = stu_rec.user_table_id
                and    a.user_column_name = stu_rec.c_true_key
                and   a.business_group_id is not null
                and   exists (select null from per_business_groups b
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
	    -- G1746. Add the check for business_group_id is null, otherwise the
	    -- row may be wrongly rejected because it already exists for a
	    -- specific business group in another legislation. This, though
	    -- unlikely, is permissible. RMF 05.01.95.
	   --
	   -- #271139 - hitting a problem because the user column name is
	   -- not the true key on its own; it's only unique for the user table.
	   -- Add the user table id to the select criteria.
	   --
   	    BEGIN
        	select distinct null
        	into   l_null_return
        	from   pay_user_columns
        	where  user_column_name = stu_rec.c_true_key
	        and    user_table_id    = stu_rec.user_table_id
        	and    nvl(legislation_code,'X') <> nvl(stu_rec.c_leg_code,'X')
        	and   (legislation_code is null or stu_rec.c_leg_code is null )
		and    business_group_id is null;

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

	    IF NOT check_parents THEN
		return;
	    END IF;


   	    update pay_user_columns
   	    set formula_id = stu_rec.formula_id
   	    ,   last_update_date = stu_rec.last_update_date
   	    ,   last_updated_by = stu_rec.last_updated_by
   	    ,   last_update_login = stu_rec.last_update_login
   	    ,   created_by = stu_rec.created_by
   	    ,   creation_date = stu_rec.creation_date
   	    where  user_column_id = stu_rec.c_surrogate_key;

       IF NOT SQL%FOUND THEN

           BEGIN
	    insert into pay_user_columns
	    (user_column_id
	    ,business_group_id
	    ,legislation_code
	    ,user_table_id
	    ,formula_id
	    ,user_column_name
	    ,legislation_subgroup
	    ,last_update_date
	    ,last_updated_by
	    ,last_update_login
	    ,created_by
	    ,creation_date
	    )
	    values
	    (stu_rec.c_surrogate_key
	    ,stu_rec.business_group_id
	    ,stu_rec.c_leg_code
	    ,stu_rec.user_table_id
	    ,stu_rec.formula_id
	    ,stu_rec.c_true_key
	    ,stu_rec.c_leg_sgrp
	    ,stu_rec.last_update_date
	    ,stu_rec.last_updated_by
	    ,stu_rec.last_update_login
	    ,stu_rec.created_by
	    ,stu_rec.creation_date
	    );
                      EXCEPTION WHEN OTHERS THEN
                        hr_legislation.hrrunprc_trace_on;
                        hr_utility.trace('ins pay_user_columns');
                        hr_utility.trace('user_column_id  ' ||
                          to_char(stu_rec.c_surrogate_key));
                        hr_utility.trace('user_column_name  ' ||
                          stu_rec.c_true_key);
                        hr_utility.trace('user_table_id  ' ||
                          to_char(stu_rec.user_table_id));
                        hr_utility.trace(':lc: ' || ':' ||
                          stu_rec.c_leg_code || ':');
                        hr_legislation.hrrunprc_trace_off;
                        raise;
                      END;

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

    IF p_phase = 1 THEN
	check_next_sequence;
    END IF;

    FOR delivered IN stu LOOP

	-- Uses main cursor stu to implicity define a record


	savepoint new_user_column_name;

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

END install_ucolumns;

--*******************************************************************
-- OVERALL INSTALLATION PROCEDURE
--*******************************************************************

PROCEDURE install(p_phase number)
---------------------------------
IS
    -- Driver procedure to control the execution of all installation procedures.

BEGIN

    IF p_phase = 1 OR p_phase =2 THEN

hr_legislation.hrrunprc_trace_on;
hr_utility.trace('start install_ele_class: ' || to_char(p_phase));
hr_legislation.hrrunprc_trace_off;

	install_ele_class(p_phase); 	--install element classifications

hr_legislation.hrrunprc_trace_on;
hr_utility.trace('start install_elements: ' || to_char(p_phase));
hr_legislation.hrrunprc_trace_off;

	install_elements(p_phase); 	--install elements,sprs,frrs,inputs

hr_legislation.hrrunprc_trace_on;
hr_utility.trace('start install_ele_sets: ' || to_char(p_phase));
hr_legislation.hrrunprc_trace_off;

	install_ele_sets(p_phase); 	--install sets,type rules,class rules

hr_legislation.hrrunprc_trace_on;
hr_utility.trace('start install_utables: ' || to_char(p_phase));
hr_legislation.hrrunprc_trace_off;

	install_utables(p_phase); 	--install user tables

hr_legislation.hrrunprc_trace_on;
hr_utility.trace('start install_ucolumns: ' || to_char(p_phase));
hr_legislation.hrrunprc_trace_off;

	install_ucolumns(p_phase); 	--install user columns

    END IF;

END install;

END hr_legislation_elements;

/
