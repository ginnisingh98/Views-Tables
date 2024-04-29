--------------------------------------------------------
--  DDL for Package HRI_OPL_WMV
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."HRI_OPL_WMV" AUTHID CURRENT_USER AS
/* $Header: hriowmv.pkh 115.4 2004/04/29 08:19:48 vsethi noship $ */

/* Exceptions raised when there is a problem with a fast formula */
ff_not_compiled   EXCEPTION;   -- Raised when a fast formula is not compiled

PROCEDURE range_cursor( pactid         IN NUMBER,
                        sqlstr         OUT NOCOPY VARCHAR2);

PROCEDURE action_creation( pactid      IN NUMBER,
                           stperson    IN NUMBER,
                           endperson   IN NUMBER,
                           chunk       IN NUMBER);

PROCEDURE init_code( p_payroll_action_id      IN NUMBER);

PROCEDURE archive_code( p_assactid        IN NUMBER,
                        p_effective_date  IN DATE);

PROCEDURE deinit_code( p_payroll_action_id      IN NUMBER);

PROCEDURE run_for_bg(p_business_group_id  IN NUMBER,
                     p_full_refresh       IN VARCHAR2,
                     p_collect_fte        IN VARCHAR2,
                     p_collect_head       IN VARCHAR2,
                     p_collect_from       IN VARCHAR2,
                     p_collect_to         IN VARCHAR2);
--
PROCEDURE shared_hrms_dflt_prcss
  (errbuf              OUT NOCOPY VARCHAR2
  ,retcode             OUT NOCOPY NUMBER
  ,p_collect_from_date IN VARCHAR2 DEFAULT NULL
  ,p_collect_to_date   IN VARCHAR2 DEFAULT NULL
  ,p_full_refresh      IN VARCHAR2 DEFAULT NULL
  ,p_attribute1        IN VARCHAR2 DEFAULT NULL
  ,p_attribute2        IN VARCHAR2 DEFAULT NULL);
--
END hri_opl_wmv;

 

/
