--------------------------------------------------------
--  DDL for Package CN_OU_UTIL_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."CN_OU_UTIL_PVT" AUTHID CURRENT_USER AS
-- $Header: cnvouuts.pls 120.0 2005/09/09 17:52:46 sbadami noship $

-- Start of comments
--    API name        : is_valid_org
--    Type            : Public.
--    Function        :
--    Pre-reqs        : None.
--    Parameters      :
--    IN              : p_org_id IN NUMBER Required
--    OUT             : Boolean  OUT  VARCHAR2(1)
--    Version         : Current version 1.0
--    Notes           : This procedure checks whether org_id is valid
--
-- End of comments

FUNCTION is_valid_org (
      p_org_id  NUMBER,
      p_raise_error VARCHAR2 := 'Y'
)
RETURN BOOLEAN;


END CN_OU_UTIL_PVT;

 

/
