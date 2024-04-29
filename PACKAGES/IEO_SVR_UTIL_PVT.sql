--------------------------------------------------------
--  DDL for Package IEO_SVR_UTIL_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IEO_SVR_UTIL_PVT" AUTHID CURRENT_USER AS
/* $Header: IEOSVUVS.pls 115.21 2004/04/27 00:56:06 edwang ship $ */


-- Sub-Program Unit Declarations

PROCEDURE GET_SVR_TYPE_LOAD_INFO
  (P_SERVER_TYPE_UUID   IN VARCHAR2
  );

PROCEDURE GET_ALL_SUBGROUPS
  (P_GROUP_ID       IN  NUMBER
  ,X_GROUP_ID_LIST  OUT NOCOPY SYSTEM.IEO_SVR_ID_ARRAY
  );

PROCEDURE LOCATE_ALL_GROUPS
  (P_SERVER_ID_LOOKING  IN  NUMBER
  ,X_GROUP_ID_LIST      OUT NOCOPY SYSTEM.IEO_SVR_ID_ARRAY
  );

PROCEDURE GET_ALL_SERVERS_IN_GROUP
  (P_GROUP_ID           IN  NUMBER
  ,P_SERVER_TYPE_UUID   IN  VARCHAR2
  ,P_WIRE_PROTOCOL      IN  VARCHAR2
  ,P_COMP_DEF_NAME      IN  VARCHAR2
  ,P_COMP_DEF_VERSION   IN  NUMBER
  ,P_COMP_DEF_IMPL      IN  VARCHAR2
  ,P_COMP_NAME          IN  VARCHAR2
  ,X_SVR_INFO_LIST      OUT NOCOPY SYSTEM.IEO_SVR_INFO_ARRAY
  );

PROCEDURE GET_CONNECT_INFO_FOR_ALL_SVRS
  (P_SERVER_ID_LOOKING  IN  NUMBER
  ,P_SERVER_TYPE_UUID   IN  VARCHAR2
  ,P_WIRE_PROTOCOL      IN  VARCHAR2
  ,P_COMP_DEF_NAME      IN  VARCHAR2
  ,P_COMP_DEF_VERSION   IN  NUMBER
  ,P_COMP_DEF_IMPL      IN  VARCHAR2
  ,P_COMP_NAME          IN  VARCHAR2
  ,X_DB_TIME            OUT NOCOPY DATE
  ,X_SVR_COUNT          OUT NOCOPY NUMBER
  ,X_SVR_INFO_LIST      OUT NOCOPY SYSTEM.IEO_SVR_INFO_ARRAY
  );

PROCEDURE GET_ALL_SVRS_IN_GROUP_NST
  (P_GROUP_ID           IN  NUMBER
  ,P_SERVER_TYPE_UUID   IN  VARCHAR2
  ,P_WIRE_PROTOCOL      IN  VARCHAR2
  ,P_COMP_DEF_NAME      IN  VARCHAR2
  ,P_COMP_DEF_VERSION   IN  NUMBER
  ,P_COMP_DEF_IMPL      IN  VARCHAR2
  ,P_COMP_NAME          IN  VARCHAR2
  ,X_SVR_INFO_LIST      OUT NOCOPY SYSTEM.IEO_SVR_INFO_NST
  );

PROCEDURE GET_CONN_INFO_FOR_ALL_SVRS_NST
  (P_SERVER_ID_LOOKING  IN  NUMBER
  ,P_SERVER_TYPE_UUID   IN  VARCHAR2
  ,P_WIRE_PROTOCOL      IN  VARCHAR2
  ,P_COMP_DEF_NAME      IN  VARCHAR2
  ,P_COMP_DEF_VERSION   IN  NUMBER
  ,P_COMP_DEF_IMPL      IN  VARCHAR2
  ,P_COMP_NAME          IN  VARCHAR2
  ,X_DB_TIME            OUT NOCOPY DATE
  ,X_SVR_COUNT          OUT NOCOPY NUMBER
  ,X_SVR_INFO_LIST      OUT NOCOPY SYSTEM.IEO_SVR_INFO_NST
  );

/* Updates real-time server information. */
PROCEDURE UPDATE_RT_INFO
  (P_SERVER_ID            IN NUMBER
  ,P_STATUS               IN NUMBER
  ,P_MAJOR_LOAD_FACTOR    IN NUMBER
  ,P_MINOR_LOAD_FACTOR    IN NUMBER
  ,P_EXTRA                IN VARCHAR2
  );


/* Updates real-time server information when server load is not to be specified. */
PROCEDURE UPDATE_RT_INFO_NO_LOAD
  (P_SERVER_ID            IN NUMBER
  ,P_STATUS               IN NUMBER
  ,P_EXTRA                IN VARCHAR2
  );

/* Updates real-time server information with node id. */
PROCEDURE UPDATE_RT_INFO_V2
  (P_SERVER_ID            IN NUMBER
  ,P_STATUS               IN NUMBER
  ,P_NODE_ID              IN NUMBER
  ,P_MAJOR_LOAD_FACTOR    IN NUMBER
  ,P_MINOR_LOAD_FACTOR    IN NUMBER
  ,P_EXTRA                IN VARCHAR2
  );


/* Updates real-time server information with node id when server load is not to be specified. */
PROCEDURE UPDATE_RT_INFO_NO_LOAD_V2
  (P_SERVER_ID            IN NUMBER
  ,P_STATUS               IN NUMBER
  ,P_NODE_ID              IN NUMBER
  ,P_EXTRA                IN VARCHAR2
  );



/* Locates a server of a particular type, given a group. */
PROCEDURE LOCATE_LEAST_LOADED_IN_GROUP
  (P_GROUP_ID           IN NUMBER
  ,P_SERVER_TYPE_UUID   IN VARCHAR2
  ,P_EXCLUDE_SERVER_ID  IN NUMBER
  ,X_SERVER_ID          OUT NOCOPY NUMBER
  ,P_TIMEOUT_TOLERANCE  IN NUMBER   DEFAULT -1
  );


/* Locates a server of a particular type, given a group. */
PROCEDURE LOCATE_BY_MINOR_LOAD
  (P_GROUP_ID           IN NUMBER
  ,P_SERVER_TYPE_UUID   IN VARCHAR2
  ,P_EXCLUDE_SERVER_ID  IN NUMBER
  ,X_SERVER_ID          OUT NOCOPY NUMBER
  ,P_TIMEOUT_TOLERANCE  IN NUMBER   DEFAULT -1
  );



/* Locates a server of a particular type, given a group. */
PROCEDURE LOCATE_BY_MAJOR_LOAD
  (P_GROUP_ID           IN NUMBER
  ,P_SERVER_TYPE_UUID   IN VARCHAR2
  ,P_EXCLUDE_SERVER_ID  IN NUMBER
  ,X_SERVER_ID          OUT NOCOPY NUMBER
  ,P_TIMEOUT_TOLERANCE  IN NUMBER   DEFAULT -1
  );



/* Locates a server of a particular type, given another server. */
PROCEDURE LOCATE_LEAST_LOADED_FOR_SVR
  (P_SERVER_ID_LOOKING  IN NUMBER
  ,P_SERVER_TYPE_UUID   IN VARCHAR2
  ,X_SERVER_ID_FOUND    OUT NOCOPY NUMBER
  ,P_TIMEOUT_TOLERANCE  IN NUMBER   DEFAULT -1
  );


/* Locates a server of a particular type, given another server, and obtains */
/* the connection information, based on some default rules.                 */
PROCEDURE LOCATE_LLS_AND_INFO
  (P_SERVER_ID          IN  NUMBER
  ,P_SERVER_TYPE_UUID   IN  VARCHAR2
  ,P_WIRE_PROTOCOL      IN  VARCHAR2
  ,P_COMP_DEF_NAME      IN  VARCHAR2
  ,P_COMP_DEF_VERSION   IN  NUMBER
  ,P_COMP_DEF_IMPL      IN  VARCHAR2
  ,P_COMP_NAME          IN  VARCHAR2
  ,X_SERVER_ID_FOUND    OUT NOCOPY NUMBER
  ,X_USER_ADDRESS       OUT NOCOPY VARCHAR2
  ,X_DNS_NAME           OUT NOCOPY VARCHAR2
  ,X_IP_ADDRESS         OUT NOCOPY VARCHAR2
  ,X_PORT               OUT NOCOPY NUMBER
  ,X_COMP_NAME          OUT NOCOPY VARCHAR2
  ,P_TIMEOUT_TOLERANCE  IN NUMBER   DEFAULT -1
  );


/* Locates a server of a particular type, given another server, and obtains */
/* the connection information, based on some default rules.                 */
PROCEDURE LOCATE_LLS_AND_INFO_BY_GROUP
  (P_SERVER_GROUP_ID    IN  NUMBER
  ,P_SERVER_TYPE_UUID   IN  VARCHAR2
  ,P_WIRE_PROTOCOL      IN  VARCHAR2
  ,P_COMP_DEF_NAME      IN  VARCHAR2
  ,P_COMP_DEF_VERSION   IN  NUMBER
  ,P_COMP_DEF_IMPL      IN  VARCHAR2
  ,P_COMP_NAME          IN  VARCHAR2
  ,X_SERVER_ID_FOUND    OUT NOCOPY NUMBER
  ,X_USER_ADDRESS       OUT NOCOPY VARCHAR2
  ,X_DNS_NAME           OUT NOCOPY VARCHAR2
  ,X_IP_ADDRESS         OUT NOCOPY VARCHAR2
  ,X_PORT               OUT NOCOPY NUMBER
  ,X_COMP_NAME          OUT NOCOPY VARCHAR2
  ,P_TIMEOUT_TOLERANCE  IN NUMBER   DEFAULT -1
  );




PROCEDURE GET_SVR_CONNECT_INFO
(
    p_api_version       IN	NUMBER,
  	p_init_msg_list		IN	VARCHAR2 ,
  	p_commit	    	IN  VARCHAR2,
    p_server_id       IN NUMBER,
    p_server_type_id  IN NUMBER,
    p_comp_def_name   IN VARCHAR2,
    p_comp_def_version IN NUMBER,
  	x_return_status		OUT NOCOPY	VARCHAR2 ,
    x_msg_count		OUT NOCOPY	NUMBER	,
    x_msg_data		OUT NOCOPY	VARCHAR2,
    x_comp_id     OUT NOCOPY NUMBER,
    x_comp_name   OUT NOCOPY VARCHAR2,
    x_wire_protocol OUT NOCOPY VARCHAR2,
    x_port      OUT NOCOPY NUMBER,
    x_ip        OUT NOCOPY VARCHAR2,
    x_base_url  OUT NOCOPY VARCHAR2,
    x_url       OUT NOCOPY VARCHAR2

);


PROCEDURE IS_SERVER_UP
(
    p_api_version       IN	NUMBER,
  	p_init_msg_list		IN	VARCHAR2 ,
  	p_commit	    	IN  VARCHAR2,
    p_server_id           IN  NUMBER,
    p_server_type_id    IN NUMBER,
  	x_return_status		OUT NOCOPY	VARCHAR2 ,
    x_msg_count		OUT NOCOPY	NUMBER	,
    x_msg_data		OUT NOCOPY	VARCHAR2,
    x_is_server_up   OUT NOCOPY  VARCHAR2,
    x_server_status   OUT NOCOPY NUMBER,
    x_server_name    OUT NOCOPY VARCHAR2,
    x_server_group_name OUT NOCOPY VARCHAR2
);

-- Removes all the agent bindings to a particular server
-- This should be called by the servers during startup.  To clear any
-- leftover bindings from a previous server crash.
PROCEDURE CLEAR_SERVER_BINDINGS
  (P_SERVER_ID        IN  NUMBER
  );


END IEO_SVR_UTIL_PVT;

 

/
