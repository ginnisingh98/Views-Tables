--------------------------------------------------------
--  DDL for Package Body HZ_ORGANIZATION_INFO_V2PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."HZ_ORGANIZATION_INFO_V2PUB" AS
/* $Header: ARH2OISB.pls 120.16 2005/12/07 19:30:45 acng noship $ */

--------------------------------------
-- declaration of private global varibles
--------------------------------------

--G_DEBUG             BOOLEAN := FALSE;
G_MISS_CONTENT_SOURCE_TYPE               VARCHAR2(30) := 'USER_ENTERED';
g_fin_mixnmatch_enabled                  VARCHAR2(1);
g_fin_selected_datasources               VARCHAR2(255);
g_fin_is_datasource_selected             VARCHAR2(1) := 'N';
g_fin_entity_attr_id                     NUMBER;

--------------------------------------
-- declaration of private procedures and functions
--------------------------------------

/*PROCEDURE enable_debug;

PROCEDURE disable_debug;
*/

PROCEDURE do_create_financial_report(
    p_financial_report_rec              IN OUT  NOCOPY FINANCIAL_REPORT_REC_TYPE,
    x_financial_report_id               OUT NOCOPY     NUMBER,
    x_return_status                     IN OUT NOCOPY  VARCHAR2
);

PROCEDURE do_update_financial_report(
    p_financial_report_rec              IN OUT  NOCOPY FINANCIAL_REPORT_REC_TYPE,
    p_object_version_number             IN OUT NOCOPY  NUMBER,
    x_return_status                     IN OUT NOCOPY  VARCHAR2
);

PROCEDURE do_create_financial_number(
    p_financial_number_rec              IN OUT  NOCOPY FINANCIAL_NUMBER_REC_TYPE,
    x_financial_number_id               OUT NOCOPY     NUMBER,
    x_return_status                     IN OUT NOCOPY  VARCHAR2
);

PROCEDURE do_update_financial_number(
    p_financial_number_rec              IN OUT  NOCOPY FINANCIAL_NUMBER_REC_TYPE,
    p_object_version_number             IN OUT NOCOPY  NUMBER,
    x_return_status                     IN OUT NOCOPY  VARCHAR2
);

--------------------------------------
-- private procedures and functions
--------------------------------------

/**
 * PRIVATE PROCEDURE enable_debug
 *
 * DESCRIPTION
 *     Turn on debug mode.
 *
 * EXTERNAL PROCEDURES/FUNCTIONS ACCESSED
 *     HZ_UTILITY_V2PUB.enable_debug
 *
 * MODIFICATION HISTORY
 *
 *   23-JAN-2003    Sreedhar Mohan      o Created.
 *
 */

/*PROCEDURE enable_debug IS

BEGIN

    IF FND_PROFILE.value( 'HZ_API_FILE_DEBUG_ON' ) = 'Y' OR
       FND_PROFILE.value( 'HZ_API_DBMS_DEBUG_ON' ) = 'Y'
    THEN
        HZ_UTILITY_V2PUB.enable_debug;
        G_DEBUG := TRUE;
    END IF;

END enable_debug;
*/

/**
 * PRIVATE PROCEDURE disable_debug
 *
 * DESCRIPTION
 *     Turn off debug mode.
 *
 * EXTERNAL PROCEDURES/FUNCTIONS ACCESSED
 *     HZ_UTILITY_V2PUB.disable_debug
 *
 * MODIFICATION HISTORY
 *
 *   23-JAN-2003    Sreedhar Mohan      o Created.
 *
 */

/*PROCEDURE disable_debug IS

BEGIN

    IF G_DEBUG THEN
        HZ_UTILITY_V2PUB.disable_debug;
        G_DEBUG := FALSE;
    END IF;

END disable_debug;
*/

/**
 * PROCEDURE do_create_financial_report
 *
 * DESCRIPTION
 *     Creates financial report.
 *
 * SCOPE - PRIVATE
 *
 * EXTERNAL PROCEDURES/FUNCTIONS ACCESSED
 *
 * ARGUMENTS
 *   IN:
 *     p_financial_report_rec         Financial report record.
 *
 *   IN/OUT:
 *   OUT:
 *     x_financial_report_id          Financial report Id.
 *     x_return_status                Return status after the call. The status can
 *                                    be FND_API.G_RET_STS_SUCCESS (success),
 *                                    FND_API.G_RET_STS_ERROR (error),
 *                                    FND_API.G_RET_STS_UNEXP_ERROR (unexpected error).
 *
 * NOTES
 *
 * MODIFICATION HISTORY
 *
 *   23-JAN-2003    Sreedhar Mohan        o Created.
 *
 */

PROCEDURE do_create_financial_report(
    p_financial_report_rec              IN OUT  NOCOPY FINANCIAL_REPORT_REC_TYPE,
    x_financial_report_id               OUT NOCOPY     NUMBER,
    x_return_status                     IN OUT NOCOPY  VARCHAR2
) IS

    l_dummy                             VARCHAR2(1);
    l_rowid                             ROWID;

BEGIN

    -- validate Financial report  record
    HZ_REGISTRY_VALIDATE_V2PUB.validate_financial_report(
        'C',
        p_financial_report_rec,
        l_rowid,
        x_return_status);

    IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
        RAISE FND_API.G_EXC_ERROR;
    END IF;

    --Bug 2490399: Added final_ind in financial_report_rec_type. Hence passing
    --the final_ind value instead of fnd_api.g_miss_char.
    -- call table handler to insert a row
    HZ_FINANCIAL_REPORTS_PKG.Insert_Row (
        x_ROWID                                 => l_rowid,
        x_FINANCIAL_REPORT_ID                   => p_financial_report_rec.financial_report_id,
        x_DATE_REPORT_ISSUED                    => p_financial_report_rec.date_report_issued,
        x_PARTY_ID                              => p_financial_report_rec.party_id,
        x_DOCUMENT_REFERENCE                    => p_financial_report_rec.document_reference,
        x_ISSUED_PERIOD                         => p_financial_report_rec.issued_period,
        x_REQUIRING_AUTHORITY                   => p_financial_report_rec.requiring_authority,
        x_TYPE_OF_FINANCIAL_REPORT              => p_financial_report_rec.type_of_financial_report,
        x_REPORT_START_DATE                     => p_financial_report_rec.report_start_date,
        x_REPORT_END_DATE                       => p_financial_report_rec.report_end_date,
        x_AUDIT_IND                             => p_financial_report_rec.audit_ind,
        x_CONSOLIDATED_IND                      => p_financial_report_rec.consolidated_ind,
        x_ESTIMATED_IND                         => p_financial_report_rec.estimated_ind,
        x_FISCAL_IND                            => p_financial_report_rec.fiscal_ind,
        x_FINAL_IND                             => p_financial_report_rec.final_ind,
        x_FORECAST_IND                          => p_financial_report_rec.forecast_ind,
        x_OPENING_IND                           => p_financial_report_rec.opening_ind,
        x_PROFORMA_IND                          => p_financial_report_rec.proforma_ind,
        x_QUALIFIED_IND                         => p_financial_report_rec.qualified_ind,
        x_RESTATED_IND                          => p_financial_report_rec.restated_ind,
        x_SIGNED_BY_PRINCIPALS_IND              => p_financial_report_rec.signed_by_principals_ind,
        x_TRIAL_BALANCE_IND                     => p_financial_report_rec.trial_balance_ind,
        x_UNBALANCED_IND                        => p_financial_report_rec.unbalanced_ind,
        x_CONTENT_SOURCE_TYPE                   => G_MISS_CONTENT_SOURCE_TYPE,
        x_STATUS                                => p_financial_report_rec.status,
        x_OBJECT_VERSION_NUMBER                 => 1,
        x_CREATED_BY_MODULE                     => p_financial_report_rec.created_by_module,
        x_ACTUAL_CONTENT_SOURCE                 => p_financial_report_rec.actual_content_source
    );

    x_financial_report_id := p_financial_report_rec.financial_report_id;

END do_create_financial_report;

PROCEDURE do_update_financial_report(
    p_financial_report_rec              IN OUT  NOCOPY FINANCIAL_REPORT_REC_TYPE,
    p_object_version_number             IN OUT NOCOPY  NUMBER,
    x_return_status                     IN OUT NOCOPY  VARCHAR2
) IS

    l_rowid                                     ROWID  := NULL;
    l_object_version_number                     NUMBER;
    l_party_id                                  NUMBER;
--  Bug 4693719 : Added for local assignment
    l_acs HZ_FINANCIAL_REPORTS.actual_content_source%TYPE;
    db_actual_content_source HZ_FINANCIAL_REPORTS.actual_content_source%TYPE;

BEGIN

    -- check whether record has been updated by another user
    BEGIN
        -- check object_version_number
        --  Bug 4693719 : add ACS in select
        SELECT rowid, object_version_number, party_id, actual_content_source
        INTO l_rowid, l_object_version_number, l_party_id, db_actual_content_source
        FROM HZ_FINANCIAL_REPORTS
        WHERE financial_report_id = p_financial_report_rec.financial_report_id
        FOR UPDATE NOWAIT;

        IF NOT
             (
              ( p_object_version_number IS NULL AND l_object_version_number IS NULL )
              OR
              ( p_object_version_number IS NOT NULL AND
                l_object_version_number IS NOT NULL AND
                p_object_version_number = l_object_version_number
              )
             )
        THEN
            FND_MESSAGE.SET_NAME('AR', 'HZ_API_RECORD_CHANGED');
            FND_MESSAGE.SET_TOKEN('TABLE', 'HZ_FINANCIAL_REPORTS');
            FND_MSG_PUB.ADD;
            RAISE FND_API.G_EXC_ERROR;
        END IF;

        p_object_version_number := nvl(l_object_version_number, 1) + 1;

    EXCEPTION
        WHEN NO_DATA_FOUND THEN
            FND_MESSAGE.SET_NAME('AR', 'HZ_API_NO_RECORD');
            FND_MESSAGE.SET_TOKEN('RECORD', 'HZ_FINANCIAL_REPORTS');
            FND_MESSAGE.SET_TOKEN('VALUE', NVL( TO_CHAR( p_financial_report_rec.financial_report_id ), 'null' ) );
            FND_MSG_PUB.ADD;
            RAISE FND_API.G_EXC_ERROR;
    END;

    -- validate financial report record
    HZ_REGISTRY_VALIDATE_V2PUB.validate_financial_report(
        'U',
        p_financial_report_rec,
        l_rowid,
        x_return_status);

    IF x_return_status = FND_API.G_RET_STS_ERROR THEN
        RAISE FND_API.G_EXC_ERROR;
    END IF;

    --  Bug 4693719 : pass NULL if the secure data is not updated
   IF HZ_UTILITY_V2PUB.G_UPDATE_ACS = 'Y' THEN
       l_acs := nvl(p_financial_report_rec.actual_content_source, 'USER_ENTERED');
   ELSE
       l_acs := NULL;
   END IF;


    --Bug 2490399: Added final_ind in financial_report_rec_type. Hence passing
    --the final_ind value instead of fnd_api.g_miss_char.
    -- call table handler to update a row
    HZ_FINANCIAL_REPORTS_PKG.Update_Row (
        x_ROWID                                 => l_rowid,
        x_FINANCIAL_REPORT_ID                   => p_financial_report_rec.financial_report_id,
        x_DATE_REPORT_ISSUED                    => p_financial_report_rec.date_report_issued,
        x_PARTY_ID                              => p_financial_report_rec.party_id,
        x_DOCUMENT_REFERENCE                    => p_financial_report_rec.document_reference,
        x_ISSUED_PERIOD                         => p_financial_report_rec.issued_period,
        x_REQUIRING_AUTHORITY                   => p_financial_report_rec.requiring_authority,
        x_TYPE_OF_FINANCIAL_REPORT              => p_financial_report_rec.type_of_financial_report,
        x_REPORT_START_DATE                     => p_financial_report_rec.report_start_date,
        x_REPORT_END_DATE                       => p_financial_report_rec.report_end_date,
        x_AUDIT_IND                             => p_financial_report_rec.audit_ind,
        x_CONSOLIDATED_IND                      => p_financial_report_rec.consolidated_ind,
        x_ESTIMATED_IND                         => p_financial_report_rec.estimated_ind,
        x_FISCAL_IND                            => p_financial_report_rec.fiscal_ind,
        x_FINAL_IND                             => p_financial_report_rec.final_ind,
        x_FORECAST_IND                          => p_financial_report_rec.forecast_ind,
        x_OPENING_IND                           => p_financial_report_rec.opening_ind,
        x_PROFORMA_IND                          => p_financial_report_rec.proforma_ind,
        x_QUALIFIED_IND                         => p_financial_report_rec.qualified_ind,
        x_RESTATED_IND                          => p_financial_report_rec.restated_ind,
        x_SIGNED_BY_PRINCIPALS_IND              => p_financial_report_rec.signed_by_principals_ind,
        x_TRIAL_BALANCE_IND                     => p_financial_report_rec.trial_balance_ind,
        x_UNBALANCED_IND                        => p_financial_report_rec.unbalanced_ind,
        x_CONTENT_SOURCE_TYPE                   => G_MISS_CONTENT_SOURCE_TYPE,
        x_STATUS                                => p_financial_report_rec.status,
        x_OBJECT_VERSION_NUMBER                 => p_object_version_number,
        x_CREATED_BY_MODULE                     => p_financial_report_rec.created_by_module,
   --  Bug 4693719 : Pass correct value for ACS
        x_ACTUAL_CONTENT_SOURCE                 => l_acs
    );

END do_update_financial_report;

/**
 * PROCEDURE do_create_financial_number
 *
 * DESCRIPTION
 *     Creates financial_number.
 *
 * SCOPE - PRIVATE
 *
 * EXTERNAL PROCEDURES/FUNCTIONS ACCESSED
 *
 * ARGUMENTS
 *   IN:
 *     p_financial_number_rec         Financial Number record.
 *
 *   IN/OUT:
 *   OUT:
 *     x_financial_number_id          Financial Number Id.
 *     x_return_status                Return status after the call. The status can
 *                                    be FND_API.G_RET_STS_SUCCESS (success),
 *                                    FND_API.G_RET_STS_ERROR (error),
 *                                    FND_API.G_RET_STS_UNEXP_ERROR (unexpected error).
 *
 * NOTES
 *
 * MODIFICATION HISTORY
 *
 *   23-JAN-2003    Sreedhar Mohan        o Created.
 *   22-MAR-2005    Rajib Ranjan Borah    o Bug 4225452. Added check for user creation privilege.
 *
 */

PROCEDURE do_create_financial_number(
    p_financial_number_rec              IN OUT  NOCOPY FINANCIAL_NUMBER_REC_TYPE,
    x_financial_number_id               OUT NOCOPY     NUMBER,
    x_return_status                     IN OUT NOCOPY  VARCHAR2
) IS

    l_dummy                             VARCHAR2(1);
    l_rowid                             ROWID;
    l_acual_content_source              HZ_FINANCIAL_NUMBERS.actual_content_source%TYPE;

BEGIN

    -- validate financial number  record
    HZ_REGISTRY_VALIDATE_V2PUB.validate_financial_number(
        'C',
        p_financial_number_rec,
        l_rowid,
        x_return_status,
 --bug 3942332 :added parameter l_acual_content_source
	l_acual_content_source);
    IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
        RAISE FND_API.G_EXC_ERROR;
    END IF;

    -- Bug 4225452.
    IF l_acual_content_source = G_MISS_CONTENT_SOURCE_TYPE THEN
        HZ_MIXNM_UTILITY.CheckUserCreationPrivilege (
            p_entity_name                    => 'HZ_FINANCIAL_REPORTS',
            p_entity_attr_id                 => g_fin_entity_attr_id,
            p_mixnmatch_enabled              => g_fin_mixnmatch_enabled,
            p_actual_content_source          => l_acual_content_source,
            x_return_status                  => x_return_status );

	IF x_return_status = FND_API.G_RET_STS_ERROR then
	    raise fnd_api.g_exc_error;
	END IF;
    END IF;

    -- call table handler to insert a row
    HZ_FINANCIAL_NUMBERS_PKG.Insert_Row (
         x_rowid                                  => l_rowid,
         x_financial_number_id                    => p_financial_number_rec.financial_number_id,
         x_financial_report_id                    => p_financial_number_rec.financial_report_id,
         x_financial_number                       => p_financial_number_rec.financial_number,
         x_financial_number_name                  => p_financial_number_rec.financial_number_name,
         x_financial_units_applied                => p_financial_number_rec.financial_units_applied,
         x_financial_number_currency              => p_financial_number_rec.financial_number_currency,
         x_projected_actual_flag                  => p_financial_number_rec.projected_actual_flag,
         x_content_source_type                    => p_financial_number_rec.content_source_type,
         x_status                                 => p_financial_number_rec.status,
         x_object_version_number                  => 1,
         x_created_by_module                      => p_financial_number_rec.created_by_module,
         x_actual_content_source                  => l_acual_content_source

    );
    x_financial_number_id := p_financial_number_rec.financial_number_id;
END do_create_financial_number;

/**
 * PROCEDURE do_update_financial_number
 *
 * DESCRIPTION
 *     Creates financial_number.
 *
 * SCOPE - PRIVATE
 *
 * EXTERNAL PROCEDURES/FUNCTIONS ACCESSED
 *
 * ARGUMENTS
 *   IN:
 *     p_financial_number_rec         Financial Number record.
 *
 *   IN/OUT:
 *   OUT:
 *     p_object_version_number        Used for locking the being updated record.
 *     x_return_status                Return status after the call. The status can
 *                                    be FND_API.G_RET_STS_SUCCESS (success),
 *                                    FND_API.G_RET_STS_ERROR (error),
 *                                    FND_API.G_RET_STS_UNEXP_ERROR (unexpected error).
 *
 * NOTES
 *
 * MODIFICATION HISTORY
 *
 *   23-JAN-2003    Sreedhar Mohan        o Created.
 *   04-JAN-2005    Rajib Ranjan Borah    o SSM SST Integration and Extension.
 *                                          For non-profile entities, the concept of
 *                                          select/de-select data-sources is obsoleted.
 *   22-MAR-2005    Rajib Ranjan Borah    o Bug 4225452. The user creation rules for
 *                                          credit ratings were wrongly checked.
 */

PROCEDURE do_update_financial_number(
    p_financial_number_rec                  IN OUT  NOCOPY FINANCIAL_NUMBER_REC_TYPE,
    p_object_version_number             IN OUT NOCOPY  NUMBER,
    x_return_status                     IN OUT NOCOPY  VARCHAR2
) IS

    l_rowid                                     ROWID  := NULL;
    l_object_version_number                     NUMBER;
    l_acual_content_source                      HZ_FINANCIAL_NUMBERS.actual_content_source%TYPE;
    g_cre_mixnmatch_enabled                     VARCHAR2(1);
    g_cre_selected_datasources                  VARCHAR2(255);
    g_cre_is_datasource_selected                VARCHAR2(1) := 'N';
    g_cre_entity_attr_id                        NUMBER;

BEGIN

    -- check whether record has been updated by another user
    BEGIN
        -- check object_version_number
        SELECT rowid, object_version_number
        INTO l_rowid, l_object_version_number
	FROM HZ_financial_numbers
        WHERE financial_number_id = p_financial_number_rec.financial_number_id
        FOR UPDATE NOWAIT;

        IF NOT
             (
              ( p_object_version_number IS NULL AND l_object_version_number IS NULL )
              OR
              ( p_object_version_number IS NOT NULL AND
                l_object_version_number IS NOT NULL AND
                p_object_version_number = l_object_version_number
              )
             )
        THEN
            FND_MESSAGE.SET_NAME('AR', 'HZ_API_RECORD_CHANGED');
            FND_MESSAGE.SET_TOKEN('TABLE', 'HZ_FINANCIAL_NUMBERS');
            FND_MSG_PUB.ADD;
            RAISE FND_API.G_EXC_ERROR;
        END IF;

        p_object_version_number := nvl(l_object_version_number, 1) + 1;

    EXCEPTION
        WHEN NO_DATA_FOUND THEN
            FND_MESSAGE.SET_NAME('AR', 'HZ_API_NO_RECORD');
            FND_MESSAGE.SET_TOKEN('RECORD', 'HZ_FINANCIAL_NUMBERS');
            FND_MESSAGE.SET_TOKEN('VALUE', NVL( TO_CHAR( p_financial_number_rec.financial_number_id ), 'null' ) );
            FND_MSG_PUB.ADD;
            RAISE FND_API.G_EXC_ERROR;
    END;

    -- validate financial number record
    HZ_REGISTRY_VALIDATE_V2PUB.validate_financial_number(
        'U',
        p_financial_number_rec,
        l_rowid,
        x_return_status,
	--bug 3942332: added parameter to function call
	l_acual_content_source);

    IF x_return_status = FND_API.G_RET_STS_ERROR THEN
        RAISE FND_API.G_EXC_ERROR;
    END IF;

/* SSM SST Integration and Extension
 * For non-profile entities, the concept of select/de-select data-sources is obsoleted.

    HZ_MIXNM_UTILITY.LoadDataSources(
      p_entity_name                    => 'HZ_CREDIT_RATINGS',
      p_entity_attr_id                 => g_cre_entity_attr_id,
      p_mixnmatch_enabled              => g_cre_mixnmatch_enabled,
      p_selected_datasources           => g_cre_selected_datasources );
*/

    -- Bug 4225452
    /*
    HZ_MIXNM_UTILITY.AssignDataSourceDuringCreation (
      p_entity_name                    => 'HZ_CREDIT_RATINGS',
      p_entity_attr_id                 => g_cre_entity_attr_id,
      p_mixnmatch_enabled              => g_cre_mixnmatch_enabled,
      p_selected_datasources           => g_cre_selected_datasources,
      p_content_source_type            => p_financial_number_rec.content_source_type,
      p_actual_content_source          => l_acual_content_source,
      x_is_datasource_selected         => g_cre_is_datasource_selected,
      x_return_status                  => x_return_status,
      p_api_version                    => 'V2');
    */

    -- call table handler to update a row
    HZ_FINANCIAL_NUMBERS_PKG.Update_Row (
         x_rowid                                  => l_rowid,
         x_financial_number_id                    => p_financial_number_rec.financial_number_id,
         x_financial_report_id                    => p_financial_number_rec.financial_report_id,
         x_financial_number                       => p_financial_number_rec.financial_number,
         x_financial_number_name                  => p_financial_number_rec.financial_number_name,
         x_financial_units_applied                => p_financial_number_rec.financial_units_applied,
         x_financial_number_currency              => p_financial_number_rec.financial_number_currency,
         x_projected_actual_flag                  => p_financial_number_rec.projected_actual_flag,
         x_content_source_type                    => p_financial_number_rec.content_source_type,
         x_status                                 => p_financial_number_rec.status,
         x_object_version_number                  => p_object_version_number,
         x_created_by_module                      => p_financial_number_rec.created_by_module,
--bug 3942332: actual_content_source is a non-updateable column
         --x_actual_content_source                  => l_acual_content_source
         x_actual_content_source                  => null

    );

END do_update_financial_number;

--------------------------------------
-- public procedures and functions
--------------------------------------

/**
 * PROCEDURE create_financial_report
 *
 * DESCRIPTION
 *     Creates financial_report.
 *
 * EXTERNAL PROCEDURES/FUNCTIONS ACCESSED
 *     HZ_BUSINESS_EVENT_V2PVT.create_fin_reports_event
 *
 * ARGUMENTS
 *   IN:
 *     p_init_msg_list                Initialize message stack if it is set to
 *                                    FND_API.G_TRUE. Default is FND_API.G_FALSE.
 *     p_financial_report_rec         financial_report record.
 *   IN/OUT:
 *   OUT:
 *     x_financial_report_id          financial_report Id.
 *     x_return_status                Return status after the call. The status can
 *                                    be FND_API.G_RET_STS_SUCCESS (success),
 *                                    FND_API.G_RET_STS_ERROR (error),
 *                                    FND_API.G_RET_STS_UNEXP_ERROR (unexpected error).
 *     x_msg_count                    Number of messages in message stack.
 *     x_msg_data                     Message text if x_msg_count is 1.
 *
 * NOTES
 *
 * MODIFICATION HISTORY
 *
 *   23-JAN-2003    Sreedhar Mohan        o Created.
 *   04-JAN-2005    Rajib Ranjan Borah    o SSM SST Integration and Extension.
 *                                          For non-profile entities, the concept of
 *                                          select/de-select data-sources is obsoleted.
 *
 */

PROCEDURE create_financial_report(
    p_init_msg_list            IN  VARCHAR2 := FND_API.G_FALSE,
    p_financial_report_rec     IN  FINANCIAL_REPORT_REC_TYPE,
    x_financial_report_id      OUT NOCOPY NUMBER,
    x_return_status            OUT NOCOPY VARCHAR2,
    x_msg_count                OUT NOCOPY NUMBER,
    x_msg_data                 OUT NOCOPY VARCHAR2
) IS

    l_api_name                 CONSTANT       VARCHAR2(30) := 'create_financial_report';
    l_financial_report_rec     FINANCIAL_REPORT_REC_TYPE := p_financial_report_rec;

BEGIN

    --Standard start of API savepoint
    SAVEPOINT create_financial_report;

    --Initialize message list if p_init_msg_list is set to TRUE.
    IF FND_API.to_Boolean(p_init_msg_list) THEN
        FND_MSG_PUB.initialize;
    END IF;

    --Initialize API return status to success.
    x_return_status := FND_API.G_RET_STS_SUCCESS;

    -- Bug 2868913: First load data
    -- sources for this entity. Then assign the actual_content_source
    -- to the real data source. The value of content_source_type is
    -- depended on if data source is seleted. If it is selected, we reset
    -- content_source_type to user-entered.

/* SSM SST Integration and Extension
   For non-profile entities, the concept of select/de-select data-sources is obsoleted.

    HZ_MIXNM_UTILITY.LoadDataSources(
      p_entity_name                    => 'HZ_FINANCIAL_REPORTS',
      p_entity_attr_id                 => g_fin_entity_attr_id,
      p_mixnmatch_enabled              => g_fin_mixnmatch_enabled,
      p_selected_datasources           => g_fin_selected_datasources );
*/
    HZ_MIXNM_UTILITY.AssignDataSourceDuringCreation (
      p_entity_name                    => 'HZ_FINANCIAL_REPORTS',
      p_entity_attr_id                 => g_fin_entity_attr_id,
      p_mixnmatch_enabled              => g_fin_mixnmatch_enabled,
      p_selected_datasources           => g_fin_selected_datasources,
      p_content_source_type            => g_miss_content_source_type,
      p_actual_content_source          => l_financial_report_rec.actual_content_source,
      x_is_datasource_selected         => g_fin_is_datasource_selected,
      x_return_status                  => x_return_status,
      p_api_version                    => 'V2');

    IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
      RAISE FND_API.G_EXC_ERROR;
    END IF;

    -- Call to business logic.
    HZ_ORGANIZATION_INFO_V2PUB.do_create_financial_report(
        l_financial_report_rec,
        x_financial_report_id,
        x_return_status);

    -- Bug 2868913: Added one more condition, g_fin_is_datasource_selected = Y, before calling business event

    -- SSM SST Integration and Extension
    -- For non-profile entities, the concept of select/de-select data-sources is obsoleted.
    -- There is no need to check if the data-source is selected.

    IF x_return_status = FND_API.G_RET_STS_SUCCESS /*AND
       g_fin_is_datasource_selected = 'Y' */
    THEN
      IF(HZ_UTILITY_V2PUB.G_EXECUTE_API_CALLOUTS in ('Y', 'EVENTS_ENABLED')) THEN
        -- Invoke business event system.
        HZ_BUSINESS_EVENT_V2PVT.create_fin_reports_event (
          l_financial_report_rec );
      END IF;

      IF(HZ_UTILITY_V2PUB.G_EXECUTE_API_CALLOUTS in ('EVENTS_ENABLED', 'BO_EVENTS_ENABLED')) THEN
        HZ_POPULATE_BOT_PKG.pop_hz_financial_reports(
          p_operation           => 'I',
          p_financial_report_id => x_financial_report_id);
      END IF;
    END IF;

    --Standard call to get message count and if count is 1, get message info.
    FND_MSG_PUB.Count_And_Get(
        p_encoded => FND_API.G_FALSE,
        p_count => x_msg_count,
        p_data  => x_msg_data);

EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN
        ROLLBACK TO create_financial_report;
        x_return_status := FND_API.G_RET_STS_ERROR;
        FND_MSG_PUB.Count_And_Get(
            p_encoded => FND_API.G_FALSE,
            p_count => x_msg_count,
            p_data  => x_msg_data);

    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
        ROLLBACK TO create_financial_report;
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        FND_MSG_PUB.Count_And_Get(
            p_encoded => FND_API.G_FALSE,
            p_count => x_msg_count,
            p_data  => x_msg_data);

    WHEN OTHERS THEN
        ROLLBACK TO create_financial_report;
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        FND_MESSAGE.SET_NAME('AR', 'HZ_API_OTHERS_EXCEP');
        FND_MESSAGE.SET_TOKEN('ERROR' ,SQLERRM);
        FND_MSG_PUB.ADD;
        FND_MSG_PUB.Count_And_Get(
            p_encoded => FND_API.G_FALSE,
            p_count => x_msg_count,
            p_data  => x_msg_data);

END create_financial_report;

/**
 * PROCEDURE update_financial_report
 *
 * DESCRIPTION
 *     Updates Financial Report.
 *
 * EXTERNAL PROCEDURES/FUNCTIONS ACCESSED
 *     HZ_BUSINESS_EVENT_V2PVT.update_fin_reports_event
 *
 * ARGUMENTS
 *   IN:
 *     p_init_msg_list                Initialize message stack if it is set to
 *                                    FND_API.G_TRUE. Default is FND_API.G_FALSE.
 *     p_financial_report_rec         Financial report record.
 *   IN/OUT:
 *     p_object_version_number        Used for locking the being updated record.
 *   OUT:
 *     x_return_status                Return status after the call. The status can
 *                                    be FND_API.G_RET_STS_SUCCESS (success),
 *                                    FND_API.G_RET_STS_ERROR (error),
 *                                    FND_API.G_RET_STS_UNEXP_ERROR (unexpected error).
 *     x_msg_count                    Number of messages in message stack.
 *     x_msg_data                     Message text if x_msg_count is 1.
 *
 * NOTES
 *
 * MODIFICATION HISTORY
 *
 *   23-JAN-2003    Sreedhar Mohan        o Created.
 *   04-JAN-2005    Rajib Ranjan Borah    o SSM SST Integration and Extension.
 *                                          For non-profile entities, the concept of
 *                                          select/de-select data-sources is obsoleted.
 *
 */

PROCEDURE update_financial_report(
    p_init_msg_list          IN     VARCHAR2 := FND_API.G_FALSE,
    p_financial_report_rec   IN     FINANCIAL_REPORT_REC_TYPE,
    p_object_version_number  IN OUT NOCOPY NUMBER,
    x_return_status             OUT NOCOPY VARCHAR2,
    x_msg_count                 OUT NOCOPY NUMBER,
    x_msg_data                  OUT NOCOPY VARCHAR2
) IS

    l_api_name                       CONSTANT       VARCHAR2(30) := 'update_financial_report';
    l_financial_report_rec                          FINANCIAL_REPORT_REC_TYPE := p_financial_report_rec;
    l_old_fin_report_rec                            FINANCIAL_REPORT_REC_TYPE;

BEGIN

    --Standard start of API savepoint
    SAVEPOINT update_financial_report;

    --Initialize message list if p_init_msg_list is set to TRUE.
    IF FND_API.to_Boolean(p_init_msg_list) THEN
        FND_MSG_PUB.initialize;
    END IF;

    --Initialize API return status to success.
    x_return_status := FND_API.G_RET_STS_SUCCESS;

   HZ_ORGANIZATION_INFO_V2PUB.get_financial_report_rec (
     p_financial_report_id        => p_financial_report_rec.financial_report_id,
     p_financial_report_rec       => l_old_fin_report_rec,
     x_return_status              => x_return_status,
     x_msg_count                  => x_msg_count,
     x_msg_data                   => x_msg_data);


    IF x_return_status = FND_API.G_RET_STS_ERROR THEN
        RAISE FND_API.G_EXC_ERROR;
    ELSIF x_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;

    -- Bug 2868913: default the actual_content_source through mixnm API
/* SSM SST Integration and Extension
 * For non-profile entities, the concept of select/de-select data-sources is obsoleted.
 * There is no need to check if the data-source is selected.

    HZ_MIXNM_UTILITY.LoadDataSources(
      p_entity_name                    => 'HZ_FINANCIAL_REPORTS',
      p_entity_attr_id                 => g_fin_entity_attr_id,
      p_mixnmatch_enabled              => g_fin_mixnmatch_enabled,
      p_selected_datasources           => g_fin_selected_datasources );

    g_fin_is_datasource_selected :=
      HZ_MIXNM_UTILITY.isDataSourceSelected (
        p_selected_datasources           => g_fin_selected_datasources,
        p_actual_content_source          => l_old_fin_report_rec.actual_content_source );
*/
    -- Call to business logic.
    do_update_financial_report(
        l_financial_report_rec,
        p_object_version_number,
        x_return_status);

    -- Bug 2868913: Added one more condition, g_fin_is_datasource_selected = Y, before calling business event

    -- SSM SST Integration and Extension
    -- For non-profile entities, the concept of select/de-select data-sources is obsoleted.
    -- There is no need to check if the data-source is selected.
    IF x_return_status = FND_API.G_RET_STS_SUCCESS /*AND
       g_fin_is_datasource_selected = 'Y'*/
    THEN
      --Bug 2979651: Since 2907261 made to HZ.K, keeping back the changes of 115.8 version.
      IF(HZ_UTILITY_V2PUB.G_EXECUTE_API_CALLOUTS in ('Y', 'EVENTS_ENABLED')) THEN
      -- Invoke business event system.
        HZ_BUSINESS_EVENT_V2PVT.update_fin_reports_event (
          l_financial_report_rec,
          l_old_fin_report_rec );
      END IF;

      IF(HZ_UTILITY_V2PUB.G_EXECUTE_API_CALLOUTS in ('EVENTS_ENABLED', 'BO_EVENTS_ENABLED')) THEN
        HZ_POPULATE_BOT_PKG.pop_hz_financial_reports(
          p_operation           => 'U',
          p_financial_report_id => l_financial_report_rec.financial_report_id);
      END IF;
    END IF;

    HZ_UTILITY_V2PUB.G_UPDATE_ACS := NULL;
    --Standard call to get message count and if count is 1, get message info.
    FND_MSG_PUB.Count_And_Get(
        p_encoded => FND_API.G_FALSE,
        p_count => x_msg_count,
        p_data  => x_msg_data);

EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN
        ROLLBACK TO update_financial_report;
        HZ_UTILITY_V2PUB.G_UPDATE_ACS := NULL;
        x_return_status := FND_API.G_RET_STS_ERROR;
        FND_MSG_PUB.Count_And_Get(
            p_encoded => FND_API.G_FALSE,
            p_count => x_msg_count,
            p_data  => x_msg_data);

    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
        ROLLBACK TO update_financial_report;
        HZ_UTILITY_V2PUB.G_UPDATE_ACS := NULL;
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        FND_MSG_PUB.Count_And_Get(
            p_encoded => FND_API.G_FALSE,
            p_count => x_msg_count,
            p_data  => x_msg_data);

    WHEN OTHERS THEN
        ROLLBACK TO update_financial_report;
        HZ_UTILITY_V2PUB.G_UPDATE_ACS := NULL;
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        FND_MESSAGE.SET_NAME('AR', 'HZ_API_OTHERS_EXCEP');
        FND_MESSAGE.SET_TOKEN('ERROR' ,SQLERRM);
        FND_MSG_PUB.ADD;
        FND_MSG_PUB.Count_And_Get(
            p_encoded => FND_API.G_FALSE,
            p_count => x_msg_count,
            p_data  => x_msg_data);

END update_financial_report;

/**
 * PROCEDURE get_financial_report_rec
 *
 * DESCRIPTION
 *     Gets financial report record.
 *
 * EXTERNAL PROCEDURES/FUNCTIONS ACCESSED
 *     HZ_FINANCIAL_REPORTS_PKG.Select_Row
 *
 * ARGUMENTS
 *   IN:
 *     p_init_msg_list                Initialize message stack if it is set to
 *                                    FND_API.G_TRUE. Default is FND_API.G_FALSE.
 *     p_financial_report_id          Financial report ID.
 *   IN/OUT:
 *   OUT:
 *     x_financial_report_rec         Returned financial report record.
 *     x_return_status                Return status after the call. The status can
 *                                    be FND_API.G_RET_STS_SUCCESS (success),
 *                                    FND_API.G_RET_STS_ERROR (error),
 *                                    FND_API.G_RET_STS_UNEXP_ERROR (unexpected error).
 *     x_msg_count                    Number of messages in message stack.
 *     x_msg_data                     Message text if x_msg_count is 1.
 *
 * NOTES
 *
 * MODIFICATION HISTORY
 *
 *   23-JAN-2003    Sreedhar Mohan        o Created.
 */

PROCEDURE get_financial_report_rec (
    p_init_msg_list                         IN     VARCHAR2 := FND_API.G_FALSE,
    p_financial_report_id                   IN     NUMBER,
    p_financial_report_rec                  OUT    NOCOPY FINANCIAL_REPORT_REC_TYPE,
    x_return_status                         OUT NOCOPY    VARCHAR2,
    x_msg_count                             OUT NOCOPY    NUMBER,
    x_msg_data                              OUT NOCOPY    VARCHAR2
) IS

    l_api_name                              CONSTANT VARCHAR2(30) := 'get_financial_report_rec';

BEGIN

    --Initialize message list if p_init_msg_list is set to TRUE.
    IF FND_API.to_Boolean(p_init_msg_list) THEN
        FND_MSG_PUB.initialize;
    END IF;

    --Initialize API return status to success.
    x_return_status := FND_API.G_RET_STS_SUCCESS;

    --Check whether primary key has been passed in.
    IF p_financial_report_id IS NULL OR
       p_financial_report_id = FND_API.G_MISS_NUM THEN
        FND_MESSAGE.SET_NAME( 'AR', 'HZ_API_MISSING_COLUMN' );
        FND_MESSAGE.SET_TOKEN( 'COLUMN', 'financial_report_id' );
        FND_MSG_PUB.ADD;
        RAISE FND_API.G_EXC_ERROR;
    END IF;

    -- The p_financial_report_rec.financial_report_id must be initiated to p_financial_report_id
    p_financial_report_rec.financial_report_id := p_financial_report_id;

    --Bug 2490399: Added final_ind in financial_report_rec_type. Hence changing the call to
    --select_row.
    HZ_FINANCIAL_REPORTS_PKG.Select_Row (
        x_financial_report_id                  => p_financial_report_rec.financial_report_id,
        x_date_report_issued                   => p_financial_report_rec.date_report_issued,
        x_party_id                             => p_financial_report_rec.party_id,
        x_document_reference                   => p_financial_report_rec.document_reference,
        x_issued_period                        => p_financial_report_rec.issued_period,
        x_requiring_authority                  => p_financial_report_rec.requiring_authority,
        x_type_of_financial_report             => p_financial_report_rec.type_of_financial_report,
        x_report_start_date                    => p_financial_report_rec.report_start_date,
        x_report_end_date                      => p_financial_report_rec.report_end_date,
        x_audit_ind                            => p_financial_report_rec.audit_ind,
        x_consolidated_ind                     => p_financial_report_rec.consolidated_ind,
        x_estimated_ind                        => p_financial_report_rec.estimated_ind,
        x_fiscal_ind                           => p_financial_report_rec.fiscal_ind,
        x_final_ind                            => p_financial_report_rec.final_ind,
        x_forecast_ind                         => p_financial_report_rec.forecast_ind,
        x_opening_ind                          => p_financial_report_rec.opening_ind,
        x_proforma_ind                         => p_financial_report_rec.proforma_ind,
        x_qualified_ind                        => p_financial_report_rec.qualified_ind,
        x_restated_ind                         => p_financial_report_rec.restated_ind,
        x_signed_by_principals_ind             => p_financial_report_rec.signed_by_principals_ind,
        x_trial_balance_ind                    => p_financial_report_rec.trial_balance_ind,
        x_unbalanced_ind                       => p_financial_report_rec.unbalanced_ind,
        x_content_source_type                  => G_MISS_CONTENT_SOURCE_TYPE,
        x_status                               => p_financial_report_rec.status,
        x_actual_content_source                => p_financial_report_rec.actual_content_source,
        x_created_by_module                    => p_financial_report_rec.created_by_module
    );

    --Standard call to get message count and if count is 1, get message info.
    FND_MSG_PUB.Count_And_Get(
        p_encoded => FND_API.G_FALSE,
        p_count => x_msg_count,
        p_data  => x_msg_data );

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
            p_data  => x_msg_data );

    WHEN OTHERS THEN
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

        FND_MESSAGE.SET_NAME( 'AR', 'HZ_API_OTHERS_EXCEP' );
        FND_MESSAGE.SET_TOKEN( 'ERROR' ,SQLERRM );
        FND_MSG_PUB.ADD;

        FND_MSG_PUB.Count_And_Get(
            p_encoded => FND_API.G_FALSE,
            p_count => x_msg_count,
            p_data  => x_msg_data );

END get_financial_report_rec;

/**
 * PROCEDURE create_financial_number
 *
 * DESCRIPTION
 *     Creates financial_number.
 *
 * EXTERNAL PROCEDURES/FUNCTIONS ACCESSED
 *     HZ_BUSINESS_EVENT_V2PVT.create_fin_numbers_event
 *
 * ARGUMENTS
 *   IN:
 *     p_init_msg_list                Initialize message stack if it is set to
 *                                    FND_API.G_TRUE. Default is FND_API.G_FALSE.
 *     p_financial_number_rec         financial_number record.
 *   IN/OUT:
 *   OUT:
 *     x_financial_number_id          financial_number ID.
 *     x_return_status                Return status after the call. The status can
 *                                    be FND_API.G_RET_STS_SUCCESS (success),
 *                                    FND_API.G_RET_STS_ERROR (error),
 *                                    FND_API.G_RET_STS_UNEXP_ERROR (unexpected error).
 *     x_msg_count                    Number of messages in message stack.
 *     x_msg_data                     Message text if x_msg_count is 1.
 *
 * NOTES
 *
 * MODIFICATION HISTORY
 *
 *   23-JAN-2003    Sreedhar Mohan        o Created.
 *   04-JAN-2005    Rajib Ranjan Borah    o SSM SST Integration and Extension.
 *                                          For non-profile entities, the concept of
 *                                          select/de-select data-sources is obsoleted.
 *
 */

PROCEDURE create_financial_number(
    p_init_msg_list            IN  VARCHAR2 := FND_API.G_FALSE,
    p_financial_number_rec     IN  FINANCIAL_NUMBER_REC_TYPE,
    x_financial_number_id      OUT NOCOPY NUMBER,
    x_return_status            OUT NOCOPY VARCHAR2,
    x_msg_count                OUT NOCOPY NUMBER,
    x_msg_data                 OUT NOCOPY VARCHAR2
) IS

    l_api_name                 CONSTANT       VARCHAR2(30) := 'create_financial_number';
    l_financial_number_rec     FINANCIAL_NUMBER_REC_TYPE := p_financial_number_rec;

BEGIN

    --Standard start of API savepoint
    SAVEPOINT create_financial_number;

    --Initialize message list if p_init_msg_list is set to TRUE.
    IF FND_API.to_Boolean(p_init_msg_list) THEN
        FND_MSG_PUB.initialize;
    END IF;

    --Initialize API return status to success.
    x_return_status := FND_API.G_RET_STS_SUCCESS;

    --Bug 2868913: Removed the LoadDataSources from do_create_financial_number
    --and added here, as per V1 way.
/* SSM SST Integration and Extension
 * For non-profile entities, the concept of select/de-select data-sources is obsoleted.
 * There is no need to check if the data-source is selected.

    HZ_MIXNM_UTILITY.LoadDataSources(
      p_entity_name                    => 'HZ_FINANCIAL_REPORTS',
      p_entity_attr_id                 => g_fin_entity_attr_id,
      p_mixnmatch_enabled              => g_fin_mixnmatch_enabled,
      p_selected_datasources           => g_fin_selected_datasources );
*/
    -- Call to business logic.
    do_create_financial_number(
        l_financial_number_rec,
        x_financial_number_id,
        x_return_status);

    -- Bug 2868913: Added one more condition, g_fin_is_datasource_selected = Y, before calling business event

    -- SSM SST Integration and Extension
    -- For non-profile entities, the concept of select/de-select data-sources is obsoleted.
    -- There is no need to check if the data-source is selected.

    IF x_return_status = FND_API.G_RET_STS_SUCCESS /*AND
       g_fin_is_datasource_selected = 'Y' */
    THEN
      IF(HZ_UTILITY_V2PUB.G_EXECUTE_API_CALLOUTS in ('Y', 'EVENTS_ENABLED')) THEN
        -- Invoke business event system.
        HZ_BUSINESS_EVENT_V2PVT.create_fin_numbers_event (
          l_financial_number_rec );
      END IF;

      IF(HZ_UTILITY_V2PUB.G_EXECUTE_API_CALLOUTS in ('EVENTS_ENABLED', 'BO_EVENTS_ENABLED')) THEN
        HZ_POPULATE_BOT_PKG.pop_hz_financial_numbers(
          p_operation           => 'I',
          p_financial_number_id => x_financial_number_id);
      END IF;
    END IF;

    --Standard call to get message count and if count is 1, get message info.
    FND_MSG_PUB.Count_And_Get(
        p_encoded => FND_API.G_FALSE,
        p_count => x_msg_count,
        p_data  => x_msg_data);

EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN
        ROLLBACK TO create_financial_number;
        x_return_status := FND_API.G_RET_STS_ERROR;
        FND_MSG_PUB.Count_And_Get(
            p_encoded => FND_API.G_FALSE,
            p_count => x_msg_count,
            p_data  => x_msg_data);

    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
        ROLLBACK TO create_financial_number;
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        FND_MSG_PUB.Count_And_Get(
            p_encoded => FND_API.G_FALSE,
            p_count => x_msg_count,
            p_data  => x_msg_data);

    WHEN OTHERS THEN
        ROLLBACK TO create_financial_number;
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        FND_MESSAGE.SET_NAME('AR', 'HZ_API_OTHERS_EXCEP');
        FND_MESSAGE.SET_TOKEN('ERROR' ,SQLERRM);
        FND_MSG_PUB.ADD;
        FND_MSG_PUB.Count_And_Get(
            p_encoded => FND_API.G_FALSE,
            p_count => x_msg_count,
            p_data  => x_msg_data);

END create_financial_number;

/**
 * PROCEDURE update_financial_number
 *
 * DESCRIPTION
 *     Updates Financial Number.
 *
 * EXTERNAL PROCEDURES/FUNCTIONS ACCESSED
 *     HZ_BUSINESS_EVENT_V2PVT.update_fin_number_event
 *
 * ARGUMENTS
 *   IN:
 *     p_init_msg_list                Initialize message stack if it is set to
 *                                    FND_API.G_TRUE. Default is FND_API.G_FALSE.
 *     p_financial_number_rec         Financial Number record.
 *   IN/OUT:
 *     p_object_version_number        Used for locking the being updated record.
 *   OUT:
 *     x_return_status                Return status after the call. The status can
 *                                    be FND_API.G_RET_STS_SUCCESS (success),
 *                                    FND_API.G_RET_STS_ERROR (error),
 *                                    FND_API.G_RET_STS_UNEXP_ERROR (unexpected error).
 *     x_msg_count                    Number of messages in message stack.
 *     x_msg_data                     Message text if x_msg_count is 1.
 *
 * NOTES
 *
 * MODIFICATION HISTORY
 *
 *   23-JAN-2003    Sreedhar Mohan        o Created.
 *   04-JAN-2005    Rajib Ranjan Borah    o SSM SST Integration and Extension.
 *                                          For non-profile entities, the concept of
 *                                          select/de-select data-sources is obsoleted.
 *
 */

PROCEDURE update_financial_number(
    p_init_msg_list          IN     VARCHAR2 := FND_API.G_FALSE,
    p_financial_number_rec   IN     FINANCIAL_NUMBER_REC_TYPE,
    p_object_version_number  IN OUT NOCOPY NUMBER,
    x_return_status             OUT NOCOPY VARCHAR2,
    x_msg_count                 OUT NOCOPY NUMBER,
    x_msg_data                  OUT NOCOPY VARCHAR2
) IS

    l_api_name                       CONSTANT       VARCHAR2(30) := 'update_financial_number';
    l_financial_number_rec                          FINANCIAL_NUMBER_REC_TYPE := p_financial_number_rec;
    l_old_financial_number_rec                      FINANCIAL_NUMBER_REC_TYPE;

BEGIN

    --Standard start of API savepoint
    SAVEPOINT update_financial_number;

    --Initialize message list if p_init_msg_list is set to TRUE.
    IF FND_API.to_Boolean(p_init_msg_list) THEN
        FND_MSG_PUB.initialize;
    END IF;

    --Initialize API return status to success.
    x_return_status := FND_API.G_RET_STS_SUCCESS;

   get_financial_number_rec (
     p_financial_number_id        => p_financial_number_rec.financial_number_id,
     p_financial_number_rec       => l_old_financial_number_rec,
     x_return_status              => x_return_status,
     x_msg_count                  => x_msg_count,
     x_msg_data                   => x_msg_data);

    IF x_return_status = FND_API.G_RET_STS_ERROR THEN
        RAISE FND_API.G_EXC_ERROR;
    ELSIF x_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;

    -- Bug 2868913: default the actual_content_source through mixnm API
/* SSM SST Integration and Extension
 * For non-profile entities, the concept of select/de-select data-sources is obsoleted.
 * There is no need to check if the data-source is selected.

    HZ_MIXNM_UTILITY.LoadDataSources(
      p_entity_name                    => 'HZ_FINANCIAL_REPORTS',
      p_entity_attr_id                 => g_fin_entity_attr_id,
      p_mixnmatch_enabled              => g_fin_mixnmatch_enabled,
      p_selected_datasources           => g_fin_selected_datasources );
*/
    -- Call to business logic.
    do_update_financial_number(
        l_financial_number_rec,
        p_object_version_number,
        x_return_status);

    -- Bug 2868913: Added one more condition, g_fin_is_datasource_selected = Y, before calling business event
    IF x_return_status = FND_API.G_RET_STS_SUCCESS /*AND
       g_fin_is_datasource_selected = 'Y'*/
    THEN
      --Bug 2979651: Since 2907261 made to HZ.K, keeping back the changes of 115.8 version.
      IF(HZ_UTILITY_V2PUB.G_EXECUTE_API_CALLOUTS in ('Y', 'EVENTS_ENABLED')) THEN
        HZ_BUSINESS_EVENT_V2PVT.update_fin_numbers_event (
          l_financial_number_rec,
          l_old_financial_number_rec );
      END IF;

      IF(HZ_UTILITY_V2PUB.G_EXECUTE_API_CALLOUTS in ('EVENTS_ENABLED', 'BO_EVENTS_ENABLED')) THEN
        HZ_POPULATE_BOT_PKG.pop_hz_financial_numbers(
          p_operation           => 'U',
          p_financial_number_id => l_financial_number_rec.financial_number_id);
      END IF;
    END IF;

    --Standard call to get message count and if count is 1, get message info.
    FND_MSG_PUB.Count_And_Get(
        p_encoded => FND_API.G_FALSE,
        p_count => x_msg_count,
        p_data  => x_msg_data);

EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN
        ROLLBACK TO update_financial_number;
        x_return_status := FND_API.G_RET_STS_ERROR;
        FND_MSG_PUB.Count_And_Get(
            p_encoded => FND_API.G_FALSE,
            p_count => x_msg_count,
            p_data  => x_msg_data);

    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
        ROLLBACK TO update_financial_number;
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        FND_MSG_PUB.Count_And_Get(
            p_encoded => FND_API.G_FALSE,
            p_count => x_msg_count,
            p_data  => x_msg_data);

    WHEN OTHERS THEN
        ROLLBACK TO update_financial_number;
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        FND_MESSAGE.SET_NAME('AR', 'HZ_API_OTHERS_EXCEP');
        FND_MESSAGE.SET_TOKEN('ERROR' ,SQLERRM);
        FND_MSG_PUB.ADD;
        FND_MSG_PUB.Count_And_Get(
            p_encoded => FND_API.G_FALSE,
            p_count => x_msg_count,
            p_data  => x_msg_data);

END update_financial_number;

/**
 * PROCEDURE get_financial_number_rec
 *
 * DESCRIPTION
 *     Gets financial number record.
 *
 * EXTERNAL PROCEDURES/FUNCTIONS ACCESSED
 *     HZ_FINANCIAL_NUMBERS_PKG.Select_Row
 *
 * ARGUMENTS
 *   IN:
 *     p_init_msg_list                Initialize message stack if it is set to
 *                                    FND_API.G_TRUE. Default is FND_API.G_FALSE.
 *     p_financial_number_id          Financial Number ID.
 *   IN/OUT:
 *   OUT:
 *     x_financial_number_rec         Returned financial number record.
 *     x_return_status                Return status after the call. The status can
 *                                    be FND_API.G_RET_STS_SUCCESS (success),
 *                                    FND_API.G_RET_STS_ERROR (error),
 *                                    FND_API.G_RET_STS_UNEXP_ERROR (unexpected error).
 *     x_msg_count                    Number of messages in message stack.
 *     x_msg_data                     Message text if x_msg_count is 1.
 *
 * NOTES
 *
 * MODIFICATION HISTORY
 *
 *   23-JAN-2003    Sreedhar Mohan        o Created.
 */

PROCEDURE get_financial_number_rec (
    p_init_msg_list                         IN     VARCHAR2 := FND_API.G_FALSE,
    p_financial_number_id                   IN     NUMBER,
    p_financial_number_rec                  OUT    NOCOPY FINANCIAL_NUMBER_REC_TYPE,
    x_return_status                         OUT NOCOPY    VARCHAR2,
    x_msg_count                             OUT NOCOPY    NUMBER,
    x_msg_data                              OUT NOCOPY    VARCHAR2
) IS

    l_api_name                              CONSTANT VARCHAR2(30) := 'get_financial_number_rec';

BEGIN

    --Initialize message list if p_init_msg_list is set to TRUE.
    IF FND_API.to_Boolean(p_init_msg_list) THEN
        FND_MSG_PUB.initialize;
    END IF;

    --Initialize API return status to success.
    x_return_status := FND_API.G_RET_STS_SUCCESS;

    --Check whether primary key has been passed in.
    IF p_financial_number_id IS NULL OR
       p_financial_number_id = FND_API.G_MISS_NUM THEN
        FND_MESSAGE.SET_NAME( 'AR', 'HZ_API_MISSING_COLUMN' );
        FND_MESSAGE.SET_TOKEN( 'COLUMN', 'financial_number_id' );
        FND_MSG_PUB.ADD;
        RAISE FND_API.G_EXC_ERROR;
    END IF;

    -- The p_financial_number_rec.financial_number_id must be initiated to p_financial_number_id
    p_financial_number_rec.financial_number_id := p_financial_number_id;

    HZ_FINANCIAL_NUMBERS_PKG.Select_Row (
        x_financial_number_id                  => p_financial_number_rec.financial_number_id,
        x_financial_report_id                  => p_financial_number_rec.financial_report_id,
        x_financial_number                     => p_financial_number_rec.financial_number,
        x_financial_number_name                => p_financial_number_rec.financial_number_name,
        x_financial_units_applied              => p_financial_number_rec.financial_units_applied,
        x_financial_number_currency            => p_financial_number_rec.financial_number_currency,
        x_projected_actual_flag                => p_financial_number_rec.projected_actual_flag,
        x_content_source_type                  => G_MISS_CONTENT_SOURCE_TYPE,
        x_status                               => p_financial_number_rec.status,
        x_actual_content_source                => G_MISS_CONTENT_SOURCE_TYPE

    );

    --Standard call to get message count and if count is 1, get message info.
    FND_MSG_PUB.Count_And_Get(
        p_encoded => FND_API.G_FALSE,
        p_count => x_msg_count,
        p_data  => x_msg_data );

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
            p_data  => x_msg_data );

    WHEN OTHERS THEN
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

        FND_MESSAGE.SET_NAME( 'AR', 'HZ_API_OTHERS_EXCEP' );
        FND_MESSAGE.SET_TOKEN( 'ERROR' ,SQLERRM );
        FND_MSG_PUB.ADD;

        FND_MSG_PUB.Count_And_Get(
            p_encoded => FND_API.G_FALSE,
            p_count => x_msg_count,
            p_data  => x_msg_data );

END get_financial_number_rec;

END HZ_ORGANIZATION_INFO_V2PUB;

/
