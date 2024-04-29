--------------------------------------------------------
--  DDL for Package Body MST_PQ_WORKS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."MST_PQ_WORKS" AS
/* $Header: MSTPQWKB.pls 120.1 2005/06/13 03:47:24 appldev  $ */

    --g_select_all CONSTANT VARCHAR2(6) := 'All'; --'<#~$>'; -- need to modify.
    g_select_all VARCHAR2(30);
    g_New_query_id NUMBER;

    FUNCTION execute_dyn_sql(P_STMT IN VARCHAR2,P_BIND_VAR IN VARCHAR2) RETURN NUMBER IS
    BEGIN
        --KSA_DEBUG(SYSDATE,p_stmt,'dyn sql');
        IF P_BIND_VAR IS NOT NULL THEN
            EXECUTE IMMEDIATE(P_STMT) USING P_BIND_VAR;
        ELSE
            EXECUTE IMMEDIATE(P_STMT);
        END IF;
        RETURN 1;
    EXCEPTION
        WHEN OTHERS THEN
            --KSA_DEBUG(SYSDATE,sqlerrm(sqlcode),'dyn sql');
            RETURN 0;
    END execute_dyn_sql;

    PROCEDURE populate_result_table(errbuf		OUT NOCOPY VARCHAR2,
					                retcode		OUT NOCOPY NUMBER,
                                    p_query_id     IN NUMBER,
                                    p_plan_id      IN NUMBER ) IS
         CURSOR CUR_QUERY IS
         SELECT QUERY_TYPE  , PUBLIC_FLAG,
                AND_OR_FLAG , APPLIES_TO,
                EXECUTE_FLAG
         FROM MST_PERSONAL_QUERIES
         WHERE QUERY_ID = P_QUERY_ID;

         CURSOR cur_definition IS
         SELECT msc.QUERY_ID      , msc.FIELD_NAME      ,
                ms.FIELD_TYPE     , msc.SEQUENCE        ,
                msc.FILTER_TYPE   , msc.FIELD_VALUE_FROM,
                msc.FIELD_VALUE_TO, msc.MULTI_SELECT    ,
                msc.ACTIVE_FLAG   , msc.CREATED_BY
         FROM mst_selection_criteria msc,
              mst_selection ms
         WHERE msc.query_id = p_query_id
         AND   ms.field_name = msc.field_name
         AND   msc.active_flag = 1
         ORDER BY msc.SEQUENCE;

         l_rec_query cur_query%ROWTYPE;
         l_rec_definition cur_definition%ROWTYPE;
         l_field_type_temp NUMBER;
         l_delim CONSTANT VARCHAR2(1) := ',';
         l_separator CONSTANT VARCHAR2(1):= ';';
         l_where_str1 VARCHAR2(10000); --VARCHAR2(4000);
         l_where_str2 VARCHAR2(10000); --VARCHAR2(3000);
         l_where_str3 VARCHAR2(10000); --VARCHAR2(2000);

         g_plan_criteria VARCHAR2(200);
         l_plan_criteria VARCHAR2(200);
         l_cm_criteria VARCHAR2(200);
         l_mode_of_transport_temp VARCHAR2(200);
         l_multi_select_temp      NUMBER;
         l_fetch_required BOOLEAN ;
         l_changed CONSTANT VARCHAR2(4):='@<~#';

         l_user       NUMBER ; --:= TO_NUMBER(FND_PROFILE.VALUE('USER_ID'));
         l_insert_str VARCHAR2(200) ; --:= 'INSERT INTO MST_PERSONAL_QUERY_RESULTS ';
         l_insert_Col VARCHAR2(200) ;
         l_select_str VARCHAR2(2000);
         l_executed NUMBER ;
         l_update_str VARCHAR2(500);
         l_delete_str VARCHAR2(500);
         execution_failed EXCEPTION;
         related_field_notfound EXCEPTION;
    BEGIN
        l_fetch_required := TRUE;
        l_user       := TO_NUMBER(FND_PROFILE.VALUE('USER_ID'));
        l_insert_str := 'INSERT INTO MST_PERSONAL_QUERY_RESULTS ';
        BEGIN
            l_delete_str := 'DELETE MST_PERSONAL_QUERY_RESULTS WHERE QUERY_ID = :P_QUERY_ID AND PLAN_ID=:P_PLAN_ID';
            EXECUTE IMMEDIATE(l_delete_str) USING p_query_id,p_plan_id;
            l_update_str := 'UPDATE MST_PERSONAL_QUERIES SET EXECUTE_FLAG = 2 WHERE QUERY_ID = :P_QUERY_ID';
            l_executed:= execute_dyn_sql(l_update_str, p_query_id);
        EXCEPTION
            WHEN no_data_Found THEN
                NULL;
        END;
        --l_executed:= execute_dyn_sql(l_delete_str,p_query_id||','||p_plan_id);
        OPEN cur_query;
        FETCH cur_query INTO l_rec_query;
        CLOSE cur_query;

        IF l_rec_query.query_type IN ( 1, 2, 3, 4, 5 ) THEN -- loads,CM, Orders, exceptions, rules
            IF l_rec_query.query_type = 1 OR
                ( l_rec_query.query_type = 5 AND l_rec_query.applies_to = 1) THEN -- loads
                l_insert_Col := '(QUERY_ID, PLAN_ID, TRIP_ID,CREATED_BY, CREATION_DATE) ';
                l_select_str := 'SELECT DISTINCT '||p_query_id||',PLAN_ID,TRIP_ID,'|| l_user||', SYSDATE FROM MST_PQ_LOAD_DETAILS_V ';
            ELSIF l_rec_query.query_type = 2 OR
                ( l_rec_query.query_type = 5 AND l_rec_query.applies_to = 3) THEN -- CM
                l_insert_Col := '(QUERY_ID, PLAN_ID, CONTINUOUS_MOVE_ID,CREATED_BY, CREATION_DATE) ';
                l_select_str := 'SELECT DISTINCT '||p_query_id||',PLAN_ID,CONTINUOUS_MOVE_ID,'|| l_user||', SYSDATE FROM MST_PQ_CM_DETAILS_V ';
            ELSIF l_rec_query.query_type = 3 OR
                ( l_rec_query.query_type = 5 AND l_rec_query.applies_to = 2) THEN -- Orders
                l_insert_Col := '(QUERY_ID, PLAN_ID, SOURCE_CODE,SOURCE_HEADER_NUMBER,CREATED_BY, CREATION_DATE) ';
                l_select_str := 'SELECT DISTINCT '||p_query_id||',PLAN_ID,SOURCE_CODE,SOURCE_HEADER_NUMBER,'|| l_user||', SYSDATE FROM MST_PQ_ORDER_DETAILS_V ';
            ELSIF l_rec_query.query_type = 4 THEN -- Exceptions
                l_insert_Col := '(QUERY_ID, PLAN_ID, EXCEPTION_ID,CREATED_BY, CREATION_DATE) ';
                l_select_str := 'SELECT DISTINCT '||p_query_id||',PLAN_ID,EXCEPTION_ID,'|| l_user||', SYSDATE FROM MST_PQ_EXCEP_DETAILS_V ';
            ELSIF l_rec_query.query_type = 5 AND l_rec_query.applies_to = 4 THEN -- Deliveries
                l_insert_Col := '(QUERY_ID, PLAN_ID, DELIVERY_ID, CREATED_BY, CREATION_DATE) ';
                l_select_str := 'SELECT DISTINCT '||p_query_id||',PLAN_ID,DELIVERY_ID,'|| l_user||', SYSDATE FROM MST_PQ_UA_DEL_DETAILS_V ';
            END IF;
          OPEN cur_definition;
          LOOP
            l_field_type_temp := NULL;
            DECLARE
                skip_condition EXCEPTION;
                l_temp_str   VARCHAR2(30);
                l_where_str4 VARCHAR2(10000); --VARCHAR2(2000);
                l_where_str5 VARCHAR2(10000);
            BEGIN
                IF l_fetch_required THEN
                    FETCH cur_definition INTO l_rec_definition;
                ELSE
                    l_fetch_required := TRUE;
                END IF;
                --EXIT WHEN cur_definition%NOTFOUND;
                --KSA_DEBUG(SYSDATE,'inside loop ','dyn sql');
                IF cur_definition%NOTFOUND THEN
                    --KSA_DEBUG(SYSDATE,'inside loop -l_where_str1 '||l_where_str1,'dyn sql');
                    IF l_where_str1 IS NOT NULL THEN
                        l_where_str1 :=l_where_str1 ||')';
                    END IF;
                    EXIT;
                END IF;
                IF l_rec_definition.FILTER_TYPE IN(1,2,3) THEN -- =,not,in
                  l_where_str2 := l_rec_definition.FIELD_NAME;
                  IF l_rec_query.query_type = 4 AND
                     l_rec_definition.FIELD_NAME = 'MODE_OF_TRANSPORT' THEN
                        IF l_rec_definition.MULTI_SELECT =1 THEN -- YES
                            l_where_str3 := '('''||REPLACE(rtrim(l_rec_definition.FIELD_VALUE_FROM,l_separator),l_separator,''''||l_delim||'''')||''')';
                            l_where_str2 := '('||l_where_str2 ||' IN '||l_where_str3;
                        ELSIF l_rec_definition.MULTI_SELECT = 2
                              AND l_rec_definition.filter_type = 1 THEN -- NO
                            l_where_str3 := ''''||l_rec_definition.FIELD_VALUE_FROM||'''';
                            l_where_str2 := '('||l_where_str2||' = '||l_where_str3;
                        ELSE
                            l_where_str2 := '('||l_where_str2 ||' IS NULL';
                        END IF;
                        FETCH cur_definition INTO l_rec_definition;
                        IF cur_definition%FOUND AND l_rec_definition.FIELD_NAME IN ('DELIVERY_ID', 'CONTINUOUS_MOVE_ID') THEN
                            l_where_str2 := l_where_str2||' OR '||l_rec_definition.FIELD_NAME;
                            IF l_rec_definition.FIELD_VALUE_FROM = 2 THEN
                                l_where_str2 := l_where_str2 ||' IS NULL';
                            ELSIF l_rec_definition.FIELD_VALUE_FROM = 1 THEN
                                l_where_str2 := l_where_str2 ||' IS NOT NULL';
                            END IF;

                            FETCH cur_definition INTO l_rec_definition;
                            IF cur_definition%FOUND AND l_rec_definition.FIELD_NAME IN ('DELIVERY_ID', 'CONTINUOUS_MOVE_ID') THEN
                                l_where_str2 := l_where_str2||' OR '||l_rec_definition.FIELD_NAME;
                                IF l_rec_definition.FIELD_VALUE_FROM = 2 THEN
                                    l_where_str2 := l_where_str2 ||' IS NULL'||')';
                                ELSIF l_rec_definition.FIELD_VALUE_FROM = 1 THEN
                                    l_where_str2 := l_where_str2 ||' IS NOT NULL'||')';
                                END IF;
                            ELSE
                                l_where_str2 := l_where_str2 ||')';
                                l_fetch_required := FALSE;
                            END IF;
                        ELSE
                            l_where_str2 := l_where_str2 ||')';
                            l_fetch_required := FALSE;
                        END IF;
                  /***********************************/
                  ELSIF l_rec_query.query_type = 1 AND
                     l_rec_definition.FIELD_NAME = 'TL_TRIP_NUMBER' THEN
                        l_where_str2 := 'TRIP_NUMBER';
                        IF l_plan_criteria IS NOT NULL AND l_plan_criteria <> l_changed THEN
                            l_where_str1:= l_plan_criteria; -- Very important line @@@
                            l_plan_criteria := l_changed;
                        ELSIF g_plan_criteria IS NOT NULL AND g_plan_criteria <> l_changed THEN
                            l_where_str1:= g_plan_criteria; -- Very important line @@@
                            g_plan_criteria := l_changed;
                            l_plan_criteria := l_changed;
                        END IF;
                        l_temp_str := l_where_str2;
                        IF l_rec_definition.MULTI_SELECT =1 THEN -- YES
                            l_where_str3 := '('||REPLACE(rtrim(l_rec_definition.FIELD_VALUE_FROM,l_separator),l_separator,l_delim)||')';
                            l_where_str2 := l_where_str2 ||' IN '||l_where_str3;
                        ELSIF l_rec_definition.MULTI_SELECT = 2
                              AND l_rec_definition.filter_type = 1 THEN -- NO
                            l_where_str3 := l_rec_definition.FIELD_VALUE_FROM;
                            l_where_str2 := l_where_str2||' = '||l_where_str3;
                        END IF;
                        IF l_mode_of_transport_temp IS NOT NULL THEN
                            IF l_cm_criteria IS NOT NULL THEN
                                l_where_str2 := '('||l_where_str2||' AND '||l_cm_criteria||')';
                            END IF;
                            IF l_multi_select_temp = 1 THEN
                                l_where_str2 := '(('   ||l_where_str2 || ' AND MODE_OF_TRANSPORT = ''TRUCK'')'||
                                                ' OR MODE_OF_TRANSPORT IN '||l_mode_of_transport_temp||')';
                            ELSIF l_multi_select_temp = 2 THEN
                                l_where_str2 := '(('   ||l_where_str2 || ' AND MODE_OF_TRANSPORT = ''TRUCK'')'||
                                                ' OR MODE_OF_TRANSPORT = '||l_mode_of_transport_temp||')';
                            END IF;
                        ELSE
                            IF l_cm_criteria IS NOT NULL THEN
                                l_where_str2 := '('||l_where_str2||' AND '||l_cm_criteria||')';
                            END IF;
                            l_where_str2 := '('   ||l_where_str2 || ' AND MODE_OF_TRANSPORT = ''TRUCK'')';
                        END IF;
                        FETCH cur_definition INTO l_rec_definition;
                        IF l_rec_definition.FIELD_NAME = 'LTL_TRIP_NUMBER' THEN
                            IF l_rec_definition.MULTI_SELECT =1 THEN -- YES
                                l_where_str3 := '('||REPLACE(rtrim(l_rec_definition.FIELD_VALUE_FROM,l_separator),l_separator,l_delim)||')';
                                l_where_str4 := l_temp_str ||' IN '||l_where_str3;
                            ELSIF l_rec_definition.MULTI_SELECT = 2 THEN
                                l_where_str3 := l_rec_definition.FIELD_VALUE_FROM;
                                l_where_str4 := l_temp_str||' = '||l_where_str3;
                            END IF;
                            l_where_str4 := '('   ||l_where_str4 || ' AND MODE_OF_TRANSPORT = ''LTL'')';
                            l_where_str2 := '('||l_where_str2 ||' OR '|| l_where_str4||')';
                            FETCH cur_definition INTO l_rec_definition;
                            IF l_rec_definition.FIELD_NAME = 'PARCEL_TRIP_NUMBER' THEN
                                IF l_rec_definition.MULTI_SELECT =1 THEN -- YES
                                    l_where_str3 := '('||REPLACE(rtrim(l_rec_definition.FIELD_VALUE_FROM,l_separator),l_separator,l_delim)||')';
                                    l_where_str4 := l_temp_str ||' IN '||l_where_str3;
                                ELSIF l_rec_definition.MULTI_SELECT = 2 THEN
                                    l_where_str3 := l_rec_definition.FIELD_VALUE_FROM;
                                    l_where_str4 := l_temp_str||' = '||l_where_str3;
                                END IF;
                                l_where_str4 := '('   ||l_where_str4 || ' AND MODE_OF_TRANSPORT = ''PARCEL'')';
                                l_where_str2 := '('||l_where_str2 ||' OR '|| l_where_str4||')';
                            ELSE
                                l_fetch_required := FALSE;
                            END IF;
                        ELSIF l_rec_definition.FIELD_NAME = 'PARCEL_TRIP_NUMBER' THEN
                            IF l_rec_definition.MULTI_SELECT =1 THEN -- YES
                                l_where_str3 := '('||REPLACE(rtrim(l_rec_definition.FIELD_VALUE_FROM,l_separator),l_separator,l_delim)||')';
                                l_where_str4 := l_temp_str ||' IN '||l_where_str3;
                            ELSIF l_rec_definition.MULTI_SELECT = 2 THEN
                                l_where_str3 := l_rec_definition.FIELD_VALUE_FROM;
                                l_where_str4 := l_temp_str||' = '||l_where_str3;
                            END IF;
                            l_where_str4 := '('   ||l_where_str4 || ' AND MODE_OF_TRANSPORT = ''PARCEL'')';
                            l_where_str2 := '('||l_where_str2 ||' OR '|| l_where_str4||')';
                        ELSE
                            l_fetch_required := FALSE;
                        END IF;
                  ELSIF l_rec_query.query_type = 1 AND
                     l_rec_definition.FIELD_NAME = 'LTL_TRIP_NUMBER' THEN
                        l_where_str2 := 'TRIP_NUMBER';
                        IF l_plan_criteria IS NOT NULL AND l_plan_criteria <> l_changed THEN
                            l_where_str1:= l_plan_criteria; -- Very important line @@@
                            l_plan_criteria := l_changed;
                        ELSIF g_plan_criteria IS NOT NULL AND g_plan_criteria <> l_changed THEN
                            l_where_str1:= g_plan_criteria; -- Very important line @@@
                            g_plan_criteria := l_changed;
                            l_plan_criteria := l_changed;
                        END IF;
                        IF l_rec_definition.MULTI_SELECT =1 THEN -- YES
                            l_where_str3 := '('||REPLACE(rtrim(l_rec_definition.FIELD_VALUE_FROM,l_separator),l_separator,l_delim)||')';
                            l_where_str2 := l_where_str2 ||' IN '||l_where_str3;
                        ELSIF l_rec_definition.MULTI_SELECT = 2
                              AND l_rec_definition.filter_type = 1 THEN -- NO
                            l_where_str3 := l_rec_definition.FIELD_VALUE_FROM;
                            l_where_str2 := l_where_str2||' = '||l_where_str3;
                        END IF;
                        IF l_mode_of_transport_temp IS NOT NULL THEN

                            IF l_multi_select_temp = 1 THEN
                                l_where_str2 := '(('   ||l_where_str2 || ' AND MODE_OF_TRANSPORT = ''LTL'')'||
                                                ' OR MODE_OF_TRANSPORT IN '||l_mode_of_transport_temp||')';
                            ELSIF l_multi_select_temp = 2 THEN
                                l_where_str2 := '(('   ||l_where_str2 || ' AND MODE_OF_TRANSPORT = ''LTL'')'||
                                                ' OR MODE_OF_TRANSPORT = '||l_mode_of_transport_temp||')';
                            END IF;
                        ELSE
                                l_where_str2 := '('   ||l_where_str2 || ' AND MODE_OF_TRANSPORT = ''LTL'')';
                        END IF;
                        IF l_cm_criteria IS NOT NULL THEN
                            l_where_str2 := '('||l_where_str2||' OR ( MODE_OF_TRANSPORT = ''TRUCK'''||
                                                               '      AND '||l_cm_criteria||'))';
                        END IF;
                        FETCH cur_definition INTO l_rec_definition;
                        IF l_rec_definition.FIELD_NAME = 'PARCEL_TRIP_NUMBER' THEN
                            IF l_rec_definition.MULTI_SELECT =1 THEN -- YES
                                l_where_str3 := '('||REPLACE(rtrim(l_rec_definition.FIELD_VALUE_FROM,l_separator),l_separator,l_delim)||')';
                                l_where_str4 := l_temp_str ||' IN '||l_where_str3;
                            ELSIF l_rec_definition.MULTI_SELECT = 2 THEN
                                l_where_str3 := l_rec_definition.FIELD_VALUE_FROM;
                                l_where_str4 := l_temp_str||' = '||l_where_str3;
                            END IF;
                            l_where_str4 := '('   ||l_where_str4 || ' AND MODE_OF_TRANSPORT = ''PARCEL'')';
                            l_where_str2 := '('||l_where_str2 ||' OR '|| l_where_str4||')';
                        ELSE
                            l_fetch_required := FALSE;
                        END IF;
                  ELSIF l_rec_query.query_type = 1 AND
                     l_rec_definition.FIELD_NAME = 'PARCEL_TRIP_NUMBER' THEN
                        l_where_str2 := 'TRIP_NUMBER';
                        IF l_plan_criteria IS NOT NULL AND l_plan_criteria <> l_changed THEN
                            l_where_str1:= l_plan_criteria; -- Very important line @@@
                            l_plan_criteria := l_changed;
                        ELSIF g_plan_criteria IS NOT NULL AND g_plan_criteria <> l_changed THEN
                            l_where_str1:= g_plan_criteria; -- Very important line @@@
                            g_plan_criteria := l_changed;
                            l_plan_criteria := l_changed;
                        END IF;
                        IF l_rec_definition.MULTI_SELECT =1 THEN -- YES
                            l_where_str3 := '('||REPLACE(rtrim(l_rec_definition.FIELD_VALUE_FROM,l_separator),l_separator,l_delim)||')';
                            l_where_str2 := '('||l_where_str2 ||' IN '||l_where_str3;
                        ELSIF l_rec_definition.MULTI_SELECT = 2
                              AND l_rec_definition.filter_type = 1 THEN -- NO
                            l_where_str3 := l_rec_definition.FIELD_VALUE_FROM;
                            l_where_str2 := l_where_str2||' = '||l_where_str3;
                        END IF;
                        IF l_mode_of_transport_temp IS NOT NULL THEN
                            IF l_multi_select_temp = 1 THEN
                                l_where_str2 := '(('   ||l_where_str2 || ' AND MODE_OF_TRANSPORT = ''PARCEL'')'||
                                                ' OR MODE_OF_TRANSPORT IN '||l_mode_of_transport_temp||')';
                            ELSIF l_multi_select_temp = 2 THEN
                                l_where_str2 := '(('   ||l_where_str2 || ' AND MODE_OF_TRANSPORT = ''PARCEL'')'||
                                                ' OR MODE_OF_TRANSPORT = '||l_mode_of_transport_temp||')';
                            END IF;
                        ELSE
                                l_where_str2 := '('   ||l_where_str2 || ' AND MODE_OF_TRANSPORT = ''PARCEL'')';
                        END IF;
                        IF l_cm_criteria IS NOT NULL THEN
                            l_where_str2 := '('||l_where_str2||' OR ( MODE_OF_TRANSPORT = ''TRUCK'''||
                                                               '      AND '||l_cm_criteria||'))';
                        END IF;
                  /***********************************/
                  ELSIF l_rec_query.query_type = 5 AND
                        l_rec_definition.FIELD_NAME ='MODE_OF_TRANSPORT' THEN
                        l_where_str3 := ''''||l_rec_definition.FIELD_VALUE_FROM||'''';
                        l_where_str2 := l_where_str2||' = '||l_where_str3;
                  --ELSIF l_rec_query.query_type = 5 AND
                  --      l_rec_definition.FIELD_NAME ='CONTINUOUS_MOVE_ID' THEN
                  /***********************************/
                  ELSIF l_rec_query.query_type = 1 AND
                        l_rec_definition.FIELD_NAME ='CONTINUOUS_MOVE_ID' THEN
                        IF l_rec_definition.FIELD_VALUE_FROM = 2 THEN
                            l_where_str2 := l_where_str2 ||' IS NULL';
                        ELSIF l_rec_definition.FIELD_VALUE_FROM = 1 THEN
                            l_where_str2 := l_where_str2 ||' IS NOT NULL';
                        END IF;
                        l_cm_criteria := l_where_str2;
                  /***********************************/
                  ELSIF l_rec_query.query_type = 5 AND
                        l_rec_definition.FIELD_NAME ='CONTINUOUS_MOVE_ID' THEN
                        IF l_rec_definition.FIELD_VALUE_FROM = 2 THEN
                            l_where_str2 := l_where_str2 ||' IS NULL';
                        ELSIF l_rec_definition.FIELD_VALUE_FROM = 1 THEN
                            l_where_str2 := l_where_str2 ||' IS NOT NULL';
                        END IF;
                  ELSE
                    IF l_rec_definition.FIELD_NAME = 'CUSTOMER_NAME' THEN
                        l_field_type_temp := 1;
                        l_where_str2 := 'CUSTOMER_ID';
                    ELSIF l_rec_definition.FIELD_NAME = 'SUPPLIER_NAME' THEN
                        l_field_type_temp := 1;
                        l_where_str2 := 'SUPPLIER_ID';
                    ELSIF l_rec_definition.FIELD_NAME = 'CARRIER_NAME' THEN
                        l_field_type_temp := 1;
                        l_where_str2 := 'CARRIER_ID';
                    ELSIF l_rec_definition.FIELD_NAME = 'ORIGIN_FACILITY' THEN
                        l_field_type_temp := 1;
                        l_where_str2 := 'ORIGIN_FACILITY_ID';
                    ELSIF l_rec_definition.FIELD_NAME = 'DESTINATION_FACILITY' THEN
                        l_field_type_temp := 1;
                        l_where_str2 := 'DESTINATION_FACILITY_ID';
                    ELSIF l_rec_definition.FIELD_NAME = 'ITEM_NAME' THEN
                        l_field_type_temp := 1;
                        l_where_str2 := 'INVENTORY_ITEM_ID';
                    ELSIF l_rec_definition.FIELD_NAME = 'FACILITY' THEN
                        --RAISE skip_condition; -- Need review latter.
                        l_where_str2 := 'ORIGIN_FACILITY_ID';
                        l_where_str4 := 'DESTINATION_FACILITY_ID';
                    END IF;
                    IF l_rec_definition.MULTI_SELECT =1 THEN -- YES
                        IF l_rec_definition.FIELD_TYPE = 1 OR l_field_type_temp = 1 THEN -- NUMBER
                            l_where_str3 := '('||REPLACE(rtrim(l_rec_definition.FIELD_VALUE_FROM,l_separator),l_separator,l_delim)||')';
                        ELSIF l_rec_definition.FIELD_TYPE =2 THEN -- varchar2
                            l_where_str3 := '('''||REPLACE(rtrim(l_rec_definition.FIELD_VALUE_FROM,l_separator),l_separator,''''||l_delim||'''')||''')';
                        END IF;
                        /**************************/
                        IF l_rec_query.query_type = 1 AND
                          l_rec_definition.FIELD_NAME = 'MODE_OF_TRANSPORT' THEN
                            IF l_cm_criteria IS NOT NULL THEN
                                l_where_str5 := '('||l_rec_definition.FIELD_NAME||' = ''TRUCK'' AND '|| l_cm_criteria ||')';
                                IF instr(l_where_str3, '''TRUCK'',') > 0 THEN
                                    l_where_str3 := REPLACE(l_where_str3,'''TRUCK'',');
                                END IF;
                            END IF;
                            l_mode_of_transport_temp := l_where_str3;
                            l_multi_select_temp := 1;
                        END IF;
                        /**************************/
                        IF l_rec_definition.FILTER_TYPE = 2 THEN -- NOT
                            l_where_str2 := l_where_str2 ||' NOT IN '||l_where_str3;
                            IF l_where_str4 IS NOT NULL THEN
                                l_where_str4 := l_where_str4 ||' NOT IN '||l_where_str3;
                            END IF;
                        ELSE
                            l_where_str2 := l_where_str2 ||' IN '||l_where_str3;
                            IF l_where_str4 IS NOT NULL THEN
                                l_where_str4 := l_where_str4 ||' IN '||l_where_str3;
                            END IF;
                        END IF;
                        IF l_rec_query.query_type = 1
                          AND l_rec_definition.FIELD_NAME = 'MODE_OF_TRANSPORT'
                          AND l_where_str5 IS NOT NULL THEN
                            l_where_str1:= l_plan_criteria; -- Very important line @@@
                            g_plan_criteria := l_plan_criteria;
                            l_plan_criteria := l_changed ;
                            l_where_str2 := l_where_str2||' OR '|| l_where_str5;
                        END IF;
                    ELSIF l_rec_definition.MULTI_SELECT =2 THEN -- no
                        IF l_rec_definition.FIELD_TYPE = 1 OR l_field_type_temp = 1 THEN -- NUMBER
                            l_where_str3 := l_rec_definition.FIELD_VALUE_FROM;
                        ELSIF l_rec_definition.FIELD_TYPE =2 THEN -- varchar2
                            l_where_str3 := ''''||l_rec_definition.FIELD_VALUE_FROM||'''';
                        END IF;
                        /**************************/
                        IF l_rec_query.query_type = 1 AND
                          l_rec_definition.FIELD_NAME = 'MODE_OF_TRANSPORT' THEN
                            IF l_cm_criteria IS NOT NULL THEN
                                l_where_str5 := '('||l_rec_definition.FIELD_NAME||' = ''TRUCK'' AND '|| l_cm_criteria ||')';
                                IF instr(l_where_str3, '''TRUCK''') > 0 THEN
                                    l_where_str3 := REPLACE(l_where_str3,'TRUCK','TRUCK_CM'); -- Just to skip TRUCK condition
                                END IF;
                            END IF;
                            l_mode_of_transport_temp := l_where_str3;
                            l_multi_select_temp := 2;
                        END IF;
                        /**************************/
                        IF l_rec_definition.FILTER_TYPE = 2 THEN -- NOT
                            l_where_str2 := l_where_str2 ||' <> '||l_where_str3;
                            IF l_where_str4 IS NOT NULL THEN
                                l_where_str4 := l_where_str4 ||' <> '||l_where_str3;
                            END IF;
                        ELSE
                            l_where_str2 := l_where_str2 ||' = '||l_where_str3;
                            IF l_where_str4 IS NOT NULL THEN
                                l_where_str4 := l_where_str4 ||' = '||l_where_str3;
                            END IF;
                        END IF;
                        IF l_rec_query.query_type = 1
                          AND l_rec_definition.FIELD_NAME = 'MODE_OF_TRANSPORT'
                          AND l_where_str5 IS NOT NULL THEN
                            l_where_str1:= l_plan_criteria; -- Very important line @@@
                            g_plan_criteria := l_plan_criteria;
                            l_plan_criteria := l_changed ;
                            l_where_str2 := l_where_str2||' OR '|| l_where_str5;
                        END IF;
                    END IF;
                    IF l_where_str4 IS NOT NULL THEN
                        l_where_str2 := '( '||l_where_str2 ||' OR '|| l_where_str4 ||' )';
                    END IF;
                  END IF;

                  IF l_where_str1 IS NULL THEN
                    l_where_str1 := ' WHERE PLAN_ID = '||P_PLAN_ID||' AND (';
                    IF l_rec_query.query_type = 1 AND
                        l_rec_definition.FIELD_NAME IN ('MODE_OF_TRANSPORT', 'CONTINUOUS_MOVE_ID') THEN
                        l_plan_criteria := l_where_str1;

                    END IF;
                    l_where_str1 := l_where_str1 ||l_where_str2;
                  ELSIF l_where_str1 IS NOT NULL AND l_plan_criteria = l_changed THEN -- Very important line @@@
                    l_where_str1 := l_where_str1 ||l_where_str2;
                    l_plan_criteria := NULL;
                  ELSE
                    IF NVL(l_rec_query.AND_OR_FLAG,2) = 1 THEN -- 1 AND, 2 OR
                        l_where_str1 := l_where_str1 ||' AND '||l_where_str2;
                    ELSE
                        l_where_str1 := l_where_str1 ||' OR '||l_where_str2;
                    END IF;
                  END IF;
                ELSIF l_rec_definition.FILTER_TYPE = 4 THEN -- Between
                  IF l_rec_definition.FIELD_NAME IN ('ORIGIN_FACILITY_ID',
                                                     'ORIGIN_ZIP',
                                                     'ORIGIN_CITY',
                                                     'ORIGIN_STATE',
                                                     'ORIGIN_COUNTRY') THEN
                     IF l_rec_definition.FIELD_TYPE = 1 THEN -- NUMBER
                       DECLARE
                         TYPE num_List IS TABLE OF NUMBER INDEX BY BINARY_INTEGER;
                         l_field VARCHAR2(30) ; --:= l_rec_definition.FIELD_NAME;
                         l_field_values num_list;
                         l_related_field VARCHAR2(30);
                         l_related_field_values num_list;
                         l_pos NUMBER;
                         l_priv_pos NUMBER;
                         l_index NUMBER := 0;
                       BEGIN
                          l_field := l_rec_definition.FIELD_NAME;
                          l_where_str3 := l_rec_definition.FIELD_VALUE_FROM;
                          l_pos := instrb(l_where_str3,l_separator);
                          IF l_pos > 0 THEN
                            l_priv_pos := 1;
                            LOOP
                                l_pos := instrb(l_where_str3,l_separator,l_priv_pos,1);
                                EXIT WHEN l_pos <=0;
                                l_index := l_index + 1;
                                l_field_values(l_index) := TO_NUMBER(substrb(l_where_str3,l_priv_pos,l_pos - l_priv_pos));
                                l_priv_pos := l_pos + 1;
                                IF l_index >99 THEN
                                  RAISE too_many_rows;
                                END IF;
                            END LOOP;
                          ELSE
                            l_field_values(1) := TO_NUMBER(l_where_str3);
                          END IF;
                          FETCH cur_definition INTO l_rec_definition;
                          IF cur_definition%NOTFOUND THEN
                            RAISE related_field_notfound;
                          END IF;
                          l_pos := 0;
                          l_index := 0;
                          l_related_field := l_rec_definition.FIELD_NAME;
                          l_where_str3 := l_rec_definition.FIELD_VALUE_FROM;
                          l_pos := instrb(l_where_str3,l_separator);
                          IF l_pos > 0 THEN
                            l_priv_pos := 1;
                            LOOP
                                l_pos := instrb(l_where_str3,l_separator,l_priv_pos,1);
                                EXIT WHEN l_pos <=0;
                                l_index := l_index + 1;
                                l_related_field_values(l_index) := TO_NUMBER(substrb(l_where_str3,l_priv_pos,l_pos - l_priv_pos));
                                l_priv_pos := l_pos + 1;
                                IF l_index >99 THEN
                                  RAISE too_many_rows;
                                END IF;
                            END LOOP;
                          ELSE
                            l_related_field_values(1) := TO_NUMBER(l_where_str3);
                          END IF;
                          l_where_str2 := NULL;
                          FOR i IN l_field_values.first..l_field_values.last LOOP
                            FOR j IN l_related_field_values.first..l_related_field_values.last LOOP
                              IF l_where_str2 IS NOT NULL THEN
                                l_where_str2 := l_where_str2 ||' OR ';
                              END IF;
                              l_where_str2 := l_where_str2||'('||
                                              l_field ||'='||l_field_values(i)||' AND '||
                                              l_related_field||'='||l_related_field_values(j)||')';
                            END LOOP;
                          END LOOP;
                          IF l_where_str2 IS NOT NULL THEN
                            l_where_str2 := '('||l_where_str2||')';
                          END IF;
                       END ;
                     ELSIF l_rec_definition.FIELD_TYPE =2 THEN -- varchar2
                       DECLARE
                         TYPE char_List IS TABLE OF VARCHAR2(30) INDEX BY BINARY_INTEGER;
                         l_field VARCHAR2(30); -- := l_rec_definition.FIELD_NAME;
                         l_field_values char_List;
                         l_related_field VARCHAR2(30);
                         l_related_field_values char_List;
                         l_pos NUMBER;
                         l_priv_pos NUMBER;
                         l_index NUMBER := 0;
                       BEGIN
                          l_field := l_rec_definition.FIELD_NAME;
                          l_where_str3 := l_rec_definition.FIELD_VALUE_FROM;
                          l_pos := instrb(l_where_str3,l_separator);
                          IF l_pos > 0 THEN
                            l_priv_pos := 1;
                            LOOP
                                l_pos := instrb(l_where_str3,l_separator,l_priv_pos,1);
                                EXIT WHEN l_pos <=0;
                                l_index := l_index + 1;
                                l_field_values(l_index) := substrb(l_where_str3,l_priv_pos,l_pos - l_priv_pos);
                                l_priv_pos := l_pos + 1;
                                IF l_index >99 THEN
                                  RAISE too_many_rows;
                                END IF;
                            END LOOP;
                          ELSE
                            l_field_values(1) := l_where_str3;
                          END IF;
                          FETCH cur_definition INTO l_rec_definition;
                          IF cur_definition%NOTFOUND THEN
                            RAISE related_field_notfound;
                          END IF;
                          l_pos := 0;
                          l_index := 0;
                          l_related_field := l_rec_definition.FIELD_NAME;
                          l_where_str3 := l_rec_definition.FIELD_VALUE_FROM;
                          l_pos := instrb(l_where_str3,l_separator);
                          IF l_pos > 0 THEN
                            l_priv_pos := 1;
                            LOOP
                                l_pos := instrb(l_where_str3,l_separator,l_priv_pos,1);
                                EXIT WHEN l_pos <=0;
                                l_index := l_index + 1;
                                l_related_field_values(l_index) := substrb(l_where_str3,l_priv_pos,l_pos - l_priv_pos);
                                l_priv_pos := l_pos + 1;
                                IF l_index >99 THEN
                                  RAISE too_many_rows;
                                END IF;
                            END LOOP;
                          ELSE
                            l_related_field_values(1) := l_where_str3;
                          END IF;
                          l_where_str2 := NULL;
                          FOR i IN l_field_values.first..l_field_values.last LOOP
                            FOR j IN l_related_field_values.first..l_related_field_values.last LOOP
                              IF l_where_str2 IS NOT NULL THEN
                                l_where_str2 := l_where_str2 ||' OR ';
                              END IF;
                              l_where_str2 := l_where_str2||'('||
                                              l_field ||'='''||l_field_values(i)||''' AND '||
                                              l_related_field||'='''||l_related_field_values(j)||''')';
                            END LOOP;
                          END LOOP;
                          IF l_where_str2 IS NOT NULL THEN
                            l_where_str2 := '('||l_where_str2||')';
                          END IF;
                       END ;
                     END IF;
                  ELSE
                    l_where_str2 := l_rec_definition.FIELD_NAME;
                    IF l_rec_definition.FIELD_TYPE = 1 THEN -- NUMBER
                      l_where_str3 := l_rec_definition.FIELD_VALUE_FROM||' AND '||l_rec_definition.FIELD_VALUE_TO;
                    ELSIF l_rec_definition.FIELD_TYPE =2 THEN -- varchar2
                      l_where_str3 := ''''||l_rec_definition.FIELD_VALUE_FROM||''' AND '''||l_rec_definition.FIELD_VALUE_FROM||'''';
                    END IF;
                    l_where_str2 := l_where_str2 ||' BETWEEN '||l_where_str3;
                  END IF;  -- end FIELD_NAME.
                  IF l_where_str1 IS NULL THEN
                    l_where_str1 := ' WHERE PLAN_ID = '||P_PLAN_ID||' AND (';
                    l_where_str1 := l_where_str1 ||l_where_str2;
                  ELSE
                    IF NVL(l_rec_query.AND_OR_FLAG,2) = 1 THEN -- 1 AND, 2 OR
                        l_where_str1 := l_where_str1 ||' AND '||l_where_str2;
                    ELSE
                        l_where_str1 := l_where_str1 ||' OR '||l_where_str2;
                    END IF;
                  END IF;
                ELSIF l_rec_definition.FILTER_TYPE = 5 THEN -- LIKE
                  l_where_str2 := l_rec_definition.FIELD_NAME;
                  IF l_rec_definition.FIELD_NAME = 'FACILITY' THEN
                    --RAISE skip_condition;
                    l_where_str2 := 'ORIGIN_FACILITY';
                    l_where_str4 := 'DESTINATION_FACILITY';
                  END  IF;
                  IF l_rec_definition.FIELD_TYPE = 1 THEN -- NUMBER
                      l_where_str3 := l_rec_definition.FIELD_VALUE_FROM||'%';
                  ELSIF l_rec_definition.FIELD_TYPE =2 THEN -- varchar2
                      l_where_str3 := ''''||l_rec_definition.FIELD_VALUE_FROM||'%''';
                  END IF;
                  l_where_str2 := l_where_str2 ||' LIKE '||l_where_str3;
                  IF l_where_str4 IS NOT NULL THEN
                    l_where_str4 := l_where_str4 ||' LIKE '||l_where_str3;
                    l_where_str2 := '('||l_where_str2||' OR '||l_where_str4||' )';
                  END IF;
                  IF l_where_str1 IS NULL THEN
                    l_where_str1 := ' WHERE PLAN_ID = '||P_PLAN_ID||' AND (';
                    l_where_str1 := l_where_str1 ||l_where_str2;
                  ELSE
                    IF NVL(l_rec_query.AND_OR_FLAG,2) = 1 THEN -- 1 AND, 2 OR
                        l_where_str1 := l_where_str1 ||' AND '||l_where_str2;
                    ELSE
                        l_where_str1 := l_where_str1 ||' OR '||l_where_str2;
                    END IF;
                  END IF;
                ELSIF l_rec_definition.FILTER_TYPE = 6 THEN -- <
                  l_where_str2 := l_rec_definition.FIELD_NAME;

                  IF l_rec_definition.FIELD_TYPE = 1 THEN -- NUMBER
                      l_where_str3 := l_rec_definition.FIELD_VALUE_FROM;
                  ELSIF l_rec_definition.FIELD_TYPE =2 THEN -- varchar2
                      l_where_str3 := ''''||l_rec_definition.FIELD_VALUE_FROM||'''';
                  END IF;
                  l_where_str2 := l_where_str2 ||' < '||l_where_str3;
                  IF l_where_str1 IS NULL THEN
                    l_where_str1 := ' WHERE PLAN_ID = '||P_PLAN_ID||' AND (';
                    l_where_str1 := l_where_str1 ||l_where_str2;
                  ELSE
                    IF NVL(l_rec_query.AND_OR_FLAG,2) = 1 THEN -- 1 AND, 2 OR
                        l_where_str1 := l_where_str1 ||' AND '||l_where_str2;
                    ELSE
                        l_where_str1 := l_where_str1 ||' OR '||l_where_str2;
                    END IF;
                  END IF;
                ELSIF l_rec_definition.FILTER_TYPE = 7 THEN -- >
                  l_where_str2 := l_rec_definition.FIELD_NAME;

                  IF l_rec_definition.FIELD_TYPE = 1 THEN -- NUMBER
                      l_where_str3 := l_rec_definition.FIELD_VALUE_FROM;
                  ELSIF l_rec_definition.FIELD_TYPE =2 THEN -- varchar2
                      l_where_str3 := ''''||l_rec_definition.FIELD_VALUE_FROM||'''';
                  END IF;
                  l_where_str2 := l_where_str2 ||' > '||l_where_str3;
                  IF l_where_str1 IS NULL THEN
                    l_where_str1 := ' WHERE PLAN_ID = '||P_PLAN_ID||' AND (';
                    l_where_str1 := l_where_str1 ||l_where_str2;
                  ELSE
                    IF NVL(l_rec_query.AND_OR_FLAG,2) = 1 THEN -- 1 AND, 2 OR
                        l_where_str1 := l_where_str1 ||' AND '||l_where_str2;
                    ELSE
                        l_where_str1 := l_where_str1 ||' OR '||l_where_str2;
                    END IF;
                  END IF;
                ELSIF l_rec_definition.FILTER_TYPE = 8 THEN -- >= atleast
                  l_where_str2 := l_rec_definition.FIELD_NAME;

                  IF l_rec_definition.FIELD_TYPE = 1 THEN -- NUMBER
                      l_where_str3 := l_rec_definition.FIELD_VALUE_FROM;
                  ELSIF l_rec_definition.FIELD_TYPE =2 THEN -- varchar2
                      l_where_str3 := ''''||l_rec_definition.FIELD_VALUE_FROM||'''';
                  END IF;
                  l_where_str2 := l_where_str2 ||' >= '||l_where_str3;
                  IF l_where_str1 IS NULL THEN
                    l_where_str1 := ' WHERE PLAN_ID = '||P_PLAN_ID||' AND (';
                    l_where_str1 := l_where_str1 ||l_where_str2;
                  ELSE
                    IF NVL(l_rec_query.AND_OR_FLAG,2) = 1 THEN -- 1 AND, 2 OR
                        l_where_str1 := l_where_str1 ||' AND '||l_where_str2;
                    ELSE
                        l_where_str1 := l_where_str1 ||' OR '||l_where_str2;
                    END IF;
                  END IF;
                ELSIF l_rec_definition.FILTER_TYPE = 9 THEN -- <= atmost
                  l_where_str2 := l_rec_definition.FIELD_NAME;

                  IF l_rec_definition.FIELD_TYPE = 1 THEN -- NUMBER
                      l_where_str3 := l_rec_definition.FIELD_VALUE_FROM;
                  ELSIF l_rec_definition.FIELD_TYPE =2 THEN -- varchar2
                      l_where_str3 := ''''||l_rec_definition.FIELD_VALUE_FROM||'''';
                  END IF;
                  l_where_str2 := l_where_str2 ||' <= '||l_where_str3;
                  IF l_where_str1 IS NULL THEN
                    l_where_str1 := ' WHERE PLAN_ID = '||P_PLAN_ID||' AND (';
                    l_where_str1 := l_where_str1 ||l_where_str2;
                  ELSE
                    IF NVL(l_rec_query.AND_OR_FLAG,2) = 1 THEN -- 1 AND, 2 OR
                        l_where_str1 := l_where_str1 ||' AND '||l_where_str2;
                    ELSE
                        l_where_str1 := l_where_str1 ||' OR '||l_where_str2;
                    END IF;
                  END IF;
                -- --------------------------------
                ELSIF l_rec_definition.FILTER_TYPE = 10 THEN -- From or To
                  l_where_str2 := l_rec_definition.FIELD_NAME;
                    IF l_rec_definition.MULTI_SELECT =1 THEN -- YES
                        IF l_rec_definition.FIELD_TYPE = 1 THEN -- NUMBER
                            l_where_str3 := '('||REPLACE(rtrim(l_rec_definition.FIELD_VALUE_FROM,l_separator),l_separator,l_delim)||')';
                        ELSIF l_rec_definition.FIELD_TYPE =2 THEN -- varchar2
                            l_where_str3 := '('''||REPLACE(rtrim(l_rec_definition.FIELD_VALUE_FROM,l_separator),l_separator,''''||l_delim||'''')||''')';
                        END IF;
                        IF l_rec_definition.FILTER_TYPE = 2 THEN -- NOT
                            l_where_str2 := l_where_str2 ||' NOT IN '||l_where_str3;
                        ELSE
                            l_where_str2 := l_where_str2 ||' IN '||l_where_str3;
                        END IF;
                    ELSIF l_rec_definition.MULTI_SELECT =2 THEN -- no
                        IF l_rec_definition.FIELD_TYPE = 1 THEN -- NUMBER
                            l_where_str3 := l_rec_definition.FIELD_VALUE_FROM;
                        ELSIF l_rec_definition.FIELD_TYPE =2 THEN -- varchar2
                            l_where_str3 := ''''||l_rec_definition.FIELD_VALUE_FROM||'''';
                        END IF;
                        IF l_rec_definition.FILTER_TYPE = 2 THEN -- NOT
                            l_where_str2 := l_where_str2 ||' <> '||l_where_str3;
                        ELSE
                            l_where_str2 := l_where_str2 ||' = '||l_where_str3;
                        END IF;
                    END IF;
                    l_where_str2 := '('||l_where_str2||' OR ';
                    FETCH cur_definition INTO l_rec_definition;
                    IF cur_definition%NOTFOUND THEN
                        RAISE related_field_notfound;
                    END IF;
                    IF l_rec_definition.MULTI_SELECT =1 THEN -- YES
                        IF l_rec_definition.FIELD_TYPE = 1 THEN -- NUMBER
                            l_where_str3 := '('||REPLACE(rtrim(l_rec_definition.FIELD_VALUE_FROM,l_separator),l_separator,l_delim)||')';
                        ELSIF l_rec_definition.FIELD_TYPE =2 THEN -- varchar2
                            l_where_str3 := '('''||REPLACE(rtrim(l_rec_definition.FIELD_VALUE_FROM,l_separator),l_separator,''''||l_delim||'''')||''')';
                        END IF;
                        IF l_rec_definition.FILTER_TYPE = 2 THEN -- NOT
                            l_where_str2 := l_where_str2 ||l_rec_definition.FIELD_NAME||' NOT IN '||l_where_str3;
                        ELSE
                            l_where_str2 := l_where_str2 ||l_rec_definition.FIELD_NAME||' IN '||l_where_str3;
                        END IF;
                    ELSIF l_rec_definition.MULTI_SELECT =2 THEN -- no
                        IF l_rec_definition.FIELD_TYPE = 1 THEN -- NUMBER
                            l_where_str3 := l_rec_definition.FIELD_VALUE_FROM;
                        ELSIF l_rec_definition.FIELD_TYPE =2 THEN -- varchar2
                            l_where_str3 := ''''||l_rec_definition.FIELD_VALUE_FROM||'''';
                        END IF;
                        IF l_rec_definition.FILTER_TYPE = 2 THEN -- NOT
                            l_where_str2 := l_where_str2 ||l_rec_definition.FIELD_NAME||' <> '||l_where_str3;
                        ELSE
                            l_where_str2 := l_where_str2 ||l_rec_definition.FIELD_NAME||' = '||l_where_str3;
                        END IF;
                    END IF;
                    l_where_str2 := l_where_str2 ||')';
                  --END IF;
                  IF l_where_str1 IS NULL THEN
                    l_where_str1 := ' WHERE PLAN_ID = '||P_PLAN_ID||' AND (';
                    l_where_str1 := l_where_str1 ||l_where_str2;
                  ELSE
                    IF NVL(l_rec_query.AND_OR_FLAG,2) = 1 THEN -- 1 AND, 2 OR
                        l_where_str1 := l_where_str1 ||' AND '||l_where_str2;
                    ELSE
                        l_where_str1 := l_where_str1 ||' OR '||l_where_str2;
                    END IF;
                  END IF;
                END IF; -- end FILTER_TYPE
            EXCEPTION
                WHEN skip_condition THEN
                    NULL;
            END;
          END LOOP;
          CLOSE cur_definition;
          --KSA_DEBUG(SYSDATE,'out side loop -l_where_str1 '||l_where_str1,'populate_result_table');
          IF l_where_str1 IS NULL THEN
            RAISE no_data_found;
          END IF;
          l_executed:= execute_dyn_sql(l_insert_str||l_insert_Col||l_select_str||l_where_str1,NULL);
          IF l_executed = 0 THEN -- Continuous Moves
            RAISE execution_failed;
          END IF;
        END IF; -- end query_type
        retcode := 0;
        errbuf := NULL;
        COMMIT;
    EXCEPTION
        WHEN execution_failed THEN
            --RAISE;
            --errbuf := l_where_str1;
            retcode := 2;
        WHEN no_data_found THEN
            FND_MESSAGE.set_name('MST','MST_PQ_INADEQUATE_FILTER' ); --'Inadequate  Filter Conditions.');
            errbuf := FND_MESSAGE.GET;
            --errbuf := 'No logical conditions';
            retcode := 2;
        WHEN OTHERS THEN
            IF cur_definition%ISOPEN THEN
                CLOSE cur_definition;
            END IF;
            --KSA_DEBUG(SYSDATE,SQLERRM(SQLCODE),'populate_result_table');
            errbuf := SQLERRM(SQLCODE);
            retcode := 2;
            --RAISE;
    END populate_result_table;

    PROCEDURE remove_query(P_QUERY_ID IN NUMBER,
                           P_QUERY_TYPE IN NUMBER) IS
    BEGIN
        DELETE mst_personal_query_results
        WHERE query_id = p_query_id;
        --IF p_query_type IN (1,2,3,4) THEN
            DELETE mst_selection_criteria
            WHERE query_id = p_query_id;
        --END IF;
    EXCEPTION
    WHEN OTHERS THEN
        RAISE;
    END remove_query;

    PROCEDURE remove_qry_and_results(P_QUERY_ID IN NUMBER,
                                     P_QUERY_TYPE IN NUMBER) IS
        --pragma autonomous_transaction;
    BEGIN

        DELETE mst_personal_queries
        WHERE query_id = p_query_id;
        IF NOT sql%FOUND THEN
           RETURN;
        END IF;
        IF P_QUERY_TYPE = 1 THEN
            DELETE MST_LOAD_SELECTION_CRITERIA
            WHERE query_id = p_query_id;
        ELSIF P_QUERY_TYPE = 2 THEN
            DELETE MST_CM_SELECTION_CRITERIA
            WHERE query_id = p_query_id;
        ELSIF P_QUERY_TYPE = 3 THEN
            DELETE MST_ORDER_SELECTION_CRITERIA
            WHERE query_id = p_query_id;
        ELSIF P_QUERY_TYPE = 4 THEN
            DELETE MST_EXCEP_SELECTION_CRITERIA
            WHERE query_id = p_query_id;
        END IF;
        DELETE mst_personal_query_results
        WHERE query_id = p_query_id;

        DELETE mst_selection_criteria
        WHERE query_id = p_query_id;
        COMMIT;
    EXCEPTION
    WHEN OTHERS THEN
        RAISE;
    END remove_qry_and_results;

    PROCEDURE RENAME_QUERY(P_QUERY_ID IN NUMBER,
                           p_query_name IN VARCHAR2,
                           p_description IN VARCHAR2,
                           p_public_flag IN NUMBER) IS
    BEGIN
        UPDATE mst_personal_queries
        SET query_name = p_query_name,
            description = p_description,
            public_flag = p_public_flag
        WHERE query_id = p_query_id;
        commit;
    END RENAME_QUERY;

    PROCEDURE insert_load_selection(p_query_id IN NUMBER) IS

        cursor cur_loads is
        select ALL_TL, ALL_LTL, ALL_PARCEL,
               TLS_IN_CM,
               TL_NUMBERS,LTL_NUMBERS,PARCEL_NUMBERS,
               RANGE_TYPE, USER_EDITS_ONLY,
               ORIGIN_FACILITIES, DESTINATION_FACILITIES,
               ORIGIN_FACILITY_IDS, DESTINATION_FACILITY_IDS,
               ORIGIN_ZIP       , DESTINATION_ZIP,
               ORIGIN_CITY      , DESTINATION_CITY,
               ORIGIN_STATE     , DESTINATION_STATE,
               ORIGIN_COUNTRY   , DESTINATION_COUNTRY,
               CARRIERS   , CUSTOMERS   , SUPPLIERS   ,
               CARRIER_IDS, CUSTOMER_IDS, SUPPLIER_IDS,
               COST_TYPE  , COST_FROM   , COST_TO     ,
               WEIGHT_TYPE, WEIGHT_FROM , WEIGHT_TO   ,
               CUBE_TYPE  , CUBE_FROM   , CUBE_TO     ,
               UTILIZATION_TYPE   , UTILIZATION_FROM, UTILIZATION_TO,
               DEPARTURE_TIME_TYPE, DEPARTURE_TIME_FROM,
               DEPARTURE_TIME_TO  , DEPARTURE_TIME_UNIT
        from mst_load_selection_criteria
        where query_id = p_query_id;

        l_rec_loads cur_loads%ROWTYPE;

        l_insert_begin VARCHAR2(500);
        l_insert_what  VARCHAR2(3000);
        l_insert_who   VARCHAR2(500);
        l_delete_str   VARCHAR2(500);
        l_executed NUMBER ;
        l_filter_type NUMBER;
        l_sequence NUMBER ; --:= 0;
        l_multi_select NUMBER ; --:= 2; -- 1 true, 2 false
        l_active_flag NUMBER ; --:= 1;
        l_delim CONSTANT VARCHAR2(1) := ',';
        l_separator CONSTANT VARCHAR2(1):= ';';
        l_null_str CONSTANT VARCHAR2(6) := 'NULL';
        l_userid NUMBER ; --:= TO_NUMBER(FND_PROFILE.VALUE('USER_ID'));
        execution_failed EXCEPTION;
    BEGIN
        l_sequence := 0;
        l_multi_select := 2; -- 1 true, 2 false
        l_active_flag := 1;
        l_userid  := TO_NUMBER(FND_PROFILE.VALUE('USER_ID'));
        l_delete_str := 'DELETE MST_SELECTION_CRITERIA WHERE QUERY_ID = :P_QUERYID';
        l_executed := execute_dyn_sql(l_delete_str,p_query_id);
        IF l_executed = 0 THEN
            RAISE execution_failed;
        END IF;
        IF g_select_all IS NULL THEN
            FND_MESSAGE.set_name('MST','MST_PQ_ALL');
            g_select_all:= FND_MESSAGE.GET;
            --g_select_all := 'All';
        END IF;
        l_insert_begin := 'INSERT INTO MST_SELECTION_CRITERIA '||
                           '(QUERY_ID     , FIELD_NAME      , SEQUENCE     ,'||
                           'FILTER_TYPE   , FIELD_VALUE_FROM, DISPLAY_VALUE,'||
                           'FIELD_VALUE_TO, MULTI_SELECT    , ACTIVE_FLAG  ,'||
                           'CREATED_BY    , CREATION_DATE   ) VALUES ';
        OPEN cur_loads;
        FETCH cur_loads INTO l_rec_loads;
        IF cur_loads%NOTFOUND THEN
            CLOSE cur_loads;
            RAISE no_data_found;
        END IF;
        CLOSE cur_loads;
        -- ---------------------------
        -- Criteria 1-A - CM Trips
        -- ---------------------------
        l_filter_type := NULL;
        l_multi_select := 2;
        l_insert_what := '(';
        l_executed := NULL;
        IF l_rec_loads.TLS_IN_CM = 1 THEN
            DECLARE
              l_cm NUMBER;
            BEGIN
              l_sequence := l_sequence +1 ;
              l_filter_type := 1;
              l_cm := 1;
              l_insert_what := l_insert_what ||p_query_id||l_delim||'''CONTINUOUS_MOVE_ID'''||l_delim||
                                               l_sequence ||l_delim||l_filter_type||l_delim||
                                               ''''||l_cm||''''||l_delim||
                                               l_null_str||l_delim||l_null_str||l_delim||l_multi_select||l_delim||
                                               l_active_flag||l_delim;
              l_insert_who := l_userid||l_delim||'SYSDATE'||')';
              --KSA_DEBUG(SYSDATE,L_INSERT_WHO,'INSERT LOAD - WHO');
              l_executed := execute_dyn_sql(l_insert_begin||l_insert_what||l_insert_who,NULL);
              IF l_executed = 0 THEN
                RAISE execution_failed;
              END IF;
            END;
        END IF;
        l_filter_type := NULL;
        l_multi_select := 2;
        l_insert_what := '(';
        l_executed := NULL;
        -- ---------------------------------
        -- Criteria 1- mode of Transport
        -- ---------------------------------
        IF (l_rec_loads.ALL_TL = 1 AND l_rec_loads.TLS_IN_CM <> 1 )
        OR l_rec_loads.ALL_LTL = 1
        OR l_rec_loads.ALL_PARCEL = 1 THEN
            DECLARE
              l_modes VARCHAR2(50);
            BEGIN
              IF l_rec_loads.all_tl = 1 AND --OR
                 --l_rec_loads.TL_NUMBERS IS NOT NULL OR
                 l_rec_loads.TLS_IN_CM <> 1 THEN
                l_modes := 'TRUCK';
              END IF;
              IF l_rec_loads.all_ltl =1 THEN --OR
                 --l_rec_loads.LTL_NUMBERS IS NOT NULL THEN
                IF l_modes IS NOT NULL THEN
                  l_modes := l_modes||l_separator||'LTL';
                ELSE
                    l_modes := 'LTL';
                END IF;
              END IF;
              IF l_rec_loads.all_parcel =1 THEN --OR
                 --l_rec_loads.PARCEL_NUMBERS IS NOT NULL THEN
                IF l_modes IS NOT NULL THEN
                  l_modes := l_modes||l_separator||'PARCEL';
                ELSE
                    l_modes := 'PARCEL';
                END IF;
              END IF;
              l_sequence := l_sequence +1 ;
              IF instrb(l_modes,l_separator) > 0 THEN
                l_filter_type := 3;
                l_multi_select:= 1;
              ELSE
                l_filter_type := 1;
              END IF;
              l_INSERT_WHAT := l_insert_what ||p_query_id||l_delim||'''MODE_OF_TRANSPORT'''||l_delim||
                                               l_sequence ||l_delim||l_filter_type||l_delim||
                                               ''''||l_modes||''''||l_delim||
                                               l_null_str||l_delim||l_null_str||l_delim||l_multi_select||l_delim||
                                               l_active_flag||l_delim;
              l_insert_who := l_userid||l_delim||'SYSDATE'||')';
              --KSA_DEBUG(SYSDATE,L_INSERT_WHO,'INSERT LOAD - WHO');
              l_executed := execute_dyn_sql(l_insert_begin||l_insert_what||l_insert_who,NULL);
              IF l_executed = 0 THEN
                RAISE execution_failed;
              END IF;
            END;
        END IF;
        -- ---------------------------------
        -- Criteria 1-B - Trip Numbers
        -- ---------------------------------
        l_filter_type := NULL;
        l_multi_select := 2;
        l_insert_what := '(';
        l_executed := NULL;
        -- ---------------------------------
        -- Criteria 1-B-1 - TL Trip Numbers
        -- ---------------------------------
        IF l_rec_loads.TL_NUMBERS IS NOT NULL THEN
          DECLARE
            l_trip_numbers VARCHAR2(2000);
          BEGIN
            l_trip_numbers := l_rec_loads.TL_NUMBERS;

            IF instrb(l_trip_numbers,l_separator) > 0
            AND  instrb(l_trip_numbers,l_separator,-1)<>lengthb(l_trip_numbers) THEN
              l_trip_numbers := l_trip_numbers||l_separator;
            END IF;
            l_sequence := l_sequence +1 ;
            IF instrb(l_trip_numbers,l_separator) > 0 THEN
                l_filter_type := 3;
                l_multi_select:= 1;
            ELSE
                l_filter_type := 1;
            END IF;
            l_INSERT_WHAT := l_insert_what ||p_query_id||l_delim||'''TL_TRIP_NUMBER'''||l_delim||
                                             l_sequence ||l_delim||l_filter_type||l_delim||
                                             ''''||l_trip_numbers||''''||l_delim||
                                             l_null_str||l_delim||l_null_str||l_delim||l_multi_select||l_delim||
                                             l_active_flag||l_delim;
            l_insert_who := l_userid||l_delim||'SYSDATE'||')';
            l_executed := execute_dyn_sql(l_insert_begin||l_insert_what||l_insert_who,NULL);
            IF l_executed = 0 THEN
                RAISE execution_failed;
            END IF;
          END;
        END IF;
        l_filter_type := NULL;
        l_multi_select := 2;
        l_insert_what := '(';
        l_executed := NULL;
        -- ---------------------------------
        -- Criteria 1-B-2 - LTL Trip Numbers
        -- ---------------------------------
        IF l_rec_loads.LTL_NUMBERS IS NOT NULL THEN
          DECLARE
            l_trip_numbers VARCHAR2(2000);
          BEGIN
            l_trip_numbers := l_rec_loads.LTL_NUMBERS;

            IF instrb(l_trip_numbers,l_separator) > 0
            AND  instrb(l_trip_numbers,l_separator,-1)<>lengthb(l_trip_numbers) THEN
              l_trip_numbers := l_trip_numbers||l_separator;
            END IF;
            l_sequence := l_sequence +1 ;
            IF instrb(l_trip_numbers,l_separator) > 0 THEN
                l_filter_type := 3;
                l_multi_select:= 1;
            ELSE
                l_filter_type := 1;
            END IF;
            l_INSERT_WHAT := l_insert_what ||p_query_id||l_delim||'''LTL_TRIP_NUMBER'''||l_delim||
                                             l_sequence ||l_delim||l_filter_type||l_delim||
                                             ''''||l_trip_numbers||''''||l_delim||
                                             l_null_str||l_delim||l_null_str||l_delim||l_multi_select||l_delim||
                                             l_active_flag||l_delim;
            l_insert_who := l_userid||l_delim||'SYSDATE'||')';
            l_executed := execute_dyn_sql(l_insert_begin||l_insert_what||l_insert_who,NULL);
            IF l_executed = 0 THEN
                RAISE execution_failed;
            END IF;
          END;
        END IF;
        l_filter_type := NULL;
        l_multi_select := 2;
        l_insert_what := '(';
        l_executed := NULL;
        -- ------------------------------------
        -- Criteria 1-B-3 - PARCEL Trip Numbers
        -- ------------------------------------
        IF l_rec_loads.PARCEL_NUMBERS IS NOT NULL THEN
          DECLARE
            l_trip_numbers VARCHAR2(2000);
          BEGIN
            l_trip_numbers := l_rec_loads.PARCEL_NUMBERS;

            IF instrb(l_trip_numbers,l_separator) > 0
            AND  instrb(l_trip_numbers,l_separator,-1)<>lengthb(l_trip_numbers) THEN
              l_trip_numbers := l_trip_numbers||l_separator;
            END IF;
            l_sequence := l_sequence +1 ;
            IF instrb(l_trip_numbers,l_separator) > 0 THEN
                l_filter_type := 3;
                l_multi_select:= 1;
            ELSE
                l_filter_type := 1;
            END IF;
            l_INSERT_WHAT := l_insert_what ||p_query_id||l_delim||'''PARCEL_TRIP_NUMBER'''||l_delim||
                                             l_sequence ||l_delim||l_filter_type||l_delim||
                                             ''''||l_trip_numbers||''''||l_delim||
                                             l_null_str||l_delim||l_null_str||l_delim||l_multi_select||l_delim||
                                             l_active_flag||l_delim;
            l_insert_who := l_userid||l_delim||'SYSDATE'||')';
            l_executed := execute_dyn_sql(l_insert_begin||l_insert_what||l_insert_who,NULL);
            IF l_executed = 0 THEN
                RAISE execution_failed;
            END IF;
          END;
        END IF;
        /*@@@SKAKANI@@@IF l_rec_loads.TL_NUMBERS IS NOT NULL
        OR l_rec_loads.LTL_NUMBERS IS NOT NULL
        OR l_rec_loads.PARCEL_NUMBERS IS NOT NULL THEN
          DECLARE
            l_trip_numbers VARCHAR2(2000);
          BEGIN
            l_trip_numbers := l_rec_loads.TL_NUMBERS;
            IF l_rec_loads.LTL_NUMBERS IS NOT NULL THEN
              IF l_trip_numbers IS NOT NULL THEN
                IF instrb(l_trip_numbers,l_separator,-1)<>lengthb(l_trip_numbers) THEN
                  l_trip_numbers := l_trip_numbers||l_separator||l_rec_loads.LTL_NUMBERS;
                ELSE
                  l_trip_numbers := l_trip_numbers||l_rec_loads.LTL_NUMBERS;
                END IF;
              ELSE
                l_trip_numbers := l_rec_loads.LTL_NUMBERS;
              END IF;
            END IF;
            IF l_rec_loads.PARCEL_NUMBERS IS NOT NULL THEN
              IF l_trip_numbers IS NOT NULL THEN
                IF instrb(l_trip_numbers,l_separator,-1)<>lengthb(l_trip_numbers) THEN
                  l_trip_numbers := l_trip_numbers||l_separator||l_rec_loads.PARCEL_NUMBERS;
                ELSE
                  l_trip_numbers := l_trip_numbers||l_rec_loads.PARCEL_NUMBERS;
                END IF;
              ELSE
                l_trip_numbers := l_rec_loads.PARCEL_NUMBERS;
              END IF;
            END IF;
            IF instrb(l_trip_numbers,l_separator) > 0
            AND  instrb(l_trip_numbers,l_separator,-1)<>lengthb(l_trip_numbers) THEN
              l_trip_numbers := l_trip_numbers||l_separator;
            END IF;
            l_sequence := l_sequence +1 ;
            IF instrb(l_trip_numbers,l_separator) > 0 THEN
                l_filter_type := 3;
                l_multi_select:= 1;
            ELSE
                l_filter_type := 1;
            END IF;
            l_INSERT_WHAT := l_insert_what ||p_query_id||l_delim||'''TRIP_NUMBER'''||l_delim||
                                             l_sequence ||l_delim||l_filter_type||l_delim||
                                             ''''||l_trip_numbers||''''||l_delim||
                                             l_null_str||l_delim||l_null_str||l_delim||l_multi_select||l_delim||
                                             l_active_flag||l_delim;
            l_insert_who := l_userid||l_delim||'SYSDATE'||')';
            l_executed := execute_dyn_sql(l_insert_begin||l_insert_what||l_insert_who,NULL);
            IF l_executed = 0 THEN
                RAISE execution_failed;
            END IF;
          END;
        END IF;*/
        -- ---------------------------------
        -- Criteria 2 - USER EDITS
        -- ---------------------------------
        l_filter_type := NULL;
        l_multi_select := 2;
        l_insert_what := '(';
        l_executed := NULL;
        IF l_rec_loads.USER_EDITS_ONLY = 1 THEN
            DECLARE
              l_user_edits NUMBER;
              l_field_name VARCHAR2(30);
            BEGIN
              l_field_name := 'CHANGED_BY_USER';
              l_user_edits := 1;
              l_sequence := l_sequence +1 ;
              l_filter_type := 1;
              l_INSERT_WHAT := l_insert_what ||p_query_id||l_delim||''''||l_field_name||''''||l_delim||
                                               l_sequence ||l_delim||l_filter_type||l_delim||
                                               ''''||l_user_edits||''''||l_delim||
                                               l_null_str||l_delim||l_null_str||l_delim||l_multi_select||l_delim||
                                               l_active_flag||l_delim;
              l_insert_who := l_userid||l_delim||'SYSDATE'||')';
              --KSA_DEBUG(SYSDATE,L_INSERT_WHO,'INSERT LOAD - WHO');
              l_executed := execute_dyn_sql(l_insert_begin||l_insert_what||l_insert_who,NULL);
              IF l_executed = 0 THEN
                RAISE execution_failed;
              END IF;
            END;
        END IF;
        -- -------------------
        -- Criteria 3 - Range.
        -- -------------------
        l_filter_type := NULL;
        l_multi_select := 2;
        l_insert_what := '(';
        l_executed := NULL;
        IF l_rec_loads.RANGE_TYPE IN (1,2) THEN
            -- -----------------------------------
            -- Criteria 3 - Range -(1,2)- Facility
            -- -----------------------------------
            IF l_rec_loads.ORIGIN_FACILITIES <> g_select_all THEN
              DECLARE
                l_facilities VARCHAR2(2000);
                l_field_name VARCHAR2(30);
              BEGIN
                l_facilities := l_rec_loads.ORIGIN_FACILITY_IDS;

                IF l_rec_loads.RANGE_TYPE = 1 THEN
                    l_field_name := 'ORIGIN_FACILITY_ID';
                ELSIF l_rec_loads.RANGE_TYPE = 2 THEN
                    l_field_name := 'DESTINATION_FACILITY_ID';
                END IF;
                l_sequence := l_sequence +1 ;
                IF instrb(l_facilities,l_separator) > 0 THEN
                    l_filter_type := 3;
                    l_multi_select:= 1;
                ELSE
                    l_filter_type := 1;
                END IF;
                l_INSERT_WHAT := l_insert_what ||p_query_id||l_delim||''''||l_field_name||''''||l_delim||
                                                 l_sequence ||l_delim||l_filter_type||l_delim||
                                                 ''''||l_facilities||''''||l_delim||
                                                 l_null_str||l_delim||l_null_str||l_delim||l_multi_select||l_delim||
                                                 l_active_flag||l_delim;
                --KSA_DEBUG(SYSDATE,L_INSERT_WHAT,'INSERT LOAD - WHAT');
                l_insert_who := l_userid||l_delim||'SYSDATE'||')';
                l_executed := execute_dyn_sql(l_insert_begin||l_insert_what||l_insert_who,NULL);
              END;
            END IF; -- end ORIGIN_FACILITIES <> g_select_all
            -- -----------------------------------
            -- Criteria 3 - Range -(1,2)- Zip
            -- -----------------------------------
            l_filter_type := NULL;
            l_multi_select := 2;
            l_insert_what := '(';
            l_executed := NULL;
            IF l_rec_loads.ORIGIN_ZIP <> g_select_all THEN
              DECLARE
                l_postalcodes VARCHAR2(2000);
                l_field_name VARCHAR2(30);
              BEGIN
                l_postalcodes := l_rec_loads.ORIGIN_ZIP;

                IF l_rec_loads.RANGE_TYPE = 1 THEN
                    l_field_name := 'ORIGIN_ZIP';
                ELSIF l_rec_loads.RANGE_TYPE = 2 THEN
                    l_field_name := 'DESTINATION_ZIP';
                END IF;
                l_sequence := l_sequence +1 ;
                IF instrb(l_postalcodes,l_separator) > 0 THEN
                    l_filter_type := 3;
                    l_multi_select:= 1;
                ELSE
                    l_filter_type := 1;
                END IF;
                l_INSERT_WHAT := l_insert_what ||p_query_id||l_delim||''''||l_field_name||''''||l_delim||
                                                 l_sequence ||l_delim||l_filter_type||l_delim||
                                                 ''''||l_postalcodes||''''||l_delim||
                                                 l_null_str||l_delim||l_null_str||l_delim||l_multi_select||l_delim||
                                                 l_active_flag||l_delim;
                l_insert_who := l_userid||l_delim||'SYSDATE'||')';
                l_executed := execute_dyn_sql(l_insert_begin||l_insert_what||l_insert_who,NULL);
              END;
            END IF; -- end ORIGIN_ZIP <> g_select_all
            -- -----------------------------------
            -- Criteria 3 - Range -(1,2)- City
            -- -----------------------------------
            l_filter_type := NULL;
            l_multi_select := 2;
            l_insert_what := '(';
            l_executed := NULL;
            IF l_rec_loads.ORIGIN_CITY <> g_select_all THEN
              DECLARE
                l_cities      VARCHAR2(2000);
                l_field_name VARCHAR2(30);
              BEGIN
                l_cities := l_rec_loads.ORIGIN_CITY;

                IF l_rec_loads.RANGE_TYPE = 1 THEN
                    l_field_name := 'ORIGIN_CITY';
                ELSIF l_rec_loads.RANGE_TYPE = 2 THEN
                    l_field_name := 'DESTINATION_CITY';
                END IF;
                l_sequence := l_sequence +1 ;
                IF instrb(l_cities,l_separator) > 0 THEN
                    l_filter_type := 3;
                    l_multi_select:= 1;
                ELSE
                    l_filter_type := 1;
                END IF;
                l_INSERT_WHAT := l_insert_what ||p_query_id||l_delim||''''||l_field_name||''''||l_delim||
                                                 l_sequence ||l_delim||l_filter_type||l_delim||
                                                 ''''||l_cities||''''||l_delim||
                                                 l_null_str||l_delim||l_null_str||l_delim||l_multi_select||l_delim||
                                                 l_active_flag||l_delim;
                l_insert_who := l_userid||l_delim||'SYSDATE'||')';
                l_executed := execute_dyn_sql(l_insert_begin||l_insert_what||l_insert_who,NULL);
              END;
            END IF; -- end ORIGIN_CITY <> g_select_all
            -- -----------------------------------
            -- Criteria 3 - Range -(1,2)- State
            -- -----------------------------------
            l_filter_type := NULL;
            l_multi_select := 2;
            l_insert_what := '(';
            l_executed := NULL;
            IF l_rec_loads.ORIGIN_STATE <> g_select_all THEN
              DECLARE
                l_states      VARCHAR2(2000);
                l_field_name VARCHAR2(30);
              BEGIN
                l_states := l_rec_loads.ORIGIN_STATE;

                IF l_rec_loads.RANGE_TYPE = 1 THEN
                    l_field_name := 'ORIGIN_STATE';
                ELSIF l_rec_loads.RANGE_TYPE = 2 THEN
                    l_field_name := 'DESTINATION_STATE';
                END IF;
                l_sequence := l_sequence +1 ;
                IF instrb(l_states,l_separator) > 0 THEN
                    l_filter_type := 3;
                    l_multi_select:= 1;
                ELSE
                    l_filter_type := 1;
                END IF;
                l_INSERT_WHAT := l_insert_what ||p_query_id||l_delim||''''||l_field_name||''''||l_delim||
                                                 l_sequence ||l_delim||l_filter_type||l_delim||
                                                 ''''||l_states||''''||l_delim||
                                                 l_null_str||l_delim||l_null_str||l_delim||l_multi_select||l_delim||
                                                 l_active_flag||l_delim;
                l_insert_who := l_userid||l_delim||'SYSDATE'||')';
                l_executed := execute_dyn_sql(l_insert_begin||l_insert_what||l_insert_who,NULL);
              END;
            END IF; -- end ORIGIN_STATE <> g_select_all
            -- -----------------------------------
            -- Criteria 3 - Range -(1,2)- Country
            -- -----------------------------------
            l_filter_type := NULL;
            l_multi_select := 2;
            l_insert_what := '(';
            l_executed := NULL;
            IF l_rec_loads.ORIGIN_COUNTRY <> g_select_all THEN
              DECLARE
                l_countries      VARCHAR2(2000);
                l_field_name VARCHAR2(30);
              BEGIN
                l_countries := l_rec_loads.ORIGIN_COUNTRY;

                IF l_rec_loads.RANGE_TYPE = 1 THEN
                    l_field_name := 'ORIGIN_COUNTRY';
                ELSIF l_rec_loads.RANGE_TYPE = 2 THEN
                    l_field_name := 'DESTINATION_COUNTRY';
                END IF;
                l_sequence := l_sequence +1 ;
                IF instrb(l_countries,l_separator) > 0 THEN
                    l_filter_type := 3;
                    l_multi_select:= 1;
                ELSE
                    l_filter_type := 1;
                END IF;
                l_INSERT_WHAT := l_insert_what ||p_query_id||l_delim||''''||l_field_name||''''||l_delim||
                                                 l_sequence ||l_delim||l_filter_type||l_delim||
                                                 ''''||l_countries||''''||l_delim||
                                                 l_null_str||l_delim||l_null_str||l_delim||l_multi_select||l_delim||
                                                 l_active_flag||l_delim;
                l_insert_who := l_userid||l_delim||'SYSDATE'||')';
                l_executed := execute_dyn_sql(l_insert_begin||l_insert_what||l_insert_who,NULL);
              END;
            END IF; -- end ORIGIN_COUNTRY <> g_select_all
        ELSIF l_rec_loads.RANGE_TYPE = 3 THEN
            -- ---------------------------------
            -- Criteria 3 - Range -(3)- Facility
            -- ---------------------------------
            IF l_rec_loads.ORIGIN_FACILITIES <> g_select_all THEN
              DECLARE
                l_facilities VARCHAR2(2000);
                l_field_name VARCHAR2(30);
              BEGIN
                l_facilities := l_rec_loads.ORIGIN_FACILITY_IDS;
                l_field_name := 'ORIGIN_FACILITY_ID';
                l_sequence := l_sequence +1 ;
                IF instrb(l_facilities,l_separator) > 0 THEN
                    --l_filter_type := 3;
                    l_multi_select:= 1;
                ELSE
                    l_multi_select:= 2;
                    --l_filter_type := 1;
                END IF;
                l_filter_type := 10;
                l_INSERT_WHAT := l_insert_what ||p_query_id||l_delim||''''||l_field_name||''''||l_delim||
                                                 l_sequence ||l_delim||l_filter_type||l_delim||
                                                 ''''||l_facilities||''''||l_delim||
                                                 l_null_str||l_delim||l_null_str||l_delim||l_multi_select||l_delim||
                                                 l_active_flag||l_delim;
                l_insert_who := l_userid||l_delim||'SYSDATE'||')';
                l_executed := execute_dyn_sql(l_insert_begin||l_insert_what||l_insert_who,NULL);

                l_filter_type := NULL;
                l_multi_select := 2;
                l_insert_what := '(';
                l_executed := NULL;
                l_field_name := 'DESTINATION_FACILITY_ID';
                l_sequence := l_sequence +1 ;
                IF instrb(l_facilities,l_separator) > 0 THEN
                    --l_filter_type := 3;
                    l_multi_select:= 1;
                ELSE
                    --l_filter_type := 1;
                    l_multi_select:= 2;
                END IF;
                l_filter_type := 10;
                l_INSERT_WHAT := l_insert_what ||p_query_id||l_delim||''''||l_field_name||''''||l_delim||
                                                 l_sequence ||l_delim||l_filter_type||l_delim||
                                                 ''''||l_facilities||''''||l_delim||
                                                 l_null_str||l_delim||l_null_str||l_delim||l_multi_select||l_delim||
                                                 l_active_flag||l_delim;
                l_insert_who := l_userid||l_delim||'SYSDATE'||')';
                l_executed := execute_dyn_sql(l_insert_begin||l_insert_what||l_insert_who,NULL);
              END;
            END IF; -- end ORIGIN_FACILITIES <> g_select_all
            -- ---------------------------------
            -- Criteria 3 - Range -(3)- Zip
            -- ---------------------------------
            l_filter_type := NULL;
            l_multi_select := 2;
            l_insert_what := '(';
            l_executed := NULL;
            IF l_rec_loads.ORIGIN_ZIP <> g_select_all THEN
              DECLARE
                l_postalcodes VARCHAR2(2000);
                l_field_name VARCHAR2(30);
              BEGIN
                l_postalcodes := l_rec_loads.ORIGIN_ZIP;
                l_field_name := 'ORIGIN_ZIP';
                l_sequence := l_sequence +1 ;
                IF instrb(l_postalcodes,l_separator) > 0 THEN
                    --l_filter_type := 3;
                    l_multi_select:= 1;
                ELSE
                    --l_filter_type := 1;
                    l_multi_select:= 2;
                END IF;
                l_filter_type := 10;
                l_INSERT_WHAT := l_insert_what ||p_query_id||l_delim||''''||l_field_name||''''||l_delim||
                                                 l_sequence ||l_delim||l_filter_type||l_delim||
                                                 ''''||l_postalcodes||''''||l_delim||
                                                 l_null_str||l_delim||l_null_str||l_delim||l_multi_select||l_delim||
                                                 l_active_flag||l_delim;
                l_insert_who := l_userid||l_delim||'SYSDATE'||')';
                l_executed := execute_dyn_sql(l_insert_begin||l_insert_what||l_insert_who,NULL);

                l_filter_type := NULL;
                l_multi_select := 2;
                l_insert_what := '(';
                l_executed := NULL;
                l_field_name := 'DESTINATION_ZIP';
                l_sequence := l_sequence +1 ;
                IF instrb(l_postalcodes,l_separator) > 0 THEN
                    --l_filter_type := 3;
                    l_multi_select:= 1;
                ELSE
                    --l_filter_type := 1;
                    l_multi_select:= 2;
                END IF;
                l_filter_type := 10;
                l_INSERT_WHAT := l_insert_what ||p_query_id||l_delim||''''||l_field_name||''''||l_delim||
                                                 l_sequence ||l_delim||l_filter_type||l_delim||
                                                 ''''||l_postalcodes||''''||l_delim||
                                                 l_null_str||l_delim||l_null_str||l_delim||l_multi_select||l_delim||
                                                 l_active_flag||l_delim;
                l_insert_who := l_userid||l_delim||'SYSDATE'||')';
                l_executed := execute_dyn_sql(l_insert_begin||l_insert_what||l_insert_who,NULL);
              END;
            END IF; -- end ORIGIN_ZIP <> g_select_all
            -- ---------------------------------
            -- Criteria 3 - Range -(3)- City
            -- ---------------------------------
            l_filter_type := NULL;
            l_multi_select := 2;
            l_insert_what := '(';
            l_executed := NULL;
            IF l_rec_loads.ORIGIN_CITY <> g_select_all THEN
              DECLARE
                l_cities VARCHAR2(2000);
                l_field_name VARCHAR2(30);
              BEGIN
                l_cities := l_rec_loads.ORIGIN_CITY;
                l_field_name := 'ORIGIN_CITY';
                l_sequence := l_sequence +1 ;
                IF instrb(l_cities,l_separator) > 0 THEN
                    --l_filter_type := 3;
                    l_multi_select:= 1;
                ELSE
                    --l_filter_type := 1;
                    l_multi_select:= 2;
                END IF;
                l_filter_type := 10;
                l_INSERT_WHAT := l_insert_what ||p_query_id||l_delim||''''||l_field_name||''''||l_delim||
                                                 l_sequence ||l_delim||l_filter_type||l_delim||
                                                 ''''||l_cities||''''||l_delim||
                                                 l_null_str||l_delim||l_null_str||l_delim||l_multi_select||l_delim||
                                                 l_active_flag||l_delim;
                l_insert_who := l_userid||l_delim||'SYSDATE'||')';
                l_executed := execute_dyn_sql(l_insert_begin||l_insert_what||l_insert_who,NULL);

                l_filter_type := NULL;
                l_multi_select := 2;
                l_insert_what := '(';
                l_executed := NULL;
                l_field_name := 'DESTINATION_CITY';
                l_sequence := l_sequence +1 ;
                IF instrb(l_cities,l_separator) > 0 THEN
                    --l_filter_type := 3;
                    l_multi_select:= 1;
                ELSE
                    --l_filter_type := 1;
                    l_multi_select:= 2;
                END IF;
                l_filter_type := 10;
                l_INSERT_WHAT := l_insert_what ||p_query_id||l_delim||''''||l_field_name||''''||l_delim||
                                                 l_sequence ||l_delim||l_filter_type||l_delim||
                                                 ''''||l_cities||''''||l_delim||
                                                 l_null_str||l_delim||l_null_str||l_delim||l_multi_select||l_delim||
                                                 l_active_flag||l_delim;
                l_insert_who := l_userid||l_delim||'SYSDATE'||')';
                l_executed := execute_dyn_sql(l_insert_begin||l_insert_what||l_insert_who,NULL);
              END;
            END IF; -- end ORIGIN_CITY <> g_select_all
            -- ---------------------------------
            -- Criteria 3 - Range -(3)- State
            -- ---------------------------------
            l_filter_type := NULL;
            l_multi_select := 2;
            l_insert_what := '(';
            l_executed := NULL;
            IF l_rec_loads.ORIGIN_STATE <> g_select_all THEN
              DECLARE
                l_states VARCHAR2(2000);
                l_field_name VARCHAR2(30);
              BEGIN
                l_states := l_rec_loads.ORIGIN_STATE;
                l_field_name := 'ORIGIN_STATE';
                l_sequence := l_sequence +1 ;
                IF instrb(l_states,l_separator) > 0 THEN
                    --l_filter_type := 3;
                    l_multi_select:= 1;
                ELSE
                    --l_filter_type := 1;
                    l_multi_select:= 2;
                END IF;
                l_filter_type := 10;
                l_INSERT_WHAT := l_insert_what ||p_query_id||l_delim||''''||l_field_name||''''||l_delim||
                                                 l_sequence ||l_delim||l_filter_type||l_delim||
                                                 ''''||l_states||''''||l_delim||
                                                 l_null_str||l_delim||l_null_str||l_delim||l_multi_select||l_delim||
                                                 l_active_flag||l_delim;
                l_insert_who := l_userid||l_delim||'SYSDATE'||')';
                l_executed := execute_dyn_sql(l_insert_begin||l_insert_what||l_insert_who,NULL);

                l_filter_type := NULL;
                l_multi_select := 2;
                l_insert_what := '(';
                l_executed := NULL;
                l_field_name := 'DESTINATION_STATE';
                l_sequence := l_sequence +1 ;
                IF instrb(l_states,l_separator) > 0 THEN
                    --l_filter_type := 3;
                    l_multi_select:= 1;
                ELSE
                    --l_filter_type := 1;
                    l_multi_select:= 2;
                END IF;
                l_filter_type := 10;
                l_INSERT_WHAT := l_insert_what ||p_query_id||l_delim||''''||l_field_name||''''||l_delim||
                                                 l_sequence ||l_delim||l_filter_type||l_delim||
                                                 ''''||l_states||''''||l_delim||
                                                 l_null_str||l_delim||l_null_str||l_delim||l_multi_select||l_delim||
                                                 l_active_flag||l_delim;
                l_insert_who := l_userid||l_delim||'SYSDATE'||')';
                l_executed := execute_dyn_sql(l_insert_begin||l_insert_what||l_insert_who,NULL);
              END;
            END IF; -- end ORIGIN_STATE <> g_select_all
            -- ---------------------------------
            -- Criteria 3 - Range -(3)- Country
            -- ---------------------------------
            l_filter_type := NULL;
            l_multi_select := 2;
            l_insert_what := '(';
            l_executed := NULL;
            IF l_rec_loads.ORIGIN_COUNTRY <> g_select_all THEN
              DECLARE
                l_countries VARCHAR2(2000);
                l_field_name VARCHAR2(30);
              BEGIN
                l_countries := l_rec_loads.ORIGIN_COUNTRY;
                l_field_name := 'ORIGIN_COUNTRY';
                l_sequence := l_sequence +1 ;
                IF instrb(l_countries,l_separator) > 0 THEN
                    --l_filter_type := 3;
                    l_multi_select:= 1;
                ELSE
                    --l_filter_type := 1;
                    l_multi_select:= 2;
                END IF;
                l_filter_type := 10;
                l_INSERT_WHAT := l_insert_what ||p_query_id||l_delim||''''||l_field_name||''''||l_delim||
                                                 l_sequence ||l_delim||l_filter_type||l_delim||
                                                 ''''||l_countries||''''||l_delim||
                                                 l_null_str||l_delim||l_null_str||l_delim||l_multi_select||l_delim||
                                                 l_active_flag||l_delim;
                l_insert_who := l_userid||l_delim||'SYSDATE'||')';
                l_executed := execute_dyn_sql(l_insert_begin||l_insert_what||l_insert_who,NULL);

                l_filter_type := NULL;
                l_multi_select := 2;
                l_insert_what := '(';
                l_executed := NULL;
                l_field_name := 'DESTINATION_COUNTRY';
                l_sequence := l_sequence +1 ;
                IF instrb(l_countries,l_separator) > 0 THEN
                    --l_filter_type := 3;
                    l_multi_select:= 1;
                ELSE
                    --l_filter_type := 1;
                    l_multi_select:= 2;
                END IF;
                l_filter_type := 10;
                l_INSERT_WHAT := l_insert_what ||p_query_id||l_delim||''''||l_field_name||''''||l_delim||
                                                 l_sequence ||l_delim||l_filter_type||l_delim||
                                                 ''''||l_countries||''''||l_delim||
                                                 l_null_str||l_delim||l_null_str||l_delim||l_multi_select||l_delim||
                                                 l_active_flag||l_delim;
                l_insert_who := l_userid||l_delim||'SYSDATE'||')';
                l_executed := execute_dyn_sql(l_insert_begin||l_insert_what||l_insert_who,NULL);
              END;
            END IF; -- end ORIGIN_COUNTRY <> g_select_all
        ELSIF l_rec_loads.RANGE_TYPE = 4 THEN
            -- ---------------------------------
            -- Criteria 3 - Range -(4)- Facility
            -- ---------------------------------
            IF l_rec_loads.ORIGIN_FACILITIES <> g_select_all THEN
              DECLARE
                l_facilities VARCHAR2(2000);
                l_field_name VARCHAR2(30);
              BEGIN
                l_facilities := l_rec_loads.ORIGIN_FACILITY_IDS;
                l_field_name := 'ORIGIN_FACILITY_ID';
                l_sequence := l_sequence +1 ;
                IF instrb(l_facilities,l_separator) > 0 THEN
                    IF l_rec_loads.DESTINATION_FACILITIES = g_select_all THEN
                        l_filter_type := 3;
                    ELSE
                        l_filter_type := 4;
                    END IF;
                    l_multi_select:= 1;
                ELSE
                    IF l_rec_loads.DESTINATION_FACILITIES = g_select_all THEN
                        l_filter_type := 1;
                    ELSE
                        l_filter_type := 4;
                    END IF;
                END IF;
                --l_filter_type := 4;
                l_INSERT_WHAT := l_insert_what ||p_query_id||l_delim||''''||l_field_name||''''||l_delim||
                                                 l_sequence ||l_delim||l_filter_type||l_delim||
                                                 ''''||l_facilities||''''||l_delim||
                                                 l_null_str||l_delim||l_null_str||l_delim||l_multi_select||l_delim||
                                                 l_active_flag||l_delim;
                l_insert_who := l_userid||l_delim||'SYSDATE'||')';
                l_executed := execute_dyn_sql(l_insert_begin||l_insert_what||l_insert_who,NULL);
              END;
            END IF; -- end ORIGIN_FACILITY <> g_select_all
            l_filter_type := NULL;
            l_multi_select := 2;
            l_insert_what := '(';
            l_executed := NULL;
            IF l_rec_loads.DESTINATION_FACILITIES <> g_select_all THEN
              DECLARE
                l_facilities VARCHAR2(2000);
                l_field_name VARCHAR2(30);
              BEGIN
                l_facilities := l_rec_loads.DESTINATION_FACILITY_IDS;
                l_field_name := 'DESTINATION_FACILITY_ID';
                l_sequence := l_sequence +1 ;
                IF instrb(l_facilities,l_separator) > 0 THEN
                    IF l_rec_loads.ORIGIN_FACILITIES = g_select_all THEN
                        l_filter_type := 3;
                    ELSE
                        l_filter_type := 4;
                    END IF;
                    l_multi_select:= 1;
                ELSE
                    IF l_rec_loads.ORIGIN_FACILITIES = g_select_all THEN
                        l_filter_type := 1;
                    ELSE
                        l_filter_type := 4;
                    END IF;
                END IF;
                --l_filter_type := 4;
                l_INSERT_WHAT := l_insert_what ||p_query_id||l_delim||''''||l_field_name||''''||l_delim||
                                                 l_sequence ||l_delim||l_filter_type||l_delim||
                                                 ''''||l_facilities||''''||l_delim||
                                                 l_null_str||l_delim||l_null_str||l_delim||l_multi_select||l_delim||
                                                 l_active_flag||l_delim;
                l_insert_who := l_userid||l_delim||'SYSDATE'||')';
                l_executed := execute_dyn_sql(l_insert_begin||l_insert_what||l_insert_who,NULL);
              END;
            END IF; -- end DESTINATION_FACILITIES <> g_select_all
            -- ---------------------------------
            -- Criteria 3 - Range -(4)- Zip
            -- ---------------------------------
            l_filter_type := NULL;
            l_multi_select := 2;
            l_insert_what := '(';
            l_executed := NULL;
            IF l_rec_loads.ORIGIN_ZIP <> g_select_all THEN
              DECLARE
                l_postalcodes VARCHAR2(2000);
                l_field_name VARCHAR2(30);
              BEGIN
                l_postalcodes := l_rec_loads.ORIGIN_ZIP;
                l_field_name := 'ORIGIN_ZIP';
                l_sequence := l_sequence +1 ;
                IF instrb(l_postalcodes,l_separator) > 0 THEN
                    --l_filter_type := 3;
                    IF l_rec_loads.DESTINATION_ZIP = g_select_all THEN
                        l_filter_type := 3;
                    ELSE
                        l_filter_type := 4;
                    END IF;
                    l_multi_select:= 1;
                ELSE
                    IF l_rec_loads.DESTINATION_ZIP = g_select_all THEN
                        l_filter_type := 1;
                    ELSE
                        l_filter_type := 4;
                    END IF;
                    --l_filter_type := 1;
                END IF;
                l_INSERT_WHAT := l_insert_what ||p_query_id||l_delim||''''||l_field_name||''''||l_delim||
                                                 l_sequence ||l_delim||l_filter_type||l_delim||
                                                 ''''||l_postalcodes||''''||l_delim||
                                                 l_null_str||l_delim||l_null_str||l_delim||l_multi_select||l_delim||
                                                 l_active_flag||l_delim;
                l_insert_who := l_userid||l_delim||'SYSDATE'||')';
                l_executed := execute_dyn_sql(l_insert_begin||l_insert_what||l_insert_who,NULL);
              END;
            END IF; -- end ORIGIN_ZIP <> g_select_all
            l_filter_type := NULL;
            l_multi_select := 2;
            l_insert_what := '(';
            l_executed := NULL;
            IF l_rec_loads.DESTINATION_ZIP <> g_select_all THEN
              DECLARE
                l_postalcodes VARCHAR2(2000);
                l_field_name VARCHAR2(30);
              BEGIN
                l_postalcodes := l_rec_loads.DESTINATION_ZIP;
                l_field_name := 'DESTINATION_ZIP';
                l_sequence := l_sequence +1 ;
                IF instrb(l_postalcodes,l_separator) > 0 THEN
                    IF l_rec_loads.ORIGIN_ZIP = g_select_all THEN
                        l_filter_type := 3;
                    ELSE
                        l_filter_type := 4;
                    END IF;
                    --l_filter_type := 3;
                    l_multi_select:= 1;
                ELSE
                    --l_filter_type := 1;
                    IF l_rec_loads.ORIGIN_ZIP = g_select_all THEN
                        l_filter_type := 1;
                    ELSE
                        l_filter_type := 4;
                    END IF;
                END IF;
                l_INSERT_WHAT := l_insert_what ||p_query_id||l_delim||''''||l_field_name||''''||l_delim||
                                                 l_sequence ||l_delim||l_filter_type||l_delim||
                                                 ''''||l_postalcodes||''''||l_delim||
                                                 l_null_str||l_delim||l_null_str||l_delim||l_multi_select||l_delim||
                                                 l_active_flag||l_delim;
                l_insert_who := l_userid||l_delim||'SYSDATE'||')';
                l_executed := execute_dyn_sql(l_insert_begin||l_insert_what||l_insert_who,NULL);
              END;
            END IF; -- end DESTINATION_ZIP <> g_select_all
            -- ---------------------------------
            -- Criteria 3 - Range -(4)- City
            -- ---------------------------------
            l_filter_type := NULL;
            l_multi_select := 2;
            l_insert_what := '(';
            l_executed := NULL;
            IF l_rec_loads.ORIGIN_CITY <> g_select_all THEN
              DECLARE
                l_cities VARCHAR2(2000);
                l_field_name VARCHAR2(30);
              BEGIN
                l_cities := l_rec_loads.ORIGIN_CITY;
                l_field_name := 'ORIGIN_CITY';
                l_sequence := l_sequence +1 ;
                IF instrb(l_cities,l_separator) > 0 THEN
                    --l_filter_type := 3;
                    IF l_rec_loads.DESTINATION_CITY = g_select_all THEN
                        l_filter_type := 3;
                    ELSE
                        l_filter_type := 4;
                    END IF;
                    l_multi_select:= 1;
                ELSE
                    --l_filter_type := 1;
                    IF l_rec_loads.DESTINATION_CITY = g_select_all THEN
                        l_filter_type := 1;
                    ELSE
                        l_filter_type := 4;
                    END IF;
                END IF;
                l_INSERT_WHAT := l_insert_what ||p_query_id||l_delim||''''||l_field_name||''''||l_delim||
                                                 l_sequence ||l_delim||l_filter_type||l_delim||
                                                 ''''||l_cities||''''||l_delim||
                                                 l_null_str||l_delim||l_null_str||l_delim||l_multi_select||l_delim||
                                                 l_active_flag||l_delim;
                l_insert_who := l_userid||l_delim||'SYSDATE'||')';
                l_executed := execute_dyn_sql(l_insert_begin||l_insert_what||l_insert_who,NULL);
              END;
            END IF; -- end ORIGIN_CITY <> g_select_all
            l_filter_type := NULL;
            l_multi_select := 2;
            l_insert_what := '(';
            l_executed := NULL;
            IF l_rec_loads.DESTINATION_CITY <> g_select_all THEN
              DECLARE
                l_cities VARCHAR2(2000);
                l_field_name VARCHAR2(30);
              BEGIN
                l_cities := l_rec_loads.DESTINATION_CITY;
                l_field_name := 'DESTINATION_CITY';
                l_sequence := l_sequence +1 ;
                IF instrb(l_cities,l_separator) > 0 THEN
                    --l_filter_type := 3;
                    IF l_rec_loads.ORIGIN_CITY = g_select_all THEN
                        l_filter_type := 3;
                    ELSE
                        l_filter_type := 4;
                    END IF;
                    l_multi_select:= 1;
                ELSE
                    --l_filter_type := 1;
                    IF l_rec_loads.ORIGIN_CITY = g_select_all THEN
                        l_filter_type := 1;
                    ELSE
                        l_filter_type := 4;
                    END IF;
                END IF;
                l_INSERT_WHAT := l_insert_what ||p_query_id||l_delim||''''||l_field_name||''''||l_delim||
                                                 l_sequence ||l_delim||l_filter_type||l_delim||
                                                 ''''||l_cities||''''||l_delim||
                                                 l_null_str||l_delim||l_null_str||l_delim||l_multi_select||l_delim||
                                                 l_active_flag||l_delim;
                l_insert_who := l_userid||l_delim||'SYSDATE'||')';
                l_executed := execute_dyn_sql(l_insert_begin||l_insert_what||l_insert_who,NULL);
              END;
            END IF; -- end DESTINATION_CITY <> g_select_all
            -- ---------------------------------
            -- Criteria 3 - Range -(4)- State
            -- ---------------------------------
            l_filter_type := NULL;
            l_multi_select := 2;
            l_insert_what := '(';
            l_executed := NULL;
            IF l_rec_loads.ORIGIN_STATE <> g_select_all THEN
              DECLARE
                l_states VARCHAR2(2000);
                l_field_name VARCHAR2(30);
              BEGIN
                l_states := l_rec_loads.ORIGIN_STATE;
                l_field_name := 'ORIGIN_STATE';
                l_sequence := l_sequence +1 ;
                IF instrb(l_states,l_separator) > 0 THEN
                    --l_filter_type := 3;
                    IF l_rec_loads.DESTINATION_STATE = g_select_all THEN
                        l_filter_type := 3;
                    ELSE
                        l_filter_type := 4;
                    END IF;
                    l_multi_select:= 1;
                ELSE
                    --l_filter_type := 1;
                    IF l_rec_loads.DESTINATION_STATE = g_select_all THEN
                        l_filter_type := 1;
                    ELSE
                        l_filter_type := 4;
                    END IF;
                END IF;
                l_INSERT_WHAT := l_insert_what ||p_query_id||l_delim||''''||l_field_name||''''||l_delim||
                                                 l_sequence ||l_delim||l_filter_type||l_delim||
                                                 ''''||l_states||''''||l_delim||
                                                 l_null_str||l_delim||l_null_str||l_delim||l_multi_select||l_delim||
                                                 l_active_flag||l_delim;
                l_insert_who := l_userid||l_delim||'SYSDATE'||')';
                l_executed := execute_dyn_sql(l_insert_begin||l_insert_what||l_insert_who,NULL);
              END;
            END IF; -- end ORIGIN_STATE <> g_select_all
            l_filter_type := NULL;
            l_multi_select := 2;
            l_insert_what := '(';
            l_executed := NULL;
            IF l_rec_loads.DESTINATION_STATE <> g_select_all THEN
              DECLARE
                l_states VARCHAR2(2000);
                l_field_name VARCHAR2(30);
              BEGIN
                l_states := l_rec_loads.DESTINATION_STATE;
                l_field_name := 'DESTINATION_STATE';
                l_sequence := l_sequence +1 ;
                IF instrb(l_states,l_separator) > 0 THEN
                    --l_filter_type := 3;
                    IF l_rec_loads.ORIGIN_STATE = g_select_all THEN
                        l_filter_type := 3;
                    ELSE
                        l_filter_type := 4;
                    END IF;
                    l_multi_select:= 1;
                ELSE
                    --l_filter_type := 1;
                    IF l_rec_loads.ORIGIN_STATE = g_select_all THEN
                        l_filter_type := 1;
                    ELSE
                        l_filter_type := 4;
                    END IF;
                END IF;
                l_INSERT_WHAT := l_insert_what ||p_query_id||l_delim||''''||l_field_name||''''||l_delim||
                                                 l_sequence ||l_delim||l_filter_type||l_delim||
                                                 ''''||l_states||''''||l_delim||
                                                 l_null_str||l_delim||l_null_str||l_delim||l_multi_select||l_delim||
                                                 l_active_flag||l_delim;
                l_insert_who := l_userid||l_delim||'SYSDATE'||')';
                l_executed := execute_dyn_sql(l_insert_begin||l_insert_what||l_insert_who,NULL);
              END;
            END IF; -- end DESTINATION_STATE <> g_select_all
            -- ---------------------------------
            -- Criteria 3 - Range -(4)- Country
            -- ---------------------------------
            l_filter_type := NULL;
            l_multi_select := 2;
            l_insert_what := '(';
            l_executed := NULL;
            IF l_rec_loads.ORIGIN_COUNTRY <> g_select_all THEN
              DECLARE
                l_countries VARCHAR2(2000);
                l_field_name VARCHAR2(30);
              BEGIN
                l_countries := l_rec_loads.ORIGIN_COUNTRY;
                l_field_name := 'ORIGIN_COUNTRY';
                l_sequence := l_sequence +1 ;
                IF instrb(l_countries,l_separator) > 0 THEN
                    --l_filter_type := 3;
                    IF l_rec_loads.DESTINATION_COUNTRY = g_select_all THEN
                        l_filter_type := 3;
                    ELSE
                        l_filter_type := 4;
                    END IF;
                    l_multi_select:= 1;
                ELSE
                    --l_filter_type := 1;
                    IF l_rec_loads.DESTINATION_COUNTRY = g_select_all THEN
                        l_filter_type := 1;
                    ELSE
                        l_filter_type := 4;
                    END IF;
                END IF;
                l_INSERT_WHAT := l_insert_what ||p_query_id||l_delim||''''||l_field_name||''''||l_delim||
                                                 l_sequence ||l_delim||l_filter_type||l_delim||
                                                 ''''||l_countries||''''||l_delim||
                                                 l_null_str||l_delim||l_null_str||l_delim||l_multi_select||l_delim||
                                                 l_active_flag||l_delim;
                l_insert_who := l_userid||l_delim||'SYSDATE'||')';
                l_executed := execute_dyn_sql(l_insert_begin||l_insert_what||l_insert_who,NULL);
              END;
            END IF; -- end ORIGIN_COUNTRY <> g_select_all
            l_filter_type := NULL;
            l_multi_select := 2;
            l_insert_what := '(';
            l_executed := NULL;
            IF l_rec_loads.DESTINATION_COUNTRY <> g_select_all THEN
              DECLARE
                l_countries VARCHAR2(2000);
                l_field_name VARCHAR2(30);
              BEGIN
                l_countries := l_rec_loads.DESTINATION_COUNTRY;
                l_field_name := 'DESTINATION_COUNTRY';
                l_sequence := l_sequence +1 ;
                IF instrb(l_countries,l_separator) > 0 THEN
                    --l_filter_type := 3;
                    IF l_rec_loads.ORIGIN_COUNTRY = g_select_all THEN
                        l_filter_type := 3;
                    ELSE
                        l_filter_type := 4;
                    END IF;
                    l_multi_select:= 1;
                ELSE
                    --l_filter_type := 1;
                    IF l_rec_loads.ORIGIN_COUNTRY = g_select_all THEN
                        l_filter_type := 1;
                    ELSE
                        l_filter_type := 4;
                    END IF;
                END IF;
                l_INSERT_WHAT := l_insert_what ||p_query_id||l_delim||''''||l_field_name||''''||l_delim||
                                                 l_sequence ||l_delim||l_filter_type||l_delim||
                                                 ''''||l_countries||''''||l_delim||
                                                 l_null_str||l_delim||l_null_str||l_delim||l_multi_select||l_delim||
                                                 l_active_flag||l_delim;
                l_insert_who := l_userid||l_delim||'SYSDATE'||')';
                l_executed := execute_dyn_sql(l_insert_begin||l_insert_what||l_insert_who,NULL);
              END;
            END IF; -- end DESTINATION_COUNTRY <> g_select_all
        END IF; -- end RANGE_TYPE
        -- ---------------------------------
        -- Criteria 4 - Carriers
        -- ---------------------------------
        l_filter_type := NULL;
        l_multi_select := 2;
        l_insert_what := '(';
        l_executed := NULL;
        IF l_rec_loads.Carriers <> g_select_all THEN
          DECLARE
            l_Carriers VARCHAR2(2000);
            l_field_name VARCHAR2(30);
          BEGIN
            l_Carriers := l_rec_loads.Carrier_ids;
            l_field_name := 'CARRIER_ID';
            l_sequence := l_sequence +1 ;
            IF instrb(l_Carriers,l_separator) > 0 THEN
                l_filter_type := 3;
                l_multi_select:= 1;
            ELSE
                l_filter_type := 1;
            END IF;
            l_INSERT_WHAT := l_insert_what ||p_query_id||l_delim||''''||l_field_name||''''||l_delim||
                                             l_sequence ||l_delim||l_filter_type||l_delim||
                                             ''''||l_Carriers||''''||l_delim||
                                             l_null_str||l_delim||l_null_str||l_delim||l_multi_select||l_delim||
                                             l_active_flag||l_delim;
            l_insert_who := l_userid||l_delim||'SYSDATE'||')';
            l_executed := execute_dyn_sql(l_insert_begin||l_insert_what||l_insert_who,NULL);
            IF l_executed = 0 THEN
                RAISE execution_failed;
            END IF;
          END;
        END IF; -- end Carriers <> g_select_all
        -- ---------------------------------
        -- Criteria 5 - Customers
        -- ---------------------------------
        l_filter_type := NULL;
        l_multi_select := 2;
        l_insert_what := '(';
        l_executed := NULL;
        IF l_rec_loads.Customers <> g_select_all THEN
          DECLARE
            l_Customers VARCHAR2(2000);
            l_field_name VARCHAR2(30);
          BEGIN
            l_Customers := l_rec_loads.Customer_ids;
            l_field_name := 'CUSTOMER_ID';
            l_sequence := l_sequence +1 ;
            IF instrb(l_Customers,l_separator) > 0 THEN
                l_filter_type := 3;
                l_multi_select:= 1;
            ELSE
                l_filter_type := 1;
            END IF;
            l_INSERT_WHAT := l_insert_what ||p_query_id||l_delim||''''||l_field_name||''''||l_delim||
                                             l_sequence ||l_delim||l_filter_type||l_delim||
                                             ''''||l_Customers||''''||l_delim||
                                             l_null_str||l_delim||l_null_str||l_delim||l_multi_select||l_delim||
                                             l_active_flag||l_delim;
            l_insert_who := l_userid||l_delim||'SYSDATE'||')';
            l_executed := execute_dyn_sql(l_insert_begin||l_insert_what||l_insert_who,NULL);
            IF l_executed = 0 THEN
                RAISE execution_failed;
            END IF;
          END;
        END IF; -- end Customers <> g_select_all
        -- ---------------------------------
        -- Criteria 6 - Suppliers
        -- ---------------------------------
        l_filter_type := NULL;
        l_multi_select := 2;
        l_insert_what := '(';
        l_executed := NULL;
        IF l_rec_loads.Suppliers <> g_select_all THEN
          DECLARE
            l_Suppliers VARCHAR2(2000);
            l_field_name VARCHAR2(30);
          BEGIN
            l_Suppliers := l_rec_loads.Supplier_ids;
            l_field_name := 'SUPPLIER_ID';
            l_sequence := l_sequence +1 ;
            IF instrb(l_Suppliers,l_separator) > 0 THEN
                l_filter_type := 3;
                l_multi_select:= 1;
            ELSE
                l_filter_type := 1;
            END IF;
            l_INSERT_WHAT := l_insert_what ||p_query_id||l_delim||''''||l_field_name||''''||l_delim||
                                             l_sequence ||l_delim||l_filter_type||l_delim||
                                             ''''||l_Suppliers||''''||l_delim||
                                             l_null_str||l_delim||l_null_str||l_delim||l_multi_select||l_delim||
                                             l_active_flag||l_delim;
            l_insert_who := l_userid||l_delim||'SYSDATE'||')';
            l_executed := execute_dyn_sql(l_insert_begin||l_insert_what||l_insert_who,NULL);
            IF l_executed = 0 THEN
                RAISE execution_failed;
            END IF;
          END;
        END IF; -- end Suppliers <> g_select_all
        -- ---------------------------------
        -- Criteria 7 - Cost
        -- ---------------------------------
        l_filter_type := NULL;
        l_multi_select := 2;
        l_insert_what := '(';
        l_executed := NULL;
        IF l_rec_loads.COST_FROM IS NOT NULL THEN
          DECLARE
            l_cost_from NUMBER;
            l_cost_to NUMBER;
            l_field_name VARCHAR2(30);
          BEGIN
            l_cost_from := l_rec_loads.COST_FROM;
            l_field_name := 'TOTAL_COST';
            l_sequence := l_sequence +1 ;
            l_filter_type := l_rec_loads.COST_TYPE;
            l_multi_select:= 2;
            IF l_filter_type = 4 THEN
                l_cost_to := l_rec_loads.COST_TO;
            END IF;
            l_INSERT_WHAT := l_insert_what ||p_query_id||l_delim||''''||l_field_name||''''||l_delim||
                                             l_sequence ||l_delim||l_filter_type||l_delim||
                                             ''''||l_cost_from||''''||l_delim||
                                             l_null_str||l_delim||''''||l_cost_to||''''||l_delim||
                                             l_multi_select||l_delim||
                                             l_active_flag||l_delim;
            l_insert_who := l_userid||l_delim||'SYSDATE'||')';
            l_executed := execute_dyn_sql(l_insert_begin||l_insert_what||l_insert_who,NULL);
            IF l_executed = 0 THEN
                RAISE execution_failed;
            END IF;
          END;
        END IF; -- end COST_FROM IS NOT NULL
        -- ---------------------------------
        -- Criteria 8 - Weight
        -- ---------------------------------
        l_filter_type := NULL;
        l_multi_select := 2;
        l_insert_what := '(';
        l_executed := NULL;
        IF l_rec_loads.WEIGHT_FROM IS NOT NULL THEN
          DECLARE
            l_WEIGHT_from NUMBER;
            l_WEIGHT_to NUMBER;
            l_field_name VARCHAR2(30);
          BEGIN
            l_WEIGHT_from := l_rec_loads.WEIGHT_FROM;
            l_field_name := 'TOTAL_WEIGHT';
            l_sequence := l_sequence +1 ;
            l_filter_type := l_rec_loads.WEIGHT_TYPE;
            l_multi_select:= 2;
            IF l_filter_type = 4 THEN
                l_WEIGHT_to := l_rec_loads.WEIGHT_TO;
            END IF;
            l_INSERT_WHAT := l_insert_what ||p_query_id||l_delim||''''||l_field_name||''''||l_delim||
                                             l_sequence ||l_delim||l_filter_type||l_delim||
                                             ''''||l_WEIGHT_from||''''||l_delim||
                                             l_null_str||l_delim||''''||l_WEIGHT_to||''''||l_delim||
                                             l_multi_select||l_delim||
                                             l_active_flag||l_delim;
            l_insert_who := l_userid||l_delim||'SYSDATE'||')';
            l_executed := execute_dyn_sql(l_insert_begin||l_insert_what||l_insert_who,NULL);
            IF l_executed = 0 THEN
                RAISE execution_failed;
            END IF;
          END;
        END IF; -- end WEIGHT_FROM IS NOT NULL
        -- ---------------------------------
        -- Criteria 9 - Cube
        -- ---------------------------------
        l_filter_type := NULL;
        l_multi_select := 2;
        l_insert_what := '(';
        l_executed := NULL;
        IF l_rec_loads.CUBE_FROM IS NOT NULL THEN
          DECLARE
            l_CUBE_from NUMBER;
            l_CUBE_to NUMBER;
            l_field_name VARCHAR2(30);
          BEGIN
            l_CUBE_from := l_rec_loads.CUBE_FROM;
            l_field_name := 'TOTAL_CUBE';
            l_sequence := l_sequence +1 ;
            l_filter_type := l_rec_loads.CUBE_TYPE;
            l_multi_select:= 2;
            IF l_filter_type = 4 THEN
                l_CUBE_to := l_rec_loads.CUBE_TO;
            END IF;
            l_INSERT_WHAT := l_insert_what ||p_query_id||l_delim||''''||l_field_name||''''||l_delim||
                                             l_sequence ||l_delim||l_filter_type||l_delim||
                                             ''''||l_CUBE_from||''''||l_delim||
                                             l_null_str||l_delim||''''||l_CUBE_to||''''||l_delim||
                                             l_multi_select||l_delim||
                                             l_active_flag||l_delim;
            l_insert_who := l_userid||l_delim||'SYSDATE'||')';
            l_executed := execute_dyn_sql(l_insert_begin||l_insert_what||l_insert_who,NULL);
            IF l_executed = 0 THEN
                RAISE execution_failed;
            END IF;
          END;
        END IF; -- end CUBE_FROM IS NOT NULL
        -- ---------------------------------
        -- Criteria 10 - Utilization
        -- ---------------------------------
        l_filter_type := NULL;
        l_multi_select := 2;
        l_insert_what := '(';
        l_executed := NULL;
        IF l_rec_loads.UTILIZATION_FROM IS NOT NULL THEN
          DECLARE
            l_UTILIZATION_from NUMBER;
            l_UTILIZATION_to NUMBER;
            l_field_name VARCHAR2(30);
          BEGIN
            l_UTILIZATION_from := l_rec_loads.UTILIZATION_FROM;
            l_field_name := 'TOTAL_UTILIZATION';
            l_sequence := l_sequence +1 ;
            l_filter_type := l_rec_loads.UTILIZATION_TYPE;
            l_multi_select:= 2;
            IF l_filter_type = 4 THEN
                l_UTILIZATION_to := l_rec_loads.UTILIZATION_TO;
            END IF;
            l_INSERT_WHAT := l_insert_what ||p_query_id||l_delim||''''||l_field_name||''''||l_delim||
                                             l_sequence ||l_delim||l_filter_type||l_delim||
                                             ''''||l_UTILIZATION_from||''''||l_delim||
                                             l_null_str||l_delim||''''||l_UTILIZATION_to||''''||l_delim||
                                             l_multi_select||l_delim||
                                             l_active_flag||l_delim;
            l_insert_who := l_userid||l_delim||'SYSDATE'||')';
            l_executed := execute_dyn_sql(l_insert_begin||l_insert_what||l_insert_who,NULL);
            IF l_executed = 0 THEN
                RAISE execution_failed;
            END IF;
          END;
        END IF; -- end UTILIZATION_FROM IS NOT NULL
        -- ---------------------------------
        -- Criteria 11 - Departure Time
        -- ---------------------------------
        l_filter_type := NULL;
        l_multi_select := 2;
        l_insert_what := '(';
        l_executed := NULL;
        IF l_rec_loads.DEPARTURE_TIME_FROM IS NOT NULL THEN
          DECLARE
            l_DEPARTURE_TIME_from NUMBER;
            l_DEPARTURE_TIME_to NUMBER;
            l_field_name VARCHAR2(30);
          BEGIN
            l_DEPARTURE_TIME_from := l_rec_loads.DEPARTURE_TIME_FROM;
            IF l_rec_loads.DEPARTURE_TIME_UNIT = 1 THEN
                l_field_name := 'DAYS_LEFT';
            ELSIF l_rec_loads.DEPARTURE_TIME_UNIT = 2 THEN
                l_field_name := 'HOURS_LEFT';
            END IF;
            l_sequence := l_sequence +1 ;
            l_filter_type := l_rec_loads.DEPARTURE_TIME_TYPE;
            l_multi_select:= 2;
            IF l_filter_type = 4 THEN
                l_DEPARTURE_TIME_to := l_rec_loads.DEPARTURE_TIME_TO;
            END IF;
            l_INSERT_WHAT := l_insert_what ||p_query_id||l_delim||''''||l_field_name||''''||l_delim||
                                             l_sequence ||l_delim||l_filter_type||l_delim||
                                             ''''||l_DEPARTURE_TIME_from||''''||l_delim||
                                             l_null_str||l_delim||''''||l_DEPARTURE_TIME_to||''''||l_delim||
                                             l_multi_select||l_delim||
                                             l_active_flag||l_delim;
            l_insert_who := l_userid||l_delim||'SYSDATE'||')';
            l_executed := execute_dyn_sql(l_insert_begin||l_insert_what||l_insert_who,NULL);
            IF l_executed = 0 THEN
                RAISE execution_failed;
            END IF;
          END;
        END IF; -- end DEPARTURE_TIME_FROM IS NOT NULL
    EXCEPTION
        WHEN no_data_found THEN
            --KSA_DEBUG(SYSDATE,'query_id->'||p_query_id||'-'||sqlerrm(sqlcode),'insert_load_selection');
            RAISE;
        WHEN OTHERS THEN
            --KSA_DEBUG(SYSDATE,'query_id->'||p_query_id||'-'||sqlerrm(sqlcode),'insert_load_selection');
            RAISE;
    END insert_load_selection;

    PROCEDURE insert_cm_selection(p_query_id IN NUMBER) IS

        cursor cur_cms is
        select ALL_CM,   CM_TRIP_NUMBERS    , USER_EDITS_ONLY    ,
               CARRIER_IDS        ,
               CARRIERS           , COST_TYPE          ,
               COST_FROM          , COST_TO            ,
               DEPARTURE_TIME_TYPE, DEPARTURE_TIME_FROM,
               DEPARTURE_TIME_TO  , DEPARTURE_TIME_UNIT
        from mst_cm_selection_criteria
        where query_id = p_query_id;

        l_rec_loads cur_cms%ROWTYPE;

        l_insert_begin VARCHAR2(500);
        l_insert_what  VARCHAR2(3000);
        l_insert_who   VARCHAR2(500);
        l_delete_str   VARCHAR2(500);
        l_executed NUMBER ;
        l_filter_type NUMBER;
        l_sequence NUMBER ; --:= 0;
        l_multi_select NUMBER ; --:= 2; -- 1 true, 2 false
        l_active_flag NUMBER ; --:= 1;
        l_delim CONSTANT VARCHAR2(1) := ',';
        l_separator CONSTANT VARCHAR2(1):= ';';
        l_null_str CONSTANT VARCHAR2(6) := 'NULL';
        l_userid NUMBER ; --:= TO_NUMBER(FND_PROFILE.VALUE('USER_ID'));
        execution_failed EXCEPTION;
    BEGIN
        l_sequence := 0;
        l_multi_select := 2; -- 1 true, 2 false
        l_active_flag := 1;
        l_userid := TO_NUMBER(FND_PROFILE.VALUE('USER_ID'));
        l_delete_str := 'DELETE MST_SELECTION_CRITERIA WHERE QUERY_ID = :P_QUERYID';
        l_executed := execute_dyn_sql(l_delete_str,p_query_id);
        IF l_executed = 0 THEN
            RAISE execution_failed;
        END IF;
        IF g_select_all IS NULL THEN
            FND_MESSAGE.set_name('MST','MST_PQ_ALL');
            g_select_all:= FND_MESSAGE.GET;
            --g_select_all := 'All';
        END IF;
        l_insert_begin := 'INSERT INTO MST_SELECTION_CRITERIA '||
                           '(QUERY_ID     , FIELD_NAME      , SEQUENCE     ,'||
                           'FILTER_TYPE   , FIELD_VALUE_FROM, DISPLAY_VALUE,'||
                           'FIELD_VALUE_TO, MULTI_SELECT    , ACTIVE_FLAG  ,'||
                           'CREATED_BY    , CREATION_DATE   ) VALUES ';
        OPEN cur_cms;
        FETCH cur_cms INTO l_rec_loads;
        IF cur_cms%NOTFOUND THEN
            CLOSE cur_cms;
            RAISE no_data_found;
        END IF;
        CLOSE cur_cms;
        l_insert_what := '(';
        l_executed := NULL;
        -- ---------------------------------
        -- Criteria 1 CM_TRIP_NUMBERS
        -- ---------------------------------
        IF l_rec_loads.CM_TRIP_NUMBERS IS NOT NULL  THEN
          DECLARE
            l_cm_trip_numbers VARCHAR2(2000);
          BEGIN
            l_cm_trip_numbers := l_rec_loads.CM_TRIP_NUMBERS;

            IF instrb(l_cm_trip_numbers,l_separator) > 0
            AND  instrb(l_cm_trip_numbers,l_separator,-1)<>lengthb(l_cm_trip_numbers) THEN
              l_cm_trip_numbers := l_cm_trip_numbers||l_separator;
            END IF;
            l_sequence := l_sequence +1 ;
            IF instrb(l_cm_trip_numbers,l_separator) > 0 THEN
                l_filter_type := 3;
                l_multi_select:= 1;
            ELSE
                l_filter_type := 1;
            END IF;
            l_INSERT_WHAT := l_insert_what ||p_query_id||l_delim||'''CM_TRIP_NUMBER'''||l_delim||
                                             l_sequence ||l_delim||l_filter_type||l_delim||
                                             ''''||l_cm_trip_numbers||''''||l_delim||
                                             l_null_str||l_delim||l_null_str||l_delim||l_multi_select||l_delim||
                                             l_active_flag||l_delim;
            l_insert_who := l_userid||l_delim||'SYSDATE'||')';
            l_executed := execute_dyn_sql(l_insert_begin||l_insert_what||l_insert_who,NULL);
            IF l_executed = 0 THEN
                RAISE execution_failed;
            END IF;
          END;
        END IF; -- end CM_TRIP_NUMBERS

        -- ---------------------------------
        -- Criteria 1a ALL_CM
        -- ---------------------------------
        l_filter_type := NULL;
        l_multi_select := 2;
        l_insert_what := '(';
        l_executed := NULL;

	IF l_rec_loads.ALL_CM IS NOT NULL  THEN
          DECLARE
            l_cm_trip_numbers VARCHAR2(2000):= '0';
          BEGIN
            l_sequence := l_sequence +1 ;
            l_filter_type := 7;
            l_INSERT_WHAT := l_insert_what ||p_query_id||l_delim||'''CM_TRIP_NUMBER'''||l_delim||
                                             l_sequence ||l_delim||l_filter_type||l_delim||
                                             ''''||l_cm_trip_numbers||''''||l_delim||
                                             l_null_str||l_delim||l_null_str||l_delim||l_multi_select||l_delim||
                                             l_active_flag||l_delim;
            l_insert_who := l_userid||l_delim||'SYSDATE'||')';
            l_executed := execute_dyn_sql(l_insert_begin||l_insert_what||l_insert_who,NULL);
            IF l_executed = 0 THEN
                RAISE execution_failed;
            END IF;
          END;
        END IF; -- end All_CM

        -- ---------------------------------
        -- Criteria 1-B - USER EDITS
        -- ---------------------------------
        l_filter_type := NULL;
        l_multi_select := 2;
        l_insert_what := '(';
        l_executed := NULL;
        IF l_rec_loads.USER_EDITS_ONLY = 1 THEN
            DECLARE
              l_user_edits NUMBER;
              l_field_name VARCHAR2(30);
            BEGIN
              l_field_name := 'CHANGED_BY_USER';
              l_user_edits := 1;
              l_sequence := l_sequence +1 ;
              l_filter_type := 1;
              l_INSERT_WHAT := l_insert_what ||p_query_id||l_delim||''''||l_field_name||''''||l_delim||
                                               l_sequence ||l_delim||l_filter_type||l_delim||
                                               ''''||l_user_edits||''''||l_delim||
                                               l_null_str||l_delim||l_null_str||l_delim||l_multi_select||l_delim||
                                               l_active_flag||l_delim;
              l_insert_who := l_userid||l_delim||'SYSDATE'||')';
              --KSA_DEBUG(SYSDATE,L_INSERT_WHO,'INSERT LOAD - WHO');
              l_executed := execute_dyn_sql(l_insert_begin||l_insert_what||l_insert_who,NULL);
              IF l_executed = 0 THEN
                RAISE execution_failed;
              END IF;
            END;
        END IF;
        -- ---------------------------------
        -- Criteria 2 Carriers
        -- ---------------------------------
        l_filter_type := NULL;
        l_multi_select := 2;
        l_insert_what := '(';
        l_executed := NULL;
        IF l_rec_loads.Carriers <> g_select_all THEN
          DECLARE
            l_Carriers VARCHAR2(2000);
            l_field_name VARCHAR2(30);
          BEGIN
            l_Carriers := l_rec_loads.Carrier_ids;
            l_field_name := 'CARRIER_ID';
            l_sequence := l_sequence +1 ;
            IF instrb(l_Carriers,l_separator) > 0 THEN
                l_filter_type := 3;
                l_multi_select:= 1;
            ELSE
                l_filter_type := 1;
            END IF;
            l_INSERT_WHAT := l_insert_what ||p_query_id||l_delim||''''||l_field_name||''''||l_delim||
                                             l_sequence ||l_delim||l_filter_type||l_delim||
                                             ''''||l_Carriers||''''||l_delim||
                                             l_null_str||l_delim||l_null_str||l_delim||l_multi_select||l_delim||
                                             l_active_flag||l_delim;
            l_insert_who := l_userid||l_delim||'SYSDATE'||')';
            l_executed := execute_dyn_sql(l_insert_begin||l_insert_what||l_insert_who,NULL);
            IF l_executed = 0 THEN
                RAISE execution_failed;
            END IF;
          END;
        END IF; -- end Carriers <> g_select_all
        -- ---------------------------------
        -- Criteria 3 - Cost
        -- ---------------------------------
        l_filter_type := NULL;
        l_multi_select := 2;
        l_insert_what := '(';
        l_executed := NULL;
        IF l_rec_loads.COST_FROM IS NOT NULL THEN
          DECLARE
            l_cost_from NUMBER;
            l_cost_to NUMBER;
            l_field_name VARCHAR2(30);
          BEGIN
            l_cost_from := l_rec_loads.COST_FROM;
            l_field_name := 'TOTAL_COST';
            l_sequence := l_sequence +1 ;
            l_filter_type := l_rec_loads.COST_TYPE;
            l_multi_select:= 2;
            IF l_filter_type = 4 THEN
                l_cost_to := l_rec_loads.COST_TO;
            END IF;
            l_INSERT_WHAT := l_insert_what ||p_query_id||l_delim||''''||l_field_name||''''||l_delim||
                                             l_sequence ||l_delim||l_filter_type||l_delim||
                                             ''''||l_cost_from||''''||l_delim||
                                             l_null_str||l_delim||''''||l_cost_to||''''||l_delim||
                                             l_multi_select||l_delim||
                                             l_active_flag||l_delim;
            l_insert_who := l_userid||l_delim||'SYSDATE'||')';
            l_executed := execute_dyn_sql(l_insert_begin||l_insert_what||l_insert_who,NULL);
            IF l_executed = 0 THEN
                RAISE execution_failed;
            END IF;
          END;
        END IF; -- end COST_FROM IS NOT NULL
        -- ---------------------------------
        -- Criteria 4 - Departure Time
        -- ---------------------------------
        l_filter_type := NULL;
        l_multi_select := 2;
        l_insert_what := '(';
        l_executed := NULL;
        IF l_rec_loads.DEPARTURE_TIME_FROM IS NOT NULL THEN
          DECLARE
            l_DEPARTURE_TIME_from NUMBER;
            l_DEPARTURE_TIME_to NUMBER;
            l_field_name VARCHAR2(30);
          BEGIN
            l_DEPARTURE_TIME_from := l_rec_loads.DEPARTURE_TIME_FROM;
            IF l_rec_loads.DEPARTURE_TIME_UNIT = 1 THEN
                l_field_name := 'DAYS_LEFT';
            ELSIF l_rec_loads.DEPARTURE_TIME_UNIT = 2 THEN
                l_field_name := 'HOURS_LEFT';
            END IF;
            l_sequence := l_sequence +1 ;
            l_filter_type := l_rec_loads.DEPARTURE_TIME_TYPE;
            l_multi_select:= 2;
            IF l_filter_type = 4 THEN
                l_DEPARTURE_TIME_to := l_rec_loads.DEPARTURE_TIME_TO;
            END IF;
            l_INSERT_WHAT := l_insert_what ||p_query_id||l_delim||''''||l_field_name||''''||l_delim||
                                             l_sequence ||l_delim||l_filter_type||l_delim||
                                             ''''||l_DEPARTURE_TIME_from||''''||l_delim||
                                             l_null_str||l_delim||''''||l_DEPARTURE_TIME_to||''''||l_delim||
                                             l_multi_select||l_delim||
                                             l_active_flag||l_delim;
            l_insert_who := l_userid||l_delim||'SYSDATE'||')';
            l_executed := execute_dyn_sql(l_insert_begin||l_insert_what||l_insert_who,NULL);
            IF l_executed = 0 THEN
                RAISE execution_failed;
            END IF;
          END;
        END IF; -- end DEPARTURE_TIME_FROM IS NOT NULL
    EXCEPTION
        WHEN OTHERS THEN
            RAISE;
    END insert_cm_selection;

    PROCEDURE insert_order_selection(p_query_id IN NUMBER) IS
        CURSOR cur_orders IS
        SELECT ALL_SALES_ORDERS   , SALES_ORDER_NUMBERS,
               ALL_PURCHASE_ORDERS, PURCHASE_ORDER_NUMBERS,
               ALL_OTHER_ORDERS   , OTHER_ORDER_NUMBERS,
               RANGE_TYPE         ,
               ORIGIN_FACILITIES  , DESTINATION_FACILITIES,
               ORIGIN_FACILITY_IDS, DESTINATION_FACILITY_IDS,
               ORIGIN_ZIP         , DESTINATION_ZIP       ,
               ORIGIN_CITY        , DESTINATION_CITY      ,
               ORIGIN_STATE       , DESTINATION_STATE     ,
               ORIGIN_COUNTRY     , DESTINATION_COUNTRY   ,
               ITEMS              , INVENTORY_ITEM_IDS    ,
               CUSTOMERS          , CUSTOMER_IDS          ,
               SUPPLIERS          , SUPPLIER_IDS          ,
               WEIGHT_TYPE        , WEIGHT_FROM           , WEIGHT_TO             ,
               CUBE_TYPE          , CUBE_FROM             , CUBE_TO
        FROM mst_order_selection_criteria
        WHERE query_id = p_query_id;

        l_rec_orders cur_orders%ROWTYPE;

        l_insert_begin VARCHAR2(500);
        l_insert_what  VARCHAR2(3000);
        l_insert_who   VARCHAR2(500);
        l_delete_str   VARCHAR2(500);
        l_executed NUMBER ;
        l_filter_type NUMBER;
        l_sequence NUMBER ;--:= 0;
        l_multi_select NUMBER ; --:= 2; -- 1 true, 2 false
        l_active_flag NUMBER ; --:= 1;
        l_delim CONSTANT VARCHAR2(1) := ',';
        l_separator CONSTANT VARCHAR2(1):= ';';
        l_null_str CONSTANT VARCHAR2(6) := 'NULL';
        l_userid NUMBER ; --:= TO_NUMBER(FND_PROFILE.VALUE('USER_ID'));
        execution_failed EXCEPTION;
    BEGIN
        l_sequence := 0;
        l_multi_select  := 2; -- 1 true, 2 false
        l_active_flag := 1;
        l_userid := TO_NUMBER(FND_PROFILE.VALUE('USER_ID'));
        l_delete_str := 'DELETE MST_SELECTION_CRITERIA WHERE QUERY_ID = :P_QUERYID';
        l_executed := execute_dyn_sql(l_delete_str,p_query_id);
        IF l_executed = 0 THEN
            RAISE execution_failed;
        END IF;
        IF g_select_all IS NULL THEN
            FND_MESSAGE.set_name('MST','MST_PQ_ALL');
            g_select_all:= FND_MESSAGE.GET;
            --g_select_all := 'All';
        END IF;
        l_insert_begin := 'INSERT INTO MST_SELECTION_CRITERIA '||
                           '(QUERY_ID     , FIELD_NAME      , SEQUENCE     ,'||
                           'FILTER_TYPE   , FIELD_VALUE_FROM, DISPLAY_VALUE,'||
                           'FIELD_VALUE_TO, MULTI_SELECT    , ACTIVE_FLAG  ,'||
                           'CREATED_BY    , CREATION_DATE   ) VALUES ';
        OPEN cur_orders;
        FETCH cur_orders INTO l_rec_orders;
        IF cur_orders%NOTFOUND THEN
            CLOSE cur_orders;
            RAISE no_data_found;
        END IF;
        CLOSE cur_orders;
        l_filter_type := NULL;
        l_multi_select := 2;
        l_insert_what := '(';
        l_executed := NULL;
        -- ---------------------------------
        -- Criteria 1- mode of Transport
        -- ---------------------------------
        IF l_rec_orders.ALL_SALES_ORDERS = 1
        OR l_rec_orders.ALL_PURCHASE_ORDERS = 1
        OR l_rec_orders.ALL_OTHER_ORDERS = 1 THEN
            DECLARE
              l_orders VARCHAR2(50);
            BEGIN
              IF l_rec_orders.ALL_SALES_ORDERS = 1 THEN
                --l_orders := 'SO';
                l_orders := 'OE';
              END IF;
              IF l_rec_orders.ALL_PURCHASE_ORDERS =1 THEN
                IF l_orders IS NOT NULL THEN
                  l_orders := l_orders||l_separator||'PO';
                ELSE
                    l_orders := 'PO';
                END IF;
              END IF;
              IF l_rec_orders.ALL_OTHER_ORDERS =1 THEN
                IF l_orders IS NOT NULL THEN
                  l_orders := l_orders||l_separator||'XXXXX';
                ELSE
                    l_orders := 'XXXXX';
                END IF;
              END IF;
              l_sequence := l_sequence +1 ;
              IF instrb(l_orders,l_separator) > 0 THEN
                l_filter_type := 3;
                l_multi_select:= 1;
              ELSE
                l_filter_type := 1;
              END IF;
              --l_INSERT_WHAT := l_insert_what ||p_query_id||l_delim||'''REFERENCE_SOURCE_TYPE'''||l_delim||
              l_INSERT_WHAT := l_insert_what ||p_query_id||l_delim||'''SOURCE_CODE'''||l_delim||
                                               l_sequence ||l_delim||l_filter_type||l_delim||
                                               ''''||l_orders||''''||l_delim||
                                               l_null_str||l_delim||l_null_str||l_delim||l_multi_select||l_delim||
                                               l_active_flag||l_delim;
              l_insert_who := l_userid||l_delim||'SYSDATE'||')';
              --KSA_DEBUG(SYSDATE,L_INSERT_WHO,'INSERT LOAD - WHO');
              l_executed := execute_dyn_sql(l_insert_begin||l_insert_what||l_insert_who,NULL);
              IF l_executed = 0 THEN
                RAISE execution_failed;
              END IF;
            END;
        END IF;
        -- ---------------------------------
        -- Criteria 1 - Order Numbers
        -- ---------------------------------
        l_filter_type := NULL;
        l_multi_select := 2;
        l_insert_what := '(';
        l_executed := NULL;
        IF l_rec_orders.SALES_ORDER_NUMBERS IS NOT NULL
        OR l_rec_orders.PURCHASE_ORDER_NUMBERS IS NOT NULL
        OR l_rec_orders.OTHER_ORDER_NUMBERS IS NOT NULL THEN
          DECLARE
            l_order_numbers VARCHAR2(2000);
          BEGIN
            IF NVL(l_rec_orders.ALL_SALES_ORDERS,2) = 2
            AND l_rec_orders.SALES_ORDER_NUMBERS IS NOT NULL THEN
                l_order_numbers := l_rec_orders.SALES_ORDER_NUMBERS;
            END IF;

            IF NVL(l_rec_orders.ALL_PURCHASE_ORDERS,2) = 2
            AND l_rec_orders.PURCHASE_ORDER_NUMBERS IS NOT NULL THEN
              IF l_order_numbers IS NOT NULL THEN
                IF instrb(l_order_numbers,l_separator,-1)<>lengthb(l_order_numbers) THEN
                  l_order_numbers := l_order_numbers||l_separator||l_rec_orders.PURCHASE_ORDER_NUMBERS;
                ELSE
                  l_order_numbers := l_order_numbers||l_rec_orders.PURCHASE_ORDER_NUMBERS;
                END IF;
              ELSE
                l_order_numbers := l_rec_orders.PURCHASE_ORDER_NUMBERS;
              END IF;
            END IF;
            IF NVL(l_rec_orders.ALL_OTHER_ORDERS,2) = 2
            AND l_rec_orders.OTHER_ORDER_NUMBERS IS NOT NULL THEN
              IF l_order_numbers IS NOT NULL THEN
                IF instrb(l_order_numbers,l_separator,-1)<>lengthb(l_order_numbers) THEN
                  l_order_numbers := l_order_numbers||l_separator||l_rec_orders.OTHER_ORDER_NUMBERS;
                ELSE
                  l_order_numbers := l_order_numbers||l_rec_orders.OTHER_ORDER_NUMBERS;
                END IF;
              ELSE
                l_order_numbers := l_rec_orders.OTHER_ORDER_NUMBERS;
              END IF;
            END IF;
            IF instrb(l_order_numbers,l_separator) > 0
            AND  instrb(l_order_numbers,l_separator,-1)<>lengthb(l_order_numbers) THEN
              l_order_numbers := l_order_numbers||l_separator;
            END IF;
            l_sequence := l_sequence +1 ;
            IF instrb(l_order_numbers,l_separator) > 0 THEN
                l_filter_type := 3;
                l_multi_select:= 1;
            ELSE
                l_filter_type := 1;
            END IF;
            l_INSERT_WHAT := l_insert_what ||p_query_id||l_delim||'''ORDER_NUMBER'''||l_delim||
                                             l_sequence ||l_delim||l_filter_type||l_delim||
                                             ''''||l_order_numbers||''''||l_delim||
                                             l_null_str||l_delim||l_null_str||l_delim||l_multi_select||l_delim||
                                             l_active_flag||l_delim;
            l_insert_who := l_userid||l_delim||'SYSDATE'||')';
            l_executed := execute_dyn_sql(l_insert_begin||l_insert_what||l_insert_who,NULL);
            IF l_executed = 0 THEN
                RAISE execution_failed;
            END IF;
          END;
        END IF;
        -- -------------------
        -- Criteria 2 - Range.
        -- -------------------
        l_filter_type := NULL;
        l_multi_select := 2;
        l_insert_what := '(';
        l_executed := NULL;
        IF l_rec_orders.RANGE_TYPE IN (1,2) THEN
            -- -----------------------------------
            -- Criteria 2 - Range -(1,2)- Facility
            -- -----------------------------------
            IF l_rec_orders.ORIGIN_FACILITIES <> g_select_all THEN
              DECLARE
                l_facilities VARCHAR2(2000);
                l_field_name VARCHAR2(30);
              BEGIN
                l_facilities := l_rec_orders.ORIGIN_FACILITY_IDS;

                IF l_rec_orders.RANGE_TYPE = 1 THEN
                    l_field_name := 'ORIGIN_FACILITY_ID';
                ELSIF l_rec_orders.RANGE_TYPE = 2 THEN
                    l_field_name := 'DESTINATION_FACILITY_ID';
                END IF;
                l_sequence := l_sequence +1 ;
                IF instrb(l_facilities,l_separator) > 0 THEN
                    l_filter_type := 3;
                    l_multi_select:= 1;
                ELSE
                    l_filter_type := 1;
                END IF;
                l_INSERT_WHAT := l_insert_what ||p_query_id||l_delim||''''||l_field_name||''''||l_delim||
                                                 l_sequence ||l_delim||l_filter_type||l_delim||
                                                 ''''||l_facilities||''''||l_delim||
                                                 l_null_str||l_delim||l_null_str||l_delim||l_multi_select||l_delim||
                                                 l_active_flag||l_delim;
                --KSA_DEBUG(SYSDATE,L_INSERT_WHAT,'INSERT LOAD - WHAT');
                l_insert_who := l_userid||l_delim||'SYSDATE'||')';
                l_executed := execute_dyn_sql(l_insert_begin||l_insert_what||l_insert_who,NULL);
              END;
            END IF; -- end ORIGIN_FACILITIES <> g_select_all
            -- -----------------------------------
            -- Criteria 2 - Range -(1,2)- Zip
            -- -----------------------------------
            l_filter_type := NULL;
            l_multi_select := 2;
            l_insert_what := '(';
            l_executed := NULL;
            IF l_rec_orders.ORIGIN_ZIP <> g_select_all THEN
              DECLARE
                l_postalcodes VARCHAR2(2000);
                l_field_name VARCHAR2(30);
              BEGIN
                l_postalcodes := l_rec_orders.ORIGIN_ZIP;

                IF l_rec_orders.RANGE_TYPE = 1 THEN
                    l_field_name := 'ORIGIN_ZIP';
                ELSIF l_rec_orders.RANGE_TYPE = 2 THEN
                    l_field_name := 'DESTINATION_ZIP';
                END IF;
                l_sequence := l_sequence +1 ;
                IF instrb(l_postalcodes,l_separator) > 0 THEN
                    l_filter_type := 3;
                    l_multi_select:= 1;
                ELSE
                    l_filter_type := 1;
                END IF;
                l_INSERT_WHAT := l_insert_what ||p_query_id||l_delim||''''||l_field_name||''''||l_delim||
                                                 l_sequence ||l_delim||l_filter_type||l_delim||
                                                 ''''||l_postalcodes||''''||l_delim||
                                                 l_null_str||l_delim||l_null_str||l_delim||l_multi_select||l_delim||
                                                 l_active_flag||l_delim;
                l_insert_who := l_userid||l_delim||'SYSDATE'||')';
                l_executed := execute_dyn_sql(l_insert_begin||l_insert_what||l_insert_who,NULL);
              END;
            END IF; -- end ORIGIN_ZIP <> g_select_all
            -- -----------------------------------
            -- Criteria 2 - Range -(1,2)- City
            -- -----------------------------------
            l_filter_type := NULL;
            l_multi_select := 2;
            l_insert_what := '(';
            l_executed := NULL;
            IF l_rec_orders.ORIGIN_CITY <> g_select_all THEN
              DECLARE
                l_cities      VARCHAR2(2000);
                l_field_name VARCHAR2(30);
              BEGIN
                l_cities := l_rec_orders.ORIGIN_CITY;

                IF l_rec_orders.RANGE_TYPE = 1 THEN
                    l_field_name := 'ORIGIN_CITY';
                ELSIF l_rec_orders.RANGE_TYPE = 2 THEN
                    l_field_name := 'DESTINATION_CITY';
                END IF;
                l_sequence := l_sequence +1 ;
                IF instrb(l_cities,l_separator) > 0 THEN
                    l_filter_type := 3;
                    l_multi_select:= 1;
                ELSE
                    l_filter_type := 1;
                END IF;
                l_INSERT_WHAT := l_insert_what ||p_query_id||l_delim||''''||l_field_name||''''||l_delim||
                                                 l_sequence ||l_delim||l_filter_type||l_delim||
                                                 ''''||l_cities||''''||l_delim||
                                                 l_null_str||l_delim||l_null_str||l_delim||l_multi_select||l_delim||
                                                 l_active_flag||l_delim;
                l_insert_who := l_userid||l_delim||'SYSDATE'||')';
                l_executed := execute_dyn_sql(l_insert_begin||l_insert_what||l_insert_who,NULL);
              END;
            END IF; -- end ORIGIN_CITY <> g_select_all
            -- -----------------------------------
            -- Criteria 2 - Range -(1,2)- State
            -- -----------------------------------
            l_filter_type := NULL;
            l_multi_select := 2;
            l_insert_what := '(';
            l_executed := NULL;
            IF l_rec_orders.ORIGIN_STATE <> g_select_all THEN
              DECLARE
                l_states      VARCHAR2(2000);
                l_field_name VARCHAR2(30);
              BEGIN
                l_states := l_rec_orders.ORIGIN_STATE;

                IF l_rec_orders.RANGE_TYPE = 1 THEN
                    l_field_name := 'ORIGIN_STATE';
                ELSIF l_rec_orders.RANGE_TYPE = 2 THEN
                    l_field_name := 'DESTINATION_STATE';
                END IF;
                l_sequence := l_sequence +1 ;
                IF instrb(l_states,l_separator) > 0 THEN
                    l_filter_type := 3;
                    l_multi_select:= 1;
                ELSE
                    l_filter_type := 1;
                END IF;
                l_INSERT_WHAT := l_insert_what ||p_query_id||l_delim||''''||l_field_name||''''||l_delim||
                                                 l_sequence ||l_delim||l_filter_type||l_delim||
                                                 ''''||l_states||''''||l_delim||
                                                 l_null_str||l_delim||l_null_str||l_delim||l_multi_select||l_delim||
                                                 l_active_flag||l_delim;
                l_insert_who := l_userid||l_delim||'SYSDATE'||')';
                l_executed := execute_dyn_sql(l_insert_begin||l_insert_what||l_insert_who,NULL);
              END;
            END IF; -- end ORIGIN_STATE <> g_select_all
            -- -----------------------------------
            -- Criteria 2 - Range -(1,2)- Country
            -- -----------------------------------
            l_filter_type := NULL;
            l_multi_select := 2;
            l_insert_what := '(';
            l_executed := NULL;
            IF l_rec_orders.ORIGIN_COUNTRY <> g_select_all THEN
              DECLARE
                l_countries      VARCHAR2(2000);
                l_field_name VARCHAR2(30);
              BEGIN
                l_countries := l_rec_orders.ORIGIN_COUNTRY;

                IF l_rec_orders.RANGE_TYPE = 1 THEN
                    l_field_name := 'ORIGIN_COUNTRY';
                ELSIF l_rec_orders.RANGE_TYPE = 2 THEN
                    l_field_name := 'DESTINATION_COUNTRY';
                END IF;
                l_sequence := l_sequence +1 ;
                IF instrb(l_countries,l_separator) > 0 THEN
                    l_filter_type := 3;
                    l_multi_select:= 1;
                ELSE
                    l_filter_type := 1;
                END IF;
                l_INSERT_WHAT := l_insert_what ||p_query_id||l_delim||''''||l_field_name||''''||l_delim||
                                                 l_sequence ||l_delim||l_filter_type||l_delim||
                                                 ''''||l_countries||''''||l_delim||
                                                 l_null_str||l_delim||l_null_str||l_delim||l_multi_select||l_delim||
                                                 l_active_flag||l_delim;
                l_insert_who := l_userid||l_delim||'SYSDATE'||')';
                l_executed := execute_dyn_sql(l_insert_begin||l_insert_what||l_insert_who,NULL);
              END;
            END IF; -- end ORIGIN_COUNTRY <> g_select_all
        ELSIF l_rec_orders.RANGE_TYPE = 3 THEN
            -- ---------------------------------
            -- Criteria 2 - Range -(3)- Facility
            -- ---------------------------------
            IF l_rec_orders.ORIGIN_FACILITIES <> g_select_all THEN
              DECLARE
                l_facilities VARCHAR2(2000);
                l_field_name VARCHAR2(30);
              BEGIN
                l_facilities := l_rec_orders.ORIGIN_FACILITY_IDS;
                l_field_name := 'ORIGIN_FACILITY_ID';
                l_sequence := l_sequence +1 ;
                IF instrb(l_facilities,l_separator) > 0 THEN
                    --l_filter_type := 3;
                    l_multi_select:= 1;
                ELSE
                    --l_filter_type := 1;
                    l_multi_select:= 2;
                END IF;
                l_filter_type := 10;
                l_INSERT_WHAT := l_insert_what ||p_query_id||l_delim||''''||l_field_name||''''||l_delim||
                                                 l_sequence ||l_delim||l_filter_type||l_delim||
                                                 ''''||l_facilities||''''||l_delim||
                                                 l_null_str||l_delim||l_null_str||l_delim||l_multi_select||l_delim||
                                                 l_active_flag||l_delim;
                l_insert_who := l_userid||l_delim||'SYSDATE'||')';
                l_executed := execute_dyn_sql(l_insert_begin||l_insert_what||l_insert_who,NULL);

                l_filter_type := NULL;
                l_multi_select := 2;
                l_insert_what := '(';
                l_executed := NULL;
                l_field_name := 'DESTINATION_FACILITY_ID';
                l_sequence := l_sequence +1 ;
                IF instrb(l_facilities,l_separator) > 0 THEN
                    --l_filter_type := 3;
                    l_multi_select:= 1;
                ELSE
                    --l_filter_type := 1;
                    l_multi_select:= 2;
                END IF;
                l_filter_type := 10;
                l_INSERT_WHAT := l_insert_what ||p_query_id||l_delim||''''||l_field_name||''''||l_delim||
                                                 l_sequence ||l_delim||l_filter_type||l_delim||
                                                 ''''||l_facilities||''''||l_delim||
                                                 l_null_str||l_delim||l_null_str||l_delim||l_multi_select||l_delim||
                                                 l_active_flag||l_delim;
                l_insert_who := l_userid||l_delim||'SYSDATE'||')';
                l_executed := execute_dyn_sql(l_insert_begin||l_insert_what||l_insert_who,NULL);
              END;
            END IF; -- end ORIGIN_FACILITIES <> g_select_all
            -- ---------------------------------
            -- Criteria 2 - Range -(3)- Zip
            -- ---------------------------------
            l_filter_type := NULL;
            l_multi_select := 2;
            l_insert_what := '(';
            l_executed := NULL;
            IF l_rec_orders.ORIGIN_ZIP <> g_select_all THEN
              DECLARE
                l_postalcodes VARCHAR2(2000);
                l_field_name VARCHAR2(30);
              BEGIN
                l_postalcodes := l_rec_orders.ORIGIN_ZIP;
                l_field_name := 'ORIGIN_ZIP';
                l_sequence := l_sequence +1 ;
                IF instrb(l_postalcodes,l_separator) > 0 THEN
                    --l_filter_type := 3;
                    l_multi_select:= 1;
                ELSE
                    --l_filter_type := 1;
                    l_multi_select:= 2;
                END IF;
                l_filter_type := 10;
                l_INSERT_WHAT := l_insert_what ||p_query_id||l_delim||''''||l_field_name||''''||l_delim||
                                                 l_sequence ||l_delim||l_filter_type||l_delim||
                                                 ''''||l_postalcodes||''''||l_delim||
                                                 l_null_str||l_delim||l_null_str||l_delim||l_multi_select||l_delim||
                                                 l_active_flag||l_delim;
                l_insert_who := l_userid||l_delim||'SYSDATE'||')';
                l_executed := execute_dyn_sql(l_insert_begin||l_insert_what||l_insert_who,NULL);

                l_filter_type := NULL;
                l_multi_select := 2;
                l_insert_what := '(';
                l_executed := NULL;
                l_field_name := 'DESTINATION_ZIP';
                l_sequence := l_sequence +1 ;
                IF instrb(l_postalcodes,l_separator) > 0 THEN
                    --l_filter_type := 3;
                    l_multi_select:= 1;
                ELSE
                    --l_filter_type := 1;
                    l_multi_select:= 2;
                END IF;
                l_filter_type := 10;
                l_INSERT_WHAT := l_insert_what ||p_query_id||l_delim||''''||l_field_name||''''||l_delim||
                                                 l_sequence ||l_delim||l_filter_type||l_delim||
                                                 ''''||l_postalcodes||''''||l_delim||
                                                 l_null_str||l_delim||l_null_str||l_delim||l_multi_select||l_delim||
                                                 l_active_flag||l_delim;
                l_insert_who := l_userid||l_delim||'SYSDATE'||')';
                l_executed := execute_dyn_sql(l_insert_begin||l_insert_what||l_insert_who,NULL);
              END;
            END IF; -- end ORIGIN_ZIP <> g_select_all
            -- ---------------------------------
            -- Criteria 2 - Range -(3)- City
            -- ---------------------------------
            l_filter_type := NULL;
            l_multi_select := 2;
            l_insert_what := '(';
            l_executed := NULL;
            IF l_rec_orders.ORIGIN_CITY <> g_select_all THEN
              DECLARE
                l_cities VARCHAR2(2000);
                l_field_name VARCHAR2(30);
              BEGIN
                l_cities := l_rec_orders.ORIGIN_CITY;
                l_field_name := 'ORIGIN_CITY';
                l_sequence := l_sequence +1 ;
                IF instrb(l_cities,l_separator) > 0 THEN
                    --l_filter_type := 3;
                    l_multi_select:= 1;
                ELSE
                    --l_filter_type := 1;
                    l_multi_select:= 2;
                END IF;
                l_filter_type := 10;
                l_INSERT_WHAT := l_insert_what ||p_query_id||l_delim||''''||l_field_name||''''||l_delim||
                                                 l_sequence ||l_delim||l_filter_type||l_delim||
                                                 ''''||l_cities||''''||l_delim||
                                                 l_null_str||l_delim||l_null_str||l_delim||l_multi_select||l_delim||
                                                 l_active_flag||l_delim;
                l_insert_who := l_userid||l_delim||'SYSDATE'||')';
                l_executed := execute_dyn_sql(l_insert_begin||l_insert_what||l_insert_who,NULL);

                l_filter_type := NULL;
                l_multi_select := 2;
                l_insert_what := '(';
                l_executed := NULL;
                l_field_name := 'DESTINATION_CITY';
                l_sequence := l_sequence +1 ;
                IF instrb(l_cities,l_separator) > 0 THEN
                    --l_filter_type := 3;
                    l_multi_select:= 1;
                ELSE
                    --l_filter_type := 1;
                    l_multi_select:= 2;
                END IF;
                l_filter_type := 10;
                l_INSERT_WHAT := l_insert_what ||p_query_id||l_delim||''''||l_field_name||''''||l_delim||
                                                 l_sequence ||l_delim||l_filter_type||l_delim||
                                                 ''''||l_cities||''''||l_delim||
                                                 l_null_str||l_delim||l_null_str||l_delim||l_multi_select||l_delim||
                                                 l_active_flag||l_delim;
                l_insert_who := l_userid||l_delim||'SYSDATE'||')';
                l_executed := execute_dyn_sql(l_insert_begin||l_insert_what||l_insert_who,NULL);
              END;
            END IF; -- end ORIGIN_CITY <> g_select_all
            -- ---------------------------------
            -- Criteria 2 - Range -(3)- State
            -- ---------------------------------
            l_filter_type := NULL;
            l_multi_select := 2;
            l_insert_what := '(';
            l_executed := NULL;
            IF l_rec_orders.ORIGIN_STATE <> g_select_all THEN
              DECLARE
                l_states VARCHAR2(2000);
                l_field_name VARCHAR2(30);
              BEGIN
                l_states := l_rec_orders.ORIGIN_STATE;
                l_field_name := 'ORIGIN_STATE';
                l_sequence := l_sequence +1 ;
                IF instrb(l_states,l_separator) > 0 THEN
                    --l_filter_type := 3;
                    l_multi_select:= 1;
                ELSE
                    --l_filter_type := 1;
                    l_multi_select:= 2;
                END IF;
                l_filter_type := 10;
                l_INSERT_WHAT := l_insert_what ||p_query_id||l_delim||''''||l_field_name||''''||l_delim||
                                                 l_sequence ||l_delim||l_filter_type||l_delim||
                                                 ''''||l_states||''''||l_delim||
                                                 l_null_str||l_delim||l_null_str||l_delim||l_multi_select||l_delim||
                                                 l_active_flag||l_delim;
                l_insert_who := l_userid||l_delim||'SYSDATE'||')';
                l_executed := execute_dyn_sql(l_insert_begin||l_insert_what||l_insert_who,NULL);

                l_filter_type := NULL;
                l_multi_select := 2;
                l_insert_what := '(';
                l_executed := NULL;
                l_field_name := 'DESTINATION_STATE';
                l_sequence := l_sequence +1 ;
                IF instrb(l_states,l_separator) > 0 THEN
                    --l_filter_type := 3;
                    l_multi_select:= 1;
                ELSE
                    --l_filter_type := 1;
                    l_multi_select:= 2;
                END IF;
                l_filter_type := 10;
                l_INSERT_WHAT := l_insert_what ||p_query_id||l_delim||''''||l_field_name||''''||l_delim||
                                                 l_sequence ||l_delim||l_filter_type||l_delim||
                                                 ''''||l_states||''''||l_delim||
                                                 l_null_str||l_delim||l_null_str||l_delim||l_multi_select||l_delim||
                                                 l_active_flag||l_delim;
                l_insert_who := l_userid||l_delim||'SYSDATE'||')';
                l_executed := execute_dyn_sql(l_insert_begin||l_insert_what||l_insert_who,NULL);
              END;
            END IF; -- end ORIGIN_STATE <> g_select_all
            -- ---------------------------------
            -- Criteria 2 - Range -(3)- Country
            -- ---------------------------------
            l_filter_type := NULL;
            l_multi_select := 2;
            l_insert_what := '(';
            l_executed := NULL;
            IF l_rec_orders.ORIGIN_COUNTRY <> g_select_all THEN
              DECLARE
                l_countries VARCHAR2(2000);
                l_field_name VARCHAR2(30);
              BEGIN
                l_countries := l_rec_orders.ORIGIN_COUNTRY;
                l_field_name := 'ORIGIN_COUNTRY';
                l_sequence := l_sequence +1 ;
                IF instrb(l_countries,l_separator) > 0 THEN
                    --l_filter_type := 3;
                    l_multi_select:= 1;
                ELSE
                    --l_filter_type := 1;
                    l_multi_select:= 2;
                END IF;
                l_filter_type := 10;
                l_INSERT_WHAT := l_insert_what ||p_query_id||l_delim||''''||l_field_name||''''||l_delim||
                                                 l_sequence ||l_delim||l_filter_type||l_delim||
                                                 ''''||l_countries||''''||l_delim||
                                                 l_null_str||l_delim||l_null_str||l_delim||l_multi_select||l_delim||
                                                 l_active_flag||l_delim;
                l_insert_who := l_userid||l_delim||'SYSDATE'||')';
                l_executed := execute_dyn_sql(l_insert_begin||l_insert_what||l_insert_who,NULL);

                l_filter_type := NULL;
                l_multi_select := 2;
                l_insert_what := '(';
                l_executed := NULL;
                l_field_name := 'DESTINATION_COUNTRY';
                l_sequence := l_sequence +1 ;
                IF instrb(l_countries,l_separator) > 0 THEN
                    --l_filter_type := 3;
                    l_multi_select:= 1;
                ELSE
                    --l_filter_type := 1;
                    l_multi_select:= 2;
                END IF;
                l_filter_type := 10;
                l_INSERT_WHAT := l_insert_what ||p_query_id||l_delim||''''||l_field_name||''''||l_delim||
                                                 l_sequence ||l_delim||l_filter_type||l_delim||
                                                 ''''||l_countries||''''||l_delim||
                                                 l_null_str||l_delim||l_null_str||l_delim||l_multi_select||l_delim||
                                                 l_active_flag||l_delim;
                l_insert_who := l_userid||l_delim||'SYSDATE'||')';
                l_executed := execute_dyn_sql(l_insert_begin||l_insert_what||l_insert_who,NULL);
              END;
            END IF; -- end ORIGIN_COUNTRY <> g_select_all
        ELSIF l_rec_orders.RANGE_TYPE = 4 THEN
            -- ---------------------------------
            -- Criteria 2 - Range -(4)- Facility
            -- ---------------------------------
            IF l_rec_orders.ORIGIN_FACILITIES <> g_select_all THEN
              DECLARE
                l_facilities VARCHAR2(2000);
                l_field_name VARCHAR2(30);
              BEGIN
                l_facilities := l_rec_orders.ORIGIN_FACILITY_IDS;
                l_field_name := 'ORIGIN_FACILITY_ID';
                l_sequence := l_sequence +1 ;
                IF instrb(l_facilities,l_separator) > 0 THEN
                    --l_filter_type := 3;
                    IF l_rec_orders.DESTINATION_FACILITIES = g_select_all THEN
                        l_filter_type := 3;
                    ELSE
                        l_filter_type := 4;
                    END IF;
                    l_multi_select:= 1;
                ELSE
                    NULL;
                    --l_filter_type := 1;
                    IF l_rec_orders.DESTINATION_FACILITIES = g_select_all THEN
                        l_filter_type := 1;
                    ELSE
                        l_filter_type := 4;
                    END IF;
                END IF;
                --l_filter_type := 4;
                l_INSERT_WHAT := l_insert_what ||p_query_id||l_delim||''''||l_field_name||''''||l_delim||
                                                 l_sequence ||l_delim||l_filter_type||l_delim||
                                                 ''''||l_facilities||''''||l_delim||
                                                 l_null_str||l_delim||l_null_str||l_delim||l_multi_select||l_delim||
                                                 l_active_flag||l_delim;
                l_insert_who := l_userid||l_delim||'SYSDATE'||')';
                l_executed := execute_dyn_sql(l_insert_begin||l_insert_what||l_insert_who,NULL);
              END;
            END IF; -- end ORIGIN_FACILITY <> g_select_all
            l_filter_type := NULL;
            l_multi_select := 2;
            l_insert_what := '(';
            l_executed := NULL;
            IF l_rec_orders.DESTINATION_FACILITIES <> g_select_all THEN
              DECLARE
                l_facilities VARCHAR2(2000);
                l_field_name VARCHAR2(30);
              BEGIN
                l_facilities := l_rec_orders.DESTINATION_FACILITY_IDS;
                l_field_name := 'DESTINATION_FACILITY_ID';
                l_sequence := l_sequence +1 ;
                IF instrb(l_facilities,l_separator) > 0 THEN
                    IF l_rec_orders.ORIGIN_FACILITIES = g_select_all THEN
                        l_filter_type := 3;
                    ELSE
                        l_filter_type := 4;
                    END IF;
                    l_multi_select:= 1;
                ELSE
                    IF l_rec_orders.ORIGIN_FACILITIES = g_select_all THEN
                        l_filter_type := 1;
                    ELSE
                        l_filter_type := 4;
                    END IF;
                END IF;
                --l_filter_type := 4;
                l_INSERT_WHAT := l_insert_what ||p_query_id||l_delim||''''||l_field_name||''''||l_delim||
                                                 l_sequence ||l_delim||l_filter_type||l_delim||
                                                 ''''||l_facilities||''''||l_delim||
                                                 l_null_str||l_delim||l_null_str||l_delim||l_multi_select||l_delim||
                                                 l_active_flag||l_delim;
                l_insert_who := l_userid||l_delim||'SYSDATE'||')';
                l_executed := execute_dyn_sql(l_insert_begin||l_insert_what||l_insert_who,NULL);
              END;
            END IF; -- end DESTINATION_FACILITIES <> g_select_all
            -- ---------------------------------
            -- Criteria 2 - Range -(4)- Zip
            -- ---------------------------------
            l_filter_type := NULL;
            l_multi_select := 2;
            l_insert_what := '(';
            l_executed := NULL;
            IF l_rec_orders.ORIGIN_ZIP <> g_select_all THEN
              DECLARE
                l_postalcodes VARCHAR2(2000);
                l_field_name VARCHAR2(30);
              BEGIN
                l_postalcodes := l_rec_orders.ORIGIN_ZIP;
                l_field_name := 'ORIGIN_ZIP';
                l_sequence := l_sequence +1 ;
                IF instrb(l_postalcodes,l_separator) > 0 THEN
                    IF l_rec_orders.DESTINATION_ZIP = g_select_all THEN
                        l_filter_type := 3;
                    ELSE
                        l_filter_type := 4;
                    END IF;
                    l_multi_select:= 1;
                ELSE
                    IF l_rec_orders.DESTINATION_ZIP = g_select_all THEN
                        l_filter_type := 1;
                    ELSE
                        l_filter_type := 4;
                    END IF;
                END IF;
                l_INSERT_WHAT := l_insert_what ||p_query_id||l_delim||''''||l_field_name||''''||l_delim||
                                                 l_sequence ||l_delim||l_filter_type||l_delim||
                                                 ''''||l_postalcodes||''''||l_delim||
                                                 l_null_str||l_delim||l_null_str||l_delim||l_multi_select||l_delim||
                                                 l_active_flag||l_delim;
                l_insert_who := l_userid||l_delim||'SYSDATE'||')';
                l_executed := execute_dyn_sql(l_insert_begin||l_insert_what||l_insert_who,NULL);
              END;
            END IF; -- end ORIGIN_ZIP <> g_select_all
            l_filter_type := NULL;
            l_multi_select := 2;
            l_insert_what := '(';
            l_executed := NULL;
            IF l_rec_orders.DESTINATION_ZIP <> g_select_all THEN
              DECLARE
                l_postalcodes VARCHAR2(2000);
                l_field_name VARCHAR2(30);
              BEGIN
                l_postalcodes := l_rec_orders.DESTINATION_ZIP;
                l_field_name := 'DESTINATION_ZIP';
                l_sequence := l_sequence +1 ;
                IF instrb(l_postalcodes,l_separator) > 0 THEN
                    IF l_rec_orders.ORIGIN_ZIP = g_select_all THEN
                        l_filter_type := 3;
                    ELSE
                        l_filter_type := 4;
                    END IF;
                    l_multi_select:= 1;
                ELSE
                    IF l_rec_orders.ORIGIN_ZIP = g_select_all THEN
                        l_filter_type := 1;
                    ELSE
                        l_filter_type := 4;
                    END IF;
                END IF;
                l_INSERT_WHAT := l_insert_what ||p_query_id||l_delim||''''||l_field_name||''''||l_delim||
                                                 l_sequence ||l_delim||l_filter_type||l_delim||
                                                 ''''||l_postalcodes||''''||l_delim||
                                                 l_null_str||l_delim||l_null_str||l_delim||l_multi_select||l_delim||
                                                 l_active_flag||l_delim;
                l_insert_who := l_userid||l_delim||'SYSDATE'||')';
                l_executed := execute_dyn_sql(l_insert_begin||l_insert_what||l_insert_who,NULL);
              END;
            END IF; -- end DESTINATION_ZIP <> g_select_all
            -- ---------------------------------
            -- Criteria 2 - Range -(4)- City
            -- ---------------------------------
            l_filter_type := NULL;
            l_multi_select := 2;
            l_insert_what := '(';
            l_executed := NULL;
            IF l_rec_orders.ORIGIN_CITY <> g_select_all THEN
              DECLARE
                l_cities VARCHAR2(2000);
                l_field_name VARCHAR2(30);
              BEGIN
                l_cities := l_rec_orders.ORIGIN_CITY;
                l_field_name := 'ORIGIN_CITY';
                l_sequence := l_sequence +1 ;
                IF instrb(l_cities,l_separator) > 0 THEN
                    IF l_rec_orders.DESTINATION_CITY = g_select_all THEN
                        l_filter_type := 3;
                    ELSE
                        l_filter_type := 4;
                    END IF;
                    l_multi_select:= 1;
                ELSE
                    IF l_rec_orders.DESTINATION_CITY = g_select_all THEN
                        l_filter_type := 1;
                    ELSE
                        l_filter_type := 4;
                    END IF;
                END IF;
                l_INSERT_WHAT := l_insert_what ||p_query_id||l_delim||''''||l_field_name||''''||l_delim||
                                                 l_sequence ||l_delim||l_filter_type||l_delim||
                                                 ''''||l_cities||''''||l_delim||
                                                 l_null_str||l_delim||l_null_str||l_delim||l_multi_select||l_delim||
                                                 l_active_flag||l_delim;
                l_insert_who := l_userid||l_delim||'SYSDATE'||')';
                l_executed := execute_dyn_sql(l_insert_begin||l_insert_what||l_insert_who,NULL);
              END;
            END IF; -- end ORIGIN_CITY <> g_select_all
            l_filter_type := NULL;
            l_multi_select := 2;
            l_insert_what := '(';
            l_executed := NULL;
            IF l_rec_orders.DESTINATION_CITY <> g_select_all THEN
              DECLARE
                l_cities VARCHAR2(2000);
                l_field_name VARCHAR2(30);
              BEGIN
                l_cities := l_rec_orders.DESTINATION_CITY;
                l_field_name := 'DESTINATION_CITY';
                l_sequence := l_sequence +1 ;
                IF instrb(l_cities,l_separator) > 0 THEN
                    IF l_rec_orders.ORIGIN_CITY = g_select_all THEN
                        l_filter_type := 3;
                    ELSE
                        l_filter_type := 4;
                    END IF;
                    l_multi_select:= 1;
                ELSE
                    IF l_rec_orders.ORIGIN_CITY = g_select_all THEN
                        l_filter_type := 1;
                    ELSE
                        l_filter_type := 4;
                    END IF;
                END IF;
                l_INSERT_WHAT := l_insert_what ||p_query_id||l_delim||''''||l_field_name||''''||l_delim||
                                                 l_sequence ||l_delim||l_filter_type||l_delim||
                                                 ''''||l_cities||''''||l_delim||
                                                 l_null_str||l_delim||l_null_str||l_delim||l_multi_select||l_delim||
                                                 l_active_flag||l_delim;
                l_insert_who := l_userid||l_delim||'SYSDATE'||')';
                l_executed := execute_dyn_sql(l_insert_begin||l_insert_what||l_insert_who,NULL);
              END;
            END IF; -- end DESTINATION_CITY <> g_select_all
            -- ---------------------------------
            -- Criteria 2 - Range -(4)- State
            -- ---------------------------------
            l_filter_type := NULL;
            l_multi_select := 2;
            l_insert_what := '(';
            l_executed := NULL;
            IF l_rec_orders.ORIGIN_STATE <> g_select_all THEN
              DECLARE
                l_states VARCHAR2(2000);
                l_field_name VARCHAR2(30);
              BEGIN
                l_states := l_rec_orders.ORIGIN_STATE;
                l_field_name := 'ORIGIN_STATE';
                l_sequence := l_sequence +1 ;
                IF instrb(l_states,l_separator) > 0 THEN
                    IF l_rec_orders.DESTINATION_STATE = g_select_all THEN
                        l_filter_type := 3;
                    ELSE
                        l_filter_type := 4;
                    END IF;
                    l_multi_select:= 1;
                ELSE
                    IF l_rec_orders.DESTINATION_STATE = g_select_all THEN
                        l_filter_type := 1;
                    ELSE
                        l_filter_type := 4;
                    END IF;
                END IF;
                l_INSERT_WHAT := l_insert_what ||p_query_id||l_delim||''''||l_field_name||''''||l_delim||
                                                 l_sequence ||l_delim||l_filter_type||l_delim||
                                                 ''''||l_states||''''||l_delim||
                                                 l_null_str||l_delim||l_null_str||l_delim||l_multi_select||l_delim||
                                                 l_active_flag||l_delim;
                l_insert_who := l_userid||l_delim||'SYSDATE'||')';
                l_executed := execute_dyn_sql(l_insert_begin||l_insert_what||l_insert_who,NULL);
              END;
            END IF; -- end ORIGIN_STATE <> g_select_all
            l_filter_type := NULL;
            l_multi_select := 2;
            l_insert_what := '(';
            l_executed := NULL;
            IF l_rec_orders.DESTINATION_STATE <> g_select_all THEN
              DECLARE
                l_states VARCHAR2(2000);
                l_field_name VARCHAR2(30);
              BEGIN
                l_states := l_rec_orders.DESTINATION_STATE;
                l_field_name := 'DESTINATION_STATE';
                l_sequence := l_sequence +1 ;
                IF instrb(l_states,l_separator) > 0 THEN
                    IF l_rec_orders.ORIGIN_STATE = g_select_all THEN
                        l_filter_type := 3;
                    ELSE
                        l_filter_type := 4;
                    END IF;
                    l_multi_select:= 1;
                ELSE
                    IF l_rec_orders.ORIGIN_STATE = g_select_all THEN
                        l_filter_type := 1;
                    ELSE
                        l_filter_type := 4;
                    END IF;
                END IF;
                l_INSERT_WHAT := l_insert_what ||p_query_id||l_delim||''''||l_field_name||''''||l_delim||
                                                 l_sequence ||l_delim||l_filter_type||l_delim||
                                                 ''''||l_states||''''||l_delim||
                                                 l_null_str||l_delim||l_null_str||l_delim||l_multi_select||l_delim||
                                                 l_active_flag||l_delim;
                l_insert_who := l_userid||l_delim||'SYSDATE'||')';
                l_executed := execute_dyn_sql(l_insert_begin||l_insert_what||l_insert_who,NULL);
              END;
            END IF; -- end DESTINATION_STATE <> g_select_all
            -- ---------------------------------
            -- Criteria 2 - Range -(4)- Country
            -- ---------------------------------
            l_filter_type := NULL;
            l_multi_select := 2;
            l_insert_what := '(';
            l_executed := NULL;
            IF l_rec_orders.ORIGIN_COUNTRY <> g_select_all THEN
              DECLARE
                l_countries VARCHAR2(2000);
                l_field_name VARCHAR2(30);
              BEGIN
                l_countries := l_rec_orders.ORIGIN_COUNTRY;
                l_field_name := 'ORIGIN_COUNTRY';
                l_sequence := l_sequence +1 ;
                IF instrb(l_countries,l_separator) > 0 THEN
                    IF l_rec_orders.DESTINATION_COUNTRY = g_select_all THEN
                        l_filter_type := 3;
                    ELSE
                        l_filter_type := 4;
                    END IF;
                    l_multi_select:= 1;
                ELSE
                    IF l_rec_orders.DESTINATION_COUNTRY = g_select_all THEN
                        l_filter_type := 1;
                    ELSE
                        l_filter_type := 4;
                    END IF;
                END IF;
                l_INSERT_WHAT := l_insert_what ||p_query_id||l_delim||''''||l_field_name||''''||l_delim||
                                                 l_sequence ||l_delim||l_filter_type||l_delim||
                                                 ''''||l_countries||''''||l_delim||
                                                 l_null_str||l_delim||l_null_str||l_delim||l_multi_select||l_delim||
                                                 l_active_flag||l_delim;
                l_insert_who := l_userid||l_delim||'SYSDATE'||')';
                l_executed := execute_dyn_sql(l_insert_begin||l_insert_what||l_insert_who,NULL);
              END;
            END IF; -- end ORIGIN_COUNTRY <> g_select_all
            l_filter_type := NULL;
            l_multi_select := 2;
            l_insert_what := '(';
            l_executed := NULL;
            IF l_rec_orders.DESTINATION_COUNTRY <> g_select_all THEN
              DECLARE
                l_countries VARCHAR2(2000);
                l_field_name VARCHAR2(30);
              BEGIN
                l_countries := l_rec_orders.DESTINATION_COUNTRY;
                l_field_name := 'DESTINATION_COUNTRY';
                l_sequence := l_sequence +1 ;
                IF instrb(l_countries,l_separator) > 0 THEN
                    IF l_rec_orders.ORIGIN_COUNTRY = g_select_all THEN
                        l_filter_type := 3;
                    ELSE
                        l_filter_type := 4;
                    END IF;
                    l_multi_select:= 1;
                ELSE
                    IF l_rec_orders.ORIGIN_COUNTRY = g_select_all THEN
                        l_filter_type := 1;
                    ELSE
                        l_filter_type := 4;
                    END IF;
                END IF;
                l_INSERT_WHAT := l_insert_what ||p_query_id||l_delim||''''||l_field_name||''''||l_delim||
                                                 l_sequence ||l_delim||l_filter_type||l_delim||
                                                 ''''||l_countries||''''||l_delim||
                                                 l_null_str||l_delim||l_null_str||l_delim||l_multi_select||l_delim||
                                                 l_active_flag||l_delim;
                l_insert_who := l_userid||l_delim||'SYSDATE'||')';
                l_executed := execute_dyn_sql(l_insert_begin||l_insert_what||l_insert_who,NULL);
              END;
            END IF; -- end DESTINATION_COUNTRY <> g_select_all
        END IF; -- end RANGE_TYPE
        -- ---------------------------------
        -- Criteria 3 - Items
        -- ---------------------------------
        l_filter_type := NULL;
        l_multi_select := 2;
        l_insert_what := '(';
        l_executed := NULL;
        IF l_rec_orders.Items <> g_select_all THEN
          DECLARE
            l_items VARCHAR2(2000);
            l_field_name VARCHAR2(30);
          BEGIN
            l_items := l_rec_orders.Inventory_Item_Ids;
            l_field_name := 'INVENTORY_ITEM_ID';
            l_sequence := l_sequence +1 ;
            IF instrb(l_items,l_separator) > 0 THEN
                l_filter_type := 3;
                l_multi_select:= 1;
            ELSE
                l_filter_type := 1;
            END IF;
            l_INSERT_WHAT := l_insert_what ||p_query_id||l_delim||''''||l_field_name||''''||l_delim||
                                             l_sequence ||l_delim||l_filter_type||l_delim||
                                             ''''||l_items||''''||l_delim||
                                             l_null_str||l_delim||l_null_str||l_delim||l_multi_select||l_delim||
                                             l_active_flag||l_delim;
            l_insert_who := l_userid||l_delim||'SYSDATE'||')';
            l_executed := execute_dyn_sql(l_insert_begin||l_insert_what||l_insert_who,NULL);
            IF l_executed = 0 THEN
                RAISE execution_failed;
            END IF;
          END;
        END IF; -- end Items <> g_select_all
        -- ---------------------------------
        -- Criteria 4 - Customers
        -- ---------------------------------
        l_filter_type := NULL;
        l_multi_select := 2;
        l_insert_what := '(';
        l_executed := NULL;
        IF l_rec_orders.Customers <> g_select_all THEN
          DECLARE
            l_Customers VARCHAR2(2000);
            l_field_name VARCHAR2(30);
          BEGIN
            l_Customers := l_rec_orders.Customer_ids;
            l_field_name := 'CUSTOMER_ID';
            l_sequence := l_sequence +1 ;
            IF instrb(l_Customers,l_separator) > 0 THEN
                l_filter_type := 3;
                l_multi_select:= 1;
            ELSE
                l_filter_type := 1;
            END IF;
            l_INSERT_WHAT := l_insert_what ||p_query_id||l_delim||''''||l_field_name||''''||l_delim||
                                             l_sequence ||l_delim||l_filter_type||l_delim||
                                             ''''||l_Customers||''''||l_delim||
                                             l_null_str||l_delim||l_null_str||l_delim||l_multi_select||l_delim||
                                             l_active_flag||l_delim;
            l_insert_who := l_userid||l_delim||'SYSDATE'||')';
            l_executed := execute_dyn_sql(l_insert_begin||l_insert_what||l_insert_who,NULL);
            IF l_executed = 0 THEN
                RAISE execution_failed;
            END IF;
          END;
        END IF; -- end Customers <> g_select_all
        -- ---------------------------------
        -- Criteria 5 - Suppliers
        -- ---------------------------------
        l_filter_type := NULL;
        l_multi_select := 2;
        l_insert_what := '(';
        l_executed := NULL;
        IF l_rec_orders.Suppliers <> g_select_all THEN
          DECLARE
            l_Suppliers VARCHAR2(2000);
            l_field_name VARCHAR2(30);
          BEGIN
            l_Suppliers := l_rec_orders.Supplier_ids;
            l_field_name := 'SUPPLIER_ID';
            l_sequence := l_sequence +1 ;
            IF instrb(l_Suppliers,l_separator) > 0 THEN
                l_filter_type := 3;
                l_multi_select:= 1;
            ELSE
                l_filter_type := 1;
            END IF;
            l_INSERT_WHAT := l_insert_what ||p_query_id||l_delim||''''||l_field_name||''''||l_delim||
                                             l_sequence ||l_delim||l_filter_type||l_delim||
                                             ''''||l_Suppliers||''''||l_delim||
                                             l_null_str||l_delim||l_null_str||l_delim||l_multi_select||l_delim||
                                             l_active_flag||l_delim;
            l_insert_who := l_userid||l_delim||'SYSDATE'||')';
            l_executed := execute_dyn_sql(l_insert_begin||l_insert_what||l_insert_who,NULL);
            IF l_executed = 0 THEN
                RAISE execution_failed;
            END IF;
          END;
        END IF; -- end Suppliers <> g_select_all
        -- ---------------------------------
        -- Criteria 6 - Weight
        -- ---------------------------------
        l_filter_type := NULL;
        l_multi_select := 2;
        l_insert_what := '(';
        l_executed := NULL;
        IF l_rec_orders.WEIGHT_FROM IS NOT NULL THEN
          DECLARE
            l_WEIGHT_from NUMBER;
            l_WEIGHT_to NUMBER;
            l_field_name VARCHAR2(30);
          BEGIN
            l_WEIGHT_from := l_rec_orders.WEIGHT_FROM;
            l_field_name := 'TOTAL_WEIGHT';
            l_sequence := l_sequence +1 ;
            l_filter_type := l_rec_orders.WEIGHT_TYPE;
            l_multi_select:= 2;
            IF l_filter_type = 4 THEN
                l_WEIGHT_to := l_rec_orders.WEIGHT_TO;
            END IF;
            l_INSERT_WHAT := l_insert_what ||p_query_id||l_delim||''''||l_field_name||''''||l_delim||
                                             l_sequence ||l_delim||l_filter_type||l_delim||
                                             ''''||l_WEIGHT_from||''''||l_delim||
                                             l_null_str||l_delim||''''||l_WEIGHT_to||''''||l_delim||
                                             l_multi_select||l_delim||
                                             l_active_flag||l_delim;
            l_insert_who := l_userid||l_delim||'SYSDATE'||')';
            l_executed := execute_dyn_sql(l_insert_begin||l_insert_what||l_insert_who,NULL);
            IF l_executed = 0 THEN
                RAISE execution_failed;
            END IF;
          END;
        END IF; -- end WEIGHT_FROM IS NOT NULL
        -- ---------------------------------
        -- Criteria 7 - Cube
        -- ---------------------------------
        l_filter_type := NULL;
        l_multi_select := 2;
        l_insert_what := '(';
        l_executed := NULL;
        IF l_rec_orders.CUBE_FROM IS NOT NULL THEN
          DECLARE
            l_CUBE_from NUMBER;
            l_CUBE_to NUMBER;
            l_field_name VARCHAR2(30);
          BEGIN
            l_CUBE_from := l_rec_orders.CUBE_FROM;
            l_field_name := 'TOTAL_CUBE';
            l_sequence := l_sequence +1 ;
            l_filter_type := l_rec_orders.CUBE_TYPE;
            l_multi_select:= 2;
            IF l_filter_type = 4 THEN
                l_CUBE_to := l_rec_orders.CUBE_TO;
            END IF;
            l_INSERT_WHAT := l_insert_what ||p_query_id||l_delim||''''||l_field_name||''''||l_delim||
                                             l_sequence ||l_delim||l_filter_type||l_delim||
                                             ''''||l_CUBE_from||''''||l_delim||
                                             l_null_str||l_delim||''''||l_CUBE_to||''''||l_delim||
                                             l_multi_select||l_delim||
                                             l_active_flag||l_delim;
            l_insert_who := l_userid||l_delim||'SYSDATE'||')';
            l_executed := execute_dyn_sql(l_insert_begin||l_insert_what||l_insert_who,NULL);
            IF l_executed = 0 THEN
                RAISE execution_failed;
            END IF;
          END;
        END IF; -- end CUBE_FROM IS NOT NULL
    EXCEPTION
        WHEN OTHERS THEN
            RAISE;
    END insert_order_selection;

    PROCEDURE insert_excep_selection(p_query_id IN NUMBER) IS
        cursor cur_excep is
        select ALL_EXCEPTION_TYPES   ,EXCEPTION_TYPES       ,
               EXCEPTION_TYPE_IDS    ,TRUCKLOADS            ,
               PARCELS               ,LTLS                  ,
               CONTINUOUS_MOVES      ,DELIVERIES            ,
               FACILITIES            ,FACILITY_IDS          ,
               CARRIERS              ,CARRIER_IDS           ,
               CUSTOMERS             ,CUSTOMER_IDS          ,
               SUPPLIERS             ,SUPPLIER_IDS          ,
               EXCEPTION_COUNT_TYPE  ,EXCEPTION_COUNT_FROM  ,
               EXCEPTION_COUNT_TO    ,EXCEPTION_STATUS      ,
               EXCEPTION_STATUS_IDS
        from mst_excep_selection_criteria
        where query_id = p_query_id;

        l_rec_excep cur_excep%ROWTYPE;

        l_insert_begin VARCHAR2(500);
        l_insert_what  VARCHAR2(3000);
        l_insert_who   VARCHAR2(500);
        l_delete_str   VARCHAR2(500);
        l_executed NUMBER ;
        l_filter_type NUMBER;
        l_sequence NUMBER ;--:= 0;
        l_multi_select NUMBER ;--:= 2; -- 1 true, 2 false
        l_active_flag NUMBER ;--:= 1;
        l_delim CONSTANT VARCHAR2(1) := ',';
        l_separator CONSTANT VARCHAR2(1):= ';';
        l_null_str CONSTANT VARCHAR2(6) := 'NULL';
        l_userid NUMBER ; --:= TO_NUMBER(FND_PROFILE.VALUE('USER_ID'));
        execution_failed EXCEPTION;
    BEGIN
        l_sequence := 0;
        l_multi_select := 2; -- 1 true, 2 false
        l_active_flag := 1;
        l_userid := TO_NUMBER(FND_PROFILE.VALUE('USER_ID'));
        l_delete_str := 'DELETE MST_SELECTION_CRITERIA WHERE QUERY_ID = :P_QUERYID';
        l_executed := execute_dyn_sql(l_delete_str,p_query_id);
        IF l_executed = 0 THEN
            RAISE execution_failed;
        END IF;
        IF g_select_all IS NULL THEN
            FND_MESSAGE.set_name('MST','MST_PQ_ALL');
                g_select_all:= FND_MESSAGE.GET;
            --g_select_all := 'All';
        END IF;
        l_insert_begin := 'INSERT INTO MST_SELECTION_CRITERIA '||
                           '(QUERY_ID     , FIELD_NAME      , SEQUENCE     ,'||
                           'FILTER_TYPE   , FIELD_VALUE_FROM, DISPLAY_VALUE,'||
                           'FIELD_VALUE_TO, MULTI_SELECT    , ACTIVE_FLAG  ,'||
                           'CREATED_BY    , CREATION_DATE   ) VALUES ';
        OPEN cur_excep;
        FETCH cur_excep INTO l_rec_excep;
        IF cur_excep%NOTFOUND THEN
            CLOSE cur_excep;
            RAISE no_data_found;
        END IF;
        CLOSE cur_excep;
        l_insert_what := '(';
        l_executed := NULL;
        -- ---------------------------------
        -- Criteria 1 EXCEPTION_TYPES
        -- ---------------------------------
        IF l_rec_excep.EXCEPTION_TYPES IS NOT NULL  THEN
          DECLARE
            l_excep_type_ids VARCHAR2(2000);
          BEGIN
            l_excep_type_ids := l_rec_excep.EXCEPTION_TYPE_IDS;

            IF instrb(l_excep_type_ids,l_separator) > 0
            AND  instrb(l_excep_type_ids,l_separator,-1)<>lengthb(l_excep_type_ids) THEN
              l_excep_type_ids := l_excep_type_ids||l_separator;
            END IF;
            l_sequence := l_sequence +1 ;
            IF instrb(l_excep_type_ids,l_separator) > 0 THEN
                l_filter_type := 3;
                l_multi_select:= 1;
            ELSE
                l_filter_type := 1;
            END IF;
            l_INSERT_WHAT := l_insert_what ||p_query_id||l_delim||'''EXCEPTION_TYPE'''||l_delim||
                                             l_sequence ||l_delim||l_filter_type||l_delim||
                                             ''''||l_excep_type_ids||''''||l_delim||
                                             l_null_str||l_delim||l_null_str||l_delim||l_multi_select||l_delim||
                                             l_active_flag||l_delim;
            l_insert_who := l_userid||l_delim||'SYSDATE'||')';
            l_executed := execute_dyn_sql(l_insert_begin||l_insert_what||l_insert_who,NULL);
            IF l_executed = 0 THEN
                RAISE execution_failed;
            END IF;
          END;
        END IF; -- end EXCEPTION_TYPES
        l_filter_type := NULL;
        l_multi_select := 2;
        l_insert_what := '(';
        l_executed := NULL;
        -- ---------------------------------
        -- Criteria 2 TL/LTL/PARCEL
        -- ---------------------------------
        IF l_rec_excep.TRUCKLOADS = 1 OR
           l_rec_excep.LTLS = 1 OR
           l_rec_excep.PARCELS = 1 THEN
           DECLARE
            l_modes VARCHAR2(50);
           BEGIN
            IF l_rec_excep.truckloads = 1 THEN
                l_modes := 'TRUCK';
            END IF;
            IF l_rec_excep.LTLS =1 THEN
                IF l_modes IS NOT NULL THEN
                  l_modes := l_modes||l_separator||'LTL';
                ELSE
                    l_modes := 'LTL';
                END IF;
            END IF;
            IF l_rec_excep.PARCELS =1 THEN
                IF l_modes IS NOT NULL THEN
                  l_modes := l_modes||l_separator||'PARCEL';
                ELSE
                    l_modes := 'PARCEL';
                END IF;
            END IF;
            l_sequence := l_sequence +1 ;
            IF instrb(l_modes,l_separator) > 0 THEN
                l_filter_type := 3;
                l_multi_select:= 1;
            ELSE
                l_filter_type := 1;
            END IF;
            l_INSERT_WHAT := l_insert_what ||p_query_id||l_delim||'''MODE_OF_TRANSPORT'''||l_delim||
                                             l_sequence ||l_delim||l_filter_type||l_delim||
                                             ''''||l_modes||''''||l_delim||
                                             l_null_str||l_delim||l_null_str||l_delim||l_multi_select||l_delim||
                                             l_active_flag||l_delim;
            l_insert_who := l_userid||l_delim||'SYSDATE'||')';
            l_executed := execute_dyn_sql(l_insert_begin||l_insert_what||l_insert_who,NULL);
            IF l_executed = 0 THEN
                RAISE execution_failed;
            END IF;
           END;
        ELSE
            l_sequence := l_sequence +1 ;
            --l_filter_type := 10;
            l_filter_type := 1;
            DECLARE
                l_modes NUMBER;
            BEGIN
                l_modes := 2;
            l_INSERT_WHAT := l_insert_what ||p_query_id||l_delim||'''MODE_OF_TRANSPORT'''||l_delim||
                                             l_sequence ||l_delim||l_filter_type||l_delim||
                                             ''''||l_modes||''''||l_delim||
                                             l_null_str||l_delim||l_null_str||l_delim||l_multi_select||l_delim||
                                             l_active_flag||l_delim;
            END;
            l_insert_who := l_userid||l_delim||'SYSDATE'||')';
            l_executed := execute_dyn_sql(l_insert_begin||l_insert_what||l_insert_who,NULL);
            IF l_executed = 0 THEN
                RAISE execution_failed;
            END IF;
        END IF; -- end TL/LTL/PARCEL
        l_filter_type := NULL;
        l_multi_select := 2;
        l_insert_what := '(';
        l_executed := NULL;
        -- ---------------------------------
        -- Criteria 3 Continuous Moves
        -- ---------------------------------
        IF l_rec_excep.CONTINUOUS_MOVES = 1 THEN
            DECLARE
                l_cm NUMBER;
            BEGIN
                IF l_rec_excep.CONTINUOUS_MOVES = 1 THEN
                    l_sequence := l_sequence +1 ;
                    --l_filter_type := 11;
                    l_filter_type := 1;
                    l_cm := 1;
                ELSE
                    l_sequence := l_sequence +1 ;
                    --l_filter_type := 10;
                    l_filter_type := 1;
                    l_cm := 2;
                END IF;
                l_INSERT_WHAT := l_insert_what ||p_query_id||l_delim||'''CONTINUOUS_MOVE_ID'''||l_delim||
                                             l_sequence ||l_delim||l_filter_type||l_delim||
                                             ''''||l_cm||''''||l_delim||
                                             l_null_str||l_delim||l_null_str||l_delim||l_multi_select||l_delim||
                                             l_active_flag||l_delim;
            END;
            l_insert_who := l_userid||l_delim||'SYSDATE'||')';
            l_executed := execute_dyn_sql(l_insert_begin||l_insert_what||l_insert_who,NULL);
            IF l_executed = 0 THEN
                RAISE execution_failed;
            END IF;
        END IF;
        l_filter_type := NULL;
        l_multi_select := 2;
        l_insert_what := '(';
        l_executed := NULL;
        -- ---------------------------------
        -- Criteria 4 Deliveries
        -- ---------------------------------
        IF l_rec_excep.Deliveries = 1 THEN
            DECLARE
                l_deliveries NUMBER;
            BEGIN
                IF l_rec_excep.Deliveries = 1 THEN
                    l_sequence := l_sequence +1 ;
                    --l_filter_type := 11;
                    l_filter_type := 1;
                    l_deliveries := 1;
                ELSE
                    l_sequence := l_sequence +1 ;
                    --l_filter_type := 10;
                    l_filter_type := 1;
                    l_deliveries := 2;
                END IF;
                l_INSERT_WHAT := l_insert_what ||p_query_id||l_delim||'''DELIVERY_ID'''||l_delim||
                                         l_sequence ||l_delim||l_filter_type||l_delim||
                                         ''''||l_deliveries||''''||l_delim||
                                         l_null_str||l_delim||l_null_str||l_delim||l_multi_select||l_delim||
                                         l_active_flag||l_delim;
            END;
            l_insert_who := l_userid||l_delim||'SYSDATE'||')';
            l_executed := execute_dyn_sql(l_insert_begin||l_insert_what||l_insert_who,NULL);
            IF l_executed = 0 THEN
                RAISE execution_failed;
            END IF;
        END IF;
        l_filter_type := NULL;
        l_multi_select := 2;
        l_insert_what := '(';
        l_executed := NULL;
        -- ---------------------------------
        -- Criteria 5 Facilities
        -- ---------------------------------
        IF l_rec_excep.FACILITIES <> g_select_all THEN
            DECLARE
                l_facilities VARCHAR2(2000);
                l_field_name VARCHAR2(30);
            BEGIN
                l_facilities := l_rec_excep.FACILITY_IDS;
                l_field_name := 'FACILITY_ID';
                l_sequence := l_sequence +1 ;
                IF instrb(l_facilities,l_separator) > 0 THEN
                    l_filter_type := 3;
                    l_multi_select:= 1;
                ELSE
                    l_filter_type := 1;
                END IF;
                l_INSERT_WHAT := l_insert_what ||p_query_id||l_delim||''''||l_field_name||''''||l_delim||
                                                 l_sequence ||l_delim||l_filter_type||l_delim||
                                                 ''''||l_facilities||''''||l_delim||
                                                 l_null_str||l_delim||l_null_str||l_delim||l_multi_select||l_delim||
                                                 l_active_flag||l_delim;
                l_insert_who := l_userid||l_delim||'SYSDATE'||')';
                l_executed := execute_dyn_sql(l_insert_begin||l_insert_what||l_insert_who,NULL);
            END;
        END IF; -- end FACILITIES <> g_select_all
        l_filter_type := NULL;
        l_multi_select := 2;
        l_insert_what := '(';
        l_executed := NULL;
        -- ---------------------------------
        -- Criteria 6 Carriers
        -- ---------------------------------
        IF l_rec_excep.Carriers <> g_select_all THEN
          DECLARE
            l_Carriers VARCHAR2(2000);
            l_field_name VARCHAR2(30);
          BEGIN
            l_Carriers := l_rec_excep.Carrier_ids;
            l_field_name := 'CARRIER_ID';
            l_sequence := l_sequence +1 ;
            IF instrb(l_Carriers,l_separator) > 0 THEN
                l_filter_type := 3;
                l_multi_select:= 1;
            ELSE
                l_filter_type := 1;
            END IF;
            l_INSERT_WHAT := l_insert_what ||p_query_id||l_delim||''''||l_field_name||''''||l_delim||
                                             l_sequence ||l_delim||l_filter_type||l_delim||
                                             ''''||l_Carriers||''''||l_delim||
                                             l_null_str||l_delim||l_null_str||l_delim||l_multi_select||l_delim||
                                             l_active_flag||l_delim;
            l_insert_who := l_userid||l_delim||'SYSDATE'||')';
            l_executed := execute_dyn_sql(l_insert_begin||l_insert_what||l_insert_who,NULL);
            IF l_executed = 0 THEN
                RAISE execution_failed;
            END IF;
          END;
        END IF; -- end Carriers <> g_select_all
        l_filter_type := NULL;
        l_multi_select := 2;
        l_insert_what := '(';
        l_executed := NULL;
        -- ---------------------------------
        -- Criteria 7 Customers
        -- ---------------------------------
        IF l_rec_excep.Customers <> g_select_all THEN
          DECLARE
            l_Customers VARCHAR2(2000);
            l_field_name VARCHAR2(30);
          BEGIN
            l_Customers := l_rec_excep.Customer_ids;
            l_field_name := 'CUSTOMER_ID';
            l_sequence := l_sequence +1 ;
            IF instrb(l_Customers,l_separator) > 0 THEN
                l_filter_type := 3;
                l_multi_select:= 1;
            ELSE
                l_filter_type := 1;
            END IF;
            l_INSERT_WHAT := l_insert_what ||p_query_id||l_delim||''''||l_field_name||''''||l_delim||
                                             l_sequence ||l_delim||l_filter_type||l_delim||
                                             ''''||l_Customers||''''||l_delim||
                                             l_null_str||l_delim||l_null_str||l_delim||l_multi_select||l_delim||
                                             l_active_flag||l_delim;
            l_insert_who := l_userid||l_delim||'SYSDATE'||')';
            l_executed := execute_dyn_sql(l_insert_begin||l_insert_what||l_insert_who,NULL);
            IF l_executed = 0 THEN
                RAISE execution_failed;
            END IF;
          END;
        END IF; -- end Customers <> g_select_all
        l_filter_type := NULL;
        l_multi_select := 2;
        l_insert_what := '(';
        l_executed := NULL;
        -- ---------------------------------
        -- Criteria 8 - Suppliers
        -- ---------------------------------
        IF l_rec_excep.Suppliers <> g_select_all THEN
          DECLARE
            l_Suppliers VARCHAR2(2000);
            l_field_name VARCHAR2(30);
          BEGIN
            l_Suppliers := l_rec_excep.Supplier_ids;
            l_field_name := 'SUPPLIER_ID';
            l_sequence := l_sequence +1 ;
            IF instrb(l_Suppliers,l_separator) > 0 THEN
                l_filter_type := 3;
                l_multi_select:= 1;
            ELSE
                l_filter_type := 1;
            END IF;
            l_INSERT_WHAT := l_insert_what ||p_query_id||l_delim||''''||l_field_name||''''||l_delim||
                                             l_sequence ||l_delim||l_filter_type||l_delim||
                                             ''''||l_Suppliers||''''||l_delim||
                                             l_null_str||l_delim||l_null_str||l_delim||l_multi_select||l_delim||
                                             l_active_flag||l_delim;
            l_insert_who := l_userid||l_delim||'SYSDATE'||')';
            l_executed := execute_dyn_sql(l_insert_begin||l_insert_what||l_insert_who,NULL);
            IF l_executed = 0 THEN
                RAISE execution_failed;
            END IF;
          END;
        END IF; -- end Suppliers <> g_select_all
        l_filter_type := NULL;
        l_multi_select := 2;
        l_insert_what := '(';
        l_executed := NULL;
        -- ---------------------------------
        -- Criteria 9 - Exception_count
        -- ---------------------------------
        IF l_rec_excep.EXCEPTION_COUNT_FROM IS NOT NULL THEN
          DECLARE
            l_excep_Count_from NUMBER;
            l_excep_Count_to  NUMBER;
            l_field_name VARCHAR2(30);
          BEGIN
            l_excep_Count_from  := l_rec_excep.EXCEPTION_COUNT_FROM;
            l_field_name := 'TOTAL_EXCEPTIONS';
            l_sequence := l_sequence +1 ;
            l_filter_type := l_rec_excep.EXCEPTION_COUNT_TYPE;
            l_multi_select:= 2;
            IF l_filter_type = 4 THEN
                l_excep_Count_to := l_rec_excep.EXCEPTION_COUNT_TO;
            END IF;
            l_INSERT_WHAT := l_insert_what ||p_query_id||l_delim||''''||l_field_name||''''||l_delim||
                                             l_sequence ||l_delim||l_filter_type||l_delim||
                                             ''''||l_excep_Count_from ||''''||l_delim||
                                             l_null_str||l_delim||''''||l_excep_Count_to||''''||l_delim||
                                             l_multi_select||l_delim||
                                             l_active_flag||l_delim;
            l_insert_who := l_userid||l_delim||'SYSDATE'||')';
            l_executed := execute_dyn_sql(l_insert_begin||l_insert_what||l_insert_who,NULL);
            IF l_executed = 0 THEN
                RAISE execution_failed;
            END IF;
          END;
        END IF; -- end Exception_count IS NOT NULL
        l_filter_type := NULL;
        l_multi_select := 2;
        l_insert_what := '(';
        l_executed := NULL;
        -- ---------------------------------
        -- Criteria 10 - EXCEPTION_STATUS
        -- ---------------------------------
        IF l_rec_excep.EXCEPTION_STATUS IS NOT NULL THEN
            DECLARE
                l_exceptions VARCHAR2(2000);
                l_field_name VARCHAR2(30);
            BEGIN
                l_exceptions := l_rec_excep.EXCEPTION_STATUS_IDS;
                l_field_name := 'EXCEPTION_STATUS';
            l_sequence := l_sequence +1 ;
            IF instrb(l_exceptions,l_separator) > 0 THEN
                l_filter_type := 3;
                l_multi_select:= 1;
            ELSE
                l_filter_type := 1;
            END IF;
            l_INSERT_WHAT := l_insert_what ||p_query_id||l_delim||''''||l_field_name||''''||l_delim||
                                             l_sequence ||l_delim||l_filter_type||l_delim||
                                             ''''||l_exceptions||''''||l_delim||
                                             l_null_str||l_delim||l_null_str||l_delim||l_multi_select||l_delim||
                                             l_active_flag||l_delim;
            l_insert_who := l_userid||l_delim||'SYSDATE'||')';
            l_executed := execute_dyn_sql(l_insert_begin||l_insert_what||l_insert_who,NULL);
            IF l_executed = 0 THEN
                RAISE execution_failed;
            END IF;
          END;
        END IF; -- END EXCEPTION_STATUS
    END insert_excep_selection;

    PROCEDURE save_query_result(p_query_id IN NUMBER) IS
        CURSOR query_def IS
        SELECT 'x' FROM mst_personal_queries
        WHERE query_id = p_query_id
        FOR UPDATE OF execute_flag NOWAIT;
        l_dummy VARCHAR2(1);
    BEGIN
        OPEN query_def;
        FETCH query_def INTO l_dummy;
        IF query_def%FOUND THEN
            UPDATE mst_personal_queries
            SET execute_flag = 1
            WHERE CURRENT OF query_def;
            commit;
        END IF;
        CLOSE query_def;
    EXCEPTION
        WHEN OTHERS THEN
            RAISE;
    END save_query_result;

    PROCEDURE clear_temp_query(p_query_id IN NUMBER) IS
        CURSOR cur_temp_qry IS
        SELECT query_id, query_type
        FROM mst_personal_queries
        WHERE query_id = p_query_id;  -- Temp. Query

        l_temp_qry cur_temp_qry%ROWTYPE;

    BEGIN
        OPEN cur_temp_qry;
        FETCH cur_temp_qry INTO l_temp_qry;
        IF cur_temp_qry%FOUND THEN
            CLOSE cur_temp_qry;
            remove_qry_and_results
            (l_temp_qry.query_id,
             l_temp_qry.query_type);
        ELSE
            CLOSE cur_temp_qry;
        END IF;
    END clear_temp_query;

    FUNCTION launch_request(p_query_id IN NUMBER,p_plan_id IN NUMBER)
     RETURN NUMBER IS
        l_req_id NUMBER;
    BEGIN
        l_req_id := FND_REQUEST.SUBMIT_REQUEST
                     ( 'MST', -- application
                       'MSTPQTST', -- program
                       NULL,  -- description
                       NULL, -- start time
                       FALSE, -- sub_request
                       p_query_Id,
                       p_plan_id);
        RETURN l_req_id;
    END launch_request;

end MST_PQ_WORKS;

/
