--------------------------------------------------------
--  DDL for Package HRI_OLTP_DISC_JOB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."HRI_OLTP_DISC_JOB" AUTHID CURRENT_USER AS
/* $Header: hriodjob.pkh 115.0 2003/02/28 15:12:58 jtitmas noship $ */

FUNCTION lookup_product_category( p_job_id     IN NUMBER )
     RETURN VARCHAR2;

END hri_oltp_disc_job;

 

/
