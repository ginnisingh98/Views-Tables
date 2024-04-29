--------------------------------------------------------
--  DDL for Package OKL_PAYMENT_APPLICATION_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OKL_PAYMENT_APPLICATION_PVT" AUTHID CURRENT_USER AS
/* $Header: OKLRPYAS.pls 120.4 2005/06/27 23:40:36 cklee noship $*/

  G_RULE_PRESENT_ERROR       CONSTANT VARCHAR2(1000) := 'OKL_LLA_RULE_PRESENT_ERROR';
  G_RO_PYT_PRESENT_ERR       CONSTANT VARCHAR2(1000) := 'OKL_LLA_RO_PYT_APPLIED_ERROR';
  G_CAPITAL_AMT_ERROR        CONSTANT VARCHAR2(1000) := 'OKL_LLA_CAPITAL_AMT_ERROR';
  G_NO_HEADER_PAYMENT        CONSTANT VARCHAR2(1000) := 'OKL_LLA_NO_HEADER_PAYMENT';
  G_UNEXPECTED_ERROR         CONSTANT VARCHAR2(1000) := 'OKL_UNEXPECTED_ERROR';
  G_INVALID_VALUE            CONSTANT VARCHAR2(1000) := 'OKL_INVALID_VALUE';
  G_LLA_CHR_ID               CONSTANT VARCHAR2(1000) := 'OKL_LLA_CHR_ID';

  PROCEDURE apply_payment(
                          p_api_version   IN  NUMBER,
                          p_init_msg_list IN  VARCHAR2 DEFAULT OKC_API.G_FALSE,
                          x_return_status OUT NOCOPY VARCHAR2,
                          x_msg_count     OUT NOCOPY NUMBER,
                          x_msg_data      OUT NOCOPY VARCHAR2,
                          p_chr_id        IN  OKC_K_HEADERS_V.ID%TYPE,
                          p_stream_id     IN  OKC_RULES_V.OBJECT1_ID1%TYPE
                         );

  PROCEDURE apply_propery_tax_payment(
                          p_api_version   IN  NUMBER,
                          p_init_msg_list IN  VARCHAR2 DEFAULT OKC_API.G_FALSE,
                          x_return_status OUT NOCOPY VARCHAR2,
                          x_msg_count     OUT NOCOPY NUMBER,
                          x_msg_data      OUT NOCOPY VARCHAR2,
                          p_chr_id        IN  OKC_K_HEADERS_V.ID%TYPE,
                          p_stream_id     IN  OKC_RULES_V.OBJECT1_ID1%TYPE
                         );

  PROCEDURE apply_rollover_fee_payment(
                          p_api_version   IN  NUMBER,
                          p_init_msg_list IN  VARCHAR2 DEFAULT OKC_API.G_FALSE,
                          x_return_status OUT NOCOPY VARCHAR2,
                          x_msg_count     OUT NOCOPY NUMBER,
                          x_msg_data      OUT NOCOPY VARCHAR2,
                          p_chr_id        IN  OKC_K_HEADERS_V.ID%TYPE,
                          p_kle_id        IN  OKC_K_LINES_B.ID%TYPE,-- Rollover Fee Top Line
                          p_stream_id     IN  OKC_RULES_V.OBJECT1_ID1%TYPE
                         );
--start: cklee: okl.h
  PROCEDURE apply_eligible_fee_payment(
                          p_api_version   IN  NUMBER,
                          p_init_msg_list IN  VARCHAR2 DEFAULT OKC_API.G_FALSE,
                          x_return_status OUT NOCOPY VARCHAR2,
                          x_msg_count     OUT NOCOPY NUMBER,
                          x_msg_data      OUT NOCOPY VARCHAR2,
                          p_chr_id        IN  OKC_K_HEADERS_V.ID%TYPE,
                          p_kle_id        IN  OKC_K_LINES_B.ID%TYPE,-- Fee Top Line
                          p_stream_id     IN  OKC_RULES_V.OBJECT1_ID1%TYPE
                         );
--end: cklee: okl.h

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

  PROCEDURE Report_Error(
                         x_msg_count OUT NOCOPY NUMBER,
                         x_msg_data  OUT NOCOPY VARCHAR2
                        );

END OKL_PAYMENT_APPLICATION_PVT;

 

/
