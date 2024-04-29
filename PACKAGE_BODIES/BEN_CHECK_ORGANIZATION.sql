--------------------------------------------------------
--  DDL for Package Body BEN_CHECK_ORGANIZATION
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."BEN_CHECK_ORGANIZATION" AS
/* $Header: bechkorg.pkb 115.0 2003/04/30 11:44:08 glingapp noship $ */

   cursor chk_org_role_upd(p_organization_id in number, p_date_from in date , p_date_to in date) is
          select '1' from ben_popl_org_f
           where organization_id = p_organization_id
	    and ( p_date_from  >  effective_start_date
                  or nvl(p_date_to, effective_end_date) < effective_end_date);

   cursor chk_org_role_del(p_organization_id in number) is
          select '1' from ben_popl_org_f
           where organization_id = p_organization_id;

   cursor chk_org_bnf_upd(p_organization_id in number, p_date_from in date, p_date_to in date) is
             select '1' from ben_pl_bnf_f
              where organization_id = p_organization_id
	        and ( p_date_from  >  effective_start_date
                      or  nvl(p_date_to, effective_end_date) < effective_end_date);

   cursor chk_org_bnf_del(p_organization_id in number) is
          select '1' from ben_pl_bnf_f
           where organization_id = p_organization_id;

   l_data_exists varchar2(2);
   l_status varchar2(1);
   l_industry varchar2(1);

   procedure chk_org_role_bnf_upd
   (
    p_organization_id              IN hr_all_organization_units.organization_id%TYPE
   ,p_date_from			   IN date
   ,p_date_to 			   IN date
   )
   is
   Begin
     if (fnd_installation.get(appl_id     => 805
                                ,dep_appl_id => 805
      	                        ,status      => l_status
            	                ,industry    => l_industry)) then
       if (l_status = 'I') then
     	open chk_org_role_upd(p_organization_id, p_date_from, p_date_to);
        fetch chk_org_role_upd into l_data_exists;
      	if chk_org_role_upd%found then
     	close chk_org_role_upd;
     	fnd_message.set_name('BEN', 'BEN_93384_ORG_ROLE_EXISTS');
     	fnd_message.raise_error;
     	end if;
     	close chk_org_role_upd;

	open chk_org_bnf_upd(p_organization_id, p_date_from, p_date_to);
        fetch chk_org_bnf_upd into l_data_exists;
	if chk_org_bnf_upd%found then
	close chk_org_bnf_upd;
 	fnd_message.set_name('BEN', 'BEN_93385_ORG_BNF_EXISTS');
     	fnd_message.raise_error;
	end if;
     	close chk_org_bnf_upd;
       end if;
     end if;
   End;

  procedure chk_org_role_bnf_del
   (
    p_organization_id              IN hr_all_organization_units.organization_id%TYPE
   )
   is
   Begin
     if (fnd_installation.get(appl_id     => 805
                                ,dep_appl_id => 805
      	                        ,status      => l_status
            	                ,industry    => l_industry)) then
      if (l_status = 'I') then
     	open chk_org_role_del(p_organization_id);
        fetch chk_org_role_del into l_data_exists;
      	if chk_org_role_del%found then
     	close chk_org_role_del;
     	fnd_message.set_name('BEN', 'BEN_93384_ORG_ROLE_EXISTS');
     	fnd_message.raise_error;
     	end if;
     	close chk_org_role_del;

	open chk_org_bnf_del(p_organization_id);
        fetch chk_org_bnf_del into l_data_exists;
	if chk_org_bnf_del%found then
	close chk_org_bnf_del;
 	fnd_message.set_name('BEN', 'BEN_93385_ORG_BNF_EXISTS');
     	fnd_message.raise_error;
	end if;
     	close chk_org_bnf_del;
      end if;
     end if;
   End;


END BEN_CHECK_ORGANIZATION;


/
