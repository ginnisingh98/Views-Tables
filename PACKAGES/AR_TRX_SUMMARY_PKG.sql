--------------------------------------------------------
--  DDL for Package AR_TRX_SUMMARY_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."AR_TRX_SUMMARY_PKG" AUTHID CURRENT_USER AS
/* $Header: ARCMUPGS.pls 120.0.12010000.2 2009/05/27 12:40:06 mraymond ship $ */

PROCEDURE refresh_all(
       errbuf                         IN OUT NOCOPY VARCHAR2,
       retcode                        IN OUT NOCOPY VARCHAR2
      );

PROCEDURE refresh_summary_data(
       errbuf                         IN OUT NOCOPY VARCHAR2,
       retcode                        IN OUT NOCOPY VARCHAR2,
       p_max_workers                  IN NUMBER,
       p_worker_number                IN NUMBER,
       p_skip_secondary_processes     IN VARCHAR2 DEFAULT NULL,
       p_fast_delete                  IN VARCHAR2 DEFAULT 'Y');

PROCEDURE process_held_events(
       errbuf                         IN OUT NOCOPY VARCHAR2,
       retcode                        IN OUT NOCOPY VARCHAR2
      );

END AR_TRX_SUMMARY_PKG;

/
