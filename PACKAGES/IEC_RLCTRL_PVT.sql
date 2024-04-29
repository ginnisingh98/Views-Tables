--------------------------------------------------------
--  DDL for Package IEC_RLCTRL_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IEC_RLCTRL_PVT" AUTHID CURRENT_USER AS
/* $Header: IECRCPVS.pls 115.0.1157.1 2002/03/14 08:56:27 pkm ship        $ */


-- Start of comments
--  Procedure   : MAKE_LIST_ENTRIES_AVAILABLE
--  Type        : Private API
--  Usage       : Makes list entries with specified do not use reason available by setting
--                the DO_NOT_USE_FLAG to 'N' in both IEC_G_RETURN_ENTRIES and
--                AMS_LIST_ENTRIES.
--  Pre-reqs    : None
--
--  Parameters  :
--
--      P_LIST_HEADER_ID                IN      NUMBER          Required
--      P_DNU_REASON_CODE               IN      NUMBER          Required
--      X_RETURN_STATUS                 OUT     VARCHAR2(1)
--
--
-- End of comments


PROCEDURE MAKE_LIST_ENTRIES_AVAILABLE ( P_LIST_HEADER_ID	IN	NUMBER
                                      , P_DNU_REASON_CODE	IN	NUMBER
                                      , P_COMMIT                IN      BOOLEAN
                                      , X_RETURN_STATUS		OUT	VARCHAR2);

END IEC_RLCTRL_PVT;

 

/
