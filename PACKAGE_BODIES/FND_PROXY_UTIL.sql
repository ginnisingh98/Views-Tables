--------------------------------------------------------
--  DDL for Package Body FND_PROXY_UTIL
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."FND_PROXY_UTIL" AS
/* $Header: AFPRXUTB.pls 120.1 2005/07/02 04:13:56 appldev noship $ */
 -- Internal Constants
 c_wp_svc constant VARCHAR2(32) := 'WEB_PROXY';
 c_wp_un  constant VARCHAR2(32) := 'USERNAME';
 c_wp_pw  constant VARCHAR2(32) := 'PASSWORD';

 -- GET the Web Proxy Username

 FUNCTION get_web_proxy_username RETURN VARCHAR2
 IS
 BEGIN
	return fnd_vault.get(c_wp_svc, c_wp_un);
 END get_web_proxy_username;

 -- GET the Web Proxy Password

 FUNCTION get_web_proxy_pw RETURN VARCHAR2
 IS
 BEGIN
	return fnd_vault.get(c_wp_svc, c_wp_pw);
 END get_web_proxy_pw;


 -- PUT the Web Proxy Username

 PROCEDURE put_web_proxy_username(p_val IN VARCHAR2)
 IS
 BEGIN
 	fnd_vault.put(c_wp_svc, c_wp_un, p_val);
 END put_web_proxy_username;

 -- PUT the Web Proxy Password

 PROCEDURE put_web_proxy_pw(p_val IN VARCHAR2)
 IS
 BEGIN
	fnd_vault.put(c_wp_svc, c_wp_pw, p_val);
 END put_web_proxy_pw;


 -- DELete the Web Proxy Username

 PROCEDURE del_web_proxy_username
 IS
 BEGIN
	fnd_vault.del(c_wp_svc, c_wp_un);
 END del_web_proxy_username;

 -- DELete the Web Proxy Password

 PROCEDURE del_web_proxy_pw
 IS
 BEGIN
 	fnd_vault.del(c_wp_svc, c_wp_pw);
 END del_web_proxy_pw;

END;

/
