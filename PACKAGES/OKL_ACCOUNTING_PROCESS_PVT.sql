--------------------------------------------------------
--  DDL for Package OKL_ACCOUNTING_PROCESS_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OKL_ACCOUNTING_PROCESS_PVT" AUTHID CURRENT_USER AS
/* $Header: OKLRAECS.pls 120.2 2005/10/14 06:46:37 gboomina noship $ */

SUBTYPE tabv_rec_type  IS OKL_TRNS_ACC_DSTRS_PUB.tabv_rec_type;
SUBTYPE tabv_tbl_type  IS OKL_TRNS_ACC_DSTRS_PUB.tabv_tbl_type;

SUBTYPE aetv_rec_type  IS OKL_ACCT_EVENT_PUB.aetv_rec_type;
SUBTYPE aehv_rec_type  IS OKL_ACCT_EVENT_PUB.aehv_rec_type;
SUBTYPE aelv_tbl_type  IS OKL_ACCT_EVENT_PUB.aelv_tbl_type;
--gboomina bug#4648697..added for perf changes
SUBTYPE aehv_tbl_type  IS OKL_ACCT_EVENT_PUB.aehv_tbl_type;


PROCEDURE DO_ACCOUNTING(p_errbuf           OUT NOCOPY  VARCHAR2,
		  	p_retcode          OUT NOCOPY  NUMBER,
                        p_start_date       IN   VARCHAR2,
                        p_end_date         IN   VARCHAR2,
                        --gboomina..added param for bug#4648697
                        p_rpt_format       IN   VARCHAR2);

PROCEDURE DO_ACCOUNTING_CON(p_api_version         IN   NUMBER,
                            p_init_msg_list       IN   VARCHAR2,
                            p_start_date          IN   DATE,
                            p_end_date            IN   DATE,
                            x_return_status       OUT  NOCOPY VARCHAR2,
                            x_msg_count           OUT  NOCOPY NUMBER,
                            x_msg_data            OUT  NOCOPY VARCHAR2,
                            x_request_id          OUT NOCOPY  NUMBER,
                            --gboomina..added param for bug#4648697
                            p_rpt_format          IN   VARCHAR2 DEFAULT 'ALL');


G_PKG_NAME             CONSTANT VARCHAR2(200)     := 'OKL_ACCOUNTING_PROCESS_PVT';
G_APP_NAME             CONSTANT VARCHAR2(3)       :=  OKL_API.G_APP_NAME;
G_SQLERRM_TOKEN        CONSTANT VARCHAR2(200)     := 'SQLerrm';
G_SQLCODE_TOKEN        CONSTANT VARCHAR2(200)     := 'SQLcode';
G_UNEXPECTED_ERROR     CONSTANT VARCHAR2(200)     := 'OKL_CONTRACTS_UNEXPECTED_ERROR';

-- Added by Santonyr
-- Bug 3925719 Increased the commit cycle to 500 from 50.

G_commit_cycle         NUMBER := 500;


END OKL_ACCOUNTING_PROCESS_PVT;

 

/
