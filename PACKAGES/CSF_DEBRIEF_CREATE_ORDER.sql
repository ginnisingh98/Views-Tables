--------------------------------------------------------
--  DDL for Package CSF_DEBRIEF_CREATE_ORDER
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."CSF_DEBRIEF_CREATE_ORDER" AUTHID CURRENT_USER as
--  $Header: csfpodcs.pls 115.6.1157.3 2002/05/08 11:57:57 pkm ship     $
-- Start of Comments
-- Package name     : CSF_DEBRIEF_CREATE_ORDER
-- Purpose          :
-- History          : Modified by Ildiko Balint 04-AUG-2000
-- NOTE             :
-- End of Comments
-- Default number of records fetch per call

G_DEFAULT_NUM_REC_FETCH  NUMBER := 30;
G_USER_ID         NUMBER := FND_GLOBAL.USER_ID;
G_LOGIN_ID        NUMBER := FND_GLOBAL.CONC_LOGIN_ID;

PROCEDURE CREATE_ORDER (
P_CURRENCY_CODE	      IN VARCHAR2,
P_PARTY_ID		      IN NUMBER,
P_INVENTORY_ITEM_ID	  IN NUMBER,
P_QUANTITY 		      IN NUMBER,
P_UOM_CODE 		      IN VARCHAR2,
P_ORDER_TYPE_CODE	  IN VARCHAR2,
P_quote_header_id     IN NUMBER,
P_order_type_id       IN NUMBER,
P_price_list_id	      IN NUMBER,
P_employee_person_id  IN number,
P_cust_account_id     IN NUMBER,
P_shipment_id         IN NUMBER,
X_ORDER_HEADER_ID     OUT  NUMBER,
X_Return_Status       OUT  VARCHAR2,
X_Msg_Count           OUT  NUMBER,
X_Msg_Data            OUT  VARCHAR2
);

end CSF_DEBRIEF_CREATE_ORDER;


 

/
