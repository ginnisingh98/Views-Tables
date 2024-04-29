--------------------------------------------------------
--  DDL for Package OKS_BILLING_PROFILES_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OKS_BILLING_PROFILES_PUB" AUTHID CURRENT_USER AS
/* $Header: OKSPBPES.pls 120.1.12010000.2 2008/12/22 04:47:07 cgopinee ship $ */


  SUBTYPE bpev_rec_type IS oks_bpe_pvt.bpev_rec_type;
  SUBTYPE bpev_tbl_type IS oks_bpe_pvt.bpev_tbl_type;
  SUBTYPE bpe_rec_type IS oks_bpe_pvt.bpe_rec_type;
  SUBTYPE bpe_tbl_type IS oks_bpe_pvt.bpe_tbl_type;

  ---------------------------------------------------------------------------
  -- GLOBAL_MESSAGE_CONSTANTS
  ---------------------------------------------------------------------------
  G_FND_APP	               	 CONSTANT VARCHAR2(200) :=  OKC_API.G_FND_APP;
  G_FORM_UNABLE_TO_RESERVE_REC CONSTANT VARCHAR2(200) :=  OKC_API.G_FORM_UNABLE_TO_RESERVE_REC;
  G_FORM_RECORD_DELETED        CONSTANT VARCHAR2(200) :=  OKC_API.G_FORM_RECORD_DELETED;
  G_FORM_RECORD_CHANGED        CONSTANT VARCHAR2(200) :=  OKC_API.G_FORM_RECORD_CHANGED;
  G_RECORD_LOGICALLY_DELETED   CONSTANT VARCHAR2(200) :=  OKC_API.G_RECORD_LOGICALLY_DELETED;
  G_REQUIRED_VALUE             CONSTANT VARCHAR2(200) :=  OKC_API.G_REQUIRED_VALUE;
  G_INVALID_VALUE              CONSTANT VARCHAR2(200) :=  OKC_API.G_INVALID_VALUE;
  G_COL_NAME_TOKEN             CONSTANT VARCHAR2(200) :=  OKC_API.G_COL_NAME_TOKEN;
  G_PARENT_TABLE_TOKEN         CONSTANT VARCHAR2(200) :=  OKC_API.G_PARENT_TABLE_TOKEN;
  G_CHILD_TABLE_TOKEN          CONSTANT VARCHAR2(200) :=  OKC_API.G_CHILD_TABLE_TOKEN;
  G_UNEXPECTED_ERROR           CONSTANT VARCHAR2(200) := 'OKC_CONTRACTS_UNEXPECTED_ERROR';
  G_SQLERRM_TOKEN              CONSTANT VARCHAR2(200) := 'SQLerrm';
  G_SQLCODE_TOKEN              CONSTANT VARCHAR2(200) := 'SQLcode';
  G_UPPERCASE_REQUIRED         CONSTANT VARCHAR2(200) := 'OKC_CONTRACTS_UPPERCASE_REQUIRED';
  G_MODULE_CURRENT             CONSTANT VARCHAR2(255) := 'oks.plsql.OKS_BILLING_PROFILES_PUB';

  G_APP_NAME_OKC	       CONSTANT VARCHAR2(3)   :=  'OKC';
  G_RET_STS_UNEXP_ERROR        CONSTANT VARCHAR2(1)   :=  OKC_API.G_RET_STS_UNEXP_ERROR;
  ---------------------------------------------------------------------------

  -- GLOBAL EXCEPTION
  ---------------------------------------------------------------------------
  G_EXCEPTION_HALT_VALIDATION EXCEPTION;
  ---------------------------------------------------------------------------

  -- GLOBAL VARIABLES
  ---------------------------------------------------------------------------
  G_PKG_NAME	               CONSTANT VARCHAR2(200) := 'OKS_BILLING_PROFILE_PUB';
  G_APP_NAME	               CONSTANT VARCHAR2(3)   :=  OKC_API.G_APP_NAME;

  g_bpev_rec                   bpev_rec_type;
  ---------------------------------------------------------------------------
  -- Procedures and Functions
  ---------------------------------------------------------------------------

    PROCEDURE add_language;
    PROCEDURE insert_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_bpev_rec                     IN bpev_rec_type,
    x_bpev_rec                     OUT NOCOPY bpev_rec_type);

  PROCEDURE insert_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_bpev_tbl                     IN bpev_tbl_type,
    x_bpev_tbl                     OUT NOCOPY bpev_tbl_type);

  PROCEDURE lock_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_bpev_rec                     IN bpev_rec_type);

  PROCEDURE lock_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_bpev_tbl                     IN bpev_tbl_type);

  PROCEDURE update_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_bpev_rec                     IN bpev_rec_type,
    x_bpev_rec                     OUT NOCOPY bpev_rec_type);

  PROCEDURE update_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_bpev_tbl                     IN bpev_tbl_type,
    x_bpev_tbl                     OUT NOCOPY bpev_tbl_type);

  PROCEDURE delete_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_bpev_rec                     IN bpev_rec_type);

  PROCEDURE delete_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_bpev_tbl                     IN bpev_tbl_type);

  PROCEDURE validate_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_bpev_rec                     IN bpev_rec_type);

  PROCEDURE validate_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_bpev_tbl                     IN bpev_tbl_type);



  TYPE Billing_profile_rec Is Record(
     cle_Id                          NUMBER,
     chr_Id                          NUMBER,
     Billing_Profile_Id              NUMBER,
     Start_Date                      DATE,
     End_Date                        DATE);

  TYPE Stream_Level_rec Is Record(
--slh
     Chr_Id                          NUMBER,
     Cle_Id                          NUMBER,
     Billing_type                    VARCHAR2 (450), --Rule_Information1
     Rule_Information_Category       VARCHAR2 (90),  --Rule_Information_Category
     stream_type_id1                 VARCHAR2 (40),  --Object1_Id1
     stream_type_id2                 VARCHAR2 (200), --Object1_Id2
     slh_timeval_id1                 VARCHAR2 (40),  --Object2_Id1
     slh_timeval_id2                 VARCHAR2 (200), --Object2_Id2
     stream_tp_code                  VARCHAR2 (30),  --Jtot_Object1_Code
     slh_timeval_code                VARCHAR2 (30),   --Jtot_Object2_Code
--sll
     seq_no                          VARCHAR2 (450), -- RULE_INFORMATION1
     Start_Date                      VARCHAR2 (450), -- RULE_INFORMATION2
     amount                          VARCHAR2 (450), -- RULE_INFORMATION6
     sll_Rule_Information_Category   VARCHAR2 (90),
     sll_Object1_Id1                 VARCHAR2 (40),
     sll_Object1_Id2                 VARCHAR2 (200),
     sll_Jtot_Object1_Code           VARCHAR2 (30),
     target_quantity                 VARCHAR2 (450),    --rule_information3
     duration                        VARCHAR2 (450),    --rule_information4, UOM/PERIOD
     Interface_Offset                VARCHAR2 (450),    --rule_information7
     Invoice_Offset                  VARCHAR2 (450),    --rule_information8
     timeunit                        VARCHAR2 (40),      --Object1_Id1, UOM
     Invoice_Rule_Id                 NUMBER,  --INVOICE_OBJECT1_ID1 of oks_billing_profiles_v
--sum 01,jul
     Account_Rule_Id                 NUMBER  --ACCOUNT_OBJECT1_ID1 of oks_billing_profiles_v
--sum 01,jul


     );



  Type Stream_Level_tbl is TABLE OF Stream_Level_rec INDEX BY binary_integer;

  PROCEDURE Get_Billing_Schedule(
    p_api_version                   IN NUMBER,
    p_init_msg_list                 IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    p_billing_profile_rec           IN  Billing_profile_rec,
    x_sll_tbl_out                   OUT NOCOPY Stream_Level_tbl,
    x_return_status                 OUT NOCOPY VARCHAR2,
    x_msg_count                     OUT NOCOPY NUMBER,
    x_msg_data                      OUT NOCOPY VARCHAR2 );


END OKS_BILLING_PROFILES_PUB;

/
