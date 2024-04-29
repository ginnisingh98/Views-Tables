--------------------------------------------------------
--  DDL for Package OKC_KEXP_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OKC_KEXP_PVT" AUTHID CURRENT_USER AS
/* $Header: OKCRKEXS.pls 120.0 2005/05/25 19:38:05 appldev noship $ */

  ---------------------------------------------------------------------------
  -- Global Constants and Variables
  ---------------------------------------------------------------------------
  G_FND_APP           CONSTANT  VARCHAR2(200) :=  OKC_API.G_FND_APP;
  G_PKG_NAME          CONSTANT  VARCHAR2(200) := 'OKC_KEXP_REPORT_LOAD';
  G_APP_NAME          CONSTANT  VARCHAR2(3)   :=  OKC_API.G_APP_NAME;
  G_UNEXPECTED_ERROR  CONSTANT  VARCHAR2(200) := 'OKC_CONTRACTS_UNEXPECTED_ERROR';
  G_SQLERRM_TOKEN     CONSTANT  VARCHAR2(200) := 'SQLerrm';
  G_SQLCODE_TOKEN     CONSTANT  VARCHAR2(200) := 'SQLcode';
  G_VIEW              CONSTANT  VARCHAR2(30)  := 'OKC_KEXP_REPORT_V';
  G_DEF_WHERE         CONSTANT  VARCHAR2(30)  := ' CONTRACT_NUMBER IS NULL';

  ---------------------------------------------------------------------------
  -- Procedures and Functions
  ---------------------------------------------------------------------------
  PROCEDURE load_ksrch_rows(
    p_ksearch_where_clause         IN  VARCHAR2 DEFAULT G_DEF_WHERE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_report_id                    OUT NOCOPY NUMBER   );

  PROCEDURE delete_ksrch_rows(
    p_from_date                    IN  DATE     DEFAULT NULL,
    p_to_date                      IN  DATE     DEFAULT NULL,
    x_return_status                OUT NOCOPY VARCHAR2 );

  FUNCTION get_salesrep_name (     p_id1  IN  VARCHAR2,
							p_id2  IN  VARCHAR2  )
                             RETURN VARCHAR2;

END okc_kexp_pvt;

 

/
