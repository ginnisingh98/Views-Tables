--------------------------------------------------------
--  DDL for Package HZ_ORGANIZATION_INFO_V2PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."HZ_ORGANIZATION_INFO_V2PUB" AUTHID CURRENT_USER AS
/* $Header: ARH2OISS.pls 120.7 2006/08/17 10:13:41 idali noship $ */
/*#
 * This package contains the public APIs for Organization-related entities.
 * @rep:scope public
 * @rep:product HZ
 * @rep:displayname Organization Information
 * @rep:category BUSINESS_ENTITY HZ_ORGANIZATION
 * @rep:lifecycle active
 * @rep:doccd 120hztig.pdf Organization Information APIs,  Oracle Trading Community Architecture Technical Implementation Guide
 */

--------------------------------------
-- declaration of record type
--------------------------------------

TYPE financial_report_rec_type IS RECORD(
    financial_report_id                NUMBER,
    party_id                           NUMBER,
    type_of_financial_report           VARCHAR2(60),
    document_reference                 VARCHAR2(150),
    date_report_issued                 DATE,
    issued_period                      VARCHAR2(60),
    report_start_date                  DATE,
    report_end_date                    DATE,
    actual_content_source              VARCHAR2(30),
    requiring_authority                VARCHAR2(60),
    audit_ind                          VARCHAR2(30),
    consolidated_ind                   VARCHAR2(30),
    estimated_ind                      VARCHAR2(30),
    fiscal_ind                         VARCHAR2(30),
    final_ind                          VARCHAR2(30),
    forecast_ind                       VARCHAR2(30),
    opening_ind                        VARCHAR2(30),
    proforma_ind                       VARCHAR2(30),
    qualified_ind                      VARCHAR2(30),
    restated_ind                       VARCHAR2(30),
    signed_by_principals_ind           VARCHAR2(30),
    trial_balance_ind                  VARCHAR2(30),
    unbalanced_ind                     VARCHAR2(30),
    status                             VARCHAR2(30),
    created_by_module                  VARCHAR2(150)
);

TYPE financial_number_rec_type IS RECORD (
    financial_number_id                     NUMBER,
    financial_report_id                     NUMBER,
    financial_number                        NUMBER,
    financial_number_name                   VARCHAR2(60),
    financial_units_applied                 NUMBER,
    financial_number_currency               VARCHAR2(240),
    projected_actual_flag                   VARCHAR2(1),
    content_source_type                     VARCHAR2(30),
    status                                  VARCHAR2(1),
    created_by_module                       VARCHAR2(150)
);

--------------------------------------
-- declaration of public procedures and functions
--------------------------------------

/**
 * PROCEDURE create_financial_report
 *
 * DESCRIPTION
 *     Creates financial report.
 *
 * EXTERNAL PROCEDURES/FUNCTIONS ACCESSED
 *
 * ARGUMENTS
 *   IN:
 *     p_init_msg_list                Initialize message stack if it is set to
 *                                    FND_API.G_TRUE. Default is FND_API.G_FALSE.
 *     p_financial_report_rec         Financial report record.
 *   IN/OUT:
 *   OUT:
 *     x_financial_report_id          Financial report ID.
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
 *
 */

/*#
 * Use this routine to store a financial report for an organization. The API creates a
 * record in the HZ_FINANCIAL_REPORTS table.
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:displayname Create Financial Report
 * @rep:businessevent oracle.apps.ar.hz.FinancialReport.create
 * @rep:doccd 120hztig.pdf Organization Information APIs, Oracle Trading Community Architecture Technical Implementation Guide
 */
PROCEDURE create_financial_report(
    p_init_msg_list            IN  VARCHAR2 := FND_API.G_FALSE,
    p_financial_report_rec     IN  FINANCIAL_REPORT_REC_TYPE,
    x_financial_report_id      OUT NOCOPY NUMBER,
    x_return_status            OUT NOCOPY VARCHAR2,
    x_msg_count                OUT NOCOPY NUMBER,
    x_msg_data                 OUT NOCOPY VARCHAR2
);

/**
 * PROCEDURE update_financial_report
 *
 * DESCRIPTION
 *     Update financial report.
 *
 * EXTERNAL PROCEDURES/FUNCTIONS ACCESSED
 *
 * ARGUMENTS
 *   IN:
 *     p_init_msg_list                Initialize message stack if it is set to
 *                                    FND_API.G_TRUE. Default is FND_API.G_FALSE.
 *     p_financial_report_rec         Financial report record.
 *   IN/OUT:
 *     p_object_version_number        Used for locking the being updated record.
 *   OUT:
 *     x_financial_report_id          Financial report ID.
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
 *
 */

/*#
 * Use this routine to update a financial report for an organization.
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:displayname Update Financial Report
 * @rep:businessevent oracle.apps.ar.hz.FinancialReport.update
 * @rep:doccd 120hztig.pdf Organization Information APIs, Oracle Trading Community Architecture Technical Implementation Guide
 */
PROCEDURE update_financial_report(
    p_init_msg_list          IN     VARCHAR2 := FND_API.G_FALSE,
    p_financial_report_rec   IN     FINANCIAL_REPORT_REC_TYPE,
    p_object_version_number  IN OUT NOCOPY NUMBER,
    x_return_status             OUT NOCOPY VARCHAR2,
    x_msg_count                 OUT NOCOPY NUMBER,
    x_msg_data                  OUT NOCOPY VARCHAR2
);


/**
 * PROCEDURE create_financial_number
 *
 * DESCRIPTION
 *     Creates financial number.
 *
 * EXTERNAL PROCEDURES/FUNCTIONS ACCESSED
 *
 * ARGUMENTS
 *   IN:
 *     p_init_msg_list                Initialize message stack if it is set to
 *                                    FND_API.G_TRUE. Default is FND_API.G_FALSE.
 *     p_financial_number_rec         Financial Number record.
 *   IN/OUT:
 *   OUT:
 *     x_financial_number_id          Financial Number Id.
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
 *
 */

/*#
 * Use this routine to store financial numbers for an organization. The API creates a record in the HZ_FINANCIAL_NUMBERS table.
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:displayname  Create Financial Number
 * @rep:businessevent oracle.apps.ar.hz.FinancialNumber.create
 * @rep:doccd 120hztig.pdf Organization Information APIs, Oracle Trading Community Architecture Technical Implementation Guide
 */
PROCEDURE create_financial_number(
    p_init_msg_list            IN  VARCHAR2 := FND_API.G_FALSE,
    p_financial_number_rec     IN  FINANCIAL_NUMBER_REC_TYPE,
    x_financial_number_id      OUT NOCOPY NUMBER,
    x_return_status            OUT NOCOPY VARCHAR2,
    x_msg_count                OUT NOCOPY NUMBER,
    x_msg_data                 OUT NOCOPY VARCHAR2
);

/**
 * PROCEDURE update_financial_number
 *
 * DESCRIPTION
 *     Updates financial_number.
 *
 * EXTERNAL PROCEDURES/FUNCTIONS ACCESSED
 *
 * ARGUMENTS
 *   IN:
 *     p_init_msg_list                Initialize message stack if it is set to
 *                                    FND_API.G_TRUE. Default is FND_API.G_FALSE.
 *     p_financial_number_rec         Financial Number record.
 *   IN/OUT:
 *     p_object_version_number        Used for locking the being updated record.
 *   OUT:
 *     x_financial_number_id          Financial Number Id.
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
 *
 */

/*#
 * Use this routine to store financial numbers for an organization
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:displayname  Update Financial Number
 * @rep:businessevent oracle.apps.ar.hz.FinancialNumber.update
 * @rep:doccd 120hztig.pdf Organization Information APIs, Oracle Trading Community Architecture Technical Implementation Guide
 */
PROCEDURE update_financial_number(
    p_init_msg_list          IN     VARCHAR2 := FND_API.G_FALSE,
    p_financial_number_rec   IN     FINANCIAL_NUMBER_REC_TYPE,
    p_object_version_number  IN OUT NOCOPY NUMBER,
    x_return_status             OUT NOCOPY VARCHAR2,
    x_msg_count                 OUT NOCOPY NUMBER,
    x_msg_data                  OUT NOCOPY VARCHAR2
);

/**
 * PROCEDURE get_financial_report_rec
 *
 * DESCRIPTION
 *     Gets financial report rec.
 *
 * EXTERNAL PROCEDURES/FUNCTIONS ACCESSED
 *
 * ARGUMENTS
 *   IN:
 *     p_init_msg_list                Initialize message stack if it is set to
 *                                    FND_API.G_TRUE. Default is FND_API.G_FALSE.
 *     p_financial_report_id          Financial Report Id.
 *   IN/OUT:
 *   OUT:
 *     x_financial_report_rec         Financial Report Record.
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
 *
 */

PROCEDURE get_financial_report_rec (
    p_init_msg_list                         IN     VARCHAR2 := FND_API.G_FALSE,
    p_financial_report_id                   IN     NUMBER,
    p_financial_report_rec                  OUT    NOCOPY FINANCIAL_REPORT_REC_TYPE,
    x_return_status                         OUT NOCOPY    VARCHAR2,
    x_msg_count                             OUT NOCOPY    NUMBER,
    x_msg_data                              OUT NOCOPY    VARCHAR2
);

/**
 * PROCEDURE get_financial_number_rec
 *
 * DESCRIPTION
 *     Gets financial number rec.
 *
 * EXTERNAL PROCEDURES/FUNCTIONS ACCESSED
 *
 * ARGUMENTS
 *   IN:
 *     p_init_msg_list                Initialize message stack if it is set to
 *                                    FND_API.G_TRUE. Default is FND_API.G_FALSE.
 *     p_financial_number_id          Financial number Id.
 *   IN/OUT:
 *   OUT:
 *     x_financial_number_rec         Financial Number Record.
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
 *
 */

PROCEDURE get_financial_number_rec (
    p_init_msg_list                         IN     VARCHAR2 := FND_API.G_FALSE,
    p_financial_number_id                   IN     NUMBER,
    p_financial_number_rec                  OUT    NOCOPY FINANCIAL_NUMBER_REC_TYPE,
    x_return_status                         OUT NOCOPY    VARCHAR2,
    x_msg_count                             OUT NOCOPY    NUMBER,
    x_msg_data                              OUT NOCOPY    VARCHAR2
);

END HZ_ORGANIZATION_INFO_V2PUB;

 

/
