--------------------------------------------------------
--  DDL for Package Body ZX_TAX_PARTNER_MIGRATE_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."ZX_TAX_PARTNER_MIGRATE_PKG" AS
/* $Header: zxptnrmigpkgb.pls 120.14.12010000.3 2009/05/15 06:12:52 ssohal ship $ */

G_PKG_NAME              CONSTANT VARCHAR2(30)   := 'ZX_TAX_PARTNER_MIGRATE_PKG';
G_CURRENT_RUNTIME_LEVEL CONSTANT NUMBER         := FND_LOG.G_CURRENT_RUNTIME_LEVEL;
G_LEVEL_UNEXPECTED        CONSTANT NUMBER       := FND_LOG.LEVEL_UNEXPECTED;
G_LEVEL_ERROR             CONSTANT NUMBER       := FND_LOG.LEVEL_ERROR;
G_LEVEL_EXCEPTION         CONSTANT NUMBER       := FND_LOG.LEVEL_EXCEPTION;
G_LEVEL_EVENT             CONSTANT NUMBER       := FND_LOG.LEVEL_EVENT;
G_LEVEL_PROCEDURE         CONSTANT NUMBER       := FND_LOG.LEVEL_PROCEDURE;
G_LEVEL_STATEMENT         CONSTANT NUMBER       := FND_LOG.LEVEL_STATEMENT;
G_MODULE_NAME           CONSTANT VARCHAR2(250):= 'ZX.PLSQL.ZX_TAX_PARTNER_MIGRATE_PKG.';

l_gen_party_number           VARCHAR2(1);

 PROCEDURE insert_ptp (
   p_party_id       IN NUMBER,
   p_ptp_id         IN NUMBER,
   x_return_status  OUT NOCOPY VARCHAR2
   )IS

  l_api_name  CONSTANT   VARCHAR2(30) := 'INSERT_PTP';
  l_return_status    VARCHAR2(1);

  BEGIN
    IF ( G_LEVEL_PROCEDURE >= G_CURRENT_RUNTIME_LEVEL) THEN
      FND_LOG.STRING(G_LEVEL_PROCEDURE,G_MODULE_NAME||l_api_name||'.BEGIN',G_PKG_NAME||': '||l_api_name||'()+');
    END IF;

    x_return_status := FND_API.G_RET_STS_SUCCESS;

    insert into ZX_PARTY_TAX_PROFILE (
    COLLECTING_AUTHORITY_FLAG,
    PROVIDER_TYPE_CODE,
    CREATE_AWT_DISTS_TYPE_CODE,
    CREATE_AWT_INVOICES_TYPE_CODE,
    TAX_CLASSIFICATION_CODE,
    SELF_ASSESS_FLAG,
    ALLOW_OFFSET_TAX_FLAG,
    REP_REGISTRATION_NUMBER,
    EFFECTIVE_FROM_USE_LE,
    RECORD_TYPE_CODE,
    REQUEST_ID,
    PARTY_TAX_PROFILE_ID,
    ATTRIBUTE1,
    ATTRIBUTE2,
    ATTRIBUTE3,
    ATTRIBUTE4,
    ATTRIBUTE5,
    ATTRIBUTE6,
    ATTRIBUTE7,
    ATTRIBUTE8,
    ATTRIBUTE9,
    ATTRIBUTE10,
    ATTRIBUTE11,
    ATTRIBUTE12,
    ATTRIBUTE13,
    ATTRIBUTE14,
    ATTRIBUTE15,
    ATTRIBUTE_CATEGORY,
    PARTY_ID,
    PROGRAM_LOGIN_ID,
    PARTY_TYPE_CODE,
    SUPPLIER_FLAG,
    CUSTOMER_FLAG,
    SITE_FLAG,
    PROCESS_FOR_APPLICABILITY_FLAG,
    ROUNDING_LEVEL_CODE,
    ROUNDING_RULE_CODE,
    WITHHOLDING_START_DATE,
    INCLUSIVE_TAX_FLAG,
    ALLOW_AWT_FLAG,
    USE_LE_AS_SUBSCRIBER_FLAG,
    LEGAL_ESTABLISHMENT_FLAG,
    FIRST_PARTY_LE_FLAG,
    REPORTING_AUTHORITY_FLAG,
    CREATION_DATE,
    CREATED_BY,
    LAST_UPDATE_DATE,
    LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN,
    OBJECT_VERSION_NUMBER
  ) values (
    null,
    'BOTH',
    null,
    null,
    null,
    null,
    null,
    null,
    null,
    'MIGRATED',
    null,
    p_ptp_id,
    null,
    null,
    null,
    null,
    null,
    null,
    null,
    null,
    null,
    null,
    null,
    null,
    null,
    null,
    null,
    null,
    p_party_id,
    null,
    'TAX_PARTNER',
    null,
    null,
    null,
    null,
    null,
    null,
    null,
    null,
    null,
    null,
    null,
    null,
    null,
    sysdate,
    FND_GLOBAL.User_ID,
    sysdate,
    FND_GLOBAL.User_ID,
    FND_GLOBAL.Login_ID,
    1
    );

    IF ( G_LEVEL_PROCEDURE >= G_CURRENT_RUNTIME_LEVEL) THEN
      FND_LOG.STRING(G_LEVEL_PROCEDURE,G_MODULE_NAME||l_api_name||'.END',G_PKG_NAME||': '||l_api_name||'()-');
    END IF;
    EXCEPTION
       WHEN OTHERS THEN
           FND_MESSAGE.SET_NAME ('ZX','GENERIC_MESSAGE');
           FND_MESSAGE.SET_TOKEN('GENERIC_TEXT','INSERT_PTP : '||SQLERRM);
           x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
           FND_MSG_PUB.add;
           IF ( G_LEVEL_EXCEPTION >= G_CURRENT_RUNTIME_LEVEL) THEN
              FND_LOG.STRING(G_LEVEL_EXCEPTION,G_MODULE_NAME||l_api_name,SQLERRM);
           END IF;
  END insert_ptp;


PROCEDURE CREATE_VERTEX_TCA_ZX (x_return_status OUT NOCOPY VARCHAR2) IS

  l_api_name  CONSTANT   VARCHAR2(50) := 'CREATE_VERTEX_TCA_ZX';
  p_organization_rec HZ_PARTY_V2PUB.organization_rec_type;
  p_party_rec        HZ_PARTY_V2PUB.party_rec_type;
  l_return_status    VARCHAR2(2000);
  l_msg_count        NUMBER;
  l_msg_data         VARCHAR2(2000);
  l_party_id         NUMBER;
  l_party_number     VARCHAR2(2000);
  l_profile_id       NUMBER;
  l_org_contact_id   NUMBER;
  dummy              NUMBER;
  l_exists           NUMBER;

  BEGIN
    IF ( G_LEVEL_PROCEDURE >= G_CURRENT_RUNTIME_LEVEL) THEN
      FND_LOG.STRING(G_LEVEL_PROCEDURE,G_MODULE_NAME||l_api_name||'.BEGIN',G_PKG_NAME||': '||l_api_name||'()+');
    END IF;

    x_return_status := FND_API.G_RET_STS_SUCCESS;

    SELECT 1
    INTO dummy
    FROM zx_party_tax_profile
    where party_tax_profile_id = 1;

  EXCEPTION
    WHEN NO_DATA_FOUND THEN
    -- For organization record
    p_organization_rec.organization_name := 'Vertex Inc';
    p_organization_rec.duns_number_c     := '09-685-3189';
    p_organization_rec.created_by_module := 'EBTAX_SERVICE_PROVIDER';
    p_organization_rec.application_id    := 235;


    BEGIN
      SELECT 1
        INTO dummy
	    FROM hz_parties
 	    WHERE party_number = '09-685-3189';

	   EXCEPTION WHEN NO_DATA_FOUND THEN
   	     --TCA accepts party number only if profile option is N
            NULL;
    END;

    IF nvl(dummy,0)<>1  THEN
      IF l_gen_party_number is null OR l_gen_party_number = 'Y' THEN
        /*select hz_party_number_s.nextval
        into p_organization_rec.party_rec.party_number
        from dual;
        */
        NULL;
      ELSE
         p_organization_rec.party_rec.party_number := '09-685-3189';
      END IF;


    HZ_PARTY_V2PUB.create_organization(
      p_init_msg_list    => 'T',
      p_organization_rec => p_organization_rec,
      x_return_status    => l_return_status,
      x_msg_count        => l_msg_count,
      x_msg_data         => l_msg_data,
      x_party_id         => l_party_id,
      x_party_number     => l_party_number,
      x_profile_id       => l_profile_id);

/*
    IF l_msg_count > 1 THEN
      FOR i IN 1..l_msg_count LOOP
         dbms_output.put_line(FND_MSG_PUB.Get( p_encoded => FND_API.G_FALSE ));
      END LOOP;
    END IF;
    */
    IF l_return_status = FND_API.G_RET_STS_SUCCESS THEN
      /*Insert into zx_party_tax_profile*/
       insert_ptp (p_party_id         => l_party_id,
                   p_ptp_id           => 1,
                   x_return_status    => l_return_status
                  );
    END IF;

  END IF;
    IF ( G_LEVEL_PROCEDURE >= G_CURRENT_RUNTIME_LEVEL) THEN
      FND_LOG.STRING(G_LEVEL_PROCEDURE,G_MODULE_NAME||l_api_name||'.END',G_PKG_NAME||': '||l_api_name||'()-');
    END IF;
END CREATE_VERTEX_TCA_ZX;

 PROCEDURE  CREATE_TAXWARE_TCA_ZX(x_return_status OUT NOCOPY VARCHAR2) IS

  l_api_name  CONSTANT   VARCHAR2(50) := 'CREATE_TAXWARE_TCA_ZX';
  p_organization_rec HZ_PARTY_V2PUB.organization_rec_type;
  p_party_rec        HZ_PARTY_V2PUB.party_rec_type;
  l_return_status    VARCHAR2(2000);
  l_msg_count        NUMBER;
  l_msg_data         VARCHAR2(2000);
  l_party_id         NUMBER;
  l_party_number     VARCHAR2(2000);
  l_profile_id       NUMBER;
  l_org_contact_id   NUMBER;
  dummy              NUMBER;
  l_exists           NUMBER;

  BEGIN
    IF ( G_LEVEL_PROCEDURE >= G_CURRENT_RUNTIME_LEVEL) THEN
      FND_LOG.STRING(G_LEVEL_PROCEDURE,G_MODULE_NAME||l_api_name||'.BEGIN',G_PKG_NAME||': '||l_api_name||'()+');
    END IF;

    x_return_status := FND_API.G_RET_STS_SUCCESS;

    SELECT 1
    INTO dummy
    FROM zx_party_tax_profile
    where party_tax_profile_id = 2;

  EXCEPTION
    WHEN NO_DATA_FOUND THEN
    -- For organization record
    p_organization_rec.organization_name := 'ADP Inc.';
    p_organization_rec.duns_number_c     := '13-583-0177';
    p_organization_rec.created_by_module := 'EBTAX_SERVICE_PROVIDER';
    p_organization_rec.application_id    := 235;

    BEGIN
      SELECT 1
        INTO dummy
	FROM hz_parties
 	WHERE party_number = '13-583-0177';

	EXCEPTION WHEN NO_DATA_FOUND THEN
	   --TCA accepts party number only if profile option is N
         NULL;
    END;

    IF nvl(dummy,0)<>1  THEN
      IF l_gen_party_number is null OR l_gen_party_number = 'Y' THEN
         NULL;
         /*
          select hz_party_number_s.nextval
            into p_organization_rec.party_rec.party_number
            from dual;
         */
      ELSE
         p_organization_rec.party_rec.party_number := '13-583-0177';
      END IF;

    HZ_PARTY_V2PUB.create_organization(
      p_init_msg_list    => 'T',
      p_organization_rec => p_organization_rec,
      x_return_status    => l_return_status,
      x_msg_count        => l_msg_count,
      x_msg_data         => l_msg_data,
      x_party_id         => l_party_id,
      x_party_number     => l_party_number,
      x_profile_id       => l_profile_id);

     /*dbms_output.put_line(SubStr('x_return_status = '||l_return_status,1,255));
     dbms_output.put_line(SubStr('x_msg_count = '||TO_CHAR(l_msg_count), 1, 255));
     dbms_output.put_line(SubStr('x_msg_data = '||l_msg_data,1,255));
     */
     IF l_return_status = FND_API.G_RET_STS_SUCCESS THEN
      /*Insert into zx_party_tax_profile*/
      insert_ptp (p_party_id         => l_party_id,
                  p_ptp_id           => 2,
                  x_return_status    => l_return_status
                  );
    END IF;

    IF ( G_LEVEL_PROCEDURE >= G_CURRENT_RUNTIME_LEVEL) THEN
      FND_LOG.STRING(G_LEVEL_PROCEDURE,G_MODULE_NAME||l_api_name||'.END',G_PKG_NAME||': '||l_api_name||'()-');
    END IF;
  END IF;
 END  CREATE_TAXWARE_TCA_ZX;

 PROCEDURE  CREATE_OTHERS_TCA_ZX(x_return_status OUT NOCOPY VARCHAR2) IS

  l_api_name  CONSTANT   VARCHAR2(50) := 'CREATE_OTHERS_TCA_ZX';
  p_organization_rec HZ_PARTY_V2PUB.organization_rec_type;
  p_party_rec        HZ_PARTY_V2PUB.party_rec_type;
  l_return_status    VARCHAR2(2000);
  l_msg_count        NUMBER;
  l_msg_data         VARCHAR2(2000);
  l_party_id         NUMBER;
  l_party_number     VARCHAR2(2000);
  l_profile_id       NUMBER;
  l_org_contact_id   NUMBER;
  dummy              NUMBER;
  l_exists           NUMBER;

  BEGIN
    IF ( G_LEVEL_PROCEDURE >= G_CURRENT_RUNTIME_LEVEL) THEN
      FND_LOG.STRING(G_LEVEL_PROCEDURE,G_MODULE_NAME||l_api_name||'.BEGIN',G_PKG_NAME||': '||l_api_name||'()+');
    END IF;

    x_return_status := FND_API.G_RET_STS_SUCCESS;

    SELECT 1
    INTO dummy
    FROM zx_party_tax_profile
    where party_tax_profile_id = 3;

  EXCEPTION
    WHEN NO_DATA_FOUND THEN
    -- For organization record
    p_organization_rec.organization_name := 'Other Tax Partner';
    p_organization_rec.duns_number_c     := '';
    p_organization_rec.created_by_module := 'EBTAX_SERVICE_PROVIDER';
    p_organization_rec.application_id    := 235;

    BEGIN
      SELECT 1
        INTO dummy
	FROM hz_parties
 	WHERE party_number = '';

	EXCEPTION WHEN NO_DATA_FOUND THEN
	   --TCA accepts party number only if profile option is N
         NULL;
    END;

    IF nvl(dummy,0)<>1  THEN
      IF l_gen_party_number is null OR l_gen_party_number = 'Y' THEN
         NULL;
      ELSE
         p_organization_rec.party_rec.party_number := '';
      END IF;

    HZ_PARTY_V2PUB.create_organization(
      p_init_msg_list    => 'T',
      p_organization_rec => p_organization_rec,
      x_return_status    => l_return_status,
      x_msg_count        => l_msg_count,
      x_msg_data         => l_msg_data,
      x_party_id         => l_party_id,
      x_party_number     => l_party_number,
      x_profile_id       => l_profile_id);

     IF l_return_status = FND_API.G_RET_STS_SUCCESS THEN
      /*Insert into zx_party_tax_profile*/
      insert_ptp (p_party_id         => l_party_id,
                  p_ptp_id           => 3,
                  x_return_status    => l_return_status
                  );
    END IF;

    IF ( G_LEVEL_PROCEDURE >= G_CURRENT_RUNTIME_LEVEL) THEN
      FND_LOG.STRING(G_LEVEL_PROCEDURE,G_MODULE_NAME||l_api_name||'.END',G_PKG_NAME||': '||l_api_name||'()-');
    END IF;
  END IF;
 END  CREATE_OTHERS_TCA_ZX;

PROCEDURE  MIGRATE_TAX_PARTNER (x_return_status OUT NOCOPY VARCHAR2) IS
  l_api_name       CONSTANT    VARCHAR2(30) := 'MIGRATE_TAX_PARTNER';
  l_return_status              VARCHAR2(1);
  l_dss_enabled                VARCHAR2(5);

  BEGIN
    IF ( G_LEVEL_PROCEDURE >= G_CURRENT_RUNTIME_LEVEL) THEN
      FND_LOG.STRING(G_LEVEL_PROCEDURE,G_MODULE_NAME||l_api_name||'.BEGIN',G_PKG_NAME||': '||l_api_name||'()+');
    END IF;

    x_return_status := FND_API.G_RET_STS_SUCCESS;

    --Get the profile value to determine if need to pass the party number
    fnd_profile.get('HZ_GENERATE_PARTY_NUMBER', l_gen_party_number);
    l_dss_enabled := fnd_profile.value('HZ_DSS_ENABLED');
    fnd_profile.put('HZ_DSS_ENABLED','N');

    /*Create Vertex as TCA party*/
    CREATE_VERTEX_TCA_ZX (x_return_status);
    IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
      x_return_status := FND_API.G_RET_STS_ERROR ;
      FND_MESSAGE.SET_NAME ('ZX','GENERIC_MESSAGE');
      FND_MESSAGE.SET_TOKEN ('GENERIC_TEXT','Creating Vertex as Organization Party in TCA and PTP in eBTax : '||SQLERRM);
      FND_MSG_PUB.Add;
    END IF;

    /*Create Taxware as TCA party*/
    CREATE_TAXWARE_TCA_ZX (l_return_status);
    IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
      x_return_status := FND_API.G_RET_STS_ERROR ;
      FND_MESSAGE.SET_NAME ('ZX','GENERIC_MESSAGE');
      FND_MESSAGE.SET_TOKEN ('GENERIC_TEXT','Creating Taxware as Organization Party in TCA and PTP in eBTax: '||SQLERRM);
      FND_MSG_PUB.Add;
    END IF;

    /*Create Others as TCA party*/
    CREATE_OTHERS_TCA_ZX (l_return_status);
    IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
      x_return_status := FND_API.G_RET_STS_ERROR ;
      FND_MESSAGE.SET_NAME ('ZX','GENERIC_MESSAGE');
      FND_MESSAGE.SET_TOKEN ('GENERIC_TEXT','Creating Other Tax Partner as Organization Party in TCA and PTP in eBTax: '||SQLERRM);
      FND_MSG_PUB.Add;
    END IF;

    fnd_profile.put('HZ_DSS_ENABLED',l_dss_enabled);
    IF ( G_LEVEL_PROCEDURE >= G_CURRENT_RUNTIME_LEVEL) THEN
      FND_LOG.STRING(G_LEVEL_PROCEDURE,G_MODULE_NAME||l_api_name||'.END',G_PKG_NAME||': '||l_api_name||'()-');
    END IF;

 END   MIGRATE_TAX_PARTNER;
END ZX_TAX_PARTNER_MIGRATE_PKG;



/
