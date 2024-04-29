--------------------------------------------------------
--  DDL for Package FF_GLOBALS_BK1
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."FF_GLOBALS_BK1" AUTHID CURRENT_USER as
/* $Header: fffglapi.pkh 120.0.12010000.3 2008/10/31 12:26:02 pvelugul ship $ */
--
-- ----------------------------------------------------------------------------
-- |------------------------------< create_global_b >-------------------------|
-- ----------------------------------------------------------------------------
--
procedure create_global_b
(p_effective_date                in     date
,p_global_name                   in     varchar2
,p_global_description            in     varchar2
,p_data_type                     IN     varchar2
,p_value                         in     varchar2
,p_business_group_id             in     number
,p_legislation_code              in     varchar2
);
--
-- ----------------------------------------------------------------------------
-- |------------------------------< create_global_a >-------------------------|
-- ----------------------------------------------------------------------------
--
procedure create_global_a
(p_effective_date                in     date
,p_global_name                   in     varchar2
,p_global_description            in     varchar2
,p_data_type                     IN     varchar2
,p_value                         in     varchar2
,p_business_group_id             in     number
,p_legislation_code              in     varchar2
,p_global_id                     in     number
,p_object_version_number         in     number
,p_effective_start_date          in     date
,p_effective_end_date            in     date
);
--
end ff_globals_bk1;

/
