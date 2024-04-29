--------------------------------------------------------
--  DDL for Package OKL_AM_SV_WRITEDOWN_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OKL_AM_SV_WRITEDOWN_PVT" AUTHID CURRENT_USER AS
/* $Header: OKLRSVWS.pls 115.5 2002/11/04 20:48:12 sechawla noship $ */


   TYPE assets_rec_type IS RECORD( p_cle_id               NUMBER DEFAULT OKL_API.G_MISS_NUM,
                                   p_new_salvage_value    NUMBER DEFAULT OKL_API.G_MISS_NUM);

   TYPE assets_tbl_type IS TABLE OF assets_rec_type INDEX BY BINARY_INTEGER;


  ---------------------------------------------------------------------------
   --  GLOBAL CONSTANTS
  ---------------------------------------------------------------------------
   G_INVALID_VALUE        CONSTANT VARCHAR2(200) := okc_api.G_INVALID_VALUE;
   G_COL_NAME_TOKEN       CONSTANT VARCHAR2(200) := okc_api.G_COL_NAME_TOKEN;
   G_PKG_NAME             CONSTANT VARCHAR2(200) := 'OKL_AM_SV_WRITEDOWN_PVT';
   G_APP_NAME             CONSTANT VARCHAR2(3)   :=  OKL_API.G_APP_NAME;
   G_REQUIRED_VALUE       CONSTANT VARCHAR2(200) := okc_api.G_REQUIRED_VALUE;
   G_UNEXPECTED_ERROR     CONSTANT VARCHAR2(200) := 'OKL_CONTRACTS_UNEXPECTED_ERROR';
   G_SQLERRM_TOKEN        CONSTANT VARCHAR2(200) := 'SQLerrm';
   G_SQLCODE_TOKEN        CONSTANT VARCHAR2(200) := 'SQLcode';




   --  The main body of OKL_AM_SV_WRITEDOWN_PVT
   PROCEDURE create_salvage_value_trx( p_api_version           IN   NUMBER,
                                  p_init_msg_list         IN   VARCHAR2 DEFAULT OKL_API.G_FALSE,
                                  x_return_status         OUT  NOCOPY VARCHAR2,
                                  x_msg_count             OUT  NOCOPY NUMBER,
                                  x_msg_data              OUT  NOCOPY VARCHAR2,
                                  p_assets_tbl            IN   assets_tbl_type,
                                  x_salvage_value_status  OUT  NOCOPY VARCHAR2);  -- this flag is redundant,
                                                                                  -- we are keeping it for the time
                                                                                  -- being to avoid
                                                                                  -- rosetta regeneration



END OKL_AM_SV_WRITEDOWN_PVT;

 

/
