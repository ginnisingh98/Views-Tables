--------------------------------------------------------
--  DDL for Package CSD_FLWSTS_TRAN_MILES_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."CSD_FLWSTS_TRAN_MILES_PVT" AUTHID CURRENT_USER as
/* $Header: csdvflms.pls 120.0 2005/06/30 21:07:17 vkjain noship $ */

/*--------------------------------------------------*/
/* Record name: FLWSTS_TRAN_MILE_REC_TYPE           */
/* description : Record used for flow status        */
/*               transition milestone rec           */
/*                                                  */
/*--------------------------------------------------*/

TYPE FLWSTS_TRAN_MILE_REC_TYPE IS RECORD
(
  flwsts_tran_mile_id      	NUMBER,
  flwsts_tran_id	      	NUMBER,
  milestone_code              VARCHAR2(30),
  object_version_number       NUMBER,
  created_by                  NUMBER,
  creation_date               DATE,
  last_updated_by             NUMBER,
  last_update_date            DATE,
  last_update_login           NUMBER
);

/*--------------------------------------------------*/
/* procedure name: Create_Flwsts_Tran_Mile          */
/* description   : procedure used to create         */
/*                FS transition milestone rec       */
/*                                                  */
/*--------------------------------------------------*/
PROCEDURE Create_Flwsts_Tran_Mile
(
  p_api_version        		IN  NUMBER,
  p_commit	   		      IN  VARCHAR2,
  p_init_msg_list      		IN  VARCHAR2,
  p_validation_level   		IN  NUMBER,
  x_return_status      		OUT NOCOPY VARCHAR2,
  x_msg_count          		OUT NOCOPY NUMBER,
  x_msg_data           		OUT NOCOPY VARCHAR2,
  p_flwsts_tran_mile_rec      IN  FLWSTS_TRAN_MILE_REC_TYPE,
  x_flwsts_tran_mile_id		OUT NOCOPY NUMBER
);


/*--------------------------------------------------*/
/* procedure name: Update_Flwsts_Tran_Mile          */
/* description   : procedure used to update         */
/*                FS transition milestone rec       */
/*                                                  */
/*--------------------------------------------------*/
PROCEDURE Update_Flwsts_Tran_Mile
(
  p_api_version        		IN  NUMBER,
  p_commit	   		      IN  VARCHAR2,
  p_init_msg_list      		IN  VARCHAR2,
  p_validation_level   		IN  NUMBER,
  x_return_status      		OUT NOCOPY VARCHAR2,
  x_msg_count          		OUT NOCOPY NUMBER,
  x_msg_data           		OUT NOCOPY VARCHAR2,
  p_flwsts_tran_mile_rec      IN  FLWSTS_TRAN_MILE_REC_TYPE,
  x_obj_ver_number 		OUT NOCOPY NUMBER
);

/*--------------------------------------------------*/
/* procedure name: Delete_Flwsts_Tran_Mile               */
/* description   : procedure used to delete         */
/*                FS transition milestone rec       */
/*                                                  */
/*--------------------------------------------------*/
PROCEDURE Delete_Flwsts_Tran_Mile
(
  p_api_version        		IN  NUMBER,
  p_commit	   		      IN  VARCHAR2,
  p_init_msg_list      		IN  VARCHAR2,
  p_validation_level   		IN  NUMBER,
  x_return_status      		OUT NOCOPY VARCHAR2,
  x_msg_count          		OUT NOCOPY NUMBER,
  x_msg_data           		OUT NOCOPY VARCHAR2,
  p_flwsts_tran_mile_id	 	IN  NUMBER
);

/*--------------------------------------------------*/
/* procedure name: Lock_Flwsts_Tran_Mile            */
/* description   : procedure used to lock           */
/*                FS transition milestone rec       */
/*                                                  */
/*--------------------------------------------------*/
PROCEDURE Lock_Flwsts_Tran_Mile
(
  p_api_version        		IN  NUMBER,
  p_commit	   		      IN  VARCHAR2,
  p_init_msg_list      		IN  VARCHAR2,
  p_validation_level   		IN  NUMBER,
  x_return_status      		OUT NOCOPY VARCHAR2,
  x_msg_count          		OUT NOCOPY NUMBER,
  x_msg_data           		OUT NOCOPY VARCHAR2,
  p_flwsts_tran_mile_rec      IN  FLWSTS_TRAN_MILE_REC_TYPE
);

End CSD_FLWSTS_TRAN_MILES_PVT;

 

/
