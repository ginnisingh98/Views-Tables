--------------------------------------------------------
--  DDL for Package OKC_VERSION_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OKC_VERSION_PVT" AUTHID CURRENT_USER as
/* $Header: OKCRVERS.pls 120.0 2005/05/25 22:58:25 appldev noship $ */

subtype cvmv_rec_type is okc_cvm_pvt.cvmv_rec_type;

  -- GLOBAL VARIABLES
  ---------------------------------------------------------------------------
  G_UNEXPECTED_ERROR           CONSTANT   varchar2(200) := 'OKC_CONTRACTS_UNEXPECTED_ERROR';
  G_PKG_NAME			CONSTANT VARCHAR2(200) := 'OKC_VERSION_PVT';
  G_APP_NAME			CONSTANT VARCHAR2(3)   :=  OKC_API.G_APP_NAME;
  G_SQLERRM_TOKEN              CONSTANT   varchar2(200) := 'SQLerrm';
  G_SQLCODE_TOKEN              CONSTANT   varchar2(200) := 'SQLcode';
  G_COL_NAME_TOKEN		CONSTANT VARCHAR2(200) := OKC_API.G_COL_NAME_TOKEN;
  G_EXCEPTION_HALT_VALIDATION           EXCEPTION;
  ---------------------------------------------------------------------------

--Procedures pertaining to versioning a contract

PROCEDURE version_contract(
	p_api_version 		IN  NUMBER,
	p_init_msg_list 	IN  VARCHAR2 DEFAULT OKC_API.G_FALSE,
	x_return_status	OUT NOCOPY VARCHAR2,
	x_msg_count		OUT NOCOPY NUMBER,
	x_msg_data		OUT NOCOPY VARCHAR2,
     p_cvmv_rec          IN  cvmv_rec_type,
     x_cvmv_rec          OUT NOCOPY cvmv_rec_type,
     p_commit 		     IN  VARCHAR2 DEFAULT OKC_API.G_TRUE);


PROCEDURE save_version(
    p_chr_id 				IN NUMBER,
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_commit 				IN VARCHAR2 DEFAULT OKC_API.G_TRUE);

PROCEDURE erase_saved_version(
    p_chr_id 				IN NUMBER,
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_commit 				IN VARCHAR2 DEFAULT OKC_API.G_TRUE);

PROCEDURE restore_version(
    p_chr_id 				IN NUMBER,
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_commit 				IN VARCHAR2 DEFAULT OKC_API.G_TRUE);

Procedure delete_version (p_chr_id        IN NUMBER,
                          p_major_version IN NUMBER,
                          p_minor_version IN NUMBER,
                          p_called_from   IN VARCHAR2);

PROCEDURE Set_Attach_Session_Vars(p_chr_id NUMBER);

END okc_version_pvt;

 

/
