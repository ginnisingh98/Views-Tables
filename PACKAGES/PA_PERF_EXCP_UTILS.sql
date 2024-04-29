--------------------------------------------------------
--  DDL for Package PA_PERF_EXCP_UTILS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PA_PERF_EXCP_UTILS" AUTHID CURRENT_USER AS
/* $Header: PAPEUTLS.pls 120.1 2005/08/19 16:40:16 mwasowic noship $ */

--Merge exception
RAISE_MERGE_ERROR   EXCEPTION;
PRAGMA EXCEPTION_INIT(RAISE_MERGE_ERROR, -501);

Procedure get_kpa_color_indicator_list
  (
   p_object_type in varchar2
   , p_object_id in number
   , p_kpa_codes  in SYSTEM.PA_VARCHAR2_30_TBL_TYPE
   , x_indicators  out NOCOPY SYSTEM.PA_VARCHAR2_2000_TBL_TYPE --File.Sql.39 bug 4440895
   , x_return_status           OUT     NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
   , x_msg_count               OUT     NOCOPY NUMBER --File.Sql.39 bug 4440895
   , x_msg_data                OUT     NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
   , x_ind_meaning  out NOCOPY SYSTEM.PA_VARCHAR2_80_TBL_TYPE	   --Added for bug 4064923 --File.Sql.39 bug 4440895
   ) ;


Procedure get_kpa_name_list
  (
   p_kpa_codes  in SYSTEM.PA_VARCHAR2_30_TBL_TYPE
   , x_kpa_names  OUT  NOCOPY SYSTEM.PA_VARCHAR2_240_TBL_TYPE --File.Sql.39 bug 4440895
   , x_return_status           OUT     NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
   , x_msg_count               OUT     NOCOPY NUMBER --File.Sql.39 bug 4440895
   , x_msg_data                OUT     NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
   );

Function get_kpa_color_indicator
  (
  p_object_type in varchar2
  ,p_object_id in number
  , p_kpa_code in varchar2
  ) return VARCHAR2;

Function get_measure_indicator
  (
   p_object_type in varchar2
   ,p_object_id in number
   ,p_measure_id in number
   ,p_period_type in VARCHAR2 DEFAULT NULL
   ,p_period_name in VARCHAR2 DEFAULT NULL
   ,p_raw_text_flag in VARCHAR2 DEFAULT 'Y'
   ,x_perf_txn_id out NOCOPY NUMBER --File.Sql.39 bug 4440895
   ,x_excp_meaning out NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
  ) return VARCHAR2;


Function get_measure_indicator_list
  (
   p_object_type in varchar2
   ,p_object_id in number
   ,p_measure_id in SYSTEM.PA_NUM_TBL_TYPE
   ,p_period_type in VARCHAR2 DEFAULT NULL
   ,p_period_name in VARCHAR2 DEFAULT NULL
   ,p_raw_text_flag in VARCHAR2 DEFAULT 'Y'
   ,x_perf_txn_id out NOCOPY SYSTEM.PA_NUM_TBL_TYPE --File.Sql.39 bug 4440895
   ,x_excp_meaning out NOCOPY SYSTEM.PA_VARCHAR2_80_TBL_TYPE --File.Sql.39 bug 4440895
  ) return SYSTEM.PA_VARCHAR2_2000_TBL_TYPE;


Procedure copy_object_rule_assoc
  (
  p_from_object_type in varchar2
  ,p_from_object_id in number
  ,p_to_object_type in varchar2
  ,p_to_object_id in number
  , x_msg_count      OUT    NOCOPY NUMBER --File.Sql.39 bug 4440895
  , x_msg_data       OUT    NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
  , x_return_status    OUT    NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
  );


Procedure delete_object_exceptions
  (
   p_object_type in varchar2
  ,p_object_id in number
  , x_msg_count      OUT    NOCOPY NUMBER --File.Sql.39 bug 4440895
  , x_msg_data       OUT    NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
  , x_return_status    OUT    NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
  ) ;


	  Procedure start_exception_engine
	    (
				   p_project_id in NUMBER DEFAULT NULL
				   ,p_generate_exceptions   IN      VARCHAR2 DEFAULT 'Y'
				   ,p_generate_scoring      IN      VARCHAR2 DEFAULT 'Y'
				   ,p_generate_notification IN      VARCHAR2 DEFAULT 'N'
				   ,p_purge                 IN      VARCHAR2 DEFAULT 'N'
				   ,p_daysold               IN      NUMBER   DEFAULT NULL
				   ,x_request_id     OUT    NOCOPY NUMBER --File.Sql.39 bug 4440895
				   ,x_msg_count      OUT    NOCOPY NUMBER --File.Sql.39 bug 4440895
				   ,x_msg_data       OUT    NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
				   ,x_return_status  OUT    NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
				   );


end PA_PERF_EXCP_UTILS ;

 

/
