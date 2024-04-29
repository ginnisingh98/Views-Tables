--------------------------------------------------------
--  DDL for Package OKL_CURE_RECON_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OKL_CURE_RECON_PVT" AUTHID CURRENT_USER AS
/* $Header: OKLRRCOS.pls 115.7 2003/09/24 14:35:00 jsanju noship $ */

  ---------------------------------------------------------------------------
  -- GLOBAL MESSAGE CONSTANTS
  ---------------------------------------------------------------------------
  G_FND_APP			      CONSTANT VARCHAR2(200) := okl_api.G_FND_APP;
  G_REQUIRED_VALUE		  CONSTANT VARCHAR2(200) := 'OKL_REQUIRED_VALUE';
  G_INVALID_VALUE		  CONSTANT VARCHAR2(200) := okl_api.G_INVALID_VALUE;
  G_COL_NAME_TOKEN		  CONSTANT VARCHAR2(200) := 'COL_NAME';
  G_COL_NAME1_TOKEN		  CONSTANT VARCHAR2(200) := 'COL_NAME1';
  G_COL_NAME2_TOKEN		  CONSTANT VARCHAR2(200) := 'COL_NAME2';
  G_PARENT_TABLE_TOKEN	  CONSTANT VARCHAR2(200) := 'PARENT_TABLE';
  G_UNEXPECTED_ERROR	  CONSTANT VARCHAR2(200) := 'OKL_UNEXPECTED_ERROR';
  G_SQLERRM_TOKEN         CONSTANT VARCHAR2(200) := 'SQLERRM';
  G_SQLCODE_TOKEN         CONSTANT VARCHAR2(200) := 'SQLCODE';
  ---------------------------------------------------------------------------
  -- GLOBAL VARIABLES
  ---------------------------------------------------------------------------
  G_PKG_NAME			CONSTANT VARCHAR2(200) := 'OKL_CURE_RECON_PVT';
  G_APP_NAME			CONSTANT VARCHAR2(3)   := 'OKL';

   ---------------------------------------------------------------------------
  -- GLOBAL EXCEPTION
  ---------------------------------------------------------------------------
  G_EXCEPTION_HALT_VALIDATION	EXCEPTION;



  TYPE cure_amount_rec IS RECORD
  (
    cam_id		          NUMBER,
    negotiated_amount     NUMBER,
    process               VARCHAR2(50)
  );

  TYPE cure_amount_tbl IS TABLE OF cure_amount_rec INDEX BY BINARY_INTEGER;


PROCEDURE UPDATE_CURE_INVOICE (
                               p_api_version   IN NUMBER,
                               p_init_msg_list IN VARCHAR2 DEFAULT fnd_api.G_FALSE,
                               p_commit        IN VARCHAR2 DEFAULT fnd_api.G_FALSE,
                               p_report_id     IN NUMBER,
                               p_invoice_date  IN DATE,
                               p_cam_tbl       IN cure_amount_tbl,
                               p_operation     IN VARCHAR2,
                               x_return_status OUT NOCOPY VARCHAR2,
                               x_msg_count     OUT NOCOPY NUMBER,
                               x_msg_data      OUT NOCOPY VARCHAR2) ;



END OKL_CURE_RECON_PVT;


 

/
