--------------------------------------------------------
--  DDL for Package AP_WEB_UTIL_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."AP_WEB_UTIL_PKG" AUTHID CURRENT_USER as
/* $Header: apwutils.pls 120.1 2005/10/02 20:20:57 albowicz noship $ */

/*
 * Encrypts a string
 *
 * @param msg String to be encrypted.
 * @return Encrypted string
 */
function encrypt(msg in varchar2) return varchar2;


/*
 * Decrypts a string that was encrypted by encrypt().
 *
 * @param msg Encrypted string
 * @return Decrypted message
 */
function decrypt(msg in varchar2) return varchar2;


/*
 * Given the host name, returns the proxy host/port to go through.
 * Uses the profile options WEB_PROXY_HOST and WEB_PROXY_PORT. If these are not set,
 * then it uses the profile options HZ_WEBPROXY_NAME and HZ_WEBPROXY_PORT.
 *
 * This procedure currently assumes that the host that is being accessed will reside outside
 * the firewall and does not honor the WEB_PROXY_BYPASS_DOMAINS profile option.
 * <i>This is an enhancement that is probably needed.</i>
 *
 * @param p_host_name The name of the host that you are trying to access. (Currently not used)
 * @param p_proxy_host Hostname of the proxy server.
 * @param p_proxy_port Port of the proxy server.
 */
PROCEDURE GET_PROXY(p_host_name IN VARCHAR2, p_proxy_host OUT nocopy VARCHAR2, p_proxy_port OUT nocopy NUMBER);


/*
 * Updates the download columns in AP_CARD_PROGRAMS_ALL
 */
PROCEDURE UPDATE_DOWNLOAD_SIZES(p_card_program_id in NUMBER, p_file_size in NUMBER);

end AP_WEB_UTIL_PKG;

 

/
