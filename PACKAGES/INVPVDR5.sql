--------------------------------------------------------
--  DDL for Package INVPVDR5
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."INVPVDR5" AUTHID CURRENT_USER as
/* $Header: INVPVD5S.pls 115.4 2002/12/01 02:09:40 rbande ship $ */

function validate_item_header5
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

end INVPVDR5;

 

/
