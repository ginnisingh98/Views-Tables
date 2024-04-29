--------------------------------------------------------
--  DDL for Package Body PAY_PATCH_STATUS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PAY_PATCH_STATUS_PKG" as
/* $Header: pycoppst.pkb 120.0 2005/05/29 04:08 appldev noship $ */
--
/*
   Name
      get_result_value
   Description

      This function is used to retrieve the run result value in
      a sparse matrix solution.
*/
procedure ins_patch_status(p_patch_id               out nocopy number,
                           p_patch_number        in            number,
                           p_patch_name          in            varchar2,
                           p_phase               in            varchar2,
                           p_patch_type          in            varchar2,
                           p_status              in            varchar2,
                           p_description         in            varchar2,
                           p_legislation_code    in            varchar2,
                           p_application_release in            varchar2,
                           p_prereq_patch_name   in            varchar2)
is
  l_patch_id number;
begin
--
     select id
       into l_patch_id
       from pay_patch_status
      where patch_number = p_patch_number;
--
exception
   when no_data_found then
--
    select pay_patch_status_s.nextval
      into l_patch_id
      from dual;
--
    insert into pay_patch_status
               (ID,
                PATCH_NUMBER,
                PATCH_NAME,
                PHASE,
                PROCESS_TYPE,
                APPLIED_DATE,
                STATUS,
                DESCRIPTION,
                UPDATE_DATE,
                LEGISLATION_CODE,
                APPLICATION_RELEASE,
                PREREQ_PATCH_NAME
               )
    values
         (l_patch_id,
          p_patch_number,
          p_patch_name,
          p_phase,
          p_patch_type,
          sysdate,
          p_status,
          p_description,
          sysdate,
          p_legislation_code,
          p_application_release,
          p_prereq_patch_name
    );
--
  p_patch_id := l_patch_id;
--
end ins_patch_status;
--
end pay_patch_status_pkg;

/
