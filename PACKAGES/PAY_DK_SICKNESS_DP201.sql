--------------------------------------------------------
--  DDL for Package PAY_DK_SICKNESS_DP201
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PAY_DK_SICKNESS_DP201" AUTHID CURRENT_USER AS
/* $Header: pydkdp201.pkh 120.3 2006/03/06 22:23:32 pgopal noship $ */
TYPE xml_rec_type IS RECORD
		( tagname VARCHAR2(32000)
		,tagvalue VARCHAR2(32000)
		);

-- Table Type for XML Table
TYPE xml_tab_type IS TABLE OF xml_rec_type INDEX BY BINARY_INTEGER;

-- Global declaration of XML Table
xml_tab 	xml_tab_type; -------------Pl/Sql Table for storing Xml Data


/*Procedure which returns the last pay (after pre-Paymnents) of an assignment*/
PROCEDURE LAST_PAY
		(p_business_group_id IN NUMBER
		,p_assignment_id IN NUMBER
		,p_effective_date IN DATE
		,p_pay OUT NOCOPY VARCHAR2
--		,p_period_type OUT NOCOPY VARCHAR2 /*Re-opened Bug 5059274 fix.*/
		);

/*Function to get the defined balance id */
FUNCTION GET_DEFINED_BALANCE_ID
		(p_balance_name   		IN  VARCHAR2
		,p_dbi_suffix     		IN  VARCHAR2
		,p_business_group_id IN NUMBER  )
		RETURN NUMBER;

/*Function to return the working hours per week of an assignment*/
FUNCTION WORKING_HOURS_PER_WEEK
		(p_assignment_id IN NUMBER
		,p_leg_emp_id IN NUMBER
		,p_effective_date IN DATE )
		RETURN NUMBER;

/*Procudure to get the sick leave details for reporting*/
/*Bug 5059274 fix- Added p_start_date and p_end_Date parameters*/
PROCEDURE POPULATE_DETAILS
		(p_template_name in VARCHAR2
		,p_assignment_id NUMBER DEFAULT NULL
		,p_person_id NUMBER
		,p_start_date IN VARCHAR2
		,p_end_date IN VARCHAR2
		,p_le_phone_number IN VARCHAR2
		,p_le_email_addr IN varchar2
		,p_business_group_id NUMBER
		, p_xml OUT NOCOPY CLOB );

PROCEDURE WRITE_TO_CLOB (p_xml OUT NOCOPY CLOB);
END PAY_DK_SICKNESS_DP201;

 

/
