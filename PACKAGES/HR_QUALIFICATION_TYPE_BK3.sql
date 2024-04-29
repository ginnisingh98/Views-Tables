--------------------------------------------------------
--  DDL for Package HR_QUALIFICATION_TYPE_BK3
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."HR_QUALIFICATION_TYPE_BK3" AUTHID CURRENT_USER as
/* $Header: peeqtapi.pkh 120.1 2005/10/02 02:16 aroussel $ */
-- ----------------------------------------------------------------------------
-- |-------------------< delete_qualification_type_b >-------------------------|
-- ----------------------------------------------------------------------------
--
procedure delete_qualification_type_b
  (p_qualification_type_id         in     number
  ,p_object_version_number         in     number
  );
-- ----------------------------------------------------------------------------
-- |-------------------< delete_qualification_type_a >-------------------------|
-- ----------------------------------------------------------------------------
--
procedure delete_qualification_type_a
  (p_qualification_type_id         in     number
  ,p_object_version_number         in     number
  );
end hr_qualification_type_bk3;

 

/
