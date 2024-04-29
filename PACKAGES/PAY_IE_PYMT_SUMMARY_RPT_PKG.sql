--------------------------------------------------------
--  DDL for Package PAY_IE_PYMT_SUMMARY_RPT_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PAY_IE_PYMT_SUMMARY_RPT_PKG" AUTHID CURRENT_USER AS
/* $Header: pyiepysm.pkh 120.0 2005/06/03 06:47:49 appldev noship $ */

   TYPE xmlrec IS RECORD (
      tagname    VARCHAR2 (240),
      tagvalue   VARCHAR2 (240)
   );

   TYPE txmltable IS TABLE OF xmlrec
      INDEX BY BINARY_INTEGER;

   vxmltable   txmltable;
   vctr        NUMBER;


 PROCEDURE populate_pymt_summary_rep (
      p_bg_id                  IN              NUMBER,
      p_payroll_id             IN              NUMBER,
      p_period_id              IN              NUMBER,
      p_consolidation_set_id   IN              NUMBER,
      p_template_name          IN              VARCHAR2,
      p_xml                    OUT NOCOPY      CLOB
   );

END pay_ie_pymt_summary_rpt_pkg;


 

/
