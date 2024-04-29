--------------------------------------------------------
--  DDL for Package GMD_RESULTS_GRP
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."GMD_RESULTS_GRP" AUTHID CURRENT_USER AS
--$Header: GMDGRESS.pls 120.0.12010000.3 2009/04/28 12:55:36 kannavar ship $

-- Start of comments
--+==========================================================================+
--|                   Copyright (c) 1998 Oracle Corporation                  |
--|                          Redwood Shores, CA, USA                         |
--|                            All rights reserved.                          |
--+==========================================================================+
--| File Name          : GMDGRESS.pls                                        |
--| Package Name       : GMD_RESULTS_GRP                                     |
--| Type               : Group                                               |
--|                                                                          |
--| Notes                                                                    |
--|    This package contains group layer APIs for Results Entity             |
--|                                                                          |
--|  TYPEs:      result_data                                                 |
--|                                                                          |
--|  FUNCTIONs:  is_value_numeric                                            |
--|  PROCEDUREs: check_experimental_error                                    |
--|              validate_result                                             |
--|                                                                          |
--| HISTORY                                                                  |
--|    Chetan Nagar	08-Aug-2002	Created.                             |
--|    Ger  Kelly	10-Sep-2002	Added in get_rslt_and_spec_rslt changes |
--|  	Ger Kelly	17-Sep-2002	Added in get_composite_rslt procedure|
--|   GK		19-Sep-2002     Added test_type to rec, changed the rec to tbl, |
--|                                     Added event_spec_disp_id as a parameter |
--|   LeAta Jackson     01-Oct-2002     Added migration parameter to         |
--|                                     create_rslt_and_spec_result_row      |
--|   LeAta Jackson     16-Oct-2002     Added check_disp, check_event and    |
--|                                     change_lot_status.  Bug 2628427      |
--|  GK			17-Oct-2002	Bug 2621648 - changed min and max char |
--|                                      to varchar2(16) in the data records |
--|  LeAta Jackson     14-Nov-2002      Added validate_result, is_value_numeric |
--|                                     validate_eval_list,                  |
--|                                     check_experimental_errror            |
--+==========================================================================+
-- End of comments

TYPE result_data IS RECORD
       (test_id            NUMBER,
        test_code          VARCHAR2(80),
        test_type          VARCHAR2(1),
        result_num         NUMBER,
        result_char        VARCHAR2(80),
        target_num         NUMBER,
        target_char        VARCHAR2(16),
        min_num	           NUMBER,
        min_char           VARCHAR2(16),
        max_num            NUMBER,
        max_char           VARCHAR2(16),
        in_spec            VARCHAR2(1),
        spec_target_num    NUMBER,
        spec_target_char   VARCHAR2(16),
        spec_min_num       NUMBER,
        spec_min_char      VARCHAR2(16),
        spec_max_num       NUMBER,
        spec_max_char      VARCHAR2(16),
        spec_in_spec       VARCHAR2(1),
        spec_test_id       NUMBER,
        unit               VARCHAR2(25),
        method             VARCHAR2(80),
        expression         VARCHAR2(1000),
        display_label      VARCHAR2(80),
        spec_id                NUMBER,
        result                 VARCHAR2(80),
        result_date            DATE,
        display_precision      NUMBER,
        report_precision       NUMBER,
        additional_test_ind    VARCHAR2(1),
        exp_error_type         gmd_spec_tests_b.exp_error_type%TYPE,
        below_spec_min         NUMBER,
        above_spec_min         NUMBER,
        below_spec_max         NUMBER,
        above_spec_max         NUMBER,
        below_min_action_code  VARCHAR(32),
        above_min_action_code  VARCHAR(32),
        below_max_action_code  VARCHAR(32),
        above_max_action_code  VARCHAR(32),
        out_action_code        VARCHAR(32),
        evaluation_ind         VARCHAR2(3),
        value_in_report_prec   NUMBER,
        in_fuzzy_zone          VARCHAR2(5),
        out_of_spec            VARCHAR2(5),
        result_action_code     VARCHAR2(32),
        called_from_form       VARCHAR2(1),
        lab_organization_id    NUMBER,
        planned_resource       VARCHAR2(30),
        planned_resource_instance       NUMBER,
        actual_resource        VARCHAR2(30),
        actual_resource_instance NUMBER,
        --BEGIN BUG#2871126 Rameshwar
        --Display precision for comparision spec.
        spec_display_precision  NUMBER
        --END  BUG#2871126
  );


--GK B2621648

TYPE gmd_results_rec_tbl IS TABLE OF result_data
   INDEX BY BINARY_INTEGER;

TYPE comres_rec IS RECORD
    (test_id	NUMBER,
	test_code 	VARCHAR2(80),
	result_num	NUMBER,
	result_char 	VARCHAR2(16),
	target_num 	NUMBER,
	target_char	VARCHAR2(16),
	min_num		NUMBER,
	min_char	VARCHAR2(16),
	max_num		NUMBER,
	max_char	VARCHAR2(16),
	in_spec		VARCHAR2(1),
	spec_target_num 	NUMBER,
	spec_target_char	VARCHAR2(16),
	spec_min_num		NUMBER,
	spec_min_char	VARCHAR2(16),
	spec_max_num		NUMBER,
	spec_max_char	VARCHAR2(16),
	spec_in_spec		VARCHAR2(1));

TYPE gmd_comres_tab IS TABLE OF comres_rec
   INDEX BY BINARY_INTEGER;


-- The following types are used in the Calculate Expression code.
TYPE rslt_rec IS RECORD
( test_id       NUMBER
, value         NUMBER
);

TYPE rslt_tbl IS TABLE OF rslt_rec
    INDEX BY BINARY_INTEGER;

PROCEDURE create_rslt_and_spec_rslt_rows
(
  p_sample            IN  GMD_SAMPLES%ROWTYPE
, p_migration         IN  VARCHAR2     DEFAULT NULL
, x_event_spec_disp   OUT NOCOPY GMD_EVENT_SPEC_DISP%ROWTYPE
, x_sample_spec_disp  OUT NOCOPY GMD_SAMPLE_SPEC_DISP%ROWTYPE
, x_results_tab       OUT NOCOPY GMD_API_PUB.gmd_results_tab
, x_spec_results_tab  OUT NOCOPY GMD_API_PUB.gmd_spec_results_tab
, x_return_status     OUT NOCOPY VARCHAR2
);


PROCEDURE delete_rslt_and_spec_rslt_rows
(
  p_sample_id     IN         NUMBER
, x_return_status OUT NOCOPY VARCHAR2
);


FUNCTION get_current_event_spec_disp_id
(
  p_sampling_event_id     IN  NUMBER
) RETURN NUMBER;


PROCEDURE compare_rslt_and_spec
(
  p_sample_id     IN  NUMBER
, p_spec_id       IN  NUMBER
, x_test_ids      OUT NOCOPY GMD_API_PUB.number_tab
, x_return_status OUT NOCOPY VARCHAR2
);


PROCEDURE compare_cmpst_rslt_and_spec
(
  p_composite_spec_disp_id IN  NUMBER
, p_spec_id                IN  NUMBER
, x_test_ids               OUT NOCOPY GMD_API_PUB.number_tab
, x_return_status          OUT NOCOPY VARCHAR2
);


FUNCTION rslt_is_in_spec
(
  p_spec_id         IN  NUMBER
, p_test_id         IN  NUMBER
, p_rslt_value_num  IN  NUMBER   DEFAULT NULL
, p_rslt_value_char IN  VARCHAR2 DEFAULT NULL
)
RETURN VARCHAR2;


PROCEDURE add_tests_to_sample
(
  p_sample             IN  GMD_SAMPLES%ROWTYPE
, p_test_ids           IN  GMD_API_PUB.number_tab
, p_event_spec_disp_id IN  NUMBER
, x_results_tab        OUT NOCOPY GMD_API_PUB.gmd_results_tab
, x_spec_results_tab   OUT NOCOPY GMD_API_PUB.gmd_spec_results_tab
, x_return_status      OUT NOCOPY VARCHAR2
, p_test_qty           IN  NUMBER  DEFAULT NULL
, p_test_qty_uom       IN  VARCHAR2  DEFAULT NULL
);


FUNCTION next_seq_in_result
(
  p_sample_id NUMBER
, p_test_id   NUMBER
)
RETURN NUMBER;


FUNCTION all_ref_tests_exist_in_sample
(
  p_sample_id IN NUMBER
, p_test_id   IN NUMBER
) RETURN BOOLEAN;


PROCEDURE add_test_to_samples
(
  p_sample_ids         IN  GMD_API_PUB.number_tab
, p_test_id            IN  NUMBER
, p_event_spec_disp_id IN  NUMBER
, x_results_tab        OUT NOCOPY GMD_API_PUB.gmd_results_tab
, x_spec_results_tab   OUT NOCOPY GMD_API_PUB.gmd_spec_results_tab
, x_return_status      OUT NOCOPY VARCHAR2
, p_test_qty           IN  NUMBER   DEFAULT NULL
, p_test_qty_uom       IN  VARCHAR2 DEFAULT NULL
);


PROCEDURE make_target_spec_the_base_spec
(
  p_sample_id          IN NUMBER
, p_target_spec_id     IN NUMBER
, p_target_spec_vr_id  IN NUMBER
, x_return_status      OUT NOCOPY VARCHAR2
);


PROCEDURE use_target_spec_for_cmpst_rslt
(
  p_composite_spec_disp_id IN NUMBER
, p_target_spec_id         IN NUMBER
, p_target_spec_vr_id      IN NUMBER
, x_return_status          OUT NOCOPY VARCHAR2
);


PROCEDURE get_rslt_and_spec_rslt
  (p_sample_id         IN  NUMBER,
  p_source_spec_id     IN  NUMBER,
  p_target_spec_id     IN  NUMBER,
  p_event_spec_disp_id IN  NUMBER,
  x_results_rec_tbl    OUT NOCOPY GMD_RESULTS_GRP.gmd_results_rec_tbl,
  x_return_status      OUT NOCOPY VARCHAR2);


PROCEDURE composite_exist
(
  p_sampling_event_id  IN  NUMBER
, p_event_spec_disp_id IN  NUMBER DEFAULT NULL
, x_composite_exist    OUT NOCOPY VARCHAR2
, x_composite_valid    OUT NOCOPY VARCHAR2
, x_return_status      OUT NOCOPY VARCHAR2
);


PROCEDURE se_recomposite_required
(
  p_sampling_event_id  IN  NUMBER
, p_event_spec_disp_id IN  NUMBER DEFAULT NULL
, x_return_status      OUT NOCOPY VARCHAR2
);



PROCEDURE result_recomposite_required
(
  p_result_id          IN  NUMBER
, p_event_spec_disp_id IN  NUMBER
, x_return_status      OUT NOCOPY VARCHAR2
);



PROCEDURE get_sample_ids_for_se
(
  p_sampling_event_id  IN  NUMBER
, x_sample_ids         OUT NOCOPY GMD_API_PUB.number_tab
, x_return_status      OUT NOCOPY VARCHAR2
);


PROCEDURE populate_result_data_points
(
  p_sample_ids         IN GMD_API_PUB.number_tab
, p_event_spec_disp_id IN NUMBER
, x_return_status      OUT NOCOPY VARCHAR2
);


PROCEDURE create_composite_rows
(
  p_event_spec_disp_id  IN  NUMBER
, x_return_status       OUT NOCOPY VARCHAR2
);


PROCEDURE qc_mean
(
  p_test_id       IN  NUMBER
, x_mean_num      OUT NOCOPY NUMBER
, x_return_status OUT NOCOPY VARCHAR2
);


PROCEDURE qc_median
(
  p_test_id       IN  NUMBER
, x_median_num    OUT NOCOPY NUMBER
, x_median_char   OUT NOCOPY VARCHAR2
, x_return_status OUT NOCOPY VARCHAR2
);


PROCEDURE qc_mode
(
  p_test_id       IN  NUMBER
, x_mode_num      OUT NOCOPY NUMBER
, x_mode_char     OUT NOCOPY VARCHAR2
, x_return_status OUT NOCOPY VARCHAR2
);


PROCEDURE qc_high
(
  p_test_id       IN  NUMBER
, x_high_num      OUT NOCOPY NUMBER
, x_high_char     OUT NOCOPY VARCHAR2
, x_return_status OUT NOCOPY VARCHAR2
);


PROCEDURE qc_low
(
  p_test_id       IN  NUMBER
, x_low_num       OUT NOCOPY NUMBER
, x_low_char      OUT NOCOPY VARCHAR2
, x_return_status OUT NOCOPY VARCHAR2
);


PROCEDURE qc_standard_deviation
(
  p_test_id       IN  NUMBER
, x_stddev        OUT NOCOPY NUMBER
, x_return_status OUT NOCOPY VARCHAR2
);

PROCEDURE get_composite_rslt
(
  p_composite_spec_disp_id        IN  NUMBER,
  p_source_spec_id		  IN NUMBER,
  p_target_spec_id		  IN NUMBER,
  x_comresults_tab        	  OUT NOCOPY GMD_RESULTS_GRP.gmd_comres_tab,
  x_return_status         	  OUT NOCOPY VARCHAR2);


PROCEDURE change_lot_status
( p_sample_id        IN         NUMBER
, p_organization_id  IN         NUMBER
, p_lot_status       IN         VARCHAR2
, x_return_status    OUT NOCOPY VARCHAR2
);


FUNCTION is_value_numeric (p_char_number VARCHAR2)
RETURN BOOLEAN;


PROCEDURE check_experimental_error
( p_result_rec     IN OUT NOCOPY  RESULT_DATA
, x_return_status     OUT NOCOPY  VARCHAR2
);


PROCEDURE validate_result
( p_result_rec     IN OUT NOCOPY  result_data
, x_return_status     OUT NOCOPY VARCHAR2
);


PROCEDURE validate_evaluation_ind
( p_evaluation_ind      IN         VARCHAR2
, p_in_spec_ind         IN         VARCHAR2
, p_result_value        IN         VARCHAR2
, x_return_status       OUT NOCOPY VARCHAR2
);


PROCEDURE calc_expression
( p_sample_id           IN         NUMBER
, p_event_spec_disp_id  IN         NUMBER
, p_spec_id             IN         NUMBER
, x_rslt_tbl            OUT NOCOPY rslt_tbl
, x_return_status       OUT NOCOPY VARCHAR2
);


PROCEDURE  change_sample_disposition
( p_sample_id        IN         NUMBER
, x_change_disp_to   OUT NOCOPY VARCHAR2
, x_return_status    OUT NOCOPY VARCHAR2
, x_message_data     OUT NOCOPY VARCHAR2
);


PROCEDURE change_disp_for_auto_lot
( p_sample_id           IN         NUMBER
, x_change_disp_to      OUT NOCOPY VARCHAR2
, x_return_status       OUT NOCOPY VARCHAR2
);


PROCEDURE  composite_and_change_lot
( p_sampling_event_id IN         NUMBER
, p_commit            IN         VARCHAR2
, x_return_status     OUT NOCOPY VARCHAR2
);


PROCEDURE dump_data_points;


PROCEDURE update_exptest_value_null
(p_exp_ref_test_id  IN gmd_qc_tests_b.test_id%TYPE
, p_sample_id IN gmd_samples.sample_id%TYPE
, p_event_spec_disp_id IN gmd_sample_spec_disp.event_spec_disp_id%TYPE
, x_return_status     OUT NOCOPY VARCHAR2
);

END gmd_results_grp;


/
