--------------------------------------------------------
--  DDL for Package HRI_EDW_DIM_PERSON_TYPE
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."HRI_EDW_DIM_PERSON_TYPE" AUTHID CURRENT_USER AS
/* $Header: hriedpty.pkh 115.4 2003/08/07 07:32:23 jtitmas noship $ */

FUNCTION construct_person_type_pk( p_person_id   IN NUMBER,
                                   p_effective_date  IN DATE)
                   RETURN VARCHAR2;

PROCEDURE populate_person_types;

PROCEDURE insert_user_row( p_system_person_type      IN VARCHAR2,
                           p_user_person_type        IN VARCHAR2,
                           p_map_to_type             IN VARCHAR2 );

PROCEDURE remove_user_row( p_system_person_type      IN VARCHAR2,
                           p_user_person_type        IN VARCHAR2 );

PROCEDURE load_row(  p_system_person_type      IN VARCHAR2,
                     p_user_person_type        IN VARCHAR2,
                     p_map_to_type             IN VARCHAR2,
                     p_owner                   IN VARCHAR2 );

END hri_edw_dim_person_type;

 

/
