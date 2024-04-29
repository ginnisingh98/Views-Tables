--------------------------------------------------------
--  DDL for Package BEN_CWB_PERSON_INFO_BK3
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."BEN_CWB_PERSON_INFO_BK3" AUTHID CURRENT_USER as
/* $Header: becpiapi.pkh 120.2 2005/10/17 04:59:32 steotia noship $ */
--
-- ----------------------------------------------------------------------------
-- |-------------------------< delete_person_info_b >-------------------------|
-- ----------------------------------------------------------------------------
--
procedure delete_person_info_b
  (p_group_per_in_ler_id         in     number
  ,p_object_version_number       in     number
  );
--
-- ----------------------------------------------------------------------------
-- |-------------------------< delete_person_info_a >-------------------------|
-- ----------------------------------------------------------------------------
--
procedure delete_person_info_a
  (p_group_per_in_ler_id         in     number
  ,p_object_version_number       in     varchar2
  );
--
end BEN_CWB_PERSON_INFO_BK3;

 

/
