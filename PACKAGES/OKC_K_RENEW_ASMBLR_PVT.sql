--------------------------------------------------------
--  DDL for Package OKC_K_RENEW_ASMBLR_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OKC_K_RENEW_ASMBLR_PVT" AUTHID CURRENT_USER AS
/*$Header: OKCRKRAS.pls 120.0 2005/05/26 09:41:59 appldev noship $ */

g_pkg_name CONSTANT varchar2(100) := 'OKC_K_RENEW_ASMBLR_PVT';


PROCEDURE acn_assemble(
  p_api_version       IN NUMBER,
  p_init_msg_list     IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
  x_return_status     OUT NOCOPY VARCHAR2,
  x_msg_count         OUT NOCOPY NUMBER,
  x_msg_data          OUT NOCOPY VARCHAR2,

  p_k_class		IN VARCHAR2,
  p_k_nbr_mod		IN VARCHAR2,
  p_k_number		IN VARCHAR2,
  p_k_subclass		IN VARCHAR2,
  p_k_status_code		IN VARCHAR2,
  p_estimated_amount		IN NUMBER,
  p_new_k_end_date		IN DATE,
  p_new_k_id		IN NUMBER,
  p_new_k_start_date		IN DATE,
  p_original_k_end_date		IN DATE,
  p_original_kid		IN NUMBER,
  p_original_k_start_date		IN DATE  );

END OKC_K_RENEW_ASMBLR_PVT;

 

/
