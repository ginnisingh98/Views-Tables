--------------------------------------------------------
--  DDL for Package OKL_OPEN_INTERFACE_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OKL_OPEN_INTERFACE_PVT" AUTHID CURRENT_USER AS
/* $Header: OKLRKOIS.pls 120.4 2005/11/07 18:36:20 dedey noship $*/

  -- Contract Header Record Type Definition
  subtype khrv_rec_type IS OKL_CONTRACT_PUB.khrv_rec_type;
  subtype chrv_rec_type IS OKL_OKC_MIGRATION_PVT.chrv_rec_type;

  -- Contract Party Role Record Type Definition
  subtype cplv_rec_type IS OKL_OKC_MIGRATION_PVT.cplv_rec_type;
  subtype kplv_rec_type IS OKL_K_PARTY_ROLES_PVT.kplv_rec_type; -- Bug 4558486

  -- Contract Rule Record Record Type
  subtype rgpv_rec_type IS OKL_RULE_PUB.rgpv_rec_type;
  subtype rulv_rec_type IS OKL_RULE_PUB.rulv_rec_type;
  subtype rulv_tbl_type IS OKL_RULE_PUB.rulv_tbl_type;

  -- Contract Line Record Type Definition
  subtype clev_rec_type IS OKL_CREATE_KLE_PUB.clev_rec_type;
  subtype klev_rec_type IS OKL_CREATE_KLE_PUB.klev_rec_type;
  subtype cimv_rec_type IS OKL_CREATE_KLE_PUB.cimv_rec_type;
  subtype talv_rec_type IS OKL_CREATE_KLE_PUB.talv_rec_type;
  subtype itiv_tbl_type IS OKL_CREATE_KLE_PUB.itiv_tbl_type;
  subtype sidv_rec_type IS OKL_SUPP_INVOICE_DTLS_PUB.sidv_rec_type;

  subtype rmpv_rec_type IS OKL_RULE_PUB.rmpv_rec_type;

  subtype gvev_rec_type IS OKL_OKC_MIGRATION_PVT.gvev_rec_type;
  subtype adpv_rec_type IS okl_txd_assets_pub.adpv_rec_type;

  subtype pphv_rec_type is okl_party_payments_pvt.pphv_rec_type;
  subtype pphv_tbl_type is okl_party_payments_pvt.pphv_tbl_type;

  subtype ppydv_rec_type IS okl_pyd_pvt.ppydv_rec_type;
  subtype ppydv_tbl_type is okl_pyd_pvt.ppydv_tbl_type;

  PROCEDURE Process_Record_Parallel (
                            errbuf             OUT NOCOPY VARCHAR2,
                            retcode            OUT NOCOPY VARCHAR2,
                            p_batch_number     IN VARCHAR2,
                            p_start_date_from  IN VARCHAR2,
                            p_start_date_to    IN VARCHAR2,
                            p_contract_number  IN VARCHAR2,
                            p_customer_number  IN VARCHAR2,
                            p_instance_number  IN  NUMBER
                           );

  PROCEDURE Process_Record (
                            errbuf             OUT NOCOPY VARCHAR2,
                            retcode            OUT NOCOPY VARCHAR2,
                            p_batch_number     IN VARCHAR2,
                            p_start_date_from  IN VARCHAR2,
                            p_start_date_to    IN VARCHAR2,
                            p_contract_number  IN VARCHAR2,
                            p_customer_number  IN VARCHAR2,
                            p_instance_number  IN  VARCHAR2 DEFAULT 'NONE'
                           );

  PROCEDURE Check_Input_Record(
                            p_init_msg_list    IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
                            x_return_status    OUT NOCOPY VARCHAR2,
                            x_msg_count        OUT NOCOPY NUMBER,
                            x_msg_data         OUT NOCOPY VARCHAR2,
                            p_batch_number     IN  VARCHAR2,
                            p_start_date_from  IN  DATE,
                            p_start_date_to    IN  DATE,
                            p_contract_number  IN  VARCHAR2,
                            p_customer_number  IN  VARCHAR2,
                            x_total_checked    OUT NOCOPY NUMBER
                           );


  PROCEDURE Load_Input_Record(
                        p_init_msg_list    IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
                        x_return_status    OUT NOCOPY VARCHAR2,
                        x_msg_count        OUT NOCOPY NUMBER,
                        x_msg_data         OUT NOCOPY VARCHAR2,
                        p_batch_number     IN  VARCHAR2,
                        p_start_date_from  IN  DATE,
                        p_start_date_to    IN  DATE,
                        p_contract_number  IN  VARCHAR2,
                        p_customer_number  IN  VARCHAR2,
                        x_total_loaded     OUT NOCOPY NUMBER
                       );

  PROCEDURE contract_further_process(
                                     p_init_msg_list    IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
                                     x_return_status    OUT NOCOPY VARCHAR2,
                                     x_msg_count        OUT NOCOPY NUMBER,
                                     x_msg_data         OUT NOCOPY VARCHAR2,
                                     p_chr_id           IN  OKC_K_HEADERS_V.ID%TYPE,
                                     p_import_stage     IN  VARCHAR2
                                    );

  PROCEDURE contract_after_yield(
                                 p_api_version   IN NUMBER,
                                 p_init_msg_list IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
                                 x_return_status OUT NOCOPY VARCHAR2,
                                 x_msg_count     OUT NOCOPY NUMBER,
                                 x_msg_data      OUT NOCOPY VARCHAR2,
                                 p_chr_id        IN  OKC_K_HEADERS_V.ID%TYPE
                                );

  PROCEDURE Report_Error(
                         x_msg_count OUT NOCOPY NUMBER,
                         x_msg_data  OUT NOCOPY VARCHAR2
                        );

  PROCEDURE Update_Interface_Status (p_contract_number     IN  okl_header_interface.contract_number_old%TYPE,
                                     p_new_contract_number IN  okl_header_interface.contract_number%TYPE,
                                     p_status              IN  VARCHAR2,
                                     x_return_status       OUT NOCOPY VARCHAR2);

-- Function to submit the concurrent request for Contract Import.

  FUNCTION Submit_Import_Contract(
  		   			p_api_version       IN NUMBER,
  		   			p_init_msg_list 	IN VARCHAR2,
  		   			x_return_status     OUT NOCOPY VARCHAR2,
  		   			x_msg_count 		OUT NOCOPY NUMBER,
  		   			x_msg_data 			OUT NOCOPY VARCHAR2,
  		   			p_batch_number  	IN VARCHAR2,
  		   			p_contract_number 	IN VARCHAR2,
  		   			p_start_date  		IN DATE,
  		   			p_end_date  		IN DATE,
  		   			p_party_number 		IN VARCHAR2)
   RETURN NUMBER ;

END OKL_OPEN_INTERFACE_PVT;

 

/
