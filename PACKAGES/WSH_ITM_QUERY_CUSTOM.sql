--------------------------------------------------------
--  DDL for Package WSH_ITM_QUERY_CUSTOM
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."WSH_ITM_QUERY_CUSTOM" AUTHID CURRENT_USER AS
/* $Header: WSHITQCS.pls 120.0 2005/05/26 18:33:32 appldev noship $ */
        --Record Type that can store - NUMBER, VARCHAR2 or DATE
        -- either one at a time is permitted.
        TYPE g_ValueRecType IS RECORD(  g_number_val    NUMBER,
                                        g_varchar_val   VARCHAR2(360),
                                        g_date_val      DATE,
                                        g_Bind_Literal  VARCHAR2(100));

        --PL/SQL Table which stores the Values to be binded.
        -- This is required to handle IN and BETWEEN Clauses
        -- where there are multiple bind values per filter condition
        TYPE g_ValueTableType IS Table of g_ValueRecType INDEX BY BINARY_INTEGER;


        --g_Condn_Qry - Filter Condition
        --              e.g: ' AND B.ORG_ID = :value3'
        --                   ' AND B.ITEM_ID <= :value4'
	-- Depending on the type of the Value - g_number_val, g_varchar_val
	--	or g_date_val is populated.
	-- Appropriate value of g_Bind_Literal is used for binding.
        --g_Value_Type - Value Type - This could be either
        --                      VARCHAR2, NUMBER or DATE
        --Modified by AJPRABHA for 8.1 Compatibility
	TYPE g_CondnValRecType IS RECORD (g_Condn_Qry   VARCHAR2(1000),
                                          g_number_val    NUMBER,
                                          g_varchar_val   VARCHAR2(360),
                                          g_date_val      DATE,
                                          g_Bind_Literal  VARCHAR2(100),
                                          g_Value_Type    VARCHAR2(10));

        TYPE g_CondnValTableType IS Table of g_CondnValRecType INDEX BY BINARY_INTEGER;

        PROCEDURE ADD_CONDITION(p_Table         IN OUT  NOCOPY  g_CondnValTableType,
                                p_FilerCond     IN              VARCHAR2,
                                p_Value         IN              g_ValueTableType,
                                p_Value_Type    IN              VARCHAR2);

        PROCEDURE ADD_CONDITION(p_Table         IN OUT  NOCOPY  g_CondnValTableType,
                                p_FilerCond     IN              VARCHAR2);

        PROCEDURE DEL_CONDITION(p_Table         IN OUT  NOCOPY  g_CondnValTableType,
                                p_FilerCond     IN              VARCHAR2);

        PROCEDURE EDIT_CONDITION(p_Table        IN OUT  NOCOPY  g_CondnValTableType,
                                p_OldFilerCond  IN              VARCHAR2,
                                p_NewFilerCond  IN              VARCHAR2,
                                p_NewValue      IN              g_ValueTableType,
                                p_NewValueType  IN              VARCHAR2);

        PROCEDURE BIND_VALUES (p_Table        IN    g_CondnValTableType,
        		       p_CursorID     IN    NUMBER) ;


END;

 

/
