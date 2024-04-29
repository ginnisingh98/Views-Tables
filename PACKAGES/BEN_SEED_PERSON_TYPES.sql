--------------------------------------------------------
--  DDL for Package BEN_SEED_PERSON_TYPES
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."BEN_SEED_PERSON_TYPES" AUTHID CURRENT_USER as
/* $Header: benpptse.pkh 120.0 2005/05/28 09:18:18 appldev noship $ */
--------------------------------------------------------------------------------
/*
+==============================================================================+
|			Copyright (c) 1997 Oracle Corporation		       |
|			   Redwood Shores, California, USA		       |
|			        All rights reserved.			       |
+==============================================================================+

Name
	Seed Person Types
Purpose
	This package is used to seed person types which are benefit specific.
        It operates on a business group basis.
History
        Date             Who        Version    What?
        ----             ---        -------    -----
        16 Jun 98        G Perry    110.0      Created.
*/
-----------------------------------------------------------------------
procedure seed_person_types(p_business_group_id in number);
--
end ben_seed_person_types;

 

/
