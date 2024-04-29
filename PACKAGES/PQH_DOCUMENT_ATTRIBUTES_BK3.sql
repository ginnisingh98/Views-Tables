--------------------------------------------------------
--  DDL for Package PQH_DOCUMENT_ATTRIBUTES_BK3
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PQH_DOCUMENT_ATTRIBUTES_BK3" AUTHID CURRENT_USER as
/* $Header: pqdoaapi.pkh 120.0 2005/05/29 01:48:50 appldev noship $ */
--
-- ----------------------------------------------------------------------------
-- |-------------------------<delete_document_attribute_b>---------------------|
-- ----------------------------------------------------------------------------
--
procedure delete_document_attribute_b
  (p_effective_date                 in     date
  ,p_datetrack_mode                 in     varchar2
  ,p_document_attribute_id          in     number
  ,p_object_version_number          in     number
  );

--
-- ----------------------------------------------------------------------------
-- |-------------------------<delete_document_attribute_a>---------------------|
-- ----------------------------------------------------------------------------
--
procedure delete_document_attribute_a
  (p_effective_date                 in     date
  ,p_datetrack_mode                 in     varchar2
  ,p_document_attribute_id          in     number
  ,p_object_version_number          in 	   number
  ,p_effective_start_date           in     date
  ,p_effective_end_date     	    in     date
  );
--
end pqh_document_attributes_bk3;

 

/
