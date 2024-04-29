--------------------------------------------------------
--  DDL for Package BEN_SEED_REGULATIONS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."BEN_SEED_REGULATIONS" AUTHID CURRENT_USER as
/* $Header: benregse.pkh 120.0 2005/05/28 09:25:53 appldev noship $ */
--------------------------------------------------------------------------------
/*
+==============================================================================+
|			Copyright (c) 1997 Oracle Corporation		       |
|			   Redwood Shores, California, USA		       |
|			        All rights reserved.			       |
+==============================================================================+

Name
	Seed Regulations
Purpose
	This package is used to seed regulations.
        It operates on a business group basis.
History
        Date             Who        Version    What?
        ----             ---        -------    -----
        26 Oct 99        S Tee      115.0      Created.
*/
-----------------------------------------------------------------------
procedure seed_regulations(p_business_group_id in number);
--
end ben_seed_regulations;

 

/
