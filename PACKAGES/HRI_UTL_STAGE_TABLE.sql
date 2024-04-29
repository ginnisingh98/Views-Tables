--------------------------------------------------------
--  DDL for Package HRI_UTL_STAGE_TABLE
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."HRI_UTL_STAGE_TABLE" AUTHID CURRENT_USER AS
/* $Header: hriutstg.pkh 120.0 2006/01/20 02:06 jtitmas noship $ */

FUNCTION get_staging_table_name(p_master_table_name  IN VARCHAR2)
   RETURN VARCHAR2;

PROCEDURE set_up(p_owner      IN VARCHAR2,
                 p_master_table_name IN VARCHAR2);

PROCEDURE clean_up(p_owner      IN VARCHAR2,
                   p_master_table_name IN VARCHAR2);

END HRI_UTL_STAGE_TABLE;

 

/
