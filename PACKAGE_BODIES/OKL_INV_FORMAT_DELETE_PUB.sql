--------------------------------------------------------
--  DDL for Package Body OKL_INV_FORMAT_DELETE_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OKL_INV_FORMAT_DELETE_PUB" AS
/* $Header: OKLPIFDB.pls 115.3 2002/02/12 14:30:46 pkm ship        $ */
  ---------------------------------------------------------------------------
  -- GLOBAL DATASTRUCTURES
  ---------------------------------------------------------------------------
  ---------------------------------------------------------------------------
  -- Procedures and Functions
  ---------------------------------------------------------------------------

PROCEDURE delete_format(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT Okl_Api.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_inf_del_rec                  IN inf_del_rec_type)
IS


BEGIN

  Okl_Inv_Format_Delete_Pvt.DELETE_FORMAT(
    p_api_version,
    p_init_msg_list,
    x_return_status,
    x_msg_count,
    x_msg_data,
    p_inf_del_rec);

EXCEPTION
	 WHEN OTHERS THEN
                  null;
END;

PROCEDURE delete_format(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT Okl_Api.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_inf_del_tbl                     IN inf_del_tbl_type)
IS

BEGIN

  Okl_Inv_Format_Delete_Pvt.DELETE_FORMAT(
    p_api_version,
    p_init_msg_list,
    x_return_status,
    x_msg_count,
    x_msg_data,
    p_inf_del_tbl);

EXCEPTION
	 WHEN OTHERS THEN
                  null;
END;

END Okl_Inv_Format_Delete_Pub;

/
