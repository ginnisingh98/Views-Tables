--------------------------------------------------------
--  DDL for Package CCT_OAM_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."CCT_OAM_PUB" AUTHID CURRENT_USER AS
/* $Header: cctclscs.pls 120.1 2008/01/02 11:28:11 majha ship $*/


-- Start of comments
--      API name        : PURGE_CCT_TRANS_DATA
--      Type            : Public
--      Function        : Purge the transaction data from the cct_media_items table
--      Pre-reqs        : None.
--      Parameters      :
--      Version : Current version       1.0
--                Initial version       1.0
--
--      Notes           : edwang  03-03-2004 Created
--
-- End of comments

   /* Commented from bug6435501 PROCEDURE PURGE_CCT_TRANS_DATA;  --- */

    PROCEDURE PURGE_CCT_TRANS_DATA(p_errbuf        OUT NOCOPY VARCHAR2,
                                   p_retcode       OUT NOCOPY NUMBER);

END CCT_OAM_PUB;

/
