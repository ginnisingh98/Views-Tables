--------------------------------------------------------
--  DDL for Package Body PAYWSDYG_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PAYWSDYG_PKG" AS
-- $Header: pydygpkg.pkb 120.2.12010000.1 2008/07/27 22:28:37 appldev ship $
--
-- +---------------------------------------------------------------------------+
-- | Global Constants                                                          |
-- +---------------------------------------------------------------------------+
  g_package varchar2(80) := 'paywsdyg_pkg';
  --
  -- The end-of-line character to use in generated PL/SQL
  --
  g_eol CONSTANT VARCHAR2(10) := fnd_global.newline;

  -- A quick command for formatting ease, end of section.
  --
  g_eos CONSTANT VARCHAR2(10) := g_eol||g_eol||'--'||g_eol;



-- To store the dynamic triggers as a package use array so as to overcome
-- the limit of 32767
g_dyt_pkg_head    dbms_sql.varchar2s;
g_dyt_pkg_body    dbms_sql.varchar2s;
g_dyt_pkg_hindex number := 0;
g_dyt_pkg_bindex number := 0;

-- Global for PAY schema name
g_pay_schema  varchar2(30) := null;

--
-- +---------------------------------------------------------------------------+
-- | NAME       : init_dyt_pkg                                                 |
-- | SCOPE      : PRIVATE                                                      |
-- | DESCRIPTION: The dynamic generation will build up code and store it in an |
-- |       an array of varchar2(32767).  Before starting these global place-   |
-- |       holders will need to be emptied and indexes reset.  This is what is |
-- |       done here.                                                          |
-- | PARAMETERS : none                                                         |
-- | RETURNS    : None, simply clears global placeholder                       |
-- | RAISES     : None                                                         |
-- +---------------------------------------------------------------------------+

procedure init_dyt_pkg is
  l_index      number := 0;
  l_proc varchar2(30) := g_package||'.init_dyt_pkg';
begin
  hr_utility.set_location(l_proc,10);

  -- delete all elements from package head pl/sql table.
  l_index   := g_dyt_pkg_head.first;
  while l_index is not null loop
    g_dyt_pkg_head.delete(l_index);
    l_index := g_dyt_pkg_head.next(l_index);
  end loop;
  -- delete all elements from package body pl/sql table.
  l_index   := g_dyt_pkg_body.first;
  while l_index is not null loop
    g_dyt_pkg_body.delete(l_index);
    l_index := g_dyt_pkg_body.next(l_index);
  end loop;

  --initialize the index
  g_dyt_pkg_hindex := 0;
  g_dyt_pkg_bindex := 0;

  hr_utility.set_location(l_proc,900);
exception
  when others then
    hr_utility.trace('Unhandled Error: '||l_proc);
    hr_utility.set_location(l_proc,1000);
     raise;
end init_dyt_pkg;

--
-- +---------------------------------------------------------------------------+
-- | NAME       : add_to_dyt_pkg                                               |
-- | SCOPE      : PRIVATE                                                      |
-- | DESCRIPTION: The dynamic generation will build up code and store it in an |
-- |       an array of varchar2(32767).  The task of this procedure is to split|
-- |       the above array elements into array elements of size 254. This is   |
-- |       required so as to the package body of more than 32 K size can be    |
-- |       parsed using dbms_sql procedure.                                    |
-- | PARAMETERS : p_new_code_tbl - A big fat table containing rows of new code |
-- |              p_body       - Flag, false => package header, true => body   |
-- | RETURNS    : None, simply sets global placeholder                         |
-- | RAISES     : None                                                         |
-- +---------------------------------------------------------------------------+

procedure add_to_dyt_pkg
(
 p_new_code_tbl  t_varchar2_32k_tbl
 ,p_body BOOLEAN
) is

 l_code_index    number := p_new_code_tbl.first;
  l_line varchar2(254);
  l_start number;
  l_end number;
  l_next varchar2(1);
  l_proc varchar2(80) := g_package||'.add_to_dyt_pkg';
begin
  hr_utility.set_location(l_proc,10);
  <<ROW_OF_CODE_LOOP>>
  while l_code_index is not null loop
    l_start := 0;
    -- read the string of the passed on code, chop it into the array element
    -- size of 254 and store it in global package placeholders.
    <<CHAR254_LOOP>>
    while substrb(p_new_code_tbl(l_code_index),l_start,254) is not null LOOP
      l_line := substrb(p_new_code_tbl(l_code_index),l_start ,254);
      -- Find a proposed end point for this set of max 254chars
      l_end := greatest(instr(l_line,' ',-1),instr(l_line,g_eol,-1));

      -- If the next char is ok, or no space/returns at all then we use the max
      --
      l_next := substrb(p_new_code_tbl(l_code_index),l_start + 254 ,1);
      if (l_next = ' ' or l_next = g_eol or l_next is null or l_end = 0) then
        l_end := 254;
      end if;

      --Get correct subset (so not in mid word)
      l_line := substrb(p_new_code_tbl(l_code_index),l_start ,l_end);

      -- add the new code to either header or body as appropriate
      if (p_body) then
        g_dyt_pkg_bindex  :=  g_dyt_pkg_bindex  + 1;
        g_dyt_pkg_body (g_dyt_pkg_bindex) := l_line;
      else
        g_dyt_pkg_hindex  :=  g_dyt_pkg_hindex  + 1;
        g_dyt_pkg_head (g_dyt_pkg_hindex) := l_line;
      end if;
      --
      -- Start next chunk from where we have taken code up to
      l_start := l_start + l_end;
    end loop char254_loop;

    l_code_index := p_new_code_tbl.next(l_code_index);
  end loop row_of_code_loop;
  hr_utility.set_location(l_proc,900);
exception
  when others then
    hr_utility.trace('Unhandled Error: '||l_proc);
    hr_utility.trace(l_proc ||' g_dyt_pkg_hindex - ' ||  g_dyt_pkg_hindex
                            ||' g_dyt_pkg_bindex - ' ||  g_dyt_pkg_bindex );
     raise;
end ADD_TO_DYT_PKG;
--============================================
--
-- +---------------------------------------------------------------------------+
-- | NAME       : insert_parameters                                            |
-- | SCOPE      : PUBLIC                                                       |
-- | DESCRIPTION: Helper procedure to maintain parameters                      |
-- |              Inserts new rows if none exist, otherwise updates the        |
-- |              existing row if it's 'automatic' flag is set to 'Y'or null   |
-- | PARAMETERS : p_usage_type     - Value for the usage_type column           |
-- |              p_usage_id       - Value for the usage_id column             |
-- |              p_parameter_type - Value for the parameter_type column       |
-- |              p_parameter_name - Value for the parameter_name column       |
-- |              p_value_name     - Value for the value_name column           |
-- |              p_automatic      - Value for the automatic column            |
-- | RETURNS    : The primary key of the new or existing row                   |
-- | RAISES     : None                                                         |
-- +---------------------------------------------------------------------------+
  FUNCTION insert_parameters(
    p_usage_type      IN VARCHAR2 DEFAULT NULL,
    p_usage_id        IN NUMBER   DEFAULT NULL,
    p_parameter_type  IN VARCHAR2 DEFAULT NULL,
    p_parameter_name  IN VARCHAR2 DEFAULT NULL,
    p_value_name      IN VARCHAR2 DEFAULT NULL,
    p_automatic       IN VARCHAR2 DEFAULT NULL
  ) RETURN NUMBER IS
    --
    -- Get the next primary key value from the database sequence
    CURSOR get_id IS
      SELECT  pay_trigger_parameters_s.NEXTVAL
      FROM    dual;
    --
    -- Find any existing parameter matching the name, type and usage ID
    CURSOR get_existing(
      cp_id   IN NUMBER,
      cp_type IN VARCHAR2,
      cp_name IN VARCHAR2
    ) IS
      SELECT  parameter_id,automatic
      FROM    pay_trigger_parameters
      WHERE   UPPER(parameter_name)  = UPPER(cp_name)
      AND     usage_type      = cp_type
      AND     usage_id        = cp_id;
    --
    l_rc    NUMBER;
    l_auto  VARCHAR2(1);
    --
  BEGIN
    --
    -- Find any existing parameter
    OPEN get_existing(p_usage_id,p_usage_type,p_parameter_name);
    FETCH get_existing INTO l_rc,l_auto;
    IF get_existing%NOTFOUND THEN
      l_auto := 'X';
    END IF;
    CLOSE get_existing;
    --
    -- If l_auto is 'X' then the parameter doesn't exist
    IF l_auto = 'X' THEN
      --
      -- Get a new primary key
      OPEN get_id;
      FETCH get_id INTO l_rc;
      CLOSE get_id;
      --
      -- Insert the new row
      INSERT INTO pay_trigger_parameters(
        parameter_id,
        usage_type,
        usage_id,
        parameter_type,
        parameter_name,
        value_name,
        automatic
      ) VALUES (
        l_rc,
        p_usage_type,
        p_usage_id,
        p_parameter_type,
        p_parameter_name,
        p_value_name,
        p_automatic
      );
    --
    -- If l_auto is 'Y' then the parameter
    -- can be updated it with new values, if the parameter is not automatic
    -- then the user has modified it in some way so we can't change it
    ELSIF (l_auto = 'Y') THEN
      UPDATE  pay_trigger_parameters
      SET     usage_type      = p_usage_type,
              usage_id        = p_usage_id,
              parameter_type  = p_parameter_type,
              parameter_name  = p_parameter_name,
              value_name      = p_value_name,
              automatic       = p_automatic
      WHERE   parameter_id    = l_rc;
    END IF;
    --
    -- Return the primary key we found or generated
    RETURN l_rc;
  END insert_parameters;
--
-- +---------------------------------------------------------------------------+
-- | NAME       : insert_declarations                                          |
-- | SCOPE      : PRIVATE                                                      |
-- | DESCRIPTION: Simply inserts values into the PAY_TRIGGER_DECLARATIONS table|
-- | PARAMETERS : p_event_id      - The event_id column                        |
-- |              p_variable_name - The variable_name column                   |
-- |              p_data_type     - The data_type column                       |
-- |              p_variable_size - The variable_size column                   |
-- | RETURNS    : Primary key of the inserted row                              |
-- | RAISES     : None                                                         |
-- +---------------------------------------------------------------------------+
  FUNCTION insert_declarations(
    p_event_id      IN NUMBER   DEFAULT NULL,
    p_variable_name IN VARCHAR2 DEFAULT NULL,
    p_data_type     IN VARCHAR2 DEFAULT NULL,
    p_variable_size IN VARCHAR2 DEFAULT NULL
  ) RETURN NUMBER IS
    --
    -- Get the next value from the primary key sequence
    CURSOR get_id IS
      SELECT  pay_trigger_declarations_s.NEXTVAL
      FROM    dual;
    --
    l_rc NUMBER;
    --
  BEGIN
    --
    -- Fetch the new primary key
    OPEN get_id;
    FETCH get_id INTO l_rc;
    CLOSE get_id;
    --
    -- Insert the new row
    INSERT INTO pay_trigger_declarations(
			declaration_id,
			event_id,
			variable_name,
			data_type,
			variable_size
		) VALUES (
			l_rc,
			p_event_id,
			p_variable_name,
			p_data_type,
			p_variable_size
		);
		--
		-- Return the new primary key
		RETURN l_rc;
	END insert_declarations;
--
-- +---------------------------------------------------------------------------+
-- | NAME       : insert_initialisations                                       |
-- | SCOPE      : PRIVATE                                                      |
-- | DESCRIPTION: Just inserts a new row into the initialisations table        |
-- | PARAMETERS : p_event_id      - Value for the event_id column              |
-- |              p_process_order - Value for the process_order column         |
-- |              p_plsql_code    - Value for the plsql_code column            |
-- |              p_process_type  - Value for the process_type column          |
-- | RETURNS    : Primary key of the new row                                   |
-- | RAISES     : None                                                         |
-- +---------------------------------------------------------------------------+
  FUNCTION insert_initialisations(
			p_event_id        IN NUMBER DEFAULT NULL,
			p_process_order   IN NUMBER DEFAULT NULL,
			p_plsql_code      IN VARCHAR2 DEFAULT NULL,
			p_process_type    IN VARCHAR2 DEFAULT NULL
  ) RETURN NUMBER IS
    --
    -- Fetch the next primary key value from the database sequence
    CURSOR get_id IS
      SELECT  pay_trigger_initialisations_s.NEXTVAL
      FROM    dual;
    --
    l_rc NUMBER;
    --
  BEGIN
    --
    -- Fetch the primary key value
    OPEN get_id;
    FETCH get_id INTO l_rc;
    CLOSE get_id;
    --
    -- Insert the new row
		INSERT INTO pay_trigger_initialisations(
			initialisation_id,
			event_id,
			process_order,
			plsql_code,
			process_type
		) VALUES (
			l_rc,
			p_event_id,
			p_process_order,
			p_plsql_code,
			p_process_type
		);
		--
		-- Return the new primary key value
		RETURN l_rc;
	END insert_initialisations;
--
-- +---------------------------------------------------------------------------+
-- | NAME       : insert_support                                               |
-- | SCOPE      : PRIVATE                                                      |
-- | DESCRIPTION: Just insert a new row into the supporting package table      |
-- | PARAMETERS : p_event_id    - The value for the event_id column            |
-- |              p_header_code - The value for the header_code column         |
-- |              p_body_code   - The value for the body_code column           |
-- | RETURNS    : The new primary key value                                    |
-- | RAISES     : None                                                         |
-- +---------------------------------------------------------------------------+
  FUNCTION insert_support(
			p_event_id        IN NUMBER DEFAULT NULL,
  		p_header_code     IN VARCHAR2 DEFAULT NULL,
  		p_body_code       IN VARCHAR2 DEFAULT NULL
  ) RETURN NUMBER IS
    --
    -- Fetch the next value from the primary key generating sequence
    CURSOR get_id IS
      SELECT  pay_trigger_support_s.NEXTVAL
      FROM    dual;
    --
    l_rc NUMBER;
    --
  BEGIN
    --
    -- Get a new primary key value
    OPEN get_id;
    FETCH get_id INTO l_rc;
    CLOSE get_id;
    --
    -- Insert the data into the table
  	INSERT INTO pay_trigger_support(
  		support_id,
  		event_id,
  		header_code,
  		body_code
  	) VALUES (
  		l_rc,
  		p_event_id,
  		p_header_code,
  		p_body_code
    );
    --
    -- Return the primary key
    RETURN l_rc;
  END insert_support;
--
-- +---------------------------------------------------------------------------+
-- | NAME       : get_applsys_user                                             |
-- | SCOPE      : PRIVATE                                                      |
-- | DESCRIPTION: Determine the Oracle username that the applsys (FND) user    |
-- |              is created under. Needed for the ad_ddl calls.               |
-- | PARAMETERS : None                                                         |
-- | RETURNS    : The Oracle user name                                         |
-- | RAISES     : NO_DATA_FOUND - If we can't work out who the FND user is     |
-- +---------------------------------------------------------------------------+
  FUNCTION get_applsys_user RETURN VARCHAR2 IS
    --
    -- Fetch the username from foundation (AOL) tables
    CURSOR get_user(cp_appl IN VARCHAR2) IS
      SELECT  fou.oracle_username
      FROM    fnd_oracle_userid         fou,
              fnd_product_installations fpi,
              fnd_application           fa
      WHERE   fou.oracle_id             = fpi.oracle_id
      AND     fpi.application_id        = fa.application_id
      AND     fa.application_short_name = cp_appl;
    --
    l_user    VARCHAR2(30);
    --
  BEGIN
    --
    -- Try to get the username
    -- Raise NO_DATA_FOUND if (surprisingly enough) no data was found
    OPEN get_user('FND');
    FETCH get_user INTO l_user;
    IF get_user%NOTFOUND THEN
      CLOSE get_user;
      RAISE NO_DATA_FOUND;
    END IF;
    CLOSE get_user;
    --
    -- Send back the username
    RETURN l_user;
  END get_applsys_user;
--
-- +---------------------------------------------------------------------------+
-- | NAME       : get_table_product                                            |
-- | SCOPE      : PRIVATE                                                      |
-- | DESCRIPTION: Get the product that a table belongs to (PAY, PER, etc)      |
-- |              needed for calls to ad_ddl                                   |
-- | PARAMETERS : p_table - The name of the table to find                      |
-- | RETURNS    : The product (application) short name                         |
-- | RAISES     : NO_DATA_FOUND - If the table isn't listed as belonging to    |
-- |              any particular application                                   |
-- +---------------------------------------------------------------------------+
  FUNCTION get_table_product(p_table IN VARCHAR2) RETURN VARCHAR2 IS
    --
    -- Get the application short name from the foundation tables
    CURSOR get_table(cp_name IN VARCHAR2) IS
      SELECT  fa.application_short_name
      FROM    fnd_application fa,
              fnd_tables      ft
      WHERE   fa.application_id = ft.application_id
      AND     ft.table_name     = cp_name;
    --
    l_appl VARCHAR2(50);
    --
  BEGIN
    --
    -- Fetch the data, crash and burn if none was found
    OPEN get_table(p_table);
    FETCH get_table INTO l_appl;
    IF get_table%NOTFOUND THEN
      CLOSE get_table;
      RAISE NO_DATA_FOUND;
    END IF;
    CLOSE get_table;
    --
    -- Send back the application short name
    RETURN l_appl;
  END get_table_product;
--
-- +---------------------------------------------------------------------------+
-- | NAME       : get_table_from_trigger                                       |
-- | SCOPE      : PRIVATE                                                      |
-- | DESCRIPTION: Find out which table a specified trigger belongs to,         |
-- |              we need this 'cos the trigger name sort of contains the      |
-- |              table name but we mangle it up a bit to fit it in.           |
-- | PARAMETERS : p_trigger - The name of the trigger                          |
-- | RETURNS    : The table name                                               |
-- | RAISES     : NO_DATA_FOUND if the trigger name is bobbins so we couldn't  |
-- |              find the table                                               |
-- +---------------------------------------------------------------------------+
  FUNCTION get_table_from_trigger(p_trigger IN VARCHAR2) RETURN VARCHAR2 IS
    --
    -- Fetch the table name from from RDBMS data dictionary views
    CURSOR get_trigger(cp_name IN VARCHAR2) IS
      SELECT  atr.table_name
      FROM    user_triggers atr
      WHERE   trigger_name = cp_name;
    --
    l_tabl VARCHAR2(50);
    --
  BEGIN
    --
    -- Get the data, spoon up if we couldn't find the table
    OPEN get_trigger(p_trigger);
    FETCH get_trigger INTO l_tabl;
    IF get_trigger%NOTFOUND THEN
      CLOSE get_trigger;
      RAISE NO_DATA_FOUND;
    END IF;
    CLOSE get_trigger;
    --
    -- Send back the table name
    RETURN l_tabl;
  END get_table_from_trigger;
--
-- +---------------------------------------------------------------------------+
-- | NAME       : get_trigger_name                                             |
-- | SCOPE      : PUBLIC                                                       |
-- | DESCRIPTION: See Header                                                   |
-- +---------------------------------------------------------------------------+
  FUNCTION get_trigger_name(
    p_id IN NUMBER,
    p_table IN VARCHAR2,
    p_action IN VARCHAR2
  ) RETURN VARCHAR2 IS
    --
    l_newtab VARCHAR2(30);
    l_id     VARCHAR2(30);
    --
  BEGIN
    --
    -- The ID portion is the primary key of the event, the triggering action
    -- and the text 'DYT' to mark this as a DYnamically generated Trigger
    l_id := '_'||LTRIM(RTRIM(TO_CHAR(p_id)))||p_action||'_DYT';
    --
    -- The new table name is the original with the underscores removed (so
    -- we can fit more of it in) chopped off so we can fit the ID on the
    -- end
    l_newtab := SUBSTR(REPLACE(p_table,'_'),1,30-LENGTH(l_id));
    --
    -- Concatenate the new table name and the ID for the trigger name
    RETURN (l_newtab||l_id);
  END get_trigger_name;
--
-- +---------------------------------------------------------------------------+
-- | NAME       : trigger_exists                                               |
-- | SCOPE      : PRIVATE                                                      |
-- | DESCRIPTION: Check to see if the specified trigger exists or not          |
-- | PARAMETERS : p_name - The name of the                                     |
-- | RETURNS    : Boolean flag, TRUE if the trigger exists, FALSE otherwise    |
-- | RAISES     : None                                                         |
-- +---------------------------------------------------------------------------+
  FUNCTION trigger_exists(p_name IN VARCHAR2) RETURN BOOLEAN IS
    --
    -- Get trigger information from the Oracle data dictionary
    CURSOR get_trigger(cp_name IN VARCHAR2) IS
      SELECT 'Y'
      FROM   user_triggers
      WHERE  trigger_name = cp_name;
    --
    l_rc VARCHAR2(1);
    --
  BEGIN
    --
    -- Fetch the data, switch the flag manually if the trigger wasn't found
    OPEN get_trigger(p_name);
    FETCH get_trigger INTO l_rc;
    IF get_trigger%NOTFOUND THEN
      l_rc := 'N';
    END IF;
    CLOSE get_trigger;
    --
    -- Send back the boolean version of the flag
    RETURN (l_rc = 'Y');
  END trigger_exists;
--
-- +---------------------------------------------------------------------------+
-- | NAME       : drop_trigger                                                 |
-- | SCOPE      : PUBLIC                                                       |
-- | DESCRIPTION: See header                                                   |
-- +---------------------------------------------------------------------------+
  PROCEDURE drop_trigger(p_name IN VARCHAR2) IS
  BEGIN
    IF trigger_exists(p_name) THEN
      ad_ddl.do_ddl(
        get_applsys_user,
        get_table_product(get_table_from_trigger(p_name)),
        ad_ddl.drop_trigger,
        'DROP TRIGGER '||p_name,
        p_name
      );
    END IF;
  END drop_trigger;
--
-- +---------------------------------------------------------------------------+
-- | NAME       : drop_trigger_indirect                                        |
-- | SCOPE      : PUBLIC                                                       |
-- | DESCRIPTION: See header                                                   |
-- +---------------------------------------------------------------------------+
  PROCEDURE drop_trigger_indirect(p_id IN NUMBER) IS
    --
    CURSOR get_info(cp_id IN NUMBER) IS
      SELECT  table_name,
              triggering_action
      FROM    pay_trigger_events
      WHERE   event_id = cp_id;
    --
    l_table VARCHAR2(30);
    l_mode VARCHAR2(1);
  BEGIN
    OPEN get_info(p_id);
    FETCH get_info INTO l_table,l_mode;
    CLOSE get_info;
    --
    drop_trigger(get_trigger_name(p_id,l_table,l_mode));
  END drop_trigger_indirect;
--
-- +---------------------------------------------------------------------------+
-- | NAME       : create_trigger                                               |
-- | SCOPE      : PUBLIC                                                       |
-- | DESCRIPTION: See header                                                   |
-- +---------------------------------------------------------------------------+
  PROCEDURE create_trigger(
    p_trigger IN VARCHAR2,
    p_table   IN VARCHAR2,
    p_action  IN VARCHAR2,
    p_sql     IN VARCHAR2
  ) IS
    --
    l_mode  VARCHAR2(30) := 'INVALID';
  BEGIN
    IF p_action = 'I' THEN
      l_mode := 'INSERT';
    ELSIF p_action = 'U' THEN
      l_mode := 'UPDATE';
    ELSIF p_action = 'D' THEN
      l_mode := 'DELETE';
    END IF;
    --
    ad_ddl.do_ddl(
      get_applsys_user,
      get_table_product(p_table),
      ad_ddl.create_trigger,
      'CREATE OR REPLACE TRIGGER '||p_trigger||' '||
        'AFTER '||l_mode||' '||
        'ON '||p_table||' FOR EACH ROW '||
        p_sql,
      p_trigger
    );

  END create_trigger;
--
--
-- +---------------------------------------------------------------------------+
-- | NAME       : enable_trigger                                               |
-- | SCOPE      : PUBLIC                                                       |
-- | DESCRIPTION: See header                                                   |
-- +---------------------------------------------------------------------------+
  PROCEDURE enable_trigger(p_trigger IN VARCHAR2,p_enabled IN BOOLEAN) IS
    --
    l_mode VARCHAR2(30);
    --
  BEGIN
    --
    -- Can only do this if the trigger exists
    IF trigger_exists(p_trigger) THEN
      --
      -- Turn the boolean flag into DDL that the database understands
      IF p_enabled THEN
        l_mode := 'ENABLE';
      ELSE
        l_mode := 'DISABLE';
      END IF;
      --
      -- Use AOL calls to do the DDL 'properly' (although I don't see how you
      -- could do this 'improperly' :-)
      ad_ddl.do_ddl(
        get_applsys_user,
        get_table_product(get_table_from_trigger(p_trigger)),
        ad_ddl.alter_trigger,
        'ALTER TRIGGER '||p_trigger||' '||l_mode,
        p_trigger
      );
    END IF;
  END enable_trigger;
--
-- +---------------------------------------------------------------------------+
-- | NAME       : replace_placeholders                                         |
-- | SCOPE      : PUBLIC                                                       |
-- | DESCRIPTION: See header                                                   |
-- +---------------------------------------------------------------------------+
  PROCEDURE replace_placeholders(
    p_sql IN OUT NOCOPY VARCHAR2,
    p_id IN NUMBER,
    p_extra IN VARCHAR2 DEFAULT NULL
  ) IS
    --
    -- Get the mappings that the user has defined, or have been automatically
    -- generated, only initialisations can use placeholders and placeholders
    -- are always inputs
    CURSOR get_places(cp_id IN NUMBER) IS
      SELECT  parameter_name,
              value_name
      FROM    pay_trigger_parameters
      WHERE   usage_type = 'I'
      AND     parameter_type = 'I'
      AND     usage_id = cp_id;
    --
    l_replace VARCHAR2(60);
    --
  BEGIN
    --
    -- Get all the mappings
    FOR l_rec IN get_places(p_id) LOOP
      l_replace := l_rec.value_name;
      --
      -- Add any extra text (used by the statement verifier)
      IF p_extra IS NOT NULL THEN
        IF SUBSTR(l_replace,1,LENGTH(p_extra)) <> p_extra THEN
          l_replace := p_extra||l_replace;
        END IF;
      END IF;
      --
      -- Modify the SQL statement
      p_sql := REPLACE(p_sql,l_rec.parameter_name,l_replace);
    END LOOP;
  END replace_placeholders;
--
-- +---------------------------------------------------------------------------+
-- | NAME       : map_select_list                                              |
-- | SCOPE      : PRIVATE                                                      |
-- | DESCRIPTION: Describe the supplied SQL select statement, create parameter |
-- |              mappings if the validate only parameter is FALSE             |
-- | PARAMETERS : p_id            - The primary key of the initialisation that |
-- |                                owns this statement                        |
-- |              p_code          - The SQL select statement                   |
-- |              p_validate_only - Set to TRUE if you only want to check that |
-- |                                the SQL is OK.                             |
-- | RETURNS    : None                                                         |
-- | RAISES     : could_not_analyse_query - If the Parse or Describe_Columns   |
-- |                                        calls fail, probably because your  |
-- |                                        SQL statement is pants             |
-- +---------------------------------------------------------------------------+
  PROCEDURE map_select_list(
    p_id            IN NUMBER,
    p_code          IN VARCHAR2,
    p_validate_only IN BOOLEAN DEFAULT FALSE
  ) IS
    --
    l_csr   INTEGER;
    l_cols  INTEGER;
    l_desc  Dbms_Sql.Desc_Tab;
    l_name  VARCHAR2(35);
    l_code  VARCHAR2(32767) := p_code;
    l_rc    NUMBER;
    --
  BEGIN
    --
    -- Open a dynamic SQL cursor for parsing and describing
    l_csr := Dbms_Sql.Open_Cursor;
    --
    -- Replace the placeholders but add a colon to the start of local
    -- variable names (turning them into bind variables) so that the
    -- statement will parse OK
    replace_placeholders(l_code,p_id,':');
    --
    BEGIN
      --
      -- Parse and describe the statement
      Dbms_Sql.Parse(l_csr,l_code,Dbms_Sql.Native);
      Dbms_Sql.Describe_Columns(l_csr,l_cols,l_desc);
      Dbms_Sql.Close_Cursor(l_csr);
    EXCEPTION
      WHEN OTHERS THEN
        --
        -- Turn all errors into one of our custom errors
        Dbms_Sql.Close_Cursor(l_csr);
        fnd_message.set_name('PAY','PAY_DYG_CANNOT_ANALYSE_QUERY');
        app_exception.raise_exception;
    END;
    --
    -- Process all the columns that the Describe told us about
    -- N.B. This DOES NOT WORK CORRECTLY for aliased columns, boo!
    FOR l_cnt IN 1..l_cols LOOP
      l_name := 'l_'||LOWER(l_desc(l_cnt).col_name);
      -- We should probably validate l_name here but not doing it gives
      -- users a bit more flexibility with the way in which they use the form
      --
      IF NOT p_validate_only THEN
        --
        -- If we're not just validating the statement then insert (or update,
        -- see the 'insert_parameters' description) the parameter mapping
        l_rc := insert_parameters(
                  'I',
                  p_id,
                  'R',
                  LOWER(l_desc(l_cnt).col_name),
                  l_name,
                  'Y'
                );
      END IF;
    END LOOP;
    --
  END map_select_list;
--
-- +---------------------------------------------------------------------------+
-- | NAME       : scan_for_placeholders                                        |
-- | SCOPE      : PRIVATE                                                      |
-- | DESCRIPTION: Find the placeholders in the supplied code. Optionally       |
-- |              add default parameter mappings to the parameter table        |
-- | PARAMETERS : p_id            - The primary key of the initialisation that |
-- |                                owns this statement                        |
-- |              p_code          - The SQL or PL/SQL code                     |
-- |              p_validate_only - Set to TRUE if you only want to check that |
-- |                                the statement is OK, i.e. not create maps  |
-- | RETURNS    : None                                                         |
-- | RAISES     : None                                                         |
-- +---------------------------------------------------------------------------+
  PROCEDURE scan_for_placeholders(
    p_id            IN NUMBER,
    p_code          IN VARCHAR2,
    p_type          IN VARCHAR2,
    p_validate_only IN BOOLEAN DEFAULT FALSE
  ) IS
    --
    l_st      NUMBER;
    l_en      NUMBER;
    l_name    VARCHAR2(35);
    l_holder  VARCHAR2(35);
    --
    l_pl      NUMBER := 0;
    l_rc      NUMBER;
    --
  BEGIN
    --
    -- Scan all through the code
    FOR l_cnt IN 1..LENGTH(p_code) LOOP
      --
      -- If we're not currently looking at a placeholder then see if we're on
      -- the start of one and remember the position if we are
      IF l_st IS NULL THEN
        IF  UPPER(SUBSTR(p_code,l_cnt,3)) = '$L_' OR
            UPPER(SUBSTR(p_code,l_cnt,5)) IN ('$OLD_','$NEW_')
        THEN
          l_st := l_cnt;
        END IF;
      ELSE
        --
        -- Otherwise see if we're on the end of the placeholder,
        -- if we are then remember the position
        IF SUBSTR(p_code,l_cnt,1) = '$' THEN
          l_en := l_cnt;
          --
          -- Work out the placeholder name
          l_holder := LOWER(REPLACE(SUBSTR(p_code,l_st,(l_en-l_st)+1),'$'));
          --
          -- Turn the placeholder into the variable name
          IF SUBSTR(l_holder,1,2) = 'l_' THEN
            l_name := l_holder;
          ELSIF SUBSTR(l_holder,1,4) = 'old_' THEN
            l_name := REPLACE(l_holder,'old_',':old.');
          ELSIF SUBSTR(l_holder,1,4) = 'new_' THEN
            l_name := REPLACE(l_holder,'new_',':new.');
          ELSE
            l_name := NULL;
          END IF;
          --
          IF l_name IS NOT NULL THEN
            -- Check that the variable we're going to use in l_value is valid
            -- Might implement this at a later date, the form will work without
            -- it but people can generata code that won't compile
            NULL;
          END IF;
          --
          IF NOT p_validate_only THEN
            --
            -- Create or update the parameter mapping if we don't want to just
            -- validate the code
            l_rc := insert_parameters(
                      'I',
                      p_id,
                      'I',
                      SUBSTR(p_code,l_st,(l_en-l_st)+1),
                      l_name,
                      'Y'
                    );
          END IF;
          l_pl := l_pl + 1;
          --
          -- Null out the starting position 'cos we've just got to the end
          -- of a placeholder, so we'll now look for a new one
          l_st := NULL;
        END IF;
      END IF;
    END LOOP;
    --
    -- If it's an Assignment type initialisation (and we're not just validating
    -- the code) then create a default mapping for the return value.
    IF l_pl = 1 AND l_name IS NOT NULL AND p_type = 'A' THEN
      IF SUBSTR(l_name,1,5) IN (':old.',':new.') THEN
        l_name := 'l_'||SUBSTR(l_name,6);
      ELSE
        l_name := 'return_variable';
      END IF;
      --
      IF NOT p_validate_only THEN
        l_rc := insert_parameters('I',p_id,'R',NULL,l_name,'Y');
      END IF;
    END IF;
    --
  END scan_for_placeholders;
--
-- +---------------------------------------------------------------------------+
-- | NAME       : validate_select                                              |
-- | SCOPE      : PUBLIC                                                       |
-- | DESCRIPTION: See header                                                   |
-- +---------------------------------------------------------------------------+
  PROCEDURE validate_select(
    p_id      IN NUMBER,
    p_code    IN VARCHAR2,
    p_type    IN VARCHAR2
  ) IS
  BEGIN
    -- Should the validate only flag be set on these?
    -- I think it probably should, I'll check that later.
    scan_for_placeholders(p_id,p_code,p_type);
    map_select_list(p_id,p_code);
  END validate_select;
--
-- +---------------------------------------------------------------------------+
-- | NAME       : map_parameter_list                                           |
-- | SCOPE      : PUBLIC                                                       |
-- | DESCRIPTION: See header                                                   |
-- +---------------------------------------------------------------------------+
  PROCEDURE map_parameter_list(
    p_id            IN NUMBER,
    p_module        IN VARCHAR2,
    p_type          IN VARCHAR2,
    p_usage         IN VARCHAR2,
    p_validate_only IN BOOLEAN DEFAULT FALSE
  ) IS
    --
    l_overload    Dbms_Describe.Number_Table;
    l_position    Dbms_Describe.Number_Table;
    l_c_level     Dbms_Describe.Number_Table;
    l_arg_name    Dbms_Describe.Varchar2_Table;
    l_dty         Dbms_Describe.Number_Table;
    l_def_val     Dbms_Describe.Number_Table;
    l_p_mode      Dbms_Describe.Number_Table;
    l_length      Dbms_Describe.Number_Table;
    l_precision   Dbms_Describe.Number_Table;
    l_scale       Dbms_Describe.Number_Table;
    l_radix       Dbms_Describe.Number_Table;
    l_spare       Dbms_Describe.Number_Table;
    --
    l_params      INTEGER := 0;
    l_overloaded  BOOLEAN := FALSE;
    l_weirdtype   BOOLEAN := FALSE;
    l_cackmode    BOOLEAN := FALSE;
    l_name        VARCHAR2(2000);
    l_mode        VARCHAR2(1);
    l_arg         VARCHAR2(60);
    l_rc          NUMBER;
    --
  BEGIN
    BEGIN
      --
      -- Lovely Oracle supplied package to describe a stored procedure
      -- into the tables we declared earlier
      Dbms_Describe.Describe_Procedure(
        p_module,
        null,
        null,
        l_overload,
        l_position,
        l_c_level,
        l_arg_name,
        l_dty,
        l_def_val,
        l_p_mode,
        l_length,
        l_precision,
        l_scale,
        l_radix,
        l_spare
      );
    EXCEPTION
      WHEN OTHERS THEN
      fnd_message.set_name('PAY','PAY_DYG_CANNOT_DESC_MODULE');
      fnd_message.set_token('MODULE_NAME',UPPER(p_module),FALSE);
      app_exception.raise_exception;
    END;
    --
    -- Now we've described the module we'll flip through the parameters
    -- we were told about and check that they're all OK.
    BEGIN
      LOOP
        l_params := l_params + 1;
        --
        -- Set the overloaded flag
        IF l_overload(l_params) > 1 THEN
          l_overloaded := TRUE;
        END IF;
        --
        -- This one uses a type we don't support, flag that up guv'nor
        IF l_dty(l_params) NOT IN (1,2,12) THEN
          l_weirdtype := TRUE;
        END IF;
        --
        -- Complicated bit to check that the parameter's being used in the
        -- right way, here we go;
        --   * IN OUT parameters (l_p_mode = 2) aren't ever allowed
        --   * If it's being used in a function type initialisation
        --     (p_usage = 'I' AND p_type = 'F') and it's an OUT parameter
        --     (l_p_mode = 1) and it's not the return value (l_position = 0)
        --     then it's wrong
        --   * For component usages (p_usage = 'C') OUT parameters
        --     (l_p_mode = 1) aren't ever allowed.
        -- If we find any of these conditions then set the flag
        IF (l_p_mode(l_params) = 2) OR
           (p_usage = 'I' AND
            p_type = 'F'  AND
            l_p_mode(l_params) = 1 AND
            l_position(l_params) <> 0) OR
           (p_usage = 'C' AND l_p_mode(l_params) = 1)
        THEN
          l_cackmode := TRUE;
        END IF;
        --
      END LOOP;
    EXCEPTION
      WHEN NO_DATA_FOUND THEN
        --
        -- The describe procedure doesn't tell us how many rows it
        -- put into the return tables so use this to quit the loop
        -- when we flop over the end of the table
        l_params := l_params - 1;
    END;
    --
    -- Raise an error 'cos we can't deal with overloaded stuff
    IF l_overloaded THEN
      fnd_message.set_name('PAY','PAY_DYG_OVERLOADS_EXIST');
      fnd_message.set_token('MODULE_NAME',UPPER(p_module),FALSE);
      app_exception.raise_exception;
    END IF;
    --
    -- Raise an error 'cos we can't have weird types
    IF l_weirdtype THEN
      fnd_message.set_name('PAY','PAY_DYG_UNSUPPORTED_TYPE');
      fnd_message.set_token('MODULE_NAME',UPPER(p_module),FALSE);
      app_exception.raise_exception;
    END IF;
    --
    -- Raise an error if the parameters are being used in the wrong way
    IF l_cackmode THEN
      fnd_message.set_name('PAY','PAY_DYG_INCOMPATIBLE_MODE');
      fnd_message.set_token('MODULE_NAME',UPPER(p_module),FALSE);
      app_exception.raise_exception;
    END IF;
    --
    -- Set up the default parameter mappings if we didn't just want to validate
    -- the code
    IF NOT p_validate_only THEN
      FOR l_cnt IN 1..l_params LOOP
        --
        -- Is it the return value, or IN or OUT (shake it all about)?
        IF l_position(l_cnt) = 0 THEN
          l_mode := 'R';
        ELSE
          IF l_p_mode(l_cnt) = 0 THEN
            l_mode := 'I';
          ELSIF l_p_mode(l_cnt) = 1 THEN
            l_mode := 'O';
          END IF;
        END IF;
        --
        -- If it's the return value then just create a dummy return that the
        -- user'll have to change, we've got no way of working out a sensible
        -- default mapping for this
        IF l_mode = 'R' THEN
          l_rc := insert_parameters(
                    p_usage,
                    p_id,
                    l_mode,
                    NULL,
                    'return_variable',
                    'Y'
                  );
        ELSE
          l_arg := LOWER(l_arg_name(l_cnt));
          --
          -- Turn the parameter name into a local variable name
          -- or a bind variable.
          -- At some point we should also check that bind variables aren't
          -- being mapped to OUT parameters, but not here.
          IF SUBSTR(l_arg,1,4) = 'p_l_' THEN
            l_name := 'l_'||SUBSTR(l_arg,5);
          ELSIF SUBSTR(l_arg,1,6) = 'p_old_' THEN
            l_name := ':old.'||SUBSTR(l_arg,7);
          ELSIF SUBSTR(l_arg,1,6) = 'p_new_' THEN
            l_name := ':new.'||SUBSTR(l_arg,7);
          ELSE
             l_name := NULL;
          END IF;
          --
          -- Create or update the parameter mapping
          l_rc := insert_parameters(p_usage,p_id,l_mode,l_arg,l_name,'Y');
        END IF;
      END LOOP;
    END IF;
  END map_parameter_list;
--
-- +---------------------------------------------------------------------------+
-- | NAME       : automap_parameters                                           |
-- | SCOPE      : PUBLIC                                                       |
-- | DESCRIPTION: See header                                                   |
-- +---------------------------------------------------------------------------+
  PROCEDURE automap_parameters(
    p_id      IN NUMBER,
    p_usage   IN VARCHAR2,
    p_comp_id IN NUMBER DEFAULT NULL
  ) IS
    --
    -- Get the initialisation we asked for, or all of them if the ID's NULL
    CURSOR get_inits(cp_id IN NUMBER,cp_comp IN NUMBER) IS
      SELECT initialisation_id,
             plsql_code,
             process_type
      FROM   pay_trigger_initialisations
      WHERE  (initialisation_id = cp_comp OR cp_comp IS NULL)
      AND    (event_id = cp_id OR cp_id IS NULL);
    --
    -- Get the component we asked for, or all of them if the ID's NULL
    CURSOR get_comps(cp_id IN NUMBER,cp_comp IN NUMBER) IS
      SELECT component_id,
             module_name
      FROM   pay_trigger_components
      WHERE  (component_id = cp_comp OR cp_comp IS NULL)
      AND    (event_id = cp_id OR cp_id IS NULL);
    --
  BEGIN
    --
    -- We want to map parameters for initialisations
    IF p_usage = 'I' THEN
      FOR init_rec IN get_inits(p_id,p_comp_id) LOOP
        --
        -- Scan SQL select or assignment type initialisations for placeholders
        IF init_rec.process_type IN ('S','A') THEN
          scan_for_placeholders(
            init_rec.initialisation_id,
            init_rec.plsql_code,
            init_rec.process_type
          );
        END IF;
        --
        -- Map the select list of SQL statements
        IF init_rec.process_type = 'S' THEN
          map_select_list(init_rec.initialisation_id,init_rec.plsql_code);
        END IF;
        --
        -- Map the parameter list for function or procedure type initialisations
        IF init_rec.process_type IN ('F','P') THEN
          map_parameter_list(
            init_rec.initialisation_id,
            init_rec.plsql_code,
            init_rec.process_type,
            'I'
          );
        END IF;
        --
      END LOOP;
    END IF;
    --
    -- If we want to map the parameters of component modules...
    IF p_usage = 'C' THEN
      FOR comp_rec IN get_comps(p_id,p_comp_id) LOOP
        --
        -- They're always procedures, so we always need to map the parameters
        map_parameter_list(comp_rec.component_id,comp_rec.module_name,'P','C');
      END LOOP;
    END IF;
  END automap_parameters;
--
-- +---------------------------------------------------------------------------+
-- | NAME       : lob_to_varchar2                                              |
-- | SCOPE      : PUBLIC                                                       |
-- | DESCRIPTION: See header                                                   |
-- +---------------------------------------------------------------------------+
  FUNCTION lob_to_varchar2(p_clob IN OUT NOCOPY CLOB) RETURN VARCHAR2 IS
    l_vc2 VARCHAR2(32767);
    l_s BINARY_INTEGER;
  BEGIN
    --
    -- Use the supplied package to read the data out of the CLOB and dump it
    -- into a VARCHAR2, which are easier to manipulate.
    -- N.B. CLOBs can hold something like 2Gb, this VARCHAR2 can only hold
    --      about 32Kb. Ooer. Shouldn't really be a problem, 32Kb is quite
    --      a big bit of PL/SQL, just don't put millions of comments in :-)
	  Dbms_Lob.Open(p_clob,Dbms_Lob.Lob_Readonly);
 		l_s := Dbms_Lob.Getlength(p_clob);
 		Dbms_Lob.Read(p_clob,l_s,1,l_vc2);
	  Dbms_Lob.Close(p_clob);
	  --
	  -- Send back the text
	  RETURN l_vc2;
	END lob_to_varchar2;
--
-- +---------------------------------------------------------------------------+
-- | NAME       : get_reverted                                                 |
-- | SCOPE      : PUBLIC                                                       |
-- | DESCRIPTION: See header                                                   |
-- +---------------------------------------------------------------------------+
  PROCEDURE get_reverted(
    p_id    IN     NUMBER,
    p_head     OUT NOCOPY VARCHAR2,
    p_body     OUT NOCOPY VARCHAR2
  ) IS
    --
    -- Fetch the last saved version of the code from the database table
  	CURSOR get_old(cp_id IN NUMBER) IS
  		SELECT	header_code,body_code
  		FROM		pay_trigger_support
  		WHERE		support_id = cp_id;
  	--
  	l_h CLOB;
  	l_b CLOB;
  	--
  BEGIN
    --
    -- Grab the data into the two CLOBS
		OPEN get_old(p_id);
  	FETCH get_old INTO l_h,l_b;
		CLOSE get_old;
		--
		-- Turn the CLOBs into VARCHAR2s to send them back. Forms went all weird
		-- when I tried to pass CLOBs back and forth, something to do with RPC
		-- (or whatever it's called) perchance?
	  p_head := lob_to_varchar2(l_h);
	  p_body := lob_to_varchar2(l_b);
	  --
  END get_reverted;
--
-- +---------------------------------------------------------------------------+
-- | NAME       : get_package_name                                             |
-- | SCOPE      : PRIVATE                                                      |
-- | DESCRIPTION: Use this so that the supporting package name is always       |
-- |              generated the same way                                       |
-- | PARAMETERS : p_event - The primary key of the event that this supporting  |
-- |                        package supports                                   |
-- |              p_table - The table that the owning trigger will get created |
-- |                        against (to save us having to work it out)         |
-- | RETURNS    : The generated package name that should be used               |
-- | RAISES     : None                                                         |
-- +---------------------------------------------------------------------------+
  FUNCTION get_package_name(
    p_event IN NUMBER,
    p_table IN VARCHAR2
  ) RETURN VARCHAR2 IS
    --
    l_newtab VARCHAR2(30);
    l_id     VARCHAR2(30);
    --
  BEGIN
    --
    -- The ID will be the event's primary key followed by 'DYG' to denote
    -- that the package has been DYnamically Generated
    l_id := '_'||LTRIM(RTRIM(TO_CHAR(p_event)))||'_DYG';
    --
    -- Fiddle about with the table name in a similar fashion to what we do
    -- when we're creating a trigger name
    l_newtab := SUBSTR(REPLACE(p_table,'_'),1,30-LENGTH(l_id));
    --
    -- Send back the two bits joined together
    RETURN LOWER(l_newtab||l_id);
  END get_package_name;
--
-- +---------------------------------------------------------------------------+
-- | NAME       : drop_package                                                 |
-- | SCOPE      : PRIVATE                                                      |
-- | DESCRIPTION: Drop the specified database package                          |
-- | PARAMETERS : p_table - The table that the owning event's trigger will be  |
-- |                        created against, needed so we can work out what    |
-- |                        application (PAY, PER) the trigger belongs to      |
-- |              p_name  - The name of the package                            |
-- | RETURNS    : None                                                         |
-- | RAISES     : None                                                         |
-- +---------------------------------------------------------------------------+
  PROCEDURE drop_package(p_table IN VARCHAR2,p_name IN VARCHAR2) IS
  BEGIN
    --
    -- Use the AOL DLL routine
    ad_ddl.do_ddl(
      get_applsys_user,
      get_table_product(p_table),
      ad_ddl.drop_package,
      'DROP PACKAGE '||p_name,
      p_name
    );
  EXCEPTION
    WHEN OTHERS THEN
      --
      -- This shouldn't ever occur 'cos do_ddl seems to trap everything
      hr_utility.set_location('DROP PACKAGE '||p_name,ABS(SQLCODE));
  END drop_package;
--
  FUNCTION module_ok(p_name IN VARCHAR2,p_type IN VARCHAR2) RETURN BOOLEAN IS
    --
    CURSOR get_errors(cp_name IN VARCHAR2,cp_type IN VARCHAR2) IS
      SELECT  'SOME'
      FROM    user_errors
      WHERE   name = UPPER(cp_name)
      AND     type = cp_type;
    --
    l_cnt   VARCHAR2(10);
    --
  BEGIN
    --
    -- Try and fetch some errors
    OPEN get_errors(UPPER(p_name),p_type);
    FETCH get_errors INTO l_cnt;
    IF get_errors%NOTFOUND THEN
      l_cnt := 'NONE';
    END IF;
    CLOSE get_errors;
    --
    RETURN (l_cnt = 'NONE');
  END module_ok;

-- -------------------- build_dyt_pkg_from_tbl ----------------------------
-- Description:
-- Runs a SQL statement using the dbms_sql package. No bind variables
-- allowed. This procedure uses pl/sql table of varchar2 as an input
-- and hence is suitable to compile very large packages i.e more than
-- 32767 char.
-- ------------------------------------------------------------------------
procedure build_dyt_pkg_from_tbl(
                  p_package_body    dbms_sql.varchar2s,
                  p_package_index   number,
                  p_body            boolean )
is
  l_csr_sql integer;
  l_rows    number;
  l_proc varchar2(80) := g_package||'.build_dyt_pkg_from_tbl';

begin
  hr_utility.set_location(l_proc,10);
  hr_utility.trace('p_package_index - '||p_package_index);

  --
  l_csr_sql := dbms_sql.open_cursor;
  dbms_sql.parse( l_csr_sql, p_package_body,1,p_package_index,p_body, dbms_sql.v7 );
  l_rows := dbms_sql.execute( l_csr_sql );
  dbms_sql.close_cursor( l_csr_sql );
  --

  hr_utility.set_location(l_proc,900);
exception
  when others then
    hr_utility.trace('Unhandled Exception: '||l_proc);
     raise;
end build_dyt_pkg_from_tbl;

--
-- +---------------------------------------------------------------------------+
-- | NAME       : execute_by_chopping_up                                       |
-- | SCOPE      : PRIVATE                                                      |
-- | DESCRIPTION: We store the supporting packages as CLOBs (which get         |
-- |              converted back and forth into VARCHAR2s when we need to) but |
-- |              the AOL routine to create a package needs it in a PL/SQL     |
-- |              table. This routine chops up the package code, sticks it into|
-- |              the right kind of table and creates the package.             |
-- | PARAMETERS : p_name  - The name of the package to create, the AOL create  |
-- |                        routine seems to trap all the errors so we need    |
-- |                        this to check for errors                           |
-- |              p_table - The table that the owning event's trigger will be  |
-- |                        created against, needed to work out what product   |
-- |                        this package belongs to                            |
-- |              p_sql   - The PL/SQL package creation code                   |
-- |              p_body  - A flag, 'TRUE' if this is the body, else 'FALSE'   |
-- | RETURNS    : Flag to indicate whether the code compiled OK or not         |
-- | RAISES     : None                                                         |
-- +---------------------------------------------------------------------------+
  FUNCTION execute_by_chopping_up(
    p_name  IN VARCHAR2,
    p_table IN VARCHAR2,
    p_sql   IN VARCHAR2,
    p_body  IN VARCHAR2
  ) RETURN BOOLEAN IS
    --
    l_num   NUMBER := 1;
    l_pos   NUMBER := 1;
    l_offs  NUMBER := 1;
    l_line  VARCHAR2(254);
    l_user  VARCHAR2(30) := get_applsys_user;
    l_prod  VARCHAR2(50) := get_table_product(p_table);
    l_type  VARCHAR2(20);
    --
  BEGIN
    --
    -- Loop round all the code
    LOOP
      --
      -- Find the next end of line (relies on lines being less than 254
      -- characters long :-) or just use whatever's left in the string
      l_pos := INSTR(p_sql,g_eol,l_offs);
      IF l_pos > 0 THEN
        l_line := SUBSTR(p_sql,l_offs,l_pos-l_offs);
        l_offs := l_pos + 1;
      ELSE
        l_line := SUBSTR(p_sql,l_offs);
        l_offs := LENGTH(p_sql) + 1;
      END IF;
      --
      -- Shove the line we found into the PL/SQL table
      ad_ddl.build_package(l_line,l_num);
      l_num := l_num + 1;
      --
      -- Bail when we're past the end of the string
      EXIT WHEN l_offs > LENGTH(p_sql);
    END LOOP;
    --
    -- Call the AOL routine to create the package in the 'right' way
    ad_ddl.create_package(
      l_user,
      l_prod,
      UPPER(p_name),
      p_body,
      1,
      l_num - 1
    );
    --
    -- Tell the caller whether the procedure created OK or not
    IF p_body = 'TRUE' THEN
      l_type := 'PACKAGE BODY';
    ELSE
      l_type := 'PACKAGE';
    END IF;
    --
    RETURN (module_ok(p_name,l_type));
  END execute_by_chopping_up;
--
-- +---------------------------------------------------------------------------+
-- | NAME       : compile_package                                              |
-- | SCOPE      : PUBLIC                                                       |
-- | DESCRIPTION: See header                                                   |
-- +---------------------------------------------------------------------------+
  PROCEDURE compile_package(
    p_event   IN            NUMBER,
    p_table   IN            VARCHAR2,
    p_header  IN            VARCHAR2,
    p_body    IN            VARCHAR2,
    p_name    IN OUT NOCOPY VARCHAR2,
    p_head_ok IN OUT NOCOPY BOOLEAN,
    p_body_ok IN OUT NOCOPY BOOLEAN
  ) IS
    l_sql VARCHAR2(32767);
  BEGIN
    --
    -- Get the name of the package according to the standard
    p_name := get_package_name(p_event,p_table);
    --
    -- Make up the full CREATE statement then execute using the AOL routines
    l_sql := 'CREATE OR REPLACE PACKAGE '||
              p_name||' AS '||g_eol||p_header||g_eol||
             'END '||p_name||';';
    p_head_ok := execute_by_chopping_up(p_name,p_table,l_sql,p_body=>'FALSE');
    p_body_ok := p_head_ok;
    --
    -- Make up the full BODY CREATE statement then execute using the AD routines
    IF p_head_ok THEN
      l_sql := 'CREATE OR REPLACE PACKAGE BODY '||
                p_name||' AS '||g_eol||p_body||g_eol||
               'END '||p_name||';';
      p_body_ok := execute_by_chopping_up(p_name,p_table,l_sql,p_body=>'TRUE');
    END IF;
    --
  END compile_package;
--
-- +---------------------------------------------------------------------------+
-- | NAME       : table_has_business_group                                     |
-- | SCOPE      : PUBLIC                                                       |
-- | DESCRIPTION: See header                                                   |
-- +---------------------------------------------------------------------------+
  FUNCTION table_has_business_group(p_table IN VARCHAR2) RETURN BOOLEAN IS
    --
    -- Cursor to fetch the nullable flag
  	CURSOR get_null(cp_table IN VARCHAR2) IS
  		SELECT	atc.nullable
  		FROM		all_tab_columns atc
  		WHERE		atc.column_name = 'BUSINESS_GROUP_ID'
  		AND		atc.table_name  = p_table
                AND             atc.owner       = g_pay_schema;
    --
  	l_rc	VARCHAR2(1);
  BEGIN
    --
    -- Fetch Schema name if required
    --
    g_pay_schema := get_table_owner(p_table);
    --
    -- Fetch column information from the RDBMS data dictionary
  	OPEN get_null(p_table);
  	FETCH get_null INTO l_rc;
  	IF get_null%NOTFOUND THEN
  		l_rc := 'Y';
  	END IF;
  	CLOSE get_null;
  	--
  	-- Return the boolean equivalent to the NOT NULL flag
  	RETURN (l_rc = 'N');
  END table_has_business_group;
--
-- +---------------------------------------------------------------------------+
-- | NAME       : table_has_payroll                                            |
-- | SCOPE      : PUBLIC                                                       |
-- | DESCRIPTION: See header                                                   |
-- +---------------------------------------------------------------------------+
  FUNCTION table_has_payroll(p_table IN VARCHAR2) RETURN BOOLEAN IS
    --
    -- Cursor to fetch the nullable flag
  	CURSOR get_null(cp_table IN VARCHAR2) IS
  		SELECT	atc.nullable
  		FROM		all_tab_columns atc
  		WHERE		atc.column_name = 'PAYROLL_ID'
  		AND		atc.table_name  = p_table
                AND             atc.owner       = g_pay_schema;
    --
  	l_rc	VARCHAR2(1);
  BEGIN
    --
    -- Fetch Schema name if required
    --
    g_pay_schema := get_table_owner(p_table);
    --
    --
    -- Fetch the nullable flag from the data dictionary
  	OPEN get_null(p_table);
  	FETCH get_null INTO l_rc;
  	IF get_null%NOTFOUND THEN
  		l_rc := 'Y';
  	END IF;
  	CLOSE get_null;
  	--
  	-- Return the boolean equivalent of the NOT NULL flag
  	RETURN (l_rc = 'N');
  END table_has_payroll;
--
-- +---------------------------------------------------------------------------+
-- | NAME       : default_declarations                                         |
-- | SCOPE      : PRIVATE                                                      |
-- | DESCRIPTION: Create the default declaration definitions that a trigger    |
-- |              will need if it's created against a table with a business    |
-- |              group ID or a payroll ID                                     |
-- | PARAMETERS : p_has_bus  - Previously derived flag to indicate the presence|
-- |                           of a manadatory business_group_id in the table  |
-- |              p_has_pay  - Previously derived flag to indicate the presence|
-- |                           of a manadatory payroll_id column in the table  |
-- |              p_event_id - The primary key of the event which will own     |
-- |                           this trigger                                    |
-- | RETURNS    : None                                                         |
-- | RAISES     : None                                                         |
-- +---------------------------------------------------------------------------+
	PROCEDURE default_declarations(
	  p_has_bus   IN BOOLEAN,
	  p_has_pay   IN BOOLEAN,
	  p_event_id IN NUMBER
	) IS
	  l_rc NUMBER;
	BEGIN
	  IF p_has_bus THEN
  		l_rc := insert_declarations(p_event_id,'business_group_id','N');
	  	l_rc := insert_declarations(p_event_id,'legislation_code','C',30);
	  END IF;
	  --
	  IF p_has_pay THEN
	  	l_rc := insert_declarations(p_event_id,'payroll_id','N');
	  END IF;
	END default_declarations;
--
-- +---------------------------------------------------------------------------+
-- | NAME       : default_initialisations                                      |
-- | SCOPE      : PRIVATE                                                      |
-- | DESCRIPTION: Create the default initialisation definitions that a trigger |
-- |              will need if it's created against a table with a business    |
-- |              group ID or a payroll ID                                     |
-- | PARAMETERS : p_has_bus  - Previously derived flag to indicate the presence|
-- |                           of a manadatory business_group_id in the table  |
-- |              p_has_pay  - Previously derived flag to indicate the presence|
-- |                           of a manadatory payroll_id column in the table  |
-- |              p_event_id - The primary key of the event which will own     |
-- |                           this trigger                                    |
-- |              p_type     - The type of trigger, I, U or D for Insert,      |
-- |                           Update or Delete                                |
-- |              p_bus_id   - The primary key of the newly created business   |
-- |                           group id initialisation record                  |
-- |              p_leg_id   - Primary key of new legislation ID initialisation|
-- |                           record                                          |
-- |              p_pay_id   - Primary key of new payroll ID initialisation    |
-- |                           record                                          |
-- | RETURNS    : The primary keys of the newly created initialisation IDs,    |
-- |              via OUT parameters, if there are any, otherwise these values |
-- |              will be NULL                                                 |
-- | RAISES     : None                                                         |
-- +---------------------------------------------------------------------------+
	PROCEDURE default_initialisations(
	  p_has_bus   IN     BOOLEAN,
	  p_has_pay   IN     BOOLEAN,
		p_event_id  IN     NUMBER,
		p_type      IN     VARCHAR2,
		p_bus_id       OUT NOCOPY NUMBER,
		p_leg_id       OUT NOCOPY NUMBER,
		p_pay_id       OUT NOCOPY NUMBER
	) IS
		--
		l_age     VARCHAR2(10);
		--
	BEGIN
    --
    -- Use the :old or :new record depending on the trigger type
		IF p_type = 'D' THEN
			l_age := 'OLD';
		ELSE
			l_age := 'NEW';
		END IF;
		--
    -- Create the business_group_id and legislation_code initialisations if
    -- the table has a mandatory business group ID column
		IF p_has_bus THEN
  		p_bus_id := insert_initialisations(
  		              p_event_id,
  		              -20,
  		              '$'||l_age||'_BUSINESS_GROUP_ID$',
  		              'A'
  		            );
      p_leg_id := insert_initialisations(
                    p_event_id,
                    -10,
                    'SELECT legislation_code '||
                    'FROM per_business_groups '||
                    'WHERE business_group_id = $L_BUSINESS_GROUP_ID$',
                    'S'
                  );
    END IF;
    --
    -- Create the payroll_id initialisation if the table has a manadatory
    -- payroll_id column
		IF p_has_pay THEN
  		p_pay_id := insert_initialisations(
  		          p_event_id,
  		          -30,
  		          '$'||l_age||'_PAYROLL_ID$',
  		          'A'
  		        );
  	END IF;
		--
	END default_initialisations;
--
-- +---------------------------------------------------------------------------+
-- | NAME       : default_parameters                                           |
-- | SCOPE      : PRIVATE                                                      |
-- | DESCRIPTION: Create the parameter mappings for the default modules        |
-- |              belonging to an event (initialisations and components)       |
-- | PARAMETERS : p_event_id - The primary key of the event which will own     |
-- |                           the trigger that needs these parameters         |
-- | RETURNS    : None                                                         |
-- | RAISES     : None                                                         |
-- +---------------------------------------------------------------------------+
	PROCEDURE default_parameters(
		p_event_id IN NUMBER
	) IS
	BEGIN
    --
    -- Simply call the auto-mapper for all modules in this event, nothing
    -- apart from the defaults should have been created at this point
    -- Currently no default components are created so just call the automapper
    -- for initialisations
		automap_parameters(p_event_id,'I',NULL);
	END default_parameters;
--
-- +---------------------------------------------------------------------------+
-- | NAME       : flag_to_boolean                                              |
-- | SCOPE      : PRIVATE                                                      |
-- | DESCRIPTION: Simple helper function to convert a Y/N flag to a boolean    |
-- | PARAMETERS : p_flag - The text flag, should be Y or N                     |
-- | RETURNS    : TRUE if the flag is 'Y', FALSE otherwise                     |
-- | RAISES     : None                                                         |
-- +---------------------------------------------------------------------------+
  FUNCTION flag_to_boolean(p_flag IN VARCHAR2) RETURN BOOLEAN IS
  BEGIN
    -- Could do; IF p_flag = 'Y' THEN... But I think this way's neater
  	RETURN (NVL(p_flag,'N') = 'Y');
  END flag_to_boolean;
--
-- +---------------------------------------------------------------------------+
-- | NAME       : generate_trigger                                             |
-- | SCOPE      : PUBLIC                                                       |
-- | DESCRIPTION: See header                                                   |
-- +---------------------------------------------------------------------------+
  PROCEDURE generate_trigger(
    p_id   IN            NUMBER,
    p_name IN OUT NOCOPY VARCHAR2,
    p_ok      OUT NOCOPY BOOLEAN
  ) IS
  	--
  	-- Cursor to get the information about the trigger from the database
  	CURSOR csr_name(cp_id IN NUMBER) IS
          SELECT pte.table_name,     pte.triggering_action,
                 pte.generated_flag, pte.enabled_flag,
                 pdt.dated_table_id, nvl(pdt.dyn_trigger_type,'T'),
                 pdt.dyn_trigger_package_name
          FROM   pay_dated_tables pdt,
                 pay_trigger_events pte
          WHERE  pte.table_name = pdt.table_name(+)
          AND    pte.event_id = cp_id;
  	--
  	l_table     VARCHAR2(30);
  	l_trigger   VARCHAR2(30);
  	l_action    VARCHAR2(1);
  	l_gen_flag  VARCHAR2(1);
  	l_enb_flag  VARCHAR2(1);
  	l_tab_id    NUMBER;
  	l_dyn_type  VARCHAR2(1);
        l_dyt_pkg   VARCHAR2(80);
  	--
  	l_sql				VARCHAR2(32767);
  	l_rc        NUMBER;
  	--
        l_proc      VARCHAR2(30) := 'generate_trigger';
  BEGIN
    hr_utility.set_location(' Entering: '||l_proc,10);
    --Calling from SINGLE (Dynamic Triggers Form)
    --
    -- Fetch the trigger event information
 	OPEN csr_name(p_id);
 	FETCH csr_name INTO l_table,l_action,
                            l_gen_flag,l_enb_flag,
                            l_tab_id,l_dyn_type,l_dyt_pkg;
 	CLOSE csr_name;
 -- TEST TO SEE HOW USER WISHES TO HANDLE DYN TRIGGERS
 -- Eg Set up to store as db triggers, as package code or both
 -- Added by jford 1-OCT-02 as part of cont calc
 --
    IF (l_dyn_type = 'P' or l_dyn_type = 'B') THEN
      hr_utility.trace('   Handle Dynamic Triggers as Package Style.');
      -- dyn trigger code should be handled as package
      --  >> GENERATE PACKAGE
      -- generate code FOR ALL DYT's ON TABLE eg many dyn_triggers
      gen_dyt_pkg_full_code(l_tab_id,p_ok);
      p_name := l_dyt_pkg;
    ELSE
      -- type is just original 'T' Trigger mechanism so use existing code
      --  >> GENERATE DBMS TRIGGER
      hr_utility.trace('   Handle Dynamic Triggers as Individual Database Trigger Style.');
      -- Get the trigger name in the standard format
        --if weve got an old crap dyt_pkg, then dump it
        if (l_dyt_pkg is not null) then
          drop_package(l_table,l_dyt_pkg);
          update pay_dated_tables set dyn_trigger_package_name = null
          where table_name = l_dyt_pkg and dated_table_id = l_tab_id;
        end if;
 	l_trigger := get_trigger_name(p_id,l_table,l_action);
 	p_name := l_trigger;
  	--
  	-- If we should be generating the trigger then lets do it
  	IF flag_to_boolean(l_gen_flag) THEN
          --
          -- Generate the PL/SQL block that the trigger will use
          generate_code(p_id,l_sql);
          --
          -- Create the trigger using the generated PL/SQL and the AOL routines
    	  create_trigger(l_trigger,l_table,l_action,l_sql);
    	  p_ok := module_ok(l_trigger,'TRIGGER');
          if (p_ok) then
            hr_utility.trace('   Database Trigger '||p_name||' created with success');
          else
            hr_utility.trace('   Database Trigger '||p_name||' created with failure');
            update pay_trigger_events
            set generated_flag = 'N', enabled_flag = 'N'
            where event_id = p_id;
            l_enb_flag := 'N';
          end if;
          --
          -- Enable the new trigger as required
          enable_trigger(l_trigger,flag_to_boolean(l_enb_flag));
	  --
  	ELSE
          --
          -- Otherwise, drop it to make sure it definitely doesn't exist
          drop_trigger(l_trigger);
          p_ok := TRUE;
          hr_utility.trace('   Database Trigger '||p_name||' dropped with success.');
  	  --
  	END IF;
     END IF;

    hr_utility.set_location(' Leaving: '||l_proc,900);
  END generate_trigger;
--
-- +---------------------------------------------------------------------------+
-- | NAME       : compile_package_indirect                                     |
-- | SCOPE      : PUBLIC                                                       |
-- | DESCRIPTION: See header                                                   |
-- +---------------------------------------------------------------------------+
  PROCEDURE compile_package_indirect(p_id IN NUMBER) IS
    --
    -- Cursor to get all we need to know about the event, since we only get
    -- passed the primary key of the support package
    CURSOR get_info(cp_id IN NUMBER) IS
      SELECT  pte.event_id,
              pte.table_name,
              pts.header_code,
              pts.body_code
      FROM    pay_trigger_events pte,
              pay_trigger_support pts
      WHERE   pte.event_id = pts.event_id
      AND     pts.support_id = cp_id;
    --
    l_id      NUMBER;
    l_name    VARCHAR2(30);
    l_pname   VARCHAR2(30);
    l_head_ok BOOLEAN;
    l_body_ok BOOLEAN;
    l_head    CLOB;
    l_body    CLOB;
  BEGIN
    --
    -- Fetch the information we need
    OPEN get_info(p_id);
    FETCH get_info INTO l_id,l_name,l_head,l_body;
    CLOSE get_info;
    --
    -- Compile the package using the direct method, passing the info we found
    compile_package(
      l_id,
      l_name,
      lob_to_varchar2(l_head),
      lob_to_varchar2(l_body),
      l_pname,
      l_head_ok,
      l_body_ok
    );
  EXCEPTION
    WHEN OTHERS THEN
      -- Output a trrace message if we fail
      hr_utility.set_location('COMPILE_PACKAGE_INDIRECT',ABS(SQLCODE));
  END compile_package_indirect;
--
-- +---------------------------------------------------------------------------+
-- | NAME       : create_defaults                                              |
-- | SCOPE      : PUBLIC                                                       |
-- | DESCRIPTION: See header                                                   |
-- +---------------------------------------------------------------------------+
  PROCEDURE create_defaults(p_id IN NUMBER) IS
  	--
  	-- Fetch to get some more information that we need
  	CURSOR csr_name(cp_id IN NUMBER) IS
  		SELECT	pte.table_name,
  		        pte.triggering_action
  		FROM		pay_trigger_events pte
  		WHERE		pte.event_id = cp_id;
  	--
  	l_table 		VARCHAR2(30);
  	l_action    VARCHAR2(1);
  	l_bus_id    NUMBER;
  	l_leg_id    NUMBER;
  	l_pay_id    NUMBER;
  	l_rc        NUMBER;
  	l_has_bus   BOOLEAN;
  	l_has_pay   BOOLEAN;
    --
  BEGIN
    --
    -- Get the additional information
    OPEN csr_name(p_id);
    FETCH csr_name INTO l_table,l_action;
    CLOSE csr_name;
    --
    -- See if the table's got a business group ID and/or a payroll ID
    l_has_bus := table_has_business_group(l_table);
    l_has_pay := table_has_payroll(l_table);
    --
    -- Create the default declarations and initialisations that we need for
    -- a business group or payroll context trigger, then call the automapper
    -- to create the necessary parameter mappings for these initialisations
 		default_declarations(l_has_bus,l_has_pay,p_id);
  	default_initialisations(
  	  l_has_bus,
  	  l_has_pay,
  	  p_id,
  	  l_action,
  	  l_bus_id,
  	  l_leg_id,
  	  l_pay_id
  	);
  	default_parameters(p_id);
  	--
  	-- Insert some dummy code for the support package to give the user a hint
  	-- then compile it (for what it's worth :-)
  	l_rc := insert_support(
  	          p_id,
  	          '/* Add your support package header code here */',
  	          '/* Add your support package body code here */'
  	        );
    compile_package_indirect(l_rc);
  	--
  END create_defaults;
--
-- +---------------------------------------------------------------------------+
-- | NAME       : add_declarations                                             |
-- | SCOPE      : PRIVATE                                                      |
-- | DESCRIPTION: Add the declaration section to the PL/SQL code               |
-- | PARAMETERS : p_id  - The primary key value of the event that the code is  |
-- |                      being generated for                                  |
-- |              p_sql - The current PL/SQL code that the declaration section |
-- |                      will be added to                                     |
-- | RETURNS    : The PL/SQL code with the declaration section added, via the  |
-- |              IN/OUT parameter                                             |
-- | RAISES     : None                                                         |
-- +---------------------------------------------------------------------------+
  PROCEDURE add_declarations(p_id IN NUMBER,p_sql IN OUT NOCOPY VARCHAR2) IS
  	--
  	-- Get all the declarations defined for this event, decoding the type code
  	CURSOR get_decls(cp_id IN NUMBER) IS
  		SELECT 'l_'||variable_name variable_name,
  		       DECODE(data_type,
  		         'C','VARCHAR2',
  		         'D','DATE',
  		         'N','NUMBER'
  		       ) data_type,
  		       data_type data_type_code,
  		       variable_size
  		FROM   pay_trigger_declarations
  		WHERE  event_id = cp_id;
		--
  BEGIN
    --JFORD 15-SEP-03 Due to data inconsistencies the owness is now on the
    --calling code to be responsible for adding the DECLARE keyword
    --
    -- Process all the declarations
  	FOR l_rec IN get_decls(p_id) LOOP
  	  --
  	  -- Add the variable declaration, padding it out with spaces to make the
  	  -- formatting look nice.
  	  p_sql := p_sql||'  '||RPAD(l_rec.variable_name,30)||' '||l_rec.data_type;
          --
  	  IF l_rec.data_type_code = 'C' THEN
  		  p_sql := p_sql||'('||LTRIM(RTRIM(TO_CHAR(l_rec.variable_size)))||')';
  	  END IF;
  	  p_sql := p_sql||';'||g_eol;
  	END LOOP;
  END add_declarations;
--
-- +---------------------------------------------------------------------------+
-- | NAME       : add_initialisations                                          |
-- | SCOPE      : PRIVATE                                                      |
-- | DESCRIPTION: Add the PL/SQL code that will initialise the declarations    |
-- | PARAMETERS : p_id    - The primary key of the event that we are           |
-- |                        generating PL/SQL code for                         |
-- |              p_sql   - The PL/SQL code that will have the initialisation  |
-- |                        code added to it                                   |
-- |              p_table - The table that this trigger will get created on,   |
-- |                        needed to work out which bits of information we    |
-- |                        can send to the functional area checking routine   |
-- | RETURNS    : The modified PL/SQL code with the initialisation section     |
-- |              added via the IN OUT parameter and a flag indicating if any  |
-- |              initialisations were written (not sure this is good practice)|
-- | RAISES     : None                                                         |
-- +---------------------------------------------------------------------------+
	FUNCTION add_initialisations(
	  p_id    IN            NUMBER,
	  p_sql   IN OUT NOCOPY VARCHAR2,
	  p_table IN            VARCHAR2
	) RETURN BOOLEAN IS
  	--
  	-- Cursor to fetch all the initialisations that this event uses
  	CURSOR get_inits(cp_id IN NUMBER) IS
  	  SELECT   initialisation_id,
  	           plsql_code,
  	  	       process_type,
  	  	       process_order
  	  FROM     pay_trigger_initialisations
  	  WHERE		 event_id = cp_id
  	  ORDER BY process_order;
  	--
  	-- Get the name of the variable that the return value of a function or
  	-- assignment will be returned into
  	CURSOR get_outs(cp_id IN NUMBER) IS
  	  SELECT   parameter_name,
  	           value_name
  	  FROM     pay_trigger_parameters
  	  WHERE    parameter_type = 'R'
  	  AND      usage_id = cp_id
  	  AND      usage_type = 'I'
  	  ORDER BY parameter_id;
  	--
  	-- Get the mappings for the parameter list of a function or procedure
  	CURSOR get_parms(cp_id IN NUMBER) IS
  	  SELECT   parameter_name,
  	           value_name
  	  FROM     pay_trigger_parameters
  	  WHERE    parameter_type IN ('I','O')
  	  AND      value_name IS NOT NULL
  	  AND      usage_id = cp_id
  	  AND      usage_type = 'I'
  	  ORDER BY parameter_id;
  	--
  	l_inits BOOLEAN := FALSE;
  	l_fgt   BOOLEAN := FALSE;
		--
  	l_par   VARCHAR2(30);
  	l_val   VARCHAR2(35);
  	l_plsql VARCHAR2(32767);
  	l_sel   VARCHAR2(32767);
  	l_int   VARCHAR2(32767);
  	l_cnt   NUMBER;
  	--
  	l_bus   BOOLEAN := NOT no_business_context(p_table,p_id);
  	l_pay   BOOLEAN := NOT no_payroll_context(p_table,p_id);
    --
	BEGIN
	  --
	  -- Add an explanatory comment
  	p_sql := p_sql||'  /* Initialising local variables */'||g_eol;
    --
    -- Process all the initialisations
  	FOR l_rec IN get_inits(p_id) LOOP
  		l_inits := TRUE;
  		--
  		-- If the initialisation is an assignment or a function then
  		-- indent, add the return variable and the assignment operator
  		IF l_rec.process_type IN ('A','F') THEN
  		  OPEN get_outs(l_rec.initialisation_id);
				FETCH get_outs INTO l_par,l_val;
				CLOSE get_outs;
				--
  	    p_sql := p_sql||'  '||l_val||' := ';
  	  --
  	  -- Just indent if the initialisation is a procedure
  		ELSIF l_rec.process_type IN ('P') THEN
  	    p_sql := p_sql||'  ';
  	  END IF;
      --
      -- Fetch the actual code into a local variable we can modify
  		l_plsql := l_rec.plsql_code;
  		--
      -- If it's a SQL select or an assignment then we need to replace any
      -- $<TYPE>_<NAME>$ placeholders with the variables that they represent
  		IF l_rec.process_type IN ('S','A') THEN
 				replace_placeholders(l_plsql,l_rec.initialisation_id,NULL);
	  	END IF;
  		--
      -- If it's an assignment, function or procedure then add the code
      -- from the initialisation definition
  		IF l_rec.process_type IN ('A','F','P') THEN
  			p_sql := p_sql||l_plsql;
 			  --
 			  -- If it's an assignment then that's all we need to do so add the
 			  -- end of line terminator
  			IF l_rec.process_type = 'A' THEN
  			  p_sql := p_sql||';'||g_eol;
  			END IF;
  		END IF;
  		--
      -- If it's a SQL select statement then...
  		IF l_rec.process_type = 'S' THEN
  		  --
   -- Initialise the select and into list
  l_sel := '';
  l_int := '';
  --
  -- Loop round all the output mappings for this initialisation
	FOR l_inner IN get_outs(l_rec.initialisation_id) LOOP
          --
          -- If it's not the first mapping then add the correct padding
		IF get_outs%ROWCOUNT > 1 THEN
			l_sel := l_sel||', '||g_eol||'         ';
			l_int := l_int||', '||g_eol||'         ';
		END IF;
		--
		-- Add the parameter name to the select list and the return
		-- variable to the 'into' clause
		l_sel := l_sel||l_inner.parameter_name;
		l_int := l_int||l_inner.value_name;
	END LOOP;
	--
	-- Concatenate the select list, into list and the remainder of the
	-- select statement (the FROM clause onwards) to the PL/SQL code
	-- N.B. This code relies on the SQL select only bringing back 1
	-- record, otherwise it will fail at runtime, could be changed to
	-- generate a cursor, but that's quite a big change
  	p_sql :=  p_sql||'  SELECT '||l_sel||g_eol||'  INTO   '||l_int||g_eol;
  	p_sql :=  p_sql||' '||
            SUBSTR(l_plsql,INSTR(UPPER(l_plsql),' FROM '))||'; '||g_eol;
  	END IF;
  	--
  	-- If the initialisation's a function or a procedure then...
  	IF l_rec.process_type IN ('F','P') THEN
  	  --
  	  -- Get the parameter mappings for the function or procedure
  	  l_cnt := 0;
  	FOR l_inner IN get_parms(l_rec.initialisation_id) LOOP
  	  --
  	  -- Process the first/not first parameter in the list in
  	  -- different ways so that the code is formatted correctly
		IF get_parms%ROWCOUNT > 1 THEN
			p_sql := p_sql||','||g_eol;
		ELSE
			p_sql := p_sql||'('||g_eol;
		END IF;
		--
		-- Add the parameter to the list in full 'parameter => value' notation
		-- to allow the user to omit parameters from the call
		p_sql :=  p_sql||'    '||
		          RPAD(l_inner.parameter_name,30)||' => '||l_inner.value_name;
			l_cnt := l_cnt + 1;
  	END LOOP;
       --
        -- Finish off the statement by closing the parameter list bracket
        IF l_cnt > 0 THEN
    			p_sql := p_sql||g_eol||'  ); '||g_eol;
    	  END IF;
  		END IF;
  		--
  		-- Add a final comment line to delimit the initialisation block
  		p_sql := p_sql||'  --'||g_eol;
  	END LOOP;
  	--
  	-- Always write the Functional Grouping of Triggers check
    -- This could be made more efficient by placing it just after the required
    -- variables (legislation, business group and payroll) have been initialised
    -- so that any other unnecessary inititialisations aren't carried out if the
    -- trigger isn't supposed to be firing
    IF NOT l_fgt THEN
      paywsfgt_pkg.write_fgt_check(p_id,p_sql,l_bus,l_pay);
    END IF;
  	--
    -- Let the caller know if we wrote any initialisations or not
  	RETURN l_inits;
	END add_initialisations;
--
-- +---------------------------------------------------------------------------+
-- | NAME       : write_parameters                                             |
-- | SCOPE      : PRIVATE                                                      |
-- | DESCRIPTION: Add the parameter list for a component procedure call to the |
-- |              specified PL/SQL text                                        |
-- | PARAMETERS : p_id    - The primary key of the component being processed   |
-- |              p_sql   - The current PL/SQL code that the parameter list    |
-- |                        will be added to                                   |
-- |              p_extra - Any extra text to add before the parameter list    |
-- |                        item, used to indent the line correctly            |
-- | RETURNS    : The modified PL/SQL code via the OUT parameter               |
-- | RAISES     : None                                                         |
-- +---------------------------------------------------------------------------+
  PROCEDURE write_parameters(
    p_id    IN            NUMBER,
    p_sql   IN OUT NOCOPY VARCHAR2,
    p_extra IN            VARCHAR2
  ) IS
  	--
    -- Cursor to fetch the parameter mappings for the specified module
  	CURSOR get_parms(cp_id IN NUMBER) IS
  	  SELECT   parameter_name,
  	           value_name
  	  FROM     pay_trigger_parameters
  	  WHERE    parameter_type IN ('I','O')
  	  AND      value_name IS NOT NULL
  	  AND      usage_id = cp_id
  	  AND      usage_type = 'C'
  	  ORDER BY parameter_id;
  	--
  	l_num NUMBER := 0;
  	--
  BEGIN
    --
    -- Process each parameter in turn
  	FOR l_rec IN get_parms(p_id) LOOP
  		l_num := l_num + 1;
  		--
  		-- Open the bracket for the first row, otherwise add a comma
  		IF get_parms%ROWCOUNT > 1 THEN
  			p_sql := p_sql||','||g_eol;
  		ELSE
  			p_sql := p_sql||'('||g_eol;
  		END IF;
  		--
      -- Add the parameter mapping in full 'parameter => value' notation
  		p_sql := p_sql||'  '||p_extra||
  		         RPAD(l_rec.parameter_name,30)||' => '||l_rec.value_name;
  	END LOOP;
		--
		-- Add a closing bracket, only if one or more parameters was written
		IF l_num > 0 THEN
  		p_sql := p_sql||g_eol||p_extra||')';
  	END IF;
  END write_parameters;
--
-- +---------------------------------------------------------------------------+
-- | NAME       : add_components                                               |
-- | SCOPE      : PRIVATE                                                      |
-- | DESCRIPTION: Add the components (the procedure calls that actually do some|
-- |              work) to the PL/SQL code                                     |
-- | PARAMETERS : p_id  - The primary key of the event we're processing        |
-- |              p_sql - The current PL/SQL block that the component calls    |
-- |                      will get added to                                    |
-- | RETURNS    : The modified PL/SQL block via the OUT parameter and a flag   |
-- |              indicating if any components were written (not sure this is  |
-- |              good programming practice)                                   |
-- | RAISES     : None                                                         |
-- +---------------------------------------------------------------------------+
	FUNCTION add_components(
	  p_id  IN            NUMBER,
	  p_sql IN OUT NOCOPY VARCHAR2
	) RETURN BOOLEAN IS
		--
    -- Get global component calls, ones that always get called, i.e. they
    -- aren't specific to any legislation, business group or payroll
		CURSOR get_globals(cp_id IN NUMBER) IS
			SELECT component_id,
			       module_name
			FROM   pay_trigger_components
			WHERE  legislation_code IS NULL
			AND    business_group_id IS NULL
			AND    payroll_id IS NULL
			AND    enabled_flag = 'Y'
			AND    event_id = cp_id;
		--
		-- Legislation specific components, only get called if the legislation
		-- code of the current record matches the component definition
		CURSOR get_legs(cp_id IN NUMBER) IS
			SELECT component_id,
			       legislation_code,
			       module_name
			FROM   pay_trigger_components
			WHERE  legislation_code IS NOT NULL
			AND    payroll_id IS NULL
			AND    business_group_id IS NULL
			AND    enabled_flag = 'Y'
			AND    event_id = cp_id
			ORDER BY legislation_code;
		--
		-- Business group specific components, only get called if the business
		-- group of the current record matches the component definition
		CURSOR get_buss(cp_id IN NUMBER) IS
			SELECT component_id,
				     business_group_id,
			       module_name
			FROM   pay_trigger_components
			WHERE  legislation_code IS NULL
			AND    payroll_id IS NULL
			AND    business_group_id IS NOT NULL
			AND    enabled_flag = 'Y'
			AND    event_id = cp_id
			ORDER BY business_group_id;
		--
		-- Payroll specific components, only get called if the payroll
		-- id of the current record matches that of the component definition
		CURSOR get_pays(cp_id IN NUMBER) IS
			SELECT component_id,
				     payroll_id,
			       module_name
			FROM   pay_trigger_components
			WHERE  legislation_code IS NULL
			AND    business_group_id IS NULL
			AND    payroll_id IS NOT NULL
			AND    enabled_flag = 'Y'
			AND    event_id = cp_id
			ORDER BY payroll_id;
		--
		l_comps  BOOLEAN := FALSE;
		l_ifs    NUMBER := 0;
		--
    -- Remember the last code we wrote so we know when to end/start IF blocks
		l_oldleg VARCHAR2(30) := '$NO_LEGISLATION_CODE$';
		l_oldbus NUMBER       := -65536;
		l_oldpay NUMBER       := -65536;
		--
	BEGIN
    --
    -- Fetch and write details of all the global components
  	p_sql := p_sql||'  /* Global component calls */'||g_eol;
		FOR l_rec IN get_globals(p_id) LOOP
			l_comps := TRUE;
			--
			p_sql := p_sql||'  '||l_rec.module_name;
			write_parameters(l_rec.component_id,p_sql,'  ');
			p_sql := p_sql||';'||g_eol;
		END LOOP;
	  p_sql := p_sql||'  --'||g_eol;
		--
		-- Fetch and write details of legislation specific components
  	p_sql := p_sql||'  /* Legislation specific component calls */'||g_eol;
    l_ifs := 0;
		FOR l_rec IN get_legs(p_id) LOOP
			l_comps := TRUE;
			--
      -- If the legislation code has changed then add a new IF clause
			IF l_rec.legislation_code <> l_oldleg THEN
				IF get_legs%ROWCOUNT > 1 THEN
   				p_sql := p_sql||'  END IF; '||g_eol||'  --'||g_eol;
					l_ifs := l_ifs - 1;
				END IF;
   			p_sql :=  p_sql||'  IF l_legislation_code = '''||
   			          l_rec.legislation_code||''' THEN'||g_eol;
				l_ifs := l_ifs + 1;
				--
				l_oldleg := l_rec.legislation_code;
			END IF;
			--
      -- Write the component call information
			p_sql := p_sql||'    '||l_rec.module_name;
			write_parameters(l_rec.component_id,p_sql,'    ');
			p_sql := p_sql||';'||g_eol;
		END LOOP;
		--
		-- Close the final IF clause (if we wrote any)
		IF l_ifs > 0 THEN
   				p_sql := p_sql||'  END IF; '||g_eol;
		END IF;
		p_sql := p_sql||'  --'||g_eol;
		--
    -- Fetch and write details of legislation specific components
  	p_sql := p_sql||'  /* Business group specific component calls */'||g_eol;
    l_ifs := 0;
		FOR l_rec IN get_buss(p_id) LOOP
			l_comps := TRUE;
			--
      -- Write a new IF clause if the business group changed
			IF l_rec.business_group_id <> l_oldbus THEN
				IF get_buss%ROWCOUNT > 1 THEN
   				p_sql := p_sql||'  END IF; '||g_eol||'  --'||g_eol;
					l_ifs := l_ifs - 1;
				END IF;
	   		p_sql :=  p_sql||'  IF l_business_group_id = '||
	   		          TO_CHAR(l_rec.business_group_id)||' THEN'||g_eol;
				l_ifs := l_ifs + 1;
				--
				l_oldbus := l_rec.business_group_id;
			END IF;
			--
			-- Write the component call details
			p_sql := p_sql||'    '||l_rec.module_name;
			write_parameters(l_rec.component_id,p_sql,'    ');
			p_sql := p_sql||';'||g_eol;
		END LOOP;
    --
    -- Close the final IF statement if needed
		IF l_ifs > 0 THEN
   				p_sql := p_sql||'  END IF; '||g_eol;
		END IF;
		p_sql := p_sql||'  --'||g_eol;
		--
    -- Write payroll specific component calls
  	p_sql := p_sql||'  /* Payroll specific component calls */'||g_eol;
    l_ifs := 0;
		FOR l_rec IN get_pays(p_id) LOOP
			l_comps := TRUE;
			--
      -- Add a new IF clause if the payroll ID changes
			IF l_rec.payroll_id <> l_oldpay THEN
				IF get_pays%ROWCOUNT > 1 THEN
   				p_sql := p_sql||'  END IF; '||g_eol||'  --'||g_eol;
					l_ifs := l_ifs - 1;
				END IF;
	   		p_sql :=  p_sql||'  IF l_payroll_id = '||
	   		          TO_CHAR(l_rec.payroll_id)||' THEN'||g_eol;
				l_ifs := l_ifs + 1;
				--
				l_oldpay := l_rec.payroll_id;
			END IF;
			--
      -- Write the component module call
			p_sql := p_sql||'    '||l_rec.module_name;
			write_parameters(l_rec.component_id,p_sql,'    ');
			p_sql := p_sql||';'||g_eol;
		END LOOP;
    --
    -- Close the final IF if required
		IF l_ifs > 0 THEN
   				p_sql := p_sql||'  END IF; '||g_eol;
		END IF;
		p_sql := p_sql||'  --'||g_eol;
		--
    -- Let the caller know whether or not we wrote and components
		RETURN l_comps;
	END add_components;
-- +---------------------------------------------------------------------------+
-- | NAME       : generate_code                                                |
-- | SCOPE      : PUBLIC                                                       |
-- | DESCRIPTION: See header                                                   |
-- +---------------------------------------------------------------------------+
  PROCEDURE generate_code(p_id IN NUMBER,p_sql IN OUT NOCOPY VARCHAR2) IS
    --
	l_inits BOOLEAN;
	l_comps BOOLEAN;
	l_table pay_trigger_events.table_name%TYPE;
        l_name  pay_trigger_events.short_name%TYPE;
        l_type  pay_trigger_events.triggering_action%TYPE;
        l_desc  VARCHAR2(80);
        l_info  pay_trigger_events.description%TYPE;

  	--
  	-- Get some extra information about the event we're generating code for
  	CURSOR csr_name(cp_id IN NUMBER) IS
  		SELECT	pte.table_name,
  		        pte.short_name,
  		        pte.triggering_action,
  		        DECODE(pte.triggering_action,
  		          'I','Insert',
  		          'U','Update',
  		          'D','Delete'
  		        ),
  		        pte.description
  		FROM		pay_trigger_events pte
  		WHERE		pte.event_id = cp_id;
    --
  BEGIN
    --
    -- Fetch the additional information we need before we can generate
    OPEN csr_name(p_id);
    FETCH csr_name INTO l_table,l_name,l_type,l_desc,l_info;
    CLOSE csr_name;
    --
    -- Initialise the statement PL/SQL code
  	p_sql := '';
  	--

        -- Add DECLARE before calling add_declarations
        p_sql := p_sql||'DECLARE '||g_eol;
   	p_sql := p_sql||'  /* Local variable declarations */'||g_eol;

        -- Add the seeded declaration section
	add_declarations(p_id,p_sql);

        -- Add any hard-coded declarations
        p_sql := p_sql||'  l_mode  varchar2(80);'||g_eos;
  	--
  	-- Add an initial comment section to the trigger code
  	p_sql := p_sql||'BEGIN'||g_eol;
  	p_sql := p_sql||'/*'||g_eol;
  	p_sql := p_sql||'  ================================================'||g_eol;
  	p_sql := p_sql||'  This is a dynamically generated database trigger'||g_eol;
  	p_sql := p_sql||'  ================================================'||g_eol;
  	p_sql := p_sql||'            ** DO NOT CHANGE MANUALLY **          '||g_eol;
  	p_sql := p_sql||'  ------------------------------------------------'||g_eol;
  	p_sql := p_sql||'    Table:  '||l_table||g_eol;
  	p_sql := p_sql||'    Action: '||l_desc||g_eol;
  	p_sql := p_sql||'    Date:   '||TO_CHAR(SYSDATE,'DD/MM/YYYY HH24:MI')||g_eol;
  	p_sql := p_sql||'    Name:   '||l_name||g_eol;
  	p_sql := p_sql||'    Info.:  '||l_info||g_eol;
  	p_sql := p_sql||'  ================================================'||g_eol;
  	p_sql := p_sql||'*/'||g_eol||'--'||g_eol;
  	--

    --Add our system to let future processes know whether this is existing or new dyt
    p_sql := p_sql||'  l_mode := pay_dyn_triggers.g_dyt_mode;'||g_eol;
    p_sql := p_sql||'  pay_dyn_triggers.g_dyt_mode := pay_dyn_triggers.g_dbms_dyt;'||g_eol;

    -- Add the data migrator check - Bug 1885557
    p_sql := p_sql||'IF NOT (hr_general.g_data_migrator_mode <> ''Y'') THEN'||g_eol;
    p_sql := p_sql||'  RETURN;'||g_eol;
    p_sql := p_sql||'END IF;'||g_eol;
    --
    -- Add the initialisation and component PL/SQL code
  	l_inits := add_initialisations(p_id,p_sql,l_table);
  	l_comps := add_components(p_id,p_sql);
  	--
    -- If we didn't add any initialisations or components then add a NULL
    -- operation to prevent compilation errors when triggers without any
    -- default initialisations are first created
  	IF NOT l_inits AND NOT l_comps THEN
  		p_sql := p_sql||'  NULL;'||g_eol;
  	END IF;


    p_sql := p_sql||'  pay_dyn_triggers.g_dyt_mode := l_mode;'||g_eol;


    --
    -- Add a default exception block to catch all errors and write the
    -- trigger name and error text to the standard Oracle Apps error logging
    -- mechanism
  	p_sql := p_sql||'EXCEPTION'||g_eol;
  	p_sql := p_sql||'  WHEN OTHERS THEN'||g_eol;
  	p_sql := p_sql||'    hr_utility.set_location('''||
  	         get_trigger_name(p_id,l_table,l_type)||''',ABS(SQLCODE));'||g_eol;
        p_sql := p_sql||'    pay_dyn_triggers.g_dyt_mode := l_mode;'||g_eol;
  	p_sql := p_sql||'    RAISE;'||g_eol;
  	p_sql := p_sql||'  --'||g_eol;
  	p_sql := p_sql||'END;'||g_eol;
  END generate_code;
--
--
-- +---------------------------------------------------------------------------+
-- | NAME       : delete_event_children                                        |
-- | SCOPE      : PUBLIC                                                       |
-- | DESCRIPTION: See header                                                   |
-- +---------------------------------------------------------------------------+
  PROCEDURE delete_event_children(p_id IN NUMBER) IS
    --
    -- Get some more information we need before we can delete the event
    CURSOR get_trigger(cp_id IN NUMBER) IS
  		SELECT	pte.table_name,
  		        pte.triggering_action
   		FROM		pay_trigger_events pte
  		WHERE		pte.event_id = cp_id;
    --
    -- Get all the initialisations that this event uses
    CURSOR get_inits(cp_id IN NUMBER) IS
  		SELECT	initialisation_id
   		FROM		pay_trigger_initialisations
  		WHERE		event_id = cp_id;
    --
    -- Get all the components that this event uses
    CURSOR get_comps(cp_id IN NUMBER) IS
  		SELECT	component_id
   		FROM		pay_trigger_components
  		WHERE		event_id = cp_id;
    --
    l_tname VARCHAR2(30);
    l_action VARCHAR2(1);
    l_name VARCHAR2(30);
    --
  BEGIN
    --
    -- Get the table name and triggering action of the event we're deleting
    OPEN get_trigger(p_id);
    FETCH get_trigger INTO l_tname,l_action;
    CLOSE get_trigger;
    --
    -- Work out the trigger name according to the standard format
    l_name := get_trigger_name(p_id,l_tname,l_action);
    --
    -- Drop the trigger (uses AOL routines)
    drop_trigger(l_name);
    --
    -- Fetch all the initialisations, delete their children and finally
    -- the initialisations themselves
    FOR l_rec IN get_inits(p_id) LOOP
      delete_initialisation_children(l_rec.initialisation_id);
    END LOOP;
    DELETE
    FROM  pay_trigger_initialisations
    WHERE event_id = p_id;
    --
    -- Fetch all the components, delete their children and finally
    -- the components themselves
    FOR l_rec IN get_comps(p_id) LOOP
      delete_component_children(l_rec.component_id);
    END LOOP;
    DELETE
    FROM  pay_trigger_components
    WHERE event_id = p_id;
    --
    -- Delete the local variable declarations that the trigger uses
    DELETE
    FROM  pay_trigger_declarations
    WHERE event_id = p_id;
    --
    -- Drop the support package and delete it's definition
    drop_package(l_tname,get_package_name(p_id,l_tname));
    DELETE
    FROM  pay_trigger_support
    WHERE event_id = p_id;
    --
    -- Don't delete the actual event, the caller (e.g. Forms) must do this
  END delete_event_children;
--
-- +---------------------------------------------------------------------------+
-- | NAME       : delete_initialisation_children                               |
-- | SCOPE      : PUBLIC                                                       |
-- | DESCRIPTION: See header                                                   |
-- +---------------------------------------------------------------------------+
  PROCEDURE delete_initialisation_children(p_id IN NUMBER) IS
  BEGIN
    --
    -- Delete all the parameters that the requested initialisation uses
    DELETE
    FROM  pay_trigger_parameters
    WHERE usage_type = 'I'
    AND   usage_id   = p_id;
    --
    -- The caller must delete the initialisation itself
  END delete_initialisation_children;
--
-- +---------------------------------------------------------------------------+
-- | NAME       : delete_component_children                                    |
-- | SCOPE      : PUBLIC                                                       |
-- | DESCRIPTION: See header                                                   |
-- +---------------------------------------------------------------------------+
  PROCEDURE delete_component_children(p_id IN NUMBER) IS
  BEGIN
    --
    -- Delete all the parameters that the requested component uses
    DELETE
    FROM  pay_trigger_parameters
    WHERE usage_type = 'C'
    AND   usage_id   = p_id;
    --
    -- The caller must delete the component itself
  END delete_component_children;

-- +---------------------------------------------------------------------------+
-- | NAME       : delete_parameters_directly                                   |
-- | SCOPE      : PUBLIC                                                       |
-- | DESCRIPTION: See header                                                   |
-- +---------------------------------------------------------------------------+
  PROCEDURE delete_parameters_directly(p_param_id IN NUMBER) IS
  BEGIN
    --
    -- Delete a parameter directly, used by table event updates form
    DELETE
    FROM  pay_trigger_parameters
    WHERE  parameter_id   = p_param_id;
    --
    -- The caller must delete the initialisation itself
  END delete_parameters_directly;

--
--
-- +---------------------------------------------------------------------------+
-- | NAME       : get_dyt_pkg_params_tbl                                       |
-- | SCOPE      : PRIVATE                                                      |
-- | DESCRIPTION: See header                                                   |
-- +---------------------------------------------------------------------------+
  PROCEDURE get_dyt_pkg_params_tbl(p_tab_id IN NUMBER
                             ,p_tab_name IN VARCHAR2
                             ,p_params IN OUT NOCOPY g_params_tab_type) IS
    --
  cursor csr_params (cp_tab_id in number)
  is
    select parameter_name, usage_type, value_name
    from pay_trigger_parameters
    where usage_type in ('PI','PU','PD')
    and usage_id = cp_tab_id
    order by parameter_name;

  cursor csr_col_type (cp_tab_name varchar2, cp_col_name varchar2)
  is
    select data_type
    from all_tab_columns
    where table_name  = cp_tab_name
    and   column_name like cp_col_name
    and   owner       = g_pay_schema
    and rownum = 1; --Assuming if the params been truc'd to 30 then its the only col
                    --on the base table with these first 30chars

  -- nb ORDERED hint for performance fix 3110997
  cursor csr_type_from_pkg (cp_tab_name varchar2, cp_param_name varchar2)
  is
    SELECT /*+ ORDERED */ a.pls_type
      FROM (select /*+ NO_MERGE */
                   DISTINCT hook_package
              from hr_api_hooks h,
                   hr_api_modules m
             where m.api_module_id = h.api_module_id
               and m.module_name = cp_tab_name) V,
           USER_OBJECTS B,
           SYS.ARGUMENT$ A
     WHERE A.OBJ# = B.OBJECT_ID
       AND B.OBJECT_NAME = V.hook_package
       AND A.LEVEL# = 0
       AND A.argument = cp_param_name
       AND B.object_type = 'PACKAGE'
       AND rownum = 1;
--    Commented for bug fix 7006158.
--    SELECT /*+ ORDERED */ a.pls_type
--    FROM   USER_OBJECTS B,
--           SYS.ARGUMENT$ A
--    WHERE  A.OBJ# = B.OBJECT_ID
--    AND    B.OBJECT_NAME in (select hook_package
--                             from hr_api_hooks h, hr_api_modules m
--                             where m.api_module_id = h.api_module_id
--                             and m.module_name = cp_tab_name)
--    AND    A.LEVEL# = 0
--    AND    A.argument = cp_param_name
--    AND    B.object_type = 'PACKAGE'
--    AND    rownum = 1;

  i number := 0;

  BEGIN
    --
    -- Fetch Schema name if required
    --
    g_pay_schema := get_table_owner(p_tab_name);
    --
    --get all mappings of dyn-trigger-package-procedure params, eg all names
    -- of dyn-trigger local vars into a record with info on I,U,D  --given table id
    FOR param_rec in csr_params(p_tab_id) LOOP
      p_params(i).local_form := param_rec.parameter_name;
      p_params(i).usage_type := param_rec.usage_type;
      p_params(i).value_name := param_rec.value_name;
      IF SUBSTR(p_params(i).local_form,1,2) = 'l_' THEN
            p_params(i).param_form := 'p_l_'||SUBSTR(p_params(i).local_form,3);
      ELSIF SUBSTR(p_params(i).local_form,1,5) = ':old.' THEN
            p_params(i).param_form := 'p_old_'||SUBSTR(p_params(i).local_form,6);
      ELSIF SUBSTR(p_params(i).local_form,1,5) = ':new.' THEN
            p_params(i).param_form := 'p_new_'||SUBSTR(p_params(i).local_form,6);
      ELSE
            p_params(i).param_form := NULL;
      END IF;

      --Get col type using the text after the '.' in local form(plus % for like in csr)
      --
      open csr_col_type(p_tab_name,upper(substr(p_params(i).local_form,instr(p_params(i).local_form,'.')+1))||'%');
      fetch csr_col_type into p_params(i).data_type;
      close csr_col_type;

      -- if we didnt get a data_type (eg name different than base col.)
      -- then have to resort to the inefficient approach,
      -- getting the type from the user hook pkg definition, on which these parameter
      -- mappings are based.  (Because essentially all these dynamic procedures do
      -- is act as the call package from the hook pkg.)
      if (p_params(i).data_type is null) then
        open csr_type_from_pkg(p_tab_name,
                 upper('p_'||SUBSTR(p_params(i).local_form,6)));
        fetch csr_type_from_pkg into p_params(i).data_type;
        close csr_type_from_pkg;
      end if;
        --If still null try one last hack in case we're working on the ALL version
      if (p_params(i).data_type is null) then
        open csr_type_from_pkg(replace(p_tab_name, '_ALL_','_'),
                 upper('p_'||SUBSTR(p_params(i).local_form,6)));
        fetch csr_type_from_pkg into p_params(i).data_type;
        close csr_type_from_pkg;
      end if;
     --If still null try one last hack, cos know all should have this
     --and if no hook we might miss it (eg pay_element_entry_val)
     if (p_params(i).data_type is null
         and p_params(i).value_name = 'P_DATETRACK_MODE') then
       p_params(i).data_type := 'VARCHAR2';
     end if;

       -- if still null then maybe raise a better error?


      --All param versions must be less than 30 chars as used in dbms triggers
      p_params(i).param_form := substr(p_params(i).param_form,0,30);
      i := i+1;
    END LOOP;
  END get_dyt_pkg_params_tbl;

--
-- +---------------------------------------------------------------------------+
-- | NAME       : get_dyt_rhi_params                                       |
-- | SCOPE      : PRIVATE                                                      |
-- | DESCRIPTION: See header                                                   |
-- +---------------------------------------------------------------------------+
 PROCEDURE get_dyt_rhi_params(p_tab_id IN NUMBER
                            ,p_tab_name IN VARCHAR2
                            ,p_params IN OUT NOCOPY g_params_tab_type) IS

  -- Local variables to catch the values returned from
  -- hr_general.describe_procedure
  --
  l_overload            dbms_describe.number_table;
  l_position            dbms_describe.number_table;
  l_level               dbms_describe.number_table;
  l_argument_name       dbms_describe.varchar2_table;
  l_datatype            dbms_describe.number_table;
  l_default_value       dbms_describe.number_table;
  l_in_out              dbms_describe.number_table;
  l_length              dbms_describe.number_table;
  l_precision           dbms_describe.number_table;
  l_scale               dbms_describe.number_table;
  l_radix               dbms_describe.number_table;
  l_spare               dbms_describe.number_table;

  l_datatype_str      varchar2(20);            -- String equivalent of
                                               -- l_datatype number.
-- Oracle Internal DataType, Parameter, Default Codes and New Line Constants
--
c_dtype_undefined constant number      default   0;
c_dtype_varchar2  constant number      default   1;
c_dtype_number    constant number      default   2;
c_dtype_long      constant number      default   8;
c_dtype_date      constant number      default  12;
c_dtype_boolean   constant number      default 252;

 cursor csr_hooks (cp_tab_name varchar2)
  is
   select hook_package pkg, hook_procedure proc
          ,decode(hook_procedure, 'AFTER_INSERT', 'PI',
                           'AFTER_UPDATE', 'PU',
                           'AFTER_DELETE', 'PD') usage_type
   from hr_api_hooks h, hr_api_modules m
   where m.api_module_id = h.api_module_id
   and m.module_name = cp_tab_name;
  --

  i number := 1;
  j number := 0;  --p_params, our local store, starts from 0

  l_prefix varchar2(15); --Local Form prefix
  l_o      varchar2(15) := 'p_old_'; --Old Style Local Form prefix
  l_n      varchar2(15) := 'p_new_'; --Old Style Local Form prefix
  l_value_name varchar2(80);

 l_proc varchar2(80) := 'get_dyt_rhi_params';

  BEGIN

    -- Want an exhaustive list of params, whatever is available to hook
    --should be passed
    --In terms of this internal table structure, want
    --NB names based on form param screen, NOT what makes logical sense!
    -- param_form - ':old.column_name'
    -- local_form - 'p_column_name_o'
    -- value_name - 'P_old_column_name'
<< HOOK_MODULES >>
FOR hook_rec in csr_hooks(p_tab_name) LOOP

     hr_general.describe_procedure
  (object_name   => hook_rec.pkg || '.' || hook_rec.proc
   ,reserved1     => null
   ,reserved2     => null
   ,overload      => l_overload
   ,position      => l_position
   ,level         => l_level
   ,argument_name => l_argument_name
   ,datatype      => l_datatype
   ,default_value => l_default_value
   ,in_out        => l_in_out
   ,length        => l_length
   ,precision     => l_precision
   ,scale         => l_scale
   ,radix         => l_radix
   ,spare         => l_spare
   );


   << ONE_PROC_PARAM_LOOP >>
   FOR i in 1..l_position.COUNT loop
         --hr_utility.trace(' Found parameter '||l_argument_name(i)||' type '||l_         --
         if l_datatype(i) <> c_dtype_varchar2 and
             l_datatype(i) <> c_dtype_number   and
             l_datatype(i) <> c_dtype_date     and
             l_datatype(i) <> c_dtype_boolean  and
             l_datatype(i) <> c_dtype_long     then
            -- Error: In a hook package procedure all the parameter datatypes
            -- must be VARCHAR2, NUMBER, DATE, BOOLEAN or LONG. This API
            -- module will not execute until this problem has been resolved.
            hr_utility.set_message(800, 'HR_51968_AHK_HK_PARA_D_TYPE');
            hr_utility.set_location(l_proc, 80);
          else
            -- Set the datatype string with the corresponding word value
            if l_datatype(i) = c_dtype_varchar2 then
              l_datatype_str := 'VARCHAR2';
            elsif l_datatype(i) = c_dtype_number then
              l_datatype_str := 'NUMBER';
            elsif l_datatype(i) = c_dtype_date then
              l_datatype_str := 'DATE';
            elsif l_datatype(i) = c_dtype_boolean then
              l_datatype_str := 'BOOLEAN';
            else
              l_datatype_str := 'LONG';
          end if;

      p_params(j).local_form := 'NOT CALCULATED';
      p_params(j).param_form := 'NOT CALCULATED';
      p_params(j).value_name := substr(l_argument_name(i),0,30);
      p_params(j).usage_type := hook_rec.usage_type;
      p_params(j).data_type  := l_datatype_str;
      j := j+1;
          end if;

    END LOOP ONE_PROC_PARAM_LOOP;

  END LOOP HOOK_MODULES;
    --Debug Output all the paramaters in my table form
       --FOR j in 0..(p_params.COUNT - 1) loop
         --hr_utility.trace(j||' '||p_params(j).value_name||' '||p_params(j).usage_type||' '||p_params(j).data_type);
       --end loop;

       hr_utility.trace('Total RHI params '||p_params.count);

    -- If we didnt get any hook params then there might not be a hook pkg!
    -- So just base the params on what we actually need, i.e. the param mappings
    if ( p_params.count = 0 ) then
      hr_utility.trace('No hook params => build params from what is required from components');

      get_dyt_pkg_params_tbl(p_tab_id,p_tab_name,p_params);
      --On top of the ones we need in dyt call, we also know we need p_datetrack
      --in both after_delete and after_update.
      i := p_params.count;
      p_params(i).local_form := 'NOT CALCULATED';
      p_params(i).param_form := 'NOT CALCULATED';
      p_params(i).value_name := 'P_DATETRACK_MODE';
      p_params(i).usage_type := 'PU';
      p_params(i).data_type  := 'VARCHAR2';
      p_params(i).local_form := 'NOT CALCULATED';
      p_params(i+1).param_form := 'NOT CALCULATED';
      p_params(i+1).value_name := 'P_DATETRACK_MODE';
      p_params(i+1).usage_type := 'PD';
      p_params(i+1).data_type  := 'VARCHAR2';

       hr_utility.trace('Total RHI params '||p_params.count);
      -- Example of structure of p_params from get_dyt_pkg_params_tbl
      --local_form - :new.EFFECTIVE_END_DATE
      --param_form - p_new_EFFECTIVE_END_DATE
      --value_name - P_EFFECTIVE_END_DATE

    end if;

  END get_dyt_rhi_params;

--
-- +---------------------------------------------------------------------------+
-- | NAME       : get_dyt_pkg_version_of_code                                  |
-- | SCOPE      : PRIVATE                                                      |
-- | DESCRIPTION: This procedure takes an extract of dynamically generated code|
-- |              relevant for dbms triggers and turns it in to code useful for|
-- |              code that resides in packages.   Main use to convert code    |
-- |              generated by                                                 |
-- |              + add_declarations                                           |
-- |              + add_initialisations                                        |
-- |              + add_components                                             |
-- |              in to code being built as part of + Gen_dyt_pkg_full_code    |
-- +---------------------------------------------------------------------------+
  PROCEDURE get_dyt_pkg_version_of_code(p_sql IN OUT NOCOPY varchar2,
                                        p_tab_name   IN     varchar2,
                                        p_usage_type IN     varchar2) IS
    --
    l_pos number;
    l_col_name varchar2(32767);
    l_new_col_name varchar2(2000);

  cursor  csr_missing_params (cp_table_name in varchar2, cp_type in varchar2) is
  /* Component calls use this , ignore locals cos these will always be made*/
    SELECT   upper(value_name) name
    FROM     pay_trigger_parameters
    WHERE    parameter_type IN ('I','O')
    AND      value_name IS NOT NULL
    AND      usage_id in (select component_id
                          from pay_trigger_events te, pay_trigger_components tc
                          where te.event_id = tc.event_id
                          and triggering_action = cp_type
                          and   te.table_name = cp_table_name)
    AND      usage_type = 'C'
    AND      value_name like ':%'
    MINUS
  /* aru params use this */
    SELECT upper(parameter_name)
    FROM pay_trigger_parameters
    WHERE usage_type = 'P'||cp_type
    AND usage_id = (select dated_table_id
                      from pay_dated_tables
                      where table_name = cp_table_name);

  l_missing     varchar2(60);
  l_missing_rep varchar2(60);
  l_extract     varchar2(32767);
  l_extract_new varchar2(32767);
  l_pos_next    number;
  i number;

  BEGIN
  --Make life easier by getting sql in caps
  p_sql := upper(p_sql);

-- >>> 1.  Do some funky stuff to overcome major headaches.
--
--OLD SKOOL
--  DB TRIG -> CC PKG
--NEW SKOOL
--  USER_HOOK_PKG -> USER_CALL_PKG(DYT_PKG) -> CC_PKG
--
--     The original dyt's as db triggers had access to ALL values on the table
--     old and new, no worries, so CC pkg code could be built expecting ALL values.
--     However, now the CC pkg is called by a dyt_pkg which is referred to as an
--     user hook call pkg, as is called by the user hook pkg.  Trouble is what
--     parameters the user hook package has access to is in the lap of the gods
--     aka the developers who build them.  It is acceptable for example to not pass
--     the new version of values if they are non-updateable, i.e. they are defo the same
--     so why bother passing?
--     BUT, out dyt_pkg's need to call the CC pkg and this is still expecting ALL values
--     old and new for each column.
--     Therefore we do a crafty trick/hack, getting those values that are referenced in
--     component code and are not passed in by the hook.  We make the assumption,
--     fairly solid, that we can safely replace the missing value with the same
--     existing value.  EG If business_group_id is non-updateable (often) then the value
--     p_business_group_id wont exist in the scope of our hook pkg and thus not be
--     in our call-package, however p_business_group_id_o will be passed in.
--     So we replace all instances of :new.business_group_id (because everything
--     is still in old-skool db style) and replace it with :old.business_group_id.!
--     et voila, the CC pkg
--     gets all the values, just sometimes the same value for old and new.

  --missing_param defo upper
  for missing_param in csr_missing_params(p_tab_name,p_usage_type) loop
    --Most of the time missing new value, cos non-updateable
    --eg turn :new.business_group_id to :old.business_group_id
   l_missing := missing_param.name;
    if (substr(l_missing,1,4) = ':NEW' ) then
      l_missing_rep := replace(missing_param.name,'NEW','OLD');

    --But as developer has control, may be some the other way eg one off dates
    --and id's where arbitrary which is passed, and not changed
    elsif (substr(l_missing,1,4) = ':OLD' ) then
            l_missing_rep := replace(missing_param.name,'OLD','NEW');
    else
       l_missing_rep := l_missing||'xxx'; --no change so will fall over
    end if;
    --hr_utility.trace('Missing param: '||l_missing||' replace with: '||l_missing_rep);
   p_sql := replace(p_sql,l_missing,l_missing_rep);

  end loop;

-- >>> 2.  Turn any references to :old. style notation to param style
--    EG.  :old.cost_allocation_keyflex_id => p_old_cost_allocation_keyflex
--
    -- Find first occurences of :old.
    l_pos := instr(p_sql,':OLD.');
    -- Loop through all occurences
    while (l_pos > 0) loop

--Get extract from this instance of :new to next :new instance
--
      l_pos_next := instr(p_sql,':OLD.',l_pos+1);
--hr_utility.trace(l_pos||' <- l_pos -> '||l_pos_next);
      if (l_pos_next <> 0  ) then
        l_extract := substr(p_sql,l_pos,l_pos_next - l_pos);
      else
        l_extract := substr(p_sql,l_pos);
        l_pos_next := length(p_sql)+1;
      end if;

      l_col_name := translate(l_extract,' ),|;'||g_eol,'*****');
      l_col_name := substr(l_col_name,1,instr(l_col_name,'*')-1);

-- Amend the prefix and make sure we're not over the 30 char limit
      l_new_col_name := substr(replace(l_col_name,':OLD.','P_OLD_'),1,30);

--hr_utility.trace(l_pos||' Replace- '||l_col_name||'  with- '||l_new_col_name);

      l_extract_new := replace(l_extract,l_col_name,l_new_col_name);
      p_sql := substr(p_sql,0,l_pos-1)||l_extract_new||substr(p_sql,l_pos_next);

    --Find next occurence ,will be first as just done previous first,
    --but go from l_pos as quicker
      l_pos := instr(p_sql,':OLD.',l_pos);

  end loop;

-- >>> 3.  Turn any references to :new. style notation to param style
--

    -- Find first occurences of :new.
    l_pos := instr(p_sql,':NEW.');
    -- Loop through all occurences
    while (l_pos > 0) loop

--Get extract from this instance of :new to next
--
      l_pos_next := instr(p_sql,':NEW.',l_pos+1);
--hr_utility.trace(l_pos||' <- l_pos -> '||l_pos_next);
      if (l_pos_next <> 0  ) then
        l_extract := substr(p_sql,l_pos,l_pos_next - l_pos);
      else
        l_extract := substr(p_sql,l_pos);
        l_pos_next := length(p_sql)+1;
      end if;

      l_col_name := translate(l_extract,' ),|;'||g_eol,'*****');
      l_col_name := substr(l_col_name,1,instr(l_col_name,'*')-1);

-- Amend the prefix and make sure we're not over the 30 char limit
      l_new_col_name := substr(replace(l_col_name,':NEW.','P_NEW_'),1,30);

--hr_utility.trace(l_pos||' Replace- '||l_col_name||'  with- '||l_new_col_name);

      l_extract_new := replace(l_extract,l_col_name,l_new_col_name);
      p_sql := substr(p_sql,0,l_pos-1)||l_extract_new||substr(p_sql,l_pos_next);

    --Find next occurence ,will be first as just done previous first,
    --but go from l_pos as quicker
      l_pos := instr(p_sql,':NEW.',l_pos);

  end loop;

-- >>> 4.  Remove the instances of DECLARE
--  --now the calling code adds the DECLARE explicitly, as opposed to add_declarations
    --this should actually not find any DECLARE chars
    p_sql := replace(p_sql,'DECLARE');
  end get_dyt_pkg_version_of_code;

--
-- +---------------------------------------------------------------------------+
-- | NAME       : get_dyt_proc_name                                            |
-- | SCOPE      : PRIVATE                                                      |
-- | DESCRIPTION: Would like to use full dynamic trigger name simply as proc   |
-- |              name but sadly some are too long, so strip down, but keep the|
-- |              last few chars as these are often the useful identifiers.    |
-- +---------------------------------------------------------------------------+
  FUNCTION get_dyt_proc_name(p_dyt_name IN VARCHAR2) RETURN varchar2 IS

   l_suffix      pay_trigger_events.short_name%TYPE;
   l_proc_name   varchar2(30);
  BEGIN

    --Strip off the useful suffix   (make sure its max 30chars)
    l_suffix := substr(   substr(p_dyt_name,instr(p_dyt_name,'_',-1)) , 1 , 30);

    --First version of proc_name is as many chars at start of p_dyt_name
    l_proc_name := substr(p_dyt_name,1,30 - length(l_suffix));
    --Full version is first||suffix
    l_proc_name := l_proc_name||l_suffix;

    --hr_utility.trace(' Got DYT pkg procedure name: '||l_proc_name);
    return l_proc_name;
  END;

--
-- +---------------------------------------------------------------------------+
-- | NAME       : gen_dyt_pkg_full_code                                        |
-- | SCOPE      : PUBLIC                                                       |
-- | DESCRIPTION: See header                                                   |
-- +---------------------------------------------------------------------------+
  PROCEDURE gen_dyt_pkg_full_code(p_tab_id IN NUMBER,
                                  p_ok IN OUT NOCOPY BOOLEAN) IS
    --

    l_tab_id            pay_dated_tables.dated_table_id%TYPE;
    l_tab_name          pay_dated_tables.table_name%TYPE;
    l_tab_dyt_types     pay_dated_tables.dyn_trigger_type%TYPE;
    l_tab_dyt_pkg_name  pay_dated_tables.dyn_trigger_package_name%TYPE;
    l_datetracked_table varchar2(5);

    --
    l_hs     varchar2(32000);  --Used as header sql placeholders
    l_bs     varchar2(32000);  --Used as body sql placeholder
    l_hsql     varchar2(32000);  --Used as header
    l_bsql     varchar2(32767);  --Used as body

    l_dyt_params g_params_tab_type; --hold params to build dyt in dyt_pkg
    l_hok_params g_params_tab_type; --hold params to build rhi-hook wrapper
    l_dbt_name varchar2(80);

    l_head_ok BOOLEAN;
    l_body_ok BOOLEAN;
    l_flag varchar2(1);

    l_dyt_pkg_head_tbl           t_varchar2_32k_tbl;
    l_dyt_pkg_body_tbl           t_varchar2_32k_tbl;

    --
    --Given id, get table info
    CURSOR csr_table_info (cp_tab_id in NUMBER) IS
      SELECT  pdt.dated_table_id,
              pdt.table_name,
              nvl(pdt.dyn_trigger_type,'T'),
              pdt.dyn_trigger_package_name,
              decode(start_date_name,
                     null, 'N',
                     'Y')
      FROM    pay_dated_tables pdt
      WHERE   pdt.dated_table_id = (cp_tab_id);

    -- Get details of all dyn-triggers on given table
    CURSOR csr_dyts_on_table(cp_name in VARCHAR2) IS
      SELECT  pte.event_id, pte.short_name,
              pte.triggering_action, pte.description,
              DECODE(pte.triggering_action, 'I','Insert','U','Update', 'D','Delete' ) info,
              enabled_flag,generated_flag
      FROM    pay_trigger_events pte
      WHERE   pte.table_name = (cp_name)
      AND     nvl(pte.protected_flag,'N') <> 'Y';

    --
    l_proc varchar2(35) := 'gen_dyt_pkg_full_code';
  BEGIN
   hr_utility.set_location(' Entering: '||l_proc,10);
    -- The package to hold the code is created with two sections.
    -- a. The main trigger code, built using info from the dynamic triggers screen
    -- b. The after_update, after_insert, after_delete standard called by rhi,
    --    these act as wrappers calling (a)'s.
    --
    -- These parts are all built dynamically
    -- At this time, this code may have been called for the generation of a
    -- SINGLE trigger, However, we generate a dynamic trigger package (dyt_pkg)
    -- representing code for ALL triggers on that table.

  -- NB. It is important to note that there is a subtle difference between
  -- database triggers and dynamic triggers.  The latter are defined on site giving
  -- great flexibility, i.e. what customer-specific calls need to be made as part of
  -- this process.  How the code is actually stored provides more flexibility.
  -- This is table specific and defined in pay_dated_tables, eg the dyn-trigger
  -- code can be stored as database triggers, in a separate package or in both of these.
  -- ...
  -- Since continuous calc we are moving toward the idea of no database triggers,
  -- (negative issues with maintenance) and toward stored code as a package.
  -- Indeed, many seeded offerings on core tables will have this behaviour.  However,
  -- we allow greater customer flexibilty by leaving database triggers as an option.
  -- (Especially useful for non-API supported customer database tables.)
    --
    -- Fetch the table information, given this passed id
    OPEN csr_table_info(p_tab_id);
    FETCH csr_table_info INTO l_tab_id, l_tab_name,
                              l_tab_dyt_types,  l_tab_dyt_pkg_name,
                              l_datetracked_table;
    CLOSE csr_table_info;

    -- Create table of varchar2's representing the full head and body code.
    -- Initialise the holders of PL/SQL code
    --
-- >>> 1.  Add the start of this 'dynamic-trigger package code', incl comments
--
    l_hs := l_hs||'/*'||g_eol;
    l_hs := l_hs||'  =================================================='||g_eol;
    l_hs := l_hs||'  This is a dynamically generated database package  '||g_eol;
    l_hs := l_hs||'  containing code to support the use of dynamic     '||g_eol;
    l_hs := l_hs||'  triggers.                                         '||g_eol;
    l_hs := l_hs||'  Preference of package Vs dbms triggers supporting '||g_eol;
    l_hs := l_hs||'  dyn'' triggers is made via the dated table form.  '||g_eol;
    l_hs := l_hs||'  .                                                 '||g_eol;
    l_hs := l_hs||'  This code will be called implicitly by table rhi  '||g_eol;
    l_hs := l_hs||'  and explictly from non-API packages that maintain '||g_eol;
    l_hs := l_hs||'  data on the relevant table.                       '||g_eol;
    l_hs := l_hs||'  =================================================='||g_eol;
    l_hs := l_hs||'              ** DO NOT CHANGE MANUALLY **          '||g_eol;
    l_hs := l_hs||'  --------------------------------------------------'||g_eol;
    l_hs := l_hs||'    Package Name: '||l_tab_dyt_pkg_name||g_eol;
    l_hs := l_hs||'    Base Table:   '||l_tab_name||g_eol;
    l_hs := l_hs||'    Date:         '||TO_CHAR(SYSDATE,'DD/MM/YYYY HH24:MI')||g_eol;
    l_hs := l_hs||'  =================================================='||g_eol;
    l_hs := l_hs||'*/'||g_eos;

    -- Add first line of code to two main placeholders, and add the comments
    --
    l_hsql := l_hsql||'Create or replace package '||l_tab_dyt_pkg_name||g_eol
                  ||'AS'||g_eos;
    l_hsql := l_hsql||l_hs;
    l_bsql := l_bsql||'Create or replace package body '||l_tab_dyt_pkg_name||g_eol
                  ||'IS'||g_eos;
    l_bsql := l_bsql||l_hs;
    l_hs :='';
    --

    -- Shove this first chunk of code into holder
    l_dyt_pkg_head_tbl(0) := l_hsql;
    l_dyt_pkg_body_tbl(0) := l_bsql;

-- >>> 2. Get all parameters defined for this table in to table of records for future
--        manipulation.  This table holds the following info:
   hr_utility.set_location('  -Get parameters DYT : '||l_proc,20);

    --        i. local name   --entered in form
    --        ii. generated pkg param version of i-used for internal pkg proc
    --        iii. usage type   -- eg PI Insert, PU Update, PD Delete
    --        iv. type of col
    --
    get_dyt_pkg_params_tbl(l_tab_id, l_tab_name, l_dyt_params);
   hr_utility.set_location('  -Get parameters after_xxx : '||l_proc,25);
    get_dyt_rhi_params(l_tab_id, l_tab_name, l_hok_params);

-- >>> 3. Add the dynamic trigger code as separate public procedures
--        loop for each dyn trig, calling a procedure to create appropriate  code
--
   hr_utility.set_location('  -Create dyt procedure code: '||l_proc,30);
    FOR dyt_rec in csr_dyts_on_table(l_tab_name)  LOOP
        gen_dyt_pkg_proc(dyt_rec.event_id,dyt_rec.short_name,
                             l_tab_name,dyt_rec.triggering_action,
                             dyt_rec.description,dyt_rec.info,
                             l_dyt_params,l_hs,l_bs);
        l_dyt_pkg_head_tbl(csr_dyts_on_table%ROWCOUNT) := l_hs;
        l_dyt_pkg_body_tbl(csr_dyts_on_table%ROWCOUNT) := l_bs;

        l_hs := '';l_bs :='';

    END LOOP;
    --
-- >>> 4. Add the wrapper procedures for row handler entry points
    -- Create the wrapper procedures that the rhi will call, these simply call
    -- the newly created, dynamic trigger code procedures
    -- Three times, one for each trigger type
    --
   hr_utility.set_location('  -Create hook entry point procedure code: '||l_proc,40);
    gen_dyt_pkg_rhi_proc(l_tab_name,'I','INSERT',l_hok_params,l_hs,l_bs,l_dyt_params, l_dyt_pkg_head_tbl, l_dyt_pkg_body_tbl, l_datetracked_table);
    l_hs := ''; l_bs := '';
    --
    gen_dyt_pkg_rhi_proc(l_tab_name,'U','UPDATE',l_hok_params,l_hs,l_bs,l_dyt_params, l_dyt_pkg_head_tbl, l_dyt_pkg_body_tbl, l_datetracked_table);
    l_hs := ''; l_bs := '';
    --
    gen_dyt_pkg_rhi_proc(l_tab_name,'D','DELETE',l_hok_params,l_hs,l_bs,l_dyt_params, l_dyt_pkg_head_tbl, l_dyt_pkg_body_tbl, l_datetracked_table);
    l_hs := ''; l_bs := '';


-- >>> 5.  Complete the package code
--
    l_hsql := ''; l_bsql := '';
    l_hsql := l_hsql||'END '||l_tab_dyt_pkg_name||';'||g_eol;
    l_bsql := l_bsql||'/*    END_PACKAGE     */'||g_eol;
    l_bsql := l_bsql||'END '||l_tab_dyt_pkg_name||';'||g_eol;
    l_dyt_pkg_head_tbl(l_dyt_pkg_head_tbl.last + 1) := l_hsql;
    l_dyt_pkg_body_tbl(l_dyt_pkg_body_tbl.last + 1) := l_bsql;


    -- This is the first time we will be adding to the g_dyt_pkg_head and g_dyt_pkg_head tables
    -- so empty first then add
    init_dyt_pkg;
    add_to_dyt_pkg(l_dyt_pkg_head_tbl,FALSE);
    add_to_dyt_pkg(l_dyt_pkg_body_tbl,TRUE);


-- >>> 6.  Generate and compile this new dynamic package
--
   hr_utility.set_location('  -Generate database package: '||l_proc,60);
    build_dyt_pkg_from_tbl( g_dyt_pkg_head,g_dyt_pkg_hindex,FALSE);
    build_dyt_pkg_from_tbl( g_dyt_pkg_body,g_dyt_pkg_bindex,TRUE);

-- >>> 7. Create database trigger equivalent of dyn-trigger if required
--        Go through recently cached cursor again
    p_ok := TRUE; --assume ok first, then test each as built
    --
    FOR dyt_rec in csr_dyts_on_table(l_tab_name)  LOOP
      l_dbt_name := get_trigger_name(dyt_rec.event_id,l_tab_name,dyt_rec.triggering_action);
      --
      IF ( l_tab_dyt_types = 'B') THEN
        gen_dyt_db_trig(dyt_rec.event_id,dyt_rec.short_name
                      ,l_tab_name, dyt_rec.triggering_action
                      ,dyt_rec.description,dyt_rec.info
                      ,l_dyt_params,l_tab_dyt_pkg_name);
        --Set db trigger to enabled as dependent on the dyn trigger value
        enable_trigger( l_dbt_name,flag_to_boolean(dyt_rec.enabled_flag) );

        --if so far all is well perform check on this new db trigger
        if (p_ok) then
          p_ok := module_ok(l_dbt_name,'TRIGGER');
        end if;

      ELSE
        --Package only then drop db trigs if they exist.
        drop_trigger(l_dbt_name);
        p_ok := TRUE;
      END IF;

    END LOOP;


-- >>> 8. Test how well package/triggers have been created and return some kind of status
--
    -- pkg
    l_head_ok := module_ok(l_tab_dyt_pkg_name,'PACKAGE');
    l_body_ok := module_ok(l_tab_dyt_pkg_name,'PACKAGE BODY');

    --Final return status is true only if all parts are success
    if (l_head_ok and l_body_ok and p_ok) then
      p_ok := TRUE;
      l_flag := 'Y';
    else
      p_ok :=FALSE;
      l_flag := 'N';
    end if;

   --hr_utility.set_location('  -Status of database package: '||l_flag||l_proc,80);
    --Complete FOR WHOLE TABLE, so mark pkg gen, and all dyt as generated + enabled or vice versa
    -- All or nothing, either all dyt's are success, or mark all as failure
     update pay_dated_tables
          set dyn_trig_pkg_generated = l_flag
     where table_name = l_tab_name
     and dated_table_id = l_tab_id;
     --
     FOR dyt_rec in csr_dyts_on_table(l_tab_name)  LOOP
       if (p_ok) then --success so back to original
        update pay_trigger_events
             set generated_flag = l_flag,
                 enabled_flag   = dyt_rec.enabled_flag
        where event_id = dyt_rec.event_id;
       else
        update pay_trigger_events  --failure so disabled
             set generated_flag = l_flag,
                 enabled_flag   = l_flag
        where event_id = dyt_rec.event_id;
       end if;

     END LOOP;
     commit; --make sure updates are saved
   hr_utility.set_location(' Leaving: '||l_proc,900);
  END gen_dyt_pkg_full_code;

-- +-----------------------------------------------------------------------------+
-- | NAME       : gen_dyt_pkg_proc                                               |
-- | SCOPE      : PRIVATE                                                        |
-- | DESCRIPTION: This procedure generates the code representing a single dynamic|
-- |      trigger.  All information declared in the dynamic triggers form is used|
-- |      to build up a package version of this trigger.   Parameter info is got |
-- |      from the table_event_updates form.                                     |
-- |              The actual components are built up using existing procedures   |
-- |      Namely, add_components,add_initialisations, but we have to modify the  |
-- |      resulting code slightly.                                               |
-- +-----------------------------------------------------------------------------+
  PROCEDURE gen_dyt_pkg_proc(p_dyt_id IN NUMBER,p_dyt_name IN VARCHAR2
                                ,p_tab_name IN VARCHAR2, p_dyt_act IN VARCHAR2
                                ,p_dyt_desc IN VARCHAR2,p_dyt_info IN VARCHAR2
                                ,p_dyn_pkg_params IN g_params_tab_type
                                ,p_hs IN OUT NOCOPY VARCHAR2
                                ,p_bs IN OUT NOCOPY VARCHAR2) IS
    --
    l_inits BOOLEAN;
    l_comps BOOLEAN;
    l_tab_name      pay_dated_tables.table_name%TYPE   := p_tab_name;
    l_dyt_id        pay_trigger_events.event_id%TYPE   := p_dyt_id;
    l_dyt_name      pay_trigger_events.short_name%TYPE := get_dyt_proc_name(p_dyt_name);
    l_dyt_act       pay_trigger_events.triggering_action%TYPE := p_dyt_act;
    l_dyt_info      varchar2(30) := p_dyt_info;
    l_dyt_desc      pay_trigger_events.description%TYPE := p_dyt_desc ;

    l_sql  varchar2(32000);   --Used as a temp holder.
    i number;
    j number;
    delim varchar2(15) := ' ';
    --
  BEGIN
    --
    -- Initialise the statement PL/SQL code
    p_hs := ''; p_bs := '';
    --
    --
    -- Add an initial comment section to the trigger code

    l_sql := l_sql||'/*'||g_eol;
    l_sql := l_sql||'  ================================================'||g_eol;
    l_sql := l_sql||'  This is a dynamically generated package procedure'||g_eol;
    l_sql := l_sql||'  with code representing a dynamic trigger        '||g_eol;
    l_sql := l_sql||'  ================================================'||g_eol;
    l_sql := l_sql||'            ** DO NOT CHANGE MANUALLY **          '||g_eol;
    l_sql := l_sql||'  ------------------------------------------------'||g_eol;
    l_sql := l_sql||'    Name:   '||l_dyt_name||g_eol;
    l_sql := l_sql||'    Table:  '||l_tab_name||g_eol;
    l_sql := l_sql||'    Action: '||l_dyt_info||g_eol;
    l_sql := l_sql||'    Generated Date:   '||TO_CHAR(SYSDATE,'DD/MM/YYYY HH24:MI')||g_eol;
    l_sql := l_sql||'    Description: '||l_dyt_desc||g_eol;
    l_sql := l_sql||'    Full trigger name: '||p_dyt_name||g_eol;
    l_sql := l_sql||'  ================================================'||g_eol;
    l_sql := l_sql||'*/'||g_eol||'--'||g_eol;
    --
    l_sql := l_sql||'PROCEDURE '||l_dyt_name||g_eol;
    -- Complete procedure definition, (still same for header and body)
    --
    --
    i := 0;
    while i < p_dyn_pkg_params.count LOOP
      --only need to print params that are relevant
      if (substr(p_dyn_pkg_params(i).usage_type,2,1) = l_dyt_act) then
        -- quick formatting option
        if (length(p_dyn_pkg_params(i).param_form) > 40) then
          j := 80; else j := 40;
        end if;
        --if first param then add opening bracket
        if (delim = ' ') then l_sql := l_sql || '('||g_eol;
        end if;
        l_sql := l_sql ||'   '||delim||rpad(p_dyn_pkg_params(i).param_form,j,' ')
                       ||' in '||p_dyn_pkg_params(i).data_type||g_eol;
        delim := ',';
      end if;
      i := i+1;
    end loop;

    --Only close bracket if had params
    if(delim = ',') then l_sql := l_sql ||' )'; end if;
    --End the header text, then continue with body, now create two distinct strings
    p_hs := l_sql||'; -- End of procedure definition for '||l_dyt_name||g_eos;
    p_bs := l_sql ||' IS '||g_eos;

    --
    -- Add the declaration section
        -- Do not need DECLARE before calling add_declarations
   	p_bs := p_bs||'  /* Local variable declarations */'||g_eol;

        -- Add the seeded declaration section
        add_declarations(l_dyt_id,p_bs);

        -- Add any hard-coded declarations
        -- n/a

    p_bs := p_bs||'BEGIN'||g_eol;
    --
    p_bs := p_bs||'  hr_utility.trace('' >DYT: Execute procedure version of Dynamic Trigger: '||p_dyt_name||''');'||g_eol;


    --
    -- Add the data migrator check - Bug 1885557
    p_bs := p_bs||'IF NOT (hr_general.g_data_migrator_mode <> ''Y'') THEN'||g_eol;
    p_bs := p_bs||'  RETURN;'||g_eol;
    p_bs := p_bs||'END IF;'||g_eol;
    -- Add the initialisation and component PL/SQL code
    l_inits := add_initialisations(l_dyt_id,p_bs,l_tab_name);
    l_comps := add_components(l_dyt_id,p_bs);
        --
    -- If we didn't add any initialisations or components then add a NULL
    -- operation to prevent compilation errors when triggers without any
    -- default initialisations are first created
    IF NOT l_inits AND NOT l_comps THEN
           p_bs := p_bs||'  NULL;'||g_eol;
    END IF;
    --

    -- Add a default exception block to catch all errors and write the
    -- trigger name and error text to the standard Oracle Apps error logging
    -- mechanism
        p_bs := p_bs||'EXCEPTION'||g_eol;
        p_bs := p_bs||'  WHEN OTHERS THEN'||g_eol;
        p_bs := p_bs||'    hr_utility.set_location('''||
                 l_dyt_name||''',ABS(SQLCODE));'||g_eol;
        p_bs := p_bs||'    RAISE;'||g_eol;
        p_bs := p_bs||'  --'||g_eol;
        p_bs := p_bs||'END '||l_dyt_name||';'||g_eos;

    --Before we return the sql, replace any instances of :new, :old; this is because
    --we have used the existing mechanism to get initialisations and components
    --and these may well rely on 'dbms trigger' notation, however we are using a dyt pkg
    get_dyt_pkg_version_of_code(p_bs,p_tab_name,p_dyt_act);
  END gen_dyt_pkg_proc;

-- +---------------------------------------------------------------------------+
-- | NAME       : gen_dyt_pkg_rhi_proc                                         |
-- | SCOPE      : PUBLIC                                                       |
-- | DESCRIPTION: See header                                                   |
-- +---------------------------------------------------------------------------+
  PROCEDURE gen_dyt_pkg_rhi_proc( p_tab_name IN VARCHAR2
                                ,p_dyt_act IN VARCHAR2 ,p_dyt_info IN VARCHAR2
                                ,p_hok_params IN g_params_tab_type
                                ,p_hs IN OUT NOCOPY VARCHAR2
                                ,p_bs IN OUT NOCOPY VARCHAR2
                                ,p_dyt_params IN g_params_tab_type
                                ,p_dyt_pkg_head_tbl IN OUT NOCOPY t_varchar2_32k_tbl
                                ,p_dyt_pkg_body_tbl IN OUT NOCOPY t_varchar2_32k_tbl
                                ,p_datetracked_table in VARCHAR2) IS
    --
    -- Get details of all dyn-triggers on given table,
    CURSOR csr_dyts_on_tab(cp_name in VARCHAR2,cp_action in VARCHAR2) IS
      SELECT  pte.event_id, pte.short_name,
              pte.triggering_action, pte.description,
              DECODE(pte.triggering_action, 'I','Insert','U','Update', 'D','Delete' ) info
      FROM    pay_trigger_events pte
      WHERE   pte.table_name = (cp_name)
      AND     pte.triggering_action = (cp_action)
      AND     nvl(pte.protected_flag,'N') <> 'Y';


    i number;
    j number;
    delim varchar2(15) := ' ';

  BEGIN
    --
    -- Add an initial comment section to the trigger code

    p_hs := p_hs||'/*'||g_eol;
    p_hs := p_hs||'  ================================================'||g_eol;
    p_hs := p_hs||'  This is a dynamically generated procedure.      '||g_eol;
    p_hs := p_hs||'  Will be called  by API.                         '||g_eol;
    p_hs := p_hs||'  ================================================'||g_eol;
    p_hs := p_hs||'            ** DO NOT CHANGE MANUALLY **          '||g_eol;
    p_hs := p_hs||'  ------------------------------------------------'||g_eol;
    p_hs := p_hs||'    Name:   AFTER_'||upper(p_dyt_info)||g_eol;
    p_hs := p_hs||'    Table:  '||p_tab_name||g_eol;
    p_hs := p_hs||'    Action: '||p_dyt_info||g_eol;
    p_hs := p_hs||'    Generated Date:   '||TO_CHAR(SYSDATE,'DD/MM/YYYY HH24:MI')||g_eol;
    p_hs := p_hs||'    Description: Called as part of '||p_dyt_info||' process'||g_eol;
    p_hs := p_hs||'  ================================================'||g_eol;
    p_hs := p_hs||'*/'||g_eos;
    --
    p_hs := p_hs||'PROCEDURE AFTER_'||upper(p_dyt_info)||g_eol;
    -- Complete procedure definition, (still same for header and body)
    --
    --
    i := 0;

    while i < p_hok_params.count LOOP
      --only need to print params that are relevant
      if (substr(p_hok_params(i).usage_type,2,1) = p_dyt_act) then
        -- quick formatting option
        if (length(p_hok_params(i).value_name) > 40) then
          j := 80; else j := 40;
        end if;
        if (delim = ' ') then p_hs := p_hs || '('||g_eol;
        end if;

        p_hs := p_hs ||'   '||delim||rpad(p_hok_params(i).value_name,j,' ')
                     ||' in '||p_hok_params(i).data_type||g_eol;
        delim := ',';

      end if;
      i := i+1;
    end loop;

    p_hs := p_hs ||' )';

    --End the header text, then continue with body, create two distinct strings
    p_bs := p_hs ||' IS '||g_eol;
    p_bs := p_bs ||'  l_mode  varchar2(80);'||g_eos;
    p_bs := p_bs ||' BEGIN'||g_eos;

    p_bs := p_bs||'    hr_utility.trace('' >DYT: Main entry point from row handler, AFTER_'||p_dyt_info||''');'||g_eol;

    p_hs := p_hs||'; -- End of procedure definition for AFTER_'||upper(p_dyt_info)||g_eos;

    --Create main body code, i.e. call to newly created dyn-trigger procedure(s).
    --

    p_bs := p_bs ||'  /* Mechanism for event capture to know whats occurred */'||g_eol;
    p_bs := p_bs ||'  l_mode := pay_dyn_triggers.g_dyt_mode;'||g_eol;
    if (upper(p_dyt_info) = 'INSERT') then
      p_bs := p_bs ||'  pay_dyn_triggers.g_dyt_mode := hr_api.g_insert;'||g_eos;
    else
      if (p_datetracked_table = 'Y') then
        p_bs := p_bs ||'  pay_dyn_triggers.g_dyt_mode := p_datetrack_mode;'||g_eos;
      else
         if (upper(p_dyt_info) = 'UPDATE') then
           p_bs := p_bs ||'  pay_dyn_triggers.g_dyt_mode := hr_api.g_correction;'||g_eos;
         else
           p_bs := p_bs ||'  pay_dyn_triggers.g_dyt_mode := hr_api.g_zap;'||g_eos;
         end if;
      end if;
    end if;
--
    -- Save the header details.
    p_dyt_pkg_head_tbl(p_dyt_pkg_head_tbl.last + 1) := p_hs;
    p_hs := '';
--
    delim := 'X'; --will be reset if we have any dyt's
    FOR dyt_rec IN csr_dyts_on_tab(p_tab_name,p_dyt_act) LOOP
      delim :=' '; i := 0;--reset counters

      -- Save the body details
      p_dyt_pkg_body_tbl(p_dyt_pkg_body_tbl.last + 1) := p_bs;
      p_bs := '';
--
      p_bs := '  if (paywsdyg_pkg.trigger_enabled('''
                  ||dyt_rec.short_name||''')) then'||g_eol;
      p_bs := p_bs||'    '||get_dyt_proc_name(dyt_rec.short_name)||'('||g_eol;

      -- build up params for call to newly created procedure
      WHILE i < p_dyt_params.count LOOP
        --only need to print params that are relevant for this action
        --though may not be strictly relevant for this dyn trig as we just pass all
        if (substr(p_dyt_params(i).usage_type,2,1) = p_dyt_act) then
          --
          if (length(p_dyt_params(i).param_form) > 40) then -- quick formatting option
            j := 80; else j := 40;
          end if;
          p_bs := p_bs ||'     '||delim||rpad(p_dyt_params(i).param_form,j,' ')
                       ||' => '||p_dyt_params(i).value_name||g_eol;
          delim := ',';
        end if;

        i := i+1;
       END LOOP;
    p_bs := p_bs ||'    );'||g_eol||'  end if;'||g_eos;
    END LOOP;
    -- Written all calls to newly created relevant dyn-trigger, if none add null
    --
    if (delim = 'X') then
      p_bs := p_bs ||'  /* no calls => no dynamic triggers of this type on this table */';
      p_bs := p_bs ||g_eol||'  null;'||g_eos;
    end if;
    --Reset the flag
    p_bs := p_bs||'  pay_dyn_triggers.g_dyt_mode := l_mode;'||g_eos;

    -- Add a default exception block to catch all errors and write the
    -- trigger name and error text to the standard Oracle Apps error log
        p_bs := p_bs||'EXCEPTION'||g_eol;
        p_bs := p_bs||'  WHEN OTHERS THEN'||g_eol;
        p_bs := p_bs||'    hr_utility.set_location('''||
                 'AFTER_'||upper(p_dyt_info)||''',ABS(SQLCODE));'||g_eol;
        p_bs := p_bs||'    pay_dyn_triggers.g_dyt_mode := l_mode;'||g_eol;
        p_bs := p_bs||'    RAISE;'||g_eol;
        p_bs := p_bs||'  --'||g_eol;

    p_bs := p_bs ||'END  AFTER_'||upper(p_dyt_info)||';'||g_eos;

    -- Save the body details
    p_dyt_pkg_body_tbl(p_dyt_pkg_body_tbl.last + 1) := p_bs;
    p_bs := '';

  END gen_dyt_pkg_rhi_proc;

-- +---------------------------------------------------------------------------+
-- | NAME       : gen_dyt_db_trig                                              |
-- | SCOPE      : PUBLIC                                                       |
-- | DESCRIPTION: See header                                                   |
-- +---------------------------------------------------------------------------+
  PROCEDURE gen_dyt_db_trig(p_dyt_id IN NUMBER,p_dyt_name IN VARCHAR2
                                ,p_tab_name IN VARCHAR2, p_dyt_act IN VARCHAR2
                                ,p_dyt_desc IN VARCHAR2,p_dyt_info IN VARCHAR2
                                ,p_dyn_pkg_params IN g_params_tab_type
                                ,p_tab_dyt_pkg_name  in varchar2
                                ) IS
    --
    l_dyt_name      pay_trigger_events.short_name%TYPE := get_dyt_proc_name(p_dyt_name);
    l_sql  varchar2(32000);   --Used as a temp holder.
    l_dbt_name  varchar2(80);
    i number;
    j number;
    delim varchar2(15) := ' ';

  BEGIN
    l_dbt_name := get_trigger_name(p_dyt_id,p_tab_name,p_dyt_act);
    --
    -- Add an initial comment section to the trigger code

    l_sql := l_sql||'/*'||g_eol;
    l_sql := l_sql||'  ================================================'||g_eol;
    l_sql := l_sql||'  This is a dynamically generated database trigger'||g_eol;
    l_sql := l_sql||'  ================================================'||g_eol;
    l_sql := l_sql||'            ** DO NOT CHANGE MANUALLY **          '||g_eol;
    l_sql := l_sql||'  ------------------------------------------------'||g_eol;
    l_sql := l_sql||'    Trigger:  '||l_dbt_name||g_eol;
    l_sql := l_sql||'    Table:  '||p_tab_name||g_eol;
    l_sql := l_sql||'    Action: '||p_dyt_info||g_eol;
    l_sql := l_sql||'    Generated Date:   '||TO_CHAR(SYSDATE,'DD/MM/YYYY HH24:MI')||g_eol;
    l_sql := l_sql||'    Description: If enabled, this trigger will be '||g_eol;
    l_sql := l_sql||'      called as part of '||p_dyt_info||' process. '||g_eol;
    l_sql := l_sql||'  ================================================'||g_eol;
    l_sql := l_sql||'*/'||g_eos;
    l_sql := l_sql||'DECLARE'||g_eol;
    l_sql := l_sql||'  l_mode  varchar2(80);'||g_eol;
    l_sql := l_sql||'BEGIN'||g_eol;
    --
    l_sql := l_sql||'  l_mode := pay_dyn_triggers.g_dyt_mode;'||g_eol;
    l_sql := l_sql||'  pay_dyn_triggers.g_dyt_mode := pay_dyn_triggers.g_dbms_dyt;'||g_eol;

 l_sql := l_sql||'  IF NOT (hr_general.g_data_migrator_mode <> ''Y'') THEN'||g_eol;
    l_sql := l_sql||'    RETURN;'||g_eol;
    l_sql := l_sql||'  END IF;'||g_eos;

    -- Code call to newly created procedure
    --
    l_sql := l_sql||p_tab_dyt_pkg_name||'.'||l_dyt_name||'('||g_eol;
    --
    -- build up params from those entered in dated tables form
    i := 0; delim :=' ';

    while i < p_dyn_pkg_params.count LOOP
      --only need to print params that are relevant
      if (substr(p_dyn_pkg_params(i).usage_type,2,1) = p_dyt_act) then
        --Need to create the mock rhi-hook control params
        --NB think P_NEW_EFFECTIVE_DATE is now redundant, but leave in as no overhead
        --
        if (upper(p_dyn_pkg_params(i).param_form) = 'P_NEW_EFFECTIVE_DATE') then
          l_sql := l_sql ||'   '||delim||rpad(p_dyn_pkg_params(i).param_form,40,' ')
                     ||' => :new.effective_start_date'||g_eol;
          delim := ',';
        elsif  (upper(p_dyn_pkg_params(i).param_form) = 'P_NEW_DATETRACK_MODE') then
          l_sql := l_sql ||'   '||delim||rpad(p_dyn_pkg_params(i).param_form,40,' ')
                     ||' => pay_dyn_triggers.g_dbms_dyt'||g_eol;
          delim := ',';
        else  --MAIN useful db cols
         -- quick formatting option
          if (length(p_dyn_pkg_params(i).param_form) > 40) then
            j := 80; else j := 40;
          end if;
          l_sql := l_sql ||'   '||delim||rpad(p_dyn_pkg_params(i).param_form,j,' ')
                       ||' => '||p_dyn_pkg_params(i).local_form||g_eol;
          delim := ',';
        end if;
      end if;

      i := i+1;
    end loop;

    --End the trigger text
    l_sql := l_sql||'); -- End of call to dynamic trigger code stored in package '||g_eos;
    l_sql := l_sql||'  pay_dyn_triggers.g_dyt_mode := l_mode;'||g_eol;

    -- Add a default exception block to catch all errors and write the
    -- trigger name and error text to the standard Oracle Apps error log
        l_sql := l_sql||'EXCEPTION'||g_eol;
        l_sql := l_sql||'  WHEN OTHERS THEN'||g_eol;
        l_sql := l_sql||'    hr_utility.set_location('''||
                 l_dbt_name||''',ABS(SQLCODE));'||g_eol;
        l_sql := l_sql||'    pay_dyn_triggers.g_dyt_mode := l_mode;'||g_eol;
        l_sql := l_sql||'    RAISE;'||g_eol;
        l_sql := l_sql||'  --'||g_eol;

    l_sql := l_sql||'END;'||g_eol;

    --Use common procedure to create trigger
    --
    create_trigger(l_dbt_name,p_tab_name,p_dyt_act,l_sql);
  end gen_dyt_db_trig;

-- +---------------------------------------------------------------------------+
-- | NAME       : trigger_enabled                                              |
-- | SCOPE      : PUBLIC                                                       |
-- | DESCRIPTION: Simply returns boolean to see if dyn trigger is enabled.     |
-- |              Called by dynamically created rhi proc in dynamic package    |
-- | PARAMETERS : p_dyt      - The dynamic trigger name                        |
-- | RETURNS    : TRUE if trigger is enabled, FALSE otherwise                  |
-- | RAISES     : None                                                         |
-- +---------------------------------------------------------------------------+
FUNCTION trigger_enabled(p_dyt varchar2) return BOOLEAN
IS
  cursor csr_enabled(cp_dyt varchar2) is
    SELECT enabled_flag
    FROM pay_trigger_events
    where short_name = cp_dyt;

  l_flag varchar2(1);

BEGIN
  open csr_enabled(p_dyt);
  fetch csr_enabled into l_flag;
  close csr_enabled;
  return (flag_to_boolean(l_flag));

END trigger_enabled;

-- +---------------------------------------------------------------------------+
-- | name       : convert_tab_style                                            |
-- | scope      : public                                                       |
-- | description: there are times when the seeded behaviour needs to be altered|
-- |  usually as a result of release issues.  this procedure provides a quick  |
-- |  wrapper utility to change a dated table from dbms_dyt to dyt_pkg and vice|
-- |  versa.
-- | parameters : p_table_name  - the dated table name                         |
-- |            : p_dyt_type    - eg t<dbms trigger> p<ackage> b<oth>          |
-- | returns    : none
-- | raises     : none                                                         |
-- +---------------------------------------------------------------------------+
procedure convert_tab_style(p_table_name in varchar2,p_dyt_type in varchar2)
is

  l_name  varchar2(240);
  l_hooks varchar2(15);
  l_ok    boolean;
  l_api_module_id number;

  cursor csr_dyt_ids(cp_table_name in varchar2) is
    select event_id,short_name from pay_trigger_events
    where table_name = cp_table_name;
  cursor csr_get_id is
    select api_module_id
    from hr_api_modules
    where module_name = p_table_name;

begin
  hr_utility.trace('>>> set table '||p_table_name||' to be style '||p_dyt_type);
  --
  update pay_dated_tables
    set dyn_trigger_type = p_dyt_type, dyn_trig_pkg_generated = 'N'
  where table_name = p_table_name;

  hr_utility.trace(' creating dyt triggers...');
  --
  for dyt_record in csr_dyt_ids(p_table_name) loop
    paywsdyg_pkg.generate_trigger(
      dyt_record.event_id,
      l_name,
      l_ok);
    hr_utility.trace(' just created a dynamic trigger for id: '||dyt_record.event_id||', dyt_name: '||dyt_record.short_name||', into: '||l_name);
    if (p_dyt_type = 'P') then exit; end if;
   end loop;
   hr_utility.trace('>>> completed trigger building for table '||p_table_name);


    if (p_dyt_type = 'P') then
      l_hooks := 'Y';
    else
      l_hooks := 'N';
    end if;

    update hr_api_hook_calls
    set enabled_flag = l_hooks
    where api_hook_call_id in (
        select api_hook_call_id
        from hr_api_hook_calls ahc,
          hr_api_hooks ah,
          hr_api_modules am
        where ahc.api_hook_id = ah.api_hook_id
        and ah.api_module_id = am.api_module_id
        and ahc.call_package = (select dyn_trigger_package_name
                          from pay_dated_tables
                          where table_name = am.module_name)
        and am.module_name = p_table_name );

   for module in csr_get_id loop
    --Rebuild Hooks Packages
    hr_api_user_hooks_utility.create_hooks_add_report(l_api_module_id);

   end loop;

end convert_tab_style;

-- +---------------------------------------------------------------------------+
-- | name       : confirm_dyt_data                                            |
-- | scope      : public    (Use cautiously, designed as dev util)             |
-- | description: there are times when the seeded behaviour needs to be altered|
-- |  usually as a result of release issues.  this procedure checks the data
-- | for a given table and depending on the main switch (hook calls to DYT_PKG)
-- | rebuilds the data for DYT_PKG behaviour (if calls existed) or DBMS dynamic
-- | triggers (if no calls existed)
-- | parameters : p_table_name  - the dated table name                         |
-- | returns    : none
-- | raises     : none                                                         |
-- +---------------------------------------------------------------------------+
PROCEDURE confirm_dyt_data(p_table_name in varchar2) is

l_reqd_format    varchar2(1);  --EG will be set to 'T' dbms Trigger, 'P' Package
l_current_format varchar2(1);
l_dyt_pkg_exists varchar2(1);  --EG will be set to 'Y' or 'N'


cursor csr_dyt_pkg_hook is
  select count(*)
  from hr_api_hook_calls ahc,
    hr_api_hooks ah,
    hr_api_modules am
  where ahc.api_hook_id = ah.api_hook_id
  and ah.api_module_id = am.api_module_id
  and ahc.call_package = (select dyn_trigger_package_name
                    from pay_dated_tables
                    where table_name = am.module_name)
  and am.module_name = p_table_name;
 l_hook_count     number;

  cursor csr_tab_details is
    select dated_table_id,dyn_trigger_type,dyn_trigger_package_name,dyn_trig_pkg_generated
    from pay_dated_tables
    where table_name = p_table_name;
 l_dt_id        pay_dated_tables.dated_table_id%type;
 l_dt_dyt_type  pay_dated_tables.dyn_trigger_type%type;
 l_dt_pkg_name  pay_dated_tables.dyn_trigger_package_name%type;
 l_dt_pkg_gen   pay_dated_tables.dyn_trig_pkg_generated%type;

  cursor csr_pkg_exist(cp_pkg in varchar2) is
    select status from user_objects
    where object_type = 'PACKAGE BODY'
    and  object_name = cp_pkg;
  l_pkg_status   all_objects.status%type;

  l_need_rebuild_flag varchar2(15) := 'N';
  l_result boolean;
  l_prod_status    varchar2(1);
  l_industry       varchar2(1);

  l_proc varchar2(240) := g_package||'.confirm_dyt_data';
BEGIN
  hr_utility.set_location(l_proc,10);
--
-- >>> PHASE 1: Decide what is the reqd format for this table for dynamic trigger
--
  open  csr_dyt_pkg_hook;
  fetch csr_dyt_pkg_hook into l_hook_count;
  close csr_dyt_pkg_hook;

  hr_utility.trace( '- Decision on what is the required behaviour based on enabled hook count.');
  if (l_hook_count > 0) then
    l_reqd_format := 'P';
  else
    l_reqd_format := 'T';
  end if;
  hr_utility.trace( '- Hook count is '||l_hook_count||' so REQD behaviour is '||l_reqd_format);


-- >>> PHASE 2: Get the exisitng information for this table
--
  open  csr_tab_details;
  fetch csr_tab_details into l_dt_id, l_dt_dyt_type, l_dt_pkg_name, l_dt_pkg_gen;
  close csr_tab_details;
  hr_utility.trace( '- Dated table id '||l_dt_id||' has SEEDED behaviour '||l_dt_dyt_type);

  open  csr_pkg_exist(l_dt_pkg_name);
  fetch csr_pkg_exist into l_pkg_status;
  close csr_pkg_exist;

  if (l_pkg_status is null) then l_pkg_status := 'NONE';
  end if;
  --hr_utility.trace( '- DYT_PKG '||l_dt_pkg_name||' has status '||l_pkg_status);

--Now do phase 3 if l_reqd_format = T, phase 4 if its = P
  if (l_reqd_format = 'T') then
-- >>> PHASE 3: Deal with situation where we wish for NO dyt_pkg
--
--                 ||  The DYT_PKG exists   ||  No DYT_PKG exists   ||
--++===============||===============================================||
--   Table is also || [A]  bit odd          || [B] Perfect          ||
--   set to T      ||  no danger            ||    Behaviour         ||
--   eg dbms_dyt   ||  => nothing           ||                      ||
--++===============||=======================||======================||
--   Table is NOT  || [C] Bad               || [D] Very Bad         ||
--   set to T      ||  => change table to   ||   => change table to ||
--   eg dyt_pkg    ||    be dbms style      ||     be dbms style    ||
--++===============++===============================================++
    hr_utility.trace(' NO HOOKS so desired DBMS style dynamic triggers.');
    hr_utility.trace( p_table_name||' has style set to '||l_dt_dyt_type||' and the dyt_pkg is '||l_pkg_status);
    if    (l_dt_dyt_type   = 'T' and l_pkg_status = 'VALID') then
      l_need_rebuild_flag := 'N'; --odd but not terminal

    elsif (l_dt_dyt_type   = 'T' and l_pkg_status <> 'VALID') then
      hr_utility.trace( p_table_name||' has perfect dynamic trigger data');
      l_need_rebuild_flag := 'N'; --odd but not terminal
    --
    elsif (l_dt_dyt_type   = 'P' and l_pkg_status = 'VALID') then
      l_need_rebuild_flag := 'Y'; -- BAD so change to dbms triggers
    --
    elsif (l_dt_dyt_type   = 'P' and l_pkg_status <> 'VALID') then
      l_need_rebuild_flag := 'Y'; -- BAD so change to dbms triggers
    --
    end if;
  elsif (l_reqd_format = 'P') then
-- >>> PHASE 4: Deal with situation where we wish for a dyt_pkg
--
--                 ||  The DYT_PKG exists   ||  No DYT_PKG exists   ||
--++===============||===============================================||
--   Table is also || [A]  bit odd          || [B] Bad              ||
--   set to T      ||  pkg exists and calls ||    hooks will fail   ||
--   eg dbms_dyt   ||  => change to dyt_pkg || => change to dyt_pkg ||
--++===============||=======================||======================||
--   Table is NOT  || [C] Perfect           || [D] Very Bad         ||
--   set to T      ||                       ||   hooks will fail    ||
--   eg dyt_pkg    ||                       || => change to dyt_pkg ||
--++===============++===============================================++

    hr_utility.trace(' HOOKS EXIST so desired DYT_PKG style dynamic triggers.');
    hr_utility.trace( p_table_name||' has style set to '||l_dt_dyt_type||' and the dyt_pkg is '||l_pkg_status);
    if      (l_dt_dyt_type = 'T' and l_pkg_status = 'VALID') then
      l_need_rebuild_flag := 'Y'; -- BAD so change to dyt_pkg
    --
    elsif   (l_dt_dyt_type = 'T' and l_pkg_status <> 'VALID') then
      l_need_rebuild_flag := 'Y'; -- BAD so change to dyt_pkg
    --
    elsif   (l_dt_dyt_type = 'P' and l_pkg_status = 'VALID') then
      l_need_rebuild_flag := 'N';
      hr_utility.trace( p_table_name||' has perfect dynamic trigger data');
    --
    elsif   (l_dt_dyt_type = 'P' and l_pkg_status <> 'VALID') then
      l_need_rebuild_flag := 'Y'; -- BAD so change to dyt_pkg
    --
    end if;
  end if;

  if (l_need_rebuild_flag = 'Y') then
     paywsdyg_pkg.convert_tab_style(
        p_table_name => p_table_name,
        p_dyt_type   => l_reqd_format);
  end if;

  -- To cover the exception to the rule...namely pay_element_entry_values_f
  -- which does not have hooks and thus this procedure should never be called for
  -- this table.  If this is called for pay_element_entries_f then make the
  -- vals table have the same behaviour.
  if (p_table_name = 'PAY_ELEMENT_ENTRIES_F') then
    paywsdyg_pkg.convert_tab_style(
        p_table_name => 'PAY_ELEMENT_ENTRY_VALUES_F',
        p_dyt_type   => l_reqd_format);
  end if;

  hr_utility.set_location(l_proc,900);
END  confirm_dyt_data;

--
--
-- does declaration exist for the specified variable
        function is_not_declared(p_id in number,p_name in varchar2) return boolean is
                --
                cursor csr_pay(cp_id in number,cp_name in varchar2) is
                        select  'x'
                        from            pay_trigger_declarations
                        where           variable_name = cp_name
                        and                     event_id = cp_id;
                --
                l_cx varchar2(1);
                l_rc boolean;
        begin
                open csr_pay(p_id,p_name);
                fetch csr_pay into l_cx;
                if csr_pay%notfound then
                        l_rc := true;
                else
                        l_rc := false;
                end if;
                close csr_pay;
                --
                return l_rc;
        end is_not_declared;

--
-- if the table's got a business group id then that's fine,
-- otherwise check if the user has defined their own local
-- variable that we can use
        function no_business_context(p_table in varchar2,p_id in number) return boolean is
                l_rc boolean;
        begin
                if table_has_business_group(p_table) then
                        l_rc := false;
                else
                        l_rc := is_not_declared(p_id,'business_group_id');
                end if;
                --
                return l_rc;
        end no_business_context;
--
-- if the table's got a business group id then that's fine,
-- otherwise check if the user has defined their own local
-- variable that we can use
        function no_legislation_context(p_table in varchar2,p_id in number) return boolean is
                l_rc boolean;
        begin
                if table_has_business_group(p_table) then
                        l_rc := false;
                else
                        l_rc := is_not_declared(p_id,'legislation_code');
                end if;
                --
                return l_rc;
        end no_legislation_context;
--
-- if the table's got a payroll id then that's fine,
-- otherwise check if the user has defined their own local
-- variable that we can use
        function no_payroll_context(p_table in varchar2,p_id in number) return boolean is
                --
                l_rc boolean;
        begin
                if table_has_payroll(p_table) then
                        l_rc := false;
                else
                        l_rc := is_not_declared(p_id,'payroll_id');
                end if;
                --
                return l_rc;
        end no_payroll_context;
--
procedure ins(
        p_event_id           in number,
        p_table_name         in varchar2,
        p_short_name         in varchar2,
        p_description        in varchar2,
        p_generated_flag     in varchar2,
        p_enabled_flag       in varchar2,
        p_protected_flag     in varchar2,
        p_triggering_action  in varchar2,
        p_last_update_date   in date,
        p_last_updated_by    in number,
        p_last_update_login  in number,
        p_created_by         in number,
        p_creation_date      in date
) is
begin
        insert into pay_trigger_events (
                event_id,
                table_name,
                short_name,
                description,
                generated_flag,
                enabled_flag,
                protected_flag,
                triggering_action,
                last_update_date,
                last_updated_by,
                last_update_login,
                created_by,
                creation_date
        ) values (
                p_event_id,
                p_table_name,
                p_short_name,
                p_description,
                p_generated_flag,
                p_enabled_flag,
                p_protected_flag,
                p_triggering_action,
                p_last_update_date,
                p_last_updated_by,
                p_last_update_login,
                p_created_by,
                p_creation_date
        );
end ins;
--
procedure upd(
        p_event_id           in number,
        p_table_name         in varchar2,
        p_short_name         in varchar2,
        p_description        in varchar2,
        p_generated_flag     in varchar2,
        p_enabled_flag       in varchar2,
        p_protected_flag     in varchar2,
        p_triggering_action  in varchar2,
        p_last_update_date   in date,
        p_last_updated_by    in number,
        p_last_update_login  in number,
        p_created_by         in number,
        p_creation_date      in date
) is
begin
        update  pay_trigger_events
        set     table_name              = p_table_name,
                short_name              = p_short_name,
                description             = p_description,
                generated_flag          = p_generated_flag,
                enabled_flag            = p_enabled_flag,
                protected_flag          = p_protected_flag,
                triggering_action       = p_triggering_action,
                last_update_date        = p_last_update_date,
                last_updated_by         = p_last_updated_by,
                last_update_login       = p_last_update_login,
                created_by              = p_created_by,
                creation_date           = p_creation_date
        where   event_id                = p_event_id;
end upd;
--
procedure del(
        p_event_id           in number
) is
begin
      delete from       pay_trigger_events
      where             event_id = p_event_id;
end del;
--
procedure lck(
        p_event_id           in number
) is
  cursor c_sel1 is
    select      *
    from        pay_trigger_events
    where       event_id = p_event_id
    for update nowait;
    l_old_rec c_sel1%rowtype;
--
begin
  --
  open  c_sel1;
  fetch c_sel1 into l_old_rec;
  if c_sel1%notfound then
    close c_sel1;
    --
    -- the primary key is invalid therefore we must error
    --
    fnd_message.set_name('pay', 'hr_7220_invalid_primary_key');
    fnd_message.raise_error;
  end if;
  close c_sel1;
  --
  --
  -- we need to trap the ora lock exception
  --
exception
  when hr_api.object_locked then
    --
    -- the object is locked therefore we need to supply a meaningful
    -- error message.
    --
    fnd_message.set_name('pay', 'hr_7165_object_locked');
    fnd_message.set_token('table_name', 'pay_trigger_events');
    fnd_message.raise_error;
end lck;
--
FUNCTION is_table_valid(p_table IN VARCHAR2) RETURN VARCHAR2 IS
  --
  l_rc NUMBER(15);
  --
  CURSOR csr_chk_tabname IS
    SELECT 1
    FROM   dual
    WHERE EXISTS (
      SELECT 1
      FROM   fnd_tables tab
      WHERE  tab.table_name = p_table
      AND    (tab.application_id BETWEEN 800 AND 810
             OR tab.application_id IN (8301,453,8302,8303,8403,203))
    );
  --
  CURSOR csr_get_tabapp IS
    SELECT application_id
    FROM   fnd_tables
    WHERE  table_name = p_table
    AND    ((application_id < 800 OR application_id > 810)
             AND application_id NOT IN (8301,453,8302,8303,8403,203));
  --
BEGIN
  --
  OPEN csr_chk_tabname;
  FETCH csr_chk_tabname INTO l_rc;
  IF csr_chk_tabname%NOTFOUND THEN
    CLOSE csr_chk_tabname;
    --
    -- Not in normal range get the app id and check the profile
    OPEN csr_get_tabapp;
    FETCH csr_get_tabapp INTO l_rc;
    IF csr_get_tabapp%NOTFOUND THEN
      CLOSE csr_get_tabapp;
      RETURN 'N';
    END IF;
    CLOSE csr_get_tabapp;
    --
    IF 'Y' = Fnd_Profile.Value_Specific(name=>'PAY_ENABLE_DYNAMIC_TRIGGERS',
      application_id=>l_rc)
    THEN
      RETURN 'Y';
    END IF;
    --
    RETURN 'N';
  END IF;
  --
  CLOSE csr_chk_tabname;
  RETURN 'Y';
END is_table_valid;
--
FUNCTION is_table_column_valid(p_table IN VARCHAR2,p_column IN VARCHAR2) RETURN VARCHAR2 IS
  --
  l_rc       NUMBER(15);
  --
  CURSOR csr_chk_column IS
    SELECT 1
    FROM   dual
    WHERE EXISTS (
      SELECT 1
      FROM   fnd_columns col,fnd_tables tab
      WHERE  tab.table_name = p_table
      AND    col.table_id = tab.table_id
      AND    col.application_id = tab.application_id
      AND    col.column_name = p_column
      AND    (tab.application_id BETWEEN 800 AND 810
             OR tab.application_id IN (8301,453,8302,8303,8403,203))
    );
  --
  CURSOR csr_get_colapp IS
    SELECT tab.application_id
    FROM   fnd_columns col,fnd_tables tab
    WHERE  tab.table_name = p_table
    AND    col.table_id = tab.table_id
    AND    col.application_id = tab.application_id
    AND    ((tab.application_id < 800 OR tab.application_id > 810)
           AND tab.application_id NOT IN (8301,453,8302,8303,8403,203))
    AND    col.column_name = p_column;
  --
BEGIN
  --
  OPEN csr_chk_column;
  FETCH csr_chk_column INTO l_rc;
  IF csr_chk_column%NOTFOUND THEN
    CLOSE csr_chk_column;
    --
    -- Not in normal range get the app id and check the profile
    OPEN csr_get_colapp;
    FETCH csr_get_colapp INTO l_rc;
    IF csr_get_colapp%NOTFOUND THEN
      CLOSE csr_get_colapp;
      RETURN 'N';
    END IF;
    CLOSE csr_get_colapp;
    --
    IF 'Y' = Fnd_Profile.Value_Specific(name=>'PAY_ENABLE_DYNAMIC_TRIGGERS',
      application_id=>l_rc)
    THEN
      RETURN 'Y';
    END IF;
    --
    RETURN 'N';
  END IF;
  --
  CLOSE csr_chk_column;
  RETURN 'Y';
END is_table_column_valid;
--
FUNCTION is_table_owner_valid(p_table IN VARCHAR2,p_owner IN VARCHAR2) RETURN VARCHAR2 IS
  --
  l_rc   NUMBER(15);
  --
  CURSOR csr_chk_owner IS
    SELECT 1
    FROM   dual
    WHERE EXISTS (
      SELECT 1
      FROM   fnd_tables tab,
             fnd_product_installations prd,
             fnd_oracle_userid usr
      WHERE  tab.table_name = p_table
      AND    tab.application_id = prd.application_id
      AND    (prd.application_id BETWEEN 800 AND 810
             OR prd.application_id IN (8301,453,8302,8303,8403,203))
      AND    usr.oracle_id = prd.oracle_id
      AND    usr.oracle_username = p_owner
    );
  --
  CURSOR csr_get_ownapp IS
    SELECT prd.application_id
    FROM   fnd_tables tab,
           fnd_product_installations prd,
           fnd_oracle_userid usr
    WHERE  tab.table_name = p_table
    AND    tab.application_id = prd.application_id
    AND    ((prd.application_id < 800 OR prd.application_id > 810)
           AND prd.application_id NOT IN (8301,453,8302,8303,8403,203))
    AND    usr.oracle_id = prd.oracle_id
    AND    usr.oracle_username = p_owner;
  --
BEGIN
  OPEN csr_chk_owner;
  FETCH csr_chk_owner INTO l_rc;
  IF csr_chk_owner%NOTFOUND THEN
    CLOSE csr_chk_owner;
    --
    -- Not in normal range, get app id and check profile
    OPEN csr_get_ownapp;
    FETCH csr_get_ownapp INTO l_rc;
    IF csr_get_ownapp%NOTFOUND THEN
      CLOSE csr_get_ownapp;
      RETURN 'N';
    END IF;
    CLOSE csr_get_ownapp;
    --
    IF 'Y' = Fnd_Profile.Value_Specific(name=>'PAY_ENABLE_DYNAMIC_TRIGGERS',
      application_id=>l_rc)
    THEN
      RETURN 'Y';
    END IF;
    --
    RETURN 'N';
    --
  END IF;
  CLOSE csr_chk_owner;
  --
  RETURN 'Y';
END is_table_owner_valid;
--
FUNCTION get_table_owner(p_table IN VARCHAR2) RETURN VARCHAR2 IS
  --
  l_schema   VARCHAR2(30);
  l_app      NUMBER(15);
  --
  CURSOR csr_get_owner IS
    SELECT usr.oracle_username
    FROM   fnd_tables tab,
           fnd_product_installations prd,
           fnd_oracle_userid usr
    WHERE  tab.table_name = p_table
    AND    tab.application_id = prd.application_id
    AND    (prd.application_id BETWEEN 800 AND 810
           OR prd.application_id IN (8301,453,8302,8303,8403,203))
    AND    usr.oracle_id = prd.oracle_id;
  --
  CURSOR csr_get_ownex IS
    SELECT usr.oracle_username,
           prd.application_id
    FROM   fnd_tables tab,
           fnd_product_installations prd,
           fnd_oracle_userid usr
    WHERE  tab.table_name = p_table
    AND    tab.application_id = prd.application_id
    AND    ((prd.application_id < 800 OR prd.application_id > 810)
           AND prd.application_id NOT IN (8301,453,8302,8303,8403,203))
    AND    usr.oracle_id = prd.oracle_id;
  --
BEGIN
  OPEN csr_get_owner;
  FETCH csr_get_owner INTO l_schema;
  IF csr_get_owner%NOTFOUND THEN
    CLOSE csr_get_owner;
    --
    OPEN csr_get_ownex;
    FETCH csr_get_ownex INTO l_schema,l_app;
    IF csr_get_ownex%NOTFOUND THEN
      CLOSE csr_get_ownex;
      RETURN NULL;
    END IF;
    CLOSE csr_get_ownex;
    --
    IF 'Y' = Fnd_Profile.Value_Specific(name=>'PAY_ENABLE_DYNAMIC_TRIGGERS',
      application_id=>l_app)
    THEN
      RETURN l_schema;
    END IF;
    RETURN NULL;
  END IF;
  CLOSE csr_get_owner;
  --
  RETURN l_schema;
END get_table_owner;
--
end paywsdyg_pkg;

/
