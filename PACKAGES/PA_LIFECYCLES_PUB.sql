--------------------------------------------------------
--  DDL for Package PA_LIFECYCLES_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PA_LIFECYCLES_PUB" AUTHID CURRENT_USER AS
 /* $Header: PALCDFPS.pls 120.1 2005/08/19 16:35:29 mwasowic noship $   */

G_PKG_NAME              CONSTANT VARCHAR2(30) := 'PA_LIFECYCLES_PUB';
G_MISS_NUM		CONSTANT    NUMBER      := 9.99E125;
G_MISS_CHAR             CONSTANT    VARCHAR2(1) := chr(0);
G_MISS_DATE             CONSTANT    DATE        := TO_DATE('1','j');


-- Start of comments
--	API name 	: create_lifecycle
--	Type		: Public
--	Pre-reqs	: None.
--	Purpose  	: Creates a lifecycle for the given name and short name
--	Parameters	:
--	p_api_version			IN	NUMBER		Optional	Default	 1.0
--	P_init_msg_list			IN	VARCHAR2	Optional	Default  FND_API.G_TRUE
--	P_commit			IN	VARCHAR2	Optional	Default  FND_API.G_FALSE
--	P_validate_only			IN	VARCHAR2	Optional	Default  FND_API.G_TRUE
--	P_validation_level		IN	VARCHAR2	Optional	Default  FND_API.G_VALID_LEVEL_FULL
--	P_calling_module		IN	VARCHAR2	Optional	Default  'SELF-SERVICE'
--	P_debug_mode			IN	VARCHAR2	Optional	Default  'N'
--	P_max_msg_count			IN	NUMBER		Optional	Default  G_MISS_NUM
--	P_lifecycle_short_name 		IN	VARCHAR2	Required
--	P_lifecycle_name		IN	VARCHAR2	Required
--	P_lifecycle_description		IN	VARCHAR2	Optional	Default  G_MISS_CHAR
--	P_lifecycle_project_usage_type	IN	VARCHAR2	Optional	Default  'Y'
--	P_lifecycle_product_usage_type	IN	VARCHAR2	Optional	Default  G_MISS_CHAR
--	X_lifecycle_id			OUT	NUMBER
--	X_return_status			OUT	VARCHAR2
--	X_msg_count			OUT	NUMBER
--	X_msg_data			OUT	VARCHAR2
--
--	History         :
--				15-OCT-02  amksingh   Created
-- End of comments


PROCEDURE create_lifecycle (
	P_api_version			IN	NUMBER	  := 1.0			,
	P_init_msg_list			IN	VARCHAR2  := FND_API.G_TRUE		,
	P_commit			IN	VARCHAR2  := FND_API.G_FALSE		,
	P_validate_only			IN	VARCHAR2  := FND_API.G_TRUE		,
	P_validation_level		IN	NUMBER    := FND_API.G_VALID_LEVEL_FULL ,
	P_calling_module		IN	VARCHAR2  := 'SELF-SERVICE'		,
	P_debug_mode			IN	VARCHAR2  := 'N'			,
	P_max_msg_count			IN	NUMBER    := G_MISS_NUM			,
	P_lifecycle_short_name 		IN	VARCHAR2				,
	P_lifecycle_name		IN	VARCHAR2				,
	P_lifecycle_description		IN	VARCHAR2  := G_MISS_CHAR		,
	P_lifecycle_project_usage_type	IN	VARCHAR2  := 'Y'			,
	P_lifecycle_product_usage_type	IN	VARCHAR2  := G_MISS_CHAR		,
	X_lifecycle_id			OUT	NOCOPY NUMBER 					, --File.Sql.39 bug 4440895
	X_return_status			OUT	NOCOPY VARCHAR2				, --File.Sql.39 bug 4440895
	X_msg_count			OUT	NOCOPY NUMBER					, --File.Sql.39 bug 4440895
	X_msg_data			OUT	NOCOPY VARCHAR2	 --File.Sql.39 bug 4440895
	);


-- Start of comments
--	API name 	: create_lifecycle_phase
--	Type		: Public
--	Pre-reqs	: None.
--	Purpose  	: Creates a lifecycle phase for the given lifecycle
--	Parameters	:
--	p_api_version			IN	NUMBER		Optional	Default	1.0
--	P_init_msg_list			IN	VARCHAR2	Optional	Default  FND_API.G_TRUE
--	P_commit			IN	VARCHAR2	Optional	Default  FND_API.G_FALSE
--	P_validate_only			IN	VARCHAR2	Optional	Default  FND_API.G_TRUE
--	P_validation_level		IN	VARCHAR2	Optional	Default  FND_API.G_VALID_LEVEL_FULL
--	P_calling_module		IN	VARCHAR2	Optional	Default  'SELF-SERVICE'
--	P_debug_mode			IN	VARCHAR2	Optional	Default  'N'
--	P_max_msg_count			IN	NUMBER		Optional	Default  G_MISS_NUM
--	P_lifecycle_id			IN	NUMBER          Required
--      P_phase_status_name             IN	VARCHAR2        Required
--	P_phase_short_name 		IN	VARCHAR2	Required
--	P_phase_name			IN	VARCHAR2	Required
--	P_phase_display_sequence	IN	NUMBER          Required
--	P_phase_description		IN	VARCHAR2	Optional	Default  G_MISS_CHAR
--	X_lifecycle_phase_id		OUT	NUMBER
--	X_return_status			OUT	VARCHAR2
--	X_msg_count			OUT	NUMBER
--	X_msg_data			OUT	VARCHAR2
--
--	History         :
--				15-OCT-02  amksingh   Created
-- End of comments


PROCEDURE create_lifecycle_phase(
	 P_api_version			IN	NUMBER   := 1.0				,
	 p_init_msg_list		IN	VARCHAR2 :=FND_API.G_TRUE		,
	 p_commit			IN	VARCHAR2 :=FND_API.G_FALSE		,
	 p_validate_only		IN	VARCHAR2 :=FND_API.G_TRUE		,
	 p_validation_level		IN	NUMBER   :=FND_API.G_VALID_LEVEL_FULL	,
	 p_calling_module		IN	VARCHAR2 :='SELF_SERVICE'		,
	 p_debug_mode			IN	VARCHAR2 :='N'				,
	 P_max_msg_count		IN	NUMBER   :=G_MISS_NUM			,
	 P_lifecycle_id			IN	NUMBER					,
	 P_phase_status_name		IN	VARCHAR2				,
	 P_phase_short_name 		IN	VARCHAR2 				,
	 P_phase_name			IN	VARCHAR2 				,
	 P_phase_display_sequence	IN	NUMBER   				,
	 P_phase_description		IN	VARCHAR2 :=G_MISS_CHAR			,
	 X_lifecycle_phase_id		OUT	NOCOPY NUMBER					, --File.Sql.39 bug 4440895
	 x_return_status		OUT	NOCOPY VARCHAR2				, --File.Sql.39 bug 4440895
	 x_msg_count			OUT	NOCOPY NUMBER					, --File.Sql.39 bug 4440895
	 X_msg_data			OUT	NOCOPY VARCHAR2  --File.Sql.39 bug 4440895
	);


-- Start of comments
--	API name 	: update_lifecycle
--	Type		: Public
--	Pre-reqs	: None.
--	Purpose  	: updates a lifecycle. Lifecycle name, short name, description, and usage can be updated
--	Parameters	:
--	p_api_version			IN	NUMBER		Optional	Default	1.0
--	P_init_msg_list			IN	VARCHAR2	Optional	Default  FND_API.G_TRUE
--	P_commit			IN	VARCHAR2	Optional	Default  FND_API.G_FALSE
--	P_validate_only			IN	VARCHAR2	Optional	Default  FND_API.G_TRUE
--	P_validation_level		IN	VARCHAR2	Optional	Default  FND_API.G_VALID_LEVEL_FULL
--	P_calling_module		IN	VARCHAR2	Optional	Default  'SELF-SERVICE'
--	P_debug_mode			IN	VARCHAR2	Optional	Default  'N'
--	P_max_msg_count			IN	NUMBER		Optional	Default  G_MISS_NUM
--	P_lifecycle_id			IN	NUMBER          Required
--	P_lifecycle_short_name 		IN	VARCHAR2	Optional	Default  G_MISS_CHAR
--	P_lifecycle_name		IN	VARCHAR2	Optional	Default  G_MISS_CHAR
--	P_lifecycle_description		IN	VARCHAR2	Optional	Default  G_MISS_CHAR
--	P_lifecycle_project_usage_type	IN	VARCHAR2	Optional	Default  G_MISS_CHAR
--	P_lifecycle_product_usage_type	IN	VARCHAR2	Optional	Default  G_MISS_CHAR
--	X_lifecycle_id			OUT	NUMBER
--	X_return_status			OUT	VARCHAR2
--	X_msg_count			OUT	NUMBER
--	X_msg_data			OUT	VARCHAR2
--
--	History         :
--				15-OCT-02  amksingh   Created
-- End of comments

PROCEDURE update_lifecycle (
	 p_api_version			IN	NUMBER   :=1.0				,
	 p_init_msg_list		IN	VARCHAR2 :=FND_API.G_TRUE		,
	 p_commit			IN	VARCHAR2 :=FND_API.G_FALSE		,
	 p_validate_only		IN	VARCHAR2 :=FND_API.G_TRUE		,
	 p_validation_level		IN	NUMBER   :=FND_API.G_VALID_LEVEL_FULL	,
	 p_calling_module		IN	VARCHAR2 :='SELF SERVICE'		,
	 p_debug_mode			IN	VARCHAR2 :='N'				,
	 p_max_msg_count		IN	NUMBER   :=G_MISS_NUM			,
	 P_lifecycle_id			IN	NUMBER   				,
	 P_lifecycle_short_name		IN	VARCHAR2 :=G_MISS_CHAR			,
	 P_lifecycle_name		IN	VARCHAR2 :=G_MISS_CHAR			,
	 P_lifecycle_description	IN	VARCHAR2 :=G_MISS_CHAR			,
	 P_lifecycle_project_usage_type	IN	VARCHAR2 :=G_MISS_CHAR			,
	 P_lifecycle_product_usage_type	IN	VARCHAR2 :=G_MISS_CHAR			,
	 P_record_version_number	IN	NUMBER					,
	 x_return_status		OUT	NOCOPY VARCHAR2				, --File.Sql.39 bug 4440895
	 x_msg_count			OUT	NOCOPY NUMBER					, --File.Sql.39 bug 4440895
	 X_msg_data			OUT	NOCOPY VARCHAR2  --File.Sql.39 bug 4440895
	);

-- Start of comments
--	API name 	: update_lifecycle_phase
--	Type		: Public
--	Pre-reqs	: None.
--	Purpose  	: Updates a lifecycle phase for the given lifecycle
--	Parameters	:
--	p_api_version			IN	NUMBER		Optional	Default	1.0
--	P_init_msg_list			IN	VARCHAR2	Optional	Default  FND_API.G_TRUE
--	P_commit			IN	VARCHAR2	Optional	Default  FND_API.G_FALSE
--	P_validate_only			IN	VARCHAR2	Optional	Default  FND_API.G_TRUE
--	P_validation_level		IN	VARCHAR2	Optional	Default  FND_API.G_VALID_LEVEL_FULL
--	P_calling_module		IN	VARCHAR2	Optional	Default  'SELF-SERVICE'
--	P_debug_mode			IN	VARCHAR2	Optional	Default  'N'
--	P_max_msg_count			IN	NUMBER		Optional	Default  G_MISS_NUM
--	P_lifecycle_id			IN	NUMBER          Required
--	P_lifecycle_phase_id		IN	NUMBER          Required
--      P_phase_code                    IN	VARCHAR2        Optional	Default  G_MISS_CHAR
--	P_phase_short_name 		IN	VARCHAR2	Optional	Default  G_MISS_CHAR
--	P_phase_name			IN	VARCHAR2	Optional	Default  G_MISS_CHAR
--	P_phase_display_sequence	IN	NUMBER          Optional	Default  G_MISS_NUM
--	P_phase_description		IN	VARCHAR2	Optional	Default  G_MISS_CHAR
--	X_lifecycle_phase_id		OUT	NUMBER
--	X_return_status			OUT	VARCHAR2
--	X_msg_count			OUT	NUMBER
--	X_msg_data			OUT	VARCHAR2
--
--	History         :
--				15-OCT-02  amksingh   Created
-- End of comments


PROCEDURE update_lifecycle_phase (
	 P_api_version			IN	NUMBER   :=1.0				,
	 p_init_msg_list		IN	VARCHAR2 :=FND_API.G_TRUE		,
	 p_commit			IN	VARCHAR2 :=FND_API.G_FALSE		,
	 p_validate_only		IN	VARCHAR2 :=FND_API.G_TRUE		,
	 p_validation_level		IN	NUMBER   :=FND_API.G_VALID_LEVEL_FULL	,
	 p_calling_module		IN	VARCHAR2 :='SELF SERVICE'		,
	 p_debug_mode			IN	VARCHAR2 :='N'				,
	 P_max_msg_count		IN	NUMBER   :=G_MISS_NUM			,
	 P_lifecycle_id			IN	NUMBER					,
	 P_lifecycle_phase_id		IN	NUMBER					,
	 P_phase_status_name		IN	VARCHAR2 :=G_MISS_CHAR	 		,
	 P_phase_short_name		IN	VARCHAR2 :=G_MISS_CHAR			,
	 P_phase_name			IN	VARCHAR2 :=G_MISS_CHAR			,
	 P_phase_display_sequence	IN	NUMBER   :=G_MISS_NUM			,
	 P_phase_description		IN	VARCHAR2 :=G_MISS_CHAR			,
	 P_record_version_number	IN	NUMBER					,
	 x_return_status		OUT	NOCOPY VARCHAR2				, --File.Sql.39 bug 4440895
	 x_msg_count			OUT	NOCOPY NUMBER					, --File.Sql.39 bug 4440895
	 X_msg_data			OUT	NOCOPY VARCHAR2				 --File.Sql.39 bug 4440895
	);



-- Start of comments
--	API name 	: delete_lifecycle
--	Type		: Public
--	Pre-reqs	: None.
--	Purpose  	: deletes a given lifecycle
--	Parameters	:
--	p_api_version			IN	NUMBER		Optional	Default	1.0
--	P_init_msg_list			IN	VARCHAR2	Optional	Default  FND_API.G_TRUE
--	P_commit			IN	VARCHAR2	Optional	Default  FND_API.G_FALSE
--	P_validate_only			IN	VARCHAR2	Optional	Default  FND_API.G_TRUE
--	P_validation_level		IN	VARCHAR2	Optional	Default  FND_API.G_VALID_LEVEL_FULL
--	P_calling_module		IN	VARCHAR2	Optional	Default  'SELF-SERVICE'
--	P_debug_mode			IN	VARCHAR2	Optional	Default  'N'
--	P_max_msg_count			IN	NUMBER		Optional	Default  G_MISS_NUM
--	P_lifecycle_id			IN	NUMBER          Required
--      P_record_version_number		IN	NUMBER          Required
--	X_return_status			OUT	VARCHAR2
--	X_msg_count			OUT	NUMBER
--	X_msg_data			OUT	VARCHAR2
--
--	History         :
--				15-OCT-02  amksingh   Created
-- End of comments

PROCEDURE delete_lifecycle (
	P_api_version			IN	NUMBER	  := 1.0			,
	P_init_msg_list			IN	VARCHAR2  := FND_API.G_TRUE  		,
	P_commit			IN	VARCHAR2  := FND_API.G_FALSE 		,
	P_validate_only			IN	VARCHAR2  := FND_API.G_TRUE  		,
	P_validation_level		IN	NUMBER    := FND_API.G_VALID_LEVEL_FULL	,
	P_calling_module		IN	VARCHAR2  := 'SELF-SERVICE'  		,
	P_debug_mode			IN	VARCHAR2  := 'N'	     		,
	P_max_msg_count			IN	NUMBER    := G_MISS_NUM			,
	P_lifecycle_id			IN	NUMBER 	 				,
	p_record_version_number         IN      NUMBER					,
	X_return_status			OUT	NOCOPY VARCHAR2				, --File.Sql.39 bug 4440895
	X_msg_count			OUT	NOCOPY NUMBER					, --File.Sql.39 bug 4440895
	X_msg_data			OUT	NOCOPY VARCHAR2				 --File.Sql.39 bug 4440895
	);

-- Start of comments
--	API name 	: delete_lifecycle_phase
--	Type		: Public
--	Pre-reqs	: None.
--	Purpose  	: deletes a given lifecycle phase
--	Parameters	:
--	p_api_version			IN	NUMBER		Optional	Default	1.0
--	P_init_msg_list			IN	VARCHAR2	Optional	Default  FND_API.G_TRUE
--	P_commit			IN	VARCHAR2	Optional	Default  FND_API.G_FALSE
--	P_validate_only			IN	VARCHAR2	Optional	Default  FND_API.G_TRUE
--	P_validation_level		IN	VARCHAR2	Optional	Default  FND_API.G_VALID_LEVEL_FULL
--	P_calling_module		IN	VARCHAR2	Optional	Default  'SELF-SERVICE'
--	P_debug_mode			IN	VARCHAR2	Optional	Default  'N'
--	P_max_msg_count			IN	NUMBER		Optional	Default  G_MISS_NUM
--	P_lifecycle_id			IN	NUMBER          Required
--	P_phase_id			IN	NUMBER 	 	Required
--      P_record_version_number		IN	NUMBER          Required
--	X_return_status			OUT	VARCHAR2
--	X_msg_count			OUT	NUMBER
--	X_msg_data			OUT	VARCHAR2
--
--	History         :
--				15-OCT-02  amksingh   Created
-- End of comments


PROCEDURE delete_lifecycle_phase (
	P_api_version			IN	NUMBER	  := 1.0			,
	P_init_msg_list			IN	VARCHAR2  := FND_API.G_TRUE  		,
	P_commit			IN	VARCHAR2  := FND_API.G_FALSE 		,
	P_validate_only			IN	VARCHAR2  := FND_API.G_TRUE  		,
	P_validation_level		IN	NUMBER    := FND_API.G_VALID_LEVEL_FULL	,
	P_calling_module		IN	VARCHAR2  := 'SELF-SERVICE'  		,
	P_debug_mode			IN	VARCHAR2  := 'N'	     		,
	P_max_msg_count			IN	NUMBER    := G_MISS_NUM			,
	P_lifecycle_id                  IN      NUMBER					,
	P_phase_id			IN	NUMBER 	 				,
	p_record_version_number         IN      NUMBER					,
	X_return_status			OUT	NOCOPY VARCHAR2				, --File.Sql.39 bug 4440895
	X_msg_count			OUT	NOCOPY NUMBER					, --File.Sql.39 bug 4440895
	X_msg_data			OUT	NOCOPY VARCHAR2	 --File.Sql.39 bug 4440895
	);

END PA_LIFECYCLES_PUB;

 

/
