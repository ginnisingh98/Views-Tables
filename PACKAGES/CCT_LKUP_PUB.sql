--------------------------------------------------------
--  DDL for Package CCT_LKUP_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."CCT_LKUP_PUB" AUTHID CURRENT_USER AS
/*$Header: cctplovs.pls 120.0 2005/06/02 09:25:20 appldev noship $*/



PROCEDURE GET_TRUE_FALSE_LOV
(
  p_server_group_id IN NUMBER ,  -- server group id
  p_server_id IN NUMBER ,            -- server id
  p_server_parameter_id IN NUMBER ,   -- server parameter id
  p_env_lang IN VARCHAR2 ,           -- language
  x_lov_count OUT NOCOPY NUMBER ,            -- number of lov_data returned
  x_lov_data OUT NOCOPY IEO_STRING_VARR, -- list of lov_data returned.
  x_return_status OUT NOCOPY VARCHAR2,
  x_msg_count OUT NOCOPY NUMBER,
  x_msg_data OUT NOCOPY VARCHAR2
);

PROCEDURE GET_JDBC_CONN_LOV
(
  p_server_group_id IN NUMBER ,  -- server group id
  p_server_id IN NUMBER ,            -- server id
  p_server_parameter_id IN NUMBER ,   -- server parameter id
  p_env_lang IN VARCHAR2 ,           -- language
  x_lov_count OUT NOCOPY NUMBER ,            -- number of lov_data returned
  x_lov_data OUT NOCOPY IEO_STRING_VARR, -- list of lov_data returned.
  x_return_status OUT NOCOPY VARCHAR2,
  x_msg_count OUT NOCOPY NUMBER,
  x_msg_data OUT NOCOPY VARCHAR2

);


PROCEDURE GET_TRACE_LOV
(
  p_server_group_id IN NUMBER ,  -- server group id
  p_server_id IN NUMBER ,            -- server id
  p_server_parameter_id IN NUMBER ,   -- server parameter id
  p_env_lang IN VARCHAR2 ,           -- language
  x_lov_count OUT NOCOPY NUMBER ,            -- number of lov_data returned
  x_lov_data OUT NOCOPY IEO_STRING_VARR, -- list of lov_data returned.
  x_return_status OUT NOCOPY VARCHAR2,
  x_msg_count OUT NOCOPY NUMBER,
  x_msg_data OUT NOCOPY VARCHAR2

);

PROCEDURE GET_TEST_TYPE_LOV
(
  p_server_group_id IN NUMBER ,  -- server group id
  p_server_id IN NUMBER ,            -- server id
  p_server_parameter_id IN NUMBER ,   -- server parameter id
  p_env_lang IN VARCHAR2 ,           -- language
  x_lov_count OUT NOCOPY NUMBER ,            -- number of lov_data returned
  x_lov_data OUT NOCOPY IEO_STRING_VARR, -- list of lov_data returned.
  x_return_status OUT NOCOPY VARCHAR2,
  x_msg_count OUT NOCOPY NUMBER,
  x_msg_data OUT NOCOPY VARCHAR2

);


PROCEDURE GET_MW_LOV
(
  p_server_group_id IN NUMBER ,  -- server group id
  p_server_id IN NUMBER ,            -- server id
  p_server_parameter_id IN NUMBER ,   -- server parameter id
  p_env_lang IN VARCHAR2 ,           -- language
  x_lov_count OUT NOCOPY NUMBER ,            -- number of lov_data returned
  x_lov_data OUT NOCOPY IEO_STRING_VARR, -- list of lov_data returned.
  x_return_status OUT NOCOPY VARCHAR2,
  x_msg_count OUT NOCOPY NUMBER,
  x_msg_data OUT NOCOPY VARCHAR2

);



PROCEDURE GET_ROUTE_POINT_LOV
(
  p_server_group_id IN NUMBER ,  -- server group id
  p_server_id IN NUMBER ,            -- server id
  p_server_parameter_id IN NUMBER ,   -- server parameter id
  p_env_lang IN VARCHAR2 ,           -- language
  x_lov_count OUT NOCOPY NUMBER ,            -- number of lov_data returned
  x_lov_data OUT NOCOPY IEO_STRING_VARR, -- list of lov_data returned.
  x_return_status OUT NOCOPY VARCHAR2,
  x_msg_count OUT NOCOPY NUMBER,
  x_msg_data OUT NOCOPY VARCHAR2

);


END CCT_LKUP_PUB;

 

/
