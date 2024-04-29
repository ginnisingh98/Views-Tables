--------------------------------------------------------
--  DDL for Package CCT_QDE_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."CCT_QDE_PUB" AUTHID CURRENT_USER AS
/* $Header: cctpqdes.pls 115.3 2003/10/02 23:24:24 svinamda noship $*/


PROCEDURE RECEIVE_ITEM
(
    p_api_version       IN	NUMBER,
  	p_init_msg_list		IN	VARCHAR2 ,
	p_commit	    	IN  VARCHAR2,
    p_app_id            IN  NUMBER,
    p_item_id           IN  NUMBER,
    p_item_type		    IN	NUMBER,
    p_classification    IN  VARCHAR2,
    p_kvp               IN  cct_keyvalue_varr,
    p_delay             IN NUMBER,
	x_return_status		OUT NOCOPY	VARCHAR2 ,
    x_msg_count		OUT NOCOPY	NUMBER	,
	x_msg_data		OUT NOCOPY	VARCHAR2
);


PROCEDURE UPDATE_ROUTE_RESULT
(
    p_api_version           	IN	NUMBER,
  	p_init_msg_list			IN	VARCHAR2,
	p_commit	    	IN  VARCHAR2,
  	p_item_id 		IN 	NUMBER,
    p_item_type              IN NUMBER,
    p_classification        IN VARCHAR2,
    p_route_result          IN VARCHAR2,
    p_is_route_to_all     IN VARCHAR2,
    p_is_reroute         IN VARCHAR2,
    p_kvp               IN  cct_keyvalue_varr,
 	x_return_status		OUT NOCOPY	VARCHAR2,
	x_msg_count		OUT NOCOPY	NUMBER,
    x_msg_data		OUT NOCOPY	VARCHAR2
);

PROCEDURE GET_NEXT_ITEM
(
    p_api_version   IN	NUMBER,
  	p_init_msg_list	IN	VARCHAR2,
	p_commit	    IN  VARCHAR2,
  	p_agent_id 		IN 	NUMBER,
    p_item_type    IN NUMBER,
    p_classification IN VARCHAR2,
 	x_return_status	OUT NOCOPY	VARCHAR2,
	x_msg_count		OUT NOCOPY	NUMBER,
    x_msg_data		OUT NOCOPY	VARCHAR2,
    x_app_id        OUT NOCOPY NUMBER,
    x_item_id OUT NOCOPY NUMBER,
    x_item_type	OUT NOCOPY	NUMBER,
    x_classification OUT NOCOPY  VARCHAR2,
    x_kvp     OUT NOCOPY cct_keyvalue_varr
);

PROCEDURE UPDATE_AGENT_QUEUES
(
    p_api_version   IN	NUMBER,
  	p_init_msg_list	IN	VARCHAR2,
	p_commit	    IN  VARCHAR2,
  	p_agent_id 		IN 	NUMBER,
    p_item_type    IN NUMBER,
 	x_return_status	OUT NOCOPY	VARCHAR2,
	x_msg_count		OUT NOCOPY	NUMBER,
    x_msg_data		OUT NOCOPY	VARCHAR2
);


PROCEDURE GET_AGENT_INDEX
(
    p_api_version   IN	NUMBER,
  	p_init_msg_list	IN	VARCHAR2,
	p_commit	    IN  VARCHAR2,
  	p_agent_id 		IN 	NUMBER,
 	x_return_status	OUT NOCOPY	VARCHAR2,
	x_msg_count		OUT NOCOPY	NUMBER,
    x_msg_data		OUT NOCOPY	VARCHAR2,
    x_agent_index   OUT NOCOPY NUMBER,
    x_raw_agent_index OUT NOCOPY RAW
);


FUNCTION UPDATE_CLASSIFICATION_COUNT
(
	p_commit	    IN  VARCHAR2,
  	p_agent_id 		IN 	NUMBER,
    p_item_type    IN NUMBER,
    p_classification IN VARCHAR2,
    p_count         IN NUMBER
)
RETURN NUMBER;

FUNCTION IS_BIT_SET (agent_id IN RAW, route_result IN RAW) RETURN NUMBER ;


END CCT_QDE_PUB;

 

/
