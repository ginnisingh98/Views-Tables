--------------------------------------------------------
--  DDL for Package HRI_OPL_DATA_SETUP_DGNSTC
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."HRI_OPL_DATA_SETUP_DGNSTC" AUTHID CURRENT_USER AS
/* $Header: hripdgdp.pkh 120.2.12000000.2 2007/04/12 13:24:53 smohapat noship $ */

PROCEDURE display_data_setup(errbuf             OUT NOCOPY VARCHAR2,
                             retcode            OUT NOCOPY VARCHAR2,
                             p_functional_area  IN VARCHAR2,
                             p_start_date       IN VARCHAR2,
                             p_end_date         IN VARCHAR2,
                             p_mode             IN VARCHAR2,
                             p_section          IN VARCHAR2,
                             p_subsection       IN VARCHAR2,
			     p_show_alerts      IN VARCHAR2,
			     p_show_data        IN VARCHAR2);

END hri_opl_data_setup_dgnstc;

 

/
