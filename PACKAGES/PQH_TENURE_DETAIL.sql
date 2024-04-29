--------------------------------------------------------
--  DDL for Package PQH_TENURE_DETAIL
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PQH_TENURE_DETAIL" AUTHID CURRENT_USER AS
/* $Header: pqhusprn.pkh 115.2 2002/12/03 00:07:32 rpasapul noship $ */

  managerSeq	NUMBER	:= 1;

  PROCEDURE  getPersonInfo (
		p_person_id 		 IN	NUMBER,
		p_employee_number OUT NOCOPY VARCHAR2,
		p_full_name	 OUT NOCOPY VARCHAR2,
		p_last_name	 OUT NOCOPY VARCHAR2,
		p_title		 OUT NOCOPY VARCHAR2,
		p_email_addr	 OUT NOCOPY VARCHAR2,
		p_start_date	 OUT NOCOPY DATE );

  PROCEDURE  getPersonTenure (
		p_person_id 	 	 IN	NUMBER,
		p_tenure_status 	OUT NOCOPY VARCHAR2,
		p_date_determine 	OUT NOCOPY VARCHAR2,
		p_adjust_date	 	OUT NOCOPY VARCHAR2,
		p_remain_years		OUT NOCOPY VARCHAR2,
		p_remain_months		OUT NOCOPY VARCHAR2,
		p_completed_years 	OUT NOCOPY VARCHAR2,
		p_completed_months 	OUT NOCOPY VARCHAR2 );

  PROCEDURE  getReportBodyText (
		p_report_id 	 	 IN	VARCHAR2,
		p_body_regards    OUT NOCOPY VARCHAR2,
		p_body_text1    OUT NOCOPY VARCHAR2,
		p_body_text2    OUT NOCOPY VARCHAR2,
		p_body_text3    OUT NOCOPY VARCHAR2,
		p_body_text4    OUT NOCOPY VARCHAR2,
		p_body_text5    OUT NOCOPY VARCHAR2,
		p_body_text6    OUT NOCOPY VARCHAR2,
		p_body_text7    OUT NOCOPY VARCHAR2,
		p_body_text8  	 OUT NOCOPY VARCHAR2 );

  PROCEDURE getTenuredCount (
		p_supervisor_id		IN	NUMBER,
		p_top_level			IN	VARCHAR2,
		p_start_academic_dt		IN	DATE,
		p_end_academic_dt		IN 	DATE,
		p_total_cnt		 OUT NOCOPY NUMBER,
		p_tenured_cnt		 OUT NOCOPY NUMBER,
		p_tenured_sup_cnt	 OUT NOCOPY NUMBER,
		p_tt_cnt			 OUT NOCOPY NUMBER,
		p_tt_sup_cnt		 OUT NOCOPY NUMBER,
		p_tt_final_yr_cnt	 OUT NOCOPY NUMBER,
		p_tt_final_yr_sup_cnt OUT NOCOPY NUMBER,
		p_ten_cur_yr_cnt	 OUT NOCOPY NUMBER,
		p_ten_cur_yr_sup_cnt OUT NOCOPY NUMBER,
		p_te_cur_yr_cnt	 OUT NOCOPY NUMBER,
		p_te_cur_yr_sup_cnt	 OUT NOCOPY NUMBER,
		p_td_cur_yr_cnt	 OUT NOCOPY  NUMBER,
		p_td_cur_yr_sup_cnt	 OUT NOCOPY NUMBER	);

  FUNCTION getPersonAddress (
		p_person_id		 IN	NUMBER,
		p_bgroup_id		 IN	NUMBER ) RETURN VARCHAR2 ;

  FUNCTION getPersonSupervisor (
		p_person_id 		 IN 	NUMBER ) RETURN NUMBER;

  FUNCTION getPersonRank (
		p_person_id 		 IN 	NUMBER ) RETURN VARCHAR2;

  FUNCTION getPersonJobPosition (
		p_person_id		IN 	NUMBER ) RETURN VARCHAR2;

  FUNCTION  getSupStatusCount (
		p_supervisor_id          IN NUMBER,
		p_tenure_status          IN VARCHAR2,
		p_effective_date		IN DATE	) RETURN NUMBER;

  FUNCTION  getPeriodStatusCount (
		p_supervisor_id          IN NUMBER,
		p_tenure_status          IN VARCHAR2,
		p_start_date			IN DATE,
		p_end_date			IN DATE	) RETURN NUMBER;

  FUNCTION  getStatusCount (
		p_supervisor_id          IN NUMBER,
		p_tenure_status          IN VARCHAR2 ) RETURN NUMBER;

  FUNCTION getManagerSequence  RETURN NUMBER;

END pqh_tenure_detail;

 

/
