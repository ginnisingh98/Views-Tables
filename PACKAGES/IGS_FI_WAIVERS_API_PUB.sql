--------------------------------------------------------
--  DDL for Package IGS_FI_WAIVERS_API_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IGS_FI_WAIVERS_API_PUB" AUTHID CURRENT_USER AS
/* $Header: IGSFI94S.pls 120.1 2006/01/17 02:43:13 svuppala noship $ */
/*#
 * The Import Waives API is a public API used externally to create waivers.
 * @rep:scope public
 * @rep:product IGS
 * @rep:displayname Import Manual Waivers
 * @rep:lifecycle active
 * @rep:compatibility S
 * @rep:category BUSINESS_ENTITY IGS_PARTY_CREDIT
 * @rep:category BUSINESS_ENTITY IGS_PARTY_CHARGE
 */

------------------------------------------------------------------
--Created by  : Sanil Madathil, Oracle IDC
--Date created: 29 July 2005
--
--Purpose: Public Waiver API
--
--
--Known limitations/enhancements and/or remarks:
--
--Change History:
--Who         When            What
-- svuppala   9-Jan-2006    R12 iRep Annotation - added annotation
------------------------------------------------------------------

-- Start of comments
--      API name        : CREATE_MANUAL_WAIVERS
--      Type            : Public
--      Pre-reqs        : None.
--      Function        : New Public API to extend the flexibility to the user for importing
--                        manual waiver credit transactions and waiver adjustment charges against
--                        the waiver credits that are imported by this API.
--      Parameters      :
--      IN              : p_api_version        IN NUMBER       Required
--                        This standard API parameter is used to compare the version numbers of
--                        incoming calls to its current version number.
--
--                        p_init_msg_list      IN VARCHAR2     Optional Default FND_API.G_FALSE
--                        Standard API Parameter for initialization of the message list.
--
--                        p_commit             IN VARCHAR2     Optional Default FND_API.G_FALSE
--                        Standard API Parameter to indicate if the transactions have to commit explicitly or not
--
--                        p_fee_cal_type       IN VARCHAR2      Required
--                        Fee Calendar Type associated with Waiver program
--
--                        p_fee_ci_seq_number  IN NUMBER        Required
--                        Fee Calendar Sequence Number associated with Waiver program
--
--                        p_waiver_name        IN VARCHAR2      Required
--                        Waiver program Name
--
--                        p_person_id           IN NUMBER        Required
--                        Person Id for which waiver transaction would be created
--
--                        p_waiver_amount       IN NUMBER        Required
--                        Waiver Amount for which waiver transaction is being created
--
--                        p_currency_cd         IN VARCHAR2      Required
--                        Currency Code
--
--                        p_exchange_rate       IN NUMBER        Required
--                        Exchange Rate
--
--                        p_gl_date              IN  Date         Required
--                        GL Date for creating the waiver transactions
--
--                        p_source_credit_id     IN NUMBER        Optional
--                        Credit id of the source waiver credit transaction. This value
--                        would need to be provided for creating a waiver adjustment charge
--
--      OUT             : x_return_status        OUT VARCHAR2
--                        This Standard API Out parameter returns the overall status of waiver
--                        processing performed by API. Valid values are 'S' (Success), 'E' (Error) and
--                        'U' (Unexpected error)
--
--                      : x_msg_count            OUT NUMBER
--                        This Standard API Out parameter returns number of messages in the message list
--
--                      : x_msg_data             OUT VARCHAR2
--                        This Standard API Out parameter returns the actual message in the encoded format
--
--                      : x_waiver_credit_id     OUT NUMBER
--                        This parameter returns the waiver credit id generated. This value would be
--                        NULL if user requires to create a waiver adjustment charge
--
--                      : x_waiver_adjustment_id  OUT NUMBER
--                        This parameter returns the waiver adjustment charge id generated. This
--                        value would be NULL if  user requires to create a waiver credit
--
--      Version         : Current version       1.0
--                        Initial version       1.0
-- End of comments


/*#
 * The Import Waives API is a public API used externally to create waivers.
 * @param p_API_VERSION API Version Number
 * @param p_INIT_MSG_LIST Initialize Message List
 * @param p_COMMIT Commit Transaction
 * @param p_FEE_CAL_TYPE Fee Calendar Type
 * @param p_FEE_CI_SEQ_NUMBER Fee Calendar Instance Sequence Number
 * @param p_WAIVER_NAME Waiver Name
 * @param p_PERSON_ID Person Identifier
 * @param p_WAIVER_AMOUNT Waiver Amount
 * @param p_CURRENCY_CD Currency Code
 * @param p_EXCHANGE_RATE Exchange Rate
 * @param p_GL_DATE GL Date
 * @param p_SOURCE_CREDIT_ID Source Credit Identifier
 * @param X_WAIVER_CREDIT_ID Waiver Credit Identifier
 * @param X_WAIVER_ADJUSTMENT_ID Waiver Adjustment Identifier
 * @param X_RETURN_STATUS Return Status
 * @param X_MSG_COUNT Message Count
 * @param X_MSG_DATA Message Data
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:displayname Import Manual Waivers
 */
 PROCEDURE create_manual_waivers(
  p_api_version           IN           NUMBER                                                ,
  p_init_msg_list         IN           VARCHAR2      := fnd_api.g_false                      ,
  p_commit                IN           VARCHAR2      := fnd_api.g_false                      ,
  x_return_status         OUT  NOCOPY  VARCHAR2                                              ,
  x_msg_count             OUT  NOCOPY  NUMBER                                                ,
  x_msg_data              OUT  NOCOPY  VARCHAR2                                              ,
  p_fee_cal_type          IN           igs_ca_inst_all.cal_type%TYPE                         ,
  p_fee_ci_seq_number     IN           igs_ca_inst_all.sequence_number%TYPE                  ,
  p_waiver_name           IN           igs_fi_waiver_pgms.waiver_name%TYPE                   ,
  p_person_id             IN           igs_fi_credits_all.party_id%TYPE                      ,
  p_waiver_amount         IN           igs_fi_credits_all.amount%TYPE                        ,
  p_currency_cd           IN           igs_fi_credits_all.currency_cd%TYPE                   ,
  p_exchange_rate         IN           igs_fi_credits_all.exchange_rate%TYPE                 ,
  p_gl_date               IN           igs_fi_credits_all.gl_date%TYPE                       ,
  p_source_credit_id      IN           igs_fi_credits_all.credit_id%TYPE        := NULL      ,
  x_waiver_credit_id      OUT  NOCOPY  NUMBER                                                ,
  x_waiver_adjustment_id  OUT  NOCOPY  NUMBER
);

END igs_fi_waivers_api_pub;

 

/
