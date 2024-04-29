--------------------------------------------------------
--  DDL for Package CSD_DIAGNOSTIC_CODES_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."CSD_DIAGNOSTIC_CODES_PVT" AUTHID CURRENT_USER as
/* $Header: csdvcdcs.pls 115.3 2003/10/22 23:56:33 gilam noship $ */

/*--------------------------------------------------*/
/* Record name: DIAGNOSTIC_CODE_REC_TYPE            */
/* description : Record used for diagnostic code rec*/
/*                                                  */
/*--------------------------------------------------*/

TYPE DIAGNOSTIC_CODE_REC_TYPE  IS RECORD
(
  diagnostic_code_id		NUMBER,
  object_version_number		NUMBER,
  diagnostic_code            	VARCHAR2(30),
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
/* procedure name: Create_Diagnostic_Code           */
/* description   : procedure used to create         */
/*                 diagnostic code	            */
/*                                                  */
/*--------------------------------------------------*/
PROCEDURE Create_Diagnostic_Code
(
  p_api_version        		IN  NUMBER,
  p_commit	   		IN  VARCHAR2,
  p_init_msg_list      		IN  VARCHAR2,
  p_validation_level   		IN  NUMBER,
  x_return_status      		OUT NOCOPY VARCHAR2,
  x_msg_count          		OUT NOCOPY NUMBER,
  x_msg_data           		OUT NOCOPY VARCHAR2,
  p_diagnostic_code_rec	 	IN  DIAGNOSTIC_CODE_REC_TYPE,
  x_diagnostic_code_id 		OUT NOCOPY NUMBER
);


/*--------------------------------------------------*/
/* procedure name: Update_Diagnostic_Code           */
/* description   : procedure used to update         */
/*                 diagnostic code	            */
/*                                                  */
/*--------------------------------------------------*/
PROCEDURE Update_Diagnostic_Code
(
  p_api_version        		IN  NUMBER,
  p_commit	   		IN  VARCHAR2,
  p_init_msg_list      		IN  VARCHAR2,
  p_validation_level   		IN  NUMBER,
  x_return_status      		OUT NOCOPY VARCHAR2,
  x_msg_count          		OUT NOCOPY NUMBER,
  x_msg_data           		OUT NOCOPY VARCHAR2,
  p_diagnostic_code_rec	 	IN  DIAGNOSTIC_CODE_REC_TYPE,
  x_obj_ver_number 		OUT NOCOPY NUMBER
);

/*--------------------------------------------------*/
/* procedure name: Lock_Diagnostic_Code             */
/* description   : procedure used to lock           */
/*                 diagnostic code	            */
/*                                                  */
/*--------------------------------------------------*/
PROCEDURE Lock_Diagnostic_Code
(
  p_api_version        		IN  NUMBER,
  p_commit	   		IN  VARCHAR2,
  p_init_msg_list      		IN  VARCHAR2,
  p_validation_level   		IN  NUMBER,
  x_return_status      		OUT NOCOPY VARCHAR2,
  x_msg_count          		OUT NOCOPY NUMBER,
  x_msg_data           		OUT NOCOPY VARCHAR2,
  p_diagnostic_code_rec		IN  DIAGNOSTIC_CODE_REC_TYPE
);

End CSD_DIAGNOSTIC_CODES_PVT;


 

/
