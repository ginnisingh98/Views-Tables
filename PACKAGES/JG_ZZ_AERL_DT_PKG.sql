--------------------------------------------------------
--  DDL for Package JG_ZZ_AERL_DT_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."JG_ZZ_AERL_DT_PKG" AUTHID CURRENT_USER AS
/*$Header: jgzzaerls.pls 120.3.12010000.1 2008/07/28 07:56:11 appldev ship $*/
	P_VAT_REPORTING_ENTITY_ID	number;
	P_PERIOD_NAME	varchar2(32767);
	P_SOURCE	varchar2(40);
  function cf_batch_name(trx_id in number, source in varchar2) return varchar2;
 -- Added function to get financial document type to solve bug 5550600
  function get_financial_document_type(pn_trx_id in number, pn_trx_type_id in number, pv_source in varchar2 , pv_entity_code in varchar2) return varchar2;
END JG_ZZ_AERL_DT_PKG;

/
