--------------------------------------------------------
--  DDL for Package WMS_TRIPSTOPS_STAGELANES_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."WMS_TRIPSTOPS_STAGELANES_PUB" AUTHID CURRENT_USER AS
--/* $Header: WMSDKTSS.pls 120.0 2005/05/24 18:08:13 appldev noship $ */

PROCEDURE get_stgln_for_tripstop
  (
     x_return_status               OUT NOCOPY VARCHAR2
   , x_msg_count                   OUT NOCOPY NUMBER
   , x_msg_data                    OUT NOCOPY VARCHAR2
   , p_org_id                      IN         NUMBER
   , p_trip_stop                   IN         NUMBER
   , x_stg_ln_id                   OUT NOCOPY NUMBER
   , x_sub_code                    OUT NOCOPY VARCHAR2
   );

FUNCTION get_available_staginglane
  (
     x_return_status               OUT NOCOPY VARCHAR2
   , x_msg_count                   OUT NOCOPY NUMBER
   , x_msg_data                    OUT NOCOPY VARCHAR2
   , p_trip_stop                   IN         NUMBER
   , p_dock_id                     IN         NUMBER
   )
   RETURN NUMBER;

FUNCTION check_if_stagelane_assigned
  (
     x_return_status               OUT NOCOPY VARCHAR2
   , x_msg_count                   OUT NOCOPY NUMBER
   , x_msg_data                    OUT NOCOPY VARCHAR2
   , p_stg_lane_id                 IN         NUMBER
   , p_trip_stop                   IN         NUMBER
   , p_dock_id                     IN         NUMBER
  )
  RETURN NUMBER;

FUNCTION get_earliest_available_stglane
  (
     p_dock_id                     IN  NUMBER
   )
   RETURN NUMBER;

PROCEDURE check_dockdoor_tripstop_exists
  (
     x_return_status               OUT NOCOPY VARCHAR2
   , x_msg_count                   OUT NOCOPY NUMBER
   , x_msg_data                    OUT NOCOPY VARCHAR2
   , p_trip_stop                   IN         NUMBER
   , x_dock_id                     OUT NOCOPY NUMBER
   , x_staging_lane_id             OUT NOCOPY NUMBER
   , x_dkdr_trpstp_exists	   OUT NOCOPY BOOLEAN
  );

PROCEDURE update_staging_lane_id
  (
     x_return_status               OUT NOCOPY VARCHAR2
   , x_msg_count                   OUT NOCOPY NUMBER
   , x_msg_data                    OUT NOCOPY VARCHAR2
   , p_stage_lane_id               IN         NUMBER
   , p_trip_stop                   IN         NUMBER
   , p_dock_id                     IN         NUMBER
   );

FUNCTION get_subinventory_code
  (
     x_return_status               OUT NOCOPY VARCHAR2
   , x_msg_count                   OUT NOCOPY NUMBER
   , x_msg_data                    OUT NOCOPY VARCHAR2
   , p_org_id                      IN         NUMBER
   , p_staging_lane_id             IN         NUMBER
  )
  RETURN VARCHAR2;


END WMS_TRIPSTOPS_STAGELANES_PUB;


 

/
