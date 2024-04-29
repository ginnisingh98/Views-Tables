--------------------------------------------------------
--  DDL for Package OKL_BLK_AST_UPD_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OKL_BLK_AST_UPD_PUB" AUTHID CURRENT_USER AS
/* $Header: OKLPBAUS.pls 120.1 2005/09/07 20:58:28 rkuttiya noship $ */

  ---------------------------------------------------------------------------
  -- GLOBAL CONSTANTS
  ---------------------------------------------------------------------------
  G_APP_NAME                    CONSTANT VARCHAR2(3)   := 'OKL';
  G_PKG_NAME                    CONSTANT VARCHAR2(30)  := 'OKL_BLK_AST_UPD_PUB';
  G_API_NAME                    CONSTANT VARCHAR2(30)  := 'Update_Location';
  G_API_VERSION                 CONSTANT NUMBER        := 1;
  G_COMMIT                      CONSTANT VARCHAR2(1)   := FND_API.G_TRUE;
  G_INIT_MSG_LIST               CONSTANT VARCHAR2(1)   := FND_API.G_TRUE;
  G_VALIDATION_LEVEL            CONSTANT NUMBER        := FND_API.G_VALID_LEVEL_FULL;

  SUBTYPE blk_rec_type IS okl_blk_ast_upd_pvt.okl_loc_rec_type;
  SUBTYPE blk_tbl_type IS okl_blk_ast_upd_pvt.okl_loc_tbl_type;
  ---------------------------------------------------------------------------
  -- Procedures and Functions
  ---------------------------------------------------------------------------
  PROCEDURE update_location(
                            p_api_version                    IN  NUMBER,
                            p_init_msg_list                	 IN  VARCHAR2 DEFAULT OKC_API.G_FALSE,
                            p_loc_rec                        IN  blk_rec_type,
                            x_return_status                	 OUT NOCOPY VARCHAR2,
                            x_msg_count                    	 OUT NOCOPY NUMBER,
                            x_msg_data                     	 OUT NOCOPY VARCHAR2);

  PROCEDURE update_location(
                            p_api_version                    IN  NUMBER,
                            p_init_msg_list                	 IN  VARCHAR2 DEFAULT OKC_API.G_FALSE,
                            p_loc_tbl                        IN  blk_tbl_type,
                            x_return_status                	 OUT NOCOPY VARCHAR2,
                            x_msg_count                    	 OUT NOCOPY NUMBER,
                            x_msg_data                     	 OUT NOCOPY VARCHAR2);




END okl_blk_ast_upd_pub;



 

/
