--------------------------------------------------------
--  DDL for Package HRI_BPL_FLEX
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."HRI_BPL_FLEX" AUTHID CURRENT_USER AS
/* $Header: hribflx.pkh 115.1 2004/01/21 08:13:37 jtitmas noship $ */

PROCEDURE get_value_set_lov_sql
    (p_flex_value_set_id   IN  fnd_flex_value_sets.flex_value_set_id%TYPE
    ,p_sql_stmt            OUT NOCOPY VARCHAR2
    ,p_distinct_flag       IN VARCHAR2);

END hri_bpl_flex;

 

/
