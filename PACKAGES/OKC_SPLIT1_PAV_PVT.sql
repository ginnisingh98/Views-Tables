--------------------------------------------------------
--  DDL for Package OKC_SPLIT1_PAV_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OKC_SPLIT1_PAV_PVT" AUTHID CURRENT_USER AS
/* $Header: OKCSPAVSPOS.pls 120.0.12010000.2 2010/12/16 10:59:14 nvvaidya noship $ */
  ---------------------------------------------------------------------------
  -- GLOBAL MESSAGE CONSTANTS
  ---------------------------------------------------------------------------
  G_FND_APP			CONSTANT VARCHAR2(200) := OKC_API.G_FND_APP;
  G_FORM_UNABLE_TO_RESERVE_REC	CONSTANT VARCHAR2(200) := OKC_API.G_FORM_UNABLE_TO_RESERVE_REC;
  G_FORM_RECORD_DELETED		CONSTANT VARCHAR2(200) := OKC_API.G_FORM_RECORD_DELETED;
  G_FORM_RECORD_CHANGED		CONSTANT VARCHAR2(200) := OKC_API.G_FORM_RECORD_CHANGED;
  G_RECORD_LOGICALLY_DELETED	CONSTANT VARCHAR2(200) := OKC_API.G_RECORD_LOGICALLY_DELETED;
  G_REQUIRED_VALUE		CONSTANT VARCHAR2(200) := OKC_API.G_REQUIRED_VALUE;
  G_INVALID_VALUE			CONSTANT VARCHAR2(200) := OKC_API.G_INVALID_VALUE;
  G_COL_NAME_TOKEN		CONSTANT VARCHAR2(200) := OKC_API.G_COL_NAME_TOKEN;
  G_PARENT_TABLE_TOKEN		CONSTANT VARCHAR2(200) := OKC_API.G_PARENT_TABLE_TOKEN;
  G_CHILD_TABLE_TOKEN		CONSTANT VARCHAR2(200) := OKC_API.G_CHILD_TABLE_TOKEN;
  G_UNEXPECTED_ERROR            CONSTANT VARCHAR2(200) := 'OKC_CONTRACTS_UNEXP_ERROR';
  G_FOREIGN_KEY_ERROR	 	CONSTANT VARCHAR2(200) := 'OKC_CONTRACTS_FK_ERROR';
  G_UNIQUE_KEY_ERROR	 	CONSTANT VARCHAR2(200) := 'OKC_CONTRACTS_UNIQUE_KEY_ERROR';
  G_SQLERRM_TOKEN               CONSTANT VARCHAR2(200) := 'ERROR_MESSAGE';
  G_SQLCODE_TOKEN               CONSTANT VARCHAR2(200) := 'ERROR_CODE';
  G_UPPERCASE_REQUIRED		CONSTANT VARCHAR2(200) := 'OKC_CONTRACTS_UPPERCASE_REQD';

  ---------------------------------------------------------------------------
  -- GLOBAL EXCEPTION
  ---------------------------------------------------------------------------
  G_EXCEPTION_HALT_VALIDATION	EXCEPTION;
  ---------------------------------------------------------------------------
  -- GLOBAL VARIABLES
  ---------------------------------------------------------------------------
  G_PKG_NAME			CONSTANT VARCHAR2(200) := 'OKC_PAV_PVT';
  G_APP_NAME			CONSTANT VARCHAR2(3)   :=  OKC_API.G_APP_NAME;
 ---------------------------
 --FUNCTIONs AND Procedures
 ---------------------------
   FUNCTION get_rec (
    p_pav_rec                      IN OKC_PAV_PVT.pav_rec_type,
    x_no_data_found                OUT NOCOPY BOOLEAN
  ) RETURN OKC_PAV_PVT.pav_rec_type ;

  FUNCTION get_rec (
    p_pavv_rec                     IN OKC_PAV_PVT.pavv_rec_type,
    x_no_data_found                OUT NOCOPY BOOLEAN
  ) RETURN OKC_PAV_PVT.pavv_rec_type;


   FUNCTION null_out_defaults (
    p_pavv_rec	IN OKC_PAV_PVT.pavv_rec_type
  ) RETURN OKC_PAV_PVT.pavv_rec_type ;

END OKC_SPLIT1_PAV_PVT;

/
