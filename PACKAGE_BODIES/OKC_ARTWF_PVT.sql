--------------------------------------------------------
--  DDL for Package Body OKC_ARTWF_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OKC_ARTWF_PVT" as
/* $Header: OKCARTWFB.pls 120.10.12010000.2 2010/05/19 10:05:55 harchand ship $ */

-- get info from versions table
	cursor cv(cp_org_id in number, cp_version_id in number) is
		select
         art.org_id,
		   art.article_id,
   		artv.article_version_id,
   		artv.article_status,
   		artv.adoption_type,
   		artv.global_yn,
   		'AP-'||
         to_char(art.org_id)||'.'||
   		to_char(art.article_id)||'.'||
   		to_char(artv.article_version_id)||'.'||
   		to_char(artv.object_version_number)	ikey,
         substr(nvl(art.article_number, art.article_title),0,240) ukey,
   		artv.object_version_number+1,
         art.article_title,
         artv.article_version_number
		from
			okc_articles_all art,
   	   okc_article_versions artv
		where art.article_id = artv.article_id
		and   art.standard_yn = 'Y'
		and   artv.article_status in ('DRAFT','REJECTED')
		and   art.org_id = cp_org_id
		and   artv.article_version_id = cp_version_id
		and   greatest(nvl(trunc(end_date), trunc(sysdate))+1, trunc(sysdate)) <> trunc(sysdate); -- bug#3517002
/*
      for update of
      artv.article_status,
      artv.object_version_number,
      artv.last_update_date,
      artv.last_updated_by
      nowait;
*/

-- get info from adoptions table
	cursor ca(cp_org_id in number, cp_version_id in number) is
		select
		   arta.local_org_id,
		   art.article_id,
   		arta.global_article_version_id,
   		arta.adoption_status,
   		arta.adoption_type,
   		artv.global_yn,
   		'AD-'||
         to_char(arta.local_org_id)||'.'||
   		to_char(art.article_id)||'.'||
   		to_char(artv.article_version_id)||'.'||
   		to_char(arta.object_version_number) ikey,
   		substr(nvl(art.article_number,art.article_title),0,240) ukey,
   		arta.object_version_number+1,
         art.article_title,
         artv.article_version_number
		from
			okc_articles_all art,
   		okc_article_versions artv,
   		okc_article_adoptions arta
		where 	art.article_id = artv.article_id
		and	art.standard_yn = 'Y'
		and	artv.global_yn = 'Y'
		and	arta.adoption_type = 'AVAILABLE'
      and   (arta.adoption_status = 'REJECTED' or arta.adoption_status is null)
		and	arta.local_org_id = cp_org_id
		and	artv.article_version_id = cp_version_id
		and	arta.global_article_version_id = artv.article_version_id
		and	artv.article_status = 'APPROVED'
		and	sysdate <= nvl(artv.end_date,sysdate+1)
      and   not exists
      (
         select 1
         from okc_article_adoptions
         where global_article_version_id in
         (select article_version_id
         from okc_article_versions
         where article_id = art.article_id)
         and local_org_id = arta.local_org_id
         and adoption_type = 'LOCALIZED'
         union
         select 1
         from okc_article_adoptions
         where global_article_version_id in
         (select article_version_id
         from okc_article_versions
         where article_id = art.article_id)
         and local_org_id = arta.local_org_id
         and adoption_type = 'ADOPTED'
         and article_version_number > artv.article_version_number
      );
/*
      for update of
      arta.adoption_type,
      arta.adoption_status,
      arta.object_version_number,
      arta.last_update_date,
      arta.last_updated_by
      nowait;
*/

	type c_rec_type is record (
      	org_id               okc_articles_all.org_id%type,
	      article_id           okc_articles_all.article_id%type,
   	   article_version_id   okc_article_versions.article_version_id%type,
   	   article_status       okc_article_versions.article_status%type,
   	   adoption_type        okc_article_versions.adoption_type%type,
   	   global_yn            okc_article_versions.global_yn%type,
   	   ikey                 wf_items.item_key%type,
   	   ukey                 wf_items.user_key%type,
   	   ovn                  number,
      	article_title           okc_articles_all.article_title%type,
      	article_version_number  okc_article_versions.article_version_number%type
   );

	type	c_tab_type is table of c_rec_type index by binary_integer;
	c_tab 	c_tab_type;

-- write pointer for success table
	write_ptr binary_integer;
-- write pointer for errors table
	error_ptr binary_integer;

--!!!
-- begin logging procedure declarations
g_level_procedure constant number := fnd_log.level_procedure;
g_module          constant varchar2(250) := 'okc.plsql.okc_artwf_pvt.';
l_api_name        varchar2(30);
-- end logging procedure declarations
-- begin logging procedures
procedure start_log(api_name in varchar2)
is
begin
   l_api_name := api_name;
end;

procedure log(log_str in varchar2)
is
begin
   if (g_level_procedure >= fnd_log.g_current_runtime_level) then
      fnd_log.string( g_level_procedure, g_module||l_api_name, log_str);
   end if;
end;
-- end logging procedures
--!!!

-- clean the tables
procedure clean
is
begin
	write_ptr := 0;
	error_ptr := 0;
	rollback;
end;

-- get write pointer for success
function get_write_ptr	return binary_integer
is
begin
	return	write_ptr;
end;

-- get write pointer for errors
function get_error_ptr	return binary_integer
is
begin
	return	-error_ptr;
end;

-- get write pointer for success
procedure get_write_ptr(x_write_ptr out nocopy binary_integer)
is
begin
   x_write_ptr := write_ptr;
end;

-- get write pointer for errors
procedure get_error_ptr(x_error_ptr out nocopy binary_integer) is
begin
   x_error_ptr := -error_ptr;
end;

-- print success table (for testing - don't use in apps code)
procedure print_tab
is
begin
--	dbms_output.put_line('counter='||write_ptr);
	for i in 1..write_ptr
	loop
--		dbms_output.put_line('org_id('||i||')='||c_tab(i).org_id);
--		dbms_output.put_line('article_id('||i||')='||c_tab(i).article_id);
--		dbms_output.put_line('article_version_id('||i||')='||c_tab(i).article_version_id);
--		dbms_output.put_line('article_status('||i||')='||c_tab(i).article_status);
--		dbms_output.put_line('adoption_type('||i||')='||c_tab(i).adoption_type);
--		dbms_output.put_line('global_yn('||i||')='||c_tab(i).global_yn);
--		dbms_output.put_line('key('||i||')='||c_tab(i).key);
   null;
	end loop;
end;

-- print errors table (for testing - don't use in apps code)
procedure print_err
is
begin
--	dbms_output.put_line('counter='||-error_ptr);
	for i in 1..-error_ptr
	loop
--		dbms_output.put_line('org_id('||i||')='||c_tab(-i).org_id);
--		dbms_output.put_line('article_id('||i||')='||c_tab(-i).article_id);
--		dbms_output.put_line('article_version_id('||i||')='||c_tab(-i).article_version_id);
--		dbms_output.put_line('article_status('||i||')='||c_tab(-i).article_status);
--		dbms_output.put_line('adoption_type('||i||')='||c_tab(-i).adoption_type);
--		dbms_output.put_line('global_yn('||i||')='||c_tab(-i).global_yn);
--		dbms_output.put_line('key('||i||')='||c_tab(-i).key);
   null;
	end loop;
end;

function get_display_name(userid in varchar2)
return varchar2
is
result wf_users.display_name%type;
cursor disp_name(id in varchar2) is
   select nvl(display_name, name)
   from wf_users
   where name = nvl(id, 'WFADMIN');
begin
   open disp_name(userid);
   fetch disp_name into result;
   close disp_name;
   return result;
exception when others then
   return 'WFADMIN';
end;


procedure start_wf_after_import( p_req_id in number,
                                 p_batch_number in varchar2,
                                 p_org_id in varchar2)
is
--pragma autonomous_transaction;
-- get info from versions table after import
	cursor cv_import(c_req_id in number, c_batch_num varchar2, c_org_id number) is
		select
         	art.org_id,
		art.article_id,
   		artv.article_version_id,
   		artv.article_status,
   		artv.adoption_type,
   		artv.global_yn,
   		'AI-'||
		   to_char(art.org_id)||'.'||
   		to_char(art.article_id)||'.'||
   		to_char(artv.article_version_id)||'.'||
   		to_char(artv.object_version_number) ikey,
   		substr(nvl(art.article_number,art.article_title),0,240) ukey,
   		artv.object_version_number
		from
			okc_articles_all art,
   			okc_article_versions artv,
   			okc_art_interface_all int
		where art.article_id = artv.article_id
		and   art.standard_yn = 'Y'
		and   artv.article_status in ('PENDING_APPROVAL','APPROVED')
		and   art.article_title = int.article_title
      		and   int.process_status in ('W', 'S') 	-- this process status tells
                                             		-- that the article has been imported
      		and   int.request_id = c_req_id         -- in order to find articles imported
                                             		-- in this process only
                and   int.batch_number = c_batch_num      -- added for performance
                and   int.org_id = c_org_id               -- added for performance
                and   int.article_status in ('PENDING_APPROVAL', 'APPROVED')
      		and   artv.article_version_number = int.article_version_number;

      	save_threshold               WF_ENGINE.threshold%TYPE;
        G_UNEXPECTED_ERROR           CONSTANT   varchar2(200) := 'OKC_UNEXPECTED_ERROR';
        G_SQLERRM_TOKEN              CONSTANT   varchar2(200) := 'ERROR_MESSAGE';
        G_SQLCODE_TOKEN              CONSTANT   varchar2(200) := 'ERROR_CODE';
     	j                            NUMBER ;

begin
   clean;
   j:=1;

   save_threshold := WF_ENGINE.threshold;

   WF_ENGINE.threshold := -1;
   for cv_imp_rec in cv_import(p_req_id, p_batch_number, p_org_id)
   loop
      begin
         wf_engine.CreateProcess( 'OKCARTAP', cv_imp_rec.ikey, 'ARTICLES_AFTER_IMPORT_PROC');
         wf_engine.SetItemUserKey( 'OKCARTAP', cv_imp_rec.ikey, cv_imp_rec.ukey);
         wf_engine.SetItemOwner(	'OKCARTAP', cv_imp_rec.ikey, fnd_global.user_name);
         wf_engine.SetItemAttrNumber( 'OKCARTAP', cv_imp_rec.ikey, 'USER_ID', fnd_global.user_id);
         wf_engine.SetItemAttrNumber( 'OKCARTAP', cv_imp_rec.ikey, 'RESP_ID', fnd_global.resp_id);
         wf_engine.SetItemAttrNumber( 'OKCARTAP', cv_imp_rec.ikey, 'RESP_APPL_ID', fnd_global.resp_appl_id);
         wf_engine.SetItemAttrNumber( 'OKCARTAP', cv_imp_rec.ikey, 'ORG_ID', cv_imp_rec.org_id);
         wf_engine.SetItemAttrNumber( 'OKCARTAP', cv_imp_rec.ikey, 'ARTICLE_ID', cv_imp_rec.article_id);
         wf_engine.SetItemAttrNumber( 'OKCARTAP', cv_imp_rec.ikey, 'ARTICLE_VERSION_ID', cv_imp_rec.article_version_id);
         wf_engine.SetItemAttrText( 'OKCARTAP', cv_imp_rec.ikey, 'ARTICLE_STATUS', cv_imp_rec.article_status);
         wf_engine.SetItemAttrText( 'OKCARTAP', cv_imp_rec.ikey, 'ADOPTION_TYPE', cv_imp_rec.adoption_type);
         wf_engine.SetItemAttrText( 'OKCARTAP', cv_imp_rec.ikey, 'GLOBAL_YN', cv_imp_rec.global_yn);
         wf_engine.SetItemAttrText( 'OKCARTAP', cv_imp_rec.ikey, 'REQUESTOR', fnd_global.user_name);
         wf_engine.SetItemAttrText( 'OKCARTAP', cv_imp_rec.ikey, 'REQUESTOR_DISPLAY_NAME', get_display_name(fnd_global.user_name));
         wf_engine.StartProcess('OKCARTAP' , cv_imp_rec.ikey);

         IF j = 500 THEN
           commit;
           j:=0;
         ELSE
           j:=j+1;
         END IF;
      exception
         when others then
            c_tab(error_ptr-1).org_id := cv_imp_rec.org_id;
            c_tab(error_ptr-1).article_id := cv_imp_rec.article_id;
            c_tab(error_ptr-1).article_version_id := cv_imp_rec.article_version_id;
            c_tab(error_ptr-1).article_status := cv_imp_rec.article_status;
            c_tab(error_ptr-1).adoption_type := cv_imp_rec.adoption_type;
            c_tab(error_ptr-1).global_yn := cv_imp_rec.global_yn;
            c_tab(error_ptr-1).ikey := 'OKC_WF_AFTER_IMPORT_ERROR';
            error_ptr := error_ptr-1;
             Okc_Api.Set_Message(p_app_name     => 'OKC',
                        p_msg_name     => G_UNEXPECTED_ERROR,
                        p_token1       => G_SQLCODE_TOKEN,
                        p_token1_value => sqlcode,
                        p_token2       => G_SQLERRM_TOKEN,
                        p_token2_value => sqlerrm);
      end;
   end loop;
   commit;
   WF_ENGINE.threshold := save_threshold;
end;

-- -----------------------------------------------------------------------------
-- Function get_intent
-- reads article_id workflow attribute and returns article intent ('S' for Sell
-- or 'B' for Buy) for the given article_id
-- Input:
--    itemtype - workflow item type
--    item key - workflow item key
-- Output:
--    returns article_intent
-- -----------------------------------------------------------------------------
function get_intent(itemtype in varchar2, itemkey in varchar2) return varchar2
is
   art_id okc_articles_all.article_id%type;
   art_intent okc_articles_all.article_intent%type;
begin
   art_id := wf_engine.GetItemAttrNumber(itemtype, itemkey, 'ARTICLE_ID', false);
   select article_intent into art_intent
   from okc_articles_all
   where article_id = art_id;
   return art_intent;
exception
when others then
   return null;
end;

-- -----------------------------------------------------------------------------
-- Function get_intent
-- returns article intent ('S' for Sell or 'B' for Buy) for the given article_id
-- Input:
--    art_id - article_id
-- Output:
--    returns article_intent
-- -----------------------------------------------------------------------------
function get_intent(art_id in number) return varchar2
is
   art_intent okc_articles_all.article_intent%type;
begin
   select article_intent into art_intent
   from okc_articles_all
   where article_id = art_id;
   return art_intent;
exception
when others then
   return null;
end;

-- -----------------------------------------------------------------------------
-- Function get_intent
-- returns article intent ('S' for Sell or 'B' for Buy) for the given article_version_id
-- Input:
--    art_ver_id - article_version_id
-- Output:
--    returns article_intent
-- -----------------------------------------------------------------------------
function get_intent_pub(art_ver_id in number) return varchar2
is
   art_intent okc_articles_all.article_intent%type;
begin
   select article_intent into art_intent
   from okc_articles_all a, okc_article_versions v
   where a.article_id = v.article_id
   and v.article_version_id = art_ver_id;
   return art_intent;
exception
when others then
   return null;
end;

-- -----------------------------------------------------------------------------
-- Function get_approver
-- returns approver's username for the given organization id and article intent
-- Input:
--    org_id - organization id
--    art_intent - article intent ('S' or 'B')
-- Output:
--    returns approver's username
-- -----------------------------------------------------------------------------
function get_approver(org_id in number, art_intent in varchar2) return varchar2
is
   cursor c_approvers(p_org_id in number, p_art_intent in varchar2) is
   select decode(p_art_intent, 'S', org_information2, 'B', org_information6, 'SYSADMIN')
   from hr_organization_information
   where organization_id = p_org_id
   and org_information_context = 'OKC_TERMS_LIBRARY_DETAILS';
   result hr_organization_information.org_information2%type;
begin
   open c_approvers(org_id, art_intent);
   fetch c_approvers into result;
   close c_approvers;
   return result;
exception
   when others then
      close c_approvers;
      return null;
end;

-- check status of the version and put result into success/errors table
procedure check_status(	p_org_id in number,
			p_article_version_id in number,
			x_result out nocopy varchar2,
			x_msg_count out nocopy number,
                        x_msg_data out nocopy varchar2
)
is
pragma autonomous_transaction;
e_check_1  exception;
e_check_2  exception;
function ikey_exists(p_ikey in varchar2) return boolean
as
result varchar2(1);
begin
	select 'Y' into result FROM wf_items_v
	where item_type = 'OKCARTAP'
	and item_key = p_ikey;
	return true; -- found
exception
when others then return false; -- not found
end;
begin
--   x_result := 'NOK';
   begin
      open cv(p_org_id, p_article_version_id);
      fetch cv into c_tab(write_ptr+1);
      if cv%notfound then  raise e_check_1;
      else write_ptr := write_ptr+1;
      end if;
/*
      update okc_article_versions
      set
      article_status = 'PENDING_APPROVAL',
      object_version_number = c_tab(write_ptr).ovn,
      last_update_date = sysdate,
      last_updated_by = fnd_global.user_id
      where current of cv;
*/
      close cv;
-- to be sure that there is no such item_key in workflow
	if ikey_exists(c_tab(write_ptr).ikey) then
		write_ptr := write_ptr-1;
		raise e_check_1; -- raise exception if exists
	end if;
--
--
   if get_approver(c_tab(write_ptr).org_id, get_intent(c_tab(write_ptr).article_id)) is null then
      write_ptr := write_ptr-1;
      raise e_check_1;
   end if;
--
   OKC_ARTICLE_STATUS_CHANGE_PVT.pending_approval(
      p_api_version                =>    1.0,
      p_init_msg_list              =>    FND_API.G_TRUE,
      x_return_status              =>    x_result,
      x_msg_count                  =>    x_msg_count,
      x_msg_data                   =>    x_msg_data,
      p_current_org_id             =>    p_org_id,
      p_adopt_as_is_yn             =>    'N',
      p_article_version_id         =>    p_article_version_id,
      p_article_title              =>    c_tab(write_ptr).article_title,
      p_article_version_number     =>    c_tab(write_ptr).article_version_number
   );
   if x_result = fnd_api.G_RET_STS_UNEXP_ERROR
      or
      x_result = fnd_api.G_RET_STS_ERROR then
      raise fnd_api.G_EXC_ERROR;
   end if;
--
      x_result := fnd_api.G_RET_STS_SUCCESS;
      commit;
      return;

   exception
      when  e_check_1 then
         c_tab(error_ptr-1).org_id := p_org_id;
         c_tab(error_ptr-1).article_id := null;
         c_tab(error_ptr-1).article_version_id := p_article_version_id;
         c_tab(error_ptr-1).article_status := 'APPROVAL_ERROR';
         c_tab(error_ptr-1).adoption_type := null;
         c_tab(error_ptr-1).global_yn := null;
         c_tab(error_ptr-1).ikey := 'OKC_ARTICLE_WRONG_STATUS4APPROVAL';
         error_ptr := error_ptr-1;
         close cv;
      when  fnd_api.G_EXC_ERROR  then
         c_tab(error_ptr-1).org_id := p_org_id;
         c_tab(error_ptr-1).article_id := null;
         c_tab(error_ptr-1).article_version_id := p_article_version_id;
         c_tab(error_ptr-1).article_status := 'APPROVAL_ERROR';
         c_tab(error_ptr-1).adoption_type := null;
         c_tab(error_ptr-1).global_yn := null;
         c_tab(error_ptr-1).ikey := 'OKC_ARTICLE_STATUS_PENDING_APPROVAL';
         error_ptr := error_ptr-1;
         rollback;
      when  others then
         c_tab(error_ptr-1).org_id := p_org_id;
         c_tab(error_ptr-1).article_id := null;
         c_tab(error_ptr-1).article_version_id := p_article_version_id;
         c_tab(error_ptr-1).article_status := 'APPROVAL_ERROR';
         c_tab(error_ptr-1).adoption_type := null;
         c_tab(error_ptr-1).global_yn := null;
         c_tab(error_ptr-1).ikey := 'OKC_ARTICLE_UNEXPECTED';
         error_ptr := error_ptr-1;
         close cv;
   end;
   begin
      open ca(p_org_id, p_article_version_id);
      fetch ca into c_tab(write_ptr+1);
      if ca%notfound then  raise e_check_2;
      else write_ptr := write_ptr+1;
      end if;
/*
      update okc_article_adoptions
      set
      adoption_type = 'ADOPTED',
      adoption_status = 'PENDING_APPROVAL',
      object_version_number = c_tab(write_ptr).ovn,
      last_update_date = sysdate,
      last_updated_by = fnd_global.user_id
      where current of ca;
*/
      close ca;
-- to be sure that there is no such item_key in workflow
	if ikey_exists(c_tab(write_ptr).ikey) then
		write_ptr := write_ptr-1;
		raise e_check_2; -- raise exception if exists
	end if;
--
--
   if get_approver(c_tab(write_ptr).org_id, get_intent(c_tab(write_ptr).article_id)) is null then
      write_ptr := write_ptr-1;
      raise e_check_2;
   end if;
--
   OKC_ARTICLE_STATUS_CHANGE_PVT.pending_approval(
      p_api_version                =>    1.0,
      p_init_msg_list              =>    FND_API.G_TRUE,
      x_return_status              =>    x_result,
      x_msg_count                  =>    x_msg_count,
      x_msg_data                   =>    x_msg_data,
      p_current_org_id             =>    p_org_id,
      p_adopt_as_is_yn             =>    'Y',
      p_article_version_id         =>    p_article_version_id,
      p_article_title              =>    c_tab(write_ptr).article_title,
      p_article_version_number     =>    c_tab(write_ptr).article_version_number
   );
   if x_result = fnd_api.G_RET_STS_UNEXP_ERROR
      or
      x_result = fnd_api.G_RET_STS_ERROR then
      raise fnd_api.G_EXC_ERROR;
   end if;
--
      x_result := fnd_api.G_RET_STS_SUCCESS;
      commit;
      return;

   exception
      when e_check_2 then
         c_tab(error_ptr-1).org_id := p_org_id;
         c_tab(error_ptr-1).article_id := null;
         c_tab(error_ptr-1).article_version_id := p_article_version_id;
         c_tab(error_ptr-1).article_status := 'ADOPTION_ERROR';
         c_tab(error_ptr-1).adoption_type := null;
         c_tab(error_ptr-1).global_yn := null;
         c_tab(error_ptr-1).ikey := 'OKC_ARTICLE_WRONG_STATUS4ADOPTION';
         error_ptr := error_ptr-1;
         close ca;
         x_result := fnd_api.G_RET_STS_ERROR;
      when fnd_api.G_EXC_ERROR then
         c_tab(error_ptr-1).org_id := p_org_id;
         c_tab(error_ptr-1).article_id := null;
         c_tab(error_ptr-1).article_version_id := p_article_version_id;
         c_tab(error_ptr-1).article_status := 'ADOPTION_ERROR';
         c_tab(error_ptr-1).adoption_type := null;
         c_tab(error_ptr-1).global_yn := null;
         c_tab(error_ptr-1).ikey := 'OKC_ARTICLE_STATUS_PENDING_APPROVAL';
         error_ptr := error_ptr-1;
         rollback;
      when others then
         c_tab(error_ptr-1).org_id := p_org_id;
         c_tab(error_ptr-1).article_id := null;
         c_tab(error_ptr-1).article_version_id := p_article_version_id;
         c_tab(error_ptr-1).article_status := 'ADOPTION_ERROR';
         c_tab(error_ptr-1).adoption_type := null;
         c_tab(error_ptr-1).global_yn := null;
         c_tab(error_ptr-1).ikey := 'OKC_ARTICLE_UNEXPECTED_ERROR';
         error_ptr := error_ptr-1;
         close ca;
         x_result := fnd_api.G_RET_STS_ERROR;
   end;
end;

-- check the version and print result (for testing - don't use in apps code)
procedure test(   p_org_id in number,
                  p_article_version_id in number)
is
x_result varchar(1);
x_msg_count number;
x_msg_data varchar2(2000);
begin
   check_status(p_org_id, p_article_version_id, x_result, x_msg_count, x_msg_data);
--   dbms_output.put_line('result='||x_result);
   rollback;
end;

-- get record (p_ptr) from success table
procedure get_tab(   p_ptr in                         binary_integer,
		               x_article_id out nocopy          okc_articles_all.article_id%type,
   	               x_article_version_id out nocopy  okc_article_versions.article_version_id%type,
   	               x_article_status out nocopy      okc_article_versions.article_status%type,
   	               x_adoption_type out nocopy       okc_article_versions.adoption_type%type,
   	               x_global_yn out nocopy           okc_article_versions.global_yn%type,
   	               x_key out nocopy                 varchar2)
is
begin
   if write_ptr > 0 then
      if p_ptr > 0 and p_ptr <= write_ptr then
         x_article_id         := c_tab(p_ptr).article_id;
   	   x_article_version_id := c_tab(p_ptr).article_version_id;
   	   x_article_status     := c_tab(p_ptr).article_status;
   	   x_adoption_type      := c_tab(p_ptr).adoption_type;
   	   x_global_yn          := c_tab(p_ptr).global_yn;
   	   x_key                := c_tab(p_ptr).ikey;
   	   return;
      end if;
   end if;
   x_article_id         := null;
   x_article_version_id := null;
end;

-- get record (p_ptr) from errors table
procedure get_err(   p_ptr in                         binary_integer,
		               x_article_id out nocopy          okc_articles_all.article_id%type,
   	               x_article_version_id out nocopy  okc_article_versions.article_version_id%type,
   	               x_article_status out nocopy      okc_article_versions.article_status%type,
   	               x_adoption_type out nocopy       okc_article_versions.adoption_type%type,
   	               x_global_yn out nocopy           okc_article_versions.global_yn%type,
   	               x_key out nocopy                 varchar2)
is
begin
   if error_ptr < 0 then
      if p_ptr > 0 and p_ptr <= -error_ptr then
         x_article_id         := c_tab(-p_ptr).article_id;
   	   x_article_version_id := c_tab(-p_ptr).article_version_id;
   	   x_article_status     := c_tab(-p_ptr).article_status;
   	   x_adoption_type      := c_tab(-p_ptr).adoption_type;
   	   x_global_yn          := c_tab(-p_ptr).global_yn;
   	   x_key                := c_tab(-p_ptr).ikey;
   	   return;
      end if;
   end if;
   x_article_id         := null;
   x_article_version_id := null;
end;

-- -----------------------------------------------------------------------------
-- Procedure set_notified_list
-- builds list of notified usernames (administrators) for sending notifications
-- about articles autoadoption or availability for adoption
-- Input:
--    itemtype - workflow item type
--    itemkey - workflow item key
--    actid - workflow action id
--    funcmode - workflow function mode
-- Output:
--    resultout - workflow result
--    list of usernames to notify
-- -----------------------------------------------------------------------------
procedure set_notified_list(  itemtype in varchar2,
                              itemkey in varchar2,
                              actid in number,
                              funcmode in varchar2,
                              resultout out nocopy varchar2)
is
artv_id number;

cursor c_notified(p_artv_id in number, p_art_intent in varchar2) is
select
   adoption_type,
   hr.organization_id,
   decode(p_art_intent, 'S', org_information3, 'B', org_information7,
   'SYSADMIN') notified
from
   okc_article_adoptions arta,
   hr_organization_information hri,
   hr_organization_units hr
where
   global_article_version_id = p_artv_id
and
   hri.organization_id = local_org_id
and
   hr.organization_id = local_org_id
and
   org_information_context = 'OKC_TERMS_LIBRARY_DETAILS';

operation Wf_Engine.NameTabTyp;
operation_list Wf_Engine.TextTabTyp;
organization Wf_Engine.NameTabTyp;
organization_list Wf_Engine.NumTabTyp;
notified Wf_Engine.NameTabTyp;
notified_list Wf_Engine.TextTabTyp;

art_intent varchar2(1);
counter number;
begin
   counter := 0;
   art_intent := get_intent(itemtype, itemkey);
   artv_id := wf_engine.getItemAttrNumber(itemtype, itemkey, 'ARTICLE_VERSION_ID', false);
   if ( funcmode = 'RUN' ) then
      for c_rec in c_notified(artv_id, art_intent)
      loop
         counter := counter+1;
         operation(counter):=          'OPERATION_LIST$'||counter;
         operation_list(counter):=     c_rec.adoption_type;
         organization(counter):=       'ORGANIZATION_LIST$'||counter;
         organization_list(counter):=  c_rec.organization_id;
         notified(counter):=           'NOTIFIED_LIST$'||counter;
         notified_list(counter):=      c_rec.notified;
      end loop;
      wf_engine.AddItemAttrTextArray( itemtype, itemkey, operation, operation_list);
      wf_engine.AddItemAttrNumberArray( itemtype, itemkey, organization, organization_list);
      wf_engine.AddItemAttrTextArray( itemtype, itemkey, notified, notified_list);
      wf_engine.AddItemAttr(itemtype, itemkey, 'COUNTER$', null, counter, null);
      resultout := 'COMPLETE';
      return;
   end if;
exception
   when others then
      WF_CORE.CONTEXT ( 'OKC_ARTWF_PVT', 'set_notified_list', itemtype,
                        itemkey, to_char(actid), funcmode);
      raise;
end;

--
-- decrement counter
-- called from wf - decrements COUNTER$
--
procedure decrement_counter(  itemtype in varchar2,
                              itemkey in varchar2,
                              actid in number,
                              funcmode in varchar2,
                              resultout out nocopy varchar2)
is
counter number;
begin
   counter := wf_engine.getItemAttrNumber(itemtype, itemkey, 'COUNTER$', false) - 1;
   if counter > 0 then
      wf_engine.setItemAttrNumber(itemtype, itemkey, 'COUNTER$', counter);
      resultout := 'COMPLETE:T';
   else
      resultout := 'COMPLETE:F';
   end if;
   return;
exception
   when others then
      WF_CORE.CONTEXT ( 'OKC_ARTWF_PVT', 'decrement_counter', itemtype,
                        itemkey, to_char(actid), funcmode);
      raise;
end;

--
-- set notified's username
-- called from wf - sets notified's username to NOTIFIED$
--
procedure set_notified( itemtype in varchar2,
                        itemkey in varchar2,
                        actid in number,
                        funcmode in varchar2,
                        resultout out nocopy varchar2)
is
operation okc_article_adoptions.adoption_type%type;
organization hr_organization_units_v.organization_id%type;
notified hr_organization_information.org_information3%type;
counter number;

--Fix for 6237128.Set null for notified when user is end-dated

CURSOR c_usr (notified_usr in hr_organization_information.org_information3%TYPE) IS
SELECT user_name
FROM fnd_user
WHERE user_name = notified_usr
 AND nvl(end_date,   sysdate + 1) > sysdate;
valid_notified FND_USER.user_name%TYPE;
--end of fix

begin
   counter := wf_engine.getItemAttrNumber(itemtype, itemkey, 'COUNTER$', false);
   if counter > 0 then
      operation := wf_engine.getItemAttrText(itemtype, itemkey, 'OPERATION_LIST$'||counter, false);
      organization := wf_engine.getItemAttrNumber(itemtype, itemkey, 'ORGANIZATION_LIST$'||counter, false);
      notified := wf_engine.getItemAttrText(itemtype, itemkey, 'NOTIFIED_LIST$'||counter, false);
      wf_engine.setItemAttrText(itemtype, itemkey, 'OPERATION$', operation);
      wf_engine.setItemAttrNumber(itemtype, itemkey, 'ORGANIZATION$', organization);

--Fix for 6237128.
         valid_notified := NULL;
         OPEN c_usr(notified);
         FETCH c_usr INTO valid_notified;
         IF c_usr%NOTFOUND THEN
           notified := NULL;
         END IF;
         CLOSE c_usr;
--end of fix

      wf_engine.setItemAttrText(itemtype, itemkey, 'NOTIFIED$', notified);
-- bug 3185684
      fnd_message.set_name('OKC', 'OKC_ART_UNDEFINED_ADMIN');
      fnd_message.set_token('ORGNAME', organization);
      wf_engine.setItemAttrText(itemtype, itemkey, 'WARNING', fnd_message.get);
      wf_engine.setItemAttrText(itemtype, itemkey, 'WF_ADMINISTRATOR', 'SYSADMIN');

      resultout := 'COMPLETE:'||operation;
   else
      resultout := 'COMPLETE:UNDEFINED';
   end if;
   return;
exception
   when others then
      WF_CORE.CONTEXT ( 'OKC_ARTWF_PVT', 'set_notified', itemtype,
                        itemkey, to_char(actid), funcmode);
      raise;
end;

-- -----------------------------------------------------------------------------
-- Procedure set_approver
-- sets approver's username for sending approval request
-- Input:
--    itemtype - workflow item type
--    itemkey - workflow item key
--    actid - workflow action id
--    funcmode - workflow function mode
-- Output:
--    resultout - workflow result
--    populates workflow attribute approver
-- -----------------------------------------------------------------------------
procedure set_approver( itemtype in varchar2,
                        itemkey in varchar2,
                        actid in number,
                        funcmode in varchar2,
                        resultout out nocopy varchar2)
is
org_id number;
art_intent varchar2(1);
approver_role wf_users.name%type;
approver_name wf_users.display_name%type;
begin

   org_id := wf_engine.getItemAttrNumber(itemtype, itemkey, 'ORG_ID', false);
   if ( funcmode = 'RUN' ) then
      art_intent := get_intent(itemtype, itemkey);
      approver_role := get_approver(org_id, art_intent);
      begin
         select nvl(display_name, name) into approver_name
         from wf_users where name = approver_role;
      exception
      when others then
         approver_name := null;
      end;
      wf_engine.SetItemAttrText( itemtype, itemkey, 'APPROVER_ROLE', approver_role);
      wf_engine.SetItemAttrText( itemtype, itemkey, 'APPROVER_DISPLAY_NAME', approver_name);
      resultout := 'COMPLETE';
      return;
   end if;
exception
   when others then
      WF_CORE.CONTEXT ('OKC_ARTWF_PVT', 'set_approver', itemtype,
                            itemkey, to_char(actid), funcmode);
      raise;
end;

function get_org_name(p_org_id in number) return varchar2;
-- set notification attributes
procedure set_notification(   itemtype in varchar2,
                              itemkey in varchar2,
                              actid in number,
                              funcmode in varchar2,
                              resultout out nocopy varchar2)
is
   message_code fnd_new_messages.message_name%type;
   org_id okc_articles_all.org_id%type;
   article_id okc_articles_all.article_id%type;
   article_version_id okc_article_versions.article_version_id%type;

   cursor c_approve(cp_org_id in number, cp_art_ver_id in number) is
   select
      art.article_title,
      art.article_number,
      artv.article_version_number,
      artv.article_description,
      tm.meaning type_meaning,
      im.meaning intent_meaning,
      gm.meaning global_meaning,
      pm.meaning provision_meaning,
      artv.start_date,
      artv.end_date
   from
      okc_articles_all art,
      okc_article_versions artv,
      okc_lookups_v tm,
      okc_lookups_v im,
      okc_lookups_v gm,
      okc_lookups_v pm
   where art.standard_yn = 'Y'
   and art.org_id = cp_org_id
   and article_version_id = cp_art_ver_id
   and art.article_id = artv.article_id
   and tm.lookup_type ='OKC_SUBJECT'
   and im.lookup_type ='OKC_ARTICLE_INTENT'
   and gm.lookup_type ='OKC_YN'
   and pm.lookup_type ='OKC_YN'
   and tm.lookup_code = art.article_type
   and im.lookup_code = art.article_intent
   and gm.lookup_code = artv.global_yn
   and pm.lookup_code = artv.provision_yn;

   cursor c_adopt(cp_org_id in number, cp_art_ver_id in number) is
   select
      art.article_title,
      art.article_number,
      artv.article_version_number,
      artv.article_description,
      tm.meaning type_meaning,
      im.meaning intent_meaning,
      gm.meaning global_meaning,
      pm.meaning provision_meaning,
      artv.start_date,
      artv.end_date
   from
      okc_articles_all art,
      okc_article_versions artv,
      okc_article_adoptions arta,
      okc_lookups_v tm,
      okc_lookups_v im,
      okc_lookups_v gm,
      okc_lookups_v pm
   where art.standard_yn = 'Y'
   and artv.global_yn = 'Y'
   and arta.local_org_id = cp_org_id
   and article_version_id = cp_art_ver_id
   and art.article_id = artv.article_id
   and artv.article_version_id = arta.global_article_version_id
   and tm.lookup_type ='OKC_SUBJECT'
   and im.lookup_type ='OKC_ARTICLE_INTENT'
   and gm.lookup_type ='OKC_YN'
   and pm.lookup_type ='OKC_YN'
   and tm.lookup_code = art.article_type
   and im.lookup_code = art.article_intent
   and gm.lookup_code = artv.global_yn
   and pm.lookup_code = artv.provision_yn;

   approver_name wf_users.display_name%type;

begin
   if ( funcmode = 'RUN' ) then
      message_code := wf_engine.GetActivityAttrText(itemtype, itemkey, actid, 'MESSAGE_CODE', false);
      org_id := wf_engine.GetItemAttrNumber(itemtype, itemkey, 'ORG_ID', false);
      article_id := wf_engine.GetItemAttrNumber(itemtype, itemkey, 'ARTICLE_ID', false);
      article_version_id := wf_engine.GetItemAttrNumber(itemtype, itemkey, 'ARTICLE_VERSION_ID', false);
      wf_engine.SetItemAttrText(itemtype, itemkey, 'SUBJECT', message_code);
      wf_engine.SetItemAttrText(itemtype, itemkey, 'ORGANIZATION_NAME', get_org_name(org_id));

      if message_code in (
         'OKC_ART_ADOPTION_NTF_SUBJECT',
         'OKC_ART_ADOPTION_NTF_SUBJECT_A',
         'OKC_ART_ADOPTION_NTF_SUBJECT_R'
      )  then
         wf_engine.SetItemAttrText(itemtype, itemkey, 'FWK_FUNCTION_NAME', 'OKC_ART_ADOPTION_NTF_DETAILS');
         for c_adopt_rec in c_adopt(org_id, article_version_id)
         loop
            wf_engine.SetItemAttrText(itemtype, itemkey, 'ARTICLE_TITLE', c_adopt_rec.article_title);
            wf_engine.SetItemAttrText(itemtype, itemkey, 'ARTICLE_NUMBER', c_adopt_rec.article_number);
            wf_engine.SetItemAttrNumber(itemtype, itemkey, 'ARTICLE_VERSION_NUMBER', c_adopt_rec.article_version_number);
            wf_engine.SetItemAttrText(itemtype, itemkey, 'ARTICLE_DESCRIPTION', c_adopt_rec.article_description);
            wf_engine.SetItemAttrText(itemtype, itemkey, 'ARTICLE_TYPE', c_adopt_rec.type_meaning);
            wf_engine.SetItemAttrText(itemtype, itemkey, 'ARTICLE_INTENT', c_adopt_rec.intent_meaning);
            wf_engine.SetItemAttrText(itemtype, itemkey, 'ARTICLE_GLOBAL_YN', c_adopt_rec.global_meaning);
            wf_engine.SetItemAttrText(itemtype, itemkey, 'ARTICLE_PROVISION_YN', c_adopt_rec.provision_meaning);
            wf_engine.SetItemAttrDate(itemtype, itemkey, 'ARTICLE_START_DATE', c_adopt_rec.start_date);
            wf_engine.SetItemAttrDate(itemtype, itemkey, 'ARTICLE_END_DATE', c_adopt_rec.end_date);
         end loop;
         resultout := 'COMPLETE';

      elsif message_code in (
         'OKC_ART_APPROVAL_NTF_SUBJECT',
         'OKC_ART_APPROVAL_NTF_SUBJECT_A',
         'OKC_ART_APPROVAL_NTF_SUBJECT_R'
      )  then
         wf_engine.SetItemAttrText(itemtype, itemkey, 'FWK_FUNCTION_NAME', 'OKC_ART_APPROVAL_NTF_DETAILS');
         for c_approve_rec in c_approve(org_id, article_version_id)
         loop
            wf_engine.SetItemAttrText(itemtype, itemkey, 'ARTICLE_TITLE', c_approve_rec.article_title);
            wf_engine.SetItemAttrText(itemtype, itemkey, 'ARTICLE_NUMBER', c_approve_rec.article_number);
            wf_engine.SetItemAttrNumber(itemtype, itemkey, 'ARTICLE_VERSION_NUMBER', c_approve_rec.article_version_number);
            wf_engine.SetItemAttrText(itemtype, itemkey, 'ARTICLE_DESCRIPTION', c_approve_rec.article_description);
            wf_engine.SetItemAttrText(itemtype, itemkey, 'ARTICLE_TYPE', c_approve_rec.type_meaning);
            wf_engine.SetItemAttrText(itemtype, itemkey, 'ARTICLE_INTENT', c_approve_rec.intent_meaning);
            wf_engine.SetItemAttrText(itemtype, itemkey, 'ARTICLE_GLOBAL_YN', c_approve_rec.global_meaning);
            wf_engine.SetItemAttrText(itemtype, itemkey, 'ARTICLE_PROVISION_YN', c_approve_rec.provision_meaning);
            wf_engine.SetItemAttrDate(itemtype, itemkey, 'ARTICLE_START_DATE', c_approve_rec.start_date);
            wf_engine.SetItemAttrDate(itemtype, itemkey, 'ARTICLE_END_DATE', c_approve_rec.end_date);
         end loop;
         resultout := 'COMPLETE';
      elsif message_code in (
         'OKC_ART_ADOPTED_NTF_SUBJECT',
         'OKC_ART_AVAILABLE_NTF_SUBJECT'
      )  then
         wf_engine.SetItemAttrText(itemtype, itemkey, 'FWK_FUNCTION_NAME', 'OKC_ART_APPROVAL_NTF_DETAILS');
         for c_approve_rec in c_approve(org_id, article_version_id)
         loop
            wf_engine.SetItemAttrText(itemtype, itemkey, 'ARTICLE_TITLE', c_approve_rec.article_title);
            wf_engine.SetItemAttrText(itemtype, itemkey, 'ARTICLE_NUMBER', c_approve_rec.article_number);
            wf_engine.SetItemAttrNumber(itemtype, itemkey, 'ARTICLE_VERSION_NUMBER', c_approve_rec.article_version_number);
            wf_engine.SetItemAttrText(itemtype, itemkey, 'ARTICLE_DESCRIPTION', c_approve_rec.article_description);
            wf_engine.SetItemAttrText(itemtype, itemkey, 'ARTICLE_TYPE', c_approve_rec.type_meaning);
            wf_engine.SetItemAttrText(itemtype, itemkey, 'ARTICLE_INTENT', c_approve_rec.intent_meaning);
            wf_engine.SetItemAttrText(itemtype, itemkey, 'ARTICLE_GLOBAL_YN', c_approve_rec.global_meaning);
            wf_engine.SetItemAttrText(itemtype, itemkey, 'ARTICLE_PROVISION_YN', c_approve_rec.provision_meaning);
            wf_engine.SetItemAttrDate(itemtype, itemkey, 'ARTICLE_START_DATE', c_approve_rec.start_date);
            wf_engine.SetItemAttrDate(itemtype, itemkey, 'ARTICLE_END_DATE', c_approve_rec.end_date);
         end loop;
         resultout := 'COMPLETE';
      end if;
      return;
   end if;
exception
   when others then
   WF_CORE.CONTEXT ('OKC_ARTWF_PVT', 'set_notification', itemtype,
                     itemkey, to_char(actid), funcmode);
   raise;
end;

function get_pending_meaning return varchar2
is
   cursor c_pmeaning is
   select meaning from okc_lookups_v
   where lookup_type = 'OKC_ARTICLE_STATUS'
   and lookup_code = 'PENDING_APPROVAL';
   meaning okc_lookups_v.meaning%type;
begin
   open c_pmeaning;
   fetch c_pmeaning into meaning;
   close c_pmeaning;
   return meaning;
exception
   when others then
      close c_pmeaning;
      return null;
end;

function get_adopted_meaning return varchar2
is
   cursor c_ameaning is
   select meaning from okc_lookups_v
   where lookup_type = 'OKC_ARTICLE_ADOPTION_TYPE'
   and lookup_code = 'ADOPTED';
   meaning okc_lookups_v.meaning%type;
begin
   open c_ameaning;
   fetch c_ameaning into meaning;
   close c_ameaning;
   return meaning;
exception
   when others then
      close c_ameaning;
      return null;
end;

procedure selector(  itemtype in varchar2,
                     itemkey in varchar2,
                     actid in number,
                     command in varchar2,
                     resultout in out nocopy varchar2)
is
   l_current_org_id number;
   l_current_user_id number;
   l_current_resp_id number;
   l_current_resp_appl_id number;

   org_id number;
   user_id number;
   resp_id number;
   resp_appl_id number;

begin
    org_id := wf_engine.GetItemAttrNumber(itemtype, itemkey, 'ORG_ID', true);
-- get current apps context params
    l_current_user_id       := TO_NUMBER(FND_PROFILE.VALUE('USER_ID'));
    l_current_resp_id       := TO_NUMBER(FND_PROFILE.VALUE('RESP_ID'));
    l_current_resp_appl_id  := TO_NUMBER(FND_PROFILE.VALUE('RESP_APPL_ID'));
-- get apps context params saved in wf
    user_id := wf_engine.GetItemAttrNumber(itemtype, itemkey, 'USER_ID', true);
    resp_id := wf_engine.GetItemAttrNumber(itemtype, itemkey, 'RESP_ID', true);
    resp_appl_id := wf_engine.GetItemAttrNumber(itemtype, itemkey, 'RESP_APPL_ID', true);
-- set apps context if needed
    if ( command = 'SET_CTX' ) then
        fnd_global.apps_initialize(user_id, resp_id, resp_appl_id);
        mo_global.set_policy_context('S', org_id);
        resultout := 'COMPLETE'; -- context is set up
        return;
    end if;
-- check current apps context
    if ( command = 'TEST_CTX' ) then
        if  (nvl(mo_global.get_access_mode, 'NULL') <> 'S') or
            (nvl(mo_global.get_current_org_id, -99) <> org_id)  then
            resultout := 'FALSE';   -- org part of context is wrong - reset context
            return;
        end if;
        if  (l_current_user_id <> user_id) or
            (l_current_resp_id <> resp_id) or
            (l_current_resp_appl_id <> resp_appl_id)    then
            resultout := 'FALSE';   -- apps params part of context is wrong - reset context
            return;
        end if;
        resultout := 'TRUE';  -- apps context is allright - do not touch it
        return;
    end if;
exception
    when others then
    WF_CORE.CONTEXT ('OKC_ARTWF_PVT', 'selector', itemtype,
                     itemkey, to_char(actid), command);
    raise;
end;

procedure select_process(   itemtype in varchar2,
                           itemkey in varchar2,
                           actid in number,
                           command in varchar2,
                           resultout in out nocopy varchar2)
is
   adoption_type okc_article_adoptions.adoption_type%type;
   global_yn okc_article_versions.global_yn%type;
   user_id number;
   resp_id number;
   resp_appl_id number;
begin
   user_id := null;
   resp_id := null;
   resp_appl_id := null;
   if ( command = 'RUN' ) then
      adoption_type := wf_engine.GetItemAttrText(itemtype, itemkey, 'ADOPTION_TYPE', false);
   	global_yn := wf_engine.GetItemAttrText(itemtype, itemkey, 'GLOBAL_YN', false);
      if adoption_type in ('AVAILABLE', 'ADOPTED') then
         resultout := 'ARTICLES_ADOPTION_PROC'; -- start articles adoption process
      else
         if global_yn = 'Y' then
            resultout := 'GLOBAL_ARTICLES_APPROVAL_PROC'; -- start global articles approval
         elsif global_yn = 'N' then
            resultout := 'LOCAL_ARTICLES_APPROVAL_PROC'; -- start local articles approval
         end if;
      end if;
      return;
   end if;
exception
   when others then
   WF_CORE.CONTEXT ('OKC_ARTWF_PVT', 'select_process', itemtype,
                     itemkey, to_char(actid), command);
   raise;
end;

--
-- sets status to APPROVED
--
procedure set_approved( itemtype in varchar2,
                        itemkey in varchar2,
                        actid in number,
                        funcmode in varchar2,
                        resultout out nocopy varchar2)
is
--pragma autonomous_transaction;
   article_version_id okc_article_versions.article_version_id%type;
   adoption_flag varchar2(1);
   l_return_status varchar2(1);
   msg_count number;
   msg_data varchar2(250);
   change_status_x exception;
   org_id number;
begin
   if ( funcmode = 'RUN' ) then
      article_version_id :=
         wf_engine.getItemAttrNumber(itemtype, itemkey, 'ARTICLE_VERSION_ID', false);
      org_id :=
         wf_engine.getItemAttrNumber(itemtype, itemkey, 'ORG_ID', false);
      adoption_flag :=
         wf_engine.getItemAttrText(itemtype, itemkey, 'ADOPTION_YN', false);
      OKC_ARTICLE_STATUS_CHANGE_PVT.approve(null,null,
         l_return_status, msg_count, msg_data, org_id, adoption_flag, article_version_id);
      resultout := 'COMPLETE';
      If l_return_status <> 'S' THEN
         resultout := 'ERROR';
         raise change_status_x;
      end if;
      return;
   end if;
exception
   when change_status_x then
      WF_CORE.CONTEXT('OKC_ARTICLE_STATUS_CHANGE_PVT', 'approve', itemtype,
                        itemkey, to_char(actid), funcmode);
      raise;
   when others then
      WF_CORE.CONTEXT ( 'OKC_ARTWF_PVT', 'set_approved', itemtype,
                        itemkey, to_char(actid), funcmode);
      raise;
end;

--
-- sets status to REJECTED
--
procedure set_rejected( itemtype in varchar2,
                        itemkey in varchar2,
                        actid in number,
                        funcmode in varchar2,
                        resultout out nocopy varchar2)
is
--pragma autonomous_transaction;
   article_version_id okc_article_versions.article_version_id%type;
   adoption_flag varchar2(1);
   l_return_status varchar2(1);
   msg_count number;
   msg_data varchar2(250);
   change_status_x exception;
   org_id number;
begin
   if ( funcmode = 'RUN' ) then
      article_version_id :=
         wf_engine.getItemAttrNumber(itemtype, itemkey, 'ARTICLE_VERSION_ID', false);
      org_id :=
         wf_engine.getItemAttrNumber(itemtype, itemkey, 'ORG_ID', false);
      adoption_flag :=
         wf_engine.getItemAttrText(itemtype, itemkey, 'ADOPTION_YN', false);
      OKC_ARTICLE_STATUS_CHANGE_PVT.reject(null,null,
         l_return_status, msg_count, msg_data, org_id, adoption_flag, article_version_id);
      resultout := 'COMPLETE';
      If l_return_status <> 'S' THEN
         resultout := 'ERROR';
         raise change_status_x;
      end if;
      return;
   end if;
exception
   when change_status_x then
      WF_CORE.CONTEXT('OKC_ARTICLE_STATUS_CHANGE_PVT', 'reject', itemtype,
                        itemkey, to_char(actid), funcmode);
      raise;
   when others then
      WF_CORE.CONTEXT ( 'OKC_ARTWF_PVT', 'set_rejected', itemtype,
                        itemkey, to_char(actid), funcmode);
      raise;
end;

-- somehow fnd_global.user_name doesn't work !!!
function user_name return varchar2
is
   cursor c_usr is
   select user_name
   from fnd_user_view
   where user_id = fnd_global.user_id;
   user_name fnd_user_view.user_name%type;
begin
   user_name := null;
   open c_usr;
   fetch c_usr into user_name;
   close c_usr;
   return user_name;
exception
   when others then
      close c_usr;
      user_name := 'UNDEFINED';
      return user_name;
end;

procedure start_wf_processes(result out nocopy varchar2)
is
pragma autonomous_transaction;
user_id number;
resp_id number;
resp_appl_id number;
begin
-- get current apps context params
user_id := fnd_global.user_id;
resp_id := fnd_global.resp_id;
resp_appl_id := fnd_global.resp_appl_id;

   result := 'OK';
	for i in 1..write_ptr
	loop
      begin
         wf_engine.CreateProcess( 'OKCARTAP', c_tab(i).ikey, 'ARTICLES_APPROVAL_ROOT_PROC');
         wf_engine.SetItemUserKey( 'OKCARTAP', c_tab(i).ikey, c_tab(i).ukey);
         wf_engine.SetItemOwner(	'OKCARTAP', c_tab(i).ikey, fnd_global.user_name);
         wf_engine.SetItemAttrNumber( 'OKCARTAP', c_tab(i).ikey, 'USER_ID', user_id);
         wf_engine.SetItemAttrNumber( 'OKCARTAP', c_tab(i).ikey, 'RESP_ID', resp_id);
         wf_engine.SetItemAttrNumber( 'OKCARTAP', c_tab(i).ikey, 'RESP_APPL_ID', resp_appl_id);
         wf_engine.SetItemAttrNumber( 'OKCARTAP', c_tab(i).ikey, 'ORG_ID', c_tab(i).org_id);
         wf_engine.SetItemAttrNumber( 'OKCARTAP', c_tab(i).ikey, 'ARTICLE_ID', c_tab(i).article_id);
         wf_engine.SetItemAttrNumber( 'OKCARTAP', c_tab(i).ikey, 'ARTICLE_VERSION_ID', c_tab(i).article_version_id);
         wf_engine.SetItemAttrText( 'OKCARTAP', c_tab(i).ikey, 'ARTICLE_STATUS', c_tab(i).article_status);
         wf_engine.SetItemAttrText( 'OKCARTAP', c_tab(i).ikey, 'ADOPTION_TYPE', c_tab(i).adoption_type);
         wf_engine.SetItemAttrText( 'OKCARTAP', c_tab(i).ikey, 'GLOBAL_YN', c_tab(i).global_yn);
         wf_engine.SetItemAttrText( 'OKCARTAP', c_tab(i).ikey, 'REQUESTOR', fnd_global.user_name);
         wf_engine.SetItemAttrText( 'OKCARTAP', c_tab(i).ikey, 'REQUESTOR_DISPLAY_NAME', get_display_name(fnd_global.user_name));
         wf_engine.StartProcess('OKCARTAP' , c_tab(i).ikey);
         commit;
      exception
         when others then
            result := 'NOK';
            rollback;
      end;
	end loop;
end;

procedure start_wf_process(org_id in number, article_version_id in number, result out nocopy varchar2)
is
    check_result varchar2(3);
    wf_result varchar2(3);
    x_result varchar(1);
    x_msg_count number;
    x_msg_data varchar2(2000);
begin
   check_result := 'NOK';
   wf_result := 'NOK';
   fnd_msg_pub.initialize;
   clean;
   check_status(org_id, article_version_id, x_result, x_msg_count, x_msg_data);
   if x_result = fnd_api.G_RET_STS_SUCCESS   then
      start_wf_processes(wf_result);
   end if;
   result := wf_result;
exception
   when others then
      result := 'NOK';
end;

function validate_article_version(  p_search_flow in varchar2,
                                    p_article_version_id in number,
                                    p_article_status in varchar2,
                                    p_org_id in number)
return varchar2
is
result varchar2(1);
begin
if upper(p_search_flow) = 'LOCAL' then
   if upper(p_article_status) = 'IGNORE' then
/*  bug 5008542
      select 'Y' into result
      from okc_articles_local_v
      where org_id = p_org_id
      and article_version_id = p_article_version_id;
*/
select 'Y' into result
from (
   select 'Y'
   from
      okc_articles_all art,
      okc_article_versions artv
   where art.standard_yn = 'Y'
      and art.article_id = artv.article_id
      and artv.article_version_id = p_article_version_id
      and art.org_id = p_org_id
   union all
   select 'Y'
   from
      okc_articles_all art,
      okc_article_versions artv,
      okc_article_adoptions arta
   where art.standard_yn = 'Y'
      and artv.global_yn = 'Y'
      and art.article_id = artv.article_id
      and artv.article_version_id = arta.global_article_version_id
      and artv.article_version_id = p_article_version_id
      and arta.local_org_id = p_org_id
      and arta.local_article_version_id is null
)
where rownum <= 1;
   else
      if p_article_status is null then
/*  bug 5008542
         select 'Y' into result
         from okc_articles_local_v
         where org_id = p_org_id
         and article_version_id = p_article_version_id
         and article_status is null;
*/
select 'Y' into result
from (
   select
   decode(artv.article_status, 'APPROVED', decode(greatest(nvl(trunc(end_date),
   trunc(sysdate))+1, trunc(sysdate)), trunc(sysdate), 'EXPIRED', artv.article_status),
   artv.article_status) article_status
   from
      okc_articles_all art,
      okc_article_versions artv
   where art.standard_yn = 'Y'
      and art.article_id = artv.article_id
      and artv.article_version_id = p_article_version_id
      and art.org_id = p_org_id
   union all
   select
   decode(arta.adoption_type, 'AVAILABLE', decode( decode(greatest(nvl(trunc(end_date),
   trunc(sysdate))+1, trunc(sysdate)), trunc(sysdate), 'EXPIRED', artv.article_status),
   'APPROVED', arta.adoption_status, 'EXPIRED', 'EXPIRED', 'ON_HOLD', 'ON_HOLD', 'REJECTED',
   'REJECTED' ), 'ADOPTED', decode( decode(arta.adoption_status, 'PENDING_APPROVAL', 'PENDING_APPROVAL',
   decode(greatest(nvl(trunc(end_date), trunc(sysdate))+1, trunc(sysdate)), trunc(sysdate), 'EXPIRED',
   artv.article_status) ), 'APPROVED', arta.adoption_status, 'EXPIRED', 'EXPIRED', 'ON_HOLD', 'ON_HOLD',
   'PENDING_APPROVAL', 'PENDING_APPROVAL' ) ) article_status
   from
      okc_articles_all art,
      okc_article_versions artv,
      okc_article_adoptions arta
   where art.standard_yn = 'Y'
      and artv.global_yn = 'Y'
      and art.article_id = artv.article_id
      and artv.article_version_id = arta.global_article_version_id
      and artv.article_version_id = p_article_version_id
      and arta.local_org_id = p_org_id
      and arta.local_article_version_id is null
) a
where rownum <= 1
and article_status is null;
      else
/*  bug 5008542
         select 'Y' into result
         from okc_articles_local_v
         where org_id = p_org_id
         and article_version_id = p_article_version_id
         and article_status = upper(p_article_status);
*/
select 'Y' into result
from (
   select
   decode(artv.article_status, 'APPROVED', decode(greatest(nvl(trunc(end_date),
   trunc(sysdate))+1, trunc(sysdate)), trunc(sysdate), 'EXPIRED', artv.article_status),
   artv.article_status) article_status
   from
      okc_articles_all art,
      okc_article_versions artv
   where art.standard_yn = 'Y'
      and art.article_id = artv.article_id
      and artv.article_version_id = p_article_version_id
      and art.org_id = p_org_id
   union all
   select
   decode(arta.adoption_type, 'AVAILABLE', decode( decode(greatest(nvl(trunc(end_date),
   trunc(sysdate))+1, trunc(sysdate)), trunc(sysdate), 'EXPIRED', artv.article_status),
   'APPROVED', arta.adoption_status, 'EXPIRED', 'EXPIRED', 'ON_HOLD', 'ON_HOLD', 'REJECTED',
   'REJECTED' ), 'ADOPTED', decode( decode(arta.adoption_status, 'PENDING_APPROVAL',
   'PENDING_APPROVAL', decode(greatest(nvl(trunc(end_date), trunc(sysdate))+1, trunc(sysdate)),
   trunc(sysdate), 'EXPIRED', artv.article_status) ), 'APPROVED', arta.adoption_status, 'EXPIRED',
   'EXPIRED', 'ON_HOLD', 'ON_HOLD', 'PENDING_APPROVAL', 'PENDING_APPROVAL' ) ) article_status
   from
      okc_articles_all art,
      okc_article_versions artv,
      okc_article_adoptions arta
   where art.standard_yn = 'Y'
      and artv.global_yn = 'Y'
      and art.article_id = artv.article_id
      and artv.article_version_id = arta.global_article_version_id
      and artv.article_version_id = p_article_version_id
      and arta.local_org_id = p_org_id
      and arta.local_article_version_id is null
) a
where rownum <= 1
and article_status = upper(p_article_status);
      end if;
   end if;
elsif upper(p_search_flow) = 'GLOBAL' then
   if upper(p_article_status) = 'IGNORE' then
/* bug 5011435
      select 'Y' into result
      from okc_articles_global_v
      where org_id = p_org_id
      and article_version_id = p_article_version_id;
*/
select 'Y' into result
from (
   select 'Y'
   from
      okc_articles_all art,
      okc_article_versions artv
   where
      art.standard_yn = 'Y'
      and art.article_id = artv.article_id
      and org_id = p_org_id
      and article_version_id = p_article_version_id
) a
where rownum <= 1;
   else
      if p_article_status is null then
/* bug 5011435
         select 'Y' into result
         from okc_articles_global_v
         where org_id = p_org_id
         and article_version_id = p_article_version_id
         and article_status is null;
*/
select 'Y' into result
from (
   select
   decode(artv.article_status, 'APPROVED', decode(greatest(nvl(trunc(end_date),
   trunc(sysdate))+1, trunc(sysdate)), trunc(sysdate), 'EXPIRED', artv.article_status),
   artv.article_status) article_status
   from
      okc_articles_all art,
      okc_article_versions artv
   where
      art.standard_yn = 'Y'
      and art.article_id = artv.article_id
      and org_id = p_org_id
      and article_version_id = p_article_version_id
) a
where rownum <= 1
and article_status is null;
      else
/* bug 5011435
         select 'Y' into result
         from okc_articles_global_v
         where org_id = p_org_id
         and article_version_id = p_article_version_id
         and article_status = upper(p_article_status);
*/
select 'Y' into result
from (
   select
   decode(artv.article_status, 'APPROVED', decode(greatest(nvl(trunc(end_date),
   trunc(sysdate))+1, trunc(sysdate)), trunc(sysdate), 'EXPIRED', artv.article_status),
   artv.article_status) article_status
   from
      okc_articles_all art,
      okc_article_versions artv
   where
      art.standard_yn = 'Y'
      and art.article_id = artv.article_id
      and org_id = p_org_id
      and article_version_id = p_article_version_id
) a
where article_status = upper(p_article_status);
      end if;
   end if;
else
   return null;
end if;
return 'FRESH';
exception
when others then
return 'STALE';
end;

function validate_article_version(  p_article_version_id in number,
                                    p_article_status in varchar2,
                                    p_org_id in number)
return varchar2
is
result1 varchar2(5);
result2 varchar2(5);
begin
   result1 := null;
   result2 := null;
   result1 := validate_article_version('Local',
                                       p_article_version_id,
                                       p_article_status,
                                       p_org_id);
   result2 := validate_article_version('Global',
                                       p_article_version_id,
                                       p_article_status,
                                       p_org_id);
   if(result1 = 'FRESH' or result2 = 'FRESH')   then
      return 'FRESH';
   else
      return 'STALE';
   end if;
end;

procedure generic_error(routine in varchar2,
			               errcode in number,
			               errmsg in varchar2) is
begin
    fnd_message.set_name('FND', 'SQL_PLSQL_ERROR');
    fnd_message.set_token('ROUTINE', routine);
    fnd_message.set_token('ERRNO', errcode);
    fnd_message.set_token('REASON', dbms_utility.format_error_stack);
    fnd_msg_pub.add;
end;

function get_org_name(p_org_id in number) return varchar2
is
org_name hr_organization_units.name%type;
begin
-- Fix for bug# 5010703, replaced hr_organization_units_v with hr_organization_units for Performance(shared memory)
/* bug 5028066
   select name into org_name
   from hr_organization_units
   where organization_id = p_org_id;
*/
select
   otl.name into org_name
from
   hr_all_organization_units o,
   hr_all_organization_units_tl otl
where
   o.organization_id = otl.organization_id
   and otl.language = userenv('LANG')
   and o.organization_id = p_org_id;
   return org_name;
exception
   when others then  return null;
end;

-- -----------------------------------------------------------------------------
-- Function pre_submit_validation
-- validates approvers(Sell and Buy)/administrators(Sell and Buy) for the given organization id
-- Input:
--    p_org_id - organization id
-- Output:
--    result of validation
--    'OK' if valid
--    'NOK' if invalid
-- -----------------------------------------------------------------------------
function pre_submit_validation(p_org_id in number)
return varchar2
is
undefined_approver1S exception;
undefined_approver1B exception;
undefined_approver2S exception;
undefined_approver2B exception;
result varchar2(1);
approverS wf_users.name%type;
approverB wf_users.name%type;
begin
   result := 'N';
   fnd_msg_pub.initialize;
   approverS := get_approver(p_org_id, 'S');
   approverB := get_approver(p_org_id, 'B');

   if approverS is null then
      raise undefined_approver1S;
   end if;

   if approverB is null then
      raise undefined_approver1B;
   end if;

   begin
      select 'Y' into result
      from wf_users
      where name = approverS;
   exception
   when others then
      raise undefined_approver2S;
   end;
   if result = 'N' then
      raise undefined_approver2S;
   end if;

   begin
      select 'Y' into result
      from wf_users
      where name = approverB;
   exception
   when others then
      raise undefined_approver2B;
   end;
   if result = 'N' then
      raise undefined_approver2B;
   end if;

   return 'OK';
exception
   when undefined_approver1S then
      fnd_message.set_name('OKC', 'OKC_ART_UNDEF_SELL_APPROVER');
      fnd_message.set_token('ORGNAME', get_org_name(p_org_id));
      fnd_msg_pub.add;
      return 'NOK';
   when undefined_approver1B then
      fnd_message.set_name('OKC', 'OKC_ART_UNDEF_BUY_APPROVER');
      fnd_message.set_token('ORGNAME', get_org_name(p_org_id));
      fnd_msg_pub.add;
      return 'NOK';
   when undefined_approver2S then
      fnd_message.set_name('OKC', 'OKC_ART_UNKNOWN_SELL_APPROVER');
      fnd_message.set_token('ORGNAME', get_org_name(p_org_id));
      fnd_msg_pub.add;
      return 'NOK';
   when undefined_approver2B then
      fnd_message.set_name('OKC', 'OKC_ART_UNKNOWN_BUY_APPROVER');
      fnd_message.set_token('ORGNAME', get_org_name(p_org_id));
      fnd_msg_pub.add;
      return 'NOK';
   when others then
      generic_error('okc_artwf_pvt.pre_submit_validation', sqlcode, sqlerrm);
      return 'NOK';
end;

-- -----------------------------------------------------------------------------
-- Function pre_submit_validation
-- validates approvers(Sell and Buy) for the given organization id
-- and intent
-- Input:
--    p_org_id - organization id
--    p_intent - intent
-- Output:
--    result of validation
--    'OK' if valid
--    'NOK' if invalid
-- -----------------------------------------------------------------------------
function pre_submit_validation(p_org_id in number, p_intent in varchar2)
return varchar2
is
undefined_approver1S exception;
undefined_approver1B exception;
undefined_approver2S exception;
undefined_approver2B exception;
result varchar2(1);
approverS wf_users.name%type;
approverB wf_users.name%type;
begin
   result := 'N';
   fnd_msg_pub.initialize;
   approverS := get_approver(p_org_id, 'S');
   approverB := get_approver(p_org_id, 'B');

   if p_intent = 'S' then
      if approverS is null then
         raise undefined_approver1S;
      end if;
      begin
         select 'Y' into result
         from wf_users
         where name = approverS;
      exception
      when others then
         raise undefined_approver2S;
      end;
      if result = 'N' then
         raise undefined_approver2S;
      end if;
   end if;

   if p_intent = 'B' then
      if approverB is null then
         raise undefined_approver1B;
      end if;
      begin
         select 'Y' into result
         from wf_users
         where name = approverB;
      exception
      when others then
         raise undefined_approver2B;
      end;
      if result = 'N' then
         raise undefined_approver2B;
      end if;
   end if;

   return 'OK';
exception
   when undefined_approver1S then
      fnd_message.set_name('OKC', 'OKC_ART_UNDEF_SELL_APPROVER');
      fnd_message.set_token('ORGNAME', get_org_name(p_org_id));
      fnd_msg_pub.add;
      return 'NOK';
   when undefined_approver1B then
      fnd_message.set_name('OKC', 'OKC_ART_UNDEF_BUY_APPROVER');
      fnd_message.set_token('ORGNAME', get_org_name(p_org_id));
      fnd_msg_pub.add;
      return 'NOK';
   when undefined_approver2S then
      fnd_message.set_name('OKC', 'OKC_ART_UNKNOWN_SELL_APPROVER');
      fnd_message.set_token('ORGNAME', get_org_name(p_org_id));
      fnd_msg_pub.add;
      return 'NOK';
   when undefined_approver2B then
      fnd_message.set_name('OKC', 'OKC_ART_UNKNOWN_BUY_APPROVER');
      fnd_message.set_token('ORGNAME', get_org_name(p_org_id));
      fnd_msg_pub.add;
      return 'NOK';
   when others then
      generic_error('okc_artwf_pvt.pre_submit_validation', sqlcode, sqlerrm);
      return 'NOK';
end;

procedure transfer(
   itemtype    in varchar2,
   itemkey 	   in varchar2,
	actid		   in number,
	funcmode	   in varchar2,
	resultout   out nocopy varchar2
)
is
approver_name wf_users.display_name%type;
function_name varchar2(250);

cursor approver(new_approver in varchar2) is
select display_name
from wf_users
where name = new_approver;

begin
   if (funcmode = 'TRANSFER') then

	   open approver(wf_engine.CONTEXT_NEW_ROLE);
	   fetch approver into approver_name;
	   close approver;

      wf_engine.SetItemAttrText( itemtype,
	      				            itemkey,
     				                  'APPROVER_ROLE',
						               wf_engine.CONTEXT_NEW_ROLE);
      wf_engine.SetItemAttrText( itemtype,
	      				            itemkey,
     				                  'APPROVER_DISPLAY_NAME',
						               approver_name);
	end if;
exception when others then
   wf_core.context(  'OKC_ARTWF_PVT',
		               'TRANSFER',
		               itemtype,
		               itemkey,
		               to_char(actid),
		               funcmode);
   raise;
end transfer;

function itemtype(nid in number) return varchar2
is
str wf_notifications.context%type;
s number;
begin
select context into str
from wf_notifications
where notification_id = nid;
s := instr(str,':',1,1)-1;
return SUBSTR(str,1,s);
exception when others then
return null;
end;

function itemkey(nid in number) return varchar2
is
str wf_notifications.context%type;
f number;
s number;
begin
select context into str
from wf_notifications
where notification_id = nid;
f := instr(str,':',1,1);
s := instr(str,':',1,2)-f-1;
return substr(str,f+1,s);
exception when others then
return null;
end;

function code(str in varchar2) return varchar2
is
begin
return rtrim(str, '0123456789');
exception when others then
return null;
end;

function nid(str in varchar2) return varchar2
is
begin
return ltrim(str, okc_artwf_pvt.code(str));
exception when others then
return null;
end;

PROCEDURE orgname(   document_id in varchar2,
                     display_type in varchar2,
                     document in out NOCOPY varchar2,
                     document_type in out NOCOPY varchar2)
is
begin
   start_log('orgname');
   log('orgname entry');
   document := get_org_name(document_id);
   log('org_id='||document_id);
   log('org_name='||document);
   log('orgname exit');
end;

PROCEDURE subject(   document_id in varchar2,
                     display_type in varchar2,
                     document in out NOCOPY varchar2,
                     document_type in out NOCOPY varchar2)
is
   message_code fnd_new_messages.message_name%type;
   org_id okc_articles_all.org_id%type;
   article_id okc_articles_all.article_id%type;
   article_version_id okc_article_versions.article_version_id%type;

   requestor_name wf_users.display_name%type;
   itemtype wf_engine.setctx_itemtype%type;
   itemkey wf_engine.setctx_itemkey%type;
   nid number;
begin
   start_log('subject');
   log('subject entry');
   document := 'Undefined';
   nid := to_number(okc_artwf_pvt.nid(document_id));
   message_code := okc_artwf_pvt.code(document_id);
   itemtype := okc_artwf_pvt.itemtype(nid);
   itemkey := okc_artwf_pvt.itemkey(nid);
   fnd_message.clear;
   fnd_message.set_name(application => 'OKC', name => message_code);
   if message_code in ( 'OKC_ART_ADOPTION_NTF_SUBJECT',
                        'OKC_ART_ADOPTION_NTF_SUBJECT_A',
                        'OKC_ART_ADOPTION_NTF_SUBJECT_R',
                        'OKC_ART_APPROVAL_NTF_SUBJECT',
                        'OKC_ART_APPROVAL_NTF_SUBJECT_A',
                        'OKC_ART_APPROVAL_NTF_SUBJECT_R',
                        'OKC_ART_ADOPTED_NTF_SUBJECT',
                        'OKC_ART_AVAILABLE_NTF_SUBJECT') then
      fnd_message.set_token(  token => 'ARTICLENUMBER',
                              value => wf_notification.getAttrText(nid, '#HDR_ARTICLE_NUMBER'));
      fnd_message.set_token(  token => 'ARTICLETITLE',
                              value => wf_notification.getAttrText(nid, '#HDR_ARTICLE_TITLE'));
      fnd_message.set_token(  token => 'ARTICLEVERSIONNUMBER',
                              value => wf_notification.getAttrText(nid, '#HDR_ARTICLE_VERSION_NUMBER'));
      if message_code in ( 'OKC_ART_ADOPTION_NTF_SUBJECT',
                           'OKC_ART_APPROVAL_NTF_SUBJECT')   then
         fnd_message.set_token(  token => 'APPROVERNAME',
                                 value => wf_engine.GetItemAttrText( itemtype, itemkey, 'REQUESTOR_DISPLAY_NAME'));
      end if;
      if message_code in ( 'OKC_ART_ADOPTED_NTF_SUBJECT',
                           'OKC_ART_AVAILABLE_NTF_SUBJECT') then
         fnd_message.set_token(  token => 'ORGANIZATIONNAME',
                                 value => get_org_name(wf_notification.getAttrText(nid, 'ORGANIZATION$')));
      end if;
      document := fnd_message.get;
   end if;
   log('subject exit');
exception
   when others then
   WF_CORE.CONTEXT ('OKC_ARTWF_PVT', 'subject', itemtype, itemkey, document_id);
   raise;
end;

-- bug 5202585 start
function get_terms_org_name(p_template_id in number) return varchar2
is
org_name hr_organization_units.name%type;
begin
select
   otl.name into org_name
from
   hr_all_organization_units o,
   hr_all_organization_units_tl otl
where
   o.organization_id = otl.organization_id
   and otl.language = userenv('LANG')
   and o.organization_id = (
      select org_id
      from okc_terms_templates_all
      where template_id = p_template_id
   );
   return org_name;
exception
   when others then  return null;
end;

function get_terms_intent_meaning(p_template_id in number) return varchar2
is
intent_meaning okc_lookups_v.meaning%type;
begin
   select meaning into intent_meaning
   from okc_lookups_v
   where lookup_type = 'OKC_TERMS_INTENT'
   and lookup_code = (
      select intent
      from okc_terms_templates_all
      where template_id = p_template_id
   );
   return intent_meaning;
exception
   when others then  return null;
end;

procedure callback(  document_id in varchar2,
                     display_type in varchar2,
                     document in out NOCOPY varchar2,
                     document_type in out NOCOPY varchar2)
is
cursor ntf_attrs(nid in varchar2)
is
   select name
   from wf_notification_attributes
   where notification_id = nid;
begin
   for attr in ntf_attrs(document_id) loop
      if attr.name like '#HDR%' then
         if attr.name = '#HDR_TMPL_ORG_NAME' then
            wf_notification.SetAttrText(  document_id, attr.name,
               get_terms_org_name( wf_notification.GetAttrNumber( document_id, 'TEMPLATE_ID')));
         elsif attr.name = '#HDR_ORG_NAME' then
            wf_notification.SetAttrText(  document_id, attr.name,
               get_terms_org_name( wf_notification.GetAttrNumber( document_id, 'TEMPLATE_ID')));
         elsif attr.name = '#HDR_TMPL_INTENT' then
            wf_notification.SetAttrText( document_id, attr.name,
               get_terms_intent_meaning( wf_notification.GetAttrNumber( document_id, 'TEMPLATE_ID')));
         end if;
      end if;
   end loop;
   document := null;
exception
   when others then document := null;
end;
-- bug 5202585 end

-- bug 5261848 - cr3 start

function get_g_article_text(p_org_id number, p_article_version_id number)
return okc_article_versions.article_text%type
is
   text okc_article_versions.article_text%type;
begin
   text := empty_clob();
   select article_text into text
   from okc_article_versions
   where article_version_id = (
      select global_article_version_id
      from okc_article_adoptions
      where local_org_id = p_org_id
      and local_article_version_id = p_article_version_id
   );
   return text;
exception when others then
   text := empty_clob();
   dbms_lob.createtemporary(text, TRUE); --Bug# 9676464
   return text;
end;

function get_g_translated_yn(p_article_version_id number)
return okc_article_versions.translated_yn%type
is
   yn okc_article_versions.translated_yn%type;
begin
   yn := 'N';
   select nvl(translated_yn, 'N') into yn
   from okc_article_versions
   where article_version_id = p_article_version_id;
   return yn;
exception when others then
   return 'N';
end;

function get_g_localized_yn(p_org_id number, p_article_version_id number)
return varchar2
is
   yn varchar2(1);
begin
   yn := 'N';
   select 'Y' into yn
   from okc_article_adoptions
   where local_org_id = p_org_id
   and local_article_version_id = p_article_version_id;
   return yn;
exception when others then
   return 'N';
end;

function get_g_article_version_id(p_org_id number, p_article_version_id number)
return okc_article_versions.article_version_id%type
is
   id okc_article_versions.article_version_id%type;
begin
   id := null;
   select global_article_version_id into id
   from okc_article_adoptions
   where local_org_id = p_org_id
   and local_article_version_id = p_article_version_id;
   return id;
exception when others then
   return null;
end;

-- bug 5261848 - cr3 end

end;

/
