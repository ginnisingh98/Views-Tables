--------------------------------------------------------
--  DDL for Package CSD_FLWSTS_TRANS_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."CSD_FLWSTS_TRANS_PVT" AUTHID CURRENT_USER as
/* $Header: csdvflts.pls 120.0 2005/06/30 21:09:23 vkjain noship $ */

/*--------------------------------------------------*/
/* Record name: FLWSTS_TRAN_REC_TYPE                */
/* description : Record used for flow status        */
/*               transitions rec                    */
/*                                                  */
/*--------------------------------------------------*/

TYPE FLWSTS_TRAN_REC_TYPE IS RECORD
(
  flwsts_tran_id	      	NUMBER,
  repair_type_id	            NUMBER,
  from_flow_status_id         NUMBER,
  to_flow_status_id           NUMBER,
  wf_item_type                VARCHAR2(30),
  wf_process_name             VARCHAR2(80),
  reason_required_flag        VARCHAR2(1),
  capture_activity_flag       VARCHAR2(1),
  allow_all_resp_flag         VARCHAR2(1),
  description                 VARCHAR2(2000),
  object_version_number       NUMBER,
  created_by                  NUMBER,
  creation_date               DATE,
  last_updated_by             NUMBER,
  last_update_date            DATE,
  last_update_login           NUMBER
);

/*--------------------------------------------------*/
/* procedure name: Create_Flwsts_Tran               */
/* description   : procedure used to create         */
/*                 Flow Status transition 	    */
/*                                                  */
/*--------------------------------------------------*/
PROCEDURE Create_Flwsts_Tran
(
  p_api_version        		IN  NUMBER,
  p_commit	   		      IN  VARCHAR2,
  p_init_msg_list      		IN  VARCHAR2,
  p_validation_level   		IN  NUMBER,
  x_return_status      		OUT NOCOPY VARCHAR2,
  x_msg_count          		OUT NOCOPY NUMBER,
  x_msg_data           		OUT NOCOPY VARCHAR2,
  p_flwsts_tran_rec           IN  FLWSTS_TRAN_REC_TYPE,
  x_flwsts_tran_id 		OUT NOCOPY NUMBER
);


/*--------------------------------------------------*/
/* procedure name: Update_Flwsts_Tran               */
/* description   : procedure used to update         */
/*                 Flow Status transition 	    */
/*                                                  */
/*--------------------------------------------------*/
PROCEDURE Update_Flwsts_Tran
(
  p_api_version        		IN  NUMBER,
  p_commit	   		      IN  VARCHAR2,
  p_init_msg_list      		IN  VARCHAR2,
  p_validation_level   		IN  NUMBER,
  x_return_status      		OUT NOCOPY VARCHAR2,
  x_msg_count          		OUT NOCOPY NUMBER,
  x_msg_data           		OUT NOCOPY VARCHAR2,
  p_flwsts_tran_rec           IN  FLWSTS_TRAN_REC_TYPE,
  x_obj_ver_number 		OUT NOCOPY NUMBER
);

/*--------------------------------------------------*/
/* procedure name: Delete_Flwsts_Tran               */
/* description   : procedure used to delete         */
/*                 Flow Status transition 	    */
/*                                                  */
/*--------------------------------------------------*/
PROCEDURE Delete_Flwsts_Tran
(
  p_api_version        		IN  NUMBER,
  p_commit	   		      IN  VARCHAR2,
  p_init_msg_list      		IN  VARCHAR2,
  p_validation_level   		IN  NUMBER,
  x_return_status      		OUT NOCOPY VARCHAR2,
  x_msg_count          		OUT NOCOPY NUMBER,
  x_msg_data           		OUT NOCOPY VARCHAR2,
  p_flwsts_tran_id	 	IN  NUMBER
);

/*--------------------------------------------------*/
/* procedure name: Lock_Flwsts_Tran                 */
/* description   : procedure used to lock           */
/*                 Flow Status transition 	    */
/*                                                  */
/*--------------------------------------------------*/
PROCEDURE Lock_Flwsts_Tran
(
  p_api_version        		IN  NUMBER,
  p_commit	   		      IN  VARCHAR2,
  p_init_msg_list      		IN  VARCHAR2,
  p_validation_level   		IN  NUMBER,
  x_return_status      		OUT NOCOPY VARCHAR2,
  x_msg_count          		OUT NOCOPY NUMBER,
  x_msg_data           		OUT NOCOPY VARCHAR2,
  p_flwsts_tran_rec           IN  FLWSTS_TRAN_REC_TYPE
);

End CSD_FLWSTS_TRANS_PVT;

 

/
