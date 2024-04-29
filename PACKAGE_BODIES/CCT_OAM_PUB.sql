--------------------------------------------------------
--  DDL for Package Body CCT_OAM_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."CCT_OAM_PUB" as
/* $Header: cctclscb.pls 120.1 2008/01/02 11:29:02 majha ship $*/

  /*Commented for bug6435501 PROCEDURE PURGE_CCT_TRANS_DATA IS  ---- */
    PROCEDURE PURGE_CCT_TRANS_DATA(p_errbuf        OUT NOCOPY VARCHAR2,
                               p_retcode       OUT NOCOPY NUMBER) IS
    BEGIN
        delete from cct_media_items;
	 commit; /* bug6435501*/
    END PURGE_CCT_TRANS_DATA;

END CCT_OAM_PUB;

/
