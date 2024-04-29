--------------------------------------------------------
--  DDL for Package BEN_LETRG_CACHE
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."BEN_LETRG_CACHE" AUTHID CURRENT_USER as
/* $Header: beltrgch.pkh 120.0 2005/05/28 03:39:18 appldev noship $*/
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
  115.0      14-Sep-00	mhoyes     Created.
  115.1      01-May-01	mhoyes     Added PRV and PEN caches.
  115.2      01-May-01	tjesumic   typ_cd added .
  -----------------------------------------------------------------------------
*/
--
type g_egdlertrg_inst_row is record
  (ler_id         ben_ler_f.ler_id%type
  ,typ_cd          ben_ler_f.typ_cd%type
  ,OCRD_DT_DET_CD ben_ler_f.OCRD_DT_DET_CD%type
  );
--
type g_egdlertrg_inst_tbl is table of g_egdlertrg_inst_row
  index by binary_integer;
--
procedure get_egdlertrg_dets
  (p_business_group_id in     number
  ,p_effective_date    in     date
  ,p_inst_set	       in out NOCOPY g_egdlertrg_inst_tbl
  );
--
procedure get_prvlertrg_dets
  (p_business_group_id in     number
  ,p_effective_date    in     date
  ,p_inst_set	       in out NOCOPY g_egdlertrg_inst_tbl
  );
--
procedure get_penlertrg_dets
  (p_business_group_id in     number
  ,p_effective_date    in     date
  ,p_inst_set	       in out NOCOPY g_egdlertrg_inst_tbl
  );
--
------------------------------------------------------------------------
-- DELETE CACHED DATA
------------------------------------------------------------------------
procedure clear_down_cache;
--
procedure set_no_cache;
--
END ben_letrg_cache;

 

/
