--------------------------------------------------------
--  DDL for Package Body JTF_DIAG_HELPER_UTILS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."JTF_DIAG_HELPER_UTILS" AS
/* $Header: jtf_diag_helper_utils_b.pls 120.1.12010000.2 2008/08/29 07:11:05 sramados ship $*/

FUNCTION initialise_Input_Collection RETURN JTF_DIAG_TEST_INPUTS IS
 temp JTF_DIAG_TEST_INPUTS;
BEGIN
 temp := JTF_DIAG_TEST_INPUTS(JTF_DIAG_TEST_INPUT('','','','','','','',''));
 temp.trim;
 return temp;
EXCEPTION
 WHEN others THEN
  return null;
END initialise_Input_Collection;


FUNCTION addInput(inputs IN JTF_DIAG_TEST_INPUTS,
                   name   IN  VARCHAR2,
                   value   IN  VARCHAR2,
                   isConfidential IN VARCHAR2 default 'FALSE',
                   defaultValue IN VARCHAR2 default null,
                   tip IN  VARCHAR2 default null,
                   isMandatory IN  VARCHAR2 default 'FALSE',
                   isDate IN VARCHAR2 default 'FALSE',
                   isNumber IN VARCHAR2 default 'FALSE') RETURN JTF_DIAG_TEST_INPUTS IS
  tempInput JTF_DIAG_TEST_INPUT;
  tempInputTable JTF_DIAG_TEST_INPUTS;
  temp_confdential VARCHAR2(6) := isConfidential;
  temp_mandatory   VARCHAR2(6) := isMandatory;
  temp_date        VARCHAR2(6) := isDate;
  temp_number      VARCHAR2(6) := isNumber;
  BEGIN
    IF isConfidential IS NULL THEN
      temp_confdential := 'FALSE';
    END IF;
    IF isMandatory IS NULL THEN
       temp_mandatory := 'FALSE';
    END IF;
    IF isDate IS NULL THEN
      temp_date := 'FALSE';
    END IF;
    IF isNumber IS NULL THEN
      temp_number := 'FALSE';
    END IF;
    tempInputTable := inputs;
    tempInput := JTF_DIAG_TEST_INPUT(name, value, temp_confdential, defaultValue, tip, temp_mandatory, temp_date, temp_number);
    tempInputTable.extend(1);
    tempInputTable(tempInputTable.COUNT) := tempInput;
	return tempInputTable;
  EXCEPTION
    WHEN others THEN
	 -- logging here...
	 return inputs;
END addInput;

----------------------------------------------------------------------
  -- getInputValue takes the argument name that we want the associated
  -- value for, and the JTF_DIAG_INPUTTBL of objects (table of JTF_DIAG_INPUTS)
  -- the associated value is extracted from the JTF_DIAG_INPUTTBL and returned
  -- for the passed in argument name.
  ----------------------------------------------------------------------

 FUNCTION GET_INPUT_VALUE(argName IN VARCHAR2,
                        inputs IN JTF_DIAG_INPUTTBL) RETURN VARCHAR2 IS
  input JTF_DIAG_INPUTS;
 BEGIN
   FOR v_counter IN 1..inputs.COUNT LOOP
      input := inputs(v_counter);
          IF UPPER(inputs(v_counter).name) = UPPER(argName) THEN
                return UPPER(inputs(v_counter).value);
          END IF;
   END LOOP;
   return NULL;
 END;
END JTF_DIAG_HELPER_UTILS;


/
