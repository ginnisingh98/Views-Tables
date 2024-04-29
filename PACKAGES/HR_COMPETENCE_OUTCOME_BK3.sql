--------------------------------------------------------
--  DDL for Package HR_COMPETENCE_OUTCOME_BK3
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."HR_COMPETENCE_OUTCOME_BK3" AUTHID CURRENT_USER as
/* $Header: pecpoapi.pkh 120.1 2005/10/02 02:13 aroussel $ */
-- ----------------------------------------------------------------------------
-- |--------------------------< delete_outcome_b >-----------------------------|
-- ----------------------------------------------------------------------------
--
procedure delete_outcome_b
  (p_outcome_id	                   in     number
  ,p_object_version_number         in     number
  );
-- ----------------------------------------------------------------------------
-- |--------------------------< delete_outcome_a >-----------------------------|
-- ----------------------------------------------------------------------------
--
procedure delete_outcome_a
  (p_outcome_id                    in     number
  ,p_object_version_number         in     number
  );
end hr_competence_outcome_bk3;

 

/
