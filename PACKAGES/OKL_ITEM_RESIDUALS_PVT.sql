--------------------------------------------------------
--  DDL for Package OKL_ITEM_RESIDUALS_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OKL_ITEM_RESIDUALS_PVT" AUTHID CURRENT_USER AS
  /* $Header: OKLRIRSS.pls 120.0 2005/07/07 22:12:07 smadhava noship $ */
  -- Header record type
  SUBTYPE okl_irhv_rec  is okl_irh_pvt.okl_irhv_rec;
  -- Version record type
  SUBTYPE okl_icpv_rec  is okl_icp_pvt.icpv_rec_type;
  -- Lines record type
  SUBTYPE okl_irv_tbl is okl_irv_pvt.okl_irv_tbl;

  SUBTYPE okl_lrs_id_tbl is OKL_LEASE_RATE_SETS_PVT.OKL_NUMBER_TABLE;

  TYPE lrs_ref_rec IS RECORD (
      id                    OKL_LS_RT_FCTR_SETS_V.ID%TYPE,
      NAME                  OKL_LS_RT_FCTR_SETS_V.NAME%TYPE,
      version               OKL_FE_RATE_SET_VERSIONS_V.VERSION_NUMBER%TYPE,
      object_version_number OKL_FE_RATE_SET_VERSIONS_V.OBJECT_VERSION_NUMBER%TYPE );

  TYPE lrs_ref_tbl IS TABLE OF lrs_ref_rec
  INDEX BY BINARY_INTEGER;


 -- Global Constants
  G_PKG_NAME             CONSTANT VARCHAR2(200) := 'OKL_ITEM_RESIDUALS_PVT';
  G_APP_NAME             CONSTANT VARCHAR2(3)   :=  OKL_API.G_APP_NAME;
  G_SQLERRM_TOKEN        CONSTANT VARCHAR2(200) := 'SQLERRM';
  G_SQLCODE_TOKEN        CONSTANT VARCHAR2(200) := 'SQLCODE';
  G_DB_ERROR             CONSTANT VARCHAR2(12)  := 'OKL_DB_ERROR';
  G_PROG_NAME_TOKEN      CONSTANT VARCHAR2(9)   := 'PROG_NAME';
  G_COL_NAME_TOKEN		CONSTANT VARCHAR2(200) := OKL_API.G_COL_NAME_TOKEN;

  G_CAT_ITEM          CONSTANT VARCHAR2(30)      :=  OKL_IRH_PVT.G_CAT_ITEM;
  G_CAT_ITEM_CAT      CONSTANT VARCHAR2(30)      :=  OKL_IRH_PVT.G_CAT_ITEM_CAT;
  G_CAT_RES_CAT       CONSTANT VARCHAR2(30)      :=  OKL_IRH_PVT.G_CAT_RES_CAT;

  G_RESD_PERCENTAGE       CONSTANT VARCHAR2(30)  :=  OKL_IRH_PVT.G_RESD_PERCENTAGE;

  G_STS_ACTIVE        CONSTANT VARCHAR2(30)      :=  'ACTIVE';
  G_STS_UNDER_REV     CONSTANT VARCHAR2(30)      :=  'UNDER_REVISION';
  G_STS_NEW           CONSTANT VARCHAR2(30)      :=  'NEW';
  G_STS_SUBMITTED     CONSTANT VARCHAR2(30)      :=  'SUBMITTED';

  PROCEDURE get_effective_date(
                         p_api_version       IN  NUMBER
                       , p_init_msg_list     IN  VARCHAR2 DEFAULT OKL_API.G_FALSE
                       , x_return_status     OUT NOCOPY VARCHAR2
                       , x_msg_count         OUT NOCOPY NUMBER
                       , x_msg_data          OUT NOCOPY VARCHAR2
                       , p_item_resdl_ver_id IN  NUMBER
                       , x_calc_date         OUT NOCOPY DATE
                       );
  PROCEDURE create_irs (
                         p_api_version      IN  NUMBER
                       , p_init_msg_list    IN  VARCHAR2 DEFAULT OKL_API.G_FALSE
                       , x_return_status    OUT NOCOPY VARCHAR2
                       , x_msg_count        OUT NOCOPY NUMBER
                       , x_msg_data         OUT NOCOPY VARCHAR2
                       , p_irhv_rec         IN         okl_irhv_rec
                       , p_icpv_rec         IN         okl_icpv_rec
                       , p_irv_tbl          IN         okl_irv_tbl
                       , x_irhv_rec         OUT NOCOPY okl_irhv_rec
                       , x_icpv_rec         OUT NOCOPY okl_icpv_rec
                        );

  PROCEDURE update_version_irs (
                         p_api_version      IN         NUMBER
                       , p_init_msg_list    IN         VARCHAR2 DEFAULT OKL_API.G_FALSE
                       , x_return_status    OUT NOCOPY VARCHAR2
                       , x_msg_count        OUT NOCOPY NUMBER
                       , x_msg_data         OUT NOCOPY VARCHAR2
                       , p_irhv_rec         IN         okl_irhv_rec
                       , p_icpv_rec         IN         okl_icpv_rec
                       , p_irv_tbl          IN         okl_irv_tbl
                       , x_irhv_rec         OUT NOCOPY okl_irhv_rec
                       , x_icpv_rec         OUT NOCOPY okl_icpv_rec
                       );
  procedure create_version_irs (
                         p_api_version      IN  NUMBER
                       , p_init_msg_list    IN  VARCHAR2 DEFAULT OKL_API.G_FALSE
                       , x_return_status    OUT NOCOPY VARCHAR2
                       , x_msg_count        OUT NOCOPY NUMBER
                       , x_msg_data         OUT NOCOPY VARCHAR2
                       , p_irhv_rec         IN         okl_irhv_rec
                       , p_icpv_rec         IN         okl_icpv_rec
                       , p_irv_tbl          IN         okl_irv_tbl
                       , x_irhv_rec         OUT NOCOPY okl_irhv_rec
                       , x_icpv_rec         OUT NOCOPY okl_icpv_rec
                        );

  PROCEDURE change_LRS_sts (
                         p_api_version      IN  NUMBER
                       , p_init_msg_list    IN  VARCHAR2 DEFAULT OKL_API.G_FALSE
                       , x_return_status    OUT NOCOPY VARCHAR2
                       , x_msg_count        OUT NOCOPY NUMBER
                       , x_msg_data         OUT NOCOPY VARCHAR2
                       , p_confirm_yn       IN         VARCHAR2
                       , p_icpv_rec         IN         okl_icpv_rec
                       , x_lrs_list         OUT NOCOPY lrs_ref_tbl
                       , x_change_sts       OUT NOCOPY VARCHAR2
                        );
  PROCEDURE activate_item_residual(
                         p_api_version           IN         NUMBER
                       , p_init_msg_list         IN         VARCHAR2 DEFAULT OKL_API.G_FALSE
                       , x_return_status         OUT NOCOPY VARCHAR2
                       , x_msg_count             OUT NOCOPY NUMBER
                       , x_msg_data              OUT NOCOPY VARCHAR2
                       , p_item_resdl_version_id IN         NUMBER
                       );

  PROCEDURE remove_terms(
                         p_api_version      IN         NUMBER
                       , p_init_msg_list    IN         VARCHAR2 DEFAULT OKL_API.G_FALSE
                       , x_return_status    OUT NOCOPY VARCHAR2
                       , x_msg_count        OUT NOCOPY NUMBER
                       , x_msg_data         OUT NOCOPY VARCHAR2
                       , p_irv_tbl          IN         okl_irv_tbl);
  PROCEDURE create_irs_submit (
                         p_api_version      IN  NUMBER
                       , p_init_msg_list    IN  VARCHAR2 DEFAULT OKL_API.G_FALSE
                       , x_return_status    OUT NOCOPY VARCHAR2
                       , x_msg_count        OUT NOCOPY NUMBER
                       , x_msg_data         OUT NOCOPY VARCHAR2
                       , p_irhv_rec         IN         okl_irhv_rec
                       , p_icpv_rec         IN         okl_icpv_rec
                       , p_irv_tbl          IN         okl_irv_tbl
                       , x_irhv_rec         OUT NOCOPY okl_irhv_rec
                       , x_icpv_rec         OUT NOCOPY okl_icpv_rec
                        );
  PROCEDURE update_version_irs_submit (
                         p_api_version      IN  NUMBER
                       , p_init_msg_list    IN  VARCHAR2 DEFAULT OKL_API.G_FALSE
                       , x_return_status    OUT NOCOPY VARCHAR2
                       , x_msg_count        OUT NOCOPY NUMBER
                       , x_msg_data         OUT NOCOPY VARCHAR2
                       , p_irhv_rec         IN         okl_irhv_rec
                       , p_icpv_rec         IN         okl_icpv_rec
                       , p_irv_tbl          IN         okl_irv_tbl
                       , x_irhv_rec         OUT NOCOPY okl_irhv_rec
                       , x_icpv_rec         OUT NOCOPY okl_icpv_rec
                        );
  PROCEDURE create_version_irs_submit (
                         p_api_version      IN  NUMBER
                       , p_init_msg_list    IN  VARCHAR2 DEFAULT OKL_API.G_FALSE
                       , x_return_status    OUT NOCOPY VARCHAR2
                       , x_msg_count        OUT NOCOPY NUMBER
                       , x_msg_data         OUT NOCOPY VARCHAR2
                       , p_irhv_rec         IN         okl_irhv_rec
                       , p_icpv_rec         IN         okl_icpv_rec
                       , p_irv_tbl          IN         okl_irv_tbl
                       , x_irhv_rec         OUT NOCOPY okl_irhv_rec
                       , x_icpv_rec         OUT NOCOPY okl_icpv_rec
                        );
  PROCEDURE submit_item_residual(
     p_api_version           IN   NUMBER,
     p_init_msg_list         IN   VARCHAR2 DEFAULT OKL_API.G_FALSE,
     x_return_status         OUT  NOCOPY VARCHAR2,
     x_msg_count             OUT  NOCOPY NUMBER,
     x_msg_data              OUT  NOCOPY VARCHAR2,
     p_itm_rsdl_version_id   IN   OKL_ITM_CAT_RV_PRCS_V.ID%TYPE
    );
END OKL_ITEM_RESIDUALS_PVT;

 

/
