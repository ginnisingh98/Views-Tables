--------------------------------------------------------
--  DDL for Package GHR_ELT_TO_BEN_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."GHR_ELT_TO_BEN_PKG" AUTHID CURRENT_USER AS
/* $Header: ghbencnv.pkh 120.2.12010000.2 2009/07/07 06:58:58 utokachi ship $ */
--
-- ============================================================================
--                        << Procedure: execute_mt >>
--  Description:
--  	This procedure is called from concurrent program. This procedure will
--  determine the batch size and call sub programs.
-- ============================================================================
PROCEDURE EXECUTE_CONV_MT(  p_errbuf OUT NOCOPY VARCHAR2,
                            p_retcode OUT NOCOPY NUMBER,
                            p_batch_size IN NUMBER,
			    p_thread_size IN NUMBER);

PROCEDURE EXECUTE_CONVERSION(p_errbuf OUT NOCOPY VARCHAR2,
			    p_retcode OUT NOCOPY NUMBER,
			    p_session_id IN NUMBER,
			    p_batch_no IN NUMBER,
			    p_parent_request_id IN NUMBER);

PROCEDURE ValidateRun(p_result OUT nocopy varchar2);

PROCEDURE execute_conv_hlt_plan (p_errbuf     OUT NOCOPY VARCHAR2,
                                    p_retcode    OUT NOCOPY NUMBER,
                                    p_business_group_id in Number); --Bug# 6594288

PROCEDURE execute_tsp_conversion (p_errbuf     OUT NOCOPY VARCHAR2,
                                    p_retcode    OUT NOCOPY NUMBER,
                                    p_business_group_id in Number,
				    p_agency_effective_date in varchar2,
				    p_agency_code in  varchar2,
				    p_agency_sub_code in varchar2); --Bug# 8622486


END GHR_ELT_TO_BEN_PKG;

/
