--------------------------------------------------------
--  DDL for Package OKL_AUTO_INSURANCE_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OKL_AUTO_INSURANCE_PVT" AUTHID CURRENT_USER AS
/* $Header: OKLRICXS.pls 115.4 2002/12/18 12:47:53 kjinger noship $ */

   ---------------------------------------------------------------------------
   -- GLOBAL DATASTRUCTURES
   ---------------------------------------------------------------------------
      TYPE id_rec_type IS RECORD (
     CONTRACT_NUMBER              VARCHAR2(120) := OKC_API.G_MISS_NUM,
     START_DATE                   DATE := OKC_API.G_MISS_DATE
 	);



   TYPE policy_tbl_type IS TABLE OF id_rec_type INDEX BY BINARY_INTEGER;
  SUBTYPE ipyv_rec_type IS Okl_ins_quote_Pub.ipyv_rec_type;

  SUBTYPE inav_rec_type IS Okl_Ina_Pvt.inav_rec_type;
 /*
 	TYPE iasset_rec_type IS RECORD (
     KLE_ID              NUMBER := OKC_API.G_MISS_NUM,
     premium               NUMBER := OKC_API.G_MISS_NUM
 	);
  TYPE iasset_tbl_type IS TABLE OF iasset_rec_type INDEX BY BINARY_INTEGER;
  */
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
   G_UNEXPECTED_ERROR		CONSTANT VARCHAR2(200) := 'OKL_CONTRACTS_UNEXPECTED_ERROR';
   G_NO_PARENT_RECORD            CONSTANT VARCHAR2(200) := 'OKL_PARENT_RECORD';
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
   G_INVALID_INSURANCE_TERM   CONSTANT VARCHAR2(200) := 'OKL_IPY_INVALID_DATERANGE';
   ---------------------------------------------------------------------------
   -- GLOBAL VARIABLES
   ---------------------------------------------------------------------------
   G_PKG_NAME			CONSTANT VARCHAR2(200) := 'OKL_AUTO_INSURANCE_PVT';
   G_APP_NAME			CONSTANT VARCHAR2(3)   :=  'OKL';
    ---------------------------------------------------------------------------
   -- GLOBAL EXCEPTION
   ---------------------------------------------------------------------------
   G_EXCEPTION_HALT_VALIDATION	EXCEPTION;
   ---------------------------------------------------------------------------
   -- Procedures and Functions
   ---------------------------------------------------------------------------
 PROCEDURE  auto_ins_establishment(
 	errbuf           OUT NOCOPY VARCHAR2,
 	retcode          OUT NOCOPY NUMBER
  );

   PROCEDURE  third_party_ins_followup(
 	errbuf           OUT NOCOPY VARCHAR2,
 	retcode          OUT NOCOPY NUMBER,
          p_template_id      IN NUMBER
        );

        PROCEDURE  pol_exp_notification(
        errbuf           OUT NOCOPY VARCHAR2,
        retcode          OUT NOCOPY NUMBER ,
        p_template_id      IN NUMBER
        ) ;


        PROCEDURE pay_ins_payments
 	(
 	 errbuf           OUT NOCOPY VARCHAR2,
 	 retcode          OUT NOCOPY NUMBER
 	,p_from_bill_date	IN  VARCHAR2
 	,p_to_bill_date		IN  VARCHAR2
 	);

END OKL_AUTO_INSURANCE_PVT;

 

/
