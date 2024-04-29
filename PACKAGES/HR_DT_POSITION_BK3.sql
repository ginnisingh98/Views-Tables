--------------------------------------------------------
--  DDL for Package HR_DT_POSITION_BK3
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."HR_DT_POSITION_BK3" AUTHID CURRENT_USER as
/* $Header: hrpsfapi.pkh 115.5 2000/05/10 03:55:05 pkm ship    $ */
--
-- ----------------------------------------------------------------------------
-- |---------------------------< delete_dt_position_b >-----------------|
-- ----------------------------------------------------------------------------
--
procedure delete_dt_position_b
  (
   p_position_id                    in  number
  ,p_object_version_number          in  number
  ,p_effective_date                 in  date
   ,p_datetrack_mode              in varchar2
  );
--
-- ----------------------------------------------------------------------------
-- |---------------------------< delete_dt_position_a >-----------------|
-- ----------------------------------------------------------------------------
--
procedure delete_dt_position_a
  (
   p_position_id                    in  number
  ,p_effective_start_date           in  date
  ,p_effective_end_date             in  date
  ,p_object_version_number          in  number
  ,p_effective_date                 in  date
   ,p_datetrack_mode              in varchar2
  );
--
end hr_dt_position_bk3;

 

/
