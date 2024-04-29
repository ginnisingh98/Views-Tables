--------------------------------------------------------
--  DDL for Package PAY_DK_EINR
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PAY_DK_EINR" AUTHID CURRENT_USER AS
/* $Header: pydkeinr.pkh 120.1.12010000.2 2009/05/28 06:50:18 rrajaman ship $ */

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
	p_business_group_id                             IN NUMBER,
	p_payroll_action_id                                     IN  VARCHAR2 ,
	p_template_name                                 IN VARCHAR2,
	p_xml                                                           OUT NOCOPY CLOB
	);

	PROCEDURE WritetoCLOB(p_xfdf_clob out nocopy CLOB);

END PAY_DK_EINR;

/
