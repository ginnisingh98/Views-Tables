--------------------------------------------------------
--  DDL for Package GHR_LACS_REMARKS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."GHR_LACS_REMARKS" AUTHID CURRENT_USER AS
/* $Header: ghlacrem.pkh 120.1.12010000.1 2008/07/28 10:32:18 appldev ship $ */
  PROCEDURE Apply_894_Rules(
     p_pa_request_id  GHR_PA_REQUESTS.PA_REQUEST_ID%TYPE,
     p_new_prd        GHR_PA_REQUESTS.PAY_RATE_DETERMINANT%TYPE,
     p_old_prd        GHR_PA_REQUESTS.PAY_RATE_DETERMINANT%TYPE,
     p_out_step_or_rate GHR_PA_REQUESTS.TO_STEP_OR_RATE%TYPE,
     p_eo_nbr         VARCHAR2 := NULL,
     p_eo_date        DATE := NULL,
     p_opm_nbr        VARCHAR2 := NULL,
     p_opm_date       DATE := NULL,
     p_errbuf         IN OUT NOCOPY VARCHAR2,
     p_retcode        IN OUT NOCOPY NUMBER);

    -- FWFA Changes Bug#4444609
    PROCEDURE apply_fwfa_rules(  p_pa_request_id  GHR_PA_REQUESTS.PA_REQUEST_ID%TYPE,
                                 p_noa_code       GHR_PA_REQUESTS.FIRST_NOA_CODE%TYPE,
        	                     p_pay_plan       GHR_PA_REQUESTS.TO_PAY_PLAN%TYPE,
                                 p_errbuf         IN OUT NOCOPY VARCHAR2,
                                 p_retcode        IN OUT NOCOPY NUMBER
                               );
    -- FWFA Changes
END GHR_LACS_REMARKS;

/
