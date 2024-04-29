--------------------------------------------------------
--  DDL for Package PER_ESTAB_ATTENDANCES_BK3
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PER_ESTAB_ATTENDANCES_BK3" AUTHID CURRENT_USER as
/* $Header: peesaapi.pkh 120.1 2005/10/02 02:16:54 aroussel $ */
--
--
--
-- ----------------------------------------------------------------------------
-- |-----------------------< DELETE_ATTENDED_ESTAB_b >------------------------|
-- ----------------------------------------------------------------------------
--
procedure DELETE_ATTENDED_ESTAB_b
  (p_attendance_id                 in     number
  ,p_object_version_number         in     number
  );
--
--
-- ----------------------------------------------------------------------------
-- |-----------------------< DELETE_ATTENDED_ESTAB_a >------------------------|
-- ----------------------------------------------------------------------------
--
procedure DELETE_ATTENDED_ESTAB_a
  (p_attendance_id                 in     number
  ,p_object_version_number         in     number
  );
--
end PER_ESTAB_ATTENDANCES_BK3;

 

/
