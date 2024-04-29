--------------------------------------------------------
--  DDL for Package HZ_AUTOMERGE_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."HZ_AUTOMERGE_PKG" AUTHID CURRENT_USER AS
 /*$Header: ARHAMRGS.pls 115.0 2003/09/18 00:03:51 abordia noship $ */

PROCEDURE automerge( retcode   OUT NOCOPY   VARCHAR2,
    err        OUT NOCOPY    VARCHAR2,
    p_dup_batch_id IN VARCHAR2,
    p_no_of_workers IN VARCHAR2);


END HZ_AUTOMERGE_PKG;

 

/
