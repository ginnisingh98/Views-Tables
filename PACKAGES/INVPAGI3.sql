--------------------------------------------------------
--  DDL for Package INVPAGI3
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."INVPAGI3" AUTHID CURRENT_USER as
/* $Header: INVPAG3S.pls 120.1 2007/05/14 14:05:34 anmurali ship $ */

function assign_item_revs
(
org_id          number,
all_org         NUMBER          := 2,
prog_appid      NUMBER          := -1,
prog_id         NUMBER          := -1,
request_id      NUMBER          := -1,
user_id         NUMBER          := -1,
login_id        NUMBER          := -1,
err_text in out NOCOPY varchar2,
xset_id  IN     NUMBER       DEFAULT -999,
default_flag IN  NUMBER    DEFAULT  1
)
return integer;


end INVPAGI3;

/
