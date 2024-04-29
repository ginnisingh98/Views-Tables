--------------------------------------------------------
--  DDL for Package PAY_JP_ITW_REPORT_ARCHIVE
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PAY_JP_ITW_REPORT_ARCHIVE" AUTHID CURRENT_USER AS
/* $Header: pyjpitwreparch.pkh 120.1.12000000.2 2007/04/17 03:30:50 ttagawa noship $ */
--
PROCEDURE submit_request
            (errbuf                      OUT NOCOPY VARCHAR2
            ,retcode                     OUT NOCOPY NUMBER
            ,p_run_pre_tax_archive       IN  VARCHAR2
            --
            ,p_effective_date            IN  VARCHAR2
            ,p_business_group_id         IN  VARCHAR2
            ,p_payroll_id                IN  VARCHAR2 DEFAULT NULL
            ,p_itax_organization_id      IN  VARCHAR2 DEFAULT NULL
            ,p_include_terminated_flag   IN  VARCHAR2
            ,p_termination_date_from     IN  VARCHAR2 DEFAULT NULL
            ,p_termination_date_to       IN  VARCHAR2 DEFAULT NULL
            ,p_rearchive_flag            IN  VARCHAR2
            ,p_inherit_archive_flag      IN  VARCHAR2
            ,p_publication_period_status IN  VARCHAR2
            ,p_publication_start_date    IN  VARCHAR2 DEFAULT NULL
            ,p_publication_end_date      IN  VARCHAR2 DEFAULT NULL
            --
            ,p_enable_flag               IN  VARCHAR2 DEFAULT NULL
            ,p_start_date                IN  VARCHAR2 DEFAULT NULL
            ,p_end_date                  IN  VARCHAR2 DEFAULT NULL
            ,p_consolidation_set_id      IN  VARCHAR2 DEFAULT NULL
            );
--
END PAY_JP_ITW_REPORT_ARCHIVE;

 

/
