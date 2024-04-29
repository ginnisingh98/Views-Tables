--------------------------------------------------------
--  DDL for Package GMA_PURGE_ENGINE
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."GMA_PURGE_ENGINE" AUTHID CURRENT_USER AS
/* $Header: GMAPRGES.pls 120.0.12010000.1 2008/07/30 06:17:26 appldev ship $ */

  use_ad_ddl  CONSTANT BOOLEAN := FALSE;

  -- GLOBAL variable,introduced for Archive and Purge action and name
  PA_OPTION NUMBER(2);
  PA_OPTION_NAME varchar2(2000);

  /***** procedure declarations *****/
  PROCEDURE main(
                 errbuf              OUT NOCOPY VARCHAR2,
                 retcode             OUT NOCOPY VARCHAR2,
                 p_purge_id           IN sy_purg_mst.purge_id%TYPE,
                 p_appl_short_name    IN fnd_application.application_short_name%TYPE DEFAULT 'GMA',
                 p_job_run            IN NUMBER DEFAULT NULL,
                 p_job_name           IN VARCHAR2 DEFAULT NULL);

END GMA_PURGE_ENGINE;

/
