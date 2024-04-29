--------------------------------------------------------
--  DDL for Package FND_CTL
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."FND_CTL" AUTHID CURRENT_USER as
/* $Header: AFSESCTS.pls 115.3 99/07/16 23:30:50 porting ship  $ */


PROCEDURE FND_SESS_CTL(oltp_opt_mode IN VARCHAR2,
                                        conc_opt_mode IN VARCHAR2,
                                        trace_opt     IN VARCHAR2,
                                        timestat    IN VARCHAR2,
                                        logmode    IN VARCHAR2,
                                        event_stmt   IN VARCHAR2) ;

end FND_CTL;

 

/
