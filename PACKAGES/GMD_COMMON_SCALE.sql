--------------------------------------------------------
--  DDL for Package GMD_COMMON_SCALE
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."GMD_COMMON_SCALE" AUTHID CURRENT_USER AS
/* $Header: GMDVSCLS.pls 120.0 2005/05/25 19:47:24 appldev noship $ */

  TYPE gme_material_details_tab IS TABLE OF gme_material_details%ROWTYPE index by binary_integer;


  TYPE fm_matl_dtl_tab IS TABLE OF fm_matl_dtl%ROWTYPE index by binary_integer;
/*
  TYPE lm_form_dtl_tab IS TABLE OF lm_form_dtl%ROWTYPE index by binary_integer;
*/

-- NPD Convergence
-- G_profile_fm_yield_type VARCHAR2(80) DEFAULT FND_PROFILE.VALUE('FM_YIELD_TYPE') ;

/***************************************************************************
 * V.Anitha    5-Mar-2004    BUG#3018432
 *                           Modified the scale_multiple datatype to NUMBER
 *                           from PLS_INTEGER to store decimal values also.
 **************************************************************************/

  TYPE scale_rec IS RECORD
  (  line_no			NUMBER
  ,  line_type  		NUMBER
  ,  inventory_item_id    	NUMBER          -- NPD Convergence
  ,  qty        		NUMBER
  ,  detail_uom    		VARCHAR2(25)    -- NPD Convergence
  ,  scale_type 		NUMBER
  ,  contribute_yield_ind 	VARCHAR2(1)
  ,  scale_multiple		NUMBER
  ,  scale_rounding_variance	NUMBER
  ,  rounding_direction		NUMBER
  );
  TYPE scale_tab IS TABLE OF scale_rec index by binary_integer ;

  PROCEDURE scale
  (  p_scale_tab        IN scale_tab
  ,  p_orgn_id          IN NUMBER   -- Added for NPD Conv.
  ,  p_scale_factor     IN NUMBER
  ,  p_primaries        IN VARCHAR2
  ,  x_scale_tab        OUT NOCOPY scale_tab
  ,  x_return_status    OUT NOCOPY VARCHAR2
  );


  PROCEDURE integer_multiple_scale
  (  p_scale_rec	    IN scale_rec
  ,  x_scale_rec	    OUT NOCOPY scale_rec
  ,  x_return_status	OUT NOCOPY VARCHAR2
  );

/***************************************************************************
 * V.Anitha    5-Mar-2004    BUG#3018432
 *                           Modified the p_scale_multiple datatype to NUMBER
 *                           from PLS_INTEGER to store decimal values also.
 **************************************************************************/

  PROCEDURE floor_down
   ( p_a	         IN NUMBER
  ,  p_scale_multiple    IN NUMBER
  ,  x_floor_qty	OUT NOCOPY NUMBER
  ,  x_return_status	OUT NOCOPY VARCHAR2
  );

/***************************************************************************
 * V.Anitha    5-Mar-2004    BUG#3018432
 *                           Modified the p_scale_multiple datatype to NUMBER
 *                           from PLS_INTEGER to store decimal values also.
 **************************************************************************/

  PROCEDURE ceil_up
   ( p_a	         IN NUMBER
  ,  p_scale_multiple    IN NUMBER
  ,  x_ceil_qty		OUT NOCOPY NUMBER
  ,  x_return_status	OUT NOCOPY VARCHAR2
  );

  PROCEDURE scale
  (  p_fm_matl_dtl_tab    IN fm_matl_dtl_tab
  ,  p_orgn_id            IN NUMBER     -- Added for NPD Conv.
  ,  p_scale_factor       IN NUMBER
  ,  p_primaries          IN VARCHAR2
  ,  x_fm_matl_dtl_tab    OUT NOCOPY fm_matl_dtl_tab
  ,  x_return_status      OUT NOCOPY VARCHAR2
  );

/*
--************************************************************
  PROCEDURE scale
  (  p_lm_form_dtl_tab    IN lm_form_dtl_tab
  ,  p_scale_factor       IN NUMBER
  ,  p_primaries          IN VARCHAR2
  ,  x_lm_form_dtl_tab    OUT NOCOPY lm_form_dtl_tab
  ,  x_return_status      OUT NOCOPY VARCHAR2
  );
--************************************************************
*/

  PROCEDURE theoretical_yield
  (  p_scale_tab    IN scale_tab
  ,  p_orgn_id      IN NUMBER   -- Added for NPD Conv.
  ,  p_scale_factor IN NUMBER
  ,  x_scale_tab    OUT NOCOPY scale_tab
  ,  x_return_status      OUT NOCOPY VARCHAR2
  );



END gmd_common_scale;

 

/
