--------------------------------------------------------
--  DDL for Package OKC_K_SIGN_ASMBLR_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OKC_K_SIGN_ASMBLR_PVT" AUTHID CURRENT_USER AS
/* $Header: OKCRKSAS.pls 120.0 2005/05/25 19:36:29 appldev noship $ */

  ----------------------------------------------------------------------------
  -- PROCEDURE acn_assemble
  ----------------------------------------------------------------------------
-- checkes if the action is enabled. Called by all action assemblers
-- bug#4033775
FUNCTION isActionEnabled (p_correlation  IN VARCHAR2)
RETURN VARCHAR2;

PROCEDURE acn_assemble(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_contract_id                  IN NUMBER)
  ;
END OKC_K_SIGN_ASMBLR_PVT;

 

/
