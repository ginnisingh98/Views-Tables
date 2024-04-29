--------------------------------------------------------
--  DDL for Package EDW_HR_PRSN_TYP_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."EDW_HR_PRSN_TYP_PKG" AUTHID CURRENT_USER AS
/* $Header: hriekpty.pkh 120.0 2005/05/29 07:12:24 appldev noship $ */

FUNCTION person_type_fk( p_person_id IN NUMBER,
                         p_effective_date   IN DATE)
			     RETURN VARCHAR2;

END edw_hr_prsn_typ_pkg;

 

/
