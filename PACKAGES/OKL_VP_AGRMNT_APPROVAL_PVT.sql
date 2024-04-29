--------------------------------------------------------
--  DDL for Package OKL_VP_AGRMNT_APPROVAL_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OKL_VP_AGRMNT_APPROVAL_PVT" AUTHID CURRENT_USER AS
/* $Header: OKLRVAAS.pls 120.0 2005/07/28 11:43:37 sjalasut noship $ */
  ---------------------------------------------------------------------------
  -- GLOBAL VARIABLES
  ---------------------------------------------------------------------------
  G_PKG_NAME       CONSTANT VARCHAR2(200) := 'OKL_VP_AGRMNT_APPROVAL_PVT';
  G_APP_NAME       CONSTANT VARCHAR2(3)   := OKL_API.G_APP_NAME;
  G_API_TYPE       CONSTANT VARCHAR2(30)  := '_PVT';

  -------------------------------------------------------------------------------
  -- PROCEDURE submit_oa_for_approval
  -------------------------------------------------------------------------------
  -- Start of comments
  --
  -- Procedure Name  : submit_oa_for_approval
  -- Description     : procedure raises business events for operating agreement approval
  -- Parameters      : IN p_chr_id agreement id
  --                   OUT x_status_code the effective status of the agreement
  -- Version         : 1.0
  -- History         : May 18, 05 SJALASUT created
  -- End of comments

  PROCEDURE submit_oa_for_approval(p_api_version   IN NUMBER
                                  ,p_init_msg_list IN VARCHAR2
                                  ,x_return_status OUT NOCOPY VARCHAR2
                                  ,x_msg_count     OUT NOCOPY NUMBER
                                  ,x_msg_data      OUT NOCOPY VARCHAR2
                                  ,p_chr_id        IN okc_k_headers_b.id%TYPE
                                  ,x_status_code   OUT NOCOPY okc_k_headers_b.scs_code%TYPE
                                  );

  -------------------------------------------------------------------------------
  -- PROCEDURE submit_pa_for_approval
  -------------------------------------------------------------------------------
  -- Start of comments
  --
  -- Procedure Name  : submit_pa_for_approval
  -- Description     : procedure raises business events for program agreement approval
  -- Parameters      : IN p_chr_id agreement id
  --                   OUT x_status_code the effective status of the agreement
  -- Version         : 1.0
  -- History         : May 18, 05 SJALASUT created
  -- End of comments

  PROCEDURE submit_pa_for_approval(p_api_version   IN NUMBER
                                  ,p_init_msg_list IN VARCHAR2
                                  ,x_return_status OUT NOCOPY VARCHAR2
                                  ,x_msg_count     OUT NOCOPY NUMBER
                                  ,x_msg_data      OUT NOCOPY VARCHAR2
                                  ,p_chr_id        IN okc_k_headers_b.id%TYPE
                                  ,x_status_code   OUT NOCOPY okc_k_headers_b.scs_code%TYPE
                                  );

END okl_vp_agrmnt_approval_pvt;

 

/
