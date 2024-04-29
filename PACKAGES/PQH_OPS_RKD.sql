--------------------------------------------------------
--  DDL for Package PQH_OPS_RKD
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PQH_OPS_RKD" AUTHID CURRENT_USER as
/* $Header: pqopsrhi.pkh 120.0 2005/05/29 02:16:01 appldev noship $ */
--
-- ----------------------------------------------------------------------------
-- |----------------------------< after_delete >------------------------------|
-- ----------------------------------------------------------------------------
--
procedure after_delete
  (p_wrkplc_vldtn_op_id           in number
  ,p_wrkplc_vldtn_ver_id_o        in number
  ,p_wrkplc_operation_id_o        in number
  ,p_business_group_id_o          in number
  ,p_description_o                in varchar2
  ,p_unit_percentage_o            in number
  ,p_object_version_number_o      in number
  );
--
end pqh_ops_rkd;

 

/
