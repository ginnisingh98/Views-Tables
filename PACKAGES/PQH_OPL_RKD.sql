--------------------------------------------------------
--  DDL for Package PQH_OPL_RKD
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PQH_OPL_RKD" AUTHID CURRENT_USER as
/* $Header: pqoplrhi.pkh 120.0 2005/05/29 02:14:57 appldev noship $ */
--
-- ----------------------------------------------------------------------------
-- |----------------------------< after_delete >------------------------------|
-- ----------------------------------------------------------------------------
--
procedure after_delete
  (p_operation_id                 in number
  ,p_operation_number_o           in varchar2
  ,p_description_o                in varchar2
  ,p_object_version_number_o      in number
  );
--
end pqh_opl_rkd;

 

/
