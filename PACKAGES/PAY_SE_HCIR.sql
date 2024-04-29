--------------------------------------------------------
--  DDL for Package PAY_SE_HCIR
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PAY_SE_HCIR" AUTHID CURRENT_USER AS
   /* $Header: pysehcir.pkh 120.0.12000000.1 2007/07/18 11:04:32 psingla noship $ */
   TYPE xml_rec_type IS RECORD (
      tagname    VARCHAR2 (240),
      tagvalue   VARCHAR2 (240)
   );

   TYPE xml_tab_type IS TABLE OF xml_rec_type
      INDEX BY BINARY_INTEGER;

   xml_tab   xml_tab_type;

   PROCEDURE get_data (
      p_business_group_id   IN              NUMBER,
      p_payroll_action_id   IN              VARCHAR2,
      p_template_name       IN              VARCHAR2,
      p_xml                 OUT NOCOPY      CLOB
   );

   PROCEDURE writetoclob (
      p_xfdf_clob   OUT NOCOPY   CLOB
   );
END pay_se_hcir;

 

/
