--------------------------------------------------------
--  DDL for Package HR_DM_UPLOAD
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."HR_DM_UPLOAD" AUTHID CURRENT_USER AS
/* $Header: perdmup.pkh 120.0 2005/05/30 21:18:00 appldev noship $ */

--
g_data_migrator_source_db varchar2(30);
--
PROCEDURE main(errbuf OUT NOCOPY VARCHAR2,
               retcode OUT NOCOPY NUMBER,
               p_migration_id IN NUMBER,
               p_concurrent_process IN VARCHAR2 DEFAULT 'Y',
               p_last_migration_date IN DATE,
               p_process_number       IN   NUMBER
               );

FUNCTION set_globals RETURN NUMBER;

END hr_dm_upload;


 

/
