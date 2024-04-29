--------------------------------------------------------
--  DDL for Package OZF_BASELINESALES_LIFT_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OZF_BASELINESALES_LIFT_PVT" AUTHID CURRENT_USER AS
/*$Header: ozfvbsls.pls 120.0 2005/08/10 23:23 mkothari noship $*/

 G_PKG_NAME CONSTANT VARCHAR2(30):='OZF_BASELINESALES_LIFT_PVT';

 -- ------------------------
 -- Public Procedures
 -- ------------------------

 -- ------------------------------------------------------------------
 -- Name: START_PURGE
 -- Desc: Program to Purge Baseline Sales and Promotional Lift Factor Data
 -- -----------------------------------------------------------------
  PROCEDURE START_PURGE
              (
                ERRBUF            OUT  NOCOPY VARCHAR2,
                RETCODE           OUT  NOCOPY NUMBER,
                p_data_source     IN VARCHAR2,
                p_data_type       IN VARCHAR2,
                p_curr_or_hist    IN VARCHAR2,
                p_record_type     IN VARCHAR2,
                p_as_of_date      IN VARCHAR2
	       );

END OZF_BASELINESALES_LIFT_PVT;

 

/
