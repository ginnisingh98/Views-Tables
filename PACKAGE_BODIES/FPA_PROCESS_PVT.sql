--------------------------------------------------------
--  DDL for Package Body FPA_PROCESS_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."FPA_PROCESS_PVT" as
/* $Header: FPAVPRCB.pls 120.9 2006/05/05 16:05:19 appldev noship $ */


 G_PKG_NAME    CONSTANT VARCHAR2(200) := 'FPA_PROCESS_PVT';
 G_APP_NAME    CONSTANT VARCHAR2(3)   :=  FPA_UTILITIES_PVT.G_APP_NAME;
 G_API_TYPE    CONSTANT VARCHAR2(4)   := '_PVT';
 L_API_NAME    CONSTANT VARCHAR2(35)  := 'PROCESS';


PROCEDURE Copy_Portfolio(p_portfolio_obj IN  FPA_PORTFO_ALL_OBJ);
PROCEDURE create_update_access_list
     ( p_portf_users_tbl IN  FPA_PORTFOLIO_USERS_TBL,
      p_portfolio_id  NUMBER,
       x_return_status      OUT NOCOPY  VARCHAR2,
       x_msg_data           OUT NOCOPY  VARCHAR2,
       x_msg_count          OUT NOCOPY  NUMBER
    );


/************************************************************************************/
-- PLANNING CYCLE PROCEDURES
/************************************************************************************/

/*
 * CREATE case for Planning Cycle(PC). This creates the complete PC
 * The calling program must populate all object types in fpa_pc_all_obj
 * except for fpa_pc_inv_criteria_tbl, which is being done in this API.
 */

PROCEDURE Create_Pc
     ( p_api_version        IN NUMBER,
       p_commit             IN VARCHAR2 := FND_API.G_FALSE,
       p_pc_all_obj         IN fpa_pc_all_obj,
       x_planning_cycle_id  OUT NOCOPY NUMBER,
       x_return_status      OUT NOCOPY VARCHAR2,
       x_msg_data           OUT NOCOPY VARCHAR2,
       x_msg_count          OUT NOCOPY NUMBER)

IS
    l_pcName_Count         NUMBER;
    l_new_pc_id            NUMBER;
    l_distr_list_id        NUMBER;
    l_portfolio_name       VARCHAR2(80);
    l_inv_criteria_len     NUMBER;
    l_last_pcid            NUMBER;
    l_pc_info              fpa_pc_info_obj;
    l_inv_matrix_tbl       fpa_pc_inv_matrix_tbl;
    l_fin_targets_tbl      fpa_pc_fin_targets_tbl;
    l_discount_obj         fpa_pc_discount_obj;
    l_inv_criteria_tbl     fpa_pc_inv_criteria_tbl;
    l_inv_criteria_obj     fpa_pc_inv_criteria_obj;
    l_distr_list           fpa_pc_distr_list_obj;
    l_distr_list_items_tbl fpa_pc_distr_list_items_tbl;
    l_inv_crit_count       NUMBER := 0;

     /*
      * Investment Criteria Cursor to get default weights from setup
      * while Creating PC in the Portfolio
      */
     CURSOR c_inv_criteria_setup IS
     SELECT a.strategic_obj
            ,nvl(e.strategic_obj_weight,0)
            ,0 Targetfrom
            ,0 Targetto
       FROM fpa_aw_inv_criteria_v a
            ,fpa_aw_inv_criteria_info_v e
     WHERE a.strategic_obj = e.strategic_obj;


   PROCEDURE Get_Inv_Crit_Setup_Defaults
   IS
    l_cntr                 NUMBER := 0;
   BEGIN
      IF FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
        FND_LOG.String
        ( FND_LOG.LEVEL_PROCEDURE,
          'fpa.sql.FPA_Process_Pvt.Create_Pc',
          'Inside Get_Inv_Criteria_Setup_Defaults Sub Procedure'
        );
      END IF;
      l_cntr := 1;

      l_inv_criteria_tbl := fpa_pc_inv_criteria_tbl();

      l_inv_criteria_tbl.EXTEND(l_inv_crit_count);

            OPEN c_inv_criteria_setup;
              --FOR i IN l_inv_criteria_tbl.FIRST .. l_inv_criteria_tbl.LAST
                LOOP

                  l_inv_criteria_obj := fpa_pc_inv_criteria_obj(null,null,null,null,null,null,null,null);
                  FETCH c_inv_criteria_setup INTO l_inv_criteria_obj.investment_criteria,
                                          l_inv_criteria_obj.pc_inv_criteria_weight,
                                          l_inv_criteria_obj.pc_inv_crit_score_target_from,
                                          l_inv_criteria_obj.pc_inv_crit_score_target_to;
                  EXIT WHEN c_inv_criteria_setup%NOTFOUND;
                  l_inv_criteria_obj.planning_cycle := l_new_pc_id;
                  l_inv_criteria_obj.pc_project_score_source := 'NEWSCORE';
                  l_inv_criteria_obj.pc_project_score_scale := 10;
                  l_inv_criteria_tbl(l_cntr) := l_inv_criteria_obj;
                  l_cntr := l_cntr + 1;
                END LOOP;
             CLOSE c_inv_criteria_setup;

      IF FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
        FND_LOG.String
        ( FND_LOG.LEVEL_PROCEDURE,
          'fpa.sql.FPA_Process_Pvt.Create_Pc',
          'Leaving Get_Inv_Criteria_Setup_Defaults Sub Procedure'
        );
      END IF;

   EXCEPTION
     WHEN OTHERS THEN
       IF FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
        FND_LOG.String
        ( FND_LOG.LEVEL_PROCEDURE,
          'fpa.sql.FPA_Process_Pvt.Create_Pc.Get_Inv_Criteria_Setup_Defaults',
          'Error occurred.'
        );
      END IF;


   END Get_Inv_Crit_Setup_Defaults;

BEGIN
    -- clear all previous messages.
        FND_MSG_PUB.Initialize;

    IF FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
        FND_LOG.String
        (
            FND_LOG.LEVEL_PROCEDURE,
            'fpa.sql.FPA_Process_Pvt.Create_Pc.begin',
            'Entering FPA_Process_Pvt.Create_Pc'
        );
    END IF;

    IF FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
        FND_LOG.String
        (
            FND_LOG.LEVEL_PROCEDURE,
            'fpa.sql.FPA_Process_Pvt.Create_Pc',
            'Calling FPA_PlanningCycle_Pvt.Check_Pc_Name'
        );
    END IF;

    l_pcName_Count := FPA_PlanningCycle_Pvt.Check_Pc_Name
                      (
                        p_api_version => p_api_version,
                        p_portfolio_id => p_pc_all_obj.pc_info.portfolio,
                        p_pc_name => p_pc_all_obj.pc_desc_fields.name,
                        p_pc_id => p_pc_all_obj.pc_desc_fields.id,
                        x_return_status => x_return_status,
                        x_msg_data => x_msg_data,
                        x_msg_count => x_msg_count
                      );

    -- If Duplicate Pc Name exists, then raise error and halt all execution
    IF l_pcName_Count > 0 THEN

     -- Get the name of Portfolio for this Planning cycle
        SELECT p.name INTO l_portfolio_name
        FROM fpa_portfs_vl p
        WHERE portfolio = p_pc_all_obj.pc_info.portfolio;

     -- Specify the msg, add it in FND_MSG_PUB and raise exp error
        FND_MESSAGE.SET_NAME('FPA','FPA_DUPLICATE_PCNAME');
        FND_MESSAGE.SET_TOKEN('PORTFOLIO_NAME', l_portfolio_name);
        FND_MESSAGE.SET_TOKEN('PC_NAME', p_pc_all_obj.pc_desc_fields.name);
        FND_MSG_PUB.ADD;
        RAISE FND_API.G_EXC_ERROR;

    END IF;

    -- Initialize local pcInfo and other objects from the input pc_all object
    IF FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
        FND_LOG.String
        ( FND_LOG.LEVEL_PROCEDURE,
          'fpa.sql.FPA_Process_Pvt.Create_Pc',
          'Initializing p_pc_all_obj members.'
        );
    END IF;

    IF p_pc_all_obj.pc_info IS NOT NULL THEN
      l_pc_info := p_pc_all_obj.pc_info;
    END IF;
    IF p_pc_all_obj.pc_investmix IS NOT NULL THEN
      l_inv_matrix_tbl := p_pc_all_obj.pc_investmix;
    END IF;
    IF p_pc_all_obj.pc_targets IS NOT NULL THEN
      l_fin_targets_tbl := p_pc_all_obj.pc_targets;
    END IF;
    IF p_pc_all_obj.pc_discount IS NOT NULL THEN
      l_discount_obj := p_pc_all_obj.pc_discount;
    END IF;
    IF p_pc_all_obj.pc_invest_criteria IS NOT NULL THEN
      l_inv_criteria_tbl := p_pc_all_obj.pc_invest_criteria;
    END IF;

    IF p_pc_all_obj.pc_distr_list IS NOT NULL THEN
      l_distr_list := p_pc_all_obj.pc_distr_list;
    END IF;
    IF p_pc_all_obj.distr_list_items IS NOT NULL THEN
      l_distr_list_items_tbl := p_pc_all_obj.distr_list_items;
    END IF;

    IF FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
        FND_LOG.String
        ( FND_LOG.LEVEL_PROCEDURE,
          'fpa.sql.FPA_Process_Pvt.Create_Pc',
          'Calling Fpa_Utilities_Pvt.attach_AW.'
        );
    END IF;

-- Attach AW Workspace
     Fpa_Utilities_Pvt.attach_AW
                        (
                          p_api_version => 1.0,
                          p_attach_mode => 'rw',
                          x_return_status => x_return_status,
                          x_msg_count => x_msg_count,
                          x_msg_data => x_msg_data
                        );

    IF FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
        FND_LOG.String
        ( FND_LOG.LEVEL_PROCEDURE,
          'fpa.sql.FPA_Process_Pvt.Create_Pc',
          'Calling FPA_PlanningCycle_Pvt.Create_Pc.'
        );
    END IF;

    -- Call procedure FPA_PlanningCycle_Pvt.Create_Pc
        FPA_PlanningCycle_Pvt.Create_Pc
                    (
                        p_api_version => 1.0,
                        p_pc_all_obj => p_pc_all_obj,
                        x_planning_cycle_id => l_new_pc_id,
                        x_return_status  =>  x_return_status,
                        x_msg_data  =>  x_msg_data,
                        x_msg_count =>  x_msg_count
                    );

    IF FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
        FND_LOG.String
        ( FND_LOG.LEVEL_PROCEDURE,
          'fpa.sql.FPA_Process_Pvt.Create_Pc',
          'Setting obtained pc Id to all necessary object members.'
        );
    END IF;

    -- set the new PC ID in local pc_info and other objects
        IF l_pc_info IS NOT NULL THEN
          IF FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
              FND_LOG.String
              ( FND_LOG.LEVEL_PROCEDURE,
                'fpa.sql.FPA_Process_Pvt.Create_Pc',
                'Setting l_pc_info.planning_cycle with value ' || l_new_pc_id
              );
          END IF;
          l_pc_info.planning_cycle := l_new_pc_id;
        END IF;
        IF l_inv_matrix_tbl IS NOT NULL THEN
          IF FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
              FND_LOG.String
              ( FND_LOG.LEVEL_PROCEDURE,
                'fpa.sql.FPA_Process_Pvt.Create_Pc',
                'Setting l_inv_matrix_tbl(1).planning_cycle with value ' || l_new_pc_id
              );
          END IF;
          l_inv_matrix_tbl(1).planning_cycle := l_new_pc_id;
        END IF;
        IF l_fin_targets_tbl IS NOT NULL THEN
          IF FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
              FND_LOG.String
              ( FND_LOG.LEVEL_PROCEDURE,
                'fpa.sql.FPA_Process_Pvt.Create_Pc',
                'Setting l_fin_targets_tbl(1).planning_cycle with value ' || l_new_pc_id
              );
          END IF;
          l_fin_targets_tbl(1).planning_cycle := l_new_pc_id;
        END IF;
        IF l_discount_obj IS NOT NULL THEN
          IF FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
              FND_LOG.String
              ( FND_LOG.LEVEL_PROCEDURE,
                'fpa.sql.FPA_Process_Pvt.Create_Pc',
                'Setting l_discount_obj.planning_cycle with value ' || l_new_pc_id
              );
          END IF;
          l_discount_obj.planning_cycle := l_new_pc_id;
        END IF;

        IF l_distr_list IS NOT NULL THEN
          IF FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
              FND_LOG.String
              ( FND_LOG.LEVEL_PROCEDURE,
                'fpa.sql.FPA_Process_Pvt.Create_Pc',
                'Setting l_distr_list.object_id with value ' || l_new_pc_id
              );
          END IF;
          l_distr_list.object_id := l_new_pc_id;
        END IF;

        IF l_inv_criteria_tbl IS NOT NULL THEN
          IF FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
              FND_LOG.String
              ( FND_LOG.LEVEL_PROCEDURE,
                'fpa.sql.FPA_Process_Pvt.Create_Pc',
                'Setting l_inv_criteria_tbl(1).planning_cycle with value ' || l_new_pc_id
              );
          END IF;
          l_inv_criteria_tbl(1).planning_cycle := l_new_pc_id;
        END IF;
    -- set the new PC ID in the return parameter
        x_planning_cycle_id := l_new_pc_id;

    /*
     * Check if the current portfolio has last approved planning cycle.
     *
     */
    IF FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
        FND_LOG.String
        ( FND_LOG.LEVEL_PROCEDURE,
          'fpa.sql.FPA_Process_Pvt.Create_Pc',
          'Checking if portfolio has an approved PC.'
        );
    END IF;

   -- Get the no. of Invest Criterias from setup.
        SELECT count(strategic_obj)
        INTO l_inv_crit_count
        FROM fpa_aw_inv_criteria_v;

    /*   Check for the Investment Criteria Table Type Object.
     *   If it is null then we populate it with values from the Investment
     *   Criteria at the Application level.
     *   These are the Default values for the Current Planning Cycle
     */

    IF p_pc_all_obj.pc_invest_criteria IS NULL THEN
      IF FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
        FND_LOG.String
        ( FND_LOG.LEVEL_PROCEDURE,
          'fpa.sql.FPA_Process_Pvt.Create_Pc',
          'p_pc_all_obj.pc_invest_criteria is null and about to call Get_Inv_Crit_Setup_Defaults.'
        );
      END IF;
       -- There is nothing received from java, get the setup defaults and populate
       -- l_inv_criteria_tbl
        Get_Inv_Crit_Setup_Defaults;
        IF FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
          FND_LOG.String
          ( FND_LOG.LEVEL_PROCEDURE,
            'fpa.sql.FPA_Process_Pvt.Create_Pc',
            'Calling FPA_PlanningCycle_Pvt.Update_Pc_Inv_Criteria_Data for Setup values, when UI did not have any values.'
          );
        END IF;
        FPA_PlanningCycle_Pvt.Update_Pc_Inv_Criteria_Data
          (
            p_api_version => 1.0,
            p_inv_crit_tbl  => l_inv_criteria_tbl,
            x_return_status  =>  x_return_status,
            x_msg_data   =>  x_msg_data,
            x_msg_count  =>  x_msg_count
          );
    ELSE
      IF FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
        FND_LOG.String
        ( FND_LOG.LEVEL_PROCEDURE,
          'fpa.sql.FPA_Process_Pvt.Create_Pc',
          'p_pc_all_obj.pc_invest_criteria is not null'
        );
      END IF;

      IF l_inv_crit_count <> p_pc_all_obj.pc_invest_criteria.COUNT THEN

        IF FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
          FND_LOG.String
          ( FND_LOG.LEVEL_PROCEDURE,
            'fpa.sql.FPA_Process_Pvt.Create_Pc',
            'UI criteria count and setup criteria count are not the same.'
          );
        END IF;
        -- Call Get_Inv_Crit_Setup_Defaults, where we reinitialize l_inv_criteria_tbl
        -- and get the invest criterias from setup.
        IF FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
          FND_LOG.String
          ( FND_LOG.LEVEL_PROCEDURE,
            'fpa.sql.FPA_Process_Pvt.Create_Pc',
            'Calling Get_Inv_Crit_Setup_Defaults.'
          );
        END IF;
        Get_Inv_Crit_Setup_Defaults;

        -- Call update for setup data.
        IF FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
          FND_LOG.String
          ( FND_LOG.LEVEL_PROCEDURE,
            'fpa.sql.FPA_Process_Pvt.Create_Pc',
            'Calling FPA_PlanningCycle_Pvt.Update_Pc_Inv_Criteria_Data for setting up default values.'
          );
        END IF;
         FPA_PlanningCycle_Pvt.Update_Pc_Inv_Criteria_Data
         (
           p_api_version => 1.0,
           p_inv_crit_tbl  => l_inv_criteria_tbl,
           x_return_status  =>  x_return_status,
           x_msg_data   =>  x_msg_data,
           x_msg_count  =>  x_msg_count
         );
         -- Reassign java values to l_inv_criteria_tbl from java for next update
         IF FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
          FND_LOG.String
          ( FND_LOG.LEVEL_PROCEDURE,
            'fpa.sql.FPA_Process_Pvt.Create_Pc',
            'Reassigning UI values to l_inv_criteria_tbl.'
          );
         END IF;
         l_inv_criteria_tbl := p_pc_all_obj.pc_invest_criteria;
         l_inv_criteria_tbl(1).planning_cycle := l_new_pc_id;
        --l_inv_crit_partial_count := l_inv_crit_count_java;

      END IF;
      IF FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
        FND_LOG.String
        ( FND_LOG.LEVEL_PROCEDURE,
          'fpa.sql.FPA_Process_Pvt.Create_Pc',
          'Calling FPA_PlanningCycle_Pvt.Update_Pc_Inv_Criteria_Data for UI values.'
        );
      END IF;
      FPA_PlanningCycle_Pvt.Update_Pc_Inv_Criteria_Data
        (
          p_api_version => 1.0,
          p_inv_crit_tbl  => l_inv_criteria_tbl,
          x_return_status  =>  x_return_status,
          x_msg_data   =>  x_msg_data,
          x_msg_count  =>  x_msg_count
        );
    END IF;


    IF p_pc_all_obj.pc_investmix IS NOT NULL THEN

      IF FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
        FND_LOG.String
        ( FND_LOG.LEVEL_PROCEDURE,
          'fpa.sql.FPA_Process_Pvt.Create_Pc.begin',
          'Calling FPA_PlanningCycle_Pvt.Update_Pc_Invest_Mix.'
        );
      END IF;

          FPA_PlanningCycle_Pvt.Update_Pc_Invest_Mix
               (
                p_api_version => 1.0,
                p_inv_matrix  => l_inv_matrix_tbl,
                x_return_status  =>  x_return_status,
                x_msg_data   =>  x_msg_data,
                x_msg_count  =>  x_msg_count
              );
    END IF;



    IF FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
        FND_LOG.String
        ( FND_LOG.LEVEL_PROCEDURE,
          'fpa.sql.FPA_Process_Pvt.Create_Pc',
          'Calling FPA_PlanningCycle_Pvt.Set_Pc_Status'
        );
    END IF;

        FPA_PlanningCycle_Pvt.Set_Pc_Status
            (
                p_api_version => 1.0,
                p_pc_id => l_new_pc_id,
                p_pc_status_code => 'CREATED',
                x_return_status  =>  x_return_status,
                x_msg_data  =>  x_msg_data,
                x_msg_count =>  x_msg_count
            );

    IF p_pc_all_obj.pc_info IS NOT NULL THEN
       IF p_pc_all_obj.pc_info.pc_category IS NOT NULL THEN
         IF FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
             FND_LOG.String
             ( FND_LOG.LEVEL_PROCEDURE,
              'fpa.sql.FPA_Process_Pvt.Create_Pc',
              'Calling FPA_PlanningCycle_Pvt.Update_Pc_Class_Category.'
             );
         END IF;

        FPA_PlanningCycle_Pvt.Update_Pc_Class_Category
             (
                p_api_version => 1.0,
                p_pc_id  => l_new_pc_id,
                p_catg_id => p_pc_all_obj.pc_info.pc_category,
                x_return_status  =>  x_return_status,
                x_msg_data   =>  x_msg_data,
                x_msg_count  =>  x_msg_count
              );
        END IF;

      IF p_pc_all_obj.pc_info.calendar_name IS NOT NULL THEN
        IF FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
            FND_LOG.String
            ( FND_LOG.LEVEL_PROCEDURE,
              'fpa.sql.FPA_Process_Pvt.Create_Pc',
              'Calling FPA_PlanningCycle_Pvt.Update_Pc_Calendar'
            );
        END IF;

          FPA_PlanningCycle_Pvt.Update_Pc_Calendar
             (
                p_api_version => 1.0,
                p_pc_info  => l_pc_info,
                x_return_status  =>  x_return_status,
                x_msg_data   =>  x_msg_data,
                x_msg_count  =>  x_msg_count
              );
      END IF;

      IF p_pc_all_obj.pc_info.currency_code IS NOT NULL THEN
        IF FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
            FND_LOG.String
            ( FND_LOG.LEVEL_PROCEDURE,
              'fpa.sql.FPA_Process_Pvt.Create_Pc',
              'Calling FPA_PlanningCycle_Pvt.Update_Pc_Currency'
            );
        END IF;
          FPA_PlanningCycle_Pvt.Update_Pc_Currency
             (
                p_api_version => 1.0,
                p_pc_info  =>  l_pc_info,
                x_return_status  =>  x_return_status,
                x_msg_data   =>  x_msg_data,
                x_msg_count  =>  x_msg_count
              );
      END IF;

      IF l_pc_info.submission_due_date IS NOT NULL THEN
        IF FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
            FND_LOG.String
            ( FND_LOG.LEVEL_PROCEDURE,
              'fpa.sql.FPA_Process_Pvt.Create_Pc',
              'Calling FPA_PlanningCycle_Pvt.Update_Pc_Sub_Due_Date'
            );
        END IF;


          FPA_PlanningCycle_Pvt.Update_Pc_Sub_Due_Date
             (
                p_api_version => 1.0,
                p_pc_info  =>  l_pc_info,
                x_return_status  =>  x_return_status,
                x_msg_data   =>  x_msg_data,
                x_msg_count  =>  x_msg_count
              );
        END IF;

    END IF;

    IF p_pc_all_obj.pc_discount IS NOT NULL THEN
      IF FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
        FND_LOG.String
        ( FND_LOG.LEVEL_PROCEDURE,
          'fpa.sql.FPA_Process_Pvt.Create_Pc',
          'CAlling FPA_PlanningCycle_Pvt.Update_Pc_Discount_funds.'
        );
      END IF;


          FPA_PlanningCycle_Pvt.Update_Pc_Discount_funds
               (
                p_api_version => 1.0,
                p_disc_funds  => l_discount_obj,
                x_return_status  =>  x_return_status,
                x_msg_data   =>  x_msg_data,
                x_msg_count  =>  x_msg_count
              );
    END IF;

    IF p_pc_all_obj.pc_targets IS NOT NULL THEN
      IF FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
        FND_LOG.String
        ( FND_LOG.LEVEL_PROCEDURE,
          'fpa.sql.FPA_Process_Pvt.Create_Pc',
          'CAlling FPA_PlanningCycle_Pvt.Update_Pc_Fin_Targets.'
        );
      END IF;

          FPA_PlanningCycle_Pvt.Update_Pc_Fin_Targets
               (
                p_api_version => 1.0,
                p_fin_targets_tbl  => l_fin_targets_tbl,
                x_return_status  =>  x_return_status,
                x_msg_data   =>  x_msg_data,
                x_msg_count  =>  x_msg_count
              );
    END IF;


    IF p_pc_all_obj.pc_distr_list IS NOT NULL THEN
      IF FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
        FND_LOG.String
        ( FND_LOG.LEVEL_PROCEDURE,
          'fpa.sql.FPA_Process_Pvt.Create_Pc',
          'CAlling FPA_PlanningCycle_Pvt.Pa_Distrb_Lists_Insert_Row.'
        );
      END IF;

        FPA_PlanningCycle_Pvt.Pa_Distrb_Lists_Insert_Row
              (
                p_api_version => 1.0,
                p_distr_list =>  l_distr_list,
                p_list_id    =>  l_distr_list_id,
                x_return_status  =>  x_return_status,
                x_msg_data   =>  x_msg_data,
                x_msg_count  =>  x_msg_count
              );
    END IF;

        --p_distr_list_id := l_distr_list_id
        IF l_distr_list_items_tbl IS NOT NULL THEN
            l_distr_list_items_tbl(1).list_id := l_distr_list_id;
        END IF;

    IF p_pc_all_obj.distr_list_items IS NOT NULL THEN
      IF FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
        FND_LOG.String
        ( FND_LOG.LEVEL_PROCEDURE,
          'fpa.sql.FPA_Process_Pvt.Create_Pc',
          'Calling FPA_PlanningCycle_Pvt.Pa_Dist_List_Items_Update_Row'
        );
      END IF;

        FPA_PlanningCycle_Pvt.Pa_Dist_List_Items_Update_Row
              (
                p_api_version => 1.0,
                p_distr_list_items_tbl =>  l_distr_list_items_tbl,
                x_return_status  =>  x_return_status,
                x_msg_data   =>  x_msg_data,
                x_msg_count  =>  x_msg_count
              );
    END IF;

    -- Update and commit our changes
    IF (p_commit = FND_API.G_TRUE) THEN
      IF FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
        FND_LOG.String
        ( FND_LOG.LEVEL_PROCEDURE,
          'fpa.sql.FPA_Process_Pvt.Create_Pc',
          'Updating and Committing.'
        );
      END IF;
      dbms_aw.execute('UPDATE');
      COMMIT;
    END IF;

    IF FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
        FND_LOG.String
        ( FND_LOG.LEVEL_PROCEDURE,
          'fpa.sql.FPA_Process_Pvt.Create_Pc.begin',
          'CAlling Fpa_Utilities_Pvt.detach_AW.'
        );
    END IF;

-- Detach AW Workspace
       Fpa_Utilities_Pvt.detach_AW
                        (
                          p_api_version => 1.0,
                          x_return_status => x_return_status,
                          x_msg_count => x_msg_count,
                          x_msg_data => x_msg_data
                        );


    IF FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
        FND_LOG.String
        (
            FND_LOG.LEVEL_PROCEDURE,
            'fpa.sql.FPA_Process_Pvt.Create_Pc.end',
            'Exiting FPA_Process_Pvt.Create_Pc'
        );
    END IF;

EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN
        ROLLBACK;

        x_return_status := FND_API.G_RET_STS_ERROR;
        FND_MSG_PUB.Count_And_Get
        (
            p_count  =>      x_msg_count,
            p_data   =>      x_msg_data
        );
        RAISE;

    WHEN OTHERS THEN
        FND_MESSAGE.SET_NAME('FPA','FPA_UNEXP_GENERAL_ERROR');
        FND_MESSAGE.SET_TOKEN('SOURCE', 'fpa.sql.FPA_Process_Pvt.Create_Pc');
        FND_MESSAGE.SET_TOKEN('SQL_ERR_CODE', SQLCODE);
        FND_MESSAGE.SET_TOKEN('SQL_ERR_MSG', SQLERRM);
        FND_MSG_PUB.ADD;
     -- Detach AW Workspace
       Fpa_Utilities_Pvt.detach_AW
                        (
                          p_api_version => 1.0,
                          x_return_status => x_return_status,
                          x_msg_count => x_msg_count,
                          x_msg_data => x_msg_data
                        );

        ROLLBACK;
        x_return_status := FND_API.G_RET_STS_ERROR;

        IF FND_LOG.LEVEL_ERROR >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
        FND_LOG.String
        (
            FND_LOG.LEVEL_ERROR,
            'fpa.sql.FPA_Process_Pvt.Create_Pc',
            SQLERRM
        );
        END IF;

        FND_MSG_PUB.count_and_get
        (
            p_count    =>      x_msg_count,
            p_data     =>      x_msg_data
        );
        --RAISE;

END Create_Pc;


/*
 * UPDATE case for Planning Cycle(PC). This API checks for the null values
 * in object types and only updates not null objects.
 * The calling program populates only those objects in fpa_pc_all_obj
 * which needs update.
 */


PROCEDURE Update_Pc
     ( p_api_version        IN NUMBER,
       p_commit             IN VARCHAR2 := FND_API.G_FALSE,
       p_pc_all_obj         IN fpa_pc_all_obj,
       x_return_status      OUT NOCOPY VARCHAR2,
       x_msg_data           OUT NOCOPY VARCHAR2,
       x_msg_count          OUT NOCOPY NUMBER )
IS
l_pc_info fpa_pc_info_obj;
BEGIN
    -- clear all previous messages.
        FND_MSG_PUB.Initialize;

    IF FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
        FND_LOG.String
        (
            FND_LOG.LEVEL_PROCEDURE,
            'fpa.sql.FPA_Process_Pvt.Update_Pc.begin',
            'Entering FPA_Process_Pvt.Update_Pc'
        );
    END IF;

    IF FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
        FND_LOG.String
        (
            FND_LOG.LEVEL_PROCEDURE,
            'fpa.sql.FPA_Process_Pvt.Update_Pc',
            'Initializing l_pc_info with p_pc_all_obj.pc_info'
        );
    END IF;

    -- Initialize local pcInfo object from the input pc_all object
    l_pc_info := p_pc_all_obj.pc_info;

    IF FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
        FND_LOG.String
        (
            FND_LOG.LEVEL_PROCEDURE,
            'fpa.sql.FPA_Process_Pvt.Update_Pc',
            'Calling Fpa_Utilities_Pvt.attach_AW'
        );
    END IF;

    -- Attach AW Workspace
     Fpa_Utilities_Pvt.attach_AW
                        (
                          p_api_version => 1.0,
                          p_attach_mode => 'rw',
                          x_return_status => x_return_status,
                          x_msg_count => x_msg_count,
                          x_msg_data => x_msg_data
                        );

    IF p_pc_all_obj.pc_desc_fields IS NOT NULL THEN

      IF FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
        FND_LOG.String
        (
            FND_LOG.LEVEL_PROCEDURE,
            'fpa.sql.FPA_Process_Pvt.Update_Pc',
            'Calling FPA_PlanningCycle_Pvt.Update_Pc_Desc_Fields'
        );
      END IF;
      FPA_PlanningCycle_Pvt.Update_Pc_Desc_Fields
            (
                p_api_version => 1.0,
                p_pc_all_obj => p_pc_all_obj,
                x_return_status  =>  x_return_status,
                x_msg_data  =>  x_msg_data,
                x_msg_count =>  x_msg_count
            );
    END IF;

    IF p_pc_all_obj.pc_investmix IS NOT NULL THEN

      IF FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
        FND_LOG.String
        (
            FND_LOG.LEVEL_PROCEDURE,
            'fpa.sql.FPA_Process_Pvt.Update_Pc',
            'Calling FPA_PlanningCycle_Pvt.Update_Pc_Invest_Mix'
        );
      END IF;
      FPA_PlanningCycle_Pvt.Update_Pc_Invest_Mix
             (
                p_api_version => 1.0,
                p_inv_matrix  => p_pc_all_obj.pc_investmix,
                x_return_status  =>  x_return_status,
                x_msg_data   =>  x_msg_data,
                x_msg_count  =>  x_msg_count
              );
    END IF;

    IF p_pc_all_obj.pc_info IS NOT NULL THEN
      IF p_pc_all_obj.pc_info.pc_category IS NOT NULL THEN

      IF FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
        FND_LOG.String
        (
            FND_LOG.LEVEL_PROCEDURE,
            'fpa.sql.FPA_Process_Pvt.Update_Pc',
            'Calling FPA_PlanningCycle_Pvt.Update_Pc_Class_Category'
        );
      END IF;
      FPA_PlanningCycle_Pvt.Update_Pc_Class_Category
             (
                p_api_version => 1.0,
                p_pc_id  => p_pc_all_obj.pc_info.planning_cycle,
                p_catg_id => p_pc_all_obj.pc_info.pc_category,
                x_return_status  =>  x_return_status,
                x_msg_data   =>  x_msg_data,
                x_msg_count  =>  x_msg_count
              );

      IF FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
        FND_LOG.String
        (
            FND_LOG.LEVEL_PROCEDURE,
            'fpa.sql.FPA_Process_Pvt.Update_Pc',
            'Calling FPA_PlanningCycle_Pvt.Update_Pc_Calendar'
        );
      END IF;
      FPA_PlanningCycle_Pvt.Update_Pc_Calendar
          (
                p_api_version => 1.0,
                p_pc_info  => l_pc_info,
                x_return_status  =>  x_return_status,
                x_msg_data   =>  x_msg_data,
                x_msg_count  =>  x_msg_count
           );

      IF FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
        FND_LOG.String
        (
            FND_LOG.LEVEL_PROCEDURE,
            'fpa.sql.FPA_Process_Pvt.Update_Pc',
            'Calling FPA_PlanningCycle_Pvt.Update_Pc_Currency'
        );
      END IF;
      FPA_PlanningCycle_Pvt.Update_Pc_Currency
             (
                p_api_version => 1.0,
                p_pc_info  =>  l_pc_info,
                x_return_status  =>  x_return_status,
                x_msg_data   =>  x_msg_data,
                x_msg_count  =>  x_msg_count
              );
    END IF;
        IF l_pc_info.submission_due_date IS NOT NULL THEN

          IF FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
            FND_LOG.String
            (
            FND_LOG.LEVEL_PROCEDURE,
            'fpa.sql.FPA_Process_Pvt.Update_Pc',
            'Calling FPA_PlanningCycle_Pvt.Update_Pc_Sub_Due_Date'
            );
          END IF;
          FPA_PlanningCycle_Pvt.Update_Pc_Sub_Due_Date
             (
                p_api_version => 1.0,
                p_pc_info  =>  l_pc_info,
                x_return_status  =>  x_return_status,
                x_msg_data   =>  x_msg_data,
                x_msg_count  =>  x_msg_count
              );
       END IF;

    END IF;

    IF p_pc_all_obj.pc_discount IS NOT NULL THEN
          IF FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
            FND_LOG.String
            (
            FND_LOG.LEVEL_PROCEDURE,
            'fpa.sql.FPA_Process_Pvt.Update_Pc',
            'Calling FPA_PlanningCycle_Pvt.Update_Pc_Discount_funds'
            );
          END IF;
          FPA_PlanningCycle_Pvt.Update_Pc_Discount_funds
               (
                p_api_version => 1.0,
                p_disc_funds  => p_pc_all_obj.pc_discount,
                x_return_status  =>  x_return_status,
                x_msg_data   =>  x_msg_data,
                x_msg_count  =>  x_msg_count
              );
    END IF;

    IF p_pc_all_obj.pc_targets IS NOT NULL THEN

          IF FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
            FND_LOG.String
            (
            FND_LOG.LEVEL_PROCEDURE,
            'fpa.sql.FPA_Process_Pvt.Update_Pc',
            'Calling FPA_PlanningCycle_Pvt.Update_Pc_Fin_Targets'
            );
          END IF;
          FPA_PlanningCycle_Pvt.Update_Pc_Fin_Targets
               (
                p_api_version => 1.0,
                p_fin_targets_tbl  => p_pc_all_obj.pc_targets,
                x_return_status  =>  x_return_status,
                x_msg_data   =>  x_msg_data,
                x_msg_count  =>  x_msg_count
              );
    END IF;

    IF p_pc_all_obj.pc_invest_criteria IS NOT NULL THEN

          IF FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
            FND_LOG.String
            (
            FND_LOG.LEVEL_PROCEDURE,
            'fpa.sql.FPA_Process_Pvt.Update_Pc',
            'Calling FPA_PlanningCycle_Pvt.Update_Pc_Inv_Criteria_Data'
            );
          END IF;

          FPA_PlanningCycle_Pvt.Update_Pc_Inv_Criteria_Data
               (
                p_api_version => 1.0,
                p_inv_crit_tbl  => p_pc_all_obj.pc_invest_criteria,
                x_return_status  =>  x_return_status,
                x_msg_data   =>  x_msg_data,
                x_msg_count  =>  x_msg_count
              );
    END IF;


    IF p_pc_all_obj.distr_list_items IS NOT NULL THEN

          IF FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
            FND_LOG.String
            (
            FND_LOG.LEVEL_PROCEDURE,
            'fpa.sql.FPA_Process_Pvt.Update_Pc',
            'Calling FPA_PlanningCycle_Pvt.Pa_Dist_List_Items_Update_Row'
            );
          END IF;
        FPA_PlanningCycle_Pvt.Pa_Dist_List_Items_Update_Row
              (
                p_api_version => 1.0,
                p_distr_list_items_tbl =>  p_pc_all_obj.distr_list_items,
                x_return_status  =>  x_return_status,
                x_msg_data   =>  x_msg_data,
                x_msg_count  =>  x_msg_count
              );
    END IF;


     -- Update and commit our changes
     IF (p_commit = FND_API.G_TRUE) THEN
         IF FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
           FND_LOG.String
           (
           FND_LOG.LEVEL_PROCEDURE,
           'fpa.sql.FPA_Process_Pvt.Update_Pc',
           'Updating AW and committing database.'
           );
         END IF;
         dbms_aw.execute('UPDATE');
         COMMIT;
     END IF;

     -- Detach AW Workspace
     IF FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
       FND_LOG.String
       (
        FND_LOG.LEVEL_PROCEDURE,
       'fpa.sql.FPA_Process_Pvt.Update_Pc',
       'Calling Fpa_Utilities_Pvt.detach_AW.'
       );
     END IF;

     Fpa_Utilities_Pvt.detach_AW
                        (
                          p_api_version => 1.0,
                          x_return_status => x_return_status,
                          x_msg_count => x_msg_count,
                          x_msg_data => x_msg_data
                        );

     IF FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
        FND_LOG.String
        (
            FND_LOG.LEVEL_PROCEDURE,
            'fpa.sql.FPA_Process_Pvt.Update_Pc.end',
            'Exiting FPA_Process_Pvt.Update_Pc'
        );
     END IF;


EXCEPTION
    WHEN OTHERS THEN
        FND_MESSAGE.SET_NAME('FPA','FPA_UNEXP_GENERAL_ERROR');
        FND_MESSAGE.SET_TOKEN('SOURCE', 'fpa.sql.FPA_Process_Pvt.Update_Pc');
        FND_MESSAGE.SET_TOKEN('SQL_ERR_CODE', SQLCODE);
        FND_MESSAGE.SET_TOKEN('SQL_ERR_MSG', SQLERRM);
        FND_MSG_PUB.ADD;
        ROLLBACK;
       -- Detach AW Workspace
       Fpa_Utilities_Pvt.detach_AW
                        (
                          p_api_version => 1.0,
                          x_return_status => x_return_status,
                          x_msg_count => x_msg_count,
                          x_msg_data => x_msg_data
                        );

        x_return_status := FND_API.G_RET_STS_ERROR;

        IF FND_LOG.LEVEL_ERROR >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
        FND_LOG.String
        (
            FND_LOG.LEVEL_ERROR,
            'fpa.sql.FPA_Process_Pvt.Update_Pc',
            SQLERRM
        );
        END IF;

        FND_MSG_PUB.count_and_get
        (
            p_count    =>      x_msg_count,
            p_data     =>      x_msg_data
        );
       -- RAISE;
END Update_Pc;

/*
 * Sets the Initiate Process in Planning Cycle(PC).
 */

PROCEDURE Set_Pc_Initiate
     ( p_api_version        IN NUMBER,
       p_commit             IN VARCHAR2 := FND_API.G_FALSE,
       p_pc_id              IN NUMBER,
       p_pc_name            IN VARCHAR2,
       p_pc_desc            IN VARCHAR2,
       p_sub_due_date       IN DATE,
       x_return_status      OUT NOCOPY VARCHAR2,
       x_msg_data           OUT NOCOPY VARCHAR2,
       x_msg_count          OUT NOCOPY NUMBER )
IS
l_cal_name VARCHAR2(80);
l_period_type VARCHAR2(80);
l_cal_period_type VARCHAR2(60);

l_last_pc_id       NUMBER;

CURSOR c_last_pc_id IS
SELECT prevPC.planning_cycle
  FROM FPA_AW_PC_INFO_V prevPC,
       FPA_AW_PC_INFO_V currPC
 WHERE prevPC.portfolio = currPC.portfolio
   AND currPC.planning_cycle = p_pc_id
   AND prevPC.last_flag =  1;

BEGIN

    IF FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
        FND_LOG.String
        (
            FND_LOG.LEVEL_PROCEDURE,
            'fpa.sql.FPA_Process_Pvt.Set_Pc_Initiate.begin',
            'Entering FPA_Process_Pvt.Set_Pc_Initiate'
        );
    END IF;

    OPEN  c_last_pc_id;
    FETCH c_last_pc_id INTO l_last_pc_id ;
    CLOSE c_last_pc_id;

    IF FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
        FND_LOG.String
        (
            FND_LOG.LEVEL_PROCEDURE,
            'fpa.sql.FPA_Process_Pvt.Set_Pc_Initiate.begin',
            'Value of l_last_pc_id ='||l_last_pc_id||', Calling Fpa_Utilities_Pvt.attach_AW'
        );
    END IF;
    -- Attach AW Workspace
     Fpa_Utilities_Pvt.attach_AW
                        (
                          p_api_version => 1.0,
                          p_attach_mode => 'rw',
                          x_return_status => x_return_status,
                          x_msg_count => x_msg_count,
                          x_msg_data => x_msg_data
                        );
     IF FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
                FND_LOG.String
                (
                        FND_LOG.LEVEL_PROCEDURE,
                        'fpa.sql.FPA_Process_Pvt.Set_Pc_Initiate',
                        'Executing query to retrieve Calendar information.'
                );
     END IF;

     SELECT CALENDAR_NAME , PERIOD_TYPE, CAL_PERIOD_TYPE
     INTO l_cal_name, l_period_type, l_cal_period_type
     FROM FPA_AW_PC_INFO_V
     WHERE PLANNING_CYCLE = p_pc_id;

     IF FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
                FND_LOG.String
                (
                        FND_LOG.LEVEL_PROCEDURE,
                        'fpa.sql.FPA_Process_Pvt.Set_Pc_Initiate',
                        'Calling fpa_utils_pvt.load_gl_calendar'
                );
     END IF;
     fpa_utils_pvt.load_gl_calendar
               (
                p_api_version     => 1.0,
                p_commit          => FND_API.G_TRUE,
                p_calendar_name   => l_cal_name,
                p_period_type     => l_period_type,
                p_cal_period_type => l_cal_period_type,
                x_return_status   =>  x_return_status,
                x_msg_data        =>  x_msg_data,
                x_msg_count       =>  x_msg_count
                );

     IF FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
                FND_LOG.String
                (
                        FND_LOG.LEVEL_PROCEDURE,
                        'fpa.sql.FPA_Process_Pvt.Set_Pc_Initiate',
                        'Calling fpa_planningcycle_pvt.Set_Pc_Initiate_Date.'
                );
     END IF;

      FPA_PlanningCycle_Pvt.Set_Pc_Initiate_Date
               (
                p_api_version => 1.0,
                p_pc_id => p_pc_id,
                x_return_status  =>  x_return_status,
                x_msg_data   =>  x_msg_data,
                x_msg_count  =>  x_msg_count
              );

     IF FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
                FND_LOG.String
                (
                        FND_LOG.LEVEL_PROCEDURE,
                        'fpa.sql.FPA_Process_Pvt.Set_Pc_Initiate.begin',
                        'Calling fpa_planningcycle_pvt.Set_Pc_Investment_Criteria.'
                );
     END IF;

      FPA_PlanningCycle_Pvt.Set_Pc_Investment_Criteria
      (
        p_api_version => 1.0,
        p_pc_id => p_pc_id,
        x_return_status  => x_return_status,
        x_msg_data => x_msg_data,
        x_msg_count => x_msg_count
      );


     IF FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
                FND_LOG.String
                (
                        FND_LOG.LEVEL_PROCEDURE,
                        'fpa.sql.FPA_Process_Pvt.Set_Pc_Initiate.begin',
                        'Calling FPA_PORTFOLIO_PROJECT_SETS_PVT.create_project_set'
                );
     END IF;

       FPA_PORTFOLIO_PROJECT_SETS_PVT.create_project_set
       (
         p_api_version    => 1.0,
         p_pc_id          => p_pc_id,
         x_return_status  => x_return_status,
         x_msg_data => x_msg_data,
         x_msg_count => x_msg_count
       );

     IF FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
                FND_LOG.String
                (
                        FND_LOG.LEVEL_PROCEDURE,
                        'fpa.sql.FPA_Process_Pvt.Set_Pc_Initiate.begin',
                        'Calling FPA_Main_Process_Pvt.Initiate_Workflow.'
                );
     END IF;

      FPA_Main_Process_Pvt.Initiate_Workflow
      (
        p_pc_name => p_pc_name,
        p_pc_id => p_pc_id,
    p_last_pc_id => l_last_pc_id ,
        p_pc_description => p_pc_desc,
        p_pc_date_initiated => SYSDATE,
        p_due_date => p_sub_due_date,
        x_return_status  => x_return_status,
        x_msg_data => x_msg_data,
        x_msg_count => x_msg_count
      );

     -- Update and commit our changes
     IF (p_commit = FND_API.G_TRUE) THEN
       IF FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
                  FND_LOG.String
                  (
                          FND_LOG.LEVEL_PROCEDURE,
                          'fpa.sql.FPA_Process_Pvt.Set_Pc_Initiate.begin',
                          'Updating AW and committing database.'
                  );
       END IF;
         dbms_aw.execute('UPDATE');
         COMMIT;
     END IF;

     IF FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
                FND_LOG.String
                (
                        FND_LOG.LEVEL_PROCEDURE,
                        'fpa.sql.FPA_Process_Pvt.Set_Pc_Initiate.begin',
                        'Calling Fpa_Utilities_Pvt.detach_AW'
                );
     END IF;
     -- Detach AW Workspace
     Fpa_Utilities_Pvt.detach_AW
                        (
                          p_api_version => 1.0,
                          x_return_status => x_return_status,
                          x_msg_count => x_msg_count,
                          x_msg_data => x_msg_data
                        );

     IF FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
        FND_LOG.String
        (
            FND_LOG.LEVEL_PROCEDURE,
            'fpa.sql.FPA_Process_Pvt.Set_Pc_Initiate.end',
            'Exiting FPA_Process_Pvt.Set_Pc_Initiate'
        );
     END IF;


EXCEPTION
    WHEN OTHERS THEN
        FND_MESSAGE.SET_NAME('FPA','FPA_UNEXP_GENERAL_ERROR');
        FND_MESSAGE.SET_TOKEN('SOURCE', 'fpa.sql.FPA_Process_Pvt.Set_Pc_Initiate');
        FND_MESSAGE.SET_TOKEN('SQL_ERR_CODE', SQLCODE);
        FND_MESSAGE.SET_TOKEN('SQL_ERR_MSG', SQLERRM);
        FND_MSG_PUB.ADD;
        ROLLBACK;
        -- Detach AW Workspace
        Fpa_Utilities_Pvt.detach_AW
                        (
                          p_api_version => 1.0,
                          x_return_status => x_return_status,
                          x_msg_count => x_msg_count,
                          x_msg_data => x_msg_data
                        );

        x_return_status := FND_API.G_RET_STS_ERROR;

        IF FND_LOG.LEVEL_ERROR >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
        FND_LOG.String
        (
            FND_LOG.LEVEL_ERROR,
            'fpa.sql.FPA_Process_Pvt.Set_Pc_Initiate',
            SQLERRM
        );
        END IF;

        FND_MSG_PUB.count_and_get
        (
            p_count    =>      x_msg_count,
            p_data     =>      x_msg_data
        );
        --RAISE;
END Set_Pc_Initiate;

/*
 * DELETES the User from Distribution list Subtab in Planning Cycle(PC).
 */

PROCEDURE Pa_Dist_List_Items_Delete_Row (
        p_api_version         IN NUMBER,
        p_commit              IN VARCHAR2 := FND_API.G_FALSE,
        P_LIST_ITEM_ID        IN NUMBER,
        x_return_status       OUT NOCOPY VARCHAR2,
        x_msg_data            OUT NOCOPY VARCHAR2,
        x_msg_count           OUT NOCOPY NUMBER )
IS
BEGIN
    IF FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
        FND_LOG.String
        (
            FND_LOG.LEVEL_PROCEDURE,
            'fpa.sql.FPA_Process_Pvt.Pa_Dist_List_Items_Update_Row.begin',
            'Entering FPA_Process_Pvt.Pa_Dist_List_Items_Update_Row'
        );
    END IF;


     PA_DIST_LIST_ITEMS_PKG.Delete_Row
            (
                P_LIST_ITEM_ID  => P_LIST_ITEM_ID
            );

     -- Update and commit our changes
     IF (p_commit = FND_API.G_TRUE) THEN
         COMMIT;
     END IF;


     IF FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
        FND_LOG.String
        (
            FND_LOG.LEVEL_PROCEDURE,
            'fpa.sql.FPA_Process_Pvt.Pa_Dist_List_Items_Update_Row.end',
            'Exiting FPA_Process_Pvt.Pa_Dist_List_Items_Update_Row'
        );
     END IF;


EXCEPTION
    WHEN OTHERS THEN
        FND_MESSAGE.SET_NAME('FPA','FPA_UNEXP_GENERAL_ERROR');
        FND_MESSAGE.SET_TOKEN('SOURCE', 'fpa.sql.FPA_Process_Pvt.Pa_Dist_List_Items_Update_Row');
        FND_MESSAGE.SET_TOKEN('SQL_ERR_CODE', SQLCODE);
        FND_MESSAGE.SET_TOKEN('SQL_ERR_MSG', SQLERRM);
        FND_MSG_PUB.ADD;
        ROLLBACK;

        x_return_status := FND_API.G_RET_STS_ERROR;

        IF FND_LOG.LEVEL_ERROR >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
        FND_LOG.String
        (
            FND_LOG.LEVEL_ERROR,
            'fpa.sql.FPA_Process_Pvt.Pa_Dist_List_Items_Update_Row',
            SQLERRM
        );
        END IF;

        FND_MSG_PUB.count_and_get
        (
            p_count    =>      x_msg_count,
            p_data     =>      x_msg_data
        );
        --RAISE;

END Pa_Dist_List_Items_Delete_Row;


/************************************************************************************/
-- PORTFOLIO PROCEDURES
/************************************************************************************/

PROCEDURE Create_Portfolio
     (
        p_api_version       IN      NUMBER,
        p_commit            IN      VARCHAR2 := FND_API.G_FALSE,
        p_portfolio_obj     IN  FPA_PORTFO_ALL_OBJ,
        x_portfolio_id      OUT NOCOPY  VARCHAR2,
        x_return_status     OUT NOCOPY  VARCHAR2,
        x_msg_data          OUT NOCOPY  VARCHAR2,
        x_msg_count         OUT NOCOPY  NUMBER
    )
IS
l_default_portf_user_tbl FPA_PORTFOLIO_USERS_TBL;
 l_msg_log                VARCHAR2(2000) := null;
BEGIN

         -- clear all previous messages.
        FND_MSG_PUB.Initialize;

         IF FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
        fnd_log.string
        (
            FND_LOG.LEVEL_PROCEDURE,
            'fpa.sql.fpa_process_pvt.create_portfolio.begin',
            'Entering fpa_process_pvt.create_portfolio'
        );
        END IF;
         Copy_Portfolio(p_portfolio_obj);



        -- CHeck for DUPLICATE portfolio name
         IF FPA_Portfolio_PVT.Check_Portfolio_name(p_api_version    ,
                                 NULL,
                                 portfolio_rec.portfolio_name,
                                 x_return_status,
                                 x_msg_data,
                                 x_msg_count) > 0 THEN

               FND_MESSAGE.SET_NAME('FPA','FPA_DUP_PORTF_NAME');
               FND_MESSAGE.SET_TOKEN('PORTF_NAME',portfolio_rec.portfolio_name);

                FND_MSG_PUB.ADD;
               IF FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
                  fnd_log.string
                  (
                    FND_LOG.LEVEL_PROCEDURE,
                    'fpa.sql.fpa_process_pvt.create_portfolio',
                    'Duplicate Portfolio Name'
                  );
                END IF;
            --RAISE  known exception
            RAISE FND_API.G_EXC_ERROR;
         END IF;


          -- Attach the AW space read write.
          IF FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
            fnd_log.string
            (
                FND_LOG.LEVEL_STATEMENT,
                'fpa.sql.fpa_process_pvt.create_portfolio',
                'Attaching OLAP workspace: '
            );
          END IF;
             Fpa_Utilities_Pvt.attach_AW
                        (
                          p_api_version => 1.0,
                          p_attach_mode => 'rw',
                          x_return_status => x_return_status,
                          x_msg_count => x_msg_count,
                          x_msg_data => x_msg_data
                        );


            -- Create portfolio
            FPA_Portfolio_PVT.Create_Portfolio
                                    (
                                       p_api_version,
                                       portfolio_rec,
                                       x_portfolio_id,
                                       x_return_status,
                                       x_msg_data,
                                       x_msg_count
                                   );
            -- Assign the portfolio ID that will be used by the newly created
            -- portfolio users
           portfolio_rec.portfolio_id := x_portfolio_id;


            --create/update the portfolio USERS access list

                l_default_portf_user_tbl:= FPA_PORTFOLIO_USERS_TBL();
                l_default_portf_user_tbl:= FPA_PORTFOLIO_USERS_TBL(FPA_PORTFOLIO_USERS_OBJ(null,
                                                                portfolio_rec.portfolio_id,
                                                                portfolio_rec.Portfolio_owner_id,
                                                                FPA_SECURITY_PVT.Get_Role_Id,sysdate,NULL));

                -- Create the default portfolio user
                  --Since each portfolio owner is also a security user
                  -- so that usre need to created.

                create_update_access_list
                ( l_default_portf_user_tbl,
                     portfolio_rec.portfolio_id,
                    x_return_status ,
                    x_msg_data,
                   x_msg_count

                );

              if (x_return_status = FPA_UTILITIES_PVT.G_RET_STS_UNEXP_ERROR
                  or x_return_status = FPA_UTILITIES_PVT.G_RET_STS_ERROR) then
                      l_msg_log := portfolio_rec.portfolio_id;
                      raise  FPA_UTILITIES_PVT.G_EXCEPTION_ERROR;
              end if;

              IF p_portfolio_obj.portfolio_users IS NOT NULL then
                     -- Create or update the access list users
                    create_update_access_list
                    ( p_portfolio_obj.portfolio_users,
                        portfolio_rec.portfolio_id,
                       x_return_status  ,
                       x_msg_data,
                       x_msg_count
                    );

                  if (x_return_status = FPA_UTILITIES_PVT.G_RET_STS_UNEXP_ERROR
                      or x_return_status = FPA_UTILITIES_PVT.G_RET_STS_ERROR) then
                          l_msg_log := portfolio_rec.portfolio_id;
                          raise  FPA_UTILITIES_PVT.G_EXCEPTION_ERROR;
                  end if;

              END IF;

        --Update and commit our changes
        IF (p_commit = FND_API.G_TRUE)  THEN
            dbms_aw.execute('UPDATE');
            COMMIT;
        END IF;


        -- Finally, detach the workspace
        IF FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
            fnd_log.string
            (
                FND_LOG.LEVEL_STATEMENT,
                'fpa.sql.fpa_process_pvt.create_portfolio',
                'Detaching OLAP workspace: '
            );
         END IF;
        -- Detach AW Workspace
        Fpa_Utilities_Pvt.detach_AW
                        (
                          p_api_version => 1.0,
                          x_return_status => x_return_status,
                          x_msg_count => x_msg_count,
                          x_msg_data => x_msg_data
                        );

        IF FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
        fnd_log.string
        (
            FND_LOG.LEVEL_PROCEDURE,
            'fpa.sql.fpa_process_pvt.create_portfolio.end',
            'Exiting fpa_process_pvt.create_portfolio'
        );
       END IF;

    EXCEPTION
     WHEN FPA_UTILITIES_PVT.G_EXCEPTION_ERROR THEN

        ROLLBACK;

        x_return_status := FND_API.G_RET_STS_ERROR;
        IF FND_LOG.LEVEL_ERROR >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
        fnd_log.string
        (
            FND_LOG.LEVEL_ERROR,
            'fpa_process_pvt.create_portfolio, FPA_UTILITIES_PVT.G_EXCEPTION_ERROR '||l_msg_log,
            SQLERRM
        );
        END IF;

        FND_MSG_PUB.Count_And_Get( p_count  =>      x_msg_count
                              ,p_data   =>      x_msg_data);

     WHEN FND_API.G_EXC_ERROR THEN

        ROLLBACK;

        x_return_status := FND_API.G_RET_STS_ERROR;
        IF FND_LOG.LEVEL_ERROR >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
        fnd_log.string
        (
            FND_LOG.LEVEL_ERROR,
            'fpa_process_pvt.create_portfolio',
            SQLERRM
        );
        END IF;

        FND_MSG_PUB.Count_And_Get( p_count  =>      x_msg_count
                              ,p_data   =>      x_msg_data);

    WHEN OTHERS THEN
        FND_MESSAGE.SET_NAME('FPA','FPA_UNEXP_GENERAL_ERROR');
        FND_MESSAGE.SET_TOKEN('SOURCE', 'fpa_process_pvt.create_portfolio');
        FND_MESSAGE.SET_TOKEN('SQL_ERR_CODE', SQLCODE);
        FND_MESSAGE.SET_TOKEN('SQL_ERR_MSG', SQLERRM);
        FND_MSG_PUB.ADD;
     -- Detach AW Workspace
       Fpa_Utilities_Pvt.detach_AW
                        (
                          p_api_version => 1.0,
                          x_return_status => x_return_status,
                          x_msg_count => x_msg_count,
                          x_msg_data => x_msg_data
                        );

        ROLLBACK;
        x_return_status := FND_API.G_RET_STS_ERROR;

        IF FND_LOG.LEVEL_ERROR >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
        fnd_log.string
        (
            FND_LOG.LEVEL_ERROR,
            'fpa_process_pvt.create_portfolio',
            SQLERRM
        );
        END IF;

        FND_MSG_PUB.count_and_get
        (
            p_count    =>      x_msg_count,
            p_data     =>      x_msg_data
        );

END;

/************************************************************************************
************************************************************************************/
-- The procedure Delete_Portfolio removes the portfolio from aw and Tl table

    PROCEDURE Delete_Portfolio
     (
       p_api_version        IN          NUMBER,
       p_commit            IN           VARCHAR2 := FND_API.G_FALSE,
       p_portfolio_id       IN          NUMBER,
       x_return_status      OUT NOCOPY  VARCHAR2,
       x_msg_data           OUT NOCOPY  VARCHAR2,
       x_msg_count          OUT NOCOPY  NUMBER
    )
IS
BEGIN
        IF FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
        fnd_log.string
        (
            FND_LOG.LEVEL_PROCEDURE,
            'fpa_process_pvt.Delete_Portfolio.begin',
            'Entering fpa_process_pvt.Delete_Portfolio'
        );
        END IF;
        -- Attach the AW space read write.
        IF FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
            fnd_log.string
            (
                FND_LOG.LEVEL_STATEMENT,
                'fpa.sql.fpa_process_pvt.Delete_Portfolio',
                'Attaching OLAP workspace: '
            );
         END IF;
         Fpa_Utilities_Pvt.attach_AW
                        (
                          p_api_version => 1.0,
                          p_attach_mode => 'rw',
                          x_return_status => x_return_status,
                          x_msg_count => x_msg_count,
                          x_msg_data => x_msg_data
                         );



        -- Delete the portfolio
        FPA_Portfolio_PVT.Delete_Portfolio
                        (
                            p_api_version   => p_api_version,
                            p_portfolio_id  => p_portfolio_id  ,
                            x_return_status => x_return_status,
                            x_msg_data      => x_msg_data,
                            x_msg_count     =>x_msg_count
                        );


        --Update and commit our changes
        IF (p_commit = FND_API.G_TRUE)  THEN
            dbms_aw.execute('UPDATE');
            COMMIT;
        END IF;

        -- Finally, detach the workspace
        IF FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
            fnd_log.string
            (
                FND_LOG.LEVEL_STATEMENT,
                'fpa.sql.fpa_process_pvt.Delete_Portfolio',
                'Detaching OLAP workspace: '
            );
         END IF;
        -- Detach AW Workspace
        Fpa_Utilities_Pvt.detach_AW
                        (
                          p_api_version => 1.0,
                          x_return_status => x_return_status,
                          x_msg_count => x_msg_count,
                          x_msg_data => x_msg_data
                        );

        IF FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
        fnd_log.string
        (
            FND_LOG.LEVEL_PROCEDURE,
            'fpa.sql.fpa_process_pvt.Delete_Portfolio.end',
            'Exiting fpa_process_pvt.Delete_Portfolio'
        );
       END IF;

EXCEPTION

    WHEN OTHERS THEN
        -- Detach AW Workspace
        FND_MESSAGE.SET_NAME('FPA','FPA_UNEXP_GENERAL_ERROR');
        FND_MESSAGE.SET_TOKEN('SOURCE', 'fpa_process_pvt.Delete_Portfolio');
        FND_MESSAGE.SET_TOKEN('SQL_ERR_CODE', SQLCODE);
        FND_MESSAGE.SET_TOKEN('SQL_ERR_MSG', SQLERRM);
        FND_MSG_PUB.ADD;
     -- Detach AW Workspace
       Fpa_Utilities_Pvt.detach_AW
                        (
                          p_api_version => 1.0,
                          x_return_status => x_return_status,
                          x_msg_count => x_msg_count,
                          x_msg_data => x_msg_data
                        );

        ROLLBACK;
        x_return_status := FND_API.G_RET_STS_ERROR;

        IF FND_LOG.LEVEL_ERROR >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
        fnd_log.string
        (
            FND_LOG.LEVEL_ERROR,
            'fpa_process_pvt.Delete_Portfolio',
            SQLERRM
        );
        END IF;

        FND_MSG_PUB.count_and_get
        (
            p_count    =>      x_msg_count,
            p_data     =>      x_msg_data
        );


END Delete_Portfolio;




/************************************************************************************
************************************************************************************/
-- The procedure update_Portfolio update the portfolio obhject measures
-- in th AW and the table level

PROCEDURE Update_Portfolio
     (
        p_api_version       IN      NUMBER,
        p_commit            IN      VARCHAR2 := FND_API.G_FALSE,
        p_portfolio_obj     IN  FPA_PORTFO_ALL_OBJ,
        x_return_status     OUT NOCOPY  VARCHAR2,
        x_msg_data          OUT NOCOPY  VARCHAR2,
        x_msg_count         OUT NOCOPY  NUMBER
    )

IS
BEGIN
    -- clear all previous messages.
        FND_MSG_PUB.Initialize;

      IF FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
        fnd_log.string
        (
            FND_LOG.LEVEL_PROCEDURE,
            'fpa.sql.fpa_process_pvt.update_portfolio.begin',
            'Entering fpa_process_pvt.update_portfolio'
        );
        END IF;

        --copy input object to the record type
         Copy_Portfolio(p_portfolio_obj);

            -- CHeck for DUPLICATE portfolio name
             IF FPA_Portfolio_PVT.Check_Portfolio_name(p_api_version    ,
                                 portfolio_rec.portfolio_id,
                                 portfolio_rec.portfolio_name,
                                 x_return_status,
                                 x_msg_data,
                                 x_msg_count) > 0 THEN

               FND_MESSAGE.SET_NAME('FPA','FPA_DUP_PORTF_NAME');
               FND_MESSAGE.SET_TOKEN('PORTF_NAME',portfolio_rec.portfolio_name);
                FND_MSG_PUB.ADD;

               IF FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
                  fnd_log.string
                  (
                    FND_LOG.LEVEL_PROCEDURE,
                    'fpa.sql.fpa_process_pvt.update_portfolio',
                    'Duplicate Portfolio Name'
                  );
                END IF;
            --raise the  known duplicate exception
            RAISE FND_API.G_EXC_ERROR;
         END IF;


          -- Attach the AW space read write.
          IF FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
            fnd_log.string
            (
                FND_LOG.LEVEL_STATEMENT,
                'fpa.sql.fpa_process_pvt.update_portfolio',
                'Attaching OLAP workspace: '
            );
          END IF;
             Fpa_Utilities_Pvt.attach_AW
                        (
                          p_api_version => 1.0,
                          p_attach_mode => 'rw',
                          x_return_status => x_return_status,
                          x_msg_count => x_msg_count,
                          x_msg_data => x_msg_data
                        );


        --update portfolio name description
         FPA_Portfolio_PVT.Upadate_Portfolio_Descr
            (
               p_api_version,
               portfolio_rec,
               x_return_status,
               x_msg_data,
               x_msg_count
           );
       --update portfolio type
        FPA_Portfolio_PVT.Upadate_Portfolio_type
        (
        p_api_version,
        portfolio_rec.portfolio_id ,
        portfolio_rec.portfolio_type    ,
        x_return_status,
        x_msg_data,
        x_msg_count
        );

       --update portfolio organization
       FPA_Portfolio_PVT.Upadate_Portfolio_organization
        (
        p_api_version,
        portfolio_rec.portfolio_id ,
        portfolio_rec.Portfolio_start_org_id ,
        x_return_status ,
        x_msg_data,
        x_msg_count
        );

        -- Update the portfolio onwer user

         FPA_SECURITY_PVT.update_portfolio_owner
         (
          p_api_version => p_api_version,
          p_init_msg_list =>  'F',
          p_portfolio_id => portfolio_rec.portfolio_id,
          p_person_id  =>  portfolio_rec.Portfolio_owner_id,
          x_return_status =>      x_return_status,
          x_msg_count =>          x_msg_count,
          x_msg_data =>           x_msg_data
          );

       IF p_portfolio_obj.portfolio_users IS NOT NULL then
        --create/update the access list
             create_update_access_list
                (   p_portfolio_obj.portfolio_users,
                     portfolio_rec.portfolio_id,
                    x_return_status ,
                    x_msg_data,
                   x_msg_count

            );
    END IF ;

        --Update and commit our changes
        IF (p_commit = FND_API.G_TRUE) THEN
            dbms_aw.execute('UPDATE');
            COMMIT;
        END IF;

        -- Finally, detach the workspace
        IF FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
            fnd_log.string
            (
                FND_LOG.LEVEL_STATEMENT,
                'fpa.sql.fpa_process_pvt.create_portfolio',
                'Detaching OLAP workspace: '
            );
         END IF;
        -- Detach AW Workspace
        Fpa_Utilities_Pvt.detach_AW
                        (
                          p_api_version => 1.0,
                          x_return_status => x_return_status,
                          x_msg_count => x_msg_count,
                          x_msg_data => x_msg_data
                        );

        IF FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
        fnd_log.string
        (
            FND_LOG.LEVEL_PROCEDURE,
            'fpa.sql.fpa_process_pvt.create_portfolio.end',
            'Exiting fpa_process_pvt.create_portfolio'
        );
       END IF;

EXCEPTION
     WHEN FND_API.G_EXC_ERROR THEN
        ROLLBACK;


        x_return_status := FND_API.G_RET_STS_ERROR;
        IF FND_LOG.LEVEL_ERROR >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
        fnd_log.string
        (
            FND_LOG.LEVEL_ERROR,
            'fpa_process_pvt.create_portfolio',
            SQLERRM
        );
        END IF;

        FND_MSG_PUB.Count_And_Get( p_count  =>      x_msg_count
                                   ,p_data   =>      x_msg_data);

        RAISE;

    WHEN OTHERS THEN
        -- Detach AW Workspace
        FND_MESSAGE.SET_NAME('FPA','FPA_UNEXP_GENERAL_ERROR');
        FND_MESSAGE.SET_TOKEN('SOURCE', 'fpa_process_pvt.update_portfolio');
        FND_MESSAGE.SET_TOKEN('SQL_ERR_CODE', SQLCODE);
        FND_MESSAGE.SET_TOKEN('SQL_ERR_MSG', SQLERRM);
        FND_MSG_PUB.ADD;
     -- Detach AW Workspace
       Fpa_Utilities_Pvt.detach_AW
                        (
                          p_api_version => 1.0,
                          x_return_status => x_return_status,
                          x_msg_count => x_msg_count,
                          x_msg_data => x_msg_data
                        );

        ROLLBACK;
        x_return_status := FND_API.G_RET_STS_ERROR;

        IF FND_LOG.LEVEL_ERROR >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
        fnd_log.string
        (
            FND_LOG.LEVEL_ERROR,
            'fpa_process_pvt.update_portfolio',
            SQLERRM
        );
        END IF;

        FND_MSG_PUB.count_and_get
        (
            p_count    =>      x_msg_count,
            p_data     =>      x_msg_data
        );



END;

/************************************************************************************
************************************************************************************/
-- The procedure delete_portfolio_user delets teh portfolio access list user
--  The procedure calls the Fpa security package to delete a user.

    PROCEDURE delete_Portfolio_user
     (
        p_api_version       IN      NUMBER,
        p_commit            IN      VARCHAR2 := FND_API.G_FALSE,
        p_project_party_id  IN      NUMBER,
        x_return_status     OUT NOCOPY  VARCHAR2,
        x_msg_data          OUT NOCOPY  VARCHAR2,
        x_msg_count         OUT NOCOPY  NUMBER
    ) IS
    BEGIN

      IF FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
        fnd_log.string
        (
            FND_LOG.LEVEL_PROCEDURE,
            'fpa.sql.fpa_process_pvt.delete_portfolio_user.begin',
            'Entering fpa_process_pvt.delete_portfolio_user'
        );
        END IF;


      FPA_SECURITY_PVT.Delete_Portfolio_User
            (
                p_api_version => 1,
                p_init_msg_list =>     'F',
                p_portfolio_party_id => p_project_party_id,
                p_instance_set_name=>   'PJP_PORTFOLIO_SET',
                x_return_status =>      x_return_status,
                x_msg_count =>          x_msg_count,
                x_msg_data =>           x_msg_data
            );

      IF FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
        fnd_log.string
        (
            FND_LOG.LEVEL_PROCEDURE,
            'fpa.sql.fpa_process_pvt.delete_portfolio_user.end',
            'Exiting fpa_process_pvt.delete_portfolio_user'
        );
        END IF;
        IF x_return_status <> 'S' THEN
           BEGIN
            x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
             FND_MSG_PUB.count_and_get
              (
                  p_count    =>      x_msg_count,
                  p_data     =>      x_msg_data
               );
                RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
            END;
        END IF;

    EXCEPTION
    WHEN OTHERS THEN
        FND_MESSAGE.SET_NAME('FPA','FPA_UNEXP_GENERAL_ERROR');
        FND_MESSAGE.SET_TOKEN('SOURCE', 'fpa_process_pvt.delete_Portfolio_user');
        FND_MESSAGE.SET_TOKEN('SQL_ERR_CODE', SQLCODE);
        FND_MESSAGE.SET_TOKEN('SQL_ERR_MSG', SQLERRM);
        FND_MSG_PUB.ADD;
     -- Detach AW Workspace
       Fpa_Utilities_Pvt.detach_AW
                        (
                          p_api_version => 1.0,
                          x_return_status => x_return_status,
                          x_msg_count => x_msg_count,
                          x_msg_data => x_msg_data
                        );

        ROLLBACK;
        x_return_status := FND_API.G_RET_STS_ERROR;
        IF FND_LOG.LEVEL_ERROR >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
        fnd_log.string
        (
            FND_LOG.LEVEL_ERROR,
            'fpa_process_pvt.delete_Portfolio_user',
            SQLERRM
        );
        END IF;

        FND_MSG_PUB.count_and_get
        (
            p_count    =>      x_msg_count,
            p_data     =>      x_msg_data
        );

    END;
/************************************************************************************
************************************************************************************/
--Procedure to copy the data from Object fields into the
-- portfolio_rec to record
-- This procedure is used locally by the package procedure.

PROCEDURE Copy_Portfolio(p_portfolio_obj IN  FPA_PORTFO_ALL_OBJ)
IS
    BEGIN

        portfolio_rec.portfolio_id :=p_portfolio_obj.portf_desc_fields.id;
        portfolio_rec.portfolio_name:=p_portfolio_obj.portf_desc_fields.name;
        portfolio_rec.portfolio_desc:=p_portfolio_obj.portf_desc_fields.description;
        portfolio_rec.portfolio_owner_id:=p_portfolio_obj.portf_info.owner;
        portfolio_rec.portfolio_type:=p_portfolio_obj.portf_info.portfolio_class_code;
        portfolio_rec.portfolio_start_org_id:=p_portfolio_obj.portf_info.portfolio_organization;
    END;

/************************************************************************************
************************************************************************************/
-- The procedure create_update_access_list create or update the portfloio access list user.
--  The procedure calls the Fpa security package update/crete a user.

PROCEDURE create_update_access_list
     ( p_portf_users_tbl IN  FPA_PORTFOLIO_USERS_TBL,
       p_portfolio_id  NUMBER,
       x_return_status      OUT NOCOPY  VARCHAR2,
       x_msg_data           OUT NOCOPY  VARCHAR2,
       x_msg_count          OUT NOCOPY  NUMBER
    )
IS
l_project_party_id number;

 -- standard parameters
 l_return_status          VARCHAR2(1);
 l_api_name               CONSTANT VARCHAR2(30) := 'Create_Update_Access_List';
 l_api_version            CONSTANT NUMBER    := 1.0;
 l_msg_log                VARCHAR2(2000) := null;
 ----------------------------------------------------------------------------


BEGIN
 IF FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
        fnd_log.string
        (
            FND_LOG.LEVEL_PROCEDURE,
            'fpa.sql.fpa_process_pvt.create_update_access_list.begin',
            'Entering fpa_process_pvt.create_update_access_list'
        );
 END IF;

   x_return_status := FPA_UTILITIES_PVT.G_RET_STS_SUCCESS;

   x_return_status := FPA_UTILITIES_PVT.START_ACTIVITY(
                 p_api_name      => l_api_name,
                 p_pkg_name      => G_PKG_NAME,
                 p_init_msg_list => 'T',
                 l_api_version   => l_api_version,
                 p_api_version   => l_api_version,
                 p_api_type      => G_API_TYPE,
                 p_msg_log       => 'Entering fpa_process_pvt.create_update_access_list.begin',
                 x_return_status => x_return_status);

  -- check if activity started successfully
  if (x_return_status = FPA_UTILITIES_PVT.G_RET_STS_UNEXP_ERROR) then
     l_msg_log := 'start_activity';
     raise FPA_UTILITIES_PVT.G_EXCEPTION_UNEXPECTED_ERROR;
  elsif (x_return_status = FPA_UTILITIES_PVT.G_RET_STS_ERROR) then
     l_msg_log := 'start_activity';
     raise FPA_UTILITIES_PVT.G_EXCEPTION_ERROR;
  end if;


IF p_portf_users_tbl IS NOT NULL THEN

  FOR i IN p_portf_users_tbl.FIRST..p_portf_users_tbl.LAST
        LOOP
            BEGIN

                --Check if the record is for create or for update
                 IF p_portf_users_tbl(i).project_party_id IS NULL THEN
                   --Its a new users to be created

                    FPA_SECURITY_PVT.create_portfolio_user(
                                             p_api_version => 1,
                                             p_init_msg_list =>     'F',
                                             p_object_id    =>       p_portfolio_id ,
                                             p_project_role_id =>    p_portf_users_tbl(i).role_id,
                                             p_party_id =>           p_portf_users_tbl(i).hz_party_id,
                                             p_start_date_active =>  p_portf_users_tbl(i).start_Date,
                                             p_end_date_active =>    p_portf_users_tbl(i).end_Date,
                                             x_portfolio_party_id => l_project_party_id,
                                             x_return_status =>      x_return_status,
                                             x_msg_count =>          x_msg_count,
                                             x_msg_data =>           x_msg_data
                                            );



                 ELSE
                    -- Its a update requeste
                       FPA_SECURITY_PVT.update_portfolio_user(
                                             p_api_version => 1,
                                             p_init_msg_list =>     'F',
                                             p_portfolio_party_id  => p_portf_users_tbl(i).project_party_id,
                                             p_project_role_id =>    p_portf_users_tbl(i).role_id,
                                             p_start_date_active =>  p_portf_users_tbl(i).start_Date,
                                             p_end_date_active =>    p_portf_users_tbl(i).end_Date,
                                             x_return_status =>      x_return_status,
                                             x_msg_count =>          x_msg_count,
                                             x_msg_data =>           x_msg_data
                                           );

                END IF;

                if (x_return_status = FPA_UTILITIES_PVT.G_RET_STS_UNEXP_ERROR) then
                   l_msg_log := p_portf_users_tbl(i).project_party_id||','||p_portf_users_tbl(i).role_id;
                   raise FPA_UTILITIES_PVT.G_EXCEPTION_UNEXPECTED_ERROR;
                elsif (x_return_status = FPA_UTILITIES_PVT.G_RET_STS_ERROR) then
                   l_msg_log := p_portf_users_tbl(i).project_party_id||','||p_portf_users_tbl(i).role_id;
                   raise FPA_UTILITIES_PVT.G_EXCEPTION_ERROR;
                end if;

                /*
                    -- CHECK IF THE SECUCITY CALL IS SUCCESSFUL
                    IF x_return_status <> 'S' THEN
                    BEGIN
                     x_return_status := 'U';
                     FND_MSG_PUB.count_and_get
                        (
                        p_count    =>      x_msg_count,
                        p_data     =>      x_msg_data
                        );
                       RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
                    END;
                    END IF;
                 */
             END;
        END LOOP;

        IF FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
        fnd_log.string
        (
            FND_LOG.LEVEL_PROCEDURE,
            'fpa.sql.fpa_process_pvt.create_update_access_list.end',
            'Exiting fpa_process_pvt.create_update_access_list'
        );
        END IF;

END IF;

  FPA_UTILITIES_PVT.END_ACTIVITY(
                p_api_name     => l_api_name,
                p_pkg_name     => G_PKG_NAME,
                p_msg_log      => l_msg_log,
                x_msg_count    => x_msg_count,
                x_msg_data     => x_msg_data);

EXCEPTION
      when FPA_UTILITIES_PVT.G_EXCEPTION_ERROR then
         x_return_status := FPA_UTILITIES_PVT.HANDLE_EXCEPTIONS(
            p_api_name  => l_api_name,
            p_pkg_name  => G_PKG_NAME,
            p_exc_name  => 'FPA_UTILITIES_PVT.G_RET_STS_ERROR',
            p_msg_log   => l_msg_log,
            x_msg_count => x_msg_count,
            x_msg_data  => x_msg_data,
            p_api_type  => G_API_TYPE);

      when FPA_UTILITIES_PVT.G_EXCEPTION_UNEXPECTED_ERROR then
         x_return_status := FPA_UTILITIES_PVT.HANDLE_EXCEPTIONS(
            p_api_name  => l_api_name,
            p_pkg_name  => G_PKG_NAME,
            p_exc_name  => 'FPA_UTILITIES_PVT.G_RET_STS_UNEXP_ERROR',
            p_msg_log   => l_msg_log,
            x_msg_count => x_msg_count,
            x_msg_data  => x_msg_data,
            p_api_type  => G_API_TYPE);

      when OTHERS then
         x_return_status := FPA_UTILITIES_PVT.HANDLE_EXCEPTIONS(
            p_api_name  => l_api_name,
            p_pkg_name  => G_PKG_NAME,
            p_exc_name  => 'OTHERS',
            p_msg_log   => l_msg_log||SQLERRM,
            x_msg_count => x_msg_count,
            x_msg_data  => x_msg_data,
            p_api_type  => G_API_TYPE);

END;

/************************************************************************************/
-- COLLECT PROJECT PROCEDURES
/************************************************************************************/


  PROCEDURE Collect_Projects
     (  p_api_version           IN NUMBER,
        p_commit                IN VARCHAR2 := FND_API.G_FALSE,
        p_pc_id                 IN NUMBER,
        x_return_status         OUT NOCOPY VARCHAR2,
        x_msg_data              OUT NOCOPY VARCHAR2,
        x_msg_count             OUT NOCOPY NUMBER
     )
    IS

    l_pc_id                 NUMBER;
    l_api_version           NUMBER;

l_pc_name           VARCHAR2(80);
l_pc_description        VARCHAR2(240);
l_pc_date_initiated     DATE;
l_due_date          DATE;

   BEGIN

        FND_MSG_PUB.Initialize;

        IF FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
            FND_LOG.STRING
            (
                FND_LOG.LEVEL_PROCEDURE,
                'FPA.SQL.FPA_PROCESS_PVT.Collect_Projects.begin',
                'Entering FPA_PROCESS_PVT.Collect_Projects'
            );
        END IF;

        IF FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
            FND_LOG.STRING
            (
                FND_LOG.LEVEL_PROCEDURE,
                'FPA.SQL.FPA_PROCESS_PVT.Collect_Projects.',
                'Calling  Fpa_Utilities_Pvt.attach_AW'
            );
        END IF;

        -- Attach AW Workspace
        Fpa_Utilities_Pvt.attach_AW
        (
             p_api_version => 1.0,
             p_attach_mode => 'rw',
             x_return_status => x_return_status,
             x_msg_count => x_msg_count,
             x_msg_data => x_msg_data
        );

        l_pc_id := p_pc_id;

--Changes per MJC start here.

        IF FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
            FND_LOG.STRING
            (
                FND_LOG.LEVEL_PROCEDURE,
                'FPA.SQL.FPA_PROCESS_PVT.Collect_Projects.',
                'Executing query to get PC name, desc, submission date and due date.'
            );
        END IF;

        select a.name ,a.description ,b.initiate_date ,b.submission_due_date
          into l_pc_name, l_pc_description, l_pc_date_initiated, l_due_date
          from fpa_pcs_vl a ,fpa_aw_pc_info_v b
         where a.planning_cycle = b.planning_cycle
           and a.planning_cycle = l_pc_id;

        IF FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
            FND_LOG.STRING
            (
                FND_LOG.LEVEL_PROCEDURE,
                'FPA.SQL.FPA_PROCESS_PVT.Collect_Projects.',
                'Calling Fpa_Main_Process_Pvt.Cancel_Workflow'
            );
        END IF;

        Fpa_Main_Process_Pvt.Cancel_Workflow
        (
          p_pc_name => l_pc_name,
      p_pc_id => l_pc_id,
      p_pc_description => l_pc_description,
      p_pc_date_initiated => l_pc_date_initiated,
      p_due_date => l_due_date,
      x_return_status => x_return_status,
      x_msg_count => x_msg_count,
      x_msg_data => x_msg_data
        );

/*
        IF FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
            FND_LOG.STRING
            (
                FND_LOG.LEVEL_PROCEDURE,
                'FPA.SQL.FPA_PROCESS_PVT.Collect_Projects.',
                'Calling Fpa_Main_Process_Pvt.Force_User_Action'
            );
        END IF;

        Fpa_Main_Process_Pvt.Force_User_Action
        (
          p_itemkey =>  l_pc_id,
          p_event_name => 'CANCEL_WORKFLOW',
          x_return_status => x_return_status,
          x_msg_count =>  x_msg_count,
          x_msg_data => x_msg_data
        );
*/
--Changes per MJC end here.

--        FPA_PROJECT_PVT.Collect_Projects()

        l_api_version := 1;

        IF l_api_version = p_api_version THEN
          IF FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
            FND_LOG.STRING
            (
                FND_LOG.LEVEL_PROCEDURE,
                'FPA.SQL.FPA_PROCESS_PVT.Collect_Projects.',
                'Calling FPA_PlanningCycle_Pvt.Set_Pc_Status'
            );
          END IF;

          FPA_PlanningCycle_Pvt.Set_Pc_Status
            (
                    p_api_version => l_api_version,
                    p_pc_id => l_pc_id,
                    p_pc_status_code => 'ANALYSIS',
                    x_return_status  =>  x_return_status,
                    x_msg_data  =>  x_msg_data,
                    x_msg_count =>  x_msg_count
            );

    --          The Procedure call to move workflow to the next node


    -- Update and commit our changes
            IF (p_commit = FND_API.G_TRUE) THEN
        IF FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
            FND_LOG.STRING
            (
                FND_LOG.LEVEL_PROCEDURE,
                'FPA.SQL.FPA_PROCESS_PVT.Collect_Projects.',
                'Updating AW and commiting database'
            );
        END IF;

                dbms_aw.execute('UPDATE');
                COMMIT;
            END IF;

    -- Detach AW Workspace
        IF FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
            FND_LOG.STRING
            (
                FND_LOG.LEVEL_PROCEDURE,
                'FPA.SQL.FPA_PROCESS_PVT.Collect_Projects.',
                'Calling  Fpa_Utilities_Pvt.detach_AW'
            );
        END IF;

            Fpa_Utilities_Pvt.detach_AW
            (
                p_api_version => l_api_version,
                x_return_status => x_return_status,
                x_msg_count => x_msg_count,
                x_msg_data => x_msg_data
            );

            IF FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
                FND_LOG.STRING
                (
                  FND_LOG.LEVEL_PROCEDURE,
                  'FPA.SQL.FPA_PROCESS_PVT.Collect_Projects.end',
                  'Ending FPA_PROCESS_PVT.Collect_Projects'
                );
            END IF;
        END IF;
   EXCEPTION
    WHEN OTHERS THEN
        ROLLBACK;

        -- Detach AW Workspace
        Fpa_Utilities_Pvt.detach_AW
                        (
                          p_api_version => l_api_version,
                          x_return_status => x_return_status,
                          x_msg_count => x_msg_count,
                          x_msg_data => x_msg_data
                        );

        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

        IF FND_LOG.LEVEL_ERROR >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
        FND_LOG.STRING
        (
            FND_LOG.LEVEL_ERROR,
            'FPA.SQL.FPA_PROCESS_PVT.Collect_Projects',
            SQLERRM
        );
        END IF;

        FND_MSG_PUB.count_and_get
        (
            p_count    =>      x_msg_count,
            p_data     =>      x_msg_data
        );
        RAISE;
   END Collect_Projects;


    PROCEDURE Add_Projects
      (   p_api_version           IN NUMBER,
      p_commit                IN VARCHAR2,
      p_scenario_id           IN NUMBER,
      p_proj_id_str           IN varchar2,
      p_project_source        IN VARCHAR2,
      x_return_status         OUT NOCOPY VARCHAR2,
      x_msg_data              OUT NOCOPY VARCHAR2,
      x_msg_count             OUT NOCOPY NUMBER
      )


      --    if p_project_source = 'PJT'. Add proj. from current  plan
      --    if p_project_source = 'PJP'. Add proj. from Initial Scenario
      --    p_scenario_id is always the current scenario

    IS
--       TYPE  projectIdType is TABLE of varchar2(4000) index by binary_integer;
       l_api_version           NUMBER;
       l_init_scenario_id       NUMBER;
       l_data_to_calc varchar2(30);

       p_count integer := 1;
       added_project_id varchar2(30);
       l_project_str varchar2(2000);
--       projectIdTbl projectIdType;
       projectIdTbl FPA_VALIDATION_PVT.PROJECT_ID_TBL_TYPE;
       l_exists varchar2(1);
       l_project_set_id number(15);


       cursor c_init_project_set is
         select pset.INIT_PROJECT_SET_ID
       from fpa_aw_sce_info_v sc, fpa_aw_pc_info_v pc, fpa_aw_project_sets_v pset
       where sc.planning_cycle = pc.planning_cycle
       and pc.portfolio = pset.portfolio
       and sc.scenario = p_scenario_id;

/*       cursor c_added_projects(p_scenario number) is
--   SELECT scenario ,project,scenario_project_valid from fpa_aw_proj_info_v where scenario = p_scenario;
         SELECT scenario ,project, scenario_project_valid
       FROM table (CAST(  ( olap_table ('fpa.fpapjp duration query', 'fpa_advanced_search_tbl','',
       'DIMENSION scenario FROM scenario_d DIMENSION project from project_d MEASURE scenario_project_valid from scenario_project_m')) as fpa_advanced_search_tbl))
       WHERE scenario_project_valid = 1 and scenario = p_scenario;
*/

--   l_added_projects fpa_advanced_search_tbl%rowtype;

    BEGIN



       FND_MSG_PUB.Initialize;

       IF FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
      FND_LOG.STRING
        (
        FND_LOG.LEVEL_PROCEDURE,
        'FPA.SQL.FPA_PROCESS_PVT.Add_Projects.begin',
        'Entering FPA_PROCESS_PVT.Add_Projects'
        );

       END IF;

       l_api_version := 1;

       IF FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
      FND_LOG.STRING
        (
        FND_LOG.LEVEL_PROCEDURE,
        'FPA.SQL.FPA_PROCESS_PVT.Add_Projects',
        'Getting Initial Scenario Id'
        );
       END IF;


        -- Now we get the Initial Scenario Id.
       select scenario
     into l_init_scenario_id
     from fpa_aw_sce_info_v
     where is_initial_scenario = 1
     and planning_cycle = (select planning_cycle
       from fpa_aw_sces_v
       where scenario = p_scenario_id);

       -- p_proj_id_str is passed as a string of project ids. The API calls for calculating project level data
       -- are called for each project. The project id string should be parsed and the ids stored in a pl/sql table
       -- for looping.

       -- Begin parsing project id string
       l_project_str := p_proj_id_str;
       while (length(l_project_str) > 0) LOOP

      added_project_id := substr(l_project_str,1,instr(l_project_str, ',')-1);
      if added_project_id is null then
         projectIdTbl(p_count) := l_project_str;
         l_project_str := null;
      else

         projectIdTbl(p_count) := added_project_id;
         l_project_str  := substr(l_project_str, (instr(l_project_str, ',') + 1));
      end if;
      p_count := p_count+1;
       end loop;
       -- end of parsing

     IF p_project_source = 'PJT' THEN

        IF FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
           FND_LOG.STRING
         (
         FND_LOG.LEVEL_PROCEDURE,
         'FPA.SQL.FPA_PROCESS_PVT.Add_Projects.Source = PJT',
         'Entering FPA_PROCESS_PVT.Add_Projects'
         );
        END IF;

        IF FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
           FND_LOG.STRING
         (
         FND_LOG.LEVEL_PROCEDURE,
         'FPA.SQL.FPA_PROCESS_PVT.Add_Projects.Source = PJT',
         'Calling FPA_PROCESS_PVT.load_project_details_aw'
         );
        END IF;

        -- Attaching and detaching A/w is not required for details load. This is handled internally within the project_details_aw API.
        FPA_PROCESS_PVT.load_project_details_aw
          (
          p_api_version   => 1.0,
          p_init_msg_list => 'F',
          p_commit        => FND_API.G_TRUE,
          p_type          => 'ADD',
          p_scenario_id   =>  l_init_scenario_id,
          p_projects      =>  p_proj_id_str,
          x_return_status =>  x_return_status,
          x_msg_count     =>  x_msg_data,
          x_msg_data      =>  x_msg_count
          );
     end if;

     -- irrespective of the project source, PJT or PJP, AW should be attached R/w here.

     Fpa_Utilities_Pvt.attach_AW
       (
       p_api_version => 1.0,
       p_attach_mode => 'rw',
       x_return_status => x_return_status,
       x_msg_count => x_msg_count,
       x_msg_data => x_msg_data
       );

     if p_project_source = 'PJT' then

        IF FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
           FND_LOG.String
         (
         FND_LOG.LEVEL_PROCEDURE,
         'fpa.sql.FPA_Process_Pvt.Add_Projects.Source = PJT',
         'Calling fpa_scenario_pvt.calc_scenario_data for updating Scenario project data..'
         );
        END IF;

        -- open a cursor to get the newly added projects
        -- Calculate Fin Data rollup data for all newly added projects in the scenario

        open c_init_project_set;
        fetch c_init_project_set into l_project_set_id;
        close c_init_project_set;

        IF FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
           FND_LOG.String
         (
         FND_LOG.LEVEL_PROCEDURE,
         'fpa.sql.FPA_Process_Pvt.Add_Projects.Source = PJT',
         'cursor processed to get Project Set. ID = '|| l_project_set_id
         );
        END IF;

        -- Update fpapjp - set portfolio project set relation
        dbms_aw.execute('LMT project_set_d TO ' ||l_project_set_id);


        for i in projectIdTbl.first .. projectIdTbl.last
        loop

           IF FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
          FND_LOG.STRING
            (
            FND_LOG.LEVEL_PROCEDURE,
            'FPA.SQL.FPA_PROCESS_PVT.Add_Projects.Source = PJT',
            'Calling fpa_scenario_pvt.calc_sceario_data in PROJ Mode for projectId= '||projectIdTbl(i)
            );
           END IF;

           l_data_to_calc := 'PROJ';
           fpa_scenario_pvt.calc_scenario_data
           (
         p_api_version => 1.0,
         p_scenario_id => l_init_scenario_id,
         p_project_id => projectIdTbl(i),
         p_class_code_id => null,
         p_data_to_calc => l_data_to_calc,
         x_return_status => x_return_status,
         x_msg_count => x_msg_count,
         x_msg_data => x_msg_data
           );


           -- Bug 4297801 Call Project sets api when projects are added from current plan

              l_exists := PA_PROJECT_SET_UTILS.check_projects_in_set(l_project_set_id, projectIdTbl(i));

              IF l_exists = 'N' THEN
               -- add the project to the project set, if it does not yet exist
                  PA_PROJECT_SETS_PUB.create_project_set_line
                  ( p_project_set_id  => l_project_set_id
                   ,p_project_id      => projectIdTbl(i)
                   ,x_return_status   => x_return_status
                   ,x_msg_count       => x_msg_count
                   ,x_msg_data        => x_msg_data
                  );
          END IF;

        IF FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
           FND_LOG.String
         (
         FND_LOG.LEVEL_PROCEDURE,
         'fpa.sql.FPA_Process_Pvt.Add_Projects.Source = PJT',
         'Completed Project Set API  PA_PROJECT_SETS_PUB.create_project_set_line'
         );
        END IF;


          dbms_aw.execute('LMT project_d TO ' || projectIdTbl(i));
          dbms_aw.execute('project_set_project_m = yes');

        IF FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
           FND_LOG.String
         (
         FND_LOG.LEVEL_PROCEDURE,
         'fpa.sql.FPA_Process_Pvt.Add_Projects.Source = PJT',
         'Completed AW Updates for project_set_project_m'
         );
        END IF;

        end loop;

        IF FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
           FND_LOG.STRING
         (
         FND_LOG.LEVEL_PROCEDURE,
         'FPA.SQL.FPA_PROCESS_PVT.Add_Projects.Source = PJT',
         'Completed scenario Project rollup calculations. proceeding to classcode'
         );
        END IF;

        -- calculate classcode level data for all classcodes in the scenario
        -- Call copy_sce_proj_data in PJT mode to calculate total cost, benefit,
        -- and other metrics at all levels for the Initial Scenario
        l_data_to_calc := 'CLASS';
        fpa_scenario_pvt.calc_scenario_data
          (
          p_api_version => 1.0,
          p_scenario_id => l_init_scenario_id,
          p_project_id => null,
          p_class_code_id => null,
          p_data_to_calc => l_data_to_calc,
          x_return_status => x_return_status,
          x_msg_count => x_msg_count,
        x_msg_data => x_msg_data
          );

        IF FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
           FND_LOG.STRING
             (
             FND_LOG.LEVEL_PROCEDURE,
             'FPA.SQL.FPA_PROCESS_PVT.Add_Projects.Source = PJT',
             'Completed Classcode rollup calculations. proceeding to scenario'
             );
        END IF;
        l_data_to_calc := 'SCEN';
        fpa_scenario_pvt.calc_scenario_data
          (
          p_api_version => 1.0,
          p_scenario_id => l_init_scenario_id,
          p_project_id => null,
          p_class_code_id => null,
          p_data_to_calc => l_data_to_calc,
          x_return_status => x_return_status,
          x_msg_count => x_msg_count,
          x_msg_data => x_msg_data
          );

        IF FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
           FND_LOG.STRING
             (
             FND_LOG.LEVEL_PROCEDURE,
             'FPA.SQL.FPA_PROCESS_PVT.Add_Projects.Source = PJT',
             'Calling fpa_scorecards_pvt.calc_Scenario_wscores_aw Calculate weighted and cost weighted scores '
             );
        END IF;


/*      fpa_scorecards_pvt.Calc_Scenario_Wscores_Aw
          (
          p_api_version => 1.0,
          p_init_msg_list => FND_API.G_FALSE,
          p_scenario_id => l_init_scenario_id,
          x_return_status => x_return_status,
              x_msg_count => x_msg_count,
          x_msg_data => x_msg_data
          );

          IF FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
             FND_LOG.STRING
               (
               FND_LOG.LEVEL_PROCEDURE,
               'FPA.SQL.FPA_PROCESS_PVT.Add_Projects.Source = PJT',
               'Completed calculations for Initial scenario. ScenarioId ='||l_init_scenario_id
               );
          END IF;
*/

     IF FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
        FND_LOG.STRING
        (
        FND_LOG.LEVEL_PROCEDURE,
        'fpa.sql.fpa_project_pvt.Refresh_project',
        'Calling fpa.sql.FPA_VALIDATION_PROCESS_PVT.Budget_Version_Validations'
          );
     END IF;

      FPA_VALIDATION_PROCESS_PVT.Budget_Version_Validations(
          p_api_version           =>  1.0,
          p_init_msg_list         =>  'F',
          p_validation_set        =>  'FPA_VALIDATION_TYPES',
          p_header_object_id      =>  l_init_scenario_id,
          p_header_object_type    =>  'SCENARIO',
          p_line_projects_tbl     =>  projectIdTbl,
          p_type                  =>  'CREATE',
          x_return_status         =>  x_return_status,
          x_msg_count             =>  x_msg_count,
          x_msg_data              =>  x_msg_data);

      IF FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
         FND_LOG.STRING
         (
         FND_LOG.LEVEL_PROCEDURE,
         'fpa.sql.fpa_project_pvt.Refresh_project',
         'End fpa.sql.FPA_VALIDATION_PROCESS_PVT.Budget_Version_Validations'
           );
     END IF;


     end if; -- end of PJT processing. that is, project added to initial scenario


     -- no need to check for p_proj_source = PJP because the logic below is executed for all cases except
     -- adding project from current plan to initial scenario, there is no current scenario.
     if l_init_scenario_id <> p_scenario_id then  -- then we are adding projects from Current Plan to current scenario (and initial scenario)

        FPA_SCENARIO_PVT.copy_sce_project_Data
          (
          p_api_version => l_api_version,
          p_commit      => FND_API.G_FALSE,
          p_target_scen_id => p_scenario_id,
          p_project_id_str => p_proj_id_str,
          x_return_status  =>  x_return_status,
          x_msg_data  =>  x_msg_data,
          x_msg_count =>  x_msg_count
          );

        for i in projectIdTbl.first .. projectIdTbl.last
        loop

           IF FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
          FND_LOG.STRING
            (
            FND_LOG.LEVEL_PROCEDURE,
            'FPA.SQL.FPA_PROCESS_PVT.Add_Projects.Source = PJP',
            'Calling fpa_scenario_pvt.calc_sceario_data in PROJFIN Mode for projectId= '||projectIdTbl(i)
            );
           END IF;
-- Calculate npv,irr,roi for projects added to target scenario.
-- these mertrics sshould not be copied from source scen. since discount rates for
-- source and target scenarios could be different

           l_data_to_calc := 'PROJFIN';
           fpa_scenario_pvt.calc_scenario_data
           (
         p_api_version => 1.0,
         p_scenario_id => p_scenario_id,
         p_project_id => projectIdTbl(i),
         p_class_code_id => null,
         p_data_to_calc => l_data_to_calc,
         x_return_status => x_return_status,
         x_msg_count => x_msg_count,
         x_msg_data => x_msg_data
           );
        end loop;



        -- calculate classcode level data for all classcodes in the scenario
        -- Call copy_sce_proj_data in PJT mode to calculate total cost, benefit,
        -- and other metrics at all levels for the Initial Scenario

          IF FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
         FND_LOG.STRING
           (
           FND_LOG.LEVEL_PROCEDURE,
           'FPA.SQL.FPA_PROCESS_PVT.Add_Projects.CurrentScenario',
           'Completed scenario Project rollup calculations. proceeding to classcode'
           );
          END IF;

          l_data_to_calc := 'CLASS';
          fpa_scenario_pvt.calc_scenario_data
          (
        p_api_version => 1.0,
        p_scenario_id => p_scenario_id,
        p_project_id => null,
        p_class_code_id => null,
        p_data_to_calc => l_data_to_calc,
        x_return_status => x_return_status,
        x_msg_count => x_msg_count,
        x_msg_data => x_msg_data
          );

        IF FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
           FND_LOG.STRING
         (
         FND_LOG.LEVEL_PROCEDURE,
         'FPA.SQL.FPA_PROCESS_PVT.Add_Projects.Current Scenario',
         'Completed Classcode rollup calculations. proceeding to scenario'
         );
        END IF;

        l_data_to_calc := 'SCEN';
        fpa_scenario_pvt.calc_scenario_data
          (
          p_api_version => 1.0,
          p_scenario_id => p_scenario_id,
          p_project_id => null,
          p_class_code_id => null,
          p_data_to_calc => l_data_to_calc,
          x_return_status => x_return_status,
          x_msg_count => x_msg_count,
          x_msg_data => x_msg_data
          );
/*
          IF FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
         FND_LOG.STRING
           (
           FND_LOG.LEVEL_PROCEDURE,
           'FPA.SQL.FPA_PROCESS_PVT.Add_Projects.Source = PJT',
           'Calling fpa_scorecards_pvt.calc_Scenario_wscores_aw Calculate weighted and cost weighted scores '
           );
          END IF;
          */

       IF FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
          FND_LOG.STRING
            (
            FND_LOG.LEVEL_PROCEDURE,
            'fpa.sql.fpa_project_pvt.add_project',
            'Calling fpa.sql.FPA_SCORECARDS_PVT.Handle_Comments'
            );
       END IF;

       FPA_SCORECARDS_PVT.Handle_Comments(
                p_api_version         => p_api_version,
                p_init_msg_list       => FND_API.G_TRUE,
                p_scenario_id         => p_scenario_id,
                p_type                => 'PJP',
                p_source_scenario_id  => null,
                p_delete_project_id   => null,
                x_return_status       => x_return_status,
                x_msg_count           => x_msg_count,
                x_msg_data            => x_msg_data);


      IF FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
        FND_LOG.STRING
        (
        FND_LOG.LEVEL_PROCEDURE,
        'fpa.sql.fpa_project_pvt.Refresh_project',
        'Calling fpa.sql.FPA_VALIDATION_PROCESS_PVT.Budget_Version_Validations'
          );
      END IF;

      FPA_VALIDATION_PROCESS_PVT.Budget_Version_Validations(
              p_api_version           =>  1.0,
              p_init_msg_list         =>  'F',
              p_validation_set        =>  'FPA_VALIDATION_TYPES',
              p_header_object_id      =>  p_scenario_id,
              p_header_object_type    =>  'SCENARIO',
              p_line_projects_tbl     =>  projectIdTbl,
              p_type                  =>  'CREATE',
              x_return_status         =>  x_return_status,
              x_msg_count             =>  x_msg_count,
              x_msg_data              =>  x_msg_data);

      IF FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
         FND_LOG.STRING
         (
         FND_LOG.LEVEL_PROCEDURE,
         'fpa.sql.fpa_project_pvt.Refresh_project',
         'End fpa.sql.FPA_VALIDATION_PROCESS_PVT.Budget_Version_Validations'
           );
     END IF;

     end if;  -- end of processing for PJP source.


     -- Update and commit our changes

     IF (p_commit = FND_API.G_TRUE) THEN
        dbms_aw.execute('UPDATE');
        COMMIT;
     END IF;

     -- Detach AW Workspace
     Fpa_Utilities_Pvt.detach_AW
       (
       p_api_version => l_api_version,
       x_return_status => x_return_status,
       x_msg_count => x_msg_count,
       x_msg_data => x_msg_data
       );


     IF FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
        FND_LOG.STRING
          (
          FND_LOG.LEVEL_PROCEDURE,
          'FPA.SQL.FPA_PROCESS_PVT.Add_Projects.end',
          'Ending FPA_PROCESS_PVT.Add_Projects'
          );
     END IF;

    EXCEPTION
       WHEN OTHERS THEN
     ROLLBACK;

     Fpa_Utilities_Pvt.detach_AW
       (
       p_api_version => l_api_version,
         x_return_status => x_return_status,
         x_msg_count => x_msg_count,
         x_msg_data => x_msg_data
       );

         x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

         IF FND_LOG.LEVEL_ERROR >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
        FND_LOG.STRING
          (
          FND_LOG.LEVEL_ERROR,
          'FPA.SQL.FPA_PROCESS_PVT.Add_Projects',
          SQLERRM
          );
         END IF;

         FND_MSG_PUB.count_and_get
           (
           p_count    =>      x_msg_count,
           p_data     =>      x_msg_data
           );
           RAISE;
    END Add_Projects;



    PROCEDURE Refresh_Projects
      (   p_api_version           IN NUMBER,
      p_commit                IN VARCHAR2,
      p_scenario_id           IN NUMBER,
      p_proj_id_str           IN varchar2,
      x_return_status         OUT NOCOPY VARCHAR2,
      x_msg_data              OUT NOCOPY VARCHAR2,
      x_msg_count             OUT NOCOPY NUMBER
      )
      IS

       -- TYPE  projectIdType is TABLE of varchar2(4000) index by binary_integer;
       l_api_version           NUMBER;
       l_data_to_calc varchar2(30);

       p_count integer := 1;
       added_project_id varchar2(30);
       l_project_str varchar2(2000);
       --projectIdTbl projectIdType;
       projectIdTbl FPA_VALIDATION_PVT.PROJECT_ID_TBL_TYPE;

    BEGIN

       FND_MSG_PUB.Initialize;

       IF FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
      FND_LOG.STRING
        (
        FND_LOG.LEVEL_PROCEDURE,
        'FPA.SQL.FPA_PROCESS_PVT.Refresh_Projects.begin',
        'Entering FPA_PROCESS_PVT.Refresh_Projects'
        );

       END IF;

       l_api_version := 1;

       l_project_str := p_proj_id_str;
       while (length(l_project_str) > 0) LOOP

          added_project_id := substr(l_project_str,1,instr(l_project_str, ',')-1);
          if added_project_id is null then
             projectIdTbl(p_count) := l_project_str;
             l_project_str := null;
          else

             projectIdTbl(p_count) := added_project_id;
             l_project_str  := substr(l_project_str, (instr(l_project_str, ',') + 1));
          end if;
          p_count := p_count+1;

       end loop;

    IF FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
       FND_LOG.STRING
     (
     FND_LOG.LEVEL_PROCEDURE,
     'FPA.SQL.FPA_PROCESS_PVT.Refresh_Projects.Source',
     'Entering FPA_PROCESS_PVT.Refresh_Projects'
     );
    END IF;

    IF FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
       FND_LOG.STRING
     (
     FND_LOG.LEVEL_PROCEDURE,
     'FPA.SQL.FPA_PROCESS_PVT.Refresh_Projects.Source',
     'Calling FPA_PROCESS_PVT.load_project_details_aw'
     );
    END IF;
    -- Attaching and detaching A/w is not required for details load. This is handled internally within the project_details_aw API.
    FPA_PROCESS_PVT.load_project_details_aw
      (
      p_api_version   => 1.0,
      p_init_msg_list => 'F',
      p_commit        => FND_API.G_TRUE,
      p_type          => 'REFRESH',
      p_scenario_id   => p_scenario_id,
      p_projects      => p_proj_id_str,
      x_return_status => x_return_status,
      x_msg_count     => x_msg_data,
      x_msg_data      => x_msg_count
      );

     Fpa_Utilities_Pvt.attach_AW
       (
       p_api_version => 1.0,
       p_attach_mode => 'rw',
       x_return_status => x_return_status,
       x_msg_count => x_msg_count,
       x_msg_data => x_msg_data
       );

   IF FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
       FND_LOG.String
     (
     FND_LOG.LEVEL_PROCEDURE,
     'fpa.sql.FPA_Process_Pvt.Refresh_Projects.Source',
     'Calling fpa_scenario_pvt.calc_scenario_data for updating Scenario project data..'
     );
    END IF;

    for i in projectIdTbl.first .. projectIdTbl.last
    loop

       IF FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
      FND_LOG.STRING
        (
        FND_LOG.LEVEL_PROCEDURE,
        'FPA.SQL.FPA_PROCESS_PVT.Refresh_Projects.Source',
        'Calling fpa_scenario_pvt.calc_sceario_data in PROJ Mode for projectId= '||projectIdTbl(i)
        );
       END IF;

       l_data_to_calc := 'PROJ';
       fpa_scenario_pvt.calc_scenario_data
       (
         p_api_version => 1.0,
         p_scenario_id => p_scenario_id,
         p_project_id => projectIdTbl(i),
         p_class_code_id => null,
         p_data_to_calc => l_data_to_calc,
         x_return_status => x_return_status,
         x_msg_count => x_msg_count,
         x_msg_data => x_msg_data
           );

    --      dbms_aw.execute('LMT project_d TO ' || projectIdTbl(i));

        IF FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
           FND_LOG.String
         (
         FND_LOG.LEVEL_PROCEDURE,
         'fpa.sql.FPA_Process_Pvt.Refresh_Projects.Source',
         'Completed AW Updates for project_set_project_m'
         );
        END IF;

    end loop;

    IF FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
       FND_LOG.STRING
     (
     FND_LOG.LEVEL_PROCEDURE,
     'FPA.SQL.FPA_PROCESS_PVT.Refresh_Projects.Source',
     'Completed scenario Project rollup calculations. proceeding to classcode'
     );
    END IF;

    -- calculate classcode level data for all classcodes in the scenario
    -- Call copy_sce_proj_data in PJT mode to calculate total cost, benefit,
    -- and other metrics at all levels for the Initial Scenario
    l_data_to_calc := 'CLASS';
    fpa_scenario_pvt.calc_scenario_data
      (
      p_api_version => 1.0,
      p_scenario_id => p_scenario_id,
      p_project_id => null,
      p_class_code_id => null,
      p_data_to_calc => l_data_to_calc,
      x_return_status => x_return_status,
      x_msg_count => x_msg_count,
    x_msg_data => x_msg_data
      );

    IF FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
       FND_LOG.STRING
         (
         FND_LOG.LEVEL_PROCEDURE,
         'FPA.SQL.FPA_PROCESS_PVT.Refresh_Projects.Source',
         'Completed Classcode rollup calculations. proceeding to scenario'
         );
    END IF;
    l_data_to_calc := 'SCEN';
    fpa_scenario_pvt.calc_scenario_data
      (
      p_api_version => 1.0,
      p_scenario_id => p_scenario_id,
      p_project_id => null,
      p_class_code_id => null,
      p_data_to_calc => l_data_to_calc,
      x_return_status => x_return_status,
      x_msg_count => x_msg_count,
      x_msg_data => x_msg_data
      );

     IF FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
        FND_LOG.STRING
        (
        FND_LOG.LEVEL_PROCEDURE,
        'fpa.sql.fpa_project_pvt.Refresh_project',
        'Calling fpa.sql.FPA_VALIDATION_PROCESS_PVT.Budget_Version_Validations'
          );
     END IF;

      FPA_VALIDATION_PROCESS_PVT.Budget_Version_Validations(
              p_api_version           =>  1.0,
              p_init_msg_list         =>  'F',
              p_validation_set        =>  'FPA_VALIDATION_TYPES',
              p_header_object_id      =>  p_scenario_id,
              p_header_object_type    =>  'SCENARIO',
              p_line_projects_tbl     =>  projectIdTbl,
              p_type                  =>  'UPDATE',
              x_return_status         =>  x_return_status,
              x_msg_count             =>  x_msg_count,
              x_msg_data              =>  x_msg_data);


      IF FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
         FND_LOG.STRING
         (
         FND_LOG.LEVEL_PROCEDURE,
         'fpa.sql.fpa_project_pvt.Refresh_project',
         'End fpa.sql.FPA_VALIDATION_PROCESS_PVT.Budget_Version_Validations'
           );
     END IF;


     -- Update and commit our changes

     IF (p_commit = FND_API.G_TRUE) THEN
        dbms_aw.execute('UPDATE');
        COMMIT;
     END IF;

     -- Detach AW Workspace
     Fpa_Utilities_Pvt.detach_AW
       (
       p_api_version => l_api_version,
       x_return_status => x_return_status,
       x_msg_count => x_msg_count,
       x_msg_data => x_msg_data
       );

     IF FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
        FND_LOG.STRING
          (
          FND_LOG.LEVEL_PROCEDURE,
          'FPA.SQL.FPA_PROCESS_PVT.Refresh_Projects.Begin Validate',
          'Ending FPA_PROCESS_PVT.Refresh_Projects'
          );
     END IF;



     Fpa_Validation_Pvt.Validate (
        p_api_version           => 1.0,
        p_init_msg_list         => 'F',
        p_validation_set        => 'FPA_VALIDATION_TYPES',
        p_header_object_id      => p_scenario_id,
        p_header_object_type    => 'SCENARIO',
        p_line_projects_tbl     => projectIdTbl,
        x_return_status         => x_return_status,
        x_msg_count             => x_msg_count,
        x_msg_data              => x_msg_data);


     IF FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
        FND_LOG.STRING
          (
          FND_LOG.LEVEL_PROCEDURE,
          'FPA.SQL.FPA_PROCESS_PVT.Refresh_Projects.end',
          'Ending FPA_PROCESS_PVT.Refresh_Projects'
          );
     END IF;

    EXCEPTION
       WHEN OTHERS THEN
     ROLLBACK;

     Fpa_Utilities_Pvt.detach_AW
       (
       p_api_version => l_api_version,
         x_return_status => x_return_status,
         x_msg_count => x_msg_count,
         x_msg_data => x_msg_data
       );

         x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

         IF FND_LOG.LEVEL_ERROR >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
        FND_LOG.STRING
          (
          FND_LOG.LEVEL_ERROR,
          'FPA.SQL.FPA_PROCESS_PVT.Refresh_Projects',
          SQLERRM
          );
         END IF;

         FND_MSG_PUB.count_and_get
           (
           p_count    =>      x_msg_count,
           p_data     =>      x_msg_data
           );
           RAISE;
    END Refresh_Projects;



/*++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++*/

   PROCEDURE Remove_Projects
     (  p_api_version           IN NUMBER,
        p_commit                IN VARCHAR2,
        p_scenario_id           IN NUMBER,
        p_proj_id               IN NUMBER,
        x_return_status         OUT NOCOPY VARCHAR2,
        x_msg_data              OUT NOCOPY VARCHAR2,
        x_msg_count             OUT NOCOPY NUMBER
     )

    IS

    cursor c_class_code is
     select class_code from fpa_aw_projs_v where project = p_proj_id;

    l_api_version           NUMBER;
    l_data_to_calc          varchar2(30);
    l_class_code_id         NUMBER;

   BEGIN

        FND_MSG_PUB.Initialize;

        IF FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
            FND_LOG.STRING
            (
                FND_LOG.LEVEL_PROCEDURE,
                'FPA.SQL.FPA_PROCESS_PVT.Remove_Projects.begin',
                'Entering FPA_PROCESS_PVT.Remove_Projects'
            );
        END IF;

        l_api_version := 1;

-- Get Classcode for the project_id passed as parameter.
        open c_class_code;
        fetch c_class_code into l_class_code_id;
        close c_class_code;

            Fpa_Utilities_Pvt.attach_AW
            (
                 p_api_version => 1.0,
                 p_attach_mode => 'rw',
                 x_return_status => x_return_status,
                 x_msg_count => x_msg_count,
                 x_msg_data => x_msg_data
            );

        IF FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
           FND_LOG.STRING
             (
             FND_LOG.LEVEL_PROCEDURE,
             'FPA.SQL.FPA_PROCESS_PVT.Remove_Projects',
             'calling FPA_SCENARIO_PVT.remove_project_from_scenario'
             );
        END IF;


-- API to set scenario_project_m all other project measures to na
            FPA_SCENARIO_PVT.remove_project_from_scenario
            (
                p_api_version => l_api_version,
                p_commit      => FND_API.G_FALSE,
                p_scenario_id => p_scenario_id,
                p_project_id  => p_proj_id,
                x_return_status  =>  x_return_status,
                x_msg_data  =>  x_msg_data,
                x_msg_count =>  x_msg_count
            );


        IF FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
           FND_LOG.STRING
             (
             FND_LOG.LEVEL_PROCEDURE,
             'fpa.sql.fpa_process_pvt.remove_project',
             'calling fpa_scorecards_pvt.handle_comments '||p_scenario_id||','||p_proj_id
             );
        END IF;


        FPA_SCORECARDS_PVT.Handle_Comments(
                p_api_version         => p_api_version,
                p_init_msg_list       => FND_API.G_TRUE,
                p_scenario_id         => p_scenario_id,
                p_type                => null,
                p_source_scenario_id  => null,
                p_delete_project_id   => p_proj_id,
                x_return_status       => x_return_status,
                x_msg_count           => x_msg_count,
                x_msg_data            => x_msg_data);


        IF FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
           FND_LOG.STRING
             (
             FND_LOG.LEVEL_PROCEDURE,
             'FPA.SQL.FPA_PROCESS_PVT.Remove_Projects',
             'calling FPA_SCENARIO_PVT.calc_scenario_data in class mode'
             );
        END IF;



-- Recalculate metrics at rollup level.
-- For classcode, calculate rollup at the classcode associated with the project being removed.
-- Metrics for other classcodes are not affected.
        l_data_to_calc := 'CLASS';
        fpa_scenario_pvt.calc_scenario_data
          (
          p_api_version => 1.0,
          p_scenario_id => p_scenario_id,
          p_project_id => null,
          p_class_code_id => l_class_code_id,
          p_data_to_calc => l_data_to_calc,
          x_return_status => x_return_status,
          x_msg_count => x_msg_count,
        x_msg_data => x_msg_data
          );

        IF FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
           FND_LOG.STRING
             (
             FND_LOG.LEVEL_PROCEDURE,
             'FPA.SQL.FPA_PROCESS_PVT.Remove_Projects',
             'calling FPA_SCENARIO_PVT.calc_scenario_data in Scenario mode'
             );
        END IF;

        l_data_to_calc := 'SCEN';
        fpa_scenario_pvt.calc_scenario_data
          (
          p_api_version => 1.0,
          p_scenario_id => p_scenario_id,
          p_project_id => null,
          p_class_code_id => null,
          p_data_to_calc => l_data_to_calc,
          x_return_status => x_return_status,
          x_msg_count => x_msg_count,
          x_msg_data => x_msg_data
          );

        IF FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
           FND_LOG.STRING
             (
             FND_LOG.LEVEL_PROCEDURE,
             'FPA.SQL.FPA_PROCESS_PVT.Remove_Projects',
             'Completed all API calls. Issue UPDATE to AW'
             );
        END IF;

    -- Update and commit our changes
             IF (p_commit = FND_API.G_TRUE) THEN
                dbms_aw.execute('UPDATE');
                COMMIT;
             END IF;

    -- Detach AW Workspace
             Fpa_Utilities_Pvt.detach_AW
             (
                    p_api_version => l_api_version,
                    x_return_status => x_return_status,
                    x_msg_count => x_msg_count,
                    x_msg_data => x_msg_data
             );

             IF FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
                FND_LOG.STRING
                (
                      FND_LOG.LEVEL_PROCEDURE,
                      'FPA.SQL.FPA_PROCESS_PVT.Remove_Projects.end',
                      'Ending FPA_PROCESS_PVT.Remove_Projects'
                );
             END IF;

   EXCEPTION
    WHEN OTHERS THEN
        ROLLBACK;

        -- Detach AW Workspace
        Fpa_Utilities_Pvt.detach_AW
                        (
                          p_api_version => l_api_version,
                          x_return_status => x_return_status,
                          x_msg_count => x_msg_count,
                          x_msg_data => x_msg_data
                        );

        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

        IF FND_LOG.LEVEL_ERROR >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
        FND_LOG.STRING
        (
            FND_LOG.LEVEL_ERROR,
            'FPA.SQL.FPA_PROCESS_PVT.Remove_Projects',
            SQLERRM
        );
        END IF;

        FND_MSG_PUB.count_and_get
        (
            p_count    =>      x_msg_count,
            p_data     =>      x_msg_data
        );
        RAISE;
   END Remove_Projects;


/************************************************************************************/
/************************************************************************************/

PROCEDURE update_strategicobj_weight
( p_api_version        IN NUMBER
 ,p_commit             IN VARCHAR2 := FND_API.G_FALSE
 ,p_strategic_weights_string    IN              varchar2
 ,x_return_status               OUT NOCOPY      varchar2
 ,x_msg_count                   OUT NOCOPY      number
 ,x_msg_data                    OUT NOCOPY      varchar2
)
AS
    investment_rec          fpa_investment_criteria_pvt.investment_rec_type;

    l_api_version            CONSTANT NUMBER    := 1.0;

BEGIN

        -- clear all previous messages.
        FND_MSG_PUB.Initialize;

          -- Attach the AW space read write.
          IF FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
            fnd_log.string
            (
                FND_LOG.LEVEL_STATEMENT,
                'fpa.sql.fpa_process_pvt.update_strategicobj_weight',
                'Attaching OLAP workspace: '
            );
          END IF;

          Fpa_Utilities_Pvt.attach_AW
                        (
                          p_api_version => 1.0,
                          p_attach_mode => 'rw',
                          x_return_status => x_return_status,
                          x_msg_count => x_msg_count,
                          x_msg_data => x_msg_data
                        );

        -- set the values in the record type equal to the ones passed.
        investment_rec.strategic_scores_string := p_strategic_weights_string;

    fpa_investment_criteria_pvt.update_strategicobj_weight_aw
    (
        p_investment_rec_type => investment_rec,
        x_return_status => x_return_status,
        x_msg_count => x_msg_count,
        x_msg_data => x_msg_data
    );

        -- Finally, detach the workspace
        IF FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
            fnd_log.string
            (
                FND_LOG.LEVEL_STATEMENT,
                'fpa.sql.fpa_process_pvt.create_portfolio',
                'Detaching OLAP workspace: '
            );
         END IF;

    -- Update and commit our changes
    IF (p_commit = FND_API.G_TRUE) THEN
        dbms_aw.execute('UPDATE');
        COMMIT;
    END IF;

       -- Detach AW Workspace
        Fpa_Utilities_Pvt.detach_AW
                        (
                          p_api_version => 1.0,
                          x_return_status => x_return_status,
                          x_msg_count => x_msg_count,
                          x_msg_data => x_msg_data
                        );

EXCEPTION
  WHEN OTHERS THEN
        ROLLBACK;
       -- Detach AW Workspace
       Fpa_Utilities_Pvt.detach_AW
                        (
                          p_api_version => 1.0,
                          x_return_status => x_return_status,
                          x_msg_count => x_msg_count,
                          x_msg_data => x_msg_data
                        );

        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

        IF FND_LOG.LEVEL_ERROR >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
        FND_LOG.String
        (
            FND_LOG.LEVEL_ERROR,
            'fpa.sql.FPA_Process_Pvt.Update_Pc',
            SQLERRM
        );
        END IF;

        FND_MSG_PUB.count_and_get
        (
            p_count    =>      x_msg_count,
            p_data     =>      x_msg_data
        );
        RAISE;
END;

/************************************************************************************/
/************************************************************************************/

PROCEDURE update_strategicobj
(   p_api_version        IN NUMBER,
    p_commit                        IN              VARCHAR2 := FND_API.G_FALSE,
    p_strategic_obj_id              IN              NUMBER,
    p_strategic_obj_name        IN      VARCHAR2,
    p_strategic_obj_desc        IN      VARCHAR2,
    x_return_status                 OUT NOCOPY      VARCHAR2,
    x_msg_count                     OUT NOCOPY      NUMBER,
    x_msg_data                      OUT NOCOPY      VARCHAR2
)
AS
    l_investment_rec            fpa_investment_criteria_pvt.investment_rec_type;

    l_api_version            CONSTANT NUMBER    := 1.0;

BEGIN

  FND_MSG_PUB.Initialize;

  l_investment_rec.strategic_obj_shortname := p_strategic_obj_id;
  l_investment_rec.strategic_obj_name := p_strategic_obj_name;
  l_investment_rec.strategic_obj_desc := p_strategic_obj_desc;

  -- Attach the AW space read write.
  IF FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
    fnd_log.string ( FND_LOG.LEVEL_STATEMENT,
                    'fpa.sql.fpa_resourcetype_pvt.create_resourcetype',
                    'Attaching OLAP workspace: ');
  END IF;

  Fpa_Utilities_Pvt.attach_AW( p_api_version => 1.0,
                               p_attach_mode => 'rw',
                               x_return_status => x_return_status,
                               x_msg_count => x_msg_count,
                               x_msg_data => x_msg_data);


  FPA_Investment_Criteria_PVT.update_strategicobj( p_commit => p_commit
                                                  ,p_investment_rec_type => l_investment_rec
                                                  ,x_return_status => x_return_status
                                                  ,x_msg_count => x_msg_count
                                                  ,x_msg_data => x_msg_data);

  -- Update and commit our changes
  IF (p_commit = FND_API.G_TRUE) THEN
    dbms_aw.execute('UPDATE');
    COMMIT;
  END IF;

  -- Detach AW Workspace
  Fpa_Utilities_Pvt.detach_AW(p_api_version => 1.0,
                              x_return_status => x_return_status,
                              x_msg_count => x_msg_count,
                              x_msg_data => x_msg_data);

EXCEPTION
    WHEN OTHERS THEN
        ROLLBACK;
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        FND_MSG_PUB.Count_And_Get
        (
            p_count    =>      x_msg_count,
                        p_data     =>      x_msg_data
        );
        RAISE;

END update_strategicobj;

PROCEDURE create_strategicobj
(   p_api_version       IN      NUMBER,
    p_commit            IN      VARCHAR2 := FND_API.G_FALSE,
    p_strategic_obj_name        IN      VARCHAR2,
    p_strategic_obj_desc        IN      VARCHAR2,
    p_strategic_obj_parent      IN      number,
    p_strategic_obj_level       IN      varchar2,
    x_return_status                 OUT NOCOPY      varchar2,
    x_msg_count                     OUT NOCOPY      number,
    x_msg_data                      OUT NOCOPY      varchar2
)
AS
    l_api_version            CONSTANT NUMBER    := 1.0;
    l_investment_rec            fpa_investment_criteria_pvt.investment_rec_type;
    l_stategic_obj_id           varchar2(30);
    l_seq_nextval                                   number;

BEGIN

        -- clear all previous messages.
        FND_MSG_PUB.Initialize;


--  investment_rec.strategic_obj_shortname := 'STROBJ' || l_seq_nextval;
    l_investment_rec.strategic_obj_name := p_strategic_obj_name;
    l_investment_rec.strategic_obj_desc := p_strategic_obj_desc;
    l_investment_rec.strategic_obj_parent := p_strategic_obj_parent;
    l_investment_rec.strategic_obj_level := p_strategic_obj_level;

        -- Attach the AW space read write.
        IF FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
                fnd_log.string
                (
                        FND_LOG.LEVEL_STATEMENT,
                        'fpa.sql.fpa_resourcetype_pvt.create_resourcetype',
                        'Attaching OLAP workspace: '
                );
        END IF;

     Fpa_Utilities_Pvt.attach_AW
                        (
                          p_api_version => 1.0,
                          p_attach_mode => 'rw',
                          x_return_status => x_return_status,
                          x_msg_count => x_msg_count,
                          x_msg_data => x_msg_data
                        );


        -- Call procedure to call Investment Criteria in AW
    fpa_investment_criteria_pvt.create_strategicobj_aw
    (
        p_commit => FND_API.G_TRUE,
        p_investment_rec_type => l_investment_rec,
                p_seeding => 'N',
                x_strategic_obj_id => l_stategic_obj_id,
        x_return_status => x_return_status,
        x_msg_count => x_msg_count,
        x_msg_data => x_msg_data
    );

        -- Call AW procedure to update the strategic_obj_status_r for the user
        -- created strategic objectives.  This will tel the UI what objectives
        -- may be deleted by the user.
        l_investment_rec.strategic_obj_status := 'DODELETE';
        l_investment_rec.strategic_obj_shortname := l_stategic_obj_id;
        FPA_Investment_Criteria_PVT.Update_StrategicObj_Status_AW(
                p_commit => FND_API.G_TRUE,
                p_investment_rec_type => l_investment_rec,
                x_return_status => x_return_status,
                x_msg_count => x_msg_count,
                x_msg_data => x_msg_data
        );

        FPA_Investment_Criteria_PVT.update_strategicobj_level_aw( p_commit
                                                                 ,l_investment_rec
                                                                 ,x_return_status
                                                                 ,x_msg_count
                                                                 ,x_msg_data);

    -- Update and commit our changes
    IF (p_commit = FND_API.G_TRUE) THEN
        dbms_aw.execute('UPDATE');
        COMMIT;
    END IF;

       -- Detach AW Workspace
       Fpa_Utilities_Pvt.detach_AW
                        (
                          p_api_version => 1.0,
                          x_return_status => x_return_status,
                          x_msg_count => x_msg_count,
                          x_msg_data => x_msg_data
                        );

EXCEPTION
    WHEN OTHERS THEN
       -- Detach AW Workspace
       Fpa_Utilities_Pvt.detach_AW
                        (
                          p_api_version => 1.0,
                          x_return_status => x_return_status,
                          x_msg_count => x_msg_count,
                          x_msg_data => x_msg_data
                        );
        ROLLBACK;
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        FND_MSG_PUB.Count_And_Get
        (
            p_count    =>      x_msg_count,
                        p_data     =>      x_msg_data
        );
        RAISE;

END create_strategicobj;

PROCEDURE delete_strategicobj
(   p_api_version       IN      NUMBER,
    p_commit            IN      VARCHAR2 := FND_API.G_FALSE,
    p_strategic_obj_shortname   IN      VARCHAR2,
    x_return_status                 OUT NOCOPY      VARCHAR2,
    x_msg_count                     OUT NOCOPY      NUMBER,
    x_msg_data                      OUT NOCOPY      VARCHAR2
)
AS
    l_investment_rec            fpa_investment_criteria_pvt.investment_rec_type;
    l_api_version            CONSTANT NUMBER    := 1.0;

BEGIN
    FND_MSG_PUB.Initialize;

    l_investment_rec.strategic_obj_shortname := p_strategic_obj_shortname;

    -- Attach the AW space read write.
    IF FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
    fnd_log.string ( FND_LOG.LEVEL_STATEMENT,
                    'fpa.sql.fpa_process_pvt.delete_strategicobj',
                    'Attaching OLAP workspace: ');
    END IF;

    Fpa_Utilities_Pvt.attach_AW( p_api_version => 1.0,
                                 p_attach_mode => 'rw',
                                 x_return_status => x_return_status,
                                 x_msg_count => x_msg_count,
                                 x_msg_data => x_msg_data);

    fpa_investment_criteria_pvt.delete_strategicobj_aw
    (
        p_api_version => p_api_version,
        p_investment_rec_type => l_investment_rec,
        x_return_status => x_return_status,
        x_msg_count => x_msg_count,
        x_msg_data => x_msg_data
    );

    -- Update and commit our changes
    IF (p_commit = FND_API.G_TRUE) THEN
      dbms_aw.execute('UPDATE');
      COMMIT;
    END IF;

    -- Detach AW Workspace
    Fpa_Utilities_Pvt.detach_AW(p_api_version => 1.0,
                                x_return_status => x_return_status,
                                x_msg_count => x_msg_count,
                                x_msg_data => x_msg_data);

EXCEPTION
    WHEN OTHERS THEN
        ROLLBACK;
       -- Detach AW Workspace
       Fpa_Utilities_Pvt.detach_AW
                        (
                          p_api_version => 1.0,
                          x_return_status => x_return_status,
                          x_msg_count => x_msg_count,
                          x_msg_data => x_msg_data
                        );

        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

        IF FND_LOG.LEVEL_ERROR >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
        FND_LOG.String
        (
            FND_LOG.LEVEL_ERROR,
            'fpa.sql.FPA_Process_Pvt.Update_Pc',
            SQLERRM
        );
        END IF;

        FND_MSG_PUB.count_and_get
        (
            p_count    =>      x_msg_count,
            p_data     =>      x_msg_data
        );
        RAISE;

END delete_strategicobj;

/*******************************************************************************************
*******************************************************************************************/

-- This procedures creates a new scenario.  Scenarios are almost always created by copying
-- from a source scenario.
-- This procedure expects the source scenario id, the planning cycle id for the source scenario
-- the new scenario name, and the new scenario description.
-- If the scenario source id is null then we are creating the initial scenario.

PROCEDURE create_scenario
(
        p_commit                        IN              VARCHAR2 := FND_API.G_FALSE,
        p_api_version                   IN              NUMBER,
        p_scenario_id_source            IN              NUMBER,
        p_pc_id                         IN              NUMBER,
        p_scenario_name                 IN              VARCHAR2,
        p_scenario_desc                 IN              VARCHAR2,
        p_copy_proposed_proj            IN              VARCHAR2,
        p_sce_disc_rate                 IN              VARCHAR2,
        p_sce_funds_avail               IN              VARCHAR2,
        x_scenario_id           OUT NOCOPY      VARCHAR2,
        x_return_status                 OUT NOCOPY      VARCHAR2,
        x_msg_count                     OUT NOCOPY      NUMBER,
        x_msg_data                      OUT NOCOPY      VARCHAR2
) is

l_api_version           NUMBER := 1.0;

l_sce_name_count    NUMBER;

l_data_to_calc      VARCHAR2(10); -- variable used for
                                      -- fpa_scenario_pvt.calc_scenario_data

l_projects_tbl           FPA_VALIDATION_PVT.PROJECT_ID_TBL_TYPE;

begin

  -- clear all previous messages.
  FND_MSG_PUB.Initialize;


  IF FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
    FND_LOG.String
    (
       FND_LOG.LEVEL_PROCEDURE,
       'fpa.sql.FPA_Process_Pvt.create_scenario.begin',
       'Entering FPA_Process_Pvt.create_scenario'
    );
  END IF;

  IF FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
    FND_LOG.String
    (
       FND_LOG.LEVEL_PROCEDURE,
       'fpa.sql.FPA_Process_Pvt.create_scenario',
       'Checking Scenario name does not exist for this planning cycle.'
    );
  END IF;

  -- Check name does not exist for this planning cycle
  l_sce_name_count := fpa_scenario_pvt.check_scenario_name
    (
      p_scenario_name => p_scenario_name,
      p_pc_id => p_pc_id,
      x_return_status => x_return_status,
      x_msg_count => x_msg_count,
      x_msg_data => x_msg_data
    );

  -- If Duplicate Scenario Name exists, then raise error and halt all execution
  IF l_sce_name_count > 0 THEN
    FND_MESSAGE.SET_NAME('FPA','FPA_DUPLICATE_SCE_NAME');
    FND_MESSAGE.SET_TOKEN('SCE_NAME', p_scenario_name);
    FND_MSG_PUB.ADD;
    RAISE FND_API.G_EXC_ERROR;
  END IF;

  IF FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
    FND_LOG.String
    (
       FND_LOG.LEVEL_PROCEDURE,
       'fpa.sql.FPA_Process_Pvt.create_scenario',
       'Attaching AW space.'
    );
  END IF;

  -- Attach AW Workspace
  Fpa_Utilities_Pvt.attach_AW
  (
    p_api_version => 1.0,
    p_attach_mode => 'rw',
    x_return_status => x_return_status,
    x_msg_count => x_msg_count,
    x_msg_data => x_msg_data
  );

  IF FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
    FND_LOG.String
    (
       FND_LOG.LEVEL_PROCEDURE,
       'fpa.sql.FPA_Process_Pvt.create_scenario',
       'Calling procedure fpa_scenario_pvt.create_scenario.'
    );
  END IF;

  -- Call procedure to crete scenario
  fpa_scenario_pvt.create_scenario
  (
        p_api_version => 1.0,
        p_scenario_name => p_scenario_name,
        p_scenario_desc => p_scenario_desc,
        p_pc_id => p_pc_id,
        x_scenario_id => x_scenario_id,
        x_return_status => x_return_status,
        x_msg_count => x_msg_count,
        x_msg_data => x_msg_data
  );

  IF FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
    FND_LOG.String
    (
       FND_LOG.LEVEL_PROCEDURE,
       'fpa.sql.FPA_Process_Pvt.create_scenario',
       'Calling fpa_scenario_pvt.copy_scenario_data.'
    );
  END IF;

  fpa_scenario_pvt.copy_scenario_data
  (
        p_api_version => 1.0,
        p_scenario_id_source => p_scenario_id_source,
        p_scenario_id_target => x_scenario_id,
        p_copy_proposed_proj => p_copy_proposed_proj,
        x_return_status => x_return_status,
        x_msg_count => x_msg_count,
        x_msg_data => x_msg_data
  );

  IF FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
    FND_LOG.String
    (
       FND_LOG.LEVEL_PROCEDURE,
       'fpa.sql.FPA_Process_Pvt.create_scenario',
       'Calling fpa_scenario_pvt.update_scenario_disc_rate.'
    );
  END IF;

  fpa_scenario_pvt.update_scenario_disc_rate
  (
    p_api_version => 1.0,
    p_scenario_id => x_scenario_id,
    p_discount_rate => p_sce_disc_rate,
    x_return_status => x_return_status,
    x_msg_count => x_msg_count,
    x_msg_data => x_msg_data
  );

  IF FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
    FND_LOG.String
    (
       FND_LOG.LEVEL_PROCEDURE,
       'fpa.sql.FPA_Process_Pvt.create_scenario',
       'Calling fpa_scenario_pvt.update_scenario_funds_avail.'
    );
  END IF;

  fpa_scenario_pvt.update_scenario_funds_avail
  (
    p_api_version => 1.0,
    p_scenario_id => x_scenario_id,
    p_scenario_funds => p_sce_funds_avail,
    x_return_status => x_return_status,
    x_msg_count => x_msg_count,
    x_msg_data => x_msg_data
  );

  IF FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
    FND_LOG.String
    (
       FND_LOG.LEVEL_PROCEDURE,
       'fpa.sql.FPA_Process_Pvt.create_scenario',
       'Calling fpa_scenario_pvt.calc_scenario_data for Project Financial Metrics.'
    );
  END IF;

  l_data_to_calc := 'PROJFIN';

  fpa_scenario_pvt.calc_scenario_data
  (
    p_api_version => 1.0,
    p_scenario_id => x_scenario_id,
    p_project_id => null,
    p_class_code_id => null,
    p_data_to_calc => l_data_to_calc,
    x_return_status => x_return_status,
    x_msg_count => x_msg_count,
    x_msg_data => x_msg_data
  );

  IF FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
    FND_LOG.String
    (
       FND_LOG.LEVEL_PROCEDURE,
       'fpa.sql.FPA_Process_Pvt.create_scenario',
       'Calling fpa_scenario_pvt.calc_scenario_data for Class Codes..'
    );
  END IF;

  l_data_to_calc := 'CLASS';

  fpa_scenario_pvt.calc_scenario_data
  (
    p_api_version => 1.0,
    p_scenario_id => x_scenario_id,
    p_project_id => null,
    p_class_code_id => null,
    p_data_to_calc => l_data_to_calc,
    x_return_status => x_return_status,
    x_msg_count => x_msg_count,
    x_msg_data => x_msg_data
  );

  IF FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
    FND_LOG.String
    (
       FND_LOG.LEVEL_PROCEDURE,
       'fpa.sql.FPA_Process_Pvt.create_scenario',
       'Calling fpa_scenario_pvt.calc_scenario_data for Scenario.'
    );
  END IF;

  l_data_to_calc := 'SCEN';

  fpa_scenario_pvt.calc_scenario_data
  (
    p_api_version => 1.0,
    p_scenario_id => x_scenario_id,
    p_project_id => null,
    p_class_code_id => null,
    p_data_to_calc => l_data_to_calc,
    x_return_status => x_return_status,
    x_msg_count => x_msg_count,
    x_msg_data => x_msg_data
  );

  IF FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
    FND_LOG.String
    (
       FND_LOG.LEVEL_PROCEDURE,
       'fpa.sql.FPA_Process_Pvt.create_scenario',
       'Calling fpa_scorecards_pvt.handle_comments.'
    );
  END IF;


  FPA_SCORECARDS_PVT.Handle_Comments(
          p_api_version         => 1.0,
          p_init_msg_list       => FND_API.G_TRUE,
          p_scenario_id         => x_scenario_id,
          p_type                => 'PJP',
          p_source_scenario_id  => p_scenario_id_source,
          p_delete_project_id   => null,
          x_return_status       => x_return_status,
          x_msg_count           => x_msg_count,
          x_msg_data            => x_msg_data);


  IF FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
    FND_LOG.String
    (
       FND_LOG.LEVEL_PROCEDURE,
       'fpa.sql.FPA_Process_Pvt.create_scenario',
       'Calling Fpa_Validation_Process_Pvt.Validate_Budget_Versions.'
    );
  END IF;

  FPA_VALIDATION_PROCESS_PVT.Budget_Version_Validations(
      p_api_version           =>  1.0,
      p_init_msg_list         =>  'F',
      p_validation_set        =>  'FPA_VALIDATION_TYPES',
      p_header_object_id      =>  x_scenario_id,
      p_header_object_type    =>  'SCENARIO',
      x_return_status         =>  x_return_status,
      x_msg_count             =>  x_msg_count,
      x_msg_data              =>  x_msg_data);

   IF FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
      FND_LOG.STRING
        (
        FND_LOG.LEVEL_PROCEDURE,
        'fpa.sql.FPA_Process_Pvt.create_scenario',
        'End Fpa_Validation_Process_Pvt.Validate_Budget_Versions.end'
        );
   END IF;

  if (x_return_status = FPA_UTILITIES_PVT.G_RET_STS_UNEXP_ERROR
      and FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) then
        FND_LOG.STRING
          (
          FND_LOG.LEVEL_PROCEDURE,
          'fpa.sql.Fpa_Validation_Process_Pvt.Validate_Budget_Versions',
          'unexpected error - create_scenario.Validate_Budget_Versions'
          );
  elsif (x_return_status = FPA_UTILITIES_PVT.G_RET_STS_ERROR
         and FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) then
        FND_LOG.STRING
          (
          FND_LOG.LEVEL_PROCEDURE,
          'fpa.sql.Fpa_Validation_Process_Pvt.Validate_Budget_Versions',
          'error - create_scenario.Validate_Budget_Versions'
          );
  end if;

  -- Update and commit our changes
  IF (p_commit = FND_API.G_TRUE) THEN
    dbms_aw.execute('UPDATE');
    COMMIT;
  END IF;

  IF FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
    FND_LOG.String
    (
       FND_LOG.LEVEL_PROCEDURE,
       'fpa.sql.FPA_Process_Pvt.create_scenario',
       'Detach AW space.'
    );
  END IF;

  -- Detach AW Workspace
  Fpa_Utilities_Pvt.detach_AW
  (
    p_api_version => 1.0,
    x_return_status => x_return_status,
    x_msg_count => x_msg_count,
    x_msg_data => x_msg_data
  );

EXCEPTION
  WHEN FND_API.G_EXC_ERROR THEN
    ROLLBACK;
    x_return_status := FND_API.G_RET_STS_ERROR;
    FND_MSG_PUB.Count_And_Get
    (
      p_count  =>      x_msg_count,
      p_data   =>      x_msg_data
    );
  WHEN OTHERS THEN
    -- Detach AW Workspace
    Fpa_Utilities_Pvt.detach_AW
    (
      p_api_version => 1.0,
      x_return_status => x_return_status,
      x_msg_count => x_msg_count,
      x_msg_data => x_msg_data
    );
    ROLLBACK;
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
  IF FND_LOG.LEVEL_ERROR >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
    FND_LOG.String
    (
      FND_LOG.LEVEL_ERROR,
      'fpa.sql.FPA_Process_Pvt.create_scenario',
      SQLERRM
    );
  END IF;
  FND_MSG_PUB.count_and_get
  (
    p_count    =>      x_msg_count,
    p_data     =>      x_msg_data
  );

END create_scenario;

/*******************************************************************************************
*******************************************************************************************/
-- This procedure sets the flag for the Initial Scenario, for the Working Scenario,
-- For Recommending a scenario, and for Unrecommending a scenario..
procedure set_scenario_action_flag
(
        p_commit                        IN              VARCHAR2 := FND_API.G_FALSE,
        p_api_version                   IN              NUMBER,
        p_scenario_id                   IN              NUMBER,
        p_scenario_action               IN              VARCHAR2,
        x_return_status                 OUT NOCOPY      VARCHAR2,
        x_msg_count                     OUT NOCOPY      NUMBER,
        x_msg_data                      OUT NOCOPY      VARCHAR2
) is

l_api_version               CONSTANT NUMBER := 1.0;
l_scenario_reccom_status        VARCHAR2(30);
l_approved_flag                 VARCHAR2(3);
begin

  -- clear all previous messages.
  FND_MSG_PUB.Initialize;

  IF FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
    FND_LOG.String
    (
       FND_LOG.LEVEL_PROCEDURE,
       'fpa.sql.FPA_Process_Pvt.set_scenario_action_flag.begin',
       'Entering FPA_Process_Pvt.set_scenario_action_flag'
    );
  END IF;

  IF FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
    FND_LOG.String
    (
       FND_LOG.LEVEL_PROCEDURE,
       'fpa.sql.FPA_Process_Pvt.set_scenario_action_flag',
       'Attaching AW space.'
    );
  END IF;

  -- Attach AW Workspace
  Fpa_Utilities_Pvt.attach_AW
  (
    p_api_version => 1.0,
    p_attach_mode => 'rw',
    x_return_status => x_return_status,
    x_msg_count => x_msg_count,
    x_msg_data => x_msg_data
  );

  IF FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
    FND_LOG.String
    (
       FND_LOG.LEVEL_PROCEDURE,
       'fpa.sql.FPA_Process_Pvt.set_scenario_action_flag',
       'Determininig what procedure to call based on p_scenario_action.'
    );
  END IF;

  if upper(p_scenario_action) = 'RECOMMEND' then
    IF FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
      FND_LOG.String
      (
         FND_LOG.LEVEL_PROCEDURE,
         'fpa.sql.FPA_Process_Pvt.set_scenario_action_flag',
         'Determininig what procedure to call based on p_scenario_action.'
      );
    END IF;
    l_scenario_reccom_status := 'yes';
    fpa_scenario_pvt.update_scenario_reccom_flag
    (
      p_api_version => 1.0,
      p_scenario_id => p_scenario_id,
      p_scenario_reccom_status => l_scenario_reccom_status,
      x_return_status => x_return_status,
      x_msg_count => x_msg_count,
      x_msg_data => x_msg_data
    );
  elsif upper(p_scenario_action) = 'APPROVE' then
    IF FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
      FND_LOG.String
      (
         FND_LOG.LEVEL_PROCEDURE,
         'fpa.sql.FPA_Process_Pvt.set_scenario_action_flag',
         'Determininig what procedure to call based on p_scenario_action.'
      );
    END IF;
    l_approved_flag := 'yes';
    fpa_scenario_pvt.update_scen_approved_flag
    ( p_scenario_id   => p_scenario_id,
      p_approved_flag => l_approved_flag,
      x_return_status => x_return_status,
      x_msg_count     => x_msg_count,
      x_msg_data      => x_msg_data
    );

  elsif upper(p_scenario_action) = 'WITHDRAW' then
    IF FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
      FND_LOG.String
      (
         FND_LOG.LEVEL_PROCEDURE,
         'fpa.sql.FPA_Process_Pvt.set_scenario_action_flag',
         'Determininig what procedure to call based on p_scenario_action.'
      );
    END IF;
     l_scenario_reccom_status := 'na';
    fpa_scenario_pvt.update_scenario_reccom_flag
    (
      p_api_version => 1.0,
      p_scenario_id => p_scenario_id,
      p_scenario_reccom_status => l_scenario_reccom_status,
      x_return_status => x_return_status,
      x_msg_count => x_msg_count,
      x_msg_data => x_msg_data
    );
  elsif upper(p_scenario_action) = 'SETCURRENT' then
    IF FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
      FND_LOG.String
      (
         FND_LOG.LEVEL_PROCEDURE,
         'fpa.sql.FPA_Process_Pvt.set_scenario_action_flag',
         'Determininig what procedure to call based on p_scenario_action.'
      );
    END IF;
    fpa_scenario_pvt.update_scenario_working_flag
    (
       p_api_version => 1.0,
       p_scenario_id => p_scenario_id,
       x_return_status => x_return_status,
       x_msg_count => x_msg_count,
       x_msg_data => x_msg_data
    );
  end if;

  IF FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
    FND_LOG.String
    (
       FND_LOG.LEVEL_PROCEDURE,
       'fpa.sql.FPA_Process_Pvt.set_scenario_action_flag',
       'Committing changes to database.'
    );
  END IF;

  -- Update and commit our changes
  IF (p_commit = FND_API.G_TRUE) THEN
    dbms_aw.execute('UPDATE');
    COMMIT;
  END IF;

  IF FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
    FND_LOG.String
    (
       FND_LOG.LEVEL_PROCEDURE,
       'fpa.sql.FPA_Process_Pvt.set_scenario_action_flag',
       'Detach AW space.'
    );
  END IF;

  -- Detach AW Workspace
  Fpa_Utilities_Pvt.detach_AW
  (
    p_api_version => 1.0,
    x_return_status => x_return_status,
    x_msg_count => x_msg_count,
    x_msg_data => x_msg_data
  );

EXCEPTION
  WHEN FND_API.G_EXC_ERROR THEN
    ROLLBACK;
    x_return_status := FND_API.G_RET_STS_ERROR;
    FND_MSG_PUB.Count_And_Get
    (
      p_count  =>      x_msg_count,
      p_data   =>      x_msg_data
    );
  WHEN OTHERS THEN
    -- Detach AW Workspace
    Fpa_Utilities_Pvt.detach_AW
    (
      p_api_version => 1.0,
      x_return_status => x_return_status,
      x_msg_count => x_msg_count,
      x_msg_data => x_msg_data
    );
    ROLLBACK;
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
  IF FND_LOG.LEVEL_ERROR >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
    FND_LOG.String
    (
      FND_LOG.LEVEL_ERROR,
      'fpa.sql.FPA_Process_Pvt.set_scenario_action_flag',
      SQLERRM
    );
  END IF;
  FND_MSG_PUB.count_and_get
  (
    p_count    =>      x_msg_count,
    p_data     =>      x_msg_data
  );

end set_scenario_action_flag;

procedure update_scenario_reccom_status
(
  p_commit                        IN              VARCHAR2 := FND_API.G_FALSE,
  p_api_version                 IN              NUMBER,
  p_scenario_id                 IN              NUMBER,
  p_project_id                  IN              VARCHAR2,
  p_scenario_reccom_value       IN              VARCHAR2,
  x_return_status               OUT NOCOPY      VARCHAR2,
  x_msg_count                   OUT NOCOPY      NUMBER,
  x_msg_data                    OUT NOCOPY      VARCHAR2
) is

l_api_version               CONSTANT NUMBER := 1.0;

begin

  -- clear all previous messages.
  FND_MSG_PUB.Initialize;


  IF FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
    FND_LOG.String
    (
       FND_LOG.LEVEL_PROCEDURE,
       'fpa.sql.FPA_Process_Pvt.update_scenario_reccom_status.begin',
       'Entering FPA_Process_Pvt.update_scenario_reccom_status'
    );
  END IF;

  IF FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
    FND_LOG.String
    (
       FND_LOG.LEVEL_PROCEDURE,
       'fpa.sql.FPA_Process_Pvt.update_scenario_reccom_status',
       'Attaching AW space.'
    );
  END IF;

  -- Attach AW Workspace
  Fpa_Utilities_Pvt.attach_AW
  (
    p_api_version => 1.0,
    p_attach_mode => 'rw',
    x_return_status => x_return_status,
    x_msg_count => x_msg_count,
    x_msg_data => x_msg_data
  );

  IF FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
    FND_LOG.String
    (
       FND_LOG.LEVEL_PROCEDURE,
       'fpa.sql.FPA_Process_Pvt.update_scenario_reccom_status',
       'Calling procedure fpa_scenario_pvt.update_scenario_reccom_status.'
    );
  END IF;

  fpa_scenario_pvt.update_scenario_reccom_status
  (
    p_api_version => 1.0,
    p_scenario_id => p_scenario_id,
    p_project_id => p_project_id,
    p_scenario_reccom_value => p_scenario_reccom_value,
    x_return_status => x_return_status,
    x_msg_count => x_msg_count,
    x_msg_data => x_msg_data
  );

  IF FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
    FND_LOG.String
    (
       FND_LOG.LEVEL_PROCEDURE,
       'fpa.sql.FPA_Process_Pvt.update_scenario_reccom_status',
       'Calling procedure fpa_scenario_pvt.calc_scenario_data for Class Codes.'
    );
  END IF;

  fpa_scenario_pvt.calc_scenario_data
  (
        p_api_version => 1.0,
        p_scenario_id => p_scenario_id,
        p_project_id => null,
        p_class_code_id => null,
        p_data_to_calc => 'CLASS',
        x_return_status => x_return_status,
        x_msg_count => x_msg_count,
        x_msg_data => x_msg_data
  );

  IF FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
    FND_LOG.String
    (
       FND_LOG.LEVEL_PROCEDURE,
       'fpa.sql.FPA_Process_Pvt.update_scenario_reccom_status',
       'Calling procedure fpa_scenario_pvt.calc_scenario_data for Scenario.'
    );
  END IF;

  fpa_scenario_pvt.calc_scenario_data
  (
        p_api_version => 1.0,
        p_scenario_id => p_scenario_id,
        p_project_id => null,
        p_class_code_id => null,
        p_data_to_calc => 'SCEN',
        x_return_status => x_return_status,
        x_msg_count => x_msg_count,
        x_msg_data => x_msg_data
  );

  IF FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
    FND_LOG.String
    (
       FND_LOG.LEVEL_PROCEDURE,
       'fpa.sql.FPA_Process_Pvt.update_scenario_reccom_status',
       'Committing changes to database.'
    );
  END IF;

  -- Update and commit our changes
  IF (p_commit = FND_API.G_TRUE) THEN
    dbms_aw.execute('UPDATE');
    COMMIT;
  END IF;

  IF FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
    FND_LOG.String
    (
       FND_LOG.LEVEL_PROCEDURE,
       'fpa.sql.FPA_Process_Pvt.update_scenario_reccom_status',
       'Detach AW space.'
    );
  END IF;

  -- Detach AW Workspace
  Fpa_Utilities_Pvt.detach_AW
  (
    p_api_version => 1.0,
    x_return_status => x_return_status,
    x_msg_count => x_msg_count,
    x_msg_data => x_msg_data
  );

EXCEPTION
  WHEN FND_API.G_EXC_ERROR THEN
    ROLLBACK;
    x_return_status := FND_API.G_RET_STS_ERROR;
    FND_MSG_PUB.Count_And_Get
    (
      p_count  =>      x_msg_count,
      p_data   =>      x_msg_data
    );
  WHEN OTHERS THEN
    -- Detach AW Workspace
    Fpa_Utilities_Pvt.detach_AW
    (
      p_api_version => 1.0,
      x_return_status => x_return_status,
      x_msg_count => x_msg_count,
      x_msg_data => x_msg_data
    );
    ROLLBACK;
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
  IF FND_LOG.LEVEL_ERROR >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
    FND_LOG.String
    (
      FND_LOG.LEVEL_ERROR,
      'fpa.sql.FPA_Process_Pvt.update_scenario_reccom_status',
      SQLERRM
    );
  END IF;
  FND_MSG_PUB.count_and_get
  (
    p_count    =>      x_msg_count,
    p_data     =>      x_msg_data
  );

END update_scenario_reccom_status;

PROCEDURE Submit_Project_Aw
(
    p_api_version           IN              NUMBER,
    p_init_msg_list         IN              VARCHAR2,
    p_commit                IN              VARCHAR2,
    p_project_id            IN              NUMBER,
    x_return_status         OUT NOCOPY      VARCHAR2,
    x_msg_count             OUT NOCOPY      NUMBER,
    x_msg_data              OUT NOCOPY      VARCHAR2
) IS

  l_return_status          VARCHAR2(1);
  l_api_name               CONSTANT VARCHAR2(30) := 'Submit_Project_Aw';
  l_api_version            CONSTANT NUMBER       := 1.0;
  l_msg_log                VARCHAR2(200)         := null;

  CURSOR PROJ_FUNDING_STATUS_CSR(P_PROJECT_ID IN NUMBER) IS
    SELECT 'T'
    FROM PA_PROJECTS_ALL
    WHERE PROJECT_ID = P_PROJECT_ID
          AND FUNDING_APPROVAL_STATUS_CODE IN
          ('FUNDING_PROPOSED','FUNDING_ONHOLD','FUNDING_APPROVED');

  l_flag VARCHAR2(1) := null;

BEGIN


      x_return_status := FPA_UTILITIES_PVT.G_RET_STS_SUCCESS;
        -- call START_ACTIVITY to create savepoint, check compatibility
        -- and initialize message list

      x_return_status := FPA_UTILITIES_PVT.START_ACTIVITY(
              p_api_name      => l_api_name,
              p_pkg_name      => G_PKG_NAME,
              p_init_msg_list => p_init_msg_list,
              l_api_version   => l_api_version,
              p_api_version   => p_api_version,
              p_api_type      => G_API_TYPE,
              p_msg_log       => 'Entering Fpa_Process_Pvt.Submit_Project_Aw',
              x_return_status => x_return_status);


        -- check if activity started successfully
      if (x_return_status = FPA_UTILITIES_PVT.G_RET_STS_UNEXP_ERROR) then
           l_msg_log := 'start_activity';
           raise FPA_UTILITIES_PVT.G_EXCEPTION_UNEXPECTED_ERROR;
      elsif (x_return_status = FPA_UTILITIES_PVT.G_RET_STS_ERROR) then
           l_msg_log := 'start_activity';
           raise FPA_UTILITIES_PVT.G_EXCEPTION_ERROR;
      end if;

      FPA_UTILITIES_PVT.Attach_AW
                        (p_api_version => l_api_version,
                         p_attach_mode => 'rw',
                         x_return_status => x_return_status,
                         x_msg_count => x_msg_count,
                         x_msg_data => x_msg_data);


      x_return_status := FPA_UTILITIES_PVT.G_RET_STS_SUCCESS;

      FPA_PROJECT_PVT.Submit_Project_Aw(
                      p_api_version        => p_api_version,
                      p_init_msg_list      => p_init_msg_list,
                      p_commit             => p_commit,
                      p_project_id         => p_project_id,
                      x_return_status      => x_return_status,
                      x_msg_count          => x_msg_count,
                      x_msg_data           => x_msg_data);

     FPA_UTILITIES_PVT.Detach_AW
                        (p_api_version => 1.0,
                         x_return_status => x_return_status,
                         x_msg_count => x_msg_count,
                         x_msg_data => x_msg_data);

    x_return_status := FPA_UTILITIES_PVT.G_RET_STS_SUCCESS;

    FPA_UTILITIES_PVT.END_ACTIVITY(
                    p_api_name     => l_api_name,
                    p_pkg_name     => G_PKG_NAME,
                    p_msg_log      => null,
                    x_msg_count    => x_msg_count,
                    x_msg_data     => x_msg_data);

EXCEPTION
      when FPA_UTILITIES_PVT.G_EXCEPTION_ERROR then

           FPA_UTILITIES_PVT.Detach_AW(
                             p_api_version => l_api_version,
                             x_return_status => x_return_status,
                             x_msg_count => x_msg_count,
                             x_msg_data => x_msg_data);

           x_return_status := FPA_UTILITIES_PVT.HANDLE_EXCEPTIONS(
                p_api_name  => l_api_name,
                p_pkg_name  => G_PKG_NAME,
                p_exc_name  => 'FPA_UTILITIES_PVT.G_RET_STS_ERROR',
                p_msg_log   => l_msg_log,
                x_msg_count => x_msg_count,
                x_msg_data  => x_msg_data,
                p_api_type  => G_API_TYPE);

      when FPA_UTILITIES_PVT.G_EXCEPTION_UNEXPECTED_ERROR then

           FPA_UTILITIES_PVT.Detach_AW(
                             p_api_version => l_api_version,
                             x_return_status => x_return_status,
                             x_msg_count => x_msg_count,
                             x_msg_data => x_msg_data);

            x_return_status := FPA_UTILITIES_PVT.HANDLE_EXCEPTIONS(
                p_api_name  => l_api_name,
                p_pkg_name  => G_PKG_NAME,
                p_exc_name  => 'FPA_UTILITIES_PVT.G_RET_STS_UNEXP_ERROR',
                p_msg_log   => l_msg_log,
                x_msg_count => x_msg_count,
                x_msg_data  => x_msg_data,
                p_api_type  => G_API_TYPE);

      when OTHERS then

           FPA_UTILITIES_PVT.Detach_AW(
                             p_api_version => l_api_version,
                             x_return_status => x_return_status,
                             x_msg_count => x_msg_count,
                             x_msg_data => x_msg_data);

         x_return_status := FPA_UTILITIES_PVT.HANDLE_EXCEPTIONS(
                p_api_name  => l_api_name,
                p_pkg_name  => G_PKG_NAME,
                p_exc_name  => 'OTHERS',
                p_msg_log   => l_msg_log||SQLERRM,
                x_msg_count => x_msg_count,
                x_msg_data  => x_msg_data,
                p_api_type  => G_API_TYPE);

END Submit_Project_Aw;

PROCEDURE Load_Project_Details_Aw
(
    p_api_version           IN              NUMBER,
    p_init_msg_list         IN              VARCHAR2 DEFAULT FND_API.G_FALSE,
    p_commit                IN              VARCHAR2,
    p_type                  IN              VARCHAR2,
    p_scenario_id           IN              NUMBER,
    p_projects              IN              VARCHAR2,
    x_return_status         OUT NOCOPY      VARCHAR2,
    x_msg_count             OUT NOCOPY      NUMBER,
    x_msg_data              OUT NOCOPY      VARCHAR2) IS

  l_return_status          VARCHAR2(1);
  l_api_name               CONSTANT VARCHAR2(30) := 'Load_Project_Details_Aw';
  l_api_version            CONSTANT NUMBER       := 1.0;
  l_msg_log                VARCHAR2(200)         := null;

BEGIN

      x_return_status := FPA_UTILITIES_PVT.G_RET_STS_SUCCESS;
        -- call START_ACTIVITY to create savepoint, check compatibility
        -- and initialize message list

      x_return_status := FPA_UTILITIES_PVT.START_ACTIVITY(
              p_api_name      => l_api_name,
              p_pkg_name      => G_PKG_NAME,
              p_init_msg_list => p_init_msg_list,
              l_api_version   => l_api_version,
              p_api_version   => p_api_version,
              p_api_type      => G_API_TYPE,
              p_msg_log       => 'Entering Fpa_Process_Pvt.Load_Project_Details_Aw',
              x_return_status => x_return_status);


        -- check if activity started successfully
      if (x_return_status = FPA_UTILITIES_PVT.G_RET_STS_UNEXP_ERROR) then
           l_msg_log := 'start_activity';
           raise FPA_UTILITIES_PVT.G_EXCEPTION_UNEXPECTED_ERROR;
      elsif (x_return_status = FPA_UTILITIES_PVT.G_RET_STS_ERROR) then
           l_msg_log := 'start_activity';
           raise FPA_UTILITIES_PVT.G_EXCEPTION_ERROR;
      end if;

      FPA_UTILITIES_PVT.Attach_AW
                        (p_api_version => l_api_version,
                         p_attach_mode => 'rw',
                         x_return_status => x_return_status,
                         x_msg_count => x_msg_count,
                         x_msg_data => x_msg_data);


      x_return_status := FPA_UTILITIES_PVT.G_RET_STS_SUCCESS;


      FPA_PROJECT_PVT.Load_Project_Details_Aw(
                      p_api_version        => p_api_version,
                      p_init_msg_list      => p_init_msg_list,
                      p_type               => p_type,
                      p_scenario_id        => p_scenario_id,
                      p_projects           => p_projects,
                      x_return_status      => x_return_status,
                      x_msg_count          => x_msg_count,
                      x_msg_data           => x_msg_data);


      if (p_commit = FND_API.G_TRUE) then
        dbms_aw.execute('UPDATE');
        COMMIT;
      end if;

      FPA_UTILITIES_PVT.Detach_AW
                        (p_api_version => 1.0,
                         x_return_status => x_return_status,
                         x_msg_count => x_msg_count,
                         x_msg_data => x_msg_data);

    x_return_status := FPA_UTILITIES_PVT.G_RET_STS_SUCCESS;

    FPA_UTILITIES_PVT.END_ACTIVITY(
                    p_api_name     => l_api_name,
                    p_pkg_name     => G_PKG_NAME,
                    p_msg_log      => null,
                    x_msg_count    => x_msg_count,
                    x_msg_data     => x_msg_data);

EXCEPTION
      when FPA_UTILITIES_PVT.G_EXCEPTION_ERROR then

           FPA_UTILITIES_PVT.Detach_AW(
                             p_api_version => l_api_version,
                             x_return_status => x_return_status,
                             x_msg_count => x_msg_count,
                             x_msg_data => x_msg_data);

           x_return_status := FPA_UTILITIES_PVT.HANDLE_EXCEPTIONS(
                p_api_name  => l_api_name,
                p_pkg_name  => G_PKG_NAME,
                p_exc_name  => 'FPA_UTILITIES_PVT.G_RET_STS_ERROR',
                p_msg_log   => l_msg_log,
                x_msg_count => x_msg_count,
                x_msg_data  => x_msg_data,
                p_api_type  => G_API_TYPE);

      when FPA_UTILITIES_PVT.G_EXCEPTION_UNEXPECTED_ERROR then

           FPA_UTILITIES_PVT.Detach_AW(
                             p_api_version => l_api_version,
                             x_return_status => x_return_status,
                             x_msg_count => x_msg_count,
                             x_msg_data => x_msg_data);

            x_return_status := FPA_UTILITIES_PVT.HANDLE_EXCEPTIONS(
                p_api_name  => l_api_name,
                p_pkg_name  => G_PKG_NAME,
                p_exc_name  => 'FPA_UTILITIES_PVT.G_RET_STS_UNEXP_ERROR',
                p_msg_log   => l_msg_log,
                x_msg_count => x_msg_count,
                x_msg_data  => x_msg_data,
                p_api_type  => G_API_TYPE);

      when OTHERS then

           FPA_UTILITIES_PVT.Detach_AW(
                             p_api_version => l_api_version,
                             x_return_status => x_return_status,
                             x_msg_count => x_msg_count,
                             x_msg_data => x_msg_data);

         x_return_status := FPA_UTILITIES_PVT.HANDLE_EXCEPTIONS(
                p_api_name  => l_api_name,
                p_pkg_name  => G_PKG_NAME,
                p_exc_name  => 'OTHERS',
                p_msg_log   => l_msg_log||SQLERRM,
                x_msg_count => x_msg_count,
                x_msg_data  => x_msg_data,
                p_api_type  => G_API_TYPE);

END Load_Project_Details_Aw;


/********************************************************************************************
********************************************************************************************/

PROCEDURE Close_Pc
(
    p_api_version           IN              NUMBER,
    p_commit                IN              VARCHAR2 DEFAULT FND_API.G_FALSE,
    p_pc_id                 IN              NUMBER,
    x_return_status         OUT NOCOPY      VARCHAR2,
    x_msg_count             OUT NOCOPY      NUMBER,
    x_msg_data              OUT NOCOPY      VARCHAR2
) is

begin

  -- clear all previous messages.
  FND_MSG_PUB.Initialize;

  IF FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
    fnd_log.string
    (
     FND_LOG.LEVEL_PROCEDURE,
     'fpa.sql.fpa_process_pvt.close_pc.begin',
     'Entering fpa_process_pvt.close_pc ,Calling Fpa_Utilities_Pvt.attach_AW'
    );
  END IF;

  -- Attach AW Workspace
  Fpa_Utilities_Pvt.attach_AW
  (
   p_api_version => 1.0,
   p_attach_mode => 'rw',
   x_return_status => x_return_status,
   x_msg_count => x_msg_count,
   x_msg_data => x_msg_data
  );


  IF FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
    fnd_log.string
    (
     FND_LOG.LEVEL_STATEMENT,
     'fpa.sql.fpa_process_pvt.close_pc.begin',
     'Calling fpa_main_process_pvt.raise_closepc_event'
    );
  END IF;

  fpa_main_process_pvt.raise_closepc_event( p_pc_id => p_pc_id,
                                x_return_status => x_return_status,
                                x_msg_count => x_msg_count,
                                x_msg_data  => x_msg_data
                                   );

  -- Update and commit our changes
  IF (p_commit = FND_API.G_TRUE) THEN
      IF FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
        FND_LOG.String
        ( FND_LOG.LEVEL_PROCEDURE,
          'fpa.sql.FPA_Process_Pvt.Close_Pc',
          'Updating and Committing.'
        );
      END IF;
      dbms_aw.execute('UPDATE');
      COMMIT;
  END IF;

  IF FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
        FND_LOG.String
        ( FND_LOG.LEVEL_PROCEDURE,
          'fpa.sql.FPA_Process_Pvt.Close_Pc',
          'CAlling Fpa_Utilities_Pvt.detach_AW.'
        );
  END IF;

  -- Detach AW Workspace
  Fpa_Utilities_Pvt.detach_AW
  (
    p_api_version => 1.0,
    x_return_status => x_return_status,
    x_msg_count => x_msg_count,
    x_msg_data => x_msg_data
  );

  IF FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
    FND_LOG.String
    (
     FND_LOG.LEVEL_PROCEDURE,
     'fpa.sql.FPA_Process_Pvt.Close_Pc.end',
     'Exiting FPA_Process_Pvt.Close_Pc'
    );
  END IF;

  EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN
      ROLLBACK;
      x_return_status := FND_API.G_RET_STS_ERROR;
      IF FND_LOG.LEVEL_ERROR >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
        fnd_log.string
        (FND_LOG.LEVEL_ERROR,
         'fpa_process_pvt.create_portfolio',
         SQLERRM);
      END IF;
      FND_MSG_PUB.Count_And_Get( p_count  =>      x_msg_count
                             ,p_data   =>      x_msg_data);
  WHEN OTHERS THEN
    FND_MESSAGE.SET_NAME('FPA','FPA_UNEXP_GENERAL_ERROR');
    FND_MESSAGE.SET_TOKEN('SOURCE', 'fpa_process_pvt.Close_Pc');
    FND_MESSAGE.SET_TOKEN('SQL_ERR_CODE', SQLCODE);
    FND_MESSAGE.SET_TOKEN('SQL_ERR_MSG', SQLERRM);
    FND_MSG_PUB.ADD;
    -- Detach AW Workspace
    Fpa_Utilities_Pvt.detach_AW
    ( p_api_version => 1.0,
      x_return_status => x_return_status,
      x_msg_count => x_msg_count,
      x_msg_data => x_msg_data
    );
    ROLLBACK;
    x_return_status := FND_API.G_RET_STS_ERROR;
    IF FND_LOG.LEVEL_ERROR >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
      fnd_log.string
      ( FND_LOG.LEVEL_ERROR,
        'fpa_process_pvt.Close_Pc',
        SQLERRM);
    END IF;
    FND_MSG_PUB.count_and_get
    ( p_count    =>      x_msg_count,
      p_data     =>      x_msg_data);

end Close_Pc;


/*
 * Updates user ranks for all projects in the current scenario.
 */

PROCEDURE Update_Scen_Proj_User_Ranks
     ( p_api_version        IN NUMBER,
       p_commit             IN VARCHAR2 := FND_API.G_FALSE,
       p_projs              IN fpa_scen_proj_userrank_all_obj,
       x_return_status      OUT NOCOPY VARCHAR2,
       x_msg_data           OUT NOCOPY VARCHAR2,
       x_msg_count          OUT NOCOPY NUMBER )
IS
BEGIN

  -- clear all previous messages.
    FND_MSG_PUB.Initialize;

    IF FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
        FND_LOG.String
        (
            FND_LOG.LEVEL_PROCEDURE,
            'fpa.sql.FPA_Process_Pvt.Update_Scen_Proj_User_Ranks.begin',
            'Entering FPA_Process_Pvt.Update_Scen_Proj_User_Ranks'
        );
    END IF;

    -- Attach AW Workspace
     Fpa_Utilities_Pvt.attach_AW
                        (
                          p_api_version => 1.0,
                          p_attach_mode => 'rw',
                          x_return_status => x_return_status,
                          x_msg_count => x_msg_count,
                          x_msg_data => x_msg_data
                        );

     FPA_Scenario_Pvt.Update_Proj_User_Ranks
               (
                p_api_version => 1.0,
                p_proj_metrics => p_projs.user_ranks,
                x_return_status  =>  x_return_status,
                x_msg_data   =>  x_msg_data,
                x_msg_count  =>  x_msg_count
              );

     -- Update and commit our changes
     IF (p_commit = FND_API.G_TRUE) THEN
         dbms_aw.execute('UPDATE');
         COMMIT;
     END IF;

     -- Detach AW Workspace
     Fpa_Utilities_Pvt.detach_AW
                        (
                          p_api_version => 1.0,
                          x_return_status => x_return_status,
                          x_msg_count => x_msg_count,
                          x_msg_data => x_msg_data
                        );
     IF FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
        FND_LOG.String
        (
            FND_LOG.LEVEL_PROCEDURE,
            'fpa.sql.FPA_Process_Pvt.Update_Scen_Proj_User_Ranks.end',
            'Exiting FPA_Process_Pvt.Update_Scen_Proj_User_Ranks'
        );
     END IF;


EXCEPTION
    WHEN OTHERS THEN
        FND_MESSAGE.SET_NAME('FPA','FPA_UNEXP_GENERAL_ERROR');
        FND_MESSAGE.SET_TOKEN('SOURCE', 'fpa.sql.FPA_Process_Pvt.Update_Scen_Proj_User_Ranks');
        FND_MESSAGE.SET_TOKEN('SQL_ERR_CODE', SQLCODE);
        FND_MESSAGE.SET_TOKEN('SQL_ERR_MSG', SQLERRM);
        FND_MSG_PUB.ADD;
        ROLLBACK;
            -- Detach AW Workspace
       Fpa_Utilities_Pvt.detach_AW
                        (
                          p_api_version => 1.0,
                          x_return_status => x_return_status,
                          x_msg_count => x_msg_count,
                          x_msg_data => x_msg_data
                        );

        x_return_status := FND_API.G_RET_STS_ERROR;

        IF FND_LOG.LEVEL_ERROR >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
        FND_LOG.String
        (
            FND_LOG.LEVEL_ERROR,
            'fpa.sql.FPA_Process_Pvt.Update_Scen_Proj_User_Ranks',
            SQLERRM
        );
        END IF;

        FND_MSG_PUB.count_and_get
        (
            p_count    =>      x_msg_count,
            p_data     =>      x_msg_data
        );
        RAISE;
END Update_Scen_Proj_User_Ranks;


-- sishanmu  added on 01/25/2005
PROCEDURE update_pjt_proj_funding_status
     (  p_api_version        IN NUMBER,
        p_init_msg_list      IN VARCHAR2,
        p_commit             IN VARCHAR2,
        p_scenario_id        IN NUMBER,
        x_return_status      OUT NOCOPY      VARCHAR2,
        x_msg_count          OUT NOCOPY      NUMBER,
        x_msg_data           OUT NOCOPY      VARCHAR2) IS

BEGIN

     IF FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
        FND_LOG.String
        (
            FND_LOG.LEVEL_PROCEDURE,
            'fpa.sql.FPA_Process_Pvt.update_pjt_proj_funding_status.Begin',
            'Exiting FPA_Process_Pvt.update_pjt_proj_funding_status'
        );
     END IF;

    x_return_status := FND_API.G_RET_STS_SUCCESS;

     fpa_project_pvt.update_proj_funding_status
           (
                p_api_version => 1.0,
                p_init_msg_list => p_init_msg_list,
                p_commit => FND_API.G_FALSE,
                p_appr_scenario_id => p_scenario_id,
                x_return_status  =>  x_return_status,
                x_msg_count  =>  x_msg_count,
                x_msg_data   =>  x_msg_data
                );

     if x_return_status = FND_API.G_RET_STS_ERROR then
        RAISE FND_API.G_EXC_ERROR;
       elsif x_return_status = FND_API.G_RET_STS_UNEXP_ERROR then
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
     end if;

     IF p_commit = FND_API.G_TRUE THEN
       COMMIT;
     END IF;

     IF FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
        FND_LOG.String
        (
            FND_LOG.LEVEL_PROCEDURE,
            'fpa.sql.FPA_Process_Pvt.update_pjt_proj_funding_status.end',
            'Exiting FPA_Process_Pvt.update_pjt_proj_funding_status'
        );
     END IF;


EXCEPTION
      when FND_API.G_EXC_ERROR then
        IF p_commit = FND_API.G_TRUE THEN
         ROLLBACK;
        END IF;
      x_return_status := 'E';

    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN

      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      fnd_msg_pub.add_exc_msg(p_pkg_name       => 'FPA_PROCESS_PVT',
                            p_procedure_name => 'UPDATE_PJT_PROJ_FUNDING_STATUS',
                            p_error_text     => SUBSTRB(SQLERRM,1,240));


      IF p_commit = FND_API.G_TRUE THEN
       ROLLBACK;
      END IF;

      RAISE;

    WHEN OTHERS THEN
      IF p_commit = FND_API.G_TRUE THEN
       ROLLBACK;
      END IF;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      fnd_msg_pub.add_exc_msg(p_pkg_name       => 'FPA_PROCESS_PVT',
                            p_procedure_name => 'UPDATE_PJT_PROJ_FUNDING_STATUS',
                            p_error_text     => SUBSTRB(SQLERRM,1,240));

     RAISE;

END update_pjt_proj_funding_status;

-- Function call returns 'T' or 'F' to enable or disable Scorecard link
-- in project Setup
FUNCTION proj_scorecard_link_enabled
(   p_function_name     IN  VARCHAR2,
    p_project_id        IN  NUMBER)
 RETURN VARCHAR2 IS

   l_licensed_flag varchar2(1) := 'F';
   l_pc_active_flag varchar2(1) := 'F';
   l_enabled_flag varchar2(1) := 'F';
   l_active_pc_count number(15);
   FPA_PJP_NOT_LICENSED EXCEPTION;

-- Cursor checks for Active planning cycles in the portfolio that the project belongs to.
   cursor c_pc_active is
     select count(a.project) Validpc
       from fpa_aw_projs_v a,
       fpa_aw_pcs_v b,
       fpa_aw_pc_info_v c
       where a.portfolio = b.portfolio
       and b.planning_cycle = c.planning_cycle
       and c.pc_status in ('COLLECTING', 'ANALYSIS')
       and a.project = p_project_id;

 BEGIN

    IF FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
       FND_LOG.String
         (
          FND_LOG.LEVEL_PROCEDURE,
          'fpa.sql.FPA_Process_Pvt.proj_scorecard_link_enabled.Begin',
          'Calling procedure FPA_Process_Pvt.proj_scorecard_link_enabled.'
         );
    END IF;

-- Check for Licensing profile option
-- If the function returned 'N', Licensing is TURNED OFF.
-- Scorelink should not be enabled. No need to check for active planning cycles.
-- Raise an Exception, return 'F', and exit the program
    IF pa_product_install_utils.check_function_licensed(p_function_name) <> 'Y' then
       l_enabled_flag := 'F';

       IF FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
                FND_LOG.String
                ( FND_LOG.LEVEL_STATEMENT,
                'fpa.sql.FPA_Process_Pvt.proj_scorecard_link_enabled',
                'PJP License for Function '||p_function_name||' = NO. Disable Scorecard Link'
                );
       END IF;

       raise FPA_PJP_NOT_LICENSED;
    end if;

-- Licensing is available for PJP
-- Now look for active planning cycle.
-- If an active planning cycle exists, set enabled flag to 'T'
-- Score card link should be ebabled.
    open c_pc_active;
     fetch c_pc_active into l_active_pc_count;
     if (l_active_pc_count > 0) and (FPA_PROJECT_PVT.valid_project(p_project_id) = FND_API.G_TRUE) then
     -- active pl cycle exists for this project.
     -- Project classfications match the correct portfolio and planning cycle.
        l_enabled_flag := 'T';

        IF FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
                FND_LOG.String
                ( FND_LOG.LEVEL_STATEMENT,
                'fpa.sql.FPA_Process_Pvt.proj_scorecard_link_enabled',
                'ProjectID = '||p_project_id||' Planing Cycle is active. Enable Scorecard link'
                );
        END IF;

      else
-- Licensing is available for PJP but, no active planning cycle exist.
-- Scorecard link should be disabled
        IF FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
                FND_LOG.String
                ( FND_LOG.LEVEL_STATEMENT,
                'fpa.sql.FPA_Process_Pvt.proj_scorecard_link_enabled',
                'ProjectID = '||p_project_id||' No active Planning Cycle. Disable Scorecard link'
                );
        END IF;

      end if;
    close c_pc_active;

    IF FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
        FND_LOG.String
        (
            FND_LOG.LEVEL_PROCEDURE,
            'fpa.sql.FPA_Process_Pvt.proj_scorecard_link_enabled.end',
            'Exiting FPA_Process_Pvt.proj_scorecard_link_enabled'
        );
    END IF;

    RETURN l_enabled_flag;

 EXCEPTION
    WHEN FPA_PJP_NOT_LICENSED then
       IF FND_LOG.LEVEL_EXCEPTION >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
                FND_LOG.String
                ( FND_LOG.LEVEL_EXCEPTION,
                'fpa.sql.FPA_Process_Pvt.proj_scorecard_link_enabled',
                'PJP Not Licensed. Score Link should be disabled'
                );
       END IF;

      RETURN l_enabled_flag;

    when OTHERS then
       IF FND_LOG.LEVEL_ERROR >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
                FND_LOG.String
                ( FND_LOG.LEVEL_ERROR,
                'fpa.sql.FPA_Process_Pvt.proj_scorecard_link_enabled',
                'Score Link should be disabled for ProjectID '||p_project_id
                );
       END IF;
       IF FND_LOG.LEVEL_ERROR >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
                FND_LOG.String
                ( FND_LOG.LEVEL_ERROR,
                'fpa.sql.FPA_Process_Pvt.proj_scorecard_link_enabled',
                SQLERRM
                );
       END IF;

     RETURN l_enabled_flag;

 END proj_scorecard_link_enabled;

END FPA_PROCESS_PVT;

/
