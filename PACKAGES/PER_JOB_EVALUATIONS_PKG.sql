--------------------------------------------------------
--  DDL for Package PER_JOB_EVALUATIONS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PER_JOB_EVALUATIONS_PKG" AUTHID CURRENT_USER as
/* $Header: pejbe01t.pkh 115.0 99/07/18 13:54:57 porting ship $ */
--
PROCEDURE system_measured_name(p_system_name      in out varchar2,
			       p_system           in     varchar2,
			       p_measured_in_name in out varchar2,
			       p_measured_in      in varchar2);
--
PROCEDURE get_next_sequence(p_job_evaluation_id in out number);
--
PROCEDURE check_evaluation_exists(p_job_id            in     number,
                                  p_position_id       in     number,
				  p_job_evaluation_id in     number,
				  p_system            in     varchar2,
				  p_date_evaluated    in     date,
				  p_rowid             in     varchar2,
				  p_evaluation_exists in out boolean);
--
END PER_JOB_EVALUATIONS_PKG;

 

/
