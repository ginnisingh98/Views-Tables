--------------------------------------------------------
--  DDL for Package OKL_INS_QUOTE_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OKL_INS_QUOTE_PVT" AUTHID CURRENT_USER AS
/* $Header: OKLRINQS.pls 120.9 2005/11/24 10:28:53 gboomina noship $ */
    ---------------------------------------------------------------------------
  -- GLOBAL DATASTRUCTURES
  ---------------------------------------------------------------------------

 SUBTYPE ipyv_rec_type IS Okl_Ipy_Pvt.ipyv_rec_type;
 TYPE ipyv_tbl_type IS TABLE OF ipyv_rec_type INDEX BY BINARY_INTEGER;
 SUBTYPE inav_rec_type IS Okl_Ina_Pvt.inav_rec_type;
 TYPE inav_tbl_type IS TABLE OF inav_rec_type INDEX BY BINARY_INTEGER;


	TYPE iasset_rec_type IS RECORD (
    KLE_ID              NUMBER := OKC_API.G_MISS_NUM,
    premium               NUMBER := OKC_API.G_MISS_NUM,
    LESSOR_PREMIUM       NUMBER := OKC_API.G_MISS_NUM
	);
 TYPE iasset_tbl_type IS TABLE OF iasset_rec_type INDEX BY BINARY_INTEGER;

  TYPE policy_rec_type IS RECORD
  (
    POLICY_NUMBER       OKL_INS_POLICIES_V.POLICY_NUMBER%TYPE := OKC_API.G_MISS_CHAR,
    CONTRACT_NUMBER     OKC_K_HEADERS_V.CONTRACT_NUMBER%TYPE := OKC_API.G_MISS_CHAR
  );

  TYPE policy_tbl_type IS TABLE OF policy_rec_type INDEX BY BINARY_INTEGER;

   TYPE payment_rec_type IS RECORD(
  AMOUNT    NUMBER := OKC_API.G_MISS_NUM,
  DUE_DATE    DATE := OKC_API.G_MISS_DATE
   );
 TYPE payment_tbl_type IS TABLE OF payment_rec_type INDEX BY BINARY_INTEGER;


  TYPE insexp_rec_type IS RECORD(
  AMOUNT    NUMBER := OKC_API.G_MISS_NUM,
  PERIOD    NUMBER := OKC_API.G_MISS_NUM
   );
 TYPE insexp_tbl_type IS TABLE OF insexp_rec_type INDEX BY BINARY_INTEGER;

  ---------------------------------------------------------------------------
  -- GLOBAL MESSAGE CONSTANTS
  ---------------------------------------------------------------------------
  G_FND_APP			CONSTANT VARCHAR2(200) := Okc_Api.G_FND_APP;
  G_REQUIRED_VALUE		CONSTANT VARCHAR2(200) := 'OKL_REQUIRED_VALUE';
  G_INVALID_VALUE		CONSTANT VARCHAR2(200) := Okc_Api.G_INVALID_VALUE;
  G_COL_NAME_TOKEN		CONSTANT VARCHAR2(200) := 'COL_NAME';
  G_COL_VALUE_TOKEN		CONSTANT VARCHAR2(200) := 'COL_VALUE';
  G_COL_NAME1_TOKEN		CONSTANT VARCHAR2(200) := 'COL_NAME1';
  G_COL_NAME2_TOKEN		CONSTANT VARCHAR2(200) := 'COL_NAME2';
  G_PARENT_TABLE_TOKEN		CONSTANT VARCHAR2(200) := 'PARENT_TABLE';
  G_CHILD_TABLE_TOKEN		CONSTANT VARCHAR2(200) := 'CHILD_TABLE'; --3745151 Fix for invalid error message
  G_UNEXPECTED_ERROR		CONSTANT VARCHAR2(200) := 'OKL_CONTRACTS_UNEXPECTED_ERROR';
  G_NO_PARENT_RECORD            CONSTANT VARCHAR2(200) := 'OKL_NO_PARENT_RECORD';
  G_SQLERRM_TOKEN               CONSTANT VARCHAR2(200) := 'OKL_SQLERRM';
  G_SQLCODE_TOKEN               CONSTANT VARCHAR2(200) := 'OKL_SQLCODE';
  G_INVALID_QUOTE               CONSTANT VARCHAR2(200) := 'OKL_QUOTE_INVALID';
  G_INVALID_QUOTE_TYPE         CONSTANT VARCHAR2(200) := 'OKL_QUOTE_TYPE_INVALID';
  G_EXPIRED_QUOTE              CONSTANT VARCHAR2(200) := 'OKL_QUOTE_EXPIRED';
  G_NO_STREAM_REC_FOUND        CONSTANT VARCHAR2(200) := 'OKL_NO_STREAM_REC_FOUND';
  G_INVALID_CONTRACT           CONSTANT VARCHAR2(200) := 'OKL_INVALID_CONTRACT';
  G_K_NOT_ACTIVE               CONSTANT VARCHAR2(200) := 'OKL_K_NOT_ACTIVE';
  G_INVALID_FOR_ACTIVE_TYPE     CONSTANT VARCHAR2(200) := 'OKL_INVALID_FOR_ACTIVE_TYPE';
  G_INVALID_FOR_ACTIVE_STATUS     CONSTANT VARCHAR2(200) := 'OKL_INVALID_FOR_ACTIVE_STATUS';
  G_STREAM_ALREADY_ACTIVE      CONSTANT VARCHAR2(200) := 'OKL_STREAM_ALREADY_ACTIVE';
  G_INVALID_CONTRACT_LINE     CONSTANT VARCHAR2(200) := 'OKL_INVALID_CONTRACT_LINE';
  G_FND_LOOKUP_PAYMENT_FREQ   CONSTANT VARCHAR2(200) := 'OKL_INS_PAYMENT_FREQUENCY';
  G_NO_CAPITAL_AMOUNT         CONSTANT VARCHAR2(200) := 'OKL_NO_CAPITAL_AMOUNT';
  G_NO_SYSTEM_PROFILE         CONSTANT VARCHAR2(200) := 'OKL_NO_SYSTEM_PROFILE';
  G_SYS_PROFILE_NAME          CONSTANT VARCHAR2(200) := 'OKL_SYS_PROFILE_NAME';
  G_NO_INSURANCE              CONSTANT VARCHAR2(200) := 'OKL_NO_INSURANCE';
  G_NO_K_TERM                  CONSTANT VARCHAR2(200) := 'OKL_NO_K_TERM';
  G_NO_K_OEC                 CONSTANT VARCHAR2(200) := 'OKL_NO_K_OEC';
  G_NO_OEC                   CONSTANT VARCHAR2(200) := 'OKL_NO_OEC';
  G_NO_KLE                   CONSTANT VARCHAR2(200) := 'OKL_NO_KLE';
  G_NO_INS_CLASS             CONSTANT VARCHAR2(200) := 'OKL_NO_INS_CLASS';
  G_NOT_ACTIVE               CONSTANT VARCHAR2(1) := 'A' ;
  G_INVALID_INSURANCE_TERM   CONSTANT VARCHAR2(200) := 'OKL_INVALID_INSURANCE_TERM';
  G_NO_STREAM                CONSTANT VARCHAR2(200) := 'OKL_NO_STREAM_TYPE';
  G_PURPOSE_TOKEN            CONSTANT VARCHAR2(200) := 'PURPOSE'; --bug 4024785
  --gboomina Bug 4744724 - Added - Start
  G_INVALID_QUOTE_TERM   CONSTANT VARCHAR2(200) := 'OKL_INVALID_QUOTE_TERM';
  --gboomina Bug 4744724 - Added - End
  ---------------------------------------------------------------------------
  -- GLOBAL VARIABLES
  ---------------------------------------------------------------------------
  G_PKG_NAME			CONSTANT VARCHAR2(200) := 'Okl_Ins_Quote_Pvt';
  G_APP_NAME			CONSTANT VARCHAR2(3)   :=  'OKL';
  G_NOT_ABLE CONSTANT VARCHAR2(1)   := 'N' ;
  G_NO_INS CONSTANT VARCHAR2(1)   := 'I' ;
   ---------------------------------------------------------------------------
  -- GLOBAL EXCEPTION
  ---------------------------------------------------------------------------
  G_EXCEPTION_HALT_VALIDATION	EXCEPTION;
  ---------------------------------------------------------------------------
  -- Procedures and Functions


  PROCEDURE save_quote(
     p_api_version                  IN NUMBER,
     p_init_msg_list                IN VARCHAR2 DEFAULT Okc_Api.G_FALSE,
     x_return_status                OUT NOCOPY VARCHAR2,
     x_msg_count                    OUT NOCOPY NUMBER,
     x_msg_data                     OUT NOCOPY VARCHAR2,
     px_ipyv_rec                     IN OUT NOCOPY ipyv_rec_type,
	 x_message                      OUT NOCOPY  VARCHAR2  );
-- Need to have second procedure
-- so that we don't need TO recalculate
  PROCEDURE save_accept_quote(
     p_api_version                  IN NUMBER,
     p_init_msg_list                IN VARCHAR2 DEFAULT Okc_Api.G_FALSE,
     x_return_status                OUT NOCOPY VARCHAR2,
     x_msg_count                    OUT NOCOPY NUMBER,
     x_msg_data                     OUT NOCOPY VARCHAR2,
     p_ipyv_rec                     IN  ipyv_rec_type,
	 x_message                      OUT NOCOPY  VARCHAR2  );

-- Need to have second procedure
-- so that we don't need to recalculate
  PROCEDURE accept_quote(
     p_api_version                  IN NUMBER,
     p_init_msg_list                IN VARCHAR2 DEFAULT Okc_Api.G_FALSE,
     x_return_status                OUT NOCOPY VARCHAR2,
     x_msg_count                    OUT NOCOPY NUMBER,
     x_msg_data                     OUT NOCOPY VARCHAR2,
     p_quote_id                     IN NUMBER );


PROCEDURE   create_ins_streams(
         p_api_version                   IN NUMBER,
     p_init_msg_list                IN VARCHAR2 DEFAULT Okc_Api.G_FALSE,
     x_return_status                OUT NOCOPY VARCHAR2,
     x_msg_count                    OUT NOCOPY NUMBER,
     x_msg_data                     OUT NOCOPY VARCHAR2,
     p_ipyv_rec                     IN ipyv_rec_type
         );


	      PROCEDURE   calc_lease_premium(
         p_api_version                   IN NUMBER,
		 p_init_msg_list                IN VARCHAR2 DEFAULT Okc_Api.G_FALSE,
         x_return_status                OUT NOCOPY VARCHAR2,
         x_msg_count                    OUT NOCOPY NUMBER,
         x_msg_data                     OUT NOCOPY VARCHAR2,
         px_ipyv_rec                     IN OUT NOCOPY ipyv_rec_type,
	     x_message                      OUT NOCOPY VARCHAR2,
         x_iasset_tbl                  OUT NOCOPY  iasset_tbl_type
     );

     	      PROCEDURE   calc_optional_premium(
         p_api_version                   IN NUMBER,
		 p_init_msg_list                IN VARCHAR2 DEFAULT Okc_Api.G_FALSE,
         x_return_status                OUT NOCOPY VARCHAR2,
         x_msg_count                    OUT NOCOPY NUMBER,
         x_msg_data                     OUT NOCOPY VARCHAR2,
         p_ipyv_rec                     IN  ipyv_rec_type,
	     x_message                      OUT NOCOPY VARCHAR2,
         x_ipyv_rec                  OUT NOCOPY  ipyv_rec_type
     );
  -- bug:3967640
    PROCEDURE calc_total_premium(p_api_version                  IN NUMBER,
                             p_init_msg_list                IN VARCHAR2 ,
                             x_return_status                OUT NOCOPY VARCHAR2,
                             x_msg_count                    OUT NOCOPY NUMBER,
                             x_msg_data                     OUT NOCOPY VARCHAR2,
                             p_pol_qte_id                   IN  VARCHAR2,
                             x_total_premium                OUT NOCOPY NUMBER);

	 PROCEDURE  activate_ins_stream(
     p_api_version                   IN NUMBER,
     p_init_msg_list                IN VARCHAR2 DEFAULT Okc_Api.G_FALSE,
     x_return_status                OUT NOCOPY  VARCHAR2,
     x_msg_count                    OUT NOCOPY NUMBER,
     x_msg_data                     OUT NOCOPY VARCHAR2,
     p_ipyv_rec                     IN ipyv_rec_type
         );

   PROCEDURE  activate_ins_streams(
	errbuf           OUT NOCOPY VARCHAR2,
	retcode          OUT NOCOPY NUMBER
      );

 PROCEDURE  activate_ins_streams(
     p_api_version                   IN NUMBER,
     p_init_msg_list                IN VARCHAR2 DEFAULT Okc_Api.G_FALSE,
     x_return_status                OUT NOCOPY  VARCHAR2,
     x_msg_count                    OUT NOCOPY NUMBER,
     x_msg_data                     OUT NOCOPY VARCHAR2,
     p_contract_id                  IN NUMBER
         );


	PROCEDURE   activate_ins_policy(
       p_api_version                   IN NUMBER,
     p_init_msg_list                IN VARCHAR2 DEFAULT Okc_Api.G_FALSE,
     x_return_status                OUT NOCOPY VARCHAR2,
     x_msg_count                    OUT NOCOPY NUMBER,
     x_msg_data                     OUT NOCOPY VARCHAR2,
     p_ins_policy_id                     IN NUMBER
         );

     PROCEDURE  create_third_prt_ins(
     p_api_version                   IN NUMBER,
     p_init_msg_list                IN VARCHAR2 DEFAULT Okc_Api.G_FALSE,
     x_return_status                OUT NOCOPY  VARCHAR2,
     x_msg_count                    OUT NOCOPY NUMBER,
     x_msg_data                     OUT NOCOPY VARCHAR2,
     p_ipyv_rec                  IN ipyv_rec_type,
     x_ipyv_rec                  OUT NOCOPY  ipyv_rec_type
         );
-- Bug: 4567777 PAGARG new procedures for Lease Application Functionality.
     PROCEDURE crt_lseapp_thrdprt_ins(
     p_api_version                  IN NUMBER,
     p_init_msg_list                IN VARCHAR2 DEFAULT OKL_API.G_FALSE,
     x_return_status                OUT NOCOPY  VARCHAR2,
     x_msg_count                    OUT NOCOPY NUMBER,
     x_msg_data                     OUT NOCOPY VARCHAR2,
     p_ipyv_rec                     IN ipyv_rec_type,
     x_ipyv_rec                     OUT NOCOPY ipyv_rec_type);

	PROCEDURE lseapp_thrdprty_to_ctrct(
     p_api_version                  IN NUMBER,
     p_init_msg_list                IN VARCHAR2 DEFAULT OKL_API.G_FALSE,
     x_return_status                OUT NOCOPY VARCHAR2,
     x_msg_count                    OUT NOCOPY NUMBER,
     x_msg_data                     OUT NOCOPY VARCHAR2,
     p_lakhr_id                     IN NUMBER,
     x_ipyv_rec                     OUT NOCOPY ipyv_rec_type);

END Okl_Ins_Quote_Pvt;

 

/
