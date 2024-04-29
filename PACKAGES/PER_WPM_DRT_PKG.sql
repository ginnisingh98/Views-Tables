--------------------------------------------------------
--  DDL for Package PER_WPM_DRT_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PER_WPM_DRT_PKG" AUTHID CURRENT_USER AS
/* $Header: pewpmdrt.pkh 120.0.12010000.9 2018/04/12 06:18:42 mbhagwan noship $ */

	PROCEDURE remove_notification(
		p_appraisal_id IN number
	);

	PROCEDURE remove_appraisals(
		V_PERSON_ID IN number
	);

	PROCEDURE APPRAISALS_DRC(
		person_id number,
		p_result_tbl    OUT NOCOPY per_drt_pkg.result_tbl_type
	);

	PROCEDURE remove_succ_plan(
		V_DEL_PERSON_ID IN number
	);

	PROCEDURE PER_WPM_HR_DRC(
		person_id number,
		p_result_tbl    OUT NOCOPY per_drt_pkg.result_tbl_type
	);
	PROCEDURE PER_WPM_HR_POST(
		person_id number
	);

end PER_WPM_DRT_PKG;

/
