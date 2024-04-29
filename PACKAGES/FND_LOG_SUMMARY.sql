--------------------------------------------------------
--  DDL for Package FND_LOG_SUMMARY
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."FND_LOG_SUMMARY" AUTHID CURRENT_USER as
/* $Header: AFUTLGSS.pls 115.0 2004/03/09 02:24:40 kkapur noship $ */


/* This routine is used as a concurrent program.  */
/* Nobody besides the concurrent manager should call it. */
procedure summarize_rows;

end fnd_log_summary;

 

/
