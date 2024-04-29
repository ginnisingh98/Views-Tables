--------------------------------------------------------
--  DDL for Package HR_DM_AOL_EXT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."HR_DM_AOL_EXT" AUTHID CURRENT_USER AS
/* $Header: perdmaxt.pkh 120.0 2005/05/31 17:04:35 appldev noship $ */

--

FUNCTION custom_test(r_migration_data IN hr_dm_utility.r_migration_rec,
                     r_flexfield_data IN hr_dm_init.r_flexfield_rec)
    RETURN BOOLEAN;

--

END hr_dm_aol_ext;

 

/
