--------------------------------------------------------
--  DDL for Package OKL_SALES_QUOTE_QA_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OKL_SALES_QUOTE_QA_PVT" AUTHID CURRENT_USER AS
/* $Header: OKLRQQCS.pls 120.4 2006/04/12 11:20:02 ssdeshpa noship $ */

 --------------------
   -- PACKAGE CONSTANTS
   --------------------
   G_PKG_NAME             CONSTANT VARCHAR2(30)  := 'OKLRQQCB.pls';
   G_APP_NAME             CONSTANT VARCHAR2(30)  := OKL_API.G_APP_NAME;
   G_API_VERSION          CONSTANT NUMBER        := 1;
   G_USER_ID              CONSTANT NUMBER        := FND_GLOBAL.USER_ID;
   G_LOGIN_ID             CONSTANT NUMBER        := FND_GLOBAL.LOGIN_ID;
   G_FALSE                CONSTANT VARCHAR2(1)   := OKL_API.G_FALSE;
   G_TRUE                 CONSTANT VARCHAR2(1)   := OKL_API.G_TRUE;
   G_RET_STS_SUCCESS      CONSTANT VARCHAR2(1)   := OKL_API.G_RET_STS_SUCCESS;
   G_RET_STS_UNEXP_ERROR  CONSTANT VARCHAR2(1)   := OKL_API.G_RET_STS_UNEXP_ERROR;
   G_RET_STS_ERROR        CONSTANT VARCHAR2(1)   := OKL_API.G_RET_STS_ERROR;
   G_DB_ERROR             CONSTANT VARCHAR2(30)  := 'OKL_DB_ERROR';
   G_PKG_NAME_TOKEN       CONSTANT VARCHAR2(30)  := 'PKG_NAME';
   G_PROG_NAME_TOKEN      CONSTANT VARCHAR2(30)  := 'PROG_NAME';
   G_COL_NAME_TOKEN       CONSTANT VARCHAR2(30)  := 'COL_NAME';
   G_SQLCODE_TOKEN        CONSTANT VARCHAR2(30)  := 'SQLCODE';
   G_SQLERRM_TOKEN        CONSTANT VARCHAR2(30)  := 'SQLERRM';
   G_API_TYPE             CONSTANT varchar2(4)   := '_PVT';
   G_FUNCTION_DATA_INVALID     CONSTANT VARCHAR2(200) := 'OKL_FUNCTION_DATA_INVALID';
   G_OPERAND_DATA_INVALID      CONSTANT VARCHAR2(200) := 'OKL_OPERAND_DATA_INVALID';
   G_FUNCTION_DOES_NOT_EXIST   CONSTANT VARCHAR2(200) := 'OKL_FUNCTION_DOES_NOT_EXIST';
   G_INVALID_FUNCTION          CONSTANT VARCHAR2(200) := 'OKL_INVALID_FUNCTION';
   -----------------------------------------------------------------------------
   --Exception Delration

   ------------------
   -- DATA STRUCTURES
   ------------------

   TYPE qa_results_rec_type IS RECORD (
     check_code                      VARCHAR2(30)
    ,check_meaning                   VARCHAR2(80)
    ,result_code                     VARCHAR2(30)
    ,result_meaning                  VARCHAR2(80)
    ,message_code                    VARCHAR2(30)
    ,message_text                    VARCHAR2(2000)
    );

   TYPE qa_results_tbl_type IS TABLE OF qa_results_rec_type INDEX BY BINARY_INTEGER;
 --------------------------------------------------------------------------------
 --QA Checker Called By Quick Quote Validate API's
   PROCEDURE run_qa_checker (
      p_api_version                  IN NUMBER
     ,p_init_msg_list                IN VARCHAR2
     ,p_object_type                  IN VARCHAR2
     ,p_object_id                    IN NUMBER
     ,x_return_status                OUT NOCOPY VARCHAR2
     ,x_msg_count                    OUT NOCOPY NUMBER
     ,x_msg_data                     OUT NOCOPY VARCHAR2
     ,x_qa_result                    OUT NOCOPY VARCHAR2
     ,x_qa_result_tbl                IN OUT NOCOPY OKL_SALES_QUOTE_QA_PVT.qa_results_tbl_type);
 --------------------------------------------------------------------------------
 --QA Checker Called By the
 --Lease Quote,Lease Application and Lease Opportunity Validate API's

   PROCEDURE run_qa_checker (
      p_api_version                  IN NUMBER
     ,p_init_msg_list                IN VARCHAR2
     ,p_object_type                  IN VARCHAR2
     ,p_object_id                    IN NUMBER
     ,x_qa_result                    OUT NOCOPY VARCHAR2
     ,x_return_status                OUT NOCOPY VARCHAR2
     ,x_msg_count                    OUT NOCOPY NUMBER
     ,x_msg_data                     OUT NOCOPY VARCHAR2);
 --------------------------------------------------------------------------------
   ----------------
   -- PROGRAM UNITS
   ----------------
   PROCEDURE run_qa_checker (
      p_api_version                  IN NUMBER
     ,p_init_msg_list                IN VARCHAR2
     ,p_object_type                  IN VARCHAR2
     ,p_object_id                    IN NUMBER
     ,x_return_status                OUT NOCOPY VARCHAR2
     ,x_msg_count                    OUT NOCOPY NUMBER
     ,x_msg_data                     OUT NOCOPY VARCHAR2
     ,x_qa_result_tbl                OUT NOCOPY OKL_SALES_QUOTE_QA_PVT.qa_results_tbl_type);

  ------------------------------------------------------------------------------
  --Bug # 4688662 ssdeshpa start
   FUNCTION are_all_lines_overriden(p_quote_id           IN  NUMBER
                                    ,p_pricing_method     IN  VARCHAR2
                                    ,p_line_level_pricing IN VARCHAR2
                                    ,x_return_status      OUT NOCOPY VARCHAR2)
   RETURN VARCHAR2;
  --Bug # 4688662 ssdeshpa end

END OKL_SALES_QUOTE_QA_PVT;

/
