--------------------------------------------------------
--  DDL for Package CSTPSMCM
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."CSTPSMCM" AUTHID CURRENT_USER AS
/* $Header: CSTSMCMS.pls 115.4 2002/11/11 22:58:11 awwang ship $ */
PROCEDURE WSM_COST_MANAGER(RETCODE out NOCOPY number,
                           ERRBUF out NOCOPY varchar2);

END CSTPSMCM;

 

/
