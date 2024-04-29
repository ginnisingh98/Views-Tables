--------------------------------------------------------
--  DDL for Package OKL_FUNDING_CHECKLIST_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OKL_FUNDING_CHECKLIST_PVT" AUTHID CURRENT_USER AS
/* $Header: OKLRCLFS.pls 120.1 2005/05/27 17:26:05 cklee noship $ */
 ----------------------------------------------------------------------------
 -- GLOBAL VARIABLES
 ----------------------------------------------------------------------------
 G_PKG_NAME             CONSTANT VARCHAR2(200) := 'OKL_FUNDING_CHECKLIST_PVT';
 G_APP_NAME             CONSTANT VARCHAR2(3)   :=  OKL_API.G_APP_NAME;

 G_RET_STS_SUCCESS		 CONSTANT VARCHAR2(1) 	:= OKL_API.G_RET_STS_SUCCESS;
 G_RET_STS_UNEXP_ERROR		 CONSTANT VARCHAR2(1) 	:= OKL_API.G_RET_STS_UNEXP_ERROR;
 G_RET_STS_ERROR		 CONSTANT VARCHAR2(1) 	:= OKL_API.G_RET_STS_ERROR;
 G_EXCEPTION_ERROR		 EXCEPTION;
 G_EXCEPTION_UNEXPECTED_ERROR	 EXCEPTION;

 G_UNEXPECTED_ERROR           CONSTANT VARCHAR2(30) := 'OKL_UNEXPECTED_ERROR';
 G_SQLERRM_TOKEN              CONSTANT VARCHAR2(30) := 'OKL_SQLERRM';
 G_SQLCODE_TOKEN              CONSTANT VARCHAR2(30) := 'OKL_SQLCODE';

 G_EXC_NAME_OTHERS	        CONSTANT VARCHAR2(6) := 'OTHERS';
 G_API_TYPE	CONSTANT VARCHAR(4) := '_PVT';
 G_UI_DATE_MASK      VARCHAR2(15) := fnd_profile.value('ICX_DATE_FORMAT_MASK');
 G_OKL_LLA_INVALID_DATE_FORMAT CONSTANT VARCHAR2(30) := 'OKL_LLA_INVALID_DATE_FORMAT';
 G_NOT_UNIQUE                 CONSTANT VARCHAR2(30) := 'OKL_LLA_NOT_UNIQUE';
 G_REQUIRED_VALUE             CONSTANT VARCHAR2(30) := 'OKL_REQUIRED_VALUE';
 G_LLA_RANGE_CHECK            CONSTANT VARCHAR2(30) := 'OKL_LLA_RANGE_CHECK';
 G_INVALID_VALUE              CONSTANT VARCHAR2(30) := OKL_API.G_INVALID_VALUE;
 G_COL_NAME_TOKEN             CONSTANT VARCHAR2(30) := OKL_API.G_COL_NAME_TOKEN;

 ----------------------------------------------------------------------------
 -- Data Structures
 ----------------------------------------------------------------------------

  TYPE rulv_rec_type IS RECORD (
    id                             NUMBER := OKC_API.G_MISS_NUM,
--    object_version_number          NUMBER := OKC_API.G_MISS_NUM,
--    sfwt_flag                      OKC_RULES_V.SFWT_FLAG%TYPE := OKC_API.G_MISS_CHAR,
    object1_id1                    OKC_RULES_V.OBJECT1_ID1%TYPE := OKC_API.G_MISS_CHAR,
--    object2_id1                    OKC_RULES_V.OBJECT2_ID1%TYPE := OKC_API.G_MISS_CHAR,
--    object3_id1                    OKC_RULES_V.OBJECT3_ID1%TYPE := OKC_API.G_MISS_CHAR,
    object1_id2                    OKC_RULES_V.OBJECT1_ID2%TYPE := OKC_API.G_MISS_CHAR,
--    object2_id2                    OKC_RULES_V.OBJECT2_ID2%TYPE := OKC_API.G_MISS_CHAR,
--    object3_id2                    OKC_RULES_V.OBJECT3_ID2%TYPE := OKC_API.G_MISS_CHAR,
--    jtot_object1_code              OKC_RULES_V.JTOT_OBJECT1_CODE%TYPE := OKC_API.G_MISS_CHAR,
--    jtot_object2_code              OKC_RULES_V.JTOT_OBJECT2_CODE%TYPE := OKC_API.G_MISS_CHAR,
--    jtot_object3_code              OKC_RULES_V.JTOT_OBJECT3_CODE%TYPE := OKC_API.G_MISS_CHAR,
    dnz_chr_id                     NUMBER := OKC_API.G_MISS_NUM,
    rgp_id                         NUMBER := OKC_API.G_MISS_NUM,
--    priority                       NUMBER := OKC_API.G_MISS_NUM,
--    std_template_yn                OKC_RULES_V.STD_TEMPLATE_YN%TYPE := OKC_API.G_MISS_CHAR,
--    comments                       OKC_RULES_V.COMMENTS%TYPE := OKC_API.G_MISS_CHAR,
--    warn_yn                        OKC_RULES_V.WARN_YN%TYPE := OKC_API.G_MISS_CHAR,
--    attribute_category             OKC_RULES_V.ATTRIBUTE_CATEGORY%TYPE := OKC_API.G_MISS_CHAR,
--    attribute1                     OKC_RULES_V.ATTRIBUTE1%TYPE := OKC_API.G_MISS_CHAR,
--    attribute2                     OKC_RULES_V.ATTRIBUTE2%TYPE := OKC_API.G_MISS_CHAR,
--    attribute3                     OKC_RULES_V.ATTRIBUTE3%TYPE := OKC_API.G_MISS_CHAR,
--    attribute4                     OKC_RULES_V.ATTRIBUTE4%TYPE := OKC_API.G_MISS_CHAR,
--    attribute5                     OKC_RULES_V.ATTRIBUTE5%TYPE := OKC_API.G_MISS_CHAR,
--    attribute6                     OKC_RULES_V.ATTRIBUTE6%TYPE := OKC_API.G_MISS_CHAR,
--    attribute7                     OKC_RULES_V.ATTRIBUTE7%TYPE := OKC_API.G_MISS_CHAR,
--    attribute8                     OKC_RULES_V.ATTRIBUTE8%TYPE := OKC_API.G_MISS_CHAR,
--    attribute9                     OKC_RULES_V.ATTRIBUTE9%TYPE := OKC_API.G_MISS_CHAR,
--    attribute10                    OKC_RULES_V.ATTRIBUTE10%TYPE := OKC_API.G_MISS_CHAR,
--    attribute11                    OKC_RULES_V.ATTRIBUTE11%TYPE := OKC_API.G_MISS_CHAR,
--    attribute12                    OKC_RULES_V.ATTRIBUTE12%TYPE := OKC_API.G_MISS_CHAR,
--    attribute13                    OKC_RULES_V.ATTRIBUTE13%TYPE := OKC_API.G_MISS_CHAR,
--    attribute14                    OKC_RULES_V.ATTRIBUTE14%TYPE := OKC_API.G_MISS_CHAR,
--    attribute15                    OKC_RULES_V.ATTRIBUTE15%TYPE := OKC_API.G_MISS_CHAR,
--    created_by                     NUMBER := OKC_API.G_MISS_NUM,
--    creation_date                  OKC_RULES_V.CREATION_DATE%TYPE := OKC_API.G_MISS_DATE,
--    last_updated_by                NUMBER := OKC_API.G_MISS_NUM,
--    last_update_date               OKC_RULES_V.LAST_UPDATE_DATE%TYPE := OKC_API.G_MISS_DATE,
--    last_update_login              NUMBER := OKC_API.G_MISS_NUM,
    --text                           OKC_RULES_V.TEXT%TYPE := NULL,
    rule_information_category      OKC_RULES_V.RULE_INFORMATION_CATEGORY%TYPE := OKC_API.G_MISS_CHAR,
    rule_information1              OKC_RULES_V.RULE_INFORMATION1%TYPE := OKC_API.G_MISS_CHAR,
    rule_information2              OKC_RULES_V.RULE_INFORMATION2%TYPE := OKC_API.G_MISS_CHAR,
    rule_information3              OKC_RULES_V.RULE_INFORMATION3%TYPE := OKC_API.G_MISS_CHAR,
    rule_information4              OKC_RULES_V.RULE_INFORMATION4%TYPE := OKC_API.G_MISS_CHAR,
    rule_information5              OKC_RULES_V.RULE_INFORMATION5%TYPE := OKC_API.G_MISS_CHAR,
    rule_information6              OKC_RULES_V.RULE_INFORMATION6%TYPE := OKC_API.G_MISS_CHAR,
    rule_information7              OKC_RULES_V.RULE_INFORMATION7%TYPE := OKC_API.G_MISS_CHAR,
    rule_information8              OKC_RULES_V.RULE_INFORMATION8%TYPE := OKC_API.G_MISS_CHAR,
    rule_information9              OKC_RULES_V.RULE_INFORMATION9%TYPE := OKC_API.G_MISS_CHAR,
    rule_information10             OKC_RULES_V.RULE_INFORMATION10%TYPE := OKC_API.G_MISS_CHAR,
    rule_information11             OKC_RULES_V.RULE_INFORMATION11%TYPE := OKC_API.G_MISS_CHAR,
    rule_information12             OKC_RULES_V.RULE_INFORMATION12%TYPE := OKC_API.G_MISS_CHAR,
    rule_information13             OKC_RULES_V.RULE_INFORMATION13%TYPE := OKC_API.G_MISS_CHAR,
    rule_information14             OKC_RULES_V.RULE_INFORMATION14%TYPE := OKC_API.G_MISS_CHAR,
    rule_information15             OKC_RULES_V.RULE_INFORMATION15%TYPE := OKC_API.G_MISS_CHAR,
--    template_yn                    OKC_RULES_B.TEMPLATE_YN%TYPE := OKC_API.G_MISS_CHAR,
--    ans_set_jtot_object_code       OKC_RULES_B.ans_set_jtot_object_code%TYPE := OKC_API.G_MISS_CHAR,
--    ans_set_jtot_object_id1            OKC_RULES_B.ans_set_jtot_object_id1%TYPE := OKC_API.G_MISS_CHAR,
--    ans_set_jtot_object_id2            OKC_RULES_B.ans_set_jtot_object_id2%TYPE := OKC_API.G_MISS_CHAR,
    display_sequence               NUMBER:= OKC_API.G_MISS_NUM
);

  g_miss_rulv_rec                rulv_rec_type;

  TYPE rulv_tbl_type IS TABLE OF rulv_rec_type INDEX BY BINARY_INTEGER;
 ----------------------------------------------------------------------------
 -- Global Exception
 ----------------------------------------------------------------------------
 G_EXCEPTION_HALT_VALIDATION	EXCEPTION;

 ----------------------------------------------------------------------------
 -- Procedures and Functions
 ------------------------------------------------------------------------------
----------------------------------------------------------------------------------
-- Start of comments
--
-- Procedure Name  : create_funding_chklst
-- Description     : wrapper api for create funding checklists associated
--                   with credit line contract ID
-- Business Rules  :
-- Parameters      :
-- Version         : 1.0
-- End of comments
----------------------------------------------------------------------------------
 PROCEDURE create_funding_chklst(
    p_api_version                  IN NUMBER
   ,p_init_msg_list                IN VARCHAR2 DEFAULT OKL_API.G_FALSE
   ,x_return_status                OUT NOCOPY VARCHAR2
   ,x_msg_count                    OUT NOCOPY NUMBER
   ,x_msg_data                     OUT NOCOPY VARCHAR2
   ,p_rulv_tbl                     IN  rulv_tbl_type
   ,x_rulv_tbl                     OUT NOCOPY rulv_tbl_type
 );

----------------------------------------------------------------------------------
-- Start of comments
--
-- Procedure Name  : update_funding_chklst
-- Description     : wrapper api for update funding checklists associated
--                   with credit line contract ID
-- Business Rules  :
-- Parameters      :
-- Version         : 1.0
-- End of comments
----------------------------------------------------------------------------------
 PROCEDURE update_funding_chklst(
    p_api_version                  IN NUMBER
   ,p_init_msg_list                IN VARCHAR2 DEFAULT OKL_API.G_FALSE
   ,x_return_status                OUT NOCOPY VARCHAR2
   ,x_msg_count                    OUT NOCOPY NUMBER
   ,x_msg_data                     OUT NOCOPY VARCHAR2
   ,p_rulv_tbl                     IN  rulv_tbl_type
   ,x_rulv_tbl                     OUT NOCOPY rulv_tbl_type
 );

----------------------------------------------------------------------------------
-- Start of comments
--
-- Procedure Name  : delete_funding_chklst
-- Description     : wrapper api for delete funding checklists associated
--                   with credit line contract ID
-- Business Rules  :
-- Parameters      :
-- Version         : 1.0
-- End of comments
----------------------------------------------------------------------------------
 PROCEDURE delete_funding_chklst(
    p_api_version                  IN NUMBER
   ,p_init_msg_list                IN VARCHAR2 DEFAULT OKL_API.G_FALSE
   ,x_return_status                OUT NOCOPY VARCHAR2
   ,x_msg_count                    OUT NOCOPY NUMBER
   ,x_msg_data                     OUT NOCOPY VARCHAR2
   ,p_rulv_tbl                     IN  rulv_tbl_type
 );

----------------------------------------------------------------------------------
-- Start of comments
--
-- Procedure Name  : approve_funding_request
-- Description     : wrapper api for update_funding_header with status = 'APPROVE'
-- Business Rules  :
-- Parameters      :
-- Version         : 1.0
-- End of comments
----------------------------------------------------------------------------------
 PROCEDURE approve_funding_request(
    p_api_version                  IN NUMBER
   ,p_init_msg_list                IN VARCHAR2 DEFAULT OKL_API.G_FALSE
   ,x_return_status                OUT NOCOPY VARCHAR2
   ,x_msg_count                    OUT NOCOPY NUMBER
   ,x_msg_data                     OUT NOCOPY VARCHAR2
   ,p_fund_req_id                  IN  okl_trx_ap_invoices_b.id%TYPE
 );

----------------------------------------------------------------------------------
-- Start of comments
--
-- Procedure Name  : approve_funding_chklst
-- Description     : set funding checklists status to "Active"
-- Business Rules  :
-- Parameters      :
-- Version         : 1.0
-- End of comments
----------------------------------------------------------------------------------
 PROCEDURE approve_funding_chklst(
    p_api_version                  IN NUMBER
   ,p_init_msg_list                IN VARCHAR2 DEFAULT OKL_API.G_FALSE
   ,x_return_status                OUT NOCOPY VARCHAR2
   ,x_msg_count                    OUT NOCOPY NUMBER
   ,x_msg_data                     OUT NOCOPY VARCHAR2
   ,p_rulv_rec                     IN  rulv_rec_type
 );

END OKL_FUNDING_CHECKLIST_PVT;

 

/
