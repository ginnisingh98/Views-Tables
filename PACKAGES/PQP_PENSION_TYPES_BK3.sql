--------------------------------------------------------
--  DDL for Package PQP_PENSION_TYPES_BK3
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PQP_PENSION_TYPES_BK3" AUTHID CURRENT_USER As
/* $Header: pqptyapi.pkh 120.1.12000000.1 2007/01/16 04:28:57 appldev noship $ */
--
-- ----------------------------------------------------------------------------
-- |-------------------------< Delete_Pension_Type_b >-------------------------|
-- ----------------------------------------------------------------------------
--
Procedure Delete_Pension_Type_b
  (p_validate              in     boolean
  ,p_effective_date        in     date
  ,p_datetrack_mode        in     varchar2
  ,p_pension_type_id       in     number
  ,p_object_version_number in     number
   );

-- ----------------------------------------------------------------------------
-- |-------------------------< Delete_Pension_Type_a >-------------------------|
-- ----------------------------------------------------------------------------
--
Procedure Delete_Pension_Type_a
  (p_validate              in     boolean
  ,p_effective_date        in     date
  ,p_datetrack_mode        in     varchar2
  ,p_pension_type_id       in     number
  ,p_object_version_number in     number
  ,p_effective_start_date  in     date
  ,p_effective_end_date    in     date
   );

End PQP_Pension_Types_BK3;

 

/
