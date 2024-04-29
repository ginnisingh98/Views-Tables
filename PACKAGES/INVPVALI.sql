--------------------------------------------------------
--  DDL for Package INVPVALI
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."INVPVALI" AUTHID CURRENT_USER AS
/* $Header: INVPVALS.pls 120.0.12010000.1 2008/07/24 01:43:51 appldev ship $ */

function validate_item_revs
(
org_id          number,
all_org         NUMBER          := 2,
prog_appid      NUMBER          := -1,
prog_id         NUMBER          := -1,
request_id      NUMBER          := -1,
user_id         NUMBER          := -1,
login_id        NUMBER          := -1,
err_text in out NOCOPY varchar2,
xset_id  IN     NUMBER  DEFAULT -999
)
return integer;

function mtl_pr_validate_item
(
org_id          number,
all_org         NUMBER          := 2,
prog_appid      NUMBER          := -1,
prog_id         NUMBER          := -1,
request_id      NUMBER          := -1,
user_id         NUMBER          := -1,
login_id        NUMBER          := -1,
err_text in out NOCOPY varchar2,
xset_id  IN     NUMBER  DEFAULT -999
)
return integer;

END INVPVALI;

/
