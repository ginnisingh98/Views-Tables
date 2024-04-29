--------------------------------------------------------
--  DDL for Package GHR_COMPLAINT_BASES_BK_3
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."GHR_COMPLAINT_BASES_BK_3" AUTHID CURRENT_USER as
/* $Header: ghcbaapi.pkh 120.1 2005/10/02 01:57:14 aroussel $ */
--
-- ----------------------------------------------------------------------------
-- |-------------------------< delete_compl_basis_b >-------------------------|
-- ----------------------------------------------------------------------------
--
procedure delete_compl_basis_b
  (p_compl_basis_id               in number
  ,p_object_version_number        in number
  );
--
-- ----------------------------------------------------------------------------
-- |-------------------------< delete_compl_basis_a >-------------------------|
-- ----------------------------------------------------------------------------
--
procedure delete_compl_basis_a
  (p_compl_basis_id               in number
  ,p_object_version_number        in number
  );
--
end ghr_complaint_bases_bk_3;

 

/
