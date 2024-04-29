--------------------------------------------------------
--  DDL for Package HR_TIPS_DML
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."HR_TIPS_DML" AUTHID CURRENT_USER as
/* $Header: hrtipdml.pkh 115.1 99/10/05 17:59:11 porting ship $ */
--
procedure addTip(p_filename          varchar2
                ,p_screen            varchar2
                ,p_field             varchar2
                ,p_language          varchar2
                ,p_business_group_id number      default null
                ,p_text              long
                ,p_mode              varchar2
      );
--
procedure clearTips(p_filename          varchar2
                   ,p_language          varchar2
                   ,p_business_group_id number    default null);
--
--
end hr_tips_dml;

 

/
