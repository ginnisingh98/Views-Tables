--------------------------------------------------------
--  DDL for Package PAY_FI_PAYLIST
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PAY_FI_PAYLIST" AUTHID CURRENT_USER AS
/* $Header: pyfipaylr.pkh 120.0 2006/01/24 04:17:15 atrivedi noship $ */
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
             p_business_group_id  in varchar2, --temp removal ..shoud be added for G
          p_payroll_action_id       				IN  VARCHAR2 ,
      p_template_name       IN              VARCHAR2,
      p_xml                 OUT NOCOPY      CLOB
   );

	PROCEDURE WritetoCLOB(p_xfdf_clob out nocopy CLOB);


END PAY_FI_PAYLIST;

 

/
