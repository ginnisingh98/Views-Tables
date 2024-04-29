--------------------------------------------------------
--  DDL for Package GMD_ROUTING_STEPS_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."GMD_ROUTING_STEPS_PVT" AUTHID CURRENT_USER AS
/* $Header: GMDVRTSS.pls 115.2 2002/11/07 20:31:02 rajreddy noship $ */

  m_api_version   CONSTANT NUMBER         := 1;
  m_pkg_name      CONSTANT VARCHAR2 (30)  := 'GMD_ROUTING_STEPS_PVT';

PROCEDURE insert_routing_steps
(
  p_routing_id             IN   gmd_routings.routing_id%TYPE
, p_routing_step_rec       IN   fm_rout_dtl%ROWTYPE
, x_return_status          OUT NOCOPY  VARCHAR2
);

PROCEDURE insert_step_dependencies
(
  p_routing_id             IN   gmd_routings.routing_id%TYPE
, p_routingstep_no         IN   fm_rout_dtl.routingstep_no%TYPE
, p_routings_step_dep_tbl  IN   gmd_routings_pub.gmd_routings_step_dep_tab
, x_return_status          OUT NOCOPY 	VARCHAR2
);

PROCEDURE update_routing_steps
( p_routingstep_id	IN	fm_rout_dtl.routingstep_id%TYPE
, p_update_table	IN	gmd_routings_pub.update_tbl_type
, x_return_status       OUT NOCOPY     VARCHAR2
);

PROCEDURE update_step_dependencies
( p_routingstep_no	IN	fm_rout_dep.routingstep_no%TYPE
, p_dep_routingstep_no	IN	fm_rout_dep.routingstep_no%TYPE
, p_routing_id 		IN	fm_rout_dep.routing_id%TYPE
, p_update_table	IN	gmd_routings_pub.update_tbl_type
, x_return_status       OUT NOCOPY     VARCHAR2
);

PROCEDURE delete_routing_step
( p_routingstep_id	IN	fm_rout_dtl.routingstep_id%TYPE
, p_routing_id 		IN	gmd_routings.routing_id%TYPE 	:=  NULL
, x_return_status       OUT NOCOPY     VARCHAR2
);

PROCEDURE delete_step_dependencies
( p_routingstep_no	IN	fm_rout_dep.routingstep_no%TYPE
, p_dep_routingstep_no	IN	fm_rout_dep.routingstep_no%TYPE := NULL
, p_routing_id 		IN	fm_rout_dep.routing_id%TYPE
, x_return_status       OUT NOCOPY     VARCHAR2
);


END GMD_ROUTING_STEPS_PVT;

 

/
