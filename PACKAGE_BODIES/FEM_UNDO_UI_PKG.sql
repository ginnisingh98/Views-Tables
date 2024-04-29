--------------------------------------------------------
--  DDL for Package Body FEM_UNDO_UI_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."FEM_UNDO_UI_PKG" AS
/* $Header: FEMUNDOUIB.pls 120.0 2006/06/30 06:07:50 asadadek noship $ */

FUNCTION get_user_name(p_user_id NUMBER) RETURN VARCHAR2 AS
l_user_name VARCHAR2(100);
BEGIN

SELECT user_name INTO l_user_name
FROM fnd_user
WHERE user_id = p_user_id;

RETURN l_user_name;

EXCEPTION
WHEN no_data_found THEN
 RETURN null;

END;


-- This function gets the undo status for a request and object combination.
-- This function simply returns the execution_status_code of the p_object_id
-- for p_request_id by ordering the status codes in a logical order such that
-- the UI will reflect the correct undo status.
-- The possible undo_status_codes are 'SUCCESS','RUNNING','ERROR_RERUN','ERROR_CANCELLED'.

FUNCTION get_undo_status(p_object_id NUMBER,p_request_id NUMBER) RETURN VARCHAR2 AS
l_undo_status VARCHAR2(100);
BEGIN

SELECT exec_status_code INTO l_undo_status
FROM (SELECT exec_status_code
      FROM  (SELECT exec_status_code
             FROM fem_ud_list_candidates
             WHERE object_id = p_object_id
             AND request_id = p_request_id
             UNION
             SELECT exec_status_code
             FROM fem_ud_list_dependents
             WHERE dependent_object_id = p_object_id
             AND dependent_request_id = p_request_id )
      ORDER by exec_status_code desc)
WHERE  rownum = 1;

RETURN l_undo_status;

EXCEPTION

WHEN no_data_found THEN
 RETURN null;

END;



FUNCTION is_ledger_table(p_table_name varchar2) RETURN VARCHAR2 AS
l_ledger_table VARCHAR2(1) := 'N';
l_count NUMBER;
BEGIN


SELECT count(*) INTO l_count FROM
FEM_TABLE_CLASS_ASSIGNMT class
WHERE class.table_name= p_table_name
AND class.table_classification_code IN ('ABM_LEDGER','PFT_LEDGER');

IF l_count >= 1 THEN
   L_LEDGER_TABLE := 'Y';
END IF;

RETURN  l_ledger_table;

EXCEPTION
WHEN no_data_found THEN
RETURN l_ledger_table;

END;


-- This function checks if a particular Undo candidate and its
-- dependents are not undoable. Checks the validation_status_code column
-- in the preview tables , that is populated by the Undo engine.
-- Returns 'Y' if the candidate and all its dependents are undoable.
-- Returns 'N' otherwise.

FUNCTION is_undo_valid(p_ud_session_id NUMBER,
                       p_object_id NUMBER,
                       p_request_id NUMBER) RETURN VARCHAR2 AS
l_status_code VARCHAR2(40);
l_count NUMBER;
BEGIN

-- First find if the candidate is valid for Undo.
SELECT validation_status_code INTO l_status_code
FROM fem_ud_prview_candidates
WHERE ud_session_id = p_ud_session_id
AND object_id = p_object_id
AND request_id = p_request_id;

IF l_status_code <>  'FEM_UD_VALID_TXT' THEN
 RETURN 'N';
END IF ;

--Now find if any of the dependents is invalid for Undo.
SELECT count(*) into l_count
FROM fem_ud_prview_dependents
WHERE validation_status_code <> 'FEM_UD_VALID_TXT'
AND request_id = p_request_id
AND object_id = p_object_id
AND ud_session_id = p_ud_session_id;

IF l_count > 0 THEN
 RETURN 'N';
END IF;

 RETURN 'Y';

 EXCEPTION
 WHEN no_data_found THEN
  RETURN 'N';

END;

END  fem_undo_ui_pkg;

/
