--------------------------------------------------------
--  DDL for Package GHR_BENEFITS_EIT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."GHR_BENEFITS_EIT" AUTHID CURRENT_USER AS
/* $Header: ghbenenr.pkh 120.0.12010000.1 2008/07/28 10:22:01 appldev ship $ */
 PROCEDURE ghr_benefits_fehb
	(errbuf                  OUT NOCOPY      VARCHAR2,
		retcode                 OUT NOCOPY      NUMBER,
		p_person_id per_all_people_f.person_id%type,
		p_effective_date VARCHAR2,
		p_business_group_id per_all_people_f.business_group_id%type,
		p_pl_code ben_pl_f.short_code%type,
		p_opt_code ben_opt_f.short_code%type,
		p_pre_tax varchar2,
		p_assignment_id per_all_assignments_f.assignment_id%type,
		p_temps_total_cost varchar2,
		p_temp_appt varchar2 default 'N');

PROCEDURE ghr_benefits_tsp
		(errbuf                  OUT NOCOPY      VARCHAR2,
		retcode                 OUT NOCOPY      NUMBER,
		p_person_id per_all_people_f.person_id%type,
		p_effective_date VARCHAR2,
		p_business_group_id per_all_people_f.business_group_id%type,
		p_tsp_status varchar2,
		p_opt_name ben_opt_f.name%type,
		p_opt_val number
		);

END ghr_benefits_eit;

/
