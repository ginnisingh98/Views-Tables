--------------------------------------------------------
--  DDL for Package Body HZ_ORG_INFO_VALIDATE
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."HZ_ORG_INFO_VALIDATE" as
/* $Header: ARHORIVB.pls 120.2 2005/06/16 21:13:11 jhuang ship $ */

procedure validate_stock_markets(
        p_stock_markets_rec        IN  HZ_ORG_INFO_PUB.stock_markets_rec_type,
        p_create_update_flag       IN  VARCHAR2,
        x_return_status            IN OUT  NOCOPY VARCHAR2
        )
IS
    l_count                NUMBER;

BEGIN
    -- no foreign key validation for stock market.


    -- validate stock_exchange_code, lookup_type with ?
    -- comment out the validation below
    -- because the lookup has not been creasted yet.
   /* IF p_stock_markets_rec.stock_exchange_code is NOT NULL and
       p_stock_markets_rec.stock_exchange_code <> FND_API.G_MISS_CHAR  THEN
         SELECT count(*)
         INTO l_count
         FROM AR_LOOKUPS
         WHERE lookup_type = 'STOCK_SYMBOL'
         AND lookup_code = p_stock_markets_rec.stock_exchange_code;

         if l_count  = 0 then
              FND_MESSAGE.SET_NAME('AR', 'HZ_API_INVALID_LOOKUP');
              FND_MESSAGE.SET_TOKEN('COLUMN', 'STOCK_SYMBOL');
              FND_MESSAGE.SET_TOKEN('LOOKUP_TYPE', 'YES/NO');
              FND_MSG_PUB.ADD;
        end if;
    END IF; */

   null;

END validate_stock_markets;

procedure validate_security_issued(
        p_security_issued_rec      IN  HZ_ORG_INFO_PUB.security_issued_rec_type,
        p_create_update_flag       IN  VARCHAR2,
        x_return_status            IN OUT  NOCOPY VARCHAR2
        )
IS
    l_count                NUMBER;
    l_stock_exchange_id    NUMBER;
    l_rowid                ROWID := NULL;
    l_begin_date           DATE;
    l_end_date             DATE;
BEGIN
    -- check required field:
    IF (p_create_update_flag = 'C'  AND
        (p_security_issued_rec.stock_exchange_id is NULL OR
         p_security_issued_rec.stock_exchange_id = FND_API.G_MISS_NUM))  OR
       (p_create_update_flag = 'U' AND
        p_security_issued_rec.stock_exchange_id is NULL)  THEN

         FND_MESSAGE.SET_NAME('AR', 'HZ_API_MISSING_COLUMN');
         FND_MESSAGE.SET_TOKEN('COLUMN', 'stock_exchange_id');
         FND_MSG_PUB.ADD;
         x_return_status := FND_API.G_RET_STS_ERROR;


    END IF;

    -- check non-updateable field: stock_exchange_id
    if (p_create_update_flag = 'U' AND
        (p_security_issued_rec.stock_exchange_id <> FND_API.G_MISS_NUM  OR
         p_security_issued_rec.begin_date <> FND_API.G_MISS_DATE  OR
         p_security_issued_rec.end_date <> FND_API.G_MISS_DATE )) THEN
       BEGIN
         SELECT stock_exchange_id, begin_date, end_date
         INTO l_stock_exchange_id, l_begin_date, l_end_date
         FROM HZ_SECURITY_ISSUED
         WHERE security_issued_id = p_security_issued_rec.security_issued_id;

         if l_stock_exchange_id <> p_security_issued_rec.stock_exchange_id  AND
            p_security_issued_rec.stock_exchange_id <> FND_API.G_MISS_NUM  THEN
              FND_MESSAGE.SET_NAME('AR', 'HZ_API_NONUPDATEABLE_COLUMN');
              FND_MESSAGE.SET_TOKEN('COLUMN', 'party_id');
              FND_MSG_PUB.ADD;
              x_return_status := FND_API.G_RET_STS_ERROR;

         end if;


         EXCEPTION WHEN NO_DATA_FOUND THEN
         FND_MESSAGE.SET_NAME('AR', 'HZ_API_NO_RECORD');
         FND_MESSAGE.SET_TOKEN('RECORD', 'security_issued');
         FND_MESSAGE.SET_TOKEN('VALUE', to_char(p_security_issued_rec.stock_exchange_id));
         FND_MSG_PUB.ADD;
         x_return_status := FND_API.G_RET_STS_ERROR;

      END;

    END IF;

     -- validate foreign key: party_id to hz_parties,
     --                       stock_exchange_id to hz_stock_markets,
     --                       security_currency_code to fnd_currencies.


     IF p_security_issued_rec.party_id is NOT NULL   AND
        p_security_issued_rec.party_id <> FND_API.G_MISS_NUM THEN

         SELECT COUNT(*) INTO l_count
         FROM hz_parties
         where party_id = p_security_issued_rec.party_id;

         IF l_count = 0 THEN
                        FND_MESSAGE.SET_NAME('AR', 'HZ_API_INVALID_FK');
                        FND_MESSAGE.SET_TOKEN('FK', 'party_id');
                        FND_MESSAGE.SET_TOKEN('COLUMN', 'party_id');
                        FND_MESSAGE.SET_TOKEN('TABLE', 'hz_parties');
                        FND_MSG_PUB.ADD;
                        x_return_status := FND_API.G_RET_STS_ERROR;

         END IF;

    END IF;

     IF p_security_issued_rec.stock_exchange_id is NOT NULL   AND
        p_security_issued_rec.stock_exchange_id <> FND_API.G_MISS_NUM THEN

         SELECT COUNT(*) INTO l_count
         FROM hz_stock_markets
         where stock_exchange_id  = p_security_issued_rec.stock_exchange_id;

         IF l_count = 0 THEN
              FND_MESSAGE.SET_NAME('AR', 'HZ_API_INVALID_FK');
              FND_MESSAGE.SET_TOKEN('FK', 'stock_exchange_id');
              FND_MESSAGE.SET_TOKEN('COLUMN', 'stock_exchange_id');
              FND_MESSAGE.SET_TOKEN('TABLE', 'hz_stock_markets');
              FND_MSG_PUB.ADD;
              x_return_status := FND_API.G_RET_STS_ERROR;

         END IF;

     END IF;

     IF p_security_issued_rec.security_currency_code is NOT NULL AND
        p_security_issued_rec.security_currency_code <> FND_API.G_MISS_CHAR  THEN

          SELECT count(*)
          INTO l_count
          FROM fnd_currencies
          WHERE currency_code = p_security_issued_rec.security_currency_code
          AND currency_flag = 'Y'
          AND enabled_flag in ('Y', 'N');

          if l_count = 0 then
                FND_MESSAGE.SET_NAME('AR', 'HZ_API_INVALID_FK');
                FND_MESSAGE.SET_TOKEN('FK', 'security_currency_code');
                FND_MESSAGE.SET_TOKEN('COLUMN', 'currency_code');
                FND_MESSAGE.SET_TOKEN('TABLE', 'fnd_currencies');
                FND_MSG_PUB.ADD;
                x_return_status := FND_API.G_RET_STS_ERROR;

          end if;
  END IF;

     -- end_date should be greater than begin_date

     IF p_create_update_flag = 'C'  THEN
          IF p_security_issued_rec.end_date is  NOT NULL  AND
             p_security_issued_rec.end_date <> FND_API.G_MISS_DATE  THEN
               if (p_security_issued_rec.end_date < p_security_issued_rec.begin_date  OR
                   p_security_issued_rec.begin_date IS NULL  OR
                   p_security_issued_rec.begin_date = FND_API.G_MISS_DATE)  THEN
                     FND_MESSAGE.SET_NAME('AR', 'HZ_API_START_DATE_GREATER');
                     FND_MSG_PUB.ADD;
                     x_return_status := FND_API.G_RET_STS_ERROR;
               end if;
     END IF;

     -- compare end_date with database data and user passed data.
     ELSIF p_create_update_flag = 'U' THEN
             if (p_security_issued_rec.end_date is  NOT NULL  AND
                 p_security_issued_rec.end_date <> FND_API.G_MISS_DATE)   THEN
                   if p_security_issued_rec.begin_date is NOT NULL  AND
                      p_security_issued_rec.begin_date <> FND_API.G_MISS_DATE  then
                        if p_security_issued_rec.end_date < p_security_issued_rec.begin_date then
                             FND_MESSAGE.SET_NAME('AR', 'HZ_API_START_DATE_GREATER');
                             FND_MSG_PUB.ADD;
                             x_return_status := FND_API.G_RET_STS_ERROR;

                        end if;
                   elsif (p_security_issued_rec.end_date < l_begin_date  OR
                          l_begin_date is NULL )  then
                           FND_MESSAGE.SET_NAME('AR', 'HZ_API_START_DATE_GREATER');
                           FND_MSG_PUB.ADD;
                           x_return_status := FND_API.G_RET_STS_ERROR;

                   end if;
              elsif (p_security_issued_rec.begin_date is  NOT NULL  AND
                     p_security_issued_rec.begin_date <> FND_API.G_MISS_DATE)   THEN
                      if l_end_date < p_security_issued_rec.begin_date then
                        FND_MESSAGE.SET_NAME('AR', 'HZ_API_START_DATE_GREATER');
                        FND_MSG_PUB.ADD;
                        x_return_status := FND_API.G_RET_STS_ERROR;

                      end if;
              end if;
     END IF;
--Status Validation
 hz_common_pub.validate_lookup('REGISTRY_STATUS','status',p_security_issued_rec.status,x_return_status);

END validate_security_issued;


procedure validate_financial_reports(
        p_financial_reports_rec    IN  HZ_ORG_INFO_PUB.financial_reports_rec_type,
        p_create_update_flag       IN  VARCHAR2,
        x_return_status            IN OUT  NOCOPY VARCHAR2
        )
IS
    l_count              NUMBER;
    l_party_id           NUMBER;
    l_report_start_date  DATE;
    l_report_end_date    DATE;
    l_content_source_type   hz_financial_reports.content_source_type%TYPE;
    db_actual_content_source    hz_financial_reports.actual_content_source%TYPE;

BEGIN

    -- mandatory fields
    IF (p_create_update_flag = 'C' AND
         (p_financial_reports_rec.party_id is NULL OR
          p_financial_reports_rec.party_id = FND_API.G_MISS_NUM)) OR
        (p_create_update_flag = 'U' AND
         p_financial_reports_rec.party_id is NULL) THEN

          FND_MESSAGE.SET_NAME('AR', 'HZ_API_MISSING_COLUMN');
          FND_MESSAGE.SET_TOKEN('COLUMN', 'party_id');
          FND_MSG_PUB.ADD;
          x_return_status := FND_API.G_RET_STS_ERROR;

     END IF;

    -- non updateable field

    IF (p_create_update_flag = 'U') THEN
      BEGIN
         SELECT party_id,report_start_date,
                report_end_date, content_source_type, actual_content_source
         INTO l_party_id, l_report_start_date,
              l_report_end_date, l_content_source_type, db_actual_content_source
         FROM HZ_FINANCIAL_REPORTS
         WHERE financial_report_id= p_financial_reports_rec.financial_report_id;

         IF p_financial_reports_rec.party_id <> FND_API.G_MISS_NUM  OR
         p_financial_reports_rec.report_end_date <> FND_API.G_MISS_DATE  OR
         p_financial_reports_rec.report_start_date <> FND_API.G_MISS_DATE THEN

          if l_party_id <> p_financial_reports_rec.party_id  AND
            p_financial_reports_rec.party_id <> FND_API.G_MISS_NUM  THEN
              FND_MESSAGE.SET_NAME('AR', 'HZ_API_NONUPDATEABLE_COLUMN');
              FND_MESSAGE.SET_TOKEN('COLUMN', 'party_id');
              FND_MSG_PUB.ADD;
              x_return_status := FND_API.G_RET_STS_ERROR;

          end if;
         END IF;

         EXCEPTION WHEN NO_DATA_FOUND THEN
         FND_MESSAGE.SET_NAME('AR', 'HZ_API_NO_RECORD');
         FND_MESSAGE.SET_TOKEN('RECORD', 'financial report');
         FND_MESSAGE.SET_TOKEN('VALUE',
                  to_char(p_financial_reports_rec.financial_report_id));
         FND_MSG_PUB.ADD;
         x_return_status := FND_API.G_RET_STS_ERROR;

      END;

    END IF;

    -- foreign keys: party_id to HZ_PARTIES table

    IF p_financial_reports_rec.party_id is NOT NULL   AND
       p_financial_reports_rec.party_id <> FND_API.G_MISS_NUM THEN

         SELECT COUNT(*) INTO l_count
         FROM hz_parties
         where party_id = p_financial_reports_rec.party_id;

         IF l_count = 0 THEN
                        FND_MESSAGE.SET_NAME('AR', 'HZ_API_INVALID_FK');
                        FND_MESSAGE.SET_TOKEN('FK', 'party_id');
                        FND_MESSAGE.SET_TOKEN('COLUMN', 'party_id');
                        FND_MESSAGE.SET_TOKEN('TABLE', 'hz_parties');
                        FND_MSG_PUB.ADD;
                        x_return_status := FND_API.G_RET_STS_ERROR;

         END IF;

    END IF;

    -- report_end_date should be greater than report_start_date

    IF p_create_update_flag = 'C'  THEN
         IF p_financial_reports_rec.report_end_date is  NOT NULL  AND
            p_financial_reports_rec.report_end_date <> FND_API.G_MISS_DATE  THEN
              if (p_financial_reports_rec.report_end_date
                  < p_financial_reports_rec.report_start_date  OR
                  p_financial_reports_rec.report_start_date IS NULL  OR
                  p_financial_reports_rec.report_start_date = FND_API.G_MISS_DATE)  THEN
                    FND_MESSAGE.SET_NAME('AR', 'HZ_API_START_DATE_GREATER');
                    FND_MSG_PUB.ADD;
                    x_return_status := FND_API.G_RET_STS_ERROR;

              end if;
          END IF;

     -- compare end_date with database data and user passed data.
     ELSIF p_create_update_flag = 'U' THEN
             if (p_financial_reports_rec.report_end_date is  NOT NULL  AND
                 p_financial_reports_rec.report_end_date <> FND_API.G_MISS_DATE)   THEN
                   if p_financial_reports_rec.report_start_date is NOT NULL  AND
                      p_financial_reports_rec.report_start_date <> FND_API.G_MISS_DATE  then
                        if p_financial_reports_rec.report_end_date
                           < p_financial_reports_rec.report_start_date then
                             FND_MESSAGE.SET_NAME('AR', 'HZ_API_START_DATE_GREATER');
                             FND_MSG_PUB.ADD;
                             x_return_status := FND_API.G_RET_STS_ERROR;

                        end if;
                   elsif ( p_financial_reports_rec.report_end_date < l_report_start_date  OR
                           l_report_start_date is NULL) then
                           FND_MESSAGE.SET_NAME('AR', 'HZ_API_START_DATE_GREATER');
                           FND_MSG_PUB.ADD;
                           x_return_status := FND_API.G_RET_STS_ERROR;

                   end if;
              elsif (p_financial_reports_rec.report_start_date is  NOT NULL  AND
                     p_financial_reports_rec.report_start_date <> FND_API.G_MISS_DATE)   THEN
                      if l_report_end_date < p_financial_reports_rec.report_start_date then
                        FND_MESSAGE.SET_NAME('AR', 'HZ_API_START_DATE_GREATER');
                        FND_MSG_PUB.ADD;
                        x_return_status := FND_API.G_RET_STS_ERROR;

                      end if;
              end if;
     END IF;

--
-- Bug 2197181: removed content_source_type validation as a part of mix-n-match Project.
--

/*
--content_source_type validations.
--Bug 1363124: validation#2 of content_source_type

  IF p_create_update_flag = 'U' THEN
        IF l_content_source_type <> p_financial_reports_rec.content_source_type
        OR p_financial_reports_rec.content_source_type IS NULL THEN
                FND_MESSAGE.SET_NAME('AR', 'HZ_API_NONUPDATEABLE_COLUMN');
                FND_MESSAGE.SET_TOKEN('COLUMN', 'content_source_type');
                FND_MSG_PUB.ADD;
                x_return_status := FND_API.G_RET_STS_ERROR;
        END IF;
  END IF;

  hz_common_pub.validate_lookup(
        p_lookup_type   => 'CONTENT_SOURCE_TYPE',
        p_column        => 'content_source_type',
        p_column_value  => p_financial_reports_rec.content_source_type,
        x_return_status => x_return_status
  );

  IF p_create_update_flag = 'C'
  AND (p_financial_reports_rec.content_source_type IS NULL
       OR p_financial_reports_rec.content_source_type = FND_API.G_MISS_CHAR) THEN
                FND_MESSAGE.SET_NAME('AR', 'HZ_API_MISSING_COLUMN');
                FND_MESSAGE.SET_TOKEN('COLUMN', 'content_source_type');
                FND_MSG_PUB.ADD;
                x_return_status := FND_API.G_RET_STS_ERROR;
  END IF;

*/

    -- Bug 2197181: Added validation for mix-n-match

    ----------------------------------------
    -- validate content_source_type and actual_content_source_type
    ----------------------------------------
    -- SSM SST Integration and Extension
    -- Pass HZ_FINANCIAL_REPORTS for new parameter p_entity_name
    HZ_MIXNM_UTILITY.ValidateContentSource (
      p_api_version                       => 'V1',
      p_create_update_flag                => p_create_update_flag,
      p_check_update_privilege            => 'Y',
      p_content_source_type               => p_financial_reports_rec.content_source_type,
      p_old_content_source_type           => l_content_source_type,
      p_actual_content_source             => p_financial_reports_rec.actual_content_source,
      p_old_actual_content_source         => db_actual_content_source,
      p_entity_name                       => 'HZ_FINANCIAL_REPORTS',
      x_return_status                     => x_return_status );

--Status Validation
 hz_common_pub.validate_lookup('REGISTRY_STATUS','status',p_financial_reports_rec.status,x_return_status);


END validate_financial_reports;


procedure validate_financial_numbers(
        p_financial_numbers_rec    IN  HZ_ORG_INFO_PUB.financial_numbers_rec_type,
        p_create_update_flag       IN  VARCHAR2,
        x_return_status            IN OUT  NOCOPY VARCHAR2,
        x_rep_content_source_type  OUT  NOCOPY VARCHAR2,
        x_rep_actual_content_source     OUT  NOCOPY VARCHAR2
        )
IS
    l_count                NUMBER;
    l_financial_report_id  NUMBER;
    db_content_source_type hz_financial_numbers.content_source_type%TYPE;
BEGIN
    -- mandatory field: financial_report_id

     IF (p_create_update_flag = 'C' AND
         (p_financial_numbers_rec.financial_report_id is NULL OR
          p_financial_numbers_rec.financial_report_id = FND_API.G_MISS_NUM)) OR
        (p_create_update_flag = 'U' AND
         p_financial_numbers_rec.financial_report_id is NULL) THEN

          FND_MESSAGE.SET_NAME('AR', 'HZ_API_MISSING_COLUMN');
          FND_MESSAGE.SET_TOKEN('COLUMN', 'financial_report_id');
          FND_MSG_PUB.ADD;
          x_return_status := FND_API.G_RET_STS_ERROR;


     END IF;

    -- non updateable field

    IF (p_create_update_flag = 'U') THEN
        SELECT financial_report_id, content_source_type
        INTO l_financial_report_id, db_content_source_type
        FROM HZ_FINANCIAL_NUMBERS
        WHERE financial_number_id = p_financial_numbers_rec.financial_number_id;

        if (p_financial_numbers_rec.financial_report_id <> FND_API.G_MISS_NUM) AND
           (l_financial_report_id <> p_financial_numbers_rec.financial_report_id)
       THEN
              FND_MESSAGE.SET_NAME('AR', 'HZ_API_NONUPDATEABLE_COLUMN');
              FND_MESSAGE.SET_TOKEN('COLUMN', 'financial_report_id');
              FND_MSG_PUB.ADD;
              x_return_status := FND_API.G_RET_STS_ERROR;

        END IF;

    END IF;

    -- foreign keys: financial_report_id to HZ_FINANCIAL_REPORTS table

    IF p_financial_numbers_rec.financial_report_id is NOT NULL   AND
       p_financial_numbers_rec.financial_report_id <> FND_API.G_MISS_NUM THEN

        BEGIN
         SELECT content_source_type, actual_content_source
         INTO x_rep_content_source_type, x_rep_actual_content_source
         FROM HZ_FINANCIAL_REPORTS
         where financial_report_id  = p_financial_numbers_rec.financial_report_id;

        EXCEPTION WHEN NO_DATA_FOUND THEN
                        FND_MESSAGE.SET_NAME('AR', 'HZ_API_INVALID_FK');
                        FND_MESSAGE.SET_TOKEN('FK', 'financial_report_id');
                        FND_MESSAGE.SET_TOKEN('COLUMN', 'financial_report_id');
                        FND_MESSAGE.SET_TOKEN('TABLE', 'hz_financial_reports');
                        FND_MSG_PUB.ADD;
                        x_return_status := FND_API.G_RET_STS_ERROR;

        END;

    END IF;

--
-- Bug 2197181: removed content_source_type validation as a part of mix-n-match Project.
--

/*

--content_source_type validations.
--Bug 1363124: validation#2 of content_source_type

  IF p_create_update_flag = 'U' THEN
        IF l_content_source_type <> p_financial_numbers_rec.content_source_type
        OR p_financial_numbers_rec.content_source_type IS NULL THEN
                FND_MESSAGE.SET_NAME('AR', 'HZ_API_NONUPDATEABLE_COLUMN');
                FND_MESSAGE.SET_TOKEN('COLUMN', 'content_source_type');
                FND_MSG_PUB.ADD;
                x_return_status := FND_API.G_RET_STS_ERROR;
        END IF;
  END IF;

  hz_common_pub.validate_lookup(
        p_lookup_type   => 'CONTENT_SOURCE_TYPE',
        p_column        => 'content_source_type',
        p_column_value  => p_financial_numbers_rec.content_source_type,
        x_return_status => x_return_status
  );

  IF p_create_update_flag = 'C'
  AND (p_financial_numbers_rec.content_source_type IS NULL
       OR p_financial_numbers_rec.content_source_type = FND_API.G_MISS_CHAR) THEN
                FND_MESSAGE.SET_NAME('AR', 'HZ_API_MISSING_COLUMN');
                FND_MESSAGE.SET_TOKEN('COLUMN', 'content_source_type');
                FND_MSG_PUB.ADD;
                x_return_status := FND_API.G_RET_STS_ERROR;
  END IF;

*/


    -- validate financial_number_currency ? (which message to display?)
--Status Validation
 hz_common_pub.validate_lookup('REGISTRY_STATUS','status',p_financial_numbers_rec.status,x_return_status);

    -- Bug 2197181 : obsolete content_source_type. Raise error in development
    -- site if user tries to populate value into this column.

    IF NVL(FND_PROFILE.value('HZ_API_ERR_ON_OBSOLETE_COLUMN'), 'N') = 'Y'
    THEN
      HZ_UTILITY_V2PUB.Check_ObsoleteColumn (
        p_api_version                  => 'V1',
        p_create_update_flag           => p_create_update_flag,
        p_column                       => 'content_source_type',
        p_column_value                 => p_financial_numbers_rec.content_source_type,
        p_default_value                => 'USER_ENTERED',
        p_old_column_value             => db_content_source_type,
        x_return_status                => x_return_status);
    END IF;

END validate_financial_numbers;

procedure validate_certifications(
        p_certifications_rec       IN  HZ_ORG_INFO_PUB.certifications_rec_type,
        p_create_update_flag       IN  VARCHAR2,
        x_return_status            IN OUT  NOCOPY VARCHAR2
        )
IS
    l_count           NUMBER;
    l_party_id        NUMBER;
BEGIN
    -- check required field: party_id, certification_name
    IF (p_create_update_flag = 'C'  AND
        (p_certifications_rec.party_id is NULL   OR
         p_certifications_rec.party_id = FND_API.G_MISS_NUM))  OR
       (p_create_update_flag = 'U'  AND
        p_certifications_rec.party_id is NULL)  THEN

          FND_MESSAGE.SET_NAME('AR', 'HZ_API_MISSING_COLUMN');
          FND_MESSAGE.SET_TOKEN('COLUMN', 'party_id');
          FND_MSG_PUB.ADD;
          x_return_status := FND_API.G_RET_STS_ERROR;

     END IF;

    IF (p_create_update_flag = 'C'  AND
        (p_certifications_rec.certification_name is NULL   OR
         p_certifications_rec.certification_name = FND_API.G_MISS_CHAR))  OR
       (p_create_update_flag = 'U'  AND
        p_certifications_rec.certification_name is NULL)  THEN

          FND_MESSAGE.SET_NAME('AR', 'HZ_API_MISSING_COLUMN');
          FND_MESSAGE.SET_TOKEN('COLUMN', 'certification_name');
          FND_MSG_PUB.ADD;
          x_return_status := FND_API.G_RET_STS_ERROR;

    END IF;

   -- non-updateable field: party_id

   IF (p_create_update_flag = 'U'  AND
       p_certifications_rec.party_id <> FND_API.G_MISS_NUM)  THEN

       SELECT party_id
       INTO l_party_id
       FROM HZ_CERTIFICATIONS
       WHERE certification_id = p_certifications_rec.certification_id;

       if l_party_id <> p_certifications_rec.party_id  then
            FND_MESSAGE.SET_NAME('AR', 'HZ_API_NONUPDATEABLE_COLUMN');
            FND_MESSAGE.SET_TOKEN('COLUMN', 'certification_id');
            FND_MSG_PUB.ADD;
            x_return_status := FND_API.G_RET_STS_ERROR;

       end if;

    END IF;

    -- check foreign key : party_id to hz_parties.

    IF p_certifications_rec.party_id is NOT NULL  AND
       p_certifications_rec.party_id  <> FND_API.G_MISS_NUM  THEN

         SELECT count(*)
         INTO l_count
         FROM HZ_PARTIES
         WHERE party_id = p_certifications_rec.party_id;

         if l_count = 0  then
              FND_MESSAGE.SET_NAME('AR', 'HZ_API_INVALID_FK');
              FND_MESSAGE.SET_TOKEN('FK', 'party_id');
              FND_MESSAGE.SET_TOKEN('COLUMN', 'party_id');
              FND_MESSAGE.SET_TOKEN('TABLE', 'hz_parties');
              FND_MSG_PUB.ADD;
              x_return_status := FND_API.G_RET_STS_ERROR;

         END IF;

    END IF;

--Status Validation

hz_common_pub.validate_lookup('REGISTRY_STATUS','status',p_certifications_rec.status,x_return_status);
END validate_certifications;

procedure validate_industrial_reference(
        p_industrial_reference_rec IN  HZ_ORG_INFO_PUB.industrial_reference_rec_type,
        p_create_update_flag       IN  VARCHAR2,
        x_return_status            IN OUT  NOCOPY VARCHAR2
        )
IS
    l_count       NUMBER;
    l_party_id    NUMBER;
BEGIN
    -- mandatory fields : party_id, industrial_reference
    IF (p_create_update_flag = 'C' AND
         (p_industrial_reference_rec.party_id is NULL OR
          p_industrial_reference_rec.party_id = FND_API.G_MISS_NUM)) OR
        (p_create_update_flag = 'U' AND
         p_industrial_reference_rec.party_id is NULL) THEN

          FND_MESSAGE.SET_NAME('AR', 'HZ_API_MISSING_COLUMN');
          FND_MESSAGE.SET_TOKEN('COLUMN', 'party_id');
          FND_MSG_PUB.ADD;
          x_return_status := FND_API.G_RET_STS_ERROR;


    END IF;

     IF (p_create_update_flag = 'C' AND
         (p_industrial_reference_rec.industry_reference is NULL OR
          p_industrial_reference_rec.industry_reference = FND_API.G_MISS_CHAR)) OR
        (p_create_update_flag = 'U' AND
         p_industrial_reference_rec.industry_reference is NULL) THEN

          FND_MESSAGE.SET_NAME('AR', 'HZ_API_MISSING_COLUMN');
          FND_MESSAGE.SET_TOKEN('COLUMN', 'industry_reference');
          FND_MSG_PUB.ADD;
          x_return_status := FND_API.G_RET_STS_ERROR;


    END IF;

    IF (p_create_update_flag = 'U'  AND
        p_industrial_reference_rec.party_id <> FND_API.G_MISS_NUM)  THEN
          SELECT party_id
          INTO l_party_id
          FROM HZ_INDUSTRIAL_REFERENCE
          WHERE INDUSTRY_REFERENCE_ID = p_industrial_reference_rec.INDUSTRY_REFERENCE_ID;

          if l_party_id <> p_industrial_reference_rec.party_id  AND
             p_industrial_reference_rec.party_id <> FND_API.G_MISS_NUM  THEN
               FND_MESSAGE.SET_NAME('AR', 'HZ_API_NONUPDATEABLE_COLUMN');
               FND_MESSAGE.SET_TOKEN('COLUMN', 'party_id');
               FND_MSG_PUB.ADD;
               x_return_status := FND_API.G_RET_STS_ERROR;

          end if;
    END IF;

    -- check foreign key : party_id to hz_parties.

    IF p_industrial_reference_rec.party_id is NOT NULL  AND
       p_industrial_reference_rec.party_id  <> FND_API.G_MISS_NUM  THEN

         SELECT count(*)
         INTO l_count
         FROM HZ_PARTIES
         WHERE party_id = p_industrial_reference_rec.party_id;

         if l_count = 0  then
              FND_MESSAGE.SET_NAME('AR', 'HZ_API_INVALID_FK');
              FND_MESSAGE.SET_TOKEN('FK', 'party_id');
              FND_MESSAGE.SET_TOKEN('COLUMN', 'party_id');
              FND_MESSAGE.SET_TOKEN('TABLE', 'hz_parties');
              FND_MSG_PUB.ADD;
              x_return_status := FND_API.G_RET_STS_ERROR;

         END IF;

    END IF;

--Status Validation

hz_common_pub.validate_lookup('REGISTRY_STATUS','status',p_industrial_reference_rec.status,x_return_status);

END validate_industrial_reference;

procedure validate_industrial_classes(
        p_industrial_classes_rec   IN  HZ_ORG_INFO_PUB.industrial_classes_rec_type,
        p_create_update_flag       IN  VARCHAR2,
        x_return_status            IN OUT  NOCOPY VARCHAR2
        )
IS
    l_count    NUMBER;
BEGIN

    -- check required field: code_primary_segment

    IF (p_create_update_flag = 'C'  AND
        (p_industrial_classes_rec.code_primary_segment is NULL OR
         p_industrial_classes_rec.code_primary_segment = FND_API.G_MISS_CHAR))  OR
       (p_create_update_flag = 'U'  AND
        p_industrial_classes_rec.code_primary_segment is NULL)  THEN

         FND_MESSAGE.SET_NAME('AR', 'HZ_API_MISSING_COLUMN');
         FND_MESSAGE.SET_TOKEN('COLUMN', 'code_primary_segment');
         FND_MSG_PUB.ADD;
         x_return_status := FND_API.G_RET_STS_ERROR;


    END IF;

END validate_industrial_classes;


procedure validate_industrial_class_app(
        p_industrial_class_app_rec IN  HZ_ORG_INFO_PUB.industrial_class_app_rec_type,
        p_create_update_flag       IN  VARCHAR2,
        x_return_status            IN OUT  NOCOPY VARCHAR2
        )
IS
    l_count                NUMBER;
    l_party_id             NUMBER;
    l_industrial_class_id  NUMBER;
    l_begin_date           DATE;
    l_end_date             DATE;
BEGIN

    -- mandatory fields : party_id, industrial_class_id
    IF (p_create_update_flag = 'C' AND
         (p_industrial_class_app_rec.party_id is NULL OR
          p_industrial_class_app_rec.party_id = FND_API.G_MISS_NUM)) OR
        (p_create_update_flag = 'U' AND
         p_industrial_class_app_rec.party_id is NULL) THEN

          FND_MESSAGE.SET_NAME('AR', 'HZ_API_MISSING_COLUMN');
          FND_MESSAGE.SET_TOKEN('COLUMN', 'party_id');
          FND_MSG_PUB.ADD;
          x_return_status := FND_API.G_RET_STS_ERROR;

    END IF;

    IF (p_create_update_flag = 'C' AND
         (p_industrial_class_app_rec.industrial_class_id is NULL OR
          p_industrial_class_app_rec.industrial_class_id = FND_API.G_MISS_NUM)) OR
        (p_create_update_flag = 'U' AND
         p_industrial_class_app_rec.industrial_class_id is NULL) THEN

          FND_MESSAGE.SET_NAME('AR', 'HZ_API_MISSING_COLUMN');
          FND_MESSAGE.SET_TOKEN('COLUMN', 'industrial_class_id');
          FND_MSG_PUB.ADD;
          x_return_status := FND_API.G_RET_STS_ERROR;

    END IF;



    -- non updateable field

    IF (p_create_update_flag = 'U'  AND
        (p_industrial_class_app_rec.party_id <> FND_API.G_MISS_NUM  OR
         p_industrial_class_app_rec.industrial_class_id <> FND_API.G_MISS_NUM  OR
         p_industrial_class_app_rec.end_date <> FND_API.G_MISS_DATE  OR
         p_industrial_class_app_rec.begin_date <> FND_API.G_MISS_DATE )) THEN
       BEGIN
         SELECT party_id, industrial_class_id, begin_date, end_date
         INTO l_party_id, l_industrial_class_id, l_begin_date, l_end_date
         FROM HZ_INDUSTRIAL_CLASS_APP
         WHERE code_applied_id= p_industrial_class_app_rec.code_applied_id;

         if l_party_id <> p_industrial_class_app_rec.party_id  AND
            p_industrial_class_app_rec.party_id <> FND_API.G_MISS_NUM  THEN
              FND_MESSAGE.SET_NAME('AR', 'HZ_API_NONUPDATEABLE_COLUMN');
              FND_MESSAGE.SET_TOKEN('COLUMN', 'party_id');
              FND_MSG_PUB.ADD;
              x_return_status := FND_API.G_RET_STS_ERROR;

         end if;

         if l_industrial_class_id <> p_industrial_class_app_rec.industrial_class_id  AND
            p_industrial_class_app_rec.industrial_class_id <> FND_API.G_MISS_NUM  THEN
              FND_MESSAGE.SET_NAME('AR', 'HZ_API_NONUPDATEABLE_COLUMN');
              FND_MESSAGE.SET_TOKEN('COLUMN', 'industrial_class_id');
              FND_MSG_PUB.ADD;
              x_return_status := FND_API.G_RET_STS_ERROR;

         end if;


         EXCEPTION WHEN NO_DATA_FOUND THEN
         FND_MESSAGE.SET_NAME('AR', 'HZ_API_NO_RECORD');
         FND_MESSAGE.SET_TOKEN('RECORD', 'industrial class applied');
         FND_MESSAGE.SET_TOKEN('VALUE', to_char(p_industrial_class_app_rec.code_applied_id));
         FND_MSG_PUB.ADD;
         x_return_status := FND_API.G_RET_STS_ERROR;

      END;


    END IF;



    -- foreign keys: party_id to HZ_PARTIES table.
    --               industrial_class_id to hz_industrial_class_app

    IF p_industrial_class_app_rec.party_id is NOT NULL   AND
       p_industrial_class_app_rec.party_id <> FND_API.G_MISS_NUM THEN

         SELECT COUNT(*) INTO l_count
         FROM hz_parties
         where party_id = p_industrial_class_app_rec.party_id;

         IF l_count = 0 THEN
                        FND_MESSAGE.SET_NAME('AR', 'HZ_API_INVALID_FK');
                        FND_MESSAGE.SET_TOKEN('FK', 'party_id');
                        FND_MESSAGE.SET_TOKEN('COLUMN', 'party_id');
                        FND_MESSAGE.SET_TOKEN('TABLE', 'hz_parties');
                        FND_MSG_PUB.ADD;
                        x_return_status := FND_API.G_RET_STS_ERROR;

         END IF;

    END IF;

    IF p_industrial_class_app_rec.industrial_class_id is NOT NULL   AND
       p_industrial_class_app_rec.industrial_class_id <> FND_API.G_MISS_NUM THEN

         SELECT COUNT(*) INTO l_count
         FROM hz_industrial_classes
         where industrial_class_id = p_industrial_class_app_rec.industrial_class_id;

         IF l_count = 0 THEN
                        FND_MESSAGE.SET_NAME('AR', 'HZ_API_INVALID_FK');
                        FND_MESSAGE.SET_TOKEN('FK', 'industrial_class_id');
                        FND_MESSAGE.SET_TOKEN('COLUMN', 'industrial_class_id');
                        FND_MESSAGE.SET_TOKEN('TABLE', 'hz_industrial_classes');
                        FND_MSG_PUB.ADD;
                        x_return_status := FND_API.G_RET_STS_ERROR;

         END IF;

    END IF;


    -- end_date should be greater than begin_date

    IF p_create_update_flag = 'C'  THEN
         IF p_industrial_class_app_rec.end_date is  NOT NULL  AND
            p_industrial_class_app_rec.end_date <> FND_API.G_MISS_DATE  THEN
              if (p_industrial_class_app_rec.end_date
                  < p_industrial_class_app_rec.begin_date  OR
                  p_industrial_class_app_rec.begin_date IS NULL  OR
                  p_industrial_class_app_rec.begin_date = FND_API.G_MISS_DATE)  THEN
                    FND_MESSAGE.SET_NAME('AR', 'HZ_API_START_DATE_GREATER');
                    FND_MSG_PUB.ADD;
                    x_return_status := FND_API.G_RET_STS_ERROR;

              end if;
          END IF;


     -- compare end_date with database data and user passed data.
     ELSIF p_create_update_flag = 'U' THEN
             if (p_industrial_class_app_rec.end_date is  NOT NULL  AND
                 p_industrial_class_app_rec.end_date <> FND_API.G_MISS_DATE)   THEN
                   if p_industrial_class_app_rec.begin_date is NOT NULL  AND
                      p_industrial_class_app_rec.begin_date <> FND_API.G_MISS_DATE  then
                        if p_industrial_class_app_rec.end_date
                           <p_industrial_class_app_rec.begin_date then
                             FND_MESSAGE.SET_NAME('AR', 'HZ_API_START_DATE_GREATER');
                             FND_MSG_PUB.ADD;
                             x_return_status := FND_API.G_RET_STS_ERROR;

                        end if;
                   elsif (p_industrial_class_app_rec.end_date < l_begin_date  OR
                          l_begin_date is NULL)  then
                           FND_MESSAGE.SET_NAME('AR', 'HZ_API_START_DATE_GREATER');
                           FND_MSG_PUB.ADD;
                           x_return_status := FND_API.G_RET_STS_ERROR;

                   end if;
              elsif (p_industrial_class_app_rec.begin_date is  NOT NULL  AND
                     p_industrial_class_app_rec.begin_date <> FND_API.G_MISS_DATE)   THEN
                      if l_end_date < p_industrial_class_app_rec.begin_date then
                        FND_MESSAGE.SET_NAME('AR', 'HZ_API_START_DATE_GREATER');
                        FND_MSG_PUB.ADD;
                        x_return_status := FND_API.G_RET_STS_ERROR;
                      end if;
              end if;
     END IF;
END validate_industrial_class_app;


END HZ_ORG_INFO_VALIDATE;

/
