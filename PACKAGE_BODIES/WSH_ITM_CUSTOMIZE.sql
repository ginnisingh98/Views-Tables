--------------------------------------------------------
--  DDL for Package Body WSH_ITM_CUSTOMIZE
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."WSH_ITM_CUSTOMIZE" AS
/* $Header: WSHITCCB.pls 115.1 2003/06/19 00:06:02 sperera noship $ */


        G_PKG_NAME CONSTANT VARCHAR2(50) := 'WSH_ITM_CUSTOMIZE';


         /*===========================================================================+
	 | PROCEDURE                                                                 |
	 |              ALTER_ITEM_SYNC                                              |
	 |                                                                           |
	 | DESCRIPTION                                                               |
	 |              This is a stub procedure which is called when the Item       |
	 |              Synchronization Concurrent program is launched.              |
	 |              Additional filter conditions can be appended usning this     |
	 |              procedure.                                                   |
	 |              							     |
 	 +===========================================================================*/


        PROCEDURE ALTER_ITEM_SYNC(p_Table IN OUT NOCOPY WSH_ITM_QUERY_CUSTOM.g_CondnValTableType) IS
                l_Item_Condn1Tab        WSH_ITM_QUERY_CUSTOM.g_ValueTableType;

                --
                l_debug_on BOOLEAN;
                --
                l_module_name CONSTANT VARCHAR2(100) := 'wsh.plsql.' || G_PKG_NAME || '.' || 'ALTER_ITEM_SYNC';
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
                END IF;
                --
                NULL;
                --Adding a Condition
                --l_Item_Condn1Tab(1).g_number_val := 1;
                --l_Item_Condn1Tab(1).g_Bind_Literal := ':b_org_id';
                --WSH_ITM_QUERY_CUSTOM.ADD_CONDITION(p_Table, ' AND B.ORG_ID = :b_org_id', l_Item_Condn1Tab, 'NUMBER');

                --Editing a Condition
                --l_Item_Condn1Tab(1).g_number_val := 208;
                --WSH_ITM_QUERY_CUSTOM.EDIT_CONDITION(p_Table,' AND B.ORG_ID = :b_org_id',  ' AND B.ORG_ID = :b_org_id', l_Item_Condn1Tab, 'NUMBER');

                --Deleting a Condition
                --WSH_ITM_QUERY_CUSTOM.DEL_CONDITION(p_Table, ' AND B.ORG_ID = :b_org_id');
                --
                -- Debug Statements
                --
                IF l_debug_on THEN
                    WSH_DEBUG_SV.pop(l_module_name);
                END IF;
                --
        END;


         /*===========================================================================+
	 | PROCEDURE                                                                 |
	 |              ALTER_PARTY_SYNC                                             |
	 |                                                                           |
	 | DESCRIPTION                                                               |
	 |              This is a stub procedure which is called when the Party      |
	 |              Synchronization Concurrent program is launched.              |
	 |              Additional filter conditions can be appended usning this     |
	 |              procedure.                                                   |
	 |                                                                           |
 	 +===========================================================================*/

        PROCEDURE ALTER_PARTY_SYNC(p_Table IN OUT NOCOPY WSH_ITM_QUERY_CUSTOM.g_CondnValTableType) IS

		--
		l_debug_on BOOLEAN;
		--
		l_module_name CONSTANT VARCHAR2(100) := 'wsh.plsql.' || G_PKG_NAME || '.' || 'ALTER_PARTY_SYNC';
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
                END IF;
                --
                NULL;
                --
                -- Debug Statements
                --
                IF l_debug_on THEN
                    WSH_DEBUG_SV.pop(l_module_name);
                END IF;
                --
        END;



       --
       -- PROCEDURE   ALTER_DELIVERY_MARK
       -- DESCRIPTION This is a stub procedure that can be modified by the customer to
       --             specify the deliveries that require ITM compliance screening by
       --             appending filter conditions.


       PROCEDURE ALTER_DELIVERY_MARK (p_Table IN OUT NOCOPY WSH_ITM_QUERY_CUSTOM.g_CondnValTableType,
                                      x_return_status OUT NOCOPY VARCHAR2) IS

                l_Item_Condn1Tab        WSH_ITM_QUERY_CUSTOM.g_ValueTableType;
		--
		l_debug_on BOOLEAN;
		--
		l_module_name CONSTANT VARCHAR2(100) := 'wsh.plsql.' || G_PKG_NAME || '.' || 'ALTER_DELIVERY_MARK';
		--


       BEGIN
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
                END IF;
                NULL;

                --Adding a Condition
                --l_Item_Condn1Tab(1).g_number_val := 1;
                --l_Item_Condn1Tab(1).g_Bind_Literal := ':b_org_id';
                --WSH_ITM_QUERY_CUSTOM.ADD_CONDITION(p_Table, ' AND WND.ORGANIZATION_ID = :b_org_id', l_Item_Condn1Tab, 'NUMBER');

                --Editing a Condition
                --l_Item_Condn1Tab(1).g_number_val := 208;
                --WSH_ITM_QUERY_CUSTOM.EDIT_CONDITION(p_Table,' AND WND.ORGANIZATION_ID = :b_org_id',  ' AND WND.ORG_ID = :b_org_id', l_Item_Condn1Tab, 'NUMBER');
                --Deleting a Condition
                --WSH_ITM_QUERY_CUSTOM.DEL_CONDITION(p_Table, ' AND WND.ORGANIZATION_ID = :b_org_id');

                x_return_status := WSH_UTIL_CORE.G_RET_STS_SUCCESS;

                IF l_debug_on THEN
                    WSH_DEBUG_SV.pop(l_module_name);
                END IF;



       EXCEPTION
       WHEN Others THEN
               wsh_util_core.default_handler('WSH_ITM_CUSTOMIZE.ALTER_DELIVERY_MARK');
               x_return_status := WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR;

               IF l_debug_on THEN
                   WSH_DEBUG_SV.logmsg(l_module_name,'Unexpected error has occured. Oracle error message is '|| SQLERRM,WSH_DEBUG_SV.C_UNEXPEC_ERR_LEVEL);
                   WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:OTHERS');
               END IF;

       END ALTER_DELIVERY_MARK;




END;

/
