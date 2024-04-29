--------------------------------------------------------
--  DDL for Package INVPASGI
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."INVPASGI" AUTHID CURRENT_USER as
/* $Header: INVPAG1S.pls 120.1 2007/05/14 14:00:00 anmurali ship $ */

function mtl_pr_assign_item_data(
org_id          number,
all_org         NUMBER          := 2,
prog_appid      NUMBER          := -1,
prog_id         NUMBER          := -1,
request_id      NUMBER          := -1,
user_id         NUMBER          := -1,
login_id        NUMBER          := -1,
err_text in out NOCOPY varchar2,
xset_id   IN     NUMBER       DEFAULT -999,
default_flag IN  NUMBER    DEFAULT  1
)
return integer;

end INVPASGI;

/
