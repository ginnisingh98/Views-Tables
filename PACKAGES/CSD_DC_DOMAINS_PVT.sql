--------------------------------------------------------
--  DDL for Package CSD_DC_DOMAINS_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."CSD_DC_DOMAINS_PVT" AUTHID CURRENT_USER as
/* $Header: csdvdcds.pls 115.1 2004/01/23 02:17:24 gilam noship $ */

/*--------------------------------------------------*/
/* Record name: DC_DOMAIN_REC_TYPE                  */
/* description : Record used for dc domain rec      */
/*                                                  */
/*--------------------------------------------------*/

TYPE DC_DOMAIN_REC_TYPE  IS RECORD
(
  dc_domain_id		        NUMBER,
  object_version_number		NUMBER,
  diagnostic_code_id            NUMBER,
  inventory_item_id            	NUMBER,
  category_id            	NUMBER,
  category_set_id            	NUMBER,
  domain_type_code             	VARCHAR2(30),
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
/* procedure name: Create_DC_Domain                 */
/* description   : procedure used to create         */
/*                 dc domain	                    */
/*                                                  */
/*--------------------------------------------------*/
PROCEDURE Create_DC_Domain
(
  p_api_version        		IN  NUMBER,
  p_commit	   		IN  VARCHAR2,
  p_init_msg_list      		IN  VARCHAR2,
  p_validation_level   		IN  NUMBER,
  x_return_status      		OUT NOCOPY VARCHAR2,
  x_msg_count          		OUT NOCOPY NUMBER,
  x_msg_data           		OUT NOCOPY VARCHAR2,
  p_dc_domain_rec	 	IN  DC_DOMAIN_REC_TYPE,
  x_dc_domain_id 		OUT NOCOPY NUMBER
);


/*--------------------------------------------------*/
/* procedure name: Update_DC_Domain                 */
/* description   : procedure used to update         */
/*                 dc domain	                    */
/*                                                  */
/*--------------------------------------------------*/
PROCEDURE Update_DC_Domain
(
  p_api_version        		IN  NUMBER,
  p_commit	   		IN  VARCHAR2,
  p_init_msg_list      		IN  VARCHAR2,
  p_validation_level   		IN  NUMBER,
  x_return_status      		OUT NOCOPY VARCHAR2,
  x_msg_count          		OUT NOCOPY NUMBER,
  x_msg_data           		OUT NOCOPY VARCHAR2,
  p_dc_domain_rec	 	IN  DC_DOMAIN_REC_TYPE,
  x_obj_ver_number 		OUT NOCOPY NUMBER
);

/*--------------------------------------------------*/
/* procedure name: Delete_DC_Domain                 */
/* description   : procedure used to delete         */
/*                 dc domain	                    */
/*                                                  */
/*--------------------------------------------------*/
PROCEDURE Delete_DC_Domain
(
  p_api_version        		IN  NUMBER,
  p_commit	   		IN  VARCHAR2,
  p_init_msg_list      		IN  VARCHAR2,
  p_validation_level   		IN  NUMBER,
  x_return_status      		OUT NOCOPY VARCHAR2,
  x_msg_count          		OUT NOCOPY NUMBER,
  x_msg_data           		OUT NOCOPY VARCHAR2,
  p_dc_domain_id	 	IN  NUMBER
);

/*--------------------------------------------------*/
/* procedure name: Lock_DC_Domain                   */
/* description   : procedure used to lock           */
/*                 dc domain	                    */
/*                                                  */
/*--------------------------------------------------*/
PROCEDURE Lock_DC_Domain
(
  p_api_version        		IN  NUMBER,
  p_commit	   		IN  VARCHAR2,
  p_init_msg_list      		IN  VARCHAR2,
  p_validation_level   		IN  NUMBER,
  x_return_status      		OUT NOCOPY VARCHAR2,
  x_msg_count          		OUT NOCOPY NUMBER,
  x_msg_data           		OUT NOCOPY VARCHAR2,
  p_dc_domain_rec		IN  DC_DOMAIN_REC_TYPE
);

End CSD_DC_DOMAINS_PVT;


 

/
