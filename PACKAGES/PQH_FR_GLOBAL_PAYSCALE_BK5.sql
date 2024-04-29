--------------------------------------------------------
--  DDL for Package PQH_FR_GLOBAL_PAYSCALE_BK5
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PQH_FR_GLOBAL_PAYSCALE_BK5" AUTHID CURRENT_USER as
/* $Header: pqginapi.pkh 120.1 2005/10/02 02:45:05 aroussel $ */
--
-- ----------------------------------------------------------------------------
-- |-------------------------< delete_indemnity_rate_b>-------------------------|
-- ----------------------------------------------------------------------------
--
procedure delete_indemnity_rate_b
  (p_effective_date                   in     date
   ,p_datetrack_mode                   in     varchar2
   ,p_global_index_id                  in     number
   ,p_object_version_number            in     number
  );

--
-- ----------------------------------------------------------------------------
-- |-------------------------< delete_indemnity_rate_a>-------------------------|
-- ----------------------------------------------------------------------------
--
procedure delete_indemnity_rate_a
  (p_effective_date                   in     date
   ,p_datetrack_mode                   in     varchar2
   ,p_global_index_id                  in     number
   ,p_object_version_number            in     number
   ,p_effective_start_date             in     date
   ,p_effective_end_date               in     date
  );
--
--
end pqh_fr_global_payscale_bk5;

 

/
