--------------------------------------------------------
--  DDL for Package CSF_DEBRIEF_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."CSF_DEBRIEF_PUB" AUTHID CURRENT_USER as
--  $Header: csfpdbfs.pls 120.2 2007/12/11 22:42:54 hhaugeru ship $
/*#
 * This is the public interface for Debrief transactions.
 * The interface allows upload of Material, Labor and Expense transactions.
 * @rep:scope public
 * @rep:product CSF
 * @rep:displayname Debrief
 * @rep:lifecycle active
 * @rep:compatibility S
 * @rep:category BUSINESS_ENTITY CSF_TASK_DEBRIEF
 */
-- Start of Comments
-- Package name     : CSF_DEBRIEF_PUB
-- Purpose          :
-- History          :
-- NOTE             :
-- End of Comments
-- Default number of records fetch per call

G_DEFAULT_NUM_REC_FETCH  NUMBER := 30;
G_USER_ID         NUMBER := FND_GLOBAL.USER_ID;
G_LOGIN_ID        NUMBER := FND_GLOBAL.CONC_LOGIN_ID;

--   *******************************************************
--    Start of Comments
--   -------------------------------------------------------
--    Record name:DEBRIEF_Rec_Type
--   -------------------------------------------------------

TYPE DEBRIEF_Rec_Type IS RECORD
(
DEBRIEF_HEADER_ID                NUMBER		:=  	FND_API.G_MISS_NUM,
DEBRIEF_NUMBER                   VARCHAR2(50)	:= 	FND_API.G_MISS_CHAR,
DEBRIEF_DATE                     DATE		:= 	FND_API.G_MISS_DATE,
DEBRIEF_STATUS_ID                NUMBER		:=  	FND_API.G_MISS_NUM,
TASK_ASSIGNMENT_ID               NUMBER		:=  	FND_API.G_MISS_NUM,
CREATED_BY                       NUMBER		:=  	FND_API.G_MISS_NUM,
CREATION_DATE                    DATE		:= 	FND_API.G_MISS_DATE,
LAST_UPDATED_BY                  NUMBER		:=  	FND_API.G_MISS_NUM,
LAST_UPDATE_DATE                 DATE 		:= 	FND_API.G_MISS_DATE,
LAST_UPDATE_LOGIN                NUMBER		:=  	FND_API.G_MISS_NUM,
ATTRIBUTE1                       VARCHAR2(150)	:= 	FND_API.G_MISS_CHAR,
ATTRIBUTE2                       VARCHAR2(150)	:= 	FND_API.G_MISS_CHAR,
ATTRIBUTE3                       VARCHAR2(150)	:= 	FND_API.G_MISS_CHAR,
ATTRIBUTE4                       VARCHAR2(150)	:= 	FND_API.G_MISS_CHAR,
ATTRIBUTE5                       VARCHAR2(150)	:= 	FND_API.G_MISS_CHAR,
ATTRIBUTE6                       VARCHAR2(150)	:= 	FND_API.G_MISS_CHAR,
ATTRIBUTE7                       VARCHAR2(150)	:= 	FND_API.G_MISS_CHAR,
ATTRIBUTE8                       VARCHAR2(150)	:= 	FND_API.G_MISS_CHAR,
ATTRIBUTE9                       VARCHAR2(150)	:= 	FND_API.G_MISS_CHAR,
ATTRIBUTE10                      VARCHAR2(150)	:= 	FND_API.G_MISS_CHAR,
ATTRIBUTE11                      VARCHAR2(150)	:= 	FND_API.G_MISS_CHAR,
ATTRIBUTE12                      VARCHAR2(150)	:= 	FND_API.G_MISS_CHAR,
ATTRIBUTE13                      VARCHAR2(150)	:=	FND_API.G_MISS_CHAR,
ATTRIBUTE14                      VARCHAR2(150)	:= 	FND_API.G_MISS_CHAR,
ATTRIBUTE15                      VARCHAR2(150)	:= 	FND_API.G_MISS_CHAR,
ATTRIBUTE_CATEGORY               VARCHAR2(30)	:= 	FND_API.G_MISS_CHAR,
OBJECT_VERSION_NUMBER            NUMBER         :=      FND_API.G_MISS_NUM,
TRAVEL_START_TIME                DATE           :=      FND_API.G_MISS_DATE,
TRAVEL_END_TIME                  DATE           :=      FND_API.G_MISS_DATE,
TRAVEL_DISTANCE_IN_KM            NUMBER         :=      FND_API.G_MISS_NUM
);

G_MISS_DEBRIEF_REC          DEBRIEF_Rec_Type;
TYPE  DEBRIEF_Tbl_Type      IS TABLE OF DEBRIEF_Rec_Type
                                    INDEX BY BINARY_INTEGER;
G_MISS_DEBRIEF_TBL          DEBRIEF_Tbl_Type;

TYPE DEBRIEF_sort_rec_type IS RECORD
(
      DEBRIEF_HEADER_ID   NUMBER := NULL
);

TYPE DEBRIEF_LINE_Rec_Type IS RECORD
(
DEBRIEF_LINE_ID                 	NUMBER 		:= FND_API.G_MISS_NUM,
 DEBRIEF_HEADER_ID               	NUMBER 		:= FND_API.G_MISS_NUM,
 DEBRIEF_LINE_NUMBER             	NUMBER 		:= FND_API.G_MISS_NUM,
 SERVICE_DATE                    	DATE 	 	:= FND_API.G_MISS_DATE,
 BUSINESS_PROCESS_ID			NUMBER		:= FND_API.G_MISS_NUM,
 TXN_BILLING_TYPE_ID             	NUMBER 		:= FND_API.G_MISS_NUM,
 INVENTORY_ITEM_ID                      NUMBER 		:= FND_API.G_MISS_NUM,
 INSTANCE_ID                              NUMBER 		:= FND_API.G_MISS_NUM,
 ISSUING_INVENTORY_ORG_ID                 NUMBER 	:= FND_API.G_MISS_NUM,
 RECEIVING_INVENTORY_ORG_ID               NUMBER 	:= FND_API.G_MISS_NUM,
 ISSUING_SUB_INVENTORY_CODE               VARCHAR2(10) 	:= FND_API.G_MISS_CHAR,
 RECEIVING_SUB_INVENTORY_CODE             VARCHAR2(10) 	:= FND_API.G_MISS_CHAR,
 ISSUING_LOCATOR_ID                       NUMBER 	:= FND_API.G_MISS_NUM,
 RECEIVING_LOCATOR_ID                     NUMBER 	:= FND_API.G_MISS_NUM,
 PARENT_PRODUCT_ID                        NUMBER 	:= FND_API.G_MISS_NUM,
 REMOVED_PRODUCT_ID                       NUMBER 	:= FND_API.G_MISS_NUM,
 STATUS_OF_RECEIVED_PART                  VARCHAR2(30) 	:= FND_API.G_MISS_CHAR,
 ITEM_SERIAL_NUMBER                       VARCHAR2(30) 	:= FND_API.G_MISS_CHAR,
 ITEM_REVISION                            VARCHAR2(3) 	:= FND_API.G_MISS_CHAR,
 ITEM_LOTNUMBER                           VARCHAR2(80) 	:= FND_API.G_MISS_CHAR,
 UOM_CODE                                 VARCHAR2(3) 	:= FND_API.G_MISS_CHAR,
 QUANTITY                                 NUMBER 	:= FND_API.G_MISS_NUM,
 -- RMA_NUMBER                            NUMBER 	:= FND_API.G_MISS_NUM,
 RMA_HEADER_ID                            NUMBER 	:= FND_API.G_MISS_NUM,
 DISPOSITION_CODE                         VARCHAR2(30) 	:= FND_API.G_MISS_CHAR,
 MATERIAL_REASON_CODE                     VARCHAR2(30) 	:= FND_API.G_MISS_CHAR,
 LABOR_REASON_CODE                        VARCHAR2(30) 	:= FND_API.G_MISS_CHAR,
 EXPENSE_REASON_CODE                      VARCHAR2(30) 	:= FND_API.G_MISS_CHAR,
 LABOR_START_DATE                         DATE 		:= FND_API.G_MISS_DATE,
 LABOR_END_DATE                           DATE 		:= FND_API.G_MISS_DATE,
 STARTING_MILEAGE                         NUMBER 	:= FND_API.G_MISS_NUM,
 ENDING_MILEAGE                           NUMBER 	:= FND_API.G_MISS_NUM,
 EXPENSE_AMOUNT                           NUMBER 	:= FND_API.G_MISS_NUM,
 CURRENCY_CODE                            VARCHAR2(15) 	:= FND_API.G_MISS_CHAR,
 DEBRIEF_LINE_STATUS_ID                   NUMBER 	:= FND_API.G_MISS_NUM,
 CHANNEL_CODE                     		  VARCHAR2(30) 	:= FND_API.G_MISS_CHAR,
 CHARGE_UPLOAD_STATUS                     VARCHAR2(30) 	:= FND_API.G_MISS_CHAR,
 CHARGE_UPLOAD_MSG_CODE                   VARCHAR2(30) 	:= FND_API.G_MISS_CHAR,
 CHARGE_UPLOAD_MESSAGE                    VARCHAR2(240) := FND_API.G_MISS_CHAR,
 IB_UPDATE_STATUS                         VARCHAR2(30) 	:= FND_API.G_MISS_CHAR,
 IB_UPDATE_MSG_CODE                       VARCHAR2(30) 	:= FND_API.G_MISS_CHAR,
 IB_UPDATE_MESSAGE                        VARCHAR2(240) := FND_API.G_MISS_CHAR,
 SPARE_UPDATE_STATUS                      VARCHAR2(30) 	:= FND_API.G_MISS_CHAR,
 SPARE_UPDATE_MSG_CODE                    VARCHAR2(30) 	:= FND_API.G_MISS_CHAR,
 SPARE_UPDATE_MESSAGE                     VARCHAR2(240) := FND_API.G_MISS_CHAR,
 ERROR_TEXT                               VARCHAR2(2000):= FND_API.G_MISS_CHAR,
 CREATED_BY                      	  NUMBER 	:= FND_API.G_MISS_NUM,
 CREATION_DATE                   	  DATE 		:= FND_API.G_MISS_DATE,
 LAST_UPDATED_BY                 	  NUMBER 	:= FND_API.G_MISS_NUM,
 LAST_UPDATE_DATE                	  DATE 		:= FND_API.G_MISS_DATE,
 LAST_UPDATE_LOGIN                        NUMBER 	:= FND_API.G_MISS_NUM,
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
 ATTRIBUTE_CATEGORY                       VARCHAR2(30)  := FND_API.G_MISS_CHAR,
 RETURN_REASON_CODE                       VARCHAR2(30)  := FND_API.G_MISS_CHAR,
 TRANSACTION_TYPE_ID                      NUMBER	:= FND_API.G_MISS_NUM,
 RETURN_DATE                    	  DATE 	 	:= FND_API.G_MISS_DATE,
 MATERIAL_TRANSACTION_ID                  NUMBER 	:= FND_API.G_MISS_NUM,
 OBJECT_VERSION_NUMBER                    NUMBER        := FND_API.G_MISS_NUM
);

G_MISS_DEBRIEF_LINE_REC          DEBRIEF_LINE_Rec_Type;
TYPE  DEBRIEF_LINE_Tbl_Type      IS TABLE OF DEBRIEF_LINE_Rec_Type
                                    INDEX BY BINARY_INTEGER;
G_MISS_DEBRIEF_LINE_TBL          DEBRIEF_LINE_Tbl_Type;

TYPE DEBRIEF_LINE_sort_rec_type IS RECORD
(
      DEBRIEF_LINE_ID   NUMBER := NULL
);

--   API Name:  Create_Debrief
--
/*#
 * Creates a debrief header with lines.
 * @param p_api_version_number Specifies the version number of the API.
 * @param p_init_msg_list Specifies if the message stack should be cleared.
 * @param p_commit Specifies if the api should commit the transactions.
 * @param p_debrief_rec Record with debrief header information.
 * @param p_debrief_line_tbl List of debrief lines to be added.
 * @param x_debrief_header_id Returns the debrief header identifier.
 * @param x_return_status Returns the process status.
 * @param x_msg_count Returns the number of error messages.
 * @param x_msg_data Returns the error messages.
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:displayname Create Debrief Header and Lines
 */
PROCEDURE Create_DEBRIEF(
    p_api_version_number         IN   NUMBER,
    p_init_msg_list              IN   VARCHAR2     := FND_API.G_FALSE,
    p_commit                     IN   VARCHAR2     := FND_API.G_FALSE,
    p_debrief_rec     IN    DEBRIEF_Rec_Type  := G_MISS_DEBRIEF_REC,
    p_debrief_line_tbl        IN    DEBRIEF_LINE_tbl_type   ,
							--	DEFAULT G_MISS_DEBRIEF_LINE_tbl,
    x_debrief_header_id     OUT NOCOPY  NUMBER,
    x_return_status             OUT NOCOPY  VARCHAR2,
    x_msg_count                  OUT NOCOPY  NUMBER,
    x_msg_data                   OUT NOCOPY  VARCHAR2
    );


--   API Name:  Update_debrief
/*#
 * Updates an existing debrief header.
 * @param p_api_version_number Specifies the version number of the API.
 * @param p_init_msg_list Specifies if the message stack should be cleared.
 * @param p_commit Specifies if the api should commit the transactions.
 * @param p_debrief_rec Record with debrief header information.
 * @param x_return_status Returns the process status.
 * @param x_msg_count Returns the number of error messages.
 * @param x_msg_data Returns the error messages.
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:displayname Update a Debrief Header
 */
PROCEDURE Update_debrief(
    p_api_version_number         IN   NUMBER,
    p_init_msg_list              IN   VARCHAR2     := FND_API.G_FALSE,
    p_commit                     IN   VARCHAR2     := FND_API.G_FALSE,
    p_debrief_rec     	   IN    DEBRIEF_Rec_Type DEFAULT G_MISS_DEBRIEF_REC,
    x_return_status              OUT NOCOPY  VARCHAR2,
    x_msg_count                  OUT NOCOPY  NUMBER,
    x_msg_data                   OUT NOCOPY  VARCHAR2
    );

-- Start Lead_Line part
--   API Name:  Create_debrief_line
--

/*#
 * Adds debrief lines to an existing debrief header
 * @param p_api_version_number Specifies the version number of the API.
 * @param p_init_msg_list Specifies if the message stack should be cleared.
 * @param p_commit Specifies if the api should commit the transactions.
 * @param p_upd_tskassgnstatus Specifies if assignment status should be changed.
 * @param p_task_assignment_status Specifies the new assignment status.
 * @param p_debrief_line_tbl List of debrief lines to be added.
 * @param p_debrief_header_id Specifies the Debrief header identifier.
 * @param p_source_object_type_code Specifies the source object type.
 * @param x_return_status Returns the process status.
 * @param x_msg_count Returns the number of error messages.
 * @param x_msg_data Returns the error messages.
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:displayname Create Debrief Header and Lines
 */
PROCEDURE Create_debrief_lines(
    p_api_version_number         IN   NUMBER,
    p_init_msg_list              IN   VARCHAR2     := FND_API.G_FALSE,
    p_commit                     IN   VARCHAR2     := FND_API.G_FALSE,
    p_upd_tskassgnstatus         IN   VARCHAR2   DEFAULT NULL,
    p_task_assignment_status     IN   VARCHAR2     DEFAULT NULL,
    p_debrief_line_tbl           IN   DEBRIEF_LINE_Tbl_Type  := G_MISS_DEBRIEF_LINE_Tbl,
    p_debrief_header_id          IN   NUMBER,
    p_source_object_type_code    IN   VARCHAR2,
    x_return_status              OUT NOCOPY  VARCHAR2,
    x_msg_count                  OUT NOCOPY  NUMBER,
    x_msg_data                   OUT NOCOPY  VARCHAR2
    );

--   API Name:  Update_debrief_line
--

/*#
 * Updates an existing debrief line
 * @param p_api_version_number Specifies the version number of the API.
 * @param p_init_msg_list Specifies if the message stack should be cleared.
 * @param p_commit Specifies if the api should commit the transactions.
 * @param p_upd_tskassgnstatus Specifies if assignment status should be changed.
 * @param p_task_assignment_status Specifies the new assignment status.
 * @param p_debrief_line_rec Record with debrief line information.
 * @param x_return_status Returns the process status.
 * @param x_msg_count Returns the number of error messages.
 * @param x_msg_data Returns the error messages.
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:displayname Update Debrief Line
 */
PROCEDURE Update_debrief_line(
    p_api_version_number         IN   NUMBER,
    p_init_msg_list              IN   VARCHAR2     := FND_API.G_FALSE,
    p_commit                     IN   VARCHAR2     := FND_API.G_FALSE,
    p_upd_tskassgnstatus        IN VARCHAR2   DEFAULT NULL,
    p_task_assignment_status     IN VARCHAR2  DEFAULT  NULL,
    p_debrief_line_rec        IN    DEBRIEF_LINE_Rec_Type,
    x_return_status              OUT NOCOPY  VARCHAR2,
    x_msg_count                  OUT NOCOPY  NUMBER,
    x_msg_data                   OUT NOCOPY  VARCHAR2
    );
PROCEDURE call_internal_hook (
      p_package_name      IN       VARCHAR2,
      p_api_name          IN       VARCHAR2,
      p_processing_type   IN       VARCHAR2,
      x_return_status     OUT NOCOPY      VARCHAR2
   );

End CSF_DEBRIEF_PUB;


/
