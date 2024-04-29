--------------------------------------------------------
--  DDL for Package PAY_DK_TCR
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PAY_DK_TCR" AUTHID CURRENT_USER AS
/* $Header: pydktaxreq.pkh 120.0.12010000.1 2008/10/15 11:37:04 pvelugul noship $ */

	TYPE tagdata IS RECORD
	(
	TagName VARCHAR2(240),
	TagValue VARCHAR2(240)
	);

	TYPE ttagdata
	IS TABLE OF tagdata
	INDEX BY BINARY_INTEGER;

	gtagdata ttagdata;

	PROCEDURE GET_DATA (
	p_business_group_id		IN NUMBER,
	p_legal_employer		IN VARCHAR2 ,
	p_start_date			IN VARCHAR2,
	p_test_submission		IN VARCHAR2,
	p_template_name			IN VARCHAR2,
	p_xml                           OUT NOCOPY CLOB
	);

	PROCEDURE WritetoCLOB(p_xfdf_clob out nocopy CLOB);

END PAY_DK_TCR;

/
