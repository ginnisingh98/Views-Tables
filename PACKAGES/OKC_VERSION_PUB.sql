--------------------------------------------------------
--  DDL for Package OKC_VERSION_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OKC_VERSION_PUB" AUTHID CURRENT_USER as
/* $Header: OKCPVERS.pls 120.0 2005/05/25 23:06:23 appldev noship $ */

subtype cvmv_rec_type is okc_version_pvt.cvmv_rec_type;
subtype cvmv_tbl_type is okc_cvm_pvt.cvmv_tbl_type;

G_EXCEPTION_HALT_PROCESSING  EXCEPTION;
G_APP_NAME			    CONSTANT   VARCHAR2(3)   :=  OKC_API.G_APP_NAME;
G_UNEXPECTED_ERROR           CONSTANT   varchar2(200) := 'OKC_CONTRACTS_UNEXPECTED_ERROR';
G_SQLERRM_TOKEN              CONSTANT   varchar2(200) := 'ERROR_MESSAGE';
G_SQLCODE_TOKEN              CONSTANT   varchar2(200) := 'ERROR_CODE';


--Procedures pertaining to versioning a contract

PROCEDURE version_contract(
	p_api_version 		IN NUMBER,
	p_init_msg_list 	IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
	x_return_status	OUT NOCOPY VARCHAR2,
	x_msg_count		OUT NOCOPY NUMBER,
	x_msg_data		OUT NOCOPY VARCHAR2,
     p_cvmv_rec          IN cvmv_rec_type,
	p_commit        	IN VARCHAR2 DEFAULT OKC_API.G_TRUE,
     x_cvmv_rec          OUT NOCOPY cvmv_rec_type);

PROCEDURE version_contract(
	p_api_version 		IN NUMBER,
	p_init_msg_list 	IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
	x_return_status	OUT NOCOPY VARCHAR2,
	x_msg_count		OUT NOCOPY NUMBER,
	x_msg_data		OUT NOCOPY VARCHAR2,
     p_cvmv_tbl          IN cvmv_tbl_type,
	p_commit        	IN VARCHAR2 DEFAULT OKC_API.G_TRUE,
     x_cvmv_tbl          OUT NOCOPY cvmv_tbl_type);

PROCEDURE save_version(
    p_chr_id 				IN NUMBER,
    p_api_version             IN NUMBER,
    p_init_msg_list           IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status           OUT NOCOPY VARCHAR2,
    x_msg_count               OUT NOCOPY NUMBER,
    p_commit        	     IN VARCHAR2 DEFAULT OKC_API.G_TRUE,
    x_msg_data                OUT NOCOPY VARCHAR2);

PROCEDURE erase_saved_version(
    p_chr_id 				IN NUMBER,
    p_api_version             IN NUMBER,
    p_init_msg_list           IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status           OUT NOCOPY VARCHAR2,
    x_msg_count               OUT NOCOPY NUMBER,
    p_commit        	     IN VARCHAR2 DEFAULT OKC_API.G_TRUE,
    x_msg_data                OUT NOCOPY VARCHAR2);

PROCEDURE restore_version(
    p_chr_id 				IN NUMBER,
    p_api_version             IN NUMBER,
    p_init_msg_list           IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status           OUT NOCOPY VARCHAR2,
    x_msg_count               OUT NOCOPY NUMBER,
    p_commit        	     IN VARCHAR2 DEFAULT OKC_API.G_TRUE,
    x_msg_data                OUT NOCOPY VARCHAR2);


END okc_version_pub;

 

/
