--------------------------------------------------------
--  DDL for Package FND_DATADICT_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."FND_DATADICT_PKG" AUTHID CURRENT_USER AS
/* $Header: AFUDICTS.pls 115.0 99/07/16 23:32:20 porting ship $ */

  PROCEDURE rename_table(p_appl_id       IN number,
                         p_old_tablename IN varchar2,
                         p_new_tablename IN varchar2);

END;

 

/
