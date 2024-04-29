--------------------------------------------------------
--  DDL for Package PQH_BDGT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PQH_BDGT" AUTHID CURRENT_USER as
/* $Header: pqbudget.pkh 115.9 2002/11/27 04:43:03 rpasapul ship $ */

procedure propagate_version_changes (p_change_mode           in varchar2,
                                     p_budget_version_id     in number,
				     p_budget_style_cd       in varchar2,
                                     p_new_bgv_unit1_value   in number,
                                     p_new_bgv_unit2_value   in number,
                                     p_new_bgv_unit3_value   in number,
                                     p_unit1_precision       in number,
                                     p_unit2_precision       in number,
                                     p_unit3_precision       in number,
				     p_unit1_aggregate       in varchar2,
				     p_unit2_aggregate       in varchar2,
				     p_unit3_aggregate       in varchar2,
                                     p_budget_version_status in out nocopy varchar2,
                                     p_bgv_unit1_available   in out nocopy number,
                                     p_bgv_unit2_available   in out nocopy number,
                                     p_bgv_unit3_available   in out nocopy number
);

procedure propagate_budget_changes (p_change_mode           in varchar2,
                                    p_budget_detail_id      in number,
                                    p_new_bgt_unit1_value   in number,
                                    p_new_bgt_unit2_value   in number,
                                    p_new_bgt_unit3_value   in number,
                                    p_unit1_precision       in number,
                                    p_unit2_precision       in number,
                                    p_unit3_precision       in number,
				    p_unit1_aggregate       in varchar2,
				    p_unit2_aggregate       in varchar2,
				    p_unit3_aggregate       in varchar2,
                                    p_bgt_unit1_available   in out nocopy number,
                                    p_bgt_unit2_available   in out nocopy number,
                                    p_bgt_unit3_available   in out nocopy number
);

procedure propagate_period_changes (p_change_mode          in varchar2,
                                    p_budget_period_id     in number,
                                    p_new_prd_unit1_value  in number,
                                    p_new_prd_unit2_value  in number,
                                    p_new_prd_unit3_value  in number,
                                    p_unit1_precision      in number,
                                    p_unit2_precision      in number,
                                    p_unit3_precision      in number,
                                    p_prd_unit1_available  in out nocopy number,
                                    p_prd_unit2_available  in out nocopy number,
                                    p_prd_unit3_available  in out nocopy number
);

procedure insert_budget_detail(
  p_budget_version_id           in number,
  p_organization_id             in number           default null,
  p_job_id                      in number           default null,
  p_position_id                 in number           default null,
  p_grade_id                    in number           default null,
  p_budget_unit1_percent        in number           default null,
  p_budget_unit1_value          in number           default null,
  p_budget_unit2_percent        in number           default null,
  p_budget_unit2_value          in number           default null,
  p_budget_unit3_percent        in number           default null,
  p_budget_unit3_value          in number           default null,
  p_budget_unit1_value_type_cd  in varchar2         default null,
  p_budget_unit2_value_type_cd  in varchar2         default null,
  p_budget_unit3_value_type_cd  in varchar2         default null,
  p_gl_status                   in varchar2         default null,
  p_budget_unit1_available      in number           default null,
  p_budget_unit2_available      in number           default null,
  p_budget_unit3_available      in number           default null,
  p_budget_detail_id               out nocopy number
) ;

Procedure update_budget_detail
  (
  p_budget_detail_id             in number,
  p_budget_version_id            in number           default hr_api.g_number,
  p_organization_id              in number           default hr_api.g_number,
  p_job_id                       in number           default hr_api.g_number,
  p_position_id                  in number           default hr_api.g_number,
  p_grade_id                     in number           default hr_api.g_number,
  p_budget_unit1_percent         in number           default hr_api.g_number,
  p_budget_unit1_value           in number           default hr_api.g_number,
  p_budget_unit2_percent         in number           default hr_api.g_number,
  p_budget_unit2_value           in number           default hr_api.g_number,
  p_budget_unit3_percent         in number           default hr_api.g_number,
  p_budget_unit3_value           in number           default hr_api.g_number,
  p_object_version_number        in out nocopy number,
  p_budget_unit1_value_type_cd   in varchar2         default hr_api.g_varchar2,
  p_budget_unit2_value_type_cd   in varchar2         default hr_api.g_varchar2,
  p_budget_unit3_value_type_cd   in varchar2         default hr_api.g_varchar2,
  p_gl_status                    in varchar2         default hr_api.g_varchar2,
  p_budget_unit1_available       in number           default hr_api.g_number,
  p_budget_unit2_available       in number           default hr_api.g_number,
  p_budget_unit3_available       in number           default hr_api.g_number
  ) ;

procedure bgv_date_validation( p_budget_id          in number,
			       p_version_number     in number ,
			       p_date_from          in date,
			       p_date_to            in date,
			       p_bgv_ll_date        out nocopy date,
			       p_bgv_ul_date        out nocopy date,
			       p_status             out nocopy varchar2) ;
function gl_post(p_budget_version_id in number) return number ;

end pqh_bdgt;

 

/
