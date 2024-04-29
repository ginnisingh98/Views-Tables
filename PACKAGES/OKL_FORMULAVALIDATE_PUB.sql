--------------------------------------------------------
--  DDL for Package OKL_FORMULAVALIDATE_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OKL_FORMULAVALIDATE_PUB" AUTHID CURRENT_USER AS
  /* $Header: OKLPVALS.pls 115.2 2002/02/06 20:31:04 pkm ship       $ */

  ---------------------------------------------------------------------------
  -- GLOBAL VARIABLES
  ---------------------------------------------------------------------------
  G_UNEXPECTED_ERROR          CONSTANT VARCHAR2(200) := 'OKL_CONTRACTS_UNEXPECTED_ERROR';
  G_SQLERRM_TOKEN             CONSTANT VARCHAR2(200) := 'OKL_SQLERRM';
  G_SQLCODE_TOKEN             CONSTANT VARCHAR2(200) := 'OKL_SQLCODE';

  G_APP_NAME		      CONSTANT VARCHAR2(3)   :=  OKL_API.G_APP_NAME;
  G_PKG_NAME                  CONSTANT VARCHAR2(30)  := 'OKL_FORMULAVALIDATE_PUB';


  G_EXCEPTION_HALT_PROCESSING EXCEPTION;


  PROCEDURE VAL_ValidateFormula(p_api_version   IN  NUMBER
                   ,p_init_msg_list IN  VARCHAR2 DEFAULT OKC_API.G_FALSE
                   ,x_return_status OUT NOCOPY VARCHAR2
                   ,x_msg_count     OUT NOCOPY NUMBER
                   ,x_msg_data      OUT NOCOPY VARCHAR2
                   ,x_validate_status OUT NOCOPY VARCHAR2
                   ,p_fma_id  IN  okl_formulae_v.id%TYPE
                   ,p_cgr_id  IN  okl_context_groups_v.id%TYPE );


END OKL_FORMULAVALIDATE_PUB;

 

/
