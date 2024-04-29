--------------------------------------------------------
--  DDL for Package HRI_MTDT_PARAM
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."HRI_MTDT_PARAM" AUTHID CURRENT_USER AS
/* $Header: hrimpar.pkh 120.0 2005/05/29 06:55:23 appldev noship $ */

TYPE param_metadata_rectype IS RECORD
  (pmv_bind_string         VARCHAR2(80));

TYPE param_metadata_tabtype IS TABLE OF param_metadata_rectype INDEX BY VARCHAR2(80);

g_param_mtdt_tab   param_metadata_tabtype;

END hri_mtdt_param;

 

/
