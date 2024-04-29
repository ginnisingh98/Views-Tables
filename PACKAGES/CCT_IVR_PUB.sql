--------------------------------------------------------
--  DDL for Package CCT_IVR_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."CCT_IVR_PUB" AUTHID CURRENT_USER AS
/* $Header: cctivrs.pls 115.8 2003/02/26 20:47:00 rajayara noship $ */

PROCEDURE parseAppData (
  p_app_data IN VARCHAR2,
  x_YYYY     OUT nocopy VARCHAR2,
  x_media_item OUT nocopy NUMBER,
  x_ZZZZ       OUT nocopy VARCHAR2,
  x_create_media_item OUT nocopy boolean
);


PROCEDURE create_IVR_Item
(
	p_api_version		IN	NUMBER,
	p_init_msg_list		IN	VARCHAR2	DEFAULT FND_API.G_FALSE,
	p_commit		IN	VARCHAR2	DEFAULT FND_API.G_FALSE,
	x_return_status		OUT nocopy	VARCHAR2,
	x_msg_count		OUT nocopy	NUMBER,
	x_msg_data		OUT nocopy	VARCHAR2,
	p_start_date_time	IN	DATE 		DEFAULT null,
	p_end_date_time		IN	DATE 		DEFAULT null,
	p_duration_in_secs	IN	NUMBER   	DEFAULT null,
	p_ivr_data		IN	VARCHAR2 	DEFAULT null,
	p_app_data		IN	VARCHAR2 	DEFAULT null,
	x_app_data		OUT  nocopy	VARCHAR2
);

PROCEDURE  callIVRTEST (p_app_data VARCHAR2) ;


END CCT_IVR_PUB;

 

/
