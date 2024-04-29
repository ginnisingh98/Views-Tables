--------------------------------------------------------
--  DDL for Package INVPULI3
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."INVPULI3" AUTHID CURRENT_USER as
/* $Header: INVPUL3S.pls 120.1 2007/03/27 08:54:08 anmurali ship $ */

FUNCTION copy_item_attributes( org_id         IN            NUMBER
                              ,all_org        IN            NUMBER  := 2
                              ,prog_appid     IN            NUMBER  := -1
                              ,prog_id        IN            NUMBER  := -1
                              ,request_id     IN            NUMBER  := -1
                              ,user_id        IN            NUMBER  := -1
                              ,login_id       IN            NUMBER  := -1
                              ,xset_id        IN            NUMBER  := -999
                              ,err_text       IN OUT NOCOPY VARCHAR2 )
RETURN INTEGER;

end INVPULI3;

/
