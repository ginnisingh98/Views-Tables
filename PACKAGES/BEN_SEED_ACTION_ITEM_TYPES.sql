--------------------------------------------------------
--  DDL for Package BEN_SEED_ACTION_ITEM_TYPES
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."BEN_SEED_ACTION_ITEM_TYPES" AUTHID CURRENT_USER as
/* $Header: benactse.pkh 120.0 2005/05/28 03:42:01 appldev noship $ */
--------------------------------------------------------------------------------
/*
+==============================================================================+
|			Copyright (c) 1997 Oracle Corporation		       |
|			   Redwood Shores, California, USA		       |
|			        All rights reserved.			       |
+==============================================================================+

Name
	Seed Action Item Types
Purpose
	This package is used to seed action item types which are benefit specific.
        It operates on a business group basis.
History
        Date             Who        Version    What?
        ----             ---        -------    -----
        18 Jun 98        S Tee      110.0      Created.
*/
-----------------------------------------------------------------------
procedure seed_action_item_types(p_business_group_id in number);
--
end ben_seed_action_item_types;

 

/
