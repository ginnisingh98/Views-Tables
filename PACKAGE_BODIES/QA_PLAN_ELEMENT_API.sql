--------------------------------------------------------
--  DDL for Package Body QA_PLAN_ELEMENT_API
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."QA_PLAN_ELEMENT_API" AS
/* $Header: qltelemb.plb 120.35.12010000.8 2010/04/26 17:12:29 ntungare ship $ */

--
-- Type definition.  These are tables used to create internal
-- cache to improve performance.  Any records retrieved will be
-- temporarily saved into these tables.
--

-- Bug 3769260. shkalyan 30 July 2004.
-- Added this record type for storing relevant QA Spec elements.
-- This is needed as we need to select only specific columns
-- of QA spec elements instead of selecting * from QA_SPEC_CHARS

TYPE qa_spec_char_rec IS RECORD
(
    spec_id                   qa_spec_chars.spec_id%TYPE,
    char_id                   qa_spec_chars.char_id%TYPE,
    enabled_flag              qa_spec_chars.enabled_flag%TYPE,
    target_value              qa_spec_chars.target_value%TYPE,
    upper_spec_limit          qa_spec_chars.upper_spec_limit%TYPE,
    lower_spec_limit          qa_spec_chars.lower_spec_limit%TYPE,
    upper_reasonable_limit    qa_spec_chars.upper_reasonable_limit%TYPE,
    lower_reasonable_limit    qa_spec_chars.lower_reasonable_limit%TYPE,
    upper_user_defined_limit  qa_spec_chars.upper_user_defined_limit%TYPE,
    lower_user_defined_limit  qa_spec_chars.lower_user_defined_limit%TYPE,
    uom_code                  qa_spec_chars.uom_code%TYPE
);

TYPE qa_spec_chars_table IS TABLE OF qa_spec_char_rec
    INDEX BY BINARY_INTEGER;

--TYPE qa_spec_chars_table IS TABLE OF qa_spec_chars%ROWTYPE
--  INDEX BY BINARY_INTEGER;

-- Bug 3769260. shkalyan 30 July 2004.
-- Added this record type for storing relevant QA Plan elements.
-- This is needed as we need to select only specific columns
-- of QA Plan elements instead of selecting * from QA_PLAN_CHARS

TYPE qa_plan_char_rec IS RECORD
(
    plan_id                   qa_plan_chars.plan_id%TYPE,
    char_id                   qa_plan_chars.char_id%TYPE,
    prompt_sequence           qa_plan_chars.prompt_sequence%TYPE,
    prompt                    qa_plan_chars.prompt%TYPE,
    enabled_flag              qa_plan_chars.enabled_flag%TYPE,
    mandatory_flag            qa_plan_chars.mandatory_flag%TYPE,
    default_value             qa_plan_chars.default_value%TYPE,
    default_value_id          qa_plan_chars.default_value_id%TYPE,
    result_column_name        qa_plan_chars.result_column_name%TYPE,
    values_exist_flag         qa_plan_chars.values_exist_flag%TYPE,
    displayed_flag            qa_plan_chars.displayed_flag%TYPE,
    decimal_precision         qa_plan_chars.decimal_precision%TYPE,
    uom_code                  qa_plan_chars.uom_code%TYPE,
    read_only_flag            qa_plan_chars.read_only_flag%TYPE,
    ss_poplist_flag           qa_plan_chars.ss_poplist_flag%TYPE,
    information_flag          qa_plan_chars.information_flag%TYPE
);

TYPE qa_plan_chars_table IS TABLE OF qa_plan_char_rec
    INDEX BY BINARY_INTEGER;

--12.1 QWB Usability Improvements project
Type string_list is table of varchar2(200) index by binary_integer;

--TYPE qa_plan_chars_table IS TABLE OF qa_plan_chars%ROWTYPE
--  INDEX BY BINARY_INTEGER;

    CURSOR cursor_qa_plan_chars(p_id NUMBER) IS
        SELECT  plan_id,
                char_id,
                prompt_sequence,
                prompt,
                enabled_flag,
                mandatory_flag,
                default_value,
                default_value_id,
                result_column_name,
                values_exist_flag,
                displayed_flag,
                decimal_precision,
                uom_code,
                read_only_flag,
                ss_poplist_flag,
                information_flag
        FROM    qa_plan_chars
        WHERE   plan_id = p_id
        AND     enabled_flag = 1;

--
-- Package Variables: These will be populated at run time
--

x_qa_spec_chars_array           qa_spec_chars_table;
x_qa_plan_chars_array           qa_plan_chars_table;

    --
    -- All the fetch_... procedures are auxiliary caching functions
    -- called only by inquiry APIs that return the object's attributes.
    --

    --
    -- This plan element index is used to hash plan id and element id
    -- into one unique integer to be used as index into the cache.
    --

FUNCTION plan_element_index(plan_id IN NUMBER, element_id IN NUMBER)
    RETURN NUMBER IS

    i NUMBER;
BEGIN
    --
    -- Bug 2409938
    -- This is a potential installation/upgrade error.
    -- Error happens if there is some customization of
    -- collection plans or elements with huge IDs.
    -- Temporarily fixed with a modulus.  It should be
    -- properly fixed with a hash collision resolution.
    -- But the temp workaround should only have collision
    -- when user has more than 20,000 collection plans
    -- *and still* with a probability of about 1/200,000.
    -- bso Tue Jul 16 12:41:23 PDT 2002
    --

    --
    -- Bug 2465704
    -- The above hash collision problem is now fixed with
    -- linear hash collision resolution.
    -- The plan_element array is hit to see if the index
    -- contains the right plan element.  If not, we search
    -- forward until either the matching plan element is
    -- reached or an empty cell is reached.
    --
    -- Because of this, we need to introduce a new function
    -- spec_element_index for use by the spec_element array.
    -- bso Sun Dec  1 17:39:18 PST 2002
    --

    i := mod(plan_id * qa_ss_const.max_elements + element_id,
           2147483647);

    LOOP
        IF NOT x_qa_plan_chars_array.EXISTS(i) THEN
            RETURN i;
        END IF;

        IF x_qa_plan_chars_array(i).plan_id = plan_id AND
           x_qa_plan_chars_array(i).char_id = element_id THEN
            RETURN i;
        END IF;

        i := mod(i + 1, 2147483647);
    END LOOP;

END plan_element_index;


FUNCTION spec_element_index(p_spec_id IN NUMBER, p_element_id IN NUMBER)
    RETURN NUMBER IS

    i NUMBER;
BEGIN
    -- Bug 2465704
    -- See comments in plan_element_index.

    i := mod(p_spec_id * qa_ss_const.max_elements + p_element_id,
           2147483647);

    LOOP
        IF NOT x_qa_spec_chars_array.EXISTS(i) THEN
            RETURN i;
        END IF;

        IF x_qa_spec_chars_array(i).spec_id = p_spec_id AND
           x_qa_spec_chars_array(i).char_id = p_element_id THEN
            RETURN i;
        END IF;

        i := mod(i + 1, 2147483647);
    END LOOP;

END spec_element_index;


FUNCTION exists_qa_spec_chars(spec_id IN NUMBER, element_id IN NUMBER)
    RETURN BOOLEAN IS
BEGIN
    RETURN x_qa_spec_chars_array.EXISTS(
        spec_element_index(spec_id, element_id));
END exists_qa_spec_chars;


--
-- See Bug 2624112
--
-- Modified the logic for Global Specifications Enhancements
--
-- rkunchal
--

PROCEDURE fetch_qa_spec_chars (spec_id IN NUMBER, element_id IN NUMBER) IS

-- Bug 3769260. shkalyan 30 July 2004.
-- Modified cursor to select only specific columns
-- of QA spec elements instead of selecting * from QA_SPEC_CHARS

    CURSOR C1 (s_id NUMBER, e_id NUMBER) IS
        SELECT QSC.spec_id,
               QSC.char_id,
               QSC.enabled_flag,
               QSC.target_value,
               QSC.upper_spec_limit,
               QSC.lower_spec_limit,
               QSC.upper_reasonable_limit,
               QSC.lower_reasonable_limit,
               QSC.upper_user_defined_limit,
               QSC.lower_user_defined_limit,
               QSC.uom_code
        FROM   qa_spec_chars QSC,
               qa_specs QS
        WHERE  QSC.char_id = e_id
        AND    QSC.spec_id = QS.common_spec_id
        AND    QS.spec_id = s_id;

BEGIN

    IF NOT exists_qa_spec_chars(spec_id, element_id) THEN
        OPEN C1(spec_id, element_id);

        FETCH C1 INTO x_qa_spec_chars_array(
            spec_element_index(spec_id, element_id));
        CLOSE C1;
    END IF;

END fetch_qa_spec_chars;

-- Bug 3769260. shkalyan 30 July 2004.
-- Added this procedure to fetch all the elements of a specifications
-- The reason for introducing this procedure is to reduce the number of
-- hits on the QA_SPEC_CHARS.
-- Callers will use this procedure to pre-fetch all the Spec elements
-- to the cache if all the elements of a Spec would be accessed.

PROCEDURE fetch_qa_spec_chars (spec_id IN NUMBER) IS

    CURSOR C1 (s_id NUMBER) IS
        SELECT QSC.spec_id,
               QSC.char_id,
               QSC.enabled_flag,
               QSC.target_value,
               QSC.upper_spec_limit,
               QSC.lower_spec_limit,
               QSC.upper_reasonable_limit,
               QSC.lower_reasonable_limit,
               QSC.upper_user_defined_limit,
               QSC.lower_user_defined_limit,
               QSC.uom_code
        FROM   qa_spec_chars QSC,
               qa_specs QS
        WHERE  QSC.spec_id = QS.common_spec_id
        AND    QS.spec_id = s_id;

    l_spec_char_rec    qa_spec_char_rec;

BEGIN

    OPEN C1(spec_id);
    LOOP
        FETCH C1 INTO l_spec_char_rec;
        EXIT WHEN C1%NOTFOUND;

        IF NOT exists_qa_spec_chars(spec_id, l_spec_char_rec.char_id) THEN
           x_qa_spec_chars_array(spec_element_index(spec_id, l_spec_char_rec.char_id)) := l_spec_char_rec;
        END IF;
    END LOOP;
    CLOSE C1;

END fetch_qa_spec_chars;


FUNCTION exists_qa_plan_chars(plan_id IN NUMBER, element_id IN NUMBER)
    RETURN BOOLEAN IS
BEGIN

    RETURN x_qa_plan_chars_array.EXISTS(
        plan_element_index(plan_id, element_id));
END exists_qa_plan_chars;


PROCEDURE fetch_qa_plan_chars (plan_id IN NUMBER, element_id IN NUMBER) IS

-- Bug 3769260. shkalyan 30 July 2004.
-- Modified cursor to select only specific columns
-- of QA plan elements instead of selecting * from QA_PLAN_CHARS

    CURSOR C1 (p_id NUMBER, e_id NUMBER) IS
        SELECT  plan_id,
                char_id,
                prompt_sequence,
                prompt,
                enabled_flag,
                mandatory_flag,
                default_value,
                default_value_id,
                result_column_name,
                values_exist_flag,
                displayed_flag,
                decimal_precision,
                uom_code,
                read_only_flag,
                ss_poplist_flag,
                information_flag
        FROM    qa_plan_chars
        WHERE   plan_id = p_id
        AND     char_id = e_id
        AND enabled_flag = 1;

BEGIN

    IF NOT exists_qa_plan_chars(plan_id, element_id) THEN

        OPEN C1(plan_id, element_id);
        FETCH C1 INTO x_qa_plan_chars_array(
            plan_element_index(plan_id, element_id));

        CLOSE C1;
    END IF;

    EXCEPTION WHEN OTHERS THEN
        RAISE;
END fetch_qa_plan_chars;

-- Bug 3769260. shkalyan 30 July 2004.
-- Added this procedure to fetch all the elements of a plan
-- The reason for introducing this procedure is to reduce the number of
-- hits on the QA_PLAN_CHARS.
-- Callers will use this procedure to pre-fetch all the Plan elements
-- to the cache if all the elements of a plan would be accessed.

PROCEDURE fetch_qa_plan_chars (plan_id IN NUMBER) IS
    l_plan_char_rec qa_plan_char_rec;

    -- Bug 5182097.  Cursor C1 is needed in the new proc
    -- refetch_qa_plan_chars, so extracted out to package
    -- level and renaming it to cursor_qa_plan_chars.
    -- bso Mon May  1 16:59:56 PDT 2006

BEGIN

    OPEN cursor_qa_plan_chars(plan_id);
    LOOP
        FETCH cursor_qa_plan_chars INTO l_plan_char_rec;
        EXIT WHEN cursor_qa_plan_chars%NOTFOUND;

        IF NOT exists_qa_plan_chars(plan_id, l_plan_char_rec.char_id) THEN
           x_qa_plan_chars_array(plan_element_index(plan_id, l_plan_char_rec.char_id)) := l_plan_char_rec;
        END IF;
    END LOOP;
    CLOSE cursor_qa_plan_chars;

END fetch_qa_plan_chars;


PROCEDURE refetch_qa_plan_chars(p_plan_id IN NUMBER) IS
--
-- Bug 5182097.  Need a procedure to repopulate qpc otherwise
-- some subtle changes in Setup Collection Plans are not immediately
-- reflected in QWB.  Also need Map_in_demand to call this proc during
-- qwb execution.
--
-- The procedure is almost identical to fetch_qa_plan_chars except
-- it doesn't first check if the plan char exists.  Fetching is
-- forced to avoid caching problem.
--
-- bso Mon May  1 17:01:45 PDT 2006
--
    l_plan_char_rec qa_plan_char_rec;

BEGIN

    OPEN cursor_qa_plan_chars(p_plan_id);
    LOOP
        FETCH cursor_qa_plan_chars INTO l_plan_char_rec;
        EXIT WHEN cursor_qa_plan_chars%NOTFOUND;

        x_qa_plan_chars_array(plan_element_index(p_plan_id,
            l_plan_char_rec.char_id)) := l_plan_char_rec;
    END LOOP;
    CLOSE cursor_qa_plan_chars;

END refetch_qa_plan_chars;

--
-- This is a qa_spec_chars inquiry API.
--
FUNCTION qsc_lower_reasonable_limit(spec_id IN NUMBER,
    element_id IN NUMBER) RETURN VARCHAR2 IS
BEGIN
    fetch_qa_spec_chars(spec_id, element_id);
    IF NOT exists_qa_spec_chars(spec_id, element_id) THEN
        RETURN NULL;
    END IF;
    RETURN x_qa_spec_chars_array(spec_element_index(spec_id, element_id)).
        lower_reasonable_limit;
END qsc_lower_reasonable_limit;


--
-- This is a qa_spec_chars inquiry API.
--
FUNCTION qsc_upper_reasonable_limit(spec_id IN NUMBER,
    element_id IN NUMBER) RETURN VARCHAR2 IS
BEGIN
    fetch_qa_spec_chars(spec_id, element_id);
    IF NOT exists_qa_spec_chars(spec_id, element_id) THEN
        RETURN NULL;
    END IF;
    RETURN x_qa_spec_chars_array(spec_element_index(spec_id, element_id)).
        upper_reasonable_limit;
END qsc_upper_reasonable_limit;


--
-- This is a qa_plan_chars inquiry API.
--
FUNCTION qpc_enabled_flag(plan_id IN NUMBER,
    element_id IN NUMBER) RETURN NUMBER IS
BEGIN
    fetch_qa_plan_chars(plan_id, element_id);
    IF NOT exists_qa_plan_chars(plan_id, element_id) THEN
        RETURN NULL;
    END IF;
    RETURN x_qa_plan_chars_array(plan_element_index(plan_id, element_id)).
        enabled_flag;
END qpc_enabled_flag;

--
-- See Bug 2624112
-- The decimal precision for a number type collection
-- element is to be configured at plan level.
-- rkunchal Wed Oct 16 05:32:33 PDT 2002
--
-- Decimal Precision is taken from qa_plan_chars
--

--
-- This is a qa_plan_chars inquiry API.
--
FUNCTION qpc_decimal_precision(p_plan_id IN NUMBER,
                               p_element_id IN NUMBER) RETURN NUMBER IS
BEGIN

    fetch_qa_plan_chars(p_plan_id, p_element_id);
    IF NOT exists_qa_plan_chars(p_plan_id, p_element_id) THEN
        RETURN NULL;
    END IF;

    RETURN x_qa_plan_chars_array(plan_element_index(p_plan_id, p_element_id)).
        decimal_precision;

END qpc_decimal_precision;

--
-- This is a qa_plan_chars inquiry API.
--
FUNCTION qpc_mandatory_flag(plan_id IN NUMBER,
    element_id IN NUMBER) RETURN NUMBER IS
BEGIN
    fetch_qa_plan_chars(plan_id, element_id);
    IF NOT exists_qa_plan_chars(plan_id, element_id) THEN
        RETURN NULL;
    END IF;
    RETURN x_qa_plan_chars_array(plan_element_index(plan_id, element_id)).
        mandatory_flag;
END qpc_mandatory_flag;


-- New get functions added for the new columns in qa_plan_chars
-- SSQR project

FUNCTION qpc_displayed_flag(plan_id IN NUMBER,
    element_id IN NUMBER) RETURN NUMBER IS
BEGIN
    fetch_qa_plan_chars(plan_id, element_id);
    IF NOT exists_qa_plan_chars(plan_id, element_id) THEN
        RETURN NULL;
    END IF;
    RETURN x_qa_plan_chars_array(plan_element_index(plan_id, element_id)).
        displayed_flag;
END qpc_displayed_flag;



FUNCTION qpc_poplist_flag(plan_id IN NUMBER,
    element_id IN NUMBER) RETURN NUMBER IS
BEGIN
    fetch_qa_plan_chars(plan_id, element_id);
    IF NOT exists_qa_plan_chars(plan_id, element_id) THEN
        RETURN NULL;
    END IF;
    RETURN x_qa_plan_chars_array(plan_element_index(plan_id, element_id)).
        ss_poplist_flag;
END qpc_poplist_flag;



FUNCTION qpc_read_only_flag(plan_id IN NUMBER,
    element_id IN NUMBER) RETURN NUMBER IS
BEGIN
    fetch_qa_plan_chars(plan_id, element_id);
    IF NOT exists_qa_plan_chars(plan_id, element_id) THEN
        RETURN NULL;
    END IF;
    RETURN x_qa_plan_chars_array(plan_element_index(plan_id, element_id)).
        read_only_flag;
END qpc_read_only_flag;

--
-- This is a qa_plan_chars inquiry API.
--
FUNCTION qpc_values_exist_flag(plan_id IN NUMBER,
    element_id IN NUMBER) RETURN NUMBER IS
BEGIN

    fetch_qa_plan_chars(plan_id, element_id);
    IF NOT exists_qa_plan_chars(plan_id, element_id) THEN
        RETURN NULL;
    END IF;

    RETURN x_qa_plan_chars_array(plan_element_index(plan_id, element_id)).
        values_exist_flag;
END qpc_values_exist_flag;


--
-- This is a qa_plan_chars inquiry API.
--
FUNCTION qpc_result_column_name (plan_id IN NUMBER,
    element_id IN NUMBER) RETURN VARCHAR2 IS
BEGIN

    fetch_qa_plan_chars(plan_id, element_id);
    IF NOT exists_qa_plan_chars(plan_id, element_id) THEN
        RETURN NULL;
    END IF;

    RETURN x_qa_plan_chars_array(plan_element_index(plan_id, element_id)).
        result_column_name;
END qpc_result_column_name;

--
-- This is a qa_plan_chars inquiry API.
--
FUNCTION get_prompt (plan_id IN NUMBER,
    element_id IN NUMBER) RETURN VARCHAR2 IS
BEGIN

    fetch_qa_plan_chars(plan_id, element_id);
    IF NOT exists_qa_plan_chars(plan_id, element_id) THEN
        RETURN NULL;
    END IF;

    RETURN x_qa_plan_chars_array(plan_element_index(plan_id, element_id)).
        prompt;
END get_prompt;


--
-- This is a qa_plan_chars inquiry API.
--
FUNCTION get_uom_code (plan_id IN NUMBER,
    element_id IN NUMBER) RETURN VARCHAR2 IS
BEGIN

    fetch_qa_plan_chars(plan_id, element_id);
    IF NOT exists_qa_plan_chars(plan_id, element_id) THEN
        RETURN NULL;
    END IF;

    RETURN x_qa_plan_chars_array(plan_element_index(plan_id, element_id)).
        uom_code;
END get_uom_code;


--
-- This is a qa_plan_chars inquiry API.
--
FUNCTION get_decimal_precision (plan_id IN NUMBER,
    element_id IN NUMBER) RETURN VARCHAR2 IS
BEGIN

    fetch_qa_plan_chars(plan_id, element_id);
    IF NOT exists_qa_plan_chars(plan_id, element_id) THEN
        RETURN NULL;
    END IF;

    RETURN x_qa_plan_chars_array(plan_element_index(plan_id, element_id)).
        decimal_precision;
END get_decimal_precision;


FUNCTION keyflex (element_id IN NUMBER)
    RETURN BOOLEAN IS

BEGIN
-- Added bill_reference,routing_reference,to_locator for NCM Hardode Elements.
-- Bug 2449067.

-- added the following to include new hardcoded element followup activity
-- saugupta Aug 2003

    RETURN element_id IN (qa_ss_const.item, qa_ss_const.locator,
        qa_ss_const.comp_item, qa_ss_const.comp_locator, qa_ss_const.asset_group, qa_ss_const.asset_activity, qa_ss_const.followup_activity, qa_ss_const.bill_reference, qa_ss_const.routing_reference, qa_ss_const.to_locator);
END keyflex;


FUNCTION normalized (element_id IN NUMBER)
    RETURN BOOLEAN IS
BEGIN
    RETURN (NOT keyflex(element_id))
        AND (qa_chars_api.hardcoded_column(element_id) IS NOT NULL)
        AND (qa_chars_api.fk_meaning(element_id) IS NOT NULL)
        AND (qa_chars_api.fk_lookup_type(element_id) <> 2);
END normalized;


FUNCTION derived (element_id IN NUMBER)
    RETURN VARCHAR2 IS
BEGIN
    IF (keyflex(element_id) OR normalized(element_id)) THEN
        RETURN 'Y';
    ELSE
       RETURN 'F';
    END IF;
END derived;


FUNCTION primitive (element_id IN NUMBER)
    RETURN BOOLEAN IS
BEGIN
    RETURN (qa_chars_api.hardcoded_column(element_id) IS NOT NULL)
        AND NOT (normalized(element_id));
END primitive;


FUNCTION hardcoded (element_id IN NUMBER)
    RETURN BOOLEAN IS

BEGIN

    RETURN qa_chars_api.hardcoded_column(element_id) IS NOT NULL;

END hardcoded;


FUNCTION get_element_datatype (element_id IN NUMBER)
    RETURN NUMBER  IS

BEGIN

    RETURN qa_chars_api.datatype(element_id);

END get_element_datatype;


-- BUG 3303285
-- ksoh Mon Dec 29 13:33:02 PST 2003
-- this version of get_spec_limits is left for backward compatibility only.
-- please use the get_spec_limits that takes in plan_id
-- and performs uom conversion when necessary.
PROCEDURE get_spec_limits (spec_id IN NUMBER, element_id IN NUMBER,
    lower_limit OUT NOCOPY VARCHAR2, upper_limit OUT NOCOPY VARCHAR2) IS

BEGIN

    IF element_in_spec(spec_id, element_id) THEN
        lower_limit := qsc_lower_reasonable_limit(spec_id, element_id);
        upper_limit := qsc_upper_reasonable_limit(spec_id, element_id);
    ELSE
        -- Bug 3692326
        -- shkalyan Tue Jun 22 2004
        -- If spec_id is present but, element is not in spec, then,
        -- element spec should not be used.
        IF ( NVL(spec_id, 0) <= 0 ) THEN
          lower_limit := qa_chars_api.lower_reasonable_limit(element_id);
          upper_limit := qa_chars_api.upper_reasonable_limit(element_id);
        ELSE
          lower_limit := NULL;
          upper_limit := NULL;
        END IF;
    END IF;

END get_spec_limits;


-- BUG 3303285
-- ksoh Mon Dec 29 13:33:02 PST 2003
-- overloaded get_spec_limits with a version that takes in plan_id
-- it is used for retrieving qa_plan_chars.uom_code for uom conversion
PROCEDURE get_spec_limits (p_plan_id IN NUMBER, p_spec_id IN NUMBER,
    p_element_id IN NUMBER,
    lower_limit OUT NOCOPY VARCHAR2, upper_limit OUT NOCOPY VARCHAR2) IS

    CURSOR c IS
        select uom_code
        from qa_spec_chars
        where spec_id = p_spec_id
        and char_id = p_element_id;

    -- 12.1 QWB Usabiltiy Improvements
    -- Cursor to read the UOM defined on element Level
    --
    Cursor char_uom is
        select uom_code
        from qa_chars
        where char_id = p_element_id;


    l_plan_char_uom qa_plan_chars.uom_code%TYPE;
    l_spec_char_uom qa_spec_chars.uom_code%TYPE;
    l_decimal_precision NUMBER;
BEGIN
    l_plan_char_uom := get_uom_code(p_plan_id, p_element_id);
    l_decimal_precision := get_decimal_precision(p_plan_id, p_element_id);

    IF element_in_spec(p_spec_id, p_element_id) THEN
        lower_limit := qsc_lower_reasonable_limit(p_spec_id, p_element_id);
        upper_limit := qsc_upper_reasonable_limit(p_spec_id, p_element_id);

		-- find out spec element UOM and perform conversion
		-- if they are different
		-- NOTE that no conversion will be performed if one of them is null
        OPEN c;
        FETCH c INTO l_spec_char_uom;
        CLOSE C;
        IF l_plan_char_uom <> l_spec_char_uom THEN
            IF (lower_limit IS NOT NULL) THEN
                lower_limit := INV_CONVERT.INV_UM_CONVERT(null,
                                             l_decimal_precision,
                                             lower_limit,
                                             l_spec_char_uom,
                                             l_plan_char_uom,
                                             null,
                                             null);
            END IF;
            IF (upper_limit IS NOT NULL) THEN
                upper_limit := INV_CONVERT.INV_UM_CONVERT(null,
                                             l_decimal_precision,
                                             upper_limit,
                                             l_spec_char_uom,
                                             l_plan_char_uom,
                                             null,
                                             null);
            END IF;
	        IF ((lower_limit = -99999) OR (upper_limit = -99999)) THEN
                fnd_message.set_name('QA', 'QA_INCONVERTIBLE_UOM');
                fnd_message.set_token('ENTITY1', l_spec_char_uom);
                fnd_message.set_token('ENTITY2', l_plan_char_uom);
	            fnd_msg_pub.add();
	        END IF;
        END IF;
    ELSE
        -- Bug 3692326
        -- shkalyan Tue Jun 22 2004
        -- If spec_id is present but, element is not in spec, then,
        -- element spec should not be used.

        -- Spec id is NULL
        IF ( NVL(p_spec_id, 0) <= 0 ) THEN

          -- 12.1 QWB Usability Improvements
          -- If the spec_id is NULL then we would the cursor and read the
          -- UOM defined on the char level. Then fetch the lower and the
          -- upper limits and perform the UOM conversion in case the UOM
          -- defined for that element on the plan level is different from
          -- that defined on the element level.
          --
          OPEN char_uom;
          FETCH char_uom into l_spec_char_uom;
          CLOSE char_uom;

          -- Get the spec limits defined on the elemnt level
          lower_limit := qa_chars_api.lower_reasonable_limit(p_element_id);
          upper_limit := qa_chars_api.upper_reasonable_limit(p_element_id);

          -- Check if the UOM on the plan level is different that that on the
          -- element level in which case perform the conversion
          IF l_plan_char_uom <> l_spec_char_uom THEN
            -- perform UOM conversion for the lower spec limit
            IF (lower_limit IS NOT NULL) THEN
                lower_limit := INV_CONVERT.INV_UM_CONVERT(null,
                                             l_decimal_precision,
                                             lower_limit,
                                             l_spec_char_uom,
                                             l_plan_char_uom,
                                             null,
                                             null);
            END IF;
            -- perform UOM conversion for the upper spec limit
            IF (upper_limit IS NOT NULL) THEN
                upper_limit := INV_CONVERT.INV_UM_CONVERT(null,
                                             l_decimal_precision,
                                             upper_limit,
                                             l_spec_char_uom,
                                             l_plan_char_uom,
                                             null,
                                             null);
            END IF;
                IF ((lower_limit = -99999) OR (upper_limit = -99999)) THEN
                fnd_message.set_name('QA', 'QA_INCONVERTIBLE_UOM');
                fnd_message.set_token('ENTITY1', l_spec_char_uom);
                fnd_message.set_token('ENTITY2', l_plan_char_uom);
                    fnd_msg_pub.add();
                END IF;
          END IF;
        ELSE
          lower_limit := NULL;
          upper_limit := NULL;
        END IF;
    END IF;

END get_spec_limits;


-- BUG 3303285
-- ksoh Mon Jan  5 12:55:13 PST 2004
-- it is used for retrieving low/high value for evaluation of action triggers
-- it performs UOM conversion.
-- NOTE: p_spec_id can be 0 if not in use
PROCEDURE get_low_high_values (p_plan_id IN NUMBER, p_spec_id IN NUMBER,
    p_element_id IN NUMBER,
    p_low_value_lookup IN NUMBER,
    p_high_value_lookup IN NUMBER,
    x_low_value OUT NOCOPY VARCHAR2, x_high_value OUT NOCOPY VARCHAR2) IS

    CURSOR c IS
        SELECT
	  decode(p_spec_id,0,
	       decode(p_low_value_lookup,
		7,qc.lower_reasonable_limit,
		6,qc.lower_spec_limit,
		5,qc.lower_user_defined_limit,
		4,qc.target_value,
		3,qc.upper_user_defined_limit,
		2,qc.upper_spec_limit,
		1,qc.upper_reasonable_limit,
		NULL),
	       decode(p_low_value_lookup,
		7,QscQs.lower_reasonable_limit,
		6,QscQs.lower_spec_limit,
		5,QscQs.lower_user_defined_limit,
		4,QscQs.target_value,
		3,QscQs.upper_user_defined_limit,
		2,QscQs.upper_spec_limit,
		1,QscQs.upper_reasonable_limit,
		NULL)) LOW_VALUE,
	  decode(p_spec_id,0,
	       decode(p_high_value_lookup,
		7,qc.lower_reasonable_limit,
		6,qc.lower_spec_limit,
		5,qc.lower_user_defined_limit,
		4,qc.target_value,
		3,qc.upper_user_defined_limit,
		2,qc.upper_spec_limit,
		1,qc.upper_reasonable_limit,
		NULL),
	       decode(p_high_value_lookup,
		7,QscQs.lower_reasonable_limit,
		6,QscQs.lower_spec_limit,
		5,QscQs.lower_user_defined_limit,
		4,QscQs.target_value,
		3,QscQs.upper_user_defined_limit,
		2,QscQs.upper_spec_limit,
		1,QscQs.upper_reasonable_limit,
		NULL)) HIGH_VALUE,
	    nvl(QscQs.uom_code, qc.uom_code) SPEC_CHAR_UOM,
	    nvl(qpc.uom_code, qc.uom_code) PLAN_CHAR_UOM,
        nvl(qpc.decimal_precision, qc.decimal_precision) DECIMAL_PRECISION
FROM
qa_chars qc,
qa_plan_chars qpc,
(select
 qsc.CHAR_ID,
 qsc.ENABLED_FLAG,
 qsc.TARGET_VALUE,
 qsc.UPPER_SPEC_LIMIT,
 qsc.LOWER_SPEC_LIMIT,
 qsc.UPPER_REASONABLE_LIMIT,
 qsc.LOWER_REASONABLE_LIMIT,
 qsc.UPPER_USER_DEFINED_LIMIT,
 qsc.LOWER_USER_DEFINED_LIMIT,
 qsc.UOM_CODE

 from
 qa_spec_chars qsc,
 qa_specs qs

 where
 qsc.spec_id = qs.common_spec_id and
 qs.spec_id = p_spec_id) QscQs

WHERE
qpc.plan_id = p_plan_id AND
qpc.enabled_flag = 1 AND
qc.char_id = qpc.char_id AND
qc.char_id = QscQs.char_id (+) AND
qpc.char_id = p_element_id;

    l_plan_char_uom qa_plan_chars.uom_code%TYPE;
    l_spec_char_uom qa_spec_chars.uom_code%TYPE;
    l_decimal_precision NUMBER;

BEGIN
    OPEN c;
    FETCH c INTO        x_low_value,
                        x_high_value,
                        l_spec_char_uom,
                        l_plan_char_uom,
                        l_decimal_precision;
    CLOSE c;
    IF (p_spec_id <> 0) AND
        (l_plan_char_uom <> l_spec_char_uom) THEN
        IF (x_low_value IS NOT NULL) THEN
            x_low_value := INV_CONVERT.INV_UM_CONVERT(null,
                                             l_decimal_precision,
                                             x_low_value,
                                             l_spec_char_uom,
                                             l_plan_char_uom,
                                             null,
                                             null);
        END IF;
        IF (x_high_value IS NOT NULL) THEN
            x_high_value := INV_CONVERT.INV_UM_CONVERT(null,
                                             l_decimal_precision,
                                             x_high_value,
                                             l_spec_char_uom,
                                             l_plan_char_uom,
                                             null,
                                             null);
        END IF;
	    IF ((x_low_value = -99999) OR (x_high_value = -99999)) THEN
            fnd_message.set_name('QA', 'QA_INCONVERTIBLE_UOM');
            fnd_message.set_token('ENTITY1', l_spec_char_uom);
            fnd_message.set_token('ENTITY2', l_plan_char_uom);
	        fnd_msg_pub.add();
	    END IF;
    END IF;
END get_low_high_values;


FUNCTION values_exist (plan_id IN NUMBER, element_id IN NUMBER)
    RETURN BOOLEAN IS

BEGIN

    RETURN qpc_values_exist_flag(plan_id, element_id) = 1;

END values_exist;


FUNCTION sql_validation_exists (element_id IN NUMBER)
    RETURN BOOLEAN IS

BEGIN

    RETURN qa_chars_api.sql_validation_string(element_id) IS NOT NULL;

END sql_validation_exists;


FUNCTION element_in_plan (plan_id IN NUMBER, element_id IN NUMBER)
    RETURN BOOLEAN IS

BEGIN

    fetch_qa_plan_chars(plan_id, element_id);
    RETURN exists_qa_plan_chars(plan_id, element_id);

END element_in_plan;


FUNCTION element_in_spec (spec_id IN NUMBER, element_id IN NUMBER)
    RETURN BOOLEAN IS

BEGIN

    fetch_qa_spec_chars(spec_id, element_id);
    RETURN exists_qa_spec_chars(spec_id, element_id);

END element_in_spec;


FUNCTION get_actual_datatype (element_id IN NUMBER)
    RETURN NUMBER IS

BEGIN

    IF NOT hardcoded(element_id) THEN
        RETURN qa_ss_const.character_datatype;

    ELSIF NOT primitive(element_id) THEN
        RETURN qa_ss_const.number_datatype;

    ELSE
        RETURN qa_chars_api.datatype(element_id);

    END IF;

END get_actual_datatype;



FUNCTION get_department_id (org_id IN NUMBER, value IN VARCHAR2)
      RETURN NUMBER IS

    id  NUMBER;

    CURSOR c (d_code VARCHAR2, o_id NUMBER) IS
        SELECT department_id
        FROM bom_departments_val_v
        WHERE department_code = d_code
        AND organization_id = o_id;

BEGIN

    IF value IS NULL THEN
        RETURN NULL;
    END IF;

    OPEN c(value, org_id);
    FETCH c INTO id;
    CLOSE c;

    RETURN id;

END get_department_id;


FUNCTION get_job_id (org_id IN NUMBER, value IN VARCHAR2)
    RETURN NUMBER IS

    id          NUMBER;

 -- #2382432
 -- Changed the view to WIP_DISCRETE_JOBS_ALL_V instead of
 -- earlier wip_open_discrete_jobs_val_v
 -- rkunchal Sun Jun 30 22:59:11 PDT 2002

    CURSOR c (w_e_name VARCHAR2, o_id NUMBER) IS
        SELECT wip_entity_id
        FROM wip_discrete_jobs_all_v
        WHERE wip_entity_name = w_e_name
        AND organization_id = o_id;

BEGIN

    IF value IS NULL THEN
        RETURN NULL;
    END IF;

    OPEN c(value, org_id);
    FETCH c INTO id;
    CLOSE c;

    RETURN id;

END get_job_id;


FUNCTION get_production_line_id (org_id IN NUMBER, value IN VARCHAR2)
    RETURN NUMBER IS

    id          NUMBER;

    CURSOR c (w_e_name VARCHAR2, o_id NUMBER) IS
        SELECT line_id
        FROM wip_lines_val_v
        WHERE line_code = w_e_name
        AND organization_id = o_id;

BEGIN

    IF value IS NULL THEN
        RETURN NULL;
    END IF;

    OPEN c(value, org_id);
    FETCH c INTO id;
    CLOSE c;

    RETURN id;

END get_production_line_id;


FUNCTION get_resource_code_id (org_id IN NUMBER, value IN VARCHAR2)
    RETURN NUMBER IS

    id          NUMBER;

    CURSOR c (r_code VARCHAR2, o_id NUMBER) IS
        SELECT resource_id
        FROM bom_resources_val_v
        WHERE resource_code = r_code
        AND organization_id = o_id;

BEGIN

    IF value IS NULL THEN
        RETURN NULL;
    END IF;

    OPEN c(value, org_id);
    FETCH c INTO id;
    CLOSE c;

    RETURN id;

END get_resource_code_id;


FUNCTION get_supplier_id (value IN VARCHAR2)
    RETURN NUMBER IS

    id          NUMBER;

    CURSOR c (v_name VARCHAR2) IS
        SELECT vendor_id
        FROM po_vendors
        WHERE vendor_name = v_name
        AND nvl(end_date_active, sysdate + 1) > sysdate;

BEGIN

    IF value IS NULL THEN
        RETURN NULL;
    END IF;

    OPEN c(value);
    FETCH c INTO id;
    CLOSE c;

    RETURN id;

END get_supplier_id;


FUNCTION get_po_number_id (value IN VARCHAR2)
    RETURN NUMBER IS

--
-- R12 Project MOAC 4637896
-- This function used to be invoked by mobile quality
-- to derive po_header_id for use by some PO-related
-- dependent elements, such as PO Line.  After MOAC
-- update, mobile will pass po_header_id directly to
-- those dependent element LOVs, so this function is
-- no longer in use.
--
-- The dependent elements are PO Line Number and
-- PO Shipment Number
--
-- bso Sat Oct  8 12:20:50 PDT 2005
--
    id          NUMBER;

    -- Bug 4958763. SQL Repository Fix SQL ID: 15008272
    -- Reverting back the changes for functionality
    CURSOR c (s VARCHAR2) IS
        SELECT po_header_id
        FROM PO_POS_VAL_TRX_V
        WHERE segment1 = s;

BEGIN

    IF value IS NULL THEN
        RETURN NULL;
    END IF;

    OPEN c(value);
    FETCH c INTO id;
    CLOSE c;

    RETURN id;

END get_po_number_id;


FUNCTION get_customer_id (value IN VARCHAR2)
    RETURN NUMBER IS

    id          NUMBER;

    CURSOR c (c_name VARCHAR2) IS
        SELECT customer_id
        FROM qa_customers_lov_v
        WHERE status = 'A'
        AND customer_name = c_name
        AND nvl(customer_prospect_code, 'CUSTOMER') = 'CUSTOMER';

BEGIN

    IF value IS NULL THEN
        RETURN NULL;
    END IF;

    OPEN c(value);
    FETCH c INTO id;
    CLOSE c;

    RETURN id;

END get_customer_id;


FUNCTION get_so_number_id (value IN VARCHAR2)
    RETURN NUMBER IS

    id          NUMBER;

    -- Bug 4958763.  SQL Repository Fix SQL ID: 15008330
    -- reverting back the changes for functionality
    CURSOR c (v VARCHAR2) IS
        SELECT sales_order_id header_id
        FROM   qa_sales_orders_lov_v
        WHERE  order_number = v;

BEGIN

    IF value IS NULL THEN
        RETURN NULL;
    END IF;

    OPEN c(value);
    FETCH c INTO id;
    CLOSE c;

    RETURN id;

END get_so_number_id;


FUNCTION get_so_line_number_id (value IN VARCHAR2)
    RETURN NUMBER IS

    id          NUMBER;

    CURSOR c (h_id IN VARCHAR2) IS
        SELECT sl.line_number
        FROM mtl_system_items_kfv msik, so_lines sl
        WHERE sl.inventory_item_id = msik.inventory_item_id
        AND header_id = h_id;

BEGIN

    IF value IS NULL THEN
        RETURN NULL;
    END IF;

    OPEN c(value);
    FETCH c INTO id;
    CLOSE c;

    RETURN id;

END get_so_line_number_id;


FUNCTION get_po_release_number_id (value IN VARCHAR2, x_po_header_id IN NUMBER)
    RETURN NUMBER IS

    id          NUMBER;

    CURSOR c (p_id NUMBER, r_num VARCHAR2) IS
        SELECT pr.po_release_id
        FROM po_releases pr
        WHERE pr.po_header_id = p_id
        AND pr.release_num = r_num;

BEGIN

    IF value IS NULL THEN
        RETURN NULL;
    END IF;

    OPEN c(x_po_header_id, value);
    FETCH c INTO id;
    CLOSE c;

    RETURN id;

END get_po_release_number_id;


FUNCTION get_project_number_id (value IN VARCHAR2)
    RETURN NUMBER IS

    id          NUMBER;
/*
mtl_project_v changed to pjm_projects_all_v (selects from both pjm enabled and
non-pjm enabled orgs).
rkaza, 11/10/2001.
*/

--
-- the sql has to be changed as pjm_projects_all_v is operating unit sensitive.
-- has to change to a sql that searching all operating units.
-- reference bug 3578563
-- jezheng
-- Mon Apr 19 12:20:16 PDT 2004
--
/*    CURSOR c (p_num VARCHAR2) IS
        SELECT project_id
        FROM pjm_projects_all_v
        WHERE project_number = p_num;
*/

    cursor c (p_proj_num varchar2) is
       select project_id
       from   pa_projects_all
       where  segment1 = p_proj_num
       UNION ALL
       select project_id
       from   pjm_seiban_numbers
       where  project_number = p_proj_num;

BEGIN

    IF value IS NULL THEN
        RETURN NULL;
    END IF;

    OPEN c(value);
    FETCH c INTO id;
    CLOSE c;

    RETURN id;

END get_project_number_id;


--
-- Bug 2672396.  Added p_project_id because task is a dependent element.
-- Fix is required in qltvalb.plb also.
-- bso Mon Nov 25 17:29:56 PST 2002
--
FUNCTION get_task_number_id(value IN VARCHAR2, p_project_id IN NUMBER)
    RETURN NUMBER IS

    id          NUMBER;

--
-- The sql is operating unit sensitive. Has to be changed to a sql
-- that searches all operating units.
-- reference bug 3578563
-- jezheng
--  Mon Apr 19 12:25:23 PDT 2004
--

/*    CURSOR c (p_task_number VARCHAR2, p_project_id NUMBER) IS
        SELECT task_id
        FROM mtl_task_v
        WHERE task_number = p_task_number AND project_id = p_project_id;
*/

    cursor c (p_task_num varchar2, p_proj_id number) is
        select TASK_ID
        from pa_tasks
        where PROJECT_ID = p_proj_id and
        task_number = p_task_num;

BEGIN

    IF value IS NULL THEN
        RETURN NULL;
    END IF;

    OPEN c(value, p_project_id);
    FETCH c INTO id;
    CLOSE c;

    RETURN id;

END get_task_number_id;


FUNCTION get_rma_number_id (value IN VARCHAR2)
    RETURN NUMBER IS

    id          NUMBER;

    CURSOR C(v VARCHAR2) IS
        SELECT sh.header_id
        FROM   so_order_types sot,
               oe_order_headers sh,
               qa_customers_lov_v rc
        WHERE  sh.order_type_id = sot.order_type_id and
               sh.sold_to_org_id = rc.customer_id and
               sh.order_category_code in ('RETURN', 'MIXED') and
               sh.order_number = v;

BEGIN

    IF value IS NULL THEN
        RETURN NULL;
    END IF;

    OPEN c(value);
    FETCH c INTO id;
    CLOSE c;

    RETURN id;

END get_rma_number_id;

FUNCTION get_LPN_id (value IN VARCHAR2)
    RETURN NUMBER IS

    id          NUMBER;

    CURSOR c (t_id VARCHAR2) IS
        SELECT LPN_ID
        FROM WMS_LICENSE_PLATE_NUMBERS
        WHERE LICENSE_PLATE_NUMBER = t_id;

BEGIN

    IF value IS NULL THEN
        RETURN NULL;
    END IF;

    OPEN c(value);
    FETCH c INTO id;
    CLOSE c;

    RETURN id;

END get_LPN_id;

-- added the following to include new hardcoded element Transfer license plate number
-- saugupta Aug 2003

FUNCTION get_XFR_LPN_id (value IN VARCHAR2)
    RETURN NUMBER IS

    id          NUMBER;

    CURSOR c (t_id VARCHAR2) IS
        SELECT LPN_ID
        FROM WMS_LICENSE_PLATE_NUMBERS
        WHERE LICENSE_PLATE_NUMBER = t_id;

BEGIN

    IF value IS NULL THEN
        RETURN NULL;
    END IF;

    OPEN c(value);
    FETCH c INTO id;
    CLOSE c;

    RETURN id;

END get_XFR_LPN_id;

FUNCTION get_contract_id (value IN VARCHAR2)
RETURN NUMBER IS

id NUMBER := NULL;

CURSOR c (val VARCHAR2) IS
    SELECT k_header_id
    FROM oke_k_headers_lov_v
    WHERE k_number = val;

BEGIN

        IF value is NOT NULL THEN
                OPEN c(value);
                FETCH c INTO id;
                CLOSE c;
        END IF;

    RETURN id;

END get_contract_id;

FUNCTION get_contract_line_id (value IN VARCHAR2)
RETURN NUMBER IS

id NUMBER := NULL;

CURSOR c (val VARCHAR2) IS
    SELECT k_line_id
    FROM oke_k_lines_full_v
    WHERE line_number = val;

BEGIN

    IF value is NOT NULL THEN
        OPEN c(value);
        FETCH c INTO id;
        CLOSE c;
    END IF;

    RETURN id;

END get_contract_line_id;

FUNCTION get_deliverable_id (value IN VARCHAR2)
RETURN NUMBER IS

id NUMBER := NULL;

CURSOR c (val VARCHAR2) IS
    SELECT deliverable_id
    FROM oke_k_deliverables_vl
    WHERE deliverable_num = val;

BEGIN

    IF value is NOT NULL THEN
        OPEN c(value);
        FETCH c INTO id;
        CLOSE c;
    END IF;

    RETURN id;

END get_deliverable_id;



FUNCTION get_work_order_id (org_id IN NUMBER, value IN VARCHAR2)
    RETURN NUMBER IS

    id          NUMBER;

/* rkaza 10/21/2002. Bug 2635736 */
    CURSOR c (w_e_name VARCHAR2, o_id NUMBER) IS
        SELECT WDJ.wip_entity_id
        FROM wip_entities WE, wip_discrete_jobs WDJ
        WHERE WDJ.status_type in (3,4) and
              WDJ.wip_entity_id = WE.wip_entity_id and
              WE.entity_type IN (6, 7) and
              WE.wip_entity_name = w_e_name
              AND WDJ.organization_id = o_id;

BEGIN

    IF value IS NULL THEN
        RETURN NULL;
    END IF;

    OPEN c(value, org_id);
    FETCH c INTO id;
    CLOSE c;

    RETURN id;

END get_work_order_id;



FUNCTION get_party_id (value IN VARCHAR2)
    RETURN NUMBER IS

    id          NUMBER;

    CURSOR c (p_name VARCHAR2) IS
        SELECT party_id
        FROM hz_parties
        WHERE status = 'A'
        AND party_name = p_name
        AND party_type IN ('ORGANIZATION','PERSON')
        ORDER BY party_name;

BEGIN

    IF value IS NULL THEN
        RETURN NULL;
    END IF;

    OPEN c(value);
    FETCH c INTO id;
    CLOSE c;

    RETURN id;

END get_party_id;

--
-- Implemented the following get_id functions for
-- Service_Item, Counter, Maintenance_Requirement,
-- Service_Request, Rework_Job
-- For ASO project
-- rkunchal Thu Jul 25 01:43:48 PDT 2002
--

FUNCTION get_item_instance_id (value IN VARCHAR2)
    RETURN NUMBER IS

    id          NUMBER;

    CURSOR c (i_num VARCHAR2) IS
        SELECT cii.instance_id
        FROM qa_csi_item_instances cii, mtl_system_items_kfv msik
        WHERE cii.instance_number = i_num
        AND cii.last_vld_organization_id = msik.organization_id;

BEGIN

    IF value IS NULL THEN
        RETURN NULL;
    END IF;

    OPEN c(value);
    FETCH c INTO id;
    CLOSE c;

    RETURN id;

END get_item_instance_id;


FUNCTION get_counter_name_id (value IN VARCHAR2)
    RETURN NUMBER IS

    id          NUMBER;
    -- Bug 4958763. SQL Repository Fix SQL ID: 15008597
    -- to maintain consistency using IB view for counters
    -- replacing cs_counters with csi_counters_vl
    CURSOR c (c_name VARCHAR2) IS
        SELECT cc.counter_id
         FROM csi_counters_vl cc
         WHERE cc.name = c_name;
/*
        SELECT cc.counter_id
        FROM cs_counters cc, cs_counter_groups ccg
        WHERE cc.counter_group_id = ccg.counter_group_id
        AND ccg.template_flag = 'N'
        AND cc.name = c_name;
*/

BEGIN

    IF value IS NULL THEN
        RETURN NULL;
    END IF;

    OPEN c(value);
    FETCH c INTO id;
    CLOSE c;

    RETURN id;

END get_counter_name_id;


FUNCTION get_maintenance_req_id (value IN VARCHAR2)
    RETURN NUMBER IS

    id          NUMBER;

    CURSOR c (mr_title VARCHAR2) IS
        SELECT mr_header_id
        FROM qa_ahl_mr
        WHERE title = mr_title;

BEGIN

    IF value IS NULL THEN
        RETURN NULL;
    END IF;

    OPEN c(value);
    FETCH c INTO id;
    CLOSE c;

    RETURN id;

END get_maintenance_req_id;


FUNCTION get_service_request_id (value IN VARCHAR2)
    RETURN NUMBER IS

    id          NUMBER;

    CURSOR c (s_request VARCHAR2) IS
        SELECT incident_id
        FROM cs_incidents
        WHERE incident_number = s_request;

BEGIN

    IF value IS NULL THEN
        RETURN NULL;
    END IF;

    OPEN c(value);
    FETCH c INTO id;
    CLOSE c;

    RETURN id;

END get_service_request_id;


FUNCTION get_rework_job_id (org_id IN NUMBER, value IN VARCHAR2)
    RETURN NUMBER IS

    id          NUMBER;

    CURSOR c (w_e_name VARCHAR2, o_id NUMBER) IS
        SELECT wip_entity_id
        FROM wip_discrete_jobs_all_v
        WHERE wip_entity_name = w_e_name
        AND organization_id = o_id;

BEGIN

    IF value IS NULL THEN
        RETURN NULL;
    END IF;

    OPEN c(value, org_id);
    FETCH c INTO id;
    CLOSE c;

    RETURN id;

END get_rework_job_id;

--
-- End of inclusions for ASO project
-- rkunchal Thu Jul 25 01:43:48 PDT 2002
--
-- R12 OPM Deviations. Bug 4345503 Start

FUNCTION get_process_batch_id (value IN VARCHAR2,p_org_id IN NUMBER)
    RETURN NUMBER IS
    id          NUMBER;
    CURSOR c (batch_num VARCHAR2,o_id NUMBER) IS
      SELECT BATCH_ID
      FROM GME_BATCH_HEADER
      WHERE BATCH_NO = batch_num
      AND ( ORGANIZATION_ID IS NULL OR
            ORGANIZATION_ID = o_id );
BEGIN
    IF value IS NULL THEN
      RETURN NULL;
    END IF;

    OPEN c(value,p_org_id);
    FETCH c INTO id;
    CLOSE c;

    RETURN id;
END get_process_batch_id;

FUNCTION get_process_batchstep_id (value IN VARCHAR2,
                                   p_process_batch_id IN NUMBER)
    RETURN NUMBER IS
    id      NUMBER;
    CURSOR c (l_batchstep_num VARCHAR2, l_batch_id NUMBER) is
      SELECT BATCHSTEP_ID
      FROM GME_BATCH_STEPS
      WHERE BATCHSTEP_NO = L_BATCHSTEP_NUM
      AND BATCH_ID = L_BATCH_ID;
BEGIN

    IF value IS NULL THEN
      RETURN NULL;
    END IF;

    OPEN c(value,p_process_batch_id);
    FETCH c INTO id;
    CLOSE c;

    RETURN id;

END get_process_batchstep_id;

FUNCTION get_process_operation_id (value IN VARCHAR2,
                                   p_process_batch_id IN NUMBER,
                                   p_process_batchstep_id IN NUMBER)
    RETURN NUMBER IS
    id      NUMBER;

    CURSOR c (l_operation VARCHAR2, l_batch_id NUMBER, l_batchstep_id VARCHAR2) is
      SELECT OPRN_ID
      FROM GMO_BATCH_STEPS_V
      WHERE OPERATION = L_OPERATION
      AND BATCH_ID = L_BATCH_ID
      AND BATCHSTEP_ID = L_BATCHSTEP_ID;
BEGIN
    IF value IS NULL THEN
      RETURN NULL;
    END IF;

    OPEN c(value,p_process_batch_id, p_process_batchstep_id);
    FETCH c INTO id;
    CLOSE c;

    RETURN id;

END get_process_operation_id;

FUNCTION get_process_activity_id (value IN VARCHAR2,
	                          p_process_batch_id IN NUMBER,
	                          p_process_batchstep_id IN NUMBER)
    RETURN NUMBER IS
    id      NUMBER;
    CURSOR c (l_activity VARCHAR2, l_batch_id NUMBER, l_batchstep_id NUMBER) is
      SELECT BATCHSTEP_ACTIVITY_ID
      FROM GME_BATCH_STEP_ACTIVITIES
      WHERE ACTIVITY = L_ACTIVITY
      AND BATCH_ID = L_BATCH_ID
      AND BATCHSTEP_ID = L_BATCHSTEP_ID ;
BEGIN
    IF value IS NULL THEN
      RETURN NULL;
    END IF;

    OPEN c(value,p_process_batch_id, p_process_batchstep_id);
    FETCH c INTO id;
    CLOSE c;

    RETURN id;

END get_process_activity_id;

FUNCTION get_process_resource_id (value IN VARCHAR2,
	                          p_process_batch_id IN NUMBER,
	                          p_process_batchstep_id IN NUMBER,
	                          p_process_activity_id IN NUMBER)
    RETURN NUMBER IS
    id      NUMBER;
    CURSOR c (l_resources VARCHAR2, l_batch_id NUMBER,
              l_batchstep_id NUMBER, l_activity_id NUMBER) is
      SELECT BATCHSTEP_RESOURCE_ID
      FROM GME_BATCH_STEP_RESOURCES
      WHERE RESOURCES = L_RESOURCES
      AND BATCH_ID = L_BATCH_ID
      AND BATCHSTEP_ID = L_BATCHSTEP_ID
      AND BATCHSTEP_ACTIVITY_ID = L_ACTIVITY_ID;
BEGIN
    IF value IS NULL THEN
      RETURN NULL;
    END IF;

    OPEN c(value,p_process_batch_id, p_process_batchstep_id,
           p_process_activity_id);
    FETCH c INTO id;
    CLOSE c;

    RETURN id;

END get_process_resource_id;

FUNCTION get_process_parameter_id (value IN VARCHAR2,
	                           p_process_resource_id IN NUMBER)
    RETURN NUMBER IS
    id      NUMBER;
    CURSOR c (l_parameter VARCHAR2, l_resource_id NUMBER) is
      SELECT GP.PARAMETER_ID
      FROM GMP_PROCESS_PARAMETERS GP, GME_PROCESS_PARAMETERS GE
      WHERE GP.PARAMETER_NAME = L_PARAMETER
      AND GP.PARAMETER_ID = GE.PARAMETER_ID
      AND GE.BATCHSTEP_RESOURCE_ID= L_RESOURCE_ID;
BEGIN
    IF value IS NULL THEN
      RETURN NULL;
    END IF;

    OPEN c(value,p_process_resource_id);
    FETCH c INTO id;
    CLOSE c;

    RETURN id;

END get_process_parameter_id;

-- R12 OPM Deviations. Bug 4345503 End

/* R12 DR Integration. Bug 4345489 Start */

FUNCTION get_repair_line_id (value IN VARCHAR2)
    RETURN NUMBER
    IS

    id          NUMBER;

    cursor c (p_ro_num varchar2) is
       select repair_line_id
       from   csd_repairs
       where  repair_number = p_ro_num;


BEGIN

    IF value IS NULL THEN
        RETURN NULL;
    END IF;

    OPEN c(value);
    FETCH c INTO id;
    CLOSE c;

    RETURN id;

END get_repair_line_id;


FUNCTION get_jtf_task_id (value IN VARCHAR2)
    RETURN NUMBER
    IS

id          NUMBER;

    cursor c (p_task_num varchar2) is
       select task_id
       from   jtf_tasks_b
       where  task_number = p_task_num;


BEGIN

    IF value IS NULL THEN
        RETURN NULL;
    END IF;

    OPEN c(value);
    FETCH c INTO id;
    CLOSE c;

    RETURN id;

END get_jtf_task_id;

/* R12 DR Integration. Bug 4345489 End */

-- Start of inclusions for NCM Hardcode Elements.
-- suramasw Thu Oct 31 10:48:59 PST 2002.
-- Bug 2449067.


FUNCTION validate_to_subinventory (x_org_id IN NUMBER, x_to_subinventory IN VARCHAR2)
    RETURN BOOLEAN IS

    CURSOR c IS
        SELECT 1
        FROM  mtl_secondary_inventories
        WHERE organization_id = x_org_id
        AND nvl(disable_date, sysdate+1) > sysdate
        AND  secondary_inventory_name = x_to_subinventory;

    result BOOLEAN;
    dummy NUMBER;

BEGIN

    OPEN c;
    FETCH c INTO dummy;
    result := c%FOUND;
    CLOSE c;

    RETURN result;

END validate_to_subinventory;

-- End of inclusions for NCM Hardcode Elements.

FUNCTION retrieve_id (sql_statement IN VARCHAR2)
    RETURN NUMBER IS

    retrieved_id        NUMBER;

BEGIN

   EXECUTE IMMEDIATE sql_statement
   INTO retrieved_id;

   RETURN retrieved_id;

   EXCEPTION  WHEN OTHERS THEN
        RAISE;

END retrieve_id;


FUNCTION value_in_sql (sql_statement IN VARCHAR2, value IN VARCHAR2)
    RETURN BOOLEAN IS

    indicator   NUMBER;
    new_sql_statement VARCHAR2(10000);

BEGIN


   new_sql_statement  := 'SELECT 1 FROM DUAL WHERE ' || '''' ||
       qa_core_pkg.dequote(value)  || '''';

   new_sql_statement  := new_sql_statement || ' IN ' || '(' ||
       sql_statement || ')';


   EXECUTE IMMEDIATE new_sql_statement
   INTO indicator;

   RETURN indicator = 1;

   EXCEPTION WHEN OTHERS THEN
       RETURN  FALSE;

END value_in_sql;


FUNCTION validate_transaction_date(transaction_number IN NUMBER)
    RETURN BOOLEAN IS

    result BOOLEAN DEFAULT TRUE;
    dummy NUMBER;

BEGIN


    IF (transaction_number = qa_ss_const.po_inspection_txn) THEN
        -- NEED FURTHER WORK:  need to validate transaction date
        -- in this specific case
        result := FALSE;
    END IF;

    RETURN result;

END validate_transaction_date;


FUNCTION validate_uom(x_org_id IN NUMBER, x_item_id IN NUMBER,
    x_uom_code IN VARCHAR2) RETURN BOOLEAN IS

    CURSOR c IS
        SELECT 1
        FROM   mtl_item_uoms_view
        WHERE  inventory_item_id = x_item_id AND
               organization_id = x_org_id AND
               uom_code = x_uom_code;

    result BOOLEAN;
    dummy NUMBER;

BEGIN

    OPEN c;
    FETCH c INTO dummy;
    result := c%FOUND;
    CLOSE c;

    RETURN result;

END validate_uom;


FUNCTION validate_revision (x_org_id IN NUMBER, x_item_id IN NUMBER,
    x_revision IN VARCHAR2)
    RETURN BOOLEAN IS

    CURSOR c IS
        SELECT 1
        FROM   mtl_item_revisions
        WHERE  inventory_item_id = x_item_id AND
               organization_id = x_org_id AND
               revision = x_revision;

    result BOOLEAN;
    dummy NUMBER;

BEGIN

    OPEN c;
    FETCH c INTO dummy;
    result := c%FOUND;
    CLOSE c;

    RETURN result;

END validate_revision;

FUNCTION validate_lot_num(x_org_id IN NUMBER, x_item_id IN NUMBER,
    x_lot_num IN VARCHAR2)
    RETURN BOOLEAN IS

    CURSOR c IS
        SELECT 1
        FROM   mtl_lot_numbers
        WHERE  inventory_item_id = x_item_id AND
               organization_id = x_org_id AND
               lot_number = x_lot_num;

    result BOOLEAN;
    dummy NUMBER;

BEGIN

    OPEN c;
    FETCH c INTO dummy;
    result := c%FOUND;
    CLOSE c;

    RETURN result;

END validate_lot_num;


FUNCTION validate_serial_num(x_org_id IN NUMBER, x_item_id IN NUMBER,
    x_lot_num IN VARCHAR2, x_revision IN VARCHAR2, x_serial_num IN VARCHAR2)
    RETURN BOOLEAN IS


    -- Bug 3364660. Changed the cursor sql to use the nvl() for revision
    -- and lot number columns. kabalakr.

    --
    -- Bug 3773298.  Relaxing the where conditions such that if
    -- input lot number is null, we allow for all serial numbers
    -- for that item to pass validation.  Same for revision.
    -- bso Tue Jul 20 15:20:37 PDT 2004
    --
    CURSOR c IS
        SELECT 1
        FROM   mtl_serial_numbers
        WHERE  inventory_item_id = x_item_id AND
               current_organization_id = x_org_id AND
               (x_lot_num IS NULL OR lot_number = x_lot_num) AND
               (x_revision IS NULL OR revision = x_revision) AND
               serial_number = x_serial_num;

    result BOOLEAN;
    dummy NUMBER;

BEGIN

    OPEN c;
    FETCH c INTO dummy;
    result := c%FOUND;
    CLOSE c;

    RETURN result;

END validate_serial_num;



FUNCTION validate_subinventory (x_org_id IN NUMBER, x_subinventory IN VARCHAR2)
    RETURN BOOLEAN IS


    -- Bug 3381173. The Subinventory specified for Mobile LPN inspection could
    -- either be a storage or receiving sub. Hence changed the sql to accomodate
    -- both types of sub.
    -- kabalakr Tue Jan 27 02:18:59 PST 2004.

    CURSOR c IS
        SELECT 1
        FROM  mtl_secondary_inventories
        WHERE organization_id = x_org_id
        AND ((((SUBINVENTORY_TYPE <> 2) OR (SUBINVENTORY_TYPE IS NULL))
                          AND nvl(disable_date, sysdate+1) > sysdate)
                          OR (SUBINVENTORY_TYPE = 2))
        AND  secondary_inventory_name = x_subinventory;

    result BOOLEAN;
    dummy NUMBER;

BEGIN

    OPEN c;
    FETCH c INTO dummy;
    result := c%FOUND;
    CLOSE c;

    RETURN result;

END validate_subinventory;


FUNCTION validate_lot_number (x_transaction_number IN NUMBER, x_transaction_id
    IN NUMBER, x_lot_number IN VARCHAR2)
    RETURN BOOLEAN IS

    CURSOR c IS
        SELECT 1
        FROM  mtl_transaction_lots_temp
        WHERE transaction_temp_id = x_transaction_id
        AND lot_number = x_lot_number;

    result BOOLEAN;
    dummy NUMBER;

BEGIN

    -- No validation done for direct data entry in which case
    -- the transaction number is going to be null

    IF (x_transaction_number is NULL) THEN
        RETURN TRUE;
    END IF;

    -- Only done for WIP Completion and Work Order Less Completions

    IF (x_transaction_number NOT IN( qa_ss_const.wip_completion_txn,
           qa_ss_const.flow_work_order_less_txn)) THEN
        RETURN TRUE;
    END IF;

    OPEN c;
    FETCH c INTO dummy;
    result := c%FOUND;
    CLOSE c;

    RETURN result;

END validate_lot_number;


FUNCTION validate_serial_number (x_transaction_number IN NUMBER,
    x_transaction_id IN NUMBER, x_lot_number IN VARCHAR2, x_serial_number IN
    VARCHAR2)
    RETURN BOOLEAN IS

    --
    -- Bug 3758145.  The original SQL is incorrect in transaction scenario.
    -- the WHERE conditions msn.line_mark_id should be rewritten as
    -- msn.lot_line_mark_id and vice versa.
    -- bso Tue Jul 20 15:52:21 PDT 2004
    --
    CURSOR c IS
        SELECT 1
        FROM  mtl_serial_numbers msn,
              mtl_transaction_lots_temp mtlt
        WHERE msn.lot_line_mark_id = x_transaction_id
        AND mtlt.transaction_temp_id = msn.lot_line_mark_id
        AND mtlt.serial_transaction_temp_id = msn.line_mark_id
        AND mtlt.lot_number = x_lot_number
        AND x_lot_number IS NOT NULL
        AND msn.serial_number = x_serial_number
        UNION ALL
        SELECT 1
        FROM mtl_serial_numbers msn
        WHERE msn.line_mark_id = x_transaction_id
        AND x_lot_number IS NULL
        AND msn.serial_number = x_serial_number;

    result BOOLEAN DEFAULT FALSE;
    dummy NUMBER;

BEGIN

    -- Only done for WIP Completion and Work Order Less Completions

    -- Bug 3364660. Return TRUE even if the x_transaction_number is NULL.
    -- kabalakr.

    IF (x_transaction_number NOT IN( qa_ss_const.wip_completion_txn,
           qa_ss_const.flow_work_order_less_txn))
       OR (x_transaction_number IS NULL) THEN

        RETURN TRUE;
    END IF;

    OPEN c;
    FETCH c INTO dummy;
    result := c%FOUND;
    CLOSE c;

    RETURN result;

END validate_serial_number;


FUNCTION validate_op_seq_number (x_org_id IN NUMBER, x_line_id IN NUMBER,
    x_wip_entity_id IN NUMBER, x_op_seq_number IN VARCHAR2)
    RETURN BOOLEAN IS

    CURSOR c1 IS
        SELECT 1
        FROM wip_operations_all_v
        WHERE organization_id = x_org_id
        AND wip_entity_id = x_wip_entity_id
        AND operation_seq_num = x_op_seq_number;

    CURSOR c2 IS
        SELECT 1
        FROM wip_operations_all_v
        WHERE organization_id = x_org_id
        AND wip_entity_id = x_wip_entity_id
        AND operation_seq_num = x_op_seq_number
        AND repetitive_schedule_id =
        (  SELECT repetitive_schedule_id
           FROM wip_first_open_schedule_v
           WHERE organization_id = x_org_id
           AND wip_entity_id = x_wip_entity_id
           AND line_id = x_line_id  );

    result BOOLEAN DEFAULT FALSE;
    dummy NUMBER;

BEGIN

    IF (x_line_id IS NULL) THEN

        OPEN c1;
        FETCH c1 INTO dummy;
        result := c1%FOUND;
        CLOSE c1;

    ELSE

        OPEN c2;
        FETCH c2 INTO dummy;
        result := c2%FOUND;
        CLOSE c2;

    END IF;
    RETURN result;

END validate_op_seq_number;

--
-- See Bug 2588213
-- To support the element Maintenance Op Seq Number
-- to be used along with Maintenance Workorder
-- rkunchal Mon Sep 23 23:46:28 PDT 2002
--
FUNCTION validate_maintenance_op_seq (x_org_id IN NUMBER,
                                      x_maintenance_work_order_id IN NUMBER,
                                      x_maintenance_op_seq IN VARCHAR2)
RETURN BOOLEAN IS

    CURSOR c IS
        SELECT 1
        FROM wip_operations_all_v
        WHERE organization_id = x_org_id
        AND wip_entity_id = x_maintenance_work_order_id
        AND operation_seq_num = x_maintenance_op_seq;

    result BOOLEAN DEFAULT FALSE;
    dummy  NUMBER;

BEGIN

   OPEN c;
   FETCH c INTO dummy;
   result := c%FOUND;
   CLOSE c;

   RETURN result;

END validate_maintenance_op_seq;

--
-- End of inclusions for Bug 2588213
--

FUNCTION validate_po_line_number (x_po_header_id IN NUMBER, x_po_line_number
    IN VARCHAR2)
    RETURN BOOLEAN IS

    CURSOR c IS
        SELECT 1
        FROM   PO_LINES_VAL_TRX_V
        WHERE po_header_id = x_po_header_id
        AND  line_num = x_po_line_number;

    result BOOLEAN;
    dummy NUMBER;

BEGIN

    OPEN c;
    FETCH c INTO dummy;
    result := c%FOUND;
    CLOSE c;

    RETURN result;

END validate_po_line_number;

--
-- bug 9652549 CLM changes
--
FUNCTION validate_po_shipments (x_po_line_num IN VARCHAR2, x_po_header_id IN
    NUMBER, x_po_shipments IN VARCHAR2)
    RETURN BOOLEAN IS

    --
    -- bug 9652549 CLM changes
    --
    -- Bug 4958763. SQL Repository Fix SQL ID: 15008958
    CURSOR c IS
        SELECT 1
        FROM po_line_locations
        WHERE po_line_id =
              ( SELECT po_line_id
                FROM PO_LINES_TRX_V
                WHERE line_num = x_po_line_num
                AND po_header_id =  x_po_header_id)
        AND shipment_num = x_po_shipments;
/*
        SELECT 1
        FROM  po_shipments_all_v
        WHERE po_line_id =
            (SELECT po_line_id
             FROM po_lines_val_v
             WHERE line_num = x_po_line_num
             AND po_header_id = x_po_header_id)
        AND shipment_num = x_po_shipments;
*/

    result BOOLEAN;
    dummy NUMBER;

BEGIN

    OPEN c;
    FETCH c INTO dummy;
    result := c%FOUND;
    CLOSE c;

    RETURN result;

END validate_po_shipments;


FUNCTION validate_receipt_number (x_receipt_number IN VARCHAR2)
    RETURN BOOLEAN IS

/*    -- Bug 4958763. SQL Repository Fix SQL ID: 15008972
    CURSOR c IS
        SELECT 1
        FROM RCV_SHIPMENT_HEADERS
        WHERE receipt_num = x_receipt_number
        AND RECEIPT_SOURCE_CODE = 'VENDOR';
*/
    --
    -- Bug 7491455.FP For bug 6800960.
    -- changed the query for validationg receipt number to include RMA receipts
    -- pdube Fri Oct 17 00:14:28 PDT 2008
    CURSOR c IS
        SELECT 1
        FROM  RCV_SHIPMENT_HEADERS RCVSH,
              PO_VENDORS POV,
              RCV_TRANSACTIONS RT
        WHERE RCVSH.RECEIPT_SOURCE_CODE in ('VENDOR','CUSTOMER') AND
              RCVSH.VENDOR_ID = POV.VENDOR_ID(+) AND
              RT.SHIPMENT_HEADER_ID = RCVSH.SHIPMENT_HEADER_ID AND
              receipt_num = x_receipt_number;
/*
        SELECT 1
        FROM rcv_receipts_all_v
        WHERE receipt_num = x_receipt_number;
*/

    result BOOLEAN;
    dummy NUMBER;

BEGIN

    OPEN c;
    FETCH c INTO dummy;
    result := c%FOUND;
    CLOSE c;

    RETURN result;

END validate_receipt_number;


FUNCTION get_target_element (plan_char_action_id IN NUMBER)
    RETURN NUMBER IS

    target_element NUMBER;

    CURSOR c1 (pca_id NUMBER) IS
        SELECT assigned_char_id
        FROM qa_plan_char_actions
        WHERE plan_char_action_id = pca_id;

BEGIN

    OPEN c1(plan_char_action_id);
    FETCH c1 INTO target_element;
    CLOSE c1;

    RETURN target_element;

    EXCEPTION WHEN OTHERS THEN
        RAISE;

END get_target_element;


FUNCTION get_enabled_flag (plan_id IN NUMBER, element_id IN NUMBER)
    RETURN NUMBER IS
BEGIN
    RETURN qpc_enabled_flag(plan_id, element_id);
END get_enabled_flag;

--
-- See Bug 2624112
-- The decimal precision for a number type collection
-- element is to be configured at plan level.
-- rkunchal Wed Oct 16 05:32:33 PDT 2002
--
-- New function to get the decimal precision for the element
-- from the QA_PLAN_CHARS table.
--

FUNCTION decimal_precision (p_plan_id IN NUMBER, p_element_id IN NUMBER)
    RETURN NUMBER IS
BEGIN
    RETURN qpc_decimal_precision(p_plan_id, p_element_id);
END decimal_precision;

FUNCTION get_mandatory_flag (plan_id IN NUMBER, element_id IN NUMBER)
    RETURN NUMBER IS
BEGIN
    RETURN qpc_mandatory_flag(plan_id, element_id);
END get_mandatory_flag;


FUNCTION get_sql_validation_string (element_id IN NUMBER)
    RETURN VARCHAR2 IS
BEGIN
    RETURN qa_chars_api.sql_validation_string(element_id);
END get_sql_validation_string;


FUNCTION get_result_column_name (plan_id IN NUMBER, element_id IN NUMBER)
    RETURN VARCHAR2 IS

    --
    -- This is a function that returns the unique column name in the table
    -- qa_results given an element_id, plan_id combination.
    --

    name                VARCHAR2(30);

BEGIN

    name := qa_chars_api.hardcoded_column(element_id);

    IF (name IS NULL) THEN
        name := qpc_result_column_name(plan_id, element_id);
    END IF;

    RETURN name;

END get_result_column_name;


FUNCTION sql_string_exists(x_plan_id IN NUMBER, x_char_id IN NUMBER,
    org_id IN NUMBER, user_id IN NUMBER, value IN VARCHAR2,
    x_ref OUT NOCOPY LovRefCursor)
    RETURN BOOLEAN IS

    sql_string VARCHAR2(3000);
    wild VARCHAR2(250);

BEGIN

    -- Before Single Scan LOV
    -- wild := value || '%';

    -- After Single Scan LOV
    wild := value;

    IF values_exist(x_plan_id, x_char_id) THEN
        sql_string := 'SELECT short_code, description
                       FROM   qa_plan_char_value_lookups
                       WHERE  plan_id = :1
                       AND    char_id = :2
                       AND    short_code LIKE :3
                       ORDER BY short_code';
        OPEN x_ref FOR sql_string USING x_plan_id, x_char_id, wild;
        RETURN TRUE;

    ELSIF sql_validation_exists(x_char_id) THEN

        sql_string := get_sql_validation_string(x_char_id);
        sql_string := qa_chars_api.format_sql_for_lov(sql_string,
            org_id, user_id);

        --
        -- Bug 1474995.  Adding filter to the user-defined SQL.
        --
        sql_string :=
            'select *
            from
               (select ''x'' code, ''x'' description
                from dual
                where 1 = 2
                union
                select * from
                ( '|| sql_string ||
               ' )) where code like :1';

        OPEN x_ref FOR sql_string USING wild;
        RETURN TRUE;

    ELSE
        RETURN FALSE;
    END IF;

END sql_string_exists;


PROCEDURE get_department_lov(org_id IN NUMBER, value IN VARCHAR2,
    x_ref OUT NOCOPY LovRefCursor) IS

    wild VARCHAR2(160);
    sql_string VARCHAR2(1500);

BEGIN

/*  Before Single Scan LOV
    IF value IS NULL THEN
        wild := '%';
    ELSE
        wild := value || '%';
    END IF; */

    -- After Single Scan LOV
    wild := value;

    sql_string := 'SELECT department_code, description
                   FROM   bom_departments_val_v
                   WHERE  department_code like :1 AND
                          organization_id = :2
                   ORDER BY department_code';
    OPEN x_ref FOR sql_string USING wild, org_id;

END get_department_lov;


PROCEDURE get_job_lov(org_id IN NUMBER, value IN VARCHAR2,
    x_ref OUT NOCOPY LovRefCursor) IS

    wild VARCHAR2(160);
    sql_string VARCHAR2(1500);

BEGIN

/*  Before Single Scan LOV
    IF value IS NULL THEN
        wild := '%';
    ELSE
        wild := value || '%';
    END IF; */

    -- After Single Scan LOV
    wild := value;


  -- #2382432
  -- Changed the view to WIP_DISCRETE_JOBS_ALL_V instead of
  -- earlier wip_open_discrete_jobs_val_v
  -- rkunchal Sun Jun 30 22:59:11 PDT 2002

    sql_string := 'SELECT wip_entity_name, description
                   FROM   wip_discrete_jobs_all_v
                   WHERE  wip_entity_name like :1 AND
                          organization_id = :2
                   ORDER BY wip_entity_name';
    OPEN x_ref FOR sql_string USING wild, org_id;
END get_job_lov;


PROCEDURE get_work_order_lov(org_id IN NUMBER, value IN VARCHAR2,
    x_ref OUT NOCOPY LovRefCursor) IS

    wild VARCHAR2(160);
    sql_string VARCHAR2(1500);

BEGIN

/*  Before Single Scan LOV
    IF value IS NULL THEN
        wild := '%';
    ELSE
        wild := value || '%';
    END IF; */

    -- After Single Scan LOV
    wild := value;

/* rkaza 10/21/2002. Bug 2635736 */
    sql_string := 'select WE.wip_entity_name, WDJ.description
                   from wip_entities WE, wip_discrete_jobs WDJ
                   where WDJ.organization_id = :1 and
                         WDJ.status_type in (3,4) and
                         WDJ.wip_entity_id = WE.wip_entity_id and
                         WE.entity_type IN (6, 7) and
                         WE.wip_entity_name like :2
                         order by WE.wip_entity_name';

    OPEN x_ref FOR sql_string USING org_id, wild;

END get_work_order_lov;



PROCEDURE get_production_lov (org_id IN NUMBER, value IN VARCHAR2,
    x_ref OUT NOCOPY LovRefCursor) IS

    wild VARCHAR2(160);
    sql_string VARCHAR2(1500);

BEGIN

/*  Before Single Scan LOV
    IF value IS NULL THEN
        wild := '%';
    ELSE
        wild := value || '%';
    END IF; */

    -- After Single Scan LOV
    wild := value;

    sql_string := 'SELECT line_code, description
                   FROM   wip_lines_val_v
                   WHERE  line_code like :1 AND
                          organization_id = :2
                   ORDER BY line_code';
    OPEN x_ref FOR sql_string USING wild, org_id;

END get_production_lov;


PROCEDURE get_resource_code_lov (org_id IN NUMBER, value IN VARCHAR2,
    x_ref OUT NOCOPY LovRefCursor) IS

    wild VARCHAR2(160);
    sql_string VARCHAR2(1500);

BEGIN

/*  Before Single Scan LOV
    IF value IS NULL THEN
        wild := '%';
    ELSE
        wild := value || '%';
    END IF; */

    -- After Single Scan LOV
    wild := value;


    sql_string := 'SELECT resource_code, description
                   FROM   bom_resources_val_v
                   WHERE  resource_code like :1
                   AND    organization_id = :2
                   ORDER BY resource_code';

    OPEN x_ref FOR sql_string USING wild, org_id;

END get_resource_code_lov;


PROCEDURE get_supplier_lov (value IN VARCHAR2, x_ref OUT NOCOPY LovRefCursor) IS

    wild VARCHAR2(240);
    sql_string VARCHAR2(1500);

BEGIN

/*  Before Single Scan LOV
    IF value IS NULL THEN
        wild := '%';
    ELSE
        wild := value || '%';
    END IF; */

    -- After Single Scan LOV
    wild := value;

    sql_string := 'SELECT vendor_name, segment1
                   FROM   po_vendors
                   WHERE  vendor_name like :1
                   AND    nvl(end_date_active, sysdate + 1) > sysdate
                   ORDER BY vendor_name';

    OPEN x_ref FOR sql_string USING wild;

END get_supplier_lov;


PROCEDURE get_po_number_lov (value IN VARCHAR2, x_ref OUT NOCOPY LovRefCursor) IS

    wild VARCHAR2(160);
    sql_string VARCHAR2(1500);

BEGIN

/*  Before Single Scan LOV
    IF value IS NULL THEN
        wild := '%';
    ELSE
        wild := value || '%';
    END IF; */

    -- After Single Scan LOV
    wild := value;

    -- R12 Project MOAC 4637896
    -- Now select operating unit as an additional column.
    -- bso Sat Oct  8 12:21:06 PDT 2005

    sql_string := 'SELECT po_header_id, segment1, vendor_name ||
                          '' ('' || operating_unit || '')''
                   FROM   qa_po_numbers_lov_v
                   WHERE  segment1 like :1
                   ORDER BY segment1';

    OPEN x_ref FOR sql_string USING wild;

END get_po_number_lov;


--
-- Reference bug 2286796
-- The lov query should be the same with the element Customer's
-- sql_validation_string. customer_name is the column that should show
-- first and populate to collection element Customer.
-- Reversed the column order and order by customer_name instead of number
-- jezheng
-- Wed Apr 17 14:57:27 PDT 2002
--
PROCEDURE get_customer_lov (value IN VARCHAR2, x_ref OUT NOCOPY LovRefCursor) IS

    wild VARCHAR2(160);
    sql_string VARCHAR2(1500);

BEGIN

/*  Before Single Scan LOV
    IF value IS NULL THEN
        wild := '%';
    ELSE
        wild := value || '%';
    END IF; */

    -- After Single Scan LOV
    wild := value;

    sql_string := 'SELECT customer_name, customer_number
                   FROM   qa_customers_lov_v
                   WHERE  customer_name like :1
                   AND  status = ''A''
                   AND nvl(customer_prospect_code, ''CUSTOMER'') =
                   ''CUSTOMER''
                   ORDER BY customer_name';

    OPEN x_ref FOR sql_string USING wild;

END get_customer_lov;


PROCEDURE get_so_number_lov (value IN VARCHAR2, x_ref OUT NOCOPY LovRefCursor) IS

    wild VARCHAR2(160);
    sql_string VARCHAR2(1500);

BEGIN

/*  Before Single Scan LOV
    IF value IS NULL THEN
        wild := '%';
    ELSE
        wild := value || '%';
    END IF; */

    -- After Single Scan LOV
    wild := value;

-- Bug 4958763. Fixing it along with SQL repository fixes
-- reverting back the changes for functionality
    sql_string := 'SELECT  order_number, order_type name
                   FROM    qa_sales_orders_lov_v
                   WHERE   order_number like :1
                   ORDER BY order_number';

    OPEN x_ref FOR sql_string USING wild;

END get_so_number_lov;


    -- Bug 4958763.  SQL Repository Fix SQL ID: 15009074
    -- "so_lines" is obsoleted in 11i. Replacing it with oe_order_lines
    -- also SO Line Number is not having LOV in Forms and QWB
    -- and so removing the lov in Mobile as well
    -- even after commenting out it does not require any change in Mobile code
    -- saugupta Wed, 08 Feb 2006 03:00:30 -0800 PDT

 -- Bug 7716875.Setting LOV for SO Line Num based on SO Num
 -- Included so num in parameters.pdube Mon Apr 13 03:25:19 PDT 2009
 PROCEDURE get_so_line_number_lov (x_so_number IN VARCHAR2,
                                   value IN VARCHAR2,
                                   x_ref OUT NOCOPY LovRefCursor) IS

    wild VARCHAR2(160);
    sql_string VARCHAR2(1500);

BEGIN

     -- Bug 7716875.Added this query to get so_line_nums based on so.
     -- x_ref := NULL;
     wild := value;
     sql_string := 'select distinct to_char(oel.line_number) ,''Sales Order: ''|| '||
                   'oeha.order_number || '';'' || ''Item: '' || oel.ordered_item  description '||
                   'from oe_order_lines_all oel, oe_order_headers_all oeha '||
                   'where oel.header_id = oeha.header_id '||
                   'and oeha.order_number = :1 ' ||
                   'and to_char(oel.line_number) like :2 ' ||
                   'order by description, line_number ';
     OPEN x_ref FOR sql_string USING x_so_number,wild;

/*  Before Single Scan LOV
    IF value IS NULL THEN
        wild := '%';
    ELSE
        wild := value || '%';
    END IF;

    -- After Single Scan LOV
    wild := value;

    sql_string := 'SELECT to_char(sl.line_number), msik.concatenated_segments
                   FROM   mtl_system_items_kfv msik, so_lines sl
                   WHERE  sl.inventory_item_id = msik.inventory_item_id
                   AND    header_id like :1';

    OPEN x_ref FOR sql_string USING wild;
*/
END get_so_line_number_lov;


PROCEDURE get_po_release_number_lov (p_po_header_id IN NUMBER, value IN VARCHAR2, x_ref OUT
    NOCOPY LovRefCursor) IS

    wild VARCHAR2(160);
    sql_string VARCHAR2(1500);

BEGIN

/*  Before Single Scan LOV
    IF value IS NULL THEN
        wild := '%';
    ELSE
        wild := value || '%';
    END IF; */

    -- After Single Scan LOV
    wild := value;
-- Bug 4958763.  SQL Repository Fix SQL ID: 15009081
/*
    sql_string := 'SELECT release_num, release_date
                   FROM   po_releases pr
                   WHERE  pr.release_num like :1
                   ORDER BY pr.release_num';
*/

    sql_string := 'SELECT release_num, release_date
                   FROM   po_releases
                   WHERE po_header_id = :1
                   AND release_num like :2
                   ORDER BY release_num';

    OPEN x_ref FOR sql_string USING p_po_header_id, wild;

END get_po_release_number_lov;


PROCEDURE get_project_number_lov (value IN VARCHAR2, x_ref OUT
    NOCOPY LovRefCursor) IS

    wild VARCHAR2(160);
    sql_string VARCHAR2(1500);

BEGIN
/*
mtl_project_v changed to pjm_projects_all_v (selects from both pjm enabled and
non-pjm enabled orgs).
rkaza, 11/10/2001.
*/
/*  Before Single Scan LOV
    IF value IS NULL THEN
        wild := '%';
    ELSE
        wild := value || '%';
    END IF; */

    -- After Single Scan LOV
    wild := value;

--
--  Bug 5249078.  Changed pjm_projects_all_v to
--  pjm_projects_v for MOAC compliance.
--  bso Thu Jun  1 10:46:50 PDT 2006
--
    sql_string := 'SELECT project_number, project_name
                   FROM   pjm_projects_v
                   WHERE  project_number like :1
                   ORDER BY project_number';

    OPEN x_ref FOR sql_string USING wild;

END get_project_number_lov;


PROCEDURE get_task_number_lov (value IN VARCHAR2, x_ref OUT
    NOCOPY LovRefCursor) IS

    wild VARCHAR2(160);
    sql_string VARCHAR2(1500);

BEGIN

/*  Before Single Scan LOV
    IF value IS NULL THEN
        wild := '%';
    ELSE
        wild := value || '%';
    END IF; */

    -- After Single Scan LOV
    wild := value;

    sql_string := 'SELECT task_number, task_name
                   FROM   mtl_task_v
                   WHERE  task_number like :1
                   ORDER BY task_number';

    OPEN x_ref FOR sql_string USING wild;

END get_task_number_lov;


PROCEDURE get_rma_number_lov (value IN VARCHAR2, x_ref OUT
    NOCOPY LovRefCursor) IS

    wild VARCHAR2(160);
    sql_string VARCHAR2(1500);

BEGIN

/*  Before Single Scan LOV
    IF value IS NULL THEN
        wild := '%';
    ELSE
        wild := value || '%';
    END IF; */

    -- After Single Scan LOV
    wild := value;

    sql_string := 'SELECT sh.order_number, sot.name
                   FROM   so_order_types sot,
                          oe_order_headers sh,
                          qa_customers_lov_v rc
                   WHERE  sh.order_type_id = sot.order_type_id and
                          sh.sold_to_org_id = rc.customer_id and
                          sh.order_category_code in (''RETURN'', ''MIXED'') and
                          sh.order_number like :1
                   ORDER BY sh.order_number';

    OPEN x_ref FOR sql_string USING wild;

END get_rma_number_lov;

--
-- Bug 6161802
-- Added procedure to return lov sql for rma line number
-- with rma number as a bind variable
-- skolluku Tue Jul 17 23:47:13 PDT 2007
--
PROCEDURE get_rma_line_num_lov (x_rma_number IN VARCHAR2,
    value IN VARCHAR2, x_ref OUT NOCOPY LovRefCursor) IS

    wild VARCHAR2(160);
    sql_string VARCHAR2(1500);

BEGIN

   -- After Single Scan LOV
    wild := value;

    sql_string := 'select distinct to_char(oel.line_number),
                  ''RMA Number: '' || sh.order_number || '';'' || ''Item: '' || oel.ordered_item  description
                  from oe_order_lines oel, so_order_types sot, oe_order_headers sh
                  where sh.order_type_id = sot.order_type_id and oel.header_id = sh.header_id and
                   oel.line_category_code in (''RETURN'', ''MIXED'') and
                   sh.order_number = :1 and
                   to_char(oel.line_number) like :2
                  order by description, line_number';

    OPEN x_ref FOR sql_string USING x_rma_number, wild;

END get_rma_line_num_lov;

PROCEDURE get_LPN_lov (value IN VARCHAR2, x_ref OUT
    NOCOPY LovRefCursor) IS

    wild VARCHAR2(160);
    sql_string VARCHAR2(1500);

BEGIN

/*  Before Single Scan LOV
    IF value IS NULL THEN
        wild := '%';
    ELSE
        wild := value || '%';
    END IF; */

    -- After Single Scan LOV
    wild := value;

    sql_string := 'SELECT license_plate_number, attribute1
                   FROM   wms_license_plate_numbers
                   WHERE  license_plate_number like :1
                   ORDER BY license_plate_number';

    OPEN x_ref FOR sql_string USING wild;

END get_LPN_lov;

-- added the following to include new hardcoded element Transfer license plate number
-- saugupta Aug 2003

PROCEDURE get_XFR_LPN_lov (value IN VARCHAR2, x_ref OUT
    NOCOPY LovRefCursor) IS

    wild VARCHAR2(160);
    sql_string VARCHAR2(1500);

BEGIN

/*  Before Single Scan LOV
    IF value IS NULL THEN
        wild := '%';
    ELSE
        wild := value || '%';
    END IF; */

    -- After Single Scan LOV
    wild := value;

    sql_string := 'SELECT license_plate_number, attribute1
                   FROM   wms_license_plate_numbers
                   WHERE  license_plate_number like :1
                   ORDER BY license_plate_number';

    OPEN x_ref FOR sql_string USING wild;

END get_XFR_LPN_lov;

PROCEDURE get_contract_lov (value IN VARCHAR2, x_ref OUT
    NOCOPY LovRefCursor) IS

    filter VARCHAR2(160);
    sql_string VARCHAR2(1500);

BEGIN

/*  Before Single Scan LOV
    filter := value || '%'; */

    -- After Single Scan LOV
    filter := value;

    sql_string := 'SELECT k_number, short_description
                   FROM   oke_k_headers_lov_v
                   WHERE  k_number like :1
                   ORDER BY k_number';

    OPEN x_ref FOR sql_string USING filter;

END get_contract_lov;

PROCEDURE get_contract_line_lov (value IN VARCHAR2, contract_number IN VARCHAR2,
                                 x_ref OUT NOCOPY LovRefCursor) IS

filter VARCHAR2(160);
sql_string VARCHAR2(1500);
contract_id NUMBER ;

BEGIN

/*  Before Single Scan LOV
    filter := value || '%'; */

    -- After Single Scan LOV
    filter := value;

    contract_id := get_contract_id (contract_number);
    sql_string := 'SELECT line_number, line_description
                   FROM   oke_k_lines_full_v
                   WHERE  header_id = :1 AND
                          line_number like :2
                   ORDER BY line_number';

    OPEN x_ref FOR sql_string USING contract_id, filter;

END get_contract_line_lov;

PROCEDURE get_deliverable_lov (value IN VARCHAR2, contract_number IN VARCHAR2,
                               line_number IN VARCHAR2, x_ref OUT NOCOPY LovRefCursor) IS

filter VARCHAR2(160);
sql_string VARCHAR2(1500);
contract_id NUMBER;
line_id NUMBER;

BEGIN

/*  Before Single Scan LOV
    filter := value || '%'; */

    -- After Single Scan LOV
    filter := value;

    contract_id := get_contract_id (contract_number);
    line_id := get_contract_line_id (line_number);

    sql_string := 'SELECT deliverable_num, description
                   FROM   oke_k_deliverables_vl
                   WHERE  k_header_id = :1 AND
                          k_line_id = :2 AND
                          deliverable_num like :3
                   ORDER BY deliverable_num';

    OPEN x_ref FOR sql_string USING contract_id, line_id, filter;

END get_deliverable_lov;



PROCEDURE get_uom_lov (x_org_id IN NUMBER, x_item_name IN VARCHAR2,
    value IN VARCHAR2, x_ref OUT NOCOPY LovRefCursor) IS

    wild VARCHAR2(160);
    sql_string VARCHAR2(1500);
    x_item_id NUMBER DEFAULT NULL;

BEGIN

    -- This procedure is used for both uom and component uom

/*  Before Single Scan LOV
    IF value IS NULL THEN
        wild := '%';
    ELSE
        wild := value || '%';
    END IF; */

    -- After Single Scan LOV
    wild := value;

    x_item_id := qa_flex_util.get_item_id(x_org_id, x_item_name);

    sql_string := 'SELECT uom_code, description
                   FROM   mtl_item_uoms_view
                   WHERE  inventory_item_id = :1
                   AND    organization_id = :2
                   AND    uom_code like :3
                   ORDER BY uom_code';

    OPEN x_ref FOR sql_string USING x_item_id, x_org_id, wild;

END get_uom_lov;


PROCEDURE get_revision_lov (x_org_id IN NUMBER, x_item_name IN VARCHAR2,
    value IN VARCHAR2, x_ref OUT NOCOPY LovRefCursor) IS

    wild VARCHAR2(160);
    sql_string VARCHAR2(1500);
    x_item_id NUMBER DEFAULT NULL;

BEGIN

    -- This procedure is used for both revision and component revision

/*  Before Single Scan LOV
    IF value IS NULL THEN
        wild := '%';
    ELSE
        wild := value || '%';
    END IF; */

    -- After Single Scan LOV
    wild := value;

    x_item_id := qa_flex_util.get_item_id(x_org_id, x_item_name);

    -- Bug 3595553. Modified the below query to join with msi to fetch
    -- revisions only if the item is revision controlled. All the items
    -- will have a base revision by default. But we want this sql to
    -- fetch revision only if the item is revision controlled. kabalakr.

    sql_string := 'SELECT mir.revision, mir.effectivity_date
                   FROM   mtl_item_revisions mir, mtl_system_items msi
                   WHERE  mir.inventory_item_id = :1
                   AND    mir.organization_id = :2
                   AND    mir.revision like :3
                   AND    mir.inventory_item_id = msi.inventory_item_id
                   AND    mir.organization_id = msi.organization_id
                   AND    msi.revision_qty_control_code = 2
                   ORDER BY revision';

    OPEN x_ref FOR sql_string USING x_item_id, x_org_id, wild;

END get_revision_lov;

PROCEDURE get_lot_num_lov (x_org_id IN NUMBER, x_item_name IN VARCHAR2,
    value IN VARCHAR2, x_ref OUT NOCOPY LovRefCursor) IS

    wild VARCHAR2(160);
    sql_string VARCHAR2(1500);
    x_item_id NUMBER DEFAULT NULL;

BEGIN

/*  Before Single Scan LOV
    IF value IS NULL THEN
        wild := '%';
    ELSE
        wild := value || '%';
    END IF; */

    -- After Single Scan LOV
    wild := value;

    x_item_id := qa_flex_util.get_item_id(x_org_id, x_item_name);

    sql_string := 'select lot_number, description
                   from mtl_lot_numbers
                   where inventory_item_id = :1
                   and organization_id = :2
                   and lot_number like :3
                   and (disable_flag = 2 or disable_flag is null)
                   ORDER BY lot_number';

    OPEN x_ref FOR sql_string USING x_item_id, x_org_id, wild;

END get_lot_num_lov;

PROCEDURE get_serial_num_lov (x_org_id IN NUMBER, x_item_name IN VARCHAR2,
x_lot_number IN VARCHAR2,
x_revision IN VARCHAR2,
    value IN VARCHAR2, x_ref OUT NOCOPY LovRefCursor) IS

    wild VARCHAR2(160);
    sql_string VARCHAR2(1500);
    x_item_id NUMBER DEFAULT NULL;

BEGIN

    wild := value;

    x_item_id := qa_flex_util.get_item_id(x_org_id, x_item_name);

    -- Undoing Bug 3364660.  Not needed after sync up with Bug 3773298
    -- l_trans_string := fnd_message.get_string('QA','QA_MOBILE_SERIAL_LOV_TXT');
    --
    -- Bug 3773298
    -- Sync up the SQL to be the same with forms.
    -- bso Tue Jul 20 16:12:06 PDT 2004
    --
    sql_string := 'select serial_number, current_status_name
                    from mtl_serial_numbers_all_v
                    where current_organization_id = :1
                    and inventory_item_id = :2
                    and (:3 is null OR lot_number = :4)
                    and (:5 is null OR revision = :6)
                    and serial_number like :7
                    order by 1';

    OPEN x_ref FOR sql_string USING x_org_id , x_item_id, x_lot_number, x_lot_number, x_revision, x_revision, wild;

END get_serial_num_lov;

--dgupta: Start R12 EAM Integration. Bug 4345492
PROCEDURE get_asset_instance_number_lov (p_org_id IN NUMBER, p_asset_group IN VARCHAR2,
p_asset_number IN VARCHAR2, value IN VARCHAR2, x_ref OUT NOCOPY LovRefCursor) IS

    wild VARCHAR2(160);
    sql_string VARCHAR2(1500);
    l_asset_group_id NUMBER DEFAULT NULL;

BEGIN
    -- After Single Scan LOV
    wild := value;

    l_asset_group_id := get_asset_group_id(p_org_id, p_asset_group);

   sql_string := 'SELECT
      cii.instance_number, cii.instance_description
      FROM
      csi_item_instances cii, mtl_system_items_b msib, mtl_parameters mp
      WHERE
      msib.organization_id = mp.organization_id and
      msib.organization_id = cii.last_vld_organization_id and
      msib.inventory_item_id = cii.inventory_item_id and
      msib.eam_item_type in (1,3) and
      msib.serial_number_control_code <> 1 and
      sysdate between nvl(cii.active_start_date, sysdate-1)
                and nvl(cii.active_end_date, sysdate+1) and
      mp.maint_organization_id = :1 and
      cii.inventory_item_id = nvl(:2, cii.inventory_item_id) and
      cii.instance_number like :3 and
      cii.serial_number = nvl(:4, cii. serial_number)
      order by cii.instance_number';

    OPEN x_ref FOR sql_string USING p_org_id , l_asset_group_id, wild, p_asset_number;

END get_asset_instance_number_lov;
--dgupta: End R12 EAM Integration. Bug 4345492


PROCEDURE get_asset_number_lov (x_org_id IN NUMBER, x_asset_group IN VARCHAR2,
x_asset_instance_number IN VARCHAR2, --R12 EAM Integration. Bug 4345492
value IN VARCHAR2, x_ref OUT NOCOPY LovRefCursor) IS

    wild VARCHAR2(160);
    sql_string VARCHAR2(1500);
    x_asset_group_id NUMBER DEFAULT NULL;
    x_asset_instance_id NUMBER DEFAULT NULL; --R12 EAM Integration. Bug 4345492

BEGIN

/*  Before Single Scan LOV
    IF value IS NULL THEN
        wild := '%';
    ELSE
        wild := value || '%';
    END IF; */

    -- After Single Scan LOV
    wild := value;

   --dgupta: Start R12 EAM Integration. Bug 4345492
   x_asset_group_id := get_asset_group_id(x_org_id, x_asset_group);
   x_asset_instance_id := get_asset_instance_id(x_asset_instance_number);

   sql_string := 'SELECT
    	distinct msn.serial_number, msn.descriptive_text
    	FROM
    	mtl_serial_numbers msn, csi_item_instances cii, mtl_system_items_b msib, mtl_parameters mp
    	WHERE
    	msib.organization_id = mp.organization_id and
    	msib.organization_id = cii.last_vld_organization_id and
    	msib.inventory_item_id = cii.inventory_item_id and
    	msib.eam_item_type in (1,3) and
    	sysdate between nvl(cii.active_start_date(+), sysdate-1)
    	          and nvl(cii.active_end_date(+), sysdate+1) and
    	msib.organization_id = msn.current_organization_id and
    	msib.inventory_item_id = msn.inventory_item_id and
    	mp.maint_organization_id = :1 and
    	msn.inventory_item_id = :2 and --removed nvl: serial number requires asset group as well
    	msn.serial_number like :3 and
    	cii.instance_id= nvl(:4, cii.instance_id)
    	order by msn.serial_number';

    OPEN x_ref FOR sql_string USING x_org_id , x_asset_group_id, wild, x_asset_instance_id;
   --dgupta: End R12 EAM Integration. Bug 4345492

END get_asset_number_lov;


PROCEDURE get_subinventory_lov (x_org_id IN NUMBER, value IN VARCHAR2,
    x_ref OUT NOCOPY LovRefCursor) IS

    wild VARCHAR2(160);
    sql_string VARCHAR2(1500);

BEGIN

    -- This procedure is used for both subinventory and component subinventory

/*  Before Single Scan LOV
    IF value IS NULL THEN
        wild := '%';
    ELSE
        wild := value || '%';
    END IF; */

    -- After Single Scan LOV
    wild := value;

    sql_string := 'SELECT secondary_inventory_name, description
                   FROM   mtl_secondary_inventories
                   WHERE  organization_id = :1
                   AND    nvl(disable_date, sysdate+1) > sysdate
                   AND    secondary_inventory_name like :2
                   ORDER BY secondary_inventory_name';

    OPEN x_ref FOR sql_string USING x_org_id, wild;

END get_subinventory_lov;


PROCEDURE get_lot_number_lov (x_transaction_id IN NUMBER, value IN VARCHAR2,
    x_ref OUT NOCOPY LovRefCursor) IS

    wild VARCHAR2(160);
    sql_string VARCHAR2(1500);

BEGIN

/*  Before Single Scan LOV
    IF value IS NULL THEN
        wild := '%';
    ELSE
        wild := value || '%';
    END IF; */

    -- After Single Scan LOV
    wild := value;

    sql_string := 'SELECT lot_number, lot_expiration_date
                   FROM   mtl_transaction_lots_temp
                   WHERE  transaction_temp_id = :1
                   AND    lot_number like :2
                   ORDER BY lot_number';

    OPEN x_ref FOR sql_string USING x_transaction_id, wild;

END get_lot_number_lov;


PROCEDURE get_serial_number_lov (x_transaction_id IN NUMBER, x_lot_number
    IN VARCHAR2, value IN VARCHAR2, x_ref OUT NOCOPY LovRefCursor) IS

    wild VARCHAR2(160);
    sql_string VARCHAR2(1500);

BEGIN

    wild := value;

    --
    -- Bug 3758145.  The original SQL is incorrect in transaction scenario.
    -- the WHERE conditions msn.line_mark_id should be rewritten as
    -- msn.lot_line_mark_id and vice versa.
    -- bso Tue Jul 20 15:52:21 PDT 2004
    --
    sql_string := 'SELECT msn.serial_number, msn.current_status
                   FROM  mtl_serial_numbers msn,
                         mtl_transaction_lots_temp mtlt
                   WHERE msn.lot_line_mark_id = :1
                   AND mtlt.transaction_temp_id = msn.lot_line_mark_id
                   AND mtlt.serial_transaction_temp_id = msn.line_mark_id
                   AND mtlt.lot_number = :2
                   AND :3 IS NOT NULL
                   AND msn.serial_number like :4
                   UNION ALL
                   SELECT msn.serial_number, msn.current_status
                   FROM mtl_serial_numbers msn
                   WHERE msn.line_mark_id = :5
                   AND :6 IS NULL
                   AND msn.serial_number like :7
                   ORDER BY 1';

    OPEN x_ref FOR sql_string USING x_transaction_id, x_lot_number,
        x_lot_number, wild, x_transaction_id, x_lot_number, wild;

END get_serial_number_lov;

--
-- Removed the DEFAULT clause to make the code GSCC compliant
-- List of changed arguments.
-- Old
--    production_line IN VARCHAR2 DEFAULT NULL
-- New
--    production_line IN VARCHAR2
--

PROCEDURE get_op_seq_number_lov (org_id IN NUMBER, value IN VARCHAR2,
    job_name IN VARCHAR2, production_line IN VARCHAR2,
    x_ref OUT NOCOPY LovRefCursor) IS

    wild VARCHAR2(160);
    sql_string VARCHAR2(1500);
    x_line_id NUMBER DEFAULT NULL;
    x_wip_entity_id NUMBER DEFAULT NULL;

BEGIN

/*  Before Single Scan LOV
    IF value IS NULL THEN
        wild := '%';
    ELSE
        wild := value || '%';
    END IF; */

    -- After Single Scan LOV
    wild := value;

    IF (production_line IS NOT NULL) THEN
        x_line_id := get_production_line_id(org_id, production_line);
    END IF;

    x_wip_entity_id := get_job_id(org_id, job_name);


    IF (x_line_id IS NULL) THEN

        sql_string := 'SELECT operation_seq_num, operation_code
                       FROM     wip_operations_all_v
                       WHERE    operation_seq_num like :1
                       AND      wip_entity_id = :2
                       AND      organization_id = :3
                       ORDER BY operation_seq_num';

        OPEN x_ref FOR sql_string USING wild, x_wip_entity_id, org_id;

    ELSE

        sql_string := 'SELECT operation_seq_num, operation_code
                       FROM   wip_operations_all_v
                       WHERE  operation_seq_num like :1
                       AND    wip_entity_id = :2
                       AND    organization_id = :3
                       AND    repetitive_schedule_id =
                       (
                        SELECT  repetitive_schedule_id
                        FROM    wip_first_open_schedule_v
                        WHERE   line_id = :4
                        AND     wip_entity_id = :5
                        AND organization_id = :6
                        )
                       ORDER BY operation_seq_num';

        OPEN x_ref FOR sql_string USING wild, x_wip_entity_id, org_id,
            x_line_id, x_wip_entity_id, org_id;

    END IF;

END get_op_seq_number_lov;

--
-- See Bug 2588213
-- To support the element Maintenance Op Seq Number
-- to be used along with Maintenance Workorder
-- rkunchal Mon Sep 23 23:46:28 PDT 2002
--

PROCEDURE get_maintenance_op_seq_lov(org_id IN NUMBER,
                                     value IN VARCHAR2,
                                     maintenance_work_order IN VARCHAR2,
                                     x_ref OUT NOCOPY LovRefCursor) IS
    wild VARCHAR2(160);
    sql_string VARCHAR2(1500);
    x_wip_entity_id NUMBER DEFAULT NULL;

BEGIN

/*  Before Single Scan LOV
    IF value IS NULL THEN
       wild := '%';
    ELSE
       wild := value || '%';
    END IF; */

    -- After Single Scan LOV
    wild := value;

    x_wip_entity_id := get_job_id(org_id, maintenance_work_order);

    sql_string := 'SELECT   operation_seq_num, operation_code
                   FROM     wip_operations_all_v
                   WHERE    operation_seq_num like :1
                   AND      wip_entity_id = :2
                   AND      organization_id = :3
                   ORDER BY operation_seq_num';

    OPEN x_ref FOR sql_string USING wild, x_wip_entity_id, org_id;

END get_maintenance_op_seq_lov;

--
-- End of inclusions for Bug 2588213
--


--
-- R12 Project MOAC 4637896
-- Change po_number param to p_po_header_id and change the
-- SQL to bind to this param.
-- bso Sat Oct  8 12:29:58 PDT 2005
--
PROCEDURE get_po_line_number_lov(p_po_header_id IN NUMBER, value IN
    VARCHAR2, x_ref OUT NOCOPY LovRefCursor) IS

    wild VARCHAR2(160);
    sql_string VARCHAR2(1500);

BEGIN

/*  Before Single Scan LOV
    IF value IS NULL THEN
        wild := '%';
    ELSE
        wild := value || '%';
    END IF; */

    -- After Single Scan LOV
    wild := value;

    --
    -- bug 9652444 CLM changes
    --
    sql_string := 'SELECT line_num, concatenated_segments
                   FROM   PO_LINES_VAL_TRX_V
                   WHERE  po_header_id = :1
                   AND    line_num like :2
                   ORDER BY line_num';

    OPEN x_ref FOR sql_string USING p_po_header_id, wild;

END get_po_line_number_lov;


--
-- R12 Project MOAC 4637896
-- Change po_number param to p_po_header_id and change the
-- SQL to bind to this param.
-- bso Sat Oct  8 12:29:58 PDT 2005
--
-- bug 9652444 CLM changes
--
PROCEDURE get_po_shipments_lov(po_line_num IN VARCHAR2, p_po_header_id IN NUMBER,
    value IN VARCHAR2, x_ref OUT NOCOPY LovRefCursor) IS

    wild VARCHAR2(160);
    sql_string VARCHAR2(1500);

BEGIN

/*  Before Single Scan LOV
    IF value IS NULL THEN
        wild := '%';
    ELSE
        wild := value || '%';
    END IF; */

    -- After Single Scan LOV
    wild := value;

/*
    sql_string := 'SELECT shipment_num, shipment_type
                   FROM  po_shipments_all_v
                   WHERE po_line_id =
                       (SELECT po_line_id
                        FROM po_lines_val_v
                        WHERE line_num = :1
                        AND po_header_id = :2)
                   AND shipment_num like :3';
*/
    -- Bug 4958763. SQL Repository Fix SQL ID: 15009194
    --
    -- bug 9652549 CLM changes
    --
    sql_string := 'SELECT shipment_num, shipment_type
                   FROM  PO_LINE_LOCATIONS_TRX_V
                   WHERE po_line_id =
                          (SELECT po_line_id
                           FROM PO_LINES_TRX_V
                           WHERE line_num = :1
                           AND po_header_id = :2)
                   AND shipment_num like :3';

    OPEN x_ref FOR sql_string USING po_line_num, p_po_header_id, wild;

END get_po_shipments_lov;


PROCEDURE get_receipt_num_lov (value IN VARCHAR2, x_ref OUT NOCOPY LovRefCursor) IS

    wild VARCHAR2(160);
    sql_string VARCHAR2(1500);

BEGIN

/*  Before Single Scan LOV
    IF value IS NULL THEN
        wild := '%';
    ELSE
        wild := value || '%';
    END IF; */

    -- After Single Scan LOV
    wild := value;

    -- Bug 7491455
    -- FP for bug 6800960.Changed the sql to include the RMA receipts.
    -- pdube Fri Oct 17 00:14:28 PDT 2008
    /*sql_string := 'SELECT RCVSH.receipt_num, POV.vendor_name
                   FROM   rcv_receipts_all_v
                   WHERE  receipt_num like :1
                   ORDER BY receipt_num';
    */
    sql_string :=  'SELECT RCVSH.receipt_num, POV.vendor_name
                    FROM  RCV_SHIPMENT_HEADERS RCVSH,
                          PO_VENDORS POV,
                          RCV_TRANSACTIONS RT
                    WHERE RCVSH.RECEIPT_SOURCE_CODE in (''VENDOR'',''CUSTOMER'') AND
                          RCVSH.VENDOR_ID = POV.VENDOR_ID(+) AND
                          RT.SHIPMENT_HEADER_ID = RCVSH.SHIPMENT_HEADER_ID AND
                          rcvsh.receipt_num like :1
                          ORDER BY RCVSH.receipt_num';

    OPEN x_ref FOR sql_string USING wild;

END get_receipt_num_lov;


PROCEDURE get_party_lov (value IN VARCHAR2, x_ref OUT NOCOPY LovRefCursor) IS

    wild VARCHAR2(160);
    sql_string VARCHAR2(1500);
BEGIN

/*  Before Single Scan LOV
    IF value IS NULL THEN
        wild := '%';
    ELSE
        wild := value || '%';
    END IF; */

    -- After Single Scan LOV
    wild := value;

/*
    --Reviewing 2255344.  Incorrect SQL.  bso

    sql_string := 'SELECT party_number, party_name
                  FROM   hz_parties
                  WHERE party_number like :1
                  AND status = ''A''
                  AND party_type IN (''ORGANIZATION'',''PERSON'')
                  ORDER BY party_name';
 */
    sql_string := 'SELECT party_name, party_number
                  FROM   hz_parties
                  WHERE party_name like :1
                  AND status = ''A''
                  AND party_type IN (''ORGANIZATION'',''PERSON'')
                  ORDER BY party_name';

    OPEN x_ref FOR sql_string USING wild;

END get_party_lov;

--
-- Implemented the following six get_lov procedures for
-- Service_Item, Counter, Maintenance_Requirement, Service_Request, Rework_Job
-- For ASO project
-- rkunchal Thu Jul 25 01:43:48 PDT 2002
--

PROCEDURE get_item_instance_lov (value IN VARCHAR2, x_ref OUT NOCOPY LovRefCursor) IS

    wild VARCHAR2(160);
    sql_string VARCHAR2(1500);

BEGIN

/*  Before Single Scan LOV
    IF value IS NULL THEN
        wild := '%';
    ELSE
        wild := value || '%';
    END IF; */

    -- After Single Scan LOV
    wild := value;

    sql_string := 'SELECT cii.instance_number, cii.serial_number
                   FROM   qa_csi_item_instances cii, mtl_system_items_kfv msik
                   WHERE  cii.inventory_item_id = msik.inventory_item_id
                   AND    cii.last_vld_organization_id = msik.organization_id
                   AND    instance_number like :1
                   ORDER BY 1';

    OPEN x_ref FOR sql_string USING wild;

END get_item_instance_lov;

--
-- Bug 9032151
-- Overloading above procedure and with the new one which takes
-- care of the dependency of item instance on item.
-- skolluku
--
PROCEDURE get_item_instance_lov (p_org_id IN NUMBER, p_item_name IN VARCHAR2,
    value IN VARCHAR2, x_ref OUT NOCOPY LovRefCursor) IS

    wild VARCHAR2(160);
    sql_string VARCHAR2(1500);
    l_item_id NUMBER DEFAULT NULL;

BEGIN

    -- After Single Scan LOV
    wild := value;

    l_item_id := qa_flex_util.get_item_id(p_org_id, p_item_name);

    sql_string := 'SELECT cii.instance_number, cii.serial_number
                   FROM   qa_csi_item_instances cii, mtl_system_items_kfv msik
                   WHERE  cii.inventory_item_id = msik.inventory_item_id
                    AND   cii.last_vld_organization_id = msik.organization_id
                    AND   cii.inventory_item_id = :1
                    AND   trunc(sysdate) BETWEEN trunc(nvl(cii.active_start_date, sysdate))
                                             AND trunc(nvl(cii.active_end_date, sysdate))
                    AND instance_number like :2
                   ORDER BY cii.instance_number';

    OPEN x_ref FOR sql_string USING l_item_id, wild;

END get_item_instance_lov;

--
-- Bug 9359442
-- New procedure which returns lov for item instance serial based on item.
-- skolluku
--
PROCEDURE get_item_instance_serial_lov (p_org_id IN NUMBER, p_item_name IN VARCHAR2,
                                        value IN VARCHAR2, x_ref OUT NOCOPY LovRefCursor) IS

    wild VARCHAR2(160);
    sql_string VARCHAR2(1500);
    l_item_id NUMBER DEFAULT NULL;

BEGIN

    -- After Single Scan LOV
    wild := value;

    l_item_id := qa_flex_util.get_item_id(p_org_id, p_item_name);

    sql_string := 'SELECT cii.serial_number, msik.concatenated_segments
                   FROM qa_csi_item_instances cii, mtl_system_items_kfv msik
                   WHERE cii.inventory_item_id = msik.inventory_item_id
                    AND cii.inv_master_organization_id = msik.organization_id
                    AND msik.inventory_item_id = :1
                    AND cii.serial_number like :2
                    AND trunc(sysdate) BETWEEN trunc(nvl(cii.active_start_date, sysdate))
                    AND trunc(nvl(cii.active_end_date, sysdate))
                   ORDER BY cii.serial_number';

    OPEN x_ref FOR sql_string USING l_item_id, wild;

END get_item_instance_serial_lov;

PROCEDURE get_counter_name_lov (value IN VARCHAR2, x_ref OUT NOCOPY LovRefCursor) IS

    wild VARCHAR2(160);
    sql_string VARCHAR2(1500);

BEGIN

/*  Before Single Scan LOV
    IF value IS NULL THEN
        wild := '%';
    ELSE
        wild := value || '%';
    END IF; */

    -- After Single Scan LOV
    wild := value;

-- Bug 4958763.  SQL Repository Fix SQL ID: 15009209
/*
    sql_string := 'SELECT cc.name, cc.description
                   FROM   cs_counters cc, cs_counter_groups ccg
                   WHERE  cc.counter_group_id = ccg.counter_group_id
                   AND    ccg.template_flag = ''N''
                   AND    cc.name like :1
                   ORDER BY 1';
*/
    sql_string := 'SELECT name, description
                   FROM csi_counters_vl
                   WHERE name like :1
                   AND trunc(sysdate) BETWEEN nvl(start_date_active, trunc(sysdate))
                                       AND  nvl(end_date_active, trunc(sysdate))
                   ORDER BY 1';

    OPEN x_ref FOR sql_string USING wild;

END get_counter_name_lov;


PROCEDURE get_maintenance_req_lov (value IN VARCHAR2, x_ref OUT NOCOPY LovRefCursor) IS

    wild VARCHAR2(160);
    sql_string VARCHAR2(1500);

BEGIN

/*  Before Single Scan LOV
    IF value IS NULL THEN
        wild := '%';
    ELSE
        wild := value || '%';
    END IF; */

    -- After Single Scan LOV
    wild := value;

    sql_string := 'SELECT title, version_number
                   FROM   qa_ahl_mr
                   WHERE title like :1
                   ORDER BY 1';

    OPEN x_ref FOR sql_string USING wild;

END get_maintenance_req_lov;


PROCEDURE get_service_request_lov (value IN VARCHAR2, x_ref OUT NOCOPY LovRefCursor) IS

    wild VARCHAR2(160);
    sql_string VARCHAR2(1500);

BEGIN

/*  Before Single Scan LOV
    IF value IS NULL THEN
        wild := '%';
    ELSE
        wild := value || '%';
    END IF; */

    -- After Single Scan LOV
    wild := value;

    sql_string := 'SELECT incident_number, summary
                   FROM   cs_incidents
                   WHERE  incident_number like :1
                   ORDER BY 1';

    OPEN x_ref FOR sql_string USING wild;

END get_service_request_lov;


PROCEDURE get_rework_job_lov (org_id IN NUMBER, value IN VARCHAR2,
    x_ref OUT NOCOPY LovRefCursor) IS

    wild VARCHAR2(160);
    sql_string VARCHAR2(1500);

BEGIN

/*  Before Single Scan LOV
    IF value IS NULL THEN
        wild := '%';
    ELSE
        wild := value || '%';
    END IF; */

    -- After Single Scan LOV
    wild := value;

    sql_string := 'SELECT wip_entity_name, description
                   FROM   wip_discrete_jobs_all_v
                   WHERE  wip_entity_name like :1 AND
                          organization_id = :2
                   ORDER BY wip_entity_name';
    OPEN x_ref FOR sql_string USING wild, org_id;

END get_rework_job_lov;

--
-- End of inclusions for ASO project
-- rkunchal Thu Jul 25 01:43:48 PDT 2002
--

-- Start of inclusions for NCM Hardcode Elements.
-- suramasw Thu Oct 31 10:48:59 PST 2002.
-- Bug 2449067.


PROCEDURE get_bill_reference_lov (x_org_id IN NUMBER, value IN VARCHAR2,
    x_ref OUT NOCOPY LovRefCursor) IS

    wild VARCHAR2(160);
    sql_string VARCHAR2(1500);

BEGIN

/*  Before Single Scan LOV
    IF value IS NULL THEN
        wild := '%';
    ELSE
        wild := value || '%';
    END IF; */

    -- After Single Scan LOV
    wild := value;

    sql_string := 'SELECT concatenated_segments, description
                   FROM   mtl_system_items_kfv
                   WHERE  organization_id = :1
                   AND    concatenated_segments like :2
                   ORDER BY concatenated_segments';

    OPEN x_ref FOR sql_string USING x_org_id, wild;

END get_bill_reference_lov;

PROCEDURE get_routing_reference_lov (x_org_id IN NUMBER, value IN VARCHAR2,
    x_ref OUT NOCOPY LovRefCursor) IS

    wild VARCHAR2(160);
    sql_string VARCHAR2(1500);

BEGIN

/*  Before Single Scan LOV
    IF value IS NULL THEN
        wild := '%';
    ELSE
        wild := value || '%';
    END IF; */

    -- After Single Scan LOV
    wild := value;

    sql_string := 'SELECT concatenated_segments, description
                   FROM   mtl_system_items_kfv
                   WHERE  organization_id = :1
                   AND    concatenated_segments like :2
                   ORDER BY concatenated_segments';

    OPEN x_ref FOR sql_string USING x_org_id, wild;

END get_routing_reference_lov;

PROCEDURE get_to_locator_lov (x_org_id IN NUMBER, x_item_name IN VARCHAR2,
    value IN VARCHAR2, x_ref OUT NOCOPY LovRefCursor) IS

    wild VARCHAR2(160);
    sql_string VARCHAR2(1500);

BEGIN

/*  Before Single Scan LOV
    IF value IS NULL THEN
        wild := '%';
    ELSE
        wild := value || '%';
    END IF; */

    -- After Single Scan LOV
    wild := value;

    sql_string := 'SELECT concatenated_segments, description
                   FROM   mtl_item_locations_kfv
                   WHERE  organization_id = :1
                   AND    concatenated_segments like :2
                   ORDER BY concatenated_segments';

    OPEN x_ref FOR sql_string USING x_org_id, wild;

END get_to_locator_lov;

PROCEDURE get_to_subinventory_lov (x_org_id IN NUMBER, value IN VARCHAR2,
    x_ref OUT NOCOPY LovRefCursor) IS

    wild VARCHAR2(160);
    sql_string VARCHAR2(1500);

BEGIN

/*  Before Single Scan LOV
    IF value IS NULL THEN
        wild := '%';
    ELSE
        wild := value || '%';
    END IF; */

    -- After Single Scan LOV
    wild := value;

    sql_string := 'SELECT secondary_inventory_name, description
                   FROM   mtl_secondary_inventories
                   WHERE  organization_id = :1
                   AND    nvl(disable_date, sysdate+1) > sysdate
                   AND    secondary_inventory_name like :2
                   ORDER BY secondary_inventory_name';

    OPEN x_ref FOR sql_string USING x_org_id, wild;

END get_to_subinventory_lov;

PROCEDURE get_lot_status_lov (x_org_id IN NUMBER, x_lot_num IN VARCHAR2,
    x_item_name IN VARCHAR2, value IN VARCHAR2,
    x_ref OUT NOCOPY LovRefCursor) IS

    wild VARCHAR2(160);
    sql_string VARCHAR2(1500);

    x_item_id NUMBER;

BEGIN

/* Before Single Scan LOV
   IF value IS NULL THEN
      wild := '%';
   ELSE
      wild := value || '%';
   END IF; */

    -- After Single Scan LOV
    wild := value;

    x_item_id := qa_flex_util.get_item_id(x_org_id, x_item_name);

    -- Added the organization_id condition in the following select statement.
    -- Bug 2686970. suramasw Wed Nov 27 04:45:34 PST 2002.

    sql_string := 'SELECT mms.status_code, mms.description
                   FROM mtl_lot_numbers mln, mtl_material_statuses mms
                   WHERE mln.inventory_item_id = :1
                   AND mln.organization_id = :2
                   AND mln.lot_number like :3
                   AND mln.status_id = mms.status_id
                   AND mms.status_code like :4
                   AND mms.enabled_flag = 1';

    OPEN x_ref FOR sql_string USING x_item_id, x_org_id, x_lot_num, wild;

END get_lot_status_lov;

FUNCTION get_lot_status_id (value IN VARCHAR2)
    RETURN NUMBER IS

    id NUMBER;

    CURSOR c (code VARCHAR2) IS
       SELECT status_id
       FROM mtl_material_statuses
       WHERE status_code = code;

BEGIN

   IF value IS NULL THEN
        RETURN NULL;
    END IF;

    OPEN c(value);
    FETCH c INTO id;
    CLOSE c;

    RETURN id;

END get_lot_status_id;

PROCEDURE get_serial_status_lov (x_org_id IN NUMBER, x_serial_num IN VARCHAR2,
    x_item_name IN VARCHAR2, value IN VARCHAR2,
    x_ref OUT NOCOPY LovRefCursor) IS

    wild VARCHAR2(160);
    sql_string VARCHAR2(1500);

    x_item_id NUMBER;

BEGIN

/*  Before Single Scan LOV
    IF value IS NULL THEN
        wild := '%';
    ELSE
        wild := value || '%';
    END IF; */

    -- After Single Scan LOV
    wild := value;

    x_item_id := qa_flex_util.get_item_id(x_org_id, x_item_name);

    sql_string := 'SELECT mms.status_code, mms.description
                   FROM mtl_serial_numbers msn, mtl_material_statuses mms
                   WHERE msn.inventory_item_id = :1
                   AND msn.serial_number like :2
                   AND msn.status_id = mms.status_id
                   AND mms.status_code like :3
                   AND mms.enabled_flag = 1';

    OPEN x_ref FOR sql_string USING x_item_id, x_serial_num, wild;

END get_serial_status_lov;

-- R12 OPM Deviations. Bug 4345503 Start
PROCEDURE get_process_batch_num_lov
(p_org_id IN NUMBER,
 value IN VARCHAR2,
 x_ref OUT NOCOPY LovRefCursor) IS

  wild VARCHAR2(160);
  sql_string VARCHAR2(1500);
BEGIN
  wild := value||'%';

  sql_string := 'SELECT BATCH_NO, BATCH_NO BATCH_DESC '||
                'FROM GME_BATCH_HEADER '||
                'WHERE BATCH_NO like :1 '||
                'AND (ORGANIZATION_ID = :2 '||
                ' or ORGANIZATION_ID IS NULL)';

  OPEN x_ref FOR sql_string USING wild,p_org_id;

END get_process_batch_num_lov;

PROCEDURE get_process_batchstep_num_lov
(p_org_id IN NUMBER,
 p_process_batch_num IN VARCHAR2,
 value IN VARCHAR2,
 x_ref OUT NOCOPY LovRefCursor) IS

  wild VARCHAR2(160);
  sql_string VARCHAR2(1500);
  l_batch_id NUMBER;
BEGIN
  l_batch_id := get_process_batch_id(p_process_batch_num, p_org_id);
  wild := value;
  sql_string := 'SELECT STEPS.BATCHSTEP_NO,OPS.OPRN_DESC BATCHSTEP_DESC '||
                'FROM GME_BATCH_STEPS STEPS, GMD_OPERATIONS OPS '||
                'WHERE STEPS.BATCHSTEP_NO like :1 '||
                'AND STEPS.BATCH_ID =:2 '||
                'AND STEPS.OPRN_ID = OPS.OPRN_ID';

  OPEN x_ref FOR sql_string USING wild, l_batch_id;

END get_process_batchstep_num_lov;

PROCEDURE get_process_operation_lov
(p_org_id IN NUMBER,
 p_process_batch_num IN VARCHAR2,
 p_process_batchstep_num IN NUMBER,
 value IN VARCHAR2,
 x_ref OUT NOCOPY LovRefCursor) IS

  wild VARCHAR2(160);
  sql_string VARCHAR2(1500);
  l_batch_id NUMBER;
  l_batchstep_id NUMBER;
BEGIN
  l_batch_id := get_process_batch_id(p_process_batch_num, p_org_id);
  l_batchstep_id := get_process_batchstep_id(p_process_batchstep_num, l_batch_id);
  wild := value;

  sql_string := 'SELECT OPERATION PROCESS_OPERATION, OPRN_DESC '||
                'FROM GMO_BATCH_STEPS_V	'||
                'WHERE OPERATION like :1 '||
                'AND BATCHSTEP_ID = :2 '||
                'AND BATCH_ID =:3';

  OPEN x_ref FOR sql_string USING wild, l_batchstep_id, l_batch_id;

END get_process_operation_lov;

PROCEDURE get_process_activity_lov
(p_org_id IN NUMBER,
 p_process_batch_num IN VARCHAR2,
 p_process_batchstep_num IN NUMBER,
 value IN VARCHAR2,
 x_ref OUT NOCOPY LovRefCursor) IS

  wild VARCHAR2(160);
  sql_string VARCHAR2(1500);
  l_batch_id NUMBER;
  l_batchstep_id NUMBER;
  l_activity_id NUMBER;
BEGIN
  l_batch_id := get_process_batch_id(p_process_batch_num, p_org_id);
  l_batchstep_id := get_process_batchstep_id(p_process_batchstep_num, l_batch_id);
  wild := value;

  sql_string := 'SELECT STEPS.ACTIVITY,ACTIVITIES.ACTIVITY_DESC '||
                'FROM GME_BATCH_STEP_ACTIVITIES STEPS, GMD_ACTIVITIES ACTIVITIES '||
                'WHERE STEPS.ACTIVITY like :1 '||
                'AND STEPS.BATCHSTEP_ID =:2 '||
                'AND STEPS.BATCH_ID =:3 '||
                'AND STEPS.ACTIVITY = ACTIVITIES.ACTIVITY';

  OPEN x_ref FOR sql_string USING wild, l_batchstep_id, l_batch_id;

END get_process_activity_lov;

PROCEDURE get_process_resource_lov
(p_org_id IN NUMBER,
 p_process_batch_num IN VARCHAR2,
 p_process_batchstep_num IN NUMBER,
 p_process_activity IN VARCHAR2,
 value IN VARCHAR2,
 x_ref OUT NOCOPY LovRefCursor) IS

  wild VARCHAR2(160);
  sql_string VARCHAR2(1500);
  l_batch_id NUMBER;
  l_batchstep_id NUMBER;
  l_activity_id NUMBER;
BEGIN
  l_batch_id := get_process_batch_id(p_process_batch_num, p_org_id);
  l_batchstep_id := get_process_batchstep_id(p_process_batchstep_num, l_batch_id);
  l_activity_id := get_process_activity_id(p_process_activity, l_batch_id, l_batchstep_id);
  wild := value;

  sql_string := 'SELECT GBSR.RESOURCES, CRMV.RESOURCE_DESC '||
                'FROM GME_BATCH_STEP_RESOURCES GBSR, CR_RSRC_MST_VL CRMV '||
                'WHERE GBSR.RESOURCES like :1 '||
                'AND GBSR.BATCHSTEP_ACTIVITY_ID =:2 '||
                'AND GBSR.BATCHSTEP_ID =:3 '||
                'AND GBSR.BATCH_ID =:4 '||
                'AND GBSR.RESOURCES = CRMV.RESOURCES';

  OPEN x_ref FOR sql_string USING wild, l_activity_id, l_batchstep_id, l_batch_id;

END get_process_resource_lov;

PROCEDURE get_process_parameter_lov
(p_org_id IN NUMBER,
 p_process_resource IN VARCHAR2,
 value IN VARCHAR2,
 x_ref OUT NOCOPY LovRefCursor) IS

  wild VARCHAR2(160);
  sql_string VARCHAR2(1500);
BEGIN
  wild := value;

  sql_string := 'SELECT GP.PARAMETER_NAME, GP.PARAMETER_DESCRIPTION '||
                'FROM GMP_PROCESS_PARAMETERS GP,GME_PROCESS_PARAMETERS GE '||
                'WHERE GE.RESOURCES = :1 '||
                'AND GE.PARAMETER_ID = GP.PARAMETER_ID '||
                'AND GP.PARAMETER_NAME like :2';

  OPEN x_ref FOR sql_string USING p_process_resource, wild;

END get_process_parameter_lov;

-- R12 OPM Deviations. Bug 4345503 End

/* R12 DR Integration. Bug 4345489 Start */

PROCEDURE get_repair_number_lov (value IN VARCHAR2,
                                 x_ref OUT     NOCOPY LovRefCursor) IS

    wild VARCHAR2(160);
    sql_string VARCHAR2(1500);

BEGIN

    wild := value;

    sql_string := 'SELECT repair_number, problem_description
                   FROM   csd_repairs
                   WHERE  repair_number like :1
		   and status not in (''C'', ''H'')
                   ORDER BY repair_number';

    OPEN x_ref FOR sql_string USING wild;

END get_repair_number_lov;

PROCEDURE get_jtf_task_lov (value IN VARCHAR2, x_ref OUT
    NOCOPY LovRefCursor) IS

 wild VARCHAR2(160);
    sql_string VARCHAR2(1500);

BEGIN

    wild := value;

    sql_string := 'SELECT task_number, task_name
                   FROM jtf_tasks_vl
                   WHERE  task_number like :1
                   ORDER BY task_number';

    OPEN x_ref FOR sql_string USING wild;

END get_jtf_task_lov;

/* R12 DR Integration. Bug 4345489 End */

FUNCTION get_serial_status_id (value IN VARCHAR2)
    RETURN NUMBER IS

    id NUMBER;

    CURSOR c (code VARCHAR2) IS
       SELECT status_id
       FROM mtl_material_statuses
       WHERE status_code = code;

BEGIN

   IF value IS NULL THEN
        RETURN NULL;
    END IF;

    OPEN c(value);
    FETCH c INTO id;
    CLOSE c;

    RETURN id;

END get_serial_status_id;

-- End of inclusions for NCM Hardcode Elements.


PROCEDURE get_item_lov (x_org_id IN NUMBER, value IN VARCHAR2,
    x_ref OUT NOCOPY LovRefCursor) IS

    wild VARCHAR2(160);
    sql_string VARCHAR2(1500);

BEGIN

/*  Before Single Scan LOV
    IF value IS NULL THEN
        wild := '%';
    ELSE
        wild := value || '%';
    END IF; */

    -- After Single Scan LOV
    wild := value;

    sql_string := 'SELECT concatenated_segments, description
                   FROM   mtl_system_items_kfv
                   WHERE  organization_id = :1
                   AND    concatenated_segments like :2
                   ORDER BY concatenated_segments';

    OPEN x_ref FOR sql_string USING x_org_id, wild;

END get_item_lov;


--
-- Bug 5292020 adding comp item LOV to mqa.
-- comp item LOVs have three variants depending on what is
-- present in the collection plan.  Hence this LOV contains
-- 3 SQLs selected depending on the input param.  All SQLs
-- adapted from flex field definition in QLTRES.pld.
-- bso Thu Jun  8 00:16:03 PDT 2006
--
PROCEDURE get_comp_item_lov(
    p_org_id IN NUMBER,
    p_item_name IN VARCHAR2,
    p_job_name IN VARCHAR2,
    p_prod_line IN VARCHAR2,
    p_value IN VARCHAR2,
    x_ref OUT NOCOPY LovRefCursor) IS

    l_sql_string VARCHAR2(1500);
    l_job_id NUMBER;
    l_prod_line_id NUMBER;
    l_item_id NUMBER;

BEGIN

    IF p_item_name IS NOT NULL THEN
        l_item_id := qa_flex_util.get_item_id(p_org_id, p_item_name);
    END IF;

    IF p_job_name IS NOT NULL THEN
        l_job_id := get_job_id(p_org_id, p_job_name);
    END IF;

    IF p_prod_line IS NOT NULL THEN
        l_prod_line_id := get_production_line_id(p_org_id, p_prod_line);
    END IF;

    IF l_job_id IS NOT NULL THEN
        --
        -- Comp Item with WIP Job dependency.
        --
        l_sql_string :=
            'SELECT concatenated_segments, description
             FROM   mtl_system_items_kfv
             WHERE  organization_id = :1 AND
                    concatenated_segments like :2 AND
                    inventory_item_id IN (
                    SELECT inventory_item_id
                    FROM   wip_requirement_operations
                    WHERE  wip_entity_id = :3 AND
                           organization_id = :4)';
        OPEN x_ref FOR l_sql_string USING p_org_id, p_value, l_job_id,
            p_org_id;

    ELSIF l_prod_line_id IS NOT NULL AND l_item_id IS NOT NULL THEN
        --
        -- Comp Item with Flow Production Line dependency.
        --
        l_sql_string :=
            'SELECT concatenated_segments, description
             FROM   mtl_system_items_kfv
             WHERE  organization_id = :1 AND
                    concatenated_segments like :2 AND
                    inventory_item_id IN (
                    SELECT inventory_item_id
                    FROM   wip_requirement_operations
                    WHERE  wip_entity_id = (
                           SELECT wip_entity_id
                           FROM   wip_repetitive_items
                           WHERE  line_id = :3 AND
                                  primary_item_id = :4 AND
                                  organization_id = :5))';
        OPEN x_ref FOR l_sql_string USING p_org_id, p_value, l_prod_line_id,
            l_item_id, p_org_id;
    ELSIF l_item_id IS NOT NULL THEN
        --
        -- Comp Item with BOM Component Dependency.
        --
        l_sql_string :=
            'SELECT concatenated_segments, description
             FROM   mtl_system_items_kfv
             WHERE  organization_id = :1 AND
                    concatenated_segments like :2 AND
                    inventory_item_id IN (
                    SELECT bic.component_item_id
                    FROM   bom_inventory_components bic,
                           bom_bill_of_materials bom
                    WHERE  bic.bill_sequence_id = bom.bill_sequence_id AND
                           bic.effectivity_date <= sysdate AND
                           nvl(bic.disable_date, sysdate+1) > sysdate AND
                           bom.assembly_item_id = :3 AND
                           bom.organization_id = :4)';
        OPEN x_ref FOR l_sql_string USING p_org_id, p_value, l_item_id,
            p_org_id;
    ELSE
        --
        -- This is a catchall SQL that returns no value.
        --
        l_sql_string := 'SELECT ''x'', ''x'' FROM dual WHERE 1 = 2';
        open x_ref FOR l_sql_string;
    END IF;

END get_comp_item_lov;


PROCEDURE get_asset_group_lov (x_org_id IN NUMBER, value IN VARCHAR2,
    x_ref OUT NOCOPY LovRefCursor) IS

    wild VARCHAR2(160);
    sql_string VARCHAR2(1500);

BEGIN

/*  Before Single Scan LOV
    IF value IS NULL THEN
        wild := '%';
    ELSE
        wild := value || '%';
    END IF; */

    -- After Single Scan LOV
    wild := value;

    --dgupta: Start R12 EAM Integration. Bug 4345492
    sql_string := 'select distinct msikfv.concatenated_segments, msikfv.description
                    from mtl_system_items_b_kfv msikfv, mtl_parameters mp
                    where msikfv.organization_id = mp.organization_id
                    and msikfv.eam_item_type in (1,3)
                    and mp.maint_organization_id = :1
                    and msikfv.concatenated_segments like :2
                    order by msikfv.concatenated_segments';
    --dgupta: End R12 EAM Integration. Bug 4345492

    OPEN x_ref FOR sql_string USING x_org_id, wild;

END get_asset_group_lov;



--dgupta: Start R12 EAM Integration. Bug 4345492
PROCEDURE get_asset_activity_lov (x_org_id IN NUMBER, p_asset_group IN VARCHAR2,
	  p_asset_number IN VARCHAR2, p_asset_instance_number IN VARCHAR2, value IN VARCHAR2,
	  x_ref OUT NOCOPY LovRefCursor) IS

    wild VARCHAR2(160);
    sql_string VARCHAR2(1500);
    l_asset_group_id NUMBER DEFAULT NULL;
    l_asset_instance_id NUMBER DEFAULT NULL;

BEGIN

    -- After Single Scan LOV
    wild := value;

    l_asset_group_id := get_asset_group_id(x_org_id, p_asset_group);
    l_asset_instance_id := get_asset_instance_id(p_asset_instance_number);
    if (l_asset_instance_id is null) then
      l_asset_instance_id := get_asset_instance_id(l_asset_group_id, p_asset_number);
    end if;

    if (p_asset_number is null  and l_asset_instance_id is null) then
    -- show all activities asssociated to the asset group
    -- If no match found or if asset group passed in is null, lov is empty
/*
    	sql_string := 'SELECT meaav.activity, meaav.activity_description
         FROM   mtl_eam_asset_activities_v meaav, mtl_system_items_b msib
         WHERE  msib.organization_id = :1
         and meaav. maintenance_object_id = :2 --pass asset group inventory_item_id
  		   and (meaav.end_date_active is null or meaav.end_date_active > sysdate)
  		   and (meaav.start_date_active is null or meaav.start_date_active < sysdate)
         and msib.inventory_item_id = meaav. maintenance_object_id
  		   and meaav.maintenance_object_type = 2  --non serialized item
         AND meaav.activity like :3
         ORDER BY meaav.activity';
*/
       -- Bug 4958763. SQL Repository Fix SQL ID: 15009272
       sql_string := 'SELECT
                    msib.concatenated_segments activity ,
                    msib.description activity_description
                FROM mtl_eam_asset_activities meaav,
                    mtl_system_items_b_kfv msib
                WHERE msib.organization_id = :1
                    AND meaav. maintenance_object_id = :2 --pass asset group inventory_item_id
                    AND (meaav.end_date_active is null
                         OR meaav.end_date_active > sysdate)
                    AND (meaav.start_date_active is null
                         OR meaav.start_date_active < sysdate)
                    AND msib.inventory_item_id = meaav.asset_activity_id
                    AND meaav.maintenance_object_type = 2 --non serialized item
                    AND msib.concatenated_segments like :3
                ORDER BY msib.concatenated_segments';

    	OPEN x_ref FOR sql_string USING x_org_id, l_asset_group_id, wild;
    else
    -- show all activities associated to asset group and asset number
    -- if exact match not found, lov is empty.
/*
    	sql_string := 'SELECT meaav.activity, meaav.activity_description
         FROM   mtl_eam_asset_activities_v meaav, mtl_system_items_b msib
         WHERE  msib.organization_id = :1
  		   and meaav.maintenance_object_id = :2 --pass asset instance_id
  		   and meaav.maintenance_object_type = 3  --serialized item
  		   and (meaav.end_date_active is null or meaav.end_date_active > sysdate)
  		   and (meaav.start_date_active is null or meaav.start_date_active < sysdate)
         and msib.inventory_item_id = meaav.inventory_item_id
         AND meaav.activity like :3
         ORDER BY meaav.activity';
*/
        -- Bug 4958763. SQL Repository Fix SQL ID: 15009282
        sql_string := 'SELECT
                            msi.concatenated_segments activity ,
                            msi.description activity_description
                        FROM mtl_eam_asset_activities meaa,
                            mtl_system_items_b_kfv msi
                        WHERE msi.organization_id = :1
                            AND meaa.maintenance_object_id = :2 --pass asset instance_id
                            AND meaa.maintenance_object_type = 3 --serialized item
                            AND (meaa.end_date_active is null
                                 OR meaa.end_date_active > sysdate)
                            AND (meaa.start_date_active is null
                                 OR meaa.start_date_active < sysdate)
                            AND msi.inventory_item_id = meaa.asset_activity_id
                            AND msi.concatenated_segments like :3
                        ORDER BY msi.concatenated_segments';

      OPEN x_ref FOR sql_string USING x_org_id,  l_asset_instance_id, wild;
    end if;

END get_asset_activity_lov;

-- added the following to include new hardcoded element followup activity
-- saugupta Aug 2003
--dgupta: just call asset activity lov, since query is same
PROCEDURE get_followup_activity_lov (x_org_id IN NUMBER, p_asset_group IN VARCHAR2,
	  p_asset_number IN VARCHAR2, p_asset_instance_number IN VARCHAR2, value IN VARCHAR2,
	  x_ref OUT NOCOPY LovRefCursor) IS
BEGIN
  get_asset_activity_lov(x_org_id, p_asset_group, p_asset_number, p_asset_instance_number,
    value, x_ref); --no use duplicating code
END get_followup_activity_lov;

--dgupta: End R12 EAM Integration. Bug 4345492

PROCEDURE get_locator_lov (x_org_id IN NUMBER, x_item_name IN VARCHAR2,
    value IN VARCHAR2, x_ref OUT NOCOPY LovRefCursor) IS

    wild VARCHAR2(160);
    sql_string VARCHAR2(1500);

BEGIN

/*  Before Single Scan LOV
    IF value IS NULL THEN
        wild := '%';
    ELSE
        wild := value || '%';
    END IF; */

    -- After Single Scan LOV
    wild := value;

    sql_string := 'SELECT concatenated_segments, description
                   FROM   mtl_item_locations_kfv
                   WHERE  organization_id = :1
                   AND    concatenated_segments like :2
                   ORDER BY concatenated_segments';

    OPEN x_ref FOR sql_string USING x_org_id, wild;

END get_locator_lov;

--
-- Removed the DEFAULT clause to make the code GSCC compliant
-- List of changed arguments.
-- Old
--    user_id IN NUMBER DEFAULT NULL
--    value IN VARCHAR2 DEFAULT NULL
-- New
--     user_id IN NUMBER
--     value IN VARCHAR2
--

PROCEDURE get_plan_element_lov(plan_id IN NUMBER, char_id IN NUMBER,
    org_id IN NUMBER, user_id IN NUMBER,
    value IN VARCHAR2,
    x_ref OUT NOCOPY LovRefCursor) IS

BEGIN

    -- The function sql_string_exists simple checks to see
    -- if the user defined element should have a LOV
    -- associated with it or not. If it should then it returns
    -- true and populates sql_string - an out parameter.

    IF sql_string_exists(plan_id, char_id, org_id, user_id, value, x_ref) THEN
        RETURN;
    ELSE
    --
    -- To prevent client from bombing, open an empty cursor in case
    -- this function if called but there is no LOV!
    --
        OPEN x_ref FOR
        SELECT 'x', 'x' FROM dual WHERE 1 = 2;
    END IF;

END get_plan_element_lov;


PROCEDURE get_spec_details ( x_spec_id IN NUMBER, x_char_id IN NUMBER,
    x_target_value              OUT NOCOPY VARCHAR2,
    x_lower_spec_limit          OUT NOCOPY VARCHAR2,
    x_upper_spec_limit          OUT NOCOPY VARCHAR2,
    x_lower_user_defined_limit  OUT NOCOPY VARCHAR2,
    x_upper_user_defined_limit  OUT NOCOPY VARCHAR2,
    x_lower_reasonable_limit    OUT NOCOPY VARCHAR2,
    x_upper_reasonable_limit    OUT NOCOPY VARCHAR2) IS

    CURSOR c IS
        SELECT
            target_value,
            lower_spec_limit,
            upper_spec_limit,
            lower_user_defined_limit,
            upper_user_defined_limit,
            lower_reasonable_limit,
            upper_reasonable_limit
        FROM    qa_spec_chars
        WHERE   spec_id = x_spec_id
        AND     char_id = x_char_id;

BEGIN

    OPEN c;
    FETCH c INTO        x_target_value,
                        x_lower_spec_limit,
                        x_upper_spec_limit,
                        x_lower_user_defined_limit,
                        x_upper_user_defined_limit,
                        x_lower_reasonable_limit,
                        x_upper_reasonable_limit;
    CLOSE c;

    x_target_value              := nvl(x_target_value, ' ');
    x_lower_spec_limit          := nvl(x_lower_spec_limit, ' ');
    x_upper_spec_limit          := nvl(x_upper_spec_limit, ' ');
    x_lower_user_defined_limit  := nvl(x_lower_user_defined_limit, ' ');
    x_upper_user_defined_limit  := nvl(x_upper_user_defined_limit, ' ');
    x_lower_reasonable_limit    := nvl(x_lower_reasonable_limit, ' ');
    x_upper_reasonable_limit    := nvl(x_upper_reasonable_limit, ' ');

END get_spec_details;


PROCEDURE get_spec_sub_type (x_spec_id IN NUMBER,
    x_element_name OUT NOCOPY VARCHAR2) IS

    CURSOR c IS
        SELECT name
        FROM qa_chars
        WHERE char_id =
                ( SELECT char_id
                  FROM   qa_specs
                  WHERE  spec_id = x_spec_id );

BEGIN

    OPEN c;
    FETCH c INTO x_element_name;
    CLOSE c;

    x_element_name := nvl(x_element_name, ' ');

END get_spec_sub_type;


PROCEDURE get_spec_type (p_spec_id IN NUMBER,
    x_spec_type OUT NOCOPY VARCHAR2) IS

    CURSOR c IS
        SELECT meaning
        FROM mfg_lookups
        WHERE lookup_type = 'QA_SPEC_TYPE'
        AND   lookup_code =
                ( SELECT assignment_type
                  FROM   qa_specs
                  WHERE  spec_id = p_spec_id );

BEGIN

    OPEN c;
    FETCH c INTO x_spec_type;
    CLOSE c;

END get_spec_type;


PROCEDURE get_item_name (p_spec_id IN NUMBER,
    x_item_name OUT NOCOPY VARCHAR2) IS

    CURSOR c IS
        SELECT organization_id, item_id
        FROM   qa_specs
        WHERE  spec_id = p_spec_id;

    l_org_id  NUMBER;
    l_item_id NUMBER;

BEGIN

    OPEN c;
    FETCH c INTO l_org_id, l_item_id;
    CLOSE c;

    x_item_name := QA_FLEX_UTIL.item(l_org_id, l_item_id);

END get_item_name;


PROCEDURE get_supplier_name (p_spec_id IN NUMBER,
    x_supplier_name OUT NOCOPY VARCHAR2) IS

    CURSOR c IS
        SELECT vendor_name
        FROM po_vendors
        WHERE vendor_id =
                ( SELECT vendor_id
                  FROM   qa_specs
                  WHERE  spec_id = p_spec_id );

BEGIN

    OPEN c;
    FETCH c INTO x_supplier_name;
    CLOSE c;

END get_supplier_name;


PROCEDURE get_customer_name (p_spec_id IN NUMBER,
    x_customer_name OUT NOCOPY VARCHAR2) IS

    CURSOR c IS
        SELECT customer_name
        FROM qa_customers_lov_v
        WHERE customer_id =
                ( SELECT customer_id
                  FROM   qa_specs
                  WHERE  spec_id = p_spec_id );

BEGIN

    OPEN c;
    FETCH c INTO x_customer_name;
    CLOSE c;

END get_customer_name;


FUNCTION context_element (element_id IN NUMBER, txn_number IN NUMBER)
    RETURN BOOLEAN IS

    result BOOLEAN;
    dummy NUMBER;

    CURSOR c IS
        SELECT 1
        FROM   qa_txn_collection_triggers qtct
        WHERE  qtct.transaction_number = txn_number
        AND    qtct.collection_trigger_id = element_id;

BEGIN

    -- This function determines if collection element is a context element
    -- given a transaction number.

    OPEN c;
    FETCH c INTO dummy;
    result := c%FOUND;
    CLOSE c;

    RETURN result;

END context_element;

--dgupta: Start R12 EAM Integration. Bug 4345492
FUNCTION get_asset_instance_id (value IN VARCHAR2)
    RETURN NUMBER IS

    id          NUMBER;
   --Instance Number was already validated for eam restrictions
   --Following sql returns 1 row as there is unique index on instance_number
    CURSOR c (i_num VARCHAR2) IS
        SELECT cii.instance_id
        FROM csi_item_instances cii
        WHERE cii.instance_number = i_num;

BEGIN

    IF value IS NULL THEN
        RETURN NULL;
    END IF;

    OPEN c(value);
    FETCH c INTO id;
    CLOSE c;

    RETURN id;

END get_asset_instance_id;

FUNCTION get_asset_instance_id (p_asset_group_id IN NUMBER, p_asset_number IN VARCHAR2)
    RETURN NUMBER IS

    id          NUMBER;
   --Asset Group and Asset Number were already validated for eam restrictions
    CURSOR c (org_id NUMBER, asset_group VARCHAR2) IS
        SELECT cii.instance_id
        FROM csi_item_instances cii
        WHERE cii.inventory_item_id = p_asset_group_id
        AND cii.serial_number = p_asset_number; --inv id and serial num combo is unique

BEGIN

    IF ((p_asset_group_id IS NULL) OR (p_asset_number is NULL)) THEN
        RETURN NULL;
    END IF;

    OPEN c(p_asset_group_id, p_asset_number);
    FETCH c INTO id;
    CLOSE c;

    RETURN id;

END get_asset_instance_id;


FUNCTION get_asset_group_id (org_id IN NUMBER, value IN VARCHAR2)
    RETURN NUMBER IS

    id          NUMBER;
   --rownum=1 =>better performance since all rows have same inventory_item_id
    CURSOR c (o_id NUMBER, a_group VARCHAR2) IS
        SELECT msikfv.inventory_item_id
        FROM mtl_system_items_b_kfv msikfv, mtl_parameters mp
        WHERE msikfv.organization_id = mp.organization_id
        and msikfv.eam_item_type in (1,3)
        and mp.maint_organization_id = o_id
        and msikfv.concatenated_segments = a_group
        and rownum=1;

BEGIN

    IF value IS NULL THEN
        RETURN NULL;
    END IF;

    OPEN c(org_id, value);
    FETCH c INTO id;
    CLOSE c;

    RETURN id;

END get_asset_group_id;

--dgupta: End R12 EAM Integration. Bug 4345492

 -- Bug 4519558. OA Framework integration project. UT bug fix.
 -- Transaction type element was erroring out for WIP transactions.
 -- New function to validate "Transaction Type".
 -- srhariha.Tue Aug  2 00:43:07 PDT 2005.
 FUNCTION validate_transaction_type(p_transaction_number IN NUMBER,
                                    p_org_id IN NUMBER,
                                    p_user_id IN NUMBER,
                                    p_value IN VARCHAR2)
                                          RETURN BOOLEAN IS

   CURSOR C4 IS
   SELECT 1
   FROM MTL_TRANSACTION_TYPES
   WHERE transaction_source_type_id = 5
   AND transaction_action_id in (31,32)
   AND transaction_type_name = p_value;

   CURSOR C22 IS
   SELECT 1
   FROM MTL_TRANSACTION_TYPES
   WHERE transaction_source_type_id = 5
   AND transaction_action_id in (30,31,32)
   AND transaction_type_name = p_value;

   CURSOR C1 IS
   SELECT 1
   FROM MFG_LOOKUPS
   WHERE lookup_type ='WIP_MOVE_TRANSACTION_TYPE'
   AND meaning = p_value;

   CURSOR C_MOBILE(p_lookup_type VARCHAR2) IS
   SELECT 1
   FROM QA_LOOKUPS
   WHERE lookup_type = p_lookup_type
   AND lookup_code = p_value;

   l_temp NUMBER;
   result BOOLEAN;
   sql_string QA_CHARS.SQL_VALIDATION_STRING%TYPE;

 BEGIN
   IF p_transaction_number = qa_ss_const.wip_completion_txn THEN
      OPEN C4;
      FETCH C4 INTO l_temp;
      result := C4%FOUND;
      CLOSE C4;

   ELSIF p_transaction_number = qa_ss_const.flow_work_order_less_txn THEN
      OPEN C22;
      FETCH C22 INTO l_temp;
      result := C22%FOUND;
      CLOSE C22;

   ELSIF p_transaction_number = qa_ss_const.wip_move_txn THEN
      OPEN C1;
      FETCH C1 INTO l_temp;
      result := C1%FOUND;
      CLOSE C1;

  -- Bug 4519558.OA Framework Integration project. UT bug fix.
  -- Incorporating Bryan's code review comments. Use new
  -- method in qa_mqa_mwa_api package.
  -- srhariha. Mon Aug 22 02:50:35 PDT 2005.

   ELSIF qa_mqa_mwa_api.is_mobile_txn(p_transaction_number) = fnd_api.g_true THEN
      OPEN C_MOBILE(qa_ss_const.mob_txn_lookup_prefix || to_char(p_transaction_number));
      FETCH C_MOBILE INTO l_temp;
      result := C_MOBILE%FOUND;
      CLOSE C_MOBILE;

   ELSE

     sql_string := get_sql_validation_string(qa_ss_const.transaction_type);


     sql_string := qa_chars_api.format_sql_for_validation (sql_string,
        p_org_id, p_user_id);

     IF value_in_sql (sql_string, p_value) THEN
        result := TRUE;
     ELSE
        result := FALSE;
     END IF;

   END IF;

    RETURN result;

 END validate_transaction_type;

-- bug 5186397
-- new function to perform the UOM conversion
-- This will call the INV api to convert
-- the source value passed from the source
-- UOM to the Target UOM
-- SHKALYAN 01-May-2006
--
 FUNCTION perform_uom_conversion (p_source_val IN VARCHAR2,
                                  p_precision  IN NUMBER ,
                                  p_source_UOM IN VARCHAR2,
                                  p_target_UOM IN VARCHAR2)
       RETURN NUMBER AS
     converted_value  NUMBER;
BEGIN
     converted_value := INV_CONVERT.INV_UM_CONVERT
                         (null,
                          p_precision,
                          to_number(p_source_val),
                          p_source_UOM,
                          p_target_UOM,
                          null,
                          null);

     RETURN  converted_value;
END perform_uom_conversion;

--
-- Bug 5383667
-- New function to get the
-- Id Values from QA_results table
-- ntungare Thu Aug 24 02:02:38 PDT 2006
--
Function get_id_val(p_child_char_id IN NUMBER,
                    p_plan_id       IN NUMBER,
                    p_collection_id IN NUMBER,
                    p_occurrence    IN NUMBER)
    RETURN VARCHAR2 AS
    id_val  NUMBER;
    str     VARCHAR2(2000);
BEGIN
    -- bug 6129280
    -- Added to fetch locator_id, comp_locator_id
    -- and to_locator_id and process it
    -- bhsankar Tue Jul 17 02:35:19 PDT 2007
    --
    -- bug 6132613
    -- Modified to fetch Ids for RMA number
    -- ntungare Tue Jul 17 22:54:27 PDT 2007
    --
    If (p_child_char_id = qa_ss_const.party_name OR
        p_child_char_id = qa_ss_const.po_number OR
        p_child_char_id = qa_ss_const.locator OR
        p_child_char_id = qa_ss_const.comp_locator OR
        p_child_char_id = qa_ss_const.to_locator OR
        p_child_char_id = qa_ss_const.rma_number  ) THEN
      str := 'Select '|| qa_chars_api.hardcoded_column(p_child_char_id)||
             ' from qa_results '||
             ' where plan_id = :p_plan_id '||
             '   and collection_id = :p_collection_id '||
             '   and occurrence    = :p_occurrence';

      Execute Immediate str
        INTO id_val
      USING p_plan_id, p_collection_id, p_occurrence;

      If id_val IS NOT NULL THEN
        RETURN id_val;
      End If;
    End if;

    Return NULL;
END get_id_val;

-- bug 6263809
-- New function to get the quantity received for
-- a particular shipment in a receipt.
-- This is needed for LPN Inspections wherein
-- if there is a shipment number collection element
-- then the quantity validation should happen
-- based on it.
-- bhsankar Fri Oct 12 03:06:24 PDT 2007
--
--
-- bug 9652549 CLM changes
--
PROCEDURE get_qty_for_shipment(
        p_po_num IN VARCHAR2,
        p_line_num IN VARCHAR2,
        p_ship_num IN NUMBER,
        x_qty OUT NOCOPY NUMBER) IS

   --
   -- bug 9652549 CLM changes
   --
   CURSOR C1 IS
   SELECT (pll.quantity_received - (pll.quantity_accepted + pll.quantity_rejected)) quantity_received
   FROM   PO_HEADERS_TRX_V ph,
          PO_LINE_LOCATIONS_TRX_V pll,
          PO_LINES_TRX_V pl
   WHERE  pll.po_header_id = ph.po_header_id
   AND    pll.po_line_id = pl.po_line_id
   AND    pll.shipment_num = p_ship_num
   AND    pl.line_num = p_line_num
   AND    ph.segment1 = p_po_num;
BEGIN
    OPEN C1;
      FETCH C1 INTO x_qty;
    CLOSE C1;

    IF x_qty is null THEN
      x_qty := -1;
    END IF;
END get_qty_for_shipment;

-- 12.1 QWB Usability Improvements
-- Method to set the flags for the depenedent elements
PROCEDURE set_dep_element_flag (elements  IN qa_validation_api.ElementsArray,
                                charId    IN NUMBER,
                                condition IN BOOLEAN,
                                dep_elements_list IN OUT NOCOPY string_list,
                                dep_flag_list     IN OUT NOCOPY string_list) AS

     enable_flag   CONSTANT VARCHAR2(1) := 'E';
     disable_flag  CONSTANT VARCHAR2(1) := 'D';
     status        VARCHAR2(1);
BEGIN
    IF (condition = TRUE) THEN
       status := enable_flag;
    ELSE
       status := disable_flag;
    END If;

    If elements.exists(charId) then
       dep_elements_list(NVL(dep_elements_list.LAST,0)+1) := charId;
       dep_flag_list(NVL(dep_flag_list.LAST,0)+1)         := status;
    End If;
END;

-- 12.1 QWB Usability Improvements Project
-- This method has been copied from the file
-- INVCORE.pld. INV team doesn't have an equivalent API
-- to do the processing in PL/SQL since the currrent
-- processing is restricted to Forms UI only.
--
FUNCTION NO_NEG_BALANCE(restrict_flag  IN  Number,
                        neg_flag       IN  Number,
                        action         IN  Number)
    return boolean IS

   VALUE             VARCHAR2(1);
   DO_NOT  BOOLEAN;
BEGIN
     if (restrict_flag = 2 or restrict_flag IS NULL) then
       if (neg_flag = 2) THEN
         if (action = 1 OR action = 2 or action = 3 or
             action = 21 or action = 30 or action = 32) then
             DO_NOT := TRUE;
         else
             DO_NOT := FALSE;
         end if;
       else
         DO_NOT := FALSE;
       end if;
     elsif (restrict_flag = 1) then
       DO_NOT := TRUE;

     else
           /*
          VALUE := restrict_flag;
          app_exception.invalid_argument('LOCATOR.NO_NEG_BALANCE',
                                    'RESTRICT_FLAG',
                                    VALUE);*/
          NULL;
     end if;
     return DO_NOT;
END NO_NEG_BALANCE;

-- 12.1 QWB Usability Improvements Project
-- This method has been copied from the file
-- INVCORE.pld. INV team doesn't have an equivalent API
-- to do the processing in PL/SQL since the currrent
-- processing is restricted to Forms UI only.
--
FUNCTION CONTROL(org_control      IN    number,
                 sub_control      IN    number,
                 item_control     IN    number default NULL,
                 restrict_flag    IN    Number default NULL,
                 Neg_flag         IN    Number default NULL,
                 action           IN    Number default NULL)
     return number  is
  VALUE     VARCHAR2(1);
  locator_control number;
  begin

    if (org_control = 1) then
       locator_control := 1;
    elsif (org_control = 2) then
       locator_control := 2;
    elsif (org_control = 3) then
       locator_control := 3;
       if (no_neg_balance(restrict_flag,
                          neg_flag,action)) then
         locator_control := 2;
       end if;
    elsif (org_control = 4) then
      if (sub_control = 1) then
         locator_control := 1;
      elsif (sub_control = 2) then
         locator_control := 2;
      elsif (sub_control = 3) then
         locator_control := 3;
         if (no_neg_balance(restrict_flag,
                            neg_flag,action)) then
           locator_control := 2;
         end if;
      elsif (sub_control = 5) then
        if (item_control = 1) then
           locator_control := 1;
        elsif (item_control = 2) then
           locator_control := 2;
        elsif (item_control = 3) then
           locator_control := 3;
           if (no_neg_balance(restrict_flag,
                              neg_flag,action)) then
             locator_control := 2;
           end if;
        elsif (item_control IS NULL) then
           locator_control := sub_control;
        else
	  /*
          VALUE := item_control;
          app_exception.invalid_argument('LOCATOR.CONTROL',
                                    'ITEM_LOCATOR_CONTROL',
                                    VALUE);
           */NULL;
        end if;
      else
        /*
        VALUE := sub_control;
        app_exception.invalid_argument('LOCATOR.CONTROL',
                                    'SUB_LOCATOR_CONTROL',
                                    VALUE);*/
         NULL;
      end if;
    else
      /*
      VALUE := org_control;
      app_exception.invalid_argument('LOCATOR.CONTROL',
                                    'ORG_LOCATOR_CONTROL',
                                    VALUE);*/
      NULL;
    end if;
    return locator_control;
END CONTROL;

--
-- 12.1 QWB Usability Improvements
-- Procedure that sets the dependeny rules between different elements
--
PROCEDURE enable_disable_dep_elements (elements  IN qa_validation_api.ElementsArray,
                                       charId    IN NUMBER,
                                       plan_id   IN NUMBER,
                                       org_id    IN NUMBER,
                                       dependent_elements OUT NOCOPY VARCHAR2,
                                       disable_enable_flag_list OUT NOCOPY VARCHAR2)
      AS

    dep_elements_list string_list ;
    dep_flag_list     string_list ;
    enable_flag       CONSTANT VARCHAR2(1) := 'E';
    disable_flag      CONSTANT VARCHAR2(1) := 'D';

    l_restrict_subinventories_code NUMBER;
    l_restrict_locators_code       NUMBER;
    l_location_control_code        NUMBER;
    l_revision_qty_control_code    NUMBER;
    l_serial_number_control_code   NUMBER;
    l_lot_control_code             NUMBER;
    l_primary_uom_code             VARCHAR2(20);

    X_LOC_CNTRL                    NUMBER;

    enable_contition               BOOLEAN;

    CURSOR locator is
      SELECT stock_locator_control_code,
             negative_inv_receipt_code
      FROM mtl_parameters
      WHERE organization_id = org_id;

    x_org_loc_control NUMBER;
    x_neg_inv         NUMBER;

   Cursor sub_loc_cur (p_subinv_name IN VARCHAR2) IS
     SELECT locator_type
      FROM mtl_secondary_inventories
      WHERE organization_id = org_id
       AND nvl(disable_date,   sysdate + 1) > sysdate
       AND secondary_inventory_name = p_subinv_name;

   l_sub_loc_type  NUMBER := 1;

   CURSOR c (p_item_id IN NUMBER) IS
     SELECT
         msi.restrict_subinventories_code,
         msi.restrict_locators_code,
         msi.location_control_code,
         msi.revision_qty_control_code,
         msi.serial_number_control_code,
         msi.lot_control_code,
         msi.primary_uom_code
      FROM
         mtl_system_items msi
      WHERE msi.organization_id   = org_id AND
            msi.inventory_item_id = p_item_id;

   cascaded_dep_elements_list  VARCHAR2(32000);
   cascaded_dep_flag_list      VARCHAR2(32000);
   disabled_elements           qa_validation_api.ElementsArray;
BEGIN
    -- build the logic to fetch the dependent elements to be enabled
    -- based on the lines of the code present in QLTRES.pld
    --

    --
    -- bug 7191632
    -- Removed the Hard dependency between the Production Line
    -- Item collection elements. This dependency would be
    -- established using LOVs
    -- ntungare
    --
    -- Process the element Production Line
    /*
    If (charId = 20) then
         -- enable Item
         set_dep_element_flag(elements,
                              10,
                              (elements(charId).value IS NOT NULL),
                              dep_elements_list,
                              dep_flag_list);
    */

    -- Process the element Item
    IF (charId = 10) then
          OPEN c (elements(charId).id);
          FETCH c INTO
              l_restrict_subinventories_code ,
              l_restrict_locators_code       ,
              l_location_control_code        ,
              l_revision_qty_control_code    ,
              l_serial_number_control_code   ,
              l_lot_control_code             ,
              l_primary_uom_code;
          CLOSE c;

         -- enable UOM
         set_dep_element_flag(elements,
                              12,
                              (elements(charId).value IS NOT NULL),
                              dep_elements_list,
                              dep_flag_list);

         --enable revision
         set_dep_element_flag(elements,
                              13,
                              ((elements(charId).value IS NOT NULL) AND
                              (l_revision_qty_control_code = 2)),
                              dep_elements_list,
                              dep_flag_list);

         --enable Lot Number
         set_dep_element_flag(elements,
                              16,
                              ((elements(charId).value IS NOT NULL) AND
                              (l_lot_control_code <> 1)),
                              dep_elements_list,
                              dep_flag_list);

         --enable Serial Number
         set_dep_element_flag(elements,
                              17,
                              ((elements(charId).value IS NOT NULL) AND
                              (l_serial_number_control_code <> 1)),
                              dep_elements_list,
                              dep_flag_list);

         --enable Subinventory
         set_dep_element_flag(elements,
                              14,
                              (elements(charId).value IS NOT NULL),
                              dep_elements_list,
                              dep_flag_list);

         --enable To Subinventory
         set_dep_element_flag(elements,
                              2147483628,
                              (elements(charId).value IS NOT NULL),
                              dep_elements_list,
                              dep_flag_list);

    -- Process element Lot number
    ELSIF (charId = 16) then
         --enable Lot Status
         set_dep_element_flag(elements,
                              188,
                              (elements(charId).value IS NOT NULL),
                              dep_elements_list,
                              dep_flag_list);

    -- Process element Serial Number
    ELSIF charId = 17 then
         --enable Serial Status
         set_dep_element_flag(elements,
                              189,
                              (elements(charId).value IS NOT NULL),
                              dep_elements_list,
                              dep_flag_list);

    -- Process element Subinventory
    ELSIF charId = 14 then
         --enable Locator
         OPEN locator;
         FETCH locator INTO x_org_loc_control,
                            x_neg_inv;
         CLOSE locator;

         OPEN sub_loc_cur(elements(charId).value);
         FETCH sub_loc_cur INTO l_sub_loc_type;
         CLOSE sub_loc_cur;

         If (elements.exists(10)) then
            OPEN c (elements(10).id);
            FETCH c INTO
                l_restrict_subinventories_code ,
                l_restrict_locators_code       ,
                l_location_control_code        ,
                l_revision_qty_control_code    ,
                l_serial_number_control_code   ,
                l_lot_control_code             ,
                l_primary_uom_code;
            CLOSE c;
         Else
                l_restrict_subinventories_code := NULL;
                l_restrict_locators_code       := NULL;
                l_location_control_code        := NULL;
                l_revision_qty_control_code    := NULL;
                l_serial_number_control_code   := NULL;
                l_lot_control_code             := NULL;
                l_primary_uom_code             := NULL;
         End If;

         IF (elements(charId).value IS NULL) THEN
            x_loc_cntrl := 1;
         Else
            x_loc_cntrl := CONTROL(
                                ORG_CONTROL   => x_org_loc_control,
                                SUB_CONTROL   => l_sub_loc_type,
                                ITEM_CONTROL  => l_location_control_code,
                                RESTRICT_FLAG => l_restrict_locators_code,
                                NEG_FLAG      => x_neg_inv);
         End If;

         set_dep_element_flag(elements,
                              15,
                              ((elements(charId).value IS NOT NULL) AND
                              (x_LOC_CNTRL <>1 AND X_LOC_CNTRL in (2,3))),
                              dep_elements_list,
                              dep_flag_list);

    -- Process element To Subinventory
    ELSIF charId = 2147483628 then
         --enable To Locator
         OPEN locator;
         FETCH locator INTO x_org_loc_control,
                            x_neg_inv;
         CLOSE locator;

         OPEN sub_loc_cur (elements(charId).value) ;
         FETCH sub_loc_cur INTO l_sub_loc_type;
         CLOSE sub_loc_cur;

         If (elements.exists(10)) then
            OPEN c (elements(10).id);
            FETCH c INTO
                l_restrict_subinventories_code ,
                l_restrict_locators_code       ,
                l_location_control_code        ,
                l_revision_qty_control_code    ,
                l_serial_number_control_code   ,
                l_lot_control_code             ,
                l_primary_uom_code;
            CLOSE c;
         Else
                l_restrict_subinventories_code := NULL;
                l_restrict_locators_code       := NULL;
                l_location_control_code        := NULL;
                l_revision_qty_control_code    := NULL;
                l_serial_number_control_code   := NULL;
                l_lot_control_code             := NULL;
                l_primary_uom_code             := NULL;
         End If;

         IF (elements(charId).value IS NULL) THEN
            x_loc_cntrl := 1;
         Else
            x_loc_cntrl := CONTROL(
                                ORG_CONTROL   => x_org_loc_control,
                                SUB_CONTROL   => l_sub_loc_type,
                                ITEM_CONTROL  => l_location_control_code,
                                RESTRICT_FLAG => l_restrict_locators_code,
                                NEG_FLAG      => x_neg_inv);
         End If;

         set_dep_element_flag(elements,
                              2147483627,
                              ((elements(charId).value IS NOT NULL) AND
                              (x_LOC_CNTRL <>1 AND X_LOC_CNTRL in (2,3))),
                              dep_elements_list,
                              dep_flag_list);

    -- Process element Job Name
    ELSIF charId = 19 then
         -- enable TO_OP_SEQ_NUM
         set_dep_element_flag(elements,
                              21,
                              (elements(charId).value IS NOT NULL),
                              dep_elements_list,
                              dep_flag_list);

         --enable FROM_OP_SEQ_NUM
         set_dep_element_flag(elements,
                              22,
                              (elements(charId).value IS NOT NULL),
                              dep_elements_list,
                              dep_flag_list);

    -- Process element TO_OP_SEQ_NUM
    ELSIF charId = 21 then
         -- enable TO_INTRAOPERATION_STEP
         set_dep_element_flag(elements,
                              23,
                              (elements(charId).value IS NOT NULL),
                              dep_elements_list,
                              dep_flag_list);

    -- Process element FROM_OP_SEQ_NUM
    ELSIF charId = 22 then
         -- enable TO_INTRAOPERATION_STEP
         set_dep_element_flag(elements,
                              24,
                              (elements(charId).value IS NOT NULL),
                              dep_elements_list,
                              dep_flag_list);

    -- Process element PO Number
    ELSIF charId = 27 then
         -- enable PO Release Number
         set_dep_element_flag(elements,
                              110,
                              (elements(charId).value IS NOT NULL),
                              dep_elements_list,
                              dep_flag_list);

         -- enable PO Line Number
         set_dep_element_flag(elements,
                              28,
                              (elements(charId).value IS NOT NULL),
                              dep_elements_list,
                              dep_flag_list);

    -- Process element PO Line Number
    ELSIF charId = 28 then
         -- enable PO Release Number
         set_dep_element_flag(elements,
                              29,
                              (elements(charId).value IS NOT NULL),
                              dep_elements_list,
                              dep_flag_list);

    -- Process element Project Number
    ELSIF charId = 121 then
         -- enable PO Release Number
         set_dep_element_flag(elements,
                              122,
                              (elements(charId).value IS NOT NULL),
                              dep_elements_list,
                              dep_flag_list);

    -- Process element Asset Group
    ELSIF charId = 162 then
         -- enable Asset Number
         set_dep_element_flag(elements,
                              163,
                              (elements(charId).value IS NOT NULL),
                              dep_elements_list,
                              dep_flag_list);

         -- enable Asset Instance Number
         set_dep_element_flag(elements,
                              2147483550,
                              (elements(charId).value IS NOT NULL),
                              dep_elements_list,
                              dep_flag_list);

         -- enable Asset Activity
         set_dep_element_flag(elements,
                              164,
                              (elements(charId).value IS NOT NULL),
                              dep_elements_list,
                              dep_flag_list);

    -- Process element Asset Number
    ELSIF charId = 163 then
         -- enable Asset Activity
         set_dep_element_flag(elements,
                              164,
                              (elements(charId).value IS NOT NULL),
                              dep_elements_list,
                              dep_flag_list);

    -- Process element PROCESS_BATCHSTEP_NUM
    ELSIF charId = 2147483555 then
         -- enable PROCESS_OPERATION
         set_dep_element_flag(elements,
                              2147483554,
                              (elements(charId).value IS NOT NULL),
                              dep_elements_list,
                              dep_flag_list);

    -- Process element PROCESS_OPERATION
    ELSIF charId = 2147483554 then
         -- enable PROCESS_ACTIVITY
         set_dep_element_flag(elements,
                              2147483553,
                              (elements(charId).value IS NOT NULL),
                              dep_elements_list,
                              dep_flag_list);

    -- Process element PROCESS_ACTIVITY
    ELSIF charId = 2147483553 then
         -- enable PROCESS_RESOURCE
         set_dep_element_flag(elements,
                              2147483552,
                              (elements(charId).value IS NOT NULL),
                              dep_elements_list,
                              dep_flag_list);

    -- Process element PROCESS_RESOURCE
    ELSIF charId = 2147483552 then
         -- enable PROCESS_PARAMETER
         set_dep_element_flag(elements,
                              2147483551,
                              (elements(charId).value IS NOT NULL),
                              dep_elements_list,
                              dep_flag_list);

    -- Process the element Comp Item
    ELSIF charId = 60 then
          OPEN c (elements(charId).id);
          FETCH c INTO
              l_restrict_subinventories_code ,
              l_restrict_locators_code       ,
              l_location_control_code        ,
              l_revision_qty_control_code    ,
              l_serial_number_control_code   ,
              l_lot_control_code             ,
              l_primary_uom_code;
          CLOSE c;

         -- enable COMP_UOM
         set_dep_element_flag(elements,
                              62,
                              (elements(charId).value IS NOT NULL),
                              dep_elements_list,
                              dep_flag_list);

         --enable COMP_revision
         set_dep_element_flag(elements,
                              63,
                              ((elements(charId).value IS NOT NULL) AND
                              (l_revision_qty_control_code = 2)),
                              dep_elements_list,
                              dep_flag_list);

         --enable Comp Lot Number
         set_dep_element_flag(elements,
                              66,
                              ((elements(charId).value IS NOT NULL) AND
                              (l_lot_control_code <> 1)),
                              dep_elements_list,
                              dep_flag_list);

         --enable Comp Serial Number
         set_dep_element_flag(elements,
                              67,
                              ((elements(charId).value IS NOT NULL) AND
                              (l_serial_number_control_code <> 1)),
                              dep_elements_list,
                              dep_flag_list);

         --enable Subinventory
         set_dep_element_flag(elements,
                              64,
                              (elements(charId).value IS NOT NULL),
                              dep_elements_list,
                              dep_flag_list);

    -- Process element Comp Subinventory
    ELSIF charId = 64 then
         --enable Comp Locator
         OPEN locator;
         FETCH locator INTO x_org_loc_control,
                            x_neg_inv;
         CLOSE locator;

         OPEN sub_loc_cur (elements(charId).value) ;
         FETCH sub_loc_cur INTO l_sub_loc_type;
         CLOSE sub_loc_cur;

         If (elements.exists(60)) then
            OPEN c (elements(60).id);
            FETCH c INTO
                l_restrict_subinventories_code ,
                l_restrict_locators_code       ,
                l_location_control_code        ,
                l_revision_qty_control_code    ,
                l_serial_number_control_code   ,
                l_lot_control_code             ,
                l_primary_uom_code;
            CLOSE c;
         Else
                l_restrict_subinventories_code := NULL;
                l_restrict_locators_code       := NULL;
                l_location_control_code        := NULL;
                l_revision_qty_control_code    := NULL;
                l_serial_number_control_code   := NULL;
                l_lot_control_code             := NULL;
                l_primary_uom_code             := NULL;
         End If;

         IF (elements(charId).value IS NULL) THEN
            x_loc_cntrl := 1;
         Else
            x_loc_cntrl := CONTROL(
                                ORG_CONTROL   => x_org_loc_control,
                                SUB_CONTROL   => l_sub_loc_type,
                                ITEM_CONTROL  => l_location_control_code,
                                RESTRICT_FLAG => l_restrict_locators_code,
                                NEG_FLAG      => x_neg_inv);
         End If;

         --
         -- bug 7194001
         -- The locator field was getting modified
         -- incorrectly instead of the comp locator
         -- ntungare
         --
         set_dep_element_flag(elements,
                              65,
                              ((elements(charId).value IS NOT NULL) AND
                              (x_LOC_CNTRL <>1 AND X_LOC_CNTRL in (2,3))),
                              dep_elements_list,
                              dep_flag_list);

    -- Bug 7716875.Added dependency between sales_order
    -- and so line_num.pdube Mon Apr 13 03:25:19 PDT 2009.
    ELSIF charId = 33 THEN
        -- enable SO Line Number
        set_dep_element_flag(elements,
                             35,
                             (elements(charId).value IS NOT NULL),
                             dep_elements_list,
                             dep_flag_list);
    END IF;

    -- initializing the disabled elements array as
    -- equal to the elements array
    --
    disabled_elements := elements;

    IF dep_elements_list.count <> 0 then
       FOR cntr in 1..dep_elements_list.count
         LOOP
            dependent_elements := dependent_elements ||','|| dep_elements_list(cntr);
            disable_enable_flag_list := disable_enable_flag_list ||','|| dep_flag_list(cntr);

            -- If a collection element has been diasbled, all its
            -- dependent elements must also be disabled
            --
            IF (dep_flag_list(cntr) = disable_flag) THEN
               -- Since the element is to be disbaled. Hence setting the value as NULL.
               IF elements.exists(dep_elements_list(cntr)) THEN
	          disabled_elements(dep_elements_list(cntr)).value := NULL;
		  null;
               END IF;

               enable_disable_dep_elements(disabled_elements,
                                           dep_elements_list(cntr),
                                           plan_id,
                                           org_id,
                                           cascaded_dep_elements_list,
                                           cascaded_dep_flag_list);

               IF (cascaded_dep_elements_list IS NOT NULL) THEN
                  dependent_elements       := dependent_elements ||','|| cascaded_dep_elements_list;
                  disable_enable_flag_list := disable_enable_flag_list || ',' || cascaded_dep_flag_list ;
               END IF;
            END IF;
         END LOOP;
    ELSE
       RETURN;
    END If;

    dependent_elements := LTRIM(dependent_elements ,',');
    disable_enable_flag_list := LTRIM(disable_enable_flag_list, ',') ;

END enable_disable_dep_elements ;

-- 12.1 QWB Usability Improvemenets
-- New procedure to process dependent elements
PROCEDURE process_dependent_elements(result_string IN VARCHAR2,
                                     id_string     IN VARCHAR2,
                                     org_id        IN NUMBER,
                                     p_plan_id     IN NUMBER,
                                     char_Id       IN VARCHAR2,
                                     dependent_elements OUT NOCOPY VARCHAR2,
                                     disable_enable_flag_list OUT NOCOPY VARCHAR2)
      AS
   elements       qa_validation_api.ElementsArray;
   char_cntr         NUMBER;
   dep_elements_list VARCHAR2(4000);
   dep_flag_list     VARCHAR2(4000);

   l_result_string   VARCHAR2(32767);

   Cursor plan_chars_cur is
      select char_id from qa_plan_chars
        where plan_id = p_plan_id;
BEGIN
   l_result_string := result_string;

   -- Handling for NULL result string. In this case
   -- build a result string with all the elements
   -- set as NULL
   if (l_result_string IS NULL) THEN
       For rad in plan_chars_cur
        loop
           l_result_string := l_result_string||'@'||rad.char_id||'=';
        end loop;
        l_result_string := LTRIM(l_result_string,'@');
   end If;

   -- Builid elements array
   elements := qa_validation_api.result_to_array(l_result_string);
   elements := qa_validation_api.id_to_array(id_string, elements);

   -- If char id is NULL then the entire row is to be
   -- processed
   If char_id IS NULL THEN
       char_cntr := elements.first;

        -- Process all elements
       while char_cntr <= elements.last
         loop
            -- Get the dependent elemnts list and the flags
            enable_disable_dep_elements(elements,
                                        char_cntr,
                                        p_plan_id,
					org_id,
                                        dep_elements_list,
                                        dep_flag_list);

            if dep_elements_list is not null then
                    dependent_elements  := dependent_elements ||','||dep_elements_list;
                    disable_enable_flag_list := disable_enable_flag_list||','||dep_flag_list;
            end if;
            char_cntr := elements.next(char_cntr);
         end loop;

  -- If char id is NOT NULL then the specific element
  -- is to be processed
   Else
      -- Get the dependent elemnts list and the flags
      enable_disable_dep_elements(elements,
                                  char_Id,
                                  p_plan_id,
                                  org_id,
                                  dep_elements_list,
                                  dep_flag_list);

      dependent_elements  := dep_elements_list;
      disable_enable_flag_list := dep_flag_list;
   End If;

   If dependent_elements  IS NOT NULL THEN
      dependent_elements  := LTRIM(dependent_elements ,',');
      disable_enable_flag_list := LTRIM(disable_enable_flag_list ,',');
   End If;
END process_dependent_elements;

--
-- 12.1 QWB Usabitlity Improvements
-- Function to build the Info column value
--
FUNCTION build_info_column(p_plan_id        IN NUMBER,
                           p_collection_id  IN NUMBER,
                           p_occurrence     IN NUMBER)
      RETURN VARCHAR2
    AS

    Type hardcoded_char_tab_typ IS TABLE OF NUMBER INDEX BY binary_integer;
    hardcoded_char_tab hardcoded_char_tab_typ;

    cols_str VARCHAR2(32767);
    char_ids_str VARCHAR2(32767);

    plan_name VARCHAR2(100);

    result_str VARCHAR2(32767);

    char_name  VARCHAR(100);

    p_values_string  VARCHAR2(32767) := NULL;
BEGIN
    -- get the list of information columns
    --
    -- bug 7115965
    -- Added an order by clause
    -- ntungare
    --
    SELECT qpc.char_id bulk collect
      INTO hardcoded_char_tab
    FROM qa_plan_chars qpc
    WHERE qpc.plan_id = p_plan_id
      AND qpc.information_flag = 1
    ORDER BY prompt_sequence;

    -- get the columns names corresponding to
    -- the information columns
    -- The processing is to be done only if there are any
    -- information columns.
    if hardcoded_char_tab.count <> 0 then
      FOR cntr IN 1 .. hardcoded_char_tab.COUNT
        LOOP
          -- get the column name to select from view
          Select upper(translate(name,' ''*{}','_____')) into char_name
            from qa_chars
          where char_id =   hardcoded_char_tab(cntr);

          -- build a list of columns to select from the
          -- plan view
          --
          -- bug 7115965
          -- Changed the separator from space to comma
          -- ntungare
          --
          cols_str := cols_str ||  char_name||'||'', ''||';

        END LOOP;

        -- build the plan view name
        SELECT deref_view_name INTO plan_name
          FROM qa_plans
         WHERE plan_id = p_plan_id;

        --
        -- bug 7115965
        -- Changed the separator from space to comma
        -- ntungare
        --
        cols_str := RTRIM(cols_str, '||'', ''||');

        -- Execute the dynamic query and get the information cols string
        EXECUTE IMMEDIATE 'Select ' || cols_str || ' from ' || plan_name ||
                             ' where collection_id = :collection_id and
                                   occurrence = :occurrence'
            INTO p_values_string
        USING p_collection_id,
              p_occurrence;
    end if;

    return p_values_string;
END build_info_column;

END qa_plan_element_api;

/
