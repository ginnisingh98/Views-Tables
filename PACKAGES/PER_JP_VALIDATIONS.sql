--------------------------------------------------------
--  DDL for Package PER_JP_VALIDATIONS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PER_JP_VALIDATIONS" AUTHID CURRENT_USER AS
/* $Header: pejpvald.pkh 115.6 2003/08/11 21:04:33 ytohya ship $ */
/*      p_format allows the following mask.

	0 : 0-9		Numbers only, non-omittable
	9 : 0-9		Numbers only, omittable
	A : A-Z		Capital alphabet only, non-omittable
	P : A-Z		Capital alphabet only, omittable
	a : a-z		Small alphabet only, non-omittable
	p : a-z		Small alphabet only, omittable
	L : 0-9, A-Z	Numbers and capital alphabet only, non-omittable
	C : 0-9, A-Z	Numbers and capital alphabet only, omittable
	l : 0-9, a-z	Numbers and small alphabet only, non-omittable
	c : 0-9, a-z	Numbers and small alphabet only, omittable */
	FUNCTION CHECK_FORMAT(
			p_value		IN VARCHAR2,
			p_format	IN VARCHAR2) RETURN VARCHAR2;
--	pragma restrict_references(check_format,WNDS,WNPS);
--
	FUNCTION CHECK_DATE_FORMAT(
			p_value		IN VARCHAR2,
			p_format	IN VARCHAR2) RETURN VARCHAR2;
--
	FUNCTION DISTRICT_CODE_CHECK_DIGIT(
			p_district_code IN VARCHAR2) RETURN NUMBER;
--	pragma restrict_references(district_code_check_digit,WNDS,WNPS);
--
	FUNCTION DISTRICT_CODE_EXISTS(
			p_district_code	IN VARCHAR2,
			p_check_digit	IN VARCHAR2 DEFAULT 'TRUE') RETURN VARCHAR2;
--
	FUNCTION ORG_EXISTS(
			p_business_group_id	IN NUMBER,
			p_effective_date	IN DATE,
			p_organization_id	IN NUMBER,
			p_org_class		IN VARCHAR2) RETURN VARCHAR2;
--	pragma restrict_references(org_exists,WNDS,WNPS);
	FUNCTION CHECK_HALF_KANA(
			p_value			IN VARCHAR2) RETURN VARCHAR2;
--
	FUNCTION VEHICLE_EXISTS(
			p_business_group_id	IN NUMBER,
			p_assignment_id		IN NUMBER,
			p_effective_date	IN DATE,
			p_vehicle_allocation_id	IN NUMBER) RETURN VARCHAR2;
--
END per_jp_validations;

 

/
