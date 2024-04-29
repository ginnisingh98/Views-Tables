--------------------------------------------------------
--  DDL for Package OKL_AM_VENDOR_RES_SHARE_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OKL_AM_VENDOR_RES_SHARE_PVT" AUTHID CURRENT_USER AS
/* $Header: OKLRVRSS.pls 120.2 2007/01/09 12:37:20 udhenuko noship $ */

  -- Variables for XML Publisher Report input parameters
  P_ASSET_NUMBER       VARCHAR2(120);
  P_DISP_DATE_FROM     VARCHAR2(120);
  P_DISP_DATE_TO       VARCHAR2(120);
  P_VPA_NUMBER         VARCHAR2(120);
  P_ASST_END_DT_FROM   VARCHAR2(120);
  P_ASST_END_DT_TO     VARCHAR2(120);
  P_CURRENCY           VARCHAR2(120);
  WHERE_CLAUSE         VARCHAR2(4000);

  ---------------------------------------------------------------------------
  -- PROCEDURES
  ---------------------------------------------------------------------------

  -- This procedure is called by concurrent manager to do vendor residual sharing
  PROCEDURE concurrent_vend_res_share_prg(
                    errbuf           OUT NOCOPY VARCHAR2,
                    retcode          OUT NOCOPY VARCHAR2,
                    p_api_version    IN  VARCHAR2,
                	p_init_msg_list  IN  VARCHAR2 DEFAULT OKL_API.G_FALSE,
                    p_kle_id         IN  VARCHAR2 DEFAULT NULL);

  -- This procedure is called by concurrent manager to generate vendor residual sharing report
  PROCEDURE concurrent_vend_res_share_rpt(
                    errbuf             OUT NOCOPY VARCHAR2,
                    retcode            OUT NOCOPY VARCHAR2,
                    p_api_version      IN  VARCHAR2,
                	p_init_msg_list    IN  VARCHAR2 DEFAULT OKL_API.G_FALSE,
                    p_asset_number     IN  VARCHAR2 DEFAULT NULL,
					p_disp_date_from   IN  VARCHAR2 DEFAULT NULL,
					p_disp_date_to     IN  VARCHAR2 DEFAULT NULL,
					p_vpa_number       IN  VARCHAR2 DEFAULT NULL,
					p_asst_end_dt_from IN  VARCHAR2 DEFAULT NULL,
					p_asst_end_dt_to   IN  VARCHAR2 DEFAULT NULL,
					p_currency         IN  VARCHAR2 DEFAULT NULL);

  -- UDHENUKO Function to form the where clause for XML Publisher based on the input parameters
  FUNCTION  BEFORE_REPORT_INIT_WHRE_CLAUSE RETURN BOOLEAN;

END OKL_AM_VENDOR_RES_SHARE_PVT;

/
