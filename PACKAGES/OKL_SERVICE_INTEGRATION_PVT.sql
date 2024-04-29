--------------------------------------------------------
--  DDL for Package OKL_SERVICE_INTEGRATION_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OKL_SERVICE_INTEGRATION_PVT" AUTHID CURRENT_USER AS
/* $Header: OKLRSRIS.pls 120.2 2005/10/30 03:42:06 appldev noship $*/

  G_INVALID_VALUE             CONSTANT VARCHAR2(1000) := 'OKL_INVALID_VALUE';
  G_UNEXPECTED_ERROR          CONSTANT VARCHAR2(1000) := 'OKL_UNEXPECTED_ERROR';
  G_OKL_ITEM_MISMATCH         CONSTANT VARCHAR2(1000) := 'OKL_LLA_ITEM_MISMATCH';
  G_OKL_LINK_CON_ERROR        CONSTANT VARCHAR2(1000) := 'OKL_LLA_INVALID_LINK_CONTRACT';
  G_OKL_MULTI_LINK_ERROR      CONSTANT VARCHAR2(1000) := 'OKL_LLA_MULTI_LINK_ERROR';
  G_OKL_ITEM_QTY_MISMATCH     CONSTANT VARCHAR2(1000) := 'OKL_LLA_ITEM_QTY_MISMATCH';
  G_LLA_SERV_LINE_LINK_ERROR  CONSTANT VARCHAR2(1000) := 'OKL_LLA_SERV_LINE_LINK_ERROR';
  G_LLA_CURR_MISMATCH         CONSTANT VARCHAR2(1000) := 'OKL_LLA_CURR_MISMATCH';
  G_LLA_CUST_MISMATCH         CONSTANT VARCHAR2(1000) := 'OKL_LLA_CUST_MISMATCH';
  G_LLA_BILL_TO_MISMATCH      CONSTANT VARCHAR2(1000) := 'OKL_LLA_BILL_TO_MISMATCH';
  G_LLA_COV_ASSET_ERROR       CONSTANT VARCHAR2(1000) := 'OKL_LLA_COV_ASSET_ERROR';
  G_SERVICE_LINK_EXIST        CONSTANT VARCHAR2(1000) := 'OKL_LLA_SERVICE_LINK_EXIST';
  G_SRV_NO_ASSET_MATCH        CONSTANT VARCHAR2(1000) := 'OKL_SRV_NO_ASSET_MATCH';


  SUBTYPE clev_rec_type IS okl_okc_migration_pvt.clev_rec_type;
  SUBTYPE clev_tbl_type IS okl_okc_migration_pvt.clev_tbl_type;
  SUBTYPE klev_rec_type IS okl_contract_pub.klev_rec_type;
  SUBTYPE klev_tbl_type IS okl_contract_pub.klev_tbl_type;
  SUBTYPE cimv_tbl_type IS okl_okc_migration_pvt.cimv_tbl_type;

  TYPE link_line_rec_type IS RECORD (
     okl_service_line_id OKC_K_LINES_V.ID%TYPE,
     oks_service_line_id OKC_K_LINES_V.ID%TYPE
  );

  TYPE link_line_tbl_type IS TABLE OF link_line_rec_type INDEX BY BINARY_INTEGER;

  TYPE srv_cov_rec_type IS RECORD (
     oks_cov_prod_line_id OKC_K_LINES_V.ID%TYPE
  );

  TYPE srv_cov_tbl_type IS TABLE OF srv_cov_rec_type INDEX BY BINARY_INTEGER;

  PROCEDURE Report_Error(
                         x_msg_count OUT NOCOPY NUMBER,
                         x_msg_data  OUT NOCOPY VARCHAR2
                        );

  PROCEDURE create_service_line(
                                p_api_version         IN  NUMBER,
                                p_init_msg_list       IN  VARCHAR2,
                                x_return_status       OUT NOCOPY VARCHAR2,
                                x_msg_count           OUT NOCOPY NUMBER,
                                x_msg_data            OUT NOCOPY VARCHAR2,
                                p_okl_chr_id          IN  OKC_K_HEADERS_V.ID%TYPE, -- Lease Contract Header ID
                                p_oks_chr_id          IN  OKC_K_HEADERS_V.ID%TYPE, -- Service Contract Header ID
                                p_oks_service_line_id IN  OKC_K_LINES_V.ID%TYPE,   -- Service Contract Service Top Line ID
                                p_supplier_id         IN  NUMBER,
                                x_okl_service_line_id OUT NOCOPY OKC_K_LINES_V.ID%TYPE -- Returns Lease Service TOP Line ID
                               );

  PROCEDURE link_service_line(
                                p_api_version         IN  NUMBER,
                                p_init_msg_list       IN  VARCHAR2,
                                x_return_status       OUT NOCOPY VARCHAR2,
                                x_msg_count           OUT NOCOPY NUMBER,
                                x_msg_data            OUT NOCOPY VARCHAR2,
                                p_okl_chr_id          IN  OKC_K_HEADERS_V.ID%TYPE, -- Lease Contract Header ID
                                p_oks_chr_id          IN  OKC_K_HEADERS_V.ID%TYPE, -- Service Contract Header ID
                                p_okl_service_line_id IN  OKC_K_LINES_V.ID%TYPE,   -- Lease Service Top Line ID
                                p_oks_service_line_id IN  OKC_K_LINES_V.ID%TYPE    -- Service Contract - Service TOP Line ID
                               );

  PROCEDURE delete_service_line(
                                p_api_version         IN  NUMBER,
                                p_init_msg_list       IN  VARCHAR2,
                                x_return_status       OUT NOCOPY VARCHAR2,
                                x_msg_count           OUT NOCOPY NUMBER,
                                x_msg_data            OUT NOCOPY VARCHAR2,
                                p_clev_rec            IN  clev_rec_type,
                                p_klev_rec            IN  klev_rec_type
                               );

  PROCEDURE check_service_link (
                                p_api_version             IN  NUMBER,
                                p_init_msg_list           IN  VARCHAR2,
                                x_return_status           OUT NOCOPY VARCHAR2,
                                x_msg_count               OUT NOCOPY NUMBER,
                                x_msg_data                OUT NOCOPY VARCHAR2,
                                p_lease_contract_id       IN  OKC_K_HEADERS_V.ID%TYPE,
                                x_service_contract_id     OUT NOCOPY OKC_K_HEADERS_V.ID%TYPE
                               );

  PROCEDURE check_service_line_link (
                                p_api_version             IN  NUMBER,
                                p_init_msg_list           IN  VARCHAR2,
                                x_return_status           OUT NOCOPY VARCHAR2,
                                x_msg_count               OUT NOCOPY NUMBER,
                                x_msg_data                OUT NOCOPY VARCHAR2,
                                p_lease_contract_id       IN  OKC_K_HEADERS_V.ID%TYPE,
                                p_oks_service_line_id     IN  OKC_K_LINES_V.ID%TYPE,
                                x_service_contract_id     OUT NOCOPY OKC_K_HEADERS_V.ID%TYPE
                               );

  PROCEDURE get_service_link_line (
                                   p_api_version             IN  NUMBER,
                                   p_init_msg_list           IN  VARCHAR2,
                                   x_return_status           OUT NOCOPY VARCHAR2,
                                   x_msg_count               OUT NOCOPY NUMBER,
                                   x_msg_data                OUT NOCOPY VARCHAR2,
                                   p_lease_contract_id       IN  OKC_K_HEADERS_V.ID%TYPE,
                                   x_link_line_tbl           OUT NOCOPY LINK_LINE_TBL_TYPE,
                                   x_service_contract_id     OUT NOCOPY OKC_K_HEADERS_V.ID%TYPE
                                  );

  PROCEDURE create_link_service_line(
                                p_api_version         IN  NUMBER,
                                p_init_msg_list       IN  VARCHAR2,
                                x_return_status       OUT NOCOPY VARCHAR2,
                                x_msg_count           OUT NOCOPY NUMBER,
                                x_msg_data            OUT NOCOPY VARCHAR2,
                                p_okl_chr_id          IN  OKC_K_HEADERS_V.ID%TYPE, -- Lease Contract Header ID
                                p_oks_chr_id          IN  OKC_K_HEADERS_V.ID%TYPE, -- Service Contract Header ID
                                p_oks_service_line_id IN  OKC_K_LINES_V.ID%TYPE,   -- Service Contract Service Top Line ID
                                p_supplier_id         IN  NUMBER,
                                x_okl_service_line_id OUT NOCOPY OKC_K_LINES_V.ID%TYPE -- Returns Contract Service TOP Line ID
                               );

  PROCEDURE update_service_line(
                                p_api_version         IN  NUMBER,
                                p_init_msg_list       IN  VARCHAR2,
                                x_return_status       OUT NOCOPY VARCHAR2,
                                x_msg_count           OUT NOCOPY NUMBER,
                                x_msg_data            OUT NOCOPY VARCHAR2,
                                p_okl_chr_id          IN  OKC_K_HEADERS_V.ID%TYPE, -- Lease Contract Header ID
                                p_oks_chr_id          IN  OKC_K_HEADERS_V.ID%TYPE, -- Service Contract Header ID
                                p_oks_service_line_id IN  OKC_K_LINES_V.ID%TYPE,   -- Service Contract Service Top Line ID
                                p_supplier_id         IN  NUMBER,
                                p_clev_rec            IN  clev_rec_type,
                                p_klev_rec            IN  klev_rec_type,
                                x_okl_service_line_id OUT NOCOPY OKC_K_LINES_V.ID%TYPE
                              );

  PROCEDURE create_cov_asset_line(
                                 p_api_version    IN  NUMBER,
                                 p_init_msg_list  IN  VARCHAR2 DEFAULT OKC_API.G_FALSE,
                                 x_return_status  OUT NOCOPY VARCHAR2,
                                 x_msg_count      OUT NOCOPY NUMBER,
                                 x_msg_data       OUT NOCOPY VARCHAR2,
                                 p_clev_tbl       IN  clev_tbl_type,
                                 p_klev_tbl       IN  klev_tbl_type,
                                 p_cimv_tbl       IN  cimv_tbl_type,
                                 p_cov_tbl        IN  srv_cov_tbl_type,
                                 x_clev_tbl       OUT NOCOPY clev_tbl_type,
                                 x_klev_tbl       OUT NOCOPY klev_tbl_type,
                                 x_cimv_tbl       OUT NOCOPY cimv_tbl_type
                               );

  PROCEDURE update_cov_asset_line(
                                 p_api_version    IN  NUMBER,
                                 p_init_msg_list  IN  VARCHAR2 DEFAULT OKC_API.G_FALSE,
                                 x_return_status  OUT NOCOPY VARCHAR2,
                                 x_msg_count      OUT NOCOPY NUMBER,
                                 x_msg_data       OUT NOCOPY VARCHAR2,
                                 p_clev_tbl       IN  clev_tbl_type,
                                 p_klev_tbl       IN  klev_tbl_type,
                                 p_cimv_tbl       IN  cimv_tbl_type,
                                 p_cov_tbl        IN  srv_cov_tbl_type,
                                 x_clev_tbl       OUT NOCOPY clev_tbl_type,
                                 x_klev_tbl       OUT NOCOPY klev_tbl_type,
                                 x_cimv_tbl       OUT NOCOPY cimv_tbl_type);

  PROCEDURE update_jtf_code(
                            p_api_version    IN  NUMBER,
                            p_init_msg_list  IN  VARCHAR2 DEFAULT OKC_API.G_FALSE,
                            x_return_status  OUT NOCOPY VARCHAR2,
                            x_msg_count      OUT NOCOPY NUMBER,
                            x_msg_data       OUT NOCOPY VARCHAR2,
                            p_okl_chr_id     IN  OKC_K_HEADERS_B.ID%TYPE,
                            p_oks_chr_id     IN  OKC_K_HEADERS_B.ID%TYPE,
                            p_jtf_code       IN  VARCHAR2
                           );

  PROCEDURE initiate_service_booking(
                                    p_api_version    IN  NUMBER,
                                    p_init_msg_list  IN  VARCHAR2 DEFAULT OKC_API.G_FALSE,
                                    x_return_status  OUT NOCOPY VARCHAR2,
                                    x_msg_count      OUT NOCOPY NUMBER,
                                    x_msg_data       OUT NOCOPY VARCHAR2,
                                    p_okl_chr_id     IN  OKC_K_HEADERS_B.ID%TYPE
                                );

  PROCEDURE create_service_from_oks(
                                  p_api_version         IN  NUMBER,
                                  p_init_msg_list       IN  VARCHAR2,
                                  x_return_status       OUT NOCOPY VARCHAR2,
                                  x_msg_count           OUT NOCOPY NUMBER,
                                  x_msg_data            OUT NOCOPY VARCHAR2,
                                  p_okl_chr_id          IN  OKC_K_HEADERS_V.ID%TYPE,
                                  p_oks_chr_id          IN  OKC_K_HEADERS_V.ID%TYPE,
                                  p_supplier_id         IN  NUMBER,
                                  p_sty_id              IN  OKL_K_LINES.STY_ID%TYPE DEFAULT NULL,
                                  x_okl_service_line_id OUT NOCOPY OKC_K_LINES_V.ID%TYPE
                                 );

  PROCEDURE delink_service_contract(
                                    p_api_version         IN  NUMBER,
                                    p_init_msg_list       IN  VARCHAR2,
                                    x_return_status       OUT NOCOPY VARCHAR2,
                                    x_msg_count           OUT NOCOPY NUMBER,
                                    x_msg_data            OUT NOCOPY VARCHAR2,
                                    p_okl_chr_id          IN  OKC_K_HEADERS_V.ID%TYPE
                                   );

  PROCEDURE expire_lease_instance(
                                  p_api_version         IN  NUMBER,
                                  p_init_msg_list       IN  VARCHAR2,
                                  x_return_status       OUT NOCOPY VARCHAR2,
                                  x_msg_count           OUT NOCOPY NUMBER,
                                  x_msg_data            OUT NOCOPY VARCHAR2,
                                  p_okl_chr_id          IN  OKC_K_HEADERS_V.ID%TYPE
                                 );

  PROCEDURE relink_service_contract(
                                    p_api_version         IN  NUMBER,
                                    p_init_msg_list       IN  VARCHAR2,
                                    x_return_status       OUT NOCOPY VARCHAR2,
                                    x_msg_count           OUT NOCOPY NUMBER,
                                    x_msg_data            OUT NOCOPY VARCHAR2,
                                    p_okl_chr_id          IN  OKC_K_HEADERS_V.ID%TYPE,
                                    p_oks_chr_id          IN  OKC_K_HEADERS_V.ID%TYPE,
                                    p_supplier_id         IN  NUMBER,
                                    p_sty_id              IN  OKL_K_LINES.STY_ID%TYPE DEFAULT NULL,
                                    x_okl_service_line_id OUT NOCOPY OKC_K_LINES_V.ID%TYPE
                                   );

END OKL_SERVICE_INTEGRATION_PVT;

 

/
