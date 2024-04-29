--------------------------------------------------------
--  DDL for Package GMD_RESULTS_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."GMD_RESULTS_PUB" AUTHID CURRENT_USER AS
/*  $Header: GMDPRESS.pls 120.1 2005/06/28 02:03:18 nsrivast noship $*/
/*#
 * This interface is used for processing QM Results.
 * This package defines and implements the procedures and datatypes
 * required for processing QM results.
 * @rep:scope public
 * @rep:product GMD
 * @rep:lifecycle active
 * @rep:displayname GMD Results Package
 * @rep:compatibility S
 * @rep:category BUSINESS_ENTITY GMD_RESULTS_PUB
 */
-- Define Results Rec Type
-- Bug 3559515 EVAL_IND and ACTION_CODE assigned proper data types.

TYPE RESULTS_REC IS RECORD
( UPDATE_INSTANCE_ID   GMD_RESULTS.UPDATE_INSTANCE_ID%TYPE,
  RESULT_ID            GMD_RESULTS.RESULT_ID%TYPE,
  SAMPLE_ID            GMD_RESULTS.SAMPLE_ID%TYPE,
  SAMPLE_NO            GMD_SAMPLES.SAMPLE_NO%TYPE,
  ORGANIZATION_ID      GMD_SAMPLES.ORGANIZATION_ID%TYPE,       /*NSRIVAST, INVCONV*/
  LAB_ORGANIZATION_ID  GMD_RESULTS.LAB_ORGANIZATION_ID%TYPE,   /*NSRIVAST, INVCONV*/
  TEST_CODE            GMD_QC_TESTS.TEST_CODE%TYPE,
  TEST_ID              GMD_RESULTS.TEST_ID%TYPE,
  TEST_REPLICATE_CNT   GMD_RESULTS.TEST_REPLICATE_CNT%TYPE,
  RESULT_VALUE         VARCHAR2(80),
  RESULT_DATE          GMD_RESULTS.RESULT_DATE%TYPE,
  TEST_KIT_INV_ITEM_ID GMD_RESULTS.TEST_KIT_INV_ITEM_ID%TYPE,  /*NSRIVAST, INVCONV*/
  TEST_KIT_LOT_NUMBER  GMD_RESULTS.TEST_KIT_LOT_NUMBER%TYPE,   /*NSRIVAST, INVCONV*/
  TESTER               GMD_RESULTS.TESTER%TYPE,
  TESTER_ID            GMD_RESULTS.TESTER_ID%TYPE,
  TEST_PROVIDER_CODE   GMD_RESULTS.TEST_PROVIDER_CODE%TYPE,
  TEST_PROVIDER_ID     GMD_RESULTS.TEST_PROVIDER_ID%TYPE,
  SEQ                  GMD_RESULTS.SEQ%TYPE,
  IN_SPEC              GMD_SPEC_RESULTS.IN_SPEC_IND%TYPE,
  ASSAY_RETEST         GMD_RESULTS.ASSAY_RETEST%TYPE,
  EVAL_IND             GMD_SPEC_RESULTS.EVALUATION_IND%TYPE,
  ACTION_CODE          GMD_SPEC_RESULTS.ACTION_CODE%TYPE,
  AD_HOC_PRINT_ON_COA_IND GMD_RESULTS.AD_HOC_PRINT_ON_COA_IND%TYPE,
  PLANNED_RESOURCE GMD_RESULTS.PLANNED_RESOURCE%TYPE,
  PLANNED_RESOURCE_INSTANCE GMD_RESULTS.PLANNED_RESOURCE_INSTANCE%TYPE,
  ACTUAL_RESOURCE      GMD_RESULTS.ACTUAL_RESOURCE%TYPE,
  ACTUAL_RESOURCE_INSTANCE  GMD_RESULTS.ACTUAL_RESOURCE_INSTANCE%TYPE,
  PLANNED_RESULT_DATE  GMD_RESULTS.PLANNED_RESULT_DATE%TYPE,
  TEST_BY_DATE         GMD_RESULTS.TEST_BY_DATE%TYPE,
  TEST_QTY             GMD_RESULTS.TEST_QTY%TYPE,
  TEST_QTY_UOM         GMD_RESULTS.TEST_QTY_UOM%TYPE,  /*NSRIVAST, INVCONV*/
  RESERVE_SAMPLE_ID    GMD_RESULTS.RESERVE_SAMPLE_ID%TYPE,
  CONSUMED_QTY         GMD_RESULTS.CONSUMED_QTY%TYPE
);


/*   Define Procedures And Functions :   */

/*#
 * Validates input
 * This procedure checks input against various validations and
 * will throw an exception if any validation fails.
 * @param p_results_rec Record structure for Result
 * @param x_return_status 'S'-Success, 'E'-Error, 'U'-Unexpected Error
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:displayname Validate Result Input Procedure
 * @rep:compatibility S
 */

PROCEDURE VALIDATE_INPUT
( p_results_rec          IN  GMD_RESULTS_PUB.RESULTS_REC,
  x_return_status        OUT NOCOPY VARCHAR2
);

/*#
 * Gets Result information
 * @param p_results_rec Record structure for results
 * @param x_tests_rec Record structure for tests
 * @param x_samples_rec Record structure for samples
 * @param x_return_status 'S'-Success, 'E'-Error, 'U'-Unexpected Error
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:displayname Get Result Information
 * @rep:compatibility S
 */

PROCEDURE GET_RESULT_INFO
( p_results_rec          IN  GMD_RESULTS_PUB.RESULTS_REC,
  x_tests_rec            OUT NOCOPY GMD_QC_TESTS%ROWTYPE,
  x_samples_rec          OUT NOCOPY GMD_SAMPLES%ROWTYPE,
  x_return_status        OUT NOCOPY VARCHAR2
);


/*#
 * records results
 * @param p_api_version API version field
 * @param p_init_msg_list Flag to check if message list is intialized
 * @param p_commit Flag to check for commit
 * @param p_validation_level For future use
 * @param p_results_rec Record structure for Results
 * @param p_user_name Login User Name
 * @param x_results_rec Record structure for GMD results
 * @param x_spec_results_rec Record structure for GMD specification results
 * @param x_return_status 'S'-Success, 'E'-Error, 'U'-Unexpected Error
 * @param x_msg_count Number of messages on message stack
 * @param x_msg_data Actual message data on message stack
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:displayname Record Results
 * @rep:compatibility S
 */



PROCEDURE RECORD_RESULTS
( p_api_version            IN  NUMBER
, p_init_msg_list          IN  VARCHAR2        DEFAULT FND_API.G_FALSE
, p_commit                 IN  VARCHAR2        DEFAULT FND_API.G_FALSE
, p_validation_level       IN  NUMBER          DEFAULT FND_API.G_VALID_LEVEL_FULL
, p_results_rec            IN  GMD_RESULTS_PUB.RESULTS_REC
, p_user_name              IN  VARCHAR2
, x_results_rec            OUT NOCOPY GMD_RESULTS%ROWTYPE
, x_spec_results_rec       OUT NOCOPY GMD_SPEC_RESULTS%ROWTYPE
, x_return_status          OUT NOCOPY VARCHAR2
, x_msg_count              OUT NOCOPY NUMBER
, x_msg_data               OUT NOCOPY VARCHAR2
, p_user_responsibility_id IN NUMBER DEFAULT NULL /*NSRIVAST, INVCONV*/
);


/*#
 * adds tests to the sample
 * @param p_api_version API version field
 * @param p_init_msg_list Flag to check if message list is intialized
 * @param p_commit Flag to check for commit
 * @param p_validation_level For future use
 * @param p_user_name Login User Name
 * @param p_sample_rec Record structure for Samples
 * @param p_test_id_tab Table structure for Table IDs
 * @param p_event_spec_disp_id Event spec disp ID
 * @param x_results_tab Table structure for Results
 * @param x_spec_results_tab Table structure for Specification Results
 * @param x_return_status 'S'-Success, 'E'-Error, 'U'-Unexpected Error
 * @param x_msg_count Number of messages on message stack
 * @param x_msg_data Actual message data on message stack
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:displayname Add tests to sample
 * @rep:compatibility S
 */

PROCEDURE ADD_TESTS_TO_SAMPLE
(
  p_api_version          IN  NUMBER
, p_init_msg_list        IN  VARCHAR2        DEFAULT FND_API.G_FALSE
, p_commit               IN  VARCHAR2        DEFAULT FND_API.G_FALSE
, p_validation_level     IN  NUMBER          DEFAULT FND_API.G_VALID_LEVEL_FULL
, p_user_name            IN  VARCHAR2
, p_sample_rec           IN  GMD_SAMPLES%ROWTYPE
, p_test_id_tab          IN  GMD_API_PUB.number_tab
, p_event_spec_disp_id   IN  NUMBER
, x_results_tab          OUT NOCOPY GMD_API_PUB.gmd_results_tab
, x_spec_results_tab     OUT NOCOPY GMD_API_PUB.gmd_spec_results_tab
, x_return_status        OUT NOCOPY VARCHAR2
, x_msg_count            OUT NOCOPY NUMBER
, x_msg_data             OUT NOCOPY VARCHAR2
);

END GMD_RESULTS_PUB;

 

/
