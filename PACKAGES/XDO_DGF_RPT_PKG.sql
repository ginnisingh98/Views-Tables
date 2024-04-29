--------------------------------------------------------
--  DDL for Package XDO_DGF_RPT_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."XDO_DGF_RPT_PKG" AUTHID CURRENT_USER as
/* $Header: XDODGFRPS.pls 120.0 2008/01/19 00:13:50 bgkim noship $ */


  -- Public type declarations
  type RULE_RECORD_TYPE is record (
    id                   integer,
    rule_short_name      varchar2(20),
    rule_type            varchar2(1),
    rule_variable        varchar2(2000),
    rule_operator        varchar2(4),
    rule_values          varchar2(2000),
    rule_values_datatype varchar2(1),
    db_function          varchar2(80),
    arg_number           number,
    arg01                varchar2(2000),
    arg02                varchar2(2000),
    arg03                varchar2(2000),
    arg04                varchar2(2000),
    arg05                varchar2(2000),
    arg06                varchar2(2000),
    arg07                varchar2(2000),
    arg08                varchar2(2000),
    arg09                varchar2(2000),
    arg10                varchar2(2000),
    arg01_type           varchar2(1),
    arg02_type           varchar2(1),
    arg03_type           varchar2(1),
    arg04_type           varchar2(1),
    arg05_type           varchar2(1),
    arg06_type           varchar2(1),
    arg07_type           varchar2(1),
    arg08_type           varchar2(1),
    arg09_type           varchar2(1),
    arg10_type           varchar2(1),
    return_value         boolean
  );

  type RULE_TABLE_TYPE is table of RULE_RECORD_TYPE
  index by binary_integer;

  type TPL_RULE_ID_RECORD_TYPE is record (
       template_code      varchar2(20),
       rule_id            integer,
       format_filter_type varchar2(3) default ''
  );

  type TPL_RULE_ID_TABLE_TYPE is table of TPL_RULE_ID_RECORD_TYPE
  index by binary_integer;

  type TPLT_RECORD_TYPE is record (
       template_name                 varchar2(40),
       template_code                 varchar2(40),
       template_application          varchar2(15), -- added attribute 19.4.2006
       template_lang_territory_codes varchar2(1000), -- added attribute 28.4.2006
       template_lang_territory_desc  varchar2(2000), -- added attribute 28.4.2006
       report_code                   varchar2(40),
       pdf_format_allowed            varchar2(1) default 'Y',
       rtf_format_allowed            varchar2(1) default 'Y',
       htm_format_allowed            varchar2(1) default 'Y',
       xls_format_allowed            varchar2(1) default 'Y',
       txt_format_allowed            varchar2(1) default 'Y',
       printer_allowed               varchar2(1) default 'N',
       first_r_id                    integer default -1, -- first index to TPL_RULE_ID_TABLE_TYPE
       last_r_id                     integer default -1  -- last index to TPL_RULE_ID_TABLE_TYPE
  );


  type TPLT_TABLE_TYPE is table of TPLT_RECORD_TYPE
  index by binary_integer;

  type PARAM_RECORD_TYPE is record (
       report_code                   varchar2(40),
       report_application            varchar2(15), -- added attribute 19.4.2006
       parameter_type                varchar2(1),
       parameter_name                varchar2(100), -- added attribute 29.11.2006
       parameter_value               varchar2(500)
  );

  type PARAM_TABLE_TYPE is table of PARAM_RECORD_TYPE
  index by binary_integer;

  type RPT_RECORD_TYPE is record (
       report_name                  varchar2(40),
       report_code                  varchar2(40),
       report_application           varchar2(15), -- added attribute 19.4.2006
       rpt_context_id               integer -- added attribute 12.04.2005
  );
  type RPT_TABLE_TYPE is  table of RPT_RECORD_TYPE
  index by binary_integer;



  -- Public function and procedure declarations
  procedure get_context_reports(
                p_form_code         IN  varchar2,
                p_block_code        IN  varchar2,
                p_report_table      OUT NOCOPY RPT_TABLE_TYPE,
                p_template_table    OUT NOCOPY TPLT_TABLE_TYPE,
                p_tpl_rule_id_table OUT NOCOPY TPL_RULE_ID_TABLE_TYPE,
                p_rule_table        OUT NOCOPY RULE_TABLE_TYPE);

  procedure get_report_parameters(
                p_rpt_contexts      IN  RPT_TABLE_TYPE,
                p_parameters        OUT NOCOPY PARAM_TABLE_TYPE
                );
  procedure prepare_context_lists(p_form_code  IN varchar2,
                                  p_block_code IN varchar2);

  procedure filter_templates(p_resolved_rule_list     IN RULE_TABLE_TYPE);
  procedure filter_templates_o(p_resolved_rule_list_o IN XDO_DGF_RULE_TABLE_TYPE);

  procedure store_report_list(p_report_list           IN RPT_TABLE_TYPE);
  procedure store_template_list(p_template_list       IN TPLT_TABLE_TYPE);
  procedure store_parameter_list(p_parameter_list     IN PARAM_TABLE_TYPE);
  function get_report_list      return RPT_TABLE_TYPE;
  function get_template_list    return TPLT_TABLE_TYPE;
  function get_parameter_list   return PARAM_TABLE_TYPE;
  function get_rule_list        return RULE_TABLE_TYPE;

  function get_rule_list_o      return XDO_DGF_RULE_TABLE_TYPE;
  function get_parameter_list_o return XDO_DGF_PARAM_TABLE_TYPE;
  function get_template_list_o  return XDO_DGF_TPLT_TABLE_TYPE;
  function get_report_list_o    return XDO_DGF_RPT_TABLE_TYPE;

  -- procedure test;
end XDO_DGF_RPT_PKG;

/
