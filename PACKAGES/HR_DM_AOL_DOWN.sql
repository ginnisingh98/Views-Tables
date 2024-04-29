--------------------------------------------------------
--  DDL for Package HR_DM_AOL_DOWN
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."HR_DM_AOL_DOWN" AUTHID CURRENT_USER AS
/* $Header: perdmadl.pkh 120.0 2005/05/31 17:03:23 appldev noship $ */

--

--
PROCEDURE main(errbuf OUT NOCOPY VARCHAR2,
               retcode OUT NOCOPY NUMBER,
               p_migration_id IN NUMBER,
               p_concurrent_process IN VARCHAR2 DEFAULT 'Y',
               p_last_migration_date IN DATE,
               p_process_number IN NUMBER
               );


PROCEDURE spawn_down(p_migration_id IN NUMBER,
                     p_phase_id IN NUMBER,
                     p_phase_item_id IN NUMBER
                     );

--


END hr_dm_aol_down;

 

/
