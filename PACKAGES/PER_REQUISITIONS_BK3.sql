--------------------------------------------------------
--  DDL for Package PER_REQUISITIONS_BK3
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PER_REQUISITIONS_BK3" AUTHID CURRENT_USER as
/* $Header: pereqapi.pkh 120.1 2005/10/02 02:23:47 aroussel $ */
--
-- ----------------------------------------------------------------------------
-- |-------------------------< DELETE_REQUISITION_b >-------------------------|
-- ----------------------------------------------------------------------------
--
procedure DELETE_REQUISITION_b
  (
   p_requisition_id                in     number
  ,p_object_version_number         in     number
  );
--
-- ----------------------------------------------------------------------------
-- |-------------------------< DELETE_REQUISITION_a >-------------------------|
-- ----------------------------------------------------------------------------
--
procedure DELETE_REQUISITION_a
  (
   p_requisition_id                in     number
  ,p_object_version_number         in     number
  );
--
end PER_REQUISITIONS_BK3;

 

/
