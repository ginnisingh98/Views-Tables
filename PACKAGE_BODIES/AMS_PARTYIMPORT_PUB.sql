--------------------------------------------------------
--  DDL for Package Body AMS_PARTYIMPORT_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."AMS_PARTYIMPORT_PUB" AS
/* $Header: amspptyb.pls 115.5 2000/01/09 18:03:40 pkm ship   $ */

-----------------------------------------------------------
-- PACKAGE
--    AMS_PartyImport_PUB
--
-- PROCEDURES
--
-- HISTORY
-- 12-Nov-1999 choang      Created.
------------------------------------------------------------

G_PKG_NAME           CONSTANT VARCHAR2(30) := 'AMS_PartyImport_PUB';


--------------------------------------------------------------------
-- PROCEDURE
--    Set_UsedParty
PROCEDURE Set_UsedParty (
   p_api_version       IN  NUMBER,
   p_init_msg_list     IN  VARCHAR2  := FND_API.g_false,
   p_commit            IN  VARCHAR2  := FND_API.g_false,
   p_validation_level  IN  NUMBER    := FND_API.g_valid_level_full,

   x_return_status     OUT VARCHAR2,
   x_msg_count         OUT NUMBER,
   x_msg_data          OUT VARCHAR2,

   p_party_sources_id  IN  NUMBER
)
IS
   l_api_version     CONSTANT NUMBER       := 1.0;

   l_party_rec       AMS_PartyImport_PVT.Party_Rec_Type;
BEGIN
   --
   -- Initialize the record with the g_miss values.
   AMS_PartyImport_PVT.Init_Party_Rec (l_party_rec);

   l_party_rec.party_sources_id := p_party_sources_id;

   --
   -- Set the USED_FLAG to 'Y'
   l_party_rec.used_flag := 'Y';

   AMS_PartyImport_PVT.Update_Party (
      p_api_version        => l_api_version,
      p_init_msg_list      => p_init_msg_list,
      p_commit             => p_commit,
      p_validation_level   => p_validation_level,

      x_return_status      => x_return_status,
      x_msg_count          => x_msg_count,
      x_msg_data           => x_msg_data,

      p_party_rec          => l_party_rec
   );

END Set_UsedParty;


END AMS_PartyImport_PUB;

/
