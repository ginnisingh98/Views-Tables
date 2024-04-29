--------------------------------------------------------
--  DDL for Package AMS_PARTYIMPORT_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."AMS_PARTYIMPORT_PUB" AUTHID CURRENT_USER AS
/* $Header: amspptys.pls 115.5 2000/01/09 18:03:50 pkm ship   $ */

-----------------------------------------------------------
-- PACKAGE
--    AMS_PartyImport_PUB
--
-- PURPOSE
--    Public API for Oracle Marketing Party Sources.
--
-- PROCEDURES
--    Set_UsedParty
--
------------------------------------------------------------


--------------------------------------------------------------------
-- PROCEDURE
--    Set_UsedParty
--
-- PURPOSE
--
--
-- PARAMETERS
--    p_party_sources_id: identifies the party source which needs
--       to be updated.
--
--
-- NOTES
--    1. Calls the update API.
--------------------------------------------------------------------
PROCEDURE Set_UsedParty (
   p_api_version       IN  NUMBER,
   p_init_msg_list     IN  VARCHAR2  := FND_API.g_false,
   p_commit            IN  VARCHAR2  := FND_API.g_false,
   p_validation_level  IN  NUMBER    := FND_API.g_valid_level_full,

   x_return_status     OUT VARCHAR2,
   x_msg_count         OUT NUMBER,
   x_msg_data          OUT VARCHAR2,

   p_party_sources_id  IN  NUMBER
);


END AMS_PartyImport_PUB;

 

/
