--------------------------------------------------------
--  DDL for Package HR_COPY_GSP
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."HR_COPY_GSP" AUTHID CURRENT_USER as
/* $Header: hrcpygsp.pkh 120.0 2005/05/30 23:24:59 appldev noship $ */
--
procedure template(p_template_id       in number,
                   p_new_name          in varchar2,
                   p_business_group_id in number,
                   p_copy_ru           in varchar2,
                   p_copy_rv           in varchar2,
                   p_copy_kt           in varchar2);
--
procedure itu (p_itu_id            in number,
               p_template_id       in number,
               p_name              in varchar2,
               p_business_group_id in number,
               p_copy_ru           in varchar2,
               p_copy_rv           in varchar2,
               p_copy_kt           in varchar2);
--
procedure item_type (p_item_type_id      in number,
                     p_new_name          in varchar2,
                     p_business_group_id in number,
                     p_copy_vr           in varchar2,
                     p_copy_vkt          in varchar2);
--
end hr_copy_gsp;

 

/
