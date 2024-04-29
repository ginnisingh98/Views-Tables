--------------------------------------------------------
--  DDL for Package INVPUPI2
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."INVPUPI2" AUTHID CURRENT_USER as
/* $Header: INVPUP2S.pls 115.6 2004/07/28 10:34:51 mantyaku ship $ */

function validate_flags(
   org_id     IN            NUMBER
  ,all_org    IN            NUMBER  := 2
  ,prog_appid IN            NUMBER  := -1
  ,prog_id    IN            NUMBER  := -1
  ,request_id IN            NUMBER  := -1
  ,user_id    IN            NUMBER  := -1
  ,login_id   IN            NUMBER  := -1
  ,xset_id    IN            NUMBER  := -999
  ,err_text   IN OUT NOCOPY VARCHAR2
)
return integer;

end INVPUPI2;

 

/
