--------------------------------------------------------
--  DDL for Package Body IBE_MSITE_GRP
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IBE_MSITE_GRP" AS
  /* $Header: IBEGMSTB.pls 120.7.12010000.2 2016/10/18 19:53:30 ytian ship $ */

master_msite_exists_exception EXCEPTION;
store_not_exists_exception exception;
msite_default_lang_missing EXCEPTION;
msite_default_org_missing  EXCEPTION;
msite_default_currency_missing EXCEPTION;
msite_languages_missing    EXCEPTION;
msite_orgs_missing  EXCEPTION;
msite_currencies_missing EXCEPTION;


FUNCTION msite_default_lang_exists(p_msite_id IN NUMBER )
                                   RETURN BOOLEAN
IS
  CURSOR valid_msite_lang_cur(p_msite_id IN NUMBER)  IS
    select 1 from dual where exists (
      select msite_id
      from ibe_msites_b
      where  msite_id = p_msite_id
      and    default_language_code is not null );

    l_exists NUMBER;
    l_return_status Boolean := false;
BEGIN
  OPEN valid_msite_lang_cur(p_msite_id);
  FETCH valid_msite_lang_cur INTO l_exists;
  IF valid_msite_lang_cur%FOUND THEN
    l_return_status := true;
  end if;
  close valid_msite_lang_cur;
  return l_return_status;
EXCEPTION
   WHEN OTHERS THEN
     IF valid_msite_lang_cur%ISOPEN THEN
     close valid_msite_lang_cur;
     END IF;
     return false;
END msite_default_lang_exists;


FUNCTION msite_default_currency_exists(p_msite_id IN NUMBER )
                                       RETURN BOOLEAN
IS
  CURSOR valid_msite_currency_cur(p_msite_id IN NUMBER)  IS
    select 1 from dual where exists (
      select msite_id from ibe_msites_b where
      msite_id = p_msite_id and default_currency_code is not null );

    l_exists NUMBER;
    l_return_status Boolean := false;

BEGIN

  OPEN valid_msite_currency_cur(p_msite_id);
  FETCH valid_msite_currency_cur INTO l_exists;

  IF valid_msite_currency_cur%FOUND THEN
    l_return_status := true;
  end if;

  close valid_msite_currency_cur;

  return l_return_status;

EXCEPTION
   WHEN OTHERS THEN
     IF valid_msite_currency_cur%ISOPEN THEN
     close valid_msite_currency_cur;
     END IF;
     return false;
END msite_default_currency_exists;


FUNCTION msite_default_org_exists(p_msite_id IN NUMBER )
                                  RETURN BOOLEAN
IS
  CURSOR valid_msite_org_cur(p_msite_id IN NUMBER)  IS
    select 1 from dual where exists (
      select msite_id from ibe_msites_b where
      msite_id = p_msite_id and default_org_id is not null );

    l_exists NUMBER;
    l_return_status Boolean := false;

BEGIN

  OPEN valid_msite_org_cur(p_msite_id);
  FETCH valid_msite_org_cur INTO l_exists;

  IF valid_msite_org_cur%FOUND THEN
    l_return_status := true;
  end if;

  close valid_msite_org_cur;

  return l_return_status;

EXCEPTION
   WHEN OTHERS THEN
     IF valid_msite_org_cur%ISOPEN THEN
     close valid_msite_org_cur;
     END IF;
     return false;
END msite_default_org_exists;


FUNCTION valid_language(p_language VARCHAR2)
                        RETURN BOOLEAN
IS
  CURSOR valid_language_cur(p_language varchar2)  IS
    select 1 from dual where exists (
      select language_code from fnd_languages_vl where
      language_code = p_language);
    l_exists NUMBER;
    l_return_status Boolean := true;

BEGIN

  OPEN valid_language_cur(p_language);
  FETCH valid_language_cur INTO l_exists;

  IF valid_language_cur%NOTFOUND THEN
    l_return_status := false;
  end if;

  close valid_language_cur;

  if l_return_status = false then
    raise FND_API.g_exc_error;
    -----dbms_output.put_line('invalid languages:' || p_language);
  END IF;

  -----dbms_output.put_line('valid languages:' || p_language);
  return l_return_status;

EXCEPTION
   WHEN OTHERS THEN
     IF valid_language_cur%ISOPEN THEN
     close valid_language_cur;
     END IF;
     FND_MESSAGE.set_name('IBE','IBE_MSITE_LANG_INVLD');
     FND_MESSAGE.set_token('0', p_language);
     FND_MSG_PUB.ADD;
     -----dbms_output.put_line('invalid languages');
     return false;
END valid_language;


FUNCTION valid_orgid(p_orgid NUMBER)
                     RETURN BOOLEAN
IS
  CURSOR valid_orgid_cur(p_orgid varchar2)  IS
    select 1 from dual where exists (
      select organization_id from hr_all_organization_units where
      organization_id  = p_orgid);
    l_exists NUMBER;
    l_return_status Boolean := true;

BEGIN

  OPEN valid_orgid_cur(p_orgid);
  FETCH valid_orgid_cur INTO l_exists;
  IF valid_orgid_cur%NOTFOUND THEN
    l_return_status := false;
  end if;

  if l_return_status = false then
    raise FND_API.g_exc_error;
  end if;

  -----dbms_output.put_line('invalid orgid:' || p_orgid);

  return l_return_status;

EXCEPTION
   WHEN OTHERS THEN
     IF valid_orgid_cur%ISOPEN THEN
     close valid_orgid_cur;
     END IF;
     FND_MESSAGE.set_name('IBE','IBE_MSITE_ORGID_INVLD');
     FND_MESSAGE.set_token('0', p_orgid);
     FND_MSG_PUB.ADD;
     --dbms_output.put_line('invalid Org id');
     return false;
END valid_orgid;


FUNCTION valid_currency(p_currency VARCHAR2)
                        RETURN BOOLEAN
IS
  CURSOR valid_currency_cur(p_currency varchar2)  IS
    select 1 from dual where exists (
      select currency_code from fnd_currencies_vl where
      currency_code = p_currency);
    l_exists NUMBER;
    l_return_status Boolean := true;

BEGIN

  OPEN valid_currency_cur(p_currency);
  FETCH valid_currency_cur INTO l_exists;
  IF valid_currency_cur%NOTFOUND THEN
    l_return_status := false;
    --dbms_output.put_line('error in currency code1:' || p_currency);
  end if;

  close valid_currency_cur;
  if l_return_status = false then
    raise FND_API.g_exc_error;
  END IF;

  return l_return_status;

EXCEPTION
   WHEN OTHERS THEN
     IF valid_currency_cur%ISOPEN THEN
     close valid_currency_cur;
     END IF;
     FND_MESSAGE.set_name('IBE','IBE_MSITE_CURRENCY_INVLD');
     FND_MESSAGE.set_token('0', p_currency);
     FND_MSG_PUB.ADD;
     --dbms_output.put_line('error in currency code');
     return false;

END valid_currency;


FUNCTION valid_prc_lstids(p_currency VARCHAR2,
                          p_walkin_prclstid number,
                          p_registered_prclstid number,
                          p_bizpartner_prclstid NUMBER,
                          p_partner_prclstid NUMBER)
                          RETURN BOOLEAN
IS
  CURSOR valid_currency_prclstid_cur(p_currency varchar2,
    p_walkin_prclstid number,
    p_registered_prclstid number,
    p_bizpartner_prclstid NUMBER,
    p_partner_prclstid NUMBER)
IS
    select 1 from dual where exists (
      select list_header_id from qp_list_headers_v where
      currency_code = p_currency and
      list_header_id in (p_walkin_prclstid,p_registered_prclstid,p_bizpartner_prclstid,p_partner_prclstid));

     l_exists NUMBER;
     l_return_status Boolean := true;

BEGIN

  if p_walkin_prclstid is null or  p_registered_prclstid is null or
    p_bizpartner_prclstid is  null or
    p_partner_prclstid is  null
  then
    FND_MESSAGE.set_name('IBE','IBE_MSITE_PRCLSTID_REQ');
    FND_MESSAGE.set_token('CURR_CODE', p_currency);
    FND_MSG_PUB.ADD;
    raise FND_API.g_exc_error;
  END IF;

  OPEN valid_currency_prclstid_cur(p_currency,p_walkin_prclstid,p_registered_prclstid,
    p_bizpartner_prclstid, p_partner_prclstid);
  FETCH valid_currency_prclstid_cur INTO l_exists;


  IF valid_currency_prclstid_cur%NOTFOUND THEN
    l_return_status := false;
  END IF;
  close valid_currency_prclstid_cur;

  if l_return_status = false
  then
    FND_MESSAGE.set_name('IBE','IBE_MSITE_PRCLSTID_INVLD');
    FND_MESSAGE.set_token('WALKIN_ID',p_walkin_prclstid);
    FND_MESSAGE.set_token('REG_ID' , p_registered_prclstid);
    FND_MESSAGE.set_token('BIZ_ID' , p_bizpartner_prclstid);
    FND_MESSAGE.set_token('PARTNER_ID' , p_partner_prclstid);
    FND_MESSAGE.set_token('CURR_CODE',p_currency);
    FND_MSG_PUB.ADD;
  end if;

  return l_return_status;

EXCEPTION
   WHEN OTHERS THEN
     IF valid_currency_prclstid_cur%ISOPEN THEN
     close valid_currency_prclstid_cur;
     END IF;
     return FALSE;
END valid_prc_lstids;


PROCEDURE save_msite(
  p_api_version      IN     NUMBER,
  p_init_msg_list    IN     VARCHAR2 := FND_API.g_false,
  p_commit           IN     VARCHAR2  := FND_API.g_false,
  x_return_status    OUT NOCOPY    VARCHAR2,
  x_msg_count        OUT NOCOPY    NUMBER,
  x_msg_data         OUT NOCOPY    VARCHAR2,
  p_msite_rec        IN OUT NOCOPY Msite_REC_TYPE )
IS
  l_api_name    CONSTANT VARCHAR2(30) := 'save_msite';
  l_full_name   CONSTANT VARCHAR2(60) := g_pkg_name ||'.'|| l_api_name;

  l_operation_type       VARCHAR2(10);

  l_msite_id		 NUMBER;
  walkin_allowed_code    VARCHAR2(1);
  l_atp_check_flag       VARCHAR2(1);
  l_master_exists        NUMBER;
  l_msite_master_flag    VARCHAR2(1);
  l_store_id	         NUMBER := NULL;
  l_exists               NUMBER ;
  l_root_section_flag    VARCHAR2(1) := FND_API.g_false;
  l_return_status        VARCHAR2(1);
  l_msg_count	         NUMBER;
  l_msg_data	         VARCHAR2(80);
  l_root_section_id      NUMBER := NULL;
  l_resp_access_flag     VARCHAR2(1);
  l_party_access_code    VARCHAR2(1);

  l_cur_root_sct_id              NUMBER;
  l_sct_root_flag                NUMBER;

  l_payment_thresh_enable_flag VARCHAR2(1);
  l_enable_traffic_filter VARCHAR2(1);
  l_reporting_status VARCHAR2(1);

  l_debug VARCHAR2(1);

  CURSOR msite_id_seq IS
    SELECT ibe_msites_b_s1.NEXTVAL
      FROM DUAL;

  /*CURSOR store_id_cur  IS
   select store_id  from ibe_stores_b
    where rownum < 2 ;*/

  CURSOR master_msite_any_cur  IS
   select 1 from dual where exists (
                            select msite_id  from ibe_msites_b
                             where master_msite_flag = 'Y') ;

  CURSOR master_msite_cur(p_msite_id IN NUMBER)  IS
   select 1 from dual
    where exists (
          select msite_id
            from ibe_msites_b
           where master_msite_flag = 'Y'
             AND msite_id <> p_msite_id);

  CURSOR yes_no_cur (p_code in varchar2) IS
   select 1 from dual where exists (
                            select lookup_code
                              from fnd_lookup_values_vl
                             where lookup_type='YES_NO'
                               and lookup_code=p_code);

  CURSOR C_party_access_code (p_code in varchar2) IS
    select 1 from fnd_lookup_values_vl
     where  lookup_type = 'IBE_PARTY_ACCESS_CODE'
       and    lookup_code = p_code ;
BEGIN
  l_operation_type:= 'INSERT';
  l_debug  := NVL(FND_PROFILE.VALUE('IBE_DEBUG'),'N');

     IF (l_debug = 'Y') THEN
        IBE_UTIL.Debug('Start IBE_MSITE_GRP.Save_Msite');
     END IF;

  --------------------- initialize -----------------------+
  SAVEPOINT save_msite;


  IF NOT FND_API.compatible_api_call(
    g_api_version,
    p_api_version,
    l_api_name,
    g_pkg_name ) THEN
    RAISE FND_API.g_exc_unexpected_error;
  END IF;


  IF FND_API.to_boolean(p_init_msg_list) THEN
    FND_MSG_PUB.initialize;
  END IF;


  x_return_status := FND_API.G_RET_STS_SUCCESS;

  --- Check if the msite_id exists
  IF p_msite_rec.msite_id IS NOT NULL AND
    p_msite_rec.msite_id <> FND_API.g_miss_num
  THEN
       IF (l_debug = 'Y') THEN
          IBE_UTIL.Debug('[IBE_MSITE_GRP]Minisite id is passed');
       END IF;
    if ibe_dspmgrvalidation_grp.check_msite_exists(
      p_msite_rec.msite_id, p_msite_rec.Object_version_Number) = false
    then
         IF (l_debug = 'Y') THEN
            IBE_UTIL.Debug('[IBE_MSITE_GRP]Raising Exception: MiniSite Exists');
         END IF;
      raise FND_API.g_exc_error;
    end if;

    l_operation_type:='UPDATE';

       IF (l_debug = 'Y') THEN
          IBE_UTIL.Debug('[IBE_MSITE_GRP]Operation is an Update');
       END IF;

  END IF;
  if p_msite_rec.msite_root_section_id <> FND_API.g_miss_num AND
    p_msite_rec.msite_root_section_id is not null then

    if ibe_dspmgrvalidation_grp.check_root_section_exists(
      p_msite_rec.msite_root_section_id) = false
    then
         IF (l_debug = 'Y') THEN
            IBE_UTIL.Debug('Raising Exception:Root Section Does not exist');
         END IF;
      raise FND_API.g_exc_error;
    end if;

    l_root_section_flag := FND_API.g_true;
    l_root_section_id   := p_msite_rec.msite_root_section_id;
  else
    --- If the minisite is a new one, then root section id can be null ,
    --todo
    if (p_msite_rec.msite_id is not null and
      p_msite_rec.enable_for_store = FND_API.g_true) or
      p_msite_rec.enable_for_store = FND_API.g_true
    then
      FND_MESSAGE.set_name('IBE','IBE_MSITE_RSECID_INVLD');
      FND_MSG_PUB.ADD;
      raise FND_API.g_exc_error;
    end if;
  end if;

  if p_msite_rec.msite_master_flag = FND_API.g_true then
    raise master_msite_exists_exception;
  else
    l_msite_master_flag := 'N';
  end if;


  --dbms_output.put_line('passed master mini site flag teste  '  );
  -- Check if the access_name for a minisite is unique
  If ( p_msite_rec.msite_id IS NULL OR
    p_msite_rec.msite_id = FND_API.g_miss_num) AND
    (p_msite_rec.access_name IS NOT NULL AND
    p_msite_rec.access_name <> FND_API.G_MISS_CHAR) Then
    If  Ibe_Dspmgrvalidation_Grp.Check_Msite_Accessname(
      p_access_name  => p_msite_rec.access_name)= FALSE
    Then
         IF (l_debug = 'Y') THEN
            IBE_UTIL.Debug('Exception:Access Name is not Unique');
         END IF;
      Raise FND_API.G_EXC_ERROR ;
    End If;
  End If;

  if p_msite_rec.enable_for_store = FND_API.g_true then
    --dbms_output.put_line('****************enabled for store is to true '  );
    /*OPEN store_id_cur;
    fetch store_id_cur into l_store_id;
    if store_id_cur%NOTFOUND then
      close store_id_cur;
      raise store_not_exists_exception;
    end if;
    close store_id_cur;*/

    if ibe_dspmgrvalidation_grp.check_root_section_exists(
      p_msite_rec.msite_root_section_id) = false
    then
      raise FND_API.g_exc_error;
    end if;

    if msite_default_lang_exists(p_msite_rec.msite_id) = false
    then
      raise msite_default_lang_missing;
    end if;

    if msite_default_currency_exists(p_msite_rec.msite_id) = false
    then
      raise msite_default_currency_missing;
    end if;
    /*** REDUNDANT AS ORG ID WILL BE DETERMINED BY RESPONSIBILITY
    if msite_default_org_exists(p_msite_rec.msite_id) = false then
       raise msite_default_org_missing;
    end if;
    ******/
  end if;

    walkin_allowed_code := p_msite_rec.walkin_allowed_code;
    OPEN yes_no_cur(walkin_allowed_code);
    FETCH yes_no_cur INTO l_exists;
    IF yes_no_cur%NOTFOUND THEN
      walkin_allowed_code := 'N';
    END IF;
    close yes_no_cur;

    l_atp_check_flag := p_msite_rec.atp_check_flag;
    OPEN yes_no_cur(l_atp_check_flag);
    FETCH yes_no_cur INTO l_exists;
    IF yes_no_cur%NOTFOUND THEN
      l_atp_check_flag := 'N';
    END IF;
    close yes_no_cur;

    l_resp_access_flag := p_msite_rec.resp_access_flag;
    IF (((l_operation_type = 'UPDATE') AND
      (l_resp_access_flag IS NOT NULL AND
      l_resp_access_flag <> FND_API.G_MISS_char)) OR
      l_operation_type = 'INSERT')
    THEN
      OPEN yes_no_cur(l_resp_access_flag );
      FETCH yes_no_cur INTO l_exists;
      IF yes_no_cur%NOTFOUND THEN
        l_resp_access_flag := 'N';
      END IF;
      close yes_no_cur;
    END IF;

    l_party_access_code := p_msite_rec.party_access_code;
    IF (((l_operation_type = 'UPDATE') AND
      (l_party_access_code IS NOT NULL AND
      l_party_access_code <> FND_API.G_MISS_char)) OR
      l_operation_type = 'INSERT')
    THEN
      OPEN  C_party_access_code(l_party_access_code );
      FETCH C_party_access_code INTO l_exists;
      IF  C_party_access_code%NOTFOUND THEN
        l_party_access_code := 'A';
      END IF;
      close  C_party_access_code;
    END IF;

    IF  l_operation_type = 'INSERT'
    THEN
      OPEN msite_id_seq;
      FETCH msite_id_seq INTO l_msite_id;
      CLOSE msite_id_seq;
    END IF;

    l_sct_root_flag := 1;

    --added by YAXU on 06/11/2002 for payment threshold
    l_payment_thresh_enable_flag := p_msite_rec.payment_threshold_enable_flag;
    OPEN yes_no_cur(l_payment_thresh_enable_flag);
    FETCH yes_no_cur INTO l_exists;
    IF yes_no_cur%NOTFOUND THEN
      l_payment_thresh_enable_flag := 'N';
    END IF;
    close yes_no_cur;

	l_enable_traffic_filter := p_msite_rec.enable_traffic_filter;
	IF l_enable_traffic_filter <> 'Y'
	THEN
		l_enable_traffic_filter := 'N';
	END IF;

	l_reporting_status := p_msite_rec.reporting_status;
	IF l_reporting_status <> 'Y'
	THEN
		l_reporting_status := 'N';
	END IF;


    IF l_operation_type = 'INSERT'
    THEN
         IF (l_debug = 'Y') THEN
            IBE_UTIL.Debug('Before insert into IBE_MSITES_B');
         END IF;
      INSERT INTO IBE_MSITES_B (
        MSITE_ID,
        OBJECT_VERSION_NUMBER,
        LAST_UPDATE_DATE,
        LAST_UPDATED_BY,
        CREATION_DATE,
        CREATED_BY,
        LAST_UPDATE_LOGIN,
        START_DATE_ACTIVE,
        END_DATE_ACTIVE,
        DEFAULT_DATE_FORMAT,
        PROFILE_ID,
        MASTER_MSITE_FLAG,
        WALKIN_ALLOWED_FLAG,
        STORE_ID,
        ATP_CHECK_FLAG,
        MSITE_ROOT_SECTION_ID,
        RESP_ACCESS_FLAG ,
        PARTY_ACCESS_CODE ,
        ACCESS_NAME,
        URL,
        THEME_ID,
        PAYMENT_THRESHOLD_ENABLE_FLAG,
		DOMAIN_NAME,
		ENABLE_TRAFFIC_FILTER,
		REPORTING_STATUS,
		SITE_TYPE)
        VALUES (
        l_msite_id,
        1,
        SYSDATE,
        FND_GLOBAL.user_id,
        SYSDATE,
        FND_GLOBAL.user_id,
        FND_GLOBAL.user_id,
        p_msite_rec.start_date_active,
        p_msite_rec.end_date_active,
        p_msite_rec.date_format,
        p_msite_rec.profile_id,
        l_msite_master_flag,
        walkin_allowed_code,
        l_store_id,
        l_atp_check_flag,
        l_root_section_id,
        l_resp_access_flag ,
        l_party_access_code ,
        p_msite_rec.access_name ,
        DECODE(p_msite_rec.url,FND_API.G_MISS_CHAR,null,p_msite_rec.url) ,
        DECODE(p_msite_rec.theme_id,FND_API.G_MISS_NUM,null,p_msite_rec.theme_id),
        l_payment_thresh_enable_flag,
		p_msite_rec.domain_name,
		l_enable_traffic_filter,
		l_reporting_status,
		p_msite_rec.site_type);
         IF (l_debug = 'Y') THEN
            IBE_UTIL.Debug('After insert into IBE_MSITES_B');
         END IF;
      --- Insert into the TL table
         IF (l_debug = 'Y') THEN
            IBE_UTIL.Debug('Before insert into IBE_MSITES_TL');
         END IF;

      insert into IBE_MSITES_TL (
        MSITE_ID,
        LAST_UPDATE_DATE,
        LAST_UPDATED_BY,
        CREATION_DATE,
        CREATED_BY,
        LAST_UPDATE_LOGIN,
        OBJECT_VERSION_NUMBER,
        MSITE_NAME,
        MSITE_DESCRIPTION,
        LANGUAGE,
        SOURCE_LANG ) select
        l_msite_id,
          sysdate,
          FND_GLOBAL.user_id,
          sysdate,
          FND_GLOBAL.user_id,
          FND_GLOBAL.user_id,
          1,
          p_msite_rec.Display_name,
          p_msite_rec.description,
          L.LANGUAGE_CODE,
          userenv('LANG')
          from FND_LANGUAGES L
          where L.INSTALLED_FLAG in ('I', 'B')
          and not exists(
          select NULL
          from IBE_MSITES_TL T
          where T.MSITE_ID =l_msite_id
          and T.LANGUAGE = L.LANGUAGE_CODE);
         IF (l_debug = 'Y') THEN
            IBE_UTIL.Debug('After insert into IBE_MSITES_TL');
         END IF;

        p_msite_rec.msite_id := l_msite_id;
        p_msite_rec.object_version_number := 1;

    ELSIF l_operation_type = 'UPDATE'
    THEN
      -- added the following code for globalisation -- ssridhar
      --    RESP_ACCESS_FLAG           = l_resp_access_flag ,
      --    PARTY_ACCESS_CODE          = l_party_access_code ,
      --    ACCESS_NAME                = p_msite_rec.access_name
      --Bug fix for not updating end_date_active

      IF l_resp_access_flag = fnd_api.g_miss_char
      THEN
        l_resp_access_flag := NULL;
      END IF;

      IF l_party_access_code = fnd_api.g_miss_char
      THEN
        l_party_access_code := NULL;
      END IF;

      IF p_msite_rec.access_name = fnd_api.g_miss_char
      THEN
        p_msite_rec.access_name := NULL;
      END IF;

      IF p_msite_rec.start_date_active = fnd_api.g_miss_date
      THEN
        p_msite_rec.start_date_active := NULL;
      END IF;

      IF p_msite_rec.end_date_active = fnd_api.g_miss_date
      THEN
        p_msite_rec.end_date_active := NULL;
      END IF;

      IF p_msite_rec.url = fnd_api.g_miss_char
      THEN
        p_msite_rec.url := NULL;
      END IF;

      IF p_msite_rec.theme_id = fnd_api.g_miss_num
      THEN
        p_msite_rec.theme_id := NULL;
      END IF;


  --
  -- Check if the root section of the p_mini_site_id equals to the p_section_id.
  -- If it does, then don't do the association again
  -- Added by YAXU on -3/27/2002
  --

     SELECT msite_root_section_id into l_cur_root_sct_id
     FROM   ibe_msites_b
     WHERE  msite_id = p_msite_rec.msite_id;


     IF  l_cur_root_sct_id = p_msite_rec.msite_root_section_id
     THEN
         l_sct_root_flag :=0;
     END IF;


         IF (l_debug = 'Y') THEN
            IBE_UTIL.Debug('Before updating IBE_MSITES_B');
         END IF;

      UPDATE  IBE_MSITES_B  SET
        LAST_UPDATE_DATE         = SYSDATE,
        LAST_UPDATED_BY          = FND_GLOBAL.user_id,
        LAST_UPDATE_LOGIN        = FND_GLOBAL.user_id,
        PROFILE_ID               = p_msite_rec.profile_id,
        DEFAULT_DATE_FORMAT      = p_msite_rec.date_format ,
        MASTER_MSITE_FLAG        = l_msite_master_flag,
        WALKIN_ALLOWED_FLAG      = walkin_allowed_code,
        STORE_ID                 = l_store_id ,
        ATP_CHECK_FLAG           = l_atp_check_flag,
        MSITE_ROOT_SECTION_ID    = l_root_section_id ,
        OBJECT_VERSION_NUMBER    = p_msite_rec.object_version_number + 1,
        RESP_ACCESS_FLAG         = NVL(l_resp_access_flag,resp_access_flag),
        PARTY_ACCESS_CODE        = nvl(l_party_access_code,party_access_code),
        ACCESS_NAME              = p_msite_rec.access_name,
        START_DATE_ACTIVE        =
                        nvl(p_msite_rec.start_date_active,start_date_active),
        END_DATE_ACTIVE          = p_msite_rec.end_date_active ,
        URL                      = NVL(p_msite_rec.url,url),
        THEME_ID                 = NVL(p_msite_rec.theme_id,theme_id),
        PAYMENT_THRESHOLD_ENABLE_FLAG = l_payment_thresh_enable_flag,
		DOMAIN_NAME              = p_msite_rec.domain_name,
		ENABLE_TRAFFIC_FILTER    = p_msite_rec.enable_traffic_filter,
		REPORTING_STATUS         = p_msite_rec.reporting_status,
		SITE_TYPE                = p_msite_rec.site_type
        WHERE
        MSITE_ID                 = p_msite_rec.msite_id and
        OBJECT_VERSION_NUMBER    = p_msite_rec.object_version_number ;

         IF (l_debug = 'Y') THEN
            IBE_UTIL.Debug('After updating IBE_MSITES_B');
            IBE_UTIL.Debug('Before updating IBE_MSITES_TL');
         END IF;

      UPDATE  IBE_MSITES_TL  SET
        MSITE_NAME = decode( p_msite_rec.Display_name, FND_API.G_MISS_CHAR,
        MSITE_NAME, p_msite_rec.Display_name),
        MSITE_DESCRIPTION = decode( p_msite_rec.description,
        FND_API.G_MISS_CHAR, MSITE_DESCRIPTION, p_msite_rec.description),
        LAST_UPDATE_DATE = SYSDATE,
        LAST_UPDATED_BY = FND_GLOBAL.user_id,
        LAST_UPDATE_LOGIN = FND_GLOBAL.user_id,
        OBJECT_VERSION_NUMBER= p_msite_rec.object_version_number +1 ,
        SOURCE_LANG = userenv('LANG')
        where msite_id = p_msite_rec.msite_id
        and userenv('LANG') in (LANGUAGE, SOURCE_LANG);

         IF (l_debug = 'Y') THEN
            IBE_UTIL.Debug('After updating IBE_MSITES_TL');
         END IF;

      p_msite_rec.object_version_number :=
        p_msite_rec.object_version_number + 1;

    END IF;

   IF(l_sct_root_flag = 1)
   THEN
    ----if p_msite_rec.enable_for_store = FND_API.g_true and
    if l_root_section_flag = FND_API.g_true
    then
         IF (l_debug = 'Y') THEN
            IBE_UTIL.Debug('Before calling IBE_DSP_HIERARCHY_SETUP_PVT.' || 'Associate_Root_Sct_To_MSite ');
         END IF;

      IBE_DSP_HIERARCHY_SETUP_PVT.Associate_Root_Sct_To_MSite
        (
        p_api_version                 => p_api_version,
        p_init_msg_list               => FND_API.g_false,
        p_commit                      => FND_API.g_false,
        p_validation_level            => 100,
        p_section_id                  => p_msite_rec.msite_root_section_id,
        p_mini_site_id                => p_msite_rec.msite_id,
        x_return_status               => l_return_status,
        x_msg_count                   => x_msg_count,
        x_msg_data                    => x_msg_data
        );

         IF (l_debug = 'Y') THEN
            IBE_UTIL.Debug('After calling IBE_DSP_HIERARCHY_SETUP_PVT.' || 'Associate_Root_Sct_To_MSite ');
         END IF;

      if l_return_status = FND_API.G_RET_STS_SUCCESS then
        update IBE_MSITES_B set msite_root_section_id = l_root_section_id ,
          store_id = l_store_id
          where msite_id=p_msite_rec.msite_id;
      else
        raise FND_API.g_exc_error;
      end if;
    end if;
   END IF;

    --dbms_output.put_line('Operation is successful ' );
    --- Check if the caller requested to commit ,
    --- If p_commit set to true, commit the transaction
    IF  FND_API.to_boolean(p_commit) THEN
      COMMIT;
    END IF;

    x_return_status := FND_API.G_RET_STS_SUCCESS;

    FND_MSG_PUB.count_and_get(
      p_encoded => FND_API.g_false,
      p_count   => x_msg_count,
      p_data    => x_msg_data
                             );

EXCEPTION

   WHEN FND_API.g_exc_error THEN
     ROLLBACK TO save_msite;
     x_return_status := FND_API.g_ret_sts_error;
     FND_MSG_PUB.count_and_get(
       p_encoded => FND_API.g_false,
       p_count   => x_msg_count,
       p_data    => x_msg_data
                              );

   WHEN FND_API.g_exc_unexpected_error THEN
     ROLLBACK TO save_msite;
     x_return_status := FND_API.g_ret_sts_unexp_error ;
     --dbms_output.put_line('unexpected error raised');
     FND_MSG_PUB.count_and_get(
       p_encoded => FND_API.g_false,
       p_count   => x_msg_count,
       p_data    => x_msg_data
                              );

   WHEN master_msite_exists_exception THEN
     ROLLBACK TO save_msite;
     x_return_status := FND_API.g_ret_sts_error ;
     FND_MESSAGE.set_name('IBE','IBE_MSITE_MASTER_EXISTS');
     FND_MSG_PUB.ADD;
     --dbms_output.put_line('master_msite error raised');
     FND_MSG_PUB.count_and_get(
       p_encoded => FND_API.g_false,
       p_count   => x_msg_count,
       p_data    => x_msg_data
                              );

   WHEN store_not_exists_exception THEN
     ROLLBACK TO save_msite;
     x_return_status := FND_API.g_ret_sts_error ;
     FND_MSG_PUB.count_and_get(
       p_encoded => FND_API.g_false,
       p_count   => x_msg_count,
       p_data    => x_msg_data
                              );

   WHEN  msite_default_org_missing THEN
     ROLLBACK TO save_msite;
     x_return_status := FND_API.g_ret_sts_error;
     FND_MESSAGE.set_name('IBE','IBE_MSITE_DEF_ORG_REQ');
     FND_MESSAGE.set_token('ID', p_msite_rec.msite_id);
     FND_MSG_PUB.ADD;
     FND_MSG_PUB.count_and_get(
       p_encoded => FND_API.g_false,
       p_count   => x_msg_count,
       p_data    => x_msg_data
                              );
   WHEN  msite_default_currency_missing THEN
     ROLLBACK TO save_msite;
     x_return_status := FND_API.g_ret_sts_error;
     FND_MESSAGE.set_name('IBE','IBE_MSITE_DEF_CURR_REQ');
     FND_MESSAGE.set_token('ID', p_msite_rec.msite_id);
     FND_MSG_PUB.ADD;
     FND_MSG_PUB.count_and_get(
       p_encoded => FND_API.g_false,
       p_count   => x_msg_count,
       p_data    => x_msg_data
                              );

   WHEN  msite_default_lang_missing THEN
     ROLLBACK TO save_msite;
     x_return_status := FND_API.g_ret_sts_error;
     FND_MESSAGE.set_name('IBE','IBE_MSITE_DEF_LANG_REQ');
     FND_MESSAGE.set_token('ID', p_msite_rec.msite_id);
     FND_MSG_PUB.ADD;
     FND_MSG_PUB.count_and_get(
       p_encoded => FND_API.g_false,
       p_count   => x_msg_count,
       p_data    => x_msg_data
                              );

   WHEN OTHERS THEN
     ROLLBACK TO save_msite;
     x_return_status := FND_API.g_ret_sts_unexp_error ;
     IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_unexp_error)
     THEN
       FND_MSG_PUB.add_exc_msg(g_pkg_name, l_api_name);
     END IF;
     FND_MSG_PUB.count_and_get(
       p_encoded => FND_API.g_false,
       p_count   => x_msg_count,
       p_data    => x_msg_data
                              );

END save_msite;

--
-- Need to put into event handler to flush minisite information
-- And minisite responsibility cache
--   MerchantMinisiteMgr.flushMinisite("UPDATE", lmstFlushArr);
--   MinisiteResponsibilitiesCacheManager.invalidate();
PROCEDURE duplicate_msite(
  p_api_version           IN NUMBER,
  p_init_msg_list         IN VARCHAR2 := FND_API.g_false,
  p_commit                IN VARCHAR2  := FND_API.g_false,
  p_default_language_code IN varchar2,
  p_default_currency_code IN varchar2,
  p_walkin_pricing_id     IN number,
  x_minisite_id          OUT NOCOPY number,
  x_version_number       OUT NOCOPY NUMBER,
  x_return_status        OUT NOCOPY VARCHAR2,
  x_msg_count            OUT NOCOPY NUMBER,
  x_msg_data             OUT NOCOPY VARCHAR2,
  p_msite_rec         IN OUT NOCOPY MSITE_REC_TYPE)

IS
  l_api_version NUMBER := 1.0;
  l_api_name VARCHAR2(50);
  l_return_status VARCHAR2(1);
  l_msg_count NUMBER;
  l_msg_data VARCHAR2(4000);
  l_debug VARCHAR2(1);

  l_i NUMBER;
  -- For Minisite
  l_party_access_code VARCHAR2(30);

  -- For language
  l_language_code VARCHAR2(4);
  l_enable_flag VARCHAR2(3);
  l_def_found NUMBER;
  -- For currency and price list
  l_currency_code VARCHAR2(15);
  l_bizpartner_prc_listid NUMBER;
  l_partner_prc_listid NUMBER;
  l_registered_prc_listid NUMBER;
  l_walkin_prc_listid NUMBER;
  l_orderable_limit NUMBER;
  l_payment_threshold NUMBER;

  -- Responsibility code and group
  l_copy VARCHAR2(240);
  l_responsibility_id NUMBER;
  l_application_id NUMBER;
  l_start_date_active DATE;
  l_end_date_active DATE;
  l_sort_order NUMBER;
  l_display_name VARCHAR2(240);
  l_group_code VARCHAR2(30);
  l_prev_msite_resp_id NUMBER;
  l_msite_resp_id NUMBER;
  x_msite_resp_id NUMBER;
  l_order_type_id NUMBER;

  -- Access Restriction
  l_party_id NUMBER;
  l_party_ids JTF_NUMBER_TABLE;
  l_start_date_actives JTF_DATE_TABLE;
  l_end_date_actives JTF_DATE_TABLE;
  l_msite_prty_accss_ids JTF_NUMBER_TABLE;
  l_duplicate_association_status JTF_VARCHAR2_TABLE_100;
  l_is_any_duplicate_status VARCHAR2(1);

  l_msite_id NUMBER;
  l_version_number NUMBER;
  l_msite_rec IBE_MSite_GRP.Msite_REC_TYPE;
  l_msite_languages_tbl IBE_MSite_GRP.msite_languages_tbl_type;
  l_msite_currencies_tbl IBE_MSite_GRP.MSITE_CURRENCIES_TBL_TYPE;

  CURSOR c_get_msite_detail_csr(c_msite_id NUMBER) IS
    select party_access_code
    from ibe_msites_b
    where msite_id = c_msite_id;

  CURSOR c_get_msite_langs_csr(c_msite_id NUMBER) IS
    select language_code, enable_flag
      from ibe_msite_languages
     where msite_id = c_msite_id
  order by language_code;

  CURSOR c_get_msite_pricing_csr(c_msite_id NUMBER) IS
    select m.currency_code, m.bizpartner_prc_listid,
           m.registered_prc_listid, m.walkin_prc_listid,
           m.orderable_limit, m.payment_threshold,m.partner_prc_listid
      from ibe_msite_currencies m
     where m.msite_id = c_msite_id
   ORDER BY m.currency_code;

  CURSOR c_get_msite_resp_csr(c_msite_id NUMBER) IS
    SELECT MR.msite_resp_id, MR.responsibility_id, MR.application_id,
		 MR.display_name, MR.start_date_active, MR.end_date_active,
		 MR.sort_order, MR.group_code, MR.order_type_id
      FROM ibe_msite_resps_vl MR
     WHERE MR.msite_id = c_msite_id
  ORDER BY MR.msite_resp_id, MR.group_code;

  CURSOR c_get_msite_access_csr(c_msite_id NUMBER) IS
    SELECT party_id, start_date_active, end_date_active
	 FROM ibe_msite_prty_accss
     WHERE msite_id = c_msite_id;
BEGIN
  SAVEPOINT DUPLICATE_MSITE_SAVE;
  l_api_name:= 'duplicate_msite';
  l_debug  := NVL(FND_PROFILE.VALUE('IBE_DEBUG'),'N');

  IF (l_debug = 'Y') THEN
    IBE_UTIL.debug('duplicate_msite Starts +');
    IBE_UTIL.debug('p_api_version = '||p_api_version);
    IBE_UTIL.debug('p_init_msg_list = '||p_init_msg_list);
    IBE_UTIL.debug('p_commit = '||p_commit);
    IBE_UTIL.debug('p_source_msite_id = '||p_msite_rec.msite_id);
    IBE_UTIL.debug('p_display_name = '||p_msite_rec.display_name);
    IBE_UTIL.debug('p_access_name = '||p_msite_rec.access_name);
    IBE_UTIL.debug('p_description = '||p_msite_rec.description);
    IBE_UTIL.debug('p_default_language_code = '||p_default_language_code);
    IBE_UTIL.debug('p_default_currency_code = '||p_default_currency_code);
    IBE_UTIL.debug('p_walkin_pricing_id = '||p_walkin_pricing_id);
    IBE_UTIL.debug('p_start_date_active = '||p_msite_rec.start_date_active);
    IBE_UTIL.debug('p_end_date_active = '||p_msite_rec.end_date_active);
    IBE_UTIL.debug('p_msite_root_section_id = '||p_msite_rec.msite_root_section_id);
    IBE_UTIL.debug('p_walkin_allowed_code = '||p_msite_rec.walkin_allowed_code);
    IBE_UTIL.debug('p_atp_check_flag = '||p_msite_rec.atp_check_flag);
    IBE_UTIL.debug('p_resp_access_flag = '||p_msite_rec.resp_access_flag);
    IBE_UTIL.debug('p_payment_thresh_enable_flag = '||p_msite_rec.payment_threshold_enable_flag);
    IBE_UTIL.debug('p_domain_name = '||p_msite_rec.domain_name);
    IBE_UTIL.debug('p_enable_traffic_filter = '||p_msite_rec.enable_traffic_filter);
    IBE_UTIL.debug('p_reporting_status  = '||p_msite_rec.reporting_status);
    IBE_UTIL.debug('p_site_type  = '||p_msite_rec.site_type);
  END IF;
  IF NOT FND_API.Compatible_API_Call(l_api_version,
                                     p_api_version,
                                     l_api_name,
                                     G_PKG_NAME) THEN
     RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
  END IF;
  IF FND_API.to_Boolean(p_init_msg_list) THEN
    FND_MSG_PUB.initialize;
  END IF;
  -- Initialize API return status to SUCCESS
  x_return_status := FND_API.G_RET_STS_SUCCESS;

  OPEN c_get_msite_detail_csr(p_msite_rec.msite_id);
  FETCH c_get_msite_detail_csr INTO l_party_access_code;
  CLOSE c_get_msite_detail_csr;

  -- Validate on minisite main information
  -- Duplicate minisite main information
  l_msite_rec.msite_id := null;
  l_msite_rec.object_version_number := null;
  l_msite_rec.display_name := p_msite_rec.display_name;
  l_msite_rec.access_name := p_msite_rec.access_name;
  l_msite_rec.description := p_msite_rec.description;
  l_msite_rec.start_date_active := p_msite_rec.start_date_active;
  l_msite_rec.end_date_active := p_msite_rec.end_date_active;
  l_msite_rec.party_access_code := l_party_access_code;
  l_msite_rec.msite_root_section_id := p_msite_rec.msite_root_section_id;
  l_msite_rec.walkin_allowed_code := p_msite_rec.walkin_allowed_code;
  l_msite_rec.atp_check_flag := p_msite_rec.atp_check_flag;
  l_msite_rec.resp_access_flag := p_msite_rec.resp_access_flag;
  l_msite_rec.payment_threshold_enable_flag := p_msite_rec.payment_threshold_enable_flag;
  l_msite_rec.profile_id := null;
  l_msite_rec.date_format := null;
  l_msite_rec.msite_master_flag := FND_API.g_false;
  l_msite_rec.enable_for_store := null;
  l_msite_rec.url := null;
  l_msite_rec.theme_id := null;
  l_msite_rec.enable_traffic_filter := p_msite_rec.enable_traffic_filter;
  l_msite_rec.reporting_status := p_msite_rec.reporting_status;
  l_msite_rec.site_type := p_msite_rec.site_type;
  IBE_MSite_GRP.save_msite(
    p_api_version  => l_api_version,
    p_init_msg_list => FND_API.g_false,
    p_commit => FND_API.g_false,
    x_return_status => l_return_status,
    x_msg_count => l_msg_count,
    x_msg_data => l_msg_data,
    p_msite_rec => l_msite_rec);
  IF (l_return_status = FND_API.G_RET_STS_ERROR) THEN
    IF (l_debug = 'Y') THEN
      IBE_UTIL.debug('Error in IBE_MSite_GRP.save_msite');
      for i in 1..l_msg_count loop
        l_msg_data := FND_MSG_PUB.get(i,FND_API.G_FALSE);
        IBE_UTIL.debug(l_msg_data);
      end loop;
    END IF;
    RAISE FND_API.G_EXC_ERROR;
  ELSIF (l_return_status = FND_API.G_RET_STS_UNEXP_ERROR) THEN
    IF (l_debug = 'Y') THEN
      IBE_UTIL.debug('Error in IBE_MSite_GRP.save_msite');
      for i in 1..l_msg_count loop
        l_msg_data := FND_MSG_PUB.get(i,FND_API.G_FALSE);
        IBE_UTIL.debug(l_msg_data);
      end loop;
    END IF;
    RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
  END IF;
  l_msite_id := l_msite_rec.msite_id;
  l_version_number := l_msite_rec.Object_Version_Number;
  x_minisite_id := l_msite_rec.msite_id;
  x_version_number := l_msite_rec.Object_Version_Number;

  -- Get Language list of the source minisite
  -- And set it into new minisite
  l_i := 1;
  l_def_found := 0;
  OPEN c_get_msite_langs_csr(p_msite_rec.msite_id);
  LOOP

    FETCH c_get_msite_langs_csr INTO l_language_code, l_enable_flag;
    EXIT WHEN c_get_msite_langs_csr%NOTFOUND;

    IF (l_language_code = p_default_language_code) THEN
      l_def_found := 1;
      l_msite_languages_tbl(l_i).language_code := l_language_code;
      l_msite_languages_tbl(l_i).default_flag := FND_API.g_true;
      l_msite_languages_tbl(l_i).enable_flag := 'Y';
    ELSE
      l_msite_languages_tbl(l_i).language_code := l_language_code;
      l_msite_languages_tbl(l_i).default_flag := FND_API.g_false;
      l_msite_languages_tbl(l_i).enable_flag := l_enable_flag;
    END IF;
    l_i := l_i + 1;
  END LOOP;
  CLOSE c_get_msite_langs_csr;

  IF (l_i = 1) OR (l_def_found = 0) THEN
    l_msite_languages_tbl(l_i).language_code := p_default_language_code;
    l_msite_languages_tbl(l_i).default_flag := FND_API.g_true;
    l_msite_languages_tbl(l_i).enable_flag := 'Y';
  END IF;
  IBE_MSite_GRP.save_msite_languages(
    p_api_version => l_api_version,
    p_init_msg_list => FND_API.g_false,
    p_commit => p_commit,
    x_return_status => l_return_status,
    x_msg_count => l_msg_count,
    x_msg_data => l_msg_data,
    p_msite_id => l_msite_id,
    p_msite_languages_tbl => l_msite_languages_tbl);
  IF (l_return_status = FND_API.G_RET_STS_ERROR) THEN
    IF (l_debug = 'Y') THEN
      IBE_UTIL.debug('Error in IBE_MSite_GRP.save_msite_languages');
      for i in 1..l_msg_count loop
        l_msg_data := FND_MSG_PUB.get(i,FND_API.G_FALSE);
        IBE_UTIL.debug(l_msg_data);
      end loop;
    END IF;
    RAISE FND_API.G_EXC_ERROR;
  ELSIF (l_return_status = FND_API.G_RET_STS_UNEXP_ERROR) THEN
    IF (l_debug = 'Y') THEN
      IBE_UTIL.debug('Error in IBE_MSite_GRP.save_msite_languages');
      for i in 1..l_msg_count loop
        l_msg_data := FND_MSG_PUB.get(i,FND_API.G_FALSE);
        IBE_UTIL.debug(l_msg_data);
      end loop;
    END IF;
    RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
  END IF;

  -- Duplicate Currencies and price lists
  l_i := 1;
  l_def_found := 0;
  OPEN c_get_msite_pricing_csr(p_msite_rec.msite_id);
  LOOP
    FETCH c_get_msite_pricing_csr INTO l_currency_code,
      l_bizpartner_prc_listid, l_registered_prc_listid,
      l_walkin_prc_listid, l_orderable_limit,
      l_payment_threshold, l_partner_prc_listid;
    EXIT WHEN c_get_msite_pricing_csr%NOTFOUND;

    IF (l_currency_code = p_default_currency_code) THEN
      l_def_found := 1;
      l_registered_prc_listid := p_walkin_pricing_id;
      l_bizpartner_prc_listid := p_walkin_pricing_id;
      l_partner_prc_listid := p_walkin_pricing_id;
      l_msite_currencies_tbl(l_i).currency_code := l_currency_code;
      l_msite_currencies_tbl(l_i).walkin_prc_lst_id
        := p_walkin_pricing_id;
      l_msite_currencies_tbl(l_i).registered_prc_lst_id
        := l_registered_prc_listid;
      l_msite_currencies_tbl(l_i).biz_partner_prc_lst_id
        := l_bizpartner_prc_listid;
      l_msite_currencies_tbl(l_i).orderable_limit
        := l_orderable_limit;
      l_msite_currencies_tbl(l_i).default_flag := FND_API.g_true;
      l_msite_currencies_tbl(l_i).payment_threshold
        := l_payment_threshold;

      l_msite_currencies_tbl(l_i).partner_prc_lst_id
        := l_partner_prc_listid;

    ELSE
      l_msite_currencies_tbl(l_i).currency_code := l_currency_code;
      l_msite_currencies_tbl(l_i).walkin_prc_lst_id
        := l_walkin_prc_listid;
      l_msite_currencies_tbl(l_i).registered_prc_lst_id
        := l_registered_prc_listid;
      l_msite_currencies_tbl(l_i).biz_partner_prc_lst_id
        := l_bizpartner_prc_listid;
      l_msite_currencies_tbl(l_i).orderable_limit
        := l_orderable_limit;
      l_msite_currencies_tbl(l_i).default_flag := FND_API.g_false;
      l_msite_currencies_tbl(l_i).payment_threshold
        := l_payment_threshold;

      l_msite_currencies_tbl(l_i).partner_prc_lst_id
        := l_partner_prc_listid;

    END IF;
    l_i := l_i + 1;
  END LOOP;
  CLOSE c_get_msite_pricing_csr;
  IF (l_i = 1) OR (l_def_found = 0) THEN
      l_msite_currencies_tbl(l_i).currency_code := p_default_currency_code;
      l_msite_currencies_tbl(l_i).walkin_prc_lst_id
        := p_walkin_pricing_id;
      l_msite_currencies_tbl(l_i).registered_prc_lst_id
        := p_walkin_pricing_id;
      l_msite_currencies_tbl(l_i).biz_partner_prc_lst_id
        := p_walkin_pricing_id;
      l_msite_currencies_tbl(l_i).orderable_limit
        := NULL;
      l_msite_currencies_tbl(l_i).default_flag := FND_API.g_true;
      l_msite_currencies_tbl(l_i).payment_threshold
        := NULL;

      l_msite_currencies_tbl(l_i).partner_prc_lst_id
        := p_walkin_pricing_id;

  END IF;
  IBE_MSite_GRP.save_msite_currencies(
    p_api_version => 1.0,
    p_init_msg_list => FND_API.g_false,
    p_commit => p_commit,
    x_return_status => l_return_status,
    x_msg_count => l_msg_count,
    x_msg_data => l_msg_data,
    p_msite_id => l_msite_id,
    p_msite_currencies_tbl => l_msite_currencies_tbl);
  IF (l_return_status = FND_API.G_RET_STS_ERROR) THEN
    IF (l_debug = 'Y') THEN
      IBE_UTIL.debug('Error in IBE_MSite_GRP.save_msite_currencies');
      for i in 1..l_msg_count loop
        l_msg_data := FND_MSG_PUB.get(i,FND_API.G_FALSE);
        IBE_UTIL.debug(l_msg_data);
      end loop;
    END IF;
    RAISE FND_API.G_EXC_ERROR;
  ELSIF (l_return_status = FND_API.G_RET_STS_UNEXP_ERROR) THEN
    IF (l_debug = 'Y') THEN
      IBE_UTIL.debug('Error in IBE_MSite_GRP.save_msite_currencies');
      for i in 1..l_msg_count loop
        l_msg_data := FND_MSG_PUB.get(i,FND_API.G_FALSE);
        IBE_UTIL.debug(l_msg_data);
      end loop;
    END IF;
    RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
  END IF;

  -- For Payment Types, Shipping Methods, and Credit Card
  IBE_MSITE_INFORMATION_MGR_PVT.duplicate_msite_info (
    p_api_version => 1.0,
    p_init_msg_list => FND_API.G_FALSE,
    p_commit => p_commit,
    p_validation_level => FND_API.G_VALID_LEVEL_FULL,
    p_source_msite_id => p_msite_rec.msite_id,
    p_target_msite_id => l_msite_id,
    x_return_status => l_return_status,
    x_msg_count => l_msg_count,
    x_msg_data => l_msg_data
    );
  IF (l_return_status = FND_API.G_RET_STS_ERROR) THEN
    IF (l_debug = 'Y') THEN
      IBE_UTIL.debug('Error in IBE_MSITE_INFORMATION_MGR_PVT.'||
	   'Change_Msite_Info');
      for i in 1..l_msg_count loop
        l_msg_data := FND_MSG_PUB.get(i,FND_API.G_FALSE);
        IBE_UTIL.debug(l_msg_data);
      end loop;
    END IF;
    RAISE FND_API.G_EXC_ERROR;
  ELSIF (l_return_status = FND_API.G_RET_STS_UNEXP_ERROR) THEN
    IF (l_debug = 'Y') THEN
      IBE_UTIL.debug('Error in IBE_MSITE_INFORMATION_MGR_PVT.'||
	   'Change_Msite_Info');
      for i in 1..l_msg_count loop
        l_msg_data := FND_MSG_PUB.get(i,FND_API.G_FALSE);
        IBE_UTIL.debug(l_msg_data);
      end loop;
    END IF;
    RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
  END IF;

  -- For Responsibility Association Plus Group Code
  l_prev_msite_resp_id := NULL;
  l_msite_resp_id := NULL;
  x_msite_resp_id := NULL;
  l_order_type_id := null;

  OPEN c_get_msite_resp_csr(p_msite_rec.msite_id);
  LOOP
    FETCH c_get_msite_resp_csr INTO l_msite_resp_id, l_responsibility_id,
	 l_application_id, l_display_name, l_start_date_active,
	 l_end_date_active, l_sort_order, l_group_code, l_order_Type_id;
    EXIT WHEN c_get_msite_resp_csr%NOTFOUND;
    fnd_message.set_name('IBE','IBE_M_COPY_OF');
    fnd_message.set_token('NAME',l_display_name);
    l_copy := fnd_message.get;

    IF (l_prev_msite_resp_id IS NULL) OR
	 (l_prev_msite_resp_id <> l_msite_resp_id) THEN
	 l_prev_msite_resp_id := l_msite_resp_id;
	 l_msite_resp_id := NULL;

      IBE_Msite_Resp_Pvt.Create_Msite_Resp (
        p_api_version => 1.0,
        p_init_msg_list => FND_API.G_FALSE,
        p_commit => p_commit,
        p_validation_level => FND_API.G_VALID_LEVEL_FULL,
        p_msite_resp_id => l_msite_resp_id,
        p_msite_id => l_msite_id,
        p_responsibility_id => l_responsibility_id,
        p_application_id => l_application_id,
        p_start_date_active => l_start_date_active,
        p_end_date_active => l_end_date_active,
        p_sort_order => l_sort_order,
        p_display_name => l_copy,
        p_group_code => l_group_code,
        p_ordertype_id => l_order_type_id,
        x_msite_resp_id => x_msite_resp_id,
        x_return_status => l_return_status,
        x_msg_count => l_msg_count,
        x_msg_data => l_msg_data);
    ELSE
      l_msite_resp_id := x_msite_resp_id;

      IBE_Msite_Resp_Pvt.Create_Msite_Resp (
        p_api_version => 1.0,
        p_init_msg_list => FND_API.G_FALSE,
        p_commit => p_commit,
        p_validation_level => FND_API.G_VALID_LEVEL_FULL,
        p_msite_resp_id => l_msite_resp_id,
        p_msite_id => l_msite_id,
        p_responsibility_id => l_responsibility_id,
        p_application_id => l_application_id,
        p_start_date_active => l_start_date_active,
        p_end_date_active => l_end_date_active,
        p_sort_order => l_sort_order,
        p_display_name => l_copy,
        p_group_code => l_group_code,
        p_ordertype_id => l_order_type_id,
        x_msite_resp_id => x_msite_resp_id,
        x_return_status => l_return_status,
        x_msg_count => l_msg_count,
        x_msg_data => l_msg_data);
    END IF;
    IF (l_return_status = FND_API.G_RET_STS_ERROR) THEN
      IF (l_debug = 'Y') THEN
        IBE_UTIL.debug('Error in IBE_Msite_Resp_Pvt.Create_Msite_Resp');
        for i in 1..l_msg_count loop
          l_msg_data := FND_MSG_PUB.get(i,FND_API.G_FALSE);
          IBE_UTIL.debug(l_msg_data);
        end loop;
      END IF;
      RAISE FND_API.G_EXC_ERROR;
    ELSIF (l_return_status = FND_API.G_RET_STS_UNEXP_ERROR) THEN
      IF (l_debug = 'Y') THEN
        IBE_UTIL.debug('Error in IBE_Msite_Resp_Pvt.Create_Msite_Resp');
        for i in 1..l_msg_count loop
          l_msg_data := FND_MSG_PUB.get(i,FND_API.G_FALSE);
          IBE_UTIL.debug(l_msg_data);
        end loop;
      END IF;
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;
  END LOOP;
  CLOSE c_get_msite_resp_csr;

  -- Access Restriction
  l_i := 1;
  l_party_ids := JTF_NUMBER_TABLE();
  l_start_date_actives := JTF_DATE_TABLE();
  l_end_date_actives := JTF_DATE_TABLE();
  OPEN c_get_msite_access_csr(p_msite_rec.msite_id);
  LOOP
     FETCH c_get_msite_access_csr INTO l_party_id,
	  l_start_date_active, l_end_date_active;
     EXIT WHEN c_get_msite_access_csr%NOTFOUND;
	l_party_ids.EXTEND;
	l_start_date_actives.EXTEND;
	l_end_date_actives.EXTEND;
	l_party_ids(l_i) := l_party_id;
	l_start_date_actives(l_i) := l_start_date_active;
	l_end_date_actives(l_i) := l_end_date_active;
	l_i := l_i + 1;
  END LOOP;
  CLOSE c_get_msite_access_csr;
  IF (l_i > 1) THEN
    Ibe_Msite_Prty_Accss_Mgr_Pvt.Associate_Parties_To_MSite(
      p_api_version => 1.0,
      p_init_msg_list => FND_API.G_FALSE,
      p_commit => p_commit,
      p_validation_level => FND_API.G_VALID_LEVEL_FULL,
      p_msite_id => l_msite_id,
      p_party_ids => l_party_ids,
      p_start_date_actives => l_start_date_actives,
      p_end_date_actives => l_end_date_actives,
      x_msite_prty_accss_ids => l_msite_prty_accss_ids,
      x_duplicate_association_status => l_duplicate_association_status,
      x_is_any_duplicate_status => l_is_any_duplicate_status,
      x_return_status => l_return_status,
      x_msg_count => l_msg_count,
      x_msg_data => l_msg_data);
    IF (l_return_status = FND_API.G_RET_STS_ERROR) THEN
      IF (l_debug = 'Y') THEN
        IBE_UTIL.debug('Error in IBE_MSite_GRP.save_msite_currencies');
        for i in 1..l_msg_count loop
          l_msg_data := FND_MSG_PUB.get(i,FND_API.G_FALSE);
          IBE_UTIL.debug(l_msg_data);
        end loop;
      END IF;
      RAISE FND_API.G_EXC_ERROR;
    ELSIF (l_return_status = FND_API.G_RET_STS_UNEXP_ERROR) THEN
      IF (l_debug = 'Y') THEN
        IBE_UTIL.debug('Error in IBE_MSite_GRP.save_msite_currencies');
        for i in 1..l_msg_count loop
          l_msg_data := FND_MSG_PUB.get(i,FND_API.G_FALSE);
          IBE_UTIL.debug(l_msg_data);
        end loop;
      END IF;
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;
  END IF;

  IF (l_debug = 'Y') THEN
    IBE_UTIL.debug('Before committing the work:'||p_commit);
  END IF;
  IF (FND_API.To_Boolean(p_commit)) THEN
    COMMIT WORK;
  END IF;
  FND_MSG_PUB.Count_And_Get(p_count => x_msg_count,
    p_data    => x_msg_data,
    p_encoded => 'F');
  IF (l_debug = 'Y') THEN
    IBE_UTIL.debug('duplicate_msite Ends +');
  END IF;
EXCEPTION
  WHEN FND_API.G_EXC_ERROR THEN
    ROLLBACK TO DUPLICATE_MSITE_SAVE;
    x_return_status := FND_API.G_RET_STS_ERROR;
    FND_MSG_PUB.Count_And_Get(p_count => x_msg_count,
	 p_data    => x_msg_data,
	 p_encoded => 'F');
  WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
    ROLLBACK TO DUPLICATE_MSITE_SAVE;
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    FND_MSG_PUB.Count_And_Get(p_count => x_msg_count,
	 p_data    => x_msg_data,
	 p_encoded => 'F');
  WHEN OTHERS THEN
    ROLLBACK TO DUPLICATE_MSITE_SAVE;
    FND_MESSAGE.Set_Name('FND', 'SQL_PLSQL_ERROR');
    FND_MESSAGE.Set_Token('ROUTINE', l_api_name);
    FND_MESSAGE.Set_Token('ERRNO', SQLCODE);
    FND_MESSAGE.Set_Token('REASON', SQLERRM);
    FND_MSG_PUB.Add;
    IF (l_debug = 'Y') THEN
    IBE_UTIL.debug('SQLCODE:'||SQLCODE);
    IBE_UTIL.debug('SQLERRM:'||SQLERRM);
    END IF;
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) THEN
      FND_MSG_PUB.Add_Exc_Msg(G_PKG_NAME, l_api_name);
    END IF;
    FND_MSG_PUB.Count_And_Get(p_count => x_msg_count,
	 p_data    => x_msg_data,
	 p_encoded => 'F');
END duplicate_msite;


PROCEDURE save_msite_languages(
  p_api_version   IN  NUMBER,
  p_init_msg_list IN  VARCHAR2 := FND_API.g_false,
  p_commit              IN  VARCHAR2  := FND_API.g_false,
  x_return_status       OUT NOCOPY VARCHAR2,
  x_msg_count           OUT NOCOPY  NUMBER,
  x_msg_data            OUT NOCOPY  VARCHAR2,
  p_msite_id            IN   NUMBER,
  p_msite_languages_tbl IN MSITE_LANGUAGES_TBL_TYPE
                              )
IS
  l_api_name    CONSTANT VARCHAR2(30) := 'save_msite_languages';
  l_full_name   CONSTANT VARCHAR2(60) := g_pkg_name ||'.'|| l_api_name;
  l_msite_id		NUMBER;
  l_exists		NUMBER;
  default_index	NUMBER := 0;

  CURSOR msite_languages_id_seq IS
    SELECT ibe_msite_languages_s1.NEXTVAL
      FROM DUAL;

    l_msite_languages_id NUMBER;
    l_insert_row NUMBER := 0;
    l_debug VARCHAR2(1);


BEGIN
        l_debug  := NVL(FND_PROFILE.VALUE('IBE_DEBUG'),'N');

  --------------------- initialize -----------------------+
  SAVEPOINT save_msite_languages;

  IF NOT FND_API.compatible_api_call(
    g_api_version,
    p_api_version,
    l_api_name,
    g_pkg_name
                                    ) THEN
    RAISE FND_API.g_exc_unexpected_error;
  END IF;


  IF FND_API.to_boolean(p_init_msg_list) THEN
    FND_MSG_PUB.initialize;
  END IF;


  x_return_status := FND_API.G_RET_STS_SUCCESS;

  --- Check if the msite_id exists
  IF p_msite_id IS NOT NULL and p_msite_id <> FND_API.g_miss_num
  THEN

    if ibe_dspmgrvalidation_grp.check_msite_exists(p_msite_id) = false then
      raise FND_API.g_exc_error;
    end if;

    --dbms_output.put_line('Minisite id is passed '  );
    ---- Delete all the entries for the mini-site

    if p_msite_languages_tbl.count > 0
    then

      DELETE FROM IBE_MSITE_LANGUAGES where
        msite_id = p_msite_id;

      --- Insert all the rows for the minisite


      --dbms_output.put_line('Default language id is passed deleted'  );

      for l_index in 1..p_msite_languages_tbl.count
      LOOP
       BEGIN
        savepoint save_msite_language;

        if valid_language(p_msite_languages_tbl(l_index).language_code) =
           false THEN
           raise FND_API.g_exc_error;
        end if;

        OPEN msite_languages_id_seq;
        FETCH msite_languages_id_seq INTO l_msite_languages_id;
        CLOSE msite_languages_id_seq;

       INSERT INTO IBE_MSITE_LANGUAGES (
         MSITE_LANGUAGE_ID,
         OBJECT_VERSION_NUMBER,
         LAST_UPDATE_DATE,
         LAST_UPDATED_BY,
         CREATION_DATE,
         CREATED_BY,
         LAST_UPDATE_LOGIN,
         MSITE_ID,
         LANGUAGE_CODE,
 	 ENABLE_FLAG)
       VALUES (
         l_msite_languages_id,
         1,
         SYSDATE,
         FND_GLOBAL.user_id,
         SYSDATE,
         FND_GLOBAL.user_id,
         FND_GLOBAL.user_id,
         p_msite_id,
         p_msite_languages_tbl(l_index).language_code,
 	 p_msite_languages_tbl(l_index).enable_flag);

       --dbms_output.put_line('inserted language  passed '  );
      l_insert_row := l_insert_row + 1;
      -- Check if this language is default
      if p_msite_languages_tbl(l_index).default_flag = FND_API.g_true
         and default_index = 0 then
          default_index := l_index;
      end if;

    EXCEPTION
          WHEN OTHERS   THEN
            ROLLBACK TO save_msite_language;
            x_return_status := FND_API.g_ret_sts_error;
    END;

   END LOOP;
/* else if msite_enabled_for_store(p_msite_id) = true then
         raise msite_languages_missing;
 end if;
        */
  END IF;

  If default_index > 0 then
    --dbms_output.put_line('default is not null');
    update IBE_MSITES_B SET
      DEFAULT_LANGUAGE_CODE =
      p_msite_languages_tbl(default_index).language_code
      WHERE  MSITE_ID = p_msite_id;
  else
    --dbms_output.put_line('default is null');
    raise msite_default_lang_missing;
  end if;

  -- changed 08/04/2003. Will not delete langauges. No need to do this.
  --ibe_physicalmap_grp.delete_msite_language(p_msite_id);

  --- Check if the caller requested to commit ,
  --- If p_commit set to true, commit the transaction
  if l_insert_row > 0 then
    IF  FND_API.to_boolean(p_commit) THEN
        COMMIT;
    END IF;
  else
    raise FND_API.g_exc_error;
  end if;
else
   raise ibe_dspmgrvalidation_grp.msite_req_exception;
end if;
 FND_MSG_PUB.count_and_get( p_encoded => FND_API.g_false,
                            p_count   => x_msg_count,
                            p_data    => x_msg_data
                             );
 EXCEPTION
    WHEN FND_API.g_exc_error THEN
       ROLLBACK TO save_msite_languages;
       x_return_status := FND_API.g_ret_sts_error;
       FND_MSG_PUB.count_and_get(
             p_encoded => FND_API.g_false,
             p_count   => x_msg_count,
             p_data    => x_msg_data
              );
    WHEN ibe_dspmgrvalidation_grp.msite_req_exception THEN
       ROLLBACK TO save_msite_languages;
       x_return_status := FND_API.g_ret_sts_error;
       FND_MESSAGE.set_name('IBE','IBE_MSITE_REQ');
       FND_MSG_PUB.ADD;
       FND_MSG_PUB.count_and_get(
           p_encoded => FND_API.g_false,
           p_count   => x_msg_count,
           p_data    => x_msg_data
           );
    WHEN  msite_default_lang_missing THEN
      ROLLBACK TO save_msite_languages;
      x_return_status := FND_API.g_ret_sts_error;
      FND_MESSAGE.set_name('IBE','IBE_MSITE_DEF_LANG_REQ');
      FND_MESSAGE.set_token('ID', p_msite_id);
      FND_MSG_PUB.ADD;
      FND_MSG_PUB.count_and_get(
           p_encoded => FND_API.g_false,
           p_count   => x_msg_count,
           p_data    => x_msg_data
            );
    WHEN FND_API.g_exc_unexpected_error THEN
      ROLLBACK TO save_msite_languages;
      x_return_status := FND_API.g_ret_sts_unexp_error ;
      FND_MSG_PUB.count_and_get(
          p_encoded => FND_API.g_false,
          p_count   => x_msg_count,
          p_data    => x_msg_data );
    WHEN OTHERS THEN
        ROLLBACK TO save_msite_languages;
        x_return_status := FND_API.g_ret_sts_unexp_error ;
        IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_unexp_error)
        THEN
          FND_MSG_PUB.add_exc_msg(g_pkg_name, l_api_name);
        END IF;
        FND_MSG_PUB.count_and_get(
             p_encoded => FND_API.g_false,
             p_count   => x_msg_count,
             p_data    => x_msg_data  );

END save_msite_languages;

PROCEDURE save_msite_currencies(
       p_api_version         IN  NUMBER,
       p_init_msg_list       IN   VARCHAR2 := FND_API.g_false,
       p_commit              IN  VARCHAR2  := FND_API.g_false,
       x_return_status       OUT NOCOPY VARCHAR2,
       x_msg_count           OUT NOCOPY  NUMBER,
       x_msg_data            OUT NOCOPY  VARCHAR2,
       p_msite_id            IN   NUMBER,
       p_msite_currencies_tbl IN  MSITE_CURRENCIES_TBL_TYPE
        )
IS
 l_api_name    CONSTANT VARCHAR2(30) := 'save_msite_currencies';
 l_full_name   CONSTANT VARCHAR2(60) := g_pkg_name ||'.'|| l_api_name;
 l_msite_id		NUMBER;
 l_exists		NUMBER;
 CURSOR msite_currencies_id_seq IS
     SELECT ibe_msite_currencies_s1.NEXTVAL
       FROM DUAL;
 l_msite_currencies_id NUMBER;
 l_payment_threshold NUMBER;
 l_insert_row	NUMBER := 0;
 default_index NUMBER := 0;
 l_debug VARCHAR2(1);
 l_validate_result VARCHAR2(3);

BEGIN
        l_debug  := NVL(FND_PROFILE.VALUE('IBE_DEBUG'),'N');

   --------------------- initialize -----------------------+

   SAVEPOINT save_msite_currencies;

   IF NOT FND_API.compatible_api_call(
       g_api_version,
       p_api_version,
       l_api_name,
       g_pkg_name ) THEN
           RAISE FND_API.g_exc_unexpected_error;
   END IF;

   IF FND_API.to_boolean(p_init_msg_list) THEN
      FND_MSG_PUB.initialize;
   END IF;
   x_return_status := FND_API.G_RET_STS_SUCCESS;
    --- Check if the msite_id exists
   IF p_msite_id IS NOT NULL and p_msite_id <> FND_API.g_miss_num
   THEN
      --dbms_output.put_line('Minisite id is passed '  );
     if ibe_dspmgrvalidation_grp.check_msite_exists(p_msite_id) = false then
        raise FND_API.g_exc_error;
     end if;
     if (p_msite_currencies_tbl.count > 0 ) then
        ---- Delete all the entries for the mini-site
        DELETE FROM IBE_MSITE_CURRENCIES where
            msite_id = p_msite_id;

         --- Insert all the rows for the minisite
       for l_index in 1..p_msite_currencies_tbl.count
       LOOP
         BEGIN
           savepoint save_msite_currency;
           if valid_currency(p_msite_currencies_tbl(l_index).currency_code)
               = false THEN
               raise FND_API.g_exc_error;
           end if;

	   QP_UTIL_PUB.Validate_Price_List_Curr_Code(
	      p_msite_currencies_tbl(l_index).walkin_prc_lst_id,
 	      p_msite_currencies_tbl(l_index).currency_code,
              NULL,
              l_validate_result);

	   if (l_validate_result = 'N') then
	     raise FND_API.g_exc_error;
           end if;

 	   QP_UTIL_PUB.Validate_Price_List_Curr_Code(
	      p_msite_currencies_tbl(l_index).registered_prc_lst_id,
	      p_msite_currencies_tbl(l_index).currency_code,
              NULL,
              l_validate_result);

	   if (l_validate_result = 'N') then
	     raise FND_API.g_exc_error;
           end if;

 	   QP_UTIL_PUB.Validate_Price_List_Curr_Code(
              p_msite_currencies_tbl(l_index).biz_partner_prc_lst_id,
	      p_msite_currencies_tbl(l_index).currency_code,
              NULL,
              l_validate_result);

	   if (l_validate_result = 'N') then
	     raise FND_API.g_exc_error;
           end if;

 	   QP_UTIL_PUB.Validate_Price_List_Curr_Code(
              p_msite_currencies_tbl(l_index).partner_prc_lst_id,
	      p_msite_currencies_tbl(l_index).currency_code,
              NULL,
              l_validate_result);

	   if (l_validate_result = 'N') then
	     raise FND_API.g_exc_error;
           end if;

/* Sept-05-2003 JQU
   following logic replaced by the 3 QP_UTIL_PUB.Validate_Price_List_Curr_Code
   function calls above to support multi-currency price lists

           if valid_prc_lstids (
              p_msite_currencies_tbl(l_index).currency_code,
              p_msite_currencies_tbl(l_index).walkin_prc_lst_id,
              p_msite_currencies_tbl(l_index).registered_prc_lst_id,

             = false then
              --dbms_output.put_line('invliad prc list id  test');
              raise FND_API.g_exc_error;
         end if;
*/
       l_payment_threshold := p_msite_currencies_tbl(l_index).payment_threshold;
       if(l_payment_threshold = FND_API.g_miss_num)
       then
          l_payment_threshold := NULL;
       end if;


       OPEN msite_currencies_id_seq;
       FETCH msite_currencies_id_seq INTO l_msite_currencies_id;
       CLOSE msite_currencies_id_seq;
       INSERT INTO IBE_MSITE_CURRENCIES (
            MSITE_CURRENCY_ID,
            OBJECT_VERSION_NUMBER,
            LAST_UPDATE_DATE,
            LAST_UPDATED_BY,
            CREATION_DATE,
            CREATED_BY,
            LAST_UPDATE_LOGIN,
            MSITE_ID,
            CURRENCY_CODE,
            WALKIN_PRC_LISTID,
            REGISTERED_PRC_LISTID,
            BIZPARTNER_PRC_LISTID,
            ORDERABLE_limit,
            PAYMENT_THRESHOLD,
            PARTNER_PRC_LISTID)
       VALUES (
          l_msite_currencies_id,
          1,
          SYSDATE,
          FND_GLOBAL.user_id,
          SYSDATE,
          FND_GLOBAL.user_id,
          FND_GLOBAL.user_id,
          p_msite_id,
          p_msite_currencies_tbl(l_index).currency_code,
          p_msite_currencies_tbl(l_index).walkin_prc_lst_id,
          p_msite_currencies_tbl(l_index).registered_prc_lst_id,
          p_msite_currencies_tbl(l_index).biz_partner_prc_lst_id,
          p_msite_currencies_tbl(l_index).orderable_limit,
          l_payment_threshold,
          p_msite_currencies_tbl(l_index).partner_prc_lst_id);
  --        p_msite_currencies_tbl(l_index).payment_threshold);
                                                                                 --dbms_output.put_line('inserted into currency');

    l_insert_row	:= l_insert_row + 1;
     --dbms_output.put_line('inserted into currency' || l_insert_row);

    if p_msite_currencies_tbl(l_index).default_flag = FND_API.g_true
       and default_index = 0 then
       default_index := l_index;
    end if;
  EXCEPTION
     WHEN OTHERS   THEN
        ROLLBACK TO save_msite_currency;
        x_return_status := FND_API.g_ret_sts_error;
  END;
 END LOOP;
 /* else if msite_enabled_for_store(p_msite_id) = true then
       raise msite_currencies_missing;
    end if;
   */
 END IF;
 If default_index > 0 then
     update IBE_MSITES_B SET
     DEFAULT_CURRENCY_CODE =
     p_msite_currencies_tbl(default_index).currency_code
     WHERE  MSITE_ID = p_msite_id;
                                                                                  --dbms_output.put_line('set default  currency');
 else
   --dbms_output.put_line('default is null');
  raise msite_default_currency_missing;
 end if;
  --- Check if the caller requested to commit ,
  --- If p_commit set to true, commit the transaction
  if l_insert_row > 0 then
    IF  FND_API.to_boolean(p_commit) THEN
      COMMIT;
    END IF;
  else
   --dbms_output.put_line('raising an error' || l_insert_row);
   raise FND_API.g_exc_error;
  end if;
  else
    raise ibe_dspmgrvalidation_grp.msite_req_exception;
  end if;
   FND_MSG_PUB.count_and_get(
p_encoded => FND_API.g_false,
     p_count   => x_msg_count,
p_data    => x_msg_data
);

    EXCEPTION
       WHEN FND_API.g_exc_error THEN
ROLLBACK TO save_msite_currencies;
x_return_status := FND_API.g_ret_sts_error;
FND_MSG_PUB.count_and_get(
p_encoded => FND_API.g_false,
           p_count   => x_msg_count,
p_data    => x_msg_data
        );
   WHEN ibe_dspmgrvalidation_grp.msite_req_exception THEN
      ROLLBACK TO save_msite_currencies;
x_return_status := FND_API.g_ret_sts_error;
FND_MESSAGE.set_name('IBE','IBE_MSITE_REQ');
          FND_MSG_PUB.ADD;
FND_MSG_PUB.count_and_get(
p_encoded => FND_API.g_false,
p_count   => x_msg_count,
p_data    => x_msg_data
);
 WHEN  msite_default_currency_missing THEN
     ROLLBACK TO save_msite_currencies;
x_return_status := FND_API.g_ret_sts_error;
FND_MESSAGE.set_name('IBE','IBE_MSITE_DEF_CURR_REQ');
FND_MESSAGE.set_token('ID', p_msite_id);
FND_MSG_PUB.ADD;
FND_MSG_PUB.count_and_get(
p_encoded => FND_API.g_false,
        p_count   => x_msg_count,
p_data    => x_msg_data
                         );
        WHEN FND_API.g_exc_unexpected_error THEN
              ROLLBACK TO save_msite_currencies;
              x_return_status := FND_API.g_ret_sts_unexp_error ;
FND_MSG_PUB.count_and_get(
p_encoded => FND_API.g_false,
           p_count   => x_msg_count,
p_data    => x_msg_data
                         );
        WHEN OTHERS THEN
            ROLLBACK TO save_msite_currencies;
x_return_status := FND_API.g_ret_sts_unexp_error ;
IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_unexp_error)
        THEN
FND_MSG_PUB.add_exc_msg(g_pkg_name, l_api_name);
END IF;
FND_MSG_PUB.count_and_get(
p_encoded => FND_API.g_false,
                                                                                      p_count   => x_msg_count,
p_data    => x_msg_data
);

     END save_msite_currencies;



PROCEDURE save_msite_orgids(
                            p_api_version         IN  NUMBER,
                            p_init_msg_list       IN   VARCHAR2 := FND_API.g_false,
  p_commit              IN  VARCHAR2  := FND_API.g_false,
  x_return_status       OUT NOCOPY VARCHAR2,
  x_msg_count           OUT NOCOPY  NUMBER,
  x_msg_data            OUT NOCOPY  VARCHAR2,
  p_msite_id            IN   NUMBER,
  p_msite_orgids_tbl       IN  MSITE_ORGIDS_TBL_TYPE
                           )
IS
  l_api_name    CONSTANT VARCHAR2(30) := 'save_msite_orgids';
  l_full_name   CONSTANT VARCHAR2(60) := g_pkg_name ||'.'|| l_api_name;
  l_msite_id		NUMBER;
  l_exists		NUMBER;
  l_insert_row	NUMBER := 0;

  CURSOR msite_oprorg_id_seq IS
    SELECT ibe_msite_orgs_s1.NEXTVAL
      FROM DUAL;

    l_msite_org_id NUMBER;
    default_index NUMBER := 0;
    l_debug VARCHAR2(1);

BEGIN
        l_debug  := NVL(FND_PROFILE.VALUE('IBE_DEBUG'),'N');

  --------------------- initialize -----------------------+
  SAVEPOINT save_msite_orgids;

  IF NOT FND_API.compatible_api_call(
    g_api_version,
    p_api_version,
    l_api_name,
    g_pkg_name
                                    ) THEN
    RAISE FND_API.g_exc_unexpected_error;
  END IF;


  IF FND_API.to_boolean(p_init_msg_list) THEN
    FND_MSG_PUB.initialize;
  END IF;


  x_return_status := FND_API.G_RET_STS_SUCCESS;

  --- Check if the msite_id exists
  IF p_msite_id IS NOT NULL and p_msite_id <> FND_API.g_miss_num
  THEN
    --dbms_output.put_line('Minisite id is passed '  );

    if ibe_dspmgrvalidation_grp.check_msite_exists(p_msite_id) = false then
      raise FND_API.g_exc_error;
    end if;

    if (p_msite_orgids_tbl.count > 0 ) then
      ---- Delete all the entries for the mini-site
      DELETE FROM IBE_MSITE_ORGS where
        msite_id = p_msite_id;

      --- Insert all the rows for the minisite


      --dbms_output.put_line('passed defualt orgid test');
      for l_index in 1..p_msite_orgids_tbl.count
      LOOP
BEGIN
  savepoint save_msite_orgid;

  if valid_orgid(p_msite_orgids_tbl(l_index).orgid) = false THEN
    raise FND_API.g_exc_error;
  end if;
  OPEN msite_oprorg_id_seq;
  FETCH msite_oprorg_id_seq INTO l_msite_org_id;
  CLOSE msite_oprorg_id_seq;

  INSERT INTO IBE_MSITE_ORGS (
    MSITE_ORG_ID,
    OBJECT_VERSION_NUMBER,
    LAST_UPDATE_DATE,
    LAST_UPDATED_BY,
    CREATION_DATE,
    CREATED_BY,
    LAST_UPDATE_LOGIN,
    MSITE_ID,
    ORG_ID
                             )
    VALUES (
    l_msite_org_id,
    1,
    SYSDATE,
    FND_GLOBAL.user_id,
    SYSDATE,
    FND_GLOBAL.user_id,
    FND_GLOBAL.user_id,
    p_msite_id,
    p_msite_orgids_tbl(l_index).orgid);
  --dbms_output.put_line('inserted into opr org');
  l_insert_row := l_insert_row + 1;

  if p_msite_orgids_tbl(l_index).default_flag = FND_API.g_true
    and default_index = 0 then
    default_index := l_index;
  end if;

EXCEPTION
   WHEN OTHERS   THEN
     ROLLBACK TO save_msite_orgid;
     x_return_status := FND_API.g_ret_sts_error;
END;

      END LOOP;
   /* else
      if msite_enabled_for_store(p_msite_id) = true then
        raise msite_orgs_missing;
      end if;*/
    END IF;

    If default_index > 0 then
      update IBE_MSITES_B SET
        DEFAULT_ORG_ID = p_msite_orgids_tbl(default_index).orgid where
        MSITE_ID = p_msite_id;
    else
      raise msite_default_org_missing;
    end if;

    --- Check if the caller requested to commit ,
    --- If p_commit set to true, commit the transaction
    if l_insert_row > 0 then
      IF  FND_API.to_boolean(p_commit) THEN
        COMMIT;
      END IF;
    else
      raise FND_API.g_exc_error;
    end if;

  else
    raise ibe_dspmgrvalidation_grp.msite_req_exception;
  end if;

  FND_MSG_PUB.count_and_get(
    p_encoded => FND_API.g_false,
    p_count   => x_msg_count,
    p_data    => x_msg_data
                           );

EXCEPTION

   WHEN FND_API.g_exc_error THEN
     ROLLBACK TO save_msite_orgids;
     x_return_status := FND_API.g_ret_sts_error;
     FND_MSG_PUB.count_and_get(
       p_encoded => FND_API.g_false,
       p_count   => x_msg_count,
       p_data    => x_msg_data
                              );

   WHEN ibe_dspmgrvalidation_grp.msite_req_exception THEN
     ROLLBACK TO save_msite_orgids;
     x_return_status := FND_API.g_ret_sts_error;
     FND_MESSAGE.set_name('IBE','IBE_MSITE_REQ');
     FND_MSG_PUB.ADD;
     FND_MSG_PUB.count_and_get(
       p_encoded => FND_API.g_false,
       p_count   => x_msg_count,
       p_data    => x_msg_data
                              );
   WHEN FND_API.g_exc_unexpected_error THEN
     ROLLBACK TO save_msite_orgids;
     x_return_status := FND_API.g_ret_sts_unexp_error ;
     FND_MSG_PUB.count_and_get(
       p_encoded => FND_API.g_false,
       p_count   => x_msg_count,
       p_data    => x_msg_data
                              );

   WHEN  msite_default_org_missing THEN
     ROLLBACK TO save_msite_orgids;
     x_return_status := FND_API.g_ret_sts_error;
     FND_MESSAGE.set_name('IBE','IBE_MSITE_DEF_ORG_REQ');
     FND_MESSAGE.set_token('ID', p_msite_id);
     FND_MSG_PUB.ADD;
     FND_MSG_PUB.count_and_get(
       p_encoded => FND_API.g_false,
       p_count   => x_msg_count,
       p_data    => x_msg_data
                              );

   WHEN OTHERS THEN
     ROLLBACK TO save_msite_orgids;
     x_return_status := FND_API.g_ret_sts_unexp_error ;
     IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_unexp_error)
     THEN
       FND_MSG_PUB.add_exc_msg(g_pkg_name, l_api_name);
     END IF;
     FND_MSG_PUB.count_and_get(
       p_encoded => FND_API.g_false,
       p_count   => x_msg_count,
       p_data    => x_msg_data
                              );

END save_msite_orgids;


PROCEDURE delete_msite(
                       p_api_version           IN  NUMBER,
                       p_init_msg_list    IN   VARCHAR2 := FND_API.g_false,
  p_commit              IN  VARCHAR2  := FND_API.g_false,
  x_return_status       OUT NOCOPY VARCHAR2,
  x_msg_count           OUT NOCOPY  NUMBER,
  x_msg_data            OUT NOCOPY  VARCHAR2,
  p_msite_id_tbl        IN msite_delete_tbl_type
                      )
IS

  l_api_name    CONSTANT VARCHAR2(30) := 'delete_msite';
  l_full_name   CONSTANT VARCHAR2(60) := g_pkg_name ||'.'|| l_api_name;
  l_msite_id		NUMBER;
  l_exists		NUMBER;
  l_insert_row	NUMBER := 0;
  l_index		NUMBER := 0;


  CURSOR c_msite_resp (p_msite_id Number) Is
    Select msite_resp_id
      From   IBE_MSITE_RESPS_B
      Where  msite_id = p_msite_id ;
      l_debug VARCHAR2(1);

BEGIN
        l_debug := NVL(FND_PROFILE.VALUE('IBE_DEBUG'),'N');

  --------------------- initialize -----------------------+
  SAVEPOINT delete_msite;

  IF NOT FND_API.compatible_api_call(
    g_api_version,
    p_api_version,
    l_api_name,
    g_pkg_name
                                    ) THEN
    RAISE FND_API.g_exc_unexpected_error;
  END IF;


  IF FND_API.to_boolean(p_init_msg_list) THEN
    FND_MSG_PUB.initialize;
  END IF;


  x_return_status := FND_API.G_RET_STS_SUCCESS;

  --- Check if the msite_id exists
  for l_index in 1..p_msite_id_tbl.count
  LOOP
    BEGIN
      savepoint delete_msite_id;
      IF p_msite_id_tbl(l_index).msite_id IS NOT NULL and
        p_msite_id_tbl(l_index).msite_id <> FND_API.g_miss_num
      THEN
        --dbms_output.put_line('Minisite id is passed '  );

        --- if ibe_dspmgrvalidation_grp.check_msite_exists(p_msite_id_tbl(l_index).msite_id) = false then
        ---       raise FND_API.g_exc_error;
        --- end if;

        ibe_physicalmap_grp.delete_msite(p_msite_id_tbl(l_index).msite_id);

        delete from ibe_msite_languages where msite_id = p_msite_id_tbl(l_index).msite_id;
        delete from ibe_msite_currencies where msite_id = p_msite_id_tbl(l_index).msite_id;
        delete from ibe_msite_orgs where msite_id = p_msite_id_tbl(l_index).msite_id;
        delete from ibe_dsp_msite_sct_sects where mini_site_id=p_msite_id_tbl(l_index).msite_id;
        delete from ibe_dsp_msite_sct_items where mini_site_id=p_msite_id_tbl(l_index).msite_id;
        delete from ibe_msites_tl where msite_id = p_msite_id_tbl(l_index).msite_id;
        delete from ibe_msites_b where msite_id = p_msite_id_tbl(l_index).msite_id;

        --added for deleting the rows from the newly added Merchant responsibility
        --table -- ssridhar

        for rec_msite_resp in c_msite_resp (p_msite_id_tbl(l_index).msite_id )
        Loop
          Ibe_Msite_Resp_Pvt.Delete_Msite_Resp(
            p_api_version    => 1.0 ,
            p_init_msg_list  => FND_API.G_FALSE,
            p_commit         => FND_API.G_FALSE,
            p_validation_level=>FND_API.G_VALID_LEVEL_FULL,
            p_msite_resp_id  => rec_msite_resp.msite_resp_id ,
            -- p_msite_id     => FND_API.G_MISS_NUM,
            --p_responsibility_id => FND_API.G_MISS_NUM,
            --p_application_id => FND_API.G_MISS_NUM,
            x_return_status   => x_return_status ,
            x_msg_count       => x_msg_count ,
            x_msg_data        => x_msg_data  );

          IF (x_return_status = FND_API.G_RET_STS_ERROR) THEN
            FND_MESSAGE.Set_Name('IBE', 'IBE_MSITE_DELETE_MSITE_RESP_FL');
            FND_MSG_PUB.Add;
            RAISE FND_API.G_EXC_ERROR;
          ELSIF (x_return_status = FND_API.G_RET_STS_UNEXP_ERROR) THEN
            FND_MESSAGE.Set_Name('IBE', 'IBE_MSITE_DELETE_MSITE_RESP_FL');
            FND_MSG_PUB.Add;
            RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
          END IF;
        End Loop;

        delete from ibe_msite_prty_accss
          where msite_id = p_msite_id_tbl(l_index).msite_id;

        delete from ibe_wf_notif_msg_maps
          where msite_id = p_msite_id_tbl(l_index).msite_id;

      else
        raise ibe_dspmgrvalidation_grp.msite_req_exception;
      end if;

    EXCEPTION
       WHEN OTHERS   THEN
         ROLLBACK TO delete_msite_id;
         x_return_status := FND_API.g_ret_sts_error;
    END;

  END LOOP;



  IF  FND_API.to_boolean(p_commit) THEN
    COMMIT;
  END IF;

  x_return_status := FND_API.G_RET_STS_SUCCESS;

  FND_MSG_PUB.count_and_get(
    p_encoded => FND_API.g_false,
    p_count   => x_msg_count,
    p_data    => x_msg_data
                           );

EXCEPTION
   WHEN FND_API.g_exc_error THEN
     ROLLBACK TO delete_msite;
     x_return_status := FND_API.g_ret_sts_error;
     FND_MSG_PUB.count_and_get(
       p_encoded => FND_API.g_false,
       p_count   => x_msg_count,
       p_data    => x_msg_data
                              );

   WHEN ibe_dspmgrvalidation_grp.msite_req_exception THEN
     ROLLBACK TO delete_msite;
     x_return_status := FND_API.g_ret_sts_error;
     FND_MESSAGE.set_name('IBE','IBE_MSITE_REQ');
     FND_MSG_PUB.ADD;
     FND_MSG_PUB.count_and_get(
       p_encoded => FND_API.g_false,
       p_count   => x_msg_count,
       p_data    => x_msg_data
                              );

   WHEN FND_API.g_exc_unexpected_error THEN
     ROLLBACK TO delete_msite;
     x_return_status := FND_API.g_ret_sts_unexp_error ;
     FND_MSG_PUB.count_and_get(
       p_encoded => FND_API.g_false,
       p_count   => x_msg_count,
       p_data    => x_msg_data
                              );

   WHEN OTHERS THEN
     ROLLBACK TO delete_msite;
     x_return_status := FND_API.g_ret_sts_unexp_error ;
     IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_unexp_error)
     THEN
       FND_MSG_PUB.add_exc_msg(g_pkg_name, l_api_name);
     END IF;
     FND_MSG_PUB.count_and_get(
       p_encoded => FND_API.g_false,
       p_count   => x_msg_count,
       p_data    => x_msg_data
                              );

end delete_msite;


PROCEDURE get_msite_attribute (
                               p_api_version         	IN  NUMBER,
                               p_init_msg_list       	IN   VARCHAR2 := FND_API.g_false,
  p_commit              	IN  VARCHAR2  := FND_API.g_false,
  x_return_status       	OUT NOCOPY VARCHAR2,
  x_msg_count           	OUT NOCOPY  NUMBER,
  x_msg_data            	OUT NOCOPY  VARCHAR2,
  p_msite_id		 	IN   NUMBER,
  p_msite_attribute_name     IN   VARCHAR2,
  x_msite_attribute_value	OUT NOCOPY VARCHAR2)
IS

  l_api_name    CONSTANT VARCHAR2(30) := 'get_msite_attribute';
  l_full_name   CONSTANT VARCHAR2(60) := g_pkg_name ||'.'|| l_api_name;
  l_debug VARCHAR2(1);

BEGIN
        l_debug := NVL(FND_PROFILE.VALUE('IBE_DEBUG'),'N');

  --------------------- initialize -----------------------+
  SAVEPOINT get_msite_attribute;

  IF NOT FND_API.compatible_api_call(
    g_api_version,
    p_api_version,
    l_api_name,
    g_pkg_name
                                    ) THEN
    RAISE FND_API.g_exc_unexpected_error;
  END IF;


  IF FND_API.to_boolean(p_init_msg_list) THEN
    FND_MSG_PUB.initialize;
  END IF;


  x_return_status := FND_API.G_RET_STS_SUCCESS;

  IF p_msite_id IS NOT NULL AND p_msite_id <> FND_API.g_miss_num
  THEN
    --dbms_output.put_line('Minisite id is passed '  );

    if ibe_dspmgrvalidation_grp.check_msite_exists(p_msite_id) = false then
      raise FND_API.g_exc_error;
    end if;

    x_msite_attribute_value := FND_PROFILE.VALUE_SPECIFIC(p_msite_attribute_name,null,null,671);
  ELSE
    raise ibe_dspmgrvalidation_grp.msite_req_exception;
  END IF;

  x_return_status := FND_API.G_RET_STS_SUCCESS;

  FND_MSG_PUB.count_and_get(
    p_encoded => FND_API.g_false,
    p_count   => x_msg_count,
    p_data    => x_msg_data
                           );

EXCEPTION
   WHEN FND_API.g_exc_error THEN
     ROLLBACK TO get_msite_attribute;
     x_return_status := FND_API.g_ret_sts_error;
     FND_MSG_PUB.count_and_get(
       p_encoded => FND_API.g_false,
       p_count   => x_msg_count,
       p_data    => x_msg_data
                              );

   WHEN ibe_dspmgrvalidation_grp.msite_req_exception THEN
     ROLLBACK TO get_msite_attribute;
     x_return_status := FND_API.g_ret_sts_error;
     FND_MESSAGE.set_name('IBE','IBE_MSITE_REQ');
     FND_MSG_PUB.ADD;
     FND_MSG_PUB.count_and_get(
       p_encoded => FND_API.g_false,
       p_count   => x_msg_count,
       p_data    => x_msg_data
                              );

   WHEN FND_API.g_exc_unexpected_error THEN
     ROLLBACK TO get_msite_attribute;
     x_return_status := FND_API.g_ret_sts_unexp_error ;
     FND_MSG_PUB.count_and_get(
       p_encoded => FND_API.g_false,
       p_count   => x_msg_count,
       p_data    => x_msg_data
                              );

   WHEN OTHERS THEN
     ROLLBACK TO get_msite_attribute;
     x_return_status := FND_API.g_ret_sts_unexp_error ;
     IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_unexp_error)
     THEN
       FND_MSG_PUB.add_exc_msg(g_pkg_name, l_api_name);
     END IF;
     FND_MSG_PUB.count_and_get(
       p_encoded => FND_API.g_false,
       p_count   => x_msg_count,
       p_data    => x_msg_data
                              );

end get_msite_attribute;


-- Modifying the procedure to insert 3 new fields for globalisation -- ssridhar
--   RESP_ACCESS_FLAG
--   PARTY_ACCESS_CODE
--   ACCESS_NAME

procedure INSERT_ROW (
                      X_ROWID 			in out NOCOPY 	VARCHAR2,
                      X_MSITE_ID 			in 	NUMBER,
                      X_ATTRIBUTE_CATEGORY 		in 	VARCHAR2,
                      X_ATTRIBUTE1 			in 	VARCHAR2,
                      X_ATTRIBUTE2 			in	VARCHAR2,
                      X_ATTRIBUTE3 			in 	VARCHAR2,
                      X_ATTRIBUTE4 			in 	VARCHAR2,
                      X_ATTRIBUTE5 			in 	VARCHAR2,
                      X_ATTRIBUTE6 			in 	VARCHAR2,
                      X_ATTRIBUTE7 			in 	VARCHAR2,
                      X_ATTRIBUTE8 			in 	VARCHAR2,
                      X_ATTRIBUTE9 			in 	VARCHAR2,
                      X_ATTRIBUTE11 		in 	VARCHAR2,
                      X_ATTRIBUTE10 		in 	VARCHAR2,
                      X_ATTRIBUTE12 		in 	VARCHAR2,
                      X_ATTRIBUTE13 		in 	VARCHAR2,
                      X_ATTRIBUTE14 		in 	VARCHAR2,
                      X_ATTRIBUTE15 		in 	VARCHAR2,
                      X_OBJECT_VERSION_NUMBER	in 	NUMBER,
                      X_STORE_ID 			in 	NUMBER,
                      X_START_DATE_ACTIVE 		in 	DATE,
                      X_END_DATE_ACTIVE 		in 	DATE,
                      X_DEFAULT_LANGUAGE_CODE 	in 	VARCHAR2,
                      X_DEFAULT_CURRENCY_CODE 	in 	VARCHAR2,
                      X_DEFAULT_DATE_FORMAT 	in 	VARCHAR2,
                      X_DEFAULT_ORG_ID 		in 	NUMBER,
                      X_ATP_CHECK_FLAG 		in 	VARCHAR2,
                      X_WALKIN_ALLOWED_FLAG 	in 	VARCHAR2,
                      X_MSITE_ROOT_SECTION_ID 	in 	NUMBER,
                      X_PROFILE_ID 			in 	NUMBER,
                      X_MASTER_MSITE_FLAG 		in 	VARCHAR2,
                      X_MSITE_NAME 			in 	VARCHAR2,
                      X_MSITE_DESCRIPTION 		in 	VARCHAR2,
                      X_CREATION_DATE 		in 	DATE,
                      X_CREATED_BY 			in 	NUMBER,
                      X_LAST_UPDATE_DATE 		in 	DATE,
                      X_LAST_UPDATED_BY 		in 	NUMBER,
                      X_LAST_UPDATE_LOGIN 		in 	NUMBER,
                      X_RESP_ACCESS_FLAG            in      VARCHAR2 ,
                      X_PARTY_ACCESS_CODE           in      VARCHAR2 ,
                      X_ACCESS_NAME                 in      VARCHAR2 ,
                      X_URL                         in      VARCHAR2 ,
                      X_THEME_ID                    in      NUMBER ,
                      X_PAYMENT_THRESH_ENABLE_FLAG  in VARCHAR2  := NULL,
                      X_DOMAIN_NAME                 in VARCHAR2  := NULL,
                      X_ENABLE_TRAFFIC_FILTER       in VARCHAR2  := 'N',
                      X_REPORTING_STATUS            in VARCHAR2  := 'N',
                      X_SITE_TYPE                   in VARCHAR2  := 'I')
is
  cursor C is select ROWID from IBE_MSITES_B
    where MSITE_ID = X_MSITE_ID
    ;
begin
  insert into IBE_MSITES_B (
    ATTRIBUTE_CATEGORY,
    ATTRIBUTE1,
    ATTRIBUTE2,
    ATTRIBUTE3,
    ATTRIBUTE4,
    ATTRIBUTE5,
    ATTRIBUTE6,
    ATTRIBUTE7,
    ATTRIBUTE8,
    ATTRIBUTE9,
    ATTRIBUTE11,
    ATTRIBUTE10,
    ATTRIBUTE12,
    ATTRIBUTE13,
    ATTRIBUTE14,
    ATTRIBUTE15,
    MSITE_ID,
    OBJECT_VERSION_NUMBER,
    STORE_ID,
    START_DATE_ACTIVE,
    END_DATE_ACTIVE,
    DEFAULT_LANGUAGE_CODE,
    DEFAULT_CURRENCY_CODE,
    DEFAULT_DATE_FORMAT,
    DEFAULT_ORG_ID,
    ATP_CHECK_FLAG,
    WALKIN_ALLOWED_FLAG,
    MSITE_ROOT_SECTION_ID,
    PROFILE_ID,
    MASTER_MSITE_FLAG,
    CREATION_DATE,
    CREATED_BY,
    LAST_UPDATE_DATE,
    LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN ,
    RESP_ACCESS_FLAG ,
    PARTY_ACCESS_CODE ,
    ACCESS_NAME ,
    URL ,
    THEME_ID,
    PAYMENT_THRESHOLD_ENABLE_FLAG,
	DOMAIN_NAME,
	ENABLE_TRAFFIC_FILTER,
	REPORTING_STATUS,
	SITE_TYPE
    ) values (
    X_ATTRIBUTE_CATEGORY,
    X_ATTRIBUTE1,
    X_ATTRIBUTE2,
    X_ATTRIBUTE3,
    X_ATTRIBUTE4,
    X_ATTRIBUTE5,
    X_ATTRIBUTE6,
    X_ATTRIBUTE7,
    X_ATTRIBUTE8,
    X_ATTRIBUTE9,
    X_ATTRIBUTE11,
    X_ATTRIBUTE10,
    X_ATTRIBUTE12,
    X_ATTRIBUTE13,
    X_ATTRIBUTE14,
    X_ATTRIBUTE15,
    X_MSITE_ID,
    X_OBJECT_VERSION_NUMBER,
    X_STORE_ID,
    X_START_DATE_ACTIVE,
    X_END_DATE_ACTIVE,
    X_DEFAULT_LANGUAGE_CODE,
    X_DEFAULT_CURRENCY_CODE,
    X_DEFAULT_DATE_FORMAT,
    X_DEFAULT_ORG_ID,
    X_ATP_CHECK_FLAG,
    X_WALKIN_ALLOWED_FLAG,
    X_MSITE_ROOT_SECTION_ID,
    X_PROFILE_ID,
    X_MASTER_MSITE_FLAG,
    X_CREATION_DATE,
    X_CREATED_BY,
    X_LAST_UPDATE_DATE,
    X_LAST_UPDATED_BY,
    X_LAST_UPDATE_LOGIN ,
    X_RESP_ACCESS_FLAG ,
    X_PARTY_ACCESS_CODE ,
    X_ACCESS_NAME,
    X_URL,
    X_THEME_ID,
    X_PAYMENT_THRESH_ENABLE_FLAG,
	X_DOMAIN_NAME,
	X_ENABLE_TRAFFIC_FILTER,
	X_REPORTING_STATUS,
	X_SITE_TYPE  );

  insert into IBE_MSITES_TL (
    MSITE_ID,
    OBJECT_VERSION_NUMBER,
    CREATED_BY,
    CREATION_DATE,
    LAST_UPDATED_BY,
    LAST_UPDATE_DATE,
    LAST_UPDATE_LOGIN,
    MSITE_NAME,
    MSITE_DESCRIPTION,
    LANGUAGE,
    SOURCE_LANG
                            ) select
      X_MSITE_ID,
      X_OBJECT_VERSION_NUMBER,
      X_CREATED_BY,
      X_CREATION_DATE,
      X_LAST_UPDATED_BY,
      X_LAST_UPDATE_DATE,
      X_LAST_UPDATE_LOGIN,
      X_MSITE_NAME,
      X_MSITE_DESCRIPTION,
      L.LANGUAGE_CODE,
      userenv('LANG')
      from FND_LANGUAGES L
      where L.INSTALLED_FLAG in ('I', 'B')
      and not exists
      (select NULL
      from IBE_MSITES_TL T
      where T.MSITE_ID = X_MSITE_ID
      and T.LANGUAGE = L.LANGUAGE_CODE);

    open c;
    fetch c into X_ROWID;
    if (c%notfound) then
      close c;
      raise no_data_found;
    end if;
    close c;

end INSERT_ROW;

-- Modifying the procedure to accept 3 new fields for globalisation -- ssridhar
--   RESP_ACCESS_FLAG
--   PARTY_ACCESS_CODE
--   ACCESS_NAME

procedure LOCK_ROW (
                    X_MSITE_ID 			in 	NUMBER,
                    X_ATTRIBUTE_CATEGORY 		in 	VARCHAR2,
                    X_ATTRIBUTE1 			in 	VARCHAR2,
                    X_ATTRIBUTE2 			in	VARCHAR2,
                    X_ATTRIBUTE3 			in 	VARCHAR2,
                    X_ATTRIBUTE4 			in 	VARCHAR2,
                    X_ATTRIBUTE5 			in 	VARCHAR2,
                    X_ATTRIBUTE6 			in 	VARCHAR2,
                    X_ATTRIBUTE7 			in 	VARCHAR2,
                    X_ATTRIBUTE8 			in 	VARCHAR2,
                    X_ATTRIBUTE9 			in 	VARCHAR2,
                    X_ATTRIBUTE11 		in 	VARCHAR2,
                    X_ATTRIBUTE10 		in 	VARCHAR2,
                    X_ATTRIBUTE12 		in 	VARCHAR2,
                    X_ATTRIBUTE13 		in 	VARCHAR2,
                    X_ATTRIBUTE14 		in 	VARCHAR2,
                    X_ATTRIBUTE15 		in 	VARCHAR2,
                    X_OBJECT_VERSION_NUMBER 	in 	NUMBER,
                    X_STORE_ID 			in 	NUMBER,
                    X_START_DATE_ACTIVE 		in 	DATE,
                    X_END_DATE_ACTIVE 		in 	DATE,
                    X_DEFAULT_LANGUAGE_CODE 	in 	VARCHAR2,
                    X_DEFAULT_CURRENCY_CODE 	in 	VARCHAR2,
                    X_DEFAULT_DATE_FORMAT 	in 	VARCHAR2,
                    X_DEFAULT_ORG_ID 		in 	NUMBER,
                    X_ATP_CHECK_FLAG 		in 	VARCHAR2,
                    X_WALKIN_ALLOWED_FLAG 	in 	VARCHAR2,
                    X_MSITE_ROOT_SECTION_ID 	in 	NUMBER,
                    X_PROFILE_ID 			in 	NUMBER,
                    X_MASTER_MSITE_FLAG 		in 	VARCHAR2,
                    X_MSITE_NAME 			in 	VARCHAR2,
                    X_MSITE_DESCRIPTION 		in 	VARCHAR2 ,
                    X_RESP_ACCESS_FLAG            in 	VARCHAR2 ,
                    X_PARTY_ACCESS_CODE           in 	VARCHAR2 ,
                    X_ACCESS_NAME                 in 	VARCHAR2 ,
                    X_URL                         in      VARCHAR2 ,
                    X_THEME_ID                    in      NUMBER ,
                    X_PAYMENT_THRESH_ENABLE_FLAG  in VARCHAR2  := NULL,
                    X_DOMAIN_NAME                 in VARCHAR2  := NULL,
                    X_ENABLE_TRAFFIC_FILTER       in VARCHAR2  := 'N',
                    X_REPORTING_STATUS            in VARCHAR2  := 'N',
                    X_SITE_TYPE                   in VARCHAR2  := 'I')
IS
  cursor c is select
    ATTRIBUTE_CATEGORY,
      ATTRIBUTE1,
      ATTRIBUTE2,
      ATTRIBUTE3,
      ATTRIBUTE4,
      ATTRIBUTE5,
      ATTRIBUTE6,
      ATTRIBUTE7,
      ATTRIBUTE8,
      ATTRIBUTE9,
      ATTRIBUTE11,
      ATTRIBUTE10,
      ATTRIBUTE12,
      ATTRIBUTE13,
      ATTRIBUTE14,
      ATTRIBUTE15,
      OBJECT_VERSION_NUMBER,
      STORE_ID,
      START_DATE_ACTIVE,
      END_DATE_ACTIVE,
      DEFAULT_LANGUAGE_CODE,
      DEFAULT_CURRENCY_CODE,
      DEFAULT_DATE_FORMAT,
      DEFAULT_ORG_ID,
      ATP_CHECK_FLAG,
      WALKIN_ALLOWED_FLAG,
      MSITE_ROOT_SECTION_ID,
      PROFILE_ID,
      MASTER_MSITE_FLAG ,
      RESP_ACCESS_FLAG ,
      PARTY_ACCESS_CODE ,
      ACCESS_NAME ,
      URL ,
      THEME_ID,
      PAYMENT_THRESHOLD_ENABLE_FLAG,
	  DOMAIN_NAME,
	  ENABLE_TRAFFIC_FILTER,
	  REPORTING_STATUS,
	  SITE_TYPE
      from IBE_MSITES_B
      where MSITE_ID = X_MSITE_ID
      for update of MSITE_ID nowait;
    recinfo c%rowtype;

    cursor c1 is select
      MSITE_NAME,
        MSITE_DESCRIPTION,
        decode(LANGUAGE, userenv('LANG'), 'Y', 'N') BASELANG
        from IBE_MSITES_TL
        where MSITE_ID = X_MSITE_ID
        and userenv('LANG') in (LANGUAGE, SOURCE_LANG)
        for update of MSITE_ID nowait;
begin
  open c;
  fetch c into recinfo;
  if (c%notfound) then
    close c;
    fnd_message.set_name('FND', 'FORM_RECORD_DELETED');
    app_exception.raise_exception;
  end if;
  close c;
  if (    ((recinfo.ATTRIBUTE_CATEGORY = X_ATTRIBUTE_CATEGORY)
    OR ((recinfo.ATTRIBUTE_CATEGORY is null) AND (X_ATTRIBUTE_CATEGORY is null)))
    AND ((recinfo.ATTRIBUTE1 = X_ATTRIBUTE1)
    OR ((recinfo.ATTRIBUTE1 is null) AND (X_ATTRIBUTE1 is null)))
    AND ((recinfo.ATTRIBUTE2 = X_ATTRIBUTE2)
    OR ((recinfo.ATTRIBUTE2 is null) AND (X_ATTRIBUTE2 is null)))
    AND ((recinfo.ATTRIBUTE3 = X_ATTRIBUTE3)
    OR ((recinfo.ATTRIBUTE3 is null) AND (X_ATTRIBUTE3 is null)))
    AND ((recinfo.ATTRIBUTE4 = X_ATTRIBUTE4)
    OR ((recinfo.ATTRIBUTE4 is null) AND (X_ATTRIBUTE4 is null)))
    AND ((recinfo.ATTRIBUTE5 = X_ATTRIBUTE5)
    OR ((recinfo.ATTRIBUTE5 is null) AND (X_ATTRIBUTE5 is null)))
    AND ((recinfo.ATTRIBUTE6 = X_ATTRIBUTE6)
    OR ((recinfo.ATTRIBUTE6 is null) AND (X_ATTRIBUTE6 is null)))
    AND ((recinfo.ATTRIBUTE7 = X_ATTRIBUTE7)
    OR ((recinfo.ATTRIBUTE7 is null) AND (X_ATTRIBUTE7 is null)))
    AND ((recinfo.ATTRIBUTE8 = X_ATTRIBUTE8)
    OR ((recinfo.ATTRIBUTE8 is null) AND (X_ATTRIBUTE8 is null)))
    AND ((recinfo.ATTRIBUTE9 = X_ATTRIBUTE9)
    OR ((recinfo.ATTRIBUTE9 is null) AND (X_ATTRIBUTE9 is null)))
    AND ((recinfo.ATTRIBUTE11 = X_ATTRIBUTE11)
    OR ((recinfo.ATTRIBUTE11 is null) AND (X_ATTRIBUTE11 is null)))
    AND ((recinfo.ATTRIBUTE10 = X_ATTRIBUTE10)
    OR ((recinfo.ATTRIBUTE10 is null) AND (X_ATTRIBUTE10 is null)))
    AND ((recinfo.ATTRIBUTE12 = X_ATTRIBUTE12)
    OR ((recinfo.ATTRIBUTE12 is null) AND (X_ATTRIBUTE12 is null)))
    AND ((recinfo.ATTRIBUTE13 = X_ATTRIBUTE13)
    OR ((recinfo.ATTRIBUTE13 is null) AND (X_ATTRIBUTE13 is null)))
    AND ((recinfo.ATTRIBUTE14 = X_ATTRIBUTE14)
    OR ((recinfo.ATTRIBUTE14 is null) AND (X_ATTRIBUTE14 is null)))
    AND ((recinfo.ATTRIBUTE15 = X_ATTRIBUTE15)
    OR ((recinfo.ATTRIBUTE15 is null) AND (X_ATTRIBUTE15 is null)))
    AND (recinfo.OBJECT_VERSION_NUMBER = X_OBJECT_VERSION_NUMBER)
    AND ((recinfo.STORE_ID = X_STORE_ID)
    OR ((recinfo.STORE_ID is null) AND (X_STORE_ID is null)))
    AND (recinfo.START_DATE_ACTIVE = X_START_DATE_ACTIVE)
    AND ((recinfo.END_DATE_ACTIVE = X_END_DATE_ACTIVE)
    OR ((recinfo.END_DATE_ACTIVE is null) AND (X_END_DATE_ACTIVE is null)))
    AND ((recinfo.DEFAULT_LANGUAGE_CODE = X_DEFAULT_LANGUAGE_CODE)
    OR ((recinfo.DEFAULT_LANGUAGE_CODE is null) AND (X_DEFAULT_LANGUAGE_CODE is null)))
    AND ((recinfo.DEFAULT_CURRENCY_CODE = X_DEFAULT_CURRENCY_CODE)
    OR ((recinfo.DEFAULT_CURRENCY_CODE is null) AND (X_DEFAULT_CURRENCY_CODE is null)))
    AND ((recinfo.DEFAULT_DATE_FORMAT = X_DEFAULT_DATE_FORMAT)
    OR ((recinfo.DEFAULT_DATE_FORMAT is null) AND (X_DEFAULT_DATE_FORMAT is null)))
    AND ((recinfo.DEFAULT_ORG_ID = X_DEFAULT_ORG_ID)
    OR ((recinfo.DEFAULT_ORG_ID is null) AND (X_DEFAULT_ORG_ID is null)))
    AND ((recinfo.ATP_CHECK_FLAG = X_ATP_CHECK_FLAG)
    OR ((recinfo.ATP_CHECK_FLAG is null) AND (X_ATP_CHECK_FLAG is null)))
    AND ((recinfo.WALKIN_ALLOWED_FLAG = X_WALKIN_ALLOWED_FLAG)
    OR ((recinfo.WALKIN_ALLOWED_FLAG is null) AND (X_WALKIN_ALLOWED_FLAG is null)))
    AND ((recinfo.MSITE_ROOT_SECTION_ID = X_MSITE_ROOT_SECTION_ID)
    OR ((recinfo.MSITE_ROOT_SECTION_ID is null) AND (X_MSITE_ROOT_SECTION_ID is null)))
    AND ((recinfo.PROFILE_ID = X_PROFILE_ID)
    OR ((recinfo.PROFILE_ID is null) AND (X_PROFILE_ID is null)))
    AND ((recinfo.MASTER_MSITE_FLAG = X_MASTER_MSITE_FLAG)
    OR ((recinfo.MASTER_MSITE_FLAG is null) AND (X_MASTER_MSITE_FLAG is null)))
    AND ((recinfo.RESP_ACCESS_FLAG = X_RESP_ACCESS_FLAG )
    OR ((recinfo.RESP_ACCESS_FLAG is null) AND (X_RESP_ACCESS_FLAG is null)))
    AND ((recinfo.PARTY_ACCESS_CODE = X_PARTY_ACCESS_CODE )
    OR ((recinfo.PARTY_ACCESS_CODE is null) AND ( X_PARTY_ACCESS_CODE is null)))
    AND ((recinfo.ACCESS_NAME = X_ACCESS_NAME )
    OR ((recinfo.ACCESS_NAME is null) AND ( X_ACCESS_NAME is null)))
    AND ((recinfo.URL = X_URL )
    OR ((recinfo.URL is null) AND ( X_URL is null)))
    AND ((recinfo.THEME_ID = X_THEME_ID )
    OR ((recinfo.THEME_ID is null) AND ( X_THEME_ID is null)))
    AND ((recinfo.PAYMENT_THRESHOLD_ENABLE_FLAG = X_PAYMENT_THRESH_ENABLE_FLAG)
    OR ((recinfo.PAYMENT_THRESHOLD_ENABLE_FLAG is null) AND (X_PAYMENT_THRESH_ENABLE_FLAG is null)))
    AND ((recinfo.DOMAIN_NAME= X_DOMAIN_NAME)
    OR ((recinfo.DOMAIN_NAME is null) AND (X_DOMAIN_NAME is null)))
    AND ((recinfo.ENABLE_TRAFFIC_FILTER = X_ENABLE_TRAFFIC_FILTER)
    OR ((recinfo.ENABLE_TRAFFIC_FILTER is null) AND (X_ENABLE_TRAFFIC_FILTER is null)))
    AND ((recinfo.REPORTING_STATUS = X_REPORTING_STATUS)
    OR ((recinfo.REPORTING_STATUS is null) AND (X_REPORTING_STATUS is null)))
    AND ((recinfo.SITE_TYPE = X_SITE_TYPE)
    OR ((recinfo.SITE_TYPE is null) AND (X_SITE_TYPE is null)))
     ) then
    null;
  else
    fnd_message.set_name('FND', 'FORM_RECORD_CHANGED');
    app_exception.raise_exception;
  end if;

  for tlinfo in c1 loop
    if (tlinfo.BASELANG = 'Y') then
      if (    ((tlinfo.MSITE_NAME = X_MSITE_NAME)
        OR ((tlinfo.MSITE_NAME is null) AND (X_MSITE_NAME is null)))
        AND ((tlinfo.MSITE_DESCRIPTION = X_MSITE_DESCRIPTION)
        OR ((tlinfo.MSITE_DESCRIPTION is null) AND (X_MSITE_DESCRIPTION is null)))
         ) then
        null;
      else
        fnd_message.set_name('FND', 'FORM_RECORD_CHANGED');
        app_exception.raise_exception;
      end if;
    end if;
  end loop;
  return;
end LOCK_ROW;

-- UPDATE_ROW procedure is not being called for updating rows in this package
-- Modifying the procedure to updating 3 new fields for globalisation
-- ssridhar
--   RESP_ACCESS_FLAG
--   PARTY_ACCESS_CODE
--   ACCESS_NAME


procedure UPDATE_ROW (
                      X_MSITE_ID 			in NUMBER,
                      X_ATTRIBUTE_CATEGORY 		in VARCHAR2,
                      X_ATTRIBUTE1 			in VARCHAR2,
                      X_ATTRIBUTE2 			in VARCHAR2,
                      X_ATTRIBUTE3 			in VARCHAR2,
                      X_ATTRIBUTE4 			in VARCHAR2,
                      X_ATTRIBUTE5 			in VARCHAR2,
                      X_ATTRIBUTE6 			in VARCHAR2,
                      X_ATTRIBUTE7 			in VARCHAR2,
                      X_ATTRIBUTE8 			in VARCHAR2,
                      X_ATTRIBUTE9 			in VARCHAR2,
                      X_ATTRIBUTE11 		in VARCHAR2,
                      X_ATTRIBUTE10 		in VARCHAR2,
                      X_ATTRIBUTE12 		in VARCHAR2,
                      X_ATTRIBUTE13 		in VARCHAR2,
                      X_ATTRIBUTE14 		in VARCHAR2,
                      X_ATTRIBUTE15 		in VARCHAR2,
                      X_OBJECT_VERSION_NUMBER 	in NUMBER,
                      X_STORE_ID 			in NUMBER,
                      X_START_DATE_ACTIVE 		in DATE,
                      X_END_DATE_ACTIVE 		in DATE,
                      X_DEFAULT_LANGUAGE_CODE 	in VARCHAR2,
                      X_DEFAULT_CURRENCY_CODE 	in VARCHAR2,
                      X_DEFAULT_DATE_FORMAT 	in VARCHAR2,
                      X_DEFAULT_ORG_ID 		in NUMBER,
                      X_ATP_CHECK_FLAG 		in VARCHAR2,
                      X_WALKIN_ALLOWED_FLAG 	in VARCHAR2,
                      X_MSITE_ROOT_SECTION_ID 	in NUMBER,
                      X_PROFILE_ID 			in NUMBER,
                      X_MASTER_MSITE_FLAG 		in VARCHAR2,
                      X_MSITE_NAME 			in VARCHAR2,
                      X_MSITE_DESCRIPTION 		in VARCHAR2,
                      X_LAST_UPDATE_DATE 		in DATE,
                      X_LAST_UPDATED_BY 		in NUMBER,
                      X_LAST_UPDATE_LOGIN 		in NUMBER ,
                      X_RESP_ACCESS_FLAG            in VARCHAR2 ,
                      X_PARTY_ACCESS_CODE           in VARCHAR2 ,
                      X_ACCESS_NAME                 in VARCHAR2 ,
                      X_URL                       IN VARCHAR2 ,
                      X_THEME_ID                  IN NUMBER ,
                      X_PAYMENT_THRESH_ENABLE_FLAG  in VARCHAR2  := NULL,
					  X_DOMAIN_NAME                 in VARCHAR2  := NULL,
					  X_ENABLE_TRAFFIC_FILTER       in VARCHAR2  := 'N',
					  X_REPORTING_STATUS            in VARCHAR2  := 'N',
					  X_SITE_TYPE                   in VARCHAR2  := 'I')
		IS
		begin
		  update IBE_MSITES_B set
			ATTRIBUTE_CATEGORY           = X_ATTRIBUTE_CATEGORY,
			ATTRIBUTE1                   = X_ATTRIBUTE1,
			ATTRIBUTE2                   = X_ATTRIBUTE2,
			ATTRIBUTE3                   = X_ATTRIBUTE3,
			ATTRIBUTE4                   = X_ATTRIBUTE4,
			ATTRIBUTE5                   = X_ATTRIBUTE5,
			ATTRIBUTE6                   = X_ATTRIBUTE6,
			ATTRIBUTE7                   = X_ATTRIBUTE7,
			ATTRIBUTE8                   = X_ATTRIBUTE8,
			ATTRIBUTE9                   = X_ATTRIBUTE9,
			ATTRIBUTE11                  = X_ATTRIBUTE11,
			ATTRIBUTE10                  = X_ATTRIBUTE10,
			ATTRIBUTE12                  = X_ATTRIBUTE12,
			ATTRIBUTE13                  = X_ATTRIBUTE13,
			ATTRIBUTE14                  = X_ATTRIBUTE14,
			ATTRIBUTE15                  = X_ATTRIBUTE15,
			OBJECT_VERSION_NUMBER        = OBJECT_VERSION_NUMBER+1,
			STORE_ID                     = X_STORE_ID,
			START_DATE_ACTIVE            = X_START_DATE_ACTIVE,
			END_DATE_ACTIVE              = X_END_DATE_ACTIVE,
			DEFAULT_LANGUAGE_CODE        = X_DEFAULT_LANGUAGE_CODE,
			DEFAULT_CURRENCY_CODE        = X_DEFAULT_CURRENCY_CODE,
			DEFAULT_DATE_FORMAT          = X_DEFAULT_DATE_FORMAT,
			DEFAULT_ORG_ID               = X_DEFAULT_ORG_ID,
			ATP_CHECK_FLAG               = X_ATP_CHECK_FLAG,
			WALKIN_ALLOWED_FLAG          = X_WALKIN_ALLOWED_FLAG,
			MSITE_ROOT_SECTION_ID        = X_MSITE_ROOT_SECTION_ID,
			PROFILE_ID                   = X_PROFILE_ID,
			MASTER_MSITE_FLAG            = X_MASTER_MSITE_FLAG,
			LAST_UPDATE_DATE             = X_LAST_UPDATE_DATE,
			LAST_UPDATED_BY              = X_LAST_UPDATED_BY,
			LAST_UPDATE_LOGIN            = X_LAST_UPDATE_LOGIN ,
			RESP_ACCESS_FLAG             = X_RESP_ACCESS_FLAG ,
			PARTY_ACCESS_CODE            = X_PARTY_ACCESS_CODE ,
			ACCESS_NAME                  = X_ACCESS_NAME ,
			URL                          = X_URL ,
			THEME_ID                     = X_THEME_ID ,
			PAYMENT_THRESHOLD_ENABLE_FLAG = X_PAYMENT_THRESH_ENABLE_FLAG,
			DOMAIN_NAME                   = X_DOMAIN_NAME,
			ENABLE_TRAFFIC_FILTER         = X_ENABLE_TRAFFIC_FILTER,
			REPORTING_STATUS              = X_REPORTING_STATUS,
			SITE_TYPE                     = X_SITE_TYPE
			WHERE
			MSITE_ID                     = X_MSITE_ID
			AND OBJECT_VERSION_NUMBER        = decode(X_OBJECT_VERSION_NUMBER,
			FND_API.G_MISS_NUM,
			OBJECT_VERSION_NUMBER,
			X_OBJECT_VERSION_NUMBER);

		  if (sql%notfound) then
			raise no_data_found;
		  end if;

		  update IBE_MSITES_TL set
			MSITE_NAME = X_MSITE_NAME,
			OBJECT_VERSION_NUMBER = OBJECT_VERSION_NUMBER+1,
			MSITE_DESCRIPTION = X_MSITE_DESCRIPTION,
			LAST_UPDATE_DATE = X_LAST_UPDATE_DATE,
			LAST_UPDATED_BY = X_LAST_UPDATED_BY,
			LAST_UPDATE_LOGIN = X_LAST_UPDATE_LOGIN,
			SOURCE_LANG = userenv('LANG')
			where MSITE_ID = X_MSITE_ID
			and userenv('LANG') in (LANGUAGE, SOURCE_LANG)
			and OBJECT_VERSION_NUMBER = decode(X_OBJECT_VERSION_NUMBER,
			FND_API.G_MISS_NUM,
			OBJECT_VERSION_NUMBER,
			X_OBJECT_VERSION_NUMBER);

		  if (sql%notfound) then
			raise no_data_found;
		  end if;
		end UPDATE_ROW;

		procedure DELETE_ROW (
							  X_MSITE_ID 			in NUMBER
							 ) IS
		begin
		  delete from IBE_MSITES_TL
			where MSITE_ID = X_MSITE_ID;

		  if (sql%notfound) then
			raise no_data_found;
		  end if;

		  delete from IBE_MSITES_B
			where MSITE_ID = X_MSITE_ID;

		  if (sql%notfound) then
			raise no_data_found;
		  end if;
		end DELETE_ROW;

procedure TRANSLATE_ROW (
								 X_MSITE_ID          	in      NUMBER,
								 X_OWNER               in      VARCHAR2,
								 X_MSITE_NAME          in      VARCHAR2,
								 X_MSITE_DESCRIPTION   in      VARCHAR2,
								 X_LAST_UPDATE_DATE in varchar2,
                                 X_CUSTOM_MODE  in Varchar2
								) IS
  f_luby    number;  -- entity owner in file
 f_ludate  date;    -- entity update date in file
 db_luby   number;  -- entity owner in db
 db_ludate date;    -- entity update date in db

begin
 f_luby := fnd_load_util.owner_id(X_OWNER);
 f_ludate := nvl(to_date(X_LAST_UPDATE_DATE, 'YYYY/MM/DD'), sysdate);
 select LAST_UPDATED_BY, LAST_UPDATE_DATE
   	into db_luby, db_ludate
  	from ibe_msites_tl
   	where msite_id = X_MSITE_ID
	and language=userenv('LANG');-- bug #5089259

IF (fnd_load_util.upload_test(f_luby, f_ludate, db_luby, db_ludate, X_CUSTOM_MODE)) then

		  update ibe_msites_tl
			set language = USERENV('LANG'),
			source_lang = USERENV('LANG'),
			object_version_number = object_version_number + 1,
			msite_name = X_MSITE_NAME,
			msite_description = X_MSITE_DESCRIPTION,
			last_updated_by = f_luby,--decode(X_OWNER,'SEED',1,0),
			last_update_date = f_ludate, --sysdate,
			last_update_login=0
			Where userenv('LANG') in (language,source_lang)
			and msite_id = X_MSITE_ID;
END IF;
EXCEPTION
  WHEN OTHERS THEN
    IF FND_MSG_PUB.Check_Msg_level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
    THEN
      FND_MSG_PUB.Add_Exc_Msg(G_PKG_NAME, 'Translate_Row');
    END IF;
    RAISE;

end TRANSLATE_ROW;

		-- Modifying the procedure to accept 3 new fields for globalisation
		-- ssridhar
		--   RESP_ACCESS_FLAG
		--   PARTY_ACCESS_CODE
		--   ACCESS_NAME



procedure LOAD_ROW (
							X_MSITE_ID 			in NUMBER,
							X_OWNER			in VARCHAR2,
							X_ATTRIBUTE_CATEGORY 		in VARCHAR2,
							X_ATTRIBUTE1 			in VARCHAR2,
							X_ATTRIBUTE2 			in VARCHAR2,
							X_ATTRIBUTE3 			in VARCHAR2,
							X_ATTRIBUTE4 			in VARCHAR2,
							X_ATTRIBUTE5 			in VARCHAR2,
							X_ATTRIBUTE6 			in VARCHAR2,
							X_ATTRIBUTE7 			in VARCHAR2,
							X_ATTRIBUTE8 			in VARCHAR2,
							X_ATTRIBUTE9 			in VARCHAR2,
							X_ATTRIBUTE11 		in VARCHAR2,
							X_ATTRIBUTE10 		in VARCHAR2,
							X_ATTRIBUTE12 		in VARCHAR2,
							X_ATTRIBUTE13 		in VARCHAR2,
							X_ATTRIBUTE14 		in VARCHAR2,
							X_ATTRIBUTE15 		in VARCHAR2,
							X_OBJECT_VERSION_NUMBER 	in NUMBER,
							X_STORE_ID 			in NUMBER,
							X_START_DATE_ACTIVE 		in DATE,
							X_END_DATE_ACTIVE 		in DATE,
							X_DEFAULT_LANGUAGE_CODE 	in VARCHAR2,
							X_DEFAULT_CURRENCY_CODE 	in VARCHAR2,
							X_DEFAULT_DATE_FORMAT 	in VARCHAR2,
							X_DEFAULT_ORG_ID 		in NUMBER,
							X_ATP_CHECK_FLAG 		in VARCHAR2,
							X_WALKIN_ALLOWED_FLAG 	in VARCHAR2,
							X_MSITE_ROOT_SECTION_ID 	in NUMBER,
							X_PROFILE_ID 			in NUMBER,
							X_MASTER_MSITE_FLAG 		in VARCHAR2,
							X_MSITE_NAME 			in VARCHAR2,
							X_MSITE_DESCRIPTION 		in VARCHAR2 ,
							X_RESP_ACCESS_FLAG            in VARCHAR2 ,
							X_PARTY_ACCESS_CODE           in VARCHAR2 ,
							X_ACCESS_NAME                 in VARCHAR2 ,
							X_URL                       in  VARCHAR2 ,
							X_THEME_ID                  in  NUMBER ,
                       		X_PAYMENT_THRESH_ENABLE_FLAG  in VARCHAR2  := NULL,
				     	    X_DOMAIN_NAME                 in VARCHAR2  := NULL,
					        X_ENABLE_TRAFFIC_FILTER       in VARCHAR2  := 'N',
					        X_REPORTING_STATUS            in VARCHAR2  := 'N',
					        X_SITE_TYPE                   in VARCHAR2  := 'I',
                            X_LAST_UPDATE_DATE in varchar2,
                            X_CUSTOM_MODE  in Varchar2)
IS

  Owner_id 	NUMBER := 0;
  Row_Id		VARCHAR2(64);
  l_object_version_number          NUMBER := 1;
  f_luby    number;  -- entity owner in file
  f_ludate  date;    -- entity update date in file
  db_luby   number;  -- entity owner in db
  db_ludate date;    -- entity update date in db


Begin
   f_luby := fnd_load_util.owner_id(X_OWNER);
   f_ludate := nvl(to_date(X_LAST_UPDATE_DATE, 'YYYY/MM/DD'), sysdate);
   select LAST_UPDATED_BY, LAST_UPDATE_DATE
   	into db_luby, db_ludate
  	from ibe_msites_b
   	where MSITE_ID = X_MSITE_ID;




  IF ((x_object_version_number IS NOT NULL) AND
      (x_object_version_number <> FND_API.G_MISS_NUM))
  THEN
    l_object_version_number := x_object_version_number;
  END IF;
 IF (fnd_load_util.upload_test(f_luby, f_ludate, db_luby, db_ludate, X_CUSTOM_MODE)) then
  UPDATE_ROW(
    X_MSITE_ID		=>	X_MSITE_ID,
    X_ATTRIBUTE_CATEGORY    =>	X_ATTRIBUTE_CATEGORY,
    X_ATTRIBUTE1            =>	X_ATTRIBUTE1,
    X_ATTRIBUTE2            =>	X_ATTRIBUTE2,
    X_ATTRIBUTE3            =>	X_ATTRIBUTE3,
    X_ATTRIBUTE4            =>	X_ATTRIBUTE4,
    X_ATTRIBUTE5            =>	X_ATTRIBUTE5,
    X_ATTRIBUTE6            =>	X_ATTRIBUTE6,
    X_ATTRIBUTE7            =>	X_ATTRIBUTE7,
    X_ATTRIBUTE8            =>	X_ATTRIBUTE8,
    X_ATTRIBUTE9            =>	X_ATTRIBUTE9,
    X_ATTRIBUTE11           =>	X_ATTRIBUTE10,
    X_ATTRIBUTE10           =>	X_ATTRIBUTE11,
    X_ATTRIBUTE12           =>	X_ATTRIBUTE12,
    X_ATTRIBUTE13           =>	X_ATTRIBUTE13,
    X_ATTRIBUTE14           =>	X_ATTRIBUTE14,
    X_ATTRIBUTE15           =>	X_ATTRIBUTE15,
    X_OBJECT_VERSION_NUMBER =>	X_OBJECT_VERSION_NUMBER,
    X_STORE_ID              =>	X_STORE_ID,
    X_START_DATE_ACTIVE     =>	X_START_DATE_ACTIVE,
    X_END_DATE_ACTIVE       =>     	X_END_DATE_ACTIVE,
    X_DEFAULT_LANGUAGE_CODE =>	X_DEFAULT_LANGUAGE_CODE,
    X_DEFAULT_CURRENCY_CODE =>   	X_DEFAULT_CURRENCY_CODE,
    X_DEFAULT_DATE_FORMAT   =>   	X_DEFAULT_DATE_FORMAT,
    X_DEFAULT_ORG_ID        =>   	X_DEFAULT_ORG_ID,
    X_ATP_CHECK_FLAG        =>	X_ATP_CHECK_FLAG,
    X_WALKIN_ALLOWED_FLAG   =>   	X_WALKIN_ALLOWED_FLAG,
    X_MSITE_ROOT_SECTION_ID =>	X_MSITE_ROOT_SECTION_ID,
    X_PROFILE_ID            =>   	X_PROFILE_ID,
    X_MASTER_MSITE_FLAG     =>      X_MASTER_MSITE_FLAG,
    X_MSITE_NAME            =>   	X_MSITE_NAME,
    X_MSITE_DESCRIPTION  	=>	X_MSITE_DESCRIPTION,
    X_LAST_UPDATE_DATE      =>	f_ludate, --SYSDATE,
    X_LAST_UPDATED_BY       =>	f_luby,--Owner_id,
    X_LAST_UPDATE_LOGIN     =>	0 ,
    X_RESP_ACCESS_FLAG      =>      X_RESP_ACCESS_FLAG ,
    X_PARTY_ACCESS_CODE     =>      X_PARTY_ACCESS_CODE ,
    X_ACCESS_NAME           =>      X_ACCESS_NAME ,
    X_URL                   =>  X_URL,
    X_THEME_ID              =>  X_THEME_ID,
    X_PAYMENT_THRESH_ENABLE_FLAG  => X_PAYMENT_THRESH_ENABLE_FLAG,
    X_DOMAIN_NAME           =>  X_DOMAIN_NAME,
    X_ENABLE_TRAFFIC_FILTER => X_ENABLE_TRAFFIC_FILTER,
    X_REPORTING_STATUS      => X_REPORTING_STATUS,
    X_SITE_TYPE             => X_SITE_TYPE );
END IF;
Exception

   When NO_DATA_FOUND Then
     INSERT_ROW(
     X_ROWID			=>	Row_id,
     X_MSITE_ID		=>	X_MSITE_ID,
     X_ATTRIBUTE_CATEGORY    =>	X_ATTRIBUTE_CATEGORY,
     X_ATTRIBUTE1            =>	X_ATTRIBUTE1,
     X_ATTRIBUTE2            =>	X_ATTRIBUTE2,
     X_ATTRIBUTE3            =>	X_ATTRIBUTE3,
     X_ATTRIBUTE4            =>	X_ATTRIBUTE4,
     X_ATTRIBUTE5            =>	X_ATTRIBUTE5,
     X_ATTRIBUTE6            =>	X_ATTRIBUTE6,
     X_ATTRIBUTE7            =>	X_ATTRIBUTE7,
     X_ATTRIBUTE8            =>	X_ATTRIBUTE8,
     X_ATTRIBUTE9            =>	X_ATTRIBUTE9,
     X_ATTRIBUTE11           =>	X_ATTRIBUTE10,
     X_ATTRIBUTE10           =>	X_ATTRIBUTE11,
     X_ATTRIBUTE12           =>	X_ATTRIBUTE12,
     X_ATTRIBUTE13           =>	X_ATTRIBUTE13,
     X_ATTRIBUTE14           =>	X_ATTRIBUTE14,
     X_ATTRIBUTE15           =>	X_ATTRIBUTE15,
     X_OBJECT_VERSION_NUMBER =>	L_OBJECT_VERSION_NUMBER,
     X_STORE_ID              =>	X_STORE_ID,
     X_START_DATE_ACTIVE     =>	X_START_DATE_ACTIVE,
     X_END_DATE_ACTIVE       =>     	X_END_DATE_ACTIVE,
     X_DEFAULT_LANGUAGE_CODE =>	X_DEFAULT_LANGUAGE_CODE,
     X_DEFAULT_CURRENCY_CODE =>   	X_DEFAULT_CURRENCY_CODE,
     X_DEFAULT_DATE_FORMAT   =>   	X_DEFAULT_DATE_FORMAT,
     X_DEFAULT_ORG_ID        =>   	X_DEFAULT_ORG_ID,
     X_ATP_CHECK_FLAG        =>	X_ATP_CHECK_FLAG,
     X_WALKIN_ALLOWED_FLAG   =>   	X_WALKIN_ALLOWED_FLAG,
     X_MSITE_ROOT_SECTION_ID =>	X_MSITE_ROOT_SECTION_ID,
     X_PROFILE_ID            =>   	X_PROFILE_ID,
     X_MASTER_MSITE_FLAG     =>      X_MASTER_MSITE_FLAG,
     X_MSITE_NAME            =>   	X_MSITE_NAME,
     X_MSITE_DESCRIPTION  	=>	X_MSITE_DESCRIPTION,
     X_CREATION_DATE		=>	f_ludate, --SYSDATE,
     X_CREATED_BY		=>	f_luby,--Owner_id,
     X_LAST_UPDATE_DATE      =>	f_ludate, --SYSDATE,
     X_LAST_UPDATED_BY       =>	f_luby,--Owner_id,
     X_LAST_UPDATE_LOGIN     =>	0 ,
     X_RESP_ACCESS_FLAG      =>      X_RESP_ACCESS_FLAG ,
     X_PARTY_ACCESS_CODE     =>      X_PARTY_ACCESS_CODE ,
     X_ACCESS_NAME           =>      X_ACCESS_NAME ,
     X_URL                   =>  X_URL,
     X_THEME_ID              =>  X_THEME_ID,
     X_PAYMENT_THRESH_ENABLE_FLAG  => X_PAYMENT_THRESH_ENABLE_FLAG,
     X_DOMAIN_NAME           => X_DOMAIN_NAME,
     X_ENABLE_TRAFFIC_FILTER => X_ENABLE_TRAFFIC_FILTER,
     X_REPORTING_STATUS      => X_REPORTING_STATUS,
     X_SITE_TYPE             => X_SITE_TYPE );

End LOAD_ROW;

procedure ADD_LANGUAGE
is
begin
  delete from IBE_MSITES_TL T
    where not exists
    (select NULL
    from IBE_MSITES_B B
    where B.MSITE_ID = T.MSITE_ID
    );

  update IBE_MSITES_TL T set (
    MSITE_NAME,
    MSITE_DESCRIPTION
                             ) = (select
    B.MSITE_NAME,
    B.MSITE_DESCRIPTION
    from IBE_MSITES_TL B
    where B.MSITE_ID = T.MSITE_ID
    and B.LANGUAGE = T.SOURCE_LANG)
    where (
    T.MSITE_ID,
    T.LANGUAGE
          ) in (select
    SUBT.MSITE_ID,
    SUBT.LANGUAGE
    from IBE_MSITES_TL SUBB, IBE_MSITES_TL SUBT
    where SUBB.MSITE_ID = SUBT.MSITE_ID
    and SUBB.LANGUAGE = SUBT.SOURCE_LANG
    and (SUBB.MSITE_NAME <> SUBT.MSITE_NAME
    or (SUBB.MSITE_NAME is null and SUBT.MSITE_NAME is not null)
    or (SUBB.MSITE_NAME is not null and SUBT.MSITE_NAME is null)
    or SUBB.MSITE_DESCRIPTION <> SUBT.MSITE_DESCRIPTION
    or (SUBB.MSITE_DESCRIPTION is null and SUBT.MSITE_DESCRIPTION is not null)
    or (SUBB.MSITE_DESCRIPTION is not null and SUBT.MSITE_DESCRIPTION is null)
        ));

  insert into IBE_MSITES_TL (
    MSITE_ID,
    OBJECT_VERSION_NUMBER,
    CREATED_BY,
    CREATION_DATE,
    LAST_UPDATED_BY,
    LAST_UPDATE_DATE,
    LAST_UPDATE_LOGIN,
    MSITE_NAME,
    MSITE_DESCRIPTION,
    LANGUAGE,
    SOURCE_LANG
                            ) select
    B.MSITE_ID,
      B.OBJECT_VERSION_NUMBER,
      B.CREATED_BY,
      B.CREATION_DATE,
      B.LAST_UPDATED_BY,
      B.LAST_UPDATE_DATE,
      B.LAST_UPDATE_LOGIN,
      B.MSITE_NAME,
      B.MSITE_DESCRIPTION,
      L.LANGUAGE_CODE,
      B.SOURCE_LANG
      from IBE_MSITES_TL B, FND_LANGUAGES L
      where L.INSTALLED_FLAG in ('I', 'B')
      and B.LANGUAGE = userenv('LANG')
      and not exists
      (select NULL
      from IBE_MSITES_TL T
      where T.MSITE_ID = B.MSITE_ID
      and T.LANGUAGE = L.LANGUAGE_CODE);
end ADD_LANGUAGE;

PROCEDURE LOAD_SEED_ROW
  (
  					X_MSITE_ID 		     in NUMBER,
  					X_OWNER         	 in VARCHAR2,
  					X_MSITE_NAME		 in VARCHAR2,
  					X_MSITE_DESCRIPTION 	in VARCHAR2,
  					X_ATTRIBUTE_CATEGORY    in VARCHAR2,
  					X_ATTRIBUTE1            in VARCHAR2,
  					X_ATTRIBUTE2            in VARCHAR2,
  					X_ATTRIBUTE3            in VARCHAR2,
  					X_ATTRIBUTE4            in VARCHAR2,
  					X_ATTRIBUTE5            in VARCHAR2,
  					X_ATTRIBUTE6            in VARCHAR2,
  					X_ATTRIBUTE7            in VARCHAR2,
  					X_ATTRIBUTE8            in VARCHAR2,
  					X_ATTRIBUTE9            in VARCHAR2,
  					X_ATTRIBUTE10           in VARCHAR2,
  					X_ATTRIBUTE11           in VARCHAR2,
  					X_ATTRIBUTE12           in VARCHAR2,
  					X_ATTRIBUTE13           in VARCHAR2,
  					X_ATTRIBUTE14           in VARCHAR2,
  					X_ATTRIBUTE15           in VARCHAR2,
  					X_OBJECT_VERSION_NUMBER in NUMBER,
  					X_STORE_ID              in NUMBER,
  					X_START_DATE_ACTIVE 	IN VARCHAR2,--IN DATE,
                                        X_END_DATE_ACTIVE 	IN VARCHAR2,--	IN DATE,
  					X_DEFAULT_LANGUAGE_CODE in VARCHAR2,
  					X_DEFAULT_CURRENCY_CODE in VARCHAR2,
  					X_DEFAULT_DATE_FORMAT   in VARCHAR2,
  					X_DEFAULT_ORG_ID        in NUMBER,
  					X_ATP_CHECK_FLAG        in VARCHAR2,
  					X_WALKIN_ALLOWED_FLAG   in VARCHAR2,
  					X_MSITE_ROOT_SECTION_ID in NUMBER,
  					X_PROFILE_ID            in NUMBER,
  					X_MASTER_MSITE_FLAG     in VARCHAR2,
					X_RESP_ACCESS_FLAG      in VARCHAR2 ,
					X_PARTY_ACCESS_CODE	    in VARCHAR2 ,
					X_ACCESS_NAME    	    in VARCHAR2 ,
					X_URL			        in VARCHAR2 ,
					X_THEME_ID		        in VARCHAR2 ,
               		X_PAYMENT_THRESH_ENABLE_FLAG  in VARCHAR2  := NULL,
		     	    X_DOMAIN_NAME                 in VARCHAR2  := NULL,
			        X_ENABLE_TRAFFIC_FILTER       in VARCHAR2  := 'N',
			        X_REPORTING_STATUS            in VARCHAR2  := 'N',
			        X_SITE_TYPE                   in VARCHAR2  := 'I',
        			X_LAST_UPDATE_DATE		IN VARCHAR2,
                    X_CUSTOM_MODE           IN VARCHAR2,
           			X_UPLOAD_MODE           IN VARCHAR2
  )
IS
BEGIN
		IF (X_UPLOAD_MODE = 'NLS') then

			TRANSLATE_ROW(
  					X_MSITE_ID,
  					X_OWNER,
  					X_MSITE_NAME,
  					X_MSITE_DESCRIPTION,
                    X_LAST_UPDATE_DATE,
                    X_CUSTOM_MODE);
		Else
			LOAD_ROW(
					X_MSITE_ID,
  					X_OWNER,
  					X_ATTRIBUTE_CATEGORY,
  					X_ATTRIBUTE1,
  					X_ATTRIBUTE2,
  					X_ATTRIBUTE3,
  					X_ATTRIBUTE4,
  					X_ATTRIBUTE5,
  					X_ATTRIBUTE6,
  					X_ATTRIBUTE7,
  					X_ATTRIBUTE8,
  					X_ATTRIBUTE9,
  					X_ATTRIBUTE10,
  					X_ATTRIBUTE11,
  					X_ATTRIBUTE12,
  					X_ATTRIBUTE13,
  					X_ATTRIBUTE14,
  					X_ATTRIBUTE15,
  					X_OBJECT_VERSION_NUMBER,
  					X_STORE_ID,
  					to_date(X_START_DATE_ACTIVE,'YYYY/MM/DD'),
  					to_date(X_END_DATE_ACTIVE,'YYYY/MM/DD'),
  					X_DEFAULT_LANGUAGE_CODE,
  					X_DEFAULT_CURRENCY_CODE,
  					X_DEFAULT_DATE_FORMAT,
  					X_DEFAULT_ORG_ID,
  					X_ATP_CHECK_FLAG,
  					X_WALKIN_ALLOWED_FLAG,
  					X_MSITE_ROOT_SECTION_ID,
  					X_PROFILE_ID,
  					X_MASTER_MSITE_FLAG,
  					X_MSITE_NAME,
  					X_MSITE_DESCRIPTION,
					X_RESP_ACCESS_FLAG,
					X_PARTY_ACCESS_CODE,
					X_ACCESS_NAME,
					X_URL,
					X_THEME_ID,
               		X_PAYMENT_THRESH_ENABLE_FLAG,
		     	    X_DOMAIN_NAME,
			        X_ENABLE_TRAFFIC_FILTER,
			        X_REPORTING_STATUS,
			        X_SITE_TYPE,
                    X_LAST_UPDATE_DATE,
                    X_CUSTOM_MODE);
			End If;


END LOAD_SEED_ROW;


END IBE_Msite_GRP;

/
