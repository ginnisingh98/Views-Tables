--------------------------------------------------------
--  DDL for Package HRI_OPL_SUPH_HST_INC
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."HRI_OPL_SUPH_HST_INC" AUTHID CURRENT_USER AS
/* $Header: hrioshhi.pkh 115.3 2003/01/17 19:42:31 rthiagar noship $ */

PROCEDURE Load_managers(p_start_date  IN DATE,
                        p_end_date    IN DATE);

PROCEDURE Load_managers(errbuf        OUT NOCOPY VARCHAR2,
                        retcode       OUT NOCOPY VARCHAR2,
                        p_start_date  IN DATE,
                        p_end_date    IN DATE);

END hri_opl_suph_hst_inc;

 

/
