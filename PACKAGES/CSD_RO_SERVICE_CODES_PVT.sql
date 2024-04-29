--------------------------------------------------------
--  DDL for Package CSD_RO_SERVICE_CODES_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."CSD_RO_SERVICE_CODES_PVT" AUTHID CURRENT_USER as
/* $Header: csdvrscs.pls 120.1 2006/09/19 23:12:53 rfieldma noship $ */

/*--------------------------------------------------*/
/* Record name: RO_SERVICE_CODE_REC_TYPE            */
/* description : Record used for ro service code rec*/
/*                                                  */
/*--------------------------------------------------*/

TYPE RO_SERVICE_CODE_REC_TYPE  IS RECORD
(
  ro_service_code_id		NUMBER,
  object_version_number		NUMBER,
  repair_line_id            	NUMBER,
  service_code_id            	NUMBER,
  source_type_code             	VARCHAR2(30),
  source_solution_id          	NUMBER,
  applicable_flag           	VARCHAR2(1),
  applied_to_est_flag       	VARCHAR2(1),
  applied_to_work_flag      	VARCHAR2(1),
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
  attribute15                	VARCHAR2(150),
  service_item_id			NUMBER -- rfieldma, 4666403
);

/*--------------------------------------------------*/
/* procedure name: Create_RO_Service_Code           */
/* description   : procedure used to create         */
/*                 ro service code	            */
/*                                                  */
/*--------------------------------------------------*/
PROCEDURE Create_RO_Service_Code
(
  p_api_version        		IN  NUMBER,
  p_commit	   		IN  VARCHAR2,
  p_init_msg_list      		IN  VARCHAR2,
  p_validation_level   		IN  NUMBER,
  x_return_status      		OUT NOCOPY VARCHAR2,
  x_msg_count          		OUT NOCOPY NUMBER,
  x_msg_data           		OUT NOCOPY VARCHAR2,
  p_ro_service_code_rec	 	IN  RO_SERVICE_CODE_REC_TYPE,
  x_ro_service_code_id 		OUT NOCOPY NUMBER
);


/*--------------------------------------------------*/
/* procedure name: Update_RO_Service_Code           */
/* description   : procedure used to update         */
/*                 ro service code	            */
/*                                                  */
/*--------------------------------------------------*/
PROCEDURE Update_RO_Service_Code
(
  p_api_version        		IN  NUMBER,
  p_commit	   		IN  VARCHAR2,
  p_init_msg_list      		IN  VARCHAR2,
  p_validation_level   		IN  NUMBER,
  x_return_status      		OUT NOCOPY VARCHAR2,
  x_msg_count          		OUT NOCOPY NUMBER,
  x_msg_data           		OUT NOCOPY VARCHAR2,
  p_ro_service_code_rec	 	IN  RO_SERVICE_CODE_REC_TYPE,
  x_obj_ver_number 		OUT NOCOPY NUMBER
);

/*--------------------------------------------------*/
/* procedure name: Delete_RO_Service_Code           */
/* description   : procedure used to delete         */
/*                 ro service code	            */
/*                                                  */
/*--------------------------------------------------*/
PROCEDURE Delete_RO_Service_Code
(
  p_api_version        		IN  NUMBER,
  p_commit	   		IN  VARCHAR2,
  p_init_msg_list      		IN  VARCHAR2,
  p_validation_level   		IN  NUMBER,
  x_return_status      		OUT NOCOPY VARCHAR2,
  x_msg_count          		OUT NOCOPY NUMBER,
  x_msg_data           		OUT NOCOPY VARCHAR2,
  p_ro_service_code_id	 	IN  NUMBER
);

/*--------------------------------------------------*/
/* procedure name: Lock_RO_Service_Code             */
/* description   : procedure used to lock           */
/*                 ro service code	            */
/*                                                  */
/*--------------------------------------------------*/
PROCEDURE Lock_RO_Service_Code
(
  p_api_version        		IN  NUMBER,
  p_commit	   		IN  VARCHAR2,
  p_init_msg_list      		IN  VARCHAR2,
  p_validation_level   		IN  NUMBER,
  x_return_status      		OUT NOCOPY VARCHAR2,
  x_msg_count          		OUT NOCOPY NUMBER,
  x_msg_data           		OUT NOCOPY VARCHAR2,
  p_ro_service_code_rec		IN  RO_SERVICE_CODE_REC_TYPE
);

End CSD_RO_SERVICE_CODES_PVT;

 

/
