--------------------------------------------------------
--  DDL for Package OKL_CURE_REQUEST_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OKL_CURE_REQUEST_PVT" AUTHID CURRENT_USER AS
/* $Header: OKLRREQS.pls 115.7 2003/10/10 19:00:37 jsanju noship $ */

  ---------------------------------------------------------------------------
  -- GLOBAL MESSAGE CONSTANTS
  ---------------------------------------------------------------------------
  G_FND_APP			      CONSTANT VARCHAR2(200) := okl_api.G_FND_APP;
  G_REQUIRED_VALUE		CONSTANT VARCHAR2(200) := 'OKL_REQUIRED_VALUE';
  G_INVALID_VALUE		      CONSTANT VARCHAR2(200) := okl_api.G_INVALID_VALUE;
  G_COL_NAME_TOKEN		CONSTANT VARCHAR2(200) := 'COL_NAME';
  G_COL_NAME1_TOKEN		CONSTANT VARCHAR2(200) := 'COL_NAME1';
  G_COL_NAME2_TOKEN		CONSTANT VARCHAR2(200) := 'COL_NAME2';
  G_PARENT_TABLE_TOKEN		CONSTANT VARCHAR2(200) := 'PARENT_TABLE';
  G_UNEXPECTED_ERROR		CONSTANT VARCHAR2(200) := 'OKL_UNEXPECTED_ERROR';
  G_SQLERRM_TOKEN             CONSTANT VARCHAR2(200) := 'SQLERRM';
  G_SQLCODE_TOKEN             CONSTANT VARCHAR2(200) := 'SQLCODE';
  G_PROCESS_SUCCESS           CONSTANT VARCHAR2(200) := 'OKL_PROCESS_SUCCESSFUL';
  ---------------------------------------------------------------------------
  -- GLOBAL VARIABLES
  ---------------------------------------------------------------------------
  G_PKG_NAME			CONSTANT VARCHAR2(200) := 'OKL_CURE_REQUEST_PVT';
  G_APP_NAME			CONSTANT VARCHAR2(3)   := 'OKL';
  G_CONFIRM_SUBMIT            CONSTANT VARCHAR2(200) := 'OKL_CONFIRM_SUBMIT';
  G_INVALID_CURE_REQUEST      CONSTANT VARCHAR2(200) := 'OKL_INVALID_CURE_REQUEST';
  G_ERROR_GETTING_OBJECT_VERSION
                              CONSTANT VARCHAR2(200) := 'ERROR_GETTING_OBJECT_VERSION';
  ---------------------------------------------------------------------------
  -- GLOBAL EXCEPTION
  ---------------------------------------------------------------------------
  G_EXCEPTION_HALT_VALIDATION	EXCEPTION;
  G_MISSING_EMAIL_ID EXCEPTION;
  G_MISSING_TEMPLATE EXCEPTION;
  ---------------------------------------------------------------------------
  -- Procedures and Functions
  ---------------------------------------------------------------------------

  /*
  PROCEDURE: SEND_CURE_REQUEST
             This procedure is to send Vendor Cure Requests for
             records generated in OKL_CURE_REPORTS and
             OKL_CURE_REPORT_AMOUNTS table. These records are then
             processed by Send Cure Request procedure via Fulfillment.
  */
  PROCEDURE SEND_CURE_REQUEST
  (
     errbuf               OUT NOCOPY VARCHAR2,
     retcode              OUT NOCOPY NUMBER,
     p_vendor_number      IN  NUMBER DEFAULT NULL,
     p_report_number      IN  VARCHAR2 DEFAULT NULL,
     p_report_date        IN  DATE DEFAULT NULL
  );

END OKL_CURE_REQUEST_PVT;



 

/
