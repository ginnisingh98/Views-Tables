--------------------------------------------------------
--  DDL for Package OKE_DELIVERABLE_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OKE_DELIVERABLE_PVT" AUTHID CURRENT_USER AS
/* $Header: OKEVDELS.pls 115.22 2003/10/22 23:52:30 jxtang ship $ */

-- GLOBAL DATA STRUCTURES

TYPE del_rec_type IS RECORD(
 DELIVERABLE_ID                   	  NUMBER := OKE_API.G_MISS_NUM,
 DELIVERABLE_NUM                  	  VARCHAR2(150) := OKE_API.G_MISS_CHAR,
 PROJECT_ID                               NUMBER := OKE_API.G_MISS_NUM,
 TASK_ID                                  NUMBER := OKE_API.G_MISS_NUM,
 ITEM_ID                                  NUMBER := OKE_API.G_MISS_NUM,
 K_HEADER_ID                      	  NUMBER := OKE_API.G_MISS_NUM,
 K_LINE_ID                        	  NUMBER := OKE_API.G_MISS_NUM,
 DELIVERY_DATE                            DATE := OKE_API.G_MISS_DATE,
 STATUS_CODE                      	  VARCHAR2(30) := OKE_API.G_MISS_CHAR,
 PARENT_DELIVERABLE_ID                    NUMBER := OKE_API.G_MISS_NUM,
 SHIP_TO_ORG_ID				  NUMBER := OKE_API.G_MISS_NUM,
 SHIP_TO_LOCATION_ID			  NUMBER := OKE_API.G_MISS_NUM,
 SHIP_FROM_ORG_ID			  NUMBER := OKE_API.G_MISS_NUM,
 SHIP_FROM_LOCATION_ID			  NUMBER := OKE_API.G_MISS_NUM,
 DIRECTION				  VARCHAR2(3) := OKE_API.G_MISS_CHAR,
 INVENTORY_ORG_ID			  NUMBER := OKE_API.G_MISS_NUM,
 DEFAULTED_FLAG				  VARCHAR2(1) := OKE_API.G_MISS_CHAR,
 IN_PROCESS_FLAG			  VARCHAR2(1) := OKE_API.G_MISS_CHAR,
 WF_ITEM_KEY				  VARCHAR2(240) := OKE_API.G_MISS_CHAR,
 SUB_REF_ID                               NUMBER := OKE_API.G_MISS_NUM,
 START_DATE                               DATE := OKE_API.G_MISS_DATE,
 END_DATE                                 DATE := OKE_API.G_MISS_DATE,
 PRIORITY_CODE                            VARCHAR2(30) := OKE_API.G_MISS_CHAR,
 CURRENCY_CODE                            VARCHAR2(15) := OKE_API.G_MISS_CHAR,
 UNIT_PRICE                               NUMBER := OKE_API.G_MISS_NUM,
 UOM_CODE                                 VARCHAR2(30) := OKE_API.G_MISS_CHAR,
 QUANTITY                                 NUMBER := OKE_API.G_MISS_NUM,
 COUNTRY_OF_ORIGIN_CODE                   VARCHAR2(30) := OKE_API.G_MISS_CHAR,
 SUBCONTRACTED_FLAG                       VARCHAR2(1) := OKE_API.G_MISS_CHAR,
 DEPENDENCY_FLAG                          VARCHAR2(1) := OKE_API.G_MISS_CHAR,
 BILLABLE_FLAG                            VARCHAR2(1) := OKE_API.G_MISS_CHAR,
 BILLING_EVENT_ID                         NUMBER := OKE_API.G_MISS_NUM,
 DROP_SHIPPED_FLAG                        VARCHAR2(1) := OKE_API.G_MISS_CHAR,
 COMPLETED_FLAG                           VARCHAR2(1) := OKE_API.G_MISS_CHAR,
 AVAILABLE_FOR_SHIP_FLAG                  VARCHAR2(1) := OKE_API.G_MISS_CHAR,
 CREATE_DEMAND				  VARCHAR2(1) := OKE_API.G_MISS_CHAR,
 READY_TO_BILL				  VARCHAR2(1) := OKE_API.G_MISS_CHAR,
 NEED_BY_DATE				  DATE	      := OKE_API.G_MISS_DATE,
 READY_TO_PROCURE			  VARCHAR2(1) := OKE_API.G_MISS_CHAR,
 MPS_TRANSACTION_ID			  NUMBER := OKE_API.G_MISS_NUM,
 PO_REF_1				  NUMBER := OKE_API.G_MISS_NUM,
 PO_REF_2				  NUMBER := OKE_API.G_MISS_NUM,
 PO_REF_3				  NUMBER := OKE_API.G_MISS_NUM,
 SHIPPING_REQUEST_ID			  NUMBER := OKE_API.G_MISS_NUM,
 UNIT_NUMBER				  VARCHAR2(80) := OKE_API.G_MISS_CHAR,
 NDB_SCHEDULE_DESIGNATOR		  VARCHAR2(10) := OKE_API.G_MISS_CHAR,
 SHIPPABLE_FLAG                           VARCHAR2(1) := OKE_API.G_MISS_CHAR,
 CFE_REQ_FLAG                             VARCHAR2(1) := OKE_API.G_MISS_CHAR,
 INSPECTION_REQ_FLAG                      VARCHAR2(1) := OKE_API.G_MISS_CHAR,
 INTERIM_RPT_REQ_FLAG                     VARCHAR2(1) := OKE_API.G_MISS_CHAR,
 LOT_APPLIES_FLAG                         VARCHAR2(1) := OKE_API.G_MISS_CHAR,
 CUSTOMER_APPROVAL_REQ_FLAG               VARCHAR2(1) := OKE_API.G_MISS_CHAR,
 EXPECTED_SHIPMENT_DATE                   DATE := OKE_API.G_MISS_DATE,
 INITIATE_SHIPMENT_DATE                   DATE := OKE_API.G_MISS_DATE,
 PROMISED_SHIPMENT_DATE                   DATE := OKE_API.G_MISS_DATE,
 AS_OF_DATE                               DATE := OKE_API.G_MISS_DATE,
 DATE_OF_FIRST_SUBMISSION                 DATE := OKE_API.G_MISS_DATE,
 FREQUENCY                                VARCHAR2(30) := OKE_API.G_MISS_CHAR,
 ACQ_DOC_NUMBER                           VARCHAR2(30) := OKE_API.G_MISS_CHAR,
 SUBMISSION_FLAG                          VARCHAR2(1) := OKE_API.G_MISS_CHAR,
 DATA_ITEM_SUBTITLE                       VARCHAR2(30) := OKE_API.G_MISS_CHAR,
 TOTAL_NUM_OF_COPIES                      NUMBER := OKE_API.G_MISS_NUM,
 CDRL_CATEGORY                            VARCHAR2(30) := OKE_API.G_MISS_CHAR,
 DATA_ITEM_NAME                           VARCHAR2(30) := OKE_API.G_MISS_CHAR,
 EXPORT_FLAG                              VARCHAR2(1) := OKE_API.G_MISS_CHAR,
 EXPORT_LICENSE_NUM                       VARCHAR2(30) := OKE_API.G_MISS_CHAR,
 EXPORT_LICENSE_RES                       VARCHAR2(30) := OKE_API.G_MISS_CHAR,
 CREATED_BY                       	  NUMBER := OKE_API.G_MISS_NUM,
 CREATION_DATE                    	  DATE := OKE_API.G_MISS_DATE,
 LAST_UPDATED_BY                  	  NUMBER := OKE_API.G_MISS_NUM,
 LAST_UPDATE_LOGIN                        NUMBER := OKE_API.G_MISS_NUM,
 LAST_UPDATE_DATE                 	  DATE := OKE_API.G_MISS_DATE,
 ATTRIBUTE_CATEGORY                       VARCHAR2(30) := OKE_API.G_MISS_CHAR,
 ATTRIBUTE1                               VARCHAR2(150) := OKE_API.G_MISS_CHAR,
 ATTRIBUTE2                               VARCHAR2(150) := OKE_API.G_MISS_CHAR,
 ATTRIBUTE3                               VARCHAR2(150) := OKE_API.G_MISS_CHAR,
 ATTRIBUTE4                               VARCHAR2(150) := OKE_API.G_MISS_CHAR,
 ATTRIBUTE5                               VARCHAR2(150) := OKE_API.G_MISS_CHAR,
 ATTRIBUTE6                               VARCHAR2(150) := OKE_API.G_MISS_CHAR,
 ATTRIBUTE7                               VARCHAR2(150) := OKE_API.G_MISS_CHAR,
 ATTRIBUTE8                               VARCHAR2(150) := OKE_API.G_MISS_CHAR,
 ATTRIBUTE9                               VARCHAR2(150) := OKE_API.G_MISS_CHAR,
 ATTRIBUTE10                              VARCHAR2(150) := OKE_API.G_MISS_CHAR,
 ATTRIBUTE11                              VARCHAR2(150) := OKE_API.G_MISS_CHAR,
 ATTRIBUTE12                              VARCHAR2(150) := OKE_API.G_MISS_CHAR,
 ATTRIBUTE13                              VARCHAR2(150) := OKE_API.G_MISS_CHAR,
 ATTRIBUTE14                              VARCHAR2(150) := OKE_API.G_MISS_CHAR,
 ATTRIBUTE15                              VARCHAR2(150) := OKE_API.G_MISS_CHAR,
 DESCRIPTION                              VARCHAR2(240) := OKE_API.G_MISS_CHAR,
 COMMENTS                                 VARCHAR2(2000) := OKE_API.G_MISS_CHAR,
 SFWT_FLAG                        	  VARCHAR2(3)  := OKE_API.G_MISS_CHAR,
 WEIGHT					  NUMBER        := OKE_API.G_MISS_NUM,
 WEIGHT_UOM_CODE			  VARCHAR2(10)  := OKE_API.G_MISS_CHAR,
 VOLUME					  NUMBER	:= OKE_API.G_MISS_NUM,
 VOLUME_UOM_CODE			  VARCHAR2(10)  := OKE_API.G_MISS_CHAR,
 EXPENDITURE_ORGANIZATION_ID		  NUMBER        := OKE_API.G_MISS_NUM,
 EXPENDITURE_TYPE			  VARCHAR2(30)	:= OKE_API.G_MISS_CHAR,
 EXPENDITURE_ITEM_DATE			  DATE		:= OKE_API.G_MISS_DATE,
 DESTINATION_TYPE_CODE			  VARCHAR2(30)	:= OKE_API.G_MISS_CHAR,
 RATE_TYPE				  VARCHAR2(30)  := OKE_API.G_MISS_CHAR,
 RATE_DATE				  DATE		:= OKE_API.G_MISS_DATE,
 EXCHANGE_RATE				  NUMBER	:= OKE_API.G_MISS_NUM,
 REQUISITION_LINE_TYPE_ID		  NUMBER	:= OKE_API.G_MISS_NUM,
 PO_CATEGORY_ID				  NUMBER  	:= OKE_API.G_MISS_NUM);

TYPE del_tbl_type IS TABLE OF del_rec_type
INDEX BY BINARY_INTEGER;

-- GLOBAL MESSAGE CONSTANTS

  G_FND_APP			CONSTANT VARCHAR2(200) := OKE_API.G_FND_APP;

  G_FORM_UNABLE_TO_RESERVE_REC 	CONSTANT VARCHAR2(200) := OKE_API.G_FORM_UNABLE_TO_RESERVE_REC;
  G_FORM_RECORD_DELETED 	CONSTANT VARCHAR2(200) := OKE_API.G_FORM_RECORD_DELETED;

  G_FORM_RECORD_CHANGED 	CONSTANT VARCHAR2(200) := OKE_API.G_FORM_RECORD_CHANGED;

  G_RECORD_LOGICALLY_DELETED	CONSTANT VARCHAR2(200) := OKE_API.G_RECORD_LOGICALLY_DELETED;
  G_REQUIRED_VALUE		CONSTANT VARCHAR2(200) := OKE_API.G_REQUIRED_VALUE;
  G_INVALID_VALUE		CONSTANT VARCHAR2(200) := OKE_API.G_INVALID_VALUE;
  G_COL_NAME_TOKEN		CONSTANT VARCHAR2(200) := OKE_API.G_COL_NAME_TOKEN;
  G_PARENT_TABLE_TOKEN		CONSTANT VARCHAR2(200) := OKE_API.G_PARENT_TABLE_TOKEN;
  G_CHILD_TABLE_TOKEN		CONSTANT VARCHAR2(200) := OKE_API.G_CHILD_TABLE_TOKEN;
  G_PKG_NAME			CONSTANT VARCHAR2(200) := 'OKE_DELIVERABLE_PVT';
  G_APP_NAME			CONSTANT VARCHAR2(3)   :=  OKE_API.G_APP_NAME;
  G_FALSE			CONSTANT VARCHAR2(1)   := 'F';

-- Procedures and functions

  PROCEDURE insert_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_del_rec                      IN del_rec_type,
    x_del_rec                      OUT NOCOPY del_rec_type);

  PROCEDURE insert_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_del_tbl                     IN del_tbl_type,
    x_del_tbl                     OUT NOCOPY del_tbl_type);

  PROCEDURE update_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_del_rec                     IN del_rec_type,
    x_del_rec                     OUT NOCOPY del_rec_type);

  PROCEDURE update_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,

    p_del_tbl                     IN del_tbl_type,
    x_del_tbl                     OUT NOCOPY del_tbl_type);

  PROCEDURE delete_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_del_rec                     IN del_rec_type);

  PROCEDURE delete_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_del_tbl                     IN del_tbl_type);

  PROCEDURE validate_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_del_rec                     IN del_rec_type);

  PROCEDURE validate_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_del_tbl                     IN del_tbl_type);



  PROCEDURE lock_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_del_rec                     IN del_rec_type);



  PROCEDURE lock_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_del_tbl                     IN del_tbl_type);

  PROCEDURE add_language;

  FUNCTION check_dependency(p_deliverable_id Number) RETURN BOOLEAN;

END OKE_DELIVERABLE_PVT;


 

/
