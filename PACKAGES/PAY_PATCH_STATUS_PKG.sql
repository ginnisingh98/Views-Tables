--------------------------------------------------------
--  DDL for Package PAY_PATCH_STATUS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PAY_PATCH_STATUS_PKG" AUTHID CURRENT_USER as
/* $Header: pycoppst.pkh 120.0 2005/05/29 04:08:36 appldev noship $ */
--
procedure ins_patch_status(p_patch_id               out nocopy number,
                           p_patch_number        in            number,
                           p_patch_name          in            varchar2,
                           p_phase               in            varchar2,
                           p_patch_type          in            varchar2,
                           p_status              in            varchar2,
                           p_description         in            varchar2,
                           p_legislation_code    in            varchar2,
                           p_application_release in            varchar2,
                           p_prereq_patch_name   in            varchar2);
end pay_patch_status_pkg;

 

/
