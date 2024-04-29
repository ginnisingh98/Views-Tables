--------------------------------------------------------
--  DDL for Package PA_CI_IMPACT_TYPE_USAGE_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PA_CI_IMPACT_TYPE_USAGE_PVT" AUTHID CURRENT_USER AS
/* $Header: PACIIMVS.pls 120.0.12010000.2 2009/06/08 19:01:50 cklee ship $ */

  ---------------------------------------------------------------------------
  -- GLOBAL CONSTANTS
  ---------------------------------------------------------------------------
  G_CREATE			CONSTANT VARCHAR2(10) := 'CREATE';
  G_UPDATE			CONSTANT VARCHAR2(10) := 'UPDATE';
  G_VIEW			CONSTANT VARCHAR2(10) := 'INSERT';
  G_ISSUE			CONSTANT VARCHAR2(10) := 'ISSUE';
  G_CHANGE_ORDER    CONSTANT VARCHAR2(15) := 'CHANGE_ORDER';
  G_CHANGE_REQUEST  CONSTANT VARCHAR2(15) := 'CHANGE_REQUEST';
--------------------------------------------------------------------------------
-- ERRORS AND EXCEPTIONS
--------------------------------------------------------------------------------

G_EXCEPTION_ERROR		EXCEPTION;
G_EXCEPTION_UNEXPECTED_ERROR	EXCEPTION;

  TYPE impact_rec_type is RECORD
     (--ci_impact_type_usage_id pa_ci_impact_type_usage.ci_impact_type_usage_id%type := OKL_API.G_MISS_NUM,
	  impact_type_code        pa_ci_impact_type_usage.IMPACT_TYPE_CODE%type)
	  --impact_type_code_order  pa_ci_impact_type_usage.IMPACT_TYPE_CODE_ORDER%type := OKL_API.G_MISS_NUM)
     ;
  TYPE impact_tbl_type IS TABLE OF impact_rec_type
        INDEX BY BINARY_INTEGER;


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
);

--start:|   16-FEB-2009  cklee  R12.1.2 setup ehancement

PROCEDURE apply_ci_impact_type_usage (
  p_api_version			IN NUMBER :=  1.0,
  p_init_msg_list		IN VARCHAR2 := 'T',
  p_commit			    IN VARCHAR2 := 'F',
  p_validate_only		IN VARCHAR2 := 'T',
  p_max_msg_count		IN NUMBER := null,

  p_ui_mode             IN VARCHAR2,
  p_ci_class_code		IN VARCHAR2,
  p_ci_type_id          IN NUMBER,
  p_impact_tbl          IN impact_tbl_type,

--  x_impact_tbl          OUT NOCOPY impact_tbl_type,
  x_return_status		OUT NOCOPY VARCHAR2,
  x_msg_count			OUT NOCOPY NUMBER,
  x_msg_data			OUT NOCOPY VARCHAR2
);
--end:|   16-FEB-2009  cklee  R12.1.2 setup ehancement

--start:|   16-FEB-2009  cklee  R12.1.2 setup ehancement

PROCEDURE update_ci_impact_type_usage (
  p_api_version			IN NUMBER :=  1.0,
  p_init_msg_list		IN VARCHAR2 := 'T',
  p_commit			IN VARCHAR2 := 'F',
  p_validate_only		IN VARCHAR2 := 'T',
  p_max_msg_count		IN NUMBER := null,

  P_IMPACT_TYPE_CODE_ORDER IN NUMBER,
  p_ci_impact_type_usage_id		IN NUMBER,

  x_return_status		OUT NOCOPY VARCHAR2,
  x_msg_count			OUT NOCOPY NUMBER,
  x_msg_data			OUT NOCOPY VARCHAR2
);
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

END pa_ci_impact_type_usage_pvt;

/
