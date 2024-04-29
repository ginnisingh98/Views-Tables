--------------------------------------------------------
--  DDL for Package AMS_CELL_INTEGRATE_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."AMS_CELL_INTEGRATE_PVT" AUTHID CURRENT_USER AS
/* $Header: amsvceis.pls 115.4 2002/11/22 08:55:06 jieli ship $ */

---------------------------------------------------------------------
-- PROCEDURE
--    create_segment_list
-- PURPOSE
--    This procedure will create a list header which will include the
--    segment id.
--
-- HISTORY
--    09/06/01  yxliu  Created.
---------------------------------------------------------------------

PROCEDURE create_segment_list
( p_api_version            IN    NUMBER,
  p_init_msg_list          IN    VARCHAR2   := FND_API.G_TRUE,
  p_commit                 IN    VARCHAR2   := FND_API.G_FALSE,
  p_validation_level       IN    NUMBER     := FND_API.G_VALID_LEVEL_FULL,
  p_owner_user_id          IN    NUMBER,
  p_cell_id                IN    NUMBER,
  x_return_status          OUT NOCOPY   VARCHAR2,
  x_msg_count              OUT NOCOPY   NUMBER,
  x_msg_data               OUT NOCOPY   VARCHAR2,
  x_list_header_id         OUT NOCOPY   NUMBER,
  x_list_source_type       OUT NOCOPY   VARCHAR2,
  p_list_name              in    VARCHAR2    DEFAULT NULL
);

END AMS_CEll_INTEGRATE_PVT;

 

/
