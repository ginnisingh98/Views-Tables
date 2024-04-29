--------------------------------------------------------
--  DDL for Package PA_CI_IMPACT_TYPE_USAGE_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PA_CI_IMPACT_TYPE_USAGE_PUB" AUTHID CURRENT_USER AS
/* $Header: PACIIMPS.pls 120.0.12010000.3 2009/06/08 18:48:49 cklee ship $ */
PROCEDURE create_ci_impact_type_usage (
  p_api_version			IN NUMBER :=  1.0,
  p_init_msg_list		IN VARCHAR2 := 'T',
  p_commit			IN VARCHAR2 := 'F',
  p_validate_only		IN VARCHAR2 := 'T',
  p_max_msg_count		IN NUMBER := null,

  p_impact_type_code IN VARCHAR2  := null,
  p_ci_type_class_code IN VARCHAR2  := null,
  p_CI_TYPE_ID in NUMBER := null,

  p_created_by			IN NUMBER DEFAULT fnd_global.user_id,
  p_creation_date		IN DATE DEFAULT SYSDATE,
  p_last_update_login		IN NUMBER DEFAULT fnd_global.login_id,

--start:|   16-FEB-2009  cklee  R12.1.2 setup ehancement
  P_IMPACT_TYPE_CODE_ORDER IN NUMBER  default null,
--end:|   16-FEB-2009  cklee  R12.1.2 setup ehancement
  x_ci_impact_type_usage_id		OUT NOCOPY NUMBER,
  x_return_status		OUT NOCOPY VARCHAR2,
  x_msg_count			OUT NOCOPY NUMBER,
  x_msg_data			OUT NOCOPY VARCHAR2
				       ) ;
--start:|   16-FEB-2009  cklee  R12.1.2 setup ehancement

PROCEDURE update_ci_impact_type_usage (
  p_api_version			IN NUMBER :=  1.0,
  p_init_msg_list		IN VARCHAR2 := 'T',
  p_commit			IN VARCHAR2 := 'F',
  p_validate_only		IN VARCHAR2 := 'T',
  p_max_msg_count		IN NUMBER := null,

  p_ci_impact_type_usage_id	IN NUMBER,
  P_IMPACT_TYPE_CODE_ORDER IN NUMBER,

  x_return_status		OUT NOCOPY VARCHAR2,
  x_msg_count			OUT NOCOPY NUMBER,
  x_msg_data			OUT NOCOPY VARCHAR2
) ;
--end:|   16-FEB-2009  cklee  R12.1.2 setup ehancement



PROCEDURE delete_ci_impact_type_usage (
  p_api_version			IN NUMBER :=  1.0,
  p_init_msg_list		IN VARCHAR2 := 'T',
  p_commit			IN VARCHAR2 := 'F',
  p_validate_only		IN VARCHAR2 := 'T',
  p_max_msg_count		IN NUMBER := null,

  p_ci_impact_type_usage_id	IN NUMBER := null,
  p_impact_type_code            IN VARCHAR2 := null,
  p_ci_type_class_code          IN VARCHAR2 := null,
  p_ci_type_id                  IN NUMBER := null,
 --start:|   16-FEB-2009  cklee  R12.1.2 setup ehancement
  P_IMPACT_TYPE_CODE_ORDER IN NUMBER  default null,
--end:|   16-FEB-2009  cklee  R12.1.2 setup ehancement
 x_return_status		OUT NOCOPY VARCHAR2,
  x_msg_count			OUT NOCOPY NUMBER,
  x_msg_data			OUT NOCOPY VARCHAR2
) ;

FUNCTION delete_impact_type_usage_ok
  (
   p_impact_type_code            IN VARCHAR2 ,
   p_ci_type_id                  IN NUMBER
   ) RETURN VARCHAR2;

END PA_CI_IMPACT_TYPE_USAGE_PUB;

/
