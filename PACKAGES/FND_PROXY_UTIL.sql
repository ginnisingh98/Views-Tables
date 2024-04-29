--------------------------------------------------------
--  DDL for Package FND_PROXY_UTIL
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."FND_PROXY_UTIL" AUTHID CURRENT_USER AS
/* $Header: AFPRXUTS.pls 120.1 2005/07/02 04:14:01 appldev noship $ */

 -- GET the Web Proxy Username

 FUNCTION get_web_proxy_username RETURN VARCHAR2;

 -- GET the Web Proxy Password

 FUNCTION get_web_proxy_pw RETURN VARCHAR2;


 -- PUT the Web Proxy Username

 PROCEDURE put_web_proxy_username(p_val IN VARCHAR2);

 -- PUT the Web Proxy Password

 PROCEDURE put_web_proxy_pw(p_val IN VARCHAR2);


 -- DELete the Web Proxy Username

 PROCEDURE del_web_proxy_username;

 -- DELete the Web Proxy Password

 PROCEDURE del_web_proxy_pw;

END;

 

/
