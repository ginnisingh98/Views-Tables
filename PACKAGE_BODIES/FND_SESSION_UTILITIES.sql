--------------------------------------------------------
--  DDL for Package Body FND_SESSION_UTILITIES
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."FND_SESSION_UTILITIES" as
/* $Header: AFICXSUB.pls 120.1.12010000.4 2013/06/05 17:09:01 fskinner ship $ */

  function SessionID_to_XSID(p_session_id in number) return varchar2
  is
    l_XSID varchar2(32);
  begin
    select XSID
    into   l_XSID
    from   ICX_SESSIONS
    where  SESSION_ID = p_session_id;
    if l_XSID is null
    then
      l_XSID := icx_call.encrypt3(p_session_id);
    end if;

    return l_XSID;

  exception
    when no_data_found then
      l_XSID := NULL;
      return l_XSID;
  end SessionID_to_XSID;

  function XSID_to_SessionID(p_XSID in varchar2) return number
  is
    l_SessionID number;
    l_module varchar2(200):= 'fnd.plsql.FND_SESSION_UTILITIES.XSID_to_SessionID';
  begin
    if (fnd_log.LEVEL_STATEMENT >= fnd_log.G_CURRENT_RUNTIME_LEVEL) then
      fnd_log.string(fnd_log.LEVEL_STATEMENT, l_module, 'Hijack log: in xsid to
sessionid for xsid: '||p_xsid);
    end if;

    -- if substrb(p_XSID,-2,2) <> ':S'
    -- New method to generate XSID (NewXSID) always generates XSID
    -- of length 26. Whereas the old method (encrypt3) always generates
    -- the value in lengths of multiple of 16 (ex: 16,32,64)
    if length(p_XSID) <> 26
    then
      if (fnd_log.LEVEL_STATEMENT >= fnd_log.G_CURRENT_RUNTIME_LEVEL) then
        fnd_log.string(fnd_log.LEVEL_STATEMENT, l_module, 'Hijack log: in xsid
to ses - p_XSID <> 26...call decrypt3');
      end if;

      l_SessionID := icx_call.decrypt3(p_XSID);
    else
      if (fnd_log.LEVEL_STATEMENT >= fnd_log.G_CURRENT_RUNTIME_LEVEL) then
        fnd_log.string(fnd_log.LEVEL_STATEMENT, l_module, 'Hijack log: in xsid
to ses = 26 - query icx_sessions');
      end if;

      select SESSION_ID
      into   l_SessionID
      from   ICX_SESSIONS
      where  XSID = p_XSID;
    end if;

    if (fnd_log.LEVEL_STATEMENT >= fnd_log.G_CURRENT_RUNTIME_LEVEL) then
      fnd_log.string(fnd_log.LEVEL_STATEMENT, l_module, 'Hijack log: in xsid to
sessionid return sessionid: '||l_sessionID);
    end if;

    return l_SessionID;

  exception
    when no_data_found then
      l_SessionID := NULL;
      return l_SessionID;
  end XSID_to_SessionID;

  function TransactionID_to_XTID(p_transaction_id in number) return varchar2
  is
  -- l_XTID varchar2(32);
  begin

    return p_transaction_id;

  end TransactionID_to_XTID;


  function XTID_to_TransactionID(p_XTID in varchar2) return number
  is
    l_TransactionID number;
  begin

    -- nlbarlow, have to still support backward compatibility.
    begin

  if (translate(p_XTID, 'ABCDEFGHIJKLMNOPQRSTUVWXYZ',
        'xxxxxxxxxxxxxxxxxxxxxxxxxx') <> p_XTID)
       then
     l_TransactionID := icx_call.decrypt3(p_XTID);

   else

      select TRANSACTION_ID
      into   l_TransactionID
      from   ICX_TRANSACTIONS
      where  TRANSACTION_ID = p_XTID;

  end if;

/*

    exception
      when no_data_found then
        l_TransactionID := NULL;
      when others then
        l_TransactionID := icx_call.decrypt3(p_XTID);
*/


     exception
     when no_data_found then
      l_TransactionID := NULL;

    end;

    return l_TransactionID;

  end XTID_to_TransactionID;







  function MAC(p_source in varchar2,
               p_session_id in number) return varchar2 is
    l_source raw(2000);
    l_key    raw(20);
    l_mac    raw(16);
  begin

    l_source := utl_raw.cast_to_raw(p_source);

    select MAC_KEY
    into   l_key
    from   ICX_SESSIONS
    where  SESSION_ID = p_session_id;

    l_mac := fnd_crypto.mac(source => l_source,
                            mac_type => fnd_crypto.HMAC_MD5,
                            key => l_key);

    return fnd_crypto.encode(source => l_mac,
                             fmt_type => fnd_crypto.ENCODE_URL);

   exception
     when no_data_found then
     l_mac := NULL;
     return l_mac;

  end;

end FND_SESSION_UTILITIES;

/
