--------------------------------------------------------
--  DDL for Package Body HRI_OLTP_DISC_JOB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."HRI_OLTP_DISC_JOB" AS
/* $Header: hriodjob.pkb 115.0 2003/02/28 15:13:11 jtitmas noship $ */

/******************************************************************************/
/* Finds the product category for a given job                                 */
/******************************************************************************/
FUNCTION lookup_product_category( p_job_id     IN NUMBER )
     RETURN VARCHAR2 IS

  l_product_category     VARCHAR2(80);

BEGIN

  l_product_category := hri_bpl_job.lookup_product_category(p_job_id);

  RETURN l_product_category;

EXCEPTION WHEN OTHERS THEN

  RETURN null;

END lookup_product_category;

END hri_oltp_disc_job;

/
