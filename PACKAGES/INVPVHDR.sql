--------------------------------------------------------
--  DDL for Package INVPVHDR
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."INVPVHDR" AUTHID CURRENT_USER as
/* $Header: INVPVD1S.pls 115.3 2002/12/01 02:08:23 rbande ship $ */

function validate_item_header
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

end INVPVHDR;

 

/
