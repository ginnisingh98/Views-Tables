--------------------------------------------------------
--  DDL for Package CSD_SC_WORK_ENTITIES_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."CSD_SC_WORK_ENTITIES_PVT" AUTHID CURRENT_USER as
/* $Header: csdvscws.pls 115.1 2004/02/07 02:36:09 gilam noship $ */

/*--------------------------------------------------*/
/* Record name: SC_WORK_ENTITY_REC_TYPE             */
/* description : Record used for sc work entity rec */
/*                                                  */
/*--------------------------------------------------*/

TYPE SC_WORK_ENTITY_REC_TYPE  IS RECORD
(
  sc_work_entity_id		NUMBER,
  object_version_number		NUMBER,
  service_code_id            	NUMBER,
  work_entity_id1            	NUMBER,
  work_entity_type_code        	VARCHAR2(30),
  work_entity_id2            	NUMBER,
  work_entity_id3            	NUMBER,
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
/* procedure name: Create_SC_Work_Entity            */
/* description   : procedure used to create         */
/*                 sc work entity	            */
/*                                                  */
/*--------------------------------------------------*/
PROCEDURE Create_SC_Work_Entity
(
  p_api_version        		IN  NUMBER,
  p_commit	   		IN  VARCHAR2,
  p_init_msg_list      		IN  VARCHAR2,
  p_validation_level   		IN  NUMBER,
  x_return_status      		OUT NOCOPY VARCHAR2,
  x_msg_count          		OUT NOCOPY NUMBER,
  x_msg_data           		OUT NOCOPY VARCHAR2,
  p_sc_work_entity_rec	 	IN  SC_WORK_ENTITY_REC_TYPE,
  x_sc_work_entity_id 		OUT NOCOPY NUMBER
);


/*--------------------------------------------------*/
/* procedure name: Update_SC_Work_Entity            */
/* description   : procedure used to update         */
/*                 sc work entity	            */
/*                                                  */
/*--------------------------------------------------*/
PROCEDURE Update_SC_Work_Entity
(
  p_api_version        		IN  NUMBER,
  p_commit	   		IN  VARCHAR2,
  p_init_msg_list      		IN  VARCHAR2,
  p_validation_level   		IN  NUMBER,
  x_return_status      		OUT NOCOPY VARCHAR2,
  x_msg_count          		OUT NOCOPY NUMBER,
  x_msg_data           		OUT NOCOPY VARCHAR2,
  p_sc_work_entity_rec	 	IN  SC_WORK_ENTITY_REC_TYPE,
  x_obj_ver_number 		OUT NOCOPY NUMBER
);

/*--------------------------------------------------*/
/* procedure name: Delete_SC_Work_Entity            */
/* description   : procedure used to delete         */
/*                 sc work entity	            */
/*                                                  */
/*--------------------------------------------------*/
PROCEDURE Delete_SC_Work_Entity
(
  p_api_version        		IN  NUMBER,
  p_commit	   		IN  VARCHAR2,
  p_init_msg_list      		IN  VARCHAR2,
  p_validation_level   		IN  NUMBER,
  x_return_status      		OUT NOCOPY VARCHAR2,
  x_msg_count          		OUT NOCOPY NUMBER,
  x_msg_data           		OUT NOCOPY VARCHAR2,
  p_sc_work_entity_id	 	IN  NUMBER
);

/*--------------------------------------------------*/
/* procedure name: Lock_SC_Work_Entity              */
/* description   : procedure used to lock           */
/*                 sc work entity	            */
/*                                                  */
/*--------------------------------------------------*/
PROCEDURE Lock_SC_Work_Entity
(
  p_api_version        		IN  NUMBER,
  p_commit	   		IN  VARCHAR2,
  p_init_msg_list      		IN  VARCHAR2,
  p_validation_level   		IN  NUMBER,
  x_return_status      		OUT NOCOPY VARCHAR2,
  x_msg_count          		OUT NOCOPY NUMBER,
  x_msg_data           		OUT NOCOPY VARCHAR2,
  p_sc_work_entity_rec		IN  SC_WORK_ENTITY_REC_TYPE
);

End CSD_SC_WORK_ENTITIES_PVT;


 

/
