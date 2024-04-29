--------------------------------------------------------
--  DDL for Package PQH_GSP_DEFAULT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PQH_GSP_DEFAULT" AUTHID CURRENT_USER as
/* $Header: pqgspdef.pkh 115.3 2004/07/27 04:19 ggnanagu noship $ */

function get_asg_for_pil(p_per_in_ler_id  in number,
                         p_effective_date in date) return number;

procedure get_electbl_chc(p_per_in_ler_id  in number,
                          p_effective_date in date,
                          p_grade_id       in number,
                          p_step_id        in number,
                          p_electbl_chc_id out nocopy number);
procedure get_def_auto_code(p_per_in_ler_id  in number,
                            p_effective_date in date,
                            p_return_code    out nocopy varchar2,
                            p_electbl_chc_id out nocopy number);
function get_next_oipl(p_oipl_id in number,
                       p_effective_date in date) return number;
function get_next_step(p_grade_id       in number default null,
                       p_step_id        in number default null,
                       p_effective_date in date) return number;
function get_lowest_sal_incr_step(p_cur_sal        in number,
                                  p_grade_id       in number,
                                  p_effective_date in date,
                                  P_Assignment_id  in Number Default NULL) return number;
function get_sal_for_step(p_step_id in number,
                          p_effective_date in date) return number;
procedure get_default_progression(p_per_in_ler_id  in number,
                                  p_effective_date in date,
                                  p_electbl_chc_id out nocopy number,
                                  p_return_code    out nocopy varchar2,
                                  p_error_message out nocopy varchar2);
function get_default_gl(p_effective_date in date,
                        p_business_group_id in number) return number;
procedure get_gl_details(p_gl_id          in number,
                         p_effective_date in date,
                         p_prog_style_cd  out nocopy varchar2,
                         p_post_style_cd  out nocopy varchar2,
                         p_gl_name        out nocopy varchar2,
                         p_dflt_step_cd   out nocopy varchar2,
                         p_dflt_step_rl   out nocopy varchar2);
function get_next_grade(p_grade_id in number,
                        p_gl_id in number,
                        p_effective_date in date) return number;
function get_next_plan(p_pl_id          in number,
                       p_gl_id          in number,
                       p_effective_date in date) return number ;
function get_cur_sal(p_assignment_id   in number,
                     p_effective_date  in date) return number;
procedure get_emp_step_placement(p_assignment_id  in number,
                                 p_effective_date in date,
                                 p_emp_step_id    out nocopy number,
                                 p_num_incr       out nocopy number);
procedure step_progression(p_effective_date in date,
                           p_step_id        in number,
                           p_num_incr       in number,
                           p_ceiling_step_id in number,
                           p_future_step_id  in number,
                           p_next_step_id    out nocopy number);
procedure grd_step_progression_result(p_grade_id        in number,
                                      p_step_id         in number,
                                      p_gl_id           in number,
                                      p_assignment_id   in number,
                                      p_effective_date  in date,
                                      p_ceiling_step_id in number,
                                      p_dflt_step_cd    in varchar2,
                                      p_num_incr        in number,
                                      p_future_step_id  in number,
                                      p_next_grade_id   out nocopy number,
                                      p_next_step_id    out nocopy number);
procedure grade_progression(p_assignment_id  in number,
                            p_effective_date in date,
                            p_grade_id       in number,
                            p_gl_id          in number,
                            p_next_grade_id  out nocopy number);
function get_default_step(p_next_grade_id  in number,
                          p_assignment_id  in number,
                          p_dflt_step_cd   in varchar2,
                          p_effective_date in date) return number;
procedure get_step_seq(p_step_id        in number,
                       p_effective_date in date,
                       p_step_seq       out nocopy number,
                       p_grade_spine_id out nocopy number);
function is_grade_in_gl(p_grade_id in number,
                        p_gl_id    in number,
                        p_effective_date in date) return number;
procedure next_asg_grade_step(p_assignment_id   in number,
                              p_cur_asg_eed     in date,
                              p_future_grade_id out nocopy number,
                              p_future_step_id  out nocopy number);
function get_annual_sal(p_assignment_id   in number,
                     p_effective_date  in date) return number;
end pqh_gsp_default;

 

/
