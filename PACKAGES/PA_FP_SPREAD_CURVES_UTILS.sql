--------------------------------------------------------
--  DDL for Package PA_FP_SPREAD_CURVES_UTILS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PA_FP_SPREAD_CURVES_UTILS" AUTHID CURRENT_USER as
/* $Header: PAFPSCUS.pls 120.1.12010000.2 2010/01/28 23:52:17 snizam ship $ */

  -- start  of code changes for 9036322
  TYPE  t1  IS  TABLE  OF  pa_resource_assignments.spread_curve_id%TYPE  INDEX  BY  binary_integer;
   G_curve_id_tbl  t1;
   G_is_first_call VARCHAR2 (1) := 'Y';
  -- End  of code changes for 9036322

FUNCTION is_spread_curve_in_use ( p_spread_curve_id IN Pa_spread_curves_b.spread_curve_id%TYPE ) RETURN VARCHAR2;

PROCEDURE validate (
        p_spread_curve_id       IN              Pa_spread_curves_b.spread_curve_id%TYPE,
	p_name                  IN              Pa_spread_curves_tl.name%TYPE,
	P_effective_from        IN              Pa_spread_curves_b.effective_Start_date%TYPE,
	P_effective_to		IN              Pa_spread_curves_b.effective_end_date%TYPE,
	P_point1                IN              Pa_spread_curves_b.point1%TYPE,
	P_point2                IN              Pa_spread_curves_b.point2%TYPE,
	P_point3                IN              Pa_spread_curves_b.point3%TYPE,
	P_point4                IN              Pa_spread_curves_b.point4%TYPE,
	P_point5                IN              Pa_spread_curves_b.point5%TYPE,
	P_point6                IN              Pa_spread_curves_b.point6%TYPE,
	P_point7                IN              Pa_spread_curves_b.point7%TYPE,
	P_point8                IN              Pa_spread_curves_b.point8%TYPE,
	P_point9                IN              Pa_spread_curves_b.point9%TYPE,
	P_point10               IN              Pa_spread_curves_b.point10%TYPE,
	x_return_status	        OUT             NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
	x_msg_data             OUT             NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
	x_msg_count             OUT             NOCOPY number	 ); --File.Sql.39 bug 4440895

PROCEDURE validate_name
    (p_name                         IN     pa_spread_curves_tl.name%TYPE,
     p_spread_curve_id             IN     pa_spread_curves_tl.spread_curve_id%TYPE,
     x_return_status                OUT    NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
     x_msg_count                    OUT    NOCOPY NUMBER, --File.Sql.39 bug 4440895
     x_msg_data                     OUT    NOCOPY VARCHAR2); --File.Sql.39 bug 4440895

PROCEDURE validate_amount_in_buckets(
	P_point1                IN        Pa_spread_curves_b.point1%TYPE,
	P_point2                IN        Pa_spread_curves_b.point2%TYPE,
	P_point3                IN        Pa_spread_curves_b.point3%TYPE,
	P_point4                IN        Pa_spread_curves_b.point4%TYPE,
	P_point5                IN        Pa_spread_curves_b.point5%TYPE,
	P_point6                IN        Pa_spread_curves_b.point6%TYPE,
	P_point7                IN        Pa_spread_curves_b.point7%TYPE,
	P_point8                IN        Pa_spread_curves_b.point8%TYPE,
	P_point9                IN        Pa_spread_curves_b.point9%TYPE,
	P_point10               IN        Pa_spread_curves_b.point10%TYPE,
	x_return_status         OUT       NOCOPY VARCHAR2,  --File.Sql.39 bug 4440895
	x_msg_data             OUT       NOCOPY VARCHAR2,  --File.Sql.39 bug 4440895
	x_msg_count             OUT       NOCOPY number); --File.Sql.39 bug 4440895

END pa_fp_spread_curves_utils;

/
