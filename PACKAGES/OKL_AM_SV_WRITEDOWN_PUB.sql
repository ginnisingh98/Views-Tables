--------------------------------------------------------
--  DDL for Package OKL_AM_SV_WRITEDOWN_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OKL_AM_SV_WRITEDOWN_PUB" AUTHID CURRENT_USER AS
/* $Header: OKLPSVWS.pls 115.4 2002/04/21 20:27:56 pkm ship        $ */



SUBTYPE assets_tbl_type  IS OKL_AM_SV_WRITEDOWN_PVT.assets_tbl_type;

---------------------------------------------------------------------------
   --  GLOBAL CONSTANTS
  ---------------------------------------------------------------------------

   G_PKG_NAME             CONSTANT VARCHAR2(200) := 'OKL_AM_SV_WRITEDOWN_PUB';
   G_APP_NAME             CONSTANT VARCHAR2(3)   :=  OKC_API.G_APP_NAME;
   G_UNEXPECTED_ERROR     CONSTANT VARCHAR2(200) := 'OKC_CONTRACTS_UNEXPECTED_ERROR';
   G_SQLERRM_TOKEN        CONSTANT VARCHAR2(200) := 'SQLerrm';
   G_SQLCODE_TOKEN        CONSTANT VARCHAR2(200) := 'SQLcode';



   --  The main body of OKL_AM_SV_WRITEDOWN_PUB
   PROCEDURE create_salvage_value_trx( p_api_version             IN   NUMBER,
                                  p_init_msg_list         IN     VARCHAR2 DEFAULT OKC_API.G_FALSE,
                                  x_return_status         OUT    NOCOPY VARCHAR2,
                                  x_msg_count             OUT    NOCOPY NUMBER,
                                  x_msg_data              OUT    NOCOPY VARCHAR2,
                                  p_assets_tbl            IN     assets_tbl_type,
                                  x_salvage_value_status  OUT    NOCOPY VARCHAR2);  -- this flag is redundant,
                                                                                  -- we are keeping it for the time
                                                                                  -- being to avoid
                                                                                  -- rosetta regeneration

END OKL_AM_SV_WRITEDOWN_PUB;

 

/
