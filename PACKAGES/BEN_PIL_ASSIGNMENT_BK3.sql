--------------------------------------------------------
--  DDL for Package BEN_PIL_ASSIGNMENT_BK3
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."BEN_PIL_ASSIGNMENT_BK3" as

--
-- ----------------------------------------------------------------------------
-- |---------------------------< delete_pil_assignment_b >-----------------|
-- ----------------------------------------------------------------------------
--
procedure delete_pil_assignment_b
  (
   p_pil_assignment_id              in  number
  ,p_object_version_number          in  number

  );
--
-- ----------------------------------------------------------------------------
-- |---------------------------< delete_pil_assignment_a >-----------------|
-- ----------------------------------------------------------------------------
--
procedure delete_pil_assignment_a
  (
   p_pil_assignment_id              in  number
  ,p_object_version_number          in  number
   );
--
end ben_pil_assignment_bk3;

 

/
