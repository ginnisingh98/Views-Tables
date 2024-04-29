--------------------------------------------------------
--  DDL for Package OKL_BPD_ADV_MON_RPT_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OKL_BPD_ADV_MON_RPT_PVT" AUTHID CURRENT_USER AS
/* $Header: OKLRAVRS.pls 120.2 2005/10/30 04:02:16 appldev noship $ */

-- Procedure for Advance Monies Report Generation

PROCEDURE          DO_REPORT(p_errbuf             OUT NOCOPY VARCHAR2,
                             p_retcode            OUT NOCOPY NUMBER,
                             p_rcpt_applic_stat   IN   VARCHAR2,
                             p_from_date          IN   VARCHAR2,
                             p_to_date            IN   VARCHAR2);

 -- Function for length formatting

FUNCTION   GET_PROPER_LENGTH(p_input_data         IN   VARCHAR2,
                             p_input_length       IN   NUMBER,
				                     p_input_type         IN   VARCHAR2)
RETURN VARCHAR2;
END okl_bpd_adv_mon_rpt_pvt;

 

/
