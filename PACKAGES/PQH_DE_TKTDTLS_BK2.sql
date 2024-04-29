--------------------------------------------------------
--  DDL for Package PQH_DE_TKTDTLS_BK2
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PQH_DE_TKTDTLS_BK2" AUTHID CURRENT_USER as
/* $Header: pqtktapi.pkh 120.0 2005/05/29 02:49:33 appldev noship $ */
--
-- ----------------------------------------------------------------------------
-- |-------------------------< <Update_TKT_DTLS_b >-------------------------|
-- ----------------------------------------------------------------------------
--

procedure Update_TKT_DTLS_b
           (p_effective_date             in  date
           ,p_TATIGKEIT_NUMBER           In  Varchar2
           ,P_DESCRIPTION                In  Varchar2
           ,P_TATIGKEIT_DETAIL_ID        In  Number
           ,p_object_version_number      In  Number);

procedure Update_TKT_DTLS_a
    (p_effective_date             in  date
    ,p_TATIGKEIT_NUMBER           In  Varchar2
    ,P_DESCRIPTION                In  Varchar2
    ,P_TATIGKEIT_DETAIL_ID        In  Number
    ,p_object_version_number      In  Number);

end PQH_DE_TKTDTLS_BK2;

 

/
