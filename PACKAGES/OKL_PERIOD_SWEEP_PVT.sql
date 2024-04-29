--------------------------------------------------------
--  DDL for Package OKL_PERIOD_SWEEP_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OKL_PERIOD_SWEEP_PVT" AUTHID CURRENT_USER AS
/* $Header: OKLRSWPS.pls 120.4.12010000.2 2008/08/07 23:27:02 rkuttiya ship $ */

  G_REQUIRED_VALUE		CONSTANT VARCHAR2(200) := OKC_API.G_REQUIRED_VALUE;
  G_COL_NAME_TOKEN		CONSTANT VARCHAR2(200) := OKC_API.G_COL_NAME_TOKEN;
  G_PKG_NAME     CONSTANT VARCHAR2(30) := 'OKL_PERIOD_SWEEP_PVT';
  G_APP_NAME CONSTANT VARCHAR2(3)      :=  OKL_API.G_APP_NAME;
  G_FILE_NAME    CONSTANT VARCHAR2(12) := 'OKLRGLTB.pls';

  -- Bug 5707866
  --Variables for XML Publisher Report input parameters
  p_period_from      VARCHAR2(15);
  p_period_to          VARCHAR2(15);
  p_run_option        VARCHAR2(80);
  p_representation_code VARCHAR2(20);

PROCEDURE OKL_PERIOD_SWEEP (p_errbuf              OUT NOCOPY VARCHAR2
                           ,p_retcode             OUT NOCOPY NUMBER
                           ,p_representation_code IN VARCHAR2
                           ,p_period_from        IN VARCHAR2
                           ,p_period_to           IN VARCHAR2
                           ,p_run_option          IN VARCHAR2);

PROCEDURE OKL_PERIOD_SWEEP_CON(
                               p_init_msg_list       IN VARCHAR2 DEFAULT Okc_Api.G_FALSE
                              ,x_return_status       OUT NOCOPY VARCHAR2
                              ,x_msg_count           OUT NOCOPY NUMBER
                              ,x_msg_data            OUT NOCOPY VARCHAR2
                              ,p_representation_code IN VARCHAR2 DEFAULT NULL
                              ,p_period_from         IN VARCHAR2
                              ,p_period_to           IN VARCHAR2
                              ,p_run_option          IN VARCHAR2
                              ,x_request_id          OUT NOCOPY NUMBER);

--Bug 5707866  Added new function for XML Publisher Report
FUNCTION BEFOREREPORT RETURN BOOLEAN;

END OKL_PERIOD_SWEEP_PVT;

/
