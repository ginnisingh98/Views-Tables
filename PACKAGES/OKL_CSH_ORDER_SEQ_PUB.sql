--------------------------------------------------------
--  DDL for Package OKL_CSH_ORDER_SEQ_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OKL_CSH_ORDER_SEQ_PUB" AUTHID CURRENT_USER AS
/* $Header: OKLPSATS.pls 115.4 2002/02/12 14:30:59 pkm ship        $ */


  ---------------------------------------------------------------------------
  -- GLOBAL DATASTRUCTURES
  ---------------------------------------------------------------------------

 SUBTYPE stav_rec_type IS okl_csh_order_seq_pvt.stav_rec_type;
 SUBTYPE stav_tbl_type IS okl_csh_order_seq_pvt.stav_tbl_type;

 SUBTYPE okl_csh_order_rec_type IS okl_csh_order_seq_pvt.okl_csh_order_rec_type;
 SUBTYPE okl_csh_order_tbl_type IS okl_csh_order_seq_pvt.okl_csh_order_tbl_type;

  ---------------------------------------------------------------------------
  -- GLOBAL VARIABLES
  ---------------------------------------------------------------------------
G_PKG_NAME             CONSTANT VARCHAR2(200) := 'OKL_CSH_ORDER_SEQ_PUB';
  ---------------------------------------------------------------------------
  -- Procedures and Functions
  ---------------------------------------------------------------------------

/*
PROCEDURE insert_order_sequence (p_api_version  IN NUMBER
       ,p_init_msg_list     IN VARCHAR2 DEFAULT Okc_Api.G_FALSE
       ,x_return_status     OUT NOCOPY VARCHAR2
       ,x_msg_count         OUT NOCOPY NUMBER
       ,x_msg_data          OUT NOCOPY VARCHAR2
       ,p_okl_csh_order_rec IN okl_csh_order_rec_type
       ,x_okl_csh_order_rec OUT NOCOPY okl_csh_order_rec_type);

PROCEDURE insert_order_sequence (p_api_version  IN NUMBER
       ,p_init_msg_list     IN VARCHAR2 DEFAULT Okc_Api.G_FALSE
       ,x_return_status     OUT NOCOPY VARCHAR2
       ,x_msg_count         OUT NOCOPY NUMBER
       ,x_msg_data          OUT NOCOPY VARCHAR2
       ,p_okl_csh_order_tbl IN okl_csh_order_tbl_type
       ,x_okl_csh_order_tbl OUT NOCOPY okl_csh_order_tbl_type);
*/


PROCEDURE update_order_sequence (p_api_version  IN NUMBER
       ,p_init_msg_list      IN VARCHAR2 DEFAULT Okc_Api.G_FALSE
       ,x_return_status     OUT NOCOPY VARCHAR2
       ,x_msg_count         OUT NOCOPY NUMBER
       ,x_msg_data          OUT NOCOPY VARCHAR2
       ,p_okl_csh_order_rec IN okl_csh_order_rec_type
       ,x_okl_csh_order_rec OUT NOCOPY okl_csh_order_rec_type);

PROCEDURE update_order_sequence (p_api_version  IN NUMBER
       ,p_init_msg_list     IN VARCHAR2 DEFAULT Okc_Api.G_FALSE
       ,x_return_status     OUT NOCOPY VARCHAR2
       ,x_msg_count         OUT NOCOPY NUMBER
       ,x_msg_data          OUT NOCOPY VARCHAR2
       ,p_okl_csh_order_tbl IN okl_csh_order_tbl_type
       ,x_okl_csh_order_tbl OUT NOCOPY okl_csh_order_tbl_type);

END OKL_CSH_ORDER_SEQ_PUB;

 

/
