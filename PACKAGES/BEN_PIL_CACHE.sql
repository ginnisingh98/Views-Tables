--------------------------------------------------------
--  DDL for Package BEN_PIL_CACHE
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."BEN_PIL_CACHE" AUTHID CURRENT_USER as
/* $Header: benpilch.pkh 115.2 2003/02/12 12:07:50 rpgupta noship $*/
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
  115.0      17-Aug-01	mhoyes       Created.
  115.1      26-Nov-01	mhoyes     - dbdrv lines.
  -----------------------------------------------------------------------------
*/
--
type g_pil_inst_row is record
  (per_in_ler_id  ben_per_in_ler.per_in_ler_id%type
  ,ntfn_dt        ben_per_in_ler.ntfn_dt%type
  );
--
procedure PIL_GetPILDets
  (p_per_in_ler_id in     number
  ,p_inst_row      in out NOCOPY g_pil_inst_row
  );
--
------------------------------------------------------------------------
-- DELETE CACHED DATA
------------------------------------------------------------------------
procedure clear_down_cache;
--
END ben_pil_cache;

 

/
