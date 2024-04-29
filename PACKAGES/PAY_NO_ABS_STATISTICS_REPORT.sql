--------------------------------------------------------
--  DDL for Package PAY_NO_ABS_STATISTICS_REPORT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PAY_NO_ABS_STATISTICS_REPORT" AUTHID CURRENT_USER AS
/* $Header: pynoabsr.pkh 120.0.12000000.1 2007/05/22 05:52:44 rajesrin noship $ */
        TYPE tagdata IS RECORD
        (
            TagName VARCHAR2(240),
            TagValue VARCHAR2(240)
        );
        TYPE ttagdata
        IS TABLE OF tagdata
        INDEX BY BINARY_INTEGER;
        gplsqltable ttagdata;

        TYPE AbsenceRec IS RECORD(initialized varchar2(1),
		              quatertag varchar2(30),
		              possible_working_days 	NUMBER,
		              sick_1_3_ocr_sc 		NUMBER,
		              sick_1_3_days_sc 		NUMBER,
		              sick_1_3_ocr_dc 		NUMBER,
		              sick_1_3_days_dc 		NUMBER,
		              sick_4_16_ocrs 		NUMBER,
		              sick_4_16_days 		NUMBER,
		              sick_more_16_ocrs 	NUMBER,
		              sick_more_16_days 	NUMBER,
		              sick_more_8w_ocrs 	NUMBER,
		              sick_more_8w_days 	NUMBER,
		              cms_abs_ocrs		NUMBER,
		              cms_abs_days		NUMBER,
		              parental_abs_ocrs		NUMBER,
		              parental_abs_days		NUMBER,
		              other_abs_ocrs		NUMBER,
		              other_abs_days		NUMBER,
		              other_abs_paid_ocrs	NUMBER,
		              other_abs_paid_days	NUMBER
		              );

	TYPE abstab IS TABLE OF AbsenceRec INDEX BY BINARY_INTEGER;


  function get_archive_payroll_action_id(p_payroll_action_id in number)
  return number;
       PROCEDURE get_data (
             		p_business_group_id  IN VARCHAR2, --temp removal ..shoud be added for G
          		p_payroll_action_id  IN VARCHAR2,
      			p_template_name      IN VARCHAR2,
      			p_xml                OUT NOCOPY CLOB
			);

	PROCEDURE WritetoCLOB(p_xfdf_clob out nocopy CLOB);


END PAY_NO_ABS_STATISTICS_REPORT;

 

/
