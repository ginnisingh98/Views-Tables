--------------------------------------------------------
--  DDL for Package HR_JP_GENERAL_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."HR_JP_GENERAL_PKG" AUTHID CURRENT_USER AS
/* $Header: hrjpgen.pkh 115.5 2003/08/11 21:05:44 ytohya ship $ */
--------------------------------------------------------------
	FUNCTION GET_SESSION_DATE
--------------------------------------------------------------
	RETURN DATE;
--	pragma restrict_references(GET_SESSION_DATE,WNDS,WNPS);

--------------------------------------------------------------
	FUNCTION DECODE_ORG(
--------------------------------------------------------------
		P_ORGANIZATION_ID	IN NUMBER)
	RETURN VARCHAR2;
--	pragma restrict_references(DECODE_ORG,WNDS,WNPS);

--------------------------------------------------------------
	FUNCTION DECODE_DISTRICT(
--------------------------------------------------------------
		P_DISTRICT_CODE		IN VARCHAR2)
	RETURN VARCHAR2;
--	pragma restrict_references(DECODE_DISTRICT,WNDS,WNPS);

--------------------------------------------------------------
	FUNCTION GET_ADDRESS(
--------------------------------------------------------------
		P_PERSON_ID		IN NUMBER,
		P_ADDRESS_TYPE		IN VARCHAR2,
		P_EFFECTIVE_DATE	IN DATE)
	RETURN VARCHAR2;
--	pragma restrict_references(GET_ADDRESS,WNDS,WNPS);

--------------------------------------------------------------
	FUNCTION GET_DISTRICT_CODE(
--------------------------------------------------------------
		P_PERSON_ID		IN NUMBER,
		P_ADDRESS_TYPE		IN VARCHAR2,
		P_EFFECTIVE_DATE	IN DATE)
	RETURN VARCHAR2;
--	pragma restrict_references(GET_DISTRICT_CODE,WNDS,WNPS);

--------------------------------------------------------------
	FUNCTION run_assact_exists(
--------------------------------------------------------------
			p_assignment_id		IN NUMBER,
			p_element_set_name	IN VARCHAR2,
			p_validation_start_date	IN DATE DEFAULT NULL,
			p_validation_end_date	IN DATE DEFAULT NULL,
			p_effective_date	IN DATE DEFAULT NULL) RETURN VARCHAR2;
--	pragma restrict_references(run_assact_exists,WNDS,WNPS);


--
-- ----------------------------------------------------------------------------
-- |-------------------------< get_org_short_name >----------------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--   This Function returns one of the org extra names defined as further
--   org information against the specified organization .
--   Which name column to be returnd is determined by the specified
--   column name.
--
-- NOTE:
--     This Function does not raise an error even when user sets parameters
--     to invalid values,but returns NULL.
--
--
--
-- In Parameters:
--   Name                           Reqd Type     Description
--   p_organization_id              Yes  number   ID of oraganization.
--
--
--
--   p_column_name                   No  varchar2 Column name for org short
--                                                name.You must specify NAME1
--                                                ,NAME2,NAME3,NAME4 or NAME5.
--                                                The Default value is NAME1.
--
-- Post Success:
--
--   The Function sets the following out parameters:
--
--   Name                           Type     Description
--                                  varchar2 The return value is the org
--                                           short name associated with
--                                           the column name and the
--                                           organization
--
--
-- Access Status:
--   Public.
--
-- {End Of Comments}
--
--------------------------------------------------------------
	FUNCTION GET_ORG_SHORT_NAME(
--------------------------------------------------------------
		 p_organization_id	IN	NUMBER
		,p_column_name	        IN	VARCHAR2 default 'NAME1')
 	RETURN VARCHAR2;
--        pragma restrict_references(GET_ORG_SHORT_NAME,WNDS,WNPS);
--
-- The following function is to avoid bug.2668811
--
--------------------------------------------------------------
function date_to_jp_char(
--------------------------------------------------------------
	p_date			in date,
	p_format		in varchar2) return varchar2 deterministic;
--
--------------------------------------------------------------
	FUNCTION DECODE_VEHICLE(
--------------------------------------------------------------
		P_VEHICLE_ALLOCATION_ID		IN NUMBER,
		P_EFFECTIVE_DATE		IN DATE)
	RETURN VARCHAR2;
--
END HR_JP_GENERAL_PKG;

 

/
