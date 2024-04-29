--------------------------------------------------------
--  DDL for Package OKL_SIMPLE_PRICING_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OKL_SIMPLE_PRICING_PVT" AUTHID CURRENT_USER AS
/* $Header: OKLRSPRS.pls 115.9 2003/02/13 20:34:30 rfedane noship $ */

  G_UNEXPECTED_ERROR           CONSTANT VARCHAR2(200) := 'OKL_CONTRACTS_UNEXP_ERROR';
  G_SQLCODE_TOKEN              CONSTANT VARCHAR2(200) := 'SQLCODE';
  G_SQLERRM_TOKEN              CONSTANT VARCHAR2(200) := 'SQLERRM';
  G_APP_NAME                   CONSTANT VARCHAR2(3)   :=  OKL_API.G_APP_NAME;

  FUNCTION compute_periodic_payment
    (p_term             IN NUMBER
    ,p_frequency        IN NUMBER
    ,p_rate             IN NUMBER
    ,p_principal        IN NUMBER
    ,p_residual_percent IN NUMBER
    ,p_arrears          IN VARCHAR2
    ,x_return_status    OUT NOCOPY VARCHAR2
    ) RETURN NUMBER;

END OKL_SIMPLE_PRICING_PVT;

 

/
