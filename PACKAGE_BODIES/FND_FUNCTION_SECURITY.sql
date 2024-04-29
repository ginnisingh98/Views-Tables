--------------------------------------------------------
--  DDL for Package Body FND_FUNCTION_SECURITY
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."FND_FUNCTION_SECURITY" AS
/* $Header: AFSCFUNB.pls 115.10 2004/05/25 22:58:39 pdeluna ship $ */


--
-- RESPONSIBILITY_EXISTS
--   Check if responsibility exists.
-- IN
--   responsibility_key (REQUIRED, KEY) - responsibility key
-- RETURNS
--   TRUE if responsibility exists
-- NOTES:
-- 1. The responsibility_id in the script must match the id in the tape
--    database.  To get the id, first create the responsibility in tape,
--    then query the id using either examine in the form or sqlplus.
--
FUNCTION RESPONSIBILITY_EXISTS(
  responsibility_key IN VARCHAR2)
RETURN BOOLEAN
IS
  dummy NUMBER;
BEGIN
  SELECT 1
  INTO dummy
  FROM fnd_responsibility r
  WHERE r.responsibility_key = responsibility_exists.responsibility_key;

  RETURN TRUE;
EXCEPTION
  WHEN no_data_found THEN
    RETURN FALSE;
END RESPONSIBILITY_EXISTS;

--
-- FORM_FUNCTION_EXISTS
--   Check if function exists.
-- IN
--   function_name (KEY, REQUIRED) - Function developer key name
-- RETURNS
--   TRUE if function exists
--
FUNCTION FORM_FUNCTION_EXISTS(
  function_name IN VARCHAR2)
RETURN BOOLEAN
IS
  dummy NUMBER;
BEGIN
  SELECT 1
  INTO dummy
  FROM fnd_form_functions f
  WHERE f.function_name = form_function_exists.function_name;

  RETURN TRUE;
EXCEPTION
  WHEN no_data_found THEN
    RETURN FALSE;
END FORM_FUNCTION_EXISTS;

--
-- MENU_EXISTS
--   Check if menu exists.
-- IN
--   menu_name (KEY, REQUIRED) - Menu developer key name
-- RETURNS
--   TRUE if menu exists
--
FUNCTION MENU_EXISTS(
  menu_name IN VARCHAR2)
RETURN BOOLEAN
IS
  dummy NUMBER;
BEGIN
  SELECT 1
  INTO dummy
  FROM fnd_menus f
  WHERE f.menu_name = menu_exists.menu_name;

  RETURN TRUE;
EXCEPTION
  WHEN no_data_found THEN
    RETURN FALSE;
END MENU_EXISTS;

--
-- MENU_ENTRY_EXISTS
--   Check if menu entry exists.
-- IN
--   menu_name (KEY, REQUIRED) - Menu developer key name
--   sub_menu_name (KEY) - Developer key name of submenu
--   function_name (KEY) - Developer key name of function
-- RETURNS
--   TRUE if menu entry exists
--
FUNCTION MENU_ENTRY_EXISTS(
  menu_name IN VARCHAR2,
  sub_menu_name IN VARCHAR2,
  function_name IN VARCHAR2)
RETURN BOOLEAN
IS
  dummy NUMBER;
BEGIN
  SELECT 1
  INTO dummy
  FROM fnd_menu_entries me, fnd_menus m, fnd_menus s, fnd_form_functions f
  WHERE me.menu_id = m.menu_id
  AND m.menu_name = menu_entry_exists.menu_name
  AND me.sub_menu_id = s.menu_id (+)
  AND nvl(s.menu_name, 'x') = nvl(menu_entry_exists.sub_menu_name, 'x')
  AND me.function_id = f.function_id (+)
  AND nvl(f.function_name, 'x') = nvl(menu_entry_exists.function_name, 'x');

  RETURN TRUE;
EXCEPTION
  WHEN no_data_found THEN
    RETURN FALSE;
END MENU_ENTRY_EXISTS;

--
-- SECURITY_RULE_EXISTS
--   Check if security rule exists.
-- IN
--   responsibility_key (KEY, REQUIRED) - Key of responsibility owning rule
--   rule_type (KEY, REQUIRED) - Rule type
--     'F' = Function exclusion
--     'M' = Menu exclusion
--   rule_name (KEY, REQUIRED) - Rule name
--     Function developer key name (if rule_type = 'F')
--     Menu developer key name (if rule_type = 'M')
-- RETURNS
--   TRUE if security rule exists
--
FUNCTION SECURITY_RULE_EXISTS(
  responsibility_key IN VARCHAR2,
  rule_type IN VARCHAR2 DEFAULT 'F',  -- F = Function, M = Menu
  rule_name IN VARCHAR2)              -- Function_name or menu_name
RETURN BOOLEAN
IS
  dummy NUMBER;
BEGIN
  IF (rule_type = 'F') THEN
    SELECT 1
    INTO dummy
    FROM fnd_resp_functions rf, fnd_responsibility r, fnd_form_functions f
    WHERE rf.responsibility_id = r.responsibility_id
    AND rf.application_id = r.application_id
    AND r.responsibility_key = security_rule_exists.responsibility_key
    AND rf.rule_type = 'F'
    AND rf.action_id = f.function_id
    AND f.function_name = security_rule_exists.rule_name;
  ELSE
    SELECT 1
    INTO dummy
    FROM fnd_resp_functions rf, fnd_responsibility r, fnd_menus m
    WHERE rf.responsibility_id = r.responsibility_id
    AND rf.application_id = r.application_id
    AND r.responsibility_key = security_rule_exists.responsibility_key
    AND rf.rule_type = 'M'
    AND rf.action_id = m.menu_id
    AND m.menu_name = security_rule_exists.rule_name;
  END IF;

  RETURN TRUE;
EXCEPTION
  WHEN no_data_found THEN
    RETURN FALSE;
END SECURITY_RULE_EXISTS;

--
-- RESPONSIBILITY
--   Insert/update/delete a GUI responsibility (not 2.3 responsibilities).
--
-- IN:
--   responsibility_id (REQUIRED, KEY) - Responsibility id (see note 1)
--   responsibility_key (REQUIRED, KEY) - Responsibility key
--   responsibility_name (REQUIRED) - Responsibility name
--   application_name (REQUIRED) - Application short name
--   description - Description
--   start_date (REQUIRED) - Effective Date From
--   end_date - Effective Date To
--   data_group_name (REQUIRED) - Data Group Name
--   data_group_application (REQUIRED) - Data group application short name
--   menu_name (REQUIRED) - Menu developer key name
--   request_group_name - Request group name
--   request_group_application - Request group application short name
--   version - '4' for Forms Resp, 'W' for Web Resp, 'M' for Mobile Apps
--   web_host_name - Web Host Name (for Web Resp)
--   web_agent_name - Web Agent Name (for Web Resp)
--   delete_flag (REQUIRED) - Delete mode (see package comments)
--
-- CHILD REFERENCES: (Delete is cascaded to ...)
--   (none - see note 2)
-- FOREIGN REFERENCES: (Delete prevented if referenced in ...)
--   (none - see note 2)
--
-- NOTES:
-- 1. The responsibility_id in the script must match the id in the tape
--    database.  To get the id, first create the responsibility in tape,
--    then query the id using either examine in the form or sqlplus.
-- 2. Responsibilities are never deleted.  If this procedure is called
--    with delete_flag = 'Y' or 'F', the end_date will be set to sysdate
--    to effectively disable the responsibility.
--
PROCEDURE RESPONSIBILITY (
	responsibility_id			IN NUMBER,
	responsibility_key			IN VARCHAR2,
	responsibility_name			IN VARCHAR2,
	application					IN VARCHAR2,
	description					IN VARCHAR2 DEFAULT '',
	START_DATE					IN DATE,
	end_date					IN DATE DEFAULT '',
	data_group_name				IN VARCHAR2,
	data_group_application		IN VARCHAR2,
	menu_name					IN VARCHAR2,
	request_group_name			IN VARCHAR2 DEFAULT '',
	request_group_application	IN VARCHAR2 DEFAULT '',
	version						IN VARCHAR2 DEFAULT '4',
	web_host_name				IN VARCHAR2 DEFAULT NULL,
	web_agent_name				IN VARCHAR2 DEFAULT NULL,
	delete_flag					IN VARCHAR2 DEFAULT 'N'
)
IS
	namebuf						VARCHAR2(100);
	application_id				NUMBER DEFAULT '';
	data_group_id				NUMBER DEFAULT '';
	data_group_application_id	NUMBER DEFAULT '';
	menu_id						NUMBER DEFAULT '';
	request_group_id			NUMBER DEFAULT '';
	group_application_id		NUMBER DEFAULT '';
	dummy						NUMBER;

BEGIN

	-- Get application_id
	SELECT	a.application_id
	INTO	application_id
	FROM	fnd_application a
	WHERE	a.application_short_name = responsibility.application;

	-- Delete if requested
	IF (delete_flag <> 'N') THEN
		-- Resps are never deleted.  Set the end_date instead.
		UPDATE	fnd_responsibility
		SET		end_date = sysdate
		WHERE	responsibility_key = responsibility.responsibility_key;

		-- Added for Function Security Cache Invalidation Project.
		fnd_function_security_cache.update_resp(responsibility.responsibility_id,
			responsibility.application_id);

		RETURN;
	END IF;

	-- This is an insert/update.
	-- Bump responsibility_name by prepending '@' if needed to avoid any
	-- possible unique key violations.
	namebuf := responsibility.responsibility_name;
	LOOP
		SELECT	count(1)
		INTO	dummy
		FROM	fnd_responsibility_vl fr
		WHERE	fr.responsibility_name = namebuf
		AND		(fr.responsibility_id <> responsibility.responsibility_id
		OR		 fr.application_id <> responsibility.application_id);

		EXIT WHEN dummy = 0;

		namebuf := '@'||substr(namebuf, 1, 79);
	END LOOP;

	-- Select all other hidden keys
	-- Data group
	SELECT	dg.data_group_id, a.application_id
	INTO	data_group_id, data_group_application_id
	FROM	fnd_data_groups_standard_view dg, fnd_data_group_units dgu, fnd_application a
	WHERE	dg.data_group_name = responsibility.data_group_name
	AND		dg.data_group_id = dgu.data_group_id
	AND		dgu.application_id = a.application_id
	AND		a.application_short_name = responsibility.data_group_application;

	-- Menu
	SELECT	m.menu_id
	INTO	menu_id
	FROM	fnd_menus m
	WHERE	m.menu_name = responsibility.menu_name;

	-- Request group, if supplied
	IF (request_group_name IS NOT NULL) THEN
		SELECT	rg.request_group_id, a.application_id
		INTO	request_group_id, group_application_id
		FROM	fnd_request_groups rg, fnd_application a
		WHERE	rg.request_group_name = responsibility.request_group_name
		AND		rg.application_id = a.application_id
		AND		a.application_short_name = responsibility.request_group_application;
	END IF;

	-- Select to decide if this is insert or update
	BEGIN
		SELECT	responsibility_id
		INTO	dummy
		FROM	fnd_responsibility r
		WHERE	r.responsibility_key = responsibility.responsibility_key;
	EXCEPTION
		WHEN no_data_found THEN
			-- Insert into base
			INSERT INTO fnd_responsibility (
				application_id,
				responsibility_id,
				responsibility_key,
				creation_date,
				created_by,
				last_update_date,
				last_updated_by,
				last_update_login,
				data_group_id,
				data_group_application_id,
				menu_id,
				START_DATE,
				end_date,
				group_application_id,
				request_group_id,
				version,
				web_host_name,
				web_agent_name
			)
				VALUES (
				responsibility.application_id,
				responsibility.responsibility_id,
				responsibility.responsibility_key,
				sysdate,
				1,
				sysdate,
				1,
				0,
				responsibility.data_group_id,
				responsibility.data_group_application_id,
				responsibility.menu_id,
				responsibility.START_DATE,
				responsibility.end_date,
				responsibility.group_application_id,
				responsibility.request_group_id,
				responsibility.version,
				responsibility.web_host_name,
				responsibility.web_agent_name
			);

		-- Added for Function Security Cache Invalidation Project.
		fnd_function_security_cache.insert_resp(responsibility.responsibility_id,
			responsibility.application_id);

		-- Insert into tl
		INSERT INTO fnd_responsibility_tl (
			application_id,
			responsibility_id,
			LANGUAGE,
			responsibility_name,
			description,
			created_by,
			creation_date,
			last_updated_by,
			last_update_date,
			last_update_login,
			source_lang
		)
			SELECT	responsibility.application_id,
					responsibility.responsibility_id,
					l.language_code,
					namebuf,
					responsibility.description,
					1,
					sysdate,
					1,
					sysdate,
					0,
					userenv('LANG')
			FROM	fnd_languages l
			WHERE	l.installed_flag IN ('I', 'B');

		RETURN;
	END;

	-- Update existing row
	UPDATE	fnd_responsibility r
	SET		responsibility_key = responsibility.responsibility_key,
			START_DATE = responsibility.START_DATE,
			end_date = responsibility.end_date,
			data_group_id = responsibility.data_group_id,
			data_group_application_id = responsibility.data_group_application_id,
			menu_id = responsibility.menu_id,
			request_group_id = responsibility.request_group_id,
			group_application_id = responsibility.group_application_id,
			version = responsibility.version,
			web_host_name = responsibility.web_host_name,
			web_agent_name = responsibility.web_agent_name
	WHERE	r.responsibility_id = responsibility.responsibility_id
	AND		r.application_id = responsibility.application_id;

	-- Added for Function Security Cache Invalidation Project.
	fnd_function_security_cache.update_resp(responsibility.responsibility_id,
		responsibility.application_id);

	-- Update TL
	UPDATE	fnd_responsibility_tl r
	SET		responsibility_name = namebuf,
			description = responsibility.description
	WHERE	r.responsibility_id = responsibility.responsibility_id
	AND		r.application_id = responsibility.application_id
	AND		r.LANGUAGE = userenv('LANG');

END RESPONSIBILITY;

--
-- FORM_FUNCTION
--   Insert/update/delete a function.
--
-- IN:
--   function_name (KEY, REQUIRED) - Function developer key name
--   form_name - Name of form attached to function
--               (Use the actual form name, not the user name or title.)
--   parameters - Parameter string for the form
--   type - Type flag of the function
--   user_function_name (REQUIRED) - User name of function
--                                   (in current language)
--   description - Description of function
--   delete_flag (REQUIRED) - Delete mode (see package comments)
--
-- CHILD REFERENCES: (Delete is cascaded to ...)
--   Function Security Exclusion Rules
--
-- FOREIGN REFERENCES: (Delete prevented if referenced in ...)
--   GUI Menu Entry
--   Attachments
--   2.3 Menu Entry
--
PROCEDURE FORM_FUNCTION (
	function_name		IN VARCHAR2,
	form_name			IN VARCHAR2 DEFAULT '',
	PARAMETERS			IN VARCHAR2 DEFAULT '',
	TYPE				IN VARCHAR2 DEFAULT '',
	user_function_name	IN VARCHAR2 DEFAULT '',
	description			IN VARCHAR2 DEFAULT '',
	delete_flag			IN VARCHAR2 DEFAULT 'N'
)
IS
	curlang			VARCHAR2(30);
	namebuf			VARCHAR2(80);
	form_id			NUMBER DEFAULT '';
	application_id	NUMBER DEFAULT '';
	function_id		NUMBER DEFAULT '';
	dummy			NUMBER;

	CURSOR RESP_FUNC IS
		SELECT	APPLICATION_ID, RESPONSIBILITY_ID
		FROM	FND_RESP_FUNCTIONS
		WHERE	rule_type = 'F'
		AND		action_id = form_function.function_id;

BEGIN
	BEGIN
		SELECT	function_id
		INTO	form_function.function_id
		FROM	fnd_form_functions
		WHERE	function_name = form_function.function_name;
	EXCEPTION
		WHEN no_data_found THEN
			function_id := -1;
	END;

	-- Delete if requested
	IF (delete_flag <> 'N') THEN
		-- Check for foreign key references
		IF (delete_flag <> 'F') THEN
			BEGIN
				SELECT	1
				INTO	dummy
				FROM	sys.dual
				WHERE	NOT EXISTS
					(SELECT	1
					 FROM	fnd_menu_entries me
					 WHERE	me.function_id = form_function.function_id);

				SELECT	1
				INTO	dummy
				FROM	sys.dual
				WHERE	NOT EXISTS
					(SELECT	1
					 FROM	fnd_attachment_functions af
					 WHERE	af.function_type = 'F'
					 AND	af.function_id = form_function.function_id);

			EXCEPTION
				WHEN no_data_found THEN
					RETURN;
			END;
		END IF;

		DELETE	FROM fnd_form_functions
		WHERE	function_id = form_function.function_id;

		-- Added for Function Security Cache Invalidation Project.
		fnd_function_security_cache.delete_function(form_function.function_id);

		DELETE	FROM fnd_form_functions_tl
		WHERE	function_id = form_function.function_id;

		-- Cascade deletes to resp functions
		DELETE	FROM fnd_resp_functions rf
		WHERE	rf.rule_type = 'F'
		AND		rf.action_id = form_function.function_id;

		-- Added for Function Security Cache Invalidation Project.
		-- Seems that I need make sure that each responsibility excluded is taken into account.
		FOR rs IN RESP_FUNC LOOP
			fnd_function_security_cache.update_resp(rs.responsibility_id, rs.application_id);
		END LOOP;

		RETURN;
	END IF;

    -- This is an insert/update.
    -- Bump user_name by prepending '@' if needed to avoid any
    -- possible unique key violations.
    namebuf := form_function.user_function_name;
    LOOP
      SELECT count(1)
      INTO dummy
      FROM fnd_form_functions_vl ff
      WHERE ff.user_function_name = namebuf
      AND ff.function_id <> form_function.function_id;

      EXIT WHEN dummy = 0;

      namebuf := '@'||substr(namebuf, 1, 79);
    END LOOP;

    -- Get form ids if form name supplied
    IF (form_name IS NOT NULL) THEN
        SELECT f.form_id, f.application_id
        INTO form_function.form_id, form_function.application_id
        FROM fnd_form f
        WHERE f.form_name = form_function.form_name;
    END IF;

    curlang := fnd_global.current_language;

    -- Decide if this is insert or update
    IF (function_id = -1) THEN

        SELECT	fnd_form_functions_s.NEXTVAL
        INTO	form_function.function_id
        FROM	dual;

        -- Insert into base
        INSERT INTO fnd_form_functions (
            function_id,
            function_name,
            application_id,
            form_id,
            PARAMETERS,
            creation_date,
            created_by,
            last_update_date,
            last_updated_by,
            last_update_login,
            TYPE)
        SELECT
            form_function.function_id,
            form_function.function_name,
            form_function.application_id,
            form_function.form_id,
            form_function.PARAMETERS,
            sysdate,
            1,
            sysdate,
            1,
            1,
            form_function.TYPE
        FROM sys.dual;

        -- Added for Function Security Cache Invalidation Project.
		fnd_function_security_cache.insert_function(form_function.function_id);

        -- Insert into _TL
        INSERT INTO fnd_form_functions_tl (
            LANGUAGE,
            function_id,
            user_function_name,
            description,
            creation_date,
            created_by,
            last_update_date,
            last_updated_by,
            last_update_login,
            source_lang)
        SELECT
            l.language_code,
            f.function_id,
            form_function.namebuf,
            form_function.description,
            sysdate,
            1,
            sysdate,
            1,
            1,
	    userenv('LANG')
        FROM fnd_form_functions f, fnd_languages l
        WHERE f.function_name = form_function.function_name
        AND l.installed_flag IN ('I', 'B');

        RETURN;
    END IF;

    -- Update base
    UPDATE fnd_form_functions SET
        application_id = form_function.application_id,
        form_id = form_function.form_id,
        PARAMETERS = form_function.PARAMETERS,
        last_update_date = sysdate,
        last_updated_by = 1,
        last_update_login = 1,
        TYPE = form_function.TYPE
    WHERE function_id = form_function.function_id;

	-- Added for Function Security Cache Invalidation Project.
	fnd_function_security_cache.update_function(form_function.function_id);

    -- Update TL
    UPDATE fnd_form_functions_tl SET
        user_function_name = form_function.namebuf,
        description = form_function.description,
        last_update_date = sysdate,
        last_updated_by = 1,
        last_update_login = 1,
        source_lang = userenv('LANG')
    WHERE function_id = form_function.function_id
    AND userenv('LANG') IN (LANGUAGE, source_lang);
END FORM_FUNCTION;

--
-- MENU
--   Insert/update/delete a menu.
--
-- IN:
--   menu_name (KEY, REQUIRED) - Menu developer key
--   user_menu_name (REQUIRED) - Menu user name (in current language)
--   description - Menu description (in current language)
--   delete_flag (REQUIRED) - Delete mode (see package comments)
--
-- CHILD REFERENCES: (Delete is cascaded to ...)
--   Menu Entry (entries of this menu)
--   Function Security Exclusion Rules
--
-- FOREIGN REFERENCES: (Delete prevented if referenced in ...)
--   Menu Entry (as a submenu of another menu) (see note)
--   Responsibility (as the main menu of a responsibility)
--
-- NOTE:
--   To delete an entire menu tree, delete the top level menu of the tree
-- first, then work down to the leaves one level at a time to avoid
-- invalidating foreign references along the way.
--
PROCEDURE MENU (
	menu_name		IN VARCHAR2,
	user_menu_name	IN VARCHAR2 DEFAULT '',
	description		IN VARCHAR2 DEFAULT '',
	delete_flag		IN VARCHAR2 DEFAULT 'N'
)
IS
	curlang		VARCHAR2(30);
	namebuf		VARCHAR2(80);
	menu_id		NUMBER DEFAULT '';
	dummy	NUMBER;

	CURSOR RESP_FUNC IS
		SELECT	APPLICATION_ID, RESPONSIBILITY_ID
		FROM	FND_RESP_FUNCTIONS
		WHERE	rule_type = 'M'
		AND		action_id = menu.menu_id;

	CURSOR MN_ENTRY is
		SELECT	sub_menu_id, function_id
		FROM		fnd_menu_entries
		WHERE		menu_id = menu.menu_id;

BEGIN

	BEGIN
		SELECT	menu_id
		INTO	menu.menu_id
		FROM	fnd_menus
		WHERE	menu_name = menu.menu_name;
	EXCEPTION
		WHEN no_data_found THEN
			menu_id := -1;
    END;

	-- Delete if requested
	IF (delete_flag <> 'N') THEN
		-- Check for foreign key references
		IF (delete_flag <> 'F') THEN
			BEGIN
				SELECT	1
				INTO	dummy
				FROM	sys.dual
				WHERE NOT EXISTS
					(SELECT	1
					 FROM	fnd_menu_entries me
					 WHERE	me.sub_menu_id = menu.menu_id);

				SELECT	1
				INTO	dummy
				FROM	sys.dual
				WHERE NOT EXISTS
					(SELECT	1
					 FROM	fnd_responsibility r
					 WHERE	r.menu_id = menu.menu_id);

			EXCEPTION
				WHEN no_data_found THEN
					RETURN;
			END;
		END IF;

		DELETE	FROM fnd_menus
		WHERE	menu_id = menu.menu_id;

		-- Added for Function Security Cache Invalidation Project.
		fnd_function_security_cache.delete_menu(menu.menu_id);

		DELETE	FROM fnd_menus_tl
		WHERE	menu_id = menu.menu_id;

		-- Cascade delete to menu entries and resp functions
		DELETE	FROM fnd_menu_entries
		WHERE	menu_id = menu.menu_id;

		-- Added for Function Security Cache Invalidation Project.
		-- Need make sure that each menu entry deleted is taken into account.
		FOR mn IN MN_ENTRY LOOP
			fnd_function_security_cache.delete_menu_entry(menu.menu_id,
				mn.sub_menu_id, mn.function_id);
		END LOOP;

		DELETE	FROM fnd_menu_entries_tl
		WHERE	menu_id = menu.menu_id;

		DELETE	FROM fnd_resp_functions rf
		WHERE	rf.rule_type = 'M'
		AND		rf.action_id = menu.menu_id;

		-- Added for Function Security Cache Invalidation Project.
		-- Need make sure that each responsibility updated is taken into account.
		FOR rs IN RESP_FUNC LOOP
			fnd_function_security_cache.update_resp(rs.responsibility_id, rs.application_id);
		END LOOP;

		RETURN;
	END IF;

	curlang := fnd_global.current_language;

	-- This is an insert/update.
	-- Bump responsibility_name by prepending '@' if needed to avoid any
	-- possible unique key violations.
	namebuf := menu.user_menu_name;
	LOOP
		SELECT	count(1)
		INTO	dummy
		FROM	fnd_menus_vl fm
		WHERE	fm.user_menu_name = namebuf
		AND		fm.menu_id <> menu.menu_id;

		EXIT WHEN dummy = 0;

		namebuf := '@'||substr(namebuf, 1, 79);
	END LOOP;

	-- Select to decide if this is insert or update
	IF (menu_id = -1) THEN

		SELECT	fnd_menus_s.NEXTVAL
		INTO	menu.menu_id
		FROM	dual;

		-- Insert into base
		INSERT INTO fnd_menus (
			menu_id,
			menu_name,
			creation_date,
			created_by,
			last_update_date,
			last_updated_by,
			last_update_login
		)
			SELECT	menu.menu_id,
					menu.menu_name,
					sysdate,
					1,
					sysdate,
					1,
					1
			FROM	sys.dual;


		-- Added for Function Security Cache Invalidation Project.
		fnd_function_security_cache.insert_menu(menu.menu_id);

		-- Insert into _TL
		INSERT INTO fnd_menus_tl (
			LANGUAGE,
			menu_id,
			user_menu_name,
			description,
			creation_date,
			created_by,
			last_update_date,
			last_updated_by,
			last_update_login,
			source_lang
		)
		SELECT	l.language_code,
				f.menu_id,
				menu.namebuf,
				menu.description,
				sysdate,
				1,
				sysdate,
				1,
				1,
				userenv('LANG')
		FROM	fnd_menus f, fnd_languages l
		WHERE	f.menu_name = menu.menu_name
		AND		l.installed_flag IN ('I', 'B');

		RETURN;
	END IF;

    -- Update base -- nothing updatable in base table

    -- Update TL
    UPDATE	fnd_menus_tl
    SET		user_menu_name = menu.namebuf,
			description = menu.description,
			last_update_date = sysdate,
			last_updated_by = 1,
			last_update_login = 1,
			source_lang = userenv('LANG')
	WHERE	menu_id = menu.menu_id
	AND		userenv('LANG') IN (LANGUAGE, source_lang);

	-- Added for Function Security Cache Invalidation Project
	FND_FUNCTION_SECURITY_CACHE.update_menu(menu.menu_id);

END MENU;

--
-- MENU_ENTRY
--   Insert/update/delete an individual menu entry.
--
-- IN:
--   menu_name (KEY, REQUIRED) - Menu developer key
--   entry_sequence - Sequence number (see note below)
--   prompt - Entry prompt (in current language)
--   sub_menu_name (KEY) - Developer key name of submenu
--   function_name (KEY) - Developer key name of function
--   description - Entry description (in current language)
--   delete_flag (REQUIRED) - Delete mode (see package comments)
--
-- CHILD REFERENCES: (Delete is cascaded to ...)
--   (none)
-- FOREIGN REFERENCES: (Delete prevented if referenced in ...)
--   (none)
--
-- NOTE:
--   Menu entries are identified by the triple of menu_name, sub_menu_name,
-- and function_name, not by entry_sequence.  The entry_sequence argument is
-- used only when inserting a new entry.
--
PROCEDURE MENU_ENTRY (
	menu_name		IN VARCHAR2,
	entry_sequence	IN NUMBER,
	PROMPT			IN VARCHAR2 DEFAULT '',
	sub_menu_name	IN VARCHAR2 DEFAULT '',
	function_name	IN VARCHAR2 DEFAULT '',
	description		IN VARCHAR2 DEFAULT '',
	delete_flag		IN VARCHAR2 DEFAULT 'N'
)
IS
	curlang				VARCHAR2(30);
	menu_id				NUMBER DEFAULT '';
	sub_menu_id			NUMBER DEFAULT '';
	function_id			NUMBER DEFAULT '';
	l_entry_sequence	NUMBER DEFAULT '';

BEGIN
	curlang := fnd_global.current_language;

	-- Get menu_id
	SELECT	menu_id
	INTO	menu_entry.menu_id
	FROM	fnd_menus
	WHERE	menu_name = menu_entry.menu_name;

	-- Get sub_menu_id
	IF (sub_menu_name IS NOT NULL) THEN
		SELECT	menu_id
		INTO	menu_entry.sub_menu_id
		FROM	fnd_menus
		WHERE	menu_name = menu_entry.sub_menu_name;
	END IF;

	-- Get function_id
	IF (function_name IS NOT NULL) THEN
		SELECT	function_id
		INTO	menu_entry.function_id
		FROM	fnd_form_functions
		WHERE	function_name = menu_entry.function_name;
	END IF;

	-- Find local entry sequence matching submenu/function pair.
	BEGIN
		SELECT	fme.entry_sequence
		INTO	l_entry_sequence
		FROM	fnd_menu_entries fme
		WHERE	fme.menu_id = menu_entry.menu_id
		AND		nvl(fme.sub_menu_id, -1) = nvl(menu_entry.sub_menu_id, -1)
		AND		nvl(fme.function_id, -1) = nvl(menu_entry.function_id, -1);
	EXCEPTION
		WHEN no_data_found THEN
		-- Submenu/function not found.  Use argument.
		l_entry_sequence := entry_sequence;
	END;

	-- Delete if requested
	IF (delete_flag = 'Y') THEN

	    -- Determine the correct sub_menu_id and function_id using the menu_id
	    -- and entry sequence before deleting.  It may not be safe to use the
		-- previous values determined above since those values may have failed
		-- in the matching test previous to this code.
		SELECT sub_menu_id, function_id
		INTO   menu_entry.sub_menu_id, menu_entry.function_id
		FROM   fnd_menu_entries
		WHERE  menu_id = menu_entry.menu_id
		AND	   entry_sequence = l_entry_sequence;

		DELETE	FROM fnd_menu_entries
		WHERE	menu_id = menu_entry.menu_id
		AND		entry_sequence = l_entry_sequence;

		-- Added for Function Security Cache Invalidation Project.
		-- If menu_id exists, then sub_menu_id and function_id also exist and has already been
		-- derived above.
		fnd_function_security_cache.delete_menu_entry(menu_entry.menu_id,
			menu_entry.sub_menu_id, menu_entry.function_id);

		DELETE	FROM fnd_menu_entries_tl
		WHERE	menu_id = menu_entry.menu_id
		AND		entry_sequence = l_entry_sequence;

		RETURN;
	END IF;

	-- Select to decide if this is insert or update
	BEGIN
		SELECT	menu_id
		INTO	menu_entry.menu_id
		FROM	fnd_menu_entries
		WHERE	menu_id = menu_entry.menu_id
		AND		entry_sequence = l_entry_sequence;
	EXCEPTION
		WHEN no_data_found THEN
			-- Insert into base
			INSERT INTO fnd_menu_entries (
				menu_id,
				entry_sequence,
				sub_menu_id,
				function_id,
				creation_date,
				created_by,
				last_update_date,
				last_updated_by,
				last_update_login
			)
			VALUES (
				menu_entry.menu_id,
				menu_entry.entry_sequence,
				menu_entry.sub_menu_id,
				menu_entry.function_id,
				sysdate,
				1,
				sysdate,
				1,
				1
			);

			-- Added for Function Security Cache Invalidation Project.
			fnd_function_security_cache.insert_menu_entry(menu_entry.menu_id,
				menu_entry.sub_menu_id, menu_entry.function_id);

			-- Insert into _TL
			INSERT INTO fnd_menu_entries_tl (
				LANGUAGE,
				menu_id,
				entry_sequence,
				PROMPT,
				description,
				creation_date,
				created_by,
				last_update_date,
				last_updated_by,
				last_update_login,
				source_lang
			)
			SELECT	l.language_code,
					menu_entry.menu_id,
					menu_entry.entry_sequence,
					menu_entry.PROMPT,
					menu_entry.description,
					sysdate,
					1,
					sysdate,
					1,
					1,
					userenv('LANG')
			FROM	fnd_languages l
			WHERE	l.installed_flag IN ('I', 'B');

			RETURN;
	END;

	-- Update base
	UPDATE	fnd_menu_entries
	SET		sub_menu_id = menu_entry.sub_menu_id,
			function_id = menu_entry.function_id,
			last_update_date = sysdate,
			last_updated_by = 1,
			last_update_login = 1
	WHERE	menu_id = menu_entry.menu_id
	AND		entry_sequence = l_entry_sequence;

	-- Added for Function Security Cache Invalidation Project.
	fnd_function_security_cache.update_menu_entry(menu_entry.menu_id,
		menu_entry.sub_menu_id, menu_entry.function_id);

	-- Update TL
	UPDATE	fnd_menu_entries_tl
	SET		PROMPT = menu_entry.PROMPT,
			description = menu_entry.description,
			last_update_date = sysdate,
			last_updated_by = 1,
			last_update_login = 1,
			source_lang = userenv('LANG')
	WHERE	menu_id = menu_entry.menu_id
	AND		entry_sequence = l_entry_sequence
	AND		userenv('LANG') IN (LANGUAGE, source_lang);

END MENU_ENTRY;

--
-- SECURITY_RULE
--   Insert/update/delete a function security exclusion rule.
--
-- IN:
--   responsibility_key (KEY, REQUIRED) - Key of responsibility owning rule
--   rule_type (KEY, REQUIRED) - Rule type
--     'F' = Function exclusion
--     'M' = Menu exclusion
--   rule_name (KEY, REQUIRED) - Rule name
--     Function developer key name (if rule_type = 'F')
--     Menu developer key name (if rule_type = 'M')
--   delete_flag (REQUIRED) - Delete mode (see package comments)
--
-- CHILD REFERENCES: (Delete is cascaded to ...)
--   (none)
-- FOREIGN REFERENCES: (Delete prevented if referenced in ...)
--   (none)
--
PROCEDURE SECURITY_RULE (
    responsibility_key IN VARCHAR2,
    rule_type IN VARCHAR2 DEFAULT 'F',  /* F = Function, M = Menu */
    rule_name IN VARCHAR2,              /* Function_name or menu_name */
    delete_flag IN VARCHAR2 DEFAULT 'N')
IS
    curlang VARCHAR2(30);
    responsibility_id NUMBER;
    application_id NUMBER;
    action_id NUMBER;
BEGIN
    curlang := fnd_global.current_language;

    -- Get responsibility ids
    SELECT fr.responsibility_id, fr.application_id
    INTO security_rule.responsibility_id, security_rule.application_id
    FROM fnd_responsibility fr
    WHERE fr.responsibility_key = security_rule.responsibility_key;

    -- Get action id
    IF (rule_type = 'F') THEN
        SELECT function_id
        INTO security_rule.action_id
        FROM fnd_form_functions
        WHERE function_name = security_rule.rule_name;
    ELSE
        SELECT menu_id
        INTO security_rule.action_id
        FROM fnd_menus
        WHERE menu_name = security_rule.rule_name;
    END IF;

    -- Delete if requested
    IF (delete_flag = 'Y') THEN
        DELETE FROM fnd_resp_functions
        WHERE responsibility_id = security_rule.responsibility_id
        AND application_id = security_rule.application_id
        AND rule_type = security_rule.rule_type
        AND action_id = security_rule.action_id;

		-- Added for Function Security Cache Invalidation Project.
		fnd_function_security_cache.update_resp(security_rule.responsibility_id, security_rule.application_id);

        RETURN;
    END IF;

    -- Must always be an insert - nothing to update
    INSERT INTO fnd_resp_functions (
        application_id,
        responsibility_id,
        action_id,
        rule_type,
        last_update_date,
        last_updated_by,
        last_update_login,
        creation_date,
        created_by)
    VALUES (
        security_rule.application_id,
        security_rule.responsibility_id,
        security_rule.action_id,
        security_rule.rule_type,
        sysdate,
        1,
        1,
        sysdate,
        1);

		-- Added for Function Security Cache Invalidation Project.
		fnd_function_security_cache.update_resp(security_rule.responsibility_id,
			security_rule.application_id);

    -- No TL table

END SECURITY_RULE;

--
-- UPDATE_FUNCTION_NAME
--   This procedure updates the developer key of an existing function.
-- The function with name oldname is located, and the name updated to newname.
-- If a function already exists with name newname, it is deleted in favor of
-- the updated row with oldname.
--
-- IN:
--   oldname (REQUIRED) - old function developer name
--   newname (REQUIRED) - new function developer name
--
-- NOTES:
--   The user is responsible for making sure all references to the
-- function in forms, code, etc, are updated to the new name.
--   Under normal circumstances developer keys should never be changed.  This
-- procedure should only be used for new functions not in general use, or to
-- fix bugs caused by inconsistent data created in previous patches.
--
PROCEDURE UPDATE_FUNCTION_NAME (
	oldname	IN VARCHAR2,
	newname	IN VARCHAR2
)
IS
	oldid	NUMBER;
	newid	NUMBER;

	CURSOR MNU_ENTRY IS
		SELECT	MENU_ID, ENTRY_SEQUENCE, SUB_MENU_ID
		FROM	FND_MENU_ENTRIES
		WHERE	FUNCTION_ID = newid;

	CURSOR RESP_FUNC IS
		SELECT	APPLICATION_ID, RESPONSIBILITY_ID
		FROM	FND_RESP_FUNCTIONS
		WHERE	rule_type = 'F'
		AND		action_id = newid;

BEGIN
	-- Find which function names have already been changed
	BEGIN
		SELECT	FUNCTION_ID
		INTO	oldid
		FROM	FND_FORM_FUNCTIONS
		WHERE	FUNCTION_NAME = oldname;
	EXCEPTION
		WHEN no_data_found THEN
			oldid := -1;
	END;

	BEGIN
		SELECT	FUNCTION_ID
		INTO	newid
		FROM	FND_FORM_FUNCTIONS
		WHERE	FUNCTION_NAME = newname;
	EXCEPTION
		WHEN no_data_found THEN
			newid := -1;
	END;

	-- If neither exists then do nothing
	IF ((oldid = -1) AND (newid = -1)) THEN
		RETURN;
	END IF;

	-- If only newname exists, already done
	IF ((oldid = -1) AND (newid <> -1)) THEN
		RETURN;
	END IF;

	-- If only oldname exists, only update oldname to newname
	IF ((oldid <> -1) AND (newid = -1)) THEN
		UPDATE	FND_FORM_FUNCTIONS
		SET		FUNCTION_NAME = newname
		WHERE	FUNCTION_NAME = oldname;

		-- Added for Function Security Cache Invalidation Project.
		fnd_function_security_cache.update_function(oldid);

		RETURN;
	END IF;

	-- If both oldname and newname exist, then
	-- 1. Reset FKs to all point to old row
	-- 2. Delete new row
	-- 3. Update oldname to newname in old row

	-- 1. Reset Fks to all point to old row
	UPDATE	FND_MENU_ENTRIES
	SET		FUNCTION_ID = oldid
	WHERE	FUNCTION_ID = newid;

	-- Added for Function Security Cache Invalidation Project.
	-- Need make sure that each menu entry updated is taken into account.
	FOR mn IN MNU_ENTRY LOOP
		fnd_function_security_cache.update_menu_ENTRY(mn.menu_id, mn.sub_menu_id, newid);
	END LOOP;

	UPDATE	FND_RESP_FUNCTIONS
	SET		ACTION_ID = oldid
	WHERE	RULE_TYPE = 'F'
	AND		ACTION_ID = newid;

	-- Added for Function Security Cache Invalidation Project.
	-- Need make sure that each responsibility updated is taken into account.
	FOR rs IN RESP_FUNC LOOP
		fnd_function_security_cache.update_resp(rs.responsibility_id, rs.application_id);
	END LOOP;

	UPDATE	FND_ATTACHMENT_FUNCTIONS
	SET		FUNCTION_ID = oldid
	WHERE	FUNCTION_TYPE = 'F'
	AND		FUNCTION_ID = newid;

	-- 2. Delete new row
	DELETE	FROM FND_FORM_FUNCTIONS
	WHERE	FUNCTION_ID = newid;

	-- Added for Function Security Cache Invalidation Project.
	fnd_function_security_cache.update_function(newid);

	DELETE	FROM FND_FORM_FUNCTIONS_TL
	WHERE	FUNCTION_ID = newid;

	-- 3. Update oldname to newname in old row
	UPDATE	FND_FORM_FUNCTIONS
	SET		FUNCTION_NAME = newname
	WHERE	FUNCTION_ID = oldid;

	-- Added for Function Security Cache Invalidation Project.
	fnd_function_security_cache.update_function(oldid);

END UPDATE_FUNCTION_NAME;

--
-- UPDATE_MENU_NAME
--   This procedure updates the developer key of an existing menu.
-- The menu with name oldname is located, and the name updated to newname.
-- If a menu already exists with name newname, it is deleted in favor of
-- the updated row with oldname.
--
-- IN:
--   oldname (REQUIRED) - old menu developer name
--   newname (REQUIRED) - new menu developer name
--
-- NOTES:
--   The user is responsible for making sure all references to the
-- menu in forms, code, etc, are updated to the new name.
--   Under normal circumstances developer keys should never be changed.  This
-- procedure should only be used for new menus not in general use, or to
-- fix bugs caused by inconsistent data created in previous patches.
--
PROCEDURE UPDATE_MENU_NAME (
	oldname	IN VARCHAR2,
	newname	IN VARCHAR2
)
IS
	oldid	NUMBER;
	newid	NUMBER;

	CURSOR RESP_CURSOR IS
		SELECT	RESPONSIBILITY_ID, APPLICATION_ID
		FROM	FND_RESPONSIBILITY
		WHERE	MENU_ID = oldid;

	CURSOR RESP_FUNC IS
		SELECT	APPLICATION_ID, RESPONSIBILITY_ID
		FROM	FND_RESP_FUNCTIONS
		WHERE	rule_type = 'M'
		AND		action_id = newid;

	CURSOR mn_entry IS
		SELECT	SUB_MENU_ID, FUNCTION_ID
		FROM	FND_MENU_ENTRIES
	    WHERE	MENU_ID = newid;

BEGIN
	-- Find which menu names have already been changed
	BEGIN
		SELECT	MENU_ID
		INTO	oldid
		FROM	FND_MENUS
		WHERE	MENU_NAME = oldname;
	EXCEPTION
		WHEN no_data_found THEN
			oldid := -1;
	END;

	BEGIN
		SELECT	MENU_ID
		INTO	newid
		FROM	FND_MENUS
		WHERE	MENU_NAME = newname;
	EXCEPTION
		WHEN no_data_found THEN
			newid := -1;
	END;

	-- If neither exists then do nothing
	IF ((oldid = -1) AND (newid = -1)) THEN
		RETURN;
	END IF;

	-- If only newname exists, already done
	IF ((oldid = -1) AND (newid <> -1)) THEN
		RETURN;
	END IF;

	-- If only oldname exists, only update oldname to newname
	IF ((oldid <> -1) AND (newid = -1)) THEN
		UPDATE	FND_MENUS
		SET		MENU_NAME = newname
		WHERE	MENU_NAME = oldname;

		-- Added for Function Security Cache Invalidation Project.
		fnd_function_security_cache.update_menu(oldid);

		RETURN;
	END IF;

	-- If both oldname and newname exist, then
	-- 1. Reset FKs to all point to old row
	-- 2. Delete new row
	-- 3. Update oldname to newname in old row

	-- 1. Reset Fks to all point to old row
	UPDATE	FND_MENU_ENTRIES
	SET		SUB_MENU_ID = oldid
	WHERE	MENU_ID = newid;

	-- Added for Function Security Cache Invalidation Project.
	-- Need make sure that each menu entry updated is taken into account.
	FOR mn IN mn_entry LOOP
		fnd_function_security_cache.update_menu_entry(newid, mn.sub_menu_id, mn.function_id);
	END LOOP;

	UPDATE	FND_RESPONSIBILITY
	SET		MENU_ID = oldid
	WHERE	MENU_ID = newid;

	-- Added for Function Security Cache Invalidation Project.
	-- Need make sure that each responsibility updated is taken into account.
	FOR rs IN RESP_CURSOR LOOP
		fnd_function_security_cache.update_resp(rs.responsibility_id, rs.application_id);
	END LOOP;

	UPDATE	FND_MENU_ENTRIES
	SET		MENU_ID = oldid
	WHERE	MENU_ID = newid;

	-- Added for Function Security Cache Invalidation Project.
	-- Need make sure that each menu entry updated is taken into account.
	FOR mn IN mn_entry LOOP
		fnd_function_security_cache.update_menu_entry(newid, mn.sub_menu_id, mn.function_id);
	END LOOP;

	UPDATE	FND_MENU_ENTRIES_TL
	SET		MENU_ID = oldid
	WHERE	MENU_ID = newid;

	UPDATE	FND_RESP_FUNCTIONS
	SET		ACTION_ID = oldid
	WHERE	RULE_TYPE = 'M'
	AND		ACTION_ID = newid;

	-- Added for Function Security Cache Invalidation Project.
	-- Seems that I need make sure that each responsibility updated is taken into account.
	FOR rs IN RESP_FUNC LOOP
		fnd_function_security_cache.update_resp(rs.responsibility_id, rs.application_id);
	END LOOP;

	-- 2. Delete new row
	DELETE	FROM FND_MENUS
	WHERE	MENU_ID = newid;

	-- Added for Function Security Cache Invalidation Project.
	fnd_function_security_cache.update_menu(newid);

	DELETE	FROM FND_MENUS_TL
	WHERE	MENU_ID = newid;

	-- 3. Update oldname to newname in old row
	UPDATE	FND_MENUS
	SET		MENU_NAME = newname
	WHERE	MENU_ID = oldid;

	-- Added for Function Security Cache Invalidation Project.
	fnd_function_security_cache.update_menu(oldid);

END UPDATE_MENU_NAME;

END FND_FUNCTION_SECURITY;

/
