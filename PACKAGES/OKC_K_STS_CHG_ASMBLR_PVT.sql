--------------------------------------------------------
--  DDL for Package OKC_K_STS_CHG_ASMBLR_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OKC_K_STS_CHG_ASMBLR_PVT" AUTHID CURRENT_USER AS
/*$Header: OKCRHSCS.pls 120.0 2005/05/25 19:10:14 appldev noship $ */

subtype control_rec_type is okc_util.okc_control_rec_type;

g_pkg_name CONSTANT varchar2(100) := 'OKC_K_STS_CHG_ASMBLR_PVT';

-- action assembler for contract status change action
PROCEDURE acn_assemble(
  p_api_version          IN NUMBER,
  p_init_msg_list        IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
  x_return_status        OUT NOCOPY VARCHAR2,
  x_msg_count            OUT NOCOPY NUMBER,
  x_msg_data             OUT NOCOPY VARCHAR2,
  p_k_id		 IN NUMBER,
  p_k_number		 IN VARCHAR2,
  p_k_nbr_mod		 IN VARCHAR2,
  p_k_cur_sts_code       IN VARCHAR2,
  p_k_cur_sts_type       IN VARCHAR2,
  p_k_pre_sts_code       IN VARCHAR2,
  p_k_pre_sts_type       IN VARCHAR2,
  p_k_source_system_code IN VARCHAR2
  );

PROCEDURE acn_assemble(
  p_api_version          IN NUMBER,
  p_init_msg_list        IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
  x_return_status        OUT NOCOPY VARCHAR2,
  x_msg_count            OUT NOCOPY NUMBER,
  x_msg_data             OUT NOCOPY VARCHAR2,
  p_k_id		 IN NUMBER,
  p_k_number		 IN VARCHAR2,
  p_k_nbr_mod		 IN VARCHAR2,
  p_k_cur_sts_code       IN VARCHAR2,
  p_k_cur_sts_type       IN VARCHAR2,
  p_k_pre_sts_code       IN VARCHAR2,
  p_k_pre_sts_type       IN VARCHAR2,
  p_k_source_system_code IN VARCHAR2,
  p_control_rec		 IN control_rec_type
  );

END OKC_K_STS_CHG_ASMBLR_PVT;

 

/
