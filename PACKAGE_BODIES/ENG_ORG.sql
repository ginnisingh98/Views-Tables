--------------------------------------------------------
--  DDL for Package Body ENG_ORG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."ENG_ORG" AS
/* $Header: ENGORGDB.pls 115.1 99/07/27 08:40:39 porting ship $ */
--
  PROCEDURE eng_predel_validation (p_organization_id   IN number) is


--
-- Parameters
-- p_organization_id : UID of organization being deleted.
--
-- Local Variable
v_dummy varchar2(1);
--
begin
 hr_utility.set_location('eng_org.eng_predel_validation',1);
 select 1
 into v_dummy
 from sys.dual
 where exists(select 'exists'
              from  eng_engineering_changes ec
              where ec.responsible_organization_id = p_organization_id);
--
-- If got through then error
--
 hr_utility.set_message(801,'HR_7043_ORG_ENG_PRE_DELETE');
 hr_utility.raise_error;
--
exception
  when no_data_found then null;
end eng_predel_validation;
--
END eng_org;

/
