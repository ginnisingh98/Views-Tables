--------------------------------------------------------
--  DDL for Package AR_LL_RCV_GROUPING_HOOK
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."AR_LL_RCV_GROUPING_HOOK" AUTHID CURRENT_USER as
/*$Header: ARRWGHKS.pls 120.1 2005/07/29 08:04:00 ramenon noship $ */
  procedure update_source_data_keys (x_customer_Trx_id in number);
  function get_group_id (sdk1 in varchar2, sdk2 in varchar2) return number;
  function get_group_name (sdk1 in varchar2, sdk2 in varchar2) return varchar2;
end;

 

/
