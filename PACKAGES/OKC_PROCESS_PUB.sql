--------------------------------------------------------
--  DDL for Package OKC_PROCESS_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OKC_PROCESS_PUB" AUTHID CURRENT_USER as
/* $Header: OKCPPDFS.pls 120.0 2005/05/26 09:28:34 appldev noship $ */

 	-- complex entity object subtype definitions
	subtype pdfv_rec_type is okc_process_pvt.pdfv_rec_type;
 	subtype pdfv_tbl_type is okc_process_pvt.pdfv_tbl_type;
 	subtype pdpv_rec_type is okc_process_pvt.pdpv_rec_type;
 	subtype pdpv_tbl_type is okc_process_pvt.pdpv_tbl_type;

  ---------------------------------------------------------------------------------------
  -- GLOBAL VARIABLES
  ---------------------------------------------------------------------------------------
 	G_PKG_NAME             CONSTANT VARCHAR2(200) := 'OKC_PROCESS_PUB';
 	G_APP_NAME             CONSTANT VARCHAR2(3)   :=  OKC_API.G_APP_NAME;
	G_UNEXPECTED_ERROR     CONSTANT VARCHAR2(200) := 'OKC_UNEXPECTED_ERROR';
  	G_SQLERRM_TOKEN        CONSTANT VARCHAR2(200) := 'SQLerrm';
  	G_SQLCODE_TOKEN        CONSTANT VARCHAR2(200) := 'SQLcode';

	g_pdfv_rec	       okc_process_pvt.pdfv_rec_type;
	g_pdfv_tbl             okc_process_pvt.pdfv_tbl_type;
        g_pdpv_rec             okc_process_pvt.pdpv_rec_type;
        g_pdpv_tbl             okc_process_pvt.pdpv_tbl_type;
 ---------------------------------------------------------------------------------------
	--Global Exception
  	G_EXCEPTION_HALT_VALIDATION	EXCEPTION;

 --Public procedure declarations

 PROCEDURE add_language;

 --Object type procedure for insert
 PROCEDURE create_process_def(
    p_api_version	    IN NUMBER,
    p_init_msg_list         IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status         OUT NOCOPY VARCHAR2,
    x_msg_count             OUT NOCOPY NUMBER,
    x_msg_data              OUT NOCOPY VARCHAR2,
    p_pdfv_rec		    IN pdfv_rec_type,
    p_pdpv_tbl              IN pdpv_tbl_type,
    x_pdfv_rec              OUT NOCOPY pdfv_rec_type,
    x_pdpv_tbl              OUT NOCOPY pdpv_tbl_type);

 --Object type procedure for update
 PROCEDURE update_process_def(
    p_api_version	    IN NUMBER,
    p_init_msg_list         IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status         OUT NOCOPY VARCHAR2,
    x_msg_count             OUT NOCOPY NUMBER,
    x_msg_data              OUT NOCOPY VARCHAR2,
    p_pdfv_rec		    IN pdfv_rec_type,
    p_pdpv_tbl              IN pdpv_tbl_type,
    x_pdfv_rec              OUT NOCOPY pdfv_rec_type,
    x_pdpv_tbl              OUT NOCOPY pdpv_tbl_type);

 --Object type procedure for validate
 PROCEDURE validate_process_def(
    p_api_version	    IN NUMBER,
    p_init_msg_list         IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status         OUT NOCOPY VARCHAR2,
    x_msg_count             OUT NOCOPY NUMBER,
    x_msg_data              OUT NOCOPY VARCHAR2,
    p_pdfv_rec		    IN pdfv_rec_type,
    p_pdpv_tbl              IN pdpv_tbl_type);

 --Procedures for Process Definitions

 PROCEDURE create_proc_def(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_pdfv_tbl                     IN pdfv_tbl_type,
    x_pdfv_tbl                     OUT NOCOPY pdfv_tbl_type);

 PROCEDURE create_proc_def(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_pdfv_rec                     IN pdfv_rec_type,
    x_pdfv_rec                     OUT NOCOPY pdfv_rec_type);

 PROCEDURE lock_proc_def(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_pdfv_tbl                     IN pdfv_tbl_type);

 PROCEDURE lock_proc_def(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_pdfv_rec                     IN pdfv_rec_type);

 PROCEDURE update_proc_def(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_pdfv_tbl                     IN pdfv_tbl_type,
    x_pdfv_tbl                     OUT NOCOPY pdfv_tbl_type);

 PROCEDURE update_proc_def(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_pdfv_rec                     IN pdfv_rec_type,
    x_pdfv_rec                     OUT NOCOPY pdfv_rec_type);

 PROCEDURE delete_proc_def(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_pdfv_tbl                     IN pdfv_tbl_type);

 PROCEDURE delete_proc_def(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_pdfv_rec                     IN pdfv_rec_type);

 PROCEDURE validate_proc_def(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_pdfv_tbl                     IN pdfv_tbl_type);

 PROCEDURE validate_proc_def(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_pdfv_rec                     IN pdfv_rec_type);

  --Procedures for Process Definition Parameters

 PROCEDURE create_proc_def_parms(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_pdpv_tbl                     IN pdpv_tbl_type,
    x_pdpv_tbl                     OUT NOCOPY pdpv_tbl_type);

 PROCEDURE create_proc_def_parms(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_pdpv_rec                     IN pdpv_rec_type,
    x_pdpv_rec                     OUT NOCOPY pdpv_rec_type);

 PROCEDURE lock_proc_def_parms(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_pdpv_tbl                     IN pdpv_tbl_type);

 PROCEDURE lock_proc_def_parms(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_pdpv_rec                     IN pdpv_rec_type);

 PROCEDURE update_proc_def_parms(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_pdpv_tbl                     IN pdpv_tbl_type,
    x_pdpv_tbl                     OUT NOCOPY pdpv_tbl_type);

 PROCEDURE update_proc_def_parms(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_pdpv_rec                     IN pdpv_rec_type,
    x_pdpv_rec                     OUT NOCOPY pdpv_rec_type);

 PROCEDURE delete_proc_def_parms(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_pdpv_rec                     IN pdpv_rec_type);

 PROCEDURE delete_proc_def_parms(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_pdpv_tbl                     IN pdpv_tbl_type);

 PROCEDURE validate_proc_def_parms(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_pdpv_tbl                     IN pdpv_tbl_type);

 PROCEDURE validate_proc_def_parms(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_pdpv_rec                     IN pdpv_rec_type);

 PROCEDURE validate_dbnames(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_wf_proc                      IN  VARCHAR2,
    p_wf_name                      IN  VARCHAR2,
    p_package                      IN  VARCHAR2,
    p_procedure                    IN  VARCHAR2);

END okc_process_pub;

 

/
