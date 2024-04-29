--------------------------------------------------------
--  DDL for Package INVPVDR7
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."INVPVDR7" AUTHID CURRENT_USER as
/* $Header: INVPVD7S.pls 120.0 2005/05/25 04:41:58 appldev noship $ */

function validate_item_header7
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

end INVPVDR7;

 

/
