--------------------------------------------------------
--  DDL for Package IEC_DEFAULT_SUBSET_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IEC_DEFAULT_SUBSET_PVT" AUTHID CURRENT_USER AS
/* $Header: IECADSBS.pls 115.7 2003/08/22 20:41:15 hhuang noship $ */

-----------------------------++++++-------------------------------
--
-- Start of comments
--
--  API name    : CREATE_DEFAULT_SUBSETS
--  Type        : Public
--  Pre-reqs    : None
--  Function    : if a default subset has not previously been
--                created on the list the create one.

--  Parameters  :
--
--  Version     : Initial version 1.0
--
-- End of comments
--
-----------------------------++++++-------------------------------
/* Called by the Status Plugin. */
PROCEDURE CREATE_DEFAULT_SUBSETS( P_LIST_ID IN NUMBER
                                , X_RETURN_STATUS OUT NOCOPY VARCHAR2);
-- PL/SQL Block
END IEC_DEFAULT_SUBSET_PVT;

 

/
