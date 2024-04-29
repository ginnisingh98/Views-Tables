--------------------------------------------------------
--  DDL for Package PQP_GB_PENSRV_SVPN
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PQP_GB_PENSRV_SVPN" 
 /* $Header: pqpgbpsispn.pkh 120.1 2008/01/09 03:58:37 rlingama noship $ */
AUTHID CURRENT_USER AS
 -- Enable_retro_overlap
 PROCEDURE derive_svpn( errbuf      OUT NOCOPY VARCHAR2,
                        retcode     OUT NOCOPY VARCHAR2,
                        p_business_group_id IN NUMBER,
                        p_eff_end_date      IN VARCHAR2,
                        p_execution_mode    IN VARCHAR2);

 FUNCTION chk_emp_eligibility(p_assignment_id IN NUMBER
				              ) RETURN DATE;
END pqp_gb_pensrv_svpn;

/
