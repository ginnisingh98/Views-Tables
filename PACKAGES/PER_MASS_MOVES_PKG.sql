--------------------------------------------------------
--  DDL for Package PER_MASS_MOVES_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PER_MASS_MOVES_PKG" AUTHID CURRENT_USER as
/* $Header: pemmv01t.pkh 115.0 99/07/18 14:02:10 porting ship $ */
--
--
  procedure insert_row
                  (p_business_group_id in number,
                   p_effective_date in date,
                   p_new_organization_id in number,
                   p_source_organization_id in number,
                   p_reason in varchar2,
                   p_status in varchar2,
                   p_mass_move_id out number,
                   p_row_id out varchar2);
--
--
  procedure update_row
                  (p_mass_move_id in number,
                   p_effective_date in date,
                   p_new_organization_id in number,
                   p_source_organization_id in number,
                   p_reason in varchar2,
                   p_row_id in varchar2);
--
--
  procedure delete_row
                  (p_mass_move_id in number,
                   p_row_id in varchar2);
--
--
  procedure lock_row
                  (p_mass_move_id in number,
                   p_business_group_id in number,
                   p_effective_date in date,
                   p_new_organization_id in number,
                   p_source_organization_id in number,
                   p_reason in varchar2,
                   p_status in varchar2,
                   p_row_id in varchar2);


end per_mass_moves_pkg ;


 

/
