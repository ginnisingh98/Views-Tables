--------------------------------------------------------
--  DDL for Package GMD_SPEC_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."GMD_SPEC_PUB" AUTHID CURRENT_USER AS
/*  $Header: GMDPSPCS.pls 120.1 2006/10/04 11:50:30 srakrish noship $ */
/*#
 * This interface is used to create and delete Specifications.
 * This package defines and implements the procedures and datatypes
 * required to create and delete Specifications and Specification Tests.
 * @rep:scope public
 * @rep:product GMD
 * @rep:lifecycle active
 * @rep:displayname Quality Specifications package
 * @rep:compatibility S
 * @rep:category BUSINESS_ENTITY GMD_QC_SPEC
 */
 /*
 +=========================================================================+
 |                Copyright (c) 2000 Oracle Corporation                    |
 |                        TVP, Reading, England                            |
 |                         All rights reserved                             |
 +=========================================================================+
 | File Name          : GMDPSPCS.pls                                       |
 | Package Name       : GMD_Spec_PUB                                       |
 | Type               : PUBLIC                                             |
 |                                                                         |
 | DESCRIPTION                                                             |
 |     This package contains public definitions for processing             |
 |     QC Specifications                                                   |
 |                                                                         |
 |                                                                         |
 | HISTORY                                                                 |
 |     03-AUG-2002  H.Verdding                                             |
 |                                                                         |
 +=========================================================================+
  API Name  : GMD_Spec_PUB
  Type      : Public
  Function  : This package contains public procedures used to process
              specifications.
  Pre-reqs  : N/A
  Parameters: Per function


  Current Vers  : 1.0

  Previous Vers : 1.0

  Initial Vers  : 1.0
  Notes
  END of Notes */



/*  A Table type Definition For GMD_Spec_PUB */

TYPE SPEC_TESTS_TBL IS TABLE OF GMD_SPEC_TESTS%ROWTYPE
      INDEX BY BINARY_INTEGER;


TYPE INVENTORY_SPEC_VRS_TBL IS TABLE OF GMD_INVENTORY_SPEC_VRS%ROWTYPE
      INDEX BY BINARY_INTEGER;


-- Define Procedures And Functions :
-- =================================

/*#
 * Creates Specifications
 * This is a PL/SQL procedure to Create Specifications.
 * @param p_api_version API version field
 * @param p_init_msg_list Flag to check if message list is initialized
 * @param p_commit Flag to check for commit
 * @param p_validation_level For Future Use
 * @param p_spec Record Structure of Specifications
 * @param p_spec_tests_tbl Table Structure of Specification tests
 * @param p_user_name Login User name
 * @param x_spec Record Structure of Specifications
 * @param x_spec_tests_tbl Table Structure of Specification tests
 * @param x_return_status  'S'-Success, 'E'-Error, 'U'-Unexpected Error
 * @param x_msg_count Number of messages on message stack
 * @param x_msg_data Actual message data on message stack
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:displayname Create Specifications procedure
 * @rep:compatibility S
*/
PROCEDURE CREATE_SPEC
( p_api_version          IN  NUMBER
, p_init_msg_list        IN  VARCHAR2        DEFAULT FND_API.G_FALSE
, p_commit               IN  VARCHAR2        DEFAULT FND_API.G_FALSE
, p_validation_level     IN  VARCHAR2        DEFAULT FND_API.G_VALID_LEVEL_FULL
, p_spec                 IN  GMD_SPECIFICATIONS%ROWTYPE
, p_spec_tests_tbl       IN  GMD_SPEC_PUB.spec_tests_tbl
, p_user_name            IN  VARCHAR2        DEFAULT NULL
, x_spec                 OUT NOCOPY GMD_SPECIFICATIONS%ROWTYPE
, x_spec_tests_tbl       OUT NOCOPY GMD_SPEC_PUB.spec_tests_tbl
, x_return_status        OUT NOCOPY VARCHAR2
, x_msg_count            OUT NOCOPY NUMBER
, x_msg_data             OUT NOCOPY VARCHAR2
);

/*#
 * Deletes Specifications
 * This is a PL/SQL procedure to Delete Specifications.
 * @param p_api_version API version field
 * @param p_init_msg_list Flag to check if message list is initialized
 * @param p_commit Flag to check for commit
 * @param p_validation_level For Future Use
 * @param p_spec Record Structure of Specifications
 * @param p_user_name Login User name
 * @param x_deleted_rows Number of Specification records Deleted
 * @param x_return_status  'S'-Success, 'E'-Error, 'U'-Unexpected Error
 * @param x_msg_count Number of messages on message stack
 * @param x_msg_data Actual message data on message stack
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:displayname Delete Specifications procedure
 * @rep:compatibility S
*/
PROCEDURE DELETE_SPEC
( p_api_version          IN  NUMBER
, p_init_msg_list        IN  VARCHAR2        DEFAULT FND_API.G_FALSE
, p_commit               IN  VARCHAR2        DEFAULT FND_API.G_FALSE
, p_validation_level     IN  VARCHAR2        DEFAULT FND_API.G_VALID_LEVEL_FULL
, p_spec                 IN  GMD_SPECIFICATIONS%ROWTYPE
, p_user_name            IN  VARCHAR2        DEFAULT NULL
, x_deleted_rows         OUT NOCOPY NUMBER
, x_return_status        OUT NOCOPY VARCHAR2
, x_msg_count            OUT NOCOPY NUMBER
, x_msg_data             OUT NOCOPY VARCHAR2
);

/*#
 * Deletes Specification Tests
 * This is a PL/SQL procedure to Delete Specification Tests.
 * @param p_api_version API version field
 * @param p_init_msg_list Flag to check if message list is initialized
 * @param p_commit Flag to check for commit
 * @param p_validation_level For Future Use
 * @param p_spec_tests_tbl Table Structure of Specification Tests
 * @param x_deleted_rows Number of Specification records Deleted
 * @param x_return_status  'S'-Success, 'E'-Error, 'U'-Unexpected Error
 * @param x_msg_count Number of messages on message stack
 * @param x_msg_data Actual message data on message stack
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:displayname Delete Specifications procedure
 * @rep:compatibility S
*/
PROCEDURE DELETE_SPEC_TESTS
( p_api_version          IN  NUMBER
, p_init_msg_list        IN  VARCHAR2        DEFAULT FND_API.G_FALSE
, p_commit               IN  VARCHAR2        DEFAULT FND_API.G_FALSE
, p_validation_level     IN  VARCHAR2        DEFAULT FND_API.G_VALID_LEVEL_FULL
, p_spec_tests_tbl       IN  GMD_SPEC_PUB.spec_tests_tbl
, x_deleted_rows         OUT NOCOPY NUMBER
, x_return_status        OUT NOCOPY VARCHAR2
, x_msg_count            OUT NOCOPY NUMBER
, x_msg_data             OUT NOCOPY VARCHAR2
);

END GMD_SPEC_PUB;

 

/
