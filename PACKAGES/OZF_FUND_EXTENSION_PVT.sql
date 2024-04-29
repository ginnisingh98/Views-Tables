--------------------------------------------------------
--  DDL for Package OZF_FUND_EXTENSION_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OZF_FUND_EXTENSION_PVT" AUTHID CURRENT_USER AS
/* $Header: ozfvfexs.pls 115.1 2004/04/16 11:47:06 rimehrot noship $*/

---------------------------------------------------------------------
-- PROCEDURE
---   validate_delete_fund
--
-- PURPOSE
--    Validate whether a fund can be deleted. Called by 'Delete Objects' framework
--    1) identify and provide details of dependent objects that cannot be deleted.
--    2) if 1) has nothing, identify and provide details of various dependent object
--       that can be deleted and the relationships that can be disassociated.
--
-- HISTORY
--    02/20/02  yzhao  Created.
--
-- PARAMETERS
---------------------------------------------------------------------
PROCEDURE validate_delete_fund(
    p_api_version_number IN       NUMBER
  , p_init_msg_list      IN       VARCHAR2 := fnd_api.g_false
  , p_commit             IN       VARCHAR2 := fnd_api.g_false
  , p_object_id          IN       NUMBER
  , p_object_version_number IN    NUMBER
  , x_dependent_object_tbl  OUT NOCOPY   ams_utility_pvt.dependent_objects_tbl_type
  , x_return_status      OUT NOCOPY      VARCHAR2
  , x_msg_count          OUT NOCOPY      NUMBER
  , x_msg_data           OUT NOCOPY      VARCHAR2
);


---------------------------------------------------------------------
-- PROCEDURE
---   delete_fund
--
-- PURPOSE
--    api alled by 'Delete Objects' framework to do hard table delete
--
-- HISTORY
--    02/20/02  yzhao  Created.
--
-- PARAMETERS
---------------------------------------------------------------------
PROCEDURE delete_fund(
    p_api_version_number IN       NUMBER
  , p_init_msg_list      IN       VARCHAR2 := fnd_api.g_false
  , p_commit             IN       VARCHAR2 := fnd_api.g_false
  , p_object_id          IN       NUMBER
  , p_object_version_number IN    NUMBER
  , x_return_status      OUT NOCOPY      VARCHAR2
  , x_msg_count          OUT NOCOPY      NUMBER
  , x_msg_data           OUT NOCOPY      VARCHAR2
);

END OZF_Fund_Extension_Pvt;


 

/
