--------------------------------------------------------
--  DDL for Package HRI_OLTP_PMV_LABEL
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."HRI_OLTP_PMV_LABEL" AUTHID CURRENT_USER AS
/* $Header: hriopdlv.pkh 120.0 2005/05/29 07:32:08 appldev noship $ */

FUNCTION get_label(p_dim_lvl_name  VARCHAR2,
                   p_dim_lvl_pk    VARCHAR2,
                   p_name_type     VARCHAR2)
       RETURN VARCHAR2;

END hri_oltp_pmv_label;

 

/
