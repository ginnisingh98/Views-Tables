--------------------------------------------------------
--  DDL for Package OKL_PAYMENT_APPLICATION_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OKL_PAYMENT_APPLICATION_PUB" AUTHID CURRENT_USER AS
/* $Header: OKLPPYAS.pls 115.3 2002/05/08 17:01:59 pkm ship     $*/

  PROCEDURE apply_payment(
                          p_api_version   IN  NUMBER,
                          p_init_msg_list IN  VARCHAR2 DEFAULT OKC_API.G_FALSE,
                          x_return_status OUT NOCOPY VARCHAR2,
                          x_msg_count     OUT NOCOPY NUMBER,
                          x_msg_data      OUT NOCOPY VARCHAR2,
                          p_chr_id        IN  OKC_K_HEADERS_V.ID%TYPE,
                          p_stream_id     IN  OKC_RULES_V.OBJECT1_ID1%TYPE
                         );

  PROCEDURE delete_payment(
                           p_api_version   IN  NUMBER,
                           p_init_msg_list IN  VARCHAR2 DEFAULT OKC_API.G_FALSE,
                           x_return_status OUT NOCOPY VARCHAR2,
                           x_msg_count     OUT NOCOPY NUMBER,
                           x_msg_data      OUT NOCOPY VARCHAR2,
                           p_chr_id        IN  OKC_K_HEADERS_V.ID%TYPE,
                           p_rgp_id        IN  OKC_RULE_GROUPS_V.ID%TYPE,
                           p_rule_id       IN  OKC_RULES_V.ID%TYPE
                          );

END OKL_PAYMENT_APPLICATION_PUB;

 

/
