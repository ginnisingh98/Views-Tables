--------------------------------------------------------
--  DDL for Package BOMDELEX
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."BOMDELEX" AUTHID CURRENT_USER AS
/* $Header: BOMDEXPS.pls 120.1 2005/06/21 04:44:14 appldev ship $ */
/*==========================================================================+
|   Copyright (c) 1993 Oracle Corporation Belmont, California, USA          |
|                          All rights reserved.                             |
+===========================================================================+
|                                                                           |
| File Name    : BOMDELES.pls                                               |
| DESCRIPTION  : This file is a packaged specification for deleting
|		 records from bom_explosions table where the rexplode flag
|		 is set to 1
| Parameters:   1 - top bill sequence id , 2-explosion type
|               error_code      error code
|               error_msg       error message
|History :
|23-JUN-03	Sangeetha	CREATED
+==========================================================================*/

PROCEDURE DELETE_BOM_EXPLOSIONS(
	ERRBUF                  IN OUT NOCOPY /* file.sql.39 change */ 	VARCHAR2,
	RETCODE                 IN OUT NOCOPY /* file.sql.39 change */ 	VARCHAR2,
	top_bill_seq_id         IN      Number  ,
        expl_type          	IN      Varchar2
        ) ;

PROCEDURE Get_Top_Bill(
	Item_Id 	 	 IN     NUMBER,
        Org_Id  	         IN     NUMBER,
        Alt_Bom_Desg		 IN	VARCHAR2,
        Return_Status    	 IN OUT NOCOPY /* file.sql.39 change */    VARCHAR2 ,
	Err_Buf		 	 IN OUT NOCOPY /* file.sql.39 change */ 	VARCHAR2
	);

END BOMDELEX;

 

/
