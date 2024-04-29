--------------------------------------------------------
--  DDL for Package PQH_DOCUMENT_ATTRIBUTES_BK1
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PQH_DOCUMENT_ATTRIBUTES_BK1" AUTHID CURRENT_USER as
/* $Header: pqdoaapi.pkh 120.0 2005/05/29 01:48:50 appldev noship $ */
--
-- ----------------------------------------------------------------------------
-- |-------------------------<CREATE_DOCUMENT_ATTRIBUTE_b>-------------------------|
-- ----------------------------------------------------------------------------
--


procedure CREATE_DOCUMENT_ATTRIBUTE_b
    (  p_effective_date                 in     date
      ,p_document_id                    in     number
      ,p_attribute_id                   in     number
      ,p_tag_name                       in     varchar2
    );

--
-- ----------------------------------------------------------------------------
-- |-------------------------<CREATE_DOCUMENT_ATTRIBUTE_a>-------------------------|
-- ----------------------------------------------------------------------------
--
procedure CREATE_DOCUMENT_ATTRIBUTE_a
    (  p_effective_date                 in     date
      ,p_document_id                    in     number
      ,p_attribute_id                   in     number
      ,p_tag_name                       in     varchar2
      ,p_document_attribute_id          in     number
      ,p_object_version_number          in	number
      ,p_effective_start_date           in	date
      ,p_effective_end_date             in	date
    );
--
end pqh_document_attributes_bk1;

 

/
