--------------------------------------------------------
--  DDL for Package HRI_OPL_SETUP_DIAGNOSTIC
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."HRI_OPL_SETUP_DIAGNOSTIC" AUTHID CURRENT_USER AS
/* $Header: hripdgsp.pkh 120.3.12000000.2 2007/04/12 13:25:45 smohapat noship $ */

PROCEDURE display_setup(errbuf             OUT NOCOPY VARCHAR2,
                        retcode            OUT NOCOPY VARCHAR2,
                        p_functional_area  IN VARCHAR2);

END hri_opl_setup_diagnostic;

 

/
