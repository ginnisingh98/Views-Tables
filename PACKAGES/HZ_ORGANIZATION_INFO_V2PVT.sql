--------------------------------------------------------
--  DDL for Package HZ_ORGANIZATION_INFO_V2PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."HZ_ORGANIZATION_INFO_V2PVT" AUTHID CURRENT_USER AS
/*$Header: ARHORI1S.pls 120.1 2005/06/16 21:12:56 jhuang noship $ */

--------------------------------------
-- declaration of oublic procedures and funcations
--------------------------------------

PROCEDURE v2_create_financial_report (
    p_financial_report_rec        IN      HZ_ORG_INFO_PUB.FINANCIAL_REPORTS_REC_TYPE,
    x_return_status               IN OUT  NOCOPY VARCHAR2,
    x_financial_report_id            OUT  NOCOPY NUMBER
);

PROCEDURE v2_update_financial_report (
    p_financial_report_rec        IN      HZ_ORG_INFO_PUB.FINANCIAL_REPORTS_REC_TYPE,
    p_last_update_date            IN OUT  NOCOPY DATE,
    x_return_status               IN OUT  NOCOPY VARCHAR2
);

PROCEDURE v2_create_financial_number (
    p_financial_number_rec        IN      HZ_ORG_INFO_PUB.FINANCIAL_NUMBERS_REC_TYPE,
    x_return_status               IN OUT  NOCOPY VARCHAR2,
    x_financial_number_id            OUT  NOCOPY NUMBER
);

PROCEDURE v2_update_financial_number (
    p_financial_number_rec        IN      HZ_ORG_INFO_PUB.FINANCIAL_NUMBERS_REC_TYPE,
    p_last_update_date            IN OUT  NOCOPY DATE,
    x_return_status               IN OUT  NOCOPY VARCHAR2
);

END HZ_ORGANIZATION_INFO_V2PVT;

 

/
