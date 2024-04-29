--------------------------------------------------------
--  DDL for Package CCT_CASCADE_DELETE_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."CCT_CASCADE_DELETE_PUB" AUTHID CURRENT_USER AS
/* $Header: cctcsdes.pls 120.0 2005/06/02 09:23:49 appldev noship $ */
  PROCEDURE delete_defunct_del_middlewares ;

  PROCEDURE delete_defunct_middlewares;

  PROCEDURE delete_deleted_middlewares;

   PROCEDURE delete_middleware
    ( p_server_group_id IN NUMBER
      , p_commit_flag IN VARCHAR2  DEFAULT 'N');

   PROCEDURE delete_middleware
    ( p_middleware_id IN NUMBER
      , p_commit_flag IN VARCHAR2  DEFAULT 'N');

   PROCEDURE delete_teleset
    ( p_middleware_id IN NUMBER
      , p_commit_flag IN VARCHAR2 DEFAULT 'N');


   PROCEDURE delete_ivr
    ( p_middleware_id IN NUMBER
    , p_commit_flag IN VARCHAR2 DEFAULT 'N');

   PROCEDURE delete_multisite
    ( p_middleware_id IN NUMBER
     , p_commit_flag IN VARCHAR2 DEFAULT 'N');

   PROCEDURE delete_route_point
    ( p_middleware_id IN NUMBER
     , p_commit_flag IN VARCHAR2 DEFAULT 'N')    ;

   PROCEDURE delete_ivr
    ( p_route_point_id IN NUMBER
      , p_commit_flag IN VARCHAR2 DEFAULT 'N')   ;

   PROCEDURE delete_multisite_paths
    ( p_multisite_config_id IN NUMBER
    , p_commit_flag IN VARCHAR2 DEFAULT 'N');


   PROCEDURE delete_multisite_paths
    ( p_mw_route_point_id IN NUMBER
      , p_commit_flag IN VARCHAR2 DEFAULT 'N');

END CCT_CASCADE_DELETE_PUB; -- Package Specification CCT_CASCADE_DELETE_PUB

 

/
