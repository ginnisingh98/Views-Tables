--------------------------------------------------------
--  DDL for Package GMD_STABILITY_STUDIES_GRP
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."GMD_STABILITY_STUDIES_GRP" AUTHID CURRENT_USER AS
/* $Header: GMDGSSTS.pls 120.1 2005/08/16 07:46:40 svankada noship $ */

FUNCTION Stability_Study_Exist
(
  p_stability_study_no IN VARCHAR2 ) RETURN BOOLEAN;

FUNCTION calculate_end_date
( p_storage_plan_id	IN NUMBER,
  p_start_date		IN DATE ) RETURN DATE ;

-- INVCONV
/*	This procedure is being called from the post-forms-commit trigger of the Stability Studies form.
 This procedure is not required because when we select sample group from the material sources form,
 all the validations being done in this procedure are done there itself. So, this procedure will be removed.*/
/*PROCEDURE validate_sampling_event( p_ss_id		IN NUMBER ,
				   p_item_id		IN NUMBER,
  				   p_base_spec_id	IN NUMBER) ;  */

PROCEDURE calculate_sample_qty(
						 -- p_ss_id		IN  NUMBER, INVCONV
			       p_source_id 	IN  NUMBER,
			       --p_item_id	IN  NUMBER, INVCONV
			       p_sample_qty 	OUT NOCOPY NUMBER,
			       p_sample_uom 	OUT NOCOPY VARCHAR2,
			       x_return_status	OUT NOCOPY VARCHAR2) ;

-- not needed now for INVCONV

--FUNCTION check_doc_numbering( p_doc_type  IN VARCHAR2 ,
--			      p_orgn_code IN VARCHAR2 ) RETURN NUMBER ;

PROCEDURE ss_approval_checklist_ok(p_ss_id  		IN NUMBER ,
			          x_return_status	OUT NOCOPY VARCHAR2) ;

PROCEDURE ss_launch_checklist_ok(p_ss_id  		IN NUMBER ,
			        x_return_status	OUT NOCOPY VARCHAR2) ;

PROCEDURE change_ss_status(	p_ss_id		IN	NUMBER,
				p_start_status	IN	NUMBER,
				p_target_status	IN	NUMBER,
				x_return_status OUT NOCOPY VARCHAR2,
				x_message	OUT NOCOPY VARCHAR2 ) ;

END GMD_STABILITY_STUDIES_GRP;

 

/
