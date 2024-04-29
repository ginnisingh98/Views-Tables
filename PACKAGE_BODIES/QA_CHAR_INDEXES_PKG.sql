--------------------------------------------------------
--  DDL for Package Body QA_CHAR_INDEXES_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."QA_CHAR_INDEXES_PKG" AS
/* $Header: qaindexb.pls 120.0 2005/05/24 19:10:53 appldev noship $ */

    -- A constant to fool GSCC.  See bug 3554899
    -- Copied from qltvcreb
    -- bso Wed Apr  7 22:27:11 PDT 2004
    g_period CONSTANT VARCHAR2(1) := '.';

    --
    -- Apps schema info
    --
    g_dummy           BOOLEAN;
    g_fnd             CONSTANT VARCHAR2(3) := 'FND';
    g_fnd_schema      VARCHAR2(30);
    g_qa              CONSTANT VARCHAR2(3) := 'QA';
    g_qa_schema       VARCHAR2(30);
    g_status          VARCHAR2(1);
    g_industry        VARCHAR2(10);

    --
    -- Standard who columns.
    --
    who_user_id                 CONSTANT NUMBER := fnd_global.conc_login_id;
    who_request_id              CONSTANT NUMBER := fnd_global.conc_request_id;
    who_program_id              CONSTANT NUMBER := fnd_global.conc_program_id;
    who_program_application_id  CONSTANT NUMBER := fnd_global.prog_appl_id;


    CURSOR c_enabled(p_char_id NUMBER) IS
        SELECT enabled_flag
        FROM   qa_char_indexes
        WHERE  char_id = p_char_id;


    FUNCTION index_exists(p_char_id NUMBER)
        RETURN INTEGER IS

    --
    -- Return 1 if index exists for p_char_id.  0 otherwise.
    --
        l NUMBER;

    BEGIN

        OPEN c_enabled(p_char_id);
        FETCH c_enabled INTO l;
        IF c_enabled%NOTFOUND THEN
            CLOSE c_enabled;
            RETURN 0;
        END IF;

        CLOSE c_enabled;
        RETURN 1;

    END index_exists;


    FUNCTION index_exists_and_enabled(p_char_id NUMBER)
        RETURN INTEGER IS

    --
    -- Return 1 if index exists and enabled for p_char_id.  0 otherwise.
    --

        l NUMBER;

    BEGIN
        OPEN c_enabled(p_char_id);
        FETCH c_enabled INTO l;
        IF c_enabled%NOTFOUND THEN
            CLOSE c_enabled;
            RETURN 0;
        END IF;

        CLOSE c_enabled;
        IF l = 1 THEN
            RETURN 1;
        ELSE
            RETURN 0;
        END IF;

    END index_exists_and_enabled;


    FUNCTION get_default_result_column(p_char_id NUMBER)
        RETURN VARCHAR2 IS

    --
    -- Return the default result column name of an index (that is
    -- the final parameter in the decode function.
    -- If no index exists or the index is disabled, this function
    -- returns NULL.  Caller can use this function to test for
    -- the enable/disable status also.  Just test to see if the
    -- return value is NULL or not.
    --

        CURSOR c IS
            SELECT default_result_column
            FROM   qa_char_indexes
            WHERE  char_id = p_char_id AND enabled_flag = 1;

        l_result_column VARCHAR2(30);

    BEGIN
        OPEN c;
        FETCH c INTO l_result_column;
        IF c%notfound THEN
            CLOSE c;
            RETURN NULL;
        END IF;

        CLOSE c;
        RETURN l_result_column;
    END get_default_result_column;


    FUNCTION disable_index(p_char_id NUMBER) RETURN INTEGER IS
    --
    -- Disable the index if one exists.  Return 0 if successful;
    -- a negative error code if not (or if index doesn't exist).
    -- Does not perform database commit.
    --
    BEGIN
        UPDATE qa_char_indexes
        SET enabled_flag = 2
        WHERE char_id = p_char_id;

        RETURN 0;

        EXCEPTION
            WHEN OTHERS THEN
                RETURN err_disable_index;

    END disable_index;


    FUNCTION create_hardcoded_index(
        p_char_id NUMBER,
        p_alias VARCHAR2,
        p_index_name VARCHAR2,
        p_additional_parameters VARCHAR2)
        RETURN INTEGER IS
    --
    -- Create the hardcoded index.
    -- Return 0 if successful, a negative error code if not.
    --
    -- FUTURE EXPANSION ONLY.  NOT IN SCOPE.
    -- bso Sun Nov 21 15:42:23 PST 2004
    --
    BEGIN
        RETURN err_unsupported_element_type;
    END create_hardcoded_index;


    FUNCTION construct_decode_function(
        p_char_id NUMBER,
        p_alias VARCHAR2,
        x_most_common OUT NOCOPY VARCHAR2,
        x_function OUT NOCOPY dbms_sql.varchar2s)
        RETURN INTEGER IS

    --
    -- This is an auxiliary function that constructs the decode
    -- function to be used in the function-based index.  The
    -- function string is returned in pieces in the x_function
    -- array (an array of varchar2).  An array is used instead of
    -- a simple VARCHAR2 because PL/SQL VARCHAR2 can only handle
    -- 32K while a create index DDL can handle 64K.
    --
    -- Make sure the input p_alias is either null or a valid table
    -- alias with the period, such as 'QR.'
    --
    -- Return 0 if successful; a negative error code otherwise.
    --
    -- Note: this function was modeled after the global_view
    -- procedure in qltvcreb and utilized the same dbms_sql.varchar2s
    -- array.  It can potentially handle more than 32K, but the
    -- current scope is to handle decode function of 32K or less
    -- to make other PL/SQL manipulation of this function string
    -- more manageable.  Expansion to > 32K is non-trivial because
    -- ordinary PL/SQL VARCHAR2 variables used in many places to
    -- handle this function string cannot handle > 32K.
    -- bso Sun Nov 21 14:51:50 PST 2004
    --

        --
        -- This cursor is used to find the most commonly used
        -- result column name given a char_id.  Ignore template
        -- plans (i.e., organization_id <> 0)
        --
        CURSOR c_most_common(p_char_id NUMBER) IS
            SELECT qpc.result_column_name
            FROM   qa_plan_chars qpc, qa_plans qp
            WHERE  qpc.plan_id = qp.plan_id AND
                   qpc.char_id = p_char_id AND
                   qp.organization_id <> 0
            GROUP BY result_column_name
            ORDER BY count(result_column_name) desc;

        l_most_common VARCHAR2(30);

        --
        -- This cursor is the main loop to go through each plan
        -- that is not template plan (i.e., organization_id <> 0).
        -- Since the most commonly used result column name will be
        -- appended to the end of the DECODE function as default
        -- parameter, the plans having this are ignored also.
        --
        CURSOR c_result_column(p_char_id NUMBER, p_col VARCHAR2) IS
            SELECT qpc.plan_id, qpc.result_column_name
            FROM   qa_plan_chars qpc, qa_plans qp
            WHERE  qpc.plan_id = qp.plan_id AND
                   qpc.char_id = p_char_id AND
                   qp.organization_id <> 0 AND
                   qpc.result_column_name <> p_col;

        --
        -- Bug 1357601.  The decode statement used to "straighten" softcoded
        -- elements into a single column has a sever limit of 255 parameters.
        -- These variables are added to resolve the limit.  When the limit is
        -- up, we use the very last parameter of the decode statement to
        -- start a new decode, which can have another 255 params.  This is
        -- repeated as necessary.
        --
        -- decode_count keeps the no. of decodes being used so far.
        -- decode_param keeps the no. of parameters in the current decode.
        -- decode_limit is the server limit.  This should be updated if
        --    the server is enhanced in the future.
        --
        decode_count NUMBER;
        decode_param NUMBER;
        decode_limit CONSTANT NUMBER := 255;
        i INTEGER;

    BEGIN

        OPEN c_most_common(p_char_id);
        FETCH c_most_common INTO l_most_common;
        IF c_most_common%notfound THEN
            CLOSE c_most_common;
            RETURN err_element_not_in_use;
        END IF;

        CLOSE c_most_common;
        x_most_common := l_most_common;

        --
        -- Main loop to go through each plan ID that has p_char_id
        -- as element (except when the result column name is the
        -- most common column).  Now construct the decode function.
        -- For example,
        --
        -- decode(qr.plan_id,
        --     101, qr.character2,
        --     102, qr.character5,
        --     103, qr.character14,
        --     qr.character1)
        --
        i := 1;
        x_function(i) := 'DECODE(' || p_alias || 'PLAN_ID,';
        decode_count := 1;     -- see comments in variable declaration.
        decode_param := 1;
        FOR r IN c_result_column(p_char_id, l_most_common) LOOP
            i := i + 1;

            --
            -- If maximum no. of arguments to the "decode" function is
            -- close to the server allowed 'decode_limit', then we want
            -- to start a new tail-end decode statement.
            --
            IF decode_param >= (decode_limit - 2) THEN
                x_function(i) := 'DECODE(' || p_alias || 'PLAN_ID,';
                i := i + 1;
                decode_count := decode_count + 1;
                decode_param := 1;
            END IF;

            x_function(i) := r.plan_id || ',' || p_alias ||
                r.result_column_name || ',';

            decode_param := decode_param + 2;
        END LOOP;

        IF i = 1 THEN
            --
            -- In the extremely rare condition where all plans have the
            -- same result column for this char ID, we need to remove
            -- the decode function.
            --
            x_function(i) := p_alias || l_most_common;
        ELSE
            --
            -- Add the most common column as default parameter and then
            -- close all decode() parenthesis
            --
            x_function(i) := x_function(i) || p_alias || l_most_common;

            FOR x IN 1 .. decode_count LOOP
                x_function(i) := x_function(i) || ')';
            END LOOP;
        END IF;

        RETURN 0;

    END construct_decode_function;


    FUNCTION varchar2s_to_varchar2(
        p_function dbms_sql.varchar2s,
        x_ddl OUT NOCOPY VARCHAR2)
        RETURN INTEGER IS
    --
    -- A helper function to convert the decode function string from
    -- dbms_sql.varchar2 format to a simple string.  Return 0 if
    -- successful; -1 if not.
    --
        l_ddl VARCHAR2(32767);
    BEGIN

        FOR i IN p_function.FIRST .. p_function.LAST LOOP
            l_ddl := l_ddl || p_function(i);
        END LOOP;

        x_ddl := l_ddl;
        RETURN 0;

        EXCEPTION
            WHEN OTHERS THEN
                RETURN err_string_overflow;

    END varchar2s_to_varchar2;


    FUNCTION create_softcoded_index(
        p_char_id NUMBER,
        p_alias VARCHAR2,
        p_index_name VARCHAR2,
        p_additional_parameters VARCHAR2)
        RETURN INTEGER IS
    --
    -- Create the softcoded index.
    -- Return 0 if successful, a negative error code if not.
    --
        l_ddl VARCHAR2(32767); -- current scope supports 32k only
        l_function dbms_sql.varchar2s;
        l_status INTEGER;
        l_alias_dot VARCHAR2(50);
        l_most_common VARCHAR2(30);
        l_rowid VARCHAR2(50);

    BEGIN
        IF p_alias IS NOT NULL THEN
            l_alias_dot := p_alias || '.';
        END IF;

        l_status := construct_decode_function(
            p_char_id, l_alias_dot, l_most_common, l_function);
        IF l_status <> 0 THEN
            RETURN l_status;
        END IF;

        l_status := varchar2s_to_varchar2(l_function, l_ddl);
        IF l_status <> 0 THEN
            RETURN l_status;
        END IF;

        --
        -- Table operation is performed before DDL by design
        -- so that the database commit inherent in the DDL
        -- will commit the data in sync.
        --
        insert_row(
            x_rowid                     => l_rowid,
            p_created_by                => who_user_id,
            p_creation_date             => sysdate,
            p_last_updated_by           => who_user_id,
            p_last_update_date          => sysdate,
            p_last_update_login         => who_user_id,
            p_request_id                => who_request_id,
            p_program_application_id    => who_program_application_id,
            p_program_id                => who_program_id,
            p_program_update_date       => sysdate,
            p_char_id                   => p_char_id,
            p_enabled_flag              => 1,
            p_index_name                => p_index_name,
            p_default_result_column     => l_most_common,
            p_text                      => l_ddl,
            p_additional_parameters     => p_additional_parameters);

        --
        -- Here l_ddl contains the actual DECODE function.
        -- we prepend and append the rest of the actual
        -- rdbms CREATE INDEX command and pass to ad_ddl.
        -- String overflow is still possible.
        --
        l_ddl := 'CREATE INDEX ' || g_qa_schema || '.' ||
            '"' || p_index_name || '" ON ' ||
            g_qa_schema || '.QA_RESULTS ' || p_alias ||
            '(' || l_alias_dot || 'PLAN_ID, ' || l_ddl || ') ' ||
            p_additional_parameters;

        ad_ddl.do_ddl(
            applsys_schema => g_fnd_schema,
            application_short_name => g_qa,
            statement_type => ad_ddl.create_index,
            statement => l_ddl,
            object_name => p_index_name);

        RETURN 0;


        EXCEPTION
            WHEN VALUE_ERROR THEN
                RETURN err_string_overflow;
            WHEN OTHERS THEN
                RETURN err_create_index;

    END create_softcoded_index;



    PROCEDURE insert_row(
        x_rowid                     OUT NOCOPY VARCHAR2,
        p_created_by                NUMBER,
        p_creation_date             DATE,
        p_last_updated_by           NUMBER,
        p_last_update_date          DATE,
        p_last_update_login         NUMBER,
        p_request_id                NUMBER,
        p_program_application_id    NUMBER,
        p_program_id                NUMBER,
        p_program_update_date       DATE,
        p_char_id                   NUMBER,
        p_enabled_flag              NUMBER,
        p_index_name                VARCHAR2,
        p_default_result_column     VARCHAR2,
        p_text                      VARCHAR2,
        p_additional_parameters     VARCHAR2) IS

        CURSOR c IS
             SELECT rowid
             FROM   qa_char_indexes
             WHERE  char_id = p_char_id;

    BEGIN
        INSERT INTO qa_char_indexes(
            created_by,
            creation_date,
            last_updated_by,
            last_update_date,
            last_update_login,
            request_id,
            program_application_id,
            program_id,
            program_update_date,
            char_id,
            enabled_flag,
            index_name,
            default_result_column,
            text,
            additional_parameters)
        VALUES(
            p_created_by,
            p_creation_date,
            p_last_updated_by,
            p_last_update_date,
            p_last_update_login,
            p_request_id,
            p_program_application_id,
            p_program_id,
            p_program_update_date,
            p_char_id,
            p_enabled_flag,
            p_index_name,
            p_default_result_column,
            p_text,
            p_additional_parameters);

        OPEN c;
        FETCH c INTO x_rowid;
        IF SQL%NOTFOUND THEN
            CLOSE c;
            RAISE no_data_found;
        END IF;
        CLOSE c;

    END insert_row;


    PROCEDURE delete_row(p_char_id NUMBER) IS
    --
    -- The delete_row handler differs from the normal standard
    -- a little because this procedure is not designed to be used
    -- by Forms, so it is more efficient to pass in the primary key
    -- than to pass in the rowid.
    -- bso
    --
    BEGIN

        DELETE
        FROM  qa_char_indexes
        WHERE char_id = p_char_id;

        IF SQL%NOTFOUND THEN
            RAISE no_data_found;
        END IF;

    END delete_row;


    FUNCTION drop_index(p_char_id NUMBER) RETURN INTEGER IS
    --
    -- Main function to drop an index.  If successful, the index record in
    -- qa_char_indexes table is also deleted to register the fact.
    --
    -- Return 0 if successful, a negative error code if not.
    --
    -- Because this is a DDL, by definition a commit is
    -- performed inherently.
    --
        l_index_name VARCHAR2(30);
        l_ddl VARCHAR2(100);
        CURSOR c IS
            SELECT index_name
            FROM   qa_char_indexes
            WHERE  char_id = p_char_id;
    BEGIN
        SAVEPOINT l_drop_index;

        OPEN c;
        FETCH c INTO l_index_name;
        IF c%notfound THEN
            CLOSE c;
            RETURN err_drop_index;
        END IF;
        CLOSE c;

        BEGIN
            --
            -- Table operation is performed before DDL by design
            -- so that the database commit inherent in the DDL
            -- will commit the data in sync.
            --
            delete_row(p_char_id);

            EXCEPTION
                WHEN OTHERS THEN
                    RETURN err_delete_row;
        END;

        l_ddl := 'DROP INDEX ' || g_qa_schema || '.' ||
            '"' || l_index_name || '"';

        ad_ddl.do_ddl(
            applsys_schema => g_fnd_schema,
            application_short_name => g_qa,
            statement_type => ad_ddl.drop_index,
            statement => l_ddl,
            object_name => l_index_name);

        RETURN 0;

        EXCEPTION
            WHEN OTHERS THEN
                ROLLBACK TO l_drop_index;
                RETURN err_drop_index;

    END drop_index;


    FUNCTION create_or_regenerate_index(
        p_char_id NUMBER,
        p_index_name VARCHAR2,
        p_additional_parameters VARCHAR2)
        RETURN INTEGER IS
    --
    -- Main function to create or regenerate index.
    -- If an index already exists, then it is dropped before
    -- creating.  If an index is created or regenerated
    -- successfully, then the qa_char_indexes table is
    -- updated with that fact.
    --
    -- Return 0 if successful, a negative error code if not.
    --
    -- Because this is a DDL, by definition a commit is
    -- performed inherently.
    --
        l_status INTEGER;

    BEGIN

        SAVEPOINT l_create_index;

        --
        -- A safeguard against dropping Quality's own indexes.
        --
        IF substr(p_index_name, 1, 3) = 'QA_' THEN
            RETURN err_index_name;
        END IF;

        IF index_exists(p_char_id) = 1 THEN
            l_status := drop_index(p_char_id);
            IF l_status <> 0 THEN
                RETURN l_status;
            END IF;
        END IF;

        --
        -- Simple check to make sure p_char_id is a softcoded element.
        --
        IF qa_chars_api.hardcoded_column(p_char_id) IS NOT NULL THEN
            RETURN err_unsupported_element_type;
        END IF;

        l_status := create_softcoded_index(
            p_char_id => p_char_id,
            p_alias => '',
            p_index_name => p_index_name,
            p_additional_parameters => p_additional_parameters);
        IF l_status <> 0 THEN
            ROLLBACK TO l_create_index;
            RETURN l_status;
        END IF;

        RETURN 0;

        EXCEPTION
            WHEN OTHERS THEN
                ROLLBACK TO l_create_index;
                RETURN err_insert_row;

    END create_or_regenerate_index;


    PROCEDURE get_predicate(
        p_char_id NUMBER,
        p_alias VARCHAR2,
        x_predicate OUT NOCOPY VARCHAR2) IS

        l_predicate VARCHAR2(32767);

        -- Bug 4086800. A CLOB value cannot be fetched directly
        -- into a VARCHAR2 variable prior to 9i. Hence the below
        -- cursor needs to be modified to be compatible across
        -- database versions. Used the dbms_lob package routines
        -- for varchar2 conversions. kabalakr.

        CURSOR c IS
            SELECT dbms_lob.substr(text, dbms_lob.getlength(text), 1)
            FROM   qa_char_indexes
            WHERE  char_id = p_char_id AND enabled_flag = 1;

    BEGIN
        OPEN c;
        FETCH c INTO l_predicate;
        IF c%notfound THEN
            CLOSE c;
            x_predicate := NULL;
        ELSE
            CLOSE c;

            IF p_alias IS NOT NULL THEN
                l_predicate := replace(replace(l_predicate,
                    'PLAN_ID', p_alias || '.PLAN_ID'),
                    'CHARACTER', p_alias || '.CHARACTER');
            END IF;

            x_predicate := l_predicate;
        END IF;

        EXCEPTION
            WHEN OTHERS THEN
                x_predicate := NULL;

    END get_predicate;


    PROCEDURE wrapper(
        errbuf    OUT NOCOPY VARCHAR2,
        retcode   OUT NOCOPY NUMBER,
        argument1            VARCHAR2,
        argument2            VARCHAR2,
        argument3            VARCHAR2,
        argument4            VARCHAR2) IS

    --
    -- Wrapper procedure to create or drop the index.
    -- This procedure is the entry point for this package
    -- through the concurrent program 'Manage Collection
    -- element indexes'. This wrapper procedure is attached
    -- to the QAINDEX executable.
    -- argument1 -> Index Action : 'Create or Regenerate' OR 'Drop'.
    -- argument2 -> Proposed or New Index name.
    -- argument3 -> Softcoded Plan element on which Index action
    --              will be executed.
    -- argument4 -> Additional Parameters specified by the user
    --              when creating the index.
    --

       l_type_of_action   NUMBER;
       l_char_id          NUMBER;
       l_return           NUMBER;

    BEGIN

       fnd_file.put_line(fnd_file.log, 'qa_char_indexes_pkg: entered the wrapper');

       l_type_of_action := to_number(argument1);
       l_char_id := to_number(argument3);

       IF l_type_of_action = 1 THEN
          fnd_file.put_line(fnd_file.log, 'Create or Regnerate the Index');

          l_return := create_or_regenerate_index(
             p_char_id                => l_char_id,
             p_index_name             => argument2,
             p_additional_parameters  => argument4);

          IF (l_return = 0) THEN
             fnd_file.put_line(fnd_file.log, 'Index successfully created');
             errbuf := '';
             retcode := 0;
          ELSE
             fnd_file.put_line(fnd_file.log, 'Index creation failed. ERROR:'||to_char(l_return));
             errbuf := 'ERROR:'||to_char(l_return);
             retcode := 2;
          END IF;


       ELSIF (l_type_of_action = 2) THEN
          fnd_file.put_line(fnd_file.log, 'Drop the Index');

          l_return := drop_index(
             p_char_id => l_char_id);

          IF (l_return = 0) THEN
             fnd_file.put_line(fnd_file.log, 'Index successfully dropped');
             errbuf := '';
             retcode := 0;
          ELSE
             fnd_file.put_line(fnd_file.log, 'Index failed to drop. ERROR:'||to_char(l_return));
             errbuf := 'ERROR:'||to_char(l_return);
             retcode := 2;
          END IF;
       END IF;

       fnd_file.put_line(fnd_file.log, 'qa_char_indexes_pkg: exiting the wrapper');

    END wrapper;


    FUNCTION get_index_predicate(
        p_char_id NUMBER,
        p_alias VARCHAR2)
        RETURN VARCHAR2 IS

    -- This function acts as a wrapper to the get_predicate procedure.
    -- The requirement is from QWB Advanced Search, where we need to
    -- model the VO with the get_predicate().

        l_predicate VARCHAR2(32767);

    BEGIN

        -- This is just a wrapper to get_predicate() procedure.
        -- No validations in this function.

        get_predicate(p_char_id   => p_char_id,
                      p_alias     => p_alias,
                      x_predicate => l_predicate);

        RETURN l_predicate;

    END get_index_predicate;


    --
    -- Bug 3930666.  This bug does not impact this
    -- current package.  But it is most efficient to
    -- fix it by exposing a new function to the public
    -- which is a combination of varchar2s_to_varchar2
    -- and construct_decode_function of this package.
    -- To be used in qlthrb.plb.
    -- bso Tue Apr  5 17:24:07 PDT 2005
    --
    FUNCTION get_decode_function(
        p_char_id NUMBER,
        p_alias VARCHAR2 DEFAULT NULL)
        RETURN VARCHAR2 IS

        l_most_common VARCHAR2(30);
        l_function dbms_sql.varchar2s;
        l_predicate VARCHAR2(32767);
        l_status NUMBER;

    BEGIN
        l_status := construct_decode_function(p_char_id,
            p_alias, l_most_common, l_function);

        IF l_status <> 0 THEN
            RETURN '';
        END IF;

        l_status := varchar2s_to_varchar2(l_function, l_predicate);
        IF l_status <> 0 THEN
            RETURN '';
        END IF;

        RETURN l_predicate;

    END get_decode_function;

BEGIN

    g_dummy := fnd_installation.get_app_info(
        application_short_name => g_fnd,
        status => g_status,
        industry => g_industry,
        oracle_schema => g_fnd_schema);

    g_dummy := fnd_installation.get_app_info(
        application_short_name => g_qa,
        status => g_status,
        industry => g_industry,
        oracle_schema => g_qa_schema);

END qa_char_indexes_pkg;

/
