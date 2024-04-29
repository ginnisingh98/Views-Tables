--------------------------------------------------------
--  DDL for Package OKL_ACCOUNT_DIST_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OKL_ACCOUNT_DIST_PVT" AUTHID CURRENT_USER AS
/* $Header: OKLRTDTS.pls 120.8.12010000.2 2008/08/14 12:08:33 racheruv ship $ */

SUBTYPE ctxt_val_tbl_type IS OKL_EXECUTE_FORMULA_PUB.ctxt_val_tbl_type;
SUBTYPE tabv_rec_type IS OKL_TRNS_ACC_DSTRS_PUB.tabv_rec_type;
SUBTYPE tabv_tbl_type IS OKL_TRNS_ACC_DSTRS_PUB.tabv_tbl_type;

SUBTYPE avlv_tbl_type IS OKL_TMPT_SET_PUB.avlv_tbl_type;
SUBTYPE avlv_rec_type IS OKL_TMPT_SET_PUB.avlv_rec_type;
SUBTYPE aetv_rec_type IS OKL_ACCT_EVENT_PUB.aetv_rec_type;
SUBTYPE acc_gen_primary_key IS Okl_Account_Generator_Pub.primary_key_tbl;

-- bug 4157521

SUBTYPE acc_gen_wf_sources_rec IS Okl_Account_Generator_Pub.acc_gen_wf_sources_rec;

-- Added by Santonyr on 26-Jul-2004 for the bug 3772490

SUBTYPE asev_rec_type IS Okl_Acct_Sources_Pvt.asev_rec_type;
SUBTYPE asev_tbl_type IS Okl_Acct_Sources_Pvt.asev_tbl_type;


TYPE  TMPL_IDENTIFY_REC_TYPE IS RECORD
  (PRODUCT_ID             NUMBER    := OKL_API.G_MISS_NUM,
   TRANSACTION_TYPE_ID    NUMBER    := OKL_API.G_MISS_NUM,
   STREAM_TYPE_ID         NUMBER    := OKL_API.G_MISS_NUM,
   ADVANCE_ARREARS        OKL_AE_TEMPLATES.ADVANCE_ARREARS%TYPE := OKL_API.G_MISS_CHAR,
   FACTORING_SYND_FLAG    OKL_AE_TEMPLATES.FACTORING_SYND_FLAG%TYPE := OKL_API.G_MISS_CHAR,
   SYNDICATION_CODE       OKL_AE_TEMPLATES.SYT_CODE%TYPE := OKL_API.G_MISS_CHAR,
   FACTORING_CODE         OKL_AE_TEMPLATES.FAC_CODE%TYPE := OKL_API.G_MISS_CHAR,

-- Santonyr. Added to implement Securitization Chnages
   INVESTOR_CODE         OKL_AE_TEMPLATES.INV_CODE%TYPE := OKL_API.G_MISS_CHAR,
   MEMO_YN                OKL_AE_TEMPLATES.MEMO_YN%TYPE := OKL_API.G_MISS_CHAR,
   PRIOR_YEAR_YN          OKL_AE_TEMPLATES.PRIOR_YEAR_YN%TYPE := OKL_API.G_MISS_CHAR,

-- 15-Oct-04 santonyr -- Added a new flag to template identification record
-- for revenue recognition program  Bug 3948354.
   REV_REC_FLAG 		  VARCHAR2(1) := 'N'

   );

TYPE DIST_INFO_REC_TYPE IS RECORD
  (SOURCE_ID                NUMBER                                 := OKL_API.G_MISS_NUM,
   SOURCE_TABLE             OKL_TRNS_ACC_DSTRS.SOURCE_TABLE%TYPE := OKL_API.G_MISS_CHAR,
   ACCOUNTING_DATE          OKL_TRNS_ACC_DSTRS.GL_DATE%TYPE      := OKL_API.G_MISS_DATE,
   GL_REVERSAL_FLAG         OKL_TRNS_ACC_DSTRS.GL_REVERSAL_FLAG%TYPE  := OKL_API.G_MISS_CHAR,
   POST_TO_GL               OKL_TRNS_ACC_DSTRS.POST_TO_GL%TYPE   := OKL_API.G_MISS_CHAR,
   AMOUNT                   NUMBER       := OKL_API.G_MISS_NUM,
   CURRENCY_CODE            OKL_TRNS_ACC_DSTRS.CURRENCY_CODE%TYPE := OKL_API.G_MISS_CHAR,
   CURRENCY_CONVERSION_TYPE OKL_TRNS_ACC_DSTRS.CURRENCY_CONVERSION_TYPE%TYPE
                            := OKL_API.G_MISS_CHAR,
   CURRENCY_CONVERSION_DATE OKL_TRNS_ACC_DSTRS.CURRENCY_CONVERSION_DATE%TYPE
                            := OKL_API.G_MISS_DATE,

   -- Santonyr Added on 18-Nov-2002
   -- Multi Currency Changes

   CURRENCY_CONVERSION_RATE NUMBER := OKL_API.G_MISS_NUM,

   CONTRACT_ID              NUMBER       := OKL_API.G_MISS_NUM,
   CONTRACT_LINE_ID         NUMBER       := OKL_API.G_MISS_NUM);

TYPE AMOUNT_TBL_TYPE  IS TABLE OF NUMBER INDEX BY BINARY_INTEGER;

--Added by gboomina for Accruals Performance
   --Bug 4662173 - Start of Changes
   TYPE DIST_INFO_TBL_TYPE IS TABLE OF DIST_INFO_REC_TYPE INDEX BY BINARY_INTEGER;

   TYPE avlb_rec_type IS RECORD (
       id                             NUMBER := OKC_API.G_MISS_NUM,
       object_version_number          NUMBER := OKC_API.G_MISS_NUM,
       try_id                         NUMBER := OKC_API.G_MISS_NUM,
       aes_id                         NUMBER := OKC_API.G_MISS_NUM,
       sty_id                         NUMBER := OKC_API.G_MISS_NUM,
       fma_id                         NUMBER := OKC_API.G_MISS_NUM,
       set_of_books_id                NUMBER := OKC_API.G_MISS_NUM,
       fac_code                       OKL_AE_TEMPLATES.FAC_CODE%TYPE := OKC_API.G_MISS_CHAR,
       syt_code                       OKL_AE_TEMPLATES.SYT_CODE%TYPE := OKC_API.G_MISS_CHAR,
       post_to_gl                     OKL_AE_TEMPLATES.POST_TO_GL%TYPE := OKC_API.G_MISS_CHAR,
       advance_arrears                OKL_AE_TEMPLATES.ADVANCE_ARREARS%TYPE := OKC_API.G_MISS_CHAR,
       memo_yn                        OKL_AE_TEMPLATES.MEMO_YN%TYPE := OKC_API.G_MISS_CHAR,
       prior_year_yn                  OKL_AE_TEMPLATES.PRIOR_YEAR_YN%TYPE := OKC_API.G_MISS_CHAR,
       name                           OKL_AE_TEMPLATES.NAME%TYPE := OKC_API.G_MISS_CHAR,
       description                    OKL_AE_TEMPLATES.DESCRIPTION%TYPE := OKC_API.G_MISS_CHAR,
       version                        OKL_AE_TEMPLATES.VERSION%TYPE := OKC_API.G_MISS_CHAR,
       factoring_synd_flag            OKL_AE_TEMPLATES.FACTORING_SYND_FLAG%TYPE := OKC_API.G_MISS_CHAR,
       start_date                     OKL_AE_TEMPLATES.START_DATE%TYPE := OKC_API.G_MISS_DATE,
       end_date                       OKL_AE_TEMPLATES.END_DATE%TYPE := OKC_API.G_MISS_DATE,
       accrual_yn                     OKL_AE_TEMPLATES.ACCRUAL_YN%TYPE := OKC_API.G_MISS_CHAR,
       attribute_category             OKL_AE_TEMPLATES.ATTRIBUTE_CATEGORY%TYPE := OKC_API.G_MISS_CHAR,
       attribute1                     OKL_AE_TEMPLATES.ATTRIBUTE1%TYPE := OKC_API.G_MISS_CHAR,
       attribute2                     OKL_AE_TEMPLATES.ATTRIBUTE2%TYPE := OKC_API.G_MISS_CHAR,
       attribute3                     OKL_AE_TEMPLATES.ATTRIBUTE3%TYPE := OKC_API.G_MISS_CHAR,
       attribute4                     OKL_AE_TEMPLATES.ATTRIBUTE4%TYPE := OKC_API.G_MISS_CHAR,
       attribute5                     OKL_AE_TEMPLATES.ATTRIBUTE5%TYPE := OKC_API.G_MISS_CHAR,
       attribute6                     OKL_AE_TEMPLATES.ATTRIBUTE6%TYPE := OKC_API.G_MISS_CHAR,
       attribute7                     OKL_AE_TEMPLATES.ATTRIBUTE7%TYPE := OKC_API.G_MISS_CHAR,
       attribute8                     OKL_AE_TEMPLATES.ATTRIBUTE8%TYPE := OKC_API.G_MISS_CHAR,
       attribute9                     OKL_AE_TEMPLATES.ATTRIBUTE9%TYPE := OKC_API.G_MISS_CHAR,
       attribute10                    OKL_AE_TEMPLATES.ATTRIBUTE10%TYPE := OKC_API.G_MISS_CHAR,
       attribute11                    OKL_AE_TEMPLATES.ATTRIBUTE11%TYPE := OKC_API.G_MISS_CHAR,
       attribute12                    OKL_AE_TEMPLATES.ATTRIBUTE12%TYPE := OKC_API.G_MISS_CHAR,
       attribute13                    OKL_AE_TEMPLATES.ATTRIBUTE13%TYPE := OKC_API.G_MISS_CHAR,
       attribute14                    OKL_AE_TEMPLATES.ATTRIBUTE14%TYPE := OKC_API.G_MISS_CHAR,
       attribute15                    OKL_AE_TEMPLATES.ATTRIBUTE15%TYPE := OKC_API.G_MISS_CHAR,
       org_id                         NUMBER := OKC_API.G_MISS_NUM,
       created_by                     NUMBER := OKC_API.G_MISS_NUM,
       creation_date                  OKL_AE_TEMPLATES.CREATION_DATE%TYPE := OKC_API.G_MISS_DATE,
       last_updated_by                NUMBER := OKC_API.G_MISS_NUM,
       last_update_date               OKL_AE_TEMPLATES.LAST_UPDATE_DATE%TYPE := OKC_API.G_MISS_DATE,
       last_update_login              NUMBER := OKC_API.G_MISS_NUM,

        -- Added by HKPATEL for securitization changes
       inv_code                               OKL_AE_TEMPLATES.INV_CODE%TYPE := OKC_API.G_MISS_CHAR,
           parent_index_number            NUMBER := OKC_API.G_MISS_NUM);

     g_miss_avlv_rec                         avlv_rec_type;

     TYPE avlb_tbl_type IS TABLE OF avlb_rec_type
           INDEX BY BINARY_INTEGER;

     TYPE amt_rec_type IS RECORD(
        amount                        NUMBER := OKC_API.G_MISS_NUM,
            parent_index_number           NUMBER := OKC_API.G_MISS_NUM);

     TYPE amt_tbl_type IS TABLE OF amt_rec_type
           INDEX BY BINARY_INTEGER;

     -- Table type which holds the account generator source  related information
     TYPE acc_gen_rec IS RECORD
        (source_table              okl_ag_source_maps.source%TYPE,
         primary_key_column        VARCHAR2(100),
         source_id  NUMBER
        );

     TYPE acc_gen_tbl IS TABLE OF acc_gen_rec INDEX BY BINARY_INTEGER;
     --Bug 4662173 - End of Changes

     --Added by kthiruva on 12-Feb-2007 for SLA Uptake
     --Bug 5707866 - Start of Changes
     TYPE tmpl_identify_tbl_type IS TABLE OF tmpl_identify_rec_type INDEX BY BINARY_INTEGER;

     --Record and table type to store the ctxt_val_Tbl per transaction line_id
     TYPE ctxt_rec_type IS RECORD(ctxt_val_tbl  ctxt_val_tbl_type
                                 ,source_id     NUMBER );

     TYPE ctxt_tbl_type IS TABLE OF ctxt_rec_type INDEX BY BINARY_INTEGER;

     --Record and table type to store the account generator table info per transaction line
     TYPE acc_gen_rec_type IS RECORD(acc_gen_key_tbl  acc_gen_primary_key
                                    ,source_id  NUMBER);

     TYPE acc_gen_tbl_type IS TABLE OF acc_gen_rec_type INDEX BY BINARY_INTEGER;

     --Record and table type to store the template info per transaction line
     TYPE avlv_out_rec_type IS RECORD(template_tbl AVLV_TBL_TYPE,
                                      source_id  NUMBER);

     TYPE avlv_out_tbl_type IS TABLE OF avlv_out_rec_type INDEX BY BINARY_INTEGER;

     --Record and table type to store the distribution amoounts per transaction line
     TYPE amount_out_rec_type IS RECORD(amount_tbl AMOUNT_TBL_TYPE,
                                        source_id  NUMBER);

     TYPE amount_out_tbl_type IS TABLE OF amount_out_rec_type INDEX BY BINARY_INTEGER;

     TYPE tclv_rec_type IS RECORD(source_id NUMBER,
                                  source_table VARCHAR2(30));

     TYPE tclv_tbl_type IS TABLE OF tclv_rec_type INDEX BY BINARY_INTEGER;
     --Bug 5707866 - End of Changes


PROCEDURE  CREATE_ACCOUNTING_DIST(p_api_version             IN       NUMBER,
                                  p_init_msg_list           IN       VARCHAR2,
                                  x_return_status           OUT      NOCOPY VARCHAR2,
                                  x_msg_count               OUT      NOCOPY NUMBER,
                                  x_msg_data                OUT      NOCOPY VARCHAR2,
                                  p_tmpl_identify_rec       IN       TMPL_IDENTIFY_REC_TYPE,
                                  p_dist_info_rec           IN       DIST_INFO_REC_TYPE,
                                  p_ctxt_val_tbl            IN       CTXT_VAL_TBL_TYPE,
                                  p_acc_gen_primary_key_tbl IN       acc_gen_primary_key,
                                  x_template_tbl            OUT      NOCOPY AVLV_TBL_TYPE,
                                  x_amount_tbl              OUT      NOCOPY AMOUNT_TBL_TYPE);

PROCEDURE  CREATE_ACCOUNTING_DIST(p_api_version             IN       NUMBER,
                                  p_init_msg_list           IN       VARCHAR2,
                                  x_return_status           OUT      NOCOPY VARCHAR2,
                                  x_msg_count               OUT      NOCOPY NUMBER,
                                  x_msg_data                OUT      NOCOPY VARCHAR2,
                                  p_tmpl_identify_rec       IN       TMPL_IDENTIFY_REC_TYPE,
                                  p_dist_info_rec           IN       DIST_INFO_REC_TYPE,
                                  p_ctxt_val_tbl            IN       CTXT_VAL_TBL_TYPE,
                                  p_acc_gen_primary_key_tbl IN       acc_gen_primary_key,
                                  x_template_tbl            OUT      NOCOPY AVLV_TBL_TYPE,
                                  x_amount_tbl              OUT      NOCOPY AMOUNT_TBL_TYPE,
                                  x_gl_date                 OUT      NOCOPY DATE);

--Added by gboomina on 14-Oct-2005 for improving Accruals Performance
   --Bug 4662173 - Start of Changes
   PROCEDURE  CREATE_ACCOUNTING_DIST(p_api_version             IN       NUMBER,
                                     p_init_msg_list           IN       VARCHAR2,
                                     x_return_status           OUT      NOCOPY VARCHAR2,
                                     x_msg_count               OUT      NOCOPY NUMBER,
                                     x_msg_data                OUT      NOCOPY VARCHAR2,
                                     p_tmpl_identify_rec       IN       TMPL_IDENTIFY_REC_TYPE,
                                     p_dist_info_tbl           IN       DIST_INFO_TBL_TYPE,
                                     p_ctxt_val_tbl            IN       CTXT_VAL_TBL_TYPE,
                                     p_acc_gen_primary_key_tbl IN       acc_gen_tbl,
                                     x_template_tbl            OUT      NOCOPY AVLB_TBL_TYPE,
                                     x_amount_tbl              OUT      NOCOPY AMT_TBL_TYPE);
   --Bug 4662173 - End of Changes

  --Added by kthiruva on 14-Feb-2007 for SLA Uptake
  --Bug 5707866 - Start of Changes
  --New Accounting Engine signature which accepts a table of distributions and template_identify_rec
  --This call is made once for a transaction header
  PROCEDURE CREATE_ACCOUNTING_DIST (p_api_version                     IN      NUMBER,
                                     p_init_msg_list                   IN      VARCHAR2,
                                     x_return_status                   OUT  NOCOPY VARCHAR2,
                                     x_msg_count                       OUT  NOCOPY NUMBER,
                                     x_msg_data                        OUT  NOCOPY VARCHAR2,
                                     p_tmpl_identify_tbl               IN   TMPL_IDENTIFY_TBL_TYPE,
                                     p_dist_info_tbl                   IN   DIST_INFO_TBL_TYPE,
                                     p_ctxt_val_tbl                    IN   CTXT_TBL_TYPE,
                                     p_acc_gen_primary_key_tbl         IN   ACC_GEN_TBL_TYPE,
                                     x_template_tbl                    OUT  NOCOPY AVLV_OUT_TBL_TYPE,
                                     x_amount_tbl                      OUT  NOCOPY AMOUNT_OUT_TBL_TYPE,
                                     p_trx_header_id                   IN   NUMBER,
                                     p_trx_header_table                  IN  VARCHAR2 DEFAULT NULL);
  --Bug 5707866 - End of Changes


PROCEDURE  GET_TEMPLATE_INFO(p_api_version        IN      NUMBER,
                             p_init_msg_list      IN      VARCHAR2,
                             x_return_status      OUT     NOCOPY VARCHAR2,
                             x_msg_count          OUT     NOCOPY NUMBER,
                             x_msg_data           OUT     NOCOPY VARCHAR2,
                             p_tmpl_identify_rec  IN      TMPL_IDENTIFY_REC_TYPE,
                             x_template_tbl       OUT     NOCOPY AVLV_TBL_TYPE,
                             p_validity_date      IN      DATE DEFAULT SYSDATE);


PROCEDURE  UPDATE_POST_TO_GL(p_api_version          IN         NUMBER,
                             p_init_msg_list        IN         VARCHAR2,
                             x_return_status        OUT        NOCOPY VARCHAR2,
                             x_msg_count            OUT        NOCOPY NUMBER,
                             x_msg_data             OUT        NOCOPY VARCHAR2,
                             p_source_id            IN         NUMBER,
     	    	             p_source_table         IN         VARCHAR2);


PROCEDURE  DELETE_ACCT_ENTRIES(p_api_version                IN         NUMBER,
                               p_init_msg_list              IN         VARCHAR2,
                               x_return_status              OUT        NOCOPY VARCHAR2,
                               x_msg_count                  OUT        NOCOPY NUMBER,
                               x_msg_data                   OUT        NOCOPY VARCHAR2,
                               p_source_id                  IN         NUMBER,
                               p_source_table               IN         VARCHAR2);


PROCEDURE  REVERSE_ENTRIES(p_api_version                IN         NUMBER,
                           p_init_msg_list              IN         VARCHAR2,
                           x_return_status              OUT        NOCOPY VARCHAR2,
                           x_msg_count                  OUT        NOCOPY NUMBER,
                           x_msg_data                   OUT        NOCOPY VARCHAR2,
                           p_source_id                  IN         NUMBER,
                           p_source_table               IN         VARCHAR2,
                           p_acct_date                  IN         DATE);


G_PKG_NAME CONSTANT VARCHAR2(200)     := 'OKL_ACCOUNT_DIST_PVT' ;
G_APP_NAME CONSTANT VARCHAR2(3)       :=  OKL_API.G_APP_NAME;
g_sysdate DATE := TRUNC(SYSDATE);
G_gl_date DATE;



G_REQUIRED_VALUE                 CONSTANT VARCHAR2(200) := OKL_API.G_REQUIRED_VALUE;
G_INVALID_VALUE                  CONSTANT VARCHAR2(200) := OKL_API.G_INVALID_VALUE;
G_SQLERRM_TOKEN                  CONSTANT VARCHAR2(200) := 'OKL_SQLerrm';
G_SQLCODE_TOKEN                  CONSTANT VARCHAR2(200) := 'OKL_SQLcode';
G_COL_NAME_TOKEN                 CONSTANT VARCHAR2(200) :=  OKL_API.G_COL_NAME_TOKEN;
G_UNEXPECTED_ERROR               CONSTANT VARCHAR2(200) := 'OKL_CONTRACTS_UNEXPECTED_ERROR';


-- Added by Santonyr on 26-Jul-2004 for the bug 3772490

TYPE  template_amount_rec_type IS RECORD
  (TEMPLATE_ID             NUMBER    := Okl_Api.G_MISS_NUM,
   AMOUNT                  NUMBER    := Okl_Api.G_MISS_NUM,
   FORMULA_USED         VARCHAR2(3)   := Okl_Api.G_MISS_CHAR,
   STREAM_TYPE_ID       NUMBER    := Okl_Api.G_MISS_NUM);

TYPE template_amount_tbl_type IS TABLE OF template_amount_rec_type INDEX BY BINARY_INTEGER;

--Added by gboomina on 14-Oct-2005 for improving Accruals Performance
   --Bug 4662173 - Start of Changes
   TYPE  tmp_bulk_amount_rec_type IS RECORD
     (TEMPLATE_ID             NUMBER    := Okl_Api.G_MISS_NUM,
      AMOUNT                  NUMBER    := Okl_Api.G_MISS_NUM,
      FORMULA_USED         VARCHAR2(3)   := Okl_Api.G_MISS_CHAR,
      STREAM_TYPE_ID       NUMBER    := Okl_Api.G_MISS_NUM,
      PARENT_INDEX_NUMBER     NUMBER    := Okl_Api.G_MISS_NUM);

   TYPE tmp_bulk_amount_tbl_type IS TABLE OF tmp_bulk_amount_rec_type INDEX BY BINARY_INTEGER;
   --Bug 4662173 - End of Changes


PROCEDURE  POPULATE_ACCT_SOURCES(p_api_version              IN       NUMBER,
                                 p_init_msg_list           IN       VARCHAR2,
                                 x_return_status           OUT      NOCOPY VARCHAR2,
                                 x_msg_count               OUT      NOCOPY NUMBER,
                                 x_msg_data                OUT      NOCOPY VARCHAR2,
                                 p_tmpl_identify_rec       IN       TMPL_IDENTIFY_REC_TYPE,
                                 p_dist_info_rec           IN       DIST_INFO_REC_TYPE,
                                 p_acc_gen_primary_key_tbl IN       acc_gen_primary_key,
                                 p_template_amount_tbl     IN       template_amount_tbl_type);


 --Added by  gboomina for Accruals Performance Improvement
 --Bug 4662173 - Start of Changes
PROCEDURE  POPULATE_ACCT_SOURCES(p_api_version              IN       NUMBER,
                                 p_init_msg_list           IN       VARCHAR2,
                                 x_return_status           OUT      NOCOPY VARCHAR2,
                                 x_msg_count               OUT      NOCOPY NUMBER,
                                 x_msg_data                OUT      NOCOPY VARCHAR2,
                                 p_tmpl_identify_rec       IN       TMPL_IDENTIFY_REC_TYPE,
                                 p_dist_info_tbl           IN       DIST_INFO_TBL_TYPE,
                                 p_acc_gen_primary_key_tbl IN       acc_gen_tbl,
                                 p_template_amount_tbl     IN       tmp_bulk_amount_tbl_type);
  --Bug 4662173 - End of Changes

     -- MG uptake
     TYPE ledger_rec_type IS RECORD
        (ledger_id         gl_ledgers.ledger_id%TYPE,
         rep_code          gl_ledgers.short_name%TYPE,
         rep_type          VARCHAR2(20)
        );
	 TYPE ledger_tbl_type IS TABLE OF ledger_rec_type INDEX BY PLS_INTEGER;

	 g_representation_type     VARCHAR2(20);
	 g_ledger_id               NUMBER;

END OKL_ACCOUNT_DIST_PVT;

/
