--------------------------------------------------------
--  DDL for Package Body ZX_PARTY_MERGE_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."ZX_PARTY_MERGE_PKG" AS
/* $Header: zxcptpmb.pls 120.5.12010000.9 2009/12/10 12:17:23 srajapar ship $ */

  g_user_id     constant  number(15)   := FND_GLOBAL.user_id;
  g_login_id    constant  number(15)   := FND_GLOBAL.login_id;

  -- Logging Infra
  G_PKG_NAME              CONSTANT VARCHAR2(30) := 'ZX_PARTY_MERGE_PKG';
  G_CURRENT_RUNTIME_LEVEL          NUMBER;
  G_LEVEL_UNEXPECTED      CONSTANT NUMBER       := FND_LOG.LEVEL_UNEXPECTED;
  G_LEVEL_ERROR           CONSTANT NUMBER       := FND_LOG.LEVEL_ERROR;
  G_LEVEL_EXCEPTION       CONSTANT NUMBER       := FND_LOG.LEVEL_EXCEPTION;
  G_LEVEL_EVENT           CONSTANT NUMBER       := FND_LOG.LEVEL_EVENT;
  G_LEVEL_PROCEDURE       CONSTANT NUMBER       := FND_LOG.LEVEL_PROCEDURE;
  G_LEVEL_STATEMENT       CONSTANT NUMBER       := FND_LOG.LEVEL_STATEMENT;
  G_MODULE_NAME           CONSTANT VARCHAR2(30) := 'ZX.PLSQL.ZX_PARTY_MERGE_PKG';


PROCEDURE ZX_CUST_REG_MERGE_PVT (
  p_entity_name        in  hz_merge_dictionary.entity_name%type,
  p_from_id            in  oks_billing_profiles_b.id%type,
  x_to_id              in out nocopy oks_billing_profiles_b.id%type,
  p_from_fk_id         in  hz_merge_parties.from_party_id%type,
  p_to_fk_id           in  hz_merge_parties.to_party_id%type,
  p_parent_entity_name in  hz_merge_dictionary.parent_entity_name%type,
  p_batch_id           in  hz_merge_batch.batch_id%type,
  p_batch_party_id     in  hz_merge_party_details.batch_party_id%type,
  x_return_status     out  nocopy varchar2)
    IS
  -- Enter the procedure variables here. As shown below
  l_count                  NUMBER(10)       := 0;
  --l_from_start_date        DATE;
  --l_from_end_date          DATE;
  --l_to_start_date          DATE;
  --l_to_end_date            DATE;
  --l_registration_from      VARCHAR2(50);
  --l_registration_to        VARCHAR2(50);
  --l_registration_id_from   NUMBER;
  --l_registration_id_to     NUMBER;
  --l_update_reg_from_date   DATE;
  --l_update_reg_to_date     DATE;
  --l_location_id_from       NUMBER;
  --l_location_id_to         NUMBER;
  --l_reg_src_code_from      VARCHAR2(30);
  --l_reg_src_code_to        VARCHAR2(30);
  --l_reg_reason_code_from   VARCHAR2(30);
  --l_reg_reason_code_to     VARCHAR2(30);
  --l_rep_tax_auth_id_from   NUMBER;
  --l_rep_tax_auth_id_to     NUMBER;
  --l_coll_tax_auth_id_from  NUMBER;
  --l_coll_tax_auth_id_to    NUMBER;


  --cursor registration_number(p_fk_id  hz_merge_parties.from_party_id%type) IS
    --select registration_id, registration_number, effective_from, effective_to,
           --LEGAL_LOCATION_ID, REGISTRATION_SOURCE_CODE, REGISTRATION_REASON_CODE,
           --REP_TAX_AUTHORITY_ID, COLL_TAX_AUTHORITY_ID
    --from   zx_registrations reg, zx_party_tax_profile prof
    --where  reg.PARTY_TAX_PROFILE_ID = prof.PARTY_TAX_PROFILE_ID
    --and    prof.party_id = p_fk_id;
    --from_registration_rec registration_number%ROWTYPE;
    --to_registration_rec registration_number%ROWTYPE;0

    cursor registration_number
     (p_from_party_id  hz_merge_parties.from_party_id%type
     ,p_to_party_id    hz_merge_parties.to_party_id%type)
    IS
    select from_reg.registration_id registration_id_from,
          to_reg.registration_id registration_id_to,
          CASE WHEN from_reg.effective_from > to_reg.effective_from
                    THEN to_reg.effective_from
                    ELSE from_reg.effective_from
               END as update_reg_from_date,
          CASE WHEN from_reg.effective_to IS NULL OR to_reg.effective_to IS NULL
                    THEN NULL
               WHEN from_reg.effective_to > to_reg.effective_to
                    THEN from_reg.effective_to
                    ELSE to_reg.effective_to
               END as update_reg_to_date,
          CASE WHEN to_reg.LEGAL_LOCATION_ID IS NULL AND from_reg.LEGAL_LOCATION_ID IS NOT NULL
                    THEN from_reg.LEGAL_LOCATION_ID
               END as location_id_to,
          CASE WHEN to_reg.REGISTRATION_SOURCE_CODE IS NULL AND from_reg.REGISTRATION_SOURCE_CODE IS NOT NULL
                    THEN from_reg.REGISTRATION_SOURCE_CODE
               END as reg_src_code_to,
          CASE WHEN to_reg.REGISTRATION_REASON_CODE IS NULL AND from_reg.REGISTRATION_REASON_CODE IS NOT NULL
                    THEN from_reg.REGISTRATION_REASON_CODE
               END as reg_reason_code_to,
          CASE WHEN to_reg.REP_TAX_AUTHORITY_ID IS NULL AND from_reg.REP_TAX_AUTHORITY_ID IS NOT NULL
                    THEN from_reg.REP_TAX_AUTHORITY_ID
               END as rep_tax_auth_id_to,
          CASE WHEN to_reg.COLL_TAX_AUTHORITY_ID IS NULL AND from_reg.COLL_TAX_AUTHORITY_ID IS NOT NULL
                    THEN from_reg.COLL_TAX_AUTHORITY_ID
               END as coll_tax_auth_id_to
   from   zx_registrations from_reg,
          zx_registrations to_reg
    where  from_reg.PARTY_TAX_PROFILE_ID IN
            (SELECT party_tax_profile_id
               FROM zx_party_tax_profile
              WHERE party_id = p_from_party_id
            )
    and    to_reg.PARTY_TAX_PROFILE_ID IN
            (SELECT party_tax_profile_id
               FROM zx_party_tax_profile
              WHERE party_id = p_to_party_id
            )
    and    from_reg.registration_number = to_reg.registration_number
    and    from_reg.registration_id <> to_reg.registration_id;

  registration_rec registration_number%ROWTYPE;

  -- Logging Infra
  l_procedure_name CONSTANT VARCHAR2(30) := '.ZX_CUST_REG_MERGE_PVT ';
  l_log_msg                 FND_LOG_MESSAGES.MESSAGE_TEXT%TYPE;

BEGIN

  -- Logging Infra: Setting up runtime level
  G_CURRENT_RUNTIME_LEVEL := FND_LOG.G_CURRENT_RUNTIME_LEVEL;

  IF (G_LEVEL_PROCEDURE >= G_CURRENT_RUNTIME_LEVEL ) THEN
    l_log_msg := l_procedure_name||' (+) ';
    FND_LOG.STRING(G_LEVEL_PROCEDURE, G_MODULE_NAME||l_procedure_name, l_log_msg);
  END IF;

  x_return_status :=  FND_API.G_RET_STS_SUCCESS;

  --If it is a Site Merge, nothing to be done. Return the x_to_id.

  if p_from_fk_id = p_to_fk_id then
     x_to_id := p_from_id;
     return;
  end if;

  if p_from_fk_id <> p_to_fk_id then
    BEGIN

      arp_message.set_line('Updating zx_party_tax_profile...');

      FOR registration_rec IN registration_number(p_from_fk_id,p_to_fk_id)
      LOOP
         UPDATE zx_registrations
         SET merged_to_registration_id   = registration_rec.registration_id_to,
             effective_to       = sysdate,
             last_update_date   = sysdate,
             last_updated_by    = g_user_id,
             last_update_login  = g_login_id,
             object_version_number = object_version_number+1
         WHERE registration_id = registration_rec.registration_id_from;

         UPDATE zx_registrations
         SET effective_from             = registration_rec.update_reg_from_date,
             effective_to               = registration_rec.update_reg_to_date,
             LEGAL_LOCATION_ID          = registration_rec.location_id_to,
             REGISTRATION_SOURCE_CODE   = registration_rec.reg_src_code_to,
             REGISTRATION_REASON_CODE   = registration_rec.reg_reason_code_to,
             REP_TAX_AUTHORITY_ID       = registration_rec.rep_tax_auth_id_to,
             COLL_TAX_AUTHORITY_ID      = registration_rec.coll_tax_auth_id_to,
             last_update_date           = sysdate,
             last_updated_by            = g_user_id,
             last_update_login          = g_login_id,
             object_version_number       = object_version_number+1
         WHERE registration_id         = registration_rec.registration_id_to;

         l_count := l_count + sql%rowcount;

      END LOOP;

        arp_message.set_name('AR','AR_ROWS_UPDATED');
        arp_message.set_token('NUM_ROWS',to_char(l_count));

    EXCEPTION
      WHEN NO_DATA_FOUND THEN
        NULL;
      WHEN OTHERS THEN
        FND_MESSAGE.SET_NAME('AR', 'HZ_MERGE_SQL_ERROR');
        FND_MESSAGE.SET_TOKEN('ERROR' ,SQLERRM);
        FND_MSG_PUB.ADD;
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    END;
  end if; -- p_from_fk_id <> p_to_fk_id

   IF (G_LEVEL_PROCEDURE >= G_CURRENT_RUNTIME_LEVEL ) THEN
     l_log_msg := l_procedure_name||' (-) ';
     FND_LOG.STRING(G_LEVEL_PROCEDURE, G_MODULE_NAME||l_procedure_name, l_log_msg);
   END IF;

 end ZX_CUST_REG_MERGE_PVT;



  PROCEDURE ZX_PTP_MERGE_PVT (
  p_entity_name        in  hz_merge_dictionary.entity_name%type,
  p_from_id            in  oks_billing_profiles_b.id%type,
  x_to_id          in out  nocopy oks_billing_profiles_b.id%type,
  p_from_fk_id         in  hz_merge_parties.from_party_id%type,
  p_to_fk_id           in  hz_merge_parties.to_party_id%type,
  p_parent_entity_name in  hz_merge_dictionary.parent_entity_name%type,
  p_batch_id           in  hz_merge_batch.batch_id%type,
  p_batch_party_id     in  hz_merge_party_details.batch_party_id%type,
  x_return_status     out  nocopy varchar2)
    IS
      -- Enter the procedure variables here. As shown below
  l_count           number(10)   := 0;
  l_ptp_id_from     NUMBER;
  l_ptp_id_to       NUMBER;
  l_code_assignment_id  hz_code_assignments.owner_table_name%TYPE;

  cursor Party_Tax_Profile(p_fk_id  hz_merge_parties.from_party_id%type) IS
    select Party_Tax_Profile_id
    from   zx_party_tax_profile prof
    where  prof.party_id = p_fk_id
      and  prof.party_type_code = 'THIRD_PARTY';

    from_ptp_rec Party_Tax_Profile%ROWTYPE;
    to_ptp_rec   Party_Tax_Profile%ROWTYPE;

  cursor Class_Categories_From(p_ptp_id  number) IS
    select  code_assignment_id, class_category, class_code, END_DATE_ACTIVE
    from    hz_code_assignments
    where   owner_table_name = 'ZX_PARTY_TAX_PROFILE'
    and     owner_table_id = p_ptp_id
    and     NVL(END_DATE_ACTIVE,SYSDATE) >= sysdate;

  cursor Class_Codes_To(p_ptp_id number,
                        p_class_category  hz_code_assignments.class_category%type,
                        p_end_date   hz_code_assignments.end_date_active%type,
                        p_class_code hz_code_assignments.class_code%type) IS
    select  distinct class_category, class_code, END_DATE_ACTIVE
    from    hz_code_assignments
    where   owner_table_name = 'ZX_PARTY_TAX_PROFILE'
    and     owner_table_id = p_ptp_id
    and     NVL(END_DATE_ACTIVE,SYSDATE) >= NVL(p_end_date,SYSDATE)
    and     class_category = p_class_category
    and     class_code = p_class_code
    group by class_category, class_code, END_DATE_ACTIVE;

    Class_Codes_To_Rec Class_Codes_To%ROWTYPE;

    -- Logging Infra
  l_procedure_name CONSTANT VARCHAR2(30) := '.ZX_PTP_MERGE_PVT ';
  l_log_msg                 FND_LOG_MESSAGES.MESSAGE_TEXT%TYPE;

BEGIN

-- Logging Infra: Setting up runtime level
  G_CURRENT_RUNTIME_LEVEL := FND_LOG.G_CURRENT_RUNTIME_LEVEL;

  IF (G_LEVEL_PROCEDURE >= G_CURRENT_RUNTIME_LEVEL ) THEN
      l_log_msg := l_procedure_name||' (+) ';
      FND_LOG.STRING(G_LEVEL_PROCEDURE, G_MODULE_NAME||l_procedure_name, l_log_msg);
  END IF;

  x_return_status :=  FND_API.G_RET_STS_SUCCESS;

  --If it is a Site Merge, nothing to be done. Return the x_to_id.

  if p_from_fk_id = p_to_fk_id then
    x_to_id := p_from_id;
    return;
  end if;

  if p_from_fk_id <> p_to_fk_id then

    BEGIN
      arp_message.set_line('Updating zx_party_tax_profile...');

      OPEN Party_Tax_Profile(p_from_fk_id);
      FETCH Party_Tax_Profile INTO from_ptp_rec;
      IF Party_Tax_Profile%FOUND THEN
        l_ptp_id_from  := from_ptp_rec.Party_Tax_Profile_id;
      END IF;
      CLOSE Party_Tax_Profile;

      OPEN Party_Tax_Profile(p_to_fk_id);
      FETCH Party_Tax_Profile INTO to_ptp_rec;
      IF Party_Tax_Profile%FOUND THEN
        l_ptp_id_to  := to_ptp_rec.Party_Tax_Profile_id;
      END IF;
      CLOSE Party_Tax_Profile;

      update zx_party_tax_profile
        set merged_to_ptp_id   = l_ptp_id_to,
            merged_status_code = 'MERGED',
            last_update_date   = sysdate,
            last_updated_by    = g_user_id,
            last_update_login  = g_login_id,
            object_version_number = object_version_number+1
      where Party_Tax_Profile_id = l_ptp_id_from;

      l_count := sql%rowcount;
      arp_message.set_name('AR','AR_ROWS_UPDATED');
      arp_message.set_token('NUM_ROWS',to_char(l_count));

      For code_assig IN Class_Categories_From (l_ptp_id_from) LOOP
        OPEN Class_Codes_To(l_ptp_id_to
                           ,code_assig.class_category
                           ,code_assig.END_DATE_ACTIVE
                           ,code_assig.class_code);
        FETCH Class_Codes_To INTO Class_Codes_To_Rec.Class_Category,
                                  Class_Codes_To_Rec.class_code,
                                  Class_Codes_To_Rec.END_DATE_ACTIVE;
        IF Class_Codes_To%NOTFOUND THEN
          update hz_code_assignments
          set owner_table_id         = l_ptp_id_to,
              last_update_date       = sysdate,
              last_updated_by        = g_user_id,
              last_update_login      = g_login_id,
              object_version_number  = object_version_number+1
          where code_assignment_id = code_assig.code_assignment_id;
        END IF;
        CLOSE Class_Codes_To;
     END Loop;

    EXCEPTION
      WHEN NO_DATA_FOUND THEN
        NULL;
      WHEN OTHERS THEN
        FND_MESSAGE.SET_NAME('AR', 'HZ_MERGE_SQL_ERROR');
        FND_MESSAGE.SET_TOKEN('ERROR' ,SQLERRM);
        FND_MSG_PUB.ADD;
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    END;
  end if;

   IF (G_LEVEL_PROCEDURE >= G_CURRENT_RUNTIME_LEVEL ) THEN
     l_log_msg := l_procedure_name||' (-) ';
     FND_LOG.STRING(G_LEVEL_PROCEDURE, G_MODULE_NAME||l_procedure_name, l_log_msg);
   END IF;

end ZX_PTP_MERGE_PVT;



PROCEDURE ZX_TAX_AUTH_MERGE_PVT (
  p_entity_name        in  hz_merge_dictionary.entity_name%type,
  p_ptp_id_from            in  NUMBER,
  p_ptp_id_to            in  NUMBER,
  x_to_id          in out  nocopy oks_billing_profiles_b.id%type,
  p_from_fk_id         in  hz_merge_parties.from_party_id%type,
  p_to_fk_id           in  hz_merge_parties.to_party_id%type,
  x_return_status     out  nocopy varchar2)
    IS
      -- Enter the procedure variables here. As shown below
  l_count      number(10)       := 0;

  -- Logging Infra
  l_procedure_name CONSTANT VARCHAR2(30) := '.ZX_TAX_AUTH_MERGE_PVT ';
  l_log_msg                 FND_LOG_MESSAGES.MESSAGE_TEXT%TYPE;

BEGIN

  -- Logging Infra: Setting up runtime level
  G_CURRENT_RUNTIME_LEVEL := FND_LOG.G_CURRENT_RUNTIME_LEVEL;

  IF (G_LEVEL_PROCEDURE >= G_CURRENT_RUNTIME_LEVEL ) THEN
    l_log_msg := l_procedure_name||' (+) ';
    FND_LOG.STRING(G_LEVEL_PROCEDURE, G_MODULE_NAME||l_procedure_name, l_log_msg);
  END IF;

  x_return_status :=  FND_API.G_RET_STS_SUCCESS;

  --If it is a Site Merge, nothing to be done. Return the x_to_id.

  if p_from_fk_id = p_to_fk_id then
    return;
  end if;

  if p_from_fk_id <> p_to_fk_id then
    BEGIN

      arp_message.set_line('Updating zx_registrations for tax Authorities...');

      update zx_registrations
      set TAX_AUTHORITY_ID   = p_ptp_id_to,
          last_update_date   = sysdate,
          last_updated_by    = g_user_id,
          last_update_login  = g_login_id,
          object_version_number = object_version_number+1
      where TAX_AUTHORITY_ID = p_ptp_id_from;

      update zx_registrations
      set REP_TAX_AUTHORITY_ID   = p_ptp_id_to,
          last_update_date   = sysdate,
          last_updated_by    = g_user_id,
          last_update_login  = g_login_id,
          object_version_number = object_version_number+1
      where REP_TAX_AUTHORITY_ID = p_ptp_id_from;

      update zx_registrations
      set COLL_TAX_AUTHORITY_ID   = p_ptp_id_to,
          last_update_date   = sysdate,
          last_updated_by    = g_user_id,
          last_update_login  = g_login_id,
          object_version_number = object_version_number+1
      where COLL_TAX_AUTHORITY_ID = p_ptp_id_from;

      arp_message.set_line('Updating zx_taxes_b for tax Authorities...');

      update zx_taxes_b
      set REP_TAX_AUTHORITY_ID   = p_ptp_id_to,
          last_update_date   = sysdate,
          last_updated_by    = g_user_id,
          last_update_login  = g_login_id,
          object_version_number = object_version_number+1
      where REP_TAX_AUTHORITY_ID = p_ptp_id_from;

      update zx_taxes_b
      set COLL_TAX_AUTHORITY_ID   = p_ptp_id_to,
          last_update_date   = sysdate,
          last_updated_by    = g_user_id,
          last_update_login  = g_login_id,
          object_version_number = object_version_number+1
      where COLL_TAX_AUTHORITY_ID = p_ptp_id_from;

      arp_message.set_line('Updating zx_regimes_b for tax Authorities...');

      update zx_regimes_b
      set REP_TAX_AUTHORITY_ID   = p_ptp_id_to,
          last_update_date   = sysdate,
          last_updated_by    = g_user_id,
          last_update_login  = g_login_id,
          object_version_number = object_version_number+1
      where REP_TAX_AUTHORITY_ID = p_ptp_id_from;

      update zx_regimes_b
      set COLL_TAX_AUTHORITY_ID   = p_ptp_id_to,
          last_update_date   = sysdate,
          last_updated_by    = g_user_id,
          last_update_login  = g_login_id,
          object_version_number = object_version_number+1
      where COLL_TAX_AUTHORITY_ID = p_ptp_id_from;

      arp_message.set_line('Updating zx_jurisdictions_b for tax Authorities...');

      update zx_jurisdictions_b
      set REP_TAX_AUTHORITY_ID   = p_ptp_id_to,
          last_update_date   = sysdate,
          last_updated_by    = g_user_id,
          last_update_login  = g_login_id,
          object_version_number = object_version_number+1
      where REP_TAX_AUTHORITY_ID = p_ptp_id_from;

      update zx_jurisdictions_b
      set COLL_TAX_AUTHORITY_ID   = p_ptp_id_to,
          last_update_date   = sysdate,
          last_updated_by    = g_user_id,
          last_update_login  = g_login_id,
          object_version_number = object_version_number+1
      where COLL_TAX_AUTHORITY_ID = p_ptp_id_from;

      arp_message.set_line('Updating zx_jurisdictions_b for tax Authorities...');

      update zx_exemptions
      set ISSUING_TAX_AUTHORITY_ID   = p_ptp_id_to,
          last_update_date   = sysdate,
          last_updated_by    = g_user_id,
          last_update_login  = g_login_id,
          object_version_number = object_version_number+1
      where ISSUING_TAX_AUTHORITY_ID = p_ptp_id_from;

      l_count := sql%rowcount;
      arp_message.set_name('AR','AR_ROWS_UPDATED');
      arp_message.set_token('NUM_ROWS',to_char(l_count));

    EXCEPTION
      WHEN NO_DATA_FOUND THEN
           NULL;
       WHEN OTHERS THEN
            FND_MESSAGE.SET_NAME('AR', 'HZ_MERGE_SQL_ERROR');
            FND_MESSAGE.SET_TOKEN('ERROR' ,SQLERRM);
            FND_MSG_PUB.ADD;
            x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    END;
  end if;

   IF (G_LEVEL_PROCEDURE >= G_CURRENT_RUNTIME_LEVEL ) THEN
     l_log_msg := l_procedure_name||' (-) ';
     FND_LOG.STRING(G_LEVEL_PROCEDURE, G_MODULE_NAME||l_procedure_name, l_log_msg);
   END IF;

 end ZX_TAX_AUTH_MERGE_PVT;



PROCEDURE ZX_EXEMPTIONS_PVT (
  p_entity_name        in  hz_merge_dictionary.entity_name%type,
  p_from_id            in  oks_billing_profiles_b.id%type,
  x_to_id              in out  nocopy oks_billing_profiles_b.id%type,
  p_from_fk_id         in  hz_merge_parties.from_party_id%type,
  p_to_fk_id           in  hz_merge_parties.to_party_id%type,
  p_parent_entity_name in  hz_merge_dictionary.parent_entity_name%type,
  p_batch_id           in  hz_merge_batch.batch_id%type,
  p_batch_party_id     in  hz_merge_party_details.batch_party_id%type,
  x_return_status      out  nocopy varchar2)

  IS

  cursor exe_number(p_fk_id  hz_merge_parties.from_party_id%type) IS
    select TAX_EXEMPTION_ID
          , EXEMPT_CERTIFICATE_NUMBER
          , effective_from
          , effective_to
          , EXEMPTION_TYPE_CODE
          , EXEMPTION_STATUS_CODE
          , TAX_REGIME_CODE
          , TAX_RATE_CODE
          , CUST_ACCOUNT_ID
          , SITE_USE_ID
          , EXEMPT_REASON_CODE
          , CONTENT_OWNER_ID
          , TAX
          , TAX_JURISDICTION_ID
          , PRODUCT_ID
          , TAX_STATUS_CODE
    from   zx_exemptions exemp
    where  party_tax_profile_id = p_fk_id;

  CURSOR  to_exemption (l_certificate_number varchar2,
                        l_effective_from zx_exemptions.effective_from%type,
                        l_effective_to zx_exemptions.effective_to%type,
                        l_type_code zx_exemptions.exemption_type_code%type,
                        l_status_code zx_exemptions.exemption_status_code%type,
                        l_tax_regime_code  zx_exemptions.tax_regime_code%type,
                        l_tax_rate_code zx_exemptions.tax_rate_code%type,
                        l_cust_account_id zx_exemptions.cust_account_id%type,
                        l_site_use_id zx_exemptions.site_use_id%type,
                        l_exempt_reason_code zx_exemptions.exempt_reason_code%type,
                        l_content_owner_id zx_exemptions.content_owner_id%type,
                        l_tax zx_exemptions.tax%type,
                        l_tax_jurisdiction_id zx_exemptions.tax_jurisdiction_id%type,
                        l_product_id zx_exemptions.product_id%type,
                        l_tax_status_code zx_exemptions.tax_status_code%type)
    IS
    select TAX_EXEMPTION_ID
    from   zx_exemptions exemp
    where  party_tax_profile_id = p_to_fk_id
      and  exempt_certificate_number = l_certificate_number
      and  effective_from = l_effective_from
      and  nvl(effective_to,l_effective_to) = l_effective_to
      and  exemption_type_code = l_type_code
      and  exemption_status_code = l_status_code
      and  tax_regime_code = l_tax_regime_code
      and  tax_rate_code = l_tax_rate_code
      and  cust_account_id = l_cust_account_id
      and  site_use_id = l_site_use_id
      and  exempt_reason_code = l_exempt_reason_code
      and  content_owner_id = l_content_owner_id
      and  tax = l_tax
      and  tax_jurisdiction_id = l_tax_jurisdiction_id
      and  tax_status_code = l_tax_status_code
      and  (product_id is null or product_id = l_product_id)
      and  duplicate_exemption = 0;

    to_exemption_rec to_exemption%ROWTYPE;

  -- Enter the procedure variables here.
  l_count      number(10)       := 0;

  -- Logging Infra
  l_procedure_name CONSTANT VARCHAR2(30) := '.ZX_EXEMPTIONS_PVT ';
  l_log_msg                 FND_LOG_MESSAGES.MESSAGE_TEXT%TYPE;

BEGIN

  -- Logging Infra: Setting up runtime level
  G_CURRENT_RUNTIME_LEVEL := FND_LOG.G_CURRENT_RUNTIME_LEVEL;

  IF (G_LEVEL_PROCEDURE >= G_CURRENT_RUNTIME_LEVEL ) THEN
    l_log_msg := l_procedure_name||' (+) ';
    FND_LOG.STRING(G_LEVEL_PROCEDURE, G_MODULE_NAME||l_procedure_name, l_log_msg);
  END IF;

  x_return_status :=  FND_API.G_RET_STS_SUCCESS;

  --If it is a Site Merge, nothing to be done. Return the x_to_id.

  if p_from_fk_id = p_to_fk_id then
    x_to_id := p_from_id;
    return;
  end if;

  if p_from_fk_id <> p_to_fk_id then
    BEGIN

       arp_message.set_line('Updating exemptions...');
       For rec_exe IN exe_number(p_from_fk_id)
         Loop
            Open  to_exemption(rec_exe.exempt_certificate_number
                              ,rec_exe.effective_from
                              ,rec_exe.effective_to
                              ,rec_exe.exemption_type_code
                              ,rec_exe.exemption_status_code
                              ,rec_exe.tax_regime_code
                              ,rec_exe.tax_rate_code
                              ,rec_exe.cust_account_id
                              ,rec_exe.site_use_id
                              ,rec_exe.exempt_reason_code
                              ,rec_exe.content_owner_id
                              ,rec_exe.tax
                              ,rec_exe.tax_jurisdiction_id
                              ,rec_exe.tax_status_code
                              ,rec_exe.product_id);
               Loop
                     FETCH to_exemption INTO to_exemption_rec;
                     IF to_exemption%NOTFOUND THEN
                       update zx_exemptions
                       set --merged_to_exemption_id   = l_exemption_id_to,
                           party_tax_profile_id  = p_to_fk_id,
                           last_update_date      = sysdate,
                           last_updated_by       = g_user_id,
                           last_update_login     = g_login_id,
                           object_version_number = object_version_number+1
                       where TAX_EXEMPTION_ID = rec_exe.tax_exemption_id;
                     End IF;

                      l_count := l_count+sql%rowcount;
                End Loop;
             CLOSE to_exemption;

          End Loop;

       arp_message.set_name('AR','AR_ROWS_UPDATED');
       arp_message.set_token('NUM_ROWS',to_char(l_count));

    EXCEPTION
       WHEN NO_DATA_FOUND THEN
         NULL;
       WHEN OTHERS THEN
         FND_MESSAGE.SET_NAME('AR', 'HZ_MERGE_SQL_ERROR');
         FND_MESSAGE.SET_TOKEN('ERROR' ,SQLERRM);
         FND_MSG_PUB.ADD;
         x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    END;
  END IF;

  IF (G_LEVEL_PROCEDURE >= G_CURRENT_RUNTIME_LEVEL ) THEN
    l_log_msg := l_procedure_name||' (-) ';
    FND_LOG.STRING(G_LEVEL_PROCEDURE, G_MODULE_NAME||l_procedure_name, l_log_msg);
  END IF;
end ZX_EXEMPTIONS_PVT;

PROCEDURE ZX_CUSTOMER_VETO_PVT (
  p_ptp_id_from         in  number,
  p_ptp_id_to           in  number,
  x_merge_yn            out  nocopy VARCHAR2,
  p_from_fk_id          in  hz_merge_parties.from_party_id%type,
  p_to_fk_id            in  hz_merge_parties.to_party_id%type,
  x_return_status       out  nocopy varchar2)
    IS
  -- Enter the procedure variables here. As shown below
  l_count           number(10)   := 0;
  l_ptp_id_from     NUMBER;
  l_ptp_id_to       NUMBER;
  l_calculate_tax_from   VARCHAR2(1);
  l_calculate_tax_to   VARCHAR2(1);
  l_code_assignment_id  hz_code_assignments.owner_table_name%TYPE;
  l_hash_key        BINARY_INTEGER;

  l_reg_attr_tbl_from   reg_attr_tbl_type;
  l_reg_attr_tbl_to   reg_attr_tbl_type;
  TABLE_SIZE            BINARY_INTEGER := 2048;
--  class_category_rec    class_category_rec_type;
--  class_category_tbl    class_category_tbl_type;

  cursor Calculate_Tax_Flag(p_ptp_id  NUMBER) IS
    select PROCESS_FOR_APPLICABILITY_FLAG
    from   zx_party_tax_profile ptp
    where  ptp.party_tax_profile_id = p_ptp_id;

    from_calc_tax_rec Calculate_Tax_Flag%ROWTYPE;
    to_calc_tax_rec Calculate_Tax_Flag%ROWTYPE;

--  cursor Registration_Attributes(p_ptp_id  number) IS
--    select a.REGISTRATION_TYPE_CODE, a.REGISTRATION_NUMBER, a.ROUNDING_RULE_CODE,
--           a.SELF_ASSESS_FLAG, a.INCLUSIVE_TAX_FLAG
--    from zx_registrations a, zx_party_tax_profile b
--    where   b.party_tax_profile_id = p_ptp_id
--    and     a.party_tax_profile_id = b.party_tax_profile_id;

--    Reg_Attr_From_Rec Registration_Attributes%ROWTYPE;
--    Reg_Attr_To_Rec Registration_Attributes%ROWTYPE;

  cursor Registration_Attributes(p_ptp_id_1  number,
                                 p_ptp_id_2  number) IS
    select a.REGISTRATION_TYPE_CODE,
           a.REGISTRATION_NUMBER,
           a.ROUNDING_RULE_CODE,
           NVL(a.SELF_ASSESS_FLAG, 'N')   SELF_ASSESS_FLAG,
           NVL(a.INCLUSIVE_TAX_FLAG, 'N') INCLUSIVE_TAX_FLAG,
           a.TAX_REGIME_CODE,
           a.TAX,
           b.REP_REGISTRATION_NUMBER
    from zx_registrations a, zx_party_tax_profile b
    where   b.party_tax_profile_id = p_ptp_id_1
    and     a.party_tax_profile_id = b.party_tax_profile_id
    and     sysdate between a.effective_from and nvl(a.effective_to, sysdate)
    MINUS
    select a.REGISTRATION_TYPE_CODE,
           a.REGISTRATION_NUMBER,
           a.ROUNDING_RULE_CODE,
           NVL(a.SELF_ASSESS_FLAG, 'N')   SELF_ASSESS_FLAG,
           NVL(a.INCLUSIVE_TAX_FLAG, 'N') INCLUSIVE_TAX_FLAG,
           a.TAX_REGIME_CODE,
           a.TAX,
           b.REP_REGISTRATION_NUMBER
    from zx_registrations a, zx_party_tax_profile b
    where   b.party_tax_profile_id = p_ptp_id_2
    and     a.party_tax_profile_id = b.party_tax_profile_id
    and     sysdate between a.effective_from and nvl(a.effective_to, sysdate);

    cursor Registration_Attributes_Exist(p_ptp_id number) IS
    select 1
    from zx_registrations a, zx_party_tax_profile b
    where   b.party_tax_profile_id = p_ptp_id
    and     a.party_tax_profile_id = b.party_tax_profile_id
    and     sysdate between a.effective_from and nvl(a.effective_to, sysdate);

    Reg_Attr_Rec Registration_Attributes%ROWTYPE;
    Reg_Attr_Rec_From Registration_Attributes%ROWTYPE;


    -- Logging Infra
  l_procedure_name CONSTANT VARCHAR2(30) := '.ZX_CUSTOMER_VETO_PVT ';
  l_log_msg                 FND_LOG_MESSAGES.MESSAGE_TEXT%TYPE;
  l_dummy_number            NUMBER;


BEGIN

  -- Logging Infra: Procedure level
  -- Logging Infra: Setting up runtime level
  G_CURRENT_RUNTIME_LEVEL := FND_LOG.G_CURRENT_RUNTIME_LEVEL;

  IF (G_LEVEL_PROCEDURE >= G_CURRENT_RUNTIME_LEVEL ) THEN
      l_log_msg := l_procedure_name||' (+) ';
      FND_LOG.STRING(G_LEVEL_PROCEDURE, G_MODULE_NAME||l_procedure_name, l_log_msg);
  END IF;

  IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL ) THEN
    FND_LOG.STRING(G_LEVEL_STATEMENT, G_MODULE_NAME||l_procedure_name,
      'Parameters to the procedure are as follows :- '||
      'p_ptp_id_from : '||p_ptp_id_from||' , p_ptp_id_to : '||p_ptp_id_to||
      'p_from_fk_id : '||p_from_fk_id||' , p_to_fk_id : '||p_to_fk_id
                  );
  END IF;

  x_return_status :=  FND_API.G_RET_STS_SUCCESS;
--
-- Tax Applicability it is just for Suppliers
--   Commenting as per Nigel Updates 3511846
--
--  OPEN Calculate_Tax_Flag(p_ptp_id_from);
--  FETCH Calculate_Tax_Flag INTO from_calc_tax_rec;
--  IF Calculate_Tax_Flag%FOUND THEN
--    l_calculate_tax_from  :=from_calc_tax_rec.PROCESS_FOR_APPLICABILITY_FLAG;
--  END IF;
--  CLOSE Calculate_Tax_Flag;
--
--  OPEN Calculate_Tax_Flag(p_ptp_id_to);
--  FETCH Calculate_Tax_Flag INTO to_calc_tax_rec;
--  IF Calculate_Tax_Flag%FOUND THEN
--    l_calculate_tax_to  :=to_calc_tax_rec.PROCESS_FOR_APPLICABILITY_FLAG;
--  END IF;
--  CLOSE Calculate_Tax_Flag;
--
--    if(l_calculate_tax_from <> l_calculate_tax_to) THEN
--        arp_message.set_line('Parties '||p_from_fk_id||' and '||p_to_fk_id||' cannot be merged
--                            as Calculate Tax Flag has different Values');
--        x_merge_yn  := 'N';
--    end if;
--

--  FOR REC in Registration_Attributes(p_ptp_id_to) LOOP
--    l_hash_key := DBMS_UTILITY.get_hash_value(REC.REGISTRATION_TYPE_CODE||REC.REGISTRATION_NUMBER||REC.ROUNDING_RULE_CODE||REC.SELF_ASSESS_FLAG||REC.INCLUSIVE_TAX_FLAG,1,TABLE_SIZE);
--    l_reg_attr_tbl_to(l_hash_key) := REC;
--  END LOOP;

--  FOR REC in Registration_Attributes(p_ptp_id_from) LOOP
--    l_hash_key := DBMS_UTILITY.get_hash_value(REC.REGISTRATION_TYPE_CODE||REC.REGISTRATION_NUMBER||REC.ROUNDING_RULE_CODE||REC.SELF_ASSESS_FLAG||REC.INCLUSIVE_TAX_FLAG,1,TABLE_SIZE);
--    if(l_reg_attr_tbl_to.exists(l_hash_key)) THEN
--      x_merge_yn  := 'Y';
--    ELSE
--      arp_message.set_line('Parties '||p_from_fk_id||' and '||p_to_fk_id||
--         ' cannot be merged as Registration Attributes have different Values');
--      x_merge_yn  := 'N';
--    END IF;

--    l_reg_attr_tbl_from(l_hash_key) := REC;
--  END LOOP;

  OPEN Registration_Attributes (p_ptp_id_from,p_ptp_id_to);  -- (A-B)
  FETCH Registration_Attributes into Reg_Attr_Rec;

  IF Registration_Attributes%FOUND THEN
    IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL ) THEN
      FND_LOG.STRING(G_LEVEL_STATEMENT, G_MODULE_NAME||l_procedure_name,
        'Parties '||p_ptp_id_from||' and '||p_ptp_id_to||
        ' cannot be merged as Registration Attributes have different Values (A-B)'
                    );
    END IF;
    arp_message.set_line('Parties '||p_from_fk_id||' and '||p_to_fk_id||
         ' cannot be merged as Registration Attributes have different Values (A-B)');
    x_merge_yn  := 'N';
    CLOSE Registration_Attributes;
    return;
  END IF;

  CLOSE Registration_Attributes;

  OPEN Registration_Attributes (p_ptp_id_to, p_ptp_id_from); -- (B-A)
  FETCH Registration_Attributes into Reg_Attr_Rec;

  IF Registration_Attributes%FOUND THEN
    OPEN Registration_Attributes_Exist (p_ptp_id_from);
    FETCH Registration_Attributes_Exist into l_dummy_number;
    IF Registration_Attributes_Exist%FOUND THEN
      IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL ) THEN
        FND_LOG.STRING(G_LEVEL_STATEMENT, G_MODULE_NAME||l_procedure_name,
          'Parties '||p_ptp_id_to||' and '||p_ptp_id_from||
          ' cannot be merged as Registration Attributes have different Values (B-A)'
                      );
      END IF;
      arp_message.set_line('Parties '||p_to_fk_id ||' and '||p_from_fk_id||
         ' cannot be merged as Registration Attributes have different Values (B-A)');
      x_merge_yn  := 'N';
      CLOSE Registration_Attributes_Exist;
      return;
    END IF;
    CLOSE Registration_Attributes_Exist;
  END IF;

  CLOSE Registration_Attributes;

  x_merge_yn  := 'Y';

  IF (G_LEVEL_PROCEDURE >= G_CURRENT_RUNTIME_LEVEL ) THEN
    l_log_msg := l_procedure_name||' (-) ';
    FND_LOG.STRING(G_LEVEL_PROCEDURE, G_MODULE_NAME||l_procedure_name, l_log_msg);
  END IF;

  EXCEPTION
    WHEN NO_DATA_FOUND THEN
      NULL;
    WHEN OTHERS THEN
      FND_MESSAGE.SET_NAME('AR', 'HZ_MERGE_SQL_ERROR');
      FND_MESSAGE.SET_TOKEN('ERROR' ,SQLERRM);
      FND_MSG_PUB.ADD;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
end ZX_CUSTOMER_VETO_PVT;


PROCEDURE ZX_MERGE (
  p_entity_name        in  hz_merge_dictionary.entity_name%type,
  p_from_id            in  oks_billing_profiles_b.id%type,
  x_to_id          in out  nocopy oks_billing_profiles_b.id%type,
  p_from_fk_id         in  hz_merge_parties.from_party_id%type,
  p_to_fk_id           in  hz_merge_parties.to_party_id%type,
  p_parent_entity_name in  hz_merge_dictionary.parent_entity_name%type,
  p_batch_id           in  hz_merge_batch.batch_id%type,
  p_batch_party_id     in  hz_merge_party_details.batch_party_id%type,
  x_return_status     out  nocopy varchar2)
    IS
  -- Enter the procedure variables here. As shown below
  l_ptp_id_from         NUMBER;
  l_ptp_id_to           NUMBER;
  l_code_assignment_id  hz_code_assignments.owner_table_name%TYPE;
  l_party_type_from     VARCHAR2(30);
  l_party_type_to       VARCHAR2(30);
  l_merge_yn            VARCHAR2(1);


  cursor Party_Tax_Profile(p_fk_id  hz_merge_parties.from_party_id%type) IS
    select Party_Tax_Profile_id, party_type_code
    from   zx_party_tax_profile prof
    where  prof.party_id = p_fk_id
      and  prof.party_type_code = 'THIRD_PARTY';

  from_ptp_rec Party_Tax_Profile%ROWTYPE;
  to_ptp_rec   Party_Tax_Profile%ROWTYPE;

  -- Logging Infra
  l_procedure_name CONSTANT VARCHAR2(30) := '.ZX_MERGE ';
  l_log_msg                 FND_LOG_MESSAGES.MESSAGE_TEXT%TYPE;

BEGIN

  -- Logging Infra: Setting up runtime level
  G_CURRENT_RUNTIME_LEVEL := FND_LOG.G_CURRENT_RUNTIME_LEVEL;

  -- Logging Infra: Procedure level
  IF (G_LEVEL_PROCEDURE >= G_CURRENT_RUNTIME_LEVEL ) THEN
     l_log_msg := l_procedure_name||' (+) ';
     FND_LOG.STRING(G_LEVEL_PROCEDURE, G_MODULE_NAME||l_procedure_name, l_log_msg);
  END IF;

  x_return_status :=  FND_API.G_RET_STS_SUCCESS;

  --If it is a Site Merge, nothing to be done. Return the x_to_id.

  if p_from_fk_id = p_to_fk_id then
    x_to_id := p_from_id;
    x_return_status := 'E';
    return;
  end if;

  if p_from_fk_id <> p_to_fk_id then
    BEGIN

      arp_message.set_line('Identifying Party Type...');

      OPEN Party_Tax_Profile(p_from_fk_id);
      FETCH Party_Tax_Profile INTO from_ptp_rec;
      IF Party_Tax_Profile%FOUND THEN
        l_ptp_id_from     := from_ptp_rec.Party_Tax_Profile_id;
        l_party_type_from := from_ptp_rec.Party_type_code;
      END IF;
      CLOSE Party_Tax_Profile;

      OPEN Party_Tax_Profile(p_to_fk_id);
      FETCH Party_Tax_Profile INTO from_ptp_rec;
      IF Party_Tax_Profile%FOUND THEN
        l_ptp_id_to     := from_ptp_rec.Party_Tax_Profile_id;
        l_party_type_to := from_ptp_rec.Party_type_code;
      END IF;
      CLOSE Party_Tax_Profile;

      if(l_party_type_from <> l_party_type_to) THEN
        arp_message.set_line('Cannot Merge Parties, Party Types are different...');
        x_return_status := 'E';
        return;
      else
        if(l_party_type_from = 'THIRD_PARTY') THEN
          ZX_CUSTOMER_VETO_PVT(
            p_ptp_id_from       => l_ptp_id_from,
            p_ptp_id_to         => l_ptp_id_to,
            x_merge_yn          => l_merge_yn,
            p_from_fk_id        => p_from_fk_id,
            p_to_fk_id          => p_to_fk_id,
            x_return_status     => x_return_status);

-- As per Nigel comments bug 3511846
--          ZX_FISCAL_CLASS_VETO(
--            p_ptp_id_from       => l_ptp_id_from,
--            p_ptp_id_to         => l_ptp_id_to,
--            x_merge_yn          => l_merge_yn,
--            p_from_fk_id        => p_from_fk_id,
--            p_to_fk_id          => p_to_fk_id,
--            x_return_status     => x_return_status);
--

          if(l_merge_yn = 'N') THEN
            x_return_status := 'E';
          else
            ZX_PTP_MERGE_PVT(
              p_entity_name       => p_entity_name,
              p_from_id           => p_from_id,
              x_to_id             => x_to_id,
              p_from_fk_id        => p_from_fk_id,
              p_to_fk_id          => p_to_fk_id,
              p_parent_entity_name=> p_parent_entity_name,
              p_batch_id          => p_batch_id,
              p_batch_party_id    => p_batch_party_id,
              x_return_status     => x_return_status);

            ZX_CUST_REG_MERGE_PVT(
              p_entity_name       => p_entity_name,
              p_from_id           => p_from_id,
              x_to_id             => x_to_id,
              p_from_fk_id        => p_from_fk_id,
              p_to_fk_id          => p_to_fk_id,
              p_parent_entity_name=> p_parent_entity_name,
              p_batch_id          => p_batch_id,
              p_batch_party_id    => p_batch_party_id,
              x_return_status     => x_return_status);

            ZX_EXEMPTIONS_PVT(
              p_entity_name       => p_entity_name,
              p_from_id           => p_from_id,
              x_to_id             => x_to_id,
              p_from_fk_id        => l_ptp_id_from,
              p_to_fk_id          => l_ptp_id_from,
              p_parent_entity_name=> p_parent_entity_name,
              p_batch_id          => p_batch_id,
              p_batch_party_id    => p_batch_party_id,
              x_return_status     => x_return_status);
            end if;
          elsif(l_party_type_from = 'TAX_AUTHORITY') THEN
            ZX_TAX_AUTH_MERGE_PVT (
              p_entity_name       => p_entity_name,
              p_ptp_id_from       => l_ptp_id_from,
              p_ptp_id_to         => l_ptp_id_to,
              x_to_id             => x_to_id,
              p_from_fk_id        => p_from_fk_id,
              p_to_fk_id          => p_to_fk_id,
              x_return_status     => x_return_status);
          end if;
        end if;

      EXCEPTION
        WHEN NO_DATA_FOUND THEN
          NULL;
        WHEN OTHERS THEN
          FND_MESSAGE.SET_NAME('AR', 'HZ_MERGE_SQL_ERROR');
          FND_MESSAGE.SET_TOKEN('ERROR' ,SQLERRM);
          FND_MSG_PUB.ADD;
          x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      END;
    end if;

    IF (G_LEVEL_PROCEDURE >= G_CURRENT_RUNTIME_LEVEL ) THEN
        l_log_msg := l_procedure_name||' (-) ';
        FND_LOG.STRING(G_LEVEL_PROCEDURE, G_MODULE_NAME||l_procedure_name, l_log_msg);
    END IF;

end ZX_MERGE;

------------------------------
-- Merge PTP (Bulk Call)
------------------------------
  PROCEDURE MERGE_PTP_BULK
    (request_id    IN  NUMBER,
     set_number    IN  NUMBER,
     process_mode  IN  VARCHAR2
    ) IS
    -- Logging Infra
    l_procedure_name CONSTANT VARCHAR2(30) := '.MERGE_PTP_BULK ';
    l_prog_appl_id            NUMBER;
    l_conc_program_id         NUMBER;
    l_request_id              NUMBER;

    TYPE bulk_number_type is TABLE OF NUMBER INDEX BY BINARY_INTEGER;
    l_tbl_from_party_site_id  bulk_number_type;
    l_tbl_to_party_site_id    bulk_number_type;
    l_tbl_from_ptp_id         bulk_number_type;
    l_tbl_to_ptp_id           bulk_number_type;
    l_tbl_to_acct_id          bulk_number_type;
    l_tbl_to_acct_site_id     bulk_number_type;


  BEGIN
    arp_message.set_line(G_MODULE_NAME||l_procedure_name||'Begin with param request id: '||request_id);
    G_CURRENT_RUNTIME_LEVEL := FND_LOG.G_CURRENT_RUNTIME_LEVEL;
    -- Logging Infra: Procedure level
    IF (G_LEVEL_PROCEDURE >= G_CURRENT_RUNTIME_LEVEL ) THEN
      FND_LOG.STRING(G_LEVEL_PROCEDURE, G_MODULE_NAME||l_procedure_name,
         'Begin with param request id: '||request_id);
    END IF;
    l_request_id      := request_id;
    l_prog_appl_id    := FND_GLOBAL.PROG_APPL_ID;
    l_conc_program_id := FND_GLOBAL.CONC_PROGRAM_ID;
    --
    -- Processing for PTP records start
    --
    SELECT from_party_site_id,
           to_party_site_id,
           party_tax_profile_id,
           zx_party_tax_profile_s.nextval,
           cust_account_id,
           cust_acct_site_id
   BULK COLLECT INTO l_tbl_from_party_site_id,
                     l_tbl_to_party_site_id,
                     l_tbl_from_ptp_id,
                     l_tbl_to_ptp_id,
                     l_tbl_to_acct_id,
                     l_tbl_to_acct_site_id
    FROM (SELECT cas.party_site_id   from_party_site_id,
                 cas2.party_site_id        to_party_site_id,
                 ptp.party_tax_profile_id,
                 cas2.cust_account_id,
                 cas2.cust_acct_site_id,
                 row_number() over (partition by cas.party_site_id,
                                                 cas2.party_site_id,
                                                 cas2.cust_account_id,
                                                 cas2.cust_acct_site_id
                                        order by rm.customer_site_id
                                    ) as party_site_num
           FROM RA_CUSTOMER_MERGES rm,
                HZ_CUST_ACCT_SITES_ALL cas,
                HZ_CUST_ACCT_SITES_ALL cas2,
                ZX_PARTY_TAX_PROFILE ptp
          WHERE rm.request_id = l_request_id
            AND rm.duplicate_address_id = cas.cust_acct_site_id
            AND rm.customer_address_id = cas2.cust_acct_site_id
            AND ptp.party_id = cas.party_site_id
            AND ptp.party_type_code = 'THIRD_PARTY_SITE'
          )
    WHERE party_site_num = 1;

    arp_message.set_line(G_MODULE_NAME||l_procedure_name||'from party id - to party id - ptp id');
    IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL ) THEN
      FND_LOG.STRING(G_LEVEL_STATEMENT, G_MODULE_NAME||l_procedure_name,'from party id - to party id - ptp id');
    END IF;

    for i in 1..l_tbl_to_ptp_id.count LOOP
      IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL ) THEN
        FND_LOG.STRING(G_LEVEL_STATEMENT, G_MODULE_NAME||l_procedure_name,
           l_tbl_from_party_site_id(i)||' - '|| l_tbl_to_party_site_id(i)||' - '||l_tbl_to_ptp_id(i));
      END IF;
      arp_message.set_line(G_MODULE_NAME||l_procedure_name||l_tbl_from_party_site_id(i)||' - '|| l_tbl_to_party_site_id(i)||' - '||l_tbl_to_ptp_id(i));
    END LOOP;

    IF l_tbl_from_ptp_id.count > 0 THEN
      --
      -- inserting PTP records for the new site
      --
      IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL ) THEN
        FND_LOG.STRING(G_LEVEL_STATEMENT, G_MODULE_NAME||l_procedure_name,
            'Inserting party tax profile records');
      END IF;
      arp_message.set_line(G_MODULE_NAME||l_procedure_name||'Inserting party tax profile records');
      FORALL i IN 1..l_tbl_to_ptp_id.count
          INSERT INTO ZX_PARTY_TAX_PROFILE
            (party_type_code
            ,supplier_flag
            ,customer_flag
            ,site_flag
            ,process_for_applicability_flag
            ,rounding_level_code
            ,rounding_rule_code
            ,withholding_start_date
            ,inclusive_tax_flag
            ,allow_awt_flag
            ,use_le_as_subscriber_flag
            ,legal_establishment_flag
            ,first_party_le_flag
            ,reporting_authority_flag
            ,collecting_authority_flag
            ,provider_type_code
            ,create_awt_dists_type_code
            ,create_awt_invoices_type_code
            ,tax_classification_code
            ,self_assess_flag
            ,allow_offset_tax_flag
            ,effective_from_use_le
            ,record_type_code
            ,created_by
            ,creation_date
            ,last_updated_by
            ,last_update_date
            ,last_update_login
            ,request_id
            ,program_application_id
            ,program_id
            ,attribute1
            ,attribute2
            ,attribute3
            ,attribute4
            ,attribute5
            ,attribute6
            ,attribute7
            ,attribute8
            ,attribute9
            ,attribute10
            ,attribute11
            ,attribute12
            ,attribute13
            ,attribute14
            ,attribute15
            ,attribute_category
            ,program_login_id
            ,party_tax_profile_id
            ,party_id
            ,rep_registration_number
            ,object_version_number
            ,registration_type_code
            ,country_code
            ,merged_to_ptp_id
            ,merged_status_code
            )
          SELECT
             a.party_type_code
            ,a.supplier_flag
            ,a.customer_flag
            ,a.site_flag
            ,a.process_for_applicability_flag
            ,a.rounding_level_code
            ,a.rounding_rule_code
            ,a.withholding_start_date
            ,a.inclusive_tax_flag
            ,a.allow_awt_flag
            ,a.use_le_as_subscriber_flag
            ,a.legal_establishment_flag
            ,a.first_party_le_flag
            ,a.reporting_authority_flag
            ,a.collecting_authority_flag
            ,a.provider_type_code
            ,a.create_awt_dists_type_code
            ,a.create_awt_invoices_type_code
            ,a.tax_classification_code
            ,a.self_assess_flag
            ,a.allow_offset_tax_flag
            ,a.effective_from_use_le
            ,a.record_type_code
            ,G_USER_ID
            ,SYSDATE
            ,G_LOGIN_ID
            ,SYSDATE
            ,G_LOGIN_ID
            ,l_request_id
            ,l_prog_appl_id
            ,l_conc_program_id
            ,a.attribute1
            ,a.attribute2
            ,a.attribute3
            ,a.attribute4
            ,a.attribute5
            ,a.attribute6
            ,a.attribute7
            ,a.attribute8
            ,a.attribute9
            ,a.attribute10
            ,a.attribute11
            ,a.attribute12
            ,a.attribute13
            ,a.attribute14
            ,a.attribute15
            ,a.attribute_category
            ,G_LOGIN_ID
            ,l_tbl_to_ptp_id(i)
            ,l_tbl_to_party_site_id(i)
            ,a.rep_registration_number
            ,1
            ,a.registration_type_code
            ,a.country_code
            ,a.merged_to_ptp_id
            ,a.merged_status_code
        FROM zx_party_tax_profile a
        WHERE a.party_tax_profile_id = l_tbl_from_ptp_id(i);
      --
      -- Processing for PTP records end
      -----------------------------------------------------------------
      -- Processing for Registration records start
      --
      IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL ) THEN
        FND_LOG.STRING(G_LEVEL_STATEMENT, G_MODULE_NAME||l_procedure_name,
            'Inserting registration records');
      END IF;
      arp_message.set_line(G_MODULE_NAME||l_procedure_name||'Inserting registration records');
      FORALL i in 1..l_tbl_from_ptp_id.count
        INSERT INTO ZX_REGISTRATIONS
          (registration_type_code
          ,registration_number
          ,validation_rule
          ,rounding_rule_code
          ,tax_jurisdiction_code
          ,self_assess_flag
          ,registration_status_code
          ,registration_source_code
          ,registration_reason_code
          ,tax
          ,tax_regime_code
          ,inclusive_tax_flag
          ,has_tax_exemptions_flag
          ,effective_from
          ,effective_to
          ,rep_party_tax_name
          ,default_registration_flag
          ,bank_account_num
          ,legal_location_id
          ,record_type_code
          ,created_by
          ,creation_date
          ,last_updated_by
          ,last_update_date
          ,last_update_login
          ,request_id
          ,program_application_id
          ,program_id
          ,attribute1
          ,attribute2
          ,attribute3
          ,attribute4
          ,attribute5
          ,attribute6
          ,attribute7
          ,attribute8
          ,attribute9
          ,attribute10
          ,attribute11
          ,attribute12
          ,attribute13
          ,attribute14
          ,attribute15
          ,attribute_category
          ,tax_classification_code
          ,program_login_id
          ,registration_id
          ,tax_authority_id
          ,rep_tax_authority_id
          ,coll_tax_authority_id
          ,party_tax_profile_id
          ,legal_registration_id
          ,bank_id
          ,bank_branch_id
          ,account_id
          ,account_site_id
          ,object_version_number
          ,rounding_level_code
          ,account_type_code
          ,merged_to_registration_id
          )
        SELECT
           registration_type_code
          ,registration_number
          ,validation_rule
          ,rounding_rule_code
          ,tax_jurisdiction_code
          ,self_assess_flag
          ,registration_status_code
          ,registration_source_code
          ,registration_reason_code
          ,tax
          ,tax_regime_code
          ,inclusive_tax_flag
          ,has_tax_exemptions_flag
          ,effective_from
          ,effective_to
          ,rep_party_tax_name
          ,default_registration_flag
          ,bank_account_num
          ,legal_location_id
          ,record_type_code
          ,G_USER_ID
          ,SYSDATE
          ,G_USER_ID
          ,SYSDATE
          ,G_LOGIN_ID
          ,l_request_id
          ,l_prog_appl_id
          ,l_conc_program_id
          ,attribute1
          ,attribute2
          ,attribute3
          ,attribute4
          ,attribute5
          ,attribute6
          ,attribute7
          ,attribute8
          ,attribute9
          ,attribute10
          ,attribute11
          ,attribute12
          ,attribute13
          ,attribute14
          ,attribute15
          ,attribute_category
          ,tax_classification_code
          ,G_LOGIN_ID
          ,zx_registrations_s.nextval
          ,tax_authority_id
          ,rep_tax_authority_id
          ,coll_tax_authority_id
          ,l_tbl_to_ptp_id(i)
          ,legal_registration_id
          ,bank_id
          ,bank_branch_id
          ,l_tbl_to_acct_id(i)
          ,l_tbl_to_acct_site_id(i)
          ,1
          ,rounding_level_code
          ,account_type_code
          ,merged_to_registration_id
        FROM zx_registrations
        WHERE party_tax_profile_id = l_tbl_from_ptp_id(i);
      --
      -- Processing for Registration records end
      -----------------------------------------------------------------
      -- Processing for Exemption records start
      --
      IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL ) THEN
        FND_LOG.STRING(G_LEVEL_STATEMENT, G_MODULE_NAME||l_procedure_name,
            'Inserting exemption records');
      END IF;
      arp_message.set_line(G_MODULE_NAME||l_procedure_name||'Inserting exemption records');
      FORALL i in 1..l_tbl_from_ptp_id.count
        INSERT INTO zx_exemptions
          (tax_exemption_id
          ,exemption_type_code
          ,exemption_status_code
          ,tax_regime_code
          ,tax_status_code
          ,tax
          ,tax_rate_code
          ,exempt_certificate_number
          ,exempt_reason_code
          ,issuing_tax_authority_id
          ,effective_from
          ,effective_to
          ,content_owner_id
          ,product_id
          ,inventory_org_id
          ,rate_modifier
          ,tax_jurisdiction_id
          ,det_factor_templ_code
          ,record_type_code
          ,created_by
          ,creation_date
          ,last_updated_by
          ,last_update_date
          ,last_update_login
          ,request_id
          ,program_application_id
          ,program_id
          ,program_login_id
          ,attribute1
          ,attribute2
          ,attribute3
          ,attribute4
          ,attribute5
          ,attribute6
          ,attribute7
          ,attribute8
          ,attribute9
          ,attribute10
          ,attribute11
          ,attribute12
          ,attribute13
          ,attribute14
          ,attribute15
          ,attribute_category
          ,apply_to_lower_levels_flag
          ,object_version_number
          ,party_tax_profile_id
          ,cust_account_id
          ,site_use_id
          ,duplicate_exemption
          )
        SELECT
           zx_exemptions_s.nextval
          ,exemption_type_code
          ,exemption_status_code
          ,tax_regime_code
          ,tax_status_code
          ,tax
          ,tax_rate_code
          ,exempt_certificate_number
          ,exempt_reason_code
          ,issuing_tax_authority_id
          ,effective_from
          ,effective_to
          ,content_owner_id
          ,product_id
          ,inventory_org_id
          ,rate_modifier
          ,tax_jurisdiction_id
          ,det_factor_templ_code
          ,record_type_code
          ,G_USER_ID
          ,SYSDATE
          ,G_USER_ID
          ,SYSDATE
          ,G_LOGIN_ID
          ,l_request_id
          ,l_prog_appl_id
          ,l_conc_program_id
          ,G_LOGIN_ID
          ,attribute1
          ,attribute2
          ,attribute3
          ,attribute4
          ,attribute5
          ,attribute6
          ,attribute7
          ,attribute8
          ,attribute9
          ,attribute10
          ,attribute11
          ,attribute12
          ,attribute13
          ,attribute14
          ,attribute15
          ,attribute_category
          ,apply_to_lower_levels_flag
          ,1
          ,l_tbl_to_ptp_id(i)
          ,l_tbl_to_acct_id(i)
          ,site_use_id
          ,duplicate_exemption
        FROM zx_exemptions
        WHERE party_tax_profile_id = l_tbl_from_ptp_id(i);
      --
      -- Processing for Exemption records end
      -----------------------------------------------------------------
    END IF;

    IF (G_LEVEL_PROCEDURE >= G_CURRENT_RUNTIME_LEVEL ) THEN
      FND_LOG.STRING(G_LEVEL_PROCEDURE, G_MODULE_NAME||l_procedure_name,'end');
    END IF;
    arp_message.set_line(G_MODULE_NAME||l_procedure_name||'end');

  EXCEPTION
    WHEN OTHERS THEN
      IF (G_LEVEL_EXCEPTION >= G_CURRENT_RUNTIME_LEVEL ) THEN
        FND_LOG.STRING(G_LEVEL_EXCEPTION, G_MODULE_NAME||l_procedure_name,'Exception - '||SQLERRM);
      END IF;
      arp_message.set_line(G_MODULE_NAME||l_procedure_name||'Exception - '||SQLERRM);
  END MERGE_PTP_BULK;

---------------------------------
-- Merge Party Site Registrations
---------------------------------
PROCEDURE MERGE_SITE_REGISTRATIONS_PVT
    (p_from_ptp_id       IN   zx_party_tax_profile.party_tax_profile_id%TYPE
    ,p_to_ptp_id         IN   zx_party_tax_profile.party_tax_profile_id%TYPE
    ,x_return_status     OUT  NOCOPY VARCHAR2
  ) IS

  CURSOR get_from_ptp_registrations IS
  SELECT * FROM zx_registrations
  WHERE party_tax_profile_id = p_from_ptp_id;

  l_registration_id  NUMBER;
  l_reg_count        NUMBER;
  l_procedure_name   CONSTANT VARCHAR2(30) := '.MERGE_SITE_REGISTRATIONS_PVT';

BEGIN
  G_CURRENT_RUNTIME_LEVEL := FND_LOG.G_CURRENT_RUNTIME_LEVEL;
  x_return_status         := FND_API.G_RET_STS_SUCCESS;

  IF (G_LEVEL_PROCEDURE >= G_CURRENT_RUNTIME_LEVEL ) THEN
    FND_LOG.STRING(G_LEVEL_PROCEDURE, G_MODULE_NAME||l_procedure_name,
                   'Merge_Site_Registrations_Pvt(+)');
  END IF;

  l_reg_count := 0;

  FOR rec IN get_from_ptp_registrations LOOP
    SELECT zx_registrations_s.nextval
      INTO l_registration_id
      FROM dual;

    INSERT INTO ZX_REGISTRATIONS
         (registration_type_code
          ,registration_number
          ,validation_rule
          ,rounding_rule_code
          ,tax_jurisdiction_code
          ,self_assess_flag
          ,registration_status_code
          ,registration_source_code
          ,registration_reason_code
          ,tax
          ,tax_regime_code
          ,inclusive_tax_flag
          ,has_tax_exemptions_flag
          ,effective_from
          ,effective_to
          ,rep_party_tax_name
          ,default_registration_flag
          ,bank_account_num
          ,legal_location_id
          ,record_type_code
          ,created_by
          ,creation_date
          ,last_updated_by
          ,last_update_date
          ,last_update_login
          ,attribute1
          ,attribute2
          ,attribute3
          ,attribute4
          ,attribute5
          ,attribute6
          ,attribute7
          ,attribute8
          ,attribute9
          ,attribute10
          ,attribute11
          ,attribute12
          ,attribute13
          ,attribute14
          ,attribute15
          ,attribute_category
          ,tax_classification_code
          ,registration_id
          ,tax_authority_id
          ,rep_tax_authority_id
          ,coll_tax_authority_id
          ,party_tax_profile_id
          ,legal_registration_id
          ,account_id
          ,account_site_id
          ,bank_id
          ,bank_branch_id
          ,object_version_number
          ,rounding_level_code
          ,account_type_code
          ,merged_to_registration_id
          )
      VALUES
         (rec.registration_type_code
          ,rec.registration_number
          ,rec.validation_rule
          ,rec.rounding_rule_code
          ,rec.tax_jurisdiction_code
          ,rec.self_assess_flag
          ,rec.registration_status_code
          ,rec.registration_source_code
          ,rec.registration_reason_code
          ,rec.tax
          ,rec.tax_regime_code
          ,rec.inclusive_tax_flag
          ,rec.has_tax_exemptions_flag
          ,rec.effective_from
          ,rec.effective_to
          ,rec.rep_party_tax_name
          ,'N'
          ,rec.bank_account_num
          ,rec.legal_location_id
          ,rec.record_type_code
          ,g_user_id
          ,sysdate
          ,g_user_id
          ,sysdate
          ,g_login_id
          ,rec.attribute1
          ,rec.attribute2
          ,rec.attribute3
          ,rec.attribute4
          ,rec.attribute5
          ,rec.attribute6
          ,rec.attribute7
          ,rec.attribute8
          ,rec.attribute9
          ,rec.attribute10
          ,rec.attribute11
          ,rec.attribute12
          ,rec.attribute13
          ,rec.attribute14
          ,rec.attribute15
          ,rec.attribute_category
          ,rec.tax_classification_code
          ,l_registration_id
          ,rec.tax_authority_id
          ,rec.rep_tax_authority_id
          ,rec.coll_tax_authority_id
          ,p_to_ptp_id
          ,rec.legal_registration_id
          ,rec.account_id
          ,rec.account_site_id
          ,rec.bank_id
          ,rec.bank_branch_id
          ,1
          ,rec.rounding_level_code
          ,rec.account_type_code
          ,NULL);

    UPDATE zx_registrations
       SET merged_to_registration_id = l_registration_id,
           effective_to       = sysdate,
           last_update_date   = sysdate,
           last_updated_by    = g_user_id,
           last_update_login  = g_login_id,
           object_version_number = object_version_number+1
     WHERE registration_id = rec.registration_id
       AND party_tax_profile_id = p_from_ptp_id;

    l_reg_count := l_reg_count + 1;

  END LOOP;

  IF (G_LEVEL_PROCEDURE >= G_CURRENT_RUNTIME_LEVEL ) THEN
    FND_LOG.STRING(G_LEVEL_PROCEDURE, G_MODULE_NAME||l_procedure_name,
                   l_reg_count||' record(s) created in ZX_Registrations');
  END IF;

  IF (G_LEVEL_PROCEDURE >= G_CURRENT_RUNTIME_LEVEL ) THEN
    FND_LOG.STRING(G_LEVEL_PROCEDURE, G_MODULE_NAME||l_procedure_name,
                   'Merge_Site_Registrations_Pvt(+)');
  END IF;

EXCEPTION
  WHEN OTHERS THEN
    IF (G_LEVEL_EXCEPTION >= G_CURRENT_RUNTIME_LEVEL ) THEN
      FND_LOG.STRING(G_LEVEL_EXCEPTION, G_MODULE_NAME||l_procedure_name,
                     'Merge_Site_Registrations_Pvt(Exception)');
      FND_LOG.STRING(G_LEVEL_EXCEPTION, G_MODULE_NAME||l_procedure_name,
                     'Error : '||SQLERRM);
    END IF;
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;

END MERGE_SITE_REGISTRATIONS_PVT;

------------------------------
-- Merge Party Site Exemptions
------------------------------
PROCEDURE MERGE_SITE_EXEMPTIONS_PVT
    (p_from_ptp_id       IN   zx_party_tax_profile.party_tax_profile_id%TYPE
    ,p_to_ptp_id         IN   zx_party_tax_profile.party_tax_profile_id%TYPE
    ,x_return_status     OUT  NOCOPY VARCHAR2
  ) IS

  l_procedure_name   CONSTANT VARCHAR2(30) := '.MERGE_SITE_EXEMPTIONS_PVT';

BEGIN
  G_CURRENT_RUNTIME_LEVEL := FND_LOG.G_CURRENT_RUNTIME_LEVEL;
  x_return_status         := FND_API.G_RET_STS_SUCCESS;

  IF (G_LEVEL_PROCEDURE >= G_CURRENT_RUNTIME_LEVEL ) THEN
    FND_LOG.STRING(G_LEVEL_PROCEDURE, G_MODULE_NAME||l_procedure_name,
                   'Merge_Site_Exemptions_Pvt(+)');
  END IF;

      INSERT INTO zx_exemptions
          (tax_exemption_id
          ,exemption_type_code
          ,exemption_status_code
          ,tax_regime_code
          ,tax_status_code
          ,tax
          ,tax_rate_code
          ,exempt_certificate_number
          ,exempt_reason_code
          ,issuing_tax_authority_id
          ,effective_from
          ,effective_to
          ,content_owner_id
          ,product_id
          ,inventory_org_id
          ,rate_modifier
          ,tax_jurisdiction_id
          ,det_factor_templ_code
          ,record_type_code
          ,created_by
          ,creation_date
          ,last_updated_by
          ,last_update_date
          ,last_update_login
          ,attribute1
          ,attribute2
          ,attribute3
          ,attribute4
          ,attribute5
          ,attribute6
          ,attribute7
          ,attribute8
          ,attribute9
          ,attribute10
          ,attribute11
          ,attribute12
          ,attribute13
          ,attribute14
          ,attribute15
          ,attribute_category
          ,apply_to_lower_levels_flag
          ,object_version_number
          ,party_tax_profile_id
          ,cust_account_id
          ,site_use_id
          ,duplicate_exemption
          )
        SELECT
           zx_exemptions_s.nextval
          ,exemption_type_code
          ,exemption_status_code
          ,tax_regime_code
          ,tax_status_code
          ,tax
          ,tax_rate_code
          ,exempt_certificate_number
          ,exempt_reason_code
          ,issuing_tax_authority_id
          ,effective_from
          ,effective_to
          ,content_owner_id
          ,product_id
          ,inventory_org_id
          ,rate_modifier
          ,tax_jurisdiction_id
          ,det_factor_templ_code
          ,record_type_code
          ,g_user_id
          ,sysdate
          ,g_user_id
          ,sysdate
          ,g_login_id
          ,attribute1
          ,attribute2
          ,attribute3
          ,attribute4
          ,attribute5
          ,attribute6
          ,attribute7
          ,attribute8
          ,attribute9
          ,attribute10
          ,attribute11
          ,attribute12
          ,attribute13
          ,attribute14
          ,attribute15
          ,attribute_category
          ,apply_to_lower_levels_flag
          ,1
          ,p_to_ptp_id
          ,cust_account_id
          ,site_use_id
          ,duplicate_exemption
        FROM zx_exemptions
        WHERE party_tax_profile_id = p_from_ptp_id;

  IF (G_LEVEL_PROCEDURE >= G_CURRENT_RUNTIME_LEVEL ) THEN
    FND_LOG.STRING(G_LEVEL_PROCEDURE, G_MODULE_NAME||l_procedure_name,
                   SQL%ROWCOUNT||' record(s) created in ZX_Exemptions');
  END IF;

  IF (G_LEVEL_PROCEDURE >= G_CURRENT_RUNTIME_LEVEL ) THEN
    FND_LOG.STRING(G_LEVEL_PROCEDURE, G_MODULE_NAME||l_procedure_name,
                   'Merge_Site_Exemptions_Pvt(-)');
  END IF;

EXCEPTION
  WHEN OTHERS THEN
    IF (G_LEVEL_EXCEPTION >= G_CURRENT_RUNTIME_LEVEL ) THEN
      FND_LOG.STRING(G_LEVEL_EXCEPTION, G_MODULE_NAME||l_procedure_name,
                     'Merge_Site_Exemptions_Pvt(Exception)');
      FND_LOG.STRING(G_LEVEL_EXCEPTION, G_MODULE_NAME||l_procedure_name,
                     'Error : '||SQLERRM);
    END IF;
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;

END MERGE_SITE_EXEMPTIONS_PVT;

------------------------------
-- Merge Party Sites PTP
------------------------------
PROCEDURE MERGE_PARTY_SITES_PTP_PVT
    (p_from_fk_id        IN   zx_party_tax_profile.party_id%TYPE
    ,p_from_party_type   IN   zx_party_tax_profile.party_type_code%TYPE
    ,p_to_fk_id          IN   zx_party_tax_profile.party_id%TYPE
    ,p_to_party_type     IN   zx_party_tax_profile.party_type_code%TYPE
    ,x_return_status     OUT  NOCOPY VARCHAR2
  ) IS

  CURSOR c_party_type (c_party_type zx_party_tax_profile.party_type_code%TYPE) IS
    SELECT lookup_code
    FROM   fnd_lookups
    WHERE  lookup_type = 'ZX_PTP_PARTY_TYPE'
    AND    lookup_code = c_party_type
    AND    enabled_flag = 'Y'
    AND    SYSDATE BETWEEN start_date_active AND NVL(end_date_active,SYSDATE);

  CURSOR get_ptp_info
       (c_party_id   zx_party_tax_profile.party_id%TYPE,
        c_party_type zx_party_tax_profile.party_type_code%TYPE) IS
    SELECT * FROM zx_party_tax_profile
    WHERE  party_id = c_party_id
    AND    party_type_code = c_party_type;

  CURSOR get_ptp_id
       (c_party_id   zx_party_tax_profile.party_id%TYPE,
        c_party_type zx_party_tax_profile.party_type_code%TYPE) IS
    SELECT party_tax_profile_id
    FROM   zx_party_tax_profile
    WHERE  party_id = c_party_id
    AND    party_type_code = c_party_type;

  l_from_ptp_id      zx_party_tax_profile.party_id%TYPE;
  l_to_ptp_id        zx_party_tax_profile.party_id%TYPE;
  l_party_type_code  zx_party_tax_profile.party_type_code%TYPE;

  l_from_ptp_rec     zx_Party_Tax_Profile%ROWTYPE;
  l_to_ptp_rec       zx_Party_Tax_Profile%ROWTYPE;

  l_procedure_name   CONSTANT VARCHAR2(30) := '.MERGE_PARTY_SITES_PTP_PVT';

BEGIN

  G_CURRENT_RUNTIME_LEVEL := FND_LOG.G_CURRENT_RUNTIME_LEVEL;
  x_return_status         := FND_API.G_RET_STS_SUCCESS;

  IF (G_LEVEL_PROCEDURE >= G_CURRENT_RUNTIME_LEVEL ) THEN
    FND_LOG.STRING(G_LEVEL_PROCEDURE, G_MODULE_NAME||l_procedure_name,
                   'Merge_Party_Sites_PTP_Pvt(+)');
  END IF;

  ---------------------------
  -- Party Type Validation --
  ---------------------------
  OPEN c_party_type(p_from_party_type);
  FETCH c_party_type INTO l_party_type_code;
    IF c_party_type%NOTFOUND THEN
      x_return_status := FND_API.G_RET_STS_ERROR;
      CLOSE c_party_type;
      IF (G_LEVEL_EXCEPTION >= G_CURRENT_RUNTIME_LEVEL ) THEN
        FND_LOG.STRING(G_LEVEL_EXCEPTION, G_MODULE_NAME||l_procedure_name,
                       'Error : Party Type '||p_from_party_type||' is not valid');
      END IF;
      RETURN;
    END IF;
  CLOSE c_party_type;
  ---------------------------
  -- From Party Validation --
  ---------------------------
  OPEN get_ptp_info(p_from_fk_id, p_from_party_type);
  FETCH get_ptp_info INTO l_from_ptp_rec;
    IF get_ptp_info%NOTFOUND THEN
      CLOSE get_ptp_info;
      x_return_status := FND_API.G_RET_STS_ERROR;
      IF (G_LEVEL_EXCEPTION >= G_CURRENT_RUNTIME_LEVEL ) THEN
        FND_LOG.STRING(G_LEVEL_EXCEPTION, G_MODULE_NAME||l_procedure_name,
                     'Error : From Party Info not available for Party-Id '||
                      p_from_fk_id||' and Party-Type '||p_from_party_type);
      END IF;
      RETURN;
    END IF;
  CLOSE get_ptp_info;
  -------------------------
  -- To Party Validation --
  -------------------------
  OPEN get_ptp_info(p_to_fk_id, p_to_party_type);
  FETCH get_ptp_info INTO l_to_ptp_rec;
    IF get_ptp_info%FOUND THEN
      CLOSE get_ptp_info;
      x_return_status := FND_API.G_RET_STS_ERROR;
      IF (G_LEVEL_EXCEPTION >= G_CURRENT_RUNTIME_LEVEL ) THEN
        FND_LOG.STRING(G_LEVEL_EXCEPTION, G_MODULE_NAME||l_procedure_name,
                     'Error : To Party Info already available for Party-Id '||
                      p_to_fk_id||' and Party-Type '||p_to_party_type);
      END IF;
      RETURN;
    ELSIF get_ptp_info%NOTFOUND THEN
      l_to_ptp_rec := l_from_ptp_rec;
      l_to_ptp_rec.party_id := p_to_fk_id;
    END IF;
  CLOSE get_ptp_info;

  ---------------------------------------
  -- Create New PTP record for To Site --
  ---------------------------------------
  ZX_PARTY_TAX_PROFILE_PKG.INSERT_ROW
      (p_collecting_authority_flag    => l_to_ptp_rec.collecting_authority_flag
      ,p_provider_type_code           => l_to_ptp_rec.provider_type_code
      ,p_create_awt_dists_type_code   => l_to_ptp_rec.create_awt_dists_type_code
      ,p_create_awt_invoices_type_cod => l_to_ptp_rec.create_awt_invoices_type_code
      ,p_tax_classification_code      => l_to_ptp_rec.tax_classification_code
      ,p_self_assess_flag             => l_to_ptp_rec.self_assess_flag
      ,p_allow_offset_tax_flag        => l_to_ptp_rec.allow_offset_tax_flag
      ,p_rep_registration_number      => l_to_ptp_rec.rep_registration_number
      ,p_effective_from_use_le        => l_to_ptp_rec.effective_from_use_le
      ,p_record_type_code             => l_to_ptp_rec.record_type_code
      ,p_request_id                   => l_to_ptp_rec.request_id
      ,p_attribute1                   => l_to_ptp_rec.attribute1
      ,p_attribute2                   => l_to_ptp_rec.attribute2
      ,p_attribute3                   => l_to_ptp_rec.attribute3
      ,p_attribute4                   => l_to_ptp_rec.attribute4
      ,p_attribute5                   => l_to_ptp_rec.attribute5
      ,p_attribute6                   => l_to_ptp_rec.attribute6
      ,p_attribute7                   => l_to_ptp_rec.attribute7
      ,p_attribute8                   => l_to_ptp_rec.attribute8
      ,p_attribute9                   => l_to_ptp_rec.attribute9
      ,p_attribute10                  => l_to_ptp_rec.attribute10
      ,p_attribute11                  => l_to_ptp_rec.attribute11
      ,p_attribute12                  => l_to_ptp_rec.attribute12
      ,p_attribute13                  => l_to_ptp_rec.attribute13
      ,p_attribute14                  => l_to_ptp_rec.attribute14
      ,p_attribute15                  => l_to_ptp_rec.attribute15
      ,p_attribute_category           => l_to_ptp_rec.attribute_category
      ,p_party_id                     => l_to_ptp_rec.party_id
      ,p_program_login_id             => l_to_ptp_rec.program_login_id
      ,p_party_type_code              => l_to_ptp_rec.party_type_code
      ,p_supplier_flag                => l_to_ptp_rec.supplier_flag
      ,p_customer_flag                => l_to_ptp_rec.customer_flag
      ,p_site_flag                    => l_to_ptp_rec.site_flag
      ,p_process_for_applicability_fl => l_to_ptp_rec.process_for_applicability_flag
      ,p_rounding_level_code          => l_to_ptp_rec.rounding_level_code
      ,p_rounding_rule_code           => l_to_ptp_rec.rounding_rule_code
      ,p_withholding_start_date       => l_to_ptp_rec.withholding_start_date
      ,p_inclusive_tax_flag           => l_to_ptp_rec.inclusive_tax_flag
      ,p_allow_awt_flag               => l_to_ptp_rec.allow_awt_flag
      ,p_use_le_as_subscriber_flag    => l_to_ptp_rec.use_le_as_subscriber_flag
      ,p_legal_establishment_flag     => l_to_ptp_rec.legal_establishment_flag
      ,p_first_party_le_flag          => l_to_ptp_rec.first_party_le_flag
      ,p_reporting_authority_flag     => l_to_ptp_rec.reporting_authority_flag
      ,x_return_status                => x_return_status
      ,p_registration_type_code       => l_to_ptp_rec.registration_type_code
      ,p_country_code                 => l_to_ptp_rec.country_code
      );

  IF NVL(x_return_status,FND_API.G_RET_STS_SUCCESS) <> FND_API.G_RET_STS_SUCCESS THEN
    IF (G_LEVEL_PROCEDURE >= G_CURRENT_RUNTIME_LEVEL ) THEN
      FND_LOG.STRING(G_LEVEL_PROCEDURE, G_MODULE_NAME||l_procedure_name,
                     'Incorrect status retuned by ZX_Party_Tax_Profile_Pkg.Insert_Row()');
      FND_LOG.STRING(G_LEVEL_PROCEDURE, G_MODULE_NAME||l_procedure_name,
                     'Return Status = '||x_return_status);
      FND_LOG.STRING(G_LEVEL_PROCEDURE, G_MODULE_NAME||l_procedure_name,
                     'Merge_Party_Sites_PTP_Pvt(-)');
    END IF;
    RETURN;
  END IF;

  OPEN get_ptp_id (p_to_fk_id, p_to_party_type);
  FETCH get_ptp_id INTO l_to_ptp_rec.party_tax_profile_id;
  CLOSE get_ptp_id;

  IF l_to_ptp_rec.party_tax_profile_id IS NULL THEN
    IF (G_LEVEL_PROCEDURE >= G_CURRENT_RUNTIME_LEVEL ) THEN
      FND_LOG.STRING(G_LEVEL_PROCEDURE, G_MODULE_NAME||l_procedure_name,
                     'Error : Party_Tax_Profile_Id of To-Site is NULL');
    END IF;
    x_return_status := FND_API.G_RET_STS_ERROR ;
    RETURN;
  ELSE
    IF (G_LEVEL_PROCEDURE >= G_CURRENT_RUNTIME_LEVEL ) THEN
      FND_LOG.STRING(G_LEVEL_PROCEDURE, G_MODULE_NAME||l_procedure_name,
                     'Party_Tax_Profile_Id of To-Site : '||l_to_ptp_rec.party_tax_profile_id);
    END IF;
  END IF;

  UPDATE zx_party_tax_profile
  SET    merged_to_ptp_id   = l_to_ptp_rec.party_tax_profile_id,
         merged_status_code = 'MERGED',
         last_update_date   = SYSDATE,
         last_updated_by    = g_user_id,
         last_update_login  = g_login_id,
         object_version_number = object_version_number+1
  WHERE Party_Tax_Profile_id = l_from_ptp_rec.party_tax_profile_id;

  -----------------------
  -- Create registrations
  -----------------------
  MERGE_SITE_REGISTRATIONS_PVT
    (p_from_ptp_id   => l_from_ptp_rec.party_tax_profile_id
    ,p_to_ptp_id     => l_to_ptp_rec.party_tax_profile_id
    ,x_return_status => x_return_status);

  IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
    IF (G_LEVEL_PROCEDURE >= G_CURRENT_RUNTIME_LEVEL ) THEN
      FND_LOG.STRING(G_LEVEL_PROCEDURE, G_MODULE_NAME||l_procedure_name,
                     'Incorrect status retuned by Merge_Site_Registrations_Pvt()');
      FND_LOG.STRING(G_LEVEL_PROCEDURE, G_MODULE_NAME||l_procedure_name,
                     'Return Status = '||x_return_status);
      FND_LOG.STRING(G_LEVEL_PROCEDURE, G_MODULE_NAME||l_procedure_name,
                     'Merge_Party_Sites_PTP_Pvt(-)');
    END IF;
    RETURN;
  END IF;

  --------------------
  -- Create Exemptions
  --------------------
  MERGE_SITE_EXEMPTIONS_PVT
    (p_from_ptp_id   => l_from_ptp_rec.party_tax_profile_id
    ,p_to_ptp_id     => l_to_ptp_rec.party_tax_profile_id
    ,x_return_status => x_return_status);

  IF NVL(x_return_status,FND_API.G_RET_STS_SUCCESS) <> FND_API.G_RET_STS_SUCCESS THEN
    IF (G_LEVEL_PROCEDURE >= G_CURRENT_RUNTIME_LEVEL ) THEN
      FND_LOG.STRING(G_LEVEL_PROCEDURE, G_MODULE_NAME||l_procedure_name,
                     'Incorrect status retuned by Merge_Site_Exemptions_Pvt()');
      FND_LOG.STRING(G_LEVEL_PROCEDURE, G_MODULE_NAME||l_procedure_name,
                     'Return Status = '||x_return_status);
      FND_LOG.STRING(G_LEVEL_PROCEDURE, G_MODULE_NAME||l_procedure_name,
                     'Merge_Party_Sites_PTP_Pvt(-)');
    END IF;
    RETURN;
  END IF;

  IF (G_LEVEL_PROCEDURE >= G_CURRENT_RUNTIME_LEVEL ) THEN
    FND_LOG.STRING(G_LEVEL_PROCEDURE, G_MODULE_NAME||l_procedure_name,
                   'Merge_Party_Sites_PTP_Pvt(-)');
  END IF;

EXCEPTION
  WHEN OTHERS THEN
    IF c_party_type%ISOPEN THEN CLOSE c_party_type; END IF;
    IF get_ptp_info%ISOPEN THEN CLOSE get_ptp_info; END IF;
    IF get_ptp_id%ISOPEN   THEN CLOSE get_ptp_id;   END IF;

    IF (G_LEVEL_EXCEPTION >= G_CURRENT_RUNTIME_LEVEL ) THEN
      FND_LOG.STRING(G_LEVEL_EXCEPTION, G_MODULE_NAME||l_procedure_name,
                     'Merge_Party_Sites_PTP_Pvt(Exception)');
      FND_LOG.STRING(G_LEVEL_EXCEPTION, G_MODULE_NAME||l_procedure_name,
                     'Error : '||SQLERRM);
    END IF;
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;

END MERGE_PARTY_SITES_PTP_PVT;

------------------------------
-- Merge Party Sites
------------------------------
PROCEDURE MERGE_PTP_SITES (
   p_entity_name        IN     VARCHAR2,
   p_from_id            IN     NUMBER,
   p_to_id              IN OUT NOCOPY NUMBER,
   p_from_fk_id         IN     NUMBER,
   p_to_fk_id           IN     NUMBER,
   p_parent_entity_name IN     VARCHAR2,
   p_batch_id           IN     VARCHAR2,
   p_batch_party_id     IN     VARCHAR2,
   x_return_status      IN OUT NOCOPY VARCHAR2
  ) IS

  l_procedure_name CONSTANT VARCHAR2(30) := '.MERGE_PTP_SITES ';

BEGIN

  G_CURRENT_RUNTIME_LEVEL := FND_LOG.G_CURRENT_RUNTIME_LEVEL;
  x_return_status         := FND_API.G_RET_STS_SUCCESS;

  IF (G_LEVEL_PROCEDURE >= G_CURRENT_RUNTIME_LEVEL ) THEN
    FND_LOG.STRING(G_LEVEL_PROCEDURE, G_MODULE_NAME||l_procedure_name,
                   'Merge_PTP_Sites(+)');
  END IF;

  IF (G_LEVEL_PROCEDURE >= G_CURRENT_RUNTIME_LEVEL ) THEN
    FND_LOG.STRING(G_LEVEL_PROCEDURE, G_MODULE_NAME||l_procedure_name,'Input Parameters :-');
    FND_LOG.STRING(G_LEVEL_PROCEDURE, G_MODULE_NAME||l_procedure_name,'Entity_Name : '       ||p_entity_name);
    FND_LOG.STRING(G_LEVEL_PROCEDURE, G_MODULE_NAME||l_procedure_name,'From_Id : '           ||p_from_id);
    FND_LOG.STRING(G_LEVEL_PROCEDURE, G_MODULE_NAME||l_procedure_name,'From_Fk_Id : '        ||p_from_fk_id);
    FND_LOG.STRING(G_LEVEL_PROCEDURE, G_MODULE_NAME||l_procedure_name,'To_Id : '             ||p_to_id);
    FND_LOG.STRING(G_LEVEL_PROCEDURE, G_MODULE_NAME||l_procedure_name,'To_Fk_id : '          ||p_to_fk_id);
    FND_LOG.STRING(G_LEVEL_PROCEDURE, G_MODULE_NAME||l_procedure_name,'Parent_Entity_Name : '||p_parent_entity_name);
    FND_LOG.STRING(G_LEVEL_PROCEDURE, G_MODULE_NAME||l_procedure_name,'Batch_Id : '          ||p_batch_id);
    FND_LOG.STRING(G_LEVEL_PROCEDURE, G_MODULE_NAME||l_procedure_name,'Batch_Party_Id : '    ||p_batch_party_id);
  END IF;

  IF p_from_fk_id IS NULL THEN
    x_return_status := FND_API.G_RET_STS_ERROR;
    IF (G_LEVEL_PROCEDURE >= G_CURRENT_RUNTIME_LEVEL ) THEN
      FND_LOG.STRING(G_LEVEL_PROCEDURE, G_MODULE_NAME||l_procedure_name,
                     'Error : From-Party-Id is NULL');
    END IF;
    RETURN;
  END IF;

  IF p_to_fk_id IS NULL THEN
    x_return_status := FND_API.G_RET_STS_ERROR;
    IF (G_LEVEL_PROCEDURE >= G_CURRENT_RUNTIME_LEVEL ) THEN
      FND_LOG.STRING(G_LEVEL_PROCEDURE, G_MODULE_NAME||l_procedure_name,
                     'Error : To-Party-Id is NULL');
    END IF;
    RETURN;
  END IF;

  IF p_from_fk_id = p_to_fk_id THEN
    p_to_id := p_from_id;
    x_return_status := FND_API.G_RET_STS_ERROR;
    IF (G_LEVEL_PROCEDURE >= G_CURRENT_RUNTIME_LEVEL ) THEN
      FND_LOG.STRING(G_LEVEL_PROCEDURE, G_MODULE_NAME||l_procedure_name,
                     'Error : From-Party-Id and To-Party-Id are same');
    END IF;
    RETURN;
  END IF;

  MERGE_PARTY_SITES_PTP_PVT
      (p_from_fk_id        => p_from_fk_id
      ,p_from_party_type   => 'THIRD_PARTY_SITE'
      ,p_to_fk_id          => p_to_fk_id
      ,p_to_party_type     => 'THIRD_PARTY_SITE'
      ,x_return_status     => x_return_status
      );

  IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
    IF (G_LEVEL_PROCEDURE >= G_CURRENT_RUNTIME_LEVEL ) THEN
      FND_LOG.STRING(G_LEVEL_PROCEDURE, G_MODULE_NAME||l_procedure_name,
                     'Incorrect status retuned by Merge_Party_Sites_PTP_Pvt()');
      FND_LOG.STRING(G_LEVEL_PROCEDURE, G_MODULE_NAME||l_procedure_name,
                     'Return Status = '||x_return_status);
      FND_LOG.STRING(G_LEVEL_PROCEDURE, G_MODULE_NAME||l_procedure_name,
                     'Merge_PTP_Sites(-)');
    END IF;
    RETURN;
  END IF;

  IF (G_LEVEL_PROCEDURE >= G_CURRENT_RUNTIME_LEVEL ) THEN
    FND_LOG.STRING(G_LEVEL_PROCEDURE, G_MODULE_NAME||l_procedure_name,
                   'Merge_PTP_Sites(-)');
  END IF;

EXCEPTION
  WHEN OTHERS THEN
    IF (G_LEVEL_EXCEPTION >= G_CURRENT_RUNTIME_LEVEL ) THEN
      FND_LOG.STRING(G_LEVEL_EXCEPTION, G_MODULE_NAME||l_procedure_name,
                     'Merge_PTP_Sites(Exception)');
      FND_LOG.STRING(G_LEVEL_EXCEPTION, G_MODULE_NAME||l_procedure_name,
                     'Error : '||SQLERRM);
    END IF;
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
    RAISE;
END MERGE_PTP_SITES;

END ZX_PARTY_MERGE_PKG;

/
