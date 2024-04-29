--------------------------------------------------------
--  DDL for Package PER_SUCC_MGMT_MIGRATION_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PER_SUCC_MGMT_MIGRATION_PKG" AUTHID CURRENT_USER AS
/* $Header: pesucmgr.pkh 120.0.12010000.1 2009/05/22 20:33:29 kgowripe noship $*/

PROCEDURE migrate_succ_plan_eit(errbuf                      out  nocopy varchar2
                               ,retcode                     out  nocopy number
                               ,p_business_group_id         IN NUMBER );
END per_succ_mgmt_migration_pkg;

/
