--------------------------------------------------------
--  DDL for Package PA_PROJ_STRUCTURE_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PA_PROJ_STRUCTURE_PUB" AUTHID CURRENT_USER as
/* $Header: PAXSTRPS.pls 120.3 2005/12/19 16:06:58 rakragha noship $ */

--bug 4448499
global_sequence_number NUMBER := 0;
global_sub_proj_task_count NUMBER :=0;
--bug 4448499
procedure CREATE_RELATIONSHIP
(
	p_api_version				IN		NUMBER		:= 1.0,
	p_init_msg_list 		IN		VARCHAR2	:= FND_API.G_TRUE,
	p_commit						IN		VARCHAR2	:= FND_API.G_FALSE,
	p_validate_only			IN		VARCHAR2	:= FND_API.G_TRUE,
	p_debug_mode				IN		VARCHAR2	:= 'N',
	p_task_id						IN		NUMBER,
	p_project_id				IN		NUMBER,
	x_return_status			OUT		NOCOPY VARCHAR2,
	x_msg_count					OUT		NOCOPY NUMBER,
	x_msg_data					OUT		NOCOPY VARCHAR2
);

function CHECK_SUBPROJ_CONTRACT_ASSO
(
	p_project_id	IN NUMBER
)
return VARCHAR2;

function CHECK_TASK_CONTRACT_ASSO
(
	p_task_id IN NUMBER
)
return VARCHAR2;

procedure DELETE_RELATIONSHIP
(
	p_api_version				IN		NUMBER		:= 1.0,
	p_init_msg_list 		IN		VARCHAR2	:= FND_API.G_TRUE,
	p_commit						IN		VARCHAR2	:= FND_API.G_FALSE,
	p_validate_only			IN		VARCHAR2	:= FND_API.G_TRUE,
	p_debug_mode				IN		VARCHAR2	:= 'N',
	p_task_id						IN		NUMBER,
	p_project_id				IN		NUMBER,
	x_return_status			OUT		NOCOPY VARCHAR2,
	x_msg_count					OUT		NOCOPY NUMBER,
	x_msg_data					OUT		NOCOPY VARCHAR2
);


--bug
procedure POPULATE_STRUCTURES_TMP_TAB
(
	p_api_version			IN		NUMBER		:= 1.0,
	p_init_msg_list 		IN		VARCHAR2	:= FND_API.G_TRUE,
	p_commit				IN		VARCHAR2	:= FND_API.G_FALSE,
	p_validate_only			IN		VARCHAR2	:= FND_API.G_TRUE,
	p_debug_mode			IN		VARCHAR2	:= 'N',
	p_project_id			IN		NUMBER,
	p_structure_version_id		IN		NUMBER,
	p_task_version_id		IN		NUMBER          := PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM,
	p_calling_page_name		IN		VARCHAR2,
        p_populate_tmp_tab_flag         IN              VARCHAR2           := 'Y',
        p_parent_project_id     IN      NUMBER := PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM,
        p_sequence_offset     IN      NUMBER := 0,    --bug 4448499
        p_wbs_display_depth             IN              NUMBER          := -1, -- Bug # 4875311.
	x_return_status			OUT		NOCOPY VARCHAR2,
	x_msg_count				OUT		NOCOPY NUMBER,
	x_msg_data				OUT		NOCOPY VARCHAR2
	);

procedure INSERT_PUBLISHED_RECORDS
(
	p_api_version			IN		NUMBER		:= 1.0,
	p_init_msg_list 		IN		VARCHAR2	:= FND_API.G_TRUE,
	p_commit				IN		VARCHAR2	:= FND_API.G_FALSE,
	p_validate_only			IN		VARCHAR2	:= FND_API.G_TRUE,
	p_debug_mode			IN		VARCHAR2	:= 'N',
	p_project_id			IN		NUMBER,
        p_structure_version_id          IN              NUMBER,
        p_parent_project_id     IN      NUMBER := PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM,
        p_sequence_offset     IN      NUMBER := 0,    --bug 4448499
        p_wbs_display_depth             IN              NUMBER   := -1, -- Bug # 4875311.
        p_task_version_id               IN              NUMBER   := PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM, -- Bug # 4875311.
	x_return_status			OUT		NOCOPY VARCHAR2,
	x_msg_count				OUT		NOCOPY NUMBER,
	x_msg_data				OUT		NOCOPY VARCHAR2
);


procedure INSERT_WORKING_RECORDS
(
	p_api_version			IN		NUMBER		:= 1.0,
	p_init_msg_list 		IN		VARCHAR2	:= FND_API.G_TRUE,
	p_commit				IN		VARCHAR2	:= FND_API.G_FALSE,
	p_validate_only			IN		VARCHAR2	:= FND_API.G_TRUE,
	p_debug_mode			IN		VARCHAR2	:= 'N',
	p_project_id			IN		NUMBER,
        p_structure_version_id          IN              NUMBER,
        p_parent_project_id     IN      NUMBER := PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM,
        p_sequence_offset     IN      NUMBER := 0,    --bug 4448499
        p_wbs_display_depth             IN              NUMBER   := -1, -- Bug # 4875311.
        p_task_version_id               IN              NUMBER   := PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM, -- Bug # 4875311.
	x_return_status			OUT		NOCOPY VARCHAR2,
	x_msg_count				OUT		NOCOPY NUMBER,
	x_msg_data				OUT		NOCOPY VARCHAR2
);

procedure INSERT_SUBPROJECTS
(
	p_api_version			IN		NUMBER		:= 1.0,
	p_init_msg_list 		IN		VARCHAR2	:= FND_API.G_TRUE,
	p_commit				IN		VARCHAR2	:= FND_API.G_FALSE,
	p_validate_only			IN		VARCHAR2	:= FND_API.G_TRUE,
	p_debug_mode			IN		VARCHAR2	:= 'N',
        p_calling_page_name             IN              VARCHAR2,
	p_project_id			IN		NUMBER,
        p_structure_version_id          IN              NUMBER,
        p_parent_project_id     IN      NUMBER := PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM,
        p_wbs_display_depth             IN              NUMBER          := -1, -- Bug # 4875311.
	x_return_status			OUT	NOCOPY 	VARCHAR2,
	x_msg_count				OUT	NOCOPY 	NUMBER,
	x_msg_data				OUT	NOCOPY 	VARCHAR2
);


procedure INSERT_PUBLISHED_RECORD
(
	p_api_version			IN		NUMBER		:= 1.0,
	p_init_msg_list 		IN		VARCHAR2	:= FND_API.G_TRUE,
	p_commit				IN		VARCHAR2	:= FND_API.G_FALSE,
	p_validate_only			IN		VARCHAR2	:= FND_API.G_TRUE,
	p_debug_mode			IN		VARCHAR2	:= 'N',
	p_project_id			IN		NUMBER,
	p_structure_version_id  IN      NUMBER,
	p_task_version_id  IN      NUMBER,
        p_parent_project_id     IN      NUMBER := PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM,
	x_return_status			OUT	NOCOPY 	VARCHAR2,
	x_msg_count				OUT	NOCOPY 	NUMBER,
	x_msg_data				OUT	NOCOPY 	VARCHAR2
);

procedure INSERT_WORKING_RECORD
(
	p_api_version			IN		NUMBER		:= 1.0,
	p_init_msg_list 		IN		VARCHAR2	:= FND_API.G_TRUE,
	p_commit				IN		VARCHAR2	:= FND_API.G_FALSE,
	p_validate_only			IN		VARCHAR2	:= FND_API.G_TRUE,
	p_debug_mode			IN		VARCHAR2	:= 'N',
	p_project_id			IN		NUMBER,
      p_structure_version_id        IN      NUMBER,
	p_task_version_id             IN      NUMBER,
        p_parent_project_id     IN      NUMBER := PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM,
	x_return_status			OUT	NOCOPY 	VARCHAR2,
	x_msg_count				OUT	NOCOPY 	NUMBER,
	x_msg_data				OUT	NOCOPY 	VARCHAR2
);

procedure INSERT_UPD_WORKING_RECORDS
(
        p_api_version                   IN              NUMBER          := 1.0,
        p_init_msg_list                 IN              VARCHAR2        := FND_API.G_TRUE,
        p_commit                        IN              VARCHAR2        := FND_API.G_FALSE,
        p_validate_only                 IN              VARCHAR2        := FND_API.G_TRUE,
        p_debug_mode                    IN              VARCHAR2        := 'N',
        p_project_id                    IN              NUMBER,
        p_structure_version_id          IN              NUMBER,
        p_parent_project_id             IN      NUMBER := PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM,
        p_wbs_display_depth             IN              NUMBER   := -1, -- Bug # 4875311.
        p_task_version_id               IN              NUMBER   := PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM, -- Bug # 4875311.
        x_return_status                 OUT   NOCOPY           VARCHAR2,
        x_msg_count                     OUT   NOCOPY           NUMBER,
        x_msg_data                      OUT   NOCOPY           VARCHAR2
);

procedure INSERT_UPD_PUBLISHED_RECORDS
(
        p_api_version                   IN              NUMBER          := 1.0,
        p_init_msg_list                 IN              VARCHAR2        := FND_API.G_TRUE,
        p_commit                        IN              VARCHAR2        := FND_API.G_FALSE,
        p_validate_only                 IN              VARCHAR2        := FND_API.G_TRUE,
        p_debug_mode                    IN              VARCHAR2        := 'N',
        p_project_id                    IN              NUMBER,
        p_structure_version_id          IN              NUMBER,
        p_parent_project_id             IN      NUMBER := PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM,
        p_wbs_display_depth             IN              NUMBER   := -1, -- Bug # 4875311.
        p_task_version_id               IN              NUMBER   := PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM, -- Bug # 4875311.
        x_return_status                 OUT    NOCOPY          VARCHAR2,
        x_msg_count                     OUT    NOCOPY          NUMBER,
        x_msg_data                      OUT    NOCOPY          VARCHAR2
);

-- Bug # 4875311.

procedure populate_pji_tab_for_plan_prj
(p_api_version                  IN      NUMBER          :=1.0
 ,p_init_msg_list               IN      VARCHAR2        :=FND_API.G_TRUE
 ,p_commit                      IN      VARCHAR2        :=FND_API.G_FALSE
 ,p_validate_only               IN      VARCHAR2        :=FND_API.G_TRUE
 ,p_validation_level            IN      NUMBER          :=FND_API.G_VALID_LEVEL_FULL
 ,p_calling_module              IN      VARCHAR2        :='SELF_SERVICE'
 ,p_debug_mode                  IN      VARCHAR2        :='N'
 ,p_max_msg_count               IN      NUMBER          :=PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM
 ,p_project_id                  IN      NUMBER
 ,p_project_element_id          IN      NUMBER          DEFAULT NULL
 ,p_structure_version_id        IN      NUMBER          DEFAULT NULL
 ,p_baselined_str_ver_id        IN      NUMBER          DEFAULT NULL
 ,p_structure_type              IN      VARCHAR2        := 'WORKPLAN'
 ,p_populate_tmp_tab_flag       IN      VARCHAR2        := 'Y'
 ,p_program_rollup_flag         IN      VARCHAR2        := 'Y'
 ,p_calling_context             IN      VARCHAR2        := 'ROLLUP'
 ,p_as_of_date                  IN      DATE            := null
 ,p_wbs_display_depth           IN      NUMBER          := -1
 ,p_structure_flag              IN      VARCHAR2        := 'Y'
 ,x_return_status               OUT     NOCOPY		VARCHAR2
 ,x_msg_count                   OUT     NOCOPY		NUMBER
 ,x_msg_data                    OUT     NOCOPY		VARCHAR2);

-- Bug # 4875311.

end PA_PROJ_STRUCTURE_PUB;


 

/
