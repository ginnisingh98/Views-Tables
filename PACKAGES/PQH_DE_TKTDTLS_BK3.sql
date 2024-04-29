--------------------------------------------------------
--  DDL for Package PQH_DE_TKTDTLS_BK3
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PQH_DE_TKTDTLS_BK3" AUTHID CURRENT_USER as
/* $Header: pqtktapi.pkh 120.0 2005/05/29 02:49:33 appldev noship $ */
--
-- ----------------------------------------------------------------------------
-- |-------------------------< Delete_TKT_DTLS_b >-------------------------|
-- ----------------------------------------------------------------------------
--
Procedure Delete_TKT_DTLS_b
  (p_TATIGKEIT_DETAIL_ID           In     Number
  ,p_object_version_number         In     number);

Procedure Delete_TKT_DTLS_a
  (p_TATIGKEIT_DETAIL_ID           In     Number
  ,p_object_version_number         In     number);

end PQH_DE_TKTDTLS_BK3;

 

/
