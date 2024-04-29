--------------------------------------------------------
--  DDL for Package HR_DM_DELETE
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."HR_DM_DELETE" AUTHID CURRENT_USER AS
/* $Header: perdmdel.pkh 120.1 2005/06/15 02:08:50 nhunur noship $ */

--

--
PROCEDURE main(errbuf OUT NOCOPY VARCHAR2,
               retcode OUT NOCOPY NUMBER,
               p_migration_id IN NUMBER,
               p_concurrent_process IN VARCHAR2 DEFAULT 'Y',
               p_last_migration_date IN DATE,
               p_process_number IN NUMBER
               );
PROCEDURE set_active(p_migration_id IN NUMBER);
PROCEDURE pre_delete_process(r_migration_data IN
                                           hr_dm_utility.r_migration_rec);

PROCEDURE del_fnd_info(p_business_group_id IN NUMBER);

--


END hr_dm_delete;

 

/
