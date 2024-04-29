--------------------------------------------------------
--  DDL for Package Body AR_LL_RCV_GROUPING_HOOK
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."AR_LL_RCV_GROUPING_HOOK" as
/*$Header: ARRWGHKB.pls 120.2 2007/12/31 11:49:17 spdixit ship $ */


procedure update_source_data_keys (x_customer_Trx_id in number) is
--This sample procedure inserts dummy group names into Source_data_key5
-- and the corresponding dummy group id to source_data_key4
begin
  --
  -- Uncomment the following update, to do your own grouping
  -- Remember not to update Source_data_key4 with 0, as it is reserved
  -- for lines without any groups
  --
  --update ra_customer_Trx_lines
  --set source_data_key5 = decode(mod(line_number,4),1,'Printers',2,'Scanners',3,'Monitors')
  --   ,source_data_key4 = mod(line_number,4)
  --where interface_line_attribute9 <> 'Service';
  --
  -- Don't change any of the updates below.

  update ra_customer_Trx_lines
  set source_data_key5 = get_group_name (source_data_key1, source_data_key2)
     ,source_data_key4 = get_group_id (source_data_key1, source_data_key2)
  where customer_trx_id = x_customer_trx_id
  AND interface_line_attribute9 = 'Service';


exception
  when others then
    raise;
end;


function  get_group_id (sdk1 in varchar2, sdk2 in varchar2) return number is
--This sample procedure gets dummy group id from Source_data_key2
-- if the line is not a 'Service' line interfaced from OKS product
  group_id number;
begin

 select srv.id
   into group_id
 from oks_billprst_srvline_v srv
 where srv.id(+) = sdk1
  and srv.bcl_id(+) = sdk2
  and rownum = 1;

return group_id;
exception
  when others then
    raise;
end;


function get_group_name (sdk1 in varchar2, sdk2 in varchar2) return varchar2 is
--This sample procedure gets dummy group names from Source_data_key1
-- if the line is not a 'Service' line interfaced from OKS product
  group_name varchar2(150);
begin
 select srv.name
 into group_name
 from oks_billprst_srvline_v srv
 where srv.id(+) = sdk1
  and srv.bcl_id(+) = sdk2
  and rownum = 1;

return group_name;
exception
  when others then
    raise;
end;


END AR_LL_RCV_GROUPING_HOOK;

/
