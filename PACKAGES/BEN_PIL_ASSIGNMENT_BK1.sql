--------------------------------------------------------
--  DDL for Package BEN_PIL_ASSIGNMENT_BK1
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."BEN_PIL_ASSIGNMENT_BK1" as

--
-- ----------------------------------------------------------------------------
-- |---------------------------< create_pil_assignment_b >-----------------|
-- ----------------------------------------------------------------------------
--
procedure create_pil_assignment_b
  (
   p_per_in_ler_id                  in  number
  ,p_applicant_assignment_id        in  number
  ,p_offer_assignment_id            in  number
   );
--
-- ----------------------------------------------------------------------------
-- |---------------------------< create_pil_assignment_a >-----------------|
-- ----------------------------------------------------------------------------
--
procedure create_pil_assignment_a
  (
   p_pil_assignment_id              in  number
  ,p_per_in_ler_id                  in  number
  ,p_applicant_assignment_id        in  number
  ,p_offer_assignment_id            in  number
  ,p_object_version_number          in  number
   );
--
end ben_pil_assignment_bk1;

 

/
