--------------------------------------------------------
--  DDL for Package CSD_SERVICE_CODES_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."CSD_SERVICE_CODES_PVT" AUTHID CURRENT_USER as
/* $Header: csdvcscs.pls 115.2 2004/01/23 02:21:21 gilam noship $ */

/*--------------------------------------------------*/
/* Record name: SERVICE_CODE_REC_TYPE               */
/* description : Record used for service code rec   */
/*                                                  */
/*--------------------------------------------------*/

TYPE SERVICE_CODE_REC_TYPE  IS RECORD
(
  service_code_id		NUMBER,
  object_version_number		NUMBER,
  service_code            	VARCHAR2(30),
  name		             	VARCHAR2(80),
  description                	VARCHAR2(240),
  active_from                	DATE,
  active_to		     	DATE,
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
/* procedure name: Create_Service_Code              */
/* description   : procedure used to create         */
/*                 service code	                    */
/*                                                  */
/*--------------------------------------------------*/
PROCEDURE Create_Service_Code
(
  p_api_version        		IN  NUMBER,
  p_commit	   		IN  VARCHAR2,
  p_init_msg_list      		IN  VARCHAR2,
  p_validation_level   		IN  NUMBER,
  x_return_status      		OUT NOCOPY VARCHAR2,
  x_msg_count          		OUT NOCOPY NUMBER,
  x_msg_data           		OUT NOCOPY VARCHAR2,
  p_service_code_rec	 	IN  SERVICE_CODE_REC_TYPE,
  x_service_code_id 		OUT NOCOPY NUMBER
);


/*--------------------------------------------------*/
/* procedure name: Update_Service_Code              */
/* description   : procedure used to update         */
/*                 service code	                    */
/*                                                  */
/*--------------------------------------------------*/
PROCEDURE Update_Service_Code
(
  p_api_version        		IN  NUMBER,
  p_commit	   		IN  VARCHAR2,
  p_init_msg_list      		IN  VARCHAR2,
  p_validation_level   		IN  NUMBER,
  x_return_status      		OUT NOCOPY VARCHAR2,
  x_msg_count          		OUT NOCOPY NUMBER,
  x_msg_data           		OUT NOCOPY VARCHAR2,
  p_service_code_rec	 	IN  SERVICE_CODE_REC_TYPE,
  x_obj_ver_number 		OUT NOCOPY NUMBER
);

/*--------------------------------------------------*/
/* procedure name: Lock_Service_Code                */
/* description   : procedure used to lock           */
/*                 service code	                    */
/*                                                  */
/*--------------------------------------------------*/
PROCEDURE Lock_Service_Code
(
  p_api_version        		IN  NUMBER,
  p_commit	   		IN  VARCHAR2,
  p_init_msg_list      		IN  VARCHAR2,
  p_validation_level   		IN  NUMBER,
  x_return_status      		OUT NOCOPY VARCHAR2,
  x_msg_count          		OUT NOCOPY NUMBER,
  x_msg_data           		OUT NOCOPY VARCHAR2,
  p_service_code_rec		IN  SERVICE_CODE_REC_TYPE
);

End CSD_SERVICE_CODES_PVT;


 

/
