--------------------------------------------------------
--  DDL for Package PJI_FM_XBS_ACCUM_UTILS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PJI_FM_XBS_ACCUM_UTILS" AUTHID CURRENT_USER AS
/* $Header: PJIPUT1S.pls 120.4 2006/09/01 19:03:09 ajdas noship $ */

 /*Changed for workplan progress.
      p_end_date              IN   DATE,
      p_calendar_type         IN   VARCHAR2,
      and added
      p_extraction_type       IN   VARCHAR2(1) := NULL,
      p_calling_context       IN   VARCHAR2 := NULL  */
PROCEDURE DELETE_FIN8(
    p_project_id    IN   NUMBER,
    p_calendar_type IN   VARCHAR2 DEFAULT NULL,
    p_end_date      IN   DATE     DEFAULT NULL,
    p_err_flag      IN   NUMBER   DEFAULT 0,
    p_err_msg       IN   VARCHAR2 DEFAULT NULL
);

PROCEDURE get_summarized_data (
    p_project_ids           IN   SYSTEM.pa_num_tbl_type := SYSTEM.pa_num_tbl_type(),
    p_resource_list_ids     IN   SYSTEM.pa_num_tbl_type := SYSTEM.pa_num_tbl_type(),
    p_struct_ver_ids        IN   SYSTEM.pa_num_tbl_type := SYSTEM.pa_num_tbl_type(),
    p_start_date            IN   DATE := NULL,
    p_end_date              IN   SYSTEM.PA_DATE_TBL_TYPE := SYSTEM.PA_DATE_TBL_TYPE(),
    p_start_period_name     IN   VARCHAR2 := NULL,
    p_end_period_name       IN   VARCHAR2 := NULL,
    p_calendar_type         IN   SYSTEM.PA_VARCHAR2_1_TBL_TYPE := SYSTEM. PA_VARCHAR2_1_TBL_TYPE(),
    p_extraction_type       IN   VARCHAR2 := NULL,
    p_calling_context       IN   VARCHAR2 := NULL,
    p_record_type           IN   VARCHAR2,
    p_currency_type         IN   NUMBER,
    x_return_status         OUT NOCOPY VARCHAR2,
    x_msg_code              OUT NOCOPY VARCHAR2);

/*
PROCEDURE populate_workplan_data (
    p_project_id           IN   NUMBER,
    p_struct_ver_id        IN   NUMBER DEFAULT NULL,
    p_base_struct_ver_id   IN   NUMBER DEFAULT NULL,
    p_plan_version_id      IN   NUMBER DEFAULT NULL,
    p_progress_actuals_flag IN  VARCHAR2 DEFAULT 'N',
    p_as_of_date           IN   DATE DEFAULT NULL,
    p_delete_flag          IN   VARCHAR2 := 'Y',
    p_workplan_flag        IN   VARCHAR2 := 'Y',
    p_project_element_id   IN   NUMBER DEFAULT NULL,
    p_calling_context       IN   VARCHAR2 := NULL,
    p_program_rollup_flag IN   VARCHAR2 DEFAULT 'N',
    x_return_status OUT NOCOPY VARCHAR2,
    x_msg_code      OUT NOCOPY VARCHAR2 ); */



PROCEDURE populate_updatewbs_data (
    p_project_id           IN   NUMBER,
    p_struct_ver_id        IN   NUMBER DEFAULT NULL,
    p_base_struct_ver_id   IN   NUMBER DEFAULT NULL,
    p_plan_version_id      IN   NUMBER DEFAULT NULL,
    p_as_of_date           IN   DATE DEFAULT NULL,
    p_delete_flag          IN   VARCHAR2 := 'Y',
    p_project_element_id   IN   NUMBER DEFAULT NULL,
    p_level	      IN   NUMBER DEFAULT 1,
    p_structure_flag   IN   VARCHAR2 DEFAULT 'N',
    x_return_status OUT NOCOPY VARCHAR2,
    x_msg_code      OUT NOCOPY VARCHAR2 );


PROCEDURE FPM_UPGRADE_INITIALIZE;

PROCEDURE FPM_UPGRADE_END;

PROCEDURE REMAP_RBS_TXN_ACCUM_HDRS (
     x_return_status                    OUT NOCOPY      VARCHAR2
    ,x_msg_data                         OUT NOCOPY      VARCHAR2
    ,x_msg_count                        OUT NOCOPY      NUMBER );

PROCEDURE get_msp_actuals_data(
       p_project_id IN NUMBER,
       p_calendar_type IN VARCHAR2,
       p_resource_list_id IN NUMBER DEFAULT NULL,
       p_task_res_flag IN VARCHAR2,
       p_end_date IN DATE,
       x_return_status OUT NOCOPY VARCHAR2,
       x_msg_code OUT NOCOPY VARCHAR2);



TYPE populate_in_rec_type IS RECORD
(   project_id              NUMBER(25) ,
    struct_ver_id           NUMBER(25),
    base_struct_ver_id      NUMBER(25) ,
    plan_version_id          NUMBER (25) ,
    as_of_date               DATE	,
    project_element_id   NUMBER (25)
);

TYPE populate_in_tbl_type IS TABLE OF populate_in_rec_type
INDEX BY BINARY_INTEGER;
populate_in_default_tbl populate_in_tbl_type;


PROCEDURE populate_workplan_data (
    p_populate_in_tbl       IN   populate_in_tbl_type  := populate_in_default_tbl,
    p_project_id            IN   NUMBER DEFAULT NULL,
    p_struct_ver_id         IN   NUMBER DEFAULT NULL,
    p_base_struct_ver_id    IN   NUMBER DEFAULT NULL,
    p_plan_version_id       IN   NUMBER DEFAULT NULL,
    p_progress_actuals_flag IN   VARCHAR2 DEFAULT 'N',
    p_as_of_date            IN   DATE DEFAULT NULL,
    p_delete_flag           IN   VARCHAR2 := 'Y',
    p_workplan_flag         IN   VARCHAR2 := 'Y',
    p_project_element_id    IN   NUMBER DEFAULT NULL,
    p_calling_context       IN   VARCHAR2 := NULL,
    p_program_rollup_flag   IN   VARCHAR2 DEFAULT 'N',
    x_return_status OUT NOCOPY VARCHAR2,
    x_msg_code      OUT NOCOPY VARCHAR2 );


END PJI_FM_XBS_ACCUM_UTILS;

 

/
