--------------------------------------------------------
--  DDL for Package OKL_CURE_REQUEST_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OKL_CURE_REQUEST_PUB" AUTHID CURRENT_USER AS
/* $Header: OKLPREQS.pls 115.6 2003/10/10 18:35:06 jsanju noship $ */

  ---------------------------------------------------------------------------
  -- GLOBAL VARIABLES
  ---------------------------------------------------------------------------
  G_PKG_NAME			CONSTANT VARCHAR2(200) := 'OKL_CURE_REQUEST_PUB';
  G_APP_NAME			CONSTANT VARCHAR2(3)   := 'OKL';

   ---------------------------------------------------------------------------
  -- GLOBAL EXCEPTION
  ---------------------------------------------------------------------------
  G_EXCEPTION_HALT_VALIDATION	EXCEPTION;
  ---------------------------------------------------------------------------

  ---------------------------------------------------------------------------
  -- PROCEDURE SEND_CURE_REQUEST_PRE
  ---------------------------------------------------------------------------
  PROCEDURE SEND_CURE_REQUEST
  (
     errbuf               OUT NOCOPY VARCHAR2,
     retcode              OUT NOCOPY NUMBER,
     p_vendor_number      IN  NUMBER DEFAULT NULL,
     p_report_number      IN  VARCHAR2 DEFAULT NULL,
     p_report_date        IN  VARCHAR2 DEFAULT NULL

  );

END OKL_CURE_REQUEST_PUB;


 

/
