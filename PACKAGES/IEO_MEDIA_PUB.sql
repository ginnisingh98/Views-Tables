--------------------------------------------------------
--  DDL for Package IEO_MEDIA_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IEO_MEDIA_PUB" AUTHID CURRENT_USER AS
/* $Header: ieopmeds.pls 115.2 2004/03/19 20:20:45 svinamda noship $*/


PROCEDURE UPDATE_DEVICE_MAP
(
    p_api_version       IN	NUMBER,
  	p_init_msg_list		IN	VARCHAR2 ,
  	p_commit	    	IN  VARCHAR2,
    p_server_group_id           IN  NUMBER,
    p_media_type          IN  VARCHAR2,
    p_device_type		    IN	VARCHAR2,
    p_device_id    IN  VARCHAR2,
    p_is_device_available IN VARCHAR2,
    p_server_id       IN NUMBER,
  	x_return_status		OUT NOCOPY	VARCHAR2 ,
    x_msg_count		OUT NOCOPY	NUMBER	,
    x_msg_data		OUT NOCOPY	VARCHAR2
);

PROCEDURE GET_DEVICE_LOCATION
(
  p_api_version           	IN	NUMBER,
  p_init_msg_list			IN	VARCHAR2,
  p_commit	    	IN  VARCHAR2,
  p_server_group_name 		IN 	VARCHAR2,
  p_media_type            IN VARCHAR2,
  p_device_type           IN VARCHAR2,
  p_device_id             IN VARCHAR2,
  x_return_status		OUT NOCOPY	VARCHAR2,
  x_msg_count		OUT NOCOPY	NUMBER,
  x_msg_data		OUT NOCOPY	VARCHAR2,
  x_server_id   OUT NOCOPY  VARCHAR2,
  x_device_map_id OUT NOCOPY NUMBER
);


PROCEDURE LOCATE_LEAST_LOADED_IN_GROUP
(
    p_api_version   IN	NUMBER,
  	p_init_msg_list	IN	VARCHAR2,
  	p_commit	    IN  VARCHAR2,
  	p_server_group_name IN VARCHAR2,
    p_server_type_uuid   IN VARCHAR2,
    x_return_status	OUT NOCOPY	VARCHAR2,
    x_msg_count		OUT NOCOPY	NUMBER,
    x_msg_data		OUT NOCOPY	VARCHAR2,
    x_server_id   OUT NOCOPY  VARCHAR2
);


PROCEDURE LOCATE_BY_MINOR_LOAD
(
    p_api_version   IN	NUMBER,
  	p_init_msg_list	IN	VARCHAR2,
  	p_commit	    IN  VARCHAR2,
  	p_server_group_name IN VARCHAR2,
    p_server_type_uuid   IN VARCHAR2,
    x_return_status	OUT NOCOPY	VARCHAR2,
    x_msg_count		OUT NOCOPY	NUMBER,
    x_msg_data		OUT NOCOPY	VARCHAR2,
    x_server_id   OUT NOCOPY  VARCHAR2
);


PROCEDURE LOCATE_BY_MAJOR_LOAD
(
    p_api_version   IN	NUMBER,
  	p_init_msg_list	IN	VARCHAR2,
  	p_commit	    IN  VARCHAR2,
  	p_server_group_name IN VARCHAR2,
    p_server_type_uuid   IN VARCHAR2,
    x_return_status	OUT NOCOPY	VARCHAR2,
    x_msg_count		OUT NOCOPY	NUMBER,
    x_msg_data		OUT NOCOPY	VARCHAR2,
    x_server_id   OUT NOCOPY  VARCHAR2
);




END IEO_MEDIA_PUB;

 

/
