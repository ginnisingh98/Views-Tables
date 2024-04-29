--------------------------------------------------------
--  DDL for Package CS_EST_APPLY_CONTRACT_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."CS_EST_APPLY_CONTRACT_PKG" AUTHID CURRENT_USER as
/* $Header: csxchcos.pls 120.2 2005/08/18 16:48:25 mviswana noship $ */


-- PROCEDURE to process all the interface records :
SUBTYPE ENT_CONTRACT_TAB IS OKS_ENTITLEMENTS_PUB.GET_CONTOP_TBL;

PROCEDURE Apply_Contract (
   p_coverage_id	   IN  NUMBER,
   p_coverage_txn_group_id IN  NUMBER,
   p_txn_billing_type_id   IN NUMBER,
   p_business_process_id   IN NUMBER,
   p_request_date          IN DATE,
   p_amount                IN NUMBER,
   p_discount_amount       OUT NOCOPY     NUMBER,
   X_RETURN_STATUS         OUT NOCOPY     VARCHAR2,
   X_MSG_COUNT             OUT NOCOPY     NUMBER,
   X_MSG_DATA              OUT NOCOPY     VARCHAR2);

--
--
PROCEDURE Update_Estimate_Details (
   p_Estimate_Detail_Id  IN  NUMBER,
   p_discount_price      IN  NUMBER);

TYPE cont_rec_type IS RECORD
   (COVERAGE_ID   	OKS_ENT_COVERAGES_V.ACTUAL_COVERAGE_ID%type,
    COVERAGE_NAME 	OKS_ENT_COVERAGES_V.COVERAGE_NAME%type,
    COV_TXN_GROUP_ID  OKS_ENT_TXN_GROUPS_V.TXN_GROUP_ID%type);

TYPE CONTTAB IS TABLE OF cont_rec_type INDEX BY BINARY_INTEGER;

PROCEDURE GET_CONTRACT_LINES(
   P_API_VERSION		IN NUMBER ,
   P_INIT_MSG_LIST		IN VARCHAR2,
   P_CUSTOMER_ID		IN NUMBER,
   P_CUSTOMER_ACCOUNT_ID	IN NUMBER,
   P_SERVICE_LINE_ID		IN NUMBER DEFAULT NULL,
   P_CUSTOMER_PRODUCT_ID	IN NUMBER DEFAULT NULL,
   p_system_id			IN number default null, -- Fix bug 3040124
   p_inventory_item_id		IN number default null, -- Fix bug 3040124
   P_REQUEST_DATE		IN DATE,
   P_BUSINESS_PROCESS_ID	IN NUMBER DEFAULT NULL,
   P_CALC_RESPTIME_FLAG		IN VARCHAR2 DEFAULT NULL,
   P_VALIDATE_FLAG		IN VARCHAR2,
   X_ENT_CONTRACTS		OUT NOCOPY ENT_CONTRACT_TAB,
   X_RETURN_STATUS		OUT NOCOPY VARCHAR2,
   X_MSG_COUNT			OUT NOCOPY NUMBER,
   X_MSG_DATA			OUT NOCOPY VARCHAR2);

end CS_Est_Apply_Contract_PKG;

 

/
