--------------------------------------------------------
--  DDL for Package HRI_BPL_DIM_LVL
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."HRI_BPL_DIM_LVL" AUTHID CURRENT_USER AS
/* $Header: hribdlv.pkh 120.0 2005/05/29 06:52:45 appldev noship $ */

FUNCTION get_value_label(p_dim_lvl_name  VARCHAR2,
                         p_dim_lvl_pk    VARCHAR2,
                         p_name_type     VARCHAR2)
       RETURN VARCHAR2;

END hri_bpl_dim_lvl;

 

/
