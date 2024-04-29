--------------------------------------------------------
--  DDL for Package CSD_RO_DIAGNOSTIC_CODES_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."CSD_RO_DIAGNOSTIC_CODES_PVT" AUTHID CURRENT_USER as
/* $Header: csdvrdcs.pls 120.1 2006/09/20 00:16:52 rfieldma noship $ */

/*-----------------------------------------------------*/
/* Record name: RO_DIAGNOSTIC_CODE_REC_TYPE            */
/* description : Record used for ro diagnostic code rec*/
/*                                                     */
/*-----------------------------------------------------*/

TYPE RO_DIAGNOSTIC_CODE_REC_TYPE  IS RECORD
(
  ro_diagnostic_code_id		NUMBER,
  object_version_number		NUMBER,
  repair_line_id            	NUMBER,
  diagnostic_code_id           	NUMBER,
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
  diagnostic_item_id		NUMBER  -- rfieldma, 4666403
);

/*--------------------------------------------------*/
/* procedure name: Create_RO_Diagnostic_Code        */
/* description   : procedure used to create         */
/*                 ro diagnostic code	            */
/*                                                  */
/*--------------------------------------------------*/
PROCEDURE Create_RO_Diagnostic_Code
(
  p_api_version        		IN  NUMBER,
  p_commit	   		IN  VARCHAR2,
  p_init_msg_list      		IN  VARCHAR2,
  p_validation_level   		IN  NUMBER,
  x_return_status      		OUT NOCOPY VARCHAR2,
  x_msg_count          		OUT NOCOPY NUMBER,
  x_msg_data           		OUT NOCOPY VARCHAR2,
  p_ro_diagnostic_code_rec	IN  RO_DIAGNOSTIC_CODE_REC_TYPE,
  x_ro_diagnostic_code_id 	OUT NOCOPY NUMBER
);


/*--------------------------------------------------*/
/* procedure name: Update_RO_Diagnostic_Code        */
/* description   : procedure used to update         */
/*                 ro diagnostic code	            */
/*                                                  */
/*--------------------------------------------------*/
PROCEDURE Update_RO_Diagnostic_Code
(
  p_api_version        		IN  NUMBER,
  p_commit	   		IN  VARCHAR2,
  p_init_msg_list      		IN  VARCHAR2,
  p_validation_level   		IN  NUMBER,
  x_return_status      		OUT NOCOPY VARCHAR2,
  x_msg_count          		OUT NOCOPY NUMBER,
  x_msg_data           		OUT NOCOPY VARCHAR2,
  p_ro_diagnostic_code_rec	IN  RO_DIAGNOSTIC_CODE_REC_TYPE,
  x_obj_ver_number 		OUT NOCOPY NUMBER
);

/*--------------------------------------------------*/
/* procedure name: Delete_RO_Diagnostic_Code        */
/* description   : procedure used to delete         */
/*                 ro diagnostic code	            */
/*                                                  */
/*--------------------------------------------------*/
PROCEDURE Delete_RO_Diagnostic_Code
(
  p_api_version        		IN  NUMBER,
  p_commit	   		IN  VARCHAR2,
  p_init_msg_list      		IN  VARCHAR2,
  p_validation_level   		IN  NUMBER,
  x_return_status      		OUT NOCOPY VARCHAR2,
  x_msg_count          		OUT NOCOPY NUMBER,
  x_msg_data           		OUT NOCOPY VARCHAR2,
  p_ro_diagnostic_code_id	IN  NUMBER
);

/*--------------------------------------------------*/
/* procedure name: Lock_RO_Diagnostic_Code          */
/* description   : procedure used to lock           */
/*                 ro diagnostic code	            */
/*                                                  */
/*--------------------------------------------------*/
PROCEDURE Lock_RO_Diagnostic_Code
(
  p_api_version        		IN  NUMBER,
  p_commit	   		IN  VARCHAR2,
  p_init_msg_list      		IN  VARCHAR2,
  p_validation_level   		IN  NUMBER,
  x_return_status      		OUT NOCOPY VARCHAR2,
  x_msg_count          		OUT NOCOPY NUMBER,
  x_msg_data           		OUT NOCOPY VARCHAR2,
  p_ro_diagnostic_code_rec	IN  RO_DIAGNOSTIC_CODE_REC_TYPE
);

End CSD_RO_DIAGNOSTIC_CODES_PVT;

 

/
