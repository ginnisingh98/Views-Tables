--------------------------------------------------------
--  DDL for Package Body WF_NTF_RULECRITERIA_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."WF_NTF_RULECRITERIA_PKG" as
/* $Header: WFNTFRCB.pls 120.1 2005/07/02 03:16:11 appldev noship $ */

procedure insert_row(x_rule_name  in varchar2,
		     x_msg_type   in varchar2)
is
begin
  insert into wf_ntf_rule_criteria (
    rule_name,
    message_type,
    creation_date
  ) values (
    x_rule_name,
    x_msg_type,
    sysdate);
exception
  when others then
    wf_core.context('Wf_ntf_rulecriteria_pkg', 'Insert_Row', x_rule_name, x_msg_type);
    raise;
end insert_row;

procedure delete_row(x_rule_name  in varchar2,
     		     x_msg_type   in varchar2)
is
begin
  delete from wf_ntf_rule_criteria
  where   rule_name = x_rule_name
  and   message_type = x_msg_type;

  if (sql%notfound) then
    raise no_data_found;
  end if;
exception
  when others then
    wf_core.context('Wf_ntf_rulecriteria_pkg', 'Delete_Row',  x_rule_name, x_msg_type);
    raise;
end delete_row;

procedure update_row(x_rule_name  in varchar2,
		     x_msg_type   in varchar2)
is
begin
       update wf_ntf_rule_criteria
       set    message_type = x_msg_type
       where  rule_name = x_rule_name;

      if SQL%NOTFOUND then
	 raise no_data_found;
      end if;
exception
  when others then
    wf_core.context('Wf_ntf_rulecriteria_pkg', 'Update_Row',  x_rule_name, x_msg_type);
    raise;
end update_row;

procedure load_row(x_rule_name     in varchar2,
		   x_msg_type      in varchar2)
is
begin
 if wf_ntf_rules_pkg.g_mode = 'FORCE' then
   wf_ntf_rulecriteria_pkg.update_row(x_rule_name,
                                   x_msg_type);
 end if;
exception
  when others then
   wf_ntf_rulecriteria_pkg.insert_row(x_rule_name,
                                   x_msg_type);
end load_row;

end WF_NTF_RULECRITERIA_PKG;


/
