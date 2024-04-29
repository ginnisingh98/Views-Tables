--------------------------------------------------------
--  DDL for Package Body FND_FLEX_WORKFLOW
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."FND_FLEX_WORKFLOW" AS
/* $Header: AFFFWKFB.pls 120.1.12010000.3 2014/08/22 18:03:33 hgeorgi ship $ */

-- ==================================================
-- CACHING
-- ==================================================
g_kffcache_item_type VARCHAR2(100);
g_kffcache_item_key  VARCHAR2(100);
g_kffcache_key_flex  key_flex_type;

g_cache_return_code VARCHAR2(30);
g_cache_key         VARCHAR2(2000);
g_cache_value       fnd_plsql_cache.generic_cache_value_type;

-- --------------------------------------------------
-- sgc : Segment count cache
-- --------------------------------------------------
sgc_cache_controller      fnd_plsql_cache.cache_1to1_controller_type;
sgc_cache_storage         fnd_plsql_cache.generic_cache_values_type;

-- --------------------------------------------------
-- wfp : Workflow Process Name cache.
-- --------------------------------------------------
wfp_cache_controller      fnd_plsql_cache.cache_1to1_controller_type;
wfp_cache_storage         fnd_plsql_cache.generic_cache_values_type;

-- --------------------------------------------------
-- aid : Application id cache.
-- --------------------------------------------------
aid_cache_controller      fnd_plsql_cache.cache_1to1_controller_type;
aid_cache_storage         fnd_plsql_cache.generic_cache_values_type;

--
-- Global variables
--
g_debug_fnd_flex_workflow BOOLEAN := FALSE;
g_chr_newline             VARCHAR2(8);
g_wf_not_completed        VARCHAR2(100) := 'FLEX_WF_NOT_COMPLETED';

-- ======================================================================
-- DEBUG
-- ======================================================================
PROCEDURE dbms_debug(p_debug IN VARCHAR2)
  IS
     i INTEGER;
     m INTEGER;
     c INTEGER := 80; -- line size
     l_session_id NUMBER;
     utl_file_dir VARCHAR2(4000);
     L_HANDLER UTL_FILE.FILE_TYPE;
BEGIN
      --get the directory where we can write
      SELECT value into utl_file_dir FROM V$PARAMETER WHERE NAME = 'utl_file_dir';
      --get the session id
      SELECT userenv('SESSIONID') into l_session_id from dual;

      -- If no dir defined, then try using /usr/tmp, it may not work.
      -- So you need to edit the init.ora file to include the UTL_FILE_DIR parameter.
      IF utl_file_dir IS NULL THEN
         L_HANDLER := UTL_FILE.FOPEN('/usr/tmp', 'fdfsrvdbg.log', 'A');
      ELSE
        --get the first directory from a possible several dirs
        IF instr(utl_file_dir,',') > 0 THEN
           utl_file_dir := substr(utl_file_dir,1,instr(utl_file_dir,',')-1);
         END IF;
         L_HANDLER := UTL_FILE.FOPEN(utl_file_dir, 'fdfsrvdbg.log', 'A');
      END IF;

   m := Ceil(Length(p_debug)/c);  -- number of lines
   FOR i IN 1..m LOOP
      execute immediate ('begin dbms' ||
			 '_output' ||
			 '.put_line(''' ||
			 REPLACE(Substr(p_debug, 1+c*(i-1), c), '''', '''''') ||
			 '''); end;');
                        UTL_FILE.PUT_LINE(L_HANDLER, CONCAT(l_session_id || ' ', REPLACE(Substr(p_debug, 1+c*(i-1), c), '''', '''''')));
   END LOOP;
   UTL_FILE.FCLOSE(L_HANDLER);
EXCEPTION
   WHEN OTHERS THEN
      UTL_FILE.FCLOSE(L_HANDLER);
END dbms_debug;

-- ======================================================================
PROCEDURE debug(p_debug IN VARCHAR2)
  IS
     l_vc2       VARCHAR2(32000) := p_debug || g_chr_newline;
     l_line_size NUMBER := 75;
     l_pos       NUMBER;
BEGIN
   IF (g_debug_fnd_flex_workflow) THEN
      WHILE (l_vc2 IS NOT NULL) LOOP
	 l_pos := Instr(l_vc2, g_chr_newline, 1, 1); -- find the first new line
	 IF (l_pos >= l_line_size) THEN
	    l_pos := l_line_size;
	 END IF;
	 dbms_debug(Rtrim(Substr(l_vc2, 1, l_pos), g_chr_newline));
	 l_vc2 := Substr(l_vc2, l_pos + 1);
      END LOOP;
   END IF;
EXCEPTION
   WHEN OTHERS THEN
      NULL;
END debug;

-- ======================================================================
PROCEDURE report_wf_error(p_func_name IN VARCHAR2)
  IS
BEGIN
   IF (g_debug_fnd_flex_workflow) THEN
      debug('Account Generator failed in ' || p_func_name ||
	    ' with following error.' || g_chr_newline ||
	    'ERROR_NAME    : ' || wf_core.error_name || g_chr_newline ||
	    'ERROR_MESSAGE : ' || wf_core.error_message || g_chr_newline ||
	    'ERROR_STACK   : ' || wf_core.error_stack || g_chr_newline ||
	    'SQLERRM       : ' || Sqlerrm || g_chr_newline ||
	    'DBMS_ERROR_STACK:' || g_chr_newline ||
	    dbms_utility.format_error_stack() || g_chr_newline ||
	    'DBMS_CALL_STACK:' || g_chr_newline ||
	    dbms_utility.format_call_stack());
   END IF;
EXCEPTION
   WHEN OTHERS THEN
      NULL;
END report_wf_error;

-- ======================================================================
-- bool_to_char
--
-- A utility function to convert boolean values to char to print in
-- debug statements
--
FUNCTION bool_to_char(value IN BOOLEAN)
  RETURN VARCHAR2
  IS
BEGIN
   IF (value) THEN
      RETURN 'TRUE';
    ELSIF (NOT value) THEN
      RETURN 'FALSE';
    ELSE
      RETURN 'NULL';
   END IF;
END bool_to_char;

-- ======================================================================
-- Get the current structure specific attributes from WF.
--
PROCEDURE get_key_flex(p_item_type IN VARCHAR2,
		       p_item_key  IN VARCHAR2,
		       px_key_flex IN OUT nocopy key_flex_type)
  IS
BEGIN
   IF ((g_kffcache_item_type = p_item_type) AND
       (g_kffcache_item_key = p_item_key)) THEN
      NULL;
    ELSE
      g_kffcache_item_type := p_item_type;
      g_kffcache_item_key := p_item_key;

      g_kffcache_key_flex.application_id := To_number
	(wf_engine.GetItemAttrText(p_item_type, p_item_key, 'FND_FLEX_APPLID'));

      g_kffcache_key_flex.application_short_name :=
	wf_engine.GetItemAttrText(p_item_type, p_item_key, 'FND_FLEX_APPLSNAME');

      g_kffcache_key_flex.id_flex_code :=
	wf_engine.GetItemAttrText(p_item_type, p_item_key, 'FND_FLEX_CODE');

      g_kffcache_key_flex.id_flex_num := To_number
	(wf_engine.GetItemAttrText(p_item_type, p_item_key, 'FND_FLEX_NUM'));

      g_kffcache_key_flex.numof_segments := To_number
	(wf_engine.GetItemAttrText(p_item_type, p_item_key, 'FND_FLEX_NSEGMENTS'));
   END IF;

   px_key_flex := g_kffcache_key_flex;

   IF (g_debug_fnd_flex_workflow) THEN
      debug('Account Generator is running for:');
      debug('  WF ITEM = ' || p_item_type || '/' || p_item_key);
      debug('  APPLICATION = ' || (To_char(px_key_flex.application_id) || '/' ||
				   px_key_flex.application_short_name));
      debug('  KEY FLEX = ' || (px_key_flex.id_flex_code || '/' ||
				To_char(px_key_flex.id_flex_num) || '/' ||
				px_key_flex.numof_segments));
   END IF;
END get_key_flex;

-- ======================================================================
-- select_process
--
-- This function selects which process in the given item type
-- should be used to generate the combination for the given
-- structure. This information is stored in the table
-- FND_FLEX_WORKFLOW_PROCESSES
--
FUNCTION select_process(appl_short_name IN VARCHAR2,
			code            IN VARCHAR2,
			num             IN NUMBER,
			itemtype        IN VARCHAR2)
  RETURN VARCHAR2
  IS
     l_pname VARCHAR2(30);
BEGIN
   g_cache_key := (appl_short_name || '.' || code || '.' ||
		   num || '.' || itemtype);
   fnd_plsql_cache.generic_1to1_get_value(wfp_cache_controller,
					  wfp_cache_storage,
					  g_cache_key,
					  g_cache_value,
					  g_cache_return_code);

   IF (g_cache_return_code = fnd_plsql_cache.CACHE_FOUND) THEN
      l_pname := g_cache_value.varchar2_1;
    ELSE
      SELECT
	wf_process_name
	INTO l_pname
	FROM fnd_flex_workflow_processes fwk, fnd_application app
	WHERE app.application_short_name = appl_short_name
	AND fwk.application_id = app.application_id
	AND fwk.id_flex_code = code
	AND fwk.id_flex_num = num
	AND fwk.wf_item_type = itemtype;

      fnd_plsql_cache.generic_cache_new_value
	(x_value      => g_cache_value,
	 p_varchar2_1 => l_pname);

      fnd_plsql_cache.generic_1to1_put_value(wfp_cache_controller,
					     wfp_cache_storage,
					     g_cache_key,
					     g_cache_value);
   END IF;
   RETURN l_pname;
EXCEPTION
   WHEN OTHERS THEN
      RETURN 'DEFAULT_ACCOUNT_GENERATION';
END select_process;


-- ======================================================================
-- get_process_result
--
-- This procedure returns the status/result of a given process.
-- (this will be the value returned
-- by the end activity that terminated the top level process.
--
PROCEDURE get_process_result(p_itemtype   IN VARCHAR2,
			     p_itemkey    IN VARCHAR2,
			     x_status     OUT nocopy VARCHAR2,
			     x_result     OUT nocopy VARCHAR2)
  IS
     l_actid   NUMBER;
     l_status  VARCHAR2(100);
     l_result  VARCHAR2(100);
BEGIN
   --
   -- Get the result of the last activity executed.
   -- If the process has completed, this will be the root process.
   --   Note: to be accurate, this should also check that the actid
   -- returned really is the root process.  If it isn't, the result
   -- will either be an error or a block activity (null result), so
   -- it shouldn't really matter.
   --
   Wf_Item_Activity_Status.LastResult(p_itemtype, p_itemkey,
				      l_actid, l_status, l_result);
   --
   -- Debug
   --
   IF (g_debug_fnd_flex_workflow) THEN
      debug('PROCESS ACTID  IS ' || l_actid);
      debug('PROCESS STATUS IS ' || l_status);
      debug('PROCESS RESULT IS ' || l_result);
   END IF;

   x_status := l_status;
   x_result := l_result;

EXCEPTION
   WHEN OTHERS THEN
      RAISE;
END get_process_result;


-- ======================================================================
-- INITIALIZE
--
-- This function generates an item key from the sequence
-- FND_FLEX_WORKFLOW_ITEMKEY_S, creates a workflow process
-- for the given item, creates/sets values for flexfield
-- specific item attributes.
--
FUNCTION initialize(appl_short_name IN VARCHAR2,
		    code            IN VARCHAR2,
		    num             IN NUMBER,
		    itemtype        IN VARCHAR2)
  RETURN VARCHAR2
  IS
     l_itemkey            VARCHAR2(38);
     l_pname              VARCHAR2(30);
     l_application_id     NUMBER;
     l_nsegments          NUMBER;
     l_profile_debug_mode VARCHAR2(10);
     acct_gen_profile     VARCHAR2(1);
BEGIN


    -- get profile value for "Account Generator: Run in Debug Mode"
    -- This will turn on debug for Work Flow Account Generator
    FND_PROFILE.get('ACCOUNT_GENERATOR:DEBUG_MODE', acct_gen_profile);
    if(acct_gen_profile='Y') then
       g_debug_fnd_flex_workflow:=TRUE;
    end if;


   --
   -- Debug
   --
   IF (g_debug_fnd_flex_workflow) THEN
      debug('START FND_FLEX_WORKFLOW.INITIALIZE');
      debug('APPLICATION_SHORT_NAME = ' || appl_short_name);
      debug('CODE = ' || code);
      debug('NUM = ' || TO_CHAR(num));
      debug('ITEMTYPE = ' || itemtype);
   END IF;

   --
   -- Get Application ID
   --
   g_cache_key := appl_short_name;
   fnd_plsql_cache.generic_1to1_get_value(aid_cache_controller,
					  aid_cache_storage,
					  g_cache_key,
					  g_cache_value,
					  g_cache_return_code);
   IF (g_cache_return_code = fnd_plsql_cache.CACHE_FOUND) THEN
      l_application_id := g_cache_value.number_1;
    ELSE
      SELECT
	application_id
	INTO l_application_id
	FROM fnd_application
	WHERE application_short_name = appl_short_name;

      fnd_plsql_cache.generic_cache_new_value
	(x_value    => g_cache_value,
	 p_number_1 => l_application_id);

      fnd_plsql_cache.generic_1to1_put_value(aid_cache_controller,
					     aid_cache_storage,
					     g_cache_key,
					     g_cache_value);
   END IF;

   --
   -- Get the number of enabled segments for this flexfield structure
   --
   g_cache_key := l_application_id || '.' || code || '.' || num;
   fnd_plsql_cache.generic_1to1_get_value(sgc_cache_controller,
					  sgc_cache_storage,
					  g_cache_key,
					  g_cache_value,
					  g_cache_return_code);
   IF (g_cache_return_code = fnd_plsql_cache.CACHE_FOUND) THEN
      l_nsegments := g_cache_value.number_1;
    ELSE
      SELECT
	COUNT(*)
	INTO l_nsegments
	FROM fnd_id_flex_segments
	WHERE application_id = l_application_id
	AND id_flex_code = code
	AND id_flex_num = num
	AND enabled_flag = 'Y';

      fnd_plsql_cache.generic_cache_new_value
	(x_value    => g_cache_value,
	 p_number_1 => l_nsegments);

      fnd_plsql_cache.generic_1to1_put_value(sgc_cache_controller,
					     sgc_cache_storage,
					     g_cache_key,
					     g_cache_value);
   END IF;

   --
   -- Generate a unique itemkey for this process.
   --
   --
   -- Profile option is used to decide whether to create the process in
   -- synch mode or not.
   -- In synch mode WF doesn't keep all details about attributes.
   -- bug735681 and bug742903.
   --
   IF (fnd_profile.defined('ACCOUNT_GENERATOR:DEBUG_MODE')) THEN
      l_profile_debug_mode := fnd_profile.value('ACCOUNT_GENERATOR:DEBUG_MODE');
    ELSE
      l_profile_debug_mode := 'N';
   END IF;

   IF (l_profile_debug_mode = 'Y') THEN
      SELECT
	TO_CHAR(FND_FLEX_WORKFLOW_ITEMKEY_S.NEXTVAL)
	INTO l_itemkey
	FROM DUAL;
    ELSE -- Synch Mode, key is '#SYNCH'
      l_itemkey := wf_engine.eng_synch;
   END IF;

   --
   -- Select the process to start for the given structure.
   --
   l_pname := fnd_flex_workflow.select_process(appl_short_name, code, num,
					       itemtype);

   --
   -- Debug
   --
   IF (g_debug_fnd_flex_workflow) THEN
      debug('APPLICATION ID = ' || TO_CHAR(l_application_id));
      debug('NUMBER OF SEGMENTS = ' || TO_CHAR(l_nsegments));
      debug('ITEMKEY = ' || l_itemkey);
      debug('PROCESS = ' || l_pname);
   END IF;

   --
   -- Create the workflow process for the given itemtype with the
   -- generated itemkey and selected process.
   --
   wf_engine.CreateProcess(itemtype, l_itemkey, l_pname);

   --
   -- Create item attributes for the process to store the flexfield
   -- information.
   --
   -- Structure specific: (Set when process is created. initialize())
   --
   -- FND_FLEX_APPLSNAME    - Flexfield Application Short Name
   -- FND_FLEX_CODE         - Flexfield Code
   -- FND_FLEX_NUM          - Flexfield Structure Number
   -- FND_FLEX_APPLID       - Flexfield Application ID
   -- FND_FLEX_NSEGMENTS    - Number of enabled segments
   --
   -- Process Run specific: (Nullify before each run. generate())
   --
   -- FND_FLEX_CCID         - Code Combination ID
   -- FND_FLEX_SEGMENTS     - Concatenated Segments
   -- FND_FLEX_DATA         - Concatenated IDs
   -- FND_FLEX_DESCRIPTIONS - Concatenated Descriptions
   -- FND_FLEX_MESSAGE      - Error Message
   -- FND_FLEX_STATUS       - Validation Status
   -- FND_FLEX_INSERT       - Insert new combinations?
   -- FND_FLEX_NEW          - Is this a new code combination?
   -- FND_FLEX_SEGMENTn     - Flexfield Segments
   --
   wf_engine.AddItemAttr(itemtype, l_itemkey, 'FND_FLEX_APPLSNAME');
   wf_engine.AddItemAttr(itemtype, l_itemkey, 'FND_FLEX_CODE');
   wf_engine.AddItemAttr(itemtype, l_itemkey, 'FND_FLEX_NUM');
   wf_engine.AddItemAttr(itemtype, l_itemkey, 'FND_FLEX_APPLID');
   wf_engine.AddItemAttr(itemtype, l_itemkey, 'FND_FLEX_NSEGMENTS');

   wf_engine.AddItemAttr(itemtype, l_itemkey, 'FND_FLEX_CCID');
   wf_engine.AddItemAttr(itemtype, l_itemkey, 'FND_FLEX_SEGMENTS');
   wf_engine.AddItemAttr(itemtype, l_itemkey, 'FND_FLEX_DATA');
   wf_engine.AddItemAttr(itemtype, l_itemkey, 'FND_FLEX_DESCRIPTIONS');
   wf_engine.AddItemAttr(itemtype, l_itemkey, 'FND_FLEX_MESSAGE');
   wf_engine.AddItemAttr(itemtype, l_itemkey, 'FND_FLEX_STATUS');
   wf_engine.AddItemAttr(itemtype, l_itemkey, 'FND_FLEX_INSERT');
   wf_engine.AddItemAttr(itemtype, l_itemkey, 'FND_FLEX_NEW');
   FOR i IN 1..l_nsegments LOOP
      wf_engine.AddItemAttr(itemtype, l_itemkey,
			    'FND_FLEX_SEGMENT' || TO_CHAR(i));
   END LOOP;

   --
   -- Set structure specific Item Attributes.
   --
   wf_engine.SetItemAttrText(itemtype, l_itemkey,
			     'FND_FLEX_APPLSNAME', appl_short_name);
   wf_engine.SetItemAttrText(itemtype, l_itemkey,
			     'FND_FLEX_CODE', code);
   wf_engine.SetItemAttrText(itemtype, l_itemkey,
			     'FND_FLEX_NUM', TO_CHAR(num));
   wf_engine.SetItemAttrText(itemtype, l_itemkey,
			     'FND_FLEX_APPLID', TO_CHAR(l_application_id));
   wf_engine.SetItemAttrText(itemtype, l_itemkey,
			     'FND_FLEX_NSEGMENTS', TO_CHAR(l_nsegments));
   --
   -- Set the kffcache.
   --
   g_kffcache_item_type := itemtype;
   g_kffcache_item_key := l_itemkey;

   g_kffcache_key_flex.application_id         := l_application_id;
   g_kffcache_key_flex.application_short_name := appl_short_name;
   g_kffcache_key_flex.id_flex_code           := code;
   g_kffcache_key_flex.id_flex_num            := num;
   g_kffcache_key_flex.numof_segments         := l_nsegments;

   --
   -- Return the itemkey
   --
   IF (g_debug_fnd_flex_workflow) THEN
      debug('END FND_FLEX_WORKFLOW.INITIALIZE');
   END IF;
   RETURN l_itemkey;

EXCEPTION
   WHEN OTHERS THEN
      wf_core.context('FND_FLEX_WORKFLOW', 'INITIALIZE',
		      itemtype, l_itemkey);
      report_wf_error('FND_FLEX_WORKFLOW.INITIALIZE');
      RAISE;
END initialize;

-- ======================================================================
-- GENERATE
--
-- This function starts the workflow process and retrieves the results.
-- If the process ended in a failure mode, or if the flex validation
-- showed an invalid status then the error message is also retrieved
-- and the function returns a FALSE, otherwise it returns TRUE.
--
-- This function exists in two forms. In the first form, (which should
-- be used when calling from forms client) if new code combinations are
-- generated the combination is not inserted into the database. The
-- second form of this function allows the developer to specify if new
-- code combinations can be inserted (in which case it is the developers
-- responsibility to do a commit after this call if such a combination
-- was inserted. This form of this function is for calling account
-- generator from batch programs).
-- NOTE: FAILURE TO DO A COMMIT AFTER INSERTING A NEW CODE COMBINATION
-- WILL MAINTAIN A TABLE LOCK ON THE CODE COMBINATIONS TABLE!!!
--
FUNCTION generate(itemtype      IN VARCHAR2,
		  itemkey       IN VARCHAR2,
		  ccid          IN OUT nocopy NUMBER,
		  concat_segs   IN OUT nocopy VARCHAR2,
		  concat_ids    IN OUT nocopy VARCHAR2,
		  concat_descrs IN OUT nocopy VARCHAR2,
		  error_message IN OUT nocopy VARCHAR2)
  RETURN BOOLEAN
  IS
     l_insert_if_new   BOOLEAN := FALSE;
     l_new_combination BOOLEAN;
BEGIN
   RETURN generate(itemtype, itemkey, l_insert_if_new, ccid, concat_segs,
		   concat_ids, concat_descrs, error_message,
		   l_new_combination);
END generate;

FUNCTION generate(itemtype        IN VARCHAR2,
		  itemkey         IN VARCHAR2,
		  insert_if_new   IN BOOLEAN,
		  ccid            IN OUT nocopy NUMBER,
		  concat_segs     IN OUT nocopy VARCHAR2,
		  concat_ids      IN OUT nocopy VARCHAR2,
		  concat_descrs   IN OUT nocopy VARCHAR2,
		  error_message   IN OUT nocopy VARCHAR2,
		  new_combination IN OUT nocopy BOOLEAN) RETURN BOOLEAN
  IS
     l_process_status    VARCHAR2(100);
     l_process_result    VARCHAR2(100);
     l_validation_status VARCHAR2(30);
     l_wf_success        BOOLEAN := FALSE;
     l_nsegments         NUMBER;
BEGIN
   --
   -- Debug
   --
   IF (g_debug_fnd_flex_workflow) THEN
      debug('START FND_FLEX_WORKFLOW.GENERATE');
      debug('ITEMTYPE = ' || itemtype);
      debug('ITEMKEY = ' || itemkey);
      debug('INSERT_IF_NEW = ' || bool_to_char(insert_if_new));
   END IF;

   --
   -- Reset Process Run specific Item Attributes. (Init them)
   --
   wf_engine.SetItemAttrText(itemtype, itemkey, 'FND_FLEX_CCID', NULL);
   wf_engine.SetItemAttrText(itemtype, itemkey, 'FND_FLEX_SEGMENTS', NULL);
   wf_engine.SetItemAttrText(itemtype, itemkey, 'FND_FLEX_DATA', NULL);
   wf_engine.SetItemAttrText(itemtype, itemkey, 'FND_FLEX_DESCRIPTIONS', NULL);
   wf_engine.SetItemAttrText(itemtype, itemkey, 'FND_FLEX_MESSAGE', NULL);
   wf_engine.SetItemAttrText(itemtype, itemkey, 'FND_FLEX_STATUS', NULL);
   IF (insert_if_new) THEN
      wf_engine.SetItemAttrText(itemtype, itemkey, 'FND_FLEX_INSERT', 'Y');
    ELSE
      wf_engine.SetItemAttrText(itemtype, itemkey, 'FND_FLEX_INSERT', 'N');
   END IF;
   wf_engine.SetItemAttrText(itemtype, itemkey, 'FND_FLEX_NEW', NULL);

   l_nsegments := To_number
     (wf_engine.GetItemAttrText(itemtype, itemkey, 'FND_FLEX_NSEGMENTS'));

   FOR i IN 1..l_nsegments LOOP
      wf_engine.SetItemAttrText(itemtype, itemkey,
				'FND_FLEX_SEGMENT' || TO_CHAR(i), NULL);
   END LOOP;

   --
   -- Start the process.
   --
   DECLARE
      l_threshold NUMBER;
   BEGIN
      --
      -- Set the cost threshold to a high value so that none of the
      -- functions will ever be run in the background.
      --
      l_threshold := wf_engine.threshold;
      wf_engine.threshold := 999999;

      wf_engine.StartProcess(itemtype, itemkey);

      wf_engine.threshold := l_threshold;
   EXCEPTION
      WHEN OTHERS THEN
	 wf_engine.threshold := l_threshold;
	 RAISE;
   END;

   --
   -- Get the result of the process.
   --
   get_process_result(itemtype, itemkey, l_process_status, l_process_result);

   --
   -- Check the success first.
   --
   IF ((l_process_result = 'SUCCESS') AND
       (l_process_status = wf_engine.eng_completed)) THEN
      l_wf_success := TRUE;
      --
      -- The process completed successfully. Get the results of the
      -- flex valiation. Return error message and fail if the
      -- validation failed.
      --

      ccid := To_number(wf_engine.GetItemAttrText(itemtype, itemkey,
						  'FND_FLEX_CCID'));
      concat_segs := wf_engine.GetItemAttrText(itemtype, itemkey,
					       'FND_FLEX_SEGMENTS');
      concat_ids := wf_engine.GetItemAttrText(itemtype, itemkey,
					      'FND_FLEX_DATA');
      concat_descrs := wf_engine.GetItemAttrText(itemtype, itemkey,
						 'FND_FLEX_DESCRIPTIONS');
      l_validation_status := wf_engine.GetItemAttrText(itemtype, itemkey,
						       'FND_FLEX_STATUS');
      IF (wf_engine.GetItemAttrText(itemtype, itemkey, 'FND_FLEX_NEW')
	  = 'Y') THEN
	 new_combination := TRUE;
       ELSE
	 new_combination := FALSE;
      END IF;

      --
      -- Debug
      --
      IF (g_debug_fnd_flex_workflow) THEN
	 debug('CCID IS ' || TO_CHAR(ccid));
	 debug('CONCATENATED SEGMENTS IS ' || concat_segs);
	 debug('CONCATENATED IDS IS ' || concat_ids);
	 debug('CONCATENATED DESCRIPTIONS IS ' || concat_descrs);
	 debug('NEW COMBINATION IS ' || bool_to_char(new_combination));
	 debug('VALIDATION_STATUS IS ' ||
	       Nvl(l_validation_status, 'NULL, set to INVALID.'));
      END IF;

      --
      -- Generate should not return NULL validation status.
      --
      l_validation_status := Nvl(l_validation_status, 'INVALID');
      IF (l_validation_status <> 'VALID') THEN
	 error_message := wf_engine.GetItemAttrText(itemtype, itemkey,
						    'FND_FLEX_MESSAGE');
	 --
	 -- Debug
	 --
	 IF (g_debug_fnd_flex_workflow) THEN
	    debug('ERROR MESSAGE IS ' || error_message);
	 END IF;
      END IF;

    ELSE
      l_wf_success := FALSE;

      --
      -- This indicates a fatal error. The code combination generation
      -- and validation has not been completed successfully.
      -- Retrieve the error message and set the output values to null
      --
      error_message := wf_engine.GetItemAttrText(itemtype, itemkey,
						 'FND_FLEX_MESSAGE');
      ccid := 0;

      --
      -- Still return whatever is generated.
      --
      concat_segs := wf_engine.GetItemAttrText(itemtype, itemkey,
					       'FND_FLEX_SEGMENTS');
      concat_ids := wf_engine.GetItemAttrText(itemtype, itemkey,
					      'FND_FLEX_DATA');
      concat_descrs := wf_engine.GetItemAttrText(itemtype, itemkey,
						 'FND_FLEX_DESCRIPTIONS');
      new_combination := FALSE;

      --
      -- Debug
      --
      IF (g_debug_fnd_flex_workflow) THEN
	 IF (l_process_status = 'ERROR') THEN
	    debug('ERROR FUNCTION : '|| l_process_result);
	 END IF;
	 debug('ERROR MESSAGE IS ' || error_message);
      END IF;

   END IF;

   IF (g_debug_fnd_flex_workflow) THEN
      debug('END FND_FLEX_WORKFLOW.GENERATE');
   END IF;
   --
   -- If the process resulted in FAILURE or the combination is invalid,
   -- return FALSE, else return TRUE
   --
   IF ((l_wf_success) AND
       (l_validation_status = 'VALID')) THEN
      return TRUE;
    ELSE
      return FALSE;
   END IF;

EXCEPTION
   WHEN OTHERS THEN
      wf_core.context('FND_FLEX_WORKFLOW', 'GENERATE',
		      itemtype, itemkey);
      report_wf_error('FND_FLEX_WORKFLOW.GENERATE');

      IF (error_message IS NULL) THEN
	 error_message := Substr(dbms_utility.format_error_stack(),1,200);
      END IF;

      RETURN FALSE;
END generate;


-- ======================================================================
-- GENERATE_PARTIAL
--
-- This is a special case of the GENERATE function. This was
-- added for PO to combine mutiple account generation into one item
-- type. The runnable processes in this item type have sub-processes
-- that generate code combinations separated by block activities.
-- This function can be used to start these sub-processes from a given
-- block activity. When a block activity is not specified it is started
-- from the start activity of the topmost process. When the sub-process
-- completes its results are returned similiar to the GENERATE function.
-- This function can be called multiple times to complete the
-- runnable process. This allows more than one code combination to
-- be built from a runnable process.
--
-- This function exists in two forms. In the first form, (which should
-- be used when calling from forms client) if new code combinations are
-- generated the combination is not inserted into the database. The
-- second form of this function allows the developer to specify if new
-- code combinations can be inserted (in which case it is the developers
-- responsibility to do a commit after this call if such a combination
-- was inserted. This form of this function is for calling account
-- generator from batch programs).
-- NOTE: FAILURE TO DO A COMMIT AFTER INSERTING A NEW CODE COMBINATION
-- WILL MAINTAIN A TABLE LOCK ON THE CODE COMBINATIONS TABLE!!!
--
FUNCTION generate_partial(itemtype        IN VARCHAR2,
			  itemkey         IN VARCHAR2,
			  subprocess      IN VARCHAR2,
			  block_activity  IN VARCHAR2,
			  ccid            IN OUT nocopy NUMBER,
			  concat_segs     IN OUT nocopy VARCHAR2,
			  concat_ids      IN OUT nocopy VARCHAR2,
			  concat_descrs   IN OUT nocopy VARCHAR2,
			  error_message   IN OUT nocopy VARCHAR2) RETURN BOOLEAN
  IS
     l_insert_if_new BOOLEAN := FALSE;
     l_new_combination BOOLEAN;
BEGIN
   RETURN generate_partial(itemtype, itemkey, subprocess, block_activity,
			   l_insert_if_new, ccid, concat_segs, concat_ids,
			   concat_descrs, error_message, l_new_combination);
END generate_partial;

FUNCTION generate_partial(itemtype        IN VARCHAR2,
			  itemkey         IN VARCHAR2,
			  subprocess      IN VARCHAR2,
			  block_activity  IN VARCHAR2,
			  insert_if_new   IN BOOLEAN,
			  ccid            IN OUT nocopy NUMBER,
			  concat_segs     IN OUT nocopy VARCHAR2,
			  concat_ids      IN OUT nocopy VARCHAR2,
			  concat_descrs   IN OUT nocopy VARCHAR2,
			  error_message   IN OUT nocopy VARCHAR2,
			  new_combination IN OUT nocopy BOOLEAN)
  RETURN BOOLEAN
  IS
     l_process_status    VARCHAR2(100);
     l_process_result    VARCHAR2(100);
     l_validation_status VARCHAR2(30);
     nsegments           NUMBER;
     l_wf_success        BOOLEAN := FALSE;
BEGIN
   --
   -- Debug
   --
   IF (g_debug_fnd_flex_workflow) THEN
      debug('START FND_FLEX_WORKFLOW.GENERATE_PARTIAL');
      debug('ITEMTYPE = ' || itemtype);
      debug('ITEMKEY = ' || itemkey);
      debug('SUBPROCESS = ' || subprocess);
      debug('BLOCK_ACTIVITY = ' || block_activity);
      debug('INSERT_IF_NEW = ' || bool_to_char(insert_if_new));
   END IF;

   --
   -- Set value for attribute FND_FLEX_INSERT to whether the code
   -- combination should be inserted into the database if it is
   -- new.
   --
   IF (insert_if_new) THEN
      wf_engine.SetItemAttrText(itemtype, itemkey,
				'FND_FLEX_INSERT', 'Y');
    ELSE
      wf_engine.SetItemAttrText(itemtype, itemkey,
				'FND_FLEX_INSERT', 'N');
   END IF;

   --
   -- Start the process.
   --
   DECLARE
      l_threshold NUMBER;
   BEGIN
      --
      -- Set the cost threshold to a high value so that none of the
      -- functions will ever be run in the background.
      --
      l_threshold := wf_engine.threshold;
      wf_engine.threshold := 999999;

      IF (block_activity IS NULL) THEN
	 wf_engine.StartProcess(itemtype, itemkey);
       ELSE
	 wf_engine.CompleteActivity(itemtype, itemkey, block_activity, '');
      END IF;

      wf_engine.threshold := l_threshold;
   EXCEPTION
      WHEN OTHERS THEN
	 wf_engine.threshold := l_threshold;
	 RAISE;
   END;

   --
   -- Get the result of the process.
   --
   get_process_result(itemtype, itemkey, l_process_status, l_process_result);

   --
   -- Check the success first.
   --
   IF (((l_process_result = 'SUCCESS') AND
	(l_process_status = wf_engine.eng_completed)) OR
       ((l_process_result IS NULL) AND
	(l_process_status = wf_engine.eng_notified))) THEN
      l_wf_success := TRUE;
      --
      -- The process completed successfully. Get the results of the
      -- flex valiation. Return error message and fail if the
      -- validation failed.
      --

      ccid := TO_NUMBER(wf_engine.GetItemAttrText(itemtype, itemkey,
						  'FND_FLEX_CCID'));
      concat_segs := wf_engine.GetItemAttrText(itemtype, itemkey,
					       'FND_FLEX_SEGMENTS');
      concat_ids := wf_engine.GetItemAttrText(itemtype, itemkey,
					      'FND_FLEX_DATA');
      concat_descrs := wf_engine.GetItemAttrText(itemtype, itemkey,
						 'FND_FLEX_DESCRIPTIONS');
      l_validation_status := wf_engine.GetItemAttrText(itemtype, itemkey,
						       'FND_FLEX_STATUS');
      IF (wf_engine.GetItemAttrText(itemtype, itemkey, 'FND_FLEX_NEW')
	  = 'Y') THEN
	 new_combination := TRUE;
       ELSE
	 new_combination := FALSE;
      END IF;

      --
      -- Debug
      --
      IF (g_debug_fnd_flex_workflow) THEN
	 debug('CCID IS ' || TO_CHAR(ccid));
	 debug('CONCATENATED SEGMENTS IS ' || concat_segs);
	 debug('CONCATENATED ID IS ' || concat_ids);
	 debug('CONCATENATED DESCRIPTIONS IS ' || concat_descrs);
	 debug('NEW COMBINATION IS ' || bool_to_char(new_combination));
	 debug('VALIDATION_STATUS IS ' ||
	       Nvl(l_validation_status, 'NULL, set to INVALID.'));
      END IF;

      --
      -- Generate_partial should not return NULL validation status.
      --
      l_validation_status := Nvl(l_validation_status, 'INVALID');
      IF (l_validation_status <> 'VALID') THEN
	 error_message := wf_engine.GetItemAttrText(itemtype, itemkey,
						    'FND_FLEX_MESSAGE');
	 --
	 -- Debug
	 --
	 IF (g_debug_fnd_flex_workflow) THEN
	    debug('ERROR MESSAGE IS ' || error_message);
	 END IF;
      END IF;

    ELSE
      l_wf_success := FALSE;
      --
      -- This indicates a fatal error. The code combination generation
      -- and validation has not been completed successfully.
      -- Retrieve the error message and set the output values to null
      --
      IF (l_process_status = 'ERROR') THEN
	 error_message := wf_engine.GetItemAttrText(itemtype, itemkey,
						    'FND_FLEX_MESSAGE');
       ELSIF (l_process_result = 'FAILURE') THEN
	 error_message := wf_engine.GetItemAttrText(itemtype, itemkey,
						    'FND_FLEX_MESSAGE');
       ELSE
	 error_message := 'Error: Process ' || subprocess ||
	   ' not completed';
      END IF;

      ccid := 0;

      --
      -- Still return whatever is generated.
      --
      concat_segs := wf_engine.GetItemAttrText(itemtype, itemkey,
					       'FND_FLEX_SEGMENTS');
      concat_ids := wf_engine.GetItemAttrText(itemtype, itemkey,
					      'FND_FLEX_DATA');
      concat_descrs := wf_engine.GetItemAttrText(itemtype, itemkey,
						 'FND_FLEX_DESCRIPTIONS');
      new_combination := FALSE;

      --
      -- Debug
      --
      IF (g_debug_fnd_flex_workflow) THEN
	 IF (l_process_status = 'ERROR') THEN
	    debug('ERROR FUNCTION : '|| l_process_result);
	 END IF;
	 debug('ERROR MESSAGE IS ' || error_message);
      END IF;

   END IF;

   --
   -- Since this is a partial generate just clear the
   -- flexfield attributes for the next run
   --
   wf_engine.SetItemAttrText(itemtype, itemkey, 'FND_FLEX_CCID', NULL);
   wf_engine.SetItemAttrText(itemtype, itemkey, 'FND_FLEX_SEGMENTS', NULL);
   wf_engine.SetItemAttrText(itemtype, itemkey, 'FND_FLEX_DATA', NULL);
   wf_engine.SetItemAttrText(itemtype, itemkey, 'FND_FLEX_DESCRIPTIONS', NULL);
   wf_engine.SetItemAttrText(itemtype, itemkey, 'FND_FLEX_MESSAGE', NULL);
   wf_engine.SetItemAttrText(itemtype, itemkey, 'FND_FLEX_STATUS', NULL);
   wf_engine.SetItemAttrText(itemtype, itemkey, 'FND_FLEX_INSERT', NULL);
   wf_engine.SetItemAttrText(itemtype, itemkey, 'FND_FLEX_NEW', NULL);
   nsegments := TO_NUMBER(wf_engine.GetItemAttrText(itemtype, itemkey,
						    'FND_FLEX_NSEGMENTS'));
   FOR i IN 1..nsegments LOOP
      wf_engine.SetItemAttrText(itemtype, itemkey,
				'FND_FLEX_SEGMENT' || TO_CHAR(i), NULL);
   END LOOP;

   --
   -- If the process resulted in FAILURE or the combination is invalid,
   -- return FALSE, else return TRUE
   --
   IF ((l_wf_success) AND
       (l_validation_status = 'VALID')) THEN
      return TRUE;
    ELSE
      return FALSE;
   END IF;

EXCEPTION
   WHEN OTHERS THEN
      wf_core.context('FND_FLEX_WORKFLOW', 'GENERATE_PARTIAL',
		      itemtype, itemkey);
      report_wf_error('FND_FLEX_WORKFLOW.GENERATE_PARTIAL');

      IF (error_message IS NULL) THEN
	 error_message := Substr(dbms_utility.format_error_stack(),1,200);
      END IF;
      RETURN FALSE;
END generate_partial;

-- ======================================================================
-- LOAD_CONCATENATED_SEGMENTS
-- This is a special procedure for loading values returned by the
-- flexbuilder upgrade plsql function to the workflow process.
-- This function should ONLY be called for this case.
--

PROCEDURE load_concatenated_segments(itemtype      IN VARCHAR2,
				     itemkey       IN VARCHAR2,
				     concat_segs   IN VARCHAR2)
  IS
     nsegments           NUMBER;
     delim               VARCHAR2(10);
     segment_array       FND_FLEX_EXT.SegmentArray;
     l_key_flex          key_flex_type;
BEGIN
   --
   -- Debug
   --
   IF (g_debug_fnd_flex_workflow) THEN
      debug('START FND_FLEX_WORKFLOW.LOAD_CONCATENATED_SEGMENTS');
      debug('CONCATENATED SEGMENTS = ' || concat_segs);
   END IF;

   --
   -- Get the required item attributes
   --
   get_key_flex(itemtype, itemkey, l_key_flex);

   --
   -- Use the FND_FLEX_EXT pacakge to break up the concatenated segments
   --
   delim := fnd_flex_ext.get_delimiter(l_key_flex.application_short_name,
				       l_key_flex.id_flex_code,
				       l_key_flex.id_flex_num);

   --
   -- Debug
   --
   IF (g_debug_fnd_flex_workflow) THEN
      debug('SEGMENT DELIMITER IS ' || delim);
   END IF;

   nsegments := fnd_flex_ext.breakup_segments(concat_segs, delim,
					      segment_array);

   --
   -- Got the values, now assign them to the segment attributes.
   --
   FOR i IN 1..nsegments LOOP
      wf_engine.SetItemAttrText(itemtype, itemkey,
				'FND_FLEX_SEGMENT' || TO_CHAR(i),
				segment_array(i));
      --
      -- Debug
      --
      IF (g_debug_fnd_flex_workflow) THEN
	 debug('VALUE ASSIGNED TO SEGMENT ' || TO_CHAR(i) || ' IS ' ||
	       segment_array(i));
      END IF;
   END LOOP;
END load_concatenated_segments;

-- ======================================================================
-- PURGE
-- Purges the workflow tables of data from a given itemtype, itemkey.
-- This is automatically done within the GENERATE function. This
-- function was added to support GENERATE_PARTIAL.
--
PROCEDURE purge(itemtype       IN VARCHAR2,
		itemkey        IN VARCHAR2)
  IS
BEGIN
   return;
   --
   -- Purge profile is obsolete.  Synch processes have
   -- nothing to purge, and processes being run normally for
   -- debugging should not be purged. - sdstratt
   --
   -- If the profile option ACCOUNT_GENERATOR:PURGE_DATA is set to
   -- 'Y', then purge the workflow runtime data.
   --
   -- IF (fnd_profile.defined('ACCOUNT_GENERATOR:PURGE_DATA')) THEN
   --    purge_flag := fnd_profile.value('ACCOUNT_GENERATOR:PURGE_DATA');
   -- ELSE
   --    purge_flag := 'Y';
   -- END IF;
   -- IF (purge_flag = 'Y') THEN
   --    wf_purge.total(itemtype, itemkey);
   -- END IF;
   --
EXCEPTION
   WHEN OTHERS THEN
      wf_core.context('FND_FLEX_WORKFLOW', 'PURGE',
		      itemtype, itemkey);
      report_wf_error('FND_FLEX_WORKFLOW.PURGE');
      RAISE;
END purge;

-- ======================================================================
-- Set the debug mode on
--
PROCEDURE debug_on IS
BEGIN
   execute immediate ('begin dbms' ||
		      '_output' ||
		      '.enable(1000000); end;');
   g_debug_fnd_flex_workflow := TRUE;
   fnd_flex_workflow_apis.debug_on();
END debug_on;

--
-- Set the debug mode off
--
PROCEDURE debug_off IS
BEGIN
   g_debug_fnd_flex_workflow := FALSE;
   fnd_flex_workflow_apis.debug_off();
END debug_off;

BEGIN
   g_chr_newline := fnd_global.newline;

   g_kffcache_item_type := '$FLEX$';
   g_kffcache_item_key := '$FLEX$';

   fnd_plsql_cache.generic_1to1_init('WKF.SGC',
				     sgc_cache_controller,
				     sgc_cache_storage);

   fnd_plsql_cache.generic_1to1_init('WKF.WFP',
				     wfp_cache_controller,
				     wfp_cache_storage);

   fnd_plsql_cache.generic_1to1_init('WKF.AID',
				     aid_cache_controller,
				     aid_cache_storage);
END fnd_flex_workflow;

/
