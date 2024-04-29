--------------------------------------------------------
--  DDL for Package ZPB_ACVAL_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."ZPB_ACVAL_PVT" AUTHID CURRENT_USER AS
/* $Header: ZPBACVLS.pls 120.0.12010.4 2006/08/03 11:54:24 appldev noship $  */

  g_req_child_nodes       CONSTANT number := 0;

  QUERY_OBJECT_PATH       CONSTANT varchar2(17) := 'QUERY_OBJECT_PATH';
  QUERY_OBJECT_NAME       CONSTANT varchar2(17) := 'QUERY_OBJECT_NAME';
  MAX_LENGTH              CONSTANT number := 32000;


--  this procedure returns 'Y' n the OUT parameter if the changes can
--  be applied to the current run of the BP. Otherwise it will return 'N' in the
--  OUT parameter
PROCEDURE validate_currentrun (
  p_analysis_cycle_id   IN  zpb_analysis_cycles.analysis_cycle_id%type,
  x_changeCurrentRun               OUT NOCOPY VARCHAR2) ;



-- this procedure returns can return 4 different values in the output variable
-- 0: both queries are identical
-- 1: first query is a subset of second
-- 2: second query is a subset of first
-- 3: both queries are different
PROCEDURE compare_line_members(p_first_query IN varchar2,
                               p_second_query IN varchar2,
                               x_equal OUT NOCOPY integer);
-- this procedure initializes the solve objects from the
-- shared aw. These objects will be used by the validation routines that
-- will be called by FWK subsequent to this call
PROCEDURE initialize_solve_object(
  p_analysis_cycle_id   IN  zpb_analysis_cycles.analysis_cycle_id%type);



-- this procedure detaches all attached aw. It is called by fwk code to detach
-- all the aw that were used by the validation api's
PROCEDURE detach_aw(p_data_aw IN varchar2);


-- This procedure validates that the line members in Solve are identical
-- to the line members in the data model
--
-- it returns 1 output variable
-- x_comparision: this variable is a boolean and can contain either
--                'Y' or 'N'
PROCEDURE val_solve_eq_model(
  p_analysis_cycle_id   IN  zpb_analysis_cycles.analysis_cycle_id%type,
  x_comparision               OUT NOCOPY VARCHAR2);



-- This procedure validates that all the loaded line members in
-- the Solve definition are part of a Load Data task
--
-- it returns 2 output variables
-- x_isvalid: this variable is a boolean and can contain either
--            'Y' or 'N'
-- x_task_name:  this variable will contain a list of all
--               line member of source type LOADED which does not
--               exist in a LOAD DATA task
PROCEDURE val_solve_eq_data_load(
  p_analysis_cycle_id   IN  zpb_analysis_cycles.analysis_cycle_id%type,
  x_isvalid               OUT NOCOPY VARCHAR2,
  x_dim_members           OUT NOCOPY VARCHAR2);

-- This procedure validates that all the line members in a Load Data
-- task are defined as LOADED in the Solve definition
--
-- it returns 3 output variables
-- x_isvalid: this variable is a boolean and can contain either
--            'Y' or 'N'
-- x_task_name:  this variable will contain a list of all
--               LOAD DATA  tasks that  have a line member which does not
--               exist in the Solve definition with source type LOADED
-- x_dim_members: list of line members which exist in a LOAD DATA task
--                but do not exist in the Solve definition with source
--                type LOADED
PROCEDURE val_solve_gt_than_load(
  p_analysis_cycle_id   IN  zpb_analysis_cycles.analysis_cycle_id%type,
  x_isvalid               OUT NOCOPY VARCHAR2,
  x_task_name               OUT NOCOPY VARCHAR2,
  x_dim_members           OUT NOCOPY VARCHAR2);




-- This procedure validates that every Generate Template task contains
-- at least one line member of source type INPUT
--
-- it returns 2 output variables
-- x_isvalid: this variable is a boolean and can contain either
--            'Y' or 'N'
-- x_invalid_tasks_list: this variable will contain a list of all
--                       generate template tasks that do not have
--                       a line member of source type INPUT
PROCEDURE validate_generate_worksheet(
  p_analysis_cycle_id   IN  zpb_analysis_cycles.analysis_cycle_id%type,
  x_isvalid               OUT NOCOPY VARCHAR2 ,
  x_invalid_tasks_list     OUT NOCOPY VARCHAR2);



-- this procedure validates the solve input  levels
--
--
-- it returns 2 output variables
-- x_isvalid: this variable is a boolean and can contain either
--            'Y' or 'N'
-- x_invalid_dim_list: this variable will contain a list
--                         of invalid input dimensions if the x_isvalid
--                         is equal to 'N' i.e validation failed
-- x_invalid_linemem_list: this variable will contain a list
--                         of invalid line member ids if the x_isvalid
--                         is equal to 'N' i.e validation failed
PROCEDURE validate_input_selections(
  p_api_version          IN NUMBER,
  p_init_msg_list        IN VARCHAR2 := FND_API.G_FALSE,
  p_commit               IN VARCHAR2 :=  FND_API.G_FALSE,
  p_validation_level     IN NUMBER := FND_API.G_VALID_LEVEL_FULL,
  x_return_status        OUT NOCOPY VARCHAR2 ,
  x_msg_count            OUT NOCOPY NUMBER,
  x_msg_data             OUT NOCOPY VARCHAR2,
  p_analysis_cycle_id    IN  zpb_analysis_cycles.analysis_cycle_id%type,
  p_inputDims            IN  VARCHAR2,
  x_isvalid              OUT NOCOPY VARCHAR2,
  x_invalid_dim_list     OUT NOCOPY VARCHAR2,
  x_invalid_linemem_list OUT NOCOPY VARCHAR2);



-- this procedure validates the solve input and output levels .
-- it ensures that they  are defined and share a hierarchy
-- it returns 2 output variables
-- x_isvalid: this variable is a boolean and can contain either
--            'Y' or 'N'
-- x_invalid_linemem_list: this variable will contain a list
--                         of invalid line member ids if the x_isvalid
--                         is equal to 'N' i.e validation failed
PROCEDURE validate_solve_levels(
  p_api_version          IN NUMBER,
  p_init_msg_list        IN VARCHAR2 := FND_API.G_FALSE,
  p_commit               IN VARCHAR2 :=  FND_API.G_FALSE,
  p_validation_level     IN NUMBER := FND_API.G_VALID_LEVEL_FULL,
  x_return_status        OUT NOCOPY VARCHAR2 ,
  x_msg_count            OUT NOCOPY NUMBER,
  x_msg_data             OUT NOCOPY VARCHAR2,
  p_analysis_cycle_id    IN  zpb_analysis_cycles.analysis_cycle_id%type,
  p_outputDims          IN  VARCHAR2,
  x_isvalid              OUT NOCOPY VARCHAR2,
  x_invalid_linemem_list OUT NOCOPY VARCHAR2);


-- this procedure validates the template lines are a subset of the
-- model lines
--
--
-- it returns 2 output variables
-- x_isvalid: this variable is a boolean and can contain either
--            'Y' or 'N'
-- x_invalid_task_list: this variable will contain a list
--                      of generate tasks which are  invalid i.e.
--                      contain lines that are not in the model
PROCEDURE val_template_le_model(
  p_api_version          IN NUMBER,
  p_init_msg_list        IN VARCHAR2 := FND_API.G_FALSE,
  p_commit               IN VARCHAR2 :=  FND_API.G_FALSE,
  p_validation_level     IN NUMBER := FND_API.G_VALID_LEVEL_FULL,
  x_return_status        OUT NOCOPY VARCHAR2 ,
  x_msg_count            OUT NOCOPY NUMBER,
  x_msg_data             OUT NOCOPY VARCHAR2,
  p_analysis_cycle_id    IN  zpb_analysis_cycles.analysis_cycle_id%type,
  x_isvalid              OUT NOCOPY VARCHAR2,
  x_invalid_tasks_list OUT NOCOPY VARCHAR2);

-- this procedure returns two possible output values
-- 'Y': The union of Line Members of ALL Generate Template Tasks is equal to the
--       NON_INITIALIZED  inputted line members of Solve
-- 'N': The union of Line Members of ALL  Generate Template Tasks is different from the
--       NON_INITIALIZED  inputted line members of Solve
procedure val_solveinp_eq_gentemp(
  p_api_version          IN NUMBER,
  p_init_msg_list        IN VARCHAR2 := FND_API.G_FALSE,
  p_commit               IN VARCHAR2 :=  FND_API.G_FALSE,
  p_validation_level     IN NUMBER := FND_API.G_VALID_LEVEL_FULL,
  x_return_status        OUT NOCOPY VARCHAR2 ,
  x_msg_count            OUT NOCOPY NUMBER,
  x_msg_data             OUT NOCOPY VARCHAR2,
  p_analysis_cycle_id   IN  zpb_analysis_cycles.analysis_cycle_id%type,
  x_isvalid               OUT NOCOPY VARCHAR2,
  x_dim_members           OUT NOCOPY VARCHAR2);



-- this procedure validates the solve input and output levels .
-- it ensures that they   share a hierarchy and the input level
-- is not lower than the output level
-- it returns 2 output variables
-- x_isvalid: this variable is a boolean and can contain either
--            'Y' or 'N'
-- x_invalid_linemem_list: this variable will contain a list
--                         of invalid line member ids if the x_isvalid
--                         is equal to 'N' i.e validation failed
PROCEDURE val_solve_input_higher_levels(
  p_api_version          IN NUMBER,
  p_init_msg_list        IN VARCHAR2 := FND_API.G_FALSE,
  p_commit               IN VARCHAR2 :=  FND_API.G_FALSE,
  p_validation_level     IN NUMBER := FND_API.G_VALID_LEVEL_FULL,
  x_return_status        OUT NOCOPY VARCHAR2 ,
  x_msg_count            OUT NOCOPY NUMBER,
  x_msg_data             OUT NOCOPY VARCHAR2,
  p_analysis_cycle_id    IN  zpb_analysis_cycles.analysis_cycle_id%type,
  x_isvalid              OUT NOCOPY VARCHAR2,
  x_invalid_linemem_list OUT NOCOPY VARCHAR2);

-- this procedure validates the solve output  levels
--
--
-- it returns 2 output variables
-- x_isvalid: this variable is a boolean and can contain either
--            'Y' or 'N'
-- x_invalid_dim_list: this variable will contain a list
--                         of invalid input dimensions if the x_isvalid
--                         is equal to 'N' i.e validation failed
-- x_invalid_linemem_list: this variable will contain a list
--                         of invalid line member ids if the x_isvalid
--                         is equal to 'N' i.e validation failed
PROCEDURE validate_output_selections(
  p_api_version          IN NUMBER,
  p_init_msg_list        IN VARCHAR2 := FND_API.G_FALSE,
  p_commit               IN VARCHAR2 :=  FND_API.G_FALSE,
  p_validation_level     IN NUMBER := FND_API.G_VALID_LEVEL_FULL,
  x_return_status        OUT NOCOPY VARCHAR2 ,
  x_msg_count            OUT NOCOPY NUMBER,
  x_msg_data             OUT NOCOPY VARCHAR2,
  p_analysis_cycle_id    IN  zpb_analysis_cycles.analysis_cycle_id%type,
  p_outputDims            IN  VARCHAR2,
  x_isvalid              OUT NOCOPY VARCHAR2,
  x_invalid_dim_list     OUT NOCOPY VARCHAR2,
  x_invalid_linemem_list OUT NOCOPY VARCHAR2);

-- this procedure validates that the solve input and output selections .
-- share a hierarchy with the horizon start and end levels
-- it returns 1 output variable
-- x_isvalid: this variable is a boolean and can contain either
--            'Y' or 'N'
PROCEDURE val_solve_hrzselections(
  p_api_version          IN NUMBER,
  p_init_msg_list        IN VARCHAR2 := FND_API.G_FALSE,
  p_commit               IN VARCHAR2 :=  FND_API.G_FALSE,
  p_validation_level     IN NUMBER := FND_API.G_VALID_LEVEL_FULL,
  x_return_status        OUT NOCOPY VARCHAR2 ,
  x_msg_count            OUT NOCOPY NUMBER,
  x_msg_data             OUT NOCOPY VARCHAR2,
  p_analysis_cycle_id    IN  zpb_analysis_cycles.analysis_cycle_id%type,
  p_hrz_level            IN VARCHAR2,
  x_isvalid              OUT NOCOPY VARCHAR2);

-- To delete view for an active instance
-- and clean up its worksheets

PROCEDURE delete_view(
  p_analysis_cycle_id    IN  zpb_analysis_cycles.analysis_cycle_id%type);

PROCEDURE has_validation_errors(
    itemtype    IN varchar2,
    itemkey     IN varchar2,
    actid       IN number,
    funcmode    IN varchar2,
    resultout   OUT nocopy varchar2);

END zpb_acval_pvt;

 

/
