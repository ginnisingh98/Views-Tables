--------------------------------------------------------
--  DDL for Package Body HR_MULTI_TENANT_INSTALL
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."HR_MULTI_TENANT_INSTALL" AS
/* $Header: pemtinst.pkb 120.0.12010000.3 2008/11/19 09:06:08 bchakrab noship $ */
procedure master_process
    (errbuf          out nocopy varchar2
    ,retcode         out nocopy number
    ,install_mode    in varchar2
    ,population_size in number) as
BEGIN
NULL;
END master_process;

procedure child_process
    (errbuf          out nocopy varchar2
    ,retcode         out nocopy number
    ,install_mode      in varchar2
    ,population_size   in number
    ,population_start  in number
    ,population_end    in number) as
begin
null;
end;

PROCEDURE initialize_orgs (errbuf              OUT  NOCOPY  VARCHAR2
                          ,retcode             OUT  NOCOPY  NUMBER
                          ,p_enterprise_id     IN           NUMBER
                          ,p_organization_id   IN           NUMBER) AS
BEGIN
NULL;
END initialize_orgs;
END hr_multi_tenant_install;

/
