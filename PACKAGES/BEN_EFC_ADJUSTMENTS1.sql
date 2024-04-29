--------------------------------------------------------
--  DDL for Package BEN_EFC_ADJUSTMENTS1
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."BEN_EFC_ADJUSTMENTS1" AUTHID CURRENT_USER as
/* $Header: beefcaj1.pkh 115.4 2002/12/31 23:58:24 mmudigon noship $*/
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
  115.0      12-Jul-01	mhoyes     Created.
  115.1      17-Aug-01	mhoyes     Enhanced for BEN July patch.
  115.2      27-Aug-01	mhoyes     Added parameter to
                                   get_cust_mapped_rounding_code.
  115.3      31-Aug-01	mhoyes     Enhanced for BEN July patch.
  115.4      30-Dec-02  mmudigon   NOCOPY
  -----------------------------------------------------------------------------
*/
--
procedure prv_adjustments
  (p_validate          in     boolean default false
  ,p_worker_id         in     number  default null
  ,p_action_id         in     number  default null
  ,p_total_workers     in     number  default null
  ,p_pk1               in     number  default null
  ,p_chunk             in     number  default null
  ,p_efc_worker_id     in     number  default null
  --
  ,p_valworker_id      in     number  default null
  ,p_valtotal_workers  in     number  default null
  --
  ,p_business_group_id in     number  default null
  --
  ,p_adjustment_counts    out nocopy ben_efc_adjustments.g_adjustment_counts
  );
--
procedure eev_adjustments
  (p_validate          in     boolean default false
  ,p_worker_id         in     number  default null
  ,p_action_id         in     number  default null
  ,p_total_workers     in     number  default null
  ,p_pk1               in     number  default null
  ,p_chunk             in     number  default null
  ,p_efc_worker_id     in     number  default null
  --
  ,p_valworker_id      in     number  default null
  ,p_valtotal_workers  in     number  default null
  --
  ,p_business_group_id in     number  default null
  --
  ,p_adjustment_counts    out nocopy ben_efc_adjustments.g_adjustment_counts
  );
--
procedure bpl_adjustments
  (p_validate          in     boolean default false
  ,p_worker_id         in     number  default null
  ,p_action_id         in     number  default null
  ,p_total_workers     in     number  default null
  ,p_pk1               in     number  default null
  ,p_chunk             in     number  default null
  ,p_efc_worker_id     in     number  default null
  --
  ,p_valworker_id      in     number  default null
  ,p_valtotal_workers  in     number  default null
  --
  ,p_business_group_id in     number  default null
  --
  ,p_adjustment_counts    out nocopy ben_efc_adjustments.g_adjustment_counts
  );
--
END ben_efc_adjustments1;

 

/
