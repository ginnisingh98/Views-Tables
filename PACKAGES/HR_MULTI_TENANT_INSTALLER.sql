--------------------------------------------------------
--  DDL for Package HR_MULTI_TENANT_INSTALLER
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."HR_MULTI_TENANT_INSTALLER" AUTHID CURRENT_USER AS
/* $Header: pemtstup.pkh 120.0.12010000.5 2008/11/28 09:44:26 bchakrab noship $ */

--
-- Name
--   install_hr_multi_tenant
--
-- Purpose
--    This procedure is called by the concurrent program
--    'Enable Multiple Tenant Security Process'. If valid profile
--    is not set for HR_ENABLE_MULTI_TENANCY it returns. If
--    the multi tenancy solution is not already installed then
--    it installs the solution. Irrespective of the soultion being installed
--    or not, it generates the package 'HR_MULTI_TENANCY_PKG'
--    and 'HR_MULTI_TENANT_INSTALL'.
--
-- Arguments
--   errbuf and retcode.
--

PROCEDURE install_hr_multi_tenant  (errbuf  OUT  NOCOPY  VARCHAR2
                                   ,retcode OUT  NOCOPY  NUMBER);

END hr_multi_tenant_installer;

/
