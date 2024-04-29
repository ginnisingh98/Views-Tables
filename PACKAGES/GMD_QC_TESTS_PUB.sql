--------------------------------------------------------
--  DDL for Package GMD_QC_TESTS_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."GMD_QC_TESTS_PUB" AUTHID CURRENT_USER AS
/*  $Header: GMDPTSTS.pls 115.4 2004/04/16 09:06:52 rboddu noship $ */
/*#
 * This interface is used to create and delete Test details.
 * This package defines and implements the procedures and datatypes
 * required to create and delete Test Headers and Test Values.
 * @rep:scope public
 * @rep:product GMD
 * @rep:lifecycle active
 * @rep:displayname Quality Tests package
 * @rep:compatibility S
 * @rep:category BUSINESS_ENTITY GMD_QC_TESTS_PUB
 */

/* +=========================================================================+
 |                Copyright (c) 2000 Oracle Corporation                    |
 |                        TVP, Reading, England                            |
 |                         All rights reserved                             |
 +=========================================================================+
 | FILENAME                                                                |
 |     GMDPTSTS.pls                                                        |
 |                                                                         |
 | DESCRIPTION                                                             |
 |     This package contains public definitions For processing             |
 |     QC TESTS                                                            |

 |                                                                         |
 |                                                                         |
 | HISTORY                                                                 |
 |     23-JUL-2002  H.Verdding                                             |
 |                                                                         |
 +=========================================================================+
  API Name  : GMD_QC_TESTS_PUB
  Type      : Public
  Function  : This package contains public procedures for processing QC TESTS
  Pre-reqs  : N/A
  Parameters: Per function


  Current Vers  : 1.0

  Previous Vers : 1.0

  Initial Vers  : 1.0
  Notes
*/



/*  A Table type Definition For QC TESTS PUB */

TYPE QC_TEST_VALUES_TBL IS TABLE OF GMD_QC_TEST_VALUES%ROWTYPE
      INDEX BY BINARY_INTEGER;

TYPE QC_CUST_TESTS_TBL IS TABLE OF GMD_CUSTOMER_TESTS%ROWTYPE
      INDEX BY BINARY_INTEGER;



/*   Define Procedures And Functions :   */

/*#
 * Creates Test Header and Test Values
 * This is a PL/SQL procedure to create Test Header and Test Values.
 * @param p_api_version API version field
 * @param p_init_msg_list Flag to check if message list initialized
 * @param p_commit to check for commit
 * @param p_validation_level For Future use
 * @param p_qc_tests_rec Record structure of Test Headers
 * @param p_qc_test_values_tbl Table structure of Test Values
 * @param p_qc_cust_tests_tbl Table structure of Customer Tests
 * @param p_user_name Login User Name
 * @param x_qc_tests_rec record structure of Test Headers
 * @param x_qc_test_values_tbl Table structure of Test Values
 * @param x_qc_cust_tests_tbl Table structure of Customer Tests
 * @param x_return_status  'S'-Success, 'E'-Error, 'U'-Unexpected Error
 * @param x_msg_count Number of messages on message stack
 * @param x_msg_data Actual message data on message stack
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:displayname Create Tests procedure
 * @rep:compatibility S
 */
PROCEDURE CREATE_TESTS
( p_api_version          IN  NUMBER
, p_init_msg_list        IN  VARCHAR2        DEFAULT FND_API.G_FALSE
, p_commit               IN  VARCHAR2        DEFAULT FND_API.G_FALSE
, p_validation_level     IN  NUMBER          DEFAULT FND_API.G_VALID_LEVEL_FULL
, p_qc_tests_rec         IN  GMD_QC_TESTS%ROWTYPE
, p_qc_test_values_tbl   IN  GMD_QC_TESTS_PUB.qc_test_values_tbl
, p_qc_cust_tests_tbl    IN  GMD_QC_TESTS_PUB.qc_cust_tests_tbl
, p_user_name            IN  VARCHAR2
, x_qc_tests_rec         OUT NOCOPY  GMD_QC_TESTS%ROWTYPE
, x_qc_test_values_tbl   OUT NOCOPY  GMD_QC_TESTS_PUB.qc_test_values_tbl
, x_qc_cust_tests_tbl    OUT NOCOPY  GMD_QC_TESTS_PUB.qc_cust_tests_tbl
, x_return_status        OUT NOCOPY VARCHAR2
, x_msg_count            OUT NOCOPY NUMBER
, x_msg_data             OUT NOCOPY VARCHAR2
);

/*#
 * Deletes Test Headers
 * This is a PL/SQL procedure to Delete Test Headers.
 * @param p_api_version API version field
 * @param p_init_msg_list Flag to check if message list initialized
 * @param p_commit to check for commit
 * @param p_validation_level For Future Use
 * @param p_qc_tests_rec record structure of Test Headers
 * @param p_user_name Login User name
 * @param x_return_status  'S'-Success, 'E'-Error, 'U'-Unexpected Error
 * @param x_msg_count Number of messages on message stack
 * @param x_msg_data Actual message data on message stack
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:displayname Delete Test Headers procedure
 * @rep:compatibility S
*/
PROCEDURE DELETE_TEST_HEADERS
( p_api_version          IN  NUMBER
, p_init_msg_list        IN  VARCHAR2        DEFAULT FND_API.G_FALSE
, p_commit               IN  VARCHAR2        DEFAULT FND_API.G_FALSE
, p_validation_level     IN  NUMBER          DEFAULT FND_API.G_VALID_LEVEL_FULL
, p_qc_tests_rec         IN  GMD_QC_TESTS%ROWTYPE
, p_user_name            IN  VARCHAR2
, x_return_status        OUT NOCOPY VARCHAR2
, x_msg_count            OUT NOCOPY NUMBER
, x_msg_data             OUT NOCOPY VARCHAR2
);

/*#
 * Deletes Test Values
 * This is a PL/SQL procedure to Delete Test Values.
 * @param p_api_version API version field
 * @param p_init_msg_list Flag to check if message list initialized
 * @param p_commit to check for commit
 * @param p_validation_level For Future Use
 * @param p_qc_test_values_tbl Table structure of Test Values
 * @param x_deleted_rows Number of Test Value records Deleted
 * @param x_return_status  'S'-Success, 'E'-Error, 'U'-Unexpected Error
 * @param x_msg_count Number of messages on message stack
 * @param x_msg_data Actual message data on message stack
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:displayname Delete Test Values procedure
 * @rep:compatibility S
*/
PROCEDURE DELETE_TEST_VALUES
( p_api_version          IN  NUMBER
, p_init_msg_list        IN  VARCHAR2        DEFAULT FND_API.G_FALSE
, p_commit               IN  VARCHAR2        DEFAULT FND_API.G_FALSE
, p_validation_level     IN  NUMBER          DEFAULT FND_API.G_VALID_LEVEL_FULL
, p_qc_test_values_tbl   IN  GMD_QC_TESTS_PUB.qc_test_values_tbl
, x_deleted_rows         OUT NOCOPY NUMBER
, x_return_status        OUT NOCOPY VARCHAR2
, x_msg_count            OUT NOCOPY NUMBER
, x_msg_data             OUT NOCOPY VARCHAR2
);

/*#
 * Deletes Test Customer Display Details
 * This is a PL/SQL procedure to Delete Test Customer Display Details.
 * @param p_api_version API version field
 * @param p_init_msg_list Flag to check if message list initialized
 * @param p_commit to check for commit
 * @param p_validation_level For Future Use
 * @param p_qc_cust_tests_tbl Table structure of Test Customer Display
 * @param x_deleted_rows Number of Test Customer Display records Deleted
 * @param x_return_status  'S'-Success, 'E'-Error, 'U'-Unexpected Error
 * @param x_msg_count Number of messages on message stack
 * @param x_msg_data Actual message data on message stack
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:displayname Delete Test Customer Display Details procedure
 * @rep:compatibility S
*/
PROCEDURE DELETE_CUSTOMER_TESTS
( p_api_version          IN  NUMBER
, p_init_msg_list        IN  VARCHAR2        DEFAULT FND_API.G_FALSE
, p_commit               IN  VARCHAR2        DEFAULT FND_API.G_FALSE
, p_validation_level     IN  NUMBER          DEFAULT FND_API.G_VALID_LEVEL_FULL
, p_qc_cust_tests_tbl    IN  GMD_QC_TESTS_PUB.qc_cust_tests_tbl
, x_deleted_rows         OUT NOCOPY NUMBER
, x_return_status        OUT NOCOPY VARCHAR2
, x_msg_count            OUT NOCOPY NUMBER
, x_msg_data             OUT NOCOPY VARCHAR2
);


END GMD_QC_TESTS_PUB;

 

/
