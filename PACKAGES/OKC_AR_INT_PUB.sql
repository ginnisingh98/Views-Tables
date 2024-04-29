--------------------------------------------------------
--  DDL for Package OKC_AR_INT_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OKC_AR_INT_PUB" AUTHID CURRENT_USER AS
/* $Header: OKCPARXS.pls 120.0 2005/05/25 23:09:40 appldev noship $ */
  ---------------------------------------------------------------------------
  -- GLOBAL DATASTRUCTURES
  ---------------------------------------------------------------------------
  TYPE contract_contingency_rec_type IS RECORD (
   CONTINGENCY_TYPE              VARCHAR2(30),
   CONTINGENCY_PRESENT_YN        VARCHAR2(1),
   EXPIRATION_DATE               DATE,
   EXPIRATION_START_EVENT        VARCHAR2(30) DEFAULT 'INVOICE',
   EXPIRATION_DURATION           NUMBER,
   DURATION_UOM                  VARCHAR2(30));

  TYPE contract_contingency_tbl_type IS TABLE OF contract_contingency_rec_type INDEX BY BINARY_INTEGER;

  -- GLOBAL VARIABLES
  ---------------------------------------------------------------------------
  G_UNEXPECTED_ERROR           CONSTANT   varchar2(200) := 'OKC_UNEXPECTED_ERROR';
  G_PKG_NAME                    CONSTANT VARCHAR2(200) := 'OKC_AR_INT_PUB';
  G_APP_NAME                    CONSTANT VARCHAR2(3)   :=  OKC_API.G_APP_NAME;
  G_SQLERRM_TOKEN              CONSTANT   varchar2(200) := 'ERROR_MESSAGE';
  G_SQLCODE_TOKEN              CONSTANT   varchar2(200) := 'ERROR_CODE';
  G_EXCEPTION_HALT_VALIDATION           EXCEPTION;
  ---------------------------------------------------------------------------


PROCEDURE get_contract_contingencies
( p_api_version                     IN NUMBER,
  p_init_msg_list                   IN VARCHAR2 DEFAULT FND_API.G_FALSE,
  p_contract_id                     IN NUMBER,
  p_contract_line_id                IN NUMBER,
  x_contract_contingencies_tbl      OUT NOCOPY contract_contingency_tbl_type,
  x_return_status                   OUT NOCOPY VARCHAR2,
  x_msg_count                       OUT NOCOPY NUMBER,
  x_msg_data                        OUT NOCOPY VARCHAR2
);

END okc_ar_int_pub;

 

/
