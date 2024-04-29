--------------------------------------------------------
--  DDL for Package OKL_GL_TRANSFER_PVT_W
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OKL_GL_TRANSFER_PVT_W" AUTHID CURRENT_USER as
  /* $Header: OKLEGLTS.pls 120.1 2005/07/11 12:50:03 dkagrawa noship $ */
  procedure okl_gl_transfer_con(p_init_msg_list  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p_batch_name  VARCHAR2
    , p_from_date  date
    , p_to_date  date
    , p_validate_account  VARCHAR2
    , p_gl_transfer_mode  VARCHAR2
    , p_submit_journal_import  VARCHAR2
    , x_request_id out nocopy  NUMBER
  );
end okl_gl_transfer_pvt_w;

 

/
