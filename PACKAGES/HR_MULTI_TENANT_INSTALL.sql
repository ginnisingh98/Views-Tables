--------------------------------------------------------
--  DDL for Package HR_MULTI_TENANT_INSTALL
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."HR_MULTI_TENANT_INSTALL" AUTHID CURRENT_USER AS
/* $Header: pemtinst.pkh 120.0.12010000.3 2008/11/19 08:58:56 bchakrab noship $ */

PROCEDURE master_process (errbuf          OUT NOCOPY VARCHAR2
                         ,retcode         OUT NOCOPY NUMBER
                         ,install_mode    IN VARCHAR2
                         ,population_size IN NUMBER);

PROCEDURE child_process (errbuf            OUT NOCOPY VARCHAR2
                        ,retcode           OUT NOCOPY NUMBER
                        ,install_mode      IN         VARCHAR2
                        ,population_size   IN         NUMBER
                        ,population_start  IN         NUMBER
                        ,population_end    IN         NUMBER);

PROCEDURE initialize_orgs (errbuf              OUT  NOCOPY  VARCHAR2
                          ,retcode             OUT  NOCOPY  NUMBER
                          ,p_enterprise_id     IN           NUMBER
                          ,p_organization_id   IN           NUMBER);
END hr_multi_tenant_install;

/
