--------------------------------------------------------
--  DDL for Package EDW_TRUNCATE_MD
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."EDW_TRUNCATE_MD" AUTHID CURRENT_USER AS
/* $Header: EDWUPMDS.pls 115.3 2003/11/19 09:19:38 smulye noship $  */
   version   CONSTANT VARCHAR (80)
            := '$Header: EDWUPMDS.pls 115.3 2003/11/19 09:19:38 smulye noship $';


   g_getsyn           EXCEPTION;

   FUNCTION get_syn_info (syn_name IN VARCHAR2)
      RETURN VARCHAR2;

   procedure clean_up(tbl_name IN VARCHAR2);

END edw_truncate_md;

 

/
