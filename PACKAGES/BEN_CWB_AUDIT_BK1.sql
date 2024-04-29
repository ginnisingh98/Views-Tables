--------------------------------------------------------
--  DDL for Package BEN_CWB_AUDIT_BK1
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."BEN_CWB_AUDIT_BK1" AUTHID CURRENT_USER as
/* $Header: beaudapi.pkh 120.4 2006/10/27 10:52:17 steotia noship $ */
--
-- ------------------------------------------------------------------------
-- |------------------------< create_audit_entry_b >----------------------|
-- ------------------------------------------------------------------------
--
procedure create_audit_entry_b
  (p_group_per_in_ler_id           in     number
  ,p_group_pl_id                   in     number
  ,p_lf_evt_ocrd_dt                in     date
  ,p_pl_id                         in     number
  ,p_group_oipl_id                 in     number
  ,p_audit_type_cd                 in     varchar2
  ,p_old_val_varchar               in     varchar2
  ,p_new_val_varchar               in     varchar2
  ,p_old_val_number                in     number
  ,p_new_val_number                in     number
  ,p_old_val_date                  in     date
  ,p_new_val_date                  in     date
  ,p_date_stamp                    in     date
  ,p_change_made_by_person_id      in     number
  ,p_supporting_information        in     varchar2
  ,p_request_id                    in     number
  ,p_cwb_audit_id                  in     number
  );
--
-- -------------------------------------------------------------------------
-- |------------------------< create_audit_entry_a >-----------------------|
-- -------------------------------------------------------------------------
--
procedure create_audit_entry_a
  (p_group_per_in_ler_id           in     number
  ,p_group_pl_id                   in     number
  ,p_lf_evt_ocrd_dt                in     date
  ,p_pl_id                         in     number
  ,p_group_oipl_id                 in     number
  ,p_audit_type_cd                 in     varchar2
  ,p_old_val_varchar               in     varchar2
  ,p_new_val_varchar               in     varchar2
  ,p_old_val_number                in     number
  ,p_new_val_number                in     number
  ,p_old_val_date                  in     date
  ,p_new_val_date                  in     date
  ,p_date_stamp                    in     date
  ,p_change_made_by_person_id      in     number
  ,p_supporting_information        in     varchar2
  ,p_request_id                    in     number
  ,p_cwb_audit_id                  in     number
  ,p_object_version_number         in     number
  );
--
end BEN_CWB_AUDIT_BK1;

 

/
