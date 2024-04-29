--------------------------------------------------------
--  DDL for Package CSD_RT_TRAN_RESPS_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."CSD_RT_TRAN_RESPS_PVT" AUTHID CURRENT_USER as
/* $Header: csdvrtrs.pls 120.0 2005/06/30 21:10:42 vkjain noship $ */

/*--------------------------------------------------*/
/* Record name: RT_TRAN_RESP_REC_TYPE               */
/* description : Record used for repair type        */
/*               transition responsibility rec      */
/*                                                  */
/*--------------------------------------------------*/

TYPE RT_TRAN_RESP_REC_TYPE IS RECORD
(
  rt_tran_resp_id      	      NUMBER,
  rt_tran_id	      	NUMBER,
  responsibility_id           NUMBER,
  object_version_number       NUMBER,
  created_by                  NUMBER,
  creation_date               DATE,
  last_updated_by             NUMBER,
  last_update_date            DATE,
  last_update_login           NUMBER
);

/*--------------------------------------------------*/
/* procedure name: Create_Rt_Tran_Resp          */
/* description   : procedure used to create         */
/*                repair type transition responsibility rec*/
/*                                                  */
/*--------------------------------------------------*/
PROCEDURE Create_Rt_Tran_Resp
(
  p_api_version        		IN  NUMBER,
  p_commit	   		      IN  VARCHAR2,
  p_init_msg_list      		IN  VARCHAR2,
  p_validation_level   		IN  NUMBER,
  x_return_status      		OUT NOCOPY VARCHAR2,
  x_msg_count          		OUT NOCOPY NUMBER,
  x_msg_data           		OUT NOCOPY VARCHAR2,
  p_rt_tran_resp_rec          IN  RT_TRAN_RESP_REC_TYPE,
  x_rt_tran_resp_id		OUT NOCOPY NUMBER
);


/*--------------------------------------------------*/
/* procedure name: Update_Rt_Tran_Resp          */
/* description   : procedure used to update         */
/*                repair type transition responsibility rec */
/*                                                  */
/*--------------------------------------------------*/
PROCEDURE Update_Rt_Tran_Resp
(
  p_api_version        		IN  NUMBER,
  p_commit	   		      IN  VARCHAR2,
  p_init_msg_list      		IN  VARCHAR2,
  p_validation_level   		IN  NUMBER,
  x_return_status      		OUT NOCOPY VARCHAR2,
  x_msg_count          		OUT NOCOPY NUMBER,
  x_msg_data           		OUT NOCOPY VARCHAR2,
  p_rt_tran_resp_rec          IN  RT_TRAN_RESP_REC_TYPE,
  x_obj_ver_number 		OUT NOCOPY NUMBER
);

/*--------------------------------------------------*/
/* procedure name: Delete_Rt_Tran_Resp               */
/* description   : procedure used to delete         */
/*                repair type transition responsibility rec       */
/*                                                  */
/*--------------------------------------------------*/
PROCEDURE Delete_Rt_Tran_Resp
(
  p_api_version        		IN  NUMBER,
  p_commit	   		      IN  VARCHAR2,
  p_init_msg_list      		IN  VARCHAR2,
  p_validation_level   		IN  NUMBER,
  x_return_status      		OUT NOCOPY VARCHAR2,
  x_msg_count          		OUT NOCOPY NUMBER,
  x_msg_data           		OUT NOCOPY VARCHAR2,
  p_rt_tran_resp_id	 	IN  NUMBER
);

/*--------------------------------------------------*/
/* procedure name: Lock_Rt_Tran_Resp                 */
/* description   : procedure used to lock           */
/*                reapir type transition responsibility rec       */
/*                                                  */
/*--------------------------------------------------*/
PROCEDURE Lock_Rt_Tran_Resp
(
  p_api_version        		IN  NUMBER,
  p_commit	   		      IN  VARCHAR2,
  p_init_msg_list      		IN  VARCHAR2,
  p_validation_level   		IN  NUMBER,
  x_return_status      		OUT NOCOPY VARCHAR2,
  x_msg_count          		OUT NOCOPY NUMBER,
  x_msg_data           		OUT NOCOPY VARCHAR2,
  p_rt_tran_resp_rec          IN  RT_TRAN_RESP_REC_TYPE
);

End CSD_RT_TRAN_RESPS_PVT;

 

/
