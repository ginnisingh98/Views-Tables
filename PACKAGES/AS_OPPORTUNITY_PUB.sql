--------------------------------------------------------
--  DDL for Package AS_OPPORTUNITY_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."AS_OPPORTUNITY_PUB" AUTHID CURRENT_USER as
/* $Header: asxpopps.pls 120.5 2006/07/26 11:12:15 mohali ship $ */
/*#
 * This is a public interface for all the opportunity related functions.
 * These APIs provide a number of procedures for Opportunity and its sub-entities
 * including Opportunity Contacts, Product Lines, Sales Credits, Competitor
 * Products, Decision Factors and Opportunity Obstacles.
 *
 * <p>
 *<B>Standard IN parameters:</B> The following list describes the standard IN parameters
 * which are common to all APIs provided by Oracle Sales products.
 * <ul><li>p_api_version: The p_api_version parameter has no default value. Therefore, all API
 * callers must pass it in their calls. This parameter is used by the API to
 * compare the version numbers of incoming calls to its current version number,
 * and to return an unexpected error if they are incompatible. Pass 2.0 unless
 * otherwise indicated in the API parameter list.</li>
 * <li>p_init_msg_list: Default = FND_API.G_FALSE. The p_init_msg_list
 * parameter allows API callers to request the API to do the initialization of
 * the message list on their behalf.</li>
 * <li>p_commit: Default = FND_API.G_FALSE. The p_commit parameter is used by API
 * callers to ask the API to do a commit on their behalf after performing its
 * function.</li>
 * <li>p_validation_level: Default = FND_API.G_VALID_LEVEL_FULL. This parameter
 * should always be set to FND_API.G_VALID_LEVEL_FULL to ensure that valid data
 * is saved in the database.</li>
 * <li>p_check_access_flag: Standard parameter for opportunity and access APIs only.
 * The p_check_access_flag parameter allows API callers to request that the API
 * does the application security check on their behalf. We strongly recommend that
 * you always pass "Y" to the opportunity and access APIs to ensure that the application
 * data is processed with security control.</li>
 * <li>p_admin_flag: Standard parameter for opportunity and access APIs only.
 * This p_admin_flag parameter tells the API if the logged in user is an administrator.</li>
 * <li>p_admin_group_id: Standard parameter for opportunity and access APIs only.
 * This parameter passes the administrator sales group ID of the logged in user if the
 * user is an administrator.</li>
 * <li>p_identity_salesforce_id: Standard parameter for opportunity and access APIs
 * only. This parameter passes the resource identifier of the logged in user.</li>
 * <li>p_profile_tbl: This parameter is not used currently.</li></ul></p>
 *
 * <p>
 * <B>Standard OUT parameters:</B> The following list describes standard OUT parameters
 * which are common to all public APIs provided by Oracle Sales products.
 * <ul><li>x_return_status: Indicates the return status of the API. The values returned
 * are one of the following:
 * <ul><li> FND_API.G_RET_STS_SUCCESS- indicates that the API call
 * was successful. </li>
 * <li>FND_API.G_RET_STS_ERROR- indicates that there was a validation error
 * or a missing data error.</li>
 * <li>FND_API.G_RET_STS_UNEXP_ ERROR- indicates that the calling
 * program encountered an unexpected or unhandled error.</li></ul></li>
 * <li>x_msg_count: Holds the number of messages in the message list. Refer to the FND_MSG_PUB
 * API documentation for more information about how to retrieve messages from the message
 * stack.</li>
 * <li>x_msg_data: Error message returned by the API. If the number of messages returned is
 * more than one, this parameter will be null and the messages must be extracted
 * from the message stack.</li></ul></p>
 *
 * Note: <I>All standard OUT parameters are required parameter specifications.</I>
 *
 * @rep:scope public
 * @rep:product AS
 * @rep:displayname Opportunity Public APIs
 * @rep:lifecycle active
 * @rep:category BUSINESS_ENTITY AS_OPPORTUNITY
 */

-- Start of Comments
--
-- NAME
--   AS_OPPORTUNITY_PUB
--
--

--
-- Opportunity Header Type
--

TYPE header_rec_type        IS RECORD
    (   last_update_date            Date        := FND_API.G_MISS_DATE,
        last_updated_by             Number          := FND_API.G_MISS_NUM,
        creation_Date               Date            := FND_API.G_MISS_DATE,
        created_by                  Number          := FND_API.G_MISS_NUM,
        last_update_login           Number          := FND_API.G_MISS_NUM,
        request_id                  NUMBER      := FND_API.G_MISS_NUM,
        program_application_id      NUMBER      := FND_API.G_MISS_NUM,
        program_id                  NUMBER      := FND_API.G_MISS_NUM,
        program_update_date         DATE        := FND_API.G_MISS_DATE,
        lead_id                     NUMBER      := FND_API.G_MISS_NUM,
        lead_number                 VARCHAR2(30)    := FND_API.G_MISS_CHAR,
        orig_system_reference       VARCHAR2(240)   := FND_API.G_MISS_CHAR,
        lead_source_code            VARCHAR2(30)    := FND_API.G_MISS_CHAR,
        lead_source                 VARCHAR2(80)    := FND_API.G_MISS_CHAR,
        description                 VARCHAR2(240)   := FND_API.G_MISS_CHAR,
        source_promotion_id         NUMBER          := FND_API.G_MISS_NUM,
        source_promotion_code       VARCHAR2(30)    := FND_API.G_MISS_CHAR,
        customer_id                 NUMBER          := FND_API.G_MISS_NUM,
        customer_name               VARCHAR2(360)   := FND_API.G_MISS_CHAR,
    customer_name_phonetic      VARCHAR2(360)   := FND_API.G_MISS_CHAR,
        address_id                  NUMBER          := FND_API.G_MISS_NUM,
        address                     VARCHAR2(240)   := FND_API.G_MISS_CHAR,
        address2                    VARCHAR2(240)   := FND_API.G_MISS_CHAR,
        address3                    VARCHAR2(240)   := FND_API.G_MISS_CHAR,
        address4                    VARCHAR2(240)   := FND_API.G_MISS_CHAR,
        city                        VARCHAR2(60)    := FND_API.G_MISS_CHAR,
        state                       VARCHAR2(60)    := FND_API.G_MISS_CHAR,
        country                     VARCHAR2(60)    := FND_API.G_MISS_CHAR,
        province                    VARCHAR2(60)    := FND_API.G_MISS_CHAR,
        sales_stage_id              NUMBER          := FND_API.G_MISS_NUM,
        sales_stage                 VARCHAR2(60)    := FND_API.G_MISS_CHAR,
        win_probability             NUMBER          := FND_API.G_MISS_NUM,
        status_code                 VARCHAR2(30)    := FND_API.G_MISS_CHAR,
        status                      VARCHAR2(240)   := FND_API.G_MISS_CHAR,
        total_amount                NUMBER          := FND_API.G_MISS_NUM,
    converted_total_amount      NUMBER          := FND_API.G_MISS_NUM,
        channel_code                VARCHAR2(30)    := FND_API.G_MISS_CHAR,
        channel                     VARCHAR2(80)    := FND_API.G_MISS_CHAR,
        decision_date               DATE            := FND_API.G_MISS_DATE,
        currency_code               VARCHAR2(15)    := FND_API.G_MISS_CHAR,
    to_currency_code            VARCHAR2(15)    := FND_API.G_MISS_CHAR,
        close_reason_code           VARCHAR2(30)    := FND_API.G_MISS_CHAR,
        close_reason                VARCHAR2(80)    := FND_API.G_MISS_CHAR,
        close_competitor_code       VARCHAR2(30)    := FND_API.G_MISS_CHAR,
        close_competitor_id         NUMBER          := FND_API.G_MISS_NUM,
        close_competitor            VARCHAR2(360)   := FND_API.G_MISS_CHAR,
        close_comment               VARCHAR2(240)   := FND_API.G_MISS_CHAR,
        end_user_customer_id        NUMBER          := FND_API.G_MISS_NUM,
        end_user_customer_name      VARCHAR2(360)   := FND_API.G_MISS_CHAR,
        end_user_address_id         NUMBER          := FND_API.G_MISS_NUM,
    owner_salesforce_id     NUMBER          := FND_API.G_MISS_NUM,
    owner_sales_group_id        NUMBER      := FND_API.G_MISS_NUM,
    -- owner_assign_date        DATE            := FND_API.G_MISS_DATE,
        parent_project              VARCHAR2(80)    := FND_API.G_MISS_CHAR,
        parent_project_code         VARCHAR2(30)    := FND_API.G_MISS_CHAR,
        updateable_flag             VARCHAR2(1)     := 'N',
        price_list_id               Number          := FND_API.G_MISS_NUM,
        initiating_contact_id       Number          := FND_API.G_MISS_NUM,
        rank                        Varchar2(30)    := FND_API.G_MISS_CHAR,
        member_access               VARCHAR2(1)     := FND_API.G_MISS_CHAR,
        member_role                 VARCHAR2(1)     := FND_API.G_MISS_CHAR,
    Deleted_Flag            VARCHAR2(1)     := FND_API.G_MISS_CHAR,
    Auto_Assignment_Type        VARCHAR2(30)    := FND_API.G_MISS_CHAR,
    PRM_Assignment_Type     VARCHAR2(30)    := FND_API.G_MISS_CHAR,
    Customer_budget         NUMBER      := FND_API.G_MISS_NUM,
    Methodology_Code        VARCHAR2(30)    := FND_API.G_MISS_CHAR,
    Sales_Methodology_Id        NUMBER      := FND_API.G_MISS_NUM,
    Original_Lead_Id        NUMBER      := FND_API.G_MISS_NUM,
    Decision_Timeframe_Code     VARCHAR2(30)    := FND_API.G_MISS_CHAR,
    Incumbent_partner_Resource_Id   NUMBER      := FND_API.G_MISS_NUM,
    Incumbent_partner_Party_Id  NUMBER      := FND_API.G_MISS_NUM,
    Offer_Id            NUMBER      := FND_API.G_MISS_NUM,
    Vehicle_Response_Code       VARCHAR2(30)    := FND_API.G_MISS_CHAR,
    Budget_Status_Code      VARCHAR2(30)    := FND_API.G_MISS_CHAR,
    FOLLOWUP_DATE                   DATE        := FND_API.G_MISS_DATE,
    NO_OPP_ALLOWED_FLAG             VARCHAR2(1) := FND_API.G_MISS_CHAR,
    DELETE_ALLOWED_FLAG             VARCHAR2(1) := FND_API.G_MISS_CHAR,
    PRM_EXEC_SPONSOR_FLAG           VARCHAR2(1) := FND_API.G_MISS_CHAR,
    PRM_PRJ_LEAD_IN_PLACE_FLAG      VARCHAR2(1) := FND_API.G_MISS_CHAR,
    PRM_IND_CLASSIFICATION_CODE     VARCHAR2(30)    := FND_API.G_MISS_CHAR,
    PRM_LEAD_TYPE           VARCHAR2(30)    := FND_API.G_MISS_CHAR,
        ORG_ID                      NUMBER          := FND_API.G_MISS_NUM,
        freeze_flag                     VARCHAR2(1)    := FND_API.G_MISS_CHAR,
        attribute_category          VARCHAR2(30),
        attribute1                  VARCHAR2(150),
        attribute2                  VARCHAR2(150),
        attribute3                  VARCHAR2(150),
        attribute4                  VARCHAR2(150),
        attribute5                  VARCHAR2(150),
        attribute6                  VARCHAR2(150),
        attribute7                  VARCHAR2(150),
        attribute8                  VARCHAR2(150),
        attribute9                  VARCHAR2(150),
        attribute10                 VARCHAR2(150),
        attribute11                 VARCHAR2(150),
        attribute12                 VARCHAR2(150),
        attribute13                 VARCHAR2(150),
        attribute14                 VARCHAR2(150),
        attribute15                 VARCHAR2(150),
        PRM_REFERRAL_CODE           VARCHAR2(50)    := FND_API.G_MISS_CHAR,
        TOTAL_REVENUE_OPP_FORECAST_AMT  NUMBER          := FND_API.G_MISS_NUM -- Added for ASNB
        );

G_MISS_HEADER_REC       header_rec_type;
TYPE header_tbl_type        IS TABLE OF    header_rec_type
                        INDEX BY BINARY_INTEGER;
G_MISS_HEADER_TBL           header_tbl_type;



--
-- Opportunity Line Record Type
--

TYPE line_rec_type         IS RECORD
    (   last_update_date                Date        := FND_API.G_MISS_DATE,
        last_updated_by                 Number          := FND_API.G_MISS_NUM,
        creation_Date                   Date            := FND_API.G_MISS_DATE,
        created_by                      Number          := FND_API.G_MISS_NUM,
        last_update_login               Number          := FND_API.G_MISS_NUM,
        request_id                      NUMBER      := FND_API.G_MISS_NUM,
        program_application_id          NUMBER      := FND_API.G_MISS_NUM,
        program_id                      NUMBER      := FND_API.G_MISS_NUM,
        program_update_date             DATE        := FND_API.G_MISS_DATE,
    lead_id                         NUMBER          := FND_API.G_MISS_NUM,
        lead_line_id                    NUMBER          := FND_API.G_MISS_NUM,
        original_lead_line_id           NUMBER          := FND_API.G_MISS_NUM,
        interest_type_id                NUMBER          := FND_API.G_MISS_NUM,
        interest_type                   VARCHAR2(80)    := FND_API.G_MISS_CHAR,
        interest_status_code            VARCHAR2(30)    := FND_API.G_MISS_CHAR,
        primary_interest_code_id        NUMBER          := FND_API.G_MISS_NUM,
        primary_interest_code           VARCHAR2(100)   := FND_API.G_MISS_CHAR,
        secondary_interest_code_id      NUMBER          := FND_API.G_MISS_NUM,
        secondary_interest_code         VARCHAR2(100)   := FND_API.G_MISS_CHAR,
        inventory_item_id               NUMBER          := FND_API.G_MISS_NUM,
        inventory_item_conc_segs        VARCHAR2(2000)  := FND_API.G_MISS_CHAR,
        organization_id                 NUMBER          := FND_API.G_MISS_NUM,
        uom_code                        VARCHAR2(3)     := FND_API.G_MISS_CHAR,
        uom                             VARCHAR2(25)    := FND_API.G_MISS_CHAR,
        quantity                        NUMBER          := FND_API.G_MISS_NUM,
    ship_date               DATE        := FND_API.G_MISS_DATE,
        total_amount                    NUMBER          := FND_API.G_MISS_NUM,
        sales_stage_id                  NUMBER          := FND_API.G_MISS_NUM,
        sales_stage                     VARCHAR2(60)    := FND_API.G_MISS_CHAR,
        win_probability                 NUMBER          := FND_API.G_MISS_NUM,
        status_code                     VARCHAR2(30)    := FND_API.G_MISS_CHAR,
        status                          VARCHAR2(80)    := FND_API.G_MISS_CHAR,
        decision_date                   DATE            := FND_API.G_MISS_DATE,
        channel_code                    VARCHAR2(30)    := FND_API.G_MISS_CHAR,
        channel                         VARCHAR2(80)    := FND_API.G_MISS_CHAR,
        unit_price                  Number          := FND_API.G_MISS_NUM,
    price                   Number          := FND_API.G_MISS_NUM,
        price_volume_margin         Number          := FND_API.G_MISS_NUM,
        quoted_line_flag            Varchar(1)      := FND_API.G_MISS_CHAR,
        member_access               VARCHAR2(1)     := FND_API.G_MISS_CHAR,
        member_role                 VARCHAR2(1)     := FND_API.G_MISS_CHAR,
    currency_code               VARCHAR2(15)    := FND_API.G_MISS_CHAR,
        owner_scredit_percent       NUMBER      := FND_API.G_MISS_NUM,
    Source_Promotion_Id     NUMBER      := FND_API.G_MISS_NUM,
    forecast_date           DATE            := FND_API.G_MISS_DATE,
        rolling_forecast_flag       Varchar(1)      := FND_API.G_MISS_CHAR,
    Offer_Id            NUMBER      := FND_API.G_MISS_NUM,
        ORG_ID                          NUMBER      := FND_API.G_MISS_NUM,
        product_category_id             NUMBER      := FND_API.G_MISS_NUM,
    product_cat_set_id              NUMBER      := FND_API.G_MISS_NUM,
        attribute_category          VARCHAR2(30),
        attribute1                  VARCHAR2(150),
        attribute2                  VARCHAR2(150),
        attribute3                  VARCHAR2(150),
        attribute4                  VARCHAR2(150),
        attribute5                  VARCHAR2(150),
        attribute6                  VARCHAR2(150),
        attribute7                  VARCHAR2(150),
        attribute8                  VARCHAR2(150),
        attribute9                  VARCHAR2(150),
        attribute10                 VARCHAR2(150),
        attribute11                 VARCHAR2(150),
        attribute12                 VARCHAR2(150),
        attribute13                 VARCHAR2(150),
        attribute14                 VARCHAR2(150),
        attribute15                 VARCHAR2(150),
        opp_worst_forecast_amount   NUMBER := FND_API.G_MISS_NUM,
        opp_forecast_amount         NUMBER := FND_API.G_MISS_NUM,
        opp_best_forecast_amount    NUMBER := FND_API.G_MISS_NUM
       );

G_MISS_LINE_REC line_rec_type;
TYPE line_tbl_type  IS TABLE OF    line_rec_type
                        INDEX BY BINARY_INTEGER;
G_MISS_LINE_TBL         line_tbl_type;

TYPE line_out_rec_type          IS RECORD
(
        lead_line_id            NUMBER,
        return_status           VARCHAR2(1)
);
TYPE line_out_tbl_type          IS TABLE OF    line_out_rec_type
                            INDEX BY BINARY_INTEGER;


--
-- Sales Credit Record Type
--

TYPE sales_credit_rec_type    IS RECORD
    (   last_update_date            Date        := FND_API.G_MISS_DATE,
        last_updated_by             Number      := FND_API.G_MISS_NUM,
        creation_Date               Date            := FND_API.G_MISS_DATE,
        created_by                  Number          := FND_API.G_MISS_NUM,
        last_update_login           Number          := FND_API.G_MISS_NUM,
        request_id                  NUMBER      := FND_API.G_MISS_NUM,
        program_application_id      NUMBER      := FND_API.G_MISS_NUM,
        program_id                  NUMBER      := FND_API.G_MISS_NUM,
        program_update_date         DATE        := FND_API.G_MISS_DATE,
        sales_credit_id             NUMBER          := FND_API.G_MISS_NUM,
    original_sales_credit_id    NUMBER          := FND_API.G_MISS_NUM,
        lead_id                     NUMBER          := FND_API.G_MISS_NUM,
        lead_line_id                NUMBER          := FND_API.G_MISS_NUM,
        salesforce_id               NUMBER          := FND_API.G_MISS_NUM,
        person_id                   NUMBER          := FND_API.G_MISS_NUM,
        employee_last_name          VARCHAR2(40)    := FND_API.G_MISS_CHAR,
        employee_first_name         VARCHAR2(20)    := FND_API.G_MISS_CHAR,
        salesgroup_id               NUMBER          := FND_API.G_MISS_NUM,
        salesgroup_name             VARCHAR2(60)    := FND_API.G_MISS_CHAR,
        partner_customer_id         NUMBER          := FND_API.G_MISS_NUM,
        partner_customer_name       VARCHAR2(360)   := FND_API.G_MISS_CHAR,
        partner_city                VARCHAR2(60)    := FND_API.G_MISS_CHAR,
        partner_address_id          NUMBER          := FND_API.G_MISS_NUM,
        revenue_amount              NUMBER          := FND_API.G_MISS_NUM,
        revenue_percent             NUMBER          := FND_API.G_MISS_NUM,
        quota_credit_amount         NUMBER          := FND_API.G_MISS_NUM,
        quota_credit_percent        NUMBER          := FND_API.G_MISS_NUM,
        revenue_derived_col         NUMBER          := FND_API.G_MISS_NUM,
        quota_derived_col           NUMBER          := FND_API.G_MISS_NUM,
        member_access               VARCHAR2(1)     := FND_API.G_MISS_CHAR,
        member_role                 VARCHAR2(1)     := FND_API.G_MISS_CHAR,
        MANAGER_REVIEW_FLAG         VARCHAR2(1)       := FND_API.G_MISS_CHAR,
        MANAGER_REVIEW_DATE         DATE        := FND_API.G_MISS_DATE,
        line_tbl_index              NUMBER          := NULL,
        delete_flag                 VARCHAR2(10)    := FND_API.G_FALSE,
    currency_code               VARCHAR2(15)    := FND_API.G_MISS_CHAR,
    credit_type_id              NUMBER          := FND_API.G_MISS_NUM,
    credit_type             VARCHAR2(30)      := FND_API.G_MISS_CHAR,
    credit_amount               NUMBER          := FND_API.G_MISS_NUM,
    credit_percent              NUMBER      := FND_API.G_MISS_NUM,
        ORG_ID                      NUMBER          := FND_API.G_MISS_NUM,
        attribute_category          VARCHAR2(30),
        attribute1                  VARCHAR2(150),
        attribute2                  VARCHAR2(150),
        attribute3                  VARCHAR2(150),
        attribute4                  VARCHAR2(150),
        attribute5                  VARCHAR2(150),
        attribute6                  VARCHAR2(150),
        attribute7                  VARCHAR2(150),
        attribute8                  VARCHAR2(150),
        attribute9                  VARCHAR2(150),
        attribute10                 VARCHAR2(150),
        attribute11                 VARCHAR2(150),
        attribute12                 VARCHAR2(150),
        attribute13                 VARCHAR2(150),
        attribute14                 VARCHAR2(150),
        attribute15                 VARCHAR2(150),
        opp_worst_forecast_amount   NUMBER := FND_API.G_MISS_NUM,
        opp_forecast_amount         NUMBER := FND_API.G_MISS_NUM,
        opp_best_forecast_amount    NUMBER := FND_API.G_MISS_NUM,
        defaulted_from_owner_flag     VARCHAR2(1)  := FND_API.G_MISS_CHAR -- Added for ASNB
        );

G_MISS_SALES_CREDIT_REC     sales_credit_rec_type;
TYPE sales_credit_tbl_type      IS TABLE OF    sales_credit_rec_type
                            INDEX BY BINARY_INTEGER;
G_MISS_SALES_CREDIT_TBL         sales_credit_tbl_type;

TYPE sales_credit_out_rec_type  IS RECORD
(
        sales_credit_id         NUMBER,
        return_status           VARCHAR2(1)
);
TYPE sales_credit_out_tbl_type  IS TABLE OF    sales_credit_out_rec_type
                            INDEX BY BINARY_INTEGER;


G_PERCENT_COLUMN CONSTANT NUMBER := 1;
G_AMOUNT_COLUMN CONSTANT NUMBER := 2;

--
-- Obstacle Record Type
--

TYPE obstacle_rec_type        IS RECORD
    (   last_update_date        Date            := FND_API.G_MISS_DATE,
        last_updated_by         Number          := FND_API.G_MISS_NUM,
        creation_Date           Date            := FND_API.G_MISS_DATE,
        created_by              Number          := FND_API.G_MISS_NUM,
        last_update_login       Number          := FND_API.G_MISS_NUM,
        request_id              NUMBER      := FND_API.G_MISS_NUM,
        program_application_id  NUMBER      := FND_API.G_MISS_NUM,
        program_id              NUMBER      := FND_API.G_MISS_NUM,
        program_update_date     DATE        := FND_API.G_MISS_DATE,
        lead_obstacle_id        NUMBER          := FND_API.G_MISS_NUM,
        lead_id                 NUMBER          := FND_API.G_MISS_NUM,
        obstacle_code           VARCHAR2(30)    := FND_API.G_MISS_CHAR,
        obstacle                VARCHAR2(80)    := FND_API.G_MISS_CHAR,
        obstacle_status         VARCHAR2(80)    := FND_API.G_MISS_CHAR,
        comments                VARCHAR2(240)   := FND_API.G_MISS_CHAR,
        member_access           VARCHAR2(30)    := FND_API.G_MISS_CHAR,
        member_role             VARCHAR2(30)    := FND_API.G_MISS_CHAR,
        ORG_ID                  NUMBER          := FND_API.G_MISS_NUM,
        attribute_category      VARCHAR2(30),
        attribute1              VARCHAR2(150),
        attribute2              VARCHAR2(150),
        attribute3              VARCHAR2(150),
        attribute4              VARCHAR2(150),
        attribute5              VARCHAR2(150),
        attribute6              VARCHAR2(150),
        attribute7              VARCHAR2(150),
        attribute8              VARCHAR2(150),
        attribute9              VARCHAR2(150),
        attribute10             VARCHAR2(150),
        attribute11             VARCHAR2(150),
        attribute12             VARCHAR2(150),
        attribute13             VARCHAR2(150),
        attribute14             VARCHAR2(150),
        attribute15             VARCHAR2(150)
    );

G_MISS_OBSTACLE_REC     obstacle_rec_type;
TYPE obstacle_tbl_type      IS TABLE OF    obstacle_rec_type
                        INDEX BY BINARY_INTEGER;
G_MISS_OBSTACLE_TBL         obstacle_tbl_type;

TYPE obstacle_out_rec_type      IS RECORD
(
        lead_obstacle_id        NUMBER,
        return_status           VARCHAR2(1)
);
TYPE obstacle_out_tbl_type      IS TABLE OF    obstacle_out_rec_type
                            INDEX BY BINARY_INTEGER;

--
-- Competitor Record Type
--

TYPE competitor_rec_type        IS RECORD
    (   last_update_date        Date            := FND_API.G_MISS_DATE,
        last_updated_by         Number          := FND_API.G_MISS_NUM,
        creation_Date           Date            := FND_API.G_MISS_DATE,
        created_by              Number          := FND_API.G_MISS_NUM,
        last_update_login       Number          := FND_API.G_MISS_NUM,
        request_id              NUMBER      := FND_API.G_MISS_NUM,
        program_application_id  NUMBER      := FND_API.G_MISS_NUM,
        program_id              NUMBER      := FND_API.G_MISS_NUM,
        program_update_date     DATE        := FND_API.G_MISS_DATE,
        lead_competitor_id      NUMBER          := FND_API.G_MISS_NUM,
        competitor_code         VARCHAR2(30)    := FND_API.G_MISS_CHAR,
        competitor_id           NUMBER          := FND_API.G_MISS_NUM,
    relationship_party_id   NUMBER          := FND_API.G_MISS_NUM,
        lead_id                 NUMBER          := FND_API.G_MISS_NUM,
        competitor              VARCHAR2(80)    := FND_API.G_MISS_CHAR,
        competitor_meaning      VARCHAR2(240)   := FND_API.G_MISS_CHAR,
    competitor_rank     NUMBER      := FND_API.G_MISS_NUM,
    win_loss_status         VARCHAR2(30)    := FND_API.G_MISS_CHAR,
        products                VARCHAR2(80)    := FND_API.G_MISS_CHAR,
        comments                VARCHAR2(240)   := FND_API.G_MISS_CHAR,
        member_access           VARCHAR2(30)    := FND_API.G_MISS_CHAR,
        member_role             VARCHAR2(30)    := FND_API.G_MISS_CHAR,
        ORG_ID                  NUMBER          := FND_API.G_MISS_NUM,
        attribute_category      VARCHAR2(30),
        attribute1              VARCHAR2(150),
        attribute2              VARCHAR2(150),
        attribute3              VARCHAR2(150),
        attribute4              VARCHAR2(150),
        attribute5              VARCHAR2(150),
        attribute6              VARCHAR2(150),
        attribute7              VARCHAR2(150),
        attribute8              VARCHAR2(150),
        attribute9              VARCHAR2(150),
        attribute10             VARCHAR2(150),
        attribute11             VARCHAR2(150),
        attribute12             VARCHAR2(150),
        attribute13             VARCHAR2(150),
        attribute14             VARCHAR2(150),
        attribute15             VARCHAR2(150)
    );

G_MISS_COMPETITOR_REC       competitor_rec_type;
TYPE competitor_tbl_type        IS TABLE OF    competitor_rec_type
                            INDEX BY BINARY_INTEGER;
G_MISS_COMPETITOR_TBL       competitor_tbl_type;

TYPE competitor_out_rec_type    IS RECORD
(
        lead_competitor_id      NUMBER,
        return_status           VARCHAR2(1)
);
TYPE competitor_out_tbl_type    IS TABLE OF    competitor_out_rec_type
                            INDEX BY BINARY_INTEGER;

--
-- Order Record Type
--

TYPE order_rec_type            IS RECORD
    (   last_update_date        Date            := FND_API.G_MISS_DATE,
        last_updated_by         Number          := FND_API.G_MISS_NUM,
        creation_Date           Date            := FND_API.G_MISS_DATE,
        created_by              Number          := FND_API.G_MISS_NUM,
        last_update_login       Number          := FND_API.G_MISS_NUM,
        request_id              NUMBER      := FND_API.G_MISS_NUM,
        program_application_id  NUMBER      := FND_API.G_MISS_NUM,
        program_id              NUMBER      := FND_API.G_MISS_NUM,
        program_update_date     DATE        := FND_API.G_MISS_DATE,
        lead_order_id           NUMBER          := FND_API.G_MISS_NUM,
        lead_id                 NUMBER          := FND_API.G_MISS_NUM,
        order_number            NUMBER          := FND_API.G_MISS_NUM,
        order_header_id         NUMBER          := FND_API.G_MISS_NUM,
        date_ordered            Date            := FND_API.G_MISS_DATE,
        order_type_id           Number          := FND_API.G_MISS_NUM,
        order_type              VARCHAR2(30)    := FND_API.G_MISS_CHAR,
        currency_code           VARCHAR2(15)    := FND_API.G_MISS_CHAR,
        order_amount            NUMBER          := FND_API.G_MISS_NUM,
        member_access           VARCHAR2(30)    := FND_API.G_MISS_CHAR,
        member_role             VARCHAR2(30)    := FND_API.G_MISS_CHAR,
        ORG_ID                  NUMBER          := FND_API.G_MISS_NUM,
        attribute_category      VARCHAR2(30),
        attribute1              VARCHAR2(150),
        attribute2              VARCHAR2(150),
        attribute3              VARCHAR2(150),
        attribute4              VARCHAR2(150),
        attribute5              VARCHAR2(150),
        attribute6              VARCHAR2(150),
        attribute7              VARCHAR2(150),
        attribute8              VARCHAR2(150),
        attribute9              VARCHAR2(150),
        attribute10             VARCHAR2(150),
        attribute11             VARCHAR2(150),
        attribute12             VARCHAR2(150),
        attribute13             VARCHAR2(150),
        attribute14             VARCHAR2(150),
        attribute15             VARCHAR2(150)
    );

G_MISS_ORDER_REC            order_rec_type;
TYPE order_tbl_type         IS TABLE OF    order_rec_type
                            INDEX BY BINARY_INTEGER;
G_MISS_ORDER_TBL                order_tbl_type;

TYPE order_out_rec_type     IS RECORD
(
        lead_order_id       NUMBER,
        return_status           VARCHAR2(1)
);
TYPE order_out_tbl_type     IS TABLE OF    order_out_rec_type
                            INDEX BY BINARY_INTEGER;

--
-- Contact Record Type
--

TYPE contact_rec_type        IS RECORD
    (   last_update_date        Date            := FND_API.G_MISS_DATE,
        last_updated_by         Number          := FND_API.G_MISS_NUM,
        creation_Date           Date            := FND_API.G_MISS_DATE,
        created_by              Number          := FND_API.G_MISS_NUM,
        last_update_login       Number          := FND_API.G_MISS_NUM,
        request_id              NUMBER          := FND_API.G_MISS_NUM,
        program_application_id  NUMBER          := FND_API.G_MISS_NUM,
        program_id              NUMBER          := FND_API.G_MISS_NUM,
        program_update_date     DATE            := FND_API.G_MISS_DATE,
        lead_contact_id         NUMBER          := FND_API.G_MISS_NUM,
        lead_id                 NUMBER          := FND_API.G_MISS_NUM,
        customer_id             NUMBER          := FND_API.G_MISS_NUM,
        address_id              NUMBER          := FND_API.G_MISS_NUM,
        phone_id                NUMBER          := FND_API.G_MISS_NUM,
        first_name              VARCHAR2(40)    := FND_API.G_MISS_CHAR,
        last_name               VARCHAR2(50)    := FND_API.G_MISS_CHAR,
        contact_number          VARCHAR2(30)    := FND_API.G_MISS_CHAR,
        orig_system_reference   VARCHAR2(240)   := FND_API.G_MISS_CHAR,
        contact_id              NUMBER          := FND_API.G_MISS_NUM,
        enabled_flag            VARCHAR2(1)     := FND_API.G_MISS_CHAR,
        rank_code               VARCHAR2(30)    := FND_API.G_MISS_CHAR,
        rank                    VARCHAR2(80)    := FND_API.G_MISS_CHAR,
        member_access           VARCHAR2(30)    := FND_API.G_MISS_CHAR,
        member_role             VARCHAR2(30)    := FND_API.G_MISS_CHAR,
    contact_party_id        NUMBER          := FND_API.G_MISS_NUM,
    primary_contact_flag    VARCHAR2(1)     := FND_API.G_MISS_CHAR,
    role                    VARCHAR2(30)    := FND_API.G_MISS_CHAR,
        ORG_ID                  NUMBER          := FND_API.G_MISS_NUM,
        attribute_category      VARCHAR2(30),
        attribute1              VARCHAR2(150),
        attribute2              VARCHAR2(150),
        attribute3              VARCHAR2(150),
        attribute4              VARCHAR2(150),
        attribute5              VARCHAR2(150),
        attribute6              VARCHAR2(150),
        attribute7              VARCHAR2(150),
        attribute8              VARCHAR2(150),
        attribute9              VARCHAR2(150),
        attribute10             VARCHAR2(150),
        attribute11             VARCHAR2(150),
        attribute12             VARCHAR2(150),
        attribute13             VARCHAR2(150),
        attribute14             VARCHAR2(150),
        attribute15             VARCHAR2(150)
    );

G_MISS_CONTACT_REC              contact_rec_type;
TYPE contact_tbl_type       IS TABLE OF    contact_rec_type
                            INDEX BY BINARY_INTEGER;
G_MISS_CONTACT_TBL              contact_tbl_type;

TYPE contact_out_rec_type       IS RECORD
(
        lead_contact_id     NUMBER,
        return_status           VARCHAR2(1)
);
TYPE contact_out_tbl_type   IS TABLE OF    contact_out_rec_type
                            INDEX BY BINARY_INTEGER;


TYPE Competitor_Prod_Rec_Type IS RECORD
(
--       SECURITY_GROUP_ID               NUMBER := FND_API.G_MISS_NUM,
       ATTRIBUTE15                     VARCHAR2(150) := FND_API.G_MISS_CHAR,
       ATTRIBUTE14                     VARCHAR2(150) := FND_API.G_MISS_CHAR,
       ATTRIBUTE13                     VARCHAR2(150) := FND_API.G_MISS_CHAR,
       ATTRIBUTE12                     VARCHAR2(150) := FND_API.G_MISS_CHAR,
       ATTRIBUTE11                     VARCHAR2(150) := FND_API.G_MISS_CHAR,
       ATTRIBUTE10                     VARCHAR2(150) := FND_API.G_MISS_CHAR,
       ATTRIBUTE9                      VARCHAR2(150) := FND_API.G_MISS_CHAR,
       ATTRIBUTE8                      VARCHAR2(150) := FND_API.G_MISS_CHAR,
       ATTRIBUTE7                      VARCHAR2(150) := FND_API.G_MISS_CHAR,
       ATTRIBUTE6                      VARCHAR2(150) := FND_API.G_MISS_CHAR,
       ATTRIBUTE4                      VARCHAR2(150) := FND_API.G_MISS_CHAR,
       ATTRIBUTE5                      VARCHAR2(150) := FND_API.G_MISS_CHAR,
       ATTRIBUTE2                      VARCHAR2(150) := FND_API.G_MISS_CHAR,
       ATTRIBUTE3                      VARCHAR2(150) := FND_API.G_MISS_CHAR,
       ATTRIBUTE1                      VARCHAR2(150) := FND_API.G_MISS_CHAR,
       ATTRIBUTE_CATEGORY              VARCHAR2(30) := FND_API.G_MISS_CHAR,
       PROGRAM_ID                      NUMBER := FND_API.G_MISS_NUM,
       PROGRAM_UPDATE_DATE             DATE := FND_API.G_MISS_DATE,
       PROGRAM_APPLICATION_ID          NUMBER := FND_API.G_MISS_NUM,
       REQUEST_ID                      NUMBER := FND_API.G_MISS_NUM,
       WIN_LOSS_STATUS                 VARCHAR2(30) := FND_API.G_MISS_CHAR,
       COMPETITOR_PRODUCT_ID           NUMBER := FND_API.G_MISS_NUM,
       LEAD_LINE_ID                    NUMBER := FND_API.G_MISS_NUM,
       LEAD_ID                         NUMBER := FND_API.G_MISS_NUM,
       LEAD_COMPETITOR_PROD_ID         NUMBER := FND_API.G_MISS_NUM,
       LAST_UPDATE_LOGIN               NUMBER := FND_API.G_MISS_NUM,
       LAST_UPDATED_BY                 NUMBER := FND_API.G_MISS_NUM,
       LAST_UPDATE_DATE                DATE := FND_API.G_MISS_DATE,
       CREATED_BY                      NUMBER := FND_API.G_MISS_NUM,
       CREATION_DATE                   DATE := FND_API.G_MISS_DATE
);

G_MISS_Competitor_Prod_REC          Competitor_Prod_Rec_Type;
TYPE  Competitor_Prod_Tbl_Type      IS TABLE OF Competitor_Prod_Rec_Type
                                    INDEX BY BINARY_INTEGER;
G_MISS_Competitor_Prod_TBL          Competitor_Prod_Tbl_Type;

TYPE Competitor_Prod_out_rec_type       IS RECORD
(
        LEAD_COMPETITOR_PROD_ID     NUMBER,
        return_status               VARCHAR2(1)
);
TYPE Competitor_Prod_out_tbl_type   IS TABLE OF    Competitor_Prod_out_rec_type
                            INDEX BY BINARY_INTEGER;


TYPE Decision_Factor_Rec_Type IS RECORD
(
--       SECURITY_GROUP_ID               NUMBER := FND_API.G_MISS_NUM,
       ATTRIBUTE15                     VARCHAR2(150) := FND_API.G_MISS_CHAR,
       ATTRIBUTE14                     VARCHAR2(150) := FND_API.G_MISS_CHAR,
       ATTRIBUTE13                     VARCHAR2(150) := FND_API.G_MISS_CHAR,
       ATTRIBUTE12                     VARCHAR2(150) := FND_API.G_MISS_CHAR,
       ATTRIBUTE11                     VARCHAR2(150) := FND_API.G_MISS_CHAR,
       ATTRIBUTE10                     VARCHAR2(150) := FND_API.G_MISS_CHAR,
       ATTRIBUTE9                      VARCHAR2(150) := FND_API.G_MISS_CHAR,
       ATTRIBUTE8                      VARCHAR2(150) := FND_API.G_MISS_CHAR,
       ATTRIBUTE7                      VARCHAR2(150) := FND_API.G_MISS_CHAR,
       ATTRIBUTE6                      VARCHAR2(150) := FND_API.G_MISS_CHAR,
       ATTRIBUTE5                      VARCHAR2(150) := FND_API.G_MISS_CHAR,
       ATTRIBUTE4                      VARCHAR2(150) := FND_API.G_MISS_CHAR,
       ATTRIBUTE3                      VARCHAR2(150) := FND_API.G_MISS_CHAR,
       ATTRIBUTE2                      VARCHAR2(150) := FND_API.G_MISS_CHAR,
       ATTRIBUTE1                      VARCHAR2(150) := FND_API.G_MISS_CHAR,
       ATTRIBUTE_CATEGORY              VARCHAR2(30) := FND_API.G_MISS_CHAR,
       PROGRAM_UPDATE_DATE             DATE := FND_API.G_MISS_DATE,
       PROGRAM_ID                      NUMBER := FND_API.G_MISS_NUM,
       PROGRAM_APPLICATION_ID          NUMBER := FND_API.G_MISS_NUM,
       REQUEST_ID                      NUMBER := FND_API.G_MISS_NUM,
       DECISION_RANK                   NUMBER := FND_API.G_MISS_NUM,
       DECISION_PRIORITY_CODE          VARCHAR2(240) := FND_API.G_MISS_CHAR,
       DECISION_FACTOR_CODE            VARCHAR2(30) := FND_API.G_MISS_CHAR,
       LEAD_DECISION_FACTOR_ID         NUMBER := FND_API.G_MISS_NUM,
       LEAD_LINE_ID                    NUMBER := FND_API.G_MISS_NUM,
       CREATE_BY                       NUMBER := FND_API.G_MISS_NUM,
       LAST_UPDATED_BY                 NUMBER := FND_API.G_MISS_NUM,
       LAST_UPDATE_DATE                DATE := FND_API.G_MISS_DATE,
       LAST_UPDATE_LOGIN               NUMBER := FND_API.G_MISS_NUM,
       CREATION_DATE                   DATE := FND_API.G_MISS_DATE
);

G_MISS_Decision_Factor_REC          Decision_Factor_Rec_Type;
TYPE  Decision_Factor_Tbl_Type      IS TABLE OF Decision_Factor_Rec_Type
                                    INDEX BY BINARY_INTEGER;
G_MISS_Decision_Factor_TBL          Decision_Factor_Tbl_Type;

TYPE Decision_Factor_out_rec_type       IS RECORD
(
        LEAD_DECISION_FACTOR_ID     NUMBER,
        return_status               VARCHAR2(1)
);
TYPE Decision_Factor_out_tbl_type   IS TABLE OF    Decision_Factor_out_rec_type
                            INDEX BY BINARY_INTEGER;



-- Start of Comments
--
--    API name    : Create_Opp_header
--    Type        : Public.
--
--
-- Required:
--        last_update_date
--        last_updated_by
--        creation_date
--        created_by
--        last_update_login
--        Customer_Id
--        Status
--
--
-- End of Comments

/*#
 * Creates the Opportunity Header.
 *
 * This procedure performs the following functions:
 * <ul>
 * <li>Checks for user privileges to create new opportunities.</li>
 * <li>Validates the data in the header record.</li>
 * <li>Inserts a new opportunity header record in table AS_LEADS_ALL.</li>
 * <li>Adds creator to the opportunity's sales team.</li>
 * <li>Performs territory assignment for this opportunity.</li>
 * <li>Starts the sales methodology workflow.</li>
 * <li>Performs post creation processes through user-hook to handle business logic
 *   implemented by Oracle Partners.</li>
 * </ul>
 *
 * @param p_api_version_number API version number.
 * @param p_init_msg_list Intialize the message array.
 * @param p_commit Commit after processing the transaction.
 * @param p_validation_level Validation Level (FND_API.G_VALID_LEVEL_NONE
 * or FND_API.G_VALID_LEVEL_FULL).
 * @param p_header_rec Record of the opportunity header to be created. The
 * record type passed in p_header_rec is defined in the package AS_OPPORTUNITY_PUB.
 * @param p_check_access_flag Check whether the logged in user has privileges
 * to create the opportunity.
 * @param p_admin_flag 'Y' if the logged in user has an administrator role.
 * @param p_admin_group_id Sales group identifier of the logged in user if
 * the user has an administrator role.
 * @param p_identity_salesforce_id Sales force identifier of the logged in user.
 * @param p_salesgroup_id Sales group identifier of the logged in user.
 * @param p_partner_cont_party_id The party identifier of the partner contact
 * if the logged in user is a partner contact.
 * @param p_profile_tbl A PL/SQL table containing profile values. This PL/SQL
 * table is of record type AS_UTILITY_PUB.profile_rec_type defined in the
 * package AS_UTILITY_PUB.
 * @param x_return_status The return status of the API stating Success, Failure or
 * Unexpected Error.
 * @param x_msg_count Number of error messages recorded during processing.
 * @param x_msg_data Contains the text of the message if msg_count = 1.
 * @param x_lead_id The identifier of the created opportunity.
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:displayname Create Opportunity Header
 */
PROCEDURE Create_Opp_Header
(   p_api_version_number        IN    NUMBER,
    p_init_msg_list             IN    VARCHAR2  DEFAULT FND_API.G_FALSE,
    p_commit                    IN    VARCHAR2  DEFAULT FND_API.G_FALSE,
    p_validation_level          IN    NUMBER    DEFAULT FND_API.G_VALID_LEVEL_FULL,
    p_header_rec                IN    HEADER_REC_TYPE   DEFAULT  G_MISS_HEADER_REC,
    p_check_access_flag         IN    VARCHAR2,
    p_admin_flag            IN    VARCHAR2,
    p_admin_group_id            IN    NUMBER,
    p_identity_salesforce_id    IN    NUMBER,
    p_salesgroup_id     IN    NUMBER    DEFAULT  NULL,
    p_partner_cont_party_id IN    NUMBER,
    p_profile_tbl           IN    AS_UTILITY_PUB.Profile_Tbl_Type
                      DEFAULT AS_UTILITY_PUB.G_MISS_PROFILE_TBL,
    x_return_status             OUT NOCOPY   VARCHAR2,
    x_msg_count                 OUT NOCOPY   NUMBER,
    x_msg_data                  OUT NOCOPY   VARCHAR2,
    x_lead_id                   OUT NOCOPY   NUMBER
);


-- Start of Comments
--
--    API name    : Update_Opp_Header
--    Type        : Public
--    Function    : Update Opportunity Information
--
-- Required:
--        Lead_Id
--        last_update_date
--

/*#
 * Updates the Opportunity Header.
 *
 * This procedure performs the following functions:
 * <ul>
 * <li>Checks for user privileges to update new opportunities.</li>
 * <li>Validates the data in the header record.</li>
 * <li>Creates system notes for this opportunity if needed.</li>
 * <li>Updates the opportunity header in the AS_LEADS_ALL table.</li>
 * <li>Starts the sales methodology workflow if sales methodology is added to
 *   the opportunity.</li>
 * <li>Performs territory assignment for this opportunity.</li>
 * <li>Performs post creation processes through user-hook to handle business logic
 *   implemented by Oracle Partners.</li>
 * </ul>
 *
 * @param p_api_version_number API version number.
 * @param p_init_msg_list Intialize the message array.
 * @param p_commit Commit after processing the transaction.
 * @param p_validation_level Validation Level (FND_API.G_VALID_LEVEL_NONE
 * or FND_API.G_VALID_LEVEL_FULL).
 * @param p_header_rec Record of the opportunity header to be updated. The
 * record type passed in p_header_rec is defined in the package AS_OPPORTUNITY_PUB.
 * @param p_check_access_flag Check whether the logged in user has privileges
 * to update the opportunity.
 * @param p_admin_flag 'Y' if logged in user has an administrator role.
 * @param p_admin_group_id Sales group identifier of the logged in user if
 * user has an administrator role.
 * @param p_identity_salesforce_id Sales force identifier of the logged in user.
 * @param p_partner_cont_party_id The party identifier of the partner contact
 * if the logged in user is a partner contact.
 * @param p_profile_tbl A PL/SQL table containing profile values. This PL/SQL
 * table is of record type AS_UTILITY_PUB.profile_rec_type defined in the
 * package AS_UTILITY_PUB.
 * @param x_return_status The return status of the API stating Success, Failure or
 * Unexpected Error.
 * @param x_msg_count Number of error messages recorded during processing.
 * @param x_msg_data Contains the text of the message if msg_count = 1.
 * @param x_lead_id The identifier of the updated opportunity.
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:displayname Update Opportunity Header
 */
PROCEDURE Update_Opp_Header
(   p_api_version_number        IN     NUMBER,
    p_init_msg_list             IN     VARCHAR2 DEFAULT  FND_API.G_FALSE,
    p_commit                    IN     VARCHAR2 DEFAULT  FND_API.G_FALSE,
    p_validation_level          IN     NUMBER   DEFAULT  FND_API.G_VALID_LEVEL_FULL,
    p_header_rec                IN     AS_OPPORTUNITY_PUB.Header_Rec_Type,
    p_check_access_flag         IN     VARCHAR2,
    p_admin_flag            IN     VARCHAR2,
    p_admin_group_id            IN     NUMBER,
    p_identity_salesforce_id    IN     NUMBER,
    p_partner_cont_party_id IN     NUMBER,
    p_profile_tbl           IN     AS_UTILITY_PUB.Profile_Tbl_Type
                       DEFAULT AS_UTILITY_PUB.G_MISS_PROFILE_TBL,
    x_return_status             OUT NOCOPY    VARCHAR2,
    x_msg_count                 OUT NOCOPY    NUMBER,
    x_msg_data                  OUT NOCOPY    VARCHAR2,
    x_lead_id                   OUT NOCOPY    NUMBER);


-- Start of Comments
--
--    API name    : Delete_Opp_Header
--    Type        : Public
--    Function    : Delete Opportunity Record
--

PROCEDURE Delete_Opp_Header
(   p_api_version_number        IN     NUMBER,
    p_init_msg_list             IN     VARCHAR2 DEFAULT  FND_API.G_FALSE,
    p_commit                    IN     VARCHAR2 DEFAULT  FND_API.G_FALSE,
    p_validation_level          IN     NUMBER   DEFAULT  FND_API.G_VALID_LEVEL_FULL,
    p_header_rec                IN     AS_OPPORTUNITY_PUB.Header_Rec_Type,
    p_check_access_flag         IN     VARCHAR2,
    p_admin_flag            IN     VARCHAR2,
    p_admin_group_id            IN     NUMBER,
    p_identity_salesforce_id    IN     NUMBER,
    p_partner_cont_party_id IN     NUMBER,
    p_profile_tbl           IN     AS_UTILITY_PUB.Profile_Tbl_Type
                       DEFAULT AS_UTILITY_PUB.G_MISS_PROFILE_TBL,
    x_return_status             OUT NOCOPY    VARCHAR2,
    x_msg_count                 OUT NOCOPY    NUMBER,
    x_msg_data                  OUT NOCOPY    VARCHAR2,
    x_lead_id                   OUT NOCOPY    NUMBER);


-- Start of Comments
--
--    API name    : Create_Opp_Lines
--    Type        : Public
--    Function    : Create Opportunity Lines for an Opportunity
--
--
-- Required:
--      Lead_Id
--      Interest_Type_Id/Inventory_Item_Id and Organization_Id
--

/*#
 * Creates product lines for an Opportunity.
 *
 * This procedure performs the following functions:
 * <ul>
 * <li>Checks for user privileges to create product lines.</li>
 * <li>Validates the data in the purchase line table.</li>
 * <li>Inserts purchase line records to the table AS_LEAD_LINES_ALL.</li>
 * <li>Updates the opportunity header with the new purchase amount.</li>
 * <li>Defaults forecast information to the user creating the product line.</li>
 * <li>Performs the territory assignment for the opportunity.</li>
 * </ul>
 *
 * @param p_api_version_number API version number.
 * @param p_init_msg_list Intialize the message array.
 * @param p_commit Commit after processing the transaction.
 * @param p_validation_level Validation Level (FND_API.G_VALID_LEVEL_NONE
 * or FND_API.G_VALID_LEVEL_FULL).
 * @param p_line_tbl A PL/SQL table of product lines to be created. This PL/SQL
 * table is of record type AS_OPPORTUNITY_PUB.line_rec_type defined in the
 * package AS_OPPORTUNITY_PUB.
 * @param p_header_rec Record of the opportunity header to which the purchase
 * lines belong. The record type passed in p_header_rec is defined in the
 * package AS_OPPORTUNITY_PUB.
 * @param p_check_access_flag Check whether the logged in user has privileges
 * to create the opportunity.
 * @param p_admin_flag 'Y' if the logged in user has an administrator role.
 * @param p_admin_group_id Sales group identifier of the logged in user if
 * the user has an administrator role.
 * @param p_identity_salesforce_id Sales force identifier of the logged in user.
 * @param p_salesgroup_id Sales group identifier of the logged in user.
 * @param p_partner_cont_party_id The party identifier of the partner contact
 * if the logged in user is a partner contact.
 * @param p_profile_tbl A PL/SQL table containing profile values. This PL/SQL
 * table is of record type AS_UTILITY_PUB.profile_rec_type defined in the
 * package AS_UTILITY_PUB.
 * @param x_line_out_tbl The identifiers of the created product lines and
 * their statuses. This PL/SQL table is of record type
 * AS_OPPORTUNITY_PUB.line_out_rec_type defined in the package AS_OPPORTUNITY_PUB.
 * @param x_return_status The return status of the API stating Success, Failure or
 * Unexpected Error.
 * @param x_msg_count Number of error messages recorded during processing.
 * @param x_msg_data Contains the text of the message if msg_count = 1.
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:displayname Create Opportunity Lines
 */
PROCEDURE Create_Opp_Lines
(   p_api_version_number        IN     NUMBER,
    p_init_msg_list             IN     VARCHAR2 DEFAULT  FND_API.G_FALSE,
    p_commit                    IN     VARCHAR2 DEFAULT  FND_API.G_FALSE,
    p_validation_level          IN     NUMBER   DEFAULT  FND_API.G_VALID_LEVEL_FULL,
    p_line_tbl              IN     AS_OPPORTUNITY_PUB.Line_Tbl_Type,
    p_header_rec                IN     AS_OPPORTUNITY_PUB.Header_Rec_Type,
    p_check_access_flag         IN     VARCHAR2,
    p_admin_flag            IN     VARCHAR2,
    p_admin_group_id            IN     NUMBER,
    p_identity_salesforce_id    IN     NUMBER,
    p_salesgroup_id     IN     NUMBER   DEFAULT  NULL,
    p_partner_cont_party_id IN     NUMBER,
    p_profile_tbl           IN     AS_UTILITY_PUB.Profile_Tbl_Type
                       DEFAULT AS_UTILITY_PUB.G_MISS_PROFILE_TBL,
    x_line_out_tbl      OUT NOCOPY    Line_Out_Tbl_Type,
    x_return_status             OUT NOCOPY    VARCHAR2,
    x_msg_count                 OUT NOCOPY    NUMBER,
    x_msg_data                  OUT NOCOPY    VARCHAR2);


-- Start of Comments
--
--    API name    : Update_Opp_Lines
--    Type        : Public
--    Function    : Update Opp_Line Information for an Opportunity
--
--
-- Required:    LAST_UPDATE_DATE
--      Lead_Line_Id
--      Lead_Id
--      Interest_Type_Id/Inventory_Item_Id and Organization_Id
--

/*#
 * Updates the product lines for an Opportunity.
 *
 * This procedure performs the following functions:
 * <ul>
 * <li>Checks for user privileges to update product lines.</li>
 * <li>Validates the data in the purchase line table.</li>
 * <li>Updates purchase line records in the AS_LEAD_LINES_ALL table.</li>
 * <li>Updates the opportunity header with the new purchase amount.</li>
 * <li>Sychronizes the forecast information with the new product line
 * amounts for the assigned owner.</li>
 * <li>Performs the territory assignment for the opportunity.</li>
 * </ul>
 *
 * @param p_api_version_number API version number.
 * @param p_init_msg_list Initialize the message array.
 * @param p_commit Commit after processing the transaction.
 * @param p_validation_level Validation Level (FND_API.G_VALID_LEVEL_NONE
 * or FND_API.G_VALID_LEVEL_FULL).
 * @param p_identity_salesforce_id Sales force identifier of the logged in user
 * @param p_line_tbl A PL/SQL table of product lines to be updated.  This PL/SQL
 * table is of record type AS_OPPORTUNITY_PUB.line_rec_type defined in the
 * package AS_OPPORTUNITY_PUB.
 * @param p_header_rec Record of the opportunity header to which the purchase
 * line belongs.  The record type passed in p_header_rec is defined in
 * the package AS_OPPORTUNITY_PUB.
 * @param p_check_access_flag Check whether the logged in user has privileges
 * to update the opportunity.
 * @param p_admin_flag 'Y' if the logged in user has an administrator role.
 * @param p_admin_group_id Sales group identifier of the logged in user if
 * the user has an administrator role.
 * @param p_partner_cont_party_id The party identifier of the partner contact
 * if the logged in user is a partner contact.
 * @param p_profile_tbl A PL/SQL table containing profile values. This PL/SQL
 * table is of record type AS_UTILITY_PUB.profile_rec_type defined in the
 * package AS_UTILITY_PUB.
 * @param x_line_out_tbl The identifiers of the updated product lines and
 * their statuses.  This PL/SQL table is of record type
 * AS_OPPORTUNITY_PUB.line_out_rec_type defined in the package AS_OPPORTUNITY_PUB.
 * @param x_return_status The return status of the API stating Success, Failure or
 * Unexpected Error.
 * @param x_msg_count Number of error messages recorded during processing.
 * @param x_msg_data Contains the text of the message if msg_count = 1.
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:displayname Update Opportunity Lines
 */
PROCEDURE Update_Opp_Lines
(   p_api_version_number        IN    NUMBER,
    p_init_msg_list             IN    VARCHAR2 DEFAULT  FND_API.G_FALSE,
    p_commit                    IN    VARCHAR2 DEFAULT  FND_API.G_FALSE,
    p_validation_level          IN    NUMBER   DEFAULT  FND_API.G_VALID_LEVEL_FULL,
    p_identity_salesforce_id    IN    NUMBER   DEFAULT  NULL,
    p_line_tbl              IN    AS_OPPORTUNITY_PUB.Line_Tbl_Type,
    p_header_rec                IN    AS_OPPORTUNITY_PUB.Header_Rec_Type,
    p_check_access_flag         IN    VARCHAR2,
    p_admin_flag            IN    VARCHAR2,
    p_admin_group_id            IN    NUMBER,
    p_partner_cont_party_id IN    NUMBER,
    p_profile_tbl           IN    AS_UTILITY_PUB.Profile_Tbl_Type
                      DEFAULT AS_UTILITY_PUB.G_MISS_PROFILE_TBL,
    x_line_out_tbl      OUT NOCOPY   Line_Out_Tbl_Type,
    x_return_status             OUT NOCOPY   VARCHAR2,
    x_msg_count                 OUT NOCOPY   NUMBER,
    x_msg_data                  OUT NOCOPY   VARCHAR2);



-- Start of Comments
--
--    API name    : Delete_Opp_Lines
--    Type        : Public
--    Function    : Delete Lines for an Opportunity
--
--

PROCEDURE Delete_Opp_Lines
(   p_api_version_number        IN    NUMBER,
    p_init_msg_list             IN    VARCHAR2 DEFAULT  FND_API.G_FALSE,
    p_commit                    IN    VARCHAR2 DEFAULT  FND_API.G_FALSE,
    p_validation_level          IN    NUMBER   DEFAULT  FND_API.G_VALID_LEVEL_FULL,
    p_identity_salesforce_id    IN    NUMBER   DEFAULT  NULL,
    p_line_tbl              IN    AS_OPPORTUNITY_PUB.Line_Tbl_Type,
    p_header_rec                IN    AS_OPPORTUNITY_PUB.Header_Rec_Type,
    p_check_access_flag         IN    VARCHAR2,
    p_admin_flag            IN    VARCHAR2,
    p_admin_group_id            IN    NUMBER,
    p_partner_cont_party_id IN    NUMBER,
    p_profile_tbl           IN    AS_UTILITY_PUB.Profile_Tbl_Type
                      DEFAULT AS_UTILITY_PUB.G_MISS_PROFILE_TBL,
    x_line_out_tbl      OUT NOCOPY   Line_Out_Tbl_Type,
    x_return_status             OUT NOCOPY   VARCHAR2,
    x_msg_count                 OUT NOCOPY   NUMBER,
    x_msg_data                  OUT NOCOPY   VARCHAR2);


--
-- Create Sales Credits
--
-- Required:
--      Lead_Id
--      Lead_Line_Id
--      Saleforce_Id
--      Credit_Type_Id
--      Credit_Amount/Credit_Percent
--


PROCEDURE Create_Sales_Credits
(   p_api_version_number        IN     NUMBER,
    p_init_msg_list             IN     VARCHAR2 DEFAULT  FND_API.G_FALSE,
    p_commit                    IN     VARCHAR2 DEFAULT  FND_API.G_FALSE,
    p_validation_level          IN     NUMBER   DEFAULT  FND_API.G_VALID_LEVEL_FULL,
    p_identity_salesforce_id    IN     NUMBER   DEFAULT  NULL,
    p_sales_credit_tbl          IN     AS_OPPORTUNITY_PUB.Sales_Credit_Tbl_Type,
    p_check_access_flag         IN     VARCHAR2,
    p_admin_flag            IN     VARCHAR2,
    p_admin_group_id            IN     NUMBER,
    p_partner_cont_party_id     IN     NUMBER,
    p_profile_tbl           IN     AS_UTILITY_PUB.Profile_Tbl_Type
                       DEFAULT AS_UTILITY_PUB.G_MISS_PROFILE_TBL,
    x_sales_credit_out_tbl      OUT NOCOPY    Sales_Credit_Out_Tbl_Type,
    x_return_status             OUT NOCOPY    VARCHAR2,
    x_msg_count                 OUT NOCOPY    NUMBER,
    x_msg_data                  OUT NOCOPY    VARCHAR2);

--
-- Update Sales Credits
--
-- Required:    Last_Update_date
--      Sales_Credit_Id
--      Lead_Id
--      Lead_Line_Id
--      Saleforce_Id
--      Credit_Type_Id
--      Credit_Amount/Credit_Percent
--

PROCEDURE Update_Sales_Credits
(   p_api_version_number        IN     NUMBER,
    p_init_msg_list             IN     VARCHAR2 DEFAULT  FND_API.G_FALSE,
    p_commit                    IN     VARCHAR2 DEFAULT  FND_API.G_FALSE,
    p_validation_level          IN     NUMBER   DEFAULT  FND_API.G_VALID_LEVEL_FULL,
    p_identity_salesforce_id    IN     NUMBER DEFAULT  NULL,
    p_sales_credit_tbl          IN     AS_OPPORTUNITY_PUB.Sales_Credit_Tbl_Type,
    p_check_access_flag         IN     VARCHAR2,
    p_admin_flag            IN     VARCHAR2,
    p_admin_group_id            IN     NUMBER,
    p_partner_cont_party_id     IN     NUMBER,
    p_profile_tbl           IN     AS_UTILITY_PUB.Profile_Tbl_Type
                       DEFAULT AS_UTILITY_PUB.G_MISS_PROFILE_TBL,
    x_sales_credit_out_tbl      OUT NOCOPY    Sales_Credit_Out_Tbl_Type,
    x_return_status             OUT NOCOPY    VARCHAR2,
    x_msg_count                 OUT NOCOPY    NUMBER,
    x_msg_data                  OUT NOCOPY    VARCHAR2);

--
-- Modify Sales Credits
--
-- Required:
--      Lead_Id
--      Lead_Line_Id
--      Saleforce_Id
--      Credit_Type_Id
--      Credit_Amount/Credit_Percent
--
-- Note: This API will perform 100% validation for forecast/revenue credit
--       before insert/update/delete sales credits for opportunity line.
--   The caller need to pass in all the sales credit records
--       under the opportunity line for insert/update. The records
--       which are not passed in will be deleted from the database.
--

PROCEDURE Modify_Sales_Credits
(   p_api_version_number        IN     NUMBER,
    p_init_msg_list             IN     VARCHAR2 DEFAULT  FND_API.G_FALSE,
    p_commit                    IN     VARCHAR2 DEFAULT  FND_API.G_FALSE,
    p_validation_level          IN     NUMBER   DEFAULT  FND_API.G_VALID_LEVEL_FULL,
    p_identity_salesforce_id    IN     NUMBER DEFAULT  NULL,
    p_sales_credit_tbl          IN     AS_OPPORTUNITY_PUB.Sales_Credit_Tbl_Type,
    p_check_access_flag         IN     VARCHAR2,
    p_admin_flag            IN     VARCHAR2,
    p_admin_group_id            IN     NUMBER,
    p_partner_cont_party_id     IN     NUMBER,
    p_profile_tbl           IN     AS_UTILITY_PUB.Profile_Tbl_Type
                       DEFAULT AS_UTILITY_PUB.G_MISS_PROFILE_TBL,
    x_sales_credit_out_tbl      OUT NOCOPY    Sales_Credit_Out_Tbl_Type,
    x_return_status             OUT NOCOPY    VARCHAR2,
    x_msg_count                 OUT NOCOPY    NUMBER,
    x_msg_data                  OUT NOCOPY    VARCHAR2);


--
-- Delete Sales Credits
--

PROCEDURE Delete_Sales_Credits
(   p_api_version_number        IN     NUMBER,
    p_init_msg_list             IN     VARCHAR2 DEFAULT  FND_API.G_FALSE,
    p_commit                    IN     VARCHAR2 DEFAULT  FND_API.G_FALSE,
    p_validation_level          IN     NUMBER   DEFAULT  FND_API.G_VALID_LEVEL_FULL,
    p_identity_salesforce_id    IN     NUMBER DEFAULT  NULL,
    p_sales_credit_tbl          IN     AS_OPPORTUNITY_PUB.Sales_Credit_tbl_Type,
    p_check_access_flag         IN     VARCHAR2,
    p_admin_flag            IN     VARCHAR2,
    p_admin_group_id            IN     NUMBER,
    p_partner_cont_party_id     IN     NUMBER,
    p_profile_tbl           IN     AS_UTILITY_PUB.Profile_Tbl_Type
                       DEFAULT AS_UTILITY_PUB.G_MISS_PROFILE_TBL,
    x_sales_credit_out_tbl      OUT NOCOPY    Sales_Credit_Out_Tbl_Type,
    x_return_status             OUT NOCOPY    VARCHAR2,
    x_msg_count                 OUT NOCOPY    NUMBER,
    x_msg_data                  OUT NOCOPY    VARCHAR2);

--
-- Create Obstacles
--
-- Required:
--      Lead_Id
--      Obstacle_Code
--

PROCEDURE Create_Obstacles
(   p_api_version_number        IN     NUMBER,
    p_init_msg_list             IN     VARCHAR2 DEFAULT  FND_API.G_FALSE,
    p_commit                    IN     VARCHAR2 DEFAULT  FND_API.G_FALSE,
    p_validation_level          IN     NUMBER   DEFAULT  FND_API.G_VALID_LEVEL_FULL,
    p_identity_salesforce_id    IN     NUMBER DEFAULT  NULL,
    p_obstacle_tbl              IN     AS_OPPORTUNITY_PUB.Obstacle_tbl_Type,
    p_check_access_flag         IN     VARCHAR2,
    p_admin_flag            IN     VARCHAR2,
    p_admin_group_id            IN     NUMBER,
    p_partner_cont_party_id     IN     NUMBER,
    p_profile_tbl           IN     AS_UTILITY_PUB.Profile_Tbl_Type
                       DEFAULT AS_UTILITY_PUB.G_MISS_PROFILE_TBL,
    x_obstacle_out_tbl          OUT NOCOPY    Obstacle_Out_Tbl_Type,
    x_return_status             OUT NOCOPY    VARCHAR2,
    x_msg_count                 OUT NOCOPY    NUMBER,
    x_msg_data                  OUT NOCOPY    VARCHAR2);

--
-- Update Obstacles
--
-- Required:    Last_Update_date
--      Lead_Obstacle_Id
--      Lead_Id
--      Obstacle_Code
--

PROCEDURE Update_Obstacles
(   p_api_version_number        IN     NUMBER,
    p_init_msg_list             IN     VARCHAR2 DEFAULT  FND_API.G_FALSE,
    p_commit                    IN     VARCHAR2 DEFAULT  FND_API.G_FALSE,
    p_validation_level          IN     NUMBER   DEFAULT  FND_API.G_VALID_LEVEL_FULL,
    p_identity_salesforce_id    IN     NUMBER DEFAULT  NULL,
    p_obstacle_tbl              IN     AS_OPPORTUNITY_PUB.Obstacle_tbl_Type,
    p_check_access_flag         IN     VARCHAR2,
    p_admin_flag            IN     VARCHAR2,
    p_admin_group_id            IN     NUMBER,
    p_partner_cont_party_id     IN     NUMBER,
    p_profile_tbl           IN     AS_UTILITY_PUB.Profile_Tbl_Type
                       DEFAULT AS_UTILITY_PUB.G_MISS_PROFILE_TBL,
    x_obstacle_out_tbl          OUT NOCOPY    Obstacle_Out_Tbl_Type,
    x_return_status             OUT NOCOPY    VARCHAR2,
    x_msg_count                 OUT NOCOPY    NUMBER,
    x_msg_data                  OUT NOCOPY    VARCHAR2);

--
-- Delete Obstacles
--

PROCEDURE Delete_Obstacles
(   p_api_version_number        IN     NUMBER,
    p_init_msg_list             IN     VARCHAR2 DEFAULT  FND_API.G_FALSE,
    p_commit                    IN     VARCHAR2 DEFAULT  FND_API.G_FALSE,
    p_validation_level          IN     NUMBER   DEFAULT  FND_API.G_VALID_LEVEL_FULL,
    p_identity_salesforce_id    IN     NUMBER DEFAULT  NULL,
    p_obstacle_tbl              IN     AS_OPPORTUNITY_PUB.Obstacle_tbl_Type,
    p_check_access_flag         IN     VARCHAR2,
    p_admin_flag            IN     VARCHAR2,
    p_admin_group_id            IN     NUMBER,
    p_partner_cont_party_id     IN     NUMBER,
    p_profile_tbl           IN     AS_UTILITY_PUB.Profile_Tbl_Type
                       DEFAULT AS_UTILITY_PUB.G_MISS_PROFILE_TBL,
    x_obstacle_out_tbl          OUT NOCOPY    Obstacle_Out_Tbl_Type,
    x_return_status             OUT NOCOPY    VARCHAR2,
    x_msg_count                 OUT NOCOPY    NUMBER,
    x_msg_data                  OUT NOCOPY    VARCHAR2);

--
-- Update Lead Orders
--
-- Required:    Last_Update_date
--      Lead_Order_Id
--      Lead_Id
--      Order_Header_Id
--

PROCEDURE Update_Orders
(   p_api_version_number        IN     NUMBER,
    p_init_msg_list             IN     VARCHAR2 DEFAULT  FND_API.G_FALSE,
    p_commit                    IN     VARCHAR2 DEFAULT  FND_API.G_FALSE,
    p_validation_level          IN     NUMBER   DEFAULT  FND_API.G_VALID_LEVEL_FULL,
    p_identity_salesforce_id    IN     NUMBER   DEFAULT  NULL,
    p_lead_order_tbl            IN     AS_OPPORTUNITY_PUB.Order_tbl_Type,
    p_check_access_flag         IN     VARCHAR2,
    p_admin_flag            IN     VARCHAR2,
    p_admin_group_id            IN     NUMBER,
    p_partner_cont_party_id     IN     NUMBER,
    p_profile_tbl           IN     AS_UTILITY_PUB.Profile_Tbl_Type
                       DEFAULT AS_UTILITY_PUB.G_MISS_PROFILE_TBL,
    x_order_out_tbl         OUT NOCOPY    Order_Out_Tbl_Type,
    x_return_status             OUT NOCOPY    VARCHAR2,
    x_msg_count                 OUT NOCOPY    NUMBER,
    x_msg_data                  OUT NOCOPY    VARCHAR2);

--
-- Delete Lead Orders
--

PROCEDURE Delete_Orders
(   p_api_version_number        IN     NUMBER,
    p_init_msg_list             IN     VARCHAR2 DEFAULT  FND_API.G_FALSE,
    p_commit                    IN     VARCHAR2 DEFAULT  FND_API.G_FALSE,
    p_validation_level          IN     NUMBER   DEFAULT  FND_API.G_VALID_LEVEL_FULL,
    p_identity_salesforce_id    IN     NUMBER   DEFAULT  NULL,
    p_lead_order_tbl            IN     AS_OPPORTUNITY_PUB.Order_tbl_Type,
    p_check_access_flag         IN     VARCHAR2,
    p_admin_flag            IN     VARCHAR2,
    p_admin_group_id            IN     NUMBER,
    p_partner_cont_party_id     IN     NUMBER,
    p_profile_tbl           IN     AS_UTILITY_PUB.Profile_Tbl_Type
                       DEFAULT AS_UTILITY_PUB.G_MISS_PROFILE_TBL,
    x_order_out_tbl         OUT NOCOPY    Order_Out_Tbl_Type,
    x_return_status             OUT NOCOPY    VARCHAR2,
    x_msg_count                 OUT NOCOPY    NUMBER,
    x_msg_data                  OUT NOCOPY    VARCHAR2);

--
-- Create Competitors
--
-- Required:
--      Lead_Id
--      Competitor_Id
--

PROCEDURE Create_Competitors
(   p_api_version_number        IN     NUMBER,
    p_init_msg_list             IN     VARCHAR2 DEFAULT  FND_API.G_FALSE,
    p_commit                    IN     VARCHAR2 DEFAULT  FND_API.G_FALSE,
    p_validation_level          IN     NUMBER   DEFAULT  FND_API.G_VALID_LEVEL_FULL,
    p_identity_salesforce_id    IN     NUMBER   DEFAULT  NULL,
    p_competitor_tbl            IN     AS_OPPORTUNITY_PUB.Competitor_tbl_Type,
    p_check_access_flag         IN     VARCHAR2,
    p_admin_flag            IN     VARCHAR2,
    p_admin_group_id            IN     NUMBER,
    p_partner_cont_party_id     IN     NUMBER,
    p_profile_tbl           IN     AS_UTILITY_PUB.Profile_Tbl_Type
                       DEFAULT AS_UTILITY_PUB.G_MISS_PROFILE_TBL,
    x_competitor_out_tbl        OUT NOCOPY    Competitor_Out_Tbl_Type,
    x_return_status             OUT NOCOPY    VARCHAR2,
    x_msg_count                 OUT NOCOPY    NUMBER,
    x_msg_data                  OUT NOCOPY    VARCHAR2);

--
-- Update Competitors
--
-- Required:    Last_Update_date
--      Lead_Competitor_Id
--      Lead_Id
--      Competitor_Id
--

PROCEDURE Update_Competitors
(   p_api_version_number        IN     NUMBER,
    p_init_msg_list             IN     VARCHAR2 DEFAULT  FND_API.G_FALSE,
    p_commit                    IN     VARCHAR2 DEFAULT  FND_API.G_FALSE,
    p_validation_level          IN     NUMBER   DEFAULT  FND_API.G_VALID_LEVEL_FULL,
    p_identity_salesforce_id    IN     NUMBER   DEFAULT  NULL,
    p_competitor_tbl            IN     AS_OPPORTUNITY_PUB.Competitor_tbl_Type,
    p_check_access_flag         IN     VARCHAR2,
    p_admin_flag            IN     VARCHAR2,
    p_admin_group_id            IN     NUMBER,
    p_partner_cont_party_id     IN     NUMBER,
    p_profile_tbl           IN     AS_UTILITY_PUB.Profile_Tbl_Type
                       DEFAULT AS_UTILITY_PUB.G_MISS_PROFILE_TBL,
    x_competitor_out_tbl        OUT NOCOPY    Competitor_Out_Tbl_Type,
    x_return_status             OUT NOCOPY    VARCHAR2,
    x_msg_count                 OUT NOCOPY    NUMBER,
    x_msg_data                  OUT NOCOPY    VARCHAR2);


PROCEDURE Delete_Competitors
(   p_api_version_number        IN     NUMBER,
    p_init_msg_list             IN     VARCHAR2 DEFAULT  FND_API.G_FALSE,
    p_commit                    IN     VARCHAR2 DEFAULT  FND_API.G_FALSE,
    p_validation_level          IN     NUMBER   DEFAULT  FND_API.G_VALID_LEVEL_FULL,
    p_identity_salesforce_id    IN     NUMBER   DEFAULT  NULL,
    p_competitor_tbl            IN     AS_OPPORTUNITY_PUB.Competitor_tbl_Type,
    p_check_access_flag         IN     VARCHAR2,
    p_admin_flag            IN     VARCHAR2,
    p_admin_group_id            IN     NUMBER,
    p_partner_cont_party_id     IN     NUMBER,
    p_profile_tbl           IN     AS_UTILITY_PUB.Profile_Tbl_Type
                       DEFAULT AS_UTILITY_PUB.G_MISS_PROFILE_TBL,
    x_competitor_out_tbl        OUT NOCOPY    Competitor_Out_Tbl_Type,
    x_return_status             OUT NOCOPY    VARCHAR2,
    x_msg_count                 OUT NOCOPY    NUMBER,
    x_msg_data                  OUT NOCOPY    VARCHAR2);


--
-- Create Competitor_Prods
--
-- Required:
--      Lead_Id
--      Lead_Line_Id
--      Lead_Competitor_Id

PROCEDURE Create_Competitor_Prods
(   p_api_version_number        IN     NUMBER,
    p_init_msg_list             IN     VARCHAR2 DEFAULT  FND_API.G_FALSE,
    p_commit                    IN     VARCHAR2 DEFAULT  FND_API.G_FALSE,
    p_validation_level          IN     NUMBER   DEFAULT  FND_API.G_VALID_LEVEL_FULL,
    p_identity_salesforce_id    IN     NUMBER   DEFAULT  NULL,
    p_competitor_prod_tbl       IN     AS_OPPORTUNITY_PUB.Competitor_Prod_tbl_Type,
    p_check_access_flag         IN     VARCHAR2,
    p_admin_flag            IN     VARCHAR2,
    p_admin_group_id            IN     NUMBER,
    p_partner_cont_party_id     IN     NUMBER,
    p_profile_tbl           IN     AS_UTILITY_PUB.Profile_Tbl_Type
                       DEFAULT AS_UTILITY_PUB.G_MISS_PROFILE_TBL,
    x_competitor_prod_out_tbl   OUT NOCOPY    Competitor_Prod_Out_Tbl_Type,
    x_return_status             OUT NOCOPY    VARCHAR2,
    x_msg_count                 OUT NOCOPY    NUMBER,
    x_msg_data                  OUT NOCOPY    VARCHAR2);

--
-- Update Competitor_Prods
--
-- Required:    Last_Update_date
--      Lead_Competitor_Id
--      Lead_Id
--      Lead_Line_Id
--      Lead_Competitor_Prod_Id
--

PROCEDURE Update_Competitor_Prods
(   p_api_version_number    IN     NUMBER,
    p_init_msg_list         IN     VARCHAR2 DEFAULT  FND_API.G_FALSE,
    p_commit                IN     VARCHAR2 DEFAULT  FND_API.G_FALSE,
    p_validation_level      IN     NUMBER   DEFAULT  FND_API.G_VALID_LEVEL_FULL,
    p_identity_salesforce_id IN    NUMBER   DEFAULT  NULL,
    p_competitor_prod_tbl        IN     AS_OPPORTUNITY_PUB.Competitor_Prod_tbl_Type,
    p_check_access_flag     IN     VARCHAR2,
    p_admin_flag        IN     VARCHAR2,
    p_admin_group_id        IN     NUMBER,
    p_partner_cont_party_id   IN     NUMBER,
    p_profile_tbl       IN     AS_UTILITY_PUB.Profile_Tbl_Type
                   DEFAULT AS_UTILITY_PUB.G_MISS_PROFILE_TBL,
    x_competitor_prod_out_tbl    OUT NOCOPY    Competitor_Prod_Out_Tbl_Type,
    x_return_status         OUT NOCOPY    VARCHAR2,
    x_msg_count             OUT NOCOPY    NUMBER,
    x_msg_data              OUT NOCOPY    VARCHAR2);


PROCEDURE Delete_Competitor_Prods
(   p_api_version_number        IN     NUMBER,
    p_init_msg_list             IN     VARCHAR2 DEFAULT  FND_API.G_FALSE,
    p_commit                    IN     VARCHAR2 DEFAULT  FND_API.G_FALSE,
    p_validation_level          IN     NUMBER   DEFAULT  FND_API.G_VALID_LEVEL_FULL,
    p_identity_salesforce_id    IN     NUMBER   DEFAULT  NULL,
    p_competitor_prod_tbl       IN     AS_OPPORTUNITY_PUB.Competitor_Prod_tbl_Type,
    p_check_access_flag         IN     VARCHAR2,
    p_admin_flag            IN     VARCHAR2,
    p_admin_group_id            IN     NUMBER,
    p_partner_cont_party_id     IN     NUMBER,
    p_profile_tbl           IN     AS_UTILITY_PUB.Profile_Tbl_Type
                       DEFAULT AS_UTILITY_PUB.G_MISS_PROFILE_TBL,
    x_competitor_prod_out_tbl   OUT NOCOPY    Competitor_Prod_Out_Tbl_Type,
    x_return_status             OUT NOCOPY    VARCHAR2,
    x_msg_count                 OUT NOCOPY    NUMBER,
    x_msg_data                  OUT NOCOPY    VARCHAR2);


--
-- Create Decision_Factors
--
-- Required:
--      Lead_Id
--      Lead_Line_Id
--

PROCEDURE Create_Decision_Factors
(   p_api_version_number        IN     NUMBER,
    p_init_msg_list             IN     VARCHAR2 DEFAULT  FND_API.G_FALSE,
    p_commit                    IN     VARCHAR2 DEFAULT  FND_API.G_FALSE,
    p_validation_level          IN     NUMBER   DEFAULT  FND_API.G_VALID_LEVEL_FULL,
    p_identity_salesforce_id    IN     NUMBER   DEFAULT  NULL,
    p_decision_factor_tbl       IN     AS_OPPORTUNITY_PUB.Decision_Factor_tbl_Type,
    p_check_access_flag         IN     VARCHAR2,
    p_admin_flag            IN     VARCHAR2,
    p_admin_group_id            IN     NUMBER,
    p_partner_cont_party_id     IN     NUMBER,
    p_profile_tbl           IN     AS_UTILITY_PUB.Profile_Tbl_Type
                       DEFAULT AS_UTILITY_PUB.G_MISS_PROFILE_TBL,
    x_decision_factor_out_tbl   OUT NOCOPY    Decision_Factor_Out_Tbl_Type,
    x_return_status             OUT NOCOPY    VARCHAR2,
    x_msg_count                 OUT NOCOPY    NUMBER,
    x_msg_data                  OUT NOCOPY    VARCHAR2);

--
-- Update Decision_Factors
--
-- Required:    Last_Update_date
--      Lead_Decision_Factor_Id
--      Lead_Id
--      Lead_Line_Id

--

PROCEDURE Update_Decision_Factors
(   p_api_version_number        IN     NUMBER,
    p_init_msg_list             IN     VARCHAR2 DEFAULT  FND_API.G_FALSE,
    p_commit                    IN     VARCHAR2 DEFAULT  FND_API.G_FALSE,
    p_validation_level          IN     NUMBER   DEFAULT  FND_API.G_VALID_LEVEL_FULL,
    p_identity_salesforce_id    IN     NUMBER   DEFAULT  NULL,
    p_decision_factor_tbl       IN     AS_OPPORTUNITY_PUB.Decision_Factor_tbl_Type,
    p_check_access_flag         IN     VARCHAR2,
    p_admin_flag            IN     VARCHAR2,
    p_admin_group_id            IN     NUMBER,
    p_partner_cont_party_id     IN     NUMBER,
    p_profile_tbl           IN     AS_UTILITY_PUB.Profile_Tbl_Type
                       DEFAULT AS_UTILITY_PUB.G_MISS_PROFILE_TBL,
    x_decision_factor_out_tbl   OUT NOCOPY    Decision_Factor_Out_Tbl_Type,
    x_return_status             OUT NOCOPY    VARCHAR2,
    x_msg_count                 OUT NOCOPY    NUMBER,
    x_msg_data                  OUT NOCOPY    VARCHAR2);


PROCEDURE Delete_Decision_Factors
(   p_api_version_number        IN     NUMBER,
    p_init_msg_list             IN     VARCHAR2 DEFAULT  FND_API.G_FALSE,
    p_commit                    IN     VARCHAR2 DEFAULT  FND_API.G_FALSE,
    p_validation_level          IN     NUMBER   DEFAULT  FND_API.G_VALID_LEVEL_FULL,
    p_identity_salesforce_id    IN     NUMBER   DEFAULT  NULL,
    p_decision_factor_tbl       IN     AS_OPPORTUNITY_PUB.Decision_Factor_tbl_Type,
    p_check_access_flag         IN     VARCHAR2,
    p_admin_flag            IN     VARCHAR2,
    p_admin_group_id            IN     NUMBER,
    p_partner_cont_party_id     IN     NUMBER,
    p_profile_tbl           IN     AS_UTILITY_PUB.Profile_Tbl_Type
                       DEFAULT AS_UTILITY_PUB.G_MISS_PROFILE_TBL,
    x_decision_factor_out_tbl   OUT NOCOPY    Decision_Factor_Out_Tbl_Type,
    x_return_status             OUT NOCOPY    VARCHAR2,
    x_msg_count                 OUT NOCOPY    NUMBER,
    x_msg_data                  OUT NOCOPY    VARCHAR2);



--
-- Create Contacts
--
-- Required:
--      Lead_Id
--      Customer_Id
--      Contact_Party_Id
--      Enabled_Flag
--

PROCEDURE Create_Contacts
(   p_api_version_number        IN     NUMBER,
    p_init_msg_list             IN     VARCHAR2 DEFAULT  FND_API.G_FALSE,
    p_commit                    IN     VARCHAR2 DEFAULT  FND_API.G_FALSE,
    p_validation_level          IN     NUMBER   DEFAULT  FND_API.G_VALID_LEVEL_FULL,
    p_identity_salesforce_id    IN     NUMBER DEFAULT  NULL,
    p_contact_tbl               IN     AS_OPPORTUNITY_PUB.Contact_tbl_Type,
    p_header_rec                IN     HEADER_REC_TYPE DEFAULT  G_MISS_HEADER_REC,
    p_check_access_flag         IN     VARCHAR2,
    p_admin_flag            IN     VARCHAR2,
    p_admin_group_id            IN     NUMBER,
    p_partner_cont_party_id     IN     NUMBER,
    p_profile_tbl           IN     AS_UTILITY_PUB.Profile_Tbl_Type
                       DEFAULT AS_UTILITY_PUB.G_MISS_PROFILE_TBL,
    x_contact_out_tbl           OUT NOCOPY    Contact_Out_Tbl_Type,
    x_return_status             OUT NOCOPY    VARCHAR2,
    x_msg_count                 OUT NOCOPY    NUMBER,
    x_msg_data                  OUT NOCOPY    VARCHAR2);


--
-- Update Contacts
--
-- Required:    Last_Update_date
--      Lead_Contact_Id
--      Lead_Id
--      Customer_Id
--      Contact_Party_Id
--      Enabled_Flag
--

PROCEDURE Update_Contacts
(   p_api_version_number        IN     NUMBER,
    p_init_msg_list             IN     VARCHAR2 DEFAULT  FND_API.G_FALSE,
    p_commit                    IN     VARCHAR2 DEFAULT  FND_API.G_FALSE,
    p_validation_level          IN     NUMBER   DEFAULT  FND_API.G_VALID_LEVEL_FULL,
    p_identity_salesforce_id    IN     NUMBER DEFAULT  NULL,
    p_contact_tbl               IN     AS_OPPORTUNITY_PUB.Contact_tbl_Type,
    p_check_access_flag         IN     VARCHAR2,
    p_admin_flag            IN     VARCHAR2,
    p_admin_group_id            IN     NUMBER,
    p_partner_cont_party_id     IN     NUMBER,
    p_profile_tbl           IN     AS_UTILITY_PUB.Profile_Tbl_Type
                       DEFAULT AS_UTILITY_PUB.G_MISS_PROFILE_TBL,
    x_contact_out_tbl           OUT NOCOPY    Contact_Out_Tbl_Type,
    x_return_status             OUT NOCOPY    VARCHAR2,
    x_msg_count                 OUT NOCOPY    NUMBER,
    x_msg_data                  OUT NOCOPY    VARCHAR2);

--
-- Delete Contacts
--

PROCEDURE Delete_Contacts
(   p_api_version_number        IN     NUMBER,
    p_init_msg_list             IN     VARCHAR2 DEFAULT  FND_API.G_FALSE,
    p_commit                    IN     VARCHAR2 DEFAULT  FND_API.G_FALSE,
    p_validation_level          IN     NUMBER   DEFAULT  FND_API.G_VALID_LEVEL_FULL,
    p_identity_salesforce_id    IN     NUMBER DEFAULT  NULL,
    p_contact_tbl               IN     AS_OPPORTUNITY_PUB.Contact_tbl_Type,
    p_check_access_flag         IN     VARCHAR2,
    p_admin_flag            IN     VARCHAR2,
    p_admin_group_id            IN     NUMBER,
    p_partner_cont_party_id     IN     NUMBER,
    p_profile_tbl           IN     AS_UTILITY_PUB.Profile_Tbl_Type
                       DEFAULT AS_UTILITY_PUB.G_MISS_PROFILE_TBL,
    x_contact_out_tbl           OUT NOCOPY    Contact_Out_Tbl_Type,
    x_return_status             OUT NOCOPY    VARCHAR2,
    x_msg_count                 OUT NOCOPY    NUMBER,
    x_msg_data                  OUT NOCOPY    VARCHAR2);


--
-- Delete Sales Teams
--

PROCEDURE Delete_SalesTeams
(       p_api_version_number        IN      NUMBER,
        p_init_msg_list                 IN      VARCHAR2    DEFAULT  FND_API.G_FALSE,
        p_commit                        IN      VARCHAR2    DEFAULT  FND_API.G_FALSE,
        p_validation_level          IN      NUMBER   DEFAULT  FND_API.G_VALID_LEVEL_FULL,
        p_sales_team_tbl                IN      AS_ACCESS_PUB.SALES_TEAM_TBL_TYPE,
        p_check_access_flag         IN  VARCHAR2,
        p_admin_flag                IN  VARCHAR2,
        p_admin_group_id            IN  NUMBER,
        p_identity_salesforce_id    IN  NUMBER,
        p_partner_cont_party_id     IN      NUMBER,
        p_profile_tbl               IN      AS_UTILITY_PUB.Profile_Tbl_Type
                        DEFAULT AS_UTILITY_PUB.G_MISS_PROFILE_TBL,
        x_return_status                 OUT NOCOPY     VARCHAR2,
        x_msg_count                     OUT NOCOPY     NUMBER,
        x_msg_data                      OUT NOCOPY     VARCHAR2
);


-- Start of Comments
--
--    API name:     Copy_Opportunity
--    Type:         Public.
--
--    Function:     To copy an existing opportunity header with/without
--          the salesteam, opportunity lines, sales_credits, contacts
--          and competitors
--
--    Note:     1. If the p_sales_credits = FND_API.G_TRUE then
--                     the p_opp_lines must be FND_API.G_TRUE.
--          2. If the p_copy_salesteam is FALSE the salesteam
--                     will be defaulted as in creating a new opportunity.
--          3. If the p_copy_sales_credit is FALSE then the
--                     the sales credits will be defaulted 100% to the
--                     logon salesforce.
--
--
--    Parameter specifications:
--      p_lead_id       - which opportunity you want to copy from
--      p_description           - name of opportunity
--      p_copy_salesteam        - whether to copy the sales team
--      p_copy_opp_lines    - whether to copy the opportunity lines
--      p_copy_lead_contacts    - whether to copy the opportunity contacts
--  p_copy_lead_competitors - whether to copy the opportunity competitors
--      p_copy_sales_credits    - whether to copy the sales credits
--      p_copy_methodology  - whether to copy the sales methodology
--      p_new_customer_id   - the customer identifier of the new opportunity
--      p_new_address_id        - the customer address identifier of the new
--                opportunity
--
-- End of Comments

PROCEDURE Copy_Opportunity
(   p_api_version_number            IN    NUMBER,
    p_init_msg_list                 IN    VARCHAR2      DEFAULT FND_API.G_FALSE,
    p_commit                        IN    VARCHAR2      DEFAULT FND_API.G_FALSE,
    p_validation_level              IN    NUMBER    DEFAULT FND_API.G_VALID_LEVEL_FULL,
    p_lead_id                       IN    NUMBER,
    p_description                   IN    VARCHAR2,
    p_copy_salesteam            IN    VARCHAR2  DEFAULT FND_API.G_FALSE,
    p_copy_opp_lines            IN    VARCHAR2  DEFAULT FND_API.G_FALSE,
    p_copy_lead_contacts            IN    VARCHAR2  DEFAULT FND_API.G_FALSE,
    p_copy_lead_competitors         IN    VARCHAR2  DEFAULT FND_API.G_FALSE,
    p_copy_sales_credits        IN    VARCHAR2  DEFAULT FND_API.G_FALSE,
    p_copy_methodology              IN    VARCHAR2      DEFAULT FND_API.G_FALSE,
    p_new_customer_id           IN    NUMBER,
    p_new_address_id            IN    NUMBER,
    p_check_access_flag             IN    VARCHAR2,
    p_admin_flag                IN    VARCHAR2,
    p_admin_group_id                IN    NUMBER,
    p_identity_salesforce_id        IN    NUMBER,
    p_salesgroup_id         IN    NUMBER        DEFAULT  NULL,
    p_partner_cont_party_id     IN    NUMBER,
    p_profile_tbl               IN    AS_UTILITY_PUB.Profile_Tbl_Type
                      DEFAULT AS_UTILITY_PUB.G_MISS_PROFILE_TBL,
    x_return_status                 OUT NOCOPY   VARCHAR2,
    x_msg_count                     OUT NOCOPY   NUMBER,
    x_msg_data                      OUT NOCOPY   VARCHAR2,
    x_lead_id                       OUT NOCOPY   NUMBER
);


--
-- Get Access Profiles
--
-- This procedure gets profile values from profile table type
-- and output access profile record type.
--
-- This procedure is used by internal private APIs where input
-- parameter is profile table type and need to call check access
-- APIs.
--

PROCEDURE Get_Access_Profiles(
    p_profile_tbl           IN  AS_UTILITY_PUB.Profile_Tbl_Type,
    x_access_profile_rec        OUT NOCOPY AS_ACCESS_PUB.Access_Profile_Rec_Type
);

--
-- Get Profiles
--
-- This function get profile value from profile table type
-- and return the value for the input profile name.
--
-- If profile name is not found in profile table or
-- profile value is NULL or FND_API.G_MISS_CHAR
-- then the function return NULL
--

FUNCTION Get_Profile(
    p_profile_tbl           IN  AS_UTILITY_PUB.Profile_Tbl_Type,
    p_profile_name          IN  VARCHAR2 )
RETURN VARCHAR2;


END AS_OPPORTUNITY_PUB;

 

/
