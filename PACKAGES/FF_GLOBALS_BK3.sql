--------------------------------------------------------
--  DDL for Package FF_GLOBALS_BK3
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."FF_GLOBALS_BK3" AUTHID CURRENT_USER as
/* $Header: fffglapi.pkh 120.0.12010000.3 2008/10/31 12:26:02 pvelugul ship $ */
--
-- ----------------------------------------------------------------------------
-- |------------------------------< delete_global_b >-------------------------|
-- ----------------------------------------------------------------------------
--
procedure delete_global_b
(p_effective_date                in     date
,p_global_id                     in     number
,p_datetrack_update_mode         in     varchar2
,p_object_version_number         in     number
);
--
-- ----------------------------------------------------------------------------
-- |------------------------------< delete_global_a >-------------------------|
-- ----------------------------------------------------------------------------
--
procedure delete_global_a
(p_effective_date                in     date
,p_global_id                     in     number
,p_datetrack_update_mode         in     varchar2
,p_object_version_number         in     number
,p_effective_start_date          in     date
,p_effective_end_date            in     date
);
--
end ff_globals_bk3;

/
