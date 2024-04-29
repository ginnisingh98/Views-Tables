--------------------------------------------------------
--  DDL for Package FND_DATADICT_SEQ_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."FND_DATADICT_SEQ_PKG" AUTHID CURRENT_USER AS
/* $Header: AFSDICTS.pls 115.1 99/07/16 23:30:35 porting ship  $ */

  PROCEDURE rename_seq(p_appl_id     IN number,
                       p_old_seqname IN varchar2,
                       p_new_seqname IN varchar2);

END;

 

/
