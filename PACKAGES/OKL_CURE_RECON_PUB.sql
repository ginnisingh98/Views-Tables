--------------------------------------------------------
--  DDL for Package OKL_CURE_RECON_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OKL_CURE_RECON_PUB" AUTHID CURRENT_USER AS
/* $Header: OKLPRCOS.pls 115.6 2003/09/24 14:31:04 jsanju noship $ */

  G_PKG_NAME			CONSTANT VARCHAR2(200) := 'OKL_CURE_RECON_PUB';
  G_APP_NAME			CONSTANT VARCHAR2(3)   := 'OKL';
  G_EXCEPTION_HALT_VALIDATION	EXCEPTION;

 subtype cure_amount_tbl is OKL_cure_recon_pvt.cure_amount_tbl;

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
END OKL_CURE_RECON_PUB;

 

/
