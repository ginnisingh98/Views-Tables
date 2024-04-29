--------------------------------------------------------
--  DDL for Package PAY_INS_CUSTOM_TEMPLATE
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PAY_INS_CUSTOM_TEMPLATE" AUTHID CURRENT_USER AS
/* $Header: payinscstmplt.pkh 120.0.12010000.3 2009/08/03 13:46:32 avenkatk noship $*/
/*===========================================================================+
 |               Copyright (c) 2001 Oracle Corporation                        |
 |                  Redwood Shores, California, USA                           |
 |                       All rights reserved.                                 |
 +============================================================================+
  Name      PAY_INS_CUSTOM_TEMPLATE

  File      payinscstmplt.pkh

  Purpose   The purpose of this package is to register the user defined custom
                Templates into Payroll Tables i.e. PAY_REPORT_CATEGORUES,
        PAY_REPORT_CATEGORY_COMPONENTS AND PAY_REPORT_VARIABLES.

  Notes     Currently this procedure supports the following concurrent programs
                for which user defined custom templates can be registered :
        1.  Local Year End Interface Extract
        2.  Employee W-2 PDF
        3.  1099R Information Return - PDF
        4.  Check Writer (XML)
        5.  Deposit Advice (XML)
        6.  RL1 PDF
        7.  RL2 PDF
        8.  Direct Deposit (New Zealand)
        9.  Japan, Roster of Workers
        10. Japan, Employee Ledger
        Whenever any new concurrent programs is required to be added in this
        category i.e if any new conc programs is decided to have the flexibility
        of registering custom template, please edit the function GET_NAME.
        If the Concurrent program's short name differs from the corresponding
        data_source_code in table xdo_templates_b, this function needs one
        'elsif' clause to be added for that new concurrent program.

  History

  Date          User Id       Version    Description
  ============================================================================
  01-Sep-08     kagangul       115.0     Initial Version Created
  03-Aug-09     avenkatk       115.1     Added NZ and JP Reports
  ============================================================================*/

PROCEDURE insert_custom_template(errbuf             OUT NOCOPY VARCHAR2,
                 retcode            OUT NOCOPY NUMBER,
                 p_conc_prog            VARCHAR2,
                 p_lookup_type_name     VARCHAR2,
                 p_business_group_id        NUMBER);

FUNCTION get_definition_id(pn_report_group_id           NUMBER,
               pv_template_type_code        VARCHAR2,
               pv_template_code         VARCHAR2)
RETURN NUMBER;

FUNCTION get_legislation_code(p_business_group_id       NUMBER)
RETURN VARCHAR2;

PROCEDURE insert_report_variable(p_report_definition_id     NUMBER,
                                 p_definition_type      VARCHAR2,
                                 p_name             VARCHAR2,
                                 p_value            VARCHAR2,
                     p_business_group_id        NUMBER,
                                 p_report_variable_id       OUT NOCOPY NUMBER);

PROCEDURE insert_report_catg_comp(p_report_category_id      NUMBER,
                      p_report_definition_id    NUMBER,
                  p_breakout_variable_id    NUMBER,
                  p_order_by_variable_id    NUMBER,
                  p_style_sheet_variable_id NUMBER,
                  p_business_group_id       NUMBER,
                  p_report_category_comp_id OUT NOCOPY NUMBER);

PROCEDURE insert_report_category(p_report_group_id      NUMBER,
                 p_category_name        VARCHAR2,
                 p_short_name           VARCHAR2,
                 p_legislation_code     VARCHAR2,
                 p_business_group_id        NUMBER,
                 p_report_category_id       NUMBER);

FUNCTION get_name(p_conc_prog                   VARCHAR2)
RETURN  VARCHAR2;

END pay_ins_custom_template;

/
