--------------------------------------------------------
--  DDL for Package CSD_REPAIR_MILESTONES_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."CSD_REPAIR_MILESTONES_PVT" AUTHID CURRENT_USER as
/* $Header: csdvroms.pls 120.0 2005/07/14 18:57:46 vkjain noship $ */

/*--------------------------------------------------*/
/* Record name: REPAIR_MILESTONE_REC_TYPE           */
/* description : Record used for repair             */
/*               milestone rec                      */
/*                                                  */
/*--------------------------------------------------*/

TYPE REPAIR_MILESTONE_REC_TYPE IS RECORD
(
  repair_milestone_id      	NUMBER,
  repair_line_id	      	NUMBER,
  milestone_code              VARCHAR2(30),
  milestone_date              DATE,
  object_version_number       NUMBER,
  created_by                  NUMBER,
  creation_date               DATE,
  last_updated_by             NUMBER,
  last_update_date            DATE,
  last_update_login           NUMBER
);

/*--------------------------------------------------*/
/* procedure name: Create_Repair_Milestone          */
/* description   : procedure used to create         */
/*                 repair milestone                 */
/*                                                  */
/*--------------------------------------------------*/
PROCEDURE Create_Repair_Milestone
(
  p_api_version        		IN  NUMBER,
  p_commit	   		      IN  VARCHAR2,
  p_init_msg_list      		IN  VARCHAR2,
  p_validation_level   		IN  NUMBER,
  x_return_status      		OUT NOCOPY VARCHAR2,
  x_msg_count          		OUT NOCOPY NUMBER,
  x_msg_data           		OUT NOCOPY VARCHAR2,
  p_repair_milestone_rec      IN  REPAIR_MILESTONE_REC_TYPE,
  x_repair_milestone_id		OUT NOCOPY NUMBER
);


/*--------------------------------------------------*/
/* procedure name: Update_Repair_Milestone          */
/* description   : procedure used to update         */
/*                 repair milestone                 */
/*                                                  */
/*--------------------------------------------------*/
PROCEDURE Update_Repair_Milestone
(
  p_api_version        		IN  NUMBER,
  p_commit	   		      IN  VARCHAR2,
  p_init_msg_list      		IN  VARCHAR2,
  p_validation_level   		IN  NUMBER,
  x_return_status      		OUT NOCOPY VARCHAR2,
  x_msg_count          		OUT NOCOPY NUMBER,
  x_msg_data           		OUT NOCOPY VARCHAR2,
  p_repair_milestone_rec      IN  REPAIR_MILESTONE_REC_TYPE,
  x_obj_ver_number 		OUT NOCOPY NUMBER
);

/*--------------------------------------------------*/
/* procedure name: Delete_Repair_Milestone          */
/* description   : procedure used to delete         */
/*                 repair milestone                 */
/*                                                  */
/*--------------------------------------------------*/
PROCEDURE Delete_Repair_Milestone
(
  p_api_version        		IN  NUMBER,
  p_commit	   		      IN  VARCHAR2,
  p_init_msg_list      		IN  VARCHAR2,
  p_validation_level   		IN  NUMBER,
  x_return_status      		OUT NOCOPY VARCHAR2,
  x_msg_count          		OUT NOCOPY NUMBER,
  x_msg_data           		OUT NOCOPY VARCHAR2,
  p_repair_milestone_id	 	IN  NUMBER
);

/*--------------------------------------------------*/
/* procedure name: Lock_Repair_Milestone            */
/* description   : procedure used to lock           */
/*                 repair milestone                 */
/*                                                  */
/*--------------------------------------------------*/
PROCEDURE Lock_Repair_Milestone
(
  p_api_version        		IN  NUMBER,
  p_commit	   		      IN  VARCHAR2,
  p_init_msg_list      		IN  VARCHAR2,
  p_validation_level   		IN  NUMBER,
  x_return_status      		OUT NOCOPY VARCHAR2,
  x_msg_count          		OUT NOCOPY NUMBER,
  x_msg_data           		OUT NOCOPY VARCHAR2,
  p_repair_milestone_rec      IN  REPAIR_MILESTONE_REC_TYPE
);

End CSD_REPAIR_MILESTONES_PVT;

 

/
