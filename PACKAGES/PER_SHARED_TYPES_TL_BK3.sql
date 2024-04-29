--------------------------------------------------------
--  DDL for Package PER_SHARED_TYPES_TL_BK3
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PER_SHARED_TYPES_TL_BK3" AUTHID CURRENT_USER as
/* $Header: pesttapi.pkh 115.2 2002/12/09 16:29:30 eumenyio ship $ */
--
-- ----------------------------------------------------------------------------
-- |---------------------------< delete_shared_types_tl_b >-----------------|
-- ----------------------------------------------------------------------------
--
procedure delete_shared_types_tl_b
  (
   p_shared_type_id                 in  number
  );
--
-- ----------------------------------------------------------------------------
-- |---------------------------< delete_shared_types_tl_a >-----------------|
-- ----------------------------------------------------------------------------
--
procedure delete_shared_types_tl_a
  (
   p_shared_type_id                 in  number
  ,p_language                       in  varchar2
  );
--
end per_shared_types_tl_bk3;

 

/
