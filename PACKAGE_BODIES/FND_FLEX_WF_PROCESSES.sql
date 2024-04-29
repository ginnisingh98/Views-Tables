--------------------------------------------------------
--  DDL for Package Body FND_FLEX_WF_PROCESSES
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."FND_FLEX_WF_PROCESSES" AS
/* $Header: AFFFWFPB.pls 120.1.12010000.1 2008/07/25 14:14:57 appldev ship $ */

--
-- Global Variables
--
g_internal_messages   VARCHAR2(32000) := NULL;
g_validate_parameters BOOLEAN         := TRUE;
g_session_mode        VARCHAR2(100)   := NULL;
g_newline             VARCHAR2(100);
--
-- Who information.
--
TYPE who_type IS RECORD
  (
   created_by        NUMBER,
   creation_date     DATE,
   last_updated_by   NUMBER,
   last_update_date  DATE,
   last_update_login NUMBER
   );

--
-- Private Functions/Procedures
--

-- --------------------------------------------------------------------
FUNCTION get_who RETURN who_type
  IS
     l_who who_type;
BEGIN
   set_session_mode(g_session_mode);
   IF (g_session_mode = 'seed_data') THEN
      l_who.created_by        := 1;
      l_who.creation_date     := To_date('01011996', 'MMDDYYYY');
    ELSIF (g_session_mode = 'customer_data') THEN
      l_who.created_by        := 0;
      l_who.creation_date     := Sysdate;
   END IF;
   l_who.last_updated_by   := l_who.created_by;
   l_who.last_update_date  := l_who.creation_date;
   l_who.last_update_login := 0;
   RETURN(l_who);
END get_who;

-- --------------------------------------------------------------------
PROCEDURE message(msg VARCHAR2) IS
BEGIN
   g_internal_messages := g_internal_messages || msg || g_newline;
END message;

-- --------------------------------------------------------------------
PROCEDURE message_init IS
BEGIN
   g_internal_messages := '';
   message('FND_FLEX_WF_PROCESSES API Messages:');
END message_init;

-- --------------------------------------------------------------------
PROCEDURE validate_flexfield_structure(x_application_id IN NUMBER,
				       x_code           IN VARCHAR2,
				       x_num            IN NUMBER)
  IS
     dummy NUMBER;
BEGIN
   SELECT 1
     INTO dummy
     FROM fnd_id_flex_structures
     WHERE application_id = x_application_id
     AND id_flex_code = x_code
     AND id_flex_num = x_num;
EXCEPTION
   WHEN OTHERS THEN
      raise_application_error(-20001,
			      'Unable to locate flexfield structure:(' ||
			      TO_CHAR(x_application_id) || ',' ||
			      x_code || ',' || TO_CHAR(x_num) ||
			      ').' ||
			      g_newline || ' - Sqlerrm:' || Sqlerrm);
END;

-- --------------------------------------------------------------------
PROCEDURE validate_workflow_process(x_item_type IN VARCHAR2,
				    x_process   IN VARCHAR2)
  IS
     dummy NUMBER;
BEGIN
   BEGIN
      SELECT 1
	INTO dummy
	FROM  wf_runnable_processes_v
	WHERE item_type = x_item_type
	AND process_name = x_process;
   EXCEPTION
      WHEN no_data_found THEN
	 raise_application_error(-20001,
				 'Unable to locate process ' || x_process ||
				 ' in workflow item ' || x_item_type || '.' ||
				 g_newline || ' - Sqlerrm:' || Sqlerrm);
   END;
EXCEPTION
   WHEN OTHERS THEN
      raise_application_error(-20001, 'validate_workflow_process() failed.' ||
			      g_newline || ' - Sqlerrm:' || Sqlerrm);
END;

-- --------------------------------------------------------------------
PROCEDURE validate_workflow_item(x_name IN VARCHAR2)
  IS
     dummy NUMBER;
BEGIN
   BEGIN
      SELECT 1
	INTO dummy
	FROM  wf_item_types_vl item
	WHERE item.name = x_name;
   EXCEPTION
      WHEN no_data_found THEN
	 raise_application_error(-20001,
				 'Unable to locate flexfield workflow item: ' ||
				 x_name || '.' ||
				 g_newline || ' - Sqlerrm:' || Sqlerrm);
   END;

   validate_workflow_process(x_name, 'DEFAULT_ACCOUNT_GENERATION');
EXCEPTION
   WHEN OTHERS THEN
      raise_application_error(-20001, 'validate_workflow_item() failed.' ||
			      g_newline || ' - Sqlerrm:' || Sqlerrm);
END;

--
-- Public Functions/Procedures
--

-- --------------------------------------------------------------------
-- Sets the validate mode on/off
PROCEDURE validate_on IS
BEGIN
   g_validate_parameters := TRUE;
END validate_on;

-- --------------------------------------------------------------------
PROCEDURE validate_off IS
BEGIN
   g_validate_parameters := FALSE;
END validate_off;

-- --------------------------------------------------------------------
-- Returns error messages
FUNCTION message RETURN VARCHAR2
  IS
     l_internal_messages VARCHAR2(32000);
BEGIN
   message('End of Messages.');
   l_internal_messages := g_internal_messages;
   message_init();
   RETURN l_internal_messages;
END message;

-- --------------------------------------------------------------------
-- Sets if this is seed data changes or customer changes
PROCEDURE set_session_mode(session_mode IN VARCHAR2) IS
BEGIN
   IF (session_mode IN ('customer_data', 'seed_data')) THEN
      g_session_mode := session_mode;
    ELSE
      raise_application_error(-20001,
			      'bad session mode:''' || session_mode ||
			      '''. Use set_session_mode() to specify. ' ||
			      'Valid values are: ''customer_data'', ''seed_data''.');
   END IF;
END;

-- --------------------------------------------------------------------
-- Adds a new flexfield workflow item and process
PROCEDURE add_workflow_item_type(x_application_id IN NUMBER,
				 x_code           IN VARCHAR2,
				 x_num            IN NUMBER,
				 x_item_type      IN VARCHAR2,
				 x_process_name   IN VARCHAR2)
  IS
     l_who who_type;
BEGIN
   message_init();
   l_who := get_who();

   IF (g_validate_parameters) THEN
      validate_flexfield_structure(x_application_id, x_code, x_num);
      validate_workflow_item(x_item_type);
      validate_workflow_process(x_item_type, x_process_name);
   END IF;

   INSERT INTO fnd_flex_workflow_processes
     (application_id, id_flex_code, id_flex_num,
      wf_item_type, wf_process_name,
      last_update_date, last_updated_by,
      creation_date, created_by, last_update_login)
     VALUES
     (x_application_id, x_code, x_num,
      x_item_type, x_process_name,
      l_who.last_update_date, l_who.last_updated_by,
      l_who.creation_date, l_who.created_by, l_who.last_update_login);

EXCEPTION
   WHEN OTHERS THEN
      raise_application_error(-20001,
			      'Insert on fnd_flex_workflow_processes failed.' ||
			      g_newline || ' - Sqlerrm:' || Sqlerrm);
END add_workflow_item_type;

-- --------------------------------------------------------------------
PROCEDURE delete_workflow_item_type(x_application_id IN NUMBER,
				    x_code           IN VARCHAR2,
				    x_num            IN NUMBER,
				    x_item_type      IN VARCHAR2)
  IS
BEGIN
   message_init();
   DELETE
     FROM fnd_flex_workflow_processes
     WHERE application_id = x_application_id
     AND id_flex_code = x_code
     AND id_flex_num = x_num
     AND wf_item_type = x_item_type;
EXCEPTION
   WHEN OTHERS THEN
      raise_application_error(-20001,
			      'Delete failed.' ||
			      g_newline || ' - Sqlerrm:' || Sqlerrm);
END delete_workflow_item_type;

-- --------------------------------------------------------------------
-- Changes the process associated with an flex workflow item
PROCEDURE change_workflow_process(x_application_id IN NUMBER,
				  x_code           IN VARCHAR2,
				  x_num            IN NUMBER,
				  x_item_type      IN VARCHAR2,
				  x_process_name   IN VARCHAR2)
  IS
     l_who who_type;
BEGIN
   message_init();
   l_who := get_who();

   IF (g_validate_parameters) THEN
      validate_flexfield_structure(x_application_id, x_code, x_num);
      validate_workflow_item(x_item_type);
      validate_workflow_process(x_item_type, x_process_name);
   END IF;

   UPDATE fnd_flex_workflow_processes
     SET wf_process_name = x_process_name
     WHERE application_id = x_application_id
     AND id_flex_code = x_code
     AND id_flex_num = x_num
     AND wf_item_type = x_item_type;

   IF SQL%NOTFOUND THEN
      raise_application_error(-20001,
			      'Unable to locate workflow item ' ||
			      x_item_type || ' for flexfield structure: ' ||
			      TO_CHAR(x_application_id) || ',' ||
			      x_code || ',' || TO_CHAR(x_num));
   END IF;

   IF (g_session_mode = 'customer_data') THEN
      UPDATE fnd_flex_workflow_processes
	SET last_update_date = l_who.last_update_date,
	last_updated_by = l_who.last_updated_by,
	last_update_login = l_who.last_update_login
	WHERE application_id = x_application_id
	AND id_flex_code = x_code
	AND id_flex_num = x_num
	AND x_item_type = x_item_type;
   END IF;

EXCEPTION
   WHEN OTHERS THEN
      raise_application_error(-20001,
			      'Update on fnd_flex_workflow_processes failed.'||
			      g_newline || ' - Sqlerrm:' || Sqlerrm);
END change_workflow_process;

PROCEDURE add_new_workflow_item_type(p_application_short_name IN VARCHAR2,
				     p_id_flex_code           IN VARCHAR2,
				     p_wf_item_type           IN VARCHAR2)
  IS
     l_who             who_type;
     l_wf_process_name VARCHAR2(100) := 'DEFAULT_ACCOUNT_GENERATION';
     l_application_id  NUMBER;
BEGIN
   message_init();
   l_who := get_who();

   BEGIN
      SELECT application_id
	INTO l_application_id
	FROM fnd_application
	WHERE application_short_name = p_application_short_name;
   EXCEPTION
      WHEN no_data_found THEN
	 raise_application_error(-20001, '''' || p_application_short_name ||
				 ''' application does not exist.');
   END;

   validate_workflow_item(p_wf_item_type);
   validate_workflow_process(p_wf_item_type, l_wf_process_name);

   INSERT INTO fnd_flex_workflow_processes
     (
      application_id,
      id_flex_code,
      id_flex_num,
      wf_item_type,
      wf_process_name,

      last_update_date,
      last_updated_by,
      creation_date,
      created_by,
      last_update_login
      )
     SELECT
     ifst.application_id,
     ifst.id_flex_code,
     ifst.id_flex_num,
     p_wf_item_type,
     l_wf_process_name,

     l_who.last_update_date,
     l_who.last_updated_by,
     l_who.creation_date,
     l_who.created_by,
     l_who.last_update_login
     FROM fnd_id_flex_structures ifst
     WHERE ifst.application_id = l_application_id
     AND ifst.id_flex_code = p_id_flex_code
     AND NOT exists (SELECT NULL
		     FROM fnd_flex_workflow_processes fwp
		     WHERE fwp.application_id = ifst.application_id
		     AND fwp.id_flex_code = ifst.id_flex_code
		     AND fwp.id_flex_num = ifst.id_flex_num
		     AND fwp.wf_item_type = p_wf_item_type);

EXCEPTION
   WHEN OTHERS THEN
      raise_application_error(-20001,
			      'add_new_workflow_item_type() failed.' ||
			      g_newline || ' - Sqlerrm:' || Sqlerrm);
END add_new_workflow_item_type;

-- --------------------------------------------------------------------
BEGIN
   g_newline := fnd_global.newline;
   message_init();
END fnd_flex_wf_processes;

/
