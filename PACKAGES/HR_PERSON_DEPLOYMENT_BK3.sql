--------------------------------------------------------
--  DDL for Package HR_PERSON_DEPLOYMENT_BK3
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."HR_PERSON_DEPLOYMENT_BK3" AUTHID CURRENT_USER as
/* $Header: hrpdtapi.pkh 120.5 2007/10/01 10:00:52 ghshanka noship $ */
--
-- ----------------------------------------------------------------------------
-- |-------------------------< delete_person_deployment_b >-------------------|
-- ----------------------------------------------------------------------------
--
procedure delete_person_deployment_b
  (p_person_deployment_id          in     number
  ,p_object_version_number         in     number
  );
--
-- ----------------------------------------------------------------------------
-- |-------------------------< delete_person_deployment_a >-------------------|
-- ----------------------------------------------------------------------------
--
procedure delete_person_deployment_a
  (p_person_deployment_id          in     number
  ,p_object_version_number         in     number
  );
--
end HR_PERSON_DEPLOYMENT_BK3;

/
