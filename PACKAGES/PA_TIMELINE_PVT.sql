--------------------------------------------------------
--  DDL for Package PA_TIMELINE_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PA_TIMELINE_PVT" AUTHID CURRENT_USER as
/* $Header: PARLPVTS.pls 120.1 2005/08/19 16:55:42 mwasowic noship $   */

-- Create timeline (overloaded for assignment)
PROCEDURE Create_Timeline (p_assignment_id       IN      NUMBER,
                           x_return_status       OUT     NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
                           x_msg_count           OUT     NOCOPY NUMBER, --File.Sql.39 bug 4440895
                           x_msg_data            OUT     NOCOPY VARCHAR2); --File.Sql.39 bug 4440895

PROCEDURE Create_Timeline (p_start_resource_name  IN     VARCHAR2,
				                   p_end_resource_name	  IN     VARCHAR2,
				                   p_resource_id	        IN	   NUMBER,
				                   p_start_date		        IN	   DATE,
				                   p_end_date		          IN	   DATE,
                           x_return_status        OUT    NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
                           x_msg_count            OUT    NOCOPY NUMBER, --File.Sql.39 bug 4440895
                           x_msg_data             OUT    NOCOPY VARCHAR2); --File.Sql.39 bug 4440895

PROCEDURE Create_Timeline (p_calendar_id  	      IN     NUMBER,
                           x_return_status        OUT    NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
                           x_msg_count            OUT    NOCOPY NUMBER, --File.Sql.39 bug 4440895
                           x_msg_data             OUT    NOCOPY VARCHAR2); --File.Sql.39 bug 4440895

-- Delete timeline
PROCEDURE Delete_Timeline(p_assignment_id       IN      NUMBER,
                          x_return_status       OUT     NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
                          x_msg_count           OUT     NOCOPY NUMBER, --File.Sql.39 bug 4440895
                          x_msg_data            OUT     NOCOPY VARCHAR2); --File.Sql.39 bug 4440895


-- Procedure            : copy_open_asgn_timeline
-- Purpose              : Copy timeline data, pa_timeline_row_label and
--                        pa_proj_asgn_time_chart, for a newly created open
--                        assignment whose timeline has NOT been built.
--                        Currently, the only API calling this is
--                        PA_SCHEDULE_PVT.create_opn_asg_schedule.
PROCEDURE copy_open_asgn_timeline (p_assignment_id_tbl    IN   PA_ASSIGNMENTS_PUB.assignment_id_tbl_type,
                                 p_assignment_source_id   IN   NUMBER,
                                 x_return_status          OUT  NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
                                 x_msg_count              OUT  NOCOPY NUMBER, --File.Sql.39 bug 4440895
                                 x_msg_data               OUT  NOCOPY VARCHAR2); --File.Sql.39 bug 4440895


PROCEDURE populate_time_chart_table (p_timeline_type IN VARCHAR2,
            p_row_label_id_tbl  IN SYSTEM.PA_NUM_TBL_TYPE,
            p_resource_id       IN NUMBER DEFAULT NULL,
            p_conflict_group_id IN NUMBER DEFAULT NULL,
            p_assignment_id     IN NUMBER DEFAULT NULL,
            p_start_date        IN DATE,
            p_end_date          IN DATE,
            p_scale_type        IN VARCHAR2,
            p_delete_flag       IN VARCHAR2 DEFAULT 'Y',
            x_return_status     OUT NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
            x_msg_count         OUT NOCOPY NUMBER, --File.Sql.39 bug 4440895
            x_msg_data          OUT NOCOPY VARCHAR2); --File.Sql.39 bug 4440895

END PA_TIMELINE_PVT;

 

/
