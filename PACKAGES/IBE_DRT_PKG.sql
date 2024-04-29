--------------------------------------------------------
--  DDL for Package IBE_DRT_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IBE_DRT_PKG" AUTHID CURRENT_USER AS
/* $Header: IBEDRTPS.pls 120.0.12010000.1 2018/04/06 23:21:49 ytian noship $ */
  --
  --- Wrapper around FND_LOG package to write into log file (when debugging is on)
  --
  g_debug         CONSTANT VARCHAR2(1)  := NVL(fnd_profile.value('AFLOG_ENABLED'), 'N');
  g_pkg_name      CONSTANT VARCHAR2(30) := 'IBE_DRT_PKG';
  g_module_prefix CONSTANT VARCHAR2(50) := 'ibe.plsql.' || g_pkg_name || '.';
  g_gdpr_ex       EXCEPTION;
  PRAGMA EXCEPTION_INIT( g_gdpr_ex, -20001 );


    PROCEDURE write_log
      (message       IN         varchar2
	,stage		 IN					varchar2);


 PROCEDURE ibe_hr_drc
    (person_id       IN         number
    ,result_tbl    OUT NOCOPY per_drt_pkg.result_tbl_type);


END ibe_drt_pkg;

/
