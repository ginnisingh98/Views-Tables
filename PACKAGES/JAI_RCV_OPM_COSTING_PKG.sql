--------------------------------------------------------
--  DDL for Package JAI_RCV_OPM_COSTING_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."JAI_RCV_OPM_COSTING_PKG" AUTHID CURRENT_USER AS
/* $Header: jai_rcv_opm_cst.pls 120.2.12010000.1 2008/11/21 04:57:19 mbremkum noship $ */

  PROCEDURE opm_cost_adjust( errbuf             OUT NOCOPY VARCHAR2,
                             retcode            OUT NOCOPY NUMBER,
                             p_organization_id  IN NUMBER   ,
                             p_start_date       IN VARCHAR2 ,
                             p_end_date         IN VARCHAR2 );

END jai_rcv_opm_costing_pkg;

/
