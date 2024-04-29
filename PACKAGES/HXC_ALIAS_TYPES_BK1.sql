--------------------------------------------------------
--  DDL for Package HXC_ALIAS_TYPES_BK1
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."HXC_ALIAS_TYPES_BK1" AUTHID CURRENT_USER as
/* $Header: hxchatapi.pkh 120.0 2005/05/29 05:34:15 appldev noship $ */
--
-- ----------------------------------------------------------------------------
-- |-------------------------< create_alias_types_b >-------------------------|
-- ----------------------------------------------------------------------------
--
procedure create_alias_types_b
  (p_alias_type                    in     varchar2,
   p_reference_object              in     varchar2,
   p_alias_type_id                 in     number,
   p_object_version_number         in     number
  );
--
-- ----------------------------------------------------------------------------
-- |-------------------------< create_alias_types_a >-------------------------|
-- ----------------------------------------------------------------------------
--
procedure create_alias_types_a
  (p_alias_type                    in     varchar2,
   p_reference_object              in     varchar2,
   p_alias_type_id                 in     number,
   p_object_version_number         in     number
  );
--
-- ----------------------------------------------------------------------------
-- |-------------------------< update_alias_types_b >-------------------------|
-- ----------------------------------------------------------------------------
--
procedure update_alias_types_b
  (p_alias_type                    in     varchar2,
   p_reference_object              in     varchar2,
   p_alias_type_id                 in     number,
   p_object_version_number         in     number
  );
--
-- ----------------------------------------------------------------------------
-- |-------------------------< update_alias_types_a >-------------------------|
-- ----------------------------------------------------------------------------
--
procedure update_alias_types_a
  (p_alias_type                    in     varchar2,
   p_reference_object              in     varchar2,
   p_alias_type_id                 in     number,
   p_object_version_number         in     number
  );
--
-- ----------------------------------------------------------------------------
-- |-------------------------< delete_alias_types_b >-------------------------|
-- ----------------------------------------------------------------------------
--
procedure delete_alias_types_b
  (p_alias_type_id                 in     number,
   p_object_version_number         in     number
  );

--
-- ----------------------------------------------------------------------------
-- |-------------------------< delete_alias_types_a >-------------------------|
-- ----------------------------------------------------------------------------
--
procedure delete_alias_types_a
  (p_alias_type_id                 in     number,
   p_object_version_number         in     number
  );
end hxc_alias_types_bk1;

 

/
