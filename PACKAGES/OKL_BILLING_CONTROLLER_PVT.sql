--------------------------------------------------------
--  DDL for Package OKL_BILLING_CONTROLLER_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OKL_BILLING_CONTROLLER_PVT" AUTHID CURRENT_USER AS
/* $Header: OKLPBICS.pls 120.13 2008/02/07 13:21:40 zrehman noship $*/

  G_PKG_NAME                 CONSTANT VARCHAR2(200) := 'OKL_BILLING_CONTROLLER_PVT';
  G_APP_NAME                 CONSTANT VARCHAR2(3)   :=  OKL_API.G_APP_NAME;

  G_API_TYPE                 CONSTANT VARCHAR2(4)   := '_PVT';
  G_UNEXPECTED_ERROR         CONSTANT VARCHAR2(1000) := 'OKL_UNEXPECTED_ERROR';

  -- Bug 4520466
  FUNCTION get_next_bill_date ( p_khr_id IN NUMBER ) return date;

  PROCEDURE track_next_bill_date ( p_khr_id IN NUMBER );
  -- End Bug 4520466

  -- Bug 4546873;
  PROCEDURE PURGE_PARALLEL_PROCESSES (
                            errbuf             OUT NOCOPY VARCHAR2,
                            retcode            OUT NOCOPY NUMBER,
                            p_source           IN VARCHAR2 DEFAULT NULL
                           );
  -- End Bug 4546873;


  PROCEDURE Process_Spawner (
                            errbuf             OUT NOCOPY VARCHAR2,
                            retcode            OUT NOCOPY NUMBER,
                            p_num_processes    IN NUMBER,
                            p_start_date_from  IN VARCHAR2 DEFAULT NULL,
                            p_start_date_to    IN VARCHAR2 DEFAULT NULL,
                            p_contract_number  IN VARCHAR2	DEFAULT NULL,
                            p_cust_acct_id     IN NUMBER DEFAULT NULL,
                            p_inv_msg          IN VARCHAR2 DEFAULT 'TRUE',
                            p_source           IN VARCHAR2 DEFAULT NULL,
-- modified by zrehman for Bug#6788005 on 01-Feb-2008 start
                            p_ia_contract_type   IN VARCHAR2,
                            p_inv_cust_acct_id        IN NUMBER
-- modified by zrehman for Bug#6788005 on 01-Feb-2008 end
                           );


  PROCEDURE BILL_STREAMS_MASTER (
                            errbuf             OUT NOCOPY VARCHAR2,
                            retcode            OUT NOCOPY NUMBER,
                            p_ia_contract_type   IN VARCHAR2,
			    p_start_date_from  IN VARCHAR2,
                            p_start_date_to    IN VARCHAR2,
                            p_contract_number  IN VARCHAR2	DEFAULT NULL,
                            p_cust_acct_id     IN NUMBER DEFAULT NULL,
			    p_inv_cust_acct_id      IN NUMBER,
                            p_num_processes    IN NUMBER
                           );

  --fmiao 5209209 change
  PROCEDURE PREPARE_RECEIVABLES_MASTER (
                            errbuf             OUT NOCOPY VARCHAR2,
                            retcode            OUT NOCOPY NUMBER,
                            p_num_processes    IN  NUMBER
                           );
  --fmiao 5209209 change end


  PROCEDURE AR_TRANSFER_MASTER (
                            errbuf             OUT NOCOPY VARCHAR2,
                            retcode            OUT NOCOPY NUMBER,
                            p_start_date_from  IN VARCHAR2,
                            p_start_date_to    IN VARCHAR2,
                            p_num_processes    IN NUMBER
                           );


  PROCEDURE OKL_CONS_MASTER (
                            errbuf             OUT NOCOPY VARCHAR2,
                            retcode            OUT NOCOPY NUMBER,
                            p_inv_msg          IN  VARCHAR2 DEFAULT 'TRUE',
                            p_num_processes    IN  NUMBER
                           );


  	   G_NO_DATA_FOUND 		CONSTANT VARCHAR2(200) := 'NO_DATA_FOUND';
  	   G_TOO_MANY_ROWS 		CONSTANT VARCHAR2(200) := 'TOO_MANY_ROWS';
  	   G_OTHERS        		CONSTANT VARCHAR2(200) := 'OTHERS';

       -- ------------------------------
       -- Commit frequency
       -- ------------------------------
       G_Commit_Max         CONSTANT NUMBER := 500;
       g_cons_bill_data_cached     BOOLEAN := FALSE;

  -- -------------------------------------------------------------------------
  -- Consolidated Billing data structure
  -- -------------------------------------------------------------------------
  TYPE cons_bill_rec_type IS RECORD (
             customer_id            okl_ext_sell_invs_v.customer_id%TYPE,
             currency               okl_ext_sell_invs_v.currency_code%TYPE,
             bill_to_site           okl_ext_sell_invs_v.customer_address_id%TYPE,
             payment_method         okl_ext_sell_invs_v.receipt_method_id%TYPE,
             private_label          okl_ext_sell_invs_v.xtrx_private_label%TYPE,
             date_consolidated      okl_ext_sell_invs_v.TRX_DATE%TYPE,
             ity_id                 okl_invoice_types_b.id%TYPE, -- bug 5138822
             inf_id                 okl_invoice_formats_b.id%TYPE,
             contract_id            okc_k_headers_b.id%TYPE,
             contract_number        okc_k_headers_b.contract_number%TYPE,
             prev_cons_invoice_num  okl_cnsld_ar_hdrs_v.consolidated_invoice_number%TYPE,
             org_id                 okl_ext_sell_invs_v.org_id%TYPE,
             set_of_books_id        okl_ext_sell_invs_v.set_of_books_id%TYPE,
             kle_id                 okc_k_lines_b.id%TYPE,
             sty_id                 okl_strm_type_v.id%TYPE,
             xsi_id                 okl_ext_sell_invs_v.id%TYPE,
             xls_id                 okl_xtl_sell_invs_v.id%TYPE,
             amount	                okl_xtl_sell_invs_v.amount%TYPE,
             sel_id                 okl_xtl_sell_invs_v.sel_id%TYPE,
             legal_entity_id        okl_ext_sell_invs_v.legal_entity_id%TYPE -- for LE Uptake project 08-11-2006
	     );

  TYPE cons_bill_tbl_type IS TABLE OF cons_bill_rec_type
        INDEX BY BINARY_INTEGER;

  TYPE saved_bill_rec_type IS RECORD (
		   	 l_customer_id         okl_ext_sell_invs_v.customer_id%TYPE,
             l_currency            okl_ext_sell_invs_v.currency_code%TYPE,
             l_bill_to_site        okl_ext_sell_invs_v.customer_address_id%TYPE,
             l_payment_method      okl_ext_sell_invs_v.receipt_method_id%TYPE,
             l_private_label       okl_ext_sell_invs_v.xtrx_private_label%TYPE,
             l_date_consolidated   okl_ext_sell_invs_v.TRX_DATE%TYPE,
             l_saved_ity_id        okl_invoice_types_b.id%TYPE, -- bug 5138822
             l_saved_format_id     okl_invoice_formats_v.id%TYPE,
             l_saved_prev_cons_num okl_cnsld_ar_hdrs_v.consolidated_invoice_number%TYPE,
             l_prev_khr_id         okc_k_headers_b.id%TYPE,
             l_line_number         NUMBER,
             l_commit_cnt          NUMBER,
             l_overall_status      VARCHAR2(1),
             l_cnr_id              NUMBER,
             l_lln_id              NUMBER,
             l_cons_inv_num        okl_cnsld_ar_hdrs_v.consolidated_invoice_number%TYPE);

    TYPE update_rec_type IS RECORD (
	 cnr_id			    NUMBER,
     cons_inv_number    okl_cnsld_ar_hdrs_b.consolidated_invoice_number%TYPE,
	 lln_id			    NUMBER,
	 lsm_id			    NUMBER,
     asset_number       Okl_Xtl_Sell_Invs_tl.XTRX_ASSET%TYPE,
     invoice_format     OKL_INVOICE_FORMATS_V.NAME%TYPE,
     line_type          okl_invc_line_types_v.NAME%TYPE,
     private_label      Okl_Ext_Sell_Invs_tl.xtrx_private_label%TYPE,
     sty_name           okl_strm_type_v.NAME%TYPE,
     contract_number    okc_k_headers_b.contract_number%TYPE,
     lsm_amount         NUMBER,
	 xsi_id			    NUMBER,
	 xls_id			    NUMBER,
	 cnr_total          NUMBER,
	 lln_total          NUMBER
	);

    TYPE update_tbl_type IS TABLE OF update_rec_type
	     INDEX BY BINARY_INTEGER;


  --MDOKAL
  TYPE cnr_rec_type IS RECORD (
    id                             NUMBER := null,
    consolidated_invoice_number    OKL_CNSLD_AR_HDRS_B.CONSOLIDATED_INVOICE_NUMBER%TYPE := '',
    due_date            		   OKL_CNSLD_AR_HDRS_B.DUE_DATE%TYPE := null,
    trx_status_code                OKL_CNSLD_AR_HDRS_B.TRX_STATUS_CODE%TYPE := '',
    currency_code                  OKL_CNSLD_AR_HDRS_B.CURRENCY_CODE%TYPE := '',
    set_of_books_id                NUMBER := null,
    ibt_id                         NUMBER := null,
    ixx_id                         NUMBER := null,
    irm_id                         NUMBER := null,
    inf_id                         NUMBER := null,
    amount                         NUMBER := null,
    date_consolidated              OKL_CNSLD_AR_HDRS_B.DATE_CONSOLIDATED%TYPE := null,
    invoice_pull_yn                OKL_CNSLD_AR_HDRS_B.INVOICE_PULL_YN%TYPE := '',
    object_version_number          NUMBER := null,
    request_id                     NUMBER := null,
    program_application_id         NUMBER := null,
    program_id                     NUMBER := null,
    program_update_date            OKL_CNSLD_AR_HDRS_B.PROGRAM_UPDATE_DATE%TYPE := null,
    org_id                         NUMBER := null,
    attribute_category             OKL_CNSLD_AR_HDRS_B.ATTRIBUTE_CATEGORY%TYPE := '',
    attribute1                     OKL_CNSLD_AR_HDRS_B.ATTRIBUTE1%TYPE := '',
    attribute2                     OKL_CNSLD_AR_HDRS_B.ATTRIBUTE2%TYPE := '',
    attribute3                     OKL_CNSLD_AR_HDRS_B.ATTRIBUTE3%TYPE := '',
    attribute4                     OKL_CNSLD_AR_HDRS_B.ATTRIBUTE4%TYPE := '',
    attribute5                     OKL_CNSLD_AR_HDRS_B.ATTRIBUTE5%TYPE := '',
    attribute6                     OKL_CNSLD_AR_HDRS_B.ATTRIBUTE6%TYPE := '',
    attribute7                     OKL_CNSLD_AR_HDRS_B.ATTRIBUTE7%TYPE := '',
    attribute8                     OKL_CNSLD_AR_HDRS_B.ATTRIBUTE8%TYPE := '',
    attribute9                     OKL_CNSLD_AR_HDRS_B.ATTRIBUTE9%TYPE := '',
    attribute10                    OKL_CNSLD_AR_HDRS_B.ATTRIBUTE10%TYPE := '',
    attribute11                    OKL_CNSLD_AR_HDRS_B.ATTRIBUTE11%TYPE := '',
    attribute12                    OKL_CNSLD_AR_HDRS_B.ATTRIBUTE12%TYPE := '',
    attribute13                    OKL_CNSLD_AR_HDRS_B.ATTRIBUTE13%TYPE := '',
    attribute14                    OKL_CNSLD_AR_HDRS_B.ATTRIBUTE14%TYPE := '',
    attribute15                    OKL_CNSLD_AR_HDRS_B.ATTRIBUTE15%TYPE := '',
    created_by                     NUMBER := null,
    creation_date                  OKL_CNSLD_AR_HDRS_B.CREATION_DATE%TYPE := null,
    last_updated_by                NUMBER := null,
    last_update_date               OKL_CNSLD_AR_HDRS_B.LAST_UPDATE_DATE%TYPE := null,
    last_update_login              NUMBER := null,
    legal_entity_id               OKL_CNSLD_AR_HDRS_B.LEGAL_ENTITY_ID%TYPE := null); -- for LE Uptake project 08-11-2006

  TYPE cnr_tl_rec_type IS RECORD (
    id                            OKL_CNSLD_AR_HDRS_TL.ID%TYPE := null,
    language                      OKL_CNSLD_AR_HDRS_TL.LANGUAGE%TYPE := '',
    source_lang                   OKL_CNSLD_AR_HDRS_TL.SOURCE_LANG%TYPE := '',
    sfwt_flag                     OKL_CNSLD_AR_HDRS_TL.SFWT_FLAG%TYPE := '',
    private_label_logo_url        OKL_CNSLD_AR_HDRS_TL.PRIVATE_LABEL_LOGO_URL%TYPE := '',
    created_by                    OKL_CNSLD_AR_HDRS_TL.CREATED_BY%TYPE := null,
    creation_date                 OKL_CNSLD_AR_HDRS_TL.CREATION_DATE%TYPE := null,
    last_updated_by               OKL_CNSLD_AR_HDRS_TL.LAST_UPDATED_BY%TYPE := null,
    last_update_date              OKL_CNSLD_AR_HDRS_TL.LAST_UPDATE_DATE%TYPE := null,
    last_update_login             OKL_CNSLD_AR_HDRS_TL.LAST_UPDATE_LOGIN%TYPE := null);

  TYPE lln_rec_type IS RECORD (
    id                             NUMBER := null,
    sequence_number                NUMBER := null,
    lln_id_parent                  NUMBER := null,
    kle_id                         NUMBER := null,
    khr_id                         NUMBER := null,
    cnr_id                         NUMBER := null,
    ilt_id                         NUMBER := null,
    line_type                      OKL_CNSLD_AR_LINES_B.LINE_TYPE%TYPE := '',
    amount                         NUMBER := null,
    tax_amount                     NUMBER := null,
    object_version_number          NUMBER := null,
    request_id                     NUMBER := null,
    program_application_id         NUMBER := null,
    program_id                     NUMBER := null,
    program_update_date            OKL_CNSLD_AR_LINES_B.PROGRAM_UPDATE_DATE%TYPE := null,
    org_id                         NUMBER := null,
    attribute_category             OKL_CNSLD_AR_LINES_B.ATTRIBUTE_CATEGORY%TYPE := '',
    attribute1                     OKL_CNSLD_AR_LINES_B.ATTRIBUTE1%TYPE := '',
    attribute2                     OKL_CNSLD_AR_LINES_B.ATTRIBUTE2%TYPE := '',
    attribute3                     OKL_CNSLD_AR_LINES_B.ATTRIBUTE3%TYPE := '',
    attribute4                     OKL_CNSLD_AR_LINES_B.ATTRIBUTE4%TYPE := '',
    attribute5                     OKL_CNSLD_AR_LINES_B.ATTRIBUTE5%TYPE := '',
    attribute6                     OKL_CNSLD_AR_LINES_B.ATTRIBUTE6%TYPE := '',
    attribute7                     OKL_CNSLD_AR_LINES_B.ATTRIBUTE7%TYPE := '',
    attribute8                     OKL_CNSLD_AR_LINES_B.ATTRIBUTE8%TYPE := '',
    attribute9                     OKL_CNSLD_AR_LINES_B.ATTRIBUTE9%TYPE := '',
    attribute10                    OKL_CNSLD_AR_LINES_B.ATTRIBUTE10%TYPE := '',
    attribute11                    OKL_CNSLD_AR_LINES_B.ATTRIBUTE11%TYPE := '',
    attribute12                    OKL_CNSLD_AR_LINES_B.ATTRIBUTE12%TYPE := '',
    attribute13                    OKL_CNSLD_AR_LINES_B.ATTRIBUTE13%TYPE := '',
    attribute14                    OKL_CNSLD_AR_LINES_B.ATTRIBUTE14%TYPE := '',
    attribute15                    OKL_CNSLD_AR_LINES_B.ATTRIBUTE15%TYPE := '',
    created_by                     NUMBER := null,
    creation_date                  OKL_CNSLD_AR_LINES_B.CREATION_DATE%TYPE := null,
    last_updated_by                NUMBER := null,
    last_update_date               OKL_CNSLD_AR_LINES_B.LAST_UPDATE_DATE%TYPE := null,
    last_update_login              NUMBER := null);

  TYPE lln_tl_rec_type IS RECORD (
    id                            OKL_CNSLD_AR_LINES_TL.ID%TYPE := null,
    language                      OKL_CNSLD_AR_LINES_TL.LANGUAGE%TYPE := '',
    source_lang                   OKL_CNSLD_AR_LINES_TL.SOURCE_LANG%TYPE := '',
    sfwt_flag                     OKL_CNSLD_AR_LINES_TL.SFWT_FLAG%TYPE := '',
    created_by                    OKL_CNSLD_AR_LINES_TL.CREATED_BY%TYPE := null,
    creation_date                 OKL_CNSLD_AR_LINES_TL.CREATION_DATE%TYPE := null,
    last_updated_by               OKL_CNSLD_AR_LINES_TL.LAST_UPDATED_BY%TYPE := null,
    last_update_date              OKL_CNSLD_AR_LINES_TL.LAST_UPDATE_DATE%TYPE := null,
    last_update_login             OKL_CNSLD_AR_LINES_TL.LAST_UPDATE_LOGIN%TYPE := null);

  TYPE lsm_rec_type IS RECORD (
    id                             NUMBER := null,
    lln_id                         NUMBER := null,
    sty_id                         NUMBER := null,
    kle_id                         NUMBER := null,
    khr_id                         NUMBER := null,
    amount                         NUMBER := null,
	LATE_INT_ASSESS_DATE 		   OKL_CNSLD_AR_STRMS_B.LATE_INT_ASSESS_DATE%TYPE := null,
	LATE_CHARGE_ASSESS_DATE		   OKL_CNSLD_AR_STRMS_B.LATE_CHARGE_ASSESS_DATE%TYPE := null,
	LATE_CHARGE_ASS_YN			   OKL_CNSLD_AR_STRMS_B.LATE_CHARGE_ASS_YN%TYPE := '',
	LATE_INT_ASS_YN				   OKL_CNSLD_AR_STRMS_B.LATE_INT_ASS_YN%TYPE := '',
    tax_amount					   NUMBER := null,
    receivables_invoice_id         NUMBER := null,
    object_version_number          NUMBER := null,
	pay_status_code				   OKL_CNSLD_AR_STRMS_B.PAY_STATUS_CODE%TYPE := '',
    request_id                     NUMBER := null,
    program_application_id         NUMBER := null,
    program_id                     NUMBER := null,
    program_update_date            OKL_CNSLD_AR_STRMS_B.PROGRAM_UPDATE_DATE%TYPE := null,
    org_id                         NUMBER := null,
    attribute_category             OKL_CNSLD_AR_STRMS_B.ATTRIBUTE_CATEGORY%TYPE := '',
    attribute1                     OKL_CNSLD_AR_STRMS_B.ATTRIBUTE1%TYPE :=  '',
    attribute2                     OKL_CNSLD_AR_STRMS_B.ATTRIBUTE2%TYPE := '',
    attribute3                     OKL_CNSLD_AR_STRMS_B.ATTRIBUTE3%TYPE := '',
    attribute4                     OKL_CNSLD_AR_STRMS_B.ATTRIBUTE4%TYPE := '',
    attribute5                     OKL_CNSLD_AR_STRMS_B.ATTRIBUTE5%TYPE := '',
    attribute6                     OKL_CNSLD_AR_STRMS_B.ATTRIBUTE6%TYPE := '',
    attribute7                     OKL_CNSLD_AR_STRMS_B.ATTRIBUTE7%TYPE := '',
    attribute8                     OKL_CNSLD_AR_STRMS_B.ATTRIBUTE8%TYPE := '',
    attribute9                     OKL_CNSLD_AR_STRMS_B.ATTRIBUTE9%TYPE := '',
    attribute10                    OKL_CNSLD_AR_STRMS_B.ATTRIBUTE10%TYPE := '',
    attribute11                    OKL_CNSLD_AR_STRMS_B.ATTRIBUTE11%TYPE := '',
    attribute12                    OKL_CNSLD_AR_STRMS_B.ATTRIBUTE12%TYPE := '',
    attribute13                    OKL_CNSLD_AR_STRMS_B.ATTRIBUTE13%TYPE := '',
    attribute14                    OKL_CNSLD_AR_STRMS_B.ATTRIBUTE14%TYPE := '',
    attribute15                    OKL_CNSLD_AR_STRMS_B.ATTRIBUTE15%TYPE := '',
    created_by                     NUMBER := null,
    creation_date                  OKL_CNSLD_AR_STRMS_B.CREATION_DATE%TYPE := null,
    last_updated_by                NUMBER := null,
    last_update_date               OKL_CNSLD_AR_STRMS_B.LAST_UPDATE_DATE%TYPE := null,
    last_update_login              NUMBER := null,
    investor_disb_status           OKL_CNSLD_AR_STRMS_B.investor_disb_status%TYPE := '',
    investor_disb_err_mg           OKL_CNSLD_AR_STRMS_B.investor_disb_err_mg%TYPE := '',
    sel_id                         NUMBER := null,
    date_disbursed                 OKL_CNSLD_AR_STRMS_B.date_disbursed%TYPE := null );


  TYPE lsm_tl_rec_type IS RECORD (
    id                            OKL_CNSLD_AR_STRMS_TL.ID%TYPE := null,
    language                      OKL_CNSLD_AR_STRMS_TL.LANGUAGE%TYPE := '',
    source_lang                   OKL_CNSLD_AR_STRMS_TL.SOURCE_LANG%TYPE := '',
    sfwt_flag                     OKL_CNSLD_AR_STRMS_TL.SFWT_FLAG%TYPE := '',
    created_by                    OKL_CNSLD_AR_STRMS_TL.CREATED_BY%TYPE := null,
    creation_date                 OKL_CNSLD_AR_STRMS_TL.CREATION_DATE%TYPE := null,
    last_updated_by               OKL_CNSLD_AR_STRMS_TL.LAST_UPDATED_BY%TYPE := null,
    last_update_date              OKL_CNSLD_AR_STRMS_TL.LAST_UPDATE_DATE%TYPE := null,
    last_update_login             OKL_CNSLD_AR_STRMS_TL.LAST_UPDATE_LOGIN%TYPE := null);

  TYPE lln_tbl_type IS TABLE OF lln_rec_type
        INDEX BY BINARY_INTEGER;

  TYPE lln_tl_tbl_type IS TABLE OF lln_tl_rec_type
        INDEX BY BINARY_INTEGER;

  g_line_counter   NUMBER := 0;
  g_cons_bill_tbl  NUMBER := 0;
  g_lln_tbl        lln_tbl_type;
  g_lln_tl_tbl     lln_tl_tbl_type;

  TYPE lsm_tbl_type IS TABLE OF lsm_rec_type
        INDEX BY BINARY_INTEGER;

  TYPE lsm_tl_tbl_type IS TABLE OF lsm_tl_rec_type
        INDEX BY BINARY_INTEGER;

  g_lsm_tbl        lsm_tbl_type;
  g_lsm_tl_tbl     lsm_tl_tbl_type;
  g_stream_counter   NUMBER := 0;

  TYPE cnr_tbl_type IS TABLE OF cnr_rec_type
        INDEX BY BINARY_INTEGER;

  TYPE cnr_tl_tbl_type IS TABLE OF cnr_tl_rec_type
        INDEX BY BINARY_INTEGER;

  g_cnr_tbl        cnr_tbl_type;
  g_cnr_tl_tbl     cnr_tl_tbl_type;
  g_header_counter   NUMBER := 0;


  TYPE lln_total_rec IS RECORD (
	 cnr_id			    NUMBER,
	 lln_id			    NUMBER,
     amount             NUMBER
	);

  TYPE lln_total_tbl IS TABLE OF lln_total_rec
        INDEX BY BINARY_INTEGER;


  g_last_rec BOOLEAN :=FALSE;
  g_cnr_total           NUMBER := 0;
  g_prev_cnr_id         NUMBER;

  g_lln_total           NUMBER := 0;
  g_prev_lln_id         NUMBER;

  TYPE xsi_rec IS RECORD (
     id                    okl_ext_sell_invs_b.id%type,
	 trx_status_code	   okl_ext_sell_invs_b.trx_status_code%type,
	 xtrx_invoice_pull_yn  okl_ext_sell_invs_b.	xtrx_invoice_pull_yn%type);

  TYPE xsi_tbl IS TABLE OF xsi_rec
        INDEX BY BINARY_INTEGER;

  g_xsi_tbl             xsi_tbl;
  g_xsi_counter         NUMBER := 0;

  TYPE xls_rec IS RECORD (
     id                        okl_xtl_sell_invs_b.id%type,
	 lsm_id                    okl_xtl_sell_invs_b.lsm_id%type,
	 xtrx_cons_line_number     okl_xtl_sell_invs_b.xtrx_cons_line_number%type,
	 xtrx_cons_stream_id       okl_xtl_sell_invs_b.xtrx_cons_stream_id%type);

  TYPE xls_tbl IS TABLE OF xls_rec
        INDEX BY BINARY_INTEGER;

  g_xls_tbl             xls_tbl;
  g_xls_counter         NUMBER := 0;


  TYPE xsi_tl_rec IS RECORD (
     id                        okl_ext_sell_invs_tl.id%type,
	 xtrx_cons_invoice_number  okl_ext_sell_invs_tl.xtrx_cons_invoice_number%type,
	 xtrx_format_type          okl_ext_sell_invs_tl.xtrx_format_type%type,
	 xtrx_private_label        okl_ext_sell_invs_tl.xtrx_private_label%type);

  TYPE xsi_tl_tbl IS TABLE OF xsi_tl_rec
        INDEX BY BINARY_INTEGER;

  g_xsi_tl_tbl             xsi_tl_tbl;
  g_xsi_tl_counter         NUMBER := 0;

  TYPE xls_tl_rec IS RECORD (
     id                    okl_xtl_sell_invs_tl.id%type,
     xtrx_contract         okl_xtl_sell_invs_tl.xtrx_contract%type,
     xtrx_asset            okl_xtl_sell_invs_tl.xtrx_asset%type,
     xtrx_stream_type      okl_xtl_sell_invs_tl.xtrx_stream_type%type,
     xtrx_stream_group     okl_xtl_sell_invs_tl.xtrx_stream_group%type);

  TYPE xls_tl_tbl IS TABLE OF xls_tl_rec
        INDEX BY BINARY_INTEGER;

  g_xls_tl_tbl             xls_tl_tbl;
  g_xls_tl_counter         NUMBER := 0;

  TYPE asset_rec IS RECORD (
     id                   okc_k_lines_b.id%type,
     name                 okc_k_lines_tl.name%type);

  TYPE asset_tbl IS TABLE OF asset_rec
        INDEX BY BINARY_INTEGER;

  -- fmiao 5232919 change start
   -- Defining global table records for OKL_INV_MSSG_ATT records
   g_imav_tbl      OKL_IMA_PVT.imav_tbl_type;
   g_imav_counter  NUMBER := 0;

  TYPE msg_rec IS RECORD (
     id                   okl_invoice_mssgs_v.id%type,
     priority             okl_invoice_mssgs_v.priority%type,
     pkg_name             okl_invoice_mssgs_v.pkg_name%type,
     proc_name            okl_invoice_mssgs_v.proc_name%type,
     start_date           okl_invoice_mssgs_v.start_date%TYPE,
     end_date             okl_invoice_mssgs_v.end_date%TYPE);
  -- fmiao 5232919 change end

  TYPE msg_tbl IS TABLE OF msg_rec
        INDEX BY BINARY_INTEGER;

  g_msg_tbl               msg_tbl;
  g_inv_msg               VARCHAR2(25) := 'TRUE';

  PROCEDURE create_cons_bill(
           p_contract_number	IN  VARCHAR2	DEFAULT NULL,
	       p_api_version        IN  NUMBER,
    	   p_init_msg_list      IN  VARCHAR2 DEFAULT Okl_Api.G_FALSE,
           p_commit             IN  VARCHAR2 DEFAULT FND_API.G_FALSE,
           p_inv_msg            IN  VARCHAR2 DEFAULT 'TRUE',
           p_assigned_process   IN  VARCHAR2 DEFAULT NULL,
    	   x_return_status      OUT NOCOPY VARCHAR2,
    	   x_msg_count          OUT NOCOPY NUMBER,
    	   x_msg_data           OUT NOCOPY VARCHAR2);

  PROCEDURE process_cons_bill_tbl(
           p_contract_number	IN  VARCHAR2	DEFAULT NULL,
	       p_api_version        IN NUMBER,
    	   p_init_msg_list      IN VARCHAR2 DEFAULT Okl_Api.G_FALSE,
           p_commit             IN  VARCHAR2 DEFAULT FND_API.G_FALSE,
    	   x_return_status      OUT NOCOPY VARCHAR2,
    	   x_msg_count          OUT NOCOPY NUMBER,
    	   x_msg_data           OUT NOCOPY VARCHAR2,
           p_cons_bill_tbl      IN OUT NOCOPY cons_bill_tbl_type,
           p_saved_bill_rec     IN OUT NOCOPY saved_bill_rec_type,
           p_update_tbl         IN OUT NOCOPY update_tbl_type);

  FUNCTION get_invoice_group(p_khr_id NUMBER)
       RETURN VARCHAR2;

  PRAGMA RESTRICT_REFERENCES(get_invoice_group, WNDS);

END OKL_BILLING_CONTROLLER_PVT;

/
