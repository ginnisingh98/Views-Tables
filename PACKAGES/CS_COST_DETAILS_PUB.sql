--------------------------------------------------------
--  DDL for Package CS_COST_DETAILS_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."CS_COST_DETAILS_PUB" AUTHID CURRENT_USER AS
/* $Header: csxpcsts.pls 120.1 2008/01/18 07:01:59 bkanimoz noship $ */

--cost record structure

TYPE COST_REC_TYPE IS RECORD
(
cost_id NUMBER                  := FND_API.G_MISS_NUM ,
incident_id NUMBER              := FND_API.G_MISS_NUM ,
estimate_Detail_id NUMBER       := FND_API.G_MISS_NUM ,
charge_line_type VARCHAR(30)    := FND_API.G_MISS_CHAR ,
transaction_type_id NUMBER      := FND_API.G_MISS_NUM ,
txn_billing_type_id NUMBER      := FND_API.G_MISS_NUM ,
inventory_item_id NUMBER        := FND_API.G_MISS_NUM ,
quantity NUMBER                 := FND_API.G_MISS_NUM ,
unit_of_measure_code VARCHAR2(3):= FND_API.G_MISS_CHAR ,
currency_code VARCHAR2(15)      := FND_API.G_MISS_CHAR ,
source_id NUMBER                := FND_API.G_MISS_NUM ,
source_code VARCHAR2(10)        := FND_API.G_MISS_CHAR ,
org_id NUMBER                   := FND_API.G_MISS_NUM ,
inventory_org_id NUMBER         := FND_API.G_MISS_NUM ,
transaction_date DATE           := FND_API.G_MISS_DATE ,
extended_cost NUMBER            := FND_API.G_MISS_NUM ,
attribute1 VARCHAR2(150)        := FND_API.G_MISS_CHAR ,
attribute2 VARCHAR2(150)        := FND_API.G_MISS_CHAR ,
attribute3 VARCHAR2(150)        := FND_API.G_MISS_CHAR ,
attribute4 VARCHAR2(150)        := FND_API.G_MISS_CHAR ,
attribute5 VARCHAR2(150)        := FND_API.G_MISS_CHAR ,
attribute6 VARCHAR2(150)        := FND_API.G_MISS_CHAR ,
attribute7 VARCHAR2(150)        := FND_API.G_MISS_CHAR ,
attribute8 VARCHAR2(150)        := FND_API.G_MISS_CHAR ,
attribute9 VARCHAR2(150)        := FND_API.G_MISS_CHAR ,
attribute10 VARCHAR2(150)       := FND_API.G_MISS_CHAR ,
attribute11 VARCHAR2(150)       := FND_API.G_MISS_CHAR ,
attribute12 VARCHAR2(150)       := FND_API.G_MISS_CHAR ,
attribute13 VARCHAR2(150)       := FND_API.G_MISS_CHAR ,
attribute14 VARCHAR2(150)       := FND_API.G_MISS_CHAR ,
attribute15 VARCHAR2(150)       := FND_API.G_MISS_CHAR
) ;


G_MISS_COST_REC Cost_Rec_Type ;

/*=========================================
Procedure Create_cost_details
===========================================
*/
-- Start of comments
--      API name        : Create_Cost_Details
--      Type            : Public
--      Function        :
--      Pre-reqs        : None.
--      Parameters      :
--
--      IN              : p_api_version: 	Standard Version of API	 	            Required
--                        p_init_msg_list:                                                  Optional
--                        p_commit:             Indicates whether API should commit         Optional
--                        p_validation_level:                                               Optional
--                        p_resp_appl_id:
--                        p_resp_id:
--                        p_user_id:
--                        p_login_id:
--                        p_transaction_control:
--                        p_cost_Rec: Cost_Rec_Type
--                        Following passed using RECORD Cost_Rec_Type are required
--                        or conditionally required.
--                         incident_id:               Required
--                         Transaction_Type_Id:       Required
--                         Inventory_item_id:         Required
--                         Source_id:		      Required
--                         Source_code:		      Required
--				(or)
--			   Estimate_Detail_Id	       Required
--                        If Estimate_Detail_Id is passed then, all the information
--                        for costing will be taken from the Charges table and the Costing Private API is called with No validation
--                        If estimate_Detail_id not passed ,then the costing private api is called with full validation by passing the values

--      OUT             : x_return_status:
--                        x_msg_count:
--                        x_object_version_number:
--                        x_msg_data:
--                        x_estimate_detail_id:
--                        x_line_number:
--
--      Version : Current version      12.1
--      Notes   : This API is a public API to Create Cost Details
--
-- End of comments

/*#
* Create a cost line associated with a service request. This procedure creates one cost line
* at a time.
*/

PROCEDURE Create_cost_details
(
p_api_version IN NUMBER,
p_init_msg_list IN VARCHAR2       := FND_API.G_FALSE,
p_commit IN VARCHAR2              := FND_API.G_FALSE,
p_validation_level IN NUMBER      := FND_API.G_VALID_LEVEL_FULL,
x_return_status OUT NOCOPY VARCHAR2,
x_msg_count OUT NOCOPY NUMBER,
x_object_version_number OUT NOCOPY NUMBER,
x_msg_data OUT NOCOPY VARCHAR2,
x_cost_id OUT NOCOPY NUMBER,
p_resp_appl_id IN NUMBER          := FND_GLOBAL.RESP_APPL_ID,
p_resp_id IN NUMBER               := FND_GLOBAL.RESP_ID,
p_user_id IN NUMBER               := FND_GLOBAL.USER_ID,
p_login_id IN NUMBER              := NULL,
p_transaction_control IN VARCHAR2 := FND_API.G_TRUE,
p_Cost_Rec IN Cost_Rec_Type       :=G_MISS_COST_REC

);

/*=========================================
Procedure Update_Cost_details
===========================================
*/

-- Start of comments
--      API name        : Update_Cost_Details
--      Type            : Public
--      Function        :
--      Pre-reqs        : None.


PROCEDURE Update_Cost_details
(
p_api_version IN NUMBER,
p_init_msg_list IN VARCHAR2       := FND_API.G_FALSE,
p_commit IN VARCHAR2              := FND_API.G_FALSE,
p_validation_level IN NUMBER      := FND_API.G_VALID_LEVEL_FULL,
x_return_status OUT NOCOPY VARCHAR2,
x_msg_count OUT NOCOPY NUMBER,
x_object_version_number OUT NOCOPY NUMBER,
x_msg_data OUT NOCOPY VARCHAR2,
p_resp_appl_id IN NUMBER          := FND_GLOBAL.RESP_APPL_ID,
p_resp_id IN NUMBER               := FND_GLOBAL.RESP_ID,
p_user_id IN NUMBER               := FND_GLOBAL.USER_ID,
p_login_id IN NUMBER              := NULL,
p_transaction_control IN VARCHAR2 := FND_API.G_TRUE,
p_Cost_Rec IN Cost_Rec_Type       := G_MISS_COST_REC
) ;

/*=========================================
Procedure Delete_Cost_details
===========================================
*/
-- Start of comments
--      API name        : Delere_Cost_Details
--      Type            : Public
--      Function        :
--      Pre-reqs        : None.

PROCEDURE Delete_Cost_details
(
p_api_version IN NUMBER,
p_init_msg_list IN VARCHAR2       := FND_API.G_FALSE,
p_commit IN VARCHAR2              := FND_API.G_FALSE,
p_validation_level IN NUMBER      := FND_API.G_VALID_LEVEL_FULL,
x_return_status OUT NOCOPY VARCHAR2,
x_msg_count OUT NOCOPY NUMBER,
x_msg_data OUT NOCOPY VARCHAR2,
p_transaction_control IN VARCHAR2 := FND_API.G_TRUE,
p_cost_id IN NUMBER               := NULL
) ;

/*=========================================
Procedure Log_Cost_Rec_Parameters
===========================================
*/
--This procedure is for logging the cost record parameters passed into the FND_LOG_MESSAGES table

PROCEDURE Log_Cost_Rec_Parameters
(
p_Cost_Rec_in IN Cost_Rec_Type
);

END CS_Cost_Details_PUB ;

/
