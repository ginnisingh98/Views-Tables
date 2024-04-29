--------------------------------------------------------
--  DDL for Package Body JG_ZZ_SHARED_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."JG_ZZ_SHARED_PKG" AS
/* $Header: jgzzssab.pls 120.18.12010000.2 2010/02/04 11:20:08 pakumare ship $ */

FUNCTION IS_GLOBALIZATION_ENABLED(p_country_code IN VARCHAR2)
RETURN VARCHAR2 IS
l_country_code  varchar2(2);
l_disabled varchar2(10);
BEGIN
 -- Assign the country code
 l_country_code := p_country_code;

 IF l_country_code IS NOT NULL THEN
	  BEGIN
			 SELECT 'Yes' into l_disabled FROM FND_LOOKUPS
			 WHERE LOOKUP_TYPE = 'JG_DISABLE_GLOBALIZATION'
			 AND ENABLED_FLAG = 'Y'
			 AND TRUNC(NVL(END_DATE_ACTIVE,SYSDATE+1)) >= TRUNC(SYSDATE)
			 AND TRUNC(START_DATE_ACTIVE) <= TRUNC(SYSDATE)
			 AND LOOKUP_CODE = UPPER(l_country_code);
	  EXCEPTION
	  WHEN TOO_MANY_ROWS THEN
	   l_disabled := 'Yes';
	  WHEN NO_DATA_FOUND THEN
	   l_disabled := NULL;
	  WHEN OTHERS THEN
	   l_disabled := NULL;
	   END;
 END IF;

IF l_disabled = 'Yes' THEN
   l_country_code := NULL;
ELSE
   l_country_code := p_country_code;
END IF;

RETURN l_country_code;

END IS_GLOBALIZATION_ENABLED;

FUNCTION CHECK_CACHE(p_org_id     IN NUMBER,
                     p_ledger_id  IN NUMBER,
                     p_inv_org_id IN NUMBER,
                     p_resp_id    IN NUMBER,
                     p_type       IN VARCHAR2)
RETURN VARCHAR2 IS
BEGIN
  IF p_org_id is NOT NULL THEN
    IF p_type = 'COUNTRY' THEN
      IF JG_ZZ_SHARED_PKG.p_country_tbl.exists('ORGID'||to_char(p_org_id)) THEN
        return JG_ZZ_SHARED_PKG.p_country_tbl('ORGID'||to_char(p_org_id));
      END IF;
    ELSIF p_type = 'PRODUCT' THEN
      IF JG_ZZ_SHARED_PKG.p_product_tbl.exists('ORGID'||to_char(p_org_id)) THEN
        return JG_ZZ_SHARED_PKG.p_product_tbl('ORGID'||to_char(p_org_id));
      END IF;
    ELSIF p_type = 'APPL' THEN
      IF JG_ZZ_SHARED_PKG.p_appl_tbl.exists('ORGID'||to_char(p_org_id)) THEN
        return JG_ZZ_SHARED_PKG.p_appl_tbl('ORGID'||to_char(p_org_id));
      END IF;
    END IF;

  ELSIF p_ledger_id is NOT NULL THEN
    IF p_type = 'COUNTRY' THEN
      IF JG_ZZ_SHARED_PKG.p_country_tbl.exists('LEID'||to_char(p_ledger_id)) THEN
        return JG_ZZ_SHARED_PKG.p_country_tbl('LEID'||to_char(p_ledger_id));
      END IF;
    ELSIF p_type = 'PRODUCT' THEN
      IF JG_ZZ_SHARED_PKG.p_product_tbl.exists('LEID'||to_char(p_ledger_id)) THEN
        return JG_ZZ_SHARED_PKG.p_product_tbl('LEID'||to_char(p_ledger_id));
      END IF;
    ELSIF p_type = 'APPL' THEN
      IF JG_ZZ_SHARED_PKG.p_appl_tbl.exists('LEID'||to_char(p_ledger_id)) THEN
        return JG_ZZ_SHARED_PKG.p_appl_tbl('LEID'||to_char(p_ledger_id));
      END IF;
    END IF;

  ELSIF p_inv_org_id is NOT NULL THEN
    IF p_type = 'COUNTRY' THEN
      IF JG_ZZ_SHARED_PKG.p_country_tbl.exists('INVID'||to_char(p_inv_org_id)) THEN
        return JG_ZZ_SHARED_PKG.p_country_tbl('INVID'||to_char(p_inv_org_id));
      END IF;
    ELSIF p_type = 'PRODUCT' THEN
      IF JG_ZZ_SHARED_PKG.p_product_tbl.exists('INVID'||to_char(p_inv_org_id)) THEN
        return JG_ZZ_SHARED_PKG.p_product_tbl('INVID'||to_char(p_inv_org_id));
      END IF;
    ELSIF p_type = 'APPL' THEN
      IF JG_ZZ_SHARED_PKG.p_appl_tbl.exists('INVID'||to_char(p_inv_org_id)) THEN
        return JG_ZZ_SHARED_PKG.p_appl_tbl('INVID'||to_char(p_inv_org_id));
      END IF;
    END IF;

  ELSIF p_resp_id is NOT NULL THEN
    IF p_type = 'COUNTRY' THEN
      IF JG_ZZ_SHARED_PKG.p_country_tbl.exists('RESPID'||to_char(p_resp_id)) THEN
        return JG_ZZ_SHARED_PKG.p_country_tbl('RESPID'||to_char(p_resp_id));
      END IF;
    ELSIF p_type = 'PRODUCT' THEN
      IF JG_ZZ_SHARED_PKG.p_product_tbl.exists('RESPID'||to_char(p_resp_id)) THEN
        return JG_ZZ_SHARED_PKG.p_product_tbl('RESPID'||to_char(p_resp_id));
      END IF;
    ELSIF p_type = 'APPL' THEN
      IF JG_ZZ_SHARED_PKG.p_appl_tbl.exists('RESPID'||to_char(p_resp_id)) THEN
        return JG_ZZ_SHARED_PKG.p_appl_tbl('RESPID'||to_char(p_resp_id));
      END IF;
    END IF;

  END IF;
  return NULL;

END CHECK_CACHE;

PROCEDURE PUT_CACHE( p_org_id     IN NUMBER,
                     p_ledger_id  IN NUMBER,
                     p_inv_org_id IN NUMBER,
                     p_resp_id    IN NUMBER,
                     p_type       IN VARCHAR2,
                     p_value      IN VARCHAR2)
IS
BEGIN
  IF p_org_id is NOT NULL THEN
    IF p_type = 'COUNTRY' THEN
        JG_ZZ_SHARED_PKG.p_country_tbl('ORGID'||to_char(p_org_id)) := p_value;
    ELSIF p_type = 'PRODUCT' THEN
        JG_ZZ_SHARED_PKG.p_product_tbl('ORGID'||to_char(p_org_id)) := p_value;
    ELSIF p_type = 'APPL' THEN
        JG_ZZ_SHARED_PKG.p_appl_tbl('ORGID'||to_char(p_org_id)) := p_value;
    END IF;

  ELSIF p_ledger_id is NOT NULL THEN
    IF p_type = 'COUNTRY' THEN
        JG_ZZ_SHARED_PKG.p_country_tbl('LEID'||to_char(p_ledger_id)) := p_value;
    ELSIF p_type = 'PRODUCT' THEN
        JG_ZZ_SHARED_PKG.p_product_tbl('LEID'||to_char(p_ledger_id)) := p_value;
    ELSIF p_type = 'APPL' THEN
        JG_ZZ_SHARED_PKG.p_appl_tbl('LEID'||to_char(p_ledger_id)) := p_value;
    END IF;

  ELSIF p_inv_org_id is NOT NULL THEN
    IF p_type = 'COUNTRY' THEN
        JG_ZZ_SHARED_PKG.p_country_tbl('INVID'||to_char(p_inv_org_id)) := p_value;
    ELSIF p_type = 'PRODUCT' THEN
        JG_ZZ_SHARED_PKG.p_product_tbl('INVID'||to_char(p_inv_org_id)) := p_value;
    ELSIF p_type = 'APPL' THEN
        JG_ZZ_SHARED_PKG.p_appl_tbl('INVID'||to_char(p_inv_org_id)) := p_value;
    END IF;

  ELSIF p_resp_id is NOT NULL THEN
    IF p_type = 'COUNTRY' THEN
        JG_ZZ_SHARED_PKG.p_country_tbl('RESPID'||to_char(p_resp_id)) := p_value;
    ELSIF p_type = 'PRODUCT' THEN
        JG_ZZ_SHARED_PKG.p_product_tbl('RESPID'||to_char(p_resp_id)) := p_value;
    ELSIF p_type = 'APPL' THEN
        JG_ZZ_SHARED_PKG.p_appl_tbl('RESPID'||to_char(p_resp_id)) := p_value;
    END IF;
  END IF;

END PUT_CACHE;


FUNCTION GET_COUNTRY RETURN VARCHAR2 IS

l_country_code  varchar2(2);
l_result        VARCHAR2(10);
BEGIN

  l_result := CHECK_CACHE(NULL,NULL,NULL,FND_GLOBAL.RESP_ID,'COUNTRY') ;
  l_result := JG_ZZ_SHARED_PKG.IS_GLOBALIZATION_ENABLED(l_result);

  IF l_result is NOT NULL THEN
    return l_result;
  END IF;
  l_country_code := fnd_profile.value('JGZZ_COUNTRY_CODE');

  JG_ZZ_SHARED_PKG.PUT_CACHE( p_org_id => NULL,
                     p_ledger_id  => NULL,
                     p_inv_org_id => NULL,
                     p_resp_id    => FND_GLOBAL.RESP_ID,
                     p_type       => 'COUNTRY',
                     p_value      =>  l_country_code);
  l_country_code := JG_ZZ_SHARED_PKG.IS_GLOBALIZATION_ENABLED(l_country_code);

  return l_country_code;

END get_country;

FUNCTION GET_COUNTRY ( p_org_id     IN NUMBER,
                       p_ledger_id  IN NUMBER DEFAULT NULL,
                       p_inv_org_id IN NUMBER DEFAULT NULL)
RETURN VARCHAR2 IS

l_return_status      varchar2(100);
l_msg_count          number;
l_global_cnt         number;
l_msg_data           varchar2(2000);
l_country_code       varchar2(2);
l_country_tbl        xle_utilities_grp.countrycode_tbl_type;
-- l_org_id_from_inv    number(15); -- Bug 4963243
l_Inv_Le_info_rec    XLE_BUSINESSINFO_GRP.inv_org_Rec_Type;
l_result             VARCHAR2(100);
BEGIN

  l_result := NULL;
  l_result := CHECK_CACHE(p_org_id,p_ledger_id,p_inv_org_id,NULL,'COUNTRY');
  l_result := JG_ZZ_SHARED_PKG.IS_GLOBALIZATION_ENABLED(l_result);

  IF l_result is NOT NULL THEN
     return l_result;
  END IF;

  IF p_org_id IS NOT NULL Then
     xle_utilities_grp.get_fp_countrycode_ou (
                       p_api_version    => 1.0,
                       p_init_msg_list  => NULL,
                       p_commit         => NULL,
                       x_return_status  => l_return_status,
                       x_msg_count      => l_msg_count,
                       x_msg_data       => l_msg_data,
                       p_operating_unit => p_org_id,
                       x_country_code   => l_country_code);

   IF l_return_status <> FND_API.G_RET_STS_SUCCESS Then
      l_country_code := NULL;
   END IF;

  ELSIF p_ledger_id IS NOT NULL Then
     xle_utilities_grp.get_fp_countrycode_lid (
                       p_api_version          => 1.0,
                       p_init_msg_list        => NULL,
                       p_commit               => NULL,
                       x_return_status        => l_return_status,
                       x_msg_count            => l_msg_count,
                       x_msg_data             => l_msg_data,
                       p_ledger_id            => p_ledger_id,
                       x_register_country_tbl => l_country_tbl);

     IF l_return_status = FND_API.G_RET_STS_SUCCESS Then
        -- check if there is only one globalization country supported by Jx products
        -- and return it. If there is more than one globalization country, return NULL
        l_global_cnt := 0;
        FOR i IN l_country_tbl.first..l_country_tbl.last
        LOOP
           IF l_country_tbl(i).country_code IN ('CA', 'KR', 'SG', 'TH', 'TW',
                                                'AU', 'IN', 'CN', 'SK', 'UA',
                                                'BE', 'CH', 'CZ', 'DE', 'DK',
                                                'ES', 'EX', 'FI', 'FR', 'GR',
                                                'HU', 'IL', 'IT', 'NL', 'NO',
                                                'PL', 'PT', 'SE', 'TR', 'RU',
                                                'AR', 'BR', 'CL', 'CO', 'MX',
                                                'VE', 'PE', 'RO', 'JP', 'KZ') THEN
               l_global_cnt := l_global_cnt + 1;
               l_country_code := l_country_tbl(i).country_code;
           END IF;
        END LOOP;
        IF l_global_cnt > 1 THEN
           l_country_code := NULL;
        END IF;
     ELSE
        l_country_code := NULL;
     END IF;

  ELSIF p_inv_org_id IS NOT NULL Then

    -- The following fix is superseded by Bug fix 4963243 given
    -- at the end of this section

    /*
    -- Bug 4883010 (SCM), 4946442 (JG)
    -- obtain org_id from inventory org id
    -- then obtain country from org_id

    Begin
      SELECT
        DECODE(FPG.MULTI_ORG_FLAG, 'Y',
                DECODE(HOI2.ORG_INFORMATION_CONTEXT,
                       'Accounting Information',
                       TO_NUMBER(HOI2.ORG_INFORMATION3),
                       TO_NUMBER(NULL)
                      ),
              TO_NUMBER(NULL)
              )
      INTO l_org_id_from_inv
      FROM HR_ORGANIZATION_INFORMATION HOI1,
           HR_ORGANIZATION_INFORMATION HOI2,
           GL_SETS_OF_BOOKS GSOB,
           FND_PRODUCT_GROUPS FPG
      WHERE HOI1.ORGANIZATION_ID = HOI2.ORGANIZATION_ID
        AND HOI1.ORG_INFORMATION1 = 'INV'
        AND HOI1.ORG_INFORMATION2 = 'Y'
        AND ( HOI1.ORG_INFORMATION_CONTEXT || '') = 'CLASS'
        AND ( HOI2.ORG_INFORMATION_CONTEXT || '') ='Accounting Information'
        AND HOI2.ORG_INFORMATION1 = to_char(GSOB.set_of_books_id)
        AND HOI1.ORGANIZATION_ID = p_inv_org_id;
    Exception
      when others then
        l_org_id_from_inv := null;
    End;


    if l_org_id_from_inv is not null then
      xle_utilities_grp.get_fp_countrycode_ou (
                          p_api_version    => 1.0,
                          p_init_msg_list  => NULL,
                          p_commit         => NULL,
                          x_return_status  => l_return_status,
                          x_msg_count      => l_msg_count,
                          x_msg_data       => l_msg_data,
                          p_operating_unit => l_org_id_from_inv,
                          x_country_code   => l_country_code);
    end if;
    */

    -- Bug fix 4963243

    l_Inv_Le_info_rec.delete;
    XLE_BUSINESSINFO_GRP.Get_InvOrg_Info(
                                      x_return_status => l_return_status,
                                      x_msg_data      => l_msg_data,
                                      P_InvOrg_ID     => p_inv_org_id,
                                      P_Le_ID         => NULL,
                                      P_Party_ID      => NULL,
                                      x_Inv_Le_info   => l_Inv_Le_info_rec);

    IF l_return_status <> FND_API.G_RET_STS_SUCCESS Then
       l_country_code := NULL;
    ELSE
       l_country_code := l_Inv_Le_info_rec(l_Inv_Le_info_rec.FIRST).COUNTRY;
    END IF;

  END IF;
  JG_ZZ_SHARED_PKG.PUT_CACHE( p_org_id => p_org_id,
                     p_ledger_id  => p_ledger_id,
                     p_inv_org_id => p_inv_org_id,
                     p_resp_id    => NULL,
                     p_type       => 'COUNTRY',
                     p_value      =>  l_country_code);

  l_country_code := JG_ZZ_SHARED_PKG.IS_GLOBALIZATION_ENABLED(l_country_code);

  return l_country_code;

END get_country;

FUNCTION GET_PRODUCT RETURN VARCHAR2 IS

l_product_code varchar2(2);
l_result VARCHAR2(100);
 BEGIN

  l_result := CHECK_CACHE(NULL,NULL,NULL,FND_GLOBAL.RESP_ID,'PRODUCT') ;
  IF l_result is NOT NULL THEN
    return l_result;
  END IF;
  l_product_code := fnd_profile.value('JGZZ_PRODUCT_CODE');
  JG_ZZ_SHARED_PKG.PUT_CACHE( p_org_id => NULL,
                     p_ledger_id  => NULL,
                     p_inv_org_id => NULL,
                     p_resp_id    => FND_GLOBAL.RESP_ID,
                     p_type       => 'PRODUCT',
                     p_value      =>  l_product_code);
  return l_product_code;

END get_product;

FUNCTION GET_PRODUCT ( p_org_id     IN NUMBER,
                       p_ledger_id  IN NUMBER DEFAULT NULL,
                       p_inv_org_id IN NUMBER DEFAULT NULL)
RETURN VARCHAR2 IS

l_country_code varchar2(2);
l_product_code varchar2(2);
l_result VARCHAR2(100);
BEGIN

  l_result := NULL;
  l_result := CHECK_CACHE(p_org_id,p_ledger_id,p_inv_org_id,NULL,'PRODUCT');
    IF l_result is NOT NULL THEN
      return l_result;
    END IF;

  IF p_org_id IS NOT NULL Then
     l_country_code := get_country (p_org_id,
                                    p_ledger_id);

     IF l_country_code IS NOT NULL Then
        IF l_country_code IN ('CA', 'KR', 'SG', 'TH', 'TW', 'AU','JP', 'IN', 'CN') THEN
           l_product_code := 'JA';
        ELSIF l_country_code in ('BE', 'CH', 'CZ', 'DE', 'DK',
                                 'ES', 'EX', 'FI', 'FR', 'GR',
                                 'HU', 'IL', 'IT', 'NL', 'NO',
                                 'PL', 'PT', 'SE', 'TR', 'RU',
                                 'SK', 'UA', 'RO','KZ') THEN
           l_product_code := 'JE';
        ELSIF l_country_code in ('AR', 'BR', 'CL','VE','PE', 'CO', 'MX') THEN
           l_product_code := 'JL';
        END IF;
     END IF;
  END IF;

  JG_ZZ_SHARED_PKG.PUT_CACHE( p_org_id => p_org_id,
                     p_ledger_id  => p_ledger_id,
                     p_inv_org_id => p_inv_org_id,
                     p_resp_id    => NULL,
                     p_type       => 'PRODUCT',
                     p_value      =>  l_product_code);
  return l_product_code;

END get_product;

FUNCTION GET_APPLICATION
RETURN VARCHAR2 IS

l_application fnd_profile_option_values.profile_option_value%type;
l_result VARCHAR2(100);
BEGIN

  l_result := CHECK_CACHE(NULL,NULL,NULL,FND_GLOBAL.RESP_ID,'APPL') ;
  IF l_result is NOT NULL THEN
    return l_result;
  END IF;
  l_application := fnd_profile.value('JGZZ_APPL_SHORT_NAME');
  JG_ZZ_SHARED_PKG.PUT_CACHE( p_org_id => NULL,
                     p_ledger_id  => NULL,
                     p_inv_org_id => NULL,
                     p_resp_id    => FND_GLOBAL.RESP_ID,
                     p_type       => 'APPL',
                     p_value      =>  l_application);
  return l_application;

END get_application;

FUNCTION GET_APPLICATION ( p_curr_form_name IN VARCHAR2)
RETURN VARCHAR2 IS
  l_application varchar2(10);
  l_result VARCHAR2(100);
BEGIN

  if p_curr_form_name in ('APXCUMSP', 'APXIISIM', 'APXINWKB', 'APXPAWKB',
                          'APXPMTCH', 'APXSPDPF', 'APXSUDCC', 'APXSUMBA',
                          'APXTADTC', 'APXTCERT', 'APXTRDRE', 'APXVDMVD',
                          'APXXXEER') then
    l_application := 'SQLAP';
  elsif p_curr_form_name in ('ARXAIEXP', 'ARXCUDCI', 'ARXMACPC', 'ARXPRGLP',
                             'ARXRWMAI', 'ARXSTDML', 'ARXSUDRC', 'ARXSUMRT',
                             'ARXSURMT', 'ARXSUVAT', 'ARXSYSPA', 'ARXTWMAI',
                             'RAXSUCTT', 'RAXSUMSC', 'RCVRCERC', 'RCVRCVRC') then
    l_application := 'AR';
  elsif p_curr_form_name in ('CEXCABMR') then
    l_application := 'CE';
  elsif p_curr_form_name in ('FAXASSET', 'FAXDPRUN', 'FAXMADDS', 'FAXMAREV',
                             'FAXSUBCT', 'FAXSUCAT') then
    l_application := 'OFA';
  elsif p_curr_form_name in ('FNDNLDCX','FNDSNASQ') then
    l_application := 'FND';
  elsif p_curr_form_name in ('GLXJEENT', 'GLXSTBKS') then
    l_application := 'SQLGL';
  elsif p_curr_form_name in ('INVIDITM', 'INVIDTMP', 'INVIVATT', 'INVIVCSU',
                             'INVPTRPR', 'INVSDFCR', 'INVSDOIO') then
    l_application := 'INV';
  elsif p_curr_form_name in ('OEXOEMCG', 'OEXOEMOE', 'OEXOEORD', 'OEXOETEL',
                             'OEXOEVOR', 'OEXORRSO', 'CSCCCCRC') then
    l_application := 'ONT';
  elsif p_curr_form_name in ('PERWSLOC') then
    l_application := 'PER';
  elsif p_curr_form_name in ('POXBWVRP', 'POXDOPRE', 'POXPOEPO', 'POXPOERL',
                             'POXRQERQ', 'POXSCERQ', 'POXSTDPO') then
    l_application := 'PO';
  elsif p_curr_form_name in ('WSHFDDPW', 'WSHFSCDL', 'WSHFSTRX', 'WSHFXCSM') then
    l_application := 'WSH';
  elsif p_curr_form_name in ('ZXTAXDETFACTORS', 'ZXTRLLINEDISTUI', 'ZXTRXSIM') then
    l_application := 'ZX';
  else
    -- if the form is not part of the above list of
    -- globalized forms, access application from system profile.
    -- if the system profile is not defined, it returns null anyways.
  l_result := CHECK_CACHE(NULL,NULL,NULL,FND_GLOBAL.RESP_ID,'APPL') ;
  IF l_result is NOT NULL THEN
    return l_result;
  END IF;

  l_application := fnd_profile.value('JGZZ_APPL_SHORT_NAME');
  JG_ZZ_SHARED_PKG.PUT_CACHE( p_org_id => NULL,
                     p_ledger_id  => NULL,
                     p_inv_org_id => NULL,
                     p_resp_id    => FND_GLOBAL.RESP_ID,
                     p_type       => 'APPL',
                     p_value      =>  l_application);
  end if;

  RETURN l_application;

END get_application;

END JG_ZZ_SHARED_PKG;

/
