--------------------------------------------------------
--  DDL for Package PQP_EXCEPTION_GROUP_BK3
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PQP_EXCEPTION_GROUP_BK3" AUTHID CURRENT_USER as
/* $Header: pqergapi.pkh 120.0 2005/05/29 01:45:11 appldev noship $ */
--
-- ----------------------------------------------------------------------------
-- |------------------< delete_exception_group_b >------------------------|
-- ----------------------------------------------------------------------------
--
procedure delete_exception_group_b
  (p_exception_group_id            in     number
  ,p_object_version_number         in     number
  );
--
-- ----------------------------------------------------------------------------
-- |------------------< delete_exception_group_a >------------------------|
-- ----------------------------------------------------------------------------
--
procedure delete_exception_group_a
  (p_exception_group_id            in     number
  ,p_object_version_number         in     number
  );
--
end pqp_exception_group_bk3;

 

/
