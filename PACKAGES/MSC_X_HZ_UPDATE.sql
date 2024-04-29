--------------------------------------------------------
--  DDL for Package MSC_X_HZ_UPDATE
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."MSC_X_HZ_UPDATE" AUTHID CURRENT_USER AS
/*  $Header: MSCXHZUS.pls 120.1 2005/06/07 23:35:15 appldev  $ */

   Procedure update_supdem_entries( arg_err_msg      OUT NOCOPY VARCHAR2,
                                    arg_query_id     IN  NUMBER
                                  );


END MSC_X_HZ_UPDATE;

 

/
