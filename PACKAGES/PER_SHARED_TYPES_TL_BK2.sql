--------------------------------------------------------
--  DDL for Package PER_SHARED_TYPES_TL_BK2
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PER_SHARED_TYPES_TL_BK2" AUTHID CURRENT_USER as
/* $Header: pesttapi.pkh 115.2 2002/12/09 16:29:30 eumenyio ship $ */
--
-- ----------------------------------------------------------------------------
-- |---------------------------< update_shared_types_tl_b >-----------------|
-- ----------------------------------------------------------------------------
--
procedure update_shared_types_tl_b
  (
   p_shared_type_id                 in  number
  ,p_source_lang                    in  varchar2
  ,p_shared_type_name               in  varchar2
  );
--
-- ----------------------------------------------------------------------------
-- |---------------------------< update_shared_types_tl_a >-----------------|
-- ----------------------------------------------------------------------------
--
procedure update_shared_types_tl_a
  (
   p_shared_type_id                 in  number
  ,p_language                       in  varchar2
  ,p_source_lang                    in  varchar2
  ,p_shared_type_name               in  varchar2
  );
--
end per_shared_types_tl_bk2;

 

/
