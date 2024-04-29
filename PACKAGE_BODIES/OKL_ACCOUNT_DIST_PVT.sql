--------------------------------------------------------
--  DDL for Package Body OKL_ACCOUNT_DIST_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OKL_ACCOUNT_DIST_PVT" AS
/* $Header: OKLRTDTB.pls 120.32.12010000.7 2009/06/01 17:29:55 racheruv ship $ */

    G_MODULE VARCHAR2(255) := 'okl.stream.esg.okl_esg_transport_pvt';
    G_DEBUG_ENABLED CONSTANT VARCHAR2(10) := OKL_DEBUG_PUB.CHECK_LOG_ENABLED;
    G_IS_DEBUG_STATEMENT_ON BOOLEAN;
-- Start of wraper code generated automatically by Debug code generator
  L_MODULE VARCHAR2(40) := 'LEASE.ACCOUNTING.ENGINE';
  L_DEBUG_ENABLED CONSTANT VARCHAR2(10) := OKL_DEBUG_PUB.CHECK_LOG_ENABLED;
  L_LEVEL_PROCEDURE NUMBER;
  IS_DEBUG_PROCEDURE_ON BOOLEAN;
-- End of wraper code generated automatically by Debug code generator

  -- Gloabl variable to identify if the program is called from
  -- Recevue Recognition Bug 3948354

  G_REV_REC_FLAG   VARCHAR2(1);
  TYPE ID_TBL_TYPE IS TABLE OF NUMBER INDEX BY BINARY_INTEGER;

  --Cursor to get the Account Derivation Option
  CURSOR get_acct_derivation_csr
  IS
  SELECT ACCOUNT_DERIVATION
  FROM okl_sys_acct_opts;

  -- new table to cache the representation attributes.
  -- Added by racheruv for MG uptake
  g_ledger_tbl    ledger_tbl_type;


-- Added by racheruv for MG uptake. Procedure gets the representation
-- and ledger details for OUs with sec rep method of 'Automated'. bug 8210595
PROCEDURE get_rep_attributes IS
  CURSOR get_ledger_attrs
  IS
   select o.set_of_books_id ledger_id,
          g.short_name rep_code,
          'PRIMARY' rep_type
     FROM okl_sys_acct_opts o,
          gl_ledgers g
    WHERE o.set_of_books_id = g.ledger_id
    UNION ALL
   select f.set_of_books_id ledger_id,
          g.short_name rep_code,
          'SECONDARY' rep_type
     FROM okl_sys_acct_opts o,
          okl_system_params_all s,
          fa_book_controls f,
          gl_ledgers g
    WHERE o.org_id = s.org_id
      AND s.RPT_PROD_BOOK_TYPE_CODE = f.book_type_code
      AND f.set_of_books_id = g.ledger_id
      AND o.secondary_rep_method = 'AUTOMATED';

  ledger_rec      get_ledger_attrs%ROWTYPE;

BEGIN
  -- get the ledger attributes
    OPEN get_ledger_attrs;
    LOOP
      FETCH get_ledger_attrs INTO ledger_rec;
      EXIT WHEN get_ledger_attrs%NOTFOUND;
        g_ledger_tbl(ledger_rec.ledger_id).ledger_id := ledger_rec.ledger_id;
        g_ledger_tbl(ledger_rec.ledger_id).rep_code := ledger_rec.rep_code;
        g_ledger_tbl(ledger_rec.ledger_id).rep_type := ledger_rec.rep_type;
    END LOOP;

	close get_ledger_attrs;

END  get_rep_attributes;

-- Added by kthiruva on 25-May-2007 for bug 5707866 - SLA Uptake
-- The foreign key references available in the AE that are required by
-- the okl_sla_acct_sources api for populating sources are passed through
PROCEDURE  POPULATE_ACCT_SOURCES(p_api_version              IN       NUMBER,
                                p_init_msg_list           IN       VARCHAR2,
                                x_return_status           OUT      NOCOPY VARCHAR2,
                                x_msg_count               OUT      NOCOPY NUMBER,
                                x_msg_data                OUT      NOCOPY VARCHAR2,
                                p_tmpl_identify_rec       IN       TMPL_IDENTIFY_REC_TYPE,
                                p_dist_info_rec           IN       DIST_INFO_REC_TYPE,
                                p_acc_gen_primary_key_tbl IN       acc_gen_primary_key,
x_asev_rec                OUT      NOCOPY asev_rec_type)
IS

  l_return_status  VARCHAR2(1) := Okl_Api.G_RET_STS_SUCCESS;
  l_api_name       VARCHAR2(30) := 'POPULATE_ACCT_SOURCES';
  l_api_version    NUMBER := 1.0;

  l_init_msg_list         VARCHAR2(1) := Okl_Api.G_FALSE;
  l_msg_count             NUMBER := 0;
  l_msg_data              VARCHAR2(2000);


  l_pay_vendor_sites_pk         VARCHAR2(50);
  l_rec_site_uses_pk            VARCHAR2(50);
  l_asset_category_id_pk1       VARCHAR2(50);
  l_asset_book_pk2              VARCHAR2(50);
  l_pay_financial_options_pk    VARCHAR2(50);
  l_jtf_sales_reps_pk           VARCHAR2(50);
  l_inventory_item_id_pk1       VARCHAR2(50);
  l_inventory_org_id_pk2        VARCHAR2(50);
  l_rec_trx_types_pk            VARCHAR2(50);
  l_factor_investor_code        VARCHAR2(30);

  l_asev_rec  asev_rec_type;

BEGIN

   x_return_status := Okl_Api.G_RET_STS_SUCCESS;

   l_return_status := Okl_Api.START_ACTIVITY(l_api_name,
                                             G_PKG_NAME,
                                             p_init_msg_list,
                                             l_api_version,
                                             p_api_version,
                                             '_PVT',
                                             x_return_status);
   IF (l_return_status = Okl_Api.G_RET_STS_UNEXP_ERROR) THEN
     RAISE Okl_Api.G_EXCEPTION_UNEXPECTED_ERROR;
   ELSIF (l_return_status = Okl_Api.G_RET_STS_ERROR) THEN
     RAISE Okl_Api.G_EXCEPTION_ERROR;
   END IF;

   -- Extract the account generator sources from account generator primary key table.
   IF p_acc_gen_primary_key_tbl.COUNT > 0 THEN

     FOR j IN p_acc_gen_primary_key_tbl.FIRST..p_acc_gen_primary_key_tbl.LAST LOOP

          IF p_acc_gen_primary_key_tbl(j).source_table = 'AP_VENDOR_SITES_V' THEN
             l_pay_vendor_sites_pk      := TRIM(p_acc_gen_primary_key_tbl(j).primary_key_column);

          ELSIF p_acc_gen_primary_key_tbl(j).source_table = 'AR_SITE_USES_V' THEN
              l_rec_site_uses_pk := TRIM(p_acc_gen_primary_key_tbl(j).primary_key_column);

          ELSIF p_acc_gen_primary_key_tbl(j).source_table = 'FA_CATEGORY_BOOKS' THEN
              l_asset_category_id_pk1 := TRIM(SUBSTR(p_acc_gen_primary_key_tbl(j).primary_key_column,1, 50));
              l_asset_book_pk2 := TRIM(SUBSTR(p_acc_gen_primary_key_tbl(j).primary_key_column,51, 100));

          ELSIF p_acc_gen_primary_key_tbl(j).source_table = 'FINANCIALS_SYSTEM_PARAMETERS' THEN
              l_pay_financial_options_pk := TRIM(p_acc_gen_primary_key_tbl(j).primary_key_column);

          ELSIF p_acc_gen_primary_key_tbl(j).source_table = 'JTF_RS_SALESREPS_MO_V' THEN
              l_jtf_sales_reps_pk := TRIM(p_acc_gen_primary_key_tbl(j).primary_key_column);

          ELSIF p_acc_gen_primary_key_tbl(j).source_table = 'MTL_SYSTEM_ITEMS_VL' THEN
              l_inventory_item_id_pk1 := TRIM(SUBSTR(p_acc_gen_primary_key_tbl(j).primary_key_column,1, 50));
              l_inventory_org_id_pk2 := TRIM(SUBSTR(p_acc_gen_primary_key_tbl(j).primary_key_column,51, 100));

          ELSIF p_acc_gen_primary_key_tbl(j).source_table = 'RA_CUST_TRX_TYPES' THEN
              l_rec_trx_types_pk := TRIM(p_acc_gen_primary_key_tbl(j).primary_key_column);
          END IF;

      END LOOP;
   END IF;

   -- Get the syndication /Investor Code
   IF p_tmpl_identify_rec.factoring_synd_flag = 'SYNDICATION' THEN
      l_factor_investor_code := p_tmpl_identify_rec.syndication_code;
   ELSIF p_tmpl_identify_rec.factoring_synd_flag = 'FACTORING' THEN
      l_factor_investor_code := p_tmpl_identify_rec.factoring_code;
   ELSIF p_tmpl_identify_rec.factoring_synd_flag = 'INVESTOR' THEN
      l_factor_investor_code := p_tmpl_identify_rec.investor_code;
   END IF;

   --Populating the l_asev_rec
   l_asev_rec.source_table      :=  p_dist_info_rec.source_table; --source_table,
   l_asev_rec.source_id         :=  p_dist_info_rec.source_id; --source_id,
   l_asev_rec.pdt_id            :=  p_tmpl_identify_rec.product_id; --product_id,
   l_asev_rec.try_id            :=  p_tmpl_identify_rec.transaction_type_id; --trx_type_id,
   l_asev_rec.memo_yn           :=  NVL(p_tmpl_identify_rec.memo_yn, 'N'); --memo_yn,
   l_asev_rec.factor_investor_flag :=  p_tmpl_identify_rec.factoring_synd_flag; --factor_investor_flag,
   l_asev_rec.factor_investor_code :=  l_factor_investor_code; --factor_investor_code,
   l_asev_rec.pay_vendor_sites_pk       :=  l_pay_vendor_sites_pk; --pay_vendor_sites_pk,
   l_asev_rec.rec_site_uses_pk          :=  l_rec_site_uses_pk; --rec_site_uses_pk,
   l_asev_rec.asset_category_id_pk1     :=  l_asset_category_id_pk1; --asset_categories_pk1,
   l_asev_rec.asset_book_pk2            :=  l_asset_book_pk2; --asset_categories_pk2,
   l_asev_rec.pay_financial_options_pk  :=  l_pay_financial_options_pk; --pay_financial_options_pk,
   l_asev_rec.jtf_sales_reps_pk         :=  l_jtf_sales_reps_pk; --jtf_sales_reps_pk,
   l_asev_rec.inventory_item_id_pk1     :=  l_inventory_item_id_pk1; --inventory_items_pk1,
   l_asev_rec.inventory_org_id_pk2      :=  l_inventory_org_id_pk2; --inventory_items_pk2,
   l_asev_rec.rec_trx_types_pk          :=  l_rec_trx_types_pk; --rec_trx_types_pk,


   x_asev_rec := l_asev_rec;
   Okl_Api.END_ACTIVITY(x_msg_count, x_msg_data);

   x_return_status := Okl_Api.G_RET_STS_SUCCESS;

EXCEPTION

    WHEN Okl_Api.G_EXCEPTION_ERROR THEN
      x_return_status := OKL_API.HANDLE_EXCEPTIONS
      ( l_api_name,
        G_PKG_NAME,
        'OKL_API.G_RET_STS_ERROR',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
    WHEN Okl_Api.G_EXCEPTION_UNEXPECTED_ERROR THEN
      x_return_status := OKL_API.HANDLE_EXCEPTIONS
      ( l_api_name,
        G_PKG_NAME,
        'OKL_API.G_RET_STS_UNEXP_ERROR',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
    WHEN OTHERS THEN
      x_return_status := OKL_API.HANDLE_EXCEPTIONS
      ( l_api_name,
        G_PKG_NAME,
        'OTHERS',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );


END POPULATE_ACCT_SOURCES;


-- Added by Santonyr
-- Added this procedure to execute a query dynamically and populate the
-- template table. This returns the template table with the resulted rows.

PROCEDURE  Execute_Tmpl_Query
(p_stmt           IN      VARCHAR2,
    x_return_status      OUT     NOCOPY VARCHAR2,
       x_template_tbl       OUT     NOCOPY AVLV_TBL_TYPE)
IS

  TYPE ref_cursor IS REF CURSOR;
  tmpl_csr ref_cursor;

  tmpl_rec AVLV_REC_TYPE;
  i NUMBER := 0;

BEGIN

  x_return_status := OKL_API.G_RET_STS_SUCCESS;

  OPEN tmpl_csr FOR p_stmt;
  LOOP
     FETCH tmpl_csr INTO
              tmpl_rec.ID
             ,tmpl_rec.NAME
             ,tmpl_rec.SET_OF_BOOKS_ID
             ,tmpl_rec.STY_ID
             ,tmpl_rec.TRY_ID
             ,tmpl_rec.AES_ID
        ,tmpl_rec.SYT_CODE
             ,tmpl_rec.FAC_CODE
             ,tmpl_rec.FMA_ID
             ,tmpl_rec.ADVANCE_ARREARS
             ,tmpl_rec.POST_TO_GL
             ,tmpl_rec.VERSION
             ,tmpl_rec.START_DATE
             ,tmpl_rec.OBJECT_VERSION_NUMBER
             ,tmpl_rec.MEMO_YN
             ,tmpl_rec.PRIOR_YEAR_YN
             ,tmpl_rec.DESCRIPTION
             ,tmpl_rec.FACTORING_SYND_FLAG
             ,tmpl_rec.END_DATE
             ,tmpl_rec.ACCRUAL_YN
             ,tmpl_rec.ORG_ID
             ,tmpl_rec.ATTRIBUTE_CATEGORY
             ,tmpl_rec.ATTRIBUTE1
             ,tmpl_rec.ATTRIBUTE2
             ,tmpl_rec.ATTRIBUTE3
             ,tmpl_rec.ATTRIBUTE4
             ,tmpl_rec.ATTRIBUTE5
             ,tmpl_rec.ATTRIBUTE6
             ,tmpl_rec.ATTRIBUTE7
             ,tmpl_rec.ATTRIBUTE8
             ,tmpl_rec.ATTRIBUTE9
             ,tmpl_rec.ATTRIBUTE10
             ,tmpl_rec.ATTRIBUTE11
             ,tmpl_rec.ATTRIBUTE12
             ,tmpl_rec.ATTRIBUTE13
             ,tmpl_rec.ATTRIBUTE14
             ,tmpl_rec.ATTRIBUTE15
             ,tmpl_rec.CREATED_BY
             ,tmpl_rec.CREATION_DATE
             ,tmpl_rec.LAST_UPDATED_BY
             ,tmpl_rec.LAST_UPDATE_DATE
             ,tmpl_rec.LAST_UPDATE_LOGIN
             ,tmpl_rec.INV_CODE;

     EXIT WHEN tmpl_csr%NOTFOUND;
     i := i + 1;
     x_template_tbl(i)  := tmpl_rec;
  END LOOP;
CLOSE tmpl_csr;


EXCEPTION
  WHEN OTHERS THEN

    IF tmpl_csr%ISOPEN THEN
      CLOSE tmpl_csr;
    END IF;
    x_return_status := OKL_API.G_RET_STS_UNEXP_ERROR;
    OKL_API.SET_MESSAGE(p_app_name      => g_app_name
                         ,p_msg_name      => g_unexpected_error
                         ,p_token1        => g_sqlcode_token
                         ,p_token1_value  => SQLCODE
                         ,p_token2        => g_sqlerrm_token
                         ,p_token2_value  => SQLERRM);

END execute_tmpl_query;


--- This procedure is used for getting templates based on the input parameters
----p_validity_date is the date for which template is queried. The templates
--- satisfying the query criterias and valid on the p_validity_date will only be selected

PROCEDURE  GET_TEMPLATE_INFO(p_api_version        IN      NUMBER,
                             p_init_msg_list      IN      VARCHAR2,
                             x_return_status      OUT     NOCOPY VARCHAR2,
                             x_msg_count          OUT     NOCOPY NUMBER,
                             x_msg_data           OUT     NOCOPY VARCHAR2,
                             p_tmpl_identify_rec  IN      TMPL_IDENTIFY_REC_TYPE,
                             x_template_tbl       OUT     NOCOPY AVLV_TBL_TYPE,
                             p_validity_date      IN      DATE DEFAULT SYSDATE)

IS


  l_stmt   VARCHAR2(5000);
  l_stmt_exe   VARCHAR2(5000);
  l_where  VARCHAR2(2000) := ' ';
  l_where_memo_yn VARCHAR2(1000) :=' ';
  l_where_flag_code    VARCHAR2(1000) := ' ';
  l_where_flag   VARCHAR2(1000) := ' ';
  l_where_no_flag VARCHAR2(1000) := ' ';
  l_where_exe   VARCHAR2(4000) := ' ';
  l_inner_query VARCHAR2(2000);
  l_aes_id NUMBER;

  i  NUMBER := 0;

  l_product_id          NUMBER := P_TMPL_IDENTIFY_REC.PRODUCT_ID;
  l_transaction_type_id NUMBER := P_TMPL_IDENTIFY_REC.TRANSACTION_TYPE_ID;
  l_stream_type_id      NUMBER := P_TMPL_IDENTIFY_REC.STREAM_TYPE_ID;
  l_advance_arrears     OKL_AE_TEMPLATES.ADVANCE_ARREARS%TYPE
                             := P_TMPL_IDENTIFY_REC.advance_arrears;
  l_factoring_synd_flag OKL_AE_TEMPLATES.FACTORING_SYND_FLAG%TYPE
                             := P_TMPL_IDENTIFY_REC.FACTORING_SYND_FLAG;
  l_syndication_code   OKL_AE_TEMPLATES.SYT_CODE%TYPE
                             := P_TMPL_IDENTIFY_REC.SYNDICATION_CODE;
  l_factoring_code     OKL_AE_TEMPLATES.FAC_CODE%TYPE
                             := P_TMPL_IDENTIFY_REC.FACTORING_CODE;
  l_investor_code     OKL_AE_TEMPLATES.INV_CODE%TYPE
                             := P_TMPL_IDENTIFY_REC.INVESTOR_CODE;
  l_memo_yn            OKL_AE_TEMPLATES.MEMO_YN%TYPE := P_TMPL_IDENTIFY_REC.MEMO_YN;
  l_prior_year_yn      OKL_AE_TEMPLATES.PRIOR_YEAR_YN%TYPE := P_TMPL_IDENTIFY_REC.PRIOR_YEAR_YN;
  l_return_status VARCHAR2(1) := OKL_API.G_RET_STS_SUCCESS;

  -- Bug 3948354

  l_rev_rec_flag  VARCHAR2(1) := NVL(P_TMPL_IDENTIFY_REC.REV_REC_FLAG, 'N');

  CURSOR prod_csr(v_prod_id NUMBER) IS
  SELECT aes_id
  FROM OKL_PRODUCTS_V
  WHERE ID = v_prod_id;

BEGIN
  IF (G_DEBUG_ENABLED = 'Y') THEN
    G_IS_DEBUG_STATEMENT_ON := OKL_DEBUG_PUB.CHECK_LOG_ON(G_MODULE, FND_LOG.LEVEL_STATEMENT);
  END IF;

  x_return_status := OKL_API.G_RET_STS_SUCCESS;

  -- Check if the Product ID is null
  IF (p_tmpl_identify_rec.PRODUCT_ID = OKL_API.G_MISS_NUM) OR
      (p_tmpl_identify_rec.PRODUCT_ID IS NULL) THEN
       OKL_API.set_message(G_APP_NAME, G_REQUIRED_VALUE,G_COL_NAME_TOKEN,'Product ID');
       RAISE OKL_API.G_EXCEPTION_ERROR;
  END IF;

   -- Check if the Transaction type is null
  IF (p_tmpl_identify_rec.TRANSACTION_TYPE_ID = OKL_API.G_MISS_NUM) OR
      (p_tmpl_identify_rec.TRANSACTION_TYPE_ID IS NULL) THEN
       OKL_API.set_message(G_APP_NAME, G_REQUIRED_VALUE,G_COL_NAME_TOKEN,'Transaction Type ID');
       RAISE OKL_API.G_EXCEPTION_ERROR;
  END IF;


  -- Form the select statement to query the template info

  l_stmt := ' SELECT ID
             ,NAME
             ,SET_OF_BOOKS_ID
             ,STY_ID
             ,TRY_ID
             ,AES_ID
         ,SYT_CODE
             ,FAC_CODE
             ,FMA_ID
             ,ADVANCE_ARREARS
             ,POST_TO_GL
             ,VERSION
             ,START_DATE
             ,OBJECT_VERSION_NUMBER
             ,MEMO_YN
             ,PRIOR_YEAR_YN
             ,DESCRIPTION
             ,FACTORING_SYND_FLAG
             ,END_DATE
             ,ACCRUAL_YN
             ,ORG_ID
             ,ATTRIBUTE_CATEGORY
             ,ATTRIBUTE1
             ,ATTRIBUTE2
             ,ATTRIBUTE3
             ,ATTRIBUTE4
             ,ATTRIBUTE5
             ,ATTRIBUTE6
             ,ATTRIBUTE7
             ,ATTRIBUTE8
             ,ATTRIBUTE9
             ,ATTRIBUTE10
             ,ATTRIBUTE11
             ,ATTRIBUTE12
             ,ATTRIBUTE13
             ,ATTRIBUTE14
             ,ATTRIBUTE15
             ,CREATED_BY
             ,CREATION_DATE
             ,LAST_UPDATED_BY
             ,LAST_UPDATE_DATE
             ,LAST_UPDATE_LOGIN
             ,INV_CODE
       FROM OKL_AE_TEMPLATES A WHERE 1 = 1 ';


  OPEN prod_csr(l_product_id);
  FETCH prod_csr INTO l_aes_id ;
  CLOSE prod_csr;

  -- Add aes_id to the where condition if aes_id is not null

  IF (l_aes_id IS NOT NULL) THEN
      l_where := l_where || ' AND aes_id = ' || l_aes_id || ' ';
  END IF;

-- Add l_stream_type_id to the where condition if l_stream_type_id is not null
  IF (l_stream_type_id IS NOT NULL)  AND
     (l_stream_type_id <> OKL_API.G_MISS_NUM) THEN
      l_where := l_where || ' AND sty_id = ' || l_stream_type_id || ' ';
  END IF;

-- Add l_transaction_type_id to the where condition if l_transaction_type_id is not null
  IF (l_transaction_type_id IS NOT NULL) AND
     (l_transaction_type_id <> OKL_API.G_MISS_NUM) THEN
     l_where := l_where || ' AND try_id = ' || l_transaction_type_id || ' ';
  END IF;

-- Following lines commented by Kanti. Bug 2467318

--  IF (l_advance_arrears IS NOT NULL) AND
--     (l_advance_arrears <> OKL_API.G_MISS_CHAR) THEN
--     l_where := l_where || ' AND advance_arrears = ' || '''' || l_advance_arrears || '''' || ' ';
--  ELSIF (l_advance_arrears IS NULL) THEN
--     l_where := l_where || ' AND advance_arrears IS NULL ';
--  END IF;

-- Following lines commented by Kanti. Bug 2467318
--  IF (l_prior_year_yn IS NOT NULL) AND
--     (l_prior_year_yn <> OKL_API.G_MISS_CHAR) THEN
--     l_where := l_where || ' AND prior_year_yn = ' || '''' || l_prior_year_yn || '''' || ' ';
--  END IF;


-- Bug 3948354
-- If AE is called from Revenue Recognition program, it does not use
-- memo flag to identify the templates.

IF l_rev_rec_flag = 'N' THEN

-- Changed by kthiruva 26-Sep-2003 for Bug 3162340
-- If the memo_yn field is NULL or G_MISS_CHAR then the value passed is 'N' else the actual
-- value is passed to the where clause to identify the templates.

  IF (l_memo_yn IS NULL) OR
     (l_memo_yn = OKL_API.G_MISS_CHAR) THEN
     l_memo_yn  := 'N';
     l_where_memo_yn := l_where_memo_yn || ' AND memo_yn = ' || '''' || l_memo_yn || '''' ||  ' ';
  ELSE
     l_where_memo_yn := l_where_memo_yn || ' AND memo_yn = ' || '''' || l_memo_yn || '''' ||  ' ';
  END IF;

-- Bug 3948354
ELSE
  l_where_memo_yn := ' ';
END IF;




  l_where := l_where || ' AND trunc(start_date) <= ' || '''' ||  trunc(p_validity_date) || '''';
  l_where := l_where || ' AND (trunc(end_date) >=  '  || '''' || trunc(p_validity_date) || '''';
  l_where := l_where || ' OR end_date IS NULL )' ;


  IF (l_factoring_synd_flag IS NOT NULL) AND
     (l_factoring_synd_flag <> OKL_API.G_MISS_CHAR) THEN
     l_where_flag_code := l_where_flag_code || ' AND factoring_synd_flag = '
                  || '''' || l_factoring_synd_flag || '''' || ' ';
  ELSIF (l_factoring_synd_flag IS NULL) THEN
     l_where_flag_code := l_where_flag_code || ' AND factoring_synd_flag IS NULL ';
  END IF;


-- Add l_syndication_code to the where condition if l_syndication_code is not null
  IF (l_syndication_code IS NOT NULL) AND
     (l_syndication_code <> OKL_API.G_MISS_CHAR) THEN
     l_where_flag_code := l_where_flag_code || ' AND syt_code = '
                  || '''' || l_syndication_code || '''' || ' ';
  ELSIF (l_syndication_code IS NULL) THEN
     l_where_flag_code := l_where_flag_code || ' AND syt_code IS NULL ';
  END IF;

-- Add l_factoring_code to the where condition if l_factoring_code is not null
  IF (l_factoring_code IS NOT NULL) AND
     (l_factoring_code <> OKL_API.G_MISS_CHAR) THEN
     l_where_flag_code := l_where_flag_code || ' AND fac_code = '
                  || '''' || l_factoring_code || '''' || ' ';
  ELSIF (l_factoring_code IS NULL) THEN
     l_where_flag_code := l_where_flag_code || ' AND fac_code IS NULL ';
  END IF;

-- Add l_factoring_code to the where condition if l_factoring_code is not null
  IF (l_investor_code IS NOT NULL) AND
     (l_investor_code <> OKL_API.G_MISS_CHAR) THEN
     l_where_flag_code := l_where_flag_code || ' AND inv_code = '
                  || '''' || l_investor_code || '''' || ' ';
  ELSIF (l_investor_code IS NULL) THEN
     l_where_flag_code := l_where_flag_code || ' AND inv_code IS NULL ';
  END IF;

 -- Execute the complete select statement
  l_stmt_exe        := l_stmt || l_where ||l_where_memo_yn || l_where_flag_code ;
  IF (G_IS_DEBUG_STATEMENT_ON = true) THEN
      OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE,'The statement executed for fetching the Template Information is :');
    OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE,l_stmt_exe);
  END IF;

  execute_tmpl_query(p_stmt    => l_stmt_exe,
     x_return_status => l_return_status,
                   x_template_tbl  =>  x_template_tbl);

  IF l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR THEN
    RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
  END IF;


  IF (l_factoring_synd_flag IS NOT NULL) AND
     (l_factoring_synd_flag <> OKL_API.G_MISS_CHAR) THEN
     l_where_flag := l_where_flag || ' AND factoring_synd_flag = '
                  || '''' || l_factoring_synd_flag || '''' || ' ';
     l_where_flag := l_where_flag || ' AND syt_code IS NULL AND fac_code '
           || ' IS NULL AND inv_code IS NULL ';
  END IF;

-- Execute the select statement with syndication flag only

  IF  x_template_tbl.COUNT = 0 THEN
    l_stmt_exe        := l_stmt || l_where ||l_where_memo_yn|| l_where_flag ;
    IF (G_IS_DEBUG_STATEMENT_ON = true) THEN
          OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE,'The statement executed for fetching the Template Information is :');
      OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE,l_stmt_exe);
    END IF;

    execute_tmpl_query(p_stmt    => l_stmt_exe,
     x_return_status => l_return_status,
                   x_template_tbl  =>  x_template_tbl);
  END IF;

  IF l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR THEN
    RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
  END IF;

  l_where_no_flag := ' AND factoring_synd_flag IS NULL AND syt_code IS NULL AND fac_code '
           || ' IS NULL AND inv_code IS NULL ';

-- Execute the select statement with out syndication flag and code

  IF  x_template_tbl.COUNT = 0 THEN
    l_stmt_exe        := l_stmt || l_where ||l_where_memo_yn|| l_where_no_flag;

    IF (G_IS_DEBUG_STATEMENT_ON = true) THEN
          OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE,'The statement executed for fetching the Template Information is :');
      OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE,l_stmt_exe);
    END IF;

    execute_tmpl_query(p_stmt    => l_stmt_exe,
     x_return_status => l_return_status,
                   x_template_tbl  =>  x_template_tbl);
  END IF;

  IF l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR THEN
    RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
  END IF;


-- Bug 3948354
-- If AE is called from Revenue Recognition program, it does not use
-- memo flag to identify the templates.

IF l_rev_rec_flag = 'N' THEN


--Added by kthiruva 25-Sep-2003 for Bug 3162340
-- IF memo_yn = 'Y' does not fetch any templates then execute the query again for memo_yn = 'N'

  IF x_template_tbl.COUNT = 0 THEN
     IF l_memo_yn = 'Y' THEN
       l_where_memo_yn := ' ';
       l_memo_yn := 'N';
       l_where_memo_yn := l_where_memo_yn || ' AND memo_yn = ' || '''' || l_memo_yn || '''' ||  ' ';


      -- Execute the complete select statement
     l_stmt_exe        := l_stmt || l_where ||l_where_memo_yn || l_where_flag_code ;
     IF (G_IS_DEBUG_STATEMENT_ON = true) THEN
            OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE,'The statement executed for fetching the Template Information is :');
       OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE,l_stmt_exe);
     END IF;

     execute_tmpl_query(p_stmt    => l_stmt_exe,
                  x_return_status => l_return_status,
                        x_template_tbl  =>  x_template_tbl);

     IF l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR THEN
       RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
     END IF;

     -- Execute the select statement with syndication flag only

      IF  x_template_tbl.COUNT = 0 THEN
         l_stmt_exe        := l_stmt || l_where ||l_where_memo_yn|| l_where_flag ;
         IF (G_IS_DEBUG_STATEMENT_ON = true) THEN
                    OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE,'The statement executed for fetching the Template Information is :');
           OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE,l_stmt_exe);
         END IF;

         execute_tmpl_query(p_stmt    => l_stmt_exe,
                      x_return_status => l_return_status,
                            x_template_tbl  =>  x_template_tbl);
      END IF;

      IF l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR THEN
        RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
      END IF;

      -- Execute the select statement with out syndication flag and code

      IF  x_template_tbl.COUNT = 0 THEN
         l_stmt_exe        := l_stmt || l_where ||l_where_memo_yn|| l_where_no_flag;
         IF (G_IS_DEBUG_STATEMENT_ON = true) THEN
                    OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE,'The statement executed for fetching the Template Information is :');
           OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE,l_stmt_exe);
         END IF;

         execute_tmpl_query(p_stmt    => l_stmt_exe,
                      x_return_status => l_return_status,
                            x_template_tbl  =>  x_template_tbl);
      END IF;

      IF l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR THEN
        RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
      END IF;

    END IF;
   END IF;
END IF;


EXCEPTION

  WHEN OKL_API.G_EXCEPTION_ERROR THEN
      x_return_status := OKL_API.G_RET_STS_ERROR;

  WHEN OKL_API.G_EXCEPTION_UNEXPECTED_ERROR THEN
      x_return_status := OKL_API.G_RET_STS_UNEXP_ERROR;

  WHEN OTHERS THEN
      x_return_status := OKL_API.G_RET_STS_UNEXP_ERROR;
      OKL_API.SET_MESSAGE(p_app_name      => g_app_name
                         ,p_msg_name      => g_unexpected_error
                         ,p_token1        => g_sqlcode_token
                         ,p_token1_value  => SQLCODE
                         ,p_token2        => g_sqlerrm_token
                         ,p_token2_value  => SQLERRM);

END get_template_info;




PROCEDURE  EXECUTE_FORMULA(p_avlv_rec             IN          avlv_rec_type,
                           p_contract_id          IN          NUMBER,
                           p_contract_line_id     IN          NUMBER,
                           p_ctxt_val_tbl         IN          ctxt_val_tbl_type,
                           x_return_status        OUT         NOCOPY VARCHAR2,
                           x_amount               OUT         NOCOPY NUMBER)
IS

  l_init_msg_list    VARCHAR2(1) := OKL_API.G_FALSE;
  l_return_status    VARCHAR2(1) := OKL_API.G_RET_STS_SUCCESS;
  l_msg_count        NUMBER := 0;
  l_msg_data         VARCHAR2(2000);
  l_formula_name     OKL_FORMULAE_V.NAME%TYPE;

  CURSOR frml_csr(v_id NUMBER) IS
  SELECT name
  FROM okl_formulae_v
  WHERE id = v_id;

BEGIN

   -- Get the formula name associates with the template

   OPEN frml_csr(p_avlv_rec.fma_id);
   FETCH frml_csr INTO l_formula_name;
   CLOSE frml_csr;

  -- Make a call to formula engine to execute the formula

  -- Formula Engine has to return the currency code.. Code will be added soon

-- Start of wraper code generated automatically by Debug code generator for Okl_Execute_Formula_Pub.EXECUTE
  IF(L_DEBUG_ENABLED='Y') THEN
    L_LEVEL_PROCEDURE :=FND_LOG.LEVEL_PROCEDURE;
    IS_DEBUG_PROCEDURE_ON := OKL_DEBUG_PUB.Check_Log_On(L_MODULE, L_LEVEL_PROCEDURE);
  END IF;
  IF(IS_DEBUG_PROCEDURE_ON) THEN
    BEGIN
        OKL_DEBUG_PUB.LOG_DEBUG(L_LEVEL_PROCEDURE,L_MODULE,'Begin Debug OKLRTDTB.pls call Okl_Execute_Formula_Pub.EXECUTE ');
    END;
  END IF;

   Okl_Execute_Formula_Pub.EXECUTE(p_api_version            => 1.0
                                  ,p_init_msg_list          => l_init_msg_list
                                  ,x_return_status          => l_return_status
                                  ,x_msg_count              => l_msg_count
                                  ,x_msg_data               => l_msg_data
                                  ,p_formula_name           => l_formula_name
                                  ,p_contract_id            => p_contract_id
                                  ,p_line_id                => p_contract_line_id
                                  ,p_additional_parameters  => p_ctxt_val_tbl
                                  ,x_value                  => x_amount);

  IF(IS_DEBUG_PROCEDURE_ON) THEN
    BEGIN
        OKL_DEBUG_PUB.LOG_DEBUG(L_LEVEL_PROCEDURE,L_MODULE,'End Debug OKLRTDTB.pls call Okl_Execute_Formula_Pub.EXECUTE ');
    END;
  END IF;
-- End of wraper code generated automatically by Debug code generator for Okl_Execute_Formula_Pub.EXECUTE

   x_return_status := l_return_status;

EXCEPTION

   WHEN OTHERS THEN
      OKL_API.SET_MESSAGE(p_app_name      => g_app_name
                         ,p_msg_name      => g_unexpected_error
                         ,p_token1        => g_sqlcode_token
                         ,p_token1_value  => SQLCODE
                         ,p_token2        => g_sqlerrm_token
                         ,p_token2_value  => SQLERRM);

      x_return_status := OKL_API.G_RET_STS_UNEXP_ERROR;

END EXECUTE_FORMULA;


FUNCTION  CHECK_DIST(p_source_id            IN          NUMBER,
                     p_source_table         IN          VARCHAR2)
RETURN NUMBER


IS

  l_posted_yn           VARCHAR2(1);
  l_gl_transfer_flag    VARCHAR2(1);

  CURSOR dist_csr(v_source_id NUMBER,
                  v_source_table VARCHAR2) IS
  SELECT POSTED_YN
  FROM OKL_TRNS_ACC_DSTRS
  WHERE source_id    = v_source_id
  AND   source_table = v_source_table;


  CURSOR aeh_csr(v_source_id NUMBER,
                 v_source_table VARCHAR2) IS

  SELECT gl_transfer_flag
  FROM OKL_AE_HEADERS aeh, OKL_ACCOUNTING_EVENTS aet
  WHERE  aeh.accounting_event_id = aet.accounting_event_id
  AND    aet.source_id    = v_source_id
  AND    aet.source_table = v_source_table;

BEGIN

  OPEN dist_csr(p_source_id, p_source_table);
  FETCH dist_csr INTO l_posted_yn;
  IF (dist_csr%NOTFOUND) THEN
     CLOSE dist_csr;
     RETURN 0;
  END IF;
  CLOSE dist_csr;

  IF (l_posted_yn = 'N') THEN
     RETURN 1;
  ELSIF (l_posted_yn = 'Y') THEN
     OPEN aeh_csr(p_source_id, p_source_table);
     FETCH aeh_csr INTO l_gl_transfer_flag;
     CLOSE aeh_csr;
     IF (l_gl_transfer_flag <> 'N') THEN
         RETURN 3;
     ELSE
         RETURN 2;
     END IF;
  END IF;
END CHECK_DIST;


--This function is used to check the status of the Journal Creation
-- status = 0 denotes that there are no distributions existing in OKL for the source_id, source_table combination
-- status = 1 denotes that the distributions in OKL exist, but journals have not yet been created in SLA
-- status = 2 denotes that the distributions exist in OKL , and journals have been created in SLA

FUNCTION  check_journal(p_source_id            IN          NUMBER,
                        p_source_table         IN          VARCHAR2)
RETURN NUMBER
IS

  --Added by kthiruva on 02-Jul-2007
  --Bug 6154785 - Start of Changes
  CURSOR posted_yn_csr(v_source_id NUMBER,
                  v_source_table VARCHAR2) IS
  SELECT POSTED_YN
  FROM OKL_TRNS_ACC_DSTRS
  WHERE source_id    = v_source_id
  AND   source_table = v_source_table;
  --Bug 6154785 - End of Changes

  CURSOR dist_csr(v_source_id NUMBER,
                  v_source_table VARCHAR2) IS
  SELECT distinct xle.event_status_code
  FROM OKL_TRNS_ACC_DSTRS dist,
       XLA_EVENTS xle
  WHERE dist.SOURCE_ID    = v_source_id
  AND dist.SOURCE_TABLE = v_source_table
  AND dist.accounting_event_id = xle.event_id;

  l_status    VARCHAR2(1);
  l_posted_yn           VARCHAR2(1);

BEGIN

  OPEN posted_yn_csr(p_source_id, p_source_table);
  FETCH posted_yn_csr INTO l_posted_yn;
  IF (posted_yn_csr%NOTFOUND) THEN
     CLOSE posted_yn_csr;
     RETURN 0;
  END IF;
  CLOSE posted_yn_csr;

  --For Billing/Disbursement transactions the posted_yn flag will be N as they need not be posted to GL
  IF (l_posted_yn = 'N') THEN
     RETURN 1;
  ELSE
    --Transaction is an OKL transaction.Check if its already created in SLA or not
    OPEN dist_csr(p_source_id, p_source_table);
    FETCH dist_csr INTO l_status;
    IF (dist_csr%NOTFOUND) THEN
       CLOSE dist_csr;
       RETURN 0 ;
    END IF;
    CLOSE dist_csr;

    IF (l_status IN ('I','U')) THEN
      RETURN 1;
    ELSE
      RETURN 2;
    END IF;
  END IF;

END check_journal;


PROCEDURE  CREATE_DIST_RECS(p_avlv_rec         IN    AVLV_REC_TYPE,
                  p_tmpl_identify_rec IN   TMPL_IDENTIFY_REC_TYPE,
                            p_dist_info_rec    IN    DIST_INFO_REC_TYPE,
                            p_amount           IN    NUMBER,
                            p_gen_table        IN    acc_gen_primary_key,
                x_return_status    OUT   NOCOPY VARCHAR2,
x_tabv_tbl         OUT   NOCOPY TABV_TBL_TYPE)
IS
-- Changed by Santonyr on 22-Sep-2004 to fix bug 3901209.
-- Selecting Template Line ID also in the cursor.

  CURSOR atl_csr(v_avl_id NUMBER) IS
  SELECT  ID,
    CODE_COMBINATION_ID
         ,AE_LINE_TYPE
         ,CRD_CODE
         ,ACCOUNT_BUILDER_YN
         ,PERCENTAGE
  FROM OKL_AE_TMPT_LNES
  WHERE avl_id = v_avl_id;

  l_atl_rec atl_csr%ROWTYPE;
  l_rowcount   NUMBER := 0;

  CURSOR sao_csr IS
  SELECT  rounding_ccid
         ,cc_apply_rounding_difference
         ,ael_apply_rounding_difference
  FROM OKL_SYS_ACCT_OPTS;

  CURSOR sob_csr (v_set_of_books_id NUMBER) IS
  SELECT ROUNDING_CCID rounding_code_combination_id
  FROM GL_LEDGERS_PUBLIC_V
  WHERE ledger_id = v_set_of_books_id;

  l_tabv_tbl      tabv_tbl_type ;
  l_tabv_tbl_out  tabv_tbl_type ;
  i  NUMBER := 0;
  l_rate                  NUMBER := 0;
  l_currency_conversion_rate NUMBER := 0;
  l_acc_amount            NUMBER := 0;
  l_total_amount          NUMBER := 0;
  l_acc_total_amount      NUMBER := 0;
  l_amount                NUMBER := 0;
  l_dr_total              NUMBER := 0;
  l_cr_total              NUMBER := 0;
  l_dr_diff               NUMBER := 0;
  l_cr_diff               NUMBER := 0;
  l_acc_dr_diff           NUMBER := 0;
  l_acc_cr_diff           NUMBER := 0;
  l_acc_dr_total          NUMBER := 0;
  l_acc_cr_total          NUMBER := 0;

  l_slice_amount          NUMBER := 0;
  --Added by dpsingh for Bug:5082565(H)
  l_highest_amount_cr     NUMBER := OKL_API.G_MISS_NUM;
  l_highest_amount_dr     NUMBER := OKL_API.G_MISS_NUM;
  --end dpsingh
  l_lowest_amount_cr      NUMBER := OKL_API.G_MISS_NUM;
  l_lowest_amount_dr      NUMBER := OKL_API.G_MISS_NUM;
  l_lowest_index_cr       NUMBER := 0;
  l_lowest_index_dr       NUMBER := 0;
  l_highest_index_cr      NUMBER := 0;
  l_highest_index_dr      NUMBER := 0;
  l_rounding_ccid         NUMBER := 0;
  l_functional_curr       OKL_TRNS_ACC_DSTRS.CURRENCY_CODE%TYPE;
  l_formula_curr          OKL_TRNS_ACC_DSTRS.CURRENCY_CODE%TYPE;
  l_passed_curr           OKL_TRNS_ACC_DSTRS.CURRENCY_CODE%TYPE;
  l_cc_apply_rounding_diff     OKL_SYS_ACCT_OPTS.CC_APPLY_ROUNDING_DIFFERENCE%TYPE;
  l_ael_apply_rounding_diff    OKL_SYS_ACCT_OPTS.AEL_APPLY_ROUNDING_DIFFERENCE%TYPE;

  l_api_version     NUMBER := 1.0;
  l_init_msg_list         VARCHAR2(1) := OKL_API.G_FALSE;
  l_msg_count             NUMBER := 0;
  l_msg_data              VARCHAR2(2000);
  l_return_status         VARCHAR2(1) := OKL_API.G_RET_STS_SUCCESS;
  l_set_of_books_id       NUMBER;
  l_acc_gen_wf_sources_rec  acc_gen_wf_sources_rec;

BEGIN
  IF (G_DEBUG_ENABLED = 'Y') THEN
    G_IS_DEBUG_STATEMENT_ON := OKL_DEBUG_PUB.CHECK_LOG_ON(G_MODULE, FND_LOG.LEVEL_STATEMENT);
  END IF;

  IF (G_IS_DEBUG_STATEMENT_ON = true) THEN
      OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE,'Inside the procedure CREATE_DIST_RECS');
  END IF;

  -- get the below details based on the representation .. MG uptake
  IF nvl(g_representation_type, 'PRIMARY') = 'PRIMARY' THEN
    l_functional_curr  := Okl_Accounting_Util.get_func_curr_code;
    l_set_of_books_id  := OKL_ACCOUNTING_UTIL.GET_SET_OF_BOOKS_ID;
  ELSE
    l_functional_curr  := Okl_Accounting_Util.get_func_curr_code(g_ledger_id);
    l_set_of_books_id  := g_ledger_id;
  END IF;

  OPEN sao_csr;
  FETCH sao_csr INTO l_rounding_ccid,
                     l_cc_apply_rounding_diff,
                     l_ael_apply_rounding_diff;
  CLOSE sao_csr;
  IF (G_IS_DEBUG_STATEMENT_ON = true) THEN
      OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE,'The values returned by sao_csr are: ');
    OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE,'l_rounding_ccid             :'||l_rounding_ccid);
    OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE,'l_cc_apply_rounding_diff    :'||l_cc_apply_rounding_diff);
    OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE,'l_ael_apply_rounding_diff   :'||l_ael_apply_rounding_diff);
  END IF;

-- The following three lines of code to be removed once we start populating rounding CCID in
-- OKL_SYS_ACCT_OPTS table. Starts Here ****

  OPEN sob_csr(l_set_of_books_id);
  FETCH sob_csr INTO l_rounding_ccid;
  CLOSE sob_csr;

--- Ends Here  *****

-- Santonyr Commented out on 18-Nov-2002
-- Multi Currency Changes

/*
  IF (l_passed_curr <> l_functional_curr) THEN
       l_rate  := Okl_Accounting_Util.get_curr_con_rate
                           (p_from_curr_code => l_passed_curr,
                            p_to_curr_code   => l_functional_curr,
                            p_con_date       => p_dist_info_rec.currency_conversion_date,
                            p_con_type       => p_dist_info_rec.currency_conversion_type);
       IF (l_rate = 0) THEN
           OKL_API.SET_MESSAGE(p_app_name     => g_app_name,
                               p_msg_name     => 'OKL_CONV_RATE_NOT_FOUND');
           x_return_status := OKL_API.G_RET_STS_ERROR;
           RAISE OKL_API.G_EXCEPTION_ERROR;
       END IF;
  ELSE
       l_rate := 1;
  END IF;
*/

-- Santonyr Changed on 18-Nov-2002
-- Multi Currency Changes
-- Accounting Engine assumes the transaction is on functional currency if not passed

  IF (p_dist_info_rec.currency_code IS NOT NULL) AND
     (p_dist_info_rec.currency_code <> OKL_API.G_MISS_CHAR) THEN
     l_passed_curr := p_dist_info_rec.currency_code;
  ELSE
     l_passed_curr := l_functional_curr;
  END IF;

-- Santonyr Changed on 18-Nov-2002
-- Multi Currency Changes
-- The Conversion rate is 1 if both transaction and functional currencies are same. Else
-- Use the currency passed.

  IF (l_passed_curr = l_functional_curr) THEN
    l_rate := 1;
    l_currency_conversion_rate := NULL;
  ELSE
    l_rate := p_dist_info_rec.currency_conversion_rate;
    l_currency_conversion_rate := p_dist_info_rec.currency_conversion_rate;
  END IF;


-- Changed by Santonyr on 18th Jun, 2003 to fix the bug 3012735
-- Rounding the amounts before processing

  l_total_amount     :=  Okl_Accounting_Util.ROUND_AMOUNT
                         (p_amount        => p_amount,
                          p_currency_code => l_passed_curr);

  l_acc_total_amount :=  Okl_Accounting_Util.ROUND_AMOUNT
                         (p_amount        => l_total_amount * l_rate,
                          p_currency_code => l_functional_curr);

  -- Check to see that Template has at least two lines
  OPEN atl_csr(p_avlv_rec.ID);
  LOOP
     FETCH atl_csr INTO l_atl_rec;
     l_rowcount := atl_csr%ROWCOUNT;
     EXIT WHEN atl_csr%NOTFOUND;
  END LOOP;
  CLOSE atl_csr;

  IF (l_rowcount < 2) THEN
      OKL_API.SET_MESSAGE(p_app_name     => g_app_name,
                          p_msg_name     => 'OKL_LT2_LINE_IN_TMPL',
                          p_token1        => 'TEMPLATE',
                          p_token1_value  => p_avlv_rec.NAME,
                          p_token2        => 'COUNT',
                          p_token2_value  => l_rowcount);
      x_return_status := OKL_API.G_RET_STS_ERROR;
      RAISE OKL_API.G_EXCEPTION_ERROR;

  END IF;


  FOR atl_rec IN atl_csr(p_avlv_rec.ID)
  LOOP
       i := i + 1;
       l_slice_amount      :=  l_total_amount * atl_rec.percentage/100;

     -- Polulate l_tabv_tbl with the distribution attributes

       l_tabv_tbl(i).CR_DR_FLAG                 :=  atl_rec.CRD_CODE;

       IF (atl_rec.account_builder_yn = 'Y') THEN

       -- Call the Account generator if the account generator flag is set.

       -- Changed by Santonyr on 22-Sep-2004 to fix bug 3901209.
       -- Added a new parameter 'p_ae_tmpt_line_id'.
       -- If Account Generator fails due to lack of sources, it picks up the
       -- default account code for the passed account template line and returns.

   -- Populating account generator workflow sources for bug 4157521

          l_acc_gen_wf_sources_rec.product_id          := p_tmpl_identify_rec.product_id;
          l_acc_gen_wf_sources_rec.transaction_type_id := p_tmpl_identify_rec.transaction_type_id;
          l_acc_gen_wf_sources_rec.stream_type_id      := p_tmpl_identify_rec.stream_type_id;
          l_acc_gen_wf_sources_rec.factoring_synd_flag := p_tmpl_identify_rec.factoring_synd_flag;
          l_acc_gen_wf_sources_rec.syndication_code    := p_tmpl_identify_rec.syndication_code;
          l_acc_gen_wf_sources_rec.factoring_code      := p_tmpl_identify_rec.factoring_code;
          l_acc_gen_wf_sources_rec.investor_code       := p_tmpl_identify_rec.investor_code;
          l_acc_gen_wf_sources_rec.memo_yn             := p_tmpl_identify_rec.memo_yn;
          l_acc_gen_wf_sources_rec.rev_rec_flag      := p_tmpl_identify_rec.rev_rec_flag;
          l_acc_gen_wf_sources_rec.source_id           := p_dist_info_rec.source_id;
          l_acc_gen_wf_sources_rec.source_table        := p_dist_info_rec.source_table;
          l_acc_gen_wf_sources_rec.accounting_date     := trunc(G_gl_date);
          l_acc_gen_wf_sources_rec.contract_id         := p_dist_info_rec.contract_id;
          l_acc_gen_wf_sources_rec.contract_line_id    := p_dist_info_rec.contract_line_id;

          -- Changed the signature for bug 4157521

          -- 07-FEB-06.SGIYER. Bug 5013588
          -- Added check for account gen sources being passed.
          -- If not passed then defaulting.
          IF p_gen_table.COUNT > 0 THEN
            l_tabv_tbl(i).CODE_COMBINATION_ID :=
             OKL_ACCOUNT_GENERATOR_PUB.GET_CCID(p_api_version     => l_api_version,
                                                p_init_msg_list   => l_init_msg_list,
                                                x_return_status   => l_return_status,
                                                x_msg_count       => l_msg_count,
                                                x_msg_data        => l_msg_data,
                                                p_acc_gen_wf_sources_rec => l_acc_gen_wf_sources_rec,
                                                p_ae_line_type    => atl_rec.ae_line_type,
                                                p_primary_key_tbl => p_gen_table,
                                                p_ae_tmpt_line_id => atl_rec.id);

             IF (l_return_status <> OKL_API.G_RET_STS_SUCCESS) THEN
                IF (G_IS_DEBUG_STATEMENT_ON = true) THEN
                                  OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE,'Error encountered while fetching the CCID using the Account Generator Rules');
                END IF;
                x_return_status := l_return_status;
                RAISE OKL_API.G_EXCEPTION_ERROR;
             END IF;
          ELSE
            -- 07-FEB-06.SGIYER. Bug 5013588
            -- Defaulting template line account as per line level accrual solution
            IF (atl_rec.code_combination_id IS NULL) OR (atl_rec.code_combination_id = OKL_API.G_MISS_NUM) THEN
              Okl_Api.set_message(p_app_name     => g_app_name,
                                  p_msg_name     => 'OKL_TMPT_LN_CCID_REQD');
              x_return_status := OKL_API.G_RET_STS_ERROR;
              RAISE OKL_API.G_EXCEPTION_ERROR;
            END IF;
            l_tabv_tbl(i).CODE_COMBINATION_ID        :=  atl_rec.code_combination_id;
          END IF;

       ELSE
         l_tabv_tbl(i).CODE_COMBINATION_ID :=  atl_rec.code_combination_id;
       END IF;


       l_tabv_tbl(i).CURRENCY_CODE              :=  l_passed_curr;
       IF (atl_rec.CRD_CODE = 'D') THEN
           l_tabv_tbl(i).AE_LINE_TYPE           := 'LEASE_DEBIT';
       END IF;
       IF (atl_rec.CRD_CODE = 'C') THEN
           l_tabv_tbl(i).AE_LINE_TYPE           := 'LEASE_CREDIT';
       END IF;
       l_tabv_tbl(i).TEMPLATE_ID                :=  p_avlv_rec.ID;
       l_tabv_tbl(i).SOURCE_ID                  :=  p_dist_info_rec.source_id;
       l_tabv_tbl(i).SOURCE_TABLE               :=  p_dist_info_rec.source_table;
       l_tabv_tbl(i).GL_REVERSAL_FLAG           :=  p_dist_info_rec.gl_reversal_flag;

       l_amount                                 :=  Okl_Accounting_Util.ROUND_AMOUNT
                                                     (p_amount        => l_slice_amount,
                                                      p_currency_code => l_passed_curr);

       l_acc_amount                             :=  Okl_Accounting_Util.ROUND_AMOUNT
                                                      (p_amount  => l_slice_amount * l_rate,
                                                       p_currency_code => l_functional_curr);

       l_tabv_tbl(i).AMOUNT                     :=  l_amount;
       l_tabv_tbl(i).ACCOUNTED_AMOUNT           :=  l_acc_amount;
       l_tabv_tbl(i).GL_DATE                    :=  trunc(G_gl_date);
       l_tabv_tbl(i).PERCENTAGE                 :=  atl_rec.percentage;
       l_tabv_tbl(i).POSTED_YN                  := 'N';
       l_tabv_tbl(i).CURRENCY_CONVERSION_DATE   :=  p_dist_info_rec.currency_conversion_date;
       l_tabv_tbl(i).CURRENCY_CONVERSION_RATE   :=  l_currency_conversion_rate;
       l_tabv_tbl(i).CURRENCY_CONVERSION_TYPE   :=  p_dist_info_rec.currency_conversion_type;
       l_tabv_tbl(i).AE_CREATION_ERROR          :=  NULL;
       l_tabv_tbl(i).POST_TO_GL                 :=  p_dist_info_rec.post_to_gl;
       l_tabv_tbl(i).ORIGINAL_DIST_ID           :=  NULL;
       l_tabv_tbl(i).REVERSE_EVENT_FLAG         := 'N';
       -- pass the set_of_books_id to the tapi for MG uptake .. racheruv
       l_tabv_tbl(i).SET_OF_BOOKS_ID            := l_set_of_books_id;

       -- Bug 3948354
       -- Populate the comments column with 'CASH_RECEIPT if it is called from
       -- Revenue Recognition program

       IF NVL(G_REV_REC_FLAG, 'N') = 'Y' AND
         p_avlv_rec.MEMO_YN = 'Y' THEN
         l_tabv_tbl(i).COMMENTS := 'CASH_RECEIPT';
       END IF;


       IF (atl_rec.crd_code = 'D') THEN
           l_dr_total     := NVL(l_dr_total,0)     + l_amount;
           l_acc_dr_total := NVL(l_acc_dr_total,0) + l_acc_amount;
          -- Added OKL_API.G_MISS_NUM condition by dpsingh for bug 5082565(H)
          IF (l_highest_amount_dr = OKL_API.G_MISS_NUM OR l_highest_amount_dr <= l_amount) THEN
               l_highest_amount_dr := l_amount;
               l_highest_index_dr  := i;
           END IF;
           IF (l_lowest_amount_dr > l_amount) THEN
               l_lowest_amount_dr := l_amount;
               l_lowest_index_dr  := i;
           END IF;
       END IF;

       IF (atl_rec.crd_code = 'C') THEN
           l_cr_total     := NVL(l_cr_total,0) + l_amount;
           l_acc_cr_total := NVL(l_acc_cr_total,0) + l_acc_amount;
            -- Added OKL_API.G_MISS_NUM condition by dpsingh for bug 5082565(H)
           IF (l_highest_amount_cr = OKL_API.G_MISS_NUM OR l_highest_amount_cr <= l_amount) THEN
               l_highest_amount_cr := l_amount;
               l_highest_index_cr     := i;
           END IF;
           IF (l_lowest_amount_cr > l_amount) THEN
               l_lowest_amount_cr := l_amount;
               l_lowest_index_cr := i;
           END IF;
       END IF;

  END LOOP;

  IF (l_dr_total <> l_total_amount) THEN

  -- Changed by Santonyr on 18th Jun, 2003 to fix the bug 3012735
  -- Rounding the amounts before processing

      l_dr_diff := Okl_Accounting_Util.ROUND_AMOUNT (p_amount  => (l_total_amount - l_dr_total),
                                                     p_currency_code => l_passed_curr);

      l_acc_dr_diff := Okl_Accounting_Util.ROUND_AMOUNT (p_amount  => (l_acc_total_amount - l_acc_dr_total),
                                                     p_currency_code => l_functional_curr);

       --l_dr_diff     := l_total_amount     - l_dr_total;
       --l_acc_dr_diff := l_acc_total_amount - l_acc_dr_total;

       IF (l_ael_apply_rounding_diff = 'ADD_TO_HIGH') THEN

          l_tabv_tbl(l_highest_index_dr).AMOUNT := l_tabv_tbl(l_highest_index_dr).AMOUNT
                                                   + l_dr_diff;
          l_tabv_tbl(l_highest_index_dr).ACCOUNTED_AMOUNT :=
                             l_tabv_tbl(l_highest_index_dr).ACCOUNTED_AMOUNT + l_acc_dr_diff;

       ELSIF (l_ael_apply_rounding_diff = 'ADD_TO_LOW') THEN

          l_tabv_tbl(l_lowest_index_dr).AMOUNT           := l_tabv_tbl(l_lowest_index_dr).AMOUNT
                                                            + l_dr_diff;
          l_tabv_tbl(l_lowest_index_dr).ACCOUNTED_AMOUNT :=
                                     l_tabv_tbl(l_lowest_index_dr).ACCOUNTED_AMOUNT + l_acc_dr_diff;

       ELSIF (l_ael_apply_rounding_diff = 'ADD_NEW_LINE') THEN

           i := i + 1;
           l_tabv_tbl(i).CR_DR_FLAG                     :=  'D';
           l_tabv_tbl(i).CODE_COMBINATION_ID            :=  l_rounding_ccid;
           l_tabv_tbl(i).CURRENCY_CODE                  :=  l_passed_curr;
           l_tabv_tbl(i).AE_LINE_TYPE                   :=  'LEASE_DEBIT';
           l_tabv_tbl(i).TEMPLATE_ID                    :=  p_avlv_rec.ID;
           l_tabv_tbl(i).SOURCE_ID                      :=  p_dist_info_rec.source_id;
           l_tabv_tbl(i).SOURCE_TABLE                   :=  p_dist_info_rec.source_table;
           l_tabv_tbl(i).GL_REVERSAL_FLAG               :=  p_dist_info_rec.gl_reversal_flag;
           l_tabv_tbl(i).AMOUNT                         :=  l_dr_diff;
           l_tabv_tbl(i).ACCOUNTED_AMOUNT               :=  l_acc_dr_diff;
           l_tabv_tbl(i).GL_DATE                        :=  trunc(G_gl_date);
           l_tabv_tbl(i).PERCENTAGE                     :=  NULL;
           l_tabv_tbl(i).POSTED_YN                      := 'N';
           l_tabv_tbl(i).CURRENCY_CONVERSION_DATE       :=  p_dist_info_rec.currency_conversion_date;
           l_tabv_tbl(i).CURRENCY_CONVERSION_RATE:=  l_currency_conversion_rate;
           l_tabv_tbl(i).CURRENCY_CONVERSION_TYPE       := p_dist_info_rec.currency_conversion_type;
           l_tabv_tbl(i).AE_CREATION_ERROR              :=  NULL;
           l_tabv_tbl(i).POST_TO_GL                     :=  p_dist_info_rec.post_to_gl;
           l_tabv_tbl(i).ORIGINAL_DIST_ID               :=  NULL;
           l_tabv_tbl(i).REVERSE_EVENT_FLAG             := 'N';
           -- pass the set_of_books_id to the tapi for MG uptake .. racheruv
           l_tabv_tbl(i).SET_OF_BOOKS_ID            := l_set_of_books_id;

-- Bug 3948354
-- Populate the comments column with 'CASH_RECEIPT if it is called from
-- Revenue Recognition program

IF NVL(G_REV_REC_FLAG, 'N') = 'Y' AND
p_avlv_rec.MEMO_YN = 'Y' THEN
    l_tabv_tbl(i).COMMENTS := 'CASH_RECEIPT';
END IF;

      END IF; -- End If for l_ael_apply_rounding_diff

  END IF; -- End IF for (l_dr_total <> l_total_amount)


  IF (l_cr_total <> l_total_amount) THEN

  -- Changed by Santonyr on 18th Jun, 2003 to fix the bug 3012735
  -- Rounding the amounts before processing

      l_cr_diff := Okl_Accounting_Util.ROUND_AMOUNT (p_amount  => (l_total_amount - l_cr_total),
                                                     p_currency_code => l_passed_curr);

      l_acc_cr_diff := Okl_Accounting_Util.ROUND_AMOUNT (p_amount  => (l_acc_total_amount - l_acc_cr_total),
                                                     p_currency_code => l_functional_curr);

--       l_cr_diff     := l_total_amount     - l_cr_total;
--       l_acc_cr_diff := l_acc_total_amount - l_acc_cr_total;

       IF (l_ael_apply_rounding_diff = 'ADD_TO_HIGH') THEN

           l_tabv_tbl(l_highest_index_cr).AMOUNT     := l_tabv_tbl(l_highest_index_cr).AMOUNT
                                                            + l_cr_diff;
           l_tabv_tbl(l_highest_index_cr).ACCOUNTED_AMOUNT :=
                                  l_tabv_tbl(l_highest_index_cr).ACCOUNTED_AMOUNT + l_acc_cr_diff;

       ELSIF (l_ael_apply_rounding_diff = 'ADD_TO_LOW') THEN

           l_tabv_tbl(l_lowest_index_cr).AMOUNT           := l_tabv_tbl(l_lowest_index_cr).AMOUNT
                                                                 + l_cr_diff;
           l_tabv_tbl(l_lowest_index_cr).ACCOUNTED_AMOUNT :=
                                    l_tabv_tbl(l_lowest_index_cr).ACCOUNTED_AMOUNT + l_acc_cr_diff;


       ELSIF (l_ael_apply_rounding_diff = 'ADD_NEW_LINE') THEN

           i := i + 1;
           l_tabv_tbl(i).CR_DR_FLAG                     :=  'C';
           l_tabv_tbl(i).CODE_COMBINATION_ID            :=  l_rounding_ccid;
           l_tabv_tbl(i).CURRENCY_CODE                  :=  l_passed_curr;
           l_tabv_tbl(i).AE_LINE_TYPE                   :=  'LEASE_CREDIT';
           l_tabv_tbl(i).TEMPLATE_ID                    :=  p_avlv_rec.ID;
           l_tabv_tbl(i).SOURCE_ID                      :=  p_dist_info_rec.source_id;
           l_tabv_tbl(i).SOURCE_TABLE                   :=  p_dist_info_rec.source_table;
           l_tabv_tbl(i).GL_REVERSAL_FLAG               :=  p_dist_info_rec.gl_reversal_flag;
           l_tabv_tbl(i).AMOUNT                         :=  l_cr_diff;
           l_tabv_tbl(i).ACCOUNTED_AMOUNT               :=  l_acc_cr_diff;
           l_tabv_tbl(i).GL_DATE                        :=  trunc(G_gl_date);
           l_tabv_tbl(i).PERCENTAGE                     :=  NULL;
           l_tabv_tbl(i).POSTED_YN                      := 'N';
           l_tabv_tbl(i).CURRENCY_CONVERSION_DATE:=  p_dist_info_rec.currency_conversion_date;
           l_tabv_tbl(i).CURRENCY_CONVERSION_RATE:=  l_currency_conversion_rate;
           l_tabv_tbl(i).CURRENCY_CONVERSION_TYPE       :=  p_dist_info_rec.currency_conversion_type;
           l_tabv_tbl(i).AE_CREATION_ERROR              :=  NULL;
           l_tabv_tbl(i).POST_TO_GL                     :=  p_dist_info_rec.post_to_gl;
           l_tabv_tbl(i).ORIGINAL_DIST_ID               :=  NULL;
           l_tabv_tbl(i).REVERSE_EVENT_FLAG             := 'N';
           -- pass the set_of_books_id to the tapi for MG uptake
           l_tabv_tbl(i).SET_OF_BOOKS_ID            := l_set_of_books_id;

-- Bug 3948354
-- Populate the comments column with 'CASH_RECEIPT if it is called from
-- Revenue Recognition program

IF NVL(G_REV_REC_FLAG, 'N') = 'Y' AND
p_avlv_rec.MEMO_YN = 'Y' THEN
    l_tabv_tbl(i).COMMENTS := 'CASH_RECEIPT';
END IF;


       END IF; -- End IF for l_ael_apply_rounding_diff

  END IF; -- End IF for (l_cr_total <> l_total_amount)


  -- Create the distributions

-- Start of wraper code generated automatically by Debug code generator for Okl_Trns_Acc_Dstrs_Pub.INSERT_TRNS_ACC_DSTRS
  IF(IS_DEBUG_PROCEDURE_ON) THEN
    BEGIN
        OKL_DEBUG_PUB.LOG_DEBUG(L_LEVEL_PROCEDURE,L_MODULE,'Begin Debug OKLRTDTB.pls call Okl_Trns_Acc_Dstrs_Pub.INSERT_TRNS_ACC_DSTRS ');
    END;
  END IF;
  IF (G_IS_DEBUG_STATEMENT_ON = true) THEN
      OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE,'Prior to the call to INSERT_TRNS_ACC_DSTRS, the parameters passed are :');
    OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE,'=======================================================================');
  END IF;
  FOR i in l_tabv_tbl.FIRST..l_tabv_tbl.LAST
  LOOP
     IF (G_IS_DEBUG_STATEMENT_ON = true) THEN
            OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE,'l_tabv_tbl(i).CR_DR_FLAG               :'||l_tabv_tbl(i).CR_DR_FLAG);
       OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE,'l_tabv_tbl(i).CODE_COMBINATION_ID      :'||l_tabv_tbl(i).CODE_COMBINATION_ID);
       OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE,'l_tabv_tbl(i).CURRENCY_CODE            :'||l_tabv_tbl(i).CURRENCY_CODE);
       OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE,'l_tabv_tbl(i).AE_LINE_TYPE             :'||l_tabv_tbl(i).AE_LINE_TYPE);
       OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE,'l_tabv_tbl(i).TEMPLATE_ID              :'||l_tabv_tbl(i).TEMPLATE_ID);
       OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE,'l_tabv_tbl(i).SOURCE_ID                :'||l_tabv_tbl(i).SOURCE_ID);
       OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE,'l_tabv_tbl(i).SOURCE_TABLE             :'||l_tabv_tbl(i).SOURCE_TABLE);
       OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE,'l_tabv_tbl(i).GL_REVERSAL_FLAG         :'||l_tabv_tbl(i).GL_REVERSAL_FLAG);
       OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE,'l_tabv_tbl(i).AMOUNT                   :'||l_tabv_tbl(i).AMOUNT);
       OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE,'l_tabv_tbl(i).ACCOUNTED_AMOUNT         :'||l_tabv_tbl(i).ACCOUNTED_AMOUNT);
       OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE,'l_tabv_tbl(i).GL_DATE                  :'||l_tabv_tbl(i).GL_DATE);
       OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE,'l_tabv_tbl(i).PERCENTAGE               :'||l_tabv_tbl(i).PERCENTAGE);
       OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE,'l_tabv_tbl(i).POSTED_YN                :'||l_tabv_tbl(i).POSTED_YN);
       OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE,'l_tabv_tbl(i).CURRENCY_CONVERSION_DATE :'||l_tabv_tbl(i).CURRENCY_CONVERSION_DATE);
       OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE,'l_tabv_tbl(i).CURRENCY_CONVERSION_RATE :'||l_tabv_tbl(i).CURRENCY_CONVERSION_RATE);
       OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE,'l_tabv_tbl(i).CURRENCY_CONVERSION_TYPE :'||l_tabv_tbl(i).CURRENCY_CONVERSION_TYPE);
       OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE,'l_tabv_tbl(i).AE_CREATION_ERROR        :'||l_tabv_tbl(i).AE_CREATION_ERROR);
       OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE,'l_tabv_tbl(i).POST_TO_GL               :'||l_tabv_tbl(i).POST_TO_GL);
       OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE,'l_tabv_tbl(i).ORIGINAL_DIST_ID         :'||l_tabv_tbl(i).ORIGINAL_DIST_ID);
       OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE,'l_tabv_tbl(i).REVERSE_EVENT_FLAG       :'||l_tabv_tbl(i).REVERSE_EVENT_FLAG);
       OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE,'l_tabv_tbl(i).SET_OF_BOOKS_ID          :'||l_tabv_tbl(i).SET_OF_BOOKS_ID);
     END IF;
  END LOOP;

  Okl_Trns_Acc_Dstrs_Pub.INSERT_TRNS_ACC_DSTRS(p_api_version     => l_api_version
                                              ,p_init_msg_list   => l_init_msg_list
                                              ,x_return_status   => l_return_status
                                              ,x_msg_count       => l_msg_count
                                              ,x_msg_data        => l_msg_data
                                              ,p_tabv_tbl        => l_tabv_tbl
                                              ,x_tabv_tbl        => l_tabv_tbl_out);
  IF (G_IS_DEBUG_STATEMENT_ON = true) THEN
      OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE,'The return status after the call to Okl_Trns_Acc_Dstrs_Pub.INSERT_TRNS_ACC_DSTRS'||l_return_status);
  END IF;
  IF(IS_DEBUG_PROCEDURE_ON) THEN
    BEGIN
        OKL_DEBUG_PUB.LOG_DEBUG(L_LEVEL_PROCEDURE,L_MODULE,'End Debug OKLRTDTB.pls call Okl_Trns_Acc_Dstrs_Pub.INSERT_TRNS_ACC_DSTRS ');
    END;
  END IF;
-- End of wraper code generated automatically by Debug code generator for Okl_Trns_Acc_Dstrs_Pub.INSERT_TRNS_ACC_DSTRS

  x_return_status := l_return_status;
  x_tabv_tbl      := l_tabv_tbl_out;

EXCEPTION

  WHEN OKL_API.G_EXCEPTION_ERROR THEN
      NULL;
  WHEN others then
      OKL_API.SET_MESSAGE(p_app_name      => g_app_name
                         ,p_msg_name      => g_unexpected_error
                         ,p_token1        => g_sqlcode_token
                         ,p_token1_value  => SQLCODE
                         ,p_token2        => g_sqlerrm_token
                         ,p_token2_value  => SQLERRM);

      x_return_status := OKL_API.G_RET_STS_UNEXP_ERROR;

END CREATE_DIST_RECS;

--Added by kthiruva on 06-Feb-2007 for SLA Uptake
--Bug 5707866 - Start of Changes
--Signature to be used to create distributions, when the account derivation option is AMB
PROCEDURE  CREATE_DIST_RECS( --Bug 6127326 dpsingh start
                            p_avlv_rec         IN    AVLV_REC_TYPE DEFAULT NULL,
                            --Bug 6127326 dpsingh end
                            p_tmpl_identify_rec IN   TMPL_IDENTIFY_REC_TYPE,
                            p_dist_info_rec    IN    DIST_INFO_REC_TYPE,
                            p_amount           IN    NUMBER,
                            x_return_status    OUT   NOCOPY VARCHAR2,
                            x_tabv_tbl         OUT   NOCOPY tabv_tbl_type)
IS

  CURSOR sao_csr IS
  SELECT  rounding_ccid
         ,cc_apply_rounding_difference
         ,ael_apply_rounding_difference
  FROM OKL_SYS_ACCT_OPTS;

  CURSOR sob_csr (v_set_of_books_id NUMBER) IS
  SELECT ROUNDING_CCID rounding_code_combination_id
  FROM GL_LEDGERS_PUBLIC_V
  WHERE ledger_id = v_set_of_books_id;

  l_tabv_tbl      tabv_tbl_type ;
  l_tabv_tbl_out  tabv_tbl_type ;
  i  NUMBER := 0;
  l_rate                  NUMBER := 0;
  l_currency_conversion_rate NUMBER := 0;
  l_amount                NUMBER := p_amount;

  l_functional_curr       OKL_TRNS_ACC_DSTRS.CURRENCY_CODE%TYPE;
  l_formula_curr          OKL_TRNS_ACC_DSTRS.CURRENCY_CODE%TYPE;
  l_passed_curr           OKL_TRNS_ACC_DSTRS.CURRENCY_CODE%TYPE;
  l_rounding_ccid         NUMBER := 0;
  l_cc_apply_rounding_diff     OKL_SYS_ACCT_OPTS.CC_APPLY_ROUNDING_DIFFERENCE%TYPE;
  l_ael_apply_rounding_diff    OKL_SYS_ACCT_OPTS.AEL_APPLY_ROUNDING_DIFFERENCE%TYPE;


  l_api_version     NUMBER := 1.0;
  l_init_msg_list         VARCHAR2(1) := OKL_API.G_FALSE;
  l_msg_count             NUMBER := 0;
  l_msg_data              VARCHAR2(2000);
  l_return_status         VARCHAR2(1) := OKL_API.G_RET_STS_SUCCESS;
  l_set_of_books_id       NUMBER;


  --Added by kthiruva on 06-Feb-2006 for SLA Uptake
  --Bug 5707866 - Start of Changes
  l_account_derivation    OKL_SYS_ACCT_OPTS.ACCOUNT_DERIVATION%TYPE;
  --Bug 5707866 - End of Changes


BEGIN
  IF (G_DEBUG_ENABLED = 'Y') THEN
    G_IS_DEBUG_STATEMENT_ON := OKL_DEBUG_PUB.CHECK_LOG_ON(G_MODULE, FND_LOG.LEVEL_STATEMENT);
  END IF;

  IF (G_IS_DEBUG_STATEMENT_ON = true) THEN
      OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE,'Inside the procedure CREATE_DIST_RECS');
  END IF;

  -- get the details below based on the representation..MG uptake
  IF nvl(g_representation_type, 'PRIMARY') = 'PRIMARY' THEN
    l_functional_curr  := Okl_Accounting_Util.get_func_curr_code;
    l_set_of_books_id  := OKL_ACCOUNTING_UTIL.GET_SET_OF_BOOKS_ID;
  ELSE
    l_functional_curr  := Okl_Accounting_Util.get_func_curr_code(g_ledger_id);
    l_set_of_books_id  := g_ledger_id;
  END IF;

  OPEN sao_csr;
  FETCH sao_csr INTO l_rounding_ccid,
                     l_cc_apply_rounding_diff,
                     l_ael_apply_rounding_diff;
  CLOSE sao_csr;
  IF (G_IS_DEBUG_STATEMENT_ON = true) THEN
      OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE,'The values returned by sao_csr are: ');
    OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE,'l_rounding_ccid             :'||l_rounding_ccid);
    OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE,'l_cc_apply_rounding_diff    :'||l_cc_apply_rounding_diff);
    OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE,'l_ael_apply_rounding_diff   :'||l_ael_apply_rounding_diff);
  END IF;

  -- The following three lines of code to be removed once we start populating rounding CCID in
  -- OKL_SYS_ACCT_OPTS table. Starts Here ****

  OPEN sob_csr(l_set_of_books_id);
  FETCH sob_csr INTO l_rounding_ccid;
  CLOSE sob_csr;

  -- Santonyr Changed on 18-Nov-2002
  -- Multi Currency Changes
  -- Accounting Engine assumes the transaction is on functional currency if not passed

  IF (p_dist_info_rec.currency_code IS NOT NULL) AND
     (p_dist_info_rec.currency_code <> OKL_API.G_MISS_CHAR) THEN
     l_passed_curr := p_dist_info_rec.currency_code;
  ELSE
     l_passed_curr := l_functional_curr;
  END IF;

  -- Santonyr Changed on 18-Nov-2002
  -- Multi Currency Changes
  -- The Conversion rate is 1 if both transaction and functional currencies are same. Else
  -- Use the currency passed.

  IF (l_passed_curr = l_functional_curr) THEN
    l_rate := 1;
    l_currency_conversion_rate := NULL;
  ELSE
    l_rate := p_dist_info_rec.currency_conversion_rate;
    l_currency_conversion_rate := p_dist_info_rec.currency_conversion_rate;
  END IF;

  l_tabv_tbl(i).CURRENCY_CODE                  :=  l_passed_curr;
  l_tabv_tbl(i).SOURCE_ID                      :=  p_dist_info_rec.source_id;
  l_tabv_tbl(i).SOURCE_TABLE                   :=  p_dist_info_rec.source_table;
  l_tabv_tbl(i).GL_REVERSAL_FLAG               :=  p_dist_info_rec.gl_reversal_flag;
  --Raw amounts are being stored as the rounding would be done in SLA as per the rules setup
  l_tabv_tbl(i).AMOUNT                         :=  l_amount;
  l_tabv_tbl(i).ACCOUNTED_AMOUNT               :=  l_amount;
  l_tabv_tbl(i).GL_DATE                        :=  trunc(G_gl_date);
  l_tabv_tbl(i).PERCENTAGE                     :=  NULL;
  l_tabv_tbl(i).POSTED_YN                      := 'N';
  l_tabv_tbl(i).CURRENCY_CONVERSION_DATE       :=  p_dist_info_rec.currency_conversion_date;
  l_tabv_tbl(i).CURRENCY_CONVERSION_RATE   :=  l_currency_conversion_rate;
  l_tabv_tbl(i).CURRENCY_CONVERSION_TYPE       :=  p_dist_info_rec.currency_conversion_type;
  l_tabv_tbl(i).AE_CREATION_ERROR              :=  NULL;
  l_tabv_tbl(i).POST_TO_GL                     :=  p_dist_info_rec.post_to_gl;
  l_tabv_tbl(i).ORIGINAL_DIST_ID               :=  NULL;
  l_tabv_tbl(i).REVERSE_EVENT_FLAG             := 'N';
  --Bug 6127326 dpsingh start
  l_tabv_tbl(i).TEMPLATE_ID                :=  p_avlv_rec.ID;
   --Bug 6127326 dpsingh end
  -- pass the set_of_books_id to the tapi for MG uptake.
  l_tabv_tbl(i).set_of_books_id                 := l_set_of_books_id;

  -- Start of wraper code generated automatically by Debug code generator for Okl_Trns_Acc_Dstrs_Pub.INSERT_TRNS_ACC_DSTRS
  IF(IS_DEBUG_PROCEDURE_ON) THEN
    BEGIN
        OKL_DEBUG_PUB.LOG_DEBUG(L_LEVEL_PROCEDURE,L_MODULE,'Begin Debug OKLRTDTB.pls call Okl_Trns_Acc_Dstrs_Pub.INSERT_TRNS_ACC_DSTRS ');
    END;
  END IF;
  IF (G_IS_DEBUG_STATEMENT_ON = true) THEN
      OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE,'Prior to the call to INSERT_TRNS_ACC_DSTRS, the parameters passed are :');
    OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE,'=======================================================================');
  END IF;
  FOR i in l_tabv_tbl.FIRST..l_tabv_tbl.LAST
  LOOP
     IF (G_IS_DEBUG_STATEMENT_ON = true) THEN
       OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE,'l_tabv_tbl(i).CR_DR_FLAG               :'||l_tabv_tbl(i).CR_DR_FLAG);
       OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE,'l_tabv_tbl(i).CODE_COMBINATION_ID      :'||l_tabv_tbl(i).CODE_COMBINATION_ID);
       OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE,'l_tabv_tbl(i).CURRENCY_CODE            :'||l_tabv_tbl(i).CURRENCY_CODE);
       OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE,'l_tabv_tbl(i).AE_LINE_TYPE             :'||l_tabv_tbl(i).AE_LINE_TYPE);
       OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE,'l_tabv_tbl(i).TEMPLATE_ID              :'||l_tabv_tbl(i).TEMPLATE_ID);
       OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE,'l_tabv_tbl(i).SOURCE_ID                :'||l_tabv_tbl(i).SOURCE_ID);
       OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE,'l_tabv_tbl(i).SOURCE_TABLE             :'||l_tabv_tbl(i).SOURCE_TABLE);
       OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE,'l_tabv_tbl(i).GL_REVERSAL_FLAG         :'||l_tabv_tbl(i).GL_REVERSAL_FLAG);
       OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE,'l_tabv_tbl(i).AMOUNT                   :'||l_tabv_tbl(i).AMOUNT);
       OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE,'l_tabv_tbl(i).ACCOUNTED_AMOUNT         :'||l_tabv_tbl(i).ACCOUNTED_AMOUNT);
       OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE,'l_tabv_tbl(i).GL_DATE                  :'||l_tabv_tbl(i).GL_DATE);
       OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE,'l_tabv_tbl(i).PERCENTAGE               :'||l_tabv_tbl(i).PERCENTAGE);
       OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE,'l_tabv_tbl(i).POSTED_YN                :'||l_tabv_tbl(i).POSTED_YN);
       OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE,'l_tabv_tbl(i).CURRENCY_CONVERSION_DATE :'||l_tabv_tbl(i).CURRENCY_CONVERSION_DATE);
       OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE,'l_tabv_tbl(i).CURRENCY_CONVERSION_RATE :'||l_tabv_tbl(i).CURRENCY_CONVERSION_RATE);
       OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE,'l_tabv_tbl(i).CURRENCY_CONVERSION_TYPE :'||l_tabv_tbl(i).CURRENCY_CONVERSION_TYPE);
       OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE,'l_tabv_tbl(i).AE_CREATION_ERROR        :'||l_tabv_tbl(i).AE_CREATION_ERROR);
       OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE,'l_tabv_tbl(i).POST_TO_GL               :'||l_tabv_tbl(i).POST_TO_GL);
       OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE,'l_tabv_tbl(i).ORIGINAL_DIST_ID         :'||l_tabv_tbl(i).ORIGINAL_DIST_ID);
       OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE,'l_tabv_tbl(i).REVERSE_EVENT_FLAG       :'||l_tabv_tbl(i).REVERSE_EVENT_FLAG);
       OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE,'l_tabv_tbl(i).set_of_books_id       :'||l_tabv_tbl(i).set_of_books_id);
     END IF;
  END LOOP;

  Okl_Trns_Acc_Dstrs_Pub.INSERT_TRNS_ACC_DSTRS(p_api_version     => l_api_version
                                              ,p_init_msg_list   => l_init_msg_list
                                              ,x_return_status   => l_return_status
                                              ,x_msg_count       => l_msg_count
                                              ,x_msg_data        => l_msg_data
                                              ,p_tabv_tbl        => l_tabv_tbl
                                              ,x_tabv_tbl        => l_tabv_tbl_out);
  IF (G_IS_DEBUG_STATEMENT_ON = true) THEN
      OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE,'The return status after the call to Okl_Trns_Acc_Dstrs_Pub.INSERT_TRNS_ACC_DSTRS'||l_return_status);
  END IF;
  IF(IS_DEBUG_PROCEDURE_ON) THEN
    BEGIN
        OKL_DEBUG_PUB.LOG_DEBUG(L_LEVEL_PROCEDURE,L_MODULE,'End Debug OKLRTDTB.pls call Okl_Trns_Acc_Dstrs_Pub.INSERT_TRNS_ACC_DSTRS ');
    END;
  END IF;
-- End of wraper code generated automatically by Debug code generator for Okl_Trns_Acc_Dstrs_Pub.INSERT_TRNS_ACC_DSTRS

  x_return_status := l_return_status;
  x_tabv_tbl      := l_tabv_tbl_out;

EXCEPTION

  WHEN OKL_API.G_EXCEPTION_ERROR THEN
      NULL;
  WHEN others then
      OKL_API.SET_MESSAGE(p_app_name      => g_app_name
                         ,p_msg_name      => g_unexpected_error
                         ,p_token1        => g_sqlcode_token
                         ,p_token1_value  => SQLCODE
                         ,p_token2        => g_sqlerrm_token
                         ,p_token2_value  => SQLERRM);

      x_return_status := OKL_API.G_RET_STS_UNEXP_ERROR;

END CREATE_DIST_RECS;
--Bug 5707866 - End of Changes

PROCEDURE UPDATE_POST_TO_GL(p_api_version       IN               NUMBER,
                            p_init_msg_list     IN               VARCHAR2,
                            x_return_status     OUT              NOCOPY VARCHAR2,
                            x_msg_count         OUT              NOCOPY NUMBER,
                            x_msg_data          OUT              NOCOPY VARCHAR2,
                            p_source_id         IN               NUMBER,
            p_source_table      IN               VARCHAR2)
IS

  l_tabv_tbl_in     TABV_TBL_TYPE;
  l_tabv_tbl_out    TABV_TBL_TYPE;
  l_api_version     NUMBER := 1.0;
  l_id              NUMBER := 0;

  i  NUMBER := 0;


  CURSOR dist_csr IS
  SELECT ID
  FROM OKL_TRNS_ACC_DSTRS
  WHERE source_id     = p_source_id
  AND   source_table  = p_source_table;

  dist_rec  dist_csr%ROWTYPE;


BEGIN

   x_return_status := OKL_API.G_RET_STS_SUCCESS;

   FOR dist_rec IN dist_csr

   LOOP

      i := i + 1;
      l_tabv_tbl_in(i).ID := dist_rec.ID;
      l_tabv_tbl_in(i).POST_TO_GL  := 'Y';

   END LOOP;

   IF (l_tabv_tbl_in.COUNT > 0) THEN

-- Start of wraper code generated automatically by Debug code generator for Okl_Trns_Acc_Dstrs_Pub.update_trns_acc_dstrs
  IF(L_DEBUG_ENABLED='Y') THEN
    L_LEVEL_PROCEDURE :=FND_LOG.LEVEL_PROCEDURE;
    IS_DEBUG_PROCEDURE_ON := OKL_DEBUG_PUB.Check_Log_On(L_MODULE, L_LEVEL_PROCEDURE);
  END IF;
  IF(IS_DEBUG_PROCEDURE_ON) THEN
    BEGIN
        OKL_DEBUG_PUB.LOG_DEBUG(L_LEVEL_PROCEDURE,L_MODULE,'Begin Debug OKLRTDTB.pls call Okl_Trns_Acc_Dstrs_Pub.update_trns_acc_dstrs ');
    END;
  END IF;
         Okl_Trns_Acc_Dstrs_Pub.update_trns_acc_dstrs(p_api_version     => l_api_version,
                                                      p_init_msg_list   => p_init_msg_list,
                                                      x_return_status   => x_return_status,
                                                      x_msg_count       => x_msg_count,
                                                      x_msg_data        => x_msg_data,
                                                      p_tabv_tbl        => l_tabv_tbl_in,
                                                      x_tabv_tbl        => l_tabv_tbl_out);
  IF(IS_DEBUG_PROCEDURE_ON) THEN
    BEGIN
        OKL_DEBUG_PUB.LOG_DEBUG(L_LEVEL_PROCEDURE,L_MODULE,'End Debug OKLRTDTB.pls call Okl_Trns_Acc_Dstrs_Pub.update_trns_acc_dstrs ');
    END;
  END IF;
-- End of wraper code generated automatically by Debug code generator for Okl_Trns_Acc_Dstrs_Pub.update_trns_acc_dstrs
   ELSE

        OKL_API.SET_MESSAGE(p_app_name     => g_app_name,
                            p_msg_name     => 'OKL_DIST_NOT_FOUND');

        x_return_status := OKL_API.G_RET_STS_ERROR;


   END IF;


EXCEPTION

  WHEN OTHERS THEN

      OKL_API.SET_MESSAGE(p_app_name      => g_app_name
                         ,p_msg_name      => g_unexpected_error
                         ,p_token1        => g_sqlcode_token
                         ,p_token1_value  => SQLCODE
                         ,p_token2        => g_sqlerrm_token
                         ,p_token2_value  => SQLERRM);

      x_return_status := OKL_API.G_RET_STS_UNEXP_ERROR;


END UPDATE_POST_TO_GL;




PROCEDURE  DELETE_DIST_AE(p_flag          IN VARCHAR2,
                          p_source_id     IN NUMBER,
                          p_source_table  IN VARCHAR2,
                          x_return_status OUT NOCOPY VARCHAR2)

IS

  CURSOR dist_csr(v_source_id  NUMBER, v_source_table VARCHAR2) IS
  SELECT ID
  FROM OKL_TRNS_ACC_DSTRS
  WHERE source_id    = v_source_id
  AND   source_table = v_source_table;


  l_dist_tbl      TABV_TBL_TYPE;
  i               NUMBER := 0;
  j               NUMBER := 0;
  l_api_version   NUMBER := 1.0;
  l_init_msg_list VARCHAR2(1) := OKL_API.G_FALSE;
  l_msg_count     NUMBER := 0;
  l_msg_data      VARCHAR2(2000);
  l_id            NUMBER;


BEGIN

  x_return_status := OKL_API.G_RET_STS_SUCCESS;

  IF (p_flag = 'DIST') THEN

      OPEN dist_csr(p_source_id, p_source_table);
      LOOP
        FETCH dist_csr INTO  l_id;
        EXIT WHEN dist_csr%NOTFOUND;
        i := i + 1;
        l_dist_tbl(i).ID := l_id;
      END LOOP;

      CLOSE dist_csr;

-- Start of wraper code generated automatically by Debug code generator for Okl_Trns_Acc_Dstrs_Pub.delete_trns_acc_dstrs
  IF(L_DEBUG_ENABLED='Y') THEN
    L_LEVEL_PROCEDURE :=FND_LOG.LEVEL_PROCEDURE;
    IS_DEBUG_PROCEDURE_ON := OKL_DEBUG_PUB.Check_Log_On(L_MODULE, L_LEVEL_PROCEDURE);
  END IF;
  IF(IS_DEBUG_PROCEDURE_ON) THEN
    BEGIN
        OKL_DEBUG_PUB.LOG_DEBUG(L_LEVEL_PROCEDURE,L_MODULE,'Begin Debug OKLRTDTB.pls call Okl_Trns_Acc_Dstrs_Pub.delete_trns_acc_dstrs ');
    END;
  END IF;
      Okl_Trns_Acc_Dstrs_Pub.delete_trns_acc_dstrs(p_api_version     => l_api_version
                                                  ,p_init_msg_list   => l_init_msg_list
                                                  ,x_return_status   => x_return_status
                                                  ,x_msg_count       => l_msg_count
                                                  ,x_msg_data        => l_msg_data
                                                  ,p_tabv_tbl        => l_dist_tbl);
  IF(IS_DEBUG_PROCEDURE_ON) THEN
    BEGIN
        OKL_DEBUG_PUB.LOG_DEBUG(L_LEVEL_PROCEDURE,L_MODULE,'End Debug OKLRTDTB.pls call Okl_Trns_Acc_Dstrs_Pub.delete_trns_acc_dstrs ');
    END;
  END IF;
-- End of wraper code generated automatically by Debug code generator for Okl_Trns_Acc_Dstrs_Pub.delete_trns_acc_dstrs

  END IF;

END DELETE_DIST_AE;



PROCEDURE   VALIDATE_PARAMS(p_dist_info_Rec      IN   DIST_INFO_REC_TYPE,
                            x_return_status      OUT  NOCOPY VARCHAR2)
IS


  -- redundant code .. not used.
  --CURSOR sobv_csr IS
  --SELECT currency_code
  --FROM GL_LEDGERS_PUBLIC_V
  --WHERE LEDGER_ID = Okl_Accounting_Util.get_set_of_books_id;

  l_validate_holder VARCHAR2(1) := OKL_API.G_MISS_CHAR;
  l_functional_curr  OKL_TRNS_ACC_DSTRS.CURRENCY_CODE%TYPE;
  l_gl_date DATE;


BEGIN

   x_return_status  := OKL_API.G_RET_STS_SUCCESS;

   -- get the functional currency based on the representation. MG uptake
   IF nvl(g_representation_type, 'PRIMARY') = 'PRIMARY' THEN
      l_functional_curr := Okl_Accounting_Util.GET_FUNC_CURR_CODE;
   ELSE
      l_functional_curr := Okl_Accounting_Util.GET_FUNC_CURR_CODE(g_ledger_id);
   END IF;

    -- Check if the source ID is null
   IF (P_dist_info_REC.SOURCE_ID = OKL_API.G_MISS_NUM) OR
      (P_dist_info_REC.SOURCE_ID IS NULL) THEN
       OKL_API.set_message(G_APP_NAME, G_REQUIRED_VALUE,G_COL_NAME_TOKEN,'SOURCE_ID');
       RAISE OKL_API.G_EXCEPTION_ERROR;
   END IF;

   -- Check if the source table is null
   IF (P_dist_info_REC.SOURCE_TABLE = OKL_API.G_MISS_CHAR) OR
      (P_dist_info_REC.SOURCE_TABLE IS NULL) THEN
       OKL_API.set_message(G_APP_NAME, G_REQUIRED_VALUE,G_COL_NAME_TOKEN,'SOURCE_TABLE');
       RAISE OKL_API.G_EXCEPTION_ERROR;
   END IF;


-- Fixed bug 2815972 by Santonyr on 04-Aug-2003

/*
   -- Negative Amounts are not Allowed.
   IF (P_dist_info_REC.AMOUNT < 0) THEN
       OKL_API.SET_MESSAGE(p_app_name     => g_app_name,
                           p_msg_name     => 'OKL_INVALID_AMOUNT');
       RAISE OKL_API.G_EXCEPTION_ERROR;
   END IF;
*/


   -- Check if the source table is valid
   l_validate_holder :=
     Okl_Accounting_Util.VALIDATE_SOURCE_ID_TABLE(p_source_id    => P_dist_info_REC.source_id,
                                                  p_source_table => P_dist_info_REC.source_table);

   IF (l_validate_holder = OKL_API.G_FALSE) THEN
       OKL_API.SET_MESSAGE(p_app_name     => g_app_name,
                           p_msg_name     => 'OKL_INVALID_SOURCE_TBL_ID');
       RAISE OKL_API.G_EXCEPTION_ERROR;
   END IF;

   -- Check if the accounting date is null
   IF (P_dist_info_REC.ACCOUNTING_DATE = OKL_API.G_MISS_DATE) OR
      (P_dist_info_REC.ACCOUNTING_DATE IS NULL) THEN
       OKL_API.set_message(G_APP_NAME, G_REQUIRED_VALUE,G_COL_NAME_TOKEN,'ACCOUNTING_DATE');
       RAISE OKL_API.G_EXCEPTION_ERROR;

   ELSE
     -- Bug 7560071.
     -- Get the accounting date .. based on representation. MG uptake
     IF nvl(g_representation_type, 'PRIMARY') = 'PRIMARY' THEN
       l_gl_date := OKL_ACCOUNTING_UTIL.get_valid_gl_date(P_dist_info_REC.ACCOUNTING_DATE);
     ELSE
       l_gl_date := OKL_ACCOUNTING_UTIL.get_valid_gl_date(P_dist_info_REC.ACCOUNTING_DATE, g_ledger_id);
     END IF;

     IF l_gl_date IS NULL THEN
       OKL_API.SET_MESSAGE(p_app_name     => g_app_name,
                           p_msg_name     => 'OKL_INVALID_GL_DATE');
       RAISE OKL_API.G_EXCEPTION_ERROR;
     END IF;

     G_gl_date := l_gl_date;

   END IF;

   -- Check if the reversal flag is null
   IF (P_dist_info_REC.GL_REVERSAL_FLAG = OKL_API.G_MISS_CHAR) OR
      (P_dist_info_REC.GL_REVERSAL_FLAG IS NULL) THEN
       OKL_API.set_message(G_APP_NAME, G_REQUIRED_VALUE,G_COL_NAME_TOKEN,'REVERSAL_FLAG');
       RAISE OKL_API.G_EXCEPTION_ERROR;
   END IF;

   -- Check if the post to gl flag is null
   IF (P_dist_info_REC.POST_TO_GL = OKL_API.G_MISS_CHAR) OR
      (P_dist_info_REC.POST_TO_GL IS NULL) THEN
       OKL_API.set_message(G_APP_NAME, G_REQUIRED_VALUE,G_COL_NAME_TOKEN,'POST_TO_GL');
       RAISE OKL_API.G_EXCEPTION_ERROR;
   END IF;

   -- Check if the currency conversion factors are null if the trx currency and
   -- functional currency are not same.

   IF (p_dist_info_Rec.currency_code IS NOT NULL) AND
      (p_dist_info_rec.currency_code <> OKL_API.G_MISS_CHAR) THEN

       IF (p_dist_info_rec.currency_code <> l_functional_curr) THEN

          IF (P_dist_info_REC.currency_conversion_type = OKL_API.G_MISS_CHAR) OR
             (P_dist_info_REC.currency_conversion_type IS NULL) THEN
                OKL_API.set_message(G_APP_NAME, G_REQUIRED_VALUE,
   G_COL_NAME_TOKEN,'Currency Conversion Type');
                RAISE OKL_API.G_EXCEPTION_ERROR;
          END IF;

          IF (P_dist_info_REC.currency_conversion_date = OKL_API.G_MISS_DATE) OR
             (P_dist_info_REC.currency_conversion_DATE IS NULL) THEN
                OKL_API.set_message(G_APP_NAME, G_REQUIRED_VALUE,
                                   G_COL_NAME_TOKEN,'Currency Conversion Date');
                RAISE OKL_API.G_EXCEPTION_ERROR;
          END IF;

-- Added by Santonyr on 19-Nov-2002
-- Made currency rate mandatory for Multi-Currency

  IF (P_dist_info_rec.currency_conversion_rate = OKL_API.G_MISS_NUM) OR
             (P_dist_info_rec.currency_conversion_rate IS NULL) THEN
                OKL_API.set_message(G_APP_NAME, G_REQUIRED_VALUE,
                                   G_COL_NAME_TOKEN,'Currency Conversion Rate');
                RAISE OKL_API.G_EXCEPTION_ERROR;
          END IF;
       END IF;
   END IF;

EXCEPTION

  WHEN OKL_API.G_EXCEPTION_ERROR THEN
      x_return_status := OKL_API.G_RET_STS_ERROR;

-- gboomina Bug 4662173 start
  WHEN OTHERS THEN
         x_return_status := OKL_API.G_RET_STS_ERROR;

   END VALIDATE_PARAMS;


   --Added by gboomina on 14-Oct-2005
   --Bug 4662173 - Start of Changes
   PROCEDURE   VALIDATE_PARAMS(p_dist_info_tbl      IN   DIST_INFO_TBL_TYPE,
                                    p_functional_curr    IN   OKL_TRNS_ACC_DSTRS.CURRENCY_CODE%TYPE,
                                    x_return_status      OUT  NOCOPY VARCHAR2)
   IS

     l_validate_holder VARCHAR2(1) := OKL_API.G_MISS_CHAR;
     l_functional_curr  OKL_TRNS_ACC_DSTRS.CURRENCY_CODE%TYPE := p_functional_curr;
     l_gl_date DATE;
     l_date    DATE;
     l_first_rec  CHAR := 'T';
   BEGIN

      x_return_status  := OKL_API.G_RET_STS_SUCCESS;

      FOR i in p_dist_info_tbl.FIRST .. p_dist_info_tbl.LAST LOOP
         -- Check if the source ID is null
         IF (P_dist_info_tbl(i).SOURCE_ID = OKL_API.G_MISS_NUM) OR
           (P_dist_info_tbl(i).SOURCE_ID IS NULL) THEN
             OKL_API.set_message(G_APP_NAME, G_REQUIRED_VALUE,G_COL_NAME_TOKEN,'SOURCE_ID');
             RAISE OKL_API.G_EXCEPTION_ERROR;
         END IF;

         -- Check if the source table is null
         IF (p_dist_info_tbl(i).SOURCE_TABLE = OKL_API.G_MISS_CHAR) OR
            (p_dist_info_tbl(i).SOURCE_TABLE IS NULL) THEN
             OKL_API.set_message(G_APP_NAME, G_REQUIRED_VALUE,G_COL_NAME_TOKEN,'SOURCE_TABLE');
             RAISE OKL_API.G_EXCEPTION_ERROR;
         END IF;

         -- Check if the accounting date is null
         IF (p_dist_info_tbl(i).ACCOUNTING_DATE = OKL_API.G_MISS_DATE) OR
            (p_dist_info_tbl(i).ACCOUNTING_DATE IS NULL) THEN
            OKL_API.set_message(G_APP_NAME, G_REQUIRED_VALUE,G_COL_NAME_TOKEN,'ACCOUNTING_DATE');
            RAISE OKL_API.G_EXCEPTION_ERROR;
         ELSE
		   -- get the valida gl date based on the representation .. MG Uptake.bug 7560071
           --IF (l_first_rec = 'T') THEN -- bug 7560071
		   IF i = p_dist_info_tbl.FIRST then
              l_date := P_dist_info_tbl(i).ACCOUNTING_DATE;
              l_gl_date := OKL_ACCOUNTING_UTIL.get_valid_gl_date(p_dist_info_tbl(i).ACCOUNTING_DATE, g_ledger_id);
              IF l_gl_date IS NULL THEN
                  OKL_API.SET_MESSAGE(p_app_name     => g_app_name,
                                      p_msg_name     => 'OKL_INVALID_GL_DATE');
                  RAISE OKL_API.G_EXCEPTION_ERROR;
              END IF;
              --l_first_rec := 'F'; -- bug 7560071
           END IF;

           IF  (l_date <> p_dist_info_tbl(i).ACCOUNTING_DATE) THEN
              l_gl_date := OKL_ACCOUNTING_UTIL.get_valid_gl_date(p_dist_info_tbl(i).ACCOUNTING_DATE, g_ledger_id);

              IF l_gl_date IS NULL THEN
                  OKL_API.SET_MESSAGE(p_app_name     => g_app_name,
                                      p_msg_name     => 'OKL_INVALID_GL_DATE');
                  RAISE OKL_API.G_EXCEPTION_ERROR;
              END IF;
           END IF;

           G_gl_date := l_gl_date;

         END IF;

         -- Check if the reversal flag is null
         IF (p_dist_info_tbl(i).GL_REVERSAL_FLAG = OKL_API.G_MISS_CHAR) OR
            (p_dist_info_tbl(i).GL_REVERSAL_FLAG IS NULL) THEN
            OKL_API.set_message(G_APP_NAME, G_REQUIRED_VALUE,G_COL_NAME_TOKEN,'REVERSAL_FLAG');
            RAISE OKL_API.G_EXCEPTION_ERROR;
         END IF;

         -- Check if the post to gl flag is null
         IF (p_dist_info_tbl(i).POST_TO_GL = OKL_API.G_MISS_CHAR) OR
            (p_dist_info_tbl(i).POST_TO_GL IS NULL) THEN
             OKL_API.set_message(G_APP_NAME, G_REQUIRED_VALUE,G_COL_NAME_TOKEN,'POST_TO_GL');
             RAISE OKL_API.G_EXCEPTION_ERROR;
         END IF;

         -- Check if the currency conversion factors are null if the trx currency and
         -- functional currency are not same.

         IF (p_dist_info_tbl(i).currency_code IS NOT NULL) AND
            (p_dist_info_tbl(i).currency_code <> OKL_API.G_MISS_CHAR) THEN

            IF (p_dist_info_tbl(i).currency_code <> l_functional_curr) THEN

               IF (p_dist_info_tbl(i).currency_conversion_type = OKL_API.G_MISS_CHAR) OR
                  (p_dist_info_tbl(i).currency_conversion_type IS NULL) THEN
                     OKL_API.set_message(G_APP_NAME, G_REQUIRED_VALUE,
                                        G_COL_NAME_TOKEN,'Currency Conversion Type');
                     RAISE OKL_API.G_EXCEPTION_ERROR;
               END IF;

               IF (p_dist_info_tbl(i).currency_conversion_date = OKL_API.G_MISS_DATE) OR
                  (p_dist_info_tbl(i).currency_conversion_DATE IS NULL) THEN
                     OKL_API.set_message(G_APP_NAME, G_REQUIRED_VALUE,
                                         G_COL_NAME_TOKEN,'Currency Conversion Date');
                     RAISE OKL_API.G_EXCEPTION_ERROR;
               END IF;

               -- Added by Santonyr on 19-Nov-2002
               -- Made currency rate mandatory for Multi-Currency

                  IF (p_dist_info_tbl(i).currency_conversion_rate = OKL_API.G_MISS_NUM) OR
                 (p_dist_info_tbl(i).currency_conversion_rate IS NULL) THEN
                   OKL_API.set_message(G_APP_NAME, G_REQUIRED_VALUE,
                                      G_COL_NAME_TOKEN,'Currency Conversion Rate');
                   RAISE OKL_API.G_EXCEPTION_ERROR;
              END IF;
           END IF;
        END IF;
      END LOOP;

   EXCEPTION

     WHEN OKL_API.G_EXCEPTION_ERROR THEN
         x_return_status := OKL_API.G_RET_STS_ERROR;

-- gboomina Bug 4662173 end

END VALIDATE_PARAMS;

--gboomina Bug 4662173 start
PROCEDURE COPY_TEMPLATE_TBL(p_temp_rec           IN AVLV_REC_TYPE,
                               x_template_rec       OUT NOCOPY AVLB_REC_TYPE,
                               x_return_status      OUT NOCOPY VARCHAR2)
   IS

     BEGIN
       x_return_status := OKL_API.G_RET_STS_SUCCESS;
       x_template_rec.id                    := p_temp_rec.id;
       x_template_rec.object_version_number := p_temp_rec.object_version_number;
       x_template_rec.try_id                := p_temp_rec.try_id;
       x_template_rec.aes_id                := p_temp_rec.aes_id;
       x_template_rec.sty_id                := p_temp_rec.sty_id;
       x_template_rec.fma_id                := p_temp_rec.fma_id;
       x_template_rec.set_of_books_id       := p_temp_rec.set_of_books_id;
       x_template_rec.fac_code              := p_temp_rec.fac_code;
       x_template_rec.syt_code              := p_temp_rec.syt_code;
       x_template_rec.post_to_gl            := p_temp_rec.post_to_gl;
       x_template_rec.advance_arrears       := p_temp_rec.advance_arrears;
       x_template_rec.memo_yn               := p_temp_rec.memo_yn;
       x_template_rec.prior_year_yn         := p_temp_rec.prior_year_yn;
       x_template_rec.name                  := p_temp_rec.name;
       x_template_rec.description           := p_temp_rec.description;
       x_template_rec.version               := p_temp_rec.version;
       x_template_rec.factoring_synd_flag   := p_temp_rec.factoring_synd_flag;
       x_template_rec.start_date            := p_temp_rec.start_date;
       x_template_rec.end_date              := p_temp_rec.end_date;
       x_template_rec.accrual_yn            := p_temp_rec.accrual_yn;
       x_template_rec.attribute_category    := p_temp_rec.attribute_category;
       x_template_rec.attribute1            := p_temp_rec.attribute1;
       x_template_rec.attribute2            := p_temp_rec.attribute2;
       x_template_rec.attribute3            := p_temp_rec.attribute3;
       x_template_rec.attribute4            := p_temp_rec.attribute4;
       x_template_rec.attribute5            := p_temp_rec.attribute5;
       x_template_rec.attribute6            := p_temp_rec.attribute6;
       x_template_rec.attribute7            := p_temp_rec.attribute7;
       x_template_rec.attribute8            := p_temp_rec.attribute8;
       x_template_rec.attribute9            := p_temp_rec.attribute9;
       x_template_rec.attribute10           := p_temp_rec.attribute10;
       x_template_rec.attribute11           := p_temp_rec.attribute11;
       x_template_rec.attribute12           := p_temp_rec.attribute12;
       x_template_rec.attribute13           := p_temp_rec.attribute13;
       x_template_rec.attribute14           := p_temp_rec.attribute14;
       x_template_rec.attribute15           := p_temp_rec.attribute15;
       x_template_rec.org_id                := p_temp_rec.org_id;
       x_template_rec.created_by            := p_temp_rec.created_by;
       x_template_rec.creation_date         := p_temp_rec.creation_date;
       x_template_rec.last_updated_by       := p_temp_rec.last_updated_by;
       x_template_rec.last_update_date      := p_temp_rec.last_update_date;
       x_template_rec.last_update_login     := p_temp_rec.last_update_login;
       x_template_rec.inv_code                          := p_temp_rec.inv_code;
     EXCEPTION
      WHEN OTHERS THEN
         x_return_status := OKL_API.G_RET_STS_UNEXP_ERROR;
         OKL_API.SET_MESSAGE(p_app_name      => g_app_name
                            ,p_msg_name      => g_unexpected_error
                            ,p_token1        => g_sqlcode_token
                            ,p_token1_value  => SQLCODE
                            ,p_token2        => g_sqlerrm_token
                            ,p_token2_value  => SQLERRM);
     END COPY_TEMPLATE_TBL;

   --Method that obtains the acc_Gen_table details for a particular source_id
   PROCEDURE GET_ACC_GEN_TBL( p_source_id           IN NUMBER,
                              p_gen_table           IN acc_gen_tbl,
                              x_acc_gen_tbl_ret     OUT NOCOPY acc_gen_primary_key)
   IS
     acc_gen_tbl_count     NUMBER := 0;
     l_source_id           NUMBER := p_source_id;
     BEGIN
       FOR i IN p_gen_table.FIRST ..p_gen_table.LAST LOOP
         IF p_gen_table(i).source_id = l_source_id THEN
           x_acc_gen_tbl_ret(acc_gen_tbl_count).source_table := p_gen_table(i).source_table;
           x_acc_gen_tbl_ret(acc_gen_tbl_count).primary_key_column := p_gen_table(i).primary_key_column;
           acc_gen_tbl_count := acc_gen_tbl_count + 1;
         END IF;
       END LOOP;
     END GET_ACC_GEN_TBL;

   --Method that obtains the acc_Gen_table details for a particular source_id
   PROCEDURE GET_ACC_GEN_TBL( p_source_id           IN NUMBER,
                              p_gen_table           IN ACC_GEN_TBL_TYPE,
                              x_acc_gen_tbl_ret     OUT NOCOPY acc_gen_primary_key)
   IS
     l_source_id           NUMBER := p_source_id;
     BEGIN
       FOR i IN p_gen_table.FIRST ..p_gen_table.LAST LOOP
         IF p_gen_table(i).source_id = l_source_id THEN
           x_acc_gen_tbl_ret := p_gen_table(i).acc_gen_key_tbl;
         END IF;
       END LOOP;
     END GET_ACC_GEN_TBL;

   --Method that obtains the acc_Gen_table details for a particular source_id
   PROCEDURE GET_CONTEXT_VAL(p_source_id      IN NUMBER
                             ,p_ctxt_tbl      IN ctxt_tbl_type
                             ,x_ctxt_val_tbl  OUT NOCOPY ctxt_val_tbl_type)
   IS
   l_source_id           NUMBER := p_source_id;
   BEGIN
     IF (p_ctxt_tbl.count > 0 ) THEN
       FOR i IN p_ctxt_tbl.FIRST ..p_ctxt_tbl.LAST LOOP
         IF p_ctxt_tbl(i).source_id = l_source_id THEN
           x_ctxt_val_tbl := p_ctxt_tbl(i).ctxt_val_tbl;
         END IF;
       END LOOP;
 END IF;
   END GET_CONTEXT_VAL;

   --Method that obtains the acc_Gen_table details for a particular index number value
   PROCEDURE GET_TEMPLATE_AMOUNT_TBL( p_parent_index_number IN NUMBER,
                              p_tmp_amount_table    IN tmp_bulk_amount_tbl_type,
                              x_tmp_amt_tbl_ret     OUT NOCOPY template_amount_tbl_type)
   IS
     tmp_amt_tbl_count     NUMBER := 1;
     l_parent_index_number NUMBER := p_parent_index_number;
     BEGIN
       FOR i in p_tmp_amount_table.FIRST..p_tmp_amount_table.LAST LOOP
         IF p_tmp_amount_table(i).parent_index_number = l_parent_index_number THEN
           x_tmp_amt_tbl_ret(tmp_amt_tbl_count).TEMPLATE_ID           := p_tmp_amount_table(i).TEMPLATE_ID;
           x_tmp_amt_tbl_ret(tmp_amt_tbl_count).AMOUNT                := p_tmp_amount_table(i).AMOUNT;
           x_tmp_amt_tbl_ret(tmp_amt_tbl_count).FORMULA_USED          := p_tmp_amount_table(i).FORMULA_USED;
           x_tmp_amt_tbl_ret(tmp_amt_tbl_count).STREAM_TYPE_ID        := p_tmp_amount_table(i).STREAM_TYPE_ID;
           tmp_amt_tbl_count := tmp_amt_tbl_count + 1;
         END IF;
       END LOOP;
     END GET_TEMPLATE_AMOUNT_TBL;

   PROCEDURE ACCUMULATE_ACCT_SOURCES
              (p_asev_tbl        IN asev_tbl_type,
               x_asev_full_tbl   IN OUT NOCOPY asev_tbl_type,
               x_return_status   OUT NOCOPY VARCHAR2)
     IS
      l_asev_tbl_count  NUMBER;
      l_return_status   VARCHAR2(1);
     BEGIN
       -- Intialize the return status
       l_return_status := OKL_API.G_RET_STS_SUCCESS;
       IF (x_asev_full_tbl.COUNT > 0) THEN
          l_asev_tbl_count := x_asev_full_tbl.LAST + 1;
       ELSE
          l_asev_tbl_count := 1;
       END IF;

       FOR i in p_asev_tbl.FIRST..p_asev_tbl.LAST LOOP
         x_asev_full_tbl(l_asev_tbl_count) := p_asev_tbl(i);
         l_asev_tbl_count := l_asev_tbl_count + 1;
       END LOOP;
       x_return_Status := l_return_status;
     END ACCUMULATE_ACCT_SOURCES;
     --Bug 4662173 - End of Changes

     --Added by kthiruva on 13-Feb-2007 for SLA Uptake
     --Bug 5707866 - Start of Changes
     --This procedure keeps appending the template_tbl being passed to the existing OUT paramater
     PROCEDURE GET_FINAL_TEMPLATE_TBL(p_template_tbl IN AVLV_OUT_TBL_TYPE
                                     ,x_template_tbl IN OUT NOCOPY AVLV_OUT_TBL_TYPE)
     IS
      i         NUMBER:= 0;
     BEGIN
       IF (x_template_tbl.COUNT = 0)
       THEN
         i := 0;
       ELSE
         i := x_template_tbl.COUNT;
       END IF;
       IF ( p_template_tbl.count > 0 ) THEN
         FOR j in p_template_tbl.FIRST..p_template_tbl.LAST
         LOOP
           x_template_tbl(i) := p_template_tbl(j);
           i := i + 1;
         END LOOP;
       END IF;
     END GET_FINAL_TEMPLATE_TBL;

     --This procedure keeps appending the amount_tbl being passed to the existing OUT paramater
     PROCEDURE GET_FINAL_AMOUNT_TBL(p_amount_tbl  IN AMOUNT_OUT_TBL_TYPE
                                   ,x_amount_tbl  IN OUT NOCOPY AMOUNT_OUT_TBL_TYPE)
     IS
      i         NUMBER:= 0;
     BEGIN
       IF (x_amount_tbl.COUNT = 0)
       THEN
         i := 0;
       ELSE
         i := x_amount_tbl.COUNT;
       END IF;
       IF (p_amount_tbl.count > 0) THEN
         FOR j in p_amount_tbl.FIRST..p_amount_tbl.LAST
         LOOP
           x_amount_tbl(i) := p_amount_tbl(j);
           i := i + 1;
         END LOOP;
       END IF;
     END GET_FINAL_AMOUNT_TBL;

     --This procedure keeps appending the tabv_tbl being passed to the existing OUT paramater
     PROCEDURE GET_FINAL_TABV_TBL(p_tabv_tbl   IN tabv_tbl_type
                                 ,x_tabv_tbl   IN OUT NOCOPY tabv_tbl_type)
     IS
      i         NUMBER:= 0;
     BEGIN
       IF (x_tabv_tbl.COUNT = 0)
       THEN
         i := 0;
       ELSE
         i := x_tabv_tbl.COUNT;
       END IF;
       IF (p_tabv_tbl.count > 0) THEN
         FOR j in p_tabv_tbl.FIRST..p_tabv_tbl.LAST
         LOOP
           x_tabv_tbl(i) := p_tabv_tbl(j);
           i := i + 1;
         END LOOP;
       END IF;
     END GET_FINAL_TABV_TBL;

     --This procedure returns the transaction lines that have evaluated to a non-zero amount
     PROCEDURE GET_LINE_ID_TBL(p_amount_tbl     IN AMOUNT_OUT_TBL_TYPE,
                               x_line_tbl       IN OUT NOCOPY ID_TBL_TYPE)
     IS
      l_amount         NUMBER := 0;
      l_count          NUMBER := 0;
     BEGIN
       IF (p_amount_tbl.count > 0) THEN
         FOR i in p_amount_tbl.FIRST..p_amount_tbl.LAST
         LOOP
           --Reinitialising l_amount every time
           l_amount := 0;
           IF (p_amount_tbl(i).amount_tbl.count > 0) THEN
           FOR j in p_amount_tbl(i).amount_tbl.FIRST..p_amount_tbl(i).amount_tbl.LAST
         LOOP
           l_amount := l_amount + p_amount_tbl(i).amount_tbl(j);
 END LOOP;
 --The transaction line evaluated to a non-zero amount. Adding the line to the out table
 IF (l_amount <> 0) THEN
   x_line_tbl(l_count) := p_amount_tbl(i).source_id;
               l_count := l_count +1;
 END IF;
   END IF;
         END LOOP;
       END IF;
     END GET_LINE_ID_TBL;

     --Procedure to ensure that the in parameters passed in the new AE engine call are valid
     --As the new signature accepts tables of all in parameters, the table count of all tables
     --should be identical
     PROCEDURE VALIDATE_IN_PARAMS(p_dist_info_tbl           IN DIST_INFO_TBL_TYPE
                                 ,p_tmpl_identify_tbl       IN TMPL_IDENTIFY_TBL_TYPE
                                 ,p_ctxt_val_tbl            IN ctxt_tbl_type
                                 ,p_acc_gen_primary_key_tbl IN acc_gen_tbl_type
         ,x_return_status           OUT NOCOPY VARCHAR2)
     IS
       l_validate    BOOLEAN;
 BEGIN
       x_return_status  := OKL_API.G_RET_STS_SUCCESS;
       IF(p_dist_info_tbl.count <> p_tmpl_identify_tbl.count)  THEN
          OKL_API.SET_MESSAGE(p_app_name     => g_app_name
                                                  ,p_msg_name     => 'OKL_AE_INCORRECT_PARAMS'
                                                  ,p_token1        => 'PARAMETER'
                                                  ,p_token1_value  => 'p_tmpl_identify_tbl'
                                                 ,p_token2        => 'COUNT'
                                                 ,p_token2_value  => p_dist_info_tbl.count);
           RAISE OKL_API.G_EXCEPTION_ERROR;
END IF;
IF (p_dist_info_tbl.count <> p_acc_gen_primary_key_tbl.count) THEN
           OKL_API.SET_MESSAGE(p_app_name     => g_app_name
                                                  ,p_msg_name     => 'OKL_AE_INCORRECT_PARAMS'
                                                  ,p_token1        => 'PARAMETER'
                                                  ,p_token1_value  => 'p_acc_gen_primary_key_tbl'
                                                  ,p_token2        => 'COUNT'
                                                 ,p_token2_value  => p_dist_info_tbl.count);
           RAISE OKL_API.G_EXCEPTION_ERROR;
END IF;
       IF not ((p_dist_info_tbl.count = p_ctxt_val_tbl.count) OR p_ctxt_val_tbl.count = 0) THEN
           OKL_API.SET_MESSAGE(p_app_name     => g_app_name
                                                  ,p_msg_name     => 'OKL_AE_INCORRECT_PARAMS_CTX'
                                                  ,p_token1        => 'PARAMETER'
                                                  ,p_token1_value  => 'p_ctxt_val_tbl'
                                                  ,p_token2        => 'COUNT'
                                                 ,p_token2_value  => p_dist_info_tbl.count);
          RAISE OKL_API.G_EXCEPTION_ERROR;
       END IF;

     EXCEPTION
       WHEN OKL_API.G_EXCEPTION_ERROR THEN
         x_return_status := OKL_API.G_RET_STS_ERROR;
       -- gboomina Bug 4662173 start
       WHEN OTHERS THEN
         x_return_status := OKL_API.G_RET_STS_ERROR;
     END VALIDATE_IN_PARAMS;
     --Bug 5707866 - End of Changes

   PROCEDURE CREATE_ACCOUNTING_DIST(p_api_version              IN       NUMBER,
                                      p_init_msg_list            IN       VARCHAR2,
                                      x_return_status            OUT      NOCOPY VARCHAR2,
                                      x_msg_count                OUT      NOCOPY NUMBER,
                                      x_msg_data                 OUT      NOCOPY VARCHAR2,
                                      p_tmpl_identify_rec        IN       TMPL_IDENTIFY_REC_TYPE,
                                      p_dist_info_rec            IN       DIST_INFO_REC_TYPE,
                                      p_ctxt_val_tbl             IN       CTXT_VAL_TBL_TYPE,
                                      p_acc_gen_primary_key_tbl  IN       acc_gen_primary_key,
                                      x_template_tbl             OUT      NOCOPY AVLV_TBL_TYPE,
                                      x_amount_tbl               OUT      NOCOPY AMOUNT_TBL_TYPE)


   IS

     l_check_status   NUMBER;
     i                NUMBER := 0;
     l_amount         NUMBER := 0;

     tmpl_rec         AVLV_REC_TYPE;
     l_tmpl_tbl       avlv_tbl_type;
     l_formula_name   OKL_FORMULAE_V.NAME%TYPE;
     l_functional_curr OKL_TRNS_ACC_DSTRS.CURRENCY_CODE%TYPE;
     l_return_status  VARCHAR2(1) := OKL_API.G_RET_STS_SUCCESS;

     l_api_name       VARCHAR2(30) := 'CREATE_ACCOUNTING_DIST';
     l_api_version    NUMBER := 1.0;

   -- Added by Santonyr on 30-Jul-2003 to fix the bug 2941805

     l_product_name  OKL_PRODUCTS.NAME%TYPE;
     l_trx_type_name OKL_TRX_TYPES_TL.NAME%TYPE;
     l_sty_type_name OKL_STRM_TYPE_TL.NAME%TYPE;

   -- Added by Santonyr on 12-Jul-2440 for the bug 3761026

     l_template_amount_tbl template_amount_tbl_type;



     CURSOR frml_csr(v_id NUMBER) IS
     SELECT name
     FROM okl_formulae_v
     WHERE id = v_id;

   -- Added by Santonyr on 30-Jul-2003 to fix the bug 2941805

     CURSOR prdt_csr (l_pdt_id OKL_PRODUCTS.ID%TYPE) IS
     SELECT name
     FROM okl_products
     WHERE id = l_pdt_id ;

     CURSOR trx_type_csr (l_trx_type_id OKL_TRX_TYPES_TL.ID%TYPE) IS
     SELECT name
     FROM okl_trx_types_tl
     WHERE id = l_trx_type_id ;

     CURSOR sty_type_csr (l_sty_type_id OKL_STRM_TYPE_TL.ID%TYPE) IS
     SELECT name
     FROM okl_strm_type_tl
     WHERE id = l_sty_type_id ;

     --Added by kthiruva on 06-Feb-2007 for SLA Uptake
     --Bug 5707866 - Start of Changes
     l_account_derivation     OKL_SYS_ACCT_OPTS.ACCOUNT_DERIVATION%TYPE;
     l_tcn_id                 NUMBER;
     l_init_msg_list         VARCHAR2(1) := OKL_API.G_FALSE;
     l_msg_count             NUMBER := 0;
     l_msg_data              VARCHAR2(2000);
     l_event_id              NUMBER;
     l_event_date            DATE;
     l_gl_short_name         GL_LEDGERS.SHORT_NAME%TYPE;
     l_tabv_tbl              tabv_tbl_type ;
     l_tabv_tbl_out          tabv_tbl_type ;
     x_tabv_tbl              tabv_tbl_type ;
     l_try_name              OKL_TRX_TYPES_TL.NAME%TYPE;
     l_tcnv_rec              okl_sla_acc_sources_pvt.tehv_rec_type;
     l_tclv_rec              okl_sla_acc_sources_pvt.telv_rec_type;
     l_tclv_tbl              okl_sla_acc_sources_pvt.telv_tbl_type;
     l_tabv_tbl_final        tabv_tbl_type;
     k                       NUMBER := 0;
     l_tehv_id               NUMBER;
 l_asev_rec              asev_rec_type;
 l_line_amount           NUMBER := 0;
     l_rxhv_rec              okl_sla_acc_sources_pvt.rxhv_rec_type;
     l_rxhv_adj_rec              okl_sla_acc_sources_pvt.rxhv_rec_type;
     l_rxlv_tbl              okl_sla_acc_sources_pvt.rxlv_tbl_type;
     l_rxlv_adj_tbl              okl_sla_acc_sources_pvt.rxlv_tbl_type;
     x_rxlv_tbl              okl_sla_acc_sources_pvt.rxlv_tbl_type;
     x_rxlv_adj_tbl              okl_sla_acc_sources_pvt.rxlv_tbl_type;
 l_rxlv_rec              okl_sla_acc_sources_pvt.rxlv_rec_type;
 l_rxlv_adj_rec              okl_sla_acc_sources_pvt.rxlv_rec_type;

     l_pxhv_rec              okl_sla_acc_sources_pvt.pxhv_rec_type;
     l_pxlv_tbl              okl_sla_acc_sources_pvt.pxlv_tbl_type;
     x_pxlv_tbl              okl_sla_acc_sources_pvt.pxlv_tbl_type;
 l_pxlv_rec              okl_sla_acc_sources_pvt.pxlv_rec_type;

     l_tai_id                NUMBER;
     l_adj_id                NUMBER;
     l_tap_id                NUMBER;

     CURSOR get_tcn_id_csr(p_source_id IN NUMBER)
     IS
     SELECT tcl.tcn_id
     FROM OKL_TXL_CNTRCT_LNS_ALL tcl
     WHERE tcl.id = p_source_id;


     CURSOR get_tai_id_csr(p_source_id IN NUMBER)
     IS
     SELECT TXL.TAI_ID
     FROM OKL_TXL_AR_INV_LNS_B TXL,
          OKL_TXD_AR_LN_DTLS_B TXD
     WHERE TXD.TIL_ID_DETAILS = TXL.ID
     AND TXD.ID = p_source_id;

 --Bug 6316320 dpsingh start
      CURSOR get_adj_id_csr(p_source_id IN NUMBER)
     IS
     SELECT ADJ_ID
     FROM OKL_TXL_ADJSTS_LNS_ALL_B
     WHERE ID = p_source_id;
   --Bug 6316320 dpsingh start

     CURSOR get_tai_details_csr (p_source_id NUMBER)
     IS
      SELECT    tai.id                 tai_id
                      ,tld.khr_id             khr_id
                     ,tld.kle_id             kle_id
                     ,tld.sty_id             sty_id
                     ,tai.try_id             try_id
                     ,tll.description        trans_line_description
       FROM     okl_trx_ar_invoices_b tai
               ,okl_txl_ar_inv_lns_b  til
               ,okl_txd_ar_ln_dtls_b  tld
               ,okl_txd_ar_ln_dtls_tl tll
      WHERE     tll.id = tld.id
        AND     tld.til_id_details = til.id
        AND     til.tai_id = tai.id
        AND     tld.id = p_source_id;

--Bug 6316320 dpsingh start
CURSOR get_adj_details_csr (p_source_id NUMBER)
     IS
      SELECT    adj.id                 adj_id
                     ,adjl.khr_id             khr_id
                     ,adjl.kle_id             kle_id
                     ,adjl.sty_id             sty_id
                     ,adj.try_id             try_id
       FROM     okl_trx_ar_adjsts_all_b adj
               ,okl_txl_adjsts_lns_all_b  adjl
      WHERE  adjl.adj_id = adj.id
        AND     adjl.id = p_source_id;
--Bug 6316320 dpsingh end

     CURSOR get_tap_id_csr(p_source_id NUMBER)
     IS
     SELECT tpl.tap_id
     FROM okl_txl_ap_inv_lns_b  tpl
     WHERE TPL.ID = p_source_id;

     CURSOR get_tap_details_csr (p_source_id NUMBER)
     IS
     SELECT    tpl.id                     tap_id
               ,tpl.khr_id                khr_id
               ,tpl.kle_id                kle_id
               ,tpl.sty_id                sty_id
               ,tap.try_id                try_id
               ,tap.vendor_invoice_number trans_number
               ,tll.description           trans_line_description
       FROM     okl_trx_ap_invoices_b tap
               ,okl_txl_ap_inv_lns_b  tpl
               ,okl_txl_ap_inv_lns_tl tll
      WHERE     tll.id = tpl.id
        AND     tap.id = tpl.tap_id
        AND     tpl.id = p_source_id;


     CURSOR get_gl_short_name_csr
     IS
     SELECT GL.SHORT_NAME
     FROM OKL_SYS_ACCT_OPTS SAO,
          GL_LEDGERS GL
     WHERE SAO.SET_OF_BOOKS_ID = GL.LEDGER_ID;

     CURSOR get_trx_type(p_try_id NUMBER)
     IS
     SELECT TRY.AEP_CODE
 FROM OKL_TRX_TYPES_B TRY
 WHERE TRY.ID = p_try_id;

     CURSOR dist_exists_csr(p_source_id NUMBER,
                            p_source_table VARCHAR2)
     IS
     SELECT 1
     FROM OKL_TRNS_ACC_DSTRS_ALL
     WHERE SOURCE_ID    = p_source_id
     AND SOURCE_TABLE = p_source_table;

     CURSOR get_ext_hdr_csr(p_source_id NUMBER)
     IS
     SELECT HEADER_EXTENSION_ID
     FROM OKL_TRX_EXTENSION_B
     WHERE SOURCE_ID = p_source_id;

     get_tai_details_rec    get_tai_details_csr%ROWTYPE;
     get_adj_details_rec    get_adj_details_csr%ROWTYPE;
     get_tap_details_rec    get_tap_details_csr%ROWTYPE;
     --Bug 5707866 - End of Changes

     -- get the set of books from the trx header .. MG uptake
     CURSOR get_ledger_id_csr(p_tcl_id IN NUMBER)
     IS
     SELECT set_of_books_id
	   FROM okl_trx_contracts hdr, okl_txl_cntrct_lns lns
      WHERE hdr.id = lns.tcn_id
        AND lns.id = p_tcl_id;

     l_ledger_id     NUMBER;

   BEGIN
      x_return_status := OKL_API.G_RET_STS_SUCCESS;

      l_return_status := OKL_API.START_ACTIVITY(l_api_name,
                                                G_PKG_NAME,
                                                p_init_msg_list,
                                                l_api_version,
                                                p_api_version,
                                                '_PVT',
                                                x_return_status);
      IF (l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
        RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
      ELSIF (l_return_status = OKL_API.G_RET_STS_ERROR) THEN
        RAISE OKL_API.G_EXCEPTION_ERROR;
      END IF;

	  -- get the representation attributes .. MG uptake
	  get_rep_attributes;

      l_ledger_id := NULL;

	  IF NVL(p_dist_info_rec.source_table, 'OKL_TXL_CNTRCT_LNS') = 'OKL_TXL_CNTRCT_LNS' THEN
	    OPEN get_ledger_id_csr(p_dist_info_rec.source_id);
	    FETCH get_ledger_id_csr INTO l_ledger_id;
	    CLOSE get_ledger_id_csr;
	  END IF;

	  IF l_ledger_id IS NOT NULL then
	    g_representation_type := g_ledger_tbl(l_ledger_id).rep_type;
	    g_ledger_id := l_ledger_id;
	  ELSE
	    g_representation_type := 'PRIMARY';
	    g_ledger_id := okl_accounting_util.get_set_of_books_id;
	  END IF;

      -- Get the functional currency .. based on representation. MG uptake
	  IF g_representation_type = 'PRIMARY' THEN
        l_functional_curr := okl_accounting_util.get_func_curr_code;
	  ELSE
        l_functional_curr := okl_accounting_util.get_func_curr_code(g_ledger_id);
	  END IF;


   -- Bug 3948354
   -- Set the global variable G_REV_REC_FLAG to the value passed by calling program

      G_REV_REC_FLAG := p_tmpl_identify_rec.REV_REC_FLAG;


   -- Validate the Parameters

      VALIDATE_PARAMS(p_dist_info_rec       => p_dist_info_rec,
                      x_return_status       => l_return_status);


      IF (l_return_status <> OKL_API.G_RET_STS_SUCCESS) THEN
          RAISE OKL_API.G_EXCEPTION_ERROR;
      END IF;

   -- Get the Templates from the given parameters

   --- Change the G_GL_DATE to p_dist_info_rec.accounting_date if we want to pass passed-date as GL Date

      --Added by kthiruva for SLA Uptake
      --Bug 5707866 - Start of Changes
      OPEN get_acct_derivation_csr;
      FETCH get_acct_derivation_csr INTO l_account_derivation;
      CLOSE get_acct_derivation_csr;

      --If account derivation is not found then raise an error and halt processing
      IF l_account_derivation IS NULL THEN
           OKL_API.SET_MESSAGE(p_app_name     => g_app_name
                               ,p_msg_name     => 'OKL_ACCT_DER_NOT_SET');
   RAISE OKL_API.G_EXCEPTION_ERROR;
  END IF;

  --Fetching the trasaction type.
  --For Drop 2, sources capture, event creation is being done only for OKL transaction types
  OPEN get_trx_type(p_tmpl_identify_rec.transaction_type_id);
      FETCH get_trx_type INTO l_try_name;
      CLOSE get_trx_type;

      --Only when the account derivation option is 'ATS'
  --Or if the account derivation option is 'AMB' and the transaction amount is not known
  --should the template information be fetched
      IF (l_account_derivation = 'ATS') OR
         ((l_account_derivation = 'AMB') AND ((p_dist_info_rec.AMOUNT IS NULL) OR (p_dist_info_rec.AMOUNT = OKL_API.G_MISS_NUM)))
      THEN
        GET_TEMPLATE_INFO(p_api_version        => l_api_version,
                        p_init_msg_list      => p_init_msg_list,
                        x_return_status      => l_return_status,
                        x_msg_count          => x_msg_count,
                        x_msg_data           => x_msg_data,
                        p_tmpl_identify_rec  => p_tmpl_identify_rec,
                        x_template_tbl       => l_tmpl_tbl,
                        p_validity_date      => G_GL_DATE);

        IF (l_return_status <> OKL_API.G_RET_STS_SUCCESS) THEN
          RAISE OKL_API.G_EXCEPTION_ERROR;
        END IF;

        -- Raise an error if template is not found.

        IF (l_tmpl_tbl.COUNT = 0) THEN

            -- Added by Santonyr on 30-Jul-2003 to fix the bug 2941805

            FOR prdt_rec IN prdt_csr (p_tmpl_identify_rec.product_id) LOOP
              l_product_name := prdt_rec.name;
            END LOOP;

            FOR trx_type_rec IN trx_type_csr (p_tmpl_identify_rec.transaction_type_id) LOOP
              l_trx_type_name := trx_type_rec.name;
            END LOOP;

            FOR sty_type_rec IN sty_type_csr (p_tmpl_identify_rec.stream_type_id) LOOP
              l_sty_type_name := sty_type_rec.name;
            END LOOP;

            OKL_API.SET_MESSAGE(p_app_name     => g_app_name
                               ,p_msg_name     => 'OKL_TMPL_NOT_FOUND'
                               ,p_token1        => 'PRODUCT'
                               ,p_token1_value  => l_product_name
                               ,p_token2        => 'TRANSACTION_TYPE'
                               ,p_token2_value  => l_trx_type_name
                               ,p_token3        => 'STREAM_TYPE'
                               ,p_token3_value  => NVL(l_sty_type_name,  ' ')
                               ,p_token4        => 'ACCOUNTING_DATE'
                               ,p_token4_value  => G_GL_DATE);


             RAISE OKL_API.G_EXCEPTION_ERROR;
        END IF;


        -- Check the Distribution Status and take appropriate Action
        l_check_status := CHECK_JOURNAL(p_source_id    =>  p_dist_info_rec.source_id,
                                        p_source_table =>  p_dist_info_rec.source_table);

        -- l_check_status = 1 denotes that the distributions in OKL exist, but journals have not yet been created in SLA
        -- l_check_status = 2 denotes that the distributions exist in OKL , and journals have been created in SLA


        IF (l_check_status = 1) THEN
           -- Delete from Distributions
           DELETE_DIST_AE(p_flag          => 'DIST',
                         p_source_id     => p_dist_info_rec.source_id,
                         p_source_table  => p_dist_info_rec.source_table,
                         x_return_status => l_return_status);

           IF (l_return_status <> OKL_API.G_RET_STS_SUCCESS) THEN
              RAISE OKL_API.G_EXCEPTION_ERROR;
           END IF;

           --The accounting event needs to be created only for the OKL transaction types
           IF l_try_name IN ('RECEIPT_APPLICATION','PRINCIPAL_ADJUSTMENT','UPFRONT_TAX','BOOKING','TERMINATION',
   'ASSET_DISPOSITION','ACCRUAL','GENERAL_LOSS_PROVISION','SPECIFIC_LOSS_PROVISION','REBOOK','EVERGREEN',
   'RELEASE','INVESTOR','SPLIT_ASSET')
           THEN

             --This accounting engine call has been made in an update mode i.e. the transaction line already existed
             --Thefore the accounting sources need to be recaptured while creating distributions
             --Fetching the transaction header id
             OPEN get_tcn_id_csr(p_dist_info_rec.source_id);
             FETCH get_tcn_id_csr INTO l_tcn_id;
             CLOSE get_tcn_id_csr;

             l_tcnv_rec.source_id := l_tcn_id;
             l_tcnv_rec.source_table := 'OKL_TRX_CONTRACTS';

     --Existing sources are being deleted.
             okl_sla_acc_sources_pvt.delete_trx_extension(
                              p_api_version               => l_api_version
                             ,p_init_msg_list             => l_init_msg_list
                             ,p_trans_hdr_rec             => l_tcnv_rec
                             ,x_trans_line_tbl            => l_tclv_tbl
                             ,x_return_status             => l_return_status
                             ,x_msg_count                 => l_msg_count
                             ,x_msg_data                  => l_msg_data
                             );

             IF (l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
               OKL_API.SET_MESSAGE(p_app_name     => g_app_name
                                  ,p_msg_name     => 'OKL_DEL_SOURCES_FAILED');
               RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
             ELSIF (l_return_status = OKL_API.G_RET_STS_ERROR) THEN
               OKL_API.SET_MESSAGE(p_app_name     => g_app_name
                                  ,p_msg_name     => 'OKL_DEL_SOURCES_FAILED');
               RAISE OKL_API.G_EXCEPTION_ERROR;
             END IF;

   ELSIF l_try_name IN ('BILLING','CREDIT_MEMO','ROLLOVER_BILLING','ROLLOVER_CREDITMEMO',
            'RELEASE_BILLING','RELEASE_CREDITMEMO') THEN
             --This accounting engine call has been made in an update mode i.e. the transaction line already existed
             --Thefore the accounting sources need to be recaptured while creating distributions
             --Fetching the transaction header id
             OPEN get_tai_id_csr(p_dist_info_rec.source_id);
             FETCH get_tai_id_csr INTO l_tai_id;
             CLOSE get_tai_id_csr;

             l_rxhv_rec.source_id := l_tai_id;
             l_rxhv_rec.source_table := 'OKL_TRX_AR_INVOICES_B';

     --Existing sources are being deleted.
             okl_sla_acc_sources_pvt.delete_ar_extension(
                              p_api_version               => l_api_version
                             ,p_init_msg_list             => l_init_msg_list
                             ,p_rxhv_rec                  => l_rxhv_rec
                             ,x_rxlv_tbl                  => x_rxlv_tbl
                             ,x_return_status             => l_return_status
                             ,x_msg_count                 => l_msg_count
                             ,x_msg_data                  => l_msg_data
                             );

             IF (l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
               OKL_API.SET_MESSAGE(p_app_name     => g_app_name
                                  ,p_msg_name     => 'OKL_DEL_SOURCES_FAILED');
               RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
             ELSIF (l_return_status = OKL_API.G_RET_STS_ERROR) THEN
               OKL_API.SET_MESSAGE(p_app_name     => g_app_name
                                  ,p_msg_name     => 'OKL_DEL_SOURCES_FAILED');
               RAISE OKL_API.G_EXCEPTION_ERROR;
             END IF;
 --Bug 6316320 dpsingh start
     ELSIF l_try_name IN ('BALANCE_WRITE_OFF' ,'ADJUSTMENTS') THEN
             --This accounting engine call has been made in an update mode i.e. the transaction line already existed
             --Thefore the accounting sources need to be recaptured while creating distributions
             --Fetching the transaction header id
             OPEN get_adj_id_csr(p_dist_info_rec.source_id);
             FETCH get_adj_id_csr INTO l_adj_id;
             CLOSE get_adj_id_csr;

             l_rxhv_adj_rec.source_id := l_adj_id;
             l_rxhv_adj_rec.source_table := 'OKL_TRX_AR_ADJSTS_B' ;

     --Existing sources are being deleted.
             okl_sla_acc_sources_pvt.delete_ar_extension(
                              p_api_version               => l_api_version
                             ,p_init_msg_list             => l_init_msg_list
                             ,p_rxhv_rec                  => l_rxhv_adj_rec
                             ,x_rxlv_tbl                  => x_rxlv_adj_tbl
                             ,x_return_status             => l_return_status
                             ,x_msg_count                 => l_msg_count
                             ,x_msg_data                  => l_msg_data
                             );

             IF (l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
               OKL_API.SET_MESSAGE(p_app_name     => g_app_name
                                  ,p_msg_name     => 'OKL_DEL_SOURCES_FAILED');
               RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
             ELSIF (l_return_status = OKL_API.G_RET_STS_ERROR) THEN
               OKL_API.SET_MESSAGE(p_app_name     => g_app_name
                                  ,p_msg_name     => 'OKL_DEL_SOURCES_FAILED');
               RAISE OKL_API.G_EXCEPTION_ERROR;
             END IF;
      --Bug 6316320 dpsingh end
           --Checking for AP transaction Types
   ELSIF l_try_name IN ('DISBURSEMENT','FUNDING','DEBIT_NOTE') THEN
             --This accounting engine call has been made in an update mode i.e. the transaction line already existed
             --Thefore the accounting sources need to be recaptured while creating distributions
             --Fetching the transaction header id
             OPEN get_tap_id_csr(p_dist_info_rec.source_id);
             FETCH get_tap_id_csr INTO l_tap_id;
             CLOSE get_tap_id_csr;

             l_pxhv_rec.source_id := l_tap_id;
             l_pxhv_rec.source_table := 'OKL_TRX_AP_INVOICES_B';

     --Existing sources are being deleted.
             okl_sla_acc_sources_pvt.delete_ap_extension(
                              p_api_version               => l_api_version
                             ,p_init_msg_list             => l_init_msg_list
                             ,p_pxhv_rec                  => l_pxhv_rec
                             ,x_pxlv_tbl                  => x_pxlv_tbl
                             ,x_return_status             => l_return_status
                             ,x_msg_count                 => l_msg_count
                             ,x_msg_data                  => l_msg_data
                             );

             IF (l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
               OKL_API.SET_MESSAGE(p_app_name     => g_app_name
                                  ,p_msg_name     => 'OKL_DEL_SOURCES_FAILED');
               RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
             ELSIF (l_return_status = OKL_API.G_RET_STS_ERROR) THEN
               OKL_API.SET_MESSAGE(p_app_name     => g_app_name
                                  ,p_msg_name     => 'OKL_DEL_SOURCES_FAILED');
               RAISE OKL_API.G_EXCEPTION_ERROR;
             END IF;

           END IF;-- Check for transaction type
        END IF;

        IF (l_check_status = 2) THEN
           OKL_API.SET_MESSAGE(p_app_name     => g_app_name,
                               p_msg_name     => 'OKL_AE_GONE_TO_SLA');
           RAISE OKL_API.G_EXCEPTION_ERROR;
        END IF;


        FOR j IN 1..l_tmpl_tbl.COUNT
        LOOP

           tmpl_rec := l_tmpl_tbl(j);

          -- Added by Santonyr on 12-Jul-2440 for the bug 3761026

           l_template_amount_tbl(j).template_id := tmpl_rec.id;
           l_template_amount_tbl(j).stream_type_id := tmpl_rec.sty_id;


           IF (p_dist_info_rec.AMOUNT IS NULL) OR
              (p_dist_info_rec.AMOUNT = OKL_API.G_MISS_NUM) THEN

             -- If the amount is null calculate the amount using formula engine

             IF (tmpl_rec.FMA_ID IS NULL) OR
                (tmpl_rec.FMA_ID = OKL_API.G_MISS_NUM) THEN
                 -- If the formula is not found associated with template
                 OKL_API.SET_MESSAGE(p_app_name     => g_app_name,
                                     p_msg_name     => 'OKL_FMA_NOT_PRESENT',
                                     p_token1       => 'TEMPLATE_NAME',
                                     p_token1_value => tmpl_rec.NAME);
                 RAISE OKL_API.G_EXCEPTION_ERROR;
             END IF;

             OPEN frml_csr(tmpl_rec.fma_id);
             FETCH frml_csr INTO l_formula_name;
             CLOSE frml_csr;

             -- Execute the formula using formula engine.

             EXECUTE_FORMULA(p_avlv_rec            => tmpl_rec,
                             p_contract_id         => p_dist_info_rec.contract_id,
                             p_contract_line_id    => p_dist_info_rec.contract_line_id,
                             p_ctxt_val_tbl        => p_ctxt_val_tbl,
                             x_return_status       => l_return_status,
                             x_amount              => l_amount );

             IF (l_return_status <> OKL_API.G_RET_STS_SUCCESS) THEN
                  OKL_API.SET_MESSAGE(p_app_name     => g_app_name,
                                      p_msg_name     => 'OKL_FRML_EXE_FAILED',
                                      p_token1       => 'FORMULA_NAME',
                                      p_token1_value => l_formula_name);

             END IF;

             IF (l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
                 RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
             ELSIF (l_return_status = OKL_API.G_RET_STS_ERROR) THEN
                 RAISE OKL_API.G_EXCEPTION_ERROR;
             END IF;

             -- Added by Santonyr on 12-Jul-2440 for the bug 3761026
             l_template_amount_tbl(j).formula_used := 'Y';

           ELSE -- If the amount is passed from the caller (amount is not null).

             l_amount  := p_dist_info_rec.AMOUNT;

             -- Added by Santonyr on 12-Jul-2440 for the bug 3761026
             l_template_amount_tbl(j).formula_used := 'N';

           END IF;  -- End If for (p_dist_info_rec.AMOUNT IS NULL)

           -- If amount passes is Zero or Amount got from formula is zero then a
           -- message should be displayed.

           IF (l_amount = 0) THEN
              OKL_API.SET_MESSAGE(p_app_name     => g_app_name,
                                  p_msg_name     => 'OKL_FRML_RET_ZERO_AMT',
                                  p_token1       => 'TEMPLATE_NAME',
                                  p_token1_value => tmpl_rec.NAME);

              -- Santonyr on 14-Jul-2003 Fixed bug 3048686
              --     RAISE OKL_API.G_EXCEPTION_ERROR;

           END IF;

           x_template_tbl(j)              := tmpl_rec;

           --- Changed by Kanti. Bug 3125787
           x_amount_tbl(j)                := Okl_Accounting_Util.ROUND_AMOUNT(p_amount        => l_amount,
                                                                             p_currency_code => p_dist_info_rec.currency_code);

           -- Added by Santonyr on 12-Jul-2440 for the bug 3761026
           l_template_amount_tbl(j).amount := x_amount_tbl(j);

           -- Create the Distributions if Amount is Greater than Zero
           -- Fixed bug 2815972 by Santonyr on 04-Aug-2003

           IF (l_amount <> 0) THEN
             IF (l_account_derivation = 'ATS') THEN
               CREATE_DIST_RECS(p_avlv_rec           => tmpl_rec,
                                p_tmpl_identify_rec  => p_tmpl_identify_rec,
                                p_dist_info_rec      => p_dist_info_rec,
                                p_amount             => l_amount,
                                p_gen_table          => p_acc_gen_primary_key_tbl,
                                x_return_status      => l_return_status,
x_tabv_tbl           => l_tabv_tbl_out);

               IF (l_return_status <> OKL_API.G_RET_STS_SUCCESS) THEN
                   RAISE OKL_API.G_EXCEPTION_ERROR;
               END IF;

             ELSIF (l_account_derivation = 'AMB') THEN
               CREATE_DIST_RECS(--Bug 6127326 dpsingh start
                                p_avlv_rec           => tmpl_rec,
--Bug 6127326 dpsingh end
                        p_tmpl_identify_rec  => p_tmpl_identify_rec,
                                p_dist_info_rec      => p_dist_info_rec,
                                p_amount             => l_amount,
                                x_return_status      => l_return_status,
x_tabv_tbl           => l_tabv_tbl_out);

               IF (l_return_status <> OKL_API.G_RET_STS_SUCCESS) THEN
                   RAISE OKL_API.G_EXCEPTION_ERROR;
               END IF;
             END IF;
          END IF;  -- End If for (l_amount <> 0)

          --The distribution table returned by each iteration of l_tmpl_tbl.COUNT needs to be accumulated
          IF (l_tabv_tbl_final.COUNT = 0) THEN
              k := 0;
          ELSE
      k := l_tabv_tbl_final.COUNT;
          END IF;

          IF l_tabv_tbl_out.COUNT > 0 THEN
            FOR i in l_tabv_tbl_out.FIRST..l_tabv_tbl_out.LAST
            LOOP
              l_tabv_tbl_final(k).id := l_tabv_tbl_out(i).id;
              k := k + 1;
            END LOOP;
          END IF;

        END LOOP;  -- End LOOP for (l_tmpl_tbl.COUNT)
      --If the account derivation option is 'AMB' and the amount is known
      ELSE
        --Assinging the amount being passed in the rec to l_amount
        l_amount := p_dist_info_rec.amount;
        -- Check the Distribution Status and take appropriate Action
        l_check_status := CHECK_JOURNAL(p_source_id    =>  p_dist_info_rec.source_id,
                                        p_source_table =>  p_dist_info_rec.source_table);

        -- l_check_status = 1 denotes that the distributions in OKL exist, but journals have not yet been created in SLA
        -- l_check_status = 2 denotes that the distributions exist in OKL , and journals have been created in SLA


        IF (l_check_status = 1) THEN
           -- Delete from Distributions
           DELETE_DIST_AE(p_flag          => 'DIST',
                         p_source_id     => p_dist_info_rec.source_id,
                         p_source_table  => p_dist_info_rec.source_table,
                         x_return_status => l_return_status);

           IF (l_return_status <> OKL_API.G_RET_STS_SUCCESS) THEN
              RAISE OKL_API.G_EXCEPTION_ERROR;
           END IF;

           --The accounting event needs to be created only for the OKL transaction types
           IF l_try_name IN ('RECEIPT_APPLICATION','PRINCIPAL_ADJUSTMENT','UPFRONT_TAX','BOOKING','TERMINATION',
   'ASSET_DISPOSITION','ACCRUAL','GENERAL_LOSS_PROVISION','SPECIFIC_LOSS_PROVISION','REBOOK','EVERGREEN',
   'RELEASE','INVESTOR','SPLIT_ASSET')
           THEN

             --This accounting engine call has been made in an update mode i.e. the transaction line already existed
             --Thefore the accounting sources need to be recaptured while creating distributions

             --Fetching the transaction header id
             OPEN get_tcn_id_csr(p_dist_info_rec.source_id);
             FETCH get_tcn_id_csr INTO l_tcn_id;
             CLOSE get_tcn_id_csr;

             l_tcnv_rec.source_id := l_tcn_id;
             l_tcnv_rec.source_table := 'OKL_TRX_CONTRACTS';

     --Existing sources are being deleted.
             okl_sla_acc_sources_pvt.delete_trx_extension(
                              p_api_version               => l_api_version
                             ,p_init_msg_list             => l_init_msg_list
                             ,p_trans_hdr_rec             => l_tcnv_rec
                             ,x_trans_line_tbl            => l_tclv_tbl
                             ,x_return_status             => l_return_status
                             ,x_msg_count                 => l_msg_count
                             ,x_msg_data                  => l_msg_data
                             );

             IF (l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
               OKL_API.SET_MESSAGE(p_app_name     => g_app_name
                                  ,p_msg_name     => 'OKL_DEL_SOURCES_FAILED');
               RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
             ELSIF (l_return_status = OKL_API.G_RET_STS_ERROR) THEN
               OKL_API.SET_MESSAGE(p_app_name     => g_app_name
                                  ,p_msg_name     => 'OKL_DEL_SOURCES_FAILED');
               RAISE OKL_API.G_EXCEPTION_ERROR;
             END IF;

   ELSIF l_try_name IN ('BILLING','CREDIT_MEMO','ROLLOVER_BILLING','ROLLOVER_CREDITMEMO',
            'RELEASE_BILLING','RELEASE_CREDITMEMO') THEN
             --This accounting engine call has been made in an update mode i.e. the transaction line already existed
             --Thefore the accounting sources need to be recaptured while creating distributions
             --Fetching the transaction header id
             OPEN get_tai_id_csr(p_dist_info_rec.source_id);
             FETCH get_tai_id_csr INTO l_tai_id;
             CLOSE get_tai_id_csr;

             l_rxhv_rec.source_id := l_tai_id;
             l_rxhv_rec.source_table := 'OKL_TRX_AR_INVOICES_B';

     --Existing sources are being deleted.
             okl_sla_acc_sources_pvt.delete_ar_extension(
                              p_api_version               => l_api_version
                             ,p_init_msg_list             => l_init_msg_list
                             ,p_rxhv_rec                  => l_rxhv_rec
                             ,x_rxlv_tbl                  => x_rxlv_tbl
                             ,x_return_status             => l_return_status
                             ,x_msg_count                 => l_msg_count
                             ,x_msg_data                  => l_msg_data
                             );

             IF (l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
               OKL_API.SET_MESSAGE(p_app_name     => g_app_name
                                  ,p_msg_name     => 'OKL_DEL_SOURCES_FAILED');
               RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
             ELSIF (l_return_status = OKL_API.G_RET_STS_ERROR) THEN
               OKL_API.SET_MESSAGE(p_app_name     => g_app_name
                                  ,p_msg_name     => 'OKL_DEL_SOURCES_FAILED');
               RAISE OKL_API.G_EXCEPTION_ERROR;
             END IF;

     --Bug 6316320 dpsingh start
     ELSIF l_try_name IN ('BALANCE_WRITE_OFF' ,'ADJUSTMENTS') THEN
             --This accounting engine call has been made in an update mode i.e. the transaction line already existed
             --Thefore the accounting sources need to be recaptured while creating distributions
             --Fetching the transaction header id
             OPEN get_adj_id_csr(p_dist_info_rec.source_id);
             FETCH get_adj_id_csr INTO l_adj_id;
             CLOSE get_adj_id_csr;

             l_rxhv_adj_rec.source_id := l_adj_id;
             l_rxhv_adj_rec.source_table := 'OKL_TRX_AR_ADJSTS_B';

     --Existing sources are being deleted.
             okl_sla_acc_sources_pvt.delete_ar_extension(
                              p_api_version               => l_api_version
                             ,p_init_msg_list             => l_init_msg_list
                             ,p_rxhv_rec                  => l_rxhv_adj_rec
                             ,x_rxlv_tbl                  => x_rxlv_adj_tbl
                             ,x_return_status             => l_return_status
                             ,x_msg_count                 => l_msg_count
                             ,x_msg_data                  => l_msg_data
                             );

             IF (l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
               OKL_API.SET_MESSAGE(p_app_name     => g_app_name
                                  ,p_msg_name     => 'OKL_DEL_SOURCES_FAILED');
               RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
             ELSIF (l_return_status = OKL_API.G_RET_STS_ERROR) THEN
               OKL_API.SET_MESSAGE(p_app_name     => g_app_name
                                  ,p_msg_name     => 'OKL_DEL_SOURCES_FAILED');
               RAISE OKL_API.G_EXCEPTION_ERROR;
             END IF;
      --Bug 6316320 dpsingh end
           --Checking for AP transaction Types
   ELSIF l_try_name IN ('DISBURSEMENT','FUNDING','DEBIT_NOTE') THEN
             --This accounting engine call has been made in an update mode i.e. the transaction line already existed
             --Thefore the accounting sources need to be recaptured while creating distributions
             --Fetching the transaction header id
             OPEN get_tap_id_csr(p_dist_info_rec.source_id);
             FETCH get_tap_id_csr INTO l_tap_id;
             CLOSE get_tap_id_csr;

             l_pxhv_rec.source_id := l_tap_id;
             l_pxhv_rec.source_table := 'OKL_TRX_AP_INVOICES_B';

     --Existing sources are being deleted.
             okl_sla_acc_sources_pvt.delete_ap_extension(
                              p_api_version               => l_api_version
                             ,p_init_msg_list             => l_init_msg_list
                             ,p_pxhv_rec                  => l_pxhv_rec
                             ,x_pxlv_tbl                  => x_pxlv_tbl
                             ,x_return_status             => l_return_status
                             ,x_msg_count                 => l_msg_count
                             ,x_msg_data                  => l_msg_data
                             );

             IF (l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
               OKL_API.SET_MESSAGE(p_app_name     => g_app_name
                                  ,p_msg_name     => 'OKL_DEL_SOURCES_FAILED');
               RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
             ELSIF (l_return_status = OKL_API.G_RET_STS_ERROR) THEN
               OKL_API.SET_MESSAGE(p_app_name     => g_app_name
                                  ,p_msg_name     => 'OKL_DEL_SOURCES_FAILED');
               RAISE OKL_API.G_EXCEPTION_ERROR;
             END IF;
           END IF;-- Check for transaction type
        END IF;

        IF (l_check_status = 2) THEN
           OKL_API.SET_MESSAGE(p_app_name     => g_app_name,
                               p_msg_name     => 'OKL_AE_GONE_TO_SLA');
           RAISE OKL_API.G_EXCEPTION_ERROR;
        END IF;

        --Create the distribution
        CREATE_DIST_RECS(p_tmpl_identify_rec  => p_tmpl_identify_rec,
                         p_dist_info_rec      => p_dist_info_rec,
                         p_amount             => l_amount,
                         x_return_status      => l_return_status,
 x_tabv_tbl           => l_tabv_tbl_out);

--As there is only one distribution being created when account derivation is AMB,
--the amount is being assigned to x_amount_tbl(0)
        x_amount_tbl(0) := l_amount;

        IF (l_return_status <> OKL_API.G_RET_STS_SUCCESS) THEN
           RAISE OKL_API.G_EXCEPTION_ERROR;
        END IF;

        --In the case of AMB, there is only one iteration. However, the l_tabv_tbl_final needs to be populated
        -- in this case as well
        IF (l_tabv_tbl_final.COUNT = 0) THEN
           k := 0;
        ELSE
           k := l_tabv_tbl_final.COUNT;
        END IF;

        IF  l_tabv_tbl_out.count > 0 THEN
          FOR i in l_tabv_tbl_out.FIRST..l_tabv_tbl_out.LAST
          LOOP
            l_tabv_tbl_final(k).id := l_tabv_tbl_out(i).id;
            k := k + 1;
          END LOOP;
        END IF;
      END IF;

      --Checking to see if the transaction line amount has a non zero amount .Only if the transaction has atleast one
      --transaction line with a non-zero amount are sources captured and accounting event created.
      IF (x_amount_tbl.count > 0) THEN
        l_line_amount := 0;
        FOR i in x_amount_tbl.FIRST..x_amount_tbl.LAST
        LOOP
          l_line_amount := l_line_amount + x_amount_tbl(i);
        END LOOP;
      END IF;

      --The accounting event needs to be created only for the OKL transaction types
      IF l_try_name IN ('RECEIPT_APPLICATION','PRINCIPAL_ADJUSTMENT','UPFRONT_TAX','BOOKING','TERMINATION',
   'ASSET_DISPOSITION','ACCRUAL','GENERAL_LOSS_PROVISION','SPECIFIC_LOSS_PROVISION','REBOOK','EVERGREEN',
   'RELEASE','INVESTOR','SPLIT_ASSET') AND (l_line_amount >0)
      THEN
        --Fetch the GL Short Name.This will be sent as the valuation method
        --OPEN get_gl_short_name_csr;
        --FETCH get_gl_short_name_csr INTO l_gl_short_name;
        --CLOSE get_gl_short_name_csr;

	    -- get the correct short name based on representation.
	    l_gl_short_name := g_ledger_tbl(g_ledger_id).rep_code;

        IF l_gl_short_name IS NULL
        THEN
           OKL_API.SET_MESSAGE(p_app_name      => g_app_name
                              ,p_msg_name      => 'OKL_GL_NOT_SET_FOR_ORG');
           RAISE OKL_API.G_EXCEPTION_ERROR;
        END IF;

        --Making the call to populate_Acct_sources to retreive the l_asev_rec to be passed to
--populate_tcn_sources and populate_tcl_sources

        POPULATE_ACCT_SOURCES(p_api_version             => l_api_version,
                              p_init_msg_list           => l_init_msg_list,
                              x_return_status           => l_return_status,
                              x_msg_count               => l_msg_count,
                              x_msg_data                => l_msg_data,
                              p_tmpl_identify_rec       => p_tmpl_identify_rec,
                              p_dist_info_rec           => p_dist_info_rec,
                              p_acc_gen_primary_key_tbl => p_acc_gen_primary_key_tbl,
                      x_asev_rec                => l_asev_rec);

        IF (l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
           OKL_API.SET_MESSAGE(p_app_name     => g_app_name
                              ,p_msg_name     => 'OKL_SLA_SOURCES_FAILED');
           RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
        ELSIF (l_return_status = OKL_API.G_RET_STS_ERROR) THEN
           OKL_API.SET_MESSAGE(p_app_name     => g_app_name
                              ,p_msg_name     => 'OKL_SLA_SOURCES_FAILED');
           RAISE OKL_API.G_EXCEPTION_ERROR;
        END IF;

        OPEN get_tcn_id_csr(p_dist_info_rec.source_id);
        FETCH get_tcn_id_csr INTO l_tcn_id;
        CLOSE get_tcn_id_csr;

        OKL_XLA_EVENTS_PVT.event_exists(p_api_version        => l_api_version
                                       ,p_init_msg_list      => l_init_msg_list
                                       ,x_return_status      => l_return_status
                                       ,x_msg_count          => l_msg_count
                                       ,x_msg_data           => l_msg_data
                                       ,p_tcn_id             => l_tcn_id
                                       ,p_action_type        => 'CREATE'
                                       ,x_event_id           => l_event_id
                                       ,x_event_date         => l_event_date);

        IF (l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
           RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
        ELSIF (l_return_status = OKL_API.G_RET_STS_ERROR) THEN
           RAISE OKL_API.G_EXCEPTION_ERROR;
        END IF;

        IF l_event_id is null THEN

          l_event_id := OKL_XLA_EVENTS_PVT.create_event(p_api_version        => l_api_version
                                                       ,p_init_msg_list      => l_init_msg_list
                                                       ,x_return_status      => l_return_status
                                                       ,x_msg_count          => l_msg_count
                                                       ,x_msg_data           => l_msg_data
                                                       ,p_tcn_id             => l_tcn_id
                                                       ,p_gl_date            => G_gl_date
                                                       ,p_action_type        => 'CREATE'
                                                       ,p_representation_code   => l_gl_short_name
                                                       );

          IF (l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
             OKL_API.SET_MESSAGE(p_app_name     => g_app_name
                               ,p_msg_name     => 'OKL_CREATE_EVENT_FAILED');
             RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
          ELSIF (l_return_status = OKL_API.G_RET_STS_ERROR) THEN
             OKL_API.SET_MESSAGE(p_app_name     => g_app_name
                               ,p_msg_name     => 'OKL_CREATE_EVENT_FAILED');
             RAISE OKL_API.G_EXCEPTION_ERROR;
          END IF;

          l_tcnv_rec.source_id := l_tcn_id;
          l_tcnv_rec.source_table := 'OKL_TRX_CONTRACTS';

          --Make the call to capture account header source
          OKL_SLA_ACC_SOURCES_PVT.populate_tcn_sources(p_api_version   => l_api_version
                                              ,p_init_msg_list => l_init_msg_list
                                                      ,px_trans_hdr_rec => l_tcnv_rec
  ,p_acc_sources_rec => l_asev_rec
                                                      ,x_return_status => l_return_status
                                                      ,x_msg_count     => l_msg_count
                                                      ,x_msg_data      => l_msg_data
                                                      );

          IF (l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
             OKL_API.SET_MESSAGE(p_app_name     => g_app_name
                                ,p_msg_name     => 'OKL_SLA_SOURCES_FAILED');
             RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
          ELSIF (l_return_status = OKL_API.G_RET_STS_ERROR) THEN
             OKL_API.SET_MESSAGE(p_app_name     => g_app_name
                                ,p_msg_name     => 'OKL_SLA_SOURCES_FAILED');
             RAISE OKL_API.G_EXCEPTION_ERROR;
          END IF;

        END IF;

--Event id needs to be stamped for every distribution being created
        FOR i IN l_tabv_tbl_final.FIRST..l_tabv_tbl_final.LAST
    LOOP
      l_tabv_tbl(i).id                  := l_tabv_tbl_final(i).id;
      l_tabv_tbl(i).accounting_event_id := l_event_id;
          --Once the event is created successfully in XLA, posted_yn flag is set to Y
          l_tabv_tbl(i).posted_yn           := 'Y';
    END LOOP;

    --Update the distributions created with the Accounting Event Id
        OKL_TRNS_ACC_DSTRS_PUB.update_trns_acc_dstrs(p_api_version    => l_api_version
                                                    ,p_init_msg_list  => l_init_msg_list
                                                    ,x_return_status  => l_return_status
                                                    ,x_msg_count      => l_msg_count
                                                    ,x_msg_data       => l_msg_data
                                                    ,p_tabv_tbl       => l_tabv_tbl
                                                    ,x_tabv_tbl       => x_tabv_tbl
                                                    );

        IF (l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
          OKL_API.SET_MESSAGE(p_app_name     => g_app_name
                             ,p_msg_name     => 'OKL_UPD_DIST_FAILED');
          RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
        ELSIF (l_return_status = OKL_API.G_RET_STS_ERROR) THEN
          OKL_API.SET_MESSAGE(p_app_name     => g_app_name
                             ,p_msg_name     => 'OKL_UPD_DIST_FAILED');
          RAISE OKL_API.G_EXCEPTION_ERROR;
        END IF;

--Before making the call to capture line sources, check the following
--If l_check_status = 1, then the transaction line is in update mode and existing sources have been deleted
--Header and line Sources need to be captured for all the sources deleted
        IF (l_check_status = 1)
        THEN
          --Populate header sources
          l_tcnv_rec.source_id := l_tcn_id;
          l_tcnv_rec.source_table := 'OKL_TRX_CONTRACTS';

  --Make the call to capture account header source
          OKL_SLA_ACC_SOURCES_PVT.populate_tcn_sources(p_api_version   => l_api_version
                                              ,p_init_msg_list => l_init_msg_list
                                                      ,px_trans_hdr_rec => l_tcnv_rec
  ,p_acc_sources_rec => l_asev_rec
                                                      ,x_return_status => l_return_status
                                                      ,x_msg_count     => l_msg_count
                                                      ,x_msg_data      => l_msg_data
                                                      );

          IF (l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
             OKL_API.SET_MESSAGE(p_app_name     => g_app_name
                                ,p_msg_name     => 'OKL_SLA_SOURCES_FAILED');
             RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
          ELSIF (l_return_status = OKL_API.G_RET_STS_ERROR) THEN
             OKL_API.SET_MESSAGE(p_app_name     => g_app_name
                                ,p_msg_name     => 'OKL_SLA_SOURCES_FAILED');
             RAISE OKL_API.G_EXCEPTION_ERROR;
          END IF;

  --Making the call to populate line sources
  FOR i in l_tclv_tbl.FIRST..l_tclv_tbl.LAST
  LOOP
    --Make the call to Capture line sources
            l_tclv_rec.source_id := l_tclv_tbl(i).source_id;
            l_tclv_rec.source_table := l_tclv_tbl(i).source_table;
            l_tclv_rec.teh_id    := l_tcnv_rec.header_extension_id;

            --Make the call to capture account header source
            OKL_SLA_ACC_SOURCES_PVT.populate_tcl_sources(p_api_version   => l_api_version
                                                ,p_init_msg_list => l_init_msg_list
                                                        ,px_trans_line_rec => l_tclv_rec
,p_acc_sources_rec => l_asev_rec
                                                        ,x_return_status => l_return_status
                                                        ,x_msg_count     => l_msg_count
                                                        ,x_msg_data      => l_msg_data
                                                        );

            IF (l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
               OKL_API.SET_MESSAGE(p_app_name     => g_app_name
                                  ,p_msg_name     => 'OKL_SLA_SOURCES_FAILED');
               RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
            ELSIF (l_return_status = OKL_API.G_RET_STS_ERROR) THEN
               OKL_API.SET_MESSAGE(p_app_name     => g_app_name
                                  ,p_msg_name     => 'OKL_SLA_SOURCES_FAILED');
               RAISE OKL_API.G_EXCEPTION_ERROR;
            END IF;
  END LOOP;
        END IF;
        --Line sources need to be captured for the current line
        --Execute the cursor to fetch the transaction extension header id to pass to the call to populate_tcl_sources
        OPEN get_ext_hdr_csr(p_source_id => l_tcn_id);
        FETCH get_ext_hdr_csr INTO l_tehv_id;
        CLOSE get_ext_hdr_csr;

        --Make the call to Capture line sources
        l_tclv_rec.source_id := p_dist_info_rec.source_id;
        l_tclv_rec.source_table := 'OKL_TXL_CNTRCT_LNS';
        l_tclv_rec.teh_id := l_tehv_id;

        --Make the call to capture account header source
        OKL_SLA_ACC_SOURCES_PVT.populate_tcl_sources(p_api_version   => l_api_version
                                              ,p_init_msg_list => l_init_msg_list
                                                      ,px_trans_line_rec => l_tclv_rec
    ,p_acc_sources_rec => l_asev_rec
                                                      ,x_return_status => l_return_status
                                                      ,x_msg_count     => l_msg_count
                                                      ,x_msg_data      => l_msg_data
                                                      );

        IF (l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
             OKL_API.SET_MESSAGE(p_app_name     => g_app_name
                                ,p_msg_name     => 'OKL_SLA_SOURCES_FAILED');
             RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
        ELSIF (l_return_status = OKL_API.G_RET_STS_ERROR) THEN
             OKL_API.SET_MESSAGE(p_app_name     => g_app_name
                                ,p_msg_name     => 'OKL_SLA_SOURCES_FAILED');
             RAISE OKL_API.G_EXCEPTION_ERROR;
        END IF;
      --If the transaction is an AR transaction, then sources should be captured if the transaction line amount
  --is non-zero. However event creation for the transaction is not done from OKL

      ELSIF l_try_name IN ('BILLING','CREDIT_MEMO','ROLLOVER_BILLING','ROLLOVER_CREDITMEMO',
           'RELEASE_BILLING','RELEASE_CREDITMEMO') AND (l_line_amount >0)
      THEN
        --Fetch the GL Short Name.This will be sent as the valuation method
        --OPEN get_gl_short_name_csr;
        --FETCH get_gl_short_name_csr INTO l_gl_short_name;
        --CLOSE get_gl_short_name_csr;

	    -- get the correct short name based on representation.
	    l_gl_short_name := g_ledger_tbl(g_ledger_id).rep_code;

        IF l_gl_short_name IS NULL
        THEN
           OKL_API.SET_MESSAGE(p_app_name      => g_app_name
                              ,p_msg_name      => 'OKL_GL_NOT_SET_FOR_ORG');
           RAISE OKL_API.G_EXCEPTION_ERROR;
        END IF;

        --Making the call to populate_Acct_sources to retreive the l_asev_rec to be passed to
--populate_tcn_sources and populate_tcl_sources

        POPULATE_ACCT_SOURCES(p_api_version             => l_api_version,
                              p_init_msg_list           => l_init_msg_list,
                              x_return_status           => l_return_status,
                              x_msg_count               => l_msg_count,
                              x_msg_data                => l_msg_data,
                              p_tmpl_identify_rec       => p_tmpl_identify_rec,
                              p_dist_info_rec           => p_dist_info_rec,
                              p_acc_gen_primary_key_tbl => p_acc_gen_primary_key_tbl,
                              x_asev_rec                => l_asev_rec);

        IF (l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
           OKL_API.SET_MESSAGE(p_app_name     => g_app_name
                              ,p_msg_name     => 'OKL_SLA_SOURCES_FAILED');
           RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
        ELSIF (l_return_status = OKL_API.G_RET_STS_ERROR) THEN
           OKL_API.SET_MESSAGE(p_app_name     => g_app_name
                              ,p_msg_name     => 'OKL_SLA_SOURCES_FAILED');
           RAISE OKL_API.G_EXCEPTION_ERROR;
        END IF;

        OPEN get_tai_details_csr(p_dist_info_rec.source_id);
        FETCH get_tai_details_csr INTO get_tai_details_rec;
        CLOSE get_tai_details_csr;

        l_rxhv_rec.source_id    := get_tai_details_rec.tai_id;
        l_rxhv_rec.source_table := 'OKL_TRX_AR_INVOICES_B';
        l_rxhv_rec.khr_id       := get_tai_details_rec.khr_id;
        l_rxhv_rec.try_id       := get_tai_details_rec.try_id;


   --Before making the call to capture line sources, check the following
   --If l_check_status = 1, then the transaction line is in update mode and existing sources have been deleted
   --Header and line Sources need to be captured for all the sources deleted
       IF (l_check_status = 1)
       THEN
          --Making the call to populate line sources
  FOR i in x_rxlv_tbl.FIRST..l_rxlv_tbl.LAST
  LOOP
    --Make the call to Capture line sources
            l_rxlv_rec.source_id    := x_rxlv_tbl(i).source_id;
            l_rxlv_rec.source_table := x_rxlv_tbl(i).source_table;
            l_rxlv_rec.kle_id       := get_tai_details_rec.kle_id;
            l_rxlv_rec.sty_id       := get_tai_details_rec.sty_id;
            l_rxlv_rec.trans_line_description  := get_tai_details_rec.trans_line_description;

            --Make the call to capture account header source
            OKL_SLA_ACC_SOURCES_PVT.populate_ar_sources(p_api_version      => l_api_version
                                                       ,p_init_msg_list   => l_init_msg_list
                                                        ,p_rxhv_rec        => l_rxhv_rec
                                                        ,p_rxlv_rec        => l_rxlv_rec
                                                        ,p_acc_sources_rec => l_asev_rec
                                                        ,x_return_status   => l_return_status
                                                        ,x_msg_count       => l_msg_count
                                                        ,x_msg_data        => l_msg_data
                                                        );

            IF (l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
               OKL_API.SET_MESSAGE(p_app_name     => g_app_name
                                  ,p_msg_name     => 'OKL_SLA_SOURCES_FAILED');
               RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
            ELSIF (l_return_status = OKL_API.G_RET_STS_ERROR) THEN
               OKL_API.SET_MESSAGE(p_app_name     => g_app_name
                                  ,p_msg_name     => 'OKL_SLA_SOURCES_FAILED');
               RAISE OKL_API.G_EXCEPTION_ERROR;
            END IF;
  END LOOP;
        END IF;
        --Line sources need to be captured for the current line

        --Make the call to Capture line sources
        l_rxlv_rec.source_id := p_dist_info_rec.source_id;
        l_rxlv_rec.source_table := 'OKL_TXD_AR_LN_DTLS_B';
        l_rxlv_rec.kle_id       := get_tai_details_rec.kle_id;
        l_rxlv_rec.sty_id       := get_tai_details_rec.sty_id;
        l_rxlv_rec.trans_line_description  := get_tai_details_rec.trans_line_description;

        --Make the call to capture account header source
        OKL_SLA_ACC_SOURCES_PVT.populate_ar_sources(p_api_version      => l_api_version
                                                   ,p_init_msg_list   => l_init_msg_list
                                                   ,p_rxhv_rec        => l_rxhv_rec
                                                   ,p_rxlv_rec        => l_rxlv_rec
                                                   ,p_acc_sources_rec => l_asev_rec
                                                   ,x_return_status   => l_return_status
                                                   ,x_msg_count       => l_msg_count
                                                   ,x_msg_data        => l_msg_data
                                                   );

        IF (l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
             OKL_API.SET_MESSAGE(p_app_name     => g_app_name
                                ,p_msg_name     => 'OKL_SLA_SOURCES_FAILED');
             RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
        ELSIF (l_return_status = OKL_API.G_RET_STS_ERROR) THEN
             OKL_API.SET_MESSAGE(p_app_name     => g_app_name
                                ,p_msg_name     => 'OKL_SLA_SOURCES_FAILED');
             RAISE OKL_API.G_EXCEPTION_ERROR;
        END IF;

 --Bug 6316320 dpsingh start
 ELSIF l_try_name IN ('BALANCE_WRITE_OFF' ,'ADJUSTMENTS') AND (l_line_amount >0)
      THEN
        --Fetch the GL Short Name.This will be sent as the valuation method
        --OPEN get_gl_short_name_csr;
        --FETCH get_gl_short_name_csr INTO l_gl_short_name;
        --CLOSE get_gl_short_name_csr;

	    -- get the correct short name based on representation.
	    l_gl_short_name := g_ledger_tbl(g_ledger_id).rep_code;

        IF l_gl_short_name IS NULL
        THEN
           OKL_API.SET_MESSAGE(p_app_name      => g_app_name
                              ,p_msg_name      => 'OKL_GL_NOT_SET_FOR_ORG');
           RAISE OKL_API.G_EXCEPTION_ERROR;
        END IF;

        --Making the call to populate_Acct_sources to retreive the l_asev_rec to be passed to
--populate_tcn_sources and populate_tcl_sources

        POPULATE_ACCT_SOURCES(p_api_version             => l_api_version,
                              p_init_msg_list           => l_init_msg_list,
                              x_return_status           => l_return_status,
                              x_msg_count               => l_msg_count,
                              x_msg_data                => l_msg_data,
                              p_tmpl_identify_rec       => p_tmpl_identify_rec,
                              p_dist_info_rec           => p_dist_info_rec,
                              p_acc_gen_primary_key_tbl => p_acc_gen_primary_key_tbl,
                      x_asev_rec                => l_asev_rec);

        IF (l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
           OKL_API.SET_MESSAGE(p_app_name     => g_app_name
                              ,p_msg_name     => 'OKL_SLA_SOURCES_FAILED');
           RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
        ELSIF (l_return_status = OKL_API.G_RET_STS_ERROR) THEN
           OKL_API.SET_MESSAGE(p_app_name     => g_app_name
                              ,p_msg_name     => 'OKL_SLA_SOURCES_FAILED');
           RAISE OKL_API.G_EXCEPTION_ERROR;
        END IF;

        OPEN get_adj_details_csr(p_dist_info_rec.source_id);
        FETCH get_adj_details_csr INTO get_adj_details_rec;
        CLOSE get_adj_details_csr;

        l_rxhv_adj_rec.source_id    := get_adj_details_rec.adj_id;
        l_rxhv_adj_rec.source_table := 'OKL_TRX_AR_ADJSTS_B';
        l_rxhv_adj_rec.khr_id       := get_adj_details_rec.khr_id;
        l_rxhv_adj_rec.try_id       := get_adj_details_rec.try_id;


   --Before making the call to capture line sources, check the following
   --If l_check_status = 1, then the transaction line is in update mode and existing sources have been deleted
   --Header and line Sources need to be captured for all the sources deleted
       IF (l_check_status = 1)
       THEN
          --Making the call to populate line sources
  FOR i in x_rxlv_adj_tbl.FIRST..l_rxlv_adj_tbl.LAST
  LOOP
    --Make the call to Capture line sources
            l_rxlv_adj_rec.source_id    := x_rxlv_adj_tbl(i).source_id;
            l_rxlv_adj_rec.source_table := x_rxlv_adj_tbl(i).source_table;
            l_rxlv_adj_rec.kle_id       := get_adj_details_rec.kle_id;
            l_rxlv_adj_rec.sty_id       := get_adj_details_rec.sty_id;

            --Make the call to capture account header source
            OKL_SLA_ACC_SOURCES_PVT.populate_ar_sources(p_api_version      => l_api_version
                                                        ,p_init_msg_list   => l_init_msg_list
                                                        ,p_rxhv_rec        => l_rxhv_adj_rec
                                                        ,p_rxlv_rec        => l_rxlv_adj_rec
                                                        ,p_acc_sources_rec => l_asev_rec
                                                        ,x_return_status   => l_return_status
                                                        ,x_msg_count       => l_msg_count
                                                        ,x_msg_data        => l_msg_data
                                                        );

            IF (l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
               OKL_API.SET_MESSAGE(p_app_name     => g_app_name
                                  ,p_msg_name     => 'OKL_SLA_SOURCES_FAILED');
               RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
            ELSIF (l_return_status = OKL_API.G_RET_STS_ERROR) THEN
               OKL_API.SET_MESSAGE(p_app_name     => g_app_name
                                  ,p_msg_name     => 'OKL_SLA_SOURCES_FAILED');
               RAISE OKL_API.G_EXCEPTION_ERROR;
            END IF;
  END LOOP;
        END IF;
        --Line sources need to be captured for the current line

        --Make the call to Capture line sources
        l_rxlv_adj_rec.source_id := p_dist_info_rec.source_id;
        l_rxlv_adj_rec.source_table := 'OKL_TXD_AR_LN_DTLS_B';
        l_rxlv_adj_rec.kle_id       := get_adj_details_rec.kle_id;
        l_rxlv_adj_rec.sty_id       := get_adj_details_rec.sty_id;

        --Make the call to capture account header source
        OKL_SLA_ACC_SOURCES_PVT.populate_ar_sources(p_api_version      => l_api_version
                                                    ,p_init_msg_list   => l_init_msg_list
                                                   ,p_rxhv_rec        => l_rxhv_adj_rec
                                                   ,p_rxlv_rec        => l_rxlv_adj_rec
                                                   ,p_acc_sources_rec => l_asev_rec
                                                   ,x_return_status   => l_return_status
                                                   ,x_msg_count       => l_msg_count
                                                   ,x_msg_data        => l_msg_data
                                                   );

        IF (l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
             OKL_API.SET_MESSAGE(p_app_name     => g_app_name
                                ,p_msg_name     => 'OKL_SLA_SOURCES_FAILED');
             RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
        ELSIF (l_return_status = OKL_API.G_RET_STS_ERROR) THEN
             OKL_API.SET_MESSAGE(p_app_name     => g_app_name
                                ,p_msg_name     => 'OKL_SLA_SOURCES_FAILED');
             RAISE OKL_API.G_EXCEPTION_ERROR;
        END IF;
  --Bug 6316320 dpsingh end
      --Processing for AP Transactions
      ELSIF l_try_name IN ('DISBURSEMENT','FUNDING','DEBIT_NOTE') AND (l_line_amount >0)
      THEN
        -- below code is not required for MG uptake.
        --OPEN get_gl_short_name_csr;
        --FETCH get_gl_short_name_csr INTO l_gl_short_name;
        --CLOSE get_gl_short_name_csr;

	    -- get the correct short name based on representation.
	    l_gl_short_name := g_ledger_tbl(g_ledger_id).rep_code;

        IF l_gl_short_name IS NULL
        THEN
           OKL_API.SET_MESSAGE(p_app_name      => g_app_name
                              ,p_msg_name      => 'OKL_GL_NOT_SET_FOR_ORG');
           RAISE OKL_API.G_EXCEPTION_ERROR;
        END IF;

        --Making the call to populate_Acct_sources to retreive the l_asev_rec to be passed to
--populate_tcn_sources and populate_tcl_sources

        POPULATE_ACCT_SOURCES(p_api_version             => l_api_version,
                              p_init_msg_list           => l_init_msg_list,
                              x_return_status           => l_return_status,
                              x_msg_count               => l_msg_count,
                              x_msg_data                => l_msg_data,
                              p_tmpl_identify_rec       => p_tmpl_identify_rec,
                              p_dist_info_rec           => p_dist_info_rec,
                              p_acc_gen_primary_key_tbl => p_acc_gen_primary_key_tbl,
                      x_asev_rec                => l_asev_rec);

        IF (l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
           OKL_API.SET_MESSAGE(p_app_name     => g_app_name
                              ,p_msg_name     => 'OKL_SLA_SOURCES_FAILED');
           RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
        ELSIF (l_return_status = OKL_API.G_RET_STS_ERROR) THEN
           OKL_API.SET_MESSAGE(p_app_name     => g_app_name
                              ,p_msg_name     => 'OKL_SLA_SOURCES_FAILED');
           RAISE OKL_API.G_EXCEPTION_ERROR;
        END IF;

        OPEN get_tap_details_csr(p_dist_info_rec.source_id);
        FETCH get_tap_details_csr INTO get_tap_details_rec;
        CLOSE get_tap_details_csr;

        l_pxhv_rec.source_id    := get_tap_details_rec.tap_id;
        l_pxhv_rec.source_table := 'OKL_TRX_AP_INVOICES_B';
        l_pxhv_rec.khr_id       := get_tap_details_rec.khr_id;
        l_pxhv_rec.try_id       := get_tap_details_rec.try_id;
        l_pxhv_rec.trans_number := get_tap_details_rec.trans_number;


   --Before making the call to capture line sources, check the following
   --If l_check_status = 1, then the transaction line is in update mode and existing sources have been deleted
   --Header and line Sources need to be captured for all the sources deleted
       IF (l_check_status = 1)
       THEN
          --Making the call to populate line sources
  FOR i in x_pxlv_tbl.FIRST..l_pxlv_tbl.LAST
  LOOP
    --Make the call to Capture line sources
            l_pxlv_rec.source_id    := x_pxlv_tbl(i).source_id;
            l_pxlv_rec.source_table := x_pxlv_tbl(i).source_table;
            l_pxlv_rec.kle_id       := get_tap_details_rec.kle_id;
            l_pxlv_rec.sty_id       := get_tap_details_rec.sty_id;
            l_pxlv_rec.trans_line_description  := get_tap_details_rec.trans_line_description;

            --Make the call to capture account header source
            OKL_SLA_ACC_SOURCES_PVT.populate_ap_sources(p_api_version      => l_api_version
                                                ,p_init_msg_list   => l_init_msg_list
                                                        ,p_pxhv_rec        => l_pxhv_rec
                                                        ,p_pxlv_rec        => l_pxlv_rec
,p_acc_sources_rec => l_asev_rec
                                                        ,x_return_status   => l_return_status
                                                        ,x_msg_count       => l_msg_count
                                                        ,x_msg_data        => l_msg_data
                                                        );

            IF (l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
               OKL_API.SET_MESSAGE(p_app_name     => g_app_name
                                  ,p_msg_name     => 'OKL_SLA_SOURCES_FAILED');
               RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
            ELSIF (l_return_status = OKL_API.G_RET_STS_ERROR) THEN
               OKL_API.SET_MESSAGE(p_app_name     => g_app_name
                                  ,p_msg_name     => 'OKL_SLA_SOURCES_FAILED');
               RAISE OKL_API.G_EXCEPTION_ERROR;
            END IF;
  END LOOP;
        END IF;
        --Line sources need to be captured for the current line

        --Make the call to Capture line sources
        l_pxlv_rec.source_id := p_dist_info_rec.source_id;
        l_pxlv_rec.source_table := p_dist_info_rec.source_table;
        l_pxlv_rec.kle_id       := get_tap_details_rec.kle_id;
        l_pxlv_rec.sty_id       := get_tap_details_rec.sty_id;
        l_pxlv_rec.trans_line_description  := get_tap_details_rec.trans_line_description;

        --Make the call to capture account header source
        OKL_SLA_ACC_SOURCES_PVT.populate_ap_sources(p_api_version      => l_api_version
                                           ,p_init_msg_list   => l_init_msg_list
                                                   ,p_pxhv_rec        => l_pxhv_rec
                                                   ,p_pxlv_rec        => l_pxlv_rec
       ,p_acc_sources_rec => l_asev_rec
                                                   ,x_return_status   => l_return_status
                                                   ,x_msg_count       => l_msg_count
                                                   ,x_msg_data        => l_msg_data
                                                   );

        IF (l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
             OKL_API.SET_MESSAGE(p_app_name     => g_app_name
                                ,p_msg_name     => 'OKL_SLA_SOURCES_FAILED');
             RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
        ELSIF (l_return_status = OKL_API.G_RET_STS_ERROR) THEN
             OKL_API.SET_MESSAGE(p_app_name     => g_app_name
                                ,p_msg_name     => 'OKL_SLA_SOURCES_FAILED');
             RAISE OKL_API.G_EXCEPTION_ERROR;
        END IF;
      END IF;
      OKL_API.END_ACTIVITY(x_msg_count, x_msg_data);

   EXCEPTION

       WHEN OKL_API.G_EXCEPTION_ERROR THEN
         x_return_status := OKL_API.HANDLE_EXCEPTIONS
         ( l_api_name,
           G_PKG_NAME,
           'OKL_API.G_RET_STS_ERROR',
           x_msg_count,
           x_msg_data,
           '_PVT'
         );
       WHEN OKL_API.G_EXCEPTION_UNEXPECTED_ERROR THEN
         x_return_status := OKL_API.HANDLE_EXCEPTIONS
         ( l_api_name,
           G_PKG_NAME,
           'OKL_API.G_RET_STS_UNEXP_ERROR',
           x_msg_count,
           x_msg_data,
           '_PVT'
         );
       WHEN OTHERS THEN
         x_return_status := OKL_API.HANDLE_EXCEPTIONS
         ( l_api_name,
           G_PKG_NAME,
           'OTHERS',
           x_msg_count,
           x_msg_data,
           '_PVT'
         );

   END CREATE_ACCOUNTING_DIST;

--gboomina Bug 4662173 end

--Added by gboomina on 14-Oct-05 for Accruals Performance
--Bug 4662173 - Start of Changes
--This signature is used when a group of dist_info_rec can be grouped for a single transaction header
--as they share the same tmpl_identify_rec

PROCEDURE   CREATE_ACCOUNTING_DIST(p_api_version              IN       NUMBER,
                                   p_init_msg_list            IN       VARCHAR2,
                                   x_return_status            OUT      NOCOPY VARCHAR2,
                                   x_msg_count                OUT      NOCOPY NUMBER,
                                   x_msg_data                 OUT      NOCOPY VARCHAR2,
                                   p_tmpl_identify_rec        IN       TMPL_IDENTIFY_REC_TYPE,
                                   p_dist_info_tbl            IN       DIST_INFO_TBL_TYPE,
                                   p_ctxt_val_tbl             IN       CTXT_VAL_TBL_TYPE,
                                   p_acc_gen_primary_key_tbl  IN       acc_gen_tbl,
                                   x_template_tbl             OUT      NOCOPY AVLB_TBL_TYPE,
                                   x_amount_tbl               OUT      NOCOPY AMT_TBL_TYPE)


IS

  l_check_status   NUMBER;
  i                NUMBER := 0;
  l_amount         NUMBER := 0;

  tmpl_rec         AVLV_REC_TYPE;
  l_tmpl_tbl       avlv_tbl_type;
  l_formula_name   OKL_FORMULAE_V.NAME%TYPE;
  l_functional_curr OKL_TRNS_ACC_DSTRS.CURRENCY_CODE%TYPE;
  l_return_status  VARCHAR2(1) := OKL_API.G_RET_STS_SUCCESS;

  l_api_name       VARCHAR2(30) := 'CREATE_ACCOUNTING_DIST';
  l_api_version    NUMBER := 1.0;

-- Added by Santonyr on 30-Jul-2003 to fix the bug 2941805

  l_product_name  OKL_PRODUCTS.NAME%TYPE;
  l_trx_type_name OKL_TRX_TYPES_TL.NAME%TYPE;
  l_sty_type_name OKL_STRM_TYPE_TL.NAME%TYPE;

-- Added by Santonyr on 12-Jul-2440 for the bug 3761026

  l_template_amount_tbl tmp_bulk_amount_tbl_type;



  CURSOR frml_csr(v_id NUMBER) IS
  SELECT name
  FROM okl_formulae_v
  WHERE id = v_id;

-- Added by Santonyr on 30-Jul-2003 to fix the bug 2941805

  CURSOR prdt_csr (l_pdt_id OKL_PRODUCTS.ID%TYPE) IS
  SELECT name
  FROM okl_products
  WHERE id = l_pdt_id ;

  -- Bug 4205156. SGIYER 07-MAR-05. Added language clause
  CURSOR trx_type_csr (l_trx_type_id OKL_TRX_TYPES_TL.ID%TYPE) IS
  SELECT name
  FROM okl_trx_types_tl
  WHERE id = l_trx_type_id
  AND language = USERENV('LANG');

  -- Bug 4205156. SGIYER 07-MAR-05. Added language clause
  CURSOR sty_type_csr (l_sty_type_id OKL_STRM_TYPE_TL.ID%TYPE) IS
  SELECT name
  FROM okl_strm_type_tl
  WHERE id = l_sty_type_id
  AND language = USERENV('LANG');

  l_dist_info_tbl        DIST_INFO_TBL_TYPE:= p_dist_info_tbl;
  --Added by  gboomina for the Accruals Performance Enhancement
  l_acc_gen_ind                 NUMBER := 0;
  l_acc_gen_last_ind            NUMBER := 0;
  p_acc_gen_tbl_ret             acc_gen_primary_key;
  l_tmp_amt_tbl_count           NUMBER := 0;
  --Added by kthiruva on 06-Feb-2007 for SLA Uptake
  --Bug 5707866 - Start of Changes
  l_account_derivation     OKL_SYS_ACCT_OPTS.ACCOUNT_DERIVATION%TYPE;
  l_tcn_id                 NUMBER;
  l_init_msg_list         VARCHAR2(1) := OKL_API.G_FALSE;
  l_msg_count             NUMBER := 0;
  l_msg_data              VARCHAR2(2000);
  l_event_id              NUMBER;
  l_event_date            DATE;
  l_gl_short_name         GL_LEDGERS.SHORT_NAME%TYPE;
  l_tabv_tbl_out          tabv_tbl_type ;
  l_tabv_tbl_final        tabv_tbl_type;
  x_tabv_tbl              tabv_tbl_type ;
  k                       NUMBER := 0;
  l_first_rec             BOOLEAN := TRUE;

  CURSOR get_tcn_id_csr(p_source_id IN NUMBER)
  IS
  SELECT tcl.tcn_id
  FROM OKL_TXL_CNTRCT_LNS tcl
  WHERE tcl.id = p_source_id;

  -- cursor to get the ledger details for a trx header. MG Uptake
  CURSOR get_ledger_id_csr(p_tcl_id IN NUMBER)
  IS
  SELECT set_of_books_id
	FROM okl_trx_contracts hdr, okl_txl_cntrct_lns lns
   WHERE hdr.id = lns.tcn_id
     AND lns.id = p_tcl_id;

  l_ledger_id     NUMBER;

  CURSOR get_gl_short_name_csr
  IS
  SELECT GL.SHORT_NAME
  FROM OKL_SYS_ACCT_OPTS SAO,
       GL_LEDGERS GL
  WHERE SAO.SET_OF_BOOKS_ID = GL.LEDGER_ID;
  --Bug 5707866 - End of Changes

BEGIN
  IF (G_DEBUG_ENABLED = 'Y') THEN
    G_IS_DEBUG_STATEMENT_ON := OKL_DEBUG_PUB.CHECK_LOG_ON(G_MODULE, FND_LOG.LEVEL_STATEMENT);
  END IF;
   x_return_status := OKL_API.G_RET_STS_SUCCESS;

   l_return_status := OKL_API.START_ACTIVITY(l_api_name,
                                             G_PKG_NAME,
                                             p_init_msg_list,
                                             l_api_version,
                                             p_api_version,
                                             '_PVT',
                                             x_return_status);
   IF (l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
     RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
   ELSIF (l_return_status = OKL_API.G_RET_STS_ERROR) THEN
     RAISE OKL_API.G_EXCEPTION_ERROR;
   END IF;

   -- get the ledger attributes .. racheruv
   get_rep_attributes;

   IF l_dist_info_tbl(l_dist_info_tbl.first).source_table = 'OKL_TXL_CNTRCT_LNS' THEN
     OPEN get_ledger_id_csr(l_dist_info_tbl(l_dist_info_tbl.first).source_id);
     FETCH get_ledger_id_csr INTO l_ledger_id;
     CLOSE get_ledger_id_csr;
   END IF;

   IF l_ledger_id IS NOT NULL THEN
     g_representation_type := g_ledger_tbl(l_ledger_id).rep_type;
     g_ledger_id := l_ledger_id;
   ELSE
	   g_representation_type := 'PRIMARY';
	   g_ledger_id := okl_accounting_util.get_set_of_books_id;
   END IF;

-- Get the functional currency .. based on the represention
   IF g_representation_type = 'PRIMARY' THEN
     l_functional_curr := okl_accounting_util.get_func_curr_code;
   ELSE
     l_functional_curr := okl_accounting_util.get_func_curr_code(g_ledger_id);
   END IF;


-- Bug 3948354
-- Set the global variable G_REV_REC_FLAG to the value passed by calling program

   G_REV_REC_FLAG := p_tmpl_identify_rec.REV_REC_FLAG;


-- Validate the Parameters

   IF (G_IS_DEBUG_STATEMENT_ON = true) THEN
        OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE,'Prior to the call to VALIDATE_PARAMS');
   END IF;
   VALIDATE_PARAMS(p_dist_info_tbl       => l_dist_info_tbl,
                   p_functional_curr     => l_functional_curr,
                   x_return_status       => l_return_status);
   IF (G_IS_DEBUG_STATEMENT_ON = true) THEN
        OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE,'After the call to VALIDATE_PARAMS, the return status is :'||l_return_status);
   END IF;



   IF (l_return_status <> OKL_API.G_RET_STS_SUCCESS) THEN
       RAISE OKL_API.G_EXCEPTION_ERROR;
   END IF;

-- Get the Templates from the given parameters

--- Change the G_GL_DATE to p_dist_info_rec.accounting_date if we want to pass passed-date as GL Date

   IF (G_IS_DEBUG_STATEMENT_ON = true) THEN
        OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE,'Prior to the call to Get_Template_Info');
   END IF;

   --Bug 5707866 - Start of Changes
   OPEN get_acct_derivation_csr;
   FETCH get_acct_derivation_csr INTO l_account_derivation;
   CLOSE get_acct_derivation_csr;

   IF l_account_derivation IS NULL THEN
      OKL_API.SET_MESSAGE(p_app_name     => g_app_name
                         ,p_msg_name     => 'OKL_ACCT_DER_NOT_SET');
      RAISE OKL_API.G_EXCEPTION_ERROR;
   END IF;

   --Deriving the functional currency to be passed in the call to validate_params
   --l_functional_curr := Okl_Accounting_Util.GET_FUNC_CURR_CODE; -- redundant code

   -- Check the Distribution Status and take appropriate Action
   FOR i in l_dist_info_tbl.FIRST..l_dist_info_tbl.LAST LOOP
       --Only when the account derivation option is 'ATS'
       --Or if the account derivation option is 'AMB' and the transaction amount is not known
       --should the template information be fetched
       IF (l_account_derivation = 'ATS') OR
          ((l_account_derivation = 'AMB') AND ((l_dist_info_tbl(i).AMOUNT IS NULL) OR (l_dist_info_tbl(i).AMOUNT = OKL_API.G_MISS_NUM)))
       THEN
         IF (l_first_rec = TRUE)
     THEN
           GET_TEMPLATE_INFO(p_api_version        => l_api_version,
                             p_init_msg_list      => p_init_msg_list,
                             x_return_status      => l_return_status,
                             x_msg_count          => x_msg_count,
                             x_msg_data           => x_msg_data,
                             p_tmpl_identify_rec  => p_tmpl_identify_rec,
                             x_template_tbl       => l_tmpl_tbl,
                             p_validity_date      => G_GL_DATE);

           IF (l_return_status <> OKL_API.G_RET_STS_SUCCESS) THEN
             RAISE OKL_API.G_EXCEPTION_ERROR;
           END IF;

           --Setting l_first_rec to FALSE, so that GET_TEMPLATE_INFO need not be called every time in the loop
           l_first_rec :=  FALSE;

           IF (G_IS_DEBUG_STATEMENT_ON = true) THEN
              OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE,'The return status after the Get_Template_Info call is :'||l_return_status);
           END IF;

           -- Raise an error if template is not found.
           IF (l_tmpl_tbl.COUNT = 0) THEN
             -- Added by Santonyr on 30-Jul-2003 to fix the bug 2941805
             FOR prdt_rec IN prdt_csr (p_tmpl_identify_rec.product_id) LOOP
               l_product_name := prdt_rec.name;
             END LOOP;

             FOR trx_type_rec IN trx_type_csr (p_tmpl_identify_rec.transaction_type_id) LOOP
               l_trx_type_name := trx_type_rec.name;
             END LOOP;

             FOR sty_type_rec IN sty_type_csr (p_tmpl_identify_rec.stream_type_id) LOOP
               l_sty_type_name := sty_type_rec.name;
             END LOOP;

             OKL_API.SET_MESSAGE(p_app_name     => g_app_name
                                ,p_msg_name     => 'OKL_TMPL_NOT_FOUND'
                                ,p_token1        => 'PRODUCT'
                                ,p_token1_value  => l_product_name
                                ,p_token2        => 'TRANSACTION_TYPE'
                                ,p_token2_value  => l_trx_type_name
                       ,p_token3        => 'STREAM_TYPE'
                                ,p_token3_value  => NVL(l_sty_type_name,  ' ')
                       ,p_token4        => 'ACCOUNTING_DATE'
                                ,p_token4_value  => G_GL_DATE);


             RAISE OKL_API.G_EXCEPTION_ERROR;
           END IF;
         END IF;

         -- Check the Distribution Status and take appropriate Action
         l_check_status := CHECK_JOURNAL(p_source_id    =>  l_dist_info_tbl(i).source_id,
                                         p_source_table =>  l_dist_info_tbl(i).source_table);

         -- l_check_status = 1 denotes that the distributions in OKL exist, but journals have not yet been created in SLA
         -- l_check_status = 2 denotes that the distributions exist in OKL , and journals have been created in SLA


         IF (l_check_status = 1) THEN
           -- Delete from Distributions
           DELETE_DIST_AE(p_flag          => 'DIST',
                         p_source_id     => l_dist_info_tbl(i).source_id,
                         p_source_table  => l_dist_info_tbl(i).source_table,
                         x_return_status => l_return_status);

           IF (l_return_status <> OKL_API.G_RET_STS_SUCCESS) THEN
              RAISE OKL_API.G_EXCEPTION_ERROR;
           END IF;

         END IF;

         IF (l_check_status = 2) THEN
           OKL_API.SET_MESSAGE(p_app_name     => g_app_name,
                               p_msg_name     => 'OKL_AE_GONE_TO_SLA');
           RAISE OKL_API.G_EXCEPTION_ERROR;
         END IF;

         FOR j IN 1..l_tmpl_tbl.COUNT
         LOOP
           tmpl_rec := l_tmpl_tbl(j);

           -- Added by Santonyr on 12-Jul-2440 for the bug 3761026
           l_template_amount_tbl(l_tmp_amt_tbl_count).template_id := tmpl_rec.id;
           l_template_amount_tbl(l_tmp_amt_tbl_count).stream_type_id := tmpl_rec.sty_id;
           --Building the reference between the template_amount_tbl and dist_info_rec
           l_template_amount_tbl(l_tmp_amt_tbl_count).parent_index_number := i;


           IF (l_dist_info_tbl(i).AMOUNT IS NULL) OR
              (l_dist_info_tbl(i).AMOUNT = OKL_API.G_MISS_NUM) THEN

              -- If the amount is null calculate the amount using formula engine
              IF (tmpl_rec.FMA_ID IS NULL) OR
                 (tmpl_rec.FMA_ID = OKL_API.G_MISS_NUM) THEN
                -- If the formula is not found associated with template
                    OKL_API.SET_MESSAGE(p_app_name     => g_app_name,
                                        p_msg_name     => 'OKL_FMA_NOT_PRESENT',
                                        p_token1       => 'TEMPLATE_NAME',
                                        p_token1_value => tmpl_rec.NAME);
                    RAISE OKL_API.G_EXCEPTION_ERROR;
              END IF;

              OPEN frml_csr(tmpl_rec.fma_id);
              FETCH frml_csr INTO l_formula_name;
              CLOSE frml_csr;

              -- For secondary rep txn, set the security policy for streams. MG Uptake
              IF g_representation_type = 'SECONDARY' THEN
                OKL_STREAMS_SEC_PVT.SET_REPO_STREAMS;
              END IF;

              -- Execute the formula using formula engine.

              EXECUTE_FORMULA(p_avlv_rec            => tmpl_rec,
                              p_contract_id         => l_dist_info_tbl(i).contract_id,
                              p_contract_line_id    => l_dist_info_tbl(i).contract_line_id,
                              p_ctxt_val_tbl        => p_ctxt_val_tbl,
                              x_return_status       => l_return_status,
                              x_amount              => l_amount );

              IF (l_return_status <> OKL_API.G_RET_STS_SUCCESS) THEN
                   OKL_API.SET_MESSAGE(p_app_name     => g_app_name,
                                       p_msg_name     => 'OKL_FRML_EXE_FAILED',
                                       p_token1       => 'FORMULA_NAME',
                                       p_token1_value => l_formula_name);

              END IF;

              -- For secondary rep txn, reset the security policy for streams. MG Uptake
              IF g_representation_type = 'SECONDARY' THEN
                OKL_STREAMS_SEC_PVT.RESET_REPO_STREAMS;
              END IF;

              IF (l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
                  RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
              ELSIF (l_return_status = OKL_API.G_RET_STS_ERROR) THEN
                  RAISE OKL_API.G_EXCEPTION_ERROR;
              END IF;

              -- Added by Santonyr on 12-Jul-2440 for the bug 3761026
              l_template_amount_tbl(l_tmp_amt_tbl_count).formula_used := 'Y';

           ELSE -- If the amount is passed from the caller (amount is not null).

              l_amount  := l_dist_info_tbl(i).AMOUNT;
              -- Added by Santonyr on 12-Jul-2440 for the bug 3761026
              l_template_amount_tbl(l_tmp_amt_tbl_count).formula_used := 'N';

           END IF;  -- End If for (p_dist_info_rec.AMOUNT IS NULL)

           -- If amount passes is Zero or Amount got from formula is zero then a
           -- message should be displayed.

           IF (l_amount = 0) THEN
               OKL_API.SET_MESSAGE(p_app_name     => g_app_name,
                                   p_msg_name     => 'OKL_FRML_RET_ZERO_AMT',
                                   p_token1       => 'TEMPLATE_NAME',
                                   p_token1_value => tmpl_rec.NAME);

           -- Santonyr on 14-Jul-2003 Fixed bug 3048686
           --     RAISE OKL_API.G_EXCEPTION_ERROR;

           END IF;

           IF (G_IS_DEBUG_STATEMENT_ON = true) THEN
                OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE,'Prior to the call to COPY_TEMPLATE_TBL');
           END IF;

   COPY_TEMPLATE_TBL(p_temp_rec => tmpl_rec,
                             x_template_rec => x_template_tbl(j),
                             x_return_status => l_return_status);


            IF (l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
               RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
            ELSIF (l_return_status = OKL_API.G_RET_STS_ERROR) THEN
               RAISE OKL_API.G_EXCEPTION_ERROR;
            END IF;

            IF (G_IS_DEBUG_STATEMENT_ON = true) THEN
                OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE,'After the call to COPY_TEMPLATE_TBL, the return status is '||l_return_status);
            END IF;

            --Building a reference between the dist_info rec and x_template_tbl
            x_template_tbl(l_tmp_amt_tbl_count).parent_index_number := i;
            x_amount_tbl(l_tmp_amt_tbl_count).amount := Okl_Accounting_Util.ROUND_AMOUNT(p_amount        => l_amount,
                                                                                         p_currency_code => p_dist_info_tbl(i).currency_code);
            x_amount_tbl(l_tmp_amt_tbl_count).parent_index_number := i;
            l_template_amount_tbl(l_tmp_amt_tbl_count).amount := x_amount_tbl(l_tmp_amt_tbl_count).amount;

            --Fetch the Account gen table corresponding to the source_id of the current distribution record
            GET_ACC_GEN_TBL(p_source_id         => p_dist_info_tbl(i).source_id,
                            p_gen_table            => p_acc_gen_primary_key_tbl,
                            x_acc_gen_tbl_ret      => p_acc_gen_tbl_ret);

            IF (l_amount <> 0) THEN
               IF (l_account_derivation = 'ATS')
               THEN
                 CREATE_DIST_RECS(p_avlv_rec           => tmpl_rec,
                                  p_tmpl_identify_rec  => p_tmpl_identify_rec,
                                  p_dist_info_rec      => l_dist_info_tbl(i),
                                  p_amount             => l_amount,
                                  p_gen_table          => p_acc_gen_tbl_ret,
                                  x_return_status      => l_return_status,
  x_tabv_tbl           => l_tabv_tbl_out);

                 IF (l_return_status <> OKL_API.G_RET_STS_SUCCESS) THEN
                    RAISE OKL_API.G_EXCEPTION_ERROR;
                 END IF;
               ELSIF (l_account_derivation = 'AMB')
   THEN
                 CREATE_DIST_RECS(--Bug 6127326 dpsingh start
                                  p_avlv_rec           => tmpl_rec,
                                  --Bug 6127326 dpsingh end
                                  p_tmpl_identify_rec  => p_tmpl_identify_rec,
                                  p_dist_info_rec      => l_dist_info_tbl(i),
                                  p_amount             => l_amount,
                                  x_return_status      => l_return_status,
  x_tabv_tbl           => l_tabv_tbl_out);

                 IF (l_return_status <> OKL_API.G_RET_STS_SUCCESS) THEN
                    RAISE OKL_API.G_EXCEPTION_ERROR;
                 END IF;
   END IF;
            END IF;  -- End If for (l_amount <> 0)

            --Incrementing the counter
            l_tmp_amt_tbl_count := l_tmp_amt_tbl_count + 1;

            IF (l_tabv_tbl_final.COUNT = 0) THEN
              k := 0;
         ELSE
  k := l_tabv_tbl_final.COUNT;
END IF;

            FOR i in l_tabv_tbl_out.FIRST..l_tabv_tbl_out.LAST
            LOOP
              l_tabv_tbl_final(k).id := l_tabv_tbl_out(i).id;
              k := k + 1;
            END LOOP;

         END LOOP;  -- End LOOP for (l_tmpl_tbl.COUNT)

       --Else when the account derivation option is 'AMB' and the transaction amount is already known
       ELSE
        --Assinging the amount being passed in the rec to l_amount
        l_amount := l_dist_info_tbl(i).amount;

        --Deriving the functional currency to be passed in the call to validate_params
        --l_functional_curr := Okl_Accounting_Util.GET_FUNC_CURR_CODE; -- redundant code

        -- Check the Distribution Status and take appropriate Action
        l_check_status := CHECK_JOURNAL(p_source_id    =>  l_dist_info_tbl(i).source_id,
                                        p_source_table =>  l_dist_info_tbl(i).source_table);

        -- l_check_status = 1 denotes that the distributions in OKL exist, but journals have not yet been created in SLA
        -- l_check_status = 2 denotes that the distributions exist in OKL , and journals have been created in SLA


        IF (l_check_status = 1) THEN
           -- Delete from Distributions
           DELETE_DIST_AE(p_flag          => 'DIST',
                         p_source_id     => l_dist_info_tbl(i).source_id,
                         p_source_table  => l_dist_info_tbl(i).source_table,
                         x_return_status => l_return_status);

           IF (l_return_status <> OKL_API.G_RET_STS_SUCCESS) THEN
              RAISE OKL_API.G_EXCEPTION_ERROR;
           END IF;

        END IF;

        IF (l_check_status = 2) THEN
           OKL_API.SET_MESSAGE(p_app_name     => g_app_name,
                               p_msg_name     => 'OKL_AE_GONE_TO_SLA');
           RAISE OKL_API.G_EXCEPTION_ERROR;
        END IF;

        l_template_amount_tbl(l_tmp_amt_tbl_count).amount := x_amount_tbl(l_tmp_amt_tbl_count).amount;

        l_amount := l_dist_info_tbl(i).amount;

        IF (l_amount <> 0) THEN

            CREATE_DIST_RECS(p_tmpl_identify_rec  => p_tmpl_identify_rec,
                             p_dist_info_rec      => l_dist_info_tbl(i),
                             p_amount             => l_amount,
                             x_return_status      => l_return_status,
 x_tabv_tbl           => l_tabv_tbl_out);

            IF (l_return_status <> OKL_API.G_RET_STS_SUCCESS) THEN
                RAISE OKL_API.G_EXCEPTION_ERROR;
            END IF;
        END IF;  -- End If for (l_amount <> 0)

        x_amount_tbl(l_tmp_amt_tbl_count).amount := Okl_Accounting_Util.ROUND_AMOUNT(p_amount        => l_amount,
                                                                                     p_currency_code => p_dist_info_tbl(i).currency_code);
        x_amount_tbl(l_tmp_amt_tbl_count).parent_index_number := i;

        --Incrementing the counter
        l_tmp_amt_tbl_count := l_tmp_amt_tbl_count + 1;

        IF (l_tabv_tbl_final.COUNT = 0) THEN
           k := 0;
        ELSE
   k := l_tabv_tbl_final.COUNT;
END IF;

        FOR i in l_tabv_tbl_out.FIRST..l_tabv_tbl_out.LAST
        LOOP
          l_tabv_tbl_final(k).id := l_tabv_tbl_out(i).id;
          k := k + 1;
        END LOOP;

       END IF;
   END LOOP; --End loop for (l_dist_info_tbl.count)

   --Fetching the transaction header id corresponding to this distribution
   --As the dist_info_tbl is grouped for a single transaction header,
   --the tcn_id is fetched only once for the entire table
   OPEN get_tcn_id_csr(p_source_id => l_dist_info_tbl(l_dist_info_tbl.first).source_id);
   FETCH get_tcn_id_csr INTO l_tcn_id;
   CLOSE get_tcn_id_csr;

   --Checking if an event has already been created for the transaction
   OKL_XLA_EVENTS_PVT.event_exists(p_api_version        => l_api_version
                                  ,p_init_msg_list      => l_init_msg_list
                                  ,x_return_status      => l_return_status
                                  ,x_msg_count          => l_msg_count
                                  ,x_msg_data           => l_msg_data
                                  ,p_tcn_id             => l_tcn_id
                                  ,p_action_type        => 'CREATE'
                                  ,x_event_id           => l_event_id
                                  ,x_event_date         => l_event_date);

   IF (l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
        RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
   ELSIF (l_return_status = OKL_API.G_RET_STS_ERROR) THEN
        RAISE OKL_API.G_EXCEPTION_ERROR;
   END IF;

   --If an event is already found , do nothing, else Capture account sources for the header
   IF l_event_id IS NULL
   THEN
        -- below code s not required for MG uptake.
        --OPEN get_gl_short_name_csr;
        --FETCH get_gl_short_name_csr INTO l_gl_short_name;
        --CLOSE get_gl_short_name_csr;

        -- set the representation name which will be used as valuation method
        l_gl_short_name := g_ledger_tbl(g_ledger_id).rep_code;

        IF l_gl_short_name IS NULL
        THEN
          OKL_API.SET_MESSAGE(p_app_name      => g_app_name
                             ,p_msg_name      => 'OKL_GL_NOT_SET_FOR_ORG');
          RAISE OKL_API.G_EXCEPTION_ERROR;
        END IF;

        l_event_id := OKL_XLA_EVENTS_PVT.create_event(p_api_version        => l_api_version
                                                     ,p_init_msg_list      => l_init_msg_list
                                                     ,x_return_status      => l_return_status
                                                     ,x_msg_count          => l_msg_count
                                                     ,x_msg_data           => l_msg_data
                                                     ,p_tcn_id             => l_tcn_id
                                                     ,p_gl_date            => G_gl_date
                                                     ,p_action_type        => 'CREATE'
                                                     ,p_representation_code   => l_gl_short_name
                                                     );

        IF (l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
           RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
        ELSIF (l_return_status = OKL_API.G_RET_STS_ERROR) THEN
           RAISE OKL_API.G_EXCEPTION_ERROR;
        END IF;

   END IF;

   FOR i in l_tabv_tbl_final.FIRST..l_tabv_tbl_final.LAST
   LOOP
      l_tabv_tbl_final(i).accounting_event_id := l_event_id;
      --Once the event is created successfully in XLA, posted_yn flag is set to Y
      l_tabv_tbl_final(i).posted_yn           := 'Y';
   END LOOP;

   --Update the accounting_event_id on the
   OKL_TRNS_ACC_DSTRS_PUB.update_trns_acc_dstrs(p_api_version    => l_api_version
                                               ,p_init_msg_list  => l_init_msg_list
                                               ,x_return_status  => l_return_status
                                               ,x_msg_count      => l_msg_count
                                               ,x_msg_data       => l_msg_data
                                               ,p_tabv_tbl       => l_Tabv_tbl_final
                                               ,x_tabv_tbl       => x_tabv_tbl
                                               );

   OKL_API.END_ACTIVITY(x_msg_count, x_msg_data);

EXCEPTION

    WHEN OKL_API.G_EXCEPTION_ERROR THEN
      x_return_status := OKL_API.HANDLE_EXCEPTIONS
      ( l_api_name,
        G_PKG_NAME,
        'OKL_API.G_RET_STS_ERROR',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
    WHEN OKL_API.G_EXCEPTION_UNEXPECTED_ERROR THEN
      x_return_status := OKL_API.HANDLE_EXCEPTIONS
      ( l_api_name,
        G_PKG_NAME,
        'OKL_API.G_RET_STS_UNEXP_ERROR',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
    WHEN OTHERS THEN
      x_return_status := OKL_API.HANDLE_EXCEPTIONS
      ( l_api_name,
        G_PKG_NAME,
        'OTHERS',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );

END CREATE_ACCOUNTING_DIST;
 --Bug 4662173 - End of Changes

PROCEDURE   CREATE_ACCOUNTING_DIST(p_api_version              IN       NUMBER,
                                   p_init_msg_list            IN       VARCHAR2,
                                   x_return_status            OUT      NOCOPY VARCHAR2,
                                   x_msg_count                OUT      NOCOPY NUMBER,
                                   x_msg_data                 OUT      NOCOPY VARCHAR2,
                                   p_tmpl_identify_rec        IN       TMPL_IDENTIFY_REC_TYPE,
                                   p_dist_info_tbl            IN       DIST_INFO_TBL_TYPE,
                                   p_ctxt_val_tbl             IN       CTXT_TBL_TYPE,
                                   p_acc_gen_primary_key_tbl  IN       ACC_GEN_TBL_TYPE,
                                   x_template_tbl             OUT      NOCOPY AVLV_OUT_TBL_TYPE,
                                   x_amount_tbl               OUT      NOCOPY AMOUNT_OUT_TBL_TYPE,
                                   x_tabv_tbl                 OUT      NOCOPY TABV_TBL_TYPE)

IS

  l_check_status   NUMBER;
  i                NUMBER := 0;
  l_amount         NUMBER := 0;

  tmpl_rec         AVLV_REC_TYPE;
  l_tmpl_tbl       avlv_tbl_type;
  l_formula_name   OKL_FORMULAE_V.NAME%TYPE;
  l_functional_curr OKL_TRNS_ACC_DSTRS.CURRENCY_CODE%TYPE;
  l_return_status  VARCHAR2(1) := OKL_API.G_RET_STS_SUCCESS;

  l_api_name       VARCHAR2(30) := 'CREATE_ACCOUNTING_DIST';
  l_api_version    NUMBER := 1.0;

-- Added by Santonyr on 30-Jul-2003 to fix the bug 2941805

  l_product_name  OKL_PRODUCTS.NAME%TYPE;
  l_trx_type_name OKL_TRX_TYPES_TL.NAME%TYPE;
  l_sty_type_name OKL_STRM_TYPE_TL.NAME%TYPE;

  CURSOR frml_csr(v_id NUMBER) IS
  SELECT name
  FROM okl_formulae_v
  WHERE id = v_id;

-- Added by Santonyr on 30-Jul-2003 to fix the bug 2941805

  CURSOR prdt_csr (l_pdt_id OKL_PRODUCTS.ID%TYPE) IS
  SELECT name
  FROM okl_products
  WHERE id = l_pdt_id ;

  -- Bug 4205156. SGIYER 07-MAR-05. Added language clause
  CURSOR trx_type_csr (l_trx_type_id OKL_TRX_TYPES_TL.ID%TYPE) IS
  SELECT name
  FROM okl_trx_types_tl
  WHERE id = l_trx_type_id
  AND language = USERENV('LANG');

  -- Bug 4205156. SGIYER 07-MAR-05. Added language clause
  CURSOR sty_type_csr (l_sty_type_id OKL_STRM_TYPE_TL.ID%TYPE) IS
  SELECT name
  FROM okl_strm_type_tl
  WHERE id = l_sty_type_id
  AND language = USERENV('LANG');

  l_dist_info_tbl        DIST_INFO_TBL_TYPE:= p_dist_info_tbl;
  --Added by  gboomina for the Accruals Performance Enhancement
  l_acc_gen_ind                 NUMBER := 0;
  l_acc_gen_last_ind            NUMBER := 0;
  p_acc_gen_tbl_ret             acc_gen_primary_key;
  l_tmp_amt_tbl_count           NUMBER := 0;
  --Added by kthiruva on 06-Feb-2007 for SLA Uptake
  --Bug 5707866 - Start of Changes
  l_ctxt_val_tbl           CTXT_VAL_TBL_TYPE;
  l_account_derivation     OKL_SYS_ACCT_OPTS.ACCOUNT_DERIVATION%TYPE;
  l_tcn_id                 NUMBER;
  l_init_msg_list         VARCHAR2(1) := OKL_API.G_FALSE;
  l_msg_count             NUMBER := 0;
  l_msg_data              VARCHAR2(2000);
  l_event_id              NUMBER;
  l_event_date            DATE;
  l_gl_short_name         GL_LEDGERS.SHORT_NAME%TYPE;
  l_tabv_tbl_out          tabv_tbl_type ;
  l_tabv_tbl_final        tabv_tbl_type;
  --x_tabv_tbl              tabv_tbl_type ;
  k                       NUMBER := 0;
  l_first_rec             BOOLEAN := TRUE;

  --Bug 5707866 - End of Changes

BEGIN
  IF (G_DEBUG_ENABLED = 'Y') THEN
    G_IS_DEBUG_STATEMENT_ON := OKL_DEBUG_PUB.CHECK_LOG_ON(G_MODULE, FND_LOG.LEVEL_STATEMENT);
  END IF;
   x_return_status := OKL_API.G_RET_STS_SUCCESS;

   l_return_status := OKL_API.START_ACTIVITY(l_api_name,
                                             G_PKG_NAME,
                                             p_init_msg_list,
                                             l_api_version,
                                             p_api_version,
                                             '_PVT',
                                             x_return_status);
   IF (l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
     RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
   ELSIF (l_return_status = OKL_API.G_RET_STS_ERROR) THEN
     RAISE OKL_API.G_EXCEPTION_ERROR;
   END IF;

-- Get the functional currency, based on the representation
   IF g_representation_type = 'PRIMARY' THEN
     l_functional_curr := okl_accounting_util.get_func_curr_code;
   ELSE
	 l_functional_curr := okl_accounting_util.get_func_curr_code(g_ledger_id);
   END IF;


-- Bug 3948354
-- Set the global variable G_REV_REC_FLAG to the value passed by calling program
   G_REV_REC_FLAG := p_tmpl_identify_rec.REV_REC_FLAG;

-- Validate the Parameters

   IF (G_IS_DEBUG_STATEMENT_ON = true) THEN
        OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE,'Prior to the call to VALIDATE_PARAMS');
   END IF;
   VALIDATE_PARAMS(p_dist_info_tbl       => l_dist_info_tbl,
                   p_functional_curr     => l_functional_curr,
                   x_return_status       => l_return_status);

   IF (l_return_status <> OKL_API.G_RET_STS_SUCCESS) THEN
       RAISE OKL_API.G_EXCEPTION_ERROR;
   END IF;

   IF (G_IS_DEBUG_STATEMENT_ON = true) THEN
        OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE,'After the call to VALIDATE_PARAMS, the return status is :'||l_return_status);
   END IF;

-- Get the Templates from the given parameters

--- Change the G_GL_DATE to p_dist_info_rec.accounting_date if we want to pass passed-date as GL Date

   IF (G_IS_DEBUG_STATEMENT_ON = true) THEN
        OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE,'Prior to the call to Get_Template_Info');
   END IF;

   --Bug 5707866 - Start of Changes
   OPEN get_acct_derivation_csr;
   FETCH get_acct_derivation_csr INTO l_account_derivation;
   CLOSE get_acct_derivation_csr;

   IF l_account_derivation IS NULL THEN
      OKL_API.SET_MESSAGE(p_app_name     => g_app_name
                         ,p_msg_name     => 'OKL_ACCT_DER_NOT_SET');
      RAISE OKL_API.G_EXCEPTION_ERROR;
   END IF;

   --Deriving the functional currency to be passed in the call to validate_params
   --l_functional_curr := Okl_Accounting_Util.GET_FUNC_CURR_CODE; --redundant code.

   -- Check the Distribution Status and take appropriate Action
   FOR i in l_dist_info_tbl.FIRST..l_dist_info_tbl.LAST LOOP
       --Only when the account derivation option is 'ATS'
       --Or if the account derivation option is 'AMB' and the transaction amount is not known
       --should the template information be fetched
       IF (l_account_derivation = 'ATS') OR
          ((l_account_derivation = 'AMB') AND ((l_dist_info_tbl(i).AMOUNT IS NULL) OR (l_dist_info_tbl(i).AMOUNT = OKL_API.G_MISS_NUM)))
       THEN
         IF (l_first_rec = TRUE)
     THEN
           GET_TEMPLATE_INFO(p_api_version        => l_api_version,
                             p_init_msg_list      => p_init_msg_list,
                             x_return_status      => l_return_status,
                             x_msg_count          => x_msg_count,
                             x_msg_data           => x_msg_data,
                             p_tmpl_identify_rec  => p_tmpl_identify_rec,
                             x_template_tbl       => l_tmpl_tbl,
                             p_validity_date      => G_GL_DATE);

           IF (l_return_status <> OKL_API.G_RET_STS_SUCCESS) THEN
             RAISE OKL_API.G_EXCEPTION_ERROR;
           END IF;

           --Setting l_first_rec to FALSE, so that GET_TEMPLATE_INFO need not be called every time in the loop
           l_first_rec :=  FALSE;

           IF (G_IS_DEBUG_STATEMENT_ON = true) THEN
              OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE,'The return status after the Get_Template_Info call is :'||l_return_status);
           END IF;

           -- Raise an error if template is not found.
           IF (l_tmpl_tbl.COUNT = 0) THEN
             -- Added by Santonyr on 30-Jul-2003 to fix the bug 2941805
             FOR prdt_rec IN prdt_csr (p_tmpl_identify_rec.product_id) LOOP
               l_product_name := prdt_rec.name;
             END LOOP;

             FOR trx_type_rec IN trx_type_csr (p_tmpl_identify_rec.transaction_type_id) LOOP
               l_trx_type_name := trx_type_rec.name;
             END LOOP;

             FOR sty_type_rec IN sty_type_csr (p_tmpl_identify_rec.stream_type_id) LOOP
               l_sty_type_name := sty_type_rec.name;
             END LOOP;

             OKL_API.SET_MESSAGE(p_app_name     => g_app_name
                                ,p_msg_name     => 'OKL_TMPL_NOT_FOUND'
                                ,p_token1        => 'PRODUCT'
                                ,p_token1_value  => l_product_name
                                ,p_token2        => 'TRANSACTION_TYPE'
                                ,p_token2_value  => l_trx_type_name
                       ,p_token3        => 'STREAM_TYPE'
                                ,p_token3_value  => NVL(l_sty_type_name,  ' ')
                       ,p_token4        => 'ACCOUNTING_DATE'
                                ,p_token4_value  => G_GL_DATE);


             RAISE OKL_API.G_EXCEPTION_ERROR;
           END IF;
         END IF;

         -- Check the Distribution Status and take appropriate Action
         l_check_status := CHECK_JOURNAL(p_source_id    =>  l_dist_info_tbl(i).source_id,
                                         p_source_table =>  l_dist_info_tbl(i).source_table);


         -- l_check_status = 1 denotes that the distributions in OKL exist, but journals have not yet been created in SLA
         -- l_check_status = 2 denotes that the distributions exist in OKL , and journals have been created in SLA
         IF (l_check_status = 1) THEN
           -- Delete from Distributions
           DELETE_DIST_AE(p_flag          => 'DIST',
                         p_source_id     => l_dist_info_tbl(i).source_id,
                         p_source_table  => l_dist_info_tbl(i).source_table,
                         x_return_status => l_return_status);

           IF (l_return_status <> OKL_API.G_RET_STS_SUCCESS) THEN
              RAISE OKL_API.G_EXCEPTION_ERROR;
           END IF;

         END IF;

         IF (l_check_status = 2) THEN
           OKL_API.SET_MESSAGE(p_app_name     => g_app_name,
                               p_msg_name     => 'OKL_AE_GONE_TO_SLA');
           RAISE OKL_API.G_EXCEPTION_ERROR;
         END IF;

         FOR j IN 1..l_tmpl_tbl.COUNT
         LOOP
           tmpl_rec := l_tmpl_tbl(j);

           IF (l_dist_info_tbl(i).AMOUNT IS NULL) OR
              (l_dist_info_tbl(i).AMOUNT = OKL_API.G_MISS_NUM) THEN

              -- If the amount is null calculate the amount using formula engine
              IF (tmpl_rec.FMA_ID IS NULL) OR
                 (tmpl_rec.FMA_ID = OKL_API.G_MISS_NUM) THEN
                -- If the formula is not found associated with template
                    OKL_API.SET_MESSAGE(p_app_name     => g_app_name,
                                        p_msg_name     => 'OKL_FMA_NOT_PRESENT',
                                        p_token1       => 'TEMPLATE_NAME',
                                        p_token1_value => tmpl_rec.NAME);
                    RAISE OKL_API.G_EXCEPTION_ERROR;
              END IF;

              OPEN frml_csr(tmpl_rec.fma_id);
              FETCH frml_csr INTO l_formula_name;
              CLOSE frml_csr;

              -- Execute the formula using formula engine.

              GET_CONTEXT_VAL(p_source_id    => p_dist_info_tbl(i).source_id
                             ,p_ctxt_tbl     => p_ctxt_val_tbl
                             ,x_ctxt_val_tbl =>  l_ctxt_val_tbl);


              -- For secondary rep txn, set the security policy for streams. MG uptake
              IF g_representation_type = 'SECONDARY' THEN
                OKL_STREAMS_SEC_PVT.SET_REPO_STREAMS;
              END IF;

              EXECUTE_FORMULA(p_avlv_rec            => tmpl_rec,
                              p_contract_id         => l_dist_info_tbl(i).contract_id,
                              p_contract_line_id    => l_dist_info_tbl(i).contract_line_id,
                              p_ctxt_val_tbl        => l_ctxt_val_tbl,
                              x_return_status       => l_return_status,
                              x_amount              => l_amount );

              IF (l_return_status <> OKL_API.G_RET_STS_SUCCESS) THEN
                   OKL_API.SET_MESSAGE(p_app_name     => g_app_name,
                                       p_msg_name     => 'OKL_FRML_EXE_FAILED',
                                       p_token1       => 'FORMULA_NAME',
                                       p_token1_value => l_formula_name);

              END IF;

              -- For secondary rep txn, reset the security policy for streams. MG uptake
              IF g_representation_type = 'SECONDARY' THEN
                OKL_STREAMS_SEC_PVT.RESET_REPO_STREAMS;
              END IF;

              IF (l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
                  RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
              ELSIF (l_return_status = OKL_API.G_RET_STS_ERROR) THEN
                  RAISE OKL_API.G_EXCEPTION_ERROR;
              END IF;
           ELSE -- If the amount is passed from the caller (amount is not null).
              l_amount  := l_dist_info_tbl(i).AMOUNT;
           END IF;  -- End If for (p_dist_info_rec.AMOUNT IS NULL)

           -- If amount passes is Zero or Amount got from formula is zero then a
           -- message should be displayed.

           IF (l_amount = 0) THEN
               OKL_API.SET_MESSAGE(p_app_name     => g_app_name,
                                   p_msg_name     => 'OKL_FRML_RET_ZERO_AMT',
                                   p_token1       => 'TEMPLATE_NAME',
                                   p_token1_value => tmpl_rec.NAME);
           -- Santonyr on 14-Jul-2003 Fixed bug 3048686
           --     RAISE OKL_API.G_EXCEPTION_ERROR;
           END IF;

           --Building a reference between the dist_info rec and x_template_tbl
           x_template_tbl(i).template_tbl(j) := tmpl_rec;
           x_template_tbl(i).source_id := l_dist_info_tbl(i).source_id;
           x_amount_tbl(i).amount_tbl(j) := Okl_Accounting_Util.ROUND_AMOUNT(p_amount        => l_amount,
                                                                                         p_currency_code => p_dist_info_tbl(i).currency_code);
           x_amount_tbl(i).source_id := l_dist_info_tbl(i).source_id;

           --Fetch the Account gen table corresponding to the source_id of the current distribution record
           GET_ACC_GEN_TBL(p_source_id            => p_dist_info_tbl(i).source_id,
                           p_gen_table            => p_acc_gen_primary_key_tbl,
                           x_acc_gen_tbl_ret      => p_acc_gen_tbl_ret);

           IF (l_amount <> 0) THEN
               IF (l_account_derivation = 'ATS')
               THEN
                 CREATE_DIST_RECS(p_avlv_rec           => tmpl_rec,
                                  p_tmpl_identify_rec  => p_tmpl_identify_rec,
                                  p_dist_info_rec      => l_dist_info_tbl(i),
                                  p_amount             => l_amount,
                                  p_gen_table          => p_acc_gen_tbl_ret,
                                  x_return_status      => l_return_status,
  x_tabv_tbl           => l_tabv_tbl_out);

                 IF (l_return_status <> OKL_API.G_RET_STS_SUCCESS) THEN
                    RAISE OKL_API.G_EXCEPTION_ERROR;
                 END IF;
               ELSIF (l_account_derivation = 'AMB')
   THEN
                 CREATE_DIST_RECS(--Bug 6127326 dpsingh start
                                  p_avlv_rec           => tmpl_rec,
                                  --Bug 6127326 dpsingh end
                                  p_tmpl_identify_rec  => p_tmpl_identify_rec,
                                  p_dist_info_rec      => l_dist_info_tbl(i),
                                  p_amount             => l_amount,
                                  x_return_status      => l_return_status,
  x_tabv_tbl           => l_tabv_tbl_out);

                 IF (l_return_status <> OKL_API.G_RET_STS_SUCCESS) THEN
                    RAISE OKL_API.G_EXCEPTION_ERROR;
                 END IF;
   END IF;
           END IF;  -- End If for (l_amount <> 0)

           IF (l_tabv_tbl_final.COUNT = 0) THEN
              k := 0;
           ELSE
      k := l_tabv_tbl_final.COUNT;
           END IF;

   IF (l_tabv_tbl_out.count > 0) THEN
             FOR i in l_tabv_tbl_out.FIRST..l_tabv_tbl_out.LAST
             LOOP
                l_tabv_tbl_final(k).id := l_tabv_tbl_out(i).id;
                k := k + 1;
             END LOOP;
           END IF;

         END LOOP;  -- End LOOP for (l_tmpl_tbl.COUNT)

       --Else when the account derivation option is 'AMB' and the transaction amount is already known
       ELSE
        --Assinging the amount being passed in the rec to l_amount
        l_amount := l_dist_info_tbl(i).amount;

        --Deriving the functional currency to be passed in the call to validate_params
        l_functional_curr := Okl_Accounting_Util.GET_FUNC_CURR_CODE;

        -- Check the Distribution Status and take appropriate Action
        l_check_status := CHECK_JOURNAL(p_source_id    =>  l_dist_info_tbl(i).source_id,
                                        p_source_table =>  l_dist_info_tbl(i).source_table);

        -- l_check_status = 1 denotes that the distributions in OKL exist, but journals have not yet been created in SLA
        -- l_check_status = 2 denotes that the distributions exist in OKL , and journals have been created in SLA


        IF (l_check_status = 1) THEN
           -- Delete from Distributions
           DELETE_DIST_AE(p_flag          => 'DIST',
                         p_source_id     => l_dist_info_tbl(i).source_id,
                         p_source_table  => l_dist_info_tbl(i).source_table,
                         x_return_status => l_return_status);

           IF (l_return_status <> OKL_API.G_RET_STS_SUCCESS) THEN
              RAISE OKL_API.G_EXCEPTION_ERROR;
           END IF;

        END IF;

        IF (l_check_status = 2) THEN
           OKL_API.SET_MESSAGE(p_app_name     => g_app_name,
                               p_msg_name     => 'OKL_AE_GONE_TO_SLA');
           RAISE OKL_API.G_EXCEPTION_ERROR;
        END IF;

        l_amount := l_dist_info_tbl(i).amount;

        IF (l_amount <> 0) THEN

            CREATE_DIST_RECS(p_tmpl_identify_rec  => p_tmpl_identify_rec,
                             p_dist_info_rec      => l_dist_info_tbl(i),
                             p_amount             => l_amount,
                             x_return_status      => l_return_status,
 x_tabv_tbl           => l_tabv_tbl_out);

            IF (l_return_status <> OKL_API.G_RET_STS_SUCCESS) THEN
                RAISE OKL_API.G_EXCEPTION_ERROR;
            END IF;
        END IF;  -- End If for (l_amount <> 0)

        x_amount_tbl(i).amount_tbl(0) := Okl_Accounting_Util.ROUND_AMOUNT(p_amount        => l_amount,
                                                                                     p_currency_code => p_dist_info_tbl(i).currency_code);
        x_amount_tbl(i).source_id := l_dist_info_tbl(i).source_id;


        IF (l_tabv_tbl_final.COUNT = 0) THEN
           k := 0;
        ELSE
   k := l_tabv_tbl_final.COUNT;
END IF;

IF (l_tabv_tbl_out.count > 0) THEN
          FOR i in l_tabv_tbl_out.FIRST..l_tabv_tbl_out.LAST
          LOOP
            l_tabv_tbl_final(k).id := l_tabv_tbl_out(i).id;
            k := k + 1;
          END LOOP;
        END IF;
       END IF;
       x_tabv_tbl := l_tabv_tbl_final;
   END LOOP; --End loop for (l_dist_info_tbl.count)
   OKL_API.END_ACTIVITY(x_msg_count, x_msg_data);

EXCEPTION

    WHEN OKL_API.G_EXCEPTION_ERROR THEN
      x_return_status := OKL_API.HANDLE_EXCEPTIONS
      ( l_api_name,
        G_PKG_NAME,
        'OKL_API.G_RET_STS_ERROR',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
    WHEN OKL_API.G_EXCEPTION_UNEXPECTED_ERROR THEN
      x_return_status := OKL_API.HANDLE_EXCEPTIONS
      ( l_api_name,
        G_PKG_NAME,
        'OKL_API.G_RET_STS_UNEXP_ERROR',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
    WHEN OTHERS THEN
      x_return_status := OKL_API.HANDLE_EXCEPTIONS
      ( l_api_name,
        G_PKG_NAME,
        'OTHERS',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );

END CREATE_ACCOUNTING_DIST;

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
                                     p_trx_header_table                  IN  VARCHAR2 DEFAULT NULL)

   IS

     l_check_status   NUMBER;
     i                NUMBER := 0;
     l_amount         NUMBER := 0;

     tmpl_rec         AVLV_REC_TYPE;
     l_tmpl_tbl       avlv_tbl_type;
     l_formula_name   OKL_FORMULAE_V.NAME%TYPE;
     l_functional_curr OKL_TRNS_ACC_DSTRS.CURRENCY_CODE%TYPE;
     l_return_status  VARCHAR2(1) := OKL_API.G_RET_STS_SUCCESS;

     l_api_name       VARCHAR2(30) := 'CREATE_ACCOUNTING_DIST';
     l_api_version    NUMBER := 1.0;

   -- Added by Santonyr on 30-Jul-2003 to fix the bug 2941805

     l_product_name  OKL_PRODUCTS.NAME%TYPE;
     l_trx_type_name OKL_TRX_TYPES_TL.NAME%TYPE;
     l_sty_type_name OKL_STRM_TYPE_TL.NAME%TYPE;

   -- Added by Santonyr on 12-Jul-2440 for the bug 3761026

     l_template_amount_tbl template_amount_tbl_type;
     l_line_tbl    ID_TBL_TYPE;

     CURSOR frml_csr(v_id NUMBER) IS
     SELECT name
     FROM okl_formulae_v
     WHERE id = v_id;

   -- Added by Santonyr on 30-Jul-2003 to fix the bug 2941805

     CURSOR prdt_csr (l_pdt_id OKL_PRODUCTS.ID%TYPE) IS
     SELECT name
     FROM okl_products
     WHERE id = l_pdt_id ;

     CURSOR trx_type_csr (l_trx_type_id OKL_TRX_TYPES_TL.ID%TYPE) IS
     SELECT name
     FROM okl_trx_types_tl
     WHERE id = l_trx_type_id ;

     CURSOR sty_type_csr (l_sty_type_id OKL_STRM_TYPE_TL.ID%TYPE) IS
     SELECT name
     FROM okl_strm_type_tl
     WHERE id = l_sty_type_id ;

     --Added by kthiruva on 06-Feb-2007 for SLA Uptake
     --Bug 5707866 - Start of Changes
     l_account_derivation     OKL_SYS_ACCT_OPTS.ACCOUNT_DERIVATION%TYPE;
     l_tcn_id                 NUMBER := p_trx_header_id;
     l_init_msg_list         VARCHAR2(1) := OKL_API.G_FALSE;
     l_msg_count             NUMBER := 0;
     l_msg_data              VARCHAR2(2000);
     l_event_id              NUMBER;
     l_event_date            DATE;
     l_gl_short_name         GL_LEDGERS.SHORT_NAME%TYPE;
     l_tabv_tbl              tabv_tbl_type ;
     l_tabv_tbl_out          tabv_tbl_type ;
     x_tabv_tbl              tabv_tbl_type ;
     l_dist_info_tbl         dist_info_tbl_type := p_dist_info_tbl;
     l_dist_info_temp_tbl    dist_info_tbl_type;
     l_tmpl_identify_tbl     tmpl_identify_tbl_type := p_tmpl_identify_tbl;
     l_temp_tmpl_rec         tmpl_identify_rec_type;
     l_count                 NUMBER := 0;
     l_ctxt_val_temp_tbl     ctxt_tbl_type;
     l_acc_gen_temp_tbl      acc_gen_tbl_type;
     l_ctxt_val_tbl          ctxt_tbl_type := p_ctxt_val_tbl;
     l_acc_gen_tbl           acc_gen_tbl_type := p_acc_gen_primary_key_tbl;
     x_template_temp_tbl     AVLV_OUT_TBL_TYPE;
     x_amount_temp_tbl       AMOUNT_OUT_TBL_TYPE;
     x_tabv_temp_tbl         TABV_TBL_TYPE;
     l_tcnv_rec              okl_sla_acc_sources_pvt.tehv_rec_type;
     l_tclv_tbl              okl_sla_acc_sources_pvt.telv_tbl_type;
     l_tclv_tbl_final        okl_sla_acc_sources_pvt.telv_tbl_type;
     x_tclv_tbl              okl_sla_acc_sources_pvt.telv_tbl_type;
     l_try_name              OKL_TRX_TYPES_TL.NAME%TYPE;
     l_source_table          VARCHAR2(30);
     l_asev_rec              asev_rec_type;
     l_asev_tbl              asev_tbl_type;
     l_asev_count            NUMBER := 0;
     l_acc_gen_key_tbl       acc_gen_primary_key;
     l_found                 boolean := false;
     l_equal                 boolean := false;
     l_rxhv_rec              okl_sla_acc_sources_pvt.rxhv_rec_type;
     l_rxhv_adj_rec              okl_sla_acc_sources_pvt.rxhv_rec_type;
     l_rxlv_tbl              okl_sla_acc_sources_pvt.rxlv_tbl_type;
     x_rxlv_tbl              okl_sla_acc_sources_pvt.rxlv_tbl_type;
     x_rxlv_adj_tbl              okl_sla_acc_sources_pvt.rxlv_tbl_type;
     l_pxhv_rec              okl_sla_acc_sources_pvt.pxhv_rec_type;
     l_pxlv_tbl              okl_sla_acc_sources_pvt.pxlv_tbl_type;
     x_pxlv_tbl              okl_sla_acc_sources_pvt.pxlv_tbl_type;
     l_rxlv_adj_tbl              okl_sla_acc_sources_pvt.rxlv_tbl_type;

     CURSOR get_tcn_id_csr(p_source_id IN NUMBER)
     IS
     SELECT tcl.tcn_id
     FROM OKL_TXL_CNTRCT_LNS_ALL tcl
     WHERE tcl.id = p_source_id;

	 -- get the ledger based on the p_trx_header_id parameter
	 CURSOR get_ledger_id_csr
	 IS
	 SELECT set_of_books_id
	   FROM okl_trx_contracts
	  WHERE id = p_trx_header_id;

	 l_ledger_id    NUMBER;

     CURSOR get_gl_short_name_csr
     IS
     SELECT GL.SHORT_NAME
     FROM OKL_SYS_ACCT_OPTS SAO,
          GL_LEDGERS GL
     WHERE SAO.SET_OF_BOOKS_ID = GL.LEDGER_ID;

     CURSOR get_trx_type(p_try_id NUMBER)
     IS
     SELECT TRY.AEP_CODE
 FROM OKL_TRX_TYPES_B TRY
 WHERE TRY.ID = p_try_id;

     CURSOR get_acc_event_id(p_tcn_id IN NUMBER)
     IS
     SELECT distinct dist.accounting_event_id
     FROM okl_trns_acc_dstrs_all dist,
          okl_txl_cntrct_lns_all txl,
          okl_trx_contracts_all trx
     WHERE dist.source_id = txl.id
     AND txl.tcn_id = trx.id
     and trx.id = p_tcn_id;

     CURSOR check_sources_csr(p_trx_header_id IN NUMBER)
     IS
     SELECT 1
     FROM OKL_EXT_AR_HEADER_SOURCES_B RXH
     WHERE RXH.SOURCE_ID = p_trx_header_id;

     CURSOR check_ap_sources_csr(p_trx_header_id IN NUMBER)
     IS
     SELECT 1
     FROM OKL_EXT_AP_HEADER_SOURCES_B PXH
     WHERE PXH.SOURCE_ID = p_trx_header_id;

     l_sources_exist     VARCHAR2(1);
     --Bug 5707866 - End of Changes

   BEGIN
      x_return_status := OKL_API.G_RET_STS_SUCCESS;

      l_return_status := OKL_API.START_ACTIVITY(l_api_name,
                                                G_PKG_NAME,
                                                p_init_msg_list,
                                                l_api_version,
                                                p_api_version,
                                                '_PVT',
                                                x_return_status);
      IF (l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
        RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
      ELSIF (l_return_status = OKL_API.G_RET_STS_ERROR) THEN
        RAISE OKL_API.G_EXCEPTION_ERROR;
      END IF;

      VALIDATE_IN_PARAMS(p_dist_info_tbl           => p_dist_info_tbl
                        ,p_tmpl_identify_tbl       => p_tmpl_identify_tbl
                        ,p_ctxt_val_tbl            => p_ctxt_val_tbl
                        ,p_acc_gen_primary_key_tbl => p_acc_gen_primary_key_tbl
,x_return_status           => l_return_status
);

     IF (l_return_status <> OKL_API.G_RET_STS_SUCCESS) THEN
        RAISE OKL_API.G_EXCEPTION_ERROR;
     END IF;

	 -- get the representation attributes.. MG uptake
	    get_rep_attributes;

	  IF NVL(p_trx_header_table, 'OKL_TXL_CNTRCT_LNS') = 'OKL_TXL_CNTRCT_LNS' then
         OPEN get_ledger_id_csr;
         FETCH get_ledger_id_csr INTO l_ledger_id;
         CLOSE get_ledger_id_csr;
	  END IF;

 	   IF l_ledger_id IS NOT NULL THEN
         g_representation_type := g_ledger_tbl(l_ledger_id).rep_type;
         g_ledger_id := l_ledger_id;
	   ELSE
	     g_representation_type := 'PRIMARY';
	     g_ledger_id := okl_accounting_util.get_set_of_books_id;
	   END IF;


      --Assigning the first template rec to a temporary rec
      l_temp_tmpl_rec := l_tmpl_identify_tbl(l_tmpl_identify_tbl.FIRST);

      FOR i in l_dist_info_tbl.FIRST..l_dist_info_tbl.LAST
      LOOP
        IF (nvl(l_tmpl_identify_tbl(i).STREAM_TYPE_ID,1) = nvl(l_temp_tmpl_rec.STREAM_TYPE_ID,1)) AND
           (nvl(l_tmpl_identify_tbl(i).ADVANCE_ARREARS,1) = nvl(l_temp_tmpl_rec.ADVANCE_ARREARS,1)) AND
           (nvl(l_tmpl_identify_tbl(i).FACTORING_SYND_FLAG,1) = nvl(l_temp_tmpl_rec.FACTORING_SYND_FLAG,1)) AND
           (nvl(l_tmpl_identify_tbl(i).SYNDICATION_CODE,1) = nvl(l_temp_tmpl_rec.SYNDICATION_CODE,1)) AND
           (nvl(l_tmpl_identify_tbl(i).FACTORING_CODE,1) = nvl(l_temp_tmpl_rec.FACTORING_CODE,1)) AND
           (nvl(l_tmpl_identify_tbl(i).MEMO_YN,1) = nvl(l_temp_tmpl_rec.MEMO_YN,1)) AND
           (nvl(l_tmpl_identify_tbl(i).PRIOR_YEAR_YN,1) = nvl(l_temp_tmpl_rec.PRIOR_YEAR_YN,1)) AND
           (nvl(l_tmpl_identify_tbl(i).REV_REC_FLAG,1) = nvl(l_temp_tmpl_rec.REV_REC_FLAG,1))
        THEN
           l_dist_info_temp_tbl(l_count) :=  l_dist_info_tbl(i);
           IF (l_ctxt_val_tbl.count >0) THEN
             l_ctxt_val_temp_tbl(l_count)  :=  l_ctxt_val_tbl(i);
           END IF;
           l_acc_gen_temp_tbl(l_count)   :=  l_acc_gen_tbl(i);
           l_count := l_count + 1;
        ELSE
           CREATE_ACCOUNTING_DIST(p_api_version              => p_api_version,
                                  p_init_msg_list            => p_init_msg_list,
                                  x_return_status            => x_return_status,
                                  x_msg_count                => x_msg_count,
                                  x_msg_data                 => x_msg_data,
                                  p_tmpl_identify_rec        => l_temp_tmpl_rec,
                                  p_dist_info_tbl            => l_dist_info_temp_tbl,
                                  p_ctxt_val_tbl             => l_ctxt_val_temp_tbl,
                                  p_acc_gen_primary_key_tbl  => l_acc_gen_temp_tbl,
                                  x_template_tbl             => x_template_temp_tbl,
                                  x_amount_tbl               => x_amount_temp_tbl,
                                  x_tabv_tbl                 => x_tabv_temp_tbl);

           IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
             RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
           ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
             RAISE OKL_API.G_EXCEPTION_ERROR;
           END IF;

           --The out parameters from each call are consolidated and built
           GET_FINAL_TEMPLATE_TBL(p_template_tbl => x_template_temp_tbl,
                                  x_template_tbl => x_template_tbl);

           GET_FINAL_AMOUNT_TBL(p_amount_tbl => x_amount_temp_tbl,
                                x_amount_tbl => x_amount_tbl);

           GET_FINAL_TABV_TBL(p_tabv_tbl   => x_tabv_temp_tbl,
                              x_tabv_tbl   => l_tabv_tbl_out);

           --The existing temp tables need to be cleared and reassigned
           l_count := 0;
           l_dist_info_temp_tbl.DELETE;
           l_ctxt_val_temp_tbl.DELETE;
           l_acc_gen_temp_tbl.DELETE;
           l_temp_tmpl_rec := l_tmpl_identify_tbl(i);

           l_dist_info_temp_tbl(l_count) :=  l_dist_info_tbl(i);
           IF (l_ctxt_val_tbl.count >0) THEN
              l_ctxt_val_temp_tbl(l_count)  :=  l_ctxt_val_tbl(i);
           END IF;
           l_acc_gen_temp_tbl(l_count)   :=  l_acc_gen_tbl(i);
           l_count := l_count + 1;
         END IF;
      END LOOP;

      --Making the create_Dist call for the last record
      CREATE_ACCOUNTING_DIST(p_api_version              => p_api_version,
                             p_init_msg_list            => p_init_msg_list,
                             x_return_status            => x_return_status,
                             x_msg_count                => x_msg_count,
                             x_msg_data                 => x_msg_data,
                             p_tmpl_identify_rec        => l_temp_tmpl_rec,
                             p_dist_info_tbl            => l_dist_info_temp_tbl,
                             p_ctxt_val_tbl             => l_ctxt_val_temp_tbl,
                             p_acc_gen_primary_key_tbl  => l_acc_gen_temp_tbl,
                             x_template_tbl             => x_template_temp_tbl,
                             x_amount_tbl               => x_amount_temp_tbl,
                             x_tabv_tbl                 => x_tabv_temp_tbl);

       IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
           RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
       ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
           RAISE OKL_API.G_EXCEPTION_ERROR;
       END IF;

       --The out parameters from each call are consolidated and built
       GET_FINAL_TEMPLATE_TBL(p_template_tbl => x_template_temp_tbl,
                              x_template_tbl => x_template_tbl);

       GET_FINAL_AMOUNT_TBL(p_amount_tbl => x_amount_temp_tbl,
                            x_amount_tbl => x_amount_tbl);

       GET_FINAL_TABV_TBL(p_tabv_tbl   => x_tabv_temp_tbl,
                          x_tabv_tbl   => l_tabv_tbl_out);

   OPEN get_trx_type(l_temp_tmpl_rec.transaction_type_id);
       FETCH get_trx_type INTO l_try_name;
       CLOSE get_trx_type;

       --Added by kthiruva on 03-Jul-2007
       --Event creation should be done only if there is atleast one transaction line evaluating to a non-zero amount
       --Sources need to be captured only for those transaction lines that evaluate to a non-zero amount
   --Bug 6134235 - Start of Changes
       GET_LINE_ID_TBL(p_amount_tbl => x_amount_tbl,
                       x_line_tbl => l_line_tbl);
       --Bug 6134235 - End of Changes

      --This cursor is used to determine ,if distributions already exist for the transaction id
      -- If an accounting event already exists , else we create a new event
      IF l_try_name IN ('RECEIPT_APPLICATION','PRINCIPAL_ADJUSTMENT','UPFRONT_TAX','BOOKING','TERMINATION',
   'ASSET_DISPOSITION','ACCRUAL','GENERAL_LOSS_PROVISION','SPECIFIC_LOSS_PROVISION','REBOOK','EVERGREEN',
   'RELEASE','INVESTOR','SPLIT_ASSET') AND (l_line_tbl.count > 0)
      THEN
        --Populated for the calls to delete/create Account Sources
        l_tcnv_rec.source_id := p_trx_header_id;
        l_tcnv_rec.source_table := 'OKL_TRX_CONTRACTS';

        OPEN get_acc_event_id(p_trx_header_id);
        FETCH get_acc_event_id INTO l_event_id;
        CLOSE get_acc_event_id;

        IF (l_event_id IS NOT NULL) THEN
    --Make the call to delete existing sources
          okl_sla_acc_sources_pvt.delete_trx_extension(
                           p_api_version               => l_api_version
                          ,p_init_msg_list             => l_init_msg_list
                          ,p_trans_hdr_rec             => l_tcnv_rec
                          ,x_trans_line_tbl            => x_tclv_tbl
                          ,x_return_status             => l_return_status
                          ,x_msg_count                 => l_msg_count
                          ,x_msg_data                  => l_msg_data
                          );

          IF (l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
             OKL_API.SET_MESSAGE(p_app_name     => g_app_name
                                ,p_msg_name     => 'OKL_DEL_SOURCES_FAILED');
             RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
          ELSIF (l_return_status = OKL_API.G_RET_STS_ERROR) THEN
             OKL_API.SET_MESSAGE(p_app_name     => g_app_name
                                ,p_msg_name     => 'OKL_DEL_SOURCES_FAILED');
             RAISE OKL_API.G_EXCEPTION_ERROR;
          END IF;
        --As event_id is not found, we create a new event
    ELSE
          --The below code is not required after MG uptake.. racheruv
          --OPEN get_gl_short_name_csr;
          --FETCH get_gl_short_name_csr INTO l_gl_short_name;
          --CLOSE get_gl_short_name_csr;

        -- set the representation code, which is used as the valuation method
        -- MG uptake.
	      l_gl_short_name := g_ledger_tbl(g_ledger_id).rep_code;

          IF l_gl_short_name IS NULL
          THEN
             OKL_API.SET_MESSAGE(p_app_name      => g_app_name
                                ,p_msg_name      => 'OKL_GL_NOT_SET_FOR_ORG');
             RAISE OKL_API.G_EXCEPTION_ERROR;
          END IF;

          l_event_id := OKL_XLA_EVENTS_PVT.create_event(p_api_version        => l_api_version
                                                       ,p_init_msg_list      => l_init_msg_list
                                                       ,x_return_status      => l_return_status
                                                       ,x_msg_count          => l_msg_count
                                                       ,x_msg_data           => l_msg_data
                                                       ,p_tcn_id             => l_tcn_id
                                                       ,p_gl_date            => G_gl_date
                                                       ,p_action_type        => 'CREATE'
                                                       ,p_representation_code   => l_gl_short_name
                                                       );

          IF (l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
             OKL_API.SET_MESSAGE(p_app_name     => g_app_name
                               ,p_msg_name     => 'OKL_CREATE_EVENT_FAILED');
             RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
          ELSIF (l_return_status = OKL_API.G_RET_STS_ERROR) THEN
             OKL_API.SET_MESSAGE(p_app_name     => g_app_name
                               ,p_msg_name     => 'OKL_CREATE_EVENT_FAILED');
             RAISE OKL_API.G_EXCEPTION_ERROR;
          END IF;
        END IF;--(IF l_event_id is null)

        IF (l_tabv_tbl_out.count > 0) THEN
          --Populating the distribution table that needs to be updated with accounting_event_id
          FOR i IN l_tabv_tbl_out.FIRST..l_tabv_tbl_out.LAST
      LOOP
         l_tabv_tbl(i).id                  := l_tabv_tbl_out(i).id;
         l_tabv_tbl(i).accounting_event_id := l_event_id;
             --Once the event is created successfully in XLA, posted_yn flag is set to Y
             l_tabv_tbl(i).posted_yn           := 'Y';
      END LOOP;

      --Update the distributions created with the Accounting Event Id
          OKL_TRNS_ACC_DSTRS_PUB.update_trns_acc_dstrs(p_api_version    => l_api_version
                                                    ,p_init_msg_list  => l_init_msg_list
                                                    ,x_return_status  => l_return_status
                                                    ,x_msg_count      => l_msg_count
                                                    ,x_msg_data       => l_msg_data
                                                    ,p_tabv_tbl       => l_tabv_tbl
                                                    ,x_tabv_tbl       => x_tabv_tbl
                                                    );

          IF (l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
            OKL_API.SET_MESSAGE(p_app_name     => g_app_name
                               ,p_msg_name     => 'OKL_UPD_DIST_FAILED');
            RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
          ELSIF (l_return_status = OKL_API.G_RET_STS_ERROR) THEN
            OKL_API.SET_MESSAGE(p_app_name     => g_app_name
                               ,p_msg_name     => 'OKL_UPD_DIST_FAILED');
            RAISE OKL_API.G_EXCEPTION_ERROR;
          END IF;
        END IF;

IF p_dist_info_tbl.count = l_line_tbl.count THEN
  l_equal := true;
    END IF;

        --Making the call to populate_Acct_sources to retreive the l_asev_rec to be passed to populate_sources
FOR i in p_dist_info_tbl.FIRST..p_dist_info_tbl.LAST
LOOP
    l_found := false;
  IF not(l_equal) THEN
    --If the l_line_tbl and p_dist_info_tbl count do not match, then there are some transaction lines of
    --zero amount. Therefore processing only those records in p_dist_info_tbl that exist in l_line_tbl
    --asev_rec needs to be fetched only for those lines in l_line_tbl
            FOR j in l_line_tbl.FIRST..l_line_tbl.LAST
            LOOP
              IF (p_dist_info_tbl(i).source_id = l_line_tbl(j)) THEN
                l_found := true;
              END IF;
            END LOOP;
           END IF;

           IF (l_found) OR (l_equal) THEN

     --The index i should refer to the corresponding records in p_dist_info_tbl, p_tmpl_identify_tbl and
     --p_acc_gen_primary_key_tbl.Hence the condition. If the condition returns false and the tables are
     --indexed differently, then in the ELSE part, we loop through the entire table and find a match on source_id
     IF p_acc_gen_primary_key_tbl(i).source_id = p_dist_info_tbl(i).source_id
     THEN
       l_acc_gen_key_tbl := p_acc_gen_primary_key_tbl(i).acc_gen_key_tbl;
     ELSE
       FOR j IN p_acc_gen_primary_key_tbl.FIRST..p_acc_gen_primary_key_tbl.LAST
       LOOP
         IF p_dist_info_tbl(i).source_id = p_acc_gen_primary_key_tbl(j).source_id
         THEN
           l_acc_gen_key_tbl := p_acc_gen_primary_key_tbl(j).acc_gen_key_tbl;
           EXIT;
         END IF;
           END LOOP;
          END IF;

              POPULATE_ACCT_SOURCES(p_api_version             => l_api_version,
                                    p_init_msg_list           => l_init_msg_list,
                                    x_return_status           => l_return_status,
                                    x_msg_count               => l_msg_count,
                                    x_msg_data                => l_msg_data,
                                    p_tmpl_identify_rec       => p_tmpl_identify_tbl(i),
                                    p_dist_info_rec           => p_dist_info_tbl(i),
                                    p_acc_gen_primary_key_tbl => l_acc_gen_key_tbl,
                            x_asev_rec                => l_asev_rec);

              IF (l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
                 OKL_API.SET_MESSAGE(p_app_name     => g_app_name
                                    ,p_msg_name     => 'OKL_SLA_SOURCES_FAILED');
                 RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
              ELSIF (l_return_status = OKL_API.G_RET_STS_ERROR) THEN
                 OKL_API.SET_MESSAGE(p_app_name     => g_app_name
                                    ,p_msg_name     => 'OKL_SLA_SOURCES_FAILED');
                 RAISE OKL_API.G_EXCEPTION_ERROR;
              END IF;

      --Building the line table that needs to be sent to the populate sources_call
      l_tclv_tbl(l_asev_count).source_id := p_dist_info_tbl(i).source_id;
  l_tclv_tbl(l_asev_count).source_table := p_dist_info_tbl(i).source_table;
  --Building the asev_table
      l_asev_tbl(l_asev_count) := l_asev_rec;
      l_asev_count             := l_asev_count + 1;
            END IF; --(if l_found)
        END LOOP;

        --Make the call to capture accounting sources for the header for OKL trasaction types only
        OKL_SLA_ACC_SOURCES_PVT.populate_sources
                             (p_api_version    => l_api_version
                             ,p_init_msg_list  => l_init_msg_list
                             ,p_trans_hdr_rec   => l_tcnv_rec
                             ,p_trans_line_tbl  => l_tclv_tbl
                             ,p_acc_sources_tbl => l_asev_tbl
                             ,x_return_status  => l_return_status
                             ,x_msg_count    => l_msg_count
                             ,x_msg_data      => l_msg_data);


        IF (l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
            OKL_API.SET_MESSAGE(p_app_name     => g_app_name
                               ,p_msg_name     => 'OKL_SLA_SOURCES_FAILED');
            RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
        ELSIF (l_return_status = OKL_API.G_RET_STS_ERROR) THEN
            OKL_API.SET_MESSAGE(p_app_name     => g_app_name
                               ,p_msg_name     => 'OKL_SLA_SOURCES_FAILED');
            RAISE OKL_API.G_EXCEPTION_ERROR;
        END IF;
  --If the accounting engine call is being made for a billing transaction , then sources need to be
  --captured at the header and line level. However, for AR transactions, events are not created by OKL
      ELSIF l_try_name IN ('BILLING','CREDIT_MEMO','ROLLOVER_BILLING','ROLLOVER_CREDITMEMO',
       'RELEASE_BILLING','RELEASE_CREDITMEMO') AND (l_line_tbl.count > 0) THEN

        --Populated for the calls to delete/create Account Sources
        l_rxhv_rec.source_id := p_trx_header_id;
        --For AR And AP transactions, p_trx_header_table needs to be passed always.
--Its optional only for OKL Transactions
        IF p_trx_header_table IS NULL THEN
             Okl_Api.set_message(G_APP_NAME,
                     G_INVALID_VALUE,
 G_COL_NAME_TOKEN,
 'SOURCE_TABLE');
             RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
        END IF;
l_rxhv_rec.source_table := p_trx_header_table;

        --Cursor to check if sources already exist for the transaction. IF so , the transaction is being updated
        --and therefore, existing sources need to be deleted and re-captured.
        OPEN check_sources_csr(p_trx_header_id);
        FETCH check_sources_csr INTO l_sources_exist;
        IF (check_sources_csr%FOUND) THEN
    --Make the call to delete existing sources
          okl_sla_acc_sources_pvt.delete_ar_extension(
                           p_api_version               => l_api_version
                          ,p_init_msg_list             => l_init_msg_list
                          ,p_rxhv_rec                  => l_rxhv_rec
                          ,x_rxlv_tbl                  => x_rxlv_tbl
                          ,x_return_status             => l_return_status
                          ,x_msg_count                 => l_msg_count
                          ,x_msg_data                  => l_msg_data
                          );

          IF (l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
             OKL_API.SET_MESSAGE(p_app_name     => g_app_name
                                ,p_msg_name     => 'OKL_DEL_SOURCES_FAILED');
             RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
          ELSIF (l_return_status = OKL_API.G_RET_STS_ERROR) THEN
             OKL_API.SET_MESSAGE(p_app_name     => g_app_name
                                ,p_msg_name     => 'OKL_DEL_SOURCES_FAILED');
             RAISE OKL_API.G_EXCEPTION_ERROR;
          END IF;
        END IF;--(IF l_event_id is null)
        CLOSE check_sources_csr;

IF p_dist_info_tbl.count = l_line_tbl.count THEN
  l_equal := true;
    END IF;

        --Making the call to populate_Acct_sources to retreive the l_asev_rec to be passed to populate_sources
FOR i in p_dist_info_tbl.FIRST..p_dist_info_tbl.LAST
LOOP
    l_found := false;
  IF not(l_equal) THEN
    --If the l_line_tbl and p_dist_info_tbl count do not match, then there are some transaction lines of
    --zero amount. Therefore processing only those records in p_dist_info_tbl that exist in l_line_tbl
    --asev_rec needs to be fetched only for those lines in l_line_tbl
            FOR j in l_line_tbl.FIRST..l_line_tbl.LAST
            LOOP
              IF (p_dist_info_tbl(i).source_id = l_line_tbl(j)) THEN
                l_found := true;
              END IF;
            END LOOP;
           END IF;

           IF (l_found) OR (l_equal) THEN

     --The index i should refer to the corresponding records in p_dist_info_tbl, p_tmpl_identify_tbl and
     --p_acc_gen_primary_key_tbl.Hence the condition. If the condition returns false and the tables are
     --indexed differently, then in the ELSE part, we loop through the entire table and find a match on source_id
     IF p_acc_gen_primary_key_tbl(i).source_id = p_dist_info_tbl(i).source_id
     THEN
       l_acc_gen_key_tbl := p_acc_gen_primary_key_tbl(i).acc_gen_key_tbl;
     ELSE
       FOR j IN p_acc_gen_primary_key_tbl.FIRST..p_acc_gen_primary_key_tbl.LAST
       LOOP
         IF p_dist_info_tbl(i).source_id = p_acc_gen_primary_key_tbl(j).source_id
         THEN
           l_acc_gen_key_tbl := p_acc_gen_primary_key_tbl(j).acc_gen_key_tbl;
           EXIT;
         END IF;
           END LOOP;
          END IF;

              POPULATE_ACCT_SOURCES(p_api_version             => l_api_version,
                                    p_init_msg_list           => l_init_msg_list,
                                    x_return_status           => l_return_status,
                                    x_msg_count               => l_msg_count,
                                    x_msg_data                => l_msg_data,
                                    p_tmpl_identify_rec       => p_tmpl_identify_tbl(i),
                                    p_dist_info_rec           => p_dist_info_tbl(i),
                                    p_acc_gen_primary_key_tbl => l_acc_gen_key_tbl,
                            x_asev_rec                => l_asev_rec);

              IF (l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
                 OKL_API.SET_MESSAGE(p_app_name     => g_app_name
                                    ,p_msg_name     => 'OKL_SLA_SOURCES_FAILED');
                 RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
              ELSIF (l_return_status = OKL_API.G_RET_STS_ERROR) THEN
                 OKL_API.SET_MESSAGE(p_app_name     => g_app_name
                                    ,p_msg_name     => 'OKL_SLA_SOURCES_FAILED');
                 RAISE OKL_API.G_EXCEPTION_ERROR;
              END IF;

      --Building the line table that needs to be sent to the populate sources_call
      l_rxlv_tbl(l_asev_count).source_id := p_dist_info_tbl(i).source_id;
  l_rxlv_tbl(l_asev_count).source_table := p_dist_info_tbl(i).source_table;

      l_asev_tbl(l_asev_count) := l_asev_rec;
      l_asev_count             := l_asev_count + 1;
            END IF; --(if l_found)
        END LOOP;

        --Make the call to capture accounting sources for the header for OKL trasaction types only
        OKL_SLA_ACC_SOURCES_PVT.populate_sources
                             (p_api_version    => l_api_version
                             ,p_init_msg_list  => l_init_msg_list
                             ,p_rxhv_rec          => l_rxhv_rec
                             ,p_rxlv_tbl          => l_rxlv_tbl
                             ,p_acc_sources_tbl   => l_asev_tbl
                             ,x_return_status  => l_return_status
                             ,x_msg_count  => l_msg_count
                             ,x_msg_data      => l_msg_data);


        IF (l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
            OKL_API.SET_MESSAGE(p_app_name     => g_app_name
                               ,p_msg_name     => 'OKL_SLA_SOURCES_FAILED');
            RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
        ELSIF (l_return_status = OKL_API.G_RET_STS_ERROR) THEN
            OKL_API.SET_MESSAGE(p_app_name     => g_app_name
                               ,p_msg_name     => 'OKL_SLA_SOURCES_FAILED');
            RAISE OKL_API.G_EXCEPTION_ERROR;
        END IF;

 --Bug 6316320 dpsingh start
        --If the accounting engine call is being made for a adjustment transaction , then sources need to be
  --captured at the header and line level. However, for AR transactions, events are not created by OKL
      ELSIF l_try_name IN ( 'BALANCE_WRITE_OFF' ,'ADJUSTMENTS') AND (l_line_tbl.count > 0) THEN

        --Populated for the calls to delete/create Account Sources
        l_rxhv_adj_rec.source_id := p_trx_header_id;
        --For AR And AP transactions, p_trx_header_table needs to be passed always.
--Its optional only for OKL Transactions
        IF p_trx_header_table IS NULL THEN
             Okl_Api.set_message(G_APP_NAME,
                     G_INVALID_VALUE,
 G_COL_NAME_TOKEN,
 'SOURCE_TABLE');
             RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
        END IF;
l_rxhv_adj_rec.source_table := p_trx_header_table;

        --Cursor to check if sources already exist for the transaction. IF so , the transaction is being updated
        --and therefore, existing sources need to be deleted and re-captured.
        OPEN check_sources_csr(p_trx_header_id);
        FETCH check_sources_csr INTO l_sources_exist;
        IF (check_sources_csr%FOUND) THEN
    --Make the call to delete existing sources
          okl_sla_acc_sources_pvt.delete_ar_extension(
                           p_api_version               => l_api_version
                          ,p_init_msg_list             => l_init_msg_list
                          ,p_rxhv_rec                  => l_rxhv_adj_rec
                          ,x_rxlv_tbl                  => x_rxlv_adj_tbl
                          ,x_return_status             => l_return_status
                          ,x_msg_count                 => l_msg_count
                          ,x_msg_data                  => l_msg_data
                          );

          IF (l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
             OKL_API.SET_MESSAGE(p_app_name     => g_app_name
                                ,p_msg_name     => 'OKL_DEL_SOURCES_FAILED');
             RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
          ELSIF (l_return_status = OKL_API.G_RET_STS_ERROR) THEN
             OKL_API.SET_MESSAGE(p_app_name     => g_app_name
                                ,p_msg_name     => 'OKL_DEL_SOURCES_FAILED');
             RAISE OKL_API.G_EXCEPTION_ERROR;
          END IF;
        END IF;--(IF l_event_id is null)
        CLOSE check_sources_csr;

IF p_dist_info_tbl.count = l_line_tbl.count THEN
  l_equal := true;
    END IF;

        --Making the call to populate_Acct_sources to retreive the l_asev_rec to be passed to populate_sources
FOR i in p_dist_info_tbl.FIRST..p_dist_info_tbl.LAST
LOOP
    l_found := false;
  IF not(l_equal) THEN
    --If the l_line_tbl and p_dist_info_tbl count do not match, then there are some transaction lines of
    --zero amount. Therefore processing only those records in p_dist_info_tbl that exist in l_line_tbl
    --asev_rec needs to be fetched only for those lines in l_line_tbl
            FOR j in l_line_tbl.FIRST..l_line_tbl.LAST
            LOOP
              IF (p_dist_info_tbl(i).source_id = l_line_tbl(j)) THEN
                l_found := true;
              END IF;
            END LOOP;
           END IF;

           IF (l_found) OR (l_equal) THEN

     --The index i should refer to the corresponding records in p_dist_info_tbl, p_tmpl_identify_tbl and
     --p_acc_gen_primary_key_tbl.Hence the condition. If the condition returns false and the tables are
     --indexed differently, then in the ELSE part, we loop through the entire table and find a match on source_id
     IF p_acc_gen_primary_key_tbl(i).source_id = p_dist_info_tbl(i).source_id
     THEN
       l_acc_gen_key_tbl := p_acc_gen_primary_key_tbl(i).acc_gen_key_tbl;
     ELSE
       FOR j IN p_acc_gen_primary_key_tbl.FIRST..p_acc_gen_primary_key_tbl.LAST
       LOOP
         IF p_dist_info_tbl(i).source_id = p_acc_gen_primary_key_tbl(j).source_id
         THEN
           l_acc_gen_key_tbl := p_acc_gen_primary_key_tbl(j).acc_gen_key_tbl;
           EXIT;
         END IF;
           END LOOP;
          END IF;

              POPULATE_ACCT_SOURCES(p_api_version             => l_api_version,
                                    p_init_msg_list           => l_init_msg_list,
                                    x_return_status           => l_return_status,
                                    x_msg_count               => l_msg_count,
                                    x_msg_data                => l_msg_data,
                                    p_tmpl_identify_rec       => p_tmpl_identify_tbl(i),
                                    p_dist_info_rec           => p_dist_info_tbl(i),
                                    p_acc_gen_primary_key_tbl => l_acc_gen_key_tbl,
                            x_asev_rec                => l_asev_rec);

              IF (l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
                 OKL_API.SET_MESSAGE(p_app_name     => g_app_name
                                    ,p_msg_name     => 'OKL_SLA_SOURCES_FAILED');
                 RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
              ELSIF (l_return_status = OKL_API.G_RET_STS_ERROR) THEN
                 OKL_API.SET_MESSAGE(p_app_name     => g_app_name
                                    ,p_msg_name     => 'OKL_SLA_SOURCES_FAILED');
                 RAISE OKL_API.G_EXCEPTION_ERROR;
              END IF;

      --Building the line table that needs to be sent to the populate sources_call
      l_rxlv_adj_tbl(l_asev_count).source_id := p_dist_info_tbl(i).source_id;
      l_rxlv_adj_tbl(l_asev_count).source_table := p_dist_info_tbl(i).source_table;

      l_asev_tbl(l_asev_count) := l_asev_rec;
      l_asev_count             := l_asev_count + 1;
            END IF; --(if l_found)
        END LOOP;

        --Make the call to capture accounting sources for the header for OKL trasaction types only
        OKL_SLA_ACC_SOURCES_PVT.populate_sources
                             (p_api_version    => l_api_version
                             ,p_init_msg_list  => l_init_msg_list
                             ,p_rxhv_rec          => l_rxhv_adj_rec
                             ,p_rxlv_tbl          => l_rxlv_adj_tbl
                             ,p_acc_sources_tbl   => l_asev_tbl
                             ,x_return_status  => l_return_status
                             ,x_msg_count  => l_msg_count
                             ,x_msg_data      => l_msg_data);

        IF (l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
            OKL_API.SET_MESSAGE(p_app_name     => g_app_name
                               ,p_msg_name     => 'OKL_SLA_SOURCES_FAILED');
            RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
        ELSIF (l_return_status = OKL_API.G_RET_STS_ERROR) THEN
            OKL_API.SET_MESSAGE(p_app_name     => g_app_name
                               ,p_msg_name     => 'OKL_SLA_SOURCES_FAILED');
            RAISE OKL_API.G_EXCEPTION_ERROR;
        END IF;
  --Bug 6316320 dpsingh end
  --If the accounting engine call is being made for an AP transaction , then sources need to be
  --captured at the header and line level. However, for AP transactions, events are not created by OKL
      ELSIF l_try_name IN ('DISBURSEMENT','FUNDING','DEBIT_NOTE') AND (l_line_tbl.count > 0) THEN

        --Populated for the calls to delete/create Account Sources
        l_pxhv_rec.source_id := p_trx_header_id;
        --For AR And AP transactions, p_trx_header_table needs to be passed always.
--Its optional only for OKL Transactions
        IF p_trx_header_table IS NULL THEN
             Okl_Api.set_message(G_APP_NAME,
                     G_INVALID_VALUE,
 G_COL_NAME_TOKEN,
 'SOURCE_TABLE');
             RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
        END IF;
l_pxhv_rec.source_table := p_trx_header_table;

        --Cursor to check if sources already exist for the transaction. IF so , the transaction is being updated
        --and therefore, existing sources need to be deleted and re-captured.
        OPEN check_ap_sources_csr(p_trx_header_id);
        FETCH check_ap_sources_csr INTO l_sources_exist;
        IF (check_ap_sources_csr%FOUND) THEN
    --Make the call to delete existing sources
          okl_sla_acc_sources_pvt.delete_ap_extension(
                           p_api_version               => l_api_version
                          ,p_init_msg_list             => l_init_msg_list
                          ,p_pxhv_rec                  => l_pxhv_rec
                          ,x_pxlv_tbl                  => x_pxlv_tbl
                          ,x_return_status             => l_return_status
                          ,x_msg_count                 => l_msg_count
                          ,x_msg_data                  => l_msg_data
                          );

          IF (l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
             OKL_API.SET_MESSAGE(p_app_name     => g_app_name
                                ,p_msg_name     => 'OKL_DEL_SOURCES_FAILED');
             RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
          ELSIF (l_return_status = OKL_API.G_RET_STS_ERROR) THEN
             OKL_API.SET_MESSAGE(p_app_name     => g_app_name
                                ,p_msg_name     => 'OKL_DEL_SOURCES_FAILED');
             RAISE OKL_API.G_EXCEPTION_ERROR;
          END IF;
        END IF;
        CLOSE check_ap_sources_csr;

IF p_dist_info_tbl.count = l_line_tbl.count THEN
  l_equal := true;
    END IF;

        --Making the call to populate_Acct_sources to retreive the l_asev_rec to be passed to populate_sources
FOR i in p_dist_info_tbl.FIRST..p_dist_info_tbl.LAST
LOOP
    l_found := false;
  IF not(l_equal) THEN
    --If the l_line_tbl and p_dist_info_tbl count do not match, then there are some transaction lines of
    --zero amount. Therefore processing only those records in p_dist_info_tbl that exist in l_line_tbl
    --asev_rec needs to be fetched only for those lines in l_line_tbl
            FOR j in l_line_tbl.FIRST..l_line_tbl.LAST
            LOOP
              IF (p_dist_info_tbl(i).source_id = l_line_tbl(j)) THEN
                l_found := true;
              END IF;
            END LOOP;
           END IF;

           IF (l_found) OR (l_equal) THEN

     --The index i should refer to the corresponding records in p_dist_info_tbl, p_tmpl_identify_tbl and
     --p_acc_gen_primary_key_tbl.Hence the condition. If the condition returns false and the tables are
     --indexed differently, then in the ELSE part, we loop through the entire table and find a match on source_id
     IF p_acc_gen_primary_key_tbl(i).source_id = p_dist_info_tbl(i).source_id
     THEN
       l_acc_gen_key_tbl := p_acc_gen_primary_key_tbl(i).acc_gen_key_tbl;
     ELSE
       FOR j IN p_acc_gen_primary_key_tbl.FIRST..p_acc_gen_primary_key_tbl.LAST
       LOOP
         IF p_dist_info_tbl(i).source_id = p_acc_gen_primary_key_tbl(j).source_id
         THEN
           l_acc_gen_key_tbl := p_acc_gen_primary_key_tbl(j).acc_gen_key_tbl;
           EXIT;
         END IF;
           END LOOP;
          END IF;

              POPULATE_ACCT_SOURCES(p_api_version             => l_api_version,
                                    p_init_msg_list           => l_init_msg_list,
                                    x_return_status           => l_return_status,
                                    x_msg_count               => l_msg_count,
                                    x_msg_data                => l_msg_data,
                                    p_tmpl_identify_rec       => p_tmpl_identify_tbl(i),
                                    p_dist_info_rec           => p_dist_info_tbl(i),
                                    p_acc_gen_primary_key_tbl => l_acc_gen_key_tbl,
                            x_asev_rec                => l_asev_rec);

              IF (l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
                 OKL_API.SET_MESSAGE(p_app_name     => g_app_name
                                    ,p_msg_name     => 'OKL_SLA_SOURCES_FAILED');
                 RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
              ELSIF (l_return_status = OKL_API.G_RET_STS_ERROR) THEN
                 OKL_API.SET_MESSAGE(p_app_name     => g_app_name
                                    ,p_msg_name     => 'OKL_SLA_SOURCES_FAILED');
                 RAISE OKL_API.G_EXCEPTION_ERROR;
              END IF;

      --Building the line table that needs to be sent to the populate sources_call
      l_pxlv_tbl(l_asev_count).source_id := p_dist_info_tbl(i).source_id;
  l_pxlv_tbl(l_asev_count).source_table := p_dist_info_tbl(i).source_table;

      l_asev_tbl(l_asev_count) := l_asev_rec;
      l_asev_count             := l_asev_count + 1;
            END IF; --(if l_found)
        END LOOP;

        --Make the call to capture accounting sources for the header for OKL trasaction types only
        OKL_SLA_ACC_SOURCES_PVT.populate_sources
                             (p_api_version    => l_api_version
                             ,p_init_msg_list  => l_init_msg_list
                             ,p_pxhv_rec          => l_pxhv_rec
                             ,p_pxlv_tbl          => l_pxlv_tbl
                             ,p_acc_sources_tbl   => l_asev_tbl
                             ,x_return_status  => l_return_status
                             ,x_msg_count  => l_msg_count
                             ,x_msg_data      => l_msg_data);


        IF (l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
            OKL_API.SET_MESSAGE(p_app_name     => g_app_name
                               ,p_msg_name     => 'OKL_SLA_SOURCES_FAILED');
            RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
        ELSIF (l_return_status = OKL_API.G_RET_STS_ERROR) THEN
            OKL_API.SET_MESSAGE(p_app_name     => g_app_name
                               ,p_msg_name     => 'OKL_SLA_SOURCES_FAILED');
            RAISE OKL_API.G_EXCEPTION_ERROR;
        END IF;
  END IF;

      OKL_API.END_ACTIVITY(x_msg_count, x_msg_data);

   EXCEPTION

       WHEN OKL_API.G_EXCEPTION_ERROR THEN
         x_return_status := OKL_API.HANDLE_EXCEPTIONS
         ( l_api_name,
           G_PKG_NAME,
           'OKL_API.G_RET_STS_ERROR',
           x_msg_count,
           x_msg_data,
           '_PVT'
         );
       WHEN OKL_API.G_EXCEPTION_UNEXPECTED_ERROR THEN
         x_return_status := OKL_API.HANDLE_EXCEPTIONS
         ( l_api_name,
           G_PKG_NAME,
           'OKL_API.G_RET_STS_UNEXP_ERROR',
           x_msg_count,
           x_msg_data,
           '_PVT'
         );
       WHEN OTHERS THEN
         x_return_status := OKL_API.HANDLE_EXCEPTIONS
         ( l_api_name,
           G_PKG_NAME,
           'OTHERS',
           x_msg_count,
           x_msg_data,
           '_PVT'
         );

   END CREATE_ACCOUNTING_DIST;

PROCEDURE  REVERSE_ENTRIES(p_api_version                IN         NUMBER,
                           p_init_msg_list              IN         VARCHAR2,
                           x_return_status              OUT        NOCOPY VARCHAR2,
                           x_msg_count                  OUT        NOCOPY NUMBER,
                           x_msg_data                   OUT        NOCOPY VARCHAR2,
                           p_source_id                  IN         NUMBER,
                           p_source_table               IN         VARCHAR2,
                           p_acct_date                  IN         DATE)
IS

BEGIN

-- Start of wraper code generated automatically by Debug code generator for OKL_REVERSAL_PUB.REVERSE_ENTRIES
  IF(L_DEBUG_ENABLED='Y') THEN
    L_LEVEL_PROCEDURE :=FND_LOG.LEVEL_PROCEDURE;
    IS_DEBUG_PROCEDURE_ON := OKL_DEBUG_PUB.Check_Log_On(L_MODULE, L_LEVEL_PROCEDURE);
  END IF;
  IF(IS_DEBUG_PROCEDURE_ON) THEN
    BEGIN
        OKL_DEBUG_PUB.LOG_DEBUG(L_LEVEL_PROCEDURE,L_MODULE,'Begin Debug OKLRTDTB.pls call OKL_REVERSAL_PUB.REVERSE_ENTRIES ');
    END;
  END IF;
    OKL_REVERSAL_PUB.REVERSE_ENTRIES(p_api_version       => p_api_version,
                                     p_init_msg_list     => p_init_msg_list,
                                     x_return_status     => x_return_status,
                                     x_msg_count         => x_msg_count,
                                     x_msg_data          => x_msg_data,
                                     p_source_id         => p_source_id,
                                     p_source_table      => p_source_table,
                                     p_acct_date         => p_acct_date);
  IF(IS_DEBUG_PROCEDURE_ON) THEN
    BEGIN
        OKL_DEBUG_PUB.LOG_DEBUG(L_LEVEL_PROCEDURE,L_MODULE,'End Debug OKLRTDTB.pls call OKL_REVERSAL_PUB.REVERSE_ENTRIES ');
    END;
  END IF;
-- End of wraper code generated automatically by Debug code generator for OKL_REVERSAL_PUB.REVERSE_ENTRIES



END REVERSE_ENTRIES;



PROCEDURE  DELETE_ACCT_ENTRIES(p_api_version                IN         NUMBER,
                               p_init_msg_list              IN         VARCHAR2,
                               x_return_status              OUT        NOCOPY VARCHAR2,
                               x_msg_count                  OUT        NOCOPY NUMBER,
                               x_msg_data                   OUT        NOCOPY VARCHAR2,
                               p_source_id                  IN         NUMBER,
                               p_source_table               IN         VARCHAR2)
IS



  l_return_status  VARCHAR2(1) := OKL_API.G_RET_STS_SUCCESS;
  l_api_name       VARCHAR2(30) := 'DELETE_ACCT_ENTRIES';
  l_api_version    NUMBER := 1.0;
  l_check_Status   NUMBER := 0;


BEGIN

   x_return_status := OKL_API.G_RET_STS_SUCCESS;

   l_return_status := OKL_API.START_ACTIVITY(l_api_name,
                                             G_PKG_NAME,
                                             p_init_msg_list,
                                             l_api_version,
                                             p_api_version,
                                             '_PVT',
                                             x_return_status);
   IF (l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
     RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
   ELSIF (l_return_status = OKL_API.G_RET_STS_ERROR) THEN
     RAISE OKL_API.G_EXCEPTION_ERROR;
   END IF;

   -- Check the Distribution Status and take appropriate Action
   l_check_status := CHECK_JOURNAL(p_source_id    =>  p_source_id,
                                   p_source_table =>  p_source_table);

   -- l_check_status = 1 denotes that the distributions in OKL exist, but journals have not yet been created in SLA
   -- l_check_status = 2 denotes that the distributions exist in OKL , and journals have been created in SLA


   IF (l_check_status = 1) THEN
       -- Delete from Distributions
       DELETE_DIST_AE(p_flag          => 'DIST',
                      p_source_id     => p_source_id,
                      p_source_table  => p_source_table,
                      x_return_status => l_return_status);

       IF (l_return_status <> OKL_API.G_RET_STS_SUCCESS) THEN
          RAISE OKL_API.G_EXCEPTION_ERROR;
       END IF;
    END IF;

    IF (l_check_status = 2) THEN
       OKL_API.SET_MESSAGE(p_app_name     => g_app_name,
                           p_msg_name     => 'OKL_AE_GONE_TO_SLA');
       RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;


    OKL_API.END_ACTIVITY(x_msg_count, x_msg_data);

    x_return_status := OKL_API.G_RET_STS_SUCCESS;

EXCEPTION

    WHEN OKL_API.G_EXCEPTION_ERROR THEN
      x_return_status := OKL_API.HANDLE_EXCEPTIONS
      ( l_api_name,
        G_PKG_NAME,
        'OKL_API.G_RET_STS_ERROR',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
    WHEN OKL_API.G_EXCEPTION_UNEXPECTED_ERROR THEN
      x_return_status := OKL_API.HANDLE_EXCEPTIONS
      ( l_api_name,
        G_PKG_NAME,
        'OKL_API.G_RET_STS_UNEXP_ERROR',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
    WHEN OTHERS THEN
      x_return_status := OKL_API.HANDLE_EXCEPTIONS
      ( l_api_name,
        G_PKG_NAME,
        'OTHERS',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );


END DELETE_ACCT_ENTRIES;

PROCEDURE   CREATE_ACCOUNTING_DIST(p_api_version              IN       NUMBER,
                                   p_init_msg_list            IN       VARCHAR2,
                                   x_return_status            OUT      NOCOPY VARCHAR2,
                                   x_msg_count                OUT      NOCOPY NUMBER,
                                   x_msg_data                 OUT      NOCOPY VARCHAR2,
                                   p_tmpl_identify_rec        IN       TMPL_IDENTIFY_REC_TYPE,
                                   p_dist_info_rec            IN       DIST_INFO_REC_TYPE,
                                   p_ctxt_val_tbl             IN       CTXT_VAL_TBL_TYPE,
                                   p_acc_gen_primary_key_tbl  IN       acc_gen_primary_key,
                                   x_template_tbl             OUT      NOCOPY AVLV_TBL_TYPE,
                                   x_amount_tbl               OUT      NOCOPY AMOUNT_TBL_TYPE,
                                   x_gl_date                  OUT      NOCOPY DATE)
IS
BEGIN

    CREATE_ACCOUNTING_DIST(p_api_version               => p_api_version,
                           p_init_msg_list             => p_init_msg_list,
                           x_return_status             => x_return_status,
                           x_msg_count                 => x_msg_count,
                           x_msg_data                  => x_msg_data,
                           p_tmpl_identify_rec         => p_tmpl_identify_rec,
                           p_dist_info_rec             => p_dist_info_rec,
                           p_ctxt_val_tbl              => p_ctxt_val_tbl,
                           p_acc_gen_primary_key_tbl   => p_acc_gen_primary_key_tbl,
                           x_template_tbl              => x_template_tbl,
                           x_amount_tbl                => x_amount_tbl);

    x_gl_date := G_gl_date;

END CREATE_ACCOUNTING_DIST;

-- Added by Santonyr on 12-Jul-2440 for the bug 3761026

PROCEDURE  POPULATE_ACCT_SOURCES(p_api_version              IN       NUMBER,
                                p_init_msg_list           IN       VARCHAR2,
                                x_return_status           OUT      NOCOPY VARCHAR2,
                                x_msg_count               OUT      NOCOPY NUMBER,
                                x_msg_data                OUT      NOCOPY VARCHAR2,
                                p_tmpl_identify_rec       IN       TMPL_IDENTIFY_REC_TYPE,
                                p_dist_info_rec           IN       DIST_INFO_REC_TYPE,
                                p_acc_gen_primary_key_tbl IN       acc_gen_primary_key,
                                p_template_amount_tbl     IN       template_amount_tbl_type)
IS

  l_return_status  VARCHAR2(1) := Okl_Api.G_RET_STS_SUCCESS;
  l_api_name       VARCHAR2(30) := 'POPULATE_ACCT_SOURCES';
  l_api_version    NUMBER := 1.0;

  l_init_msg_list         VARCHAR2(1) := Okl_Api.G_FALSE;
  l_msg_count             NUMBER := 0;
  l_msg_data              VARCHAR2(2000);


  l_pay_vendor_sites_pk         VARCHAR2(50);
  l_rec_site_uses_pk            VARCHAR2(50);
  l_asset_category_id_pk1       VARCHAR2(50);
  l_asset_book_pk2              VARCHAR2(50);
  l_pay_financial_options_pk    VARCHAR2(50);
  l_jtf_sales_reps_pk           VARCHAR2(50);
  l_inventory_item_id_pk1       VARCHAR2(50);
  l_inventory_org_id_pk2        VARCHAR2(50);
  l_rec_trx_types_pk            VARCHAR2(50);
  l_factor_investor_code        VARCHAR2(30);

  l_asev_tbl  asev_tbl_type;
  x_asev_tbl  asev_tbl_type;

BEGIN

   x_return_status := Okl_Api.G_RET_STS_SUCCESS;

   l_return_status := Okl_Api.START_ACTIVITY(l_api_name,
                                             G_PKG_NAME,
                                             p_init_msg_list,
                                             l_api_version,
                                             p_api_version,
                                             '_PVT',
                                             x_return_status);
   IF (l_return_status = Okl_Api.G_RET_STS_UNEXP_ERROR) THEN
     RAISE Okl_Api.G_EXCEPTION_UNEXPECTED_ERROR;
   ELSIF (l_return_status = Okl_Api.G_RET_STS_ERROR) THEN
     RAISE Okl_Api.G_EXCEPTION_ERROR;
   END IF;


-- Extract the account generator sources from account generator primary key table.

   IF p_acc_gen_primary_key_tbl.COUNT > 0 THEN

    FOR j IN p_acc_gen_primary_key_tbl.FIRST..p_acc_gen_primary_key_tbl.LAST LOOP

          IF p_acc_gen_primary_key_tbl(j).source_table = 'AP_VENDOR_SITES_V' THEN
             l_pay_vendor_sites_pk      := TRIM(p_acc_gen_primary_key_tbl(j).primary_key_column);


            ELSIF p_acc_gen_primary_key_tbl(j).source_table = 'AR_SITE_USES_V' THEN
              l_rec_site_uses_pk := TRIM(p_acc_gen_primary_key_tbl(j).primary_key_column);


            ELSIF p_acc_gen_primary_key_tbl(j).source_table = 'FA_CATEGORY_BOOKS' THEN
              l_asset_category_id_pk1 := TRIM(SUBSTR(p_acc_gen_primary_key_tbl(j).primary_key_column,1, 50));
              l_asset_book_pk2 := TRIM(SUBSTR(p_acc_gen_primary_key_tbl(j).primary_key_column,51, 100));


            ELSIF p_acc_gen_primary_key_tbl(j).source_table = 'FINANCIALS_SYSTEM_PARAMETERS' THEN
              l_pay_financial_options_pk := TRIM(p_acc_gen_primary_key_tbl(j).primary_key_column);

            ELSIF p_acc_gen_primary_key_tbl(j).source_table = 'JTF_RS_SALESREPS_MO_V' THEN
                  l_jtf_sales_reps_pk := TRIM(p_acc_gen_primary_key_tbl(j).primary_key_column);


            ELSIF p_acc_gen_primary_key_tbl(j).source_table = 'MTL_SYSTEM_ITEMS_VL' THEN
                  l_inventory_item_id_pk1 := TRIM(SUBSTR(p_acc_gen_primary_key_tbl(j).primary_key_column,1, 50));
                  l_inventory_org_id_pk2 := TRIM(SUBSTR(p_acc_gen_primary_key_tbl(j).primary_key_column,51, 100));

            ELSIF p_acc_gen_primary_key_tbl(j).source_table = 'RA_CUST_TRX_TYPES' THEN
                  l_rec_trx_types_pk := TRIM(p_acc_gen_primary_key_tbl(j).primary_key_column);
           END IF;

        END LOOP;

  END IF;

  -- Get the syndication /Investor Code

    IF p_tmpl_identify_rec.factoring_synd_flag = 'SYNDICATION' THEN
          l_factor_investor_code := p_tmpl_identify_rec.syndication_code;
        ELSIF p_tmpl_identify_rec.factoring_synd_flag = 'FACTORING' THEN
          l_factor_investor_code := p_tmpl_identify_rec.factoring_code;
        ELSIF p_tmpl_identify_rec.factoring_synd_flag = 'INVESTOR' THEN
          l_factor_investor_code := p_tmpl_identify_rec.investor_code;
        END IF;


-- Populate the account sources PL/SQL table.

   IF p_template_amount_tbl.COUNT > 0 THEN

     FOR i IN p_template_amount_tbl.FIRST .. p_template_amount_tbl.LAST LOOP

        l_asev_tbl(i).source_table      :=  p_dist_info_rec.source_table; --source_table,
        l_asev_tbl(i).source_id         :=  p_dist_info_rec.source_id; --source_id,
        l_asev_tbl(i).pdt_id            :=  p_tmpl_identify_rec.product_id; --product_id,
        l_asev_tbl(i).try_id            :=  p_tmpl_identify_rec.transaction_type_id; --trx_type_id,
        l_asev_tbl(i).sty_id            :=  p_template_amount_tbl(i).stream_type_id ; --stream_type_id,
        l_asev_tbl(i).memo_yn           :=  NVL(p_tmpl_identify_rec.memo_yn, 'N'); --memo_yn,
        l_asev_tbl(i).factor_investor_flag :=  p_tmpl_identify_rec.factoring_synd_flag; --factor_investor_flag,
        l_asev_tbl(i).factor_investor_code :=  l_factor_investor_code; --factor_investor_code,
        l_asev_tbl(i).amount            :=  p_template_amount_tbl(i).amount; --amount
        l_asev_tbl(i).formula_used      :=  p_template_amount_tbl(i).formula_used; --formula_used
        l_asev_tbl(i).entered_date      :=  p_dist_info_rec.accounting_date; --entered_accounting_date,
        l_asev_tbl(i).accounting_date   :=  trunc(g_gl_date); --accounting_date,
        l_asev_tbl(i).gl_reversal_flag  :=  p_dist_info_rec.gl_reversal_flag; --gl_reversal_flag,
        l_asev_tbl(i).post_to_gl        :=  p_dist_info_rec.post_to_gl; --post_to_gl,
        l_asev_tbl(i).currency_code     :=  p_dist_info_rec.currency_code; --currency_code,
        l_asev_tbl(i).currency_conversion_type :=  p_dist_info_rec.currency_conversion_type; --currency_conversion_type,
        l_asev_tbl(i).currency_conversion_date :=  p_dist_info_rec.currency_conversion_date; --currency_conversion_date,
        l_asev_tbl(i).currency_conversion_rate :=  p_dist_info_rec.currency_conversion_rate; --currency_conversion_rate,
        l_asev_tbl(i).khr_id            :=  p_dist_info_rec.contract_id; --contract_id,
        l_asev_tbl(i).kle_id            :=  p_dist_info_rec.contract_line_id; --contract_line_id,
        l_asev_tbl(i).pay_vendor_sites_pk       :=  l_pay_vendor_sites_pk; --pay_vendor_sites_pk,
        l_asev_tbl(i).rec_site_uses_pk          :=  l_rec_site_uses_pk; --rec_site_uses_pk,
        l_asev_tbl(i).asset_category_id_pk1     :=  l_asset_category_id_pk1; --asset_categories_pk1,
        l_asev_tbl(i).asset_book_pk2            :=  l_asset_book_pk2; --asset_categories_pk2,
        l_asev_tbl(i).pay_financial_options_pk  :=  l_pay_financial_options_pk; --pay_financial_options_pk,
        l_asev_tbl(i).jtf_sales_reps_pk         :=  l_jtf_sales_reps_pk; --jtf_sales_reps_pk,
        l_asev_tbl(i).inventory_item_id_pk1     :=  l_inventory_item_id_pk1; --inventory_items_pk1,
        l_asev_tbl(i).inventory_org_id_pk2      :=  l_inventory_org_id_pk2; --inventory_items_pk2,
        l_asev_tbl(i).rec_trx_types_pk          :=  l_rec_trx_types_pk; --rec_trx_types_pk,
        l_asev_tbl(i).avl_id                    :=  p_template_amount_tbl(i).template_id; --template_id
        l_asev_tbl(i).local_product_yn          :=  'Y'; --local_product,
        l_asev_tbl(i).internal_status           :=  'ENTERED'; --status,
        l_asev_tbl(i).custom_status             :=  'ENTERED'; --custom_status,
        l_asev_tbl(i).source_indicator_flag     :=  'INTERNAL'; --source_indicator,

      END LOOP;

   END IF;


-- Insert into Account Sources table.

  Okl_Acct_Sources_Pvt. insert_acct_sources (
                      p_api_version   => l_api_version
                      ,p_init_msg_list => l_init_msg_list
                      ,x_return_status => l_return_status
                      ,x_msg_count     => l_msg_count
                      ,x_msg_data      => l_msg_data
                      ,p_asev_tbl      => l_asev_tbl
                      ,x_asev_tbl      => x_asev_tbl);

  IF (l_return_status = Okl_Api.G_RET_STS_UNEXP_ERROR) THEN
    RAISE Okl_Api.G_EXCEPTION_UNEXPECTED_ERROR;
  ELSIF (l_return_status = Okl_Api.G_RET_STS_ERROR) THEN
    RAISE Okl_Api.G_EXCEPTION_ERROR;
  END IF;


   Okl_Api.END_ACTIVITY(x_msg_count, x_msg_data);

   x_return_status := Okl_Api.G_RET_STS_SUCCESS;

EXCEPTION

    WHEN Okl_Api.G_EXCEPTION_ERROR THEN
      x_return_status := OKL_API.HANDLE_EXCEPTIONS
      ( l_api_name,
        G_PKG_NAME,
        'OKL_API.G_RET_STS_ERROR',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
    WHEN Okl_Api.G_EXCEPTION_UNEXPECTED_ERROR THEN
      x_return_status := OKL_API.HANDLE_EXCEPTIONS
      ( l_api_name,
        G_PKG_NAME,
        'OKL_API.G_RET_STS_UNEXP_ERROR',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
    WHEN OTHERS THEN
      x_return_status := OKL_API.HANDLE_EXCEPTIONS
      ( l_api_name,
        G_PKG_NAME,
        'OTHERS',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );


END POPULATE_ACCT_SOURCES;

--Added by gboomina for Accruals Performance on 14-Oct-2005
   --Bug 4662173 - Start of Changes
   PROCEDURE  POPULATE_ACCT_SOURCES(p_api_version              IN       NUMBER,
                                   p_init_msg_list           IN       VARCHAR2,
                                   x_return_status           OUT      NOCOPY VARCHAR2,
                                   x_msg_count               OUT      NOCOPY NUMBER,
                                   x_msg_data                OUT      NOCOPY VARCHAR2,
                                   p_tmpl_identify_rec       IN       TMPL_IDENTIFY_REC_TYPE,
                                   p_dist_info_tbl           IN       DIST_INFO_TBL_TYPE,
                                   p_acc_gen_primary_key_tbl IN       acc_gen_tbl,
                                   p_template_amount_tbl     IN       tmp_bulk_amount_tbl_type)
   IS

     l_return_status  VARCHAR2(1) := Okl_Api.G_RET_STS_SUCCESS;
     l_api_name       VARCHAR2(30) := 'POPULATE_ACCT_SOURCES';
     l_api_version    NUMBER := 1.0;

     l_init_msg_list         VARCHAR2(1) := Okl_Api.G_FALSE;
     l_msg_count             NUMBER := 0;
     l_msg_data              VARCHAR2(2000);


     l_pay_vendor_sites_pk         VARCHAR2(50);
     l_rec_site_uses_pk            VARCHAR2(50);
     l_asset_category_id_pk1       VARCHAR2(50);
     l_asset_book_pk2              VARCHAR2(50);
     l_pay_financial_options_pk    VARCHAR2(50);
     l_jtf_sales_reps_pk           VARCHAR2(50);
     l_inventory_item_id_pk1       VARCHAR2(50);
     l_inventory_org_id_pk2        VARCHAR2(50);
     l_rec_trx_types_pk            VARCHAR2(50);
     l_factor_investor_code        VARCHAR2(30);

     l_asev_tbl  asev_tbl_type;
     x_asev_tbl  asev_tbl_type;
     j                             NUMBER := 0;
     --Added by  gboomina for the Accruals Performance Enhancement
     l_acc_gen_index               NUMBER := 0;
     l_acc_gen_last_index          NUMBER := 0;
     l_dist_info_tbl               DIST_INFO_TBL_TYPE := p_dist_info_tbl;
     l_asev_full_tbl               asev_tbl_type;
     p_acc_gen_tbl_ret             acc_gen_primary_key;
     l_tmp_amt_tbl_ret             template_amount_tbl_type;
     l_tmp_amt_index               NUMBER := 0;
     l_tmp_amt_last_index          NUMBER := 0;

   BEGIN

      x_return_status := Okl_Api.G_RET_STS_SUCCESS;

      l_return_status := Okl_Api.START_ACTIVITY(l_api_name,
                                                G_PKG_NAME,
                                                p_init_msg_list,
                                                l_api_version,
                                                p_api_version,
                                                '_PVT',
                                                x_return_status);
      IF (l_return_status = Okl_Api.G_RET_STS_UNEXP_ERROR) THEN
        RAISE Okl_Api.G_EXCEPTION_UNEXPECTED_ERROR;
      ELSIF (l_return_status = Okl_Api.G_RET_STS_ERROR) THEN
        RAISE Okl_Api.G_EXCEPTION_ERROR;
      END IF;


     FOR i IN l_dist_info_tbl.FIRST..l_dist_info_tbl.LAST LOOP
       --Obtaining the acc_gen_tbl for the l_dist_info_tbl(i)
       GET_ACC_GEN_TBL(p_source_id            => l_dist_info_tbl(i).source_id,
                       p_gen_table            => p_acc_gen_primary_key_tbl,
                       x_acc_gen_tbl_ret      => p_acc_gen_tbl_ret);


       -- Extract the account generator sources from account generator primary key table.

       IF p_acc_gen_tbl_ret.COUNT > 0 THEN

         FOR j IN p_acc_gen_tbl_ret.FIRST..p_acc_gen_tbl_ret.LAST LOOP

             IF p_acc_gen_tbl_ret(j).source_table = 'AP_VENDOR_SITES_V' THEN
                l_pay_vendor_sites_pk      := TRIM(p_acc_gen_tbl_ret(j).primary_key_column);


               ELSIF p_acc_gen_tbl_ret(j).source_table = 'AR_SITE_USES_V' THEN
                 l_rec_site_uses_pk := TRIM(p_acc_gen_tbl_ret(j).primary_key_column);


               ELSIF p_acc_gen_tbl_ret(j).source_table = 'FA_CATEGORY_BOOKS' THEN
                 l_asset_category_id_pk1 := TRIM(SUBSTR(p_acc_gen_tbl_ret(j).primary_key_column,1, 50));
                 l_asset_book_pk2 := TRIM(SUBSTR(p_acc_gen_tbl_ret(j).primary_key_column,51, 100));


               ELSIF p_acc_gen_tbl_ret(j).source_table = 'FINANCIALS_SYSTEM_PARAMETERS' THEN
                 l_pay_financial_options_pk := TRIM(p_acc_gen_tbl_ret(j).primary_key_column);

               ELSIF p_acc_gen_tbl_ret(j).source_table = 'JTF_RS_SALESREPS_MO_V' THEN
                     l_jtf_sales_reps_pk := TRIM(p_acc_gen_tbl_ret(j).primary_key_column);


               ELSIF p_acc_gen_tbl_ret(j).source_table = 'MTL_SYSTEM_ITEMS_VL' THEN
                     l_inventory_item_id_pk1 := TRIM(SUBSTR(p_acc_gen_tbl_ret(j).primary_key_column,1, 50));
                     l_inventory_org_id_pk2 := TRIM(SUBSTR(p_acc_gen_tbl_ret(j).primary_key_column,51, 100));

               ELSIF p_acc_gen_tbl_ret(j).source_table = 'RA_CUST_TRX_TYPES' THEN
                     l_rec_trx_types_pk := TRIM(p_acc_gen_tbl_ret(j).primary_key_column);
             END IF;

          END LOOP;

       END IF;

     -- Get the syndication /Investor Code

       IF p_tmpl_identify_rec.factoring_synd_flag = 'SYNDICATION' THEN
          l_factor_investor_code := p_tmpl_identify_rec.syndication_code;
       ELSIF p_tmpl_identify_rec.factoring_synd_flag = 'FACTORING' THEN
          l_factor_investor_code := p_tmpl_identify_rec.factoring_code;
       ELSIF p_tmpl_identify_rec.factoring_synd_flag = 'INVESTOR' THEN
          l_factor_investor_code := p_tmpl_identify_rec.investor_code;
       END IF;

       --Obtaining the template_amount_tbl for the l_dist_info_tbl(i)
       GET_TEMPLATE_AMOUNT_TBL(p_parent_index_number  => i,
                              p_tmp_amount_table     => p_template_amount_tbl,
                              x_tmp_amt_tbl_ret      => l_tmp_amt_tbl_ret);


       FOR j IN l_tmp_amt_tbl_ret.FIRST .. l_tmp_amt_tbl_ret.LAST LOOP
                 l_asev_tbl(j).source_table      :=  p_dist_info_tbl(i).source_table; --source_table,
             l_asev_tbl(j).source_id         :=  p_dist_info_tbl(i).source_id; --source_id,
             l_asev_tbl(j).pdt_id            :=  p_tmpl_identify_rec.product_id; --product_id,
             l_asev_tbl(j).try_id            :=  p_tmpl_identify_rec.transaction_type_id; --trx_type_id,
             l_asev_tbl(j).sty_id            :=  l_tmp_amt_tbl_ret(j).stream_type_id ; --stream_type_id,
             l_asev_tbl(j).memo_yn           :=  NVL(p_tmpl_identify_rec.memo_yn, 'N'); --memo_yn,
             l_asev_tbl(j).factor_investor_flag :=  p_tmpl_identify_rec.factoring_synd_flag; --factor_investor_flag,
             l_asev_tbl(j).factor_investor_code :=  l_factor_investor_code; --factor_investor_code,
             l_asev_tbl(j).amount            :=  l_tmp_amt_tbl_ret(j).amount; --amount
             l_asev_tbl(j).formula_used      :=  l_tmp_amt_tbl_ret(j).formula_used; --formula_used
             l_asev_tbl(j).entered_date      :=  p_dist_info_tbl(i).accounting_date; --entered_accounting_date,
             l_asev_tbl(j).accounting_date   :=  trunc(g_gl_date); --accounting_date,
             l_asev_tbl(j).gl_reversal_flag  :=  p_dist_info_tbl(i).gl_reversal_flag; --gl_reversal_flag,
             l_asev_tbl(j).post_to_gl        :=  p_dist_info_tbl(i).post_to_gl; --post_to_gl,
             l_asev_tbl(j).currency_code     :=  p_dist_info_tbl(i).currency_code; --currency_code,
             l_asev_tbl(j).currency_conversion_type :=  p_dist_info_tbl(i).currency_conversion_type; --currency_conversion_type,
             l_asev_tbl(j).currency_conversion_date :=  p_dist_info_tbl(i).currency_conversion_date; --currency_conversion_date,
             l_asev_tbl(j).currency_conversion_rate :=  p_dist_info_tbl(i).currency_conversion_rate; --currency_conversion_rate,
             l_asev_tbl(j).khr_id            :=  p_dist_info_tbl(i).contract_id; --contract_id,
             l_asev_tbl(j).kle_id            :=  p_dist_info_tbl(i).contract_line_id; --contract_line_id,
             l_asev_tbl(j).pay_vendor_sites_pk       :=  l_pay_vendor_sites_pk; --pay_vendor_sites_pk,
             l_asev_tbl(j).rec_site_uses_pk          :=  l_rec_site_uses_pk; --rec_site_uses_pk,
             l_asev_tbl(j).asset_category_id_pk1     :=  l_asset_category_id_pk1; --asset_categories_pk1,
             l_asev_tbl(j).asset_book_pk2            :=  l_asset_book_pk2; --asset_categories_pk2,
             l_asev_tbl(j).pay_financial_options_pk  :=  l_pay_financial_options_pk; --pay_financial_options_pk,
             l_asev_tbl(j).jtf_sales_reps_pk         :=  l_jtf_sales_reps_pk; --jtf_sales_reps_pk,
             l_asev_tbl(j).inventory_item_id_pk1     :=  l_inventory_item_id_pk1; --inventory_items_pk1,
             l_asev_tbl(j).inventory_org_id_pk2      :=  l_inventory_org_id_pk2; --inventory_items_pk2,
             l_asev_tbl(j).rec_trx_types_pk          :=  l_rec_trx_types_pk; --rec_trx_types_pk,
             l_asev_tbl(j).avl_id                    :=  l_tmp_amt_tbl_ret(j).template_id; --template_id
             l_asev_tbl(j).local_product_yn          :=  'Y'; --local_product,
             l_asev_tbl(j).internal_status           :=  'ENTERED'; --status,
             l_asev_tbl(j).custom_status             :=  'ENTERED'; --custom_status,
             l_asev_tbl(j).source_indicator_flag     :=  'INTERNAL'; --source_indicator,
       END LOOP;
       --Accumulating the account sources for the entire dist_info_tbl
       ACCUMULATE_ACCT_SOURCES(p_asev_tbl        => l_asev_tbl,
                               x_asev_full_tbl   => l_asev_full_tbl,
                               x_return_status   => l_return_status);

     END LOOP;--For dist_info_tbl.count


   -- Insert into Account Sources table.

     Okl_Acct_Sources_Pvt. insert_acct_sources_bulk (
                         p_api_version   => l_api_version
                         ,p_init_msg_list => l_init_msg_list
                         ,x_return_status => l_return_status
                         ,x_msg_count     => l_msg_count
                         ,x_msg_data      => l_msg_data
                         ,p_asev_tbl      => l_asev_full_tbl
                         ,x_asev_tbl      => x_asev_tbl);

     IF (l_return_status = Okl_Api.G_RET_STS_UNEXP_ERROR) THEN
       RAISE Okl_Api.G_EXCEPTION_UNEXPECTED_ERROR;
     ELSIF (l_return_status = Okl_Api.G_RET_STS_ERROR) THEN
       RAISE Okl_Api.G_EXCEPTION_ERROR;
     END IF;


      Okl_Api.END_ACTIVITY(x_msg_count, x_msg_data);

      x_return_status := Okl_Api.G_RET_STS_SUCCESS;

   EXCEPTION

       WHEN Okl_Api.G_EXCEPTION_ERROR THEN
         x_return_status := OKL_API.HANDLE_EXCEPTIONS
         ( l_api_name,
           G_PKG_NAME,
           'OKL_API.G_RET_STS_ERROR',
           x_msg_count,
           x_msg_data,
           '_PVT'
         );
       WHEN Okl_Api.G_EXCEPTION_UNEXPECTED_ERROR THEN
         x_return_status := OKL_API.HANDLE_EXCEPTIONS
         ( l_api_name,
           G_PKG_NAME,
           'OKL_API.G_RET_STS_UNEXP_ERROR',
           x_msg_count,
           x_msg_data,
           '_PVT'
         );
       WHEN OTHERS THEN
         x_return_status := OKL_API.HANDLE_EXCEPTIONS
         ( l_api_name,
           G_PKG_NAME,
           'OTHERS',
           x_msg_count,
           x_msg_data,
           '_PVT'
         );


   END POPULATE_ACCT_SOURCES;
   --Bug 4662173 - End of Changes

END OKL_ACCOUNT_DIST_PVT;

/
