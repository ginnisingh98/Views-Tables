--------------------------------------------------------
--  DDL for Package OKL_ACTIVATE_ASSET_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OKL_ACTIVATE_ASSET_PVT" AUTHID CURRENT_USER As
/* $Header: OKLRACAS.pls 120.3 2006/02/10 18:40:53 rpillay noship $ */
G_APP_NAME   VARCHAR2(30) := OKL_API.G_APP_NAME;
SUBTYPE cimv_rec_type is  OKL_OKC_MIGRATION_PVT.cimv_rec_type;
SUBTYPE cimv_tbl_type is  OKL_OKC_MIGRATION_PVT.cimv_tbl_type;
SUBTYPE talv_rec_type is  OKL_TXL_ASSETS_PUB.tlpv_rec_type;
SUBTYPE tadv_rec_type is  OKL_TXD_ASSETS_PUB.adpv_rec_type;

    Cursor bk_dfs_csr( ctId   okx_ast_bks_v.depreciation_category%TYPE,
                       effDat okx_ast_bks_v.acquisition_date%TYPE,
                       bk     okx_ast_bks_v.book_type_code%TYPE) IS
    select life_in_months,
           deprn_method,
	   adjusted_rate
    from okx_ast_ct_bk_dfs_v
    where category_id = ctId
        and nvl(start_dpis, effDat) <= effDat
        and nvl(end_dpis, effDat+1) > effDat
        and book_type_code = bk;

    Cursor l_hdr_csr(  chrId NUMBER ) is
    select khr.orig_system_source_code,
           khr.start_date,
           khr.template_yn,
           khr.deal_type,
           pdt.id  pid,
	   nvl(pdt.reporting_pdt_id, -1) report_pdt_id,
           khr.currency_code currency_code,
           khr.term_duration term,
           khr.authoring_org_id
    from   okl_k_headers_full_v khr,
           okl_products_v pdt
    where  khr.id = chrId
        and khr.pdt_id = pdt.id(+);


PROCEDURE  ACTIVATE_ASSET(p_api_version   IN  NUMBER,
                          p_init_msg_list IN  VARCHAR2 DEFAULT OKL_API.G_FALSE,
                          x_return_status OUT NOCOPY VARCHAR2,
                          x_msg_count     OUT NOCOPY NUMBER,
                          x_msg_data      OUT NOCOPY VARCHAR2,
                          p_chrv_id       IN  NUMBER,
                          p_call_mode     IN  VARCHAR2,
                          x_cimv_tbl      OUT NOCOPY cimv_tbl_type);
PROCEDURE REBOOK_ASSET  (p_api_version   IN  NUMBER,
                         p_init_msg_list IN  VARCHAR2 DEFAULT OKL_API.G_FALSE,
                         x_return_status OUT NOCOPY VARCHAR2,
                         x_msg_count     OUT NOCOPY NUMBER,
                         x_msg_data      OUT NOCOPY VARCHAR2,
                         p_rbk_chr_id    IN  NUMBER);
PROCEDURE MASS_REBOOK_ASSET  (p_api_version   IN  NUMBER,
                              p_init_msg_list IN  VARCHAR2 DEFAULT OKL_API.G_FALSE,
                              x_return_status OUT NOCOPY VARCHAR2,
                              x_msg_count     OUT NOCOPY NUMBER,
                              x_msg_data      OUT NOCOPY VARCHAR2,
                              p_rbk_chr_id    IN  NUMBER
                             );
PROCEDURE RELEASE_ASSET (p_api_version   IN  NUMBER,
                         p_init_msg_list IN  VARCHAR2 DEFAULT OKL_API.G_FALSE,
                         x_return_status OUT NOCOPY VARCHAR2,
                         x_msg_count     OUT NOCOPY NUMBER,
                         x_msg_data      OUT NOCOPY VARCHAR2,
                         p_rel_chr_id    IN  NUMBER);
 ---------------------------------------------------------------------
 --Bug# : pricing parameters
 --------------------------------------------------------------------
  --Bug# :
  TYPE AST_DTL_REC_TYPE is RECORD
                (ASSET_NUMBER            FA_ADDITIONS.ASSET_NUMBER%TYPE,
                 BOOK_TYPE_CODE          FA_BOOKS.BOOK_TYPE_CODE%TYPE,
                 BOOK_CLASS              FA_BOOK_CONTROLS.BOOK_CLASS%TYPE,
                 DEPRN_METHOD            FA_BOOKS.DEPRN_METHOD_CODE%TYPE,
                 DEPRN_METHOD_ID         FA_METHODS.METHOD_ID%TYPE,
                 IN_SERVICE_DATE         FA_BOOKS.DATE_PLACED_IN_SERVICE%TYPE,
                 LIFE_IN_MONTHS          FA_BOOKS.LIFE_IN_MONTHS%TYPE,
                 BASIC_RATE              FA_BOOKS.BASIC_RATE%TYPE,
                 ADJUSTED_RATE           FA_BOOKS.ADJUSTED_RATE%TYPE,
                 SALVAGE_VALUE           FA_BOOKS.SALVAGE_VALUE%TYPE,
                 PERCENT_SALVAGE_VALUE   FA_BOOKS.PERCENT_SALVAGE_VALUE%TYPE,
                 PRORATE_CONVENTION_CODE FA_BOOKS.PRORATE_CONVENTION_CODE%TYPE,
                 COST                    FA_BOOKS.COST%TYPE
                );
 TYPE ast_dtl_tbl_type IS TABLE OF ast_dtl_rec_type INDEX BY BINARY_INTEGER;

 --Bug# 3621875
 Procedure Get_pricing_Parameters ( p_api_version   IN  NUMBER,
                                     p_init_msg_list IN  VARCHAR2 DEFAULT OKL_API.G_FALSE,
                                     x_return_status OUT NOCOPY VARCHAR2,
                                     x_msg_count     OUT NOCOPY NUMBER,
                                     x_msg_data      OUT NOCOPY VARCHAR2,
                                     p_chr_id        IN  NUMBER,
                                     p_cle_id        IN  NUMBER,
                                     x_ast_dtl_tbl   OUT NOCOPY ast_dtl_tbl_type);
--Bug# 4899328
Procedure recalculate_asset_cost ( p_api_version   IN  NUMBER,
                                   p_init_msg_list IN  VARCHAR2 DEFAULT OKL_API.G_FALSE,
                                   x_return_status OUT NOCOPY VARCHAR2,
                                   x_msg_count     OUT NOCOPY NUMBER,
                                   x_msg_data      OUT NOCOPY VARCHAR2,
                                   p_chr_id        IN  NUMBER,
                                   p_cle_id        IN  NUMBER);

END OKL_ACTIVATE_ASSET_PVT;

/
