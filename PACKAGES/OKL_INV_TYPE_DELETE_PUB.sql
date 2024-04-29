--------------------------------------------------------
--  DDL for Package OKL_INV_TYPE_DELETE_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OKL_INV_TYPE_DELETE_PUB" AUTHID CURRENT_USER AS
/* $Header: OKLPITDS.pls 115.1 2002/02/05 12:06:37 pkm ship       $ */

SUBTYPE ity_del_rec_type IS Okl_Inv_Type_Delete_Pvt.ity_del_rec_type;
SUBTYPE ity_del_tbl_type IS Okl_Inv_Type_Delete_Pvt.ity_del_tbl_type;

  ---------------------------------------------------------------------------
  -- Procedures and Functions
  ---------------------------------------------------------------------------

  PROCEDURE delete_type(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT Okl_Api.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_ity_del_rec                  IN ity_del_rec_type);

  PROCEDURE delete_type(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT Okl_Api.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_ity_del_tbl                  IN ity_del_tbl_type);

END Okl_Inv_Type_Delete_Pub;

 

/
