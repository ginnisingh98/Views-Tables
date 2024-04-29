--------------------------------------------------------
--  DDL for Package Body HRI_BPL_PARAMETER
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."HRI_BPL_PARAMETER" AS
/* $Header: hribprm.pkb 120.0 2005/11/11 03:06:12 jtitmas noship $ */

FUNCTION get_bis_global_start_date
       RETURN DATE IS

BEGIN

  RETURN bis_common_parameters.get_global_start_date;

END get_bis_global_start_date;


END hri_bpl_parameter;

/
