--------------------------------------------------------
--  DDL for Package PV_CATEGORY_MIGRATION
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PV_CATEGORY_MIGRATION" AUTHID CURRENT_USER AS
/* $Header: pvsphmis.pls 115.0 2004/03/11 23:27:07 pklin ship $ */

PROCEDURE Category_Migration (
    ERRBUF             OUT NOCOPY VARCHAR2,
    RETCODE            OUT NOCOPY VARCHAR2,
    p_trace_mode       IN  VARCHAR2,
    p_log_to_file      IN  VARCHAR2 := 'Y');

end PV_CATEGORY_MIGRATION;

 

/
