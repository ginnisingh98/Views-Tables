--------------------------------------------------------
--  DDL for Package INVPUTLI
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."INVPUTLI" AUTHID CURRENT_USER as
/* $Header: INVPUL1S.pls 120.2 2007/05/17 09:54:25 anmurali ship $ */

procedure info (P_message varchar2);

function get_dynamic_sql_str
(
dyn_sql_num  in        number,
sql_text     out       NOCOPY varchar2,
err_text     out       NOCOPY varchar2
)
return integer;

function assign_master_defaults
(
tran_id		number,
item_id         number,
org_id          number,
master_org_id	number,
status_default  varchar2,
uom_default	varchar2,
allow_item_desc_flag varchar2,
req_required_flag    varchar2,
err_text out    NOCOPY varchar2,
xset_id  in     number DEFAULT -999,
p_rowid         rowid
)
return integer;

function assign_item_defaults
(
item_id         number,
org_id          number,
status_default  varchar2,
uom_default	varchar2,
allow_item_desc_flag varchar2,
req_required_flag    varchar2,
tax_flag	varchar2,
err_text out    NOCOPY varchar2,
xset_id  in     number DEFAULT -999,
p_rowid         rowid,
v_receiving_flag varchar2
)
return integer;

FUNCTION predefault_child_master
(
   item_id              NUMBER,
   org_id               NUMBER,
   master_org_id        NUMBER,
   err_text out NOCOPY  VARCHAR2,
   xset_id  in          NUMBER DEFAULT -999 ,
   p_rowid              ROWID
)
RETURN INTEGER;

function get_debug_level
return integer;

end INVPUTLI;

/
