--------------------------------------------------------
--  DDL for Package HR_DM_CLEANUP
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."HR_DM_CLEANUP" AUTHID CURRENT_USER AS
/* $Header: perdmclu.pkh 120.0 2005/05/31 17:05:56 appldev noship $ */

--
PROCEDURE main(errbuf OUT NOCOPY VARCHAR2,
               retcode OUT NOCOPY NUMBER,
               p_migration_id IN NUMBER,
               p_concurrent_process IN VARCHAR2 DEFAULT 'Y',
               p_last_migration_date IN DATE,
               p_process_number IN NUMBER
               );

PROCEDURE post_cleanup_process(r_migration_data IN
                                        hr_dm_utility.r_migration_rec);
--

--


END hr_dm_cleanup;

 

/
