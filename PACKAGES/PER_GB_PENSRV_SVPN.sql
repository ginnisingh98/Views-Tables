--------------------------------------------------------
--  DDL for Package PER_GB_PENSRV_SVPN
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PER_GB_PENSRV_SVPN" 
 /* $Header: pegbasgp.pkh 120.1.12010000.3 2008/11/07 11:28:22 npannamp ship $ */
AUTHID CURRENT_USER AS

procedure CREATE_GB_SPN (p_assignment_id in Number,
                         p_effective_date in Date);

procedure AUTO_CALC_FTE (p_assignment_id in Number,
                         P_EFFECTIVE_START_DATE in Date);
END  per_gb_pensrv_svpn;

/
