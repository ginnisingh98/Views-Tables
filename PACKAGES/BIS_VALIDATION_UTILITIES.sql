--------------------------------------------------------
--  DDL for Package BIS_VALIDATION_UTILITIES
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."BIS_VALIDATION_UTILITIES" AUTHID CURRENT_USER AS
/*$Header: BISVAUTS.pls 115.0 2003/06/26 20:51:47 tiwang noship $*/


PROCEDURE PUT_MISSING_CURRENCY(
 p_object_type in varchar2,
 p_object_name in varchar2,
 p_EXCEPTION_MESSAGE in VARCHAR2 default null,
 p_CORRECTIVE_ACTION_FF in varchar2 default null,
 p_Rate_type in varchar2 default null,
 p_From_currency in varchar2 default null,
 p_To_currency in varchar2 default null,
 p_effective_date in date default null);

 PROCEDURE PUT_MISSING_UOM(
  p_object_type in varchar2,
 p_object_name in varchar2,
 p_EXCEPTION_MESSAGE in VARCHAR2 default null,
 p_CORRECTIVE_ACTION_FF in varchar2 default null,
 p_From_UOM in varchar2 default null,
 p_To_UOM in varchar2 default null,
 p_Inventory_items in varchar2 default null);

 PROCEDURE PUT_MISSING_PERIOD(
  p_object_type in varchar2,
  p_object_name in varchar2,
 p_EXCEPTION_MESSAGE in VARCHAR2 default null,
 p_CORRECTIVE_ACTION_FF in varchar2 default null,
 p_period_name in varchar2 default null,
 p_calendar in varchar2 default null);

PROCEDURE PUT_OTHER_VALIDATION(
  p_object_type in varchar2,
 p_object_name in varchar2,
 p_error_type in varchar2 default null,
 p_EXCEPTION_MESSAGE in VARCHAR2 default null,
 p_CORRECTIVE_ACTION_FF in varchar2 default null);


 PROCEDURE PUT_MISSING_CONTRACT(
 p_object_type in varchar2,
 p_object_name in varchar2,
 p_EXCEPTION_MESSAGE in VARCHAR2 default null,
 p_CORRECTIVE_ACTION_FF in varchar2 default null,
 p_Rate_type in varchar2 default null,
 p_From_currency in varchar2 default null,
 p_To_currency in varchar2 default null,
 p_date in date default null,
 p_date_override in date default null,
 p_Contract_number in varchar2 default null,
 p_Contract_id in number default null,
 p_Contract_status in varchar2 default null);

 procedure put_missing_global_setup(
  p_parameter_list       IN DBMS_SQL.VARCHAR2_TABLE);


END BIS_VALIDATION_UTILITIES;

 

/
