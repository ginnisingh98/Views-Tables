--------------------------------------------------------
--  DDL for Package PER_REC_ACTIVITY_FOR_BK3
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PER_REC_ACTIVITY_FOR_BK3" AUTHID CURRENT_USER as
/* $Header: percfapi.pkh 120.1 2005/10/02 02:23:35 aroussel $ */
--
-- ----------------------------------------------------------------------------
-- |-------------------------< DELETE_REC_ACTIVITY_FOR_B >--------------------|
-- ----------------------------------------------------------------------------
--
procedure DELETE_REC_ACTIVITY_FOR_B
  (
   p_rec_activity_for_id           in     number
  ,p_object_version_number         in     number
  );
--
-- ----------------------------------------------------------------------------
-- |-------------------------< DELETE_REC_ACTIVITY_FOR_A >--------------------|
-- ----------------------------------------------------------------------------
--
procedure DELETE_REC_ACTIVITY_FOR_A
  (
   p_rec_activity_for_id           in     number
  ,p_object_version_number         in     number
  );
--
end PER_REC_ACTIVITY_FOR_BK3;

 

/
