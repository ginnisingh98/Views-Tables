--------------------------------------------------------
--  DDL for Package INVPVLM2
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."INVPVLM2" AUTHID CURRENT_USER AS
/* $Header: INVPVM2S.pls 115.5 2002/12/01 02:10:57 rbande ship $ */

function validate_item_org4
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

/*Removed declaration of _org5 and _org6 as they have been merged into _org4 */

END INVPVLM2;

 

/
