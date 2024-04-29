--------------------------------------------------------
--  DDL for Package PAY_COSTING_KFF_UTIL_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PAY_COSTING_KFF_UTIL_PKG" AUTHID CURRENT_USER AS
/* $Header: pykffutl.pkh 115.4 2003/09/25 10:09:00 swinton ship $ */
/*===========================================================================*
 |               Copyright (c) 1994 Oracle Corporation                       |
 |                       All rights reserved.                                |
 *===========================================================================*/
/*
REM
REM Version    Date        Author      Reason
REM 115.4      25-Sep-2003 swinton     Enhancement 3121279. Added:
REM                                    - cost_keyflex_segment_defined function
REM                                    - get_cost_keyflex_segment_value
REM                                      function
REM                                    - get_cost_keyflex_structure function
REM                                    - validate_costing_keyflex procedure
REM                                    The above are required to support the
REM                                    View Cost Allocation Keyflex OA
REM                                    Framework pages.
REM 115.3      25-MAY-2003 A.Logue     NOCOPY changes. Bug 2961843.
REM 110.2      29-Oct-1999 A.Logue     costing_kff_null_default_segs
REM                                    procedure.
REM 110.0      24-Dec-1998 S.Billing   Created file
REM
*/



PROCEDURE costing_kff_seg_behaviour (
  p_level            	IN VARCHAR2,
  p_cost_id_flex_num 	IN NUMBER,
  p_required			OUT NOCOPY VARCHAR2,
  p_allownulls			OUT NOCOPY VARCHAR2
  );

PROCEDURE costing_kff_null_default_segs(
  p_level               IN     VARCHAR2,
  p_cost_id_flex_num    IN     NUMBER,
  p_segment1            IN OUT NOCOPY VARCHAR2,
  p_segment2            IN OUT NOCOPY VARCHAR2,
  p_segment3            IN OUT NOCOPY VARCHAR2,
  p_segment4            IN OUT NOCOPY VARCHAR2,
  p_segment5            IN OUT NOCOPY VARCHAR2,
  p_segment6            IN OUT NOCOPY VARCHAR2,
  p_segment7            IN OUT NOCOPY VARCHAR2,
  p_segment8            IN OUT NOCOPY VARCHAR2,
  p_segment9            IN OUT NOCOPY VARCHAR2,
  p_segment10           IN OUT NOCOPY VARCHAR2,
  p_segment11           IN OUT NOCOPY VARCHAR2,
  p_segment12           IN OUT NOCOPY VARCHAR2,
  p_segment13           IN OUT NOCOPY VARCHAR2,
  p_segment14           IN OUT NOCOPY VARCHAR2,
  p_segment15           IN OUT NOCOPY VARCHAR2,
  p_segment16           IN OUT NOCOPY VARCHAR2,
  p_segment17           IN OUT NOCOPY VARCHAR2,
  p_segment18           IN OUT NOCOPY VARCHAR2,
  p_segment19           IN OUT NOCOPY VARCHAR2,
  p_segment20           IN OUT NOCOPY VARCHAR2,
  p_segment21           IN OUT NOCOPY VARCHAR2,
  p_segment22           IN OUT NOCOPY VARCHAR2,
  p_segment23           IN OUT NOCOPY VARCHAR2,
  p_segment24           IN OUT NOCOPY VARCHAR2,
  p_segment25           IN OUT NOCOPY VARCHAR2,
  p_segment26           IN OUT NOCOPY VARCHAR2,
  p_segment27           IN OUT NOCOPY VARCHAR2,
  p_segment28           IN OUT NOCOPY VARCHAR2,
  p_segment29           IN OUT NOCOPY VARCHAR2,
  p_segment30           IN OUT NOCOPY VARCHAR2
  );

function cost_keyflex_segment_defined (
  p_cost_id_flex_num in number,
  p_segment_name in varchar2) return varchar2;

function get_cost_keyflex_segment_value (
  p_segment_name in varchar2,
  p_value_set_id in number,
  p_value_set_application_id in number,
  p_assignment_id in number,
  p_cost_allocation_id in number,
  p_element_entry_id in number,
  p_effective_date in date
  ) return varchar2;

procedure validate_costing_keyflex (
    p_cost_id_flex_num in number
  , p_concat_segments in varchar2
  , p_validation_date in date
  , p_resp_appl_id in number
  , p_resp_id in number
  , p_user_id in number
  , p_cost_allocation_keyflex_id out nocopy number
  , p_error_segment_num out nocopy number
  , p_error_segment_name out nocopy varchar2
  , p_application_col_name out nocopy varchar2
  , p_error_message out nocopy varchar2
  ) ;

function get_cost_keyflex_structure (
  p_cost_id_flex_num in number
  ) return varchar2;

END pay_costing_kff_util_pkg;

 

/
