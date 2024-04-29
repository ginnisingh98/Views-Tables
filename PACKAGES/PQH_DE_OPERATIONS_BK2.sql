--------------------------------------------------------
--  DDL for Package PQH_DE_OPERATIONS_BK2
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PQH_DE_OPERATIONS_BK2" AUTHID CURRENT_USER as
/* $Header: pqoplapi.pkh 120.0 2005/05/29 02:14:38 appldev noship $ */
--
-- ----------------------------------------------------------------------------
-- |-------------------------< <Update_OPERATIONS_b >-------------------------|
-- ----------------------------------------------------------------------------
--

procedure Update_OPERATIONS_b
           (p_effective_date             in  date
           ,p_OPERATION_NUMBER           In  Varchar2
           ,P_DESCRIPTION                In  Varchar2
           ,P_OPERATION_ID               In  Number
           ,p_object_version_number      In  Number);

procedure Update_OPERATIONS_a
    (p_effective_date             in  date
    ,p_OPERATION_NUMBER           In  Varchar2
    ,P_DESCRIPTION                In  Varchar2
    ,P_OPERATION_ID               In  Number
    ,p_object_version_number      In  Number);

end PQH_DE_OPERATIONS_BK2;

 

/
