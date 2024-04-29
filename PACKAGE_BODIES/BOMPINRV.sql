--------------------------------------------------------
--  DDL for Package Body BOMPINRV
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."BOMPINRV" as
/* $Header: BOMINRVB.pls 120.3 2005/12/05 03:17:03 vhymavat ship $ */
Procedure increment_revision(
	i_item_id in mtl_item_revisions.inventory_item_id%type,
 	i_org_id in mtl_item_revisions.organization_id%type,
        i_date_time in mtl_item_revisions.effectivity_date%type,
	who in ProgramInfoStruct,
 	o_out_code in out nocopy mtl_item_revisions.revision%type,
        error_message in out nocopy varchar) is

	Cursor get_current_rev is
  		select a.revision,
		       nvl(length(rtrim(a.revision,'0123456789')),0) rev_len
  		from mtl_item_revisions_b a
  		where a.organization_id = i_org_id
  		and   a.inventory_item_id = i_item_id
  		and   a.effectivity_date = (
			select max(b.effectivity_date)
			from mtl_item_revisions_b b
			where b.inventory_item_id = a.inventory_item_id
			and   b.organization_id   = a.organization_id
			and   b.effectivity_date  <= i_date_time)
		--	and   b.implementation_date is not null)
--  		and   a.implementation_date is not null  commneted for bug 4637312
		order by a.revision desc; --* Added for Bug #3483066
 	current_rev get_current_rev%rowtype;
	Cursor check_duplicate_rev(rev in varchar) is
          	select 'x'
     	  	from   mtl_item_revisions_b r
  	  	where r.organization_id = i_org_id
  	  	and   r.inventory_item_id = i_item_id
  	  	and   r.revision = rev;
 	dummy varchar2(1);
	new_item_revision mtl_item_revisions.revision%type := null;
        old_rev_len     NUMBER;
        new_rev_len     NUMBER;
  	i_revision_id   NUMBER;
	i_language_code VARCHAR2(3);
Begin

/* Get current implemented rev */

	Open get_current_rev;
	Fetch get_current_rev into current_rev;
	If get_current_rev%notfound then
		Close get_current_rev;
		Raise no_data_found;
	end if;
	Close get_current_rev;

/*
 * Check to see if the current rev is strictly numeric, increment it
 * and then check if the new one exists.
 */

    	If current_rev.rev_len = 0 then  /* Numbers only */
		new_item_revision :=
			to_char(to_number(current_rev.revision)+1);
                old_rev_len := NVL(length(current_rev.revision),0);
                new_rev_len := NVL(length(new_item_revision),0);
                if (new_rev_len < old_rev_len) then
                        new_item_revision := lpad(new_item_revision,
                                old_rev_len,'0');
                end if;
		Open check_duplicate_rev(new_item_revision);
		Fetch check_duplicate_rev into dummy;
		If check_duplicate_rev%found then
    			o_out_code := null;
		else
			Insert into mtl_item_revisions_b(
				inventory_item_id,
				organization_id,
				revision,
				last_update_date,
				last_updated_by,
				creation_date,
				created_by,
				last_update_login,
				effectivity_date,
				program_application_id,
				program_id,
				program_update_date,
				request_id,
				REVISION_ID,
				REVISION_LABEL,
				OBJECT_VERSION_NUMBER)
			values (
				i_item_id,
 				i_org_id,
				new_item_revision,
				sysdate,
				who.userid,
				sysdate,
				who.userid,
                 		who.loginid,
        			i_date_time,
                 		who.appid,
                		who.progid,
				sysdate,
                 		who.reqstid,
				MTL_ITEM_REVISIONS_B_S.nextval,
				new_item_revision,
				1) RETURNING revision_id INTO i_revision_id;

			 SELECT userenv('LANG') INTO i_language_code FROM dual;
   			-- description is stored in MTL_ITEM_REVISIONS_TL
   			insert into MTL_ITEM_REVISIONS_TL (
                       		inventory_item_id,
                        	organization_id,
                        	revision_id,
                        	language,
                        	source_lang,
                        	last_update_date,
                        	last_updated_by,
                        	creation_date,
                        	created_by,
                        	last_update_login,
                        	description )
                 	SELECT  i_item_id,
                        	i_org_id,
                        	i_revision_id,
                        	lang.language_code,
                        	i_language_code,
                        	sysdate,
                        	who.userid,
                        	sysdate,
                        	who.userid,
                        	who.userid,
                        	NULL
                       	FROM FND_LANGUAGES lang
                       	where lang.INSTALLED_FLAG in ('I', 'B')
                       	and not exists
                      		(select NULL
                       		 from MTL_ITEM_REVISIONS_TL T
                       		 where T.INVENTORY_ITEM_ID = i_item_id
                       		 and   T.ORGANIZATION_ID = i_org_id
                       		 and   T.REVISION_ID = i_revision_id
                       		 and   T.LANGUAGE = lang.LANGUAGE_CODE);

			o_out_code := new_item_revision;
		end if;
		Close check_duplicate_rev;
	else
		o_out_code := null;
	end if;
	error_message := null;
Exception
	when NO_DATA_FOUND then /* no revs found for item - ignore */
     		o_out_code := null;
		error_message := null;
   	when OTHERS then
     		o_out_code := null;
		error_message := substrb(sqlerrm, 1, 150);
end increment_revision;

end BOMPINRV;

/
