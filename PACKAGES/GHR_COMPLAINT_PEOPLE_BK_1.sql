--------------------------------------------------------
--  DDL for Package GHR_COMPLAINT_PEOPLE_BK_1
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."GHR_COMPLAINT_PEOPLE_BK_1" AUTHID CURRENT_USER as
/* $Header: ghcplapi.pkh 120.1 2005/10/02 01:57:40 aroussel $ */
--
-- ----------------------------------------------------------------------------
-- |-------------------------< create_compl_person_b >-------------------------|
-- ----------------------------------------------------------------------------
--
procedure create_compl_person_b
  (p_effective_date                in     date
  ,p_person_id                      in     number
  ,p_complaint_id                   in     number
  ,p_role_code                      in     varchar2
  ,p_start_date                     in     date
  ,p_end_date                       in     date
  );
--
-- ----------------------------------------------------------------------------
-- |-------------------------< create_compl_person_a >-------------------------|
-- ----------------------------------------------------------------------------
--
procedure create_compl_person_a
  (p_effective_date                 in     date
  ,p_person_id                      in     number
  ,p_complaint_id                   in     number
  ,p_role_code                      in     varchar2
  ,p_start_date                     in     date
  ,p_end_date                       in     date
  ,p_compl_person_id                in     number
  ,p_object_version_number          in     number
  );
--
end ghr_complaint_people_bk_1;

 

/