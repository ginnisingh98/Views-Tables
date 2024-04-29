--------------------------------------------------------
--  DDL for Package Body AP_WEB_UTIL_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."AP_WEB_UTIL_PKG" as
/* $Header: apwutilb.pls 120.1 2005/10/02 20:20:51 albowicz noship $ */

--
-- Encryption routine
--
function encrypt(msg in varchar2) return varchar2
is
  r varchar2(5);
begin
  r := to_char(dbms_random.value(0, 99999), 'FM00000');
  return icx_call.encrypt(r || msg);
end encrypt;

--
-- Decryption routine
--
function decrypt(msg in varchar2) return varchar2
is
begin
    return substr(icx_call.decrypt(msg), 6);
end decrypt;

--
-- Gets the proxy server
--
PROCEDURE GET_PROXY(p_host_name IN VARCHAR2, p_proxy_host OUT nocopy VARCHAR2, p_proxy_port OUT nocopy NUMBER)
IS
  l_proxy VARCHAR2(255);
  l_proxy_port VARCHAR2(255);
BEGIN
  -- First, attempt to get proxy value from FND.  If the proxy name is not
  -- found, try the TCA values regardless of whether the port is found.
  fnd_profile.get('WEB_PROXY_HOST', l_proxy);
  fnd_profile.get('WEB_PROXY_PORT', l_proxy_port);

  IF l_proxy IS NULL AND l_proxy_port IS NULL THEN
    fnd_profile.get('HZ_WEBPROXY_NAME', l_proxy);
    fnd_profile.get('HZ_WEBPROXY_PORT', l_proxy_port);
  END IF;

  p_proxy_host := l_proxy;
  p_proxy_port := to_number(l_proxy_port);
END GET_PROXY;


/*
 * Updates the download columns in AP_CARD_PROGRAMS_ALL
 */
PROCEDURE UPDATE_DOWNLOAD_SIZES(p_card_program_id in NUMBER, p_file_size in NUMBER)
 IS
  l_curr_average_size number;
  l_curr_download_count number;
BEGIN
  SELECT nvl(average_download_size, 0), nvl(download_count, 0)
        INTO l_curr_average_size, l_curr_download_count
        FROM ap_card_programs_all
        WHERE card_program_id = p_card_program_id;

  UPDATE ap_card_programs_all
     SET last_download_date = SYSDATE,
         last_download_size = p_file_size,
         average_download_size = (l_curr_average_size * l_curr_download_count + p_file_size) / (l_curr_download_count + 1),
         download_count = l_curr_download_count + 1
     WHERE card_program_id = p_card_program_id;
END UPDATE_DOWNLOAD_SIZES;

end AP_WEB_UTIL_PKG;

/
