--------------------------------------------------------
--  DDL for Package CSD_RT_TRANS_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."CSD_RT_TRANS_PVT" AUTHID CURRENT_USER as
/* $Header: csdvrtts.pls 120.0 2005/06/30 21:11:24 vkjain noship $ */

/*--------------------------------------------------*/
/* Record name: RT_TRAN_REC_TYPE                    */
/* description : Record used for repair type        */
/*               transitions rec                    */
/*                                                  */
/*--------------------------------------------------*/

TYPE RT_TRAN_REC_TYPE IS RECORD
(
  rt_tran_id	      	NUMBER,
  from_repair_type_id	      NUMBER,
  to_repair_type_id           NUMBER,
  common_flow_status_id       NUMBER,
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
/* procedure name: Create_Rt_Tran                   */
/* description   : procedure used to create         */
/*                 repair type transition 	    */
/*                                                  */
/*--------------------------------------------------*/
PROCEDURE Create_Rt_Tran
(
  p_api_version        		IN  NUMBER,
  p_commit	   		      IN  VARCHAR2,
  p_init_msg_list      		IN  VARCHAR2,
  p_validation_level   		IN  NUMBER,
  x_return_status      		OUT NOCOPY VARCHAR2,
  x_msg_count          		OUT NOCOPY NUMBER,
  x_msg_data           		OUT NOCOPY VARCHAR2,
  p_rt_tran_rec               IN  RT_TRAN_REC_TYPE,
  x_rt_tran_id 		      OUT NOCOPY NUMBER
);


/*--------------------------------------------------*/
/* procedure name: Update_Rt_Tran                   */
/* description   : procedure used to update         */
/*                 repair type transition 	    */
/*                                                  */
/*--------------------------------------------------*/
PROCEDURE Update_Rt_Tran
(
  p_api_version        		IN  NUMBER,
  p_commit	   		      IN  VARCHAR2,
  p_init_msg_list      		IN  VARCHAR2,
  p_validation_level   		IN  NUMBER,
  x_return_status      		OUT NOCOPY VARCHAR2,
  x_msg_count          		OUT NOCOPY NUMBER,
  x_msg_data           		OUT NOCOPY VARCHAR2,
  p_rt_tran_rec               IN  RT_TRAN_REC_TYPE,
  x_obj_ver_number 		OUT NOCOPY NUMBER
);

/*--------------------------------------------------*/
/* procedure name: Delete_Rt_Tran               */
/* description   : procedure used to delete         */
/*                 repair type transition 	    */
/*                                                  */
/*--------------------------------------------------*/
PROCEDURE Delete_Rt_Tran
(
  p_api_version        		IN  NUMBER,
  p_commit	   		      IN  VARCHAR2,
  p_init_msg_list      		IN  VARCHAR2,
  p_validation_level   		IN  NUMBER,
  x_return_status      		OUT NOCOPY VARCHAR2,
  x_msg_count          		OUT NOCOPY NUMBER,
  x_msg_data           		OUT NOCOPY VARCHAR2,
  p_rt_tran_id	            IN  NUMBER
);

/*--------------------------------------------------*/
/* procedure name: Lock_Rt_Tran                 */
/* description   : procedure used to lock           */
/*                 repair type transition 	    */
/*                                                  */
/*--------------------------------------------------*/
PROCEDURE Lock_Rt_Tran
(
  p_api_version        		IN  NUMBER,
  p_commit	   		      IN  VARCHAR2,
  p_init_msg_list      		IN  VARCHAR2,
  p_validation_level   		IN  NUMBER,
  x_return_status      		OUT NOCOPY VARCHAR2,
  x_msg_count          		OUT NOCOPY NUMBER,
  x_msg_data           		OUT NOCOPY VARCHAR2,
  p_rt_tran_rec               IN  RT_TRAN_REC_TYPE
);

End CSD_RT_TRANS_PVT;

 

/
