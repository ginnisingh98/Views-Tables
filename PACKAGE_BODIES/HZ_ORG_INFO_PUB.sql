--------------------------------------------------------
--  DDL for Package Body HZ_ORG_INFO_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."HZ_ORG_INFO_PUB" as
/* $Header: ARHORISB.pls 120.11 2005/12/07 19:32:52 acng ship $ */

G_PKG_NAME CONSTANT VARCHAR2(30) :=  'HZ_ORG_INFO_PUB';

-- Bug 2197181: added for mix-n-match project.

g_fin_mixnmatch_enabled                VARCHAR2(1);
g_fin_selected_datasources             VARCHAR2(255);
g_fin_is_datasource_selected           VARCHAR2(1) := 'N';
g_fin_entity_attr_id                   NUMBER;

/*===========================================================================+
 | PROCEDURE
 |              do_create_stock_markets
 |
 | DESCRIPTION
 |              Creates stock markets.
 |
 | SCOPE - PRIVATE
 |
 | EXETERNAL PROCEDURES/FUNCTIONS ACCESSED
 |
 | ARGUMENTS  : IN:
 |              OUT:
 |                    x_stock_exchange_id
 |          IN/ OUT:
 |                    p_stock_markets_rec
 |                    x_return_status
 |
 | RETURNS    : NONE
 |
 | NOTES
 |
 | MODIFICATION HISTORY
 |    Jianying Huang 06-OCT-00  Bug 1428526: make *_rec parameters as
 |                      'IN OUT' in order to pass the changed record
 |                      to caller.
 |
 |     16-MAR-01  Suresh P   Bug No :1478910 Added the status column in
 |                 HZ_CERTIFICATIONS_PKG.INSERT_ROW(),HZ_CERTIFICATION_PKG.UPDATE_ROW(),
 |                 HZ_FINANCIAL_REPORTS_PKG.INSERT_ROW(),HZ_FINANCIAL_REPORTS_PKG.UPDATE_ROW(),
 |                 HZ_FINANCIAL_NUMBER_PKG.INSERT_ROW(),HZ_FINANCIAL_NUMBER_PKG.UPDATE_ROW(),
 |                 HZ_INDUSTRIAL_REFERENCE_PKG.INSERT_ROW(),HZ_INDUSTRIAL_REFERENCE_PKG.UPDATE_ROW,
 |                 HZ_SECURITY_ISSUED_PKG.INSERT_ROW(),HZ_SECURITY_ISSUED_PKG.UPDATE_ROW.
 +===========================================================================*/

procedure do_create_stock_markets(
        p_stock_markets_rec      IN OUT  NOCOPY stock_markets_rec_type,
        x_stock_exchange_id      OUT     NOCOPY NUMBER,
        x_return_status          IN OUT  NOCOPY VARCHAR2
) IS
        l_stock_exchange_id      NUMBER := p_stock_markets_rec.stock_exchange_id;
        l_rowid                  ROWID := NULL;
        l_count                  NUMBER;
BEGIN
   -- if l_stock_exchange_id is NULL, then generate PK.
   IF l_stock_exchange_id is NULL  OR
      l_stock_exchange_id = FND_API.G_MISS_NUM  THEN
     l_count := 1;

     WHILE l_count >0 LOOP
       SELECT hz_stock_markets_s.nextval
       INTO l_stock_exchange_id from dual;

       SELECT count(*)
       INTO l_count
       FROM HZ_STOCK_MARKETS
       WHERE stock_exchange_id  = l_stock_exchange_id;
     END LOOP;

   ELSE
     l_count := 0;

     SELECT count(*)
     INTO l_count
     FROM HZ_STOCK_MARKETS
     WHERE stock_exchange_id = l_stock_exchange_id;

     if  l_count > 0 THEN
       FND_MESSAGE.SET_NAME('AR', 'HZ_API_DUPLICATE_COLUMN');
       FND_MESSAGE.SET_TOKEN('COLUMN', 'stock_exchange_id');
       FND_MSG_PUB.ADD;
       RAISE FND_API.G_EXC_ERROR;
      end if;

    END IF;

    x_stock_exchange_id := l_stock_exchange_id;

    -- validate stock market record
    HZ_ORG_INFO_VALIDATE.validate_stock_markets(p_stock_markets_rec,'C',
                                                x_return_status);

    IF x_return_status = FND_API.G_RET_STS_ERROR THEN
                RAISE FND_API.G_EXC_ERROR;
    END IF;

-- Bug 1428526: Should pass updated stock market info. to caller.
-- Make sure to use values in p_stock_markets_rec.* when calling insert table
-- handler. Need to update p_stock_markets_rec first.
    p_stock_markets_rec.stock_exchange_id := l_stock_exchange_id;

    -- call table handler to insert a row
    HZ_STOCK_MARKETS_PKG.INSERT_ROW(
      X_Rowid => l_rowid,
      X_STOCK_EXCHANGE_ID => p_stock_markets_rec.stock_exchange_id,
      X_COUNTRY_OF_RESIDENCE => p_stock_markets_rec.COUNTRY_OF_RESIDENCE,
      X_STOCK_EXCHANGE_CODE => p_stock_markets_rec.STOCK_EXCHANGE_CODE,
      X_STOCK_EXCHANGE_NAME => p_stock_markets_rec.STOCK_EXCHANGE_NAME,
      X_CREATED_BY => hz_utility_pub.CREATED_BY,
      X_CREATION_DATE => hz_utility_pub.CREATION_DATE,
      X_LAST_UPDATE_LOGIN => hz_utility_pub.LAST_UPDATE_LOGIN,
      X_LAST_UPDATE_DATE => hz_utility_pub.LAST_UPDATE_DATE,
      X_LAST_UPDATED_BY => hz_utility_pub.LAST_UPDATED_BY,
      X_REQUEST_ID => hz_utility_pub.REQUEST_ID,
      X_PROGRAM_APPLICATION_ID => hz_utility_pub.PROGRAM_APPLICATION_ID,
      X_PROGRAM_ID => hz_utility_pub.PROGRAM_ID,
      X_PROGRAM_UPDATE_DATE => hz_utility_pub.PROGRAM_UPDATE_DATE,
      X_WH_UPDATE_DATE => p_stock_markets_rec.WH_UPDATE_DATE
     );

END do_create_stock_markets;

/*===========================================================================+
 | PROCEDURE
 |              do_update_stock_markets
 |
 | DESCRIPTION
 |              Updates stock markets.
 |
 | SCOPE - PRIVATE
 |
 | EXETERNAL PROCEDURES/FUNCTIONS ACCESSED
 |
 | ARGUMENTS  : IN:
 |              OUT:
 |          IN/ OUT:
 |                    p_stock_markets_rec
 |                    p_last_update_date
 |                    x_return_status
 |
 | RETURNS    : NONE
 |
 | NOTES
 |
 | MODIFICATION HISTORY
 |    Jianying Huang 06-OCT-00  Bug 1428526: make *_rec parameters as
 |                      'IN OUT' in order to pass the changed record
 |                      to caller.
 |
 +===========================================================================*/

procedure do_update_stock_markets(
        p_stock_markets_rec       IN OUT  NOCOPY stock_markets_rec_type,
        p_last_update_date        IN OUT  NOCOPY DATE,
        x_return_status           IN OUT  NOCOPY VARCHAR2
) IS
        l_count                   NUMBER;
        l_rowid                   ROWID := NULL;
        l_last_update_date        DATE;
BEGIN
     -- check primary key
     IF p_stock_markets_rec.stock_exchange_id is NULL  OR
        p_stock_markets_rec.stock_exchange_id = FND_API.G_MISS_NUM  THEN
          FND_MESSAGE.SET_NAME('AR', 'HZ_API_MISSING_COLUMN');
          FND_MESSAGE.SET_TOKEN('COLUMN', 'stock_exchange_id');
          FND_MSG_PUB.ADD;
          RAISE FND_API.G_EXC_ERROR;
     END IF;

     -- check last_update_date
     IF p_last_update_date is NULL  OR
        p_last_update_date = FND_API.G_MISS_DATE  THEN
          FND_MESSAGE.SET_NAME('AR', 'HZ_API_MISSING_COLUMN');
          FND_MESSAGE.SET_TOKEN('COLUMN', 'last_update_date');
          FND_MSG_PUB.ADD;
          RAISE FND_API.G_EXC_ERROR;
     END IF;

     -- select rowid , last_update_date for lock a row

begin
     SELECT rowid, last_update_date
     INTO l_rowid, l_last_update_date
     FROM HZ_STOCK_MARKETS
     WHERE stock_exchange_id = p_stock_markets_rec.stock_exchange_id
     AND to_char(last_update_date, 'DD-MON-YYYY HH:MI:SS') =
     to_char(p_last_update_date, 'DD-MON-YYYY HH:MI:SS')
     FOR UPDATE NOWAIT;

     EXCEPTION WHEN NO_DATA_FOUND THEN
     FND_MESSAGE.SET_NAME('AR', 'HZ_API_RECORD_CHANGED');
     FND_MESSAGE.SET_TOKEN('TABLE', 'HZ_STOCK_MARKETS');
     FND_MSG_PUB.ADD;
     RAISE FND_API.G_EXC_ERROR;
end;

        -- validate stock market record
        HZ_ORG_INFO_VALIDATE.validate_stock_markets(p_stock_markets_rec,'U',
                                                    x_return_status);

        IF x_return_status = FND_API.G_RET_STS_ERROR THEN
                RAISE FND_API.G_EXC_ERROR;
        END IF;

        -- pass back last update date
        p_last_update_date := hz_utility_pub.LAST_UPDATE_DATE;

-- Bug 1428526: Should pass updated stock market info. to caller.
-- Make sure to use values in p_stock_markets_rec.* when calling update table
-- handler. Need to update p_stock_markets_rec first.
      NULL;

      -- call table handler to update a row
      HZ_STOCK_MARKETS_PKG.UPDATE_ROW(
        X_Rowid => l_rowid,
        X_STOCK_EXCHANGE_ID => p_stock_markets_rec.STOCK_EXCHANGE_ID,
        X_COUNTRY_OF_RESIDENCE => p_stock_markets_rec.COUNTRY_OF_RESIDENCE,
        X_STOCK_EXCHANGE_CODE => p_stock_markets_rec.STOCK_EXCHANGE_CODE,
        X_STOCK_EXCHANGE_NAME => p_stock_markets_rec.STOCK_EXCHANGE_NAME,
        X_CREATED_BY => FND_API.G_MISS_NUM,
        X_CREATION_DATE => FND_API.G_MISS_DATE,
        X_LAST_UPDATE_LOGIN => hz_utility_pub.LAST_UPDATE_LOGIN,
        X_LAST_UPDATE_DATE => p_last_update_date,
        X_LAST_UPDATED_BY => hz_utility_pub.LAST_UPDATED_BY,
        X_REQUEST_ID => hz_utility_pub.REQUEST_ID,
        X_PROGRAM_APPLICATION_ID => hz_utility_pub.PROGRAM_APPLICATION_ID,
        X_PROGRAM_ID => hz_utility_pub.PROGRAM_ID,
        X_PROGRAM_UPDATE_DATE => hz_utility_pub.PROGRAM_UPDATE_DATE,
        X_WH_UPDATE_DATE => p_stock_markets_rec.WH_UPDATE_DATE
       );

END do_update_stock_markets;

/*===========================================================================+
 | PROCEDURE
 |              do_create_security_issued
 |
 | DESCRIPTION
 |              Creates security issued.
 |
 | SCOPE - PRIVATE
 |
 | EXETERNAL PROCEDURES/FUNCTIONS ACCESSED
 |
 | ARGUMENTS  : IN:
 |              OUT:
 |                    x_security_issued_id
 |          IN/ OUT:
 |                    p_security_issued_rec
 |                    x_return_status
 |
 | RETURNS    : NONE
 |
 | NOTES
 |
 | MODIFICATION HISTORY
 |    Jianying Huang 06-OCT-00  Bug 1428526: make *_rec parameters as
 |                      'IN OUT' in order to pass the changed record
 |                      to caller.
 |
 +===========================================================================*/

procedure do_create_security_issued(
        p_security_issued_rec      IN OUT  NOCOPY security_issued_rec_type,
        x_security_issued_id       OUT     NOCOPY NUMBER,
        x_return_status            IN OUT  NOCOPY VARCHAR2
) IS
        l_security_issued_id       NUMBER := p_security_issued_rec.security_issued_id;
        l_count                    NUMBER ;
        l_rowid                    ROWID  := NULL;
BEGIN
   -- if l_security_issued_id NULL, generate primary key.
   IF l_security_issued_id is NULL  OR
      l_security_issued_id = FND_API.G_MISS_NUM  THEN
        l_count := 1;

        WHILE l_count > 0 LOOP
          SELECT hz_security_issued_s.nextval
          INTO l_security_issued_id  from DUAL;

          SELECT count(*)
          INTO l_count
          FROM HZ_SECURITY_ISSUED
          WHERE security_issued_id = l_security_issued_id;
       END LOOP;

    ELSE
      l_count := 0;

      SELECT count(*)
      INTO  l_count
      FROM HZ_SECURITY_ISSUED
      WHERE security_issued_id = l_security_issued_id;

       if  l_count > 0 THEN
       FND_MESSAGE.SET_NAME('AR', 'HZ_API_DUPLICATE_COLUMN');
       FND_MESSAGE.SET_TOKEN('COLUMN', 'security_issued_id');
       FND_MSG_PUB.ADD;
       RAISE FND_API.G_EXC_ERROR;
      end if;

    END IF;

    x_security_issued_id := l_security_issued_id;

     -- validate security issued record
    HZ_ORG_INFO_VALIDATE.validate_security_issued(p_security_issued_rec,'C',
                                                  x_return_status );
    IF x_return_status = FND_API.G_RET_STS_ERROR THEN
                RAISE FND_API.G_EXC_ERROR;
    END IF;

-- Bug 1428526: Should pass updated security issued info. to caller.
-- Make sure to use values in p_security_issued_rec.* when calling insert table
-- handler. Need to update p_security_issued_rec first.
    p_security_issued_rec.security_issued_id := l_security_issued_id;
    -- call table handler to insert a row
    HZ_SECURITY_ISSUED_PKG.INSERT_ROW(
      X_Rowid => l_rowid,
      X_SECURITY_ISSUED_ID => p_security_issued_rec.security_issued_id,
      X_ESTIMATED_TOTAL_AMOUNT => p_security_issued_rec.ESTIMATED_TOTAL_AMOUNT,
      X_PARTY_ID => p_security_issued_rec.PARTY_ID,
      X_STOCK_EXCHANGE_ID => p_security_issued_rec.STOCK_EXCHANGE_ID,
      X_SECURITY_ISSUED_CLASS => p_security_issued_rec.SECURITY_ISSUED_CLASS,
      X_SECURITY_ISSUED_NAME => p_security_issued_rec.SECURITY_ISSUED_NAME,
      X_TOTAL_AMOUNT_IN_A_CURRENCY => p_security_issued_rec.TOTAL_AMOUNT_IN_A_CURRENCY,
      X_STOCK_TICKER_SYMBOL => p_security_issued_rec.STOCK_TICKER_SYMBOL,
      X_SECURITY_CURRENCY_CODE => p_security_issued_rec.SECURITY_CURRENCY_CODE,
      X_BEGIN_DATE => p_security_issued_rec.BEGIN_DATE,
      X_END_DATE => p_security_issued_rec.END_DATE,
      X_CREATED_BY => hz_utility_pub.CREATED_BY,
      X_CREATION_DATE => hz_utility_pub.CREATION_DATE,
      X_LAST_UPDATE_LOGIN => hz_utility_pub.LAST_UPDATE_LOGIN,
      X_LAST_UPDATE_DATE => hz_utility_pub.LAST_UPDATE_DATE,
      X_LAST_UPDATED_BY => hz_utility_pub.LAST_UPDATED_BY,
      X_REQUEST_ID => hz_utility_pub.REQUEST_ID,
      X_PROGRAM_APPLICATION_ID => hz_utility_pub.PROGRAM_APPLICATION_ID,
      X_PROGRAM_ID => hz_utility_pub.PROGRAM_ID,
      X_PROGRAM_UPDATE_DATE => hz_utility_pub.PROGRAM_UPDATE_DATE,
      X_WH_UPDATE_DATE => p_security_issued_rec.WH_UPDATE_DATE,
      X_STATUS        =>p_security_issued_rec.STATUS
     );

END do_create_security_issued;

/*===========================================================================+
 | PROCEDURE
 |              do_update_security_issued
 |
 | DESCRIPTION
 |              Updates security issued.
 |
 | SCOPE - PRIVATE
 |
 | EXETERNAL PROCEDURES/FUNCTIONS ACCESSED
 |
 | ARGUMENTS  : IN:
 |              OUT:
 |          IN/ OUT:
 |                    p_security_issued_rec
 |                    p_last_update_date
 |                    x_return_status
 |
 | RETURNS    : NONE
 |
 | NOTES
 |
 | MODIFICATION HISTORY
 |    Jianying Huang 06-OCT-00  Bug 1428526: make *_rec parameters as
 |                      'IN OUT' in order to pass the changed record
 |                      to caller.
 |
 +===========================================================================*/

procedure do_update_security_issued(
        p_security_issued_rec   IN OUT  NOCOPY security_issued_rec_type,
        p_last_update_date      IN OUT  NOCOPY DATE,
        x_return_status         IN OUT  NOCOPY VARCHAR2
) IS
        l_last_update_date      DATE;
        l_count                 NUMBER;
        l_rowid                 ROWID := NULL;
BEGIN

   -- check required field:
   IF p_security_issued_rec.security_issued_id is NULL  OR
      p_security_issued_rec.security_issued_id = FND_API.G_MISS_NUM  THEN

        FND_MESSAGE.SET_NAME('AR', 'HZ_API_MISSING_COLUMN');
        FND_MESSAGE.SET_TOKEN('COLUMN', 'security_issued_id');
        FND_MSG_PUB.ADD;
        RAISE FND_API.G_EXC_ERROR;

   END IF;

        IF p_last_update_date IS NULL OR
           p_last_update_date = FND_API.G_MISS_DATE
        THEN
                FND_MESSAGE.SET_NAME('AR', 'HZ_API_MISSING_COLUMN');
                FND_MESSAGE.SET_TOKEN('COLUMN', 'p_last_update_date');
                FND_MSG_PUB.ADD;
                RAISE FND_API.G_EXC_ERROR;
        END IF;
begin
        -- check last update date.
        SELECT rowid, last_update_date
        INTO l_rowid, l_last_update_date
        FROM HZ_SECURITY_ISSUED
        where security_issued_id
              = p_security_issued_rec.security_issued_id
        AND to_char(last_update_date, 'DD-MON-YYYY HH:MI:SS') =
            to_char(p_last_update_date, 'DD-MON-YYYY HH:MI:SS')
        FOR UPDATE NOWAIT;

        EXCEPTION WHEN NO_DATA_FOUND THEN
        FND_MESSAGE.SET_NAME('AR', 'HZ_API_RECORD_CHANGED');
        FND_MESSAGE.SET_TOKEN('TABLE', 'HZ_SECURITY_ISSUED');
        FND_MSG_PUB.ADD;
        RAISE FND_API.G_EXC_ERROR;
end;

        -- validate security issued record
        HZ_ORG_INFO_VALIDATE.validate_security_issued(p_security_issued_rec,'U',
                                                      x_return_status);

        IF x_return_status = FND_API.G_RET_STS_ERROR THEN
                RAISE FND_API.G_EXC_ERROR;
        END IF;

        -- pass back last_update_date
        p_last_update_date := hz_utility_pub.LAST_UPDATE_DATE;

-- Bug 1428526: Should pass updated security issued info. to caller.
-- Make sure to use values in p_security_issued_rec.* when calling update table
-- handler. Need to update p_security_issued_rec first.
      NULL;

      -- call table handler to update a row
      HZ_SECURITY_ISSUED_PKG.UPDATE_ROW(
        X_Rowid => l_rowid,
        X_SECURITY_ISSUED_ID => p_security_issued_rec.SECURITY_ISSUED_ID,
        X_ESTIMATED_TOTAL_AMOUNT => p_security_issued_rec.ESTIMATED_TOTAL_AMOUNT,
        X_PARTY_ID => p_security_issued_rec.PARTY_ID,
        X_STOCK_EXCHANGE_ID => p_security_issued_rec.STOCK_EXCHANGE_ID,
        X_SECURITY_ISSUED_CLASS => p_security_issued_rec.SECURITY_ISSUED_CLASS,
        X_SECURITY_ISSUED_NAME => p_security_issued_rec.SECURITY_ISSUED_NAME,
        X_TOTAL_AMOUNT_IN_A_CURRENCY => p_security_issued_rec.TOTAL_AMOUNT_IN_A_CURRENCY,
        X_STOCK_TICKER_SYMBOL => p_security_issued_rec.STOCK_TICKER_SYMBOL,
        X_SECURITY_CURRENCY_CODE => p_security_issued_rec.SECURITY_CURRENCY_CODE,
        X_BEGIN_DATE => p_security_issued_rec.BEGIN_DATE,
        X_END_DATE => p_security_issued_rec.END_DATE,
        X_CREATED_BY => FND_API.G_MISS_NUM,
        X_CREATION_DATE => FND_API.G_MISS_DATE,
        X_LAST_UPDATE_LOGIN => hz_utility_pub.LAST_UPDATE_LOGIN,
        X_LAST_UPDATE_DATE => p_last_update_date,
        X_LAST_UPDATED_BY => hz_utility_pub.LAST_UPDATED_BY,
        X_REQUEST_ID => hz_utility_pub.REQUEST_ID,
        X_PROGRAM_APPLICATION_ID => hz_utility_pub.PROGRAM_APPLICATION_ID,
        X_PROGRAM_ID => hz_utility_pub.PROGRAM_ID,
        X_PROGRAM_UPDATE_DATE => hz_utility_pub.PROGRAM_UPDATE_DATE,
        X_WH_UPDATE_DATE => p_security_issued_rec.WH_UPDATE_DATE,
        X_STATUS        => p_security_issued_rec.STATUS
       );

END do_update_security_issued;

/*===========================================================================+
 | PROCEDURE
 |              do_create_financial_reports
 |
 | DESCRIPTION
 |              Creates financial reports.
 |
 | SCOPE - PRIVATE
 |
 | EXETERNAL PROCEDURES/FUNCTIONS ACCESSED
 |
 | ARGUMENTS  : IN:
 |              OUT:
 |                    x_financial_report_id
 |          IN/ OUT:
 |                    p_financial_reports_rec
 |                    x_return_status
 |
 | RETURNS    : NONE
 |
 | NOTES
 |
 | MODIFICATION HISTORY
 |    Jianying Huang 06-OCT-00  Bug 1428526: make *_rec parameters as
 |                      'IN OUT' in order to pass the changed record
 |                      to caller.
 |    01-03-2005  Rajib Ranjan Borah   o SSM SST Integration and Extension.
 |                                       For non-profile entities, the concept of
 |                                       select/de-select data-sources is obsoleted.
 +===========================================================================*/

procedure do_create_financial_reports(
    p_financial_reports_rec         IN OUT NOCOPY financial_reports_rec_type,
    x_financial_report_id           OUT    NOCOPY NUMBER,
    x_return_status                 IN OUT NOCOPY VARCHAR2
) IS

    l_financial_report_id           NUMBER := p_financial_reports_rec.financial_report_id;
    l_rowid                         ROWID := NULL;
    l_count                         NUMBER;
    x_msg_count                     NUMBER;
    x_msg_data                      VARCHAR2(2000);

BEGIN

/*
    --Call to User-Hook pre Processing Procedure
    --Bug 1363124: validation#3 of content_source_type

    IF  fnd_profile.value('HZ_EXECUTE_API_CALLOUTS') = 'Y' AND
        -- Bug 2197181: Modifed the condition
        g_fin_is_datasource_selected = 'Y'
    THEN
      hz_org_info_crmhk.create_financial_reports_pre(
        p_financial_reports_rec,
        x_return_status,
        x_msg_count,
        x_msg_data);

      IF x_return_status = FND_API.G_RET_STS_ERROR THEN
        RAISE FND_API.G_EXC_ERROR;
      ELSIF x_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
        FND_MESSAGE.SET_NAME('AR', 'HZ_API_HOOK_ERROR');
        FND_MESSAGE.SET_TOKEN('PROCEDURE',
                              'HZ_ORG_INFO_CRMHK.CREATE_FINANCIAL_REPORTS_PRE');
        FND_MESSAGE.SET_TOKEN('ERROR' ,SQLERRM);
        FND_MSG_PUB.ADD;
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
      END IF;
    END IF;
*/

    -- if l_financial_report_id is NULL, then generate PK.
    IF l_financial_report_id is NULL  OR
       l_financial_report_id = FND_API.G_MISS_NUM
    THEN
      l_count := 1;

      WHILE l_count >0 LOOP
        SELECT hz_financial_reports_s.nextval
        INTO l_financial_report_id from dual;

        SELECT count(*)
        INTO l_count
        FROM HZ_FINANCIAL_REPORTS
        WHERE financial_report_id = l_financial_report_id;
      END LOOP;
    ELSE
      l_count := 0;

      SELECT count(*)
      INTO l_count
      FROM HZ_FINANCIAL_REPORTS
      WHERE financial_report_id = l_financial_report_id;

      IF  l_count > 0 THEN
       FND_MESSAGE.SET_NAME('AR', 'HZ_API_DUPLICATE_COLUMN');
       FND_MESSAGE.SET_TOKEN('COLUMN', 'financial_report_id');
       FND_MSG_PUB.ADD;
       RAISE FND_API.G_EXC_ERROR;
      END IF;
    END IF;

    x_financial_report_id := l_financial_report_id;

    -- validate financial report record
    HZ_ORG_INFO_VALIDATE.validate_financial_reports(
      p_financial_reports_rec, 'C', x_return_status);

    IF x_return_status = FND_API.G_RET_STS_ERROR THEN
      RAISE FND_API.G_EXC_ERROR;
    END IF;

    -- Bug 1428526: Should pass updated financial reports info. to caller.
    -- Make sure to use values in p_financial_reports_rec.* when calling insert table
    -- handler. Need to update p_financial_reports_rec first.
    p_financial_reports_rec.financial_report_id := l_financial_report_id;
/*
    -- call table handler to insert a row
    HZ_FINANCIAL_REPORTS_PKG.INSERT_ROW(
      x_rowid                           => l_rowid,
      x_financial_report_id             => p_financial_reports_rec.financial_report_id,
      x_date_report_issued              => p_financial_reports_rec.date_report_issued,
      x_party_id                        => p_financial_reports_rec.party_id,
      x_document_reference              => p_financial_reports_rec.document_reference,
      x_issued_period                   => p_financial_reports_rec.issued_period,
      x_requiring_authority             => p_financial_reports_rec.requiring_authority,
      x_type_of_financial_report        => p_financial_reports_rec.type_of_financial_report,
      x_created_by                      => hz_utility_pub.created_by,
      x_creation_date                   => hz_utility_pub.creation_date,
      x_last_update_login               => hz_utility_pub.last_update_login,
      x_last_update_date                => hz_utility_pub.last_update_date,
      x_last_updated_by                 => hz_utility_pub.last_updated_by,
      x_request_id                      => hz_utility_pub.request_id,
      x_program_application_id          => hz_utility_pub.program_application_id,
      x_program_id                      => hz_utility_pub.program_id,
      x_program_update_date             => hz_utility_pub.program_update_date,
      x_wh_udpate_id                    => p_financial_reports_rec.wh_udpate_id,
      x_report_start_date               => p_financial_reports_rec.report_start_date,
      x_report_end_date                 => p_financial_reports_rec.report_end_date,
      x_audit_ind                       => p_financial_reports_rec.audit_ind,
      x_consolidated_ind                => p_financial_reports_rec.consolidated_ind,
      x_estimated_ind                   => p_financial_reports_rec.estimated_ind,
      x_fiscal_ind                      => p_financial_reports_rec.fiscal_ind,
      x_final_ind                       => p_financial_reports_rec.final_ind,
      x_forecast_ind                    => p_financial_reports_rec.forecast_ind,
      x_opening_ind                     => p_financial_reports_rec.opening_ind,
      x_proforma_ind                    => p_financial_reports_rec.proforma_ind,
      x_qualified_ind                   => p_financial_reports_rec.qualified_ind,
      x_restated_ind                    => p_financial_reports_rec.restated_ind,
      x_signed_by_principals_ind        => p_financial_reports_rec.signed_by_principals_ind,
      x_trial_balance_ind               => p_financial_reports_rec.trial_balance_ind,
      x_unbalanced_ind                  => p_financial_reports_rec.unbalanced_ind,
      x_content_source_type             => p_financial_reports_rec.content_source_type ,
      x_status                          => p_financial_reports_rec.status,
      x_actual_content_source           => p_financial_reports_rec.actual_content_source
     );
*/
/*
    --Call to User-Hook pre Processing Procedure
    --Bug 1363124: validation#3 of content_source_type

    IF  fnd_profile.value('HZ_EXECUTE_API_CALLOUTS') = 'Y' AND
        -- Bug 2197181: Modifed the condition
        g_fin_is_datasource_selected = 'Y'
    THEN
      hz_org_info_crmhk.create_financial_reports_post(
        p_financial_reports_rec,
        x_return_status,
        x_msg_count,
        x_msg_data);

      IF x_return_status = FND_API.G_RET_STS_ERROR THEN
        RAISE FND_API.G_EXC_ERROR;
      ELSIF x_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
        FND_MESSAGE.SET_NAME('AR', 'HZ_API_HOOK_ERROR');
        FND_MESSAGE.SET_TOKEN('PROCEDURE',
                              'HZ_ORG_INFO_CRMHK.CREATE_FINANCIAL_REPORTS_POST');
        FND_MESSAGE.SET_TOKEN('ERROR' ,SQLERRM);
        FND_MSG_PUB.ADD;
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
      END IF;
    END IF;
*/

END do_create_financial_reports;

/*===========================================================================+
 | PROCEDURE
 |              do_update_financial_reports
 |
 | DESCRIPTION
 |              Updates financial reports.
 |
 | SCOPE - PRIVATE
 |
 | EXETERNAL PROCEDURES/FUNCTIONS ACCESSED
 |
 | ARGUMENTS  : IN:
 |              OUT:
 |          IN/ OUT:
 |                    p_financial_reports_rec
 |                    p_last_update_date
 |                    x_return_status
 |
 | RETURNS    : NONE
 |
 | NOTES
 |
 | MODIFICATION HISTORY
 |    Jianying Huang 06-OCT-00  Bug 1428526: make *_rec parameters as
 |                      'IN OUT' in order to pass the changed record
 |                      to caller.
 |    01-03-2005  Rajib Ranjan Borah   o SSM SST Integration and Extension.
 |                                       For non-profile entities, the concept of
 |                                       select/de-select data-sources is obsoleted.
 +===========================================================================*/

procedure do_update_financial_reports(
    p_financial_reports_rec         IN OUT NOCOPY financial_reports_rec_type,
    p_last_update_date              IN OUT NOCOPY DATE,
    x_return_status                 IN OUT NOCOPY VARCHAR2
) IS

    l_rowid                         ROWID := NULL;
    l_last_update_date              DATE;
    x_msg_count                     NUMBER;
    x_msg_data                      VARCHAR2(2000);

BEGIN

    -- check required fields:
    IF p_financial_reports_rec.financial_report_id is NULL OR
       p_financial_reports_rec.financial_report_id = FND_API.G_MISS_NUM
    THEN
     FND_MESSAGE.SET_NAME('AR', 'HZ_API_MISSING_COLUMN');
     FND_MESSAGE.SET_TOKEN('COLUMN', 'financial_report_id');
     FND_MSG_PUB.ADD;
     RAISE FND_API.G_EXC_ERROR;
    END IF;

    IF p_last_update_date IS NULL OR
       p_last_update_date = FND_API.G_MISS_DATE
    THEN
      FND_MESSAGE.SET_NAME('AR', 'HZ_API_MISSING_COLUMN');
      FND_MESSAGE.SET_TOKEN('COLUMN', 'p_last_update_date');
      FND_MSG_PUB.ADD;
      RAISE FND_API.G_EXC_ERROR;
    END IF;

    BEGIN
      -- check last update date.
      SELECT rowid, last_update_date
      INTO l_rowid, l_last_update_date
      FROM hz_financial_reports
      where financial_report_id = p_financial_reports_rec.financial_report_id
      AND to_char(last_update_date, 'DD-MON-YYYY HH:MI:SS') =
          to_char(p_last_update_date, 'DD-MON-YYYY HH:MI:SS')
      FOR UPDATE NOWAIT;

    EXCEPTION
      WHEN NO_DATA_FOUND THEN
        FND_MESSAGE.SET_NAME('AR', 'HZ_API_RECORD_CHANGED');
        FND_MESSAGE.SET_TOKEN('TABLE', 'HZ_FINANCIAL_REPORTS');
        FND_MSG_PUB.ADD;
        RAISE FND_API.G_EXC_ERROR;
    END;

/*
    --Call to User-Hook pre Processing Procedure
    --Bug 1363124: validation#3 of content_source_type

    IF fnd_profile.value('HZ_EXECUTE_API_CALLOUTS') = 'Y' AND
       -- Bug 2197181: Modifed the condition
       g_fin_is_datasource_selected = 'Y'
    THEN
      hz_org_info_crmhk.update_financial_reports_pre(
        p_financial_reports_rec,
        x_return_status,
        x_msg_count,
        x_msg_data);

      IF x_return_status = FND_API.G_RET_STS_ERROR THEN
        RAISE FND_API.G_EXC_ERROR;
      ELSIF x_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
        FND_MESSAGE.SET_NAME('AR', 'HZ_API_HOOK_ERROR');
        FND_MESSAGE.SET_TOKEN('PROCEDURE',
                              'HZ_ORG_INFO_CRMHK.UPDATE_FINANCIAL_REPORTS_PRE');
        FND_MESSAGE.SET_TOKEN('ERROR' ,SQLERRM);
        FND_MSG_PUB.ADD;
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
      END IF;
    END IF;
*/

    -- validate financial report record
    HZ_ORG_INFO_VALIDATE.validate_financial_reports(
      p_financial_reports_rec, 'U', x_return_status);

    IF x_return_status = FND_API.G_RET_STS_ERROR THEN
      RAISE FND_API.G_EXC_ERROR;
    END IF;

    -- pass back last update date
    p_last_update_date := hz_utility_pub.LAST_UPDATE_DATE;

    -- Bug 1428526: Should pass updated financial reports info. to caller.
    -- Make sure to use values in p_financial_reports_rec.* when calling update table
    -- handler. Need to update p_financial_reports_rec first.
    NULL;
/*
    -- call table handler to update a row
    HZ_FINANCIAL_REPORTS_PKG.UPDATE_ROW(
      x_rowid                           => l_rowid,
      x_financial_report_id             => p_financial_reports_rec.financial_report_id,
      x_date_report_issued              => p_financial_reports_rec.date_report_issued,
      x_party_id                        => p_financial_reports_rec.party_id,
      x_document_reference              => p_financial_reports_rec.document_reference,
      x_issued_period                   => p_financial_reports_rec.issued_period,
      x_requiring_authority             => p_financial_reports_rec.requiring_authority,
      x_type_of_financial_report        => p_financial_reports_rec.type_of_financial_report,
      x_created_by                      => fnd_api.g_miss_num,
      x_creation_date                   => fnd_api.g_miss_date,
      x_last_update_login               => hz_utility_pub.last_update_login,
      x_last_update_date                => p_last_update_date,
      x_last_updated_by                 => hz_utility_pub.last_updated_by,
      x_request_id                      => hz_utility_pub.request_id,
      x_program_application_id          => hz_utility_pub.program_application_id,
      x_program_id                      => hz_utility_pub.program_id,
      x_program_update_date             => hz_utility_pub.program_update_date,
      x_wh_udpate_id                    => p_financial_reports_rec.wh_udpate_id,
      x_report_start_date               => p_financial_reports_rec.report_start_date,
      x_report_end_date                 => p_financial_reports_rec.report_end_date,
      x_audit_ind                       => p_financial_reports_rec.audit_ind,
      x_consolidated_ind                => p_financial_reports_rec.consolidated_ind,
      x_estimated_ind                   => p_financial_reports_rec.estimated_ind,
      x_fiscal_ind                      => p_financial_reports_rec.fiscal_ind,
      x_final_ind                       => p_financial_reports_rec.final_ind,
      x_forecast_ind                    => p_financial_reports_rec.forecast_ind,
      x_opening_ind                     => p_financial_reports_rec.opening_ind,
      x_proforma_ind                    => p_financial_reports_rec.proforma_ind,
      x_qualified_ind                   => p_financial_reports_rec.qualified_ind,
      x_restated_ind                    => p_financial_reports_rec.restated_ind,
      x_signed_by_principals_ind        => p_financial_reports_rec.signed_by_principals_ind,
      x_trial_balance_ind               => p_financial_reports_rec.trial_balance_ind,
      x_unbalanced_ind                  => p_financial_reports_rec.unbalanced_ind,
      -- bug 2197181 : content_source_type is obsolete and it is non-updateable.
      x_content_source_type             => fnd_api.g_miss_char,
      x_status                          =>p_financial_reports_rec.status,
      x_actual_content_source           => p_financial_reports_rec.actual_content_source
     );
*/
/*
    --Call to User-Hook post Processing Procedure
    IF fnd_profile.value('HZ_EXECUTE_API_CALLOUTS') = 'Y'  AND
       -- Bug 2197181: Modifed the condition
       g_fin_is_datasource_selected = 'Y'
    THEN
      hz_org_info_crmhk.update_financial_reports_post(
        p_financial_reports_rec,
        x_return_status,
        x_msg_count,
        x_msg_data);

      IF x_return_status = FND_API.G_RET_STS_ERROR THEN
        RAISE FND_API.G_EXC_ERROR;
      ELSIF x_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
        FND_MESSAGE.SET_NAME('AR', 'HZ_API_HOOK_ERROR');
        FND_MESSAGE.SET_TOKEN('PROCEDURE',
                              'HZ_ORG_INFO_CRMHK.UPDATE_FINANCIAL_REPORTS_POST');
        FND_MESSAGE.SET_TOKEN('ERROR' ,SQLERRM);
        FND_MSG_PUB.ADD;
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
      END IF;
    END IF;
*/

END do_update_financial_reports;

/*===========================================================================+
 | PROCEDURE
 |              do_create_financial_numbers
 |
 | DESCRIPTION
 |              Creates financial numbers.
 |
 | SCOPE - PRIVATE
 |
 | EXETERNAL PROCEDURES/FUNCTIONS ACCESSED
 |
 | ARGUMENTS  : IN:
 |              OUT:
 |                    x_financial_number_id
 |          IN/ OUT:
 |                    p_financial_numbers_rec
 |                    x_return_status
 |
 | RETURNS    : NONE
 |
 | NOTES
 |
 | MODIFICATION HISTORY
 |    Jianying Huang 06-OCT-00  Bug 1428526: make *_rec parameters as
 |                      'IN OUT' in order to pass the changed record
 |                      to caller.
 |    01-03-2005  Rajib Ranjan Borah   o SSM SST Integration and Extension.
 |                                       For non-profile entities, the concept of
 |                                       select/de-select data-sources is obsoleted.
 +===========================================================================*/

procedure do_create_financial_numbers(
    p_financial_numbers_rec         IN OUT NOCOPY financial_numbers_rec_type,
    x_financial_number_id           OUT    NOCOPY NUMBER,
    x_return_status                 IN OUT NOCOPY VARCHAR2
) IS

    l_financial_number_id           NUMBER := p_financial_numbers_rec.financial_number_id;
    l_rep_content_source_type       hz_financial_reports.content_source_type%TYPE;
    l_rep_actual_content_source     hz_financial_reports.actual_content_source%TYPE;
    l_rowid                         ROWID  := NULL;
    l_count                         NUMBER;
    x_msg_count                     NUMBER;
    x_msg_data                      VARCHAR2(2000);

BEGIN

    -- if l_financial_number_id is NULL, then generate PK.
    IF l_financial_number_id is NULL  OR
       l_financial_number_id = FND_API.G_MISS_NUM
    THEN
      l_count := 1;

      WHILE l_count >0 LOOP
        SELECT hz_financial_numbers_s.nextval
        INTO l_financial_number_id from dual;

        SELECT count(*)
        INTO l_count
        FROM HZ_FINANCIAL_NUMBERS
        WHERE financial_number_id = l_financial_number_id;
      END LOOP;
    ELSE
      l_count := 0;

      SELECT count(*)
      INTO l_count
      FROM HZ_FINANCIAL_NUMBERS
      WHERE financial_number_id = l_financial_number_id;

      IF  l_count > 0 THEN
       FND_MESSAGE.SET_NAME('AR', 'HZ_API_DUPLICATE_COLUMN');
       FND_MESSAGE.SET_TOKEN('COLUMN', 'financial_number_id');
       FND_MSG_PUB.ADD;
       RAISE FND_API.G_EXC_ERROR;
      END IF;
    END IF;

    x_financial_number_id := l_financial_number_id;

    -- validate financial number record
    HZ_ORG_INFO_VALIDATE.validate_financial_numbers(
      p_financial_numbers_rec, 'C', x_return_status,
      l_rep_content_source_type, l_rep_actual_content_source);

    IF x_return_status = FND_API.G_RET_STS_ERROR THEN
      RAISE FND_API.G_EXC_ERROR;
    END IF;

    -- Bug 2197181: added for mix-n-match project. first check if user
    -- has privilege to create user-entered data if mix-n-match is enabled.

    -- SSM SST Integration and Extension
    -- For non-profile entities, the concept of select/de-select data-sources is obsoleted.
    -- There is no need to check if the data-source is selected.

    IF /*NVL(g_fin_mixnmatch_enabled, 'N') = 'Y' AND*/
       l_rep_actual_content_source = G_MISS_CONTENT_SOURCE_TYPE
    THEN
      HZ_MIXNM_UTILITY.CheckUserCreationPrivilege (
        p_entity_name                  => 'HZ_FINANCIAL_REPORTS',
        p_entity_attr_id               => g_fin_entity_attr_id,
        p_mixnmatch_enabled            => g_fin_mixnmatch_enabled,
        p_actual_content_source        => l_rep_actual_content_source,
        x_return_status                => x_return_status );
    END IF;

    IF x_return_status = FND_API.G_RET_STS_ERROR THEN
      RAISE FND_API.G_EXC_ERROR;
    END IF;

    -- Bug 2197181: added for mix-n-match project.
    -- check if the data source is seleted.

  /* SSM SST Integration and Extension
   * For non-profile entities, the concept of select/de-select data-sources is obsoleted.
   * There is no need to check if the data-source is selected.

      g_fin_is_datasource_selected :=
      HZ_MIXNM_UTILITY.isDataSourceSelected (
        p_selected_datasources           => g_fin_selected_datasources,
        p_actual_content_source          => l_rep_actual_content_source );
  */
/*
    --Call to User-Hook pre Processing Procedure
    --Bug 1363124: validation#3 of content_source_type

    IF fnd_profile.value('HZ_EXECUTE_API_CALLOUTS') = 'Y' AND
       -- Bug 2197181: Added below condition for Mix-n-Match
       g_fin_is_datasource_selected = 'Y'
    THEN
      hz_org_info_crmhk.create_financial_numbers_pre(
        p_financial_numbers_rec,
        x_return_status,
        x_msg_count,
        x_msg_data);

      IF x_return_status = FND_API.G_RET_STS_ERROR THEN
        RAISE FND_API.G_EXC_ERROR;
      ELSIF x_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
        FND_MESSAGE.SET_NAME('AR', 'HZ_API_HOOK_ERROR');
        FND_MESSAGE.SET_TOKEN('PROCEDURE',
                              'HZ_ORG_INFO_CRMHK.CREATE_FINANCIAL_NUMBERS_PRE');
        FND_MESSAGE.SET_TOKEN('ERROR' ,SQLERRM);
        FND_MSG_PUB.ADD;
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
      END IF;
    END IF;
*/

    -- Bug 1428526: Should pass updated financial numbers info. to caller.
    -- Make sure to use values in p_financial_numbers_rec.* when calling insert table
    -- handler. Need to update p_financial_numbers_rec first.
    p_financial_numbers_rec.financial_number_id := l_financial_number_id;
/*
    -- call table handler to insert a row
    HZ_FINANCIAL_NUMBERS_PKG.INSERT_ROW(
      x_rowid                           => l_rowid,
      x_financial_number_id             => p_financial_numbers_rec.financial_number_id,
      x_financial_report_id             => p_financial_numbers_rec.financial_report_id,
      x_financial_number                => p_financial_numbers_rec.financial_number,
      x_financial_number_name           => p_financial_numbers_rec.financial_number_name,
      x_financial_units_applied         => p_financial_numbers_rec.financial_units_applied,
      x_financial_number_currency       => p_financial_numbers_rec.financial_number_currency,
      x_projected_actual_flag           => p_financial_numbers_rec.projected_actual_flag,
      x_created_by                      => hz_utility_pub.created_by,
      x_creation_date                   => hz_utility_pub.creation_date,
      x_last_update_login               => hz_utility_pub.last_update_login,
      x_last_update_date                => hz_utility_pub.last_update_date,
      x_last_updated_by                 => hz_utility_pub.last_updated_by,
      x_request_id                      => hz_utility_pub.request_id,
      x_program_application_id          => hz_utility_pub.program_application_id,
      x_program_id                      => hz_utility_pub.program_id,
      x_program_update_date             => hz_utility_pub.program_update_date,
      x_wh_update_date                  => p_financial_numbers_rec.wh_update_date,
      x_content_source_type             => l_rep_content_source_type,
      x_status                          => p_financial_numbers_rec.status,
      x_actual_content_source           => l_rep_actual_content_source
    );
*/
/*
    --Call to User-Hook post Processing Procedure
    IF fnd_profile.value('HZ_EXECUTE_API_CALLOUTS') = 'Y' AND
       -- Bug 2197181: Added below condition for Mix-n-Match
       g_fin_is_datasource_selected = 'Y'
    THEN
      hz_org_info_crmhk.create_financial_numbers_post(
        p_financial_numbers_rec,
        x_return_status,
        x_msg_count,
        x_msg_data);

      IF x_return_status = FND_API.G_RET_STS_ERROR THEN
        RAISE FND_API.G_EXC_ERROR;
      ELSIF x_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
        FND_MESSAGE.SET_NAME('AR', 'HZ_API_HOOK_ERROR');
        FND_MESSAGE.SET_TOKEN('PROCEDURE',
                              'HZ_ORG_INFO_CRMHK.CREATE_FINANCIAL_NUMBERS_POST');
        FND_MESSAGE.SET_TOKEN('ERROR' ,SQLERRM);
        FND_MSG_PUB.ADD;
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
      END IF;
    END IF;
*/

END do_create_financial_numbers;

/*===========================================================================+
 | PROCEDURE
 |              do_update_financial_numbers
 |
 | DESCRIPTION
 |              Updates financial numbers.
 |
 | SCOPE - PRIVATE
 |
 | EXETERNAL PROCEDURES/FUNCTIONS ACCESSED
 |
 | ARGUMENTS  : IN:
 |              OUT:
 |          IN/ OUT:
 |                    p_financial_numbers_rec
 |                    p_last_update_date
 |                    x_return_status
 |
 | RETURNS    : NONE
 |
 | NOTES
 |
 | MODIFICATION HISTORY
 |    Jianying Huang 06-OCT-00  Bug 1428526: make *_rec parameters as
 |                      'IN OUT' in order to pass the changed record
 |                      to caller.
 |    01-03-2005  Rajib Ranjan Borah   o SSM SST Integration and Extension.
 |                                       For non-profile entities, the concept of
 |                                       select/de-select data-sources is obsoleted.
 |                                     o Updateability will be checked according to the
 |                                       rules setup for the same instead of program controlled
 |                                       profile values.
 +===========================================================================*/

procedure do_update_financial_numbers(
    p_financial_numbers_rec         IN OUT NOCOPY financial_numbers_rec_type,
    p_last_update_date              IN OUT NOCOPY DATE,
    x_return_status                 IN OUT NOCOPY VARCHAR2
) IS

    l_last_update_date              DATE;
    db_actual_content_source        hz_financial_numbers.actual_content_source%TYPE;
    l_rep_content_source_type       hz_financial_reports.content_source_type%TYPE;
    l_rep_actual_content_source     hz_financial_reports.actual_content_source%TYPE;
    l_rowid                         ROWID := NULL;
    x_msg_count                     NUMBER;
    x_msg_data                      VARCHAR2(2000);

BEGIN

    -- check required fields:
    IF p_financial_numbers_rec.financial_number_id is NULL OR
       p_financial_numbers_rec.financial_number_id = FND_API.G_MISS_NUM
    THEN
      FND_MESSAGE.SET_NAME('AR', 'HZ_API_MISSING_COLUMN');
      FND_MESSAGE.SET_TOKEN('COLUMN', 'financial_number_id');
      FND_MSG_PUB.ADD;
      RAISE FND_API.G_EXC_ERROR;
    END IF;

    IF p_last_update_date IS NULL OR
       p_last_update_date = FND_API.G_MISS_DATE
    THEN
       FND_MESSAGE.SET_NAME('AR', 'HZ_API_MISSING_COLUMN');
       FND_MESSAGE.SET_TOKEN('COLUMN', 'p_last_update_date');
       FND_MSG_PUB.ADD;
       RAISE FND_API.G_EXC_ERROR;
    END IF;

    BEGIN
      -- check last update date.
      SELECT rowid, last_update_date, actual_content_source
      INTO l_rowid, l_last_update_date, db_actual_content_source
      FROM HZ_FINANCIAL_NUMBERS
      WHERE financial_number_id  = p_financial_numbers_rec.financial_number_id
      AND to_char(last_update_date, 'DD-MON-YYYY HH:MI:SS') =
          to_char(p_last_update_date, 'DD-MON-YYYY HH:MI:SS')
      FOR UPDATE NOWAIT;

    EXCEPTION
      WHEN NO_DATA_FOUND THEN
        FND_MESSAGE.SET_NAME('AR', 'HZ_API_RECORD_CHANGED');
        FND_MESSAGE.SET_TOKEN('TABLE', 'HZ_FINANCIAL_NUMBERS');
        FND_MSG_PUB.ADD;
        RAISE FND_API.G_EXC_ERROR;
    END;

    -- Bug 2197181: added for mix-n-match project. first check if user has
    -- privilege to update this entity.

    -- SSM SST Integration and Extension
    -- Pass new parameters p_entity_name and p_new_actual_content_source
    IF db_actual_content_source <> G_MISS_CONTENT_SOURCE_TYPE
    THEN
      HZ_MIXNM_UTILITY.CheckUserUpdatePrivilege (
        p_actual_content_source        => db_actual_content_source,
	p_new_actual_content_source    => G_MISS_CONTENT_SOURCE_TYPE,
	p_entity_name                  => 'HZ_FINANCIAL_REPORTS',
        x_return_status                => x_return_status );
    END IF;

    IF x_return_status = FND_API.G_RET_STS_ERROR THEN
      RAISE FND_API.G_EXC_ERROR;
    END IF;

    -- Bug 2197181: added for mix-n-match project.
    -- check if the data source is seleted.

/* SSM SST Integration and Extension
 * For non-profile entities, the concept of select/de-select data-sources is obsoleted.
 * There is no need to check if the data-source is selected.

    g_fin_is_datasource_selected :=
      HZ_MIXNM_UTILITY.isDataSourceSelected (
        p_selected_datasources           => g_fin_selected_datasources,
        p_actual_content_source          => db_actual_content_source );
*/

/*
    --Call to User-Hook pre Processing Procedure
    --Bug 1363124: validation#3 of content_source_type
    IF fnd_profile.value('HZ_EXECUTE_API_CALLOUTS') = 'Y' AND
       -- Bug 2197181: Added below condition for Mix-n-Match
       g_fin_is_datasource_selected = 'Y'
    THEN
      hz_org_info_crmhk.update_financial_numbers_pre(
        p_financial_numbers_rec,
        x_return_status,
        x_msg_count,
        x_msg_data);

      IF x_return_status = FND_API.G_RET_STS_ERROR THEN
        RAISE FND_API.G_EXC_ERROR;
      ELSIF x_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
        FND_MESSAGE.SET_NAME('AR', 'HZ_API_HOOK_ERROR');
        FND_MESSAGE.SET_TOKEN('PROCEDURE',
                              'HZ_ORG_INFO_CRMHK.UPDATE_FINANCIAL_NUMBERS_PRE');
        FND_MESSAGE.SET_TOKEN('ERROR' ,SQLERRM);
        FND_MSG_PUB.ADD;
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
      END IF;
    END IF;
*/

    -- validate financial number record
    HZ_ORG_INFO_VALIDATE.validate_financial_numbers(
      p_financial_numbers_rec, 'U', x_return_status,
      l_rep_content_source_type, l_rep_actual_content_source);

    IF x_return_status = FND_API.G_RET_STS_ERROR THEN
      RAISE FND_API.G_EXC_ERROR;
    END IF;

    -- pass back the last update_date
    p_last_update_date := hz_utility_pub.LAST_UPDATE_DATE;

    -- Bug 1428526: Should pass updated financial numbers info. to caller.
    -- Make sure to use values in p_financial_numbers_rec.* when calling update table
    -- handler. Need to update p_financial_numbers_rec first.
    NULL;
/*
    -- call table handler to update a row
    HZ_FINANCIAL_NUMBERS_PKG.UPDATE_ROW(
      x_rowid                           => l_rowid,
      x_financial_number_id             => p_financial_numbers_rec.financial_number_id,
      x_financial_report_id             => p_financial_numbers_rec.financial_report_id,
      x_financial_number                => p_financial_numbers_rec.financial_number,
      x_financial_number_name           => p_financial_numbers_rec.financial_number_name,
      x_financial_units_applied         => p_financial_numbers_rec.financial_units_applied,
      x_financial_number_currency       => p_financial_numbers_rec.financial_number_currency,
      x_projected_actual_flag           => p_financial_numbers_rec.projected_actual_flag,
      x_created_by                      => fnd_api.g_miss_num,
      x_creation_date                   => fnd_api.g_miss_date,
      x_last_update_login               => hz_utility_pub.last_update_login,
      x_last_update_date                => p_last_update_date,
      x_last_updated_by                 => hz_utility_pub.last_updated_by,
      x_request_id                      => hz_utility_pub.request_id,
      x_program_application_id          => hz_utility_pub.program_application_id,
      x_program_id                      => hz_utility_pub.program_id,
      x_program_update_date             => hz_utility_pub.program_update_date,
      x_wh_update_date                  => p_financial_numbers_rec.wh_update_date,
      -- bug 2197181 : content_source_type is obsolete and it is non-updateable.
      x_content_source_type             => fnd_api.g_miss_char,
      x_status                          => p_financial_numbers_rec.status,
      -- bug 2197181 : actual_content_source is non-updateable.
      x_actual_content_source           => fnd_api.g_miss_char
    );
*/
/*
    --Call to User-Hook post Processing Procedure
    IF  fnd_profile.value('HZ_EXECUTE_API_CALLOUTS') = 'Y' AND
        -- Bug 2197181: Added below condition for Mix-n-Match
        g_fin_is_datasource_selected = 'Y'
    THEN
      hz_org_info_crmhk.update_financial_numbers_post(
        p_financial_numbers_rec,
        x_return_status,
        x_msg_count,
        x_msg_data);

      IF x_return_status = FND_API.G_RET_STS_ERROR THEN
        RAISE FND_API.G_EXC_ERROR;
      ELSIF x_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
        FND_MESSAGE.SET_NAME('AR', 'HZ_API_HOOK_ERROR');
        FND_MESSAGE.SET_TOKEN('PROCEDURE',
                              'HZ_ORG_INFO_CRMHK.UPDATE_FINANCIAL_NUMBERS_POST');
        FND_MESSAGE.SET_TOKEN('ERROR' ,SQLERRM);
        FND_MSG_PUB.ADD;
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
      END IF;
    END IF;
*/

END do_update_financial_numbers;

/*===========================================================================+
 | PROCEDURE
 |              do_create_certifications
 |
 | DESCRIPTION
 |              Creates certifications.
 |
 | SCOPE - PRIVATE
 |
 | EXETERNAL PROCEDURES/FUNCTIONS ACCESSED
 |
 | ARGUMENTS  : IN:
 |              OUT:
 |                    x_certification_id
 |          IN/ OUT:
 |                    p_certifications_rec
 |                    x_return_status
 |
 | RETURNS    : NONE
 |
 | NOTES
 |
 | MODIFICATION HISTORY
 |    Jianying Huang 06-OCT-00  Bug 1428526: make *_rec parameters as
 |                      'IN OUT' in order to pass the changed record
 |                      to caller.
 |
 +===========================================================================*/

procedure do_create_certifications(
        p_certifications_rec    IN OUT  NOCOPY certifications_rec_type,
        x_certification_id      OUT     NOCOPY NUMBER,
        x_return_status         IN OUT  NOCOPY VARCHAR2
) IS
        l_certification_id    NUMBER := p_certifications_rec.certification_id;
        l_rowid               ROWID  := NULL;
        l_count               NUMBER;
BEGIN
   -- if l_certification_id is NULL, then generate PK.
   IF l_certification_id is NULL  OR
      l_certification_id = FND_API.G_MISS_NUM  THEN
     l_count := 1;

     WHILE l_count >0 LOOP
       SELECT hz_certifications_s.nextval
       INTO l_certification_id from dual;

       SELECT count(*)
       INTO l_count
       FROM HZ_CERTIFICATIONS
       WHERE certification_id = l_certification_id;
     END LOOP;

   ELSE
     l_count := 0;

     SELECT count(*)
     INTO l_count
     FROM HZ_CERTIFICATIONS
     WHERE certification_id = l_certification_id;

     if  l_count > 0 THEN
       FND_MESSAGE.SET_NAME('AR', 'HZ_API_DUPLICATE_COLUMN');
       FND_MESSAGE.SET_TOKEN('COLUMN', 'certification_id');
       FND_MSG_PUB.ADD;
       RAISE FND_API.G_EXC_ERROR;
      end if;

    END IF;

    x_certification_id := l_certification_id;

    -- validate certification record
    HZ_ORG_INFO_VALIDATE.validate_certifications(p_certifications_rec,'C',
                                                 x_return_status);

     IF x_return_status = FND_API.G_RET_STS_ERROR THEN
                RAISE FND_API.G_EXC_ERROR;
     END IF;

-- Bug 1428526: Should pass updated certifications info. to caller.
-- Make sure to use values in p_certifications_rec.* when calling insert table
-- handler. Need to update p_certifications_rec first.
    p_certifications_rec.certification_id := l_certification_id;
    -- call table handler to insert a row
    HZ_CERTIFICATIONS_PKG.INSERT_ROW(
      X_Rowid => l_rowid,
      X_CERTIFICATION_ID => p_certifications_rec.certification_id,
      X_CERTIFICATION_NAME => p_certifications_rec.CERTIFICATION_NAME,
      X_CURRENT_STATUS => p_certifications_rec.CURRENT_STATUS,
      X_PARTY_ID => p_certifications_rec.PARTY_ID,
      X_EXPIRES_ON_DATE => p_certifications_rec.EXPIRES_ON_DATE,
      X_GRADE => p_certifications_rec.GRADE,
      X_ISSUED_BY_AUTHORITY => p_certifications_rec.ISSUED_BY_AUTHORITY,
      X_ISSUED_ON_DATE => p_certifications_rec.ISSUED_ON_DATE,
      X_CREATED_BY => hz_utility_pub.CREATED_BY,
      X_CREATION_DATE => hz_utility_pub.CREATION_DATE,
      X_LAST_UPDATE_LOGIN => hz_utility_pub.LAST_UPDATE_LOGIN,
      X_LAST_UPDATE_DATE => hz_utility_pub.LAST_UPDATE_DATE,
      X_LAST_UPDATED_BY => hz_utility_pub.LAST_UPDATED_BY,
      X_REQUEST_ID => hz_utility_pub.REQUEST_ID,
      X_PROGRAM_APPLICATION_ID => hz_utility_pub.PROGRAM_APPLICATION_ID,
      X_PROGRAM_ID => hz_utility_pub.PROGRAM_ID,
      X_PROGRAM_UPDATE_DATE => hz_utility_pub.PROGRAM_UPDATE_DATE,
      X_WH_UPDATE_DATE => p_certifications_rec.WH_UPDATE_DATE,
      X_STATUS     => p_certifications_rec.STATUS
     );

END do_create_certifications;

/*===========================================================================+
 | PROCEDURE
 |              do_update_certifications
 |
 | DESCRIPTION
 |              Updates certifications.
 |
 | SCOPE - PRIVATE
 |
 | EXETERNAL PROCEDURES/FUNCTIONS ACCESSED
 |
 | ARGUMENTS  : IN:
 |              OUT:
 |          IN/ OUT:
 |                    p_certifications_rec
 |                    p_last_update_date
 |                    x_return_status
 |
 | RETURNS    : NONE
 |
 | NOTES
 |
 | MODIFICATION HISTORY
 |    Jianying Huang 06-OCT-00  Bug 1428526: make *_rec parameters as
 |                      'IN OUT' in order to pass the changed record
 |                      to caller.
 |
 +===========================================================================*/

procedure do_update_certifications(
        p_certifications_rec   IN OUT  NOCOPY certifications_rec_type,
        p_last_update_date     IN OUT  NOCOPY DATE,
        x_return_status        IN OUT  NOCOPY VARCHAR2
) IS
        l_rowid                ROWID := NULL;
        l_last_update_date     DATE;
BEGIN
   -- check required fields:
   IF p_certifications_rec.certification_id is NULL OR
      p_certifications_rec.certification_id = FND_API.G_MISS_NUM  THEN

     FND_MESSAGE.SET_NAME('AR', 'HZ_API_MISSING_COLUMN');
     FND_MESSAGE.SET_TOKEN('COLUMN', 'certification_id');
     FND_MSG_PUB.ADD;
     RAISE FND_API.G_EXC_ERROR;

   END IF;

        IF p_last_update_date IS NULL OR
           p_last_update_date = FND_API.G_MISS_DATE
        THEN
                FND_MESSAGE.SET_NAME('AR', 'HZ_API_MISSING_COLUMN');
                FND_MESSAGE.SET_TOKEN('COLUMN', 'p_last_update_date');
                FND_MSG_PUB.ADD;
                RAISE FND_API.G_EXC_ERROR;
        END IF;
begin
        -- check last update date.
        SELECT rowid, last_update_date
        INTO l_rowid, l_last_update_date
        FROM HZ_CERTIFICATIONS
        where certification_id
              = p_certifications_rec.certification_id
        AND to_char(last_update_date, 'DD-MON-YYYY HH:MI:SS') =
            to_char(p_last_update_date, 'DD-MON-YYYY HH:MI:SS')
        FOR UPDATE NOWAIT;

        EXCEPTION WHEN NO_DATA_FOUND THEN
        FND_MESSAGE.SET_NAME('AR', 'HZ_API_RECORD_CHANGED');
        FND_MESSAGE.SET_TOKEN('TABLE', 'HZ_CERTIFICATIONS');
        FND_MSG_PUB.ADD;
        RAISE FND_API.G_EXC_ERROR;
end;

        -- validate certification record
        HZ_ORG_INFO_VALIDATE.validate_certifications(p_certifications_rec,'U',
                                                     x_return_status);

        IF x_return_status = FND_API.G_RET_STS_ERROR THEN
                RAISE FND_API.G_EXC_ERROR;
        END IF;

        -- pass back the last update date
        p_last_update_date :=  hz_utility_pub.LAST_UPDATE_DATE;

-- Bug 1428526: Should pass updated certifications info. to caller.
-- Make sure to use values in p_certifications_rec.* when calling update table
-- handler. Need to update p_certifications_rec first.
        NULL;

        -- call table handler to update a row
        HZ_CERTIFICATIONS_PKG.UPDATE_ROW(
          X_Rowid => l_rowid,
          X_CERTIFICATION_ID => p_certifications_rec.CERTIFICATION_ID,
          X_CERTIFICATION_NAME => p_certifications_rec.CERTIFICATION_NAME,
          X_CURRENT_STATUS => p_certifications_rec.CURRENT_STATUS,
          X_PARTY_ID => p_certifications_rec.PARTY_ID,
          X_EXPIRES_ON_DATE => p_certifications_rec.EXPIRES_ON_DATE,
          X_GRADE => p_certifications_rec.GRADE,
          X_ISSUED_BY_AUTHORITY => p_certifications_rec.ISSUED_BY_AUTHORITY,
          X_ISSUED_ON_DATE => p_certifications_rec.ISSUED_ON_DATE,
          X_CREATED_BY => FND_API.G_MISS_NUM,
          X_CREATION_DATE => FND_API.G_MISS_DATE,
          X_LAST_UPDATE_LOGIN => hz_utility_pub.LAST_UPDATE_LOGIN,
          X_LAST_UPDATE_DATE => p_last_update_date,
          X_LAST_UPDATED_BY => hz_utility_pub.LAST_UPDATED_BY,
          X_REQUEST_ID => hz_utility_pub.REQUEST_ID,
          X_PROGRAM_APPLICATION_ID => hz_utility_pub.PROGRAM_APPLICATION_ID,
          X_PROGRAM_ID => hz_utility_pub.PROGRAM_ID,
          X_PROGRAM_UPDATE_DATE => hz_utility_pub.PROGRAM_UPDATE_DATE,
          X_WH_UPDATE_DATE => p_certifications_rec.WH_UPDATE_DATE,
      X_STATUS     => p_certifications_rec.STATUS
        );

END do_update_certifications;

/*===========================================================================+
 | PROCEDURE
 |              do_create_industrial_reference
 |
 | DESCRIPTION
 |              Creates industrial reference.
 |
 | SCOPE - PRIVATE
 |
 | EXETERNAL PROCEDURES/FUNCTIONS ACCESSED
 |
 | ARGUMENTS  : IN:
 |              OUT:
 |                    x_industrial_reference_id
 |          IN/ OUT:
 |                    p_industrial_reference_rec
 |                    x_return_status
 |
 | RETURNS    : NONE
 |
 | NOTES
 |
 | MODIFICATION HISTORY
 |    Jianying Huang 06-OCT-00  Bug 1428526: make *_rec parameters as
 |                      'IN OUT' in order to pass the changed record
 |                      to caller.
 |
 +===========================================================================*/

procedure do_create_industrial_reference(
        p_industrial_reference_rec  IN OUT  NOCOPY industrial_reference_rec_type,
        x_industry_reference_id     OUT     NOCOPY NUMBER,
        x_return_status             IN OUT  NOCOPY VARCHAR2
) IS
        l_industry_reference_id     NUMBER:= p_industrial_reference_rec.industry_reference_id;
        l_rowid                     ROWID := NULL;
        l_count                     NUMBER;
BEGIN
   -- if l_industry_reference_id is NULL, then generate PK.
   IF l_industry_reference_id is NULL  OR
      l_industry_reference_id = FND_API.G_MISS_NUM  THEN
        l_count := 1;

        WHILE l_count >0 LOOP
          SELECT hz_industrial_reference_s.nextval
          INTO l_industry_reference_id from dual;

          SELECT count(*)
          INTO l_count
          FROM HZ_INDUSTRIAL_REFERENCE
          WHERE industry_reference_id = l_industry_reference_id;
        END LOOP;

   ELSE
     l_count := 0;

     SELECT count(*)
     INTO l_count
     FROM HZ_INDUSTRIAL_REFERENCE
     WHERE industry_reference_id = l_industry_reference_id;

     if  l_count > 0 THEN
       FND_MESSAGE.SET_NAME('AR', 'HZ_API_DUPLICATE_COLUMN');
       FND_MESSAGE.SET_TOKEN('COLUMN', 'industry_reference_id');
       FND_MSG_PUB.ADD;
       RAISE FND_API.G_EXC_ERROR;
      end if;

    END IF;

    x_industry_reference_id := l_industry_reference_id;

    -- validate industrial reference record
    HZ_ORG_INFO_VALIDATE.validate_industrial_reference(p_industrial_reference_rec,'C',
                                                       x_return_status);

     IF x_return_status = FND_API.G_RET_STS_ERROR THEN
                RAISE FND_API.G_EXC_ERROR;
     END IF;

-- Bug 1428526: Should pass updated industrial reference info. to caller.
-- Make sure to use values in p_industrial_reference_rec.* when calling insert table
-- handler. Need to update p_industrial_reference_rec first.
    p_industrial_reference_rec.industry_reference_id := l_industry_reference_id;

    -- call table handler to insert a row
    HZ_INDUSTRIAL_REFERENCE_PKG.INSERT_ROW(
      X_Rowid => l_rowid,
      X_INDUSTRY_REFERENCE_ID => p_industrial_reference_rec.industry_reference_id,
      X_INDUSTRY_REFERENCE => p_industrial_reference_rec.INDUSTRY_REFERENCE,
      X_ISSUED_BY_AUTHORITY => p_industrial_reference_rec.ISSUED_BY_AUTHORITY,
      X_NAME_OF_REFERENCE => p_industrial_reference_rec.NAME_OF_REFERENCE,
      X_RECOGNIZED_AS_OF_DATE => p_industrial_reference_rec.RECOGNIZED_AS_OF_DATE,
      X_CREATED_BY => hz_utility_pub.CREATED_BY,
      X_CREATION_DATE => hz_utility_pub.CREATION_DATE,
      X_LAST_UPDATE_LOGIN => hz_utility_pub.LAST_UPDATE_LOGIN,
      X_LAST_UPDATE_DATE => hz_utility_pub.LAST_UPDATE_DATE,
      X_LAST_UPDATED_BY => hz_utility_pub.LAST_UPDATED_BY,
      X_REQUEST_ID => hz_utility_pub.REQUEST_ID,
      X_PROGRAM_APPLICATION_ID => hz_utility_pub.PROGRAM_APPLICATION_ID,
      X_PROGRAM_ID => hz_utility_pub.PROGRAM_ID,
      X_PROGRAM_UPDATE_DATE => hz_utility_pub.PROGRAM_UPDATE_DATE,
      X_WH_UPDATE_DATE => p_industrial_reference_rec.WH_UPDATE_DATE,
      X_PARTY_ID => p_industrial_reference_rec.PARTY_ID,
      X_STATUS   =>p_industrial_reference_rec.STATUS
    );

end do_create_industrial_reference;

/*===========================================================================+
 | PROCEDURE
 |              do_update_industrial_reference
 |
 | DESCRIPTION
 |              Updates industrial reference.
 |
 | SCOPE - PRIVATE
 |
 | EXETERNAL PROCEDURES/FUNCTIONS ACCESSED
 |
 | ARGUMENTS  : IN:
 |              OUT:
 |          IN/ OUT:
 |                    p_industrial_reference_rec
 |                    p_last_update_date
 |                    x_return_status
 |
 | RETURNS    : NONE
 |
 | NOTES
 |
 | MODIFICATION HISTORY
 |    Jianying Huang 06-OCT-00  Bug 1428526: make *_rec parameters as
 |                      'IN OUT' in order to pass the changed record
 |                      to caller.
 |
 +===========================================================================*/

procedure do_update_industrial_reference(
        p_industrial_reference_rec   IN OUT  NOCOPY industrial_reference_rec_type,
        p_last_update_date           IN OUT  NOCOPY DATE,
        x_return_status              IN OUT  NOCOPY VARCHAR2
) IS
        l_rowid                      ROWID := NULL;
        l_last_update_date           DATE;
BEGIN
   -- check required fields:
   IF p_industrial_reference_rec.industry_reference_id is NULL OR
      p_industrial_reference_rec.industry_reference_id = FND_API.G_MISS_NUM  THEN

     FND_MESSAGE.SET_NAME('AR', 'HZ_API_MISSING_COLUMN');
     FND_MESSAGE.SET_TOKEN('COLUMN', 'industry_reference_id');
     FND_MSG_PUB.ADD;
     RAISE FND_API.G_EXC_ERROR;

   END IF;

        IF p_last_update_date IS NULL OR
           p_last_update_date = FND_API.G_MISS_DATE
        THEN
                FND_MESSAGE.SET_NAME('AR', 'HZ_API_MISSING_COLUMN');
                FND_MESSAGE.SET_TOKEN('COLUMN', 'p_last_update_date');
                FND_MSG_PUB.ADD;
                RAISE FND_API.G_EXC_ERROR;
        END IF;
begin
        -- check last update date.
        SELECT rowid, last_update_date
        INTO l_rowid, l_last_update_date
        FROM HZ_INDUSTRIAL_REFERENCE
        where industry_reference_id
              = p_industrial_reference_rec.industry_reference_id
        AND to_char(last_update_date, 'DD-MON-YYYY HH:MI:SS') =
            to_char(p_last_update_date, 'DD-MON-YYYY HH:MI:SS')
        FOR UPDATE NOWAIT;

        EXCEPTION WHEN NO_DATA_FOUND THEN
        FND_MESSAGE.SET_NAME('AR', 'HZ_API_RECORD_CHANGED');
        FND_MESSAGE.SET_TOKEN('TABLE', 'HZ_INDUSTRIAL_REFERENCE');
        FND_MSG_PUB.ADD;
        RAISE FND_API.G_EXC_ERROR;
end;

        -- validate industry reference record
        HZ_ORG_INFO_VALIDATE.validate_industrial_reference(p_industrial_reference_rec,'U',
                                                           x_return_status);

        IF x_return_status = FND_API.G_RET_STS_ERROR THEN
                RAISE FND_API.G_EXC_ERROR;
        END IF;

        -- pass back the last update date
        p_last_update_date := hz_utility_pub.LAST_UPDATE_DATE;

-- Bug 1428526: Should pass updated industrial reference info. to caller.
-- Make sure to use values in p_industrial_reference_rec.* when calling update table
-- handler. Need to update p_industrial_reference_rec first.
        NULL;

        -- call table handler to update a row
        HZ_INDUSTRIAL_REFERENCE_PKG.UPDATE_ROW(
          X_Rowid => l_rowid,
          X_INDUSTRY_REFERENCE_ID => p_industrial_reference_rec.INDUSTRY_REFERENCE_ID,
          X_INDUSTRY_REFERENCE => p_industrial_reference_rec.INDUSTRY_REFERENCE,
          X_ISSUED_BY_AUTHORITY => p_industrial_reference_rec.ISSUED_BY_AUTHORITY,
          X_NAME_OF_REFERENCE => p_industrial_reference_rec.NAME_OF_REFERENCE,
          X_RECOGNIZED_AS_OF_DATE => p_industrial_reference_rec.RECOGNIZED_AS_OF_DATE,
          X_CREATED_BY => FND_API.G_MISS_NUM,
          X_CREATION_DATE => FND_API.G_MISS_DATE,
          X_LAST_UPDATE_LOGIN => hz_utility_pub.LAST_UPDATE_LOGIN,
          X_LAST_UPDATE_DATE => p_last_update_date,
          X_LAST_UPDATED_BY => hz_utility_pub.LAST_UPDATED_BY,
          X_REQUEST_ID => hz_utility_pub.REQUEST_ID,
          X_PROGRAM_APPLICATION_ID => hz_utility_pub.PROGRAM_APPLICATION_ID,
          X_PROGRAM_ID => hz_utility_pub.PROGRAM_ID,
          X_PROGRAM_UPDATE_DATE => hz_utility_pub.PROGRAM_UPDATE_DATE,
          X_WH_UPDATE_DATE => p_industrial_reference_rec.WH_UPDATE_DATE,
          X_PARTY_ID => p_industrial_reference_rec.PARTY_ID,
          X_STATUS   =>p_industrial_reference_rec.STATUS
         );

END do_update_industrial_reference;

/*===========================================================================+
 | PROCEDURE
 |              do_create_industrial_classes
 |
 | DESCRIPTION
 |              Creates industrial classes.
 |
 | SCOPE - PRIVATE
 |
 | EXETERNAL PROCEDURES/FUNCTIONS ACCESSED
 |
 | ARGUMENTS  : IN:
 |              OUT:
 |                    x_industrial_class_id
 |          IN/ OUT:
 |                    p_industrial_classes_rec
 |                    x_return_status
 |
 | RETURNS    : NONE
 |
 | NOTES
 |
 | MODIFICATION HISTORY
 |    Jianying Huang 06-OCT-00  Bug 1428526: make *_rec parameters as
 |                      'IN OUT' in order to pass the changed record
 |                      to caller.
 |
 +===========================================================================*/

procedure do_create_industrial_classes(
        p_industrial_classes_rec  IN OUT  NOCOPY industrial_classes_rec_type,
        x_industrial_class_id     OUT     NOCOPY NUMBER,
        x_return_status           IN OUT  NOCOPY VARCHAR2
) IS
        l_industrial_class_id     NUMBER := p_industrial_classes_rec.industrial_class_id;
        l_rowid                   ROWID  := NULL;
        l_count                   NUMBER;
BEGIN
   -- if l_industrial_class_id is NULL, then generate PK.
   IF l_industrial_class_id is NULL  OR
      l_industrial_class_id = FND_API.G_MISS_NUM  THEN
     l_count := 1;

     WHILE l_count >0 LOOP
       SELECT hz_industrial_classes_s.nextval
       INTO l_industrial_class_id from dual;

       SELECT count(*)
       INTO l_count
       FROM HZ_INDUSTRIAL_CLASSES
       WHERE industrial_class_id = l_industrial_class_id;
     END LOOP;

   ELSE
     l_count := 0;

     SELECT count(*)
     INTO l_count
     FROM HZ_INDUSTRIAL_CLASSES
     WHERE industrial_class_id = l_industrial_class_id;

     if  l_count > 0 THEN
       FND_MESSAGE.SET_NAME('AR', 'HZ_API_DUPLICATE_COLUMN');
       FND_MESSAGE.SET_TOKEN('COLUMN', 'industrial_class_id');
       FND_MSG_PUB.ADD;
       RAISE FND_API.G_EXC_ERROR;
      end if;

    END IF;

    x_industrial_class_id := l_industrial_class_id;

    -- validate industrial classes  record
    HZ_ORG_INFO_VALIDATE.validate_industrial_classes(p_industrial_classes_rec,'C',
                                                     x_return_status);

    IF x_return_status = FND_API.G_RET_STS_ERROR THEN
                RAISE FND_API.G_EXC_ERROR;
    END IF;

-- Bug 1428526: Should pass updated industrial classes info. to caller.
-- Make sure to use values in p_industrial_classes_rec.* when calling insert table
-- handler. Need to update p_industrial_classes_rec first.
    p_industrial_classes_rec.industrial_class_id := l_industrial_class_id;

    -- call table handler to insert a row
    HZ_INDUSTRIAL_CLASSES_PKG.INSERT_ROW(
      X_Rowid => l_rowid,
      X_INDUSTRIAL_CLASS_ID => p_industrial_classes_rec.industrial_class_id,
      X_INDUSTRIAL_CODE_NAME => p_industrial_classes_rec.INDUSTRIAL_CODE_NAME,
      X_CODE_PRIMARY_SEGMENT => p_industrial_classes_rec.CODE_PRIMARY_SEGMENT,
      X_INDUSTRIAL_CLASS_SOURCE => p_industrial_classes_rec.INDUSTRIAL_CLASS_SOURCE,
      X_CODE_DESCRIPTION => p_industrial_classes_rec.CODE_DESCRIPTION,
      X_CREATED_BY => hz_utility_pub.CREATED_BY,
      X_CREATION_DATE => hz_utility_pub.CREATION_DATE,
      X_LAST_UPDATE_LOGIN => hz_utility_pub.LAST_UPDATE_LOGIN,
      X_LAST_UPDATE_DATE => hz_utility_pub.LAST_UPDATE_DATE,
      X_LAST_UPDATED_BY => hz_utility_pub.LAST_UPDATED_BY,
      X_REQUEST_ID => hz_utility_pub.REQUEST_ID,
      X_PROGRAM_APPLICATION_ID => hz_utility_pub.PROGRAM_APPLICATION_ID,
      X_PROGRAM_ID => hz_utility_pub.PROGRAM_ID,
      X_PROGRAM_UPDATE_DATE => hz_utility_pub.PROGRAM_UPDATE_DATE,
      X_WH_UPDATE_DATE => p_industrial_classes_rec.WH_UPDATE_DATE
     );

END do_create_industrial_classes;

/*===========================================================================+
 | PROCEDURE
 |              do_update_industrial_classes
 |
 | DESCRIPTION
 |              Updates industrial classes.
 |
 | SCOPE - PRIVATE
 |
 | EXETERNAL PROCEDURES/FUNCTIONS ACCESSED
 |
 | ARGUMENTS  : IN:
 |              OUT:
 |          IN/ OUT:
 |                    p_industrial_classes_rec
 |                    p_last_update_date
 |                    x_return_status
 |
 | RETURNS    : NONE
 |
 | NOTES
 |
 | MODIFICATION HISTORY
 |    Jianying Huang 06-OCT-00  Bug 1428526: make *_rec parameters as
 |                      'IN OUT' in order to pass the changed record
 |                      to caller.
 |
 +===========================================================================*/

procedure do_update_industrial_classes(
        p_industrial_classes_rec   IN OUT  NOCOPY industrial_classes_rec_type,
        p_last_update_date         IN OUT  NOCOPY DATE,
        x_return_status            IN OUT  NOCOPY VARCHAR2
) IS
        l_count                    NUMBER;
        l_rowid                    ROWID := NULL;
        l_last_update_date         DATE;
BEGIN
   -- check required field:
   IF p_industrial_classes_rec.industrial_class_id is NULL OR
     p_industrial_classes_rec.industrial_class_id  = FND_API.G_MISS_NUM  THEN

     FND_MESSAGE.SET_NAME('AR', 'HZ_API_MISSING_COLUMN');
     FND_MESSAGE.SET_TOKEN('COLUMN', 'industrial_class_id');
     FND_MSG_PUB.ADD;
     RAISE FND_API.G_EXC_ERROR;

   END IF;

        IF p_last_update_date IS NULL OR
           p_last_update_date = FND_API.G_MISS_DATE
        THEN
                FND_MESSAGE.SET_NAME('AR', 'HZ_API_MISSING_COLUMN');
                FND_MESSAGE.SET_TOKEN('COLUMN', 'p_last_update_date');
                FND_MSG_PUB.ADD;
                RAISE FND_API.G_EXC_ERROR;
        END IF;
begin
        -- check last update date.
        SELECT rowid, last_update_date
        INTO l_rowid, l_last_update_date
        FROM HZ_INDUSTRIAL_CLASSES
        where industrial_class_id
              = p_industrial_classes_rec.industrial_class_id
        AND to_char(last_update_date, 'DD-MON-YYYY HH:MI:SS') =
            to_char(p_last_update_date, 'DD-MON-YYYY HH:MI:SS')
        FOR UPDATE NOWAIT;

        EXCEPTION WHEN NO_DATA_FOUND THEN
        FND_MESSAGE.SET_NAME('AR', 'HZ_API_RECORD_CHANGED');
        FND_MESSAGE.SET_TOKEN('TABLE', 'HZ_INDUSTRIAL_CLASSES');
        FND_MSG_PUB.ADD;
        RAISE FND_API.G_EXC_ERROR;
end;

       -- validate  industrial classes record
        HZ_ORG_INFO_VALIDATE.validate_industrial_classes(p_industrial_classes_rec,'U',
                                                         x_return_status);

        IF x_return_status = FND_API.G_RET_STS_ERROR THEN
                RAISE FND_API.G_EXC_ERROR;
        END IF;

        -- pass back the last update date
        p_last_update_date := hz_utility_pub.LAST_UPDATE_DATE;

-- Bug 1428526: Should pass updated industrial classes info. to caller.
-- Make sure to use values in p_industrial_classes_rec.* when calling update table
-- handler. Need to update p_industrial_classes_rec first.
        NULL;

        -- call table handler to update a row
        HZ_INDUSTRIAL_CLASSES_PKG.UPDATE_ROW(
          X_Rowid => l_rowid,
          X_INDUSTRIAL_CLASS_ID => p_industrial_classes_rec.INDUSTRIAL_CLASS_ID,
          X_INDUSTRIAL_CODE_NAME => p_industrial_classes_rec.INDUSTRIAL_CODE_NAME,
          X_CODE_PRIMARY_SEGMENT => p_industrial_classes_rec.CODE_PRIMARY_SEGMENT,
          X_INDUSTRIAL_CLASS_SOURCE => p_industrial_classes_rec.INDUSTRIAL_CLASS_SOURCE,
          X_CODE_DESCRIPTION => p_industrial_classes_rec.CODE_DESCRIPTION,
          X_CREATED_BY => FND_API.G_MISS_NUM,
          X_CREATION_DATE => FND_API.G_MISS_DATE,
          X_LAST_UPDATE_LOGIN => hz_utility_pub.LAST_UPDATE_LOGIN,
          X_LAST_UPDATE_DATE => p_last_update_date,
          X_LAST_UPDATED_BY => hz_utility_pub.LAST_UPDATED_BY,
          X_REQUEST_ID => hz_utility_pub.REQUEST_ID,
          X_PROGRAM_APPLICATION_ID => hz_utility_pub.PROGRAM_APPLICATION_ID,
          X_PROGRAM_ID => hz_utility_pub.PROGRAM_ID,
          X_PROGRAM_UPDATE_DATE => hz_utility_pub.PROGRAM_UPDATE_DATE,
          X_WH_UPDATE_DATE => p_industrial_classes_rec.WH_UPDATE_DATE
        );

END do_update_industrial_classes;


/*  Private procedure get
    get_current_financial_report
    get_current_financial_number
    are public procedures */

   PROCEDURE get_current_industrial_classes(
     p_api_version               IN   NUMBER,
     p_init_msg_list             IN   VARCHAR2:= FND_API.G_FALSE,
     p_industrial_class_id       IN   NUMBER,
     x_industrial_classes_rec    OUT  NOCOPY industrial_classes_rec_type,
     x_return_status             OUT  NOCOPY VARCHAR2,
     x_msg_count                 OUT  NOCOPY NUMBER,
     x_msg_data                  OUT  NOCOPY VARCHAR2);

   PROCEDURE  get_current_stock_markets
   ( p_api_version           IN      NUMBER,
     p_init_msg_list         IN      VARCHAR2:= FND_API.G_FALSE,
     p_stock_exchange_id     IN     NUMBER,
     x_stock_markets_rec     OUT    NOCOPY stock_markets_rec_type,
     x_return_status         OUT    NOCOPY VARCHAR2,
     x_msg_count             OUT    NOCOPY NUMBER,
     x_msg_data              OUT    NOCOPY VARCHAR2);

   PROCEDURE  get_current_security_issued
   ( p_api_version           IN      NUMBER,
     p_init_msg_list         IN      VARCHAR2:= FND_API.G_FALSE,
     p_security_issued_id    IN     NUMBER,
     x_security_issued_rec   OUT    NOCOPY security_issued_rec_type,
     x_return_status         OUT    NOCOPY VARCHAR2,
     x_msg_count             OUT    NOCOPY NUMBER,
     x_msg_data              OUT    NOCOPY VARCHAR2);

   PROCEDURE  get_current_certifications
   ( p_api_version           IN      NUMBER,
     p_init_msg_list         IN      VARCHAR2:= FND_API.G_FALSE,
     p_certification_id      IN     NUMBER,
     x_certifications_rec    OUT    NOCOPY certifications_rec_type,
     x_return_status         OUT    NOCOPY VARCHAR2,
     x_msg_count             OUT    NOCOPY NUMBER,
     x_msg_data              OUT    NOCOPY VARCHAR2);


/*===========================================================================+
 | PROCEDURE
 |              get_current_industrial_classes
 |
 | DESCRIPTION
 |              Gets industrial_classes of current record.
 |
 | SCOPE - PRIVATE
 |
 | EXETERNAL PROCEDURES/FUNCTIONS ACCESSED
 |
 | ARGUMENTS  : IN:
 |                    p_industrial_class_id
 |                    p_init_msg_list
 |                    p_api_version
 |              OUT:
 |                    x_industrial_classes_rec
 |                    x_status
 |                    x_msg_count
 |                    x_msg_data
 |          IN/ OUT:
 |
 | RETURNS    : NONE
 |
 | NOTES
 |
 | MODIFICATION HISTORY
 |
 +===========================================================================*/

   PROCEDURE get_current_industrial_classes(
     p_api_version               IN   NUMBER,
     p_init_msg_list             IN   VARCHAR2:= FND_API.G_FALSE,
     p_industrial_class_id       IN   NUMBER,
     x_industrial_classes_rec    OUT  NOCOPY industrial_classes_rec_type,
     x_return_status             OUT  NOCOPY VARCHAR2,
     x_msg_count                 OUT  NOCOPY NUMBER,
     x_msg_data                  OUT  NOCOPY VARCHAR2)
   IS
      CURSOR c1 IS
      SELECT
          industrial_class_id,
          industrial_code_name,
          code_primary_segment,
          industrial_class_source,
          code_description,
          wh_update_date
        FROM HZ_INDUSTRIAL_CLASSES
       WHERE industrial_class_id = p_industrial_class_id;

      lrec                    c1%ROWTYPE;
      l_api_name              CONSTANT VARCHAR2(30) := 'get_current_industrial_classes';
      l_api_version           CONSTANT  NUMBER       := 1.0;

   BEGIN
     -- Initialize API return status to success.
     x_return_status := FND_API.G_RET_STS_SUCCESS;

     IF NOT FND_API.Compatible_API_Call(
                                        l_api_version,
                                        p_api_version,
                                        l_api_name,
                                        G_PKG_NAME)
     THEN
            RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
     END IF;

     -- Check whether primary key has been passed in.
     IF p_industrial_class_id IS NULL OR
        p_industrial_class_id = FND_API.G_MISS_NUM THEN
         FND_MESSAGE.SET_NAME( 'AR', 'HZ_API_MISSING_COLUMN' );
         FND_MESSAGE.SET_TOKEN( 'COLUMN', 'industrial_class_id' );
         FND_MSG_PUB.ADD;
         RAISE FND_API.G_EXC_ERROR;
     END IF;

     OPEN c1;
     FETCH c1 INTO lrec;
     IF c1%NOTFOUND THEN

        FND_MESSAGE.SET_NAME('AR', 'HZ_API_NO_RECORD');
        FND_MESSAGE.SET_TOKEN('RECORD', 'industrial_class');
        FND_MESSAGE.SET_TOKEN('VALUE', to_char(p_industrial_class_id));
        FND_MSG_PUB.ADD;
        RAISE FND_API.G_EXC_ERROR;

     ELSE
       x_industrial_classes_rec.industrial_class_id     := lrec.industrial_class_id;
       x_industrial_classes_rec.industrial_code_name    := lrec.industrial_code_name;
       x_industrial_classes_rec.code_primary_segment    := lrec.code_primary_segment;
       x_industrial_classes_rec.industrial_class_source := lrec.industrial_class_source;
       x_industrial_classes_rec.code_description  := lrec.code_description;
       x_industrial_classes_rec.wh_update_date    := lrec.wh_update_date;
     END IF;
      CLOSE c1;
   EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN
        x_return_status := FND_API.G_RET_STS_ERROR;

        FND_MSG_PUB.Count_And_Get(
            p_encoded => FND_API.G_FALSE,
            p_count => x_msg_count,
            p_data  => x_msg_data );

    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        FND_MSG_PUB.Count_And_Get(
            p_encoded => FND_API.G_FALSE,
            p_count => x_msg_count,
            p_data  => x_msg_data);

    WHEN OTHERS THEN
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

        FND_MESSAGE.SET_NAME( 'AR', 'HZ_API_OTHERS_EXCEP' );
        FND_MESSAGE.SET_TOKEN( 'ERROR' ,SQLERRM );
        FND_MSG_PUB.ADD;

        FND_MSG_PUB.Count_And_Get(
            p_encoded => FND_API.G_FALSE,
            p_count => x_msg_count,
            p_data  => x_msg_data );
   END;

/*===========================================================================+
 | PROCEDURE
 |              get_current_stock_markets
 | DESCRIPTION
 |              Gets stock markets of current record.
 | SCOPE - PRIVATE
 | EXETERNAL PROCEDURES/FUNCTIONS ACCESSED
 | ARGUMENTS  : IN:
 |                    p_stock_exchange_id
 |                    p_init_msg_list
 |                    p_api_version
 |              OUT:
 |                    x_stock_markets_rec
 |                    x_status
 |                    x_msg_count
 |                    x_msg_data
 |          IN/ OUT:
 | RETURNS    : NONE
 | NOTES
 | MODIFICATION HISTORY: Herve Yu 14-MAY-2002
 +===========================================================================*/
   PROCEDURE  get_current_stock_markets
   ( p_api_version           IN      NUMBER,
     p_init_msg_list         IN      VARCHAR2:= FND_API.G_FALSE,
     p_stock_exchange_id     IN     NUMBER,
     x_stock_markets_rec     OUT    NOCOPY stock_markets_rec_type,
     x_return_status         OUT    NOCOPY VARCHAR2,
     x_msg_count             OUT    NOCOPY NUMBER,
     x_msg_data              OUT    NOCOPY VARCHAR2)
   IS
     CURSOR c1 IS
      SELECT stock_exchange_id,
             country_of_residence,
             stock_exchange_code,
             stock_exchange_name,
             wh_update_date
        FROM hz_stock_markets
       WHERE stock_exchange_id = p_stock_exchange_id;
     lrec                    c1%ROWTYPE;
     l_api_name              CONSTANT VARCHAR2(30) := 'get_current_stock_markets';
     l_api_version           CONSTANT  NUMBER       := 1.0;

   BEGIN
     -- Initialize API return status to success.
     x_return_status := FND_API.G_RET_STS_SUCCESS;

     IF NOT FND_API.Compatible_API_Call(
                                        l_api_version,
                                        p_api_version,
                                        l_api_name,
                                        G_PKG_NAME)
     THEN
          RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
     END IF;

     -- Check whether primary key has been passed in.
     IF p_stock_exchange_id IS NULL OR
        p_stock_exchange_id = FND_API.G_MISS_NUM THEN
         FND_MESSAGE.SET_NAME( 'AR', 'HZ_API_MISSING_COLUMN' );
         FND_MESSAGE.SET_TOKEN( 'COLUMN', 'stock_exchange_id' );
         FND_MSG_PUB.ADD;
         RAISE FND_API.G_EXC_ERROR;
     END IF;

     OPEN c1;
     FETCH c1 INTO lrec;
     IF c1%NOTFOUND THEN
         FND_MESSAGE.SET_NAME('AR', 'HZ_API_NO_RECORD');
         FND_MESSAGE.SET_TOKEN('RECORD', 'stock_markets');
         FND_MESSAGE.SET_TOKEN('VALUE', to_char(p_stock_exchange_id));
         FND_MSG_PUB.ADD;
         RAISE FND_API.G_EXC_ERROR;
     ELSE
        x_stock_markets_rec.stock_exchange_id := lrec.stock_exchange_id;
        x_stock_markets_rec.country_of_residence := lrec.country_of_residence;
        x_stock_markets_rec.stock_exchange_code := lrec.stock_exchange_code;
        x_stock_markets_rec.stock_exchange_name := lrec.stock_exchange_name;
        x_stock_markets_rec.wh_update_date := lrec.wh_update_date;
     END IF;
     CLOSE c1;
   EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN
        x_return_status := FND_API.G_RET_STS_ERROR;
        FND_MSG_PUB.Count_And_Get(
            p_encoded => FND_API.G_FALSE,
            p_count => x_msg_count,
            p_data  => x_msg_data );

    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        FND_MSG_PUB.Count_And_Get(
            p_encoded => FND_API.G_FALSE,
            p_count => x_msg_count,
            p_data  => x_msg_data);

    WHEN OTHERS THEN
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        FND_MESSAGE.SET_NAME( 'AR', 'HZ_API_OTHERS_EXCEP' );
        FND_MESSAGE.SET_TOKEN( 'ERROR' ,SQLERRM );
        FND_MSG_PUB.ADD;

        FND_MSG_PUB.Count_And_Get(
            p_encoded => FND_API.G_FALSE,
            p_count => x_msg_count,
            p_data  => x_msg_data );
   END;

/*===========================================================================+
 | PROCEDURE
 |              get_current_security_issued
 | DESCRIPTION
 |              Gets sec issued of current record.
 | SCOPE - PRIVATE
 | EXETERNAL PROCEDURES/FUNCTIONS ACCESSED
 | ARGUMENTS  : IN:
 |                    p_security_issued_id
 |                    p_init_msg_list
 |                    p_api_version
 |              OUT:
 |                    x_security_issued_rec
 |                    x_status
 |                    x_msg_count
 |                    x_msg_data
 |          IN/ OUT:
 | RETURNS    : NONE
 | NOTES
 | MODIFICATION HISTORY: Herve Yu 14-MAY-2002
 +===========================================================================*/
   PROCEDURE  get_current_security_issued
   ( p_api_version           IN      NUMBER,
     p_init_msg_list         IN      VARCHAR2:= FND_API.G_FALSE,
     p_security_issued_id    IN     NUMBER,
     x_security_issued_rec   OUT    NOCOPY security_issued_rec_type,
     x_return_status         OUT    NOCOPY VARCHAR2,
     x_msg_count             OUT    NOCOPY NUMBER,
     x_msg_data              OUT    NOCOPY VARCHAR2)
   IS
     CURSOR c1 IS
     SELECT security_issued_id        ,
            estimated_total_amount    ,
            stock_exchange_id         ,
            security_issued_class     ,
            security_issued_name      ,
            total_amount_in_a_currency,
            stock_ticker_symbol       ,
            security_currency_code    ,
            begin_date      ,
            party_id        ,
            end_date        ,
            wh_update_date  ,
            status
      FROM hz_security_issued
     WHERE security_issued_id = p_security_issued_id;
    lrec                    c1%ROWTYPE;
    l_api_name              CONSTANT VARCHAR2(30) := 'get_current_security_issued';
    l_api_version           CONSTANT  NUMBER       := 1.0;

   BEGIN

     -- Initialize API return status to success.
     x_return_status := FND_API.G_RET_STS_SUCCESS;

     IF NOT FND_API.Compatible_API_Call(
                                        l_api_version,
                                        p_api_version,
                                        l_api_name,
                                        G_PKG_NAME)
     THEN
         RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
     END IF;


     -- Check whether primary key has been passed in.
     IF p_security_issued_id IS NULL OR
        p_security_issued_id = FND_API.G_MISS_NUM THEN
         FND_MESSAGE.SET_NAME( 'AR', 'HZ_API_MISSING_COLUMN' );
         FND_MESSAGE.SET_TOKEN( 'COLUMN', 'security_issued_id' );
         FND_MSG_PUB.ADD;
         RAISE FND_API.G_EXC_ERROR;
     END IF;

     OPEN c1;
     FETCH c1 INTO lrec;
     IF c1%NOTFOUND THEN
        FND_MESSAGE.SET_NAME('AR', 'HZ_API_NO_RECORD');
        FND_MESSAGE.SET_TOKEN('RECORD', 'security_issued');
        FND_MESSAGE.SET_TOKEN('VALUE', to_char(p_security_issued_id));
        FND_MSG_PUB.ADD;
        RAISE FND_API.G_EXC_ERROR;
     ELSE
        x_security_issued_rec.security_issued_id := lrec.security_issued_id;
        x_security_issued_rec.estimated_total_amount := lrec.estimated_total_amount;
        x_security_issued_rec.stock_exchange_id := lrec.stock_exchange_id;
        x_security_issued_rec.security_issued_class := lrec.security_issued_class;
        x_security_issued_rec.security_issued_name := lrec.security_issued_name;
        x_security_issued_rec.total_amount_in_a_currency := lrec.total_amount_in_a_currency;
        x_security_issued_rec.stock_ticker_symbol := lrec.stock_ticker_symbol;
        x_security_issued_rec.security_currency_code := lrec.security_currency_code;
        x_security_issued_rec.begin_date := lrec.begin_date;
        x_security_issued_rec.end_date := lrec.end_date;
        x_security_issued_rec.wh_update_date := lrec.wh_update_date;
        x_security_issued_rec.status := lrec.status;
     END IF;
     CLOSE c1;
   EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN
        x_return_status := FND_API.G_RET_STS_ERROR;

        FND_MSG_PUB.Count_And_Get(
            p_encoded => FND_API.G_FALSE,
            p_count => x_msg_count,
            p_data  => x_msg_data );

    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        FND_MSG_PUB.Count_And_Get(
            p_encoded => FND_API.G_FALSE,
            p_count => x_msg_count,
            p_data  => x_msg_data);

    WHEN OTHERS THEN
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

        FND_MESSAGE.SET_NAME( 'AR', 'HZ_API_OTHERS_EXCEP' );
        FND_MESSAGE.SET_TOKEN( 'ERROR' ,SQLERRM );
        FND_MSG_PUB.ADD;

        FND_MSG_PUB.Count_And_Get(
            p_encoded => FND_API.G_FALSE,
            p_count => x_msg_count,
            p_data  => x_msg_data );
  END;

/*===========================================================================+
 | PROCEDURE
 |              get_current_certifications
 | DESCRIPTION
 |              Gets certifications current record.
 | SCOPE - PRIVATE
 | EXETERNAL PROCEDURES/FUNCTIONS ACCESSED
 | ARGUMENTS  : IN:
 |                    p_certification_id
 |                    p_init_msg_list
 |                    p_api_version
 |              OUT:
 |                    x_certifications_rec
 |                    x_status
 |                    x_msg_count
 |                    x_msg_data
 |          IN/ OUT:
 | RETURNS    : NONE
 | NOTES
 | MODIFICATION HISTORY: Herve Yu 14-MAY-2002
 +===========================================================================*/
   PROCEDURE  get_current_certifications
   ( p_api_version           IN      NUMBER,
     p_init_msg_list         IN      VARCHAR2:= FND_API.G_FALSE,
     p_certification_id      IN     NUMBER,
     x_certifications_rec    OUT    NOCOPY certifications_rec_type,
     x_return_status         OUT    NOCOPY VARCHAR2,
     x_msg_count             OUT    NOCOPY NUMBER,
     x_msg_data              OUT    NOCOPY VARCHAR2
   )
   IS
     CURSOR c1 IS
     SELECT certification_id      ,
            certification_name    ,
            party_id              ,
            current_status        ,
            expires_on_date       ,
            grade                 ,
            issued_by_authority   ,
            issued_on_date        ,
            wh_update_date        ,
            status
       FROM hz_certifications
      WHERE certification_id = p_certification_id;
     lrec                    c1%ROWTYPE;
     l_api_name              CONSTANT VARCHAR2(30) := 'get_current_certifications';
     l_api_version           CONSTANT  NUMBER       := 1.0;

   BEGIN

     -- Initialize API return status to success.
     x_return_status := FND_API.G_RET_STS_SUCCESS;

     IF NOT FND_API.Compatible_API_Call(
                                        l_api_version,
                                        p_api_version,
                                        l_api_name,
                                        G_PKG_NAME)
     THEN
         RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
     END IF;

     -- Check whether primary key has been passed in.
     IF p_certification_id IS NULL OR
        p_certification_id = FND_API.G_MISS_NUM THEN
         FND_MESSAGE.SET_NAME( 'AR', 'HZ_API_MISSING_COLUMN' );
         FND_MESSAGE.SET_TOKEN( 'COLUMN', 'certification_id' );
         FND_MSG_PUB.ADD;
         RAISE FND_API.G_EXC_ERROR;
     END IF;

     OPEN c1;
     FETCH c1 INTO lrec;
     IF c1%NOTFOUND THEN

        FND_MESSAGE.SET_NAME('AR', 'HZ_API_NO_RECORD');
        FND_MESSAGE.SET_TOKEN('RECORD', 'certifications');
        FND_MESSAGE.SET_TOKEN('VALUE', to_char(p_certification_id));
        FND_MSG_PUB.ADD;
        RAISE FND_API.G_EXC_ERROR;

     ELSE

        x_certifications_rec.certification_id := lrec.certification_id;
        x_certifications_rec.certification_name := lrec.certification_name;
        x_certifications_rec.party_id := lrec.party_id;
        x_certifications_rec.current_status := lrec.current_status;
        x_certifications_rec.expires_on_date := lrec.expires_on_date;
        x_certifications_rec.grade := lrec.grade;
        x_certifications_rec.issued_by_authority := lrec.issued_by_authority;
        x_certifications_rec.issued_on_date := lrec.issued_on_date;
        x_certifications_rec.wh_update_date := lrec.wh_update_date;
        x_certifications_rec.status := lrec.status;

      END IF;
      CLOSE c1;
   EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN
        x_return_status := FND_API.G_RET_STS_ERROR;

        FND_MSG_PUB.Count_And_Get(
            p_encoded => FND_API.G_FALSE,
            p_count => x_msg_count,
            p_data  => x_msg_data );

    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        FND_MSG_PUB.Count_And_Get(
            p_encoded => FND_API.G_FALSE,
            p_count => x_msg_count,
            p_data  => x_msg_data);

    WHEN OTHERS THEN
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

        FND_MESSAGE.SET_NAME( 'AR', 'HZ_API_OTHERS_EXCEP' );
        FND_MESSAGE.SET_TOKEN( 'ERROR' ,SQLERRM );
        FND_MSG_PUB.ADD;

        FND_MSG_PUB.Count_And_Get(
            p_encoded => FND_API.G_FALSE,
            p_count => x_msg_count,
            p_data  => x_msg_data );
   END;


/*===========================================================================+
 | PROCEDURE
 |              do_create_industrial_class_app
 |
 | DESCRIPTION
 |              Creates industrial class app.
 |
 | SCOPE - PRIVATE
 |
 | EXETERNAL PROCEDURES/FUNCTIONS ACCESSED
 |
 | ARGUMENTS  : IN:
 |              OUT:
 |                    x_code_applied_id
 |          IN/ OUT:
 |                    p_industrial_class_app_rec
 |                    x_return_status
 |
 | RETURNS    : NONE
 |
 | NOTES
 |
 | MODIFICATION HISTORY
 |    Jianying Huang 06-OCT-00  Bug 1428526: make *_rec parameters as
 |                      'IN OUT' in order to pass the changed record
 |                      to caller.
 |
 +===========================================================================*/

procedure do_create_industrial_class_app(
        p_industrial_class_app_rec   IN OUT  NOCOPY industrial_class_app_rec_type,
        x_code_applied_id            OUT     NOCOPY NUMBER,
        x_return_status              IN OUT  NOCOPY VARCHAR2
) IS
        l_code_applied_id            NUMBER := p_industrial_class_app_rec.code_applied_id;
        l_rowid                      ROWID  := NULL;
        l_count                      NUMBER;
BEGIN
   -- if l_code_applied_id is NULL, then generate PK.
   IF l_code_applied_id is NULL  OR
      l_code_applied_id = FND_API.G_MISS_NUM  THEN
        l_count := 1;

        WHILE l_count >0 LOOP
          SELECT hz_industrial_class_app_s.nextval
          INTO l_code_applied_id from dual;

          SELECT count(*)
          INTO l_count
          FROM HZ_INDUSTRIAL_CLASS_APP
          WHERE code_applied_id = l_code_applied_id;
        END LOOP;

   ELSE
     l_count := 0;

     SELECT count(*)
     INTO l_count
     FROM HZ_INDUSTRIAL_CLASS_APP
     WHERE code_applied_id = l_code_applied_id;

     if  l_count > 0 THEN
       FND_MESSAGE.SET_NAME('AR', 'HZ_API_DUPLICATE_COLUMN');
       FND_MESSAGE.SET_TOKEN('COLUMN', 'code_applied_id');
       FND_MSG_PUB.ADD;
       RAISE FND_API.G_EXC_ERROR;
      end if;

    END IF;

    x_code_applied_id := l_code_applied_id;

    -- validate industrial classes  record
    HZ_ORG_INFO_VALIDATE.validate_industrial_class_app(p_industrial_class_app_rec,'C',
                                                       x_return_status);

    IF x_return_status = FND_API.G_RET_STS_ERROR THEN
                RAISE FND_API.G_EXC_ERROR;
    END IF;

-- Bug 1428526: Should pass updated industrial class app info. to caller.
-- Make sure to use values in p_industrial_class_app_rec.* when calling insert table
-- handler. Need to update p_industrial_class_app_rec first.
    p_industrial_class_app_rec.code_applied_id := l_code_applied_id;

    -- call table handler to insert a row
    HZ_INDUSTRIAL_CLASS_APP_PKG.INSERT_ROW(
      X_Rowid => l_rowid,
      X_CODE_APPLIED_ID => p_industrial_class_app_rec.code_applied_id,
      X_BEGIN_DATE => p_industrial_class_app_rec.BEGIN_DATE,
      X_PARTY_ID => p_industrial_class_app_rec.PARTY_ID,
      X_END_DATE => p_industrial_class_app_rec.END_DATE,
      X_INDUSTRIAL_CLASS_ID => p_industrial_class_app_rec.INDUSTRIAL_CLASS_ID,
      X_CREATED_BY => hz_utility_pub.CREATED_BY,
      X_CREATION_DATE => hz_utility_pub.CREATION_DATE,
      X_LAST_UPDATE_LOGIN => hz_utility_pub.LAST_UPDATE_LOGIN,
      X_LAST_UPDATE_DATE => hz_utility_pub.LAST_UPDATE_DATE,
      X_LAST_UPDATED_BY => hz_utility_pub.LAST_UPDATED_BY,
      X_REQUEST_ID => hz_utility_pub.REQUEST_ID,
      X_PROGRAM_APPLICATION_ID => hz_utility_pub.PROGRAM_APPLICATION_ID,
      X_PROGRAM_ID => hz_utility_pub.PROGRAM_ID,
      X_PROGRAM_UPDATE_DATE => hz_utility_pub.PROGRAM_UPDATE_DATE,
      X_WH_UPDATE_DATE => p_industrial_class_app_rec.WH_UPDATE_DATE,
      X_CONTENT_SOURCE_TYPE => p_industrial_class_app_rec.CONTENT_SOURCE_TYPE,
      X_IMPORTANCE_RANKING  => p_industrial_class_app_rec.IMPORTANCE_RANKING
   );

END do_create_industrial_class_app;

 /*===========================================================================+
 | PROCEDURE
 |              do_update_industrial_class_app
 |
 | DESCRIPTION
 |              Updates industrial class app.
 |
 | SCOPE - PRIVATE
 |
 | EXETERNAL PROCEDURES/FUNCTIONS ACCESSED
 |
 | ARGUMENTS  : IN:
 |              OUT:
 |          IN/ OUT:
 |                    p_industrial_class_app_rec
 |                    p_last_update_date
 |                    x_return_status
 |
 | RETURNS    : NONE
 |
 | NOTES
 |
 | MODIFICATION HISTORY
 |    Jianying Huang 06-OCT-00  Bug 1428526: make *_rec parameters as
 |                      'IN OUT' in order to pass the changed record
 |                      to caller.
 |
 +===========================================================================*/

procedure do_update_industrial_class_app(
        p_industrial_class_app_rec    IN OUT  NOCOPY industrial_class_app_rec_type,
        p_last_update_date            IN OUT  NOCOPY DATE,
        x_return_status               IN OUT  NOCOPY VARCHAR2
) IS
        l_count                       NUMBER;
        l_rowid                       ROWID := NULL;
        l_last_update_date            DATE;
BEGIN
  -- check required field:
  IF p_industrial_class_app_rec.code_applied_id is NULL OR
     p_industrial_class_app_rec.code_applied_id  = FND_API.G_MISS_NUM  THEN

     FND_MESSAGE.SET_NAME('AR', 'HZ_API_MISSING_COLUMN');
     FND_MESSAGE.SET_TOKEN('COLUMN', 'code_applied_id');
     FND_MSG_PUB.ADD;
     RAISE FND_API.G_EXC_ERROR;

   END IF;

        IF p_last_update_date IS NULL OR
           p_last_update_date = FND_API.G_MISS_DATE
        THEN
                FND_MESSAGE.SET_NAME('AR', 'HZ_API_MISSING_COLUMN');
                FND_MESSAGE.SET_TOKEN('COLUMN', 'p_last_update_date');
                FND_MSG_PUB.ADD;
                RAISE FND_API.G_EXC_ERROR;
        END IF;
begin
        -- check last update date.
        SELECT rowid, last_update_date
        INTO l_rowid, l_last_update_date
        FROM HZ_INDUSTRIAL_CLASS_APP
        where code_applied_id
              = p_industrial_class_app_rec.code_applied_id
        AND to_char(last_update_date, 'DD-MON-YYYY HH:MI:SS') =
            to_char(p_last_update_date, 'DD-MON-YYYY HH:MI:SS')
        FOR UPDATE NOWAIT;

        EXCEPTION WHEN NO_DATA_FOUND THEN
        FND_MESSAGE.SET_NAME('AR', 'HZ_API_RECORD_CHANGED');
        FND_MESSAGE.SET_TOKEN('TABLE', 'HZ_INDUSTRIAL_CLASS_APP');
        FND_MSG_PUB.ADD;
        RAISE FND_API.G_EXC_ERROR;
end;

       -- validate  industrial class app record
        HZ_ORG_INFO_VALIDATE.validate_industrial_class_app(p_industrial_class_app_rec,'U',
                                                           x_return_status);

        IF x_return_status = FND_API.G_RET_STS_ERROR THEN
                RAISE FND_API.G_EXC_ERROR;
        END IF;

        -- pass back teh last update date
        p_last_update_date := hz_utility_pub.LAST_UPDATE_DATE;

-- Bug 1428526: Should pass updated industrial class app info. to caller.
-- Make sure to use values in p_industrial_class_app_rec.* when calling update table
-- handler. Need to update p_industrial_class_app_rec first.
        NULL;

        -- call table handler to update a row
        HZ_INDUSTRIAL_CLASS_APP_PKG.UPDATE_ROW(
          X_Rowid => l_rowid,
          X_CODE_APPLIED_ID => p_industrial_class_app_rec.CODE_APPLIED_ID,
          X_BEGIN_DATE => p_industrial_class_app_rec.BEGIN_DATE,
          X_PARTY_ID => p_industrial_class_app_rec.PARTY_ID,
          X_END_DATE => p_industrial_class_app_rec.END_DATE,
          X_INDUSTRIAL_CLASS_ID => p_industrial_class_app_rec.INDUSTRIAL_CLASS_ID,
          X_CREATED_BY => FND_API.G_MISS_NUM,
          X_CREATION_DATE => FND_API.G_MISS_DATE,
          X_LAST_UPDATE_LOGIN => hz_utility_pub.LAST_UPDATE_LOGIN,
          X_LAST_UPDATE_DATE => p_last_update_date,
          X_LAST_UPDATED_BY => hz_utility_pub.LAST_UPDATED_BY,
          X_REQUEST_ID => hz_utility_pub.REQUEST_ID,
          X_PROGRAM_APPLICATION_ID => hz_utility_pub.PROGRAM_APPLICATION_ID,
          X_PROGRAM_ID => hz_utility_pub.PROGRAM_ID,
          X_PROGRAM_UPDATE_DATE => hz_utility_pub.PROGRAM_UPDATE_DATE,
          X_WH_UPDATE_DATE => p_industrial_class_app_rec.WH_UPDATE_DATE,
          X_CONTENT_SOURCE_TYPE => p_industrial_class_app_rec.CONTENT_SOURCE_TYPE,
          X_IMPORTANCE_RANKING => p_industrial_class_app_rec.IMPORTANCE_RANKING
        );

END do_update_industrial_class_app;

/*===========================================================================+
 | PROCEDURE
 |              create_stock_markets
 |
 | DESCRIPTION
 |              Creates stock markets.
 |
 | SCOPE - PUBLIC
 |
 | EXETERNAL PROCEDURES/FUNCTIONS ACCESSED
 |
 | ARGUMENTS  : IN:
 |                    p_api_version
 |                    p_init_msg_list
 |                    p_commit
 |                    p_stock_markets_rec
 |                    p_validation_level
 |              OUT:
 |                    x_return_status
 |                    x_msg_count
 |                    x_msg_data
 |                    x_stock_exchange_id
 |          IN/ OUT:
 |
 | RETURNS    : NONE
 |
 | NOTES
 |
 | MODIFICATION HISTORY
 |
 +===========================================================================*/

procedure create_stock_markets(
        p_api_version           IN      NUMBER,
        p_init_msg_list         IN      VARCHAR2:= FND_API.G_FALSE,
        p_commit                IN      VARCHAR2:= FND_API.G_FALSE,
        p_stock_markets_rec     IN      STOCK_MARKETS_REC_TYPE,
        x_return_status         OUT     NOCOPY VARCHAR2,
        x_msg_count             OUT     NOCOPY NUMBER,
        x_msg_data              OUT     NOCOPY VARCHAR2,
        x_stock_exchange_id     OUT     NOCOPY NUMBER,
        p_validation_level      IN      NUMBER :=FND_API.G_VALID_LEVEL_FULL
) IS
        l_api_name              CONSTANT VARCHAR2(30) := 'create stock markets';
        l_api_version           CONSTANT  NUMBER       := 1.0;
        l_stock_markets_rec     STOCK_MARKETS_REC_TYPE := p_stock_markets_rec;

BEGIN
--Standard start of API savepoint
        SAVEPOINT create_stock_markets_pub;
--Standard call to check for call compatibility.
        IF NOT FND_API.Compatible_API_Call(
                                        l_api_version,
                                        p_api_version,
                                        l_api_name,
                                        G_PKG_NAME)
        THEN
                RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
        END IF;

--Initialize message list if p_init_msg_list is set to TRUE.
        IF FND_API.to_Boolean(p_init_msg_list) THEN
                FND_MSG_PUB.initialize;
        END IF;

--Initialize API return status to success.
        x_return_status := FND_API.G_RET_STS_SUCCESS;

/*
--Call to User-Hook pre Processing Procedure
      IF fnd_profile.value('HZ_EXECUTE_API_CALLOUTS') = 'Y' THEN
        hz_org_info_crmhk.create_stock_markets_pre(
                        l_stock_markets_rec,
                        x_return_status,
                        x_msg_count,
                        x_msg_data);

        IF x_return_status = FND_API.G_RET_STS_ERROR THEN
                RAISE FND_API.G_EXC_ERROR;
        ELSIF x_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
                FND_MESSAGE.SET_NAME('AR', 'HZ_API_HOOK_ERROR');
                FND_MESSAGE.SET_TOKEN('PROCEDURE',
                                'HZ_ORG_INFO_CRMHK.CREATE_STOCK_MARKETS_PRE');
                FND_MESSAGE.SET_TOKEN('ERROR' ,SQLERRM);
                FND_MSG_PUB.ADD;
                RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
        END IF;

       END IF;
*/

-- Call to business logic.
-- Call PL/SQL wrapper over table handler
        do_create_stock_markets( l_stock_markets_rec,
                                 x_stock_exchange_id,
                                 x_return_status);

/*
--Call to User-Hook post Processing Procedure
      IF fnd_profile.value('HZ_EXECUTE_API_CALLOUTS') = 'Y' THEN
        hz_org_info_crmhk.create_stock_markets_post(
                        l_stock_markets_rec,
                        x_return_status,
                        x_msg_count,
                        x_msg_data);

        IF x_return_status = FND_API.G_RET_STS_ERROR THEN
                RAISE FND_API.G_EXC_ERROR;
        ELSIF x_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
                FND_MESSAGE.SET_NAME('AR', 'HZ_API_HOOK_ERROR');
                FND_MESSAGE.SET_TOKEN('PROCEDURE',
                                'HZ_ORG_INFO_CRMHK.CREATE_STOCK_MARKETS_POST');
                FND_MESSAGE.SET_TOKEN('ERROR' ,SQLERRM);
                FND_MSG_PUB.ADD;
                RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
        END IF;

       END IF;
*/

     --Bug 4743141.
   IF x_return_status = FND_API.G_RET_STS_SUCCESS THEN
     IF(HZ_UTILITY_V2PUB.G_EXECUTE_API_CALLOUTS in ('Y', 'EVENTS_ENABLED')) THEN
       hz_business_event_v2pvt.create_stock_markets_event(l_stock_markets_rec);
     END IF;
   END IF;

--Standard check of p_commit.
        IF FND_API.to_Boolean(p_commit) THEN
                Commit;
        END IF;

--Standard call to get message count and if count is 1, get message info.
        FND_MSG_PUB.Count_And_Get(
                p_encoded => FND_API.G_FALSE,
                p_count => x_msg_count,
                p_data  => x_msg_data);
EXCEPTION
        WHEN FND_API.G_EXC_ERROR THEN
                ROLLBACK TO create_stock_markets_pub;
                x_return_status := FND_API.G_RET_STS_ERROR;
                FND_MSG_PUB.Count_And_Get(
                                p_encoded => FND_API.G_FALSE,
                                p_count => x_msg_count,
                                p_data  => x_msg_data);

        WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
                ROLLBACK TO create_stock_markets_pub;
                x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
                FND_MSG_PUB.Count_And_Get(
                                p_encoded => FND_API.G_FALSE,
                                p_count => x_msg_count,
                                p_data  => x_msg_data);

        WHEN OTHERS THEN
                ROLLBACK TO create_stock_markets_pub;
                x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

                FND_MESSAGE.SET_NAME('AR', 'HZ_API_OTHERS_EXCEP');
                FND_MESSAGE.SET_TOKEN('ERROR' ,SQLERRM);
                FND_MSG_PUB.ADD;

                FND_MSG_PUB.Count_And_Get(
                                p_encoded => FND_API.G_FALSE,
                                p_count => x_msg_count,
                                p_data  => x_msg_data);

END create_stock_markets;

/*===========================================================================+
 | PROCEDURE
 |              update_stock_markets
 |
 | DESCRIPTION
 |              Updates stock markets.
 |
 | SCOPE - PUBLIC
 |
 | EXETERNAL PROCEDURES/FUNCTIONS ACCESSED
 |
 | ARGUMENTS  : IN:
 |                    p_api_version
 |                    p_init_msg_list
 |                    p_commit
 |                    p_stock_markets_rec
 |                    p_validation_level
 |              OUT:
 |                    x_return_status
 |                    x_msg_count
 |                    x_msg_data
 |          IN/ OUT:
 |                    p_last_update_date
 |
 | RETURNS    : NONE
 |
 | NOTES
 |
 | MODIFICATION HISTORY
 |
 +===========================================================================*/

procedure update_stock_markets(
        p_api_version           IN      NUMBER,
        p_init_msg_list         IN      VARCHAR2:= FND_API.G_FALSE,
        p_commit                IN      VARCHAR2:= FND_API.G_FALSE,
        p_stock_markets_rec     IN      STOCK_MARKETS_REC_TYPE,
        p_last_update_date      IN OUT  NOCOPY DATE,
        x_return_status         OUT     NOCOPY VARCHAR2,
        x_msg_count             OUT     NOCOPY NUMBER,
        x_msg_data              OUT     NOCOPY VARCHAR2,
        p_validation_level      IN      NUMBER :=FND_API.G_VALID_LEVEL_FULL
) IS

        l_api_name              CONSTANT VARCHAR2(30) := 'update stock markets';
        l_api_version           CONSTANT  NUMBER       := 1.0;
        l_stock_markets_rec     STOCK_MARKETS_REC_TYPE := p_stock_markets_rec;
        l_old_stock_markets_rec STOCK_MARKETS_REC_TYPE;
BEGIN
--Standard start of API savepoint
        SAVEPOINT update_stock_markets_pub;
--Standard call to check for call compatibility.
        IF NOT FND_API.Compatible_API_Call(
                                        l_api_version,
                                        p_api_version,
                                        l_api_name,
                                        G_PKG_NAME)
        THEN
                RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
        END IF;

--Initialize message list if p_init_msg_list is set to TRUE.
        IF FND_API.to_Boolean(p_init_msg_list) THEN
                FND_MSG_PUB.initialize;
        END IF;

--Initialize API return status to success.
        x_return_status := FND_API.G_RET_STS_SUCCESS;

/*
--Call to User-Hook pre Processing Procedure
      IF fnd_profile.value('HZ_EXECUTE_API_CALLOUTS') = 'Y' THEN
        hz_org_info_crmhk.update_stock_markets_pre(
                        l_stock_markets_rec,
                        x_return_status,
                        x_msg_count,
                        x_msg_data);

        IF x_return_status = FND_API.G_RET_STS_ERROR THEN
                RAISE FND_API.G_EXC_ERROR;
        ELSIF x_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
                FND_MESSAGE.SET_NAME('AR', 'HZ_API_HOOK_ERROR');
                FND_MESSAGE.SET_TOKEN('PROCEDURE',
                                'HZ_ORG_INFO_CRMHK.UPDATE_STOCK_MARKETS_PRE');
                FND_MESSAGE.SET_TOKEN('ERROR' ,SQLERRM);
                FND_MSG_PUB.ADD;
                RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
        END IF;

       END IF;

-- Get Old stock_markets_rec
    get_current_stock_markets(1,
                              FND_API.G_FALSE,
                              l_stock_markets_rec.stock_exchange_id,
                              l_old_stock_markets_rec,
                              x_return_status,
                              x_msg_count,
                              x_msg_data);

    IF x_return_status = FND_API.G_RET_STS_ERROR THEN
        RAISE FND_API.G_EXC_ERROR;
    ELSIF x_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;
*/

-- Call to business logic.
-- Call PL/SQL wrapper over table handler
        do_update_stock_markets( l_stock_markets_rec,
                                 p_last_update_date,
                                 x_return_status);

/*
--Call to User-Hook post Processing Procedure
      IF fnd_profile.value('HZ_EXECUTE_API_CALLOUTS') = 'Y' THEN
        hz_org_info_crmhk.update_stock_markets_post(
                        l_stock_markets_rec,
                        x_return_status,
                        x_msg_count,
                        x_msg_data);

        IF x_return_status = FND_API.G_RET_STS_ERROR THEN
                RAISE FND_API.G_EXC_ERROR;
        ELSIF x_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
                FND_MESSAGE.SET_NAME('AR', 'HZ_API_HOOK_ERROR');
                FND_MESSAGE.SET_TOKEN('PROCEDURE',
                                'HZ_ORG_INFO_CRMHK.UPDATE_STOCK_MARKETS_POST');
                FND_MESSAGE.SET_TOKEN('ERROR' ,SQLERRM);
                FND_MSG_PUB.ADD;
                RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
        END IF;

       END IF;
*/

     --Bug 4743141.
   IF x_return_status = FND_API.G_RET_STS_SUCCESS THEN
     IF(HZ_UTILITY_V2PUB.G_EXECUTE_API_CALLOUTS in ('Y', 'EVENTS_ENABLED')) THEN
      hz_business_event_v2pvt.update_stock_markets_event(l_stock_markets_rec);
     END IF;
   END IF;

--Standard check of p_commit.
        IF FND_API.to_Boolean(p_commit) THEN
                Commit;
        END IF;

--Standard call to get message count and if count is 1, get message info.
        FND_MSG_PUB.Count_And_Get(
                p_encoded => FND_API.G_FALSE,
                p_count => x_msg_count,
                p_data  => x_msg_data);
EXCEPTION
        WHEN FND_API.G_EXC_ERROR THEN
                ROLLBACK TO update_stock_markets_pub;
                x_return_status := FND_API.G_RET_STS_ERROR;
                FND_MSG_PUB.Count_And_Get(
                                p_encoded => FND_API.G_FALSE,
                                p_count => x_msg_count,
                                p_data  => x_msg_data);

        WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
                ROLLBACK TO update_stock_markets_pub;
                x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
                FND_MSG_PUB.Count_And_Get(
                                p_encoded => FND_API.G_FALSE,
                                p_count => x_msg_count,
                                p_data  => x_msg_data);

        WHEN OTHERS THEN
                ROLLBACK TO update_stock_markets_pub;
                x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

                FND_MESSAGE.SET_NAME('AR', 'HZ_API_OTHERS_EXCEP');
                FND_MESSAGE.SET_TOKEN('ERROR' ,SQLERRM);
                FND_MSG_PUB.ADD;

                FND_MSG_PUB.Count_And_Get(
                                p_encoded => FND_API.G_FALSE,
                                p_count => x_msg_count,
                                p_data  => x_msg_data);

END update_stock_markets;

/*===========================================================================+
 | PROCEDURE
 |              create_security_issued
 |
 | DESCRIPTION
 |              Creates security issued.
 |
 | SCOPE - PUBLIC
 |
 | EXETERNAL PROCEDURES/FUNCTIONS ACCESSED
 |
 | ARGUMENTS  : IN:
 |                    p_api_version
 |                    p_init_msg_list
 |                    p_commit
 |                    p_security_issued_rec
 |                    p_validation_level
 |              OUT:
 |                    x_return_status
 |                    x_msg_count
 |                    x_msg_data
 |                    x_security_issued_id
 |          IN/ OUT:
 |
 | RETURNS    : NONE
 |
 | NOTES
 |
 | MODIFICATION HISTORY
 |
 +===========================================================================*/

procedure create_security_issued(
        p_api_version           IN      NUMBER,
        p_init_msg_list         IN      VARCHAR2:= FND_API.G_FALSE,
        p_commit                IN      VARCHAR2:= FND_API.G_FALSE,
        p_security_issued_rec   IN      SECURITY_ISSUED_REC_TYPE,
        x_return_status         OUT     NOCOPY VARCHAR2,
        x_msg_count             OUT     NOCOPY NUMBER,
        x_msg_data              OUT     NOCOPY VARCHAR2,
        x_security_issued_id    OUT     NOCOPY NUMBER,
        p_validation_level      IN      NUMBER :=FND_API.G_VALID_LEVEL_FULL
) IS
        l_api_name              CONSTANT VARCHAR2(30) := 'create security issued';
        l_api_version           CONSTANT  NUMBER       := 1.0;
        l_security_issued_rec   SECURITY_ISSUED_REC_TYPE := p_security_issued_rec;

BEGIN
--Standard start of API savepoint
        SAVEPOINT create_security_issued_pub;
--Standard call to check for call compatibility.
        IF NOT FND_API.Compatible_API_Call(
                                        l_api_version,
                                        p_api_version,
                                        l_api_name,
                                        G_PKG_NAME)
        THEN
                RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
        END IF;

--Initialize message list if p_init_msg_list is set to TRUE.
        IF FND_API.to_Boolean(p_init_msg_list) THEN
                FND_MSG_PUB.initialize;
        END IF;

--Initialize API return status to success.
        x_return_status := FND_API.G_RET_STS_SUCCESS;

/*
--Call to User-Hook pre Processing Procedure
      IF fnd_profile.value('HZ_EXECUTE_API_CALLOUTS') = 'Y' THEN
        hz_org_info_crmhk.create_security_issued_pre(
                        l_security_issued_rec,
                        x_return_status,
                        x_msg_count,
                        x_msg_data);

        IF x_return_status = FND_API.G_RET_STS_ERROR THEN
                RAISE FND_API.G_EXC_ERROR;
        ELSIF x_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
                FND_MESSAGE.SET_NAME('AR', 'HZ_API_HOOK_ERROR');
                FND_MESSAGE.SET_TOKEN('PROCEDURE',
                                'HZ_ORG_INFO_CRMHK.CREATE_SECURITY_ISSUED_PRE');
                FND_MESSAGE.SET_TOKEN('ERROR' ,SQLERRM);
                FND_MSG_PUB.ADD;
                RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
        END IF;

       END IF;
*/

-- Call to business logic.
-- Call PL/SQL wrapper over table handler
        do_create_security_issued(l_security_issued_rec,
                                  x_security_issued_id,
                                  x_return_status);

/*
--Call to User-Hook post Processing Procedure
      IF fnd_profile.value('HZ_EXECUTE_API_CALLOUTS') = 'Y' THEN
        hz_org_info_crmhk.create_security_issued_post(
                        l_security_issued_rec,
                        x_return_status,
                        x_msg_count,
                        x_msg_data);

        IF x_return_status = FND_API.G_RET_STS_ERROR THEN
                RAISE FND_API.G_EXC_ERROR;
        ELSIF x_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
                FND_MESSAGE.SET_NAME('AR', 'HZ_API_HOOK_ERROR');
                FND_MESSAGE.SET_TOKEN('PROCEDURE',
                                'HZ_ORG_INFO_CRMHK.CREATE_SECURITY_ISSUED_POST');
                FND_MESSAGE.SET_TOKEN('ERROR' ,SQLERRM);
                FND_MSG_PUB.ADD;
                RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
        END IF;

       END IF;
*/

     --Bug 4743141.
   IF x_return_status = FND_API.G_RET_STS_SUCCESS THEN
     IF(HZ_UTILITY_V2PUB.G_EXECUTE_API_CALLOUTS in ('Y', 'EVENTS_ENABLED')) THEN
       hz_business_event_v2pvt.create_sec_issued_event(l_security_issued_rec);
     END IF;
   END IF;

--Standard check of p_commit.
        IF FND_API.to_Boolean(p_commit) THEN
                Commit;
        END IF;

--Standard call to get message count and if count is 1, get message info.
        FND_MSG_PUB.Count_And_Get(
                p_encoded => FND_API.G_FALSE,
                p_count => x_msg_count,
                p_data  => x_msg_data);
EXCEPTION
        WHEN FND_API.G_EXC_ERROR THEN
                ROLLBACK TO create_security_issued_pub;
                x_return_status := FND_API.G_RET_STS_ERROR;
                FND_MSG_PUB.Count_And_Get(
                                p_encoded => FND_API.G_FALSE,
                                p_count => x_msg_count,
                                p_data  => x_msg_data);

        WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
                ROLLBACK TO create_security_issued_pub;
                x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
                FND_MSG_PUB.Count_And_Get(
                                p_encoded => FND_API.G_FALSE,
                                p_count => x_msg_count,
                                p_data  => x_msg_data);

        WHEN OTHERS THEN
                ROLLBACK TO create_security_issued_pub;
                x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

                FND_MESSAGE.SET_NAME('AR', 'HZ_API_OTHERS_EXCEP');
                FND_MESSAGE.SET_TOKEN('ERROR' ,SQLERRM);
                FND_MSG_PUB.ADD;

                FND_MSG_PUB.Count_And_Get(
                                p_encoded => FND_API.G_FALSE,
                                p_count => x_msg_count,
                                p_data  => x_msg_data);

END create_security_issued;

/*===========================================================================+
 | PROCEDURE
 |              update_security_issued
 |
 | DESCRIPTION
 |              Updates security issued.
 |
 | SCOPE - PUBLIC
 |
 | EXETERNAL PROCEDURES/FUNCTIONS ACCESSED
 |
 | ARGUMENTS  : IN:
 |                    p_api_version
 |                    p_init_msg_list
 |                    p_commit
 |                    p_security_issued_rec
 |                    p_validation_level
 |              OUT:
 |                    x_return_status
 |                    x_msg_count
 |                    x_msg_data
 |          IN/ OUT:
 |                    p_last_update_date
 |
 | RETURNS    : NONE
 |
 | NOTES
 |
 | MODIFICATION HISTORY
 |
 +===========================================================================*/

procedure update_security_issued(
        p_api_version           IN      NUMBER,
        p_init_msg_list         IN      VARCHAR2:= FND_API.G_FALSE,
        p_commit                IN      VARCHAR2:= FND_API.G_FALSE,
        p_security_issued_rec   IN      SECURITY_ISSUED_REC_TYPE,
        p_last_update_date      IN OUT  NOCOPY DATE,
        x_return_status         OUT     NOCOPY VARCHAR2,
        x_msg_count             OUT     NOCOPY NUMBER,
        x_msg_data              OUT     NOCOPY VARCHAR2,
        p_validation_level      IN      NUMBER :=FND_API.G_VALID_LEVEL_FULL
) IS

        l_api_name              CONSTANT VARCHAR2(30) := 'update security issued';
        l_api_version           CONSTANT  NUMBER       := 1.0;
        l_security_issued_rec   SECURITY_ISSUED_REC_TYPE := p_security_issued_rec;
        l_old_security_issued_rec   SECURITY_ISSUED_REC_TYPE;
BEGIN
--Standard start of API savepoint
        SAVEPOINT update_security_issued_pub;
--Standard call to check for call compatibility.
        IF NOT FND_API.Compatible_API_Call(
                                        l_api_version,
                                        p_api_version,
                                        l_api_name,
                                        G_PKG_NAME)
        THEN
                RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
        END IF;

--Initialize message list if p_init_msg_list is set to TRUE.
        IF FND_API.to_Boolean(p_init_msg_list) THEN
                FND_MSG_PUB.initialize;
        END IF;

--Initialize API return status to success.
        x_return_status := FND_API.G_RET_STS_SUCCESS;


/*
     get_current_security_issued(1,
                                 FND_API.G_FALSE,
                                 l_security_issued_rec.security_issued_id,
                                 l_old_security_issued_rec,
                                 x_return_status,
                                 x_msg_count,
                                 x_msg_data);

    IF x_return_status = FND_API.G_RET_STS_ERROR THEN
        RAISE FND_API.G_EXC_ERROR;
    ELSIF x_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;

--Call to User-Hook pre Processing Procedure
      IF fnd_profile.value('HZ_EXECUTE_API_CALLOUTS') = 'Y' THEN
        hz_org_info_crmhk.update_security_issued_pre(
                        l_security_issued_rec,
                        x_return_status,
                        x_msg_count,
                        x_msg_data);

        IF x_return_status = FND_API.G_RET_STS_ERROR THEN
                RAISE FND_API.G_EXC_ERROR;
        ELSIF x_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
                FND_MESSAGE.SET_NAME('AR', 'HZ_API_HOOK_ERROR');
                FND_MESSAGE.SET_TOKEN('PROCEDURE',
                                'HZ_ORG_INFO_CRMHK.UPDATE_SECURITY_ISSUED_PRE');
                FND_MESSAGE.SET_TOKEN('ERROR' ,SQLERRM);
                FND_MSG_PUB.ADD;
                RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
        END IF;

       END IF;
*/

-- Call to business logic.
-- Call PL/SQL wrapper over table handler
        do_update_security_issued(l_security_issued_rec,
                                  p_last_update_date,
                                  x_return_status);

/*
--Call to User-Hook post Processing Procedure
      IF  fnd_profile.value('HZ_EXECUTE_API_CALLOUTS') = 'Y' THEN
        hz_org_info_crmhk.update_security_issued_post(
                        l_security_issued_rec,
                        x_return_status,
                        x_msg_count,
                        x_msg_data);

        IF x_return_status = FND_API.G_RET_STS_ERROR THEN
                RAISE FND_API.G_EXC_ERROR;
        ELSIF x_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
                FND_MESSAGE.SET_NAME('AR', 'HZ_API_HOOK_ERROR');
                FND_MESSAGE.SET_TOKEN('PROCEDURE',
                                'HZ_ORG_INFO_CRMHK.UPDATE_SECURITY_ISSUED_POST');
                FND_MESSAGE.SET_TOKEN('ERROR' ,SQLERRM);
                FND_MSG_PUB.ADD;
                RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
        END IF;

       END IF;
*/

     --Bug 4743141.
   IF x_return_status = FND_API.G_RET_STS_SUCCESS THEN
     IF(HZ_UTILITY_V2PUB.G_EXECUTE_API_CALLOUTS in ('Y', 'EVENTS_ENABLED')) THEN
       hz_business_event_v2pvt.update_sec_issued_event(l_security_issued_rec);
     END IF;
   END IF;

--Standard check of p_commit.
        IF FND_API.to_Boolean(p_commit) THEN
                Commit;
        END IF;

--Standard call to get message count and if count is 1, get message info.
        FND_MSG_PUB.Count_And_Get(
                p_encoded => FND_API.G_FALSE,
                p_count => x_msg_count,
                p_data  => x_msg_data);
EXCEPTION
        WHEN FND_API.G_EXC_ERROR THEN
                ROLLBACK TO update_security_issued_pub;
                x_return_status := FND_API.G_RET_STS_ERROR;
                FND_MSG_PUB.Count_And_Get(
                                p_encoded => FND_API.G_FALSE,
                                p_count => x_msg_count,
                                p_data  => x_msg_data);

        WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
                ROLLBACK TO update_security_issued_pub;
                x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
                FND_MSG_PUB.Count_And_Get(
                                p_encoded => FND_API.G_FALSE,
                                p_count => x_msg_count,
                                p_data  => x_msg_data);

        WHEN OTHERS THEN
                ROLLBACK TO update_security_issued_pub;
                x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

                FND_MESSAGE.SET_NAME('AR', 'HZ_API_OTHERS_EXCEP');
                FND_MESSAGE.SET_TOKEN('ERROR' ,SQLERRM);
                FND_MSG_PUB.ADD;

                FND_MSG_PUB.Count_And_Get(
                                p_encoded => FND_API.G_FALSE,
                                p_count => x_msg_count,
                                p_data  => x_msg_data);

END update_security_issued;

/*===========================================================================+
 | PROCEDURE
 |              create_financial_reports
 |
 | DESCRIPTION
 |              Creates financial reports.
 |
 | SCOPE - PUBLIC
 |
 | EXETERNAL PROCEDURES/FUNCTIONS ACCESSED
 |
 | ARGUMENTS  : IN:
 |                    p_api_version
 |                    p_init_msg_list
 |                    p_commit
 |                    p_financial_reports_rec
 |                    p_validation_level
 |              OUT:
 |                    x_return_status
 |                    x_msg_count
 |                    x_msg_data
 |                    x_financial_report_id
 |          IN/ OUT:
 |
 | RETURNS    : NONE
 |
 | NOTES
 |
 | MODIFICATION HISTORY
 |
 |    01-03-2005  Rajib Ranjan Borah   o SSM SST Integration and Extension.
 |                                       For non-profile entities, the concept of
 |                                       select/de-select data-sources is obsoleted.
 +===========================================================================

procedure create_financial_reports(
    p_api_version                   IN     NUMBER,
    p_init_msg_list                 IN     VARCHAR2:= FND_API.G_FALSE,
    p_commit                        IN     VARCHAR2:= FND_API.G_FALSE,
    p_financial_reports_rec         IN     FINANCIAL_REPORTS_REC_TYPE,
    x_return_status                 OUT    NOCOPY VARCHAR2,
    x_msg_count                     OUT    NOCOPY NUMBER,
    x_msg_data                      OUT    NOCOPY VARCHAR2,
    x_financial_report_id           OUT    NOCOPY NUMBER,
    p_validation_level              IN     NUMBER :=FND_API.G_VALID_LEVEL_FULL
) IS

    l_api_name                      CONSTANT VARCHAR2(30) := 'create financial reports';
    l_api_version                   CONSTANT NUMBER := 1.0;
    l_financial_reports_rec         FINANCIAL_REPORTS_REC_TYPE := p_financial_reports_rec;

BEGIN

    --Standard start of API savepoint
    SAVEPOINT create_financial_reports_pub;

    --Standard call to check for call compatibility.
    IF NOT FND_API.Compatible_API_Call(
             l_api_version,
             p_api_version,
             l_api_name,
             G_PKG_NAME)
    THEN
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;

    --Initialize message list if p_init_msg_list is set to TRUE.
    IF FND_API.to_Boolean(p_init_msg_list) THEN
      FND_MSG_PUB.initialize;
    END IF;

    --Initialize API return status to success.
    x_return_status := FND_API.G_RET_STS_SUCCESS;

    -- Bug 2197181: added for mix-n-match project. first load data
    -- sources for this entity. Then assign the actual_content_source
    -- to the real data source. The value of content_source_type is
    -- depended on if data source is seleted. If it is selected, we reset
    -- content_source_type to user-entered. We also check if user
    -- has the privilege to create user-entered data if mix-n-match
    -- is enabled.

    -- Bug 2444678: Removed caching.

    -- IF g_fin_mixnmatch_enabled IS NULL THEN
* SSM SST Integration and Extension
 * For non-profile entities, the concept of select/de-select data-sources is obsoleted.
 * There is no need to check if the data-source is selected.

    HZ_MIXNM_UTILITY.LoadDataSources(
      p_entity_name                    => 'HZ_FINANCIAL_REPORTS',
      p_entity_attr_id                 => g_fin_entity_attr_id,
      p_mixnmatch_enabled              => g_fin_mixnmatch_enabled,
      p_selected_datasources           => g_fin_selected_datasources );
*
    -- END IF;

    HZ_MIXNM_UTILITY.AssignDataSourceDuringCreation (
      p_entity_name                    => 'HZ_FINANCIAL_REPORTS',
      p_entity_attr_id                 => g_fin_entity_attr_id,
      p_mixnmatch_enabled              => g_fin_mixnmatch_enabled,
      p_selected_datasources           => g_fin_selected_datasources,
      p_content_source_type            => l_financial_reports_rec.content_source_type,
      p_actual_content_source          => l_financial_reports_rec.actual_content_source,
      x_is_datasource_selected         => g_fin_is_datasource_selected,
      x_return_status                  => x_return_status,
      p_api_version                    => 'V1');

    IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
      RAISE FND_API.G_EXC_ERROR;
    END IF;

********************this code is replaced to go via V2 API.
    -- Call to business logic.
    do_create_financial_reports(
      l_financial_reports_rec,
      x_financial_report_id,
      x_return_status);
************************

    -- call to perform everything through V2 API
    HZ_ORGANIZATION_INFO_V2PVT.v2_create_financial_report (
     p_financial_report_rec =>  l_financial_reports_rec,
     x_return_status        =>  x_return_status,
     x_financial_report_id  =>  x_financial_report_id
    );

*
    -- Invoke business event system.
    IF x_return_status = FND_API.G_RET_STS_SUCCESS AND
       -- Bug 2197181: Added below condition for Mix-n-Match
       g_fin_is_datasource_selected = 'Y'
    THEN
       HZ_BUSINESS_EVENT_V2PVT.create_fin_reports_event(l_financial_reports_rec);
    END IF;
*
    --Standard check of p_commit.
    IF FND_API.to_Boolean(p_commit) THEN
      Commit;
    END IF;

    --Standard call to get message count and if count is 1, get message info.
    FND_MSG_PUB.Count_And_Get(
      p_encoded => FND_API.G_FALSE,
      p_count => x_msg_count,
      p_data  => x_msg_data);

EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN
      ROLLBACK TO create_financial_reports_pub;
      x_return_status := FND_API.G_RET_STS_ERROR;

      FND_MSG_PUB.Count_And_Get(
        p_encoded => FND_API.G_FALSE,
        p_count => x_msg_count,
        p_data  => x_msg_data);

    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
      ROLLBACK TO create_financial_reports_pub;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

      FND_MSG_PUB.Count_And_Get(
        p_encoded => FND_API.G_FALSE,
        p_count => x_msg_count,
        p_data  => x_msg_data);

    WHEN OTHERS THEN
      ROLLBACK TO create_financial_reports_pub;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

      FND_MESSAGE.SET_NAME('AR', 'HZ_API_OTHERS_EXCEP');
      FND_MESSAGE.SET_TOKEN('ERROR' ,SQLERRM);
      FND_MSG_PUB.ADD;

      FND_MSG_PUB.Count_And_Get(
        p_encoded => FND_API.G_FALSE,
        p_count => x_msg_count,
        p_data  => x_msg_data);

END create_financial_reports;
END V1 API Obsolete
*/

/*===========================================================================+
 | PROCEDURE
 |              update_financial_reports
 |
 | DESCRIPTION
 |              Updates financial reports.
 |
 | SCOPE - PUBLIC
 |
 | EXETERNAL PROCEDURES/FUNCTIONS ACCESSED
 |
 | ARGUMENTS  : IN:
 |                    p_api_version
 |                    p_init_msg_list
 |                    p_commit
 |                    p_financial_reports_rec
 |                    p_validation_level
 |              OUT:
 |                    x_return_status
 |                    x_msg_count
 |                    x_msg_data
 |          IN/ OUT:
 |                    p_last_update_date
 |
 | RETURNS    : NONE
 |
 | NOTES
 |
 | MODIFICATION HISTORY
 |
 |   01-03-2005  Rajib Ranjan Borah   o SSM SST Integration and Extension.
 |                                      For non-profile entities, the concept of
 |                                      select/de-select data-sources is obsoleted.
 +===========================================================================

procedure update_financial_reports(
    p_api_version                   IN     NUMBER,
    p_init_msg_list                 IN     VARCHAR2:= FND_API.G_FALSE,
    p_commit                        IN     VARCHAR2:= FND_API.G_FALSE,
    p_financial_reports_rec         IN     FINANCIAL_REPORTS_REC_TYPE,
    p_last_update_date              IN OUT NOCOPY DATE,
    x_return_status                 OUT    NOCOPY VARCHAR2,
    x_msg_count                     OUT    NOCOPY NUMBER,
    x_msg_data                      OUT    NOCOPY VARCHAR2,
    p_validation_level              IN     NUMBER :=FND_API.G_VALID_LEVEL_FULL
) IS

    l_api_name                      CONSTANT VARCHAR2(30) := 'update financial reports';
    l_api_version                   CONSTANT NUMBER := 1.0;
    l_financial_reports_rec         FINANCIAL_REPORTS_REC_TYPE := p_financial_reports_rec;
    l_old_financial_reports_rec     FINANCIAL_REPORTS_REC_TYPE;

BEGIN

    --Standard start of API savepoint
    SAVEPOINT update_financial_reports_pub;

    --Standard call to check for call compatibility.
    IF NOT FND_API.Compatible_API_Call(
             l_api_version,
             p_api_version,
             l_api_name,
             G_PKG_NAME)
    THEN
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;

    --Initialize message list if p_init_msg_list is set to TRUE.
    IF FND_API.to_Boolean(p_init_msg_list) THEN
      FND_MSG_PUB.initialize;
    END IF;

    --Initialize API return status to success.
    x_return_status := FND_API.G_RET_STS_SUCCESS;

    get_current_financial_report(
      1, FND_API.G_FALSE,
      l_financial_reports_rec.financial_report_id,
      l_old_financial_reports_rec,
      x_return_status,
      x_msg_count,
      x_msg_data);

    IF x_return_status = FND_API.G_RET_STS_ERROR THEN
      RAISE FND_API.G_EXC_ERROR;
    ELSIF x_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;

    -- Bug 2197181: added for mix-n-match project. first load data
    -- sources for this entity.

    -- Bug 2444678: Removed caching.

    -- IF g_fin_mixnmatch_enabled IS NULL THEN

 * SSM SST Integration and Extension
 * For non-profile entities, the concept of select/de-select data-sources is obsoleted.
 * There is no need to check if the data-source is selected.

    HZ_MIXNM_UTILITY.LoadDataSources(
      p_entity_name                    => 'HZ_FINANCIAL_REPORTS',
      p_entity_attr_id                 => g_fin_entity_attr_id,
      p_mixnmatch_enabled              => g_fin_mixnmatch_enabled,
      p_selected_datasources           => g_fin_selected_datasources );

    -- END IF;

    -- Bug 2197181: added for mix-n-match project.
    -- check if the data source is seleted.
 * SSM SST Integration and Extension
 * For non-profile entities, the concept of select/de-select data-sources is obsoleted.
 * There is no need to check if the data-source is selected.

    g_fin_is_datasource_selected :=
      HZ_MIXNM_UTILITY.isDataSourceSelected (
        p_selected_datasources           => g_fin_selected_datasources,
        p_actual_content_source          => l_old_financial_reports_rec.actual_content_source );
*
********************this code is replaced to go via V2 API.
    -- Call to business logic.
    do_update_financial_reports(
      l_financial_reports_rec,
      p_last_update_date,
      x_return_status);
************************

    -- call to perform everything through V2 API
    HZ_ORGANIZATION_INFO_V2PVT.v2_update_financial_report (
      l_financial_reports_rec,
      p_last_update_date,
      x_return_status
    );

    *
    -- Invoke business event system.
    IF x_return_status = FND_API.G_RET_STS_SUCCESS AND
       -- Bug 2197181: Added below condition for Mix-n-Match
       g_fin_is_datasource_selected = 'Y'
    THEN
      HZ_BUSINESS_EVENT_V2PVT.update_fin_reports_event(l_financial_reports_rec);
    END IF;
    *
    --Standard check of p_commit.
    IF FND_API.to_Boolean(p_commit) THEN
      Commit;
    END IF;

    --Standard call to get message count and if count is 1, get message info.
    FND_MSG_PUB.Count_And_Get(
      p_encoded => FND_API.G_FALSE,
      p_count => x_msg_count,
      p_data  => x_msg_data);

EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN
      ROLLBACK TO update_financial_reports_pub;
      x_return_status := FND_API.G_RET_STS_ERROR;

      FND_MSG_PUB.Count_And_Get(
        p_encoded => FND_API.G_FALSE,
        p_count => x_msg_count,
        p_data  => x_msg_data);

    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
      ROLLBACK TO update_financial_reports_pub;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

      FND_MSG_PUB.Count_And_Get(
        p_encoded => FND_API.G_FALSE,
        p_count => x_msg_count,
        p_data  => x_msg_data);

    WHEN OTHERS THEN
      ROLLBACK TO update_financial_reports_pub;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

      FND_MESSAGE.SET_NAME('AR', 'HZ_API_OTHERS_EXCEP');
      FND_MESSAGE.SET_TOKEN('ERROR' ,SQLERRM);
      FND_MSG_PUB.ADD;

      FND_MSG_PUB.Count_And_Get(
        p_encoded => FND_API.G_FALSE,
        p_count => x_msg_count,
        p_data  => x_msg_data);

END update_financial_reports;
END Obsolete v1 api
*/

/*===========================================================================+
 | PROCEDURE
 |              create_financial_numbers
 |
 | DESCRIPTION
 |              Creates financial numbers.
 |
 | SCOPE - PUBLIC
 |
 | EXETERNAL PROCEDURES/FUNCTIONS ACCESSED
 |
 | ARGUMENTS  : IN:
 |                    p_api_version
 |                    p_init_msg_list
 |                    p_commit
 |                    p_financial_numbers_rec
 |                    p_validation_level
 |              OUT:
 |                    x_return_status
 |                    x_msg_count
 |                    x_msg_data
 |                    x_financial_number_id
 |          IN/ OUT:
 |
 | RETURNS    : NONE
 |
 | NOTES
 |
 | MODIFICATION HISTORY
 |
 |   01-03-2005  Rajib Ranjan Borah   o SSM SST Integration and Extension.
 |                                      For non-profile entities, the concept of
 |                                      select/de-select data-sources is obsoleted.
 +===========================================================================

procedure create_financial_numbers(
    p_api_version                   IN     NUMBER,
    p_init_msg_list                 IN     VARCHAR2:= FND_API.G_FALSE,
    p_commit                        IN     VARCHAR2:= FND_API.G_FALSE,
    p_financial_numbers_rec         IN     FINANCIAL_NUMBERS_REC_TYPE,
    x_return_status                 OUT    NOCOPY VARCHAR2,
    x_msg_count                     OUT    NOCOPY NUMBER,
    x_msg_data                      OUT    NOCOPY VARCHAR2,
    x_financial_number_id           OUT    NOCOPY NUMBER,
    p_validation_level              IN     NUMBER :=FND_API.G_VALID_LEVEL_FULL
) IS

    l_api_name                      CONSTANT VARCHAR2(30) := 'create financial numbers';
    l_api_version                   CONSTANT NUMBER := 1.0;
    l_financial_numbers_rec         FINANCIAL_NUMBERS_REC_TYPE := p_financial_numbers_rec;

BEGIN

    --Standard start of API savepoint
    SAVEPOINT create_financial_numbers_pub;

    --Standard call to check for call compatibility.
    IF NOT FND_API.Compatible_API_Call(
             l_api_version,
             p_api_version,
             l_api_name,
             G_PKG_NAME)
    THEN
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;

    --Initialize message list if p_init_msg_list is set to TRUE.
    IF FND_API.to_Boolean(p_init_msg_list) THEN
      FND_MSG_PUB.initialize;
    END IF;

    --Initialize API return status to success.
    x_return_status := FND_API.G_RET_STS_SUCCESS;

    -- Bug 2197181: added for mix-n-match project. first load data
    -- sources for this entity.

    -- Bug 2444678: Removed caching.

    -- IF g_fin_mixnmatch_enabled IS NULL THEN
 * SSM SST Integration and Extension
 * For non-profile entities, the concept of select/de-select data-sources is obsoleted.
 * There is no need to check if the data-source is selected.

    HZ_MIXNM_UTILITY.LoadDataSources(
      p_entity_name                    => 'HZ_FINANCIAL_REPORTS',
      p_entity_attr_id                 => g_fin_entity_attr_id,
      p_mixnmatch_enabled              => g_fin_mixnmatch_enabled,
      p_selected_datasources           => g_fin_selected_datasources );
*
    -- END IF;

********************this code is replaced to go via V2 API.
    -- Call to business logic.
    do_create_financial_numbers(
      l_financial_numbers_rec,
      x_financial_number_id,
      x_return_status);
************************

    -- call to perform everything through V2 API
    HZ_ORGANIZATION_INFO_V2PVT.v2_create_financial_number (
      p_financial_number_rec    => l_financial_numbers_rec,
      x_financial_number_id      => x_financial_number_id,
      x_return_status            => x_return_status);

*
    -- Invoke business event system.
    IF x_return_status = FND_API.G_RET_STS_SUCCESS AND
       -- Bug 2197181: Added below condition for Mix-n-Match
       g_fin_is_datasource_selected = 'Y'
    THEN
      HZ_BUSINESS_EVENT_V2PVT.create_fin_numbers_event(l_financial_numbers_rec);
    END IF;
*

    --Standard check of p_commit.
    IF FND_API.to_Boolean(p_commit) THEN
      Commit;
    END IF;

    --Standard call to get message count and if count is 1, get message info.
    FND_MSG_PUB.Count_And_Get(
      p_encoded => FND_API.G_FALSE,
      p_count => x_msg_count,
      p_data  => x_msg_data);

EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN
      ROLLBACK TO create_financial_numbers_pub;
      x_return_status := FND_API.G_RET_STS_ERROR;

      FND_MSG_PUB.Count_And_Get(
        p_encoded => FND_API.G_FALSE,
        p_count => x_msg_count,
        p_data  => x_msg_data);

    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
      ROLLBACK TO create_financial_numbers_pub;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

      FND_MSG_PUB.Count_And_Get(
        p_encoded => FND_API.G_FALSE,
        p_count => x_msg_count,
        p_data  => x_msg_data);

    WHEN OTHERS THEN
      ROLLBACK TO create_financial_numbers_pub;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

      FND_MESSAGE.SET_NAME('AR', 'HZ_API_OTHERS_EXCEP');
      FND_MESSAGE.SET_TOKEN('ERROR' ,SQLERRM);
      FND_MSG_PUB.ADD;

      FND_MSG_PUB.Count_And_Get(
        p_encoded => FND_API.G_FALSE,
        p_count => x_msg_count,
        p_data  => x_msg_data);

END create_financial_numbers;
END Obsolete vi api

*/
/*===========================================================================+
 | PROCEDURE
 |              update_financial_numbers
 |
 | DESCRIPTION
 |              Updates financial numbers.
 |
 | SCOPE - PUBLIC
 |
 | EXETERNAL PROCEDURES/FUNCTIONS ACCESSED
 |
 | ARGUMENTS  : IN:
 |                    p_api_version
 |                    p_init_msg_list
 |                    p_commit
 |                    p_financial_numbers_rec
 |                    p_validation_level
 |              OUT:
 |                    x_return_status
 |                    x_msg_count
 |                    x_msg_data
 |          IN/ OUT:
 |                    p_last_update_date
 |
 | RETURNS    : NONE
 |
 | NOTES
 |
 | MODIFICATION HISTORY
 |
 |   01-03-2005  Rajib Ranjan Borah   o SSM SST Integration and Extension.
 |                                      For non-profile entities, the concept of
 |                                      select/de-select data-sources is obsoleted.
 +===========================================================================

procedure update_financial_numbers(
    p_api_version                   IN     NUMBER,
    p_init_msg_list                 IN     VARCHAR2:= FND_API.G_FALSE,
    p_commit                        IN     VARCHAR2:= FND_API.G_FALSE,
    p_financial_numbers_rec         IN     FINANCIAL_NUMBERS_REC_TYPE,
    p_last_update_date              IN OUT NOCOPY DATE,
    x_return_status                 OUT    NOCOPY VARCHAR2,
    x_msg_count                     OUT    NOCOPY NUMBER,
    x_msg_data                      OUT    NOCOPY VARCHAR2,
    p_validation_level              IN     NUMBER :=FND_API.G_VALID_LEVEL_FULL
) IS

    l_api_name                      CONSTANT VARCHAR2(30) := 'update financial numbers';
    l_api_version                   CONSTANT NUMBER := 1.0;
    l_financial_numbers_rec         FINANCIAL_NUMBERS_REC_TYPE := p_financial_numbers_rec;
    l_old_financial_numbers_rec     FINANCIAL_NUMBERS_REC_TYPE;

BEGIN

    --Standard start of API savepoint
    SAVEPOINT update_financial_numbers_pub;

    --Standard call to check for call compatibility.
    IF NOT FND_API.Compatible_API_Call(
             l_api_version,
             p_api_version,
             l_api_name,
             G_PKG_NAME)
    THEN
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;

    --Initialize message list if p_init_msg_list is set to TRUE.
    IF FND_API.to_Boolean(p_init_msg_list) THEN
      FND_MSG_PUB.initialize;
    END IF;

    --Initialize API return status to success.
    x_return_status := FND_API.G_RET_STS_SUCCESS;

    get_current_financial_number(
      1, FND_API.G_FALSE,
      l_financial_numbers_rec.financial_number_id,
      l_old_financial_numbers_rec,
      x_return_status,
      x_msg_count,
      x_msg_data);

    IF x_return_status = FND_API.G_RET_STS_ERROR THEN
      RAISE FND_API.G_EXC_ERROR;
    ELSIF x_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;

    -- Bug 2197181: added for mix-n-match project. first load data
    -- sources for this entity.

    -- Bug 2444678: Removed caching.

    -- IF g_fin_mixnmatch_enabled IS NULL THEN
 * SSM SST Integration and Extension
 * For non-profile entities, the concept of select/de-select data-sources is obsoleted.
 * There is no need to check if the data-source is selected.

    HZ_MIXNM_UTILITY.LoadDataSources(
      p_entity_name                    => 'HZ_FINANCIAL_REPORTS',
      p_entity_attr_id                 => g_fin_entity_attr_id,
      p_mixnmatch_enabled              => g_fin_mixnmatch_enabled,
      p_selected_datasources           => g_fin_selected_datasources );
 *
    -- END IF;

********************this code is replaced to go via V2 API.
    -- Call to business logic.
    do_update_financial_numbers(
      l_financial_numbers_rec,
      p_last_update_date,
      x_return_status);
************************

    -- call to perform everything through V2 API
    HZ_ORGANIZATION_INFO_V2PVT.v2_update_financial_number (
      l_financial_numbers_rec,
      p_last_update_date,
      x_return_status
    );

*
    -- Invoke business event system.
    IF x_return_status = FND_API.G_RET_STS_SUCCESS AND
       -- Bug 2197181: Added below condition for Mix-n-Match
       g_fin_is_datasource_selected = 'Y'
    THEN
      HZ_BUSINESS_EVENT_V2PVT.update_fin_numbers_event(l_financial_numbers_rec);
    END IF;
*

    --Standard check of p_commit.
    IF FND_API.to_Boolean(p_commit) THEN
      Commit;
    END IF;

    --Standard call to get message count and if count is 1, get message info.
    FND_MSG_PUB.Count_And_Get(
      p_encoded => FND_API.G_FALSE,
      p_count => x_msg_count,
      p_data  => x_msg_data);

EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN
      ROLLBACK TO update_financial_numbers_pub;
      x_return_status := FND_API.G_RET_STS_ERROR;

      FND_MSG_PUB.Count_And_Get(
        p_encoded => FND_API.G_FALSE,
        p_count => x_msg_count,
        p_data  => x_msg_data);

    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
      ROLLBACK TO update_financial_numbers_pub;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

      FND_MSG_PUB.Count_And_Get(
        p_encoded => FND_API.G_FALSE,
        p_count => x_msg_count,
        p_data  => x_msg_data);

    WHEN OTHERS THEN
      ROLLBACK TO update_financial_numbers_pub;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

      FND_MESSAGE.SET_NAME('AR', 'HZ_API_OTHERS_EXCEP');
      FND_MESSAGE.SET_TOKEN('ERROR' ,SQLERRM);
      FND_MSG_PUB.ADD;

      FND_MSG_PUB.Count_And_Get(
        p_encoded => FND_API.G_FALSE,
        p_count => x_msg_count,
        p_data  => x_msg_data);

END update_financial_numbers;
END Obsolete V1 API
*/
/*===========================================================================+
 | PROCEDURE
 |              create_certifications
 |
 | DESCRIPTION
 |              Creates certifications.
 |
 | SCOPE - PUBLIC
 |
 | EXETERNAL PROCEDURES/FUNCTIONS ACCESSED
 |
 | ARGUMENTS  : IN:
 |                    p_api_version
 |                    p_init_msg_list
 |                    p_commit
 |                    p_certifications_rec
 |                    p_validation_level
 |              OUT:
 |                    x_return_status
 |                    x_msg_count
 |                    x_msg_data
 |                    x_certification_id
 |          IN/ OUT:
 |
 | RETURNS    : NONE
 |
 | NOTES
 |
 | MODIFICATION HISTORY
 |
 +===========================================================================*/

procedure create_certifications(
        p_api_version           IN      NUMBER,
        p_init_msg_list         IN      VARCHAR2:= FND_API.G_FALSE,
        p_commit                IN      VARCHAR2:= FND_API.G_FALSE,
        p_certifications_rec    IN      CERTIFICATIONS_REC_TYPE,
        x_return_status         OUT     NOCOPY VARCHAR2,
        x_msg_count             OUT     NOCOPY NUMBER,
        x_msg_data              OUT     NOCOPY VARCHAR2,
        x_certification_id      OUT     NOCOPY NUMBER,
        p_validation_level      IN      NUMBER :=FND_API.G_VALID_LEVEL_FULL
) IS
        l_api_name              CONSTANT VARCHAR2(30)   := 'create certifications';
        l_api_version           CONSTANT  NUMBER        := 1.0;
        l_certifications_rec    CERTIFICATIONS_REC_TYPE := p_certifications_rec;

BEGIN
--Standard start of API savepoint
        SAVEPOINT create_certifications_pub;
--Standard call to check for call compatibility.
        IF NOT FND_API.Compatible_API_Call(
                                        l_api_version,
                                        p_api_version,
                                        l_api_name,
                                        G_PKG_NAME)
        THEN
                RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
        END IF;

--Initialize message list if p_init_msg_list is set to TRUE.
        IF FND_API.to_Boolean(p_init_msg_list) THEN
                FND_MSG_PUB.initialize;
        END IF;

--Initialize API return status to success.
        x_return_status := FND_API.G_RET_STS_SUCCESS;

/*
--Call to User-Hook pre Processing Procedure
      IF fnd_profile.value('HZ_EXECUTE_API_CALLOUTS') = 'Y' THEN
        hz_org_info_crmhk.create_certifications_pre(
                        l_certifications_rec,
                        x_return_status,
                        x_msg_count,
                        x_msg_data);

        IF x_return_status = FND_API.G_RET_STS_ERROR THEN
                RAISE FND_API.G_EXC_ERROR;
        ELSIF x_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
                FND_MESSAGE.SET_NAME('AR', 'HZ_API_HOOK_ERROR');
                FND_MESSAGE.SET_TOKEN('PROCEDURE',
                                'HZ_ORG_INFO_CRMHK.CREATE_CERTIFICATIONS_PRE');
                FND_MESSAGE.SET_TOKEN('ERROR' ,SQLERRM);
                FND_MSG_PUB.ADD;
                RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
        END IF;

       END IF;
*/

-- Call to business logic.
-- Call PL/SQL wrapper over table handler
        do_create_certifications( l_certifications_rec,
                                  x_certification_id,
                                  x_return_status);

/*
--Call to User-Hook post Processing Procedure
      IF fnd_profile.value('HZ_EXECUTE_API_CALLOUTS') = 'Y' THEN
        hz_org_info_crmhk.create_certifications_post(
                        l_certifications_rec,
                        x_return_status,
                        x_msg_count,
                        x_msg_data);

        IF x_return_status = FND_API.G_RET_STS_ERROR THEN
                RAISE FND_API.G_EXC_ERROR;
        ELSIF x_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
                FND_MESSAGE.SET_NAME('AR', 'HZ_API_HOOK_ERROR');
                FND_MESSAGE.SET_TOKEN('PROCEDURE',
                                'HZ_ORG_INFO_CRMHK.CREATE_CERTIFICATIONS_POST');
                FND_MESSAGE.SET_TOKEN('ERROR' ,SQLERRM);
                FND_MSG_PUB.ADD;
                RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
        END IF;

       END IF;
*/

   IF x_return_status = FND_API.G_RET_STS_SUCCESS THEN
     IF(HZ_UTILITY_V2PUB.G_EXECUTE_API_CALLOUTS in ('Y', 'EVENTS_ENABLED')) THEN
       hz_business_event_v2pvt.create_certifications_event(l_certifications_rec);
     END IF;

     IF(HZ_UTILITY_V2PUB.G_EXECUTE_API_CALLOUTS in ('EVENTS_ENABLED', 'BO_EVENTS_ENABLED')) THEN
       -- populate function for integration service
       HZ_POPULATE_BOT_PKG.pop_hz_certifications(
         p_operation        => 'I',
         p_certification_id => x_certification_id);
     END IF;
   END IF;

--Standard check of p_commit.
        IF FND_API.to_Boolean(p_commit) THEN
                Commit;
        END IF;

--Standard call to get message count and if count is 1, get message info.
        FND_MSG_PUB.Count_And_Get(
                p_encoded => FND_API.G_FALSE,
                p_count => x_msg_count,
                p_data  => x_msg_data);
EXCEPTION
        WHEN FND_API.G_EXC_ERROR THEN
                ROLLBACK TO create_certifications_pub;
                x_return_status := FND_API.G_RET_STS_ERROR;
                FND_MSG_PUB.Count_And_Get(
                                p_encoded => FND_API.G_FALSE,
                                p_count => x_msg_count,
                                p_data  => x_msg_data);

        WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
                ROLLBACK TO create_certifications_pub;
                x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
                FND_MSG_PUB.Count_And_Get(
                                p_encoded => FND_API.G_FALSE,
                                p_count => x_msg_count,
                                p_data  => x_msg_data);
        WHEN OTHERS THEN
                ROLLBACK TO create_certifications_pub;
                x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

                FND_MESSAGE.SET_NAME('AR', 'HZ_API_OTHERS_EXCEP');
                FND_MESSAGE.SET_TOKEN('ERROR' ,SQLERRM);
                FND_MSG_PUB.ADD;

                FND_MSG_PUB.Count_And_Get(
                                p_encoded => FND_API.G_FALSE,
                                p_count => x_msg_count,
                                p_data  => x_msg_data);
END create_certifications;

/*===========================================================================+
 | PROCEDURE
 |              update_certifications
 |
 | DESCRIPTION
 |              Updates certifications.
 |
 | SCOPE - PUBLIC
 |
 | EXETERNAL PROCEDURES/FUNCTIONS ACCESSED
 |
 | ARGUMENTS  : IN:
 |                    p_api_version
 |                    p_init_msg_list
 |                    p_commit
 |                    p_certifications_rec
 |                    p_validation_level
 |              OUT:
 |                    x_return_status
 |                    x_msg_count
 |                    x_msg_data
 |          IN/ OUT:
 |                    p_last_update_date
 |
 | RETURNS    : NONE
 |
 | NOTES
 |
 | MODIFICATION HISTORY
 |
 +===========================================================================*/

procedure update_certifications(
        p_api_version           IN      NUMBER,
        p_init_msg_list         IN      VARCHAR2:= FND_API.G_FALSE,
        p_commit                IN      VARCHAR2:= FND_API.G_FALSE,
        p_certifications_rec    IN      CERTIFICATIONS_REC_TYPE,
        p_last_update_date      IN OUT  NOCOPY DATE,
        x_return_status         OUT     NOCOPY VARCHAR2,
        x_msg_count             OUT     NOCOPY NUMBER,
        x_msg_data              OUT     NOCOPY VARCHAR2,
        p_validation_level      IN      NUMBER :=FND_API.G_VALID_LEVEL_FULL
) IS
        l_api_name              CONSTANT VARCHAR2(30) := 'update certifications';
        l_api_version           CONSTANT  NUMBER       := 1.0;
        l_certifications_rec    CERTIFICATIONS_REC_TYPE := p_certifications_rec;
        l_old_certifications_rec    CERTIFICATIONS_REC_TYPE ;

BEGIN
--Standard start of API savepoint
        SAVEPOINT update_certifications_pub;
--Standard call to check for call compatibility.
        IF NOT FND_API.Compatible_API_Call(
                                        l_api_version,
                                        p_api_version,
                                        l_api_name,
                                        G_PKG_NAME)
        THEN
                RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
        END IF;

--Initialize message list if p_init_msg_list is set to TRUE.
        IF FND_API.to_Boolean(p_init_msg_list) THEN
                FND_MSG_PUB.initialize;
        END IF;

--Initialize API return status to success.
        x_return_status := FND_API.G_RET_STS_SUCCESS;

/*
    get_current_certifications(1,
                               FND_API.G_FALSE,
                               l_certifications_rec.certification_id,
                               l_old_certifications_rec,
                               x_return_status,
                               x_msg_count,
                               x_msg_data);

    IF x_return_status = FND_API.G_RET_STS_ERROR THEN
        RAISE FND_API.G_EXC_ERROR;
    ELSIF x_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;
*/

/*
--Call to User-Hook pre Processing Procedure
      IF fnd_profile.value('HZ_EXECUTE_API_CALLOUTS') = 'Y'  THEN
        hz_org_info_crmhk.update_certifications_pre(
                        l_certifications_rec,
                        x_return_status,
                        x_msg_count,
                        x_msg_data);

        IF x_return_status = FND_API.G_RET_STS_ERROR THEN
                RAISE FND_API.G_EXC_ERROR;
        ELSIF x_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
                FND_MESSAGE.SET_NAME('AR', 'HZ_API_HOOK_ERROR');
                FND_MESSAGE.SET_TOKEN('PROCEDURE',
                                'HZ_ORG_INFO_CRMHK.UPDATE_CERTIFICATIONS_PRE');
                FND_MESSAGE.SET_TOKEN('ERROR' ,SQLERRM);
                FND_MSG_PUB.ADD;
                RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
        END IF;

       END IF;
*/

-- Call to business logic.
-- Call PL/SQL wrapper over table handler
        do_update_certifications( l_certifications_rec,
                                  p_last_update_date,
                                  x_return_status);

/*
--Call to User-Hook post Processing Procedure
      IF fnd_profile.value('HZ_EXECUTE_API_CALLOUTS') = 'Y' THEN
        hz_org_info_crmhk.update_certifications_post(
                        l_certifications_rec,
                        x_return_status,
                        x_msg_count,
                        x_msg_data);

        IF x_return_status = FND_API.G_RET_STS_ERROR THEN
                RAISE FND_API.G_EXC_ERROR;
        ELSIF x_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
                FND_MESSAGE.SET_NAME('AR', 'HZ_API_HOOK_ERROR');
                FND_MESSAGE.SET_TOKEN('PROCEDURE',
                                'HZ_ORG_INFO_CRMHK.UPDATE_CERTIFICATIONS_POST');
                FND_MESSAGE.SET_TOKEN('ERROR' ,SQLERRM);
                FND_MSG_PUB.ADD;
                RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
        END IF;

       END IF;
*/

   IF x_return_status = FND_API.G_RET_STS_SUCCESS THEN
     IF(HZ_UTILITY_V2PUB.G_EXECUTE_API_CALLOUTS in ('Y', 'EVENTS_ENABLED')) THEN
       hz_business_event_v2pvt.update_certifications_event(l_certifications_rec);
     END IF;

     IF(HZ_UTILITY_V2PUB.G_EXECUTE_API_CALLOUTS in ('EVENTS_ENABLED', 'BO_EVENTS_ENABLED')) THEN
       -- populate function for integration service
       HZ_POPULATE_BOT_PKG.pop_hz_certifications(
         p_operation        => 'U',
         p_certification_id => l_certifications_rec.certification_id);
     END IF;
   END IF;

--Standard check of p_commit.
        IF FND_API.to_Boolean(p_commit) THEN
                Commit;
        END IF;

--Standard call to get message count and if count is 1, get message info.
        FND_MSG_PUB.Count_And_Get(
                p_encoded => FND_API.G_FALSE,
                p_count => x_msg_count,
                p_data  => x_msg_data);
EXCEPTION
        WHEN FND_API.G_EXC_ERROR THEN
                ROLLBACK TO update_certifications_pub;
                x_return_status := FND_API.G_RET_STS_ERROR;
                FND_MSG_PUB.Count_And_Get(
                                p_encoded => FND_API.G_FALSE,
                                p_count => x_msg_count,
                                p_data  => x_msg_data);

        WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
                ROLLBACK TO update_certifications_pub;
                x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
                FND_MSG_PUB.Count_And_Get(
                                p_encoded => FND_API.G_FALSE,
                                p_count => x_msg_count,
                                p_data  => x_msg_data);

        WHEN OTHERS THEN
                ROLLBACK TO update_certifications_pub;
                x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

                FND_MESSAGE.SET_NAME('AR', 'HZ_API_OTHERS_EXCEP');
                FND_MESSAGE.SET_TOKEN('ERROR' ,SQLERRM);
                FND_MSG_PUB.ADD;

                FND_MSG_PUB.Count_And_Get(
                                p_encoded => FND_API.G_FALSE,
                                p_count => x_msg_count,
                                p_data  => x_msg_data);

END update_certifications;

/*===========================================================================+
 | PROCEDURE
 |              create_industrial_reference
 |
 | DESCRIPTION
 |              Creates industrial reference.
 |
 | SCOPE - PUBLIC
 |
 | EXETERNAL PROCEDURES/FUNCTIONS ACCESSED
 |
 | ARGUMENTS  : IN:
 |                    p_api_version
 |                    p_init_msg_list
 |                    p_commit
 |                    p_industrial_reference_rec
 |                    p_validation_level
 |              OUT:
 |                    x_return_status
 |                    x_msg_count
 |                    x_msg_data
 |                    x_industrial_reference_id
 |          IN/ OUT:
 |
 | RETURNS    : NONE
 |
 | NOTES
 |
 | MODIFICATION HISTORY
 |
 +===========================================================================*/

procedure create_industrial_reference(
        p_api_version               IN      NUMBER,
        p_init_msg_list             IN      VARCHAR2:= FND_API.G_FALSE,
        p_commit                    IN      VARCHAR2:= FND_API.G_FALSE,
        p_industrial_reference_rec  IN      INDUSTRIAL_REFERENCE_REC_TYPE,
        x_return_status             OUT     NOCOPY VARCHAR2,
        x_msg_count                 OUT     NOCOPY NUMBER,
        x_msg_data                  OUT     NOCOPY VARCHAR2,
        x_industry_reference_id     OUT     NOCOPY NUMBER,
        p_validation_level          IN      NUMBER :=FND_API.G_VALID_LEVEL_FULL
) IS
        l_api_name                  CONSTANT VARCHAR2(30) := 'create industrial reference';
        l_api_version               CONSTANT  NUMBER       := 1.0;
        l_industrial_reference_rec  INDUSTRIAL_REFERENCE_REC_TYPE := p_industrial_reference_rec;

BEGIN
--Standard start of API savepoint
        SAVEPOINT create_industrial_ref_pub;
--Standard call to check for call compatibility.
        IF NOT FND_API.Compatible_API_Call(
                                        l_api_version,
                                        p_api_version,
                                        l_api_name,
                                        G_PKG_NAME)
        THEN
                RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
        END IF;

--Initialize message list if p_init_msg_list is set to TRUE.
        IF FND_API.to_Boolean(p_init_msg_list) THEN
                FND_MSG_PUB.initialize;
        END IF;

--Initialize API return status to success.
        x_return_status := FND_API.G_RET_STS_SUCCESS;

/*
--Call to User-Hook pre Processing Procedure
      IF fnd_profile.value('HZ_EXECUTE_API_CALLOUTS') = 'Y' THEN
        hz_org_info_crmhk.create_industrial_ref_pre(
                        l_industrial_reference_rec,
                        x_return_status,
                        x_msg_count,
                        x_msg_data);

        IF x_return_status = FND_API.G_RET_STS_ERROR THEN
                RAISE FND_API.G_EXC_ERROR;
        ELSIF x_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
                FND_MESSAGE.SET_NAME('AR', 'HZ_API_HOOK_ERROR');
                FND_MESSAGE.SET_TOKEN('PROCEDURE',
                                'HZ_ORG_INFO_CRMHK.CREATE_INDUSTRIAL_REF_PRE');
                FND_MESSAGE.SET_TOKEN('ERROR' ,SQLERRM);
                FND_MSG_PUB.ADD;
                RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
        END IF;

       END IF;
*/

-- Call to business logic.
-- Call PL/SQL wrapper over table handler
        do_create_industrial_reference( l_industrial_reference_rec,
                                        x_industry_reference_id,
                                        x_return_status);

/*
--Call to User-Hook post Processing Procedure
      IF fnd_profile.value('HZ_EXECUTE_API_CALLOUTS') = 'Y' THEN
        hz_org_info_crmhk.create_industrial_ref_post(
                        l_industrial_reference_rec,
                        x_return_status,
                        x_msg_count,
                        x_msg_data);

        IF x_return_status = FND_API.G_RET_STS_ERROR THEN
                RAISE FND_API.G_EXC_ERROR;
        ELSIF x_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
                FND_MESSAGE.SET_NAME('AR', 'HZ_API_HOOK_ERROR');
                FND_MESSAGE.SET_TOKEN('PROCEDURE',
                                'HZ_ORG_INFO_CRMHK.CREATE_INDUSTRIAL_REF_POST');
                FND_MESSAGE.SET_TOKEN('ERROR' ,SQLERRM);
                FND_MSG_PUB.ADD;
                RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
        END IF;

       END IF;
*/


--Standard check of p_commit.
        IF FND_API.to_Boolean(p_commit) THEN
                Commit;
        END IF;

--Standard call to get message count and if count is 1, get message info.
        FND_MSG_PUB.Count_And_Get(
                p_encoded => FND_API.G_FALSE,
                p_count => x_msg_count,
                p_data  => x_msg_data);
EXCEPTION
        WHEN FND_API.G_EXC_ERROR THEN
                ROLLBACK TO create_industrial_ref_pub;
                x_return_status := FND_API.G_RET_STS_ERROR;
                FND_MSG_PUB.Count_And_Get(
                                p_encoded => FND_API.G_FALSE,
                                p_count => x_msg_count,
                                p_data  => x_msg_data);

        WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
                ROLLBACK TO create_industrial_ref_pub;
                x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
                FND_MSG_PUB.Count_And_Get(
                                p_encoded => FND_API.G_FALSE,
                                p_count => x_msg_count,
                                p_data  => x_msg_data);

        WHEN OTHERS THEN
                ROLLBACK TO create_industrial_ref_pub;
                x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

                FND_MESSAGE.SET_NAME('AR', 'HZ_API_OTHERS_EXCEP');
                FND_MESSAGE.SET_TOKEN('ERROR' ,SQLERRM);
                FND_MSG_PUB.ADD;

                FND_MSG_PUB.Count_And_Get(
                                p_encoded => FND_API.G_FALSE,
                                p_count => x_msg_count,
                                p_data  => x_msg_data);

end create_industrial_reference;

/*===========================================================================+
 | PROCEDURE
 |              update_industrial_reference
 |
 | DESCRIPTION
 |              Updates industrial_reference.
 |
 | SCOPE - PUBLIC
 |
 | EXETERNAL PROCEDURES/FUNCTIONS ACCESSED
 |
 | ARGUMENTS  : IN:
 |                    p_api_version
 |                    p_init_msg_list
 |                    p_commit
 |                    p_industrial_reference_rec
 |                    p_validation_level
 |              OUT:
 |                    x_return_status
 |                    x_msg_count
 |                    x_msg_data
 |          IN/ OUT:
 |                    p_last_update_date
 |
 | RETURNS    : NONE
 |
 | NOTES
 |
 | MODIFICATION HISTORY
 |
 +===========================================================================*/

procedure update_industrial_reference(
        p_api_version               IN      NUMBER,
        p_init_msg_list             IN      VARCHAR2:= FND_API.G_FALSE,
        p_commit                    IN      VARCHAR2:= FND_API.G_FALSE,
        p_industrial_reference_rec  IN      INDUSTRIAL_REFERENCE_REC_TYPE,
        p_last_update_date          IN OUT  NOCOPY DATE,
        x_return_status             OUT     NOCOPY VARCHAR2,
        x_msg_count                 OUT     NOCOPY NUMBER,
        x_msg_data                  OUT     NOCOPY VARCHAR2,
        p_validation_level          IN      NUMBER :=FND_API.G_VALID_LEVEL_FULL
) IS
        l_api_name                  CONSTANT VARCHAR2(30) := 'update industrial reference';
        l_api_version               CONSTANT  NUMBER       := 1.0;
        l_industrial_reference_rec  INDUSTRIAL_REFERENCE_REC_TYPE := p_industrial_reference_rec;
BEGIN
--Standard start of API savepoint
        SAVEPOINT update_industrial_ref_pub;
--Standard call to check for call compatibility.
        IF NOT FND_API.Compatible_API_Call(
                                        l_api_version,
                                        p_api_version,
                                        l_api_name,
                                        G_PKG_NAME)
        THEN
                RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
        END IF;

--Initialize message list if p_init_msg_list is set to TRUE.
        IF FND_API.to_Boolean(p_init_msg_list) THEN
                FND_MSG_PUB.initialize;
        END IF;

--Initialize API return status to success.
        x_return_status := FND_API.G_RET_STS_SUCCESS;

/*
--Call to User-Hook pre Processing Procedure
      IF fnd_profile.value('HZ_EXECUTE_API_CALLOUTS') = 'Y' THEN
        hz_org_info_crmhk.update_industrial_ref_pre(
                        l_industrial_reference_rec,
                        x_return_status,
                        x_msg_count,
                        x_msg_data);

        IF x_return_status = FND_API.G_RET_STS_ERROR THEN
                RAISE FND_API.G_EXC_ERROR;
        ELSIF x_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
                FND_MESSAGE.SET_NAME('AR', 'HZ_API_HOOK_ERROR');
                FND_MESSAGE.SET_TOKEN('PROCEDURE',
                                'HZ_ORG_INFO_CRMHK.UPDATE_INDUSTRIAL_REF_PRE');
                FND_MESSAGE.SET_TOKEN('ERROR' ,SQLERRM);
                FND_MSG_PUB.ADD;
                RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
        END IF;

       END IF;
*/
-- Call to business logic.
-- Call PL/SQL wrapper over table handler
        do_update_industrial_reference( l_industrial_reference_rec,
                                        p_last_update_date,
                                        x_return_status);

/*
--Call to User-Hook post Processing Procedure
      IF fnd_profile.value('HZ_EXECUTE_API_CALLOUTS') = 'Y' THEN
        hz_org_info_crmhk.update_industrial_ref_post(
                        l_industrial_reference_rec,
                        x_return_status,
                        x_msg_count,
                        x_msg_data);

        IF x_return_status = FND_API.G_RET_STS_ERROR THEN
                RAISE FND_API.G_EXC_ERROR;
        ELSIF x_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
                FND_MESSAGE.SET_NAME('AR', 'HZ_API_HOOK_ERROR');
                FND_MESSAGE.SET_TOKEN('PROCEDURE',
                                'HZ_ORG_INFO_CRMHK.UPDATE_INDUSTRIAL_REF_POST');
                FND_MESSAGE.SET_TOKEN('ERROR' ,SQLERRM);
                FND_MSG_PUB.ADD;
                RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
        END IF;

       END IF;
*/

--Standard check of p_commit.
        IF FND_API.to_Boolean(p_commit) THEN
                Commit;
        END IF;

--Standard call to get message count and if count is 1, get message info.
        FND_MSG_PUB.Count_And_Get(
                p_encoded => FND_API.G_FALSE,
                p_count => x_msg_count,
                p_data  => x_msg_data);
EXCEPTION
        WHEN FND_API.G_EXC_ERROR THEN
                ROLLBACK TO update_industrial_ref_pub;
                x_return_status := FND_API.G_RET_STS_ERROR;
                FND_MSG_PUB.Count_And_Get(
                                p_encoded => FND_API.G_FALSE,
                                p_count => x_msg_count,
                                p_data  => x_msg_data);

        WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
                ROLLBACK TO update_industrial_ref_pub;
                x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
                FND_MSG_PUB.Count_And_Get(
                                p_encoded => FND_API.G_FALSE,
                                p_count => x_msg_count,
                                p_data  => x_msg_data);

        WHEN OTHERS THEN
                ROLLBACK TO update_industrial_ref_pub;
                x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

                FND_MESSAGE.SET_NAME('AR', 'HZ_API_OTHERS_EXCEP');
                FND_MESSAGE.SET_TOKEN('ERROR' ,SQLERRM);
                FND_MSG_PUB.ADD;

                FND_MSG_PUB.Count_And_Get(
                                p_encoded => FND_API.G_FALSE,
                                p_count => x_msg_count,
                                p_data  => x_msg_data);

END update_industrial_reference;

/*===========================================================================+
 | PROCEDURE
 |              create_industrial_classes
 |
 | DESCRIPTION
 |              Creates industrial classes.
 |
 | SCOPE - PUBLIC
 |
 | EXETERNAL PROCEDURES/FUNCTIONS ACCESSED
 |
 | ARGUMENTS  : IN:
 |                    p_api_version
 |                    p_init_msg_list
 |                    p_commit
 |                    p_industrial_classes_rec
 |                    p_validation_level
 |              OUT:
 |                    x_return_status
 |                    x_msg_count
 |                    x_msg_data
 |                    x_industrial_class_id
 |          IN/ OUT:
 |
 | RETURNS    : NONE
 |
 | NOTES
 |
 | MODIFICATION HISTORY
 |
 +===========================================================================*/

procedure create_industrial_classes(
        p_api_version             IN      NUMBER,
        p_init_msg_list           IN      VARCHAR2:= FND_API.G_FALSE,
        p_commit                  IN      VARCHAR2:= FND_API.G_FALSE,
        p_industrial_classes_rec  IN      INDUSTRIAL_CLASSES_REC_TYPE,
        x_return_status           OUT     NOCOPY VARCHAR2,
        x_msg_count               OUT     NOCOPY NUMBER,
        x_msg_data                OUT     NOCOPY VARCHAR2,
        x_industrial_class_id     OUT     NOCOPY NUMBER,
        p_validation_level        IN      NUMBER :=FND_API.G_VALID_LEVEL_FULL
) IS
        l_api_name                CONSTANT VARCHAR2(30) := 'create industrial classes';
        l_api_version             CONSTANT  NUMBER       := 1.0;
        l_industrial_classes_rec  INDUSTRIAL_CLASSES_REC_TYPE := p_industrial_classes_rec;
BEGIN
--Standard start of API savepoint
        SAVEPOINT create_industrial_classes_pub;
--Standard call to check for call compatibility.
        IF NOT FND_API.Compatible_API_Call(
                                        l_api_version,
                                        p_api_version,
                                        l_api_name,
                                        G_PKG_NAME)
        THEN
                RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
        END IF;

--Initialize message list if p_init_msg_list is set to TRUE.
        IF FND_API.to_Boolean(p_init_msg_list) THEN
                FND_MSG_PUB.initialize;
        END IF;

--Initialize API return status to success.
        x_return_status := FND_API.G_RET_STS_SUCCESS;

/*
--Call to User-Hook pre Processing Procedure
      IF  fnd_profile.value('HZ_EXECUTE_API_CALLOUTS') = 'Y' THEN
        hz_org_info_crmhk.create_industrial_classes_pre(
                        l_industrial_classes_rec,
                        x_return_status,
                        x_msg_count,
                        x_msg_data);

        IF x_return_status = FND_API.G_RET_STS_ERROR THEN
                RAISE FND_API.G_EXC_ERROR;
        ELSIF x_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
                FND_MESSAGE.SET_NAME('AR', 'HZ_API_HOOK_ERROR');
                FND_MESSAGE.SET_TOKEN('PROCEDURE',
                                'HZ_ORG_INFO_CRMHK.CREATE_INDUSTRIAL_CLASSES_PRE');
                FND_MESSAGE.SET_TOKEN('ERROR' ,SQLERRM);
                FND_MSG_PUB.ADD;
                RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
        END IF;

       END IF;
*/
-- Call to business logic.
-- Call PL/SQL wrapper over table handler
        do_create_industrial_classes( l_industrial_classes_rec,
                                      x_industrial_class_id,
                                      x_return_status);

/*
--Call to User-Hook post Processing Procedure
      IF fnd_profile.value('HZ_EXECUTE_API_CALLOUTS') = 'Y' THEN
        hz_org_info_crmhk.create_industrial_classes_post(
                        l_industrial_classes_rec,
                        x_return_status,
                        x_msg_count,
                        x_msg_data);

        IF x_return_status = FND_API.G_RET_STS_ERROR THEN
                RAISE FND_API.G_EXC_ERROR;
        ELSIF x_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
                FND_MESSAGE.SET_NAME('AR', 'HZ_API_HOOK_ERROR');
                FND_MESSAGE.SET_TOKEN('PROCEDURE',
                                'HZ_ORG_INFO_CRMHK.CREATE_INDUSTRIAL_CLASSES_POST');
                FND_MESSAGE.SET_TOKEN('ERROR' ,SQLERRM);
                FND_MSG_PUB.ADD;
                RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
        END IF;

       END IF;
*/

--Standard check of p_commit.
        IF FND_API.to_Boolean(p_commit) THEN
                Commit;
        END IF;

--Standard call to get message count and if count is 1, get message info.
        FND_MSG_PUB.Count_And_Get(
                p_encoded => FND_API.G_FALSE,
                p_count => x_msg_count,
                p_data  => x_msg_data);
EXCEPTION
        WHEN FND_API.G_EXC_ERROR THEN
                ROLLBACK TO create_industrial_classes_pub;
                x_return_status := FND_API.G_RET_STS_ERROR;
                FND_MSG_PUB.Count_And_Get(
                                p_encoded => FND_API.G_FALSE,
                                p_count => x_msg_count,
                                p_data  => x_msg_data);

        WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
                ROLLBACK TO create_industrial_classes_pub;
                x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
                FND_MSG_PUB.Count_And_Get(
                                p_encoded => FND_API.G_FALSE,
                                p_count => x_msg_count,
                                p_data  => x_msg_data);

        WHEN OTHERS THEN
                ROLLBACK TO create_industrial_classes_pub;
                x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

                FND_MESSAGE.SET_NAME('AR', 'HZ_API_OTHERS_EXCEP');
                FND_MESSAGE.SET_TOKEN('ERROR' ,SQLERRM);
                FND_MSG_PUB.ADD;

                FND_MSG_PUB.Count_And_Get(
                                p_encoded => FND_API.G_FALSE,
                                p_count => x_msg_count,
                                p_data  => x_msg_data);

END create_industrial_classes;

/*===========================================================================+
 | PROCEDURE
 |              update_industrial_classes
 |
 | DESCRIPTION
 |              Updates industrial classes.
 |
 | SCOPE - PUBLIC
 |
 | EXETERNAL PROCEDURES/FUNCTIONS ACCESSED
 |
 | ARGUMENTS  : IN:
 |                    p_api_version
 |                    p_init_msg_list
 |                    p_commit
 |                    p_industrial_classes_rec
 |                    p_validation_level
 |              OUT:
 |                    x_return_status
 |                    x_msg_count
 |                    x_msg_data
 |          IN/ OUT:
 |                    p_last_update_date
 |
 | RETURNS    : NONE
 |
 | NOTES
 |
 | MODIFICATION HISTORY
 |
 +===========================================================================*/

procedure update_industrial_classes(
        p_api_version                IN      NUMBER,
        p_init_msg_list              IN      VARCHAR2:= FND_API.G_FALSE,
        p_commit                     IN      VARCHAR2:= FND_API.G_FALSE,
        p_industrial_classes_rec     IN      INDUSTRIAL_CLASSES_REC_TYPE,
        p_last_update_date           IN OUT  NOCOPY DATE,
        x_return_status              OUT     NOCOPY VARCHAR2,
        x_msg_count                  OUT     NOCOPY NUMBER,
        x_msg_data                   OUT     NOCOPY VARCHAR2,
        p_validation_level           IN      NUMBER :=FND_API.G_VALID_LEVEL_FULL
) IS

        l_api_name                   CONSTANT VARCHAR2(30) := 'update industrial classes';
        l_api_version                CONSTANT  NUMBER       := 1.0;
        l_industrial_classes_rec     INDUSTRIAL_CLASSES_REC_TYPE := p_industrial_classes_rec;
        l_old_industrial_classes_rec INDUSTRIAL_CLASSES_REC_TYPE;
BEGIN
--Standard start of API savepoint
        SAVEPOINT update_industrial_classes_pub;
--Standard call to check for call compatibility.
        IF NOT FND_API.Compatible_API_Call(
                                        l_api_version,
                                        p_api_version,
                                        l_api_name,
                                        G_PKG_NAME)
        THEN
                RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
        END IF;

--Initialize message list if p_init_msg_list is set to TRUE.
        IF FND_API.to_Boolean(p_init_msg_list) THEN
                FND_MSG_PUB.initialize;
        END IF;

--Initialize API return status to success.
        x_return_status := FND_API.G_RET_STS_SUCCESS;

--Get the old record.
        get_current_industrial_classes(
                1,
                FND_API.G_FALSE,
                l_industrial_classes_rec.industrial_class_id,
                l_old_industrial_classes_rec,
                x_return_status,
                x_msg_count,
                x_msg_data);

/*
--Call to User-Hook pre Processing Procedure
      IF fnd_profile.value('HZ_EXECUTE_API_CALLOUTS') = 'Y' THEN
        hz_org_info_crmhk.update_industrial_classes_pre(
                        l_industrial_classes_rec,
                        l_old_industrial_classes_rec,
                        x_return_status,
                        x_msg_count,
                        x_msg_data);

        IF x_return_status = FND_API.G_RET_STS_ERROR THEN
                RAISE FND_API.G_EXC_ERROR;
        ELSIF x_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
                FND_MESSAGE.SET_NAME('AR', 'HZ_API_HOOK_ERROR');
                FND_MESSAGE.SET_TOKEN('PROCEDURE',
                                'HZ_ORG_INFO_CRMHK.UPDATE_INDUSTRIAL_CLASSES_PRE');
                FND_MESSAGE.SET_TOKEN('ERROR' ,SQLERRM);
                FND_MSG_PUB.ADD;
                RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
        END IF;

       END IF;
*/

-- Call to business logic.
-- Call PL/SQL wrapper over table handler
        do_update_industrial_classes( l_industrial_classes_rec,
                                      p_last_update_date,
                                      x_return_status);

/*
--Call to User-Hook post Processing Procedure
      IF  fnd_profile.value('HZ_EXECUTE_API_CALLOUTS') = 'Y' THEN
        hz_org_info_crmhk.update_industrial_classes_post(
                        l_industrial_classes_rec,
                        x_return_status,
                        x_msg_count,
                        x_msg_data);

        IF x_return_status = FND_API.G_RET_STS_ERROR THEN
                RAISE FND_API.G_EXC_ERROR;
        ELSIF x_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
                FND_MESSAGE.SET_NAME('AR', 'HZ_API_HOOK_ERROR');
                FND_MESSAGE.SET_TOKEN('PROCEDURE',
                                'HZ_ORG_INFO_CRMHK.UPDATE_INDUSTRIAL_CLASSES_POST');
                FND_MESSAGE.SET_TOKEN('ERROR' ,SQLERRM);
                FND_MSG_PUB.ADD;
                RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
        END IF;

       END IF;
*/

--Standard check of p_commit.
        IF FND_API.to_Boolean(p_commit) THEN
                Commit;
        END IF;

--Standard call to get message count and if count is 1, get message info.
        FND_MSG_PUB.Count_And_Get(
                p_encoded => FND_API.G_FALSE,
                p_count => x_msg_count,
                p_data  => x_msg_data);
EXCEPTION
        WHEN FND_API.G_EXC_ERROR THEN
                ROLLBACK TO update_industrial_classes_pub;
                x_return_status := FND_API.G_RET_STS_ERROR;
                FND_MSG_PUB.Count_And_Get(
                                p_encoded => FND_API.G_FALSE,
                                p_count => x_msg_count,
                                p_data  => x_msg_data);

        WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
                ROLLBACK TO update_industrial_classes_pub;
                x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
                FND_MSG_PUB.Count_And_Get(
                                p_encoded => FND_API.G_FALSE,
                                p_count => x_msg_count,
                                p_data  => x_msg_data);

        WHEN OTHERS THEN
                ROLLBACK TO update_industrial_classes_pub;
                x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

                FND_MESSAGE.SET_NAME('AR', 'HZ_API_OTHERS_EXCEP');
                FND_MESSAGE.SET_TOKEN('ERROR' ,SQLERRM);
                FND_MSG_PUB.ADD;

                FND_MSG_PUB.Count_And_Get(
                                p_encoded => FND_API.G_FALSE,
                                p_count => x_msg_count,
                                p_data  => x_msg_data);

END update_industrial_classes;

/*===========================================================================+
 | PROCEDURE
 |              create_industrial_class_app
 |
 | DESCRIPTION
 |              Creates industrial class app.
 |
 | SCOPE - PUBLIC
 |
 | EXETERNAL PROCEDURES/FUNCTIONS ACCESSED
 |
 | ARGUMENTS  : IN:
 |                    p_api_version
 |                    p_init_msg_list
 |                    p_commit
 |                    p_industrial_class_app_rec
 |                    p_validation_level
 |              OUT:
 |                    x_return_status
 |                    x_msg_count
 |                    x_msg_data
 |                    x_code_applied_id
 |          IN/ OUT:
 |
 | RETURNS    : NONE
 |
 | NOTES
 |
 | MODIFICATION HISTORY
 |
 +===========================================================================*/

procedure create_industrial_class_app(
        p_api_version               IN      NUMBER,
        p_init_msg_list             IN      VARCHAR2:= FND_API.G_FALSE,
        p_commit                    IN      VARCHAR2:= FND_API.G_FALSE,
        p_industrial_class_app_rec  IN      INDUSTRIAL_CLASS_APP_REC_TYPE,
        x_return_status             OUT     NOCOPY VARCHAR2,
        x_msg_count                 OUT     NOCOPY NUMBER,
        x_msg_data                  OUT     NOCOPY VARCHAR2,
        x_code_applied_id           OUT     NOCOPY NUMBER,
        p_validation_level          IN      NUMBER :=FND_API.G_VALID_LEVEL_FULL
) IS
        l_api_name                  CONSTANT VARCHAR2(30)   := 'create industrial class app';
        l_api_version               CONSTANT  NUMBER        := 1.0;
        l_industrial_class_app_rec  INDUSTRIAL_CLASS_APP_REC_TYPE := p_industrial_class_app_rec;
BEGIN
--Standard start of API savepoint
        SAVEPOINT create_indus_class_app_pub;
--Standard call to check for call compatibility.
        IF NOT FND_API.Compatible_API_Call(
                                        l_api_version,
                                        p_api_version,
                                        l_api_name,
                                        G_PKG_NAME)
        THEN
                RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
        END IF;

--Initialize message list if p_init_msg_list is set to TRUE.
        IF FND_API.to_Boolean(p_init_msg_list) THEN
                FND_MSG_PUB.initialize;
        END IF;

--Initialize API return status to success.
        x_return_status := FND_API.G_RET_STS_SUCCESS;

/*
--Call to User-Hook pre Processing Procedure
      IF  fnd_profile.value('HZ_EXECUTE_API_CALLOUTS') = 'Y' THEN
        hz_org_info_crmhk.create_indus_class_app_pre(
                        l_industrial_class_app_rec,
                        x_return_status,
                        x_msg_count,
                        x_msg_data);

        IF x_return_status = FND_API.G_RET_STS_ERROR THEN
                RAISE FND_API.G_EXC_ERROR;
        ELSIF x_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
                FND_MESSAGE.SET_NAME('AR', 'HZ_API_HOOK_ERROR');
                FND_MESSAGE.SET_TOKEN('PROCEDURE',
                                'HZ_ORG_INFO_CRMHK.CREATE_INDUS_CLASS_APP_PRE');
                FND_MESSAGE.SET_TOKEN('ERROR' ,SQLERRM);
                FND_MSG_PUB.ADD;
                RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
        END IF;

       END IF;
*/

-- Call to business logic.
-- Call PL/SQL wrapper over table handler
        do_create_industrial_class_app( l_industrial_class_app_rec,
                                        x_code_applied_id,
                                        x_return_status);

/*
--Call to User-Hook post Processing Procedure
      IF fnd_profile.value('HZ_EXECUTE_API_CALLOUTS') = 'Y' THEN
        hz_org_info_crmhk.create_indus_class_app_post(
                        l_industrial_class_app_rec,
                        x_return_status,
                        x_msg_count,
                        x_msg_data);

        IF x_return_status = FND_API.G_RET_STS_ERROR THEN
                RAISE FND_API.G_EXC_ERROR;
        ELSIF x_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
                FND_MESSAGE.SET_NAME('AR', 'HZ_API_HOOK_ERROR');
                FND_MESSAGE.SET_TOKEN('PROCEDURE',
                                'HZ_ORG_INFO_CRMHK.CREATE_INDUS_CLASS_APP_POST');
                FND_MESSAGE.SET_TOKEN('ERROR' ,SQLERRM);
                FND_MSG_PUB.ADD;
                RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
        END IF;

       END IF;
*/

--Standard check of p_commit.
        IF FND_API.to_Boolean(p_commit) THEN
                Commit;
        END IF;

--Standard call to get message count and if count is 1, get message info.
        FND_MSG_PUB.Count_And_Get(
                p_encoded => FND_API.G_FALSE,
                p_count => x_msg_count,
                p_data  => x_msg_data);
EXCEPTION
        WHEN FND_API.G_EXC_ERROR THEN
                ROLLBACK TO create_indus_class_app_pub;
                x_return_status := FND_API.G_RET_STS_ERROR;
                FND_MSG_PUB.Count_And_Get(
                                p_encoded => FND_API.G_FALSE,
                                p_count => x_msg_count,
                                p_data  => x_msg_data);

        WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
                ROLLBACK TO create_indus_class_app_pub;
                x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
                FND_MSG_PUB.Count_And_Get(
                                p_encoded => FND_API.G_FALSE,
                                p_count => x_msg_count,
                                p_data  => x_msg_data);

        WHEN OTHERS THEN
                ROLLBACK TO create_indus_class_app_pub;
                x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

                FND_MESSAGE.SET_NAME('AR', 'HZ_API_OTHERS_EXCEP');
                FND_MESSAGE.SET_TOKEN('ERROR' ,SQLERRM);
                FND_MSG_PUB.ADD;

                FND_MSG_PUB.Count_And_Get(
                                p_encoded => FND_API.G_FALSE,
                                p_count => x_msg_count,
                                p_data  => x_msg_data);

END create_industrial_class_app;

/*===========================================================================+
 | PROCEDURE
 |              update_industrial_class_app
 |
 | DESCRIPTION
 |              Updates industrial class app.
 |
 | SCOPE - PUBLIC
 |
 | EXETERNAL PROCEDURES/FUNCTIONS ACCESSED
 |
 | ARGUMENTS  : IN:
 |                    p_api_version
 |                    p_init_msg_list
 |                    p_commit
 |                    p_industrial_class_app_rec
 |                    p_validation_level
 |              OUT:
 |                    x_return_status
 |                    x_msg_count
 |                    x_msg_data
 |          IN/ OUT:
 |                    p_last_update_date
 |
 | RETURNS    : NONE
 |
 | NOTES
 |
 | MODIFICATION HISTORY
 |
 +===========================================================================*/

procedure update_industrial_class_app(
        p_api_version               IN      NUMBER,
        p_init_msg_list             IN      VARCHAR2:= FND_API.G_FALSE,
        p_commit                    IN      VARCHAR2:= FND_API.G_FALSE,
        p_industrial_class_app_rec  IN      INDUSTRIAL_CLASS_APP_REC_TYPE,
        p_last_update_date          IN OUT  NOCOPY DATE,
        x_return_status             OUT     NOCOPY VARCHAR2,
        x_msg_count                 OUT     NOCOPY NUMBER,
        x_msg_data                  OUT     NOCOPY VARCHAR2,
        p_validation_level          IN      NUMBER :=FND_API.G_VALID_LEVEL_FULL
) IS
        l_api_name                  CONSTANT VARCHAR2(30) := 'update industrial class app';
        l_api_version               CONSTANT  NUMBER       := 1.0;
        l_industrial_class_app_rec  INDUSTRIAL_CLASS_APP_REC_TYPE := p_industrial_class_app_rec;
BEGIN
--Standard start of API savepoint
        SAVEPOINT update_indus_class_app_pub;
--Standard call to check for call compatibility.
        IF NOT FND_API.Compatible_API_Call(
                                        l_api_version,
                                        p_api_version,
                                        l_api_name,
                                        G_PKG_NAME)
        THEN
                RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
        END IF;

--Initialize message list if p_init_msg_list is set to TRUE.
        IF FND_API.to_Boolean(p_init_msg_list) THEN
                FND_MSG_PUB.initialize;
        END IF;

--Initialize API return status to success.
        x_return_status := FND_API.G_RET_STS_SUCCESS;

/*
--Call to User-Hook pre Processing Procedure
      IF fnd_profile.value('HZ_EXECUTE_API_CALLOUTS') = 'Y' THEN
        hz_org_info_crmhk.update_indus_class_app_pre(
                        l_industrial_class_app_rec,
                        x_return_status,
                        x_msg_count,
                        x_msg_data);

        IF x_return_status = FND_API.G_RET_STS_ERROR THEN
                RAISE FND_API.G_EXC_ERROR;
        ELSIF x_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
                FND_MESSAGE.SET_NAME('AR', 'HZ_API_HOOK_ERROR');
                FND_MESSAGE.SET_TOKEN('PROCEDURE',
                                'HZ_ORG_INFO_CRMHK.CREATE_INDUS_CLASS_APP_PRE');
                FND_MESSAGE.SET_TOKEN('ERROR' ,SQLERRM);
                FND_MSG_PUB.ADD;
                RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
        END IF;

       END IF;
*/

-- Call to business logic.
-- Call PL/SQL wrapper over table handler
        do_update_industrial_class_app( l_industrial_class_app_rec,
                                        p_last_update_date,
                                        x_return_status);

/*
--Call to User-Hook post Processing Procedure
      IF fnd_profile.value('HZ_EXECUTE_API_CALLOUTS') = 'Y' THEN
        hz_org_info_crmhk.update_indus_class_app_post(
                        l_industrial_class_app_rec,
                        x_return_status,
                        x_msg_count,
                        x_msg_data);

        IF x_return_status = FND_API.G_RET_STS_ERROR THEN
                RAISE FND_API.G_EXC_ERROR;
        ELSIF x_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
                FND_MESSAGE.SET_NAME('AR', 'HZ_API_HOOK_ERROR');
                FND_MESSAGE.SET_TOKEN('PROCEDURE',
                                'HZ_ORG_INFO_CRMHK.UPDATE_INDUS_CLASS_APP_POST');
                FND_MESSAGE.SET_TOKEN('ERROR' ,SQLERRM);
                FND_MSG_PUB.ADD;
                RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
        END IF;

       END IF;
*/

--Standard check of p_commit.
        IF FND_API.to_Boolean(p_commit) THEN
                Commit;
        END IF;

--Standard call to get message count and if count is 1, get message info.
        FND_MSG_PUB.Count_And_Get(
                p_encoded => FND_API.G_FALSE,
                p_count => x_msg_count,
                p_data  => x_msg_data);
EXCEPTION
        WHEN FND_API.G_EXC_ERROR THEN
                ROLLBACK TO update_indus_class_app_pub;
                x_return_status := FND_API.G_RET_STS_ERROR;
                FND_MSG_PUB.Count_And_Get(
                                p_encoded => FND_API.G_FALSE,
                                p_count => x_msg_count,
                                p_data  => x_msg_data);

        WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
                ROLLBACK TO update_indus_class_app_pub;
                x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
                FND_MSG_PUB.Count_And_Get(
                                p_encoded => FND_API.G_FALSE,
                                p_count => x_msg_count,
                                p_data  => x_msg_data);

        WHEN OTHERS THEN
                ROLLBACK TO update_indus_class_app_pub;
                x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

                FND_MESSAGE.SET_NAME('AR', 'HZ_API_OTHERS_EXCEP');
                FND_MESSAGE.SET_TOKEN('ERROR' ,SQLERRM);
                FND_MSG_PUB.ADD;

                FND_MSG_PUB.Count_And_Get(
                                p_encoded => FND_API.G_FALSE,
                                p_count => x_msg_count,
                                p_data  => x_msg_data);

END update_industrial_class_app;


procedure get_current_financial_report(
        p_api_version           IN      NUMBER,
        p_init_msg_list         IN      VARCHAR2:= FND_API.G_FALSE,
        p_financial_report_id   IN      NUMBER,
        x_financial_reports_rec OUT     NOCOPY FINANCIAL_REPORTS_REC_TYPE,
        x_return_status         IN OUT     NOCOPY VARCHAR2,
        x_msg_count             OUT     NOCOPY NUMBER,
        x_msg_data              OUT     NOCOPY VARCHAR2
) IS
        l_api_name              CONSTANT VARCHAR2(30) := 'get_current_financial_report';
        l_api_version           CONSTANT  NUMBER       := 1.0;

BEGIN

--Standard call to check for call compatibility.
        IF NOT FND_API.Compatible_API_Call(
                                        l_api_version,
                                        p_api_version,
                                        l_api_name,
                                        G_PKG_NAME)
        THEN
                RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
        END IF;

--Initialize message list if p_init_msg_list is set to TRUE.
        IF FND_API.to_Boolean(p_init_msg_list) THEN
                FND_MSG_PUB.initialize;
        END IF;

--Initialize API return status to success.
        x_return_status := FND_API.G_RET_STS_SUCCESS;

--Check whether primary key has been passed in.
        IF p_financial_report_id IS NULL OR
           p_financial_report_id = FND_API.G_MISS_NUM THEN

            FND_MESSAGE.SET_NAME('AR', 'HZ_API_MISSING_COLUMN');
            FND_MESSAGE.SET_TOKEN('COLUMN', 'financial_report_id');
            FND_MSG_PUB.ADD;
            RAISE FND_API.G_EXC_ERROR;
        END IF;

        BEGIN /* Just for select statement */

           SELECT
                financial_report_id,
                date_report_issued,
                party_id,
                document_reference,
                issued_period,
                requiring_authority,
                type_of_financial_report,
                wh_udpate_id,
                report_start_date,
                report_end_date,
                audit_ind,
                consolidated_ind,
                estimated_ind,
                fiscal_ind,
                final_ind,
                forecast_ind,
                opening_ind,
                proforma_ind,
                qualified_ind,
                restated_ind,
                signed_by_principals_ind,
                trial_balance_ind,
                unbalanced_ind,
                content_source_type,
                status,
                actual_content_source
           INTO
                x_financial_reports_rec.financial_report_id,
                x_financial_reports_rec.date_report_issued,
                x_financial_reports_rec.party_id,
                x_financial_reports_rec.document_reference,
                x_financial_reports_rec.issued_period,
                x_financial_reports_rec.requiring_authority,
                x_financial_reports_rec.type_of_financial_report,
                x_financial_reports_rec.wh_udpate_id,
                x_financial_reports_rec.report_start_date,
                x_financial_reports_rec.report_end_date,
                x_financial_reports_rec.audit_ind,
                x_financial_reports_rec.consolidated_ind,
                x_financial_reports_rec.estimated_ind,
                x_financial_reports_rec.fiscal_ind,
                x_financial_reports_rec.final_ind,
                x_financial_reports_rec.forecast_ind,
                x_financial_reports_rec.opening_ind,
                x_financial_reports_rec.proforma_ind,
                x_financial_reports_rec.qualified_ind,
                x_financial_reports_rec.restated_ind,
                x_financial_reports_rec.signed_by_principals_ind,
                x_financial_reports_rec.trial_balance_ind,
                x_financial_reports_rec.unbalanced_ind,
                x_financial_reports_rec.content_source_type,
                x_financial_reports_rec.status,
                x_financial_reports_rec.actual_content_source

           FROM hz_financial_reports
           WHERE financial_report_id = p_financial_report_id;

        EXCEPTION
           WHEN NO_DATA_FOUND THEN
              FND_MESSAGE.SET_NAME('AR', 'HZ_API_NO_RECORD');
              FND_MESSAGE.SET_TOKEN('RECORD', 'financial report');
              FND_MESSAGE.SET_TOKEN('VALUE', to_char(p_financial_report_id));
              FND_MSG_PUB.ADD;
              RAISE FND_API.G_EXC_ERROR;
        END;
--Standard call to get message count and if count is 1, get message info.
        FND_MSG_PUB.Count_And_Get(
                p_encoded => FND_API.G_FALSE,
                p_count => x_msg_count,
                p_data  => x_msg_data);

EXCEPTION
        WHEN FND_API.G_EXC_ERROR THEN
                x_return_status := FND_API.G_RET_STS_ERROR;
                FND_MSG_PUB.Count_And_Get(
                                p_encoded => FND_API.G_FALSE,
                                p_count => x_msg_count,
                                p_data  => x_msg_data);

        WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
                x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
                FND_MSG_PUB.Count_And_Get(
                                p_encoded => FND_API.G_FALSE,
                                p_count => x_msg_count,
                                p_data  => x_msg_data);
        WHEN OTHERS THEN
                x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

                FND_MESSAGE.SET_NAME('AR', 'HZ_API_OTHERS_EXCEP');
                FND_MESSAGE.SET_TOKEN('ERROR' ,SQLERRM);
                FND_MSG_PUB.ADD;

                FND_MSG_PUB.Count_And_Get(
                                p_encoded => FND_API.G_FALSE,
                                p_count => x_msg_count,
                                p_data  => x_msg_data);


END get_current_financial_report;

procedure get_current_financial_number(
        p_api_version           IN      NUMBER,
        p_init_msg_list         IN      VARCHAR2:= FND_API.G_FALSE,
        p_financial_number_id   IN      NUMBER,
        x_financial_numbers_rec OUT     NOCOPY FINANCIAL_NUMBERS_REC_TYPE,
        x_return_status         IN OUT     NOCOPY VARCHAR2,
        x_msg_count             OUT     NOCOPY NUMBER,
        x_msg_data              OUT     NOCOPY VARCHAR2
) IS
        l_api_name              CONSTANT VARCHAR2(30) := 'get_current_financial_number';
        l_api_version           CONSTANT  NUMBER       := 1.0;

BEGIN

--Standard call to check for call compatibility.
        IF NOT FND_API.Compatible_API_Call(
                                        l_api_version,
                                        p_api_version,
                                        l_api_name,
                                        G_PKG_NAME)
        THEN
                RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
        END IF;

--Initialize message list if p_init_msg_list is set to TRUE.
        IF FND_API.to_Boolean(p_init_msg_list) THEN
                FND_MSG_PUB.initialize;
        END IF;

--Initialize API return status to success.
        x_return_status := FND_API.G_RET_STS_SUCCESS;

--Check whether primary key has been passed in.
        IF p_financial_number_id IS NULL OR
           p_financial_number_id = FND_API.G_MISS_NUM THEN

            FND_MESSAGE.SET_NAME('AR', 'HZ_API_MISSING_COLUMN');
            FND_MESSAGE.SET_TOKEN('COLUMN', 'financial_number_id');
            FND_MSG_PUB.ADD;
            RAISE FND_API.G_EXC_ERROR;
        END IF;

        BEGIN /* Just for select statement */

           SELECT
                financial_number_id,
                financial_report_id,
                financial_number,
                financial_number_name,
                financial_units_applied,
                financial_number_currency,
                projected_actual_flag,
                wh_update_date,
                content_source_type,
                status
           INTO
                x_financial_numbers_rec.financial_number_id,
                x_financial_numbers_rec.financial_report_id,
                x_financial_numbers_rec.financial_number,
                x_financial_numbers_rec.financial_number_name,
                x_financial_numbers_rec.financial_units_applied,
                x_financial_numbers_rec.financial_number_currency,
                x_financial_numbers_rec.projected_actual_flag,
                x_financial_numbers_rec.wh_update_date,
                x_financial_numbers_rec.content_source_type,
                x_financial_numbers_rec.status
           FROM hz_financial_numbers
           WHERE financial_number_id = p_financial_number_id;

        EXCEPTION
           WHEN NO_DATA_FOUND THEN
              FND_MESSAGE.SET_NAME('AR', 'HZ_API_NO_RECORD');
              FND_MESSAGE.SET_TOKEN('RECORD', 'credit rating');
              FND_MESSAGE.SET_TOKEN('VALUE', to_char(p_financial_number_id));
              FND_MSG_PUB.ADD;
              RAISE FND_API.G_EXC_ERROR;
        END;
--Standard call to get message count and if count is 1, get message info.
        FND_MSG_PUB.Count_And_Get(
                p_encoded => FND_API.G_FALSE,
                p_count => x_msg_count,
                p_data  => x_msg_data);

EXCEPTION
        WHEN FND_API.G_EXC_ERROR THEN
                x_return_status := FND_API.G_RET_STS_ERROR;
                FND_MSG_PUB.Count_And_Get(
                                p_encoded => FND_API.G_FALSE,
                                p_count => x_msg_count,
                                p_data  => x_msg_data);

        WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
                x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
                FND_MSG_PUB.Count_And_Get(
                                p_encoded => FND_API.G_FALSE,
                                p_count => x_msg_count,
                                p_data  => x_msg_data);
        WHEN OTHERS THEN
                x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

                FND_MESSAGE.SET_NAME('AR', 'HZ_API_OTHERS_EXCEP');
                FND_MESSAGE.SET_TOKEN('ERROR' ,SQLERRM);
                FND_MSG_PUB.ADD;

                FND_MSG_PUB.Count_And_Get(
                                p_encoded => FND_API.G_FALSE,
                                p_count => x_msg_count,
                                p_data  => x_msg_data);


END get_current_financial_number;





END HZ_ORG_INFO_PUB;

/
