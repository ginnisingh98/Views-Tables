--------------------------------------------------------
--  DDL for Package GHR_VALIDATE_PERWSEPI
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."GHR_VALIDATE_PERWSEPI" AUTHID CURRENT_USER AS
/* $Header: ghrwsepi.pkh 120.0.12010000.3 2009/05/26 12:05:13 utokachi noship $ */

Function get_person_type(p_business_group_id IN NUMBER,p_person_id IN number
	,p_effective_date IN DATE)return varchar2;

-- that have been completed.
FUNCTION check_pend_future_pars (p_person_id  IN NUMBER
                                ,p_from_date  IN DATE
                                ,p_to_date    IN DATE)
RETURN VARCHAR2;

end ghr_validate_perwsepi;

/
