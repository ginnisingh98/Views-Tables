--------------------------------------------------------
--  DDL for Package PQH_OPL_RKI
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PQH_OPL_RKI" AUTHID CURRENT_USER as
/* $Header: pqoplrhi.pkh 120.0 2005/05/29 02:14:57 appldev noship $ */
--
-- ----------------------------------------------------------------------------
-- |-----------------------------< after_insert >-----------------------------|
-- ----------------------------------------------------------------------------
--
procedure after_insert
  (p_effective_date               in date
  ,p_operation_id                 in number
  ,p_operation_number             in varchar2
  ,p_description                  in varchar2
  ,p_object_version_number        in number
  );
end pqh_opl_rki;

 

/
