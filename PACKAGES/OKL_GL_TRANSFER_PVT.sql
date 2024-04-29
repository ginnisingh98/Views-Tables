--------------------------------------------------------
--  DDL for Package OKL_GL_TRANSFER_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OKL_GL_TRANSFER_PVT" AUTHID CURRENT_USER AS
/* $Header: OKLRGLTS.pls 115.9 2002/12/18 12:47:37 kjinger noship $ */

  G_REQUIRED_VALUE		CONSTANT VARCHAR2(200) := OKC_API.G_REQUIRED_VALUE;
  G_COL_NAME_TOKEN		CONSTANT VARCHAR2(200) := OKC_API.G_COL_NAME_TOKEN;
  G_PKG_NAME     CONSTANT VARCHAR2(30) := 'OKL_GL_TRANSFER_PVT';
  G_APP_NAME CONSTANT VARCHAR2(3)      :=  OKL_API.G_APP_NAME;
  G_FILE_NAME    CONSTANT VARCHAR2(12) := 'OKLRGLTB.pls';


PROCEDURE OKL_GL_transfer (p_errbuf OUT NOCOPY VARCHAR2
                          ,p_retcode OUT NOCOPY NUMBER
                          ,p_batch_name IN VARCHAR2
                          ,p_from_date IN VARCHAR2
                          ,p_to_date IN VARCHAR2
                          ,p_validate_account IN VARCHAR2
                          ,p_gl_transfer_mode IN VARCHAR2
                          ,p_submit_journal_import IN VARCHAR2 );

PROCEDURE OKL_gl_transfer_con (p_init_msg_list IN VARCHAR2 DEFAULT Okc_Api.G_FALSE
                              ,x_return_status OUT NOCOPY VARCHAR2
                              ,x_msg_count OUT NOCOPY NUMBER
                              ,x_msg_data OUT NOCOPY VARCHAR2
                              ,p_batch_name IN VARCHAR2
                              ,p_from_date IN DATE
                              ,p_to_date IN DATE
                              ,p_validate_account IN VARCHAR2
                              ,p_gl_transfer_mode IN VARCHAR2
                              ,p_submit_journal_import IN VARCHAR2
                              ,x_request_id OUT NOCOPY NUMBER);


END Okl_Gl_Transfer_Pvt;

 

/
