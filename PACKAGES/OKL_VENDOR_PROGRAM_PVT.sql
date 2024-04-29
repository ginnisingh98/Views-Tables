--------------------------------------------------------
--  DDL for Package OKL_VENDOR_PROGRAM_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OKL_VENDOR_PROGRAM_PVT" AUTHID CURRENT_USER AS
/*$Header: OKLRPRMS.pls 120.5 2006/11/03 10:55:11 sosharma noship $*/

SUBTYPE chrv_rec_type    IS OKL_OKC_MIGRATION_PVT.chrv_rec_type;
SUBTYPE khrv_rec_type    IS OKL_CONTRACT_PUB.khrv_rec_type;

 TYPE program_header_rec_type is RECORD (
   p_agreement_number         okl_k_headers_full_v.contract_number%TYPE := OKL_API.G_MISS_CHAR,
   p_contract_category        okl_k_headers_full_v.scs_code%TYPE := OKL_API.G_MISS_CHAR,
   p_start_date               okl_k_headers_full_v.start_date%TYPE := OKL_API.G_MISS_DATE,
   p_end_date                 okl_k_headers_full_v.end_date%TYPE := OKL_API.G_MISS_DATE,
   p_short_description        okl_k_headers_full_v.short_description%TYPE := OKL_API.G_MISS_CHAR,
   p_description              okl_k_headers_full_v.description%TYPE := OKL_API.G_MISS_CHAR,
   p_comments                 okl_k_headers_full_v.comments%TYPE := OKL_API.G_MISS_CHAR,
   p_template_yn              okl_k_headers_full_v.template_yn%TYPE:= OKL_API.G_MISS_CHAR,
   P_qcl_id                   okl_k_headers_full_v.qcl_id%TYPE := OKL_API.G_MISS_NUM,
   p_issue_or_receive         okl_k_headers_full_v.issue_or_receive%TYPE := OKL_API.G_MISS_CHAR,
   p_workflow_process         okc_k_processes_v.pdf_id%TYPE := OKL_API.G_MISS_NUM,
   p_referred_id              okl_k_headers_full_v.khr_id%TYPE,
   p_object1_id1              okc_k_party_roles_v.object1_id1%TYPE :=OKL_API.G_MISS_CHAR,
   p_object1_id2              okc_k_party_roles_v.object1_id2%TYPE :=OKL_API.G_MISS_CHAR,
   p_attribute_category       okl_k_headers_full_v.attribute_category%TYPE:= OKL_API.G_MISS_CHAR,
   p_attribute1               okl_k_headers_full_v.attribute1%TYPE:= OKL_API.G_MISS_CHAR,
   p_attribute2               okl_k_headers_full_v.attribute2%TYPE:= OKL_API.G_MISS_CHAR,
   p_attribute3               okl_k_headers_full_v.attribute3%TYPE:= OKL_API.G_MISS_CHAR,
   p_attribute4               okl_k_headers_full_v.attribute4%TYPE:= OKL_API.G_MISS_CHAR,
   p_attribute5               okl_k_headers_full_v.attribute5%TYPE:= OKL_API.G_MISS_CHAR,
   p_attribute6               okl_k_headers_full_v.attribute6%TYPE:= OKL_API.G_MISS_CHAR,
   p_attribute7               okl_k_headers_full_v.attribute7%TYPE:= OKL_API.G_MISS_CHAR,
   p_attribute8               okl_k_headers_full_v.attribute8%TYPE:= OKL_API.G_MISS_CHAR,
   p_attribute9               okl_k_headers_full_v.attribute9%TYPE:= OKL_API.G_MISS_CHAR,
   p_attribute10              okl_k_headers_full_v.attribute10%TYPE:= OKL_API.G_MISS_CHAR,
   p_attribute11              okl_k_headers_full_v.attribute11%TYPE:= OKL_API.G_MISS_CHAR,
   p_attribute12              okl_k_headers_full_v.attribute12%TYPE:= OKL_API.G_MISS_CHAR,
   p_attribute13              okl_k_headers_full_v.attribute13%TYPE:= OKL_API.G_MISS_CHAR,
   p_attribute14              okl_k_headers_full_v.attribute14%TYPE:= OKL_API.G_MISS_CHAR,
   p_attribute15              okl_k_headers_full_v.attribute15%TYPE:= OKL_API.G_MISS_CHAR,
   /* sosharma 31-Oct-2006
   Build:R12
   p_legal_entity_id added to the record structure
   */
   p_legal_entity_id          okl_k_headers_full_v.legal_entity_id%TYPE:= OKL_API.G_MISS_NUM
   );


G_PKG_NAME CONSTANT VARCHAR2(200)     := 'OKL_VENDOR_PROGRAM_PVT ';
G_APP_NAME CONSTANT VARCHAR2(3)       :=  OKL_API.G_APP_NAME;


G_REQUIRED_VALUE                 CONSTANT VARCHAR2(200) := OKL_API.G_REQUIRED_VALUE;
G_INVALID_VALUE                  CONSTANT VARCHAR2(200) := OKL_API.G_INVALID_VALUE;
G_SQLERRM_TOKEN                  CONSTANT VARCHAR2(200) := 'OKL_SQLERRM';
G_SQLCODE_TOKEN                  CONSTANT VARCHAR2(200) := 'OKL_SQLCODE';
G_UNEXPECTED_ERROR               CONSTANT VARCHAR2(200) := 'OKL_CONTRACTS_UNEXPECTED_ERROR';
G_UPPERCASE_REQUIRED             CONSTANT VARCHAR2(200) := 'OKL_UPPER_CASE_REQUIRED';
G_COL_NAME_TOKEN                 CONSTANT VARCHAR2(200) := OKL_API.G_COL_NAME_TOKEN;
G_START_DATE                     CONSTANT VARCHAR2(200) := 'OKL_START_DATE';
G_END_DATE                       CONSTANT VARCHAR2(200) := 'OKL_END_DATE';


PROCEDURE create_program(p_api_version          IN               NUMBER,
                      p_init_msg_list           IN               VARCHAR2 DEFAULT OKL_API.G_FALSE,
                      x_return_status           OUT              NOCOPY VARCHAR2,
                      x_msg_count               OUT              NOCOPY NUMBER,
                      x_msg_data                OUT              NOCOPY VARCHAR2,
                      p_hdr_rec                 IN               program_header_rec_type,
                      p_parent_agreement_number IN               okl_k_headers_full_v.contract_number%TYPE DEFAULT NULL,
                      x_header_rec              OUT NOCOPY              chrv_rec_type,
                      x_k_header_rec            OUT NOCOPY              khrv_rec_type);


PROCEDURE update_program(p_api_version             IN               NUMBER,
                         p_init_msg_list           IN               VARCHAR2 DEFAULT OKL_API.G_FALSE,
                         x_return_status           OUT              NOCOPY VARCHAR2,
                         x_msg_count               OUT              NOCOPY NUMBER,
                         x_msg_data                OUT              NOCOPY VARCHAR2,
                         p_hdr_rec                 IN               program_header_rec_type,
                         p_program_id              IN               okl_k_headers_full_v.id%TYPE,
                         p_parent_agreement_id     IN               okc_k_headers_v.ID%TYPE DEFAULT NULL);


FUNCTION Is_Process_Active(p_chr_id IN okl_k_headers_full_v.id%TYPE) RETURN VARCHAR2;


PROCEDURE passed_to_incomplete(p_api_version             IN               NUMBER,
                               p_init_msg_list           IN               VARCHAR2 DEFAULT OKL_API.G_FALSE,
                               x_return_status           OUT              NOCOPY VARCHAR2,
                               x_msg_count               OUT              NOCOPY NUMBER,
                               x_msg_data                OUT              NOCOPY VARCHAR2,
                               p_program_id              IN               OKC_K_HEADERS_V.ID%TYPE);


END OKL_VENDOR_PROGRAM_PVT;

/
