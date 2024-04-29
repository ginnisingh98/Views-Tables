--------------------------------------------------------
--  DDL for Package EC_DOCUMENT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."EC_DOCUMENT" AUTHID CURRENT_USER AS
-- $Header: ECTRIGS.pls 120.3 2005/09/30 05:48:09 arsriniv ship $
/*#
 * This package contains routines to process outbound documents.
 * @rep:scope internal
 * @rep:product EC
 * @rep:lifecycle active
 * @rep:displayname Outbound Processing Routines
 * @rep:compatibility S
 * @rep:category BUSINESS_ENTITY EC_OUTBOUND
 */

-- Define temporary stack that loads passed parameter values into it.
 TYPE t_parm_tmp_tbl IS TABLE OF VARCHAR2(150)
 INDEX BY BINARY_INTEGER;

m_parm_tmp_tbl t_parm_tmp_tbl;
/*#
 * This is the program which triggers an outbound process concurrent program.
 * @param p_api_version_number API Version Number
 * @param p_init_msg_list   Initialize Message List?
 * @param p_validation_level Validation Level
 * @param x_return_status Return Status
 * @param x_msg_count   Message Count
 * @param x_msg_data Message Data
 * @param call_status Concurrent Program Status
 * @param request_id Request Id of the Concurrent Program
 * @param i_Output_Path   File Path of the Output flat file
 * @param i_Output_Filename  Output File Name
 * @param i_Transaction_Type Transaction Type
 * @param i_debug_mode  Debug Mode
 * @param p_parameter1  Parameter 1 to Concurrent Program
 * @param p_parameter2  Parameter 2 to Concurrent Program
 * @param p_parameter3  Parameter 3 to Concurrent Program
 * @param p_parameter4  Parameter 4 to Concurrent Program
 * @param p_parameter5  Parameter 5 to Concurrent Program
 * @param p_parameter6  Parameter 6 to Concurrent Program
 * @param p_parameter7  Parameter 7 to Concurrent Program
 * @param p_parameter8  Parameter 8 to Concurrent Program
 * @param p_parameter9  Parameter 9 to Concurrent Program
 * @param p_parameter10  Parameter 10 to Concurrent Program
 * @param p_parameter11  Parameter 11 to Concurrent Program
 * @param p_parameter12  Parameter 12 to Concurrent Program
 * @param p_parameter13  Parameter 13 to Concurrent Program
 * @param p_parameter14  Parameter 14 to Concurrent Program
 * @param p_parameter15  Parameter 15 to Concurrent Program
 * @param p_parameter16  Parameter 16 to Concurrent Program
 * @param p_parameter17  Parameter 17 to Concurrent Program
 * @param p_parameter18  Parameter 18 to Concurrent Program
 * @param p_parameter19  Parameter 19 to Concurrent Program
 * @param p_parameter20  Parameter 20 to Concurrent Program
 * @rep:scope internal
 * @rep:lifecycle active
 * @rep:displayname Trigger Outbound EDI Transaction Processing
 * @rep:compatibility S
 */

PROCEDURE send(
	p_api_version_number    IN      NUMBER,
        p_init_msg_list         IN      VARCHAR2 := FND_API.G_FALSE,
        p_commit                IN      VARCHAR2 := FND_API.G_FALSE,
        p_validation_level      IN      NUMBER   := FND_API.G_VALID_LEVEL_FULL,
        x_return_status         OUT  NOCOPY   VARCHAR2,
        x_msg_count             OUT  NOCOPY   NUMBER,
        x_msg_data              OUT  NOCOPY   VARCHAR2,
	call_status             OUT  NOCOPY   BOOLEAN,
        request_id              OUT  NOCOPY   PLS_INTEGER,
	i_Output_Path		IN	VARCHAR2,
	i_Output_Filename       IN      VARCHAR2 DEFAULT NULL,
        i_Transaction_Type      IN      VARCHAR2,
	i_debug_mode            IN      NUMBER DEFAULT NULL,
        p_parameter1            IN      VARCHAR2,
        p_parameter2            IN      VARCHAR2,
        p_parameter3            IN      VARCHAR2,
        p_parameter4            IN      VARCHAR2,
        p_parameter5            IN      VARCHAR2,
        p_parameter6            IN      VARCHAR2,
        p_parameter7            IN      VARCHAR2,
        p_parameter8            IN      VARCHAR2,
        p_parameter9            IN      VARCHAR2,
        p_parameter10           IN      VARCHAR2,
        p_parameter11           IN      VARCHAR2,
        p_parameter12           IN      VARCHAR2,
        p_parameter13           IN      VARCHAR2,
        p_parameter14           IN      VARCHAR2,
        p_parameter15           IN      VARCHAR2,
        p_parameter16           IN      VARCHAR2,
        p_parameter17           IN      VARCHAR2,
        p_parameter18           IN      VARCHAR2,
        p_parameter19           IN      VARCHAR2,
        p_parameter20           IN      VARCHAR2);

/*#
 * This is the program which processes outbound documents.
 * @param errbuf   Error Buffer
 * @param retcode Return Code
 * @param i_Output_Path   File path of the Output flat file
 * @param i_Output_Filename  Output File Name
 * @param i_Transaction_Type Transaction Type
 * @param i_debug_mode  Debug mode
 * @param parameter1  Parameter 1
 * @param parameter2  Parameter 2
 * @param parameter3  Parameter 3
 * @param parameter4  Parameter 4
 * @param parameter5  Parameter 5
 * @param parameter6  Parameter 6
 * @param parameter7  Parameter 7
 * @param parameter8  Parameter 8
 * @param parameter9  Parameter 9
 * @param parameter10  Parameter 10
 * @param parameter11  Parameter 11
 * @param parameter12  Parameter 12
 * @param parameter13  Parameter 13
 * @param parameter14  Parameter 14
 * @param parameter15  Parameter 15
 * @param parameter16  Parameter 16
 * @param parameter17  Parameter 17
 * @param parameter18  Parameter 18
 * @param parameter19  Parameter 19
 * @param parameter20  Parameter 20
 * @rep:scope internal
 * @rep:lifecycle active
 * @rep:displayname Process Outbound EDI Transactions
 * @rep:compatibility S
 */


PROCEDURE process_outbound(
        errbuf			OUT NOCOPY	VARCHAR2,
	retcode			OUT NOCOPY	VARCHAR2,
	i_Output_Path		IN	VARCHAR2,
	i_Output_Filename       IN      VARCHAR2 DEFAULT NULL,
	i_Transaction_Type      IN      VARCHAR2,
	i_debug_mode            IN      NUMBER  DEFAULT 0,
        parameter1              IN      VARCHAR2 DEFAULT NULL,
        parameter2              IN      VARCHAR2 DEFAULT NULL,
        parameter3              IN      VARCHAR2 DEFAULT NULL,
        parameter4              IN      VARCHAR2 DEFAULT NULL,
        parameter5              IN      VARCHAR2 DEFAULT NULL,
        parameter6              IN      VARCHAR2 DEFAULT NULL,
        parameter7              IN      VARCHAR2 DEFAULT NULL,
        parameter8              IN      VARCHAR2 DEFAULT NULL,
        parameter9              IN      VARCHAR2 DEFAULT NULL,
        parameter10             IN      VARCHAR2 DEFAULT NULL,
        parameter11             IN      VARCHAR2 DEFAULT NULL,
        parameter12             IN      VARCHAR2 DEFAULT NULL,
        parameter13             IN      VARCHAR2 DEFAULT NULL,
        parameter14             IN      VARCHAR2 DEFAULT NULL,
        parameter15             IN      VARCHAR2 DEFAULT NULL,
        parameter16             IN      VARCHAR2 DEFAULT NULL,
        parameter17             IN      VARCHAR2 DEFAULT NULL,
        parameter18             IN      VARCHAR2 DEFAULT NULL,
        parameter19             IN      VARCHAR2 DEFAULT NULL,
        parameter20             IN      VARCHAR2 DEFAULT NULL);

/*Bug 1854866
Assigned default values to the paramters1..20
of the procedure populate_tmp_parm_stack
since the default values are assigned
to these parameters in the package body
*/
PROCEDURE populate_tmp_parm_stack(
        parameter1             IN      VARCHAR2 DEFAULT NULL,
        parameter2             IN      VARCHAR2 DEFAULT NULL,
        parameter3             IN      VARCHAR2 DEFAULT NULL,
        parameter4             IN      VARCHAR2 DEFAULT NULL,
        parameter5             IN      VARCHAR2 DEFAULT NULL,
        parameter6             IN      VARCHAR2 DEFAULT NULL,
        parameter7             IN      VARCHAR2 DEFAULT NULL,
        parameter8             IN      VARCHAR2 DEFAULT NULL,
        parameter9             IN      VARCHAR2 DEFAULT NULL,
        parameter10            IN      VARCHAR2 DEFAULT NULL,
        parameter11            IN      VARCHAR2 DEFAULT NULL,
        parameter12            IN      VARCHAR2 DEFAULT NULL,
        parameter13            IN      VARCHAR2 DEFAULT NULL,
        parameter14            IN      VARCHAR2 DEFAULT NULL,
        parameter15            IN      VARCHAR2 DEFAULT NULL,
        parameter16            IN      VARCHAR2 DEFAULT NULL,
        parameter17            IN      VARCHAR2 DEFAULT NULL,
        parameter18            IN      VARCHAR2 DEFAULT NULL,
        parameter19            IN      VARCHAR2 DEFAULT NULL,
        parameter20            IN      VARCHAR2 DEFAULT NULL);


END ec_document;


 

/
