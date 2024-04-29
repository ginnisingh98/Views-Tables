--------------------------------------------------------
--  DDL for Package ORACLENAVIGATE
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."ORACLENAVIGATE" AUTHID CURRENT_USER as
/* $Header: ICXSENS.pls 120.3 2007/11/21 19:46:31 amgonzal ship $ */

function security_group(p_responsibility_id number,
                        p_application_id number) return boolean;

procedure displayUnderConstruction;

procedure Responsibility(P in pls_integer default NULL,
                         D in varchar2 default NULL,
                         S in pls_integer default NULL,
                         M in pls_integer default NULL,
                         tab_context_flag in varchar2 default 'ON');

procedure Navigate(p_session_id pls_integer default null,
                   p_plug_id    pls_integer default null,
                   p_display_name  varchar2 default NULL,
                   p_delete     varchar2 default 'N');

procedure Favorites(p_session_id pls_integer default null,
                   p_plug_id    pls_integer default null,
                   p_display_name  varchar2 default NULL,
                   p_delete     varchar2 default 'N');

procedure FavoriteCreate;

procedure FavoriteRename(item_name in varchar2 default null);

procedure customizeFavorites(X in pls_integer);

procedure updateFavorites(X in varchar2,
			  Y in pls_integer);

c_ampersand constant varchar2(1) := '&';

PROCEDURE menuBypass(p_token IN VARCHAR2,
                     p_mode  IN VARCHAR2);

PROCEDURE menuBypass(p_token IN VARCHAR2);

end OracleNavigate;

/
