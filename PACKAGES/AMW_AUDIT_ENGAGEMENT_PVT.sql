--------------------------------------------------------
--  DDL for Package AMW_AUDIT_ENGAGEMENT_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."AMW_AUDIT_ENGAGEMENT_PVT" AUTHID CURRENT_USER AS
/* $Header: amwvengs.pls 120.2 2008/02/08 14:25:25 adhulipa ship $ */
/*===========================================================================*/

PROCEDURE copy_scope_from_engagement(
    p_source_entity_id          IN       NUMBER,
    p_target_entity_id          IN       NUMBER,
    l_copy_ineff_controls boolean :=false,
    x_return_status             OUT      nocopy VARCHAR2
);

PROCEDURE create_engagement_for_pa(
    p_project_id   IN      NUMBER,
    p_audit_project_id     OUT     nocopy NUMBER,
    x_return_status        OUT     nocopy VARCHAR2
);


PROCEDURE create_engagement_in_pa(
    p_created_from_project_id   IN      NUMBER,
    p_project_name              IN      VARCHAR2,
    p_project_number          	IN      VARCHAR2,
    p_project_description	IN	VARCHAR2,
    p_project_manager         	IN      NUMBER default 11,
    p_project_status         	IN	VARCHAR2 default 'ACTIVE',
    p_start_date		IN	DATE default SYSDATE,
    p_completion_date		IN	DATE default SYSDATE+100,
    p_project_id		OUT     nocopy NUMBER,
    p_msg_data                  OUT     nocopy VARCHAR2,
    x_return_status             OUT     nocopy VARCHAR2
);


PROCEDURE update_engagement_in_pa(
    p_project_id   		IN      NUMBER,
    p_project_name              IN      VARCHAR2,
    p_project_number            IN      VARCHAR2,
    p_project_description       IN      VARCHAR2,
    p_project_manager           IN      NUMBER ,
    p_project_status            IN      VARCHAR2 default 'ACTIVE',
    p_start_date                IN      DATE default SYSDATE,
    p_completion_date           IN      DATE default NULL,
    p_sign_off_required         IN      VARCHAR2,
    p_msg_data	                OUT     nocopy VARCHAR2,
    x_return_status             OUT     nocopy VARCHAR2
);


PROCEDURE create_audit_task_in_pa(
    p_project_id                IN      NUMBER,
    p_parent_task_id            IN      NUMBER,
    p_task_name                 IN      VARCHAR2,
    p_task_number               IN      VARCHAR2,
    p_task_description          IN      VARCHAR2,
    p_task_manager              IN      NUMBER,
    p_start_date                IN      DATE ,
    p_completion_date           IN      DATE ,
    p_task_id                   OUT     nocopy NUMBER,
    p_msg_data                  OUT     nocopy VARCHAR2,
    x_return_status             OUT     nocopy VARCHAR2
);

PROCEDURE update_audit_task_in_pa(
    p_project_id                IN      NUMBER,
    p_task_id                   IN      NUMBER,
    p_parent_task_id            IN      NUMBER,
    p_task_name                 IN      VARCHAR2,
    p_task_number               IN      VARCHAR2,
    p_task_description          IN      VARCHAR2,
    p_task_manager              IN      NUMBER,
    p_start_date                IN      DATE ,
    p_completion_date           IN      DATE ,
    p_msg_data                  OUT     nocopy VARCHAR2,
    x_return_status             OUT     nocopy VARCHAR2
);

PROCEDURE delete_audit_task_in_pa(
    p_project_id                IN      NUMBER,
    p_task_id                   IN      NUMBER,
--    p_task_number               IN      VARCHAR2,
    p_msg_data                  OUT     nocopy VARCHAR2,
    x_return_status             OUT     nocopy VARCHAR2
);

PROCEDURE delete_audit_task_in_icm(
    p_audit_project_id	IN	NUMBER,
    p_task_id		IN	NUMBER,
    x_return_status	OUT	nocopy VARCHAR2
);

FUNCTION is_workplan_version_shared( p_project_id IN NUMBER) return VARCHAR2;

 PROCEDURE cp_tasks
    ( p_source_project_id IN NUMBER,
      p_dest_project_id IN NUMBER,
      x_return_status OUT nocopy VARCHAR2
);
PROCEDURE COPY_SCOPE_INEFF_CONTROLS(
    p_source_entity_id		IN	 NUMBER,
    p_target_entity_id          IN       NUMBER,
    x_return_status             OUT      nocopy VARCHAR2
);
PROCEDURE cp_tasks_all
    ( p_source_project_id IN NUMBER,
      p_dest_project_id IN NUMBER,
      x_return_status OUT nocopy VARCHAR2);
END AMW_AUDIT_ENGAGEMENT_PVT;

/
