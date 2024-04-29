--------------------------------------------------------
--  DDL for Package PV_PTR_MEMBER_TYPE_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PV_PTR_MEMBER_TYPE_PVT" AUTHID CURRENT_USER AS
/* $Header: pvxvmtcs.pls 120.1 2005/06/26 23:16:01 appldev ship $ */
-- ===============================================================

--------------------------------------------------------------------------
   -- PROCEDURE
   --   Register_term_ptr_memb_type
   --
   -- PURPOSE
   --   This api can register as well as terminate member type and its corresponding relationships
   -- IN
   --   partner_id   IN  NUMBER.
   --     for which member type is getting registered/terminated - either created/updated
   --   p_current_memb_type.IN  VARCHAR2 DEFAULT NULL
   --     The existing member type stored in the db. if its not passed, we will query and get it
   --   p_new_memb_type IN  VARCHAR2.
   --     pass GLOBAL,SUBSIDIARY or STANDARD if you want to register a new member type(also validated).
   --     if you want to terminate the relationship pass null.
   --   p_global_ptr_id. IN  NUMBER DEFAULT NULL
   --     if the new member type is  SUBSIDIARY, pass the global's partner id from pv_partner_profiles table
   --     this is validated only if the new member type is  SUBSIDIARY

   -- HISTORY
   --   15-SEP-2003        pukken        CREATION
   --------------------------------------------------------------------------
PROCEDURE Register_term_ptr_memb_type
(
    p_api_version_number  IN  NUMBER
   ,p_init_msg_list       IN  VARCHAR2 := FND_API.G_FALSE
   ,p_commit              IN  VARCHAR2 := FND_API.G_FALSE
   ,p_validation_level    IN  NUMBER   :=  FND_API.G_VALID_LEVEL_FULL
   ,p_partner_id          IN  NUMBER
   ,p_current_memb_type   IN  VARCHAR2 DEFAULT NULL
   ,p_new_memb_type       IN  VARCHAR2
   ,p_global_ptr_id	  IN  NUMBER   DEFAULT NULL
   ,x_return_status       OUT NOCOPY VARCHAR2
   ,x_msg_count           OUT NOCOPY NUMBER
   ,x_msg_data            OUT NOCOPY VARCHAR2
);

---------------------------------------------

-- PROCEDURE
--   Pv_ptr_member_type_pvt.Process_ptr_member_type
--
-- PURPOSE
--   Change Membership Type.
-- IN
--   partner_id             IN NUMBER
--     partner_id for which member type is getting changed
--   p_chg_from_memb_type   IN  VARCHAR2 := NULL
--     if not given, will get from profile, should be 'SUBSIDIARY','GLOBAL','STANDARD'
--   p_chg_to_memb_type     IN  VARCHAR2
--     should be 'SUBSIDIARY','GLOBAL','STANDARD'
--   p_chg_to_global_ptr_id IN  NUMBER   DEFAULT NULL
--     if p_chg_to_memb_type is 'SUBSIDIARY', this needs to be passed for identifying the global partner_id for the subsidiary
-- USED BY
--   called from vendor facing UI when member type change is requested by partner
--
-- HISTORY
--   15-SEP-2003        pukken        CREATION
--------------------------------------------------------------------------

PROCEDURE Process_ptr_member_type
(
    p_api_version_number    IN  NUMBER
   ,p_init_msg_list         IN  VARCHAR2 := FND_API.G_FALSE
   ,p_commit                IN  VARCHAR2 := FND_API.G_FALSE
   ,p_validation_level      IN  NUMBER   := FND_API.G_VALID_LEVEL_FULL
   ,p_partner_id            IN  NUMBER
   ,p_chg_from_memb_type    IN  VARCHAR2 DEFAULT NULL
   ,p_chg_to_memb_type      IN  VARCHAR2
   ,p_chg_to_global_ptr_id  IN  NUMBER   DEFAULT NULL
   ,x_return_status         OUT NOCOPY VARCHAR2
   ,x_msg_count             OUT NOCOPY NUMBER
   ,x_msg_data              OUT NOCOPY VARCHAR2
);

PROCEDURE update_partner_dtl
(
   p_api_version_number      IN  NUMBER
   , p_init_msg_list         IN  VARCHAR2 := FND_API.G_FALSE
   , p_commit                IN  VARCHAR2 := FND_API.G_FALSE
   , p_validation_level      IN  NUMBER   :=  FND_API.G_VALID_LEVEL_FULL
   , p_partner_id            IN  NUMBER
   , p_old_partner_status    IN  VARCHAR2
   , p_new_partner_status    IN  VARCHAR2
   , p_chg_from_memb_type    IN  VARCHAR2
   , p_chg_to_memb_type      IN  VARCHAR2
   , p_old_global_ptr_id     IN  NUMBER   DEFAULT NULL
   , p_new_global_ptr_id     IN  NUMBER   DEFAULT NULL
   , x_return_status         OUT NOCOPY VARCHAR2
   , x_msg_count             OUT NOCOPY NUMBER
   , x_msg_data              OUT NOCOPY VARCHAR2
);

FUNCTION validate_global_partner_orgzn
( p_global_prtnr_org_number  IN  VARCHAR2
)RETURN VARCHAR2;

FUNCTION get_global_partner_id
( p_global_prtnr_org_number  IN  VARCHAR2
)RETURN NUMBER;

FUNCTION terminate_partner
(
   p_subscription_guid  IN RAW
   , p_event            IN OUT NOCOPY wf_event_t
) RETURN VARCHAR2 ;



END Pv_ptr_member_type_pvt;

 

/
