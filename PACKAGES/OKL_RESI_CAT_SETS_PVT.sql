--------------------------------------------------------
--  DDL for Package OKL_RESI_CAT_SETS_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OKL_RESI_CAT_SETS_PVT" authid current_user as
  /* $Header: OKLRRCSS.pls 120.2 2005/09/14 06:42:33 smadhava noship $ */
  -- Header record type
  subtype okl_rcsv_rec  is okl_rcs_pvt.okl_rcsv_rec;
  -- Lines table type
  subtype okl_res_tbl is okl_res_pvt.okl_res_tbl;

  -- Global Constants
  G_PKG_NAME             CONSTANT VARCHAR2(200) := 'OKL_RESI_CAT_SETS_PVT';
  G_APP_NAME             CONSTANT VARCHAR2(3)   :=  OKL_API.G_APP_NAME;
  G_SQLERRM_TOKEN        CONSTANT VARCHAR2(200) := 'SQLERRM';
  G_SQLCODE_TOKEN        CONSTANT VARCHAR2(200) := 'SQLCODE';
  G_DB_ERROR             CONSTANT VARCHAR2(12)  := 'OKL_DB_ERROR';
  G_PROG_NAME_TOKEN      CONSTANT VARCHAR2(9)   := 'PROG_NAME';
  G_COL_NAME_TOKEN		CONSTANT VARCHAR2(200) := OKL_API.G_COL_NAME_TOKEN;
  G_CAT_ITEM             CONSTANT VARCHAR2(30)  :=  OKL_RCS_PVT.G_CAT_ITEM;
  G_CAT_ITEM_CAT         CONSTANT VARCHAR2(30)  :=  OKL_RCS_PVT.G_CAT_ITEM_CAT;
  G_STS_INACTIVE         CONSTANT VARCHAR2(30)  :=  OKL_RCS_PVT.G_STS_INACTIVE;
  G_STS_ACTIVE           CONSTANT VARCHAR2(30)  :=  OKL_RCS_PVT.G_STS_ACTIVE;
  -- Global exceptions
  G_EXCEPTION_HALT_VALIDATION   EXCEPTION;

  procedure create_rcs (
                         p_api_version      IN  NUMBER
                       , p_init_msg_list    IN  VARCHAR2 DEFAULT OKL_API.G_FALSE
                       , x_return_status    OUT NOCOPY VARCHAR2
                       , x_msg_count        OUT NOCOPY NUMBER
                       , x_msg_data         OUT NOCOPY VARCHAR2
                       , p_rcsv_rec         IN         okl_rcsv_rec
                       , p_res_tbl          IN         okl_res_tbl
                       , x_rcsv_rec         OUT NOCOPY okl_rcsv_rec
                       , x_res_tbl          OUT NOCOPY okl_res_tbl
                        );
  PROCEDURE update_rcs (
                         p_api_version      IN         NUMBER
                       , p_init_msg_list    IN         VARCHAR2 DEFAULT OKL_API.G_FALSE
                       , x_return_status    OUT NOCOPY VARCHAR2
                       , x_msg_count        OUT NOCOPY NUMBER
                       , x_msg_data         OUT NOCOPY VARCHAR2
                       , p_rcsv_rec         IN         okl_rcsv_rec
                       , p_res_tbl          IN         okl_res_tbl
                       , x_rcsv_rec         OUT NOCOPY okl_rcsv_rec
                        );

  PROCEDURE activate_rcs (
                         p_api_version      IN         NUMBER
                       , p_init_msg_list    IN         VARCHAR2 DEFAULT OKL_API.G_FALSE
                       , x_return_status    OUT NOCOPY VARCHAR2
                       , x_msg_count        OUT NOCOPY NUMBER
                       , x_msg_data         OUT NOCOPY VARCHAR2
                       , p_rcsv_rec         IN         okl_rcsv_rec
                       , p_res_tbl          IN         okl_res_tbl
                       , x_rcsv_rec         OUT NOCOPY okl_rcsv_rec
                        );
  PROCEDURE Inactivate_rcs (
                         p_api_version      IN         NUMBER
                       , p_init_msg_list    IN         VARCHAR2 DEFAULT OKL_API.G_FALSE
                       , x_return_status    OUT NOCOPY VARCHAR2
                       , x_msg_count        OUT NOCOPY NUMBER
                       , x_msg_data         OUT NOCOPY VARCHAR2
                       , p_rcs_id           IN         NUMBER
                       , p_obj_ver_number   IN         NUMBER
                        );
PROCEDURE delete_objects(
                         p_api_version      IN         NUMBER
                       , p_init_msg_list    IN         VARCHAR2 DEFAULT OKL_API.G_FALSE
                       , x_return_status    OUT NOCOPY VARCHAR2
                       , x_msg_count        OUT NOCOPY NUMBER
                       , x_msg_data         OUT NOCOPY VARCHAR2
                       , p_res_tbl          IN         okl_res_tbl);
end OKL_RESI_CAT_SETS_PVT;

 

/
