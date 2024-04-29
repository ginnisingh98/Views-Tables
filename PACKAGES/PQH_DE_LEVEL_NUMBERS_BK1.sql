--------------------------------------------------------
--  DDL for Package PQH_DE_LEVEL_NUMBERS_BK1
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PQH_DE_LEVEL_NUMBERS_BK1" AUTHID CURRENT_USER as
/* $Header: pqgvnapi.pkh 120.0 2005/05/29 02:01:14 appldev noship $ */

  Procedure Insert_LEVEL_NUMBERS_b
   (p_effective_date             in  date
   ,p_LEVEL_NUMBER               in  Varchar2
   ,P_DESCRIPTION                In  Varchar2
    );


--
-- ----------------------------------------------------------------------------
-- |-------------------------< Insert_LEVEL_NUMBERS_a >-------------------------|
-- ----------------------------------------------------------------------------
--

procedure Insert_LEVEL_NUMBERS_a
  (p_effective_date                in  date
  ,p_LEVEL_NUMBER                  In  Varchar2
  ,P_DESCRIPTION                   In  Varchar2
  ,P_LEVEL_NUMBER_ID               in  Number
  ,p_object_version_number         in  number) ;



 --
end PQH_DE_LEVEL_NUMBERS_BK1;

 

/
