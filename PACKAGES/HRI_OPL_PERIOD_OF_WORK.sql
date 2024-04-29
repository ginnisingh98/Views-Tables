--------------------------------------------------------
--  DDL for Package HRI_OPL_PERIOD_OF_WORK
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."HRI_OPL_PERIOD_OF_WORK" AUTHID CURRENT_USER AS
/* $Header: hriopow.pkh 120.1 2005/06/21 22:22:05 anmajumd noship $ */
--
g_warning_flag VARCHAR2(30);
--
PROCEDURE full_refresh;
--
END HRI_OPL_PERIOD_OF_WORK;

 

/
