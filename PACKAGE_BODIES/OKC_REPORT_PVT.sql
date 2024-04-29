--------------------------------------------------------
--  DDL for Package Body OKC_REPORT_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OKC_REPORT_PVT" as
/* $Header: OKCRXPKB.pls 120.3 2005/08/16 16:35:18 jkodiyan noship $ */

	l_debug VARCHAR2(1) := NVL(FND_PROFILE.VALUE('AFLOG_ENABLED'),'N');

--
--    Print Contract Process API methods
--
--      get_xsl_help
--      get_art_help
--      get_xml
--      get_htm
--	set_env
--      get_contract_url
--	check_access
--	transformation_error
--	check_transf_path
--	exec_OKC_WEB_PRERUN
--	prerun
--	exec_OKC_WEB_LOG_RUN
--	noop
--	free_temp_clob
--	get_k_version
--

--
--    Dependencies:
--
--	okc_tree_index 	(.set_root_id)
--	wf_mail		(.urlencode)
--
--	okcFormsXmlPrint.jsp (former okcxmlkf.jsp) - print xml contract
--
--    Profile values used:
--
--	OKC_WEB_ENVPROC
--	OKC_WEB_LOG_RUN
--	OKC_WEB_REPORT
--	OKC_WEB_PRERUN
--

--
--    Messages used  		with tokens
--
--	OKC_PROFILE_CHECK	PROFILE
--	OKC_NOT_CACHED_TRANSF	METHOD
--	OKC_CACHE_LOCKED	CACHE_TYPE
--	OKC_TRANSF_ERROR	TRANSF_TYPE, TRANSF_NAME
--	OKC_INACTIVE_TRANSF	TRANSF_TYPE, TRANSF_NAME, PROFILE
--

	G_kid number;
	G_vid number;
	G_mid number;
	G_xid number;

	G_sql_id number;


	G_ignore_cache varchar2(1);

--
--  PROCEDURE/Function
--    private EncodeString
--
--  PURPOSE
--    escapes '&' and '<'
--
  function EncodeString(p_string varchar2) return varchar2
  is
    encoded_string varchar2(4000);
  begin
    encoded_string := p_string;
    encoded_string := replace(encoded_string, '&', '&'||'amp;' );
    encoded_string := replace(encoded_string, '<', '&'||'lt;' );
    return(encoded_string);
  end EncodeString;

--
--  PROCEDURE/Function
--    private EncodeClob
--
--  PURPOSE
--    escapes '&' and '<'
--
  function EncodeClob(r_clob in out nocopy clob, p_title varchar2) return clob
  is
    r_len integer;
    w_clob CLOB;
    w_len integer;
    offset integer := 1;
    buff varchar2(4000);
  begin
    DBMS_LOB.OPEN(lob_loc => r_clob, open_mode => DBMS_LOB.LOB_READONLY);
    r_len := DBMS_LOB.getlength(lob_loc => r_clob);
    DBMS_LOB.CREATETEMPORARY(lob_loc => w_clob, cache => FALSE, dur => DBMS_LOB.CALL);
    DBMS_LOB.OPEN(lob_loc => w_clob,open_mode =>  DBMS_LOB.LOB_READWRITE);
    buff := '<html><head><title>"?" -> '||p_title||'</title></head><body><pre>';
    DBMS_LOB.writeappend(lob_loc => w_clob, amount => length(buff),buffer => buff);
    buff := NULL;
    WHILE (r_len > 0) LOOP
      buff := DBMS_LOB.substr(lob_loc => r_clob,amount => least(r_len,800),offset => offset);
      buff := EncodeString(buff);
      DBMS_LOB.writeappend(lob_loc => w_clob,amount => length(buff),buffer => buff);
      buff := NULL;
      r_len := r_len-least(r_len,800);
      offset := offset+800;
    END LOOP;
    buff := '</pre></body></html>';
    DBMS_LOB.writeappend(lob_loc => w_clob,amount =>length(buff),buffer =>buff);
    DBMS_LOB.CLOSE(lob_loc => r_clob);
    DBMS_LOB.CLOSE(lob_loc => w_clob);
    return w_clob;
  end;

--
--  PROCEDURE/Function
--    private EncodeClob
--
--  PURPOSE
--    overload previous procedure if clob is empty
--
  function EncodeClob(p_title varchar2, p_message varchar2) return clob
  is
    w_clob CLOB;
    w_len integer;
    offset integer := 1;
    buff varchar2(4000);
  begin
    DBMS_LOB.CREATETEMPORARY(lob_loc => w_clob,cache => FALSE,dur => DBMS_LOB.CALL);
    DBMS_LOB.OPEN(lob_loc =>w_clob, open_mode => DBMS_LOB.LOB_READWRITE);
    buff := '<html><head><title>"?" -> '||p_title||'</title></head><body><pre>';
    DBMS_LOB.writeappend(lob_loc => w_clob,amount =>length(buff),buffer => buff);
    buff := NULL;
    if (p_title is NULL) then
      DBMS_LOB.writeappend(lob_loc => w_clob,amount =>length(p_message),buffer =>p_message);
    end if;
    buff := '</pre></body></html>';
    DBMS_LOB.writeappend(lob_loc => w_clob,amount => length(buff),buffer => buff);
    DBMS_LOB.CLOSE(lob_loc =>w_clob);
    return w_clob;
  end;

--
--  PROCEDURE/Function
--    private profile_check_msg
--
--  PURPOSE
--    returns OKC_PROFILE_CHECK message
--    with user name of p_prof_name option value
--
  function profile_check_msg(p_prof_name varchar2) return varchar2
  is
    l_message varchar2(2000);
    l_token varchar2(240);
    cursor profile_option_csr(p_profile_option varchar2) is
      select USER_PROFILE_OPTION_NAME
      from fnd_profile_options_vl
      where application_id=510
      and PROFILE_OPTION_NAME = p_profile_option;
  begin
    open profile_option_csr(p_prof_name);
    fetch profile_option_csr into l_token;
    close profile_option_csr;
    fnd_message.clear;
    fnd_message.set_name(APPLICATION=>'OKC',NAME=>'OKC_PROFILE_CHECK');
    fnd_message.set_token(TOKEN=>'PROFILE',VALUE=>'"'||l_token||'"');
    return fnd_message.get;
  end;

--
--  PROCEDURE/Function
--    private get_sql_id
--
--  PURPOSE
--    returns sql_id - id of the query
--    derives it from OKC_WEB_REPORT profile option
--
  function get_sql_id return number
  is
    l_sql_id number;
    cursor c_sql_id is
      select SQL_ID from (
       select SQL_ID, XST_ID
       from OKC_REPORT_XST
       connect by ID = prior XST_ID
       start with ID = fnd_profile.value('OKC_WEB_REPORT')
     ) where SQL_ID is not NULL;
  begin
    open c_sql_id;
    fetch c_sql_id into l_sql_id;
    close c_sql_id;
    return l_sql_id;
  end;

--
--  PROCEDURE/Function
--    private get_xsl_id
--
--  PURPOSE
--    returns xsl_id - stylesheet id
--    derives it from OKC_WEB_REPORT profile option
--
  function get_xsl_id return number
  is
    l_xsl_id number;
    cursor c_xsl_id is
      select XSL_ID
      from OKC_REPORT_XST
     where ID = fnd_profile.value('OKC_WEB_REPORT');
  begin
    open c_xsl_id;
    fetch c_xsl_id into l_xsl_id;
    close c_xsl_id;
    return l_xsl_id;
  end;

--
--  PROCEDURE/Function
--    get_xsl_help
--
--  PURPOSE
--    returns help text for XSL designer in format
--    <html>
--      <head><title>
--        "?" -> okc_report_sql_v.name
--      </title></head>
--      <body><pre>
--        okc_report_sql_v.help_text
--        '&' and '<' replaced with '&'||'amp;' and '&'||'lt;'
--      </pre></body>
--    </html>
--
  function get_xsl_help(
	p_sql_id number   -- if null derive from OKC_WEB_REPORT prof.
  ) return clob
  is
    l_sql_id number;
    l_name varchar2(150);
    l_clob clob;
    cursor c_clob(p_sql number) is
      select name, help_text
      from okc_report_sql_v
      where id = p_sql;
    l_message varchar2(2000);
  begin
    if (p_sql_id is NULL) then
      l_sql_id := get_sql_id;
    else
      l_sql_id := p_sql_id;
    end if;
    open c_clob(l_sql_id);
    fetch c_clob into l_name, l_clob;
    close c_clob;
    if (l_clob is NULL) then
      return EncodeClob(l_name, profile_check_msg('OKC_WEB_REPORT'));
    else
      return EncodeClob(l_clob, l_name);
    end if;
  end;

--
--  PROCEDURE/Function
--    get_art_help
--
--  PURPOSE
--    returns help text for standard atricles designer
--    similar to previous method based on view okc_report_xsl_v
--
  function get_art_help(
	p_xsl_id number   -- if null derive from OKC_WEB_REPORT prof.
  ) return clob
  is
    l_xsl_id number;
    l_name varchar2(150);
    l_clob clob;
    cursor c_clob(p_xsl number) is
      select name, help_text
      from okc_report_xsl_v
      where id = p_xsl;
    l_message varchar2(2000);
  begin
    if (p_xsl_id is NULL) then
      l_xsl_id := get_xsl_id;
    else
      l_xsl_id := p_xsl_id;
    end if;
    open c_clob(l_xsl_id);
    fetch c_clob into l_name, l_clob;
    close c_clob;
    if (l_clob is NULL) then
      return EncodeClob(l_name, profile_check_msg('OKC_WEB_REPORT'));
    else
      return EncodeClob(l_clob, l_name);
    end if;
  end;

--
--  PROCEDURE/Function
--    private not_cached_trans_msg
--
--  PURPOSE
--    returns OKC_NOT_CACHED_TRANSF message
--    with procedure name as METHOD token
--
  function not_cached_transf_msg(p_proc_name varchar2) return varchar2
  is
    l_message varchar2(2000);
    l_token varchar2(240);
  begin
    fnd_message.clear;
    fnd_message.set_name(APPLICATION=>'OKC',NAME=>'OKC_NOT_CACHED_TRANSF');
    fnd_message.set_token(TOKEN=>'METHOD',VALUE=>'"'||p_proc_name||'"');
    return fnd_message.get;
  end;

--
--  PROCEDURE/Function
--    private cache_locked_msg
--
--  PURPOSE
--    returns OKC_CACHE_LOCKED message
--    with cache name as CACHE token
--
  function cache_locked_msg(p_cache varchar2) return varchar2
  is
    l_message varchar2(2000);
    l_token varchar2(240);
  begin
    fnd_message.clear;
    fnd_message.set_name(APPLICATION=>'OKC',NAME=>'OKC_CACHE_LOCKED');
    fnd_message.set_token(TOKEN=>'CACHE_TYPE',VALUE=>'"'||p_cache||'"');
    return fnd_message.get;
  end;

--
--  PROCEDURE/Function
--    public get_k_version
--
--  PURPOSE
--    output MAJOR (might be in as well), MINOR vesions
--    to get rid of default, that is last, Contract version
--
-- prior 1158 was   procedure get_k_version(p_chr_id number,

  procedure get_k_version(p_chr_id in out nocopy number,
			x_major_version in out nocopy number,
			x_minor_version out nocopy number) is
  cursor k_version_csr(pp_chr_id number,pp_major_version number) is
    select V.MAJOR_VERSION, V.MINOR_VERSION
    from
      okc_k_vers_numbers_v V
    where V.CHR_ID = pp_chr_id
      and (pp_major_version is NULL or pp_major_version = V.MAJOR_VERSION)
    union all
    select pp_major_version, max(H.MINOR_VERSION) MINOR_VERSION
    from okc_k_vers_numbers_v V1,
      OKC_K_VERS_NUMBERS_H H
    where V1.CHR_ID = pp_chr_id
	  and H.CHR_ID = pp_chr_id
          and H.MAJOR_VERSION = pp_major_version
	  and H.MAJOR_VERSION <> V1.MAJOR_VERSION
    ;
  begin
--1158
    if (p_chr_id is NULL) then
        p_chr_id := get_new_id;
	x_major_version := -1;
	x_minor_version := -1;
        return;
    end if;
--/1158
    open k_version_csr(p_chr_id,x_major_version);
    fetch k_version_csr into x_major_version, x_minor_version;
    close k_version_csr;
  end;

--
--  PROCEDURE/Function
--    get_xml
--
--  PURPOSE
--    should be called only for "cached" sql transformations
--    returns datagram from cache if it is still valid,
--    or updates/inserts clob to put there result on XSQL transformation
--
  procedure get_xml(
    -- standard parameters
	p_api_version in NUMBER ,
	p_init_msg_list	in VARCHAR2 ,
	x_return_status	out NOCOPY VARCHAR2,
	x_msg_count out NOCOPY NUMBER,
	x_msg_data out NOCOPY VARCHAR2,
    -- input parameters
--1158	p_chr_id in NUMBER,
--1158	p_major_version NUMBER ,
--1158	p_sql_id in NUMBER ,
	p_run_anyway_yn in varchar2 ,
    -- output parameters
	x_xml_text out nocopy CLOB,
	x_clob_status out nocopy VARCHAR2
	--'I' - inserted empty, or old and obsolete; locked
	--'V' - valid not locked
	--'N' - not cached
  ) is
    l_sql_id number;
    l_msg_data varchar2(2000);
    l_cached varchar2(1);
    l_sql_date DATE;
    cursor sql_csr(p_xid number) is
      select S.CACHE_YN, S.LAST_UPDATE_DATE, S.id SQL_ID
      from OKC_REPORT_SQL_V S, OKC_REPORT_XST T
      where T.id = p_xid and T.sql_id = S.id
      and sysdate between S.start_date and nvl(S.end_date,sysdate);
    l_dummy varchar2(1);
    cursor xml_csr(	pp_chr_id number,
		pp_major_version number,
		pp_minor_version number,
		pp_sql_id number,
		pp_sql_date date) is
      select '!'
      from
        okc_report_xml_v M
      where M.CHR_ID = pp_chr_id
      and M.MAJOR_VERSION = pp_major_version
      and M.MINOR_VERSION = pp_minor_version
      and M.SQL_ID = pp_sql_id
      and M.LAST_UPDATE_DATE > pp_sql_date
      and M.XML_TEXT is not NULL
    ;
    cursor xml_csr1(	pp_chr_id number,
		pp_major_version number,
		pp_minor_version number,
		pp_sql_id number,
		pp_sql_date date) is
      select M.XML_TEXT
      from
        okc_report_xml_v M
      where M.CHR_ID = pp_chr_id
      and M.MAJOR_VERSION = pp_major_version
      and M.MINOR_VERSION = pp_minor_version
      and M.SQL_ID = pp_sql_id
      and M.LAST_UPDATE_DATE > pp_sql_date
      and M.XML_TEXT is not NULL
    ;
  begin
    DBMS_TRANSACTION.SAVEPOINT('OKC_REPORT_PVT');

    open sql_csr(G_xid);
    fetch sql_csr into l_cached, l_sql_date, l_sql_id;
    close sql_csr;
    if (l_cached is null) then
      x_return_status := 'E';
      x_msg_count := 1;
      l_msg_data := profile_check_msg('OKC_WEB_REPORT');
      x_msg_data := l_msg_data;
      x_xml_text := EncodeClob('Error: OKC_REPORT_PVT.get_xml', l_msg_data);
      x_clob_status := 'I';
      return;
    elsif (l_cached = 'N' or  G_ignore_cache = 'Y') then
      x_return_status := 'S';
      x_clob_status := 'N';
      return;
    end if;

    l_dummy := '?';
    open xml_csr(	G_kid,
		G_vid,
		G_mid,
		l_sql_id,
		l_sql_date);
    fetch xml_csr into l_dummy;
    close xml_csr;
    if (l_dummy = '!' and p_run_anyway_yn = 'N') then
      open xml_csr1(	G_kid,
		G_vid,
		G_mid,
		l_sql_id,
		l_sql_date);
      fetch xml_csr1 into x_xml_text;
      close xml_csr1;
      x_return_status := 'S';
      x_clob_status := 'V';
      return;
    end if;
--
-- obsolete? - lock cache, update everything but clob
--
    begin
        delete from okc_report_xml M
        where M.CHR_ID = G_kid
          and M.MAJOR_VERSION = G_vid
          and M.LANGUAGE = userenv('LANG')
          and M.SQL_ID = l_sql_id
          ;
    exception when others then NULL;
    end;
    insert into okc_report_xml
         (	CHR_ID
		,MAJOR_VERSION
		,LANGUAGE
		,SQL_ID
		,MINOR_VERSION
		,XML_TEXT
		,CREATED_BY
		,CREATION_DATE
		,LAST_UPDATED_BY
		,LAST_UPDATE_DATE
		,LAST_UPDATE_LOGIN
	    ) values
	    (	G_kid,
		G_vid,
		userenv('LANG'),
		l_sql_id,
		G_mid,
		empty_clob(),
		fnd_global.user_id,
		sysdate,
		fnd_global.user_id,
		sysdate,
		fnd_global.login_id
	    );
    select XML_TEXT into x_xml_text
    from okc_report_xml
    where CHR_ID = G_kid
	and MAJOR_VERSION = G_vid
	and LANGUAGE = userenv('LANG')
	and SQL_ID = l_sql_id
    for update of XML_TEXT nowait;
    x_return_status := 'S';
    x_clob_status := 'I';
    return;
  exception when others then
      x_return_status := 'E';
      x_msg_count := 1;
      l_msg_data := cache_locked_msg('XML');
      x_msg_data := l_msg_data;
      x_xml_text := EncodeClob('Error: OKC_REPORT_PVT.get_xml', l_msg_data);
      x_clob_status := 'I';
      DBMS_TRANSACTION.ROLLBACK_SAVEPOINT('OKC_REPORT_PVT');
  end;

--
--  PROCEDURE/Function
--    private get_xsl_sql_date
--
--  PURPOSE
--    returns last update date of the stylesheet
--    (including called stylesheets, if any)
--
  function get_xsl_sql_date(p_xst_id number) return date
  is
    l_date date;
    cursor last_update_csr(p_xst number) is
	select greatest(
		max(S.LAST_UPDATE_DATE),
		max(Q.LAST_UPDATE_DATE),
		max(T.LAST_UPDATE_DATE)) d
	from
	  (select SQL_ID, XSL_ID, LAST_UPDATE_DATE
	   from OKC_REPORT_XST
	   connect by ID = prior XST_ID
	   start with ID = p_xst) T,
	  OKC_REPORT_XSL_V S,
	  OKC_REPORT_SQL_V Q
	where T.XSL_ID = S.ID
	and T.SQL_ID = Q.ID (+);
  begin
    open last_update_csr(p_xst_id);
    fetch last_update_csr into l_date;
    close last_update_csr;
    return l_date;
  end;

--
--  PROCEDURE/Function
--    get_htm
--
--  PURPOSE
--    should be called only for "cached" xsl transformations
--    returns datagram from cache if it is still valid,
--    or updates/inserts clob to put there result on XSL Transformation
--
  procedure get_htm(
    -- standard parameters
	p_api_version in NUMBER ,
	p_init_msg_list	in VARCHAR2 ,
	x_return_status	out NOCOPY VARCHAR2,
	x_msg_count out NOCOPY NUMBER,
	x_msg_data out NOCOPY VARCHAR2,
    -- input parameters
--1158	p_chr_id in NUMBER,
--1158	p_major_version NUMBER ,
--1158	p_xst_id in NUMBER ,
--1158	p_scn_id in NUMBER ,
	p_run_anyway_yn in varchar2 ,
    -- output parameters
	x_htm_text out nocopy CLOB,
	x_clob_status out nocopy VARCHAR2
	--'I' - inserted empty, or old and obsolete; locked
	--'V' - valid not locked
	--'N' - not cached
  ) is
    l_msg_data varchar2(2000);
    l_cached varchar2(1);
    l_xst_date DATE;
    cursor xst_csr(p_xst number) is
      select T.CACHE_YN
      from OKC_REPORT_XST_V T, OKC_REPORT_XSL_V L
      where T.id = p_xst
      and T.XSL_ID = L.ID
      and sysdate between L.start_date and nvl(L.end_date,sysdate);
    l_dummy varchar2(1);
    cursor htm_cache_csr(pp_chr_id number,
		pp_major_version number,
		pp_minor_version number,
		pp_xst_id number,
		pp_scn_id number,
		pp_xst_date date) is
      select '!'
      from
        okc_report_htm_v H
      where H.CHR_ID = pp_chr_id
      and H.MAJOR_VERSION = pp_major_version
      and H.MINOR_VERSION = pp_minor_version
      and H.XST_ID = pp_xst_id
      and H.SCN_ID = pp_scn_id
      and H.LAST_UPDATE_DATE > pp_xst_date
      and H.HTM_TEXT is not NULL
    ;
    cursor htm_cache_csr1(	pp_chr_id number,
		pp_major_version number,
		pp_minor_version number,
		pp_xst_id number,
		pp_scn_id number,
		pp_xst_date date) is
      select H.HTM_TEXT
      from
        okc_report_htm_v H
      where H.CHR_ID = pp_chr_id
      and H.MAJOR_VERSION = pp_major_version
      and H.MINOR_VERSION = pp_minor_version
      and H.XST_ID = pp_xst_id
      and H.SCN_ID = pp_scn_id
      and H.LAST_UPDATE_DATE > pp_xst_date
      and H.HTM_TEXT is not NULL
    ;
  begin
    DBMS_TRANSACTION.SAVEPOINT('OKC_REPORT_PVT');

    open xst_csr(G_xid);
    fetch xst_csr into l_cached;
    close xst_csr;
    if (l_cached is null) then
      x_return_status := 'E';
      x_msg_count := 1;
      l_msg_data := profile_check_msg('OKC_WEB_REPORT');
      x_msg_data := l_msg_data;
      x_htm_text := EncodeClob('Error: OKC_REPORT_PVT.get_htm', l_msg_data);
      x_clob_status := 'I';
      return;
    end if;
--
--  find last update in definitions
--
    l_xst_date := get_xsl_sql_date(G_xid);

    l_dummy:='?';
    open htm_cache_csr(	G_kid,
		G_vid,
		G_mid,
		G_xid,
		0,
		l_xst_date);
    fetch htm_cache_csr into l_dummy;
    close htm_cache_csr;
    if (l_dummy = '!' and l_cached = 'Y' and p_run_anyway_yn = 'N' and G_ignore_cache = 'N') then
    open htm_cache_csr1(	G_kid,
		G_vid,
		G_mid,
		G_xid,
		0,
		l_xst_date);
    fetch htm_cache_csr1 into x_htm_text;
    close htm_cache_csr1;
    x_return_status := 'S';
    x_clob_status := 'V';
    return;
    end if;
--
-- obsolete? - lock cache, update everything but clob
--
    begin
        delete from okc_report_htm H
        where H.CHR_ID = G_kid
          and H.MAJOR_VERSION = G_vid
          and H.LANGUAGE = userenv('LANG')
          and H.XST_ID = G_xid
          and H.SCN_ID = 0
          ;
    exception when others then NULL;
    end;
--
-- not found! - insert in cache and lock
--
    insert into okc_report_htm
    (	CHR_ID
	,MAJOR_VERSION
	,LANGUAGE
	,XST_ID
	,SCN_ID
	,MINOR_VERSION
	,HTM_TEXT
	,CREATED_BY
	,CREATION_DATE
	,LAST_UPDATED_BY
	,LAST_UPDATE_DATE
	,LAST_UPDATE_LOGIN
    ) values
    (	G_kid,
	G_vid,
	userenv('LANG'),
	G_xid,
	0,
	G_mid,
	empty_clob(),
	fnd_global.user_id,
	sysdate,
	fnd_global.user_id,
	sysdate,
	fnd_global.login_id
    );
    select HTM_TEXT into x_htm_text
    from okc_report_htm
    where CHR_ID = G_kid
	and MAJOR_VERSION = G_vid
	and LANGUAGE = userenv('LANG')
	and XST_ID = G_xid
	and SCN_ID = 0
    for update of HTM_TEXT nowait;
    x_return_status := 'S';
    if (G_ignore_cache = 'Y' or l_cached = 'N') then
      x_clob_status := 'N';
    else
      x_clob_status := 'I';
    end if;
    return;
  exception when others then
      x_return_status := 'E';
      x_msg_count := 1;
      l_msg_data := cache_locked_msg('HTM');
      x_msg_data := l_msg_data;
      x_htm_text := EncodeClob('Error: OKC_REPORT_PVT.get_htm', l_msg_data);
      x_clob_status := 'I';
      DBMS_TRANSACTION.ROLLBACK_SAVEPOINT('OKC_REPORT_PVT');
  end;


--
--  PROCEDURE/Function
--    private urlencode
--
--  PURPOSE
--    escapes parameter values
--
  function urlencode (value varchar2) return varchar2 is
  begin
    return replace(replace(WF_MAIL.URLENCODE(value),'\','%5C'),':','%3A');
  end;

--
--  PROCEDURE/Function
--    private failed_lock
--
--  PURPOSE
--    returns "lock failure" translated message
--
  function failed_lock return varchar2
  is
    l_message varchar2(2000);
  begin
    fnd_message.clear;
    fnd_message.set_name(APPLICATION=>OKC_API.G_FND_APP,NAME=>OKC_API.G_FORM_UNABLE_TO_RESERVE_REC);
    return fnd_message.get;
  end;

--
--  PROCEDURE/Function
--    private failed_session
--
--  PURPOSE
--    returns FND_SESSION_FAILED translated message
--
  function failed_session return varchar2
  is
    l_message varchar2(2000);
  begin
    fnd_message.clear;
    fnd_message.set_name(APPLICATION=>'FND',NAME=>'FND_SESSION_FAILED');
    return fnd_message.get;
  end;

--
--  PROCEDURE/Function
--    public set_env
--
--  PURPOSE
--    call only from JSP apllication (not from forms apps)
--
--    dinamicly executes <fnd_profile.value('OKC_WEB_ENVPROC')>
--    besides it sets okc_tree_index.set_root_id(p_kid):
--    SQL statements use okc_tree_index.get_root_id as Contact Id
--
  procedure set_env(p_kid varchar2) is
  cursor c1 is
    select '!' from okc_k_headers_b
    where id=p_kid;
  l_dummy varchar2(1) := '?';
  cursor c2 (p_xid number) is
	select '!'
	from
	  okc_report_xst X,
	  okc_report_prm_v P
	where X.ID = p_xid
	and P.sql_id = X.sql_id
	and P.code not in ('xid', 'kid', 'vid', 'content_type');
    l_value varchar2(200);
  begin
    okc_tree_index.set_root_id(p_kid);
    G_xid := fnd_profile.value('OKC_WEB_REPORT');
    G_kid := p_kid;
    G_vid := OKC_PARAMETERS_PUB.Get('vid');
    get_k_version(G_kid, G_vid, G_mid);
    if (G_vid = -1) then
      G_ignore_cache := 'Y';
    else
      open c2(G_xid);
      fetch c2 into l_dummy;
      close c2;
      if (l_dummy = '!') then
        G_ignore_cache := 'Y';
      else
        G_ignore_cache := 'N';
      end if;
    end if;
    l_dummy := '?';
    open c1;
    fetch c1 into l_dummy;
    close c1;
    l_value := fnd_profile.value('OKC_WEB_ENVPROC');
    if (l_value is NULL or upper(l_value) = 'OKC_CONTEXT.SET_OKC_ORG_CONTEXT') then
      if (l_dummy = '!') then
        okc_context.set_okc_org_context(p_chr_id => p_kid);
      else
        okc_context.set_okc_org_context(p_org_id => NULL, p_organization_id => NULL);
      end if;
    else
      begin
        if (l_dummy = '?') then
          l_value := 'begin '||l_value||';end;';
          execute immediate l_value;
         else
          l_value := 'begin '||l_value||'(:1); end;';
          execute immediate l_value using in p_kid;
        end if;
      exception when others then
        if (l_dummy = '?') then
          l_value := 'begin '||l_value||'(p_chr_id => NULL);end;';
          execute immediate l_value;
        else
          l_value := 'begin '||l_value||'(p_chr_id=> :1); end;';
          execute immediate l_value using in p_kid;
         end if;
      end;
    end if;
  exception
   when others then NULL;
  end set_env;

--
--  PROCEDURE/Function
--    public set_env
--
--  PURPOSE - previous overload with extra in parameter
--            p_xid that is report id to set OKC_WEB_REPORT po
--            if not default report requested
--
--    call only from JSP apllication (not from forms apps)
--
--    dinamicly executes <fnd_profile.value('OKC_WEB_ENVPROC')>
--    besides it sets okc_tree_index.set_root_id(p_kid):
--    SQL statements use okc_tree_index.get_root_id as Contact Id
--
  procedure set_env(
	p_kid varchar2
       ,p_xid varchar2
		) is
  begin
    if (p_xid is not NULL) then
      fnd_profile.put('OKC_WEB_REPORT',p_xid);
    end if;
    set_env(p_kid);
  exception
   when others then NULL;
  end set_env;

--1158
--
--  PROCEDURE/Function
--    public set_env
--
--  PURPOSE - previous overload with request parameter's set
--
--    dinamicly executes <fnd_profile.value('OKC_WEB_ENVPROC')>
--    besides it sets okc_tree_index.set_root_id(p_kid):
--
  procedure set_env(p_array in JTF_VARCHAR2_TABLE_2000) is
  cursor c1(p_kn varchar2) is
  select to_char(id) from okc_k_headers_b
  where contract_number = p_kn;
  kid varchar2(40);
  k_ind number;
  k_ind1 number;
  k_num varchar2(300);
  begin
    OKC_PARAMETERS_PUB.Set_Params(p_array);
    k_ind := OKC_PARAMETERS_PUB.Get_Index('kid');
    if (k_ind is not null) then
      if (OKC_PARAMETERS_PUB.Get_Value(k_ind) is null) then
        k_ind1 := OKC_PARAMETERS_PUB.Get_Index('_kid');
        if (k_ind1 is not null) then
          k_num := OKC_PARAMETERS_PUB.Get_Value(k_ind1);
          if (k_num is not null) then
            open c1(k_num);
            fetch c1 into kid;
            close c1;
            if (kid is not null) then
              OKC_PARAMETERS_PUB.Reset_Param(k_ind,kid);
            end if;
          end if;
        end if;
      else
        kid := OKC_PARAMETERS_PUB.Get_Value(k_ind);
      end if;
    end if;
-- Changes for bugfix 3404142 start
--    set_env(kid, OKC_PARAMETERS_PUB.Get('xid'));
    set_env(kid, fnd_profile.value('OKC_WEB_REPORT'));
-- Changes for bugfix 3404142 end
  exception
   when others then NULL;
  end set_env;

  function url_other_params(p_array in OKC_PARAMETERS_PUB.name_value_tbl_type) return varchar2 is
    l_url varchar2(4000);
    l_name varchar2(200);
    l_value varchar2(4000);
    i number;
    c number;
  begin
if (p_array is not null) then
  c := p_array.COUNT;
  if (c>0) then
    i := p_array.FIRST;
    while (i <= p_array.LAST) loop

      l_name := p_array(i).NAME;
      l_value := urlencode(p_array(i).VALUE);
      if (length(l_url)+length(l_name)+length(l_value) <= 3990) then
        l_url := l_url||l_name||'='||l_value||'&';
      end if;
      i := i+1;
    end loop;
  end if;
end if;
    return l_url;
  end;

--/1158

--
--  PROCEDURE/Function
--    public set_env
--
--  PURPOSE
--	should be called from FROMS application
--
--	1. apps_initialize
--	2. dbms_session.set_nls
--	3. exec <fnd_profile.value('OKC_WEB_ENVPROC')>
--      4. besides it sets okc_tree_index.set_root_id(p_kid)
--       SQL statements use okc_tree_index.get_root_id as Contact Id
--

  procedure set_env(   -- parameters names as in request
	p_uid varchar2,  -- User Id
	p_rid varchar2,  -- Resp Id
	p_aid varchar2,  -- Apps Id
	p_gid varchar2,  -- Group Id
	p_nlsl varchar2, -- NLS Language
	p_nlst varchar2, -- NLS Territory
	p_kid varchar2,  -- Contract Id
      p_xid varchar2   -- Report Id
		) is
    l_value varchar2(200);
    cursor nls_csr(param varchar2) is
      select value
      from NLS_SESSION_PARAMETERS
      where PARAMETER=param;
  begin
    fnd_global.apps_initialize(
	user_id 	  => to_number(p_uid),
	resp_id 	  => to_number(p_rid),
	resp_appl_id 	  => to_number(p_aid),
	security_group_id => to_number(p_gid)
    );
  --
  -- set nls context if different
  --
    open nls_csr('NLS_LANGUAGE');
    fetch nls_csr into l_value;
    close nls_csr;
    if (l_value<>p_nlsl) then
	sys.dbms_session.set_nls('NLS_LANGUAGE',p_nlsl);
    end if;
    open nls_csr('NLS_TERRITORY');
    fetch nls_csr into l_value;
    close nls_csr;
    if (l_value<>p_nlst) then
	sys.dbms_session.set_nls('NLS_TERRITORY',p_nlst);
    end if;
    fnd_profile.put('OKC_WEB_REPORT',p_xid);
    set_env(p_kid);
  exception
   when others then NULL;
  end set_env;

--
--  PROCEDURE/Function
--    private report_url
--
--  PURPOSE
--    returns url for forms apps to raise report
--
--    JSP:
--      fnd_profile.value('APPS_SERVLET_AGENT')||'OA_HTML/okcFormsXmlPrint.jsp'  (previously okcxmlkf.jsp)
--
--    parameters:
--
--	event=FRM
--	dbc=v$instance.lower(host_name)||'_'||lower(instance_name)||'.dbc'
--	kid=p_chr_id
--	vid=p_major_version
--	sid=p_scn_id
--	nlsl=<NLS_LANGUAGE>
--	nlst=<NLS_TERRITORY>
--	uid=fnd_global.user_id
--	rid=fnd_global.resp_id
--	aid=fnd_global.resp_appl_id
--	gid=fnd_global.security_group_id
--    xid=xts_id
--

  function report_url(
	p_chr_id in NUMBER,
	p_major_version NUMBER,
        p_scn_id NUMBER	)
  return varchar2 as
    l_path varchar2(200);
    l_template varchar2(200) := 'okcFormsXmlPrint.jsp';
    l_dbc varchar2(200);
    l_url varchar2(1000);
    l_value varchar2(200);
  begin
    l_path := fnd_profile.value('APPS_SERVLET_AGENT');
    select lower(host_name)||'_'||lower(instance_name)||'.dbc' into l_dbc
    from v$instance;
    l_url  := l_path;
    if ((l_path is not NULL) and (substr(l_path,-1,1) <> '/')) then
      l_url := l_url||'/';
    end if;
    l_url := l_url||'OA_HTML/'||l_template||'?event=FRM';
--
    l_url := l_url||'&'||'dbc='||l_dbc;
    l_url := l_url||'&'||'kid='||to_char(p_chr_id);
    l_url := l_url||'&'||'vid='||to_char(p_major_version);
    l_url := l_url||'&'||'sid='||to_char(p_scn_id);
    l_url := l_url||'&'||'xid='||fnd_profile.value('OKC_WEB_REPORT');
--
    l_url := l_url||'&'||'nlsl=';
    select wf_mail.URLENCODE(value) into l_value
    from NLS_SESSION_PARAMETERS
    where PARAMETER='NLS_LANGUAGE';
    l_url := l_url||l_value;
--
    l_url := l_url||'&'||'nlst=';
    select wf_mail.URLENCODE(value) into l_value
    from NLS_SESSION_PARAMETERS
    where PARAMETER='NLS_TERRITORY';
    l_url := l_url||l_value;
--
  l_url := l_url||'&'||'uid='||to_char(fnd_global.user_id)
		||'&'||'rid='||to_char(fnd_global.resp_id)
		||'&'||'aid='||to_char(fnd_global.resp_appl_id)
		||'&'||'gid='||to_char(fnd_global.security_group_id)
		||'&'||'key='||substr(to_char(okc_p_util.raw_to_number(sys_guid())),-10)
  ;
  return l_url;
end report_url;


--
--  PROCEDURE/Function
--    public exec_OKC_WEB_PRERUN
--
--  PURPOSE
--
--    procedure executes <OKC_WEB_PRERUN> profile option
--    site level value sample: 'OKC_REPORT_PVT.prerun'
--    published only for jsp apps
--    in forms apps call included in get_contract_url
--
--    signature of the procedure defined in <OKC_WEB_PRERUN> profile option
--    should be the same as the sample OKC_REPORT_PVT.prerun
--
  procedure exec_OKC_WEB_PRERUN(
    -- standard parameters
	p_api_version in NUMBER ,
	p_init_msg_list	in VARCHAR2 ,
	x_return_status	out NOCOPY VARCHAR2,
	x_msg_count out NOCOPY NUMBER,
	x_msg_data out NOCOPY VARCHAR2
    -- input parameters
--1158	,p_chr_id in NUMBER,
--1158	p_major_version in NUMBER ,
--1158	p_scn_id in NUMBER
	) is
    l_value varchar2(2000);
  begin
    l_value := fnd_profile.value('OKC_WEB_PRERUN');
    if (l_value is NULL) then
      x_return_status := 'S';
      return;
    end if;
    if (upper(l_value) = 'OKC_REPORT_PVT.PRERUN') then
      OKC_REPORT_PVT.prerun(
	p_api_version 	=> p_api_version,
	p_init_msg_list	=> p_init_msg_list,
	x_return_status	=> x_return_status,
	x_msg_count 	=> x_msg_count,
	x_msg_data 	=> x_msg_data,
	p_chr_id 	=> G_kid,
	p_major_version => G_vid,
	p_scn_id 	=> 0
      );
    else
      l_value := 'begin '||l_value||'('||
	'p_api_version 	=> :p_api_version,'||
	'p_init_msg_list=> :p_init_msg_list,'||
	'x_return_status=> :x_return_status,'||
	'x_msg_count 	=> :x_msg_count,'||
	'x_msg_data 	=> :x_msg_data,'||
	'p_chr_id 	=> :p_chr_id,'||
	'p_major_version=> :p_major_version,'||
	'p_scn_id 	=> :p_scn_id'||
				');end;';
      execute immediate l_value using
	in p_api_version,
	in p_init_msg_list,
	in out x_return_status,
	in out x_msg_count,
	in out x_msg_data,
	in G_kid,
	in G_vid,
	in 0;
    end if;
  exception
  when OTHERS then
    fnd_message.clear;
    fnd_message.set_name(APPLICATION=>'OKC',NAME=>'OKC_UNEXPECTED_ERROR');
    fnd_message.set_token(TOKEN=>'ERROR_CODE',VALUE=>sqlcode);
    fnd_message.set_token(TOKEN=>'ERROR_MESSAGE',VALUE=>sqlerrm);
    x_return_status := 'U';
    x_msg_count := 1;
    x_msg_data := fnd_message.get;
  end;

--
--  PROCEDURE/Function
--    exec_OKC_WEB_LOG_RUN
--
--  PURPOSE
--
--    procedure executes <OKC_WEB_LOG_RUN> profile option
--    site level value sample: 'OKC_REPORT_PVT.noop'
--    noop means No Operation (knowhow belongs to WF team)
--    called from bean both for FRM and JSP applications
--    when real transformation happens, not just retrieve
--    from cache
--
--    signature of the procedure defined in <OKC_WEB_LOG_RUN> profile option
--    should be the same as the sample OKC_REPORT_PVT.noop
--
  procedure exec_OKC_WEB_LOG_RUN(
    -- standard parameters
	p_api_version in NUMBER ,
	p_init_msg_list	in VARCHAR2 ,
	x_return_status	out NOCOPY VARCHAR2,
	x_msg_count out NOCOPY NUMBER,
	x_msg_data out NOCOPY VARCHAR2
    -- input parameters
--1158	,p_chr_id in NUMBER,
--1158	p_major_version in NUMBER ,
--1158	p_scn_id in NUMBER
		) is
    l_value varchar2(2000);
  begin
    l_value := fnd_profile.value('OKC_WEB_LOG_RUN');
    if (l_value is NULL) then
      x_return_status := 'S';
      return;
    end if;
    if (upper(l_value) = 'OKC_REPORT_PVT.NOOP') then
      OKC_REPORT_PVT.noop(
	p_api_version 	=> p_api_version,
	p_init_msg_list	=> p_init_msg_list,
	x_return_status	=> x_return_status,
	x_msg_count 	=> x_msg_count,
	x_msg_data 	=> x_msg_data,
	p_chr_id 	=> G_kid,
	p_major_version => G_vid,
	p_scn_id 	=> 0
      );
    else
      l_value := 'begin '||l_value||'('||
	'p_api_version 	=> :p_api_version,'||
	'p_init_msg_list=> :p_init_msg_list,'||
	'x_return_status=> :x_return_status,'||
	'x_msg_count 	=> :x_msg_count,'||
	'x_msg_data 	=> :x_msg_data,'||
	'p_chr_id 	=> :p_chr_id,'||
	'p_major_version=> :p_major_version,'||
	'p_scn_id 	=> :p_scn_id'||
					');end;';
      execute immediate l_value using
	in p_api_version,
	in p_init_msg_list,
	in out x_return_status,
	in out x_msg_count,
	in out x_msg_data,
	in G_kid,
	in G_vid,
	in 0;
    end if;
  exception
  when OTHERS then
    fnd_message.clear;
    fnd_message.set_name(APPLICATION=>'OKC',NAME=>'OKC_UNEXPECTED_ERROR');
    fnd_message.set_token(TOKEN=>'ERROR_CODE',VALUE=>sqlcode);
    fnd_message.set_token(TOKEN=>'ERROR_MESSAGE',VALUE=>sqlerrm);
    x_return_status := 'U';
    x_msg_count := 1;
    x_msg_data := fnd_message.get;
  end;


--
--  PROCEDURE/Function
--    public get_contract_url
--
--  PURPOSE
--
--    produces url to print contract from form:
--    fnd_utilities.open_url(okc_report_pvt.report_url(:p_chr_id));
--    takes care this url not reusable
--
  procedure get_contract_url(
    -- standard parameters
	p_api_version in NUMBER ,
	p_init_msg_list	in VARCHAR2 ,
	x_return_status	out NOCOPY VARCHAR2,
	x_msg_count out NOCOPY NUMBER,
	x_msg_data out NOCOPY VARCHAR2,
    -- input parameters
	p_chr_id in NUMBER,
	p_major_version NUMBER ,
        p_scn_id NUMBER ,
    -- output parameters
	x_url out nocopy varchar2
  ) is
    l_chr_id number := p_chr_id;
    l_major_version number := p_major_version;
    l_minor_version number;
    l_scn_id number := NVL(p_scn_id,0);
    cursor k_header_csr is
      select '!'
      from OKC_K_HEADERS_TL
      where ID = p_chr_id
	and LANGUAGE = userenv('LANG')
      for update of last_update_date, last_updated_by
      nowait;
    l_dummy varchar2(1) := '?';
  begin
    DBMS_TRANSACTION.SAVEPOINT('OKC_REPORT_PVT');

    exec_OKC_WEB_PRERUN(
	p_api_version,
	p_init_msg_list,
	x_return_status,
	x_msg_count,
	x_msg_data
--	,p_chr_id,
--	p_major_version,
--	p_scn_id
	);
    if (x_return_status<>'S') then
      DBMS_TRANSACTION.ROLLBACK_SAVEPOINT('OKC_REPORT_PVT');
      return;
    end if;

--
-- get rid of default for major_version
-- and retrieve minor version
--
    get_k_version(l_chr_id, l_major_version, l_minor_version);
    open k_header_csr;
    fetch k_header_csr into l_dummy;
    close k_header_csr;
    if l_dummy = '?' then
      raise NO_DATA_FOUND;
    end if;
    update OKC_K_HEADERS_TL
    set last_updated_by = fnd_global.user_id,
	last_update_date = sysdate+1/144
    where ID = p_chr_id
	and LANGUAGE = userenv('LANG');
    x_url := report_url(p_chr_id,l_major_version, l_scn_id);
    commit;
    x_return_status := 'S';
    return;
  exception when others then
      x_return_status := 'E';
      x_msg_count := 1;
      x_msg_data := failed_lock;
      DBMS_TRANSACTION.ROLLBACK_SAVEPOINT('OKC_REPORT_PVT');
  end;

--
--  PROCEDURE/Function
--    check_access
--
--  PURPOSE
--
--    returns 'E' if request is obsolete;
--    if not returns 'S';
--
  procedure check_access(
    -- standard parameters
	p_api_version in NUMBER ,
	p_init_msg_list	in VARCHAR2 ,
	x_return_status	out NOCOPY VARCHAR2,
	x_msg_count out NOCOPY NUMBER,
	x_msg_data out NOCOPY VARCHAR2,
    -- input parameters
	p_chr_id in NUMBER
  ) is
    cursor k_header_csr is
      select '!'
      from OKC_K_HEADERS_TL
      where ID = p_chr_id
	and LANGUAGE = userenv('LANG')
	and last_updated_by = fnd_global.user_id
        and last_update_date > sysdate
      for update of last_update_date
      nowait;
    l_dummy varchar2(1) := '?';
  begin
    DBMS_TRANSACTION.SAVEPOINT('OKC_REPORT_PVT');
    open k_header_csr;
    fetch k_header_csr into l_dummy;
    close k_header_csr;
    if l_dummy = '?' then
      raise NO_DATA_FOUND;
    end if;
  -- for test commented out, later on place back
--    update OKC_K_HEADERS_TL
--    set last_update_date = sysdate
--    where ID = p_chr_id and LANGUAGE = userenv('LANG');
    commit;

    x_return_status := 'S';
    return;
  exception when others then
      x_return_status := 'E';
      x_msg_count := 1;
      x_msg_data := failed_session;
      DBMS_TRANSACTION.ROLLBACK_SAVEPOINT('OKC_REPORT_PVT');
  end;

--
--  PROCEDURE/Function
--    transformation_error
--
--  PURPOSE
--
--    returns translated message
--    OKC_TRANSF_ERROR with tokens TRANSF_TYPE, TRANSF_NAME
--
  function transformation_error(
	p_type in varchar2,
	p_id   in number
  ) return varchar2 is
    l_message varchar2(2000);
    l_token varchar2(150);
    cursor c_sql(p_sql number) is
      select name from okc_report_sql_v
      where id=p_sql;
    cursor c_xsl(p_xsl number) is
      select name from okc_report_xsl_v
      where id=p_xsl;
   begin
     if (p_type='SQL') then
       open c_sql(p_id);
       fetch c_sql into l_token;
       close c_sql;
     else
       open c_xsl(p_id);
       fetch c_xsl into l_token;
       close c_xsl;
     end if;
    fnd_message.clear;
    fnd_message.set_name(APPLICATION=>'OKC',NAME=>'OKC_TRANSF_ERROR');
    fnd_message.set_token(TOKEN=>'TRANSF_TYPE',VALUE=>p_type);
    fnd_message.set_token(TOKEN=>'TRANSF_NAME',VALUE=>'"'||l_token||'"');
    return fnd_message.get;
  end;

  function return_mess(p_mess varchar2) return varchar2 is
  begin
       fnd_message.clear;
       fnd_message.set_name(APPLICATION => 'OKC',NAME => p_mess);
       return '<html><head><title>Error</title><head><body><ul><li><pre>'||fnd_message.get||'</pre></li></ul></body></html>';
  end;


--
--  PROCEDURE/Function
--    check_transf_path
--
--  PURPOSE
--
--    returns 'S' if path valid
--    else returns translated message
--      OKC_INACTIVE_TRANSF
--        tokens TRANSF_TYPE, TRANSF_NAME, PROFILE
--
  function check_transf_path return varchar2 is

    l_message varchar2(2000);
    l_token1 varchar2(240);
    l_token2 varchar2(240);
    l_token3 varchar2(240);

    cursor template_csr is
      select
        'XSL' TEMPLATE_TYPE,
        S.NAME TEMPLATE_NAME
      from
        ( select XSL_ID,SQL_ID
          from OKC_REPORT_XST
          connect by ID = prior XST_ID
          start with ID = fnd_profile.value('OKC_WEB_REPORT')) T,
        OKC_REPORT_XSL_V S
      where T.XSL_ID = S.ID
        and  not(sysdate between S.START_DATE and NVL(S.END_DATE,sysdate))
      union all
      select
        'SQL' TEMPLATE_TYPE,
        Q.NAME TEMPLATE_NAME
      from
        ( select XSL_ID,SQL_ID
          from OKC_REPORT_XST
          connect by ID = prior XST_ID
          start with ID = fnd_profile.value('OKC_WEB_REPORT')) T,
        OKC_REPORT_SQL_V Q
       where T.SQL_ID = Q.ID
         and  not(sysdate between Q.START_DATE and NVL(Q.END_DATE,sysdate))
     ;
     cursor profile_options_csr is
       select '"'||USER_PROFILE_OPTION_NAME||'"'
       from fnd_profile_options_vl
       where application_id=510
         and PROFILE_OPTION_NAME = 'OKC_WEB_REPORT'
     ;

     l_dummy varchar2(1):='?';
     cursor report_exists is
       select '!'
       from OKC_REPORT_XST T, OKC_REPORT_XSL_V L
       where T.ID = fnd_profile.value('OKC_WEB_REPORT')
       and T.XSL_ID = L.ID;

   begin
     if (fnd_profile.value('OKC_WEB_REPORT') is NULL) then
--       open profile_options_csr;
--       fetch profile_options_csr into l_token3;
--       close profile_options_csr;
       fnd_message.clear;
       fnd_message.set_name(APPLICATION=>'OKC',NAME=>'OKC_INACTIVE_TRANSF');
--       fnd_message.set_token(TOKEN=>'TRANSF_TYPE',VALUE=>l_token1);
--       fnd_message.set_token(TOKEN=>'TRANSF_NAME',VALUE=>'"'||l_token2||'"');
--       fnd_message.set_token(TOKEN=>'PROFILE',VALUE=>l_token3);
       return fnd_message.get;
     end if;
     open report_exists;
     fetch report_exists into l_dummy;
     close report_exists;
     if (l_dummy = '?') then
--       open profile_options_csr;
--       fetch profile_options_csr into l_token3;
--       close profile_options_csr;
       fnd_message.clear;
       fnd_message.set_name(APPLICATION=>'OKC',NAME=>'OKC_INACTIVE_TRANSF');
--       fnd_message.set_token(TOKEN=>'TRANSF_TYPE',VALUE=>l_token1);
--       fnd_message.set_token(TOKEN=>'TRANSF_NAME',VALUE=>'"'||l_token2||'"');
--       fnd_message.set_token(TOKEN=>'PROFILE',VALUE=>l_token3);
       return fnd_message.get;
     end if;

     open template_csr;
     fetch template_csr into l_token1, l_token2;
     close template_csr;
     if (l_token1 is not null) then
       open profile_options_csr;
       fetch profile_options_csr into l_token3;
       close profile_options_csr;
       fnd_message.clear;
       fnd_message.set_name(APPLICATION=>'OKC',NAME=>'OKC_INACTIVE_TRANSF');
--       fnd_message.set_token(TOKEN=>'TRANSF_TYPE',VALUE=>l_token1);
--       fnd_message.set_token(TOKEN=>'TRANSF_NAME',VALUE=>'"'||l_token2||'"');
--       fnd_message.set_token(TOKEN=>'PROFILE',VALUE=>l_token3);
       return fnd_message.get;
     else
       return 'S';
     end if;
   end;

--
--  PROCEDURE/Function
--    noop - mean No Operation - WF team knowhow
--
--  PURPOSE
--
--    sample dummy procedure for setting OKC_WEB_LOG_RUN
--    profile option value on site level
--
--    what is important - signature
--
  procedure noop(
    -- standard parameters
	p_api_version in NUMBER ,
	p_init_msg_list	in VARCHAR2 ,
	x_return_status	out NOCOPY VARCHAR2,
	x_msg_count out NOCOPY NUMBER,
	x_msg_data out NOCOPY VARCHAR2,
    -- input parameters
	p_chr_id in NUMBER,
	p_major_version NUMBER ,
	p_scn_id in NUMBER
  ) is
  begin
    x_return_status := 'S';
  end;

--
--  PROCEDURE/Function
-- private function data_required_msg
-- called from prerun validation
--
--  PURPOSE
--
-- returns translated message OKC_DATA_REQUIRED
-- Data required for some operation
-- DATA_NAME data required for OPERATION
--
-- translatable token DATA_NAME
--   OKC_SECTIONS Sections
--   OKC_RULE_GROUPS Rule Groups
-- translatable token OPERATION
--   OKC_PRINT_CONTRACT Contract Printing
--

function data_required_msg(p_data_name varchar2) return varchar2 is
begin
  fnd_message.clear;
  FND_MESSAGE.SET_NAME(application => 'OKC',
                       name     => 'OKC_DATA_REQUIRED');
  FND_MESSAGE.SET_TOKEN(token => 'DATA_NAME',
                      	value     => p_data_name,
			translate => TRUE);
      FND_MESSAGE.SET_TOKEN(token => 'OPERATION',
                      	value     => 'OKC_PRINT_CONTRACT',
			translate => TRUE);
    return fnd_message.get;
end;

--
--  PROCEDURE/Function
--    articles_warning
--
--  PURPOSE
--
--    included for use within Authoring Form only for PM demo
--
  procedure articles_warning(
    -- standard parameters
	p_api_version in NUMBER ,
	p_init_msg_list	in VARCHAR2 ,
	x_return_status	out NOCOPY VARCHAR2,
	x_msg_count out NOCOPY NUMBER,
	x_msg_data out NOCOPY VARCHAR2,
    -- input parameters
	p_chr_id in NUMBER
  ) is
  l_dummy number;
  cursor articles_diff_csr(p_chr number) is
  select id
  from okc_k_articles_v
  where dnz_chr_id = p_chr
  and chr_id = p_chr
  minus
  SELECT SC.cat_id id
  from okc_section_contents_v SC
  WHERE SC.scn_id in
    (SELECT id
    from okc_sections_b
    connect by prior id = scn_id
    start with chr_id = p_chr
    and scn_id is NULL);
  begin
    open articles_diff_csr(p_chr_id);
    fetch articles_diff_csr into l_dummy;
    close articles_diff_csr;
    if (l_dummy is not NULL) then
      x_return_status := 'E';
      x_msg_count := 1;
      fnd_message.clear;
      FND_MESSAGE.SET_NAME(application => 'OKC', name     => 'OKC_ARTICLES_WARNING');
      x_msg_data := fnd_message.get;
      return;
    end if;
    x_return_status := 'S';
  end;


--
--  PROCEDURE/Function
--    prerun
--
--  PURPOSE
--
--    sample procedure, its name could be used
--    to set profile option OKC_WEB_PRERUN
--    performs sample validation tasks:
--    checks if lines and sections are present in the contract
--
--    what is import - signature
--
  procedure prerun(
    -- standard parameters
	p_api_version in NUMBER ,
	p_init_msg_list	in VARCHAR2 ,
	x_return_status	out NOCOPY VARCHAR2,
	x_msg_count out NOCOPY NUMBER,
	x_msg_data out NOCOPY VARCHAR2,
    -- input parameters
	p_chr_id in NUMBER,
	p_major_version in NUMBER ,
	p_scn_id in NUMBER
  ) is
  l_dummy varchar2(1);
--
-- sections required
--
  cursor sections_csr(p_chr number) is
    select '!'
    from okc_sections_v
    where CHR_ID = p_chr
  ;
--
-- RG required at header level
--
  cursor lines_csr(p_chr number) is
    select '!'
    from okc_k_lines_v
    where CHR_ID = p_chr
    ;
  begin
    l_dummy := '?';
    open sections_csr(p_chr_id);
    fetch sections_csr into l_dummy;
    close sections_csr;
    if (l_dummy = '?') then
      x_return_status := 'E';
      x_msg_count := 1;
      x_msg_data := data_required_msg('OKC_SECTIONS');
      return;
    end if;
    l_dummy := '?';
    open lines_csr(p_chr_id);
    fetch lines_csr into l_dummy;
    close lines_csr;
    if (l_dummy = '?') then
      x_return_status := 'E';
      x_msg_count := 1;
      x_msg_data := data_required_msg('OKC_K_LINES');
      return;
    end if;
    x_return_status := 'S';
  end;

--
--  PROCEDURE/Function
--    free_temp_clob
--
--  PURPOSE
--    for internal use only
--    just a wrapper of dbms_clob.freetemporary
--
  procedure free_temp_clob(
	p_clob in out nocopy CLOB
  ) is
  begin
    if (dbms_lob.istemporary(lob_loc => p_clob) = 1) then
      dbms_lob.freetemporary(lob_loc => p_clob);
    end if;
  exception when others then NULL;
  end;

--  PROCEDURE/Function
--    get_sql_name
--  PURPOSE
--    for internal use only
--
  function get_sql_name(p_sql_id number) return varchar2 is
    cursor sql_csr is select name from okc_report_sql_v
                 where id=p_sql_id;
    l_name varchar2(150);
  begin
    if p_sql_id is null then return NULL; end if;
    open sql_csr;
    fetch sql_csr into l_name;
    close sql_csr;
    return l_name;
  end;

--  PROCEDURE/Function
--    public get_new_id
--  PURPOSE
--    for internal use only
--
  function get_new_id return number is
  begin
    return okc_p_util.raw_to_number(sys_guid());
  end;

--  PROCEDURE/Function
--    public get_new_id
--  PURPOSE
--    for internal use only
--
  function get_new_id(p_entity varchar2) return number is
    l_user_id number := fnd_global.user_id;
    l_n number;
  begin
    if (l_user_id <> 1) then
      return okc_p_util.raw_to_number(sys_guid());
    else
      if (p_entity = 'SQL') then
        select NVL(max(id),10000)+1 into l_n
        from okc_report_sql_b
        where id between 10001 and 20000-1;
      elsif (p_entity = 'XSL') then
        select NVL(max(id),10000)+1 into l_n
        from okc_report_xsl_b
        where id between 10001 and 20000-1;
      elsif (p_entity = 'XST') then
        select NVL(max(id),10000)+1 into l_n
        from okc_report_xst
        where id between 10001 and 20000-1;
      end if;
      return l_n;
    end if;
  end;

-- Start of comments
--
-- Procedure Name  : check_name_uk
-- Description     : checks if sql or xsl name is unique
-- Business Rules  :
-- Parameters      :
-- Version         : 1.0
-- End of comments

function check_name_uk(p_entity varchar2) return varchar2 is
cursor sql_csr is
  select name
  from okc_report_sql_v
  where nvl(end_date,sysdate)>=sysdate
  group by name
  having count(1)>1;
cursor xsl_csr is
  select name
  from okc_report_xsl_v
  where nvl(end_date,sysdate)>=sysdate
  group by name
  having count(1)>1;
l_name varchar2(150);
begin
  if (p_entity = 'SQL') then
    open sql_csr;
    fetch sql_csr into l_name;
    close sql_csr;
  elsif (p_entity = 'XSL') then
    open xsl_csr;
    fetch xsl_csr into l_name;
    close xsl_csr;
  end if;
  if (l_name is not null) then
    fnd_message.clear;
    fnd_message.set_name(APPLICATION=>'OKC',NAME=>'OKC_VALUE_NOT_UNIQUE');
    fnd_message.set_token(TOKEN=>'COL_NAME',VALUE=>l_name);
    return fnd_message.get;
  else
    return null;
  end if;
end;

procedure set_message(p_message varchar2, p_code varchar2, p_prompt varchar2, p_value varchar2) is
begin
   OKC_API.SET_MESSAGE(p_app_name => 'OKC'
                       ,p_msg_name     => p_message
                       ,p_token1 => 'NAME'
                       ,p_token1_value => p_prompt
                       ,p_token2 => 'VALUE'
                       ,p_token2_value => p_value
                       );
  OKC_PARAMETERS_PUB.Reset_Param(OKC_PARAMETERS_PUB.Get_Index(p_code),NULL);
end;

procedure set_sql_id is
    cursor c_sql_id is
       select T.SQL_ID
       from OKC_REPORT_XST T, OKC_REPORT_XSL_V L
       where T.ID = fnd_profile.value('OKC_WEB_REPORT')
       and T.XSL_ID = L.ID;
begin
     G_sql_id := null;
     if (fnd_profile.value('OKC_WEB_REPORT') is NULL) then
       OKC_API.SET_MESSAGE(p_app_name => 'OKC'
                       ,p_msg_name     => 'OKC_INACTIVE_TRANSF'
                       );
       return;
    end if;
    open c_sql_id;
    fetch c_sql_id into G_sql_id;
    close c_sql_id;
     if (G_sql_id is NULL) then
       OKC_API.SET_MESSAGE(p_app_name => 'OKC'
                       ,p_msg_name     => 'OKC_INACTIVE_TRANSF');
    end if;

end;

-- Start of comments
--
-- Procedure Name  : validate parameters
-- Description     : returns errors #
-- Business Rules  :
-- Parameters      :
-- Version         : 1.0
-- End of comments

function validate_params(p_required_yn varchar2 ) return number is
  cursor c1(p number) is
    select code,
      prompt,
      type,
      required_yn,
      lov_query,
      OKC_PARAMETERS_PUB.get(code) value
    from OKC_REPORT_PRM_V
    where sql_id = p
    order by sequence_num;
    r c1%ROWTYPE;

    type ct is ref cursor;
    c2 ct;
    n number;
    ni number;
    m varchar2(4000);
    nv varchar2(4000);

begin
  fnd_msg_pub.initialize;
--
--  validate types, dependencies, spawn fnd_messages
--
  set_sql_id;
  if (G_sql_id is NULL) then
    return -1;
  end if;
  for r in c1(G_sql_id) LOOP
    if ( (p_required_yn = 'Y') and (r.required_yn = 'Y') ) then
      nv := r.value;
      ni := OKC_PARAMETERS_PUB.get_index('_'||r.code);
      if (ni is not NULL) then
        nv := OKC_PARAMETERS_PUB.get_value(ni);
      end if;
      if (nv is NULL) then
        OKC_API.SET_MESSAGE(p_app_name => 'OKC'
                       ,p_msg_name     => 'OKC_REQUIRED_FIELD'
                       ,p_token1 => 'FIELD_NAME'
                       ,p_token1_value => '"'||r.prompt||'"'
                       );
       end if;
    end if;
    if (r.type = 'VARCHAR2') then
      GOTO continue;
    end if;
    if ( (r.type = 'NUMBER') and (r.value is not NULL) ) then
    begin
      if (to_number(r.value) is not NULL) then
        GOTO continue;
      end if;
    exception when others then
      set_message('OKC_XML_PARAM_NUMBER', r.code, r.prompt, r.value);
      GOTO continue;
    end;
    end if;
    if ( (r.type = 'DATE') and (r.value is not NULL) ) then
    begin
      if (to_date(r.value,'YYYY/MM/DD') is not NULL) then
        GOTO continue;
      end if;
    exception when others then
      set_message('OKC_XML_PARAM_DATE', r.code, r.prompt, r.value);
      GOTO continue;
    end;
    end if;

    if (r.type = 'LOV') then
      ni := OKC_PARAMETERS_PUB.get_index('_'||r.code);
      if (ni is NULL) then
        if (r.value is NULL) then
          GOTO continue;
        else
        begin
          n := NULL;
          open c2 for 'select 1 a from ('||r.lov_query||') where id = :1' using r.value;
          fetch c2 into n;
          close c2;
          if (n is NULL) then
            set_message('OKC_XML_PARAM_LOV', r.code, r.prompt, r.value);
          end if;
          GOTO continue;
        exception when others then
          if (c2%ISOPEN) then close c2; end if;
          set_message('OKC_XML_PARAM_LOV', r.code, r.prompt, r.value);
          GOTO continue;
        end;
        end if;
      else
        begin
          nv := OKC_PARAMETERS_PUB.get_value(ni);

          if (nv is NULL) then
            OKC_PARAMETERS_PUB.Reset_Param(OKC_PARAMETERS_PUB.Get_Index(r.code),NULL);
            GOTO continue;
          end if;

          n := NULL;
          open c2 for
            'select 1 a from ('||r.lov_query||') where id = :1 and name=:2'
          using r.value, nv;
          fetch c2 into n;
          close c2;
          if (n is not NULL) then
            GOTO continue;
          end if;

          m := NULL;
          open c2 for
            'select id from ('||r.lov_query||') where name=:2'
          using nv;
          fetch c2 into m;
          close c2;
          if (m is not NULL) then
            OKC_PARAMETERS_PUB.Reset_Param(OKC_PARAMETERS_PUB.Get_Index(r.code),m);
            GOTO continue;
          end if;
          open c2 for
            'select id from ('||r.lov_query||') where name like :2'
          using nv;
          fetch c2 into m;
          close c2;
          if (m is not NULL) then
            OKC_PARAMETERS_PUB.Reset_Param(OKC_PARAMETERS_PUB.Get_Index(r.code),m);
            GOTO continue;
          end if;
          set_message('OKC_XML_PARAM_LOV', r.code, r.prompt, nv);
          GOTO continue;
        exception when others then
          if (c2%ISOPEN) then close c2;
          end if;
          set_message('OKC_XML_PARAM_LOV', r.code, r.prompt, nv);
          GOTO continue;
        end;
      end if;
    end if;
    <<continue>> NULL;
  end LOOP;

  return fnd_msg_pub.Count_Msg;
end;

function set_and_validate(p_array in JTF_VARCHAR2_TABLE_2000, p_required_yn varchar2 ) return number is
begin
  set_env(p_array);
  return validate_params(p_required_yn);
end;

function get_zero_mess return varchar2 is
begin
    fnd_message.clear;
    fnd_message.set_name(APPLICATION=>'CN',NAME=>'CN_NO_RECS_FOUND');
    return replace(fnd_message.get,'<',fnd_global.local_chr(38)||'lt;');
end;

function get_much_mess return varchar2 is
begin
    fnd_message.clear;
    fnd_message.set_name(APPLICATION=>'PER',NAME=>'HR_WEB_RETRIEVE_LIMIT_EXCEEDED');
    return replace(fnd_message.get,'<',fnd_global.local_chr(38)||'lt;');
end;

procedure get_labels(
	x_title out nocopy varchar2,
	x_prompt out nocopy varchar2,
	x_message out nocopy varchar2,
	x_name out nocopy varchar2,
	x_description out nocopy varchar2,
	x_sql out nocopy varchar2) is
  cursor c1 is
    select replace(prompt,'<',fnd_global.local_chr(38)||'lt;'), lov_query
    from okc_report_prm_v PRM, okc_report_xst_v XST
    where PRM.sql_id = XST.sql_id
      and XST.id = fnd_profile.value('OKC_WEB_REPORT')
      and PRM.code = OKC_PARAMETERS_PUB.get('__param_code');
  cursor c2 is
    select replace(MEANING,'<',fnd_global.local_chr(38)||'lt;') from fnd_lookups
    where LOOKUP_TYPE='OKS_ITEM_DISPLAY_PREFERENCE'
    and lookup_code='DISPLAY_NAME';
  cursor c3 is
    select replace(MEANING,'<',fnd_global.local_chr(38)||'lt;') from fnd_lookups
    where LOOKUP_TYPE='OKS_ITEM_DISPLAY_PREFERENCE'
    and lookup_code='DISPLAY_DESC';
  cursor c4 is
    select replace(description,'<',fnd_global.local_chr(38)||'lt;') from fnd_lookups
    where LOOKUP_TYPE='FLEX_VALIDATION_EVENTS'
    and LOOKUP_CODE='Q';

begin
    open c4;
    fetch c4 into x_title;
    close c4;
    open c2;
    fetch c2 into x_name;
    close c2;
    open c3;
    fetch c3 into x_description;
    close c3;
    if (fnd_profile.value('OKC_WEB_REPORT') is NULL) then
      fnd_message.clear;
      fnd_message.set_name(APPLICATION=>'CN',NAME=>'CN_NO_RECS_FOUND');
      x_message := fnd_message.get;
      return;
    else
      open c1;
      fetch c1 into x_prompt,x_sql;
      close c1;
    end if;
end;

procedure get_actions(
	x_run1 out nocopy varchar2,
	x_run2 out nocopy varchar2,
	x_close out nocopy varchar2) is
begin
    fnd_message.clear;
    fnd_message.set_name(APPLICATION=>'OKC',NAME=>'OKC_XML_RUN1');
    x_run1 := replace(fnd_message.get,'<',fnd_global.local_chr(38)||'lt;');
    fnd_message.clear;
    fnd_message.set_name(APPLICATION=>'OKC',NAME=>'OKC_XML_RUN2');
    x_run2 := replace(fnd_message.get,'<',fnd_global.local_chr(38)||'lt;');
    fnd_message.clear;
    fnd_message.set_name(APPLICATION=>'OKC',NAME=>'OKC_XML_CLOSE');
    x_close := replace(fnd_message.get,'<',fnd_global.local_chr(38)||'lt;');
end;

procedure document_link(
     p_kid in NUMBER,
     p_vid in NUMBER,
     p_xid in NUMBER,
     p_document in out NOCOPY CLOB) as

  cursor get_htm_text(pp_kid number, pp_vid number, pp_xid number) is
    select HTM_TEXT
    from okc_report_htm_v
    where CHR_ID = pp_kid
    and MAJOR_VERSION = pp_vid
    and XST_ID = pp_xid;
  c1 clob;

begin
    open get_htm_text(p_kid,p_vid,p_xid);
    fetch get_htm_text into c1;
--    fetch get_htm_text into p_document;
    close get_htm_text;
    DBMS_LOB.COPY(dest_lob => p_document,src_lob => c1, amount => dbms_lob.getlength(c1));
end;

  --
  -- sample post-report trigger to send message to
  -- the wf_role passed in P_RECIPIENT parameter
  --
procedure post_message(
     p_api_version in NUMBER ,
     p_init_msg_list in VARCHAR2 ,
     x_return_status out NOCOPY VARCHAR2,
     x_msg_count out NOCOPY NUMBER,
     x_msg_data out NOCOPY VARCHAR2,
     p_chr_id in NUMBER,
     p_major_version NUMBER ,
     p_scn_id in NUMBER ) is

  P_RECIPIENT varchar2(100) 	:= OKC_PARAMETERS_PUB.get('P_RECIPIENT');
  P_SUBJECT varchar2(2000) 	    := OKC_PARAMETERS_PUB.get('P_SUBJECT');
  P_BODY varchar2(2000) 	       := OKC_PARAMETERS_PUB.get('P_BODY');
  P_XID varchar2(40)		      := fnd_profile.value('OKC_WEB_REPORT');

  l_dummy varchar2(1) := '?';

  cursor c1(k number) is
    select
	Contract_number||
	decode(Contract_number_modifier,NULL,NULL,' - ')||
	Contract_number_modifier
    from okc_k_headers_b
    where id = k;

  cursor c2(x varchar2) is
    select
      S.NAME
    from okc_report_xst T,
      okc_report_sql_v Q,
      okc_report_xsl_v S
    where T.id = x
      and T.sql_id = Q.id
      and T.xsl_id = S.id;
  begin
    x_return_status := 'S';
    if (P_RECIPIENT is null) then
      return;
    end if;
    if (P_SUBJECT is NULL) then
      open c1(p_chr_id);
      fetch c1 into P_SUBJECT;
      close c1;
    end if;
    if (P_SUBJECT is NULL) then
      open c2(P_XID);
      fetch c2 into P_SUBJECT;
      close c2;
    end if;

    OKC_ASYNC_PUB.send_doc(
        p_api_version => 1,
        p_init_msg_list => 'T',
        x_return_status => x_return_status,
        x_msg_count => x_msg_count,
        x_msg_data => x_msg_data,
        p_recipient => P_RECIPIENT,
        p_msg_subj => P_SUBJECT,
        p_msg_body => P_BODY,
        p_proc  => 'begin OKC_REPORT_PVT.document_link('
			||'p_kid => '||p_chr_id||','
			||'p_vid => '||NVL(to_char(p_major_version),'NULL')||','
			||'p_xid => '||P_XID||','
			||'p_document => '||':1); end;');

  end post_message;

  --
  -- send document from cache
  --
procedure send_document(
     p_recipient varchar2,
     p_subject varchar2,
     p_body varchar2 ,
     p_chr_id in NUMBER,
     p_major_version NUMBER,
     p_xst_id NUMBER) is

     x_return_status VARCHAR2(1);
     x_msg_count NUMBER;
     x_msg_data VARCHAR2(2000);

  begin
    if ((p_recipient is NULL) or (p_recipient = fnd_global.local_chr(0))) then
      return;
    end if;
    OKC_ASYNC_PUB.send_doc(
        p_api_version => 1,
        p_init_msg_list => 'T',
        x_return_status => x_return_status,
        x_msg_count => x_msg_count,
        x_msg_data => x_msg_data,
        p_recipient => p_recipient,
        p_msg_subj => p_subject,
        p_msg_body => p_body,
        p_proc  => 'begin OKC_REPORT_PVT.document_link('
			||'p_kid => '||p_chr_id||','
			||'p_vid => '||NVL(to_char(p_major_version),'NULL')||','
			||'p_xid => '||P_XST_ID||','
			||'p_document => '||':1); end;');
 end send_document;

  --
  -- send document from cache
  --
procedure conc_send_document(
     errbuf 	 out nocopy varchar2,
     retcode 	 out nocopy varchar2,
     p_recipient 	varchar2,
     p_cc 		varchar2 ,
     p_bcc 		varchar2 ,
     p_subject 		varchar2,
     p_body 		varchar2 ,
     p_xst_id 		NUMBER,
     p_chr_id 		NUMBER,
     p_major_version 	NUMBER ) is
  v number := p_major_version;
  cursor c1(k number) is
    select
	  MAJOR_VERSION
    from OKC_K_VERS_NUMBERS_V
    where CHR_ID = k;
  begin
    errbuf  := '';
    retcode := '0';
    if (p_major_version is NULL) then
      open c1(p_chr_id);
      fetch c1 into v;
      close c1;
    end if;
    if (v is NULL) then
      v:= -1;
    end if;
    send_document(
     p_recipient,
     p_subject,
     p_body,
     p_chr_id,
     v,
     p_xst_id);
    send_document(
     p_cc,
     p_subject,
     p_body,
     p_chr_id,
     v,
     p_xst_id);
    send_document(
     p_bcc,
     p_subject,
     p_body,
     p_chr_id,
     v,
     p_xst_id);
  end;

procedure conc_send_error(
     errbuf out nocopy varchar2,
     retcode out nocopy varchar2,
     p_recipient varchar2,
     p_cc varchar2 ,
     p_xst_id NUMBER,
     p_chr_id in NUMBER) is

  cursor c1(k number) is
    select
	Contract_number
	,Contract_number_modifier
    from okc_k_headers_b
    where id = k;

  l_n varchar2(200);
  l_m varchar2(200);

  cursor c2(x varchar2) is
    select
      Q.NAME NAME,
      S.NAME DESCRIPTION
    from okc_report_xst T,
      okc_report_sql_tl Q,
      okc_report_xsl_tl S
    where T.id = x
      and T.sql_id = Q.id
      and T.xsl_id = S.id
      and Q.LANGUAGE = userenv('LANG')
      and S.LANGUAGE = userenv('LANG')
      ;

  l_q varchar2(200);
  l_x varchar2(200);

  l_s varchar2(2000);
  l_b varchar2(2000);

  x_return_status varchar2(1);
  x_msg_count number;
  x_msg_data varchar2(2000);

  begin
    errbuf  := '';
    retcode := '0';
    if ((p_recipient is NULL) or (p_recipient = fnd_global.local_chr(0))) then
      return;
    end if;
    open  c1(p_chr_id);
    fetch c1 into l_n,l_m;
    close c1;
    open  c2(p_xst_id);
    fetch c2 into l_q,l_x;
    close c2;

    fnd_message.clear;
    fnd_message.set_name(APPLICATION=>'OKC',NAME=>'OKC_XML_ERROR_SUBJECT');
    fnd_message.set_token(TOKEN => 'NAME'	,VALUE => l_q);
    fnd_message.set_token(TOKEN => 'DESCRIPTION',VALUE => l_x);
    fnd_message.set_token(TOKEN => 'NUMBER'	,VALUE => l_n);
    fnd_message.set_token(TOKEN => 'MODIFIER'	,VALUE => l_m);
    l_s := fnd_message.get;

    fnd_message.clear;
    fnd_message.set_name(APPLICATION=>'OKC',NAME=>'OKC_XML_ERROR');
    fnd_message.set_token(TOKEN => 'NAME'	,VALUE => l_q);
    fnd_message.set_token(TOKEN => 'DESCRIPTION',VALUE => l_x);
    fnd_message.set_token(TOKEN => 'NUMBER'	,VALUE => l_n);
    fnd_message.set_token(TOKEN => 'MODIFIER'	,VALUE => l_m);
    l_b := fnd_message.get;

    OKC_ASYNC_PUB.msg_call(
			p_api_version	=> 1,
           		x_return_status => x_return_status,
           		x_msg_count     => x_msg_count,
           		x_msg_data      => x_msg_data,
			p_recipient     => p_recipient,
			p_msg_subj      => l_s,
			p_msg_body      => l_b,
			p_contract_id   => p_chr_id);
    if ((p_cc is NULL) or (p_cc = fnd_global.local_chr(0))) then
      return;
    end if;
    OKC_ASYNC_PUB.msg_call(
			p_api_version	=> 1,
           		x_return_status => x_return_status,
           		x_msg_count     => x_msg_count,
           		x_msg_data      => x_msg_data,
			p_recipient     => p_cc,
			p_msg_subj      => l_s,
			p_msg_body      => l_b,
			p_contract_id   => p_chr_id);
  end;

function run_report_and_send(
     p_recipient 	varchar2,
     p_cc 		varchar2 ,
     p_bcc 		varchar2 ,
     p_subject 		varchar2,
     p_body 		varchar2 ,
     p_xst_id 		NUMBER,
     p_chr_id 		NUMBER,
     p_major_version 	NUMBER ,
     p_err_recipient 	varchar2 ,
     p_err_cc 		varchar2
     ) return number is
  success boolean;
begin
  success := fnd_submit.set_request_set('OKC','KXMLREPORT_SET');
  if (not(success)) then return NULL; end if;
  success := fnd_submit.submit_program('OKC','KXMLREPORT','KXMLREPORT',p_chr_id,p_xst_id);
  if (not(success)) then return NULL; end if;
  success := fnd_submit.submit_program('OKC','OKC_XML_MESS1','OKC_XML_MESS1',P_RECIPIENT,P_CC,P_BCC,P_SUBJECT,
	P_BODY, P_XST_ID,P_CHR_ID, P_MAJOR_VERSION);
  if (not(success)) then return NULL; end if;
  success := fnd_submit.submit_program('OKC','OKC_XML_MESS2','OKC_XML_MESS2',P_ERR_RECIPIENT,P_ERR_CC,P_XST_ID,
	P_CHR_ID);
  if (not(success)) then return NULL; end if;
  return fnd_submit.submit_set(null,FALSE);
end;

end OKC_REPORT_PVT;

/
