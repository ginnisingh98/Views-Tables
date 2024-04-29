--------------------------------------------------------
--  DDL for Package HZ_DUP_MERGE_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."HZ_DUP_MERGE_PUB" AUTHID CURRENT_USER AS
/*$Header: ARHBCMBS.pls 120.1 2006/09/21 23:16:07 awu noship $ */
/*#
 *Create Merge Request API
 *Public API that creates a merge request in Oracle Data Librarian. A merge request contains the
 *details of a party or parties that are considered similar and potential candidates for merge.
 *
 * @rep:scope public
 * @rep:product HZ
 * @rep:lifecycle active
 * @rep:category BUSINESS_ENTITY HZ_PARTY
 * @rep:displayname Create Merge Request API
 * @rep:doccd 120hztig.pdf Data Quality Management Availability APIs, Oracle Trading Community Architecture Technical Implementation Guide
 */


  -- PROCEDURE create_dup_merge_request
  --
  -- DESCRIPTION
  --     Create merge request for duplicate parties
  --
  -- EXTERNAL PROCEDURES/FUNCTIONS ACCESSED
  --
  -- ARGUMENTS
  --   IN:
  --  p_init_msg_list  	Standard IN parameter to initialize message stack.
  --  p_dup_id_objs  	An object table of duplicate party ids.
  --  p_note_text   	note for the merge request
  --
  --   OUT:
  --     x_return_status      Return status after the call. The status can
  --                          be fnd_api.g_ret_sts_success (success),
  --                          fnd_api.g_ret_sts_error (error),
  --                          FND_API.G_RET_STS_UNEXP_ERROR (unexpected error).
  --     x_msg_count          Number of messages in message stack.
  --     x_msg_data           Message text if x_msg_count is 1.
  --     x_merge_request_id   merge request id
  --
  -- NOTES
  --
  -- MODIFICATION HISTORY
  --
  --   10-JAN-2006   AWU          Created.

/*#
 *Creates a merge request in Oracle Data Librarian. A merge request contains the details
 *of a party or parties that are considered similar and potential candidates for merge. To
 *successfully call this API, pass a list of duplicate party IDs or source system
 *management mappings, and optionally some note text.
 *
 * @param p_init_msg_list Indicates if the message stack is initialized.Default value: FND_API.G_FALSE.
 * @param p_dup_id_objs The PL/SQL table of records structure that has the duplicate party ID information.
 * @param p_note_text Note text for the merge request.
 * @param x_return_status A code indicating whether any errors occurred during processing.
 * @param x_msg_count Indicates how many messages exist on the message stack upon completion of processing.
 * @param x_msg_data If exactly one message exists on the message stack upon completion of processing, then this parameter contains that message.
 * @param x_merge_request_id Indicates the merge request.
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:category BUSINESS_ENTITY HZ_PARTY
 * @rep:displayname Create Merge Request API
 * @rep:doccd 120hztig.pdf Data Quality Management Availability APIs, Oracle Trading Community Architecture Technical Implementation Guide
 */

PROCEDURE create_dup_merge_request(
  p_init_msg_list       IN            VARCHAR2 := fnd_api.g_false,
  p_dup_id_objs    	IN            HZ_DUP_ID_OBJ_TBL,
  p_note_text           IN            VARCHAR2,
  x_return_status       OUT NOCOPY    VARCHAR2,
  x_msg_count           OUT NOCOPY    NUMBER,
  x_msg_data            OUT NOCOPY    VARCHAR2,
  x_merge_request_id           OUT NOCOPY    NUMBER
);

END HZ_DUP_MERGE_PUB;

 

/
