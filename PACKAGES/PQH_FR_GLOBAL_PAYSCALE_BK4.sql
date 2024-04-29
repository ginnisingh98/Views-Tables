--------------------------------------------------------
--  DDL for Package PQH_FR_GLOBAL_PAYSCALE_BK4
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PQH_FR_GLOBAL_PAYSCALE_BK4" AUTHID CURRENT_USER as
/* $Header: pqginapi.pkh 120.1 2005/10/02 02:45:05 aroussel $ */

-- ----------------------------------------------------------------------------
-- |-------------------------< update_global_index_b >----------------|
-- ----------------------------------------------------------------------------
--
procedure update_global_index_b
  (p_effective_date               in     date
   ,p_datetrack_mode               in     varchar2
   ,p_global_index_id              in     number
   ,p_object_version_number        in     number
   ,p_gross_index                  in     number
   ,p_increased_index              in     number
   ,p_effective_start_date         in	  date
   ,p_effective_end_date           in	  date
   );

--
-- ----------------------------------------------------------------------------
-- |-------------------------< update_global_index_a >----------------|
-- ----------------------------------------------------------------------------
--
procedure update_global_index_a
  (p_effective_date               in     date
   ,p_datetrack_mode               in     varchar2
   ,p_global_index_id              in     number
   ,p_object_version_number        in     number
   ,p_gross_index                  in     number
   ,p_increased_index              in     number
   ,p_effective_start_date         in	  date
   ,p_effective_end_date           in	  date
   );
--
end pqh_fr_global_payscale_bk4;

 

/
