--------------------------------------------------------
--  DDL for Package JTF_RS_IMPORT_USER_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."JTF_RS_IMPORT_USER_PUB" AUTHID CURRENT_USER AS
  /* $Header: jtfrsius.pls 115.5 2004/06/25 18:15:47 baianand ship $ */
/*#
 * This package contains procedures to create resources by
 * importing employee information stored in jtf_rs_upload_data table
 * @rep:scope private
 * @rep:product JTF
 * @rep:displayname Import Users Package
 * @rep:category BUSINESS_ENTITY JTF_RS_RESOURCE
 * @rep:category BUSINESS_ENTITY JTF_RS_GROUP_MEMBER
 */


  /*****************************************************************************************
   ******************************************************************************************/

  /* Package variables. */

  G_PKG_NAME         VARCHAR2(30) := 'JTF_RS_IMPORT_USER_PUB';

/*#
 * This procedure imports in bulk. It takes all records from
 * jtf_rs_upload_data table for a transaction and tries to
 * import them into resources.
 * @param ERRBUF output parameter containg errors
 * @param RETCODE output parameter containing return status
 * @param P_TRANSACTION_NO Transation number indicating the unique batch data in
 *                         jtf_rs_upload_data.
 * @rep:scope private
 * @rep:displayname Import Users
 */
PROCEDURE crt_bulk_import (
    ERRBUF              OUT NOCOPY VARCHAR2,
    RETCODE             OUT NOCOPY VARCHAR2,
    P_TRANSACTION_NO    IN   NUMBER);

/*#
 * This procedure starts concurrent request for
 * importing records from jtf_rs_upload_data table for a transaction,
 * into resources.
 * @param P_API_VERSION  API version number
 * @param P_INIT_MSG_LIST Flag to start with clearing messages from database
 * @param P_COMMIT Flag to commit at the end of the procedure
 * @param P_TRANSACTION_NO Transation number indicating the unique batch data in
 *                         jtf_rs_upload_data.
 * @param P_REQUEST_NO Output parameter for concurrent request number
 * @param X_RETURN_STATUS Output parameter for return status
 * @param X_MSG_COUNT Output parameter for number of user messages from this procedure
 * @param X_MSG_DATA Output parameter containing last user message from this procedure
 * @rep:scope private
 * @rep:displayname Start Import User Concurrent Request
 */
PROCEDURE  import_user
   (P_API_VERSION          IN   NUMBER,
    P_INIT_MSG_LIST        IN   VARCHAR2   DEFAULT  FND_API.G_FALSE,
    P_COMMIT               IN   VARCHAR2   DEFAULT  FND_API.G_FALSE,
    P_TRANSACTION_NO       IN   JTF_RS_UPLOAD_DATA.TRANSACTION_NO%TYPE,
    P_REQUEST_NO           OUT NOCOPY  NUMBER,
    X_RETURN_STATUS        OUT NOCOPY  VARCHAR2,
    X_MSG_COUNT            OUT NOCOPY  NUMBER,
    X_MSG_DATA             OUT NOCOPY  VARCHAR2
  );

/*#
 * Procedure to update the import status and error information for a
 * record in jtf_rs_upload_data table.
 * @param P_TRANSACTION_NO Transation number indicating the unique batch data in
 *                         jtf_rs_upload_data.
 * @param P_RECORD_NO Record Number to identify a specific record for a P_TRANSACTION_NO
 * @param P_PROCESS_STATUS Status of upload - S -success, U -Unsuccessful, W -Warning
 * @param P_ERROR_TEXT Error text in case status is U or W
 * @rep:scope private
 * @rep:displayname Update Upload Data
 */
PROCEDURE update_upload_data (
     P_TRANSACTION_NO IN JTF_RS_UPLOAD_DATA.TRANSACTION_NO%TYPE,
     P_RECORD_NO      IN JTF_RS_UPLOAD_DATA.RECORD_NO%TYPE,
     P_PROCESS_STATUS IN JTF_RS_UPLOAD_DATA.PROCESS_STATUS%TYPE,
     P_ERROR_TEXT     IN JTF_RS_UPLOAD_DATA.ERROR_TEXT%TYPE
  );

END jtf_rs_import_user_pub;

 

/
