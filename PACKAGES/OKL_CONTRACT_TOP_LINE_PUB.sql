--------------------------------------------------------
--  DDL for Package OKL_CONTRACT_TOP_LINE_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OKL_CONTRACT_TOP_LINE_PUB" AUTHID CURRENT_USER as
/* $Header: OKLPKTLS.pls 115.4 2003/01/07 19:37:08 smereddy noship $ */

  subtype klev_rec_type is OKL_CONTRACT_TOP_LINE_PVT.klev_rec_type;
  subtype klev_tbl_type is OKL_CONTRACT_TOP_LINE_PVT.klev_tbl_type;
  subtype clev_rec_type is OKL_CONTRACT_TOP_LINE_PVT.clev_rec_type;
  subtype clev_tbl_type is OKL_CONTRACT_TOP_LINE_PVT.clev_tbl_type;
  subtype cimv_rec_type is OKL_CONTRACT_TOP_LINE_PVT.cimv_rec_type;
  subtype cimv_tbl_type is OKL_CONTRACT_TOP_LINE_PVT.cimv_tbl_type;
  subtype cplv_rec_type is OKL_CONTRACT_TOP_LINE_PVT.cplv_rec_type;
  subtype cplv_tbl_type is OKL_CONTRACT_TOP_LINE_PVT.cplv_tbl_type;


-- Global variables for user hooks
  G_PKG_NAME  CONSTANT VARCHAR2(200) := 'OKL_CONTRACT_TOP_LINE_PUB';
  G_APP_NAME  CONSTANT VARCHAR2(3)   :=  OKC_API.G_APP_NAME;

  g_klev_rec  klev_rec_type;
  g_klev_tbl  klev_tbl_type;
  g_clev_rec  clev_rec_type;
  g_clev_tbl  clev_tbl_type;
  g_cimv_rec  cimv_rec_type;
  g_cimv_tbl  cimv_tbl_type;
  g_cplv_rec  cplv_rec_type;
  g_cplv_tbl  cplv_tbl_type;

 PROCEDURE create_contract_top_line(
            p_api_version    IN  NUMBER,
            p_init_msg_list  IN  VARCHAR2 DEFAULT OKC_API.G_FALSE,
            x_return_status  OUT NOCOPY VARCHAR2,
            x_msg_count      OUT NOCOPY NUMBER,
            x_msg_data       OUT NOCOPY VARCHAR2,
            p_clev_rec       IN  clev_rec_type,
            p_klev_rec       IN  klev_rec_type,
            p_cimv_rec       IN  cimv_rec_type,
            p_cplv_rec       IN  cplv_rec_type,
            x_clev_rec       OUT NOCOPY clev_rec_type,
            x_klev_rec       OUT NOCOPY klev_rec_type,
            x_cimv_rec       OUT NOCOPY cimv_rec_type,
            x_cplv_rec       OUT NOCOPY cplv_rec_type);


PROCEDURE create_contract_link_serv (
            p_api_version    		IN  NUMBER,
            p_init_msg_list  		IN  VARCHAR2 DEFAULT OKC_API.G_FALSE,
            x_return_status  		OUT NOCOPY   VARCHAR2,
            x_msg_count      		OUT NOCOPY   NUMBER,
            x_msg_data       		OUT NOCOPY   VARCHAR2,
            p_chr_id			IN  NUMBER,
	    p_contract_number           IN  VARCHAR2,
	    p_item_name                 IN  VARCHAR2,
	    p_supplier_name             IN  VARCHAR2,
	    x_cle_id			OUT NOCOPY NUMBER);

  PROCEDURE update_contract_top_line(
            p_api_version    IN  NUMBER,
            p_init_msg_list  IN  VARCHAR2 DEFAULT OKC_API.G_FALSE,
            x_return_status  OUT NOCOPY VARCHAR2,
            x_msg_count      OUT NOCOPY NUMBER,
            x_msg_data       OUT NOCOPY VARCHAR2,
            p_clev_rec       IN  clev_rec_type,
            p_klev_rec       IN  klev_rec_type,
            p_cimv_rec       IN  cimv_rec_type,
            p_cplv_rec       IN  cplv_rec_type,
            x_clev_rec       OUT NOCOPY clev_rec_type,
            x_klev_rec       OUT NOCOPY klev_rec_type,
            x_cimv_rec       OUT NOCOPY cimv_rec_type,
            x_cplv_rec       OUT NOCOPY cplv_rec_type);


PROCEDURE update_contract_link_serv (
            p_api_version    		IN  NUMBER,
            p_init_msg_list  		IN  VARCHAR2 DEFAULT OKC_API.G_FALSE,
            x_return_status  		OUT NOCOPY   VARCHAR2,
            x_msg_count      		OUT NOCOPY   NUMBER,
            x_msg_data       		OUT NOCOPY   VARCHAR2,
            p_chr_id			IN  NUMBER,
            p_cle_id			IN  NUMBER,
	    p_contract_number           IN  VARCHAR2,
	    p_item_name                 IN  VARCHAR2,
	    p_supplier_name             IN  VARCHAR2,
	    x_cle_id			OUT NOCOPY NUMBER);

  PROCEDURE delete_contract_top_line(
            p_api_version    IN  NUMBER,
            p_init_msg_list  IN  VARCHAR2 DEFAULT OKC_API.G_FALSE,
            x_return_status  OUT NOCOPY VARCHAR2,
            x_msg_count      OUT NOCOPY NUMBER,
            x_msg_data       OUT NOCOPY VARCHAR2,
            p_clev_rec       IN  clev_rec_type,
            p_klev_rec       IN  klev_rec_type,
            p_cimv_rec       IN  cimv_rec_type,
            p_cplv_rec       IN  cplv_rec_type);

  PROCEDURE delete_contract_line(
            p_api_version    IN  NUMBER,
            p_init_msg_list  IN  VARCHAR2 DEFAULT OKC_API.G_FALSE,
            x_return_status  OUT NOCOPY VARCHAR2,
            x_msg_count      OUT NOCOPY NUMBER,
            x_msg_data       OUT NOCOPY VARCHAR2,
            p_chr_id         IN  number,
            p_cle_id         IN  number);

 PROCEDURE create_contract_top_line(
            p_api_version    IN  NUMBER,
            p_init_msg_list  IN  VARCHAR2 DEFAULT OKC_API.G_FALSE,
            x_return_status  OUT NOCOPY VARCHAR2,
            x_msg_count      OUT NOCOPY NUMBER,
            x_msg_data       OUT NOCOPY VARCHAR2,
            p_clev_tbl       IN  clev_tbl_type,
            p_klev_tbl       IN  klev_tbl_type,
            p_cimv_tbl       IN  cimv_tbl_type,
            p_cplv_tbl       IN  cplv_tbl_type,
            x_clev_tbl       OUT NOCOPY clev_tbl_type,
            x_klev_tbl       OUT NOCOPY klev_tbl_type,
            x_cimv_tbl       OUT NOCOPY cimv_tbl_type,
            x_cplv_tbl       OUT NOCOPY cplv_tbl_type);

  PROCEDURE update_contract_top_line(
            p_api_version    IN  NUMBER,
            p_init_msg_list  IN  VARCHAR2 DEFAULT OKC_API.G_FALSE,
            x_return_status  OUT NOCOPY VARCHAR2,
            x_msg_count      OUT NOCOPY NUMBER,
            x_msg_data       OUT NOCOPY VARCHAR2,
            p_clev_tbl       IN  clev_tbl_type,
            p_klev_tbl       IN  klev_tbl_type,
            p_cimv_tbl       IN  cimv_tbl_type,
            p_cplv_tbl       IN  cplv_tbl_type,
            x_clev_tbl       OUT NOCOPY clev_tbl_type,
            x_klev_tbl       OUT NOCOPY klev_tbl_type,
            x_cimv_tbl       OUT NOCOPY cimv_tbl_type,
            x_cplv_tbl       OUT NOCOPY cplv_tbl_type);

  PROCEDURE delete_contract_top_line(
            p_api_version    IN  NUMBER,
            p_init_msg_list  IN  VARCHAR2 DEFAULT OKC_API.G_FALSE,
            x_return_status  OUT NOCOPY VARCHAR2,
            x_msg_count      OUT NOCOPY NUMBER,
            x_msg_data       OUT NOCOPY VARCHAR2,
            p_clev_tbl       IN  clev_tbl_type,
            p_klev_tbl       IN  klev_tbl_type,
            p_cimv_tbl       IN  cimv_tbl_type,
            p_cplv_tbl       IN  cplv_tbl_type);

 PROCEDURE validate_fee_expense_rule(
                                     p_api_version         IN  NUMBER,
                                     p_init_msg_list       IN  VARCHAR2 DEFAULT OKL_API.G_FALSE,
                                     x_return_status       OUT NOCOPY VARCHAR2,
                                     x_msg_count           OUT NOCOPY NUMBER,
                                     x_msg_data            OUT NOCOPY VARCHAR2,
                                     p_chr_id              IN  OKC_K_HEADERS_V.ID%TYPE,
                                     p_line_id             IN  OKC_K_LINES_V.ID%TYPE,
                                     p_no_of_period        IN  NUMBER,
                                     p_frequency           IN  VARCHAR2,
                                     p_amount_per_period   IN  NUMBER
                                    );
 PROCEDURE validate_passthru_rule(
                                  p_api_version         IN  NUMBER,
                                  p_init_msg_list       IN  VARCHAR2 DEFAULT OKL_API.G_FALSE,
                                  x_return_status       OUT NOCOPY VARCHAR2,
                                  x_msg_count           OUT NOCOPY NUMBER,
                                  x_msg_data            OUT NOCOPY VARCHAR2,
                                  p_line_id             IN  OKC_K_LINES_V.ID%TYPE,
                                  p_vendor_id           IN  NUMBER,
                                  p_payment_term        IN  VARCHAR2,
                                  p_payment_term_id     IN  NUMBER,
                                  p_pay_to_site         IN  VARCHAR2,
                                  p_pay_to_site_id      IN  NUMBER,
                                  p_payment_method_code IN  VARCHAR2,
                                  x_payment_term_id1    OUT NOCOPY VARCHAR2,
                                  x_pay_site_id1        OUT NOCOPY VARCHAR2,
                                  x_payment_method_id1  OUT NOCOPY VARCHAR2
                                 );

End OKL_CONTRACT_TOP_LINE_PUB;

 

/
