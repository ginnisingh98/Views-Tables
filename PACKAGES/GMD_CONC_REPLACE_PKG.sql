--------------------------------------------------------
--  DDL for Package GMD_CONC_REPLACE_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."GMD_CONC_REPLACE_PKG" AUTHID CURRENT_USER AS
/* $Header: GMDROPRS.pls 115.12 2004/07/04 02:22:14 txdaniel noship $ */


   P_last_update_date  Date   := SYSDATE;
   P_last_updated_by   NUMBER := FND_PROFILE.VALUE('USER_ID');
   P_last_update_login  NUMBER := FND_PROFILE.VALUE('LOGIN_ID');

   TYPE Search_Result_Rec IS RECORD (
    object_id            NUMBER
   ,object_name          VARCHAR2(240)
   ,object_vers          NUMBER
   ,object_desc          VARCHAR2(240)
   ,object_status_desc   VARCHAR2(240)
   ,object_select_ind    NUMBER
   ,object_status_code   VARCHAR2(240) );


  TYPE Search_Result_Tbl IS TABLE OF Search_Result_Rec INDEX BY BINARY_INTEGER;

  Procedure Populate_search_table(X_search_tbl OUT NOCOPY Search_Result_Tbl);

  PROCEDURE Mass_Replace_Operation ( err_buf           OUT NOCOPY VARCHAR2,
    	                             ret_code          OUT NOCOPY VARCHAR2,
                                     pConcurrent_id    IN  NUMBER DEFAULT NULL,
                                     pObject_type      IN  VARCHAR2,
                                     pReplace_type     IN  VARCHAR2,
                                     pOld_Name         IN  VARCHAR2,
                                     pNew_Name         IN  VARCHAR2,
                                     pOld_Version      IN  VARCHAR2 DEFAULT NULL,
                                     pNew_Version      IN  VARCHAR2 DEFAULT NULL,
                                     pScale_factor     IN  VARCHAR2 DEFAULT '1',
                                     pVersion_flag     IN  VARCHAR2 DEFAULT 'N',
                                     pCreate_Recipe    IN  NUMBER   DEFAULT 0
                  				   );

  PROCEDURE Validate_All_Replace_Rows( pObject_type    IN  VARCHAR2,
                                       pReplace_type   IN  VARCHAR2,
                                       pOld_Name       IN  VARCHAR2,
                                       pRows_Processed OUT NOCOPY NUMBER,
                                       x_return_status OUT NOCOPY VARCHAR2
                                       );
END GMD_CONC_REPLACE_PKG;

 

/
