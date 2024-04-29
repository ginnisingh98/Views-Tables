--------------------------------------------------------
--  DDL for Package Body FF_DATA_DICT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."FF_DATA_DICT" AS
/* $Header: peffdict.pkb 120.9.12010000.5 2009/03/12 16:24:47 divicker ship $ */
--****************************************************************************
-- INSTALLATION PROCEDURE FOR : FF_CONTEXTS_F
--****************************************************************************

procedure disable_ffuebru_trig is
  statem varchar2(256);
  sql_cur number;
  ignore number;
begin
  statem := 'alter trigger ff_user_entities_bru disable';
  sql_cur := dbms_sql.open_cursor;
  dbms_sql.parse(sql_cur,
                 statem,
                 dbms_sql.v7);
  ignore := dbms_sql.execute(sql_cur);
  dbms_sql.close_cursor(sql_cur);
end;

procedure enable_ffuebru_trig is
  statem varchar2(256);
  sql_cur number;
  ignore number;
begin
  statem := 'alter trigger ff_user_entities_bru enable';
  sql_cur := dbms_sql.open_cursor;
  dbms_sql.parse(sql_cur,
                 statem,
                 dbms_sql.v7);
  ignore := dbms_sql.execute(sql_cur);
  dbms_sql.close_cursor(sql_cur);
end;

procedure dis_cont_calc_trigger is
  statem varchar2(256);
  sql_cur number;
  ignore number;
begin
  statem := 'alter trigger FFGLOBALSF_9501D_DYT disable';
  sql_cur := dbms_sql.open_cursor;
  dbms_sql.parse(sql_cur,
                 statem,
                 dbms_sql.v7);
  ignore := dbms_sql.execute(sql_cur);
  dbms_sql.close_cursor(sql_cur);
  statem := 'alter trigger FFGLOBALSF_9502I_DYT disable';
  sql_cur := dbms_sql.open_cursor;
  dbms_sql.parse(sql_cur,
                 statem,
                 dbms_sql.v7);
  ignore := dbms_sql.execute(sql_cur);
  dbms_sql.close_cursor(sql_cur);
  statem := 'alter trigger FFGLOBALSF_9503U_DYT disable';
  sql_cur := dbms_sql.open_cursor;
  dbms_sql.parse(sql_cur,
                 statem,
                 dbms_sql.v7);
  ignore := dbms_sql.execute(sql_cur);
  dbms_sql.close_cursor(sql_cur);
end;

procedure ena_cont_calc_trigger is
  statem varchar2(256);
  sql_cur number;
  ignore number;
begin
  statem := 'alter trigger FFGLOBALSF_9501D_DYT enable';
  sql_cur := dbms_sql.open_cursor;
  dbms_sql.parse(sql_cur,
                 statem,
                 dbms_sql.v7);
  ignore := dbms_sql.execute(sql_cur);
  dbms_sql.close_cursor(sql_cur);
  statem := 'alter trigger FFGLOBALSF_9502I_DYT enable';
  sql_cur := dbms_sql.open_cursor;
  dbms_sql.parse(sql_cur,
                 statem,
                 dbms_sql.v7);
  ignore := dbms_sql.execute(sql_cur);
  dbms_sql.close_cursor(sql_cur);
  statem := 'alter trigger FFGLOBALSF_9503U_DYT enable';
  sql_cur := dbms_sql.open_cursor;
  dbms_sql.parse(sql_cur,
                 statem,
                 dbms_sql.v7);
  ignore := dbms_sql.execute(sql_cur);
  dbms_sql.close_cursor(sql_cur);
end;


PROCEDURE install_ffc (p_phase IN number)
-----------------------------------------
IS
    -- Install delivered formula contexts into the live tables. This delivery
    -- procedure maintains referential integrity with all children of formula
    -- contetxs. It must be executed before any other formula dictionary
    -- routine.

    l_null_return varchar2(1); 		-- for 'select null' statements
    l_new_surrogate_key number(15);     -- new surrogate key for delivery row

    CURSOR stu  			-- selects all rows from startup entity
    IS
        select context_name c_true_key
	,      rowid
	,      context_level
	,      data_type
	,      context_id c_surrogate_key
	from   hr_s_contexts;


    stu_rec stu%ROWTYPE;		-- Record for above SELECT

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

	rollback to new_context_name;

	hr_legislation.insert_hr_stu_exceptions('ff_contexts'
        ,      stu_rec.c_surrogate_key
        ,      exception_type
        ,      stu_rec.c_true_key);


    END crt_exc;

    PROCEDURE check_next_sequence
    -----------------------------
    IS

	v_sequence_number number(9);
	v_min_delivered number(9);
	v_max_delivered number(9);

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


	BEGIN	--check that the installde routes will not conflict
		--with the delivered values


	    select distinct null
	    into   l_null_return
	    from   ff_contexts a
	    where  exists
		(select null
		 from   hr_s_contexts b
		 where  a.context_id = b.context_id
		);

	    --conflict may exist
	    --update all context_id's to remove conflict

	    update /*+NO_INDEX*/ hr_s_contexts
	    set    context_id = context_id - 50000000;

	    update /*+NO_INDEX*/ hr_s_route_context_usages
            set    context_id = context_id - 50000000;

	    update /*+NO_INDEX*/ hr_s_ftype_context_usages
            set    context_id = context_id - 50000000;

	    update /*+NO_INDEX*/ hr_s_function_context_usages
            set    context_id = context_id - 50000000;

	    update hr_s_application_ownerships
	    set    key_value = key_value - 50000000
	    where  key_name = 'CONTEXT_ID';

	EXCEPTION WHEN NO_DATA_FOUND THEN NULL;

	END; --check of context_id



	select min(context_id) - (count(*) *3)
	,      max(context_id) + (count(*) *3)
	into   v_min_delivered
	,      v_max_delivered
	from   hr_s_contexts;

	select ff_contexts_s.nextval
	into   v_sequence_number
	from   dual;

        IF v_sequence_number
	  BETWEEN v_min_delivered AND v_max_delivered THEN

            hr_legislation.munge_sequence('FF_CONTEXTS_S',
                                          v_sequence_number,
                                          v_max_delivered);

        END IF;

    END check_next_sequence;

    PROCEDURE update_uid
    --------------------
    IS
	-- Subprogram to update surrogate UID and all occurrences in child rows

        r_count NUMBER;

    BEGIN


        BEGIN

	    select distinct context_id
            into   l_new_surrogate_key
	    from   ff_contexts
	    where  context_name = stu_rec.c_true_key;

        EXCEPTION WHEN NO_DATA_FOUND THEN


	    select ff_contexts_s.nextval
	    into   l_new_surrogate_key
	    from   dual;

        END;

	-- Update all child entities

        update hr_s_contexts
        set    context_id = l_new_surrogate_key
        where  context_id = stu_rec.c_surrogate_key;

        update hr_s_application_ownerships
        set    key_value = to_char(l_new_surrogate_key)
        where  key_value = to_char(stu_rec.c_surrogate_key)
        and    key_name = 'CONTEXT_ID';

        update hr_s_ftype_context_usages
        set    context_id = l_new_surrogate_key
        where  context_id = stu_rec.c_surrogate_key;

        update hr_s_route_context_usages
        set    context_id = l_new_surrogate_key
        where  context_id = stu_rec.c_surrogate_key;

        update hr_s_function_context_usages
        set    context_id = l_new_surrogate_key
        where  context_id = stu_rec.c_surrogate_key;

    END update_uid;

    PROCEDURE remove
    ----------------
    IS
        -- Remove a row from the startup/delivered tables

    BEGIN

        delete from hr_s_contexts
        where  rowid = stu_rec.rowid;


        IF p_phase = 2 THEN
	    l_new_surrogate_key := stu_rec.c_surrogate_key;
        END IF;

        delete from hr_stu_exceptions
        where  surrogate_id = stu_rec.c_surrogate_key
        and    table_name = 'FF_CONTEXTS';

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

        IF p_phase <> 1 THEN	--only perform in phase 1
	    return TRUE;
        END IF;

        select null --if exception raised then this row is not needed
        into   l_null_return
        from   dual
        where  exists (
               select null
	       from   hr_s_application_ownerships a
	       ,      fnd_product_installations b
	       ,      fnd_application c
	       where  a.key_name = 'CONTEXT_ID'
	       and    a.key_value = l_new_surrogate_key
	       and    a.product_name = c.application_short_name
	       and    c.application_id = b.application_id
	       and    ((b.status = 'I' and c.application_short_name <> 'PQP')
	              or
                      (b.status in ('I', 'S') and c.application_short_name = 'PQP')));

        return TRUE;	--indicates row is required

    EXCEPTION WHEN NO_DATA_FOUND THEN

	-- Row not needed for any installed product

	remove;

	return FALSE;	--indicates row not needed

    END valid_ownership;

    PROCEDURE transfer_row
    ----------------------
    IS
	-- Check if a delivered row is needed and insert into the
	-- live tables if it is.

    BEGIN

	-- A simplistic installation. If the context name already exists
	-- in the live tables then no exception is raised and the row is
	-- delete from the delivery tables. If the context name does not
	-- exist then an exception is raised. The actual insert only occurs
	-- in phase 2 and after the insert has been performed the delivered
	-- row must be deleted.

        select null
        into   l_null_return
        from   ff_contexts
        where  context_name = stu_rec.c_true_key;


	-- Row not required so delete

	remove;

    EXCEPTION WHEN NO_DATA_FOUND THEN

	-- Row not present in installed tables


	-- No inserts in phase 1

	IF p_phase = 1 THEN
	    return;
	END IF;

        BEGIN
	insert into ff_contexts
	(context_id
	,context_level
	,context_name
	,data_type
	)
	values
	(stu_rec.c_surrogate_key
	,stu_rec.context_level
	,stu_rec.c_true_key
	,stu_rec.data_type);
                      EXCEPTION WHEN OTHERS THEN
                        hr_legislation.hrrunprc_trace_on;
                        hr_utility.trace('ins ff_contexts');
                        hr_utility.trace('context_id  ' ||
                          to_char(stu_rec.c_surrogate_key));
                        hr_utility.trace('context_name  ' ||
                          stu_rec.c_true_key);
                        hr_utility.trace('context_level  ' ||
                          to_char(stu_rec.context_level));
                        hr_utility.trace('datatype  ' ||
                          stu_rec.data_type);
                        hr_legislation.hrrunprc_trace_off;
                        raise;
                      END;


	-- Delete delivered row now it has been installed

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


        savepoint new_context_name;

        -- Make all cursor columns available to all procedures

        stu_rec := delivered;

	IF p_phase = 1 THEN update_uid; END IF;

        IF valid_ownership THEN

            -- Test the row onerships for the current row


	    transfer_row;

       END IF;

    END LOOP;

END install_ffc;

--****************************************************************************
-- INSTALLATION PROCEDURE FOR : FF_FORMULA_TYPES_S
--****************************************************************************

PROCEDURE install_fft (p_phase IN number)
-----------------------------------------
IS
    -- Install startup formula types into a live account. The procedure compares
    -- delivered types to live types. If different the delivered types will be
    -- installed.

    l_null_return varchar2(1); 		-- For 'select null' statements
    l_new_surrogate_key number(15); 	-- New surrogate key for delivery row
    l_old_surrogate_key number(15);
    l_number_of_ftcu number;

    CURSOR stu				-- Selects all rows from startup entity
    IS
	select formula_type_name c_true_key
	,      rowid
	,      formula_type_id c_surrogate_key
	,      type_description
	,      last_update_date
	,      last_updated_by
	,      last_update_login
	,      created_by
	,      creation_date
	from   hr_s_formula_types;

    CURSOR ftcu (p_ftype_id number)	-- Cursor for install context usages
    IS
	select *
	from   hr_s_ftype_context_usages
	where  formula_type_id = p_ftype_id;

    stu_rec stu%ROWTYPE;		-- Record definition for cursor select


    PROCEDURE crt_exc (exception_type IN varchar2)
    ----------------------------------------------
    IS
	-- Reports any exceptions during the delivery of startup data to
	-- FF_FORMULA_TYPES_S

    BEGIN

	-- When the installation procedures encounter an error that cannot
	-- be handled, an exception is raised and all work is rolled back
	-- to the last savepoint. The installation process then continues
	-- with the next primary key to install. The same exception will
	-- not be raised more than once.


	rollback to new_formula_type_name;

	hr_legislation.insert_hr_stu_exceptions('ff_formula_types'
        ,      stu_rec.c_surrogate_key
        ,      exception_type
        ,      stu_rec.c_true_key);


    END crt_exc;

    PROCEDURE check_next_sequence
    -----------------------------
    IS
        CURSOR c_fft1 IS
        select distinct null
        from   ff_formula_types a
        where  exists
            (select null
             from   hr_s_formula_types b
             where  a.formula_type_id = b.formula_type_id
            );
        --
        v_sequence_number number(9);
        v_min_delivered number(9);
        v_max_delivered number(9);

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
	-- This procedure will check three sequences

    BEGIN


	BEGIN	--check that the installde routes will not conflict
		--with the delivered values

            --
            open c_fft1;
            fetch c_fft1 into l_null_return;
                IF c_fft1%NOTFOUND OR c_fft1%NOTFOUND IS NULL THEN
                        RAISE NO_DATA_FOUND;
                END IF;
            close c_fft1;
            --
	    --conflict may exist
	    --update all formula_type_id's to remove conflict

	    update hr_s_formula_types
	    set    formula_type_id = formula_type_id - 50000000;

	    update hr_s_formulas_f
            set    formula_type_id = formula_type_id - 50000000;

	    update hr_s_ftype_context_usages
            set    formula_type_id = formula_type_id - 50000000;

	    update hr_s_qp_reports
            set    formula_type_id = formula_type_id - 50000000;

	    update hr_s_application_ownerships
	    set    key_value = key_value - 50000000
	    where  key_name = 'FORMULA_TYPE_ID';

	EXCEPTION WHEN NO_DATA_FOUND THEN NULL;

	END; --check of formula_type_id



        select min(formula_type_id) - (count(*) *3)
        ,      max(formula_type_id) + (count(*) *3)
        into   v_min_delivered
        ,      v_max_delivered
        from   hr_s_formula_types;

        select ff_formula_types_s.nextval
        into   v_sequence_number
        from   dual;

        IF v_sequence_number
          BETWEEN v_min_delivered AND v_max_delivered THEN

            hr_legislation.munge_sequence('FF_FORMULA_TYPES_S',
                                          v_sequence_number,
                                          v_max_delivered);

        END IF;

    END check_next_sequence;

    PROCEDURE update_uid
    --------------------
    IS
	-- Subprogram to update surrogate UID and all occurrences in child rows

    BEGIN


        BEGIN

            select distinct formula_type_id
	    into   l_new_surrogate_key
	    from   ff_formula_types
	    where  formula_type_name = stu_rec.c_true_key;

        EXCEPTION WHEN NO_DATA_FOUND THEN

	   select ff_formula_types_s.nextval
	   into   l_new_surrogate_key
	   from   dual;

           WHEN TOO_MANY_ROWS THEN
           hr_legislation.hrrunprc_trace_on;
           hr_utility.trace('multiple ftype ' || stu_rec.c_true_key);
           hr_legislation.hrrunprc_trace_off;
           raise;
       END;

       -- Update all child entities

       update hr_s_formula_types
       set    formula_type_id = l_new_surrogate_key
       where  formula_type_id = stu_rec.c_surrogate_key;

       update hr_s_application_ownerships
       set    key_value = to_char(l_new_surrogate_key)
       where  key_value = to_char(stu_rec.c_surrogate_key)
       and    key_name = 'FORMULA_TYPE_ID';

       update hr_s_formulas_f
       set    formula_type_id = l_new_surrogate_key
       where  formula_type_id = stu_rec.c_surrogate_key;

       update hr_s_ftype_context_usages
       set    formula_type_id = l_new_surrogate_key
       where  formula_type_id = stu_rec.c_surrogate_key;

       update hr_s_qp_reports
       set    formula_type_id = l_new_surrogate_key
       where  formula_type_id = stu_rec.c_surrogate_key;

    END update_uid;

    PROCEDURE remove
    ----------------
    IS
        -- Remove a row from the startup/delivered tables

    BEGIN

        delete from hr_s_formula_types
        where  rowid = stu_rec.rowid;

        delete from hr_s_ftype_context_usages
        where  formula_type_id = l_new_surrogate_key;

    END remove;

    FUNCTION valid_ownership RETURN BOOLEAN
    ---------------------------------------
    IS
    --
    CURSOR c_fft2 IS
        select null --if exception raised then this row is not needed
        from   dual
        where  exists (
               select null
               from   hr_s_application_ownerships a
               ,      fnd_product_installations b
               ,      fnd_application c
               where  a.key_name = 'FORMULA_TYPE_ID'
               and    a.key_value = l_new_surrogate_key
               and    a.product_name = c.application_short_name
               and    c.application_id = b.application_id
               and    ((b.status = 'I' and c.application_short_name <> 'PQP')
                       or
                       (b.status in ('I', 'S') and c.application_short_name = 'PQP')));
    --
    -- If for a given formula_type_id, there is a difference of any sort between
    -- what is on the live table to what is being delivered then we must
    -- invalidate and recreate the usages which will invalidate potentially
    -- many formulae. This if there is no mismatch between delivered and
    -- live data then we will remove the formula type from the hr_s tables
    -- so eleiminating the need for formula invalidation.
    -- new version. Only need for live to not be a superset of HR_S
    CURSOR c_fft3 IS
      select 1
      from   dual
      where  exists
        (select hfcu.context_id
         from   hr_s_ftype_context_usages hfcu
         where  hfcu.formula_type_id = l_new_surrogate_key
         MINUS
         select fcu.context_id
         from   ff_ftype_context_usages fcu
         where  fcu.formula_type_id = l_new_surrogate_key);
    --
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

     IF p_phase <> 1 THEN	-- Only perform in phase 1
       return TRUE;
     END IF;
     --
     BEGIN
        open c_fft2;
        fetch c_fft2 into l_null_return;
           IF c_fft2%NOTFOUND THEN
           close c_fft2;
           RAISE NO_DATA_FOUND;
        END IF;
        close c_fft2;
        --
     EXCEPTION WHEN NO_DATA_FOUND THEN

	-- Row not needed for any installed product
	remove;
	return FALSE;	-- Indicates row not needed

     END;

     BEGIN

      -- Now check to see if we have to reinstall this row by checking
      -- if the ftype usages all match. If any don't then we must reinstall
      -- the formula_type and its usages which will mean potentially having
      -- to recompile many formulae
      IF p_phase <> 1 THEN
        return TRUE;
      END IF;

      -- check if any diffs between ftcus in delivered and live
      -- this cursor doesnt cater when there are no ftcus so check for
      -- this first

      select count(*)
      into   l_number_of_ftcu
      from   hr_s_ftype_context_usages
      where  formula_type_id = l_new_surrogate_key;

      if l_number_of_ftcu <> 0 then
        open c_fft3;
        fetch c_fft3 into l_null_return;
        IF c_fft3%NOTFOUND THEN
           close c_fft3;
           remove; -- everything between live and delivered matches
        END IF;
        close c_fft3;
      end if;
      --
    EXCEPTION WHEN OTHERS THEN
      null;
    END;

    return TRUE;

    END valid_ownership;

    PROCEDURE transfer_row
    ----------------------
    IS

    CURSOR c_fft5 (usages_context_id number) IS
    select null
    from   ff_contexts
    where  context_id = usages_context_id;
    --

    BEGIN

        update ff_formula_types
        set    type_description = stu_rec.type_description
        ,      last_update_date = stu_rec.last_update_date
        ,      last_updated_by = stu_rec.last_updated_by
        ,      last_update_login = stu_rec.last_update_login
        ,      created_by = stu_rec.created_by
        ,      creation_date = stu_rec.creation_date
        where  formula_type_name = stu_rec.c_true_key;

        IF SQL%NOTFOUND THEN

            -- This formula type does not exist

           BEGIN
	    insert into ff_formula_types
	    (formula_type_name
	    ,formula_type_id
            ,type_description
	    ,last_update_date
	    ,last_updated_by
	    ,last_update_login
	    ,created_by
	    ,creation_date
	    )
	    values
	    (stu_rec.c_true_key
	    ,stu_rec.c_surrogate_key
	    ,stu_rec.type_description
	    ,stu_rec.last_update_date
	    ,stu_rec.last_updated_by
	    ,stu_rec.last_update_login
	    ,stu_rec.created_by
	    ,stu_rec.creation_date
 	    );
                      EXCEPTION WHEN OTHERS THEN
                        hr_legislation.hrrunprc_trace_on;
                        hr_utility.trace('ins ff_formula_types');
                        hr_utility.trace('formula_type_id  ' ||
                          to_char(stu_rec.c_surrogate_key));
                        hr_utility.trace('formula_type_name  ' ||
                          stu_rec.c_true_key);
                        hr_legislation.hrrunprc_trace_off;
                        raise;
                      END;


	END IF;

   	-- Now loop for all context usages to install. First a check must be made
	-- to see if the context referenced in this row is installed in the live
	-- tables. If not then the transfer for this whole formula type must not
	-- proceed. The actual insert statement is within a phase value check
	-- to allow any errors with parent contexts to be highlighted in pahse 1.
	-- the last final delete will only occur in phase 2, since only in phase 2
	-- will the row have been transferred.
	-- All the live context usages must be deleted first

        FOR usages IN ftcu(l_new_surrogate_key) LOOP

	    BEGIN

                delete ff_compiled_info_f f
                where  f.formula_id in (
                  select distinct a.formula_id
                  from   ff_formulas_f a,
                         ff_fdi_usages_f b,
                         ff_contexts c
                  where  a.formula_type_id = stu_rec.c_surrogate_key
                  and    a.formula_id = b.formula_id
                  and    b.item_name = upper(c.context_name)
                  and    c.context_id = usages.context_id
                  and    b.usage = 'U');

                delete ff_fdi_usages_f f
                where  f.formula_id in (
                  select distinct a.formula_id
                  from   ff_formulas_f a,
                         ff_fdi_usages_f b,
                         ff_contexts c
                  where  a.formula_type_id = stu_rec.c_surrogate_key
                  and    a.formula_id = b.formula_id
                  and    b.item_name = upper(c.context_name)
                  and    c.context_id = usages.context_id
                  and    b.usage = 'U');

                delete from ff_ftype_context_usages
                where  formula_type_id = stu_rec.c_surrogate_key
                and context_id=usages.context_id;

                open c_fft5 (usages.context_id);
                fetch c_fft5 into l_null_return;
                IF c_fft5%NOTFOUND OR c_fft5%NOTFOUND IS NULL THEN
                  RAISE NO_DATA_FOUND;
                END IF;
                close c_fft5;

                insert into ff_ftype_context_usages
                (formula_type_id
                ,context_id)
                values
                (usages.formula_type_id
                ,usages.context_id);

            EXCEPTION WHEN NO_DATA_FOUND THEN

	        -- Parent context not present


	        crt_exc('Context referenced by child usage is not present');

	        -- Get next formula type to install

                return;

                     WHEN OTHERS THEN
                        hr_legislation.hrrunprc_trace_on;
                        hr_utility.trace('ins ff_ftype_context_usages');
                        hr_utility.trace('formula_type_id  ' ||
                          to_char(usages.formula_type_id));
                        hr_utility.trace('context_id  ' ||
                          to_char(usages.context_id));
                        hr_utility.trace('formula_type_name  ' ||
                          stu_rec.c_true_key);
                        hr_legislation.hrrunprc_trace_off;
                        raise;
	    END;

	END LOOP usages;


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
    -- and the next row is returned. Ownership details are checked and
    -- if the row is required then the surrogate id is updated and the
    -- main transfer logic is called.

    IF p_phase = 1 THEN
	check_next_sequence;
    END IF;

    FOR delivered IN stu LOOP

	-- Uses main cursor stu to impilicity define a record


        savepoint new_formula_type_name;

	-- Make all cursor columns available to all procedures

        stu_rec := delivered;

        IF p_phase = 1 THEN
            update_uid;
        END IF;

        IF p_phase = 2 THEN
	    l_new_surrogate_key := stu_rec.c_surrogate_key;
	END IF;

        IF valid_ownership THEN

	    -- Test the row onerships for the current row


 	    if p_phase = 2 THEN transfer_row; end if;

	END IF;

    END LOOP;

END install_fft;

--****************************************************************************
-- INSTALLATION PROCEDURE FOR : FF_FORMULAS_F
--****************************************************************************

PROCEDURE install_formulas (p_phase IN NUMBER)
----------------------------------------------
IS
	-- Install procedure to transfer startup delivered ff_formulass into a
	-- live account, and remove the then delivered rows from the delivery
	-- account.
	-- This procedure is called in two phase. Only in the second phase are
	-- details transferred into live tables. The parameter p_phase holds
	-- the phase number.

	row_in_error exception;
        v_formula_text long;
        vlive_formula_text long;
	l_current_proc varchar2(80) := 'hr_legislation.install_formulas';
	l_new_formula_id        number(15);
	l_null_return           varchar2(1);

    CURSOR c_distinct
    IS
	-- select statement used for the main loop. Each row return is used
	-- as the commit unit, since each true primary key may have many date
	-- effective rows for it.
	-- The selected primary key is then passed into the second driving
	-- cursor statement as a parameter, and all date effective rows for
	-- this primary key are then selected.

       select max(effective_end_date) c_end
       ,      formula_id c_surrogate_key
       ,      formula_type_id
       ,      formula_name c_true_key
       ,      legislation_code
       from   hr_s_formulas_f
       group  by formula_id
       ,         formula_type_id
       ,         formula_name
       ,         legislation_code;

    CURSOR c_each_row (pc_formula_id varchar2)
    IS
	-- Selects all date effective rows for the current true primary key
	-- The primary key has already been selected using the above cursor.
	-- This cursor accepts the primary key as a parameter and selects all
	-- date effective rows for it.

	select *
        from   hr_s_formulas_f
        where  formula_id = pc_formula_id;

    -- These records are defined here so all sub procedures may use the
    -- values selected. This saves the need for all sub procedures to have
    -- a myriad of parameters passed. The cursors are controlled in FOR
    -- cursor LOOPs. When a row is returned the whole record is copied into
    -- these record definitions.

    r_distinct c_distinct%ROWTYPE;
    r_each_row c_each_row%ROWTYPE;
    l_dummy varchar2(1);

    PROCEDURE crt_exc (exception_type IN varchar2)
    ----------------------------------------------
    IS
	-- Reports any exceptions during the delivery of startup data to
	-- FF_FORMULAS_F
    BEGIN
	-- When the installation procedures encounter an error that cannot
	-- be handled, an exception is raised and all work is rolled back
	-- to the last savepoint. The installation process then continues
	-- with the next primary key to install. The same exception will
	-- not be raised more than once.

	rollback to new_formula_name;

	hr_legislation.insert_hr_stu_exceptions('ff_formulas_f'
        ,      r_distinct.c_surrogate_key
        ,      exception_type
        ,      r_distinct.c_true_key);


    END crt_exc;

    PROCEDURE remove (v_id IN number)
    ---------------------------------
    IS
	-- Subprogram to delete a row from the delivery tables, and all child
	-- application ownership rows

    BEGIN


	delete from hr_s_formulas_f
	where  formula_id = v_id;

    END remove;

    PROCEDURE check_next_sequence
    -----------------------------
    IS

	v_sequence_number number(9);
	v_min_delivered number(9);
	v_max_delivered number(9);

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
	    from   ff_formulas_f a
	    where  exists
		(select null
		 from   hr_s_formulas_f b
		 where  a.formula_id = b.formula_id
		);

	    --conflict may exist
	    --update all formula_id's to remove conflict

	    update /*+NO_INDEX*/ hr_s_formulas_f
	    set    formula_id = formula_id - 50000000;

	    update /*+NO_INDEX*/ hr_s_qp_reports
            set    formula_id = formula_id - 50000000;

	    update /*+NO_INDEX*/ hr_s_element_types_f
            set    formula_id = formula_id - 50000000;

            update /*+NO_INDEX*/ hr_s_element_types_f
            set    iterative_formula_id = iterative_formula_id - 50000000;

            update /*+NO_INDEX*/ hr_s_element_types_f
            set    proration_formula_id = proration_formula_id - 50000000;

            update /*+NO_INDEX*/ hr_s_input_values_f
            set    formula_id = formula_id - 50000000;

            update /*+NO_INDEX*/ hr_s_status_processing_rules_f
            set    formula_id = formula_id - 50000000;

            update /*+NO_INDEX*/ hr_s_user_columns
            set    formula_id = formula_id - 50000000;

	    update hr_s_application_ownerships
	    set    key_value = key_value - 50000000
	    where  key_name = 'FORMULA_ID';

	    update /*+NO_INDEX*/ hr_s_magnetic_records
	    set    formula_id = formula_id - 50000000;

            update hr_s_legislation_rules
            set    rule_mode =
		to_char(fnd_number.canonical_to_number(rule_mode) - 50000000)
            where  rule_type = 'LEGISLATION_CHECK_FORMULA';

	EXCEPTION WHEN NO_DATA_FOUND THEN NULL;

	END; --check of formula_id


        select min(formula_id) - (count(*) *3)
        ,      max(formula_id) + (count(*) *3)
        into   v_min_delivered
        ,      v_max_delivered
        from   hr_s_formulas_f;

        select ff_formulas_s.nextval
        into   v_sequence_number
        from   dual;

        IF v_sequence_number
	  BETWEEN v_min_delivered AND v_max_delivered THEN

            hr_legislation.munge_sequence('FF_FORMULAS_S',
                                          v_sequence_number,
                                          v_max_delivered);
        END IF;

    END check_next_sequence;

    PROCEDURE update_uid
    --------------------
    IS
	-- Subprogram to update surrogate UID and all occurrences in child rows

	-- See if this primary key is already installed. If so then the sorrogate
	-- key of the delivered row must be updated to the value in the installed
	-- tables. If the row is not already present then select the next value
	-- from the sequence. In either case all rows for this primary key must
	-- be updated, as must all child references to the old surrogate uid.

    BEGIN


	BEGIN

	    select distinct formula_id
	    into   l_new_formula_id
	    from   ff_formulas_f
	    where  formula_name = r_distinct.c_true_key
	    and    formula_type_id = r_distinct.formula_type_id
	    and    business_Group_id is null
            and    ((legislation_code is NULL and r_distinct.legislation_code is NULL)
                    or (r_distinct.legislation_code=legislation_code));


	EXCEPTION WHEN NO_DATA_FOUND THEN


	    select ff_formulas_s.nextval
	    into   l_new_formula_id
	    from   dual;

             WHEN TOO_MANY_ROWS THEN

                        hr_legislation.hrrunprc_trace_on;
                        hr_utility.trace('sel ff_formulas_f TMR');
                        hr_utility.trace('formula_name ' ||
                          r_distinct.c_true_key);
                        hr_utility.trace('formula_type_id  ' ||
                          to_char(r_distinct.formula_type_id));
                        hr_utility.trace(':lc: ' || ':' ||
                          r_distinct.legislation_code || ':');
                        hr_legislation.hrrunprc_trace_off;
                        raise;
	END;

	update hr_s_formulas_f
        set    formula_id = l_new_formula_id
        where  formula_id = r_distinct.c_surrogate_key;

        update hr_s_application_ownerships
        set    key_value = to_char(l_new_formula_id)
        where  key_value = to_char(r_distinct.c_surrogate_key)
        and    key_name = 'FORMULA_ID';

        update hr_s_qp_reports
        set    formula_id = l_new_formula_id
        where  formula_id = r_distinct.c_surrogate_key;

        update hr_s_element_Types_f
        set    formula_id = l_new_formula_id
        where  formula_id = r_distinct.c_surrogate_key;

        update hr_s_element_Types_f
        set    iterative_formula_id = l_new_formula_id
        where  iterative_formula_id = r_distinct.c_surrogate_key;

        update hr_s_element_Types_f
        set    proration_formula_id = l_new_formula_id
        where  proration_formula_id = r_distinct.c_surrogate_key;

        update hr_s_input_values_f
        set    formula_id = l_new_formula_id
        where  formula_id = r_distinct.c_surrogate_key;

        update hr_s_status_processing_rules_f
        set    formula_id = l_new_formula_id
        where  formula_id = r_distinct.c_surrogate_key;

        update hr_s_user_columns
        set    formula_id = l_new_formula_id
        where  formula_id = r_distinct.c_surrogate_key;

	update hr_s_magnetic_records
        set    formula_id = l_new_formula_id
        where  formula_id = r_distinct.c_surrogate_key;

	update hr_s_legislation_rules
	set    rule_mode = to_char(l_new_formula_id)
        where  rule_mode = to_char(r_distinct.c_surrogate_key)
	and    rule_type = 'LEGISLATION_CHECK_FORMULA';


    END update_uid;

    PROCEDURE validity_checks
    -------------------------
    IS
	-- After all rows for a primary key have been delivered, entity specific
	-- checks must be performed to check to validity of the data that has
	-- just been installed.

    BEGIN


        IF p_phase =2 THEN
	    l_new_formula_id := r_distinct.c_surrogate_key;
	END IF;

	-- Start child check 1

        BEGIN

	    -- Check input values first

	    select distinct null
	    into   l_null_return
	    from   pay_input_values_f
	    where  effective_end_date > r_distinct.c_end
	    and    formula_id = l_new_formula_id
	    and    business_group_id is not null;


	    crt_exc('User created input value exists after the new end date');

            return;

	EXCEPTION WHEN NO_DATA_FOUND THEN

	    null;

	END;

        BEGIN

	    -- Check status processing rules now

	    select distinct null
	    into   l_null_return
	    from   pay_status_processing_rules_f
            where  effective_end_date > r_distinct.c_end
            and    formula_id = l_new_formula_id
            and    business_group_id is not null;


            crt_exc('User created process rule exists after the new end date');

	    return;

        EXCEPTION WHEN NO_DATA_FOUND THEN

	    null;

        END;

    END validity_checks;

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

	    select distinct null
	    into   l_NULL_RETURN
	    from   hr_s_formula_types
	    where  formula_type_id = r_each_row.formula_type_id;


	    crt_exc('Parent formula type still exists in delivery tables');

	    -- Parent still exists, ignore this row

	    return FALSE;

	EXCEPTION WHEN NO_DATA_FOUND THEN

	    null;

        END;

	BEGIN

	    -- Check that the parent exists in the live tables


	    select null
	    into   l_null_return
	    from   ff_formula_types
	    where  formula_type_id = r_each_row.formula_type_id;

        EXCEPTION WHEN NO_DATA_FOUND THEN


	    crt_exc('Parent formula type does not exist in live tables');

	    return FALSE;

        END;

	-- Logic drops through to this statement

	return TRUE;

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
	    -- Perform a check to see if the primary key has been creeated within
	    -- a visible business group. Ie: the business group is for the same
	    -- legislation as the delivered row, or the delivered row has a null
	    -- legislation. If no rows are returned then the primary key has not
	    -- already been created by a user.

	    -- The formula must be created for the same formula type.


            select distinct null
            into   l_null_return
            from ff_formulas_f a
            where a.formula_name = r_distinct.c_true_key
            and   a.formula_type_id = r_distinct.formula_type_id
            and   a.business_group_id is not null
            and   exists (select null from per_business_groups b
              where b.business_group_id = a.business_group_id
              and b.legislation_code = nvl(r_distinct.legislation_code,b.legislation_code));


            crt_exc('Row already created in a business group');

	    -- Indicates this row is not to be transferred

	    return FALSE;

	EXCEPTION WHEN NO_DATA_FOUND THEN

	    null;

        END;

	-- Now perform a check to see if this primary key has been installed
	-- with a legislation code that would make it visible at the same time
	-- as this row. Ie: if any legislation code is null within the set of
	-- returned rows, then the transfer may not go ahead. If no rows are
	-- returned then the delivered row is fine.

	-- The formula must be created within the same formula type.

        BEGIN


	    select distinct null
	    into   l_null_return
	    from   ff_formulas_f
	    where  formula_name = r_distinct.c_true_key
	    and    formula_type_id = r_distinct.formula_type_id
	    and    legislation_code <> r_distinct.legislation_code
	    and    (legislation_code is null or
		   r_distinct.legislation_code is null );


            crt_exc('Row already created for a visible legislation');

	    --indicates this row is not to be transferred

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


        select null --if exception raised then this row is not needed
        into   l_null_return
        from   dual
        where exists (select null
         from   hr_s_application_ownerships a
        ,      fnd_product_installations b
        ,      fnd_application c
        where  a.key_name = 'FORMULA_ID'
        and    a.key_value = r_distinct.c_surrogate_key
        and    a.product_name = c.application_short_name
        and    c.application_id = b.application_id
        and    ((b.status = 'I' and c.application_short_name <> 'PQP')
                or
                (b.status in ('I', 'S') and c.application_short_name = 'PQP')));


	-- Indicates row is required

	return TRUE;

    EXCEPTION WHEN NO_DATA_FOUND THEN

	-- Row not needed for any installed product


	remove(r_distinct.c_surrogate_key);

	-- Indicate row not needed

	return FALSE;

    END valid_ownership;

function formula_changed(form_id in number) return boolean is
cursor all_rows(f_id in number) is
  select effective_start_date
  from   hr_s_formulas_f
  where  formula_id = f_id;
begin
                    -- First check on  existence

                    BEGIN
                      select null
                      into  l_dummy
                      from  ff_formulas_f
                      where formula_id = form_id;
                    EXCEPTION when others then
                      return TRUE;
                    END;

                    -- Check long column for all
                    for r_all_rows in all_rows(form_id)
                    loop
                     BEGIN
                      select formula_text
                      into   v_formula_text
                      from   hr_s_formulas_f
                      where  formula_id = form_id
                      and    effective_start_date = r_all_rows.effective_start_date;

                      select formula_text
                      into   vlive_formula_text
                      from   ff_formulas_f
                      where  formula_id = form_id
                      and    effective_start_date = r_all_rows.effective_start_date;

                      -- First check if non stub formula diff from live
                      if (v_formula_text is not null and
                          vlive_formula_text is not null and
                          v_formula_text <> vlive_formula_text) then
                        return TRUE;
                      end if;

                     EXCEPTION when others then
                      -- not all DT rows in hr_s match to live
                      -- or if live version does not exist we need to transfer
                        return TRUE;
                     END;

                    end loop;

                    -- Now check the rest of the row's columns
                    -- not imported by a later hdt
                    begin
                      select null
                      into l_dummy
                      from dual
                      where not exists
                        ((
                         select effective_start_date,
                                effective_end_date,
                                description
                         from   hr_s_formulas_f
                         where  formula_id = form_id
                         and    formula_type_id = r_distinct.formula_type_id
                         MINUS
                         select effective_start_date,
                                effective_end_date,
                                description
                         from   ff_formulas_f
                         where  formula_id = form_id
                         and    formula_type_id = r_distinct.formula_type_id
                        )
                         UNION
                        (
                         select effective_start_date,
                                effective_end_date,
                                description
                         from   ff_formulas_f
                         where  formula_id = form_id
                         and    formula_type_id = r_distinct.formula_type_id
                         MINUS
                         select effective_start_date,
                                effective_end_date,
                                description
                         from   hr_s_formulas_f
                         where  formula_id = form_id
                         and    formula_type_id = r_distinct.formula_type_id
                        ));
                    -- if we get a row and not the exception then identical
                    return FALSE;
                    exception
                      -- otherwise there is a diff
                      when no_data_found then
                        return TRUE;
                    end;
end formula_changed;

BEGIN

    -- Two loops are used here. The main loop which select distinct primary
    -- key rows and an inner loop which selects all date effective rows for the
    -- primary key. The inner loop is only required in phase 2, since only
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
    --                 of the installation (validity_checks).

    -- An exception is used with this procedure 'row_in_error' in case an error
    -- is encountered from calling any function. If this is raised, then an
    -- exception is entered into the control tables (crt_exc();) and a rollback
    -- is performed.

    IF p_phase = 1 THEN
	check_next_sequence;
    END IF;

    FOR formula_names IN c_distinct LOOP


	savepoint new_formula_name;

	r_distinct := formula_names;

	BEGIN


	    IF valid_ownership THEN

	        -- This row is wanted


		IF p_phase = 1 THEN


		    -- Get new surrogate id and update child references

		    update_uid;

	        ELSE

		    -- Phase = 2

                    -- Now Ids are matched Check if formula definition is
                    -- actually required
                    if not  formula_changed(r_distinct.c_surrogate_key) then
                      remove(r_distinct.c_surrogate_key);
                    else

		    delete from ff_fdi_usages_f
		    where  formula_id = r_distinct.c_surrogate_key;

		    delete from ff_compiled_info_f
                    where  formula_id = r_distinct.c_surrogate_key;

		    delete from ff_formulas_f
		    where  formula_id = r_distinct.c_surrogate_key;

		    FOR each_row IN c_each_row(r_distinct.c_surrogate_key) LOOP


		        r_each_row := each_row;

		        IF NOT check_parents THEN
		            RAISE row_in_error;
		        END IF;

                        BEGIN
		        insert into ff_formulas_f
		        (formula_id
	                ,effective_start_date
	                ,effective_end_date
	                ,business_group_id
	                ,legislation_code
	                ,formula_type_id
	                ,formula_name
	                ,description
	                ,formula_text
	                ,sticky_flag
                        ,compile_flag
	                ,last_update_date
		        ,last_updated_by
	                ,last_update_login
	                ,created_by
	                ,creation_date
		        )
		        values
		        (r_each_row.formula_id
                        ,r_each_row.effective_start_date
                        ,r_each_row.effective_end_date
                        ,r_each_row.business_group_id
                        ,r_each_row.legislation_code
                        ,r_each_row.formula_type_id
                        ,r_each_row.formula_name
                        ,r_each_row.description
                        ,r_each_row.formula_text
                        ,r_each_row.sticky_flag
                        ,r_each_row.compile_flag
                        ,r_each_row.last_update_date
                        ,r_each_row.last_updated_by
                        ,r_each_row.last_update_login
                        ,r_each_row.created_by
                        ,r_each_row.creation_date
                        );
                      EXCEPTION WHEN OTHERS THEN
                        hr_legislation.hrrunprc_trace_on;
                        hr_utility.trace('ins ff_formulas_f');
                        hr_utility.trace('formula_name  ' ||
                          r_each_row.formula_name);
                        hr_utility.trace('formula_id  ' ||
                          to_char(r_each_row.formula_id));
                        hr_utility.trace('formula_type_id  ' ||
                          to_char(r_each_row.formula_type_id));
                        hr_utility.trace(':lc: ' || ':' ||
                          r_each_row.legislation_code || ':');
                        hr_legislation.hrrunprc_trace_off;
                        raise;
                      END;

		        remove(r_distinct.c_surrogate_key);

		    END LOOP each_row;

	            validity_checks;

		    -- This will cause a rollback if error occurs

	       END IF;

              end if; -- need the row


	    END IF;

        EXCEPTION WHEN row_in_error THEN

	    -- Already rolled back

	    null;

        END;

    END LOOP formula_names;

END install_formulas;

--****************************************************************************
-- INSTALLATION PROCEDURE FOR : FF_ROUTES
--****************************************************************************

PROCEDURE install_routes (p_phase IN number)
------------------------
IS
    -- Procedure install routes/usages/entities/parameters/parameter values.
    -- The main driving installation cursor runs from hr_s_routes. All child
    -- rows are installed as cursors driven by the current route_id. The user
    -- entities then have child rows installed in a similar way.
    -- If the route has not changed, ie:does not need to be installed, it may
    -- still remain in the startup tables if there are child user entities to
    -- install. When a route is installed, the child rows of parameters and
    -- context usages are fully refreshed. Child user entities are stil treated
    -- as only being installed if required. Database ietms and parameter values
    -- are fully refreshed if the parent user entity is required to be installed.

    l_null_return varchar2(1); 		-- For 'select null' statements
    l_new_surrogate_key number(15); 	-- New surrogate key for the delivery row
    string varchar2(80);
    l_route_id number;
    l_route_name varchar2(2000);
    l_new_route BOOLEAN;

    CURSOR c_all_159260
    IS
    select route_id route_id,
           route_name route_name
    from   hr_s_routes
    where  last_update_login = 159260;

    CURSOR stu				-- Selects all rows from startup entity
    IS
    select route_id c_surrogate_key
    ,route_name c_true_key
    ,user_defined_flag
    ,description
    ,text
    ,nvl(last_update_date,to_date('01-01-0001','DD-MM-YYYY')) last_update_date
    ,last_updated_by
    ,last_update_login
    ,created_by
    ,creation_date
    ,optimizer_hint
    ,rowid
    from   hr_s_routes;

    CURSOR user_entity (r_id IN number)	-- To install all user entities
    IS					-- for a given route
	select *
   	from   hr_s_user_entities
   	where  route_id = r_id;

    CURSOR usage (r_id IN number)	-- To install context usages
    IS					-- for a given route
	select distinct *
	from   hr_s_route_context_usages
   	where  route_id = r_id;

    CURSOR parameter (r_id IN number)	-- To install all route parameters
    IS					-- for a given route
	select ROUTE_PARAMETER_ID
	,      ROUTE_ID
	,      DATA_TYPE
	,      PARAMETER_NAME
	,      SEQUENCE_NO
	,      rowid
   	from   hr_s_route_parameters
   	where  route_id = r_id;

    CURSOR parameter_value (ue_id IN number)
    IS
	-- To install parameter values for a given user entity

	select *
   	from   hr_s_route_parameter_values
   	where  user_entity_id = ue_id;

    CURSOR db_item (ue_id IN number)
    IS
        -- Cursor to install database items for a given user entity

	select *
   	from   hr_s_database_items
   	where  user_entity_id = ue_id;

    stu_rec stu%ROWTYPE;

    PROCEDURE crt_exc (exception_type IN varchar2)
    ----------------------------------------------
    IS
	-- Reports any exceptions during the delivery of startup data to
	-- FF_ROUTES

    BEGIN
	-- When the installation procedures encounter an error that cannot
	-- be handled, an exception is raised and all work is rolled back
	-- to the last savepoint. The installation process then continues
	-- with the next primary key to install. The same exception will
	-- not be raised more than once.


	rollback to new_route_name;

	hr_legislation.insert_hr_stu_exceptions('ff_routes'
        ,      stu_rec.c_surrogate_key
        ,      exception_type
        ,      stu_rec.c_true_key);


    END crt_exc;

    PROCEDURE check_id_conflicts
    ----------------------------
    IS
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
	-- Three tables are tested:
	--   1. ff_routes
	--   2. ff_user_entities
	--   3. ff_route_parameters
	-- The second is tested for using the sequences.
	-- If the next value from the live sequence is within the range of
	-- delivered surrogate id's then the live sequence must be incremented.
	-- If no action is taken, then duplicates may be introduced into the
	-- delivered tables, and child rows may be totally invalidated.
	-- This procedure will check three sequences
	--   1. ff_routes_S
	--   2. ff_user_entities_s
	--   3. ff_route_parameters_s

       v_sequence_number number(9);
       v_min_delivered number(9);
       v_max_delivered number(9);
       --
       cursor get_ff_routes is
            select distinct null
            from   ff_routes a
            where  exists
                (select null
                 from   hr_s_routes b
                 where  a.route_id = b.route_id
                );

        cursor get_ff_route_parameters is
            select distinct null
            from   ff_route_parameters a
            where  exists
                (select null
                 from   hr_s_route_parameters b
                 where  b.route_parameter_id = a.route_parameter_id
                );

        cursor get_ff_user_entities is
            select distinct null
            from   ff_user_entities a
            where  exists
                (select null
                 from   hr_s_user_entities b
                 where  a.user_entity_id = b.user_entity_id
                );
    --
    BEGIN

	-- Start with check against ff_routes


	BEGIN	--check that the installde routes will not conflict
		--with the delivered values

            --
            open get_ff_routes;
            fetch get_ff_routes into l_null_return;
            IF get_ff_routes%NOTFOUND OR get_ff_routes%NOTFOUND IS NULL THEN
                 RAISE NO_DATA_FOUND;
            END IF;
            close get_ff_routes;
            --
	    --conflict may exist
	    --update all route_id's to remove conflict

	    update /*+NO_INDEX*/ hr_s_routes
	    set    route_id = route_id - 50000000;

	    update hr_s_application_ownerships
	    set    key_value = key_value - 50000000
	    where  key_name = 'ROUTE_ID';

	    update /*+NO_INDEX*/ hr_s_balance_dimensions
	    set    route_id = route_id - 50000000;

            update /*+NO_INDEX*/ hr_s_dimension_routes
            set    route_id = route_id - 50000000;

	    update /*+NO_INDEX*/ hr_s_route_context_usages
	    set    route_id = route_id - 50000000;

	    update /*+NO_INDEX*/ hr_s_user_entities
            set    route_id = route_id - 50000000;

	    update /*+NO_INDEX*/ hr_s_route_parameters
            set    route_id = route_id - 50000000;

	EXCEPTION WHEN NO_DATA_FOUND THEN NULL;

	END; --check of route_id


	BEGIN	--check that no conflict exists within the route
		--parameter id's

            --
            open get_ff_route_parameters;
            fetch get_ff_route_parameters into l_null_return;
            IF get_ff_route_parameters%NOTFOUND
            OR get_ff_route_parameters%NOTFOUND IS NULL THEN
                RAISE NO_DATA_FOUND;
            END IF;
            close get_ff_route_parameters;
            --
	    --Conflict exists, so update the stu values of the parameter id

	    update hr_s_route_parameters
	    set    route_parameter_id = route_parameter_id -50000000;

	    update hr_s_route_parameter_values
            set    route_parameter_id = route_parameter_id -50000000;

	EXCEPTION WHEN NO_DATA_FOUND THEN NULL;

        END; --check of route_parameter_id



	BEGIN	--check that no conflict exists with the id's of the installed
		--user entities, compared with the values of delivered UE's

            --
            open get_ff_user_entities;
            fetch get_ff_user_entities into l_null_return;
            IF get_ff_user_entities%NOTFOUND OR get_ff_user_entities%NOTFOUND IS NULL THEN
                 RAISE NO_DATA_FOUND;
            END IF;
            close get_ff_user_entities;
            --
	    --conflict exists, so update the stu values of user_entity_id

	    update /*+NO_INDEX*/ hr_s_user_entities
	    set    user_entity_id = user_entity_id -50000000;

            update /*+NO_INDEX*/ hr_s_database_items
            set    user_entity_id = user_entity_id -50000000;

            update /*+NO_INDEX*/ hr_s_route_parameter_values
            set    user_entity_id = user_entity_id -50000000;

            update /*+NO_INDEX*/ hr_s_report_format_items_f
            set    user_entity_id = user_entity_id -50000000;

        EXCEPTION WHEN NO_DATA_FOUND THEN NULL;

        END; --check of user_entity_id


   	select min(route_id) - (count(*) *3)
   	,      max(route_id) + (count(*) *3)
   	into   v_min_delivered
   	,      v_max_delivered
   	from   hr_s_routes;

   	select ff_routes_s.nextval
   	into   v_sequence_number
   	from   dual;

	IF v_sequence_number
	  BETWEEN v_min_delivered AND v_max_delivered THEN

            hr_legislation.munge_sequence('FF_ROUTES_S',
                                          v_sequence_number,
                                          v_max_delivered);

        END IF;

	-- Now check ff_user_entities


   	select min(user_entity_id) - (count(*) *3)
   	,      max(user_entity_id) + (count(*) *3)
   	into   v_min_delivered
   	,      v_max_delivered
   	from   hr_s_user_entities;

   	select ff_user_entities_s.nextval
   	into   v_sequence_number
   	from   dual;

	IF v_sequence_number
	  BETWEEN v_min_delivered AND v_max_delivered THEN

            hr_legislation.munge_sequence('FF_USER_ENTITIES_S',
                                          v_sequence_number,
                                          v_max_delivered);

        END IF;

	-- Now check ff_route_parameters


   	select min(route_parameter_id) - (count(*) *3)
   	,      max(route_parameter_id) + (count(*) *3)
   	into   v_min_delivered
   	,      v_max_delivered
   	from   hr_s_route_parameters;

   	select ff_route_parameters_s.nextval
   	into   v_sequence_number
   	from   dual;

	IF v_sequence_number
	  BETWEEN v_min_delivered AND v_max_delivered THEN

            hr_legislation.munge_sequence('FF_ROUTE_PARAMETERS_S',
                                          v_sequence_number,
                                          v_max_delivered);

        END IF;

    END check_id_conflicts;

    PROCEDURE update_uid
    --------------------
    IS
        -- Subprogram to update surrogate UID and all occurrences in child rows

	l_new_parameter_id number(9);
	l_new_entity_id    number(9);

    cursor c_form3(p_route_id number) is
      select distinct ffu.formula_id fid
      from   ff_fdi_usages_f ffu
      where  ffu.item_name in (select fdbi.user_name
                               from   ff_database_items fdbi,
                                      ff_user_entities fue
                               where  fdbi.user_entity_id = fue.user_entity_id
                               and    fue.route_id = p_route_id);

    BEGIN

        l_new_surrogate_key := null;

        BEGIN

	    select distinct route_id
	    into   l_new_surrogate_key
	    from   ff_routes
	    where  route_name = stu_rec.c_true_key
            and    user_defined_flag = 'N';

        EXCEPTION WHEN NO_DATA_FOUND THEN


           select ff_routes_s.nextval
           into   l_new_surrogate_key
	   from   dual;

           WHEN TOO_MANY_ROWS THEN
                        hr_legislation.hrrunprc_trace_on;
                        hr_utility.trace('sel route ff_routes TMR');
                        hr_utility.trace('route_name  ' ||
                          stu_rec.c_true_key);
                        hr_legislation.hrrunprc_trace_off;
                        raise;
        END;


	-- Update all child entities


        update hr_s_routes
        set    route_id = l_new_surrogate_key
        where  rowid = stu_rec.rowid;

        update hr_s_application_ownerships
        set    key_value = to_char(l_new_surrogate_key)
        where  key_value = to_char(stu_rec.c_surrogate_key)
        and    key_name = 'ROUTE_ID';

        update hr_s_balance_dimensions
        set    route_id = l_new_surrogate_key
        where  route_id = stu_rec.c_Surrogate_key;

        update hr_s_dimension_routes
        set    route_id = l_new_surrogate_key
        where  route_id = stu_rec.c_Surrogate_key;

        update hr_s_route_context_usages
        set    route_id = l_new_surrogate_key
        where  route_id = stu_rec.c_Surrogate_key;


        FOR delivered_params IN parameter(stu_Rec.c_Surrogate_key) LOOP

	    BEGIN --select of new surrogate id


	        select route_parameter_id
	        into   l_new_parameter_id
	        from   ff_route_parameters
                where  sequence_no = delivered_params.sequence_no
	        and    parameter_name = delivered_params.parameter_name
	        and    route_id = l_new_surrogate_key;

	    EXCEPTION WHEN NO_DATA_FOUND THEN

                /* As this could be a change to either the sequence ordering
                   or the parameter naming (or both) be safe and just delete
                   all parameters for this route and reimport them from scratch
                   so as to avoid any constraint violations */

               /* bug 5501644 */
                for r_form3 in c_form3(l_new_surrogate_key) loop
                  delete ff_fdi_usages_f where formula_id = r_form3.fid;
                  delete ff_compiled_info_f where formula_id = r_form3.fid;
                end loop;

                delete ff_route_parameter_values
                where route_parameter_id in (
                  select route_parameter_id
                  from   ff_route_parameters
                  where  route_id = l_new_surrogate_key);

                delete ff_route_parameters
                where  route_id = l_new_surrogate_key;

	        select ff_route_parameters_s.nextval
	        into   l_new_parameter_id
                from   dual;

                 WHEN TOO_MANY_ROWS THEN

                        hr_legislation.hrrunprc_trace_on;
                        hr_utility.trace('sel ff_route_parameters TMR');
                        hr_utility.trace('parameter_name  ' ||
                          delivered_params.parameter_name);
                        hr_utility.trace('route_id  ' ||
                          to_char(l_new_surrogate_key));
                        hr_utility.trace('route_name  ' ||
                          stu_rec.c_true_key);
                        hr_utility.trace('sequence_no  ' ||
                          to_char(delivered_params.sequence_no));
                        hr_legislation.hrrunprc_trace_off;
                        raise;

	    END; --select of new surrogate id

	    update hr_s_route_parameters
	    set    route_id = l_new_surrogate_key
	    ,      route_parameter_id = l_new_parameter_id
	    where  route_parameter_id = delivered_params.route_parameter_id;

	    update hr_s_route_parameter_values
	    set    route_parameter_id = l_new_parameter_id
            where  route_parameter_id = delivered_params.route_parameter_id;

        END LOOP delivered_params;

	FOR delivered_entities IN user_entity(stu_Rec.c_Surrogate_key) LOOP

            BEGIN

		select user_entity_id
		into   l_new_entity_id
	  	from   ff_user_entities
	   	where  user_entity_name = delivered_entities.user_entity_name
                and    nvl(legislation_code,'X') = nvl(delivered_entities.legislation_code,'X')
	   	and    route_id = l_new_surrogate_key;

	    EXCEPTION WHEN NO_DATA_FOUND THEN

		select ff_user_entities_s.nextval
		into   l_new_entity_id
		from   dual;

                WHEN TOO_MANY_ROWS THEN
                        hr_legislation.hrrunprc_trace_on;
                        hr_utility.trace('sel ff_user_entities TMR');
                        hr_utility.trace('user_entity_name  ' ||
                          delivered_entities.user_entity_name);
                        hr_utility.trace('route_id  ' ||
                          to_char(l_new_surrogate_key));
                        hr_utility.trace('route_name  ' ||
                          stu_rec.c_true_key);
                        hr_utility.trace(':lc: ' || ':' ||
                          delivered_entities.legislation_code || ':');
                        hr_legislation.hrrunprc_trace_off;
                        raise;
	    END;

	     update hr_s_user_entities
	     set    user_entity_id = l_new_entity_id
	     ,      route_id = l_new_surrogate_key
	     where  user_entity_id = delivered_entities.user_entity_id;

	     update hr_s_database_items
	     set    user_entity_id = l_new_entity_id
             where  user_entity_id = delivered_entities.user_entity_id;

	     update hr_s_route_parameter_values
             set    user_entity_id = l_new_entity_id
             where  user_entity_id = delivered_entities.user_entity_id;

  	     update hr_s_report_format_items_f
             set    user_entity_id = l_new_entity_id
             where  user_entity_id = delivered_entities.user_entity_id;

	END LOOP;

    END update_uid;

    PROCEDURE remove (v_route_id IN number)
    ---------------------------------------
    IS
	-- Remove a row from the startup tables

    BEGIN

   	delete from hr_s_database_items a
        where  a.user_entity_id in
          (select b.user_entity_id
           from   hr_s_user_entities b
           where  b.route_id = v_route_id
           );

   	delete from hr_s_route_parameter_values a
   	where  a.user_entity_id in
          (select b.user_entity_id
           from   hr_s_user_entities b
           where  b.route_id = v_route_id
           );

   	delete from hr_s_user_entities
   	where  route_id = v_route_id;

   	delete from hr_s_route_context_usages
   	where  route_id = v_route_id;

   	delete from hr_s_route_parameters
   	where  route_id = v_route_id;

   	delete from hr_s_routes
   	where  route_id = v_route_id;

    END remove;

    FUNCTION valid_ownership RETURN BOOLEAN
    ---------------------------------------
    IS
	-- Test ownership of this current row
       cursor get_application_ownerships is
       select null
       from   dual
       where  exists
               (select null
               from   hr_s_application_ownerships a
               ,      fnd_product_installations b
               ,      fnd_application c
               where  a.key_name = 'ROUTE_ID'
               and    a.key_value = stu_rec.c_surrogate_key
               and    a.product_name = c.application_short_name
               and    c.application_id = b.application_id
               and    ((b.status = 'I' and c.application_short_name <> 'PQP')
                       or
                       (b.status in ('I', 'S') and c.application_short_name = 'PQP')));
    --
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

	IF p_phase <> 1 THEN	-- Only perform in phase 1
		return TRUE;
	END IF;


	-- If exception raised below then this row is not needed
        --
        open get_application_ownerships;
        fetch get_application_ownerships into l_null_return;
           IF get_application_ownerships%NOTFOUND OR get_application_ownerships%NOTFOUND IS NULL THEN
               RAISE NO_DATA_FOUND;
           END IF;
        close get_application_ownerships;
        --
	-- Indicate row is required

   	return TRUE;

    EXCEPTION WHEN NO_DATA_FOUND THEN

	-- Row not needed for any installed product

	remove(stu_Rec.c_surrogate_key);

	-- Indicate row not needed

	return FALSE;

    END valid_ownership;


    FUNCTION route_changed (p_route_id IN number,
                            p_new_route OUT nocopy boolean) RETURN BOOLEAN
    ------------------------------------------------------------
    IS
	-- Function to test if the current route is different to the one
	-- installed. If the route is different the function will return true.
	--
	-- Changed the comparison rules so that the routes are now only
	-- flagged as different if the route text itself has changed. In the
	-- past the routes were also considered to be different if the last
	-- update dates were differed. Unfortunately this was the case whenever
	-- a dump file was recreated, even though the route text was unchanged.
	-- This led to all routes being trashed and recreated on the target
	-- account, db items being lost etc. RMF 26.09.95.
	--
        -- Optimizer hint now can trigger update

       v_route_text long; 	-- Used to select the installed route text
       v_optimizer_hint ff_routes.optimizer_hint%type;
       v_last_update date;      -- Used to select the installed last update

    BEGIN

   	select text, optimizer_hint
   	into   v_route_text, v_optimizer_hint
   	from   ff_routes
   	where  route_id = p_route_id;

   	IF  v_route_text = stu_rec.text AND
            nvl(v_optimizer_hint, 'nohint') =
              nvl(stu_rec.optimizer_hint, 'nohint') THEN
	    -- Route text and hint is identical
	    return FALSE;
        END IF;

        p_new_route := FALSE;
--        hr_legislation.hrrunprc_trace_on;
--        hr_utility.trace('route diff: ' || to_char(l_new_surrogate_key) || ' '
--                         || stu_rec.c_true_key);
--        hr_legislation.hrrunprc_trace_off;

	return TRUE; --delivered route is defferent

    EXCEPTION WHEN NO_DATA_FOUND THEN
	-- The route is not installed
        p_new_route := TRUE;
--        hr_legislation.hrrunprc_trace_on;
--        hr_utility.trace('new route: ' || to_char(l_new_surrogate_key) || ' '
--                         || stu_rec.c_true_key);
--        hr_legislation.hrrunprc_trace_off;
	return TRUE;

    END;

    FUNCTION valid_to_insert RETURN BOOLEAN
    ---------------------------------------
    IS
	-- Check to see if the route can be installed.
    --
    l_number number(9);
    --

    BEGIN
	-- Test to see if the route has been created already by a user. The
	-- function will return true if the route is okay to be installed.

        --
   	select count(*)
   	into   l_number
   	from   ff_routes a
   	where  a.route_name = stu_rec.c_true_key
   	and    a.user_defined_flag = 'Y';
        --
	if l_number = 0 or l_number is null then
   	   return TRUE;
        else
	   --This Route name is an existing User-Defined route
	   --So cannot be delivered.
   	   crt_exc('FF_Routes row already created by a user');
	   return FALSE;--indicates this row is not to be transferred
        end if;

    EXCEPTION WHEN NO_DATA_FOUND THEN


	-- No user created row exists for this primary key

	return TRUE;

    END valid_to_insert;

    FUNCTION user_entity_changed (v_user_entity_id IN number) RETURN BOOLEAN
    ------------------------------------------------------------------------
    IS
	-- Check to see if the current user entity differs from the install one
	-- TRUE is returned if the user entity differs

    ue_name1 varchar2(240);
    ue_name2 varchar2(240);

    BEGIN

          select null
          into   l_null_return
          from   dual
          where  exists
            ((select
                     BUSINESS_GROUP_ID,
                     LEGISLATION_CODE,
                     ROUTE_ID,
                     NOTFOUND_ALLOWED_FLAG,
                     USER_ENTITY_NAME,
                     CREATOR_ID,
                     CREATOR_TYPE,
                     ENTITY_DESCRIPTION
              from   hr_s_user_entities
              where  user_entity_id = v_user_entity_id
  MINUS
              select
                     BUSINESS_GROUP_ID,
                     LEGISLATION_CODE,
                     ROUTE_ID,
                     NOTFOUND_ALLOWED_FLAG,
                     USER_ENTITY_NAME,
                     CREATOR_ID,
                     CREATOR_TYPE,
                     ENTITY_DESCRIPTION
              from   ff_user_entities
              where  user_entity_id = v_user_entity_id
  )
              UNION
             (select
                     BUSINESS_GROUP_ID,
                     LEGISLATION_CODE,
                     ROUTE_ID,
                     NOTFOUND_ALLOWED_FLAG,
                     USER_ENTITY_NAME,
                     CREATOR_ID,
                     CREATOR_TYPE,
                     ENTITY_DESCRIPTION
              from   ff_user_entities
              where  user_entity_id = v_user_entity_id
  MINUS
              select
                     BUSINESS_GROUP_ID,
                     LEGISLATION_CODE,
                     ROUTE_ID,
                     NOTFOUND_ALLOWED_FLAG,
                     USER_ENTITY_NAME,
                     CREATOR_ID,
                     CREATOR_TYPE,
                     ENTITY_DESCRIPTION
              from   hr_s_user_entities
              where  user_entity_id = v_user_entity_id
              ))
        or exists
               (select user_name,
                       data_type,
                       definition_text,
                       null_allowed_flag,
                       description
                from   hr_s_database_items
                where  user_entity_id = v_user_entity_id
                MINUS
                select user_name,
                       data_type,
                       definition_text,
                       null_allowed_flag,
                       description
                from   ff_database_items
                where  user_entity_id = v_user_entity_id)
         or exists
                (select value
                 from   hr_s_route_parameter_values
                 where  user_entity_id = v_user_entity_id
                 MINUS
                 select value
                 from   ff_route_parameter_values
                 where  user_entity_id = v_user_entity_id);

        -- Show that this user entity differs from the install one
        begin
          select user_entity_name
          into   ue_name1
          from ff_user_entities
          where user_entity_id = v_user_entity_id;
          select user_entity_name
          into   ue_name2
          from hr_s_user_entities
          where user_entity_id = v_user_entity_id;
--        hr_legislation.hrrunprc_trace_on;
--        hr_utility.trace('ue chg: ' || to_char(v_user_entity_id) || ' '
--                         || ue_name1 || ':' || ue_name2);
--        hr_legislation.hrrunprc_trace_off;
        exception when others then null;
        end;

	return TRUE;

    EXCEPTION WHEN NO_DATA_FOUND THEN


	return FALSE;

    END user_entity_changed;

    FUNCTION install_user_entity (v_route_id IN number) RETURN BOOLEAN
    ------------------------------------------------------------------
    IS
	-- Logic to insert the user entity and all children. If called in pahse one
	-- TRUE is returned as soon as a user entity is found that has to be installed.
	-- If no user entities are to be installed then FALSE is returned.

    cursor c_form(p_ue_id number) is
      select distinct fue.formula_id fid
      from   ff_fdi_usages_f fue
      where  fue.item_name in (select fdbi.user_name
                               from   ff_database_items fdbi
                               where  fdbi.user_entity_id = p_ue_id);

    BEGIN

	FOR all_user_entities IN user_entity(v_route_id) LOOP


	    IF user_entity_changed(all_user_entities.user_entity_id) THEN

                IF p_phase = 1 THEN
		    return TRUE;
		END IF;

                -- delete all formula usages, compiled info that may be
                -- affected by this dbi
                for r_form in c_form(all_user_entities.user_entity_id) loop
                  delete ff_fdi_usages_f where formula_id = r_form.fid;
                  delete ff_compiled_info_f where formula_id = r_form.fid;
                end loop;

                update ff_user_entities
                set business_group_id = all_user_entities.business_group_id
                   ,legislation_code = all_user_entities.legislation_code
                   ,route_id = all_user_entities.route_id
                   ,notfound_allowed_flag = all_user_entities.notfound_allowed_flag
                   ,user_entity_name = all_user_entities.user_entity_name
                   ,creator_id = all_user_entities.creator_id
                   ,creator_type = all_user_entities.creator_type
                   ,entity_description = all_user_entities.entity_description
                   ,last_update_date = all_user_entities.last_update_date
                   ,last_updated_by = all_user_entities.last_updated_by
                   ,last_update_login = all_user_entities.last_update_login
                   ,created_by = all_user_entities.created_by
                   ,creation_date = all_user_entities.creation_date
                where user_entity_id = all_user_entities.user_entity_id;

                IF SQL%NOTFOUND THEN

                BEGIN
	   	insert into ff_user_entities
	   	(user_entity_id
	   	,business_group_id
	   	,legislation_code
	   	,route_id
	   	,notfound_allowed_flag
	   	,user_entity_name
	   	,creator_id
	   	,creator_type
	   	,entity_description
	   	,last_update_date
	   	,last_updated_by
	  	,last_update_login
	  	,created_by
	   	,creation_date
	   	)
	   	values
	   	(all_user_entities.user_entity_id
	   	,all_user_entities.business_group_id
	   	,all_user_entities.legislation_code
	   	,all_user_entities.route_id
		,all_user_entities.notfound_allowed_flag
	   	,all_user_entities.user_entity_name
	   	,all_user_entities.creator_id
	  	,all_user_entities.creator_type
	   	,all_user_entities.entity_description
	   	,all_user_entities.last_update_date
	   	,all_user_entities.last_updated_by
	   	,all_user_entities.last_update_login
	  	,all_user_entities.created_by
	   	,all_user_entities.creation_date
	   	);

                      EXCEPTION WHEN OTHERS THEN
                        hr_legislation.hrrunprc_trace_on;
                        hr_utility.trace('ins ff_user_entities');
                        hr_utility.trace('user_entity_name  ' ||
                          all_user_entities.user_entity_name);
                        hr_utility.trace('user_entity_id  ' ||
                          to_char(all_user_entities.user_entity_id));
                        hr_utility.trace('route_id  ' ||
                          to_char(all_user_entities.route_id));
                        hr_utility.trace('route_name  ' ||
                          stu_rec.c_true_key);
                        hr_utility.trace('creator_id  ' ||
                          to_char(all_user_entities.creator_id));
                        hr_utility.trace('creator_type  ' ||
                          all_user_entities.creator_type);
                        hr_utility.trace(':lc: ' || ':' ||
                          all_user_entities.legislation_code || ':');
                        hr_legislation.hrrunprc_trace_off;
                        raise;
                      END;
                END IF;

	   	FOR all_db_items IN
		  db_item(all_user_entities.user_entity_id)
		LOOP

                    update ff_database_items
                    set    data_type = all_db_items.data_type
                          ,definition_text = all_db_items.definition_text
                          ,null_allowed_flag = all_db_items.null_allowed_flag
                          ,description = all_db_items.description
                          ,last_update_date = all_db_items.last_update_date
                          ,last_updated_by = all_db_items.last_updated_by
                          ,last_update_login = all_db_items.last_update_login
                          ,created_by = all_db_items.created_by
                          ,creation_date = all_db_items.creation_date
                    where user_name = all_db_items.user_name
                    and   user_entity_id = all_db_items.user_entity_id;

                    IF SQL%NOTFOUND THEN

                    BEGIN
		    insert into ff_database_items
		    (user_name
		    ,user_entity_id
		    ,data_type
		    ,definition_text
		    ,null_allowed_flag
		    ,description
		    ,last_update_date
		    ,last_updated_by
		    ,last_update_login
		    ,created_by
		    ,creation_date
		    )
		    VALUES
		    (all_db_items.user_name
		    ,all_db_items.user_entity_id
		    ,all_db_items.data_type
		    ,all_db_items.definition_text
		    ,all_db_items.null_allowed_flag
		    ,all_db_items.description
		    ,all_db_items.last_update_date
		    ,all_db_items.last_updated_by
		    ,all_db_items.last_update_login
		    ,all_db_items.created_by
		    ,all_db_items.creation_date
		    );
                      EXCEPTION WHEN OTHERS THEN
                        hr_legislation.hrrunprc_trace_on;
                        hr_utility.trace('ins ff_database_items');
                        hr_utility.trace('dbi user_name  ' ||
                          all_db_items.user_name);
                        hr_utility.trace('user_entity_id  ' ||
                          to_char(all_db_items.user_entity_id));
                        hr_utility.trace('user_entity_name  ' ||
                          all_user_entities.user_entity_name);
                        hr_utility.trace('route_id  ' ||
                          to_char(all_user_entities.route_id));
                        hr_utility.trace('route_name  ' ||
                          stu_rec.c_true_key);
                        hr_utility.trace('creator_id  ' ||
                          to_char(all_user_entities.creator_id));
                        hr_utility.trace('creator_type  ' ||
                          all_user_entities.creator_type);
                        hr_legislation.hrrunprc_trace_off;
                        raise;
                      END;

                    END IF;

		END LOOP all_db_items;

		FOR pvalues IN
		  parameter_value(all_user_entities.user_entity_id)
		LOOP

		    BEGIN

                    update ff_route_parameter_values
                    set    value = pvalues.value
                          ,last_update_date = pvalues.last_update_date
                          ,last_updated_by = pvalues.last_updated_by
                          ,last_update_login = pvalues.last_update_login
                          ,created_by = pvalues.created_by
                          ,creation_date = pvalues.creation_date
                    where route_parameter_id = pvalues.route_parameter_id
                    and   user_entity_id = pvalues.user_entity_id;

                    IF SQL%NOTFOUND THEN

                    BEGIN
		    insert into ff_route_parameter_values
		   	(route_parameter_id
		   	,user_entity_id
		   	,value
		   	,last_update_date
		   	,last_updated_by
		  	,last_update_login
		   	,created_by
		   	,creation_date
		   	)
		   	VALUES
		   	(pvalues.route_parameter_id
		  	,pvalues.user_entity_id
		   	,pvalues.value
		   	,pvalues.last_update_date
		   	,pvalues.last_updated_by
		   	,pvalues.last_update_login
		   	,pvalues.created_by
		   	,pvalues.creation_date
		   	);
                      EXCEPTION WHEN OTHERS THEN
                        hr_legislation.hrrunprc_trace_on;
                        hr_utility.trace('ins ff_route_parameter_values');
                        hr_utility.trace('value  ' ||
                          pvalues.value);
                        hr_utility.trace('route_parameter_id  ' ||
                          to_char(pvalues.route_parameter_id));
                        hr_utility.trace('user_entity_id  ' ||
                          to_char(pvalues.user_entity_id));
                        hr_utility.trace('user_entity_name  ' ||
                          all_user_entities.user_entity_name);
                        hr_utility.trace('route_id  ' ||
                          to_char(all_user_entities.route_id));
                        hr_utility.trace('route_name  ' ||
                          stu_rec.c_true_key);
                        hr_utility.trace('creator_id  ' ||
                          to_char(all_user_entities.creator_id));
                        hr_utility.trace('creator_type  ' ||
                          all_user_entities.creator_type);
                        hr_legislation.hrrunprc_trace_off;
                        raise;
                      END;

                     END IF;

		    END;

	       END LOOP pvalues;


	    END IF;

       END LOOP all_user_entities;

       IF p_phase = 1 THEN
           return FALSE;
       ELSE
           return TRUE;
       END IF;

    END install_user_entity;

    PROCEDURE delete_route_form_usage
    ---------------------------------
    IS

    cursor c_form2(p_route_id number) is
      select /*+ ORDERED
           INDEX(fdbi FF_DATABASE_ITEMS_FK1)
           USE_NL(fue) */
         distinct formula_id fid
      from
          ff_user_entities fue,
          ff_database_items fdbi,
          ff_fdi_usages_f fdi
      where  fdi.item_name = fdbi.user_name
      and    fdbi.user_entity_id = fue.user_entity_id
      and    fue.route_id = p_route_id;

    BEGIN
        -- delete all formula usages, compiled info that may be
        -- affected by this dbi
        for r_form2 in c_form2(stu_rec.c_surrogate_key) loop

           delete ff_fdi_usages_f where formula_id = r_form2.fid;
           delete ff_compiled_info_f where formula_id = r_form2.fid;
        end loop;

    END delete_route_form_usage;

    PROCEDURE insert_route
    ----------------------
    IS
	-- Logic to insert or update a route, depending upon whether it exists
	-- already in the live tables

    BEGIN

	update ff_routes
	set user_defined_flag = stu_rec.user_defined_flag
	,   description = stu_Rec.description
	,   text  = stu_rec.text
	,   last_update_date = stu_rec.last_update_date
	,   last_updated_by = stu_rec.last_updated_by
	,   last_update_login = stu_rec.last_update_login
	,   created_by = stu_rec.created_by
	,   creation_date = stu_rec.creation_date
        ,   optimizer_hint = stu_rec.optimizer_hint
	where  route_id = stu_rec.c_Surrogate_key;

	IF SQL%NOTFOUND THEN

            BEGIN
	    insert into ff_Routes
	    (route_id
	    ,route_name
	    ,user_defined_flag
	    ,description
	    ,text
	    ,last_update_date
	    ,last_updated_by
	    ,last_update_login
	    ,created_by
	    ,creation_date
            ,optimizer_hint
	    )
	    values
	    (stu_rec.c_surrogate_key
	    ,stu_rec.c_true_key
	    ,stu_rec.user_defined_flag
	    ,stu_rec.description
	    ,stu_rec.text
	    ,stu_rec.last_update_date
	    ,stu_rec.last_updated_by
	    ,stu_rec.last_update_login
	    ,stu_rec.created_by
	    ,stu_rec.creation_date
            ,stu_rec.optimizer_hint
	    );
                      EXCEPTION WHEN OTHERS THEN
                        hr_legislation.hrrunprc_trace_on;
                        hr_utility.trace('ins ff_routes');
                        hr_utility.trace('route_name  ' ||
                          stu_rec.c_true_key);
                        hr_utility.trace('route_id  ' ||
                          to_char(stu_rec.c_surrogate_key));
                        hr_legislation.hrrunprc_trace_off;
                        raise;
                      END;

	END IF;

    END insert_route;

    PROCEDURE transfer_row
    ----------------------
    IS
       -- Procedure to transfer a route from the delivery tables
       cursor c_ff_contexts_null (c_context_id in number) is
       select null
       from   ff_contexts
       where  context_id = c_context_id;
       --
       cursor c_ffrp_null (c_route_parameter_id in number) is
       select null
       from   ff_route_parameters
       where  route_parameter_id = c_route_parameter_id;
       --
       cursor c_ff_rcu_pop (c_route_id in number,
                            c_sequence_no in number,
                            c_context_id in number) is
       select distinct null
       from   ff_route_context_usages
       where  route_id = c_route_id
       and    sequence_no = c_sequence_no
       and    context_id = c_context_id;
       --
    BEGIN
        --
	IF p_phase = 1 THEN
	    IF route_changed(l_new_surrogate_key, l_new_route) THEN
		IF NOT valid_to_insert THEN
		    return;
		END IF;
	    ELSE
		-- Route has not changed, check user entities

	        IF install_user_entity(l_new_surrogate_key) THEN
	            null;
		ELSE
		    -- No user entities to install
                    remove(l_new_surrogate_key);
	      	    return;
	        END IF;
	    END IF;
	ELSE
	    -- Phase = 2
	    IF route_changed(stu_rec.c_surrogate_key, l_new_route) THEN
                --
		IF NOT valid_to_insert THEN
		    return;
		END IF;
		delete_route_form_usage;
		insert_route;
                --
                -- Ensure we rebuild all balance user entities and associated
                -- items in rebuild ele input bal for a changed route
                --
                IF NOT l_new_route THEN
                    delete from ff_user_entities
                    where creator_type in ('B', 'RB')
                    and route_id = stu_rec.c_surrogate_key;
                END IF;
                --
                -- Changing or inserting route so delete live ctx usages
                -- for this route
                --
                delete ff_route_context_usages
                where  route_id = stu_rec.c_surrogate_key;
                --
                -- Now install route ctx usages
                --
		FOR context_usages IN usage(stu_rec.c_surrogate_key) LOOP

		    BEGIN
                       --
                       open c_ff_contexts_null (context_usages.context_id);
                       fetch c_ff_contexts_null into l_null_return;
                       IF c_ff_contexts_null%NOTFOUND OR c_ff_contexts_null%NOTFOUND IS NULL THEN
                          close c_ff_contexts_null;
                          RAISE NO_DATA_FOUND;
                       END IF;
                       close c_ff_contexts_null;
                       --
                        BEGIN
                        insert into ff_route_context_usages
                        (route_id
                        ,context_id
                        ,sequence_no
                        )
                        values
                        (context_usages.route_id
                        ,context_usages.context_id
                        ,context_usages.sequence_no
                        );
                       EXCEPTION WHEN OTHERS THEN
                        hr_legislation.hrrunprc_trace_on;
                        hr_utility.trace('ins ff_route_context_usages');
                        hr_utility.trace('route_id  ' ||
                          to_char(context_usages.route_id));
                        hr_utility.trace('route_name  ' ||
                          stu_rec.c_true_key);
                        hr_utility.trace('context_id  ' ||
                          to_char(context_usages.context_id));
                        hr_utility.trace('sequence_no  ' ||
                          to_char(context_usages.sequence_no));
                        hr_legislation.hrrunprc_trace_off;
                        raise;
                      END;

		    EXCEPTION WHEN NO_DATA_FOUND THEN

		    	crt_exc('Parent context not installed');
		    	return;
		    END;
	    	END LOOP;

                FOR r_hrsrp in parameter (stu_rec.c_surrogate_key) LOOP

                  BEGIN

                       open c_ffrp_null (r_hrsrp.ROUTE_PARAMETER_ID);
                       fetch c_ffrp_null into l_null_return;
                       IF c_ffrp_null%NOTFOUND OR c_ffrp_null%NOTFOUND IS NULL THEN
                                close c_ffrp_null;
                                RAISE NO_DATA_FOUND;
                       END IF;
                       close c_ffrp_null;

                  update ff_route_parameters
                  set    ROUTE_ID = stu_rec.c_surrogate_key
                        ,DATA_TYPE = r_hrsrp.DATA_TYPE
                        ,PARAMETER_NAME = r_hrsrp.PARAMETER_NAME
                        ,SEQUENCE_NO = r_hrsrp.SEQUENCE_NO
                  where ROUTE_PARAMETER_ID = r_hrsrp.ROUTE_PARAMETER_ID;

                  EXCEPTION WHEN NO_DATA_FOUND THEN

                  BEGIN
   	    	  insert into ff_route_parameters
              	  (ROUTE_PARAMETER_ID
             	  ,ROUTE_ID
            	  ,DATA_TYPE
            	  ,PARAMETER_NAME
              	  ,SEQUENCE_NO
            	  )
                  values
                  (r_hrsrp.ROUTE_PARAMETER_ID,
                   stu_rec.c_surrogate_key,
                   r_hrsrp.DATA_TYPE,
                   r_hrsrp.PARAMETER_NAME,
                   r_hrsrp.SEQUENCE_NO);
                      EXCEPTION WHEN OTHERS THEN
                        hr_legislation.hrrunprc_trace_on;
                        hr_utility.trace('ins ff_route_parameters');
                        hr_utility.trace('PARAMETER_NAME  ' ||
                          r_hrsrp.PARAMETER_NAME);
                        hr_utility.trace('SEQUENCE_NO  ' ||
                          to_char(r_hrsrp.SEQUENCE_NO));
                        hr_utility.trace('ROUTE_ID  ' ||
                          to_char(stu_rec.c_surrogate_key));
                        hr_utility.trace('route_name  ' ||
                          stu_rec.c_true_key);
                        hr_utility.trace('ROUTE_PARAMETER_ID ' ||
                          to_char(r_hrsrp.ROUTE_PARAMETER_ID));
                        hr_legislation.hrrunprc_trace_off;
                        raise;
                      END;

                  END;

                END LOOP;

	    END IF;
            --
	    IF NOT install_user_entity(stu_rec.c_surrogate_key) THEN
	    	return;
	    END IF;
	    remove(stu_rec.c_surrogate_key);
        END IF;

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

    -- Need to disable the UE constraint so we can update user entities
    -- outside of the main transfer process so we dont lose our savepoints
    -- via implicit commits

--    disable_ffuebru_trig;

    IF p_phase = 1 THEN
	check_id_conflicts; --attempt to detect and remove any possible
			    --conflicts with surrogate id's that are being
			    --delivered.

    END IF;

    FOR delivered IN stu LOOP

	-- This uses main cursor stu to impilicity define a record


        savepoint new_route_name;

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

    END LOOP delivered;

--    enable_ffuebru_trig;

END install_routes;


--****************************************************************************
-- INSTALLATION PROCEDURE FOR : FF_FUNCTIONS
--****************************************************************************

PROCEDURE install_functions(p_phase IN number)
----------------------------------------------
IS
    -- Install procedure to transfer startup element classifications into
    -- a live account.

    -- The installation of functions is controlled by a main cursor which
    -- selects distinct function names from the startup tables.

    -- For each of these function names if the installed functions differ to the
    -- delivered ones, all installed functions of this name will refreshed.

    l_null_return varchar2(1); 		-- For 'select null' statements
    l_new_surrogate_key number(15); 	-- New surrogate key for the delivery row

    CURSOR stu				-- Selects all rows from startup entity
    IS
   	select distinct name
   	,      legislation_code c_leg_code
   	from   hr_s_functions;

    CURSOR distinct_function(f_name IN varchar2, c_leg_code IN varchar2)
    IS
	-- Cursor to select distinct functions

   	select *
   	from   hr_s_functions
   	where  name = f_name
        and    nvl(legislation_code, 'X') = nvl(c_leg_code, 'X');

    CURSOR usages(f_id IN number)
    IS
	-- Cursor to install child context usages

   	select *
   	from   hr_s_function_context_usages
   	where  function_id = f_id;

    stu_rec stu%ROWTYPE;

    PROCEDURE crt_exc (exception_type IN varchar2)
    ----------------------------------------------
    IS
	-- Reports any exceptions during the delivery of startup data to
	-- FF_FUNCTIONS

    BEGIN
	-- When the installation procedures encounter an error that cannot
	-- be handled, an exception is raised and all work is rolled back
	-- to the last savepoint. The installation process then continues
	-- with the next primary key to install. The same exception will
	-- not be raised more than once.

	-- The exception text is set to a composite value because this exception
	-- is raised against a function name, not a function id. Consequently
	-- the surrogate id is set to a value of 0.


	rollback to new_function_name;

	hr_legislation.insert_hr_stu_exceptions('ff_functions'
        ,      0
        ,      exception_type
        ,      stu_rec.name);


    END crt_exc;

    PROCEDURE remove(target varchar2)
    ---------------------------------
    IS
	-- Remove a row from either the startup tables or the installed tables

    BEGIN
	-- This procedure either deletes from the delivered account,
   	-- parameter of 'D', or from the live account, parameter of 'I'.

   	-- If the delivered details are being deleted the explicit deletes
   	-- from all child tables are required, since the cascade constraint
   	-- will not be delivered with these tables.

   	-- When deleting from the live account, the cascade delete can
   	-- be relied upon.

        IF target = 'D' THEN

	    delete from hr_s_function_context_usages a
	    where  exists
		   (select null
		   from   hr_s_functions b
		   where  b.function_id = a.function_id
		   and    b.name = stu_rec.name
                   and nvl(b.legislation_code,'X')=nvl(stu_rec.c_leg_code,'X')
		   );

	    delete from hr_s_function_parameters a
	    where  exists
		   (select null
		   from   hr_s_functions b
		   where  b.function_id = a.function_id
		   and    b.name = stu_rec.name
                   and nvl(b.legislation_code,'X')=nvl(stu_rec.c_leg_code,'X')
		   );


	    delete from hr_s_functions
	    where  name = stu_rec.name
            and    nvl(legislation_code,'X')=nvl(stu_rec.c_leg_code,'X');

	ELSE

	    -- Delete from live account using the cascade delete


	    delete from ff_functions
	    where  name = stu_rec.name
            and    nvl(legislation_code,'X')=nvl(stu_rec.c_leg_code,'X');

	END IF;

    END remove;

    PROCEDURE insert_delivered
    --------------------------
    IS
	-- Check if a delivered row is needed and insert into the
	-- live tables if it is

	v_inst_update date;  	-- Holds update details of installed row

    BEGIN


	BEGIN

	    -- Perform a check to see if the primary key has been created within
	    -- a visible business group. Ie: the business group is for the same
	    -- legislation as the delivered row, or the delivered row has a null
	    -- legislation. If no rows are returned then the primary key has not
	    -- already been created by a user.

            select distinct null
            into   l_null_return
            from ff_functions a
            where a.name = stu_rec.name
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

	BEGIN
            select distinct null
            into   l_null_return
            from   ff_functions
            where  name = stu_rec.name
            and    nvl(legislation_code,'X') <> nvl(stu_rec.c_leg_code,'X')
            and   (
                   legislation_code is null
                or stu_rec.c_leg_code is null
                   );

            crt_exc('Row already created for a visible legislation');

	    -- Indicates this row is not to be transferred

            return;

   	EXCEPTION WHEN NO_DATA_FOUND THEN

	    null;

	END;


	-- This procedure is only called in phase 2. All matching live
	-- functions will be be deleted and replaced with the delivered
	-- rows.

	-- The routine check_parents validates foreign key references and
	-- ensures referential integrity. The routine checks to see if the
	-- parents of a given row have been transfered to the live tables.

	-- This may only be called in phase two since in phase one all
	-- parent rows will remain in the delivery tables.

	-- After the above checks only data that has been chanegd or is new
	-- will be left in the delivery tables.

	-- The last step of this transfer, in phase 2, is to delete the now
	-- transfered row from the delivery tables.

	-- Before the update/insert goes ahead, ensure all child rows
	-- are removed so the refrsh of child rows is simple.

	remove('I');

	FOR each_func IN distinct_function(stu_rec.name, stu_rec.c_leg_code) LOOP


	    select ff_functions_s.nextval
	    into   l_new_surrogate_key
	    from   dual;


 BEGIN
	    insert into ff_functions
	    (function_id
	    ,business_group_id
	    ,legislation_code
	    ,class
	    ,name
	    ,alias_name
	    ,data_type
	    ,definition
	    ,last_update_date
	    ,last_updated_by
	    ,last_update_login
	    ,created_by
	    ,creation_date
	    )
	    values (l_new_surrogate_key
	    ,null
	    ,each_func.legislation_code
	    ,each_func.class
	    ,each_func.name
	    ,each_func.alias_name
	    ,each_func.data_type
	    ,each_func.definition
	    ,each_func.last_update_date
	    ,each_func.last_updated_by
	    ,each_func.last_update_login
	    ,each_func.created_by
	    ,each_func.creation_date
	    );


                     EXCEPTION WHEN OTHERS THEN
                        hr_legislation.hrrunprc_trace_on;
                        hr_utility.trace('ins ff_functions');
                        hr_utility.trace('function name  ' ||
                          each_func.name);
                        hr_utility.trace('function_id  ' ||
                          to_char(l_new_surrogate_key));
                        hr_utility.trace(':lc: ' || ':' ||
                          each_func.legislation_code || ':');
                        hr_legislation.hrrunprc_trace_off;
                        raise;
                      END;

            BEGIN
            insert into ff_function_parameters
	    (function_id
	    ,sequence_number
	    ,class
	    ,continuing_parameter
	    ,data_type
	    ,name
	    ,optional
	    )
	    select l_new_surrogate_key
	    ,      sequence_number
	    ,      class
	    ,      continuing_parameter
	    ,      data_type
	    ,      name
	    ,      optional
	    from   hr_s_function_parameters
	    where  function_id = each_func.function_id;
                      EXCEPTION WHEN OTHERS THEN
                        hr_legislation.hrrunprc_trace_on;
                        hr_utility.trace('ins ff_function_parameters');
                        hr_utility.trace('function_id  ' ||
                          to_char(each_func.function_id));
                        hr_utility.trace('function name  ' ||
                          each_func.name);
                        hr_utility.trace(':lc: ' ||
                          each_func.legislation_code || ':');
                        hr_legislation.hrrunprc_trace_off;
                        raise;
                      END;

	    FOR child_usages IN usages(each_func.function_id) LOOP

	        BEGIN


		    select null
		    into   l_null_return
		    from   ff_contexts
		    where  context_id = child_usages.context_id;

		    insert into ff_function_context_usages
		    (function_id
		    ,sequence_number
		    ,context_id
		    )
		    values
		    (l_new_surrogate_key
		    ,child_usages.sequence_number
		    ,child_usages.context_id
		    );

	        EXCEPTION WHEN NO_DATA_FOUND THEN


		    crt_exc('Context referenced by child usage is not present');

		    return;

                    WHEN OTHERS THEN
                        hr_legislation.hrrunprc_trace_on;
                        hr_utility.trace('ins ff_function_context_usages');
                        hr_utility.trace('function_id  ' ||
                          to_char(l_new_surrogate_key));
                        hr_utility.trace('function name  ' ||
                          each_func.name);
                        hr_utility.trace(':lc: ' ||
                          each_func.legislation_code || ':');
                        hr_utility.trace('sequence_number  ' ||
                          to_char(child_usages.sequence_number));
                        hr_utility.trace('context_id  ' ||
                          to_char(child_usages.context_id));
                        hr_legislation.hrrunprc_trace_off;
                        raise;

	        END;

	    END LOOP child_usages;

        END LOOP each_func;


        remove('D');

    END insert_delivered;

BEGIN
    -- This is the main loop to perform the installation logic. A cursor
    -- is opened to control the loop, and each row returned is placed
    -- into a record defined within the main procedure so each sub
    -- procedure has full access to all returrned columns. For each
    -- new row returned, a new savepoint is declared. If at any time
    -- the row is in error a rollback is performed to the savepoint
    -- and the next row is returned.

    -- In phase 1 the only logic is to check if the function needs to be
    -- installed. If the function needs to be installed, it will be left
    -- in the delivery tables. If not then it will be deleted.

    -- The surrogate id will be created/set in phase 2.

    -- In phase 2 all installed functions of the name stu_rec.name will be
    -- deleted from the live account. All delivered functions/usages/parameters
    -- will be then inserted. At this point a new function id will be allocated.

    FOR delivered IN stu LOOP

	-- Uses main cursor stu to impilicity define a record


	savepoint new_function_name;

   	stu_rec := delivered;


	IF p_phase = 2 THEN
	  insert_delivered;
	END IF;

    END LOOP;

END install_functions;

--****************************************************************************
-- INSTALLATION PROCEDURE FOR : FF_QP_REPORTS
--****************************************************************************

PROCEDURE install_qpreports(p_phase IN number)
----------------------------------------------
IS
    -- Install procedure to transfer startup QuickPaint reports into
    -- a live account.

    l_null_return varchar2(1);		-- For 'select null' statements
    l_new_surrogate_key number(15); 	-- New surrogate key for the delivery row

    CURSOR stu				-- Selects all rows from startup entity
    IS

	select qp_report_id c_surrogate_key
	,      formula_id
	,      formula_type_id
	,      qp_report_name c_true_key
	,      business_group_id
	,      legislation_code c_leg_code
	,      qp_altered_formula
	,      qp_description
	,      qp_text
	,      last_update_date
	,      last_updated_by
	,      last_update_login
	,      created_by
	,      creation_date
	,      rowid
	from   hr_s_qp_reports;

    stu_rec stu%ROWTYPE;

    PROCEDURE crt_exc(exception_type IN varchar2)
    ---------------------------------------------
    IS
	-- If an exception has been detected meaning that the delivered row may
	-- not be installed, then it must be reported

    BEGIN

	-- When the installation procedures encounter an error that cannot
	-- be handled, an exception is raised and all work is rolled back
	-- to the last savepoint. The installation process then continues
	-- with the next primary key to install. The same exception will
	-- not be raised more than once.


	rollback to new_qp_report_name;

	hr_legislation.insert_hr_stu_exceptions('ff_qp_reports'
        ,      stu_rec.c_surrogate_key
        ,      exception_type
        ,      stu_rec.c_true_key);


    END crt_exc;

    PROCEDURE check_next_sequence
    -----------------------------
    IS

   	v_sequence_number number(9);
   	v_min_delivered number(9);
   	v_max_delivered number(9);

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
	    from   ff_qp_reports a
	    where  exists
		(select null
		 from   hr_s_qp_reports b
		 where  a.qp_report_id = b.qp_report_id
		);

	    --conflict may exist
	    --update all qp_report_id's to remove conflict

	    update hr_s_qp_reports
	    set    qp_report_id = qp_report_id - 50000000;

	    update hr_s_application_ownerships
	    set    key_value = key_value - 50000000
	    where  key_name = 'QP_REPORT_ID';

	EXCEPTION WHEN NO_DATA_FOUND THEN NULL;

	END; --check of qp_report_id


	select min(qp_report_id) - (count(*) *3)
   	,      max(qp_report_id) + (count(*) *3)
   	into   v_min_delivered
   	,      v_max_delivered
   	from   hr_s_qp_reports;

   	select ff_qp_reports_s.nextval
   	into   v_sequence_number
   	from   dual;

   	IF v_sequence_number
	  BETWEEN v_min_delivered AND v_max_delivered THEN

            hr_legislation.munge_sequence('FF_QP_REPORTS_S',
                                          v_sequence_number,
                                          v_max_delivered);

        END IF;

    END check_next_sequence;

    PROCEDURE update_uid
    --------------------
    IS
	-- Update surrogate UID and all occurrences in child rows

    BEGIN


	BEGIN

	    select distinct qp_report_id
	    into   l_new_surrogate_key
	    from   ff_qp_reports
	    where  qp_report_name = stu_rec.c_true_key
	    and    business_group_id is null
            and  ( (legislation_code is null and stu_rec.c_leg_code is null)
                or (legislation_code = stu_rec.c_leg_code) );

    	EXCEPTION WHEN NO_DATA_FOUND THEN

	    select ff_qp_reports_s.nextval
	    into   l_new_surrogate_key
	    from   dual;

	END;

	-- Update all child entities

   	update hr_s_qp_reports
        set    qp_report_id = l_new_surrogate_key
    	where  qp_report_id = stu_rec.c_surrogate_key;

   	update hr_s_application_ownerships
   	set    key_value = to_char(l_new_surrogate_key)
   	where  key_value = to_char(stu_rec.c_surrogate_key)
   	and    key_name = 'QP_REPORT_ID';

    END update_uid;

    PROCEDURE remove
    ----------------
    IS
	-- Remove a row from either the startup tables or the installed tables

    BEGIN

   	delete from hr_s_qp_reports
   	where  rowid = stu_rec.rowid;

    END remove;

    FUNCTION valid_ownership RETURN BOOLEAN
    ---------------------------------------
    IS
	-- Test ownership of this current row

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

	-- A return code of TRUE indicates that thhe row is required.

	-- The exception is raised within this procedure if no rows are returned
	-- in this select statement. If no rows are returned then one of the
	-- following is true:
	--     1. No ownership parameters are defined.
	--     2. The products, for which owning parameters are defined, are not
	--        installed with as status of 'I'.
	--     3. The data is defined for a legislation subgroup that is not active.

    BEGIN


	IF p_phase <> 1 THEN	-- Only perform in phase 1
		return TRUE;
	END IF;


	-- If exception raised below then this row is not needed
        -- get rid of subgrp table, not even using it!
	select null
	into   l_null_return
	from   dual
	where  exists
	   (select null
	    from   hr_s_application_ownerships a
	    ,      fnd_product_installations b
	    ,      fnd_application c
	    where  a.key_name = 'QP_REPORT_ID'
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

	-- Indicate row not needed

	return FALSE;

    END valid_ownership;

    FUNCTION check_parents RETURN BOOLEAN
    -------------------------------------
    IS
	-- Check if parent data is correct

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

	-- Start parent checking against formula types


	BEGIN

	    -- Checking the delivery account

	    select distinct null
	    into   l_null_return
	    from   hr_s_formula_types
	    where  formula_type_id = stu_rec.formula_type_id;

	    crt_exc('Parent formula type remains in delivery tables');

	    -- Parent row still in startup account

	    return FALSE;

	EXCEPTION WHEN NO_DATA_FOUND THEN

	    null;

	END;


	BEGIN

	    -- Checking the installed account

	    select null
	    into   l_null_return
	    from   ff_formula_types
	    where  formula_type_id = stu_rec.formula_type_id;

	    -- Drop down to second parent check

   	EXCEPTION WHEN NO_DATA_FOUND THEN


	    crt_exc('Parent formula type not installed');

	    return FALSE;

	END;

        -- Start parent checking against formulas


	BEGIN

	    -- Checking the delivery account

            select distinct null
            into   l_null_return
            from   hr_s_formulas_f
            where  formula_id = stu_rec.formula_id;

            crt_exc('Parent formula remains in delivery tables');

	    -- Parent row still in startup account

            return FALSE;

	EXCEPTION WHEN NO_DATA_FOUND THEN

	    null;

	END;


	BEGIN

	    -- Checking the installed account

            select distinct null
            into   l_null_return
            from   ff_formulas_f
            where  formula_id = stu_rec.formula_id;

            return TRUE;

       EXCEPTION WHEN NO_DATA_FOUND THEN


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

	    -- Perform a check to see if the primary key has been created
	    -- within a visible business group. Ie: the business group
	    -- is for the same legislation as the delivered row, or the
	    -- delivered row has a null legislation. If no rows are
	    -- returned then the primary key has not already been
	    -- created by a user.

            select distinct null
            into   l_null_return
            from ff_qp_reports a
            where a.qp_report_name = stu_rec.c_true_key
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

	BEGIN

	    select distinct null
            into   l_null_return
            from   ff_qp_reports
            where  qp_report_name = stu_rec.c_true_key
            and    nvl(legislation_code,'X') <> nvl(stu_rec.c_leg_code,'X')
            and   (legislation_code is null
		   or stu_rec.c_leg_code is null );

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
	    -- Fails because parents exist
	    return;
	END IF;


   	update ff_qp_reports
   	set    formula_id = stu_rec.formula_id
   	,      formula_type_id = stu_rec.formula_type_id
   	,      qp_report_name = to_char(stu_rec.c_surrogate_key)
   	,      business_group_id = null
   	,      legislation_code = stu_rec.c_leg_code
   	,      qp_altered_formula = stu_rec.qp_altered_formula
   	,      qp_description = stu_rec.qp_description
   	,      qp_text = stu_rec.qp_text
   	,      last_update_date = stu_rec.last_update_date
   	,      last_updated_by = stu_rec.last_updated_by
   	,      last_update_login = stu_rec.last_update_login
   	,      created_by = stu_rec.created_by
   	,      creation_date = stu_rec.creation_date
   	where  qp_report_id = stu_rec.c_surrogate_key;

   	IF NOT SQL%FOUND THEN


	    insert into ff_qp_reports
	    (qp_report_id
	    ,formula_id
	    ,formula_type_id
	    ,qp_report_name
	    ,business_group_id
	    ,legislation_code
	    ,qp_altered_formula
	    ,qp_description
	    ,qp_text
	    ,last_update_date
	    ,last_updated_by
	    ,last_update_login
	    ,created_by
	    ,creation_date
	    )
	    values
	    (stu_rec.c_surrogate_key
	    ,stu_rec.formula_id
	    ,stu_rec.formula_type_id
	    ,stu_rec.c_true_key
	    ,null
	    ,stu_rec.c_leg_code
	    ,stu_rec.qp_altered_formula
	    ,stu_rec.qp_description
	    ,stu_rec.qp_text
	    ,stu_rec.last_update_date
	    ,stu_rec.last_updated_by
	    ,stu_rec.last_update_login
	    ,stu_rec.created_bY
	    ,stu_rec.creation_date
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

    IF p_phase = 1 THEN
	check_next_sequence;
    END IF;

    FOR delivered IN stu LOOP

	-- Uses main cursor stu to impilicity define a record


	savepoint new_qp_report_name;

   	stu_rec := delivered;

	IF p_phase = 2 THEN
	    l_new_surrogate_key := stu_rec.c_surrogate_key;
	END IF;

	IF valid_ownership THEN

	    -- Test the row ownerships for the current row


	    IF p_phase = 1 THEN
		update_uid;
	    END IF;

	    transfer_row;

	END IF;

    END LOOP;

END install_qpreports;

--****************************************************************************
-- INSTALLATION PROCEDURE FOR : FF_GLOBALS_S
--****************************************************************************

PROCEDURE install_globals(p_phase IN NUMBER)
--------------------------------------------
IS
    -- Install procedure to transfer startup delivered globals into a
    -- live account, and remove the then delivered rows from the delivery
    -- account.

    -- This procedure is called in two phase. Only in the second phase are
    -- details transferred into live tables. The parameter p_phase holds
    -- the phase number.

    row_in_error exception;
    l_current_proc varchar2(80) := 'hr_legislation.install_globals';
    l_new_global_id number(15);
    l_null_return varchar2(1);
    status varchar2(10);

    CURSOR c_distinct
    IS
	-- Select statement used for the main loop. Each row return is used
	-- as the commit unit, since each true primary key may have many date
	-- effective rows for it.

	-- The selected primary key is then passed into the second driving
	-- cursor statement as a parameter, and all date effective rows for
	-- this primary key are then selected.

  	select max(effective_end_date) c_end
	,      global_id c_surrogate_key
   	,      global_name c_true_key
   	,      legislation_code
   	from   hr_s_globals_f
   	group  by global_id
   	,         global_name
   	,         legislation_code;

    CURSOR c_each_row(pc_global_id varchar2)
    IS
	-- Selects all date effective rows for the current true primary key
	-- The primary key has already been selected using the above cursor.
	-- This cursor accepts the primary key as a parameter and selects all
	-- date effective rows for it.

	select *
	from   hr_s_globals_f
	where  global_id = pc_global_id;

    -- These records are defined here so all sub procedures may use the
    -- values selected. This saves the need for all sub procedures to have
    -- a myriad of parameters passed. The cursors are controlled in FOR
    -- cursor LOOPs. When a row is returned the whole record is copied into
    -- these record definitions.

    CURSOR c_global_ad(p_global_id number)
    IS
      -- This cursor is used when deleting rows from ff_globals_f.
      -- FF_GLOBAL_F has an after delete trigger that removes user_entities
      -- that have a creator_id = the global_id of the row being removed.
      -- When deleting these UE, the BRD UE trigger potentially deletes
      -- database items. This trigger invalidates all formulae that can be
      -- affected by these dbi removals.
      select distinct ffu.formula_id fid
      from   ff_fdi_usages_f ffu
      where  ffu.item_name in (select fdbi.user_name
                               from   ff_database_items fdbi,
                                      ff_user_entities ffue
                               where  fdbi.user_entity_id = ffue.user_entity_id
                                 and  ffue.creator_id = p_global_id
                                 and  ffue.creator_type = 'S');

    r_distinct c_distinct%ROWTYPE;
    r_each_row c_each_row%ROWTYPE;

    PROCEDURE remove (v_id IN number)
    ---------------------------------
    IS
	-- Subprogram to delete a row from the delivery tables, and all child
	-- application ownership rows

    BEGIN


   	delete from hr_s_globals_f
   	where  global_id = v_id;

    END remove;

    PROCEDURE check_next_sequence
    -----------------------------
    IS

	v_sequence_number number(9);
	v_min_delivered number(9);
	v_max_delivered number(9);

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
	    from   ff_globals_f a
	    where  exists
		(select null
		 from   hr_s_globals_f b
		 where  a.global_id = b.global_id
		);

	    --conflict may exist
	    --update all global_id's to remove conflict

	    update /*+NO_INDEX*/ hr_s_globals_f
	    set    global_id = global_id - 50000000;

	    update hr_s_application_ownerships
	    set    key_value = key_value - 50000000
	    where  key_name = 'GLOBAL_ID';

	EXCEPTION WHEN NO_DATA_FOUND THEN NULL;

	END; --check of global_id


   	select min(global_id) - (count(*) *3)
   	,      max(global_id) + (count(*) *3)
   	into   v_min_delivered
   	,      v_max_delivered
   	from   hr_s_globals_f;

   	select ff_globals_s.nextval
   	into   v_sequence_number
   	from   dual;

        IF v_sequence_number
          BETWEEN v_min_delivered AND v_max_delivered THEN

            hr_legislation.munge_sequence('FF_GLOBALS_S',
                                          v_sequence_number,
                                          v_max_delivered);
        END IF;

    END check_next_sequence;

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

	    select distinct global_id
	    into   l_new_global_id
	    from   ff_globals_f
	    where  global_name = r_distinct.c_true_key
	    and    business_Group_id is null
            and    ((legislation_code is NULL and r_distinct.legislation_code is NULL)
                    or (r_distinct.legislation_code=legislation_code));


	EXCEPTION WHEN NO_DATA_FOUND THEN


	    select ff_globals_s.nextval
	    into   l_new_global_id
	    from   dual;

            WHEN TOO_MANY_ROWS THEN
                        hr_legislation.hrrunprc_trace_on;
                        hr_utility.trace('sel ff_globals_f TMR');
                        hr_utility.trace('global_name  ' ||
                          r_distinct.c_true_key);
                        hr_utility.trace(':lc: ' || ':' ||
                          r_distinct.legislation_code || ':');
                        hr_legislation.hrrunprc_trace_off;
                        raise;
	END;

	update hr_s_globals_f
   	set    global_id = l_new_global_id
   	where  global_id = r_distinct.c_surrogate_key;

   	update hr_s_application_ownerships
   	set    key_value = to_char(l_new_global_id)
   	where  key_value = to_char(r_distinct.c_surrogate_key)
   	and    key_name = 'GLOBAL_ID';

    END update_uid;

    PROCEDURE crt_exc(exception_type IN varchar2)
    ---------------------------------------------
    IS
	-- If an exception has been detected meaning that the delivered row may
	-- not be installed, then it must be reported

    BEGIN

	-- When the installation procedures encounter an error that cannot
	-- be handled, an exception is raised and all work is rolled back
	-- to the last savepoint. The installation process then continues
	-- with the next primary key to install. The same exception will
	-- not be raised more than once.

   	rollback to new_global_name;

	hr_legislation.insert_hr_stu_exceptions('ff_globals_f'
        ,      r_distinct.c_surrogate_key
        ,      exception_type
        ,      r_distinct.c_true_key);


    END crt_exc;

-- ----------------------------------
-- ----------------------------------
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
        cursor get_ff_globals is
            select distinct null
            from ff_globals_f a
            where a.global_name = r_distinct.c_true_key
            and   a.business_group_id is not null
            and   exists (select null from per_business_groups b
              where b.business_group_id = a.business_group_id
              and b.legislation_code = nvl(r_distinct.legislation_code,b.legislation_code));

        --
        cursor c_valid_ownership is
            select distinct null
            from   ff_globals_f
            where  global_name = r_distinct.c_true_key
            and    nvl(legislation_code,'X')<>nvl(r_distinct.legislation_code,'X')
            and   (legislation_code is null
                   or r_distinct.legislation_code is null );
        --
	BEGIN
   	    BEGIN
		-- Perform a check to see if the primary key has been
		-- created within a visible business group. Ie: the
		-- business group is for the same legislation as the
		-- delivered row, or the delivered row has a null
		-- legislation. If no rows are returned then the primary
		-- key has not already been created by a user.

                open get_ff_globals;
                fetch get_ff_globals into l_null_return;
                    IF get_ff_globals%NOTFOUND OR get_ff_globals%NOTFOUND IS NULL THEN
                        RAISE NO_DATA_FOUND;
                    END IF;
                close get_ff_globals;
                --
		crt_exc('Row already created in a business group');
		-- Indicate this row is not to be transferred
		return FALSE;

	     EXCEPTION WHEN NO_DATA_FOUND THEN
		null;
            --
	    END;

	    -- Now perform a check to see if this primary key has been installed
	    -- with a legislation code that would make it visible at the same time
	    -- as this row. Ie: if any legislation code is null within the set of
	    -- returned rows, then the transfer may not go ahead. If no rows are
	    -- returned then the delivered row is fine.

	BEGIN
            --
            open c_valid_ownership;
            fetch c_valid_ownership into l_null_return;
                IF c_valid_ownership%NOTFOUND OR c_valid_ownership%NOTFOUND IS NULL THEN
                    RAISE NO_DATA_FOUND;
                END IF;
            close c_valid_ownership;
            --
	    crt_exc('Row already created for a visible legislation');
	    return FALSE; --indicates this row is not to be transferred

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
            where exists (select null from hr_s_application_ownerships a
	    ,      fnd_product_installations b
	    ,      fnd_application c
	    where  a.key_name = 'GLOBAL_ID'
	    and    a.key_value = r_distinct.c_surrogate_key
	    and    a.product_name = c.application_short_name
	    and    c.application_id = b.application_id
            and    ((b.status = 'I' and c.application_short_name <> 'PQP')
                    or
                    (b.status in ('I', 'S') and c.application_short_name = 'PQP')));


	    -- Indicate row is required

	    return TRUE;

	EXCEPTION WHEN NO_DATA_FOUND THEN

	    -- Row not needed for any installed product


	    remove(r_distinct.c_surrogate_key);

	    -- Indicate row not needed

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

-- disable dynamic cont calc trigger
-- dis_cont_calc_trigger;

    IF p_phase = 1 THEN
	check_next_sequence;
    END IF;

    FOR primary_keys IN c_distinct LOOP

	r_distinct := primary_keys;


   	savepoint new_global_name;

        BEGIN

	    IF valid_ownership THEN

	        -- This row is wanted


		IF p_phase = 1 THEN


		    -- Get new surrogate id and update child references

		    update_uid;

		    delete from hr_s_globals_f
		    where  global_id = l_new_global_id
		    and    not exists
		           ((select
                               EFFECTIVE_START_DATE,
                               EFFECTIVE_END_DATE,
                               BUSINESS_GROUP_ID,
                               LEGISLATION_CODE,
                               DATA_TYPE,
                               GLOBAL_NAME,
                               GLOBAL_DESCRIPTION,
                               GLOBAL_VALUE
			     from   hr_s_globals_f
			     where  global_id = l_new_global_id
			     MINUS
			     select
                               EFFECTIVE_START_DATE,
                               EFFECTIVE_END_DATE,
                               BUSINESS_GROUP_ID,
                               LEGISLATION_CODE,
                               DATA_TYPE,
                               GLOBAL_NAME,
                               GLOBAL_DESCRIPTION,
                               GLOBAL_VALUE
                             from   ff_globals_f
			     where  global_id = l_new_global_id
			    )
			     UNION
			    (select
                               EFFECTIVE_START_DATE,
                               EFFECTIVE_END_DATE,
                               BUSINESS_GROUP_ID,
                               LEGISLATION_CODE,
                               DATA_TYPE,
                               GLOBAL_NAME,
                               GLOBAL_DESCRIPTION,
                               GLOBAL_VALUE
                             from   ff_globals_f
                             where  global_id = l_new_global_id
                             MINUS
                             select
                               EFFECTIVE_START_DATE,
                               EFFECTIVE_END_DATE,
                               BUSINESS_GROUP_ID,
                               LEGISLATION_CODE,
                               DATA_TYPE,
                               GLOBAL_NAME,
                               GLOBAL_DESCRIPTION,
                               GLOBAL_VALUE
                             from   hr_s_globals_f
                             where  global_id = l_new_global_id
		           ))
               and exists (select distinct null
                   from   ff_user_entities u,
                          ff_database_items d,
                          ff_route_parameters rp,
                          ff_route_parameter_values rpv
                   where  u.user_entity_name = global_name || '_GLOBAL_UE'
                     and  u.user_entity_id = rpv.user_entity_id
                     and  d.user_entity_id = u.user_entity_id
                     and  rpv.route_parameter_id = rp.route_parameter_id
                     and  rpv.value = to_char(l_new_global_id));

		ELSE

		    -- Phase = 2


                    for r_global in c_global_ad(r_distinct.c_surrogate_key)
                    loop
                      delete ff_fdi_usages_f where formula_id = r_global.fid;
                      delete ff_compiled_info_f where formula_id = r_global.fid;
                    end loop;

                    -- Delete ff_route_parameter_values
                    -- associated with this global bug 3744555
                    -- and let them get recreated by the global triggers
                    delete ff_route_parameter_values
                    where  user_entity_id = (select user_entity_id
                      from ff_user_entities
                      where user_entity_name = r_distinct.c_true_key || '_GLOBAL_UE');

		    delete from ff_globals_f
		    where  global_id = r_distinct.c_surrogate_key;

		    FOR each_row IN c_each_row(r_distinct.c_surrogate_key)
		    LOOP

		        r_each_row := each_row;


                        BEGIN
		        insert into ff_globals_f
		        (GLOBAL_ID
		        ,EFFECTIVE_START_DATE
		        ,EFFECTIVE_END_DATE
		        ,BUSINESS_GROUP_ID
		        ,LEGISLATION_CODE
		        ,DATA_TYPE
		        ,GLOBAL_NAME
		        ,GLOBAL_DESCRIPTION
		        ,GLOBAL_VALUE
		        ,LAST_UPDATE_DATE
		        ,LAST_UPDATED_BY
		        ,LAST_UPDATE_LOGIN
		        ,CREATED_BY
		        ,CREATION_DATE)
		        values
		        (r_each_row.GLOBAL_ID
		        ,r_each_row.EFFECTIVE_START_DATE
		        ,r_each_row.EFFECTIVE_END_DATE
		        ,r_each_row.BUSINESS_GROUP_ID
		        ,r_each_row.LEGISLATION_CODE
		        ,r_each_row.DATA_TYPE
		        ,r_each_row.GLOBAL_NAME
		        ,r_each_row.GLOBAL_DESCRIPTION
		        ,r_each_row.GLOBAL_VALUE
		        ,r_each_row.LAST_UPDATE_DATE
		        ,r_each_row.LAST_UPDATED_BY
		        ,r_each_row.LAST_UPDATE_LOGIN
		        ,r_each_row.CREATED_BY
		        ,r_each_row.CREATION_DATE);

                      EXCEPTION WHEN OTHERS THEN
                        hr_legislation.hrrunprc_trace_on;
                        hr_utility.trace('ins ff_globals_f');
                        hr_utility.trace('GLOBAL_NAME  ' ||
                          r_each_row.GLOBAL_NAME);
                        hr_utility.trace('GLOBAL_ID  ' ||
                          to_char(r_each_row.GLOBAL_ID));
                        hr_utility.trace('GLOBAL_VALUE  ' ||
                          r_each_row.GLOBAL_VALUE);
                        hr_utility.trace(':lc: ' || ':' ||
                          r_each_row.legislation_code || ':');
                        hr_legislation.hrrunprc_trace_off;
                        raise;
                      END;
		    END LOOP each_row;

		    remove(r_distinct.c_surrogate_key);

		END IF;

	    END IF;

	EXCEPTION WHEN row_in_error THEN
	    rollback to new_global_name;
	END;

    END LOOP primary_keys;

-- ena_cont_calc_trigger;

END install_globals;

--****************************************************************************
-- INSTALLATION PROCEDURE FOR ALL FF DELIVERY
--****************************************************************************

PROCEDURE install (p_phase number)
----------------------------------
IS
    -- Driver procedure to execute all formula installation procedures.
  core_selected NUMBER;

BEGIN
hr_legislation.hrrunprc_trace_on;
    hr_utility.trace('start ff_data_dict.install: ' || to_char(p_phase));
hr_legislation.hrrunprc_trace_off;

    IF p_phase <> 1 and p_phase <>2 THEN
	return;
    END IF;

    IF p_phase = 2 THEN

        select count(*)
        into   core_selected
        from   hr_legislation_installations
        where  legislation_code is null
        and    action in ('I', 'U', 'F');

    END IF;
hr_legislation.hrrunprc_trace_on;
    hr_utility.trace('start install_ffc: ' || to_char(p_phase));
hr_legislation.hrrunprc_trace_off;

    install_ffc(p_phase);  	--install ff_contexts
hr_legislation.hrrunprc_trace_on;
    hr_utility.trace('start install_fft: ' || to_char(p_phase));
hr_legislation.hrrunprc_trace_off;

    install_fft(p_phase);  	--install ff_Formula_types

hr_legislation.hrrunprc_trace_on;
    hr_utility.trace('start install_formulas: ' || to_char(p_phase));
hr_legislation.hrrunprc_trace_off;

    install_formulas(p_phase); 	--install formulas

hr_legislation.hrrunprc_trace_on;
    hr_utility.trace('start install_routes: ' || to_char(p_phase));
hr_legislation.hrrunprc_trace_off;

    install_routes(p_phase); 	--install routes,entities,db items

hr_legislation.hrrunprc_trace_on;
    hr_utility.trace('start install_functions: ' || to_char(p_phase));
hr_legislation.hrrunprc_trace_off;

    install_functions(p_phase); --install functions, context usages etc

hr_legislation.hrrunprc_trace_on;
    hr_utility.trace('start install_qpreports: ' || to_char(p_phase));
hr_legislation.hrrunprc_trace_off;

    install_qpreports(p_phase); --install quickpaint reports

hr_legislation.hrrunprc_trace_on;
    hr_utility.trace('start install_globals: ' || to_char(p_phase));
hr_legislation.hrrunprc_trace_off;

    install_globals(p_phase); 	--install globals

hr_legislation.hrrunprc_trace_on;
    hr_utility.trace('exit ff_data_dict.install: ' || to_char(p_phase));
hr_legislation.hrrunprc_trace_off;

END install;

END ff_data_dict;

/
