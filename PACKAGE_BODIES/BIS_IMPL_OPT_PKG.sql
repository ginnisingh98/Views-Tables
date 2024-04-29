--------------------------------------------------------
--  DDL for Package Body BIS_IMPL_OPT_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."BIS_IMPL_OPT_PKG" AS
  /*$Header: BISIMPLB.pls 120.11 2005/12/20 10:59:30 tiwang noship $*/

  PROCEDURE DEBUG( P_TEXT VARCHAR2, P_IDENT NUMBER DEFAULT 0)
  IS
  BEGIN
    FND_LOG_REPOSITORY.INIT;
    IF (FND_LOG.LEVEL_UNEXPECTED >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
      FND_LOG.STRING(FND_LOG.LEVEL_UNEXPECTED, icx_sec.getsessioncookie, FND_LOG.LEVEL_UNEXPECTED );
      FND_LOG.STRING(FND_LOG.LEVEL_UNEXPECTED, P_TEXT, FND_LOG.LEVEL_UNEXPECTED );
    END IF;
  END;

 PROCEDURE enableImplementation(
    p_object_name varchar2)
 IS
   stmt varchar2(2000);
 BEGIN

   update bis_obj_properties prop
   set implementation_flag = 'Y'
   where OBJECT_type = 'PAGE'
   and OBJECT_NAME = p_object_name;

   update bis_obj_properties
   set implementation_flag = 'Y'
   where (object_type, OBJECT_NAME)
   in( select distinct
         depend_object_type,
         depend_OBJECT_NAME
       from bis_obj_dependency
       where enabled_flag='Y'
       start with object_type='PAGE'
              and object_name = p_object_name
       connect by prior DEPEND_OBJECT_NAME  = object_name
       AND PRIOR depend_object_type = object_type);
   DEBUG('Done enableImplementation');
 END;


 PROCEDURE disableImplPruned (
    p_object_type varchar2,
    p_object_name varchar2)
 IS
 BEGIN
          update BIS_OBJ_PROPERTIES
          set implementation_flag = 'N'
          where not exists (
            -- back traverse and hit Pages that are implemented
            (select distinct
             dep.object_owner,
             dep.object_type,
             dep.OBJECT_NAME
             from bis_obj_dependency dep
             where dep.enabled_flag= 'Y'
             and dep.object_type = 'PAGE'
             and exists (
               select 1
               from BIS_OBJ_PROPERTIES tmp
               where tmp.OBJECT_NAME = dep.OBJECT_NAME
               and tmp.OBJECT_TYPE = dep.object_type
               and tmp.implementation_flag = 'Y'
             )
             start with (
               dep.depend_object_type = p_object_type and
               dep.depend_object_name = p_object_name
             )
             connect by dep.DEPEND_OBJECT_NAME  = prior dep.object_name
	     AND dep.depend_object_type = PRIOR dep.object_type
            )
          )
          and BIS_OBJ_PROPERTIES.object_type = p_object_type
          and BIS_OBJ_PROPERTIES.object_NAME = p_object_name;
 END;


 PROCEDURE smartPrunImpl(
    p_object_name varchar2)
 IS
    l_depend_object_type bis_obj_dependency.depend_OBJECT_TYPE%type;
    l_depend_object_name bis_obj_dependency.depend_OBJECT_NAME%type;

    CURSOR C_DISIMPLGRP ( P_PGNAME bis_obj_dependency.object_name%type )
    IS
      select distinct
       depend_object_type,
       depend_OBJECT_NAME
       from bis_obj_dependency
       where enabled_flag='Y'
       start with object_type='PAGE' and object_name = P_PGNAME
	connect by prior DEPEND_OBJECT_NAME  = object_name
	AND PRIOR depend_object_type = object_type;
 BEGIN
    open C_DISIMPLGRP(p_object_name);
    loop
      fetch C_DISIMPLGRP into l_depend_object_type, l_depend_object_name;
      exit when C_DISIMPLGRP%NOTFOUND;
      DEBUG('Processing ' || l_depend_object_type|| ', ' || l_depend_object_name);
      disableImplPruned(l_depend_object_type, l_depend_object_name);
    end loop;

 END;

 PROCEDURE disableImplementation(
    p_object_name varchar2)
 IS
   stmt varchar2(2000);
 BEGIN
   update bis_obj_properties prop
   set implementation_flag = 'N'
   where OBJECT_type = 'PAGE'
   and OBJECT_NAME = p_object_name;

   smartPrunImpl(p_object_name);
   DEBUG('Done disableImplementation');
 END;


 -- this procedure should be used to change implementation flag for page object only
 PROCEDURE changeImplementation(
    p_object_name varchar2,
    p_impl_flag varchar2)
 IS
   stmt varchar2(2000);
 BEGIN
  -- original implementation
  /*
  IF p_impl_flag = 'Y' THEN
    enableImplementation(p_object_name);
  ELSE
    disableImplementation(p_object_name);
  END IF;
  */

  execute immediate
    'update bis_obj_properties set IMPLEMENTATION_FLAG = :1
     where OBJECT_NAME = :2 AND object_type = :3'
    using p_impl_flag, p_object_name, 'PAGE';
 END;


 PROCEDURE  processChange
 IS
 BEGIN
   null;
 END;

 PROCEDURE Init_impl IS
 BEGIN
   null;
 END Init_impl;

 PROCEDURE  setImplementationOptions(
     errbuf  			   OUT NOCOPY VARCHAR2,
    retcode		           OUT NOCOPY VARCHAR2
 ) IS
 BEGIN
    errbuf  := NULL;
    retcode := '0';
    IF (Not BIS_COLLECTION_UTILITIES.setup('BIS_IMPL_OPT_PKG.setImplementationOptions')) THEN
      RAISE_APPLICATION_ERROR (-20000,'Error in SETUP: ' || errbuf);
      return;
    END IF;
    propagateimplementationoptions();
  EXCEPTION
  WHEN OTHERS THEN
    errbuf := sqlerrm;
    retcode := sqlcode;
    BIS_COLLECTION_UTILITIES.put_line(' ');
    BIS_COLLECTION_UTILITIES.put_line('Error occurred:');
    BIS_COLLECTION_UTILITIES.put_line(errbuf);

    BIS_COLLECTION_UTILITIES.WRAPUP(
      FALSE,
      0,
      errbuf,
      null,
      null
    );

 END setImplementationOptions;


/** Comment out the following two APIs because in 4422645
    UI is provided for the user to set impl flag for any reports
function check_top_node(p_object_type in varchar2,p_object_name in varchar2) return varchar2 is
l_dummy varchar2(1);
cursor c_top_node is
select 'Y'
from dual
where not exists
(select 'Y'
 from bis_obj_dependency
 where depend_object_name=p_object_name
 and depend_object_type=p_object_type);
begin
   l_dummy:='N';
   ------As of now, we only consider page or report has
   -----the chance being top node
   if p_object_type in ('MV','TABLE','VIEW','REGION') then
     return 'N';
   else ----'REPORT' or 'PAGE'
     open c_top_node;
     fetch c_top_node into l_dummy;
     close c_top_node;
     return l_dummy;
   end if;
 exception
  when others then
   raise;
end;


---This api is added for enhancement 3999465.
----It is called by preparation program before calling setImplementationOptions.
----Since we don't have UI for the user to set impl flag for reports,
---we have to use this API to set impl flag to "Y" at runtime (it is better
---than doing this at seeding time, because the user may create lots of reports
---while end up only run request set for few of them) so that
---reports (MVs under reports) can be refreshed properly.
---Note that once the flag is set to "Y", there is no chance to set it back
---to "N". This may cause potential issue for MV logs.
---Once we have UI for the user to set impl flag for reports, we
----can get rid of this API call.
procedure set_implflag_reports_in_set(p_set_name in varchar2,p_set_app_id in number) is

l_sql varchar2(1000):='
 update bis_obj_properties
 set implementation_flag=''Y''
 where object_type=''REPORT''
 and object_name in (
 select distinct object_name
 from bis_request_set_objects
 where object_type=''REPORT''
 and REQUEST_SET_NAME=:1
 and SET_APP_ID=:2 )';
begin
  execute immediate l_sql using p_set_name,p_set_app_id;
  commit;
 exception
   when others then
     bis_collection_utilities.put_line('error in set_implflag_reports_in_set '||sqlerrm);
end;
**/

----this procedure is added for enhancement 3999465,4422645
----set impl flag under reports because separate UI
---is provided for the user to set impl flag for reports
--- Modified again for bug 4664831 on Oct 12, 2006

procedure propagate_impl_flag_reports is
cursor c_impl_reports is
select object_name
from bis_obj_properties
where object_type='REPORT'
and implementation_flag='Y';

/**
cursor c_unimpl_reports is
select object_name
from bis_obj_properties
where object_type='REPORT'
and implementation_flag='N';
**/
cursor c_obj_under_reports (p_report_name varchar2) is
 select distinct dep.depend_object_name, dep.depend_object_type
 from
  ( select object_name,
           object_type,
           depend_object_name,
           depend_object_type
           from  bis_obj_dependency
		   where enabled_flag='Y') dep
 where dep.depend_object_type<>'REPORT'--bug 4609286
 start with dep.object_type = 'REPORT'
   and dep.object_name=p_report_name
  connect by prior dep.depend_object_name = dep.object_name
  and prior dep.depend_object_type = dep.object_type;


l_impl_report_rec c_impl_reports%rowtype;
---l_unimpl_report_rec c_unimpl_reports%rowtype;
l_obj_under_report_rec c_obj_under_reports%rowtype;

begin

/** commented for bug 4664831
  for l_unimpl_report_rec in c_unimpl_reports loop
    for l_obj_under_report_rec in c_obj_under_reports(l_unimpl_report_rec.object_name) loop
	   update bis_obj_properties
	   set IMPLEMENTATION_FLAG ='N'
	   where object_type=l_obj_under_report_rec.depend_object_type
	   and object_name=l_obj_under_report_rec.depend_object_name;
    end loop;
 end loop;
**/

 for l_impl_report_rec in c_impl_reports loop
    for l_obj_under_report_rec in c_obj_under_reports(l_impl_report_rec.object_name) loop
  	   update bis_obj_properties
	   set IMPLEMENTATION_FLAG ='Y'
	   where object_type=l_obj_under_report_rec.depend_object_type
	   and object_name=l_obj_under_report_rec.depend_object_name;
    end loop;
 end loop;
end ;


---added for enhancement 3999465 and 4422645.
FUNCTION report_in_impl_pages(p_report_name varchar2) return varchar2
is
cursor report_in_impl_pages is
select 'Y' from dual
where exists
(select 'Y'
 from
(SELECT distinct object_name
  FROM
  ( select object_name,
           object_type,
           object_owner,
           depend_object_name,
           depend_object_type,
           depend_object_owner,
           enabled_flag
     from
     bis_obj_dependency
     where enabled_flag='Y' ) obj
  where object_type='PAGE'
  START WITH depend_object_name =p_report_name AND depend_object_type ='REPORT'
  CONNECT BY PRIOR object_name = depend_object_name AND PRIOR object_type = depend_object_type) pages,
bis_obj_properties properties
where pages.object_name=properties.object_name
and properties.object_type='PAGE'
and properties.implementation_flag='Y');

l_report_in_impl_pages varchar2(1);
begin
   l_report_in_impl_pages:='N';
   open report_in_impl_pages;
   fetch report_in_impl_pages into l_report_in_impl_pages;
   close report_in_impl_pages;
   if l_report_in_impl_pages is null then
     l_report_in_impl_pages:='N';
   end if;
   return l_report_in_impl_pages;
end;


-----this procedure is called by RSG preparation program through setImplementationOptions,
-----as well as in page configuration module directly
 PROCEDURE propagateimplementationoptions IS
  l_report_in_impl_pages varchar2(1);

  cursor c_reports_impl_null is
  select object_name
  from bis_obj_properties
  where object_type='REPORT'
  and implementation_flag is null;

  l_reports_rec c_reports_impl_null%rowtype;

 BEGIN


    ---added for enhancement 3999465 and 4422645.
    ---For backward compatibility
    ---When a new report (implementation flag is null) is added to an existing implemented page
    ---the report should have impl flag set to Y automatically
    for l_reports_rec in c_reports_impl_null loop
        l_report_in_impl_pages:=report_in_impl_pages(l_reports_rec.object_name);
        if l_report_in_impl_pages='Y' then
          execute immediate 'update bis_obj_properties set IMPLEMENTATION_FLAG = ''Y''
           where object_type=''REPORT'' and object_name=:1' using l_reports_rec.object_name;
        end if;
    end loop;

    -- Reset implementation flag. Note if implementation option flag is null, treat as N
    ----Modified for enhancement 3999465 and 4422645
    ----Exclude reports because we will have UI to set impl flag for reports
 	execute immediate
        'update bis_obj_properties set IMPLEMENTATION_FLAG = ''N''
         WHERE (object_type not in ( ''PAGE'',''REPORT''))
         OR implementation_flag IS NULL';


	------set implementation flag to 'Y' for objects under implemented pages
	------Modified for enhancement 3999465 and 4422645. Exclude reports
    execute immediate
        'update bis_obj_properties set IMPLEMENTATION_FLAG = :1
         where object_type<> ''REPORT''
		  and   (object_name, object_type) in (
            select distinct dep.depend_object_name, dep.depend_object_type
            from bis_obj_dependency dep
            where dep.enabled_flag = :2
            start with dep.object_type = :3
                  and exists (select 1
                              from bis_obj_properties prop
                              where prop.object_type = dep.object_type
                              and prop.object_name = dep.object_name
                              and prop.implementation_flag = :4)
            connect by prior dep.depend_object_name = dep.object_name
		and prior dep.depend_object_type = dep.object_type
		AND PRIOR dep.enabled_flag = :5
         )'
         using 'Y', 'Y', 'PAGE', 'Y', 'Y';

    ----added this call for enhancement 3999465,4422645
    ----set implementation flag to 'Y' for objects under implemented reports
	propagate_impl_flag_reports ;

 END propagateimplementationoptions;



-- begin: added for bug 3560408
-- private function used to find if a form function name is valid
 -- not take portal page into consideration
 FUNCTION is_valid_page_func (
    p_func_name   IN VARCHAR2) RETURN VARCHAR2
 IS
    CURSOR c_funcs (p_func_name VARCHAR2) IS
       SELECT function_name
	 FROM fnd_form_functions
	 WHERE function_name = p_func_name
	 AND web_html_call LIKE 'OA.jsp?akRegionCode=BIS_COMPONENT_PAGE'||'&'||'akRegionApplicationId=191%';
    v_func_name fnd_form_functions.function_name%type; --Enhancement 4106617
    v_is_valid_func VARCHAR2(5);
 BEGIN
    IF (p_func_name IS NULL OR p_func_name = '') THEN
       RETURN 'N';
    END IF;

    OPEN c_funcs(p_func_name);
    FETCH c_funcs INTO v_func_name;
    IF (c_funcs%notfound) THEN
       -- not a valid page form function
       v_is_valid_func := 'N';
     ELSE
       -- valid page form function
       v_is_valid_func := 'Y';
    END IF;
    CLOSE c_funcs;
    RETURN v_is_valid_func;
 EXCEPTION
    WHEN OTHERS THEN
       RETURN 'N';
 END is_valid_page_func;

 -- private function used to find the page object name for a given fnd form function
 FUNCTION get_page_name_by_func (
    p_func_name   IN VARCHAR2) RETURN VARCHAR2
 IS
    CURSOR c_page_object_name(p_func_name VARCHAR2) IS
       SELECT object_name FROM bis_obj_dependency
	 WHERE object_type = 'PAGE' AND object_name = p_func_name || '_OA'
       UNION ALL
       SELECT object_name FROM bis_obj_properties
	 WHERE object_type = 'PAGE' AND object_name = p_func_name || '_OA';

       v_object_name bis_obj_dependency.object_name%type; --Enhancement 4106617
 BEGIN
    IF (p_func_name IS NULL OR p_func_name = '') THEN
       RETURN NULL;
    END IF;
    OPEN c_page_object_name(p_func_name);
    FETCH c_page_object_name INTO v_object_name;
    IF (c_page_object_name%notfound) THEN
       -- no _OA attached
       v_object_name := p_func_name;
    END IF;
    CLOSE c_page_object_name;
    RETURN v_object_name;
 EXCEPTION
   WHEN OTHERS THEN
      RETURN NULL;
 END get_page_name_by_func;



---Added for enhancement 4422645
PROCEDURE  cascade_implflag_to_reports(p_page_function in varchar2,
                                      p_impl_flag in varchar2) is

cursor reports_under_page(p_page_name varchar2) is
select depend_objects.obj_name
from
( select distinct
   obj.depend_OBJECT_NAME obj_name,
   obj.depend_object_type obj_type,
   obj.depend_object_owner obj_owner
 from
  ( select object_name,
           object_type,
           object_owner,
           depend_object_name,
           depend_object_type,
           depend_object_owner,
           enabled_flag
     from
     bis_obj_dependency
     where enabled_flag='Y' ) obj
  start with obj.object_type ='PAGE'
  and obj.object_name = p_page_name
  connect by prior obj.DEPEND_OBJECT_NAME=obj.object_name
  and prior depend_object_type=object_type
  ) depend_objects
  where depend_objects.obj_type='REPORT';

l_report_rec reports_under_page%rowtype;

l_page_name bis_obj_properties.object_name%type;

l_report_in_impl_pages varchar2(1);

begin
 l_page_name:=get_page_name_by_func(p_page_function);
 for l_report_rec in reports_under_page(l_page_name) loop
  l_report_in_impl_pages:='N';
  if p_impl_flag='Y' then
    execute immediate 'update bis_obj_properties set implementation_flag=:1 where object_type=:2 and object_name=:3'
    using 'Y','REPORT',l_report_rec.obj_name;
  else ---p_impl_flag='N'
   l_report_in_impl_pages:=report_in_impl_pages(l_report_rec.obj_name);
   if l_report_in_impl_pages='N' then
      execute immediate 'update bis_obj_properties set implementation_flag=:1 where object_type=:2 and object_name=:3'
      using 'N','REPORT',l_report_rec.obj_name;
   end if;
  end if;
 end loop;
exception
 when others then
  raise;
end ;

 -- public api: set implementation flag for a page identified by form function name
 PROCEDURE setfndformfuncpageimplflag (
    p_func_name                   IN VARCHAR2,
    p_impl_flag                   IN VARCHAR2,
    x_return_status               OUT nocopy VARCHAR2,
    x_msg_data                    OUT nocopy VARCHAR2
 ) IS
    v_impl_flag VARCHAR2(10);
    v_page_name VARCHAR2(480); --Enhancement 4106617
 BEGIN
    IF (p_func_name IS NULL OR p_func_name = '') THEN
       x_return_status := fnd_api.g_ret_sts_error;
       x_msg_data := 'BIS_BIA_INV_PAGE_FORM_FUNC';
       RETURN;
    END IF;

    IF (p_impl_flag IS NULL OR (p_impl_flag <> 'Y' AND p_impl_flag <> 'N')) THEN
       x_return_status := fnd_api.g_ret_sts_error;
       x_msg_data := 'BIS_BIA_INVALID_IMPL_FLAG';
       RETURN;
    END IF;

    v_impl_flag := getfndformfuncpageimplflag(p_func_name);

    IF (v_impl_flag IS NOT NULL AND v_impl_flag = 'INVALID') THEN
       -- object doesn't have at least one enabled portlet
       x_return_status := fnd_api.g_ret_sts_error;
       x_msg_data := 'BIS_BIA_PAGE_NO_ENABLED_PORTLETS';
     ELSIF (v_impl_flag IS NULL) THEN
       -- invalid form function name
       x_return_status := fnd_api.g_ret_sts_error;
       x_msg_data := 'BIS_BIA_INVALID_FORM_FUNC_FOR_PAGE';
     ELSIF (v_impl_flag = 'Y' OR v_impl_flag = 'N') THEN
       v_page_name :=  get_page_name_by_func(p_func_name);
       changeimplementation(v_page_name, p_impl_flag);
       -- successfully return
       x_return_status := FND_API.G_RET_STS_SUCCESS;
    END IF;

	---06/21/2005 Modified for enhancement 4422645, added logic to enable/disable reports
    ---under the page based on UI requirement
    cascade_implflag_to_reports(p_func_name, p_impl_flag);

    RETURN;
 EXCEPTION
    WHEN OTHERS THEN
       x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
       x_msg_data := 'BIS_BIA_UNEXPECTED_ERROR';
       RETURN;
 END;


---added for enhancement 4422645
 PROCEDURE setreportimplflag (
    p_report_name                   IN VARCHAR2,
    p_impl_flag                   IN VARCHAR2,
    x_return_status               OUT nocopy VARCHAR2,
    x_msg_data                    OUT nocopy VARCHAR2
 ) IS
 BEGIN
    IF (p_impl_flag IS NULL OR (p_impl_flag <> 'Y' AND p_impl_flag <> 'N')) THEN
       x_return_status := fnd_api.g_ret_sts_error;
       x_msg_data := 'BIS_BIA_INVALID_IMPL_FLAG';
       RETURN;
    END IF;

    execute immediate 'update bis_obj_properties set implementation_flag=:1 where object_type=:1 and object_name=:2'
    using    p_impl_flag,'REPORT' ,p_report_name;
     x_return_status := FND_API.G_RET_STS_SUCCESS;
    RETURN;
 EXCEPTION
    WHEN OTHERS THEN
       x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
       x_msg_data := 'BIS_BIA_UNEXPECTED_ERROR';
       RETURN;
 END;




 -- public api to get implementation flag for a page object identified by form function name
 FUNCTION getfndformfuncpageimplflag (
    p_func_name                  IN VARCHAR2
 ) RETURN VARCHAR2 IS
    v_is_valid_page_func VARCHAR2(5);
    v_page_name bis_obj_dependency.object_name%type; --Enhancement 4106617
    v_portlet_name bis_obj_dependency.depend_object_name%type; --Enhancement 4106617
    v_ret_code VARCHAR2(10);

    CURSOR c_enabled_dep_portlets (p_page_obj_name VARCHAR2) IS
       SElECT depend_object_name
	 FROM bis_obj_dependency objdep
	 WHERE objdep.object_name = p_page_obj_name
	 AND objdep.object_type = 'PAGE'
	 AND objdep.depend_object_type = 'PORTLET'
	 AND objdep.ENABLED_FLAG = 'Y';

    CURSOR c_getimpl_flag (p_page_obj_name VARCHAR2) IS
       SELECT Nvl (implementation_flag, 'N') implflag
	 FROM bis_obj_properties
	 WHERE object_type = 'PAGE' AND object_name = p_page_obj_name;
 BEGIN
    v_is_valid_page_func := is_valid_page_func(p_func_name);
    --dbms_output.put_line('v_is_valid_page_func: '||v_is_valid_page_func);
    IF (v_is_valid_page_func = 'N') THEN
       -- invalid page form function name
       RETURN NULL;
    END IF;

    v_page_name := get_page_name_by_func(p_func_name);
    --dbms_output.put_line('v_page_name: '||v_page_name);
    OPEN c_enabled_dep_portlets(v_page_name);
    FETCH c_enabled_dep_portlets INTO v_portlet_name;
    IF (c_enabled_dep_portlets%notfound) THEN
       -- doesn't have at least one enabled dependent portlet object
       v_ret_code := 'INVALID';
       --dbms_output.put_line('invalid');
     ELSE
       -- for implementation flag, default null as 'N'
       IF (c_getimpl_flag%ISOPEN) THEN
	  CLOSE c_getimpl_flag;
       END IF;
       OPEN c_getimpl_flag(v_page_name);
       FETCH c_getimpl_flag INTO v_ret_code;
       CLOSE c_getimpl_flag;
    END IF;
    CLOSE c_enabled_dep_portlets;
    RETURN v_ret_code;
 EXCEPTION
    WHEN OTHERS THEN
       RETURN NULL;
 END getfndformfuncpageimplflag;
 -- end: added for bug 3560408


 ---added for enhancement 4422645
 -- public api to get implementation flag for a report
 ---Returned values: 'Y', 'N' ---implementation flags
 ---'INVALID' when the report is not in RSG or doesn't have dependent objects,the UI should grey out
 ---the Enabled check box
 ---null when exception happens
  FUNCTION getreportimplflag (
    p_report_name                  IN VARCHAR2
 ) RETURN VARCHAR2 IS

    v_ret_code VARCHAR2(10);

    CURSOR c_enabled_dep_objects  IS
     select 'Y'
     from dual
     where exists
     (SElECT depend_object_name
	 FROM bis_obj_dependency objdep
	 WHERE objdep.object_name = p_report_name
	 AND objdep.object_type = 'REPORT'
	 AND objdep.ENABLED_FLAG = 'Y');

    --added for bug 4532066
    CURSOR c_linked_programs  IS
     select 'Y'
     from dual
     where exists
     (SElECT object_name
	 FROM bis_obj_prog_linkages
	 WHERE object_name = p_report_name
	 AND object_type = 'REPORT'
         AND ENABLED_FLAG = 'Y');

    CURSOR c_getimpl_flag  IS
       SELECT  object_name,implementation_flag implflag
	 FROM bis_obj_properties
	 WHERE object_type = 'REPORT' AND object_name = p_report_name;

	 l_dummy varchar2(1);
         l_prog_exist varchar2(1);
	 l_report_in_impl_pages varchar2(1);
	 l_object_name bis_obj_properties.object_name%type;

 BEGIN
    l_dummy:='N';
    l_object_name:=null;

    OPEN c_enabled_dep_objects;
    FETCH c_enabled_dep_objects INTO l_dummy;
    close c_enabled_dep_objects;

    -- logic modified for the bug 4532066
    -- if no dep objects then we have to check if there is any program associated with
    -- the report
    l_prog_exist:='N';
    OPEN c_linked_programs;
    FETCH c_linked_programs INTO l_prog_exist;
    close c_linked_programs;

    IF l_dummy='N' AND l_prog_exist='N' THEN
       -- report doesn't have at least one enabled dependent object
       -- and no program is linked with the report
       v_ret_code := 'INVALID';
    ELSE
       OPEN c_getimpl_flag;
       FETCH c_getimpl_flag INTO l_object_name, v_ret_code;
       CLOSE c_getimpl_flag;
       if v_ret_code is null then
         if l_object_name is not null then
            ----added for backward compatibility
            --- For the case when a new report is added to an existing implemented page
            ----at that moment the report in bis_obj_properties has implementation_flag as null
            l_report_in_impl_pages:=report_in_impl_pages(p_report_name) ;
            if l_report_in_impl_pages='Y' then
               v_ret_code:='Y';
            else
              v_ret_code:='N';
            end if;
         else --l_object_name is null, which means the report doesn't exist in RSG
             v_ret_code:='INVALID';
         end if ;--if l_object_name is not null
       end if; --v_ret_code is null
    END IF;
    RETURN v_ret_code;
 EXCEPTION
    WHEN OTHERS THEN
       RETURN NULL;
 END ;



 -- code added for bug 3736131
 -- this public API has been added at the request of Product teams
 -- As they needed one API To check if their Module has been implemented or not
 -- public api to know if the page is implemented or not
 -- This will raise whatever exception occurs, so that the wrapper JAVA API
 -- or whoever is calling this exception may get the exception and error is easy to track
 -- Though in normal circumstances there will be no exception. ONLY IF Database goes down
 -- Or the tables do not exist which is rarest possibility

 FUNCTION isPageImplemented (
			     p_func_name                  IN VARCHAR2
			     ) RETURN VARCHAR2 IS
				v_is_valid_page_func VARCHAR2(5);
				v_page_name VARCHAR2(480); --Enhancement 4106617
				v_ret_code VARCHAR2(10);
 BEGIN
    v_is_valid_page_func := is_valid_page_func(p_func_name);

    IF (v_is_valid_page_func = 'N') THEN          -- invalid page form function name
       RETURN NULL;
    END IF;

    v_page_name := get_page_name_by_func(p_func_name);

    -- for implementation flag, default null as 'N'
    execute immediate 'select nvl(implementation_flag, :1) implflag
      FROM bis_obj_properties
      WHERE object_type = :2 AND object_name = :3'
      INTO v_ret_code
      using 'N','PAGE', v_page_name;

    return v_ret_code;

 EXCEPTION
    WHEN OTHERS THEN
       RAISE;
 END;
 -- end: added for Enhancement 3736131


---This function is for RSG internal use only
function get_impl_flag(p_obj_name in varchar2,p_obj_type in varchar2) return varchar2 is
 l_impl_flag varchar2(1);
begin
  select implementation_flag
  into l_impl_flag
  from bis_obj_properties where object_name=p_obj_name and object_type=p_obj_type;
  return l_impl_flag;
  exception
    when no_data_found then
      return 'N';
    when others then
     raise;
end;

function check_implementation return varchar2 is
l_dummy varchar2(1);

cursor l_check_impl is
select 'Y'
from dual
where exists
(select 'Y' from bis_obj_properties
 where implementation_flag='Y'
 and object_type in ('PAGE','REPORT')
) ;

begin
  l_dummy:='N';
 open l_check_impl;
 fetch l_check_impl into l_dummy;
 if  l_check_impl%notfound then
    l_dummy:='N';
 end if;
 close l_check_impl;
 return l_dummy;
 exception
  when others then
    raise;
end;

END BIS_IMPL_OPT_PKG;



/
