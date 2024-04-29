--------------------------------------------------------
--  DDL for Package OKC_OPPORTUNITY_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OKC_OPPORTUNITY_PVT" AUTHID CURRENT_USER AS
/* $Header: OKCROPPS.pls 120.0 2005/05/25 19:46:58 appldev noship $ */

 -- GLOBAL VARIABLES
  ---------------------------------------------------------------------------
  G_EXCEPTION_HALT_VALIDATION   EXCEPTION;
  G_UNEXPECTED_ERROR            CONSTANT VARCHAR2(200) := 'OKC_CONTRACTS_UNEXP_ERROR';
  G_SQLCODE_TOKEN        	CONSTANT VARCHAR2(200) := 'SQLCODE';
  G_SQLERRM_TOKEN  		CONSTANT VARCHAR2(200) := 'SQLERRM';
  G_PKG_NAME			CONSTANT VARCHAR2(200) := 'OKC_OPPORTUNITY_PVT';
  G_APP_NAME			CONSTANT VARCHAR2(3)   :=  OKC_API.G_APP_NAME;
  ---------------------------------------------------------------------------

  PROCEDURE CREATE_OPPORTUNITY(p_api_version         IN NUMBER DEFAULT 1.0,
                               p_context             IN  VARCHAR2,
                               p_contract_id         IN  NUMBER,
                               p_win_probability     IN  NUMBER,
                               p_expected_close_days IN  NUMBER,
                               x_lead_id             OUT NOCOPY NUMBER,
                               p_init_msg_list       IN VARCHAR2,
                               x_msg_data            OUT NOCOPY VARCHAR2,
                               x_msg_count           OUT NOCOPY NUMBER,
                               x_return_status       OUT NOCOPY VARCHAR2);

  PROCEDURE CREATE_OPP_HEADER(p_api_version         IN NUMBER DEFAULT 1.0,
                              p_context             IN  VARCHAR2,
                              p_contract_id         IN  NUMBER,
                              p_win_probability     IN  NUMBER,
                              p_expected_close_days IN  NUMBER,
                              x_lead_id             OUT NOCOPY NUMBER,
                              p_init_msg_list       IN VARCHAR2,
                              x_msg_data            OUT NOCOPY VARCHAR2,
                              x_msg_count           OUT NOCOPY NUMBER,
                              x_return_status       OUT NOCOPY VARCHAR2);

  PROCEDURE CREATE_OPP_LINES(p_api_version         IN NUMBER DEFAULT 1.0,
                             p_context       IN  VARCHAR2,
                             p_contract_id   IN  NUMBER,
                             p_lead_id       IN  NUMBER,
                             p_init_msg_list IN VARCHAR2,
                             x_msg_data      OUT NOCOPY VARCHAR2,
                             x_msg_count     OUT NOCOPY NUMBER,
                             x_return_status OUT NOCOPY VARCHAR2);

  PROCEDURE IS_OPP_CREATION_ALLOWED(p_context       IN  VARCHAR2,
                                    p_contract_id   IN  NUMBER,
                                    x_return_status OUT NOCOPY VARCHAR2);

  PROCEDURE GET_OPP_DEFAULTS(p_context           IN  VARCHAR2,
                             p_contract_id       IN  NUMBER,
                             x_win_probability   IN  OUT NOCOPY NUMBER,
                             x_closing_date_days IN  OUT NOCOPY NUMBER,
                             x_return_status     OUT NOCOPY VARCHAR2);
END OKC_OPPORTUNITY_PVT;

 

/
