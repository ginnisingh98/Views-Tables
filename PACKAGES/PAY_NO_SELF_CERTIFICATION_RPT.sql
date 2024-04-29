--------------------------------------------------------
--  DDL for Package PAY_NO_SELF_CERTIFICATION_RPT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PAY_NO_SELF_CERTIFICATION_RPT" AUTHID CURRENT_USER AS
/* $Header: pynosfcr.pkh 120.0.12000000.1 2007/05/20 09:28:51 rlingama noship $ */
        TYPE tagdata IS RECORD
        (
            TagName VARCHAR2(240),
            TagValue VARCHAR2(240)
        );
        TYPE ttagdata
        IS TABLE OF tagdata
        INDEX BY BINARY_INTEGER;
        gplsqltable ttagdata;



  function get_archive_payroll_action_id(p_payroll_action_id in number)
  return number;
       PROCEDURE get_data (
             		p_business_group_id  IN VARCHAR2, --temp removal ..shoud be added for G
          		p_payroll_action_id  IN VARCHAR2,
      			p_template_name      IN VARCHAR2,
      			p_xml                OUT NOCOPY CLOB
			);

	PROCEDURE WritetoCLOB(p_xfdf_clob out nocopy CLOB);


END PAY_NO_SELF_CERTIFICATION_RPT;

 

/
