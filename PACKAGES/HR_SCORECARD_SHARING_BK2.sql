--------------------------------------------------------
--  DDL for Package HR_SCORECARD_SHARING_BK2
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."HR_SCORECARD_SHARING_BK2" AUTHID CURRENT_USER as
/* $Header: pepshapi.pkh 120.1 2006/10/16 23:38:56 tpapired noship $ */
--
-- ----------------------------------------------------------------------------
-- |-------------------------< delete_sharing_instance_b >--------------------|
-- ----------------------------------------------------------------------------
--
procedure delete_sharing_instance_b
  (p_sharing_instance_id           in     number
  ,p_object_version_number         in     number
  );
--
-- ----------------------------------------------------------------------------
-- |-------------------------< delete_sharing_instance_a >--------------------|
-- ----------------------------------------------------------------------------
--
procedure delete_sharing_instance_a
  (p_sharing_instance_id           in     number
  ,p_object_version_number         in     number
  );
--
end hr_scorecard_sharing_bk2;

 

/
