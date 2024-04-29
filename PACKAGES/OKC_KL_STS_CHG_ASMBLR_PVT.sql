--------------------------------------------------------
--  DDL for Package OKC_KL_STS_CHG_ASMBLR_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OKC_KL_STS_CHG_ASMBLR_PVT" AUTHID CURRENT_USER AS
/*$Header: OKCRLSCS.pls 120.0 2005/05/25 18:21:28 appldev noship $ */

g_pkg_name CONSTANT varchar2(100) := 'OKC_KL_STS_CHG_ASMBLR_PVT';

-- action assembler for contract line status change
PROCEDURE acn_assemble(
  p_api_version           IN NUMBER,
  p_init_msg_list         IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
  x_return_status         OUT NOCOPY VARCHAR2,
  x_msg_count             OUT NOCOPY NUMBER,
  x_msg_data              OUT NOCOPY VARCHAR2,
  p_k_id		  IN NUMBER,
  p_kl_id		  IN NUMBER,
  p_k_number		  IN VARCHAR2,
  p_k_nbr_mod		  IN VARCHAR2,
  p_kl_number		  IN VARCHAR2,
  p_kl_cur_sts_code       IN VARCHAR2,
  p_kl_cur_sts_type       IN VARCHAR2,
  p_kl_pre_sts_code       IN VARCHAR2,
  p_kl_pre_sts_type       IN VARCHAR2,
  p_kl_source_system_code IN VARCHAR2
  );

END OKC_KL_STS_CHG_ASMBLR_PVT;

 

/
