--------------------------------------------------------
--  DDL for Package PQH_DE_TKTDTLS_BK1
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PQH_DE_TKTDTLS_BK1" AUTHID CURRENT_USER as
/* $Header: pqtktapi.pkh 120.0 2005/05/29 02:49:33 appldev noship $ */

  Procedure Insert_TKT_DTLS_b
   (p_effective_date             in  date
   ,p_TATIGKEIT_NUMBER           in  Varchar2
   ,P_DESCRIPTION                In  Varchar2);


--
-- ----------------------------------------------------------------------------
-- |-------------------------< Insert_TKT_DTLS_a >-------------------------|
-- ----------------------------------------------------------------------------
--

procedure Insert_TKT_DTLS_a
  (p_effective_date                in  date
  ,p_TATIGKEIT_NUMBER              In  Varchar2
  ,P_DESCRIPTION                   In  Varchar2
  ,P_TATIGKEIT_DETAIL_ID           in  Number
  ,p_object_version_number         in  number) ;



 --
end PQH_DE_TKTDTLS_BK1;

 

/
