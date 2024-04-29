--------------------------------------------------------
--  DDL for Package INVNIRIS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."INVNIRIS" AUTHID CURRENT_USER AS
/* $Header: INVNIRIS.pls 120.1 2005/05/30 08:39:38 appldev  $ */

FUNCTION mtl_validate_nir_item
(
org_id          number,
all_org         NUMBER  DEFAULT 2,
prog_appid      NUMBER  DEFAULT -1,
prog_id         NUMBER  DEFAULT -1,
request_id      NUMBER  DEFAULT -1,
user_id         NUMBER  DEFAULT -1,
login_id        NUMBER  DEFAULT -1,
xset_id         NUMBER  DEFAULT -999,
err_text        IN OUT  NOCOPY VARCHAR2) RETURN INTEGER;

FUNCTION change_policy_check(
org_id          number,
all_org         NUMBER  DEFAULT 2,
prog_appid      NUMBER  DEFAULT -1,
prog_id         NUMBER  DEFAULT -1,
request_id      NUMBER  DEFAULT -1,
user_id         NUMBER  DEFAULT -1,
login_id        NUMBER  DEFAULT -1,
xset_id         NUMBER  DEFAULT -999,
err_text        IN OUT  NOCOPY VARCHAR2) RETURN INTEGER;

END INVNIRIS;

 

/
