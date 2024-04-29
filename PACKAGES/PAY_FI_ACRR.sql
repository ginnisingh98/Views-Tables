--------------------------------------------------------
--  DDL for Package PAY_FI_ACRR
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PAY_FI_ACRR" AUTHID CURRENT_USER AS
/* $Header: pyfiacrr.pkh 120.0 2005/11/08 05:18:41 rravi noship $ */
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


END PAY_FI_ACRR;

 

/
