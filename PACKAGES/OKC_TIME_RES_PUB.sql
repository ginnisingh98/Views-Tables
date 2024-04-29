--------------------------------------------------------
--  DDL for Package OKC_TIME_RES_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OKC_TIME_RES_PUB" AUTHID CURRENT_USER AS
/* $Header: OKCPRESS.pls 120.0 2005/05/25 19:03:28 appldev noship $ */
  ---------------------------------------------------------------------------
  -- GLOBAL DATASTRUCTURES
  ---------------------------------------------------------------------------
  G_UPPERCASE_REQUIRED         CONSTANT   VARCHAR2(200) := 'OKC_UPPER_CASE_REQUIRED';
  G_UNEXPECTED_ERROR           CONSTANT   VARCHAR2(200) := 'OKC_CONTRACTS_UNEXPECTED_ERROR';
  G_SQLERRM_TOKEN              CONSTANT   VARCHAR2(200) := 'SQLerrm';
  G_SQLCODE_TOKEN              CONSTANT   VARCHAR2(200) := 'SQLcode';
  G_RETURN_STATUS                         VARCHAR2(1)   :=  OKC_API.G_RET_STS_SUCCESS;
  G_EXCEPTION_HALT_VALIDATION  EXCEPTION;
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
  ---------------------------------------------------------------------------
  -- GLOBAL VARIABLES
  ---------------------------------------------------------------------------
  G_PKG_NAME			CONSTANT VARCHAR2(200) := 'OKC_TIME_RES_PVT';
  G_APP_NAME			CONSTANT VARCHAR2(3)   :=  OKC_API.G_APP_NAME;
  ---------------------------------------------------------------------------
  -- Procedures and Functions
  ---------------------------------------------------------------------------

  PROCEDURE Res_Time_Events(
    x_return_status                OUT NOCOPY VARCHAR2,
    p_api_version	    IN NUMBER,
    p_init_msg_list         IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    p_cnh_id                       IN NUMBER,
    p_coe_id                       IN NUMBER,
    p_date                         IN date);

  PROCEDURE Res_Time_New_K(
    p_chr_id IN NUMBER,
    p_api_version	    IN NUMBER,
    p_init_msg_list         IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status OUT NOCOPY VARCHAR2);

  PROCEDURE Res_Time_Extnd_K(
    p_chr_id IN NUMBER,
    p_cle_id IN NUMBER,
    p_start_date IN DATE,
    p_end_date IN DATE,
    p_api_version	    IN NUMBER,
    p_init_msg_list         IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status OUT NOCOPY VARCHAR2);

  PROCEDURE Res_Time_Termnt_K(
    p_chr_id IN NUMBER,
    p_cle_id IN NUMBER,
    p_end_date IN DATE,
    p_api_version	    IN NUMBER,
    p_init_msg_list         IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status OUT NOCOPY VARCHAR2);

  FUNCTION Check_Res_Time_N_tasks(
    p_tve_id IN NUMBER,
    p_date IN DATE)
  return BOOLEAN ;

  PROCEDURE Delete_Res_Time_N_Tasks(
    p_tve_id IN NUMBER,
    p_date IN DATE,
    p_api_version	    IN NUMBER,
    p_init_msg_list         IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status OUT NOCOPY VARCHAR2);

  PROCEDURE Create_Res_Time_N_Tasks(
    p_tve_id IN NUMBER,
    p_start_date IN DATE,
    p_end_date IN DATE,
    p_api_version	    IN NUMBER,
    p_init_msg_list         IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status OUT NOCOPY VARCHAR2);

  PROCEDURE Batch_Resolve_Time_N_Tasks ;
END OKC_TIME_RES_PUB;

 

/
