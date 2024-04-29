--------------------------------------------------------
--  DDL for Package BIS_RL_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."BIS_RL_PKG" AUTHID CURRENT_USER AS
/* $Header: BISVEXLS.pls 120.4 2006/07/28 06:44:23 nkishore ship $ */
-- dbdrv: sql ~PROD ~PATH ~FILE none none none package &phase=pls \
-- dbdrv: checkfile(115.34=120.4):~PROD:~PATH:~FILE

/*
REM +=======================================================================+
REM |    Copyright (c) 1998 Oracle Corporation, Redwood Shores, CA, USA     |
REM |                         All rights reserved.                          |
REM +=======================================================================+
REM | FILENAME                                                              |
REM |     BISVEXLS.pls                                                      |
REM |                                                                       |
REM | DESCRIPTION                                                           |
REM |     This is the Related Links Pkg. for PMV.			    			|
REM |                                                                       |
REM | HISTORY                                                               |
REM | amkular,  06/25/1999, Initial Creation				    			|
REM | nkishore, 12/10/2002, Added updateRelatedLink_Wrapper, 	    	    |
REM | 			        reorderRelatedLinks, getAllRespFuncnSQLWrapper 	|
REM | ansingh    12/24/02    Added Wrappers for Preseeding RL Enhancement   |
REM | ansingh    01/08/03    Added function isUserIdInLinkParams            |
REM | mdamle     03/12/04    Enh 3503753 - Site level custom. for links  	|
REM | mdamle     05/28/04    Added delete API to be called from LCT file  	|
REM | mdamle     08/09/04    Bug# 3813449 - New API to copy links to dup rpt|
REM +=======================================================================+
*/

  -- mdamle 03/12/04 - Enh 3503753 - Site level custom. for links
  CUSTOM_SITE_LEVEL CONSTANT VARCHAR2(4) := 'SITE';
  CUSTOM_RESP_LEVEL CONSTANT VARCHAR2(4) := 'RESP';
  CUSTOM_ORG_LEVEL CONSTANT VARCHAR2(3) := 'ORG';
  CUSTOM_APP_LEVEL CONSTANT VARCHAR2(3) := 'APP';
  CUSTOM_FUNCTION_LEVEL CONSTANT VARCHAR2(8) := 'FUNCTION';
  CUSTOM_USER_LEVEL CONSTANT VARCHAR2(4) := 'USER';

procedure FavoriteCreate
;

procedure FavoriteRename
;

PROCEDURE Build_Related_Information_HTML
( p_image_directory      IN         VARCHAR2
 ,p_ICX_Report_Link      IN         VARCHAR2
 ,p_function_id          IN         NUMBER
 ,p_Responsibility_id    IN         NUMBER
 ,p_user_id              IN         NUMBER
 ,p_session_id           IN         VARCHAR2
 ,x_HTML                 IN OUT     NOCOPY VARCHAR2
 ,p_function_name        in         varchar2 default null);

c_ampersand constant varchar2(1) := '&';

-- mdamle 03/12/2001 - Related Links
PROCEDURE addRelatedlink_Wrapper( p_user_id			IN VARCHAR2,
 p_resp_id			IN VARCHAR2,
 p_function_id			IN VARCHAR2,
 p_linked_function_id	IN VARCHAR2,
 p_user_link_name		IN VARCHAR2,
 p_link_type			IN VARCHAR2,
 p_url				IN VARCHAR2,
 p_custom_Level			IN VARCHAR2,  -- mdamle 03/12/04 - Enh 3503753 - Site level custom. for links - custom table
 p_custom_level_value   IN VARCHAR2); -- mdamle 03/12/04 - Enh 3503753 - Site level custom. for links - custom table


-- mdamle 03/12/2001 - Related Links Wrapper for Java
procedure getRespSQLWrapper
  ( p_user_id IN PLS_INTEGER
  , p_resp_sql OUT NOCOPY varchar2
  ) ;

-- mdamle 03/12/2001 - Related Links Wrapper for Java
procedure deleteRelatedLink_Wrapper(
 p_related_link_id pls_integer
,p_isPreseed IN VARCHAR2 ); -- mdamle 03/12/04 - Enh 3503753 - Site level custom. for links

--serao  02/25/02 - for relatedlink portlet
PROCEDURE add_rl_from_function (
  pFunction_name IN VARCHAR2,
  pUserId In NUMBER,
  pPlugId IN NUMBER
) ;

--ansingh
procedure PRESEED_TO_NORMAL_WRAPPER(p_user_id in varchar2,
		  				  p_resp_id in varchar2,
		  				  p_function_id in varchar2,
						  p_related_link_id in varchar2,
						  p_user_link_name in varchar2,
						  p_link_type in varchar2,
						  p_url in varchar2);

--nbarik added for Updating the Related LInks
-- mdamle 03/12/04 - Enh 3503753 - Site level custom. for links
PROCEDURE UPDATERELATEDLINK_WRAPPER(
 p_related_link_id		IN PLS_INTEGER,
 p_related_link_name	IN VARCHAR2,
 p_user_url			IN VARCHAR2 DEFAULT NULL,
 p_isPreseed 			IN VARCHAR2);


--nbarik
procedure reorderRelatedLinks(p_content_string in varchar2,
					  p_isPreseed IN VARCHAR2); -- mdamle 03/12/04 - Enh 3503753 - Site level custom. for links


--msaran: SQL Literals project
procedure getRespFuncnSQLWrap
  ( p_user_id IN PLS_INTEGER
  , p_resp_id IN PLS_INTEGER
  , p_report_function_id IN PLS_INTEGER
  , p_search_criteria IN VARCHAR2
  , p_funcn_sql OUT NOCOPY VARCHAR2
  , p_bind_count OUT NOCOPY NUMBER
  , p_bind_string OUT NOCOPY VARCHAR2
  );

--msaran: SQL Literals project
procedure getAllRespFuncnSQLWrap
  ( p_user_id IN PLS_INTEGER
  , p_resp_id IN VARCHAR2
  , p_report_function_id IN PLS_INTEGER
  , p_search_criteria IN VARCHAR2
  , p_funcn_sql OUT NOCOPY VARCHAR2
  , p_bind_count OUT NOCOPY NUMBER
  , p_bind_string OUT NOCOPY VARCHAR2
  );

--msaran: SQL Literals project
procedure getAllRespRLPortletsSQLWrap
  ( p_user_id IN PLS_INTEGER
  , p_resp_id IN VARCHAR2
  , p_report_function_id IN PLS_INTEGER
  , p_search_criteria IN VARCHAR2
  , p_funcn_sql OUT NOCOPY VARCHAR2
  , p_bind_count OUT NOCOPY NUMBER
  , p_bind_string OUT NOCOPY VARCHAR2
  );

--msaran: SQL Literals project
procedure getRespRLPortletsSQLWrap
  ( p_user_id IN PLS_INTEGER
  , p_resp_id IN VARCHAR2
  , p_report_function_id IN PLS_INTEGER
  , p_search_criteria IN VARCHAR2
  , p_funcn_sql OUT NOCOPY VARCHAR2
  , p_bind_count OUT NOCOPY NUMBER
  , p_bind_string OUT NOCOPY VARCHAR2
  );

--ansingh
FUNCTION isUserIdInLinkParams (p_userId IN VARCHAR2,
                               p_linkParams IN VARCHAR2
                               ) RETURN VARCHAR2;

--serao ,06/03
-- mdamle 03/12/04 - Enh 3503753 - Site level custom. for links
PROCEDURE copyLinksFromPrevLevel (
  p_report_function_id 	IN VARCHAR2,
  p_user_id			IN VARCHAR2,
  p_custom_level 		IN VARCHAR2,
  p_custom_level_value 	IN VARCHAR2,
  p_plug_id			IN VARCHAR2 := NULL
);

-- mdamle 03/12/04 - Enh 3503753 - Site level custom. for links
PROCEDURE insertCustomLinks(
 p_related_link_id in number,
 p_display_sequence in number,
 p_function_id in number,
 p_responsibility_id in number,
 p_security_group_id in number,
 p_responsibility_app_id in number,
 p_linked_function_id in number,
 p_link_type in varchar2,
 p_user_url in varchar2,
 p_user_link_name in varchar2,
 p_level_site_id in number,
 p_level_resp_id in number,
 p_level_app_id in number,
 p_level_org_id in number,
 p_level_function_id in number,
 p_level_user_id in number,
 p_user_id in number);

function getPreviousCustomizationLevel(
 p_function_id in number
,p_custom_level in varchar2) RETURN VARCHAR2;

-- mdamle 05/28/2004 - Delete API to be called from LCT file
procedure delete_function_links (
 p_function_id					IN number
,x_return_status                OUT NOCOPY VARCHAR2
,x_msg_count                    OUT NOCOPY NUMBER
,x_msg_data                     OUT NOCOPY VARCHAR2
);


-- mdamle 05/28/2004 - Load API to be called from LCT file
procedure load_row (
 p_function_id					IN NUMBER
,p_user_id					IN NUMBER
,p_link_type					IN VARCHAR2
,p_linked_function_id			IN NUMBER
,p_user_url					IN VARCHAR2
,p_resp_id					IN NUMBER
,p_sec_grp_id					IN NUMBer
,p_resp_app_id					IN NUMBER
,p_display_sequence				IN NUMBER
,p_user_link_name				IN VARCHAR2
,p_login_id					IN NUMBER
,x_return_status                OUT NOCOPY VARCHAR2
,x_msg_count                    OUT NOCOPY NUMBER
,x_msg_data                     OUT NOCOPY VARCHAR2
);

-- mdamle 05/28/2004 - Translate API to be called from LCT file
procedure translate_row (
 p_function_id					IN NUMBER
,p_display_sequence				IN VARCHAR2
,p_user_link_name				IN VARCHAR2
,p_user_id					IN NUMBER
,p_login_id					IN NUMBER
,x_return_status                OUT NOCOPY VARCHAR2
,x_msg_count                    OUT NOCOPY NUMBER
,x_msg_data                     OUT NOCOPY VARCHAR2
);

procedure copy_report_links (
 p_source_function_id			IN number
,p_dest_function_id				IN number
,p_user_id					IN number
,x_return_status                OUT NOCOPY VARCHAR2
,x_msg_count                    OUT NOCOPY NUMBER
,x_msg_data                     OUT NOCOPY VARCHAR2
);

PROCEDURE Add_Language;

END BIS_RL_PKG;

 

/
