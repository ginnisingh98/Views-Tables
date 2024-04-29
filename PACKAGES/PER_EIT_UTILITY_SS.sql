--------------------------------------------------------
--  DDL for Package PER_EIT_UTILITY_SS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PER_EIT_UTILITY_SS" AUTHID CURRENT_USER as
/* $Header: hreitutl.pkh 115.1 2002/02/24 02:49:11 pkm ship        $ */

 -- ----------------------------------------------------------------------------
-- |-----------------------< EIT_NOT_EXIST >--------------------------|
-- ----------------------------------------------------------------------------


FUNCTION EIT_NOT_EXIST   (P_APPLICATION_SHORT_NAME     IN VARCHAR2,
                           P_RESPONSIBILITY_NAME       IN VARCHAR2,
                           P_INFO_TYPE_TABLE_NAME      IN VARCHAR2,
                           P_INFORMATION_TYPE          IN VARCHAR2,
                           P_ROWID                     IN VARCHAR2) RETURN BOOLEAN;



 -- ----------------------------------------------------------------------------
-- |-----------------------< create_eit_resp_security >--------------------------|
-- ----------------------------------------------------------------------------

PROCEDURE create_eit_resp_security (P_RESPONSIBILITY_NAME       IN VARCHAR2);

END;

 

/
