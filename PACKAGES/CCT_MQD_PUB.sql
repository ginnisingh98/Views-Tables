--------------------------------------------------------
--  DDL for Package CCT_MQD_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."CCT_MQD_PUB" AUTHID CURRENT_USER AS
/* $Header: cctpmqds.pls 115.2 2003/10/02 23:24:07 svinamda noship $*/



PROCEDURE RECEIVE_MEDIA_ITEM
(
    p_api_version       IN	NUMBER,
  	p_init_msg_list		IN	VARCHAR2 ,
	p_commit	    	IN  VARCHAR2,
    p_app_id            IN  NUMBER,
    p_item_type		    IN	NUMBER,
    p_classification    IN  VARCHAR2,
    p_kvp               IN  cct_keyvalue_varr,
    p_server_group_name IN VARCHAR2,
    p_direction         IN VARCHAR2,
    p_ih_item_type      IN VARCHAR2,
	x_return_status		OUT NOCOPY	VARCHAR2 ,
    x_msg_count		OUT NOCOPY	NUMBER	,
	x_msg_data		OUT NOCOPY	VARCHAR2,
    x_media_id      OUT NOCOPY NUMBER
);



PROCEDURE GET_NEXT_MEDIA_ITEM
(
    p_api_version   IN	NUMBER,
  	p_init_msg_list	IN	VARCHAR2,
	p_commit	    IN  VARCHAR2,
  	p_agent_id 		IN 	NUMBER,
    p_item_type    IN NUMBER,
    p_classification IN VARCHAR2,
    p_polling   IN VARCHAR2,
 	x_return_status	OUT NOCOPY	VARCHAR2,
	x_msg_count		OUT NOCOPY	NUMBER,
    x_msg_data		OUT NOCOPY	VARCHAR2,
    x_app_id        OUT NOCOPY NUMBER,
    x_item_id OUT NOCOPY NUMBER,
    x_item_type	OUT NOCOPY	NUMBER,
    x_classification OUT NOCOPY  VARCHAR2,
    x_kvp     OUT NOCOPY VARCHAR2
);



END CCT_MQD_PUB;

 

/
