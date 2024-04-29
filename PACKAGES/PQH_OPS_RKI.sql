--------------------------------------------------------
--  DDL for Package PQH_OPS_RKI
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PQH_OPS_RKI" AUTHID CURRENT_USER as
/* $Header: pqopsrhi.pkh 120.0 2005/05/29 02:16:01 appldev noship $ */
--
-- ----------------------------------------------------------------------------
-- |-----------------------------< after_insert >-----------------------------|
-- ----------------------------------------------------------------------------
--
procedure after_insert
  (p_effective_date               in date
  ,p_wrkplc_vldtn_op_id           in number
  ,p_wrkplc_vldtn_ver_id          in number
  ,p_wrkplc_operation_id          in number
  ,p_business_group_id            in number
  ,p_description                  in varchar2
  ,p_unit_percentage              in number
  ,p_object_version_number        in number
  );
end pqh_ops_rki;

 

/
