--------------------------------------------------------
--  DDL for Package OKL_AM_LOAD_CAT_BK_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OKL_AM_LOAD_CAT_BK_PUB" AUTHID CURRENT_USER AS
/* $Header: OKLPLCBS.pls 120.2 2005/10/30 04:25:34 appldev noship $ */


   SUBTYPE amhv_tbl_type IS OKL_AM_LOAD_CAT_BK_PVT.amhv_tbl_type;
---------------------------------------------------------------------------
   --  GLOBAL CONSTANTS
  ---------------------------------------------------------------------------

   G_PKG_NAME             CONSTANT VARCHAR2(200) := 'OKL_AM_LOAD_CAT_BK_PUB';
   G_APP_NAME             CONSTANT VARCHAR2(3)   :=  OKC_API.G_APP_NAME;
   G_UNEXPECTED_ERROR     CONSTANT VARCHAR2(200) := 'OKC_CONTRACTS_UNEXPECTED_ERROR';
   G_SQLERRM_TOKEN        CONSTANT VARCHAR2(200) := 'SQLerrm';
   G_SQLCODE_TOKEN        CONSTANT VARCHAR2(200) := 'SQLcode';



   --  The main body of OKL_AM_LOAD_CAT_BK_PUB
   PROCEDURE create_hold_setup_trx( p_api_version           IN   NUMBER,
                                  p_init_msg_list         IN   VARCHAR2 DEFAULT OKL_API.G_FALSE,
                                  p_book_type_code        IN   fa_book_controls.book_type_code%type,
                                  x_return_status         OUT  NOCOPY VARCHAR2,
                                  x_msg_count             OUT  NOCOPY NUMBER,
                                  x_msg_data              OUT  NOCOPY VARCHAR2,
                                  x_amhv_tbl              OUT  NOCOPY amhv_tbl_type
                                  );

END OKL_AM_LOAD_CAT_BK_PUB;

 

/
