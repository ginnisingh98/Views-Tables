--------------------------------------------------------
--  DDL for Package PQH_DOCUMENTS_BK3
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PQH_DOCUMENTS_BK3" AUTHID CURRENT_USER as
/* $Header: pqdocapi.pkh 120.1 2005/09/15 14:14:40 rthiagar noship $ */
--
-- ----------------------------------------------------------------------------
-- |-------------------------<delete_print_document_b>-------------------------|
-- ----------------------------------------------------------------------------
--
procedure delete_print_document_b
  (p_effective_date                   in     date
  ,p_datetrack_mode                   in     varchar2
  ,p_document_id                      in     number
  ,p_object_version_number            in     number
  );
--
-- ----------------------------------------------------------------------------
-- |-------------------------<delete_print_document_a>-------------------------|
-- ----------------------------------------------------------------------------
--
procedure delete_print_document_a
  (p_effective_date                   in     date
  ,p_datetrack_mode                   in     varchar2
  ,p_document_id                      in     number
  ,p_object_version_number            in     number
  ,p_effective_start_date             in     date
  ,p_effective_end_date               in     date
  );
--
end pqh_documents_bk3;

 

/
