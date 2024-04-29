--------------------------------------------------------
--  DDL for Package OKL_PAYMENT_SPLIT_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OKL_PAYMENT_SPLIT_PUB" AUTHID CURRENT_USER AS
/* $Header: OKLPPMSS.pls 115.1 2003/11/12 22:26:19 avsingh noship $*/

  PROCEDURE generate_line_payments(
                          p_api_version   IN  NUMBER,
                          p_init_msg_list IN  VARCHAR2 DEFAULT OKC_API.G_FALSE,
                          x_return_status OUT NOCOPY VARCHAR2,
                          x_msg_count     OUT NOCOPY NUMBER,
                          x_msg_data      OUT NOCOPY VARCHAR2,
                          p_chr_id        IN  OKC_K_HEADERS_V.ID%TYPE,
                          p_payment_type  IN  VARCHAR2,
                          p_amount        IN  NUMBER,
                          p_start_date    IN  DATE,
                          p_period        IN  NUMBER,
                          p_frequency     IN  VARCHAR2,
                          x_strm_tbl      OUT NOCOPY okl_mass_rebook_pub.strm_lalevl_tbl_type
                         );

END OKL_PAYMENT_SPLIT_PUB;

 

/
