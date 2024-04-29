--------------------------------------------------------
--  DDL for Package PQH_DOCUMENTS_BK2
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PQH_DOCUMENTS_BK2" AUTHID CURRENT_USER as
/* $Header: pqdocapi.pkh 120.1 2005/09/15 14:14:40 rthiagar noship $ */
--
-- ----------------------------------------------------------------------------
-- |-------------------------<update_print_document_b>-------------------------|
-- ----------------------------------------------------------------------------
--
procedure update_print_document_b
  (p_effective_date                 in     date
  ,p_datetrack_mode                 in     varchar2
  ,p_short_name                     in     varchar2
  ,p_document_name                  in 	   varchar2
  ,p_file_id                        in     number
  ,p_formula_id                     in     number
  ,p_enable_flag                    in     varchar2
  ,p_document_id                    in     number
  ,p_object_version_number          in     number
  ,p_document_category              in     varchar2
  /* Added for XDO changes */
  ,p_lob_code                       in     varchar2
  ,p_language                       in     varchar2
  ,p_territory                      in     varchar2
  );
--
-- ----------------------------------------------------------------------------
-- |-------------------------<update_print_document_a>-------------------------|
-- ----------------------------------------------------------------------------
--
procedure update_print_document_a
  (p_effective_date                 in     date
  ,p_datetrack_mode                 in     varchar2
  ,p_short_name                     in     varchar2
  ,p_document_name                  in 	   varchar2
  ,p_file_id                        in     number
  ,p_formula_id                     in     number
  ,p_enable_flag                    in     varchar2
  ,p_document_id                    in     number
  ,p_object_version_number          in     number
  ,p_effective_start_date           in     date
  ,p_effective_end_date             in     date
  ,p_document_category              in     varchar2
  /* Added for XDO changes */
  ,p_lob_code                       in     varchar2
  ,p_language                       in     varchar2
  ,p_territory                      in     varchar2
  );
--
end pqh_documents_bk2;

 

/
