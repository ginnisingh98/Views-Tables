--------------------------------------------------------
--  DDL for Package HRI_OPL_SUP_STATUS_HST
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."HRI_OPL_SUP_STATUS_HST" AUTHID CURRENT_USER AS
/* $Header: hrioshst.pkh 120.1.12000000.2 2007/04/12 13:18:20 smohapat noship $ */
  --
PROCEDURE full_refresh
        (errbuf        OUT NOCOPY VARCHAR2
        ,retcode       OUT NOCOPY VARCHAR2
        ,p_start_date  IN VARCHAR2
        ,p_end_date    IN VARCHAR2
        ,p_debugging     IN VARCHAR2 DEFAULT 'N'
        );
  --
PROCEDURE incremental_update
        (errbuf          OUT NOCOPY  VARCHAR2
        ,retcode         OUT  NOCOPY VARCHAR2
        ,p_debugging     IN VARCHAR2 DEFAULT 'N'
        );
  --
PROCEDURE find_changed_supervisors;
  --
PROCEDURE full_refresh
        (p_start_date  IN DATE
        ,p_end_date    IN DATE
        );
  --
PROCEDURE incremental_update
        (p_start_date    IN DATE
        ,p_end_date      IN DATE
        );
  --
PROCEDURE run_request
        (errbuf          OUT  NOCOPY VARCHAR2
        ,retcode         OUT  NOCOPY VARCHAR2
        ,p_start_date    IN VARCHAR2
        ,p_end_date      IN VARCHAR2
        ,p_full_refresh  IN VARCHAR2
        ,p_debugging     IN VARCHAR2 DEFAULT 'N'
        );
  --
END HRI_OPL_SUP_STATUS_HST;

 

/
