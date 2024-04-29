--------------------------------------------------------
--  DDL for Package PQH_DE_OPERATION_GROUPS_BK1
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PQH_DE_OPERATION_GROUPS_BK1" AUTHID CURRENT_USER as
/* $Header: pqopgapi.pkh 120.0 2005/05/29 02:13:47 appldev noship $ */

  Procedure Insert_OPERATION_GROUPS_b
 (p_effective_date                      in  date
  ,p_operation_Group_CODE               In  Varchar2
  ,P_DESCRIPTION                        In  Varchar2
  ,p_operation_GROUP_ID                 IN  Number
  ,p_object_version_number              IN  number
  ,p_business_group_id                  in  number
 ) ;

--
-- ----------------------------------------------------------------------------
-- |-------------------------< <Insert_OPERATION_GROUPS_a> >-------------------------|
-- ----------------------------------------------------------------------------
--
procedure Insert_OPERATION_GROUPS_a
 (p_effective_date                      in  date
  ,p_operation_Group_CODE               In  Varchar2
  ,P_DESCRIPTION                        In  Varchar2
  ,p_operation_GROUP_ID                 IN  Number
  ,p_object_version_number              IN  number
  ,p_business_group_id                  in  number
 ) ;

 --
end PQH_DE_OPERATION_GROUPS_BK1;

 

/
