--------------------------------------------------------
--  DDL for Package HRI_UTL_DDL
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."HRI_UTL_DDL" AUTHID CURRENT_USER AS
/* $Header: hriutddl.pkh 120.1 2006/01/20 02:05:06 jtitmas noship $ */
--
-- -----------------------------------------------------------------------------
-- PROCEDURE recreate_indexes
-- -----------------------------------------------------------------------------
--
-- This procedure recreates the indexes for the specified table using the
-- definitions stored in the temporary table
--
-- Parameter                 Type  Description
-- ------------------------  ----  ---------------------------------------------
-- p_application_short_name  IN    Short name of the application product
--                                 calling this routine
-- p_table_name              IN    Table for which the indexes are to be dropped
-- p_table_owner             IN    Name of the Schema owning the table
-- -----------------------------------------------------------------------------
--
PROCEDURE recreate_indexes(p_application_short_name IN VARCHAR2,
                           p_table_name             IN VARCHAR2,
                           p_table_owner            IN VARCHAR2);
--
-- -----------------------------------------------------------------------------
-- PROCEDURE log_and_drop_indexes
-- -----------------------------------------------------------------------------
--
-- This procedure drops all the indexes for a table and inserts definition
-- of the indexes in a temporary table. Using this definition the procedure
-- recreate_indexes can recreate the indexes. If some of the indexes are not
-- to be dropped, a comma separated list can be passed in parameter
-- p_index_excptn_lst.
--
-- NOTE: The procedure will not drop the primary key index.
--
-- Parameter                 Type  Description
-- ------------------------  ----  ---------------------------------------------
-- p_application_short_name  IN    Short name of the application product
--                                 calling this routine
-- p_table_name              IN    Table for which the indexes are to be dropped
-- p_table_owner             IN    Name of the Schema owning the table
-- p_index_excptn_lst        IN    Pass a comma separated list of indexes which
--                                 are not to be dropped
-- -----------------------------------------------------------------------------
--
PROCEDURE log_and_drop_indexes(p_application_short_name IN VARCHAR2,
                               p_table_name          IN VARCHAR2,
                               p_table_owner         IN VARCHAR2,
                               p_index_excptn_lst    IN VARCHAR2 DEFAULT NULL);
--
PROCEDURE maintain_mthd_partitions(p_table_name          IN VARCHAR2,
                                   p_table_owner         IN VARCHAR2);
--
END HRI_UTL_DDL;

 

/
