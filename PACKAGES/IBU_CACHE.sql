--------------------------------------------------------
--  DDL for Package IBU_CACHE
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IBU_CACHE" AUTHID CURRENT_USER as
/* $Header: ibuxpkgs.pls 115.6 2004/03/29 22:15:08 lahuang ship $ */

/* ------------------------------------------------------------------------
   The cleanup procedure that is called regularly by the database job to
   cleanup expired entries.
   ------------------------------------------------------------------------ */
procedure timeout_entries(errbuf out NOCOPY varchar2,
                          errcode out NOCOPY number,
                          timeout in number default 30);

/* ------------------------------------------------------------------------
   Install the database job that will expire some cache entries.
   ------------------------------------------------------------------------ */
procedure install_timeout_job(msg out NOCOPY varchar2);


/* ------------------------------------------------------------------------
   Uninstall the database job.
   ------------------------------------------------------------------------ */
procedure uninstall_timeout_job(msg out NOCOPY varchar2);

end IBU_CACHE;

 

/
