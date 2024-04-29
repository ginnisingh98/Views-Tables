--------------------------------------------------------
--  DDL for Package Body QP_BULK_VALIDATE
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."QP_BULK_VALIDATE" AS
/* $Header: QPXBLVAB.pls 120.62.12010000.7 2009/12/31 08:50:27 dnema ship $ */

/* Begin Bug No. 8854118, shaneed
 * changes
 * procedure dup_line_check - modified completely
 * function get_count - removed
 * function check_dates_for_dupl - removed
 * check_dates_overlap - new function added, similar to check_dates_overlap
 * procedure mark_dup_line  - new fuction, to mark a line is duplict
 */

/* this function check whether the dates of both line overlap
 * return true if there is an overlap, otherwise returns false
 */
FUNCTION CHECK_DATES_OVERLAP(P_REQUEST_ID NUMBER,
                             p_orig_sys_header_ref VARCHAR2,
                             p_orig_sys_line_ref_a VARCHAR2,
                             p_orig_sys_line_ref_b VARCHAR2)
RETURN BOOLEAN
IS
    l_min_date DATE;
    l_max_date DATE;

    l_a_start_date_active DATE;
    l_a_end_date_active DATE;

    l_b_start_date_active DATE;
    l_b_end_date_active DATE;

    l_routine VARCHAR2(230) := 'QP_BULK_VALIDATE.CHECK_DATES_OVERLAP ';

BEGIN
    l_min_date := To_Date('01/01/1900', 'MM/DD/YYYY');
    l_max_date := To_Date('12/31/9999', 'MM/DD/YYYY');

    --fetching dates for first line, that will be in interface table
    BEGIN
        SELECT Nvl(a.start_date_active, l_min_date), Nvl(a.end_date_active, l_max_date)
            INTO l_a_start_date_active, l_a_end_date_active
        FROM qp_interface_list_lines a
        WHERE a.orig_sys_header_ref = p_orig_sys_header_ref
          AND a.orig_sys_line_ref = p_orig_sys_line_ref_a
          AND a.request_id = p_request_id;
    EXCEPTION
        WHEN No_Data_Found
        THEN
            qp_bulk_loader_pub.write_log(l_routine || 'no line in qp_interface_list_lines for ' || p_orig_sys_line_ref_a);
            RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
        WHEN OTHERS
        THEN
            qp_bulk_loader_pub.write_log(l_routine || '#100 Unexpected exception ' || SQLERRM);
            RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    END;

    --fetching dates for second line, that can be either in interface table or setup table
    BEGIN --begin1
        SELECT Nvl(a.start_date_active, l_min_date), Nvl(a.end_date_active, l_max_date)
            INTO l_b_start_date_active, l_b_end_date_active
        FROM qp_interface_list_lines a
        WHERE a.orig_sys_header_ref = p_orig_sys_header_ref
            AND a.orig_sys_line_ref = p_orig_sys_line_ref_b
            AND a.request_id = p_request_id;
    EXCEPTION --begin1
        WHEN No_Data_Found
        THEN
            BEGIN --begin2
                SELECT Nvl(a.start_date_active, l_min_date), Nvl(a.end_date_active, l_max_date)
                    INTO l_b_start_date_active, l_b_end_date_active
                FROM qp_list_lines a
                WHERE a.orig_sys_header_ref = p_orig_sys_header_ref
                AND a.orig_sys_line_ref = p_orig_sys_line_ref_b;
            EXCEPTION --begin2
                WHEN No_Data_Found
                THEN
                    qp_bulk_loader_pub.write_log(l_routine || ' date not found in qp_list_lines and qp_interface_list_lines');
                    RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
            END; --begin2
    END; --begin1

    l_a_start_date_active := Trunc(l_a_start_date_active); --truncate the dates, to remove time part
    l_a_end_date_active := Trunc(l_a_end_date_active);

    l_b_start_date_active := Trunc(l_b_start_date_active);
    l_b_end_date_active := Trunc(l_b_end_date_active);

    /* checking for (S1 between S2 and E2) or (E1 between S2 and E2)
    * that can be simplified as S1 <= E2 and S2 <= E1  -- condition for overlap
    * S1 - start date of first line
    */
    IF l_a_start_date_active <= l_b_end_date_active  --it is the simplified condition
        AND l_b_start_date_active <= l_a_end_date_active
    THEN
        RETURN TRUE; --it overlap
    END IF;

    RETURN FALSE; --no overlap

EXCEPTION
    WHEN OTHERS
    THEN
        qp_bulk_loader_pub.write_log(l_routine || '#200 Unexpected exception ' || SQLERRM);
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
END CHECK_DATES_OVERLAP; --check_dates_overlap;

--mark duplicate line - insert into qp_interface_errors
PROCEDURE mark_dup_line(p_request_id NUMBER,
                        p_orig_sys_header_ref VARCHAR2,
                        p_orig_sys_line_ref VARCHAR2)
IS
    l_msg VARCHAR2(2000);
    l_error_id NUMBER;

    l_routine VARCHAR2(230) := 'MARK_DUP_LINE ';
BEGIN
    UPDATE qp_interface_list_lines
    SET process_status_flag = NULL --process_status_flag = NULL means, line errored out
    WHERE orig_sys_header_ref = p_orig_sys_header_ref
        AND orig_sys_line_ref = p_orig_sys_line_ref
        AND request_id = p_request_id;

    fnd_message.set_name('QP', 'QP_DUPLICATE_LIST_LINES');
    l_msg := fnd_message.Get;

    SELECT qp_interface_errors_s.NEXTVAL
        INTO l_error_id
    FROM dual;

    INSERT INTO qp_interface_errors(error_id, last_update_date, last_updated_by,
        creation_date, created_by, last_update_login, request_id,
        program_application_id, program_id, program_update_date, entity_type,
        table_name, column_name, orig_sys_header_ref, orig_sys_line_ref,
        orig_sys_qualifier_ref, orig_sys_pricing_attr_ref, error_message)
    VALUES(l_error_id, SYSDATE, FND_GLOBAL.USER_ID,
        SYSDATE, FND_GLOBAL.USER_ID, FND_GLOBAL.CONC_LOGIN_ID, p_request_id,
        661, NULL, NULL, 'PRL',
        'QP_INTERFACE_LIST_LINES', NULL, p_orig_sys_header_ref, p_orig_sys_line_ref,
        NULL, NULL, l_msg);

EXCEPTION
    WHEN OTHERS
    THEN
        qp_bulk_loader_pub.write_log(l_routine || 'Unexpected exception ' || SQLERRM);
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
END mark_dup_line;

PROCEDURE dup_line_check(p_request_id NUMBER)
IS
    /* This cursor gives lines which got atleast one
	 * duplicate pricing attibute with another line
     * in qp_interface_pricing_attribs */
    CURSOR c_dup_line_rec IS
        SELECT distinct a_attr.orig_sys_header_ref,
            a_attr.orig_sys_line_ref,      --first line
            b_attr.orig_sys_line_ref       --second line
        FROM qp_interface_pricing_attribs a_attr,
            qp_interface_pricing_attribs b_attr
        WHERE a_attr.request_id = p_request_id
            AND b_attr.request_id =  p_request_id
            AND a_attr.process_status_flag = 'P'
            AND b_attr.process_status_flag = 'P'
            AND a_attr.interface_action_code IN ('INSERT', 'UPDATE') --don't have to consider attributes
            AND b_attr.interface_action_code IN ('INSERT', 'UPDATE') --which are going to be deleted
            AND a_attr.orig_sys_header_ref = b_attr.orig_sys_header_ref --should be in same price list
            AND a_attr.orig_sys_line_ref <> b_attr.orig_sys_line_ref --not same line
            AND a_attr.product_attribute_context = b_attr.product_attribute_context
            AND a_attr.product_attribute = b_attr.product_attribute
            AND a_attr.product_attr_value = b_attr.product_attr_value
            AND Nvl(a_attr.product_uom_code, '*') = Nvl(b_attr.product_uom_code, '*')
            AND (
                    (  --either no pricing attribute or same pricing attribute
                        a_attr.pricing_attribute_context = b_attr.pricing_attribute_context
                        AND a_attr.pricing_attribute = b_attr.pricing_attribute
                        AND nvl(a_attr.pricing_attr_value_from, 0) =
                            nvl(b_attr.pricing_attr_value_from, 0)
                        AND nvl(a_attr.pricing_attr_value_to, 0) =
                            nvl(b_attr.pricing_attr_value_to, 0)
                        AND a_attr.comparison_operator_code = b_attr.comparison_operator_code
                    )
                    OR   --either no pricing attribute or same pricing attribute
                    (
                        a_attr.pricing_attribute_context IS NULL
                        AND b_attr.pricing_attribute_context IS NULL
                        AND a_attr.pricing_attribute IS NULL
                        AND b_attr.pricing_attribute IS NULL
                    )
            )
    ;

    /* Cursor gives line that got atleast one duplicate pricing attribute line
     * in qp_pricing_attributes table */
    CURSOR c_dup_line_rec1 IS
        SELECT DISTINCT a_attr.orig_sys_header_ref,
            a_attr.orig_sys_line_ref,
            b_attr.orig_sys_line_ref
        FROM qp_interface_pricing_attribs a_attr,
            qp_pricing_attributes b_attr
        WHERE a_attr.request_id = p_request_id
            AND a_attr.process_status_flag = 'P'
            AND a_attr.interface_action_code IN ('INSERT', 'UPDATE')
            AND b_attr.orig_sys_header_ref = a_attr.orig_sys_header_ref
            AND b_attr.orig_sys_line_ref <> a_attr.orig_sys_line_ref
            AND b_attr.product_attribute_context = a_attr.product_attribute_context
            AND b_attr.product_attribute = a_attr.product_attribute
            AND b_attr.product_attr_value = a_attr.product_attr_value
            AND Nvl(b_attr.product_uom_code, '*') = Nvl(a_attr.product_uom_code, '*')
            AND NOT EXISTS(  /* should not consider pricing attribute which  */
                SELECT 'X'   /* going to be updated or deleted */
                FROM qp_interface_pricing_attribs c
                WHERE c.request_id = p_request_id
                    AND c.orig_sys_pricing_attr_ref = b_attr.orig_sys_pricing_attr_ref
                    AND c.interface_action_code IN ('UPDATE', 'DELETE')
            )
            AND (  --either no pricing attribute or same pricing attribute
                    (
                        a_attr.pricing_attribute_context = b_attr.pricing_attribute_context
                        AND a_attr.pricing_attribute = b_attr.pricing_attribute
                        AND nvl(a_attr.pricing_attr_value_from, 0) =
                            nvl(b_attr.pricing_attr_value_from, 0)
                        AND nvl(a_attr.pricing_attr_value_to, 0) =
                            nvl(b_attr.pricing_attr_value_to, 0)
                        AND a_attr.comparison_operator_code = b_attr.comparison_operator_code
                    )
                    OR
                    (
                        a_attr.pricing_attribute_context IS NULL
                        AND b_attr.pricing_attribute_context IS NULL
                        AND a_attr.pricing_attribute IS NULL
                        AND b_attr.pricing_attribute IS NULL
                    )
                )
        ;

    /* gives all pricing attribute of a line
     * union b/w qp_interface_pricing_attribs and qp_pricing_attributes
     */
    CURSOR c_pricing_attr(l_orig_sys_line_ref VARCHAR2) IS
    /* take attibute from qp_interface_pricing_attribs */
        SELECT pricing_attribute_context,
        pricing_attribute,
        pricing_attr_value_from,
        pricing_attr_value_to,
        comparison_operator_code
        FROM qp_interface_pricing_attribs
        WHERE request_id = p_request_id
            AND orig_sys_line_ref = l_orig_sys_line_ref
            AND pricing_attribute_context IS NOT NULL
            AND pricing_attribute IS NOT NULL

        UNION /* union with qp_interface_pricing_attribs */

        SELECT pricing_attribute_context,
            pricing_attribute,
            pricing_attr_value_from,
            pricing_attr_value_to,
            comparison_operator_code
        FROM qp_pricing_attributes qpa
        WHERE qpa.orig_sys_line_ref = l_orig_sys_line_ref
            AND qpa.pricing_attribute_context IS NOT NULL
            AND qpa.pricing_attribute IS NOT NULL
            AND NOT EXISTS (  /* do not take an attribute from */
                SELECT 1      /* qp_pricing_attributes if that going to */
			      /*  be updated or deleted */
                FROM qp_interface_pricing_attribs c
                WHERE c.orig_sys_line_ref = l_orig_sys_line_ref
                    AND c.interface_action_code IN ('UPDATE', 'DELETE')
                    AND c.orig_sys_pricing_attr_ref = qpa.orig_sys_pricing_attr_ref
            )
    ;


    TYPE char50_type   IS TABLE OF Varchar2(50)   INDEX BY BINARY_INTEGER;
    TYPE char30_type   IS TABLE OF Varchar2(50)   INDEX BY BINARY_INTEGER;
    TYPE char240_type   IS TABLE OF Varchar2(50)   INDEX BY BINARY_INTEGER;

    TYPE dup_line_type IS RECORD (
        orig_sys_header_ref char50_type,
        a_orig_sys_line_ref char50_type,
        b_orig_sys_line_ref char50_type
    );
    TYPE found_duplicate_type IS TABLE OF varchar2(1) INDEX BY varchar2(50);

    TYPE pa_line_type IS RECORD (
        pricing_attribute_context char30_type,
        pricing_attribute char30_type,
        pricing_attr_value_from char240_type,
        pricing_attr_value_to char240_type,
        comparison_operator_code char30_type
    );

    l_dup_line_rec dup_line_type;
    l_found_duplicate_tbl FOUND_DUPLICATE_TYPE;

    l_a_pa_line_rec PA_LINE_TYPE; --pricing attirbutes of first line
    l_b_pa_line_rec PA_LINE_TYPE; --that of second line

    l_limit NUMBER := 5000; --number of records to be bulk collected

    l_a_pa_count NUMBER;
    l_b_pa_count NUMBER;
    l_pa_count NUMBER;

    l_a_count NUMBER;
    l_b_count NUMBER;

    l_dummy VARCHAR2(2);

    l_routine VARCHAR2(230) := 'DUP_LINE_CHECK ';
BEGIN
    /* First we check for duplicates in qp_interface_pricing_attribs(i_mode = 1)
     * then in qp_pricing_attributes(i_mode = 2) */
    qp_bulk_loader_pub.write_log('In ' || l_routine);
    FOR i_mode IN 1..2
    LOOP
        qp_bulk_loader_pub.write_log('i_mode = ' || i_mode);
        IF i_mode = 1
        THEN
            OPEN c_dup_line_rec;
        ELSE
            OPEN c_dup_line_rec1;
        END IF;

        LOOP	--LOOP_1
            l_dup_line_rec.orig_sys_header_ref.DELETE;
            l_dup_line_rec.a_orig_sys_line_ref.DELETE;
            l_dup_line_rec.b_orig_sys_line_ref.DELETE;

            IF i_mode = 1
            THEN
                FETCH c_dup_line_rec BULK COLLECT
                    INTO l_dup_line_rec.orig_sys_header_ref,
                    l_dup_line_rec.a_orig_sys_line_ref,
                    l_dup_line_rec.b_orig_sys_line_ref
                LIMIT l_limit;

                qp_bulk_loader_pub.write_log('count = ' || l_dup_line_rec.a_orig_sys_line_ref.count);

                EXIT WHEN l_dup_line_rec.a_orig_sys_line_ref.COUNT = 0;
            ELSIF i_mode = 2 --IF i_mode = 1
            THEN
                FETCH c_dup_line_rec1 BULK COLLECT
                    INTO l_dup_line_rec.orig_sys_header_ref,
                    l_dup_line_rec.a_orig_sys_line_ref,
                    l_dup_line_rec.b_orig_sys_line_ref
                LIMIT l_limit;

                qp_bulk_loader_pub.write_log('count = ' || l_dup_line_rec.a_orig_sys_line_ref.count);

                EXIT WHEN l_dup_line_rec.a_orig_sys_line_ref.COUNT = 0;
            END IF; --IF i_mode = 1

            FOR i IN 1..l_dup_line_rec.a_orig_sys_line_ref.Count
            LOOP
                IF l_found_duplicate_tbl.EXISTS(l_dup_line_rec.a_orig_sys_line_ref(i)) --IF3
                THEN
                    qp_bulk_loader_pub.write_log('a = ' || l_dup_line_rec.a_orig_sys_line_ref(i));
                    qp_bulk_loader_pub.write_log('b = ' || l_dup_line_rec.b_orig_sys_line_ref(i));
                    qp_bulk_loader_pub.write_log('already found these are duplicates');
                ELSE --IF3
                    /* do not process price break */
                    IF i_mode = 1 --IF1
                    THEN
                        BEGIN
                            SELECT 'X' INTO l_dummy
                            FROM qp_interface_list_lines
                            WHERE orig_sys_line_ref = l_dup_line_rec.b_orig_sys_line_ref(i)
                                AND price_break_header_ref IS NOT NULL
                                AND rltd_modifier_grp_type = 'PRICE BREAK'; --test this
                        EXCEPTION
                            WHEN OTHERS
                            THEN
                                NULL;
                        END;
                    ELSIF i_mode = 2  --IF1
                    THEN
                        BEGIN
                            SELECT 'X' INTO l_dummy
                            FROM qp_rltd_modifiers qrm,
                                qp_list_lines b
                            WHERE b.orig_sys_header_ref = l_dup_line_rec.orig_sys_header_ref(i)
                                AND b.orig_sys_line_ref = l_dup_line_rec.b_orig_sys_line_ref(i)
                                AND qrm.rltd_modifier_grp_type = 'PRICE BREAK'
                                AND qrm.to_rltd_modifier_id = b.list_line_id;
                        EXCEPTION
                        WHEN OTHERS
                        THEN
                            NULL;
                        END;
                    END IF; --IF1

                    IF l_dummy IS NULL --this code does not process price breaks
                    THEN
                        /* first code checks if there is a date overlap
                         * if no overlap, line is not duplicate
                         * if overlaps, check whether all pricing attributes
                         * got duplicates
                         */
                        IF NOT check_dates_overlap(p_request_id, --if dates do not overlap
                            l_dup_line_rec.orig_sys_header_ref(i),
                            l_dup_line_rec.a_orig_sys_line_ref(i),
                            l_dup_line_rec.b_orig_sys_line_ref(i))
                        THEN
                            NULL; --not duplicates
                        ELSE --date overlap
                            l_a_pa_count := 0;
                            l_b_pa_count := 0;

                            l_a_pa_line_rec.pricing_attribute_context.DELETE;
                            l_a_pa_line_rec.pricing_attribute.DELETE;
                            l_a_pa_line_rec.pricing_attr_value_from.DELETE;
                            l_a_pa_line_rec.pricing_attr_value_to.DELETE;
                            l_a_pa_line_rec.comparison_operator_code.DELETE;

                            /* fetch pricing attribute of first line */
                            OPEN c_pricing_attr(l_dup_line_rec.a_orig_sys_line_ref(i));
                            FETCH c_pricing_attr BULK COLLECT
                            INTO l_a_pa_line_rec.pricing_attribute_context,
                                l_a_pa_line_rec.pricing_attribute,
                                l_a_pa_line_rec.pricing_attr_value_from,
                                l_a_pa_line_rec.pricing_attr_value_to,
                                l_a_pa_line_rec.comparison_operator_code;

                            CLOSE c_pricing_attr;

                            l_b_pa_line_rec.pricing_attribute_context.DELETE;
                            l_b_pa_line_rec.pricing_attribute.DELETE;
                            l_b_pa_line_rec.pricing_attr_value_from.DELETE;
                            l_b_pa_line_rec.pricing_attr_value_to.DELETE;
                            l_b_pa_line_rec.comparison_operator_code.DELETE;

                            /* fetch pricing attributes of second line */
                            OPEN c_pricing_attr(l_dup_line_rec.b_orig_sys_line_ref(i));
                            FETCH c_pricing_attr BULK COLLECT
                            INTO l_b_pa_line_rec.pricing_attribute_context,
                                l_b_pa_line_rec.pricing_attribute,
                                l_b_pa_line_rec.pricing_attr_value_from,
                                l_b_pa_line_rec.pricing_attr_value_to,
                                l_b_pa_line_rec.comparison_operator_code;

                            CLOSE c_pricing_attr;

                            l_a_pa_count := l_a_pa_line_rec.pricing_attribute_context.Count;
                            l_b_pa_count := l_b_pa_line_rec.pricing_attribute_context.Count;

                            /* if both got same number of pricing attibutes
                             * further checking
                             * otherwise it is not a duplicate
                             */
                            IF l_a_pa_count = l_b_pa_count
                            THEN
                                --check if the pricing attributes in both the lines match
                                l_pa_count := l_a_pa_count;
                                FOR j IN 1..l_a_pa_line_rec.pricing_attribute_context.Count --FOR1
                                LOOP
                                    FOR k IN 1..l_b_pa_line_rec.pricing_attribute_context.Count --FOR2
                                    LOOP
                                        IF l_a_pa_line_rec.pricing_attribute_context(j)
                                                = l_b_pa_line_rec.pricing_attribute_context(k)
                                                AND l_a_pa_line_rec.pricing_attribute(j)
                                                = l_b_pa_line_rec.pricing_attribute(k)
                                            AND l_a_pa_line_rec.pricing_attr_value_from(j)
                                                = l_b_pa_line_rec.pricing_attr_value_from(k)
                                            AND Nvl(l_a_pa_line_rec.pricing_attr_value_to(j), '*')
                                                = Nvl(l_b_pa_line_rec.pricing_attr_value_to(k), '*')
                                            AND l_a_pa_line_rec.comparison_operator_code(j)
                                                = l_b_pa_line_rec.comparison_operator_code(k)
                                        THEN
                                            l_pa_count := l_pa_count - 1;
                                            EXIT; --exit loop FOR2
                                        END IF;
                                    END LOOP; --FOR2
                                END LOOP;--FOR1

                                IF l_pa_count = 0 --if all the attributes are same, then duplicates
                                THEN
                                    mark_dup_line(p_request_id,
                                                  l_dup_line_rec.orig_sys_header_ref(i),
                                                  l_dup_line_rec.a_orig_sys_line_ref(i));

                                    --mark it, so we don't have to procss the same line again!!
                                    l_found_duplicate_tbl(l_dup_line_rec.a_orig_sys_line_ref(i)) := 'Y';
                                    qp_bulk_loader_pub.write_log('Found a duplicate b/w '
                                            || l_dup_line_rec.a_orig_sys_line_ref(i) ||
                    						' and ' || l_dup_line_rec.b_orig_sys_line_ref(i));
                                END IF; --IF l_pa_count = 0
                            END IF; --IF l_a_pa_count = l_b_pa_count
                        END IF; --IF3, end if for date overlap check
                    END IF; --IF l_dummy IS NULL
                END IF; --IF l_found_duplicate_tbl.EXISTS(l_dup_line_rec.a_orig_sys_line_ref(i))
            END LOOP; --FOR i IN 1..l_dup_line_rec.a_orig_sys_line_ref.Count
        END LOOP;   --LOOP_1

        IF i_mode = 1
        THEN
            CLOSE c_dup_line_rec;
        ELSE
            CLOSE c_dup_line_rec1;
        END IF;
	END LOOP; --FOR i_mode IN 1..2
    qp_bulk_loader_pub.write_log(l_routine || 'Done, found ' || l_found_duplicate_tbl.COUNT || ' duplicates');
EXCEPTION
    WHEN OTHERS
    THEN
        qp_bulk_loader_pub.write_log(l_routine || 'Unexpected Exception ' || SQLERRM);
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
END dup_line_check; -- dup_line_check
--End Bug No: 8854118, shaneed

FUNCTION GET_FLEX_ENABLED_FLAG(p_flex_name VARCHAR2)
RETURN VARCHAR2
IS
l_count NUMBER;
BEGIN
    SELECT count(*)
    INTO l_count
    FROM fnd_descr_flex_column_usages
    WHERE APPLICATION_ID = 661
    AND DESCRIPTIVE_FLEXFIELD_NAME = p_flex_name
    AND ENABLED_FLAG = 'Y'
    AND ROWNUM = 1;

    IF l_count = 1 THEN
        RETURN 'Y';
    ELSE
        RETURN 'N';
    END IF;
EXCEPTION
    WHEN OTHERS THEN
        RETURN 'N';
END GET_FLEX_ENABLED_FLAG;

FUNCTION Desc_Flex ( p_flex_name IN VARCHAR2 )
RETURN BOOLEAN
IS
   l_count NUMBER := 0;
BEGIN


    qp_bulk_loader_pub.write_log( 'In Desc Flex '||p_flex_name);

    g_context     := NULL;
    g_attribute1  := NULL;
    g_attribute2  := NULL;
    g_attribute3  := NULL;
    g_attribute4  := NULL;
    g_attribute5  := NULL;
    g_attribute6  := NULL;
    g_attribute7  := NULL;
    g_attribute8  := NULL;
    g_attribute9  := NULL;
    g_attribute10 := NULL;
    g_attribute11 := NULL;
    g_attribute12 := NULL;
    g_attribute13 := NULL;
    g_attribute14 := NULL;
    g_attribute15 := NULL;

    IF FND_FLEX_DESCVAL.Validate_Desccols( 'QP', p_flex_name, 'D') THEN


       -- Copying values into global variables
       l_count := fnd_flex_descval.segment_count;
       qp_bulk_loader_pub.write_log( 'segment count='||to_char(l_count));

       FOR i IN 1..l_count LOOP

qp_bulk_loader_pub.write_log( 'segment col nam='||FND_FLEX_DESCVAL.segment_column_name(i));
qp_bulk_loader_pub.write_log( 'segment ID='|| FND_FLEX_DESCVAL.segment_id(i));

          IF FND_FLEX_DESCVAL.segment_column_name(i) = g_context_name THEN
             g_context :=  FND_FLEX_DESCVAL.segment_id(i);
           ELSIF FND_FLEX_DESCVAL.segment_column_name(i) = g_attribute1_name THEN
             g_attribute1 := FND_FLEX_DESCVAL.segment_id(i);
           ELSIF FND_FLEX_DESCVAL.segment_column_name(i) = g_attribute2_name THEN
             g_attribute2 := FND_FLEX_DESCVAL.segment_id(i);
           ELSIF FND_FLEX_DESCVAL.segment_column_name(i) = g_attribute3_name THEN
             g_attribute3 := FND_FLEX_DESCVAL.segment_id(i);
           ELSIF FND_FLEX_DESCVAL.segment_column_name(i) = g_attribute4_name THEN
             g_attribute4 := FND_FLEX_DESCVAL.segment_id(i);
           ELSIF FND_FLEX_DESCVAL.segment_column_name(i) = g_attribute5_name THEN
             g_attribute5 := FND_FLEX_DESCVAL.segment_id(i);
           ELSIF FND_FLEX_DESCVAL.segment_column_name(i) = g_attribute6_name THEN
             g_attribute6 := FND_FLEX_DESCVAL.segment_id(i);
           ELSIF FND_FLEX_DESCVAL.segment_column_name(i) = g_attribute7_name THEN
             g_attribute7 := FND_FLEX_DESCVAL.segment_id(i);
           ELSIF FND_FLEX_DESCVAL.segment_column_name(i) = g_attribute8_name THEN
             g_attribute8 := FND_FLEX_DESCVAL.segment_id(i);
           ELSIF FND_FLEX_DESCVAL.segment_column_name(i) = g_attribute9_name THEN
             g_attribute9 := FND_FLEX_DESCVAL.segment_id(i);
           ELSIF FND_FLEX_DESCVAL.segment_column_name(i) = g_attribute10_name THEN
             g_attribute10 := FND_FLEX_DESCVAL.segment_id(i);
           ELSIF FND_FLEX_DESCVAL.segment_column_name(i) = g_attribute11_name THEN
             g_attribute11 := FND_FLEX_DESCVAL.segment_id(i);
           ELSIF FND_FLEX_DESCVAL.segment_column_name(i) = g_attribute12_name THEN
             g_attribute12 := FND_FLEX_DESCVAL.segment_id(i);
           ELSIF FND_FLEX_DESCVAL.segment_column_name(i) = g_attribute13_name THEN
             g_attribute13 := FND_FLEX_DESCVAL.segment_id(i);
           ELSIF FND_FLEX_DESCVAL.segment_column_name(i) = g_attribute14_name THEN
             g_attribute14 := FND_FLEX_DESCVAL.segment_id(i);
           ELSIF FND_FLEX_DESCVAL.segment_column_name(i) = g_attribute15_name THEN
             g_attribute15 := FND_FLEX_DESCVAL.segment_id(i);
          END IF;
       END LOOP;

       RETURN TRUE;

     ELSE
        --  Prepare the encoded message by setting it on the message
        --  dictionary stack. Then, add it to the API message list.

        FND_MESSAGE.Set_Encoded(FND_FLEX_DESCVAL.Encoded_Error_Message);

        --  Derive return status.

        IF FND_FLEX_DESCVAL.value_error OR
            FND_FLEX_DESCVAL.unsupported_error
        THEN
            --  In case of an expected error return FALSE
	    qp_bulk_loader_pub.write_log( p_flex_name||'Desc Flex value/unsupport error');
            RETURN FALSE;
        ELSE
            --  In case of an unexpected error raise an exception.
	    qp_bulk_loader_pub.write_log( p_flex_name||'Desc Flex unexpected error');
            RETURN FALSE;
        END IF;
    END IF;


    RETURN TRUE;
END Desc_Flex;

FUNCTION Init_Desc_Flex (p_flex_name IN VARCHAR2,
			   p_context IN VARCHAR2,
                           p_attribute1 IN VARCHAR2,
                           p_attribute2 IN VARCHAR2,
                           p_attribute3 IN VARCHAR2,
                           p_attribute4 IN VARCHAR2,
                           p_attribute5 IN VARCHAR2,
                           p_attribute6 IN VARCHAR2,
                           p_attribute7 IN VARCHAR2,
                           p_attribute8 IN VARCHAR2,
                           p_attribute9 IN VARCHAR2,
                           p_attribute10 IN VARCHAR2,
                           p_attribute11 IN VARCHAR2,
                           p_attribute12 IN VARCHAR2,
                           p_attribute13 IN VARCHAR2,
                           p_attribute14 IN VARCHAR2,
                           p_attribute15 IN VARCHAR2)
RETURN BOOLEAN
IS
l_column_value VARCHAR2(240) := null;
BEGIN
      qp_bulk_loader_pub.write_log( 'In Init Desc Flex '||p_flex_name);

	g_context_name := 'CONTEXT';
	g_attribute1_name := 'ATTRIBUTE1';
	g_attribute2_name := 'ATTRIBUTE2';
	g_attribute3_name := 'ATTRIBUTE3';
	g_attribute4_name := 'ATTRIBUTE4';
	g_attribute5_name := 'ATTRIBUTE5';
	g_attribute6_name := 'ATTRIBUTE6';
	g_attribute7_name := 'ATTRIBUTE7';
	g_attribute8_name := 'ATTRIBUTE8';
	g_attribute9_name := 'ATTRIBUTE9';
	g_attribute10_name := 'ATTRIBUTE10';
	g_attribute11_name := 'ATTRIBUTE11';
	g_attribute12_name := 'ATTRIBUTE12';
	g_attribute13_name := 'ATTRIBUTE13';
	g_attribute14_name := 'ATTRIBUTE14';
	g_attribute15_name := 'ATTRIBUTE15';

	  IF p_attribute1 = FND_API.G_MISS_CHAR THEN

	     l_column_value := null;

	  ELSE

	     l_column_value := p_attribute1;
	    qp_bulk_loader_pub.write_log( 'Attribute1='||l_column_value);

	  END IF;

	  FND_FLEX_DESCVAL.Set_Column_Value
	  (   column_name   => 'ATTRIBUTE1'
	   ,  column_value  => l_column_value);

	  IF p_attribute2 = FND_API.G_MISS_CHAR THEN

	     l_column_value := null;

	  ELSE

	     l_column_value := p_attribute2;
	    qp_bulk_loader_pub.write_log( 'Attribute2='||l_column_value);

	  END IF;

	  FND_FLEX_DESCVAL.Set_Column_Value
	  (   column_name   => 'ATTRIBUTE2'
	   ,  column_value  => l_column_value);

	  IF p_attribute3 = FND_API.G_MISS_CHAR THEN

	     l_column_value := null;

	  ELSE

	     l_column_value := p_attribute3;
	    qp_bulk_loader_pub.write_log( 'Attribute3='||l_column_value);

	  END IF;

	  FND_FLEX_DESCVAL.Set_Column_Value
	  (   column_name   => 'ATTRIBUTE3'
	   ,  column_value  => l_column_value);

	  IF p_attribute4 = FND_API.G_MISS_CHAR THEN

	     l_column_value := null;

	  ELSE

	     l_column_value := p_attribute4;
	    qp_bulk_loader_pub.write_log( 'Attribute4='||l_column_value);

	  END IF;

	  FND_FLEX_DESCVAL.Set_Column_Value
	  (   column_name   => 'ATTRIBUTE4'
	   ,  column_value  => l_column_value);

	  IF p_attribute5 = FND_API.G_MISS_CHAR THEN

	     l_column_value := null;

	  ELSE

	     l_column_value := p_attribute5;
	    qp_bulk_loader_pub.write_log( 'Attribute5='||l_column_value);

	  END IF;

	  FND_FLEX_DESCVAL.Set_Column_Value
	  (   column_name   => 'ATTRIBUTE5'
	   ,  column_value  => l_column_value);

	  IF p_attribute6 = FND_API.G_MISS_CHAR THEN

	     l_column_value := null;

	  ELSE

	     l_column_value := p_attribute6;
	    qp_bulk_loader_pub.write_log( 'Attribute6='||l_column_value);

	  END IF;

	  FND_FLEX_DESCVAL.Set_Column_Value
	  (   column_name   => 'ATTRIBUTE6'
	   ,  column_value  => l_column_value);

	  IF p_attribute7 = FND_API.G_MISS_CHAR THEN

	     l_column_value := null;

	  ELSE

	     l_column_value := p_attribute7;
	    qp_bulk_loader_pub.write_log( 'Attribute7='||l_column_value);

	  END IF;

	  FND_FLEX_DESCVAL.Set_Column_Value
	  (   column_name   => 'ATTRIBUTE7'
	   ,  column_value  => l_column_value);

	  IF p_attribute8 = FND_API.G_MISS_CHAR THEN

	     l_column_value := null;

	  ELSE

	     l_column_value := p_attribute8;
	    qp_bulk_loader_pub.write_log( 'Attribute8='||l_column_value);

	  END IF;

	  FND_FLEX_DESCVAL.Set_Column_Value
	  (   column_name   => 'ATTRIBUTE8'
	   ,  column_value  => l_column_value);

	  IF p_attribute9 = FND_API.G_MISS_CHAR THEN

	     l_column_value := null;

	  ELSE

	     l_column_value := p_attribute9;
	    qp_bulk_loader_pub.write_log( 'Attribute9='||l_column_value);

	  END IF;

	  FND_FLEX_DESCVAL.Set_Column_Value
	  (   column_name   => 'ATTRIBUTE9'
	   ,  column_value  => l_column_value);

	  IF p_attribute10 = FND_API.G_MISS_CHAR THEN

	     l_column_value := null;

	  ELSE

	     l_column_value := p_attribute10;
	    qp_bulk_loader_pub.write_log( 'Attribute10='||l_column_value);

	  END IF;

	  FND_FLEX_DESCVAL.Set_Column_Value
	  (   column_name   => 'ATTRIBUTE10'
	   ,  column_value  => l_column_value);

	  IF p_attribute11 = FND_API.G_MISS_CHAR THEN

	     l_column_value := null;

	  ELSE

	     l_column_value := p_attribute11;
	    qp_bulk_loader_pub.write_log( 'Attribute11='||l_column_value);

	  END IF;

	  FND_FLEX_DESCVAL.Set_Column_Value
	  (   column_name   => 'ATTRIBUTE11'
	   ,  column_value  => l_column_value);

	  IF p_attribute12 = FND_API.G_MISS_CHAR THEN

	     l_column_value := null;

	  ELSE

	     l_column_value := p_attribute12;
	    qp_bulk_loader_pub.write_log( 'Attribute12='||l_column_value);

	  END IF;

	  FND_FLEX_DESCVAL.Set_Column_Value
	  (   column_name   => 'ATTRIBUTE12'
	   ,  column_value  => l_column_value);

	  IF p_attribute13 = FND_API.G_MISS_CHAR THEN

	     l_column_value := null;

	  ELSE

	     l_column_value := p_attribute13;
	    qp_bulk_loader_pub.write_log( 'Attribute13='||l_column_value);

	  END IF;

	  FND_FLEX_DESCVAL.Set_Column_Value
	  (   column_name   => 'ATTRIBUTE13'
	   ,  column_value  => l_column_value);

	  IF p_attribute14 = FND_API.G_MISS_CHAR THEN

	     l_column_value := null;

	  ELSE

	     l_column_value := p_attribute14;
	    qp_bulk_loader_pub.write_log( 'Attribute14='||l_column_value);

	  END IF;

	  FND_FLEX_DESCVAL.Set_Column_Value
	  (   column_name   => 'ATTRIBUTE14'
	   ,  column_value  => l_column_value);

	  IF p_attribute15 = FND_API.G_MISS_CHAR THEN

	     l_column_value := null;

	  ELSE

	     l_column_value := p_attribute15;
	    qp_bulk_loader_pub.write_log( 'Attribute15='||l_column_value);

	  END IF;

	  FND_FLEX_DESCVAL.Set_Column_Value
	  (   column_name   => 'ATTRIBUTE15'
	   ,  column_value  => l_column_value);

	  IF p_context = FND_API.G_MISS_CHAR THEN

	     l_column_value := null;

	  ELSE

	     l_column_value := p_context;
	    qp_bulk_loader_pub.write_log( 'Context='||l_column_value);

	  END IF;
	  FND_FLEX_DESCVAL.Set_Context_Value
	   ( context_value   => l_column_value);

	 IF NOT Desc_Flex(p_flex_name) THEN
		RETURN FALSE;
	 END IF;
	RETURN TRUE;
END;

PROCEDURE ENTITY_HEADER
          (p_header_rec IN OUT NOCOPY QP_BULK_LOADER_PUB.HEADER_REC_TYPE)

IS
l_msg_rec QP_BULK_MSG.Msg_Rec_Type;
l_old_PRICE_LIST_rec  QP_Price_List_PUB.Price_List_Rec_Type;
l_dummy                       VARCHAR2(10);
l_unit_precision_type varchar2(255) ;
l_precision number := NULL;
l_extended_precision number := NULL;
l_price_rounding   VARCHAR2(50);
l_list_header_id NUMBER;
l_exist NUMBER;
l_start_date_active VARCHAR2(30);
l_qp_pte VARCHAR2(50);
l_qp_source_system_code VARCHAR2(50);

l_header_flex_enabled VARCHAR2(1);
l_security_profile VARCHAR2(1);
l_header_id_null VARCHAR2(1);   --bug 6961376

-- Bug 4904393 START RAVI
/**
Local variables to store the hdr interface dates in date format.
**/
l_start_date DATE;
l_end_date DATE;
-- Bug 4904393 END RAVI

-- Bug 5414062 START RAVI
l_first_date_hash VARCHAR2(1);
l_second_date_hash VARCHAR2(1);
l_date_length NUMBER;
-- Bug 5414062 END RAVI

BEGIN
   qp_bulk_loader_pub.write_log('Entering Entity_header validation');

   select fnd_date.date_to_canonical(TRUNC(SYSDATE))
   into	  l_start_date_active
   from DUAL;

    l_qp_pte := FND_PROFILE.VALUE('QP_PRICING_TRANSACTION_ENTITY');
    l_qp_source_system_code := FND_PROFILE.VALUE('QP_SOURCE_SYSTEM_CODE');

   l_header_flex_enabled := get_flex_enabled_flag('QP_LIST_HEADERS');
   qp_bulk_loader_pub.write_log('Flex enabled '||l_header_flex_enabled);

FOR I IN 1..p_header_rec.orig_sys_header_ref.COUNT
LOOP

--Initially setting the message context.

l_msg_rec.REQUEST_ID := P_HEADER_REC.REQUEST_ID(I);
l_msg_rec.ENTITY_TYPE :='PRL';
l_msg_rec.TABLE_NAME :='QP_INTERFACE_LIST_HEADERS';
l_msg_rec.ORIG_SYS_HEADER_REF := nvl(p_header_rec.orig_sys_header_ref(I),p_header_rec.list_header_id(I));
l_msg_rec.LIST_HEADER_ID := p_header_rec.list_header_id(I);
l_msg_rec.ORIG_SYS_LINE_REF := NULL;
l_msg_rec.ORIG_SYS_QUALIFIER_REF := NULL;
l_msg_rec.ORIG_SYS_PRICING_ATTR_REF := NULL;

  -- Populating internal fields --

  IF p_header_rec.interface_action_code(I) = 'INSERT' THEN
      Select qp_list_headers_b_s.nextval
	into p_header_rec.list_header_id(I)
	from dual;
  END IF;

  p_header_rec.version_no(I) := '1';
  p_header_rec.automatic_flag(I) := 'Y';
  p_header_rec.discount_lines_flag(I) := 'N';
  if p_header_rec.active_flag(I) is NULL then
	p_header_rec.active_flag(I) := 'Y';
  end if;
  if p_header_rec.mobile_download(I) is NULL then
	p_header_rec.mobile_download(I) := 'N';
  end if;
  if p_header_rec.global_flag(I) is NULL then
	p_header_rec.global_flag(I) := 'Y';
  end if;
--source_system_code
    IF p_header_rec.source_system_code(I) IS NULL
    THEN
       p_header_rec.source_system_code(I) := l_qp_source_system_code;
        if p_header_rec.source_system_code(I) is NULL then
           p_header_rec.source_system_code(I) := 'QP';
        end if;
    END IF;
--pte_code
    IF p_header_rec.pte_code(I) IS NULL
    THEN
       p_header_rec.pte_code(I) := l_qp_pte;
        if p_header_rec.pte_code(I) is NULL then
           p_header_rec.pte_code(I) := 'ORDFUL';
        end if;
    END IF;

/*------------ Performing required field validation for ----------------------*/

    --orig_sys_header_ref,
  IF p_header_rec.interface_action_code(I) = 'INSERT' THEN
    IF p_header_rec.orig_sys_header_ref(I) IS NULL
    THEN

       p_header_rec.process_status_flag(I):=NULL; --'E';

       FND_MESSAGE.SET_NAME('QP','QP_ATTRIBUTE_REQUIRED');
       FND_MESSAGE.SET_TOKEN('ATTRIBUTE','ORIG_SYS_HEADER_ID');
       QP_BULK_MSG.ADD(l_msg_rec);

    END IF;
  END IF;

    --List_type_code

    IF p_header_rec.list_type_code(I) IS NULL
    THEN
       p_header_rec.list_type_code(I):= '1';
       P_header_rec.process_status_flag(I):=NULL; --'E';

       FND_MESSAGE.SET_NAME('QP','QP_ATTRIBUTE_REQUIRED');
       FND_MESSAGE.SET_TOKEN('ATTRIBUTE','LIST_TYPE_CODE');
       QP_BULK_MSG.ADD(l_msg_rec);

    END IF;

    --currency_code
    IF p_header_rec.currency_code(I) IS NULL
    THEN
       p_header_rec.currency_code(I) := '1';
       P_header_rec.process_status_flag(I):=NULL; --'E';

       FND_MESSAGE.SET_NAME('QP','QP_ATTRIBUTE_REQUIRED');
       FND_MESSAGE.SET_TOKEN('ATTRIBUTE','CURRENCY_CODE');
       QP_BULK_MSG.ADD(l_msg_rec);
       qp_bulk_loader_pub.write_log('Currency Validation failed');

    END IF;

    --Name
    IF p_header_rec.name(I) IS NULL
    THEN
       p_header_rec.name(I) := '1';
       p_header_rec.process_status_flag(I):=NULL; --'E';

       FND_MESSAGE.SET_NAME('QP','QP_ATTRIBUTE_REQUIRED');
       FND_MESSAGE.SET_TOKEN('ATTRIBUTE','NAME');
       QP_BULK_MSG.ADD(l_msg_rec);

    END IF;

    --Rounding_factor
    IF p_header_rec.rounding_factor(I) IS NULL
    THEN
       p_header_rec.rounding_factor(I):= -1;
       P_header_rec.process_status_flag(I):=NULL;

       FND_MESSAGE.SET_NAME('QP','QP_ATTRIBUTE_REQUIRED');
       FND_MESSAGE.SET_TOKEN('ATTRIBUTE','ROUNDING_FACTOR');
       QP_BULK_MSG.ADD(l_msg_rec);

    END IF;

  IF p_header_rec.interface_action_code(I) = 'INSERT' THEN
    -- Language
    IF p_header_rec.language(I) IS NULL
    THEN
       p_header_rec.language(I):= '1';
       P_header_rec.process_status_flag(I):=NULL;

       FND_MESSAGE.SET_NAME('QP','QP_ATTRIBUTE_REQUIRED');
       FND_MESSAGE.SET_TOKEN('ATTRIBUTE','LANGUAGE');
       QP_BULK_MSG.ADD(l_msg_rec);

    END IF;

    -- Source Language
    IF p_header_rec.source_lang(I) IS NULL
    THEN
       p_header_rec.source_lang(I):= '1';
       p_header_rec.process_status_flag(I):=NULL;

       FND_MESSAGE.SET_NAME('QP','QP_ATTRIBUTE_REQUIRED');
       FND_MESSAGE.SET_TOKEN('ATTRIBUTE','SOURCE_LANG');
       QP_BULK_MSG.ADD(l_msg_rec);

    END IF;
  END IF;

    --curency_header_id (conditionally required)
    If NVL(fnd_profile.value('QP_MULTI_CURRENCY_INSTALLED'), 'N') = 'Y'
    AND p_header_rec.currency_header_id(I) IS NULL
    THEN

       p_header_rec.process_status_flag(I):=NULL;
       FND_MESSAGE.SET_NAME('QP','QP_MUL_CURR_REQD');
       QP_BULK_MSG.ADD(l_msg_rec);

    END IF;


    -- Effective Date Check

    -- Bug 4904393 START RAVI (5138015,5207598,5207612,5414062)
    /**
    The date entered in the interface headers should be in the canonical format
    YYYY/MM/DD format or an error should be thrown
    **/
    IF p_header_rec.start_date_active(I) is not null THEN

       l_first_date_hash := null;
       l_second_date_hash := null;
       l_date_length := null;

       begin
          select substr(p_header_rec.start_date_active(I),5,1)
          into l_first_date_hash from dual;
          select substr(p_header_rec.start_date_active(I),8,1)
          into l_second_date_hash from dual;
          select length(p_header_rec.start_date_active(I))
          into l_date_length from dual;

          IF l_date_length<>10 or l_first_date_hash<>'/' or l_second_date_hash<>'/'
          THEN
             p_header_rec.process_status_flag(I):=NULL;
             FND_MESSAGE.SET_NAME('QP', 'QP_INVALID_DATE');
             QP_BULK_MSG.Add(l_msg_rec);
          END IF;

          l_start_date := to_date(p_header_rec.start_date_active(I),'YYYY/MM/DD');
       exception
       when others then
             p_header_rec.process_status_flag(I):=NULL;
             FND_MESSAGE.SET_NAME('QP', 'QP_INVALID_DATE');
             QP_BULK_MSG.Add(l_msg_rec);
       end;
    END IF;

    IF p_header_rec.end_date_active(I) is not null THEN

       l_first_date_hash := null;
       l_second_date_hash := null;
       l_date_length := null;

       begin
          select substr(p_header_rec.end_date_active(I),5,1)
          into l_first_date_hash from dual;
          select substr(p_header_rec.end_date_active(I),8,1)
          into l_second_date_hash from dual;
          select length(p_header_rec.end_date_active(I))
          into l_date_length from dual;

          IF l_date_length<>10 or l_first_date_hash<>'/' or l_second_date_hash<>'/'
          THEN
             p_header_rec.process_status_flag(I):=NULL;
             FND_MESSAGE.SET_NAME('QP', 'QP_INVALID_DATE');
             QP_BULK_MSG.Add(l_msg_rec);
          END IF;

          l_end_date := to_date(p_header_rec.end_date_active(I),'YYYY/MM/DD');
       exception
       when others then
             p_header_rec.process_status_flag(I):=NULL;
             FND_MESSAGE.SET_NAME('QP', 'QP_INVALID_DATE');
             QP_BULK_MSG.Add(l_msg_rec);
       end;
    END IF;
    -- Bug 4904393 END RAVI (5138015,5207598,5207612,5414062)

    -- Bug 4929691 START RAVI (5207598,5207612)
    /**
    If start date is null set it to sysdate and then check if it's greater
    than end date. If it is throw an error and set the process status to null
    **/
    IF l_end_date IS NOT NULL
    AND l_start_date IS NOT NULL
    THEN
       IF l_start_date > l_end_date THEN
          p_header_rec.process_status_flag(I):=NULL;
          FND_MESSAGE.SET_NAME('QP', 'QP_STRT_DATE_BFR_END_DATE');
	      QP_BULK_MSG.Add(l_msg_rec);
       END IF;
    END IF;
    -- Bug 4929691 END RAVI (5207598,5207612)

    -- Rounding factor value check
      l_unit_precision_type :=  FND_PROFILE.VALUE('QP_UNIT_PRICE_PRECISION_TYPE');
      l_price_rounding := fnd_profile.value('QP_PRICE_ROUNDING');

	IF p_header_rec.currency_code(I) is not null THEN
                      BEGIN
                      	SELECT -1*PRECISION, -1*EXTENDED_PRECISION
             		INTO   l_precision, l_extended_precision
			FROM   FND_CURRENCIES
			WHERE  CURRENCY_CODE = P_header_rec.CURRENCY_CODE(I);
                     EXCEPTION
                               WHEN NO_DATA_FOUND THEN
       				 p_header_rec.process_status_flag(I):=NULL;
                                 FND_MESSAGE.SET_NAME('QP','QP_INVALID_ATTRIBUTE');
                                 FND_MESSAGE.SET_TOKEN('ATTRIBUTE','rounding_factor');
                                 qp_bulk_msg.add(l_msg_rec);
                     END;
                     END IF;

        IF p_header_rec.rounding_factor(I) IS  NOT NULL
        THEN

        IF l_unit_precision_type = 'STANDARD' THEN

	   IF l_price_rounding = 'PRECISION' THEN
	       IF p_header_rec.rounding_factor(I) <> l_precision THEN
       		      p_header_rec.process_status_flag(I):=NULL;
                      FND_MESSAGE.SET_NAME('QP', 'QP_ROUNDING_FACTOR_NO_UPDATE');
                     qp_bulk_msg.add(l_msg_rec);
               END IF;
           END IF;

           IF (p_header_rec.rounding_factor(I))
		 < nvl((l_precision), (p_header_rec.rounding_factor(I))) THEN
       		          p_header_rec.process_status_flag(I):=NULL;
			  FND_MESSAGE.SET_NAME('QP', 'OE_PRL_INVALID_ROUNDING_FACTOR');
                          FND_MESSAGE.SET_TOKEN('PRECISION', l_precision);
                          qp_bulk_msg.add(l_msg_rec);
           END IF;

       ELSE
           IF l_price_rounding = 'PRECISION' THEN
                   IF p_header_rec.rounding_factor(I) <> l_extended_precision THEN
       		      p_header_rec.process_status_flag(I):=NULL;
                      FND_MESSAGE.SET_NAME('QP', 'QP_ROUNDING_FACTOR_NO_UPDATE');
 		      qp_bulk_msg.add(l_msg_rec);
                   END IF;
           END IF;

           IF (p_header_rec.rounding_factor(I))
		      < nvl((l_extended_precision),(p_header_rec.rounding_factor(I))) THEN
       		p_header_rec.process_status_flag(I):=NULL;
 	        FND_MESSAGE.SET_NAME('QP', 'OE_PRL_INVALID_ROUNDING_FACTOR');
                FND_MESSAGE.SET_TOKEN('PRECISION', l_extended_precision);
                qp_bulk_msg.add(l_msg_rec);
            END IF;
       END IF;

     END IF;
-- end rounding_factor

/*-------checking for the value of the flags ----------------------------
--active_flag
--automatic_flag
--mobile_download
--global_flag
-------------------------------------------------------------------------*/

    IF ( p_header_rec.active_flag(I) IS NOT NULL)
    THEN
		IF p_header_rec.active_flag(I) NOT IN ('Y', 'N', 'y', 'n')
		THEN
                  p_header_rec.process_status_flag(I):=NULL;
		  FND_MESSAGE.SET_NAME('QP','QP_INVALID_ATTRIBUTE');
		  FND_MESSAGE.SET_TOKEN('ATTRIBUTE','active_flag');
                  qp_bulk_msg.add(l_msg_rec);
        	END IF;
    END IF;

    IF ( p_header_rec.automatic_flag(I) IS NOT NULL)
    THEN
		IF p_header_rec.automatic_flag(I) NOT IN ('Y', 'N', 'y', 'n')
		THEN
                  p_header_rec.process_status_flag(I):=NULL;
		  FND_MESSAGE.SET_NAME('QP','QP_INVALID_ATTRIBUTE');
		  FND_MESSAGE.SET_TOKEN('ATTRIBUTE','automatic_flag');
		  qp_bulk_msg.add(l_msg_rec);
        	END IF;
    END IF;

		IF p_header_rec.global_flag(I) NOT IN ('Y', 'N', 'n')
		THEN
                  p_header_rec.process_status_flag(I):=NULL;
		  FND_MESSAGE.SET_NAME('QP','QP_INVALID_ATTRIBUTE');
		  FND_MESSAGE.SET_TOKEN('ATTRIBUTE','global_flag');
 		  qp_bulk_msg.add(l_msg_rec);
        	END IF;

    --added for MOAC
    l_security_profile := QP_SECURITY.security_on;

    IF ( p_header_rec.global_flag(I) IS NOT NULL)
    THEN

                --if security is OFF, global_flag cannot be 'N'
                IF (l_security_profile = 'N'
                and p_header_rec.global_flag(I) in ('N', 'n')) THEN
                  p_header_rec.process_status_flag(I):=NULL;
		  FND_MESSAGE.SET_NAME('QP','QP_INVALID_ATTRIBUTE');
		  FND_MESSAGE.SET_TOKEN('ATTRIBUTE','global_flag');
		  qp_bulk_msg.add(l_msg_rec);
        	END IF;

                IF l_security_profile = 'Y' THEN
                  --if security is ON and global_flag is 'N', orig_org_id cannot be null
                  IF (p_header_rec.global_flag(I) in ('N', 'n')
                  -- Bug 4947191 RAVI
                  /**
                  if security is ON and global_flag is 'N', orig_org_id cannot be null
                  **/
                  and p_header_rec.orig_org_id(I) is null) THEN
                    p_header_rec.process_status_flag(I):=NULL;
		    FND_MESSAGE.SET_NAME('QP','QP_ATTRIBUTE_REQUIRED');
                    FND_MESSAGE.SET_TOKEN('ATTRIBUTE','ORIG_ORG_ID');
		    qp_bulk_msg.add(l_msg_rec);

                  END IF;

/* for bug 4731613 moved this validation to attribute_header procedure
                  --if orig_org_id is not null and it is not a valid org
                  IF (p_header_rec.orig_org_id(I) is not null
                  and QP_UTIL.validate_org_id(p_header_rec.orig_org_id(I)) = 'N') THEN
                    p_header_rec.process_status_flag(I):=NULL;
                    FND_MESSAGE.SET_NAME('FND','FND_MO_ORG_INVALID');
--		    FND_MESSAGE.SET_TOKEN('ATTRIBUTE','orig_org_id');
		    qp_bulk_msg.add(l_msg_rec);
                  END IF;
*/
                END IF;--IF l_security_profile = 'Y'

                --global_flag 'Y', org_id not null combination is invalid
                IF ((p_header_rec.global_flag(I) = 'Y'
                and p_header_rec.orig_org_id(I) is not null) OR (p_header_rec.global_flag(I) = 'N' and p_header_rec.orig_org_id(I) is null)) THEN
                  p_header_rec.process_status_flag(I):=NULL;
                  FND_MESSAGE.SET_NAME('QP', 'QP_GLOBAL_OU_VALIDATION');
                  qp_bulk_msg.add(l_msg_rec);
                END IF;--p_header_rec.global_flag
    END IF;
    --end validations for moac

        IF ( p_header_rec.mobile_download(I) IS NOT NULL)
    THEN
		IF p_header_rec.mobile_download(I) NOT IN ('Y', 'N', 'y', 'n')
		THEN
                  p_header_rec.process_status_flag(I):=NULL;
		  FND_MESSAGE.SET_NAME('QP','QP_INVALID_ATTRIBUTE');
		  FND_MESSAGE.SET_TOKEN('ATTRIBUTE','mobile_download');
		  qp_bulk_msg.add(l_msg_rec);
        	END IF;
    END IF;

--Checking for uniqueness of the Name in qp_list_headers.
    l_exist:=null;
    Begin
      Select 1 into l_exist
      from qp_list_headers_tl
      where name= p_header_rec.name(I)
      and list_header_id <>
          (select list_header_id From qp_list_headers_b
           -- ENH unod alcoa changes RAVI
           /**
           The key between interface and qp tables is only orig_sys_hdr_ref
           (not list_header_id)
           **/
           where orig_system_header_ref =p_header_rec.orig_sys_header_ref(I)
           and nvl(list_source_code,'*') =nvl(p_header_rec.list_source_code(I),'*')
           )
       and language = userenv('LANG');

    Exception
       When no_data_found then
	  l_exist := 0;
    End;

    If l_exist = 1  THEN
       p_header_rec.process_status_flag(I):=NULL;
       fnd_message.set_name('QP', 'SO_OTHER_NAME_ALREADY_IN_USE');
       qp_bulk_msg.add(l_msg_rec);
    END IF;

     l_exist := NULL;

   IF p_header_rec.interface_action_code(I) = 'INSERT' THEN
     Select count(*) into l_exist
       from qp_interface_list_headers
      where request_id = p_header_rec.request_id(I)
	and name = p_header_rec.name(I)
	and orig_sys_header_ref <> p_header_rec.orig_sys_header_ref(I)
        and process_status_flag = 'P'; --is null;

     IF  l_exist >0 THEN
	 p_header_rec.process_status_flag(I):=NULL;
	 fnd_message.set_name('QP', 'SO_OTHER_NAME_ALREADY_IN_USE');
         qp_bulk_msg.add(l_msg_rec);
    END IF;
  END IF;

--Checking for uniqueness of orig_sys_header_ref in qp_list_headers
--and qp_interface_list_headers

    l_exist := NULL;

   BEGIN
     select 1, list_header_id into l_exist, l_list_header_id
     from qp_list_headers_b
     -- ENH unod alcoa changes START RAVI
     /**
     The key between interface and qp tables is only orig_sys_hdr_ref
     (not list_header_id)
     **/
     where orig_system_header_ref = p_header_rec.orig_sys_header_ref(I)
    and nvl(list_source_code,'*') =nvl(p_header_rec.list_source_code(I),'*');
   EXCEPTION
      	When no_data_found then
	   l_exist := 0;
     END;

     IF p_header_rec.interface_action_code(I) = 'INSERT' AND l_exist =1 THEN
	p_header_rec.process_status_flag(I):=NULL;
	fnd_message.set_name('QP', 'ORIG_SYS_HEADER_REF_NOT_UNIQUE');
        FND_MESSAGE.SET_TOKEN('REF_NO', p_header_rec.orig_sys_header_ref(I));
        FND_MESSAGE.SET_TOKEN('LS_CODE', p_header_rec.list_source_code(I));
        qp_bulk_msg.add(l_msg_rec);
     ELSIF p_header_rec.interface_action_code(I) = 'UPDATE' AND l_exist =0 THEN
	p_header_rec.process_status_flag(I):=NULL;
	fnd_message.set_name('QP', 'HEADER_RECORD_DOES_NOT_EXIST');
        FND_MESSAGE.SET_TOKEN('REF_NO', p_header_rec.orig_sys_header_ref(I));
        FND_MESSAGE.SET_TOKEN('LS_CODE', p_header_rec.list_source_code(I));
        qp_bulk_msg.add(l_msg_rec);
    END IF;

    --bug 6961376 start

    IF  p_header_rec.list_header_id(I) IS NULL THEN
        l_header_id_null := 'Y';
    ELSE
        l_header_id_null := 'N';
    END IF;
    qp_bulk_loader_pub.write_log('Is Header Id null: ' || l_header_id_null);


    IF p_header_rec.interface_action_code(I) = 'UPDATE'
	AND p_header_rec.list_header_id(I) IS NULL
	AND l_exist =1 THEN
	p_header_rec.list_header_id(I):=l_list_header_id;
    END IF;

    l_exist:= NULL;

     IF p_header_rec.interface_action_code(I) = 'INSERT' THEN
      select count(*) into l_exist
        from qp_interface_list_headers
       where request_id =p_header_rec.request_id(I)
         and (list_header_id = p_header_rec.list_header_id(I) or
              orig_sys_header_ref = p_header_rec.orig_sys_header_ref(I))
        and nvl(list_source_code,'*') =nvl(p_header_rec.list_source_code(I),'*');

       IF l_exist >1 THEN
          qp_bulk_loader_pub.write_log('Entity Header l_exist of orig is: '||l_exist);
	  p_header_rec.process_status_flag(I):=NULL;
	  fnd_message.set_name('QP','ORIG_SYS_HEADER_REF_NOT_UNIQUE');
          FND_MESSAGE.SET_TOKEN('REF_NO', p_header_rec.orig_sys_header_ref(I));
          FND_MESSAGE.SET_TOKEN('LS_CODE', p_header_rec.list_source_code(I));
          qp_bulk_msg.add(l_msg_rec);
       END IF;
     ELSIF p_header_rec.interface_action_code(I) = 'UPDATE' AND l_header_id_null = 'N' THEN
        qp_bulk_loader_pub.write_log('checking for unique orig_sys_header_ref: ' || p_header_rec.orig_sys_header_ref(I));
          select count(distinct list_header_id) into l_exist
             from qp_interface_list_headers
          where  request_id =p_header_rec.request_id(I)
	      and orig_sys_header_ref = p_header_rec.orig_sys_header_ref(I)
              and nvl(list_source_code,'*') =nvl(p_header_rec.list_source_code(I),'*');
/* 1749 to 1764 commented to for the bug number 6961376 as the bug 3604226 and bug 6961376  are raised for the same problem and the fix for the
bug 6961376 is giving better result than the bug 3604226 we commented these lines and incorporated the new code */

   /*   select count(*) into l_exist
        from qp_interface_list_headers
       where request_id =p_header_rec.request_id(I)
         -- Bug 3604226 RAVI
         /**
         Multiple headers for insert or delete action with same orig_sys_hdr_ref
         are not allowed
         **/
     --    and p_header_rec.interface_action_code(I) <> 'UPDATE'
         -- ENH undo alcoa changes RAVI
         /**
         The key between interface and qp tables is only orig_sys_hdr_ref
         (not list_header_id)
         **/
      --   and orig_sys_header_ref = p_header_rec.orig_sys_header_ref(I)
      --  and nvl(list_source_code,'*') =nvl(p_header_rec.list_source_code(I),'*'); */


    IF l_exist >1 THEN
       qp_bulk_loader_pub.write_log('Entity Header l_exist of orig is: '||l_exist);
	p_header_rec.process_status_flag(I):=NULL;
	fnd_message.set_name('QP','ORIG_SYS_HEADER_REF_NOT_UNIQUE');
        FND_MESSAGE.SET_TOKEN('REF_NO', p_header_rec.orig_sys_header_ref(I));
        FND_MESSAGE.SET_TOKEN('LS_CODE', p_header_rec.list_source_code(I));
        qp_bulk_msg.add(l_msg_rec);
    END IF;
   END IF;
   --bug 6961376 end

--QP_Security_check
  IF p_header_rec.interface_action_code(I) = 'UPDATE' THEN
 qp_bulk_loader_pub.write_log('Secu. Check list_header_id: '||to_char(p_header_rec.list_header_id(I)));
     IF QP_security.check_function( p_function_name => QP_Security.G_FUNCTION_UPDATE,
                                 p_instance_type => QP_Security.G_PRICELIST_OBJECT,
                                 p_instance_pk1  => p_header_rec.list_header_id(I)) <> 'T' THEN
	p_header_rec.process_status_flag(I):=NULL;
        fnd_message.set_name('QP', 'QP_NO_PRIVILEGE');
        fnd_message.set_token('PRICING_OBJECT', 'Price List');
        qp_bulk_msg.add(l_msg_rec);
     END IF;
  END IF;

--Defaulting
-- Basic_Pricing_Condition
    IF (QP_BULK_LOADER_PUB.GET_QP_STATUS <> 'I' OR
	   FND_PROFILE.VALUE('QP_MULTI_CURRENCY_INSTALLED') = 'N')
	AND p_header_rec.currency_header_id(I) IS NOT NULL THEN
    -- No multi currency in Basic Pricing
       p_header_rec.currency_header_id(I) := NULL;
    END IF;

--Flex field check

    IF l_header_flex_enabled = 'Y' THEN
      qp_bulk_loader_pub.write_log( 'Header Flex enabled ');

         IF NOT Init_Desc_Flex
               (p_flex_name	     =>'QP_LIST_HEADERS'
	       ,p_context            => p_header_rec.context(i)
               ,p_attribute1         => p_header_rec.attribute1(i)
               ,p_attribute2         => p_header_rec.attribute2(i)
               ,p_attribute3         => p_header_rec.attribute3(i)
               ,p_attribute4         => p_header_rec.attribute4(i)
               ,p_attribute5         => p_header_rec.attribute5(i)
               ,p_attribute6         => p_header_rec.attribute6(i)
               ,p_attribute7         => p_header_rec.attribute7(i)
               ,p_attribute8         => p_header_rec.attribute8(i)
               ,p_attribute9         => p_header_rec.attribute9(i)
               ,p_attribute10        => p_header_rec.attribute10(i)
               ,p_attribute11        => p_header_rec.attribute11(i)
               ,p_attribute12        => p_header_rec.attribute12(i)
               ,p_attribute13        => p_header_rec.attribute13(i)
               ,p_attribute14        => p_header_rec.attribute14(i)
               ,p_attribute15        => p_header_rec.attribute15(i)) THEN

	         QP_BULK_MSG.ADD(l_msg_rec);

                 -- Log Error Message
                 FND_MESSAGE.SET_NAME('QP','QP_INVALID_ATTRIBUTE');
                 FND_MESSAGE.SET_TOKEN('ATTRIBUTE',
                                       'Entity:Flexfield:Header_Desc_Flex');
	         P_header_rec.process_status_flag(I):=NULL;

	         QP_BULK_MSG.ADD(l_msg_rec);

          ELSE -- if the flex validation is successfull

            IF p_header_rec.context(i) IS NULL
              OR p_header_rec.context(i) = FND_API.G_MISS_CHAR THEN
               p_header_rec.context(i)    := g_context;
            END IF;

            IF p_header_rec.attribute1(i) IS NULL
              OR p_header_rec.attribute1(i) = FND_API.G_MISS_CHAR THEN
               p_header_rec.attribute1(i) := g_attribute1;
            END IF;

            IF p_header_rec.attribute2(i) IS NULL
              OR p_header_rec.attribute2(i) = FND_API.G_MISS_CHAR THEN
               p_header_rec.attribute2(i) := g_attribute2;
            END IF;

            IF p_header_rec.attribute3(i) IS NULL
              OR p_header_rec.attribute3(i) = FND_API.G_MISS_CHAR THEN
               p_header_rec.attribute3(i) := g_attribute3;
            END IF;

            IF p_header_rec.attribute4(i) IS NULL
              OR p_header_rec.attribute4(i) = FND_API.G_MISS_CHAR THEN
               p_header_rec.attribute4(i) := g_attribute4;
            END IF;

            IF p_header_rec.attribute5(i) IS NULL
              OR p_header_rec.attribute5(i) = FND_API.G_MISS_CHAR THEN
               p_header_rec.attribute5(i) := g_attribute5;
            END IF;

            IF p_header_rec.attribute6(i) IS NULL
              OR p_header_rec.attribute6(i) = FND_API.G_MISS_CHAR THEN
               p_header_rec.attribute6(i) := g_attribute6;
            END IF;
            IF p_header_rec.attribute7(i) IS NULL
              OR p_header_rec.attribute7(i) = FND_API.G_MISS_CHAR THEN
               p_header_rec.attribute7(i) := g_attribute7;
            END IF;

            IF p_header_rec.attribute8(i) IS NULL
              OR p_header_rec.attribute8(i) = FND_API.G_MISS_CHAR THEN
               p_header_rec.attribute8(i) := g_attribute8;
            END IF;

            IF p_header_rec.attribute9(i) IS NULL
              OR p_header_rec.attribute9(i) = FND_API.G_MISS_CHAR THEN
               p_header_rec.attribute9(i) := g_attribute9;
            END IF;

            IF p_header_rec.attribute10(i) IS NULL
              OR p_header_rec.attribute10(i) = FND_API.G_MISS_CHAR THEN
               p_header_rec.attribute10(i) := G_attribute10;
            End IF;

            IF p_header_rec.attribute11(i) IS NULL
              OR p_header_rec.attribute11(i) = FND_API.G_MISS_CHAR THEN
               p_header_rec.attribute11(i) := g_attribute11;
            END IF;

            IF p_header_rec.attribute12(i) IS NULL
              OR p_header_rec.attribute12(i) = FND_API.G_MISS_CHAR THEN
               p_header_rec.attribute12(i) := g_attribute12;
            END IF;

            IF p_header_rec.attribute13(i) IS NULL
              OR p_header_rec.attribute13(i) = FND_API.G_MISS_CHAR THEN
               p_header_rec.attribute13(i) := g_attribute13;
            END IF;

            IF p_header_rec.attribute14(i) IS NULL
              OR p_header_rec.attribute14(i) = FND_API.G_MISS_CHAR THEN
               p_header_rec.attribute14(i) := g_attribute14;
            END IF;

            IF p_header_rec.attribute15(i) IS NULL
              OR p_header_rec.attribute15(i) = FND_API.G_MISS_CHAR THEN
               p_header_rec.attribute15(i) := g_attribute15;
            END IF;
	END IF;
    END IF; 	--l_header_flex_enabled = 'Y'

--start_date_active
-- bug 4510489
/*
    IF p_header_rec.start_date_active(I) IS NULL
       AND (p_header_rec.end_date_active(I) IS NULL or
	to_date(p_header_rec.end_date_active(I), 'MM/DD/YYYY') <= to_date(l_start_date_active, 'MM/DD/YYYY'))
    THEN
	p_header_rec.start_date_active(I) := l_start_date_active;
    END IF;
*/


  -- Updation check
  --cannot update Source system code, pte code
  IF p_header_rec.interface_action_code(I) = 'UPDATE'
     AND p_header_rec.process_status_flag(I) = 'P'  THEN

      qp_bulk_loader_pub.write_log( 'Update header no: '||to_char(l_list_header_id));
      l_old_PRICE_LIST_rec := QP_Price_List_Util.Query_Row
	(   p_list_header_id        => l_list_header_id
	);

      qp_bulk_loader_pub.write_log( 'Update source_system_code : '||l_old_price_list_rec.source_system_code);
      qp_bulk_loader_pub.write_log( 'Update pte_code : '||l_old_price_list_rec.pte_code);
      IF l_old_price_list_rec.source_system_code <> p_header_rec.source_system_code(I) or
         l_old_price_list_rec.pte_code <> p_header_rec.pte_code(I) THEN
	    p_header_rec.process_status_flag(I):=NULL;
	    fnd_message.set_name('QP', 'QP_NO_UPDATE_ATTRIBUTE');
            fnd_message.set_token('ATTRIBUTE', 'Source System Code / PTE Code');
	    qp_bulk_msg.add(l_msg_rec);
      END IF;
  END IF;

END LOOP;

  qp_bulk_loader_pub.write_log('Leaving Entity_header validation');

EXCEPTION
    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
       qp_bulk_loader_pub.write_log( 'UNEXCPECTED ERROR IN PROCEDURE ENTITY_HEADER:'||sqlerrm);
       RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    WHEN OTHERS THEN
       qp_bulk_loader_pub.write_log( 'UNEXCPECTED ERROR IN PROCEDURE ENTITY_HEADER:'||sqlerrm);
       RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
END ENTITY_HEADER;


PROCEDURE ENTITY_LINE
          (P_LINE_REC IN OUT NOCOPY QP_BULK_LOADER_PUB.LINE_REC_TYPE)

IS
   l_msg_rec QP_BULK_MSG.Msg_Rec_Type;
   l_dummy NUMBER;
   l_dummy_1 NUMBER;
   l_exist  NUMBER;
   l_pb_type_code  QP_LIST_LINES.price_break_type_code%type;
   l_art_opr  QP_LIST_LINES.arithmetic_operator%type;
   l_list_header_id	NUMBER:=null;
   l_orig_sys_header_ref VARCHAR2(50) := NULL;
   l_start_date date;
   l_line_flex_enabled VARCHAR2(1);

   --Bug 5246745 RAVI
   l_header_start_date DATE;
   l_header_end_date DATE;

   --Bug 5246745 RAVI
   l_servicable_item Varchar2(1) := 'N';

   --Bug 5246745 RAVI
   l_PBH_start_date DATE;
   l_PBH_end_date DATE;

BEGIN

   qp_bulk_loader_pub.write_log('Entering Entity Line');

    l_line_flex_enabled := get_flex_enabled_flag('QP_LIST_LINES');
    qp_bulk_loader_pub.write_log('Flex enabled '||l_line_flex_enabled);

   FOR I IN 1..p_line_rec.orig_sys_line_ref.count
   LOOP

      --Initially setting the message context.
      --qp_bulk_loader_pub.write_log(' In the loop');
      l_msg_rec.REQUEST_ID := P_LINE_REC.REQUEST_ID(i);
      l_msg_rec.ENTITY_TYPE :='PRL';
      l_msg_rec.TABLE_NAME :='QP_INTERFACE_LIST_LINES';
      l_msg_rec.ORIG_SYS_HEADER_REF := p_line_rec.orig_sys_header_ref(I);
      l_msg_rec.ORIG_SYS_LINE_REF := p_line_rec.orig_sys_line_ref(I);
      l_msg_rec.ORIG_SYS_QUALIFIER_REF := NULL;
      l_msg_rec.ORIG_SYS_PRICING_ATTR_REF := NULL;

   /*-- populating some internal fields --*/
      If p_line_rec.interface_action_code(I)='INSERT' THEN
	  select  qp_list_lines_s.nextval
	    into  p_line_rec.list_line_id(I)
	    from dual;
      end if;
      p_line_rec.list_line_no(I):= p_line_rec.list_line_id(I);
      p_line_rec.pricing_phase_id(I) := 1;
      p_line_rec.automatic_flag(I) := 'Y';
      p_line_rec.modifier_level_code(I) := 'LINE';
      p_line_rec.incompatibility_grp_code(I) := 'EXCL';

      IF l_orig_sys_header_ref IS NULL or
	 l_orig_sys_header_ref <> p_line_rec.orig_sys_header_ref(I) THEN
	  Begin
	  select list_header_id, start_date_active
	    into p_line_rec.list_header_id(I), l_start_date
	    from qp_list_headers_b
	   where orig_system_header_ref = p_line_rec.orig_sys_header_ref(I);
	 Exception
	    When no_data_found then
	    p_line_rec.list_header_id(I) := -1;
	    p_line_rec.process_status_flag(I):=NULL;
	    fnd_message.set_name('QP', 'QP_INVALID_HEADER_REF');
	    FND_MESSAGE.SET_TOKEN('REF_NO', p_line_rec.orig_sys_header_ref(I));
	    FND_MESSAGE.SET_TOKEN('LS_CODE', NULL);
	    qp_bulk_msg.add(l_msg_rec);
	 End;
	 IF p_line_rec.list_header_id(I) IS NOT NULL or
	    p_line_rec.list_header_id(I) <> 0 THEN
		l_list_header_id := p_line_rec.list_header_id(I);
		l_orig_sys_header_ref := p_line_rec.orig_sys_header_ref(I);
	 ELSE
		l_list_header_id := NULL;
		l_orig_sys_header_ref := NULL;
	 END IF;
      ELSE
	 p_line_rec.list_header_id(I) := l_list_header_id;
      END IF;
      qp_bulk_loader_pub.write_log('Line Start date active'||to_char(l_start_date));

   /*------- Performing required field validation for ---------*/

   --1.orig_sys_line_ref,
   IF p_line_rec.orig_sys_line_ref(I) IS NULL
   THEN
        p_line_rec.process_status_flag(I):=NULL;
	fnd_message.set_name('QP', 'QP_ATTRIBUTE_REQUIRED');
	fnd_message.set_token('ATTRIBUTE', 'ORIG_SYS_LINE_REF');
        qp_bulk_msg.add(l_msg_rec);
   END IF;

   --Bug#5359974 RAVI START
   --The continuous PB flag set to 'Y' if the line is PBH
   --1.1 continuous_price_break_flag
   IF p_line_rec.list_line_type_code(I)='PBH'
   THEN
      p_line_rec.continuous_price_break_flag(I):= 'Y';
   END IF;
   --Bug#5359974 RAVI END

   --2.List Line Type Code
    IF p_line_rec.list_line_type_code(I) IS NULL
   THEN
        p_line_rec.list_line_type_code(I):= '1';
        p_line_rec.process_status_flag(I):=NULL;
	fnd_message.set_name('QP', 'QP_ATTRIBUTE_REQUIRED');
	fnd_message.set_token('ATTRIBUTE', 'LIST_LINE_TYPE_CODE');
        qp_bulk_msg.add(l_msg_rec);
   END IF;

   IF p_line_rec.list_line_type_code(I) <>'PLL' AND p_line_rec.list_line_type_code(I)<>'PBH' THEN
       p_line_rec.process_status_flag(I):=NULL;
	fnd_message.set_name('QP', 'QP_INVALID_ATTRIBUTE');
	fnd_message.set_token('ATTRIBUTE', 'LIST_LINE_TYPE_CODE');
        qp_bulk_msg.add(l_msg_rec);
   END IF;

   --3. Arithmetic Operator
   IF p_line_rec.arithmetic_operator(I) IS NULL
   THEN
        p_line_rec.arithmetic_operator(I):= '1';
        p_line_rec.process_status_flag(I):=NULL;
	fnd_message.set_name('QP', 'QP_ATTRIBUTE_REQUIRED');
	fnd_message.set_token('ATTRIBUTE', 'ARITHMETIC_OPERATOR1');
        qp_bulk_msg.add(l_msg_rec);
   ELSE
	IF p_line_rec.arithmetic_operator(I) = 'BLOCK_PRICE' AND
           p_line_rec.list_line_type_code(I) <> 'PBH' AND
	   p_line_rec.price_break_header_ref(I) IS NULL THEN
	    p_line_rec.arithmetic_operator(I):= '1';
	    p_line_rec.process_status_flag(I):=NULL;
	    FND_MESSAGE.SET_NAME('QP', 'QP_INVALID_ATTRIBUTE');
	    fnd_message.set_token('ATTRIBUTE', 'ARITHMETIC_OPERATOR 2');
	    qp_bulk_msg.add(l_msg_rec);
	END IF;
	IF  p_line_rec.arithmetic_operator(I) = 'BREAKUNIT_PRICE' THEN
		IF p_line_rec.list_line_type_code(I) = 'PLL' AND
       		   p_line_rec.price_break_header_ref(I) IS NOT NULL THEN
		    NULL;
		ELSE
		    p_line_rec.arithmetic_operator(I):= '1';
		    p_line_rec.process_status_flag(I):=NULL;
		    FND_MESSAGE.SET_NAME('QP', 'QP_INVALID_ATTRIBUTE');
		    fnd_message.set_token('ATTRIBUTE', 'ARITHMETIC_OPERATOR 3');
		    qp_bulk_msg.add(l_msg_rec);
		END IF;
	 END IF;
    --End arithemetic operator check

    -- Bug# 5246745 RAVI START
    --Check if item is servicable
	IF p_line_rec.arithmetic_operator(I) = 'PERCENT_PRICE' THEN
   		qp_bulk_loader_pub.write_log('Percent Price - arithmetic operator check');
		l_exist :=0;

		begin
		   select count(*) into l_exist
    	   from qp_interface_pricing_attribs qipa, mtl_system_items_vl msiv
		   where qipa.orig_sys_line_ref = p_line_rec.orig_sys_line_ref(I)
		   and qipa.request_id = p_line_rec.request_id(I)
		   and qipa.product_attribute_context = 'ITEM'
		   and qipa.product_attribute = 'PRICING_ATTRIBUTE1'
		   and msiv.inventory_item_id = to_number(qipa.PRODUCT_ATTR_VALUE)
		   and msiv.organization_id = fnd_profile.value('QP_ORGANIZATION_ID')
		   and msiv.service_item_flag = 'Y'
           and qipa.interface_action_code in ('INSERT','UPDATE');
		exception
           when NO_DATA_FOUND then
		   l_exist := 0;
		end;

		if l_exist=0 then
           begin
	      select count(*) into l_exist
    	      from qp_pricing_attributes qpa, mtl_system_items_vl msiv
	      where qpa.orig_sys_line_ref = p_line_rec.orig_sys_line_ref(I)
              -- Bug 5246745 Use Composite Index for Ref columns
              and qpa.orig_sys_header_ref = p_line_rec.orig_sys_header_ref(I)
              and qpa.product_attribute_context = 'ITEM'
	      and qpa.product_attribute = 'PRICING_ATTRIBUTE1'
	      and msiv.inventory_item_id = to_number(qpa.PRODUCT_ATTR_VALUE)
	      and msiv.organization_id = fnd_profile.value('QP_ORGANIZATION_ID')
	      and msiv.service_item_flag = 'Y'
              and qpa.orig_sys_pricing_attr_ref not in (
                       select qpa.orig_sys_pricing_attr_ref
                       from   qp_interface_pricing_attribs qipa
                       where  qipa.orig_sys_pricing_attr_ref = qpa.orig_sys_pricing_attr_ref
                       and    qipa.interface_action_code = 'DELETE'
                       and    qipa.request_id = p_line_rec.request_id(I));
		   exception
              when NO_DATA_FOUND then
		      l_exist := 0;
		   end;
        end if;

		if l_exist = 0 then
		    p_line_rec.arithmetic_operator(I):= '1';
		    p_line_rec.process_status_flag(I):=NULL;
		    FND_MESSAGE.SET_NAME('QP', 'QP_INVALID_ATTRIBUTE');
		    fnd_message.set_token('ATTRIBUTE', 'ARITHMETIC_OPERATOR 4');
		    qp_bulk_msg.add(l_msg_rec);
        else
           l_servicable_item := 'Y';
		end if;
	END IF;
   END IF; --End arithemetic operator check

   qp_bulk_loader_pub.write_log('After required field check');

    -- Uniqueness of orig_sys_line_ref
    l_exist := 0;

   qp_bulk_loader_pub.write_log('Header ref'|| p_line_rec.orig_sys_header_ref(I));
   qp_bulk_loader_pub.write_log('Line ref'|| p_line_rec.orig_sys_line_ref(I));

   BEGIN
     select count(*) into l_exist
     from   qp_list_lines
     where  orig_sys_line_ref = p_line_rec.orig_sys_line_ref(I)
     and    orig_sys_header_ref = p_line_rec.orig_sys_header_ref(I) ;

   EXCEPTION
      	When no_data_found then
	   l_exist := 0;
   END;

     If p_line_rec.interface_action_code(I)='INSERT' AND l_exist >= 1 THEN
	p_line_rec.process_status_flag(I):=NULL;
	fnd_message.set_name('QP', 'ORIG_SYS_LINE_REF_NOT_UNIQUE');
        FND_MESSAGE.SET_TOKEN('REF_NO', p_line_rec.orig_sys_line_ref(I));
        qp_bulk_msg.add(l_msg_rec);
     ELSIF p_line_rec.interface_action_code(I)='UPDATE' AND l_exist = 0 THEN
	p_line_rec.process_status_flag(I):=NULL;
	fnd_message.set_name('QP', 'LINE_RECORD_DOES_NOT_EXIST');
        FND_MESSAGE.SET_TOKEN('REF_NO', p_line_rec.orig_sys_line_ref(I));
        qp_bulk_msg.add(l_msg_rec);
     END IF;

   If p_line_rec.interface_action_code(I)='INSERT' THEN
      l_exist:= NULL;
      select count(*) into l_exist
      from   qp_interface_list_lines
      where  request_id = p_line_rec.request_id(I)
      and    orig_sys_line_ref = p_line_rec.orig_sys_line_ref(I)
      and    orig_sys_header_ref = p_line_rec.orig_sys_header_ref(I);

    IF l_exist >1 THEN
	p_line_rec.process_status_flag(I):=NULL;
	fnd_message.set_name('QP', 'ORIG_SYS_LINE_REF_NOT_UNIQUE');
        FND_MESSAGE.SET_TOKEN('REF_NO', p_line_rec.orig_sys_line_ref(I));
        qp_bulk_msg.add(l_msg_rec);
    END IF;
   end if;

   --bug 9247305 start
   If p_line_rec.interface_action_code(I)='UPDATE' THEN
      l_exist:= NULL;

      select 1 INTO l_exist
      from qp_list_lines qpll
      WHERE qpll.orig_sys_line_ref = p_line_rec.orig_sys_line_ref(I)
        and qpll.list_line_id is not null
        and qpll.list_line_id <> p_line_rec.list_line_id(I);

     IF l_exist = 1 THEN
	p_line_rec.process_status_flag(I):=NULL;
	fnd_message.set_name('QP', 'ORIG_SYS_LINE_REF_NOT_UNIQUE');
        FND_MESSAGE.SET_TOKEN('REF_NO', p_line_rec.orig_sys_line_ref(I));
        qp_bulk_msg.add(l_msg_rec);
     END IF;
    end if;
    --bug 9247305 end

       --- check for conditionally required fields --------
     IF p_line_rec.list_line_type_code(I) = 'PBH' then
       IF p_line_rec.price_break_type_code(I) IS NULL then
	p_line_rec.process_status_flag(I):=NULL;
	fnd_message.set_name('QP', 'QP_ATTRIBUTE_REQUIRED');
	fnd_message.set_token('ATTRIBUTE', 'PRICE_BREAK_TYPE_CODE');
        qp_bulk_msg.add(l_msg_rec);
       END IF;
    ELSE
       IF p_line_rec.price_break_header_ref(I) IS NULL and
	  p_line_rec.price_break_type_code(I) IS NOT NULL then
	    p_line_rec.process_status_flag(I):=NULL;
	    FND_MESSAGE.SET_NAME('QP', 'QP_INVALID_ATTRIBUTE');
	    fnd_message.set_token('ATTRIBUTE', 'PRICE_BREAK_TYPE_CODE');
	    qp_bulk_msg.add(l_msg_rec);
       END IF;
    END IF;

     IF p_line_rec.price_break_header_ref(I) IS NOT NULL then
       IF p_line_rec.rltd_modifier_grp_type(I) IS NULL then
	p_line_rec.process_status_flag(I):=NULL;
	fnd_message.set_name('QP', 'QP_ATTRIBUTE_REQUIRED');
	fnd_message.set_token('ATTRIBUTE', 'RLTD_MODIFIER_GRP_TYPE');
        qp_bulk_msg.add(l_msg_rec);
       END IF;
    END IF;

       qp_bulk_loader_pub.write_log('check price break ARITHMETIC OPERATOR');
       -- check UNIT price break has no BLOCK price break child lines

       l_dummy:= null;
     IF p_line_rec.list_line_type_code(I) = 'PBH' then
	 IF (p_LINE_rec.arithmetic_operator(I) = 'UNIT_PRICE')
         THEN
	  SELECT count(*)
	      INTO l_dummy
	      FROM qp_interface_list_lines
	     WHERE price_break_header_ref = p_LINE_rec.orig_sys_line_ref(I)
	       AND arithmetic_operator = 'BLOCK_PRICE';

          -- if any price breaks are BLOCK
	  IF (l_dummy > 0) THEN
	     p_line_rec.process_status_flag(I):=NULL;
	     FND_MESSAGE.SET_NAME('QP','QP_INVALID_CHILD_APPL_METHOD');
	     qp_bulk_msg.add(l_msg_rec);
	  END IF;

         -- Bug# 5228560 RAVI START
         l_dummy:= null;

         select count(*) into l_dummy
         from qp_list_lines l1, qp_list_lines l2, qp_rltd_modifiers l3
         where l1.orig_sys_line_ref=p_LINE_rec.orig_sys_line_ref(I)
         -- Bug 5246745 Use Composite Index for Ref columns
         and l1.orig_sys_header_ref=p_LINE_rec.orig_sys_header_ref(I)
         and l1.list_line_id=l3.FROM_RLTD_MODIFIER_ID
         and l3.TO_RLTD_MODIFIER_ID=l2.list_line_id
         and l3.RLTD_MODIFIER_GRP_TYPE='PRICE BREAK'
	 AND l2.arithmetic_operator <> 'UNIT_PRICE';

         -- if any price breaks are BLOCK in old lines
         IF (l_dummy > 0) THEN
	    p_line_rec.process_status_flag(I):=NULL;
	    FND_MESSAGE.SET_NAME('QP','QP_INVALID_CHILD_APPL_METHOD');
	    qp_bulk_msg.add(l_msg_rec);
	 END IF;
         -- Bug# 5228560 RAVI END
      END IF;

       -- block pricing
       l_dummy := null;
       l_dummy_1 := null;
       IF (p_LINE_rec.arithmetic_operator(I) = 'BLOCK_PRICE' AND
	   p_LINE_rec.price_break_type_code(I) = 'POINT')
       THEN
--	  SELECT count(*)
--	      INTO l_dummy
--	      FROM qp_list_lines pl, qp_list_lines cl,qp_rltd_modifiers rtd
--	     WHERE pl.orig_sys_line_ref = p_line_rec.orig_sys_line_ref(I)
--	       AND rtd.from_rltd_modifier_id = pl.list_line_id
--	       AND cl.list_line_id = rtd.to_rltd_modifier_id
--	       AND (cl.arithmetic_operator = 'UNIT_PRICE' OR cl.recurring_value IS NOT NULL);
--
	  SELECT count(*)
	      INTO l_dummy
	      FROM qp_interface_list_lines
	     WHERE price_break_header_ref = p_LINE_rec.orig_sys_line_ref(I)
	       AND (arithmetic_operator = 'UNIT_PRICE' OR recurring_value IS NOT NULL);

	IF (l_dummy > 0) THEN
	    p_line_rec.process_status_flag(I):=NULL;
	     FND_MESSAGE.SET_NAME('QP','QP_INVALID_PRICE_BREAK');
	     qp_bulk_msg.add(l_msg_rec);
	END IF;

      END IF;

      -- Bug# 5228560 RAVI START
      IF p_LINE_rec.arithmetic_operator(I) = 'BLOCK_PRICE' THEN
         l_dummy := null;
         IF p_LINE_rec.price_break_type_code(I) = 'RANGE' THEN
            select count(*) into l_dummy
            from qp_list_lines l1, qp_list_lines l2, qp_rltd_modifiers l3
            where l1.orig_sys_line_ref=p_LINE_rec.orig_sys_line_ref(I)
            -- Bug 5246745 Use Composite Index for Ref columns
            and l1.orig_sys_header_ref=p_LINE_rec.orig_sys_header_ref(I)
            and l1.list_line_id=l3.FROM_RLTD_MODIFIER_ID
            and l3.TO_RLTD_MODIFIER_ID=l2.list_line_id
            and l3.RLTD_MODIFIER_GRP_TYPE='PRICE BREAK'
            AND l2.arithmetic_operator = 'UNIT_PRICE';
         END IF;

         IF (l_dummy > 0) THEN
	        p_line_rec.process_status_flag(I):=NULL;
            FND_MESSAGE.SET_NAME('QP','QP_INVALID_PRICE_BREAK');
            qp_bulk_msg.add(l_msg_rec);
         END IF;

         l_dummy := null;
         IF p_LINE_rec.price_break_type_code(I) = 'POINT' THEN
            select count(*) into l_dummy
            from qp_list_lines l1, qp_list_lines l2, qp_rltd_modifiers l3
            where l1.orig_sys_line_ref=p_LINE_rec.orig_sys_line_ref(I)
            -- Bug 5246745 Use Composite Index for Ref columns
            and l1.orig_sys_header_ref=p_LINE_rec.orig_sys_header_ref(I)
            and l1.list_line_id=l3.FROM_RLTD_MODIFIER_ID
            and l3.TO_RLTD_MODIFIER_ID=l2.list_line_id
            and l3.RLTD_MODIFIER_GRP_TYPE='PRICE BREAK'
            AND l2.arithmetic_operator <> 'UNIT_PRICE';
         END IF;

         IF (l_dummy > 0) THEN
            p_line_rec.process_status_flag(I):=NULL;
            FND_MESSAGE.SET_NAME('QP','QP_INVALID_PRICE_BREAK');
            qp_bulk_msg.add(l_msg_rec);
         END IF;
      END IF;
      -- Bug# 5228560 RAVI END

   END IF;

      -- check for pbh child line arithmetic operator
     IF p_line_rec.list_line_type_code(I) = 'PLL' AND
        p_line_rec.price_break_header_ref(I) IS NOT NULL THEN

        IF p_line_rec.arithmetic_operator(I) = 'BREAKUNIT_PRICE' and
           p_line_rec.recurring_value(I) is not NULL THEN
	       P_LINE_REC.PROCESS_STATUS_FLAG(I):= NULL; --'E';
	       FND_MESSAGE.SET_NAME('QP', 'QP_INVALID_ATTRIBUTE');
	       FND_MESSAGE.SET_TOKEN('ATTRIBUTE', 'Recurring Value');
	       QP_BULK_MSG.ADD(l_msg_rec);
        END IF;

        BEGIN
           SELECT price_break_type_code, arithmetic_operator
	       INTO l_pb_type_code, l_art_opr
	       FROM QP_INTERFACE_LIST_LINES
	       WHERE orig_sys_line_ref = p_line_rec.price_break_header_ref(I)
	       AND orig_sys_header_ref = p_line_rec.orig_sys_header_ref(I)
	       AND request_id = p_line_rec.request_id(I);
           --Bug 4405737 START RAVI
           /**
           Price break type of Price break hdr line and child line should not be null.
           The price break type code of Price break hdr line and child line should be
           equal.
           **/
           IF p_line_rec.price_break_type_code(I) IS NULL OR
              l_pb_type_code IS NULL THEN
              P_LINE_REC.PROCESS_STATUS_FLAG(I):= NULL; --'E';
              FND_MESSAGE.SET_NAME('QP', 'QP_INVALID_ATTRIBUTE');
	          FND_MESSAGE.SET_TOKEN('ATTRIBUTE', 'Recurring Value');
	          QP_BULK_MSG.ADD(l_msg_rec);
              qp_bulk_loader_pub.write_log('PRICE BREAK TYPE CODE NULL');
           ELSE
              IF p_line_rec.price_break_type_code(I) = l_pb_type_code
              THEN
                 NULL;
              ELSE
                 P_LINE_REC.PROCESS_STATUS_FLAG(I):= NULL; --'E';
                 FND_MESSAGE.SET_NAME('QP', 'QP_INVALID_ATTRIBUTE');
                 FND_MESSAGE.SET_TOKEN('ATTRIBUTE', 'Recurring Value');
                 QP_BULK_MSG.ADD(l_msg_rec);
                 qp_bulk_loader_pub.write_log('PRICE BREAK TYPE CODE OF PARENT AND CHILD UNEQUAL');
              END IF;
           END IF;
    --Bug 4405737 END RAVI
      IF l_servicable_item='N' THEN
         IF p_line_rec.arithmetic_operator(I) = 'UNIT_PRICE' THEN
            IF l_art_opr <> 'UNIT_PRICE'
		       and l_art_opr <> 'PERCENT_PRICE'
            THEN
	           P_LINE_REC.PROCESS_STATUS_FLAG(I):= NULL; --'E';
	           FND_MESSAGE.SET_NAME('QP', 'QP_INVALID_ATTRIBUTE');
	           FND_MESSAGE.SET_TOKEN('ATTRIBUTE', 'Arithmetic Operator');
	           QP_BULK_MSG.ADD(l_msg_rec);
            END IF;
         ELSIF p_line_rec.arithmetic_operator(I) = 'BLOCK_PRICE' THEN
            IF l_art_opr <> 'BLOCK_PRICE' THEN
	           P_LINE_REC.PROCESS_STATUS_FLAG(I):= NULL; --'E';
               FND_MESSAGE.SET_NAME('QP', 'QP_INVALID_ATTRIBUTE');
	           FND_MESSAGE.SET_TOKEN('ATTRIBUTE', 'Arithmetic Operator');
	           QP_BULK_MSG.ADD(l_msg_rec);
            END IF;
         ELSIF p_line_rec.arithmetic_operator(I) = 'BREAKUNIT_PRICE' THEN
            IF l_art_opr <> 'BLOCK_PRICE' OR l_pb_type_code <> 'RANGE'  THEN
	           P_LINE_REC.PROCESS_STATUS_FLAG(I):= NULL; --'E';
               FND_MESSAGE.SET_NAME('QP', 'QP_INVALID_ATTRIBUTE');
	           FND_MESSAGE.SET_TOKEN('ATTRIBUTE', 'Arithmetic Operator');
	           QP_BULK_MSG.ADD(l_msg_rec);
            END IF;
	     END IF;
      END IF;

         -- Bug# 5228560 (5246745) RAVI START
         -- Check for application method compatibility between PBH line and PBC line
	     l_pb_type_code := NULL;
	     l_art_opr := NULL;

         --Get the PBH details
         SELECT L2.price_break_type_code, L2.arithmetic_operator
    	 INTO l_pb_type_code, l_art_opr
         from qp_list_lines l1, qp_list_lines l2, qp_rltd_modifiers l3
         where l1.orig_sys_line_ref=p_LINE_rec.orig_sys_line_ref(I)
         -- Bug 5246745 Use Composite Index for Ref columns
         and l1.orig_sys_header_ref=p_LINE_rec.orig_sys_header_ref(I)
         and l1.list_line_id=l3.TO_RLTD_MODIFIER_ID
         and l3.FROM_RLTD_MODIFIER_ID=l2.list_line_id
         and l3.RLTD_MODIFIER_GRP_TYPE='PRICE BREAK';

         IF l_servicable_item='N' THEN
            IF p_line_rec.arithmetic_operator(I) = 'UNIT_PRICE' THEN
               IF l_art_opr <> 'UNIT_PRICE' THEN
                  P_LINE_REC.PROCESS_STATUS_FLAG(I):= NULL; --'E';
                  FND_MESSAGE.SET_NAME('QP', 'QP_INVALID_ATTRIBUTE');
                  FND_MESSAGE.SET_TOKEN('ATTRIBUTE', 'Arithmetic Operator - Orderable item - PBC UNIT_PRICE -- PBH Wrong');
                  QP_BULK_MSG.ADD(l_msg_rec);
               END IF;
	        ELSIF p_line_rec.arithmetic_operator(I) = 'BLOCK_PRICE' THEN
               IF l_art_opr <> 'BLOCK_PRICE' THEN
	              P_LINE_REC.PROCESS_STATUS_FLAG(I):= NULL; --'E';
                  FND_MESSAGE.SET_NAME('QP', 'QP_INVALID_ATTRIBUTE');
	              FND_MESSAGE.SET_TOKEN('ATTRIBUTE', 'Arithmetic Operator - Orderable item - PBC BLOCK_PRICE -- PBH Wrong');
	              QP_BULK_MSG.ADD(l_msg_rec);
               END IF;
            ELSIF p_line_rec.arithmetic_operator(I) = 'BREAKUNIT_PRICE' THEN
               IF l_art_opr <> 'BLOCK_PRICE' OR l_pb_type_code <> 'RANGE' THEN
                  P_LINE_REC.PROCESS_STATUS_FLAG(I):= NULL; --'E';
	              FND_MESSAGE.SET_NAME('QP', 'QP_INVALID_ATTRIBUTE');
                  FND_MESSAGE.SET_TOKEN('ATTRIBUTE', 'Arithmetic Operator - Orderable item - PBC BREAKUNIT_PRICE -- PBH Wrong');
	              QP_BULK_MSG.ADD(l_msg_rec);
               END IF;
	        END IF;
         ELSIF l_servicable_item='Y' THEN
            IF p_line_rec.arithmetic_operator(I) = 'UNIT_PRICE' THEN
               IF l_art_opr <> 'UNIT_PRICE' and l_art_opr <> 'PERCENT_PRICE' THEN
                  P_LINE_REC.PROCESS_STATUS_FLAG(I):= NULL; --'E';
                  FND_MESSAGE.SET_NAME('QP', 'QP_INVALID_ATTRIBUTE');
                  FND_MESSAGE.SET_TOKEN('ATTRIBUTE', 'Arithmetic Operator - Servicable item - PBC UNIT_PRICE -- PBH Wrong');
                  QP_BULK_MSG.ADD(l_msg_rec);
               END IF;
	        ELSIF p_line_rec.arithmetic_operator(I) = 'BLOCK_PRICE' THEN
               IF l_art_opr <> 'BLOCK_PRICE' THEN
	              P_LINE_REC.PROCESS_STATUS_FLAG(I):= NULL; --'E';
                  FND_MESSAGE.SET_NAME('QP', 'QP_INVALID_ATTRIBUTE');
	              FND_MESSAGE.SET_TOKEN('ATTRIBUTE', 'Arithmetic Operator - Servicable item - PBC BLOCK_PRICE -- PBH Wrong');
	              QP_BULK_MSG.ADD(l_msg_rec);
               END IF;
            ELSIF p_line_rec.arithmetic_operator(I) = 'BREAKUNIT_PRICE' THEN
               IF l_art_opr <> 'BLOCK_PRICE' THEN
                  P_LINE_REC.PROCESS_STATUS_FLAG(I):= NULL; --'E';
	              FND_MESSAGE.SET_NAME('QP', 'QP_INVALID_ATTRIBUTE');
                  FND_MESSAGE.SET_TOKEN('ATTRIBUTE', 'Arithmetic Operator - Servicable item - PBC BREAKUNIT_PRICE -- PBH Wrong');
	              QP_BULK_MSG.ADD(l_msg_rec);
               END IF;
            ELSIF p_line_rec.arithmetic_operator(I) = 'PERCENT_PRICE' THEN
               IF l_art_opr <> 'BLOCK_PRICE' OR
                  l_art_opr <> 'PERCENT_PRICE' OR
                  l_art_opr <> 'UNIT_PRICE'
               THEN
                  P_LINE_REC.PROCESS_STATUS_FLAG(I):= NULL; --'E';
	              FND_MESSAGE.SET_NAME('QP', 'QP_INVALID_ATTRIBUTE');
                  FND_MESSAGE.SET_TOKEN('ATTRIBUTE', 'Arithmetic Operator - Servicable item - PBC PERCENT_PRICE -- PBH Wrong');
	              QP_BULK_MSG.ADD(l_msg_rec);
               END IF;
            END IF;
         END IF;
         -- Bug# 5228560 (5246745) RAVI END

        EXCEPTION
	   WHEN NO_DATA_FOUND THEN
	      null;
	END;
     END IF;

      qp_bulk_loader_pub.write_log('After pbh check');

   -- check for operand value for the line.
   IF  p_LINE_rec.list_line_type_code(I) = 'PLL'
   and p_LINE_rec.operand(I) IS NULL
   and p_LINE_rec.price_by_formula_id(I) IS NULL
   and p_LINE_rec.generate_using_formula_id(I) IS NULL
   THEN

    p_line_rec.process_status_flag(I):=NULL;
    FND_MESSAGE.SET_NAME('QP','QP_OPERAND_FORMULA');
    QP_BULK_MSG.ADD(l_msg_rec);

   END IF;

   -- Recurring value check
   -- Bug 4995724 START RAVI
   /**
   Recurring value should always be more than 1.
   Recurring value allowed only for RANGE and BLOCK PRICE
   **/
   IF p_line_rec.recurring_value(I) is not null THEN
      IF p_line_rec.recurring_value(I) < 1 Then
         FND_MESSAGE.SET_NAME('QP','QP_INVALID_ATTRIBUTE');
         FND_MESSAGE.SET_TOKEN('ATTRIBUTE','Recurring Value');
         QP_BULK_MSG.ADD(l_msg_rec);
      ELSIF p_line_rec.arithmetic_operator(I) <> 'BLOCK_PRICE'
      OR l_art_opr <> 'BLOCK_PRICE'
      OR l_pb_type_code <> 'RANGE'
      THEN
         FND_MESSAGE.SET_NAME('QP','QP_INVALID_ATTRIBUTE');
         FND_MESSAGE.SET_TOKEN('ATTRIBUTE','Recurring Value');
         QP_BULK_MSG.ADD(l_msg_rec);
       END IF;
   END IF;
   /**
   IF p_line_rec.recurring_value(I) is not null
      And p_line_rec.recurring_value(I) < 1 Then
      FND_MESSAGE.SET_NAME('QP','QP_INVALID_ATTRIBUTE');
      FND_MESSAGE.SET_TOKEN('ATTRIBUTE','Recurring Value');
      QP_BULK_MSG.ADD(l_msg_rec);
   END IF;
   **/
   -- Bug 4995724 END RAVI


   -- Date Check
   IF p_line_rec.end_date_active(I) IS NULL
   OR p_line_rec.start_date_active(I) IS NULL
   THEN
       Null;
   ELSIF (p_line_rec.start_date_active(I) > p_line_rec.end_date_active(I) ) THEN
       FND_MESSAGE.SET_NAME('QP', 'QP_STRT_DATE_BFR_END_DATE');
       QP_BULK_MSG.Add(l_msg_rec);
       --Bug# 5228368 RAVI
       p_line_rec.process_status_flag(I):=NULL;
   END IF;


   -- Date check with respect to header dates
   /**
    * Bug 5246745 RAVI START
    * Price List Line Start date should be on or after Price List Header Start Date
    * Price List Line End date should be on or before Price List Header End Date
    **/
    l_header_start_date := null;
    l_header_end_date := null;

    BEGIN
       select fnd_date.canonical_to_date(start_date_active),
              fnd_date.canonical_to_date(end_date_active)
       into l_header_start_date, l_header_end_date
       from qp_interface_list_headers
       where orig_sys_header_ref=p_line_rec.orig_sys_header_ref(I)
         and request_id=p_line_rec.request_id(I)
         and interface_action_code in ('INSERT','UPDATE');
    EXCEPTION
       WHEN OTHERS
       THEN
          qp_bulk_loader_pub.write_log( 'ERROR in comparing the Header and Line start Dates (INTERFACE)');
    END;

    IF l_header_start_date IS NULL THEN
       BEGIN
          select start_date_active, end_date_active
          into l_header_start_date, l_header_end_date
          from qp_list_headers_b
          where orig_system_header_ref=p_line_rec.orig_sys_header_ref(I);
       EXCEPTION
          WHEN OTHERS
          THEN
             qp_bulk_loader_pub.write_log( 'ERROR in comparing the Header and Line start Dates (QP)');
       END;
    END IF;

    IF p_line_rec.start_date_active(I) < l_header_start_date OR
       p_line_rec.end_date_active(I) > l_header_end_date
    THEN
       FND_MESSAGE.SET_NAME('QP', 'QP_INVALID_DATE');
       QP_BULK_MSG.Add(l_msg_rec);
       p_line_rec.process_status_flag(I):=NULL;
    END IF;
    -- Bug 5246745 RAVI END


   -- Price break child date check with respect to price break header dates
   /**
    * Bug 5246745 RAVI START
    * Price break child line Start date should be equal to Price break Header Start Date
    * Price break child line End date should be equal to Price break Header End Date
    **/
    l_PBH_start_date := null;
    l_PBH_end_date := null;

    IF p_line_rec.list_line_type_code(I)='PLL' AND
       p_line_rec.PRICE_BREAK_HEADER_REF(I) is not null AND
       p_line_rec.RLTD_MODIFIER_GRP_TYPE(I)='PRICE BREAK'
    THEN
       BEGIN
          select start_date_active, end_date_active
          into l_PBH_start_date, l_PBH_end_date
          from qp_interface_list_lines
          where orig_sys_line_ref=p_line_rec.PRICE_BREAK_HEADER_REF(I)
            -- Bug 5246745 Use Composite Index for Ref columns
            and orig_sys_header_ref=p_LINE_rec.orig_sys_header_ref(I)
            and request_id=p_line_rec.request_id(I)
            and interface_action_code in ('INSERT','UPDATE');
       EXCEPTION
          WHEN OTHERS
          THEN
             qp_bulk_loader_pub.write_log( 'ERROR in comparing the PBH and PBC start Dates (INTERFACE)');
       END;

       IF l_PBH_start_date is null THEN
          BEGIN
             select start_date_active, end_date_active
             into l_PBH_start_date, l_PBH_end_date
             from qp_list_lines
             where orig_sys_line_ref=p_line_rec.PRICE_BREAK_HEADER_REF(I)
             -- Bug 5246745 Use Composite Index for Ref columns
             and orig_sys_header_ref=p_LINE_rec.orig_sys_header_ref(I);
          EXCEPTION
             WHEN OTHERS
             THEN
                qp_bulk_loader_pub.write_log( 'ERROR in comparing the PBH and PBC start Dates (INTERFACE)');
          END;
       END IF;

       IF l_PBH_start_date <> p_line_rec.start_date_active(I) OR
          l_PBH_end_date <> p_line_rec.end_date_active(I)
       THEN
          FND_MESSAGE.SET_NAME('QP', 'QP_INVALID_DATE');
          QP_BULK_MSG.Add(l_msg_rec);
          p_line_rec.process_status_flag(I):=NULL;
       END IF;
    END IF;
    -- Bug 5246745 RAVI END

--Flex field check

    IF l_line_flex_enabled = 'Y' THEN
      qp_bulk_loader_pub.write_log( 'Line Flex enabled ');

         IF NOT Init_Desc_Flex
               (p_flex_name	     =>'QP_LIST_LINES'
	       ,p_context            => p_line_rec.context(i)
               ,p_attribute1         => p_line_rec.attribute1(i)
               ,p_attribute2         => p_line_rec.attribute2(i)
               ,p_attribute3         => p_line_rec.attribute3(i)
               ,p_attribute4         => p_line_rec.attribute4(i)
               ,p_attribute5         => p_line_rec.attribute5(i)
               ,p_attribute6         => p_line_rec.attribute6(i)
               ,p_attribute7         => p_line_rec.attribute7(i)
               ,p_attribute8         => p_line_rec.attribute8(i)
               ,p_attribute9         => p_line_rec.attribute9(i)
               ,p_attribute10        => p_line_rec.attribute10(i)
               ,p_attribute11        => p_line_rec.attribute11(i)
               ,p_attribute12        => p_line_rec.attribute12(i)
               ,p_attribute13        => p_line_rec.attribute13(i)
               ,p_attribute14        => p_line_rec.attribute14(i)
               ,p_attribute15        => p_line_rec.attribute15(i)) THEN

	         QP_BULK_MSG.ADD(l_msg_rec);

                 -- Log Error Message
                 FND_MESSAGE.SET_NAME('QP','QP_INVALID_ATTRIBUTE');
                 FND_MESSAGE.SET_TOKEN('ATTRIBUTE',
                                       'Entity:Flexfield:Line_Desc_Flex');
	         p_line_rec.process_status_flag(I):=NULL;

	         QP_BULK_MSG.ADD(l_msg_rec);

          ELSE -- if the flex validation is successfull

            IF p_line_rec.context(i) IS NULL
              OR p_line_rec.context(i) = FND_API.G_MISS_CHAR THEN
               p_line_rec.context(i)    := g_context;
            END IF;

            IF p_line_rec.attribute1(i) IS NULL
              OR p_line_rec.attribute1(i) = FND_API.G_MISS_CHAR THEN
               p_line_rec.attribute1(i) := g_attribute1;
            END IF;

            IF p_line_rec.attribute2(i) IS NULL
              OR p_line_rec.attribute2(i) = FND_API.G_MISS_CHAR THEN
               p_line_rec.attribute2(i) := g_attribute2;
            END IF;

            IF p_line_rec.attribute3(i) IS NULL
              OR p_line_rec.attribute3(i) = FND_API.G_MISS_CHAR THEN
               p_line_rec.attribute3(i) := g_attribute3;
            END IF;

            IF p_line_rec.attribute4(i) IS NULL
              OR p_line_rec.attribute4(i) = FND_API.G_MISS_CHAR THEN
               p_line_rec.attribute4(i) := g_attribute4;
            END IF;

            IF p_line_rec.attribute5(i) IS NULL
              OR p_line_rec.attribute5(i) = FND_API.G_MISS_CHAR THEN
               p_line_rec.attribute5(i) := g_attribute5;
            END IF;

            IF p_line_rec.attribute6(i) IS NULL
              OR p_line_rec.attribute6(i) = FND_API.G_MISS_CHAR THEN
               p_line_rec.attribute6(i) := g_attribute6;
            END IF;
            IF p_line_rec.attribute7(i) IS NULL
              OR p_line_rec.attribute7(i) = FND_API.G_MISS_CHAR THEN
               p_line_rec.attribute7(i) := g_attribute7;
            END IF;

            IF p_line_rec.attribute8(i) IS NULL
              OR p_line_rec.attribute8(i) = FND_API.G_MISS_CHAR THEN
               p_line_rec.attribute8(i) := g_attribute8;
            END IF;

            IF p_line_rec.attribute9(i) IS NULL
              OR p_line_rec.attribute9(i) = FND_API.G_MISS_CHAR THEN
               p_line_rec.attribute9(i) := g_attribute9;
            END IF;

            IF p_line_rec.attribute10(i) IS NULL
              OR p_line_rec.attribute10(i) = FND_API.G_MISS_CHAR THEN
               p_line_rec.attribute10(i) := G_attribute10;
            End IF;

            IF p_line_rec.attribute11(i) IS NULL
              OR p_line_rec.attribute11(i) = FND_API.G_MISS_CHAR THEN
               p_line_rec.attribute11(i) := g_attribute11;
            END IF;

            IF p_line_rec.attribute12(i) IS NULL
              OR p_line_rec.attribute12(i) = FND_API.G_MISS_CHAR THEN
               p_line_rec.attribute12(i) := g_attribute12;
            END IF;

            IF p_line_rec.attribute13(i) IS NULL
              OR p_line_rec.attribute13(i) = FND_API.G_MISS_CHAR THEN
               p_line_rec.attribute13(i) := g_attribute13;
            END IF;

            IF p_line_rec.attribute14(i) IS NULL
              OR p_line_rec.attribute14(i) = FND_API.G_MISS_CHAR THEN
               p_line_rec.attribute14(i) := g_attribute14;
            END IF;

            IF p_line_rec.attribute15(i) IS NULL
              OR p_line_rec.attribute15(i) = FND_API.G_MISS_CHAR THEN
               p_line_rec.attribute15(i) := g_attribute15;
            END IF;
	END IF;
    END IF;

-- Basic_Pricing_Condition
   IF QP_BULK_LOADER_PUB.GET_QP_STATUS <> 'I' THEN
	IF p_line_rec.price_break_type_code(I) IS NOT NULL THEN
	   p_line_rec.price_break_type_code(I) := NULL;
	END IF;
	IF p_line_rec.primary_uom_flag(I) = 'Y' THEN
	   p_line_rec.primary_uom_flag(I) := 'N';
	END IF;
   END IF;
--start_date_active
      qp_bulk_loader_pub.write_log('Line Start date value'||nvl(to_char(p_line_rec.start_date_active(I)), 'NULL'));
      qp_bulk_loader_pub.write_log('Line end date value'||nvl(to_char(p_line_rec.end_date_active(I)), 'NULL'));

    --Bug#5353889 RAVI START
    --Start date null should be allowed
    /**
    IF p_line_rec.start_date_active(I) IS NULL
       AND (p_line_rec.end_date_active(I) IS NULL or
	p_line_rec.end_date_active(I) <= l_start_date)
    THEN
      qp_bulk_loader_pub.write_log('Line Start date updated');
	p_line_rec.start_date_active(I) := l_start_date;
    END IF;
    **/
    --Bug#5353889 RAVI END

  END LOOP;

  qp_bulk_loader_pub.write_log('Leaving entity line validation');

 EXCEPTION
    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
       qp_bulk_loader_pub.write_log( 'UNEXCPECTED ERROR IN PROCEDURE ENTITY_LINE:'||sqlerrm);
       RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    WHEN OTHERS THEN
       qp_bulk_loader_pub.write_log( 'UNEXCPECTED ERROR IN PROCEDURE ENTITY_LINE:'||sqlerrm);
       RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
END ENTITY_LINE;


PROCEDURE ENTITY_QUALIFIER
          (p_qualifier_rec IN OUT NOCOPY QP_BULK_LOADER_PUB.qualifier_rec_type)
IS
 l_msg_rec                  QP_BULK_MSG.Msg_Rec_Type;
 l_segment_name             VARCHAR2(240);
 x_value                    VARCHAR2(240);
 x_id                       VARCHAR2(150);
 x_format_type              VARCHAR2(1);
 l_exist                    NUMBER;
 l_dummy                    VARCHAR2(240);
 l_seg_level                VARCHAR2(10);

l_context_error VARCHAR2(1);
l_attribute_error VARCHAR2(1);
l_value_error VARCHAR2(1);
l_datatype VARCHAR2(1);
l_precedence NUMBER;
l_error_code NUMBER;

l_context_type                VARCHAR2(30);
l_sourcing_enabled            VARCHAR2(1);
l_sourcing_status             VARCHAR2(1);
l_hierarchy_enabled           VARCHAR2(1);
l_sourcing_method             VARCHAR2(30);

-- Bug 4926775 RAVI
/**
local variable for header id.
**/
l_list_header_id NUMBER;

BEGIN
  qp_bulk_loader_pub.write_log('Entering Entity Qualifier');

  FOR I IN p_qualifier_rec.orig_sys_qualifier_ref.first
           ..p_qualifier_rec.orig_sys_qualifier_ref.last
  LOOP

     --qp_bulk_loader_pub.write_log('request_id: '||p_qualifier_rec.request_id(I));
      --Initially setting the message context.

     l_msg_rec.REQUEST_ID := P_QUALIFIER_REC.REQUEST_ID(I);
     l_msg_rec.ENTITY_TYPE :='PRL';
     l_msg_rec.TABLE_NAME :='QP_INTERFACE_QUALIFIERS';
     l_msg_rec.ORIG_SYS_HEADER_REF := p_qualifier_rec.orig_sys_header_ref(I);
     l_msg_rec.ORIG_SYS_QUALIFIER_REF := p_qualifier_rec.orig_sys_qualifier_ref(I);
     l_msg_rec.ORIG_SYS_QUALIFIER_REF := NULL;
     l_msg_rec.ORIG_SYS_PRICING_ATTR_REF := NULL;

     /*--- Internal Field populate ----*/
     p_qualifier_rec.excluder_flag(I) := 'N';
     p_qualifier_rec.orig_sys_line_ref(I) := '-1';

      If p_qualifier_rec.interface_action_code(I)='INSERT' THEN
       Select qp_qualifiers_s.nextval
       into p_qualifier_rec.qualifier_id(I) from dual;
      end if;



     /*---- Conversion of qualifier_context, qualifier_attribute,-------------
     --------qualifier_attr_value, qualifier_attr_value_to  -----------------*/

     IF p_qualifier_rec.qualifier_grouping_no(I) IS NULL THEN
	p_qualifier_rec.process_status_flag(I):=NULL;
	FND_MESSAGE.SET_NAME('QP','QP_ATTRIBUTE_REQUIRED');
        FND_MESSAGE.SET_TOKEN('ATTRIBUTE','QUALIFIER GROUPING NO');
        QP_BULK_MSG.ADD(l_msg_rec);
     END IF;

     IF p_qualifier_rec.list_line_id(I) IS NOT NULL THEN
	IF p_qualifier_rec.list_line_id(I) <> -1 THEN
	       p_qualifier_rec.process_status_flag(I):=NULL;
	       FND_MESSAGE.SET_NAME('QP','QP_INVALID_ATTRIBUTE');
	       FND_MESSAGE.SET_TOKEN('ATTRIBUTE','LIST_LINE_ID');
	       QP_BULK_MSG.ADD(l_msg_rec);
     	END IF;
     ELSE
	p_qualifier_rec.list_line_id(I):=-1;
     END IF;
     -- Qualifier Context
/*     IF p_qualifier_rec.qualifier_context(I) IS NULL THEN
	p_qualifier_rec.qualifier_context(I) := '1';
	p_qualifier_rec.process_status_flag(I):=NULL;
	FND_MESSAGE.SET_NAME('QP','QP_ATTRIBUTE_REQUIRED');
        FND_MESSAGE.SET_TOKEN('ATTRIBUTE','QUALIFIER CONTEXT');
        QP_BULK_MSG.ADD(l_msg_rec);
    END IF; */


     -- Qualifier Attribute

	IF p_qualifier_rec.qualifier_attribute(I) IS NULL THEN

--	IF p_qualifier_rec.qualifier_attribute_code(I) IS NULL THEN
	p_qualifier_rec.qualifier_attribute_code(I):= '1';
	p_qualifier_rec.process_status_flag(I):=NULL;
	FND_MESSAGE.SET_NAME('QP','QP_ATTRIBUTE_REQUIRED');
        FND_MESSAGE.SET_TOKEN('ATTRIBUTE','QUALIFIER ATTRIBUTE CODE');
        QP_BULK_MSG.ADD(l_msg_rec);
/*	ELSE

	   BEGIN
	      p_qualifier_rec.qualifier_attribute(I):= QP_UTIL.Get_Attribute_Name(
				p_application_short_name => 'QP',
				p_flexfield_name=> 'QP_ATTR_DEFNS_QUALIFIER',
				p_context_name =>p_qualifier_rec.qualifier_context(I),
				p_attribute_name=>p_qualifier_rec.qualifier_attribute_code(I));

              IF p_qualifier_rec.qualifier_attribute(I) IS NULL THEN
                p_qualifier_rec.qualifier_attribute(I):='1';
		p_qualifier_rec.process_status_flag(I):=NULL;
		FND_MESSAGE.SET_NAME('QP','QP_VALUE_TO_ID_ERROR');
		FND_MESSAGE.SET_TOKEN('ATTRIBUTE','qualifier_attribute');
		QP_BULK_MSG.ADD(l_msg_rec);
              END IF;
	   EXCEPTION
	     WHEN NO_DATA_FOUND THEN
		 p_qualifier_rec.qualifier_attribute(I):='1';
		p_qualifier_rec.process_status_flag(I):=NULL;
		FND_MESSAGE.SET_NAME('QP','QP_VALUE_TO_ID_ERROR');
		FND_MESSAGE.SET_TOKEN('ATTRIBUTE','qualifier_attribute');
		QP_BULK_MSG.ADD(l_msg_rec);
	  END;
	END IF; */

	END IF;

    	IF ( p_qualifier_rec.qualify_hier_descendents_flag(I) IS NOT NULL)
          THEN
                IF p_qualifier_rec.qualify_hier_descendents_flag(I) NOT IN ('Y', 'N', 'y', 'n')
                THEN
                p_qualifier_rec.process_status_flag(I):=NULL;
                FND_MESSAGE.SET_NAME('QP','QP_INVALID_ATTRIBUTE');
                FND_MESSAGE.SET_TOKEN('ATTRIBUTE','QUALIFY HIER DESCENDENTS FLAG ');
                qp_bulk_msg.add(l_msg_rec);
                ELSIF p_qualifier_rec.qualify_hier_descendents_flag(I) in ('Y','y') THEN
                 BEGIN
                 select 'Y' into l_hierarchy_enabled
                 from dual
                 where exists(select 'X'
                 from qp_segments_b qs,qp_prc_contexts_b qpc
                 where
                 qs.prc_context_id = qpc.prc_context_id and
                 qpc.prc_context_code = p_qualifier_rec.qualifier_context(I) and
                 qs.segment_mapping_column = p_qualifier_rec.qualifier_attribute(I) and
                 qpc.PRC_CONTEXT_TYPE = 'QUALIFIER'
                 and qs.party_hierarchy_enabled_flag ='Y');
                  p_qualifier_rec.qualify_hier_descendents_flag(I) := 'Y';
                 EXCEPTION WHEN NO_DATA_FOUND THEN
                  p_qualifier_rec.process_status_flag(I):=NULL;
                  FND_MESSAGE.SET_NAME('QP','QP_INVALID_ATTRIBUTE');
                  FND_MESSAGE.SET_TOKEN('ATTRIBUTE','QUALIFY HIER DESCENDENTS FLAG ');
                  qp_bulk_msg.add(l_msg_rec);
                 END;
                 ELSE
                    null;
                END IF;
    END IF;

-- Bug# 5214576 RAVI START
-- Qualifier Start and End Date validation
IF p_qualifier_rec.end_date_active(I) is not null THEN
   IF p_qualifier_rec.start_date_active(I) is not null THEN
      IF p_qualifier_rec.start_date_active(I) > p_qualifier_rec.end_date_active(I) THEN
         qp_bulk_loader_pub.write_log('End Date is before Start Date');
         p_qualifier_rec.process_status_flag(I):=NULL;
         FND_MESSAGE.SET_NAME('QP', 'QP_STRT_DATE_BFR_END_DATE');
	 QP_BULK_MSG.Add(l_msg_rec);
      END IF;
   ELSE
      qp_bulk_loader_pub.write_log('Qualifier Start Date is null');
      p_qualifier_rec.process_status_flag(I):=NULL;
      FND_MESSAGE.SET_NAME('QP', 'QP_INVALID_DATE');
      QP_BULK_MSG.Add(l_msg_rec);
   END IF;
END IF;
-- Bug# 5214576 RAVI END

-- Qualifier Attr Value

--Bug 4929426 START RAVI
/**
Qualifier attribute value validation (Messages)
**/

IF p_qualifier_rec.qualifier_context(I) = 'MODLIST'
AND p_qualifier_rec.qualifier_attribute(I) = 'QUALIFIER_ATTRIBUTE4'
THEN
   begin
      select 1 into l_exist from qp_list_headers_b
      where list_header_id = to_number(p_qualifier_rec.qualifier_attr_value(I));
   exception when others then
      p_qualifier_rec.process_status_flag(I):=NULL;
      FND_MESSAGE.SET_NAME('QP','QP_INVALID_ATTRIBUTE');
      FND_MESSAGE.SET_TOKEN('ATTRIBUTE','QUALIFIER_ATTR_VALUE');
      QP_BULK_MSG.ADD(l_msg_rec);
   end;
ELSE

   -- Bug 5152088 Checking if Qualifier Attribute Value Code is valid
   IF p_QUALIFIER_rec.qualifier_attr_value_code(I) IS NOT NULL THEN
      p_QUALIFIER_rec.qualifier_attr_value(I) := QP_Value_To_Id.qualifier_attr_value(
                                    p_QUALIFIER_rec.qualifier_attr_value_code(I),
                                    p_QUALIFIER_rec.qualifier_context(I),
                                    p_QUALIFIER_rec.qualifier_attribute(I)
                                   );
   END IF;

   QP_UTIL.validate_qp_flexfield(
      flexfield_name         =>'QP_ATTR_DEFNS_QUALIFIER'
      ,context               =>p_QUALIFIER_rec.qualifier_context(I)
   	  ,attribute             =>p_QUALIFIER_rec.qualifier_attribute(I)
   	  -- Bug 5152088 Checking if Qualifier Attribute Value Code is valid
	  ,value                 =>p_QUALIFIER_rec.qualifier_attr_value(I)
      ,application_short_name=>'QP'
	  ,context_flag          =>l_context_error
	  ,attribute_flag        =>l_attribute_error
	  ,value_flag            =>l_value_error
	  ,datatype              =>l_datatype
	  ,precedence            =>l_precedence
	  ,error_code            =>l_error_code
   );

   IF l_error_code IS NULL THEN
      p_qualifier_rec.process_status_flag(I):=NULL;
      FND_MESSAGE.SET_NAME('QP','QP_ATTRIBUTE_REQUIRED');
      FND_MESSAGE.SET_TOKEN('ATTRIBUTE','QUALIFIER ATTRIBUTE CODE');
      QP_BULK_MSG.ADD(l_msg_rec);
   ELSE
      IF l_error_code=1 THEN
         qp_bulk_loader_pub.write_log('Qualifier Flexfield_name is not passed.');
         p_qualifier_rec.process_status_flag(I):=NULL;
         FND_MESSAGE.SET_NAME('QP','QP_QLF_FLXFLD_NULL');
         --FND_MESSAGE.SET_TOKEN('ATTRIBUTE','QUALIFIER ATTRIBUTE CODE');
         QP_BULK_MSG.ADD(l_msg_rec);
      ELSIF l_error_code=2 THEN
         qp_bulk_loader_pub.write_log('Qualifier Context is not passed');
         p_qualifier_rec.process_status_flag(I):=NULL;
         FND_MESSAGE.SET_NAME('QP','QP_QLF_CNTXT_NULL');
         --FND_MESSAGE.SET_TOKEN('ATTRIBUTE','QUALIFIER ATTRIBUTE CODE');
         QP_BULK_MSG.ADD(l_msg_rec);
      ELSIF l_error_code=3 THEN
         qp_bulk_loader_pub.write_log('Qualifier Attribute is not passed.');
         p_qualifier_rec.process_status_flag(I):=NULL;
         FND_MESSAGE.SET_NAME('QP','QP_QLF_ATTR_NULL');
         --FND_MESSAGE.SET_TOKEN('ATTRIBUTE','QUALIFIER ATTRIBUTE CODE');
         QP_BULK_MSG.ADD(l_msg_rec);
      ELSIF l_error_code=4 THEN
         qp_bulk_loader_pub.write_log('Qualifier Value is not passed');
         p_qualifier_rec.process_status_flag(I):=NULL;
         FND_MESSAGE.SET_NAME('QP','QP_QLF_ATTR_VAL_NULL');
         --FND_MESSAGE.SET_TOKEN('ATTRIBUTE','QUALIFIER ATTRIBUTE CODE');
         QP_BULK_MSG.ADD(l_msg_rec);
      ELSIF l_error_code=5 THEN
         qp_bulk_loader_pub.write_log('Qualifier Application short name is not passed');
         p_qualifier_rec.process_status_flag(I):=NULL;
         FND_MESSAGE.SET_NAME('QP','QP_QLF_APP_NAME_NULL');
         --FND_MESSAGE.SET_TOKEN('ATTRIBUTE','QUALIFIER ATTRIBUTE CODE');
         QP_BULK_MSG.ADD(l_msg_rec);
      ELSIF l_error_code=6 THEN
         qp_bulk_loader_pub.write_log('Qualifier Invalid application short name.');
         p_qualifier_rec.process_status_flag(I):=NULL;
         FND_MESSAGE.SET_NAME('QP','QP_QLF_INVALID_APP_NAME');
         --FND_MESSAGE.SET_TOKEN('ATTRIBUTE','QUALIFIER ATTRIBUTE CODE');
         QP_BULK_MSG.ADD(l_msg_rec);
      ELSIF l_error_code=7 THEN
         qp_bulk_loader_pub.write_log('Qualifier Invalid context passed');
         p_qualifier_rec.process_status_flag(I):=NULL;
         FND_MESSAGE.SET_NAME('QP','QP_QLF_INVALID_CNTXT');
         --FND_MESSAGE.SET_TOKEN('ATTRIBUTE','QUALIFIER ATTRIBUTE CODE');
         QP_BULK_MSG.ADD(l_msg_rec);
      ELSIF l_error_code=8 THEN
         qp_bulk_loader_pub.write_log('Qualifier Invalid Attribute passed');
         p_qualifier_rec.process_status_flag(I):=NULL;
         FND_MESSAGE.SET_NAME('QP','QP_QLF_INVALID_ATTRIB');
         --FND_MESSAGE.SET_TOKEN('ATTRIBUTE','QUALIFIER ATTRIBUTE CODE');
         QP_BULK_MSG.ADD(l_msg_rec);
      ELSIF l_error_code=9 THEN
         qp_bulk_loader_pub.write_log('Qualifier Value does not exist');
         p_qualifier_rec.process_status_flag(I):=NULL;
         FND_MESSAGE.SET_NAME('QP','QP_QLF_INVALID_ATTR_VAL');
         --FND_MESSAGE.SET_TOKEN('ATTRIBUTE','QUALIFIER ATTRIBUTE CODE');
         QP_BULK_MSG.ADD(l_msg_rec);
      ELSIF l_error_code=10 THEN
         qp_bulk_loader_pub.write_log('Qualifier Invalid Flexfield Name');
         p_qualifier_rec.process_status_flag(I):=NULL;
         FND_MESSAGE.SET_NAME('QP','QP_QLF_INVALID_FLXFLD_NAME');
         --FND_MESSAGE.SET_TOKEN('ATTRIBUTE','QUALIFIER ATTRIBUTE CODE');
         QP_BULK_MSG.ADD(l_msg_rec);
      END IF;
   END IF;
END IF;

--Bug 4929426 END RAVI

	qp_bulk_loader_pub.write_log( 'Qualifier_attr_val:'||p_qualifier_rec.qualifier_attr_value(I));
      -- Qualifier Attr Value To
       IF p_qualifier_rec.comparison_operator_code(I)= 'BETWEEN' AND
	  p_qualifier_rec.qualifier_attr_value_to(I) IS NULL 	THEN

	IF p_qualifier_rec.qualifier_attr_value_to_code(I) IS NULL THEN
	p_qualifier_rec.process_status_flag(I):=NULL;
	FND_MESSAGE.SET_NAME('QP','QP_ATTRIBUTE_REQUIRED');
        FND_MESSAGE.SET_TOKEN('ATTRIBUTE','QUALIFIER ATTRIBUTE VALUE TO');
        QP_BULK_MSG.ADD(l_msg_rec);
	ELSE

	   BEGIN
	      l_segment_name :=QP_PRICE_LIST_LINE_UTIL.Get_Segment_Name
			('QP_ATTR_DEFNS_QUALIFIER',
			 p_qualifier_rec.qualifier_context(I),
  			 p_qualifier_rec.qualifier_attribute(I));

	      QP_Value_To_ID.Flex_Meaning_To_Value_Id(
 		    p_flexfield_name => 'QP_ATTR_DEFNS_QUALIFIER',
 		    p_context => p_qualifier_rec.qualifier_context(I),
                    p_segment => l_segment_name,
	            p_meaning => p_qualifier_rec.qualifier_attr_value_to_code(I),
                    x_value => x_value,
             	    x_id => x_id,
 		    x_format_type => x_format_type);

	      IF x_id IS NOT NULL THEN
		 p_qualifier_rec.qualifier_attr_value_to(I) := x_id;
	      ELSE
		 p_qualifier_rec.qualifier_attr_value_to(I) := x_value;
	      END IF;

	      IF p_qualifier_rec.qualifier_attr_value_to(I) IS NULL THEN
	       p_qualifier_rec.process_status_flag(I):=NULL;
               FND_MESSAGE.SET_NAME('QP','QP_VALUE_TO_ID_ERROR');
               FND_MESSAGE.SET_TOKEN('ATTRIBUTE','qualifier_attr_value_to');
	       QP_BULK_MSG.add(l_msg_rec);
	      END IF;

	   EXCEPTION
	      WHEN NO_DATA_FOUND THEN
                p_qualifier_rec.process_status_flag(I):=NULL;
               FND_MESSAGE.SET_NAME('QP','QP_VALUE_TO_ID_ERROR');
               FND_MESSAGE.SET_TOKEN('ATTRIBUTE','qualifier_attr_value_to');
	       QP_BULK_MSG.ADD(l_msg_rec);

	   END;
	END IF;
     END IF;



    /*------ Performing required field validation for ----------------
         orig_sys_qualifier_ref.
     -------------------------------------------------------------*/
     IF p_qualifier_rec.orig_sys_qualifier_ref(I) IS NULL THEN
        p_qualifier_rec.process_status_flag(I):=NULL;
      	FND_MESSAGE.SET_NAME('QP','QP_ATTRIBUTE_REQUIRED');
        FND_MESSAGE.SET_TOKEN('ATTRIBUTE','ORIG_SYS_QUALIFIER_REF');
        QP_BULK_MSG.ADD(l_msg_rec);
     END IF;
     l_exist:=null;
     -- Check for uniqueness of orig_sys_qualifier_ref
     BEGIN
	Select  1 INTO l_exist
	  from qp_qualifiers
	 where orig_sys_qualifier_ref=p_qualifier_rec.orig_sys_qualifier_ref(I)
	   and orig_sys_header_ref = p_qualifier_rec.orig_sys_header_ref(I);
     EXCEPTION
	 WHEN NO_DATA_FOUND THEN
	    l_exist := 0;
     END;

     IF p_qualifier_rec.interface_action_code(I) = 'INSERT' AND l_exist =  1 THEN
	p_qualifier_rec.process_status_flag(I):=NULL;
	FND_MESSAGE.SET_NAME('QP', 'ORIG_SYS_QUAL_REF_NOT_UNIQUE');
        FND_MESSAGE.SET_TOKEN('REF_NO', p_qualifier_rec.orig_sys_qualifier_ref(I));
	QP_BULK_MSG.add(l_msg_rec);
     ELSIF p_qualifier_rec.interface_action_code(I) = 'UPDATE' AND l_exist = 0 THEN
	p_qualifier_rec.process_status_flag(I):=NULL;
	FND_MESSAGE.SET_NAME('QP', 'QUALIFIER_REC_DOES_NOT_EXIST');
        FND_MESSAGE.SET_TOKEN('REF_NO', p_qualifier_rec.orig_sys_qualifier_ref(I));
	QP_BULK_MSG.add(l_msg_rec);
     END IF;
     If p_qualifier_rec.interface_action_code(I)='INSERT' THEN
     l_exist:=null;
    	Select /*+ index(qp_interface_qualifiers QP_INTERFACE_QUALIFIERS_N3) */ --bug8359604
	  count(*) INTO l_exist
	  from qp_interface_qualifiers
	 where request_id = p_qualifier_rec.request_id(I)
	   and orig_sys_qualifier_ref=p_qualifier_rec.orig_sys_qualifier_ref(I)
	   and p_qualifier_rec.process_status_flag(I) ='P' --is null
           and orig_sys_header_ref = p_qualifier_rec.orig_sys_header_ref(I);

      IF l_exist >1 THEN
	p_qualifier_rec.process_status_flag(I):=NULL;
	FND_MESSAGE.SET_NAME('QP', 'ORIG_SYS_QUAL_REF_NOT_UNIQUE');
        FND_MESSAGE.SET_TOKEN('REF_NO', p_qualifier_rec.orig_sys_qualifier_ref(I));
	QP_BULK_MSG.add(l_msg_rec);
     END IF;
    end if;

     Begin
       select  list_header_id, active_flag
	into    p_qualifier_rec.list_header_id(I), p_qualifier_rec.active_flag(i)
	from    qp_list_headers_b
	where   orig_system_header_ref = p_qualifier_rec.orig_sys_header_ref(I);
     Exception
	When NO_DATA_FOUND then
	   p_qualifier_rec.process_status_flag(I):=NULL;
	   p_qualifier_rec.list_header_id(I) := -1;
	   fnd_message.set_name('QP', 'QP_INVALID_HEADER_REF');
           FND_MESSAGE.SET_TOKEN('REF_NO',NULL);
	   qp_bulk_msg.add(l_msg_rec);
     End;

 --SECONDARY PRICELIST CHECK
    qp_bulk_loader_pub.write_log( 'SECONDARY PRICELIST CHECK');
    IF p_qualifier_rec.qualifier_context(I) = 'MODLIST'
	AND p_qualifier_rec.qualifier_attribute(I) = 'QUALIFIER_ATTRIBUTE4' THEN

-- Bug 4926775 START RAVI
/**
The currency code for the primary and secondary price lists should be same. (Messages)
**/
	    BEGIN
	    SELECT qplh.list_header_id
	      INTO l_list_header_id
	      FROM QP_interface_list_headers qpilh, qp_list_headers qplh
          WHERE qplh.list_header_id = to_number(p_qualifier_rec.qualifier_attr_value(I))
	       AND qpilh.ORIG_SYS_HEADER_REF = p_qualifier_rec.ORIG_SYS_HEADER_REF(I)
           AND qplh.currency_code = qpilh.currency_code;
	    EXCEPTION
	       WHEN NO_DATA_FOUND THEN
	          qp_bulk_loader_pub.write_log( 'Secondary Price List Currency not compatible with primary price list currency code');
		  P_QUALIFIER_REC.PROCESS_STATUS_FLAG(I):= NULL; --'E';
		  FND_MESSAGE.SET_NAME('QP', 'QP_SEC_PRL_CCD_INVALID');
		  --FND_MESSAGE.SET_TOKEN('PRICELIST_NAME', p_qualifier_rec.qualifier_attr_value(I));
		  QP_BULK_MSG.ADD(l_msg_rec);
	    END;
-- Bug 4926775 END RAVI

	IF p_qualifier_rec.qualifier_attr_value(I) IS NULL THEN
	    qp_bulk_loader_pub.write_log( 'Secondary Price List read from qp_list_header');
	    BEGIN
	    SELECT to_char(list_header_id)
	      INTO p_qualifier_rec.qualifier_attr_value(I)
	      FROM QP_LIST_HEADERS_TL
	     WHERE NAME = p_qualifier_rec.qualifier_attr_value_code(I)
	       AND LANGUAGE = userenv('LANG');
	    EXCEPTION
	       WHEN NO_DATA_FOUND THEN
		  P_QUALIFIER_REC.PROCESS_STATUS_FLAG(I):= NULL; --'E';
		  FND_MESSAGE.SET_NAME('QP', 'SEC_PRL_ERROR');
		  FND_MESSAGE.SET_TOKEN('PRICELIST_NAME', p_qualifier_rec.qualifier_attr_value_code(I));
		  QP_BULK_MSG.ADD(l_msg_rec);
	    END;
	END IF;
	IF p_qualifier_rec.qualifier_attr_value(I) IS NOT NULL THEN
	    qp_bulk_loader_pub.write_log( 'Secondary Price List duplicate check');
	    l_exist:=0;
	    begin
	    select 1 into l_exist
	    from qp_qualifiers
	    where qualifier_context = 'MODLIST'
	    and qualifier_attribute = 'QUALIFIER_ATTRIBUTE4'
	    and qualifier_attr_value = to_number(p_qualifier_rec.qualifier_attr_value(I))
	    -- Bug# 5276935 RAVI
	    -- Chcek for duplication in the remaining qualifiers
            and orig_sys_qualifier_ref <> p_qualifier_rec.orig_sys_qualifier_ref(I)
	    and list_header_id = p_qualifier_rec.list_header_id(I);
	    exception
		when others then
			null;
	    end;
	    if l_exist = 0 then
	    qp_bulk_loader_pub.write_log( 'Secondary Price List dupl. checkin int. table');
		begin
		select 1 into l_exist
		from qp_interface_qualifiers
		where request_id = p_qualifier_rec.request_id(I)
		and orig_sys_header_ref = p_qualifier_rec.orig_sys_header_ref(I)
		and orig_sys_qualifier_ref <> p_qualifier_rec.orig_sys_qualifier_ref(I)
		and qualifier_context = 'MODLIST'
		and qualifier_attribute = 'QUALIFIER_ATTRIBUTE4'
	    	and qualifier_attr_value = p_qualifier_rec.qualifier_attr_value(I);
		exception
		    when others then
			    null;
		end;
	    end if;
	    if l_exist <> 0 then
		  P_QUALIFIER_REC.PROCESS_STATUS_FLAG(I):= NULL; --'E';
		  FND_MESSAGE.SET_NAME('QP','QP_INVALID_ATTRIBUTE');
		  FND_MESSAGE.SET_TOKEN('ATTRIBUTE',' Price List');
		  QP_BULK_MSG.ADD(l_msg_rec);
	    end if;
	    qp_bulk_loader_pub.write_log( 'Secondary Price List security check');
	      IF QP_security.check_function(p_function_name => QP_Security.G_FUNCTION_UPDATE,
					 p_instance_type => QP_Security.G_PRICELIST_OBJECT,
					 p_instance_pk1  => to_number(p_qualifier_rec.qualifier_attr_value(I))) <> 'T' THEN
		p_qualifier_rec.process_status_flag(I):=NULL;
		fnd_message.set_name('QP', 'QP_NO_PRIVILEGE');
		fnd_message.set_token('PRICING_OBJECT', 'Price List');
		qp_bulk_msg.add(l_msg_rec);
	       END IF;
        END IF;
    END IF;

-- Basic_Pricing_Condition
-- Secondary PricelIst check while basic pricing
   IF QP_BULK_LOADER_PUB.GET_QP_STATUS<>'I' THEN
    IF p_qualifier_rec.qualifier_context(I) = 'MODLIST'
	AND p_qualifier_rec.qualifier_attribute(I) = 'QUALIFIER_ATTRIBUTE4' THEN
     	   l_exist:=0;

	   SELECT count(*)
	   INTO	  l_exist
	   FROM   QP_SECONDARY_PRICE_LISTS_V
	   WHERE  parent_price_list_id = p_qualifier_rec.qualifier_attr_value(I);

    qp_bulk_loader_pub.write_log( 'l_exist='||l_exist);

	   IF l_exist > 0 THEN
	      P_QUALIFIER_REC.PROCESS_STATUS_FLAG(I):= NULL; --'E';
	      FND_MESSAGE.SET_NAME('QP','QP_1_SEC_PLST_FOR_BASIC');
	      --Only one secondary pricelist allowed in Basic Pricing
	      QP_BULK_MSG.ADD(l_msg_rec);
	   END IF;
	   l_exist:=0;
	   SELECT count(*)
	   INTO	l_exist
	   FROM	QP_INTERFACE_QUALIFIERS
	   WHERE QUALIFIER_CONTEXT = 'MODLIST'
	   AND	QUALIFIER_ATTRIBUTE = 'QUALIFIER_ATTRIBUTE4'
	   AND  request_id = p_qualifier_rec.request_id(I)
	   AND	(QUALIFIER_ATTR_VALUE = p_qualifier_rec.qualifier_attr_value(I)
	    OR	QUALIFIER_ATTR_VALUE_CODE = p_qualifier_rec.qualifier_attr_value_code(I));
	   IF l_exist > 1 THEN
	      P_QUALIFIER_REC.PROCESS_STATUS_FLAG(I):= NULL; --'E';
	      FND_MESSAGE.SET_NAME('QP','QP_1_SEC_PLST_FOR_BASIC');
	      --Only one secondary pricelist allowed in Basic Pricing
	      QP_BULK_MSG.ADD(l_msg_rec);
	   END IF;
    END IF;
   END IF;
 --check for the qualifier level
  IF p_qualifier_rec.process_status_flag(I) ='P' THEN --IS NOT NULL THEN
    BEGIN
       SELECT  f.segment_level
	 INTO  l_seg_level
	 FROM  qp_prc_contexts_b d,
	       qp_segments_b e,  qp_pte_segments f
	WHERE  d.prc_context_code =p_qualifier_rec.qualifier_context(I)
	  AND  e.segment_mapping_column = p_qualifier_rec.qualifier_attribute(I)
	  AND  d.prc_context_id = e.prc_context_id
	  AND  e.segment_id = f.segment_id
	  AND  f.pte_code = 'ORDFUL';

     IF l_seg_level = 'ORDER' THEN
	  P_QUALIFIER_REC.PROCESS_STATUS_FLAG(I):= NULL; --'E';
          FND_MESSAGE.SET_NAME('QP', 'QP_ORDER_LEVEL_QUAL_NOT_ALLOWED');
	  QP_BULK_MSG.ADD(l_msg_rec);
     END IF;

     EXCEPTION
	 WHEN NO_DATA_FOUND THEN
	    NULL;
     END;

  END IF;

  IF p_qualifier_rec.qualifier_precedence(I) IS NULL or
     p_qualifier_rec.qualifier_precedence(I) = 0 THEN
    QP_UTIL.validate_qp_flexfield(flexfield_name =>'QP_ATTR_DEFNS_QUALIFIER'
               ,context        =>p_qualifier_rec.qualifier_context(I)
               ,attribute      =>p_qualifier_rec.qualifier_attribute(I)
	       ,value          =>p_qualifier_rec.qualifier_attr_value(I)
                ,application_short_name         => 'QP'
                         ,context_flag           =>l_context_error
                         ,attribute_flag         =>l_attribute_error
                         ,value_flag             =>l_value_error
                         ,datatype               =>l_datatype
                         ,precedence              =>l_precedence
                         ,error_code             =>l_error_code
                         );

    If l_error_code = 0 Then
          p_qualifier_rec.qualifier_precedence(I) := l_precedence;
    end if;
  END IF;

--warning messages
  IF P_QUALIFIER_REC.PROCESS_STATUS_FLAG(I)='P' THEN --,'*')<> 'E' THEN
   qp_bulk_loader_pub.write_log('Entering Qualifier warnings');

    IF p_Qualifier_rec.qualifier_context(I) IS NOT NULL AND
       p_Qualifier_rec.qualifier_attribute(I) IS NOT NULL
    THEN
      qp_bulk_loader_pub.write_log('Context and Attribute OK ');
      QP_UTIL.Get_Context_Type('QP_ATTR_DEFNS_QUALIFIER',
                               p_Qualifier_rec.qualifier_context(I),
                               l_context_type,
                               l_error_code);

      IF l_error_code = 0 THEN --successfully returned context_type

        QP_UTIL.Get_Sourcing_Info(l_context_type,
                                  p_Qualifier_rec.qualifier_context(I),
                                  p_Qualifier_rec.qualifier_attribute(I),
                                  l_sourcing_enabled,
                                  l_sourcing_status,
                                  l_sourcing_method);

   	qp_bulk_loader_pub.write_log('Sourcing method / status / enabled'||l_sourcing_method||l_sourcing_status||l_sourcing_enabled);

        IF l_sourcing_method = 'ATTRIBUTE MAPPING' THEN

          IF l_sourcing_enabled <> 'Y' THEN

            FND_MESSAGE.SET_NAME('QP','QP_ENABLE_SOURCING');
            FND_MESSAGE.SET_TOKEN('CONTEXT',
                                  p_Qualifier_rec.qualifier_context(I));
            FND_MESSAGE.SET_TOKEN('ATTRIBUTE',
                                  p_Qualifier_rec.qualifier_attribute(I));
	    QP_BULK_MSG.ADD(l_msg_rec);

          END IF;

          IF l_sourcing_status <> 'Y' THEN

            IF NOT (
               p_qualifier_rec.qualifier_context(I)= 'MODLIST' AND
               p_qualifier_rec.qualifier_attribute(I) = 'QUALIFIER_ATTRIBUTE10')
            THEN
              FND_MESSAGE.SET_NAME('QP','QP_BUILD_SOURCING_RULES');
              FND_MESSAGE.SET_TOKEN('CONTEXT',
                                    p_Qualifier_rec.qualifier_context(I));
              FND_MESSAGE.SET_TOKEN('ATTRIBUTE',
                                    p_Qualifier_rec.qualifier_attribute(I));
	      QP_BULK_MSG.ADD(l_msg_rec);
            END IF;

          END IF;

        END IF; --If sourcing_method = 'ATTRIBUTE MAPPING'

      END IF; --l_error_code = 0

    END IF;--If qualifier_context and qualifier_attribute are NOT NULL

  END IF;
END LOOP;

 qp_bulk_loader_pub.write_log('Leaving Entity qualifier validation');

 EXCEPTION
    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
       qp_bulk_loader_pub.write_log( 'UNEXCPECTED ERROR IN PROCEDURE ENTITY_QUALIFIER:'||sqlerrm);
       RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    WHEN OTHERS THEN
       qp_bulk_loader_pub.write_log( 'UNEXCPECTED ERROR IN PROCEDURE ENTITY_QUALIFIER:'||sqlerrm);
       RAISE FND_API.G_EXC_UNEXPECTED_ERROR;


END ENTITY_QUALIFIER;

PROCEDURE ENTITY_PRICING_ATTR
          (p_pricing_attr_rec IN OUT  NOCOPY QP_BULK_LOADER_PUB.pricing_attr_rec_type)
IS
   l_msg_rec QP_BULK_MSG.Msg_Rec_Type;
   l_exist NUMBER;
   l_exist1 NUMBER;
   l_comparison_operator_code VARCHAR2(30);
   l_error_code NUMBER;
   l_precedence NUMBER;
   l_datatype FND_FLEX_VALUE_SETS.Format_type%TYPE;
   l_value_error                 VARCHAR2(1);
   l_context_error               VARCHAR2(1);
   l_attribute_error             VARCHAR2(1);
   l_primary_uom_flag            VARCHAR2(1);
   l_count                       NUMBER;
   l_count1                      NUMBER;
   l_msg_txt                     VARCHAR2(2000);
   l_status                      VARCHAR2(20);
   l_status1                     VARCHAR2(20);
   l_pricing_attribute_id        NUMBER;
   l_old_pricing_attr_rec        QP_Price_List_PUB.Pricing_Attr_Rec_Type;
   l_availability_in_basic	VARCHAR2(1);
   l_pricing_attr_flex_enabled VARCHAR2(1);
   l_pte_code VARCHAR2(30);

l_context_type                VARCHAR2(30);
l_sourcing_enabled            VARCHAR2(1);
l_sourcing_status             VARCHAR2(1);
l_sourcing_method             VARCHAR2(30);

l_ss_code                     VARCHAR2(30);
l_fna_name                    VARCHAR2(4000);
l_fna_desc                    VARCHAR2(489);
l_fna_valid                   BOOLEAN;

--ENH Continuous Price Break START RAVI
l_old_break_pa_count NUMBER := -1;
l_new_break_pa_count NUMBER := -1;
l_new_break_low_value NUMBER := -1;
l_new_break_high_value NUMBER := -1;
l_old_break_low_value NUMBER := -1;
l_old_break_high_value NUMBER := -1;
l_break_high_value NUMBER := -1;
l_to_value_old NUMBER := -1;
l_to_value_new NUMBER := -1;
l_from_value_old NUMBER := -1;
l_from_value_new NUMBER := -1;
--ENH Continuous Price Break END RAVI

-- Bug# 5246745 RAVI
l_pa_count NUMBER := 0;


-- Bug# 5440851 RAVI
l_pa_from_val_tmp NUMBER := 0;
l_pa_to_val_tmp   NUMBER := 0;

-- Bug# 5528754
-- Local variable to store price break or price list line
l_pa_price_break VARCHAR2(30):='PRICE LIST LINE';

Cursor C_break_lines(p_orig_sys_line_ref VARCHAR2,
                     -- Bug 5246745 Use Composite Index for Ref columns
                     p_orig_sys_header_ref VARCHAR2) IS
--ENH Continuous Price Break RAVI
/**
Check for overlap of price breaks
**/
       SELECT  'OVERLAP'
          FROM   qp_list_lines la,
		 qp_rltd_modifiers ra,
                 qp_rltd_modifiers rb,
                 qp_interface_pricing_attribs pa,
                 qp_pricing_attributes pb
       WHERE  la.orig_sys_line_ref = p_orig_sys_line_ref
       -- Bug 5246745 Use Composite Index for Ref columns
       AND    la.orig_sys_header_ref = p_orig_sys_header_ref
       AND    ra.to_rltd_modifier_id = la.list_line_id
       AND    ra.rltd_modifier_grp_type = 'PRICE BREAK'
       -- Got Price Break Line
       AND    ra.from_rltd_modifier_id = rb.from_rltd_modifier_id
       AND    ra.to_rltd_modifier_id <> rb.to_rltd_modifier_id
       -- Got Remaining Price Break Lines
       AND    pa.orig_sys_line_ref = la.orig_sys_line_ref
       -- Got Price Break Line New Values
       AND    rb.to_rltd_modifier_id = pb.list_line_id
       -- Got Remaining Price Break Lines Values
       -- Bug# 5236432 RAVI
       AND pb.orig_sys_pricing_attr_ref NOT IN (
                select pia.orig_sys_pricing_attr_ref
                from qp_interface_pricing_attribs pia
                where pia.orig_sys_header_ref=pb.orig_sys_header_ref
                and pia.orig_sys_line_ref=pb.orig_sys_line_ref
           )
       -- Got the remaining Price Break Lines that are not being updated in this request
       AND (
             ( qp_number.canonical_to_number(pa.pricing_attr_value_from) >=
                 qp_number.canonical_to_number(pa.pricing_attr_value_to)
             ) -- New Price Break To is greater than (or equal to) New Price Break From
             OR
             ( qp_number.canonical_to_number(pa.pricing_attr_value_from) <
                 qp_number.canonical_to_number(pb.pricing_attr_value_to)
               AND qp_number.canonical_to_number(pa.pricing_attr_value_from) >=
                   qp_number.canonical_to_number(pb.pricing_attr_value_from)
             ) -- New Price Break From in between Old Price Break
             OR
             ( qp_number.canonical_to_number(pa.pricing_attr_value_to) <=
                 qp_number.canonical_to_number(pb.pricing_attr_value_to)
               AND qp_number.canonical_to_number(pa.pricing_attr_value_to) >
                  qp_number.canonical_to_number(pb.pricing_attr_value_from)
             ) -- New Price Break To in between Old Price Break
             OR
             ( qp_number.canonical_to_number(pa.pricing_attr_value_from) <
                 qp_number.canonical_to_number(pb.pricing_attr_value_from)
               AND qp_number.canonical_to_number(pa.pricing_attr_value_to) >
                  qp_number.canonical_to_number(pb.pricing_attr_value_to)
             ) -- Old Price Break in between New Price Break
           );

Cursor C_old_cont_grp_break_line(p_orig_sys_line_ref VARCHAR2,
                     -- Bug 5246745 Use Composite Index for Ref columns
                     p_orig_sys_header_ref VARCHAR2) IS
--ENH Continuous Price Break RAVI
/**
Count of old price breaks
**/
       SELECT  count(*) old_break_pa_count,
               min(to_number(pb.pricing_attr_value_from)) new_break_low_value,
               max(to_number(pb.pricing_attr_value_to)) new_break_high_value
          FROM   qp_list_lines la,
		 qp_rltd_modifiers ra,
                 qp_rltd_modifiers rb,
                 qp_interface_pricing_attribs pa,
                 qp_pricing_attributes pb
       WHERE  la.orig_sys_line_ref = p_orig_sys_line_ref
       -- Bug 5246745 Use Composite Index for Ref columns
       AND    la.orig_sys_header_ref = p_orig_sys_header_ref
       AND    ra.to_rltd_modifier_id = la.list_line_id
       AND    ra.rltd_modifier_grp_type = 'PRICE BREAK'
       -- Got Price Break Line
       AND    ra.from_rltd_modifier_id = rb.from_rltd_modifier_id
       AND    ra.to_rltd_modifier_id <> rb.to_rltd_modifier_id
       -- Got Remaining Price Break Lines
       AND    pa.orig_sys_line_ref = la.orig_sys_line_ref
       -- Got Price Break Line New Values
       AND    rb.to_rltd_modifier_id = pb.list_line_id;
       -- Got Remaining Price Break Lines Values

--ENH Continuous Price Break RAVI
/**
Count of new price breaks
**/
Cursor C_new_cont_grp_break_lines(p_orig_sys_line_ref VARCHAR2,
                     -- Bug 5246745 Use Composite Index for Ref columns
                     p_orig_sys_header_ref VARCHAR2) IS
       SELECT  count(*) new_break_pa_count,
               min(to_number(pb.pricing_attr_value_from)) new_break_low_value,
               max(to_number(pb.pricing_attr_value_to)) new_break_high_value
          FROM   qp_list_lines la,
	         qp_list_lines lb,
		 qp_rltd_modifiers ra,
                 qp_rltd_modifiers rb,
                 qp_interface_pricing_attribs pa,
                 qp_interface_pricing_attribs pb
       WHERE  la.orig_sys_line_ref = p_orig_sys_line_ref
       -- Bug 5246745 Use Composite Index for Ref columns
       AND    la.orig_sys_header_ref = p_orig_sys_header_ref
       AND    ra.to_rltd_modifier_id = la.list_line_id
       AND    ra.from_rltd_modifier_id = rb.from_rltd_modifier_id
       AND    pa.orig_sys_line_ref = la.orig_sys_line_ref
       AND    rb.to_rltd_modifier_id = lb.list_line_id
       AND    pb.orig_sys_line_ref = lb.orig_sys_line_ref
       AND    ra.rltd_modifier_grp_type = 'PRICE BREAK'
       AND    ra.to_rltd_modifier_id <> rb.to_rltd_modifier_id;

--ENH Continuous Price Break RAVI
/**
Count of Old Price Breaks with Same From value
**/
Cursor C_from_value_old(p_orig_sys_line_ref VARCHAR2,
                     -- Bug 5246745 Use Composite Index for Ref columns
                     p_orig_sys_header_ref VARCHAR2) IS
       SELECT  count(*) l_from_value_old
          FROM   qp_list_lines la,
		 qp_rltd_modifiers ra,
                 qp_rltd_modifiers rb,
                 qp_interface_pricing_attribs pa,
                 qp_pricing_attributes pb
       WHERE  la.orig_sys_line_ref = p_orig_sys_line_ref
       -- Bug 5246745 Use Composite Index for Ref columns
       AND    la.orig_sys_header_ref = p_orig_sys_header_ref
       AND    ra.to_rltd_modifier_id = la.list_line_id
       AND    ra.rltd_modifier_grp_type = 'PRICE BREAK'
       -- Got Price Break Line
       AND    ra.from_rltd_modifier_id = rb.from_rltd_modifier_id
       AND    ra.to_rltd_modifier_id <> rb.to_rltd_modifier_id
       -- Got Remaining Price Break Lines
       AND    pa.orig_sys_line_ref = la.orig_sys_line_ref
       -- Got Price Break Line New Values
       AND    rb.to_rltd_modifier_id = pb.list_line_id
       -- Got Remaining Price Break Lines Values
       AND    pa.pricing_attr_value_from=pb.pricing_attr_value_to;

--ENH Continuous Price Break RAVI
/**
Count of new Price Breaks with Same From value
**/
Cursor C_from_value_new(p_orig_sys_line_ref VARCHAR2,
                     -- Bug 5246745 Use Composite Index for Ref columns
                     p_orig_sys_header_ref VARCHAR2) IS
       SELECT  count(*) l_from_value_new
          FROM   qp_list_lines la,
	         qp_list_lines lb,
		 qp_rltd_modifiers ra,
                 qp_rltd_modifiers rb,
                 qp_interface_pricing_attribs pa,
                 qp_interface_pricing_attribs pb
       WHERE  la.orig_sys_line_ref = p_orig_sys_line_ref
       -- Bug 5246745 Use Composite Index for Ref columns
       AND    la.orig_sys_header_ref = p_orig_sys_header_ref
       AND    ra.to_rltd_modifier_id = la.list_line_id
       AND    ra.from_rltd_modifier_id = rb.from_rltd_modifier_id
       AND    pa.orig_sys_line_ref = la.orig_sys_line_ref
       AND    rb.to_rltd_modifier_id = lb.list_line_id
       AND    pb.orig_sys_line_ref = lb.orig_sys_line_ref
       AND    ra.rltd_modifier_grp_type = 'PRICE BREAK'
       AND    ra.to_rltd_modifier_id <> rb.to_rltd_modifier_id
       AND    pa.pricing_attr_value_from=pb.pricing_attr_value_to;

--ENH Continuous Price Break RAVI
/**
Count of Old Price Breaks with Same to value
**/
Cursor C_to_value_old(p_orig_sys_line_ref VARCHAR2,
                     -- Bug 5246745 Use Composite Index for Ref columns
                     p_orig_sys_header_ref VARCHAR2) IS
       SELECT  count(*) l_to_value_old
          FROM   qp_list_lines la,
		 qp_rltd_modifiers ra,
                 qp_rltd_modifiers rb,
                 qp_interface_pricing_attribs pa,
                 qp_pricing_attributes pb
       WHERE  la.orig_sys_line_ref = p_orig_sys_line_ref
       -- Bug 5246745 Use Composite Index for Ref columns
       AND    la.orig_sys_header_ref = p_orig_sys_header_ref
       AND    ra.to_rltd_modifier_id = la.list_line_id
       AND    ra.rltd_modifier_grp_type = 'PRICE BREAK'
       -- Got Price Break Line
       AND    ra.from_rltd_modifier_id = rb.from_rltd_modifier_id
       AND    ra.to_rltd_modifier_id <> rb.to_rltd_modifier_id
       -- Got Remaining Price Break Lines
       AND    pa.orig_sys_line_ref = la.orig_sys_line_ref
       -- Got Price Break Line New Values
       AND    rb.to_rltd_modifier_id = pb.list_line_id
       -- Got Remaining Price Break Lines Values
       AND    pa.pricing_attr_value_to=pb.pricing_attr_value_from;

--ENH Continuous Price Break RAVI
/**
Count of new Price Breaks with Same to value
**/
Cursor C_to_value_new(p_orig_sys_line_ref VARCHAR2,
                     -- Bug 5246745 Use Composite Index for Ref columns
                     p_orig_sys_header_ref VARCHAR2) IS
       SELECT  count(*) l_to_value_new
          FROM   qp_list_lines la,
	         qp_list_lines lb,
		 qp_rltd_modifiers ra,
                 qp_rltd_modifiers rb,
                 qp_interface_pricing_attribs pa,
                 qp_interface_pricing_attribs pb
       WHERE  la.orig_sys_line_ref = p_orig_sys_line_ref
       -- Bug 5246745 Use Composite Index for Ref columns
       AND    la.orig_sys_header_ref = p_orig_sys_header_ref
       AND    ra.to_rltd_modifier_id = la.list_line_id
       AND    ra.from_rltd_modifier_id = rb.from_rltd_modifier_id
       AND    pa.orig_sys_line_ref = la.orig_sys_line_ref
       AND    rb.to_rltd_modifier_id = lb.list_line_id
       AND    pb.orig_sys_line_ref = lb.orig_sys_line_ref
       AND    ra.rltd_modifier_grp_type = 'PRICE BREAK'
       AND    ra.to_rltd_modifier_id <> rb.to_rltd_modifier_id
       AND    pa.pricing_attr_value_to=pb.pricing_attr_value_from;

Cursor C_Int_break_lines(p_orig_sys_line_ref VARCHAR2,
                     -- Bug 5246745 Use Composite Index for Ref columns
                     p_orig_sys_header_ref VARCHAR2,
                     p_request_id number) IS   -- changes done by rassharm for bug no 6028305
       SELECT  /*+ leading(la) index(pa QP_INTERFACE_PRCNG_ATTRIBS_N4) index(pb QP_INTERFACE_PRCNG_ATTRIBS_N4) */ --7433219
       'OVERLAP'
          FROM   qp_list_lines la,
	         qp_list_lines lb,
		 qp_rltd_modifiers ra,
                 qp_rltd_modifiers rb,
                 qp_interface_pricing_attribs pa,
                 qp_interface_pricing_attribs pb
       WHERE  la.orig_sys_line_ref = p_orig_sys_line_ref
       -- Bug 5246745 Use Composite Index for Ref columns
       AND    la.orig_sys_header_ref = p_orig_sys_header_ref
       AND    ra.to_rltd_modifier_id = la.list_line_id
       AND    ra.from_rltd_modifier_id = rb.from_rltd_modifier_id
       AND    pa.orig_sys_line_ref = la.orig_sys_line_ref
       AND    rb.to_rltd_modifier_id = lb.list_line_id
       AND    pb.orig_sys_line_ref = lb.orig_sys_line_ref
       AND    ra.rltd_modifier_grp_type = 'PRICE BREAK'
       AND    ra.to_rltd_modifier_id <> rb.to_rltd_modifier_id
	AND    nvl(pa.pricing_attribute_datatype,'N') = 'N'
       -- changes done by rassharm for bug no 6028305
       AND pa.request_id=p_request_id
       AND pb.request_id=p_request_id
       -- end changes

       AND    (qp_number.canonical_to_number(pa.pricing_attr_value_from) < -- 4713369
                  qp_number.canonical_to_number(pb.pricing_attr_value_to)      AND
                     qp_number.canonical_to_number(pa.pricing_attr_value_from) >=
                     qp_number.canonical_to_number(pb.pricing_attr_value_from)
                     OR
                        qp_number.canonical_to_number(pa.pricing_attr_value_to) <=
                  qp_number.canonical_to_number(pb.pricing_attr_value_to)      AND
                     qp_number.canonical_to_number(pa.pricing_attr_value_to) >
                     qp_number.canonical_to_number(pb.pricing_attr_value_from)
                     OR
                        qp_number.canonical_to_number(pa.pricing_attr_value_from) <=
                  qp_number.canonical_to_number(pb.pricing_attr_value_from)    AND
                     qp_number.canonical_to_number(pa.pricing_attr_value_to) >=
                     qp_number.canonical_to_number(pb.pricing_attr_value_to));

BEGIN
qp_bulk_loader_pub.write_log('Entering Entity pricing attribute validation');
FND_PROFILE.GET('QP_PRICING_TRANSACTION_ENTITY',l_pte_code);

FOR I IN 1..p_pricing_attr_rec.orig_sys_pricing_attr_ref.COUNT
LOOP

--Initially setting the message context.

l_msg_rec.REQUEST_ID := P_PRICING_ATTR_REC.REQUEST_ID(I);
l_msg_rec.ENTITY_TYPE := 'PRL';
l_msg_rec.TABLE_NAME := 'QP_INTERFACE_PRICING_ATTRIBS';
l_msg_rec.ORIG_SYS_HEADER_REF := p_pricing_attr_rec.orig_sys_header_ref(I);
l_msg_rec.ORIG_SYS_LINE_REF := p_pricing_attr_rec.orig_sys_line_ref(I);
l_msg_rec.ORIG_SYS_QUALIFIER_REF := NULL;
l_msg_rec.ORIG_SYS_PRICING_ATTR_REF := p_pricing_attr_rec.orig_sys_pricing_attr_ref(I);

 qp_bulk_loader_pub.write_log('Inside entity pricing attr');
-- Internal field population
--List Line ID
 BEGIN
 select list_line_id
   into p_pricing_attr_rec.list_line_id(I)
   from qp_list_lines
  where orig_sys_line_ref = p_pricing_attr_rec.orig_sys_line_ref(I)
    and orig_sys_header_ref  = p_pricing_attr_rec.orig_sys_header_ref(I);

 EXCEPTION
     WHEN NO_DATA_FOUND THEN
	p_pricing_attr_rec.list_line_id(I) := -1;
        p_pricing_attr_rec.process_status_flag(I):=NULL;
	fnd_message.set_name('QP', 'QP_INVALID_LINE_REF');
        FND_MESSAGE.SET_TOKEN('REF_NO', p_pricing_attr_rec.orig_sys_line_ref(I));
        qp_bulk_msg.add(l_msg_rec);
 END;
 qp_bulk_loader_pub.write_log('After entity list_line_id pricing attribute');


 -- Bug# 5246745 RAVI START
 --2 If org is Purchasing or PO then the item must be Purchasable or Orderable.
 IF p_pricing_attr_rec.product_attribute_context(I)='ITEM' AND
    p_pricing_attr_rec.product_attribute(I)= 'PRICING_ATTRIBUTE1'
 THEN
    l_pa_count :=0;
    IF fnd_global.resp_appl_id=178 OR fnd_global.resp_appl_id=201
    THEN --Check if item is purchasing enabled
       Begin
          select count(*) into l_pa_count
          from qp_interface_pricing_attribs qipa, mtl_system_items msi
          where qipa.orig_sys_pricing_attr_ref = p_pricing_attr_rec.orig_sys_pricing_attr_ref(I)
          and qipa.request_id = P_PRICING_ATTR_REC.REQUEST_ID(I)
          and qipa.product_attribute_context = 'ITEM'
          and qipa.product_attribute = 'PRICING_ATTRIBUTE1'
          and msi.inventory_item_id = to_number(qipa.PRODUCT_ATTR_VALUE)
          and msi.organization_id = fnd_profile.value('QP_ORGANIZATION_ID')
          and msi.purchasing_enabled_flag = 'Y'
          and qipa.interface_action_code in ('INSERT','UPDATE');
       Exception
          when NO_DATA_FOUND then
             l_pa_count := 0;
       End;
    ELSE --Check if item is orderable
       Begin
          select count(*) into l_pa_count
          from qp_interface_pricing_attribs qipa, mtl_system_items msi
          where qipa.orig_sys_pricing_attr_ref = p_pricing_attr_rec.orig_sys_pricing_attr_ref(I)
          and qipa.request_id = P_PRICING_ATTR_REC.REQUEST_ID(I)
          and qipa.product_attribute_context = 'ITEM'
          and qipa.product_attribute = 'PRICING_ATTRIBUTE1'
          and msi.inventory_item_id = to_number(qipa.PRODUCT_ATTR_VALUE)
          and msi.organization_id = fnd_profile.value('QP_ORGANIZATION_ID')
          and msi.CUSTOMER_ORDER_flag = 'Y'
          and qipa.interface_action_code in ('INSERT','UPDATE');
       Exception
          when NO_DATA_FOUND then
             l_pa_count := 0;
       End;
    END IF;
    if l_pa_count=0 then
       p_pricing_attr_rec.process_status_flag(I):=NULL;
       FND_MESSAGE.SET_NAME('QP', 'QP_INVALID_ATTRIBUTE');
       fnd_message.set_token('ATTRIBUTE', 'PRODUCT_ATTRIBUTE_VALUE');
       qp_bulk_msg.add(l_msg_rec);
    end if;
 END IF;
 -- Bug# 5246745 RAVI END

  --list_header_id

 BEGIN
 select list_header_id
   into p_pricing_attr_rec.list_header_id(I)
   from qp_list_headers_b
  where orig_system_header_ref = p_pricing_attr_rec.orig_sys_header_ref(I);
 EXCEPTION
     WHEN NO_DATA_FOUND THEN
	p_pricing_attr_rec.list_header_id(I) := -1;
        p_pricing_attr_rec.process_status_flag(I):=NULL;
	fnd_message.set_name('QP', 'QP_INVALID_HEADER_REF');
        FND_MESSAGE.SET_TOKEN('REF_NO', p_pricing_attr_rec.orig_sys_header_ref(I));
        FND_MESSAGE.SET_TOKEN('LS_CODE', NULL);
        qp_bulk_msg.add(l_msg_rec);
 END;

  -- Excluder Flag
 p_pricing_attr_rec.excluder_flag(I):='N';
 p_pricing_attr_rec.accumulate_flag(I):='N';

 -- Attribute Grouping No

 IF p_pricing_attr_rec.interface_action_code(I) = 'INSERT' THEN
     Select qp_pricing_attr_group_no_s.nextval
       into p_pricing_attr_rec.attribute_grouping_no(I)
       from dual;
 END IF;

 p_pricing_attr_rec.pricing_phase_id(I):=1;

 -- Check for the uniqueness of orig_sys_pricing_attr_ref
 l_exist:=null;
 BEGIN
      SELECT 1,pricing_attribute_id INTO l_exist,l_pricing_attribute_id
	FROM qp_pricing_attributes
       WHERE orig_sys_pricing_attr_ref = p_pricing_attr_rec.orig_sys_pricing_attr_ref(I)
         AND orig_sys_line_ref = p_pricing_attr_rec.orig_sys_line_ref(I)
         AND orig_sys_header_ref =  p_pricing_attr_rec.orig_sys_header_ref(I);
 EXCEPTION
 WHEN NO_DATA_FOUND THEN
    l_exist:=0;
 END;

 IF p_pricing_attr_rec.interface_action_code(I) = 'INSERT' AND l_exist = 1 THEN
        p_pricing_attr_rec.process_status_flag(I):=NULL;
	fnd_message.set_name('QP', 'ORIG_SYS_PRC_ATTR_REF_NOT_UNIQ');
        FND_MESSAGE.SET_TOKEN('REF_NO', p_pricing_attr_rec.orig_sys_pricing_attr_ref(I));
        qp_bulk_msg.add(l_msg_rec);
 ELSIF p_pricing_attr_rec.interface_action_code(I) = 'UPDATE' AND l_exist = 0 THEN
        p_pricing_attr_rec.process_status_flag(I):=NULL;
	fnd_message.set_name('QP', 'PRC_ATTR_REC_DOES_NOT_EXIST');
        FND_MESSAGE.SET_TOKEN('REF_NO', p_pricing_attr_rec.orig_sys_pricing_attr_ref(I));
        qp_bulk_msg.add(l_msg_rec);
 END IF;

 IF p_pricing_attr_rec.interface_action_code(I) = 'INSERT' THEN
  l_exist:=null;
  BEGIN
      SELECT count(*) INTO l_exist
	FROM qp_interface_pricing_attribs
       WHERE request_id = p_pricing_attr_rec.request_id(I)
	 AND orig_sys_pricing_attr_ref = p_pricing_attr_rec.orig_sys_pricing_attr_ref(I)
	 AND orig_sys_line_ref = p_pricing_attr_rec.orig_sys_line_ref(I)
         AND orig_sys_header_ref =  p_pricing_attr_rec.orig_sys_header_ref(I);

 EXCEPTION
 WHEN NO_DATA_FOUND THEN
    l_exist:=0;
 END;

 IF l_exist > 1 THEN
        p_pricing_attr_rec.process_status_flag(I):=NULL;
	fnd_message.set_name('QP', 'ORIG_SYS_PRC_ATTR_REF_NOT_UNIQ');
        FND_MESSAGE.SET_TOKEN('REF_NO', p_pricing_attr_rec.orig_sys_pricing_attr_ref(I));
        qp_bulk_msg.add(l_msg_rec);
 END IF;
 END IF;

     -- Functional Area Validation for Hierarchical Categories (sfiresto)
    IF p_PRICING_ATTR_rec.product_attribute_context(I) = 'ITEM' AND
       p_PRICING_ATTR_rec.product_attribute(I) = 'PRICING_ATTRIBUTE2' THEN
        BEGIN

          SELECT nvl(pte_code, fnd_profile.value('QP_PRICING_TRANSACTION_ENTITY')),
                 nvl(source_system_code, fnd_profile.value('QP_SOURCE_SYSTEM_CODE'))
          INTO l_pte_code, l_ss_code
          FROM qp_interface_list_headers
          WHERE orig_sys_header_ref = p_PRICING_ATTR_rec.orig_sys_header_ref(I);

          QP_UTIL.Get_Item_Cat_Info(
             p_PRICING_ATTR_rec.product_attr_value(I),
             l_pte_code,
             l_ss_code,
             l_fna_name,
             l_fna_desc,
             l_fna_valid);

          IF NOT l_fna_valid THEN

            P_PRICING_ATTR_REC.process_status_flag(I):=NULL;

            FND_MESSAGE.set_name('QP', 'QP_INVALID_CAT_FUNC_PTE');
            FND_MESSAGE.set_token('CATID', p_PRICING_ATTR_REC.product_attr_value(I));
            FND_MESSAGE.set_token('PTE', l_pte_code);
            FND_MESSAGE.set_token('SS', l_ss_code);
            QP_BULK_MSG.Add(L_MSG_REC);

          END IF;

        END;
    END IF;

 ----- Getting product_attribute_datatype -----
 QP_UTIL.GET_PROD_FLEX_PROPERTIES(p_pricing_attr_rec.product_attribute_context(I),
				  p_pricing_attr_rec.product_attribute(I),
				  p_pricing_attr_rec.product_attr_value(I),
				  l_datatype,
				  l_precedence,
				  l_error_code);
 IF l_datatype IS NOT NULL THEN
    p_pricing_attr_rec.product_attribute_datatype(I):=l_datatype;
 ELSE
    p_pricing_attr_rec.process_status_flag(I):=NULL;
    fnd_message.set_name('QP', 'QP_ATTRIBUTE_REQUIRED');
    FND_MESSAGE.SET_TOKEN('ATTRIBUTE','Product Attribute Datatype');
    qp_bulk_msg.add(l_msg_rec);
 END IF;

  qp_bulk_loader_pub.write_log('After entity pricing attribute');

-- product uom code

 IF P_PRICING_ATTR_REC.PRODUCT_UOM_CODE(I) IS NULL THEN
    P_PRICING_ATTR_REC.process_status_flag(I):=NULL;
    FND_MESSAGE.SET_NAME('QP','QP_ATTRIBUTE_REQUIRED');
    FND_MESSAGE.SET_TOKEN('ATTRIBUTE',QP_PRC_UTIL.Get_Attribute_Name('PRODUCT_UOM_CODE'));
    QP_BULK_MSG.ADD(L_MSG_REC);
 END IF;


 --- check for single pricing_attribute record with pricing context/attr/value null
  qp_bulk_loader_pub.write_log('Pricing attr ref' || p_pricing_attr_rec.orig_sys_pricing_attr_ref(I));
  IF p_pricing_attr_rec.pricing_attribute_context(I) IS NULL
    OR p_pricing_attr_rec.pricing_attribute(I) IS NULL THEN
     l_exist := 0;
     BEGIN
	SELECT count(*) INTO l_exist
	  FROM qp_pricing_attributes
	 WHERE orig_sys_line_ref = p_pricing_attr_rec.orig_sys_line_ref(I)
	   AND orig_sys_header_ref = p_pricing_attr_rec.orig_sys_header_ref(I)
	   AND pricing_attribute_context IS NULL
           AND pricing_attribute IS NULL
           AND orig_sys_pricing_attr_ref <> p_pricing_attr_rec.orig_sys_pricing_attr_ref(I)
           AND (pricing_attr_value_from IS NULL OR pricing_Attr_value_to IS NULL);
      EXCEPTION
	 WHEN NO_DATA_FOUND THEN
	    l_exist := 0;
      END;

      qp_bulk_loader_pub.write_log('Count of records in Pricing Attr table with pricing contect/attr/value null' || to_char(l_exist));
      l_exist1:=null;
      BEGIN
	SELECT count(*) INTO l_exist1
	  FROM qp_interface_pricing_attribs
	 WHERE request_id = p_pricing_attr_rec.request_id(I)
	   AND orig_sys_line_ref = p_pricing_attr_rec.orig_sys_line_ref(I)
	   AND orig_sys_header_ref = p_pricing_attr_rec.orig_sys_header_ref(I)
	    AND orig_sys_pricing_attr_ref <> p_pricing_attr_rec.orig_sys_pricing_attr_ref(I)
	   AND pricing_attribute_context IS NULL
           AND pricing_attribute IS NULL
           AND (pricing_attr_value_from IS NULL OR pricing_attr_value_to IS NULL);
      EXCEPTION
	 WHEN NO_DATA_FOUND THEN
	    l_exist1 := 0;
      END;

      qp_bulk_loader_pub.write_log('Count of records in Int table with pricing contect/attr/value null' || to_char(l_exist1));
      IF l_exist > 0 THEN
	 p_pricing_attr_rec.process_status_flag(I):=NULL;
	 FND_MESSAGE.SET_NAME('QP','QP_BULK_PRC_ATTR_ERROR');
	 QP_BULK_MSG.ADD(l_msg_rec);
      END IF;
      IF l_exist1 > 0 THEN
	 p_pricing_attr_rec.process_status_flag(I):=NULL;
	 FND_MESSAGE.SET_NAME('QP','QP_BULK_INT_PRC_ATTR_ERROR');
	 QP_BULK_MSG.ADD(l_msg_rec);
      END IF;

    END IF;

-- Basic_Pricing_Condition
    IF QP_BULK_LOADER_PUB.GET_QP_STATUS <> 'I' THEN
      IF p_pricing_attr_rec.pricing_attribute_context(I) IS NOT NULL
	AND p_pricing_attr_rec.pricing_attribute(I) IS NOT NULL THEN
	 l_exist := 0;
	 BEGIN
	    SELECT count(*) INTO l_exist
	      FROM qp_pricing_attributes
	     WHERE orig_sys_line_ref = p_pricing_attr_rec.orig_sys_line_ref(I)
	       AND orig_sys_header_ref = p_pricing_attr_rec.orig_sys_header_ref(I)
	       AND pricing_attribute_context <> p_pricing_attr_rec.pricing_attribute_context(I)
	       AND orig_sys_pricing_attr_ref <> p_pricing_attr_rec.orig_sys_pricing_attr_ref(I);
	  EXCEPTION
	     WHEN NO_DATA_FOUND THEN
		l_exist := 0;
	  END;

	  l_exist1:=null;
	  BEGIN
	    SELECT count(*) INTO l_exist1
	      FROM qp_interface_pricing_attribs
	     WHERE request_id = p_pricing_attr_rec.request_id(I)
	       AND orig_sys_line_ref = p_pricing_attr_rec.orig_sys_line_ref(I)
	       AND orig_sys_header_ref = p_pricing_attr_rec.orig_sys_header_ref(I)
		AND orig_sys_pricing_attr_ref <> p_pricing_attr_rec.orig_sys_pricing_attr_ref(I)
	       AND pricing_attribute_context <> p_pricing_attr_rec.pricing_attribute_context(I);
	  EXCEPTION
	     WHEN NO_DATA_FOUND THEN
		l_exist1 := 0;
	  END;
	  IF l_exist > 0 OR l_exist1 > 0 THEN
	     p_pricing_attr_rec.process_status_flag(I):=NULL;
	     FND_MESSAGE.SET_NAME('QP','QP_1_PRIC_CONT_FOR_BASIC');
	     --Only one pricing context allwed in Basic Pricing
	     QP_BULK_MSG.ADD(l_msg_rec);
	  END IF;

      END IF;
    END IF;

-- Basic_Pricing_Condition
    IF QP_BULK_LOADER_PUB.GET_QP_STATUS <> 'I' THEN
       IF p_pricing_attr_rec.pricing_attribute_context(I) IS NOT NULL AND
	  p_pricing_attr_rec.pricing_attribute(I) IS NOT NULL	THEN
	BEGIN
		select s.availability_in_basic
		into   l_availability_in_basic
		from   qp_segments_b s, qp_prc_contexts_b c
		where  s.prc_context_id = c.prc_context_id
		and    c.prc_context_code = p_pricing_attr_rec.pricing_attribute_context(I)
		and    s.segment_mapping_column = p_pricing_attr_rec.pricing_attribute(I)
		and    s.availability_in_basic = 'Y';
	EXCEPTION
		WHEN NO_DATA_FOUND THEN
		 p_pricing_attr_rec.process_status_flag(I):=NULL;
		 FND_MESSAGE.SET_NAME('QP','QP_PRIC_CONTXT_NA_BASIC');
		 --Pricing Attribute Context not allowed in Basic Pricing
		 QP_BULK_MSG.ADD(l_msg_rec);
	END;

       END IF;

       IF p_pricing_attr_rec.product_attribute_context(I) IS NOT NULL AND
	  p_pricing_attr_rec.product_attribute(I) IS NOT NULL	THEN
	BEGIN
		select s.availability_in_basic
		into   l_availability_in_basic
		from   qp_segments_b s, qp_prc_contexts_b c
		where  s.prc_context_id = c.prc_context_id
		and    c.prc_context_code = p_pricing_attr_rec.product_attribute_context(I)
		and    s.segment_mapping_column = p_pricing_attr_rec.product_attribute(I)
		and    s.availability_in_basic = 'Y';
	EXCEPTION
		WHEN NO_DATA_FOUND THEN
		 p_pricing_attr_rec.process_status_flag(I):=NULL;
		 FND_MESSAGE.SET_NAME('QP','QP_PROD_CONTXT_NA_BASIC');
		 --Product Attribute Context not allowed in Basic Pricing
		 QP_BULK_MSG.ADD(l_msg_rec);
	END;
      END IF;
    END IF;
 --- check for consistency of product context/att/val among the attributes

    BEGIN
       l_exist := NULL;
       SELECT count(*) INTO l_exist
	 FROM qp_pricing_attributes
        WHERE orig_sys_line_ref = p_pricing_attr_rec.orig_sys_line_ref(I)
	  AND orig_sys_header_ref = p_pricing_attr_rec.orig_sys_header_ref(I)
	  AND product_attribute_context <> p_pricing_attr_rec.product_attribute_context(I)
	  AND product_attribute <> p_pricing_attr_rec.product_attribute(I)
	  AND product_attr_value <> p_pricing_attr_rec.product_attr_value(I);
     EXCEPTION
	WHEN NO_DATA_FOUND THEN
	   l_exist:=0;
     END;

    BEGIN
       l_exist1 := NULL;
       SELECT /*+ index(qipa QP_INTERFACE_PRCNG_ATTRIBS_N2) */ --7433219
       count(*) INTO l_exist1
	 FROM qp_interface_pricing_attribs
        WHERE request_id = p_pricing_attr_rec.request_id(I)
	  AND process_status_flag = 'P' --is null
	  AND orig_sys_line_ref = p_pricing_attr_rec.orig_sys_line_ref(I)
	  AND orig_sys_header_ref = p_pricing_attr_rec.orig_sys_header_ref(I)
	  AND product_attribute_context <> p_pricing_attr_rec.product_attribute_context(I)
	  AND product_attribute <> p_pricing_attr_rec.product_attribute(I)
	  AND product_attr_value <> p_pricing_attr_rec.product_attr_value(I);
     EXCEPTION
	WHEN NO_DATA_FOUND THEN
	   l_exist1:=0;
     END;

     IF l_exist >0 OR l_exist1>0 THEN
	 p_pricing_attr_rec.process_status_flag(I):=NULL;
	 FND_MESSAGE.SET_NAME('QP', 'INVALID_PROD_CONTEXT_ATTR_PAIR');
	 QP_BULK_MSG.ADD(l_msg_rec);
     END IF;

 -- check for pricing atributes
     IF (p_Pricing_Attr_rec.pricing_attribute_context(I) IS NOT NULL
	 OR p_Pricing_Attr_rec.pricing_attribute(I) IS NOT NULL
	 OR p_Pricing_Attr_rec.pricing_attr_value_from(I) IS NOT NULL
	 OR p_Pricing_Attr_rec.pricing_attr_value_to(I) IS NOT NULL)
     THEN
	IF (p_Pricing_Attr_rec.pricing_attribute_context(I) IS NULL
	    OR p_Pricing_Attr_rec.pricing_attribute(I) IS NULL
	    OR p_Pricing_Attr_rec.comparison_operator_code(I) IS NULL)
        THEN
	 p_pricing_attr_rec.process_status_flag(I):=NULL;
	 IF p_Pricing_Attr_rec.pricing_attribute_context(I) IS NULL THEN
	     FND_MESSAGE.SET_NAME('QP','QP_ATTRIBUTE_REQUIRED'  );
	     FND_MESSAGE.SET_TOKEN('ATTRIBUTE', 'PRICING_ATTRIBUTE_CONTEXT');
	     QP_BULK_MSG.ADD(l_msg_rec);
	 END IF;
	 IF p_Pricing_Attr_rec.pricing_attribute(I) IS NULL THEN
	     IF p_Pricing_Attr_rec.pricing_attr_code(I) IS NULL THEN
		 FND_MESSAGE.SET_NAME('QP','QP_ATTRIBUTE_REQUIRED'  );
		 FND_MESSAGE.SET_TOKEN('ATTRIBUTE', 'PRICING_ATTRIBUTE');
		 QP_BULK_MSG.ADD(l_msg_rec);
	     ELSE
		 FND_MESSAGE.SET_NAME('QP','QP_VALUE_TO_ID_ERROR'  );
		 FND_MESSAGE.SET_TOKEN('ATTRIBUTE', 'PRICING_ATTRIBUTE');
		 QP_BULK_MSG.ADD(l_msg_rec);
	     END IF;
	 END IF;
	 IF p_Pricing_Attr_rec.comparison_operator_code(I) IS NULL THEN
	     FND_MESSAGE.SET_NAME('QP','QP_ATTRIBUTE_REQUIRED'  );
	     FND_MESSAGE.SET_TOKEN('ATTRIBUTE', 'COMPARISON_OPERATOR_CODE');
	     QP_BULK_MSG.ADD(l_msg_rec);
	 END IF;
        ELSE
	   QP_UTIL.validate_qp_flexfield(flexfield_name  =>'QP_ATTR_DEFNS_PRICING'
					 ,context =>p_Pricing_Attr_rec.pricing_attribute_context(I)
					 ,attribute =>p_Pricing_Attr_rec.pricing_attribute(I)
					 ,value =>p_Pricing_Attr_rec.pricing_attr_value_from(I)
					 ,application_short_name         => 'QP'
					 ,context_flag                   =>l_context_error
					 ,attribute_flag                 =>l_attribute_error
					 ,value_flag                     =>l_value_error
					 ,datatype                       =>l_datatype
					 ,precedence                      =>l_precedence
					 ,error_code                     =>l_error_code
					 );

	   If (l_context_error = 'N'  AND l_error_code = 7)       --  invalid context
	   Then
	      p_pricing_attr_rec.process_status_flag(I):=NULL;
	      FND_MESSAGE.SET_NAME('QP','QP_ATTRIBUTE_REQUIRED'  );
	      FND_MESSAGE.SET_TOKEN('ATTRIBUTE',
				    QP_PRC_UTIL.Get_Attribute_Name('PRICING_ATTRIBUTE_CONTEXT'));

	      QP_BULK_MSG.Add(l_msg_rec);
	   END IF;

	   If l_attribute_error = 'N'   AND l_error_code = 8    --  invalid Attribute
					    Then
	      p_pricing_attr_rec.process_status_flag(I):=NULL;
	      FND_MESSAGE.SET_NAME('QP','QP_INVALID_ATTRIBUTE');
	      FND_MESSAGE.SET_TOKEN('ATTRIBUTE',' Attribute');
	      QP_BULK_MSG.Add(l_msg_rec);
	   END IF;

	   IF p_pricing_Attr_rec.comparison_operator_code(I) = '=' Then

	      If l_value_error = 'N'  AND l_error_code = 9      --  invalid value
					  Then
		 p_pricing_attr_rec.process_status_flag(I):=NULL;
		 FND_MESSAGE.SET_NAME('QP','QP_INVALID_ATTRIBUTE');
		 FND_MESSAGE.SET_TOKEN('ATTRIBUTE',' Value From ');
		 QP_BULK_MSG.Add(l_msg_rec);
	      End If;
	   END IF;

	   p_pricing_attr_rec.pricing_attribute_datatype(I):=l_datatype;

	   IF p_Pricing_Attr_rec.pricing_attribute_context(I) = 'VOLUME' AND
             p_Pricing_Attr_rec.pricing_attribute(I) = 'PRICING_ATTRIBUTE12'
                   --When Pricing Context is 'Volume' and Attribute is 'Item Amount'
           THEN
              p_pricing_attr_rec.process_status_flag(I):=NULL;
              FND_MESSAGE.SET_NAME('QP','QP_INVALID_ATTRIBUTE');
              FND_MESSAGE.SET_TOKEN('ATTRIBUTE','Pricing Attribute');
              QP_BULK_MSG.Add(l_msg_rec);
	   END IF;

--validation for canonical form
l_error_code:=QP_UTIL.validate_num_date(p_Pricing_Attr_rec.pricing_attribute_datatype(I),
					p_Pricing_Attr_rec.pricing_attr_value_from(I));
        IF l_error_code  <> 0  THEN
              p_pricing_attr_rec.process_status_flag(I):=NULL;
               FND_MESSAGE.SET_NAME('QP','QP_INVALID_ATTRIBUTE');
               FND_MESSAGE.SET_TOKEN('ATTRIBUTE','Value From ');
              QP_BULK_MSG.Add(l_msg_rec);
     END IF;

 -- Validation for Value_To

         IF p_Pricing_Attr_rec.pricing_attribute_context(I) IS NOT NULL AND
            p_Pricing_Attr_rec.pricing_attribute(I) IS NOT NULL AND
                  UPPER(p_Pricing_Attr_rec.comparison_operator_code(I)) = 'BETWEEN' AND
                    (p_Pricing_Attr_rec.pricing_attr_value_to(I) IS NULL OR
                        p_Pricing_Attr_rec.pricing_attr_value_from(I) IS NULL)
      THEN
                   p_pricing_attr_rec.process_status_flag(I):=NULL;
                   FND_MESSAGE.SET_NAME('QP','QP_ATTRIBUTE_REQUIRED'  );
                   FND_MESSAGE.SET_TOKEN('ATTRIBUTE',
			QP_PRC_UTIL.Get_Attribute_Name('PRICING_ATTR_VALUE_TO')||'/'||
                      	QP_PRC_UTIL.Get_Attribute_Name('PRICING_ATTR_VALUE_FROM'));
              QP_BULK_MSG.Add(l_msg_rec);
      END IF;

 -- validate value from

         IF p_Pricing_Attr_rec.pricing_attribute_context(I) IS NOT NULL AND
            p_Pricing_Attr_rec.pricing_attribute(I) IS NOT NULL AND
                  UPPER(p_Pricing_Attr_rec.comparison_operator_code(I)) <> 'BETWEEN' AND
                        p_Pricing_Attr_rec.pricing_attr_value_from(I) IS NULL
       THEN
                   p_pricing_attr_rec.process_status_flag(I):=NULL;
                   FND_MESSAGE.SET_NAME('QP','QP_ATTRIBUTE_REQUIRED'  );
                   FND_MESSAGE.SET_TOKEN('ATTRIBUTE',
			QP_PRC_UTIL.Get_Attribute_Name('PRICING_ATTR_VALUE_FROM'));
                    QP_BULK_MSG.Add(l_msg_rec);
        END IF;

   l_error_code:=QP_UTIL.validate_num_date(p_Pricing_Attr_rec.pricing_attribute_datatype(I),
  		             		     p_Pricing_Attr_rec.pricing_attr_value_to(I));

         IF l_error_code  <> 0  THEN
                p_pricing_attr_rec.process_status_flag(I):=NULL;
                FND_MESSAGE.SET_NAME('QP','QP_INVALID_ATTRIBUTE');
                FND_MESSAGE.SET_TOKEN('ATTRIBUTE','Value To ');
                QP_BULK_MSG.Add(l_msg_rec);
        END IF;

      END IF;  -- Else

 END IF;  -- pricing attr pair not null

   IF ( p_Pricing_Attr_rec.pricing_attribute_context(I) is not null
	 or   p_Pricing_Attr_rec.pricing_attribute(I) is not null ) then

    IF p_Pricing_Attr_rec.comparison_operator_code(I) is null then
       p_pricing_attr_rec.process_status_flag(I) :=NULL; --'E';
       FND_MESSAGE.SET_NAME('QP','QP_ATTRIBUTE_REQUIRED'  );
       FND_MESSAGE.SET_TOKEN('ATTRIBUTE',
			     QP_PRC_UTIL.Get_Attribute_Name('COMPARISON_OPERATOR_CODE'));
       QP_BULK_MSG.Add(l_msg_rec);
    ElSE
	 SELECT  lookup_code
           INTO  l_comparison_operator_code
           FROM  QP_LOOKUPS
          WHERE  LOOKUP_TYPE = 'COMPARISON_OPERATOR'
            AND  LOOKUP_CODE = UPPER(p_Pricing_Attr_rec.comparison_operator_code(I));

       If SQL%NOTFOUND
       Then
	  p_pricing_attr_rec.process_status_flag(I) :=NULL; --'E';
	  FND_MESSAGE.SET_NAME('QP','QP_ATTRIBUTE_REQUIRED'  );
	  FND_MESSAGE.SET_TOKEN('ATTRIBUTE',
				QP_PRC_UTIL.Get_Attribute_Name('COMPARISON_OPERATOR_CODE'));
	  QP_BULK_MSG.Add(l_msg_rec);
       END IF;

    END IF; /* comparison_operator_code is null */

    l_exist := 0;
    begin
       SELECT  1
       into l_exist
       FROM qp_interface_pricing_attribs b, qp_prc_contexts_b d,
	    qp_segments_b e, qp_pte_segments f
       WHERE orig_sys_pricing_attr_ref = p_pricing_attr_rec.orig_sys_pricing_attr_ref(I)
        AND  b.product_attribute_context = d.prc_context_code
	AND b.product_attribute = e.segment_mapping_column
	AND d.prc_context_id = e.prc_context_id
	AND d.prc_context_type = 'PRICING_ATTRIBUTE'
	AND e.segment_id = f.segment_id
	AND f.pte_code = l_pte_code
	AND f.segment_level <> 'LINE';
   exception
	when others then
		null;
   end;
   if l_exist > 0 then
      p_pricing_attr_rec.process_status_flag(I) :=NULL; --'E';
      FND_MESSAGE.SET_NAME('QP','QP_INVALID_ATTRIBUTE');
      FND_MESSAGE.SET_TOKEN('ATTRIBUTE', 'PRICING ATTRIBUTE');
      QP_BULK_MSG.Add(l_msg_rec);
   end if;

 END IF; /* context or atttribute is not null */

 -- price break child line can have only VOLUME pricing context

 IF  p_pricing_attr_rec.process_status_flag(I)='P' --<> 'E'
 THEN
   BEGIN
    --Bug# 5528754 RAVI
    --Check if the pricing attribute is for a PRICE BREAK
    SELECT /*+ index(l qp_list_lines_n11) index(r qp_rltd_modifiers_n2) */ --bug 9247305
     r.rltd_modifier_grp_type
      INTO l_pa_price_break
     FROM  qp_list_lines l, qp_rltd_modifiers r
    WHERE  l.orig_sys_line_ref = p_pricing_attr_rec.orig_sys_line_ref(I)
      -- Bug 5246745 Use Composite Index for Ref columns
      AND  l.orig_sys_header_ref = p_pricing_attr_rec.orig_sys_header_ref(I)
      AND  r.to_rltd_modifier_id = l.list_line_id
      AND  r.rltd_modifier_grp_type = 'PRICE BREAK';

    IF    p_pricing_attr_rec.pricing_attribute_context(I) IS NULL THEN
	  p_pricing_attr_rec.process_status_flag(I) :=NULL; --'E';
	  FND_MESSAGE.SET_NAME('QP','QP_ATTRIBUTE_REQUIRED');
          FND_MESSAGE.SET_TOKEN('ATTRIBUTE', 'Pricing Attribute Context');
	  QP_BULK_MSG.Add(l_msg_rec);
    ELSIF p_pricing_attr_rec.pricing_attribute_context(I)<>'VOLUME' THEN
	  p_pricing_attr_rec.process_status_flag(I) :=NULL; --'E';
	  FND_MESSAGE.SET_NAME('QP','PBH_CHILD_LINE_INVALID_CONTEXT');
	  QP_BULK_MSG.Add(l_msg_rec);
    END IF;

    EXCEPTION
      WHEN NO_DATA_FOUND THEN
        --Bug 5649050 (If this pricing attribute is not for a price break then set it back to default)
        l_pa_price_break :='PRICE LIST LINE';
    END;
 END IF;

   --  qp_bulk_loader_pub.write_log('check 5');

  --check for duplicate primary uom flag set
 IF p_pricing_attr_rec.process_status_flag(I)='P' THEN -- IS NULL THEN

      SELECT  primary_uom_flag
	INTO  l_primary_uom_flag
	FROM  qp_list_lines
       WHERE  list_line_id = p_PRICING_ATTR_rec.list_line_id(I);

    IF l_primary_uom_flag = 'Y'
	 AND p_PRICING_ATTR_rec.product_attribute(I) <> 'PRICING_ATTRIBUTE3' THEN
       l_count:= null;
       BEGIN
       -- Bug# 5228284 RAVI
       -- Do not consider the line if it's already the primary flag
	    SELECT count(*)
              INTO   l_count
	      FROM   qp_list_lines l, qp_pricing_attributes a
	     WHERE    l.list_line_id = a.list_line_id
	       AND    a.list_header_id = p_PRICING_ATTR_rec.list_header_id(I)
	       AND    a.product_attribute_context=p_PRICING_ATTR_rec.product_attribute_context(I)
	       AND    a.product_attribute = p_PRICING_ATTR_rec.product_attribute(I)
	       AND    a.product_attr_value = p_PRICING_ATTR_rec.product_attr_value(I)
	       AND    a.product_uom_code <> p_PRICING_ATTR_rec.product_uom_code(I)
	       AND    l.primary_uom_flag = 'Y'
	       AND    l.list_line_id <> p_PRICING_ATTR_rec.list_line_id(I);

       EXCEPTION
	  WHEN NO_DATA_FOUND THEN
	     l_count := 0;
       END;

       IF l_count > 0 THEN
	  p_pricing_attr_rec.process_status_flag(I):=NULL;
	  FND_MESSAGE.SET_NAME('QP','QP_UNIQUE_PRIMARY_UOM');
	  QP_BULK_MSG.Add(l_msg_rec);

	  -- set the corresponding line as errored
	    UPDATE qp_interface_list_lines
	       SET  process_status_flag = NULL --'E'
	     WHERE  request_id = p_pricing_attr_rec.request_id(I)
	       AND  orig_sys_line_ref = p_pricing_attr_rec.orig_sys_line_ref(I)
	       AND  orig_sys_header_ref = p_pricing_attr_rec.orig_sys_header_ref(I);

	  FND_MESSAGE.SET_NAME('QP','QP_UNIQUE_PRIMARY_UOM');
	  l_msg_txt:= FND_MESSAGE.GET;

	    INSERT INTO QP_INTERFACE_ERRORS
			(error_id,last_update_date, last_updated_by, creation_date,
			 created_by, last_update_login, request_id, program_application_id,
			 program_id, program_update_date, entity_type, table_name, column_name,
			 orig_sys_header_ref,orig_sys_line_ref,orig_sys_qualifier_ref,
			orig_sys_pricing_attr_ref, error_message)
	    VALUES
	     (qp_interface_errors_s.nextval, sysdate ,FND_GLOBAL.USER_ID, sysdate,
	      FND_GLOBAL.USER_ID, FND_GLOBAL.CONC_LOGIN_ID, p_pricing_attr_rec.request_id(I),661,
	      NULL,NULL, 'PRL', 'QP_INTERFACE_LIST_LINES', NULL,
	      p_pricing_attr_rec.orig_sys_header_ref(I),p_pricing_attr_rec.orig_sys_line_ref(I),null,
	      null,l_msg_txt);

	  FOR J IN p_pricing_attr_rec.orig_sys_line_ref.first
		   ..p_pricing_attr_rec.orig_sys_line_ref.last
		   LOOP
	     IF p_pricing_attr_rec.orig_sys_line_ref(J) = p_pricing_attr_rec.orig_sys_line_ref(I)
             AND p_pricing_attr_rec.orig_sys_pricing_attr_ref(J) <>
		 p_pricing_attr_rec.orig_sys_pricing_attr_ref(I)
	     THEN
		p_pricing_attr_rec.process_status_flag(J):=NULL; --'E';
		l_msg_rec.orig_sys_pricing_attr_ref := p_pricing_attr_rec.orig_sys_pricing_attr_ref(J);
		FND_MESSAGE.SET_NAME('QP', 'QP_PARENT_FAILED');
		QP_BULK_MSG.ADD(l_msg_rec);
	     END IF;
	  END LOOP;

       END IF;  --End duplicate exists

       BEGIN
	  l_count := null;
	    SELECT count(*)
	      INTO   l_count
	      FROM   qp_list_lines l, qp_interface_pricing_attribs a
	     WHERE   l.orig_sys_line_ref  = a.orig_sys_line_ref
	       AND   l.orig_sys_header_ref  = a.orig_sys_header_ref
	       AND    a.orig_sys_header_ref = p_PRICING_ATTR_rec.orig_sys_header_ref(I)
	       AND    a.product_attribute_context = p_PRICING_ATTR_rec.product_attribute_context(I)
	       AND    a.product_attribute = p_PRICING_ATTR_rec.product_attribute(I)
	       AND    a.product_attr_value = p_PRICING_ATTR_rec.product_attr_value(I)
	       AND    a.product_uom_code <> p_PRICING_ATTR_rec.product_uom_code(I)
               AND    a.orig_sys_pricing_attr_ref <> p_pricing_attr_rec.orig_sys_pricing_attr_ref(I)
	       AND    a.request_id =  p_pricing_attr_rec.request_id(I) 	       --bug 9247305
	       AND    a.process_status_flag = 'P' 	       --bug 9247305
	       AND    l.primary_uom_flag = 'Y';

       EXCEPTION
	  WHEN NO_DATA_FOUND THEN
	     l_count := 0;
       END;

       IF l_count > 0 THEN
	  p_pricing_attr_rec.process_status_flag(I):=NULL;
	  FND_MESSAGE.SET_NAME('QP','QP_UNIQUE_PRIMARY_UOM');
	  QP_BULK_MSG.Add(l_msg_rec);

	  -- set the corresponding line as errored
	    UPDATE qp_interface_list_lines
	       SET  process_status_flag = NULL --'E'
	     WHERE  request_id = p_pricing_attr_rec.request_id(I)
	       AND  orig_sys_line_ref = p_pricing_attr_rec.orig_sys_line_ref(I)
	       AND  orig_sys_header_ref = p_pricing_attr_rec.orig_sys_header_ref(I);

	  FND_MESSAGE.SET_NAME('QP','QP_UNIQUE_PRIMARY_UOM');
	  l_msg_txt:= FND_MESSAGE.GET;

	    INSERT INTO QP_INTERFACE_ERRORS
			(error_id,last_update_date, last_updated_by, creation_date,
			 created_by, last_update_login, request_id, program_application_id,
			 program_id, program_update_date, entity_type, table_name, column_name,
			 orig_sys_header_ref,orig_sys_line_ref,orig_sys_qualifier_ref,
			 orig_sys_pricing_attr_ref, error_message)
	    VALUES
	     (qp_interface_errors_s.nextval, sysdate ,FND_GLOBAL.USER_ID, sysdate,
	      FND_GLOBAL.USER_ID, FND_GLOBAL.CONC_LOGIN_ID, p_pricing_attr_rec.request_id(I),661,
	      NULL,NULL, 'PRL', 'QP_INTERFACE_LIST_LINES', NULL,
	      p_pricing_attr_rec.orig_sys_header_ref(I),p_pricing_attr_rec.orig_sys_line_ref(I),null,
	      null,l_msg_txt);

	  FOR J IN p_pricing_attr_rec.orig_sys_line_ref.first
		   ..p_pricing_attr_rec.orig_sys_line_ref.last
		   LOOP
	     IF p_pricing_attr_rec.orig_sys_line_ref(J) = p_pricing_attr_rec.orig_sys_line_ref(I)
		AND p_pricing_attr_rec.orig_sys_pricing_attr_ref(J) <>
		    p_pricing_attr_rec.orig_sys_pricing_attr_ref(I)
	     THEN
		p_pricing_attr_rec.process_status_flag(J):=NULL; --'E';
		l_msg_rec.orig_sys_pricing_attr_ref := p_pricing_attr_rec.orig_sys_pricing_attr_ref(J);
		FND_MESSAGE.SET_NAME('QP', 'QP_PARENT_FAILED');
		QP_BULK_MSG.ADD(l_msg_rec);
	     END IF;
	  END LOOP;
       END IF;   -- If duplicate


    END IF;   -- IF  primary_uom_flag set

 END IF;   --  IF process_status_flag

 l_msg_rec.orig_sys_pricing_attr_ref := p_pricing_attr_rec.orig_sys_pricing_attr_ref(I);

 -- qp_bulk_loader_pub.write_log('check 6');
--Delayed request validation
-- Checking multiple price break attributes

     BEGIN

          l_count:=null;
	 /* SELECT COUNT(1) INTO l_count
	   FROM
	  (SELECT /*+ ordered leading(la) index(pb QP_INTERFACE_PRCNG_ATTRIBS_N4) */ /*DISTINCT pb.pricing_attribute
	    FROM qp_list_lines la,
		 qp_pricing_attributes pb,
		 qp_rltd_modifiers ra
	   WHERE ra.to_rltd_modifier_id = la.list_line_id
	     AND pb.list_line_id = ra.to_rltd_modifier_id
	     AND ra.from_rltd_modifier_id = (select from_rltd_modifier_id
                           from qp_rltd_modifiers, qp_list_lines
                           where orig_sys_line_ref = p_pricing_attr_rec.orig_sys_line_ref(I)
                           -- Bug 5246745 Use Composite Index for Ref columns
                           and orig_sys_header_ref = p_pricing_attr_rec.orig_sys_header_ref(I)
                           and to_rltd_modifier_id = list_line_id)
	     AND ra.rltd_modifier_grp_type = 'PRICE BREAK'
	    UNION
	  SELECT  /*+ leading(la) */ /*DISTINCT pb.pricing_attribute
	    FROM   qp_list_lines la,
	           qp_interface_pricing_attribs pb,
        	   qp_rltd_modifiers ra
	   WHERE   ra.to_rltd_modifier_id = la.list_line_id
	     AND   pb.orig_sys_line_ref  = la.orig_sys_line_ref
	     AND   pb.request_id =  p_pricing_attr_rec.request_id(I)
	     AND   pb.process_status_flag = 'P' --IS NULL
	     AND   ra.from_rltd_modifier_id = (select from_rltd_modifier_id
                           from qp_rltd_modifiers, qp_list_lines
                           where orig_sys_line_ref = p_pricing_attr_rec.orig_sys_line_ref(I)
                           -- Bug 5246745 Use Composite Index for Ref columns
                           and orig_sys_header_ref = p_pricing_attr_rec.orig_sys_header_ref(I)
                           and to_rltd_modifier_id = list_line_id)
	     AND   ra.rltd_modifier_grp_type = 'PRICE BREAK');*/


	  SELECT COUNT(1) INTO l_count
	   FROM
          (SELECT /*+ ordered leading(la) index(pb QP_INTERFACE_PRCNG_ATTRIBS_N4) */ DISTINCT pb.pricing_attribute
	    FROM qp_list_lines la,
		 qp_rltd_modifiers ra,
                 qp_rltd_modifiers rb,
                 qp_list_lines lb,
		 qp_interface_pricing_attribs pb
            WHERE la.orig_sys_line_ref =  p_pricing_attr_rec.orig_sys_line_ref(I) AND
                  la.list_line_type_code = 'PLL' AND
                  la.pricing_phase_id = 1 AND
                  ra.to_rltd_modifier_id = la.list_line_id AND
                  rb.from_rltd_modifier_id = ra.FROM_RLTD_MODIFIER_ID AND
                  lb.list_line_id = rb.to_rltd_modifier_id AND
                  pb.orig_sys_line_ref = lb.orig_sys_line_ref AND
                  pb.request_id =  p_pricing_attr_rec.request_id(I) AND
                  pb.process_status_flag = 'P' AND --IS NULL  AND
                  rb.rltd_modifier_grp_type = 'PRICE BREAK'
         UNION
            SELECT /*+ leading(la) */ DISTINCT pb.pricing_attribute
	    FROM qp_list_lines la,
		 qp_pricing_attributes pb,
		 qp_rltd_modifiers ra,
                 qp_rltd_modifiers rb
            WHERE la.orig_sys_line_ref = p_pricing_attr_rec.orig_sys_line_ref(I) AND
                  la.list_line_type_code = 'PLL' AND
                  la.pricing_phase_id = 1 AND
                  ra.to_rltd_modifier_id = la.list_line_id AND
                  rb.from_rltd_modifier_id = ra.FROM_RLTD_MODIFIER_ID AND
                  pb.list_line_id = rb.to_rltd_modifier_id AND
                  rb.rltd_modifier_grp_type = 'PRICE BREAK');

	 --qp_bulk_loader_pub.write_log('multi_attr:'||l_count);

         IF l_count>1 THEN
            P_PRICING_ATTR_REC.PROCESS_STATUS_FLAG(I):= NULL; --'E';
	    FND_MESSAGE.SET_NAME('QP', 'QP_MULT_PRICE_BREAK_ATTRS');
	    QP_BULK_MSG.ADD(l_msg_rec);

	    UPDATE qp_interface_list_lines
	       SET process_status_flag = NULL --'E'
	     WHERE orig_sys_line_ref = p_pricing_attr_rec.orig_sys_line_ref(I)
	       AND orig_sys_header_ref = p_pricing_attr_rec.orig_sys_header_ref(I);

	  l_msg_txt:= FND_MESSAGE.GET;

	  INSERT INTO QP_INTERFACE_ERRORS
		       (error_id,last_update_date, last_updated_by, creation_date,
			created_by, last_update_login, request_id, program_application_id,
			program_id, program_update_date, entity_type, table_name, column_name,
			orig_sys_header_ref,orig_sys_line_ref,orig_sys_qualifier_ref,
			orig_sys_pricing_attr_ref, error_message)
	   VALUES
	    (qp_interface_errors_s.nextval, sysdate ,FND_GLOBAL.USER_ID, sysdate,
	     FND_GLOBAL.USER_ID, FND_GLOBAL.CONC_LOGIN_ID, p_pricing_attr_rec.request_id(I), 661,
	     NULL,NULL, 'PRL', 'QP_INTERFACE_LIST_LINES', NULL,
	     p_pricing_attr_rec.orig_sys_header_ref(I),p_pricing_attr_rec.orig_sys_line_ref(I),null,
	     null,l_msg_txt);

	 END IF;

      EXCEPTION
	 WHEN NO_DATA_FOUND THEN
	    NULL;
      END;

-- qp_bulk_loader_pub.write_log('check 7: Ref:'|| p_pricing_attr_rec.orig_sys_pricing_attr_ref(I));

-- Check Overlapping Price break child lines
   BEGIN

    l_status := null;
    l_status1:= null;

   IF  p_pricing_attr_rec.pricing_attribute_datatype(I)='N' THEN
       OPEN C_break_lines(p_pricing_attr_rec.orig_sys_line_ref(I),
                          -- Bug 5246745 Use Composite Index for Ref columns
                          p_pricing_attr_rec.orig_sys_header_ref(I));

       FETCH C_break_lines into l_status;       CLOSE C_break_lines;
   END IF;

--ENH Continuous Price Breaks START RAVI
/**
Validation check for multiple continuous price breaks (Messages)
**/
   IF  p_pricing_attr_rec.pricing_attribute_datatype(I)='N' THEN

       -- Bug# 5440851 RAVI START
       -- If the PA values are tried to be changed to Char from Num type throw an error.
       BEGIN
  	  l_pa_to_val_tmp:=to_number(p_pricing_attr_rec.pricing_attr_value_to(I));
       EXCEPTION
          WHEN OTHERS THEN
             P_PRICING_ATTR_REC.PROCESS_STATUS_FLAG(I):= NULL; --'E';
	     FND_MESSAGE.SET_NAME('QP', 'QP_INVALID_DATA_TYPE');
	     QP_BULK_MSG.ADD(l_msg_rec);
             p_pricing_attr_rec.pricing_attr_value_to(I):=0;
       END;

       BEGIN
          l_pa_from_val_tmp:=to_number(p_pricing_attr_rec.pricing_attr_value_from(I));
       EXCEPTION
          WHEN OTHERS THEN
             P_PRICING_ATTR_REC.PROCESS_STATUS_FLAG(I):= NULL; --'E';
	     FND_MESSAGE.SET_NAME('QP', 'QP_INVALID_DATA_TYPE');
	     QP_BULK_MSG.ADD(l_msg_rec);
             p_pricing_attr_rec.pricing_attr_value_from(I):=0;
       END;
       -- Bug# 5440851 RAVI END

       OPEN C_old_cont_grp_break_line(p_pricing_attr_rec.orig_sys_line_ref(I),
                          -- Bug 5246745 Use Composite Index for Ref columns
                          p_pricing_attr_rec.orig_sys_header_ref(I));
       FETCH C_old_cont_grp_break_line
             into l_old_break_pa_count, l_old_break_low_value, l_old_break_high_value;
       CLOSE C_old_cont_grp_break_line;
       OPEN C_new_cont_grp_break_lines(p_pricing_attr_rec.orig_sys_line_ref(I),
                          -- Bug 5246745 Use Composite Index for Ref columns
                          p_pricing_attr_rec.orig_sys_header_ref(I));
       FETCH C_new_cont_grp_break_lines
             into l_new_break_pa_count, l_new_break_low_value, l_new_break_high_value;
       CLOSE C_new_cont_grp_break_lines;

       --Max from value
       l_break_high_value:=to_number(p_pricing_attr_rec.pricing_attr_value_to(I));
       IF l_break_high_value < l_old_break_high_value THEN
          l_break_high_value:=l_old_break_high_value;
       END IF;

       IF l_break_high_value < l_new_break_high_value THEN
          l_break_high_value:=l_new_break_high_value;
       END IF;

       --Continuous Price Break To and From Values Check
       OPEN C_to_value_old(p_pricing_attr_rec.orig_sys_line_ref(I),
                          -- Bug 5246745 Use Composite Index for Ref columns
                          p_pricing_attr_rec.orig_sys_header_ref(I));
       FETCH C_to_value_old into l_to_value_old;
       CLOSE C_to_value_old;
       OPEN C_to_value_new(p_pricing_attr_rec.orig_sys_line_ref(I),
                          -- Bug 5246745 Use Composite Index for Ref columns
                          p_pricing_attr_rec.orig_sys_header_ref(I));
       FETCH C_to_value_new into l_to_value_new;
       CLOSE C_to_value_new;

       OPEN C_from_value_old(p_pricing_attr_rec.orig_sys_line_ref(I),
                          -- Bug 5246745 Use Composite Index for Ref columns
                          p_pricing_attr_rec.orig_sys_header_ref(I));
       FETCH C_from_value_old into l_from_value_old;
       CLOSE C_from_value_old;
       OPEN C_from_value_new(p_pricing_attr_rec.orig_sys_line_ref(I),
                          -- Bug 5246745 Use Composite Index for Ref columns
                          p_pricing_attr_rec.orig_sys_header_ref(I));
       FETCH C_from_value_new into l_from_value_new;
       CLOSE C_from_value_new;

       IF l_old_break_pa_count > 0 OR l_new_break_pa_count > 0 THEN
          --Multiple price breaks
          qp_bulk_loader_pub.write_log('The price breaks header has multiple price breaks');
          IF l_to_value_old = 1 OR l_to_value_new = 1 OR
             to_number(p_pricing_attr_rec.pricing_attr_value_to(I)) = l_break_high_value THEN
             qp_bulk_loader_pub.write_log('TO value has a corresponding FROM value or is the max.');
             IF l_from_value_old = 1 OR l_from_value_new = 1 OR
                to_number(p_pricing_attr_rec.pricing_attr_value_from(I))=0 THEN
                null;
                qp_bulk_loader_pub.write_log('FROM value has a corresponding TO value or is zero.');
             ELSE
		qp_bulk_loader_pub.write_log('ERROR: No Same To_From Value for Price Break');
                P_PRICING_ATTR_REC.PROCESS_STATUS_FLAG(I):= NULL ; --'E';
                FND_MESSAGE.SET_NAME('QP', 'QP_PBK_CRSPNDNG_TO_FROM');
                QP_BULK_MSG.ADD(l_msg_rec);

      	        UPDATE qp_interface_list_lines
                SET process_status_flag = NULL --'E'
	            WHERE orig_sys_line_ref = p_pricing_attr_rec.orig_sys_line_ref(I)
	            AND orig_sys_header_ref = p_pricing_attr_rec.orig_sys_header_ref(I);

                FND_MESSAGE.SET_NAME('QP', 'QP_PBK_CRSPNDNG_TO_FROM');
	            l_msg_txt:= FND_MESSAGE.GET;

      	        INSERT INTO QP_INTERFACE_ERRORS
	      	       (error_id,last_update_date, last_updated_by, creation_date,
		         	created_by, last_update_login, request_id, program_application_id,
      	      		program_id, program_update_date, entity_type, table_name, column_name,
	      	      	orig_sys_header_ref,orig_sys_line_ref,orig_sys_qualifier_ref,
      		      	orig_sys_pricing_attr_ref, error_message)
                VALUES
	                (qp_interface_errors_s.nextval, sysdate ,FND_GLOBAL.USER_ID, sysdate,
	                 FND_GLOBAL.USER_ID, FND_GLOBAL.CONC_LOGIN_ID, p_pricing_attr_rec.request_id(I), 661,
                     NULL,NULL, 'PRL', 'QP_INTERFACE_LIST_LINES', NULL,
	                 p_pricing_attr_rec.orig_sys_header_ref(I),p_pricing_attr_rec.orig_sys_line_ref(I),null,
                     null,l_msg_txt);
             END IF;
          ELSE
	     qp_bulk_loader_pub.write_log('ERROR: No Same From_To Value for Price Break');
             P_PRICING_ATTR_REC.PROCESS_STATUS_FLAG(I):= NULL ; --'E';
             FND_MESSAGE.SET_NAME('QP', 'QP_PBK_CRSPNDNG_FROM_TO');
             QP_BULK_MSG.ADD(l_msg_rec);

	         UPDATE qp_interface_list_lines
	         SET process_status_flag = NULL --'E'
	         WHERE orig_sys_line_ref = p_pricing_attr_rec.orig_sys_line_ref(I)
	         AND orig_sys_header_ref = p_pricing_attr_rec.orig_sys_header_ref(I);

	         FND_MESSAGE.SET_NAME('QP', 'QP_PBK_CRSPNDNG_FROM_TO');
	         l_msg_txt:= FND_MESSAGE.GET;

	         INSERT INTO QP_INTERFACE_ERRORS
		       (error_id,last_update_date, last_updated_by, creation_date,
			    created_by, last_update_login, request_id, program_application_id,
			    program_id, program_update_date, entity_type, table_name, column_name,
			    orig_sys_header_ref,orig_sys_line_ref,orig_sys_qualifier_ref,
			    orig_sys_pricing_attr_ref, error_message)
	         VALUES
	           (qp_interface_errors_s.nextval, sysdate ,FND_GLOBAL.USER_ID, sysdate,
	            FND_GLOBAL.USER_ID, FND_GLOBAL.CONC_LOGIN_ID, p_pricing_attr_rec.request_id(I), 661,
	            NULL,NULL, 'PRL', 'QP_INTERFACE_LIST_LINES', NULL,
	            p_pricing_attr_rec.orig_sys_header_ref(I),p_pricing_attr_rec.orig_sys_line_ref(I),null,
            	null,l_msg_txt);
          END IF;
       END IF;

       --Check if lowest PB value is zero
       IF to_number(p_pricing_attr_rec.pricing_attr_value_from(I)) <> 0 AND l_pa_price_break='PRICE BREAK'
       THEN

       --Bug# 5528754 RAVI END
          IF l_old_break_low_value = 0 OR l_new_break_low_value = 0 THEN
             NULL;
          ELSE
	     qp_bulk_loader_pub.write_log('ERROR: No 0 From Value');
             P_PRICING_ATTR_REC.PROCESS_STATUS_FLAG(I):= NULL ; --'E';
             FND_MESSAGE.SET_NAME('QP', 'QP_PBK_ZERO_FROM');
             QP_BULK_MSG.ADD(l_msg_rec);

  	         UPDATE qp_interface_list_lines
	         SET process_status_flag = NULL --'E'
	         WHERE orig_sys_line_ref = p_pricing_attr_rec.orig_sys_line_ref(I)
	         AND orig_sys_header_ref = p_pricing_attr_rec.orig_sys_header_ref(I);

	         FND_MESSAGE.SET_NAME('QP', 'QP_PBK_ZERO_FROM');
	         l_msg_txt:= FND_MESSAGE.GET;

	         INSERT INTO QP_INTERFACE_ERRORS
		       (error_id,last_update_date, last_updated_by, creation_date,
			    created_by, last_update_login, request_id, program_application_id,
			    program_id, program_update_date, entity_type, table_name, column_name,
			    orig_sys_header_ref,orig_sys_line_ref,orig_sys_qualifier_ref,
			    orig_sys_pricing_attr_ref, error_message)
	           VALUES
	             (qp_interface_errors_s.nextval, sysdate ,FND_GLOBAL.USER_ID, sysdate,
	              FND_GLOBAL.USER_ID, FND_GLOBAL.CONC_LOGIN_ID, p_pricing_attr_rec.request_id(I), 661,
	              NULL,NULL, 'PRL', 'QP_INTERFACE_LIST_LINES', NULL,
	              p_pricing_attr_rec.orig_sys_header_ref(I),p_pricing_attr_rec.orig_sys_line_ref(I),null,
            	  null,l_msg_txt);
          END IF;
       END IF;
   END IF;
--ENH Continuous Price Breaks END RAVI

   IF p_pricing_attr_rec.pricing_attribute_datatype(I)='N' THEN
       OPEN C_Int_break_lines(p_pricing_attr_rec.orig_sys_line_ref(I),
                          -- Bug 5246745 Use Composite Index for Ref columns
                          p_pricing_attr_rec.orig_sys_header_ref(I),
                          p_pricing_attr_rec.request_id(I));  -- changes done by rassharm for bug no 6028305
       FETCH C_Int_break_lines into l_status1;

       CLOSE C_Int_break_lines;
   END IF;

   IF l_status = 'OVERLAP' OR l_status1 = 'OVERLAP' THEN
      qp_bulk_loader_pub.write_log('Overlapping Price Breaks');
      P_PRICING_ATTR_REC.PROCESS_STATUS_FLAG(I):= NULL ; --'E';
      FND_MESSAGE.SET_NAME('QP', 'QP_OVERLAP_PRICE_BREAK_RANGE');
      QP_BULK_MSG.ADD(l_msg_rec);

	    UPDATE qp_interface_list_lines
	       SET process_status_flag = NULL --'E'
	     WHERE orig_sys_line_ref = p_pricing_attr_rec.orig_sys_line_ref(I)
	       AND orig_sys_header_ref = p_pricing_attr_rec.orig_sys_header_ref(I);

	  FND_MESSAGE.SET_NAME('QP', 'QP_OVERLAP_PRICE_BREAK_RANGE');
	  l_msg_txt:= FND_MESSAGE.GET;

	 INSERT INTO QP_INTERFACE_ERRORS
		       (error_id,last_update_date, last_updated_by, creation_date,
			created_by, last_update_login, request_id, program_application_id,
			program_id, program_update_date, entity_type, table_name, column_name,
			orig_sys_header_ref,orig_sys_line_ref,orig_sys_qualifier_ref,
			orig_sys_pricing_attr_ref, error_message)
	   VALUES
	    (qp_interface_errors_s.nextval, sysdate ,FND_GLOBAL.USER_ID, sysdate,
	     FND_GLOBAL.USER_ID, FND_GLOBAL.CONC_LOGIN_ID, p_pricing_attr_rec.request_id(I), 661,
	     NULL,NULL, 'PRL', 'QP_INTERFACE_LIST_LINES', NULL,
	     p_pricing_attr_rec.orig_sys_header_ref(I),p_pricing_attr_rec.orig_sys_line_ref(I),null,
	     null,l_msg_txt);

   END IF;
EXCEPTION
   WHEN NO_DATA_FOUND THEN
      NULL;
END;

--Flex field check

   IF ( p_Pricing_Attr_rec.pricing_attribute_context(I) is not null
	 or   p_Pricing_Attr_rec.pricing_attribute(I) is not null ) then

    IF l_pricing_attr_flex_enabled = 'Y' THEN
      qp_bulk_loader_pub.write_log( 'Pricing Attr Flex enabled ');

         IF NOT Init_Desc_Flex
               (p_flex_name	     =>'QP_PRICING_ATTRIBUTES'
	       ,p_context            => p_pricing_attr_rec.context(i)
               ,p_attribute1         => p_pricing_attr_rec.attribute1(i)
               ,p_attribute2         => p_pricing_attr_rec.attribute2(i)
               ,p_attribute3         => p_pricing_attr_rec.attribute3(i)
               ,p_attribute4         => p_pricing_attr_rec.attribute4(i)
               ,p_attribute5         => p_pricing_attr_rec.attribute5(i)
               ,p_attribute6         => p_pricing_attr_rec.attribute6(i)
               ,p_attribute7         => p_pricing_attr_rec.attribute7(i)
               ,p_attribute8         => p_pricing_attr_rec.attribute8(i)
               ,p_attribute9         => p_pricing_attr_rec.attribute9(i)
               ,p_attribute10        => p_pricing_attr_rec.attribute10(i)
               ,p_attribute11        => p_pricing_attr_rec.attribute11(i)
               ,p_attribute12        => p_pricing_attr_rec.attribute12(i)
               ,p_attribute13        => p_pricing_attr_rec.attribute13(i)
               ,p_attribute14        => p_pricing_attr_rec.attribute14(i)
               ,p_attribute15        => p_pricing_attr_rec.attribute15(i)) THEN

	         QP_BULK_MSG.ADD(l_msg_rec);

                 -- Log Error Message
                 FND_MESSAGE.SET_NAME('QP','QP_INVALID_ATTRIBUTE');
                 FND_MESSAGE.SET_TOKEN('ATTRIBUTE',
                                       'Entity:Flexfield:Pricing_Attr_Desc_Flex');
	         p_pricing_attr_rec.process_status_flag(I):=NULL;

	         QP_BULK_MSG.ADD(l_msg_rec);

          ELSE -- if the flex validation is successfull

            IF p_pricing_attr_rec.context(i) IS NULL
              OR p_pricing_attr_rec.context(i) = FND_API.G_MISS_CHAR THEN
               p_pricing_attr_rec.context(i)    := g_context;
            END IF;

            IF p_pricing_attr_rec.attribute1(i) IS NULL
              OR p_pricing_attr_rec.attribute1(i) = FND_API.G_MISS_CHAR THEN
               p_pricing_attr_rec.attribute1(i) := g_attribute1;
            END IF;

            IF p_pricing_attr_rec.attribute2(i) IS NULL
              OR p_pricing_attr_rec.attribute2(i) = FND_API.G_MISS_CHAR THEN
               p_pricing_attr_rec.attribute2(i) := g_attribute2;
            END IF;

            IF p_pricing_attr_rec.attribute3(i) IS NULL
              OR p_pricing_attr_rec.attribute3(i) = FND_API.G_MISS_CHAR THEN
               p_pricing_attr_rec.attribute3(i) := g_attribute3;
            END IF;

            IF p_pricing_attr_rec.attribute4(i) IS NULL
              OR p_pricing_attr_rec.attribute4(i) = FND_API.G_MISS_CHAR THEN
               p_pricing_attr_rec.attribute4(i) := g_attribute4;
            END IF;

            IF p_pricing_attr_rec.attribute5(i) IS NULL
              OR p_pricing_attr_rec.attribute5(i) = FND_API.G_MISS_CHAR THEN
               p_pricing_attr_rec.attribute5(i) := g_attribute5;
            END IF;

            IF p_pricing_attr_rec.attribute6(i) IS NULL
              OR p_pricing_attr_rec.attribute6(i) = FND_API.G_MISS_CHAR THEN
               p_pricing_attr_rec.attribute6(i) := g_attribute6;
            END IF;
            IF p_pricing_attr_rec.attribute7(i) IS NULL
              OR p_pricing_attr_rec.attribute7(i) = FND_API.G_MISS_CHAR THEN
               p_pricing_attr_rec.attribute7(i) := g_attribute7;
            END IF;

            IF p_pricing_attr_rec.attribute8(i) IS NULL
              OR p_pricing_attr_rec.attribute8(i) = FND_API.G_MISS_CHAR THEN
               p_pricing_attr_rec.attribute8(i) := g_attribute8;
            END IF;

            IF p_pricing_attr_rec.attribute9(i) IS NULL
              OR p_pricing_attr_rec.attribute9(i) = FND_API.G_MISS_CHAR THEN
               p_pricing_attr_rec.attribute9(i) := g_attribute9;
            END IF;

            IF p_pricing_attr_rec.attribute10(i) IS NULL
              OR p_pricing_attr_rec.attribute10(i) = FND_API.G_MISS_CHAR THEN
               p_pricing_attr_rec.attribute10(i) := G_attribute10;
            End IF;

            IF p_pricing_attr_rec.attribute11(i) IS NULL
              OR p_pricing_attr_rec.attribute11(i) = FND_API.G_MISS_CHAR THEN
               p_pricing_attr_rec.attribute11(i) := g_attribute11;
            END IF;

            IF p_pricing_attr_rec.attribute12(i) IS NULL
              OR p_pricing_attr_rec.attribute12(i) = FND_API.G_MISS_CHAR THEN
               p_pricing_attr_rec.attribute12(i) := g_attribute12;
            END IF;

            IF p_pricing_attr_rec.attribute13(i) IS NULL
              OR p_pricing_attr_rec.attribute13(i) = FND_API.G_MISS_CHAR THEN
               p_pricing_attr_rec.attribute13(i) := g_attribute13;
            END IF;

            IF p_pricing_attr_rec.attribute14(i) IS NULL
              OR p_pricing_attr_rec.attribute14(i) = FND_API.G_MISS_CHAR THEN
               p_pricing_attr_rec.attribute14(i) := g_attribute14;
            END IF;

            IF p_pricing_attr_rec.attribute15(i) IS NULL
              OR p_pricing_attr_rec.attribute15(i) = FND_API.G_MISS_CHAR THEN
               p_pricing_attr_rec.attribute15(i) := g_attribute15;
            END IF;
	END IF;
    END IF;
 END IF;  -- pricing attr pair not null

  -- Updation check
  --cannot update product attribute
  IF p_pricing_attr_rec.interface_action_code(I) = 'UPDATE'
     AND p_pricing_attr_rec.process_status_flag(I)='P' THEN --,'*') <> 'E' THEN

      l_old_pricing_attr_rec := Qp_pll_pricing_attr_Util.Query_Row
	(   p_pricing_attribute_id        => l_pricing_attribute_id
	);

      IF l_old_pricing_attr_rec.product_attribute_context <>
	 p_pricing_attr_rec.product_attribute_context(I)
	 OR l_old_pricing_attr_rec.product_attribute <>
	    p_pricing_attr_rec.product_attribute(I)
	    OR l_old_pricing_attr_rec.product_attr_value <>
	       p_pricing_attr_rec.product_attr_value(I) THEN

	 P_PRICING_ATTR_REC.PROCESS_STATUS_FLAG(I):= NULL; --'E';
	 FND_MESSAGE.SET_NAME('QP', 'NO_PRODUCT_ATTR_UPD');
	 QP_BULK_MSG.ADD(l_msg_rec);
      END IF;
  END IF;


--Warning messages
-- Product attribute
     IF p_pricing_attr_rec.process_status_flag(I)='P' --,'*') <> 'E'
	and p_pricing_attr_rec.pricing_attribute_context(I) IS NULL
	and p_pricing_attr_rec.pricing_attribute(I) IS NULL THEN

        QP_UTIL.Get_Context_Type('QP_ATTR_DEFNS_PRICING',
                               p_Pricing_Attr_rec.product_attribute_context(I),
                               l_context_type,
                               l_error_code);

        QP_UTIL.Get_Sourcing_Info(l_context_type,
                                  p_Pricing_Attr_rec.product_attribute_context(I),
                                  p_Pricing_Attr_rec.product_attribute(I),
                                  l_sourcing_enabled,
                                  l_sourcing_status,
                                  l_sourcing_method);
   	qp_bulk_loader_pub.write_log('Sourcing method / status / enabled'||l_sourcing_method||l_sourcing_status||l_sourcing_enabled);

        IF l_sourcing_method = 'ATTRIBUTE MAPPING' THEN

          IF l_sourcing_enabled <> 'Y' THEN

            FND_MESSAGE.SET_NAME('QP','QP_ENABLE_SOURCING');
            FND_MESSAGE.SET_TOKEN('CONTEXT',
                                p_Pricing_Attr_rec.product_attribute_context(I));
	    FND_MESSAGE.SET_TOKEN('ATTRIBUTE',
                                  p_Pricing_Attr_rec.product_attribute(I));
	    QP_BULK_MSG.ADD(l_msg_rec);
           END IF;

          IF l_sourcing_status <> 'Y' THEN

            FND_MESSAGE.SET_NAME('QP','QP_BUILD_SOURCING_RULES');
            FND_MESSAGE.SET_TOKEN('CONTEXT',
                                  p_Pricing_Attr_rec.product_attribute_context(I));
	    FND_MESSAGE.SET_TOKEN('ATTRIBUTE',
                                  p_Pricing_Attr_rec.product_attribute(I));
	    QP_BULK_MSG.ADD(l_msg_rec);

          END IF;

        END IF; --If sourcing_method = 'ATTRIBUTE MAPPING'
     END IF; -- process_status_flag(I) <> 'E'

-- Pricing attribute
     IF p_pricing_attr_rec.process_status_flag(I)='P' --,'*') <> 'E'
	and p_pricing_attr_rec.pricing_attribute_context(I) IS NOT NULL
	and p_pricing_attr_rec.pricing_attribute(I) IS NOT NULL THEN

        QP_UTIL.Get_Context_Type('QP_ATTR_DEFNS_PRICING',
                               p_Pricing_Attr_rec.pricing_attribute_context(I),
                               l_context_type,
                               l_error_code);

        QP_UTIL.Get_Sourcing_Info(l_context_type,
                                  p_Pricing_Attr_rec.pricing_attribute_context(I),
                                  p_Pricing_Attr_rec.pricing_attribute(I),
                                  l_sourcing_enabled,
                                  l_sourcing_status,
                                  l_sourcing_method);

   	qp_bulk_loader_pub.write_log('Sourcing method / status / enabled'||l_sourcing_method||l_sourcing_status||l_sourcing_enabled);

        IF l_sourcing_method = 'ATTRIBUTE MAPPING' THEN

          IF l_sourcing_enabled <> 'Y' THEN

            FND_MESSAGE.SET_NAME('QP','QP_ENABLE_SOURCING');
            FND_MESSAGE.SET_TOKEN('CONTEXT',
                                p_Pricing_Attr_rec.pricing_attribute_context(I));
	    FND_MESSAGE.SET_TOKEN('ATTRIBUTE',
                                  p_Pricing_Attr_rec.pricing_attribute(I));
	    QP_BULK_MSG.ADD(l_msg_rec);
           END IF;

          IF l_sourcing_status <> 'Y' THEN

            FND_MESSAGE.SET_NAME('QP','QP_BUILD_SOURCING_RULES');
            FND_MESSAGE.SET_TOKEN('CONTEXT',
                                  p_Pricing_Attr_rec.pricing_attribute_context(I));
	    FND_MESSAGE.SET_TOKEN('ATTRIBUTE',
                                  p_Pricing_Attr_rec.pricing_attribute(I));
	    QP_BULK_MSG.ADD(l_msg_rec);

          END IF;

        END IF; --If sourcing_method = 'ATTRIBUTE MAPPING'
     END IF; -- process_status_flag(I) <> 'E'
 END LOOP;

 qp_bulk_loader_pub.write_log( 'Leaving Entity Pricing Attr validation');

 EXCEPTION
    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
       qp_bulk_loader_pub.write_log( 'UNEXCPECTED ERROR IN PROCEDURE ENTITY_PRICING_ATTR:'||sqlerrm);
       RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    WHEN OTHERS THEN
       qp_bulk_loader_pub.write_log( 'UNEXCPECTED ERROR IN PROCEDURE ENTITY_PRICING_ATTR:'||sqlerrm);
       RAISE FND_API.G_EXC_UNEXPECTED_ERROR;


END ENTITY_PRICING_ATTR;




PROCEDURE ATTRIBUTE_HEADER
          (p_request_id NUMBER)
IS
   l_msg_txt VARCHAR2(240);

BEGIN

        --Currency Code
	--List Type Code
	--Freight Terms
	--Payment Terms
	--Ship Method (Freight Carrier)
	--Currency Header Id
	--Name
	--PTE
	--Source System

qp_bulk_loader_pub.write_log('Entering Attribute Header validation');
-- 1.Currency  Code

FND_MESSAGE.SET_NAME('QP','QP_INVALID_ATTRIBUTE');
FND_MESSAGE.SET_TOKEN('ATTRIBUTE','CURRENCY CODE');
l_msg_txt := FND_MESSAGE.GET;


INSERT INTO QP_INTERFACE_ERRORS
   (error_id,last_update_date, last_updated_by, creation_date,
    created_by, last_update_login, request_id, program_application_id,
    program_id, program_update_date, entity_type, table_name, column_name,
    orig_sys_header_ref,orig_sys_line_ref,orig_sys_qualifier_ref,
    orig_sys_pricing_attr_ref, error_message)
    	SELECT
     	qp_interface_errors_s.nextval, sysdate ,FND_GLOBAL.USER_ID, sysdate,
     	FND_GLOBAL.USER_ID, FND_GLOBAL.CONC_LOGIN_ID, qpih.request_id, 661,
     	NULL,NULL, 'PRL', 'QP_INTERFACE_LIST_HEADERS', 'CURRENCY_CODE',
     	qpih.orig_sys_header_ref,null,null,null,l_msg_txt
    	FROM QP_INTERFACE_LIST_HEADERS qpih
    	WHERE qpih.request_id = p_request_id
      	AND qpih.process_status_flag ='P' --is null
        AND qpih.currency_code is not null
	AND qpih.interface_action_code IN ('INSERT', 'UPDATE')
      	AND NOT EXISTS (SELECT currency_code -- Validation
     		      FROM fnd_currencies_vl
     		      WHERE enabled_flag = 'Y'
     		      AND currency_flag='Y'
     		      AND currency_code = qpih.currency_code
                      );

 -- 2.Freight Terms

FND_MESSAGE.SET_NAME('QP','QP_INVALID_ATTRIBUTE');
FND_MESSAGE.SET_TOKEN('ATTRIBUTE', 'FREIGHT TERMS');
l_msg_txt := FND_MESSAGE.GET;

--Bug# 5412029 START RAVI
--Check if the frieght terms are valid
    INSERT INTO QP_INTERFACE_ERRORS
   (error_id,last_update_date, last_updated_by, creation_date,
    created_by, last_update_login, request_id, program_application_id,
    program_id, program_update_date, entity_type, table_name, column_name,
    orig_sys_header_ref,orig_sys_line_ref,orig_sys_qualifier_ref,
    orig_sys_pricing_attr_ref, error_message)
    SELECT
     qp_interface_errors_s.nextval, sysdate ,FND_GLOBAL.USER_ID, sysdate,
     FND_GLOBAL.USER_ID, FND_GLOBAL.CONC_LOGIN_ID, qpih.request_id, 661,
     NULL,NULL, 'PRL', 'QP_INTERFACE_LIST_HEADERS', 'FREIGHT TERMS',
     qpih.orig_sys_header_ref,null,null,null, l_msg_txt
    FROM QP_INTERFACE_LIST_HEADERS qpih
    WHERE qpih.request_id = p_request_id
      AND  qpih.process_status_flag ='P' --is null
      AND  qpih.interface_action_code IN ('INSERT', 'UPDATE')
      AND qpih.freight_terms_code IS NOT NULL
      AND qpih.freight_terms_code <> QP_BULK_LOADER_PUB.G_NULL_CHAR
      AND qpih.freight_terms IS NOT NULL
      AND NOT EXISTS (SELECT   freight_terms_code
                      	   FROM     OE_FRGHT_TERMS_ACTIVE_V
                      	   WHERE    freight_terms_code = qpih.freight_terms_code
                           AND      freight_terms = qpih.freight_terms
                      	   AND    sysdate BETWEEN nvl(start_date_active, sysdate)
                                              AND    nvl(end_date_active, sysdate));

    INSERT INTO QP_INTERFACE_ERRORS
   (error_id,last_update_date, last_updated_by, creation_date,
    created_by, last_update_login, request_id, program_application_id,
    program_id, program_update_date, entity_type, table_name, column_name,
    orig_sys_header_ref,orig_sys_line_ref,orig_sys_qualifier_ref,
    orig_sys_pricing_attr_ref, error_message)
    SELECT
     qp_interface_errors_s.nextval, sysdate ,FND_GLOBAL.USER_ID, sysdate,
     FND_GLOBAL.USER_ID, FND_GLOBAL.CONC_LOGIN_ID, qpih.request_id, 661,
     NULL,NULL, 'PRL', 'QP_INTERFACE_LIST_HEADERS', 'FREIGHT TERMS',
     qpih.orig_sys_header_ref,null,null,null, l_msg_txt
    FROM QP_INTERFACE_LIST_HEADERS qpih
    WHERE qpih.request_id = p_request_id
      AND  qpih.process_status_flag ='P' --is null
      AND  qpih.interface_action_code IN ('INSERT', 'UPDATE')
      AND qpih.freight_terms IS NOT NULL
      AND qpih.freight_terms_code IS NULL
      AND NOT EXISTS (SELECT   freight_terms_code
                      	   FROM     OE_FRGHT_TERMS_ACTIVE_V
                      	   WHERE    freight_terms = qpih.freight_terms
                      	   AND    sysdate BETWEEN nvl(start_date_active, sysdate)
                                              AND    nvl(end_date_active, sysdate));

    INSERT INTO QP_INTERFACE_ERRORS
   (error_id,last_update_date, last_updated_by, creation_date,
    created_by, last_update_login, request_id, program_application_id,
    program_id, program_update_date, entity_type, table_name, column_name,
    orig_sys_header_ref,orig_sys_line_ref,orig_sys_qualifier_ref,
    orig_sys_pricing_attr_ref, error_message)
    SELECT
     qp_interface_errors_s.nextval, sysdate ,FND_GLOBAL.USER_ID, sysdate,
     FND_GLOBAL.USER_ID, FND_GLOBAL.CONC_LOGIN_ID, qpih.request_id, 661,
     NULL,NULL, 'PRL', 'QP_INTERFACE_LIST_HEADERS', 'FREIGHT TERMS',
     qpih.orig_sys_header_ref,null,null,null, l_msg_txt
    FROM QP_INTERFACE_LIST_HEADERS qpih
    WHERE qpih.request_id = p_request_id
      AND  qpih.process_status_flag ='P' --is null
      AND  qpih.interface_action_code IN ('INSERT', 'UPDATE')
      AND qpih.freight_terms IS NULL
      AND qpih.freight_terms_code IS NOT NULL
      AND qpih.freight_terms_code <> QP_BULK_LOADER_PUB.G_NULL_CHAR
      AND NOT EXISTS (SELECT   freight_terms_code
                      	   FROM     OE_FRGHT_TERMS_ACTIVE_V
                      	   WHERE    freight_terms_code = qpih.freight_terms_code
                      	   AND    sysdate BETWEEN nvl(start_date_active, sysdate)
                                              AND    nvl(end_date_active, sysdate));
--Bug# 5412029 END RAVI

-- 3.  LIST TYPE CODE

FND_MESSAGE.SET_NAME('QP','QP_INVALID_ATTRIBUTE');
FND_MESSAGE.SET_TOKEN('ATTRIBUTE','LIST TYPE CODE');
l_msg_txt := FND_MESSAGE.GET;

    INSERT INTO QP_INTERFACE_ERRORS
   (error_id,last_update_date, last_updated_by, creation_date,
    created_by, last_update_login, request_id, program_application_id,
    program_id, program_update_date, entity_type, table_name, column_name,
    orig_sys_header_ref,orig_sys_line_ref,orig_sys_qualifier_ref,
    orig_sys_pricing_attr_ref, error_message)
    SELECT
     qp_interface_errors_s.nextval, sysdate ,FND_GLOBAL.USER_ID, sysdate,
     FND_GLOBAL.USER_ID, FND_GLOBAL.CONC_LOGIN_ID, qpih.request_id, 661,
     NULL,NULL, 'PRL', 'QP_INTERFACE_LIST_HEADERS', 'LIST_TYPE_CODE',
     qpih.orig_sys_header_ref,null,null,null,l_msg_txt
    FROM QP_INTERFACE_LIST_HEADERS qpih
    WHERE qpih.request_id = p_request_id
         AND   qpih.process_status_flag ='P' --is null
         AND   qpih.interface_action_code IN ('INSERT', 'UPDATE')
         AND   qpih.list_type_code IS NOT NULL
         AND   NOT EXISTS (SELECT lookup_code
     		      FROM qp_lookups
     	      	      WHERE lookup_type = 'LIST_TYPE_CODE'
     		      AND lookup_code   = qpih.list_type_code);

-- 4.Ship Method(Freight Carrier)

FND_MESSAGE.SET_NAME('QP','QP_INVALID_ATTRIBUTE');
FND_MESSAGE.SET_TOKEN('ATTRIBUTE', 'FREIGHT CARRIER');
l_msg_txt := FND_MESSAGE.GET;

--Bug# 5412029 START RAVI
--Check if the ship method are valid
    INSERT INTO QP_INTERFACE_ERRORS
   (error_id,last_update_date, last_updated_by, creation_date,
    created_by, last_update_login, request_id, program_application_id,
    program_id, program_update_date, entity_type, table_name, column_name,
    orig_sys_header_ref,orig_sys_line_ref,orig_sys_qualifier_ref,
    orig_sys_pricing_attr_ref,  error_message)
    SELECT
     qp_interface_errors_s.nextval, sysdate ,FND_GLOBAL.USER_ID, sysdate,
     FND_GLOBAL.USER_ID, FND_GLOBAL.CONC_LOGIN_ID, qpih.request_id, 661,
     NULL,NULL, 'PRL', 'QP_INTERFACE_LIST_HEADERS',  'FRIEGHT CARRIER',
     qpih.orig_sys_header_ref, null,null,null,l_msg_txt
    FROM QP_INTERFACE_LIST_HEADERS qpih
    WHERE qpih.request_id = p_request_id
      AND  qpih.process_status_flag ='P' --is null
      AND  qpih.interface_action_code IN ('INSERT', 'UPDATE')
      AND qpih.ship_method IS NOT NULL
      AND qpih.ship_method_code IS NOT NULL
      AND qpih.ship_method_code <> QP_BULK_LOADER_PUB.G_NULL_CHAR
      AND NOT EXISTS (SELECT LOOKUP_CODE
    		        FROM OE_SHIP_METHODS_V
    		       WHERE LOOKUP_TYPE = 'SHIP_METHOD'
    		       AND  LOOKUP_CODE = qpih.ship_method_code
    		       AND  MEANING = qpih.ship_method
    		       AND  sysdate BETWEEN nvl(start_date_active, sysdate)
                                     AND    nvl(end_date_active, sysdate) );

    INSERT INTO QP_INTERFACE_ERRORS
   (error_id,last_update_date, last_updated_by, creation_date,
    created_by, last_update_login, request_id, program_application_id,
    program_id, program_update_date, entity_type, table_name, column_name,
    orig_sys_header_ref,orig_sys_line_ref,orig_sys_qualifier_ref,
    orig_sys_pricing_attr_ref,  error_message)
    SELECT
     qp_interface_errors_s.nextval, sysdate ,FND_GLOBAL.USER_ID, sysdate,
     FND_GLOBAL.USER_ID, FND_GLOBAL.CONC_LOGIN_ID, qpih.request_id, 661,
     NULL,NULL, 'PRL', 'QP_INTERFACE_LIST_HEADERS',  'FRIEGHT CARRIER',
     qpih.orig_sys_header_ref, null,null,null,l_msg_txt
    FROM QP_INTERFACE_LIST_HEADERS qpih
    WHERE qpih.request_id = p_request_id
      AND  qpih.process_status_flag ='P' --is null
      AND  qpih.interface_action_code IN ('INSERT', 'UPDATE')
      AND qpih.ship_method IS NULL
      AND qpih.ship_method_code IS NOT NULL
      AND qpih.ship_method_code <> QP_BULK_LOADER_PUB.G_NULL_CHAR
      AND NOT EXISTS (SELECT LOOKUP_CODE
    		        FROM OE_SHIP_METHODS_V
    		       WHERE LOOKUP_TYPE = 'SHIP_METHOD'
    		       AND  LOOKUP_CODE = qpih.ship_method_code
    		       AND  sysdate BETWEEN nvl(start_date_active, sysdate)
                                     AND    nvl(end_date_active, sysdate) );

    INSERT INTO QP_INTERFACE_ERRORS
   (error_id,last_update_date, last_updated_by, creation_date,
    created_by, last_update_login, request_id, program_application_id,
    program_id, program_update_date, entity_type, table_name, column_name,
    orig_sys_header_ref,orig_sys_line_ref,orig_sys_qualifier_ref,
    orig_sys_pricing_attr_ref,  error_message)
    SELECT
     qp_interface_errors_s.nextval, sysdate ,FND_GLOBAL.USER_ID, sysdate,
     FND_GLOBAL.USER_ID, FND_GLOBAL.CONC_LOGIN_ID, qpih.request_id, 661,
     NULL,NULL, 'PRL', 'QP_INTERFACE_LIST_HEADERS',  'FRIEGHT CARRIER',
     qpih.orig_sys_header_ref, null,null,null,l_msg_txt
    FROM QP_INTERFACE_LIST_HEADERS qpih
    WHERE qpih.request_id = p_request_id
      AND  qpih.process_status_flag ='P' --is null
      AND  qpih.interface_action_code IN ('INSERT', 'UPDATE')
      AND qpih.ship_method IS NOT NULL
      AND qpih.ship_method_code IS NULL
      AND NOT EXISTS (SELECT LOOKUP_CODE
    		        FROM OE_SHIP_METHODS_V
    		       WHERE LOOKUP_TYPE = 'SHIP_METHOD'
    		       AND  MEANING = qpih.ship_method
    		       AND  sysdate BETWEEN nvl(start_date_active, sysdate)
                                     AND    nvl(end_date_active, sysdate) );
--Bug# 5412029 END RAVI

-- 5. Payment Terms
FND_MESSAGE.SET_NAME('QP','QP_INVALID_ATTRIBUTE');
FND_MESSAGE.SET_TOKEN('ATTRIBUTE', 'PAYMENT TERMS');
l_msg_txt := FND_MESSAGE.GET;

--Bug# 5412029 START RAVI
--Check if the payment terms are valid
    INSERT INTO QP_INTERFACE_ERRORS
   (error_id,last_update_date, last_updated_by, creation_date,
    created_by, last_update_login, request_id, program_application_id,
    program_id, program_update_date, entity_type, table_name, column_name,
    orig_sys_header_ref,orig_sys_line_ref,orig_sys_qualifier_ref,
    orig_sys_pricing_attr_ref, error_message)
    SELECT
     qp_interface_errors_s.nextval, sysdate ,FND_GLOBAL.USER_ID, sysdate,
     FND_GLOBAL.USER_ID, FND_GLOBAL.CONC_LOGIN_ID, qpih.request_id, 661,
     NULL,NULL, 'PRL', 'QP_INTERFACE_LIST_HEADERS', 'PAYMENT TERMS',
     qpih.orig_sys_header_ref,null,null,null,l_msg_txt
    FROM QP_INTERFACE_LIST_HEADERS qpih
    WHERE qpih.request_id = p_request_id
      AND  qpih.process_status_flag ='P' --is null
      AND  qpih.interface_action_code IN ('INSERT', 'UPDATE')
      AND qpih.terms_id IS NOT NULL
      AND qpih.terms IS NOT NULL
      AND qpih.terms <> QP_BULK_LOADER_PUB.G_NULL_CHAR
      --Bug#5248659 RAVI
      --Use Term_id not terms_id
      AND NOT EXISTS (SELECT   TERM_ID
                      FROM     RA_TERMS
                      WHERE    TERM_ID = qpih.terms_id
                        AND    name = qpih.terms
                        AND    sysdate BETWEEN nvl(start_date_active, sysdate)
                                     AND    nvl(end_date_active, sysdate) );

    INSERT INTO QP_INTERFACE_ERRORS
   (error_id,last_update_date, last_updated_by, creation_date,
    created_by, last_update_login, request_id, program_application_id,
    program_id, program_update_date, entity_type, table_name, column_name,
    orig_sys_header_ref,orig_sys_line_ref,orig_sys_qualifier_ref,
    orig_sys_pricing_attr_ref, error_message)
    SELECT
     qp_interface_errors_s.nextval, sysdate ,FND_GLOBAL.USER_ID, sysdate,
     FND_GLOBAL.USER_ID, FND_GLOBAL.CONC_LOGIN_ID, qpih.request_id, 661,
     NULL,NULL, 'PRL', 'QP_INTERFACE_LIST_HEADERS', 'PAYMENT TERMS',
     qpih.orig_sys_header_ref,null,null,null,l_msg_txt
    FROM QP_INTERFACE_LIST_HEADERS qpih
    WHERE qpih.request_id = p_request_id
      AND  qpih.process_status_flag ='P' --is null
      AND  qpih.interface_action_code IN ('INSERT', 'UPDATE')
      AND qpih.terms_id IS NOT NULL
      AND qpih.terms IS NULL
      --Bug#5248659 RAVI
      --Use Term_id not terms_id
      AND NOT EXISTS (SELECT   TERM_ID
                      FROM     RA_TERMS
                      WHERE    TERM_ID = qpih.terms_id
                        AND    sysdate BETWEEN nvl(start_date_active, sysdate)
                                     AND    nvl(end_date_active, sysdate) );

    INSERT INTO QP_INTERFACE_ERRORS
   (error_id,last_update_date, last_updated_by, creation_date,
    created_by, last_update_login, request_id, program_application_id,
    program_id, program_update_date, entity_type, table_name, column_name,
    orig_sys_header_ref,orig_sys_line_ref,orig_sys_qualifier_ref,
    orig_sys_pricing_attr_ref, error_message)
    SELECT
     qp_interface_errors_s.nextval, sysdate ,FND_GLOBAL.USER_ID, sysdate,
     FND_GLOBAL.USER_ID, FND_GLOBAL.CONC_LOGIN_ID, qpih.request_id, 661,
     NULL,NULL, 'PRL', 'QP_INTERFACE_LIST_HEADERS', 'PAYMENT TERMS',
     qpih.orig_sys_header_ref,null,null,null,l_msg_txt
    FROM QP_INTERFACE_LIST_HEADERS qpih
    WHERE qpih.request_id = p_request_id
      AND  qpih.process_status_flag ='P' --is null
      AND  qpih.interface_action_code IN ('INSERT', 'UPDATE')
      AND qpih.terms_id IS NULL
      AND qpih.terms IS NOT NULL
      AND qpih.terms <> QP_BULK_LOADER_PUB.G_NULL_CHAR
      --Bug#5248659 RAVI
      --Use Term_id not terms_id
      AND NOT EXISTS (SELECT   TERM_ID
                      FROM     RA_TERMS
                      WHERE    name = qpih.terms
                        AND    sysdate BETWEEN nvl(start_date_active, sysdate)
                                     AND    nvl(end_date_active, sysdate) );

--Bug# 5412029 END RAVI
  -- 6. Currency Header

FND_MESSAGE.SET_NAME('QP','QP_INVALID_ATTRIBUTE');
FND_MESSAGE.SET_TOKEN('ATTRIBUTE', 'CURRENCY HEADER');
l_msg_txt := FND_MESSAGE.GET;

-- Bug 4938046,5412029 START RAVI
/**
Currency Header and Header ID validation
**/

INSERT INTO QP_INTERFACE_ERRORS
   (error_id,last_update_date, last_updated_by, creation_date,
    created_by, last_update_login, request_id, program_application_id,
    program_id, program_update_date, entity_type, table_name, column_name,
    orig_sys_header_ref,orig_sys_line_ref,orig_sys_qualifier_ref,
    orig_sys_pricing_attr_ref,  error_message)
    SELECT
     qp_interface_errors_s.nextval, sysdate ,FND_GLOBAL.USER_ID, sysdate,
     FND_GLOBAL.USER_ID, FND_GLOBAL.CONC_LOGIN_ID, qpih.request_id, 661,
     NULL,NULL, 'PRL', 'QP_INTERFACE_LIST_HEADERS',  'CURRENCY_HEADER',
     qpih.orig_sys_header_ref,null,null,null,l_msg_txt
    FROM QP_INTERFACE_LIST_HEADERS qpih
    WHERE qpih.request_id = p_request_id
      AND qpih.process_status_flag ='P' --is null
      AND qpih.interface_action_code IN ('INSERT', 'UPDATE')
      AND qpih.currency_header_id is NOT NULL
      AND qpih.currency_header is NOT NULL
      AND qpih.currency_header <> QP_BULK_LOADER_PUB.G_NULL_CHAR
      AND NOT EXISTS ( SELECT qpclb.currency_header_id
		       FROM   qp_currency_lists_b qpclb, qp_currency_lists_tl qpclt
		       WHERE  qpclb.currency_header_id = qpih.currency_header_id
               AND    qpclb.base_currency_code = qpih.currency_code
               AND    qpclt.currency_header_id = qpclb.currency_header_id
               AND    qpclt.language = nvl(qpih.language,'US')
               AND    qpclt.name = qpih.currency_header);

INSERT INTO QP_INTERFACE_ERRORS
   (error_id,last_update_date, last_updated_by, creation_date,
    created_by, last_update_login, request_id, program_application_id,
    program_id, program_update_date, entity_type, table_name, column_name,
    orig_sys_header_ref,orig_sys_line_ref,orig_sys_qualifier_ref,
    orig_sys_pricing_attr_ref,  error_message)
    SELECT
     qp_interface_errors_s.nextval, sysdate ,FND_GLOBAL.USER_ID, sysdate,
     FND_GLOBAL.USER_ID, FND_GLOBAL.CONC_LOGIN_ID, qpih.request_id, 661,
     NULL,NULL, 'PRL', 'QP_INTERFACE_LIST_HEADERS',  'CURRENCY_HEADER',
     qpih.orig_sys_header_ref,null,null,null,l_msg_txt
    FROM QP_INTERFACE_LIST_HEADERS qpih
    WHERE qpih.request_id = p_request_id
      AND  qpih.process_status_flag ='P' --is null
      AND  qpih.interface_action_code IN ('INSERT', 'UPDATE')
      AND  qpih.currency_header is NOT NULL
      AND  qpih.currency_header <> QP_BULK_LOADER_PUB.G_NULL_CHAR
      AND  qpih.currency_header_id is NULL
      AND NOT EXISTS ( SELECT qpclb.currency_header_id
		       FROM   qp_currency_lists_b qpclb, qp_currency_lists_tl qpclt
		       WHERE  qpclb.base_currency_code = qpih.currency_code
               AND    qpclt.currency_header_id = qpclb.currency_header_id
               AND    qpclt.language = nvl(qpih.language,'US')
               AND    qpclt.name = qpih.currency_header);

INSERT INTO QP_INTERFACE_ERRORS
   (error_id,last_update_date, last_updated_by, creation_date,
    created_by, last_update_login, request_id, program_application_id,
    program_id, program_update_date, entity_type, table_name, column_name,
    orig_sys_header_ref,orig_sys_line_ref,orig_sys_qualifier_ref,
    orig_sys_pricing_attr_ref,  error_message)
    SELECT
     qp_interface_errors_s.nextval, sysdate ,FND_GLOBAL.USER_ID, sysdate,
     FND_GLOBAL.USER_ID, FND_GLOBAL.CONC_LOGIN_ID, qpih.request_id, 661,
     NULL,NULL, 'PRL', 'QP_INTERFACE_LIST_HEADERS',  'CURRENCY_HEADER',
     qpih.orig_sys_header_ref,null,null,null,l_msg_txt
    FROM QP_INTERFACE_LIST_HEADERS qpih
    WHERE qpih.request_id = p_request_id
      AND  qpih.process_status_flag ='P' --is null
      AND  qpih.interface_action_code IN ('INSERT', 'UPDATE')
      AND  qpih.currency_header_id is NOT NULL
      AND  qpih.currency_header is NULL
      AND NOT EXISTS ( SELECT qpclb.currency_header_id
		       FROM   qp_currency_lists_b qpclb
		       WHERE  qpclb.currency_header_id = qpih.currency_header_id
                       AND    qpclb.base_currency_code = qpih.currency_code);
-- Bug 4938046,5412029 END RAVI

  -- 7. Name

fnd_message.set_name('QP', 'QP_ATTRIBUTE_REQUIRED');
FND_MESSAGE.SET_TOKEN('ATTRIBUTE', 'NAME');
l_msg_txt := FND_MESSAGE.GET;

INSERT INTO QP_INTERFACE_ERRORS
   (error_id,last_update_date, last_updated_by, creation_date,
    created_by, last_update_login, request_id, program_application_id,
    program_id, program_update_date, entity_type, table_name, column_name,
    orig_sys_header_ref,orig_sys_line_ref,orig_sys_qualifier_ref,
    orig_sys_pricing_attr_ref,  error_message)
    SELECT
     qp_interface_errors_s.nextval, sysdate ,FND_GLOBAL.USER_ID, sysdate,
     FND_GLOBAL.USER_ID, FND_GLOBAL.CONC_LOGIN_ID, qpih.request_id, 661,
     NULL,NULL, 'PRL', 'QP_INTERFACE_LIST_HEADERS',  'Name',
     qpih.orig_sys_header_ref,null,null,null,l_msg_txt
    FROM QP_INTERFACE_LIST_HEADERS qpih
    WHERE qpih.request_id = p_request_id
      AND  qpih.process_status_flag ='P' --is null
--      AND  qpih.interface_action_code IN ('INSERT', 'UPDATE')
      AND  qpih.interface_action_code IN ('INSERT')
      AND  (name is null or name = '');

  -- 8. Name in other pricelists

fnd_message.set_name('QP', 'SO_OTHER_NAME_ALREADY_IN_USE');
l_msg_txt := FND_MESSAGE.GET;

 qp_bulk_loader_pub.write_log('Name check in TL table '||userenv('LANG')||' '||to_char(p_request_id));

INSERT INTO QP_INTERFACE_ERRORS
   (error_id,last_update_date, last_updated_by, creation_date,
    created_by, last_update_login, request_id, program_application_id,
    program_id, program_update_date, entity_type, table_name, column_name,
    orig_sys_header_ref,orig_sys_line_ref,orig_sys_qualifier_ref,
    orig_sys_pricing_attr_ref,  error_message)
    SELECT
     qp_interface_errors_s.nextval, sysdate ,FND_GLOBAL.USER_ID, sysdate,
     FND_GLOBAL.USER_ID, FND_GLOBAL.CONC_LOGIN_ID, qpih.request_id, 661,
     NULL,NULL, 'PRL', 'QP_INTERFACE_LIST_HEADERS',  'Name',
     qpih.orig_sys_header_ref,null,null,null,l_msg_txt
    FROM QP_INTERFACE_LIST_HEADERS qpih
    WHERE qpih.request_id = p_request_id
      AND  qpih.process_status_flag ='P' --is null
      AND  qpih.interface_action_code IN ('INSERT')
      AND EXISTS ( Select qlht.name from qp_list_headers_tl qlht
	     	   where qlht.name= qpih.name
	           and qlht.language = qpih.language);

 qp_bulk_loader_pub.write_log('Count '||SQL%ROWCOUNT);

  -- 9. Name in other Interface header records

fnd_message.set_name('QP', 'SO_OTHER_NAME_ALREADY_IN_USE');
l_msg_txt := FND_MESSAGE.GET;

INSERT INTO QP_INTERFACE_ERRORS
   (error_id,last_update_date, last_updated_by, creation_date,
    created_by, last_update_login, request_id, program_application_id,
    program_id, program_update_date, entity_type, table_name, column_name,
    orig_sys_header_ref,orig_sys_line_ref,orig_sys_qualifier_ref,
    orig_sys_pricing_attr_ref,  error_message)
    SELECT
     qp_interface_errors_s.nextval, sysdate ,FND_GLOBAL.USER_ID, sysdate,
     FND_GLOBAL.USER_ID, FND_GLOBAL.CONC_LOGIN_ID, qpih.request_id, 661,
     NULL,NULL, 'PRL', 'QP_INTERFACE_LIST_HEADERS',  'Name',
     qpih.orig_sys_header_ref,null,null,null,l_msg_txt
    FROM QP_INTERFACE_LIST_HEADERS qpih
    WHERE qpih.request_id = p_request_id
      AND  qpih.process_status_flag ='P' --is null
      AND  qpih.interface_action_code IN ('INSERT')
      AND EXISTS ( Select 'x' from qp_interface_list_headers qpih1
		  where qpih1.request_id = p_request_id
		    and qpih1.name = qpih.name
		    and qpih1.process_status_flag is null
		    and qpih1.rowid <> qpih.rowid
		    and qpih1.interface_action_code = 'INSERT');
 qp_bulk_loader_pub.write_log('Count 9 '||SQL%ROWCOUNT);

  -- 10. Pricing Transaction Entity

FND_MESSAGE.SET_NAME('QP','QP_INVALID_ATTRIBUTE');
FND_MESSAGE.SET_TOKEN('ATTRIBUTE', 'Pricing Transaction Entity');
l_msg_txt := FND_MESSAGE.GET;

INSERT INTO QP_INTERFACE_ERRORS
   (error_id,last_update_date, last_updated_by, creation_date,
    created_by, last_update_login, request_id, program_application_id,
    program_id, program_update_date, entity_type, table_name, column_name,
    orig_sys_header_ref,orig_sys_line_ref,orig_sys_qualifier_ref,
    orig_sys_pricing_attr_ref,  error_message)
    SELECT
     qp_interface_errors_s.nextval, sysdate ,FND_GLOBAL.USER_ID, sysdate,
     FND_GLOBAL.USER_ID, FND_GLOBAL.CONC_LOGIN_ID, qpih.request_id, 661,
     NULL,NULL, 'PRL', 'QP_INTERFACE_LIST_HEADERS',  'pte_code',
     qpih.orig_sys_header_ref,null,null,null,l_msg_txt
    FROM QP_INTERFACE_LIST_HEADERS qpih
    WHERE qpih.request_id = p_request_id
      AND  qpih.process_status_flag ='P' --is null
      AND   qpih.interface_action_code IN ('INSERT', 'UPDATE')
      AND   qpih.pte_code IS NOT NULL
      AND   NOT EXISTS (SELECT lookup_code
     		      FROM qp_lookups
     	      	      WHERE lookup_type = 'QP_PTE_TYPE'
     		      AND  lookup_code   = qpih.pte_code);

  -- 11. Source System Code

FND_MESSAGE.SET_NAME('QP','QP_INVALID_ATTRIBUTE');
FND_MESSAGE.SET_TOKEN('ATTRIBUTE', 'Source System Code');
l_msg_txt := FND_MESSAGE.GET;

INSERT INTO QP_INTERFACE_ERRORS
   (error_id,last_update_date, last_updated_by, creation_date,
    created_by, last_update_login, request_id, program_application_id,
    program_id, program_update_date, entity_type, table_name, column_name,
    orig_sys_header_ref,orig_sys_line_ref,orig_sys_qualifier_ref,
    orig_sys_pricing_attr_ref,  error_message)
    SELECT
     qp_interface_errors_s.nextval, sysdate ,FND_GLOBAL.USER_ID, sysdate,
     FND_GLOBAL.USER_ID, FND_GLOBAL.CONC_LOGIN_ID, qpih.request_id, 661,
     NULL,NULL, 'PRL', 'QP_INTERFACE_LIST_HEADERS',  'Name',
     qpih.orig_sys_header_ref,null,null,null,l_msg_txt
    FROM QP_INTERFACE_LIST_HEADERS qpih
    WHERE qpih.request_id = p_request_id
      AND  qpih.process_status_flag ='P' --is null
      AND  qpih.interface_action_code IN ('INSERT', 'UPDATE')
      AND   qpih.source_system_code IS NOT NULL
      AND   NOT EXISTS (SELECT lookup_code
     		      FROM qp_lookups
     	      	      WHERE lookup_type = 'SOURCE_SYSTEM'
     		      AND  lookup_code   = qpih.source_system_code);

-- Bug 5208365 RAVI
INSERT INTO QP_INTERFACE_ERRORS
   (error_id,last_update_date, last_updated_by, creation_date,
    created_by, last_update_login, request_id, program_application_id,
    program_id, program_update_date, entity_type, table_name, column_name,
    orig_sys_header_ref,orig_sys_line_ref,orig_sys_qualifier_ref,
    orig_sys_pricing_attr_ref,  error_message)
    SELECT
     qp_interface_errors_s.nextval, sysdate ,FND_GLOBAL.USER_ID, sysdate,
     FND_GLOBAL.USER_ID, FND_GLOBAL.CONC_LOGIN_ID, qpih.request_id, 661,
     NULL,NULL, 'PRL', 'QP_INTERFACE_LIST_HEADERS',  'Name',
     qpih.orig_sys_header_ref,null,null,null,l_msg_txt
    FROM QP_INTERFACE_LIST_HEADERS qpih
    WHERE qpih.request_id = p_request_id
      AND  qpih.process_status_flag ='P' --is null
      AND  qpih.interface_action_code IN ('INSERT', 'UPDATE')
      -- Bug 5416556 RAVI
      --Only Price Lists with source system code equal to FND_PROFILE.VALUE('QP_SOURCE_SYSTEM_CODE') should be updated.
      AND   qpih.source_system_code <> FND_PROFILE.VALUE('QP_SOURCE_SYSTEM_CODE');

--for bug 4731613 moved this validation to attribute_header procedure
  -- 12. Validate Orig_Org_Id

FND_MESSAGE.SET_NAME('FND','FND_MO_ORG_INVALID');
--FND_MESSAGE.SET_TOKEN('ATTRIBUTE', 'Source System Code');
l_msg_txt := FND_MESSAGE.GET;

INSERT INTO QP_INTERFACE_ERRORS
   (error_id,last_update_date, last_updated_by, creation_date,
    created_by, last_update_login, request_id, program_application_id,
    program_id, program_update_date, entity_type, table_name, column_name,
    orig_sys_header_ref,orig_sys_line_ref,orig_sys_qualifier_ref,
    orig_sys_pricing_attr_ref,  error_message)
    SELECT
     qp_interface_errors_s.nextval, sysdate ,FND_GLOBAL.USER_ID, sysdate,
     FND_GLOBAL.USER_ID, FND_GLOBAL.CONC_LOGIN_ID, qpih.request_id, 661,
     NULL,NULL, 'PRL', 'QP_INTERFACE_LIST_HEADERS',  'Name',
     qpih.orig_sys_header_ref,null,null,null,l_msg_txt
    FROM QP_INTERFACE_LIST_HEADERS qpih
    WHERE qpih.request_id = p_request_id
      AND  qpih.process_status_flag ='P' --is null
      AND  qpih.interface_action_code IN ('INSERT', 'UPDATE')
      AND   qpih.global_flag = 'N' and qpih.orig_org_id IS NOT NULL
      AND   QP_UTIL.validate_org_id(qpih.orig_org_id) = 'N';

  --Bug#5208112 RAVI START
  -- 13. Validate Rounding Factor

  FND_MESSAGE.SET_NAME('QP','QP_ROUNDING_FACTOR_NO_UPDATE');
  l_msg_txt := FND_MESSAGE.GET;

  INSERT INTO QP_INTERFACE_ERRORS
   (error_id,last_update_date, last_updated_by, creation_date,
    created_by, last_update_login, request_id, program_application_id,
    program_id, program_update_date, entity_type, table_name, column_name,
    orig_sys_header_ref,orig_sys_line_ref,orig_sys_qualifier_ref,
    orig_sys_pricing_attr_ref,  error_message)
    SELECT
     qp_interface_errors_s.nextval, sysdate ,FND_GLOBAL.USER_ID, sysdate,
     FND_GLOBAL.USER_ID, FND_GLOBAL.CONC_LOGIN_ID, qpih.request_id, 661,
     NULL,NULL, 'PRL', 'QP_INTERFACE_LIST_HEADERS',  'ROUNDING_FACTOR',
     qpih.orig_sys_header_ref,null,null,null,l_msg_txt
    FROM QP_INTERFACE_LIST_HEADERS qpih
    WHERE qpih.request_id = p_request_id
      AND qpih.process_status_flag ='P' --is null
      AND qpih.interface_action_code ='UPDATE'
      AND EXISTS(
            select 1 from qp_list_headers qplh
            where qplh.orig_system_header_ref=qpih.orig_sys_header_ref
            and qplh.rounding_factor <> qpih.rounding_factor
            );
  --Bug#5208112 RAVI END

  -- Bug#3604226 RAVI START

  -- 14. Only one record with a unique Orig_Sys_Hdr_ref must be updated in one request
  -- Commenting code for bug 6961376

  /*fnd_message.set_name('QP', 'QP_HDR_REF_MULTIPLE_UPDATE');
  l_msg_txt := FND_MESSAGE.GET;

  INSERT INTO QP_INTERFACE_ERRORS
   (error_id,last_update_date, last_updated_by, creation_date,
    created_by, last_update_login, request_id, program_application_id,
    program_id, program_update_date, entity_type, table_name, column_name,
    orig_sys_header_ref,orig_sys_line_ref,orig_sys_qualifier_ref,
    orig_sys_pricing_attr_ref,  error_message)
    SELECT
     qp_interface_errors_s.nextval, sysdate ,FND_GLOBAL.USER_ID, sysdate,
     FND_GLOBAL.USER_ID, FND_GLOBAL.CONC_LOGIN_ID, qpih.request_id, 661,
     NULL,NULL, 'PRL', 'QP_INTERFACE_LIST_HEADERS',  'ORIG_SYS_HEADER_REF',
     qpih.orig_sys_header_ref,null,null,null,l_msg_txt
    FROM QP_INTERFACE_LIST_HEADERS qpih
    WHERE qpih.request_id = p_request_id
      AND qpih.process_status_flag ='P' --is null
      AND qpih.interface_action_code IN ('UPDATE', 'DELETE')
      AND ( select count(*) from qp_interface_list_headers qplh
            where qplh.orig_sys_header_ref=qpih.orig_sys_header_ref
            ) > 1;*/
  --Bug#3604226 RAVI END


 qp_bulk_loader_pub.write_log('Leaving Attribute Header validation');

 EXCEPTION
    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
       qp_bulk_loader_pub.write_log( 'UNEXCPECTED ERROR IN PROCEDURE ATTRIBUTE_HEADER:'||sqlerrm);
       RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    WHEN OTHERS THEN
       qp_bulk_loader_pub.write_log( 'UNEXCPECTED ERROR IN PROCEDURE ATTRIBUTE_HEADER:'||sqlerrm);
       RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

END ATTRIBUTE_HEADER;



PROCEDURE ATTRIBUTE_QUALIFIER
               (p_request_id NUMBER)
IS

   l_msg_txt VARCHAR2(240);
   l_pte_code VARCHAR2(30);

BEGIN

    qp_bulk_loader_pub.write_log('Entering Attribute qualifier validation');
    FND_PROFILE.GET('QP_PRICING_TRANSACTION_ENTITY',l_pte_code);
    --1. Comparison Operator

   FND_MESSAGE.SET_NAME('QP','QP_INVALID_ATTRIBUTE');
   FND_MESSAGE.SET_TOKEN('ATTRIBUTE','COMPARISON OPERATOR');
   l_msg_txt := FND_MESSAGE.GET;

    INSERT INTO QP_INTERFACE_ERRORS
   (error_id,last_update_date, last_updated_by, creation_date,
    created_by, last_update_login, request_id, program_application_id,
    program_id, program_update_date, entity_type, table_name, column_name,
    orig_sys_header_ref,orig_sys_line_ref,orig_sys_qualifier_ref,
    orig_sys_pricing_attr_ref,  error_message)
    SELECT
     qp_interface_errors_s.nextval, sysdate ,FND_GLOBAL.USER_ID, sysdate,
     FND_GLOBAL.USER_ID, FND_GLOBAL.CONC_LOGIN_ID, qpiq.request_id, 661,
     NULL,NULL, 'PRL', 'QP_INTERFACE_QUALIFIERS',  'COMPARISON_OPERATOR',
     qpiq.orig_sys_header_ref,null,qpiq.orig_sys_qualifier_ref,null, l_msg_txt
    FROM QP_INTERFACE_QUALIFIERS qpiq
    WHERE qpiq.request_id = p_request_id
      AND  qpiq.process_status_flag ='P' --is null
      AND  qpiq.interface_action_code IN ('INSERT', 'UPDATE')
      AND  qpiq.comparison_operator_code is NOT NULL
      AND NOT EXISTS ( SELECT  lookup_code
		       FROM     qp_lookups
		       WHERE lookup_type = 'COMPARISON_OPERATOR'
	               AND    lookup_code   = qpiq.comparison_operator_code);

   --2. Orig sys header ref

   FND_MESSAGE.SET_NAME('QP','QP_INVALID_ATTRIBUTE');
   FND_MESSAGE.SET_TOKEN('ATTRIBUTE','ORIG SYS HEADER REF');
   l_msg_txt := FND_MESSAGE.GET;

    INSERT INTO QP_INTERFACE_ERRORS
   (error_id,last_update_date, last_updated_by, creation_date,
    created_by, last_update_login, request_id, program_application_id,
    program_id, program_update_date, entity_type, table_name, column_name,
    orig_sys_header_ref,orig_sys_line_ref,orig_sys_qualifier_ref,
    orig_sys_pricing_attr_ref,error_message)
    SELECT
     qp_interface_errors_s.nextval, sysdate ,FND_GLOBAL.USER_ID, sysdate,
     FND_GLOBAL.USER_ID, FND_GLOBAL.CONC_LOGIN_ID, qpiq.request_id, 661,
     NULL,NULL, 'PRL', 'QP_INTERFACE_QUALIFIERS',  'ORIG_SYS_HEADER_REF',
     qpiq.orig_sys_header_ref,null,qpiq.orig_sys_qualifier_ref,null,l_msg_txt
    FROM QP_INTERFACE_QUALIFIERS qpiq
    WHERE qpiq.request_id = p_request_id
      AND  qpiq.process_status_flag ='P' --is null
      AND  qpiq.interface_action_code IN ('INSERT', 'UPDATE')
      AND  qpiq.orig_sys_header_ref is NOT NULL
      AND NOT EXISTS ( SELECT  orig_system_header_ref
		       FROM     qp_list_headers_b
		       WHERE  orig_system_header_ref = qpiq.orig_sys_header_ref);

    --3. Secondary Pricelist

-- Basic_Pricing_Condition
   -- In the case of Basic pricing only the qualifier of type secondary
   -- Pricelists are allowed.

   IF QP_BULK_LOADER_PUB.GET_QP_STATUS <> 'I' THEN

       FND_MESSAGE.SET_NAME('QP','QP_QUAL_NA_BASIC');
       --Qualifiers not allowed in Basic Pricing
       l_msg_txt := FND_MESSAGE.GET;

	INSERT INTO QP_INTERFACE_ERRORS
       (error_id,last_update_date, last_updated_by, creation_date,
	created_by, last_update_login, request_id, program_application_id,
	program_id, program_update_date, entity_type, table_name,
	orig_sys_header_ref,orig_sys_line_ref,orig_sys_qualifier_ref,
	orig_sys_pricing_attr_ref,  error_message)
	SELECT
	 qp_interface_errors_s.nextval, sysdate ,FND_GLOBAL.USER_ID, sysdate,
	 FND_GLOBAL.USER_ID, FND_GLOBAL.CONC_LOGIN_ID, qpiq.request_id, 661,
	 NULL,NULL, 'PRL', 'QP_INTERFACE_QUALIFIERS',
	 qpiq.orig_sys_header_ref,null,qpiq.orig_sys_qualifier_ref,null, l_msg_txt
	FROM QP_INTERFACE_QUALIFIERS qpiq
	WHERE qpiq.request_id = p_request_id
	  AND  qpiq.process_status_flag ='P' --is null
	  AND  qpiq.interface_action_code IN ('INSERT', 'UPDATE')
	  AND  (qpiq.qualifier_context <> 'MODLIST'
	    OR qpiq.qualifier_attribute <> 'QUALIFIER_ATTRIBUTE4');

  END IF;

   --4. Qualifier Context
       FND_MESSAGE.SET_NAME('QP','QP_ATTRIBUTE_REQUIRED');
       FND_MESSAGE.SET_TOKEN('ATTRIBUTE', 'QUALIFIER CONTEXT');

       l_msg_txt := FND_MESSAGE.GET;

	INSERT INTO QP_INTERFACE_ERRORS
       (error_id,last_update_date, last_updated_by, creation_date,
	created_by, last_update_login, request_id, program_application_id,
	program_id, program_update_date, entity_type, table_name,
	orig_sys_header_ref,orig_sys_line_ref,orig_sys_qualifier_ref,
	orig_sys_pricing_attr_ref,  error_message)
	SELECT
	 qp_interface_errors_s.nextval, sysdate ,FND_GLOBAL.USER_ID, sysdate,
	 FND_GLOBAL.USER_ID, FND_GLOBAL.CONC_LOGIN_ID, qpiq.request_id, 661,
	 NULL,NULL, 'PRL', 'QP_INTERFACE_QUALIFIERS',
	 qpiq.orig_sys_header_ref,null,qpiq.orig_sys_qualifier_ref,null, l_msg_txt
	FROM QP_INTERFACE_QUALIFIERS qpiq
	WHERE qpiq.request_id = p_request_id
	  AND  qpiq.process_status_flag ='P' --is null
	  AND  qpiq.interface_action_code IN ('INSERT', 'UPDATE')
	  AND  qpiq.qualifier_context IS NULL;

   --5. Qualifier Attribute

   FND_MESSAGE.SET_NAME('QP','QP_INVALID_ATTRIBUTE');
   FND_MESSAGE.SET_TOKEN('ATTRIBUTE','QUALIFIER ATTRIBUTE');
   l_msg_txt := FND_MESSAGE.GET;

--Bug# 5456164 START RAVI
--Validate qualifier attribute
    INSERT INTO QP_INTERFACE_ERRORS
   (error_id,last_update_date, last_updated_by, creation_date,
    created_by, last_update_login, request_id, program_application_id,
    program_id, program_update_date, entity_type, table_name, column_name,
    orig_sys_header_ref,orig_sys_line_ref,orig_sys_qualifier_ref,
    orig_sys_pricing_attr_ref,error_message)
    SELECT
     qp_interface_errors_s.nextval, sysdate ,FND_GLOBAL.USER_ID, sysdate,
     FND_GLOBAL.USER_ID, FND_GLOBAL.CONC_LOGIN_ID, qpiq.request_id, 661,
     NULL,NULL, 'PRL', 'QP_INTERFACE_QUALIFIERS',  'QUALIFIER_ATTRIBUTE',
     qpiq.orig_sys_header_ref,null,qpiq.orig_sys_qualifier_ref,null,l_msg_txt
    FROM QP_INTERFACE_QUALIFIERS qpiq
    WHERE qpiq.request_id = p_request_id
      AND  qpiq.process_status_flag ='P' --is null
      AND  qpiq.interface_action_code IN ('INSERT', 'UPDATE')
      AND  qpiq.qualifier_attribute is not null
      AND  qpiq.qualifier_attribute_code is not null
      AND  qpiq.qualifier_attribute_code <> QP_BULK_LOADER_PUB.G_NULL_CHAR
      AND NOT EXISTS (
        SELECT  'x'
        FROM    qp_interface_qualifiers b,
                qp_prc_contexts_b d,
                qp_segments_b e,
                qp_pte_segments f
        WHERE b.qualifier_context = d.prc_context_code
	  AND b.qualifier_attribute = e.segment_mapping_column
          and e.segment_code = b.qualifier_attribute_code
	  AND d.prc_context_id = e.prc_context_id
          AND d.prc_context_type = 'QUALIFIER'
	  AND e.segment_id = f.segment_id
	  AND f.pte_code = l_pte_code
	  AND f.segment_level NOT IN ('LINE')
	  AND qpiq.rowid = b.rowid);

    INSERT INTO QP_INTERFACE_ERRORS
   (error_id,last_update_date, last_updated_by, creation_date,
    created_by, last_update_login, request_id, program_application_id,
    program_id, program_update_date, entity_type, table_name, column_name,
    orig_sys_header_ref,orig_sys_line_ref,orig_sys_qualifier_ref,
    orig_sys_pricing_attr_ref,error_message)
    SELECT
     qp_interface_errors_s.nextval, sysdate ,FND_GLOBAL.USER_ID, sysdate,
     FND_GLOBAL.USER_ID, FND_GLOBAL.CONC_LOGIN_ID, qpiq.request_id, 661,
     NULL,NULL, 'PRL', 'QP_INTERFACE_QUALIFIERS',  'QUALIFIER_ATTRIBUTE',
     qpiq.orig_sys_header_ref,null,qpiq.orig_sys_qualifier_ref,null,l_msg_txt
    FROM QP_INTERFACE_QUALIFIERS qpiq
    WHERE qpiq.request_id = p_request_id
      AND  qpiq.process_status_flag ='P' --is null
      AND  qpiq.interface_action_code IN ('INSERT', 'UPDATE')
      AND  qpiq.qualifier_attribute is null
      AND  qpiq.qualifier_attribute_code is not null
      AND  qpiq.qualifier_attribute_code <> QP_BULK_LOADER_PUB.G_NULL_CHAR
      AND NOT EXISTS (
        SELECT  'x'
        FROM    qp_interface_qualifiers b,
                qp_prc_contexts_b d,
                qp_segments_b e,
                qp_pte_segments f
        WHERE  b.qualifier_context = d.prc_context_code
           and e.segment_code = b.qualifier_attribute_code
	   AND d.prc_context_id = e.prc_context_id
           AND d.prc_context_type = 'QUALIFIER'
	   AND e.segment_id = f.segment_id
	   AND f.pte_code = l_pte_code
	   AND f.segment_level NOT IN ('LINE')
	   AND qpiq.rowid = b.rowid);

    INSERT INTO QP_INTERFACE_ERRORS
   (error_id,last_update_date, last_updated_by, creation_date,
    created_by, last_update_login, request_id, program_application_id,
    program_id, program_update_date, entity_type, table_name, column_name,
    orig_sys_header_ref,orig_sys_line_ref,orig_sys_qualifier_ref,
    orig_sys_pricing_attr_ref,error_message)
    SELECT
     qp_interface_errors_s.nextval, sysdate ,FND_GLOBAL.USER_ID, sysdate,
     FND_GLOBAL.USER_ID, FND_GLOBAL.CONC_LOGIN_ID, qpiq.request_id, 661,
     NULL,NULL, 'PRL', 'QP_INTERFACE_QUALIFIERS',  'QUALIFIER_ATTRIBUTE',
     qpiq.orig_sys_header_ref,null,qpiq.orig_sys_qualifier_ref,null,l_msg_txt
    FROM QP_INTERFACE_QUALIFIERS qpiq
    WHERE qpiq.request_id = p_request_id
      AND  qpiq.process_status_flag ='P' --is null
      AND  qpiq.interface_action_code IN ('INSERT', 'UPDATE')
      AND  qpiq.qualifier_attribute is not null
      AND  qpiq.qualifier_attribute_code is null
      AND NOT EXISTS (
        SELECT  'x'
        FROM    qp_interface_qualifiers b,
                qp_prc_contexts_b d,
                qp_segments_b e,
                qp_pte_segments f
        WHERE b.qualifier_context = d.prc_context_code
	  AND b.qualifier_attribute = e.segment_mapping_column
	  AND d.prc_context_id = e.prc_context_id
          AND d.prc_context_type = 'QUALIFIER'
	  AND e.segment_id = f.segment_id
	  AND f.pte_code = l_pte_code
	  AND f.segment_level NOT IN ('LINE')
	  AND qpiq.rowid = b.rowid);
--Bug# 5456164 END RAVI

   qp_bulk_loader_pub.write_log('Leaving Attribute qualifier validation');

EXCEPTION
    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
       qp_bulk_loader_pub.write_log( 'UNEXCPECTED ERROR IN PROCEDURE ATTRIBUTE_QUALIFIER:'||sqlerrm);
       RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    WHEN OTHERS THEN
       qp_bulk_loader_pub.write_log( 'UNEXCPECTED ERROR IN PROCEDURE ATTRIBUTE_QUALIFIER:'||sqlerrm);
       RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

END ATTRIBUTE_QUALIFIER;


-- Bug# 5412045
-- Shell for qp_validate.product_uom to return Varchar2 ('TRUE', 'FALSE')
-- qp_validate.product_uom returns a boolean.
Function product_uom ( p_product_uom_code IN VARCHAR2,
                       p_category_id IN NUMBER,
                       p_list_header_id IN NUMBER )
RETURN VARCHAR2 IS
BEGIN
   IF QP_Validate.product_uom(p_product_uom_code,p_category_id,p_list_header_id)=TRUE
   THEN
      RETURN 'TRUE';
   ELSE
      RETURN 'FALSE';
   END IF;
EXCEPTION
  When OTHERS THEN
     RETURN 'FALSE';
END product_uom;


PROCEDURE ATTRIBUTE_LINE
               (p_request_id NUMBER)
IS

   l_msg_txt  VARCHAR2(240);
   l_pte_code VARCHAR2(30);

   BEGIN

    qp_bulk_loader_pub.write_log('Entering Attribute line validation');
    FND_PROFILE.GET('QP_PRICING_TRANSACTION_ENTITY',l_pte_code);

    -- 1. LIST LINE TYPE CODE
   FND_MESSAGE.SET_NAME('QP','QP_INVALID_ATTRIBUTE');
   FND_MESSAGE.SET_TOKEN('ATTRIBUTE','LIST_LINE_TYPE_CODE');
   l_msg_txt := FND_MESSAGE.GET;

    INSERT INTO QP_INTERFACE_ERRORS
   (error_id,last_update_date, last_updated_by, creation_date,
    created_by, last_update_login, request_id, program_application_id,
    program_id, program_update_date, entity_type, table_name, column_name,
    orig_sys_header_ref,orig_sys_line_ref,orig_sys_qualifier_ref,
    orig_sys_pricing_attr_ref,error_message)
    SELECT
     qp_interface_errors_s.nextval, sysdate ,FND_GLOBAL.USER_ID, sysdate,
     FND_GLOBAL.USER_ID, FND_GLOBAL.CONC_LOGIN_ID, qpil.request_id, 661,
     NULL,NULL, 'PRL', 'QP_INTERFACE_LIST_LINES',  'LIST_LINE_TYPE_CODE',
     qpil.orig_sys_header_ref,qpil.orig_sys_line_ref,null,null, l_msg_txt
    FROM QP_INTERFACE_LIST_LINES qpil
    WHERE qpil.request_id = p_request_id
      AND  qpil.process_status_flag ='P' --is null
      AND  qpil.interface_action_code IN ('INSERT', 'UPDATE')
      AND  qpil.list_line_type_code is NOT NULL
      AND NOT EXISTS ( SELECT  lookup_code
		       FROM     qp_lookups
		       WHERE  lookup_type= 'LIST_LINE_TYPE_CODE'
                       AND        lookup_code= qpil.list_line_type_code
                       AND        qpil.list_line_type_code IN ('PLL', 'PBH') );

  -- 2. ARITHMETIC OPERATOR
   FND_MESSAGE.SET_NAME('QP','QP_INVALID_ATTRIBUTE');
   FND_MESSAGE.SET_TOKEN('ATTRIBUTE','ARITHMETIC_OPERATOR 5');
   l_msg_txt := FND_MESSAGE.GET;

    INSERT INTO QP_INTERFACE_ERRORS
   (error_id,last_update_date, last_updated_by, creation_date,
    created_by, last_update_login, request_id, program_application_id,
    program_id, program_update_date, entity_type, table_name, column_name,
    orig_sys_header_ref,orig_sys_line_ref,orig_sys_qualifier_ref,
    orig_sys_pricing_attr_ref,error_message)
    SELECT
     qp_interface_errors_s.nextval, sysdate ,FND_GLOBAL.USER_ID, sysdate,
     FND_GLOBAL.USER_ID, FND_GLOBAL.CONC_LOGIN_ID, qpil.request_id, 661,
     NULL,NULL, 'PRL', 'QP_INTERFACE_LIST_LINES',  'ARITHMETIC_OPERATOR',
     qpil.orig_sys_header_ref,qpil.orig_sys_line_ref,null,null,l_msg_txt
    FROM QP_INTERFACE_LIST_LINES qpil
    WHERE qpil.request_id = p_request_id
      AND  qpil.process_status_flag ='P' --is null
      AND  qpil.interface_action_code IN ('INSERT', 'UPDATE')
      AND  qpil.arithmetic_operator is NOT NULL
      AND NOT EXISTS ( SELECT  meaning
		       FROM     qp_lookups
		       WHERE  lookup_type= 'ARITHMETIC_OPERATOR'
                       AND        lookup_code= qpil.arithmetic_operator );

   --3. PRICE BREAK TYPE CODE
   FND_MESSAGE.SET_NAME('QP','QP_INVALID_ATTRIBUTE');
   FND_MESSAGE.SET_TOKEN('ATTRIBUTE','PRICE_BREAK_TYPE_CODE');
   l_msg_txt := FND_MESSAGE.GET;

    INSERT INTO QP_INTERFACE_ERRORS
   (error_id,last_update_date, last_updated_by, creation_date,
    created_by, last_update_login, request_id, program_application_id,
    program_id, program_update_date, entity_type, table_name, column_name,
    orig_sys_header_ref,orig_sys_line_ref,orig_sys_qualifier_ref,
    orig_sys_pricing_attr_ref,error_message)
    SELECT
     qp_interface_errors_s.nextval, sysdate ,FND_GLOBAL.USER_ID, sysdate,
     FND_GLOBAL.USER_ID, FND_GLOBAL.CONC_LOGIN_ID, qpil.request_id, 661,
     NULL,NULL, 'PRL', 'QP_INTERFACE_LIST_LINES',  'PRICE_BREAK_TYPE_CODE',
     qpil.orig_sys_header_ref,qpil.orig_sys_line_ref,null,null,l_msg_txt
    FROM QP_INTERFACE_LIST_LINES qpil
    WHERE qpil.request_id = p_request_id
      AND  qpil.process_status_flag ='P' --is null
      AND  qpil.interface_action_code IN ('INSERT', 'UPDATE')
      AND  qpil.price_break_type_code is NOT NULL
      AND NOT EXISTS ( SELECT     meaning
		       FROM     qp_lookups
		       WHERE  lookup_type= 'PRICE_BREAK_TYPE_CODE'
                       AND        lookup_code= qpil.price_break_type_code);

  --4. UOM
   FND_MESSAGE.SET_NAME('QP','QP_INVALID_ATTRIBUTE');
   FND_MESSAGE.SET_TOKEN('ATTRIBUTE','Product Uom Code');
   l_msg_txt := FND_MESSAGE.GET;

	-- Bug# 5412045
	-- Validate UOM for a category line
    INSERT INTO QP_INTERFACE_ERRORS
   (error_id,last_update_date, last_updated_by, creation_date,
    created_by, last_update_login, request_id, program_application_id,
    program_id, program_update_date, entity_type, table_name, column_name,
    orig_sys_header_ref,orig_sys_line_ref,orig_sys_qualifier_ref,
    orig_sys_pricing_attr_ref,error_message)
    SELECT /*+ index(qpip QP_INTERFACE_PRCNG_ATTRIBS_N4) */
     qp_interface_errors_s.nextval, sysdate ,FND_GLOBAL.USER_ID, sysdate,
     FND_GLOBAL.USER_ID, FND_GLOBAL.CONC_LOGIN_ID, qpil.request_id, 661,
     NULL,NULL, 'PRL', 'QP_INTERFACE_PRICING_ATTRIBS',  'PRODUCT_UOM_CODE',
     qpip.orig_sys_header_ref,qpip.orig_sys_line_ref,null,
     qpip.orig_sys_pricing_attr_ref,  l_msg_txt
    FROM QP_INTERFACE_LIST_LINES qpil, QP_INTERFACE_PRICING_ATTRIBS qpip, QP_LIST_HEADERS_B qplh
    WHERE qpil.request_id = p_request_id
      AND  qpip.request_id = p_request_id -- bug no 5881528
      AND  qpil.process_status_flag ='P' --is null
      AND  qpil.orig_sys_line_ref = qpip.orig_sys_line_ref
      -- ENH unod alcoa changes RAVI
      /**
      The key between interface and qp tables is only orig_sys_hdr_ref
      (not list_header_id)
      **/
      AND  qpil.orig_sys_header_ref = qplh.orig_system_header_ref
      AND  qpip.pricing_attribute_context IS NULL
      AND  qpil.interface_action_code IN ('INSERT', 'UPDATE')
      AND  qpip.interface_action_code IN ('INSERT', 'UPDATE')
      AND  qpip.product_uom_code is NOT NULL
      and qpip.product_attribute_context = 'ITEM'
      and qpip.product_attribute = 'PRICING_ATTRIBUTE1'
      AND NOT EXISTS (
	select uom_code
	from mtl_item_uoms_view
	where organization_id = nvl(qpil.organization_id, organization_id)
	and inventory_item_id = to_number(qpip.product_attr_value)
	and uom_code = qpip.product_uom_code
        -- commented out for bug 4713401
        /*
	union
	select uom_code
	from mtl_item_uoms_view
	where (organization_id = qpil.organization_id or qpil.organization_id is null)
	and inventory_item_id in ( select inventory_item_id
	from mtl_item_categories
	where category_id =      to_number(qpip.product_attr_value)
	and (organization_id = qpil.organization_id or qpil.organization_id is null ))
	and qpip.product_attribute_context = 'ITEM'
	and qpip.product_attribute = 'PRICING_ATTRIBUTE2'
	and uom_code = qpip.product_uom_code
        */
	-- added for bug 4713401
        /* commented out as this code is not performant
	union
	select uom_code
	from mtl_item_uoms_view
	where (organization_id = qpil.organization_id or qpil.organization_id is null) and
        qpip.product_attribute_context = 'ITEM' and
        qpip.product_attribute = 'PRICING_ATTRIBUTE2' and
	uom_code = qpip.product_uom_code and
        inventory_item_id in ( select inventory_item_id
        	                     from mtl_item_categories cat
	                             where (category_id = to_number(qpip.product_attr_value) or
				            exists (SELECT 'Y'
					      FROM   eni_denorm_hierarchies
					      WHERE  parent_id = to_number(qpip.product_attr_value) and
					             child_id = cat.category_id
					             and exists (select 'Y' from QP_SOURCESYSTEM_FNAREA_MAP A,
										 qp_pte_source_systems B ,
										 mtl_default_category_sets c,
										 mtl_category_sets d
					                         where A.PTE_SOURCE_SYSTEM_ID = B.PTE_SOURCE_SYSTEM_ID and
					                               B.PTE_CODE = qplh.pte_code and
					                               B.APPLICATION_SHORT_NAME = qplh.source_system_code and
					                               A.FUNCTIONAL_AREA_ID = c.FUNCTIONAL_AREA_ID and
					                               c.CATEGORY_SET_ID = d.CATEGORY_SET_ID and
					                               d.HIERARCHY_ENABLED = 'Y' and
					                               A.ENABLED_FLAG = 'Y' and B.ENABLED_FLAG = 'Y'))))
        */
	union
	select  uom_code
	from mtl_units_of_measure_vl
	where uom_code = qpip.product_uom_code
	);


	-- Bug# 5412045
	-- Validate UOM for a category line
    INSERT INTO QP_INTERFACE_ERRORS
   (error_id,last_update_date, last_updated_by, creation_date,
    created_by, last_update_login, request_id, program_application_id,
    program_id, program_update_date, entity_type, table_name, column_name,
    orig_sys_header_ref,orig_sys_line_ref,orig_sys_qualifier_ref,
    orig_sys_pricing_attr_ref,error_message)
    SELECT
     qp_interface_errors_s.nextval, sysdate ,FND_GLOBAL.USER_ID, sysdate,
     FND_GLOBAL.USER_ID, FND_GLOBAL.CONC_LOGIN_ID, qpil.request_id, 661,
     NULL,NULL, 'PRL', 'QP_INTERFACE_PRICING_ATTRIBS',  'PRODUCT_UOM_CODE',
     qpip.orig_sys_header_ref,qpip.orig_sys_line_ref,null,
     qpip.orig_sys_pricing_attr_ref,  l_msg_txt
    FROM QP_INTERFACE_LIST_LINES qpil, QP_INTERFACE_PRICING_ATTRIBS qpip, QP_LIST_HEADERS_B qplh
    WHERE qpil.request_id = p_request_id
      AND  qpip.request_id = p_request_id -- bug no 5881528
      AND  qpil.process_status_flag ='P' --is null
      AND  qpil.orig_sys_line_ref = qpip.orig_sys_line_ref
      AND  qpil.orig_sys_header_ref = qplh.orig_system_header_ref
      AND  qpip.pricing_attribute_context IS NULL
      AND  qpil.interface_action_code IN ('INSERT', 'UPDATE')
      AND  qpip.interface_action_code IN ('INSERT', 'UPDATE')
      AND  qpip.product_uom_code is NOT NULL
      and qpip.product_attribute_context = 'ITEM'
      and qpip.product_attribute = 'PRICING_ATTRIBUTE2'
      AND NOT EXISTS (
        select 'EXISTS'
        from dual
        where QP_BULK_VALIDATE.product_uom(
                qpip.product_uom_code,
                to_number(qpip.product_attr_value),
                qplh.list_header_id) = 'TRUE'
      );


 /**
  Bug# 5465109 RAVI START
  4.1) UNIQUE FORMULA CHECK
  Only one formula should be inserted or updated in a line. Either PriceBy or Generate Formula is to be used.
  If one is used the other should be set to null. If both are used then an error should be thrown.
 **/
   FND_MESSAGE.SET_NAME('QP','QP_STATIC_OR_DYNAMIC_FORMULA');
   l_msg_txt := FND_MESSAGE.GET;

    INSERT INTO QP_INTERFACE_ERRORS
   (error_id,last_update_date, last_updated_by, creation_date,
    created_by, last_update_login, request_id, program_application_id,
    program_id, program_update_date, entity_type, table_name, column_name,
    orig_sys_header_ref,orig_sys_line_ref,orig_sys_qualifier_ref,
    orig_sys_pricing_attr_ref,error_message)
    SELECT
     qp_interface_errors_s.nextval, sysdate ,FND_GLOBAL.USER_ID, sysdate,
     FND_GLOBAL.USER_ID, FND_GLOBAL.CONC_LOGIN_ID, qpil.request_id, 661,
     NULL,NULL, 'PRL', 'QP_INTERFACE_LIST_LINES',  'PRICE_BY_AND_GENERATE_FORMULA_ID',
     qpil.orig_sys_header_ref,qpil.orig_sys_line_ref,null,null,l_msg_txt
    FROM QP_INTERFACE_LIST_LINES qpil
    WHERE qpil.request_id = p_request_id
      AND  qpil.process_status_flag ='P' --is null
      AND  qpil.interface_action_code IN ('INSERT', 'UPDATE')
      AND  qpil.price_by_formula_id is NOT NULL
      AND  qpil.price_by_formula_id <> QP_BULK_LOADER_PUB.G_NULL_NUMBER
      AND  qpil.generate_using_formula_id is NOT NULL
      AND  qpil.generate_using_formula_id <> QP_BULK_LOADER_PUB.G_NULL_NUMBER;
  --Bug# 5465109 RAVI END

--5. PRICE BY FORMULA ID

   -- Bug# 5236656 RAVI
   -- Change the message that needs to be thrown.

   FND_MESSAGE.SET_NAME('QP','QP_PRC_FOR_NAME_ID_INCMPTBLE');
   l_msg_txt := FND_MESSAGE.GET;

    INSERT INTO QP_INTERFACE_ERRORS
   (error_id,last_update_date, last_updated_by, creation_date,
    created_by, last_update_login, request_id, program_application_id,
    program_id, program_update_date, entity_type, table_name, column_name,
    orig_sys_header_ref,orig_sys_line_ref,orig_sys_qualifier_ref,
    orig_sys_pricing_attr_ref,error_message)
    SELECT
     qp_interface_errors_s.nextval, sysdate ,FND_GLOBAL.USER_ID, sysdate,
     FND_GLOBAL.USER_ID, FND_GLOBAL.CONC_LOGIN_ID, qpil.request_id, 661,
     NULL,NULL, 'PRL', 'QP_INTERFACE_LIST_LINES',  'PRICE_BY_FORMULA_ID',
     qpil.orig_sys_header_ref,qpil.orig_sys_line_ref,null,null,l_msg_txt
    FROM QP_INTERFACE_LIST_LINES qpil
    WHERE qpil.request_id = p_request_id
      AND  qpil.process_status_flag ='P' --is null
      AND  qpil.interface_action_code IN ('INSERT', 'UPDATE')
      AND  qpil.price_by_formula_id is NOT NULL
      AND  qpil.price_by_formula is NOT NULL
      AND  qpil.price_by_formula <> QP_BULK_LOADER_PUB.G_NULL_CHAR
      AND NOT EXISTS ( SELECT  name
		       FROM    qp_price_formulas_vl
		       WHERE   price_formula_id = qpil.price_by_formula_id
		       AND     name = qpil.price_by_formula);

    INSERT INTO QP_INTERFACE_ERRORS
   (error_id,last_update_date, last_updated_by, creation_date,
    created_by, last_update_login, request_id, program_application_id,
    program_id, program_update_date, entity_type, table_name, column_name,
    orig_sys_header_ref,orig_sys_line_ref,orig_sys_qualifier_ref,
    orig_sys_pricing_attr_ref,error_message)
    SELECT
     qp_interface_errors_s.nextval, sysdate ,FND_GLOBAL.USER_ID, sysdate,
     FND_GLOBAL.USER_ID, FND_GLOBAL.CONC_LOGIN_ID, qpil.request_id, 661,
     NULL,NULL, 'PRL', 'QP_INTERFACE_LIST_LINES',  'PRICE_BY_FORMULA_ID',
     qpil.orig_sys_header_ref,qpil.orig_sys_line_ref,null,null,l_msg_txt
    FROM QP_INTERFACE_LIST_LINES qpil
    WHERE qpil.request_id = p_request_id
      AND  qpil.process_status_flag ='P' --is null
      AND  qpil.interface_action_code IN ('INSERT', 'UPDATE')
      AND  qpil.price_by_formula_id is NOT NULL
      AND  qpil.price_by_formula is NULL
      AND NOT EXISTS ( SELECT  name
		       FROM    qp_price_formulas_vl
		       WHERE   price_formula_id = qpil.price_by_formula_id);

    INSERT INTO QP_INTERFACE_ERRORS
   (error_id,last_update_date, last_updated_by, creation_date,
    created_by, last_update_login, request_id, program_application_id,
    program_id, program_update_date, entity_type, table_name, column_name,
    orig_sys_header_ref,orig_sys_line_ref,orig_sys_qualifier_ref,
    orig_sys_pricing_attr_ref,error_message)
    SELECT
     qp_interface_errors_s.nextval, sysdate ,FND_GLOBAL.USER_ID, sysdate,
     FND_GLOBAL.USER_ID, FND_GLOBAL.CONC_LOGIN_ID, qpil.request_id, 661,
     NULL,NULL, 'PRL', 'QP_INTERFACE_LIST_LINES',  'PRICE_BY_FORMULA_ID',
     qpil.orig_sys_header_ref,qpil.orig_sys_line_ref,null,null,l_msg_txt
    FROM QP_INTERFACE_LIST_LINES qpil
    WHERE qpil.request_id = p_request_id
      AND  qpil.process_status_flag ='P' --is null
      AND  qpil.interface_action_code IN ('INSERT', 'UPDATE')
      AND  qpil.price_by_formula_id is NULL
      AND  qpil.price_by_formula is NOT NULL
      AND  qpil.price_by_formula <> QP_BULK_LOADER_PUB.G_NULL_CHAR
      AND NOT EXISTS ( SELECT  name
		       FROM    qp_price_formulas_vl
		       WHERE   name = qpil.price_by_formula);

--5. GENERATE USING FORMULA ID

    -- Bug# 5236656 RAVI START
    -- Change the message that needs to be thrown.

   FND_MESSAGE.SET_NAME('QP','QP_GEN_FOR_NAME_ID_INCMPTBLE');
   l_msg_txt := FND_MESSAGE.GET;

    INSERT INTO QP_INTERFACE_ERRORS
   (error_id,last_update_date, last_updated_by, creation_date,
    created_by, last_update_login, request_id, program_application_id,
    program_id, program_update_date, entity_type, table_name, column_name,
    orig_sys_header_ref,orig_sys_line_ref,orig_sys_qualifier_ref,
    orig_sys_pricing_attr_ref,error_message)
    SELECT
     qp_interface_errors_s.nextval, sysdate ,FND_GLOBAL.USER_ID, sysdate,
     FND_GLOBAL.USER_ID, FND_GLOBAL.CONC_LOGIN_ID, qpil.request_id, 661,
     NULL,NULL, 'PRL', 'QP_INTERFACE_LIST_LINES',  'GENERATE_USING_FORMULA_ID',
     qpil.orig_sys_header_ref,qpil.orig_sys_line_ref,null,null,l_msg_txt
    FROM QP_INTERFACE_LIST_LINES qpil
    WHERE qpil.request_id = p_request_id
      AND  qpil.process_status_flag ='P' --is null
      AND  qpil.interface_action_code IN ('INSERT', 'UPDATE')
      AND  qpil.generate_using_formula_id is NOT NULL
      AND  qpil.generate_using_formula is NOT NULL
      AND  qpil.generate_using_formula <> QP_BULK_LOADER_PUB.G_NULL_CHAR
      AND NOT EXISTS ( SELECT  name
		       FROM    qp_price_formulas_vl
		       WHERE   price_formula_id = qpil.generate_using_formula_id
		       AND     name = qpil.generate_using_formula);


     IF SQL%ROWCOUNT >0 THEN
        qp_bulk_loader_pub.write_log('Generate formula ID and Name are incompatible');
     END IF;

    --FND_MESSAGE.SET_NAME('QP','QP_INVALID_FORMULA_FOR_PL');
    --l_msg_txt := FND_MESSAGE.GET;
    -- Bug# 5236656 RAVI END

    INSERT INTO QP_INTERFACE_ERRORS
   (error_id,last_update_date, last_updated_by, creation_date,
    created_by, last_update_login, request_id, program_application_id,
    program_id, program_update_date, entity_type, table_name, column_name,
    orig_sys_header_ref,orig_sys_line_ref,orig_sys_qualifier_ref,
    orig_sys_pricing_attr_ref,error_message)
    SELECT
     qp_interface_errors_s.nextval, sysdate ,FND_GLOBAL.USER_ID, sysdate,
     FND_GLOBAL.USER_ID, FND_GLOBAL.CONC_LOGIN_ID, qpil.request_id, 661,
     NULL,NULL, 'PRL', 'QP_INTERFACE_LIST_LINES',  'GENERATE_USING_FORMULA_ID',
     qpil.orig_sys_header_ref,qpil.orig_sys_line_ref,null,null,l_msg_txt
    FROM QP_INTERFACE_LIST_LINES qpil
    WHERE qpil.request_id = p_request_id
      AND  qpil.process_status_flag ='P' --is null
      AND  qpil.interface_action_code IN ('INSERT', 'UPDATE')
      AND  qpil.generate_using_formula_id is NOT NULL
      AND  qpil.generate_using_formula is NULL
      AND NOT EXISTS ( SELECT  name
		       FROM    qp_price_formulas_vl
		       WHERE   price_formula_id = qpil.generate_using_formula_id);

    INSERT INTO QP_INTERFACE_ERRORS
   (error_id,last_update_date, last_updated_by, creation_date,
    created_by, last_update_login, request_id, program_application_id,
    program_id, program_update_date, entity_type, table_name, column_name,
    orig_sys_header_ref,orig_sys_line_ref,orig_sys_qualifier_ref,
    orig_sys_pricing_attr_ref,error_message)
    SELECT
     qp_interface_errors_s.nextval, sysdate ,FND_GLOBAL.USER_ID, sysdate,
     FND_GLOBAL.USER_ID, FND_GLOBAL.CONC_LOGIN_ID, qpil.request_id, 661,
     NULL,NULL, 'PRL', 'QP_INTERFACE_LIST_LINES',  'GENERATE_USING_FORMULA_ID',
     qpil.orig_sys_header_ref,qpil.orig_sys_line_ref,null,null,l_msg_txt
    FROM QP_INTERFACE_LIST_LINES qpil
    WHERE qpil.request_id = p_request_id
      AND  qpil.process_status_flag ='P' --is null
      AND  qpil.interface_action_code IN ('INSERT', 'UPDATE')
      AND  qpil.generate_using_formula_id is NULL
      AND  qpil.generate_using_formula is NOT NULL
      AND  qpil.generate_using_formula <> QP_BULK_LOADER_PUB.G_NULL_CHAR
      AND NOT EXISTS ( SELECT  name
		       FROM    qp_price_formulas_vl
		       WHERE   name = qpil.generate_using_formula);

    -- Bug# 5236656 RAVI
    IF SQL%ROWCOUNT >0 THEN
       qp_bulk_loader_pub.write_log('Generate formula ID is inaccurate');
    END IF;

--6. PBH not allowed in Basic pricing
-- Basic_Pricing_Condition

   IF QP_BULK_LOADER_PUB.GET_QP_STATUS <> 'I' THEN
       FND_MESSAGE.SET_NAME('QP','QP_PBH_NA_BASIC');
       --Price Break Header not allowed in Basic Pricing
       l_msg_txt := FND_MESSAGE.GET;

	INSERT INTO QP_INTERFACE_ERRORS
       (error_id,last_update_date, last_updated_by, creation_date,
	created_by, last_update_login, request_id, program_application_id,
	program_id, program_update_date, entity_type, table_name,
	orig_sys_header_ref,orig_sys_line_ref,orig_sys_qualifier_ref,
	orig_sys_pricing_attr_ref,error_message)
	SELECT
	 qp_interface_errors_s.nextval, sysdate ,FND_GLOBAL.USER_ID, sysdate,
	 FND_GLOBAL.USER_ID, FND_GLOBAL.CONC_LOGIN_ID, qpil.request_id, 661,
	 NULL,NULL, 'PRL', 'QP_INTERFACE_LIST_LINES',
	 qpil.orig_sys_header_ref,qpil.orig_sys_line_ref,null,null,l_msg_txt
	FROM QP_INTERFACE_LIST_LINES qpil
	WHERE qpil.request_id = p_request_id
	  AND  qpil.process_status_flag ='P' --is null
	  AND  qpil.interface_action_code IN ('INSERT', 'UPDATE')
	  AND  (qpil.list_line_type_code = 'PBH'
		OR qpil.price_break_header_ref is not NULL);

  END IF;

  --7. Product Attribute
   FND_MESSAGE.SET_NAME('QP','QP_INVALID_ATTRIBUTE');
   FND_MESSAGE.SET_TOKEN('ATTRIBUTE','Product Attribute ');
   l_msg_txt := FND_MESSAGE.GET;

    INSERT INTO QP_INTERFACE_ERRORS
   (error_id,last_update_date, last_updated_by, creation_date,
    created_by, last_update_login, request_id, program_application_id,
    program_id, program_update_date, entity_type, table_name, column_name,
    orig_sys_header_ref,orig_sys_line_ref,orig_sys_qualifier_ref,
    orig_sys_pricing_attr_ref,error_message)
    SELECT
     qp_interface_errors_s.nextval, sysdate ,FND_GLOBAL.USER_ID, sysdate,
     FND_GLOBAL.USER_ID, FND_GLOBAL.CONC_LOGIN_ID, qpil.request_id, 661,
     NULL,NULL, 'PRL', 'QP_INTERFACE_LIST_LINES',  'PRODUCT_ATTRIBUTE',
     qpip.orig_sys_header_ref,qpip.orig_sys_line_ref,null,
     qpip.orig_sys_pricing_attr_ref,  l_msg_txt
    FROM QP_INTERFACE_LIST_LINES qpil, QP_INTERFACE_PRICING_ATTRIBS qpip
    WHERE qpil.request_id = p_request_id
      AND  qpip.request_id = p_request_id -- bug no 5881528
      AND  qpil.process_status_flag ='P' --is null
      AND  qpil.orig_sys_line_ref = qpip.orig_sys_line_ref
      AND  qpip.pricing_attribute_context IS NULL
      AND  qpil.interface_action_code IN ('INSERT', 'UPDATE')
      AND EXISTS ( SELECT  'x'
        FROM qp_interface_pricing_attribs b, qp_prc_contexts_b d, qp_segments_b e, qp_pte_segments f
        WHERE  b.product_attribute_context = d.prc_context_code
	AND b.product_attribute = e.segment_mapping_column
	and e.segment_code = b.product_attr_code
        AND d.prc_context_id = e.prc_context_id
	AND d.prc_context_type = 'PRODUCT'
	AND e.segment_id = f.segment_id
	AND f.pte_code = l_pte_code
	AND f.segment_level <> 'LINE'
	AND qpip.rowid = b.rowid
        union
        SELECT  'x'
        FROM qp_interface_pricing_attribs b, qp_prc_contexts_b d, qp_segments_b e, qp_pte_segments f
        WHERE  b.product_attribute_context = d.prc_context_code
	AND b.product_attribute is NULL and e.segment_code = b.product_attr_code
	AND d.prc_context_id = e.prc_context_id
	AND d.prc_context_type = 'PRODUCT'
	AND e.segment_id = f.segment_id
	AND f.pte_code = l_pte_code
	AND f.segment_level <> 'LINE'
	AND qpip.rowid = b.rowid);

--Bug# 5456164 START RAVI
  --Validate product attribute
  --8. Product Attribute
   FND_MESSAGE.SET_NAME('QP','QP_INVALID_ATTRIBUTE');
   FND_MESSAGE.SET_TOKEN('ATTRIBUTE','Product Attribute ');
   l_msg_txt := FND_MESSAGE.GET;

    INSERT INTO QP_INTERFACE_ERRORS
   (error_id,last_update_date, last_updated_by, creation_date,
    created_by, last_update_login, request_id, program_application_id,
    program_id, program_update_date, entity_type, table_name, column_name,
    orig_sys_header_ref,orig_sys_line_ref,orig_sys_qualifier_ref,
    orig_sys_pricing_attr_ref,error_message)
    SELECT
     qp_interface_errors_s.nextval, sysdate ,FND_GLOBAL.USER_ID, sysdate,
     FND_GLOBAL.USER_ID, FND_GLOBAL.CONC_LOGIN_ID, qpil.request_id, 661,
     NULL,NULL, 'PRL', 'QP_INTERFACE_LIST_LINES',  'PRODUCT_ATTRIBUTE',
     qpip.orig_sys_header_ref,qpip.orig_sys_line_ref,null,
     qpip.orig_sys_pricing_attr_ref,  l_msg_txt
    FROM QP_INTERFACE_LIST_LINES qpil, QP_INTERFACE_PRICING_ATTRIBS qpip
    WHERE qpil.request_id = p_request_id
      AND  qpip.request_id = p_request_id -- bug no 5881528
      AND qpil.process_status_flag ='P' --is null
      AND qpil.orig_sys_line_ref = qpip.orig_sys_line_ref
      AND qpip.product_attribute_context IS NOT NULL
      AND qpip.product_attribute IS NOT NULL
      AND qpip.product_attr_code IS NOT NULL
      AND qpip.product_attr_code <> QP_BULK_LOADER_PUB.G_NULL_CHAR
      AND qpil.interface_action_code IN ('INSERT', 'UPDATE')
      AND NOT EXISTS ( SELECT  'x'
        FROM qp_interface_pricing_attribs b, qp_prc_contexts_b d, qp_segments_b e, qp_pte_segments f
        WHERE  b.product_attribute_context = d.prc_context_code
	AND b.product_attribute = e.segment_mapping_column
	and e.segment_code = b.product_attr_code
        AND d.prc_context_id = e.prc_context_id
	AND d.prc_context_type = 'PRODUCT'
	AND e.segment_id = f.segment_id
	AND f.pte_code = l_pte_code
	AND qpip.rowid = b.rowid);

    INSERT INTO QP_INTERFACE_ERRORS
   (error_id,last_update_date, last_updated_by, creation_date,
    created_by, last_update_login, request_id, program_application_id,
    program_id, program_update_date, entity_type, table_name, column_name,
    orig_sys_header_ref,orig_sys_line_ref,orig_sys_qualifier_ref,
    orig_sys_pricing_attr_ref,error_message)
    SELECT
     qp_interface_errors_s.nextval, sysdate ,FND_GLOBAL.USER_ID, sysdate,
     FND_GLOBAL.USER_ID, FND_GLOBAL.CONC_LOGIN_ID, qpil.request_id, 661,
     NULL,NULL, 'PRL', 'QP_INTERFACE_LIST_LINES',  'PRODUCT_ATTRIBUTE',
     qpip.orig_sys_header_ref,qpip.orig_sys_line_ref,null,
     qpip.orig_sys_pricing_attr_ref,  l_msg_txt
    FROM QP_INTERFACE_LIST_LINES qpil, QP_INTERFACE_PRICING_ATTRIBS qpip
    WHERE qpil.request_id = p_request_id
      AND  qpip.request_id = p_request_id -- bug no 5881528
      AND qpil.process_status_flag ='P' --is null
      AND qpil.orig_sys_line_ref = qpip.orig_sys_line_ref
      AND qpip.product_attribute_context IS NOT NULL
      AND qpip.product_attribute IS NULL
      AND qpip.product_attr_code IS NOT NULL
      AND qpip.product_attr_code <> QP_BULK_LOADER_PUB.G_NULL_CHAR
      AND qpil.interface_action_code IN ('INSERT', 'UPDATE')
      AND NOT EXISTS ( SELECT  'x'
        FROM qp_interface_pricing_attribs b, qp_prc_contexts_b d, qp_segments_b e, qp_pte_segments f
        WHERE  b.product_attribute_context = d.prc_context_code
	and e.segment_code = b.product_attr_code
        AND d.prc_context_id = e.prc_context_id
	AND d.prc_context_type = 'PRODUCT'
	AND e.segment_id = f.segment_id
	AND f.pte_code = l_pte_code
	AND qpip.rowid = b.rowid);

    INSERT INTO QP_INTERFACE_ERRORS
   (error_id,last_update_date, last_updated_by, creation_date,
    created_by, last_update_login, request_id, program_application_id,
    program_id, program_update_date, entity_type, table_name, column_name,
    orig_sys_header_ref,orig_sys_line_ref,orig_sys_qualifier_ref,
    orig_sys_pricing_attr_ref,error_message)
    SELECT
     qp_interface_errors_s.nextval, sysdate ,FND_GLOBAL.USER_ID, sysdate,
     FND_GLOBAL.USER_ID, FND_GLOBAL.CONC_LOGIN_ID, qpil.request_id, 661,
     NULL,NULL, 'PRL', 'QP_INTERFACE_LIST_LINES',  'PRODUCT_ATTRIBUTE',
     qpip.orig_sys_header_ref,qpip.orig_sys_line_ref,null,
     qpip.orig_sys_pricing_attr_ref,  l_msg_txt
    FROM QP_INTERFACE_LIST_LINES qpil, QP_INTERFACE_PRICING_ATTRIBS qpip
    WHERE qpil.request_id = p_request_id
      AND  qpip.request_id = p_request_id -- bug no 5881528
      AND qpil.process_status_flag ='P' --is null
      AND qpil.orig_sys_line_ref = qpip.orig_sys_line_ref
      AND qpip.product_attribute_context IS NOT NULL
      AND qpip.product_attribute IS NOT NULL
      AND qpip.product_attr_code IS NULL
      AND qpil.interface_action_code IN ('INSERT', 'UPDATE')
      AND NOT EXISTS ( SELECT  'x'
        FROM qp_interface_pricing_attribs b, qp_prc_contexts_b d, qp_segments_b e, qp_pte_segments f
        WHERE  b.product_attribute_context = d.prc_context_code
	AND b.product_attribute = e.segment_mapping_column
        AND d.prc_context_id = e.prc_context_id
	AND d.prc_context_type = 'PRODUCT'
	AND e.segment_id = f.segment_id
	AND f.pte_code = l_pte_code
	AND qpip.rowid = b.rowid);

  --Validate pricing attribute
  --9. Pricing Attribute
   FND_MESSAGE.SET_NAME('QP','QP_INVALID_ATTRIBUTE');
   FND_MESSAGE.SET_TOKEN('ATTRIBUTE','Pricing Attribute ');
   l_msg_txt := FND_MESSAGE.GET;

    INSERT INTO QP_INTERFACE_ERRORS
   (error_id,last_update_date, last_updated_by, creation_date,
    created_by, last_update_login, request_id, program_application_id,
    program_id, program_update_date, entity_type, table_name, column_name,
    orig_sys_header_ref,orig_sys_line_ref,orig_sys_qualifier_ref,
    orig_sys_pricing_attr_ref,error_message)
    SELECT
     qp_interface_errors_s.nextval, sysdate ,FND_GLOBAL.USER_ID, sysdate,
     FND_GLOBAL.USER_ID, FND_GLOBAL.CONC_LOGIN_ID, qpil.request_id, 661,
     NULL,NULL, 'PRL', 'QP_INTERFACE_LIST_LINES',  'PRODUCT_ATTRIBUTE',
     qpip.orig_sys_header_ref,qpip.orig_sys_line_ref,null,
     qpip.orig_sys_pricing_attr_ref,  l_msg_txt
    FROM QP_INTERFACE_LIST_LINES qpil, QP_INTERFACE_PRICING_ATTRIBS qpip
    WHERE qpil.request_id = p_request_id
      AND  qpip.request_id = p_request_id -- bug no 5881528
      AND qpil.process_status_flag ='P' --is null
      AND qpil.orig_sys_line_ref = qpip.orig_sys_line_ref
      AND qpip.pricing_attribute_context IS NOT NULL
      AND qpip.pricing_attribute IS NOT NULL
      AND qpip.pricing_attr_code IS NOT NULL
      AND qpip.pricing_attr_code <> QP_BULK_LOADER_PUB.G_NULL_CHAR
      AND qpil.interface_action_code IN ('INSERT', 'UPDATE')
      AND NOT EXISTS ( SELECT  'x'
        FROM qp_interface_pricing_attribs b, qp_prc_contexts_b d, qp_segments_b e, qp_pte_segments f
        WHERE  b.pricing_attribute_context = d.prc_context_code
	AND b.pricing_attribute = e.segment_mapping_column
	and e.segment_code = b.pricing_attr_code
        AND d.prc_context_id = e.prc_context_id
	AND d.prc_context_type = 'PRICING_ATTRIBUTE'
	AND e.segment_id = f.segment_id
	AND f.pte_code = l_pte_code
	AND qpip.rowid = b.rowid);

    INSERT INTO QP_INTERFACE_ERRORS
   (error_id,last_update_date, last_updated_by, creation_date,
    created_by, last_update_login, request_id, program_application_id,
    program_id, program_update_date, entity_type, table_name, column_name,
    orig_sys_header_ref,orig_sys_line_ref,orig_sys_qualifier_ref,
    orig_sys_pricing_attr_ref,error_message)
    SELECT
     qp_interface_errors_s.nextval, sysdate ,FND_GLOBAL.USER_ID, sysdate,
     FND_GLOBAL.USER_ID, FND_GLOBAL.CONC_LOGIN_ID, qpil.request_id, 661,
     NULL,NULL, 'PRL', 'QP_INTERFACE_LIST_LINES',  'PRODUCT_ATTRIBUTE',
     qpip.orig_sys_header_ref,qpip.orig_sys_line_ref,null,
     qpip.orig_sys_pricing_attr_ref,  l_msg_txt
    FROM QP_INTERFACE_LIST_LINES qpil, QP_INTERFACE_PRICING_ATTRIBS qpip
    WHERE qpil.request_id = p_request_id
      AND  qpip.request_id = p_request_id -- bug no 5881528
      AND qpil.process_status_flag ='P' --is null
      AND qpil.orig_sys_line_ref = qpip.orig_sys_line_ref
      AND qpip.pricing_attribute_context IS NOT NULL
      AND qpip.pricing_attribute IS NULL
      AND qpip.pricing_attr_code IS NOT NULL
      AND qpip.pricing_attr_code <> QP_BULK_LOADER_PUB.G_NULL_CHAR
      AND qpil.interface_action_code IN ('INSERT', 'UPDATE')
      AND NOT EXISTS ( SELECT  'x'
        FROM qp_interface_pricing_attribs b, qp_prc_contexts_b d, qp_segments_b e, qp_pte_segments f
        WHERE  b.pricing_attribute_context = d.prc_context_code
	and e.segment_code = b.pricing_attr_code
        AND d.prc_context_id = e.prc_context_id
	AND d.prc_context_type = 'PRICING_ATTRIBUTE'
	AND e.segment_id = f.segment_id
	AND f.pte_code = l_pte_code
	AND qpip.rowid = b.rowid);

    INSERT INTO QP_INTERFACE_ERRORS
   (error_id,last_update_date, last_updated_by, creation_date,
    created_by, last_update_login, request_id, program_application_id,
    program_id, program_update_date, entity_type, table_name, column_name,
    orig_sys_header_ref,orig_sys_line_ref,orig_sys_qualifier_ref,
    orig_sys_pricing_attr_ref,error_message)
    SELECT
     qp_interface_errors_s.nextval, sysdate ,FND_GLOBAL.USER_ID, sysdate,
     FND_GLOBAL.USER_ID, FND_GLOBAL.CONC_LOGIN_ID, qpil.request_id, 661,
     NULL,NULL, 'PRL', 'QP_INTERFACE_LIST_LINES',  'PRODUCT_ATTRIBUTE',
     qpip.orig_sys_header_ref,qpip.orig_sys_line_ref,null,
     qpip.orig_sys_pricing_attr_ref,  l_msg_txt
    FROM QP_INTERFACE_LIST_LINES qpil, QP_INTERFACE_PRICING_ATTRIBS qpip
    WHERE qpil.request_id = p_request_id
      AND  qpip.request_id = p_request_id -- bug no 5881528
      AND qpil.process_status_flag ='P' --is null
      AND qpil.orig_sys_line_ref = qpip.orig_sys_line_ref
      AND qpip.pricing_attribute_context IS NOT NULL
      AND qpip.pricing_attribute IS NOT NULL
      AND qpip.pricing_attr_code IS NULL
      AND qpil.interface_action_code IN ('INSERT', 'UPDATE')
      AND NOT EXISTS ( SELECT  'x'
        FROM qp_interface_pricing_attribs b, qp_prc_contexts_b d, qp_segments_b e, qp_pte_segments f
        WHERE  b.pricing_attribute_context = d.prc_context_code
	AND b.pricing_attribute = e.segment_mapping_column
        AND d.prc_context_id = e.prc_context_id
	AND d.prc_context_type = 'PRICING_ATTRIBUTE'
	AND e.segment_id = f.segment_id
	AND f.pte_code = l_pte_code
	AND qpip.rowid = b.rowid);
--Bug# 5456164 END RAVI

       qp_bulk_loader_pub.write_log('Leaving Attribute Line validation');
	EXCEPTION
	WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
	   qp_bulk_loader_pub.write_log( 'UNEXCPECTED ERROR IN PROCEDURE ATTRIBUTE_LINE:'||sqlerrm);
	   RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
	WHEN OTHERS THEN
	   qp_bulk_loader_pub.write_log( 'UNEXCPECTED ERROR IN PROCEDURE ATTRIBUTE_LINE:'||sqlerrm);
       RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
END ATTRIBUTE_LINE;


PROCEDURE MARK_ERRORED_INTERFACE_RECORD
   (p_table_type  VARCHAR2,
    p_request_id  NUMBER)
IS
BEGIN

   qp_bulk_loader_pub.write_log('Entering Mark errored inreface record');

   IF p_table_type = 'HEADER'  THEN

	UPDATE qp_interface_list_headers h
	   SET h.process_status_flag = NULL --'E'
	 WHERE h.request_id = p_request_id
	   AND EXISTS
	 (SELECT  orig_sys_header_ref
	    FROM  qp_interface_errors e
	   WHERE  e.orig_sys_header_ref = h.orig_sys_header_ref
	     AND  e.table_name ='QP_INTERFACE_LIST_HEADERS'
	     AND  e.request_id = p_request_id	  );

   ELSIF p_table_type = 'QUALIFIER' THEN

	UPDATE qp_interface_qualifiers  q
	   SET process_status_flag = NULL --'E'
	 WHERE q.request_id =p_request_id
	   AND EXISTS
	 (SELECT  orig_sys_qualifier_ref
	    FROM    qp_interface_errors e
	   WHERE    e.orig_sys_qualifier_ref = q.orig_sys_qualifier_ref
	     AND    e.orig_sys_header_ref = q.orig_sys_header_ref
	     AND    e.table_name ='QP_INTERFACE_QUALIFIERS'
	     AND    e.request_id = p_request_id);

   ELSIF p_table_type = 'LINE' THEN

	UPDATE qp_interface_list_lines  l
	   SET    process_status_flag = NULL --'E'
	 WHERE    l.request_id =p_request_id
	   AND EXISTS
	 (SELECT  orig_sys_line_ref
	    FROM    qp_interface_errors e
	   WHERE    e.orig_sys_line_ref = l.orig_sys_line_ref
	     AND    e.orig_sys_header_ref = l.orig_sys_header_ref
	     AND  table_name ='QP_INTERFACE_LIST_LINES'
	     AND  e.request_id = p_request_id	 );

   ELSIF p_table_type = 'PRICING_ATTRIBS' THEN

	UPDATE qp_interface_pricing_attribs  a
	   SET     process_status_flag = NULL --'E'
	 WHERE  a.request_id =p_request_id
		AND EXISTS
	 (SELECT    orig_sys_pricing_attr_ref
	    FROM    qp_interface_errors e
	   WHERE    e.orig_sys_line_ref = a.orig_sys_line_ref
	     AND    e.orig_sys_header_ref = a.orig_sys_header_ref
	     AND    e.orig_sys_pricing_attr_ref = a.orig_sys_pricing_attr_ref
	     AND    table_name ='QP_INTERFACE_PRICING_ATTRIBS'
	     AND    e.request_id = p_request_id	 );

   END IF;

   qp_bulk_loader_pub.write_log('Entering Mark errored inreface record');

   EXCEPTION
    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
       qp_bulk_loader_pub.write_log(
			 'UNEXCPECTED ERROR IN PROCEDURE MARK_ERRORED_INTERFACE_RECORD:'||sqlerrm);
       RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    WHEN OTHERS THEN
       qp_bulk_loader_pub.write_log(
			 'UNEXCPECTED ERROR IN PROCEDURE MARK_ERRORED_INTERFACE_RECORD:'||sqlerrm);
       RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

END MARK_ERRORED_INTERFACE_RECORD;

END QP_BULK_VALIDATE;

/
