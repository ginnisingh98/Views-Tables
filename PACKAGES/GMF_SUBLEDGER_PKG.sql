--------------------------------------------------------
--  DDL for Package GMF_SUBLEDGER_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."GMF_SUBLEDGER_PKG" AUTHID CURRENT_USER AS
/* $Header: gmfslups.pls 120.2 2005/10/30 20:31:32 umoogala noship $ */

/*****************************************************************************
 *  PACKAGE
 *    gmf_subledger_pkg
 *
 *  DESCRIPTION
 *    Subledger Update Process pkg
 *
 *  CONTENTS
 *    PROCEDURE	test_update ( ... )
 *
 *  HISTORY
 *    24-Dec-2002 Rajesh Seshadri - Created
 *
 ******************************************************************************/

/* Start INVCONV umoogala
PROCEDURE update_process(
	x_errbuf		OUT NOCOPY VARCHAR2,
	x_retcode		OUT NOCOPY VARCHAR2,
	p_co_code		IN VARCHAR2,
	p_gl_fiscal_year	IN VARCHAR2,
	p_gl_period		IN VARCHAR2,
	p_test_posting		IN VARCHAR2,
	p_open_gl_date		IN VARCHAR2,
	p_posting_start_date	IN VARCHAR2,
	p_posting_end_date	IN VARCHAR2,
	p_post_if_no_cost	IN VARCHAR2,
	p_post_cm		IN VARCHAR2,
	p_post_ic		IN VARCHAR2,
	p_post_om		IN VARCHAR2,
	p_post_op		IN VARCHAR2,
	p_post_pm		IN VARCHAR2,
	p_post_po		IN VARCHAR2,
	p_post_pur		IN VARCHAR2
	);

PROCEDURE validate_parameters(
	p_co_code		IN VARCHAR2,
	p_gl_fiscal_year	IN VARCHAR2,
	p_gl_period		IN VARCHAR2,
	p_test_posting		IN VARCHAR2,
	p_open_gl_date		IN VARCHAR2,
	p_posting_start_date	IN VARCHAR2,
	p_posting_end_date	IN VARCHAR2,
	p_post_cm		IN VARCHAR2,
	p_post_ic		IN VARCHAR2,
	p_post_om		IN VARCHAR2,
	p_post_op		IN VARCHAR2,
	p_post_pm		IN VARCHAR2,
	p_post_po		IN VARCHAR2,
	p_post_pur		IN VARCHAR2,
	x_closed_per_ind	OUT NOCOPY NUMBER,
	x_crev_gl_trans_date    OUT NOCOPY DATE,
	x_open_gl_fiscal_year	OUT NOCOPY NUMBER,
	x_open_gl_period	OUT NOCOPY NUMBER,
	x_crev_curr_mthd	OUT NOCOPY VARCHAR2,
	x_crev_curr_calendar	OUT NOCOPY VARCHAR2,
	x_crev_curr_period	OUT NOCOPY VARCHAR2,
	x_crev_prev_mthd	OUT NOCOPY VARCHAR2,
	x_crev_prev_calendar	OUT NOCOPY VARCHAR2,
	x_crev_prev_period	OUT NOCOPY VARCHAR2,
	x_inv_fiscal_year       OUT NOCOPY VARCHAR2,
	x_inv_period            OUT NOCOPY NUMBER,
	x_retstatus OUT NOCOPY VARCHAR2,
	x_errbuf OUT NOCOPY VARCHAR2
	);

PROCEDURE insert_control_record(
	p_co_code IN VARCHAR2,
	p_user_id IN NUMBER,
	p_gl_fiscal_year IN NUMBER,
	p_gl_period IN NUMBER,
	p_posting_start_date IN DATE,
	p_posting_end_date IN DATE,
	p_test_posting		IN VARCHAR2,
	p_post_cm		IN VARCHAR2,
	p_post_ic		IN VARCHAR2,
	p_post_om		IN VARCHAR2,
	p_post_op		IN VARCHAR2,
	p_post_pm		IN VARCHAR2,
	p_post_po		IN VARCHAR2,
	p_post_pur		IN VARCHAR2,
	p_closed_per_ind 	IN NUMBER,
	p_open_gl_date 		IN DATE,
	p_crev_gl_trans_date    IN DATE,
	p_open_gl_fiscal_year 	IN NUMBER,
	p_open_gl_period 	IN NUMBER,
	p_post_if_no_cost 	IN VARCHAR2,
	p_default_language 	IN VARCHAR2,
	p_crev_curr_mthd	IN VARCHAR2,
	p_crev_curr_calendar	IN VARCHAR2,
	p_crev_curr_period	IN VARCHAR2,
	p_crev_prev_mthd	IN VARCHAR2,
	p_crev_prev_calendar	IN VARCHAR2,
	p_crev_prev_period	IN VARCHAR2,
	p_inv_fiscal_year 	IN VARCHAR2,
	p_inv_period 		IN NUMBER,
	x_subledger_ref_no 	OUT NOCOPY NUMBER,
	x_retstatus OUT NOCOPY VARCHAR2,
	x_errbuf OUT NOCOPY VARCHAR2
	);

PROCEDURE check_costing(
	p_co_code		IN VARCHAR2,
	p_test_posting		IN VARCHAR2,
	p_period_start_date	IN DATE,
	p_period_end_date 	IN DATE,
	p_closed_period_ind 	IN  NUMBER,
	p_open_gl_date 	  	IN  DATE,
	x_crev_gl_trans_date 	OUT NOCOPY DATE,
	x_crev_curr_mthd	OUT NOCOPY VARCHAR2,
	x_crev_curr_calendar	OUT NOCOPY VARCHAR2,
	x_crev_curr_period	OUT NOCOPY VARCHAR2,
	x_crev_prev_mthd	OUT NOCOPY VARCHAR2,
	x_crev_prev_calendar	OUT NOCOPY VARCHAR2,
	x_crev_prev_period	OUT NOCOPY VARCHAR2,
	x_inv_fiscal_year   	OUT NOCOPY VARCHAR2,
	x_inv_period        	OUT NOCOPY NUMBER,
	x_retstatus 		OUT NOCOPY VARCHAR2,
	x_errbuf OUT NOCOPY VARCHAR2
	);
*/

  PROCEDURE update_process(
      x_errbuf                  OUT NOCOPY VARCHAR2
    , x_retcode                 OUT NOCOPY VARCHAR2
    , p_legal_entity_id         IN         VARCHAR2
    , p_ledger_id               IN         VARCHAR2
    , p_cost_type_id            IN         VARCHAR2
    , p_gl_fiscal_year          IN         VARCHAR2
    , p_gl_period               IN         VARCHAR2
    , p_test_posting            IN         VARCHAR2
    , p_open_gl_date            IN         VARCHAR2
    , p_posting_start_date      IN         VARCHAR2
    , p_posting_end_date        IN         VARCHAR2
    , p_post_if_no_cost         IN         VARCHAR2
    , p_process_category        IN         VARCHAR2
    , p_crev_curr_calendar      IN         VARCHAR2
    , p_crev_curr_period        IN         VARCHAR2
    , p_crev_prev_cost_type_id  IN         VARCHAR2
    , p_crev_prev_calendar      IN         VARCHAR2
    , p_crev_prev_period        IN         VARCHAR2
    , p_crev_gl_trans_date      IN         VARCHAR2
  /* start invconv umoogala
    p_co_code              in         varchar2
    p_post_cm		IN VARCHAR2,
    p_post_ic		IN VARCHAR2,
    p_post_om		IN VARCHAR2,
    p_post_op		IN VARCHAR2,
    p_post_pm		IN VARCHAR2,
    p_post_po		IN VARCHAR2,
    p_post_pur		IN VARCHAR2
  */
  );

  PROCEDURE validate_parameters(
    p_gl_fiscal_year          IN         VARCHAR2,
    p_gl_period               IN         VARCHAR2,
    p_test_posting            IN         VARCHAR2,
    p_open_gl_date            IN         VARCHAR2,
    p_posting_start_date      IN         VARCHAR2,
    p_posting_end_date        IN         VARCHAR2,
  /* Start INVCONV umoogala
    p_co_code                 IN         VARCHAR2,
    p_post_cm                 IN         VARCHAR2,
    p_post_ic                 IN         VARCHAR2,
    p_post_om                 IN         VARCHAR2,
    p_post_op                 IN         VARCHAR2,
    p_post_pm                 IN         VARCHAR2,
    p_post_po                 IN         VARCHAR2,
    p_post_pur                IN         VARCHAR2,
  */
    x_closed_per_ind          OUT NOCOPY NUMBER,
    x_crev_gl_trans_date      OUT NOCOPY DATE,
    x_open_gl_fiscal_year     OUT NOCOPY NUMBER,
    x_open_gl_period          OUT NOCOPY NUMBER,
  /* Start INVCONV umoogala
    x_crev_curr_mthd          OUT NOCOPY VARCHAR2,
    x_crev_curr_calendar      OUT NOCOPY VARCHAR2,
    x_crev_curr_period        OUT NOCOPY VARCHAR2,
    x_crev_prev_mthd          OUT NOCOPY VARCHAR2,
    x_crev_prev_calendar      OUT NOCOPY VARCHAR2,
    x_crev_prev_period        OUT NOCOPY VARCHAR2,
  */
    x_inv_fiscal_year         OUT NOCOPY NUMBER,
    x_inv_period              OUT NOCOPY NUMBER,
    x_retstatus               OUT NOCOPY VARCHAR2,
    x_errbuf               		OUT NOCOPY VARCHAR2
  );

  PROCEDURE insert_control_record(
    p_user_id                IN         NUMBER,
    p_gl_fiscal_year         IN         NUMBER,
    p_gl_period              IN         NUMBER,
    p_posting_start_date     IN         DATE,
    p_posting_end_date       IN         DATE,
    p_test_posting           IN         VARCHAR2,
  /* Start INVCONV umoogala
    p_post_cm                IN         VARCHAR2,
    p_post_ic                IN         VARCHAR2,
    p_post_om                IN         VARCHAR2,
    p_post_op                IN         VARCHAR2,
    p_post_pm                IN         VARCHAR2,
    p_post_po                IN         VARCHAR2,
    p_post_pur               IN         VARCHAR2,
  */
    p_closed_per_ind         IN         NUMBER,
    p_open_gl_date           IN         DATE,
    p_crev_gl_trans_date     IN         DATE,
    p_open_gl_fiscal_year    IN         NUMBER,
    p_open_gl_period         IN         NUMBER,
    p_post_if_no_cost        IN         VARCHAR2,
    p_default_language       IN         VARCHAR2,
  /* Start INVCONV umoogala
    p_crev_curr_mthd         IN         VARCHAR2,
    p_crev_curr_calendar     IN         VARCHAR2,
    p_crev_curr_period       IN         VARCHAR2,
    p_crev_prev_mthd         IN         VARCHAR2,
    p_crev_prev_calendar     IN         VARCHAR2,
    p_crev_prev_period       IN         VARCHAR2,
  */
    p_inv_fiscal_year        IN         VARCHAR2,
    p_inv_period             IN         NUMBER,
    x_subledger_ref_no       OUT NOCOPY NUMBER,
    x_retstatus              OUT NOCOPY VARCHAR2,
    x_errbuf                 OUT NOCOPY VARCHAR2
  );

  PROCEDURE check_costing(
    p_test_posting         IN VARCHAR2,
    p_period_start_date    IN DATE,
    p_period_end_date      IN DATE,
    p_closed_period_ind    IN  NUMBER,
    p_open_gl_date         IN  DATE,
    x_crev_gl_trans_date   OUT NOCOPY DATE,
  /* Start INVCONV umoogala
    x_crev_curr_mthd       OUT NOCOPY VARCHAR2,
    x_crev_curr_calendar   OUT NOCOPY VARCHAR2,
    x_crev_curr_period     OUT NOCOPY VARCHAR2,
    x_crev_prev_mthd       OUT NOCOPY VARCHAR2,
    x_crev_prev_calendar   OUT NOCOPY VARCHAR2,
    x_crev_prev_period     OUT NOCOPY VARCHAR2,
  */
    x_inv_fiscal_year      OUT NOCOPY NUMBER,
    x_inv_period           OUT NOCOPY NUMBER,
    x_retstatus            OUT NOCOPY VARCHAR2,
    x_errbuf               OUT NOCOPY VARCHAR2
  );

  PROCEDURE populate_global (
      p_legal_entity_id         IN         VARCHAR2
    , p_ledger_id               IN         VARCHAR2
    , p_cost_type_id            IN         VARCHAR2
    , p_post_cm                 IN         VARCHAR2
    , p_crev_curr_calendar      IN         VARCHAR2
    , p_crev_curr_period        IN         VARCHAR2
    , p_crev_prev_cost_type_id  IN         VARCHAR2
    , p_crev_prev_calendar      IN         VARCHAR2
    , p_crev_prev_period        IN         VARCHAR2
    , p_crev_gl_trans_date      IN         VARCHAR2
    )
  ;

END gmf_subledger_pkg;

 

/
