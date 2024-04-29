--------------------------------------------------------
--  DDL for Package CSF_DEBRIEF_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."CSF_DEBRIEF_PVT" AUTHID CURRENT_USER as
/* $Header: csfvdbfs.pls 120.4.12010000.4 2009/10/14 00:10:09 hhaugeru ship $ */
-- Start of Comments
-- Package name     : CSF_DEBRIEF_PVT
-- Purpose          :
-- History          :
-- NOTE             :
-- End of Comments

-- Default number of records fetch per call
G_DEFAULT_NUM_REC_FETCH  NUMBER := 30;
--   *******************************************************
--    Start of Comments
--   -------------------------------------------------------
--    Record name:DEBRIEF_Rec_Type
--   -------------------------------------------------------


TYPE DEBRIEF_Rec_Type IS RECORD
(
	DEBRIEF_HEADER_ID                NUMBER := FND_API.G_MISS_NUM,
 	DEBRIEF_NUMBER                   VARCHAR2(50) 	:= FND_API.G_MISS_CHAR,
 	DEBRIEF_DATE                     DATE 		:= FND_API.G_MISS_DATE,
 	DEBRIEF_STATUS_ID                NUMBER 		:= FND_API.G_MISS_NUM,
 	TASK_ASSIGNMENT_ID               NUMBER 		:= FND_API.G_MISS_NUM,
 	CREATED_BY                       NUMBER 		:= FND_API.G_MISS_NUM,
 	CREATION_DATE                    DATE 		:= FND_API.G_MISS_DATE,
 	LAST_UPDATED_BY                  NUMBER 		:= FND_API.G_MISS_NUM,
 	LAST_UPDATE_DATE                 DATE 		:= FND_API.G_MISS_DATE,
 	LAST_UPDATE_LOGIN                NUMBER 		:= FND_API.G_MISS_NUM,
 	ATTRIBUTE1                       VARCHAR2(150) 	:= FND_API.G_MISS_CHAR,
 	ATTRIBUTE2                       VARCHAR2(150) 	:= FND_API.G_MISS_CHAR,
 	ATTRIBUTE3                       VARCHAR2(150) 	:= FND_API.G_MISS_CHAR,
 	ATTRIBUTE4                       VARCHAR2(150) 	:= FND_API.G_MISS_CHAR,
 	ATTRIBUTE5                       VARCHAR2(150) 	:= FND_API.G_MISS_CHAR,
 	ATTRIBUTE6                       VARCHAR2(150) 	:= FND_API.G_MISS_CHAR,
 	ATTRIBUTE7                       VARCHAR2(150) 	:= FND_API.G_MISS_CHAR,
 	ATTRIBUTE8                       VARCHAR2(150) 	:= FND_API.G_MISS_CHAR,
 	ATTRIBUTE9                       VARCHAR2(150) 	:= FND_API.G_MISS_CHAR,
 	ATTRIBUTE10                      VARCHAR2(150) 	:= FND_API.G_MISS_CHAR,
 	ATTRIBUTE11                      VARCHAR2(150) 	:= FND_API.G_MISS_CHAR,
 	ATTRIBUTE12                      VARCHAR2(150) 	:= FND_API.G_MISS_CHAR,
 	ATTRIBUTE13                      VARCHAR2(150) 	:= FND_API.G_MISS_CHAR,
 	ATTRIBUTE14                      VARCHAR2(150) 	:= FND_API.G_MISS_CHAR,
 	ATTRIBUTE15                      VARCHAR2(150) 	:= FND_API.G_MISS_CHAR,
 	ATTRIBUTE_CATEGORY               VARCHAR2(30) 	:= FND_API.G_MISS_CHAR,
 	object_version_number            NUMBER        :=  FND_API.G_MISS_NUM,
    TRAVEL_START_TIME                DATE       :=  FND_API.G_MISS_DATE,
    TRAVEL_END_TIME                  DATE        :=  FND_API.G_MISS_DATE,
    TRAVEL_DISTANCE_IN_KM            NUMBER        :=  FND_API.G_MISS_NUM
	);

G_MISS_DEBRIEF_REC          DEBRIEF_Rec_Type;
TYPE  DEBRIEF_Tbl_Type      IS TABLE OF DEBRIEF_Rec_Type
                                    INDEX BY BINARY_INTEGER;
G_MISS_DEBRIEF_TBL          DEBRIEF_Tbl_Type;

TYPE DEBRIEF_LINE_Rec_Type IS RECORD
(
DEBRIEF_LINE_ID                 		NUMBER := FND_API.G_MISS_NUM,
 DEBRIEF_HEADER_ID               		NUMBER := FND_API.G_MISS_NUM,
 DEBRIEF_LINE_NUMBER             		NUMBER := FND_API.G_MISS_NUM,
 SERVICE_DATE                    		DATE 	 := FND_API.G_MISS_DATE,
 BUSINESS_PROCESS_ID             		NUMBER := FND_API.G_MISS_NUM,
 TXN_BILLING_TYPE_ID             		NUMBER := FND_API.G_MISS_NUM,
 INVENTORY_ITEM_ID                        NUMBER := FND_API.G_MISS_NUM,
 INSTANCE_ID                              NUMBER := FND_API.G_MISS_NUM,
 ISSUING_INVENTORY_ORG_ID                 NUMBER := FND_API.G_MISS_NUM,
 RECEIVING_INVENTORY_ORG_ID               NUMBER := FND_API.G_MISS_NUM,
 ISSUING_SUB_INVENTORY_CODE               VARCHAR2(10) := FND_API.G_MISS_CHAR,
 RECEIVING_SUB_INVENTORY_CODE             VARCHAR2(10) := FND_API.G_MISS_CHAR,
 ISSUING_LOCATOR_ID                       NUMBER := FND_API.G_MISS_NUM,
 RECEIVING_LOCATOR_ID                     NUMBER := FND_API.G_MISS_NUM,
 PARENT_PRODUCT_ID                        NUMBER := FND_API.G_MISS_NUM,
 REMOVED_PRODUCT_ID                       NUMBER := FND_API.G_MISS_NUM,
 STATUS_OF_RECEIVED_PART                  VARCHAR2(30) := FND_API.G_MISS_CHAR,
 ITEM_SERIAL_NUMBER                       VARCHAR2(30) := FND_API.G_MISS_CHAR,
 ITEM_REVISION                            VARCHAR2(3) := FND_API.G_MISS_CHAR,
 ITEM_LOTNUMBER                           VARCHAR2(80) := FND_API.G_MISS_CHAR,
 UOM_CODE                                 VARCHAR2(3) := FND_API.G_MISS_CHAR,
 QUANTITY                                 NUMBER := FND_API.G_MISS_NUM,
-- RMA_NUMBER                               NUMBER := FND_API.G_MISS_NUM,
 RMA_HEADER_ID                            NUMBER := FND_API.G_MISS_NUM,
 DISPOSITION_CODE                         VARCHAR2(30) := FND_API.G_MISS_CHAR,
 MATERIAL_REASON_CODE                     VARCHAR2(30) := FND_API.G_MISS_CHAR,
 LABOR_REASON_CODE                        VARCHAR2(30) := FND_API.G_MISS_CHAR,
 EXPENSE_REASON_CODE                      VARCHAR2(30) := FND_API.G_MISS_CHAR,
 LABOR_START_DATE                         DATE 		:= FND_API.G_MISS_DATE,
 LABOR_END_DATE                           DATE 		:= FND_API.G_MISS_DATE,
 STARTING_MILEAGE                         NUMBER := FND_API.G_MISS_NUM,
 ENDING_MILEAGE                           NUMBER := FND_API.G_MISS_NUM,
 EXPENSE_AMOUNT                           NUMBER := FND_API.G_MISS_NUM,
 CURRENCY_CODE                            VARCHAR2(15) := FND_API.G_MISS_CHAR,
 DEBRIEF_LINE_STATUS_ID                   NUMBER := FND_API.G_MISS_NUM,
 CHANNEL_CODE                             VARCHAR2(30) := FND_API.G_MISS_CHAR,
 CHARGE_UPLOAD_STATUS                     VARCHAR2(30) := FND_API.G_MISS_CHAR,
 CHARGE_UPLOAD_MSG_CODE                   VARCHAR2(30) := FND_API.G_MISS_CHAR,
 CHARGE_UPLOAD_MESSAGE                    VARCHAR2(240) := FND_API.G_MISS_CHAR,
 IB_UPDATE_STATUS                         VARCHAR2(30) := FND_API.G_MISS_CHAR,
 IB_UPDATE_MSG_CODE                       VARCHAR2(30) := FND_API.G_MISS_CHAR,
 IB_UPDATE_MESSAGE                        VARCHAR2(240) := FND_API.G_MISS_CHAR,
 SPARE_UPDATE_STATUS                      VARCHAR2(30) := FND_API.G_MISS_CHAR,
 SPARE_UPDATE_MSG_CODE                    VARCHAR2(30) := FND_API.G_MISS_CHAR,
 SPARE_UPDATE_MESSAGE                     VARCHAR2(240) := FND_API.G_MISS_CHAR,
 CREATED_BY                      		NUMBER := FND_API.G_MISS_NUM,
 CREATION_DATE                   		DATE 		:= FND_API.G_MISS_DATE,
 LAST_UPDATED_BY                 		NUMBER := FND_API.G_MISS_NUM,
 LAST_UPDATE_DATE                		DATE 		:= FND_API.G_MISS_DATE,
 LAST_UPDATE_LOGIN                        NUMBER := FND_API.G_MISS_NUM,
 ATTRIBUTE1                               VARCHAR2(150) := FND_API.G_MISS_CHAR,
 ATTRIBUTE2                               VARCHAR2(150) := FND_API.G_MISS_CHAR,
 ATTRIBUTE3                               VARCHAR2(150) := FND_API.G_MISS_CHAR,
 ATTRIBUTE4                               VARCHAR2(150) := FND_API.G_MISS_CHAR,
 ATTRIBUTE5                               VARCHAR2(150) := FND_API.G_MISS_CHAR,
 ATTRIBUTE6                               VARCHAR2(150) := FND_API.G_MISS_CHAR,
 ATTRIBUTE7                               VARCHAR2(150) := FND_API.G_MISS_CHAR,
 ATTRIBUTE8                               VARCHAR2(150) := FND_API.G_MISS_CHAR,
 ATTRIBUTE9                               VARCHAR2(150) := FND_API.G_MISS_CHAR,
 ATTRIBUTE10                              VARCHAR2(150) := FND_API.G_MISS_CHAR,
 ATTRIBUTE11                              VARCHAR2(150) := FND_API.G_MISS_CHAR,
 ATTRIBUTE12                              VARCHAR2(150) := FND_API.G_MISS_CHAR,
 ATTRIBUTE13                              VARCHAR2(150) := FND_API.G_MISS_CHAR,
 ATTRIBUTE14                              VARCHAR2(150) := FND_API.G_MISS_CHAR,
 ATTRIBUTE15                              VARCHAR2(150) := FND_API.G_MISS_CHAR,
 ATTRIBUTE_CATEGORY                       VARCHAR2(30) := FND_API.G_MISS_CHAR,
 RETURN_REASON_CODE                       VARCHAR2(30) := FND_API.G_MISS_CHAR,
 TRANSACTION_TYPE_ID          	          NUMBER       := FND_API.G_MISS_NUM,
 RETURN_DATE                              DATE         := FND_API.G_MISS_DATE
);

G_MISS_DEBRIEF_LINE_REC          DEBRIEF_LINE_Rec_Type;
TYPE  DEBRIEF_LINE_Tbl_Type      IS TABLE OF DEBRIEF_LINE_Rec_Type
                                    INDEX BY BINARY_INTEGER;
G_MISS_DEBRIEF_LINE_TBL          DEBRIEF_LINE_Tbl_Type;

--   API Name:  Create_debrief
--   Type    :  Private

PROCEDURE Create_debrief(
    P_Api_Version_Number    	IN   	NUMBER,
    P_Init_Msg_List         	IN   	VARCHAR2     := FND_API.G_FALSE,
    P_Commit                	IN   	VARCHAR2     := FND_API.G_FALSE,
    p_validation_level    	IN   	NUMBER       := FND_API.G_VALID_LEVEL_FULL,
    P_DEBRIEF_Rec       	IN    DEBRIEF_Rec_Type  := G_MISS_DEBRIEF_REC,
    P_DEBRIEF_LINE_tbl       	IN    DEBRIEF_LINE_tbl_type
								:= G_MISS_DEBRIEF_LINE_tbl,
    x_DEBRIEF_HEADER_ID     	OUT NOCOPY  NUMBER,
    X_Return_Status           OUT NOCOPY  VARCHAR2,
    X_Msg_Count               OUT NOCOPY  NUMBER,
    X_Msg_Data                OUT NOCOPY  VARCHAR2
    );

--   API Name:  Update_debrief

PROCEDURE Update_debrief(
    P_Api_Version_Number     	IN   	NUMBER,
    P_Init_Msg_List         	IN   	VARCHAR2 	:= FND_API.G_FALSE,
    P_Commit                	IN   	VARCHAR2 	:= FND_API.G_FALSE,
    p_validation_level       	IN  	NUMBER  	:= FND_API.G_VALID_LEVEL_FULL,
    P_debrief_Rec    		IN    debrief_Rec_Type,
    X_Return_Status         	OUT NOCOPY  	VARCHAR2,
    X_Msg_Count              	OUT NOCOPY  	NUMBER,
    X_Msg_Data               	OUT NOCOPY  	VARCHAR2
    );


PROCEDURE Create_debrief_lines(
    P_Api_Version_Number         IN   NUMBER,
    P_Init_Msg_List              IN   VARCHAR2     := FND_API.G_FALSE,
    P_Commit                     IN   VARCHAR2     := FND_API.G_FALSE,
    P_Upd_tskassgnstatus         IN VARCHAR2   DEFAULT NULL,
    P_Task_Assignment_status     IN VARCHAR2     DEFAULT NULL,
    p_validation_level           IN   NUMBER       := FND_API.G_VALID_LEVEL_FULL,
    P_DEBRIEF_LINE_tbl           IN    DEBRIEF_LINE_tbl_type,
							--	DEFAULT G_MISS_DEBRIEF_LINE_tbl,
    P_DEBRIEF_HEADER_ID          IN   NUMBER ,
    P_SOURCE_OBJECT_TYPE_CODE    IN   VARCHAR2,
    X_Return_Status              OUT NOCOPY  VARCHAR2,
    X_Msg_Count                  OUT NOCOPY  NUMBER,
    X_Msg_Data                   OUT NOCOPY  VARCHAR2
    ) ;


PROCEDURE Update_debrief_line(
    P_Api_Version_Number         IN   NUMBER,
    P_Init_Msg_List              IN   VARCHAR2    := FND_API.G_FALSE,
    P_Commit                     IN   VARCHAR2    := FND_API.G_FALSE,
    P_Upd_tskassgnstatus         IN VARCHAR2   DEFAULT NULL,
    P_Task_Assignment_status      IN VARCHAR2     DEFAULT NULL,
    p_validation_level           IN   NUMBER      := FND_API.G_VALID_LEVEL_FULL,
    P_DEBRIEF_LINE_Rec           IN OUT NOCOPY DEBRIEF_LINE_Rec_type,
    X_Return_Status              OUT NOCOPY  VARCHAR2,
    X_Msg_Count                  OUT NOCOPY  NUMBER,
    X_Msg_Data                   OUT NOCOPY  VARCHAR2
    ) ;

PROCEDURE Validate_Task_Assignment_ID (
	P_Init_Msg_List              IN   VARCHAR2     := FND_API.G_FALSE,
    	P_Validation_mode            IN   VARCHAR2,
    	P_TASK_Assignment_ID         IN   NUMBER,
    	X_Return_Status              OUT NOCOPY  VARCHAR2,
    	X_Msg_Count                  OUT NOCOPY  NUMBER,
    	X_Msg_Data                   OUT NOCOPY  VARCHAR2
);

PROCEDURE Validate_Debrief_Date (
	P_Init_Msg_List              IN   VARCHAR2     := FND_API.G_FALSE,
    	P_Validation_mode            IN   VARCHAR2,
    	P_Debrief_Date	            IN   DATE,
    	X_Return_Status              OUT NOCOPY  VARCHAR2,
    	X_Msg_Count                  OUT NOCOPY  NUMBER,
    	X_Msg_Data                   OUT NOCOPY  VARCHAR2
    );

PROCEDURE Validate_Service_Date (
	P_Init_Msg_List              IN   VARCHAR2     := FND_API.G_FALSE,
    	P_Service_Date	         	IN   DATE,
    	X_Return_Status              OUT NOCOPY  VARCHAR2,
    	X_Msg_Count                  OUT NOCOPY  NUMBER,
    	X_Msg_Data                   OUT NOCOPY  VARCHAR2
    );

PROCEDURE Validate_DEBRIEF_LINE_NUMBER (
	P_Init_Msg_List              IN   VARCHAR2     := FND_API.G_FALSE,
    	P_Validation_mode            IN   VARCHAR2,
    	P_DEBRIEF_LINE_NUMBER         IN   NUMBER,
    	X_Return_Status              OUT NOCOPY  VARCHAR2,
    	X_Msg_Count                  OUT NOCOPY  NUMBER,
    	X_Msg_Data                   OUT NOCOPY  VARCHAR2
);

PROCEDURE Validate_BUSINESS_PROCESS_ID (
	P_Init_Msg_List              IN   VARCHAR2     := FND_API.G_FALSE,
    	P_BUSINESS_PROCESS_ID        IN   NUMBER,
    	X_Return_Status              OUT NOCOPY  VARCHAR2,
    	X_Msg_Count                  OUT NOCOPY  NUMBER,
    	X_Msg_Data                   OUT NOCOPY  VARCHAR2
    );
PROCEDURE Validate_TRANSACTION_TYPE_ID (
	P_Init_Msg_List              IN   VARCHAR2     := FND_API.G_FALSE,
    	P_TRANSACTION_TYPE_ID        IN   NUMBER,
    	X_Return_Status              OUT NOCOPY  VARCHAR2,
    	X_Msg_Count                  OUT NOCOPY  NUMBER,
    	X_Msg_Data                   OUT NOCOPY  VARCHAR2
    );


PROCEDURE Validate_Inventory_Item_ID (
	P_Init_Msg_List              IN   VARCHAR2     := FND_API.G_FALSE,
	p_organization_id	     IN   NUMBER,
    	P_Inventory_Item_ID	     IN   NUMBER,
    	X_Return_Status              OUT NOCOPY  VARCHAR2,
    	X_Msg_Count                  OUT NOCOPY  NUMBER,
    	X_Msg_Data                   OUT NOCOPY  VARCHAR2 );

PROCEDURE Validate_Instance_ID (
	P_Init_Msg_List              IN   VARCHAR2     := FND_API.G_FALSE,
    	P_Instance_ID	     IN   NUMBER,
    	X_Return_Status              OUT NOCOPY  VARCHAR2,
    	X_Msg_Count                  OUT NOCOPY  NUMBER,
    	X_Msg_Data                   OUT NOCOPY  VARCHAR2 );


PROCEDURE Validate_Debrief_Header_ID (
	P_Init_Msg_List              IN   VARCHAR2     := FND_API.G_FALSE,
    	P_Debrief_Header_ID	     IN   NUMBER,
    	X_Return_Status              OUT NOCOPY  VARCHAR2,
    	X_Msg_Count                  OUT NOCOPY  NUMBER,
    	X_Msg_Data                   OUT NOCOPY  VARCHAR2);
PROCEDURE Validate_Task_Assignment_Satus(
    P_Api_Version_Number         IN   NUMBER,
    P_Init_Msg_List              IN   VARCHAR2    := FND_API.G_FALSE,
    P_Commit                     IN   VARCHAR2    := FND_API.G_FALSE,
    P_Task_Assignment_status     IN   VARCHAR2  DEFAULT  NULL,
    X_TA_STATUS_ID             OUT NOCOPY  NUMBER,
    X_Return_Status              OUT NOCOPY  VARCHAR2,
    X_Msg_Count                  OUT NOCOPY  NUMBER,
    X_Msg_Data                   OUT NOCOPY  VARCHAR2
    );
Function IS_DEBRIEF_HEADER_REC_MISSING(P_DEBRIEF_REC    DEBRIEF_REC_TYPE) Return BOOLEAN ;

Procedure CREATE_INTERACTION(P_Api_Version_Number         IN   NUMBER,
                              P_Init_Msg_List              IN   VARCHAR2     := FND_API.G_FALSE,
                              P_Commit                     IN   VARCHAR2     := FND_API.G_FALSE,
                              P_TASK_ASSIGNMENT_ID         IN   NUMBER,
                              P_DEBRIEF_HEADER_ID          IN   NUMBER,
                              P_MEDIA_ID                   IN   NUMBER,
                              P_ACTION_ID                  IN   NUMBER,
                              X_RETURN_STATUS              OUT NOCOPY  VARCHAR2,
                              X_Msg_Count                  OUT NOCOPY  NUMBER,
                              X_Msg_Data                   OUT NOCOPY  VARCHAR2) ;

PROCEDURE validate_subinventory_code (
        P_Init_Msg_List              IN   VARCHAR2     := FND_API.G_FALSE,
    	p_organization_id            IN   number,
        p_subinventory_code          in   varchar2,
    	X_Return_Status              OUT NOCOPY  VARCHAR2,
    	X_Msg_Count                  OUT NOCOPY  NUMBER,
    	X_Msg_Data                   OUT NOCOPY  VARCHAR2
    );

PROCEDURE UPDATE_TASK_ACTUAL_DATES (
      p_task_id                      IN NUMBER,
      p_actual_start_date            IN DATE,
      p_actual_end_date              IN DATE,
      x_return_status                OUT NOCOPY VARCHAR2,
      x_msg_count                    OUT NOCOPY NUMBER,
      x_msg_data                     OUT NOCOPY VARCHAR2
  ) ;

procedure update_actual_times (
  p_task_assignment_id    in number,
  x_return_status         out nocopy varchar2,
  x_msg_count             out nocopy number,
  x_msg_data              out nocopy varchar2);

PROCEDURE UPDATE_ACTUAL_TIMES (
      p_debrief_header_id            in number,
      p_start_date                   in date,
      p_end_date                     in date,
      x_return_status                out nocopy varchar2,
      x_msg_count                    out nocopy number,
      x_msg_data                     out nocopy varchar2
  ) ;
  PROCEDURE VALIDATE_COUNTERS (
      P_Init_Msg_List              IN   VARCHAR2     := FND_API.G_FALSE,
      p_task_id         in number,
      p_incident_id        in number,
      x_return_status              out nocopy varchar2,
      x_msg_count                  out nocopy number,
      x_msg_data                   out nocopy varchar2
  ) ;

PROCEDURE VALIDATE_LABOR_TIMES (
      P_Init_Msg_List              IN  VARCHAR2     := FND_API.G_FALSE,
      P_api_version_number         In  number,
      p_resource_type_code         in  Varchar2,
      p_resource_id                in  Number,
      p_debrief_line_id            in  Number,
      p_labor_start_date           in  Date,
      p_labor_end_date             in  Date,
      x_return_status              out nocopy varchar2,
      x_msg_count                  out nocopy number,
      x_msg_data                   out nocopy varchar2,
      x_debrief_number             out nocopy number,
      x_task_number                out nocopy varchar2
  ) ;

  PROCEDURE TASK_ASSIGNMENT_PRE_UPDATE(
      x_return_status out nocopy varchar2);

  PROCEDURE TASK_ASSIGNMENT_PRE_DELETE(
      x_return_status out nocopy varchar2);

  PROCEDURE TASK_ASSIGNMENT_POST_UPDATE(
      x_return_status out nocopy varchar2);

  function labor_auto_create(p_task_assignment_id in number) return varchar2;

  PROCEDURE CLOSE_DEBRIEF (
      p_task_assignment_id         in number,
      x_return_status              out nocopy varchar2,
      x_msg_count                  out nocopy number,
      x_msg_data                   out nocopy varchar2
  ) ;


-- When the labor line is deleted or updated, this procedure will update the task and task assignment details with actual start and end date

PROCEDURE update_task_actuals (
  p_debrief_header_id     in number,
  x_return_status         out nocopy varchar2,
  x_msg_count             out nocopy number,
  x_msg_data              out nocopy varchar2) ;

  Procedure validate_travel_times(p_actual_travel_start_time date,
                                p_actual_travel_end_time  date,
                                p_task_assignment_id       NUMBER,
                                P_Init_Msg_List              IN   VARCHAR2     := FND_API.G_FALSE,
                               	X_Return_Status              OUT NOCOPY  VARCHAR2,
                                X_Msg_Count                  OUT NOCOPY  NUMBER,
    	                        X_Msg_Data                   OUT NOCOPY  VARCHAR2);

END CSF_DEBRIEF_PVT;





/
