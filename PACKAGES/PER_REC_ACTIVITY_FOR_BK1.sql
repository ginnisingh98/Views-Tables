--------------------------------------------------------
--  DDL for Package PER_REC_ACTIVITY_FOR_BK1
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PER_REC_ACTIVITY_FOR_BK1" AUTHID CURRENT_USER as
/* $Header: percfapi.pkh 120.1 2005/10/02 02:23:35 aroussel $ */
--
-- ----------------------------------------------------------------------------
-- |-------------------------< CREATE_REC_ACTIVITY_FOR_B >--------------------|
-- ----------------------------------------------------------------------------
--
procedure CREATE_REC_ACTIVITY_FOR_B
  (
   p_rec_activity_for_id             in     number
  ,p_business_group_id               in     number
  ,p_vacancy_id                      in     number
  ,p_rec_activity_id                 in     number
  );
--
-- ----------------------------------------------------------------------------
-- |-------------------------< CREATE_REC_ACTIVITY_FOR_A >--------------------|
-- ----------------------------------------------------------------------------
--
procedure CREATE_REC_ACTIVITY_FOR_A
  (
   p_rec_activity_for_id             in     number
  ,p_business_group_id               in     number
  ,p_vacancy_id                      in     number
  ,p_rec_activity_id                 in     number
  ,p_object_version_number           in     number
  );
--
end PER_REC_ACTIVITY_FOR_BK1;

 

/
