--------------------------------------------------------
--  DDL for Package PA_CI_IMPACTS_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PA_CI_IMPACTS_PUB" AUTHID CURRENT_USER AS
/* $Header: PACIIPPS.pls 115.4 2002/11/23 19:23:00 syao noship $ */

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
  p_implemented_by IN NUMBER := NULL,
  p_implementation_comment IN VARCHAR2 := null,
  p_impacted_task_id IN NUMBER := null,
  p_impacted_task_name IN VARCHAR2  := NULL,

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
  p_description IN VARCHAR2   := FND_API.g_miss_char,
  p_implementation_date IN DATE := FND_API.g_miss_date,
  p_implemented_by IN NUMBER := FND_API.g_miss_num,
  p_impby_name IN VARCHAR2 := NULL,
  p_impby_type_id IN NUMBER := null,
  p_implementation_comment IN VARCHAR2 := FND_API.g_miss_char,
  p_record_version_number       IN NUMBER :=  null,
  p_impacted_task_id IN NUMBER := FND_API.g_miss_num,
  p_impacted_task_name IN VARCHAR2  := NULL,

  x_return_status		OUT NOCOPY VARCHAR2,
  x_msg_count			OUT NOCOPY NUMBER,
  x_msg_data			OUT NOCOPY VARCHAR2
);


END pa_ci_impacts_pub;

 

/
