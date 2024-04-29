--------------------------------------------------------
--  DDL for Package FA_MC_BOOK_CONTROLS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."FA_MC_BOOK_CONTROLS_PKG" AUTHID CURRENT_USER as
/* $Header: faxmcbcs.pls 120.1.12010000.2 2009/07/19 10:04:54 glchen ship $   */

--*********************** Public procedures ******************************--

-----------------------------------------------------------------------------
--
-- Currency Based Insert
-- Called from ledger when adding an ALC
--
-----------------------------------------------------------------------------

PROCEDURE add_new_currency
   (p_api_version              IN     NUMBER,
    p_init_msg_list            IN     VARCHAR2 := FND_API.G_FALSE,
    p_commit                   IN     VARCHAR2 := FND_API.G_FALSE,
    p_validation_level         IN     NUMBER   := FND_API.G_VALID_LEVEL_FULL,
    p_calling_fn               IN     VARCHAR2,

    p_src_ledger_id            IN     NUMBER,
    p_alc_ledger_id            IN     NUMBER,
    p_src_currency             IN     VARCHAR2,
    p_alc_currency             IN     VARCHAR2,
    x_return_status               OUT NOCOPY VARCHAR2,
    x_msg_count                   OUT NOCOPY NUMBER,
    x_msg_data                    OUT NOCOPY VARCHAR2
   );

-----------------------------------------------------------------------------
--
-- Book Based Insert
-- Called from book controls related apis to process MRC
--
-----------------------------------------------------------------------------

PROCEDURE add_new_book
   (p_api_version              IN     NUMBER,
    p_init_msg_list            IN     VARCHAR2 := FND_API.G_FALSE,
    p_commit                   IN     VARCHAR2 := FND_API.G_FALSE,
    p_validation_level         IN     NUMBER   := FND_API.G_VALID_LEVEL_FULL,
    p_calling_fn               IN     VARCHAR2,

    p_book_type_code           IN     VARCHAR2,
    x_return_status               OUT NOCOPY VARCHAR2,
    x_msg_count                   OUT NOCOPY NUMBER,
    x_msg_data                    OUT NOCOPY VARCHAR2
   );

-----------------------------------------------------------------------------
--
-- Currency Based Disable
-- Called from ledger when disabling an ALC
--
-----------------------------------------------------------------------------

PROCEDURE disable_currency
   (p_api_version              IN     NUMBER,
    p_init_msg_list            IN     VARCHAR2 := FND_API.G_FALSE,
    p_commit                   IN     VARCHAR2 := FND_API.G_FALSE,
    p_validation_level         IN     NUMBER   := FND_API.G_VALID_LEVEL_FULL,
    p_calling_fn               IN     VARCHAR2,

    p_src_ledger_id            IN     NUMBER,
    p_alc_ledger_id            IN     NUMBER,
    p_src_currency             IN     VARCHAR2,
    p_alc_currency             IN     VARCHAR2,
    x_return_status               OUT NOCOPY VARCHAR2,
    x_msg_count                   OUT NOCOPY NUMBER,
    x_msg_data                    OUT NOCOPY VARCHAR2
   );

END FA_MC_BOOK_CONTROLS_PKG;

/
