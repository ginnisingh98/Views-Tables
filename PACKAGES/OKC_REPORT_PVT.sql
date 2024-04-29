--------------------------------------------------------
--  DDL for Package OKC_REPORT_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OKC_REPORT_PVT" AUTHID CURRENT_USER as
/* $Header: OKCRXPKS.pls 120.0.12010000.2 2008/10/24 08:03:04 ssreekum ship $ */

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

--
--    Profile values used:
--
--	OKC_WEB_DBC
--	OKC_WEB_PATH
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

--
--    get_xsl_help
--
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
	p_sql_id number default NULL  -- if null derive from OKC_WEB_REPORT prof.
  ) return clob;

--
--    get_art_help
--
--    returns help text for standard atricles designer
--    similar to previous method based on view okc_report_xsl_v
--
  function get_art_help(
	p_xsl_id number default NULL  -- if null derive from OKC_WEB_REPORT prof.
  ) return clob;

--
--    get_xml
--
--    should be called only for "cached" sql transformations
--    returns datagram from cache if it is still valid,
--    or updates/inserts clob to put there result on XSQL transformation
--
  procedure get_xml(
    -- standard parameters
	p_api_version in NUMBER default 1,
	p_init_msg_list	in VARCHAR2 default OKC_API.G_TRUE,
	x_return_status	out nocopy VARCHAR2,
	x_msg_count out nocopy NUMBER,
	x_msg_data out nocopy VARCHAR2,
    -- input parameters
--1158	p_chr_id in NUMBER,
--1158	p_major_version NUMBER default NULL, 	-- NULL stands for the latest
--1158	p_sql_id in NUMBER default NULL,	-- if null derive from OKC_WEB_REPORT prof.
	p_run_anyway_yn in varchar2 default 'N',
   -- output parameters
	x_xml_text out nocopy CLOB,
	x_clob_status out nocopy VARCHAR2
	--'I' - inserted empty, or old and obsolete; locked
	--'V' - valid not locked
  );

--
--    get_htm
--
--    should be called only for "cached" xsl transformations
--    returns datagram from cache if it is still valid,
--    or updates/inserts clob to put there result on XSL transformation
--
  procedure get_htm(
    -- standard parameters
	p_api_version in NUMBER default 1,
	p_init_msg_list	in VARCHAR2 default OKC_API.G_TRUE,
	x_return_status	out nocopy VARCHAR2,
	x_msg_count out nocopy NUMBER,
	x_msg_data out nocopy VARCHAR2,
    -- input parameters
--1158	p_chr_id in NUMBER,
--1158	p_major_version NUMBER default NULL,	-- NULL stands for the latest
--1158	p_xst_id in NUMBER default NULL,	-- if null derive from OKC_WEB_REPORT prof.
--1158	p_scn_id in NUMBER default NULL,	-- NULL for all top sections
	p_run_anyway_yn in varchar2 default 'N',
    -- output parameters
	x_htm_text out nocopy CLOB,
	x_clob_status out nocopy VARCHAR2
	--'I' - inserted empty, or old and obsolete; locked
	--'V' - valid not locked
  );

--
--    public set_env
--
--    exec <fnd_profile.value('OKC_WEB_ENVPROC')>
--    besides it sets okc_tree_index.set_root_id(p_kid)
--    for SQL statement
--    should be called from JSP apllication
--
  procedure set_env(
	p_kid varchar2
		);

--
--    public set_env
--
--    exec <fnd_profile.value('OKC_WEB_ENVPROC')>
--    besides it sets okc_tree_index.set_root_id(p_kid)
--    for SQL statement
--    should be called from JSP apllication
--
--1158  procedure set_env(
--1158	p_kid varchar2
--1158       ,p_xid varchar2
--1158		);

--1158

--
--  PROCEDURE/Function
--    public set_env
--
--  PURPOSE - previous overload with request parameter's set
--
--    dinamicly executes <fnd_profile.value('OKC_WEB_ENVPROC')>
--
--    for backward compatibility:
--    sets okc_tree_index.set_root_id(kid):
--    fnd_profile.put('OKC_WEB_REPORT',xid);
--
--  you should take care that xid and kid from context (if there)
--  should go to params list (if they are not there yet)
--
  procedure set_env(p_array in JTF_VARCHAR2_TABLE_2000);

  function url_other_params(p_array in OKC_PARAMETERS_PUB.name_value_tbl_type) return varchar2;


--
--    private report_url, published only for debug
--
--    returns url of
--
--      fnd_profile.value('OKC_WEB_PATH')/xmlK.jsp
--
--    with parameters:
--
--	event=FRM
--	dbc=fnd_profile.value('OKC_WEB_DBC')
--	kid=p_chr_id
--	vid=p_major_version
--	sid=p_scn_id
--	nlsl=<NLS_LANGUAGE>
--	nlst=<NLS_TERRITORY>
--	uid=fnd_global.user_id
--	rid=fnd_global.resp_id
--	aid=fnd_global.resp_appl_id
--	gid=fnd_global.security_group_id
--    xid=xst_id
--
  function report_url(
	p_chr_id in NUMBER,
	p_major_version NUMBER,
        p_scn_id NUMBER	)
  return varchar2;

--
--    get_contract_url
--
--    produces url to print contract from form:
--    fnd_utilities.open_url(okc_report_pvt.report_url(:p_chr_id));
--    takes care this url be for one shot
--
  procedure get_contract_url(
    -- standard parameters
	p_api_version in NUMBER default 1,
	p_init_msg_list	in VARCHAR2 default OKC_API.G_TRUE,
	x_return_status	out nocopy VARCHAR2,
	x_msg_count out nocopy NUMBER,
	x_msg_data out nocopy VARCHAR2,
    -- input parameters
	p_chr_id in NUMBER,
	p_major_version NUMBER default NULL, 	-- NULL stands for the latest
        p_scn_id NUMBER default NULL, 		-- NULL for all top sections
    -- output parameters
	x_url out nocopy varchar2
  );

--
--    check_access
--
--    returns 'E' if request is obsolete;
--    if not then marks it as obsolete and returns 'S';
--    takes care get_contract_url.x_url be for one shot
--
  procedure check_access(
    -- standard parameters
	p_api_version in NUMBER default 1,
	p_init_msg_list	in VARCHAR2 default OKC_API.G_TRUE,
	x_return_status	out nocopy VARCHAR2,
	x_msg_count out nocopy NUMBER,
	x_msg_data out nocopy VARCHAR2,
    -- input parameters
	p_chr_id in NUMBER
  );


--
--    transformation_error
--
--    returns message from message dictionary
--    OKC_TRANSF_ERROR tokens TEMPLATE, NAME
--
--    p_type, p_id 	-> 'SQL', SQL_ID
--			-> 'XSL', XSL_ID
--
  function transformation_error(
	p_type in varchar2,
	p_id   in number
  ) return varchar2;


--
--    check_transf_path
--
--    returns 'S' if path valid
--    else returns message
--      OKC_INACTIVE_TRANSF
--        tokens TRANSF_TYPE, TRANSF_NAME, PROFILE
--
  function check_transf_path return varchar2;



--
--    exec_OKC_WEB_PRERUN
--
--    procedure executes <OKC_WEB_PRERUN> profile option
--    site level value is 'OKC_REPORT_PVT.prerun'
--    published only for jsp apps
--    in forms apps call included in get_contract_url
--
--    signature of the procedure defined in <OKC_WEB_PRERUN> profile option
--    should be the same as OKC_REPORT_PVT.prerun
--
  procedure exec_OKC_WEB_PRERUN(
    -- standard parameters
	p_api_version in NUMBER default 1,
	p_init_msg_list	in VARCHAR2 default OKC_API.G_TRUE,
	x_return_status	out nocopy VARCHAR2,
	x_msg_count out nocopy NUMBER,
	x_msg_data out nocopy VARCHAR2
    -- input parameters
--1158	,p_chr_id in NUMBER,
--1158	p_major_version in NUMBER default NULL,
--1158	p_scn_id in NUMBER default NULL
		);

--
--    prerun
--
--    'OKC_REPORT_PVT.prerun' used as default value
--    for profile option OKC_WEB_PRERUN
--    performs some validation tasks
--    like sections should be defined for the contract
--    let/not let to run report
--
  procedure prerun(
    -- standard parameters
	p_api_version in NUMBER default 1,
	p_init_msg_list	in VARCHAR2 default OKC_API.G_TRUE,
	x_return_status	out nocopy VARCHAR2,
	x_msg_count out nocopy NUMBER,
	x_msg_data out nocopy VARCHAR2,
    -- input parameters
	p_chr_id in NUMBER,
	p_major_version NUMBER default NULL,
	p_scn_id in NUMBER default NULL
  );

--
--    articles_warning
--
--    included for use with Authoring Form only
--
  procedure articles_warning(
    -- standard parameters
	p_api_version in NUMBER default 1,
	p_init_msg_list	in VARCHAR2 default OKC_API.G_TRUE,
	x_return_status	out nocopy VARCHAR2,
	x_msg_count out nocopy NUMBER,
	x_msg_data out nocopy VARCHAR2,
    -- input parameters
	p_chr_id in NUMBER
  );

--
--    exec_OKC_WEB_LOG_RUN
--
--    procedure executes <OKC_WEB_LOG_RUN> profile option
--    site level value is 'OKC_REPORT_PVT.noop'
--    called from bean both for FRM and JSP applications
--    when real transformation happens, not just retrieve
--    from cache
--
--    signature of the procedure defined in <OKC_WEB_LOG_RUN> profile option
--    should be the same as OKC_REPORT_PVT.noop
--
  procedure exec_OKC_WEB_LOG_RUN(
    -- standard parameters
	p_api_version in NUMBER default 1,
	p_init_msg_list	in VARCHAR2 default OKC_API.G_TRUE,
	x_return_status	out nocopy VARCHAR2,
	x_msg_count out nocopy NUMBER,
	x_msg_data out nocopy VARCHAR2
    -- input parameters
--1158	p_chr_id in NUMBER,
--1158	p_major_version in NUMBER default NULL,
--1158	p_scn_id in NUMBER default NULL
		);

--
--    noop
--
--    dummy procedure for setting OKC_WEB_LOG_RUN
--    profile option value at site level
--
--    does nothing, returns 'S'
--
  procedure noop(
    -- standard parameters
	p_api_version in NUMBER default 1,
	p_init_msg_list	in VARCHAR2 default OKC_API.G_TRUE,
	x_return_status	out nocopy VARCHAR2,
	x_msg_count out nocopy NUMBER,
	x_msg_data out nocopy VARCHAR2,
    -- input parameters
	p_chr_id in NUMBER,
	p_major_version NUMBER default NULL,
	p_scn_id in NUMBER default NULL
  );

--
--    free_temp_clob
--
--    just a wrapper of dbms_clob.freetemporary
--
  procedure free_temp_clob(
	p_clob in out nocopy CLOB
  );

--    public get_k_version
--
--    output MAJOR (might be in as well), MINOR vesions
--    to get rid of default last version
--
--    published for JSP apps to get rid of default versions
--
-- prior 1158 was   procedure get_k_version(p_chr_id number,

  procedure get_k_version(p_chr_id in out nocopy number,
			x_major_version in out nocopy number,
			x_minor_version out nocopy number);

--    public get_sql_name
--
  function get_sql_name(p_sql_id number) return varchar2;

--    public get_new_id
--
  function get_new_id return number;

  function get_new_id(p_entity varchar2) return number;

-- Start of comments
--
-- Procedure Name  : check_name_uk
-- Description     :
-- Business Rules  :
-- Parameters      :
-- Version         : 1.0
-- End of comments

function check_name_uk(p_entity varchar2) return varchar2;

-- Start of comments
--
-- Procedure Name  : return_mess
-- Description     : returns error
-- Business Rules  :
-- Parameters      :
-- Version         : 1.0
-- End of comments

function return_mess(p_mess varchar2) return varchar2;

-- Start of comments
--
-- Procedure Name  : validate parameters
-- Description     : returns errors #, -1 if critical error, 0 - no errors
-- Business Rules  :
-- Parameters      :
-- Version         : 1.0
-- End of comments

function validate_params(p_required_yn varchar2 default 'N') return number;
function set_and_validate(p_array in JTF_VARCHAR2_TABLE_2000,
		p_required_yn varchar2 default 'N') return number;

function get_zero_mess return varchar2;
function get_much_mess return varchar2;
procedure get_labels(
	x_title out nocopy varchar2,
	x_prompt out nocopy varchar2,
	x_message out nocopy varchar2,
	x_name out nocopy varchar2,
	x_description out nocopy varchar2,
	x_sql out nocopy varchar2);
procedure get_actions(
	x_run1 out nocopy varchar2,
	x_run2 out nocopy varchar2,
	x_close out nocopy varchar2);

procedure document_link(
     p_kid in NUMBER,
     p_vid in NUMBER,
     p_xid in NUMBER,
     p_document in out nocopy CLOB);

  --
  -- sample post report trigger to send message to
  -- the wf_role passed in P_RECEPIENT parameter
  --
procedure post_message(
	      p_api_version in NUMBER default 1,
              p_init_msg_list   in VARCHAR2 default OKC_API.G_TRUE,
              x_return_status   out nocopy VARCHAR2,
              x_msg_count out nocopy NUMBER,
              x_msg_data out nocopy VARCHAR2,
              p_chr_id in NUMBER,
              p_major_version NUMBER default NULL,
              p_scn_id in NUMBER default NULL);

  --
  -- just send document from cache
  --
procedure send_document(
     p_recipient varchar2,
     p_subject varchar2,
     p_body varchar2 default NULL,
     p_chr_id in NUMBER,
     p_major_version NUMBER,
     p_xst_id NUMBER);

procedure conc_send_document(
     errbuf out nocopy varchar2,
     retcode out nocopy varchar2,
     p_recipient varchar2,
     p_cc varchar2 default NULL,
     p_bcc varchar2 default NULL,
     p_subject varchar2,
     p_body varchar2 default NULL,
     p_xst_id NUMBER,
     p_chr_id in NUMBER,
     p_major_version NUMBER default NULL);

procedure conc_send_error(
     errbuf out nocopy varchar2,
     retcode out nocopy varchar2,
     p_recipient varchar2,
     p_cc varchar2 default NULL,
     p_xst_id NUMBER,
     p_chr_id in NUMBER);

function run_report_and_send(
     p_recipient 	varchar2,
     p_cc 		varchar2 default NULL,
     p_bcc 		varchar2 default NULL,
     p_subject 		varchar2,
     p_body 		varchar2 default NULL,
     p_xst_id 		NUMBER,
     p_chr_id 		NUMBER,
     p_major_version 	NUMBER default NULL,
     p_err_recipient 	varchar2 default NULL,
     p_err_cc 		varchar2 default NULL
     ) return number;

end OKC_REPORT_PVT;

/
