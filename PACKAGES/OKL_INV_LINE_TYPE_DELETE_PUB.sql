--------------------------------------------------------
--  DDL for Package OKL_INV_LINE_TYPE_DELETE_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OKL_INV_LINE_TYPE_DELETE_PUB" AUTHID CURRENT_USER AS
/* $Header: OKLPILRS.pls 115.1 2002/02/05 12:06:05 pkm ship       $ */

SUBTYPE ilt_del_rec_type IS Okl_Inv_Line_Type_Delete_Pvt.ilt_del_rec_type;
SUBTYPE ilt_del_tbl_type IS Okl_Inv_Line_Type_Delete_Pvt.ilt_del_tbl_type;

  ---------------------------------------------------------------------------
  -- Procedures and Functions
  ---------------------------------------------------------------------------

  PROCEDURE delete_line_type(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT Okl_Api.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_ilt_del_rec                  IN ilt_del_rec_type);

  PROCEDURE delete_line_type(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT Okl_Api.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_ilt_del_tbl                  IN ilt_del_tbl_type);

END Okl_Inv_Line_Type_Delete_Pub;

 

/
