--------------------------------------------------------
--  DDL for Package BEN_SEED_COMMUNICATION_TYPES
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."BEN_SEED_COMMUNICATION_TYPES" AUTHID CURRENT_USER as
/* $Header: bencmtse.pkh 120.0 2005/05/28 03:50:40 appldev noship $ */
--------------------------------------------------------------------------------
/*
+==============================================================================+
|			Copyright (c) 1997 Oracle Corporation		       |
|			   Redwood Shores, California, USA		       |
|			        All rights reserved.			       |
+==============================================================================+

Name
	Seed Communication Types
Purpose
	This package is used to seed communication types.
        It operates on a business group basis.
History
        Date             Who        Version    What?
        ----             ---        -------    -----
        31 Oct 98        S Tee      115.0      Created.
*/
-----------------------------------------------------------------------
procedure seed_communication_types(p_business_group_id in number);
--
end ben_seed_communication_types;

 

/
