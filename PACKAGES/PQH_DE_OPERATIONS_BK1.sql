--------------------------------------------------------
--  DDL for Package PQH_DE_OPERATIONS_BK1
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PQH_DE_OPERATIONS_BK1" AUTHID CURRENT_USER as
/* $Header: pqoplapi.pkh 120.0 2005/05/29 02:14:38 appldev noship $ */

  Procedure Insert_OPERATIONS_b
   (p_effective_date             in  date
   ,p_OPERATION_NUMBER           in  Varchar2
   ,P_DESCRIPTION                In  Varchar2);


--
-- ----------------------------------------------------------------------------
-- |-------------------------< Insert_OPERATIONS_a >-------------------------|
-- ----------------------------------------------------------------------------
--

procedure Insert_OPERATIONS_a
  (p_effective_date                in  date
  ,p_OPERATION_NUMBER              In  Varchar2
  ,P_DESCRIPTION                   In  Varchar2
  ,P_OPERATION_ID                  in  Number
  ,p_object_version_number         in  number) ;



 --
end PQH_DE_OPERATIONS_BK1;

 

/
