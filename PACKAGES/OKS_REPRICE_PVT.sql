--------------------------------------------------------
--  DDL for Package OKS_REPRICE_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OKS_REPRICE_PVT" AUTHID CURRENT_USER AS
/* $Header: OKSRRPRS.pls 120.1.12000000.1 2007/01/16 22:11:53 appldev ship $*/

  -- GLOBAL VARIABLES
  -------------------------------------------------------------------------------
  G_PKG_NAME	               CONSTANT VARCHAR2(200) := 'OKS_REPRICE_PVT';
  G_APP_NAME_OKS               CONSTANT VARCHAR2(3)   := 'OKS';
  G_APP_NAME_OKC               CONSTANT VARCHAR2(3)   := 'OKC';
  -------------------------------------------------------------------------------


  -- GLOBAL_MESSAGE_CONSTANTS
  ---------------------------------------------------------------------------------------------
  G_TRUE                       CONSTANT VARCHAR2(1)   := OKC_API.G_TRUE;
  G_FALSE                      CONSTANT VARCHAR2(1)   := OKC_API.G_FALSE;
  G_RET_STS_SUCCESS            CONSTANT VARCHAR2(1)   := OKC_API.G_RET_STS_SUCCESS;
  G_RET_STS_ERROR              CONSTANT VARCHAR2(1)   := OKC_API.G_RET_STS_ERROR;
  G_RET_STS_UNEXP_ERROR        CONSTANT VARCHAR2(1)   := OKC_API.G_RET_STS_UNEXP_ERROR;
  G_UNEXPECTED_ERROR           CONSTANT VARCHAR2(30)  := 'OKS_UNEXPECTED_ERROR';
  G_SQLERRM_TOKEN              CONSTANT VARCHAR2(30)  := 'ERROR_MESSAGE';
  G_SQLCODE_TOKEN              CONSTANT VARCHAR2(30)  := 'ERROR_CODE';
  G_REQUIRED_VALUE             CONSTANT VARCHAR2(30)  := OKC_API.G_REQUIRED_VALUE;
  G_COL_NAME_TOKEN             CONSTANT VARCHAR2(30)  := OKC_API.G_COL_NAME_TOKEN;
  ---------------------------------------------------------------------------------------------

  -- GLOBAL EXCEPTION
  ---------------------------------------
  G_ERROR                      EXCEPTION;
  G_SKIP_PRORATION             EXCEPTION;
  G_BUILD_RECORD_FAILED        EXCEPTION;
  ---------------------------------------

  TYPE REPRICE_REC_TYPE IS RECORD
       (
         Contract_Id          Number,
         Price_List_Id        Number,
         Price_Type           Varchar2(3),
         Markup_Percent       Number
       );

  TYPE SUB_LINE_TBL_TYPE IS TABLE OF NUMBER INDEX BY BINARY_INTEGER;

  PROCEDURE CALL_PRICING_API(
                             p_api_version        IN         NUMBER,
                             p_init_msg_list      IN         VARCHAR2,
                             p_id                 IN         NUMBER,
                             p_id_type            IN         VARCHAR2,
                             x_return_status      OUT NOCOPY VARCHAR2,
                             x_msg_count          OUT NOCOPY NUMBER,
                             x_msg_data           OUT NOCOPY VARCHAR2
                            );

  PROCEDURE CALL_PRICING_API(
                             p_api_version        IN  NUMBER,
                             p_init_msg_list      IN  VARCHAR2,
                             p_reprice_rec        IN  REPRICE_REC_TYPE,
                             x_return_status      OUT NOCOPY VARCHAR2,
                             x_msg_count          OUT NOCOPY NUMBER,
                             x_msg_data           OUT NOCOPY VARCHAR2
                            );

  PROCEDURE CALL_PRICING_API(
                             p_api_version            IN   NUMBER,
                             p_init_msg_list          IN   VARCHAR2,
                             x_return_status          OUT  NOCOPY VARCHAR2,
                             x_msg_count              OUT  NOCOPY NUMBER,
                             x_msg_data               OUT  NOCOPY VARCHAR2,
                             p_subject_chr_id         IN   NUMBER,
                             p_subject_top_line_id    IN   NUMBER,
                             p_subject_sub_line_tbl   IN   sub_line_tbl_type
			    );

END OKS_REPRICE_PVT;

 

/
