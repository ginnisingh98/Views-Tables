--------------------------------------------------------
--  DDL for Package EDW_HR_REC_ACT_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."EDW_HR_REC_ACT_PKG" AUTHID CURRENT_USER AS
/* $Header: hriekrec.pkh 120.0 2005/05/29 07:12:36 appldev noship $ */

FUNCTION recruitment_activity_fk( p_recruitment_activity_id IN NUMBER)
			     RETURN VARCHAR2;

END edw_hr_rec_act_pkg;

 

/
