--------------------------------------------------------
--  DDL for Package HXC_ALIAS_TYPES_CHKS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."HXC_ALIAS_TYPES_CHKS" AUTHID CURRENT_USER as
/* $Header: hxcaltchk.pkh 115.2 2002/11/27 19:53:06 jdupont noship $ */
p_X_SELECT_WC varchar2(3200);
p_X_SELECT_NC varchar2(3200);
p_X_MAPPING_CODE varchar2(100);
p_X_SUCCESS number;
G_MISS_CHAR   	CONSTANT    VARCHAR2(1) := chr(0);
c number;
p_id number(10);
p_name  varchar2(60);
rec_tab dbms_sql.desc_tab;
col_cnt number;
invalid_sql EXCEPTION;
PROCEDURE Check_Sql(X_P_ID IN NUMBER,
                    P_SQL_WC OUT NOCOPY VARCHAR2,
		    P_SQL_NC OUT NOCOPY VARCHAR2,
		    P_RET OUT NOCOPY VARCHAR2);
PROCEDURE get_id_string (X_P_ID IN NUMBER,
                    P_SQL_WC OUT NOCOPY VARCHAR2,
                    P_SQL_NC OUT NOCOPY VARCHAR2,
                    P_RET OUT NOCOPY VARCHAR2);
END HXC_ALIAS_TYPES_CHKS;

 

/
