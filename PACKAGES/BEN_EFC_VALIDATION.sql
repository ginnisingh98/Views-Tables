--------------------------------------------------------
--  DDL for Package BEN_EFC_VALIDATION
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."BEN_EFC_VALIDATION" AUTHID CURRENT_USER as
/* $Header: beefcval.pkh 120.0 2005/05/28 02:09:16 appldev noship $*/
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
  115.1      26-Jul-01	mhoyes     Enhanced for Patchset E+ patch.
  115.2      31-Aug-01	mhoyes     Enhanced for BEN July patch.
  115.3      13-Sep-01	mhoyes     Enhanced for BEN July patch.
  -----------------------------------------------------------------------------
*/
--
procedure adjust_validation
  (p_worker_id           in     number   default null
  ,p_total_workers       in     number   default null
  ,p_ent_scode           in     varchar2 default null
  --
  ,p_disp_private        in     boolean  default false
  ,p_disp_succeeds       in     boolean  default false
  ,p_disp_exclusions     in     boolean  default false
  --
  ,p_valworker_id        in     number   default null
  ,p_valtotal_workers    in     number   default null
  --
  ,p_multithread_substep in     number   default null
  --
  ,p_business_group_id   in     number   default null
  );
--
END ben_efc_validation;

 

/
