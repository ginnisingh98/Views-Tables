--------------------------------------------------------
--  DDL for Package GMD_SAMPLES_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."GMD_SAMPLES_PUB" AUTHID CURRENT_USER AS
/*  $Header: GMDPSMPS.pls 120.3.12010000.2 2009/03/18 21:10:58 plowe ship $*/
/*#
 * This interface is used to create, delete, and validate samples.
 * This package defines and implements the procedures required
 * to create, delete, and validate samples.
 * @rep:scope public
 * @rep:product GMD
 * @rep:lifecycle active
 * @rep:displayname GMD Samples Package
 * @rep:compatibility S
 * @rep:category BUSINESS_ENTITY GMD_QC_SAMPLES
 */



/*   Define Procedures And Functions :   */

/*#
 * Creates samples
 * @param p_api_version API version field
 * @param p_init_msg_list Flag to check if message list intialized
 * @param p_commit Flag to check for commit
 * @param p_validation_level For future use
 * @param p_qc_samples_rec Record structure for samples - input
 * @param p_user_name Login User name
 * @param p_find_matching_spec Flag to ensure that sampling event has spec associated
 * @param p_grade Grade
 * @param p_lpn License Plate Number
 * @param x_qc_samples_rec Record structure for samples - output
 * @param x_sampling_events_rec Record structure for sampling events
 * @param x_sample_spec_disp Record structure for Sample Spec Disposition
 * @param x_event_spec_disp_rec Record structure for Event Spec Disposition
 * @param x_results_tab Table structure for results
 * @param x_spec_results_tab Table structure for Spec results
 * @param x_return_status  'S'-Success, 'E'-Error, 'U'-Unexpected Error
 * @param x_msg_count Number of messages on message stack
 * @param x_msg_data Actual message data on message stack
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:displayname Create Samples
 * @rep:compatibility S
 */


PROCEDURE CREATE_SAMPLES
( p_api_version          IN  NUMBER
, p_init_msg_list        IN  VARCHAR2        DEFAULT FND_API.G_FALSE
, p_commit               IN  VARCHAR2        DEFAULT FND_API.G_FALSE
, p_validation_level     IN  NUMBER          DEFAULT FND_API.G_VALID_LEVEL_FULL
, p_qc_samples_rec       IN  GMD_SAMPLES%ROWTYPE
, p_user_name            IN  VARCHAR2
, p_find_matching_spec   IN  VARCHAR2  DEFAULT 'N'
, p_grade                IN  VARCHAR2 DEFAULT NULL --3431884
, p_lpn                  IN  VARCHAR2 DEFAULT NULL --7027149
, x_qc_samples_rec       OUT NOCOPY GMD_SAMPLES%ROWTYPE
, x_sampling_events_rec  OUT NOCOPY GMD_SAMPLING_EVENTS%ROWTYPE
, x_sample_spec_disp     OUT NOCOPY GMD_SAMPLE_SPEC_DISP%ROWTYPE
, x_event_spec_disp_rec  OUT NOCOPY GMD_EVENT_SPEC_DISP%ROWTYPE
, x_results_tab          OUT NOCOPY GMD_API_PUB.gmd_results_tab
, x_spec_results_tab     OUT NOCOPY GMD_API_PUB.gmd_spec_results_tab
, x_return_status        OUT NOCOPY VARCHAR2
, x_msg_count            OUT NOCOPY NUMBER
, x_msg_data             OUT NOCOPY VARCHAR2
);


/*# finds if the specification is matching
 * @param p_samples_rec Record structure for Samples
 * @param p_grade Grade
 * @param x_spec_id Specification ID
 * @param x_spec_type Specification type
 * @param x_spec_vr_id Specification Validity Rule ID
 * @param x_return_status  'S'-Success, 'E'-Error, 'U'-Unexpected Error
 * @param x_msg_data Actual message data on message stack
 * @return returns true if a matching specification is found
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:displayname Find Matching Specifications
 * @rep:compatibility S
 */

FUNCTION FIND_MATCHING_SPEC
( p_samples_rec         IN GMD_SAMPLES%ROWTYPE,
  p_grade               IN  VARCHAR2 DEFAULT NULL,  -- 3431884
  x_spec_id             OUT NOCOPY NUMBER,
  x_spec_type           OUT NOCOPY VARCHAR2,
  x_spec_vr_id          OUT NOCOPY NUMBER,
  x_return_status       OUT NOCOPY VARCHAR2,
  x_msg_data            OUT NOCOPY VARCHAR2

) RETURN BOOLEAN;


/*#
 * Deletes samples
 * @param p_api_version API version field
 * @param p_init_msg_list Flag to check if message list is intialized
 * @param p_commit Flag to check for commit
 * @param p_validation_level For future use
 * @param p_qc_samples_rec Record structure for Samples
 * @param p_user_name Login User name
 * @param x_return_status  'S'-Success, 'E'-Error, 'U'-Unexpected Error
 * @param x_msg_count Number of messages on message stack
 * @param x_msg_data Actual message data on message stack
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:displayname Delete Samples
 * @rep:compatibility S
 */

PROCEDURE DELETE_SAMPLES
( p_api_version          IN  NUMBER
, p_init_msg_list        IN  VARCHAR2        DEFAULT FND_API.G_FALSE
, p_commit               IN  VARCHAR2        DEFAULT FND_API.G_FALSE
, p_validation_level     IN  NUMBER          DEFAULT FND_API.G_VALID_LEVEL_FULL
, p_qc_samples_rec       IN  GMD_SAMPLES%ROWTYPE
, p_user_name            IN  VARCHAR2
, x_return_status        OUT NOCOPY VARCHAR2
, x_msg_count            OUT NOCOPY NUMBER
, x_msg_data             OUT NOCOPY VARCHAR2
);

/*#
 * Validates Item controls
 * @param p_sample_rec Record structure for Input Samples
 * @param x_sample_rec Record structure for Output Samples
 * @param p_grade Grade
 * @param x_return_status 'S'-Success, 'E'-Error, 'U'-Unexpected Error
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:displayname Validate Item controls
 * @rep:compatibility S
 */


PROCEDURE VALIDATE_ITEM_CONTROLS
( p_sample_rec     IN         GMD_SAMPLES%ROWTYPE,
  p_grade          IN         VARCHAR2,
  x_sample_rec     OUT NOCOPY GMD_SAMPLES%ROWTYPE,
  x_return_status  OUT NOCOPY VARCHAR2
);

/*#
 * Validates Inventory sample
 * @param p_sample_rec Record structure for samples
 * @param p_locator_control Locator is controlled or not
 * @param x_return_status 'S'-Success, 'E'-Error, 'U'-Unexpected Error
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:displayname Validate Inventory sample
 * @rep:compatibility S
 */

PROCEDURE VALIDATE_INV_SAMPLE
( p_sample_rec     IN         GMD_SAMPLES%ROWTYPE,
  p_locator_control  IN  NUMBER,
  x_return_status  OUT NOCOPY VARCHAR2
);

/*#
 * Validates Customer sample
 * @param p_sample_rec Record structure for samples
 * @param x_return_status 'S'-Success, 'E'-Error, 'U'-Unexpected Error
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:displayname Validate Customer sample
 * @rep:compatibility S
 */

PROCEDURE VALIDATE_CUST_SAMPLE
( p_sample_rec     IN         GMD_SAMPLES%ROWTYPE,
  x_return_status  OUT NOCOPY VARCHAR2
);

/*#
 * Validates Supplier sample
 * @param p_sample_rec Record structure for samples
 * @param x_return_status 'S'-Success, 'E'-Error, 'U'-Unexpected Error
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:displayname Validate Supplier sample
 * @rep:compatibility S
 */

PROCEDURE VALIDATE_SUPP_SAMPLE
( p_sample_rec     IN         GMD_SAMPLES%ROWTYPE,
  x_return_status  OUT NOCOPY VARCHAR2
);

/*#
 * Validates WIP sample
 * @param p_sample_rec Record structure for input samples
 * @param x_sample_rec Record structure for output samples
 * @param x_return_status 'S'-Success, 'E'-Error, 'U'-Unexpected Error
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:displayname Validate WIP sample
 * @rep:compatibility S
 */

PROCEDURE VALIDATE_WIP_SAMPLE
( p_sample_rec     IN          GMD_SAMPLES%ROWTYPE,
  x_sample_rec     OUT NOCOPY  GMD_SAMPLES%ROWTYPE,
  x_return_status  OUT NOCOPY  VARCHAR2
);

/*#
 * Validates sample
 * @param p_sample_rec Record structure for input samples
 * @param p_grade Grade
 * @param x_sample_rec Record structure for output samples
 * @param x_return_status 'S'-Success, 'E'-Error, 'U'-Unexpected Error
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:displayname Validate sample
 * @rep:compatibility S
 */

PROCEDURE VALIDATE_SAMPLE
(
  p_sample_rec    IN  GMD_SAMPLES%ROWTYPE
, p_grade         IN  VARCHAR2   --3431884
, x_sample_rec    OUT NOCOPY GMD_SAMPLES%ROWTYPE
, x_return_status OUT NOCOPY VARCHAR2
);

/*#
 * Validates Location sample
 * @param p_sample_rec Record structure for samples
 * @param p_locator_control Locator controlled or not
 * @param x_return_status 'S'-Success, 'E'-Error, 'U'-Unexpected Error
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:displayname Validate Location sample
 * @rep:compatibility S
 */

PROCEDURE VALIDATE_LOCATION_SAMPLE
( p_sample_rec     IN         GMD_SAMPLES%ROWTYPE,
  p_locator_control  IN  NUMBER,
  x_return_status  OUT NOCOPY VARCHAR2
);

/*#
 * Validates Resource sample
 * @param p_sample_rec Record structure for samples
 * @param x_return_status 'S'-Success, 'E'-Error, 'U'-Unexpected Error
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:displayname Validate Resource sample
 * @rep:compatibility S
 */

PROCEDURE VALIDATE_RESOURCE_SAMPLE
( p_sample_rec     IN         GMD_SAMPLES%ROWTYPE,
  x_return_status  OUT NOCOPY VARCHAR2
);

/*#
 * Validates Stability sample
 * @param p_sample_rec Record structure for samples
 * @param x_return_status 'S'-Success, 'E'-Error, 'U'-Unexpected Error
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:displayname Validate Stability sample
 * @rep:compatibility S
 */

PROCEDURE VALIDATE_STABILITY_SAMPLE
( p_sample_rec     IN         GMD_SAMPLES%ROWTYPE,
  x_return_status  OUT NOCOPY VARCHAR2
);


END GMD_SAMPLES_PUB;


/
