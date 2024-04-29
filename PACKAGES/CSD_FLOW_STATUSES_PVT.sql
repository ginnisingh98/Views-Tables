--------------------------------------------------------
--  DDL for Package CSD_FLOW_STATUSES_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."CSD_FLOW_STATUSES_PVT" AUTHID CURRENT_USER as
/* $Header: csdvflss.pls 120.0 2005/06/14 10:04:25 vkjain noship $ */

/*--------------------------------------------------*/
/* Record name: FLOW_STATUS_REC_TYPE                */
/* description : Record used for flow statuses rec  */
/*                                                  */
/*--------------------------------------------------*/

TYPE FLOW_STATUS_REC_TYPE IS RECORD
(
  flow_status_id	      	NUMBER,
  flow_status_code            VARCHAR2(30),
  status_code                 VARCHAR2(30),
  seeded_flag                 VARCHAR2(1),
  object_version_number		NUMBER,
  external_display_status     VARCHAR2(300),
  attribute_category         	VARCHAR2(30),
  attribute1                 	VARCHAR2(150),
  attribute2                 	VARCHAR2(150),
  attribute3                 	VARCHAR2(150),
  attribute4                 	VARCHAR2(150),
  attribute5                 	VARCHAR2(150),
  attribute6                 	VARCHAR2(150),
  attribute7                 	VARCHAR2(150),
  attribute8                 	VARCHAR2(150),
  attribute9                 	VARCHAR2(150),
  attribute10                	VARCHAR2(150),
  attribute11                	VARCHAR2(150),
  attribute12                	VARCHAR2(150),
  attribute13                	VARCHAR2(150),
  attribute14                	VARCHAR2(150),
  attribute15                	VARCHAR2(150)
);

/*--------------------------------------------------*/
/* procedure name: Create_Flow_Status               */
/* description   : procedure used to create         */
/*                 Flow Status 	                 */
/*                                                  */
/*--------------------------------------------------*/
PROCEDURE Create_Flow_Status
(
  p_api_version        		IN  NUMBER,
  p_commit	   		      IN  VARCHAR2,
  p_init_msg_list      		IN  VARCHAR2,
  p_validation_level   		IN  NUMBER,
  x_return_status      		OUT NOCOPY VARCHAR2,
  x_msg_count          		OUT NOCOPY NUMBER,
  x_msg_data           		OUT NOCOPY VARCHAR2,
  p_flow_status_rec      IN  FLOW_STATUS_REC_TYPE,
  x_flow_status_id 		OUT NOCOPY NUMBER
);


/*--------------------------------------------------*/
/* procedure name: Update_Flow_Status               */
/* description   : procedure used to update         */
/*                 Flow Status    	                */
/*                                                  */
/*--------------------------------------------------*/
PROCEDURE Update_Flow_Status
(
  p_api_version        		IN  NUMBER,
  p_commit	   		      IN  VARCHAR2,
  p_init_msg_list      		IN  VARCHAR2,
  p_validation_level   		IN  NUMBER,
  x_return_status      		OUT NOCOPY VARCHAR2,
  x_msg_count          		OUT NOCOPY NUMBER,
  x_msg_data           		OUT NOCOPY VARCHAR2,
  p_flow_status_rec      IN  FLOW_STATUS_REC_TYPE,
  x_obj_ver_number 		OUT NOCOPY NUMBER
);

/*--------------------------------------------------*/
/* procedure name: Delete_Flow_Status               */
/* description   : procedure used to delete         */
/*                 Flow Status	                */
/*                                                  */
/*--------------------------------------------------*/
PROCEDURE Delete_Flow_Status
(
  p_api_version        		IN  NUMBER,
  p_commit	   		      IN  VARCHAR2,
  p_init_msg_list      		IN  VARCHAR2,
  p_validation_level   		IN  NUMBER,
  x_return_status      		OUT NOCOPY VARCHAR2,
  x_msg_count          		OUT NOCOPY NUMBER,
  x_msg_data           		OUT NOCOPY VARCHAR2,
  p_flow_status_id	 	IN  NUMBER
);

/*--------------------------------------------------*/
/* procedure name: Lock_Flow_Status                 */
/* description   : procedure used to lock           */
/*                 Flow Status                      */
/*                                                  */
/*--------------------------------------------------*/
PROCEDURE Lock_Flow_Status
(
  p_api_version        		IN  NUMBER,
  p_commit	   		      IN  VARCHAR2,
  p_init_msg_list      		IN  VARCHAR2,
  p_validation_level   		IN  NUMBER,
  x_return_status      		OUT NOCOPY VARCHAR2,
  x_msg_count          		OUT NOCOPY NUMBER,
  x_msg_data           		OUT NOCOPY VARCHAR2,
  p_flow_status_rec      IN  FLOW_STATUS_REC_TYPE
);

End CSD_FLOW_STATUSES_PVT;

 

/
