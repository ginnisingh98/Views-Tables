--------------------------------------------------------
--  DDL for Package BEN_COMP_OBJECT_LIST1
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."BEN_COMP_OBJECT_LIST1" AUTHID CURRENT_USER AS
/* $Header: bebmbcl1.pkh 120.0.12000000.1 2007/01/19 01:09:29 appldev noship $ */
--
PROCEDURE populate_comp_object_list
  (p_comp_obj_cache_id      in     number
  ,p_business_group_id      in     number
  ,p_comp_selection_rule_id in     number
  ,p_effective_date         in     date
  );
--
PROCEDURE refresh_eff_date_caches;
--
END ben_comp_object_list1;

 

/
