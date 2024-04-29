--------------------------------------------------------
--  DDL for Package OKL_INV_FORMAT_DELETE_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OKL_INV_FORMAT_DELETE_PUB" AUTHID CURRENT_USER AS
/* $Header: OKLPIFDS.pls 115.1 2002/02/05 12:06:02 pkm ship       $ */

SUBTYPE inf_del_rec_type IS Okl_Inv_Format_Delete_Pvt.inf_del_rec_type;
SUBTYPE inf_del_tbl_type IS Okl_Inv_Format_Delete_Pvt.inf_del_tbl_type;

  ---------------------------------------------------------------------------
  -- Procedures and Functions
  ---------------------------------------------------------------------------

  PROCEDURE delete_format(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT Okl_Api.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_inf_del_rec                  IN inf_del_rec_type);

  PROCEDURE delete_format(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT Okl_Api.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_inf_del_tbl                  IN inf_del_tbl_type);

END Okl_Inv_Format_Delete_Pub;

 

/
