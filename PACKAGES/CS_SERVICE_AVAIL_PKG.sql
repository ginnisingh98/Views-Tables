--------------------------------------------------------
--  DDL for Package CS_SERVICE_AVAIL_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."CS_SERVICE_AVAIL_PKG" AUTHID CURRENT_USER AS
/*$Header: csxsesas.pls 115.0 99/07/16 09:08:44 porting ship $*/

PROCEDURE Duplicate_Check ( p_Event 			IN VARCHAR2,
		            p_Service_Inv_Item_Id	IN NUMBER,
		            p_Avail_Inv_Item_Id		IN NUMBER,
		            p_Manu_Org_Id		IN NUMBER,
		            p_customer_Id		IN NUMBER,
		            p_revision_low		IN NUMBER,
		            p_revision_high		IN NUMBER,
		            p_avail_start_date		IN DATE,
		            p_avail_end_date		IN DATE,
		            p_l_low_dt		        IN DATE,
		            p_l_high_dt		        IN DATE,
		            p_serv_avail_flag		IN VARCHAR2,
		            p_service_avail_id		IN NUMBER,
		            p_exists_flag		IN OUT VARCHAR2) ;
END Cs_Service_Avail_Pkg;

 

/
