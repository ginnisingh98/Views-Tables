--------------------------------------------------------
--  DDL for Package BEN_EFC_REPORTING
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."BEN_EFC_REPORTING" AUTHID CURRENT_USER as
/* $Header: beefcrep.pkh 120.0 2005/05/28 02:08:38 appldev noship $*/
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
  115.0      13-Aug-01	mhoyes     Created.
  -----------------------------------------------------------------------------
*/
--
-----------------------------------------------------------------------
--
--  ---------------------------------------------------------------------------
--  |--------------------------< DisplayEFCInfo >-----------------------------|
--  ---------------------------------------------------------------------------
--
--  Display EFC information
--
procedure DisplayEFCInfo
  (p_ent_scode           in     varchar2
  ,p_efc_action_id       in     number default null
  --
  ,p_disp_private        in     boolean default false
  ,p_disp_succeeds       in     boolean default false
  ,p_disp_exclusions     in     boolean default false
  --
  ,p_adjustment_counts   in     ben_efc_adjustments.g_adjustment_counts
  ,p_rcoerr_val_set      in     ben_efc_adjustments.g_rcoerr_values_tbl
  ,p_failed_adj_val_set  in     ben_efc_adjustments.g_failed_adj_values_tbl
  ,p_fatal_error_val_set in     ben_efc_adjustments.g_failed_adj_values_tbl
  ,p_success_val_set     in     ben_efc_adjustments.g_failed_adj_values_tbl
  );
--
end ben_efc_reporting;

 

/
