--------------------------------------------------------
--  DDL for Package ECX_MIGRATE
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."ECX_MIGRATE" AUTHID CURRENT_USER AS
-- $Header: ECXPMIRS.pls 120.2 2005/06/30 11:17:38 appldev ship $

PROCEDURE ecx_migrate_password(errmsg OUT NOCOPY varchar2, retcode OUT NOCOPY pls_integer);

PROCEDURE pmigrate(p_debug_mode pls_integer default 0);

END;

 

/
