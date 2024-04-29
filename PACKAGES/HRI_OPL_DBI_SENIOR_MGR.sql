--------------------------------------------------------
--  DDL for Package HRI_OPL_DBI_SENIOR_MGR
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."HRI_OPL_DBI_SENIOR_MGR" AUTHID CURRENT_USER AS
/* $Header: hriodmgr.pkh 120.0 2005/05/29 07:28:14 appldev noship $ */

PROCEDURE load_senior_mgrs;

PROCEDURE load_senior_mgrs(errbuf    OUT NOCOPY VARCHAR2,
                           retcode   OUT NOCOPY VARCHAR2);

END hri_opl_dbi_senior_mgr;

 

/
