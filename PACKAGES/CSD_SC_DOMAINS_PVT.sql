--------------------------------------------------------
--  DDL for Package CSD_SC_DOMAINS_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."CSD_SC_DOMAINS_PVT" AUTHID CURRENT_USER as
/* $Header: csdvscds.pls 115.1 2004/01/23 02:16:01 gilam noship $ */

/*--------------------------------------------------*/
/* Record name: SC_DOMAIN_REC_TYPE                  */
/* description : Record used for sc domain rec      */
/*                                                  */
/*--------------------------------------------------*/

TYPE SC_DOMAIN_REC_TYPE  IS RECORD
(
  sc_domain_id		        NUMBER,
  object_version_number		NUMBER,
  service_code_id            	NUMBER,
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
/* procedure name: Create_SC_Domain                 */
/* description   : procedure used to create         */
/*                 sc domain	                    */
/*                                                  */
/*--------------------------------------------------*/
PROCEDURE Create_SC_Domain
(
  p_api_version        		IN  NUMBER,
  p_commit	   		IN  VARCHAR2,
  p_init_msg_list      		IN  VARCHAR2,
  p_validation_level   		IN  NUMBER,
  x_return_status      		OUT NOCOPY VARCHAR2,
  x_msg_count          		OUT NOCOPY NUMBER,
  x_msg_data           		OUT NOCOPY VARCHAR2,
  p_sc_domain_rec	 	IN  SC_DOMAIN_REC_TYPE,
  x_sc_domain_id 		OUT NOCOPY NUMBER
);


/*--------------------------------------------------*/
/* procedure name: Update_SC_Domain                 */
/* description   : procedure used to update         */
/*                 sc domain	                    */
/*                                                  */
/*--------------------------------------------------*/
PROCEDURE Update_SC_Domain
(
  p_api_version        		IN  NUMBER,
  p_commit	   		IN  VARCHAR2,
  p_init_msg_list      		IN  VARCHAR2,
  p_validation_level   		IN  NUMBER,
  x_return_status      		OUT NOCOPY VARCHAR2,
  x_msg_count          		OUT NOCOPY NUMBER,
  x_msg_data           		OUT NOCOPY VARCHAR2,
  p_sc_domain_rec	 	IN  SC_DOMAIN_REC_TYPE,
  x_obj_ver_number 		OUT NOCOPY NUMBER
);

/*--------------------------------------------------*/
/* procedure name: Delete_SC_Domain                 */
/* description   : procedure used to delete         */
/*                 sc domain	                    */
/*                                                  */
/*--------------------------------------------------*/
PROCEDURE Delete_SC_Domain
(
  p_api_version        		IN  NUMBER,
  p_commit	   		IN  VARCHAR2,
  p_init_msg_list      		IN  VARCHAR2,
  p_validation_level   		IN  NUMBER,
  x_return_status      		OUT NOCOPY VARCHAR2,
  x_msg_count          		OUT NOCOPY NUMBER,
  x_msg_data           		OUT NOCOPY VARCHAR2,
  p_sc_domain_id	 	IN  NUMBER
);

/*--------------------------------------------------*/
/* procedure name: Lock_SC_Domain                   */
/* description   : procedure used to lock           */
/*                 sc domain	                    */
/*                                                  */
/*--------------------------------------------------*/
PROCEDURE Lock_SC_Domain
(
  p_api_version        		IN  NUMBER,
  p_commit	   		IN  VARCHAR2,
  p_init_msg_list      		IN  VARCHAR2,
  p_validation_level   		IN  NUMBER,
  x_return_status      		OUT NOCOPY VARCHAR2,
  x_msg_count          		OUT NOCOPY NUMBER,
  x_msg_data           		OUT NOCOPY VARCHAR2,
  p_sc_domain_rec		IN  SC_DOMAIN_REC_TYPE
);

End CSD_SC_DOMAINS_PVT;


 

/
