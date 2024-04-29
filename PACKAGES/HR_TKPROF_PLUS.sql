--------------------------------------------------------
--  DDL for Package HR_TKPROF_PLUS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."HR_TKPROF_PLUS" AUTHID CURRENT_USER AS
/* $Header: hrtkplus.pkh 120.0 2005/05/31 03:19:59 appldev noship $ */
--
  PROCEDURE run(
    p_location      IN VARCHAR2,
    p_filename      IN VARCHAR2,
    p_backup_stats  IN VARCHAR2    DEFAULT 'N',
    p_script_stats  IN VARCHAR2    DEFAULT 'N',
    p_limit         IN PLS_INTEGER DEFAULT 5,
    p_log_level     IN PLS_INTEGER DEFAULT 2,
    p_explain_table IN VARCHAR2    DEFAULT 'PLAN_TABLE');
--
END hr_tkprof_plus;

 

/
