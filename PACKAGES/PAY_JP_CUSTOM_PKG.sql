--------------------------------------------------------
--  DDL for Package PAY_JP_CUSTOM_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PAY_JP_CUSTOM_PKG" AUTHID CURRENT_USER AS
/* $Header: pyjpcust.pkh 120.0.12010000.1 2008/07/27 22:57:51 appldev ship $ */
	-- Actual Values for PAY_JP_PRE_TAX.
	TYPE value_rec IS RECORD(
		salary_category			VARCHAR2(30),
		itax_org_id			NUMBER,
		hi_org_id			NUMBER,
		wp_org_id			NUMBER,
		wpf_org_id			NUMBER,
		ui_org_id			NUMBER,
		wai_org_id			NUMBER,
		itax_category			VARCHAR2(30),
		itax_yea_category		VARCHAR2(30),
		ltax_district_code		VARCHAR2(30),
		ltax_swot_no			VARCHAR2(30),
		ui_category			VARCHAR2(30),
		wai_category			VARCHAR2(30),
		taxable_sal_amt			NUMBER NOT NULL := 0,
		taxable_mat_amt			NUMBER NOT NULL := 0,
		hi_prem_ee			NUMBER NOT NULL := 0,
		hi_prem_er			NUMBER NOT NULL := 0,
		ci_prem_ee			NUMBER NOT NULL := 0,
		ci_prem_er			NUMBER NOT NULL := 0,
		wp_prem_ee			NUMBER NOT NULL := 0,
		wp_prem_er			NUMBER NOT NULL := 0,
		wpf_prem_ee			NUMBER NOT NULL := 0,
		wpf_prem_er			NUMBER NOT NULL := 0,
		ui_prem_ee			NUMBER NOT NULL := 0,
		ui_sal_amt			NUMBER NOT NULL := 0,
		wai_sal_amt			NUMBER NOT NULL := 0,
		itax				NUMBER NOT NULL := 0,
		itax_adjustment			NUMBER NOT NULL := 0,
		ltax				NUMBER NOT NULL := 0,
		ltax_lumpsum			NUMBER NOT NULL := 0,
        sp_ltax_district_code   VARCHAR2(30),
		sp_ltax				NUMBER NOT NULL := 0,
		sp_ltax_income			NUMBER NOT NULL := 0,
		sp_ltax_shi			NUMBER NOT NULL := 0,
		sp_ltax_to			NUMBER NOT NULL := 0,
		mutual_aid			NUMBER NOT NULL := 0,
		disaster_tax_reduction		NUMBER NOT NULL := 0);
-----------------------------------------------------------------------
	PROCEDURE VALIDATE_RECORD(
-----------------------------------------------------------------------
			p_value		IN value_rec,
			p_action_status OUT NOCOPY VARCHAR2,
			p_message OUT NOCOPY VARCHAR2);

-----------------------------------------------------------------------
	PROCEDURE GET_ITAX_CATEGORY(
-----------------------------------------------------------------------
			p_assignment_action_id	IN NUMBER,
			p_salary_category OUT NOCOPY VARCHAR2,
			p_itax_category	 OUT NOCOPY VARCHAR2,
			p_itax_yea_category OUT NOCOPY VARCHAR2);

-----------------------------------------------------------------------
	PROCEDURE FETCH_VALUES(
-----------------------------------------------------------------------
			P_BUSINESS_GROUP_ID	IN NUMBER,
			P_ASSIGNMENT_ACTION_ID	IN NUMBER,
			P_ASSIGNMENT_ID		IN NUMBER,
			P_DATE_EARNED		IN DATE,
			P_VALUE		 OUT NOCOPY value_rec);
END PAY_JP_CUSTOM_PKG;

/
