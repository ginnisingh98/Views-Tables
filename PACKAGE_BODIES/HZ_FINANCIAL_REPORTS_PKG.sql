--------------------------------------------------------
--  DDL for Package Body HZ_FINANCIAL_REPORTS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."HZ_FINANCIAL_REPORTS_PKG" as
/* $Header: ARHOFRTB.pls 120.9 2005/10/30 04:20:52 appldev ship $ */

G_MISS_CONTENT_SOURCE_TYPE              CONSTANT VARCHAR2(30) := 'USER_ENTERED';
PROCEDURE Insert_Row (
    x_rowid                                 IN OUT NOCOPY VARCHAR2,
    x_financial_report_id                   IN OUT NOCOPY NUMBER,
    x_date_report_issued                    IN     DATE,
    x_party_id                              IN     NUMBER,
    x_document_reference                    IN     VARCHAR2,
    x_issued_period                         IN     VARCHAR2,
    x_requiring_authority                   IN     VARCHAR2,
    x_type_of_financial_report              IN     VARCHAR2,
    x_report_start_date                     IN     DATE,
    x_report_end_date                       IN     DATE,
    x_audit_ind                             IN     VARCHAR2,
    x_consolidated_ind                      IN     VARCHAR2,
    x_estimated_ind                         IN     VARCHAR2,
    x_fiscal_ind                            IN     VARCHAR2,
    x_final_ind                             IN     VARCHAR2,
    x_forecast_ind                          IN     VARCHAR2,
    x_opening_ind                           IN     VARCHAR2,
    x_proforma_ind                          IN     VARCHAR2,
    x_qualified_ind                         IN     VARCHAR2,
    x_restated_ind                          IN     VARCHAR2,
    x_signed_by_principals_ind              IN     VARCHAR2,
    x_trial_balance_ind                     IN     VARCHAR2,
    x_unbalanced_ind                        IN     VARCHAR2,
    x_content_source_type                   IN     VARCHAR2,
    x_status                                IN     VARCHAR2,
    x_object_version_number                 IN     NUMBER,
    x_created_by_module                     IN     VARCHAR2,
    x_actual_content_source                 IN     VARCHAR2
) IS

    l_success                               VARCHAR2(1) := 'N';

BEGIN

    WHILE l_success = 'N' LOOP
    BEGIN
      INSERT INTO HZ_FINANCIAL_REPORTS (
        financial_report_id,
        date_report_issued,
        party_id,
        document_reference,
        issued_period,
        requiring_authority,
        type_of_financial_report,
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
        created_by,
        creation_date,
        last_update_login,
        last_update_date,
        last_updated_by,
        request_id,
        program_application_id,
        program_id,
        program_update_date,
        status,
        object_version_number,
        created_by_module,
        application_id,
        actual_content_source
      )
      VALUES (
        DECODE(x_financial_report_id,
               FND_API.G_MISS_NUM, HZ_FINANCIAL_REPORTS_S.NEXTVAL,
               NULL, HZ_FINANCIAL_REPORTS_S.NEXTVAL,
               x_financial_report_id),
        DECODE(x_date_report_issued,
               FND_API.G_MISS_DATE, TO_DATE(NULL),
               x_date_report_issued),
        DECODE(x_party_id,
               FND_API.G_MISS_NUM, NULL,
               x_party_id),
        DECODE(x_document_reference,
               FND_API.G_MISS_CHAR, NULL,
               x_document_reference),
        DECODE(x_issued_period,
               FND_API.G_MISS_CHAR, NULL,
               x_issued_period),
        DECODE(x_requiring_authority,
               FND_API.G_MISS_CHAR, NULL,
               x_requiring_authority),
        DECODE(x_type_of_financial_report,
               FND_API.G_MISS_CHAR, NULL,
               x_type_of_financial_report),
        DECODE(x_report_start_date,
               FND_API.G_MISS_DATE, TO_DATE(NULL),
               x_report_start_date),
        DECODE(x_report_end_date,
               FND_API.G_MISS_DATE, TO_DATE(NULL),
               x_report_end_date),
        DECODE(x_audit_ind,
               FND_API.G_MISS_CHAR, NULL,
               x_audit_ind),
        DECODE(x_consolidated_ind,
               FND_API.G_MISS_CHAR, NULL,
               x_consolidated_ind),
        DECODE(x_estimated_ind,
               FND_API.G_MISS_CHAR, NULL,
               x_estimated_ind),
        DECODE(x_fiscal_ind,
               FND_API.G_MISS_CHAR, NULL,
               x_fiscal_ind),
        DECODE(x_final_ind,
               FND_API.G_MISS_CHAR, NULL,
               x_final_ind),
        DECODE(x_forecast_ind,
               FND_API.G_MISS_CHAR, NULL,
               x_forecast_ind),
        DECODE(x_opening_ind,
               FND_API.G_MISS_CHAR, NULL,
               x_opening_ind),
        DECODE(x_proforma_ind,
               FND_API.G_MISS_CHAR, NULL,
               x_proforma_ind),
        DECODE(x_qualified_ind,
               FND_API.G_MISS_CHAR, NULL,
               x_qualified_ind),
        DECODE(x_restated_ind,
               FND_API.G_MISS_CHAR, NULL,
               x_restated_ind),
        DECODE(x_signed_by_principals_ind,
               FND_API.G_MISS_CHAR, NULL,
               x_signed_by_principals_ind),
        DECODE(x_trial_balance_ind,
               FND_API.G_MISS_CHAR, NULL,
               x_trial_balance_ind),
        DECODE(x_unbalanced_ind,
               FND_API.G_MISS_CHAR, NULL,
               x_unbalanced_ind),
        DECODE(x_content_source_type,
               FND_API.G_MISS_CHAR, G_MISS_CONTENT_SOURCE_TYPE,
               NULL, G_MISS_CONTENT_SOURCE_TYPE,
               x_content_source_type),
        hz_utility_v2pub.created_by,
        hz_utility_v2pub.creation_date,
        hz_utility_v2pub.last_update_login,
        hz_utility_v2pub.last_update_date,
        hz_utility_v2pub.last_updated_by,
        hz_utility_v2pub.request_id,
        hz_utility_v2pub.program_application_id,
        hz_utility_v2pub.program_id,
        hz_utility_v2pub.program_update_date,
        DECODE(x_status,
               FND_API.G_MISS_CHAR, 'A',
               NULL, 'A',
               x_status),
        DECODE(x_object_version_number,
               FND_API.G_MISS_NUM, NULL,
               x_object_version_number),
        DECODE(x_created_by_module,
               FND_API.G_MISS_CHAR, NULL,
               x_created_by_module),
        hz_utility_v2pub.application_id,
        DECODE(x_actual_content_source,
               FND_API.G_MISS_CHAR, G_MISS_CONTENT_SOURCE_TYPE,
               NULL, G_MISS_CONTENT_SOURCE_TYPE,
               x_actual_content_source)
      ) RETURNING
        rowid,
        financial_report_id
      INTO
        x_rowid,
        x_financial_report_id;

      l_success := 'Y';

    EXCEPTION
      WHEN DUP_VAL_ON_INDEX THEN
        IF INSTR(SQLERRM, 'HZ_FINANCIAL_REPORTS_U1') <> 0 THEN
        DECLARE
          l_count             NUMBER;
          l_dummy             VARCHAR2(1);
        BEGIN
          l_count := 1;
          WHILE l_count > 0 LOOP
            SELECT HZ_FINANCIAL_REPORTS_S.NEXTVAL
            INTO x_financial_report_id FROM dual;
            BEGIN
              SELECT 'Y' INTO l_dummy
              FROM HZ_FINANCIAL_REPORTS
              WHERE financial_report_id = x_financial_report_id;
              l_count := 1;
            EXCEPTION
              WHEN NO_DATA_FOUND THEN
                l_count := 0;
            END;
          END LOOP;
        END;
--Bug fix 3038555
        ELSE
  		RAISE;
        END IF;

    END;
    END LOOP;

END Insert_Row;

PROCEDURE Update_Row (
    x_rowid                                 IN OUT NOCOPY VARCHAR2,
    x_financial_report_id                   IN     NUMBER,
    x_date_report_issued                    IN     DATE,
    x_party_id                              IN     NUMBER,
    x_document_reference                    IN     VARCHAR2,
    x_issued_period                         IN     VARCHAR2,
    x_requiring_authority                   IN     VARCHAR2,
    x_type_of_financial_report              IN     VARCHAR2,
    x_report_start_date                     IN     DATE,
    x_report_end_date                       IN     DATE,
    x_audit_ind                             IN     VARCHAR2,
    x_consolidated_ind                      IN     VARCHAR2,
    x_estimated_ind                         IN     VARCHAR2,
    x_fiscal_ind                            IN     VARCHAR2,
    x_final_ind                             IN     VARCHAR2,
    x_forecast_ind                          IN     VARCHAR2,
    x_opening_ind                           IN     VARCHAR2,
    x_proforma_ind                          IN     VARCHAR2,
    x_qualified_ind                         IN     VARCHAR2,
    x_restated_ind                          IN     VARCHAR2,
    x_signed_by_principals_ind              IN     VARCHAR2,
    x_trial_balance_ind                     IN     VARCHAR2,
    x_unbalanced_ind                        IN     VARCHAR2,
    x_content_source_type                   IN     VARCHAR2,
    x_status                                IN     VARCHAR2,
    x_object_version_number                 IN     NUMBER,
    x_created_by_module                     IN     VARCHAR2,
    x_actual_content_source                 IN     VARCHAR2
) IS
BEGIN

    UPDATE HZ_FINANCIAL_REPORTS
    SET
      financial_report_id =
        DECODE(x_financial_report_id,
               NULL, financial_report_id,
               FND_API.G_MISS_NUM, NULL,
               x_financial_report_id),
      date_report_issued =
        DECODE(x_date_report_issued,
               NULL, date_report_issued,
               FND_API.G_MISS_DATE, NULL,
               x_date_report_issued),
      party_id =
        DECODE(x_party_id,
               NULL, party_id,
               FND_API.G_MISS_NUM, NULL,
               x_party_id),
      document_reference =
        DECODE(x_document_reference,
               NULL, document_reference,
               FND_API.G_MISS_CHAR, NULL,
               x_document_reference),
      issued_period =
        DECODE(x_issued_period,
               NULL, issued_period,
               FND_API.G_MISS_CHAR, NULL,
               x_issued_period),
      requiring_authority =
        DECODE(x_requiring_authority,
               NULL, requiring_authority,
               FND_API.G_MISS_CHAR, NULL,
               x_requiring_authority),
      type_of_financial_report =
        DECODE(x_type_of_financial_report,
               NULL, type_of_financial_report,
               FND_API.G_MISS_CHAR, NULL,
               x_type_of_financial_report),
      report_start_date =
        DECODE(x_report_start_date,
               NULL, report_start_date,
               FND_API.G_MISS_DATE, NULL,
               x_report_start_date),
      report_end_date =
        DECODE(x_report_end_date,
               NULL, report_end_date,
               FND_API.G_MISS_DATE, NULL,
               x_report_end_date),
      audit_ind =
        DECODE(x_audit_ind,
               NULL, audit_ind,
               FND_API.G_MISS_CHAR, NULL,
               x_audit_ind),
      consolidated_ind =
        DECODE(x_consolidated_ind,
               NULL, consolidated_ind,
               FND_API.G_MISS_CHAR, NULL,
               x_consolidated_ind),
      estimated_ind =
        DECODE(x_estimated_ind,
               NULL, estimated_ind,
               FND_API.G_MISS_CHAR, NULL,
               x_estimated_ind),
      fiscal_ind =
        DECODE(x_fiscal_ind,
               NULL, fiscal_ind,
               FND_API.G_MISS_CHAR, NULL,
               x_fiscal_ind),
      final_ind =
        DECODE(x_final_ind,
               NULL, final_ind,
               FND_API.G_MISS_CHAR, NULL,
               x_final_ind),
      forecast_ind =
        DECODE(x_forecast_ind,
               NULL, forecast_ind,
               FND_API.G_MISS_CHAR, NULL,
               x_forecast_ind),
      opening_ind =
        DECODE(x_opening_ind,
               NULL, opening_ind,
               FND_API.G_MISS_CHAR, NULL,
               x_opening_ind),
      proforma_ind =
        DECODE(x_proforma_ind,
               NULL, proforma_ind,
               FND_API.G_MISS_CHAR, NULL,
               x_proforma_ind),
      qualified_ind =
        DECODE(x_qualified_ind,
               NULL, qualified_ind,
               FND_API.G_MISS_CHAR, NULL,
               x_qualified_ind),
      restated_ind =
        DECODE(x_restated_ind,
               NULL, restated_ind,
               FND_API.G_MISS_CHAR, NULL,
               x_restated_ind),
      signed_by_principals_ind =
        DECODE(x_signed_by_principals_ind,
               NULL, signed_by_principals_ind,
               FND_API.G_MISS_CHAR, NULL,
               x_signed_by_principals_ind),
      trial_balance_ind =
        DECODE(x_trial_balance_ind,
               NULL, trial_balance_ind,
               FND_API.G_MISS_CHAR, NULL,
               x_trial_balance_ind),
      unbalanced_ind =
        DECODE(x_unbalanced_ind,
               NULL, unbalanced_ind,
               FND_API.G_MISS_CHAR, NULL,
               x_unbalanced_ind),
      content_source_type =
        DECODE(x_content_source_type,
               NULL, content_source_type,
               FND_API.G_MISS_CHAR, NULL,
               x_content_source_type),
      created_by = created_by,
      creation_date = creation_date,
      last_update_login = hz_utility_v2pub.last_update_login,
      last_update_date = hz_utility_v2pub.last_update_date,
      last_updated_by = hz_utility_v2pub.last_updated_by,
      request_id = hz_utility_v2pub.request_id,
      program_application_id = hz_utility_v2pub.program_application_id,
      program_id = hz_utility_v2pub.program_id,
      program_update_date = hz_utility_v2pub.program_update_date,
      status =
        DECODE(x_status,
               NULL, status,
               FND_API.G_MISS_CHAR, NULL,
               x_status),
      object_version_number =
        DECODE(x_object_version_number,
               NULL, object_version_number,
               FND_API.G_MISS_NUM, NULL,
               x_object_version_number),
      created_by_module =
        DECODE(x_created_by_module,
               NULL, created_by_module,
               FND_API.G_MISS_CHAR, NULL,
               x_created_by_module),
      application_id = hz_utility_v2pub.application_id/*,

      ** SSM SST Integration and Extension
      ** actual_content_source is not updated for non-SSM enabled entities.

      actual_content_source =
        DECODE(x_actual_content_source,
               NULL, actual_content_source,
               FND_API.G_MISS_CHAR, NULL,
               x_actual_content_source)    */
    WHERE rowid = x_rowid;

    IF ( SQL%NOTFOUND ) THEN
      RAISE NO_DATA_FOUND;
    END IF;

END Update_Row;

PROCEDURE Lock_Row (
    x_rowid                                 IN OUT NOCOPY VARCHAR2,
    x_financial_report_id                   IN     NUMBER,
    x_date_report_issued                    IN     DATE,
    x_party_id                              IN     NUMBER,
    x_document_reference                    IN     VARCHAR2,
    x_issued_period                         IN     VARCHAR2,
    x_requiring_authority                   IN     VARCHAR2,
    x_type_of_financial_report              IN     VARCHAR2,
    x_report_start_date                     IN     DATE,
    x_report_end_date                       IN     DATE,
    x_audit_ind                             IN     VARCHAR2,
    x_consolidated_ind                      IN     VARCHAR2,
    x_estimated_ind                         IN     VARCHAR2,
    x_fiscal_ind                            IN     VARCHAR2,
    x_final_ind                             IN     VARCHAR2,
    x_forecast_ind                          IN     VARCHAR2,
    x_opening_ind                           IN     VARCHAR2,
    x_proforma_ind                          IN     VARCHAR2,
    x_qualified_ind                         IN     VARCHAR2,
    x_restated_ind                          IN     VARCHAR2,
    x_signed_by_principals_ind              IN     VARCHAR2,
    x_trial_balance_ind                     IN     VARCHAR2,
    x_unbalanced_ind                        IN     VARCHAR2,
    x_content_source_type                   IN     VARCHAR2,
    x_created_by                            IN     NUMBER,
    x_creation_date                         IN     DATE,
    x_last_update_login                     IN     NUMBER,
    x_last_update_date                      IN     DATE,
    x_last_updated_by                       IN     NUMBER,
    x_request_id                            IN     NUMBER,
    x_program_application_id                IN     NUMBER,
    x_program_id                            IN     NUMBER,
    x_program_update_date                   IN     DATE,
    x_status                                IN     VARCHAR2,
    x_object_version_number                 IN     NUMBER,
    x_created_by_module                     IN     VARCHAR2,
    x_application_id                        IN     NUMBER,
    x_actual_content_source                 IN     VARCHAR2
) IS

    CURSOR c IS
      SELECT * FROM hz_financial_reports
      WHERE rowid = x_rowid
      FOR UPDATE NOWAIT;
    Recinfo c%ROWTYPE;

BEGIN

    OPEN c;
    FETCH c INTO Recinfo;
    IF ( c%NOTFOUND ) THEN
      CLOSE c;
      FND_MESSAGE.SET_NAME('FND', 'FORM_RECORD_DELETED');
      APP_EXCEPTION.RAISE_EXCEPTION;
    END IF;
    CLOSE C;

    IF (
        ( ( Recinfo.financial_report_id = x_financial_report_id )
        OR ( ( Recinfo.financial_report_id IS NULL )
          AND (  x_financial_report_id IS NULL ) ) )
    AND ( ( Recinfo.date_report_issued = x_date_report_issued )
        OR ( ( Recinfo.date_report_issued IS NULL )
          AND (  x_date_report_issued IS NULL ) ) )
    AND ( ( Recinfo.party_id = x_party_id )
        OR ( ( Recinfo.party_id IS NULL )
          AND (  x_party_id IS NULL ) ) )
    AND ( ( Recinfo.document_reference = x_document_reference )
        OR ( ( Recinfo.document_reference IS NULL )
          AND (  x_document_reference IS NULL ) ) )
    AND ( ( Recinfo.issued_period = x_issued_period )
        OR ( ( Recinfo.issued_period IS NULL )
          AND (  x_issued_period IS NULL ) ) )
    AND ( ( Recinfo.requiring_authority = x_requiring_authority )
        OR ( ( Recinfo.requiring_authority IS NULL )
          AND (  x_requiring_authority IS NULL ) ) )
    AND ( ( Recinfo.type_of_financial_report = x_type_of_financial_report )
        OR ( ( Recinfo.type_of_financial_report IS NULL )
          AND (  x_type_of_financial_report IS NULL ) ) )
    AND ( ( Recinfo.report_start_date = x_report_start_date )
        OR ( ( Recinfo.report_start_date IS NULL )
          AND (  x_report_start_date IS NULL ) ) )
    AND ( ( Recinfo.report_end_date = x_report_end_date )
        OR ( ( Recinfo.report_end_date IS NULL )
          AND (  x_report_end_date IS NULL ) ) )
    AND ( ( Recinfo.audit_ind = x_audit_ind )
        OR ( ( Recinfo.audit_ind IS NULL )
          AND (  x_audit_ind IS NULL ) ) )
    AND ( ( Recinfo.consolidated_ind = x_consolidated_ind )
        OR ( ( Recinfo.consolidated_ind IS NULL )
          AND (  x_consolidated_ind IS NULL ) ) )
    AND ( ( Recinfo.estimated_ind = x_estimated_ind )
        OR ( ( Recinfo.estimated_ind IS NULL )
          AND (  x_estimated_ind IS NULL ) ) )
    AND ( ( Recinfo.fiscal_ind = x_fiscal_ind )
        OR ( ( Recinfo.fiscal_ind IS NULL )
          AND (  x_fiscal_ind IS NULL ) ) )
    AND ( ( Recinfo.final_ind = x_final_ind )
        OR ( ( Recinfo.final_ind IS NULL )
          AND (  x_final_ind IS NULL ) ) )
    AND ( ( Recinfo.forecast_ind = x_forecast_ind )
        OR ( ( Recinfo.forecast_ind IS NULL )
          AND (  x_forecast_ind IS NULL ) ) )
    AND ( ( Recinfo.opening_ind = x_opening_ind )
        OR ( ( Recinfo.opening_ind IS NULL )
          AND (  x_opening_ind IS NULL ) ) )
    AND ( ( Recinfo.proforma_ind = x_proforma_ind )
        OR ( ( Recinfo.proforma_ind IS NULL )
          AND (  x_proforma_ind IS NULL ) ) )
    AND ( ( Recinfo.qualified_ind = x_qualified_ind )
        OR ( ( Recinfo.qualified_ind IS NULL )
          AND (  x_qualified_ind IS NULL ) ) )
    AND ( ( Recinfo.restated_ind = x_restated_ind )
        OR ( ( Recinfo.restated_ind IS NULL )
          AND (  x_restated_ind IS NULL ) ) )
    AND ( ( Recinfo.signed_by_principals_ind = x_signed_by_principals_ind )
        OR ( ( Recinfo.signed_by_principals_ind IS NULL )
          AND (  x_signed_by_principals_ind IS NULL ) ) )
    AND ( ( Recinfo.trial_balance_ind = x_trial_balance_ind )
        OR ( ( Recinfo.trial_balance_ind IS NULL )
          AND (  x_trial_balance_ind IS NULL ) ) )
    AND ( ( Recinfo.unbalanced_ind = x_unbalanced_ind )
        OR ( ( Recinfo.unbalanced_ind IS NULL )
          AND (  x_unbalanced_ind IS NULL ) ) )
    AND ( ( Recinfo.content_source_type = x_content_source_type )
        OR ( ( Recinfo.content_source_type IS NULL )
          AND (  x_content_source_type IS NULL ) ) )
    AND ( ( Recinfo.created_by = x_created_by )
        OR ( ( Recinfo.created_by IS NULL )
          AND (  x_created_by IS NULL ) ) )
    AND ( ( Recinfo.creation_date = x_creation_date )
        OR ( ( Recinfo.creation_date IS NULL )
          AND (  x_creation_date IS NULL ) ) )
    AND ( ( Recinfo.last_update_login = x_last_update_login )
        OR ( ( Recinfo.last_update_login IS NULL )
          AND (  x_last_update_login IS NULL ) ) )
    AND ( ( Recinfo.last_update_date = x_last_update_date )
        OR ( ( Recinfo.last_update_date IS NULL )
          AND (  x_last_update_date IS NULL ) ) )
    AND ( ( Recinfo.last_updated_by = x_last_updated_by )
        OR ( ( Recinfo.last_updated_by IS NULL )
          AND (  x_last_updated_by IS NULL ) ) )
    AND ( ( Recinfo.request_id = x_request_id )
        OR ( ( Recinfo.request_id IS NULL )
          AND (  x_request_id IS NULL ) ) )
    AND ( ( Recinfo.program_application_id = x_program_application_id )
        OR ( ( Recinfo.program_application_id IS NULL )
          AND (  x_program_application_id IS NULL ) ) )
    AND ( ( Recinfo.program_id = x_program_id )
        OR ( ( Recinfo.program_id IS NULL )
          AND (  x_program_id IS NULL ) ) )
    AND ( ( Recinfo.program_update_date = x_program_update_date )
        OR ( ( Recinfo.program_update_date IS NULL )
          AND (  x_program_update_date IS NULL ) ) )
    AND ( ( Recinfo.status = x_status )
        OR ( ( Recinfo.status IS NULL )
          AND (  x_status IS NULL ) ) )
    AND ( ( Recinfo.object_version_number = x_object_version_number )
        OR ( ( Recinfo.object_version_number IS NULL )
          AND (  x_object_version_number IS NULL ) ) )
    AND ( ( Recinfo.created_by_module = x_created_by_module )
        OR ( ( Recinfo.created_by_module IS NULL )
          AND (  x_created_by_module IS NULL ) ) )
    AND ( ( Recinfo.application_id = x_application_id )
        OR ( ( Recinfo.application_id IS NULL )
          AND (  x_application_id IS NULL ) ) )
    AND ( ( Recinfo.actual_content_source = x_actual_content_source )
        OR ( ( Recinfo.actual_content_source IS NULL )
          AND (  x_actual_content_source IS NULL ) ) )
    ) THEN
      RETURN;
    ELSE
      FND_MESSAGE.SET_NAME('FND', 'FORM_RECORD_DELETED');
      APP_EXCEPTION.RAISE_EXCEPTION;
    END IF;

END Lock_Row;

PROCEDURE Select_Row (
    x_financial_report_id                   IN OUT NOCOPY NUMBER,
    x_date_report_issued                    OUT    NOCOPY DATE,
    x_party_id                              OUT    NOCOPY NUMBER,
    x_document_reference                    OUT    NOCOPY VARCHAR2,
    x_issued_period                         OUT    NOCOPY VARCHAR2,
    x_requiring_authority                   OUT    NOCOPY VARCHAR2,
    x_type_of_financial_report              OUT    NOCOPY VARCHAR2,
    x_report_start_date                     OUT    NOCOPY DATE,
    x_report_end_date                       OUT    NOCOPY DATE,
    x_audit_ind                             OUT    NOCOPY VARCHAR2,
    x_consolidated_ind                      OUT    NOCOPY VARCHAR2,
    x_estimated_ind                         OUT    NOCOPY VARCHAR2,
    x_fiscal_ind                            OUT    NOCOPY VARCHAR2,
    x_final_ind                             OUT    NOCOPY VARCHAR2,
    x_forecast_ind                          OUT    NOCOPY VARCHAR2,
    x_opening_ind                           OUT    NOCOPY VARCHAR2,
    x_proforma_ind                          OUT    NOCOPY VARCHAR2,
    x_qualified_ind                         OUT    NOCOPY VARCHAR2,
    x_restated_ind                          OUT    NOCOPY VARCHAR2,
    x_signed_by_principals_ind              OUT    NOCOPY VARCHAR2,
    x_trial_balance_ind                     OUT    NOCOPY VARCHAR2,
    x_unbalanced_ind                        OUT    NOCOPY VARCHAR2,
    x_content_source_type                   OUT    NOCOPY VARCHAR2,
    x_status                                OUT    NOCOPY VARCHAR2,
    x_actual_content_source                 OUT    NOCOPY VARCHAR2,
    x_created_by_module                     OUT    NOCOPY VARCHAR2
) IS
BEGIN

    SELECT
      NVL(financial_report_id, FND_API.G_MISS_NUM),
      NVL(date_report_issued, FND_API.G_MISS_DATE),
      NVL(party_id, FND_API.G_MISS_NUM),
      NVL(document_reference, FND_API.G_MISS_CHAR),
      NVL(issued_period, FND_API.G_MISS_CHAR),
      NVL(requiring_authority, FND_API.G_MISS_CHAR),
      NVL(type_of_financial_report, FND_API.G_MISS_CHAR),
      NVL(report_start_date, FND_API.G_MISS_DATE),
      NVL(report_end_date, FND_API.G_MISS_DATE),
      NVL(audit_ind, FND_API.G_MISS_CHAR),
      NVL(consolidated_ind, FND_API.G_MISS_CHAR),
      NVL(estimated_ind, FND_API.G_MISS_CHAR),
      NVL(fiscal_ind, FND_API.G_MISS_CHAR),
      NVL(final_ind, FND_API.G_MISS_CHAR),
      NVL(forecast_ind, FND_API.G_MISS_CHAR),
      NVL(opening_ind, FND_API.G_MISS_CHAR),
      NVL(proforma_ind, FND_API.G_MISS_CHAR),
      NVL(qualified_ind, FND_API.G_MISS_CHAR),
      NVL(restated_ind, FND_API.G_MISS_CHAR),
      NVL(signed_by_principals_ind, FND_API.G_MISS_CHAR),
      NVL(trial_balance_ind, FND_API.G_MISS_CHAR),
      NVL(unbalanced_ind, FND_API.G_MISS_CHAR),
      NVL(content_source_type, FND_API.G_MISS_CHAR),
      NVL(status, FND_API.G_MISS_CHAR),
      NVL(actual_content_source, FND_API.G_MISS_CHAR),
      NVL(created_by_module, FND_API.G_MISS_CHAR)
    INTO
      x_financial_report_id,
      x_date_report_issued,
      x_party_id,
      x_document_reference,
      x_issued_period,
      x_requiring_authority,
      x_type_of_financial_report,
      x_report_start_date,
      x_report_end_date,
      x_audit_ind,
      x_consolidated_ind,
      x_estimated_ind,
      x_fiscal_ind,
      x_final_ind,
      x_forecast_ind,
      x_opening_ind,
      x_proforma_ind,
      x_qualified_ind,
      x_restated_ind,
      x_signed_by_principals_ind,
      x_trial_balance_ind,
      x_unbalanced_ind,
      x_content_source_type,
      x_status,
      x_actual_content_source,
      x_created_by_module
    FROM HZ_FINANCIAL_REPORTS
    WHERE financial_report_id = x_financial_report_id;

EXCEPTION
    WHEN NO_DATA_FOUND THEN
      FND_MESSAGE.SET_NAME('AR', 'HZ_API_NO_RECORD');
      FND_MESSAGE.SET_TOKEN('RECORD', 'hz_financial_reports_rec');
      FND_MESSAGE.SET_TOKEN('VALUE', TO_CHAR(x_financial_report_id));
      FND_MSG_PUB.ADD;
      RAISE FND_API.G_EXC_ERROR;

END Select_Row;

PROCEDURE Delete_Row (
    x_financial_report_id                   IN     NUMBER
) IS
BEGIN

    DELETE FROM HZ_FINANCIAL_REPORTS
    WHERE financial_report_id = x_financial_report_id;

    IF ( SQL%NOTFOUND ) THEN
      RAISE NO_DATA_FOUND;
    END IF;

END Delete_Row;

END HZ_FINANCIAL_REPORTS_PKG;

/
