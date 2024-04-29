--------------------------------------------------------
--  DDL for Package GMD_ROUTINGS_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."GMD_ROUTINGS_PVT" AUTHID CURRENT_USER AS
/* $Header: GMDVROUS.pls 120.1.12010000.1 2008/07/24 10:02:19 appldev ship $ */

  m_api_version   CONSTANT NUMBER         := 1;
  m_pkg_name      CONSTANT VARCHAR2 (30)  := 'GMD_ROUTINGS_PVT';

  PROCEDURE insert_routing
  ( p_routings          IN             gmd_routings%ROWTYPE
  , x_message_count 	OUT NOCOPY     NUMBER
  , x_message_list 	OUT NOCOPY     VARCHAR2
  , x_return_status     OUT NOCOPY     VARCHAR2
  );

  PROCEDURE update_routing
  ( p_routing_id	IN	        gmd_routings.routing_id%TYPE    := NULL
  , p_update_table	IN	        gmd_routings_pub.update_tbl_type
  , x_message_count 	OUT NOCOPY 	NUMBER
  , x_message_list 	OUT NOCOPY 	VARCHAR2
  , x_return_status	OUT NOCOPY 	VARCHAR2
  );
  -- BUG 5197863 Added
  Function Validate_dates
  (p_routing_id  IN gmd_routings.routing_id%TYPE
  ,p_effective_start_date IN DATE
  ,p_effective_end_date  IN  DATE) RETURN NUMBER;

END GMD_ROUTINGS_PVT;

/
