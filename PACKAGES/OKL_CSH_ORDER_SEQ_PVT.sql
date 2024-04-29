--------------------------------------------------------
--  DDL for Package OKL_CSH_ORDER_SEQ_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OKL_CSH_ORDER_SEQ_PVT" AUTHID CURRENT_USER AS
/* $Header: OKLRSATS.pls 120.2 2006/07/11 09:58:54 dkagrawa noship $ */


 SUBTYPE stav_rec_type IS okl_strm_typ_allocs_pub.stav_rec_type;
 SUBTYPE stav_tbl_type IS okl_strm_typ_allocs_pub.stav_tbl_type;

  ---------------------------------------------------------------------------
  -- GLOBAL DATASTRUCTURES
  ---------------------------------------------------------------------------

  TYPE okl_csh_order_rec_type IS RECORD (
    name                           OKL_STRM_TYPE_V.NAME%TYPE,
    sty_id                         OKL_BPD_CSH_ORDER_UV.STY_ID%TYPE,
    cat_id                         OKL_BPD_CSH_ORDER_UV.CAT_ID%TYPE,
    id                             NUMBER,
    object_version_number          NUMBER := 1.0,
    sequence_number                NUMBER,
    stream_allc_type               OKL_STRM_TYP_ALLOCS.STREAM_ALLC_TYPE%TYPE,
    created_by                     NUMBER   := 0,
    creation_date                  OKL_STRM_TYP_ALLOCS.CREATION_DATE%TYPE := Okl_Api.G_MISS_DATE,
    last_updated_by                NUMBER   := 0,
    last_update_date               OKL_STRM_TYP_ALLOCS.LAST_UPDATE_DATE%TYPE := Okl_Api.G_MISS_DATE,
    last_update_login              NUMBER := 1);

    g_miss_okl_csh_order_rec      okl_csh_order_rec_type;
  TYPE okl_csh_order_tbl_type IS TABLE OF okl_csh_order_rec_type
        INDEX BY BINARY_INTEGER;

  ---------------------------------------------------------------------------
  -- GLOBAL VARIABLES
  ---------------------------------------------------------------------------

  ---------------------------------------------------------------------------
  -- Procedures and Functions
  ---------------------------------------------------------------------------

PROCEDURE insert_row (p_api_version  IN NUMBER
       ,p_init_msg_list     IN VARCHAR2 DEFAULT Okc_Api.G_FALSE
       ,x_return_status     OUT NOCOPY VARCHAR2
       ,x_msg_count         OUT NOCOPY NUMBER
       ,x_msg_data          OUT NOCOPY VARCHAR2
       ,p_okl_csh_order_rec IN okl_csh_order_rec_type
       ,x_okl_csh_order_rec OUT NOCOPY okl_csh_order_rec_type
                        );

PROCEDURE insert_row (p_api_version  IN NUMBER
       ,p_init_msg_list     IN VARCHAR2 DEFAULT Okc_Api.G_FALSE
       ,x_return_status     OUT NOCOPY VARCHAR2
       ,x_msg_count         OUT NOCOPY NUMBER
       ,x_msg_data          OUT NOCOPY VARCHAR2
       ,p_okl_csh_order_tbl IN okl_csh_order_tbl_type
       ,x_okl_csh_order_tbl OUT NOCOPY okl_csh_order_tbl_type
                        );

PROCEDURE update_row (p_api_version  IN NUMBER
       ,p_init_msg_list     IN VARCHAR2 DEFAULT Okc_Api.G_FALSE
       ,x_return_status     OUT NOCOPY VARCHAR2
       ,x_msg_count         OUT NOCOPY NUMBER
       ,x_msg_data          OUT NOCOPY VARCHAR2
       ,p_okl_csh_order_rec IN okl_csh_order_rec_type
       ,x_okl_csh_order_rec OUT NOCOPY okl_csh_order_rec_type
                        );

PROCEDURE update_row (p_api_version  IN NUMBER
       ,p_init_msg_list     IN VARCHAR2 DEFAULT Okc_Api.G_FALSE
       ,x_return_status     OUT NOCOPY VARCHAR2
       ,x_msg_count         OUT NOCOPY NUMBER
       ,x_msg_data          OUT NOCOPY VARCHAR2
       ,p_okl_csh_order_tbl IN okl_csh_order_tbl_type
       ,x_okl_csh_order_tbl OUT NOCOPY okl_csh_order_tbl_type
                        );

PROCEDURE delete_row (p_api_version  IN NUMBER
       ,p_init_msg_list     IN VARCHAR2 DEFAULT Okc_Api.G_FALSE
       ,x_return_status     OUT NOCOPY VARCHAR2
       ,x_msg_count         OUT NOCOPY NUMBER
       ,x_msg_data          OUT NOCOPY VARCHAR2
       ,p_okl_csh_order_rec IN okl_csh_order_rec_type
                        );

PROCEDURE delete_row (p_api_version  IN NUMBER
       ,p_init_msg_list     IN VARCHAR2 DEFAULT Okc_Api.G_FALSE
       ,x_return_status     OUT NOCOPY VARCHAR2
       ,x_msg_count         OUT NOCOPY NUMBER
       ,x_msg_data          OUT NOCOPY VARCHAR2
       ,p_okl_csh_order_tbl IN okl_csh_order_tbl_type
                        );

END OKL_CSH_ORDER_SEQ_Pvt;

/
