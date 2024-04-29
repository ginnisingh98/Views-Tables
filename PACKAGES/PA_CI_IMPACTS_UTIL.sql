--------------------------------------------------------
--  DDL for Package PA_CI_IMPACTS_UTIL
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PA_CI_IMPACTS_UTIL" AUTHID CURRENT_USER AS
/* $Header: PACIIPUS.pls 120.0 2005/05/29 13:53:04 appldev noship $ */

function is_any_impact_implemented (
  p_ci_id IN NUMBER := null
) RETURN boolean;

function is_render_true (
			 impact_type_code IN VARCHAR2,
			  project_id IN NUMBER :=  null
) RETURN varchar2;

function is_impact_implemented (
				p_ci_id IN NUMBER ,
				p_impact_type_code IN VARCHAR2
				) RETURN BOOLEAN;

function is_impact_exist (
				p_ci_id IN NUMBER ,
				p_impact_type_code IN VARCHAR2
				) RETURN BOOLEAN;

procedure delete_all_impacts
  (
   p_api_version                 IN     NUMBER :=  1.0,
   p_init_msg_list               IN     VARCHAR2 := 'T',
   p_commit                      IN     VARCHAR2 := 'F',
   p_validate_only               IN     VARCHAR2 := 'T',
   p_max_msg_count               IN     NUMBER := null,

   p_ci_id IN NUMBER,
   x_return_status               OUT NOCOPY    VARCHAR2,
   x_msg_count                   OUT NOCOPY    NUMBER,
   x_msg_data                    OUT NOCOPY    VARCHAR2
   ) ;

procedure copy_impact
  (
   p_api_version                 IN     NUMBER :=  1.0,
   p_init_msg_list               IN     VARCHAR2 := 'T',
   p_commit                      IN     VARCHAR2 := 'F',
   p_validate_only               IN     VARCHAR2 := 'T',
   p_max_msg_count               IN     NUMBER := null,

   p_dest_ci_id IN NUMBER,
   p_source_ci_id IN NUMBER,
   p_include_flag IN VARCHAR2,
   x_return_status               OUT NOCOPY    VARCHAR2,
   x_msg_count                   OUT NOCOPY    NUMBER,
   x_msg_data                    OUT NOCOPY    VARCHAR2
   ) ;

function is_all_impact_implemented (
				p_ci_id IN NUMBER
				    ) RETURN BOOLEAN;

procedure is_delete_impact_ok
  (
   p_ci_impact_id IN NUMBER,

   x_return_status               OUT NOCOPY    VARCHAR2,
   x_msg_count                   OUT NOCOPY    NUMBER,
   x_msg_data                    OUT NOCOPY    VARCHAR2
   ) ;

function get_edit_mode (
  p_ci_id IN NUMBER := null
			) RETURN VARCHAR2;

function get_update_impact_mode (
  p_ci_id IN NUMBER := null
			) RETURN VARCHAR2;

function get_implement_impact_mode (
  p_ci_id IN NUMBER := null
			) RETURN VARCHAR2;

function get_update_impact_mode (
  p_ci_id IN NUMBER := null,
  p_status_code IN VARCHAR2
			) RETURN VARCHAR2;

function get_implement_impact_mode (
  p_ci_id IN NUMBER := null,
  p_status_code IN VARCHAR2,
  p_type_class  IN VARCHAR2
			) RETURN VARCHAR2;

END Pa_ci_impacts_util;

 

/
