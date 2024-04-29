--------------------------------------------------------
--  DDL for Package PQH_DE_OPERATION_GROUPS_BK2
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PQH_DE_OPERATION_GROUPS_BK2" AUTHID CURRENT_USER as
/* $Header: pqopgapi.pkh 120.0 2005/05/29 02:13:47 appldev noship $ */

--
-- ----------------------------------------------------------------------------
-- |-------------------------< Update_OPERATION_GROUPS_> >------------------------|
-- ----------------------------------------------------------------------------
--

procedure Update_OPERATION_GROUPS_b
(  p_effective_date                     in  date
  ,p_operation_Group_CODE               in  Varchar2
  ,P_DESCRIPTION                        In  Varchar2
  ,p_operation_GROUP_ID                 in  Number
  ,p_object_version_number              in  number
  ,p_business_group_id                  in  number
 ) ;


procedure Update_OPERATION_GROUPS_a
 ( p_effective_date                     in  date
  ,p_operation_Group_CODE               In  Varchar2
  ,P_DESCRIPTION                        In  Varchar2
  ,p_operation_GROUP_ID                 in  Number
  ,p_object_version_number              in  number
  ,p_business_group_id                  in  number
  ) ;

end PQH_DE_OPERATION_GROUPS_BK2;

 

/
