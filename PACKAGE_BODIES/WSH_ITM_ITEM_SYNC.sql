--------------------------------------------------------
--  DDL for Package Body WSH_ITM_ITEM_SYNC
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."WSH_ITM_ITEM_SYNC" AS
/* $Header: WSHITISB.pls 120.2.12010000.1 2008/07/29 06:13:37 appldev ship $ */

    G_PKG_NAME CONSTANT VARCHAR2(50) := 'WSH_ITM_ITEM_SYNC';

    /*===========================================================================+
    | PROCEDURE                                                                 |
    |              BUILD_ITEM_WHERE_CLAUSE                                      |
    |                                                                           |
    | DESCRIPTION                                                               |
    |               This procedure builds the where clause for the item field   |
    |               based on the segments which are enabled for the Item        |
    |               flexfield                                                   |
    |                                                                           |
    +===========================================================================*/

    -- Private method to Build Item Where Condition
    PROCEDURE BUILD_ITEM_WHERE_CLAUSE(
    	p_item_from      	IN      	VARCHAR2,
	p_item_to     		IN      	VARCHAR2,
	l_Item_Table		IN	OUT NOCOPY	WSH_ITM_QUERY_CUSTOM.g_CondnValTableType
                    )

    IS
        l_flexfield_rec  FND_FLEX_KEY_API.flexfield_type;
        l_structure_rec  FND_FLEX_KEY_API.structure_type;
        l_segment_rec    FND_FLEX_KEY_API.segment_type;
        l_segment_tbl    FND_FLEX_KEY_API.segment_list;

	l_Item_Condn2Tab	WSH_ITM_QUERY_CUSTOM.g_ValueTableType;
	l_Item_Condn22Tab	WSH_ITM_QUERY_CUSTOM.g_ValueTableType;

        l_segment_number NUMBER;
        l_mstk_segs      VARCHAR2(850);
        l_mcat_segs      VARCHAR2(850);
        l_mcat_f         VARCHAR2(2000);
        l_mcat_w1        VARCHAR2(2000);
        l_mcat_w2        VARCHAR2(2000);
        l_mstk_w         VARCHAR2(2000);
                --
                l_debug_on BOOLEAN;
                --
                l_module_name CONSTANT VARCHAR2(100) := 'wsh.plsql.' || G_PKG_NAME || '.' || 'BUILD_ITEM_WHERE_CLAUSE';
                --

    BEGIN
                --
                l_debug_on := WSH_DEBUG_INTERFACE.g_debug;
                --
                IF l_debug_on IS NULL
                THEN
                    l_debug_on := WSH_DEBUG_SV.is_debug_enabled;
                END IF;
                --
                --
                -- Debug Statements
                --
                IF l_debug_on THEN
                    WSH_DEBUG_SV.push(l_module_name);
                    --
                    WSH_DEBUG_SV.log(l_module_name,'P_ITEM_FROM',P_ITEM_FROM);
                    WSH_DEBUG_SV.log(l_module_name,'P_ITEM_TO',P_ITEM_TO);

                END IF;
                --

        FND_FLEX_KEY_API.set_session_mode('customer_data');
        -- retrieve system item concatenated flexfield
        l_mstk_segs := '';
        l_flexfield_rec := FND_FLEX_KEY_API.find_flexfield('INV', 'MSTK');
        l_structure_rec := FND_FLEX_KEY_API.find_structure(l_flexfield_rec, 101);

        FND_FLEX_KEY_API.get_segments
              ( flexfield => l_flexfield_rec
              , structure => l_structure_rec
              , nsegments => l_segment_number
              , segments  => l_segment_tbl
              );

        FOR l_idx IN 1..l_segment_number LOOP
            l_segment_rec := FND_FLEX_KEY_API.find_segment
                        ( l_flexfield_rec
                        , l_structure_rec
                        , l_segment_tbl(l_idx)
                        );
            l_mstk_segs := l_mstk_segs ||'B.'||l_segment_rec.column_name;
            IF l_idx < l_segment_number THEN
                l_mstk_segs := l_mstk_segs||'||'||''''||l_structure_rec.segment_separator||''''||'||';
            END IF;
        END LOOP;

        IF p_item_from IS NOT NULL AND p_item_to IS NOT NULL THEN
		l_mstk_w := ' AND '||l_mstk_segs||' >= :b_item_from ';
		l_Item_Condn2Tab(1).g_varchar_val := p_item_from;
		l_Item_Condn2Tab(1).g_Bind_Literal := ':b_item_from';
		--
		-- Debug Statements
		--
		IF l_debug_on THEN
		    WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit WSH_ITM_QUERY_CUSTOM.ADD_CONDITION',WSH_DEBUG_SV.C_PROC_LEVEL);
		END IF;
		--
		WSH_ITM_QUERY_CUSTOM.ADD_CONDITION(l_Item_Table, l_mstk_w, l_Item_Condn2Tab, 'VARCHAR');

		l_mstk_w := ' AND '||l_mstk_segs||' <= :b_item_to ';
		l_Item_Condn22Tab(1).g_varchar_val := p_item_to;
		l_Item_Condn22Tab(1).g_Bind_Literal := ':b_item_to';
		--
		-- Debug Statements
		--
		IF l_debug_on THEN
			WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit WSH_ITM_QUERY_CUSTOM.ADD_CONDITION',WSH_DEBUG_SV.C_PROC_LEVEL);
		END IF;
		--
		WSH_ITM_QUERY_CUSTOM.ADD_CONDITION(l_Item_Table, l_mstk_w, l_Item_Condn22Tab, 'VARCHAR');
        ELSIF p_item_from IS NOT NULL AND p_item_to IS NULL THEN
		l_mstk_w := ' AND '||l_mstk_segs||' >= :b_item_from';
		l_Item_Condn2Tab(1).g_varchar_val := p_item_from;
		l_Item_Condn2Tab(1).g_Bind_Literal := ':b_item_from';
                --
                -- Debug Statements
                --
                IF l_debug_on THEN
                    WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit WSH_ITM_QUERY_CUSTOM.ADD_CONDITION',WSH_DEBUG_SV.C_PROC_LEVEL);
                END IF;
                --
                WSH_ITM_QUERY_CUSTOM.ADD_CONDITION(l_Item_Table, l_mstk_w, l_Item_Condn2Tab, 'VARCHAR');
        ELSIF p_item_from IS NULL AND p_item_to IS NOT NULL THEN
		l_mstk_w := ' AND '||l_mstk_segs||' <= :b_item_to';
		l_Item_Condn2Tab(1).g_varchar_val := p_item_to;
		l_Item_Condn2Tab(1).g_Bind_Literal := ':b_item_to';
                --
                -- Debug Statements
                --
                IF l_debug_on THEN
                    WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit WSH_ITM_QUERY_CUSTOM.ADD_CONDITION',WSH_DEBUG_SV.C_PROC_LEVEL);
                END IF;
                --
                WSH_ITM_QUERY_CUSTOM.ADD_CONDITION(l_Item_Table, l_mstk_w, l_Item_Condn2Tab, 'VARCHAR');
        END IF;
    end BUILD_ITEM_WHERE_CLAUSE;



    /*===========================================================================+
    | PROCEDURE                                                                 |
    |              POPULATE_DATA                                                |
    |                                                                           |
    | DESCRIPTION                                                               |
    |              This procedure is called when the Item Synchronization       |
    |              Concurrent Program is launched. It populates the data        |
    |              into WSH_ITM_REQUEST_CONTROL and WSH_ITM_ITEMS               |
    |              based on the parameters selected.                            |
    |                                                                           |
    +===========================================================================*/



        PROCEDURE POPULATE_DATA (
                        errbuf               		OUT NOCOPY   VARCHAR2,
                        retcode              		OUT NOCOPY   NUMBER,
			p_from_organization_code	IN           VARCHAR2,
			p_to_organization_code   	IN           VARCHAR2,
			p_from_item            		IN           VARCHAR2 ,
			p_to_item              		IN           VARCHAR2,
			p_user_item_type       		IN           VARCHAR2,
			p_created_n_days       		IN           NUMBER,
			p_updated_n_days       		IN           NUMBER
                                )IS

                l_SQLQuery      VARCHAR2(12000) := ' SELECT '||
                                        'B.INVENTORY_ITEM_ID            ITEM_ID,'||
                                        'WSH_UTIL_CORE.GET_ITEM_NAME (B.INVENTORY_ITEM_ID, B.ORGANIZATION_ID) PRODUCT_CODE, '||
                                        'T.DESCRIPTION                  DESCRIPTION,        '||
                                        'T.LONG_DESCRIPTION             LONG_DESCRIPTION,   '||
                                        'POHC.HAZARD_CLASS              HAZARD_CLASS,       '||
                                        'B.ORGANIZATION_ID              ORGANIZATION_ID,    '||
                                        'B.SOURCE_ORGANIZATION_ID       SRC_ORGANIZATION_ID,'||
                                        'FLV.MEANING                    ITEM_TYPE,          '||
                                        'B.PRIMARY_UOM_CODE             UNIT_OF_MEASURE,    '||
                                        'B.LIST_PRICE_PER_UNIT          ITEM_VALUE,         '||
                                        'GLPV.CURRENCY_CODE             INCOMING_CURRENCY,  '||
                                        'HL.COUNTRY                     COUNTRY,            '||
                                        ' B.ATTRIBUTE1 , B.ATTRIBUTE2 , B.ATTRIBUTE3 , B.ATTRIBUTE4 , '||
                                        ' B.ATTRIBUTE5 , B.ATTRIBUTE6 , B.ATTRIBUTE7 , B.ATTRIBUTE8 ,'||
                                        ' B.ATTRIBUTE9 , B.ATTRIBUTE10, B.ATTRIBUTE11, B.ATTRIBUTE12,'||
                                        ' B.ATTRIBUTE13, B.ATTRIBUTE14, B.ATTRIBUTE15,                '||
                                        ' OOD.OPERATING_UNIT     '||
                                        ' FROM '||
                                        '  MTL_SYSTEM_ITEMS_TL T ,      '||
                                        '  MTL_SYSTEM_ITEMS_B B,        '||
                                        '  HR_ALL_ORGANIZATION_UNITS HU,'||
                                        '  HR_LOCATIONS HL,             '||
                                        '  GL_LEDGERS_PUBLIC_V GLPV,    '||
                                        '  PO_HAZARD_CLASSES_TL POHC,   '||
                                        '  FND_LANGUAGES FNDL,      	'||
                                        '  FND_LOOKUP_VALUES FLV,       '||
                                        '  MTL_PARAMETERS MP, 		'||
                                        '  ORG_ORGANIZATION_DEFINITIONS OOD '||
                                        'WHERE                               '||
                                        '  B.INVENTORY_ITEM_ID = T.INVENTORY_ITEM_ID  '||
                                        '  AND B.ORGANIZATION_ID = T.ORGANIZATION_ID  '||
                                        '  AND HU.LOCATION_ID = HL.LOCATION_ID        '||
                                        '  AND HU.ORGANIZATION_ID = B.ORGANIZATION_ID '||
                                        '  AND GLPV.LEDGER_ID = OOD.SET_OF_BOOKS_ID '||
                                        '  AND POHC.HAZARD_CLASS_ID(+) = B.HAZARD_CLASS_ID'||
                                        '  AND FNDL.INSTALLED_FLAG = ''B''     '||
                                        '  AND B.INVENTORY_ITEM_STATUS_CODE <> ''Inactive''   '||
                                        '  AND FNDL.LANGUAGE_CODE = T.LANGUAGE '||
                                        '  AND FNDL.LANGUAGE_CODE = NVL(POHC.LANGUAGE,FNDL.LANGUAGE_CODE)  '||
                                        '  AND FLV.LOOKUP_TYPE = ''ITEM_TYPE'' '||
                                        '  AND FLV.LANGUAGE = FNDL.LANGUAGE_CODE   '||
                                        '  AND FLV.VIEW_APPLICATION_ID = 3     '||
                                        '  AND FLV.LOOKUP_CODE = B.ITEM_TYPE'||
                                        '  AND B.ORGANIZATION_ID = MP.ORGANIZATION_ID '||
                                        '  AND OOD.ORGANIZATION_ID = MP.ORGANIZATION_ID' ;


                l_Item_Table                    WSH_ITM_QUERY_CUSTOM.g_CondnValTableType;

                l_Item_Condn1Tab                WSH_ITM_QUERY_CUSTOM.g_ValueTableType;
                l_Item_Condn11Tab               WSH_ITM_QUERY_CUSTOM.g_ValueTableType;
                l_Item_Condn2Tab                WSH_ITM_QUERY_CUSTOM.g_ValueTableType;
                l_item_where_clause             VARCHAR(1000);
                l_Item_Condn3Tab                WSH_ITM_QUERY_CUSTOM.g_ValueTableType;
                l_Item_Condn4Tab                WSH_ITM_QUERY_CUSTOM.g_ValueTableType;
                l_Item_Condn5Tab                WSH_ITM_QUERY_CUSTOM.g_ValueTableType;
                l_Item_Condn6Tab                WSH_ITM_QUERY_CUSTOM.g_ValueTableType;

                l_tempStr       VARCHAR2(10000) := ' ';
                l_CursorID      NUMBER;
                l_ignore        NUMBER;

                --PL/SQL Table used for Bulk Select
                l_num_invItem_tab         DBMS_SQL.Number_Table;
                l_varchar_PrdCode_tab     DBMS_SQL.Varchar2_Table;
                l_varchar_Desc_tab        DBMS_SQL.Varchar2_Table;
                l_varchar_LongDesc_tab    DBMS_SQL.Clob_Table;
                l_varchar_hazClass_tab    DBMS_SQL.Varchar2_Table;
                l_num_orgId_tab           DBMS_SQL.Number_Table;
                l_num_srcOrgId_tab        DBMS_SQL.Number_Table;
                l_varchar_ItmType_tab     DBMS_SQL.Varchar2_Table;
                l_varchar_UOM_tab         DBMS_SQL.Varchar2_Table;
                l_num_itmVal_tab          DBMS_SQL.Number_Table;
                l_varchar_Curr_tab        DBMS_SQL.Varchar2_Table;
                l_varchar_Coun_tab        DBMS_SQL.Varchar2_Table;
                l_LanguageCode            VARCHAR2(4);

                l_varchar_Attrib1_tab     DBMS_SQL.Varchar2_Table;
                l_varchar_Attrib2_tab     DBMS_SQL.Varchar2_Table;
                l_varchar_Attrib3_tab     DBMS_SQL.Varchar2_Table;
                l_varchar_Attrib4_tab     DBMS_SQL.Varchar2_Table;
                l_varchar_Attrib5_tab     DBMS_SQL.Varchar2_Table;
                l_varchar_Attrib6_tab     DBMS_SQL.Varchar2_Table;
                l_varchar_Attrib7_tab     DBMS_SQL.Varchar2_Table;
                l_varchar_Attrib8_tab     DBMS_SQL.Varchar2_Table;
                l_varchar_Attrib9_tab     DBMS_SQL.Varchar2_Table;
                l_varchar_Attrib10_tab    DBMS_SQL.Varchar2_Table;
                l_varchar_Attrib11_tab    DBMS_SQL.Varchar2_Table;
                l_varchar_Attrib12_tab    DBMS_SQL.Varchar2_Table;
                l_varchar_Attrib13_tab    DBMS_SQL.Varchar2_Table;
                l_varchar_Attrib14_tab    DBMS_SQL.Varchar2_Table;
                l_varchar_Attrib15_tab    DBMS_SQL.Varchar2_Table;
                l_num_Operunit_tab        DBMS_SQL.Number_Table;

                --For Insert to ITM Inteface Tables
                l_num_ReqCtrl_tab         DBMS_SQL.Number_Table;
                l_num_ItmReqCtrl_tab      DBMS_SQL.Number_Table;
                l_num_invItemID_tab       DBMS_SQL.Number_Table;

                l_tempInvItem       NUMBER := -999;

                l_user_id       NUMBER;
                l_login_id      NUMBER;
        l_temp          BOOLEAN;



                --
                l_debug_on BOOLEAN;
                --
                l_module_name CONSTANT VARCHAR2(100) := 'wsh.plsql.' || G_PKG_NAME || '.' || 'POPULATE_DATA';
                --
        BEGIN
            --Frame draft SQL

            --
            l_debug_on := WSH_DEBUG_INTERFACE.g_debug;
            --
            IF l_debug_on IS NULL
            THEN
                l_debug_on := WSH_DEBUG_SV.is_debug_enabled;
            END IF;
            --
            --
            -- Debug Statements
            --
            IF l_debug_on THEN
                WSH_DEBUG_SV.push(l_module_name);
                --
                WSH_DEBUG_SV.log(l_module_name,'P_FROM_ORGANIZATION_CODE',P_FROM_ORGANIZATION_CODE);
                WSH_DEBUG_SV.log(l_module_name,'P_TO_ORGANIZATION_CODE',P_TO_ORGANIZATION_CODE);
                WSH_DEBUG_SV.log(l_module_name,'P_FROM_ITEM',P_FROM_ITEM);
                WSH_DEBUG_SV.log(l_module_name,'P_TO_ITEM',P_TO_ITEM);
                WSH_DEBUG_SV.log(l_module_name,'P_USER_ITEM_TYPE',P_USER_ITEM_TYPE);
                WSH_DEBUG_SV.log(l_module_name,'P_CREATED_N_DAYS',P_CREATED_N_DAYS);
                WSH_DEBUG_SV.log(l_module_name,'P_UPDATED_N_DAYS',P_UPDATED_N_DAYS);
            END IF;
            --

            -- Fetch user and login information
            l_user_id  := FND_GLOBAL.USER_ID;
            l_login_id := FND_GLOBAL.CONC_LOGIN_ID;

            IF p_from_organization_code IS NOT NULL AND p_to_organization_code IS NOT NULL THEN
                    --Adding a ORGANIZATION_CODE Condn
                    l_Item_Condn1Tab(1).g_varchar_val := p_from_organization_code;
                    l_Item_Condn1Tab(1).g_Bind_Literal := ':b_from_organization_code';
		    --
                    -- Debug Statements
                    --
                    IF l_debug_on THEN
                        WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit WSH_ITM_QUERY_CUSTOM.ADD_CONDITION',WSH_DEBUG_SV.C_PROC_LEVEL);
                    END IF;
                    --
                    WSH_ITM_QUERY_CUSTOM.ADD_CONDITION(l_Item_Table, ' AND MP.ORGANIZATION_CODE >= :b_from_organization_code', l_Item_Condn1Tab, 'VARCHAR');

        		    l_Item_Condn11Tab(1).g_varchar_val := p_to_organization_code;
                    l_Item_Condn11Tab(1).g_Bind_Literal := ':b_to_organization_code';
                    --
                    -- Debug Statements
                    --
                    IF l_debug_on THEN
                        WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit WSH_ITM_QUERY_CUSTOM.ADD_CONDITION',WSH_DEBUG_SV.C_PROC_LEVEL);
                    END IF;
                    --
                    WSH_ITM_QUERY_CUSTOM.ADD_CONDITION(l_Item_Table, ' AND MP.ORGANIZATION_CODE <= :b_to_organization_code', l_Item_Condn11Tab, 'VARCHAR');

	    	ELSIF p_from_organization_code IS NOT NULL THEN
                    --Adding a ORGANIZATION_CODE Condn
                    l_Item_Condn1Tab(1).g_varchar_val := p_from_organization_code;
                    l_Item_Condn1Tab(1).g_Bind_Literal := ':b_from_organization_code';
                    --
                    -- Debug Statements
                    --
                    IF l_debug_on THEN
                        WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit WSH_ITM_QUERY_CUSTOM.ADD_CONDITION',WSH_DEBUG_SV.C_PROC_LEVEL);
                    END IF;
                    --
                    WSH_ITM_QUERY_CUSTOM.ADD_CONDITION(l_Item_Table, ' AND MP.ORGANIZATION_CODE >= :b_from_organization_code ', l_Item_Condn1Tab, 'VARCHAR');

	   		ELSIF p_to_organization_code IS NOT NULL THEN
                    --Adding a ORGANIZATION_CODE Condn
                    l_Item_Condn1Tab(1).g_varchar_val := p_to_organization_code;
                    l_Item_Condn1Tab(1).g_Bind_Literal := ':b_to_organization_code';
                    --
                    -- Debug Statements
                    --
                    IF l_debug_on THEN
                        WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit WSH_ITM_QUERY_CUSTOM.ADD_CONDITION',WSH_DEBUG_SV.C_PROC_LEVEL);
                    END IF;
                    --
                    WSH_ITM_QUERY_CUSTOM.ADD_CONDITION(l_Item_Table, ' AND MP.ORGANIZATION_CODE <= :b_to_organization_code', l_Item_Condn1Tab, 'VARCHAR');
            END IF;

            IF p_from_item IS NOT NULL OR p_to_item IS NOT NULL THEN
                --
                -- Debug Statements
                --
                IF l_debug_on THEN
                    WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit WSH_ITM_ITEM_SYNC.BUILD_ITEM_WHERE_CLUASE',WSH_DEBUG_SV.C_PROC_LEVEL);
                END IF;
                --
                BUILD_ITEM_WHERE_CLAUSE(p_from_item,p_to_item,l_Item_Table);
            END IF;
            --Adding ITEM Type Condn
            IF p_user_item_type IS NOT NULL THEN
                    l_Item_Condn3Tab(1).g_varchar_val := p_user_item_type;
                    l_Item_Condn3Tab(1).g_Bind_Literal := ':b_user_item_type';
                    --
                    -- Debug Statements
                    --
                    IF l_debug_on THEN
                        WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit WSH_ITM_QUERY_CUSTOM.ADD_CONDITION',WSH_DEBUG_SV.C_PROC_LEVEL);
                    END IF;
                    --
                    WSH_ITM_QUERY_CUSTOM.ADD_CONDITION(l_Item_Table, ' AND B.ITEM_TYPE = :b_user_item_type ', l_Item_Condn3Tab, 'VARCHAR');
            END IF;

            --Adding Creates LAst N Days Condn
            IF p_created_n_days IS NOT NULL THEN
                    l_Item_Condn4Tab(1).g_number_val := p_created_n_days;
                    l_Item_Condn4Tab(1).g_Bind_Literal := ':b_created_n_days';
                    --
                    -- Debug Statements
                    --
                    IF l_debug_on THEN
                        WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit WSH_ITM_QUERY_CUSTOM.ADD_CONDITION',WSH_DEBUG_SV.C_PROC_LEVEL);
                    END IF;
                    --
                    WSH_ITM_QUERY_CUSTOM.ADD_CONDITION(l_Item_Table, ' AND B.CREATION_DATE >= SYSDATE - :b_created_n_days ', l_Item_Condn4Tab, 'NUMBER');
            END IF;

            --Adding Creates LAst N Days Condn
            IF p_updated_n_days IS NOT NULL THEN
                    l_Item_Condn5Tab(1).g_number_val := p_updated_n_days;
                    l_Item_Condn5Tab(1).g_Bind_Literal := ':b_updated_n_days';
                    --
                    -- Debug Statements
                    --
                    IF l_debug_on THEN
                        WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit WSH_ITM_QUERY_CUSTOM.ADD_CONDITION',WSH_DEBUG_SV.C_PROC_LEVEL);
                    END IF;
                    --
                    WSH_ITM_QUERY_CUSTOM.ADD_CONDITION(l_Item_Table, ' AND B.LAST_UPDATE_DATE >= SYSDATE - :b_updated_n_days ', l_Item_Condn5Tab, 'NUMBER');
            END IF;


             --Printing the SQL before calling Customization procedure
            FOR I IN 1..l_Item_Table.COUNT
            LOOP
                l_tempStr := l_tempStr || ' ' || l_item_table(i).g_Condn_Qry;
                    END LOOP;
                    l_tempStr := l_SQLQuery || l_tempStr || ' ORDER BY B.INVENTORY_ITEM_ID';
            IF l_debug_on THEN
                WSH_DEBUG_SV.LOG (l_module_name, 'Query ',  l_tempStr, WSH_DEBUG_SV.C_STMT_LEVEL);
            END IF;
            -- Clearing sql query
            l_tempStr := '';


            --Call to custom Procedure which could be edited by the Customer.
            --
            -- Debug Statements
            --
            IF l_debug_on THEN
                WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit WSH_ITM_CUSTOMIZE.ALTER_ITEM_SYNC',WSH_DEBUG_SV.C_PROC_LEVEL);
            END IF;
            --
            WSH_ITM_CUSTOMIZE.ALTER_ITEM_SYNC(l_Item_Table);

            --Create SQL and bind parameters
            FOR I IN 1..l_Item_Table.COUNT
            LOOP
                    l_tempStr := l_tempStr || ' ' || l_item_table(i).g_Condn_Qry;
            END LOOP;

            --Concatenating Main SQL with Condition SQL
            l_SQLQuery := l_SQLQuery || l_tempStr || ' ORDER BY B.INVENTORY_ITEM_ID';

            IF l_debug_on THEN
                WSH_DEBUG_SV.LOG (l_module_name, 'Query ',  l_SQLQuery, WSH_DEBUG_SV.C_STMT_LEVEL);
            END IF;


            -- Parse cursor
            l_CursorID := DBMS_SQL.Open_Cursor;
            DBMS_SQL.PARSE(l_CursorID, l_SQLQuery,  DBMS_SQL.v7);

            DBMS_SQL.DEFINE_ARRAY(l_CursorID, 1, l_num_invItem_tab,           100, 0);
            DBMS_SQL.DEFINE_ARRAY(l_CursorID, 2, l_varchar_PrdCode_tab,       100, 0);
            DBMS_SQL.DEFINE_ARRAY(l_CursorID, 3, l_varchar_Desc_tab,          100, 0);
            DBMS_SQL.DEFINE_ARRAY(l_CursorID, 4, l_varchar_LongDesc_tab,      100, 0);
            DBMS_SQL.DEFINE_ARRAY(l_CursorID, 5, l_varchar_hazClass_tab,      100, 0);
            DBMS_SQL.DEFINE_ARRAY(l_CursorID, 6, l_num_orgId_tab,             100, 0);
            DBMS_SQL.DEFINE_ARRAY(l_CursorID, 7, l_num_srcOrgId_tab,          100, 0);
            DBMS_SQL.DEFINE_ARRAY(l_CursorID, 8, l_varchar_ItmType_tab,       100, 0);
            DBMS_SQL.DEFINE_ARRAY(l_CursorID, 9, l_varchar_UOM_tab,           100, 0);
            DBMS_SQL.DEFINE_ARRAY(l_CursorID, 10, l_num_itmVal_tab,           100, 0);
            DBMS_SQL.DEFINE_ARRAY(l_CursorID, 11, l_varchar_Curr_tab,         100, 0);
            DBMS_SQL.DEFINE_ARRAY(l_CursorID, 12, l_varchar_Coun_tab,       100, 0);
            DBMS_SQL.DEFINE_ARRAY(l_CursorID, 13, l_varchar_Attrib1_tab,      100, 0);
            DBMS_SQL.DEFINE_ARRAY(l_CursorID, 14, l_varchar_Attrib2_tab,      100, 0);
            DBMS_SQL.DEFINE_ARRAY(l_CursorID, 15, l_varchar_Attrib3_tab,      100, 0);
            DBMS_SQL.DEFINE_ARRAY(l_CursorID, 16, l_varchar_Attrib4_tab,      100, 0);
            DBMS_SQL.DEFINE_ARRAY(l_CursorID, 17, l_varchar_Attrib5_tab,      100, 0);
            DBMS_SQL.DEFINE_ARRAY(l_CursorID, 18, l_varchar_Attrib6_tab,      100, 0);
            DBMS_SQL.DEFINE_ARRAY(l_CursorID, 19, l_varchar_Attrib7_tab,      100, 0);
            DBMS_SQL.DEFINE_ARRAY(l_CursorID, 20, l_varchar_Attrib8_tab,      100, 0);
            DBMS_SQL.DEFINE_ARRAY(l_CursorID, 21, l_varchar_Attrib9_tab,      100, 0);
            DBMS_SQL.DEFINE_ARRAY(l_CursorID, 22, l_varchar_Attrib10_tab,     100, 0);
            DBMS_SQL.DEFINE_ARRAY(l_CursorID, 23, l_varchar_Attrib11_tab,     100, 0);
            DBMS_SQL.DEFINE_ARRAY(l_CursorID, 24, l_varchar_Attrib12_tab,     100, 0);
            DBMS_SQL.DEFINE_ARRAY(l_CursorID, 25, l_varchar_Attrib13_tab,     100, 0);
            DBMS_SQL.DEFINE_ARRAY(l_CursorID, 26, l_varchar_Attrib14_tab,     100, 0);
            DBMS_SQL.DEFINE_ARRAY(l_CursorID, 27, l_varchar_Attrib15_tab,     100, 0);
            DBMS_SQL.DEFINE_ARRAY(l_CursorID, 28, l_num_Operunit_tab ,        100, 0);

            --
            -- Debug Statements
            --
            IF l_debug_on THEN
                WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit WSH_ITM_QUERY_CUSTOM.BIND_VALUES',WSH_DEBUG_SV.C_PROC_LEVEL);
            END IF;
            --
            WSH_ITM_QUERY_CUSTOM.BIND_VALUES(l_Item_Table,l_CursorID);


            IF l_debug_on THEN
                WSH_DEBUG_SV.LOGMSG (l_module_name,'Successfull bind values',WSH_DEBUG_SV.C_STMT_LEVEL);
            END IF;

            l_ignore := DBMS_SQL.EXECUTE(l_CursorID);

            --Bulk Collect customized SQL
            LOOP
                    l_ignore := DBMS_SQL.FETCH_ROWS(l_CursorID);

                    DBMS_SQL.COLUMN_VALUE(l_CursorID, 1, l_num_invItem_tab);
                    DBMS_SQL.COLUMN_VALUE(l_CursorID, 2, l_varchar_PrdCode_tab);
                    DBMS_SQL.COLUMN_VALUE(l_CursorID, 3, l_varchar_Desc_tab);
                    DBMS_SQL.COLUMN_VALUE(l_CursorID, 4, l_varchar_LongDesc_tab);
                    DBMS_SQL.COLUMN_VALUE(l_CursorID, 5, l_varchar_hazClass_tab);
                    DBMS_SQL.COLUMN_VALUE(l_CursorID, 6, l_num_orgId_tab);
                    DBMS_SQL.COLUMN_VALUE(l_CursorID, 7, l_num_srcOrgId_tab);
                    DBMS_SQL.COLUMN_VALUE(l_CursorID, 8, l_varchar_ItmType_tab);
                    DBMS_SQL.COLUMN_VALUE(l_CursorID, 9, l_varchar_UOM_tab);
                    DBMS_SQL.COLUMN_VALUE(l_CursorID, 10, l_num_itmVal_tab);
                    DBMS_SQL.COLUMN_VALUE(l_CursorID, 11, l_varchar_Curr_tab);
                    DBMS_SQL.COLUMN_VALUE(l_CursorID, 12, l_varchar_Coun_tab);
                    DBMS_SQL.COLUMN_VALUE(l_CursorID, 13, l_varchar_Attrib1_tab);
                    DBMS_SQL.COLUMN_VALUE(l_CursorID, 14, l_varchar_Attrib2_tab);
                    DBMS_SQL.COLUMN_VALUE(l_CursorID, 15, l_varchar_Attrib3_tab);
                    DBMS_SQL.COLUMN_VALUE(l_CursorID, 16, l_varchar_Attrib4_tab);
                    DBMS_SQL.COLUMN_VALUE(l_CursorID, 17, l_varchar_Attrib5_tab);
                    DBMS_SQL.COLUMN_VALUE(l_CursorID, 18, l_varchar_Attrib6_tab);
                    DBMS_SQL.COLUMN_VALUE(l_CursorID, 19, l_varchar_Attrib7_tab);
                    DBMS_SQL.COLUMN_VALUE(l_CursorID, 20, l_varchar_Attrib8_tab);
                    DBMS_SQL.COLUMN_VALUE(l_CursorID, 21, l_varchar_Attrib9_tab);
                    DBMS_SQL.COLUMN_VALUE(l_CursorID, 22, l_varchar_Attrib10_tab);
                    DBMS_SQL.COLUMN_VALUE(l_CursorID, 23, l_varchar_Attrib11_tab);
                    DBMS_SQL.COLUMN_VALUE(l_CursorID, 24, l_varchar_Attrib12_tab);
                    DBMS_SQL.COLUMN_VALUE(l_CursorID, 25, l_varchar_Attrib13_tab);
                    DBMS_SQL.COLUMN_VALUE(l_CursorID, 26, l_varchar_Attrib14_tab);
                    DBMS_SQL.COLUMN_VALUE(l_CursorID, 27, l_varchar_Attrib15_tab);
                    DBMS_SQL.COLUMN_VALUE(l_CursorID, 28, l_num_Operunit_tab );
                    EXIT WHEN l_ignore <> 100;
            END LOOP;
            DBMS_SQL.CLOSE_CURSOR(l_CursorID);

            IF l_debug_on THEN
                WSH_DEBUG_SV.LOG (l_module_name, 'Number of Items queried: ' , l_num_invItem_tab.COUNT,WSH_DEBUG_SV.C_STMT_LEVEL);
            END IF;


            IF l_num_invItem_tab.COUNT <> 0 THEN
                --Bulk Insert into Interface Tables Appropriately
                FOR i in l_num_invItem_tab.FIRST..l_num_invItem_tab.LAST
                LOOP
                    --Check if New Item
                    IF l_num_invItem_tab(i) <> l_tempInvItem THEN
                        l_tempInvItem := l_num_invItem_tab(i);
                        --Create a new Request Control Seq
                        select WSH_ITM_REQUEST_CONTROL_S.NEXTVAL
                        into
                        l_num_ReqCtrl_tab(l_num_ReqCtrl_tab.COUNT + 1)
                        from dual;

                        --Save Item ID in RC Record
                        l_num_invItemID_tab(l_num_invItemID_tab.COUNT+1) := l_tempInvItem;

                    END IF;
                    --Saving Request Control for Child WSH_ITM_ITEM Table
                    l_num_ItmReqCtrl_tab(i) := l_num_ReqCtrl_tab(l_num_ReqCtrl_tab.COUNT);
                END LOOP;

				--Getting the Base Language into the variable
				SELECT LANGUAGE_CODE INTO l_LanguageCode FROM
					FND_LANGUAGES WHERE
					INSTALLED_FLAG = 'B';
				IF l_debug_on THEN
					WSH_DEBUG_SV.LOG (l_module_name, 'Base Language : ', l_LanguageCode, WSH_DEBUG_SV.C_STMT_LEVEL);
				END IF;

                IF l_debug_on THEN
                            WSH_DEBUG_SV.LOG (l_module_name, 'Number of Request Controls to be inserted : ' , l_num_ReqCtrl_tab.COUNT,WSH_DEBUG_SV.C_STMT_LEVEL);
                END IF;

                --Bulk Insert to Request Control Table
		--ApplicationID = 702 (Bill of Materials)
                FORALL i IN l_num_ReqCtrl_tab.FIRST..l_num_ReqCtrl_tab.LAST
                    INSERT INTO WSH_ITM_REQUEST_CONTROL(
                        REQUEST_CONTROL_ID,
                        APPLICATION_ID,
                        PROCESS_FLAG,
                        SERVICE_TYPE_CODE,
                        ORIGINAL_SYSTEM_REFERENCE,
                        LANGUAGE_CODE,
                        LAST_UPDATE_DATE,
                        LAST_UPDATED_BY,
                        CREATION_DATE,
                        CREATED_BY,
                        LAST_UPDATE_LOGIN
                    )
                    VALUES(
                        l_num_ReqCtrl_tab(i),
                        702,
                        0,
                        'ITEM_SYNC',
                        l_num_invItemID_tab(i),
                        l_LanguageCode,
                        SYSDATE,
                        l_user_id,
                        SYSDATE,
                        l_user_id,
                        l_login_id
                    );

                IF l_debug_on THEN
                            WSH_DEBUG_SV.LOG (l_module_name, 'Number of Items to be inserted : ' , l_num_ItmReqCtrl_tab.COUNT,WSH_DEBUG_SV.C_STMT_LEVEL);
                END IF;

                --Bulk Insert into Items Table
                FORALL I IN l_num_ItmReqCtrl_tab.FIRST..l_num_ItmReqCtrl_tab.LAST
                    INSERT INTO WSH_ITM_ITEMS (
                        ITEM_ID,
                        REQUEST_CONTROL_ID,
                        INVENTORY_ITEM_ID,
                        ORGANIZATION_ID,
                        PRODUCT_CODE,
                        SRC_ORGANIZATION_ID,
                        DESCRIPTION,
                        LONG_DESCRIPTION,
                        HAZARD_CLASS,
                        ITEM_TYPE,
                        UNIT_OF_MEASURE,
                        ITEM_VALUE,
                        INCOMING_CURRENCY,
                        COUNTRY,
                        ATTRIBUTE1_VALUE,
                        ATTRIBUTE2_VALUE,
                        ATTRIBUTE3_VALUE,
                        ATTRIBUTE4_VALUE,
                        ATTRIBUTE5_VALUE,
                        ATTRIBUTE6_VALUE,
                        ATTRIBUTE7_VALUE,
                        ATTRIBUTE8_VALUE,
                        ATTRIBUTE9_VALUE,
                        ATTRIBUTE10_VALUE,
                        ATTRIBUTE11_VALUE,
                        ATTRIBUTE12_VALUE,
                        ATTRIBUTE13_VALUE,
                        ATTRIBUTE14_VALUE,
                        ATTRIBUTE15_VALUE,
                        LAST_UPDATE_DATE,
                        LAST_UPDATED_BY,
                        CREATION_DATE,
                        CREATED_BY,
                        LAST_UPDATE_LOGIN,
                        OPERATING_UNIT
                    )
                    VALUES(
                        WSH_ITM_ITEMS_S.NEXTVAL,
                        l_num_ItmReqCtrl_tab(i),
                        l_num_invItem_tab(i),
                        l_num_orgId_tab(i),
                        l_varchar_PrdCode_tab(i),
                        l_num_srcOrgId_tab(i),
                        l_varchar_Desc_tab(i),
                        l_varchar_LongDesc_tab(i),
                        l_varchar_hazClass_tab(i),
                        l_varchar_ItmType_tab(i),
                        l_varchar_UOM_tab(i),
                        l_num_itmVal_tab(i),
                        l_varchar_Curr_tab(i),
                        l_varchar_Coun_tab(i),
                        l_varchar_Attrib1_tab(i),
                        l_varchar_Attrib2_tab(i),
                        l_varchar_Attrib3_tab(i),
                        l_varchar_Attrib4_tab(i),
                        l_varchar_Attrib5_tab(i),
                        l_varchar_Attrib6_tab(i),
                        l_varchar_Attrib7_tab(i),
                        l_varchar_Attrib8_tab(i),
                        l_varchar_Attrib9_tab(i),
                        l_varchar_Attrib10_tab(i),
                        l_varchar_Attrib11_tab(i),
                        l_varchar_Attrib12_tab(i),
                        l_varchar_Attrib13_tab(i),
                        l_varchar_Attrib14_tab(i),
                        l_varchar_Attrib15_tab(i),
                        SYSDATE,
                        l_user_id,
                        SYSDATE,
                        l_user_id,
                        l_login_id,
                        l_num_Operunit_tab(i)
                    );
        END IF;

        --
        -- Debug Statements
        --
        IF l_debug_on THEN
            WSH_DEBUG_SV.pop(l_module_name);
        END IF;
        --

        EXCEPTION
            WHEN OTHERS THEN
                l_temp := FND_CONCURRENT.SET_COMPLETION_STATUS('ERROR','Error in  procedure WSH_ITM_CUSTOMIZE.POPULATE_DATA');
                errbuf := 'Error in  procedure WSH_ITM_CUSTOMIZE.POPULATE_DATA failed with unexpected error';
                retcode := '2';
                IF l_debug_on THEN
                    WSH_DEBUG_SV.logmsg(l_module_name,'The unexpected Error Code ' || SQLCODE || ' : ' || SQLERRM);
                    WSH_DEBUG_SV.pop(l_module_name);
                END IF;
    END POPULATE_DATA;
END WSH_ITM_ITEM_SYNC;

/
