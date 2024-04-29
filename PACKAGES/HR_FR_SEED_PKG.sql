--------------------------------------------------------
--  DDL for Package HR_FR_SEED_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."HR_FR_SEED_PKG" AUTHID CURRENT_USER as
/* $Header: pefrbssd.pkh 115.8 2003/04/10 09:12:34 jheer noship $ */

procedure create_item_types (p_business_group_id  in number);
procedure create_key_types (p_business_group_id  in number);
procedure create_restriction_types (p_business_group_id  in number);
procedure create_valid_key_types (p_business_group_id  in number);
procedure create_valid_restrictions (p_business_group_id  in number);
procedure create_template_Dis3i (p_business_group_id in number);
procedure create_template_Dis4i (p_business_group_id in number);
procedure seed_data (errbuf                  out nocopy varchar2,
                     retcode                 out nocopy number,
                     p_business_group_id IN NUMBER);

END hr_fr_seed_pkg;

 

/
