--------------------------------------------------------
--  DDL for Package CS_KB_CTX_INDEX_CONC_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."CS_KB_CTX_INDEX_CONC_PKG" AUTHID CURRENT_USER AS
/* $Header: csksynis.pls 115.0 2000/02/29 19:45:25 pkm ship    $ */

/* errbuf = err messages
   retcode = 0 success, 1 = warning, 2=error
*/

PROCEDURE Sync_All_Index (ERRBUF OUT VARCHAR2, RETCODE OUT NUMBER);

PROCEDURE Sync_Element_Index  (ERRBUF OUT VARCHAR2, RETCODE OUT NUMBER);

PROCEDURE Sync_Set_Index  (ERRBUF OUT VARCHAR2, RETCODE OUT NUMBER);

PROCEDURE Sync_Forum_Index  (ERRBUF OUT VARCHAR2, RETCODE OUT NUMBER);

procedure cs_kb_del_conc_prog;

end CS_KB_CTX_INDEX_CONC_PKG;

 

/
