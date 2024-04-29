--------------------------------------------------------
--  DDL for Package Body WSH_ITM_QUERY_CUSTOM
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."WSH_ITM_QUERY_CUSTOM" AS
/*$Header: WSHITQCB.pls 115.1 2003/12/04 11:27:06 shravisa noship $ */

        --Private method for searching with Condn String
        --
        G_PKG_NAME CONSTANT VARCHAR2(50) := 'WSH_ITM_QUERY_CUSTOM';
        --
        PROCEDURE FIND_INDEX(p_Table            IN              g_CondnValTableType,
                             p_FilerCond        IN              VARCHAR2,
                             p_index            OUT     NOCOPY  NUMBER) IS
	     --
	     l_debug_on BOOLEAN;
	     --
	     l_module_name CONSTANT VARCHAR2(100) := 'wsh.plsql.' || G_PKG_NAME || '.' || 'FIND_INDEX';
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
                    WSH_DEBUG_SV.log(l_module_name,'P_FILERCOND',P_FILERCOND);
                END IF;
                --
                FOR i in 1..p_Table.count
                LOOP
                        IF p_Table(i).g_Condn_Qry = p_FilerCond THEN
                                p_index := i;
                                EXIT;
                        END IF;
                END LOOP;
                --
                -- Debug Statements
                --
                IF l_debug_on THEN
                    WSH_DEBUG_SV.pop(l_module_name);
                END IF;
                --
        END;

        --Private method for edit/add element in Table with Value Object, Value Type
        PROCEDURE SET_DATA_INDEX(p_Table        IN OUT  NOCOPY  g_CondnValTableType,
                                 p_index        IN              NUMBER,
                                 p_NewFilerCond IN              VARCHAR2,
                                 p_NewValue     IN              g_ValueTableType,
                                 p_NewValueType IN              VARCHAR2) IS
                                 --
                                 l_debug_on BOOLEAN;
                                 --
                                 l_module_name CONSTANT VARCHAR2(100) := 'wsh.plsql.' || G_PKG_NAME || '.' || 'SET_DATA_INDEX';
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
                    WSH_DEBUG_SV.log(l_module_name,'P_INDEX',P_INDEX);
                    WSH_DEBUG_SV.log(l_module_name,'P_NEWFILERCOND',P_NEWFILERCOND);
                    WSH_DEBUG_SV.log(l_module_name,'P_NEWVALUETYPE',P_NEWVALUETYPE);
                END IF;
                --
                p_Table(p_index).g_Condn_Qry	:= p_NewFilerCond;
                --Modified by AJPRABHA for 8.1 Compatibility
		--p_Table(p_index).g_Val_Table	:= p_NewValue;
		p_Table(p_index).g_number_val	:= p_NewValue(1).g_number_val;
		p_Table(p_index).g_varchar_val	:= p_NewValue(1).g_varchar_val;
		p_Table(p_index).g_date_val	:= p_NewValue(1).g_date_val;
		p_Table(p_index).g_Bind_Literal := p_NewValue(1).g_Bind_Literal;

                p_Table(p_index).g_Value_Type := p_NewValueType;
                --
                -- Debug Statements
                --
                IF l_debug_on THEN
                    WSH_DEBUG_SV.pop(l_module_name);
                END IF;
                --
        END;

        --Add Condition, with values
	/*===========================================================================+
	| PROCEDURE                                                                 |
	|              ADD_CONDITION                                                |
	|                                                                           |
	| DESCRIPTION                                                               |
	|              This procedure adds the filter condition p_FilterCond        |
	|              to the PL/SQL table p_Table. p_Vale is the list of bind      |
	|              variables present in the condition p_FilterCond              |
	|              p_ValueType indicates the datatype of the bind variables     |
	+===========================================================================*/


        PROCEDURE ADD_CONDITION(p_Table         IN OUT  NOCOPY  g_CondnValTableType,
                                p_FilerCond     IN              VARCHAR2,
                                p_Value         IN              g_ValueTableType,
                                p_Value_Type    IN              VARCHAR2) IS
                l_index         NUMBER;
                --
                l_debug_on BOOLEAN;
                --
                l_module_name CONSTANT VARCHAR2(100) := 'wsh.plsql.' || G_PKG_NAME || '.' || 'ADD_CONDITION';
                --
        BEGIN
                --Get length of the table and add in the end.
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
                    WSH_DEBUG_SV.log(l_module_name,'P_FILERCOND',P_FILERCOND);
                    WSH_DEBUG_SV.log(l_module_name,'P_VALUE_TYPE',P_VALUE_TYPE);
                END IF;
                --
                l_index := p_Table.count + 1;
                --Add Data to index
                SET_DATA_INDEX(p_Table, l_index, p_FilerCond, p_Value, p_Value_Type);

		--
		-- Debug Statements
		--
		IF l_debug_on THEN
		    WSH_DEBUG_SV.pop(l_module_name);
		END IF;
		--
        END ADD_CONDITION;

    --Add Condition, with values
	/*===========================================================================+
	| PROCEDURE                                                                 |
	|              ADD_CONDITION                                                |
	|                                                                           |
	| DESCRIPTION                                                               |
	|              This procedure adds the filter condition p_FilterCond        |
	|              to the PL/SQL table p_Table. This procedure is to be         |
	|              called if the filter condition does not have any bind        |
	|              bind variables.						    |
	+===========================================================================*/


        --Add condition without values
        PROCEDURE ADD_CONDITION(p_Table         IN OUT  NOCOPY  g_CondnValTableType,
                                p_FilerCond     IN              VARCHAR2) IS
                l_index         NUMBER;
                --
                l_debug_on BOOLEAN;
                --
                l_module_name CONSTANT VARCHAR2(100) := 'wsh.plsql.' || G_PKG_NAME || '.' || 'ADD_CONDITION';
                --
        BEGIN
                --Get length of the table and add in the end.
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
                    WSH_DEBUG_SV.log(l_module_name,'P_FILERCOND',P_FILERCOND);
                END IF;
                --
                l_index := p_Table.count + 1;
                --Add Data to index
                p_Table(l_index).g_Condn_Qry := p_FilerCond;
                --
                -- Debug Statements
                --
                IF l_debug_on THEN
                    WSH_DEBUG_SV.pop(l_module_name);
                END IF;
                --
        END ADD_CONDITION;

        --



        PROCEDURE DEL_CONDITION(p_Table         IN OUT  NOCOPY  g_CondnValTableType,
                                p_FilerCond     IN              VARCHAR2) IS
                l_FoundIndex    NUMBER;
                p_NewTable      g_CondnValTableType;
                --
                l_debug_on BOOLEAN;
                --
                l_module_name CONSTANT VARCHAR2(100) := 'wsh.plsql.' || G_PKG_NAME || '.' || 'DEL_CONDITION';
                --
        BEGIN
                --Looping thru the Table to get the index of search result
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
                    WSH_DEBUG_SV.log(l_module_name,'P_FILERCOND',P_FILERCOND);
                END IF;
                --
                FIND_INDEX(p_Table, p_FilerCond, l_FoundIndex);

                --Delete the Rec
                FOR i in 1..p_Table.count-1
                LOOP
                        IF i<l_FoundIndex THEN
                                p_NewTable(i) := p_Table(i);
                        ELSE
                                p_NewTable(i) := p_Table(i+1);
                        END IF;
                END LOOP;
                p_Table := p_NewTable;
                --
                -- Debug Statements
                --
                IF l_debug_on THEN
                    WSH_DEBUG_SV.pop(l_module_name);
                END IF;
                --
        END;




        PROCEDURE EDIT_CONDITION(p_Table        IN OUT  NOCOPY  g_CondnValTableType,
                                p_OldFilerCond  IN              VARCHAR2,
                                p_NewFilerCond  IN              VARCHAR2,
                                p_NewValue      IN              g_ValueTableType,
                                p_NewValueType  IN              VARCHAR2) IS
                l_FoundIndex    NUMBER;
                --
                l_debug_on BOOLEAN;
                --
                l_module_name CONSTANT VARCHAR2(100) := 'wsh.plsql.' || G_PKG_NAME || '.' || 'EDIT_CONDITION';
                --
        BEGIN
                --Looping thru the Table to get the index of search result
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
                    WSH_DEBUG_SV.log(l_module_name,'P_OLDFILERCOND',P_OLDFILERCOND);
                    WSH_DEBUG_SV.log(l_module_name,'P_NEWFILERCOND',P_NEWFILERCOND);
                    WSH_DEBUG_SV.log(l_module_name,'P_NEWVALUETYPE',P_NEWVALUETYPE);
                END IF;
                --
                FIND_INDEX(p_Table, p_OldFilerCond, l_FoundIndex);

                --Modifying the Found Record
                SET_DATA_INDEX(p_Table, l_FoundIndex, p_NewFilerCond, p_NewValue, p_NewValueType);
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
	|              BIND_VALUES                                                  |
	|                                                                           |
	| DESCRIPTION                                                               |
	|              This procedure does the binding of the values to the bind    |
	|              variables of the cursor p_CursorID using the data            |
	|              in the Cond table p_Table                                    |
	|                                                                           |
	+===========================================================================*/


        PROCEDURE BIND_VALUES (p_Table        IN    g_CondnValTableType,
        		       p_CursorID     IN    NUMBER) IS
                --
                l_debug_on BOOLEAN;
                --
                l_module_name CONSTANT VARCHAR2(100) := 'wsh.plsql.' || G_PKG_NAME || '.' || 'BIND_VALUES';
                --
        BEGIN
                --Looping thru the Table to get the index of search result
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
                    WSH_DEBUG_SV.log(l_module_name,'p_cursorId',p_cursorId);
                END IF;
                --


                FOR i IN 1..p_Table.COUNT
                LOOP
                        IF p_Table(i).g_Value_Type = 'NUMBER' THEN
			       IF l_debug_on THEN
					WSH_DEBUG_SV.LOG (l_module_name, 'Binding literal ',  p_Table(i).g_Bind_Literal, WSH_DEBUG_SV.C_STMT_LEVEL);
					WSH_DEBUG_SV.LOG (l_module_name, 'Binding Value ',  p_Table(i).g_number_val, WSH_DEBUG_SV.C_STMT_LEVEL);
				END IF;
				DBMS_SQL.BIND_VARIABLE(p_CursorID,p_Table(i).g_Bind_Literal, p_Table(i).g_number_val);
                        ELSIF p_Table(i).g_Value_Type = 'VARCHAR' THEN
			       IF l_debug_on THEN
					WSH_DEBUG_SV.LOG (l_module_name, 'Binding literal ',  p_Table(i).g_Bind_Literal, WSH_DEBUG_SV.C_STMT_LEVEL);
					WSH_DEBUG_SV.LOG (l_module_name, 'Binding Value ',  p_Table(i).g_varchar_val, WSH_DEBUG_SV.C_STMT_LEVEL);
				END IF;
				DBMS_SQL.BIND_VARIABLE(p_CursorID,p_Table(i).g_Bind_Literal, p_Table(i).g_varchar_val);
                        ELSIF p_Table(i).g_Value_Type = 'DATE' THEN
			       IF l_debug_on THEN
					WSH_DEBUG_SV.LOG (l_module_name, 'Binding literal ',  p_Table(i).g_Bind_Literal, WSH_DEBUG_SV.C_STMT_LEVEL);
					WSH_DEBUG_SV.LOG (l_module_name, 'Binding Value ',  p_Table(i).g_date_val, WSH_DEBUG_SV.C_STMT_LEVEL);
				END IF;
				DBMS_SQL.BIND_VARIABLE(p_CursorID,p_Table(i).g_Bind_Literal, p_Table(i).g_date_val);
                        END IF;
                END LOOP;
	END;
END;

/
