--------------------------------------------------------
--  DDL for Package OKC_EXP_DATE_ASMBLR_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OKC_EXP_DATE_ASMBLR_PVT" AUTHID CURRENT_USER AS
/* $Header: OKCREDAS.pls 120.0 2005/05/25 19:06:53 appldev noship $ */

-- GLOBAL CONSTANTS
  ----------------------------------------------------------------------------
  g_pkg_name     		CONSTANT varchar2(100) := 'OKC_EXP_DATE_ASMBLR_PVT';

  ----------------------------------------------------------------------------
  -- PROCEDURE exp_date_assemble
  ----------------------------------------------------------------------------
   PROCEDURE exp_date_assemble(
    p_api_version	IN NUMBER,
    p_init_msg_list     IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status     OUT NOCOPY VARCHAR2,
    x_msg_count         OUT NOCOPY NUMBER,
    x_msg_data          OUT NOCOPY VARCHAR2,
    p_cnh_id            IN okc_condition_headers_b.id%TYPE,
    p_dnz_chr_id        IN okc_condition_headers_b.dnz_chr_id%TYPE DEFAULT NULL,
    p_cnh_variance      IN okc_condition_headers_b.cnh_variance%TYPE,
    p_before_after      IN okc_condition_headers_b.before_after%TYPE,
    p_last_rundate      IN okc_condition_headers_b.last_rundate%TYPE);

  ----------------------------------------------------------------------------
  -- PROCEDURE exp_lines_date_assemble
  ----------------------------------------------------------------------------
   PROCEDURE exp_lines_date_assemble(
    p_api_version       IN NUMBER,
    p_init_msg_list     IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status     OUT NOCOPY VARCHAR2,
    x_msg_count         OUT NOCOPY NUMBER,
    x_msg_data          OUT NOCOPY VARCHAR2,
    p_cnh_id            IN okc_condition_headers_b.id%TYPE,
    p_dnz_chr_id        IN okc_condition_headers_b.dnz_chr_id%TYPE DEFAULT NULL,
    p_cnh_variance      IN okc_condition_headers_b.cnh_variance%TYPE,
    p_before_after      IN okc_condition_headers_b.before_after%TYPE,
    p_last_rundate      IN okc_condition_headers_b.last_rundate%TYPE);

END OKC_EXP_DATE_ASMBLR_PVT;

 

/
