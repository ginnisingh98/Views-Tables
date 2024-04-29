--------------------------------------------------------
--  DDL for Package OKL_SERVICE_INTEGRATION_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OKL_SERVICE_INTEGRATION_PUB" AUTHID CURRENT_USER AS
/* $Header: OKLPSRIS.pls 115.1 2002/12/30 23:13:08 dedey noship $*/


  SUBTYPE clev_rec_type IS okl_okc_migration_pvt.clev_rec_type;
  SUBTYPE clev_tbl_type IS okl_okc_migration_pvt.clev_tbl_type;
  SUBTYPE klev_rec_type IS okl_contract_pub.klev_rec_type;
  SUBTYPE klev_tbl_type IS okl_contract_pub.klev_tbl_type;
  SUBTYPE cimv_tbl_type IS okl_okc_migration_pvt.cimv_tbl_type;

  SUBTYPE link_line_tbl_type IS okl_service_integration_pvt.link_line_tbl_type;
  SUBTYPE srv_cov_tbl_type IS okl_service_integration_pvt.srv_cov_tbl_type;

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

  PROCEDURE initiate_service_booking(
                                    p_api_version    IN  NUMBER,
                                    p_init_msg_list  IN  VARCHAR2 DEFAULT OKC_API.G_FALSE,
                                    x_return_status  OUT NOCOPY VARCHAR2,
                                    x_msg_count      OUT NOCOPY NUMBER,
                                    x_msg_data       OUT NOCOPY VARCHAR2,
                                    p_okl_chr_id     IN  OKC_K_HEADERS_B.ID%TYPE
                                );

END OKL_SERVICE_INTEGRATION_PUB;

 

/
