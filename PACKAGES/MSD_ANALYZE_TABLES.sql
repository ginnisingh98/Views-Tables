--------------------------------------------------------
--  DDL for Package MSD_ANALYZE_TABLES
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."MSD_ANALYZE_TABLES" AUTHID CURRENT_USER AS
/* $Header: msdaztbs.pls 115.0 2002/05/06 14:50:28 pkm ship        $ */


    Type table_type is RECORD (
        table_name            varchar2(30),
        table_type            number );

    Type table_type_list is TABLE of table_type index by binary_integer;

    PROCEDURE analyze_table( p_table_name       IN VARCHAR2,
                             p_type             IN NUMBER );

END MSD_ANALYZE_TABLES;

 

/
