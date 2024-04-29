--------------------------------------------------------
--  DDL for Package OKL_VENDOR_PROGRAM_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OKL_VENDOR_PROGRAM_PUB" AUTHID CURRENT_USER AS
/*$Header: OKLPPRMS.pls 120.1 2005/10/29 02:14:33 manumanu noship $*/

SUBTYPE chrv_rec_type    IS OKL_OKC_MIGRATION_PVT.chrv_rec_type;
SUBTYPE khrv_rec_type    IS OKL_CONTRACT_PUB.khrv_rec_type;

  ---------------------------------------------------------------------------
  -- GLOBAL VARIABLES
  ---------------------------------------------------------------------------
  G_PKG_NAME CONSTANT VARCHAR2(200)     := 'OKL_VENDOR_PROGRAM_PUB';
  G_APP_NAME CONSTANT VARCHAR2(3)       :=  OKL_API.G_APP_NAME;


  G_REQUIRED_VALUE                 CONSTANT VARCHAR2(200) := OKL_API.G_REQUIRED_VALUE;
  G_INVALID_VALUE                  CONSTANT VARCHAR2(200) := OKL_API.G_INVALID_VALUE;
  G_SQLERRM_TOKEN                  CONSTANT VARCHAR2(200) := 'OKL_SQLerrm';
  G_SQLCODE_TOKEN                  CONSTANT VARCHAR2(200) := 'OKL_SQLcode';
  G_UNEXPECTED_ERROR               CONSTANT VARCHAR2(200) := 'OKL_CONTRACTS_UNEXPECTED_ERROR';
  G_UPPERCASE_REQUIRED             CONSTANT VARCHAR2(200) := 'OKL_UPPER_CASE_REQUIRED';
  G_COL_NAME_TOKEN                 CONSTANT VARCHAR2(200) := OKL_API.G_COL_NAME_TOKEN;
  G_START_DATE                     CONSTANT VARCHAR2(200) := 'OKL_START_DATE';
  G_END_DATE                       CONSTANT VARCHAR2(200) := 'OKL_END_DATE';


SUBTYPE program_header_rec_type IS OKL_VENDOR_PROGRAM_PVT.program_header_rec_type;


PROCEDURE create_program(p_api_version             IN               NUMBER,
                          p_init_msg_list           IN               VARCHAR2 DEFAULT OKL_API.G_FALSE,
                          x_return_status           OUT              NOCOPY VARCHAR2,
                          x_msg_count               OUT              NOCOPY NUMBER,
                          x_msg_data                OUT              NOCOPY VARCHAR2,
                          p_hdr_rec                 IN               program_header_rec_type,
                          p_parent_agreement_number IN               VARCHAR2 DEFAULT NULL,
                          x_header_rec              OUT NOCOPY              chrv_rec_type,
                          x_k_header_rec            OUT NOCOPY              khrv_rec_type);


PROCEDURE update_program(p_api_version             IN               NUMBER,
                         p_init_msg_list           IN               VARCHAR2 DEFAULT OKL_API.G_FALSE,
                         x_return_status           OUT              NOCOPY VARCHAR2,
                         x_msg_count               OUT              NOCOPY NUMBER,
                         x_msg_data                OUT              NOCOPY VARCHAR2,
                         p_hdr_rec                 IN               program_header_rec_type,
                         p_program_id              IN               NUMBER,
                         p_parent_agreement_id     IN               okc_k_headers_v.ID%TYPE DEFAULT NULL
                        );


FUNCTION Is_Process_Active(p_chr_id IN NUMBER) RETURN VARCHAR2;


END OKL_VENDOR_PROGRAM_PUB;

 

/
