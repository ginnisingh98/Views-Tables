--------------------------------------------------------
--  DDL for Package INVPAGI2
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."INVPAGI2" AUTHID CURRENT_USER as
/* $Header: INVPAG2S.pls 120.1.12010000.2 2010/07/29 13:55:51 ccsingh ship $ */

function assign_item_header_recs(
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
--serial_tagging enh -- bug 9913552
-- creating this global var for passing copy_item_id to
-- this API for copying serial tag assignments.
G_copy_item_id NUMBER :=-999999;

end INVPAGI2;

/
