--------------------------------------------------------
--  DDL for Package BEN_ORG_DELETE
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."BEN_ORG_DELETE" AUTHID CURRENT_USER as
/* $Header: bebgdchk.pkh 120.0 2005/05/28 00:41:18 appldev noship $ */
  procedure perform_ri_check(p_bg_id in number);
  procedure delete_below_bg(p_bg_id in number);
  procedure delete_below_org(p_org_id in number);
end ben_org_delete;

 

/
