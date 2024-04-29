--------------------------------------------------------
--  DDL for Package EDW_HR_RQN_VCNCY_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."EDW_HR_RQN_VCNCY_PKG" AUTHID CURRENT_USER AS
/* $Header: hriekvac.pkh 120.0 2005/05/29 07:12:50 appldev noship $ */

FUNCTION vacancy_fk( p_vacancy_id IN NUMBER)
			     RETURN VARCHAR2;

END edw_hr_rqn_vcncy_pkg;

 

/
