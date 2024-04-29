--------------------------------------------------------
--  DDL for Package BEN_CWB_AUDIT_BK3
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."BEN_CWB_AUDIT_BK3" AUTHID CURRENT_USER as
/* $Header: beaudapi.pkh 120.4 2006/10/27 10:52:17 steotia noship $ */
--
-- -------------------------------------------------------------------------
-- |------------------------< delete_audit_entry_b >-----------------------|
-- -------------------------------------------------------------------------
--
procedure delete_audit_entry_b
  (p_cwb_audit_id                  in     number
  ,p_object_version_number         in     number
  );
--
-- -------------------------------------------------------------------------
-- |------------------------< delete_audit_entry_a >------------------------|
-- -------------------------------------------------------------------------
--
procedure delete_audit_entry_a
  (p_cwb_audit_id                  in     number
  ,p_object_version_number         in     number
  );
--
end BEN_CWB_AUDIT_BK3;

 

/
