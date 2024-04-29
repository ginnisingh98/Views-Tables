--------------------------------------------------------
--  DDL for Package HR_ORGANIZATION_BE10
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."HR_ORGANIZATION_BE10" AUTHID CURRENT_USER as 
--Code generated on 30/08/2013 11:36:20
/* $Header: hrapiwfe.pkb 120.4.12010000.2 2008/09/29 12:54:07 srgnanas ship $*/
procedure create_org_class_internal_a (
p_effective_date               date,
p_organization_id              number,
p_org_classif_code             varchar2,
p_classification_enabled       varchar2,
p_org_information_id           number,
p_object_version_number        number);
end hr_organization_be10;

/
