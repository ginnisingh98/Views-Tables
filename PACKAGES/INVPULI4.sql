--------------------------------------------------------
--  DDL for Package INVPULI4
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."INVPULI4" AUTHID CURRENT_USER as
/* $Header: INVPUL4S.pls 120.0.12010000.2 2009/07/17 10:19:10 vggarg ship $ */

function assign_status_attributes
(
item_id                 number,
org_id                  number,
err_text out            NOCOPY varchar2,
xset_id  IN             NUMBER   DEFAULT -999,
p_rowid                 rowid,
master_org_id           NUMBER DEFAULT NULL
)
return integer;

end INVPULI4;

/
