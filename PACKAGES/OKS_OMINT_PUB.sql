--------------------------------------------------------
--  DDL for Package OKS_OMINT_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OKS_OMINT_PUB" AUTHID CURRENT_USER AS
/* $Header: OKSPOMIS.pls 120.8.12010000.2 2009/03/10 04:02:36 vgujarat ship $ */
/*#
 * Package of APIs for retrieving customer Service information, specifically,
 * duration of a Service, availability of a Service for a customer and a list of
 * Services which can be ordered for a customer.
 * @rep:scope public
 * @rep:product OKS
 * @rep:displayname Order Integration utility procedures
 * @rep:category BUSINESS_ENTITY OKS_AVAILABLE_SERVICE
 * @rep:metalink 284732.1 See Oracle Metalink Bulletin 284732.1
*/


  ---------------------------------------------------------------------------
  -- GLOBAL MESSAGE CONSTANTS
  ---------------------------------------------------------------------------
  G_REQUIRED_VALUE		     CONSTANT VARCHAR2(200) := OKC_API.G_REQUIRED_VALUE;
  G_INVALID_VALUE			CONSTANT VARCHAR2(200) := OKC_API.G_INVALID_VALUE;
  G_COL_NAME_TOKEN		     CONSTANT VARCHAR2(200) := OKC_API.G_COL_NAME_TOKEN;
  G_PARENT_TABLE_TOKEN		CONSTANT VARCHAR2(200) := OKC_API.G_PARENT_TABLE_TOKEN;
  G_CHILD_TABLE_TOKEN		CONSTANT VARCHAR2(200) := OKC_API.G_CHILD_TABLE_TOKEN;
  G_UNEXPECTED_ERROR          CONSTANT VARCHAR2(200) := 'OKC_CONTRACTS_UNEXP_ERROR';
  G_SQLERRM_TOKEN             CONSTANT VARCHAR2(200) := 'SQLerrm';
  G_SQLCODE_TOKEN             CONSTANT VARCHAR2(200) := 'SQLcode';
  G_UPPERCASE_REQUIRED		CONSTANT VARCHAR2(200) := 'OKC_CONTRACTS_UPPERCASE_REQUIRED';

  ------------------------------------------------------------------------------------
  -- GLOBAL EXCEPTION
  ---------------------------------------------------------------------------
  G_EXCEPTION_HALT_VALIDATION	EXCEPTION;

  -- GLOBAL VARIABLES
  ---------------------------------------------------------------------------
  G_PKG_NAME			CONSTANT VARCHAR2(200) := 'OKSOMINT';
  G_APP_NAME			CONSTANT VARCHAR2(3)   := 'OKS';
  ---------------------------------------------------------------------------

  TYPE CHECK_SERVICE_REC_TYPE Is RECORD
  (
		 product_item_id	   Number
		,service_item_id	   Number
		,customer_id	   Number
            ,customer_product_id Number
		,product_revision	   Varchar2(3)
		,request_date        Date

  );


  TYPE AVAIL_SERVICE_REC_TYPE  Is RECORD
  (
		 product_item_id	Number
		,customer_id	Number
		,product_revision	Varchar2(3)
		,request_date     Date

  );



  TYPE OKS_ORDER_SERVICE_REC_TYPE Is RECORD
  (
		service_item_id	Number
,		name			Varchar2(240)
,		Description		Varchar2(240)
,		Coverage_Template_Id Number
  );



  TYPE ORDER_SERVICE_REC_TYPE Is RECORD
  (
		service_item_id	Number
  );

  TYPE order_service_tbl_type Is TABLE OF ORDER_SERVICE_REC_TYPE Index by BINARY_INTEGER;

  TYPE oks_order_service_tbl_type Is TABLE OF OKS_ORDER_SERVICE_REC_TYPE Index by BINARY_INTEGER;

  -- Added for ASO Queue Replacement

  TYPE Service_Order_Lines_RecType IS RECORD
         (Order_Header_ID    NUMBER
         ,Order_Line_ID      NUMBER
         ,Order_Number       NUMBER
         ,Ref_Order_Line_ID  NUMBER);
  --

  TYPE Service_Order_Lines_TblType IS TABLE
         OF Service_Order_Lines_RecType INDEX BY BINARY_INTEGER;
  --

  --NPALEPU
  --23-JUN-2005
  --SERVICE AVAILABILITY API ENHANCEMENT(ER 3680488)
  --ADDED NEW RECORD TYPE "NEW_ORDER_SERVICE_REC_TYPE" and NEW TABLE TYPE "NEW_ORDER_SERVICE_TBL_TYPE"
/*Increased max length for Concatenated_segments for bug7699136*/

  TYPE NEW_ORDER_SERVICE_REC_TYPE Is RECORD
  (
      Inventory_organization_id  NUMBER,
      Service_item_id            NUMBER,
      Concatenated_segments      VARCHAR2(240),
      Description                VARCHAR2(240),
      Primary_uom_code           VARCHAR2(3),
      Serviceable_product_flag   VARCHAR2(1),
      Service_item_flag          VARCHAR2(1),
      Bom_item_type              NUMBER,
      Item_type                  VARCHAR2(30),
      Service_duration           NUMBER,
      Service_duration_period_code VARCHAR2(10),
      Shippable_item_flag        VARCHAR2(1),
      Returnable_flag            VARCHAR2(1)
  );

  TYPE NEW_ORDER_SERVICE_TBL_TYPE Is TABLE OF NEW_ORDER_SERVICE_REC_TYPE Index by BINARY_INTEGER;
  --END NPALEPU


 /*#
  * Computes and returns the Duration, Period and End Date based on a given START_DATE.  The Duration
  * is derived from a co-Terminate date (which is retrieved from P_CUSTOMER_ID or P_SYSTEM_ID),  or from
  * a numeric length of time (which is derived from P_SERVICE_DURATION and P_SERVICE_PERIOD).  For
  * further details, please see the Metalink Note.
  * @param p_api_version Version numbers of incoming calls must match this number.
  * @param p_init_msg_list FND_API.G_TRUE or FND_API.G_FALSE indicates if API initializes message list.
  * @param p_customer_id Unique Identifier for customer Account
  * @param p_system_id Unique Identifier for System
  * @param p_service_duration The numeric value of the service durations length
  * @param p_service_period The Unit of Measure code for specifying the Service duration
  * @param p_coterm_checked_yn A flag indicating co-termination is needed or not
  * @param p_start_date	Date on which the ordering service becomes effective (Required)
  * @param p_end_date Date on which the service becomes expired
  * @param x_msg_count  Message Count. Returns number of messages in API message list.
  * @param x_msg_data Message Data. If x_msg_count is 1 then the message data is encoded.
  * @param x_return_status Possible returns are 'S'uccess, 'E'rror, or 'U'nexpected error.
  * @param x_service_duration Service Duration computed and returned by the procedure
  * @param x_service_period Derived service period returned by the procedure
  * @param x_new_end_date Date on which the service will expire
  * @rep:scope public
  * @rep:lifecycle active
  * @rep:displayname Get Duration
  * @rep:metalink 284732.1 See Oracle Metalink Bulletin 284732.1
  */

  Procedure Get_Duration
	   			   	 (
						P_Api_Version	  IN  Number,
						P_init_msg_list	  IN  Varchar2 Default OKC_API.G_FALSE,
						X_msg_Count		  OUT NOCOPY  Number,
						X_msg_Data		  OUT NOCOPY  Varchar2,
						X_Return_Status	  OUT NOCOPY  Varchar2,
						P_customer_id 	  IN  Number,
						P_system_id 	  IN  Number,
						P_Service_Duration  IN  Number,
						P_service_period    IN  Varchar2,
						P_coterm_checked_yn IN  Varchar2 Default OKC_API.G_FALSE,
						P_start_date 	  IN  Date,
						P_end_date 		  IN  Date,
						X_service_duration  OUT NOCOPY  Number,
						X_service_period 	  OUT NOCOPY  Varchar2,
						X_new_end_date 	  OUT  NOCOPY Date
				 	  ) ;

 /*#
  * Returns 'Y' or 'N' if the given service is available for a product or for a customer.
  * This procedure returns 'N', if one of the following conditions is met in the Service Availability Form:
  * 1.	The Service is not defined as "Generally Available"
  * 2.	The Service's Effectivity Date Range has past
  * 3.	A given Customer is listed in the "Party Exceptions"
  * 4.	A given Product is listed in the "Product Exceptions"
  *
  * If none of the previous conditions are met the API will return 'Y', or if the Service is
  * NOT listed in the Service Availability Form.
  *
  * @param p_api_version Version numbers of incoming calls must match this number.
  * @param p_init_msg_list FND_API.G_TRUE or FND_API.G_FALSE indicates if API initializes message list.
  * @param p_check_service_rec Set of input attributes
  * @param x_msg_count Returns number of messages in API message list.
  * @param x_msg_data If x_msg_count is 1 then the message data is encoded.
  * @param x_return_status Possible returns are 'S'uccess, 'E'rror, or 'U'nexpected error.
  * @param x_available_yn Flag indicating the service is available or not (Y/N)
  * @rep:scope public
  * @rep:lifecycle active
  * @rep:displayname Is Service Available
  * @rep:metalink 284732.1 See Oracle Metalink Bulletin 284732.1
  */

  Procedure Is_Service_Available
				   	 (
						P_Api_Version	  IN  Number,
						P_init_msg_list	  IN  Varchar2 Default OKC_API.G_FALSE,
						X_msg_Count	  	  OUT  NOCOPY  Number,
						X_msg_Data	  	  OUT  NOCOPY  Varchar2,
						X_Return_Status	  OUT  NOCOPY Varchar2,
						p_check_service_rec IN     CHECK_SERVICE_REC_TYPE,
						X_Available_YN	  OUT  NOCOPY Varchar2,
                                                --NPALEPU added on 29-sep-2005 for bug # 4608694
                                                P_ORG_ID          IN  NUMBER   Default NULL
                                                --END NPALEPU
				   	  );

 /*#
  * This procedure returns list of available services that can be ordered for
  * a customer or a product.  In the Service Availability Form, a Party (i.e.
  * a customer) or a Product can be excluded from a specified Service or Extended
  * Warranty.  This procedure retrieves the list of Services a given Party or a
  * given Product is NOT excluded from.
  * @param p_api_version Version numbers of incoming calls must match this number.
  * @param p_init_msg_list FND_API.G_TRUE or FND_API.G_FALSE indicates if API initializes message list.
  * @param p_avail_service_rec Set of input attributes
  * @param x_msg_count Returns number of messages in API message list.
  * @param x_msg_data If x_msg_count is 1 then the message data is encoded.
  * @param x_return_status Possible returns are 'S'uccess, 'E'rror, or 'U'nexpected error.
  * @param x_orderable_service_tbl Array of orderable services
  * @rep:scope public
  * @rep:lifecycle active
  * @rep:displayname Available Services
  * @rep:metalink 284732.1 See Oracle Metalink Bulletin 284732.1
  */

  Procedure Available_Services
   	   (
						P_Api_Version	  IN   Number,
						P_init_msg_list	  IN   Varchar2 Default OKC_API.G_FALSE,
						X_msg_Count		  OUT  NOCOPY  Number,
						X_msg_Data		  OUT  NOCOPY  Varchar2,
						X_Return_Status	  OUT  NOCOPY  Varchar2,
						p_avail_service_rec IN   AVAIL_SERVICE_REC_TYPE,
						X_Orderable_Service_tbl	  OUT  NOCOPY  order_service_tbl_type,
                                                --NPALEPU added on 21-sep-2005 for bug # 4608694
                                                P_ORG_ID          IN  NUMBER   Default NULL
                                                --END NPALEPU
					    );

  Procedure OKS_Available_Services
				    (
					P_Api_Version	  IN   Number,
					P_init_msg_list	  IN   Varchar2 Default OKC_API.G_FALSE,
					X_msg_Count		  OUT  NOCOPY  Number,
					X_msg_Data		  OUT  NOCOPY  Varchar2,
					X_Return_Status	  OUT  NOCOPY  Varchar2,
					p_avail_service_rec IN   AVAIL_SERVICE_REC_TYPE,--ADDED FOR OKS REQ
					X_Orderable_Service_tbl	  OUT  NOCOPY  OKS_order_service_tbl_type,
                                        --NPALEPU added on 21-sep-2005 for bug # 4608694
                                        P_ORG_ID          IN  NUMBER   Default NULL
                                        --END NPALEPU
				     ) ;


Procedure Is_service_available
                    (p_api_version      IN Number
                    ,p_party_id         IN Number
                    ,p_service_id       IN Number
                    ,p_request_date     IN Date Default sysdate
                    ,p_init_msg_list	IN Varchar2 Default OKC_API.G_FALSE
                    ,x_available_yn     OUT NOCOPY  Varchar2
                    ,x_msg_Count        OUT NOCOPY  Number
                    ,x_msg_Data         OUT NOCOPY  Varchar2
                    ,x_return_status    OUT NOCOPY  Varchar2);


Procedure  Delete_Contract_details
                  ( p_api_version       IN Number
                   ,p_init_msg_list	IN Varchar2 Default OKC_API.G_FALSE
                   ,p_order_line_id     IN Number
                   ,x_msg_Count        OUT NOCOPY  Number
                   ,x_msg_Data         OUT NOCOPY  Varchar2
                   ,x_return_status    OUT NOCOPY  Varchar2);


 Procedure  GET_SVC_SDATE
(
 P_api_version       IN  Number,
 P_init_msg_list     IN  Varchar2,
 P_order_line_id     IN  Number,   -- (Service Order line Id)
 X_msg_count         OUT  NOCOPY Number,
 X_msg_data          OUT  NOCOPY Varchar2,
 X_return_status     OUT  NOCOPY Varchar2,
 X_start_date        OUT  NOCOPY Date,
  X_end_date         OUT  NOCOPY Date
 );

  -- Added for ASO Queue Replacement

  PROCEDURE Interface_Service_Order_Lines
    (p_Service_Order_Lines   IN   Service_Order_Lines_TblType
    ,x_Return_Status         OUT  NOCOPY  VARCHAR2
    ,x_Error_Message         OUT  NOCOPY  VARCHAR2) ;

  --
  FUNCTION  get_quantity(p_start_date   IN DATE,
                         p_end_date      IN DATE,
                         p_source_uom    IN VARCHAR2 DEFAULT NULL,
                         p_org_id        IN VARCHAR2 DEFAULT NULL)
  return NUMBER;


  --NPALEPU
  --23-JUN-2005
  --SERVICE AVAILABILITY API ENHANCEMENT(ER 3680488)
  --ADDED NEW OVERLOADED API "Available_Services"

  /*#
  * This procedure returns list of available services that can be ordered for
  * a customer or a product based on a search criteria.  In the Service Availability Form, a Party (i.e.
  * a customer) or a Product can be excluded from a specified Service or Extended
  * Warranty.  This procedure retrieves the list of Services those match the given search criteria given Party or a
  * given Product is NOT excluded from.
  * @param p_api_version Version numbers of incoming calls must match this number.
  * @param p_init_msg_list FND_API.G_TRUE or FND_API.G_FALSE indicates if API initializes message list.
  * @param p_search_input - the search criteria
  * @param P_MAX_ROWS_RETURNED - the maximum number of rows returned by the API.
  * @param p_avail_service_rec Set of input attributes
  * @param x_msg_count Returns number of messages in API message list.
  * @param x_msg_data If x_msg_count is 1 then the message data is encoded.
  * @param x_return_status Possible returns are 'S'uccess, 'E'rror, or 'U'nexpected error.
  * @param x_orderable_service_tbl Array of orderable services
  * @rep:scope public
  * @rep:lifecycle active
  * @rep:displayname Available Services
  * @rep:metalink 284732.1 See Oracle Metalink Bulletin 284732.1
  */
  PROCEDURE Available_Services
  (
      P_Api_Version           IN  NUMBER,
      P_init_msg_list         IN  VARCHAR2 Default OKC_API.G_FALSE,
      P_search_input          IN  VARCHAR2 Default OKC_API.G_MISS_CHAR,
      P_MAX_ROWS_RETURNED     IN  NUMBER   Default 200,
      X_msg_Count             OUT NOCOPY   NUMBER,
      X_msg_Data              OUT NOCOPY   VARCHAR2,
      X_Return_Status         OUT NOCOPY   VARCHAR2,
      p_avail_service_rec     IN  AVAIL_SERVICE_REC_TYPE,
      X_Orderable_Service_tbl OUT NOCOPY   NEW_ORDER_SERVICE_TBL_TYPE,
      --NPALEPU added on 21-sep-2005 for bug # 4608694
      P_ORG_ID                IN  NUMBER   Default NULL
      --END NPALEPU
  );
  --END NPALEPU

  /*
  * If Service_Period (UOM) <> line_uom (Order_UOM), OM/ASO/Istore will call this API to
  * determine the duration in terms of the target uom that is the order_uom in this case.
  * In all the cases, target duration will be computed based on period start = Service Start
  * and Period Type = Fixed as Istore (always) and OM (sometimes) do not have service
  * start information.
  */
  FUNCTION  get_target_duration (p_start_date      IN DATE DEFAULT NULL,
                                 p_end_date        IN DATE DEFAULT NULL,
				 p_source_uom      IN VARCHAR2 DEFAULT NULL,
				 p_source_duration IN NUMBER DEFAULT NULL,
				 p_target_uom      IN VARCHAR2 DEFAULT NULL,/*Default Month*/
				 p_org_id          IN NUMBER DEFAULT NULL)
  return NUMBER;

End OKS_OMINT_PUB;

/
