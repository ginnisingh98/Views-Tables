--------------------------------------------------------
--  DDL for Package FEM_DIM_PRS_UTILS_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."FEM_DIM_PRS_UTILS_PVT" AUTHID CURRENT_USER AS
/* $Header: FEMVDPMS.pls 120.0 2005/06/06 20:56:16 appldev noship $ */

PROCEDURE Purge_Personal_Metadata (
  p_api_version         IN          NUMBER
  ,p_init_msg_list      IN          VARCHAR2    := NULL
  ,p_commit             IN          VARCHAR2    := NULL
  ,p_validation_level   IN          NUMBER      := 0
  ,p_user_id            IN          VARCHAR2    := NULL
  ,p_dimension_id       IN          NUMBER      := NULL
  ,x_return_status      OUT NOCOPY  VARCHAR2
  ,x_msg_count          OUT NOCOPY  NUMBER
  ,x_msg_data           OUT NOCOPY  VARCHAR2
);

END FEM_DIM_PRS_UTILS_PVT;

 

/
