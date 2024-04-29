--------------------------------------------------------
--  DDL for Package BEN_SEED_LIFE_EVENTS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."BEN_SEED_LIFE_EVENTS" AUTHID CURRENT_USER as
/* $Header: benlerse.pkh 120.0 2005/05/28 09:06:19 appldev noship $ */
--------------------------------------------------------------------------------
/*
+==============================================================================+
|			Copyright (c) 1997 Oracle Corporation		       |
|			   Redwood Shores, California, USA		       |
|			        All rights reserved.			       |
+==============================================================================+

Name
	Seed Life Events
Purpose
	This package is used to seed standard derivable factor life events.
        It operates on a business group basis.
History
        Date             Who        Version    What?
        ----             ---        -------    -----
        24 Jan 98        G Perry    110.0      Created.
*/
-----------------------------------------------------------------------
procedure seed_life_events(p_business_group_id in number);
--
end ben_seed_life_events;

 

/
