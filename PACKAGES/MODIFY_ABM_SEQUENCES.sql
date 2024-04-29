--------------------------------------------------------
--  DDL for Package MODIFY_ABM_SEQUENCES
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."MODIFY_ABM_SEQUENCES" AUTHID CURRENT_USER AS
/*$Header: abmseqs.pls 115.3 2002/03/06 18:36:01 pkm ship      $*/

    PROCEDURE get_tabcol_and_seq ( sequence_name VARCHAR2);

    FUNCTION modify_table_column_by_value ( table_name VARCHAR2, table_column_name VARCHAR2, increment_value NUMBER) RETURN NUMBER;

    PROCEDURE create_sequence_with_new_value ( sequence_name VARCHAR2, starting_value NUMBER);

END modify_abm_sequences;

 

/
