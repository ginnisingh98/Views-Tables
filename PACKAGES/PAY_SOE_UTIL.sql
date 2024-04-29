--------------------------------------------------------
--  DDL for Package PAY_SOE_UTIL
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PAY_SOE_UTIL" AUTHID CURRENT_USER as
/* $Header: pysoeutl.pkh 120.0.12010000.1 2008/07/27 23:42:45 appldev ship $ */
--
TYPE ref_cursor IS REF CURSOR;
--
/*
procedure setValue(ID varchar2 --number
                  ,value varchar2
                  ,firstCol BOOLEAN
                  ,lastCol BOOLEAN);
--
*/
procedure setValue(name varchar2
                  ,value varchar2
                  ,firstCol BOOLEAN
                  ,lastCol BOOLEAN);
--
procedure clear;
--
function genCursor return long;
--
function convertCursor(p_sql_string long) return ref_cursor;
--
function getIDFlexValue(p_id_flex_code in varchar2
                       ,p_id_flex_num in number
                       ,p_application_column_name varchar2
                       ,p_id in varchar2) return varchar2;
--
function getBankDetails(p_legislation_code varchar2
                       ,p_external_account_id varchar2
                       ,p_segment_type varchar2
                       ,p_mask number) return varchar2;
--
function getConfig(p_config_type varchar2) return varchar2;
--
end pay_soe_util;

/
