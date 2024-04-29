--------------------------------------------------------
--  DDL for Package PA_CI_IMPACTS_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PA_CI_IMPACTS_PVT" AUTHID CURRENT_USER AS
/* $Header: PACIIPVS.pls 115.3 2002/11/23 19:23:05 syao noship $ */

PROCEDURE create_ci_impact (
  p_api_version			IN NUMBER :=  1.0,
  p_init_msg_list		IN VARCHAR2 := 'T',
  p_commit			IN VARCHAR2 := 'F',
  p_validate_only		IN VARCHAR2 := 'T',
  p_max_msg_count		IN NUMBER := null,

  p_ci_id IN NUMBER := null,
  p_impact_type_code IN VARCHAR2  := null,

  p_status_code IN VARCHAR2  := null,
  p_description IN VARCHAR2  := null,
  p_implementation_date IN DATE := null,
  p_implemented_by IN NUMBER := null,
  p_implementation_comment IN VARCHAR2 := null,
  p_impacted_task_id IN NUMBER := null,
  x_ci_impact_id		OUT NOCOPY NUMBER,
  x_return_status		OUT NOCOPY VARCHAR2,
  x_msg_count			OUT NOCOPY NUMBER,
  x_msg_data			OUT NOCOPY VARCHAR2
) ;


PROCEDURE delete_ci_impact (
  p_api_version			IN NUMBER :=  1.0,
  p_init_msg_list		IN VARCHAR2 := 'T',
  p_commit			IN VARCHAR2 := 'F',
  p_validate_only		IN VARCHAR2 := 'T',
  p_max_msg_count		IN NUMBER := null,

  p_ci_impact_id	        IN NUMBER := null,
  p_record_version_number       IN NUMBER :=  null,
  x_return_status		OUT NOCOPY VARCHAR2,
  x_msg_count			OUT NOCOPY NUMBER,
  x_msg_data			OUT NOCOPY VARCHAR2
) ;


PROCEDURE update_ci_impact (
  p_api_version			IN NUMBER :=  1.0,
  p_init_msg_list		IN VARCHAR2 := 'T',
  p_commit			IN VARCHAR2 := 'F',
  p_validate_only		IN VARCHAR2 := 'T',
  p_max_msg_count		IN NUMBER := null,
  p_ci_impact_id		IN  NUMBER:= null,
  p_ci_id IN NUMBER := null,
  p_impact_type_code IN VARCHAR2  := null,
  p_status_code IN VARCHAR2  := null,
  p_description IN VARCHAR2  := null,
  p_implementation_date IN DATE := null,
  p_implemented_by IN NUMBER := null,
  p_impby_name IN VARCHAR2 := null,
  p_impby_type_id IN NUMBER := null,
  p_implementation_comment IN VARCHAR2 := null,
  p_record_version_number       IN NUMBER :=  null,
  p_impacted_task_id IN NUMBER := null,

  x_return_status		OUT NOCOPY VARCHAR2,
  x_msg_count			OUT NOCOPY NUMBER,
  x_msg_data			OUT NOCOPY VARCHAR2
) ;


END pa_ci_impacts_pvt;

 

/
