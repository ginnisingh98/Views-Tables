--------------------------------------------------------
--  DDL for Package ASO_SERVICE_CONTRACTS_INT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."ASO_SERVICE_CONTRACTS_INT" AUTHID CURRENT_USER as
/* $Header: asoiokss.pls 120.1 2005/06/29 12:34:20 appldev ship $ */
-- Start of Comments
-- Package name     : ASO_service_contracts_INT
-- Purpose          :
-- History          :
-- NOTE             :
-- End of Comments



--
--
-- Record types
--
--
--
--
-- API
--
--
--

TYPE CHECK_SERVICE_REC_TYPE Is RECORD
  (
		 product_item_id	Number
		,service_item_id	Number
		,customer_id	Number
		,product_revision	Varchar2(3)
		,request_date	  Date
  );
  TYPE AVAIL_SERVICE_REC_TYPE  Is RECORD
  (
		 product_item_id	Number
		,customer_id	Number
		,product_revision	Varchar2(3)
		,request_date	  Date
  );
  TYPE OKS_ORDER_SERVICE_REC_TYPE Is RECORD
  (
		service_item_id	Number
,		name			Varchar2(40)
,		Description		Varchar2(240)
,		Coverage_Template_Id Number
  );
  TYPE ORDER_SERVICE_REC_TYPE Is RECORD
  (
		service_item_id	Number
  );
  TYPE order_service_tbl_type Is TABLE OF ORDER_SERVICE_REC_TYPE Index by BINARY_INTEGER;

  TYPE oks_order_service_tbl_type Is TABLE OF OKS_ORDER_SERVICE_REC_TYPE Index by BINARY_INTEGER;

  Type War_rec_type IS RECORD (
--	Product_Item_Id	   		   Number,
        Service_item_id                    Number,
        service_name                       VARCHAR2(2000),
       -- service_name                       VARCHAR2(240),
        service_description                VARCHAR2(240),
--        Organiztion_id                     Number,
--        Status_code 		   Varchar2(20),
        Duration_Quantity		 Number,
        Duration_Period 	       Varchar2(20),
        Coverage_Schedule_id	  	   Number,
--        Starting_Delay                  Varchar2(1)
--	  Warranty_Flag 		 Varchar2(1),
--	  Service_Order_number         Number,
--	  Service_Order_Date		 Date,
--	  Bill_To_Site_Use_id		   Number,
--  	  Ship_To_Site_Use_id		   Number,
	  Warranty_Start_Date		   Date,
--	  Customer_Account_Id		   Number
	  Warranty_End_Date		   Date
				     );
  TYPE War_tbl_type IS TABLE OF War_rec_type	 INDEX BY BINARY_INTEGER;

Procedure Get_Duration
	   (
	P_Api_Version_Number	  IN  Number,
        P_init_msg_list	  IN  Varchar2 Default FND_API.G_FALSE,
	X_msg_Count       OUT NOCOPY /* file.sql.39 change */    Number,
        X_msg_Data		  OUT NOCOPY /* file.sql.39 change */   Varchar2,
        X_Return_Status	  OUT NOCOPY /* file.sql.39 change */   Varchar2,
	P_customer_id 	  IN  Number,
	P_system_id 	  IN  Number,
	P_Service_Duration  IN	Number,
        P_service_period    IN	Varchar2,
	P_coterm_checked_yn IN	Varchar2 Default FND_API.G_FALSE,
	P_start_date 	  IN  Date,
	P_end_date 		  IN  Date,
	X_service_duration  OUT NOCOPY /* file.sql.39 change */   Number,
	X_service_period 	  OUT NOCOPY /* file.sql.39 change */   Varchar2,
        X_new_end_date 	  OUT NOCOPY /* file.sql.39 change */   Date
				 	  ) ;


Procedure Is_Service_Available
   	 (
	P_Api_Version_Number	  IN  Number,
	P_init_msg_list	  IN  Varchar2 Default FND_API.G_FALSE,
	X_msg_Count	  	  OUT NOCOPY /* file.sql.39 change */    Number,
	X_msg_Data	  	  OUT NOCOPY /* file.sql.39 change */    Varchar2,
	X_Return_Status	  OUT NOCOPY /* file.sql.39 change */   Varchar2,
	p_check_service_rec IN	   CHECK_SERVICE_REC_TYPE,
	X_Available_YN	  OUT NOCOPY /* file.sql.39 change */   Varchar2
				   	  );


Procedure Available_Services(
	P_Api_Version_Number	  IN   Number,
	P_init_msg_list	  IN   Varchar2 Default FND_API.G_FALSE,
	X_msg_Count		  OUT NOCOPY /* file.sql.39 change */    Number,
	X_msg_Data		  OUT NOCOPY /* file.sql.39 change */    Varchar2,
	X_Return_Status	  OUT NOCOPY /* file.sql.39 change */    Varchar2,
	p_avail_service_rec IN	 AVAIL_SERVICE_REC_TYPE,
	X_Orderable_Service_tbl	  OUT NOCOPY /* file.sql.39 change */    order_service_tbl_type
					    );


Procedure Get_Warranty	   (
       P_Api_Version_Number	       IN	Number,
       P_init_msg_list	         IN	Varchar2 Default FND_API.G_FALSE,
       X_msg_Count	         OUT NOCOPY /* file.sql.39 change */  	Number,
       X_msg_Data		 OUT NOCOPY /* file.sql.39 change */  	  Varchar2,
       P_Org_id                  IN       Number,
       P_Organization_id         IN       NUMBER Default null,
       P_product_item_id 	 IN	  Number,
       x_return_status	         OUT NOCOPY /* file.sql.39 change */  	Varchar2,
       X_Warranty_tbl	         OUT NOCOPY /* file.sql.39 change */        War_tbl_type  );


Procedure Get_service_attributes
	   (
	P_Api_Version_Number	  IN  Number,
        P_init_msg_list	  IN  Varchar2 Default FND_API.G_FALSE,
	 P_Qte_Line_Rec     IN   ASO_QUOTE_PUB.Qte_Line_Rec_Type,
        P_Qte_Line_Dtl_tbl  IN    ASO_QUOTE_PUB.Qte_Line_Dtl_tbl_Type,
         X_msg_Count       OUT NOCOPY /* file.sql.39 change */    Number,
        X_msg_Data		  OUT NOCOPY /* file.sql.39 change */   Varchar2,
        X_Return_Status	  OUT NOCOPY /* file.sql.39 change */   Varchar2
         	  ) ;

END ASO_service_contracts_INT;

 

/
