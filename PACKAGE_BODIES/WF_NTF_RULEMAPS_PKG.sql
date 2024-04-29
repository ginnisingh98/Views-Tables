--------------------------------------------------------
--  DDL for Package Body WF_NTF_RULEMAPS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."WF_NTF_RULEMAPS_PKG" as
/* $Header: WFNTFRMB.pls 120.1 2005/07/02 03:16:26 appldev noship $ */

procedure insert_row(x_rule_name      in varchar2,
		     x_attribute_name in varchar2,
		     x_column_name    in varchar2)
is
begin
  insert into wf_ntf_rule_maps (
    rule_name,
    attribute_name,
    column_name,
    creation_date
  ) values (
    x_rule_name,
    x_attribute_name,
    x_column_name,
    sysdate);
exception
  when others then
    wf_core.context('Wf_ntf_rulemaps_pkg', 'Insert_Row',  x_rule_name, x_attribute_name);
    raise;
end insert_row;

procedure delete_row(x_rule_name      in varchar2,
		     x_attribute_name in varchar2)
is
begin
  delete from wf_ntf_rule_maps
  where   rule_name      = x_rule_name
  and   attribute_name = x_attribute_name;

  if (sql%notfound) then
    raise no_data_found;
  end if;
exception
  when others then
    wf_core.context('Wf_ntf_rulemaps_pkg', 'Delete_Row',  x_rule_name, x_attribute_name);
    raise;
end delete_row;

procedure update_row(x_rule_name      in varchar2,
		     x_attribute_name in varchar2,
		     x_column_name    in varchar2)
is
begin
     update wf_ntf_rule_maps
     set   column_name    = x_column_name
     where   rule_name      = x_rule_name
     and   attribute_name = x_attribute_name;

     if SQL%NOTFOUND then
       raise no_data_found;
     end if;
exception
  when others then
    wf_core.context('Wf_ntf_rulemaps_pkg', 'Update_Row',  x_rule_name, x_attribute_name);
    raise;
end update_row;

procedure load_row(x_rule_name      in varchar2,
		   x_attribute_name in varchar2,
		   x_column_name    in varchar2)
is
begin

 if wf_ntf_rules_pkg.g_mode = 'FORCE' then
   Wf_ntf_rulemaps_pkg.update_row(x_rule_name,
			       x_attribute_name,
			       x_column_name);
 end if;
exception
  when others then
     Wf_ntf_rulemaps_pkg.insert_row(x_rule_name,
				 x_attribute_name,
				 x_column_name);
end load_row;

end WF_NTF_RULEMAPS_PKG;


/
