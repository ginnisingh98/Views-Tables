--------------------------------------------------------
--  DDL for Package Body FND_CRYPTO
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."FND_CRYPTO" AS
/* $Header: AFSOCTKB.pls 120.3 2006/07/08 00:50:31 jnurthen noship $ */

  --- ENCRYPT AND DECRYPT ---

  PADRAW CONSTANT raw(36) := hextoraw('010202030303040404040505050505060606' || '060606070707070707070808080808080808');

  -- Bad Type
  BadType EXCEPTION;

  -- Pad Padding (decryption failed)
  BadPadding EXCEPTION;
  PRAGMA EXCEPTION_INIT(BadPadding, -12656);

  --- HASH and MAC ---

  IPAD raw(64) := '36363636363636363636363636363636' ||
                  '36363636363636363636363636363636' ||
                  '36363636363636363636363636363636' ||
                  '36363636363636363636363636363636';
  OPAD raw(64) := '5C5C5C5C5C5C5C5C5C5C5C5C5C5C5C5C' ||
                  '5C5C5C5C5C5C5C5C5C5C5C5C5C5C5C5C' ||
                  '5C5C5C5C5C5C5C5C5C5C5C5C5C5C5C5C' ||
                  '5C5C5C5C5C5C5C5C5C5C5C5C5C5C5C5C';

  --- RANDOM ---

  NORMLZ CONSTANT number := power(2,31);
  SHIFTL CONSTANT number := power(2,32);
  ENCNML CONSTANT number := power(2,63);
  ENCNMM CONSTANT number := power(2,64);
  XTONUM CONSTANT varchar2(32) := 'XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX';

  --- ENCODE AND DECODE ---

  TYPE CharMapType IS TABLE OF BINARY_INTEGER INDEX BY BINARY_INTEGER;

  NUMTOX CONSTANT varchar2(32)  := 'FM0XXXXXXXXXXXXXXX';
  BASE64 CONSTANT number        := power(2,6);

  ENC_B64 CONSTANT varchar2(66) := 'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/=';
  ENC_URL CONSTANT varchar2(66) := 'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789_-.';

  function make_map_to(mapsrc in varchar2) return CharMapType;
  function make_map_from(mapsrc in varchar2) return CharMapType;

  map_to_b64   CONSTANT CharMapType := make_map_to(ENC_B64);
  map_to_url   CONSTANT CharMapType := make_map_to(ENC_URL);
  map_from_b64 CONSTANT CharMapType := make_map_from(ENC_B64);
  map_from_url CONSTANT CharMapType := make_map_from(ENC_URL);

  --- END DECLARATIONS ---

  function numtohex(n in number, siz in pls_integer default 128)
    return varchar2
  is
    ret varchar2(100);
  begin
    if (siz = 128) then
      ret := to_char(trunc(n/power(2,64)), NUMTOX) ||
             to_char(mod  (n,power(2,64)), NUMTOX);
    elsif (siz < 65) then
      ret := to_char(mod  (n,power(2,64)), rpad('FM0X',2+2*trunc((siz+7)/8),'X'));
    else
      ret := to_char(trunc(n/power(2,64)), rpad('FM0X',2+2*trunc((siz-57)/8),'X')) ||
             to_char(mod  (n,power(2,64)), NUMTOX);
    end if;
    return rtrim(ltrim(ret));
  end;

  function NumToTwosComp(num in number)
    return varchar2
  is
    ret raw(100);
  begin
    if (num < 0) then
      return utl_raw.bit_complement(NumToTwosComp(-(num+1)));
    end if;
    if (num < ENCNML) then
      return to_char(mod  (num,power(2,64)), NUMTOX);
    end if;
    return NumToTwosComp(trunc(num/ENCNMM)) || to_char(mod(num,ENCNMM),NUMTOX);
  end NumToTwosComp;

  function TwosCompToNum(r raw)
    return varchar2
  is
    n number;
  begin
    if (to_number(utl_raw.substr(r,1,1),'XX') >= 128) then
      return -TwosCompToNum(utl_raw.bit_complement(r))-1;
    end if;
    if (utl_raw.length(r) <= 16) then
      return to_number(r, XTONUM);
    end if;
    return TwosCompToNum(utl_raw.substr(r,1,utl_raw.length(r)-16))*power(2,128)+
           to_number(utl_raw.substr(r,-16), XTONUM);
  end TwosCompToNum;

    ---------------------- ENCRYPT AND DECRYPT ------------------------

  function pkcs5pad(s raw) return raw
  is
    pad number;
  begin
    pad := 8 - MOD(utl_raw.length(s),8);
    return utl_raw.concat(s, utl_raw.substr(PADRAW, pad*(pad-1)/2+1,pad));
  end pkcs5pad;

  function des3e(s in raw,
                 k in raw,
                 i in raw,
                 pd in varchar2) return raw is
    t RAW(32767);
  begin
    if (upper(substr(pd,1,1)) = 'Y') then
      t := pkcs5pad(s);
    else
      t := s;
    end if;
    t := utl_raw.bit_xor(t, '0123456789ABCDEF');
    if (i is not null) then
      t := utl_raw.bit_xor(t, utl_raw.substr(i,1,8));
    end if;
    t := SYS.dbms_obfuscation_toolkit.DES3Encrypt
           (input=>t, key=>k,
which=>SYS.dbms_obfuscation_toolkit.ThreeKeyMode);
    return t;
  end des3e;

  FUNCTION Encrypt (plaintext   IN RAW,
                    crypto_type IN PLS_INTEGER,
                    key         IN RAW,
                    iv          IN RAW)
    RETURN RAW is
    l_encrypted raw(32767);
  begin
    if crypto_type = DES3_CBC_PKCS5
    then
      l_encrypted :=  des3e(s => plaintext,
                            k => key,
                            i => iv,
                            pd => 'Y');
    else
      raise BadType;
    end if;
    return l_encrypted;
  end Encrypt;

  function pkcs5unpad(s raw) return raw
  is
    pad number;
  begin
    pad := TO_NUMBER(rawtohex(utl_raw.substr(s, -1)), 'XX');
    if (pad < 1 or pad > 8) then raise BadPadding; end if;

    if utl_raw.compare(utl_raw.substr(PADRAW, pad*(pad-1)/2+1, pad),
                       utl_raw.substr(s, -pad)) <> 0 then
      raise BadPadding;
    end if;

    return utl_raw.substr(s, 1, utl_raw.length(s) - pad);
  end pkcs5unpad;

  function des3d(s in raw,
                 k in raw,
                 i in raw,
                 pd in varchar2)
           return raw is
    t RAW(32767);
  begin
    t := SYS.dbms_obfuscation_toolkit.DES3Decrypt
           (input=>s, key=>k,
which=>SYS.dbms_obfuscation_toolkit.ThreeKeyMode);
    t := utl_raw.bit_xor(t, '0123456789ABCDEF');
    if (i is not null) then
      t := utl_raw.bit_xor(t, utl_raw.substr(i,1,8));
    end if;
    if (upper(substr(pd,1,1)) = 'Y') then
      t := pkcs5unpad(t);
    end if;
    return t;
  end des3d;

  FUNCTION Decrypt (cryptext    IN RAW,
                    crypto_type IN PLS_INTEGER,
                    key         IN RAW,
                    iv          IN RAW)
    RETURN RAW is
    l_decrypted raw(32767);
  begin
    if crypto_type = DES3_CBC_PKCS5
    then
      l_decrypted :=  des3d(s => cryptext,
                            k => key,
                            i => iv,
                            pd => 'Y');
    else
      raise BadType;
    end if;

    return l_decrypted;
  end;


  FUNCTION EncryptNum(num       IN NUMBER,
                      key       IN RAW,
                      iv        IN RAW         DEFAULT NULL)
    RETURN VARCHAR2
  IS
  BEGIN
    return encode(des3e(NumToTwosComp(num), key, iv, 'N'), ENCODE_URL);
  END EncryptNum;


  FUNCTION DecryptNum(cryptext  IN VARCHAR2,
                      key       IN RAW,
                      iv        IN RAW         DEFAULT NULL)
    RETURN NUMBER
  IS
  BEGIN
    return TwosCompToNum(des3d(decode(cryptext,ENCODE_URL),key,iv,'N'));
  END DecryptNum;


  ---------------------- HASH and MAC ------------------------

    FUNCTION Hash (source    IN RAW,
                   hash_type IN PLS_INTEGER)
      RETURN RAW is
    begin
      return SYS.dbms_obfuscation_toolkit.md5(input => source);
    end;

    function kmd5_alg(src raw, key raw) return raw
    is
      ipk raw(64);
      opk raw(64);
      hsh raw(16);
    begin
      if (utl_raw.length(key) > 64) then
        ipk := SYS.dbms_obfuscation_toolkit.md5(input => key);
      else
        ipk := key;
      end if;
      if (utl_raw.length(ipk) < 64) then
        ipk := utl_raw.concat(ipk, rpad('0',128-2*utl_raw.length(ipk), '0'));
      end if;
      opk := utl_raw.bit_xor(ipk, OPAD);
      ipk := utl_raw.bit_xor(ipk, IPAD);

      hsh := SYS.dbms_obfuscation_toolkit.md5(input => utl_raw.concat(ipk, src));
      hsh := SYS.dbms_obfuscation_toolkit.md5(input => utl_raw.concat(opk, hsh));
      return hsh;
    end kmd5_alg;

    FUNCTION Mac (source   IN RAW,
                  mac_type IN PLS_INTEGER,
                  key      IN RAW)
      RETURN RAW
    is
      tmp raw(16);
    begin
      if mac_type = HMAC_MD5
      then
        tmp := kmd5_alg(source, key);
      elsif mac_type = HMAC_CRC
      then
        null; -- to be added
      else
        tmp := kmd5_alg(source, key);
      end if;
      return tmp;
    end;

  ---------------------- RANDOM ------------------------

  FUNCTION RandomBytes(number_bytes IN POSITIVE)
    RETURN RAW is
    ret raw(32767);
    tmp raw(2000);
    len number := number_bytes;
  begin
    while (len <> 0) loop
      if (len < 2000) then
        tmp := FND_RANDOM_NUMBER.GET_RANDOM_BYTES(len);
      else
        tmp := FND_RANDOM_NUMBER.GET_RANDOM_BYTES(2000);
      end if;
      ret := utl_raw.concat(ret, tmp);
      len := len - utl_raw.length(tmp);
    end loop;
    return ret;
  end RandomBytes;


  FUNCTION RandomNumber
    RETURN NUMBER is
  begin
    return to_number(rawtohex(RandomBytes(16)), XTONUM);
  end RandomNumber;

  FUNCTION SmallRandomNumber
    RETURN NUMBER is
    l_number number;
  begin

    loop
      l_number := floor(to_number(rawtohex(RandomBytes(4)), XTONUM)/2);
      exit when l_number > 0 and l_number < 2147483647;
    end loop;

    return l_number;
  end SmallRandomNumber;


  ---------------------- ENCODE AND DECODE ------------------------

  function encodeunit(unit in raw, len in pls_integer, mp in CharMapType)
  return varchar2
  is
    na number      := to_number(rawtohex(unit),'XXXXXXXXXXXXXXXXXXXXXXXX');
    nb number      := 0;
    ln pls_integer := len;
  begin
    ln := mod(len, 3);
    if (ln = 0) then
      ln := 4*len/3;
    elsif (ln = 1) then
      nb := 257 * mp(64);
      na := na * 16;
      ln := (4*len + 2)/3;
    else
      nb := mp(64);
      na := na * 4;
      ln := (4*len + 1)/3;
    end if;

    while (ln > 0) loop
      nb := 256 * nb + mp(mod(na, BASE64));
      na := trunc(na / BASE64);
      ln := ln - 1;
    end loop;

    return utl_raw.cast_to_varchar2(utl_raw.reverse(numtohex(nb, 8*4*trunc((len+2)/3))));
  end encodeunit;

  function encodedrop(unit in raw, len in pls_integer, mp in CharMapType)
  return varchar2
  is
    na number      := to_number(rawtohex(unit),'XXXXXXXXXXXXXXXXXXXXXXXX');
    nb number      := 0;
    ln pls_integer := len;
  begin
    while (ln > 0) loop
      nb := 256 * nb + mp(mod(na, BASE64));
      na := trunc(na / 256);
      ln := ln - 1;
    end loop;

    return utl_raw.cast_to_varchar2(utl_raw.reverse(numtohex(nb, 8*len)));
  end encodedrop;

  function make_map_to(mapsrc in varchar2) return CharMapType
  is
    tmp CharMapType;
    val raw(256):= utl_raw.cast_to_raw(mapsrc);
  begin
    for j in 1..utl_raw.length(val) LOOP
      tmp(j-1) := to_number(utl_raw.substr(val, j, 1),'XX');
    end LOOP;
    return tmp;
  end make_map_to;

  function make_map_from(mapsrc in varchar2) return CharMapType
  is
    tmp CharMapType;
    val raw(256):= utl_raw.cast_to_raw(mapsrc);
  begin
    for j in 1..utl_raw.length(val) LOOP
      tmp(to_number(utl_raw.substr(val, j, 1),'XX')) := j - 1;
    end LOOP;
    return tmp;
  end make_map_from;

  function get_map(m in pls_integer, drp in out NOCOPY boolean) return CharMapType
  is
  begin
    drp := false;
    if    (m =  ENCODE_B64) then              return map_to_b64;
    elsif (m =  ENCODE_URL) then              return map_to_url;
    elsif (m =  ENCODE_ORC) then drp := true; return map_to_url;
    elsif (m = -ENCODE_B64) then              return map_from_b64;
    elsif (m = -ENCODE_URL) then              return map_from_url;
    elsif (m = -ENCODE_ORC) then drp := true; return map_from_url;
    end if;
  end get_map;

  FUNCTION Encode (source   IN RAW,
                   fmt_type IN PLS_INTEGER)
    RETURN VARCHAR2 is
    cur number := 1;
    len number := utl_raw.length(source) + 1;
    nxt number := len - cur;
    ret varchar2(32767);
    drp boolean;
    mp CharMapType := get_map(fmt_type, drp);
  begin
    while (nxt > 0) loop
      if (nxt > 12) then nxt := 12; end if;
      if (not drp) then
        ret := ret || encodeunit(utl_raw.substr(source, cur, nxt), nxt, mp);
      else
        ret := ret || encodedrop(utl_raw.substr(source, cur, nxt), nxt, mp);
      end if;
      cur := cur + nxt;
      nxt := len - cur;
    end loop;
    return ret;
  end Encode;

  function decodeunit(unit in varchar2, mp in CharMapType)
  return raw
  is
    na number      := to_number(utl_raw.reverse(utl_raw.cast_to_raw(unit)),'XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX');
    nb number      := 0;
    nc number;
    ln pls_integer := 0;
  begin
    while (na > 0) loop
      nc := mp(mod(na, 256));
      if (nc = 64) then
        na := 0;
      else
        ln := ln + 6;
        nb := BASE64 * nb + nc;
      end if;
      na := trunc(na / 256);
    end loop;

    nc := mod(ln, 8);
    if (nc > 0) then
      ln := ln - nc;
      nb := nb / power(2,nc);
    end if;

    return numtohex(nb, ln);
  end decodeunit;

  function decodedrop(unit in varchar2, mp in CharMapType)
  return raw
  is
    na number      := to_number(utl_raw.reverse(utl_raw.cast_to_raw(unit)),'XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX');
    nb number      := 0;
    ln pls_integer := 0;
  begin
    while (na > 0) loop
      nb := 256 * nb + mp(mod(na, 256));
      na := trunc(na / 256);
      ln := ln + 8;
    end loop;

    return numtohex(nb, ln);
  end decodedrop;

  FUNCTION Decode (source   IN VARCHAR2,
                   fmt_type IN PLS_INTEGER)
    RETURN RAW is
    cur number := 1;
    len number := length(source) + 1;
    nxt number := len - cur;
    ret raw(32767);
    drp boolean;
    mp CharMapType := get_map(-fmt_type, drp);
  begin
    while (nxt > 0) loop
      if (nxt > 16) then nxt := 16; end if;
      if (not drp) then
        ret := ret || decodeunit(substr(source, cur, nxt), mp);
      else
        ret := ret || decodedrop(substr(source, cur, nxt), mp);
      end if;
      cur := cur + nxt;
      nxt := len - cur;
    end loop;
    return ret;
  end Decode;

  function RandomString(len  IN INTEGER,
                        msk  IN VARCHAR2 default FND_CRYPTO_CONSTANTS.ALPHANUMERIC_UPPER_MASK,
                        sublen IN INTEGER default 0,
                        sublen_msk IN VARCHAR2 default FND_CRYPTO_CONSTANTS.ALPHABETIC_UPPER_MASK)
           return VARCHAR2  IS


    r_char varchar2(4000);
    mask VARCHAR2(4000);
    mask_length NUMBER;
	sublenmask_length NUMBER;
    out_length NUMBER;

  BEGIN


    IF sublen > len THEN
      RAISE VALUE_ERROR;
    END IF;

    IF (len > 1000) THEN
      RAISE VALUE_ERROR;
    ELSE
      out_length := len-sublen;
    END IF;

    IF (msk is null) or (sublen_msk is null and sublen > 0) then
      RAISE VALUE_ERROR;
    END IF;

    IF sublen > 0 THEN
      sublenmask_length := length(sublen_msk);
    END IF;
    mask_length := length(msk);

    FOR i in 1..sublen LOOP
      r_char := r_char || substr(sublen_msk,mod(fnd_crypto.randomnumber,sublenmask_length)+1,1);
    END LOOP;


    FOR i IN 1..out_length LOOP
      r_char := r_char || substr(msk,mod(fnd_crypto.randomnumber,mask_length)+1,1);
    END LOOP;
    RETURN r_char;
  END RandomString;

END fnd_crypto;

/
