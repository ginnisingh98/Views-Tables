--------------------------------------------------------
--  DDL for Package Body CS_SERVICE_AVAIL_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."CS_SERVICE_AVAIL_PKG" AS
/*$Header: csxsesab.pls 115.1 99/07/16 09:08:40 porting ship  $*/

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
		            p_exists_flag		IN OUT VARCHAR2) IS
 CURSOR Check_Exists IS
 SELECT 'x'
 FROM   cs_service_availability
 WHERE  Service_Inventory_Item_Id	=	p_service_inv_item_id
   AND nvl(Inventory_Item_Id, -1)	=	nvl(p_avail_inv_item_id, -1)
   AND nvl(Item_Manufacturing_Org_Id, -1) =     nvl(p_manu_org_id, -1)
   AND nvl(Customer_Id, -1)		=	nvl(p_customer_id, -1)
   AND nvl(Revision_Low, -1)		=	nvl(p_revision_low, -1)
   AND nvl(Revision_High, -1)		=	nvl(p_revision_high, -1)
   AND trunc(nvl(start_date_active, p_l_low_dt))
   			             = trunc(nvl(p_avail_start_date, p_l_low_dt))
   AND trunc(nvl(end_date_active, p_l_high_dt))
				       = trunc(nvl(p_avail_end_date, p_l_high_dt))
   AND Service_Available_Flag       =     p_serv_avail_flag
   AND Service_Availability_Id        <>     nvl(p_service_avail_id,  '-1');
   Temp_Check VARCHAR2(1);
BEGIN
  OPEN Check_Exists;
  FETCH Check_Exists
   INTO temp_Check;
  IF Check_Exists%Found THEN
    p_exists_flag := 'Y';
  ELSE
    p_exists_flag := 'N';
  END IF;
  CLOSE Check_Exists;

END Duplicate_Check;
END CS_Service_Avail_Pkg;

/
