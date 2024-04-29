--------------------------------------------------------
--  DDL for Package FA_DEPRN_ROLLBACK_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."FA_DEPRN_ROLLBACK_PUB" AUTHID CURRENT_USER AS
/* $Header: FAPDRBS.pls 120.2.12010000.2 2009/07/19 14:29:23 glchen ship $   */
procedure do_rollback (
   -- Standard Paramters --
   p_api_version              IN      NUMBER,
   p_init_msg_list            IN      VARCHAR2 := FND_API.G_FALSE,
   p_commit                   IN      VARCHAR2 := FND_API.G_FALSE,
   p_validation_level         IN      NUMBER:=FND_API.G_VALID_LEVEL_FULL,
   x_return_status               OUT  NOCOPY VARCHAR2,
   x_msg_count                   OUT  NOCOPY NUMBER,
   x_msg_data                    OUT  NOCOPY VARCHAR2,
   p_calling_fn               IN      VARCHAR2,
   -- Asset Object --
   px_asset_hdr_rec           IN OUT  NOCOPY fa_api_types.asset_hdr_rec_type);

END FA_DEPRN_ROLLBACK_PUB;

/
