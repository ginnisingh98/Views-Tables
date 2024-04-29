--------------------------------------------------------
--  DDL for Package Body IGI_EFC_UPGRADE
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IGI_EFC_UPGRADE" AS
-- $Header: igiefupb.pls 120.0.12010000.2 2009/04/24 08:17:28 gaprasad ship $

-- Stores the budget id
TYPE budget_type IS TABLE OF gl_budget_assignment_ranges.funding_budget_version_id%TYPE;

-- Stores the value SEGMENT_LOW and SEGMENT_HIGH of a particular segment
TYPE segment_range_rec IS RECORD (segment_low VARCHAR2(25),
                                  segment_high VARCHAR2(25),
                                  segment_number NUMBER,
                                  data_type NUMBER,
                                  budget_tab BUDGET_TYPE);

-- Array of segment ranges. Array index indicates the Segment number.
TYPE segment_range_type IS VARRAY(30) OF segment_range_rec;

-- Record corresponding to table gl_budget_assignment_ranges
TYPE budget_range_rec IS RECORD (range_id gl_budget_assignment_ranges.range_id%TYPE,
                                 ledger_id gl_budget_assignment_ranges.ledger_id%TYPE,
                                 segment_range_tab SEGMENT_RANGE_TYPE,
                                 budget_tab BUDGET_TYPE);



-- Table of Budget Assignment Ranges. Corresponds to table
-- gl_budget_assignment_ranges
TYPE budget_range_type IS TABLE OF budget_range_rec;

-- Stores information for a particular segment. Used by Splitting and Merging
-- logic
TYPE segment_rec IS RECORD (index_number NUMBER,
                            segment_number NUMBER,
                            segment_high VARCHAR2(25),
                            segment_low VARCHAR2(25),
                            budget_tab BUDGET_TYPE,
                            data_type NUMBER);

-- Array of Segment Records. Used by Splitting and Merging logic.
TYPE segment_type IS TABLE OF segment_rec;

-- Array of Segment Records
TYPE segment_rec_index_type IS TABLE OF NUMBER;

-- PLSQL Table corresponding to IGI_UPG_GL_BUDORG_BC_OPTIONS
TYPE BC_OPTIONS_TAB IS TABLE OF IGI_UPG_GL_BUDORG_BC_OPTIONS%ROWTYPE;

-- Stores table of segment records
segment_tab SEGMENT_TYPE;

-- Stores table of budget records
budget_range_tab BUDGET_RANGE_TYPE;

-- g_debug_enable stores 0 or 1 and is used for logging purpose
g_debug_enabled NUMBER;

-- PLSQL record to store the Budget Organization that is processed
TYPE budget_entity_rec IS RECORD (budget_entity_id gl_budget_assignment_ranges.budget_entity_id%TYPE, ledger_id gl_budget_assignment_ranges.ledger_id%TYPE);

-- PLSQL record to store the list of Budget Organizations that are processed
TYPE budget_entity_type IS TABLE OF budget_entity_rec;

-- Stores the list of ledgers and entities upgraded by this script
-- This is used by the START_EFC_UPGRADE when the GL concurrent program
-- "Assign Assignment Ranges" is fired
budget_entity_tab budget_entity_type;


-- Procedure INSERT_ENTITY stores the list of ledgers and entities processed by
-- LOOP_AND_PROCESS. This is stored in the table budget_entity_tab.
-- This procedure ensures that duplicate entries are not inserted into the
-- table.
PROCEDURE INSERT_ENTITY(p_ledger_id gl_budget_assignment_ranges.budget_entity_id%TYPE,
                        p_entity_id gl_budget_assignment_ranges.ledger_id%TYPE,
                        errbuf OUT NOCOPY VARCHAR2,
                        retcode OUT NOCOPY NUMBER)

IS
    l_exists BOOLEAN;
BEGIN

    l_exists := FALSE;

    IF budget_entity_tab.COUNT = 0 THEN
        budget_entity_tab.extend(1);
        budget_entity_tab(1).ledger_id := p_ledger_id;
        budget_entity_tab(1).budget_entity_id := p_entity_id;
    ELSE

        FOR i IN 1..budget_entity_tab.COUNT LOOP
            IF budget_entity_tab(i).ledger_id = p_ledger_id AND
                budget_entity_tab(i).budget_entity_id = p_entity_id THEN
                l_exists := TRUE;
                EXIT;
            END IF;
        END LOOP;
        IF NOT l_exists THEN
            budget_entity_tab.extend(1);
            budget_entity_tab(budget_entity_tab.COUNT).ledger_id := p_ledger_id;
            budget_entity_tab(budget_entity_tab.COUNT).budget_entity_id := p_entity_id;
        END IF;
    END IF;

EXCEPTION
    WHEN OTHERS THEN
        fnd_file.put_line(fnd_file.log, 'Module: INSERT_ENTITY '||'Insertion failed '||SQLERRM);
        errbuf := 'Module: INSERT_ENTITY '||'Insertion failed '||SQLERRM;
        retcode := -1;
        RETURN;
END INSERT_ENTITY;


-- Procedure PRINT_BUDGET_INFO produces the output for this program
-- This procedure accepts range_id as a parameter and
-- outputs the account range and the budgets associated to this account range
PROCEDURE PRINT_BUDGET_INFO (p_range_id NUMBER,
                             errbuf OUT NOCOPY VARCHAR2,
                             retcode OUT NOCOPY NUMBER)

IS
    -- This cursor fetches the account range information
    CURSOR C_UPG_GL_BUDGET_ASSIGNMENT (pp_range_id NUMBER)
    IS
    SELECT IGIGL.*,ent.NAME BUDGET_NAME,led.NAME LEDGER_NAME
    FROM IGI_UPG_GL_BUDGET_ASSIGNMENT IGIGL,
          gl_budget_entities ent,
          GL_LEDGERS led
    WHERE IGIGL.RANGE_ID = pp_range_id
    AND IGIGL.budget_entity_id = ent.budget_entity_id
    AND IGIGL.ledger_id = led.ledger_id
    ;

    -- This cursor fetches budgets associated to the give account range
	CURSOR C_BC_OPTIONS (pp_range_id NUMBER)
	IS
	SELECT IGIBC.*,BV.BUDGET_NAME BUDGET_NAME
    FROM IGI_UPG_GL_BUDORG_BC_OPTIONS IGIBC,
         GL_BUDGET_VERSIONS BV
	WHERE IGIBC.RANGE_ID = pp_range_id AND
          IGIBC.FUNDING_BUDGET_VERSION_ID = BV.BUDGET_VERSION_ID
    ;

    -- Stores table of type C_BC_OPTIONS
    TYPE IGI_BC_OPTIONS_TAB IS TABLE OF C_BC_OPTIONS%ROWTYPE;

    -- Stores a record of type C_UPG_GL_BUDGET_ASSIGNMENT
    lc_upg_gl_bud C_UPG_GL_BUDGET_ASSIGNMENT%ROWTYPE;

    lc_bc_options IGI_BC_OPTIONS_TAB;

BEGIN
    IF p_range_id IS NULL THEN
        errbuf := 'Module: PRINT_BUDGET_INFO => '||'p_range_id is NULL';
        retcode := -1;
        RETURN;
    END IF;
    BEGIN

        --The following logic opens the cursors and displays the necessary information

        OPEN C_UPG_GL_BUDGET_ASSIGNMENT(p_range_id);
        FETCH C_UPG_GL_BUDGET_ASSIGNMENT INTO lc_upg_gl_bud;
        CLOSE C_UPG_GL_BUDGET_ASSIGNMENT;

        fnd_file.put(fnd_file.output,lc_upg_gl_bud.LEDGER_NAME||'        ');
        fnd_file.put(fnd_file.output,lc_upg_gl_bud.BUDGET_NAME||'        ');

        fnd_file.put(fnd_file.output,lc_upg_gl_bud.CURRENCY_CODE||'        ');

        IF lc_upg_gl_bud.SEGMENT1_LOW IS NOT NULL THEN
            fnd_file.put(fnd_file.output,lc_upg_gl_bud.SEGMENT1_LOW||'-');
        END IF;

        IF lc_upg_gl_bud.SEGMENT2_LOW IS NOT NULL THEN
            fnd_file.put(fnd_file.output,lc_upg_gl_bud.SEGMENT2_LOW||'-');
        END IF;

        IF lc_upg_gl_bud.SEGMENT3_LOW IS NOT NULL THEN
            fnd_file.put(fnd_file.output,lc_upg_gl_bud.SEGMENT3_LOW||'-');
        END IF;

        IF lc_upg_gl_bud.SEGMENT4_LOW IS NOT NULL THEN
            fnd_file.put(fnd_file.output,lc_upg_gl_bud.SEGMENT4_LOW||'-');
        END IF;

        IF lc_upg_gl_bud.SEGMENT5_LOW IS NOT NULL THEN
            fnd_file.put(fnd_file.output,lc_upg_gl_bud.SEGMENT5_LOW||'-');
        END IF;

        IF lc_upg_gl_bud.SEGMENT6_LOW IS NOT NULL THEN
            fnd_file.put(fnd_file.output,lc_upg_gl_bud.SEGMENT6_LOW||'-');
        END IF;

        IF lc_upg_gl_bud.SEGMENT7_LOW IS NOT NULL THEN
            fnd_file.put(fnd_file.output,lc_upg_gl_bud.SEGMENT7_LOW||'-');
        END IF;

        IF lc_upg_gl_bud.SEGMENT8_LOW IS NOT NULL THEN
            fnd_file.put(fnd_file.output,lc_upg_gl_bud.SEGMENT8_LOW||'-');
        END IF;

        IF lc_upg_gl_bud.SEGMENT9_LOW IS NOT NULL THEN
            fnd_file.put(fnd_file.output,lc_upg_gl_bud.SEGMENT9_LOW||'-');
        END IF;

        IF lc_upg_gl_bud.SEGMENT10_LOW IS NOT NULL THEN
            fnd_file.put(fnd_file.output,lc_upg_gl_bud.SEGMENT10_LOW||'-');
        END IF;

        IF lc_upg_gl_bud.SEGMENT11_LOW IS NOT NULL THEN
            fnd_file.put(fnd_file.output,lc_upg_gl_bud.SEGMENT11_LOW||'-');
        END IF;

        IF lc_upg_gl_bud.SEGMENT12_LOW IS NOT NULL THEN
            fnd_file.put(fnd_file.output,lc_upg_gl_bud.SEGMENT12_LOW||'-');
        END IF;

        IF lc_upg_gl_bud.SEGMENT13_LOW IS NOT NULL THEN
            fnd_file.put(fnd_file.output,lc_upg_gl_bud.SEGMENT13_LOW||'-');
        END IF;

        IF lc_upg_gl_bud.SEGMENT14_LOW IS NOT NULL THEN
            fnd_file.put(fnd_file.output,lc_upg_gl_bud.SEGMENT14_LOW||'-');
        END IF;

        IF lc_upg_gl_bud.SEGMENT15_LOW IS NOT NULL THEN
            fnd_file.put(fnd_file.output,lc_upg_gl_bud.SEGMENT15_LOW||'-');
        END IF;

        IF lc_upg_gl_bud.SEGMENT16_LOW IS NOT NULL THEN
            fnd_file.put(fnd_file.output,lc_upg_gl_bud.SEGMENT16_LOW||'-');
        END IF;

        IF lc_upg_gl_bud.SEGMENT17_LOW IS NOT NULL THEN
            fnd_file.put(fnd_file.output,lc_upg_gl_bud.SEGMENT17_LOW||'-');
        END IF;

        IF lc_upg_gl_bud.SEGMENT18_LOW IS NOT NULL THEN
            fnd_file.put(fnd_file.output,lc_upg_gl_bud.SEGMENT18_LOW||'-');
        END IF;
        IF lc_upg_gl_bud.SEGMENT19_LOW IS NOT NULL THEN
            fnd_file.put(fnd_file.output,lc_upg_gl_bud.SEGMENT19_LOW||'-');
        END IF;

        IF lc_upg_gl_bud.SEGMENT20_LOW IS NOT NULL THEN
            fnd_file.put(fnd_file.output,lc_upg_gl_bud.SEGMENT20_LOW||'-');
        END IF;

        IF lc_upg_gl_bud.SEGMENT21_LOW IS NOT NULL THEN
            fnd_file.put(fnd_file.output,lc_upg_gl_bud.SEGMENT21_LOW||'-');
        END IF;

        IF lc_upg_gl_bud.SEGMENT22_LOW IS NOT NULL THEN
            fnd_file.put(fnd_file.output,lc_upg_gl_bud.SEGMENT22_LOW||'-');
        END IF;

        IF lc_upg_gl_bud.SEGMENT23_LOW IS NOT NULL THEN
            fnd_file.put(fnd_file.output,lc_upg_gl_bud.SEGMENT23_LOW||'-');
        END IF;

        IF lc_upg_gl_bud.SEGMENT24_LOW IS NOT NULL THEN
            fnd_file.put(fnd_file.output,lc_upg_gl_bud.SEGMENT24_LOW||'-');
        END IF;

        IF lc_upg_gl_bud.SEGMENT25_LOW IS NOT NULL THEN
            fnd_file.put(fnd_file.output,lc_upg_gl_bud.SEGMENT25_LOW||'-');
        END IF;

        IF lc_upg_gl_bud.SEGMENT26_LOW IS NOT NULL THEN
            fnd_file.put(fnd_file.output,lc_upg_gl_bud.SEGMENT26_LOW||'-');
        END IF;

        IF lc_upg_gl_bud.SEGMENT27_LOW IS NOT NULL THEN
            fnd_file.put(fnd_file.output,lc_upg_gl_bud.SEGMENT27_LOW||'-');
        END IF;

        IF lc_upg_gl_bud.SEGMENT28_LOW IS NOT NULL THEN
            fnd_file.put(fnd_file.output,lc_upg_gl_bud.SEGMENT28_LOW||'-');
        END IF;

        IF lc_upg_gl_bud.SEGMENT29_LOW IS NOT NULL THEN
            fnd_file.put(fnd_file.output,lc_upg_gl_bud.SEGMENT29_LOW||'-');
        END IF;

        IF lc_upg_gl_bud.SEGMENT30_LOW IS NOT NULL THEN
            fnd_file.put(fnd_file.output,lc_upg_gl_bud.SEGMENT30_LOW||'-');
        END IF;

        fnd_file.put(fnd_file.output,'   to    ');

        IF lc_upg_gl_bud.SEGMENT1_HIGH IS NOT NULL THEN
            fnd_file.put(fnd_file.output,lc_upg_gl_bud.SEGMENT1_HIGH||'-');
        END IF;

        IF lc_upg_gl_bud.SEGMENT2_HIGH IS NOT NULL THEN
            fnd_file.put(fnd_file.output,lc_upg_gl_bud.SEGMENT2_HIGH||'-');
        END IF;

        IF lc_upg_gl_bud.SEGMENT3_HIGH IS NOT NULL THEN
            fnd_file.put(fnd_file.output,lc_upg_gl_bud.SEGMENT3_HIGH||'-');
        END IF;

        IF lc_upg_gl_bud.SEGMENT4_HIGH IS NOT NULL THEN
            fnd_file.put(fnd_file.output,lc_upg_gl_bud.SEGMENT4_HIGH||'-');
        END IF;

        IF lc_upg_gl_bud.SEGMENT5_HIGH IS NOT NULL THEN
            fnd_file.put(fnd_file.output,lc_upg_gl_bud.SEGMENT5_HIGH||'-');
        END IF;

        IF lc_upg_gl_bud.SEGMENT6_HIGH IS NOT NULL THEN
            fnd_file.put(fnd_file.output,lc_upg_gl_bud.SEGMENT6_HIGH||'-');
        END IF;

        IF lc_upg_gl_bud.SEGMENT7_HIGH IS NOT NULL THEN
            fnd_file.put(fnd_file.output,lc_upg_gl_bud.SEGMENT7_HIGH||'-');
        END IF;

        IF lc_upg_gl_bud.SEGMENT8_HIGH IS NOT NULL THEN
            fnd_file.put(fnd_file.output,lc_upg_gl_bud.SEGMENT8_HIGH||'-');
        END IF;

        IF lc_upg_gl_bud.SEGMENT9_HIGH IS NOT NULL THEN
            fnd_file.put(fnd_file.output,lc_upg_gl_bud.SEGMENT9_HIGH||'-');
        END IF;

        IF lc_upg_gl_bud.SEGMENT10_HIGH IS NOT NULL THEN
            fnd_file.put(fnd_file.output,lc_upg_gl_bud.SEGMENT10_HIGH||'-');
        END IF;

        IF lc_upg_gl_bud.SEGMENT11_HIGH IS NOT NULL THEN
            fnd_file.put(fnd_file.output,lc_upg_gl_bud.SEGMENT11_HIGH||'-');
        END IF;

        IF lc_upg_gl_bud.SEGMENT12_HIGH IS NOT NULL THEN
            fnd_file.put(fnd_file.output,lc_upg_gl_bud.SEGMENT12_HIGH||'-');
        END IF;

        IF lc_upg_gl_bud.SEGMENT13_HIGH IS NOT NULL THEN
            fnd_file.put(fnd_file.output,lc_upg_gl_bud.SEGMENT13_HIGH||'-');
        END IF;

        IF lc_upg_gl_bud.SEGMENT14_HIGH IS NOT NULL THEN
            fnd_file.put(fnd_file.output,lc_upg_gl_bud.SEGMENT14_HIGH||'-');
        END IF;

        IF lc_upg_gl_bud.SEGMENT15_HIGH IS NOT NULL THEN
            fnd_file.put(fnd_file.output,lc_upg_gl_bud.SEGMENT15_HIGH||'-');
        END IF;

        IF lc_upg_gl_bud.SEGMENT16_HIGH IS NOT NULL THEN
            fnd_file.put(fnd_file.output,lc_upg_gl_bud.SEGMENT16_HIGH||'-');
        END IF;

        IF lc_upg_gl_bud.SEGMENT17_HIGH IS NOT NULL THEN
            fnd_file.put(fnd_file.output,lc_upg_gl_bud.SEGMENT17_HIGH||'-');
        END IF;

        IF lc_upg_gl_bud.SEGMENT18_HIGH IS NOT NULL THEN
            fnd_file.put(fnd_file.output,lc_upg_gl_bud.SEGMENT18_HIGH||'-');
        END IF;
        IF lc_upg_gl_bud.SEGMENT19_HIGH IS NOT NULL THEN
            fnd_file.put(fnd_file.output,lc_upg_gl_bud.SEGMENT19_HIGH||'-');
        END IF;

        IF lc_upg_gl_bud.SEGMENT20_HIGH IS NOT NULL THEN
            fnd_file.put(fnd_file.output,lc_upg_gl_bud.SEGMENT20_HIGH||'-');
        END IF;

        IF lc_upg_gl_bud.SEGMENT21_HIGH IS NOT NULL THEN
            fnd_file.put(fnd_file.output,lc_upg_gl_bud.SEGMENT21_HIGH||'-');
        END IF;

        IF lc_upg_gl_bud.SEGMENT22_HIGH IS NOT NULL THEN
            fnd_file.put(fnd_file.output,lc_upg_gl_bud.SEGMENT22_HIGH||'-');
        END IF;

        IF lc_upg_gl_bud.SEGMENT23_HIGH IS NOT NULL THEN
            fnd_file.put(fnd_file.output,lc_upg_gl_bud.SEGMENT23_HIGH||'-');
        END IF;

        IF lc_upg_gl_bud.SEGMENT24_HIGH IS NOT NULL THEN
            fnd_file.put(fnd_file.output,lc_upg_gl_bud.SEGMENT24_HIGH||'-');
        END IF;

        IF lc_upg_gl_bud.SEGMENT25_HIGH IS NOT NULL THEN
            fnd_file.put(fnd_file.output,lc_upg_gl_bud.SEGMENT25_HIGH||'-');
        END IF;

        IF lc_upg_gl_bud.SEGMENT26_HIGH IS NOT NULL THEN
            fnd_file.put(fnd_file.output,lc_upg_gl_bud.SEGMENT26_HIGH||'-');
        END IF;

        IF lc_upg_gl_bud.SEGMENT27_HIGH IS NOT NULL THEN
            fnd_file.put(fnd_file.output,lc_upg_gl_bud.SEGMENT27_HIGH||'-');
        END IF;

        IF lc_upg_gl_bud.SEGMENT28_HIGH IS NOT NULL THEN
            fnd_file.put(fnd_file.output,lc_upg_gl_bud.SEGMENT28_HIGH||'-');
        END IF;

        IF lc_upg_gl_bud.SEGMENT29_HIGH IS NOT NULL THEN
            fnd_file.put(fnd_file.output,lc_upg_gl_bud.SEGMENT29_HIGH||'-');
        END IF;

        IF lc_upg_gl_bud.SEGMENT30_HIGH IS NOT NULL THEN
            fnd_file.put(fnd_file.output,lc_upg_gl_bud.SEGMENT30_HIGH||'-');
        END IF;

        fnd_file.put_line(fnd_file.output,' ');

        fnd_file.put(fnd_file.output,'Associated Budgets are ');

        OPEN C_BC_OPTIONS(p_range_id);
        FETCH C_BC_OPTIONS BULK COLLECT INTO lc_bc_options;
        CLOSE C_BC_OPTIONS;

        FOR i IN 1..lc_bc_options.COUNT LOOP
            fnd_file.put(fnd_file.output,lc_bc_options(i).budget_name||', ');
        END LOOP;

        fnd_file.put_line(fnd_file.output,' ');

    EXCEPTION
        WHEN OTHERS THEN
            fnd_file.put_line(fnd_file.output, 'Module: PRINT_BUDGET_INFO => '||SQLERRM);
            errbuf := 'Module: PRINT_BUDGET_INFO => '||SQLERRM;
            retcode := -1;
            RETURN;
    END;
END;

-- Function COMPARE_BUDGETS is an overloaded function that compares two budgets.
-- This function accepts two tables which have budget information and returns
-- true if they are the same, false otherwise.
FUNCTION COMPARE_BUDGETS (p_budget_tab1 budget_type, p_budget_tab2 BC_OPTIONS_TAB) RETURN BOOLEAN
IS
	l_exists boolean;
BEGIN
	FOR i IN 1..p_budget_tab2.COUNT LOOP
		l_exists := FALSE;
		FOR j IN 1..p_budget_tab1.COUNT LOOP
			IF p_budget_tab1(j) = p_budget_tab2(i).FUNDING_BUDGET_VERSION_ID THEN
				l_exists := TRUE;
                EXIT;
			END IF;
		END LOOP;
        IF NOT l_exists THEN
            RETURN FALSE;
        END IF;
	END LOOP;

	FOR i IN 1..p_budget_tab1.COUNT LOOP
		l_exists := FALSE;
		FOR j IN 1..p_budget_tab2.COUNT LOOP
			IF p_budget_tab2(j).FUNDING_BUDGET_VERSION_ID = p_budget_tab1(i) THEN
				l_exists := TRUE;
                EXIT;
			END IF;
		END LOOP;
        IF NOT l_exists THEN
            RETURN FALSE;
        END IF;
	END LOOP;

    RETURN TRUE;
END;

-- Function COMPARE_BUDGETS is an overloaded function that compares two budgets.
-- This function accepts two tables which have budget information and returns
-- true if they are the same, false otherwise.
FUNCTION COMPARE_BUDGETS (p_budget_tab1 budget_type, p_budget_tab2 budget_type) RETURN BOOLEAN
IS
	l_exists boolean;
BEGIN
	FOR i IN 1..p_budget_tab2.COUNT LOOP
		l_exists := FALSE;
		FOR j IN 1..p_budget_tab1.COUNT LOOP
			IF p_budget_tab1(j) = p_budget_tab2(i) THEN
				l_exists := TRUE;
                EXIT;
			END IF;
		END LOOP;
        IF NOT l_exists THEN
            RETURN FALSE;
        END IF;
	END LOOP;

	FOR i IN 1..p_budget_tab1.COUNT LOOP
		l_exists := FALSE;
		FOR j IN 1..p_budget_tab2.COUNT LOOP
			IF p_budget_tab2(j) = p_budget_tab1(i) THEN
				l_exists := TRUE;
                EXIT;
			END IF;
		END LOOP;
        IF NOT l_exists THEN
            RETURN FALSE;
        END IF;
	END LOOP;

    RETURN TRUE;
END;

-- Function MERGE_BUDGETS accepts two table and creates a third table which
-- has the concatenated values of both the tables.
-- Repeated values are outputted only once
FUNCTION MERGE_BUDGETS (p_budget_tab1 budget_type, p_budget_tab2 budget_type) RETURN budget_type
IS
	l_ret_budget_tab budget_type;
	l_exists boolean;
BEGIN
	l_ret_budget_tab := budget_type();
	l_ret_budget_tab := p_budget_tab1;
	FOR i IN 1..p_budget_tab2.COUNT LOOP
		l_exists := FALSE;
		FOR j IN 1..p_budget_tab1.COUNT LOOP
            -- This check is done to ensure that repeated values are not
            -- placed twice
			IF p_budget_tab1(j) = p_budget_tab2(i) THEN
				l_exists := TRUE;
			END IF;
		END LOOP;
		IF NOT l_exists THEN
			l_ret_budget_tab.extend(1);
			l_ret_budget_tab(l_ret_budget_tab.COUNT) := p_budget_tab2(i);
		END IF;
	END LOOP;
	RETURN l_ret_budget_tab;

END MERGE_BUDGETS;

-- Function PREVIOUS_VALUE accepts a segment value and returns the value
-- that is previous to this value. Currently this supports only numeric datatype
-- Note - PLSQL implicit conversion converts from number to varchar2 and
-- viceversa
FUNCTION PREVIOUS_VALUE (p_segment_value VARCHAR2, p_data_type NUMBER) RETURN VARCHAR2
IS

	l_prev_value varchar2(30);
BEGIN
    --Data type 0 indicates the data is numeric
    IF p_data_type = 0 THEN
		l_prev_value := p_segment_value - 1;
		IF length(l_prev_value)<length(p_segment_value) THEN
			FOR i IN 1..length(p_segment_value)-length(l_prev_value) LOOP
				l_prev_value := '0'||l_prev_value;
			END LOOP;
		END IF;
        RETURN l_prev_value;
    END IF;
    RETURN NULL;
END PREVIOUS_VALUE;

-- Function NEXT_VALUE accepts a segment value and returns the value
-- that is next to this value. Currently this supports only numeric datatype
-- Note - PLSQL implicit conversion converts from number to varchar2 and
-- viceversa
FUNCTION NEXT_VALUE (p_segment_value VARCHAR2,p_data_type NUMBER) RETURN VARCHAR2
IS
	l_next_value varchar2(30);
BEGIN
    --Data type 0 indicates the data is numeric
    IF p_data_type = 0 THEN
		l_next_value := p_segment_value + 1;
		IF length(l_next_value)<length(p_segment_value) THEN
			FOR i IN 1..length(p_segment_value)-length(l_next_value) LOOP
				l_next_value := '0'||l_next_value;
			END LOOP;
		END IF;
        RETURN l_next_value;
    END IF;
    RETURN NULL;
END NEXT_VALUE;

-- Procedure SPLIT_RANGES accepts two ranges which overlap in a merging fashion
-- and then splits them. The splitted ranges are then returned. Splitting works
-- as follows:
-- Assuming the following ranges are passed:
--
--  p_segment1 = 90 to 100 B1
--  p_segment1 = 70 to 150 B2
--
-- The overlaps is split as explained below:
--
--  70 to 89 B2
--  90 to 100 B1 B2
--  101 to 150 B2
--
-- The function then returns the concatenated list of the above values through
-- p_segment_tab
--
-- Assumptions:
-- 1. This function works only when two ranges overlapping in a merge fashion
--    is provided to it. Ranges that overlap exactly and non overlapping ranges
--    should not be passed to this function.
-- 2. There is no null check in this function, valid values must be provided to it
PROCEDURE SPLIT_RANGES (p_segment1 IN segment_range_rec,
                        p_segment2 IN segment_range_rec,
                        p_segment_tab IN OUT NOCOPY segment_type,
						p_index_number IN NUMBER,
                        errbuf OUT NOCOPY VARCHAR2,
                        retcode OUT NOCOPY VARCHAR2)
IS

l_exists	BOOLEAN;
l_segment1	segment_range_rec;
l_segment2	segment_range_rec;

BEGIN

    -- Mark the segment with lower value as l_segment1 and the other as
    -- l_segment2. This is done to avoid unnecessary repetition of code.
	IF p_segment1.segment_low >= p_segment2.segment_low THEN
		l_segment1 := p_segment1;
		l_segment2 := p_segment2;
	ELSE
		l_segment1 := p_segment2;
		l_segment2 := p_segment1;
	END IF;

	IF g_debug_enabled = 1 THEN
        fnd_file.put_line(fnd_file.log, 'l_segment1.segment_low = '||l_segment1.segment_low);
        fnd_file.put_line(fnd_file.log, 'l_segment1.segment_high = '||l_segment1.segment_high);
        fnd_file.put_line(fnd_file.log, 'l_segment2.segment_low = '||l_segment2.segment_low);
        fnd_file.put_line(fnd_file.log, 'l_segment2.segment_high = '||l_segment2.segment_high);
    END IF;

    -- Corresponding segments should be compared. If wrong segment numbers are
    -- exit with error
    IF l_segment1.segment_number <> l_segment2.segment_number THEN

        fnd_file.put_line(fnd_file.log, 'Module: SPLIT_RANGES '||'Splitting failed as segment_numbers do not match');
        errbuf := 'Module: SPLIT_RANGES '||'Splitting failed as segment_numbers do not match';
        retcode := -1;
        RETURN;
    END IF;

    -- Main splitting logic starts here
    BEGIN

    IF l_segment1.segment_low >= l_segment2.segment_low THEN
        IF l_segment1.segment_low > l_segment2.segment_low THEN
            p_segment_tab.extend(1);
            p_segment_tab(p_segment_tab.COUNT).index_number := p_index_number;
            p_segment_tab(p_segment_tab.COUNT).segment_number := l_segment1.segment_number;
            p_segment_tab(p_segment_tab.COUNT).segment_low := l_segment2.segment_low;
            p_segment_tab(p_segment_tab.COUNT).segment_high := PREVIOUS_VALUE(l_segment1.segment_low,l_segment1.data_type);

            IF p_segment_tab(p_segment_tab.COUNT).segment_high IS NULL THEN
                fnd_file.put_line(fnd_file.log, 'Module: SPLIT_RANGES '||'Null value retured ');
                errbuf := 'Module: SPLIT_RANGES '||'Null value retured for PREVIOUS_VALUE(l_segment1.segment_low,l_segment1.data_type);';
                retcode := -1;
                RETURN;
            END IF;

            p_segment_tab(p_segment_tab.COUNT).budget_tab := BUDGET_TYPE();
            p_segment_tab(p_segment_tab.COUNT).budget_tab := l_segment2.budget_tab;
        END IF;



        IF l_segment1.segment_high >= l_segment2.segment_high THEN
            p_segment_tab.extend(1);
			p_segment_tab(p_segment_tab.COUNT).index_number := p_index_number;
            p_segment_tab(p_segment_tab.COUNT).segment_number := l_segment1.segment_number;
            p_segment_tab(p_segment_tab.COUNT).segment_low := l_segment1.segment_low;
            p_segment_tab(p_segment_tab.COUNT).segment_high := l_segment2.segment_high;
            p_segment_tab(p_segment_tab.COUNT).budget_tab := BUDGET_TYPE();
            p_segment_tab(p_segment_tab.COUNT).budget_tab := MERGE_BUDGETS(l_segment1.budget_tab,l_segment2.budget_tab);

            IF p_segment_tab(p_segment_tab.COUNT).budget_tab IS NULL THEN
                fnd_file.put_line(fnd_file.log, 'Module: SPLIT_RANGES '||'Null value retured ');
                errbuf := 'Module: SPLIT_RANGES '||'Null value retured for p_segment_tab(p_segment_tab.COUNT).budget_tab';
                retcode := -1;
                RETURN;
            END IF;

            IF l_segment1.segment_high > l_segment2.segment_high THEN
                p_segment_tab.extend(1);
				p_segment_tab(p_segment_tab.COUNT).index_number := p_index_number;
                p_segment_tab(p_segment_tab.COUNT).segment_number := l_segment1.segment_number;
                p_segment_tab(p_segment_tab.COUNT).segment_low := NEXT_VALUE(l_segment2.segment_high,l_segment2.data_type);

                IF p_segment_tab(p_segment_tab.COUNT).segment_low IS NULL THEN
                    fnd_file.put_line(fnd_file.log, 'Module: SPLIT_RANGES '||'Null value retured ');
                    errbuf := 'Module: SPLIT_RANGES '||'Null value retured for NEXT_VALUE(l_segment2.segment_high,l_segment2.data_type);';
                    retcode := -1;
                    RETURN;
                END IF;

                p_segment_tab(p_segment_tab.COUNT).segment_high := l_segment1.segment_high;
                p_segment_tab(p_segment_tab.COUNT).budget_tab := BUDGET_TYPE();
                p_segment_tab(p_segment_tab.COUNT).budget_tab := l_segment1.budget_tab;
            END IF;

        ELSE

            p_segment_tab.extend(1);
			p_segment_tab(p_segment_tab.COUNT).index_number := p_index_number;
            p_segment_tab(p_segment_tab.COUNT).segment_number := l_segment1.segment_number;
            p_segment_tab(p_segment_tab.COUNT).segment_low := l_segment1.segment_low;
            p_segment_tab(p_segment_tab.COUNT).segment_high := l_segment1.segment_high;
            p_segment_tab(p_segment_tab.COUNT).budget_tab := BUDGET_TYPE();
            p_segment_tab(p_segment_tab.COUNT).budget_tab := MERGE_BUDGETS(l_segment1.budget_tab,l_segment2.budget_tab);

            IF p_segment_tab(p_segment_tab.COUNT).budget_tab IS NULL THEN
                fnd_file.put_line(fnd_file.log, 'Module: SPLIT_RANGES '||'Null value retured ');
                errbuf := 'Module: SPLIT_RANGES '||'Null value retured for p_segment_tab(p_segment_tab.COUNT).budget_tab';
                retcode := -1;
                RETURN;
            END IF;

			p_segment_tab.extend(1);
			p_segment_tab(p_segment_tab.COUNT).index_number := p_index_number;
			p_segment_tab(p_segment_tab.COUNT).segment_number := l_segment1.segment_number;
			p_segment_tab(p_segment_tab.COUNT).segment_low := NEXT_VALUE(l_segment1.segment_high,l_segment1.data_type);

            IF p_segment_tab(p_segment_tab.COUNT).segment_low IS NULL THEN
                fnd_file.put_line(fnd_file.log, 'Module: SPLIT_RANGES '||'Null value retured ');
                errbuf := 'Module: SPLIT_RANGES '||'Null value retured for NEXT_VALUE(l_segment2.segment_high,l_segment2.data_type);';
                retcode := -1;
                RETURN;
            END IF;

			p_segment_tab(p_segment_tab.COUNT).segment_high := l_segment2.segment_high;
			p_segment_tab(p_segment_tab.COUNT).budget_tab := BUDGET_TYPE();
			p_segment_tab(p_segment_tab.COUNT).budget_tab := l_segment2.budget_tab;


        END IF;


    END IF;

    EXCEPTION
        WHEN OTHERS THEN
            fnd_file.put_line(fnd_file.log, 'Module: SPLIT_RANGES '||'Splitting failed '||SQLERRM);
            errbuf := 'Module: SPLIT_RANGES '||'Splitting failed '||SQLERRM;
            retcode := -1;
            RETURN;
    END;

END SPLIT_RANGES;


-- Function RECURSIVE_MERGE recursively merges the list of segments
-- returned by SPLIT_RANGES
-- RECURSIVE_MERGE works recursively. The following example describes its working:
--
--Let the following be the input:
-- Split 1 (of Segment2)
--  70 to 89 B2
--  90 to 100 B1 B2
--  101 to 150 B2
--
-- Segment3 is split as follows:
-- Split 2 (of Segment3)
--  100 to 149 B1
--  150 to 200 B1 B2
--  201 to 250 B2
--
-- Merging of the ranges Split 1 and Split 2. Merging works as follows.
-- Each row of Split 1 is compared with every row of Split 2. If they have
-- a common budget assigned to them, then a new Range is created with the
-- common budget. For the above Split 1 and Split 2, the following results:
--
--
-- Line 1: Null (Result of merging first line of Split 1 with first line of Split2)
-- Line 2: 70-150 to 89-200 B2 (Result of merging first line of Split 1 with second line of Split2)
-- Line 3: 70-201 to 89-250 B2 (Result of merging first line of Split 1 with third line of Split2)
-- Line 4: 90- 100 to 100-149 B1 (Result of merging second line of Split 1 with first line of Split2)
-- Line 5: 90-150 to 100-200 B1 B2 (Result of merging second line of Split 1 with second line of Split2)
-- Line 6: 90-201 to 100-250 B2 (Result of merging second line of Split 1 with third line of Split2)
-- Line 7: Null (Result of merging third line of Split 1 with first line of Split2)
-- Line 8: 101-150 to 150-200 B2 (Result of merging third line of Split 1 with second line of Split2)
-- Line 9: 101-201 to 150-250 B2 (Result of merging third line of Split 1 with third line of Split2)
--
-- Any redundant ranges. Redundant ranges are those whose budget list are the same and
-- have same value for all lows-highs pairs or have pairs that are continuous in nature.
--
-- For example, the following ranges are redundant:
-- 70- 150 to 89-200 B2
-- 70-201 to 89-250 B2
--
-- The above can be reduced to:
-- 1-70- 150 to 1-89-250 B2
--
-- Doing this, finally results in:
--
-- 70-150 to 89-250 B2 (Redundant merging of Line 1 and Line 2)
-- 90- 100 to 100-149 B1
-- 90-150 to 100-200 B1 B2
-- 90-201 to 150-250 B2 (Redundant merging of Line 6 and Line 9)
-- 101-150 to 150-200 B2
--
--
-- Finally all other segments are added to the result:
--
-- 1-70-150 to 1-89-250 B2
-- 1-90- 100 to 1-100-149 B1
-- 1-90-150 to 1-100-200 B1 B2
-- 1-90-201 to 1-150-250 B2
-- 1-101-150 to 1-150-200 B2
--
--
PROCEDURE RECURSIVE_MERGE (p_budget_range1 IN BUDGET_RANGE_REC,
                          p_segment_tab IN SEGMENT_TYPE,
                          p_final_budget_ranges IN OUT NOCOPY BUDGET_RANGE_TYPE,
                          p_no_of_segments IN number,
                          p_current_segment_index IN number,
                          p_segment_rec_index_tab IN SEGMENT_REC_INDEX_TYPE,
                          errbuf OUT NOCOPY VARCHAR2,
                          retcode OUT NOCOPY NUMBER)
IS
    l_segment_rec_index_tab SEGMENT_REC_INDEX_TYPE;
    l_boolean BOOLEAN;
    l_budget_tab budget_type;
    l_index NUMBER;
    l_record_exists BOOLEAN;
    l_record_index NUMBER;
    l_exact_match_count NUMBER;
    l_overlap_count NUMBER;
    l_overlap_index NUMBER;
    l_errbuf VARCHAR2(2000);
    l_retcode NUMBER;
BEGIN
    IF p_no_of_segments < p_current_segment_index THEN
        fnd_file.put_line(fnd_file.log, 'Module: RECURSIVE_MERGE '||'p_no_of_segments < p_current_segment_index');
        errbuf  := 'Module: RECURSIVE_MERGE '||'p_no_of_segments < p_current_segment_index';
        retcode := -1;
        RETURN;
    END IF;

    -- Initialize l_segment_rec_index_tab for first call
    IF p_current_segment_index = 1 THEN
        l_segment_rec_index_tab := SEGMENT_REC_INDEX_TYPE();
    ELSE
        l_segment_rec_index_tab := p_segment_rec_index_tab;
    END IF;

    -- The recursive logic works as follows. Total number of recursion is
    -- equal to the number of segments that have to be merged.
    -- If p_no_of_segments = p_current_segment_index then recursion has reached
    -- the last segment. The list of segments selected by a given recursion
    -- is available in l_segment_rec_index_tab
    -- l_segment_rec_index_tab must be analyzed and merged
    IF p_no_of_segments = p_current_segment_index THEN

        l_budget_tab := budget_type();

        -- Loop for all segments present in p_segment_tab
        FOR cnt IN 1..p_segment_tab.COUNT LOOP

            -- If p_segment_tab is the p_current_segment_index then do the
            -- processing. This ensures that only the segments that belong
            -- to the current recursion are processed
            IF p_segment_tab(cnt).index_number = p_current_segment_index THEN

                l_segment_rec_index_tab.extend(1);
                l_segment_rec_index_tab(l_segment_rec_index_tab.COUNT) := cnt;

                -- The following for loop finds the number of common budgets
                -- for the given set of segments l_segment_rec_index_tab
                -- The common budgets are then inserted into l_budget_tab
                FOR i IN 1..p_segment_tab(l_segment_rec_index_tab(1)).budget_tab.COUNT LOOP
                    l_boolean := TRUE;

                    FOR j IN 2..l_segment_rec_index_tab.COUNT LOOP

                        EXIT WHEN NOT l_boolean;

                        l_boolean := FALSE;

                        FOR k IN 1..p_segment_tab(l_segment_rec_index_tab(j)).budget_tab.COUNT LOOP
                            IF p_segment_tab(l_segment_rec_index_tab(1)).budget_tab(i)
                             = p_segment_tab(l_segment_rec_index_tab(j)).budget_tab(k) THEN
                                l_boolean := TRUE;
                                EXIT;
                            END IF;
                        END LOOP;

                    END LOOP;

                    IF l_boolean = TRUE THEN
                        l_budget_tab.extend(1);
                        l_budget_tab(l_budget_tab.COUNT) := p_segment_tab(l_segment_rec_index_tab(1)).budget_tab(i);
                    END IF;

                END LOOP; -- End p_segment_tab For

                -- The following logic builds a range with segments
                -- in l_segment_rec_index_tab and associates to the budgets
                -- given by l_budget_tab. This range is stored
                -- in p_final_budget_ranges
                IF l_budget_tab.COUNT > 0 THEN

                    -- This for loop determines if range similiar to the
                    -- current range already exists. If Yes, then that range
                    -- is updated instead of inserted one. This is to avoid
                    -- multiple records due to split
                    FOR n IN 1..p_final_budget_ranges.COUNT LOOP

                        l_exact_match_count := 0;
                        l_overlap_count := 0;
                        l_record_exists := FALSE;
                        l_overlap_index := -1;
                        IF
                        COMPARE_BUDGETS(p_final_budget_ranges(n).budget_tab,l_budget_tab)
                        THEN
                            FOR m IN 1..l_segment_rec_index_tab.COUNT LOOP
                                l_index := l_segment_rec_index_tab(m);
                                IF
                                p_final_budget_ranges(n).segment_range_tab(p_segment_tab(l_index).segment_number).segment_low
                                   = p_segment_tab(l_index).segment_low
                                AND
                                p_final_budget_ranges(n).segment_range_tab(p_segment_tab(l_index).segment_number).segment_high
                                   = p_segment_tab(l_index).segment_high
                                THEN
                                    l_exact_match_count := l_exact_match_count +1;
                                ELSE
                                    IF NEXT_VALUE(p_final_budget_ranges(n).segment_range_tab(p_segment_tab(l_index)
                                    .segment_number).segment_high
                                    ,p_final_budget_ranges(n).segment_range_tab(p_segment_tab(l_index).segment_number).data_type)
                                       = p_segment_tab(l_index).segment_low THEN
                                        l_overlap_count := l_overlap_count + 1;
                                        l_overlap_index := l_index;
                                    END IF;
                                END IF;
                            END LOOP;
                        END IF;
                        IF l_overlap_count = 1 AND l_exact_match_count = l_segment_rec_index_tab.COUNT - 1 THEN
                            l_record_index := n;
                            l_record_exists := TRUE;
                            EXIT;
                        END IF;

                    END LOOP;

                    -- l_record_exists is true if an existing range is found
                    -- If Yes, then the record is updated inserted of insertion
                    IF l_record_exists THEN

                        p_final_budget_ranges(l_record_index).segment_range_tab(p_segment_tab(l_overlap_index)
                        .segment_number).segment_high := p_segment_tab(l_overlap_index).segment_high;

                    ELSE -- Range does not exist

                        p_final_budget_ranges.extend(1);
                        p_final_budget_ranges(p_final_budget_ranges.COUNT).budget_tab := budget_type();
                        p_final_budget_ranges(p_final_budget_ranges.COUNT).budget_tab := l_budget_tab;
                        p_final_budget_ranges(p_final_budget_ranges.COUNT).segment_range_tab := segment_range_type();


                        FOR m IN 1..30 LOOP
                            p_final_budget_ranges(p_final_budget_ranges.COUNT).segment_range_tab.extend(1);
                            p_final_budget_ranges(p_final_budget_ranges.COUNT).segment_range_tab(m).data_type
                               := p_budget_range1.segment_range_tab(m).data_type;
                            p_final_budget_ranges(p_final_budget_ranges.COUNT).segment_range_tab(m).segment_low
                               := p_budget_range1.segment_range_tab(m).segment_low;
                            p_final_budget_ranges(p_final_budget_ranges.COUNT).segment_range_tab(m).segment_high
                               := p_budget_range1.segment_range_tab(m).segment_high;
                        END LOOP;

                        FOR m IN 1..l_segment_rec_index_tab.COUNT LOOP
                            l_index := l_segment_rec_index_tab(m);
                            p_final_budget_ranges(p_final_budget_ranges.COUNT).segment_range_tab(p_segment_tab(l_index)
                               .segment_number).segment_low := p_segment_tab(l_index).segment_low;
                            p_final_budget_ranges(p_final_budget_ranges.COUNT).segment_range_tab(p_segment_tab(l_index)
                               .segment_number).segment_high := p_segment_tab(l_index).segment_high;
                        END LOOP;

                    END IF;
                END IF; -- End l_budget_tab.COUNT > 0
                l_budget_tab.trim(l_budget_tab.COUNT);
                l_segment_rec_index_tab.trim;
            END IF;
        END LOOP;
    ELSE -- Else of IF p_no_of_segments = p_current_segment_index

        FOR cnt IN 1..p_segment_tab.COUNT LOOP

            -- If p_segment_tab is the p_current_segment_index then do the
            -- processing. This ensures that only the segments that belong
            -- to the current recusion are processed
            IF p_segment_tab(cnt).index_number = p_current_segment_index THEN

                -- Insert the segment selected into l_segment_rec_index_tab
                -- and then call RECURSIVE_MERGE
                l_segment_rec_index_tab.extend(1);
                l_segment_rec_index_tab(l_segment_rec_index_tab.COUNT) := cnt;

                RECURSIVE_MERGE (p_budget_range1,
                          p_segment_tab,
                          p_final_budget_ranges,
                          p_no_of_segments,
                          p_current_segment_index + 1,
                          l_segment_rec_index_tab,
                          l_errbuf,
                          l_retcode);
                IF l_retcode IS NOT NULL AND l_retcode = -1 THEN
                    retcode := l_retcode;
                    errbuf := l_errbuf;
                    RETURN;
                END IF;

                -- The segment must be deleted once the recursive process
                -- has completed to allow the next segment to be inserted
                l_segment_rec_index_tab.trim;
            END IF;
        END LOOP;
    END IF;  -- End If of IF p_no_of_segments = p_current_segment_index


END RECURSIVE_MERGE;


-- Procedure MERGE_SEGMENTS does the necessary validation and invokes
-- Recursive merge
PROCEDURE MERGE_SEGMENTS (p_budget_range1 IN BUDGET_RANGE_REC,
                          p_segment_tab IN SEGMENT_TYPE,
                          p_final_budget_ranges IN OUT NOCOPY BUDGET_RANGE_TYPE,
                          p_no_of_segments number,
                          errbuf OUT NOCOPY VARCHAR2,
                          retcode OUT NOCOPY NUMBER)




IS

    l_errbuf VARCHAR2(2000);
    l_retcode VARCHAR2(2000);
BEGIN
  IF p_budget_range1.range_id IS NULL THEN
        fnd_file.put_line(fnd_file.log, 'p_budget_range1.range_id is NULL');
        errbuf := 'p_budget_range1.range_id is NULL';
        retcode := -1;
    RETURN;
  END IF;
  RECURSIVE_MERGE(p_budget_range1,
                  p_segment_tab,
                  p_final_budget_ranges,
                  p_no_of_segments,
                  1,
                  NULL,
                  l_errbuf,
                  l_retcode);
  errbuf := l_errbuf;
  retcode := l_retcode;

END MERGE_SEGMENTS;


-- Function PRINT_MERGE_INFO Used to print the output returned by function
-- MERGE_SEGMENTS. This is used for Logging purposes only.
PROCEDURE PRINT_MERGE_INFO(p_final_budget_ranges IN BUDGET_RANGE_TYPE)
IS
BEGIN
FOR i IN 1..p_final_budget_ranges.COUNT LOOP

        FOR k IN 1..p_final_budget_ranges(i).segment_range_tab.COUNT LOOP
            IF p_final_budget_ranges(i).segment_range_tab(k).segment_low IS NOT NULL THEN
                fnd_file.put(fnd_file.log, '-'||p_final_budget_ranges(i).segment_range_tab(k).segment_low);
            END IF;
        END LOOP;
    fnd_file.put(fnd_file.log, '   to   ');

    FOR k IN 1..p_final_budget_ranges(i).segment_range_tab.COUNT LOOP
		IF p_final_budget_ranges(i).segment_range_tab(k).segment_high IS NOT NULL THEN
            fnd_file.put(fnd_file.log, '-'||p_final_budget_ranges(i).segment_range_tab(k).segment_high);
		END IF;
    END LOOP;

	FOR j IN 1..p_final_budget_ranges(i).budget_tab.COUNT LOOP
        fnd_file.put(fnd_file.log, ' '||p_final_budget_ranges(i).budget_tab(j));
	END LOOP;
        fnd_file.put_line(fnd_file.log, '');
END LOOP;
END PRINT_MERGE_INFO;


-- Function PRINT_SPLIT_INFO Used to print the output returned by function
-- SPLIT_RANGES. This is used for Logging purposes only.
PROCEDURE PRINT_SPLIT_INFO (p_segment_tab segment_type)
IS
BEGIN
    FOR i IN 1..p_segment_tab.COUNT LOOP
        fnd_file.put(fnd_file.log, p_segment_tab(i).segment_low||' to '||p_segment_tab(i).segment_high||'   ');
        FOR j IN 1..p_segment_tab(i).budget_tab.COUNT LOOP
            fnd_file.put(fnd_file.log,p_segment_tab(i).budget_tab(j));
            fnd_file.put(fnd_file.log,'');
        END LOOP;
         fnd_file.put_line(fnd_file.log,'');
    END LOOP;

END PRINT_SPLIT_INFO;


PROCEDURE DEBUG_LOG (p_log_message VARCHAR2, p_module VARCHAR2)
IS
BEGIN
    fnd_file.put_line(fnd_file.log,'Module:'||p_module||' => '||p_log_message);
END;


PROCEDURE PRINT_OUTPUT (p_output_message VARCHAR2)
IS
BEGIN
    fnd_file.put_line(fnd_file.log,p_output_message);
END;


-- PROCEDURE LOOP_AND_PROCESS does the main processing logic
-- This proceedure works as follows:
--
-- Step 1A: Table IGI_UPG_GL_BUDGET_ASSIGNMENT is scanned for occurences of
-- non merging ranges. If Non Merging ranges are found, then they are
-- migrated to the GL if the mode is "final". Otherwise they are
-- added to the report output.
--
-- Step 1B: If No records exist in table IGI_UPG_GL_BUDGET_ASSIGNMENT
-- then execute stops and control is returned to the calling procedure
--
-- Step 2: Table IGI_UPG_GL_BUDGET_ASSIGNMENT is scanned for occurences of any
-- range which exactly merges with other ranges. If such a range is found
-- then the duplicate range is deleted and the proceed continues to Step 1A.
--
-- Step 3: In this step, the remaning ranges are analyzed. The table
-- IGI_UPG_GL_BUDGET_ASSIGNMENT is scanned for two ranges which merge with
-- each other. Then the two ranges are split by calling the function SPLIT_RANGES
-- followed by RECURSIVE_MERGE. After the ranges are split they are inserted
-- back into IGI_UPG_GL_BUDGET_ASSIGNMENT. The original ranges are deleted
-- and the proceed continues to Step 1A.
--
--
PROCEDURE LOOP_AND_PROCESS (p_data_type NUMBER,
                            p_mode NUMBER,
                            errbuf           OUT NOCOPY VARCHAR2,
                            retcode          OUT NOCOPY NUMBER
                            )
IS

	TYPE BUD_ASSIGN_TAB IS TABLE OF IGI_UPG_GL_BUDGET_ASSIGNMENT%ROWTYPE;

    -- This cursor fetches all the ranges that overlap in merge manner
	CURSOR C_NON_OVERLAPPING_RANGES IS
	SELECT * FROM IGI_UPG_GL_BUDGET_ASSIGNMENT BA1
	WHERE NOT EXISTS
		(SELECT 1 FROM
		IGI_UPG_GL_BUDGET_ASSIGNMENT BA2
		WHERE BA1.RANGE_ID <> BA2.RANGE_ID
            AND BA2.ledger_id = BA1.ledger_id
            AND BA2.currency_code = BA1.currency_code
		    AND NVL(BA1.SEGMENT1_LOW,'X') <=  NVL(BA2.SEGMENT1_HIGH,'X')
			AND NVL(BA1.SEGMENT1_HIGH,'X') >= NVL(BA2.SEGMENT1_LOW,'X')
			AND NVL(BA1.SEGMENT2_LOW,'X') <=  NVL(BA2.SEGMENT2_HIGH,'X')
			AND NVL(BA1.SEGMENT2_HIGH,'X') >= NVL(BA2.SEGMENT2_LOW,'X')
		    AND NVL(BA1.SEGMENT3_LOW,'X') <=  NVL(BA2.SEGMENT3_HIGH,'X')
			AND NVL(BA1.SEGMENT3_HIGH,'X') >= NVL(BA2.SEGMENT3_LOW,'X')
			AND NVL(BA1.SEGMENT4_LOW,'X') <=  NVL(BA2.SEGMENT4_HIGH,'X')
			AND NVL(BA1.SEGMENT4_HIGH,'X') >= NVL(BA2.SEGMENT4_LOW,'X')
		    AND NVL(BA1.SEGMENT5_LOW,'X') <=  NVL(BA2.SEGMENT5_HIGH,'X')
			AND NVL(BA1.SEGMENT5_HIGH,'X') >= NVL(BA2.SEGMENT5_LOW,'X')
			AND NVL(BA1.SEGMENT6_LOW,'X') <=  NVL(BA2.SEGMENT6_HIGH,'X')
			AND NVL(BA1.SEGMENT6_HIGH,'X') >= NVL(BA2.SEGMENT6_LOW,'X')
			AND NVL(BA1.SEGMENT7_LOW,'X') <=  NVL(BA2.SEGMENT7_HIGH,'X')
			AND NVL(BA1.SEGMENT7_HIGH,'X') >= NVL(BA2.SEGMENT7_LOW,'X')
			AND NVL(BA1.SEGMENT8_LOW,'X') <=  NVL(BA2.SEGMENT8_HIGH,'X')
			AND NVL(BA1.SEGMENT8_HIGH,'X') >= NVL(BA2.SEGMENT8_LOW,'X')
			AND NVL(BA1.SEGMENT9_LOW,'X') <=  NVL(BA2.SEGMENT9_HIGH,'X')
			AND NVL(BA1.SEGMENT9_HIGH,'X') >= NVL(BA2.SEGMENT9_LOW,'X')
			AND NVL(BA1.SEGMENT10_LOW,'X') <=  NVL(BA2.SEGMENT10_HIGH,'X')
			AND NVL(BA1.SEGMENT10_HIGH,'X') >= NVL(BA2.SEGMENT10_LOW,'X')
			AND NVL(BA1.SEGMENT11_LOW,'X') <=  NVL(BA2.SEGMENT11_HIGH,'X')
			AND NVL(BA1.SEGMENT11_HIGH,'X') >= NVL(BA2.SEGMENT11_LOW,'X')
			AND NVL(BA1.SEGMENT12_LOW,'X') <=  NVL(BA2.SEGMENT12_HIGH,'X')
			AND NVL(BA1.SEGMENT12_HIGH,'X') >= NVL(BA2.SEGMENT12_LOW,'X')
			AND NVL(BA1.SEGMENT13_LOW,'X') <=  NVL(BA2.SEGMENT13_HIGH,'X')
			AND NVL(BA1.SEGMENT13_HIGH,'X') >= NVL(BA2.SEGMENT13_LOW,'X')
			AND NVL(BA1.SEGMENT14_LOW,'X') <=  NVL(BA2.SEGMENT14_HIGH,'X')
			AND NVL(BA1.SEGMENT14_HIGH,'X') >= NVL(BA2.SEGMENT14_LOW,'X')
			AND NVL(BA1.SEGMENT15_LOW,'X') <=  NVL(BA2.SEGMENT15_HIGH,'X')
			AND NVL(BA1.SEGMENT15_HIGH,'X') >= NVL(BA2.SEGMENT15_LOW,'X')
			AND NVL(BA1.SEGMENT16_LOW,'X') <=  NVL(BA2.SEGMENT16_HIGH,'X')
			AND NVL(BA1.SEGMENT16_HIGH,'X') >= NVL(BA2.SEGMENT16_LOW,'X')
			AND NVL(BA1.SEGMENT17_LOW,'X') <=  NVL(BA2.SEGMENT17_HIGH,'X')
			AND NVL(BA1.SEGMENT17_HIGH,'X') >= NVL(BA2.SEGMENT17_LOW,'X')
			AND NVL(BA1.SEGMENT18_LOW,'X') <=  NVL(BA2.SEGMENT18_HIGH,'X')
			AND NVL(BA1.SEGMENT18_HIGH,'X') >= NVL(BA2.SEGMENT18_LOW,'X')
			AND NVL(BA1.SEGMENT19_LOW,'X') <=  NVL(BA2.SEGMENT19_HIGH,'X')
			AND NVL(BA1.SEGMENT19_HIGH,'X') >= NVL(BA2.SEGMENT19_LOW,'X')
			AND NVL(BA1.SEGMENT20_LOW,'X') <=  NVL(BA2.SEGMENT20_HIGH,'X')
			AND NVL(BA1.SEGMENT20_HIGH,'X') >= NVL(BA2.SEGMENT20_LOW,'X')
			AND NVL(BA1.SEGMENT21_LOW,'X') <=  NVL(BA2.SEGMENT21_HIGH,'X')
			AND NVL(BA1.SEGMENT21_HIGH,'X') >= NVL(BA2.SEGMENT21_LOW,'X')
			AND NVL(BA1.SEGMENT22_LOW,'X') <=  NVL(BA2.SEGMENT22_HIGH,'X')
			AND NVL(BA1.SEGMENT22_HIGH,'X') >= NVL(BA2.SEGMENT22_LOW,'X')
			AND NVL(BA1.SEGMENT23_LOW,'X') <=  NVL(BA2.SEGMENT23_HIGH,'X')
			AND NVL(BA1.SEGMENT23_HIGH,'X') >= NVL(BA2.SEGMENT23_LOW,'X')
			AND NVL(BA1.SEGMENT24_LOW,'X') <=  NVL(BA2.SEGMENT24_HIGH,'X')
			AND NVL(BA1.SEGMENT24_HIGH,'X') >= NVL(BA2.SEGMENT24_LOW,'X')
			AND NVL(BA1.SEGMENT25_LOW,'X') <=  NVL(BA2.SEGMENT25_HIGH,'X')
			AND NVL(BA1.SEGMENT25_HIGH,'X') >= NVL(BA2.SEGMENT25_LOW,'X')
			AND NVL(BA1.SEGMENT26_LOW,'X') <=  NVL(BA2.SEGMENT26_HIGH,'X')
			AND NVL(BA1.SEGMENT26_HIGH,'X') >= NVL(BA2.SEGMENT26_LOW,'X')
			AND NVL(BA1.SEGMENT27_LOW,'X') <=  NVL(BA2.SEGMENT27_HIGH,'X')
			AND NVL(BA1.SEGMENT27_HIGH,'X') >= NVL(BA2.SEGMENT27_LOW,'X')
            AND NVL(BA1.SEGMENT28_LOW,'X') <=  NVL(BA2.SEGMENT28_HIGH,'X')
			AND NVL(BA1.SEGMENT28_HIGH,'X') >= NVL(BA2.SEGMENT28_LOW,'X')
			AND NVL(BA1.SEGMENT29_LOW,'X') <=  NVL(BA2.SEGMENT29_HIGH,'X')
			AND NVL(BA1.SEGMENT29_HIGH,'X') >= NVL(BA2.SEGMENT29_LOW,'X')
			AND NVL(BA1.SEGMENT30_LOW,'X') <=  NVL(BA2.SEGMENT30_HIGH,'X')
			AND NVL(BA1.SEGMENT30_HIGH,'X') >= NVL(BA2.SEGMENT30_LOW,'X')

		);

    -- This cursor fetches all the ranges that overlap with p_range_id
    -- exactly
	CURSOR C_EXACT_OVERLAPPING_RANGE(p_range_id NUMBER) IS
	SELECT * FROM IGI_UPG_GL_BUDGET_ASSIGNMENT BA1
	WHERE EXISTS
		(SELECT 1 FROM
		IGI_UPG_GL_BUDGET_ASSIGNMENT BA2
		WHERE
            BA2.range_id = p_range_id
            AND BA2.ledger_id = BA1.ledger_id
            AND BA2.currency_code = BA1.currency_code
			AND BA1.RANGE_ID <> BA2.RANGE_ID
		    AND NVL(BA1.SEGMENT1_LOW,'X') =  NVL(BA2.SEGMENT1_LOW,'X')
			AND NVL(BA1.SEGMENT1_HIGH,'X') = NVL(BA2.SEGMENT1_HIGH,'X')
			AND NVL(BA1.SEGMENT2_LOW,'X') =  NVL(BA2.SEGMENT2_LOW,'X')
			AND NVL(BA1.SEGMENT2_HIGH,'X') = NVL(BA2.SEGMENT2_HIGH,'X')
		    AND NVL(BA1.SEGMENT3_LOW,'X') =  NVL(BA2.SEGMENT3_LOW,'X')
			AND NVL(BA1.SEGMENT3_HIGH,'X') = NVL(BA2.SEGMENT3_HIGH,'X')
			AND NVL(BA1.SEGMENT4_LOW,'X') =  NVL(BA2.SEGMENT4_LOW,'X')
			AND NVL(BA1.SEGMENT4_HIGH,'X') = NVL(BA2.SEGMENT4_HIGH,'X')
		    AND NVL(BA1.SEGMENT5_LOW,'X') =  NVL(BA2.SEGMENT5_LOW,'X')
			AND NVL(BA1.SEGMENT5_HIGH,'X') = NVL(BA2.SEGMENT5_HIGH,'X')
			AND NVL(BA1.SEGMENT6_LOW,'X') =  NVL(BA2.SEGMENT6_LOW,'X')
			AND NVL(BA1.SEGMENT6_HIGH,'X') = NVL(BA2.SEGMENT6_HIGH,'X')
			AND NVL(BA1.SEGMENT7_LOW,'X') =  NVL(BA2.SEGMENT7_LOW,'X')
			AND NVL(BA1.SEGMENT7_HIGH,'X') = NVL(BA2.SEGMENT7_HIGH,'X')
			AND NVL(BA1.SEGMENT8_LOW,'X') =  NVL(BA2.SEGMENT8_LOW,'X')
			AND NVL(BA1.SEGMENT8_HIGH,'X') = NVL(BA2.SEGMENT8_HIGH,'X')
			AND NVL(BA1.SEGMENT9_LOW,'X') =  NVL(BA2.SEGMENT9_LOW,'X')
			AND NVL(BA1.SEGMENT9_HIGH,'X') = NVL(BA2.SEGMENT9_HIGH,'X')
			AND NVL(BA1.SEGMENT10_LOW,'X') =  NVL(BA2.SEGMENT10_LOW,'X')
			AND NVL(BA1.SEGMENT10_HIGH,'X') = NVL(BA2.SEGMENT10_HIGH,'X')
			AND NVL(BA1.SEGMENT11_LOW,'X') =  NVL(BA2.SEGMENT11_LOW,'X')
			AND NVL(BA1.SEGMENT11_HIGH,'X') = NVL(BA2.SEGMENT11_HIGH,'X')
			AND NVL(BA1.SEGMENT12_LOW,'X') =  NVL(BA2.SEGMENT12_LOW,'X')
			AND NVL(BA1.SEGMENT12_HIGH,'X') = NVL(BA2.SEGMENT12_HIGH,'X')
			AND NVL(BA1.SEGMENT13_LOW,'X') =  NVL(BA2.SEGMENT13_LOW,'X')
			AND NVL(BA1.SEGMENT13_HIGH,'X') = NVL(BA2.SEGMENT13_HIGH,'X')
			AND NVL(BA1.SEGMENT14_LOW,'X') =  NVL(BA2.SEGMENT14_LOW,'X')
			AND NVL(BA1.SEGMENT14_HIGH,'X') = NVL(BA2.SEGMENT14_HIGH,'X')
			AND NVL(BA1.SEGMENT15_LOW,'X') =  NVL(BA2.SEGMENT15_LOW,'X')
			AND NVL(BA1.SEGMENT15_HIGH,'X') = NVL(BA2.SEGMENT15_HIGH,'X')
			AND NVL(BA1.SEGMENT16_LOW,'X') =  NVL(BA2.SEGMENT16_LOW,'X')
			AND NVL(BA1.SEGMENT16_HIGH,'X') = NVL(BA2.SEGMENT16_HIGH,'X')
			AND NVL(BA1.SEGMENT17_LOW,'X') =  NVL(BA2.SEGMENT17_LOW,'X')
			AND NVL(BA1.SEGMENT17_HIGH,'X') = NVL(BA2.SEGMENT17_HIGH,'X')
			AND NVL(BA1.SEGMENT18_LOW,'X') =  NVL(BA2.SEGMENT18_LOW,'X')
			AND NVL(BA1.SEGMENT18_HIGH,'X') = NVL(BA2.SEGMENT18_HIGH,'X')
			AND NVL(BA1.SEGMENT19_LOW,'X') =  NVL(BA2.SEGMENT19_LOW,'X')
			AND NVL(BA1.SEGMENT19_HIGH,'X') = NVL(BA2.SEGMENT19_HIGH,'X')
			AND NVL(BA1.SEGMENT20_LOW,'X') =  NVL(BA2.SEGMENT20_LOW,'X')
			AND NVL(BA1.SEGMENT20_HIGH,'X') = NVL(BA2.SEGMENT20_HIGH,'X')
			AND NVL(BA1.SEGMENT21_LOW,'X') =  NVL(BA2.SEGMENT21_LOW,'X')
			AND NVL(BA1.SEGMENT21_HIGH,'X') = NVL(BA2.SEGMENT21_HIGH,'X')
			AND NVL(BA1.SEGMENT22_LOW,'X') =  NVL(BA2.SEGMENT22_LOW,'X')
			AND NVL(BA1.SEGMENT22_HIGH,'X') = NVL(BA2.SEGMENT22_HIGH,'X')
			AND NVL(BA1.SEGMENT23_LOW,'X') =  NVL(BA2.SEGMENT23_LOW,'X')
			AND NVL(BA1.SEGMENT23_HIGH,'X') = NVL(BA2.SEGMENT23_HIGH,'X')
			AND NVL(BA1.SEGMENT24_LOW,'X') =  NVL(BA2.SEGMENT24_LOW,'X')
			AND NVL(BA1.SEGMENT24_HIGH,'X') = NVL(BA2.SEGMENT24_HIGH,'X')
			AND NVL(BA1.SEGMENT25_LOW,'X') =  NVL(BA2.SEGMENT25_LOW,'X')
			AND NVL(BA1.SEGMENT25_HIGH,'X') = NVL(BA2.SEGMENT25_HIGH,'X')
			AND NVL(BA1.SEGMENT26_LOW,'X') =  NVL(BA2.SEGMENT26_LOW,'X')
			AND NVL(BA1.SEGMENT26_HIGH,'X') = NVL(BA2.SEGMENT26_HIGH,'X')
			AND NVL(BA1.SEGMENT27_LOW,'X') =  NVL(BA2.SEGMENT27_LOW,'X')
			AND NVL(BA1.SEGMENT27_HIGH,'X') = NVL(BA2.SEGMENT27_HIGH,'X')
            AND NVL(BA1.SEGMENT28_LOW,'X') =  NVL(BA2.SEGMENT28_LOW,'X')
			AND NVL(BA1.SEGMENT28_HIGH,'X') = NVL(BA2.SEGMENT28_HIGH,'X')
			AND NVL(BA1.SEGMENT29_LOW,'X') =  NVL(BA2.SEGMENT29_LOW,'X')
			AND NVL(BA1.SEGMENT29_HIGH,'X') = NVL(BA2.SEGMENT29_HIGH,'X')
			AND NVL(BA1.SEGMENT30_LOW,'X') =  NVL(BA2.SEGMENT30_LOW,'X')
			AND NVL(BA1.SEGMENT30_HIGH,'X') = NVL(BA2.SEGMENT30_HIGH,'X')
		);

    -- This cursor fetches all the ranges that overlap with p_range_id
    -- in a merge fashion
	CURSOR C_OVERLAPPING_RANGE(p_range_id NUMBER) IS
	SELECT * FROM IGI_UPG_GL_BUDGET_ASSIGNMENT BA1
	WHERE EXISTS
		(SELECT 1 FROM
		IGI_UPG_GL_BUDGET_ASSIGNMENT BA2
		WHERE
            BA2.range_id = p_range_id
            AND BA2.ledger_id = BA1.ledger_id
            AND BA2.currency_code = BA1.currency_code
			AND BA1.RANGE_ID <> BA2.RANGE_ID
		    AND NVL(BA1.SEGMENT1_LOW,'X') <=  NVL(BA2.SEGMENT1_HIGH,'X')
			AND NVL(BA1.SEGMENT1_HIGH,'X') >= NVL(BA2.SEGMENT1_LOW,'X')
			AND NVL(BA1.SEGMENT2_LOW,'X') <=  NVL(BA2.SEGMENT2_HIGH,'X')
			AND NVL(BA1.SEGMENT2_HIGH,'X') >= NVL(BA2.SEGMENT2_LOW,'X')
		    AND NVL(BA1.SEGMENT3_LOW,'X') <=  NVL(BA2.SEGMENT3_HIGH,'X')
			AND NVL(BA1.SEGMENT3_HIGH,'X') >= NVL(BA2.SEGMENT3_LOW,'X')
			AND NVL(BA1.SEGMENT4_LOW,'X') <=  NVL(BA2.SEGMENT4_HIGH,'X')
			AND NVL(BA1.SEGMENT4_HIGH,'X') >= NVL(BA2.SEGMENT4_LOW,'X')
		    AND NVL(BA1.SEGMENT5_LOW,'X') <=  NVL(BA2.SEGMENT5_HIGH,'X')
			AND NVL(BA1.SEGMENT5_HIGH,'X') >= NVL(BA2.SEGMENT5_LOW,'X')
			AND NVL(BA1.SEGMENT6_LOW,'X') <=  NVL(BA2.SEGMENT6_HIGH,'X')
			AND NVL(BA1.SEGMENT6_HIGH,'X') >= NVL(BA2.SEGMENT6_LOW,'X')
			AND NVL(BA1.SEGMENT7_LOW,'X') <=  NVL(BA2.SEGMENT7_HIGH,'X')
			AND NVL(BA1.SEGMENT7_HIGH,'X') >= NVL(BA2.SEGMENT7_LOW,'X')
			AND NVL(BA1.SEGMENT8_LOW,'X') <=  NVL(BA2.SEGMENT8_HIGH,'X')
			AND NVL(BA1.SEGMENT8_HIGH,'X') >= NVL(BA2.SEGMENT8_LOW,'X')
			AND NVL(BA1.SEGMENT9_LOW,'X') <=  NVL(BA2.SEGMENT9_HIGH,'X')
			AND NVL(BA1.SEGMENT9_HIGH,'X') >= NVL(BA2.SEGMENT9_LOW,'X')
			AND NVL(BA1.SEGMENT10_LOW,'X') <=  NVL(BA2.SEGMENT10_HIGH,'X')
			AND NVL(BA1.SEGMENT10_HIGH,'X') >= NVL(BA2.SEGMENT10_LOW,'X')
			AND NVL(BA1.SEGMENT11_LOW,'X') <=  NVL(BA2.SEGMENT11_HIGH,'X')
			AND NVL(BA1.SEGMENT11_HIGH,'X') >= NVL(BA2.SEGMENT11_LOW,'X')
			AND NVL(BA1.SEGMENT12_LOW,'X') <=  NVL(BA2.SEGMENT12_HIGH,'X')
			AND NVL(BA1.SEGMENT12_HIGH,'X') >= NVL(BA2.SEGMENT12_LOW,'X')
			AND NVL(BA1.SEGMENT13_LOW,'X') <=  NVL(BA2.SEGMENT13_HIGH,'X')
			AND NVL(BA1.SEGMENT13_HIGH,'X') >= NVL(BA2.SEGMENT13_LOW,'X')
			AND NVL(BA1.SEGMENT14_LOW,'X') <=  NVL(BA2.SEGMENT14_HIGH,'X')
			AND NVL(BA1.SEGMENT14_HIGH,'X') >= NVL(BA2.SEGMENT14_LOW,'X')
			AND NVL(BA1.SEGMENT15_LOW,'X') <=  NVL(BA2.SEGMENT15_HIGH,'X')
			AND NVL(BA1.SEGMENT15_HIGH,'X') >= NVL(BA2.SEGMENT15_LOW,'X')
			AND NVL(BA1.SEGMENT16_LOW,'X') <=  NVL(BA2.SEGMENT16_HIGH,'X')
			AND NVL(BA1.SEGMENT16_HIGH,'X') >= NVL(BA2.SEGMENT16_LOW,'X')
			AND NVL(BA1.SEGMENT17_LOW,'X') <=  NVL(BA2.SEGMENT17_HIGH,'X')
			AND NVL(BA1.SEGMENT17_HIGH,'X') >= NVL(BA2.SEGMENT17_LOW,'X')
			AND NVL(BA1.SEGMENT18_LOW,'X') <=  NVL(BA2.SEGMENT18_HIGH,'X')
			AND NVL(BA1.SEGMENT18_HIGH,'X') >= NVL(BA2.SEGMENT18_LOW,'X')
			AND NVL(BA1.SEGMENT19_LOW,'X') <=  NVL(BA2.SEGMENT19_HIGH,'X')
			AND NVL(BA1.SEGMENT19_HIGH,'X') >= NVL(BA2.SEGMENT19_LOW,'X')
			AND NVL(BA1.SEGMENT20_LOW,'X') <=  NVL(BA2.SEGMENT20_HIGH,'X')
			AND NVL(BA1.SEGMENT20_HIGH,'X') >= NVL(BA2.SEGMENT20_LOW,'X')
			AND NVL(BA1.SEGMENT21_LOW,'X') <=  NVL(BA2.SEGMENT21_HIGH,'X')
			AND NVL(BA1.SEGMENT21_HIGH,'X') >= NVL(BA2.SEGMENT21_LOW,'X')
			AND NVL(BA1.SEGMENT22_LOW,'X') <=  NVL(BA2.SEGMENT22_HIGH,'X')
			AND NVL(BA1.SEGMENT22_HIGH,'X') >= NVL(BA2.SEGMENT22_LOW,'X')
			AND NVL(BA1.SEGMENT23_LOW,'X') <=  NVL(BA2.SEGMENT23_HIGH,'X')
			AND NVL(BA1.SEGMENT23_HIGH,'X') >= NVL(BA2.SEGMENT23_LOW,'X')
			AND NVL(BA1.SEGMENT24_LOW,'X') <=  NVL(BA2.SEGMENT24_HIGH,'X')
			AND NVL(BA1.SEGMENT24_HIGH,'X') >= NVL(BA2.SEGMENT24_LOW,'X')
			AND NVL(BA1.SEGMENT25_LOW,'X') <=  NVL(BA2.SEGMENT25_HIGH,'X')
			AND NVL(BA1.SEGMENT25_HIGH,'X') >= NVL(BA2.SEGMENT25_LOW,'X')
			AND NVL(BA1.SEGMENT26_LOW,'X') <=  NVL(BA2.SEGMENT26_HIGH,'X')
			AND NVL(BA1.SEGMENT26_HIGH,'X') >= NVL(BA2.SEGMENT26_LOW,'X')
			AND NVL(BA1.SEGMENT27_LOW,'X') <=  NVL(BA2.SEGMENT27_HIGH,'X')
			AND NVL(BA1.SEGMENT27_HIGH,'X') >= NVL(BA2.SEGMENT27_LOW,'X')
            AND NVL(BA1.SEGMENT28_LOW,'X') <=  NVL(BA2.SEGMENT28_HIGH,'X')
			AND NVL(BA1.SEGMENT28_HIGH,'X') >= NVL(BA2.SEGMENT28_LOW,'X')
			AND NVL(BA1.SEGMENT29_LOW,'X') <=  NVL(BA2.SEGMENT29_HIGH,'X')
			AND NVL(BA1.SEGMENT29_HIGH,'X') >= NVL(BA2.SEGMENT29_LOW,'X')
			AND NVL(BA1.SEGMENT30_LOW,'X') <=  NVL(BA2.SEGMENT30_HIGH,'X')
			AND NVL(BA1.SEGMENT30_HIGH,'X') >= NVL(BA2.SEGMENT30_LOW,'X')
		);

    -- This cursor fetches all the ranges
	CURSOR C_ALL_RANGES IS
	SELECT * FROM IGI_UPG_GL_BUDGET_ASSIGNMENT BA1;

    -- This cursor fetches all the budgets associated to p_range_id
	CURSOR C_BC_OPTIONS (p_range_id NUMBER)
	IS
	SELECT * FROM IGI_UPG_GL_BUDORG_BC_OPTIONS
	WHERE RANGE_ID = p_range_id;

	TYPE non_overlapping_ranges_tab IS TABLE OF C_NON_OVERLAPPING_RANGES%ROWTYPE;

    lc_non_overlapping_ranges non_overlapping_ranges_tab;

	lc_exact_merge_range1 IGI_UPG_GL_BUDGET_ASSIGNMENT%ROWTYPE;
	lc_exact_merge_range1_bc BC_OPTIONS_TAB;

	lc_exact_merge_range2 IGI_UPG_GL_BUDGET_ASSIGNMENT%ROWTYPE;
	lc_exact_merge_range2_bc BC_OPTIONS_TAB;



	lc_merge_range1 IGI_UPG_GL_BUDGET_ASSIGNMENT%ROWTYPE;
	lc_merge_range1_bc BC_OPTIONS_TAB;

	lc_merge_range2 IGI_UPG_GL_BUDGET_ASSIGNMENT%ROWTYPE;
	lc_merge_range2_bc BC_OPTIONS_TAB;

	p_segment1 segment_range_rec;
	p_segment2 segment_range_rec;

    -- Variable to store the number of segments that overlap within a given
    -- range
	l_index_number NUMBER;

    -- Local variable to store the data type
	l_data_type NUMBER;

    -- Boolean variable used to Step 1B to store overlap details
    l_exact_overlap_exists BOOLEAN;

    -- Stores the output of PROCEDURE SPLIT_SEGMENTS
    p_segment_tab segment_type;

    -- Parameters fed to PROCEDURE MERGE_SEGMENTS
	p_budget_range1 BUDGET_RANGE_REC;
	p_budget_range2 BUDGET_RANGE_REC;

    -- Stores the final budget ranges returned after the split
	l_final_budget_ranges BUDGET_RANGE_TYPE;

    -- This is a local variable used to emulate the behavior of a sequence
    -- A local sequence emulation is used to avoid unnecessary increment
    -- of the GL sequence gl_budget_assignment_ranges_s
	l_range_id_seq NUMBER(38);

    -- Local variable to store the sequence number of the budget ranges
    -- This is used in Step 3
	l_seq_number NUMBER;

    -- Variable used in Step 1 to store the range_id
    l_actual_range_id NUMBER(38);

    -- Local variable to store error buffer and error code
    l_errbuf VARCHAR2(2000);
    l_retcode NUMBER;

    -- Boolean variable used in Step 3 to determine if a row was inserted or not
    -- Error handling is based on value this variable has
    l_inserted BOOLEAN;

BEGIN

	l_data_type := p_data_type;
    fnd_file.put_line(fnd_file.output,'Ledger - Budget Organization - Currency - Range From - Range To ');
    BEGIN
        SELECT gl_budget_assignment_ranges_s.NEXTVAL
        INTO l_range_id_seq
        FROM dual;
        l_range_id_seq := l_range_id_seq + 1;
    EXCEPTION
        WHEN OTHERS THEN
            fnd_file.put_line(fnd_file.output, 'Error fetching sequence value from gl_budget_assignment_ranges_s');
            fnd_file.put_line(fnd_file.log, 'Module: LOOP_AND_PROCESS =>'||'Error fetching sequence value
                                                                          from gl_budget_assignment_ranges_s');
            errbuf  := 'Module: LOOP_AND_PROCESS => Error fetching sequence value from gl_budget_assignment_ranges_s';
            retcode := -1;
            RETURN;
    END;

	IF l_range_id_seq IS NULL OR l_range_id_seq = 0 THEN
        l_range_id_seq := 0;
    END IF;

    LOOP

        -- Start of Step 1A

        l_exact_overlap_exists := FALSE;
        --First open NON)OVERLAPPING_RANGES and put them into GL table
        OPEN C_NON_OVERLAPPING_RANGES;
        FETCH C_NON_OVERLAPPING_RANGES BULK COLLECT INTO lc_non_overlapping_ranges;
        CLOSE C_NON_OVERLAPPING_RANGES;



        FOR i IN 1..lc_non_overlapping_ranges.COUNT LOOP
           IF p_mode = 1 THEN
                BEGIN
                    SELECT gl_budget_assignment_ranges_s.NEXTVAL
                    INTO l_actual_range_id
                    FROM dual;
                EXCEPTION
                    WHEN OTHERS THEN
                        fnd_file.put_line(fnd_file.output, 'Error fetching sequence value from gl_budget_assignment_ranges_s');
                        fnd_file.put_line(fnd_file.log, 'Module: LOOP_AND_PROCESS (overlap) =>'
                                           ||'Error fetching sequence value from gl_budget_assignment_ranges_s');
                        errbuf  := 'Module: LOOP_AND_PROCESS (overlap) => Error fetching sequence value from gl_budget_assignment_ranges_s';
                        retcode := -1;
                        RETURN;
                END;

                PRINT_BUDGET_INFO(lc_non_overlapping_ranges(i).range_id,
                                  l_errbuf,
                                  l_retcode);

                IF l_retcode IS NOT NULL and l_retcode = -1 THEN
                    errbuf := l_errbuf;
                    retcode := l_retcode;
                    RETURN;
                END IF;

                BEGIN

                INSERT INTO IGI_EFC_UPG_BACKUP_INFO (range_id) VALUES (l_actual_range_id);

                INSERT INTO GL_BUDGET_ASSIGNMENT_RANGES
                (
                BUDGET_ENTITY_ID,
                LEDGER_ID,
                CURRENCY_CODE,
                ENTRY_CODE,
                RANGE_ID,
                STATUS,
                LAST_UPDATE_DATE,
                AUTOMATIC_ENCUMBRANCE_FLAG,
                CREATED_BY,
                CREATION_DATE,
                FUNDS_CHECK_LEVEL_CODE,
                LAST_UPDATED_BY,
                LAST_UPDATE_LOGIN,
                SEQUENCE_NUMBER,
                SEGMENT1_LOW,
                SEGMENT1_HIGH,
                SEGMENT2_LOW,
                SEGMENT2_HIGH,
                SEGMENT3_LOW,
                SEGMENT3_HIGH,
                SEGMENT4_LOW,
                SEGMENT4_HIGH,
                SEGMENT5_LOW,
                SEGMENT5_HIGH,
                SEGMENT6_LOW,
                SEGMENT6_HIGH,
                SEGMENT7_LOW,
                SEGMENT7_HIGH,
                SEGMENT8_LOW,
                SEGMENT8_HIGH,
                SEGMENT9_LOW,
                SEGMENT9_HIGH,
                SEGMENT10_LOW,
                SEGMENT10_HIGH,
                SEGMENT11_LOW,
                SEGMENT11_HIGH,
                SEGMENT12_LOW,
                SEGMENT12_HIGH,
                SEGMENT13_LOW,
                SEGMENT13_HIGH,
                SEGMENT14_LOW,
                SEGMENT14_HIGH,
                SEGMENT15_LOW,
                SEGMENT15_HIGH,
                SEGMENT16_LOW,
                SEGMENT16_HIGH,
                SEGMENT17_LOW,
                SEGMENT17_HIGH,
                SEGMENT18_LOW,
                SEGMENT18_HIGH,
                SEGMENT19_LOW,
                SEGMENT19_HIGH,
                SEGMENT20_LOW,
                SEGMENT20_HIGH,
                SEGMENT21_LOW,
                SEGMENT21_HIGH,
                SEGMENT22_LOW,
                SEGMENT22_HIGH,
                SEGMENT23_LOW,
                SEGMENT23_HIGH,
                SEGMENT24_LOW,
                SEGMENT24_HIGH,
                SEGMENT25_LOW,
                SEGMENT25_HIGH,
                SEGMENT26_LOW,
                SEGMENT26_HIGH,
                SEGMENT27_LOW,
                SEGMENT27_HIGH,
                SEGMENT28_LOW,
                SEGMENT28_HIGH,
                SEGMENT29_LOW,
                SEGMENT29_HIGH,
                SEGMENT30_LOW,
                SEGMENT30_HIGH,
                AMOUNT_TYPE,
                BOUNDARY_CODE,
                CONTEXT,
                FUNDING_BUDGET_VERSION_ID,
                PROGRAM_APPLICATION_ID,
                PROGRAM_ID,
                PROGRAM_UPDATE_DATE,
                REQUEST_ID,
                ATTRIBUTE1,
                ATTRIBUTE2,
                ATTRIBUTE3,
                ATTRIBUTE4,
                ATTRIBUTE5,
                ATTRIBUTE6,
                ATTRIBUTE7,
                ATTRIBUTE8,
                ATTRIBUTE9,
                ATTRIBUTE10,
                ATTRIBUTE11,
                ATTRIBUTE12,
                ATTRIBUTE13,
                ATTRIBUTE14,
                ATTRIBUTE15
                )

                VALUES (
                lc_non_overlapping_ranges(i).budget_entity_id,
                lc_non_overlapping_ranges(i).ledger_id,
                lc_non_overlapping_ranges(i).currency_code,
                lc_non_overlapping_ranges(i).entry_code,
                l_actual_range_id,
                'A',
                sysdate,
                lc_non_overlapping_ranges(i).automatic_encumbrance_flag,
                lc_non_overlapping_ranges(i).created_by,
                lc_non_overlapping_ranges(i).creation_date,
                lc_non_overlapping_ranges(i).funds_check_level_code,
                lc_non_overlapping_ranges(i).last_updated_by,
                lc_non_overlapping_ranges(i).last_update_login,
                lc_non_overlapping_ranges(i).sequence_number,
                lc_non_overlapping_ranges(i).SEGMENT1_LOW,
                lc_non_overlapping_ranges(i).SEGMENT1_HIGH,
                lc_non_overlapping_ranges(i).SEGMENT2_LOW,
                lc_non_overlapping_ranges(i).SEGMENT2_HIGH,
                lc_non_overlapping_ranges(i).SEGMENT3_LOW,
                lc_non_overlapping_ranges(i).SEGMENT3_HIGH,
                lc_non_overlapping_ranges(i).SEGMENT4_LOW,
                lc_non_overlapping_ranges(i).SEGMENT4_HIGH,
                lc_non_overlapping_ranges(i).SEGMENT5_LOW,
                lc_non_overlapping_ranges(i).SEGMENT5_HIGH,
                lc_non_overlapping_ranges(i).SEGMENT6_LOW,
                lc_non_overlapping_ranges(i).SEGMENT6_HIGH,
                lc_non_overlapping_ranges(i).SEGMENT7_LOW,
                lc_non_overlapping_ranges(i).SEGMENT7_HIGH,
                lc_non_overlapping_ranges(i).SEGMENT8_LOW,
                lc_non_overlapping_ranges(i).SEGMENT8_HIGH,
                lc_non_overlapping_ranges(i).SEGMENT9_LOW,
                lc_non_overlapping_ranges(i).SEGMENT9_HIGH,
                lc_non_overlapping_ranges(i).SEGMENT10_LOW,
                lc_non_overlapping_ranges(i).SEGMENT10_HIGH,
                lc_non_overlapping_ranges(i).SEGMENT11_LOW,
                lc_non_overlapping_ranges(i).SEGMENT11_HIGH,
                lc_non_overlapping_ranges(i).SEGMENT12_LOW,
                lc_non_overlapping_ranges(i).SEGMENT12_HIGH,
                lc_non_overlapping_ranges(i).SEGMENT13_LOW,
                lc_non_overlapping_ranges(i).SEGMENT13_HIGH,
                lc_non_overlapping_ranges(i).SEGMENT14_LOW,
                lc_non_overlapping_ranges(i).SEGMENT14_HIGH,
                lc_non_overlapping_ranges(i).SEGMENT15_LOW,
                lc_non_overlapping_ranges(i).SEGMENT15_HIGH,
                lc_non_overlapping_ranges(i).SEGMENT16_LOW,
                lc_non_overlapping_ranges(i).SEGMENT16_HIGH,
                lc_non_overlapping_ranges(i).SEGMENT17_LOW,
                lc_non_overlapping_ranges(i).SEGMENT17_HIGH,
                lc_non_overlapping_ranges(i).SEGMENT18_LOW,
                lc_non_overlapping_ranges(i).SEGMENT18_HIGH,
                lc_non_overlapping_ranges(i).SEGMENT19_LOW,
                lc_non_overlapping_ranges(i).SEGMENT19_HIGH,
                lc_non_overlapping_ranges(i).SEGMENT20_LOW,
                lc_non_overlapping_ranges(i).SEGMENT20_HIGH,
                lc_non_overlapping_ranges(i).SEGMENT21_LOW,
                lc_non_overlapping_ranges(i).SEGMENT21_HIGH,
                lc_non_overlapping_ranges(i).SEGMENT22_LOW,
                lc_non_overlapping_ranges(i).SEGMENT22_HIGH,
                lc_non_overlapping_ranges(i).SEGMENT23_LOW,
                lc_non_overlapping_ranges(i).SEGMENT23_HIGH,
                lc_non_overlapping_ranges(i).SEGMENT24_LOW,
                lc_non_overlapping_ranges(i).SEGMENT24_HIGH,
                lc_non_overlapping_ranges(i).SEGMENT25_LOW,
                lc_non_overlapping_ranges(i).SEGMENT25_HIGH,
                lc_non_overlapping_ranges(i).SEGMENT26_LOW,
                lc_non_overlapping_ranges(i).SEGMENT26_HIGH,
                lc_non_overlapping_ranges(i).SEGMENT27_LOW,
                lc_non_overlapping_ranges(i).SEGMENT27_HIGH,
                lc_non_overlapping_ranges(i).SEGMENT28_LOW,
                lc_non_overlapping_ranges(i).SEGMENT28_HIGH,
                lc_non_overlapping_ranges(i).SEGMENT29_LOW,
                lc_non_overlapping_ranges(i).SEGMENT29_HIGH,
                lc_non_overlapping_ranges(i).SEGMENT30_LOW,
                lc_non_overlapping_ranges(i).SEGMENT30_HIGH,
                lc_non_overlapping_ranges(i).amount_type,
                lc_non_overlapping_ranges(i).boundary_code,
                lc_non_overlapping_ranges(i).context,
                lc_non_overlapping_ranges(i).funding_budget_version_id,
                lc_non_overlapping_ranges(i).program_application_id,
                lc_non_overlapping_ranges(i).program_id,
                lc_non_overlapping_ranges(i).program_update_date,
                lc_non_overlapping_ranges(i).request_id,
                lc_non_overlapping_ranges(i).attribute1,
                lc_non_overlapping_ranges(i).attribute2,
                lc_non_overlapping_ranges(i).attribute3,
                lc_non_overlapping_ranges(i).attribute4,
                lc_non_overlapping_ranges(i).attribute5,
                lc_non_overlapping_ranges(i).attribute6,
                lc_non_overlapping_ranges(i).attribute7,
                lc_non_overlapping_ranges(i).attribute8,
                lc_non_overlapping_ranges(i).attribute9,
                lc_non_overlapping_ranges(i).attribute10,
                lc_non_overlapping_ranges(i).attribute11,
                lc_non_overlapping_ranges(i).attribute12,
                lc_non_overlapping_ranges(i).attribute13,
                lc_non_overlapping_ranges(i).attribute14,
                lc_non_overlapping_ranges(i).attribute15
                );

                INSERT INTO GL_BUDORG_BC_OPTIONS
                (
                RANGE_ID,
                FUNDING_BUDGET_VERSION_ID,
                FUNDS_CHECK_LEVEL_CODE,
                AMOUNT_TYPE,
                BOUNDARY_CODE,
                CREATED_BY,
                CREATION_DATE,
                LAST_UPDATED_BY,
                LAST_UPDATE_LOGIN,
                LAST_UPDATE_DATE
                )
                SELECT
                l_actual_range_id,
                FUNDING_BUDGET_VERSION_ID,
                FUNDS_CHECK_LEVEL_CODE,
                AMOUNT_TYPE,
                BOUNDARY_CODE,
                CREATED_BY,
                CREATION_DATE,
                LAST_UPDATED_BY,
                LAST_UPDATE_LOGIN,
                LAST_UPDATE_DATE
                FROM IGI_UPG_GL_BUDORG_BC_OPTIONS
                WHERE RANGE_ID = lc_non_overlapping_ranges(i).range_id;


                INSERT_ENTITY(lc_non_overlapping_ranges(i).ledger_id,
                    lc_non_overlapping_ranges(i).budget_entity_id,
                    l_errbuf,
                    l_retcode);

                IF l_retcode IS NOT NULL and l_retcode = -1 THEN
                    errbuf := l_errbuf;
                    retcode := l_retcode;
                    RETURN;
                END IF;

                DELETE FROM IGI_UPG_GL_BUDORG_BC_OPTIONS WHERE RANGE_ID = lc_non_overlapping_ranges(i).range_id;

                DELETE FROM IGI_UPG_GL_BUDGET_ASSIGNMENT WHERE RANGE_ID = lc_non_overlapping_ranges(i).range_id;



                EXCEPTION
                    WHEN OTHERS THEN
                        fnd_file.put_line(fnd_file.output, 'Error processing demerged data');
                        fnd_file.put_line(fnd_file.log, 'Module: LOOP_AND_PROCESS =>'||'Error processing demerged data =>'||SQLERRM);
                        errbuf  := 'Module: LOOP_AND_PROCESS =>'||'Error processing demerged data =>'||SQLERRM;
                        retcode := -1;
                        RETURN;
                END;
           ELSE
               BEGIN

                    PRINT_BUDGET_INFO(lc_non_overlapping_ranges(i).range_id,
                                      l_errbuf,
                                      l_retcode);
                    IF l_retcode IS NOT NULL and l_retcode = -1 THEN
                        errbuf := l_errbuf;
                        retcode := l_retcode;
                        RETURN;
                    END IF;


                    DELETE FROM IGI_UPG_GL_BUDORG_BC_OPTIONS WHERE RANGE_ID = lc_non_overlapping_ranges(i).range_id;

                    DELETE FROM IGI_UPG_GL_BUDGET_ASSIGNMENT WHERE RANGE_ID = lc_non_overlapping_ranges(i).range_id;
               EXCEPTION
                   WHEN OTHERS THEN
                        fnd_file.put_line(fnd_file.output, 'Error processing demerged data - prelim mode');
                        fnd_file.put_line(fnd_file.log, 'Module: LOOP_AND_PROCESS =>'
                                  ||'Error processing demerged data - prelim mode =>'||SQLERRM);
                        errbuf  := 'Module: LOOP_AND_PROCESS =>'||'Error processing demerged data - prelim mode =>'||SQLERRM;
                        retcode := -1;
                        RETURN;
               END;
           END IF;
        END LOOP;


        -- End of Step 1A

        -- Start of Step 1B

        --Then check for exact overlap
        OPEN C_ALL_RANGES;
        FETCH C_ALL_RANGES INTO lc_exact_merge_range1;
        IF C_ALL_RANGES%NOTFOUND THEN
            CLOSE C_ALL_RANGES;
            fnd_file.put_line(fnd_file.log, 'Module: LOOP_AND_PROCESS => Processing completed');
            EXIT;
        END IF;
        CLOSE C_ALL_RANGES;

        -- End of Step 1B

        -- Start of Step 2

        OPEN C_EXACT_OVERLAPPING_RANGE(lc_exact_merge_range1.range_id);
        FETCH C_EXACT_OVERLAPPING_RANGE INTO lc_exact_merge_range2;
        IF C_EXACT_OVERLAPPING_RANGE%FOUND THEN
            l_exact_overlap_exists := TRUE;
        ELSE
            l_exact_overlap_exists := FALSE;
        END IF;
        CLOSE C_EXACT_OVERLAPPING_RANGE;

        IF l_exact_overlap_exists THEN


            BEGIN

            UPDATE IGI_UPG_GL_BUDORG_BC_OPTIONS
            SET RANGE_ID = lc_exact_merge_range1.range_id
            WHERE RANGE_ID = lc_exact_merge_range2.range_id;

            DELETE FROM IGI_UPG_GL_BUDGET_ASSIGNMENT WHERE RANGE_ID = lc_exact_merge_range2.range_id;

            EXCEPTION
                WHEN OTHERS THEN
                    fnd_file.put_line(fnd_file.output, 'Error merging data which overlaps exactly');
                    fnd_file.put_line(fnd_file.log, 'Module: LOOP_AND_PROCESS =>'
                    ||'Error merging data which overlaps exactly =>'||SQLERRM);
                    errbuf  := 'Module: LOOP_AND_PROCESS =>'||'Error merging data which overlaps exactly =>'||SQLERRM;
                    retcode := -1;
                    RETURN;
            END;
            --Continue executing the loop
            --Goto is used to emulate the behaviour of continue
            GOTO CONTINUE;
        END IF;

        -- End of Step 2

        -- Start of Step 3

        OPEN C_ALL_RANGES;
        FETCH C_ALL_RANGES INTO lc_merge_range1;
        IF C_ALL_RANGES%NOTFOUND THEN
            CLOSE C_ALL_RANGES;
            fnd_file.put_line(fnd_file.log, 'Module: LOOP_AND_PROCESS => Processing completed');
            EXIT;
        END IF;
        IF C_ALL_RANGES%FOUND AND l_data_type <> 0 THEN
            CLOSE C_ALL_RANGES;
            fnd_file.put_line(fnd_file.output, 'Module: LOOP_AND_PROCESS - You have segment ranges which merge with other segment ranges
                                                for the same ledger and currency. This upgrade script does
                                                not support merging segment ranges for segments which have variable
                                                non numeric values. Merging segment ranges are supported only if your
                                                segment contains fixed length numeric values. Please contact Oracle Support for help');
            fnd_file.put_line(fnd_file.log,  'Module: LOOP_AND_PROCESS - You have segment ranges which merge with other segment ranges
                                                for the same ledger and currency code. This upgrade script does
                                                not support merging segment ranges for segments which have variable
                                                non numeric values. Merging segment ranges are supported only if your
                                                segment contains fixed length numeric values. Please contact Oracle Support for help');
            errbuf  := 'Aborting Upgrade Non numeric segments exists and merging ranges are found';
            retcode := -1;
            RETURN;
        END IF;
        CLOSE C_ALL_RANGES;


        -- This cursor selects the budgets associated to lc_merge_range1
        OPEN C_BC_OPTIONS(lc_merge_range1.range_id);
        FETCH C_BC_OPTIONS BULK COLLECT INTO lc_merge_range1_bc;
        CLOSE C_BC_OPTIONS;

        -- This cursor selects the range which overlaps with the lc_merge_range1
        OPEN C_OVERLAPPING_RANGE(lc_merge_range1.range_id);
        FETCH C_OVERLAPPING_RANGE INTO lc_merge_range2;
        CLOSE C_OVERLAPPING_RANGE;

        -- This cursor selects the budgets associated to lc_merge_range2
        OPEN C_BC_OPTIONS(lc_merge_range2.range_id);
        FETCH C_BC_OPTIONS BULK COLLECT INTO lc_merge_range2_bc;
        CLOSE C_BC_OPTIONS;


        --p_budget_range1 is assigned the value of lc_merge_range1
        --p_budget_range2 is assigned the value of lc_merge_range1

        p_budget_range1.range_id := lc_merge_range1.range_id;
        p_budget_range1.segment_range_tab := segment_range_type();
        p_budget_range1.segment_range_tab.extend(30);

        p_budget_range1.segment_range_tab(1).segment_low := lc_merge_range1.SEGMENT1_LOW;
        p_budget_range1.segment_range_tab(1).segment_high := lc_merge_range1.SEGMENT1_HIGH;
        p_budget_range1.segment_range_tab(1).data_type := l_data_type;

        p_budget_range1.segment_range_tab(2).segment_low := lc_merge_range1.SEGMENT2_LOW;
        p_budget_range1.segment_range_tab(2).segment_high := lc_merge_range1.SEGMENT2_HIGH;
        p_budget_range1.segment_range_tab(2).data_type := l_data_type;

        p_budget_range1.segment_range_tab(3).segment_low := lc_merge_range1.SEGMENT3_LOW;
        p_budget_range1.segment_range_tab(3).segment_high := lc_merge_range1.SEGMENT3_HIGH;
        p_budget_range1.segment_range_tab(3).data_type := l_data_type;

        p_budget_range1.segment_range_tab(4).segment_low := lc_merge_range1.SEGMENT4_LOW;
        p_budget_range1.segment_range_tab(4).segment_high := lc_merge_range1.SEGMENT4_HIGH;
        p_budget_range1.segment_range_tab(4).data_type := l_data_type;

        p_budget_range1.segment_range_tab(5).segment_low := lc_merge_range1.SEGMENT5_LOW;
        p_budget_range1.segment_range_tab(5).segment_high := lc_merge_range1.SEGMENT5_HIGH;
        p_budget_range1.segment_range_tab(5).data_type := l_data_type;

        p_budget_range1.segment_range_tab(6).segment_low := lc_merge_range1.SEGMENT6_LOW;
        p_budget_range1.segment_range_tab(6).segment_high := lc_merge_range1.SEGMENT6_HIGH;
        p_budget_range1.segment_range_tab(6).data_type := l_data_type;

        p_budget_range1.segment_range_tab(7).segment_low := lc_merge_range1.SEGMENT7_LOW;
        p_budget_range1.segment_range_tab(7).segment_high := lc_merge_range1.SEGMENT7_HIGH;
        p_budget_range1.segment_range_tab(7).data_type := l_data_type;

        p_budget_range1.segment_range_tab(8).segment_low := lc_merge_range1.SEGMENT8_LOW;
        p_budget_range1.segment_range_tab(8).segment_high := lc_merge_range1.SEGMENT8_HIGH;
        p_budget_range1.segment_range_tab(8).data_type := l_data_type;

        p_budget_range1.segment_range_tab(9).segment_low := lc_merge_range1.SEGMENT9_LOW;
        p_budget_range1.segment_range_tab(9).segment_high := lc_merge_range1.SEGMENT9_HIGH;
        p_budget_range1.segment_range_tab(9).data_type := l_data_type;

        p_budget_range1.segment_range_tab(10).segment_low := lc_merge_range1.SEGMENT10_LOW;
        p_budget_range1.segment_range_tab(10).segment_high := lc_merge_range1.SEGMENT10_HIGH;
        p_budget_range1.segment_range_tab(10).data_type := l_data_type;

        p_budget_range1.segment_range_tab(11).segment_low := lc_merge_range1.SEGMENT11_LOW;
        p_budget_range1.segment_range_tab(11).segment_high := lc_merge_range1.SEGMENT11_HIGH;
        p_budget_range1.segment_range_tab(11).data_type := l_data_type;

        p_budget_range1.segment_range_tab(12).segment_low := lc_merge_range1.SEGMENT12_LOW;
        p_budget_range1.segment_range_tab(12).segment_high := lc_merge_range1.SEGMENT12_HIGH;
        p_budget_range1.segment_range_tab(12).data_type := l_data_type;

        p_budget_range1.segment_range_tab(13).segment_low := lc_merge_range1.SEGMENT13_LOW;
        p_budget_range1.segment_range_tab(13).segment_high := lc_merge_range1.SEGMENT13_HIGH;
        p_budget_range1.segment_range_tab(13).data_type := l_data_type;

        p_budget_range1.segment_range_tab(14).segment_low := lc_merge_range1.SEGMENT14_LOW;
        p_budget_range1.segment_range_tab(14).segment_high := lc_merge_range1.SEGMENT14_HIGH;
        p_budget_range1.segment_range_tab(14).data_type := l_data_type;

        p_budget_range1.segment_range_tab(15).segment_low := lc_merge_range1.SEGMENT15_LOW;
        p_budget_range1.segment_range_tab(15).segment_high := lc_merge_range1.SEGMENT15_HIGH;
        p_budget_range1.segment_range_tab(15).data_type := l_data_type;

        p_budget_range1.segment_range_tab(16).segment_low := lc_merge_range1.SEGMENT16_LOW;
        p_budget_range1.segment_range_tab(16).segment_high := lc_merge_range1.SEGMENT16_HIGH;
        p_budget_range1.segment_range_tab(16).data_type := l_data_type;

        p_budget_range1.segment_range_tab(17).segment_low := lc_merge_range1.SEGMENT17_LOW;
        p_budget_range1.segment_range_tab(17).segment_high := lc_merge_range1.SEGMENT17_HIGH;
        p_budget_range1.segment_range_tab(17).data_type := l_data_type;

        p_budget_range1.segment_range_tab(18).segment_low := lc_merge_range1.SEGMENT18_LOW;
        p_budget_range1.segment_range_tab(18).segment_high := lc_merge_range1.SEGMENT18_HIGH;
        p_budget_range1.segment_range_tab(18).data_type := l_data_type;

        p_budget_range1.segment_range_tab(19).segment_low := lc_merge_range1.SEGMENT19_LOW;
        p_budget_range1.segment_range_tab(19).segment_high := lc_merge_range1.SEGMENT19_HIGH;
        p_budget_range1.segment_range_tab(19).data_type := l_data_type;

        p_budget_range1.segment_range_tab(20).segment_low := lc_merge_range1.SEGMENT20_LOW;
        p_budget_range1.segment_range_tab(20).segment_high := lc_merge_range1.SEGMENT20_HIGH;
        p_budget_range1.segment_range_tab(20).data_type := l_data_type;

        p_budget_range1.segment_range_tab(21).segment_low := lc_merge_range1.SEGMENT21_LOW;
        p_budget_range1.segment_range_tab(21).segment_high := lc_merge_range1.SEGMENT21_HIGH;
        p_budget_range1.segment_range_tab(21).data_type := l_data_type;

        p_budget_range1.segment_range_tab(22).segment_low := lc_merge_range1.SEGMENT22_LOW;
        p_budget_range1.segment_range_tab(22).segment_high := lc_merge_range1.SEGMENT22_HIGH;
        p_budget_range1.segment_range_tab(22).data_type := l_data_type;

        p_budget_range1.segment_range_tab(23).segment_low := lc_merge_range1.SEGMENT23_LOW;
        p_budget_range1.segment_range_tab(23).segment_high := lc_merge_range1.SEGMENT23_HIGH;
        p_budget_range1.segment_range_tab(23).data_type := l_data_type;

        p_budget_range1.segment_range_tab(24).segment_low := lc_merge_range1.SEGMENT24_LOW;
        p_budget_range1.segment_range_tab(24).segment_high := lc_merge_range1.SEGMENT24_HIGH;
        p_budget_range1.segment_range_tab(24).data_type := l_data_type;

        p_budget_range1.segment_range_tab(25).segment_low := lc_merge_range1.SEGMENT25_LOW;
        p_budget_range1.segment_range_tab(25).segment_high := lc_merge_range1.SEGMENT25_HIGH;
        p_budget_range1.segment_range_tab(25).data_type := l_data_type;

        p_budget_range1.segment_range_tab(26).segment_low := lc_merge_range1.SEGMENT26_LOW;
        p_budget_range1.segment_range_tab(26).segment_high := lc_merge_range1.SEGMENT26_HIGH;
        p_budget_range1.segment_range_tab(26).data_type := l_data_type;

        p_budget_range1.segment_range_tab(27).segment_low := lc_merge_range1.SEGMENT27_LOW;
        p_budget_range1.segment_range_tab(27).segment_high := lc_merge_range1.SEGMENT27_HIGH;
        p_budget_range1.segment_range_tab(27).data_type := l_data_type;

        p_budget_range1.segment_range_tab(28).segment_low := lc_merge_range1.SEGMENT28_LOW;
        p_budget_range1.segment_range_tab(28).segment_high := lc_merge_range1.SEGMENT28_HIGH;
        p_budget_range1.segment_range_tab(28).data_type := l_data_type;

        p_budget_range1.segment_range_tab(29).segment_low := lc_merge_range1.SEGMENT29_LOW;
        p_budget_range1.segment_range_tab(29).segment_high := lc_merge_range1.SEGMENT29_HIGH;
        p_budget_range1.segment_range_tab(29).data_type := l_data_type;

        p_budget_range1.segment_range_tab(30).segment_low := lc_merge_range1.SEGMENT30_LOW;
        p_budget_range1.segment_range_tab(30).segment_high := lc_merge_range1.SEGMENT30_HIGH;
        p_budget_range1.segment_range_tab(30).data_type := l_data_type;


        p_budget_range2.range_id := lc_merge_range2.range_id;
        p_budget_range2.segment_range_tab := segment_range_type();
        p_budget_range2.segment_range_tab.extend(30);

        p_budget_range2.segment_range_tab(1).segment_low := lc_merge_range2.SEGMENT1_LOW;
        p_budget_range2.segment_range_tab(1).segment_high := lc_merge_range2.SEGMENT1_HIGH;
        p_budget_range2.segment_range_tab(1).data_type := l_data_type;

        p_budget_range2.segment_range_tab(2).segment_low := lc_merge_range2.SEGMENT2_LOW;
        p_budget_range2.segment_range_tab(2).segment_high := lc_merge_range2.SEGMENT2_HIGH;
        p_budget_range2.segment_range_tab(2).data_type := l_data_type;

        p_budget_range2.segment_range_tab(3).segment_low := lc_merge_range2.SEGMENT3_LOW;
        p_budget_range2.segment_range_tab(3).segment_high := lc_merge_range2.SEGMENT3_HIGH;
        p_budget_range2.segment_range_tab(3).data_type := l_data_type;

        p_budget_range2.segment_range_tab(4).segment_low := lc_merge_range2.SEGMENT4_LOW;
        p_budget_range2.segment_range_tab(4).segment_high := lc_merge_range2.SEGMENT4_HIGH;
        p_budget_range2.segment_range_tab(4).data_type := l_data_type;

        p_budget_range2.segment_range_tab(5).segment_low := lc_merge_range2.SEGMENT5_LOW;
        p_budget_range2.segment_range_tab(5).segment_high := lc_merge_range2.SEGMENT5_HIGH;
        p_budget_range2.segment_range_tab(5).data_type := l_data_type;

        p_budget_range2.segment_range_tab(6).segment_low := lc_merge_range2.SEGMENT6_LOW;
        p_budget_range2.segment_range_tab(6).segment_high := lc_merge_range2.SEGMENT6_HIGH;
        p_budget_range2.segment_range_tab(6).data_type := l_data_type;

        p_budget_range2.segment_range_tab(7).segment_low := lc_merge_range2.SEGMENT7_LOW;
        p_budget_range2.segment_range_tab(7).segment_high := lc_merge_range2.SEGMENT7_HIGH;
        p_budget_range2.segment_range_tab(7).data_type := l_data_type;

        p_budget_range2.segment_range_tab(8).segment_low := lc_merge_range2.SEGMENT8_LOW;
        p_budget_range2.segment_range_tab(8).segment_high := lc_merge_range2.SEGMENT8_HIGH;
        p_budget_range2.segment_range_tab(8).data_type := l_data_type;

        p_budget_range2.segment_range_tab(9).segment_low := lc_merge_range2.SEGMENT9_LOW;
        p_budget_range2.segment_range_tab(9).segment_high := lc_merge_range2.SEGMENT9_HIGH;
        p_budget_range2.segment_range_tab(9).data_type := l_data_type;

        p_budget_range2.segment_range_tab(10).segment_low := lc_merge_range2.SEGMENT10_LOW;
        p_budget_range2.segment_range_tab(10).segment_high := lc_merge_range2.SEGMENT10_HIGH;
        p_budget_range2.segment_range_tab(10).data_type := l_data_type;

        p_budget_range2.segment_range_tab(11).segment_low := lc_merge_range2.SEGMENT11_LOW;
        p_budget_range2.segment_range_tab(11).segment_high := lc_merge_range2.SEGMENT11_HIGH;
        p_budget_range2.segment_range_tab(11).data_type := l_data_type;

        p_budget_range2.segment_range_tab(12).segment_low := lc_merge_range2.SEGMENT12_LOW;
        p_budget_range2.segment_range_tab(12).segment_high := lc_merge_range2.SEGMENT12_HIGH;
        p_budget_range2.segment_range_tab(12).data_type := l_data_type;

        p_budget_range2.segment_range_tab(13).segment_low := lc_merge_range2.SEGMENT13_LOW;
        p_budget_range2.segment_range_tab(13).segment_high := lc_merge_range2.SEGMENT13_HIGH;
        p_budget_range2.segment_range_tab(13).data_type := l_data_type;

        p_budget_range2.segment_range_tab(14).segment_low := lc_merge_range2.SEGMENT14_LOW;
        p_budget_range2.segment_range_tab(14).segment_high := lc_merge_range2.SEGMENT14_HIGH;
        p_budget_range2.segment_range_tab(14).data_type := l_data_type;

        p_budget_range2.segment_range_tab(15).segment_low := lc_merge_range2.SEGMENT15_LOW;
        p_budget_range2.segment_range_tab(15).segment_high := lc_merge_range2.SEGMENT15_HIGH;
        p_budget_range2.segment_range_tab(15).data_type := l_data_type;

        p_budget_range2.segment_range_tab(16).segment_low := lc_merge_range2.SEGMENT16_LOW;
        p_budget_range2.segment_range_tab(16).segment_high := lc_merge_range2.SEGMENT16_HIGH;
        p_budget_range2.segment_range_tab(16).data_type := l_data_type;

        p_budget_range2.segment_range_tab(17).segment_low := lc_merge_range2.SEGMENT17_LOW;
        p_budget_range2.segment_range_tab(17).segment_high := lc_merge_range2.SEGMENT17_HIGH;
        p_budget_range2.segment_range_tab(17).data_type := l_data_type;

        p_budget_range2.segment_range_tab(18).segment_low := lc_merge_range2.SEGMENT18_LOW;
        p_budget_range2.segment_range_tab(18).segment_high := lc_merge_range2.SEGMENT18_HIGH;
        p_budget_range2.segment_range_tab(18).data_type := l_data_type;

        p_budget_range2.segment_range_tab(19).segment_low := lc_merge_range2.SEGMENT19_LOW;
        p_budget_range2.segment_range_tab(19).segment_high := lc_merge_range2.SEGMENT19_HIGH;
        p_budget_range2.segment_range_tab(19).data_type := l_data_type;

        p_budget_range2.segment_range_tab(20).segment_low := lc_merge_range2.SEGMENT20_LOW;
        p_budget_range2.segment_range_tab(20).segment_high := lc_merge_range2.SEGMENT20_HIGH;
        p_budget_range2.segment_range_tab(20).data_type := l_data_type;

        p_budget_range2.segment_range_tab(21).segment_low := lc_merge_range2.SEGMENT21_LOW;
        p_budget_range2.segment_range_tab(21).segment_high := lc_merge_range2.SEGMENT21_HIGH;
        p_budget_range2.segment_range_tab(21).data_type := l_data_type;

        p_budget_range2.segment_range_tab(22).segment_low := lc_merge_range2.SEGMENT22_LOW;
        p_budget_range2.segment_range_tab(22).segment_high := lc_merge_range2.SEGMENT22_HIGH;
        p_budget_range2.segment_range_tab(22).data_type := l_data_type;

        p_budget_range2.segment_range_tab(23).segment_low := lc_merge_range2.SEGMENT23_LOW;
        p_budget_range2.segment_range_tab(23).segment_high := lc_merge_range2.SEGMENT23_HIGH;
        p_budget_range2.segment_range_tab(23).data_type := l_data_type;

        p_budget_range2.segment_range_tab(24).segment_low := lc_merge_range2.SEGMENT24_LOW;
        p_budget_range2.segment_range_tab(24).segment_high := lc_merge_range2.SEGMENT24_HIGH;
        p_budget_range2.segment_range_tab(24).data_type := l_data_type;

        p_budget_range2.segment_range_tab(25).segment_low := lc_merge_range2.SEGMENT25_LOW;
        p_budget_range2.segment_range_tab(25).segment_high := lc_merge_range2.SEGMENT25_HIGH;
        p_budget_range2.segment_range_tab(25).data_type := l_data_type;

        p_budget_range2.segment_range_tab(26).segment_low := lc_merge_range2.SEGMENT26_LOW;
        p_budget_range2.segment_range_tab(26).segment_high := lc_merge_range2.SEGMENT26_HIGH;
        p_budget_range2.segment_range_tab(26).data_type := l_data_type;

        p_budget_range2.segment_range_tab(27).segment_low := lc_merge_range2.SEGMENT27_LOW;
        p_budget_range2.segment_range_tab(27).segment_high := lc_merge_range2.SEGMENT27_HIGH;
        p_budget_range2.segment_range_tab(27).data_type := l_data_type;

        p_budget_range2.segment_range_tab(28).segment_low := lc_merge_range2.SEGMENT28_LOW;
        p_budget_range2.segment_range_tab(28).segment_high := lc_merge_range2.SEGMENT28_HIGH;
        p_budget_range2.segment_range_tab(28).data_type := l_data_type;

        p_budget_range2.segment_range_tab(29).segment_low := lc_merge_range2.SEGMENT29_LOW;
        p_budget_range2.segment_range_tab(29).segment_high := lc_merge_range2.SEGMENT29_HIGH;
        p_budget_range2.segment_range_tab(29).data_type := l_data_type;

        p_budget_range2.segment_range_tab(30).segment_low := lc_merge_range2.SEGMENT30_LOW;
        p_budget_range2.segment_range_tab(30).segment_high := lc_merge_range2.SEGMENT30_HIGH;
        p_budget_range2.segment_range_tab(30).data_type := l_data_type;


        l_index_number := 0;
        p_segment_tab := segment_type();


        --This for loops determines the number of segments of p_budget_range1
        --and p_budget_range2 that overlap
        --Each segment that overlap is split by calling SPLIT_RANGES. Once this
        --for loop is executed p_segment_tab has the list of segments splitted
        FOR i IN 1..30 LOOP
            IF p_budget_range1.segment_range_tab(i).segment_low IS NOT NULL AND
              p_budget_range1.segment_range_tab(i).segment_high IS NOT NULL AND
              p_budget_range2.segment_range_tab(i).segment_low IS NOT NULL AND
              p_budget_range2.segment_range_tab(i).segment_high IS NOT NULL AND
              (p_budget_range1.segment_range_tab(i).segment_low <= p_budget_range2.segment_range_tab(i).segment_high
               AND
               p_budget_range1.segment_range_tab(i).segment_high >= p_budget_range2.segment_range_tab(i).segment_low
              )
            THEN

                IF p_budget_range1.segment_range_tab(i).segment_low = p_budget_range2.segment_range_tab(i).segment_low
                AND p_budget_range2.segment_range_tab(i).segment_high = p_budget_range2.segment_range_tab(i).segment_high THEN
                    NULL;

                ELSE
                    l_index_number := l_index_number + 1;



                    p_segment1.segment_number := i;
                    p_segment1.data_type := l_data_type;
                    p_segment1.segment_low := p_budget_range1.segment_range_tab(i).SEGMENT_LOW;
                    p_segment1.segment_high := p_budget_range1.segment_range_tab(i).SEGMENT_HIGH;
                    p_segment1.budget_tab := BUDGET_TYPE();

                    FOR m IN 1..lc_merge_range1_bc.COUNT LOOP
                        p_segment1.budget_tab.extend(1);
                        p_segment1.budget_tab(m) := lc_merge_range1_bc(m).funding_budget_version_id;
                    END LOOP;


                    p_segment2.segment_number := i;
                    p_segment2.data_type := l_data_type;
                    p_segment2.segment_low := p_budget_range2.segment_range_tab(i).SEGMENT_LOW;
                    p_segment2.segment_high := p_budget_range2.segment_range_tab(i).SEGMENT_HIGH;
                    p_segment2.budget_tab := BUDGET_TYPE();

                    FOR m IN 1..lc_merge_range2_bc.COUNT LOOP
                        p_segment2.budget_tab.extend(1);
                        p_segment2.budget_tab(m) := lc_merge_range2_bc(m).funding_budget_version_id;
                    END LOOP;

                    SPLIT_RANGES(p_segment1,
                                 p_segment2,
                                 p_segment_tab,
                                 l_index_number,
                                 l_errbuf,
                                 l_retcode);

                    IF l_retcode IS NOT NULL AND l_retcode = -1 THEN
                        retcode := l_retcode;
                        errbuf := l_errbuf;
                        RETURN;
                    END IF;



                END IF;

            END IF;

        END LOOP;

        IF g_debug_enabled = 1 THEN
            PRINT_SPLIT_INFO(p_segment_tab);
        END IF;

        l_final_budget_ranges := BUDGET_RANGE_TYPE();

        -- Merging of segments in p_segment_tab happens by this function calll
        -- The final splitted budget ranges are present in l_final_budget_ranges
        MERGE_SEGMENTS(p_budget_range1, p_segment_tab, l_final_budget_ranges, l_index_number, l_errbuf, l_retcode);

        IF l_retcode IS NOT NULL AND l_retcode = -1 THEN
            retcode := l_retcode;
            errbuf := l_errbuf;
            RETURN;
        END IF;

        IF g_debug_enabled = 1 THEN
            PRINT_MERGE_INFO(l_final_budget_ranges);
        END IF;


        -- This for loop is used to insert the split ranges into the backend
        -- This is done by comparing the budgets associated to
        -- each split range with lc_merge_range2_bc or lc_merge_range1_bc
        -- Based on this insertion of corresponding data occurs
        FOR i IN 1..l_final_budget_ranges.COUNT LOOP

            --If the current range has budgets equal to lc_merge_range2_bc
            --then insertion happens and data corresponding to lc_merge_range2_bc
            --are inserted into backend. Otherwise, data corresponding to
            --lc_merge_range1_bc is inserted.

            --Compare Budgets If
            IF COMPARE_BUDGETS(l_final_budget_ranges(i).budget_tab,lc_merge_range2_bc) THEN

                l_range_id_seq := l_range_id_seq + 1;

                --Select the maximum sequence number
                DECLARE
                    l_seq_number1 NUMBER;
                    l_seq_number2 NUMBER;
                BEGIN
                    SELECT max(sequence_number)+1
                    INTO l_seq_number1
                    FROM IGI_UPG_GL_BUDGET_ASSIGNMENT
                    WHERE
                    budget_entity_id = lc_merge_range2.budget_entity_id;

                    SELECT max(sequence_number)+1
                    INTO l_seq_number2
                    FROM GL_BUDGET_ASSIGNMENT_RANGES
                    WHERE
                    budget_entity_id = lc_merge_range2.budget_entity_id;

                    IF l_seq_number1 IS NULL and l_seq_number2 IS NULL THEN
                        l_seq_number := 10;
                    ELSE
                        IF nvl(l_seq_number1,-1) < nvl(l_seq_number2,-1) THEN
                            l_seq_number := l_seq_number2;

                        ELSE
                            l_seq_number := l_seq_number1;
                        END IF;
                    END IF;

                EXCEPTION
                    WHEN OTHERS THEN
                        l_seq_number := 10;

                END;

                IF l_seq_number IS NULL OR l_seq_number = 0 THEN
                    l_seq_number := 10;
                END IF;

                -- For range l_final_budget_ranges(i) insert data corresponding
                -- to lc_merge_range2
                BEGIN

                INSERT INTO IGI_UPG_GL_BUDGET_ASSIGNMENT
                (
                BUDGET_ENTITY_ID,
                LEDGER_ID,
                CURRENCY_CODE,
                ENTRY_CODE,
                RANGE_ID,
                STATUS,
                LAST_UPDATE_DATE,
                AUTOMATIC_ENCUMBRANCE_FLAG,
                CREATED_BY,
                CREATION_DATE,
                FUNDS_CHECK_LEVEL_CODE,
                LAST_UPDATED_BY,
                LAST_UPDATE_LOGIN,
                SEQUENCE_NUMBER,
                SEGMENT1_LOW,
                SEGMENT1_HIGH,
                SEGMENT2_LOW,
                SEGMENT2_HIGH,
                SEGMENT3_LOW,
                SEGMENT3_HIGH,
                SEGMENT4_LOW,
                SEGMENT4_HIGH,
                SEGMENT5_LOW,
                SEGMENT5_HIGH,
                SEGMENT6_LOW,
                SEGMENT6_HIGH,
                SEGMENT7_LOW,
                SEGMENT7_HIGH,
                SEGMENT8_LOW,
                SEGMENT8_HIGH,
                SEGMENT9_LOW,
                SEGMENT9_HIGH,
                SEGMENT10_LOW,
                SEGMENT10_HIGH,
                SEGMENT11_LOW,
                SEGMENT11_HIGH,
                SEGMENT12_LOW,
                SEGMENT12_HIGH,
                SEGMENT13_LOW,
                SEGMENT13_HIGH,
                SEGMENT14_LOW,
                SEGMENT14_HIGH,
                SEGMENT15_LOW,
                SEGMENT15_HIGH,
                SEGMENT16_LOW,
                SEGMENT16_HIGH,
                SEGMENT17_LOW,
                SEGMENT17_HIGH,
                SEGMENT18_LOW,
                SEGMENT18_HIGH,
                SEGMENT19_LOW,
                SEGMENT19_HIGH,
                SEGMENT20_LOW,
                SEGMENT20_HIGH,
                SEGMENT21_LOW,
                SEGMENT21_HIGH,
                SEGMENT22_LOW,
                SEGMENT22_HIGH,
                SEGMENT23_LOW,
                SEGMENT23_HIGH,
                SEGMENT24_LOW,
                SEGMENT24_HIGH,
                SEGMENT25_LOW,
                SEGMENT25_HIGH,
                SEGMENT26_LOW,
                SEGMENT26_HIGH,
                SEGMENT27_LOW,
                SEGMENT27_HIGH,
                SEGMENT28_LOW,
                SEGMENT28_HIGH,
                SEGMENT29_LOW,
                SEGMENT29_HIGH,
                SEGMENT30_LOW,
                SEGMENT30_HIGH,
                AMOUNT_TYPE,
                BOUNDARY_CODE,
                CONTEXT,
                FUNDING_BUDGET_VERSION_ID,
                PROGRAM_APPLICATION_ID,
                PROGRAM_ID,
                PROGRAM_UPDATE_DATE,
                REQUEST_ID,
                ATTRIBUTE1,
                ATTRIBUTE2,
                ATTRIBUTE3,
                ATTRIBUTE4,
                ATTRIBUTE5,
                ATTRIBUTE6,
                ATTRIBUTE7,
                ATTRIBUTE8,
                ATTRIBUTE9,
                ATTRIBUTE10,
                ATTRIBUTE11,
                ATTRIBUTE12,
                ATTRIBUTE13,
                ATTRIBUTE14,
                ATTRIBUTE15
                )

                VALUES (
                lc_merge_range2.budget_entity_id,
                lc_merge_range2.ledger_id,
                lc_merge_range2.currency_code,
                lc_merge_range2.entry_code,
                l_range_id_seq,
                lc_merge_range2.status,
                sysdate,
                lc_merge_range2.automatic_encumbrance_flag,
                lc_merge_range2.created_by,
                lc_merge_range2.creation_date,
                lc_merge_range2.funds_check_level_code,
                lc_merge_range2.last_updated_by,
                lc_merge_range2.last_update_login,
                l_seq_number,
                l_final_budget_ranges(i).segment_range_tab(1).SEGMENT_LOW,
                l_final_budget_ranges(i).segment_range_tab(1).SEGMENT_HIGH,
                l_final_budget_ranges(i).segment_range_tab(2).SEGMENT_LOW,
                l_final_budget_ranges(i).segment_range_tab(2).SEGMENT_HIGH,
                l_final_budget_ranges(i).segment_range_tab(3).SEGMENT_LOW,
                l_final_budget_ranges(i).segment_range_tab(3).SEGMENT_HIGH,
                l_final_budget_ranges(i).segment_range_tab(4).SEGMENT_LOW,
                l_final_budget_ranges(i).segment_range_tab(4).SEGMENT_HIGH,
                l_final_budget_ranges(i).segment_range_tab(5).SEGMENT_LOW,
                l_final_budget_ranges(i).segment_range_tab(5).SEGMENT_HIGH,
                l_final_budget_ranges(i).segment_range_tab(6).SEGMENT_LOW,
                l_final_budget_ranges(i).segment_range_tab(6).SEGMENT_HIGH,
                l_final_budget_ranges(i).segment_range_tab(7).SEGMENT_LOW,
                l_final_budget_ranges(i).segment_range_tab(7).SEGMENT_HIGH,
                l_final_budget_ranges(i).segment_range_tab(8).SEGMENT_LOW,
                l_final_budget_ranges(i).segment_range_tab(8).SEGMENT_HIGH,
                l_final_budget_ranges(i).segment_range_tab(9).SEGMENT_LOW,
                l_final_budget_ranges(i).segment_range_tab(9).SEGMENT_HIGH,
                l_final_budget_ranges(i).segment_range_tab(10).SEGMENT_LOW,
                l_final_budget_ranges(i).segment_range_tab(10).SEGMENT_HIGH,
                l_final_budget_ranges(i).segment_range_tab(11).SEGMENT_LOW,
                l_final_budget_ranges(i).segment_range_tab(11).SEGMENT_HIGH,
                l_final_budget_ranges(i).segment_range_tab(12).SEGMENT_LOW,
                l_final_budget_ranges(i).segment_range_tab(12).SEGMENT_HIGH,
                l_final_budget_ranges(i).segment_range_tab(13).SEGMENT_LOW,
                l_final_budget_ranges(i).segment_range_tab(13).SEGMENT_HIGH,
                l_final_budget_ranges(i).segment_range_tab(14).SEGMENT_LOW,
                l_final_budget_ranges(i).segment_range_tab(14).SEGMENT_HIGH,
                l_final_budget_ranges(i).segment_range_tab(15).SEGMENT_LOW,
                l_final_budget_ranges(i).segment_range_tab(15).SEGMENT_HIGH,
                l_final_budget_ranges(i).segment_range_tab(16).SEGMENT_LOW,
                l_final_budget_ranges(i).segment_range_tab(16).SEGMENT_HIGH,
                l_final_budget_ranges(i).segment_range_tab(17).SEGMENT_LOW,
                l_final_budget_ranges(i).segment_range_tab(17).SEGMENT_HIGH,
                l_final_budget_ranges(i).segment_range_tab(18).SEGMENT_LOW,
                l_final_budget_ranges(i).segment_range_tab(18).SEGMENT_HIGH,
                l_final_budget_ranges(i).segment_range_tab(19).SEGMENT_LOW,
                l_final_budget_ranges(i).segment_range_tab(19).SEGMENT_HIGH,
                l_final_budget_ranges(i).segment_range_tab(20).SEGMENT_LOW,
                l_final_budget_ranges(i).segment_range_tab(20).SEGMENT_HIGH,
                l_final_budget_ranges(i).segment_range_tab(21).SEGMENT_LOW,
                l_final_budget_ranges(i).segment_range_tab(21).SEGMENT_HIGH,
                l_final_budget_ranges(i).segment_range_tab(22).SEGMENT_LOW,
                l_final_budget_ranges(i).segment_range_tab(22).SEGMENT_HIGH,
                l_final_budget_ranges(i).segment_range_tab(23).SEGMENT_LOW,
                l_final_budget_ranges(i).segment_range_tab(23).SEGMENT_HIGH,
                l_final_budget_ranges(i).segment_range_tab(24).SEGMENT_LOW,
                l_final_budget_ranges(i).segment_range_tab(24).SEGMENT_HIGH,
                l_final_budget_ranges(i).segment_range_tab(25).SEGMENT_LOW,
                l_final_budget_ranges(i).segment_range_tab(25).SEGMENT_HIGH,
                l_final_budget_ranges(i).segment_range_tab(26).SEGMENT_LOW,
                l_final_budget_ranges(i).segment_range_tab(26).SEGMENT_HIGH,
                l_final_budget_ranges(i).segment_range_tab(27).SEGMENT_LOW,
                l_final_budget_ranges(i).segment_range_tab(27).SEGMENT_HIGH,
                l_final_budget_ranges(i).segment_range_tab(28).SEGMENT_LOW,
                l_final_budget_ranges(i).segment_range_tab(28).SEGMENT_HIGH,
                l_final_budget_ranges(i).segment_range_tab(29).SEGMENT_LOW,
                l_final_budget_ranges(i).segment_range_tab(29).SEGMENT_HIGH,
                l_final_budget_ranges(i).segment_range_tab(30).SEGMENT_LOW,
                l_final_budget_ranges(i).segment_range_tab(30).SEGMENT_HIGH,
                lc_merge_range2.amount_type,
                lc_merge_range2.boundary_code,
                lc_merge_range2.context,
                lc_merge_range2.funding_budget_version_id,
                lc_merge_range2.program_application_id,
                lc_merge_range2.program_id,
                lc_merge_range2.program_update_date,
                lc_merge_range2.request_id,
                lc_merge_range2.attribute1,
                lc_merge_range2.attribute2,
                lc_merge_range2.attribute3,
                lc_merge_range2.attribute4,
                lc_merge_range2.attribute5,
                lc_merge_range2.attribute6,
                lc_merge_range2.attribute7,
                lc_merge_range2.attribute8,
                lc_merge_range2.attribute9,
                lc_merge_range2.attribute10,
                lc_merge_range2.attribute11,
                lc_merge_range2.attribute12,
                lc_merge_range2.attribute13,
                lc_merge_range2.attribute14,
                lc_merge_range2.attribute15
                );
                EXCEPTION
                    WHEN OTHERS THEN
                        fnd_file.put_line(fnd_file.output, 'Error inserting records into IGI_UPG_GL_BUDGET_ASSIGNMENT Location 1');
                        fnd_file.put_line(fnd_file.log, 'Module: LOOP_AND_PROCESS =>'
                           ||'Error inserting records into IGI_UPG_GL_BUDGET_ASSIGNMENT Location 1 '||SQLERRM);
                        errbuf  := 'Module: LOOP_AND_PROCESS =>'||'Error inserting records into IGI_UPG_GL_BUDGET_ASSIGNMENT Location 1 '||SQLERRM;
                        retcode := -1;
                        RETURN;
                END;

                --For each budget associated to this range, insert data
                --by determing the corresponding budget information
                --from lc_merge_range2_bc
                FOR j IN 1..l_final_budget_ranges(i).budget_tab.COUNT LOOP
                    l_inserted := FALSE;
                    FOR k IN 1..lc_merge_range2_bc.COUNT LOOP
                        IF l_final_budget_ranges(i).budget_tab(j) = lc_merge_range2_bc(k).funding_budget_version_id THEN
                            BEGIN
                            INSERT INTO IGI_UPG_GL_BUDORG_BC_OPTIONS
                            (
                            RANGE_ID,
                            FUNDING_BUDGET_VERSION_ID,
                            FUNDS_CHECK_LEVEL_CODE,
                            AMOUNT_TYPE,
                            BOUNDARY_CODE,
                            CREATED_BY,
                            CREATION_DATE,
                            LAST_UPDATED_BY,
                            LAST_UPDATE_LOGIN,
                            LAST_UPDATE_DATE
                            )
                            VALUES
                            (
                            l_range_id_seq,
                            lc_merge_range2_bc(k).funding_budget_version_id,
                            lc_merge_range2_bc(k).funds_check_level_code,
                            lc_merge_range2_bc(k).amount_type,
                            lc_merge_range2_bc(k).boundary_code,
                            lc_merge_range2_bc(k).created_by,
                            lc_merge_range2_bc(k).creation_date,
                            lc_merge_range2_bc(k).last_updated_by,
                            lc_merge_range2_bc(k).last_update_login,
                            sysdate
                            );
                            EXCEPTION
                                WHEN OTHERS THEN
                                    fnd_file.put_line(fnd_file.output, 'Error inserting records into IGI_UPG_GL_BUDORG_BC_OPTIONS Location 1');
                                    fnd_file.put_line(fnd_file.log, 'Module: LOOP_AND_PROCESS =>'
                                                   ||'Error inserting records into IGI_UPG_GL_BUDORG_BC_OPTIONS Location 1 '||SQLERRM);
                                    errbuf  := 'Module: LOOP_AND_PROCESS =>'||'Error inserting records into
                                                     IGI_UPG_GL_BUDORG_BC_OPTIONS Location 1 '||SQLERRM;
                                    retcode := -1;
                                    RETURN;
                            END;
                        l_inserted := TRUE;
                        EXIT;
                        END IF;
                    END LOOP;
                    IF NOT l_inserted THEN
                        fnd_file.put_line(fnd_file.output, 'Insertion failed - Reason not explicit in merge 1');
                        fnd_file.put_line(fnd_file.log, 'Module: LOOP_AND_PROCESS =>'||'Insertion failed - Reason not explicit in merge 1');
                        errbuf  := 'Module: LOOP_AND_PROCESS =>'||'Insertion failed - Reason not explicit in merge 1';
                        retcode := -1;
                        RETURN;
                    END IF;
                END LOOP; -- END l_final_budget_ranges(i).budget_tab

            ELSE -- Else for Compare Budgets If


                l_range_id_seq := l_range_id_seq + 1;

                --Select the maximum available sequence number
                DECLARE
                    l_seq_number1 NUMBER;
                    l_seq_number2 NUMBER;
                BEGIN
                    SELECT max(sequence_number)+1
                    INTO l_seq_number1
                    FROM IGI_UPG_GL_BUDGET_ASSIGNMENT
                    WHERE
                    budget_entity_id = lc_merge_range1.budget_entity_id;

                    SELECT max(sequence_number)+1
                    INTO l_seq_number2
                    FROM GL_BUDGET_ASSIGNMENT_RANGES
                    WHERE
                    budget_entity_id = lc_merge_range1.budget_entity_id;

                    IF l_seq_number1 IS NULL and l_seq_number2 IS NULL THEN
                        l_seq_number := 10;
                    ELSE
                        IF nvl(l_seq_number1,-1) < nvl(l_seq_number2,-1) THEN
                            l_seq_number := l_seq_number2;

                        ELSE
                            l_seq_number := l_seq_number1;
                        END IF;
                    END IF;

                EXCEPTION
                    WHEN OTHERS THEN
                        l_seq_number := 10;

                END;

                IF l_seq_number IS NULL OR l_seq_number = 0 THEN
                    l_seq_number := 10;
                END IF;


                -- For range l_final_budget_ranges(i) insert data corresponding
                -- to lc_merge_range1
                BEGIN

                INSERT INTO IGI_UPG_GL_BUDGET_ASSIGNMENT
                (
                BUDGET_ENTITY_ID,
                LEDGER_ID,
                CURRENCY_CODE,
                ENTRY_CODE,
                RANGE_ID,
                STATUS,
                LAST_UPDATE_DATE,
                AUTOMATIC_ENCUMBRANCE_FLAG,
                CREATED_BY,
                CREATION_DATE,
                FUNDS_CHECK_LEVEL_CODE,
                LAST_UPDATED_BY,
                LAST_UPDATE_LOGIN,
                SEQUENCE_NUMBER,
                SEGMENT1_LOW,
                SEGMENT1_HIGH,
                SEGMENT2_LOW,
                SEGMENT2_HIGH,
                SEGMENT3_LOW,
                SEGMENT3_HIGH,
                SEGMENT4_LOW,
                SEGMENT4_HIGH,
                SEGMENT5_LOW,
                SEGMENT5_HIGH,
                SEGMENT6_LOW,
                SEGMENT6_HIGH,
                SEGMENT7_LOW,
                SEGMENT7_HIGH,
                SEGMENT8_LOW,
                SEGMENT8_HIGH,
                SEGMENT9_LOW,
                SEGMENT9_HIGH,
                SEGMENT10_LOW,
                SEGMENT10_HIGH,
                SEGMENT11_LOW,
                SEGMENT11_HIGH,
                SEGMENT12_LOW,
                SEGMENT12_HIGH,
                SEGMENT13_LOW,
                SEGMENT13_HIGH,
                SEGMENT14_LOW,
                SEGMENT14_HIGH,
                SEGMENT15_LOW,
                SEGMENT15_HIGH,
                SEGMENT16_LOW,
                SEGMENT16_HIGH,
                SEGMENT17_LOW,
                SEGMENT17_HIGH,
                SEGMENT18_LOW,
                SEGMENT18_HIGH,
                SEGMENT19_LOW,
                SEGMENT19_HIGH,
                SEGMENT20_LOW,
                SEGMENT20_HIGH,
                SEGMENT21_LOW,
                SEGMENT21_HIGH,
                SEGMENT22_LOW,
                SEGMENT22_HIGH,
                SEGMENT23_LOW,
                SEGMENT23_HIGH,
                SEGMENT24_LOW,
                SEGMENT24_HIGH,
                SEGMENT25_LOW,
                SEGMENT25_HIGH,
                SEGMENT26_LOW,
                SEGMENT26_HIGH,
                SEGMENT27_LOW,
                SEGMENT27_HIGH,
                SEGMENT28_LOW,
                SEGMENT28_HIGH,
                SEGMENT29_LOW,
                SEGMENT29_HIGH,
                SEGMENT30_LOW,
                SEGMENT30_HIGH,
                AMOUNT_TYPE,
                BOUNDARY_CODE,
                CONTEXT,
                FUNDING_BUDGET_VERSION_ID,
                PROGRAM_APPLICATION_ID,
                PROGRAM_ID,
                PROGRAM_UPDATE_DATE,
                REQUEST_ID,
                ATTRIBUTE1,
                ATTRIBUTE2,
                ATTRIBUTE3,
                ATTRIBUTE4,
                ATTRIBUTE5,
                ATTRIBUTE6,
                ATTRIBUTE7,
                ATTRIBUTE8,
                ATTRIBUTE9,
                ATTRIBUTE10,
                ATTRIBUTE11,
                ATTRIBUTE12,
                ATTRIBUTE13,
                ATTRIBUTE14,
                ATTRIBUTE15
                )

                VALUES (
                lc_merge_range1.budget_entity_id,
                lc_merge_range1.ledger_id,
                lc_merge_range1.currency_code,
                lc_merge_range1.entry_code,
                l_range_id_seq,
                lc_merge_range1.status,
                sysdate,
                lc_merge_range1.automatic_encumbrance_flag,
                lc_merge_range1.created_by,
                lc_merge_range1.creation_date,
                lc_merge_range1.funds_check_level_code,
                lc_merge_range1.last_updated_by,
                lc_merge_range1.last_update_login,
                l_seq_number,
                l_final_budget_ranges(i).segment_range_tab(1).SEGMENT_LOW,
                l_final_budget_ranges(i).segment_range_tab(1).SEGMENT_HIGH,
                l_final_budget_ranges(i).segment_range_tab(2).SEGMENT_LOW,
                l_final_budget_ranges(i).segment_range_tab(2).SEGMENT_HIGH,
                l_final_budget_ranges(i).segment_range_tab(3).SEGMENT_LOW,
                l_final_budget_ranges(i).segment_range_tab(3).SEGMENT_HIGH,
                l_final_budget_ranges(i).segment_range_tab(4).SEGMENT_LOW,
                l_final_budget_ranges(i).segment_range_tab(4).SEGMENT_HIGH,
                l_final_budget_ranges(i).segment_range_tab(5).SEGMENT_LOW,
                l_final_budget_ranges(i).segment_range_tab(5).SEGMENT_HIGH,
                l_final_budget_ranges(i).segment_range_tab(6).SEGMENT_LOW,
                l_final_budget_ranges(i).segment_range_tab(6).SEGMENT_HIGH,
                l_final_budget_ranges(i).segment_range_tab(7).SEGMENT_LOW,
                l_final_budget_ranges(i).segment_range_tab(7).SEGMENT_HIGH,
                l_final_budget_ranges(i).segment_range_tab(8).SEGMENT_LOW,
                l_final_budget_ranges(i).segment_range_tab(8).SEGMENT_HIGH,
                l_final_budget_ranges(i).segment_range_tab(9).SEGMENT_LOW,
                l_final_budget_ranges(i).segment_range_tab(9).SEGMENT_HIGH,
                l_final_budget_ranges(i).segment_range_tab(10).SEGMENT_LOW,
                l_final_budget_ranges(i).segment_range_tab(10).SEGMENT_HIGH,
                l_final_budget_ranges(i).segment_range_tab(11).SEGMENT_LOW,
                l_final_budget_ranges(i).segment_range_tab(11).SEGMENT_HIGH,
                l_final_budget_ranges(i).segment_range_tab(12).SEGMENT_LOW,
                l_final_budget_ranges(i).segment_range_tab(12).SEGMENT_HIGH,
                l_final_budget_ranges(i).segment_range_tab(13).SEGMENT_LOW,
                l_final_budget_ranges(i).segment_range_tab(13).SEGMENT_HIGH,
                l_final_budget_ranges(i).segment_range_tab(14).SEGMENT_LOW,
                l_final_budget_ranges(i).segment_range_tab(14).SEGMENT_HIGH,
                l_final_budget_ranges(i).segment_range_tab(15).SEGMENT_LOW,
                l_final_budget_ranges(i).segment_range_tab(15).SEGMENT_HIGH,
                l_final_budget_ranges(i).segment_range_tab(16).SEGMENT_LOW,
                l_final_budget_ranges(i).segment_range_tab(16).SEGMENT_HIGH,
                l_final_budget_ranges(i).segment_range_tab(17).SEGMENT_LOW,
                l_final_budget_ranges(i).segment_range_tab(17).SEGMENT_HIGH,
                l_final_budget_ranges(i).segment_range_tab(18).SEGMENT_LOW,
                l_final_budget_ranges(i).segment_range_tab(18).SEGMENT_HIGH,
                l_final_budget_ranges(i).segment_range_tab(19).SEGMENT_LOW,
                l_final_budget_ranges(i).segment_range_tab(19).SEGMENT_HIGH,
                l_final_budget_ranges(i).segment_range_tab(20).SEGMENT_LOW,
                l_final_budget_ranges(i).segment_range_tab(20).SEGMENT_HIGH,
                l_final_budget_ranges(i).segment_range_tab(21).SEGMENT_LOW,
                l_final_budget_ranges(i).segment_range_tab(21).SEGMENT_HIGH,
                l_final_budget_ranges(i).segment_range_tab(22).SEGMENT_LOW,
                l_final_budget_ranges(i).segment_range_tab(22).SEGMENT_HIGH,
                l_final_budget_ranges(i).segment_range_tab(23).SEGMENT_LOW,
                l_final_budget_ranges(i).segment_range_tab(23).SEGMENT_HIGH,
                l_final_budget_ranges(i).segment_range_tab(24).SEGMENT_LOW,
                l_final_budget_ranges(i).segment_range_tab(24).SEGMENT_HIGH,
                l_final_budget_ranges(i).segment_range_tab(25).SEGMENT_LOW,
                l_final_budget_ranges(i).segment_range_tab(25).SEGMENT_HIGH,
                l_final_budget_ranges(i).segment_range_tab(26).SEGMENT_LOW,
                l_final_budget_ranges(i).segment_range_tab(26).SEGMENT_HIGH,
                l_final_budget_ranges(i).segment_range_tab(27).SEGMENT_LOW,
                l_final_budget_ranges(i).segment_range_tab(27).SEGMENT_HIGH,
                l_final_budget_ranges(i).segment_range_tab(28).SEGMENT_LOW,
                l_final_budget_ranges(i).segment_range_tab(28).SEGMENT_HIGH,
                l_final_budget_ranges(i).segment_range_tab(29).SEGMENT_LOW,
                l_final_budget_ranges(i).segment_range_tab(29).SEGMENT_HIGH,
                l_final_budget_ranges(i).segment_range_tab(30).SEGMENT_LOW,
                l_final_budget_ranges(i).segment_range_tab(30).SEGMENT_HIGH,
                lc_merge_range1.amount_type,
                lc_merge_range1.boundary_code,
                lc_merge_range1.context,
                lc_merge_range1.funding_budget_version_id,
                lc_merge_range1.program_application_id,
                lc_merge_range1.program_id,
                lc_merge_range1.program_update_date,
                lc_merge_range1.request_id,
                lc_merge_range1.attribute1,
                lc_merge_range1.attribute2,
                lc_merge_range1.attribute3,
                lc_merge_range1.attribute4,
                lc_merge_range1.attribute5,
                lc_merge_range1.attribute6,
                lc_merge_range1.attribute7,
                lc_merge_range1.attribute8,
                lc_merge_range1.attribute9,
                lc_merge_range1.attribute10,
                lc_merge_range1.attribute11,
                lc_merge_range1.attribute12,
                lc_merge_range1.attribute13,
                lc_merge_range1.attribute14,
                lc_merge_range1.attribute15
                );

                EXCEPTION
                    WHEN OTHERS THEN
                        fnd_file.put_line(fnd_file.output, 'Error inserting records into IGI_UPG_GL_BUDGET_ASSIGNMENT Location 2');
                        fnd_file.put_line(fnd_file.log, 'Module: LOOP_AND_PROCESS =>'
                                 ||'Error inserting records into IGI_UPG_GL_BUDGET_ASSIGNMENT Location 2 '||SQLERRM);
                        errbuf  := 'Module: LOOP_AND_PROCESS =>'||'Error inserting records into
                                 IGI_UPG_GL_BUDGET_ASSIGNMENT Location 2 '||SQLERRM;
                        retcode := -1;
                        RETURN;
                END;


                --For each budget associated to this range, determine which
                --budget tab the value is in. Based on this corresponding
                --budget data is inserted
                FOR j IN 1..l_final_budget_ranges(i).budget_tab.COUNT LOOP

                    --l_inserted is used to determine if the values is already
                    --inserted or not
                    l_inserted := FALSE;

                    FOR k IN 1..lc_merge_range1_bc.COUNT LOOP
                        IF l_final_budget_ranges(i).budget_tab(j) = lc_merge_range1_bc(k).funding_budget_version_id
                        THEN
                            BEGIN
                            INSERT INTO IGI_UPG_GL_BUDORG_BC_OPTIONS
                            (
                            RANGE_ID,
                            FUNDING_BUDGET_VERSION_ID,
                            FUNDS_CHECK_LEVEL_CODE,
                            AMOUNT_TYPE,
                            BOUNDARY_CODE,
                            CREATED_BY,
                            CREATION_DATE,
                            LAST_UPDATED_BY,
                            LAST_UPDATE_LOGIN,
                            LAST_UPDATE_DATE
                            )
                            VALUES
                            (
                            l_range_id_seq,
                            lc_merge_range1_bc(k).funding_budget_version_id,
                            lc_merge_range1_bc(k).funds_check_level_code,
                            lc_merge_range1_bc(k).amount_type,
                            lc_merge_range1_bc(k).boundary_code,
                            lc_merge_range1_bc(k).created_by,
                            lc_merge_range1_bc(k).creation_date,
                            lc_merge_range1_bc(k).last_updated_by,
                            lc_merge_range1_bc(k).last_update_login,
                            sysdate
                            );
                            EXCEPTION
                                WHEN OTHERS THEN
                                    fnd_file.put_line(fnd_file.output, 'Error inserting records into
                                               IGI_UPG_GL_BUDORG_BC_OPTIONS Location 2');
                                    fnd_file.put_line(fnd_file.log, 'Module: LOOP_AND_PROCESS =>'||'Error inserting records into
                                               IGI_UPG_GL_BUDORG_BC_OPTIONS Location 2 '||SQLERRM);
                                    errbuf  := 'Module: LOOP_AND_PROCESS =>'||'Error inserting records into
                                               IGI_UPG_GL_BUDORG_BC_OPTIONS Location 2 '||SQLERRM;
                                    retcode := -1;
                                    RETURN;
                            END;
                            l_inserted := TRUE;
                            EXIT;
                        END IF;
                    END LOOP;
                    IF NOT l_inserted THEN
                        FOR r IN 1..lc_merge_range2_bc.COUNT LOOP
                            IF l_final_budget_ranges(i).budget_tab(j) = lc_merge_range2_bc(r).funding_budget_version_id
                            THEN
                                BEGIN
                                INSERT INTO IGI_UPG_GL_BUDORG_BC_OPTIONS
                                (
                                RANGE_ID,
                                FUNDING_BUDGET_VERSION_ID,
                                FUNDS_CHECK_LEVEL_CODE,
                                AMOUNT_TYPE,
                                BOUNDARY_CODE,
                                CREATED_BY,
                                CREATION_DATE,
                                LAST_UPDATED_BY,
                                LAST_UPDATE_LOGIN,
                                LAST_UPDATE_DATE
                                )
                                VALUES
                                (
                                l_range_id_seq,
                                lc_merge_range2_bc(r).funding_budget_version_id,
                                lc_merge_range2_bc(r).funds_check_level_code,
                                lc_merge_range2_bc(r).amount_type,
                                lc_merge_range2_bc(r).boundary_code,
                                lc_merge_range2_bc(r).created_by,
                                lc_merge_range2_bc(r).creation_date,
                                lc_merge_range2_bc(r).last_updated_by,
                                lc_merge_range2_bc(r).last_update_login,
                                sysdate
                                );
                                EXCEPTION
                                    WHEN OTHERS THEN
                                        fnd_file.put_line(fnd_file.output, 'Error inserting records into
                                                               IGI_UPG_GL_BUDORG_BC_OPTIONS Location 4');
                                        fnd_file.put_line(fnd_file.log, 'Module: LOOP_AND_PROCESS =>'||'Error inserting records into
                                                               IGI_UPG_GL_BUDORG_BC_OPTIONS Location 4 '||SQLERRM);
                                        errbuf  := 'Module: LOOP_AND_PROCESS =>'||'Error inserting records into
                                                               IGI_UPG_GL_BUDORG_BC_OPTIONS Location 4 '||SQLERRM;
                                        retcode := -1;
                                        RETURN;
                                END;
                                l_inserted := TRUE;
                                EXIT;
                            END IF;
                        END LOOP;
                    END IF;

                    IF NOT l_inserted THEN
                        fnd_file.put_line(fnd_file.output, 'Insertion failed - Reason not explicit');
                        fnd_file.put_line(fnd_file.log, 'Module: LOOP_AND_PROCESS =>'||'Insertion failed - Reason not explicit');
                        errbuf  := 'Module: LOOP_AND_PROCESS =>'||'Insertion failed - Reason not explicit';
                        retcode := -1;
                        RETURN;
                    END IF;

                END LOOP; -- END l_final_budget_ranges(i).budget_tab FOR LOOP


            END IF; --End of Compare Budgets If
        END LOOP; -- End l_final_budget_ranges FOR LOOP

        BEGIN
            --Since the splits ranges have been inserted
            --the original ranges have to be deleted from the backend
            DELETE FROM IGI_UPG_GL_BUDGET_ASSIGNMENT WHERE
            range_id = lc_merge_range2.range_id OR
            range_id = lc_merge_range1.range_id;

            DELETE FROM IGI_UPG_GL_BUDORG_BC_OPTIONS WHERE
            range_id = lc_merge_range2.range_id OR
            range_id = lc_merge_range1.range_id;
        EXCEPTION
            WHEN OTHERS THEN
                fnd_file.put_line(fnd_file.output, 'Error deleting data');
                fnd_file.put_line(fnd_file.log, 'Module: LOOP_AND_PROCESS =>'||'Error deleting data'||SQLERRM);
                errbuf  := 'Module: LOOP_AND_PROCESS =>'||'Error deleting data'||SQLERRM;
                retcode := -1;
                RETURN;
        END;

    -- End of Step 3

    -- Execution from Step 2 reaches this continue
    -- This continue is used to emulate the behavior of loop continuation
	<<continue>>
    NULL;

    END LOOP;

END LOOP_AND_PROCESS;


-- Procedure START_EFC_UPGRADE is the entry point for this upgrade program
-- START_EFC_UPGRADE is called from the concurrent program
-- START_EFC_UPGRADE does the necessary book keeping and in turn calls
-- the procedure LOOP_AND_PROCESS
PROCEDURE START_EFC_UPGRADE
(
errbuf           OUT NOCOPY VARCHAR2,
retcode          OUT NOCOPY NUMBER,
p_mode            IN NUMBER,
p_data_type       IN NUMBER,
p_debug_enabled   IN NUMBER
)
IS
    -- This cursor determines whether overlapping ranges exist
    -- This is used to determine whether to proceed with the upgrade or not
	CURSOR C_OVERLAPPING_RANGE_EXISTS IS
    SELECT 1 FROM DUAL WHERE EXISTS
    (
	SELECT 1 FROM GL_BUDGET_ASSIGNMENT_RANGES BA1
	WHERE EXISTS
		(SELECT 1 FROM
		GL_BUDGET_ASSIGNMENT_RANGES BA2
		WHERE
            BA2.ledger_id = BA1.ledger_id
            AND BA2.currency_code = BA1.currency_code
			AND BA1.RANGE_ID <> BA2.RANGE_ID
		    AND NVL(BA1.SEGMENT1_LOW,'X') <=  NVL(BA2.SEGMENT1_HIGH,'X')
			AND NVL(BA1.SEGMENT1_HIGH,'X') >= NVL(BA2.SEGMENT1_LOW,'X')
			AND NVL(BA1.SEGMENT2_LOW,'X') <=  NVL(BA2.SEGMENT2_HIGH,'X')
			AND NVL(BA1.SEGMENT2_HIGH,'X') >= NVL(BA2.SEGMENT2_LOW,'X')
		    AND NVL(BA1.SEGMENT3_LOW,'X') <=  NVL(BA2.SEGMENT3_HIGH,'X')
			AND NVL(BA1.SEGMENT3_HIGH,'X') >= NVL(BA2.SEGMENT3_LOW,'X')
			AND NVL(BA1.SEGMENT4_LOW,'X') <=  NVL(BA2.SEGMENT4_HIGH,'X')
			AND NVL(BA1.SEGMENT4_HIGH,'X') >= NVL(BA2.SEGMENT4_LOW,'X')
		    AND NVL(BA1.SEGMENT5_LOW,'X') <=  NVL(BA2.SEGMENT5_HIGH,'X')
			AND NVL(BA1.SEGMENT5_HIGH,'X') >= NVL(BA2.SEGMENT5_LOW,'X')
			AND NVL(BA1.SEGMENT6_LOW,'X') <=  NVL(BA2.SEGMENT6_HIGH,'X')
			AND NVL(BA1.SEGMENT6_HIGH,'X') >= NVL(BA2.SEGMENT6_LOW,'X')
			AND NVL(BA1.SEGMENT7_LOW,'X') <=  NVL(BA2.SEGMENT7_HIGH,'X')
			AND NVL(BA1.SEGMENT7_HIGH,'X') >= NVL(BA2.SEGMENT7_LOW,'X')
			AND NVL(BA1.SEGMENT8_LOW,'X') <=  NVL(BA2.SEGMENT8_HIGH,'X')
			AND NVL(BA1.SEGMENT8_HIGH,'X') >= NVL(BA2.SEGMENT8_LOW,'X')
			AND NVL(BA1.SEGMENT9_LOW,'X') <=  NVL(BA2.SEGMENT9_HIGH,'X')
			AND NVL(BA1.SEGMENT9_HIGH,'X') >= NVL(BA2.SEGMENT9_LOW,'X')
			AND NVL(BA1.SEGMENT10_LOW,'X') <=  NVL(BA2.SEGMENT10_HIGH,'X')
			AND NVL(BA1.SEGMENT10_HIGH,'X') >= NVL(BA2.SEGMENT10_LOW,'X')
			AND NVL(BA1.SEGMENT11_LOW,'X') <=  NVL(BA2.SEGMENT11_HIGH,'X')
			AND NVL(BA1.SEGMENT11_HIGH,'X') >= NVL(BA2.SEGMENT11_LOW,'X')
			AND NVL(BA1.SEGMENT12_LOW,'X') <=  NVL(BA2.SEGMENT12_HIGH,'X')
			AND NVL(BA1.SEGMENT12_HIGH,'X') >= NVL(BA2.SEGMENT12_LOW,'X')
			AND NVL(BA1.SEGMENT13_LOW,'X') <=  NVL(BA2.SEGMENT13_HIGH,'X')
			AND NVL(BA1.SEGMENT13_HIGH,'X') >= NVL(BA2.SEGMENT13_LOW,'X')
			AND NVL(BA1.SEGMENT14_LOW,'X') <=  NVL(BA2.SEGMENT14_HIGH,'X')
			AND NVL(BA1.SEGMENT14_HIGH,'X') >= NVL(BA2.SEGMENT14_LOW,'X')
			AND NVL(BA1.SEGMENT15_LOW,'X') <=  NVL(BA2.SEGMENT15_HIGH,'X')
			AND NVL(BA1.SEGMENT15_HIGH,'X') >= NVL(BA2.SEGMENT15_LOW,'X')
			AND NVL(BA1.SEGMENT16_LOW,'X') <=  NVL(BA2.SEGMENT16_HIGH,'X')
			AND NVL(BA1.SEGMENT16_HIGH,'X') >= NVL(BA2.SEGMENT16_LOW,'X')
			AND NVL(BA1.SEGMENT17_LOW,'X') <=  NVL(BA2.SEGMENT17_HIGH,'X')
			AND NVL(BA1.SEGMENT17_HIGH,'X') >= NVL(BA2.SEGMENT17_LOW,'X')
			AND NVL(BA1.SEGMENT18_LOW,'X') <=  NVL(BA2.SEGMENT18_HIGH,'X')
			AND NVL(BA1.SEGMENT18_HIGH,'X') >= NVL(BA2.SEGMENT18_LOW,'X')
			AND NVL(BA1.SEGMENT19_LOW,'X') <=  NVL(BA2.SEGMENT19_HIGH,'X')
			AND NVL(BA1.SEGMENT19_HIGH,'X') >= NVL(BA2.SEGMENT19_LOW,'X')
			AND NVL(BA1.SEGMENT20_LOW,'X') <=  NVL(BA2.SEGMENT20_HIGH,'X')
			AND NVL(BA1.SEGMENT20_HIGH,'X') >= NVL(BA2.SEGMENT20_LOW,'X')
			AND NVL(BA1.SEGMENT21_LOW,'X') <=  NVL(BA2.SEGMENT21_HIGH,'X')
			AND NVL(BA1.SEGMENT21_HIGH,'X') >= NVL(BA2.SEGMENT21_LOW,'X')
			AND NVL(BA1.SEGMENT22_LOW,'X') <=  NVL(BA2.SEGMENT22_HIGH,'X')
			AND NVL(BA1.SEGMENT22_HIGH,'X') >= NVL(BA2.SEGMENT22_LOW,'X')
			AND NVL(BA1.SEGMENT23_LOW,'X') <=  NVL(BA2.SEGMENT23_HIGH,'X')
			AND NVL(BA1.SEGMENT23_HIGH,'X') >= NVL(BA2.SEGMENT23_LOW,'X')
			AND NVL(BA1.SEGMENT24_LOW,'X') <=  NVL(BA2.SEGMENT24_HIGH,'X')
			AND NVL(BA1.SEGMENT24_HIGH,'X') >= NVL(BA2.SEGMENT24_LOW,'X')
			AND NVL(BA1.SEGMENT25_LOW,'X') <=  NVL(BA2.SEGMENT25_HIGH,'X')
			AND NVL(BA1.SEGMENT25_HIGH,'X') >= NVL(BA2.SEGMENT25_LOW,'X')
			AND NVL(BA1.SEGMENT26_LOW,'X') <=  NVL(BA2.SEGMENT26_HIGH,'X')
			AND NVL(BA1.SEGMENT26_HIGH,'X') >= NVL(BA2.SEGMENT26_LOW,'X')
			AND NVL(BA1.SEGMENT27_LOW,'X') <=  NVL(BA2.SEGMENT27_HIGH,'X')
			AND NVL(BA1.SEGMENT27_HIGH,'X') >= NVL(BA2.SEGMENT27_LOW,'X')
            AND NVL(BA1.SEGMENT28_LOW,'X') <=  NVL(BA2.SEGMENT28_HIGH,'X')
			AND NVL(BA1.SEGMENT28_HIGH,'X') >= NVL(BA2.SEGMENT28_LOW,'X')
			AND NVL(BA1.SEGMENT29_LOW,'X') <=  NVL(BA2.SEGMENT29_HIGH,'X')
			AND NVL(BA1.SEGMENT29_HIGH,'X') >= NVL(BA2.SEGMENT29_LOW,'X')
			AND NVL(BA1.SEGMENT30_LOW,'X') <=  NVL(BA2.SEGMENT30_HIGH,'X')
			AND NVL(BA1.SEGMENT30_HIGH,'X') >= NVL(BA2.SEGMENT30_LOW,'X')
		)
        AND BA1.RANGE_ID NOT IN (
        	SELECT RANGE_ID FROM GL_BUDGET_ASSIGNMENT_RANGES BA3
            WHERE
            BA3.LEDGER_ID = BA1.LEDGER_ID AND
            BA3.CURRENCY_CODE = BA1.CURRENCY_CODE AND
            EXISTS
            (SELECT 1 FROM
            GL_BUDGET_ASSIGNMENT_RANGES BA4
            WHERE
                BA4.ledger_id = BA3.ledger_id
                AND BA4.currency_code = BA3.currency_code
                AND BA3.RANGE_ID <> BA4.RANGE_ID
                AND NVL(BA3.SEGMENT1_LOW,'X') =  NVL(BA4.SEGMENT1_LOW,'X')
                AND NVL(BA3.SEGMENT1_HIGH,'X') = NVL(BA4.SEGMENT1_HIGH,'X')
                AND NVL(BA3.SEGMENT2_LOW,'X') =  NVL(BA4.SEGMENT2_LOW,'X')
                AND NVL(BA3.SEGMENT2_HIGH,'X') = NVL(BA4.SEGMENT2_HIGH,'X')
                AND NVL(BA3.SEGMENT3_LOW,'X') =  NVL(BA4.SEGMENT3_LOW,'X')
                AND NVL(BA3.SEGMENT3_HIGH,'X') = NVL(BA4.SEGMENT3_HIGH,'X')
                AND NVL(BA3.SEGMENT4_LOW,'X') =  NVL(BA4.SEGMENT4_LOW,'X')
                AND NVL(BA3.SEGMENT4_HIGH,'X') = NVL(BA4.SEGMENT4_HIGH,'X')
                AND NVL(BA3.SEGMENT5_LOW,'X') =  NVL(BA4.SEGMENT5_LOW,'X')
                AND NVL(BA3.SEGMENT5_HIGH,'X') = NVL(BA4.SEGMENT5_HIGH,'X')
                AND NVL(BA3.SEGMENT6_LOW,'X') =  NVL(BA4.SEGMENT6_LOW,'X')
                AND NVL(BA3.SEGMENT6_HIGH,'X') = NVL(BA4.SEGMENT6_HIGH,'X')
                AND NVL(BA3.SEGMENT7_LOW,'X') =  NVL(BA4.SEGMENT7_LOW,'X')
                AND NVL(BA3.SEGMENT7_HIGH,'X') = NVL(BA4.SEGMENT7_HIGH,'X')
                AND NVL(BA3.SEGMENT8_LOW,'X') =  NVL(BA4.SEGMENT8_LOW,'X')
                AND NVL(BA3.SEGMENT8_HIGH,'X') = NVL(BA4.SEGMENT8_HIGH,'X')
                AND NVL(BA3.SEGMENT9_LOW,'X') =  NVL(BA4.SEGMENT9_LOW,'X')
                AND NVL(BA3.SEGMENT9_HIGH,'X') = NVL(BA4.SEGMENT9_HIGH,'X')
                AND NVL(BA3.SEGMENT10_LOW,'X') =  NVL(BA4.SEGMENT10_LOW,'X')
                AND NVL(BA3.SEGMENT10_HIGH,'X') = NVL(BA4.SEGMENT10_HIGH,'X')
                AND NVL(BA3.SEGMENT11_LOW,'X') =  NVL(BA4.SEGMENT11_LOW,'X')
                AND NVL(BA3.SEGMENT11_HIGH,'X') = NVL(BA4.SEGMENT11_HIGH,'X')
                AND NVL(BA3.SEGMENT12_LOW,'X') =  NVL(BA4.SEGMENT12_LOW,'X')
                AND NVL(BA3.SEGMENT12_HIGH,'X') = NVL(BA4.SEGMENT12_HIGH,'X')
                AND NVL(BA3.SEGMENT13_LOW,'X') =  NVL(BA4.SEGMENT13_LOW,'X')
                AND NVL(BA3.SEGMENT13_HIGH,'X') = NVL(BA4.SEGMENT13_HIGH,'X')
                AND NVL(BA3.SEGMENT14_LOW,'X') =  NVL(BA4.SEGMENT14_LOW,'X')
                AND NVL(BA3.SEGMENT14_HIGH,'X') = NVL(BA4.SEGMENT14_HIGH,'X')
                AND NVL(BA3.SEGMENT15_LOW,'X') =  NVL(BA4.SEGMENT15_LOW,'X')
                AND NVL(BA3.SEGMENT15_HIGH,'X') = NVL(BA4.SEGMENT15_HIGH,'X')
                AND NVL(BA3.SEGMENT16_LOW,'X') =  NVL(BA4.SEGMENT16_LOW,'X')
                AND NVL(BA3.SEGMENT16_HIGH,'X') = NVL(BA4.SEGMENT16_HIGH,'X')
                AND NVL(BA3.SEGMENT17_LOW,'X') =  NVL(BA4.SEGMENT17_LOW,'X')
                AND NVL(BA3.SEGMENT17_HIGH,'X') = NVL(BA4.SEGMENT17_HIGH,'X')
                AND NVL(BA3.SEGMENT18_LOW,'X') =  NVL(BA4.SEGMENT18_LOW,'X')
                AND NVL(BA3.SEGMENT18_HIGH,'X') = NVL(BA4.SEGMENT18_HIGH,'X')
                AND NVL(BA3.SEGMENT19_LOW,'X') =  NVL(BA4.SEGMENT19_LOW,'X')
                AND NVL(BA3.SEGMENT19_HIGH,'X') = NVL(BA4.SEGMENT19_HIGH,'X')
                AND NVL(BA3.SEGMENT20_LOW,'X') =  NVL(BA4.SEGMENT20_LOW,'X')
                AND NVL(BA3.SEGMENT20_HIGH,'X') = NVL(BA4.SEGMENT20_HIGH,'X')
                AND NVL(BA3.SEGMENT21_LOW,'X') =  NVL(BA4.SEGMENT21_LOW,'X')
                AND NVL(BA3.SEGMENT21_HIGH,'X') = NVL(BA4.SEGMENT21_HIGH,'X')
                AND NVL(BA3.SEGMENT22_LOW,'X') =  NVL(BA4.SEGMENT22_LOW,'X')
                AND NVL(BA3.SEGMENT22_HIGH,'X') = NVL(BA4.SEGMENT22_HIGH,'X')
                AND NVL(BA3.SEGMENT23_LOW,'X') =  NVL(BA4.SEGMENT23_LOW,'X')
                AND NVL(BA3.SEGMENT23_HIGH,'X') = NVL(BA4.SEGMENT23_HIGH,'X')
                AND NVL(BA3.SEGMENT24_LOW,'X') =  NVL(BA4.SEGMENT24_LOW,'X')
                AND NVL(BA3.SEGMENT24_HIGH,'X') = NVL(BA4.SEGMENT24_HIGH,'X')
                AND NVL(BA3.SEGMENT25_LOW,'X') =  NVL(BA4.SEGMENT25_LOW,'X')
                AND NVL(BA3.SEGMENT25_HIGH,'X') = NVL(BA4.SEGMENT25_HIGH,'X')
                AND NVL(BA3.SEGMENT26_LOW,'X') =  NVL(BA4.SEGMENT26_LOW,'X')
                AND NVL(BA3.SEGMENT26_HIGH,'X') = NVL(BA4.SEGMENT26_HIGH,'X')
                AND NVL(BA3.SEGMENT27_LOW,'X') =  NVL(BA4.SEGMENT27_LOW,'X')
                AND NVL(BA3.SEGMENT27_HIGH,'X') = NVL(BA4.SEGMENT27_HIGH,'X')
                AND NVL(BA3.SEGMENT28_LOW,'X') =  NVL(BA4.SEGMENT28_LOW,'X')
                AND NVL(BA3.SEGMENT28_HIGH,'X') = NVL(BA4.SEGMENT28_HIGH,'X')
                AND NVL(BA3.SEGMENT29_LOW,'X') =  NVL(BA4.SEGMENT29_LOW,'X')
                AND NVL(BA3.SEGMENT29_HIGH,'X') = NVL(BA4.SEGMENT29_HIGH,'X')
                AND NVL(BA3.SEGMENT30_LOW,'X') =  NVL(BA4.SEGMENT30_LOW,'X')
                AND NVL(BA3.SEGMENT30_HIGH,'X') = NVL(BA4.SEGMENT30_HIGH,'X')
            ))
            AND EXISTS
            (SELECT 1
                    FROM GL_BUDGET_ENTITIES glent
                    WHERE
                    BA1.ledger_id = glent.ledger_id AND
                    EXISTS (
                        SELECT 1
                        FROM PSA_EFC_OPTIONS psaefc
                        WHERE psaefc.set_of_books_id = glent.ledger_id
                        AND psaefc.mult_funding_budgets_flag = 'Y'
                    ))

            );

    -- Fetches all EFC Enabled ledgers
    CURSOR c_ledger_info IS
    SELECT DISTINCT glent.ledger_id
    FROM gl_budget_entities glent
    WHERE EXISTS (
        SELECT 1
        FROM psa_efc_options psaefc
        WHERE psaefc.set_of_books_id = glent.ledger_id
        AND psaefc.mult_funding_budgets_flag = 'Y'
    );

    -- This cursor is used to determine whether the upgrade has been run in
    -- final mode or not. When run in final mode this table is populated.
    CURSOR c_backup_exists IS
    SELECT * FROM IGI_EFC_BUDGET_ASSIGNMENT_BCK;

    lc_backup_exists c_backup_exists%ROWTYPE;
    lc_c_ledger_info c_ledger_info%ROWTYPE;

    l_errbuf VARCHAR2(2000);
    l_retcode NUMBER;

    lc_overlapping_range_exists C_OVERLAPPING_RANGE_EXISTS%ROWTYPE;

    request_id NUMBER;

BEGIN

    SAVEPOINT EFC_UPGRADE_START;

    budget_entity_tab := budget_entity_type();

    -- Fetch all EFC enabled ledgers
    -- If no EFC Enabled ledgers exist then throw error
    OPEN c_ledger_info;
    FETCH c_ledger_info INTO lc_c_ledger_info;
    IF c_ledger_info%NOTFOUND THEN
        CLOSE c_ledger_info;
        fnd_file.put_line(fnd_file.output, 'No EFC Ledgers Found');
        fnd_file.put_line(fnd_file.log, 'Module: START_EFC_UPGRADE =>'||'No EFC Ledgers Found');
        errbuf  := 'No EFC Ledgers Found';
        retcode := -1;
        RETURN;
    END IF;
    CLOSE c_ledger_info;

    g_debug_enabled := p_debug_enabled;


    -- Check if any ranges overlap in merge fashion. If Yes, then
    -- proceed with upgrade only if p_data_type is 0
    -- Otherwise throw error
    OPEN C_OVERLAPPING_RANGE_EXISTS;
    FETCH C_OVERLAPPING_RANGE_EXISTS INTO lc_overlapping_range_exists;
    IF C_OVERLAPPING_RANGE_EXISTS%FOUND AND p_data_type <> 0 THEN
        CLOSE C_OVERLAPPING_RANGE_EXISTS;
        fnd_file.put_line(fnd_file.output, 'You have segment ranges which merge with other segment ranges
                                            for the same ledger and currency. This upgrade script does
                                            not support merging segment ranges for segments which have variable
                                            non numeric values. Merging segment ranges are supported only if your
                                            segment contains fixed length numeric values. Please contact Oracle Support for help');
        fnd_file.put_line(fnd_file.log,  'You have segment ranges which merge with other segment ranges
                                            for the same ledger and currency code. This upgrade script does
                                            not support merging segment ranges for segments which have variable
                                            non numeric values. Merging segment ranges are supported only if your
                                            segment contains fixed length numeric values. Please contact Oracle Support for help');
        errbuf  := 'Non numeric segments exists and merging ranges are found';
        retcode := -1;
        RETURN;
    ELSE
        CLOSE C_OVERLAPPING_RANGE_EXISTS;
    END IF;

    IF p_mode = 1 THEN
        fnd_file.put_line(fnd_file.output, 'Running EFC Upgrade in Final Mode');
        fnd_file.put_line(fnd_file.log, 'Module: START_EFC_UPGRADE =>'||'Running EFC Upgrade in Final Mode');
    ELSE
        fnd_file.put_line(fnd_file.output, 'Running EFC Upgrade in Preliminary Mode');
        fnd_file.put_line(fnd_file.log, 'Module: START_EFC_UPGRADE =>'||'Running EFC Upgrade in Preliminary Mode');
    END IF;


    -- Typically data should not exist in these tables at this point. Deletion
    -- has been added to ensure that no data exists
    BEGIN

        DELETE FROM IGI_UPG_GL_BUDGET_ASSIGNMENT;
        DELETE FROM IGI_UPG_GL_BUDORG_BC_OPTIONS;

    EXCEPTION
        WHEN OTHERS THEN
            fnd_file.put_line(fnd_file.output, 'Purging of tables failed');
            fnd_file.put_line(fnd_file.log, 'Module: START_EFC_UPGRADE =>'||'Purging of tables failed =>'||SQLERRM);
            errbuf  := 'Purging of tables failed'||SQLERRM;
            retcode := -1;
            RETURN;
    END;

    -- If run in Final mode, backup all existing data
    IF p_mode = 1 THEN

        -- Stop the upgrade if it has already been run in final mode
        OPEN c_backup_exists;
        FETCH c_backup_exists INTO lc_backup_exists;
        IF c_backup_exists%FOUND THEN
            --Error final mode run twice
            CLOSE c_backup_exists;
            fnd_file.put_line(fnd_file.output, 'Upgrade Script has been run in Final Mode and thus cannot be run in Final Mode again');
            fnd_file.put_line(fnd_file.log, 'Module: START_EFC_UPGRADE =>'||'Upgrade Script has been run in Final Mode');
            errbuf  := 'Upgrade Script has been run in Final Mode and thus cannot be run again';
            retcode := -1;
            RETURN;
        END IF;
        CLOSE c_backup_exists;


        -- Backup all existing data into IGI_EFC_BUDGET_ASSIGNMENT_BCK
        BEGIN

        INSERT INTO IGI_EFC_BUDGET_ASSIGNMENT_BCK
        (
            BUDGET_ENTITY_ID,
            LEDGER_ID,
            CURRENCY_CODE,
            ENTRY_CODE,
            RANGE_ID,
            STATUS,
            LAST_UPDATE_DATE,
            AUTOMATIC_ENCUMBRANCE_FLAG,
            CREATED_BY,
            CREATION_DATE,
            FUNDS_CHECK_LEVEL_CODE,
            LAST_UPDATED_BY,
            LAST_UPDATE_LOGIN,
            SEQUENCE_NUMBER,
            SEGMENT1_LOW,
            SEGMENT1_HIGH,
            SEGMENT2_LOW,
            SEGMENT2_HIGH,
            SEGMENT3_LOW,
            SEGMENT3_HIGH,
            SEGMENT4_LOW,
            SEGMENT4_HIGH,
            SEGMENT5_LOW,
            SEGMENT5_HIGH,
            SEGMENT6_LOW,
            SEGMENT6_HIGH,
            SEGMENT7_LOW,
            SEGMENT7_HIGH,
            SEGMENT8_LOW,
            SEGMENT8_HIGH,
            SEGMENT9_LOW,
            SEGMENT9_HIGH,
            SEGMENT10_LOW,
            SEGMENT10_HIGH,
            SEGMENT11_LOW,
            SEGMENT11_HIGH,
            SEGMENT12_LOW,
            SEGMENT12_HIGH,
            SEGMENT13_LOW,
            SEGMENT13_HIGH,
            SEGMENT14_LOW,
            SEGMENT14_HIGH,
            SEGMENT15_LOW,
            SEGMENT15_HIGH,
            SEGMENT16_LOW,
            SEGMENT16_HIGH,
            SEGMENT17_LOW,
            SEGMENT17_HIGH,
            SEGMENT18_LOW,
            SEGMENT18_HIGH,
            SEGMENT19_LOW,
            SEGMENT19_HIGH,
            SEGMENT20_LOW,
            SEGMENT20_HIGH,
            SEGMENT21_LOW,
            SEGMENT21_HIGH,
            SEGMENT22_LOW,
            SEGMENT22_HIGH,
            SEGMENT23_LOW,
            SEGMENT23_HIGH,
            SEGMENT24_LOW,
            SEGMENT24_HIGH,
            SEGMENT25_LOW,
            SEGMENT25_HIGH,
            SEGMENT26_LOW,
            SEGMENT26_HIGH,
            SEGMENT27_LOW,
            SEGMENT27_HIGH,
            SEGMENT28_LOW,
            SEGMENT28_HIGH,
            SEGMENT29_LOW,
            SEGMENT29_HIGH,
            SEGMENT30_LOW,
            SEGMENT30_HIGH,
            AMOUNT_TYPE,
            BOUNDARY_CODE,
            CONTEXT,
            FUNDING_BUDGET_VERSION_ID,
            PROGRAM_APPLICATION_ID,
            PROGRAM_ID,
            PROGRAM_UPDATE_DATE,
            REQUEST_ID,
            ATTRIBUTE1,
            ATTRIBUTE2,
            ATTRIBUTE3,
            ATTRIBUTE4,
            ATTRIBUTE5,
            ATTRIBUTE6,
            ATTRIBUTE7,
            ATTRIBUTE8,
            ATTRIBUTE9,
            ATTRIBUTE10,
            ATTRIBUTE11,
            ATTRIBUTE12,
            ATTRIBUTE13,
            ATTRIBUTE14,
            ATTRIBUTE15
        )
        SELECT
            BUDGET_ENTITY_ID,
            LEDGER_ID,
            CURRENCY_CODE,
            ENTRY_CODE,
            RANGE_ID,
            STATUS,
            LAST_UPDATE_DATE,
            AUTOMATIC_ENCUMBRANCE_FLAG,
            CREATED_BY,
            CREATION_DATE,
            FUNDS_CHECK_LEVEL_CODE,
            LAST_UPDATED_BY,
            LAST_UPDATE_LOGIN,
            SEQUENCE_NUMBER,
            SEGMENT1_LOW,
            SEGMENT1_HIGH,
            SEGMENT2_LOW,
            SEGMENT2_HIGH,
            SEGMENT3_LOW,
            SEGMENT3_HIGH,
            SEGMENT4_LOW,
            SEGMENT4_HIGH,
            SEGMENT5_LOW,
            SEGMENT5_HIGH,
            SEGMENT6_LOW,
            SEGMENT6_HIGH,
            SEGMENT7_LOW,
            SEGMENT7_HIGH,
            SEGMENT8_LOW,
            SEGMENT8_HIGH,
            SEGMENT9_LOW,
            SEGMENT9_HIGH,
            SEGMENT10_LOW,
            SEGMENT10_HIGH,
            SEGMENT11_LOW,
            SEGMENT11_HIGH,
            SEGMENT12_LOW,
            SEGMENT12_HIGH,
            SEGMENT13_LOW,
            SEGMENT13_HIGH,
            SEGMENT14_LOW,
            SEGMENT14_HIGH,
            SEGMENT15_LOW,
            SEGMENT15_HIGH,
            SEGMENT16_LOW,
            SEGMENT16_HIGH,
            SEGMENT17_LOW,
            SEGMENT17_HIGH,
            SEGMENT18_LOW,
            SEGMENT18_HIGH,
            SEGMENT19_LOW,
            SEGMENT19_HIGH,
            SEGMENT20_LOW,
            SEGMENT20_HIGH,
            SEGMENT21_LOW,
            SEGMENT21_HIGH,
            SEGMENT22_LOW,
            SEGMENT22_HIGH,
            SEGMENT23_LOW,
            SEGMENT23_HIGH,
            SEGMENT24_LOW,
            SEGMENT24_HIGH,
            SEGMENT25_LOW,
            SEGMENT25_HIGH,
            SEGMENT26_LOW,
            SEGMENT26_HIGH,
            SEGMENT27_LOW,
            SEGMENT27_HIGH,
            SEGMENT28_LOW,
            SEGMENT28_HIGH,
            SEGMENT29_LOW,
            SEGMENT29_HIGH,
            SEGMENT30_LOW,
            SEGMENT30_HIGH,
            AMOUNT_TYPE,
            BOUNDARY_CODE,
            CONTEXT,
            FUNDING_BUDGET_VERSION_ID,
            PROGRAM_APPLICATION_ID,
            PROGRAM_ID,
            PROGRAM_UPDATE_DATE,
            REQUEST_ID,
            ATTRIBUTE1,
            ATTRIBUTE2,
            ATTRIBUTE3,
            ATTRIBUTE4,
            ATTRIBUTE5,
            ATTRIBUTE6,
            ATTRIBUTE7,
            ATTRIBUTE8,
            ATTRIBUTE9,
            ATTRIBUTE10,
            ATTRIBUTE11,
            ATTRIBUTE12,
            ATTRIBUTE13,
            ATTRIBUTE14,
            ATTRIBUTE15
        FROM GL_BUDGET_ASSIGNMENT_RANGES gar
        WHERE exists (SELECT 1
                        FROM gl_budget_entities glent
                        WHERE
                        gar.ledger_id = glent.ledger_id AND
                        EXISTS (
                            SELECT 1
                            FROM psa_efc_options psaefc
                            WHERE psaefc.set_of_books_id = glent.ledger_id
                            AND psaefc.mult_funding_budgets_flag = 'Y'
                        ));

        EXCEPTION
            WHEN OTHERS THEN
                fnd_file.put_line(fnd_file.output, 'Unexpected Error: Please check the log');
                fnd_file.put_line(fnd_file.log, 'Module: START_EFC_UPGRADE =>'||'Error while inserting into
                IGI_EFC_BUDGET_ASSIGNMENT_BCK =>'||SQLERRM);
                errbuf  := 'Module: START_EFC_UPGRADE =>'||'Error while inserting into
                IGI_EFC_BUDGET_ASSIGNMENT_BCK =>'||SQLERRM;
                retcode := -1;
                RETURN;
        END;

        -- Backup all existing budgets into IGI_BUDORG_BC_OPTIONS_BCK
        BEGIN
        INSERT INTO IGI_BUDORG_BC_OPTIONS_BCK
        (
        RANGE_ID,
        FUNDING_BUDGET_VERSION_ID,
        FUNDS_CHECK_LEVEL_CODE,
        AMOUNT_TYPE,
        BOUNDARY_CODE,
        CREATED_BY,
        CREATION_DATE,
        LAST_UPDATED_BY,
        LAST_UPDATE_LOGIN,
        LAST_UPDATE_DATE
        )
        SELECT
            RANGE_ID,
            FUNDING_BUDGET_VERSION_ID,
            FUNDS_CHECK_LEVEL_CODE,
            AMOUNT_TYPE,
            BOUNDARY_CODE,
            CREATED_BY,
            CREATION_DATE,
            LAST_UPDATED_BY,
            LAST_UPDATE_LOGIN,
            LAST_UPDATE_DATE
        FROM GL_BUDORG_BC_OPTIONS
        WHERE range_id IN
                      (SELECT range_id
                       FROM
                       IGI_EFC_BUDGET_ASSIGNMENT_BCK);

        EXCEPTION
            WHEN OTHERS THEN
                fnd_file.put_line(fnd_file.output, 'Unexpected Error: Please check the log');
                fnd_file.put_line(fnd_file.log, 'Module: START_EFC_UPGRADE =>'||'Error while inserting into
                IGI_BUDORG_BC_OPTIONS_BCK =>'||SQLERRM);
                errbuf  := 'Module: START_EFC_UPGRADE =>'||'Error while inserting into
                IGI_BUDORG_BC_OPTIONS_BCK =>'||SQLERRM;
                retcode := -1;
                RETURN;
        END;

        -- Backup all existing assignments into IGI_GL_BUDGET_ASSIGN_BCK
        BEGIN
        INSERT INTO IGI_GL_BUDGET_ASSIGN_BCK
        (
            LEDGER_ID,
            BUDGET_ENTITY_ID,
            CURRENCY_CODE,
            CODE_COMBINATION_ID,
            RANGE_ID,
            ENTRY_CODE,
            LAST_UPDATE_DATE,
            LAST_UPDATED_BY,
            AUTOMATIC_ENCUMBRANCE_FLAG,
            FUNDS_CHECK_LEVEL_CODE,
            ORDERING_VALUE,
            CREATION_DATE,
            CREATED_BY,
            LAST_UPDATE_LOGIN,
            ATTRIBUTE1,
            ATTRIBUTE2,
            ATTRIBUTE3,
            ATTRIBUTE4,
            ATTRIBUTE5,
            ATTRIBUTE6,
            ATTRIBUTE7,
            ATTRIBUTE8,
            CONTEXT,
            AMOUNT_TYPE,
            BOUNDARY_CODE,
            FUNDING_BUDGET_VERSION_ID,
            PROGRAM_APPLICATION_ID,
            PROGRAM_ID,
            PROGRAM_UPDATE_DATE,
            REQUEST_ID
        )
        SELECT
            LEDGER_ID,
            BUDGET_ENTITY_ID,
            CURRENCY_CODE,
            CODE_COMBINATION_ID,
            RANGE_ID,
            ENTRY_CODE,
            LAST_UPDATE_DATE,
            LAST_UPDATED_BY,
            AUTOMATIC_ENCUMBRANCE_FLAG,
            FUNDS_CHECK_LEVEL_CODE,
            ORDERING_VALUE,
            CREATION_DATE,
            CREATED_BY,
            LAST_UPDATE_LOGIN,
            ATTRIBUTE1,
            ATTRIBUTE2,
            ATTRIBUTE3,
            ATTRIBUTE4,
            ATTRIBUTE5,
            ATTRIBUTE6,
            ATTRIBUTE7,
            ATTRIBUTE8,
            CONTEXT,
            AMOUNT_TYPE,
            BOUNDARY_CODE,
            FUNDING_BUDGET_VERSION_ID,
            PROGRAM_APPLICATION_ID,
            PROGRAM_ID,
            PROGRAM_UPDATE_DATE,
            REQUEST_ID
        FROM GL_BUDGET_ASSIGNMENTS
        WHERE range_id IN
                      (SELECT range_id
                       FROM
                       IGI_EFC_BUDGET_ASSIGNMENT_BCK);

        EXCEPTION
            WHEN OTHERS THEN
                fnd_file.put_line(fnd_file.output, 'Unexpected Error: Please check the log');
                fnd_file.put_line(fnd_file.log, 'Module: START_EFC_UPGRADE =>'||'Error while inserting into
                IGI_GL_BUDGET_ASSIGN_BCK =>'||SQLERRM);
                errbuf  := 'Module: START_EFC_UPGRADE =>'||'Error while inserting into
                IGI_GL_BUDGET_ASSIGN_BCK =>'||SQLERRM;
                retcode := -1;
                RETURN;
        END;
    END IF; -- If mode is Final mode


    -- Copy all ranges belonging to EFC enabled ledgers into
    -- the processing table IGI_UPG_GL_BUDGET_ASSIGNMENT
    -- LOOP_AND_PROCESS picks up data from IGI_UPG_GL_BUDGET_ASSIGNMENT for
    -- processing. Data is pushed into IGI_UPG_GL_BUDGET_ASSIGNMENT
    -- instead of directly accessing it as recursive processing is needed to
    -- ensure non overlap of all ranges. Once all processing is completed
    -- data is inserted into the GL table
    BEGIN

    INSERT INTO IGI_UPG_GL_BUDGET_ASSIGNMENT
    (
        BUDGET_ENTITY_ID,
        LEDGER_ID,
        CURRENCY_CODE,
        ENTRY_CODE,
        RANGE_ID,
        STATUS,
        LAST_UPDATE_DATE,
        AUTOMATIC_ENCUMBRANCE_FLAG,
        CREATED_BY,
        CREATION_DATE,
        FUNDS_CHECK_LEVEL_CODE,
        LAST_UPDATED_BY,
        LAST_UPDATE_LOGIN,
        SEQUENCE_NUMBER,
        SEGMENT1_LOW,
        SEGMENT1_HIGH,
        SEGMENT2_LOW,
        SEGMENT2_HIGH,
        SEGMENT3_LOW,
        SEGMENT3_HIGH,
        SEGMENT4_LOW,
        SEGMENT4_HIGH,
        SEGMENT5_LOW,
        SEGMENT5_HIGH,
        SEGMENT6_LOW,
        SEGMENT6_HIGH,
        SEGMENT7_LOW,
        SEGMENT7_HIGH,
        SEGMENT8_LOW,
        SEGMENT8_HIGH,
        SEGMENT9_LOW,
        SEGMENT9_HIGH,
        SEGMENT10_LOW,
        SEGMENT10_HIGH,
        SEGMENT11_LOW,
        SEGMENT11_HIGH,
        SEGMENT12_LOW,
        SEGMENT12_HIGH,
        SEGMENT13_LOW,
        SEGMENT13_HIGH,
        SEGMENT14_LOW,
        SEGMENT14_HIGH,
        SEGMENT15_LOW,
        SEGMENT15_HIGH,
        SEGMENT16_LOW,
        SEGMENT16_HIGH,
        SEGMENT17_LOW,
        SEGMENT17_HIGH,
        SEGMENT18_LOW,
        SEGMENT18_HIGH,
        SEGMENT19_LOW,
        SEGMENT19_HIGH,
        SEGMENT20_LOW,
        SEGMENT20_HIGH,
        SEGMENT21_LOW,
        SEGMENT21_HIGH,
        SEGMENT22_LOW,
        SEGMENT22_HIGH,
        SEGMENT23_LOW,
        SEGMENT23_HIGH,
        SEGMENT24_LOW,
        SEGMENT24_HIGH,
        SEGMENT25_LOW,
        SEGMENT25_HIGH,
        SEGMENT26_LOW,
        SEGMENT26_HIGH,
        SEGMENT27_LOW,
        SEGMENT27_HIGH,
        SEGMENT28_LOW,
        SEGMENT28_HIGH,
        SEGMENT29_LOW,
        SEGMENT29_HIGH,
        SEGMENT30_LOW,
        SEGMENT30_HIGH,
        AMOUNT_TYPE,
        BOUNDARY_CODE,
        CONTEXT,
        FUNDING_BUDGET_VERSION_ID,
        PROGRAM_APPLICATION_ID,
        PROGRAM_ID,
        PROGRAM_UPDATE_DATE,
        REQUEST_ID,
        ATTRIBUTE1,
        ATTRIBUTE2,
        ATTRIBUTE3,
        ATTRIBUTE4,
        ATTRIBUTE5,
        ATTRIBUTE6,
        ATTRIBUTE7,
        ATTRIBUTE8,
        ATTRIBUTE9,
        ATTRIBUTE10,
        ATTRIBUTE11,
        ATTRIBUTE12,
        ATTRIBUTE13,
        ATTRIBUTE14,
        ATTRIBUTE15
    )
    SELECT
        BUDGET_ENTITY_ID,
        LEDGER_ID,
        CURRENCY_CODE,
        ENTRY_CODE,
        RANGE_ID,
        STATUS,
        LAST_UPDATE_DATE,
        AUTOMATIC_ENCUMBRANCE_FLAG,
        CREATED_BY,
        CREATION_DATE,
        FUNDS_CHECK_LEVEL_CODE,
        LAST_UPDATED_BY,
        LAST_UPDATE_LOGIN,
        SEQUENCE_NUMBER,
        SEGMENT1_LOW,
        SEGMENT1_HIGH,
        SEGMENT2_LOW,
        SEGMENT2_HIGH,
        SEGMENT3_LOW,
        SEGMENT3_HIGH,
        SEGMENT4_LOW,
        SEGMENT4_HIGH,
        SEGMENT5_LOW,
        SEGMENT5_HIGH,
        SEGMENT6_LOW,
        SEGMENT6_HIGH,
        SEGMENT7_LOW,
        SEGMENT7_HIGH,
        SEGMENT8_LOW,
        SEGMENT8_HIGH,
        SEGMENT9_LOW,
        SEGMENT9_HIGH,
        SEGMENT10_LOW,
        SEGMENT10_HIGH,
        SEGMENT11_LOW,
        SEGMENT11_HIGH,
        SEGMENT12_LOW,
        SEGMENT12_HIGH,
        SEGMENT13_LOW,
        SEGMENT13_HIGH,
        SEGMENT14_LOW,
        SEGMENT14_HIGH,
        SEGMENT15_LOW,
        SEGMENT15_HIGH,
        SEGMENT16_LOW,
        SEGMENT16_HIGH,
        SEGMENT17_LOW,
        SEGMENT17_HIGH,
        SEGMENT18_LOW,
        SEGMENT18_HIGH,
        SEGMENT19_LOW,
        SEGMENT19_HIGH,
        SEGMENT20_LOW,
        SEGMENT20_HIGH,
        SEGMENT21_LOW,
        SEGMENT21_HIGH,
        SEGMENT22_LOW,
        SEGMENT22_HIGH,
        SEGMENT23_LOW,
        SEGMENT23_HIGH,
        SEGMENT24_LOW,
        SEGMENT24_HIGH,
        SEGMENT25_LOW,
        SEGMENT25_HIGH,
        SEGMENT26_LOW,
        SEGMENT26_HIGH,
        SEGMENT27_LOW,
        SEGMENT27_HIGH,
        SEGMENT28_LOW,
        SEGMENT28_HIGH,
        SEGMENT29_LOW,
        SEGMENT29_HIGH,
        SEGMENT30_LOW,
        SEGMENT30_HIGH,
        AMOUNT_TYPE,
        BOUNDARY_CODE,
        CONTEXT,
        FUNDING_BUDGET_VERSION_ID,
        PROGRAM_APPLICATION_ID,
        PROGRAM_ID,
        PROGRAM_UPDATE_DATE,
        REQUEST_ID,
        ATTRIBUTE1,
        ATTRIBUTE2,
        ATTRIBUTE3,
        ATTRIBUTE4,
        ATTRIBUTE5,
        ATTRIBUTE6,
        ATTRIBUTE7,
        ATTRIBUTE8,
        ATTRIBUTE9,
        ATTRIBUTE10,
        ATTRIBUTE11,
        ATTRIBUTE12,
        ATTRIBUTE13,
        ATTRIBUTE14,
        ATTRIBUTE15
    FROM GL_BUDGET_ASSIGNMENT_RANGES gar
    WHERE exists (SELECT 1
                    FROM GL_BUDGET_ENTITIES glent
                    WHERE
                    gar.ledger_id = glent.ledger_id AND
                    EXISTS (
                        SELECT 1
                        FROM PSA_EFC_OPTIONS psaefc
                        WHERE psaefc.set_of_books_id = glent.ledger_id
                        AND psaefc.mult_funding_budgets_flag = 'Y'
                    ));

    EXCEPTION
        WHEN OTHERS THEN
            fnd_file.put_line(fnd_file.output, 'Unexpected Error: Please check the log');
            fnd_file.put_line(fnd_file.log, 'Module: START_EFC_UPGRADE =>'||'Error while inserting into
            IGI_UPG_GL_BUDGET_ASSIGNMENT =>'||SQLERRM);
            errbuf  := 'Module: START_EFC_UPGRADE =>'||'Error while inserting into
            IGI_UPG_GL_BUDGET_ASSIGNMENT =>'||SQLERRM;
            retcode := -1;
            RETURN;
    END;


    BEGIN

    INSERT INTO IGI_UPG_GL_BUDORG_BC_OPTIONS
    (
    RANGE_ID,
    FUNDING_BUDGET_VERSION_ID,
    FUNDS_CHECK_LEVEL_CODE,
    AMOUNT_TYPE,
    BOUNDARY_CODE,
    CREATED_BY,
    CREATION_DATE,
    LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN,
    LAST_UPDATE_DATE
    )
    SELECT
        RANGE_ID,
        FUNDING_BUDGET_VERSION_ID,
        FUNDS_CHECK_LEVEL_CODE,
        AMOUNT_TYPE,
        BOUNDARY_CODE,
        CREATED_BY,
        CREATION_DATE,
        LAST_UPDATED_BY,
        LAST_UPDATE_LOGIN,
        LAST_UPDATE_DATE
    FROM GL_BUDORG_BC_OPTIONS
    WHERE range_id IN
                  (SELECT range_id
                   FROM
                   IGI_UPG_GL_BUDGET_ASSIGNMENT);

    EXCEPTION
        WHEN OTHERS THEN
            fnd_file.put_line(fnd_file.output, 'Unexpected Error: Please check the log');
            fnd_file.put_line(fnd_file.log, 'Module: START_EFC_UPGRADE =>'||'Error while inserting into
            IGI_UPG_GL_BUDORG_BC_OPTIONS =>'||SQLERRM);
            errbuf  := 'Module: START_EFC_UPGRADE =>'||'Error while inserting into
            IGI_UPG_GL_BUDORG_BC_OPTIONS =>'||SQLERRM;
            retcode := -1;
            RETURN;
    END;

    -- If the report is run in final mode, then delete all
    -- the data that were picked up from the GL tables
    IF p_mode = 1 THEN

        BEGIN

        DELETE FROM GL_BUDORG_BC_OPTIONS
        WHERE range_id IN
        (SELECT range_id
        FROM
        IGI_EFC_BUDGET_ASSIGNMENT_BCK);

        DELETE FROM GL_BUDGET_ASSIGNMENT_RANGES
        WHERE range_id IN
        (SELECT range_id
        FROM
        IGI_EFC_BUDGET_ASSIGNMENT_BCK);

        DELETE FROM GL_BUDGET_ASSIGNMENTS
        WHERE range_id IN
        (SELECT range_id
        FROM
        IGI_EFC_BUDGET_ASSIGNMENT_BCK);

        EXCEPTION
        WHEN OTHERS THEN
            fnd_file.put_line(fnd_file.output, 'Unexpected Error: Please check the log');
            fnd_file.put_line(fnd_file.log, 'Module: START_EFC_UPGRADE =>'||'Error while deletion =>'||SQLERRM);
            errbuf  := 'Module: START_EFC_UPGRADE =>'||'Error while deletion =>'||SQLERRM;
            retcode := -1;
            RETURN;
        END;

    END IF;

    -- LOOP_AND_PROCESS does the main processing. When run in final mode
    -- a report output is created and all data is inserted into the GL table
    -- provided no error occurs. LOOP_AND_PROCESS when run in preliminary mode
    -- creates a report output only. No commit happens in the preliminary mode
    LOOP_AND_PROCESS(p_data_type,p_mode,l_errbuf,l_retcode);

    -- If LOOP_AND_PROCESS ends in error, initiate a rollback and end the
    -- concurrent request in error.
    IF l_retcode IS NOT NULL AND l_retcode = -1 THEN
        errbuf := l_errbuf;
        retcode := l_retcode;
        fnd_file.put_line(fnd_file.output, 'Unexpected Error: Please check the log');
        fnd_file.put_line(fnd_file.log, 'Module: START_EFC_UPGRADE =>'|| l_errbuf);
        ROLLBACK TO EFC_UPGRADE_START;
        fnd_file.put_line(fnd_file.log, 'Rollback Completed');
    ELSE

        --  If run in final mode, fire GL concurrent request
        --  "Assign Budget Ranges" in order to create assignments for the new
        --  ranges
        IF p_mode = 1 THEN

            FOR i IN 1..budget_entity_tab.COUNT LOOP
                request_id := FND_REQUEST.SUBMIT_REQUEST(
                                      'SQLGL','GLBAAR','','',FALSE,
                                      to_char(budget_entity_tab(i).ledger_id),to_char(budget_entity_tab(i).budget_entity_id),chr(0),
                                      '','','','','','','',
                                      '','','','','','','','','','',
                                      '','','','','','','','','','',
                                      '','','','','','','','','','',
                                      '','','','','','','','','','',
                                      '','','','','','','','','','',
                                      '','','','','','','','','','',
                                      '','','','','','','','','','',
                                      '','','','','','','','','','',
                                      '','','','','','','','','','');
                IF request_id IS NULL or request_id = 0 THEN
                    fnd_file.put_line(fnd_file.output, 'Unable to fire GLBAAR for ledger '
                             ||budget_entity_tab(i).ledger_id||' and Budget Organization '||budget_entity_tab(i).budget_entity_id);
                    fnd_file.put_line(fnd_file.log,'Unable to fire GLBAAR for ledger '
                             ||budget_entity_tab(i).ledger_id||' and Budget Organization '||budget_entity_tab(i).budget_entity_id);
                    errbuf := 'Unable to fire GLBAAR';
                    retcode := -1;
                    ROLLBACK TO EFC_UPGRADE_START;
                    RETURN;
                ELSE
                    fnd_file.put_line(fnd_file.output, 'Fired Concurrent Request '||request_id);
                    fnd_file.put_line(fnd_file.log, 'Fired Concurrent Request '||request_id);
                END IF;
            END LOOP;

            COMMIT;
            fnd_file.put_line(fnd_file.output, 'Process completed successfully in Final Mode');
            fnd_file.put_line(fnd_file.log, 'Process completed successfully in Final Mode');
        ELSE
            ROLLBACK TO EFC_UPGRADE_START;
            fnd_file.put_line(fnd_file.output, 'Process completed successfully in Preliminary Mode');
            fnd_file.put_line(fnd_file.log, 'Process completed successfully in Preliminary Mode');
        END IF;

    END IF;

END START_EFC_UPGRADE;

END IGI_EFC_UPGRADE;

/
