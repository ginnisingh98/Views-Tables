--------------------------------------------------------
--  DDL for Package Body HZ_ORGANIZATION_INFO_V2PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."HZ_ORGANIZATION_INFO_V2PVT" AS
/*$Header: ARHORI1B.pls 120.2 2005/06/16 21:12:53 jhuang noship $ */

--------------------------------------
-- declaration of private global varibles
--------------------------------------

DEFAULT_CREATED_BY_MODULE     CONSTANT VARCHAR2(10) := 'TCA_V1_API';
x_msg_count                            NUMBER;
x_msg_data                             VARCHAR2(2000);

--------------------------------------
-- private procedures and functions
--------------------------------------

PROCEDURE v2_financial_report_pre (
    p_create_update_flag                    IN     VARCHAR2,
    p_financial_report_rec                  IN     HZ_ORG_INFO_PUB.FINANCIAL_REPORTS_REC_TYPE,
    x_financial_report_rec                  OUT     NOCOPY HZ_ORGANIZATION_INFO_V2PUB.FINANCIAL_REPORT_REC_TYPE
) IS

BEGIN

        IF p_financial_report_rec.financial_report_id IS NULL THEN
            x_financial_report_rec.financial_report_id := FND_API.G_MISS_NUM;
        ELSIF p_financial_report_rec.financial_report_id <> FND_API.G_MISS_NUM THEN
            x_financial_report_rec.financial_report_id := p_financial_report_rec.financial_report_id;
        END IF;

        IF p_financial_report_rec.party_id IS NULL THEN
            x_financial_report_rec.party_id := FND_API.G_MISS_NUM;
        ELSIF p_financial_report_rec.party_id <> FND_API.G_MISS_NUM THEN
            x_financial_report_rec.party_id := p_financial_report_rec.party_id;
        END IF;

        IF p_financial_report_rec.type_of_financial_report IS NULL THEN
            x_financial_report_rec.type_of_financial_report := FND_API.G_MISS_CHAR;
        ELSIF p_financial_report_rec.type_of_financial_report <> FND_API.G_MISS_CHAR THEN
            x_financial_report_rec.type_of_financial_report := p_financial_report_rec.type_of_financial_report;
        END IF;

        IF p_financial_report_rec.document_reference IS NULL THEN
            x_financial_report_rec.document_reference := FND_API.G_MISS_CHAR;
        ELSIF p_financial_report_rec.document_reference <> FND_API.G_MISS_CHAR THEN
            x_financial_report_rec.document_reference := p_financial_report_rec.document_reference;
        END IF;

        IF p_financial_report_rec.date_report_issued IS NULL THEN
            x_financial_report_rec.date_report_issued := FND_API.G_MISS_DATE;
        ELSIF p_financial_report_rec.date_report_issued <> FND_API.G_MISS_DATE THEN
            x_financial_report_rec.date_report_issued := p_financial_report_rec.date_report_issued;
        END IF;

        IF p_financial_report_rec.issued_period IS NULL THEN
            x_financial_report_rec.issued_period := FND_API.G_MISS_CHAR;
        ELSIF p_financial_report_rec.issued_period <> FND_API.G_MISS_CHAR THEN
            x_financial_report_rec.issued_period := p_financial_report_rec.issued_period;
        END IF;

        IF p_financial_report_rec.report_start_date IS NULL THEN
            x_financial_report_rec.report_start_date := FND_API.G_MISS_DATE;
        ELSIF p_financial_report_rec.report_start_date <> FND_API.G_MISS_DATE THEN
            x_financial_report_rec.report_start_date := p_financial_report_rec.report_start_date;
        END IF;

        IF p_financial_report_rec.report_end_date IS NULL THEN
            x_financial_report_rec.report_end_date := FND_API.G_MISS_DATE;
        ELSIF p_financial_report_rec.report_end_date <> FND_API.G_MISS_DATE THEN
            x_financial_report_rec.report_end_date := p_financial_report_rec.report_end_date;
        END IF;

        IF p_financial_report_rec.actual_content_source IS NULL THEN
            x_financial_report_rec.actual_content_source := FND_API.G_MISS_CHAR;
        ELSIF p_financial_report_rec.actual_content_source <> FND_API.G_MISS_CHAR THEN
            x_financial_report_rec.actual_content_source := p_financial_report_rec.actual_content_source;
        END IF;

        IF p_financial_report_rec.requiring_authority IS NULL THEN
            x_financial_report_rec.requiring_authority := FND_API.G_MISS_CHAR;
        ELSIF p_financial_report_rec.requiring_authority <> FND_API.G_MISS_CHAR THEN
            x_financial_report_rec.requiring_authority := p_financial_report_rec.requiring_authority;
        END IF;

        IF p_financial_report_rec.audit_ind IS NULL THEN
            x_financial_report_rec.audit_ind := FND_API.G_MISS_CHAR;
        ELSIF p_financial_report_rec.audit_ind <> FND_API.G_MISS_CHAR THEN
            x_financial_report_rec.audit_ind := p_financial_report_rec.audit_ind;
        END IF;

        IF p_financial_report_rec.consolidated_ind IS NULL THEN
            x_financial_report_rec.consolidated_ind := FND_API.G_MISS_CHAR;
        ELSIF p_financial_report_rec.consolidated_ind <> FND_API.G_MISS_CHAR THEN
            x_financial_report_rec.consolidated_ind := p_financial_report_rec.consolidated_ind;
        END IF;

        IF p_financial_report_rec.estimated_ind IS NULL THEN
            x_financial_report_rec.estimated_ind := FND_API.G_MISS_CHAR;
        ELSIF p_financial_report_rec.estimated_ind <> FND_API.G_MISS_CHAR THEN
            x_financial_report_rec.estimated_ind := p_financial_report_rec.estimated_ind;
        END IF;

        IF p_financial_report_rec.fiscal_ind IS NULL THEN
            x_financial_report_rec.fiscal_ind := FND_API.G_MISS_CHAR;
        ELSIF p_financial_report_rec.fiscal_ind <> FND_API.G_MISS_CHAR THEN
            x_financial_report_rec.fiscal_ind := p_financial_report_rec.fiscal_ind;
        END IF;

        --Bug 2940399: Added FINAL_IND column in financial_report_rec_type. Hence added code
        --to copy from v1 record.
        IF p_financial_report_rec.final_ind IS NULL THEN
            x_financial_report_rec.final_ind := FND_API.G_MISS_CHAR;
        ELSIF p_financial_report_rec.final_ind <> FND_API.G_MISS_CHAR THEN
            x_financial_report_rec.final_ind := p_financial_report_rec.final_ind;
        END IF;

        IF p_financial_report_rec.forecast_ind IS NULL THEN
            x_financial_report_rec.forecast_ind := FND_API.G_MISS_CHAR;
        ELSIF p_financial_report_rec.forecast_ind <> FND_API.G_MISS_CHAR THEN
            x_financial_report_rec.forecast_ind := p_financial_report_rec.forecast_ind;
        END IF;

        IF p_financial_report_rec.opening_ind IS NULL THEN
            x_financial_report_rec.opening_ind := FND_API.G_MISS_CHAR;
        ELSIF p_financial_report_rec.opening_ind <> FND_API.G_MISS_CHAR THEN
            x_financial_report_rec.opening_ind := p_financial_report_rec.opening_ind;
        END IF;

        IF p_financial_report_rec.proforma_ind IS NULL THEN
            x_financial_report_rec.proforma_ind := FND_API.G_MISS_CHAR;
        ELSIF p_financial_report_rec.proforma_ind <> FND_API.G_MISS_CHAR THEN
            x_financial_report_rec.proforma_ind := p_financial_report_rec.proforma_ind;
        END IF;

        IF p_financial_report_rec.qualified_ind IS NULL THEN
            x_financial_report_rec.qualified_ind := FND_API.G_MISS_CHAR;
        ELSIF p_financial_report_rec.qualified_ind <> FND_API.G_MISS_CHAR THEN
            x_financial_report_rec.qualified_ind := p_financial_report_rec.qualified_ind;
        END IF;

        IF p_financial_report_rec.restated_ind IS NULL THEN
            x_financial_report_rec.restated_ind := FND_API.G_MISS_CHAR;
        ELSIF p_financial_report_rec.restated_ind <> FND_API.G_MISS_CHAR THEN
            x_financial_report_rec.restated_ind := p_financial_report_rec.restated_ind;
        END IF;

        IF p_financial_report_rec.signed_by_principals_ind IS NULL THEN
            x_financial_report_rec.signed_by_principals_ind := FND_API.G_MISS_CHAR;
        ELSIF p_financial_report_rec.signed_by_principals_ind <> FND_API.G_MISS_CHAR THEN
            x_financial_report_rec.signed_by_principals_ind := p_financial_report_rec.signed_by_principals_ind;
        END IF;

        IF p_financial_report_rec.trial_balance_ind IS NULL THEN
            x_financial_report_rec.trial_balance_ind := FND_API.G_MISS_CHAR;
        ELSIF p_financial_report_rec.trial_balance_ind <> FND_API.G_MISS_CHAR THEN
            x_financial_report_rec.trial_balance_ind := p_financial_report_rec.trial_balance_ind;
        END IF;

        IF p_financial_report_rec.unbalanced_ind IS NULL THEN
            x_financial_report_rec.unbalanced_ind := FND_API.G_MISS_CHAR;
        ELSIF p_financial_report_rec.unbalanced_ind <> FND_API.G_MISS_CHAR THEN
            x_financial_report_rec.unbalanced_ind := p_financial_report_rec.unbalanced_ind;
        END IF;

        IF p_financial_report_rec.status IS NULL THEN
            x_financial_report_rec.status := FND_API.G_MISS_CHAR;
        ELSIF p_financial_report_rec.status <> FND_API.G_MISS_CHAR THEN
            x_financial_report_rec.status := p_financial_report_rec.status;
        END IF;

        IF p_create_update_flag = 'C' THEN
            x_financial_report_rec.created_by_module := DEFAULT_CREATED_BY_MODULE;
        END IF;

END v2_financial_report_pre;

--------------------------------------------------
-- public procedures and functions
--------------------------------------------------

PROCEDURE v2_create_financial_report (
    p_financial_report_rec        IN     HZ_ORG_INFO_PUB.FINANCIAL_REPORTS_REC_TYPE,
    x_return_status               IN OUT  NOCOPY VARCHAR2,
    x_financial_report_id            OUT  NOCOPY NUMBER
) IS

    l_financial_report_rec         HZ_ORGANIZATION_INFO_V2PUB.FINANCIAL_REPORT_REC_TYPE;

BEGIN

    -- pre-process v1 and v2 record.
    v2_financial_report_pre (
        'C',
        p_financial_report_rec,
        l_financial_report_rec );
    -- call V2 API.

    HZ_ORGANIZATION_INFO_V2PUB.create_financial_report (
        p_financial_report_rec             => l_financial_report_rec,
        x_financial_report_id              => x_financial_report_id,
        x_return_status                    => x_return_status,
        x_msg_count                        => x_msg_count,
        x_msg_data                         => x_msg_data );

END v2_create_financial_report;


PROCEDURE v2_update_financial_report (
    p_financial_report_rec        IN     HZ_ORG_INFO_PUB.FINANCIAL_REPORTS_REC_TYPE,
    p_last_update_date            IN OUT  NOCOPY DATE,
    x_return_status               IN OUT  NOCOPY VARCHAR2
) IS

    l_financial_report_rec        HZ_ORGANIZATION_INFO_V2PUB.FINANCIAL_REPORT_REC_TYPE;
    l_last_update_date            DATE;
    l_rowid                       ROWID := NULL;
    l_object_version_number       NUMBER;

BEGIN

    -- check required fields:
    IF p_last_update_date IS NULL OR
       p_last_update_date = FND_API.G_MISS_DATE
    THEN
       FND_MESSAGE.SET_NAME('AR', 'HZ_API_MISSING_COLUMN');
       FND_MESSAGE.SET_TOKEN('COLUMN', 'p_last_update_date');
       FND_MSG_PUB.ADD;
       RAISE FND_API.G_EXC_ERROR;
    END IF;

    -- get object_version_number
    BEGIN
        SELECT ROWID, OBJECT_VERSION_NUMBER, LAST_UPDATE_DATE
        INTO l_rowid, l_object_version_number, l_last_update_date
        FROM HZ_FINANCIAL_REPORTS
        WHERE FINANCIAL_REPORT_ID  = p_financial_report_rec.financial_report_id;

        IF TO_CHAR( p_last_update_date, 'DD-MON-YYYY HH:MI:SS') <>
           TO_CHAR( l_last_update_date, 'DD-MON-YYYY HH:MI:SS')
        THEN
            FND_MESSAGE.SET_NAME( 'AR', 'HZ_API_RECORD_CHANGED' );
            FND_MESSAGE.SET_TOKEN( 'TABLE', 'hz_financial_reports' );
            FND_MSG_PUB.ADD;
            RAISE FND_API.G_EXC_ERROR;
        END IF;
    EXCEPTION
        WHEN NO_DATA_FOUND THEN
            FND_MESSAGE.SET_NAME( 'AR', 'HZ_API_NO_RECORD' );
            FND_MESSAGE.SET_TOKEN( 'RECORD', 'financial reports' );
            FND_MESSAGE.SET_TOKEN( 'VALUE',
                NVL( TO_CHAR( p_financial_report_rec.financial_report_id ), 'null' ) );
            FND_MSG_PUB.ADD;
            RAISE FND_API.G_EXC_ERROR;
    END;

    -- pre-process v1 and v2 record.
    v2_financial_report_pre (
        'U',
        p_financial_report_rec,
        l_financial_report_rec );

    -- call V2 API.
    HZ_ORGANIZATION_INFO_V2PUB.update_financial_report (
        p_financial_report_rec              => l_financial_report_rec,
        p_object_version_number             => l_object_version_number,
        x_return_status                     => x_return_status,
        x_msg_count                         => x_msg_count,
        x_msg_data                          => x_msg_data
    );

END v2_update_financial_report;

PROCEDURE v2_financial_number_pre (
    p_create_update_flag                    IN     VARCHAR2,
    p_financial_number_rec                  IN     HZ_ORG_INFO_PUB.FINANCIAL_NUMBERS_REC_TYPE,
    x_financial_number_rec                  OUT     NOCOPY HZ_ORGANIZATION_INFO_V2PUB.FINANCIAL_NUMBER_REC_TYPE
) IS

BEGIN

        IF p_financial_number_rec.financial_number_id IS NULL THEN
            x_financial_number_rec.financial_number_id := FND_API.G_MISS_NUM;
        ELSIF p_financial_number_rec.financial_number_id <> FND_API.G_MISS_NUM THEN
            x_financial_number_rec.financial_number_id := p_financial_number_rec.financial_number_id;
        END IF;

        IF p_financial_number_rec.financial_report_id IS NULL THEN
            x_financial_number_rec.financial_report_id := FND_API.G_MISS_NUM;
        ELSIF p_financial_number_rec.financial_report_id <> FND_API.G_MISS_NUM THEN
            x_financial_number_rec.financial_report_id := p_financial_number_rec.financial_report_id;
        END IF;

        IF p_financial_number_rec.financial_number IS NULL THEN
            x_financial_number_rec.financial_number := FND_API.G_MISS_NUM;
        ELSIF p_financial_number_rec.financial_number <> FND_API.G_MISS_NUM THEN
            x_financial_number_rec.financial_number := p_financial_number_rec.financial_number;
        END IF;

        IF p_financial_number_rec.financial_number_name IS NULL THEN
            x_financial_number_rec.financial_number_name := FND_API.G_MISS_CHAR;
        ELSIF p_financial_number_rec.financial_number_name <> FND_API.G_MISS_CHAR THEN
            x_financial_number_rec.financial_number_name := p_financial_number_rec.financial_number_name;
        END IF;

        IF p_financial_number_rec.financial_units_applied IS NULL THEN
            x_financial_number_rec.financial_units_applied := FND_API.G_MISS_NUM;
        ELSIF p_financial_number_rec.financial_units_applied <> FND_API.G_MISS_NUM THEN
            x_financial_number_rec.financial_units_applied := p_financial_number_rec.financial_units_applied;
        END IF;

        IF p_financial_number_rec.financial_number_currency IS NULL THEN
            x_financial_number_rec.financial_number_currency := FND_API.G_MISS_CHAR;
        ELSIF p_financial_number_rec.financial_number_currency <> FND_API.G_MISS_CHAR THEN
            x_financial_number_rec.financial_number_currency := p_financial_number_rec.financial_number_currency;
        END IF;

        IF p_financial_number_rec.projected_actual_flag IS NULL THEN
            x_financial_number_rec.projected_actual_flag := FND_API.G_MISS_CHAR;
        ELSIF p_financial_number_rec.projected_actual_flag <> FND_API.G_MISS_CHAR THEN
            x_financial_number_rec.projected_actual_flag := p_financial_number_rec.projected_actual_flag;
        END IF;

        IF p_financial_number_rec.content_source_type IS NULL THEN
            x_financial_number_rec.content_source_type := FND_API.G_MISS_CHAR;
        ELSIF p_financial_number_rec.content_source_type <> FND_API.G_MISS_CHAR THEN
            x_financial_number_rec.content_source_type := p_financial_number_rec.content_source_type;
        END IF;

        IF p_financial_number_rec.status IS NULL THEN
            x_financial_number_rec.status := FND_API.G_MISS_CHAR;
        ELSIF p_financial_number_rec.status <> FND_API.G_MISS_CHAR THEN
            x_financial_number_rec.status := p_financial_number_rec.status;
        END IF;

        IF p_create_update_flag = 'C' THEN
            x_financial_number_rec.created_by_module := DEFAULT_CREATED_BY_MODULE;
        END IF;

END v2_financial_number_pre;

--------------------------------------------------
-- public procedures and functions
--------------------------------------------------

PROCEDURE v2_create_financial_number (
    p_financial_number_rec        IN     HZ_ORG_INFO_PUB.FINANCIAL_NUMBERS_REC_TYPE,
    x_return_status               IN OUT  NOCOPY VARCHAR2,
    x_financial_number_id            OUT  NOCOPY NUMBER
) IS

    l_financial_number_rec         HZ_ORGANIZATION_INFO_V2PUB.FINANCIAL_NUMBER_REC_TYPE;

BEGIN

    -- pre-process v1 and v2 record.
    v2_financial_number_pre (
        'C',
        p_financial_number_rec,
        l_financial_number_rec );

    -- call V2 API.
    HZ_ORGANIZATION_INFO_V2PUB.create_financial_number (
        p_financial_number_rec             => l_financial_number_rec,
        x_financial_number_id              => x_financial_number_id,
        x_return_status                    => x_return_status,
        x_msg_count                        => x_msg_count,
        x_msg_data                         => x_msg_data );

END v2_create_financial_number;


PROCEDURE v2_update_financial_number (
    p_financial_number_rec        IN     HZ_ORG_INFO_PUB.FINANCIAL_NUMBERS_REC_TYPE,
    p_last_update_date            IN OUT  NOCOPY DATE,
    x_return_status               IN OUT  NOCOPY VARCHAR2
) IS

    l_financial_number_rec        HZ_ORGANIZATION_INFO_V2PUB.FINANCIAL_NUMBER_REC_TYPE;
    l_last_update_date            DATE;
    l_rowid                       ROWID := NULL;
    l_object_version_number       NUMBER;

BEGIN

    -- check required fields:
    IF p_last_update_date IS NULL OR
       p_last_update_date = FND_API.G_MISS_DATE
    THEN
       FND_MESSAGE.SET_NAME('AR', 'HZ_API_MISSING_COLUMN');
       FND_MESSAGE.SET_TOKEN('COLUMN', 'p_last_update_date');
       FND_MSG_PUB.ADD;
       RAISE FND_API.G_EXC_ERROR;
    END IF;

    -- get object_version_number
    BEGIN
        SELECT ROWID, OBJECT_VERSION_NUMBER, LAST_UPDATE_DATE
        INTO l_rowid, l_object_version_number, l_last_update_date
        FROM HZ_FINANCIAL_NUMBERS
        WHERE FINANCIAL_NUMBER_ID  = p_financial_number_rec.financial_number_id;

        IF TO_CHAR( p_last_update_date, 'DD-MON-YYYY HH:MI:SS') <>
           TO_CHAR( l_last_update_date, 'DD-MON-YYYY HH:MI:SS')
        THEN
            FND_MESSAGE.SET_NAME( 'AR', 'HZ_API_RECORD_CHANGED' );
            FND_MESSAGE.SET_TOKEN( 'TABLE', 'hz_financial_numbers' );
            FND_MSG_PUB.ADD;
            RAISE FND_API.G_EXC_ERROR;
        END IF;
    EXCEPTION
        WHEN NO_DATA_FOUND THEN
            FND_MESSAGE.SET_NAME( 'AR', 'HZ_API_NO_RECORD' );
            FND_MESSAGE.SET_TOKEN( 'RECORD', 'financial numbers' );
            FND_MESSAGE.SET_TOKEN( 'VALUE',
                NVL( TO_CHAR( p_financial_number_rec.financial_number_id ), 'null' ) );
            FND_MSG_PUB.ADD;
            RAISE FND_API.G_EXC_ERROR;
    END;

    -- pre-process v1 and v2 record.
    v2_financial_number_pre (
        'U',
        p_financial_number_rec,
        l_financial_number_rec );

    -- call V2 API.
    HZ_ORGANIZATION_INFO_V2PUB.update_financial_number (
        p_financial_number_rec              => l_financial_number_rec,
        p_object_version_number             => l_object_version_number,
        x_return_status                     => x_return_status,
        x_msg_count                         => x_msg_count,
        x_msg_data                          => x_msg_data
    );

END v2_update_financial_number;

END HZ_ORGANIZATION_INFO_V2PVT;

/
