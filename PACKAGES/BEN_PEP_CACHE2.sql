--------------------------------------------------------
--  DDL for Package BEN_PEP_CACHE2
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."BEN_PEP_CACHE2" AUTHID CURRENT_USER as
/* $Header: benpepc2.pkh 120.0 2005/06/03 08:20:32 appldev noship $*/
--
/*
+==============================================================================+
|			 Copyright (c) 1997 Oracle Corporation		       |
|			    Redwood Shores, California, USA		       |
|				All rights reserved.			       |
+==============================================================================+
--
History
  Version    Date	Who	   What?
  ---------  ---------	---------- --------------------------------------------
  115.0      30-May-05	mhoyes     Created.
  -----------------------------------------------------------------------------
*/
--
procedure write_pilpep_cache
  (p_person_id         in     number
  ,p_business_group_id in     number
  ,p_effective_date    in     date
  );
--
procedure write_pilepo_cache
  (p_person_id         in     number
  ,p_business_group_id in     number
  ,p_effective_date    in     date
  );
--
END ben_pep_cache2;

 

/
