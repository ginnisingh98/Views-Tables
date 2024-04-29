--------------------------------------------------------
--  DDL for Package FII_AR_TRX_DIST_F_D
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."FII_AR_TRX_DIST_F_D" AUTHID CURRENT_USER AS
/* $Header: FIIAR07S.pls 120.1 2005/06/07 11:56:24 sgautam noship $ */

---------------------------------------------------
-- PROCEDURE DROP_TABLE
---------------------------------------------------
PROCEDURE Init(p_instance_code IN VARCHAR2);
PROCEDURE Drop_Table (p_table_name in VARCHAR2);
PROCEDURE Create_OLTP_TRX_TMP_TABLE;
PROCEDURE Populate_OLTP_TRX_TMP_TABLE;
PROCEDURE Create_EDW_TRX_TMP_TABLE;
PROCEDURE Find_Extra_Trx_EDW;
PROCEDURE Count_Extra_Trx_EDW (l_count OUT NOCOPY /* file.sql.39 change */ NUMBER);
PROCEDURE  Insert_Staging (l_row OUT NOCOPY /* file.sql.39 change */ NUMBER);

End FII_AR_TRX_DIST_F_D;

 

/
