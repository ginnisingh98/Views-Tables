--------------------------------------------------------
--  DDL for Package PAY_JP_IWHT_REPORT_ARCH_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PAY_JP_IWHT_REPORT_ARCH_PKG" AUTHID CURRENT_USER AS
-- $Header: pyjpiwra.pkh 120.1.12010000.2 2010/03/05 07:34:49 rdarasi noship $
-- *************************************************************************
-- * Copyright (c) Oracle Corporation Japan,2009       Product Development.
-- * All rights reserved
-- *************************************************************************
-- *
-- * PROGRAM NAME
-- *  PAYJLWL.pkb
-- *
-- * DESCRIPTION
-- * This script creates the package body of PAY_JP_IWHT_REPORT_ARCH_PKG
-- *
-- * USAGE
-- *   To install       sqlplus <apps_user>/<apps_pwd> @PAY_JP_IWHT_REPORT_ARCH_PKG .pkh
-- *   To Execute       sqlplus <apps_user>/<apps_pwd> EXEC PAY_JP_IWHT_REPORT_ARCHIVE.<procedure name>
-- *
-- * PROGRAM LIST
-- * ==========
-- * NAME                 DESCRIPTION
-- * -----------------    --------------------------------------------------
-- * SUBMIT_REQUEST
-- *
-- * DEPENDENCIES
-- *   None
-- *
-- * CALLED BY
-- *   Concurrent Program
-- *
-- * LAST UPDATE DATE   10-Feb-2010
-- *   Date the program has been modified for the last time
-- *
-- * HISTORY
-- * =======
-- *
-- * VERSION            DATE        AUTHOR(S)             DESCRIPTION
-- * -------           ----------- -----------------     -----------------------------
-- * 120.0.12010000.1  09-Aug-2009  MPOTHALA               Creation
-- *************************************************************************
--
PROCEDURE submit_request
             (errbuf                      OUT NOCOPY VARCHAR2
             ,retcode                     OUT NOCOPY NUMBER
             ,p_run_pre_tax_archive       IN  VARCHAR2
              --
             ,p_effective_date            IN  VARCHAR2
             ,p_business_group_id         IN  VARCHAR2
             ,p_rearchive_flag            IN  VARCHAR2 DEFAULT NULL
             ,p_itax_organization_id      IN  VARCHAR2 DEFAULT NULL
             ,p_payroll_id                IN  VARCHAR2 DEFAULT NULL
             ,p_termination_date_from     IN  VARCHAR2 DEFAULT NULL
             ,p_termination_date_to       IN  VARCHAR2 DEFAULT NULL
             ,p_assignment_set_id         IN  VARCHAR2 DEFAULT NULL
             --
             ,p_enable_flag               IN  VARCHAR2 DEFAULT NULL
             ,p_start_date                IN  VARCHAR2 DEFAULT NULL
             ,p_end_date                  IN  VARCHAR2 DEFAULT NULL
             ,p_consolidation_set_id      IN  VARCHAR2 DEFAULT NULL
             );

--
END PAY_JP_IWHT_REPORT_ARCH_PKG;

/
