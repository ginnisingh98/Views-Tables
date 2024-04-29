--------------------------------------------------------
--  DDL for Package Body QA_CHARS_API
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."QA_CHARS_API" AS
/* $Header: qltcharb.plb 120.4 2005/06/24 02:29:21 srhariha noship $ */

--
-- Type definition.  These are tables used to create internal
-- cache to improve performance.  Any records retrieved will be
-- temporarily saved into these tables.
--

-- Bug 3769260. shkalyan 30 July 2004.
-- Added this record type for storing relevant QA elements.
-- This is needed as we need to select only specific columns
-- of QAelements instead of selecting * from QA_CHARS

TYPE qa_char_rec IS RECORD
(
    char_id                   qa_chars.char_id%TYPE,
    name                      qa_chars.name%TYPE,
    prompt                    qa_chars.prompt%TYPE,
    data_entry_hint           qa_chars.data_entry_hint%TYPE,
    datatype                  qa_chars.datatype%TYPE,
    display_length            qa_chars.display_length%TYPE,
    decimal_precision         qa_chars.decimal_precision%TYPE,
    default_value             qa_chars.default_value%TYPE,
    mandatory_flag            qa_chars.mandatory_flag%TYPE,
    uom_code                  qa_chars.uom_code%TYPE,
    target_value              qa_chars.target_value%TYPE,
    upper_spec_limit          qa_chars.upper_spec_limit%TYPE,
    lower_spec_limit          qa_chars.lower_spec_limit%TYPE,
    upper_reasonable_limit    qa_chars.upper_reasonable_limit%TYPE,
    lower_reasonable_limit    qa_chars.lower_reasonable_limit%TYPE,
    upper_user_defined_limit  qa_chars.upper_user_defined_limit%TYPE,
    lower_user_defined_limit  qa_chars.lower_user_defined_limit%TYPE,
    hardcoded_column          qa_chars.hardcoded_column%TYPE,
    developer_name            qa_chars.developer_name%TYPE,
    sql_validation_string     qa_chars.sql_validation_string%TYPE,
    enabled_flag              qa_chars.enabled_flag%TYPE,
    values_exist_flag         qa_chars.values_exist_flag%TYPE,
    fk_lookup_type            qa_chars.fk_lookup_type%TYPE,
    fk_meaning                qa_chars.fk_meaning%TYPE
);

TYPE qa_chars_table IS TABLE OF qa_char_rec INDEX BY BINARY_INTEGER;
--TYPE qa_chars_table IS TABLE OF qa_chars%ROWTYPE INDEX BY BINARY_INTEGER;

x_qa_chars_array                qa_chars_table;

--
-- All the fetch_... procedures are auxiliary caching functions
-- called only by inquiry APIs that return the object's attributes.
--

FUNCTION exists_qa_chars(element_id IN NUMBER) RETURN BOOLEAN IS

BEGIN

    RETURN x_qa_chars_array.EXISTS(element_id);

END exists_qa_chars;


PROCEDURE fetch_qa_chars (element_id IN NUMBER) IS

-- Bug 3769260. shkalyan 30 July 2004.
-- Modified cursor to select only specific columns
-- of QA elements instead of selecting * from QA_CHARS

    CURSOR C1 (e_id NUMBER) IS
        SELECT char_id,
               name,
               prompt,
               data_entry_hint,
               datatype,
               display_length,
               decimal_precision,
               default_value,
               mandatory_flag,
               uom_code,
               target_value,
               upper_spec_limit,
               lower_spec_limit,
               upper_reasonable_limit,
               lower_reasonable_limit,
               upper_user_defined_limit,
               lower_user_defined_limit,
               hardcoded_column,
               developer_name,
               sql_validation_string,
               enabled_flag,
               values_exist_flag,
               fk_lookup_type,
               fk_meaning
        FROM   qa_chars
        WHERE  char_id = e_id;

BEGIN

    IF NOT exists_qa_chars(element_id) THEN
    OPEN C1(element_id);
    FETCH C1 INTO x_qa_chars_array(element_id);
    CLOSE C1;
    END IF;

END fetch_qa_chars;


-- Bug 3769260. shkalyan 30 July 2004.
-- Added this procedure to fetch all the elements of a plan
-- The reason for introducing this procedure is to reduce the number of
-- hits on the QA_CHARS.
-- Callers will use this procedure to pre-fetch all the Plan elements
-- to the cache if all the elements of a plan would be accessed.

PROCEDURE fetch_plan_chars (plan_id IN NUMBER) IS

    l_char_rec qa_char_rec;

    CURSOR C1 (p_id NUMBER) IS
        SELECT QC.char_id,
               QC.name,
               QC.prompt,
               QC.data_entry_hint,
               QC.datatype,
               QC.display_length,
               QC.decimal_precision,
               QC.default_value,
               QC.mandatory_flag,
               QC.uom_code,
               QC.target_value,
               QC.upper_spec_limit,
               QC.lower_spec_limit,
               QC.upper_reasonable_limit,
               QC.lower_reasonable_limit,
               QC.upper_user_defined_limit,
               QC.lower_user_defined_limit,
               QC.hardcoded_column,
               QC.developer_name,
               QC.sql_validation_string,
               QC.enabled_flag,
               QC.values_exist_flag,
               QC.fk_lookup_type,
               QC.fk_meaning
        FROM   qa_chars QC,
               qa_plan_chars QPC
        WHERE  QC.char_id = QPC.char_id
        AND    QPC.plan_id = p_id
        AND    QPC.enabled_flag = 1;

BEGIN

    OPEN C1(plan_id);
    LOOP
        FETCH C1 INTO l_char_rec;
        EXIT WHEN C1%NOTFOUND;

        IF NOT exists_qa_chars(l_char_rec.char_id) THEN
           x_qa_chars_array(l_char_rec.char_id) := l_char_rec;
        END IF;
    END LOOP;
    CLOSE C1;

END fetch_plan_chars;

FUNCTION hardcoded_column(element_id IN NUMBER)
    RETURN VARCHAR2 IS

BEGIN

    fetch_qa_chars(element_id);
    IF NOT exists_qa_chars(element_id) THEN
        RETURN NULL;
    END IF;
    RETURN x_qa_chars_array(element_id).hardcoded_column;

END hardcoded_column;


FUNCTION fk_meaning(element_id IN NUMBER)
    RETURN VARCHAR2 IS

BEGIN

    fetch_qa_chars(element_id);
    IF NOT exists_qa_chars(element_id) THEN
        RETURN NULL;
    END IF;
    RETURN x_qa_chars_array(element_id).fk_meaning;

END fk_meaning;


FUNCTION fk_lookup_type(element_id IN NUMBER)
    RETURN NUMBER IS

BEGIN

    fetch_qa_chars(element_id);
    IF NOT exists_qa_chars(element_id) THEN
        RETURN NULL;
    END IF;
    RETURN x_qa_chars_array(element_id).fk_lookup_type;

END fk_lookup_type;


FUNCTION sql_validation_string(element_id IN NUMBER)
    RETURN VARCHAR2 IS

BEGIN

    fetch_qa_chars(element_id);
    IF NOT exists_qa_chars(element_id) THEN
        RETURN NULL;
    END IF;
    RETURN x_qa_chars_array(element_id).sql_validation_string;

END sql_validation_string;


FUNCTION datatype(element_id IN NUMBER)
    RETURN NUMBER IS

BEGIN

    fetch_qa_chars(element_id);
    IF NOT exists_qa_chars(element_id) THEN
        RETURN NULL;
    END IF;
    RETURN x_qa_chars_array(element_id).datatype;

END datatype;


FUNCTION display_length(element_id IN NUMBER)
    RETURN NUMBER IS

BEGIN

    fetch_qa_chars(element_id);
    IF NOT exists_qa_chars(element_id) THEN
        RETURN NULL;
    END IF;
    RETURN x_qa_chars_array(element_id).display_length;

END display_length;


FUNCTION decimal_precision (element_id IN NUMBER)
    RETURN NUMBER IS

BEGIN

    fetch_qa_chars(element_id);
    IF NOT exists_qa_chars(element_id) THEN
        RETURN NULL;
    END IF;
    RETURN x_qa_chars_array(element_id).decimal_precision;

END decimal_precision;


FUNCTION default_value (element_id IN NUMBER)
    RETURN NUMBER IS

BEGIN

    fetch_qa_chars(element_id);
    IF NOT exists_qa_chars(element_id) THEN
        RETURN NULL;
    END IF;
    RETURN x_qa_chars_array(element_id).default_value;

END default_value;


FUNCTION lower_reasonable_limit(element_id IN NUMBER)
    RETURN VARCHAR2 IS

BEGIN

    fetch_qa_chars(element_id);
    IF NOT exists_qa_chars(element_id) THEN
        RETURN NULL;
    END IF;
    RETURN x_qa_chars_array(element_id).lower_reasonable_limit;

END lower_reasonable_limit;


FUNCTION upper_reasonable_limit(element_id IN NUMBER)
    RETURN VARCHAR2 IS

BEGIN

    fetch_qa_chars(element_id);
    IF NOT exists_qa_chars(element_id) THEN
        RETURN NULL;
    END IF;
    RETURN x_qa_chars_array(element_id).upper_reasonable_limit;

END upper_reasonable_limit;


FUNCTION prompt(element_id IN NUMBER)
    RETURN VARCHAR2 IS

BEGIN

    fetch_qa_chars(element_id);
    IF NOT exists_qa_chars(element_id) THEN
        RETURN NULL;
    END IF;
    RETURN x_qa_chars_array(element_id).prompt;

END prompt;


-- SSQR project. 07/29/2003.
FUNCTION data_entry_hint(element_id IN NUMBER)
    RETURN VARCHAR2 IS

BEGIN

    fetch_qa_chars(element_id);
    IF NOT exists_qa_chars(element_id) THEN
        RETURN NULL;
    END IF;
    RETURN x_qa_chars_array(element_id).data_entry_hint;

END data_entry_hint;


FUNCTION mandatory_flag(element_id IN NUMBER)
    RETURN NUMBER IS

BEGIN

    fetch_qa_chars(element_id);
    IF NOT exists_qa_chars(element_id) THEN
        RETURN NULL;
    END IF;
    RETURN x_qa_chars_array(element_id).mandatory_flag;

END mandatory_flag;


FUNCTION format_sql_for_validation (x_string VARCHAR2, x_org_id IN NUMBER,
     x_created_by IN NUMBER)
     RETURN VARCHAR2 IS

    order_pos           NUMBER;
    new_string          VARCHAR2(2500);
    comma_pos           NUMBER;
    from_pos            NUMBER;
    who_created_by      NUMBER;

BEGIN

    -- NOTE: This function is a re-write of format_sql_validation_string
    -- in the qlttrafb package with a lot of modiifcation.  There is
    -- is a similar function named format_sql_for_lov inthis package
    -- that does the formatting specific for lovs.
    --
    -- The reason the original function can not be used are:
    --
    -- 1. The original function retrieves org_id and user_id from
    --    QRI tables.  But, for direct data entry this data
    --    should not and can not be retrieved from QRI.
    --
    -- 2. The original function adds a sql wrapper to the sql, this
    --    is not the correct thing to do in case mobile quality.
    --
    -- 3.  The original function removes Order BY clause from the query.
    --     This is required in mobile quality.
    --
    --
    -- ORASHID

    -- note: this procedure will generally return a string longer than the
    -- input parameter x_string.  dimension the variables to account for this.


    IF (x_created_by IS NULL) THEN
        who_created_by := fnd_global.user_id;
    ELSE
        who_created_by := x_created_by;
    END IF;


    -- allow trailing semi-colon and slash.  Bug 956708.
    -- bso
    new_string := rtrim(x_string, ' ;/');

    -- convert string to all uppercase for searching.
    new_string := upper(new_string);

    -- remove order by clause from string

    order_pos  := instr(new_string, 'ORDER BY');
    IF (order_pos <> 0) THEN
      new_string := SUBSTR(new_string, 1, order_pos - 1);
    END IF;

    new_string := replace(new_string, ':PARAMETER.ORG_ID', to_char(x_org_id));
    new_string := replace(new_string, ':PARAMETER.USER_ID', to_char(who_created_by));

    -- encapsulate query and withdraw the first column
    new_string := 'SELECT CODE FROM (' ||
            'SELECT ''1'' CODE, ''1'' DESCRIPTION ' ||
            'FROM SYS.DUAL WHERE 1=2 ' ||
            'UNION ALL (' ||
            new_string ||
            ') )';

    RETURN new_string;

END format_sql_for_validation;


FUNCTION format_sql_for_lov (x_string IN VARCHAR2, x_org_id IN NUMBER,
    x_created_by IN NUMBER)
    RETURN VARCHAR2 IS

    order_pos           NUMBER;
    new_string          VARCHAR2(2500);
    comma_pos           NUMBER;
    from_pos            NUMBER;
    who_created_by      NUMBER;

BEGIN

    -- note: this procedure is a re-write of format_sql_validation_string
    -- in the qlttrafb package with a lot of modiifcation.
    -- This is needed LOVs in direct data entry for Mobile Quality.
    --
    -- The reasons the original function can not be used are:
    --
    -- 1. The original function retrieves org_id and user_id from
    --    QRI tables.  But, for direct data entry this data
    --    should not and can not be retrieved from QRI.
    --
    -- 2. The original function adds a sql wrapper to the sql, this
    --    is not the correct thing to do in case mobile quality.
    --
    -- 3.  The original function removes second column from the query.
    --     This is a big NO NO in mobile quality.
    --
    -- 4.  The original function removes Order BY clause from the query.
    --     This is required in mobile quality.
    --
    --
    -- ORASHID

    IF (x_created_by IS NULL) THEN
        who_created_by := fnd_global.user_id;
    ELSE
        who_created_by := x_created_by;
    END IF;

    -- note: this procedure will generally return a string longer than the
    -- input parameter x_string.  dimension the variables to account for this.

    -- allow trailing semi-colon and slash.  Bug 956708.
    -- bso
    new_string := rtrim(x_string, ' ;/');

    -- convert string to all uppercase for searching.
    new_string := upper(x_string);

    -- check for :parameters

    new_string := replace(new_string, ':PARAMETER.ORG_ID', to_char(x_org_id));
    new_string := replace(new_string, ':PARAMETER.USER_ID', to_char(who_created_by));


    RETURN new_string;

END format_sql_for_lov;


FUNCTION get_element_id (p_element_name IN VARCHAR2)
    RETURN NUMBER IS

    CURSOR c IS
        SELECT char_id
        FROm qa_chars
        WHERE name = p_element_name
	AND enabled_flag = 1;

    l_element_id NUMBER;

BEGIN

    OPEN c;
    FETCH c INTO l_element_id;
    CLOSE c;

    RETURN l_element_id;

END get_element_id;


FUNCTION has_hardcoded_lov (p_element_id IN NUMBER)
    RETURN BOOLEAN IS

BEGIN

    -- rkaza. 12/15/2003. bug 3280307.
    -- Added Component item to the list of hardcoded lov's.

    -- anagarwa Mon Jul 26 11:37:43 PDT 2004
    -- bug 3773298 Added Serial number, component serial number,
    -- component lot number and lot number lovs missing in
    -- OA Fwk based Quality (iSP, EAM and QWB)

    IF (p_element_id IN
        (qa_ss_const.Item,
         qa_ss_const.Locator,
         qa_ss_const.Comp_Revision,
         qa_ss_const.Comp_Subinventory,
         qa_ss_const.Comp_UOM,
         qa_ss_const.Customer_Name,
         qa_ss_const.Department,
         qa_ss_const.From_Op_Seq_Num,
         qa_ss_const.Production_Line,
         qa_ss_const.PO_Number,
         qa_ss_const.PO_Release_Num,
	 qa_ss_const.po_line_num, -- bug 3215866
         qa_ss_const.PO_Shipment_Num,
         qa_ss_const.Project_Number,
         qa_ss_const.Receipt_Num,
         qa_ss_const.Resource_Code,
         qa_ss_const.Revision,
         qa_ss_const.RMA_Number,
         qa_ss_const.Sales_Order,
         qa_ss_const.Subinventory,
         qa_ss_const.Task_Number,
         qa_ss_const.To_Department,
         qa_ss_const.To_Op_Seq_Num,
         qa_ss_const.UOM,
         qa_ss_const.Vendor_Name,
         qa_ss_const.Job_Name,
	   qa_ss_const.asset_group,
	   qa_ss_const.asset_number,
--dgupta: R12 EAM Integration. Bug 4345492 Start
	   qa_ss_const.asset_instance_number,
--dgupta: R12 EAM Integration. Bug 4345492 End
	   qa_ss_const.asset_activity,
	   qa_ss_const.work_order,
	   qa_ss_const.maintenance_op_seq,
	   qa_ss_const.followup_activity,
	   qa_ss_const.comp_item,
         qa_ss_const.serial_number,
         qa_ss_const.lot_number,
         qa_ss_const.comp_lot_number,
         qa_ss_const.comp_serial_number,
	 /* R12 DR Integration. Bug 4345489 */
         qa_ss_const.repair_order_number,
 	   qa_ss_const.jtf_task_number,
	 /* R12 DR Integration. Bug 4345489 */
         -- R12 OPM Deviations. Bug 4345503 Start
         qa_ss_const.process_batch_num,
         qa_ss_const.process_batchstep_num,
         qa_ss_const.process_operation,
         qa_ss_const.process_activity,
         qa_ss_const.process_resource,
         qa_ss_const.process_parameter
         -- R12 OPM Deviations. Bug 4345503 End
         )
        ) THEN

	RETURN TRUE;

    ELSE

	RETURN FALSE;

    END IF;

END has_hardcoded_lov;

 -- anagarwa Tue Jun 22 14:19:42 PDT 2004
 -- bug 3692326 Support element spec in QWB
FUNCTION lower_spec_limit(element_id IN NUMBER)
    RETURN VARCHAR2 IS

BEGIN

    fetch_qa_chars(element_id);
    IF NOT exists_qa_chars(element_id) THEN
        RETURN NULL;
    END IF;
    RETURN x_qa_chars_array(element_id).lower_spec_limit;

END lower_spec_limit;


FUNCTION upper_spec_limit(element_id IN NUMBER)
    RETURN VARCHAR2 IS

BEGIN

    fetch_qa_chars(element_id);
    IF NOT exists_qa_chars(element_id) THEN
        RETURN NULL;
    END IF;
    RETURN x_qa_chars_array(element_id).upper_spec_limit;

END upper_spec_limit;

FUNCTION target_value(element_id IN NUMBER)
    RETURN VARCHAR2 IS

BEGIN

    fetch_qa_chars(element_id);
    IF NOT exists_qa_chars(element_id) THEN
        RETURN NULL;
    END IF;
    RETURN x_qa_chars_array(element_id).target_value;

END target_value;


-- Bug 3754667. Added the below function to fetch the developer_name
-- for a collection element. kabalakr.

FUNCTION developer_name(element_id IN NUMBER)
    RETURN VARCHAR2 IS

BEGIN

    fetch_qa_chars(element_id);
    IF NOT exists_qa_chars(element_id) THEN
        RETURN NULL;
    END IF;
    RETURN x_qa_chars_array(element_id).developer_name;

END developer_name;

-- Bug 4453386. R12 base line build.
-- Manaully merging 115.19.11510.2 changes and mainline version.
-- srhariha. Fri Jun 24 02:19:00 PDT 2005.

--
-- Bug 3926150.  Added get_element_name.  A useful utility for
-- general use also.
-- bso Sat Dec  4 15:01:54 PST 2004
--
FUNCTION get_element_name (p_element_id IN NUMBER)
    RETURN VARCHAR2 IS
BEGIN
    fetch_qa_chars(p_element_id);
    IF NOT exists_qa_chars(p_element_id) THEN
        RETURN NULL;
    END IF;
    RETURN x_qa_chars_array(p_element_id).name;
END get_element_name;



END qa_chars_api;

/
