--------------------------------------------------------
--  DDL for Package FV_TREASURY_PAYMENTS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."FV_TREASURY_PAYMENTS_PKG" AUTHID CURRENT_USER AS
-- $Header: FVAPPAYS.pls 120.1 2006/03/24 16:20:40 spothana noship $
PROCEDURE Main(X_errbuf        OUT NOCOPY VARCHAR2
              ,X_retcode       OUT NOCOPY VARCHAR2
              ,P_treas_conf_id IN  VARCHAR2
              ,P_button_name   IN  VARCHAR2);

PROCEDURE Void(X_errbuf        OUT NOCOPY VARCHAR2
              ,X_retcode       OUT NOCOPY VARCHAR2);

END FV_TREASURY_PAYMENTS_PKG;

 

/
