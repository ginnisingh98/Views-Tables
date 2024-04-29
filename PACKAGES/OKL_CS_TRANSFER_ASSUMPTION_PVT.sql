--------------------------------------------------------
--  DDL for Package OKL_CS_TRANSFER_ASSUMPTION_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OKL_CS_TRANSFER_ASSUMPTION_PVT" AUTHID CURRENT_USER AS
/* $Header: OKLRTRAS.pls 120.4 2005/10/30 04:39:18 appldev noship $ */

  -------------------------------------------------------------------------------------------------
-- GLOBAL MESSAGE CONSTANTS
-------------------------------------------------------------------------------------------------
  G_FND_APP                     CONSTANT  VARCHAR2(200) := OKL_API.G_FND_APP;
  G_COL_NAME_TOKEN              CONSTANT  VARCHAR2(200) := OKL_API.G_COL_NAME_TOKEN;
  G_PARENT_TABLE_TOKEN	        CONSTANT  VARCHAR2(200) := OKL_API.G_PARENT_TABLE_TOKEN;
  G_CHILD_TABLE_TOKEN	        CONSTANT  VARCHAR2(200) := OKL_API.G_CHILD_TABLE_TOKEN;
  G_UNEXPECTED_ERROR            CONSTANT  VARCHAR2(200) := 'OKL_UNEXPECTED_ERROR';
  G_SQLERRM_TOKEN               CONSTANT  VARCHAR2(200) := 'SQLerrm';
  G_SQLCODE_TOKEN               CONSTANT  VARCHAR2(200) := 'SQLcode';
  G_NO_PARENT_RECORD            CONSTANT  VARCHAR2(200) := 'NO_PARENT_RECORD';
  G_REQUIRED_VALUE              CONSTANT  VARCHAR2(200) := 'REQUIRED_VALUE';

------------------------------------------------------------------------------------
-- GLOBAL EXCEPTION
------------------------------------------------------------------------------------
  G_EXCEPTION_HALT_VALIDATION             EXCEPTION;
  G_EXCEPTION_STOP_VALIDATION             EXCEPTION;
  G_API_TYPE                    CONSTANT  VARCHAR2(4) := '_PVT';
  G_API_VERSION                 CONSTANT  NUMBER := 1.0;
  G_SCOPE                       CONSTANT  VARCHAR2(4) := '_PVT';

 -- GLOBAL VARIABLES
-----------------------------------------------------------------------------------
  G_PKG_NAME                    CONSTANT  VARCHAR2(200) := 'OKL_CS_TRANSFER';
  G_APP_NAME                    CONSTANT  VARCHAR2(3)   :=  OKL_API.G_APP_NAME;



  --GLOBAL DATA STRUCTURES---------------------------------------------------------
  TYPE  before_trf_rec IS RECORD(id               NUMBER,
                                 line_type        VARCHAR2(10));

  TYPE  before_trf_tbl  IS TABLE OF  before_trf_rec
  INDEX BY BINARY_INTEGER;

  TYPE 	after_trf_rec IS RECORD(id                NUMBER,
                                line_type         VARCHAR2(10),
                                bill_to_site_id   NUMBER,
                                install_loc_id    NUMBER,
                                fa_loc_id         NUMBER);
  TYPE	after_trf_tbl IS TABLE OF after_trf_rec
  INDEX	BY BINARY_INTEGER;

  SUBTYPE l_after_trf_tbl IS  after_trf_tbl;
  SUBTYPE l_before_trf_tbl IS before_trf_tbl;

  g_after_trf	l_after_trf_tbl;
  g_before_trf  l_before_trf_tbl;


  SUBTYPE tcnv_rec_type IS okl_trx_contracts_pvt.tcnv_rec_type;
  SUBTYPE tcnv_tbl_type IS okl_trx_contracts_pvt.tcnv_tbl_type;

  SUBTYPE tclv_rec_type IS okl_trx_contracts_pvt.tclv_rec_type;
  SUBTYPE tclv_tbl_type IS okl_trx_contracts_pvt.tclv_tbl_type;


  SUBTYPE taav_tbl_type IS okl_taa_pvt.taav_tbl_type;

  TYPE add_hdr_rec IS RECORD ( new_contract_number   VARCHAR2(120),
                               bill_to_site_id       NUMBER,
                               cust_acct_id          NUMBER,
                               bank_acct_Id          NUMBER,
                               invoice_format_id     NUMBER,
                               payment_mthd_id       NUMBER,
                               mla_id                NUMBER,
                               credit_line_id        NUMBER,
                               insurance_yn          VARCHAR2(1),
                               lease_policy_yn       VARCHAR2(1));
  TYPE	add_hdr_tbl IS TABLE OF add_hdr_rec
  INDEX	BY BINARY_INTEGER;

  SUBTYPE add_hdr_tbl_type IS   add_hdr_tbl;

   TYPE upd_hdr_rec IS RECORD (id              NUMBER,
                               new_contract_number   VARCHAR2(120),
                               bill_to_site_id       NUMBER,
                               cust_acct_id          NUMBER,
                               bank_acct_Id          NUMBER,
                               invoice_format_id     NUMBER,
                               payment_mthd_id       NUMBER,
                               mla_id                NUMBER,
                               credit_line_id        NUMBER,
                               insurance_yn          VARCHAR2(1),
                               lease_policy_yn       VARCHAR2(1));
  TYPE	upd_hdr_tbl IS TABLE OF upd_hdr_rec
  INDEX	BY BINARY_INTEGER;

  SUBTYPE upd_hdr_tbl_type IS   upd_hdr_tbl;

   TYPE new_lessee_rec IS RECORD (taa_id                    NUMBER,
                                  new_contract_number   VARCHAR2(120),
                                  new_lessee            VARCHAR2(360),
                                  new_party_id          NUMBER,
                                  contact_name          VARCHAR2(360),
                                  contact_id            NUMBER,
                                  contact_email         VARCHAR2(2000),
                                  contact_phone         VARCHAR2(30),
                                  bill_to_address       VARCHAR2(4000),
                                  bill_to_id            NUMBER,
                                  cust_acct_number      VARCHAR2(30),
                                  cust_acct_id          NUMBER,
                                  bank_account          VARCHAR2(30),
                                  bank_acct_id          NUMBER,
                                  invoice_format        VARCHAR2(450),
                                  inv_fmt_id         NUMBER,
                                  payment_method        VARCHAR2(30),
                                  pay_mthd_id           NUMBER,
                                  master_lease          VARCHAR2(120),
                                  mla_id                NUMBER,
                                  credit_line_no        VARCHAR2(120),
                                  credit_line_id        NUMBER,
                                  insurance_yn          VARCHAR2(1),
                                  lease_policy_yn       VARCHAR2(1));

  TYPE	new_lessee_tbl IS TABLE OF new_lessee_rec
  INDEX	BY BINARY_INTEGER;

  SUBTYPE new_lessee_tbl_type IS   new_lessee_tbl;


    TYPE insurance_rec IS RECORD (insurer               VARCHAR2(360),
                                  insurance_agent       VARCHAR2(360),
                                  policy_number         VARCHAR2(20),
                                  covered_amount        NUMBER,
                                  deductible_amount     NUMBER,
                                  effective_from        DATE,
                                  effective_to          DATE,
                                  proof_provided        DATE,
                                  proof_required        DATE,
                                  lessor_insured_yn     VARCHAR2(10),
                                  lessor_payee_yn       VARCHAR2(10));


  TYPE	insurance_tbl IS TABLE OF insurance_rec
  INDEX	BY BINARY_INTEGER;

  SUBTYPE insurance_tbl_type IS   insurance_tbl;

  PROCEDURE Create_Requests(
                            p_api_version                    IN  NUMBER,
                            p_init_msg_list                  IN  VARCHAR2 DEFAULT Okc_Api.G_FALSE,
                            p_header_tbl                     IN  tcnv_tbl_type,
                            p_add_hdr_tbl                    IN  add_hdr_tbl_type,
                            p_old_line_tbl                   IN  l_before_trf_tbl,
                            p_new_line_tbl                   IN  l_after_trf_tbl,
                            x_header_tbl                     OUT NOCOPY Okl_Trx_Contracts_Pub.tcnv_tbl_type,
                            x_taaV_tbl                       OUT NOCOPY taav_tbl_type,
                            x_return_status                  OUT NOCOPY VARCHAR2,
                            x_msg_count                      OUT NOCOPY NUMBER,
                            x_msg_data                       OUT NOCOPY VARCHAR2) ;


 PROCEDURE Accept_Requests( p_api_version                    IN  NUMBER,
                            p_init_msg_list                  IN  VARCHAR2 DEFAULT Okc_Api.G_FALSE,
                            p_header_tbl                     IN  tcnv_tbl_type,
                            p_upd_hdr_tbl                    IN  upd_hdr_tbl_type,
                            p_old_line_tbl                   IN  l_before_trf_tbl,
                            p_new_line_tbl                   IN  l_after_trf_tbl,
                            x_header_tbl                     OUT NOCOPY Okl_Trx_Contracts_Pub.tcnv_tbl_type,
                            x_taaV_tbl                       OUT NOCOPY taav_tbl_type,
                            x_return_status                  OUT NOCOPY VARCHAR2,
                            x_msg_count                      OUT NOCOPY NUMBER,
                            x_msg_data                       OUT NOCOPY VARCHAR2);

  PROCEDURE Update_Requests( p_api_version                    IN  NUMBER,
                            p_init_msg_list                  IN  VARCHAR2 DEFAULT Okc_Api.G_FALSE,
                            p_header_tbl                     IN  tcnv_tbl_type,
                            p_upd_hdr_tbl                    IN  upd_hdr_tbl_type,
                            p_old_line_tbl                   IN  l_before_trf_tbl,
                            p_new_line_tbl                   IN  l_after_trf_tbl,
                            x_header_tbl                     OUT NOCOPY Okl_Trx_Contracts_Pub.tcnv_tbl_type,
                            x_taaV_tbl                       OUT NOCOPY taav_tbl_type,
                            x_return_status                  OUT NOCOPY VARCHAR2,
                            x_msg_count                      OUT NOCOPY NUMBER,
                            x_msg_data                       OUT NOCOPY VARCHAR2);

PROCEDURE Populate_new_Lessee_details( p_api_version                    IN  NUMBER,
                                       p_init_msg_list                  IN  VARCHAR2 DEFAULT OKC_API.G_FALSE,
                                       p_request_id                     IN  NUMBER,
                                       x_new_lessee_tbl                 OUT NOCOPY new_lessee_tbl_type,
                                       x_return_status                  OUT NOCOPY VARCHAR2,
                                       x_msg_count                      OUT NOCOPY NUMBER,
                                       x_msg_data                       OUT NOCOPY VARCHAR2);

PROCEDURE Populate_ThirdParty_Insurance( p_api_version                    IN  NUMBER,
                                         p_init_msg_list                  IN  VARCHAR2 DEFAULT OKC_API.G_FALSE,
                                         p_taa_id                         IN  NUMBER,
                                         x_insurance_tbl                  OUT NOCOPY insurance_tbl_type,
                                         x_return_status                  OUT NOCOPY VARCHAR2,
                                         x_msg_count                      OUT NOCOPY NUMBER,
                                         x_msg_data                       OUT NOCOPY VARCHAR2);





END OKL_CS_TRANSFER_ASSUMPTION_PVT;



 

/
