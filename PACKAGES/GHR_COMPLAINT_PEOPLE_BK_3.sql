--------------------------------------------------------
--  DDL for Package GHR_COMPLAINT_PEOPLE_BK_3
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."GHR_COMPLAINT_PEOPLE_BK_3" AUTHID CURRENT_USER as
/* $Header: ghcplapi.pkh 120.1 2005/10/02 01:57:40 aroussel $ */
--
-- ----------------------------------------------------------------------------
-- |-------------------------< delete_compl_person_b >-------------------------|
-- ----------------------------------------------------------------------------
--
procedure delete_compl_person_b
  (p_compl_person_id               in     number
  ,p_object_version_number         in     number
  );
--
-- ----------------------------------------------------------------------------
-- |-------------------------< delete_compl_person_a >-------------------------|
-- ----------------------------------------------------------------------------
--
procedure delete_compl_person_a
  (p_compl_person_id               in     number
  ,p_object_version_number         in     number
  );
--
end ghr_complaint_people_bk_3;

 

/
