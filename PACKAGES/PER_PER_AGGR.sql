--------------------------------------------------------
--  DDL for Package PER_PER_AGGR
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PER_PER_AGGR" AUTHID CURRENT_USER AS
/* $Header: pegbperhi.pkh 120.0.12010000.2 2009/07/23 10:13:03 rlingama noship $ */

PROCEDURE AI_check_PAYE_NI_flags (p_person_id IN NUMBER,
                                  p_effective_date IN DATE); --Bug 8370225

PROCEDURE AU_check_PAYE_NI_flags (p_person_id IN NUMBER,
                                  p_effective_date IN DATE,
			          p_datetrack_mode IN VARCHAR2,
				  P_CURRENT_EMPLOYEE_FLAG_O IN VARCHAR2); --Bug 8370225

END PER_PER_AGGR;

/
