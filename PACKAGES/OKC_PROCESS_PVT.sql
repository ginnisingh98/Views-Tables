--------------------------------------------------------
--  DDL for Package OKC_PROCESS_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OKC_PROCESS_PVT" AUTHID CURRENT_USER as
/* $Header: OKCCPDFS.pls 120.0 2005/05/26 09:30:45 appldev noship $ */

 subtype pdfv_rec_type is okc_pdf_pvt.pdfv_rec_type;
 subtype pdfv_tbl_type is okc_pdf_pvt.pdfv_tbl_type;
 subtype pdpv_rec_type is okc_pdp_pvt.pdpv_rec_type;
 subtype pdpv_tbl_type is okc_pdp_pvt.pdpv_tbl_type;

 ----------------------------------------------------------------------------------
 -- Global Variables
 G_PKG_NAME                  CONSTANT VARCHAR2(200) := 'OKC_PROCESS_PVT';
 G_APP_NAME                  CONSTANT VARCHAR2(3)   :=  OKC_API.G_APP_NAME;
 G_UNEXPECTED_ERROR          CONSTANT VARCHAR2(200) := 'OKC_UNEXPECTED_ERROR';
 G_SQLERRM_TOKEN             CONSTANT VARCHAR2(200) := 'SQLerrm';
 G_SQLCODE_TOKEN             CONSTANT VARCHAR2(200) := 'SQLcode';
 G_DELETE_PROC_DEF	         CONSTANT VARCHAR2(200) := 'OKC_CANNOT_DELETE_PROCESS_DEF';
 G_VALIDATE_DBNAME_NOTFOUND  CONSTANT VARCHAR2(200) := 'OKC_VALIDATE_DBNAME_NOTFOUND';
 G_VALIDATE_DBNAME_NOTRUN    CONSTANT VARCHAR2(200) := 'OKC_VALIDATE_DBNAME_NOTRUN';
 G_VALIDATE_DBNAME_SUCCESS   CONSTANT VARCHAR2(200) := 'OKC_VALIDATE_DBNAME_SUCCESS';
 G_VALIDATE_DBNAME_WF_PAIR   CONSTANT VARCHAR2(200) := 'OKC_VALIDATE_DBNAME_WF_PAIR';
 G_VALIDATE_DBNAME_PP_PAIR   CONSTANT VARCHAR2(200) := 'OKC_VALIDATE_DBNAME_PP_PAIR';
 ----------------------------------------------------------------------------------
  --Global Exception
  G_EXCEPTION_HALT_VALIDATION	EXCEPTION;
 ----------------------------------------------------------------------------------

 PROCEDURE ADD_LANGUAGE;

 --Object type procedure for insert
 PROCEDURE create_process_def(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_pdfv_rec                     IN pdfv_rec_type,
    p_pdpv_tbl                     IN pdpv_tbl_type,
    x_pdfv_rec                     OUT NOCOPY pdfv_rec_type,
    x_pdpv_tbl                     OUT NOCOPY pdpv_tbl_type);

 --Object type procedure for update
 PROCEDURE update_process_def(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_pdfv_rec                     IN pdfv_rec_type,
    p_pdpv_tbl                     IN pdpv_tbl_type,
    x_pdfv_rec                     OUT NOCOPY pdfv_rec_type,
    x_pdpv_tbl                     OUT NOCOPY pdpv_tbl_type);

 --Object type procedure for validate
 PROCEDURE validate_process_def(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_pdfv_rec                     IN pdfv_rec_type,
    p_pdpv_tbl                     IN pdpv_tbl_type);

 --Procedures for Process definitions
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
    p_pdfv_rec                     IN pdfv_rec_type);

END okc_process_pvt;

 

/
