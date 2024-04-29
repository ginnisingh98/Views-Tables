--------------------------------------------------------
--  DDL for Package PA_AP_XFER_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PA_AP_XFER_PKG" AUTHID CURRENT_USER AS
/* $Header: PAAPXFRS.pls 115.1 2002/11/15 14:50:24 sesingh noship $ */

  PROCEDURE upd_cdl_xfer_status ( p_request_id     IN  NUMBER
                                 ,x_return_status  OUT NOCOPY NUMBER
                                 ,x_error_code     OUT NOCOPY VARCHAR2
                                 ,x_error_stage    OUT NOCOPY NUMBER
                                );

END pa_ap_xfer_pkg;

 

/
