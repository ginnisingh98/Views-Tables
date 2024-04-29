--------------------------------------------------------
--  DDL for Package PER_JOB_REQUIREMENTS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PER_JOB_REQUIREMENTS_PKG" AUTHID CURRENT_USER as
/* $Header: pejbr01t.pkh 115.0 99/07/18 13:55:11 porting ship $ */
--
PROCEDURE get_next_sequence(p_job_requirement_id in out number);
--
PROCEDURE check_unique_requirement(p_job_id                 in number,
				   p_analysis_criteria_id   in number,
				   p_rowid                  in varchar2);
--
END PER_JOB_REQUIREMENTS_PKG;

 

/
