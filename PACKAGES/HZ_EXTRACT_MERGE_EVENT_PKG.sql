--------------------------------------------------------
--  DDL for Package HZ_EXTRACT_MERGE_EVENT_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."HZ_EXTRACT_MERGE_EVENT_PKG" AUTHID CURRENT_USER AS
/*$Header: ARHMEVTS.pls 120.3.12010000.2 2009/02/04 08:08:48 vsegu ship $ */
/*#
 * Get Merge Details API
 * @rep:scope public
 * @rep:product HZ
 * @rep:lifecycle active
 * @rep:category BUSINESS_ENTITY HZ_PARTY
 * @rep:displayname Get Merge Details API
 * @rep:doccd 120hztig.pdf Data Quality Management Availability APIs, Oracle Trading Community Architecture Technical Implementation Guide
 */

FUNCTION get_object_type(
   p_table_name           IN     VARCHAR2,
   p_table_id             IN     NUMBER
) RETURN VARCHAR2;

FUNCTION get_operating_unit( p_org_id NUMBER)
RETURN VARCHAR2;

/*#
 *Get Account Merge Details API finds the details of a particular account merge by passing
 *in the customer merge header ID, which is raised from the merge event. The account merge
 *object is then extracted, which contains customer merge ID, request ID and the associated
 *party info, merge-to account ID, account number, account name,and source system management
 * mappings for all accounts involved in the merge.
 * @param p_init_msg_list Indicates if the message stack is initialized.Default value: FND_API.G_FALSE.
 * @param p_customer_merge_header_id Indicates the customer merge header numbers.
 * @param x_account_merge_obj The PL/SQL table of records structure that has the account merge result information.
 * @param x_return_status A code indicating whether any errors occurred during processing.
 * @param x_msg_count Indicates how many messages exist on the message stack upon completion of processing.
 * @param x_msg_data If exactly one message exists on the message stack upon completion of processing, then this parameter contains that message.
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:category BUSINESS_ENTITY HZ_PARTY
 * @rep:displayname Get Account Merge Details API
 * @rep:doccd 120hztig.pdf Data Quality Management Availability APIs, Oracle Trading Community Architecture Technical Implementation Guide
 */

PROCEDURE get_account_merge_event_data(
    p_init_msg_list               IN            VARCHAR2 := fnd_api.g_false,
    p_customer_merge_header_id    IN           	NUMBER,
    x_account_merge_obj           OUT NOCOPY    HZ_ACCT_MERGE_OBJ,
    x_return_status       	  OUT NOCOPY    VARCHAR2,
    x_msg_count           	  OUT NOCOPY    NUMBER,
    x_msg_data            	  OUT NOCOPY    VARCHAR2
  );

/*#
 *Get Account Merge Details API finds the details of a particular account merge by passing
 *in the customer merge header ID, which is raised from the merge event. The account merge
 *object is then extracted, which contains customer merge ID, request ID and the associated
 *party info, merge-to account ID, account number, account name,and source system management
 * mappings for all accounts and for all entities involved in the merge.
 * @param p_init_msg_list Indicates if the message stack is initialized.Default value: FND_API.G_FALSE.
 * @param p_customer_merge_header_id Indicates the customer merge header numbers.
 * @param p_get_merge_detail_flag Indicates if historical Merge To and Merge From account details and their
 * associated Source System Mapping details will be retrieved as part of the object
 * @param x_account_merge_v2_obj The PL/SQL table of records structure that has the account merge result information.
 * @param x_return_status A code indicating whether any errors occurred during processing.
 * @param x_msg_count Indicates how many messages exist on the message stack upon completion of processing.
 * @param x_msg_data If exactly one message exists on the message stack upon completion of processing,
 *                   then this parameter contains that message.
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:category BUSINESS_ENTITY HZ_PARTY
 * @rep:displayname Get Account Merge Details API
 * @rep:doccd 120hztig.pdf Data Quality Management Availability APIs, Oracle Trading Community Architecture Technical
 *      Implementation Guide
 */

 PROCEDURE get_account_merge_event_data(
    p_init_msg_list       	IN            VARCHAR2 := fnd_api.g_false,
    p_customer_merge_header_id  IN            NUMBER,
    p_get_merge_detail_flag     IN            VARCHAR2 := 'N',
    x_account_merge_v2_obj      OUT NOCOPY    HZ_ACCOUNT_MERGE_V2_OBJ,
    x_return_status       	OUT NOCOPY    VARCHAR2,
    x_msg_count           	OUT NOCOPY    NUMBER,
    x_msg_data            	OUT NOCOPY    VARCHAR2);


/*#
 * Get Party Merge Details API finds the details of a particular party merge
 * by passing in the merge batch ID and the master party ID from the merge event.
 * The party merge object is then extracted, containing the batch name, merge type,
 * automerge flag value, master party ID and the party numbers, names, and types and
 * source system management mappings for all parties involved in the merge.
 * @param p_init_msg_list Indicates if the message stack is initialized.Default value: FND_API.G_FALSE.
 * @param p_batch_id Indicates the party merge batch identifier.
 * @param p_merge_to_party_id Indicates the master party identifier.
 * @param p_get_merge_detail_flag Indicates if historical Merge To and Merge From party details from the HZ_Merge_Party_History table and their associated Source System Mapping details will be retrieved as part of the object.
 * @param x_party_merge_obj The PL/SQL table of records structure that has the party merge result information.
 * @param x_return_status A code indicating whether any errors occurred during processing.
 * @param x_msg_count Indicates how many messages exist on the message stack upon completion of processing.
 * @param x_msg_data If exactly one message exists on the message stack upon completion of processing, then this parameter contains that message.
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:category BUSINESS_ENTITY HZ_PARTY
 * @rep:displayname Get Party Merge Details API
 * @rep:doccd 120hztig.pdf Data Quality Management Availability APIs, Oracle Trading Community Architecture Technical Implementation Guide
 */

PROCEDURE get_party_merge_event_data(

    p_init_msg_list       IN            VARCHAR2 := fnd_api.g_false,
    p_batch_id            IN           	NUMBER,
    p_merge_to_party_id   IN		NUMBER,
    p_get_merge_detail_flag IN          VARCHAR2 := 'N',     --5093366
    x_party_merge_obj     OUT NOCOPY    HZ_PARTY_MERGE_OBJ,
    x_return_status       OUT NOCOPY    VARCHAR2,
    x_msg_count           OUT NOCOPY    NUMBER,
    x_msg_data            OUT NOCOPY    VARCHAR2
  );
END HZ_EXTRACT_MERGE_EVENT_PKG;

/
