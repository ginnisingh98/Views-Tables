--------------------------------------------------------
--  DDL for Package INVPVLM3
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."INVPVLM3" AUTHID CURRENT_USER AS
/* $Header: INVPVM3S.pls 115.4 2002/12/01 02:11:15 rbande ship $ */

FUNCTION validate_item_org7
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

END INVPVLM3;

 

/
