--------------------------------------------------------
--  DDL for Package INVPVALM
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."INVPVALM" AUTHID CURRENT_USER as
/* $Header: INVPVM1S.pls 115.5 2002/12/01 02:10:38 rbande ship $ */

/*NP   03OCT94 Note that in each of the functions validate_item_org_%
**     there is a major if clause for whether the
**     item master is in MSI or in MSII
**     Essentially the MSII clause is useless now with the TWO_PASS design..
**     The item master HAS to be in MSI before you process the children
**     However the (redundant) code has been maintained in all these functions
**     for future releases
*/

function validate_item_org1
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

/*Removed declarations of _org2 and _org3 as these were merged into _org1 */


end INVPVALM;

 

/
