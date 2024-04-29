--------------------------------------------------------
--  DDL for Package HRI_BPL_PARAMETER
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."HRI_BPL_PARAMETER" AUTHID CURRENT_USER AS
/* $Header: hribprm.pkh 120.0 2005/11/11 03:05:47 jtitmas noship $ */

FUNCTION get_bis_global_start_date
   RETURN DATE;

END hri_bpl_parameter;

 

/
