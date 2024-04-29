--------------------------------------------------------
--  DDL for Package ORACLESSWA
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."ORACLESSWA" AUTHID CURRENT_USER as
/* $Header: ICXSSWAS.pls 120.0 2005/10/07 12:20:56 gjimenez noship $ */

    procedure bookmarkthis (icxtoken in varchar2,
                            p        in varchar2 default NULL);

    -- OA Framework version of bookmarkthis which can do some really
    -- neat stuff for the current responsibility portlet - blow away
    -- every cached version for the current user!

    procedure FwkBookmarkThis (icxtoken in varchar2,
                               p        in varchar2 default NULL);

    procedure switchpage (pagename in varchar2);

    /* construct listener_token */

    Function listener_token return varchar2;

    /* SSO call back to create valid OSSWA session */

    Procedure sign_on (urlc in varchar2);

    procedure navigate;

    PROCEDURE convertSession;

      procedure execute (F IN VARCHAR2 DEFAULT NULL,
                         E in VARCHAR2 DEFAULT NULL,
                         P IN VARCHAR2 DEFAULT NULL,
                         L IN VARCHAR2 DEFAULT NULL);


FUNCTION SSORedirect (p_req_url IN VARCHAR2 DEFAULT NULL,
                      p_cancel_url IN VARCHAR2 DEFAULT NULL)
                      RETURN VARCHAR2;

PROCEDURE logout;
end OracleSSWA;

 

/
