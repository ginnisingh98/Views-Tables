--------------------------------------------------------
--  DDL for Package Body FND_FORM_FUNCTIONS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."FND_FORM_FUNCTIONS_PKG" as
/* $Header: AFFMFUNB.pls 120.2 2006/02/17 09:19:42 jvalenti ship $ */

-- private
function FUNCTION_VALIDATION (application_id in out nocopy number,
                               form_id in out nocopy number,
                               type in out nocopy varchar2,
                               parameters in out nocopy varchar2,
                               web_html_call in out nocopy varchar2,
                               web_host_name in varchar2,
                               region_application_id in out nocopy number,
                               region_code in out nocopy varchar2,
                               function_name in varchar2) return varchar2 is
columns_name varchar2(2000) := '';
begin
  /*
  ** Restore UNKNOWN functions
  **   functions with region_application_id were converted to REGION
  **   - region_application_id and region code used only in WEBPORTLET
  **   - form reference (with no web call) is a FORM
  **   - %.JSP web call is a JSP
  **   - %.% web call is a WWW
  **   - web call with no '%.%' is a DBPORTLET
  **   - REGION type function not used
  */

  if type is null then
    type := 'UNKNOWN';
    columns_name := 'TYPE = UNKNOWN';
  end if;

  if ( (type = 'REGION' or type = 'UNKNOWN') and
       (region_application_id is not null) and
       (region_code is not null) and
       (web_html_call is not null) and
       (form_id is null) ) then
    type := 'WEBPORTLET';
    columns_name := 'TYPE = WEBPORTLET';
  end if;

  /* Note: SUBFUNCTIONS will be converted to FORMS... */
  if ( (type = 'REGION' or type = 'UNKNOWN') and
       (application_id is not null) and
       (web_html_call is null) and
       (form_id is not null) ) then
    type := 'FORM';
    columns_name := 'TYPE = FORM';
  end if;

  if ( (type = 'REGION' or type = 'UNKNOWN') and
       (upper(web_html_call) like '%.JSP%')) then
    type := 'JSP';
    columns_name := 'TYPE = JSP';
  end if;

  if ( (type = 'REGION' or type = 'UNKNOWN') and
       (upper(web_html_call) like '%.%')) then
    type := 'WWW';
    columns_name := 'TYPE = WWW';
  end if;

  if ( (type = 'WWW' or type = 'REGION' or type = 'UNKNOWN') and
       (web_html_call not like '%.%') and
       (web_html_call not like '%=%')) then
    type := 'DBPORTLET';
    columns_name := 'TYPE = DBPORTLET';
  end if;

  if (type = 'REGION') then
    type := 'UNKNOWN';
    columns_name := 'TYPE = UNKNOWN';
  end if;

  /*
  ** Restore UNKNOWN functions
  **   functions with no form, region, or web call were set to UNKNOWN
  **   - restore PROCESS type functions
  **   - convert to SUBFUNCTION
  */

  if (type = 'UNKNOWN' and
      parameters like '%:%' and
      parameters not like '%=%') then
    type := 'PROCESS';
    columns_name := 'TYPE = PROCESS';
  end if;

  if (type = 'UNKNOWN' and
      form_id is null and
      application_id is null and
      web_html_call is null) then
    type := 'SUBFUNCTION';
    columns_name := 'TYPE = SUBFUNCTION';
  end if;

  /*
  ** SUBFUNCTIONs with wrong type
  **   - FORM type with no form_id
  **   - "WEB" type with no web_html_call
  */

  if (type = 'FORM' and
      form_id is null and
      application_id is null) then
    type := 'SUBFUNCTION';
    columns_name := 'TYPE = SUBFUNCTION';
  end if;

  if ((type = 'WWW' or
       type = 'WWL' or
       type = 'WWLG' or
       type = 'WWK') and
      (web_html_call is null) and
      (web_host_name is null)) then
    type := 'SUBFUNCTION';
    columns_name := 'TYPE = SUBFUNCTION';
  end if;

  if ((type = 'JSP' or
       type = 'INTEROPJSP' or
       type = 'SERVLET' or
       type = 'WEBPORTLET' or
       type = 'JTFWEBPORTLET' or
       type = 'DBPORTLET' or
       type = 'MOBILE') and
      (web_html_call is null)) then
    type := 'SUBFUNCTION';
    columns_name := 'TYPE = SUBFUNCTION';
  end if;

  /*
  ** Mispellings
  */
  if (type like 'SUB%' and
      type <> 'SUBFUNCTION') then
    type := 'SUBFUNCTION';
    columns_name := 'TYPE = SUBFUNCTION';
  end if;

  if (type = 'SERVELET') then
    type := 'SERVLET';
    columns_name := 'TYPE = SERVLET';
  end if;

  /*
  ** Obsolete types:  PL/SQL web type functions
  ** web functions must be one of
  **   WWW       - general web page
  **   WWK       - "kiosk" web page
  **   WWL       - Responsibility-specific PHP plug-in
  **   WWLG      - Global PHP plug-in
  **   DBPORTLET - Portal portlet
  */
  if ((web_html_call is not null) and
      (form_id is null) and
      (application_id is null) and
      (type like 'WW%') and
      (type not in ('WWW', 'WWK', 'WWL', 'WWLG')) and
      (type = 'WWP') )then
    type := 'DBPORTLET';
    columns_name := 'TYPE = DBPORTLET';
  end if;

  if ((web_html_call is not null) and
      (form_id is null) and
      (application_id is null) and
      (type like 'WW%') and
      (type not in ('WWW', 'WWK', 'WWL', 'WWLG')) and
      (type = 'WWR') )then
    type := 'WWL';
    columns_name := 'TYPE = WWL';
  end if;

  if ((web_html_call is not null) and
      (form_id is null) and
      (application_id is null) and
      (type like 'WW%') and
      (type not in ('WWW', 'WWK', 'WWL', 'WWLG')) and
      (type = 'WWRG') )then
    type := 'WWLG';
    columns_name := 'TYPE = WWLG';
  end if;

  if ((web_html_call is not null) and
      (form_id is null) and
      (application_id is null) and
      (type like 'WW%') and
      (type not in ('WWW', 'WWK', 'WWL', 'WWLG'))) then
    type := 'WWW';
    columns_name := 'TYPE = WWW';
  end if;

  /*
  ** Obsolete / unrecognized types: FORM type functions
  */

  if (type <> 'FORM'
  and type <> 'SUBFUNCTION'
  and type <> 'PROCESS'
  and type <> 'WWW'
  and type <> 'JSP'
  and type <> 'SERVLET'
  and type <> 'DBPORTLET'
  and type <> 'WEBPORTLET'
  and type <> 'WWK'
  and type <> 'WWL'
  and type <> 'WWLG'
  and form_id is not null
  and application_id is not null) then
    type := 'FORM';
    columns_name := 'TYPE = FORM';
  end if;


/*
** June 2003: Clean up invalid function type.
**            The script is developed after product team have reviewed
**            our proposal.
** Note: Case 1 to 6 is being done in the above sql scripts.
*/

-- For formatting purpose
if (columns_name is not null) then
  columns_name := columns_name||fnd_global.newline;
end if;

declare
  applname varchar2(8);
begin

  if (((type='FORM' and substr(function_name,1,3)
                                    in ('WIP','INV','WMS','WMA')) or
         (type='FORM' and substr(function_name,1,2) = 'QA') or
         (type = 'WWW' and substr(function_name,1,3)
                                    in ('WIP','INV','WMS','WMA')) or
         (type = 'WWW' and substr(function_name,1,2) = 'QA')) and
      (web_html_call is not null) and
      (application_id is not null) and
      (upper(web_html_call) not like 'ORACLE.APPS.%') and
      (upper(web_html_call) not like '%.JSP%') ) then

    select lower(application_short_name)
    into applname
    from fnd_application
    where application_id = FUNCTION_VALIDATION.application_id;

    web_html_call := 'oracle.apps.'||applname||'.'||web_html_call;
    columns_name := columns_name||'WEB_HTML_CALL = '||web_html_call;
  end if;
end;

if (form_id is not null and
    web_html_call is not null and
    upper(web_html_call) not like '%.JSP%' and
   ((type='FORM' and substr(function_name,1,3) in ('WIP','INV','WMS','WMA')) or
    (type='FORM' and substr(function_name,1,2)='QA') or
    (type='WWW' and substr(function_name,1,3) in ('INV','WMS','WMA', 'WIP')) or
    (type='WWW' and substr(function_name,1,2) = 'QA'))) then
  form_id := '';
  application_id := '';
  type := 'MOBILE';
  columns_name := columns_name||'FORM_ID = null'||fnd_global.newline;
  columns_name := columns_name||'APPLICATION_ID = null'||fnd_global.newline;
  columns_name := columns_name||'TYPE = MOBILE'||fnd_global.newline;
end if;

if (upper(web_html_call) like '%MOBILE%' and
    function_name in ('PN_MOBILE_CUST_DIR',
                      'HZ_MOBILE_CUSTOMER',
                      'AP_OME_EXPENSES',
                      'AP_OME_EXPENSES_QUICK',
                      'AR_MAM_APPLICATION_FUNCTION')) then
  type := 'MOBILE';
  form_id := '';
  application_id := '';
  columns_name := columns_name||'FORM_ID = null'||fnd_global.newline;
  columns_name := columns_name||'APPLICATION_ID = null'||fnd_global.newline;
  columns_name := columns_name||'TYPE = MOBILE'||fnd_global.newline;
end if;

if (type = 'FORM' and
    web_html_call is not null) then
  web_html_call := '';
  columns_name := columns_name||'WEB_HTML_CALL = null'||fnd_global.newline;
end if;

/*
+-----+-------------------------------+---------------------------------+-----+
|  8  | TYPE='FORM' &                 | Set REGION_APPLICATION_ID to    | 30  |
|     | REGION_APPLICATION_ID has data| null                            |     |
+-----+-------------------------------+---------------------------------+-----+
*/
if (type = 'FORM' and
    region_application_id is not null) then
  region_application_id := '';
  columns_name := columns_name||'REGION_APPLICATION_ID = null'||
                                                           fnd_global.newline;
end if;

/*
+-----+-------------------------------+---------------------------------+-----+
|  9  | TYPE='JSP'  &                 | Change TYPE to UNKNOWN          | 36  |
|     | WEB_HTML_CALL not like '%jsp%'|                                 |     |
+-----+-------------------------------+---------------------------------+-----+
*/
if (type = 'JSP' and
    upper(web_html_call) not like '%JSP%' and
    upper(web_html_call) not like '%JAVASCRIPT%') then
  type := 'UNKNOWN';
  columns_name := columns_name||'TYPE = UNKNOWN'||fnd_global.newline;
end if;

/*
+-----+-------------------------------+---------------------------------+-----+
| 10  | TYPE='JSP' &                  | Set FORM_ID to NULL             | 44  |
|     | FORM_ID has data &            | Set APPLICATION_ID to NULL      |     |
|     | APPLICATION_ID has data       |                                 |     |
+-----+-------------------------------+---------------------------------+-----+
*/
if (type = 'JSP' and
    form_id is not null and
    application_id is not null) then
  form_id := '';
  application_id := '';
  columns_name := columns_name||'FORM_ID = null'||fnd_global.newline;
  columns_name := columns_name||'APPLICATION_ID = null'||fnd_global.newline;
end if;

/*
+-----+-------------------------------+---------------------------------+-----+
| 11  | TYPE='WWW' &                  | Set FORM_ID to NULL             | 98  |
|     | FORM_ID has data &            | Set APPLICATION_ID to NULL      |     |
|     | APPLICATION_ID has data       |                                 |     |
+-----+-------------------------------+---------------------------------+-----+
*/
if (type = 'WWW' and
    (form_id is not null or application_id is not null)) then
  form_id := '';
  application_id := '';
  columns_name := columns_name||'FORM_ID = null'||fnd_global.newline;
  columns_name := columns_name||'APPLICATION_ID = null'||fnd_global.newline;
end if;

/*
+-----+-------------------------------+---------------------------------+-----+
| 12  | TYPE='SUBFUNCTION' &          | Chage TYPE to FORM              | 353 |
|     | FORM_ID has data &            |                                 |     |
|     | PARAMETERS is null &          |                                 |     |
|     | WEB_HTML_CALL is null &       |                                 |     |
|     | REGION_CODE is null           |                                 |     |
+-----+----------------------------- -+---------------------------------+-----+
*/
if ( type = 'SUBFUNCTION'
 and form_id is not null
 and parameters is null
 and web_html_call is null
 and region_code is null) then
  type := 'FORM';
  columns_name := columns_name||'TYPE = FORM'||fnd_global.newline;
end if;

/*
+-----+----------------------------- -+---------------------------------+-----+
| 13  | TYPE='SUBFUNCTION' &          | Set REGION_CODE to null         | 114 |
|     | REGION_CODE has data &        |                                 |     |
|     | FORM_ID is null&              |                                 |     |
|     | PARAMETERS is null &          |                                 |     |
|     | WEB_HTML_CALL is null &       |                                 |     |
+-----+----------------------------- -+---------------------------------+-----+
*/
if ( type = 'SUBFUNCTION'
 and form_id is null
 and parameters is null
 and web_html_call is null
 and region_code is not null) then
  region_code := '';
  columns_name := columns_name||'REGION_CODE = null'||fnd_global.newline;
end if;

/*
+-----+----------------------------- -+---------------------------------+-----+
| 14  | TYPE='SUBFUNCTION' &          | Change TYPE to JSP              |  6  |
|     | WEB_HTML_CALL has data &      |                                 |     |
|     | WEB_HTML_CALL like '%jsp%'    |                                 |     |
|     | REGION_CODE is null &         |                                 |     |
|     | FORM_ID is null &             |                                 |     |
|     | PARAMETERS is null            |                                 |     |
+-----+-------------------------------+---------------------------------+-----+
*/
if (  type = 'SUBFUNCTION'
  and form_id is null
  and parameters is null
  and web_html_call is not null
  and upper(web_html_call) like '%JSP%'
  and region_code is null) then
  type := 'JSP';
  columns_name := columns_name||'TYPE = JSP'||fnd_global.newline;
end if;

/*
+-----+-------------------------------+---------------------------------+-----+
| 15  | TYPE='SUBFUNCTION' &          | Change TYPE to UNKNOWN          |  1  |
|     | WEB_HTML_CALL has data &      |                                 |     |
|     | WEB_HTML_CALL like '%mailto%' |                                 |     |
|     | REGION_CODE is null &         |                                 |     |
|     | FORM_ID is null &             |                                 |     |
|     | PARAMETERS is null            |                                 |     |
+-----+-------------------------------+---------------------------------+-----+
*/
if (  type = 'SUBFUNCTION'
  and form_id is null
  and parameters is null
  and web_html_call is not null
  and upper(web_html_call) not like '%JSP%'
  and region_code is null) then
  type := 'UNKNOWN';
  columns_name := columns_name||'TYPE = UNKNOWN'||fnd_global.newline;
end if;

/*
+-----+-------------------------------+---------------------------------+-----+
| 16  | TYPE='SUBFUNCTION' &          | Change TYPE to FORM             |  16 |
|     | FORM_ID has data &            |                                 |     |
|     | PARAMETERS has data &         |                                 |     |
|     | WEB_HTML_CALL is null &       |                                 |     |
|     | REGION_CODE is null           |                                 |     |
+-----+-------------------------------+---------------------------------+-----+
*/
if (  type = 'SUBFUNCTION'
  and form_id is not null
  and parameters is not null
  and web_html_call is null
  and region_code is null ) then
  type := 'FORM';
  columns_name := columns_name||'TYPE = FORM'||fnd_global.newline;
end if;

/*
+-----+-------------------------------+---------------------------------+-----+
| 17  | TYPE='JTFWEBPORTLET' &        | Change TYPE to UNKNOWN          |  3  |
|     | WEB_HTML_CALL is null         |                                 |     |
+-----+-------------------------------+---------------------------------+-----+
*/
if (  type = 'JTFWEBPORTLET'
  and web_html_call is null) then
  type := 'UNKNOWN';
  columns_name := columns_name||'TYPE = UNKNOWN'||fnd_global.newline;
end if;

/*
+-----+-------------------------------+---------------------------------+-----+
| 18  | TYPE='INTEROPJSP' &           | Change TYPE to UNKNOWN          |  5  |
|     | WEB_HTML_CALL is null         |                                 |     |
+-----+-------------------------------+---------------------------------+-----+
*/
if (  type = 'INTEROPJSP'
  and web_html_call is null) then
  type := 'UNKNOWN';
  columns_name := columns_name||'TYPE = UNKNOWN'||fnd_global.newline;
end if;

/*
+-----+-------------------------------+---------------------------------+-----+
| 20  | TYPE='OBJECT'                 | Change TYPE to UNKNOWN          | 26  |
+-----+-------------------------------+---------------------------------+-----+
*/
if (type = 'OBJECT') then
  type := 'UNKNOWN';
  columns_name := columns_name||'TYPE = UNKNOWN'||fnd_global.newline;
end if;

/*
+-----+-------------------------------+---------------------------------+-----+
| 21  | TYPE='HTML' &                 | Change TYPE to JSP              |  2  |
|     | WEB_HTML_CALL like %jsp%      |                                 |     |
+-----+-------------------------------+---------------------------------+-----+
*/
if (type = 'HTML') then
  type := 'UNKNOWN';
  columns_name := columns_name||'TYPE = UNKNOWN'||fnd_global.newline;
end if;

/* Bug4507567 - Added for R12
+-----+-------------------------------+---------------------------------+-----+
|     | TYPE='INTERFACE'||            | Change TYPE to UNKNOWN          |     |
|     | TYPE='SB_INDIRECT_OP'&        |                                 |     |
|     | irep_method_name is null      |                                 |     |
|     | irep_scope is null            |                                 |     |
|     | irep_lifecycle is null        |                                 |     |
|     | irep_description is null      |                                 |     |
|     | Irep_class_id is null         |                                 |     |
+-----+-------------------------------+---------------------------------+-----+

if ((type = 'INTERFACE' or type = 'SB_INDIRECT_OP')
     and irep_method_name is null
     and irep_scope is null
     and irep_lifecycle is null
     and irep_description is null
     and irep_class_id is null) then
   type := 'UNKNOWN';
   columns_name := columns_name||'TYPE = UNKNOWN'||fnd_global.newline;
end if;
*/

return(columns_name);

end FUNCTION_VALIDATION;


procedure INSERT_ROW (
  X_ROWID in out nocopy VARCHAR2,
  X_FUNCTION_ID in NUMBER,
  X_WEB_HOST_NAME in VARCHAR2,
  X_WEB_AGENT_NAME in VARCHAR2,
  X_WEB_HTML_CALL in VARCHAR2,
  X_WEB_ENCRYPT_PARAMETERS in VARCHAR2,
  X_WEB_SECURED in VARCHAR2,
  X_WEB_ICON in VARCHAR2,
  X_OBJECT_ID in NUMBER,
  X_REGION_APPLICATION_ID in NUMBER,
  X_REGION_CODE in VARCHAR2,
  X_FUNCTION_NAME in VARCHAR2,
  X_APPLICATION_ID in NUMBER,
  X_FORM_ID in NUMBER,
  X_PARAMETERS in VARCHAR2,
  X_TYPE in VARCHAR2,
  X_USER_FUNCTION_NAME in VARCHAR2,
  X_DESCRIPTION in VARCHAR2,
  X_CREATION_DATE in DATE,
  X_CREATED_BY in NUMBER,
  X_LAST_UPDATE_DATE in DATE,
  X_LAST_UPDATED_BY in NUMBER,
  X_LAST_UPDATE_LOGIN in NUMBER
) is
begin
      fnd_form_functions_pkg.INSERT_ROW(
       X_ROWID                  => X_ROWID,
       X_FUNCTION_ID            => X_FUNCTION_ID,
       X_WEB_HOST_NAME          => X_WEB_HOST_NAME,
       X_WEB_AGENT_NAME         => X_WEB_AGENT_NAME,
       X_WEB_HTML_CALL          => X_WEB_HTML_CALL,
       X_WEB_ENCRYPT_PARAMETERS => X_WEB_ENCRYPT_PARAMETERS,
       X_WEB_SECURED            => X_WEB_SECURED,
       X_WEB_ICON               => X_WEB_ICON,
       X_OBJECT_ID              => X_OBJECT_ID,
       X_REGION_APPLICATION_ID  => X_REGION_APPLICATION_ID,
       X_REGION_CODE            => X_REGION_CODE,
       X_FUNCTION_NAME          => X_FUNCTION_NAME,
       X_APPLICATION_ID         => X_APPLICATION_ID,
       X_FORM_ID                => X_FORM_ID,
       X_PARAMETERS             => X_PARAMETERS,
       X_TYPE                   => X_TYPE,
       X_USER_FUNCTION_NAME     => X_USER_FUNCTION_NAME,
       X_DESCRIPTION            => X_DESCRIPTION,
       X_CREATION_DATE          => X_CREATION_DATE,
       X_CREATED_BY             => X_CREATED_BY,
       X_LAST_UPDATE_DATE       => X_LAST_UPDATE_DATE,
       X_LAST_UPDATED_BY        => X_LAST_UPDATED_BY,
       X_LAST_UPDATE_LOGIN      => X_LAST_UPDATE_LOGIN,
       X_MAINTENANCE_MODE_SUPPORT => NULL,
       X_CONTEXT_DEPENDENCE       => NULL,
       X_JRAD_REF_PATH          => NULL);
end INSERT_ROW;

procedure LOCK_ROW (
  X_FUNCTION_ID in NUMBER,
  X_WEB_HOST_NAME in VARCHAR2,
  X_WEB_AGENT_NAME in VARCHAR2,
  X_WEB_HTML_CALL in VARCHAR2,
  X_WEB_ENCRYPT_PARAMETERS in VARCHAR2,
  X_WEB_SECURED in VARCHAR2,
  X_WEB_ICON in VARCHAR2,
  X_OBJECT_ID in NUMBER,
  X_REGION_APPLICATION_ID in NUMBER,
  X_REGION_CODE in VARCHAR2,
  X_FUNCTION_NAME in VARCHAR2,
  X_APPLICATION_ID in NUMBER,
  X_FORM_ID in NUMBER,
  X_PARAMETERS in VARCHAR2,
  X_TYPE in VARCHAR2,
  X_USER_FUNCTION_NAME in VARCHAR2,
  X_DESCRIPTION in VARCHAR2
) is
begin
      fnd_form_functions_pkg.LOCK_ROW(
       X_FUNCTION_ID            => X_FUNCTION_ID,
       X_WEB_HOST_NAME          => X_WEB_HOST_NAME,
       X_WEB_AGENT_NAME         => X_WEB_AGENT_NAME,
       X_WEB_HTML_CALL          => X_WEB_HTML_CALL,
       X_WEB_ENCRYPT_PARAMETERS => X_WEB_ENCRYPT_PARAMETERS,
       X_WEB_SECURED            => X_WEB_SECURED,
       X_WEB_ICON               => X_WEB_ICON,
       X_OBJECT_ID              => X_OBJECT_ID,
       X_REGION_APPLICATION_ID  => X_REGION_APPLICATION_ID,
       X_REGION_CODE            => X_REGION_CODE,
       X_FUNCTION_NAME          => X_FUNCTION_NAME,
       X_APPLICATION_ID         => X_APPLICATION_ID,
       X_FORM_ID                => X_FORM_ID,
       X_PARAMETERS             => X_PARAMETERS,
       X_TYPE                   => X_TYPE,
       X_USER_FUNCTION_NAME     => X_USER_FUNCTION_NAME,
       X_DESCRIPTION            => X_DESCRIPTION,
       X_MAINTENANCE_MODE_SUPPORT => NULL,
       X_CONTEXT_DEPENDENCE       => NULL,
       X_JRAD_REF_PATH          => NULL);

end LOCK_ROW;

procedure UPDATE_ROW (
  X_FUNCTION_ID in NUMBER,
  X_WEB_HOST_NAME in VARCHAR2,
  X_WEB_AGENT_NAME in VARCHAR2,
  X_WEB_HTML_CALL in VARCHAR2,
  X_WEB_ENCRYPT_PARAMETERS in VARCHAR2,
  X_WEB_SECURED in VARCHAR2,
  X_WEB_ICON in VARCHAR2,
  X_OBJECT_ID in NUMBER,
  X_REGION_APPLICATION_ID in NUMBER,
  X_REGION_CODE in VARCHAR2,
  X_FUNCTION_NAME in VARCHAR2,
  X_APPLICATION_ID in NUMBER,
  X_FORM_ID in NUMBER,
  X_PARAMETERS in VARCHAR2,
  X_TYPE in VARCHAR2,
  X_USER_FUNCTION_NAME in VARCHAR2,
  X_DESCRIPTION in VARCHAR2,
  X_LAST_UPDATE_DATE in DATE,
  X_LAST_UPDATED_BY in NUMBER,
  X_LAST_UPDATE_LOGIN in NUMBER
) is
begin
      fnd_form_functions_pkg.UPDATE_ROW(
       X_FUNCTION_ID            => X_FUNCTION_ID,
       X_WEB_HOST_NAME          => X_WEB_HOST_NAME,
       X_WEB_AGENT_NAME         => X_WEB_AGENT_NAME,
       X_WEB_HTML_CALL          => X_WEB_HTML_CALL,
       X_WEB_ENCRYPT_PARAMETERS => X_WEB_ENCRYPT_PARAMETERS,
       X_WEB_SECURED            => X_WEB_SECURED,
       X_WEB_ICON               => X_WEB_ICON,
       X_OBJECT_ID              => X_OBJECT_ID,
       X_REGION_APPLICATION_ID  => X_REGION_APPLICATION_ID,
       X_REGION_CODE            => X_REGION_CODE,
       X_FUNCTION_NAME          => X_FUNCTION_NAME,
       X_APPLICATION_ID         => X_APPLICATION_ID,
       X_FORM_ID                => X_FORM_ID,
       X_PARAMETERS             => X_PARAMETERS,
       X_TYPE                   => X_TYPE,
       X_USER_FUNCTION_NAME     => X_USER_FUNCTION_NAME,
       X_DESCRIPTION            => X_DESCRIPTION,
       X_LAST_UPDATE_DATE       => X_LAST_UPDATE_DATE,
       X_LAST_UPDATED_BY        => X_LAST_UPDATED_BY,
       X_LAST_UPDATE_LOGIN      => X_LAST_UPDATE_LOGIN,
       X_MAINTENANCE_MODE_SUPPORT => NULL,
       X_CONTEXT_DEPENDENCE       => NULL,
       X_JRAD_REF_PATH          => NULL);
end UPDATE_ROW;

/* Overloaded version below */
procedure LOAD_ROW (
  X_FUNCTION_NAME in VARCHAR2,
  X_APPLICATION_SHORT_NAME in VARCHAR2,
  X_FORM_NAME in VARCHAR2,
  X_PARAMETERS in VARCHAR2,
  X_TYPE in VARCHAR2,
  X_WEB_HOST_NAME in VARCHAR2,
  X_WEB_AGENT_NAME in VARCHAR2,
  X_WEB_HTML_CALL in VARCHAR2,
  X_WEB_ENCRYPT_PARAMETERS in VARCHAR2,
  X_WEB_SECURED in VARCHAR2,
  X_WEB_ICON in VARCHAR2,
  X_OBJECT_NAME in VARCHAR2,
  X_REGION_APPLICATION_NAME in VARCHAR2,
  X_REGION_CODE in VARCHAR2,
  X_USER_FUNCTION_NAME in VARCHAR2,
  X_DESCRIPTION in VARCHAR2,
  X_OWNER in VARCHAR2,
  X_CUSTOM_MODE in VARCHAR2
) is
begin
  fnd_form_functions_pkg.LOAD_ROW (
    X_FUNCTION_NAME           => X_FUNCTION_NAME,
    X_APPLICATION_SHORT_NAME  => X_APPLICATION_SHORT_NAME,
    X_FORM_NAME               => X_FORM_NAME,
    X_PARAMETERS              => X_PARAMETERS,
    X_TYPE                    => X_TYPE,
    X_WEB_HOST_NAME           => X_WEB_HOST_NAME,
    X_WEB_AGENT_NAME          => X_WEB_AGENT_NAME,
    X_WEB_HTML_CALL           => X_WEB_HTML_CALL,
    X_WEB_ENCRYPT_PARAMETERS  => X_WEB_ENCRYPT_PARAMETERS,
    X_WEB_SECURED             => X_WEB_SECURED,
    X_WEB_ICON                => X_WEB_ICON,
    X_OBJECT_NAME             => X_OBJECT_NAME,
    X_REGION_APPLICATION_NAME => X_REGION_APPLICATION_NAME,
    X_REGION_CODE             => X_REGION_CODE,
    X_USER_FUNCTION_NAME      => X_USER_FUNCTION_NAME,
    X_DESCRIPTION             => X_DESCRIPTION,
    X_OWNER                   => X_OWNER,
    X_CUSTOM_MODE             => X_CUSTOM_MODE,
    X_LAST_UPDATE_DATE        => NULL,
    X_MAINTENANCE_MODE_SUPPORT => NULL,
    X_CONTEXT_DEPENDENCE       => NULL,
    X_JRAD_REF_PATH           => NULL
  );
end LOAD_ROW;

/* Overloaded version above */
procedure LOAD_ROW (
  X_FUNCTION_NAME in VARCHAR2,
  X_APPLICATION_SHORT_NAME in VARCHAR2,
  X_FORM_NAME in VARCHAR2,
  X_PARAMETERS in VARCHAR2,
  X_TYPE in VARCHAR2,
  X_WEB_HOST_NAME in VARCHAR2,
  X_WEB_AGENT_NAME in VARCHAR2,
  X_WEB_HTML_CALL in VARCHAR2,
  X_WEB_ENCRYPT_PARAMETERS in VARCHAR2,
  X_WEB_SECURED in VARCHAR2,
  X_WEB_ICON in VARCHAR2,
  X_OBJECT_NAME in VARCHAR2,
  X_REGION_APPLICATION_NAME in VARCHAR2,
  X_REGION_CODE in VARCHAR2,
  X_USER_FUNCTION_NAME in VARCHAR2,
  X_DESCRIPTION in VARCHAR2,
  X_OWNER in VARCHAR2,
  X_CUSTOM_MODE in VARCHAR2,
  X_LAST_UPDATE_DATE in VARCHAR2,
  X_MAINTENANCE_MODE_SUPPORT in VARCHAR2, /* NULL='NONE' */
  X_CONTEXT_DEPENDENCE in VARCHAR2,       /* NULL='RESP' */
  X_JRAD_REF_PATH in VARCHAR2 default NULL
) is
 -- The following four variables could be null;
 app_id  number;
 rapp_id number;
 frm_id  number;
 obj_id  number;
 fun_id  number;
 row_id varchar2(64);
 f_luby    number;  -- entity owner in file
 f_ludate  date;    -- entity update date in file
 db_luby   number;  -- entity owner in db
 db_ludate date;    -- entity update date in db
 l_form_name varchar2(4000); -- bug2438503
 l_object_name varchar2(4000); -- bug2438503
 l_region_application_name varchar2(4000); -- bug2438503
 l_parameters varchar2(4000); --bug2662933 added the following variables.
 l_web_host_name varchar2(4000);
 l_web_agent_name varchar2(4000);
 l_web_html_call varchar2(4000);
 l_web_encrypt_parameters varchar2(4000);
 l_web_secured varchar2(4000);
 l_web_icon varchar2(4000);
 l_region_code  varchar2(4000);

 L_MAINTENANCE_MODE_SUPPORT VARCHAR2(8) := X_MAINTENANCE_MODE_SUPPORT;
 L_CONTEXT_DEPENDENCE VARCHAR2(8) := X_CONTEXT_DEPENDENCE;

 -- added for adding new column JRAD_REF_PATH for bug 2747925
 L_JRAD_REF_PATH VARCHAR2(1000) := X_JRAD_REF_PATH;

begin
  if (L_MAINTENANCE_MODE_SUPPORT is NULL) then
    L_MAINTENANCE_MODE_SUPPORT := 'NONE';
  end if;

  if (L_CONTEXT_DEPENDENCE is NULL) then
    L_CONTEXT_DEPENDENCE := 'RESP';
  end if;


  begin
    select application_id into app_id
    from   fnd_application
    where  application_short_name = X_APPLICATION_SHORT_NAME;
  exception when no_data_found then
    app_id := null;
  end;

  -- Bug2662933 Get possible null values before calling UPDATE_ROW.

  select decode(X_PARAMETERS, fnd_load_util.null_value, null,
                null, X_PARAMETERS, X_PARAMETERS),
         decode(X_WEB_HOST_NAME, fnd_load_util.null_value, null,
                null, X_WEB_HOST_NAME, X_WEB_HOST_NAME),
         decode(X_WEB_AGENT_NAME, fnd_load_util.null_value, null,
		null, X_WEB_AGENT_NAME, X_WEB_AGENT_NAME),
         decode(X_WEB_HTML_CALL, fnd_load_util.null_value, null,
		null, X_WEB_HTML_CALL, X_WEB_HTML_CALL),
         decode(X_WEB_ENCRYPT_PARAMETERS, fnd_load_util.null_value, null,
		null, X_WEB_ENCRYPT_PARAMETERS, X_WEB_ENCRYPT_PARAMETERS),
         decode(X_WEB_SECURED, fnd_load_util.null_value, null,
		null, X_WEB_SECURED, X_WEB_SECURED),
	 decode(X_WEB_ICON, fnd_load_util.null_value, null,
		null, X_WEB_ICON, X_WEB_ICON),
	 decode(X_REGION_CODE, fnd_load_util.null_value, null,
		null, X_REGION_CODE, X_REGION_CODE),
	 decode(X_JRAD_REF_PATH, fnd_load_util.null_value, null,
		null, X_JRAD_REF_PATH, X_JRAD_REF_PATH)
         into l_parameters, l_web_host_name, l_web_agent_name,
	      l_web_html_call, l_web_encrypt_parameters, l_web_secured,
              l_web_icon, l_region_code, L_JRAD_REF_PATH
         from dual;

  select decode(X_FORM_NAME,
                fnd_load_util.null_value, null,
                null, X_FORM_NAME,
                X_FORM_NAME) into l_form_name from dual;

  if (l_form_name is not null) then
   begin
    select form_id into frm_id
    from fnd_form
    where form_name = X_FORM_NAME
    and   application_id = app_id;
   exception when no_data_found then
    frm_id := null;
   end;
  else frm_id := null;
  end if;

  select decode(X_OBJECT_NAME,
                fnd_load_util.null_value, null,
                null, X_OBJECT_NAME,
                X_OBJECT_NAME) into l_object_name from dual;

  if (l_object_name is not null) then
   begin
    select object_id into obj_id
    from fnd_objects
    where obj_name = X_OBJECT_NAME;
   exception when no_data_found then
    obj_id := null;
   end;
  else obj_id := null;
  end if;

  select decode(X_REGION_APPLICATION_NAME,
                fnd_load_util.null_value, null,
                null, X_REGION_APPLICATION_NAME,
                X_REGION_APPLICATION_NAME)
         into l_region_application_name from dual;

  if (l_region_application_name is not null) then
   begin
    select application_id into rapp_id
    from   fnd_application
    where  application_short_name = X_REGION_APPLICATION_NAME;
   exception when no_data_found then
    rapp_id := null;
   end;
  else rapp_id := null;
  end if;

  -- Translate owner to file_last_updated_by
  f_luby := fnd_load_util.owner_id(x_owner);

  -- Translate char last_update_date to date
  f_ludate := nvl(to_date(x_last_update_date, 'YYYY/MM/DD'), sysdate);

  select function_id, last_updated_by, last_update_date
  into fun_id, db_luby, db_ludate
  from fnd_form_functions
  where function_name = X_FUNCTION_NAME;

  if (fnd_load_util.upload_test(f_luby, f_ludate, db_luby,
                                db_ludate, X_CUSTOM_MODE)) then
    fnd_form_functions_pkg.UPDATE_ROW (
       X_FUNCTION_ID            => fun_id,
       X_WEB_HOST_NAME          => l_WEB_HOST_NAME,
       X_WEB_AGENT_NAME         => l_WEB_AGENT_NAME,
       X_WEB_HTML_CALL          => l_WEB_HTML_CALL,
       X_WEB_ENCRYPT_PARAMETERS => l_WEB_ENCRYPT_PARAMETERS,
       X_WEB_SECURED            => l_WEB_SECURED,
       X_WEB_ICON               => l_WEB_ICON,
       X_OBJECT_ID              => obj_id,
       X_REGION_APPLICATION_ID  => rapp_id,
       X_REGION_CODE            => l_REGION_CODE,
       X_FUNCTION_NAME          => X_FUNCTION_NAME,
       X_APPLICATION_ID         => app_id,
       X_FORM_ID                => frm_id,
       X_PARAMETERS             => l_PARAMETERS,
       X_TYPE                   => X_TYPE,
       X_USER_FUNCTION_NAME     => X_USER_FUNCTION_NAME,
       X_DESCRIPTION            => X_DESCRIPTION,
       X_LAST_UPDATE_DATE       => f_ludate,
       X_LAST_UPDATED_BY        => f_luby,
       X_LAST_UPDATE_LOGIN      => 0,
       X_MAINTENANCE_MODE_SUPPORT => L_MAINTENANCE_MODE_SUPPORT,
       X_CONTEXT_DEPENDENCE       => L_CONTEXT_DEPENDENCE,
       X_JRAD_REF_PATH          => L_JRAD_REF_PATH);
  end if;

  exception
    when NO_DATA_FOUND then

      select fnd_form_functions_s.nextval into fun_id from dual;

      fnd_form_functions_pkg.INSERT_ROW(
       X_ROWID                  => row_id,
       X_FUNCTION_ID            => fun_id,
       X_WEB_HOST_NAME          => l_WEB_HOST_NAME,
       X_WEB_AGENT_NAME         => l_WEB_AGENT_NAME,
       X_WEB_HTML_CALL          => l_WEB_HTML_CALL,
       X_WEB_ENCRYPT_PARAMETERS => l_WEB_ENCRYPT_PARAMETERS,
       X_WEB_SECURED            => l_WEB_SECURED,
       X_WEB_ICON               => l_WEB_ICON,
       X_OBJECT_ID              => obj_id,
       X_REGION_APPLICATION_ID  => rapp_id,
       X_REGION_CODE            => l_REGION_CODE,
       X_FUNCTION_NAME          => X_FUNCTION_NAME,
       X_APPLICATION_ID         => app_id,
       X_FORM_ID                => frm_id,
       X_PARAMETERS             => l_PARAMETERS,
       X_TYPE                   => X_TYPE,
       X_USER_FUNCTION_NAME     => X_USER_FUNCTION_NAME,
       X_DESCRIPTION            => X_DESCRIPTION,
       X_CREATION_DATE          => f_ludate,
       X_CREATED_BY             => f_luby,
       X_LAST_UPDATE_DATE       => f_ludate,
       X_LAST_UPDATED_BY        => f_luby,
       X_LAST_UPDATE_LOGIN      => 0,
       X_MAINTENANCE_MODE_SUPPORT => L_MAINTENANCE_MODE_SUPPORT,
       X_CONTEXT_DEPENDENCE       => L_CONTEXT_DEPENDENCE,
       X_JRAD_REF_PATH          => L_JRAD_REF_PATH);
end LOAD_ROW;

procedure DELETE_ROW (
  X_FUNCTION_ID in NUMBER
) is
begin
  delete from FND_FORM_FUNCTIONS
  where FUNCTION_ID = X_FUNCTION_ID;

	if (sql%notfound) then
		raise no_data_found;
	else
		-- This means that a function was deleted.
		-- Added for Function Security Cache Invalidation Project
		fnd_function_security_cache.delete_function(X_FUNCTION_ID);
	end if;

  delete from FND_FORM_FUNCTIONS_TL
  where FUNCTION_ID = X_FUNCTION_ID;

  if (sql%notfound) then
    raise no_data_found;
  end if;
end DELETE_ROW;

procedure ADD_LANGUAGE
is
begin
/* Mar/19/03 requested by Ric Ginsberg */
/* The following delete and update statements are commented out */
/* as a quick workaround to fix the time-consuming table handler issue */
/* Eventually we'll need to turn them into a separate fix_language procedure */
/*

  delete from FND_FORM_FUNCTIONS_TL T
  where not exists
    (select NULL
    from FND_FORM_FUNCTIONS B
    where B.FUNCTION_ID = T.FUNCTION_ID
    );

  update FND_FORM_FUNCTIONS_TL T set (
      USER_FUNCTION_NAME,
      DESCRIPTION
    ) = (select
      B.USER_FUNCTION_NAME,
      B.DESCRIPTION
    from FND_FORM_FUNCTIONS_TL B
    where B.FUNCTION_ID = T.FUNCTION_ID
    and B.LANGUAGE = T.SOURCE_LANG)
  where (
      T.FUNCTION_ID,
      T.LANGUAGE
  ) in (select
      SUBT.FUNCTION_ID,
      SUBT.LANGUAGE
    from FND_FORM_FUNCTIONS_TL SUBB, FND_FORM_FUNCTIONS_TL SUBT
    where SUBB.FUNCTION_ID = SUBT.FUNCTION_ID
    and SUBB.LANGUAGE = SUBT.SOURCE_LANG
    and (SUBB.USER_FUNCTION_NAME <> SUBT.USER_FUNCTION_NAME
      or SUBB.DESCRIPTION <> SUBT.DESCRIPTION
      or (SUBB.DESCRIPTION is null and SUBT.DESCRIPTION is not null)
      or (SUBB.DESCRIPTION is not null and SUBT.DESCRIPTION is null)
  ));
*/

  insert /*+ append parallel(TT) */ into
  FND_FORM_FUNCTIONS_TL TT(
    FUNCTION_ID,
    USER_FUNCTION_NAME,
    CREATION_DATE,
    CREATED_BY,
    LAST_UPDATE_DATE,
    LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN,
    DESCRIPTION,
    LANGUAGE,
    SOURCE_LANG
  ) select /*+ parallel(V) parallel(T) use_nl(T)  */ V.* from
    (   select /*+ no_merge ordered parallel(B) */
             B.FUNCTION_ID,
             B.USER_FUNCTION_NAME,
             B.CREATION_DATE,
             B.CREATED_BY,
             B.LAST_UPDATE_DATE,
             B.LAST_UPDATED_BY,
             B.LAST_UPDATE_LOGIN,
             B.DESCRIPTION,
             L.LANGUAGE_CODE,
             B.SOURCE_LANG
         from FND_FORM_FUNCTIONS_TL B, FND_LANGUAGES L
         where L.INSTALLED_FLAG in ('I', 'B')
         and B.LANGUAGE = userenv('LANG')
    )V,  FND_FORM_FUNCTIONS_TL T
    where T.function_id(+) = V.function_id
    and   T.language(+) = V.language_code
    and   T.function_id is NULL;
end ADD_LANGUAGE;

/* Overloaded version below */
procedure TRANSLATE_ROW (
  X_FUNCTION_ID in NUMBER,
  X_USER_FUNCTION_NAME in VARCHAR2,
  X_DESCRIPTION in VARCHAR2,
  X_OWNER in VARCHAR2,
  X_CUSTOM_MODE in VARCHAR2
) is
begin
  fnd_form_functions_pkg.TRANSLATE_ROW (
    X_FUNCTION_ID => X_FUNCTION_ID,
    X_USER_FUNCTION_NAME => X_USER_FUNCTION_NAME,
    X_DESCRIPTION => X_DESCRIPTION,
    X_OWNER => X_OWNER,
    X_CUSTOM_MODE => X_CUSTOM_MODE,
    X_LAST_UPDATE_DATE => null
  );
end TRANSLATE_ROW;

/* Overloaded version above */
procedure TRANSLATE_ROW (
  X_FUNCTION_ID in NUMBER,
  X_USER_FUNCTION_NAME in VARCHAR2,
  X_DESCRIPTION in VARCHAR2,
  X_OWNER in VARCHAR2,
  X_CUSTOM_MODE in VARCHAR2,
  X_LAST_UPDATE_DATE in VARCHAR2
) is
  f_luby    number;  -- entity owner in file
  f_ludate  date;    -- entity update date in file
  db_luby   number;  -- entity owner in db
  db_ludate date;    -- entity update date in db
begin
  -- Translate owner to file_last_updated_by
  f_luby := fnd_load_util.owner_id(x_owner);

  -- Translate char last_update_date to date
  f_ludate := nvl(to_date(x_last_update_date, 'YYYY/MM/DD'), sysdate);

  select LAST_UPDATED_BY, LAST_UPDATE_DATE
  into db_luby, db_ludate
  from FND_FORM_FUNCTIONS_TL
  where FUNCTION_ID = X_FUNCTION_ID
  and userenv('LANG') = LANGUAGE;

  if (fnd_load_util.upload_test(f_luby, f_ludate, db_luby,
                                db_ludate, X_CUSTOM_MODE)) then
    update FND_FORM_FUNCTIONS_TL set
      USER_FUNCTION_NAME = X_USER_FUNCTION_NAME,
      DESCRIPTION = X_DESCRIPTION,
      LAST_UPDATE_DATE = f_ludate,
      LAST_UPDATED_BY = f_luby,
      LAST_UPDATE_LOGIN = 0,
      SOURCE_LANG = userenv('LANG')
    where FUNCTION_ID = X_FUNCTION_ID
    and userenv('LANG') in (LANGUAGE, SOURCE_LANG);
  end if;

  if (sql%notfound) then
    raise no_data_found;
  end if;
end TRANSLATE_ROW;

procedure INSERT_ROW (
  X_ROWID in out nocopy VARCHAR2,
  X_FUNCTION_ID in NUMBER,
  X_WEB_HOST_NAME in VARCHAR2,
  X_WEB_AGENT_NAME in VARCHAR2,
  X_WEB_HTML_CALL in VARCHAR2,
  X_WEB_ENCRYPT_PARAMETERS in VARCHAR2,
  X_WEB_SECURED in VARCHAR2,
  X_WEB_ICON in VARCHAR2,
  X_OBJECT_ID in NUMBER,
  X_REGION_APPLICATION_ID in NUMBER,
  X_REGION_CODE in VARCHAR2,
  X_FUNCTION_NAME in VARCHAR2,
  X_APPLICATION_ID in NUMBER,
  X_FORM_ID in NUMBER,
  X_PARAMETERS in VARCHAR2,
  X_TYPE in VARCHAR2,
  X_USER_FUNCTION_NAME in VARCHAR2,
  X_DESCRIPTION in VARCHAR2,
  X_CREATION_DATE in DATE,
  X_CREATED_BY in NUMBER,
  X_LAST_UPDATE_DATE in DATE,
  X_LAST_UPDATED_BY in NUMBER,
  X_LAST_UPDATE_LOGIN in NUMBER,
  X_MAINTENANCE_MODE_SUPPORT in VARCHAR2, /* NULL='NONE' */
  X_CONTEXT_DEPENDENCE in VARCHAR2,       /* NULL='RESP' */
  X_JRAD_REF_PATH in VARCHAR2 default NULL
) is
  cursor C is select ROWID from FND_FORM_FUNCTIONS
    where FUNCTION_ID = X_FUNCTION_ID;
  L_MAINTENANCE_MODE_SUPPORT VARCHAR2(8) := X_MAINTENANCE_MODE_SUPPORT;
  L_CONTEXT_DEPENDENCE VARCHAR2(8) := X_CONTEXT_DEPENDENCE;

  -- Function type validation purpose arguments
  L_APPLICATION_ID NUMBER;
  L_FORM_ID NUMBER;
  L_TYPE  VARCHAR2(30);
  L_PARAMETERS  VARCHAR2(2000);
  L_WEB_HTML_CALL  VARCHAR2(240);
  L_REGION_APPLICATION_ID  NUMBER;
  L_REGION_CODE  VARCHAR2(30);
  columns_name VARCHAR2(2000);

begin
  if (L_MAINTENANCE_MODE_SUPPORT is NULL) then
    L_MAINTENANCE_MODE_SUPPORT := 'NONE';
  end if;

  if (L_CONTEXT_DEPENDENCE is NULL) then
    L_CONTEXT_DEPENDENCE := 'RESP';
  end if;

  -- Function type validation
  L_APPLICATION_ID := X_APPLICATION_ID;
  L_FORM_ID := X_FORM_ID;
  L_TYPE := X_TYPE;
  L_PARAMETERS := X_PARAMETERS;
  L_WEB_HTML_CALL := X_WEB_HTML_CALL;
  L_REGION_APPLICATION_ID := X_REGION_APPLICATION_ID;
  L_REGION_CODE := X_REGION_CODE;

  columns_name := FUNCTION_VALIDATION(L_APPLICATION_ID,
                      L_FORM_ID,
                      L_TYPE,
                      L_PARAMETERS,
                      L_WEB_HTML_CALL,
                      X_WEB_HOST_NAME,
                      L_REGION_APPLICATION_ID,
                      L_REGION_CODE,
                      X_FUNCTION_NAME);

  insert into FND_FORM_FUNCTIONS (
    WEB_ICON,
    WEB_HOST_NAME,
    WEB_AGENT_NAME,
    WEB_HTML_CALL,
    WEB_ENCRYPT_PARAMETERS,
    WEB_SECURED,
    OBJECT_ID,
    REGION_APPLICATION_ID,
    REGION_CODE,
    FUNCTION_ID,
    FUNCTION_NAME,
    APPLICATION_ID,
    FORM_ID,
    PARAMETERS,
    TYPE,
    CREATION_DATE,
    CREATED_BY,
    LAST_UPDATE_DATE,
    LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN,
    MAINTENANCE_MODE_SUPPORT,
    CONTEXT_DEPENDENCE,
    JRAD_REF_PATH
  ) values (
    X_WEB_ICON,
    X_WEB_HOST_NAME,
    X_WEB_AGENT_NAME,
    L_WEB_HTML_CALL,
    X_WEB_ENCRYPT_PARAMETERS,
    X_WEB_SECURED,
    X_OBJECT_ID,
    L_REGION_APPLICATION_ID,
    L_REGION_CODE,
    X_FUNCTION_ID,
    X_FUNCTION_NAME,
    L_APPLICATION_ID,
    L_FORM_ID,
    L_PARAMETERS,
    L_TYPE,
    X_CREATION_DATE,
    X_CREATED_BY,
    X_LAST_UPDATE_DATE,
    X_LAST_UPDATED_BY,
    X_LAST_UPDATE_LOGIN,
    L_MAINTENANCE_MODE_SUPPORT,
    L_CONTEXT_DEPENDENCE,
    X_JRAD_REF_PATH
  );

	-- Added for Function Security Cache Invalidation Project
	fnd_function_security_cache.insert_function(X_FUNCTION_ID);

  if (columns_name is not null) then
    -- print out message about which column has been changed to
    -- meet the function type validation rule
    fnd_message.set_name('FND', 'FUNCTION_TYPE_COLUMNS_CHANGED');
    fnd_message.set_token('NAME', X_FUNCTION_NAME);
    fnd_message.set_token('COLUMNS', columns_name);
  end if;

  insert into FND_FORM_FUNCTIONS_TL (
    FUNCTION_ID,
    USER_FUNCTION_NAME,
    CREATION_DATE,
    CREATED_BY,
    LAST_UPDATE_DATE,
    LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN,
    DESCRIPTION,
    LANGUAGE,
    SOURCE_LANG
  ) select
    X_FUNCTION_ID,
    X_USER_FUNCTION_NAME,
    X_CREATION_DATE,
    X_CREATED_BY,
    X_LAST_UPDATE_DATE,
    X_LAST_UPDATED_BY,
    X_LAST_UPDATE_LOGIN,
    X_DESCRIPTION,
    L.LANGUAGE_CODE,
    userenv('LANG')
  from FND_LANGUAGES L
  where L.INSTALLED_FLAG in ('I', 'B')
  and not exists
    (select NULL
    from FND_FORM_FUNCTIONS_TL T
    where T.FUNCTION_ID = X_FUNCTION_ID
    and T.LANGUAGE = L.LANGUAGE_CODE);

  open c;
  fetch c into X_ROWID;
  if (c%notfound) then
    close c;
    raise no_data_found;
  end if;
  close c;

end INSERT_ROW;

procedure LOCK_ROW (
  X_FUNCTION_ID in NUMBER,
  X_WEB_HOST_NAME in VARCHAR2,
  X_WEB_AGENT_NAME in VARCHAR2,
  X_WEB_HTML_CALL in VARCHAR2,
  X_WEB_ENCRYPT_PARAMETERS in VARCHAR2,
  X_WEB_SECURED in VARCHAR2,
  X_WEB_ICON in VARCHAR2,
  X_OBJECT_ID in NUMBER,
  X_REGION_APPLICATION_ID in NUMBER,
  X_REGION_CODE in VARCHAR2,
  X_FUNCTION_NAME in VARCHAR2,
  X_APPLICATION_ID in NUMBER,
  X_FORM_ID in NUMBER,
  X_PARAMETERS in VARCHAR2,
  X_TYPE in VARCHAR2,
  X_USER_FUNCTION_NAME in VARCHAR2,
  X_DESCRIPTION in VARCHAR2,
  X_MAINTENANCE_MODE_SUPPORT in VARCHAR2, /* NULL='NONE' */
  X_CONTEXT_DEPENDENCE in VARCHAR2,       /* NULL='RESP' */
  X_JRAD_REF_PATH in VARCHAR2 default NULL

) is
  cursor c is select
      WEB_ICON,
      WEB_HOST_NAME,
      WEB_AGENT_NAME,
      WEB_HTML_CALL,
      WEB_ENCRYPT_PARAMETERS,
      WEB_SECURED,
      OBJECT_ID,
      REGION_APPLICATION_ID,
      REGION_CODE,
      FUNCTION_NAME,
      APPLICATION_ID,
      FORM_ID,
      PARAMETERS,
      TYPE,
      MAINTENANCE_MODE_SUPPORT,
      CONTEXT_DEPENDENCE,
      JRAD_REF_PATH
    from FND_FORM_FUNCTIONS
    where FUNCTION_ID = X_FUNCTION_ID
    for update of FUNCTION_ID nowait;
  recinfo c%rowtype;

  cursor c1 is select
      USER_FUNCTION_NAME,
      DESCRIPTION
    from FND_FORM_FUNCTIONS_TL
    where FUNCTION_ID = X_FUNCTION_ID
    and LANGUAGE = userenv('LANG')
    for update of FUNCTION_ID nowait;
  tlinfo c1%rowtype;

  L_MAINTENANCE_MODE_SUPPORT VARCHAR2(8) := X_MAINTENANCE_MODE_SUPPORT;
  L_CONTEXT_DEPENDENCE VARCHAR2(8) := X_CONTEXT_DEPENDENCE;
begin
  if (L_MAINTENANCE_MODE_SUPPORT is NULL) then
    L_MAINTENANCE_MODE_SUPPORT := 'NONE';
  end if;

  if (L_CONTEXT_DEPENDENCE is NULL) then
    L_CONTEXT_DEPENDENCE := 'RESP';
  end if;

  open c;
  fetch c into recinfo;
  if (c%notfound) then
    close c;
    fnd_message.set_name('FND', 'FORM_RECORD_DELETED');
    app_exception.raise_exception;
  end if;
  close c;
  if (    ((recinfo.WEB_ICON = X_WEB_ICON)
           OR ((recinfo.WEB_ICON is null) AND (X_WEB_ICON is null)))
      AND ((recinfo.WEB_HOST_NAME = X_WEB_HOST_NAME)
           OR ((recinfo.WEB_HOST_NAME is null) AND (X_WEB_HOST_NAME is null)))
      AND ((recinfo.WEB_AGENT_NAME = X_WEB_AGENT_NAME)
           OR ((recinfo.WEB_AGENT_NAME is null) AND (X_WEB_AGENT_NAME is null)))
      AND ((recinfo.WEB_HTML_CALL = X_WEB_HTML_CALL)
           OR ((recinfo.WEB_HTML_CALL is null) AND (X_WEB_HTML_CALL is null)))
      AND ((recinfo.WEB_ENCRYPT_PARAMETERS = X_WEB_ENCRYPT_PARAMETERS)
           OR ((recinfo.WEB_ENCRYPT_PARAMETERS is null) AND (X_WEB_ENCRYPT_PARAMETERS is null)))
      AND ((recinfo.WEB_SECURED = X_WEB_SECURED)
           OR ((recinfo.WEB_SECURED is null) AND (X_WEB_SECURED is null)))
      AND ((recinfo.OBJECT_ID = X_OBJECT_ID)
           OR ((recinfo.OBJECT_ID is null) AND (X_OBJECT_ID is null)))
      AND ((recinfo.REGION_APPLICATION_ID = X_REGION_APPLICATION_ID)
           OR ((recinfo.REGION_APPLICATION_ID is null) AND
               (X_REGION_APPLICATION_ID is null)))
      AND ((recinfo.REGION_CODE = X_REGION_CODE)
           OR ((recinfo.REGION_CODE is null) AND (X_REGION_CODE is null)))
      AND (recinfo.FUNCTION_NAME = X_FUNCTION_NAME)
      AND ((recinfo.APPLICATION_ID = X_APPLICATION_ID)
           OR ((recinfo.APPLICATION_ID is null) AND (X_APPLICATION_ID is null)))
      AND ((recinfo.FORM_ID = X_FORM_ID)
           OR ((recinfo.FORM_ID is null) AND (X_FORM_ID is null)))
      AND ((recinfo.PARAMETERS = X_PARAMETERS)
           OR ((recinfo.PARAMETERS is null) AND (X_PARAMETERS is null)))
      AND ((recinfo.TYPE = X_TYPE)
           OR ((recinfo.TYPE is null) AND (X_TYPE is null)))
      AND (recinfo.MAINTENANCE_MODE_SUPPORT = L_MAINTENANCE_MODE_SUPPORT)
      AND (recinfo.CONTEXT_DEPENDENCE = L_CONTEXT_DEPENDENCE)
      AND ((recinfo.JRAD_REF_PATH = X_JRAD_REF_PATH)
           OR ((recinfo.JRAD_REF_PATH is null) AND (X_JRAD_REF_PATH is null)))
  ) then
    null;
  else
    fnd_message.set_name('FND', 'FORM_RECORD_CHANGED');
    app_exception.raise_exception;
  end if;

  open c1;
  fetch c1 into tlinfo;
  if (c1%notfound) then
    close c1;
    return;
  end if;
  close c1;

  if (    (tlinfo.USER_FUNCTION_NAME = X_USER_FUNCTION_NAME)
      AND ((tlinfo.DESCRIPTION = X_DESCRIPTION)
           OR ((tlinfo.DESCRIPTION is null) AND (X_DESCRIPTION is null)))
  ) then
    null;
  else
    fnd_message.set_name('FND', 'FORM_RECORD_CHANGED');
    app_exception.raise_exception;
  end if;
  return;
end LOCK_ROW;

procedure UPDATE_ROW (
  X_FUNCTION_ID in NUMBER,
  X_WEB_HOST_NAME in VARCHAR2,
  X_WEB_AGENT_NAME in VARCHAR2,
  X_WEB_HTML_CALL in VARCHAR2,
  X_WEB_ENCRYPT_PARAMETERS in VARCHAR2,
  X_WEB_SECURED in VARCHAR2,
  X_WEB_ICON in VARCHAR2,
  X_OBJECT_ID in NUMBER,
  X_REGION_APPLICATION_ID in NUMBER,
  X_REGION_CODE in VARCHAR2,
  X_FUNCTION_NAME in VARCHAR2,
  X_APPLICATION_ID in NUMBER,
  X_FORM_ID in NUMBER,
  X_PARAMETERS in VARCHAR2,
  X_TYPE in VARCHAR2,
  X_USER_FUNCTION_NAME in VARCHAR2,
  X_DESCRIPTION in VARCHAR2,
  X_LAST_UPDATE_DATE in DATE,
  X_LAST_UPDATED_BY in NUMBER,
  X_LAST_UPDATE_LOGIN in NUMBER,
  X_MAINTENANCE_MODE_SUPPORT in VARCHAR2, /* NULL='NONE' */
  X_CONTEXT_DEPENDENCE in VARCHAR2,       /* NULL='RESP' */
  X_JRAD_REF_PATH in VARCHAR2 default NULL
) is
  L_MAINTENANCE_MODE_SUPPORT VARCHAR2(8) := X_MAINTENANCE_MODE_SUPPORT;
  L_CONTEXT_DEPENDENCE VARCHAR2(8) := X_CONTEXT_DEPENDENCE;
  -- Function type validation purpose arguments
  L_APPLICATION_ID NUMBER;
  L_FORM_ID NUMBER;
  L_TYPE  VARCHAR2(30);
  L_PARAMETERS  VARCHAR2(2000);
  L_WEB_HTML_CALL  VARCHAR2(240);
  L_REGION_APPLICATION_ID  NUMBER;
  L_REGION_CODE  VARCHAR2(30);
  columns_name VARCHAR2(2000);
begin
  if (L_MAINTENANCE_MODE_SUPPORT is NULL) then
    L_MAINTENANCE_MODE_SUPPORT := 'NONE';
  end if;

  if (L_CONTEXT_DEPENDENCE is NULL) then
    L_CONTEXT_DEPENDENCE := 'RESP';
  end if;

  -- Function type validation
  L_APPLICATION_ID := X_APPLICATION_ID;
  L_FORM_ID := X_FORM_ID;
  L_TYPE := X_TYPE;
  L_PARAMETERS := X_PARAMETERS;
  L_WEB_HTML_CALL := X_WEB_HTML_CALL;
  L_REGION_APPLICATION_ID := X_REGION_APPLICATION_ID;
  L_REGION_CODE := X_REGION_CODE;

  columns_name := FUNCTION_VALIDATION(L_APPLICATION_ID,
                      L_FORM_ID,
                      L_TYPE,
                      L_PARAMETERS,
                      L_WEB_HTML_CALL,
                      X_WEB_HOST_NAME,
                      L_REGION_APPLICATION_ID,
                      L_REGION_CODE,
                      X_FUNCTION_NAME);

  update FND_FORM_FUNCTIONS set
    WEB_ICON = X_WEB_ICON,
    WEB_HOST_NAME = X_WEB_HOST_NAME,
    WEB_AGENT_NAME = X_WEB_AGENT_NAME,
    WEB_HTML_CALL = L_WEB_HTML_CALL,
    WEB_ENCRYPT_PARAMETERS = X_WEB_ENCRYPT_PARAMETERS,
    WEB_SECURED = X_WEB_SECURED,
    OBJECT_ID = X_OBJECT_ID,
    REGION_APPLICATION_ID = L_REGION_APPLICATION_ID,
    REGION_CODE = L_REGION_CODE,
    APPLICATION_ID = L_APPLICATION_ID,
    FORM_ID = L_FORM_ID,
    PARAMETERS = L_PARAMETERS,
    TYPE = L_TYPE,
    LAST_UPDATE_DATE = X_LAST_UPDATE_DATE,
    LAST_UPDATED_BY = X_LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN = X_LAST_UPDATE_LOGIN,
    MAINTENANCE_MODE_SUPPORT = L_MAINTENANCE_MODE_SUPPORT,
    CONTEXT_DEPENDENCE = L_CONTEXT_DEPENDENCE,
    JRAD_REF_PATH = X_JRAD_REF_PATH
  where FUNCTION_ID = X_FUNCTION_ID;

  if (columns_name is not null) then
    -- print out message about which column has been changed to
    -- meet the function type validation rule
    fnd_message.set_name('FND', 'FUNCTION_TYPE_COLUMNS_CHANGED');
    fnd_message.set_token('NAME', X_FUNCTION_NAME);
    fnd_message.set_token('COLUMNS', columns_name);
  end if;

  if (sql%notfound) then
    raise no_data_found;
  else
	-- This means that a function was updated.
	-- Added for Function Security Cache Invalidation Project
    fnd_function_security_cache.update_function(X_FUNCTION_ID);
end if;

  update FND_FORM_FUNCTIONS_TL set
    USER_FUNCTION_NAME = X_USER_FUNCTION_NAME,
    DESCRIPTION = X_DESCRIPTION,
    LAST_UPDATE_DATE = X_LAST_UPDATE_DATE,
    LAST_UPDATED_BY = X_LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN = X_LAST_UPDATE_LOGIN,
    SOURCE_LANG = userenv('LANG')
  where FUNCTION_ID = X_FUNCTION_ID
  and userenv('LANG') in (LANGUAGE, SOURCE_LANG);

  if (sql%notfound) then
    raise no_data_found;
  end if;
end UPDATE_ROW;

procedure SET_FUNCTION_MODE (x_function_name in varchar2,
                             x_function_mode in varchar2) is
  valid_mode number;
begin
  if (x_function_name is null) then
    return;
  end if;

  -- Validate the function maintenance mode
  begin
    select 1 into valid_mode
    from dual
    where x_function_mode in (
      select lv.lookup_code
      from fnd_lookup_values lv
      where lv.lookup_type = 'APPS_MAINTENANCE_MODE_SUPPORT'
      and lv.language = userenv('LANG'));
  exception
    when no_data_found then
      fnd_message.set_name('FND', 'FND_INVALID_MAINTENANCE_MODE');
      fnd_message.set_token('MODE', x_function_mode);
      app_exception.raise_exception;
  end;

  update fnd_form_functions
  set maintenance_mode_support = x_function_mode
  where function_name like x_function_name;

  -- Function name does not exist
  if (sql%notfound) then
      fnd_message.set_name('FND', 'FND_FUNCTION_NOT_FOUND');
      fnd_message.set_token('NAME', x_function_name);
      app_exception.raise_exception;
  end if;


end SET_FUNCTION_MODE;



end FND_FORM_FUNCTIONS_PKG;

/
