--------------------------------------------------------
--  DDL for Package CS_CSXSVODS_CHECK_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."CS_CSXSVODS_CHECK_PKG" AUTHID CURRENT_USER AS
/*$Header: cssvcces.pls 115.1 99/07/16 09:02:33 porting shi $*/

PROCEDURE Service_Check_Overlap (p_overlap_flag IN OUT VARCHAR2,
                                                   p_inventory_item_id NUMBER,
                                                   p_manu_org_id  NUMBER,
					           p_customer_product_id NUMBER,
                                                   p_start_date   DATE,
                                                   p_end_date     DATE) ;

/* Procedure to check whether the current service is being processed in Order Entry */
PROCEDURE Service_Check_Duplicate(p_duplicate_flag IN OUT VARCHAR2,
                                  p_inventory_item_id NUMBER,
                                  p_customer_product_id NUMBER);



PROCEDURE Service_Check_Duplicate_Soline(p_duplicate_flag IN OUT VARCHAR2,
                                   p_inventory_item_id NUMBER,
                                   p_customer_product_id NUMBER);




PROCEDURE CS_Check_Service_ELigibility (
                            p_cp_eligibility                IN OUT VARCHAR2,
                            p_ord_serv_inv_item_id          IN     NUMBER,
                            p_control_manu_org_id           IN     NUMBER,
                            p_cp_inventory_item_id	    IN     NUMBER,
                            p_cp_customer_id	            IN     NUMBER,
                            p_cp_revision	            IN     VARCHAR2,
                            p_order_renew_date		    IN     DATE) ;

PROCEDURE Check_Price_List(check_value IN OUT VARCHAR2,
			   p_price_list_id       IN NUMBER,
                           service_inv_item_id IN NUMBER,
                           uom_code            IN VARCHAR2) ;

PROCEDURE Calculate_service_duration (Service_duration   IN OUT NUMBER,
                                      Service_Start_Date IN DATE,
                                      Service_End_Date   IN DATE,
                                      Inventory_Item_ID  IN NUMBER,
                                      Period_Code        IN VARCHAR2,
                                      Day_UOM_Code       IN VARCHAR2 ,
                                      Rounded_Flag       IN OUT VARCHAR2,
				      Order_Duration     IN NUMBER);
PROCEDURE create_cust_interact_new_ord(control_user_id       NUMBER,
							    parent_interaction_id VARCHAR2,
							    cp_last_update_login  NUMBER,
							    cp_bill_to_contact_id NUMBER,
							    order_customer_id     NUMBER,
					 		    return_status         OUT VARCHAR2,
							    return_msg            OUT VARCHAR2);

PROCEDURE create_cust_interact_renew(control_user_id       NUMBER,
  							  cp_cp_service_id      NUMBER,
							  parent_interaction_id VARCHAR2,
							  cp_last_update_login  NUMBER,
							  cp_bill_to_contact_id NUMBER,
							  cp_customer_id        IN  NUMBER,
						       return_status         OUT VARCHAR2,
						   	  return_msg            OUT VARCHAR2);

End CS_CSXSVODS_Check_Pkg;

 

/
