--------------------------------------------------------
--  DDL for Package HR_POSITION_BK3
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."HR_POSITION_BK3" AUTHID CURRENT_USER as
/* $Header: peposapi.pkh 120.5.12010000.1 2008/07/28 05:23:44 appldev ship $ */
--
--
g_debug boolean := hr_utility.debug_enabled;
--
--
-- ----------------------------------------------------------------------------
-- |---------------------------< delete_position_b >-----------------|
-- ----------------------------------------------------------------------------
--
procedure delete_position_b
  (
   p_position_id                    in  number
  ,p_object_version_number          in  number
  ,p_effective_date                 in  date
   ,p_datetrack_mode              in varchar2
  );
--
-- ----------------------------------------------------------------------------
-- |---------------------------< delete_position_a >-----------------|
-- ----------------------------------------------------------------------------
--
procedure delete_position_a
  (
   p_position_id                    in  number
  ,p_effective_start_date           in  date
  ,p_effective_end_date             in  date
  ,p_object_version_number          in  number
  ,p_effective_date                 in  date
   ,p_datetrack_mode              in varchar2
  );
--
end hr_position_bk3;

/
