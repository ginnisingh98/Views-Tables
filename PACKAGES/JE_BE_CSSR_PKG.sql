--------------------------------------------------------
--  DDL for Package JE_BE_CSSR_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."JE_BE_CSSR_PKG" AUTHID CURRENT_USER AS
/* $Header: jebecsrs.pls 120.1 2008/01/10 12:24:56 spasupun noship $ */

g_xml clob;
g_vc_spacing number(20);

procedure main(
 p_errbuf     OUT NOCOPY VARCHAR2,
 p_retcode    OUT NOCOPY VARCHAR2,
 p_vat_reporting_entity_id  jg_zz_vat_rep_entities.vat_reporting_entity_id%TYPE,
 p_rep_period        gl_periods.period_name%TYPE,
 p_fax_number        varchar2,
 p_email             varchar2,
 p_resp_email        varchar2,
 p_trans_resp        varchar2,
 p_trans_ackn        varchar2,
 p_sec_resp          varchar2,
 p_sec_ackn          varchar2);

procedure get_admin_data
(
 p_vat_reg_num       varchar2,
 p_email_address     varchar2,
 p_tel_num           varchar2,
 p_fax_num           varchar2,
 p_name              varchar2,
 p_email_resp        varchar2,
 p_trans_resp        varchar2,
 p_trans_ackn        varchar2,
 p_sec_resp          varchar2,
 p_sec_ackn          varchar2,
 p_survey_code       varchar2,
 p_period            varchar2
);

procedure get_content_data
(p_survey_code varchar2,
 p_period      varchar2,
 p_vat_reporting_entity_id jg_zz_vat_rep_entities.vat_reporting_entity_id%TYPE
);

FUNCTION get_bsv(p_ledger_id number,p_choac_id number,p_cc_id number)RETURN VARCHAR2;
FUNCTION get_accounting_segment(p_coa_id  number,p_cc_id number default null) RETURN VARCHAR2;

function level_up return varchar2;
function level_down return varchar2;

end JE_BE_CSSR_PKG;


/
