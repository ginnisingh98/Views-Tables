--------------------------------------------------------
--  DDL for Package Body ZX_SECURITY
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."ZX_SECURITY" AS
/* $Header: zxifdtaccsecpvtb.pls 120.33.12010000.2 2008/11/12 12:29:24 spasala ship $ */

G_CURRENT_RUNTIME_LEVEL CONSTANT NUMBER       := FND_LOG.G_CURRENT_RUNTIME_LEVEL;
G_LEVEL_UNEXPECTED      CONSTANT NUMBER       := FND_LOG.LEVEL_UNEXPECTED;
G_LEVEL_ERROR           CONSTANT NUMBER       := FND_LOG.LEVEL_ERROR;
G_LEVEL_EXCEPTION       CONSTANT NUMBER       := FND_LOG.LEVEL_EXCEPTION;
G_LEVEL_EVENT           CONSTANT NUMBER       := FND_LOG.LEVEL_EVENT;
G_LEVEL_PROCEDURE       CONSTANT NUMBER       := FND_LOG.LEVEL_PROCEDURE;
G_LEVEL_STATEMENT       CONSTANT NUMBER       := FND_LOG.LEVEL_STATEMENT;
G_MODULE_NAME           CONSTANT VARCHAR2(80) := 'ZX.PLSQL.ZX_SECURITY.';



FUNCTION get_effective_date RETURN DATE
IS
BEGIN
  return G_EFFECTIVE_DATE;
END get_effective_date;


--
-- Name
--   single_read_access
-- Purpose
--  Security policy function to control read access to rules and formula setup
--  data for a single first party organization
--
-- Arguments
--   D1    - Object Schema.
--   D2    - Object Name.
--



FUNCTION single_read_access  (D1 VARCHAR2, D2 VARCHAR2) RETURN VARCHAR2
IS
D_predicate VARCHAR2 (2000);

BEGIN

 D_predicate := '(content_owner_id,tax_regime_code)  IN
                      (select parent_first_pty_org_id, tax_regime_code
                       from ZX_SUBSCRIPTION_DETAILS
                       where view_options_code in (''NONE'',''VFC'',''VFR'')
                         and SYS_CONTEXT(''my_ctx'',''EFFECTIVEDATE'') between effective_from and
                         nvl(effective_to, SYS_CONTEXT(''my_ctx'',''EFFECTIVEDATE'')) and first_pty_org_id = nvl(SYS_CONTEXT(''my_ctx'',''FIRSTPTYORGID''),-999)) ';

  RETURN D_predicate;
END single_read_access;



--
-- Name
--   single_read_access_for_excp
-- Purpose
--  Security policy function to control read access to exception setup
--  data for a single first party organization
--
-- Arguments
--   D1    - Object Schema.
--   D2    - Object Name.
--

FUNCTION single_read_access_for_excp  (D1 VARCHAR2, D2 VARCHAR2) RETURN VARCHAR2
IS
D_predicate VARCHAR2 (2000);

BEGIN

  D_predicate := '(content_owner_id,tax_regime_code)  IN
                      (select decode(opt.exception_option_code, ''OWN_ONLY'', ru.first_pty_org_id, -99),
                            ru.tax_regime_code
                       from ZX_SUBSCRIPTION_OPTIONS opt,
                            ZX_REGIMES_USAGES ru
                       where  ru.regime_usage_id = opt.regime_usage_id
                         and SYS_CONTEXT(''my_ctx'',''EFFECTIVEDATE'') between opt.effective_from and
			 nvl(opt.effective_to, SYS_CONTEXT(''my_ctx'',''EFFECTIVEDATE'')) and ru.first_pty_org_id = nvl(SYS_CONTEXT(''my_ctx'',''FIRSTPTYORGID''),-999) )';

  RETURN D_predicate;
END single_read_access_for_excp;

--
-- Name
--   single_read_access_for_override
-- Purpose
--  Security policy function to control read access to tax setup data for a
--  single first party organization
--
-- Arguments
--   D1    - Object Schema.
--   D2    - Object Name.
--
FUNCTION single_read_access_for_ovrd (D1 VARCHAR2, D2 VARCHAR2) RETURN VARCHAR2
IS
D_predicate VARCHAR2 (2000);

BEGIN
 D_predicate :=  'sdco_id = SYS_CONTEXT(''my_ctx'',''FIRSTPTYORGID'') and SYS_CONTEXT(''my_ctx'',''EFFECTIVEDATE'') between sdeff_from and
                  nvl(sdeff_to,SYS_CONTEXT(''my_ctx'',''EFFECTIVEDATE''))' ;


  RETURN D_predicate;
END single_read_access_for_ovrd;

--
-- Name
--   multiple_read_access
-- Purpose
--  Security policy function to control read access to tax setup data for
--  multiple first party organizations
--
-- Arguments
--   D1    - Object Schema.
--   D2    - Object Name.
--

FUNCTION multiple_read_access  (D1 VARCHAR2, D2 VARCHAR2) RETURN VARCHAR2
IS
D_predicate VARCHAR2 (2000);
BEGIN


  IF fnd_profile.value ('ZX_GCO_WRITE_ACCESS') = 'Y' then
    D_predicate := '(content_owner_id, tax_regime_code) IN
                        (select det.parent_first_pty_org_id, det.tax_regime_code
                         from ZX_SUBSCRIPTION_DETAILS det,
                              ZX_FIRST_PARTY_ORGANIZATIONS_V ptp
                         where det.first_pty_org_id = ptp.party_tax_profile_id)
                     or content_owner_id = -99';
   ELSE
     D_predicate := '(content_owner_id, tax_regime_code) IN
                        (select det.parent_first_pty_org_id, det.tax_regime_code
                         from ZX_SUBSCRIPTION_DETAILS det,
                              ZX_FIRST_PARTY_ORGANIZATIONS_V ptp
                         where det.first_pty_org_id = ptp.party_tax_profile_id)';
  END IF;
  RETURN D_predicate;
END multiple_read_access;

--
-- Name
--   multiple_read_access_for_excp
-- Purpose
--  Security policy function to control read access to exception setup data for
--  multiple first party organizations
--
-- Arguments
--   D1    - Object Schema.
--   D2    - Object Name.
--

FUNCTION multiple_read_access_for_excp  (D1 VARCHAR2, D2 VARCHAR2) RETURN VARCHAR2
IS
D_predicate VARCHAR2 (2000);
BEGIN


  IF fnd_profile.value ('ZX_GCO_WRITE_ACCESS') = 'Y' then
    D_predicate := '(content_owner_id, tax_regime_code) IN
                        (select decode(opt.exception_option_code, ''OWN_ONLY'', ru.first_pty_org_id, -99), ru.tax_regime_code
                         from ZX_SUBSCRIPTION_OPTIONS opt,
                              ZX_REGIMES_USAGES ru,
                              ZX_FIRST_PARTY_ORGANIZATIONS_V ptp
                         where ru.first_pty_org_id = ptp.party_tax_profile_id
                           and ru.regime_usage_id  = opt.regime_usage_id)
                     or content_owner_id = -99';
   ELSE
     D_predicate := '(content_owner_id, tax_regime_code) IN
                        (select decode(opt.exception_option_code, ''OWN_ONLY'', ru.first_pty_org_id, -99), ru.tax_regime_code
                         from ZX_SUBSCRIPTION_OPTIONS opt,
                              ZX_REGIMES_USAGES ru,
                              ZX_FIRST_PARTY_ORGANIZATIONS_V ptp
                         where ru.first_pty_org_id = ptp.party_tax_profile_id
                           and ru.regime_usage_id  = opt.regime_usage_id)';
  END IF;
  RETURN D_predicate;
END multiple_read_access_for_excp;

--
-- Name
--   write_access
-- Purpose
--  Security policy function to control write access to tax setup data
--
-- Arguments
--   D1    - Object Schema.
--   D2    - Object Name.
--

FUNCTION write_access (D1 VARCHAR2, D2 VARCHAR2)  RETURN  VARCHAR2
IS
D_predicate VARCHAR2 (2000);
BEGIN
  IF fnd_profile.value('ZX_GCO_WRITE_ACCESS') = 'Y' then
    D_predicate := '(content_owner_id, tax_regime_code) IN
                        (select parent_first_pty_org_id, tax_regime_code
                         from ZX_SUBSCRIPTION_DETAILS det,
                              ZX_FIRST_PARTY_ORGANIZATIONS_V ptp
                         where det.first_pty_org_id = ptp.party_tax_profile_id
                           and det.view_options_code = ''VFC'')
                    or content_owner_id = -99';
   ELSE
     D_predicate := '(content_owner_id, tax_regime_code) IN
                        (select parent_first_pty_org_id, tax_regime_code
                         from ZX_SUBSCRIPTION_DETAILS det,
                              ZX_FIRST_PARTY_ORGANIZATIONS_V ptp
                         where det.first_pty_org_id = ptp.party_tax_profile_id
                           and det.view_options_code = ''VFC'')';
   END IF;
  RETURN D_predicate;
END write_access;


--
-- Name
--   write_access_for_excp
-- Purpose
--  Security policy function to control write access to exception setup data
--
-- Arguments
--   D1    - Object Schema.
--   D2    - Object Name.
--

FUNCTION write_access_for_excp (D1 VARCHAR2, D2 VARCHAR2)  RETURN  VARCHAR2
IS
D_predicate VARCHAR2 (2000);
BEGIN
  IF fnd_profile.value('ZX_GCO_WRITE_ACCESS') = 'Y' then
    D_predicate := '(content_owner_id, tax_regime_code) IN
                        (select ru.first_pty_org_id, ru.tax_regime_code
                         from ZX_SUBSCRIPTION_OPTIONS opt,
                              ZX_REGIMES_USAGES ru,
                              ZX_FIRST_PARTY_ORGANIZATIONS_V ptp
                         where ru.first_pty_org_id = ptp.party_tax_profile_id
                           and ru.regime_usage_id  = opt.regime_usage_id
                           and opt.exception_option_code = ''OWN_ONLY'')
                    or content_owner_id = -99';
   ELSE
     D_predicate := '(content_owner_id, tax_regime_code) IN
                        (select ru.first_pty_org_id, ru.tax_regime_code
                         from ZX_SUBSCRIPTION_OPTIONS opt,
                              ZX_REGIMES_USAGES ru,
                              ZX_FIRST_PARTY_ORGANIZATIONS_V ptp
                         where ru.first_pty_org_id = ptp.party_tax_profile_id
                           and ru.regime_usage_id  = opt.regime_usage_id
                           and and opt.exception_option_code = ''OWN_ONLY'')';
   END IF;
  RETURN D_predicate;
END write_access_for_excp;

--
-- Name
--   first_party_org_access
-- Purpose
--  Security policy function to control data in zx_exemptions_v
--
-- Arguments
--   D1    - Object Schema.
--   D2    - Object Name.
--
FUNCTION first_party_org_access (D1 VARCHAR2, D2 VARCHAR2)
RETURN  VARCHAR2
IS
D_predicate VARCHAR2 (2000);
BEGIN
  IF ZX_SECURITY.G_FIRST_PARTY_ORG_ID is not null THEN
     D_predicate := ' content_owner_id = SYS_CONTEXT(''my_ctx'',''FIRSTPTYORGID'')';
  ELSE
     D_predicate := null;
  END IF;
  RETURN D_predicate;
END first_party_org_access;


PROCEDURE check_write_access (p_first_party_org_id IN NUMBER,
                              p_tax_regime_code    IN VARCHAR2,
                              x_return_status     OUT NOCOPY VARCHAR2)
IS
  l_count NUMBER :=0;
BEGIN
  IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
    FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||'SET_SECURITY_CONTEXT.BEGIN','ZX_SECURITY: CHECK_WRITE_ACCESS()+');
  END IF;

  x_return_status := FND_API.G_RET_STS_SUCCESS;
  IF fnd_profile.value('ZX_GCO_WRITE_ACCESS') = 'Y' then
    IF p_first_party_org_id <> -99 then
       select 1
	   into l_count
       from ZX_SUBSCRIPTION_DETAILS det
       where det.first_pty_org_id = p_first_party_org_id
    	 and det.tax_regime_code = p_tax_regime_code
         and det.view_options_code = 'VFC';
    END IF;
  ELSE
       select 1
	   into l_count
       from ZX_SUBSCRIPTION_DETAILS det
       where det.first_pty_org_id = p_first_party_org_id
         and det.tax_regime_code = p_tax_regime_code
         and det.view_options_code = 'VFC';
  END IF;

  IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
    FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||'SET_SECURITY_CONTEXT.END','ZX_SECURITY: CHECK_WRITE_ACCESS()-');
  END IF;

  EXCEPTION
    WHEN NO_DATA_FOUND THEN
      x_return_status := FND_API.G_RET_STS_ERROR;
      FND_MESSAGE.Set_Name ('ZX','GENERIC_MESSAGE');
      FND_MESSAGE.Set_Token('GENERIC_TEXT', SQLERRM);

      IF ( G_LEVEL_UNEXPECTED >= G_CURRENT_RUNTIME_LEVEL) THEN
        FND_LOG.STRING(G_LEVEL_UNEXPECTED,G_MODULE_NAME||'SET_SECURITY_CONTEXT', SQLERRM);
      END IF;

    WHEN OTHERS THEN
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      IF ( G_LEVEL_UNEXPECTED >= G_CURRENT_RUNTIME_LEVEL) THEN
        FND_LOG.STRING(G_LEVEL_UNEXPECTED,G_MODULE_NAME||'SET_SECURITY_CONTEXT', SQLERRM);
      END IF;

END check_write_access;

--
-- Name
--   single_regime_access
-- Purpose
--  Security policy function to control read access to Regime Usages data
--
-- Arguments
--   D1    - Object Schema.
--   D2    - Object Name.
--

FUNCTION single_regime_access (D1 VARCHAR2, D2 VARCHAR2)  RETURN  VARCHAR2
IS
D_predicate VARCHAR2 (2000);
BEGIN
  D_predicate := '(tax_regime_code) IN
                        (select tax_regime_code
                         from ZX_SUBSCRIPTION_DETAILS det
                         where det.first_pty_org_id = nvl(SYS_CONTEXT(''my_ctx'',''FIRSTPTYORGID'') ,-999) )';
  RETURN D_predicate;
END single_regime_access;

--
-- Name
--   add_icx_session_id
-- Purpose
--  Security policy function to control read access to Regime Usages data
--
-- Arguments
--   D1    - Object Schema.
--   D2    - Object Name.
--

FUNCTION add_icx_session_id (D1 VARCHAR2, D2 VARCHAR2)  RETURN  VARCHAR2
IS
D_predicate VARCHAR2 (2000);
BEGIN
  IF ZX_SECURITY.G_ICX_SESSION_ID is not null THEN
    --dbms_session.set_context('my_ctx','SESSIONID',to_char(ZX_SECURITY.G_ICX_SESSION_ID));
    D_predicate := 'icx_session_id = SYS_CONTEXT(''my_ctx'',''SESSIONID'') ';
  ELSE
     D_predicate := null;
  END IF;
  RETURN D_predicate;
END add_icx_session_id;

--
-- Name
--   set_security_context
-- Purpose
--  Sets the global variables G_FIRST_PARTY_ORG_ID and G_EFFECTIVE_DATE
--

PROCEDURE set_security_context(p_legal_entity_id IN NUMBER,
                               p_internal_org_id IN NUMBER,
                               p_effective_date  IN DATE,
                               x_return_status  OUT NOCOPY VARCHAR2)
IS

l_return_status 	VARCHAR2(30);
l_effective_date  	DATE;
l_first_party_org_id 	NUMBER;

BEGIN

  IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
    FND_LOG.STRING(G_LEVEL_STATEMENT,
                   G_MODULE_NAME||'SET_SECURITY_CONTEXT.BEGIN',
                   'ZX_SECURITY: SET_SECURITY_CONTEXT()+' ||
                   ', OU: '||to_char(p_internal_org_id)||' and LE: '||to_char(p_legal_entity_id));
  END IF;

  x_return_status := FND_API.G_RET_STS_SUCCESS;

  L_EFFECTIVE_DATE := nvl(p_effective_date,sysdate);

  ZX_TCM_PTP_PKG.GET_TAX_SUBSCRIBER(p_legal_entity_id,
                                    p_internal_org_id,
                                    L_FIRST_PARTY_ORG_ID,
                                    l_return_status);


    -- dbms_session.set_context('my_ctx','FIRSTPTYORGID',to_char(G_FIRST_PARTY_ORG_ID));
    -- dbms_session.set_context('my_ctx','EFFECTIVEDATE',to_char(G_EFFECTIVE_DATE));
    IF L_FIRST_PARTY_ORG_ID = G_FIRST_PARTY_ORG_ID THEN
          NULL;
    ELSE
      name_value('FIRSTPTYORGID',to_char(L_FIRST_PARTY_ORG_ID));
      G_FIRST_PARTY_ORG_ID := L_FIRST_PARTY_ORG_ID;
    END IF;

    IF L_EFFECTIVE_DATE = G_EFFECTIVE_DATE THEN
         NULL;
    ELSE
     name_value('EFFECTIVEDATE',to_char(L_EFFECTIVE_DATE));
     G_EFFECTIVE_DATE := L_EFFECTIVE_DATE;
    END IF;

  IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
    x_return_status := FND_API.G_RET_STS_ERROR;

    IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
      FND_LOG.STRING(G_LEVEL_STATEMENT,
                     G_MODULE_NAME||'SET_SECURITY_CONTEXT',
                     'Incorrect return status after calling ZX_TCM_PTP_PKG.GET_TAX_SUBSCRIBER'||
                     ', l_return_status: '||l_return_status);
    END IF;

    Return;
  END IF;

  IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
    FND_LOG.STRING(G_LEVEL_STATEMENT,
                   G_MODULE_NAME||'SET_SECURITY_CONTEXT.END',
                   'ZX_SECURITY: SET_SECURITY_CONTEXT()-'||
                   ', G_EFFECTIVE_DATE: '||to_char(G_EFFECTIVE_DATE) ||
                   ', G_FIRST_PARTY_ORG_ID: '||to_char(G_FIRST_PARTY_ORG_ID));
  END IF;

END set_security_context;

PROCEDURE set_security_context_ui(p_legal_entity_id IN NUMBER,
                               p_internal_org_id IN NUMBER,
                               p_effective_date  IN DATE,
                               x_return_status  OUT NOCOPY VARCHAR2)
IS

l_return_status 	VARCHAR2(30);
l_effective_date  	DATE;
l_first_party_org_id 	NUMBER;

BEGIN

  IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
    FND_LOG.STRING(G_LEVEL_STATEMENT,
                   G_MODULE_NAME||'SET_SECURITY_CONTEXT.BEGIN',
                   'ZX_SECURITY: SET_SECURITY_CONTEXT()+' ||
                   ', OU: '||to_char(p_internal_org_id)||' and LE: '||to_char(p_legal_entity_id));
  END IF;

  x_return_status := FND_API.G_RET_STS_SUCCESS;

  L_EFFECTIVE_DATE := nvl(p_effective_date,sysdate);

  ZX_TCM_PTP_PKG.GET_TAX_SUBSCRIBER(p_legal_entity_id,
                                    p_internal_org_id,
                                    L_FIRST_PARTY_ORG_ID,
                                    l_return_status);


    -- dbms_session.set_context('my_ctx','FIRSTPTYORGID',to_char(G_FIRST_PARTY_ORG_ID));
    -- dbms_session.set_context('my_ctx','EFFECTIVEDATE',to_char(G_EFFECTIVE_DATE));

    IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
      FND_LOG.STRING(G_LEVEL_STATEMENT,
                   G_MODULE_NAME||'SET_SECURITY_CONTEXT.END',
                   'ZX_SECURITY: SET_SECURITY_CONTEXT()-' ||
                   ', G_EFFECTIVE_DATE: '||nvl(SYS_CONTEXT('my_ctx','EFFECTIVEDATE'),sysdate) ||
                   ', G_FIRST_PARTY_ORG_ID:
'||to_char(nvl(SYS_CONTEXT('my_ctx','FIRSTPTYORGID'),-999)) );
    END IF;

    IF L_FIRST_PARTY_ORG_ID = nvl(SYS_CONTEXT('my_ctx','FIRSTPTYORGID'),-999) THEN
          NULL;
    ELSE
      name_value('FIRSTPTYORGID',to_char(L_FIRST_PARTY_ORG_ID));
      G_FIRST_PARTY_ORG_ID := L_FIRST_PARTY_ORG_ID;
    END IF;

    IF L_EFFECTIVE_DATE =
nvl(SYS_CONTEXT('my_ctx','EFFECTIVEDATE'),sysdate - 365) THEN
         NULL;
    ELSE
     name_value('EFFECTIVEDATE',to_char(L_EFFECTIVE_DATE));
     G_EFFECTIVE_DATE := L_EFFECTIVE_DATE;
    END IF;

  IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
    x_return_status := FND_API.G_RET_STS_ERROR;

    IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
      FND_LOG.STRING(G_LEVEL_STATEMENT,
                     G_MODULE_NAME||'SET_SECURITY_CONTEXT',
                     'Incorrect return status after calling ZX_TCM_PTP_PKG.GET_TAX_SUBSCRIBER'||
                     ', l_return_status: '||l_return_status);
    END IF;

    Return;
  END IF;

  IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
    FND_LOG.STRING(G_LEVEL_STATEMENT,
                   G_MODULE_NAME||'SET_SECURITY_CONTEXT.END',
                   'ZX_SECURITY: SET_SECURITY_CONTEXT()-'||
                   ', G_EFFECTIVE_DATE: '||to_char(G_EFFECTIVE_DATE) ||
                   ', G_FIRST_PARTY_ORG_ID: '||to_char(G_FIRST_PARTY_ORG_ID));
  END IF;

END set_security_context_ui;
--  Overloaded set_security_context

PROCEDURE set_security_context(p_first_party_org_id IN NUMBER,
                               p_effective_date     IN DATE,
                               x_return_status     OUT NOCOPY VARCHAR2)
IS

l_return_status VARCHAR2(30);
l_effective_date  	DATE;
l_first_party_org_id 	NUMBER;

BEGIN

  IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
    FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||'SET_SECURITY_CONTEXT.BEGIN','ZX_SECURITY: SET_SECURITY_CONTEXT()+');
  END IF;

  x_return_status := FND_API.G_RET_STS_SUCCESS;

  L_EFFECTIVE_DATE := nvl(p_effective_date,sysdate);

  L_FIRST_PARTY_ORG_ID := p_first_party_org_id;

    -- dbms_session.set_context('my_ctx','FIRSTPTYORGID',to_char(G_FIRST_PARTY_ORG_ID));
    -- dbms_session.set_context('my_ctx','EFFECTIVEDATE',to_char(G_EFFECTIVE_DATE));

    IF L_FIRST_PARTY_ORG_ID = G_FIRST_PARTY_ORG_ID THEN
       NULL;
    ELSE
       name_value('FIRSTPTYORGID',to_char(L_FIRST_PARTY_ORG_ID));
       G_FIRST_PARTY_ORG_ID := L_FIRST_PARTY_ORG_ID;
    END IF;

    IF L_EFFECTIVE_DATE = G_EFFECTIVE_DATE THEN
       NULL;
    ELSE
       name_value('EFFECTIVEDATE',to_char(L_EFFECTIVE_DATE));
       G_EFFECTIVE_DATE := L_EFFECTIVE_DATE;
    END IF;

  IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
    FND_LOG.STRING(G_LEVEL_STATEMENT,
                   G_MODULE_NAME||'SET_SECURITY_CONTEXT.END',
                   'ZX_SECURITY: SET_SECURITY_CONTEXT()-' ||
                   ', G_EFFECTIVE_DATE: '||to_char(G_EFFECTIVE_DATE) ||
                   ', G_FIRST_PARTY_ORG_ID: '||to_char(G_FIRST_PARTY_ORG_ID) );
  END IF;

END set_security_context;

PROCEDURE name_value(name varchar2, value varchar2) as

BEGIN

  dbms_session.set_context('my_ctx',name,value);

END;

END zx_security;

/
