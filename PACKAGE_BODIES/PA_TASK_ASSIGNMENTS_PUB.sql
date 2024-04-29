--------------------------------------------------------
--  DDL for Package Body PA_TASK_ASSIGNMENTS_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PA_TASK_ASSIGNMENTS_PUB" AS
-- $Header: PATAPUBB.pls 120.8.12010000.7 2010/02/12 08:57:43 sugupta ship $


  G_PKG_NAME      CONSTANT VARCHAR2(30) := 'PA_TASK_ASSIGNMENTS_PUB';
  g_periodic_mode          varchar2(1)  := null;
  P_DEBUG_MODE varchar2(1) := NVL(FND_PROFILE.value('PA_DEBUG_MODE'), 'N');
  li_curr_level NUMBER := FND_LOG.G_CURRENT_RUNTIME_LEVEL;

PROCEDURE Load_Task_Assignments
( p_api_version_number       IN NUMBER            := PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM
 ,p_commit                               IN VARCHAR2          := FND_API.G_FALSE
 ,p_init_msg_list                IN VARCHAR2          := FND_API.G_FALSE
 ,p_pm_project_reference     IN PA_VC_1000_25     := PA_VC_1000_25(PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR)
 ,p_pa_project_id                IN PA_num_1000_num   := PA_num_1000_num(PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM)
 ,p_pa_structure_version_id      IN PA_num_1000_num   := PA_num_1000_num(PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM)
 ,p_pm_task_reference        IN PA_VC_1000_25     := PA_VC_1000_25(PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR)
 ,p_pa_task_id               IN PA_num_1000_num   := PA_num_1000_num(PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM)
 ,p_pa_task_element_version_id IN PA_num_1000_num   := PA_num_1000_num(PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM)
 ,p_pm_task_asgmt_reference  IN PA_VC_1000_25     := PA_VC_1000_25(PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR)
 ,p_pa_task_assignment_id    IN PA_num_1000_num   := PA_num_1000_num(PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM)
 ,p_resource_alias           IN PA_VC_1000_80     := PA_VC_1000_80(PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR)
 ,p_resource_list_member_id  IN PA_num_1000_num   := PA_num_1000_num(PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM)
 ,p_start_date               IN PA_date_1000_date := PA_date_1000_date(PA_INTERFACE_UTILS_PUB.G_PA_MISS_DATE)
 ,p_end_date                 IN PA_date_1000_date := PA_date_1000_date(PA_INTERFACE_UTILS_PUB.G_PA_MISS_DATE)
 ,p_planned_quantity         IN PA_num_1000_num   := PA_num_1000_num(PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM)
 ,p_planned_total_raw_cost   IN PA_num_1000_num   := PA_num_1000_num(PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM)
 ,p_planned_total_bur_cost   IN PA_num_1000_num   := PA_num_1000_num(PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM)
 ,p_currency_code            IN PA_VC_1000_30     := PA_VC_1000_30(PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR)
 --This parameter is added for Bug 3948128: TA Delay CR by DHI
 ,p_scheduled_delay          IN PA_num_1000_num   := PA_num_1000_num(PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM)
 ,p_attribute_category       IN PA_VC_1000_30     := PA_VC_1000_30(PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR)
 ,p_attribute1               IN PA_VC_1000_150    := PA_VC_1000_150(PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR)
 ,p_attribute2               IN PA_VC_1000_150    := PA_VC_1000_150(PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR)
 ,p_attribute3               IN PA_VC_1000_150    := PA_VC_1000_150(PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR)
 ,p_attribute4               IN PA_VC_1000_150    := PA_VC_1000_150(PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR)
 ,p_attribute5               IN PA_VC_1000_150    := PA_VC_1000_150(PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR)
 ,p_attribute6               IN PA_VC_1000_150    := PA_VC_1000_150(PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR)
 ,p_attribute7               IN PA_VC_1000_150    := PA_VC_1000_150(PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR)
 ,p_attribute8               IN PA_VC_1000_150    := PA_VC_1000_150(PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR)
 ,p_attribute9               IN PA_VC_1000_150    := PA_VC_1000_150(PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR)
 ,p_attribute10              IN PA_VC_1000_150    := PA_VC_1000_150(PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR)
 ,p_attribute11              IN PA_VC_1000_150    := PA_VC_1000_150(PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR)
 ,p_attribute12              IN PA_VC_1000_150    := PA_VC_1000_150(PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR)
 ,p_attribute13              IN PA_VC_1000_150    := PA_VC_1000_150(PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR)
 ,p_attribute14              IN PA_VC_1000_150    := PA_VC_1000_150(PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR)
 ,p_attribute15              IN PA_VC_1000_150    := PA_VC_1000_150(PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR)
 ,p_attribute16              IN PA_VC_1000_150    := PA_VC_1000_150(PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR)
 ,p_attribute17              IN PA_VC_1000_150    := PA_VC_1000_150(PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR)
 ,p_attribute18              IN PA_VC_1000_150    := PA_VC_1000_150(PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR)
 ,p_attribute19              IN PA_VC_1000_150    := PA_VC_1000_150(PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR)
 ,p_attribute20              IN PA_VC_1000_150    := PA_VC_1000_150(PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR)
 ,p_attribute21              IN PA_VC_1000_150    := PA_VC_1000_150(PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR)
 ,p_attribute22              IN PA_VC_1000_150    := PA_VC_1000_150(PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR)
 ,p_attribute23              IN PA_VC_1000_150    := PA_VC_1000_150(PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR)
 ,p_attribute24              IN PA_VC_1000_150    := PA_VC_1000_150(PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR)
 ,p_attribute25              IN PA_VC_1000_150    := PA_VC_1000_150(PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR)
 ,p_attribute26              IN PA_VC_1000_150    := PA_VC_1000_150(PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR)
 ,p_attribute27              IN PA_VC_1000_150    := PA_VC_1000_150(PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR)
 ,p_attribute28              IN PA_VC_1000_150    := PA_VC_1000_150(PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR)
 ,p_attribute29              IN PA_VC_1000_150    := PA_VC_1000_150(PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR)
 ,p_attribute30              IN PA_VC_1000_150    := PA_VC_1000_150(PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR)
 ,up_description             IN PA_VC_1000_240    := PA_VC_1000_240(PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR)
 ,up_use_task_schedule_flag  IN PA_VC_1000_1      := PA_VC_1000_1(PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR)
 ,up_raw_cost_rate_override  IN PA_num_1000_num   := PA_num_1000_num(PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM)
 ,up_burd_cost_rate_override IN PA_num_1000_num   := PA_num_1000_num(PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM)
 ,up_billable_work_percent   IN PA_num_1000_num   := PA_num_1000_num(PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM)
 ,up_mfg_cost_type           IN PA_VC_1000_10     := PA_VC_1000_10(PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR)
 ,up_mfg_cost_type_id        IN PA_num_1000_num   := PA_num_1000_num(PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM)
 ,p_context_flag             IN PA_VC_1000_1      := PA_VC_1000_1(PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR)
 ,x_msg_count                    OUT NOCOPY NUMBER
 ,x_msg_data                     OUT NOCOPY VARCHAR2
 ,x_return_status                    OUT NOCOPY VARCHAR2
)  IS

   l_api_name      CONSTANT  VARCHAR2(30)     := 'load_task_assignments';
   i            NUMBER;
   L_FuncProc varchar2(2000);

BEGIN
   L_FuncProc := 'Load Task Assignments';

IF P_DEBUG_MODE = 'Y' AND (li_curr_level <= 3) THEN
   pa_debug.g_err_stage:='Entered ' || L_FuncProc;
   pa_debug.write(G_PKG_NAME ,pa_debug.g_err_stage,3);
END IF;

  --  Standard begin of API savepoint

  --  debug_msg1('Entered procedure:' || L_FuncProc);

    SAVEPOINT load_task_asgmts_pub;

  --  Standard call to check for call compatibility.

   IF NOT FND_API.Compatible_API_Call ( 1.0, --pa_project_pub.g_api_version_number  ,
                               p_api_version_number  ,
                               l_api_name         ,
                               G_PKG_NAME         )
   THEN

        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

   END IF;

   --dbms_output.put_line('FND API Compatible:' || L_FuncProc);

   --  Initialize the message table if requested.

   IF FND_API.TO_BOOLEAN( p_init_msg_list )

   THEN

         FND_MSG_PUB.initialize;

   END IF;

   --  Set API return status to success

       x_return_status := FND_API.G_RET_STS_SUCCESS;

IF P_DEBUG_MODE = 'Y' AND (li_curr_level <= 3) THEN
   pa_debug.g_err_stage:='Before Looping through 1000 records.' ;
   pa_debug.write(G_PKG_NAME ,pa_debug.g_err_stage,3);
END IF;

    FOR i in 1..1000 LOOP

              if p_pa_task_assignment_id.exists(i) and p_pm_task_asgmt_reference.exists(i) then

                            if (p_pa_task_assignment_id(i) is null and p_pm_task_asgmt_reference(i) is null) OR
                              (p_pa_task_assignment_id(i) = PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM
                               and p_pm_task_asgmt_reference(i) = PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR) then

						   	   	   IF P_DEBUG_MODE = 'Y' AND (li_curr_level <= 3) THEN
                                         pa_debug.g_err_stage:='Returning from Load TA as index loaded at  :' || i ;
                                         pa_debug.write(G_PKG_NAME ,pa_debug.g_err_stage,3);
									END IF;

                                         return;

                            end if;
                elsif p_pa_task_assignment_id.exists(i) then

                                if (p_pa_task_assignment_id(i) is null) OR
                                   (p_pa_task_assignment_id(i) = PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM ) then
								    IF P_DEBUG_MODE = 'Y' AND (li_curr_level <= 3) THEN
                                        pa_debug.g_err_stage:='Returning from Load TA as index loaded at  :' || i ;
                                        pa_debug.write(G_PKG_NAME ,pa_debug.g_err_stage,3);
									END IF;
                                         return;
                                end if;
                elsif   p_pm_task_asgmt_reference.exists(i)  then


                                    if (p_pm_task_asgmt_reference(i) is null) OR
                                      (p_pm_task_asgmt_reference(i) = PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR ) then
									  	IF P_DEBUG_MODE = 'Y' AND (li_curr_level <= 3) THEN
                                           pa_debug.g_err_stage:='Returning from Load TA as index loaded at :' || i ;
                                           pa_debug.write(G_PKG_NAME ,pa_debug.g_err_stage,3);
										END IF;
                                              return;

                                    end if;
                 else
				 	 		IF P_DEBUG_MODE = 'Y' AND (li_curr_level <= 3) THEN
                                pa_debug.g_err_stage:='Returning from Load TA as index loaded at -:' || i ;
                                pa_debug.write(G_PKG_NAME ,pa_debug.g_err_stage,3);
							END IF;
                                return;
                 end if;

               --  assign a value to the global counter for this table
            IF g_task_asgmts_tbl_count IS NOT NULL THEN
                g_task_asgmts_tbl_count  := g_task_asgmts_tbl_count + 1;
            ELSE
                g_task_asgmts_tbl_count  := 1;
            END IF;

			IF P_DEBUG_MODE = 'Y' AND (li_curr_level <= 3) THEN
	            pa_debug.g_err_stage:='g_task_asgmts_tbl_count :' || g_task_asgmts_tbl_count ;
	            pa_debug.write(G_PKG_NAME ,pa_debug.g_err_stage,3);
			END IF;

            IF p_pm_project_reference.exists(i) THEN
              g_task_asgmts_in_tbl(g_task_asgmts_tbl_count).pm_project_reference      :=    p_pm_project_reference(i);
            ELSE
              g_task_asgmts_in_tbl(g_task_asgmts_tbl_count).pm_project_reference      :=    PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR;
            END IF;


            IF  p_pa_project_id.exists(i) THEN
               g_task_asgmts_in_tbl(g_task_asgmts_tbl_count).pa_project_id             :=  p_pa_project_id(i);
            ELSE
               g_task_asgmts_in_tbl(g_task_asgmts_tbl_count).pa_project_id       :=    PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM;
            END IF;

            IF p_pa_structure_version_id.exists(i) THEN
               g_task_asgmts_in_tbl(g_task_asgmts_tbl_count).pa_structure_version_id       :=  p_pa_structure_version_id(i);
            ELSE
               g_task_asgmts_in_tbl(g_task_asgmts_tbl_count).pa_structure_version_id       :=    PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM;
            END IF;

            IF p_pm_task_reference.exists(i) THEN
               g_task_asgmts_in_tbl(g_task_asgmts_tbl_count).pm_task_reference   :=  p_pm_task_reference(i);
			   IF P_DEBUG_MODE = 'Y' AND (li_curr_level <= 3) THEN
	               pa_debug.g_err_stage:='In Load task asgmts. p_pm_task_reference(' || i || '):' || p_pm_task_reference(i) ;
	               pa_debug.write(G_PKG_NAME ,pa_debug.g_err_stage,3);
			   END IF;
            ELSE
               g_task_asgmts_in_tbl(g_task_asgmts_tbl_count).pm_task_reference      :=    PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR;
            END IF;

            IF p_pa_task_id.exists(i) THEN
               g_task_asgmts_in_tbl(g_task_asgmts_tbl_count).pa_task_id       :=  p_pa_task_id(i);
IF P_DEBUG_MODE = 'Y' AND (li_curr_level <= 3) THEN
               pa_debug.g_err_stage:='In Load task asgmts. p_pa_task_id(' || i || '):' || p_pa_task_id(i);
               pa_debug.write(G_PKG_NAME ,pa_debug.g_err_stage,3);
END IF;
            ELSE
               g_task_asgmts_in_tbl(g_task_asgmts_tbl_count).pa_task_id       :=    PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM;
            END IF;

            IF p_pa_task_element_version_id.exists(i) THEN
               g_task_asgmts_in_tbl(g_task_asgmts_tbl_count).pa_task_element_version_id       :=  p_pa_task_element_version_id(i);
IF P_DEBUG_MODE = 'Y' AND (li_curr_level <= 3) THEN
               pa_debug.g_err_stage:='In Load task asgmts. p_pa_task_element_version_id(' || i || '):' || p_pa_task_element_version_id(i);
               pa_debug.write(G_PKG_NAME ,pa_debug.g_err_stage,3);
END IF;
            ELSE
               g_task_asgmts_in_tbl(g_task_asgmts_tbl_count).pa_task_element_version_id       :=    PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM;
            END IF;

            IF p_pa_task_assignment_id.exists(i) THEN
               g_task_asgmts_in_tbl(g_task_asgmts_tbl_count).pa_task_assignment_id       :=  p_pa_task_assignment_id(i);
IF P_DEBUG_MODE = 'Y' AND (li_curr_level <= 3) THEN
               pa_debug.g_err_stage:='In Load task asgmts. p_pa_task_assignment_id(' || i || '):' || p_pa_task_assignment_id(i);
               pa_debug.write(G_PKG_NAME ,pa_debug.g_err_stage,3);
END IF;
            ELSE
               g_task_asgmts_in_tbl(g_task_asgmts_tbl_count).pa_task_assignment_id       :=    PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM;
            END IF;

           IF p_pm_task_asgmt_reference.exists(i) THEN
              g_task_asgmts_in_tbl(g_task_asgmts_tbl_count).pm_task_asgmt_reference   :=  p_pm_task_asgmt_reference(i);
IF P_DEBUG_MODE = 'Y' AND (li_curr_level <= 3) THEN
              pa_debug.g_err_stage:='In Load task asgmts. p_pm_task_asgmt_reference(' || i || '):' || p_pm_task_asgmt_reference(i);
              pa_debug.write(G_PKG_NAME ,pa_debug.g_err_stage,3);
END IF;
           ELSE
             g_task_asgmts_in_tbl(g_task_asgmts_tbl_count).pm_task_asgmt_reference      :=    PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR;
           END IF;

           IF p_resource_alias.exists(i) THEN
              g_task_asgmts_in_tbl(g_task_asgmts_tbl_count).resource_alias   :=  p_resource_alias(i);
           ELSE
             g_task_asgmts_in_tbl(g_task_asgmts_tbl_count).resource_alias      :=    PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR;
           END IF;

           IF p_resource_list_member_id.exists(i) THEN
              g_task_asgmts_in_tbl(g_task_asgmts_tbl_count).resource_list_member_id       :=  p_resource_list_member_id(i);
           ELSE
              g_task_asgmts_in_tbl(g_task_asgmts_tbl_count).resource_list_member_id       :=    PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM;
           END IF;

           IF p_start_date.exists(i) THEN
              g_task_asgmts_in_tbl(g_task_asgmts_tbl_count).start_date       :=  p_start_date(i);
           ELSE
             g_task_asgmts_in_tbl(g_task_asgmts_tbl_count).start_date       :=    PA_INTERFACE_UTILS_PUB.G_PA_MISS_DATE;
           END IF;

           IF p_end_date.exists(i) THEN
             g_task_asgmts_in_tbl(g_task_asgmts_tbl_count).end_date       :=  p_end_date(i);
           ELSE
             g_task_asgmts_in_tbl(g_task_asgmts_tbl_count).end_date       :=    PA_INTERFACE_UTILS_PUB.G_PA_MISS_DATE;
           END IF;

           IF p_planned_quantity.exists(i) THEN
IF P_DEBUG_MODE = 'Y' AND (li_curr_level <= 3) THEN
             pa_debug.g_err_stage:='p_planned_quantity(i)' || p_planned_quantity(i);
             pa_debug.write(G_PKG_NAME ,pa_debug.g_err_stage,3);
END IF;
             g_task_asgmts_in_tbl(g_task_asgmts_tbl_count).planned_quantity       :=  p_planned_quantity(i);
           ELSE
             g_task_asgmts_in_tbl(g_task_asgmts_tbl_count).planned_quantity       :=    PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM;
           END IF;

           IF p_planned_total_raw_cost.exists(i) THEN
             g_task_asgmts_in_tbl(g_task_asgmts_tbl_count).planned_total_raw_cost       :=  p_planned_total_raw_cost(i);
           ELSE
             g_task_asgmts_in_tbl(g_task_asgmts_tbl_count).planned_total_raw_cost       :=    PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM;
           END IF;

           IF p_planned_total_bur_cost.exists(i) THEN
             g_task_asgmts_in_tbl(g_task_asgmts_tbl_count).planned_total_bur_cost       :=  p_planned_total_bur_cost(i);
           ELSE
             g_task_asgmts_in_tbl(g_task_asgmts_tbl_count).planned_total_bur_cost       :=    PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM;
           END IF;

           IF p_currency_code.exists(i) THEN
             g_task_asgmts_in_tbl(g_task_asgmts_tbl_count).currency_code   :=  p_currency_code(i);
           ELSE
             g_task_asgmts_in_tbl(g_task_asgmts_tbl_count).currency_code      :=    PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR;
           END IF;

           --This parameter is added for Bug 3948128: TA Delay CR by DHI
           IF p_scheduled_delay.exists(i) THEN
             g_task_asgmts_in_tbl(g_task_asgmts_tbl_count).scheduled_delay   :=  p_scheduled_delay(i);
           ELSE
             g_task_asgmts_in_tbl(g_task_asgmts_tbl_count).scheduled_delay :=    PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM;
           END IF;

           IF p_attribute_category.exists(i) THEN
             g_task_asgmts_in_tbl(g_task_asgmts_tbl_count).attribute_category   :=  p_attribute_category(i);
           ELSE
             g_task_asgmts_in_tbl(g_task_asgmts_tbl_count).attribute_category      :=    PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR;
           END IF;

           IF p_attribute1.exists(i) THEN
             g_task_asgmts_in_tbl(g_task_asgmts_tbl_count).attribute1   :=  p_attribute1(i);
           ELSE
             g_task_asgmts_in_tbl(g_task_asgmts_tbl_count).attribute1      :=    PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR;
           END IF;

           IF p_attribute2.exists(i) THEN
            g_task_asgmts_in_tbl(g_task_asgmts_tbl_count).attribute2   :=  p_attribute2(i);
           ELSE
             g_task_asgmts_in_tbl(g_task_asgmts_tbl_count).attribute2      :=    PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR;
           END IF;

           IF p_attribute3.exists(i) THEN
             g_task_asgmts_in_tbl(g_task_asgmts_tbl_count).attribute3   :=  p_attribute3(i);
           ELSE
             g_task_asgmts_in_tbl(g_task_asgmts_tbl_count).attribute3      :=    PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR;
           END IF;

           IF p_attribute4.exists(i) THEN
             g_task_asgmts_in_tbl(g_task_asgmts_tbl_count).attribute4   :=  p_attribute4(i);
           ELSE
             g_task_asgmts_in_tbl(g_task_asgmts_tbl_count).attribute4      :=    PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR;
           END IF;

           IF p_attribute5.exists(i) THEN
             g_task_asgmts_in_tbl(g_task_asgmts_tbl_count).attribute5   :=  p_attribute5(i);
           ELSE
             g_task_asgmts_in_tbl(g_task_asgmts_tbl_count).attribute5      :=    PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR;
           END IF;

           IF p_attribute6.exists(i) THEN
             g_task_asgmts_in_tbl(g_task_asgmts_tbl_count).attribute6   :=  p_attribute6(i);
           ELSE
             g_task_asgmts_in_tbl(g_task_asgmts_tbl_count).attribute6      :=    PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR;
           END IF;

           IF p_attribute7.exists(i) THEN
             g_task_asgmts_in_tbl(g_task_asgmts_tbl_count).attribute7   :=  p_attribute7(i);
           ELSE
             g_task_asgmts_in_tbl(g_task_asgmts_tbl_count).attribute7      :=    PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR;
           END IF;

           IF p_attribute8.exists(i) THEN
            g_task_asgmts_in_tbl(g_task_asgmts_tbl_count).attribute8   :=  p_attribute8(i);
           ELSE
             g_task_asgmts_in_tbl(g_task_asgmts_tbl_count).attribute8      :=    PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR;
           END IF;

           IF p_attribute9.exists(i) THEN
            g_task_asgmts_in_tbl(g_task_asgmts_tbl_count).attribute9   :=  p_attribute9(i);
           ELSE
             g_task_asgmts_in_tbl(g_task_asgmts_tbl_count).attribute9      :=    PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR;
           END IF;

           IF p_attribute10.exists(i) THEN
            g_task_asgmts_in_tbl(g_task_asgmts_tbl_count).attribute10   :=  p_attribute10(i);
           ELSE
             g_task_asgmts_in_tbl(g_task_asgmts_tbl_count).attribute10      :=    PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR;
           END IF;

           IF p_attribute11.exists(i) THEN
            g_task_asgmts_in_tbl(g_task_asgmts_tbl_count).attribute11   :=  p_attribute11(i);
           ELSE
             g_task_asgmts_in_tbl(g_task_asgmts_tbl_count).attribute11      :=    PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR;
           END IF;
           IF p_attribute12.exists(i) THEN
            g_task_asgmts_in_tbl(g_task_asgmts_tbl_count).attribute12   :=  p_attribute12(i);
            ELSE
               g_task_asgmts_in_tbl(g_task_asgmts_tbl_count).attribute12      :=    PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR;
           END IF;
           IF p_attribute13.exists(i) THEN
            g_task_asgmts_in_tbl(g_task_asgmts_tbl_count).attribute13   :=  p_attribute13(i);
            ELSE
               g_task_asgmts_in_tbl(g_task_asgmts_tbl_count).attribute13      :=    PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR;
           END IF;
           IF p_attribute14.exists(i) THEN
            g_task_asgmts_in_tbl(g_task_asgmts_tbl_count).attribute14   :=  p_attribute14(i);
            ELSE
               g_task_asgmts_in_tbl(g_task_asgmts_tbl_count).attribute14      :=    PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR;
           END IF;
           IF p_attribute15.exists(i) THEN
            g_task_asgmts_in_tbl(g_task_asgmts_tbl_count).attribute15   :=  p_attribute15(i);
            ELSE
               g_task_asgmts_in_tbl(g_task_asgmts_tbl_count).attribute15      :=    PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR;
           END IF;
           IF p_attribute16.exists(i) THEN
            g_task_asgmts_in_tbl(g_task_asgmts_tbl_count).attribute16   :=  p_attribute16(i);
            ELSE
               g_task_asgmts_in_tbl(g_task_asgmts_tbl_count).attribute16      :=    PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR;
           END IF;
           IF p_attribute17.exists(i) THEN
            g_task_asgmts_in_tbl(g_task_asgmts_tbl_count).attribute17   :=  p_attribute17(i);
            ELSE
               g_task_asgmts_in_tbl(g_task_asgmts_tbl_count).attribute17      :=    PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR;
           END IF;
           IF p_attribute18.exists(i) THEN
            g_task_asgmts_in_tbl(g_task_asgmts_tbl_count).attribute18   :=  p_attribute18(i);
            ELSE
               g_task_asgmts_in_tbl(g_task_asgmts_tbl_count).attribute18      :=    PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR;
           END IF;
           IF p_attribute19.exists(i) THEN
            g_task_asgmts_in_tbl(g_task_asgmts_tbl_count).attribute19   :=  p_attribute19(i);
            ELSE
               g_task_asgmts_in_tbl(g_task_asgmts_tbl_count).attribute19      :=    PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR;
           END IF;
           IF p_attribute20.exists(i) THEN
            g_task_asgmts_in_tbl(g_task_asgmts_tbl_count).attribute20   :=  p_attribute20(i);
            ELSE
               g_task_asgmts_in_tbl(g_task_asgmts_tbl_count).attribute20      :=    PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR;
           END IF;
           IF p_attribute21.exists(i) THEN
            g_task_asgmts_in_tbl(g_task_asgmts_tbl_count).attribute21   :=  p_attribute21(i);
            ELSE
               g_task_asgmts_in_tbl(g_task_asgmts_tbl_count).attribute21      :=    PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR;
           END IF;
           IF p_attribute22.exists(i) THEN
            g_task_asgmts_in_tbl(g_task_asgmts_tbl_count).attribute22   :=  p_attribute22(i);
            ELSE
               g_task_asgmts_in_tbl(g_task_asgmts_tbl_count).attribute22      :=    PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR;
           END IF;
           IF p_attribute23.exists(i) THEN
            g_task_asgmts_in_tbl(g_task_asgmts_tbl_count).attribute23   :=  p_attribute23(i);
            ELSE
               g_task_asgmts_in_tbl(g_task_asgmts_tbl_count).attribute23      :=    PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR;
           END IF;
           IF p_attribute24.exists(i) THEN
            g_task_asgmts_in_tbl(g_task_asgmts_tbl_count).attribute24   :=  p_attribute24(i);
            ELSE
               g_task_asgmts_in_tbl(g_task_asgmts_tbl_count).attribute24      :=    PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR;
           END IF;
           IF p_attribute25.exists(i) THEN
            g_task_asgmts_in_tbl(g_task_asgmts_tbl_count).attribute25   :=  p_attribute25(i);
            ELSE
               g_task_asgmts_in_tbl(g_task_asgmts_tbl_count).attribute25      :=    PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR;
           END IF;
           IF p_attribute26.exists(i) THEN
            g_task_asgmts_in_tbl(g_task_asgmts_tbl_count).attribute26   :=  p_attribute26(i);
            ELSE
               g_task_asgmts_in_tbl(g_task_asgmts_tbl_count).attribute26      :=    PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR;
           END IF;
           IF p_attribute27.exists(i) THEN
            g_task_asgmts_in_tbl(g_task_asgmts_tbl_count).attribute27   :=  p_attribute27(i);
            ELSE
               g_task_asgmts_in_tbl(g_task_asgmts_tbl_count).attribute27      :=    PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR;
           END IF;
           IF p_attribute28.exists(i) THEN
            g_task_asgmts_in_tbl(g_task_asgmts_tbl_count).attribute28   :=  p_attribute28(i);
            ELSE
               g_task_asgmts_in_tbl(g_task_asgmts_tbl_count).attribute28      :=    PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR;
           END IF;
           IF p_attribute29.exists(i) THEN
            g_task_asgmts_in_tbl(g_task_asgmts_tbl_count).attribute29   :=  p_attribute29(i);
            ELSE
               g_task_asgmts_in_tbl(g_task_asgmts_tbl_count).attribute29      :=    PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR;
           END IF;
          IF p_attribute30.exists(i) THEN
            g_task_asgmts_in_tbl(g_task_asgmts_tbl_count).attribute30   :=  p_attribute30(i);
            ELSE
               g_task_asgmts_in_tbl(g_task_asgmts_tbl_count).attribute30      :=    PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR;
           END IF;
           IF up_description.exists(i) THEN
            g_task_asgmts_in_tbl(g_task_asgmts_tbl_count).description   :=  up_description(i);
            ELSE
               g_task_asgmts_in_tbl(g_task_asgmts_tbl_count).description      :=    PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR;
           END IF;

           IF up_use_task_schedule_flag.exists(i) THEN
            g_task_asgmts_in_tbl(g_task_asgmts_tbl_count).use_task_schedule_flag     :=  up_use_task_schedule_flag(i);
            ELSE
               g_task_asgmts_in_tbl(g_task_asgmts_tbl_count).use_task_schedule_flag  :=    PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR;
           END IF;

            IF up_raw_cost_rate_override.exists(i) THEN
            g_task_asgmts_in_tbl(g_task_asgmts_tbl_count).raw_cost_rate_override   :=  up_raw_cost_rate_override(i);
            ELSE
               g_task_asgmts_in_tbl(g_task_asgmts_tbl_count).raw_cost_rate_override      :=    PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM;
           END IF;
           IF up_burd_cost_rate_override.exists(i) THEN
            g_task_asgmts_in_tbl(g_task_asgmts_tbl_count).burd_cost_rate_override   :=  up_burd_cost_rate_override(i);
            ELSE
               g_task_asgmts_in_tbl(g_task_asgmts_tbl_count).burd_cost_rate_override      :=    PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM;
           END IF;
            IF up_mfg_cost_type.exists(i) THEN
            g_task_asgmts_in_tbl(g_task_asgmts_tbl_count).mfg_cost_type   :=  up_mfg_cost_type(i);
            ELSE
               g_task_asgmts_in_tbl(g_task_asgmts_tbl_count).mfg_cost_type      :=    PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR;
           END IF;
            IF up_mfg_cost_type_id.exists(i) THEN
            g_task_asgmts_in_tbl(g_task_asgmts_tbl_count).mfg_cost_type_id   :=  up_mfg_cost_type_id(i);
            ELSE
               g_task_asgmts_in_tbl(g_task_asgmts_tbl_count).mfg_cost_type_id      :=    PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM;
           END IF;
           IF up_billable_work_percent.exists(i) THEN
            g_task_asgmts_in_tbl(g_task_asgmts_tbl_count).billable_work_percent   :=  up_billable_work_percent(i);
            ELSE
               g_task_asgmts_in_tbl(g_task_asgmts_tbl_count).billable_work_percent      :=    PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM;
           END IF;
           IF p_context_flag.exists(i) THEN
            g_task_asgmts_in_tbl(g_task_asgmts_tbl_count).p_context   :=  p_context_flag(i);
            ELSE
               g_task_asgmts_in_tbl(g_task_asgmts_tbl_count).p_context      :=    PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR;
           END IF;


   END LOOP;

IF P_DEBUG_MODE = 'Y' AND (li_curr_level <= 3) THEN
   pa_debug.g_err_stage:='Done Loading..' ;
   pa_debug.write(G_PKG_NAME ,pa_debug.g_err_stage,3);
END IF;

EXCEPTION

  WHEN FND_API.G_EXC_ERROR
  THEN
       ROLLBACK TO load_task_asgmts_pub;

       x_return_status := FND_API.G_RET_STS_ERROR;
IF P_DEBUG_MODE = 'Y' THEN
       PA_DEBUG.write_log (x_module => G_PKG_NAME
                               ,x_msg         => 'Expected Error:' || L_FuncProc || SQLERRM
                               ,x_log_level   => 5);
END IF;

       FND_MSG_PUB.Count_And_Get
           (   p_count    =>  x_msg_count  ,
               p_data    =>   x_msg_data  );

  WHEN FND_API.G_EXC_UNEXPECTED_ERROR
  THEN
       ROLLBACK TO load_task_asgmts_pub;

       x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
IF P_DEBUG_MODE = 'Y' THEN
       PA_DEBUG.write_log (x_module => G_PKG_NAME
                               ,x_msg         => 'Unexpected Error:' || L_FuncProc || SQLERRM
                               ,x_log_level   => 5);
END IF;

       IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
       THEN
         FND_MSG_PUB.add_exc_msg
             ( p_pkg_name    => G_PKG_NAME
             , p_procedure_name  => l_api_name  );

       END IF;

       FND_MSG_PUB.Count_And_Get
           (   p_count    =>  x_msg_count  ,
               p_data    =>   x_msg_data  );

  WHEN OTHERS THEN
       ROLLBACK TO load_task_asgmts_pub;

       x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
IF P_DEBUG_MODE = 'Y' THEN
       PA_DEBUG.write_log (x_module => G_PKG_NAME
                               ,x_msg         => 'Unexpected Error:' || L_FuncProc || SQLERRM
                               ,x_log_level   => 5);
END IF;

       IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
       THEN
         FND_MSG_PUB.add_exc_msg
             ( p_pkg_name    => G_PKG_NAME
             , p_procedure_name  => l_api_name  );

       END IF;
       FND_MSG_PUB.Count_And_Get
           (   p_count    =>  x_msg_count  ,
               p_data    =>   x_msg_data  );

END LOAD_TASK_ASSIGNMENTS;


PROCEDURE Load_Task_Asgmt_Periods
( p_api_version_number       IN NUMBER            := PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM
 ,p_commit                               IN VARCHAR2          := FND_API.G_FALSE
 ,p_init_msg_list                IN VARCHAR2          := FND_API.G_FALSE
 ,p_pm_project_reference     IN PA_VC_1000_25     := PA_VC_1000_25(PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM)
 ,p_pa_project_id                IN PA_num_1000_num   := PA_num_1000_num(PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM)
 ,p_pa_structure_version_id      IN PA_num_1000_num   := PA_num_1000_num(PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM)
 ,p_pm_task_reference        IN PA_VC_1000_25     := PA_VC_1000_25(PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM)
 ,p_pa_task_id               IN PA_num_1000_num   := PA_num_1000_num(PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM)
 ,p_pa_task_element_version_id IN PA_num_1000_num   := PA_num_1000_num(PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM)
 ,p_pm_task_asgmt_reference  IN PA_VC_1000_25     := PA_VC_1000_25(PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR)
 ,p_pa_task_assignment_id    IN PA_num_1000_num   := PA_num_1000_num(PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM)
 ,p_resource_alias           IN PA_VC_1000_80     := PA_VC_1000_80(PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR)
 ,p_resource_list_member_id  IN PA_num_1000_num   := PA_num_1000_num(PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM)
 --Name of the period if available
 ,p_period_name              IN PA_VC_1000_30     := PA_VC_1000_30(PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM)
 --Start date of the period
 ,p_start_date               IN PA_date_1000_date := PA_date_1000_date(PA_INTERFACE_UTILS_PUB.G_PA_MISS_DATE)
 --End date of the period
 ,p_end_date                 IN PA_date_1000_date := PA_date_1000_date(PA_INTERFACE_UTILS_PUB.G_PA_MISS_DATE)
 ,p_txn_quantity             IN PA_num_1000_num   := PA_num_1000_num(PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM)
 ,p_txn_raw_cost             IN PA_num_1000_num   := PA_num_1000_num(PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM)
 ,p_txn_bur_cost             IN PA_num_1000_num   := PA_num_1000_num(PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM)
 ,p_currency_code            IN PA_VC_1000_30     := PA_VC_1000_30(PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR)
 ,x_msg_count                    OUT NOCOPY NUMBER
 ,x_msg_data                     OUT NOCOPY VARCHAR2
 ,x_return_status                    OUT NOCOPY VARCHAR2
) IS
 l_api_name      CONSTANT  VARCHAR2(30)     := 'load_task_assignments';
   i            NUMBER;

L_FuncProc varchar2(2000);

BEGIN
L_FuncProc := 'Load Task Assignment Periods';

IF P_DEBUG_MODE = 'Y' AND (li_curr_level <= 3) THEN
pa_debug.g_err_stage:='Entered ' || L_FuncProc;
pa_debug.write(G_PKG_NAME ,pa_debug.g_err_stage,3);
END IF;

  --dbms_output.put_line('Entered procedure:' || L_FuncProc);

--  Standard begin of API savepoint

    SAVEPOINT Load_Task_Asgmt_Periods;

--  Standard call to check for call compatibility.

     IF NOT FND_API.Compatible_API_Call ( 1.0, --pa_project_pub.g_api_version_number  ,
                               p_api_version_number  ,
                               l_api_name         ,
                               G_PKG_NAME         )
    THEN

        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

    END IF;

--  Initialize the message table if requested.

    IF FND_API.TO_BOOLEAN( p_init_msg_list )

        THEN

         FND_MSG_PUB.initialize;

    END IF;

--  Set API return status to success

    x_return_status := FND_API.G_RET_STS_SUCCESS;



  --assign appropriate values to outgoing parameters

 FOR i in 1..1000 LOOP

IF P_DEBUG_MODE = 'Y' AND (li_curr_level <= 3) THEN
  pa_debug.g_err_stage:='In Task assignment periods load loop start index:' || i;
  pa_debug.write(G_PKG_NAME ,pa_debug.g_err_stage,3);
END IF;

      if p_pa_task_assignment_id.exists(i) and p_pm_task_asgmt_reference.exists(i) then

                   if p_pa_task_assignment_id(i) is null and p_pm_task_asgmt_reference(i) is null then
IF P_DEBUG_MODE = 'Y' AND (li_curr_level <= 3) THEN
                     pa_debug.g_err_stage:='p_pa_task_assignment_id(i) is null and p_pm_task_asgmt_reference(i) is null returning:';
                     pa_debug.write(G_PKG_NAME ,pa_debug.g_err_stage,3);
END IF;
                      return;
                   end if;
        elsif p_pa_task_assignment_id.exists(i) then

                        if p_pa_task_assignment_id(i) is null then
IF P_DEBUG_MODE = 'Y' AND (li_curr_level <= 3) THEN
                                 pa_debug.g_err_stage:='p_pa_task_assignment_id(i) is null returning:';
                                 pa_debug.write(G_PKG_NAME ,pa_debug.g_err_stage,3);
END IF;
                                return;
                         end if;
        elsif   p_pm_task_asgmt_reference.exists(i)  then


                           if p_pm_task_asgmt_reference(i) is null then
IF P_DEBUG_MODE = 'Y' AND (li_curr_level <= 3) THEN
                                pa_debug.g_err_stage:='p_pm_task_asgmt_reference(i) is null returning:' ;
                                pa_debug.write(G_PKG_NAME ,pa_debug.g_err_stage,3);
END IF;
                                return;
                           end if;
        else

                 return;
         end if;

           --  assign a value to the global counter for this table
           IF g_asgmts_periods_tbl_count IS NOT NULL THEN

             g_asgmts_periods_tbl_count  := g_asgmts_periods_tbl_count + 1;

           ELSE

             g_asgmts_periods_tbl_count  := 1;

           END IF;
IF P_DEBUG_MODE = 'Y' AND (li_curr_level <= 3) THEN
         pa_debug.g_err_stage:='g_asgmts_periods_tbl_count:'  || g_asgmts_periods_tbl_count;
         pa_debug.write(G_PKG_NAME ,pa_debug.g_err_stage,3);
END IF;
--  assign incoming parameters to the global table fields

            IF p_pm_project_reference.exists(i) THEN
            g_asgmts_periods_tbl(g_asgmts_periods_tbl_count).pm_project_reference      :=    p_pm_project_reference(i);
          ELSE
             g_asgmts_periods_tbl(g_asgmts_periods_tbl_count).pm_project_reference      :=    PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR;
          END IF;

IF P_DEBUG_MODE = 'Y' AND (li_curr_level <= 3) THEN
           pa_debug.g_err_stage:='g_asgmts_periods_tbl(g_asgmts_periods_tbl_count).pm_project_reference:'  || g_asgmts_periods_tbl(g_asgmts_periods_tbl_count).pm_project_reference;
           pa_debug.write(G_PKG_NAME ,pa_debug.g_err_stage,3);
END IF;
           IF  p_pa_project_id.exists(i) THEN
             g_asgmts_periods_tbl(g_asgmts_periods_tbl_count).pa_project_id             :=  p_pa_project_id(i);
          ELSE
             g_asgmts_periods_tbl(g_asgmts_periods_tbl_count).pa_project_id       :=    PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM;
          END IF;
IF P_DEBUG_MODE = 'Y' AND (li_curr_level <= 3) THEN
           pa_debug.g_err_stage:='g_asgmts_periods_tbl(g_asgmts_periods_tbl_count).pa_project_id:'  || g_asgmts_periods_tbl(g_asgmts_periods_tbl_count).pa_project_id;
           pa_debug.write(G_PKG_NAME ,pa_debug.g_err_stage,3);
END IF;

          IF p_pa_structure_version_id.exists(i) THEN
             g_asgmts_periods_tbl(g_asgmts_periods_tbl_count).pa_structure_version_id       :=  p_pa_structure_version_id(i);
          ELSE
             g_asgmts_periods_tbl(g_asgmts_periods_tbl_count).pa_structure_version_id       :=    PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM;
          END IF;
IF P_DEBUG_MODE = 'Y' AND (li_curr_level <= 3) THEN
          pa_debug.g_err_stage:='g_asgmts_periods_tbl(g_asgmts_periods_tbl_count).pa_structure_version_id:'  || g_asgmts_periods_tbl(g_asgmts_periods_tbl_count).pa_structure_version_id;
          pa_debug.write(G_PKG_NAME ,pa_debug.g_err_stage,3);
END IF;

           IF p_pm_task_reference.exists(i) THEN
          g_asgmts_periods_tbl(g_asgmts_periods_tbl_count).pm_task_reference   :=  p_pm_task_reference(i);
          ELSE
             g_asgmts_periods_tbl(g_asgmts_periods_tbl_count).pm_task_reference      :=    PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR;
         END IF;
IF P_DEBUG_MODE = 'Y' AND (li_curr_level <= 3) THEN
         pa_debug.g_err_stage:='g_asgmts_periods_tbl(g_asgmts_periods_tbl_count).pm_task_reference:'  || g_asgmts_periods_tbl(g_asgmts_periods_tbl_count).pm_task_reference;
         pa_debug.write(G_PKG_NAME ,pa_debug.g_err_stage,3);
END IF;

           IF p_pa_task_id.exists(i) THEN
             g_asgmts_periods_tbl(g_asgmts_periods_tbl_count).pa_task_id       :=  p_pa_task_id(i);
          ELSE
             g_asgmts_periods_tbl(g_asgmts_periods_tbl_count).pa_task_id       :=    PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM;
          END IF;
IF P_DEBUG_MODE = 'Y' AND (li_curr_level <= 3) THEN
         pa_debug.g_err_stage:='g_asgmts_periods_tbl(g_asgmts_periods_tbl_count).pa_task_id:'  || g_asgmts_periods_tbl(g_asgmts_periods_tbl_count).pa_task_id;
         pa_debug.write(G_PKG_NAME ,pa_debug.g_err_stage,3);
END IF;

           IF p_pa_task_element_version_id.exists(i) THEN
              g_asgmts_periods_tbl(g_asgmts_periods_tbl_count).pa_task_element_version_id       :=  p_pa_task_element_version_id(i);
IF P_DEBUG_MODE = 'Y' AND (li_curr_level <= 3) THEN
                 pa_debug.g_err_stage:='In Load task asgmts periods. p_pa_task_element_version_id(' || i || '):' || p_pa_task_element_version_id(i)  ;
                 pa_debug.write(G_PKG_NAME ,pa_debug.g_err_stage,3);
END IF;
          ELSE
              g_asgmts_periods_tbl(g_asgmts_periods_tbl_count).pa_task_element_version_id       :=    PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM;
          END IF;

            IF p_pa_task_assignment_id.exists(i) THEN
             g_asgmts_periods_tbl(g_asgmts_periods_tbl_count).pa_task_assignment_id       :=  p_pa_task_assignment_id(i);
          ELSE
             g_asgmts_periods_tbl(g_asgmts_periods_tbl_count).pa_task_assignment_id       :=    PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM;
          END IF;
IF P_DEBUG_MODE = 'Y' AND (li_curr_level <= 3) THEN
        pa_debug.g_err_stage:='g_asgmts_periods_tbl(g_asgmts_periods_tbl_count).pa_task_assignment_id:'  || g_asgmts_periods_tbl(g_asgmts_periods_tbl_count).pa_task_assignment_id;
        pa_debug.write(G_PKG_NAME ,pa_debug.g_err_stage,3);
END IF;

           IF p_pm_task_asgmt_reference.exists(i) THEN
          g_asgmts_periods_tbl(g_asgmts_periods_tbl_count).pm_task_asgmt_reference   :=  p_pm_task_asgmt_reference(i);
          ELSE
             g_asgmts_periods_tbl(g_asgmts_periods_tbl_count).pm_task_asgmt_reference      :=    PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR;
         END IF;
IF P_DEBUG_MODE = 'Y' AND (li_curr_level <= 3) THEN
         pa_debug.g_err_stage:='g_asgmts_periods_tbl(g_asgmts_periods_tbl_count).pm_task_asgmt_reference :'  || g_asgmts_periods_tbl(g_asgmts_periods_tbl_count).pm_task_asgmt_reference ;
         pa_debug.write(G_PKG_NAME ,pa_debug.g_err_stage,3);
END IF;

           IF p_resource_alias.exists(i) THEN
          g_asgmts_periods_tbl(g_asgmts_periods_tbl_count).resource_alias   :=  p_resource_alias(i);
          ELSE
             g_asgmts_periods_tbl(g_asgmts_periods_tbl_count).resource_alias      :=    PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR;
         END IF;
IF P_DEBUG_MODE = 'Y' AND (li_curr_level <= 3) THEN
          pa_debug.g_err_stage:='g_asgmts_periods_tbl(g_asgmts_periods_tbl_count).resource_alias :'  || g_asgmts_periods_tbl(g_asgmts_periods_tbl_count).resource_alias ;
          pa_debug.write(G_PKG_NAME ,pa_debug.g_err_stage,3);
END IF;

           IF p_resource_list_member_id.exists(i) THEN
             g_asgmts_periods_tbl(g_asgmts_periods_tbl_count).resource_list_member_id       :=  p_resource_list_member_id(i);
          ELSE
             g_asgmts_periods_tbl(g_asgmts_periods_tbl_count).resource_list_member_id       :=    PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM;
          END IF;
IF P_DEBUG_MODE = 'Y' AND (li_curr_level <= 3) THEN
        pa_debug.g_err_stage:='g_asgmts_periods_tbl(g_asgmts_periods_tbl_count).resource_list_member_id :'  || g_asgmts_periods_tbl(g_asgmts_periods_tbl_count).resource_list_member_id ;
        pa_debug.write(G_PKG_NAME ,pa_debug.g_err_stage,3);
END IF;
           IF p_start_date.exists(i) THEN
             g_asgmts_periods_tbl(g_asgmts_periods_tbl_count).start_date       :=  p_start_date(i);
          ELSE
             g_asgmts_periods_tbl(g_asgmts_periods_tbl_count).start_date       :=    PA_INTERFACE_UTILS_PUB.G_PA_MISS_DATE;
          END IF;
IF P_DEBUG_MODE = 'Y' AND (li_curr_level <= 3) THEN
          pa_debug.g_err_stage:='g_asgmts_periods_tbl(g_asgmts_periods_tbl_count).start_date :'  || g_asgmts_periods_tbl(g_asgmts_periods_tbl_count).start_date ;
          pa_debug.write(G_PKG_NAME ,pa_debug.g_err_stage,3);
END IF;

          IF p_end_date.exists(i) THEN
             g_asgmts_periods_tbl(g_asgmts_periods_tbl_count).end_date       :=  p_end_date(i);
          ELSE
             g_asgmts_periods_tbl(g_asgmts_periods_tbl_count).end_date       :=    PA_INTERFACE_UTILS_PUB.G_PA_MISS_DATE;
          END IF;
IF P_DEBUG_MODE = 'Y' AND (li_curr_level <= 3) THEN
        pa_debug.g_err_stage:='g_asgmts_periods_tbl(g_asgmts_periods_tbl_count).end_date :'  || g_asgmts_periods_tbl(g_asgmts_periods_tbl_count).end_date ;
        pa_debug.write(G_PKG_NAME ,pa_debug.g_err_stage,3);
END IF;

           IF p_period_name.exists(i) THEN
          g_asgmts_periods_tbl(g_asgmts_periods_tbl_count).period_name   :=  p_period_name(i);
          ELSE
             g_asgmts_periods_tbl(g_asgmts_periods_tbl_count).period_name      :=    PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR;
         END IF;
IF P_DEBUG_MODE = 'Y' AND (li_curr_level <= 3) THEN
         pa_debug.g_err_stage:='g_asgmts_periods_tbl(g_asgmts_periods_tbl_count).period_name :'  || g_asgmts_periods_tbl(g_asgmts_periods_tbl_count).period_name ;
         pa_debug.write(G_PKG_NAME ,pa_debug.g_err_stage,3);
END IF;

            IF p_txn_quantity.exists(i) THEN
             g_asgmts_periods_tbl(g_asgmts_periods_tbl_count).quantity       :=  p_txn_quantity(i);
          ELSE
             g_asgmts_periods_tbl(g_asgmts_periods_tbl_count).quantity       :=    PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM;
          END IF;
IF P_DEBUG_MODE = 'Y' AND (li_curr_level <= 3) THEN
          pa_debug.g_err_stage:='g_asgmts_periods_tbl(g_asgmts_periods_tbl_count).quantity :'  || g_asgmts_periods_tbl(g_asgmts_periods_tbl_count).quantity ;
          pa_debug.write(G_PKG_NAME ,pa_debug.g_err_stage,3);
END IF;

             IF p_txn_raw_cost.exists(i) THEN
             g_asgmts_periods_tbl(g_asgmts_periods_tbl_count).txn_raw_cost       :=  p_txn_raw_cost(i);
          ELSE
             g_asgmts_periods_tbl(g_asgmts_periods_tbl_count).txn_raw_cost       :=    PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM;
          END IF;
IF P_DEBUG_MODE = 'Y' AND (li_curr_level <= 3) THEN
          pa_debug.g_err_stage:='g_asgmts_periods_tbl(g_asgmts_periods_tbl_count).txn_raw_cost :'  || g_asgmts_periods_tbl(g_asgmts_periods_tbl_count).txn_raw_cost ;
          pa_debug.write(G_PKG_NAME ,pa_debug.g_err_stage,3);
END IF;
             IF p_txn_bur_cost.exists(i) THEN
             g_asgmts_periods_tbl(g_asgmts_periods_tbl_count).txn_burdened_cost       :=  p_txn_bur_cost(i);
          ELSE
             g_asgmts_periods_tbl(g_asgmts_periods_tbl_count).txn_burdened_cost       :=    PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM;
          END IF;
IF P_DEBUG_MODE = 'Y' AND (li_curr_level <= 3) THEN
          pa_debug.g_err_stage:='g_asgmts_periods_tbl(g_asgmts_periods_tbl_count).txn_burdened_cost :'  || g_asgmts_periods_tbl(g_asgmts_periods_tbl_count).txn_burdened_cost ;
          pa_debug.write(G_PKG_NAME ,pa_debug.g_err_stage,3);
END IF;
            IF p_currency_code.exists(i) THEN
             g_asgmts_periods_tbl(g_asgmts_periods_tbl_count).txn_currency_code       :=  p_currency_code(i);
          ELSE
             g_asgmts_periods_tbl(g_asgmts_periods_tbl_count).txn_currency_code       :=    PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR;
          END IF;
IF P_DEBUG_MODE = 'Y' AND (li_curr_level <= 3) THEN
          pa_debug.g_err_stage:='g_asgmts_periods_tbl(g_asgmts_periods_tbl_count).txn_currency_code :'  || g_asgmts_periods_tbl(g_asgmts_periods_tbl_count).txn_currency_code ;
          pa_debug.write(G_PKG_NAME ,pa_debug.g_err_stage,3);
END IF;

 END LOOP;

EXCEPTION

  WHEN FND_API.G_EXC_ERROR
  THEN
       ROLLBACK TO Load_Task_Asgmt_Periods;

       x_return_status := FND_API.G_RET_STS_ERROR;
IF P_DEBUG_MODE = 'Y' THEN
       PA_DEBUG.write_log (x_module => G_PKG_NAME
                               ,x_msg         => 'Expected Error:' || L_FuncProc || SQLERRM
                               ,x_log_level   => 5);
END IF;

       FND_MSG_PUB.Count_And_Get
           (   p_count    =>  x_msg_count  ,
               p_data    =>   x_msg_data  );

  WHEN FND_API.G_EXC_UNEXPECTED_ERROR
  THEN
       ROLLBACK TO Load_Task_Asgmt_Periods;

       x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
IF P_DEBUG_MODE = 'Y' THEN
       PA_DEBUG.write_log (x_module => G_PKG_NAME
                               ,x_msg         => 'Unexpected Error:' || L_FuncProc || SQLERRM
                               ,x_log_level   => 5);
END IF;
       IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
       THEN
         FND_MSG_PUB.add_exc_msg
             ( p_pkg_name    => G_PKG_NAME
             , p_procedure_name  => l_api_name  );

       END IF;

       FND_MSG_PUB.Count_And_Get
           (   p_count    =>  x_msg_count  ,
               p_data    =>   x_msg_data  );

  WHEN OTHERS THEN
       ROLLBACK TO Load_Task_Asgmt_Periods;

       x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
IF P_DEBUG_MODE = 'Y' THEN
       PA_DEBUG.write_log (x_module => G_PKG_NAME
                               ,x_msg         => 'Unexpected Error:' || L_FuncProc || SQLERRM
                               ,x_log_level   => 5);
END IF;
       IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
       THEN
         FND_MSG_PUB.add_exc_msg
             ( p_pkg_name    => G_PKG_NAME
             , p_procedure_name  => l_api_name  );

       END IF;
       FND_MSG_PUB.Count_And_Get
           (   p_count    =>  x_msg_count  ,
               p_data    =>   x_msg_data  );

END Load_Task_Asgmt_Periods;
--------------------------------------------------------------------------------
--Name:               EXECUTE_CREATE_TASK_ASGMTS
--Type:               Procedure
--Description:        This procedure can be used to create task assignments
--                    using global PL/SQL tables.
--
--Called subprograms:
--
--
--
--History:
--      01-APR-2004
--

PROCEDURE Execute_Create_Task_Asgmts
( p_api_version_number        IN  NUMBER       := PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM
 ,p_commit                                IN  VARCHAR2     := FND_API.G_FALSE
 ,p_init_msg_list                 IN  VARCHAR2     := FND_API.G_FALSE
 ,p_pm_product_code               IN  VARCHAR2     := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
 ,p_pm_project_reference      IN  VARCHAR2     := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
 ,p_pa_project_id             IN  NUMBER       := PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM
 ,p_pa_structure_version_id   IN  NUMBER       := PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM
 ,x_msg_count                     OUT NOCOPY NUMBER
 ,x_msg_data                      OUT NOCOPY VARCHAR2
 ,x_return_status                     OUT NOCOPY VARCHAR2
) IS

   l_api_name             CONSTANT  VARCHAR2(30)     := 'EXECUTE_CREATE_TASK_ASGMTS';
   i                      NUMBER;
   l_return_status        VARCHAR2(1);
   l_err_stage            VARCHAR2(120);
   l_msg_data             VARCHAR2(2000);
   l_msg_count            NUMBER;
   l_project_id           NUMBER;

L_FuncProc varchar2(2000);

BEGIN
L_FuncProc := 'Execute_Create_Task_Asgmts';

IF P_DEBUG_MODE = 'Y' AND (li_curr_level <= 3) THEN
pa_debug.g_err_stage:='Entered ' || L_FuncProc;
pa_debug.write(G_PKG_NAME ,pa_debug.g_err_stage,3);
END IF;
  --dbms_output.put_line('count of global tables: in exec. create' || g_task_asgmts_tbl_count);
--  Standard begin of API savepoint

    SAVEPOINT EXECUTE_CREATE_TASK_ASGMTS;

--  Standard call to check for call compatibility.

    IF NOT FND_API.Compatible_API_Call ( 1.0, --g_api_version_number  ,
                               p_api_version_number,
                               l_api_name,
                               G_PKG_NAME         )
    THEN
         RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;


--  Initialize the message table if requested.

    IF FND_API.TO_BOOLEAN( p_init_msg_list )
    THEN
       FND_MSG_PUB.initialize;
    END IF;

--  Set API return status to success

    x_return_status := FND_API.G_RET_STS_SUCCESS;
   --dbms_output.put_line('g_task_asgmts_tbl_count:' || g_task_asgmts_tbl_count);
   --dbms_output.put_line('g_asgmts_periods_tbl_count:' || g_asgmts_periods_tbl_count);


        IF nvl(g_task_asgmts_tbl_count, 0) > 0 THEN
                          --dbms_output.put_line('calling create task assignment');
                      Create_Task_Assignments
                      (  p_api_version_number        => 1.0
                      ,p_commit                          => FND_API.G_FALSE
                      ,p_init_msg_list           => FND_API.G_FALSE
                          ,p_pm_product_code         => p_pm_product_code
                          ,p_pm_project_reference    => p_pm_project_reference
                          ,p_pa_project_id           => p_pa_project_id
                          ,p_pa_structure_version_id => p_pa_structure_version_id
                          ,p_task_assignments_in     => g_task_asgmts_in_tbl
                      ,p_task_assignments_out    => g_task_asgmts_out_tbl
                      ,x_msg_count                       => l_msg_count
                      ,x_msg_data                        => l_msg_data
                      ,x_return_status               => l_return_status
                      );
                          IF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN

                                 RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

                         ELSIF l_return_status = FND_API.G_RET_STS_ERROR THEN

                                 RAISE FND_API.G_EXC_ERROR;

                         END IF;

        END IF;


   IF nvl(g_asgmts_periods_tbl_count,0) > 0 THEN

                 --dbms_output.put_line('calling create task assignment periods');
              Pa_Task_Assignments_Pvt.Create_Task_Assignment_Periods
             (  p_api_version_number         => 1.0
              ,p_commit                          => FND_API.G_FALSE
              ,p_init_msg_list           => FND_API.G_FALSE
                  ,p_pm_product_code         => p_pm_product_code
                  ,p_pm_project_reference    => p_pm_project_reference
                  ,p_pa_project_id           => p_pa_project_id
                  ,p_pa_structure_version_id => p_pa_structure_version_id
                  ,p_task_assignment_periods_in     => g_asgmts_periods_tbl
              ,p_task_assignment_periods_out    => g_asgmts_periods_out_tbl
              ,x_msg_count                       => l_msg_count
              ,x_msg_data                        => l_msg_data
              ,x_return_status               => l_return_status
             );
         IF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN

                 RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

        ELSIF l_return_status = FND_API.G_RET_STS_ERROR THEN

                 RAISE FND_API.G_EXC_ERROR;

         END IF;

   END IF;



     IF FND_API.to_boolean( p_commit ) THEN
        COMMIT;
     END IF;


EXCEPTION

  WHEN FND_API.G_EXC_ERROR
  THEN
       ROLLBACK TO EXECUTE_CREATE_TASK_ASGMTS;

       x_return_status := FND_API.G_RET_STS_ERROR;
IF P_DEBUG_MODE = 'Y' THEN
       PA_DEBUG.write_log (x_module => G_PKG_NAME
                               ,x_msg         => 'Expected Error:' || L_FuncProc || SQLERRM
                               ,x_log_level   => 5);
END IF;
       FND_MSG_PUB.Count_And_Get
           (   p_count    =>  x_msg_count  ,
               p_data    =>   x_msg_data  );

  WHEN FND_API.G_EXC_UNEXPECTED_ERROR
  THEN
       ROLLBACK TO EXECUTE_CREATE_TASK_ASGMTS;

       x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
IF P_DEBUG_MODE = 'Y' THEN
       PA_DEBUG.write_log (x_module => G_PKG_NAME
                               ,x_msg         => 'Unexpected Error:' || L_FuncProc || SQLERRM
                               ,x_log_level   => 5);
END IF;
       FND_MSG_PUB.Count_And_Get
           (   p_count    =>  x_msg_count  ,
               p_data    =>  x_msg_data  );

  WHEN OTHERS THEN
       ROLLBACK TO EXECUTE_CREATE_TASK_ASGMTS;

       x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
IF P_DEBUG_MODE = 'Y' THEN
       PA_DEBUG.write_log (x_module => G_PKG_NAME
                               ,x_msg         => 'Unexpected Error:' || L_FuncProc || SQLERRM
                               ,x_log_level   => 5);
END IF;
       IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
       THEN
         FND_MSG_PUB.add_exc_msg
             ( p_pkg_name    => G_PKG_NAME
             , p_procedure_name  => l_api_name  );

       END IF;

       FND_MSG_PUB.Count_And_Get
           (   p_count    =>  x_msg_count  ,
               p_data    =>  x_msg_data  );

END EXECUTE_CREATE_TASK_ASGMTS;


PROCEDURE Execute_Update_Task_Asgmts
( p_api_version_number        IN  NUMBER       := PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM
 ,p_commit                                IN  VARCHAR2     := FND_API.G_FALSE
 ,p_init_msg_list                 IN  VARCHAR2     := FND_API.G_FALSE
 ,p_pm_product_code               IN  VARCHAR2     := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
 ,p_pm_project_reference      IN  VARCHAR2     := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
 ,p_pa_project_id             IN  NUMBER       := PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM
 ,p_pa_structure_version_id   IN  NUMBER       := PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM
 ,x_msg_count                     OUT NOCOPY NUMBER
 ,x_msg_data                      OUT NOCOPY VARCHAR2
 ,x_return_status                     OUT NOCOPY VARCHAR2
) IS

   l_api_name        CONSTANT  VARCHAR2(30)     := 'EXECUTE_UPDATE_TASK_ASGMTS';

   i                      NUMBER;
   l_return_status        VARCHAR2(1);
   l_err_stage            VARCHAR2(120);
   l_msg_data             VARCHAR2(2000);
   l_msg_count            NUMBER;

L_FuncProc varchar2(2000);

BEGIN
L_FuncProc := 'Execute_Update_Task_Asgmts';

IF P_DEBUG_MODE = 'Y' AND (li_curr_level <= 3) THEN
pa_debug.g_err_stage:='Entered ' || L_FuncProc;
pa_debug.write(G_PKG_NAME ,pa_debug.g_err_stage,3);
END IF;
    x_return_status :=  FND_API.G_RET_STS_SUCCESS;
--  Standard begin of API savepoint

    SAVEPOINT EXECUTE_UPDATE_TASK_ASGMTS;

--  Standard call to check for call compatibility.

    IF NOT FND_API.Compatible_API_Call ( 1.0, --g_api_version_number  ,
                               p_api_version_number,
                               l_api_name,
                               G_PKG_NAME         )
    THEN
         RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;


--  Initialize the message table if requested.

    IF FND_API.TO_BOOLEAN( p_init_msg_list )
    THEN
       FND_MSG_PUB.initialize;
    END IF;



--  Set API return status to success

    x_return_status := FND_API.G_RET_STS_SUCCESS;

        IF nvl(g_task_asgmts_tbl_count, 0) > 0 THEN

                     UPDATE_Task_Assignments
                     (  p_api_version_number         => 1.0
                      ,p_commit                          => FND_API.G_FALSE
                      ,p_init_msg_list           => FND_API.G_FALSE
                          ,p_pm_product_code         => p_pm_product_code
                          ,p_pm_project_reference    => p_pm_project_reference
                          ,p_pa_project_id           => p_pa_project_id
                          ,p_pa_structure_version_id => p_pa_structure_version_id
                          ,p_task_assignments_in     => g_task_asgmts_in_tbl
                      ,p_task_assignments_out    => g_task_asgmts_out_tbl
                      ,x_msg_count                       => l_msg_count
                      ,x_msg_data                        => l_msg_data
                      ,x_return_status               => l_return_status
                      );
                  IF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN

                         RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

                 ELSIF l_return_status = FND_API.G_RET_STS_ERROR THEN

                         RAISE FND_API.G_EXC_ERROR;

                 END IF;

    END IF;

    IF nvl(g_asgmts_periods_tbl_count,0) > 0 THEN

                     Pa_Task_Assignments_Pvt.Create_Task_Assignment_Periods
                      (p_api_version_number          => 1.0
                      ,p_commit                          => FND_API.G_FALSE
                      ,p_init_msg_list           => FND_API.G_FALSE
                          ,p_pm_product_code         => p_pm_product_code
                          ,p_pm_project_reference    => p_pm_project_reference
                          ,p_pa_project_id           => p_pa_project_id
                          ,p_pa_structure_version_id => p_pa_structure_version_id
                          ,p_task_assignment_periods_in     => g_asgmts_periods_tbl
                      ,p_task_assignment_periods_out    => g_asgmts_periods_out_tbl
                      ,x_msg_count                       => l_msg_count
                      ,x_msg_data                        => l_msg_data
                      ,x_return_status               => l_return_status
                      );

                      IF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN

                                 RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

                      ELSIF l_return_status = FND_API.G_RET_STS_ERROR THEN

                                RAISE FND_API.G_EXC_ERROR;

                      END IF;
        END IF;


  --assign appropriate values to outgoing parameters

     IF FND_API.to_boolean( p_commit ) THEN
        COMMIT;
     END IF;


EXCEPTION

  WHEN FND_API.G_EXC_ERROR
  THEN
       ROLLBACK TO EXECUTE_UPDATE_TASK_ASGMTS;

       x_return_status := FND_API.G_RET_STS_ERROR;

       FND_MSG_PUB.Count_And_Get
           (   p_count    =>  x_msg_count  ,
               p_data    =>   x_msg_data  );

  WHEN FND_API.G_EXC_UNEXPECTED_ERROR
  THEN
       ROLLBACK TO EXECUTE_UPDATE_TASK_ASGMTS;

       x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
       IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
       THEN
         FND_MSG_PUB.add_exc_msg
             ( p_pkg_name    => G_PKG_NAME
             , p_procedure_name  => l_api_name  );

       END IF;
       FND_MSG_PUB.Count_And_Get
           (   p_count    =>  x_msg_count  ,
               p_data    =>  x_msg_data  );

  WHEN OTHERS THEN
       ROLLBACK TO EXECUTE_UPDATE_TASK_ASGMTS;

       x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

       IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
       THEN
         FND_MSG_PUB.add_exc_msg
             ( p_pkg_name    => G_PKG_NAME
             , p_procedure_name  => l_api_name  );

       END IF;

       FND_MSG_PUB.Count_And_Get
           (   p_count    =>  x_msg_count  ,
               p_data    =>  x_msg_data  );

END EXECUTE_UPDATE_TASK_ASGMTS;


PROCEDURE Create_Task_Assignments
( p_api_version_number        IN   NUMBER            := PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM
 ,p_commit                                IN   VARCHAR2      := FND_API.G_FALSE
 ,p_init_msg_list                 IN   VARCHAR2      := FND_API.G_FALSE
 ,p_pm_product_code               IN   VARCHAR2      := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
 ,p_pm_project_reference      IN   VARCHAR2      := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
 ,p_pa_project_id             IN   NUMBER        := PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM
 ,p_pa_structure_version_id   IN   NUMBER        := PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM
 ,p_task_assignments_in       IN   ASSIGNMENT_IN_TBL_TYPE
 ,p_task_assignments_out      OUT  NOCOPY ASSIGNMENT_OUT_TBL_TYPE
 ,x_msg_count                     OUT  NOCOPY NUMBER
 ,x_msg_data                      OUT  NOCOPY VARCHAR2
 ,x_return_status                     OUT  NOCOPY VARCHAR2
) IS
   l_rlm_id                                              NUMBER;
   l_task_elem_version_id        NUMBER;
   l_project_id                  pa_projects_all.project_id%type;
   l_d_task_id                   NUMBER;
   l_task_assignment_id          NUMBER;
   l_msg_count                   NUMBER ;
   l_msg_data                    VARCHAR2(2000);
   l_function_allowed            VARCHAR2(1);
   l_resp_id                     NUMBER := 0;
   l_user_id                     NUMBER := 0;
   l_module_name                 VARCHAR2(80);
   l_return_status               VARCHAR2(1);
   l_api_name                    CONSTANT  VARCHAR2(30)     := 'add_task_assignments';
   i                             NUMBER;
   l_count                       NUMBER;
   l_msg_code                    VARCHAR2(30);

   l_context                     varchar2(200);
   l_calling_module              varchar2(200);
   l_struct_elem_version_id      number;
   l_budget_version_id           number;
   lk_task_elem_version_id_tbl    system.pa_num_tbl_type:= system.pa_num_tbl_type();
   lk_resource_list_member_id_tbl system.pa_num_tbl_type:= system.pa_num_tbl_type();
   l_task_elem_version_id_tbl    system.pa_num_tbl_type:= system.pa_num_tbl_type();
   l_resource_list_member_id_tbl system.pa_num_tbl_type:= system.pa_num_tbl_type();
   l_task_name_tbl               system.pa_varchar2_240_tbl_type := system.pa_varchar2_240_tbl_type();
   l_task_number_tbl             system.pa_varchar2_100_tbl_type := system.pa_varchar2_100_tbl_type();
   l_start_date_tbl              system.pa_date_tbl_type :=system.pa_date_tbl_type();
   l_end_date_tbl                system.pa_date_tbl_type := system.pa_date_tbl_type();
   l_planned_people_effort_tbl   system.pa_num_tbl_type:= system.pa_num_tbl_type();
   l_planned_equip_effort_tbl    system.pa_num_tbl_type:= system.pa_num_tbl_type();
   l_latest_eff_pub_flag_tbl     system.pa_varchar2_1_tbl_type := system.pa_varchar2_1_tbl_type();
   l_project_assignment_id_tbl   system.pa_num_tbl_type:= system.pa_num_tbl_type();
   l_quantity_tbl                system.pa_num_tbl_type:= system.pa_num_tbl_type();
   l_currency_code_tbl           system.pa_varchar2_15_tbl_type := system.pa_varchar2_15_tbl_type();
   l_raw_cost_tbl                system.pa_num_tbl_type:= system.pa_num_tbl_type();
   l_burdened_cost_tbl           system.pa_num_tbl_type:= system.pa_num_tbl_type();
   l_revenue_tbl                 system.pa_num_tbl_type:= system.pa_num_tbl_type();
   l_cost_rate_tbl               system.pa_num_tbl_type:= system.pa_num_tbl_type();
   l_bill_rate_tbl               system.pa_num_tbl_type:= system.pa_num_tbl_type();
   l_burdened_rate_tbl           system.pa_num_tbl_type:= system.pa_num_tbl_type();
   l_product_code_tbl            system.pa_varchar2_30_tbl_type := system.pa_varchar2_30_tbl_type();
   l_product_reference_tbl       system.pa_varchar2_30_tbl_type := system.pa_varchar2_30_tbl_type();  --incorrect to change to 25.
   l_attribute_category_tbl         system.pa_varchar2_30_tbl_type := system.pa_varchar2_30_tbl_type();
   l_attribute1 system.pa_varchar2_150_tbl_type := system.pa_varchar2_150_tbl_type();
   l_attribute2 system.pa_varchar2_150_tbl_type := system.pa_varchar2_150_tbl_type();
   l_attribute3 system.pa_varchar2_150_tbl_type := system.pa_varchar2_150_tbl_type();
   l_attribute4 system.pa_varchar2_150_tbl_type := system.pa_varchar2_150_tbl_type();
   l_attribute5 system.pa_varchar2_150_tbl_type := system.pa_varchar2_150_tbl_type();
   l_attribute6 system.pa_varchar2_150_tbl_type := system.pa_varchar2_150_tbl_type();
   l_attribute7 system.pa_varchar2_150_tbl_type := system.pa_varchar2_150_tbl_type();
   l_attribute8 system.pa_varchar2_150_tbl_type := system.pa_varchar2_150_tbl_type();
   l_attribute9 system.pa_varchar2_150_tbl_type := system.pa_varchar2_150_tbl_type();
   l_attribute10 system.pa_varchar2_150_tbl_type := system.pa_varchar2_150_tbl_type();
   l_attribute11 system.pa_varchar2_150_tbl_type := system.pa_varchar2_150_tbl_type();
   l_attribute12 system.pa_varchar2_150_tbl_type := system.pa_varchar2_150_tbl_type();
   l_attribute13 system.pa_varchar2_150_tbl_type := system.pa_varchar2_150_tbl_type();
   l_attribute14 system.pa_varchar2_150_tbl_type := system.pa_varchar2_150_tbl_type();
   l_attribute15 system.pa_varchar2_150_tbl_type := system.pa_varchar2_150_tbl_type();
   l_attribute16 system.pa_varchar2_150_tbl_type := system.pa_varchar2_150_tbl_type();
   l_attribute17 system.pa_varchar2_150_tbl_type := system.pa_varchar2_150_tbl_type();
   l_attribute18 system.pa_varchar2_150_tbl_type := system.pa_varchar2_150_tbl_type();
   l_attribute19 system.pa_varchar2_150_tbl_type := system.pa_varchar2_150_tbl_type();
   l_attribute20 system.pa_varchar2_150_tbl_type := system.pa_varchar2_150_tbl_type();
   l_attribute21 system.pa_varchar2_150_tbl_type := system.pa_varchar2_150_tbl_type();
   l_attribute22 system.pa_varchar2_150_tbl_type := system.pa_varchar2_150_tbl_type();
   l_attribute23 system.pa_varchar2_150_tbl_type := system.pa_varchar2_150_tbl_type();
   l_attribute24 system.pa_varchar2_150_tbl_type := system.pa_varchar2_150_tbl_type();
   l_attribute25 system.pa_varchar2_150_tbl_type := system.pa_varchar2_150_tbl_type();
   l_attribute26 system.pa_varchar2_150_tbl_type := system.pa_varchar2_150_tbl_type();
   l_attribute27 system.pa_varchar2_150_tbl_type := system.pa_varchar2_150_tbl_type();
   l_attribute28 system.pa_varchar2_150_tbl_type := system.pa_varchar2_150_tbl_type();
   l_attribute29 system.pa_varchar2_150_tbl_type := system.pa_varchar2_150_tbl_type();
   l_attribute30 system.pa_varchar2_150_tbl_type := system.pa_varchar2_150_tbl_type();
   --Added following two collections for for Bug 3940284
   l_delete_task_res_asgmt_id_tbl system.pa_num_tbl_type := system.pa_num_tbl_type();
   l_delete_task_elem_ver_id_tbl  system.pa_num_tbl_type := system.pa_num_tbl_type();

   --This table is added for Bug 3948128: TA Delay CR by DHI
   l_scheduled_delay_tbl          system.pa_num_tbl_type:= system.pa_num_tbl_type();

   CURSOR C_Get_Budget_Version_Id(p_structure_version_id IN NUMBER) is
   select budget_version_id
   from pa_budget_versions
   where project_structure_version_id = p_structure_version_id
   and project_id = p_pa_project_id;


   CURSOR C_Task_Elem_Version_Id(p_structure_version_id IN NUMBER,
                                 p_task_id in NUMBER,
                                 p_project_id IN NUMBER) IS
   SELECT pe.element_version_id
   from pa_proj_element_versions pe
   where parent_structure_version_id = p_structure_version_id
   and pe.proj_element_id = p_task_id
   and pe.project_id = p_project_id;

   CURSOR C_task_version(p_task_element_version_id IN NUMBER) IS
   SELECT pe.element_version_id, pe.proj_element_id
   from pa_proj_element_versions pe
   where pe.element_version_id = p_task_element_version_id;


    CURSOR c_cur_out(p_structure_version_id IN NUMBER,
                    p_project_id IN NUMBER,
                                        p_wbs_version_id IN NUMBER,
                                        p_resource_list_member_id IN NUMBER ) IS
   Select a.alias, b.resource_assignment_id
   from pa_resource_list_members a, pa_resource_assignments b, pa_budget_versions bv
   where a.resource_list_member_id = b.resource_list_member_id
   and b.resource_list_member_id = p_resource_list_member_id
   and b.ta_display_flag = 'Y'
   and b.budget_version_id = bv.budget_version_id
   and b.project_id = bv.project_id
   and bv.project_structure_version_id = p_structure_version_id
   and b.project_id = p_project_id
   and b.wbs_element_version_id = p_wbs_version_id;
    c_rec_out c_cur_out%ROWTYPE;


   CURSOR C_Res_List_mem_Check(p_resource_list_member_id IN NUMBER) IS
   SELECT 'X', resource_class_code
   from pa_resource_list_members
   where resource_list_member_id = p_resource_list_member_id;
   C_Res_List_Mem_Check_Rec C_Res_List_Mem_Check%ROWTYPE;

   -- Bug 4087956
--   Cursor C_Reference_Check(p_res_assignment_reference IN VARCHAR2) IS
   Cursor C_Reference_Check(p_res_assignment_reference IN VARCHAR2, c_budget_version_id IN NUMBER) IS
   select 'X'
   from pa_resource_assignments  a --, pa_budget_versions b
   where a.pm_res_assignment_reference = p_res_assignment_reference
   and a.pm_product_code = p_pm_product_code
   and a.project_id = p_pa_project_id
   and a.ta_display_flag is not null
   and a.budget_version_id = c_budget_version_id;
--   and b.project_structure_version_id = p_pa_structure_version_id
--   and a.budget_version_id = b.budget_version_id
--   and a.project_id = b.project_id;
   C_Reference_rec c_Reference_Check%ROWTYPE;


   CURSOR c_unique_res_check(p_structure_version_id IN NUMBER,
                    p_project_id IN NUMBER,
                                        p_wbs_version_id IN NUMBER,
                                        p_resource_list_member_id IN NUMBER ) IS
   Select 'X'
   from pa_resource_assignments b, pa_budget_versions bv
   where b.resource_list_member_id = p_resource_list_member_id
   and b.ta_display_flag is not null
   and b.budget_version_id = bv.budget_version_id
   and b.project_id = bv.project_id
   and bv.project_structure_version_id = p_structure_version_id
   and b.project_id = p_project_id
   and b.wbs_element_version_id = p_wbs_version_id;
   c_unique_res_rec c_unique_res_check%ROWTYPE;

   CURSOR c_people_res_check(p_structure_version_id IN NUMBER,
                    p_project_id IN NUMBER,
                                        p_wbs_version_id IN NUMBER
                                         ) IS
   Select b.budget_version_id
   from pa_resource_assignments b, pa_budget_versions bv
   where b.ta_display_flag = 'N'
   and b.budget_version_id = bv.budget_version_id
   and b.project_id = bv.project_id
   and bv.project_structure_version_id = p_structure_version_id
   and b.project_id = p_project_id
   and b.wbs_element_version_id = p_wbs_version_id
   and b.resource_class_code='PEOPLE'
   and b.pm_product_code is not NULL;
   c_people_res_rec c_people_res_check%ROWTYPE;

   CURSOR C_Workplan_Costs_enabled(p_budget_version_id IN NUMBER) IS
        select TRACK_WORKPLAN_COSTS_FLAG enabled_flag from pa_proj_fp_options
    where fin_plan_version_id = p_budget_version_id;
        C_Workplan_costs_rec C_Workplan_Costs_enabled%ROWTYPE;

   CURSOR C_Check_Res_List_None (c_resource_list_id IN NUMBER) IS
     SELECT uncategorized_flag
       FROM pa_resource_lists
      WHERE resource_list_id = c_resource_list_id;

   k_index NUMBER := 0;

L_FuncProc varchar2(2000);

l_valid_member_flag varchar2(1);
l_resource_list_id number;
none_resource_list_flag varchar2(1);
l_resource_list_member_id number;

   -- Changes for Bug 3910882 Begin
   l_num_of_tasks NUMBER;
   l_db_block_size NUMBER;
   l_num_blocks NUMBER;

   CURSOR C_Get_Default_Res_Asgmt(p_project_id IN NUMBER,
                                  p_budget_version_id IN NUMBER)
   IS
   SELECT resource_assignment_id, wbs_element_version_id
   FROM pa_resource_assignments ra, pa_copy_asgmts_temp cat
   WHERE ra.wbs_element_version_id = cat.src_elem_ver_id
   AND ra.project_id = p_project_id
   AND ra.budget_version_id = p_budget_version_id
   AND ra.ta_display_flag = 'N';

   -- Changes for Bug 3910882 End


BEGIN

L_FuncProc := 'Create_Task_Asgmts';

IF P_DEBUG_MODE = 'Y' AND (li_curr_level <= 3) THEN
pa_debug.g_err_stage:='Entered ' || L_FuncProc ;
pa_debug.write(G_PKG_NAME ,pa_debug.g_err_stage,3);
END IF;

--  Standard begin of API savepoint

    SAVEPOINT add_task_asgmts_pub;

--  Standard call to check for call compatibility.

     IF NOT FND_API.Compatible_API_Call ( 1.0, --pa_project_pub.g_api_version_number  ,
                               p_api_version_number  ,
                               l_api_name         ,
                               G_PKG_NAME         )
    THEN

          RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

    END IF;

  --dbms_output.put_line('Fnd Api is compatible:');

--  Initialize the message table if requested.

    IF FND_API.TO_BOOLEAN( p_init_msg_list )
    THEN

  FND_MSG_PUB.initialize;

    END IF;

--  Set API return status to success

    x_return_status := FND_API.G_RET_STS_SUCCESS;

    --  Initialize the message table if requested.
    --  pm_product_code is mandatory

 --dbms_output.put_line('Initialized message table.');

IF P_DEBUG_MODE = 'Y' AND (li_curr_level <= 3) THEN
 pa_debug.g_err_stage:='Checking p_pm_product_code ' || L_FuncProc;
 pa_debug.write(G_PKG_NAME ,pa_debug.g_err_stage,3);
END IF;

    IF p_pm_product_code IS NOT NULL
          AND p_pm_product_code = PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR   THEN

                       IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.G_MSG_LVL_ERROR) THEN
                                 pa_interface_utils_pub.map_new_amg_msg
                                   ( p_old_message_code => 'PA_PRODUCT_CODE_IS_MISSING'
                                    ,p_msg_attribute    => 'CHANGE'
                                    ,p_resize_flag      => 'N'
                                    ,p_msg_context      => 'GENERAL'
                                    ,p_attribute1       => ''
                                    ,p_attribute2       => ''
                                    ,p_attribute3       => ''
                                    ,p_attribute4       => ''
                                    ,p_attribute5       => '');
                       END IF;
               RAISE FND_API.G_EXC_ERROR;

    END IF;

 --dbms_output.put_line('Product Code is checked:');

    l_resp_id := FND_GLOBAL.Resp_id;
    l_user_id := FND_GLOBAL.User_id;

IF P_DEBUG_MODE = 'Y' AND (li_curr_level <= 3) THEN
    pa_debug.g_err_stage:='User id :' || l_user_id || 'l_resp_id' || l_resp_id;
    pa_debug.write(G_PKG_NAME ,pa_debug.g_err_stage,3);

    pa_debug.g_err_stage:=' p_pm_product_code check successful.' || L_FuncProc;
    pa_debug.write(G_PKG_NAME ,pa_debug.g_err_stage,3);
END IF;

    l_module_name := 'PA_PM_ADD_TASK_ASSIGNMENT';

--> Project Id check.

        IF p_pa_project_id is NOT NULL AND p_pa_project_id <> PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM THEN

                  l_project_id := p_pa_project_id;

                 --dbms_output.put_line('Project_id successfully passed..Check ' || l_project_id);

         ELSE
                 --dbms_output.put_line('Converting Project ref to id:' || p_pm_project_reference);
                        PA_PROJECT_PVT.Convert_pm_projref_to_id
                        (           p_pm_project_reference =>      p_pm_project_reference
                                 ,  p_pa_project_id     =>      p_pa_project_id
                                 ,  p_out_project_id    =>      l_project_id
                                 ,  p_return_status     =>      l_return_status
                        );

                        IF (l_return_status = FND_API.G_RET_STS_UNEXP_ERROR) THEN

                                       --dbms_output.put_line('Project_id not successful ');
IF P_DEBUG_MODE = 'Y' AND (li_curr_level <= 3) THEN
                                       pa_debug.g_err_stage:=' Project ref to id check not successful.' || L_FuncProc;
                               pa_debug.write(G_PKG_NAME ,pa_debug.g_err_stage,3);
END IF;
                                RAISE  FND_API.G_EXC_UNEXPECTED_ERROR;

                        ELSIF  (l_return_status = FND_API.G_RET_STS_ERROR) THEN

                                       --dbms_output.put_line('Project_id conv. not successful ');
IF P_DEBUG_MODE = 'Y' AND (li_curr_level <= 3) THEN
                                       pa_debug.g_err_stage:=' Project ref to id check not successful.' || L_FuncProc;
                               pa_debug.write(G_PKG_NAME ,pa_debug.g_err_stage,3);
END IF;
                               RAISE  FND_API.G_EXC_ERROR;

                        END IF;
        END IF;

         --dbms_output.put_line('Project ref to id check successful for Project ' || l_Project_id);
IF P_DEBUG_MODE = 'Y' AND (li_curr_level <= 3) THEN
        pa_debug.g_err_stage:=' Project ref to id check successful.' || L_FuncProc;
        pa_debug.write(G_PKG_NAME ,pa_debug.g_err_stage,3);
END IF;
    -- As part of enforcing project security, which would determine
    -- whether the user has the necessary privileges to update the project
    -- need to call the pa_security package

    pa_security.initialize (X_user_id        => l_user_id,
                            X_calling_module => l_module_name);
IF P_DEBUG_MODE = 'Y' AND (li_curr_level <= 3) THEN
        pa_debug.g_err_stage:=' After initializing security..' || L_FuncProc;
        pa_debug.write(G_PKG_NAME ,pa_debug.g_err_stage,3);
END IF;
    -- Actions performed using the APIs would be subject to
    -- function security. If the responsibility does not allow
    -- such functions to be executed, the API should not proceed further
    -- since the user does not have access to such functions

    -- Function security procedure check whether user have the
    -- privilege to add task or not
       --dbms_output.put_line('Security Initialize successful.');
      PA_INTERFACE_UTILS_PUB.G_PROJECT_ID := l_project_id;  --bug 2471668 ( in the project context )

      PA_PM_FUNCTION_SECURITY_PUB.check_function_security
      (p_api_version_number => p_api_version_number,
       p_responsibility_id  => l_resp_id,
       p_function_name      => 'PA_PM_ADD_TASK_ASSIGNMENT',
       p_msg_count      => l_msg_count,
       p_msg_data           => l_msg_data,
       p_return_status      => l_return_status,
       p_function_allowed   => l_function_allowed);

       IF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR
       THEN
           RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

       ELSIF l_return_status = FND_API.G_RET_STS_ERROR
       THEN
            RAISE FND_API.G_EXC_ERROR;
       END IF;

IF P_DEBUG_MODE = 'Y' AND (li_curr_level <= 3) THEN
                pa_debug.g_err_stage:=' PA_PM_ADD_TASK_ASSIGNMENT function check successful.' || L_FuncProc;
        pa_debug.write(G_PKG_NAME ,pa_debug.g_err_stage,3);
END IF;
        --dbms_output.put_line('PA_PM_ADD_TASK_ASSIGNMENT function check successful.');
       IF l_function_allowed = 'N' THEN
                 pa_interface_utils_pub.map_new_amg_msg
                   ( p_old_message_code => 'PA_FUNCTION_SECURITY_ENFORCED'
                    ,p_msg_attribute    => 'CHANGE'
                    ,p_resize_flag      => 'Y'
                    ,p_msg_context      => 'GENERAL'
                    ,p_attribute1       => ''
                    ,p_attribute2       => ''
                    ,p_attribute3       => ''
                    ,p_attribute4       => ''
                    ,p_attribute5       => '');
                 RAISE FND_API.G_EXC_ERROR;
       END IF;
           --dbms_output.put_line('PA_FUNCTION_SECURITY_ENFORCED function check successful.');
IF P_DEBUG_MODE = 'Y' AND (li_curr_level <= 3) THEN
      pa_debug.g_err_stage:=' PA_FUNCTION_SECURITY_ENFORCED function check successful.' || L_FuncProc;
        pa_debug.write(G_PKG_NAME ,pa_debug.g_err_stage,3);
END IF;



      -- Now verify whether project security allows the user to update
      -- the project
      -- The user does not have query privileges on this project
      -- Hence, cannot update the project.Raise error
          -- If the user has query privileges, then check whether
      -- update privileges are also available

      IF pa_security.allow_query(x_project_id => l_project_id ) = 'N' OR
             pa_security.allow_update(x_project_id => l_project_id ) = 'N' THEN

                    -- The user does not have update privileges on this project
                    -- Hence , raise error
                 --dbms_output.put_line('pa_security.allow_query or update not allowed..');
                 pa_interface_utils_pub.map_new_amg_msg
                   ( p_old_message_code => 'PA_PROJECT_SECURITY_ENFORCED'
                    ,p_msg_attribute    => 'CHANGE'
                    ,p_resize_flag      => 'Y'
                    ,p_msg_context      => 'GENERAL'
                    ,p_attribute1       => ''
                    ,p_attribute2       => ''
                    ,p_attribute3       => ''
                    ,p_attribute4       => ''
                    ,p_attribute5       => '');
                 RAISE FND_API.G_EXC_ERROR;
     END IF;

         --dbms_output.put_line('pa_security.allow_query or update  successful..');
IF P_DEBUG_MODE = 'Y' AND (li_curr_level <= 3) THEN
         pa_debug.g_err_stage:='PA_PROJECT_SECURITY_ENFORCED function check successful.' || L_FuncProc;
     pa_debug.write(G_PKG_NAME ,pa_debug.g_err_stage,3);
END IF;

         --dbms_output.put_line('Project Id:'  || l_project_id);
         begin

          IF  NVL(PA_PROJ_TASK_STRUC_PUB.WP_STR_EXISTS( l_project_id ), 'N') = 'N' THEN
                        IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.G_MSG_LVL_ERROR)
                        THEN
                                   --dbms_output.put_line('PA_PROJ_TASK_STRUC_PUB.WP_STR_EXISTS IS N..');
                            pa_interface_utils_pub.map_new_amg_msg
                              ( p_old_message_code => 'PA_PS_WP_NOT_SEP_FN_AMG'
                                  ,p_msg_attribute    => 'CHANGE'
                                  ,p_resize_flag      => 'N'
                                  ,p_msg_context      => 'GENERAL'
                                  ,p_attribute1       => ''
                                  ,p_attribute2       => ''
                                  ,p_attribute3       => ''
                                  ,p_attribute4       => ''
                                  ,p_attribute5       => '');
                        END IF;
                RAISE FND_API.G_EXC_ERROR;
        END IF;
         exception when others then
         null;
         end;

   --dbms_output.put_line('PA_PROJ_TASK_STRUC_PUB.WP_STR_EXISTS IS Fine..');
IF P_DEBUG_MODE = 'Y' AND (li_curr_level <= 3) THEN
   pa_debug.g_err_stage:='PA_PROJ_TASK_STRUC_PUB.WP_STR_EXISTS function check successful.' || L_FuncProc;
   pa_debug.write(G_PKG_NAME ,pa_debug.g_err_stage,3);
END IF;

                IF  p_pa_structure_version_id IS NOT NULL AND
                    (p_pa_structure_version_id <> PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM) THEN

                                 l_struct_elem_version_id := p_pa_structure_version_id;

                 ELSE
                     --dbms_output.put_line('Getting current structure version'  );
                     l_struct_elem_version_id := PA_PROJECT_STRUCTURE_UTILS.get_current_working_ver_id(
                                                     p_project_id => l_project_id);
                 END IF;

                    --dbms_output.put_line(' structure version is: ' || l_struct_elem_version_id );
            --dbms_output.put_line(' testing str if..' );
        IF ( l_struct_elem_version_id IS NULL OR
                     l_struct_elem_version_id = PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM
              )

       THEN
           --dbms_output.put_line(' test struct.null or g miss..');

                    IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.G_MSG_LVL_ERROR)
                    THEN
                                        --dbms_output.put_line(' test struct.null or gmiss err..');
                               pa_interface_utils_pub.map_new_amg_msg
                                    ( p_old_message_code => 'PA_PS_STRUC_VER_REQ'
                                     ,p_msg_attribute    => 'CHANGE'
                                     ,p_resize_flag      => 'N'
                                     ,p_msg_context      => 'GENERAL'
                                     ,p_attribute1       => ''
                                     ,p_attribute2       => ''
                                     ,p_attribute3       => ''
                                     ,p_attribute4       => ''
                                     ,p_attribute5       => '');
                    END IF;
            RAISE FND_API.G_EXC_ERROR;
       END IF;

       -- DHI ER: allowing multiple user to update task assignment
       --         Removed logic to lock version.
       -- pa_task_assignments_pvt.lock_version(l_project_id, l_struct_elem_version_id);

       -- Bug 3940853: Raise locking error return from structure API
       IF FND_MSG_PUB.count_msg > 0 THEN
         x_return_status := FND_API.G_RET_STS_ERROR;
         RAISE FND_API.G_EXC_ERROR;
       END IF;

        IF 'N' = pa_task_assignment_utils.check_edit_task_ok
                                        ( P_PROJECT_ID              => l_project_id,
                                          P_STRUCTURE_VERSION_ID    => l_struct_elem_version_id,
                                          P_CURR_STRUCT_VERSION_ID  => l_struct_elem_version_id) THEN
                                                                                                        -- Bug 4533152
                        --PA_UTILS.ADD_MESSAGE
                        --       (p_app_short_name => 'PA',
                        --        p_msg_name       => 'PA_UPDATE_PUB_VER_ERR'
                        --        );
                        x_return_status := FND_API.G_RET_STS_ERROR;
                 RAISE FND_API.G_EXC_ERROR;
       END IF;

           --dbms_output.put_line(' check edit successful' );
IF P_DEBUG_MODE = 'Y' AND (li_curr_level <= 3) THEN
                pa_debug.g_err_stage:='struct_elem version id function check successful.' || L_FuncProc;
        pa_debug.write(G_PKG_NAME ,pa_debug.g_err_stage,3);
END IF;



                OPEN C_Get_Budget_Version_Id(l_struct_elem_version_id);
                FETCH C_Get_Budget_Version_Id INTO l_budget_version_id;
                CLOSE C_Get_Budget_Version_Id;

      IF ( l_budget_version_id = PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM OR
            l_budget_version_id IS NULL  )
       THEN
           --dbms_output.put_line(' budget version not obtained.. successful' );
                    IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.G_MSG_LVL_ERROR)
                    THEN
                                PA_UTILS.ADD_MESSAGE
                                       (p_app_short_name => 'PA',
                                        p_msg_name       => 'PA_FP_PROJ_VERSION_MISMATCH'
                                        );
                    END IF;
                 x_return_status    := FND_API.G_RET_STS_ERROR;
                 RAISE FND_API.G_EXC_ERROR;

       END IF;

        -- Check if the resource list is None for the workplan
        l_resource_list_id := PA_TASK_ASSIGNMENT_UTILS.Get_WP_Resource_List_Id(l_project_id);

        none_resource_list_flag := 'N';

        OPEN C_Check_Res_List_None(l_resource_list_id);
        FETCH C_Check_Res_List_None INTO none_resource_list_flag;
        CLOSE C_Check_Res_List_None;

        IF none_resource_list_flag = 'Y' THEN
          IF p_pm_product_code = 'MSPROJECT'
          THEN
            PA_UTILS.ADD_MESSAGE( p_app_short_name => 'PA'
                                 ,p_msg_name       => 'PA_RES_LIST_NONE_ERR_MSP'
                                 ,p_token1 => 'TASK_NAME'  -- Bug 6497559
                                 ,p_value1 => PA_TASK_UTILS.get_task_name(p_task_assignments_in(i).pa_task_id)
                                 ,p_token2 => 'TASK_NUMBER'
                                 ,p_value2 => PA_TASK_UTILS.get_task_name(p_task_assignments_in(i).pa_task_id)
                                );
            x_return_status := FND_API.G_RET_STS_ERROR;
            RAISE FND_API.G_EXC_ERROR;
          ELSE
            PA_UTILS.ADD_MESSAGE( p_app_short_name => 'PA'
                                 ,p_msg_name       => 'PA_RES_LIST_NONE_ERR_AMG'
                                 ,p_token1 => 'TASK_ID'  -- Bug 6497559
                                 ,p_value1 => p_task_assignments_in(i).pa_task_id
                                );
            x_return_status := FND_API.G_RET_STS_ERROR;
            RAISE FND_API.G_EXC_ERROR;
          END IF;
        END IF;

          --dbms_output.put_line(' budget version id: ' || l_budget_version_id );

        l_count := p_task_assignments_in.COUNT;

IF P_DEBUG_MODE = 'Y' AND (li_curr_level <= 3) THEN
         pa_debug.g_err_stage:='Count of task assignments' || l_count || ':' || L_FuncProc;
         pa_debug.write(G_PKG_NAME ,pa_debug.g_err_stage,3);
END IF;


        --dbms_output.put_line(' Input Count of Global Input Tables..: ' || l_count );

        --dbms_output.put_line(' Prior to Loading internal Tables..for Count:' || l_Count );

        l_task_elem_version_id_tbl.extend(l_count);
        l_resource_list_member_id_tbl.extend(l_count);
         --dbms_output.put_line('l_count 1'|| l_count);
        l_task_name_tbl.extend(l_count);

        l_task_number_tbl.extend(l_count);

        l_start_date_tbl.extend(l_count);

        l_end_date_tbl.extend(l_count);

        l_planned_people_effort_tbl.extend(l_count);

        l_planned_equip_effort_tbl.extend(l_count);

        l_latest_eff_pub_flag_tbl.extend(l_count);

        l_project_assignment_id_tbl.extend(l_count);

        l_quantity_tbl.extend(l_count);

        l_currency_code_tbl.extend(l_count);

        l_raw_cost_tbl.extend(l_count);

        l_burdened_cost_tbl.extend(l_count);

        l_product_code_tbl.extend(l_count);

         l_product_reference_tbl.extend(l_count);
         --dbms_output.put_line('l_count 2'|| l_count);
        l_attribute_category_tbl.extend(l_count);
     --dbms_output.put_line('l_count 3'|| l_count);
        l_attribute1.extend(l_count);

        l_attribute2.extend(l_count);

        l_attribute3.extend(l_count);

        l_attribute4.extend(l_count);

        l_attribute5.extend(l_count);

        l_attribute6.extend(l_count);

        l_attribute7.extend(l_count);

        l_attribute8.extend(l_count);

        l_attribute9.extend(l_count);

        l_attribute10.extend(l_count);

        l_attribute11.extend(l_count);

        l_attribute12.extend(l_count);

        l_attribute13.extend(l_count);

        l_attribute14.extend(l_count);

        l_attribute15.extend(l_count);

        l_attribute16.extend(l_count);

        l_attribute17.extend(l_count);

        l_attribute18.extend(l_count);

        l_attribute19.extend(l_count);

        l_attribute20.extend(l_count);

        l_attribute21.extend(l_count);

        l_attribute22.extend(l_count);

        l_attribute23.extend(l_count);

        l_attribute24.extend(l_count);

        l_attribute25.extend(l_count);

        l_attribute26.extend(l_count);

        l_attribute27.extend(l_count);

        l_attribute28.extend(l_count);

        l_attribute29.extend(l_count);

        l_attribute30.extend(l_count);

        l_scheduled_delay_tbl.extend(l_count); --Bug 3948128

         --dbms_output.put_line('l_count 4'|| l_count);
 FOR i in 1..l_count LOOP

            --dbms_output.put_line('Start of Loading internal Create Tables i index is:' || i);
            --dbms_output.put_line('l_count'|| l_count);
                IF p_task_assignments_in.exists(i) THEN
                   --dbms_output.put_line('Exists :' || i);
                           NULL;
                END IF;
                IF p_task_assignments_in.exists(l_count) THEN
                       NUll;
                   --dbms_output.put_line('Exists :' || l_count);
               else
                       null;
                   --dbms_output.put_line('Not Exists :' || l_count);
                END IF;

            --dbms_output.put_line('task_id' || i|| ':' || p_task_assignments_in(i).pa_task_id);
                --dbms_output.put_line('task_ref' || i || ':' || p_task_assignments_in(i).pm_task_reference);
            --dbms_output.put_line('task_id' || l_count|| ':' || p_task_assignments_in(l_count).pa_task_id);
                --dbms_output.put_line('task_ref' || l_count|| ':' || p_task_assignments_in(l_count).pm_task_reference);

        l_d_task_id := NULL;
        l_task_elem_version_id := NULL;

        IF p_task_assignments_in.exists(i) AND p_task_assignments_in(i).pa_task_element_version_id IS NOT NULL AND
                 p_task_assignments_in(i).pa_task_element_version_id <> PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM THEN
             OPEN C_task_version(p_task_assignments_in(i).pa_task_element_version_id);
                 FETCH C_task_version INTO l_task_elem_version_id, l_d_task_id;
                 CLOSE C_task_version;


        ELSIF p_task_assignments_in.exists(i) AND p_task_assignments_in(i).pa_task_id IS NOT NULL AND
           p_task_assignments_in(i).pa_task_id <> PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM THEN

                        l_d_task_id := p_task_assignments_in(i).pa_task_id;

                         --dbms_output.put_line('l_d_task_id valid input:'|| l_d_task_id);

IF P_DEBUG_MODE = 'Y' AND (li_curr_level <= 3) THEN
                         pa_debug.g_err_stage:='task_id ' || l_d_task_id;
                         pa_debug.write(G_PKG_NAME ,pa_debug.g_err_stage,3);
END IF;

                         --dbms_output.put_line('l_d_task_id'|| l_d_task_id);

                          IF ( l_d_task_id = PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM OR
                                 l_d_task_id IS NULL  )
                            THEN
                                         IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.G_MSG_LVL_ERROR)
                                         THEN
                                                  PA_UTILS.ADD_MESSAGE
                                                            (p_app_short_name => 'PA',
                                                             p_msg_name       => 'PA_TASK_REQUIRED'
                                                             );
                                         END IF;

                                 RAISE FND_API.G_EXC_ERROR;
                            END IF;

                         l_task_elem_version_id := PA_PROJ_ELEMENTS_UTILS.GET_TASK_VERSION_ID(p_structure_version_id => l_struct_elem_version_id
                                          ,p_task_id => l_d_task_id);


        ELSIF p_task_assignments_in.exists(i) AND
              p_task_assignments_in(i).pm_task_reference IS NOT NULL AND
              p_task_assignments_in(i).pm_task_reference <> PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR THEN

         --dbms_output.put_line('l_d_task_reference'|| p_task_assignments_in(i).pm_task_reference);



                   PA_PROJECT_PVT.CONVERT_PM_TASKREF_TO_ID_all(p_pa_project_id => l_project_id
                                                      ,p_pm_task_reference => p_task_assignments_in(i).pm_task_reference
                                                      ,p_structure_type => 'WORKPLAN'
                                                      ,p_out_task_id => l_d_task_id
                                                      ,p_return_status => l_return_status);

                        --dbms_output.put_line('l_d_task_id'|| l_d_task_id);

                           IF ( l_d_task_id = PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM OR
                                l_d_task_id IS NULL  )
                           THEN
                                IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.G_MSG_LVL_ERROR)
                                THEN
                                          PA_UTILS.ADD_MESSAGE
                                                   (p_app_short_name => 'PA',
                                                    p_msg_name       => 'PA_TASK_REQUIRED'
                                                    );
                                END IF;

                                RAISE FND_API.G_EXC_ERROR;
                            END IF;



                        l_task_elem_version_id := PA_PROJ_ELEMENTS_UTILS.GET_TASK_VERSION_ID(p_structure_version_id => l_struct_elem_version_id
                                          ,p_task_id => l_d_task_id);

        END IF;



    IF ( l_task_elem_version_id = PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM OR
            l_task_elem_version_id IS NULL  )
       THEN
           IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.G_MSG_LVL_ERROR)
            THEN
                          PA_UTILS.ADD_MESSAGE
                               (p_app_short_name => 'PA',
                                p_msg_name       => 'PA_TASK_VERSION_REQUIRED'
                                );
            END IF;

            RAISE FND_API.G_EXC_ERROR;

       END IF;

        --dbms_output.put_line('task elem version id ' || l_task_elem_version_id );

IF P_DEBUG_MODE = 'Y' AND (li_curr_level <= 3) THEN
        pa_debug.g_err_stage:='task_elem version id ' || l_task_elem_version_id ;
        pa_debug.write(G_PKG_NAME ,pa_debug.g_err_stage,3);
END IF;

        --dbms_output.put_line('Assign all input variables to tabular form for api input.');

   IF l_task_elem_version_id IS NOT NULL THEN

                 k_index := k_index + 1;

                lk_task_elem_version_id_tbl.extend(1);
                lk_resource_list_member_id_tbl.extend(1);

                 l_task_elem_version_id_tbl(k_index) := l_task_elem_version_id;

                 lk_task_elem_version_id_tbl(k_index) := l_task_elem_version_id;
         --dbms_output.put_line('test 1:');
                IF p_task_assignments_in(i).resource_list_member_id IS NOT NULL AND
                   p_task_assignments_in(i).resource_list_member_id <> PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM THEN


                       OPEN C_Res_List_Mem_Check(p_task_assignments_in(i).resource_list_member_id);
                       Fetch C_Res_List_Mem_Check into C_Res_List_Mem_Check_Rec;
                       Close C_Res_List_Mem_Check;

                ELSE

                            IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.G_MSG_LVL_ERROR)
                            THEN
                              IF p_pm_product_code = 'MSPROJECT'
                              THEN
                                PA_UTILS.ADD_MESSAGE( p_app_short_name => 'PA'
                                                     ,p_msg_name       => 'PA_INVALID_RES_LIST_MEM_ID_MSP'
                                                     ,p_token1 => 'PLANNING_RESOURCE_NAME'  -- Bug 6497559
                                                     ,p_value1 => PA_TASK_UTILS.get_resource_name(p_task_assignments_in(i).resource_list_member_id)
                                                    );
                                x_return_status := FND_API.G_RET_STS_ERROR;
                                RAISE FND_API.G_EXC_ERROR;
                              ELSE
                                PA_UTILS.ADD_MESSAGE( p_app_short_name => 'PA'
                                                     ,p_msg_name       => 'PA_INVALID_RES_LIST_MEM_ID_AMG'
                                                     ,p_token1 => 'PLANNING_RESOURCE_ID'  -- Bug 6497559
                                                     ,p_value1 => p_task_assignments_in(i).resource_list_member_id
                                                    );
                                x_return_status := FND_API.G_RET_STS_ERROR;
                                RAISE FND_API.G_EXC_ERROR;
                              END IF;
                             END IF;
                END IF;

                PA_PLANNING_RESOURCE_UTILS.check_list_member_on_list(
                       p_resource_list_id          => l_resource_list_id,
                       p_resource_list_member_id   => p_task_assignments_in(i).resource_list_member_id,
                       p_project_id                => l_project_id,
                       p_chk_enabled               => 'Y',
                       x_resource_list_member_id   => l_rlm_id,
                       x_valid_member_flag         => l_valid_member_flag,
                       x_return_status             => x_return_status,
                       x_msg_count                 => x_msg_count,
                       x_msg_data                  => x_msg_data ) ;

                IF l_valid_member_flag = 'N' THEN
                       x_return_status := FND_API.G_RET_STS_ERROR;
                       RAISE FND_API.G_EXC_ERROR;
                END IF;

                IF p_task_assignments_in(i).start_date IS NOT NULL and
                   p_task_assignments_in(i).start_date <> PA_INTERFACE_UTILS_PUB.G_PA_MISS_DATE and
                   p_task_assignments_in(i).end_date IS NOT NULL and
                   p_task_assignments_in(i).end_date <> PA_INTERFACE_UTILS_PUB.G_PA_MISS_DATE and
                          p_task_assignments_in(i).start_date > p_task_assignments_in(i).end_date THEN

                                IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.G_MSG_LVL_ERROR) THEN
                                  IF p_pm_product_code = 'MSPROJECT'
                                  THEN
                                    PA_UTILS.ADD_MESSAGE( p_app_short_name => 'PA'
                                                         ,p_msg_name       => 'PA_INVALID_DATES_MSP'
                                                         ,p_token1 => 'TASK_NAME'  -- Bug 6497559
                                                         ,p_value1 => PA_TASK_UTILS.get_task_name(p_task_assignments_in(i).pa_task_id)
                                                         ,p_token2 => 'TASK_NUMBER'
                                                         ,p_value2 => PA_TASK_UTILS.get_task_name(p_task_assignments_in(i).pa_task_id)
                                                        );
                                    x_return_status := FND_API.G_RET_STS_ERROR;
                                    RAISE FND_API.G_EXC_ERROR;
                                  ELSE
                                    PA_UTILS.ADD_MESSAGE( p_app_short_name => 'PA'
                                                         ,p_msg_name       => 'PA_INVALID_DATES_AMG'
                                                         ,p_token1 => 'TASK_ID'  -- Bug 6497559
                                                         ,p_value1 => p_task_assignments_in(i).pa_task_id
                                                        );
                                    x_return_status := FND_API.G_RET_STS_ERROR;
                                    RAISE FND_API.G_EXC_ERROR;
                                  END IF;
                             END IF;

                END IF;

         --dbms_output.put_line('test 7:');
                IF p_task_assignments_in(i).pm_task_asgmt_reference IS NULL OR
                       p_task_assignments_in(i).pm_task_asgmt_reference =  PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR   THEN
                           --dbms_output.put_line('pm_task_asgmt_reference is NULL/G_MISS...error');
                            IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.G_MSG_LVL_ERROR)
                       THEN
                                  PA_UTILS.ADD_MESSAGE
                                          (p_app_short_name => 'PA',
                                           p_msg_name       => 'PA_PM_TASK_ASGMT_REF_REQ'
                                           );
                       END IF;
                                x_return_status    := FND_API.G_RET_STS_ERROR;
                       RAISE FND_API.G_EXC_ERROR;

                END IF;

           --dbms_output.put_line('pm_task_asgmt_reference is NULL/G_MISS..check passed');
                -- Bug 4087956
                OPEN C_Reference_Check(p_task_assignments_in(i).pm_task_asgmt_reference, l_budget_version_id);
                FETCH C_Reference_Check into C_Reference_Rec;
                IF C_Reference_Check%FOUND THEN
                 --dbms_output.put_line('pm_task_asgmt_reference is EXISTING error');
                              IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.G_MSG_LVL_ERROR)
                               THEN
                                          --CLOSE C_Reference_Check;  Bug 3937017
                                          PA_UTILS.ADD_MESSAGE
                                                  (p_app_short_name => 'PA'
                                                  ,p_msg_name       => 'PA_DUPLICATE_TA_REF'
                                                  ,p_token1 => 'TASK_ASGMT_REF'  -- Bug 6497559
                                                  ,p_value1 => p_task_assignments_in(i).pm_task_asgmt_reference
                                                  ,p_token2 => 'BUDGET_VER_ID'
                                                  ,p_value2 => l_budget_version_id
                                                   );
                               END IF;
                               -- Bug 3937017 Moved Close cursor
                               CLOSE C_Reference_Check;
                                x_return_status    := FND_API.G_RET_STS_ERROR;
                       RAISE FND_API.G_EXC_ERROR;
                  END IF;
                Close C_Reference_Check;
                 --dbms_output.put_line('pm_task_asgmt_reference is EXISTING check passed');



                --dbms_output.put_line('pm_task_asgmt_reference check passed:' || p_task_assignments_in(i).pm_task_asgmt_reference);

                --dbms_output.put_line('Count of out table prior to input on create: ' || g_task_asgmts_out_tbl.COUNT);



                p_task_assignments_out(k_index).pa_task_id  := l_d_task_id;
                p_task_assignments_out(k_index).resource_list_member_id  := p_task_assignments_in(i).resource_list_member_id ;

                PA_TASK_ASSIGNMENTS_PUB.g_task_asgmts_out_tbl(k_index).pa_task_id := l_d_task_id;
                PA_TASK_ASSIGNMENTS_PUB.g_task_asgmts_out_tbl(k_index).resource_list_member_id := p_task_assignments_in(i).resource_list_member_id ;

                lk_resource_list_member_id_tbl(k_index)   :=  pa_task_assignments_pvt.pfnum(p_task_assignments_in(i).resource_list_member_id) ;

                 l_start_date_tbl(k_index)                :=  pa_task_assignments_pvt.pfdate(p_task_assignments_in(i).start_date) ;
                l_end_date_tbl(k_index)                  :=  pa_task_assignments_pvt.pfdate(p_task_assignments_in(i).end_date) ;
                --l_latest_eff_pub_flag_tbl(1)       :=  NULL ;  --TBD
                l_resource_list_member_id_tbl(k_index)   :=  pa_task_assignments_pvt.pfnum(p_task_assignments_in(i).resource_list_member_id) ;
                l_project_assignment_id_tbl(k_index)     :=  -1 ;

                IF g_asgmts_periods_tbl_count >  0 THEN

                   l_quantity_tbl(k_index)                  :=  NULL ;
                   l_raw_cost_tbl(k_index)                  :=  NULL ;
                   l_burdened_cost_tbl(k_index)             :=  NULL ;

                ELSE

                         OPEN C_Workplan_Costs_enabled(l_budget_version_id);
                         FETCH C_Workplan_Costs_enabled INTO C_Workplan_Costs_rec;
                          CLOSE C_Workplan_Costs_enabled;

                          IF C_Workplan_Costs_rec.enabled_flag = 'Y' THEN
                                l_raw_cost_tbl(k_index)                  :=  pa_task_assignments_pvt.pfnum(p_task_assignments_in(i).planned_total_raw_cost) ;
                                l_burdened_cost_tbl(k_index)             :=  pa_task_assignments_pvt.pfnum(p_task_assignments_in(i).planned_total_bur_cost) ;
                          /* Bug Fix 5505113
							 As per the B n F team request started overriding the miss num with NULL.

                          */
                          	IF l_raw_cost_tbl(k_index) = FND_API.G_MISS_NUM THEN
                            	l_raw_cost_tbl(k_index) := NULL;
                          	END IF;

                          	IF l_burdened_cost_tbl(k_index) = FND_API.G_MISS_NUM THEN
                            	l_burdened_cost_tbl(k_index) := NULL;
                          	END IF;

                          END IF;
                          l_quantity_tbl(k_index)                  :=  pa_task_assignments_pvt.pfnum(p_task_assignments_in(i).planned_quantity) ;
                          /* Bug Fix 5505113
							 As per the B n F team request started overriding the miss num with NULL.

                          */
                          	IF l_quantity_tbl(k_index) = FND_API.G_MISS_NUM THEN
                            	l_quantity_tbl(k_index) := NULL;
                          	END IF;

                END IF;

        l_currency_code_tbl(k_index)             :=  pa_task_assignments_pvt.pfchar(p_task_assignments_in(i).currency_code) ;
        l_product_code_tbl(k_index)              :=  p_pm_product_code   ;
        l_product_reference_tbl(k_index)         :=  pa_task_assignments_pvt.pfchar(p_task_assignments_in(i).pm_task_asgmt_reference) ;
        l_attribute_category_tbl(k_index)        :=  pa_task_assignments_pvt.pfchar(p_task_assignments_in(i).attribute_category) ;
        l_attribute1(k_index)                    :=  pa_task_assignments_pvt.pfchar(p_task_assignments_in(i).attribute1) ;
        l_attribute2(k_index)                    :=  pa_task_assignments_pvt.pfchar(p_task_assignments_in(i).attribute2) ;
        l_attribute3(k_index)                    :=  pa_task_assignments_pvt.pfchar(p_task_assignments_in(i).attribute3) ;
        l_attribute4(k_index)                    :=  pa_task_assignments_pvt.pfchar(p_task_assignments_in(i).attribute4) ;
        l_attribute5(k_index)                    :=  pa_task_assignments_pvt.pfchar(p_task_assignments_in(i).attribute5) ;
        l_attribute6(k_index)                    :=  pa_task_assignments_pvt.pfchar(p_task_assignments_in(i).attribute6) ;
        l_attribute7(k_index)                    :=  pa_task_assignments_pvt.pfchar(p_task_assignments_in(i).attribute7) ;
        l_attribute8(k_index)                    :=  pa_task_assignments_pvt.pfchar(p_task_assignments_in(i).attribute8) ;
        l_attribute9(k_index)                    :=  pa_task_assignments_pvt.pfchar(p_task_assignments_in(i).attribute9) ;
        l_attribute10(k_index)                   :=  pa_task_assignments_pvt.pfchar(p_task_assignments_in(i).attribute10) ;
        l_attribute11(k_index)                   :=  pa_task_assignments_pvt.pfchar(p_task_assignments_in(i).attribute11) ;
        l_attribute12(k_index)                   :=  pa_task_assignments_pvt.pfchar(p_task_assignments_in(i).attribute12) ;
        l_attribute13(k_index)                   :=  pa_task_assignments_pvt.pfchar(p_task_assignments_in(i).attribute13) ;
        l_attribute14(k_index)                   :=  pa_task_assignments_pvt.pfchar(p_task_assignments_in(i).attribute14) ;
        l_attribute15(k_index)                   :=  pa_task_assignments_pvt.pfchar(p_task_assignments_in(i).attribute15) ;
        l_attribute16(k_index)                   :=  pa_task_assignments_pvt.pfchar(p_task_assignments_in(i).attribute16) ;
        l_attribute17(k_index)                   :=  pa_task_assignments_pvt.pfchar(p_task_assignments_in(i).attribute17) ;
        l_attribute18(k_index)                   :=  pa_task_assignments_pvt.pfchar(p_task_assignments_in(i).attribute18) ;
        l_attribute19(k_index)                   :=  pa_task_assignments_pvt.pfchar(p_task_assignments_in(i).attribute19) ;
        l_attribute20(k_index)                   :=  pa_task_assignments_pvt.pfchar(p_task_assignments_in(i).attribute20) ;
        l_attribute21(k_index)                   :=  pa_task_assignments_pvt.pfchar(p_task_assignments_in(i).attribute21) ;
        l_attribute22(k_index)                   :=  pa_task_assignments_pvt.pfchar(p_task_assignments_in(i).attribute22) ;
        l_attribute23(k_index)                   :=  pa_task_assignments_pvt.pfchar(p_task_assignments_in(i).attribute23) ;
        l_attribute24(k_index)                   :=  pa_task_assignments_pvt.pfchar(p_task_assignments_in(i).attribute24) ;
        l_attribute25(k_index)                   :=  pa_task_assignments_pvt.pfchar(p_task_assignments_in(i).attribute25) ;
        l_attribute26(k_index)                   :=  pa_task_assignments_pvt.pfchar(p_task_assignments_in(i).attribute26) ;
        l_attribute27(k_index)                   :=  pa_task_assignments_pvt.pfchar(p_task_assignments_in(i).attribute27) ;
        l_attribute28(k_index)                   :=  pa_task_assignments_pvt.pfchar(p_task_assignments_in(i).attribute28) ;
        l_attribute29(k_index)                   :=  pa_task_assignments_pvt.pfchar(p_task_assignments_in(i).attribute29) ;
        l_attribute30(k_index)                   :=  pa_task_assignments_pvt.pfchar(p_task_assignments_in(i).attribute30) ;
        l_scheduled_delay_tbl(k_index)           :=  pa_task_assignments_pvt.pfnum(p_task_assignments_in(i).scheduled_delay) ;--Bug 3948128

              open c_unique_res_check( l_struct_elem_version_id,
                                  l_project_id,
                                  lk_task_elem_version_id_tbl(i),
                                                  lk_resource_list_member_id_tbl(i) );
                  fetch c_unique_res_check into c_unique_res_rec;

                  IF c_unique_res_check%FOUND THEN
                                 IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.G_MSG_LVL_ERROR)
                                 THEN
                                          --CLOSE c_unique_res_check;  Bug 3937017
                                          IF p_pm_product_code = 'MSPROJECT'
                                          THEN
                                            PA_UTILS.ADD_MESSAGE
                                            ( p_app_short_name => 'PA'
                                             ,p_msg_name       => 'PA_UNIQUE_TA_RES_MSP'
                                             ,p_token1 => 'PLANNING_RESOURCE_NAME'  -- Bug 6497559
                                             ,p_value1 => PA_TASK_UTILS.get_resource_name(p_task_assignments_in(i).resource_list_member_id)
                                            );
                                          ELSE
                                            PA_UTILS.ADD_MESSAGE
                                            ( p_app_short_name => 'PA'
                                             ,p_msg_name       => 'PA_UNIQUE_TA_RES_AMG'
                                             ,p_token1 => 'PLANNING_RESOURCE_ID'  -- Bug 6497559
                                             ,p_value1 => p_task_assignments_in(i).resource_list_member_id
                                            );
                                          END IF;
                                END IF;
                        -- Bug 3937017 Moved Close cursor
                        CLOSE c_unique_res_check;
                        x_return_status    := FND_API.G_RET_STS_ERROR;
                        RAISE FND_API.G_EXC_ERROR;
                 END IF;
                 Close c_unique_res_check;

                          -- Commented for Bug 3940284 by rishukla
                         /*IF C_Res_List_Mem_Check_Rec.resource_class_code = 'PEOPLE' THEN
                            open c_people_res_check( l_struct_elem_version_id,
                                                     l_project_id,
                                                     lk_task_elem_version_id_tbl(i) );

                                    fetch c_people_res_check into c_people_res_rec;

                                        IF c_people_res_check%FOUND THEN


                                                  --dbms_output.put_line('Deleting records of task level effort from pa_resource_assignments. ');

                                                  delete from pa_resource_assignments where
                                                  resource_class_code = 'PEOPLE'
                                                  and project_id = l_project_id
                                                  and budget_version_id = c_people_res_rec.budget_version_id
                                                  and wbs_element_version_id = lk_task_elem_version_id_tbl(i)
                                                  and ta_display_flag = 'N';
                                                -- Bug 3840323 fix
                                                -- Should delete regardless of product code
                                                --and pm_product_code is not null;

                                                 --dbms_output.put_line('After Deleting records of task level effort from pa_resource_assignments. ');

                                        END IF;

                                        close c_people_res_check;
                         END IF;*/

        END IF;   --  End if for check of task elem version id prior to loading internal tables

END LOOP;


                  --dbms_output.put_line('Value of internal k_index of task assignment input records loaded so far...: ' || k_index);
 IF k_index > 0 THEN

      --dbms_output.put_line('b4 call to pa_fp_planning_transactions.add_planning_transactions:'||x_return_status );

    For i in 1..k_index LOOP
            NULL;
      --dbms_output.put_line('p_context' ||           pa_fp_constants_pkg.g_calling_module_task);
          --dbms_output.put_line('p_project_id                  ' || l_project_id);
      --dbms_output.put_line('p_struct_elem_version_id      ' || l_struct_elem_version_id );
          --dbms_output.put_line('p_budget_version_id           ' || l_budget_version_id);
          --dbms_output.put_line('p_task_elem_version_id_tbl(k_index)    ' || l_task_elem_version_id_tbl(k_index));
          --dbms_output.put_line('p_task_name_tbl(k_index)                ' || l_task_name_tbl(k_index) );
          --dbms_output.put_line('p_task_number_tbl(k_index)              ' || l_task_number_tbl(k_index) );
      --dbms_output.put_line('p_start_date_tbl(k_index)               ' || l_start_date_tbl(k_index) );
          --dbms_output.put_line('p_end_date_tbl(k_index)                 ' || l_end_date_tbl(k_index) );
          --dbms_output.put_line('p_planned_people_effort_tbl(k_index)    ' || l_planned_people_effort_tbl(k_index) );
          --dbms_output.put_line('p_planned_equip_effort_tbl(k_index)     ' || l_planned_equip_effort_tbl(k_index) );
          --dbms_output.put_line('p_latest_eff_pub_flag_tbl(k_index)      ' || l_latest_eff_pub_flag_tbl(k_index) );
          --dbms_output.put_line('p_resource_list_member_id_tbl(k_index)  ' || l_resource_list_member_id_tbl(k_index) );
          --dbms_output.put_line('p_project_assignment_id_tbl(k_index)    ' || l_project_assignment_id_tbl(k_index) );
          --dbms_output.put_line('p_quantity_tbl(k_index)                ' || l_quantity_tbl(k_index) );
          --dbms_output.put_line('p_currency_code_tbl(k_index)           ' || l_currency_code_tbl(k_index));
          --dbms_output.put_line('p_raw_cost_tbl(k_index)                ' || l_raw_cost_tbl(k_index));
          --dbms_output.put_line('p_burdened_cost_tbl(k_index)           ' || l_burdened_cost_tbl(k_index));
          --dbms_output.put_line('p_pm_product_code(k_index)             ' || l_product_code_tbl(k_index));
      --dbms_output.put_line('p_pm_res_asgmt_ref(k_index)            ' || l_product_reference_tbl(k_index));
          --dbms_output.put_line('p_attribute1(k_index)                  ' || l_attribute1(k_index));           --These are pl/sql system tables too..
          --dbms_output.put_line('p_attribute2(k_index)                  ' || l_attribute2(k_index));
          --dbms_output.put_line('p_attribute3(k_index)                  ' || l_attribute3(k_index));
          --dbms_output.put_line('p_attribute4(k_index)                  ' || l_attribute4(k_index));
          --dbms_output.put_line('p_attribute5(k_index)                  ' || l_attribute5(k_index));
          --dbms_output.put_line('p_attribute6(k_index)                  ' || l_attribute6(k_index));
          --dbms_output.put_line('p_attribute7(k_index)                  ' || l_attribute7(k_index));
          --dbms_output.put_line('p_attribute8(k_index)                  ' || l_attribute8(k_index));
          --dbms_output.put_line('p_attribute9(k_index)                  ' || l_attribute9(k_index));
          --dbms_output.put_line('p_attribute10(k_index)                 ' || l_attribute10(k_index));
          --dbms_output.put_line('p_attribute11(k_index)                 ' || l_attribute11(k_index));
          --dbms_output.put_line('p_attribute12(k_index)                 ' || l_attribute12(k_index));
          --dbms_output.put_line('p_attribute13(k_index)                 ' || l_attribute13(k_index));
          --dbms_output.put_line('p_attribute14(k_index)                 ' || l_attribute14(k_index));
          --dbms_output.put_line('p_attribute15(k_index)                 ' || l_attribute15(k_index));
          --dbms_output.put_line('p_attribute16(k_index)                 ' || l_attribute16(k_index));
          --dbms_output.put_line('p_attribute17(k_index)                 ' || l_attribute17(k_index));
          --dbms_output.put_line('p_attribute18(k_index)                 ' || l_attribute18(k_index));
          --dbms_output.put_line('p_attribute19(k_index)                 ' || l_attribute19(k_index));
          --dbms_output.put_line('p_attribute20(k_index)                 ' || l_attribute20(k_index));
          --dbms_output.put_line('p_attribute21(k_index)                 ' || l_attribute21(k_index));
          --dbms_output.put_line('p_attribute22(k_index)                 ' || l_attribute22(k_index));
          --dbms_output.put_line('p_attribute23(k_index)                 ' || l_attribute23(k_index));
          --dbms_output.put_line('p_attribute24(k_index)                 ' || l_attribute24(k_index));
          --dbms_output.put_line('p_attribute25(k_index)                 ' || l_attribute25(k_index));
          --dbms_output.put_line('p_attribute26(k_index)                 ' || l_attribute26(k_index));
          --dbms_output.put_line('p_attribute27(k_index)                 ' || l_attribute27(k_index));
          --dbms_output.put_line('p_attribute28(k_index)                 ' || l_attribute28(k_index));
          --dbms_output.put_line('p_attribute29(k_index)                 ' || l_attribute29(k_index));
          --dbms_output.put_line('p_attribute30(k_index)                 ' || l_attribute30(k_index));
          --dbms_output.put_line('x_return_status                  ' || x_return_status);
          --dbms_output.put_line('x_msg_count                      ' || x_msg_count);
          --dbms_output.put_line('x_msg_data                       ' || x_msg_data);

        end LOOP;

        --Added for Bug 3940284

        /* Updates from the bug
        In both pa_task_assignments_pub create_task_assignments and
        update_task_assignments AMG APIs, we are deleting the ta_display_flag='N'
        assignment records whenever the first resource is assigned to the task
        version.  There are a few problems that need to be fixed:

        1. We currently only delete if the resource being assigned to task is of
        'PEOPLE' class.  This IF should be removed, deletion should be done when
        resource of ANY class is assigned to task.
        2. We should NOT be deleting directly from pa_resource_assignments.  Instead,
        we should call pa_fp_planning_transaction_pub.delete_planning_transactions to
        to properly delete the assignment record.
        */

        --Changes for Bug 3910882 Begin
        /* Updates from the Bug
        The UPDATE does not perform very well in volume env.  My suggestion to improve
        this is to replace the FORALL UPDATE by 2 operations:
        * 1. Insert the task version ids into an existing temp table, PA_COPY_ASGMTS_TEMP
        * 2. Select resource assignments from pa_resource_assignments joining to the temp table
        */

        -- dynamically computing the statistics for the Temporary table
        l_num_of_tasks := l_task_elem_version_id_tbl.COUNT;

        SELECT to_number(value)
        INTO   l_db_block_size
        FROM   v$parameter
        WHERE  name = 'db_block_size';

        l_num_blocks := 1.25 * (l_num_of_tasks * 75) / l_db_block_size;

        -- Manually seed the statistics for the temporary table.
        pa_task_assignment_utils.set_table_stats('PA','PA_COPY_ASGMTS_TEMP',
                                                  l_num_of_tasks, l_num_blocks, 75);

        -- delete content from temp table before inserting
        DELETE pa_copy_asgmts_temp;

        -- bulk inserting the task version ids into the temp table
        -- Changed due to bug 4153366
        FORALL i IN 1..l_task_elem_version_id_tbl.COUNT
            INSERT INTO pa_copy_asgmts_temp VALUES
            (l_task_elem_version_id_tbl(i), -1, null, null, null, null);

IF P_DEBUG_MODE = 'Y' AND (li_curr_level <= 3) THEN
        pa_debug.g_err_stage:='Successfully inserted task version ids into the temp table';
        pa_debug.write(G_PKG_NAME ,pa_debug.g_err_stage,3);
END IF;

        -- select resource_assignment_ids and wbs_element_version_ids by joining to
        -- the temp table for all records having ta_display_flag = 'N'
        OPEN C_Get_Default_Res_Asgmt(l_project_id, l_budget_version_id);
        FETCH C_Get_Default_Res_Asgmt BULK COLLECT INTO
              l_delete_task_res_asgmt_id_tbl, l_delete_task_elem_ver_id_tbl;
        CLOSE C_Get_Default_Res_Asgmt;

IF P_DEBUG_MODE = 'Y' AND (li_curr_level <= 3) THEN
        pa_debug.g_err_stage:='Selected resource_assignment_ids and wbs_element_version_ids into plsql tables';
        pa_debug.write(G_PKG_NAME ,pa_debug.g_err_stage,3);
END IF;

        /*
        FORALL k IN l_task_elem_version_id_tbl.FIRST .. l_task_elem_version_id_tbl.LAST
        UPDATE pa_resource_assignments
        SET ta_display_flag = 'N'
        WHERE ta_display_flag = 'N'
        AND wbs_element_version_id = l_task_elem_version_id_tbl(k)
        AND project_id = l_project_id
        AND budget_version_id = l_budget_version_id
        RETURNING resource_assignment_id, wbs_element_version_id BULK COLLECT INTO
                  l_delete_task_res_asgmt_id_tbl, l_delete_task_elem_ver_id_tbl;
        */

        --Changes for Bug 3910882 End

        IF l_delete_task_res_asgmt_id_tbl.COUNT > 0 THEN
                --dbms_output.put_line('Before calling delete planning transactions:ret. status' || x_return_status);

              -- Bug 4200146: Prevent rollup from happening in PJI plan update call
              --              Turn on the mask.
              IF g_periodic_mode IS NULL THEN
                PA_TASK_PUB1.G_CALL_PJI_ROLLUP := 'N';
              END IF;

                PA_FP_PLANNING_TRANSACTION_PUB.DELETE_PLANNING_TRANSACTIONS(
                P_CONTEXT => pa_fp_constants_pkg.g_calling_module_task,
                P_TASK_OR_RES => 'ASSIGNMENT',
                P_ELEMENT_VERSION_ID_TBL => l_delete_task_elem_ver_id_tbl,
                P_TASK_NUMBER_TBL => NULL,
                P_TASK_NAME_TBL => NULL,
                P_RESOURCE_ASSIGNMENT_TBL => l_delete_task_res_asgmt_id_tbl,
                P_VALIDATE_DELETE_FLAG => NULL,
                X_RETURN_STATUS => X_RETURN_STATUS,
                X_MSG_COUNT => X_MSG_COUNT,
                X_MSG_DATA => X_MSG_DATA);

              -- Bug 4200146: Prevent rollup from happening in PJI plan update call
              --              Turn off the mask.
              IF g_periodic_mode IS NULL THEN
                PA_TASK_PUB1.G_CALL_PJI_ROLLUP := null;
              END IF;

         END IF;

        --dbms_output.put_line('After Calling delete planning transactions:ret. status' || x_return_status);
        --End of Changes for Bug 3940284

IF P_DEBUG_MODE = 'Y' AND (li_curr_level <= 3) THEN
          pa_debug.g_err_stage:='b4 call to pa_fp_planning_transactions.add_planning_transactions ret status:'||x_return_status;
          pa_debug.write(G_PKG_NAME ,pa_debug.g_err_stage,3);
          pa_debug.g_err_stage:='p_context' ||           pa_fp_constants_pkg.g_calling_module_task;
          pa_debug.write(G_PKG_NAME ,pa_debug.g_err_stage,3);
          pa_debug.g_err_stage:='p_project_id                  ' || l_project_id;
          pa_debug.write(G_PKG_NAME ,pa_debug.g_err_stage,3);
          pa_debug.g_err_stage:='p_struct_elem_version_id      ' || l_struct_elem_version_id ;
          pa_debug.write(G_PKG_NAME ,pa_debug.g_err_stage,3);
          pa_debug.g_err_stage:='p_budget_version_id           ' || l_budget_version_id;
          pa_debug.write(G_PKG_NAME ,pa_debug.g_err_stage,3);

        -- For i in 1..k_index LOOP

          pa_debug.g_err_stage:='p_task_elem_version_id_tbl' || l_task_elem_version_id_tbl(1);
          pa_debug.write(G_PKG_NAME ,pa_debug.g_err_stage,3);

          pa_debug.g_err_stage:='p_start_date_tbl' || l_start_date_tbl(1) ;
          pa_debug.write(G_PKG_NAME ,pa_debug.g_err_stage,3);
          pa_debug.g_err_stage:='p_end_date_tbl' || l_end_date_tbl(1) ;
          pa_debug.write(G_PKG_NAME ,pa_debug.g_err_stage,3);


          pa_debug.g_err_stage:='p_resource_list_member_id_tbl:' || l_resource_list_member_id_tbl(1) ;
          pa_debug.write(G_PKG_NAME ,pa_debug.g_err_stage,3);
          pa_debug.g_err_stage:='p_project_assignment_id_tbl:' || l_project_assignment_id_tbl(1) ;
          pa_debug.write(G_PKG_NAME ,pa_debug.g_err_stage,3);
          pa_debug.g_err_stage:='p_quantity_tbl:' || l_quantity_tbl(1) ;
          pa_debug.write(G_PKG_NAME ,pa_debug.g_err_stage,3);
          pa_debug.g_err_stage:='p_currency_code_tbl:' || l_currency_code_tbl(1);
          pa_debug.write(G_PKG_NAME ,pa_debug.g_err_stage,3);
          pa_debug.g_err_stage:='p_raw_cost_tbl:' || l_raw_cost_tbl(1);
          pa_debug.write(G_PKG_NAME ,pa_debug.g_err_stage,3);
          pa_debug.g_err_stage:='p_burdened_cost_tbl:' || l_burdened_cost_tbl(1);
          pa_debug.write(G_PKG_NAME ,pa_debug.g_err_stage,3);
          pa_debug.g_err_stage:='p_pm_product_code:' || l_product_code_tbl(1);
          pa_debug.write(G_PKG_NAME ,pa_debug.g_err_stage,3);
          pa_debug.g_err_stage:='p_pm_res_asgmt_ref:' || l_product_reference_tbl(1);
          pa_debug.write(G_PKG_NAME ,pa_debug.g_err_stage,3);
          pa_debug.g_err_stage:='p_scheduled_delay:' || l_scheduled_delay_tbl(1);
          pa_debug.write(G_PKG_NAME ,pa_debug.g_err_stage,3);

         -- END LOOP;
END IF;

   pa_fp_planning_transaction_pub.add_planning_transactions
    ( p_context                     => pa_fp_constants_pkg.g_calling_module_task,
          p_one_to_one_mapping_flag     => 'Y',
          p_project_id                  => l_project_id,
      p_struct_elem_version_id      => l_struct_elem_version_id ,
          p_budget_version_id           => l_budget_version_id,
          p_task_elem_version_id_tbl    => l_task_elem_version_id_tbl,
          p_task_name_tbl               => l_task_name_tbl,
          p_task_number_tbl             => l_task_number_tbl,
          p_planning_start_date_tbl              => l_start_date_tbl,
          p_planning_end_date_tbl                => l_end_date_tbl,
          p_planned_people_effort_tbl   => l_planned_people_effort_tbl,
         -- p_planned_equip_effort_tbl    => l_planned_equip_effort_tbl,
          p_latest_eff_pub_flag_tbl     => l_latest_eff_pub_flag_tbl,
          p_resource_list_member_id_tbl => l_resource_list_member_id_tbl,
          p_project_assignment_id_tbl   => l_project_assignment_id_tbl,
          p_quantity_tbl                => l_quantity_tbl,
          p_currency_code_tbl           => l_currency_code_tbl,
          p_raw_cost_tbl                => l_raw_cost_tbl,
          p_burdened_cost_tbl           => l_burdened_cost_tbl,
          p_pm_product_code             => l_product_code_tbl,
      p_pm_res_asgmt_ref            => l_product_reference_tbl,
          p_attribute_category_tbl      => l_attribute_category_tbl,
          p_attribute1                  => l_attribute1,           --These are pl/sql system tables too..
          p_attribute2                  => l_attribute2,
          p_attribute3                  => l_attribute3,
          p_attribute4                  => l_attribute4,
          p_attribute5                  => l_attribute5,
          p_attribute6                  => l_attribute6,
          p_attribute7                  => l_attribute7,
          p_attribute8                  => l_attribute8,
          p_attribute9                  => l_attribute9,
          p_attribute10                 => l_attribute10,
          p_attribute11                 => l_attribute11,
          p_attribute12                 => l_attribute12,
          p_attribute13                 => l_attribute13,
          p_attribute14                 => l_attribute14,
          p_attribute15                 => l_attribute15,
          p_attribute16                 => l_attribute16,
          p_attribute17                 => l_attribute17,
          p_attribute18                 => l_attribute18,
          p_attribute19                 => l_attribute19,
          p_attribute20                 => l_attribute20,
          p_attribute21                 => l_attribute21,
          p_attribute22                 => l_attribute22,
          p_attribute23                 => l_attribute23,
          p_attribute24                 => l_attribute24,
          p_attribute25                 => l_attribute25,
          p_attribute26                 => l_attribute26,
          p_attribute27                 => l_attribute27,
          p_attribute28                 => l_attribute28,
          p_attribute29                 => l_attribute29,
          p_attribute30                 => l_attribute30,
          p_scheduled_delay             => l_scheduled_delay_tbl, --Bug 3948128
          x_return_status               => x_return_status,
          x_msg_count                   => x_msg_count,
          x_msg_data                    => x_msg_data
          );

          --dbms_output.put_line('After returning from add planning transactions return status:' ||x_return_status );

IF P_DEBUG_MODE = 'Y' AND (li_curr_level <= 3) THEN
          pa_debug.g_err_stage:='Return status after add planning transactions.' ||x_return_status;
          pa_debug.write(G_PKG_NAME ,pa_debug.g_err_stage,3);
END IF;

           IF (x_return_status = FND_API.G_RET_STS_UNEXP_ERROR) THEN
                RAISE  FND_API.G_EXC_UNEXPECTED_ERROR;
           ELSIF  (x_return_status = FND_API.G_RET_STS_ERROR) THEN
                RAISE  FND_API.G_EXC_ERROR;
           END IF;

  END IF;    --k_index for add planning transactions...








        FOR i in 1..(k_index) LOOP

IF P_DEBUG_MODE = 'Y' AND (li_curr_level <= 3) THEN
                  pa_debug.g_err_stage:='Obtaining Task Assignment Ids index:' || i;
                  pa_debug.write(G_PKG_NAME ,pa_debug.g_err_stage,3);
END IF;

                  open c_cur_out( l_struct_elem_version_id, l_project_id, lk_task_elem_version_id_tbl(i), lk_resource_list_member_id_tbl(i) );
                  fetch c_cur_out into c_rec_out;

                  IF c_cur_out%FOUND THEN
IF P_DEBUG_MODE = 'Y' AND (li_curr_level <= 3) THEN
                          pa_debug.g_err_stage:='Success on index:' || i;
                          pa_debug.write(G_PKG_NAME ,pa_debug.g_err_stage,3);
END IF;
                          p_task_assignments_out(i).return_status  := 'S';
                        PA_TASK_ASSIGNMENTS_PUB.g_task_asgmts_out_tbl(i).return_status:= 'S';

                  ELSE
IF P_DEBUG_MODE = 'Y' AND (li_curr_level <= 3) THEN
                         pa_debug.g_err_stage:='Errored on index:' || i;
                         pa_debug.write(G_PKG_NAME ,pa_debug.g_err_stage,3);
END IF;
                         p_task_assignments_out(i).return_status  := 'E';
                        PA_TASK_ASSIGNMENTS_PUB.g_task_asgmts_out_tbl(i).return_status:= 'E';
                  END IF;

IF P_DEBUG_MODE = 'Y' AND (li_curr_level <= 3) THEN
                  pa_debug.g_err_stage:='Out resource_assignment_id:' || c_rec_out.resource_assignment_id  || 'Out resource alias:' || c_rec_out.alias;
                  pa_debug.write(G_PKG_NAME ,pa_debug.g_err_stage,3);
END IF;
                  p_task_assignments_out(i).pa_task_assignment_id  := c_rec_out.resource_assignment_id;
                  p_task_assignments_out(i).resource_alias         := c_rec_out.alias;

                  PA_TASK_ASSIGNMENTS_PUB.g_task_asgmts_out_tbl(i).pa_task_assignment_id := c_rec_out.resource_assignment_id;
                  PA_TASK_ASSIGNMENTS_PUB.g_task_asgmts_out_tbl(i).resource_alias        := c_rec_out.alias;


                  close c_cur_out;


            END LOOP;

                  --dbms_output.put_line('End of Create Task Assignments:');


     IF FND_API.to_boolean( p_commit ) THEN
IF P_DEBUG_MODE = 'Y' AND (li_curr_level <= 3) THEN
        pa_debug.g_err_stage:='COMMIT done in Create Task Assignments';
        pa_debug.write(G_PKG_NAME ,pa_debug.g_err_stage,3);
END IF;
	COMMIT;
     END IF;

EXCEPTION

  WHEN FND_API.G_EXC_ERROR
  THEN
       ROLLBACK TO add_task_asgmts_pub;
IF P_DEBUG_MODE = 'Y' THEN
       PA_DEBUG.write_log (x_module => G_PKG_NAME
                               ,x_msg         => 'Expected Error:' || L_FuncProc || SQLERRM
                               ,x_log_level   => 5);
END IF;
       x_return_status := FND_API.G_RET_STS_ERROR;

       FND_MSG_PUB.Count_And_Get
           (   p_count    =>  x_msg_count  ,
               p_data    =>  x_msg_data  );

  WHEN FND_API.G_EXC_UNEXPECTED_ERROR
  THEN
       ROLLBACK TO add_task_asgmts_pub;

IF P_DEBUG_MODE = 'Y' THEN
        PA_DEBUG.write_log (x_module => G_PKG_NAME
                               ,x_msg         => 'Unexpected Error:' || L_FuncProc || SQLERRM
                               ,x_log_level   => 5);
END IF;
       x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

       IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
       THEN
                 FND_MSG_PUB.add_exc_msg
                     ( p_pkg_name    => G_PKG_NAME
                     , p_procedure_name  => l_api_name  );

       END IF;
       FND_MSG_PUB.Count_And_Get
           (   p_count    =>  x_msg_count  ,
               p_data    =>  x_msg_data  );


  WHEN OTHERS THEN
       ROLLBACK TO add_task_asgmts_pub;

       -- Bug 4200146: Prevent rollup from happening in PJI plan update call
       --              Reset the mask.
       PA_TASK_PUB1.G_CALL_PJI_ROLLUP := null;

IF P_DEBUG_MODE = 'Y' THEN
        PA_DEBUG.write_log (x_module => G_PKG_NAME
                               ,x_msg         => 'Unexpected Error:' || L_FuncProc || SQLERRM
                               ,x_log_level   => 5);
END IF;
       x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

       IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
       THEN
                 FND_MSG_PUB.add_exc_msg
                     ( p_pkg_name    => G_PKG_NAME
                     , p_procedure_name  => l_api_name  );

       END IF;

       FND_MSG_PUB.Count_And_Get
           (   p_count    =>  x_msg_count  ,
               p_data    =>  x_msg_data  );

END CREATE_TASK_ASSIGNMENTS;



PROCEDURE Create_Task_Assignment_Periods
( p_api_version_number          IN   NUMBER          := PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM
 ,p_commit                                  IN   VARCHAR2            := FND_API.G_FALSE
 ,p_init_msg_list                   IN   VARCHAR2            := FND_API.G_FALSE
 ,p_pm_product_code                 IN   VARCHAR2      := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
 ,p_pm_project_reference        IN   VARCHAR2      := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
 ,p_pa_project_id               IN   NUMBER        := PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM
 ,p_pa_structure_version_id     IN   NUMBER        := PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM
 ,p_task_assignments_in         IN   ASSIGNMENT_IN_TBL_TYPE
 ,p_task_assignment_periods_in  IN   PA_TASK_ASSIGNMENTS_PUB.ASSIGNMENT_PERIODS_TBL_TYPE
 ,p_task_assignments_out        OUT  NOCOPY ASSIGNMENT_OUT_TBL_TYPE
 ,p_task_assignment_periods_out OUT  NOCOPY PA_TASK_ASSIGNMENTS_PUB.ASSIGNMENT_OUT_TBL_TYPE
 ,x_msg_count                       OUT  NOCOPY NUMBER
 ,x_msg_data                        OUT  NOCOPY VARCHAR2
 ,x_return_status                       OUT  NOCOPY VARCHAR2
) IS

   l_api_name             CONSTANT  VARCHAR2(30)     := 'Create_Task_Asgmt_Periods';
   i                      NUMBER;
   l_return_status        VARCHAR2(1);
   l_err_stage            VARCHAR2(120);
   l_msg_data             VARCHAR2(2000);
   l_msg_code             VARCHAR2(30);
   l_msg_count            NUMBER;
   l_project_id           NUMBER;
   l_task_assignment_periods_out PA_TASK_ASSIGNMENTS_PUB.ASSIGNMENT_OUT_TBL_TYPE;
L_FuncProc varchar2(2000);

   -- Added for bug 5469303
   CURSOR C_Get_Budget_Version_Id(p_structure_version_id IN NUMBER) is
   select budget_version_id
     from pa_budget_versions
    where project_structure_version_id = p_structure_version_id
      and project_id = p_pa_project_id;

		l_budget_version_id       number;
  l_struct_elem_version_id  number;


BEGIN
L_FuncProc := 'Create_Task_Asgmt_Periods';
--dbms_output.put_line('In Create_Task_Asgmt_Periods:');
IF P_DEBUG_MODE = 'Y' AND (li_curr_level <= 3) THEN
pa_debug.g_err_stage:='Entered ' || L_FuncProc;
pa_debug.write(G_PKG_NAME ,pa_debug.g_err_stage,3);
END IF;
--  Standard begin of API savepoint

    SAVEPOINT CREATE_TASK_ASGMT_PERIODS;

--  Standard call to check for call compatibility.

    IF NOT FND_API.Compatible_API_Call ( 1.0, --g_api_version_number  ,
                               p_api_version_number,
                               l_api_name,
                               G_PKG_NAME         )
    THEN
         RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;


--  Initialize the message table if requested.

    IF FND_API.TO_BOOLEAN( p_init_msg_list )
    THEN
       FND_MSG_PUB.initialize;
    END IF;

    --  Set API return status to success
    x_return_status := FND_API.G_RET_STS_SUCCESS;

   -- Added for bug 5469303
   IF  p_pa_structure_version_id IS NOT NULL AND (p_pa_structure_version_id <> PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM) THEN
     l_struct_elem_version_id := p_pa_structure_version_id;
   ELSE
     l_struct_elem_version_id := PA_PROJECT_STRUCTURE_UTILS.get_current_working_ver_id( p_project_id => p_pa_project_id);
   END IF;

   IF ( l_struct_elem_version_id = PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM OR l_struct_elem_version_id IS NULL  ) THEN
     IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.G_MSG_LVL_ERROR) THEN
       pa_interface_utils_pub.map_new_amg_msg ( p_old_message_code => 'PA_PS_STRUC_VER_REQ'
						,p_msg_attribute    => 'CHANGE'
						,p_resize_flag      => 'N'
						,p_msg_context      => 'GENERAL'
						,p_attribute1       => ''
						,p_attribute2       => ''
						,p_attribute3       => ''
						,p_attribute4       => ''
						,p_attribute5       => '');
      END IF;
      RAISE FND_API.G_EXC_ERROR;
   END IF;

   OPEN C_Get_Budget_Version_Id(l_struct_elem_version_id);
   FETCH C_Get_Budget_Version_Id INTO l_budget_version_id;
   CLOSE C_Get_Budget_Version_Id;

   IF ( l_budget_version_id = PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM OR l_budget_version_id IS NULL  ) THEN
     IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.G_MSG_LVL_ERROR) THEN
       PA_UTILS.ADD_MESSAGE (p_app_short_name => 'PA',
			     p_msg_name       => 'PA_FP_PROJ_VERSION_MISMATCH'
			    );
     END IF;
     x_return_status    := FND_API.G_RET_STS_ERROR;
     RAISE FND_API.G_EXC_ERROR;
   END IF;

   IF P_DEBUG_MODE = 'Y' AND (li_curr_level <= 3) THEN
     pa_debug.g_err_stage:=' budget version id: ' || l_budget_version_id ;
     pa_debug.write(G_PKG_NAME ,pa_debug.g_err_stage,3);
   END IF;
   -- End of changes for bug 5469303


        --dbms_output.put_line('Calling Init_Task_Assignments:');
        Init_Task_Assignments;
        g_asgmts_periods_tbl_count := p_task_assignment_periods_in.count;

        IF nvl(p_task_assignments_in.COUNT, 0) > 0 THEN
                      --dbms_output.put_line('Calling Create_Task_Assignments:return status: ' || l_return_status);

                      -- Bug 4200146: Set the global variable to indicate that create task assignments
                      --  is called with create task assignment periods
                      --  Prevent rollup from happening in PJI plan update call
                      g_periodic_mode := 'Y';
                      PA_TASK_PUB1.G_CALL_PJI_ROLLUP := 'N';

                      Create_Task_Assignments
                      (  p_api_version_number        => 1.0
                      ,p_commit                          => FND_API.G_FALSE
                      ,p_init_msg_list           => FND_API.G_FALSE
                          ,p_pm_product_code         => p_pm_product_code
                          ,p_pm_project_reference    => p_pm_project_reference
                          ,p_pa_project_id           => p_pa_project_id
                          ,p_pa_structure_version_id => p_pa_structure_version_id
                          ,p_task_assignments_in     => p_task_assignments_in
                      ,p_task_assignments_out    => p_task_assignments_out
                      ,x_msg_count                       => l_msg_count
                      ,x_msg_data                        => l_msg_data
                      ,x_return_status               => l_return_status
                      );

                      -- Bug 4200146
                      g_periodic_mode := null;
                      PA_TASK_PUB1.G_CALL_PJI_ROLLUP := null;

                  --dbms_output.put_line('After Create_Task_Assignments:return status: ' || l_return_status);
                  IF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN

                          RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

                 ELSIF l_return_status = FND_API.G_RET_STS_ERROR THEN

                         RAISE FND_API.G_EXC_ERROR;

                 END IF;

         END IF;

   IF nvl(p_task_assignment_periods_in.count,0) > 0 THEN
                  --dbms_output.put_line('Calling Create_Task_Assignment_Periods return status: ' || l_return_status);

              -- Bug 4200146: Set the global variable to
              --  prevent rollup from happening in PJI plan update call
              PA_TASK_PUB1.G_CALL_PJI_ROLLUP := 'N';

              Pa_Task_Assignments_pvt.Create_Task_Assignment_Periods
             (  p_api_version_number            => 1.0
              ,p_commit                                 => FND_API.G_FALSE
              ,p_init_msg_list                  => FND_API.G_FALSE
                  ,p_pm_product_code                => p_pm_product_code
                  ,p_pm_project_reference           => p_pm_project_reference
                  ,p_pa_project_id                  => p_pa_project_id
                  ,p_pa_structure_version_id        => p_pa_structure_version_id
                  ,p_task_assignment_periods_in     => p_task_assignment_periods_in
              ,p_task_assignment_periods_out    => l_task_assignment_periods_out
              ,x_msg_count                              => l_msg_count
              ,x_msg_data                               => l_msg_data
              ,x_return_status                      => l_return_status
             );

             -- Bug 4200146
             PA_TASK_PUB1.G_CALL_PJI_ROLLUP := null;

                 IF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN

                         RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

                  ELSIF l_return_status = FND_API.G_RET_STS_ERROR THEN

                        RAISE FND_API.G_EXC_ERROR;

                 END IF;

   END IF;

   -- Bug 4200146: Call PJI update update
   IF nvl(p_task_assignments_in.COUNT, 0) > 0 OR nvl(p_task_assignment_periods_in.count,0) > 0 THEN
     PJI_FM_XBS_ACCUM_MAINT.PLAN_UPDATE (p_plan_version_id => l_budget_version_id,  -- added for bug 5469303
                                         x_msg_code => l_msg_code,
                                         x_return_status => l_return_status);


     IF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
       RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
     ELSIF l_return_status = FND_API.G_RET_STS_ERROR THEN
      RAISE FND_API.G_EXC_ERROR;
     END IF;

   END IF;

     IF FND_API.to_boolean( p_commit ) THEN
        COMMIT;
     END IF;
    --dbms_output.put_line('End of Create_Task_Assignment_Periods return status: ' || l_return_status);

EXCEPTION

  WHEN FND_API.G_EXC_ERROR
  THEN
       ROLLBACK TO CREATE_TASK_ASGMT_PERIODS;

       x_return_status := FND_API.G_RET_STS_ERROR;
IF P_DEBUG_MODE = 'Y' THEN
       PA_DEBUG.write_log (x_module => G_PKG_NAME
                               ,x_msg         => 'Expected Error:' || L_FuncProc || SQLERRM
                               ,x_log_level   => 5);
END IF;
       FND_MSG_PUB.Count_And_Get
           (   p_count    =>  x_msg_count  ,
               p_data    =>   x_msg_data  );

  WHEN FND_API.G_EXC_UNEXPECTED_ERROR
  THEN
       ROLLBACK TO CREATE_TASK_ASGMT_PERIODS;

       x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
IF P_DEBUG_MODE = 'Y' THEN
       PA_DEBUG.write_log (x_module => G_PKG_NAME
                               ,x_msg         => 'Unexpected Error:' || L_FuncProc || SQLERRM
                               ,x_log_level   => 5);
END IF;
       FND_MSG_PUB.Count_And_Get
           (   p_count    =>  x_msg_count  ,
               p_data    =>  x_msg_data  );

  WHEN OTHERS THEN
       ROLLBACK TO CREATE_TASK_ASGMT_PERIODS;

       -- Bug 4200146
       g_periodic_mode := null;
       PA_TASK_PUB1.G_CALL_PJI_ROLLUP := null;

       x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
IF P_DEBUG_MODE = 'Y' THEN
       PA_DEBUG.write_log (x_module => G_PKG_NAME
                               ,x_msg         => 'Unexpected Error:' || L_FuncProc || SQLERRM
                               ,x_log_level   => 5);
END IF;
       IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
       THEN
         FND_MSG_PUB.add_exc_msg
             ( p_pkg_name    => G_PKG_NAME
             , p_procedure_name  => l_api_name  );

       END IF;

       FND_MSG_PUB.Count_And_Get
           (   p_count    =>  x_msg_count  ,
               p_data    =>  x_msg_data  );

END Create_Task_Assignment_Periods;


PROCEDURE Update_Task_Assignment_Periods
( p_api_version_number          IN   NUMBER          := PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM
 ,p_commit                                  IN   VARCHAR2            := FND_API.G_FALSE
 ,p_init_msg_list                   IN   VARCHAR2            := FND_API.G_FALSE
 ,p_pm_product_code                 IN   VARCHAR2      := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
 ,p_pm_project_reference        IN   VARCHAR2      := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
 ,p_pa_project_id               IN   NUMBER        := PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM
 ,p_pa_structure_version_id     IN   NUMBER        := PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM
 ,p_task_assignments_in         IN   ASSIGNMENT_IN_TBL_TYPE
 ,p_task_assignment_periods_in  IN   PA_TASK_ASSIGNMENTS_PUB.ASSIGNMENT_PERIODS_TBL_TYPE
 ,p_task_assignments_out        OUT  NOCOPY ASSIGNMENT_OUT_TBL_TYPE
 ,p_task_assignment_periods_out OUT  NOCOPY PA_TASK_ASSIGNMENTS_PUB.ASSIGNMENT_OUT_TBL_TYPE
 ,x_msg_count                       OUT  NOCOPY NUMBER
 ,x_msg_data                        OUT  NOCOPY VARCHAR2
 ,x_return_status                       OUT  NOCOPY VARCHAR2
) IS

   l_api_name             CONSTANT  VARCHAR2(30)     := 'Update_Task_Asgmt_Periods';
   i                      NUMBER;
   l_return_status        VARCHAR2(1);
   l_err_stage            VARCHAR2(120);
   l_msg_data             VARCHAR2(2000);
   l_msg_count            NUMBER;
   l_msg_code             VARCHAR2(30);
   l_project_id           NUMBER;
   l_task_assignment_periods_out PA_TASK_ASSIGNMENTS_PUB.ASSIGNMENT_OUT_TBL_TYPE;
L_FuncProc varchar2(2000);

   -- Added for bug 5469303
   CURSOR C_Get_Budget_Version_Id(p_structure_version_id IN NUMBER) is
   select budget_version_id
     from pa_budget_versions
    where project_structure_version_id = p_structure_version_id
      and project_id = p_pa_project_id;

		l_budget_version_id       number;
  l_struct_elem_version_id  number;


BEGIN
L_FuncProc := 'Update_Task_Asgmt_Periods';

IF P_DEBUG_MODE = 'Y' AND (li_curr_level <= 3) THEN
pa_debug.g_err_stage:='Entered ' || L_FuncProc;
pa_debug.write(G_PKG_NAME ,pa_debug.g_err_stage,3);
END IF;
--  Standard begin of API savepoint

    SAVEPOINT UPDATE_TASK_ASGMT_PERIODS;

--  Standard call to check for call compatibility.

    IF NOT FND_API.Compatible_API_Call ( 1.0, --g_api_version_number  ,
                               p_api_version_number,
                               l_api_name,
                               G_PKG_NAME         )
    THEN
         RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;

--  Initialize the message table if requested.

    IF FND_API.TO_BOOLEAN( p_init_msg_list )
    THEN
       FND_MSG_PUB.initialize;
    END IF;



--  Set API return status to success

    x_return_status := FND_API.G_RET_STS_SUCCESS;

   -- Added for bug 5469303
        IF  p_pa_structure_version_id IS NOT NULL AND (p_pa_structure_version_id <> PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM) THEN
				l_struct_elem_version_id := p_pa_structure_version_id;
	ELSE
				l_struct_elem_version_id := PA_PROJECT_STRUCTURE_UTILS.get_current_working_ver_id( p_project_id => p_pa_project_id);
	END IF;

	IF ( l_struct_elem_version_id = PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM OR l_struct_elem_version_id IS NULL  ) THEN
	  IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.G_MSG_LVL_ERROR) THEN
		pa_interface_utils_pub.map_new_amg_msg ( p_old_message_code => 'PA_PS_STRUC_VER_REQ'
							,p_msg_attribute    => 'CHANGE'
							,p_resize_flag      => 'N'
							,p_msg_context      => 'GENERAL'
						        ,p_attribute1       => ''
							,p_attribute2       => ''
							,p_attribute3       => ''
							,p_attribute4       => ''
							,p_attribute5       => '');
       	END IF;
	RAISE FND_API.G_EXC_ERROR;
     END IF;


			OPEN C_Get_Budget_Version_Id(l_struct_elem_version_id);
			FETCH C_Get_Budget_Version_Id INTO l_budget_version_id;
			CLOSE C_Get_Budget_Version_Id;

			IF ( l_budget_version_id = PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM OR l_budget_version_id IS NULL  ) THEN
				IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.G_MSG_LVL_ERROR) THEN
				  PA_UTILS.ADD_MESSAGE (p_app_short_name => 'PA',
							p_msg_name       => 'PA_FP_PROJ_VERSION_MISMATCH'
							);
			        END IF;
			x_return_status    := FND_API.G_RET_STS_ERROR;
			RAISE FND_API.G_EXC_ERROR;

                        END IF;

			IF P_DEBUG_MODE = 'Y' AND (li_curr_level <= 3) THEN
				pa_debug.g_err_stage:=' budget version id: ' || l_budget_version_id ;
				pa_debug.write(G_PKG_NAME ,pa_debug.g_err_stage,3);
			END IF;
   -- End of changes for bug 5469303


    Init_Task_Assignments;
        g_asgmts_periods_tbl_count := p_task_assignment_periods_in.count;


        IF nvl(p_task_assignments_in.COUNT, 0) > 0 THEN

                      -- Bug 4200146: Set the global variable to indicate that update task assignments
                      --  is called with update task assignment periods
                      --  Prevent rollup from happening in PJI plan update call
                      g_periodic_mode := 'Y';
                      PA_TASK_PUB1.G_CALL_PJI_ROLLUP := 'N';

                      Update_Task_Assignments
                      (  p_api_version_number        => 1.0
                      ,p_commit                          => FND_API.G_FALSE
                      ,p_init_msg_list           => FND_API.G_FALSE
                          ,p_pm_product_code         => p_pm_product_code
                          ,p_pm_project_reference    => p_pm_project_reference
                          ,p_pa_project_id           => p_pa_project_id
                          ,p_pa_structure_version_id => p_pa_structure_version_id
                          ,p_task_assignments_in     => p_task_assignments_in
                      ,p_task_assignments_out    => p_task_assignments_out
                      ,x_msg_count                       => l_msg_count
                      ,x_msg_data                        => l_msg_data
                      ,x_return_status               => l_return_status
                      );

                      -- Bug 4200146
                      g_periodic_mode := null;
                      PA_TASK_PUB1.G_CALL_PJI_ROLLUP := null;

                          IF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN

                                RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

                           ELSIF l_return_status = FND_API.G_RET_STS_ERROR THEN

                                RAISE FND_API.G_EXC_ERROR;

                         END IF;

          END IF;


   IF nvl(p_task_assignment_periods_in.count,0) > 0 THEN

              -- Bug 4200146: Set the global variable to
              --  prevent rollup from happening in PJI plan update call
              PA_TASK_PUB1.G_CALL_PJI_ROLLUP := 'N';

              Pa_Task_Assignments_pvt.Create_Task_Assignment_Periods
                (  p_api_version_number            => 1.0
                  ,p_commit                                 => FND_API.G_FALSE
                  ,p_init_msg_list                  => FND_API.G_FALSE
                  ,p_pm_product_code                => p_pm_product_code
                  ,p_pm_project_reference           => p_pm_project_reference
                  ,p_pa_project_id                  => p_pa_project_id
                  ,p_pa_structure_version_id        => p_pa_structure_version_id
                  ,p_task_assignment_periods_in     => p_task_assignment_periods_in
                  ,p_task_assignment_periods_out    => l_task_assignment_periods_out
                  ,x_msg_count                              => l_msg_count
                  ,x_msg_data                               => l_msg_data
                  ,x_return_status                      => l_return_status
              );

              -- Bug 4200146
              PA_TASK_PUB1.G_CALL_PJI_ROLLUP := null;

                 IF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN

                          RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

                ELSIF l_return_status = FND_API.G_RET_STS_ERROR THEN

                        RAISE FND_API.G_EXC_ERROR;

                 END IF;

   END IF;

   -- Bug 4200146: Call PJI update update
   IF nvl(p_task_assignments_in.COUNT, 0) > 0 OR nvl(p_task_assignment_periods_in.count,0) > 0 THEN
     PJI_FM_XBS_ACCUM_MAINT.PLAN_UPDATE (p_plan_version_id => l_budget_version_id,  -- added for bug 5469303
                                         x_msg_code => l_msg_code,
                                         x_return_status => l_return_status);


     IF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
       RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
     ELSIF l_return_status = FND_API.G_RET_STS_ERROR THEN
      RAISE FND_API.G_EXC_ERROR;
     END IF;

   END IF;



     IF FND_API.to_boolean( p_commit ) THEN
        COMMIT;
     END IF;


EXCEPTION

  WHEN FND_API.G_EXC_ERROR
  THEN
       ROLLBACK TO UPDATE_TASK_ASGMT_PERIODS;

       x_return_status := FND_API.G_RET_STS_ERROR;
IF P_DEBUG_MODE = 'Y' THEN
       PA_DEBUG.write_log (x_module => G_PKG_NAME
                               ,x_msg         => 'Expected Error:' || L_FuncProc || SQLERRM
                               ,x_log_level   => 5);
END IF;
       FND_MSG_PUB.Count_And_Get
           (   p_count    =>  x_msg_count  ,
               p_data    =>   x_msg_data  );

  WHEN FND_API.G_EXC_UNEXPECTED_ERROR
  THEN
       ROLLBACK TO UPDATE_TASK_ASGMT_PERIODS;

       x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
IF P_DEBUG_MODE = 'Y' THEN
       PA_DEBUG.write_log (x_module => G_PKG_NAME
                               ,x_msg         => 'Unexpected Error:' || L_FuncProc || SQLERRM
                               ,x_log_level   => 5);
END IF;
       FND_MSG_PUB.Count_And_Get
           (   p_count    =>  x_msg_count  ,
               p_data    =>  x_msg_data  );

  WHEN OTHERS THEN
       ROLLBACK TO UPDATE_TASK_ASGMT_PERIODS;

       -- Bug 4200146: Reset the masks
       g_periodic_mode := null;
       PA_TASK_PUB1.G_CALL_PJI_ROLLUP := null;

       x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
IF P_DEBUG_MODE = 'Y' THEN
       PA_DEBUG.write_log (x_module => G_PKG_NAME
                               ,x_msg         => 'Unexpected Error:' || L_FuncProc || SQLERRM
                               ,x_log_level   => 5);
END IF;
       IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
       THEN
         FND_MSG_PUB.add_exc_msg
             ( p_pkg_name    => G_PKG_NAME
             , p_procedure_name  => l_api_name  );

       END IF;

       FND_MSG_PUB.Count_And_Get
           (   p_count    =>  x_msg_count  ,
               p_data    =>  x_msg_data  );
END Update_Task_Assignment_Periods;


PROCEDURE Delete_Task_Assignments
( p_api_version_number        IN  NUMBER           := PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM
 ,p_commit                                IN  VARCHAR2     := FND_API.G_FALSE
 ,p_init_msg_list                 IN  VARCHAR2     := FND_API.G_FALSE
 --Either project reference or project id is required
 ,p_pm_project_reference      IN  VARCHAR2     := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
 ,p_pa_project_id             IN  NUMBER       := PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM
 --Structure version id is required
 ,p_pa_structure_version_id   IN  NUMBER       := PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM
 --Pass in list of task assignment id's or references as information at a minimum
 ,p_task_assignments_in       IN  ASSIGNMENT_IN_TBL_TYPE
 ,x_msg_count                     OUT NOCOPY NUMBER
 ,x_msg_data                      OUT NOCOPY VARCHAR2
 ,x_return_status                     OUT NOCOPY VARCHAR2
) IS
   l_pm_product_code      VARCHAR2(30) := 'INTERNAL';
   l_task_assignments_out  ASSIGNMENT_OUT_TBL_TYPE;
   l_api_name             CONSTANT  VARCHAR2(30)     := 'Delete_Task_Assignments';
   i                      NUMBER;
   l_return_status        VARCHAR2(1);
   l_err_stage            VARCHAR2(120);
   l_msg_data             VARCHAR2(2000);
   l_msg_count            NUMBER;
   l_project_id           NUMBER;

L_FuncProc varchar2(2000);

  l_task_assignments_in ASSIGNMENT_IN_TBL_TYPE;

BEGIN
L_FuncProc := 'Delete_Task_Assignments';

IF P_DEBUG_MODE = 'Y' AND (li_curr_level <= 3) THEN
pa_debug.g_err_stage:='Entered ' || L_FuncProc;
pa_debug.write(G_PKG_NAME ,pa_debug.g_err_stage,3);
END IF;
--dbms_output.put_line('Entered Delete_Task_Assignments: ' || L_FuncProc);

--  Standard begin of API savepoint

    SAVEPOINT Delete_Task_Assignments;

--  Standard call to check for call compatibility.

    IF NOT FND_API.Compatible_API_Call ( 1.0, --g_api_version_number  ,
                               p_api_version_number,
                               l_api_name,
                               G_PKG_NAME         )
    THEN
         RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;


--  Initialize the message table if requested.

    IF FND_API.TO_BOOLEAN( p_init_msg_list )
    THEN
       FND_MSG_PUB.initialize;
    END IF;



--  Set API return status to success

    x_return_status := FND_API.G_RET_STS_SUCCESS;


        IF nvl(p_task_assignments_in.COUNT, 0) > 0 THEN

                l_task_assignments_in := p_task_assignments_in;

                  FOR i in 1..l_task_assignments_in.COUNT LOOP

                     l_task_assignments_in(i).p_context := 'D';

                  END LOOP;
                  --dbms_output.put_line('From  Delete_Task_Assignments calling Update_Task_Assignments' );
                      Update_Task_Assignments
                      (  p_api_version_number        => 1.0
                      ,p_commit                          => FND_API.G_FALSE
                      ,p_init_msg_list           => FND_API.G_FALSE
                          ,p_pm_product_code         => l_pm_product_code
                          ,p_pm_project_reference    => p_pm_project_reference
                          ,p_pa_project_id           => p_pa_project_id
                          ,p_pa_structure_version_id => p_pa_structure_version_id
                          ,p_task_assignments_in     => l_task_assignments_in
                      ,p_task_assignments_out    => l_task_assignments_out
                      ,x_msg_count                       => l_msg_count
                      ,x_msg_data                        => l_msg_data
                      ,x_return_status               => l_return_status
                      );

                        IF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN

                                RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

                        ELSIF l_return_status = FND_API.G_RET_STS_ERROR THEN

                                 RAISE FND_API.G_EXC_ERROR;

                        END IF;

         END IF;


     IF FND_API.to_boolean( p_commit ) THEN
        COMMIT;
     END IF;

EXCEPTION

  WHEN FND_API.G_EXC_ERROR
  THEN
       ROLLBACK TO Delete_Task_Assignments;

       x_return_status := FND_API.G_RET_STS_ERROR;
IF P_DEBUG_MODE = 'Y' THEN
       PA_DEBUG.write_log (x_module => G_PKG_NAME
                               ,x_msg         => 'Expected Error:' || L_FuncProc || SQLERRM
                               ,x_log_level   => 5);
END IF;
       FND_MSG_PUB.Count_And_Get
           (   p_count    =>  x_msg_count  ,
               p_data    =>   x_msg_data  );

  WHEN FND_API.G_EXC_UNEXPECTED_ERROR
  THEN
       ROLLBACK TO Delete_Task_Assignments;

       x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
IF P_DEBUG_MODE = 'Y' THEN
       PA_DEBUG.write_log (x_module => G_PKG_NAME
                               ,x_msg         => 'Unexpected Error:' || L_FuncProc || SQLERRM
                               ,x_log_level   => 5);
END IF;
       FND_MSG_PUB.Count_And_Get
           (   p_count    =>  x_msg_count  ,
               p_data    =>  x_msg_data  );

  WHEN OTHERS THEN
       ROLLBACK TO Delete_Task_Assignments;

       x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
IF P_DEBUG_MODE = 'Y' THEN
       PA_DEBUG.write_log (x_module => G_PKG_NAME
                               ,x_msg         => 'Unexpected Error:' || L_FuncProc || SQLERRM
                               ,x_log_level   => 5);
END IF;
       IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
       THEN
         FND_MSG_PUB.add_exc_msg
             ( p_pkg_name    => G_PKG_NAME
             , p_procedure_name  => l_api_name  );

       END IF;

       FND_MSG_PUB.Count_And_Get
           (   p_count    =>  x_msg_count  ,
               p_data    =>  x_msg_data  );
END Delete_Task_Assignments;



PROCEDURE Update_Task_Assignments
( p_api_version_number        IN  NUMBER           := PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM
 ,p_commit                                IN  VARCHAR2     := FND_API.G_FALSE
 ,p_init_msg_list                 IN  VARCHAR2     := FND_API.G_FALSE
 ,p_pm_product_code               IN  VARCHAR2     := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
 ,p_pm_project_reference      IN  VARCHAR2     := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
 ,p_pa_project_id             IN  NUMBER       := PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM
 ,p_pa_structure_version_id   IN  NUMBER       := PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM
 ,p_task_assignments_in       IN  ASSIGNMENT_IN_TBL_TYPE
 ,p_task_assignments_out      OUT NOCOPY ASSIGNMENT_OUT_TBL_TYPE
 ,x_msg_count                     OUT NOCOPY NUMBER
 ,x_msg_data                      OUT NOCOPY VARCHAR2
 ,x_return_status                     OUT NOCOPY VARCHAR2
) IS
   l_rlm_id                                              NUMBER;
   l_task_elem_version_id        NUMBER;
   l_project_id                  pa_projects_all.project_id%type;
   l_d_task_id                   NUMBER;
   l_task_assignment_id          NUMBER;
   l_msg_count                   NUMBER ;
   l_msg_data                    VARCHAR2(2000);
   l_function_allowed            VARCHAR2(1);
   l_resp_id                     NUMBER := 0;
   l_user_id                     NUMBER := 0;
   l_module_name                 VARCHAR2(80);
   l_return_status               VARCHAR2(1);
   l_api_name                    CONSTANT  VARCHAR2(30)     := 'update_task_assignments';
   i                             NUMBER;
   l_count                       NUMBER;
   int_del_index                 NUMBER;
   int_del_tmp_index             NUMBER := 0;
   l_msg_code                    VARCHAR2(30);

   l_task_asgmt_del_tbl          task_asgmt_del_tbl_type ;

   l_ta_del_tmp_tbl              assignment_del_tbl_type;
   l_ta_del_empty_tbl            assignment_del_tbl_type;

   l_ta_del_tbl                  assignment_del_tbl_type;

   l_temp_proj_ass_id            NUMBER :=-99; --bug#9374037

   l_context                     varchar2(200);
   l_calling_module              varchar2(200);
   l_struct_elem_version_id      number;
   l_budget_version_id           number;
   l_task_elem_version_id_tbl    system.pa_num_tbl_type := system.pa_num_tbl_type();
   l_task_name_tbl               system.pa_varchar2_240_tbl_type := system.pa_varchar2_240_tbl_type();
   l_task_number_tbl             system.pa_varchar2_100_tbl_type :=  system.pa_varchar2_100_tbl_type();
   l_incur_by_resource_code_tbl  system.pa_varchar2_30_tbl_type  :=system.pa_varchar2_30_tbl_type() ;
   l_incur_by_resource_name_tbl  system.pa_varchar2_240_tbl_type :=system.pa_varchar2_240_tbl_type() ;
   l_incur_by_res_class_code_tbl system.pa_varchar2_30_tbl_type  :=system.pa_varchar2_30_tbl_type();
   lu_task_elem_version_id_tbl   system.pa_num_tbl_type := system.pa_num_tbl_type();
   ld_task_elem_version_id_tbl   system.pa_num_tbl_type := system.pa_num_tbl_type();
   l_start_date_tbl              system.pa_date_tbl_type := system.pa_date_tbl_type();
   l_end_date_tbl                system.pa_date_tbl_type := system.pa_date_tbl_type();
   l_planning_start_date_tbl     system.pa_date_tbl_type := system.pa_date_tbl_type();
   l_planning_end_date_tbl       system.pa_date_tbl_type := system.pa_date_tbl_type();

   l_latest_eff_pub_flag_tbl     system.pa_varchar2_1_tbl_type := system.pa_varchar2_1_tbl_type();
   l_resource_list_member_id_tbl system.pa_num_tbl_type := system.pa_num_tbl_type();
   l_project_assignment_id_tbl   system.pa_num_tbl_type := system.pa_num_tbl_type();
   l_quantity_tbl                system.pa_num_tbl_type := system.pa_num_tbl_type();
   l_currency_code_tbl           system.pa_varchar2_15_tbl_type := system.pa_varchar2_15_tbl_type();
   l_raw_cost_tbl                system.pa_num_tbl_type := system.pa_num_tbl_type();
   l_burdened_cost_tbl           system.pa_num_tbl_type := system.pa_num_tbl_type();
   l_revenue_tbl                 system.pa_num_tbl_type := system.pa_num_tbl_type();
   l_resource_assignment_id_tbl  system.pa_num_tbl_type := system.pa_num_tbl_type();
   lp_resource_assignment_id_tbl system.pa_num_tbl_type := system.pa_num_tbl_type();
   ld_resource_assignment_id_tbl system.pa_num_tbl_type := system.pa_num_tbl_type();
   l_resource_class_code_tbl     system.pa_varchar2_30_tbl_type :=  system.pa_varchar2_30_tbl_type();
   l_resource_alias_tbl          system.pa_varchar2_80_tbl_type  := system.pa_varchar2_80_tbl_type();
   l_res_type_code_tbl           system.pa_varchar2_30_tbl_type  := system.pa_varchar2_30_tbl_type();
   l_resource_code_tbl           system.pa_varchar2_30_tbl_type  := system.pa_varchar2_30_tbl_type();
   l_resource_name               system.pa_varchar2_240_tbl_type := system.pa_varchar2_240_tbl_type();
   l_project_role_id_tbl         system.pa_num_tbl_type          := system.pa_num_tbl_type();
   l_project_role_name_tbl       system.pa_varchar2_150_tbl_type := system.pa_varchar2_150_tbl_type();
   l_supplier_id_tbl             system.pa_num_tbl_type          := system.pa_num_tbl_type();
   l_supplier_name_tbl           system.pa_varchar2_240_tbl_type := system.pa_varchar2_240_tbl_type();
   l_organization_id_tbl         system.pa_num_tbl_type          := system.pa_num_tbl_type();
   l_organization_name_tbl       system.pa_varchar2_240_tbl_type := system.pa_varchar2_240_tbl_type();
   l_fc_res_type_code_tbl        system.pa_varchar2_30_tbl_type  := system.pa_varchar2_30_tbl_type();
   l_financial_category_name_tbl system.pa_varchar2_80_tbl_type  := system.pa_varchar2_80_tbl_type();
   l_named_role_tbl              system.pa_varchar2_80_tbl_type  := system.pa_varchar2_80_tbl_type() ;

   l_attribute_category_tbl         system.pa_varchar2_30_tbl_type := system.pa_varchar2_30_tbl_type();
   l_attribute1_tbl                 system.pa_varchar2_150_tbl_type := system.pa_varchar2_150_tbl_type();
   l_attribute2_tbl                 system.pa_varchar2_150_tbl_type := system.pa_varchar2_150_tbl_type();
   l_attribute3_tbl                 system.pa_varchar2_150_tbl_type := system.pa_varchar2_150_tbl_type();
   l_attribute4_tbl                 system.pa_varchar2_150_tbl_type := system.pa_varchar2_150_tbl_type();
   l_attribute5_tbl                 system.pa_varchar2_150_tbl_type := system.pa_varchar2_150_tbl_type();
   l_attribute6_tbl                 system.pa_varchar2_150_tbl_type := system.pa_varchar2_150_tbl_type();
   l_attribute7_tbl                 system.pa_varchar2_150_tbl_type := system.pa_varchar2_150_tbl_type();
   l_attribute8_tbl                 system.pa_varchar2_150_tbl_type := system.pa_varchar2_150_tbl_type();
   l_attribute9_tbl                 system.pa_varchar2_150_tbl_type := system.pa_varchar2_150_tbl_type();
   l_attribute10_tbl                system.pa_varchar2_150_tbl_type := system.pa_varchar2_150_tbl_type();
   l_attribute11_tbl                system.pa_varchar2_150_tbl_type := system.pa_varchar2_150_tbl_type();
   l_attribute12_tbl                system.pa_varchar2_150_tbl_type := system.pa_varchar2_150_tbl_type();
   l_attribute13_tbl                system.pa_varchar2_150_tbl_type := system.pa_varchar2_150_tbl_type();
   l_attribute14_tbl                system.pa_varchar2_150_tbl_type := system.pa_varchar2_150_tbl_type();
   l_attribute15_tbl                system.pa_varchar2_150_tbl_type := system.pa_varchar2_150_tbl_type();
   l_attribute16_tbl                system.pa_varchar2_150_tbl_type := system.pa_varchar2_150_tbl_type();
   l_attribute17_tbl                system.pa_varchar2_150_tbl_type := system.pa_varchar2_150_tbl_type();
   l_attribute18_tbl                system.pa_varchar2_150_tbl_type := system.pa_varchar2_150_tbl_type();
   l_attribute19_tbl                system.pa_varchar2_150_tbl_type := system.pa_varchar2_150_tbl_type();
   l_attribute20_tbl                system.pa_varchar2_150_tbl_type := system.pa_varchar2_150_tbl_type();
   l_attribute21_tbl                system.pa_varchar2_150_tbl_type := system.pa_varchar2_150_tbl_type();
   l_attribute22_tbl                system.pa_varchar2_150_tbl_type := system.pa_varchar2_150_tbl_type();
   l_attribute23_tbl                system.pa_varchar2_150_tbl_type := system.pa_varchar2_150_tbl_type();
   l_attribute24_tbl                system.pa_varchar2_150_tbl_type := system.pa_varchar2_150_tbl_type();
   l_attribute25_tbl                system.pa_varchar2_150_tbl_type := system.pa_varchar2_150_tbl_type();
   l_attribute26_tbl                system.pa_varchar2_150_tbl_type := system.pa_varchar2_150_tbl_type();
   l_attribute27_tbl                system.pa_varchar2_150_tbl_type := system.pa_varchar2_150_tbl_type();
   l_attribute28_tbl                system.pa_varchar2_150_tbl_type := system.pa_varchar2_150_tbl_type();
   l_attribute29_tbl                system.pa_varchar2_150_tbl_type := system.pa_varchar2_150_tbl_type();
   l_attribute30_tbl                system.pa_varchar2_150_tbl_type := system.pa_varchar2_150_tbl_type();
   l_description_tbl                system.pa_varchar2_240_tbl_type := system.pa_varchar2_240_tbl_type();
   l_use_task_schedule_flag_tbl     system.pa_varchar2_1_tbl_type := system.pa_varchar2_1_tbl_type();
   l_raw_cost_rate_override_tbl     system.pa_num_tbl_type := system.pa_num_tbl_type();
   l_burd_cost_rate_override_tbl    system.pa_num_tbl_type := system.pa_num_tbl_type();
   l_billable_work_percent_tbl      system.pa_num_tbl_type := system.pa_num_tbl_type();
   l_mfc_cost_type_id_tbl               system.pa_num_tbl_type := system.pa_num_tbl_type();

   l_scheduled_delay_tbl            system.pa_num_tbl_type := system.pa_num_tbl_type();--Bug 3948128: TA Delay CR by DHI

  --For create.
   lc_task_elem_version_id_tbl    system.pa_num_tbl_type := system.pa_num_tbl_type();
   lc_task_name_tbl               system.pa_varchar2_240_tbl_type := system.pa_varchar2_240_tbl_type();
   lc_task_number_tbl             system.pa_varchar2_100_tbl_type :=  system.pa_varchar2_100_tbl_type();
   lc_start_date_tbl              system.pa_date_tbl_type := system.pa_date_tbl_type();
   lc_end_date_tbl                system.pa_date_tbl_type := system.pa_date_tbl_type();
   lc_planned_people_effort_tbl   system.pa_num_tbl_type := system.pa_num_tbl_type();
   lc_planned_equip_effort_tbl    system.pa_num_tbl_type := system.pa_num_tbl_type();
   lc_latest_eff_pub_flag_tbl     system.pa_varchar2_1_tbl_type := system.pa_varchar2_1_tbl_type();
   lc_resource_list_member_id_tbl system.pa_num_tbl_type := system.pa_num_tbl_type();
   lc_project_assignment_id_tbl   system.pa_num_tbl_type := system.pa_num_tbl_type();
   lc_quantity_tbl                system.pa_num_tbl_type := system.pa_num_tbl_type();
   lc_currency_code_tbl           system.pa_varchar2_15_tbl_type := system.pa_varchar2_15_tbl_type();
   lc_raw_cost_tbl                system.pa_num_tbl_type := system.pa_num_tbl_type();
   lc_burdened_cost_tbl           system.pa_num_tbl_type := system.pa_num_tbl_type();
   lc_revenue_tbl                 system.pa_num_tbl_type := system.pa_num_tbl_type();
   lc_cost_rate_tbl               system.pa_num_tbl_type := system.pa_num_tbl_type();
   lc_bill_rate_tbl               system.pa_num_tbl_type := system.pa_num_tbl_type();
   lc_burdened_rate_tbl           system.pa_num_tbl_type := system.pa_num_tbl_type();
   lc_product_code_tbl            system.pa_varchar2_30_tbl_type := system.pa_varchar2_30_tbl_type();
   lc_product_reference_tbl       system.pa_varchar2_30_tbl_type := system.pa_varchar2_30_tbl_type();  --incorrect to change to 25.
--   l_attribute_category_tbl         system.pa_varchar2_30_tbl_type;
   lc_attribute1 system.pa_varchar2_150_tbl_type := system.pa_varchar2_150_tbl_type();
   lc_attribute2 system.pa_varchar2_150_tbl_type := system.pa_varchar2_150_tbl_type();
   lc_attribute3 system.pa_varchar2_150_tbl_type := system.pa_varchar2_150_tbl_type();
   lc_attribute4 system.pa_varchar2_150_tbl_type := system.pa_varchar2_150_tbl_type();
   lc_attribute5 system.pa_varchar2_150_tbl_type := system.pa_varchar2_150_tbl_type();
   lc_attribute6 system.pa_varchar2_150_tbl_type := system.pa_varchar2_150_tbl_type();
   lc_attribute7 system.pa_varchar2_150_tbl_type := system.pa_varchar2_150_tbl_type();
   lc_attribute8 system.pa_varchar2_150_tbl_type := system.pa_varchar2_150_tbl_type();
   lc_attribute9 system.pa_varchar2_150_tbl_type := system.pa_varchar2_150_tbl_type();
   lc_attribute10 system.pa_varchar2_150_tbl_type := system.pa_varchar2_150_tbl_type();
   lc_attribute11 system.pa_varchar2_150_tbl_type := system.pa_varchar2_150_tbl_type();
   lc_attribute12 system.pa_varchar2_150_tbl_type := system.pa_varchar2_150_tbl_type();
   lc_attribute13 system.pa_varchar2_150_tbl_type := system.pa_varchar2_150_tbl_type();
   lc_attribute14 system.pa_varchar2_150_tbl_type := system.pa_varchar2_150_tbl_type();
   lc_attribute15 system.pa_varchar2_150_tbl_type := system.pa_varchar2_150_tbl_type();
   lc_attribute16 system.pa_varchar2_150_tbl_type := system.pa_varchar2_150_tbl_type();
   lc_attribute17 system.pa_varchar2_150_tbl_type := system.pa_varchar2_150_tbl_type();
   lc_attribute18 system.pa_varchar2_150_tbl_type := system.pa_varchar2_150_tbl_type();
   lc_attribute19 system.pa_varchar2_150_tbl_type := system.pa_varchar2_150_tbl_type();
   lc_attribute20 system.pa_varchar2_150_tbl_type := system.pa_varchar2_150_tbl_type();
   lc_attribute21 system.pa_varchar2_150_tbl_type := system.pa_varchar2_150_tbl_type();
   lc_attribute22 system.pa_varchar2_150_tbl_type := system.pa_varchar2_150_tbl_type();
   lc_attribute23 system.pa_varchar2_150_tbl_type := system.pa_varchar2_150_tbl_type();
   lc_attribute24 system.pa_varchar2_150_tbl_type := system.pa_varchar2_150_tbl_type();
   lc_attribute25 system.pa_varchar2_150_tbl_type := system.pa_varchar2_150_tbl_type();
   lc_attribute26 system.pa_varchar2_150_tbl_type := system.pa_varchar2_150_tbl_type();
   lc_attribute27 system.pa_varchar2_150_tbl_type := system.pa_varchar2_150_tbl_type();
   lc_attribute28 system.pa_varchar2_150_tbl_type := system.pa_varchar2_150_tbl_type();
   lc_attribute29 system.pa_varchar2_150_tbl_type := system.pa_varchar2_150_tbl_type();
   lc_attribute30 system.pa_varchar2_150_tbl_type := system.pa_varchar2_150_tbl_type();

   lc_scheduled_delay_tbl            system.pa_num_tbl_type := system.pa_num_tbl_type();--Bug 3948128: TA Delay CR by DHI

--   l_planned_people_effort_tbl   system.pa_num_tbl_type;
--   l_planned_equip_effort_tbl    system.pa_num_tbl_type;
--   l_cost_rate_tbl               system.pa_num_tbl_type;
--   l_bill_rate_tbl               system.pa_num_tbl_type;
--   l_burdened_rate_tbl           system.pa_num_tbl_type;

 --Added following two collections for for Bug 3940284
   l_delete_task_res_asgmt_id_tbl system.pa_num_tbl_type := system.pa_num_tbl_type();
   l_delete_task_elem_ver_id_tbl  system.pa_num_tbl_type := system.pa_num_tbl_type();

   none_resource_list_flag varchar2(1);
--Added by rbanerje - Bug 8646853 -start
   l_spread_curve_id NUMBER;
   l_spread_curve_exists VARCHAR2(1);
   l_fixed_date DATE;
   l_spread_curve_id_tbl system.pa_num_tbl_type := system.pa_num_tbl_type();
   l_spread_curve_code pa_spread_curves_b.spread_curve_code%TYPE ;
   l_fixed_date_tbl system.pa_date_tbl_type :=system.pa_date_tbl_type();
   l_time_phased_code pa_proj_fp_options.all_time_phased_code%TYPE;  --8429604
   --Bug#8646853 -Addition end

--Bug#9374037
   CURSOR C_Proj_Ass_Id(p_resource_assignment_id IN NUMBER) IS
   select project_assignment_id
   from pa_resource_assignments
   where resource_assignment_id = p_resource_assignment_id;

  CURSOR C_Check_Res_List_None (c_resource_list_id IN NUMBER) IS
     SELECT uncategorized_flag
       FROM pa_resource_lists
      WHERE resource_list_id = c_resource_list_id;

   CURSOR C_Get_Budget_Version_Id(p_structure_version_id IN NUMBER) is
   select budget_version_id
   from pa_budget_versions
   where project_structure_version_id = p_structure_version_id
   and project_id = p_pa_project_id;

   CURSOR C_Task_Elem_Version_Id(p_structure_version_id IN NUMBER,
                                 p_task_id in NUMBER,
                                 p_project_id IN NUMBER) IS
   SELECT pe.element_version_id
   from pa_proj_element_versions pe
   where parent_structure_version_id = p_structure_version_id
   and pe.proj_element_id = p_task_id
   and pe.project_id = p_project_id;

    CURSOR C_task_version(p_task_element_version_id IN NUMBER) IS
   SELECT pe.element_version_id, pe.proj_element_id
   from pa_proj_element_versions pe
   where pe.element_version_id = p_task_element_version_id;

   c_index NUMBER := 0;
   u_index NUMBER := 0;
   del_index NUMBER := 0;

   CURSOR c_cur_out(p_structure_version_id IN NUMBER,
                    p_project_id IN NUMBER,
                                        p_wbs_version_id IN NUMBER,
                                        p_resource_list_member_id IN NUMBER ) IS
   Select a.alias, b.resource_assignment_id
   from pa_resource_list_members a, pa_resource_assignments b, pa_budget_versions bv
   where a.resource_list_member_id = b.resource_list_member_id
   and b.resource_list_member_id = p_resource_list_member_id
   and b.ta_display_flag = 'Y'
   and b.budget_version_id = bv.budget_version_id
   and b.project_id = bv.project_id
   and bv.project_structure_version_id = p_structure_version_id
   and b.project_id = p_project_id
   and b.wbs_element_version_id = p_wbs_version_id;
    c_rec_out c_cur_out%ROWTYPE;

   CURSOR C_Res_List_mem_Check(p_resource_list_member_id IN NUMBER) IS
   SELECT par.ALIAS, par.resource_class_code
   from pa_resource_list_members par
   where resource_list_member_id = p_resource_list_member_id;
   C_Res_List_Mem_Check_Rec C_Res_List_Mem_Check%ROWTYPE;



   Cursor C_Cost_Type(p_cost_type IN VARCHAR2) IS
   select cost_type_id
   from cst_cost_types_V
   where multi_org_flag = 1
   and cost_type = p_cost_type;
   C_Cost_Type_rec C_Cost_Type%ROWTYPE;

   Cursor C_Cost_Type_Exists(p_cost_type_id IN NUMBER) IS
   select 'X'
   from cst_cost_types_V
   where multi_org_flag = 1
   and cost_type_id = p_cost_type_id;
   C_Cost_Type_Exists_rec C_Cost_Type_Exists%ROWTYPE;

   Cursor C_UOM_exists(p_uom_code IN VARCHAR2) IS
   select lookup_code --meaning
   from pa_lookups
   where lookup_type = 'UNIT'
   and lookup_code = p_uom_code;
   C_UOM_exists_rec C_UOM_exists%ROWTYPE;

   Cursor C_UOM(p_uom IN VARCHAR2) IS
   select lookup_code --meaning
   from pa_lookups
   where lookup_type = 'UNIT'
   and meaning = p_uom;
   C_UOM_rec C_UOM%ROWTYPE;

   Cursor C_Currency_Exists(p_currency_code IN VARCHAR2, p_project_id IN NUMBER) IS
   select distinct TXN_CURRENCY_CODE
   from PA_FP_TXN_CURRENCIES
   where project_id = p_project_id and txn_currency_code = p_currency_code;
   C_Currency_Exists_rec C_Currency_Exists%ROWTYPE;
   --
   Cursor C_Currency_Default( p_project_id IN NUMBER) IS
   select distinct TXN_CURRENCY_CODE
   from PA_FP_TXN_CURRENCIES
   where  --PROJECT_CURRENCY_FLAG = 'Y'
   -- and
    PROJFUNC_CURRENCY_FLAG = 'Y';
   C_Currency_Default_rec C_Currency_Default%ROWTYPE;

   L_FuncProc varchar2(2000);

   l_cost_type_id NUMBER;
   l_cost_type_exists VARCHAR2(1);
   l_uom_code VARCHAR2(30);
   l_uom_exists VARCHAR2(1);
   l_currency_code VARCHAR2(15);

   CURSOR C_Res_Asgmt_Data(p_resource_assignment_id IN NUMBER) IS
   select task_id, wbs_element_version_id, resource_class_code, resource_assignment_id,
   project_role_id, organization_id,
   fc_res_type_code, named_role,res_type_code, planning_start_date, planning_end_date,
   use_task_schedule_flag, rate_based_flag, supplier_id
   from pa_resource_assignments
   where resource_assignment_id = p_resource_assignment_id;
   C_Res_Asgmt_Data_Rec C_Res_Asgmt_Data%ROWTYPE;

  ip_fc_res_type_code varchar2(200);
  ip_expenditure_type varchar2(200);
  ip_expenditure_category varchar2(200);
  ip_event_type varchar2(200);
  ip_revenue_category_code varchar2(200);

  lp_res_type_code varchar2(200);
  lp_person_id number;
  lp_bom_resource_id number;
  lp_job_id number;
  lp_person_type_code varchar2(200);
  lp_non_labor_resource varchar2(200);
  lp_inventory_item_id number;
  lp_resource_class_id number;
  lp_item_category_id number;

  -- Bug 3721630: 1) Change cursor to return all assignments
  -- in all task in the given structure version

  -- Bug Fix 5406196
  -- Issue: Unable to delete task assignments from MSP.
  -- Analysis: The p_pm_product code is the reason for the above.
  --           Whenever TAs are deleted from MSP p_pm_product_code is also passed.
  --           For TAs created using Oracle Projects the p_pm_product code is not populated.
  --		   This is causing the code to skip the TAs that are deleted from MSP, thus
  --		   a succesful message is shown in MSP without actually deleting the TA.
  -- Resolution: Comment out the p_pm_product_code check. Thus the code will go ahead and will
  --             mark the TAs to be deleted and will go through the regular validations
  --             and will either succesfully delete or will raise an error message.
  --			 This behaviour will be in consistent with the deletion of TA from Oracle Projects.

  -- Notes:
  --           There is a concern that this might be designed in that way. Not allowing the user to delete
  --           the Oracle Project's TA from third party tools.
  --           If that is the case then we need to loop through the tasks that are marked for delete and compare
  --           the p_pm_produce_code with the pm_product_code in the db. If they are not same then skip the delete
  --           and come up with the following message.
  --           You cannot delete a task assignment created in Oracle Projects using an external application.
  --           Task Number: <Task Number>. Resource Name : <Resource Name>
  --
  --   Currently going ahead with commenting out the pm_product_code check.

  CURSOR c_ta_del(p_structure_version_id in number, p_project_id in number) is
  select a.resource_assignment_id, a.wbs_element_version_id
  from pa_resource_assignments a, pa_budget_versions b
  where a.budget_version_id = b.budget_version_id
  and a.project_id = b.project_id
  and a.ta_display_flag = 'Y'
  and b.project_id = p_project_id
  and b.project_structure_version_id = p_structure_version_id;
--  and a.pm_product_code is not null
--  and a.pm_product_code = p_pm_product_code;
-- End of Bug Fix 5406196

  c_ta_del_rec c_ta_del%rowtype;

  l_resource_list_member_id NUMBER;

   -- Bug 4087956
--   Cursor C_Reference_Check(p_res_assignment_reference IN VARCHAR2) IS
   Cursor C_Reference_Check(p_res_assignment_reference IN VARCHAR2, c_budget_version_id IN NUMBER) IS
   select 'X'
   from pa_resource_assignments  a --, pa_budget_versions b
   where a.pm_res_assignment_reference = p_res_assignment_reference
   and a.pm_product_code = p_pm_product_code
   and a.project_id = p_pa_project_id
   and a.ta_display_flag is not null
   and a.budget_version_id = c_budget_version_id;
--   and b.project_structure_version_id = p_pa_structure_version_id
--   and a.budget_version_id = b.budget_version_id
--   and a.project_id = b.project_id;
   C_Reference_rec c_Reference_Check%ROWTYPE;

   CURSOR c_people_res_check(
                    p_structure_version_id IN NUMBER,
                    p_project_id IN NUMBER,
                                        p_wbs_version_id IN NUMBER
                                         ) IS
   Select b.budget_version_id
   from pa_resource_assignments b, pa_budget_versions bv
   where b.ta_display_flag = 'N'
   and b.budget_version_id = bv.budget_version_id
   and b.project_id = bv.project_id
   and bv.project_structure_version_id = p_structure_version_id
   and b.project_id = p_project_id
   and b.wbs_element_version_id = p_wbs_version_id
   and b.resource_class_code='PEOPLE'
   and b.pm_product_code is not NULL;
   c_people_res_rec c_people_res_check%ROWTYPE;


   CURSOR C_Workplan_Costs_enabled(p_budget_version_id IN NUMBER) IS
        select TRACK_WORKPLAN_COSTS_FLAG enabled_flag from pa_proj_fp_options
    where fin_plan_version_id = p_budget_version_id;
        C_Workplan_costs_rec C_Workplan_Costs_enabled%ROWTYPE;

   l_valid_member_flag varchar2(1);
   l_resource_list_id number;

   -- Changes for Bug 3910882 Begin
   l_num_of_tasks NUMBER;
   l_db_block_size NUMBER;
   l_num_blocks NUMBER;

   CURSOR C_Get_Default_Res_Asgmt(p_project_id IN NUMBER,
                                  p_budget_version_id IN NUMBER)
   IS
   SELECT resource_assignment_id, wbs_element_version_id
   FROM pa_resource_assignments ra, pa_copy_asgmts_temp cat
   WHERE ra.wbs_element_version_id = cat.src_elem_ver_id
   AND ra.project_id = p_project_id
   AND ra.budget_version_id = p_budget_version_id
   AND ra.ta_display_flag = 'N';

   -- Changes for Bug 3910882 End

--Added by rbanerje - Bug#8646853 -start
   Cursor C_Spread_Curve(p_spread_curve_name IN VARCHAR2) IS
   select a.spread_curve_id spread_curve_id
   from pa_spread_curves_b a,
            pa_spread_curves_tl t
   where t.name = p_spread_curve_name
   and a.spread_curve_id = t.spread_curve_id
   and t.language = userenv('LANG')
   and sysdate BETWEEN a.effective_start_date AND nvl(a.effective_end_date,
sysdate);
   c_spread_curve_rec C_Spread_Curve%ROWTYPE;

   Cursor C_Spread_Curve_Exists(p_spread_curve_id IN NUMBER) IS
   select 'X'
   from pa_spread_curves_b
   where spread_curve_id = p_spread_curve_id
   and sysdate BETWEEN effective_start_date AND nvl(effective_end_date,
sysdate);
   c_spread_curve_exists_rec C_Spread_Curve_Exists%ROWTYPE;

   Cursor C_Spread_Curve_Code(p_spread_curve_id IN NUMBER) IS
   select spread_curve_code
   from pa_spread_curves_b
   where spread_curve_id = p_spread_curve_id
   and sysdate BETWEEN effective_start_date AND nvl(effective_end_date,
sysdate);
   c_spread_curve_code_rec C_Spread_Curve_Code%ROWTYPE;

   Cursor C_Time_Phased_Code(p_budget_version_id IN NUMBER) IS
   select pa_fin_plan_utils.Get_Time_Phased_code(p_budget_version_id)
time_phased_code
   from dual;
   c_time_phased_code_rec C_Time_Phased_Code%ROWTYPE;

   Cursor C_Spread_Curve_Id(p_task_assignment_id IN NUMBER) IS
   select spread_curve_id
   from pa_resource_assignments
   where resource_assignment_id = p_task_assignment_id ;
   c_spread_curve_id_rec C_Spread_Curve_Id%ROWTYPE;

   Cursor C_Res_Asgmt_Id(p_project_id IN NUMBER,p_task_asgmt_reference IN
VARCHAR2,p_task_element_version_id IN NUMBER, p_resource_list_member_id IN
NUMBER) IS
   select resource_assignment_id
   from pa_resource_assignments
   where project_id = p_project_id AND
   pm_res_assignment_reference = p_task_asgmt_reference AND
   wbs_element_version_id = p_task_element_version_id AND
   resource_list_member_id = p_resource_list_member_id;
   c_res_asgmt_id_rec C_Res_Asgmt_Id%ROWTYPE;

   --Bug#8646853 -Addition end
   -- Added below for Bug 8842724
   l_task_assignments_in        ASSIGNMENT_IN_TBL_TYPE := p_task_assignments_in;

BEGIN
L_FuncProc := 'Update_Task_Asgmts';


IF P_DEBUG_MODE = 'Y' AND (li_curr_level <= 3) THEN
pa_debug.g_err_stage:='Entered ' || L_FuncProc;
pa_debug.write(G_PKG_NAME ,pa_debug.g_err_stage,3);
END IF;
--  Standard begin of API savepoint

--dbms_output.put_line('Entered Update Task Asgmts.');

    SAVEPOINT UPDATE_task_asgmts_pub;

--  Standard call to check for call compatibility.

     IF NOT FND_API.Compatible_API_Call ( 1.0, --pa_project_pub.g_api_version_number  ,
                               p_api_version_number  ,
                               l_api_name         ,
                               G_PKG_NAME         )
    THEN

  RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

    END IF;

--  Initialize the message table if requested.

    IF FND_API.TO_BOOLEAN( p_init_msg_list )
    THEN

  FND_MSG_PUB.initialize;

    END IF;

--dbms_output.put_line('Update Task Asgmts.: API Comp. checked.');

--  Set API return status to success

    x_return_status := FND_API.G_RET_STS_SUCCESS;

    --  Initialize the message table if requested.
    --  pm_product_code is mandatory

   --dbms_output.put_line('Initialized message table.');

IF P_DEBUG_MODE = 'Y' AND (li_curr_level <= 3) THEN
 pa_debug.g_err_stage:='Checking p_pm_product_code ' || L_FuncProc;
 pa_debug.write(G_PKG_NAME ,pa_debug.g_err_stage,3);
END IF;

    IF p_pm_product_code IS NOT NULL
    AND p_pm_product_code = PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR   THEN

       IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.G_MSG_LVL_ERROR) THEN
         pa_interface_utils_pub.map_new_amg_msg
           ( p_old_message_code => 'PA_PRODUCT_CODE_IS_MISSING'
            ,p_msg_attribute    => 'CHANGE'
            ,p_resize_flag      => 'N'
            ,p_msg_context      => 'GENERAL'
            ,p_attribute1       => ''
            ,p_attribute2       => ''
            ,p_attribute3       => ''
            ,p_attribute4       => ''
            ,p_attribute5       => '');
       END IF;
       RAISE FND_API.G_EXC_ERROR;

    END IF;

--dbms_output.put_line('Update Task Asgmts.: Product Code checked.');

    l_resp_id := FND_GLOBAL.Resp_id;
    l_user_id := FND_GLOBAL.User_id;

 --dbms_output.put_line('User id :' || l_user_id || 'l_resp_id' || l_resp_id);

IF P_DEBUG_MODE = 'Y' AND (li_curr_level <= 3) THEN
pa_debug.g_err_stage:=' p_pm_product_code check successful.' || L_FuncProc;
pa_debug.write(G_PKG_NAME ,pa_debug.g_err_stage,3);
END IF;



    l_module_name := 'PA_PM_UPDATE_TASK_ASSIGNMENT';


  --


    IF p_pa_project_id is NOT NULL AND p_pa_project_id <> PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM THEN

     l_project_id := p_pa_project_id;

IF P_DEBUG_MODE = 'Y' AND (li_curr_level <= 3) THEN
     pa_debug.g_err_stage:='Project_id successfully passed..Check ' || l_project_id;
     pa_debug.write(G_PKG_NAME ,pa_debug.g_err_stage,3);
END IF;

    ELSE
IF P_DEBUG_MODE = 'Y' AND (li_curr_level <= 3) THEN
        pa_debug.g_err_stage:='Converting Project ref to id:' || p_pm_project_reference;
        pa_debug.write(G_PKG_NAME ,pa_debug.g_err_stage,3);
END IF;
        PA_PROJECT_PVT.Convert_pm_projref_to_id
        (           p_pm_project_reference =>   p_pm_project_reference
                 ,  p_pa_project_id     =>      p_pa_project_id
                 ,  p_out_project_id    =>      l_project_id
                 ,  p_return_status     =>      l_return_status
        );

        IF (l_return_status = FND_API.G_RET_STS_UNEXP_ERROR) THEN

                       --dbms_output.put_line('Project_id not successful ');
IF P_DEBUG_MODE = 'Y' AND (li_curr_level <= 3) THEN
                       pa_debug.g_err_stage:=' Project ref to id check not successful.' || L_FuncProc;
               pa_debug.write(G_PKG_NAME ,pa_debug.g_err_stage,3);
END IF;
                RAISE  FND_API.G_EXC_UNEXPECTED_ERROR;

        ELSIF  (l_return_status = FND_API.G_RET_STS_ERROR) THEN

                       --dbms_output.put_line('Project_id conv. not successful ');
IF P_DEBUG_MODE = 'Y' AND (li_curr_level <= 3) THEN
                       pa_debug.g_err_stage:=' Project ref to id check not successful.' || L_FuncProc;
               pa_debug.write(G_PKG_NAME ,pa_debug.g_err_stage,3);
END IF;
               RAISE  FND_API.G_EXC_ERROR;

                END IF;
        END IF;

         --dbms_output.put_line('Project ref to id check successful for Project ' || l_Project_id);
IF P_DEBUG_MODE = 'Y' AND (li_curr_level <= 3) THEN
        pa_debug.g_err_stage:=' Project ref to id check successful.' || L_FuncProc;
        pa_debug.write(G_PKG_NAME ,pa_debug.g_err_stage,3);
END IF;

    -- As part of enforcing project security, which would determine
    -- whether the user has the necessary privileges to update the project
    -- need to call the pa_security package

    pa_security.initialize (X_user_id        => l_user_id,
                            X_calling_module => l_module_name);

    -- Actions performed using the APIs would be subject to
    -- function security. If the responsibility does not allow
    -- such functions to be executed, the API should not proceed further
    -- since the user does not have access to such functions

    -- Function security procedure check whether user have the
    -- privilege to UPDATE task or not

      PA_INTERFACE_UTILS_PUB.G_PROJECT_ID := l_project_id;  --bug 2471668 ( in the project context )

      PA_PM_FUNCTION_SECURITY_PUB.check_function_security
      (p_api_version_number => p_api_version_number,
       p_responsibility_id  => l_resp_id,
       p_function_name      => 'PA_PM_UPDATE_TASK_ASSIGNMENT',
       p_msg_count      => l_msg_count,
       p_msg_data           => l_msg_data,
       p_return_status      => l_return_status,
       p_function_allowed   => l_function_allowed);

       IF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR
       THEN
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

       ELSIF l_return_status = FND_API.G_RET_STS_ERROR
       THEN
      RAISE FND_API.G_EXC_ERROR;
       END IF;

       IF l_function_allowed = 'N' THEN
         pa_interface_utils_pub.map_new_amg_msg
           ( p_old_message_code => 'PA_FUNCTION_SECURITY_ENFORCED'
            ,p_msg_attribute    => 'CHANGE'
            ,p_resize_flag      => 'Y'
            ,p_msg_context      => 'GENERAL'
            ,p_attribute1       => ''
            ,p_attribute2       => ''
            ,p_attribute3       => ''
            ,p_attribute4       => ''
            ,p_attribute5       => '');
         x_return_status := FND_API.G_RET_STS_ERROR;
         RAISE FND_API.G_EXC_ERROR;
       END IF;

    IF FND_API.TO_BOOLEAN( p_init_msg_list )
    THEN

  FND_MSG_PUB.initialize;

    END IF;


--dbms_output.put_line('Update Task Asgmts.: Function Security checked.');

--  Set API return status to success

    x_return_status := FND_API.G_RET_STS_SUCCESS;


      -- Now verify whether project security allows the user to update
      -- the project
      -- The user does not have query privileges on this project
      -- Hence, cannot update the project.Raise error
          -- If the user has query privileges, then check whether
      -- update privileges are also available

      IF pa_security.allow_query(x_project_id => l_project_id ) = 'N' OR
             pa_security.allow_update(x_project_id => l_project_id ) = 'N' THEN

            -- The user does not have update privileges on this project
            -- Hence , raise error

         pa_interface_utils_pub.map_new_amg_msg
           ( p_old_message_code => 'PA_PROJECT_SECURITY_ENFORCED'
            ,p_msg_attribute    => 'CHANGE'
            ,p_resize_flag      => 'Y'
            ,p_msg_context      => 'GENERAL'
            ,p_attribute1       => ''
            ,p_attribute2       => ''
            ,p_attribute3       => ''
            ,p_attribute4       => ''
            ,p_attribute5       => '');
          x_return_status := FND_API.G_RET_STS_ERROR;
         RAISE FND_API.G_EXC_ERROR;
     END IF;

--dbms_output.put_line('Update Task Asgmts.: Project  Security checked for: ' || l_project_id);

IF P_DEBUG_MODE = 'Y' AND (li_curr_level <= 3) THEN
         pa_debug.g_err_stage:='PA_PROJECT_SECURITY_ENFORCED function check successful.' || L_FuncProc;
     pa_debug.write(G_PKG_NAME ,pa_debug.g_err_stage,3);
END IF;

         --dbms_output.put_line('Project Id:'  || l_project_id);

          IF  NVL(PA_PROJ_TASK_STRUC_PUB.WP_STR_EXISTS( l_project_id ), 'N') = 'N' THEN
        IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.G_MSG_LVL_ERROR)
        THEN
                   --dbms_output.put_line('PA_PROJ_TASK_STRUC_PUB.WP_STR_EXISTS IS N..');
            pa_interface_utils_pub.map_new_amg_msg
              ( p_old_message_code => 'PA_PS_WP_NOT_SEP_FN_AMG'
                  ,p_msg_attribute    => 'CHANGE'
                  ,p_resize_flag      => 'N'
                  ,p_msg_context      => 'GENERAL'
                  ,p_attribute1       => ''
                  ,p_attribute2       => ''
                  ,p_attribute3       => ''
                  ,p_attribute4       => ''
                  ,p_attribute5       => '');
        END IF;
        RAISE FND_API.G_EXC_ERROR;
      END IF;

   --dbms_output.put_line('PA_PROJ_TASK_STRUC_PUB.WP_STR_EXISTS IS Fine..');
IF P_DEBUG_MODE = 'Y' AND (li_curr_level <= 3) THEN
   pa_debug.g_err_stage:='PA_PROJ_TASK_STRUC_PUB.WP_STR_EXISTS function check successful.' || L_FuncProc;
   pa_debug.write(G_PKG_NAME ,pa_debug.g_err_stage,3);
END IF;

                IF  p_pa_structure_version_id IS NOT NULL AND
                    (p_pa_structure_version_id <> PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM) THEN

                 l_struct_elem_version_id := p_pa_structure_version_id;

            ELSE
                     --dbms_output.put_line('Getting current structure version'  );
                     l_struct_elem_version_id := PA_PROJECT_STRUCTURE_UTILS.get_current_working_ver_id(
                                                     p_project_id => l_project_id);


            END IF;

                    --dbms_output.put_line(' structure version: ' || l_struct_elem_version_id );
                        --Project Structures Integration

        IF ( l_struct_elem_version_id = PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM OR
            l_struct_elem_version_id IS NULL  )
       THEN
            IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.G_MSG_LVL_ERROR)
            THEN
               pa_interface_utils_pub.map_new_amg_msg
                    ( p_old_message_code => 'PA_PS_STRUC_VER_REQ'
                     ,p_msg_attribute    => 'CHANGE'
                     ,p_resize_flag      => 'N'
                     ,p_msg_context      => 'GENERAL'
                     ,p_attribute1       => ''
                     ,p_attribute2       => ''
                     ,p_attribute3       => ''
                     ,p_attribute4       => ''
                     ,p_attribute5       => '');
            END IF;
            RAISE FND_API.G_EXC_ERROR;
       END IF;


IF P_DEBUG_MODE = 'Y' AND (li_curr_level <= 3) THEN
       pa_debug.g_err_stage:='Update Task Asgmts.: Structure element version for locking.: '|| l_struct_elem_version_id  ;
       pa_debug.write(G_PKG_NAME ,pa_debug.g_err_stage,3);
END IF;

       -- DHI ER: allowing multiple user to update task assignment
       --         Removed logic to lock version.
       -- pa_task_assignments_pvt.lock_version(l_project_id, l_struct_elem_version_id);

       -- Bug 3940853: Raise locking error return from structure API
       IF FND_MSG_PUB.count_msg > 0 THEN
         x_return_status := FND_API.G_RET_STS_ERROR;
         RAISE FND_API.G_EXC_ERROR;
       END IF;



IF P_DEBUG_MODE = 'Y' AND (li_curr_level <= 3) THEN
       pa_debug.g_err_stage:='Lock version done';
       pa_debug.write(G_PKG_NAME ,pa_debug.g_err_stage,3);
END IF;

          IF 'N' = pa_task_assignment_utils.check_edit_task_ok( P_PROJECT_ID           => l_project_id,
                                                                P_STRUCTURE_VERSION_ID    => l_struct_elem_version_id,
                                                                                                                        P_CURR_STRUCT_VERSION_ID  => l_struct_elem_version_id) THEN
                        -- Bug 4533152
                        --PA_UTILS.ADD_MESSAGE
                        --       (p_app_short_name => 'PA',
                        --        p_msg_name       => 'PA_UPDATE_PUB_VER_ERR'
                        --        );
                        x_return_status := FND_API.G_RET_STS_ERROR;
            RAISE FND_API.G_EXC_ERROR;
       END IF;

IF P_DEBUG_MODE = 'Y' AND (li_curr_level <= 3) THEN
pa_debug.g_err_stage:='Check edit task done';
  pa_debug.write(G_PKG_NAME ,pa_debug.g_err_stage,3);
END IF;
            OPEN C_Get_Budget_Version_Id(l_struct_elem_version_id);
                FETCH C_Get_Budget_Version_Id INTO l_budget_version_id;
                CLOSE C_Get_Budget_Version_Id;

          IF ( l_budget_version_id = PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM OR
            l_budget_version_id IS NULL  ) THEN
            IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.G_MSG_LVL_ERROR)
            THEN
                        PA_UTILS.ADD_MESSAGE
                               (p_app_short_name => 'PA',
                                p_msg_name       => 'PA_FP_PROJ_VERSION_MISMATCH'
                                );
            END IF;
                        x_return_status    := FND_API.G_RET_STS_ERROR;
            RAISE FND_API.G_EXC_ERROR;

       END IF;

IF P_DEBUG_MODE = 'Y' AND (li_curr_level <= 3) THEN
        pa_debug.g_err_stage:=' budget version id: ' || l_budget_version_id ;
        pa_debug.write(G_PKG_NAME ,pa_debug.g_err_stage,3);
END IF;

        l_count := p_task_assignments_in.COUNT;

IF P_DEBUG_MODE = 'Y' AND (li_curr_level <= 3) THEN
        pa_debug.g_err_stage:='Count of input table Checked: for count of : '|| l_count ;
        pa_debug.write(G_PKG_NAME ,pa_debug.g_err_stage,3);
END IF;



      --dbms_output.put_line('Prior to starting Loop to load internal tables..');

 -- Bug 3721630: s) Moved logic to populate l_ta_del_tmp_tbl from c_ta_del
 --   cursor to outside the main loop (loop thru p_task_assignments_in)
 IF p_task_assignments_in IS NOT NULL AND
    p_task_assignments_in.COUNT > 0 AND
    p_task_assignments_in(1).p_context = 'F' THEN

    l_ta_del_tmp_tbl := l_ta_del_empty_tbl;
    int_del_tmp_index  := 0;

    OPEN c_ta_del(l_struct_elem_version_id, l_project_id);
      LOOP
      FETCH c_ta_del INTO c_ta_del_rec;
      EXIT WHEN c_ta_del%NOTFOUND;
          int_del_tmp_index := int_del_tmp_index + 1;
          l_ta_del_tmp_tbl(int_del_tmp_index).pa_task_assignment_id := c_ta_del_rec.resource_assignment_id;
          l_ta_del_tmp_tbl(int_del_tmp_index).pa_task_elem_version_id := c_ta_del_rec.wbs_element_version_id;
          l_ta_del_tmp_tbl(int_del_tmp_index).del_ta_flag := 'Y';
      END LOOP;
    CLOSE c_ta_del;

 END IF;   --IF p_task_assignments_in(i).p_context = 'F' and
 -- End of Bug 3721630 2)


        -- Check if the resource list is None for the workplan
        l_resource_list_id := PA_TASK_ASSIGNMENT_UTILS.Get_WP_Resource_List_Id(l_project_id);

        none_resource_list_flag := 'N';

        OPEN C_Check_Res_List_None(l_resource_list_id);
        FETCH C_Check_Res_List_None INTO none_resource_list_flag;
        CLOSE C_Check_Res_List_None;

        IF none_resource_list_flag = 'Y' THEN
               PA_UTILS.ADD_MESSAGE
               (p_app_short_name => 'PA',
                p_msg_name       => 'PA_RES_LIST_NONE_ERR'
               );
               x_return_status := FND_API.G_RET_STS_ERROR;
               RAISE FND_API.G_EXC_ERROR;
        END IF;
IF P_DEBUG_MODE = 'Y' AND (li_curr_level <= 3) THEN
    pa_debug.g_err_stage:='l_count'|| l_count;
    pa_debug.write(G_PKG_NAME ,pa_debug.g_err_stage,3);
END IF;

--Added by rbanerje-bug#8646853
 IF l_budget_version_id IS NOT NULL THEN
     OPEN C_Time_Phased_Code(l_budget_version_id);
     FETCH C_Time_Phased_Code INTO c_time_phased_code_rec;
     l_time_phased_code := c_time_phased_code_rec.time_phased_code ;
     CLOSE C_Time_Phased_Code;
 END IF;
 --bug#8646853-Addition end

  FOR i in 1..l_count LOOP

IF P_DEBUG_MODE = 'Y' AND (li_curr_level <= 3) THEN
    pa_debug.g_err_stage:='Start of Loading internal Update/Add/Delete Tables i index is:' || i;
    pa_debug.write(G_PKG_NAME ,pa_debug.g_err_stage,3);
END IF;


        IF p_task_assignments_in.exists(i) THEN
IF P_DEBUG_MODE = 'Y' AND (li_curr_level <= 3) THEN
           pa_debug.g_err_stage:='Exists :' || i;
           pa_debug.write(G_PKG_NAME ,pa_debug.g_err_stage,3);
END IF;
                   NULL;
        END IF;
        IF p_task_assignments_in.exists(l_count) THEN
               NUll;
           --dbms_output.put_line('Exists :' || l_count);
       else
               null;
           --dbms_output.put_line('Not Exists :' || l_count);
    END IF;

IF P_DEBUG_MODE = 'Y' AND (li_curr_level <= 3) THEN
    pa_debug.g_err_stage:='task_id' || i|| ':' || p_task_assignments_in(i).pa_task_id;
    pa_debug.write(G_PKG_NAME ,pa_debug.g_err_stage,3);
    pa_debug.g_err_stage:='task_ref' || i || ':' || p_task_assignments_in(i).pm_task_reference;
    pa_debug.write(G_PKG_NAME ,pa_debug.g_err_stage,3);
    pa_debug.g_err_stage:='task_id' || l_count|| ':' || p_task_assignments_in(l_count).pa_task_id;
    pa_debug.write(G_PKG_NAME ,pa_debug.g_err_stage,3);
        pa_debug.g_err_stage:='task_ref' || l_count|| ':' || p_task_assignments_in(l_count).pm_task_reference;
        pa_debug.write(G_PKG_NAME ,pa_debug.g_err_stage,3);

        pa_debug.g_err_stage:='task_asgmt_id' || i|| ':' || p_task_assignments_in(i).pa_task_assignment_id;
        pa_debug.write(G_PKG_NAME ,pa_debug.g_err_stage,3);
        pa_debug.g_err_stage:='task_asgmt_ref' || i || ':' || p_task_assignments_in(i).pm_task_asgmt_reference;
        pa_debug.write(G_PKG_NAME ,pa_debug.g_err_stage,3);
    pa_debug.g_err_stage:='task_asgmt_id' || l_count|| ':' || p_task_assignments_in(l_count).pa_task_assignment_id;
    pa_debug.write(G_PKG_NAME ,pa_debug.g_err_stage,3);
        pa_debug.g_err_stage:='task_asgmt_ref' || l_count|| ':' || p_task_assignments_in(l_count).pm_task_asgmt_reference;
        pa_debug.write(G_PKG_NAME ,pa_debug.g_err_stage,3);
END IF;

        l_d_task_id := NULL;
        l_task_elem_version_id := NULL;

        C_Res_Asgmt_Data_Rec := NULL;

        IF p_task_assignments_in(i).pa_task_assignment_id is not NULL AND
           p_task_assignments_in(i).pa_task_assignment_id <> PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM THEN

          OPEN C_Res_Asgmt_Data(p_task_assignments_in(i).pa_task_assignment_id);
          FETCH C_Res_Asgmt_Data into C_Res_Asgmt_Data_Rec;
          CLOSE C_Res_Asgmt_Data;
          l_d_task_id := C_Res_Asgmt_Data_Rec.task_id;
          l_task_elem_version_id := C_Res_Asgmt_Data_Rec.wbs_element_version_id;

        END IF;


        IF l_task_elem_version_id IS NULL AND p_task_assignments_in.exists(i) AND p_task_assignments_in(i).pa_task_element_version_id IS NOT NULL AND
           p_task_assignments_in(i).pa_task_element_version_id <> PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM THEN

             OPEN C_task_version(p_task_assignments_in(i).pa_task_element_version_id);
                 FETCH C_task_version INTO l_task_elem_version_id, l_d_task_id;
                 CLOSE C_task_version;


        ELSIF l_task_elem_version_id IS NULL AND p_task_assignments_in.exists(i) AND
           p_task_assignments_in(i).pa_task_id IS NOT NULL AND
           p_task_assignments_in(i).pa_task_id <> PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM THEN

          l_d_task_id := p_task_assignments_in(i).pa_task_id;

IF P_DEBUG_MODE = 'Y' AND (li_curr_level <= 3) THEN
          pa_debug.g_err_stage:='l_d_task_id valid input:'|| l_d_task_id;
          pa_debug.write(G_PKG_NAME ,pa_debug.g_err_stage,3);

          pa_debug.g_err_stage:='task_id ' || l_d_task_id;
      pa_debug.write(G_PKG_NAME ,pa_debug.g_err_stage,3);

          pa_debug.g_err_stage:='l_d_task_id'|| l_d_task_id;
          pa_debug.write(G_PKG_NAME ,pa_debug.g_err_stage,3);
END IF;

          IF ( l_d_task_id = PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM OR
                 l_d_task_id IS NULL  )
            THEN
                 IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.G_MSG_LVL_ERROR)
                 THEN
                          PA_UTILS.ADD_MESSAGE
                                    (p_app_short_name => 'PA',
                                     p_msg_name       => 'PA_TASK_REQUIRED'
                                     );
                 END IF;

                 RAISE FND_API.G_EXC_ERROR;
            END IF;



          l_task_elem_version_id := PA_PROJ_ELEMENTS_UTILS.GET_TASK_VERSION_ID(p_structure_version_id => l_struct_elem_version_id
                                          ,p_task_id => l_d_task_id);


        ELSIF l_task_elem_version_id IS NULL AND p_task_assignments_in.exists(i) AND
              p_task_assignments_in(i).pm_task_reference IS NOT NULL AND
              p_task_assignments_in(i).pm_task_reference <> PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR THEN

IF P_DEBUG_MODE = 'Y' AND (li_curr_level <= 3) THEN
         pa_debug.g_err_stage:='l_d_task_reference'|| p_task_assignments_in(i).pm_task_reference;
         pa_debug.write(G_PKG_NAME ,pa_debug.g_err_stage,3);
END IF;



           PA_PROJECT_PVT.CONVERT_PM_TASKREF_TO_ID_all(p_pa_project_id => l_project_id
                                              ,p_pm_task_reference => p_task_assignments_in(i).pm_task_reference
                                              ,p_structure_type => 'WORKPLAN'
                                              ,p_out_task_id => l_d_task_id
                                              ,p_return_status => l_return_status);

IF P_DEBUG_MODE = 'Y' AND (li_curr_level <= 3) THEN
                        pa_debug.g_err_stage:='l_d_task_id'|| l_d_task_id;
                        pa_debug.write(G_PKG_NAME ,pa_debug.g_err_stage,3);
END IF;

           IF ( l_d_task_id = PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM OR
                l_d_task_id IS NULL  )
           THEN
                IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.G_MSG_LVL_ERROR)
                THEN
                          PA_UTILS.ADD_MESSAGE
                                   (p_app_short_name => 'PA',
                                    p_msg_name       => 'PA_TASK_REQUIRED'
                                    );
                END IF;

                RAISE FND_API.G_EXC_ERROR;
            END IF;



                        l_task_elem_version_id := PA_PROJ_ELEMENTS_UTILS.GET_TASK_VERSION_ID(p_structure_version_id => l_struct_elem_version_id
                                          ,p_task_id => l_d_task_id);

        END IF;

     IF l_task_elem_version_id is not NULL AND
          l_task_elem_version_id <> PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM THEN

                   l_task_elem_version_id_tbl.extend(1);

           l_task_elem_version_id_tbl(i):= l_task_elem_version_id;

           ELSE
            IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.G_MSG_LVL_ERROR)
            THEN
                PA_UTILS.ADD_MESSAGE
                               (p_app_short_name => 'PA',
                                p_msg_name       => 'PA_TASK_VERSION_REQUIRED'
                                );

            RAISE FND_API.G_EXC_ERROR;
            END IF;
       END IF;


IF P_DEBUG_MODE = 'Y' AND (li_curr_level <= 3) THEN
  pa_debug.g_err_stage:='l_task_elem_version_id' || l_task_elem_version_id;
  pa_debug.write(G_PKG_NAME ,pa_debug.g_err_stage,3);
END IF;

-- Added below for Bug 8842724
l_task_assignments_in(i).pm_task_asgmt_reference := p_task_assignments_in(i).pm_task_asgmt_reference;

      lp_resource_assignment_id_tbl.extend(1);
  IF p_task_assignments_in(i).pa_task_assignment_id is NOT null AND
     p_task_assignments_in(i).pa_task_assignment_id <> PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM  THEN


IF P_DEBUG_MODE = 'Y' AND (li_curr_level <= 3) THEN
                 pa_debug.g_err_stage:='Accepting Task Assignment Id given:' || p_task_assignments_in(i).pa_task_assignment_id ;
                 pa_debug.write(G_PKG_NAME ,pa_debug.g_err_stage,3);
END IF;
             lp_resource_assignment_id_tbl(i) := p_task_assignments_in(i).pa_task_assignment_id;

  ELSIF p_task_assignments_in(i).pm_task_asgmt_reference is not null AND
        p_task_assignments_in(i).pm_task_asgmt_reference <> PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR THEN

IF P_DEBUG_MODE = 'Y' AND (li_curr_level <= 3) THEN
      pa_debug.g_err_stage:='Converting Task Asgmt Reference:' || p_task_assignments_in(i).pm_task_asgmt_reference ;
      pa_debug.write(G_PKG_NAME ,pa_debug.g_err_stage,3);
      pa_debug.g_err_stage:='p_pa_task_elem_ver_id     => ' || l_task_elem_version_id_tbl(i)  ;
      pa_debug.write(G_PKG_NAME ,pa_debug.g_err_stage,3);
      pa_debug.g_err_stage:='p_pm_task_asgmt_reference => ' || p_task_assignments_in(i).pm_task_asgmt_reference ;
      pa_debug.write(G_PKG_NAME ,pa_debug.g_err_stage,3);
      pa_debug.g_err_stage:='p_pa_task_assignment_id   => ' || p_task_assignments_in(i).pa_task_assignment_id;
      pa_debug.write(G_PKG_NAME ,pa_debug.g_err_stage,3);
      pa_debug.g_err_stage:='p_resource_alias          => ' || p_task_assignments_in(i).resource_alias;
      pa_debug.write(G_PKG_NAME ,pa_debug.g_err_stage,3);
      pa_debug.g_err_stage:='p_resource_list_member_id => ' || p_task_assignments_in(i).resource_list_member_id ;
      pa_debug.write(G_PKG_NAME ,pa_debug.g_err_stage,3);

          pa_debug.g_err_stage:='x_return_status  B4 convert taref to Id => ' || x_return_status;
          pa_debug.write(G_PKG_NAME ,pa_debug.g_err_stage,3);
END IF;

         Convert_PM_TARef_To_ID( p_pm_product_code         => p_pm_product_code
                                                                                                         ,p_pa_project_id           => l_project_id
                                                                                                         ,p_pa_structure_version_id => l_struct_elem_version_id
                                                                                                         ,p_pa_task_id              => l_d_task_id
                                                                                                         ,p_pa_task_elem_ver_id     => l_task_elem_version_id_tbl(i)
                                                                                                         ,p_pm_task_asgmt_reference =>  p_task_assignments_in(i).pm_task_asgmt_reference
                                                                                                         ,p_pa_task_assignment_id   =>  p_task_assignments_in(i).pa_task_assignment_id
                                                                                                         ,p_resource_alias          =>  p_task_assignments_in(i).resource_alias
                                                                                                         ,p_resource_list_member_id =>  p_task_assignments_in(i).resource_list_member_id
                                                                                                         ,p_add_error_msg_flag      =>  'N'  --Bug 3937017
                                                                                                         ,x_pa_task_assignment_id   =>  lp_resource_assignment_id_tbl(i)
                                                                                                         ,x_return_status                   =>  x_return_status
                                                                                                         );
    -- Added below for Bug 8842724
    -- Making the task assignment id as null because for creation the task_assignment_id
    -- is always null. For update the task_assignment_id always exist.
    IF lp_resource_assignment_id_tbl(i) IS NOT NULL OR
       lp_resource_assignment_id_tbl(i) <> FND_API.G_MISS_NUM THEN
       l_task_assignments_in(i).pm_task_asgmt_reference := p_task_assignments_in(i).pm_task_asgmt_reference || to_char(sysdate,':DDMMYYHH24MISS') ;
       lp_resource_assignment_id_tbl(i) := null;
    END IF;
    -- End of Bug 8842724

IF P_DEBUG_MODE = 'Y' AND (li_curr_level <= 3) THEN
          pa_debug.g_err_stage:='x_return_status  after convert taref to Id => ' || x_return_status;
          pa_debug.write(G_PKG_NAME ,pa_debug.g_err_stage,3);
          pa_debug.g_err_stage:='x_pa_task_assignment_id   => ' || lp_resource_assignment_id_tbl(i);
          pa_debug.write(G_PKG_NAME ,pa_debug.g_err_stage,3);
END IF;

   END IF;

 IF p_task_assignments_in(i).p_context <> 'D' THEN  --Validations of Not Delete Context..(Update or Add)

   IF p_task_assignments_in(i).resource_list_member_id IS NOT NULL AND
          p_task_assignments_in(i).resource_list_member_id <> PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM THEN

      C_Res_List_Mem_Check_Rec := NULL;

       OPEN C_Res_List_Mem_Check(p_task_assignments_in(i).resource_list_member_id);
       Fetch C_Res_List_Mem_Check into C_Res_List_Mem_Check_Rec;
       Close C_Res_List_Mem_Check;


       PA_PLANNING_RESOURCE_UTILS.check_list_member_on_list(
                    p_resource_list_id          => l_resource_list_id,
                    p_resource_list_member_id   => p_task_assignments_in(i).resource_list_member_id,
                    p_project_id                => l_project_id,
                    p_chk_enabled               => 'Y',
                                        x_resource_list_member_id   => l_rlm_id,
                    x_valid_member_flag         => l_valid_member_flag,
                    x_return_status             => x_return_status,
                    x_msg_count                 => x_msg_count,
                    x_msg_data                  => x_msg_data ) ;

       IF l_valid_member_flag = 'N' THEN
               x_return_status := FND_API.G_RET_STS_ERROR;
               RAISE FND_API.G_EXC_ERROR;
       END IF;

  ELSIF p_task_assignments_in(i).pa_task_assignment_id IS NULL AND
          p_task_assignments_in(i).p_context <> 'D' AND
      (p_task_assignments_in(i).resource_list_member_id IS  NULL OR
          p_task_assignments_in(i).resource_list_member_id = PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM) THEN
            IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.G_MSG_LVL_ERROR)
            THEN
              IF p_pm_product_code = 'MSPROJECT'
              THEN
                PA_UTILS.ADD_MESSAGE( p_app_short_name => 'PA'
                                     ,p_msg_name       => 'PA_INVALID_RES_LIST_MEM_ID_MSP'
                                     ,p_token1 => 'PLANNING_RESOURCE_NAME'  -- Bug 6497559
                                     ,p_value1 => PA_TASK_UTILS.get_resource_name(p_task_assignments_in(i).resource_list_member_id)
                                    );
                x_return_status := FND_API.G_RET_STS_ERROR;
                RAISE FND_API.G_EXC_ERROR;
              ELSE
                PA_UTILS.ADD_MESSAGE( p_app_short_name => 'PA'
                                     ,p_msg_name       => 'PA_INVALID_RES_LIST_MEM_ID_AMG'
                                     ,p_token1 => 'PLANNING_RESOURCE_ID'  -- Bug 6497559
                                     ,p_value1 => p_task_assignments_in(i).resource_list_member_id
                                    );
                x_return_status := FND_API.G_RET_STS_ERROR;
                RAISE FND_API.G_EXC_ERROR;
              END IF;
             END IF;
        END IF;

IF P_DEBUG_MODE = 'Y' AND (li_curr_level <= 3) THEN
       pa_debug.g_err_stage:='Res List Mem Id check passed:';
       pa_debug.write(G_PKG_NAME ,pa_debug.g_err_stage,3);
END IF;

        IF p_task_assignments_in(i).start_date IS NOT NULL and
           p_task_assignments_in(i).start_date <> PA_INTERFACE_UTILS_PUB.G_PA_MISS_DATE and
           p_task_assignments_in(i).end_date IS NOT NULL and
           p_task_assignments_in(i).end_date <> PA_INTERFACE_UTILS_PUB.G_PA_MISS_DATE and
       p_task_assignments_in(i).start_date > p_task_assignments_in(i).end_date THEN

                IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.G_MSG_LVL_ERROR) THEN
                  IF p_pm_product_code = 'MSPROJECT'
                  THEN
                    PA_UTILS.ADD_MESSAGE( p_app_short_name => 'PA'
                                         ,p_msg_name       => 'PA_INVALID_DATES_MSP'
                                         ,p_token1 => 'TASK_NAME'  -- Bug 6497559
                                         ,p_value1 => PA_TASK_UTILS.get_task_name(p_task_assignments_in(i).pa_task_id)
                                         ,p_token2 => 'TASK_NUMBER'
                                         ,p_value2 => PA_TASK_UTILS.get_task_name(p_task_assignments_in(i).pa_task_id)
                                        );
                    x_return_status := FND_API.G_RET_STS_ERROR;
                    RAISE FND_API.G_EXC_ERROR;
                  ELSE
                    PA_UTILS.ADD_MESSAGE( p_app_short_name => 'PA'
                                         ,p_msg_name       => 'PA_INVALID_DATES_AMG'
                                         ,p_token1 => 'TASK_ID'  -- Bug 6497559
                                         ,p_value1 => p_task_assignments_in(i).pa_task_id
                                        );
                    x_return_status := FND_API.G_RET_STS_ERROR;
                    RAISE FND_API.G_EXC_ERROR;
                  END IF;
             END IF;

        END IF;

        -- Made the pm_task_asgmt_reference to refer to l_task_assignments_in plsql table.
        -- For Bug 8842724
        IF p_task_assignments_in(i).pa_task_assignment_id IS NULL and
                   (l_task_assignments_in(i).pm_task_asgmt_reference IS NULL OR
               l_task_assignments_in(i).pm_task_asgmt_reference =  PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR)   THEN
                    IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.G_MSG_LVL_ERROR)
               THEN
                          PA_UTILS.ADD_MESSAGE
                                  (p_app_short_name => 'PA',
                                   p_msg_name       => 'PA_PM_TASK_ASGMT_REF_REQ'
                                   );
               END IF;
                        x_return_status    := FND_API.G_RET_STS_ERROR;
               RAISE FND_API.G_EXC_ERROR;

        END IF;

IF P_DEBUG_MODE = 'Y' AND (li_curr_level <= 3) THEN
        pa_debug.g_err_stage:='pm_task_asgmt_reference check passed.';
        pa_debug.write(G_PKG_NAME ,pa_debug.g_err_stage,3);
END IF;

          IF p_task_assignments_in(i).use_task_schedule_flag IS NOT NULL AND
           p_task_assignments_in(i).use_task_schedule_flag <> PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR AND
           p_task_assignments_in(i).use_task_schedule_flag  not in ('Y', 'N') THEN
                IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.G_MSG_LVL_ERROR)
            THEN
               pa_interface_utils_pub.map_new_amg_msg
                    ( p_old_message_code => 'PA_TASK_SCHED_FLAG_INVALID'  -->>>>
                     ,p_msg_attribute    => 'CHANGE'
                     ,p_resize_flag      => 'N'
                     ,p_msg_context      => 'GENERAL'
                     ,p_attribute1       => ''
                     ,p_attribute2       => ''
                     ,p_attribute3       => ''
                     ,p_attribute4       => ''
                     ,p_attribute5       => '');
            END IF;
            RAISE FND_API.G_EXC_ERROR;
            x_return_status    := FND_API.G_RET_STS_SUCCESS;

        END IF;


IF P_DEBUG_MODE = 'Y' AND (li_curr_level <= 3) THEN
        pa_debug.g_err_stage:='use_task_schedule_flag  check passed.';
        pa_debug.write(G_PKG_NAME ,pa_debug.g_err_stage,3);
END IF;

        -- 4108372: Should default currency code to default value instead of NULL
        l_currency_code := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR;

   IF p_task_assignments_in(i).currency_code IS NOT NULL AND
         p_task_assignments_in(i).currency_code <> PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR THEN

           OPEN C_currency_exists(p_task_assignments_in(i).currency_code, l_project_id );
           FETCH C_currency_exists INTO C_currency_exists_rec;

           IF C_currency_exists%FOUND THEN
              l_currency_code := p_task_assignments_in(i).currency_code ;
           ELSIF C_currency_exists%NOTFOUND THEN
              IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.G_MSG_LVL_ERROR)
            THEN
               pa_interface_utils_pub.map_new_amg_msg
                    ( p_old_message_code => 'PA_INVALID_CURRENCY'  -->>>>
                     ,p_msg_attribute    => 'CHANGE'
                     ,p_resize_flag      => 'N'
                     ,p_msg_context      => 'GENERAL'
                     ,p_attribute1       => ''
                     ,p_attribute2       => ''
                     ,p_attribute3       => ''
                     ,p_attribute4       => ''
                     ,p_attribute5       => '');
            END IF;
            CLOSE C_currency_exists; --Bug 3937017
            RAISE FND_API.G_EXC_ERROR;
           END IF;
           CLOSE C_currency_exists;

    END IF;


IF P_DEBUG_MODE = 'Y' AND (li_curr_level <= 3) THEN
        pa_debug.g_err_stage:='Currency Check passed.';
        pa_debug.write(G_PKG_NAME ,pa_debug.g_err_stage,3);
END IF;

 END IF; -- IF p_task_assignments_in(i).p_context <> 'D' THEN  --Validations of Not Delete Context..



 IF lp_resource_assignment_id_tbl(i) IS NOT NULL  AND                  --Delete Content
     lp_resource_assignment_id_tbl(i) <> PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM  AND
         p_task_assignments_in(i).p_context = 'D' THEN

          OPEN C_Res_Asgmt_Data(lp_resource_assignment_id_tbl(i));
          FETCH C_Res_Asgmt_Data into C_Res_Asgmt_Data_Rec;
          CLOSE C_Res_Asgmt_Data;

IF P_DEBUG_MODE = 'Y' AND (li_curr_level <= 3) THEN
           pa_debug.g_err_stage:='Entering Delete loading internal tables in Update api. Process';
           pa_debug.write(G_PKG_NAME ,pa_debug.g_err_stage,3);
END IF;
         ld_task_elem_version_id_tbl.extend(1);
     ld_resource_assignment_id_tbl.extend(1);

         del_index := del_index + 1;

         ld_task_elem_version_id_tbl(del_index)   := l_task_elem_version_id_tbl(i);
     ld_resource_assignment_id_tbl(del_index) :=  lp_resource_assignment_id_tbl(i);


 ELSIF lp_resource_assignment_id_tbl(i) IS NOT NULL  AND                 --Update Content
     lp_resource_assignment_id_tbl(i) <> PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM  AND
         p_task_assignments_in(i).p_context <> 'D' THEN

         OPEN C_Res_Asgmt_Data(lp_resource_assignment_id_tbl(i));
          FETCH C_Res_Asgmt_Data into C_Res_Asgmt_Data_Rec;
         CLOSE C_Res_Asgmt_Data;
IF P_DEBUG_MODE = 'Y' AND (li_curr_level <= 3) THEN
          pa_debug.g_err_stage:='Entering Update loading internal tables in Update api. Process';
          pa_debug.write(G_PKG_NAME ,pa_debug.g_err_stage,3);
END IF;

  IF p_task_assignments_in(i).p_context = 'F' THEN

        FOR m in 1..l_ta_del_tmp_tbl.COUNT LOOP

           IF lp_resource_assignment_id_tbl(i) = l_ta_del_tmp_tbl(m).pa_task_assignment_id THEN

              l_ta_del_tmp_tbl(m).del_ta_flag := 'N';

           END IF;

        END LOOP;

   END IF;


        IF p_task_assignments_in(i).billable_work_percent IS NOT NULL AND
           p_task_assignments_in(i).billable_work_percent <> PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM AND
          ( p_task_assignments_in(i).billable_work_percent < 0 OR
           p_task_assignments_in(i).billable_work_percent > 100) THEN
               IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.G_MSG_LVL_ERROR)
               THEN
                 IF p_pm_product_code = 'MSPROJECT'
                 THEN
                   PA_UTILS.ADD_MESSAGE( p_app_short_name => 'PA'
                                        ,p_msg_name       => 'PA_WEIGHTING_NOT_POSITIVE_MSP'
                                        ,p_token1 => 'TASK_NAME'  -- Bug 6497559
                                        ,p_value1 => PA_TASK_UTILS.get_task_name(p_task_assignments_in(i).pa_task_id)
                                        ,p_token2 => 'TASK_NUMBER'
                                        ,p_value2 => PA_TASK_UTILS.get_task_name(p_task_assignments_in(i).pa_task_id)
                                       );

                   x_return_status := FND_API.G_RET_STS_ERROR;
                   RAISE FND_API.G_EXC_ERROR;
                 ELSE
                   PA_UTILS.ADD_MESSAGE( p_app_short_name => 'PA'
                                        ,p_msg_name       => 'PA_WEIGHTING_NOT_POSITIVE_AMG'
                                        ,p_token1 => 'TASK_ID'  -- Bug 6497559
                                        ,p_value1 =>p_task_assignments_in(i).pa_task_id
                                       );

                   x_return_status := FND_API.G_RET_STS_ERROR;
                   RAISE FND_API.G_EXC_ERROR;
                 END If;
          END IF;

        END IF;

IF P_DEBUG_MODE = 'Y' AND (li_curr_level <= 3) THEN
                pa_debug.g_err_stage:='Billable Work Percent check passed.';
                pa_debug.write(G_PKG_NAME ,pa_debug.g_err_stage,3);
END IF;

        l_Cost_Type_exists := NULL;
        l_cost_type_id := NULL;

        IF p_task_assignments_in(i).mfg_cost_type_id IS NOT NULL AND
           p_task_assignments_in(i).mfg_cost_type_id <> PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM THEN

           OPEN C_Cost_Type_Exists(p_task_assignments_in(i).mfg_cost_type_id );
           FETCH C_Cost_Type_Exists INTO C_Cost_Type_Exists_rec;

           IF C_Cost_Type_Exists%FOUND THEN
              l_Cost_Type_id := p_task_assignments_in(i).mfg_cost_type_id ;
           ELSIF C_Cost_Type_Exists%NOTFOUND THEN
              l_Cost_Type_exists := 'N';
            END IF;
           CLOSE C_Cost_Type_Exists;

         ELSIF p_task_assignments_in(i).mfg_cost_type IS NOT NULL AND
               p_task_assignments_in(i).mfg_cost_type <> PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR THEN

           OPEN C_Cost_Type(p_task_assignments_in(i).mfg_cost_type_id );
           FETCH C_Cost_Type INTO C_Cost_Type_rec;

           IF C_Cost_Type%FOUND THEN
              l_Cost_Type_id := p_task_assignments_in(i).mfg_cost_type_id ;
           ELSIF C_Cost_Type%NOTFOUND THEN
              l_Cost_Type_exists := 'N';
            END IF;
           CLOSE C_Cost_Type;

         ELSE
             l_Cost_Type_id := p_task_assignments_in(i).mfg_cost_type_id ;
         END IF;

   IF l_Cost_Type_exists is NOT NULL and l_Cost_Type_exists = 'N' THEN
          IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.G_MSG_LVL_ERROR)
            THEN
               pa_interface_utils_pub.map_new_amg_msg
                    ( p_old_message_code => 'PA_INVALID_COST_TYPE'  -->>>>
                     ,p_msg_attribute    => 'CHANGE'
                     ,p_resize_flag      => 'N'
                     ,p_msg_context      => 'GENERAL'
                     ,p_attribute1       => ''
                     ,p_attribute2       => ''
                     ,p_attribute3       => ''
                     ,p_attribute4       => ''
                     ,p_attribute5       => '');
            END IF;
            RAISE FND_API.G_EXC_ERROR;
   END IF;

IF P_DEBUG_MODE = 'Y' AND (li_curr_level <= 3) THEN
   pa_debug.g_err_stage:='Cost Type check passed.';
   pa_debug.write(G_PKG_NAME ,pa_debug.g_err_stage,3);
END IF;
       	--Added by rbanerje - Bug#8646853 -start
  l_spread_curve_exists := NULL;
  l_spread_curve_id := NULL;
  l_spread_curve_code := NULL;
  l_fixed_date := p_task_assignments_in(i).fixed_date;

  IF ( (l_time_phased_code IS NULL OR (l_time_phased_code <> 'P' AND l_time_phased_code<> 'G'))
         AND ((p_task_assignments_in(i).spread_curve_id IS NOT NULL AND p_task_assignments_in(i).spread_curve_id <> PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM) OR
            (p_task_assignments_in(i).spread_curve_name IS NOT NULL AND p_task_assignments_in(i).spread_curve_name <> PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR ))) THEN
        IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.G_MSG_LVL_ERROR) THEN
               pa_interface_utils_pub.map_new_amg_msg
                    ( p_old_message_code => 'PA_DISABL_WP_NA' -->>>>
                     ,p_msg_attribute    => 'CHANGE'
                     ,p_resize_flag      => 'N'
                     ,p_msg_context      => 'GENERAL'
                     ,p_attribute1       => ''
                     ,p_attribute2       => ''
                     ,p_attribute3       => ''
                     ,p_attribute4       => ''
                     ,p_attribute5       => '');
        END IF;
        RAISE FND_API.G_EXC_ERROR;
    END IF;

  IF p_task_assignments_in(i).spread_curve_id IS NOT NULL AND
p_task_assignments_in(i).spread_curve_id <> PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM
THEN
           OPEN C_Spread_Curve_Exists(p_task_assignments_in(i).spread_curve_id
);
           FETCH C_Spread_Curve_Exists INTO c_spread_curve_exists_rec;
           IF C_Spread_Curve_Exists%FOUND THEN
              l_spread_curve_id := p_task_assignments_in(i).spread_curve_id ;
           ELSE
              l_spread_curve_exists := 'N';
           END IF;
           CLOSE C_Spread_Curve_Exists;

  ELSIF p_task_assignments_in(i).spread_curve_name IS NOT NULL AND
p_task_assignments_in(i). spread_curve_name <>
PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR THEN
           OPEN C_Spread_Curve (p_task_assignments_in(i).spread_curve_name);
           FETCH C_Spread_Curve INTO c_spread_curve_rec;
           IF C_Spread_Curve %FOUND THEN
              l_spread_curve_id := c_spread_curve_rec.spread_curve_id;
           ELSE
              l_spread_curve_exists := 'N';
           END IF;
           CLOSE C_Spread_Curve;

  END IF;

  IF (l_spread_curve_exists is NOT NULL and l_spread_curve_exists = 'N') OR
(p_task_assignments_in(i).spread_curve_id IS NULL) THEN
          IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.G_MSG_LVL_ERROR) THEN
               pa_interface_utils_pub.map_new_amg_msg
                    ( p_old_message_code => 'PA_INVALID_SPREAD_CURVE' -->>>>
                     ,p_msg_attribute    => 'CHANGE'
                     ,p_resize_flag      => 'N'
                     ,p_msg_context      => 'GENERAL'
                     ,p_attribute1       => ''
                     ,p_attribute2       => ''
                     ,p_attribute3       => ''
                     ,p_attribute4       => ''
                     ,p_attribute5       => '');
            END IF;
            RAISE FND_API.G_EXC_ERROR;
   END IF;

    IF l_spread_curve_id is NOT NULL THEN
	   OPEN C_Spread_Curve_Code(l_spread_curve_id);
           FETCH C_Spread_Curve_Code INTO c_spread_curve_code_rec;
           IF C_Spread_Curve_Code%FOUND THEN
              l_spread_curve_code := c_spread_curve_code_rec.spread_curve_code ;
           END IF;
           CLOSE C_Spread_Curve_Code;
   END IF;

   IF l_spread_curve_code is NOT NULL THEN
          IF l_spread_curve_code = 'FIXED_DATE' and (l_fixed_date is null or l_fixed_date = PA_INTERFACE_UTILS_PUB.G_PA_MISS_DATE) THEN
             IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.G_MSG_LVL_ERROR) THEN
              pa_interface_utils_pub.map_new_amg_msg
                    ( p_old_message_code => 'PA_FIXED_DATE_MISSING' -->>>>
                     ,p_msg_attribute    => 'CHANGE'
                     ,p_resize_flag      => 'N'
                     ,p_msg_context      => 'GENERAL'
                     ,p_attribute1       => ''
                     ,p_attribute2       => ''
                     ,p_attribute3       => ''
                     ,p_attribute4       => ''
                     ,p_attribute5       => '');
             END IF;
             RAISE FND_API.G_EXC_ERROR;
            END IF;


       IF l_spread_curve_code <> 'FIXED_DATE' and l_fixed_date <>
PA_INTERFACE_UTILS_PUB.G_PA_MISS_DATE THEN
               pa_interface_utils_pub.map_new_amg_msg
                   ( p_old_message_code => 'PA_APPL_ONLY_FIXED_DATE' -->>>>
                    ,p_msg_attribute    => 'CHANGE'
                     ,p_resize_flag      => 'N'
                     ,p_msg_context      => 'GENERAL'
                     ,p_attribute1       => ''
                     ,p_attribute2       => ''
                     ,p_attribute3       => ''
                     ,p_attribute4       => ''
                     ,p_attribute5       => '');
        END IF;

         IF l_spread_curve_code <> 'FIXED_DATE' THEN
	     l_fixed_date := null;
	 END IF;

   END IF;

   -- Retain existing spread curve if spread curve is not specified
	IF p_task_assignments_in(i).spread_curve_id = PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM AND p_task_assignments_in(i). spread_curve_name = PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR THEN
        -- Made the pm_task_asgmt_reference to refer to l_task_assignments_in plsql table.
        -- For Bug 8842724

	       IF p_task_assignments_in(i).pa_task_assignment_id is NULL OR p_task_assignments_in(i).pa_task_assignment_id = PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM THEN
		  OPEN C_Res_Asgmt_Id(p_pa_project_id,l_task_assignments_in(i).pm_task_asgmt_reference,p_task_assignments_in(i).pa_task_element_version_id,p_task_assignments_in(i).resource_list_member_id);
		  FETCH C_Res_Asgmt_Id INTO c_res_asgmt_id_rec;
		  IF C_Res_Asgmt_Id%FOUND THEN
		     l_task_assignment_id := c_res_asgmt_id_rec.resource_assignment_id;
		  END IF;
		  CLOSE C_Res_Asgmt_Id;
		ELSE
		   l_task_assignment_id := p_task_assignments_in(i).pa_task_assignment_id ;
		END IF;

		OPEN C_Spread_Curve_Id(l_task_assignment_id);
		FETCH C_Spread_Curve_Id INTO c_spread_curve_id_rec ;
		IF C_Spread_Curve_Id%FOUND THEN
			l_spread_curve_id := c_spread_curve_id_rec.spread_curve_id;
		END IF;
		CLOSE C_Spread_Curve_Id ;
	END IF;

IF P_DEBUG_MODE = 'Y' AND (li_curr_level <= 3) THEN
    pa_debug.g_err_stage:='l_spread_curve_id ' || l_spread_curve_id;
    pa_debug.write(G_PKG_NAME ,pa_debug.g_err_stage,3);
END IF;

IF P_DEBUG_MODE = 'Y' AND (li_curr_level <= 3) THEN
    pa_debug.g_err_stage:='l_spread_curve_name ' ||
p_task_assignments_in(i).spread_curve_name;
    pa_debug.write(G_PKG_NAME ,pa_debug.g_err_stage,3);
END IF;

IF P_DEBUG_MODE = 'Y' AND (li_curr_level <= 3) THEN
    pa_debug.g_err_stage:='fixed_date ' || l_fixed_date;
    pa_debug.write(G_PKG_NAME ,pa_debug.g_err_stage,3);
END IF;

IF P_DEBUG_MODE = 'Y' AND (li_curr_level <= 3) THEN
    pa_debug.g_err_stage:='l_time_phased_code ' || l_time_phased_code;
    pa_debug.write(G_PKG_NAME ,pa_debug.g_err_stage,3);
END IF;

--Bug#8646853 -Addition end

                 u_index := u_index + 1;

IF P_DEBUG_MODE = 'Y' AND (li_curr_level <= 3) THEN
        pa_debug.g_err_stage:='u_index:' || u_index;
        pa_debug.write(G_PKG_NAME ,pa_debug.g_err_stage,3);
END IF;

        lu_task_elem_version_id_tbl.extend(1);
        l_resource_assignment_id_tbl.extend(1);
        l_start_date_tbl.extend(1);
        l_end_date_tbl.extend(1);
        l_planning_start_date_tbl.extend(1);
        l_planning_end_date_tbl.extend(1);
        l_resource_list_member_id_tbl.extend(1) ;
        l_project_assignment_id_tbl.extend(1);
        l_quantity_tbl.extend(1);
        l_currency_code_tbl.extend(1);
        l_raw_cost_tbl.extend(1);
        l_burdened_cost_tbl.extend(1);
        l_attribute_category_tbl.extend(1);
        l_attribute1_tbl.extend(1);
        l_attribute2_tbl.extend(1);
        l_attribute3_tbl.extend(1);
        l_attribute4_tbl.extend(1);
        l_attribute5_tbl.extend(1);
        l_attribute6_tbl.extend(1);
        l_attribute7_tbl.extend(1);
        l_attribute8_tbl.extend(1);
        l_attribute9_tbl.extend(1);
        l_attribute10_tbl.extend(1);
        l_attribute11_tbl.extend(1);
        l_attribute12_tbl.extend(1);
        l_attribute13_tbl.extend(1);
        l_attribute14_tbl.extend(1);
        l_attribute15_tbl.extend(1);
        l_attribute16_tbl.extend(1);
        l_attribute17_tbl.extend(1);
        l_attribute18_tbl.extend(1);
        l_attribute19_tbl.extend(1);
        l_attribute20_tbl.extend(1);
        l_attribute21_tbl.extend(1);
        l_attribute22_tbl.extend(1);
        l_attribute23_tbl.extend(1);
        l_attribute24_tbl.extend(1);
        l_attribute25_tbl.extend(1);
        l_attribute26_tbl.extend(1);
        l_attribute27_tbl.extend(1);
        l_attribute28_tbl.extend(1);
        l_attribute29_tbl.extend(1);
        l_attribute30_tbl.extend(1);
        l_description_tbl.extend(1);
        l_use_task_schedule_flag_tbl.extend(1);
        l_raw_cost_rate_override_tbl.extend(1);
        l_burd_cost_rate_override_tbl.extend(1);
        l_billable_work_percent_tbl.extend(1);
        l_mfc_cost_type_id_tbl.extend(1);
        l_task_name_tbl.extend(1);
        l_task_number_tbl.extend(1);
        l_resource_class_code_tbl.extend(1);
    l_resource_alias_tbl.extend(1);
    l_res_type_code_tbl.extend(1);
    l_resource_code_tbl.extend(1);
    l_resource_name.extend(1);
    l_project_role_id_tbl.extend(1);
    l_project_role_name_tbl.extend(1);
    l_supplier_id_tbl.extend(1);
    l_supplier_name_tbl.extend(1);
    l_organization_id_tbl.extend(1);
    l_organization_name_tbl.extend(1);
    l_fc_res_type_code_tbl.extend(1);
    l_financial_category_name_tbl.extend(1);
    l_named_role_tbl.extend(1);

    l_incur_by_resource_code_tbl.extend(1);
    l_scheduled_delay_tbl.extend(1); --Bug 3948128
    l_spread_curve_id_tbl.extend(1); -- Bug#8646853
    l_fixed_date_tbl.extend(1);--Bug#8646853

IF P_DEBUG_MODE = 'Y' AND (li_curr_level <= 3) THEN
    pa_debug.g_err_stage:='Update Tables index is:' || u_index;
    pa_debug.write(G_PKG_NAME ,pa_debug.g_err_stage,3);
END IF;

    p_task_assignments_out(c_index+ u_index).pa_task_id  := l_d_task_id;

        p_task_assignments_out(c_index+ u_index).resource_list_member_id  := p_task_assignments_in(i).resource_list_member_id ;

IF P_DEBUG_MODE = 'Y' AND (li_curr_level <= 3) THEN
        pa_debug.g_err_stage:='Setting global out variables for task and resource list member id';
        pa_debug.write(G_PKG_NAME ,pa_debug.g_err_stage,3);
END IF;

        PA_TASK_ASSIGNMENTS_PUB.g_task_asgmts_out_tbl(c_index + u_index).pa_task_id := l_d_task_id;
        PA_TASK_ASSIGNMENTS_PUB.g_task_asgmts_out_tbl(c_index + u_index).resource_list_member_id := p_task_assignments_in(i).resource_list_member_id ;

IF P_DEBUG_MODE = 'Y' AND (li_curr_level <= 3) THEN
        pa_debug.g_err_stage:='Setting other main variables';
        pa_debug.write(G_PKG_NAME ,pa_debug.g_err_stage,3);
END IF;

        l_start_date_tbl(u_index)                :=  pa_task_assignments_pvt.pfdate(p_task_assignments_in(i).start_date) ;
        l_end_date_tbl(u_index)                  :=  pa_task_assignments_pvt.pfdate(p_task_assignments_in(i).end_date) ;

        l_planning_start_date_tbl(u_index)       :=  pa_task_assignments_pvt.pfdate(C_Res_Asgmt_Data_Rec.planning_start_date) ;
        l_planning_end_date_tbl(u_index)         :=  pa_task_assignments_pvt.pfdate(C_Res_Asgmt_Data_Rec.planning_end_date) ;

        lu_task_elem_version_id_tbl(u_index)     :=  pa_task_assignments_pvt.pfnum(l_task_elem_version_id_tbl(i));

        l_resource_list_member_id_tbl(u_index)   :=  pa_task_assignments_pvt.pfnum(p_task_assignments_in(i).resource_list_member_id) ;
        l_resource_assignment_id_tbl(u_index)    :=  pa_task_assignments_pvt.pfnum(lp_resource_assignment_id_tbl(i));

	----Bug#9374037 Starts
	-- l_project_assignment_id_tbl(u_index)     :=  -1 ;

	l_temp_proj_ass_id :=0;
	Open C_Proj_Ass_Id(p_task_assignments_in(i).pa_task_assignment_id);
	FETCH C_Proj_Ass_Id INTO l_temp_proj_ass_id;
	CLOSE C_Proj_Ass_Id;

	if (l_temp_proj_ass_id <> -1 and l_temp_proj_ass_id <> 0) then
	l_project_assignment_id_tbl(u_index)     :=  l_temp_proj_ass_id ;
	else
	l_project_assignment_id_tbl(u_index)     :=  -1 ;
	end if;
        ----Bug#9374037 Ends


        OPEN C_Workplan_Costs_enabled(l_budget_version_id);
        FETCH C_Workplan_Costs_enabled INTO C_Workplan_Costs_rec;
        CLOSE C_Workplan_Costs_enabled;

        --Rate based override currency only if workplan cost is enabled
        --Non-rate based one can override currency.
        if C_Res_Asgmt_Data_Rec.rate_based_flag = 'Y' AND C_Workplan_Costs_rec.enabled_flag = 'N' THEN
            l_currency_code_tbl(u_index)             := NULL;
        else
        l_currency_code_tbl(u_index)             :=  pa_task_assignments_pvt.pfchar(l_currency_code) ;
    end if;

        IF g_asgmts_periods_tbl_count >  0 THEN

       l_quantity_tbl(u_index)                  :=  NULL ;
           l_raw_cost_tbl(u_index)                  :=  NULL ;
           l_burdened_cost_tbl(u_index)             :=  NULL ;

        ELSE
          IF C_Workplan_Costs_rec.enabled_flag = 'Y' THEN
            l_raw_cost_tbl(u_index)                  :=  pa_task_assignments_pvt.pfnum(p_task_assignments_in(i).planned_total_raw_cost) ;
            l_burdened_cost_tbl(u_index)             :=  pa_task_assignments_pvt.pfnum(p_task_assignments_in(i).planned_total_bur_cost) ;
            /* Bug Fix 5505113
            */
            IF l_raw_cost_tbl(u_index) = FND_API.G_MISS_NUM THEN
               l_raw_cost_tbl(u_index) := NULL;
            END IF;

            IF l_burdened_cost_tbl(u_index) = FND_API.G_MISS_NUM THEN
               l_burdened_cost_tbl(u_index) := NULL;
            END IF;

          END IF;
          l_quantity_tbl(u_index)                  :=  pa_task_assignments_pvt.pfnum(p_task_assignments_in(i).planned_quantity) ;
            /* Bug Fix 5505113
            */
            IF l_quantity_tbl(u_index) = FND_API.G_MISS_NUM THEN
               l_quantity_tbl(u_index) := NULL;
            END IF;

        END IF;

IF P_DEBUG_MODE = 'Y' AND (li_curr_level <= 3) THEN
    pa_debug.g_err_stage:='Setting attributes';
    pa_debug.write(G_PKG_NAME ,pa_debug.g_err_stage,3);
END IF;

    l_attribute_category_tbl(u_index)           :=  pa_task_assignments_pvt.pfchar(p_task_assignments_in(i).attribute_category);
    l_attribute1_tbl(u_index)                   :=  pa_task_assignments_pvt.pfchar(p_task_assignments_in(i).attribute1);
    l_attribute2_tbl(u_index)                   :=  pa_task_assignments_pvt.pfchar(p_task_assignments_in(i).attribute2);
    l_attribute3_tbl(u_index)                   :=  pa_task_assignments_pvt.pfchar(p_task_assignments_in(i).attribute3);
    l_attribute4_tbl(u_index)                   :=  pa_task_assignments_pvt.pfchar(p_task_assignments_in(i).attribute4);
    l_attribute5_tbl(u_index)                   :=  pa_task_assignments_pvt.pfchar(p_task_assignments_in(i).attribute5);
    l_attribute6_tbl(u_index)                   :=  pa_task_assignments_pvt.pfchar(p_task_assignments_in(i).attribute6);
    l_attribute7_tbl(u_index)                   :=  pa_task_assignments_pvt.pfchar(p_task_assignments_in(i).attribute7);
    l_attribute8_tbl(u_index)                   :=  pa_task_assignments_pvt.pfchar(p_task_assignments_in(i).attribute8);
    l_attribute9_tbl(u_index)                   :=  pa_task_assignments_pvt.pfchar(p_task_assignments_in(i).attribute9);
    l_attribute10_tbl(u_index)                  :=  pa_task_assignments_pvt.pfchar(p_task_assignments_in(i).attribute10);
    l_attribute11_tbl(u_index)                  :=  pa_task_assignments_pvt.pfchar(p_task_assignments_in(i).attribute11);
    l_attribute12_tbl(u_index)                  :=  pa_task_assignments_pvt.pfchar(p_task_assignments_in(i).attribute12);
    l_attribute13_tbl(u_index)                  :=  pa_task_assignments_pvt.pfchar(p_task_assignments_in(i).attribute13);
    l_attribute14_tbl(u_index)                  :=  pa_task_assignments_pvt.pfchar(p_task_assignments_in(i).attribute14);
    l_attribute15_tbl(u_index)                  :=  pa_task_assignments_pvt.pfchar(p_task_assignments_in(i).attribute15);
    l_attribute16_tbl(u_index)                  :=  pa_task_assignments_pvt.pfchar(p_task_assignments_in(i).attribute16);
    l_attribute17_tbl(u_index)                  :=  pa_task_assignments_pvt.pfchar(p_task_assignments_in(i).attribute17);
    l_attribute18_tbl(u_index)                  :=  pa_task_assignments_pvt.pfchar(p_task_assignments_in(i).attribute18);
    l_attribute19_tbl(u_index)                  :=  pa_task_assignments_pvt.pfchar(p_task_assignments_in(i).attribute19);
    l_attribute20_tbl(u_index)                  :=  pa_task_assignments_pvt.pfchar(p_task_assignments_in(i).attribute20);
    l_attribute21_tbl(u_index)                  :=  pa_task_assignments_pvt.pfchar(p_task_assignments_in(i).attribute21);
    l_attribute22_tbl(u_index)                  :=  pa_task_assignments_pvt.pfchar(p_task_assignments_in(i).attribute22);
    l_attribute23_tbl(u_index)                  :=  pa_task_assignments_pvt.pfchar(p_task_assignments_in(i).attribute23);
    l_attribute24_tbl(u_index)                  :=  pa_task_assignments_pvt.pfchar(p_task_assignments_in(i).attribute24);
    l_attribute25_tbl(u_index)                  :=  pa_task_assignments_pvt.pfchar(p_task_assignments_in(i).attribute25);
    l_attribute26_tbl(u_index)                  :=  pa_task_assignments_pvt.pfchar(p_task_assignments_in(i).attribute26);
    l_attribute27_tbl(u_index)                  :=  pa_task_assignments_pvt.pfchar(p_task_assignments_in(i).attribute27);
    l_attribute28_tbl(u_index)                  :=  pa_task_assignments_pvt.pfchar(p_task_assignments_in(i).attribute28);
    l_attribute29_tbl(u_index)                  :=  pa_task_assignments_pvt.pfchar(p_task_assignments_in(i).attribute29);
    l_attribute30_tbl(u_index)                  :=  pa_task_assignments_pvt.pfchar(p_task_assignments_in(i).attribute30);
    l_scheduled_delay_tbl(u_index)              :=  pa_task_assignments_pvt.pfnum(p_task_assignments_in(i).scheduled_delay); --Bug 3948128
    l_spread_curve_id_tbl(u_index)              := pa_task_assignments_pvt.pfnum(l_spread_curve_id);--Bug#8646853
    l_fixed_date_tbl(u_index)                       := pa_task_assignments_pvt.pfdate(l_fixed_date) ;--Bug#8646853


IF P_DEBUG_MODE = 'Y' AND (li_curr_level <= 3) THEN
    pa_debug.g_err_stage:='Setting update only parameters:';
    pa_debug.write(G_PKG_NAME ,pa_debug.g_err_stage,3);
END IF;

        l_description_tbl(u_index)                  :=  pa_task_assignments_pvt.pfchar(p_task_assignments_in(i).description);
        l_use_task_schedule_flag_tbl(u_index)       :=  pa_task_assignments_pvt.pfchar(nvl(p_task_assignments_in(i).use_task_schedule_flag, C_Res_Asgmt_Data_Rec.use_task_schedule_flag));

   --dbms_output.put_line('p_task_assignments_in(i).procure_resource_flag:' || p_task_assignments_in(i).procure_resource_flag);
        --dbms_output.put_line('p_task_assignments_in(i).use_task_schedule_flag:' || p_task_assignments_in(i).use_task_schedule_flag);

   -- l_procure_resource_flag_tbl(u_index)        :=  pa_task_assignments_pvt.pfchar(nvl(p_task_assignments_in(i).procure_resource_flag, C_Res_Asgmt_Data_Rec.procure_resource_flag));


        IF g_asgmts_periods_tbl_count >  0 THEN

       l_raw_cost_rate_override_tbl(u_index)                  :=  NULL ;
           l_burd_cost_rate_override_tbl(u_index)                 :=  NULL ;
        ELSE
          if C_Res_Asgmt_Data_Rec.rate_based_flag = 'Y' AND C_Workplan_Costs_rec.enabled_flag = 'Y' THEN
       --dbms_output.put_line('p_task_assignments_in(i).raw_cost_rate_override:' || p_task_assignments_in(i).raw_cost_rate_override);
       l_raw_cost_rate_override_tbl(u_index)       :=  pa_task_assignments_pvt.pfnum(p_task_assignments_in(i).raw_cost_rate_override);

           --dbms_output.put_line('p_task_assignments_in(i).burd_cost_rate_override:' || p_task_assignments_in(i).burd_cost_rate_override);

       l_burd_cost_rate_override_tbl(u_index)      :=  pa_task_assignments_pvt.pfnum(p_task_assignments_in(i).burd_cost_rate_override);
        /* Bug Fix 5505113
        */
       IF l_raw_cost_rate_override_tbl(u_index) = FND_API.G_MISS_NUM THEN
          l_raw_cost_rate_override_tbl(u_index) := NULL;
       END IF;

       IF l_burd_cost_rate_override_tbl(u_index) = FND_API.G_MISS_NUM THEN
          l_burd_cost_rate_override_tbl(u_index) := NULL;
       END IF;

          elsif C_Res_Asgmt_Data_Rec.rate_based_flag = 'N' AND C_Workplan_Costs_rec.enabled_flag = 'Y' THEN
            --dbms_output.put_line('p_task_assignments_in(i).burd_cost_rate_override:' || p_task_assignments_in(i).burd_cost_rate_override);

       l_burd_cost_rate_override_tbl(u_index)      :=  pa_task_assignments_pvt.pfnum(p_task_assignments_in(i).burd_cost_rate_override);
        /* Bug Fix 5505113
        */
       IF l_burd_cost_rate_override_tbl(u_index) = FND_API.G_MISS_NUM THEN
          l_burd_cost_rate_override_tbl(u_index) := NULL;
       END IF;

          end if;
    END IF;

IF P_DEBUG_MODE = 'Y' AND (li_curr_level <= 3) THEN
    pa_debug.g_err_stage:='p_task_assignments_in(i).billable_work_percent' || p_task_assignments_in(i).billable_work_percent;
    pa_debug.write(G_PKG_NAME ,pa_debug.g_err_stage,3);
END IF;

    l_billable_work_percent_tbl(u_index)        :=  pa_task_assignments_pvt.pfnum(p_task_assignments_in(i).billable_work_percent);

IF P_DEBUG_MODE = 'Y' AND (li_curr_level <= 3) THEN
        pa_debug.g_err_stage:='l_cost_type_id' || l_cost_type_id;
        pa_debug.write(G_PKG_NAME ,pa_debug.g_err_stage,3);
END IF;

    l_mfc_cost_type_id_tbl(u_index)             :=  pa_task_assignments_pvt.pfnum(l_cost_type_id);
IF P_DEBUG_MODE = 'Y' AND (li_curr_level <= 3) THEN
        pa_debug.g_err_stage:='End of Setting All Update Params: int. index:' || u_index || ' Overall Index:' || i;
        pa_debug.write(G_PKG_NAME ,pa_debug.g_err_stage,3);

    pa_debug.g_err_stage:='C_Res_Asgmt_Data_Rec.task_id' || C_Res_Asgmt_Data_Rec.task_id;
    pa_debug.write(G_PKG_NAME ,pa_debug.g_err_stage,3);

        pa_debug.g_err_stage:='pa_proj_elements_utils.get_element_name(C_Res_Asgmt_Data_Rec.task_id)' || pa_proj_elements_utils.get_element_name(C_Res_Asgmt_Data_Rec.task_id);
        pa_debug.write(G_PKG_NAME ,pa_debug.g_err_stage,3);
END IF;


        l_task_name_tbl(u_index)                    :=  pa_task_assignments_pvt.pfchar(pa_proj_elements_utils.get_element_name(C_Res_Asgmt_Data_Rec.task_id));

IF P_DEBUG_MODE = 'Y' AND (li_curr_level <= 3) THEN
        pa_debug.g_err_stage:='pa_proj_elements_utils.get_element_number(C_Res_Asgmt_Data_Rec.task_id)' || pa_proj_elements_utils.get_element_number(C_Res_Asgmt_Data_Rec.task_id);
        pa_debug.write(G_PKG_NAME ,pa_debug.g_err_stage,3);
END IF;

        l_task_number_tbl(u_index)                  :=  pa_task_assignments_pvt.pfchar(pa_proj_elements_utils.get_element_number(C_Res_Asgmt_Data_Rec.task_id));

IF P_DEBUG_MODE = 'Y' AND (li_curr_level <= 3) THEN
        pa_debug.g_err_stage:='C_Res_Asgmt_Data_Rec.Resource_Class_Code' || C_Res_Asgmt_Data_Rec.Resource_Class_Code;
        pa_debug.write(G_PKG_NAME ,pa_debug.g_err_stage,3);
END IF;

        l_resource_class_code_tbl(u_index)          :=  pa_task_assignments_pvt.pfchar(C_Res_Asgmt_Data_Rec.Resource_Class_Code);

IF P_DEBUG_MODE = 'Y' AND (li_curr_level <= 3) THEN
        pa_debug.g_err_stage:='C_Res_List_Mem_Check_Rec.Alias' || C_Res_List_Mem_Check_Rec.Alias;
        pa_debug.write(G_PKG_NAME ,pa_debug.g_err_stage,3);
END IF;

    l_resource_alias_tbl(u_index)               :=  pa_task_assignments_pvt.pfchar(C_Res_List_Mem_Check_Rec.Alias);

IF P_DEBUG_MODE = 'Y' AND (li_curr_level <= 3) THEN
        pa_debug.g_err_stage:='C_Res_Asgmt_Data_Rec.res_type_code' || C_Res_Asgmt_Data_Rec.res_type_code;
        pa_debug.write(G_PKG_NAME ,pa_debug.g_err_stage,3);
END IF;

        l_res_type_code_tbl(u_index)                :=  pa_task_assignments_pvt.pfchar(C_Res_Asgmt_Data_Rec.Res_Type_Code);

IF P_DEBUG_MODE = 'Y' AND (li_curr_level <= 3) THEN
        pa_debug.g_err_stage:='C_Res_Asgmt_Data_Rec.resource_assignment_id ' || C_Res_Asgmt_Data_Rec.resource_assignment_id;
        pa_debug.write(G_PKG_NAME ,pa_debug.g_err_stage,3);

        pa_debug.g_err_stage:='PA_PLANNING_RESOURCE_UTILS.Get_resource_Code(C_Res_Asgmt_Data_Rec.resource_assignment_id)' || PA_PLANNING_RESOURCE_UTILS.Get_resource_Code(C_Res_Asgmt_Data_Rec.resource_assignment_id);
        pa_debug.write(G_PKG_NAME ,pa_debug.g_err_stage,3);
END IF;

    l_resource_code_tbl(u_index)                :=  pa_task_assignments_pvt.pfchar(PA_PLANNING_RESOURCE_UTILS.Get_resource_Code(C_Res_Asgmt_Data_Rec.resource_assignment_id));

        l_resource_name(u_index)                    :=  pa_task_assignments_pvt.pfchar(PA_PLANNING_RESOURCE_UTILS.RET_RESOURCE_NAME (
                                                                                  LP_RES_TYPE_CODE,
                                                                                  LP_PERSON_ID,
                                                                                  LP_BOM_RESOURCE_ID, LP_JOB_ID,
                                                                                  LP_PERSON_TYPE_CODE,
                                                                                  LP_NON_LABOR_RESOURCE,
                                                                                  LP_INVENTORY_ITEM_ID,
                                                                                  LP_RESOURCE_CLASS_ID, LP_ITEM_CATEGORY_ID,
                                                                                  C_Res_Asgmt_Data_Rec.resource_assignment_id ));
IF P_DEBUG_MODE = 'Y' AND (li_curr_level <= 3) THEN
        pa_debug.g_err_stage:='resource name: ' || l_resource_name(u_index);
        pa_debug.write(G_PKG_NAME ,pa_debug.g_err_stage,3);

        pa_debug.g_err_stage:='C_Res_Asgmt_Data_Rec.Project_Role_Id: ' || C_Res_Asgmt_Data_Rec.Project_Role_Id;
        pa_debug.write(G_PKG_NAME ,pa_debug.g_err_stage,3);
END IF;

    l_project_role_id_tbl(u_index)              :=  pa_task_assignments_pvt.pfnum(C_Res_Asgmt_Data_Rec.Project_Role_Id);

IF P_DEBUG_MODE = 'Y' AND (li_curr_level <= 3) THEN
        pa_debug.g_err_stage:='pa_planning_element_utils.get_project_role_name(C_Res_Asgmt_Data_Rec.Project_Role_Id): ' || pa_planning_element_utils.get_project_role_name(C_Res_Asgmt_Data_Rec.Project_Role_Id);
        pa_debug.write(G_PKG_NAME ,pa_debug.g_err_stage,3);
END IF;

        l_project_role_name_tbl(u_index)            :=  pa_task_assignments_pvt.pfchar(pa_planning_element_utils.get_project_role_name(C_Res_Asgmt_Data_Rec.Project_Role_Id));

IF P_DEBUG_MODE = 'Y' AND (li_curr_level <= 3) THEN
        pa_debug.g_err_stage:='C_Res_Asgmt_Data_Rec.Organization_Id: ' || C_Res_Asgmt_Data_Rec.Organization_Id;
        pa_debug.write(G_PKG_NAME ,pa_debug.g_err_stage,3);
END IF;

        l_organization_id_tbl(u_index)              :=  pa_task_assignments_pvt.pfnum(C_Res_Asgmt_Data_Rec.Organization_Id);

IF P_DEBUG_MODE = 'Y' AND (li_curr_level <= 3) THEN
        pa_debug.g_err_stage:='pa_expenditures_utils.GetOrgTlName(C_Res_Asgmt_Data_Rec.Organization_Id):' || pa_expenditures_utils.GetOrgTlName(C_Res_Asgmt_Data_Rec.Organization_Id);
        pa_debug.write(G_PKG_NAME ,pa_debug.g_err_stage,3);
END IF;

        l_organization_name_tbl(u_index)            :=  pa_task_assignments_pvt.pfchar(pa_expenditures_utils.GetOrgTlName(C_Res_Asgmt_Data_Rec.Organization_Id));


IF P_DEBUG_MODE = 'Y' AND (li_curr_level <= 3) THEN
        pa_debug.g_err_stage:='C_Res_Asgmt_Data_Rec.fc_res_type_Code:' || C_Res_Asgmt_Data_Rec.fc_res_type_Code;
        pa_debug.write(G_PKG_NAME ,pa_debug.g_err_stage,3);
END IF;

        l_fc_res_type_code_tbl(u_index)             :=  pa_task_assignments_pvt.pfchar(C_Res_Asgmt_Data_Rec.fc_res_type_Code);


        l_financial_category_name_tbl(u_index)      :=  pa_task_assignments_pvt.pfchar(PA_PLANNING_RESOURCE_UTILS.RET_FIN_CATEGORY_NAME (IP_FC_RES_TYPE_CODE, IP_EXPENDITURE_TYPE, IP_EXPENDITURE_CATEGORY,
                                                                                       IP_EVENT_TYPE, IP_REVENUE_CATEGORY_CODE, C_Res_Asgmt_Data_Rec.Resource_Assignment_Id ));

IF P_DEBUG_MODE = 'Y' AND (li_curr_level <= 3) THEN
        pa_debug.g_err_stage:='financial category name :' ||           l_financial_category_name_tbl(u_index);
        pa_debug.write(G_PKG_NAME ,pa_debug.g_err_stage,3);
END IF;

        -- Bug 4246109: Should pass in supplier to update_planning_transaction
        l_supplier_id_tbl(u_index)                  :=  pa_task_assignments_pvt.pfnum(C_Res_Asgmt_Data_Rec.supplier_id);

        -- Bug 4528392:
        IF l_supplier_id_tbl(u_index) IS NOT NULL and l_supplier_id_tbl(u_index) <> FND_API.G_MISS_NUM THEN
          l_supplier_name_tbl(u_index)                :=  pa_task_assignments_pvt.pfchar(pa_planning_resource_utils.ret_supplier_name(l_supplier_id_tbl(u_index)));
        ELSIF l_supplier_id_tbl(u_index) IS NULL THEN
          l_supplier_name_tbl(u_index) := NULL;
        ELSE
          l_supplier_name_tbl(u_index) := FND_API.G_MISS_CHAR;
        END IF;
        -- End of Bug 4528392:

IF P_DEBUG_MODE = 'Y' AND (li_curr_level <= 3) THEN
        pa_debug.g_err_stage:='C_Res_Asgmt_Data_Rec.Named_Role: ' || C_Res_Asgmt_Data_Rec.Named_Role;
        pa_debug.write(G_PKG_NAME ,pa_debug.g_err_stage,3);
END IF;

        l_named_role_tbl(u_index)                   :=  pa_task_assignments_pvt.pfchar(C_Res_Asgmt_Data_Rec.Named_Role);

IF P_DEBUG_MODE = 'Y' AND (li_curr_level <= 3) THEN
        pa_debug.g_err_stage:='PA_PLANNING_RESOURCE_UTILS.GET_INCUR_BY_RES_CODE(  C_Res_Asgmt_Data_Rec.resource_assignment_id) ' || PA_PLANNING_RESOURCE_UTILS.GET_INCUR_BY_RES_CODE(  C_Res_Asgmt_Data_Rec.resource_assignment_id);
        pa_debug.write(G_PKG_NAME ,pa_debug.g_err_stage,3);
END IF;

        l_incur_by_resource_code_tbl(u_index)       := pa_task_assignments_pvt.pfchar(PA_PLANNING_RESOURCE_UTILS.GET_INCUR_BY_RES_CODE(  C_Res_Asgmt_Data_Rec.resource_assignment_id) );


  ELSE              -- Add content.



        -- Bug 4087956
        -- Made the pm_task_asgmt_reference to refer to l_task_assignments_in plsql table.
        -- For Bug 8842724
        OPEN C_Reference_Check(l_task_assignments_in(i).pm_task_asgmt_reference, l_budget_version_id);
        FETCH C_Reference_Check into C_Reference_Rec;
        IF C_Reference_Check%FOUND THEN
IF P_DEBUG_MODE = 'Y' AND (li_curr_level <= 3) THEN
         pa_debug.g_err_stage:='pm_task_asgmt_reference is EXISTING error';
         pa_debug.write(G_PKG_NAME ,pa_debug.g_err_stage,3);
END IF;
              IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.G_MSG_LVL_ERROR)
               THEN
                          --CLOSE C_Reference_Check;Bug 3937017
                          PA_UTILS.ADD_MESSAGE
                                  (p_app_short_name => 'PA'
                                  ,p_msg_name       => 'PA_DUPLICATE_TA_REF'
                                  ,p_token1 => 'TASK_ASGMT_REF'  -- Bug 6497559
                                  ,p_value1 => l_task_assignments_in(i).pm_task_asgmt_reference
                                  ,p_token2 => 'BUDGET_VER_ID'
                                  ,p_value2 => l_budget_version_id
                                   );
               END IF;
               CLOSE C_Reference_Check;--Bug 3937017
                        x_return_status    := FND_API.G_RET_STS_ERROR;
               RAISE FND_API.G_EXC_ERROR;
    END IF;
        Close C_Reference_Check;
IF P_DEBUG_MODE = 'Y' AND (li_curr_level <= 3) THEN
         pa_debug.g_err_stage:='pm_task_asgmt_reference is EXISTING check passed';
         pa_debug.write(G_PKG_NAME ,pa_debug.g_err_stage,3);
END IF;

    c_index := c_index + 1;

IF P_DEBUG_MODE = 'Y' AND (li_curr_level <= 3) THEN
    pa_debug.g_err_stage:='Entering setting of internal tables for Add sequence in Update..';
    pa_debug.write(G_PKG_NAME ,pa_debug.g_err_stage,3);
END IF;

    lc_task_elem_version_id_tbl.extend(1);
        lc_task_name_tbl.extend(1);
        lc_task_number_tbl.extend(1);
    lc_start_date_tbl.extend(1);
        lc_end_date_tbl.extend(1);
        lc_planned_people_effort_tbl.extend(1);
        lc_planned_equip_effort_tbl.extend(1);
        lc_latest_eff_pub_flag_tbl.extend(1);
        lc_resource_list_member_id_tbl.extend(1);
        lc_project_assignment_id_tbl.extend(1);
        lc_quantity_tbl.extend(1);
        lc_currency_code_tbl.extend(1);
        lc_raw_cost_tbl.extend(1);
        lc_burdened_cost_tbl.extend(1);
        lc_product_code_tbl.extend(1);
    lc_product_reference_tbl.extend(1);
        lc_attribute1.extend(1);
        lc_attribute2.extend(1);
        lc_attribute3.extend(1);
        lc_attribute4.extend(1);
        lc_attribute5.extend(1);
        lc_attribute6.extend(1);
        lc_attribute7.extend(1);
        lc_attribute8.extend(1);
        lc_attribute9.extend(1);
        lc_attribute10.extend(1);
        lc_attribute11.extend(1);
        lc_attribute12.extend(1);
        lc_attribute13.extend(1);
        lc_attribute14.extend(1);
        lc_attribute15.extend(1);
        lc_attribute16.extend(1);
        lc_attribute17.extend(1);
        lc_attribute18.extend(1);
        lc_attribute19.extend(1);
        lc_attribute20.extend(1);
        lc_attribute21.extend(1);
        lc_attribute22.extend(1);
        lc_attribute23.extend(1);
        lc_attribute24.extend(1);
        lc_attribute25.extend(1);
        lc_attribute26.extend(1);
        lc_attribute27.extend(1);
        lc_attribute28.extend(1);
        lc_attribute29.extend(1);
        lc_attribute30.extend(1);
        lc_scheduled_delay_tbl.extend(1); --Bug 3948128


    p_task_assignments_out(c_index + u_index).pa_task_id  := l_d_task_id;
        p_task_assignments_out(c_index + u_index).resource_list_member_id  := p_task_assignments_in(i).resource_list_member_id ;

        PA_TASK_ASSIGNMENTS_PUB.g_task_asgmts_out_tbl(c_index + u_index).pa_task_id := l_d_task_id;
        PA_TASK_ASSIGNMENTS_PUB.g_task_asgmts_out_tbl(c_index + u_index).resource_list_member_id := p_task_assignments_in(i).resource_list_member_id ;


        lc_task_elem_version_id_tbl(c_index)      :=  pa_task_assignments_pvt.pfnum(l_task_elem_version_id_tbl(i));
    lc_task_name_tbl(c_index)                 :=  NULL; --TBD
        lc_task_number_tbl(c_index)               :=  NULL; --TBD
    lc_start_date_tbl(c_index)                :=  pa_task_assignments_pvt.pfdate(p_task_assignments_in(i).start_date) ;
        lc_end_date_tbl(c_index)                  :=  pa_task_assignments_pvt.pfdate(p_task_assignments_in(i).end_date) ;
        lc_latest_eff_pub_flag_tbl(c_index)       :=  NULL ;  --TBD
        lc_resource_list_member_id_tbl(c_index)   :=  pa_task_assignments_pvt.pfnum(p_task_assignments_in(i).resource_list_member_id) ;
        lc_project_assignment_id_tbl(c_index)     :=  -1 ;
        lc_currency_code_tbl(c_index)             :=  pa_task_assignments_pvt.pfchar(p_task_assignments_in(i).currency_code) ;

        OPEN C_Workplan_Costs_enabled(l_budget_version_id);
        FETCH C_Workplan_Costs_enabled INTO C_Workplan_Costs_rec;
        CLOSE C_Workplan_Costs_enabled;

        IF g_asgmts_periods_tbl_count >  0 THEN

           lc_quantity_tbl(c_index)                  :=  NULL ;
           lc_raw_cost_tbl(c_index)                  :=  NULL ;
           lc_burdened_cost_tbl(c_index)             :=  NULL ;

        ELSE
          IF C_Workplan_Costs_rec.enabled_flag = 'Y' THEN
           lc_raw_cost_tbl(c_index)                  :=  pa_task_assignments_pvt.pfnum(p_task_assignments_in(i).planned_total_raw_cost) ;
           lc_burdened_cost_tbl(c_index)             :=  pa_task_assignments_pvt.pfnum(p_task_assignments_in(i).planned_total_bur_cost) ;
           /* Bug Fix 5505113
           */
          IF lc_raw_cost_tbl(c_index) = FND_API.G_MISS_NUM THEN
             lc_raw_cost_tbl(c_index) := NULL;
          END IF;

          IF lc_burdened_cost_tbl(c_index)  = FND_API.G_MISS_NUM THEN
             lc_burdened_cost_tbl(c_index)  := NULL;
          END IF;

          END IF;

          lc_quantity_tbl(c_index)                  :=  pa_task_assignments_pvt.pfnum(p_task_assignments_in(i).planned_quantity);
           /* Bug Fix 5505113
           */
          IF lc_quantity_tbl(c_index) = FND_API.G_MISS_NUM THEN
             lc_quantity_tbl(c_index) := NULL;
          END IF;

        END IF;

        -- Made the pm_task_asgmt_reference to refer to l_task_assignments_in plsql table.
        -- For Bug 8842724

        lc_product_code_tbl(c_index)              :=  pa_task_assignments_pvt.pfchar(p_pm_product_code)  ;
    lc_product_reference_tbl(c_index)         :=  pa_task_assignments_pvt.pfchar(l_task_assignments_in(i).pm_task_asgmt_reference) ;
        lc_attribute1(c_index)                    :=  pa_task_assignments_pvt.pfchar(p_task_assignments_in(i).attribute1) ;
        lc_attribute2(c_index)                    :=  pa_task_assignments_pvt.pfchar(p_task_assignments_in(i).attribute2) ;
        lc_attribute3(c_index)                    :=  pa_task_assignments_pvt.pfchar(p_task_assignments_in(i).attribute3) ;
        lc_attribute4(c_index)                    :=  pa_task_assignments_pvt.pfchar(p_task_assignments_in(i).attribute4) ;
        lc_attribute5(c_index)                    :=  pa_task_assignments_pvt.pfchar(p_task_assignments_in(i).attribute5) ;
        lc_attribute6(c_index)                    :=  pa_task_assignments_pvt.pfchar(p_task_assignments_in(i).attribute6) ;
        lc_attribute7(c_index)                    :=  pa_task_assignments_pvt.pfchar(p_task_assignments_in(i).attribute7) ;
        lc_attribute8(c_index)                    :=  pa_task_assignments_pvt.pfchar(p_task_assignments_in(i).attribute8) ;
        lc_attribute9(c_index)                    :=  pa_task_assignments_pvt.pfchar(p_task_assignments_in(i).attribute9) ;
        lc_attribute10(c_index)                   :=  pa_task_assignments_pvt.pfchar(p_task_assignments_in(i).attribute10) ;
        lc_attribute11(c_index)                   :=  pa_task_assignments_pvt.pfchar(p_task_assignments_in(i).attribute11) ;
        lc_attribute12(c_index)                   :=  pa_task_assignments_pvt.pfchar(p_task_assignments_in(i).attribute12) ;
        lc_attribute13(c_index)                   :=  pa_task_assignments_pvt.pfchar(p_task_assignments_in(i).attribute13) ;
        lc_attribute14(c_index)                   :=  pa_task_assignments_pvt.pfchar(p_task_assignments_in(i).attribute14) ;
        lc_attribute15(c_index)                   :=  pa_task_assignments_pvt.pfchar(p_task_assignments_in(i).attribute15) ;
        lc_attribute16(c_index)                   :=  pa_task_assignments_pvt.pfchar(p_task_assignments_in(i).attribute16) ;
        lc_attribute17(c_index)                   :=  pa_task_assignments_pvt.pfchar(p_task_assignments_in(i).attribute17) ;
        lc_attribute18(c_index)                   :=  pa_task_assignments_pvt.pfchar(p_task_assignments_in(i).attribute18) ;
        lc_attribute19(c_index)                   :=  pa_task_assignments_pvt.pfchar(p_task_assignments_in(i).attribute19) ;
        lc_attribute20(c_index)                   :=  pa_task_assignments_pvt.pfchar(p_task_assignments_in(i).attribute20) ;
        lc_attribute21(c_index)                   :=  pa_task_assignments_pvt.pfchar(p_task_assignments_in(i).attribute21) ;
        lc_attribute22(c_index)                   :=  pa_task_assignments_pvt.pfchar(p_task_assignments_in(i).attribute22) ;
        lc_attribute23(c_index)                   :=  pa_task_assignments_pvt.pfchar(p_task_assignments_in(i).attribute23) ;
        lc_attribute24(c_index)                   :=  pa_task_assignments_pvt.pfchar(p_task_assignments_in(i).attribute24) ;
        lc_attribute25(c_index)                   :=  pa_task_assignments_pvt.pfchar(p_task_assignments_in(i).attribute25) ;
        lc_attribute26(c_index)                   :=  pa_task_assignments_pvt.pfchar(p_task_assignments_in(i).attribute26) ;
        lc_attribute27(c_index)                   :=  pa_task_assignments_pvt.pfchar(p_task_assignments_in(i).attribute27) ;
        lc_attribute28(c_index)                   :=  pa_task_assignments_pvt.pfchar(p_task_assignments_in(i).attribute28) ;
        lc_attribute29(c_index)                   :=  pa_task_assignments_pvt.pfchar(p_task_assignments_in(i).attribute29) ;
        lc_attribute30(c_index)                   :=  pa_task_assignments_pvt.pfchar(p_task_assignments_in(i).attribute30) ;
        lc_scheduled_delay_tbl(c_index)           :=  pa_task_assignments_pvt.pfnum(p_task_assignments_in(i).scheduled_delay) ; --Bug 3948128

   END IF;

  END LOOP;

IF P_DEBUG_MODE = 'Y' AND (li_curr_level <= 3) THEN
pa_debug.g_err_stage:='Loop  has ended in setting params.';
pa_debug.write(G_PKG_NAME ,pa_debug.g_err_stage,3);
END IF;

        --Added for Bug 3940284

        /* Updates from the bug
        In both pa_task_assignments_pub create_task_assignments and
        update_task_assignments AMG APIs, we are deleting the ta_display_flag='N'
        assignment records whenever the first resource is assigned to the task
        version.  There are a few problems that need to be fixed:

        1. We currently only delete if the resource being assigned to task is of
        'PEOPLE' class.  This IF should be removed, deletion should be done when
        resource of ANY class is assigned to task.
        2. We should NOT be deleting directly from pa_resource_assignments.  Instead,
        we should call pa_fp_planning_transaction_pub.delete_planning_transactions to
        to properly delete the assignment record.
        */

        --Changes for Bug 3910882 Begin
        /* Updates from the Bug
        The UPDATE does not perform very well in volume env.  My suggestion to improve
        this is to replace the FORALL UPDATE by 2 operations:
        * 1. Insert the task version ids into an existing temp table, PA_COPY_ASGMTS_TEMP
        * 2. Select resource assignments from pa_resource_assignments joining to the temp table
        */

        -- dynamically computing the statistics for the Temporary table
        l_num_of_tasks := l_task_elem_version_id_tbl.COUNT;

        SELECT to_number(value)
        INTO   l_db_block_size
        FROM   v$parameter
        WHERE  name = 'db_block_size';

        l_num_blocks := 1.25 * (l_num_of_tasks * 75) / l_db_block_size;

        -- Manually seed the statistics for the temporary table.
        pa_task_assignment_utils.set_table_stats('PA','PA_COPY_ASGMTS_TEMP',
                                                  l_num_of_tasks, l_num_blocks, 75);

        -- delete content from temp table before inserting
        DELETE pa_copy_asgmts_temp;

        -- bulk inserting the task version ids into the temp table
        FORALL i IN 1..l_task_elem_version_id_tbl.COUNT
            -- Changed due to bug 4153366
            INSERT INTO pa_copy_asgmts_temp VALUES
            (l_task_elem_version_id_tbl(i), -1, null, null, null, null);

IF P_DEBUG_MODE = 'Y' AND (li_curr_level <= 3) THEN
        pa_debug.g_err_stage:='Successfully inserted task version ids into the temp table';
        pa_debug.write(G_PKG_NAME ,pa_debug.g_err_stage,3);
END IF;

        -- select resource_assignment_ids and wbs_element_version_ids by joining to
        -- the temp table for all records having ta_display_flag = 'N'
        OPEN C_Get_Default_Res_Asgmt(l_project_id, l_budget_version_id);
        FETCH C_Get_Default_Res_Asgmt BULK COLLECT INTO
              l_delete_task_res_asgmt_id_tbl, l_delete_task_elem_ver_id_tbl;
        CLOSE C_Get_Default_Res_Asgmt;

IF P_DEBUG_MODE = 'Y' AND (li_curr_level <= 3) THEN
        pa_debug.g_err_stage:='Selected resource_assignment_ids and wbs_element_version_ids into plsql tables';
        pa_debug.write(G_PKG_NAME ,pa_debug.g_err_stage,3);
END IF;

        /*
        FORALL k IN l_task_elem_version_id_tbl.FIRST .. l_task_elem_version_id_tbl.LAST
        UPDATE pa_resource_assignments
        SET ta_display_flag = 'N'
        WHERE ta_display_flag = 'N'
        AND wbs_element_version_id = l_task_elem_version_id_tbl(k)
        AND project_id = l_project_id
        AND budget_version_id = l_budget_version_id
        RETURNING resource_assignment_id, wbs_element_version_id BULK COLLECT INTO
                  l_delete_task_res_asgmt_id_tbl, l_delete_task_elem_ver_id_tbl;
        */

        --Changes for Bug 3910882 End

        IF l_delete_task_res_asgmt_id_tbl.COUNT > 0 THEN
                --dbms_output.put_line('Before calling delete planning transactions:ret. status' || x_return_status);

                -- Bug 4200146: Prevent rollup from happening in PJI plan update call
                --              Turn on the mask.
                IF g_periodic_mode IS NULL THEN
                  PA_TASK_PUB1.G_CALL_PJI_ROLLUP := 'N';
                END IF;

                PA_FP_PLANNING_TRANSACTION_PUB.DELETE_PLANNING_TRANSACTIONS(
                P_CONTEXT => pa_fp_constants_pkg.g_calling_module_task,
                P_TASK_OR_RES => 'ASSIGNMENT',
                P_ELEMENT_VERSION_ID_TBL => l_delete_task_elem_ver_id_tbl,
                P_TASK_NUMBER_TBL => NULL,
                P_TASK_NAME_TBL => NULL,
                P_RESOURCE_ASSIGNMENT_TBL => l_delete_task_res_asgmt_id_tbl,
                P_VALIDATE_DELETE_FLAG => NULL,
                X_RETURN_STATUS => X_RETURN_STATUS,
                X_MSG_COUNT => X_MSG_COUNT,
                X_MSG_DATA => X_MSG_DATA);

                -- Bug 4200146: Prevent rollup from happening in PJI plan update call
                --              Turn off the mask.
                IF g_periodic_mode IS NULL THEN
                  PA_TASK_PUB1.G_CALL_PJI_ROLLUP := null;
                END IF;


        END IF;
                --dbms_output.put_line('After Calling delete planning transactions:ret. status' || x_return_status);
        --End of Changes for Bug 3940284


  IF c_index > 0 THEN

  IF P_DEBUG_MODE = 'Y' AND (li_curr_level <= 3) THEN
     pa_debug.g_err_stage:='Need to call Add Planning Transactions in Update Process count of Add is:' || c_index ;
     pa_debug.write(G_PKG_NAME ,pa_debug.g_err_stage,3);

         pa_debug.g_err_stage:='B4 Call to pa_fp_planning_transactions.add_planning_transactions ret status is:'|| x_return_status;
         pa_debug.write(G_PKG_NAME ,pa_debug.g_err_stage,3);

         For i in 1..c_index LOOP
          pa_debug.g_err_stage:='Index Num. in call to add:' || i ;
          pa_debug.write(G_PKG_NAME ,pa_debug.g_err_stage,3);
          pa_debug.g_err_stage:='p_context' || i ||  ':' ||         pa_fp_constants_pkg.g_calling_module_task;
          pa_debug.write(G_PKG_NAME ,pa_debug.g_err_stage,3);
          pa_debug.g_err_stage:='p_project_id' || i ||  ':' ||  l_project_id;
          pa_debug.write(G_PKG_NAME ,pa_debug.g_err_stage,3);
          pa_debug.g_err_stage:='p_struct_elem_version_id' || i || ':' ||  l_struct_elem_version_id ;
          pa_debug.write(G_PKG_NAME ,pa_debug.g_err_stage,3);
          pa_debug.g_err_stage:='p_budget_version_id' || i || ':' ||  l_budget_version_id;
          pa_debug.write(G_PKG_NAME ,pa_debug.g_err_stage,3);
          pa_debug.g_err_stage:='p_task_elem_version_id_tbl' || i || ':' ||  lc_task_elem_version_id_tbl(i);
          pa_debug.write(G_PKG_NAME ,pa_debug.g_err_stage,3);
          pa_debug.g_err_stage:='p_task_name_tbl' || i ||  ':' || lc_task_name_tbl(i);
          pa_debug.write(G_PKG_NAME ,pa_debug.g_err_stage,3);
          pa_debug.g_err_stage:='p_task_number_tbl' || i || ':' ||  lc_task_number_tbl(i);
          pa_debug.write(G_PKG_NAME ,pa_debug.g_err_stage,3);
          pa_debug.g_err_stage:='p_start_date_tbl' || i || ':' ||  lc_start_date_tbl(i) ;
          pa_debug.write(G_PKG_NAME ,pa_debug.g_err_stage,3);
          pa_debug.g_err_stage:='p_end_date_tbl' || i || ':' ||  lc_end_date_tbl(i);
          pa_debug.write(G_PKG_NAME ,pa_debug.g_err_stage,3);
          pa_debug.g_err_stage:='p_planned_people_effort_tbl' || i ||  ':' || lc_planned_people_effort_tbl(i);
          pa_debug.write(G_PKG_NAME ,pa_debug.g_err_stage,3);
          pa_debug.g_err_stage:='p_planned_equip_effort_tbl' || i ||  ':' || lc_planned_equip_effort_tbl(i);
          pa_debug.write(G_PKG_NAME ,pa_debug.g_err_stage,3);
          pa_debug.g_err_stage:='p_latest_eff_pub_flag_tbl' || i || ':' ||  lc_latest_eff_pub_flag_tbl(i);
          pa_debug.write(G_PKG_NAME ,pa_debug.g_err_stage,3);
          pa_debug.g_err_stage:='p_resource_list_member_id_tbl' || i || ':' ||  lc_resource_list_member_id_tbl(i);
          pa_debug.write(G_PKG_NAME ,pa_debug.g_err_stage,3);
          pa_debug.g_err_stage:='p_project_assignment_id_tbl' || i || ':' ||  lc_project_assignment_id_tbl(i);
          pa_debug.write(G_PKG_NAME ,pa_debug.g_err_stage,3);
          pa_debug.g_err_stage:='p_quantity_tbl' || i || ':' ||  lc_quantity_tbl(i);
          pa_debug.write(G_PKG_NAME ,pa_debug.g_err_stage,3);
          pa_debug.g_err_stage:='p_currency_code_tbl' || i || ':' ||  lc_currency_code_tbl(i);
          pa_debug.write(G_PKG_NAME ,pa_debug.g_err_stage,3);
          pa_debug.g_err_stage:='p_raw_cost_tbl'|| i || ':' ||  lc_raw_cost_tbl(i);
          pa_debug.write(G_PKG_NAME ,pa_debug.g_err_stage,3);
          pa_debug.g_err_stage:='p_burdened_cost_tbl'|| i ||  ':' || lc_burdened_cost_tbl(i);
          pa_debug.write(G_PKG_NAME ,pa_debug.g_err_stage,3);
          pa_debug.g_err_stage:='p_pm_product_code'|| i || ':' ||  lc_product_code_tbl(i);
          pa_debug.write(G_PKG_NAME ,pa_debug.g_err_stage,3);
          pa_debug.g_err_stage:='p_pm_res_asgmt_ref' || i || ':' ||  lc_product_reference_tbl(i);
          pa_debug.write(G_PKG_NAME ,pa_debug.g_err_stage,3);

         END LOOP;

          pa_debug.g_err_stage:='b4 call to pa_fp_planning_transactions.add_planning_transactions ret status:'||x_return_status;
          pa_debug.write(G_PKG_NAME ,pa_debug.g_err_stage,3);
END IF;

         -- Bug 4200146: Prevent rollup from happening in PJI plan update call
         --              Turn on the mask.
         IF g_periodic_mode IS NULL THEN
                  PA_TASK_PUB1.G_CALL_PJI_ROLLUP := 'N';
         END IF;

         pa_fp_planning_transaction_pub.add_planning_transactions
        ( p_context                     => pa_fp_constants_pkg.g_calling_module_task,
          p_one_to_one_mapping_flag     => 'Y',
          p_project_id                  => l_project_id,
          p_struct_elem_version_id      => l_struct_elem_version_id ,
          p_budget_version_id           => l_budget_version_id,
          p_task_elem_version_id_tbl    => lc_task_elem_version_id_tbl,
          p_task_name_tbl               => lc_task_name_tbl,
          p_task_number_tbl             => lc_task_number_tbl,
          p_planning_start_date_tbl              => lc_start_date_tbl,
          p_planning_end_date_tbl                => lc_end_date_tbl,
          p_planned_people_effort_tbl   => lc_planned_people_effort_tbl,
          p_latest_eff_pub_flag_tbl     => lc_latest_eff_pub_flag_tbl,
          p_resource_list_member_id_tbl => lc_resource_list_member_id_tbl,
          p_project_assignment_id_tbl   => lc_project_assignment_id_tbl,
          p_quantity_tbl                => lc_quantity_tbl,
          p_currency_code_tbl           => lc_currency_code_tbl,
          p_raw_cost_tbl                => lc_raw_cost_tbl,
          p_burdened_cost_tbl           => lc_burdened_cost_tbl,
          p_pm_product_code             => lc_product_code_tbl,
          p_pm_res_asgmt_ref            => lc_product_reference_tbl,
          p_attribute1                  => lc_attribute1,           --These are pl/sql system tables too..
          p_attribute2                  => lc_attribute2,
          p_attribute3                  => lc_attribute3,
          p_attribute4                  => lc_attribute4,
          p_attribute5                  => lc_attribute5,
          p_attribute6                  => lc_attribute6,
          p_attribute7                  => lc_attribute7,
          p_attribute8                  => lc_attribute8,
          p_attribute9                  => lc_attribute9,
          p_attribute10                 => lc_attribute10,
          p_attribute11                 => lc_attribute11,
          p_attribute12                 => lc_attribute12,
          p_attribute13                 => lc_attribute13,
          p_attribute14                 => lc_attribute14,
          p_attribute15                 => lc_attribute15,
          p_attribute16                 => lc_attribute16,
          p_attribute17                 => lc_attribute17,
          p_attribute18                 => lc_attribute18,
          p_attribute19                 => lc_attribute19,
          p_attribute20                 => lc_attribute20,
          p_attribute21                 => lc_attribute21,
          p_attribute22                 => lc_attribute22,
          p_attribute23                 => lc_attribute23,
          p_attribute24                 => lc_attribute24,
          p_attribute25                 => lc_attribute25,
          p_attribute26                 => lc_attribute26,
          p_attribute27                 => lc_attribute27,
          p_attribute28                 => lc_attribute28,
          p_attribute29                 => lc_attribute29,
          p_attribute30                 => lc_attribute30,
          p_scheduled_delay             => lc_scheduled_delay_tbl, --Bug 3948128
          x_return_status               => x_return_status,
          x_msg_count                   => x_msg_count,
          x_msg_data                    => x_msg_data
          );

         -- Bug 4200146: Prevent rollup from happening in PJI plan update call
         --              Turn off the mask.
         IF g_periodic_mode IS NULL THEN
                  PA_TASK_PUB1.G_CALL_PJI_ROLLUP := null;
         END IF;

IF P_DEBUG_MODE = 'Y' AND (li_curr_level <= 3) THEN
          pa_debug.g_err_stage:='After Calling add planning transactions:ret. status' || x_return_status;
          pa_debug.write(G_PKG_NAME ,pa_debug.g_err_stage,3);
END IF;

            IF (x_return_status = FND_API.G_RET_STS_UNEXP_ERROR) THEN
                RAISE  FND_API.G_EXC_UNEXPECTED_ERROR;
        ELSIF  (x_return_status = FND_API.G_RET_STS_ERROR) THEN
                RAISE  FND_API.G_EXC_ERROR;
        END IF;

         END IF; -- IF c_index > 0 THEN


   --Collecting delete data
   --Edge case if earlier loop not encountered based on same task/single count
   IF p_task_assignments_in.exists(1) and
      p_task_assignments_in(1).p_context = 'F' and
      l_ta_del_tmp_tbl.exists(1) THEN

     FOR k in 1..l_ta_del_tmp_tbl.COUNT LOOP

       IF  l_ta_del_tmp_tbl(k).del_ta_flag = 'Y' THEN

         ld_task_elem_version_id_tbl.extend(1);
         ld_resource_assignment_id_tbl.extend(1);

         del_index := del_index + 1;

         ld_task_elem_version_id_tbl(del_index)   :=  l_ta_del_tmp_tbl(k).pa_task_elem_version_id;
         ld_resource_assignment_id_tbl(del_index) :=  l_ta_del_tmp_tbl(k).pa_task_assignment_id;


       END IF;
     END LOOP;

   END IF;

   IF del_index > 0 THEN

IF P_DEBUG_MODE = 'Y' AND (li_curr_level <= 3) THEN
         pa_debug.g_err_stage:='Need to call Delete Planning Transactions in Update Process count of Delete is:' || del_index;
         pa_debug.write(G_PKG_NAME ,pa_debug.g_err_stage,3);
         pa_debug.g_err_stage:='Before calling delete planning transactions:ret. status' || x_return_status;
         pa_debug.write(G_PKG_NAME ,pa_debug.g_err_stage,3);
END IF;

         -- Bug 4200146: Prevent rollup from happening in PJI plan update call
         --              Turn on the mask.
         IF g_periodic_mode IS NULL THEN
                  PA_TASK_PUB1.G_CALL_PJI_ROLLUP := 'N';
         END IF;

         PA_FP_PLANNING_TRANSACTION_PUB.DELETE_PLANNING_TRANSACTIONS(
         P_CONTEXT => pa_fp_constants_pkg.g_calling_module_task,
         P_TASK_OR_RES => 'ASSIGNMENT',
         P_ELEMENT_VERSION_ID_TBL => ld_task_elem_version_id_tbl,
         P_TASK_NUMBER_TBL => NULL,
         P_TASK_NAME_TBL => NULL,
         P_RESOURCE_ASSIGNMENT_TBL => ld_resource_assignment_id_tbl,
         P_VALIDATE_DELETE_FLAG => NULL,
         X_RETURN_STATUS => X_RETURN_STATUS,
         X_MSG_COUNT => X_MSG_COUNT,
         X_MSG_DATA => X_MSG_DATA);

         -- Bug 4200146: Prevent rollup from happening in PJI plan update call
         --              Turn off the mask.
         IF g_periodic_mode IS NULL THEN
                  PA_TASK_PUB1.G_CALL_PJI_ROLLUP := null;
         END IF;

IF P_DEBUG_MODE = 'Y' AND (li_curr_level <= 3) THEN
         pa_debug.g_err_stage:='After Calling delete planning transactions:ret. status' || x_return_status;
         pa_debug.write(G_PKG_NAME ,pa_debug.g_err_stage,3);
END IF;

            IF (x_return_status = FND_API.G_RET_STS_UNEXP_ERROR) THEN
                RAISE  FND_API.G_EXC_UNEXPECTED_ERROR;
        ELSIF  (x_return_status = FND_API.G_RET_STS_ERROR) THEN
                RAISE  FND_API.G_EXC_ERROR;
        END IF;
    END IF;




   IF u_index > 0 THEN

IF P_DEBUG_MODE = 'Y' AND (li_curr_level <= 3) THEN
   pa_debug.g_err_stage:='Before Calling Update planning transactions:ret. status' || x_return_status || 'internal upd index:' || u_index;
   pa_debug.write(G_PKG_NAME ,pa_debug.g_err_stage,3);

      pa_debug.g_err_stage:='p_context' ||           pa_fp_constants_pkg.g_calling_module_task;
      pa_debug.write(G_PKG_NAME ,pa_debug.g_err_stage,3);
      pa_debug.g_err_stage:='p_project_id                  ' || l_project_id;
      pa_debug.write(G_PKG_NAME ,pa_debug.g_err_stage,3);
      pa_debug.g_err_stage:='p_struct_elem_version_id      ' || l_struct_elem_version_id ;
      pa_debug.write(G_PKG_NAME ,pa_debug.g_err_stage,3);
      pa_debug.g_err_stage:='p_budget_version_id           ' || l_budget_version_id;
      pa_debug.write(G_PKG_NAME ,pa_debug.g_err_stage,3);


   For i in 1..u_index LOOP

         pa_debug.g_err_stage:='Index Num. in call to add:' || i ;
         pa_debug.write(G_PKG_NAME ,pa_debug.g_err_stage,3);

          pa_debug.g_err_stage:='p_task_elem_version_id_tbl(i)    ' || lu_task_elem_version_id_tbl(i);
          pa_debug.write(G_PKG_NAME ,pa_debug.g_err_stage,3);

          pa_debug.g_err_stage:='p_start_date_tbl(i)               ' || l_start_date_tbl(i) ;
          pa_debug.write(G_PKG_NAME ,pa_debug.g_err_stage,3);
          pa_debug.g_err_stage:='p_end_date_tbl(i)                 ' || l_end_date_tbl(i) ;
          pa_debug.write(G_PKG_NAME ,pa_debug.g_err_stage,3);
           pa_debug.g_err_stage:='l_resource_assignment_id_tbl(i)    ' || l_resource_assignment_id_tbl(i) ;
          pa_debug.write(G_PKG_NAME ,pa_debug.g_err_stage,3);

          pa_debug.g_err_stage:='p_resource_list_member_id_tbl(i)  ' || l_resource_list_member_id_tbl(i) ;
          pa_debug.write(G_PKG_NAME ,pa_debug.g_err_stage,3);
          pa_debug.g_err_stage:='p_project_assignment_id_tbl(i)    ' || l_project_assignment_id_tbl(i) ;
          pa_debug.write(G_PKG_NAME ,pa_debug.g_err_stage,3);
          pa_debug.g_err_stage:='p_quantity_tbl(i)                ' || l_quantity_tbl(i) ;
          pa_debug.write(G_PKG_NAME ,pa_debug.g_err_stage,3);
          pa_debug.g_err_stage:='p_currency_code_tbl(i)           ' || l_currency_code_tbl(i);
          pa_debug.write(G_PKG_NAME ,pa_debug.g_err_stage,3);
          pa_debug.g_err_stage:='p_raw_cost_tbl(i)                ' || l_raw_cost_tbl(i);
          pa_debug.write(G_PKG_NAME ,pa_debug.g_err_stage,3);
          pa_debug.g_err_stage:='p_burdened_cost_tbl(i)           ' || l_burdened_cost_tbl(i);
          pa_debug.write(G_PKG_NAME ,pa_debug.g_err_stage,3);
          pa_debug.g_err_stage:='p_mfc_cost_type_id_id_tbl(i)  ' || l_mfc_cost_type_id_tbl(i) ;
          pa_debug.write(G_PKG_NAME ,pa_debug.g_err_stage,3);
          pa_debug.g_err_stage:='p_use_task_schedule_flag_tbl(i)  ' || l_use_task_schedule_flag_tbl(i) ;
          pa_debug.write(G_PKG_NAME ,pa_debug.g_err_stage,3);
        pa_debug.g_err_stage:='p_raw_cost_rate_override_tbl(i)  ' || l_raw_cost_rate_override_tbl(i) ;
          pa_debug.write(G_PKG_NAME ,pa_debug.g_err_stage,3);
          pa_debug.g_err_stage:='p_burd_cost_rate_override_tbl(i)  ' || l_burd_cost_rate_override_tbl(i) ;
          pa_debug.write(G_PKG_NAME ,pa_debug.g_err_stage,3);
          pa_debug.g_err_stage:='p_billable_work_percent_tbl(i)  ' || l_billable_work_percent_tbl(i) ;
          pa_debug.write(G_PKG_NAME ,pa_debug.g_err_stage,3);
  END LOOP;
END IF;

    -- Bug 4200146: Prevent rollup from happening in PJI plan update call
    --              Turn on the mask.
    IF g_periodic_mode IS NULL THEN
       PA_TASK_PUB1.G_CALL_PJI_ROLLUP := 'N';
    END IF;

    pa_fp_planning_transaction_pub.update_planning_transactions (
        p_context => pa_fp_constants_pkg.g_calling_module_task,
        p_struct_elem_version_id => l_struct_elem_version_id ,
        p_budget_version_id => l_budget_version_id,
        p_task_elem_version_id_tbl => lu_task_elem_version_id_tbl,
        p_schedule_start_date_tbl => l_start_date_tbl,
        p_schedule_end_date_tbl => l_end_date_tbl,
        p_planning_start_date_tbl => l_planning_start_date_tbl,
        p_planning_end_date_tbl => l_planning_end_date_tbl,
        p_resource_assignment_id_tbl => l_resource_assignment_id_tbl,
        p_resource_list_member_id_tbl => l_resource_list_member_id_tbl,
        p_assignment_description_tbl => l_description_tbl,
        p_project_assignment_id_tbl => l_project_assignment_id_tbl,
        p_mfc_cost_type_id_tbl  => l_mfc_cost_type_id_tbl,
        p_use_task_schedule_flag_tbl => l_use_task_schedule_flag_tbl,
        p_quantity_tbl => l_quantity_tbl,
        p_txn_currency_override_tbl => l_currency_code_tbl,
        p_raw_cost_tbl => l_raw_cost_tbl,
        p_burdened_cost_tbl => l_burdened_cost_tbl,
        p_cost_rate_override_tbl => l_raw_cost_rate_override_tbl,
        p_burdened_rate_override_tbl => l_burd_cost_rate_override_tbl,
        p_billable_percent_tbl => l_billable_work_percent_tbl,
        p_task_name_tbl => l_task_name_tbl,
        p_task_number_tbl => l_task_number_tbl,
        p_resource_alias_tbl => l_resource_alias_tbl,
        p_resource_class_code_tbl => l_resource_class_code_tbl,
        p_res_type_code_tbl => l_res_type_code_tbl,
        p_resource_code_tbl => l_resource_code_tbl,
        p_resource_name => l_resource_name,
        p_project_role_id_tbl => l_project_role_id_tbl,
        p_project_role_name_tbl => l_project_role_name_tbl ,
        p_supplier_id_tbl => l_supplier_id_tbl,
        p_supplier_name_tbl => l_supplier_name_tbl,
        p_organization_id_tbl => l_organization_id_tbl,
        p_organization_name_tbl => l_organization_name_tbl,
        p_fc_res_type_code_tbl => l_fc_res_type_code_tbl,
        p_named_role_tbl => l_named_role_tbl,
        p_financial_category_name_tbl => l_financial_category_name_tbl,
        p_incur_by_resource_code_tbl => l_incur_by_resource_code_tbl,
        p_attribute_category_tbl => l_attribute_category_tbl,
        p_attribute1_tbl => l_attribute1_tbl,
        p_attribute2_tbl => l_attribute2_tbl,
        p_attribute3_tbl => l_attribute3_tbl,
        p_attribute4_tbl => l_attribute4_tbl,
        p_attribute5_tbl => l_attribute5_tbl,
        p_attribute6_tbl => l_attribute6_tbl,
        p_attribute7_tbl => l_attribute7_tbl,
        p_attribute8_tbl => l_attribute8_tbl,
        p_attribute9_tbl => l_attribute9_tbl,
        p_attribute10_tbl => l_attribute10_tbl,
        p_attribute11_tbl => l_attribute11_tbl,
        p_attribute12_tbl => l_attribute12_tbl,
        p_attribute13_tbl => l_attribute13_tbl,
        p_attribute14_tbl => l_attribute14_tbl,
        p_attribute15_tbl => l_attribute15_tbl,
        p_attribute16_tbl => l_attribute16_tbl,
        p_attribute17_tbl => l_attribute17_tbl,
        p_attribute18_tbl => l_attribute18_tbl,
        p_attribute19_tbl => l_attribute19_tbl,
        p_attribute20_tbl => l_attribute20_tbl,
        p_attribute21_tbl => l_attribute21_tbl,
        p_attribute22_tbl => l_attribute22_tbl,
        p_attribute23_tbl => l_attribute23_tbl,
        p_attribute24_tbl => l_attribute24_tbl,
        p_attribute25_tbl => l_attribute25_tbl,
        p_attribute26_tbl => l_attribute26_tbl,
        p_attribute27_tbl => l_attribute27_tbl,
        p_attribute28_tbl => l_attribute28_tbl,
        p_attribute29_tbl => l_attribute29_tbl,
        p_attribute30_tbl => l_attribute30_tbl,
        p_scheduled_delay => l_scheduled_delay_tbl, --Bug 3948128
        p_upd_cost_amts_too_for_ta_flg => 'Y', -- Bug 4538286
        p_spread_curve_id_tbl => l_spread_curve_id_tbl, --Bug#8646853
	p_sp_fixed_date_tbl => l_fixed_date_tbl,--Bug#8646853
        x_return_status   => x_return_status,
        x_msg_count       => x_msg_count,
        x_msg_data        => x_msg_data
        );

    -- Bug 4200146: Prevent rollup from happening in PJI plan update call
    --              Turn off the mask.
    IF g_periodic_mode IS NULL THEN
       PA_TASK_PUB1.G_CALL_PJI_ROLLUP := null;
    END IF;

IF P_DEBUG_MODE = 'Y' AND (li_curr_level <= 3) THEN
          pa_debug.g_err_stage:='Return status after update planning transactions.' ||x_return_status;
          pa_debug.write(G_PKG_NAME ,pa_debug.g_err_stage,3);
END IF;

      IF (x_return_status = FND_API.G_RET_STS_UNEXP_ERROR) THEN
                RAISE  FND_API.G_EXC_UNEXPECTED_ERROR;
      ELSIF  (x_return_status = FND_API.G_RET_STS_ERROR) THEN
                RAISE  FND_API.G_EXC_ERROR;
      END IF;
        END IF;



                FOR i in 1..(u_index+c_index) LOOP

IF P_DEBUG_MODE = 'Y' AND (li_curr_level <= 3) THEN
                  pa_debug.g_err_stage:='Obtaining Task Assignment Ids index:' || i;
                  pa_debug.write(G_PKG_NAME ,pa_debug.g_err_stage,3);
END IF;

                  open c_cur_out( l_struct_elem_version_id, l_project_id, l_task_elem_version_id_tbl(i), p_task_assignments_in(i).resource_list_member_id );
                  fetch c_cur_out into c_rec_out;

                  IF c_cur_out%FOUND THEN
IF P_DEBUG_MODE = 'Y' AND (li_curr_level <= 3) THEN
                    pa_debug.g_err_stage:='Success on index:' || i;
                    pa_debug.write(G_PKG_NAME ,pa_debug.g_err_stage,3);
END IF;
                    p_task_assignments_out(i).return_status  := 'S';
                        PA_TASK_ASSIGNMENTS_PUB.g_task_asgmts_out_tbl(i).return_status:= 'S';

                  ELSE
IF P_DEBUG_MODE = 'Y' AND (li_curr_level <= 3) THEN
                    pa_debug.g_err_stage:='Errored on index:' || i;
                    pa_debug.write(G_PKG_NAME ,pa_debug.g_err_stage,3);
END IF;
                    p_task_assignments_out(i).return_status  := 'E';
                        PA_TASK_ASSIGNMENTS_PUB.g_task_asgmts_out_tbl(i).return_status:= 'E';
                  END IF;

IF P_DEBUG_MODE = 'Y' AND (li_curr_level <= 3) THEN
                   pa_debug.g_err_stage:='Out resource_assignment_id:' || c_rec_out.resource_assignment_id;
                   pa_debug.write(G_PKG_NAME ,pa_debug.g_err_stage,3);
                   pa_debug.g_err_stage:='Out resource alias:' || c_rec_out.alias;
                   pa_debug.write(G_PKG_NAME ,pa_debug.g_err_stage,3);
END IF;

                  p_task_assignments_out(i).pa_task_assignment_id  := c_rec_out.resource_assignment_id;
                  p_task_assignments_out(i).resource_alias         := c_rec_out.alias;

                  PA_TASK_ASSIGNMENTS_PUB.g_task_asgmts_out_tbl(i).pa_task_assignment_id := c_rec_out.resource_assignment_id;
                  PA_TASK_ASSIGNMENTS_PUB.g_task_asgmts_out_tbl(i).resource_alias        := c_rec_out.alias;


                  close c_cur_out;

              END LOOP;

         -- Bug 4200146: Call PJI update update
         IF nvl(p_task_assignments_in.COUNT, 0) > 0 AND g_periodic_mode IS NULL THEN
           PJI_FM_XBS_ACCUM_MAINT.PLAN_UPDATE (p_plan_version_id => l_budget_version_id,  -- added for bug 5469303
                                               x_msg_code => l_msg_code,
                                               x_return_status => l_return_status);


           IF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
             RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
           ELSIF l_return_status = FND_API.G_RET_STS_ERROR THEN
             RAISE FND_API.G_EXC_ERROR;
           END IF;

         END IF;

         IF FND_API.to_boolean( p_commit ) THEN
IF P_DEBUG_MODE = 'Y' AND (li_curr_level <= 3) THEN
	    pa_debug.g_err_stage:='COMMIT done in Update Task Assignments';
	    pa_debug.write(G_PKG_NAME ,pa_debug.g_err_stage,3);
END IF;
            COMMIT;
         END IF;
IF P_DEBUG_MODE = 'Y' AND (li_curr_level <= 3) THEN
         pa_debug.g_err_stage:='End of Update_Task_Assignment';
         pa_debug.write(G_PKG_NAME ,pa_debug.g_err_stage,3);
END IF;


EXCEPTION

  WHEN FND_API.G_EXC_ERROR
  THEN
      ROLLBACK TO UPDATE_task_asgmts_pub;


      x_return_status := FND_API.G_RET_STS_ERROR;
IF P_DEBUG_MODE = 'Y' THEN
      PA_DEBUG.write_log (x_module => G_PKG_NAME
                              ,x_msg         => 'Expected Error:' || L_FuncProc || SQLERRM
                              ,x_log_level   => 5);
END IF;

      FND_MSG_PUB.Count_And_Get
          (   p_count    =>  x_msg_count  ,
              p_data    =>  x_msg_data  );

  WHEN FND_API.G_EXC_UNEXPECTED_ERROR
  THEN
      ROLLBACK TO UPDATE_task_asgmts_pub;


      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
IF P_DEBUG_MODE = 'Y' THEN
      PA_DEBUG.write_log (x_module => G_PKG_NAME
                              ,x_msg         => 'Unexpected Error:' || L_FuncProc || SQLERRM
                              ,x_log_level   => 5);
END IF;
      IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
      THEN
        FND_MSG_PUB.add_exc_msg
            ( p_pkg_name    => G_PKG_NAME
            , p_procedure_name  => l_api_name  );

      END IF;
      FND_MSG_PUB.Count_And_Get
          (   p_count    =>  x_msg_count  ,
              p_data    =>  x_msg_data  );

  WHEN OTHERS THEN
      ROLLBACK TO UPDATE_task_asgmts_pub;

      -- Bug 4200146: Reset the mask.
      PA_TASK_PUB1.G_CALL_PJI_ROLLUP := null;

      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
IF P_DEBUG_MODE = 'Y' THEN
      PA_DEBUG.write_log (x_module => G_PKG_NAME
                              ,x_msg         => 'Unexpected Error:' || L_FuncProc || SQLERRM
                              ,x_log_level   => 5);
END IF;
      IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
      THEN
        FND_MSG_PUB.add_exc_msg
            ( p_pkg_name    => G_PKG_NAME
            , p_procedure_name  => l_api_name  );

      END IF;

      FND_MSG_PUB.Count_And_Get
          (   p_count    =>  x_msg_count  ,
              p_data    =>  x_msg_data  );

END UPDATE_TASK_ASSIGNMENTS;





PROCEDURE Fetch_Task_Assignments
( p_api_version_number      IN    NUMBER           := PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM
 ,p_init_msg_list                   IN    VARCHAR2         := FND_API.G_FALSE
 ,p_task_asgmt_index        IN    pa_num_1000_num  := pa_num_1000_num(PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM)
 ,p_pm_task_asgmt_reference     OUT       NOCOPY pa_vc_1000_30
 ,p_pa_task_assignment_id       OUT       NOCOPY pa_num_1000_num
 ,p_pm_task_reference       OUT   NOCOPY pa_vc_1000_30
 ,p_pa_task_id              OUT   NOCOPY pa_num_1000_num
 ,p_resource_alias          OUT   NOCOPY pa_vc_1000_80
 ,p_resource_list_member_id OUT   NOCOPY pa_num_1000_num
 ,x_return_status                   OUT   NOCOPY VARCHAR2
) IS
   l_api_name      CONSTANT  VARCHAR2(30)     := 'fetch_task_assignments';
   l_index          NUMBER;
   i            NUMBER;

L_FuncProc varchar2(2000);

BEGIN
           L_FuncProc := 'Fetch_Task_Asgmts';

IF P_DEBUG_MODE = 'Y' AND (li_curr_level <= 3) THEN
           pa_debug.g_err_stage:='Entered ' || L_FuncProc;
           pa_debug.write(G_PKG_NAME ,pa_debug.g_err_stage,3);
END IF;

           --dbms_output.put_line('Entering Fetch Task Assignments');

           p_pm_task_asgmt_reference    := pa_vc_1000_30();
           p_pa_task_assignment_id        := pa_num_1000_num();
           p_pm_task_reference       :=  pa_vc_1000_30();
           p_pa_task_id              := pa_num_1000_num();
           p_resource_alias           := pa_vc_1000_80();
           p_resource_list_member_id  := pa_num_1000_num();

           p_pm_task_asgmt_reference.extend(p_task_asgmt_index.COUNT);
           p_pa_task_assignment_id.extend(p_task_asgmt_index.COUNT);
           p_pm_task_reference.extend(p_task_asgmt_index.COUNT);
           p_pa_task_id.extend(p_task_asgmt_index.COUNT);
           p_resource_alias.extend(p_task_asgmt_index.COUNT);
           p_resource_list_member_id.extend(p_task_asgmt_index.COUNT);

           --dbms_output.put_line('After initializing out parameters');

        --  Standard begin of API savepoint

            SAVEPOINT fetch_task_assignments_pub;

        --  Standard call to check for call compatibility.

            IF NOT FND_API.Compatible_API_Call ( 1.0, --g_api_version_number  ,
                                       p_api_version_number  ,
                                       l_api_name         ,
                                       G_PKG_NAME         )
            THEN

                 RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

            END IF;

        --  Initialize the message table if requested.

            IF FND_API.TO_BOOLEAN( p_init_msg_list )
            THEN
                FND_MSG_PUB.initialize;
            END IF;

        --  Set API return status to success

         x_return_status := FND_API.G_RET_STS_SUCCESS;

        --  Check Task index value, when they don't provide an index we will error out
FOR i in 1..p_task_asgmt_index.COUNT LOOP

         --dbms_output.put_line('Entering Fetch Loop: p_task_asgmt_index.COUNT' || p_task_asgmt_index.COUNT);

            IF p_task_asgmt_index(i) = PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM
            OR p_task_asgmt_index(i) IS NULL THEN

                         --dbms_output.put_line('Asgmt index is not passed.');

                                RETURN;

                              IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.G_MSG_LVL_ERROR) THEN
                                         pa_interface_utils_pub.map_new_amg_msg
                                           ( p_old_message_code => 'PA_INDEX_NOT_PROVIDED'
                                            ,p_msg_attribute    => 'CHANGE'
                                            ,p_resize_flag      => 'N'
                                            ,p_msg_context      => 'GENERAL'
                                            ,p_attribute1       => ''
                                            ,p_attribute2       => ''
                                            ,p_attribute3       => ''
                                            ,p_attribute4       => ''
                                            ,p_attribute5       => '');
                               END IF;

                        x_return_status := FND_API.G_RET_STS_ERROR;
                        RAISE FND_API.G_EXC_ERROR;

            END IF;

          IF g_task_asgmts_out_tbl.exists(p_task_asgmt_index(i)) AND
             g_task_asgmts_out_tbl(p_task_asgmt_index(i)).return_status  = 'S' THEN

                         --dbms_output.put_line('out table exists.');

                        --  assign global table fields to the outgoing parameter
                        --  we don't want to return the big number G_PA_MISS_NUM

                         IF g_task_asgmts_out_tbl(p_task_asgmt_index(i)).pa_task_assignment_id = PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM OR
                           g_task_asgmts_out_tbl(p_task_asgmt_index(i)).pa_task_assignment_id = NULL
                         THEN

                                p_pa_task_assignment_id(i)   := NULL;

                        ELSE
                                 --dbms_output.put_line('setting task assignment id for index ' || p_task_asgmt_index(i));
                                 p_pa_task_assignment_id(i)   := NULL;
                                --dbms_output.put_line('setting task assignment id for index res id' || g_task_asgmts_out_tbl(p_task_asgmt_index(i)).pa_task_assignment_id);
                                p_pa_task_assignment_id(i)        := g_task_asgmts_out_tbl(p_task_asgmt_index(i)).pa_task_assignment_id;
                                 --dbms_output.put_line('after set');

                         END IF;

                        IF g_task_asgmts_out_tbl(p_task_asgmt_index(i)).pa_task_id = PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM OR
                           g_task_asgmts_out_tbl(p_task_asgmt_index(i)).pa_task_id  = NULL
                        THEN
                                --dbms_output.put_line('task id is null');
                                  p_pa_task_id(i)                   := NULL;

                          ELSE
                                --dbms_output.put_line('task id is not null');
                                  p_pa_task_id(i)                   := g_task_asgmts_out_tbl(p_task_asgmt_index(i)).pa_task_id;
                                 --dbms_output.put_line('task id is set');
                        END IF;

                        IF g_task_asgmts_out_tbl(p_task_asgmt_index(i)).resource_alias = PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR OR
                           g_task_asgmts_out_tbl(p_task_asgmt_index(i)).resource_alias = NULL
                        THEN
                                  --dbms_output.put_line('null  resource alias');
                                 p_resource_alias(i)          := NULL;
                                   --dbms_output.put_line('after null  resource alias');
                          ELSE
                                   --dbms_output.put_line('setting resource alias');
                                        p_resource_alias(i)               := g_task_asgmts_out_tbl(p_task_asgmt_index(i)).resource_alias;
                                         --dbms_output.put_line('after setting resource alias');
                         END IF;

                        IF g_task_asgmts_out_tbl(p_task_asgmt_index(i)).resource_list_member_id = PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM OR
                           g_task_asgmts_out_tbl(p_task_asgmt_index(i)).resource_list_member_id = NULL
                        THEN
                                 --dbms_output.put_line('null resource list member id');
                                 p_resource_list_member_id(i) := NULL;
                                 --dbms_output.put_line('after null resource list member id');
                         ELSE
                                  --dbms_output.put_line('setting resource list member id');
                                 p_resource_list_member_id(i)      := g_task_asgmts_out_tbl(p_task_asgmt_index(i)).resource_list_member_id;
                                --dbms_output.put_line('after setting resource list member id');
                        END IF;


            END IF;
  --dbms_output.put_line('out table end of loop');
 --dbms_output.put_line('out table end of fetch task assignments.');

END LOOP;

EXCEPTION

  WHEN FND_API.G_EXC_ERROR
  THEN
     ROLLBACK TO fetch_task_assignments_pub;

     x_return_status := FND_API.G_RET_STS_ERROR;
IF P_DEBUG_MODE = 'Y' THEN
     PA_DEBUG.write_log (x_module => G_PKG_NAME
                             ,x_msg         => 'Expected Error:' || L_FuncProc || SQLERRM
                             ,x_log_level   => 5);
END IF;

  WHEN FND_API.G_EXC_UNEXPECTED_ERROR
  THEN
     ROLLBACK TO fetch_task_assignments_pub;

     x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
IF P_DEBUG_MODE = 'Y' THEN
     PA_DEBUG.write_log (x_module => G_PKG_NAME
                             ,x_msg         => 'Unexpected Error:' || L_FuncProc || SQLERRM
                             ,x_log_level   => 5);
END IF;


  WHEN OTHERS THEN
     ROLLBACK TO fetch_task_assignments_pub;

     x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
IF P_DEBUG_MODE = 'Y' THEN
     PA_DEBUG.write_log (x_module => G_PKG_NAME
                             ,x_msg         => 'Unexpected Error:' || L_FuncProc || SQLERRM
                             ,x_log_level   => 5);
END IF;



END;



PROCEDURE Init_Task_Assignments IS
BEGIN
         -->>  Empty global tables , count
                 g_task_asgmts_in_tbl     := empty_task_asgmts_in_tbl;
             g_task_asgmts_out_tbl    := empty_task_asgmts_out_tbl;
                 g_task_asgmts_tbl_count  := 0;
             g_asgmts_periods_tbl     := empty_asgmts_periods_tbl;
                 g_asgmts_periods_out_tbl := empty_task_asgmts_out_tbl;
             g_asgmts_periods_tbl_count := 0;
END;


PROCEDURE Convert_PM_TARef_To_ID
( p_pm_product_code           IN VARCHAR2
 ,p_pa_project_id             IN NUMBER
 ,p_pa_structure_version_id   IN NUMBER
 ,p_pa_task_id                IN NUMBER
 ,p_pa_task_elem_ver_id       IN NUMBER
 ,p_pm_task_asgmt_reference   IN VARCHAR2     := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
 ,p_pa_task_assignment_id     IN NUMBER       := PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM
 ,p_resource_alias            IN VARCHAR2     := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
 ,p_resource_list_member_id   IN NUMBER       := PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM
 -- Bug 3937017 Added a new parameter p_add_error_msg_flag
 ,p_add_error_msg_flag        IN VARCHAR2     DEFAULT 'Y'
 -- Bug 3872176 Added a new parameter p_published_version_flag
 ,p_published_version_flag     IN VARCHAR2     DEFAULT 'N'
 ,x_pa_task_assignment_id     OUT  NOCOPY NUMBER
 ,x_return_status             OUT  NOCOPY VARCHAR2
) IS
L_FuncProc varchar2(250) ;

-- Bug 3872176 select more related project information
CURSOR  l_project_id_csr
IS
SELECT  'X', template_flag, PA_WORKPLAN_ATTR_UTILS.CHECK_WP_VERSIONING_ENABLED(project_id)
FROM    pa_projects_all
where   project_id = p_pa_project_id;

-- 3860640 Added parameter to the cursor
-- and using it in the where condition instead of input parameter
-- p_pa_structure_version_id which may be null if it is called from
-- ASSOCIATE_DLV_TO_TASK_ASSIGN api

CURSOR  l_task_asgmt_id_csr(l_struct_ver_id NUMBER)
IS
SELECT  'X'
FROM    pa_resource_assignments a, pa_budget_versions b
WHERE   a.resource_assignment_id = p_pa_task_assignment_id
AND     a.project_id = p_pa_project_id
AND     b.budget_version_id = a.budget_version_id
AND     b.project_structure_version_id = l_struct_ver_id;


CURSOR c_task_asgmt_csr(p_struct_version_id IN NUMBER) IS
SELECT a.resource_assignment_id
FROM    pa_resource_assignments a, pa_budget_versions b
WHERE   a.project_id                   = p_pa_project_id
AND     b.budget_version_id            = a.budget_version_id
AND     b.project_structure_version_id = p_struct_version_id
AND     a.pm_res_assignment_reference  = p_pm_task_asgmt_reference
AND     a.pm_product_code = p_pm_product_code;

CURSOR c_task_asgmt_from_id_csr(p_struct_version_id IN NUMBER) IS
SELECT a.resource_assignment_id
FROM    pa_resource_assignments a, pa_budget_versions b
WHERE   a.project_id                   = p_pa_project_id
AND     b.budget_version_id            = a.budget_version_id
AND     b.project_structure_version_id = p_struct_version_id
AND     a.wbs_element_version_id = p_pa_task_elem_ver_id
AND     a.resource_list_member_id = p_resource_list_member_id;


l_api_name  CONSTANT    VARCHAR2(30) := 'Convert_pm_taref_to_id';
l_task_ver_id               NUMBER ;
l_task_asgmt_id         NUMBER ;
l_struct_elem_version_id NUMBER;
l_dummy                 VARCHAR2(1);
l_template_flag         VARCHAR2(1);
l_version_enabled_flag  VARCHAR2(1);

--needed to get the field values associated to a AMG message

   CURSOR   l_amg_project_csr
      (p_pa_project_id pa_projects_all.project_id%type)
   IS
   SELECT   segment1
   FROM     pa_projects_all p
   WHERE p.project_id = p_pa_project_id;

   l_amg_segment1       VARCHAR2(25);
--Added by rtarway for BUG 3872176
CURSOR c_task_asgmt_csr_pub_ver ( l_structure_version_id NUMBER )
   IS
SELECT  published_version.resource_assignment_id
FROM    pa_resource_assignments published_version,
        (SELECT   task_id, resource_list_member_id
         FROM     pa_resource_assignments ra,
                  pa_budget_versions bv,
                  pa_proj_elem_ver_structure pevs
         WHERE    ra.pm_product_code = p_pm_product_code
         AND      ra.pm_res_assignment_reference = p_pm_task_asgmt_reference
         AND      ra.project_id = p_pa_project_id
         AND      ra.budget_version_id = bv.budget_version_id
         AND      bv.project_id = p_pa_project_id
         AND      bv.project_structure_version_id = pevs.element_version_id
         AND      pevs.current_flag = 'N'
         AND      pevs.project_id = p_pa_project_id) working_version,
        pa_budget_versions bv
WHERE   working_version.task_id = published_version.task_id
AND     working_version.resource_list_member_id =  published_version.resource_list_member_id
AND     bv.project_structure_version_id = l_structure_version_id
AND     published_version.project_id = p_pa_project_id
AND     bv.budget_version_id = published_version.budget_version_id
AND     rownum = 1;

-- Bug 3872176 Cursor to get the structure_version_id of a template
CURSOR get_template_struct_ver IS
     select c.element_version_id
        from pa_proj_element_versions c,
             pa_proj_elements b,
             pa_proj_structure_types a,
             pa_structure_types d
       where d.structure_type_class_code = 'WORKPLAN'
         and d.structure_type_id = a.structure_type_id
         and a.proj_element_id = b.proj_element_id
         and b.project_id = p_pa_project_id
         and b.proj_element_id = c.proj_element_id
         and b.project_id = c.project_id
         and c.object_type = 'PA_STRUCTURES';
-- End of Bug 3872176

   l_published_struct_elem_ver_id NUMBER;
   l_struct_ver_id NUMBER;

BEGIN

   x_return_status :=  FND_API.G_RET_STS_SUCCESS;

   -- Bug 3872176 get project information
   OPEN l_project_id_csr;
   FETCH l_project_id_csr INTO l_dummy, l_template_flag, l_version_enabled_flag;
   CLOSE l_project_id_csr;

   IF p_pa_project_id <> PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM
      AND p_pa_project_id IS NOT NULL  THEN

      IF l_dummy IS NULL THEN

                        IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.G_MSG_LVL_ERROR)
                           THEN
                             pa_interface_utils_pub.map_new_amg_msg
                              ( p_old_message_code => 'PA_INVALID_PROJECT_ID'
                               ,p_msg_attribute    => 'CHANGE'
                               ,p_resize_flag      => 'N'
                               ,p_msg_context      => 'GENERAL'
                               ,p_attribute1       => ''
                               ,p_attribute2       => ''
                               ,p_attribute3       => ''
                               ,p_attribute4       => ''
                               ,p_attribute5       => '');
                      END IF;

                         RAISE FND_API.G_EXC_ERROR;
                END IF;

   ELSE

                 IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.G_MSG_LVL_ERROR)
                 THEN
                             pa_interface_utils_pub.map_new_amg_msg
                              ( p_old_message_code => 'PA_PROJECT_ID_MISSING'
                               ,p_msg_attribute    => 'CHANGE'
                               ,p_resize_flag      => 'N'
                               ,p_msg_context      => 'GENERAL'
                               ,p_attribute1       => ''
                               ,p_attribute2       => ''
                               ,p_attribute3       => ''
                               ,p_attribute4       => ''
                               ,p_attribute5       => '');
                 END IF;

                 RAISE FND_API.G_EXC_ERROR;

   END IF;

   IF  p_pa_structure_version_id IS NOT NULL AND
            (p_pa_structure_version_id <> PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM) THEN

             l_struct_elem_version_id := p_pa_structure_version_id;

--Added by rtarway for BUG 3872176
    -- 1. Project, VE Structure , Working version
    ELSIF l_template_flag = 'N' AND p_PUBLISHED_VERSION_FLAG = 'N' AND l_version_enabled_flag = 'Y' THEN

             l_struct_elem_version_id := PA_PROJECT_STRUCTURE_UTILS.get_current_working_ver_id(
                                         p_project_id => p_pa_project_id);

    -- 2. Project, VE Structure, Published version
    ELSIF l_template_flag = 'N' AND p_PUBLISHED_VERSION_FLAG = 'Y' AND l_version_enabled_flag = 'Y' THEN

             l_struct_elem_version_id := pa_project_structure_utils.GET_LATEST_WP_VERSION(
                                              p_project_id => p_pa_project_id);

    -- 3. Project, VD Structure
    ELSIF l_template_flag = 'N' AND l_version_enabled_flag = 'N' THEN
             --dbms_output.put_line('Getting current structure version'  );
             l_struct_elem_version_id := pa_project_structure_utils.GET_LATEST_WP_VERSION(
                                              p_project_id => p_pa_project_id);

    -- 4. Template
    ELSIF l_template_flag = 'Y' THEN

             OPEN get_template_struct_ver;
             FETCH get_template_struct_ver INTO l_struct_elem_version_id;
             CLOSE get_template_struct_ver;

--End Add by rtarway for BUG 3872176

    END IF;

      --dbms_output.put_line(' structure version is: ' || l_struct_elem_version_id );
            --dbms_output.put_line(' testing str if..' );

        IF ( l_struct_elem_version_id IS NULL OR
             l_struct_elem_version_id = PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM
              )

       THEN
                         --dbms_output.put_line(' test struct.null or g miss..');

                    IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.G_MSG_LVL_ERROR)
                    THEN
                            --dbms_output.put_line(' test struct.null or gmiss err..');
                               pa_interface_utils_pub.map_new_amg_msg
                                    ( p_old_message_code => 'PA_PS_STRUC_VER_REQ'
                                     ,p_msg_attribute    => 'CHANGE'
                                     ,p_resize_flag      => 'N'
                                     ,p_msg_context      => 'GENERAL'
                                     ,p_attribute1       => ''
                                     ,p_attribute2       => ''
                                     ,p_attribute3       => ''
                                     ,p_attribute4       => ''
                                     ,p_attribute5       => '');
                    END IF;
                 RAISE FND_API.G_EXC_ERROR;
       END IF;

   IF p_pa_task_id <>  PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM
   AND p_pa_task_id IS NOT NULL
   THEN

                -- Get segment1 for AMG messages

                       OPEN l_amg_project_csr( p_pa_project_id );
                       FETCH l_amg_project_csr INTO l_amg_segment1;
                       CLOSE l_amg_project_csr;

                      l_task_ver_id := pa_proj_elements_utils.get_task_version_id(
                                        l_struct_elem_version_id,
                                        p_pa_task_id);
--dbms_output.put_line(l_task_ver_id);
               IF l_task_ver_id is NULL
               THEN
                         IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.G_MSG_LVL_ERROR)
                         THEN
                             pa_interface_utils_pub.map_new_amg_msg
                              ( p_old_message_code => 'PA_TASK_ID_INVALID'
                               ,p_msg_attribute    => 'CHANGE'
                               ,p_resize_flag      => 'N'
                               ,p_msg_context      => 'PROJ'
                               ,p_attribute1       => l_amg_segment1
                               ,p_attribute2       => ''
                               ,p_attribute3       => ''
                               ,p_attribute4       => ''
                               ,p_attribute5       => '');
                          END IF;


                         RAISE FND_API.G_EXC_ERROR;
                END IF;

        --p_out_task_id := p_pa_task_id;  --JRAJ.
    END IF;  --IF p_pa_task_id <>  PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM



    IF p_pa_task_assignment_id <>  PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM
   AND p_pa_task_assignment_id IS NOT NULL
   THEN
--dbms_output.put_line('task assignment id is passed'||p_pa_task_assignment_id);
        -- Get segment1 for AMG messages


               OPEN l_amg_project_csr( p_pa_project_id );
               FETCH l_amg_project_csr INTO l_amg_segment1;
               CLOSE l_amg_project_csr;

               -- 3860640 Passing derived structure version id to l_task_asgmt_id_csr cursor
               OPEN l_task_asgmt_id_csr(l_struct_elem_version_id);
               FETCH l_task_asgmt_id_csr INTO l_dummy;

               IF l_task_asgmt_id_csr%NOTFOUND
               THEN
                         IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.G_MSG_LVL_ERROR)
                         THEN
                             pa_interface_utils_pub.map_new_amg_msg
                              ( p_old_message_code => 'PA_TASK_ASGMT_ID_INVALID'
                               ,p_msg_attribute    => 'CHANGE'
                               ,p_resize_flag      => 'N'
                               ,p_msg_context      => 'PROJ'
                               ,p_attribute1       => l_amg_segment1
                               ,p_attribute2       => ''
                               ,p_attribute3       => ''
                               ,p_attribute4       => ''
                               ,p_attribute5       => '');
                          END IF;

                        CLOSE l_task_asgmt_id_csr;
                         RAISE FND_API.G_EXC_ERROR;
                END IF;

                 CLOSE l_task_asgmt_id_csr;

                 x_pa_task_assignment_id := p_pa_task_assignment_id;  --JRAJ.
    ELSIF p_pm_task_asgmt_reference <>  PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
       AND p_pm_task_asgmt_reference IS NOT NULL
    THEN


              --dbms_output.put_line('p_pm_task_asgmt_reference'||p_pm_task_asgmt_reference);
                  --Added by rtarway for BUG 3872176
                 --Added If condition
                 IF (p_published_version_flag = 'N')
                 THEN
                      OPEN c_task_asgmt_csr(l_struct_elem_version_id);
                      FETCH c_task_asgmt_csr INTO l_task_asgmt_id ;
                      CLOSE c_task_asgmt_csr;


                      -- 4216541
                      IF l_task_asgmt_id  IS NULL THEN

                        IF p_pa_task_elem_ver_id <> PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM AND
                           p_pa_task_elem_ver_id IS NOT NULL AND
                          p_resource_list_member_id <> PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM AND
                          p_resource_list_member_id IS NOT NULL
                        THEN

                          OPEN c_task_asgmt_from_id_csr(l_struct_elem_version_id);
                          FETCH c_task_asgmt_from_id_csr INTO l_task_asgmt_id ;
                          CLOSE c_task_asgmt_from_id_csr;

                        END IF;    -- IF p_pa_task_elem_ver_id <> PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM AND
                        -- END OF 4216541

                        IF  l_task_asgmt_id  IS NULL THEN

                                  IF FND_MSG_PUB.check_msg_level (FND_MSG_PUB.G_MSG_LVL_ERROR)
                                  AND p_add_error_msg_flag = 'Y'    -- Bug 3937017
                                  -- In update_task_assignments flow, convert_pm_taref_to_id is called to determine whether
                                  -- the given assignment data should be created (if failed to convert) or updated (if conversion
                                  -- succeeds).  Therefore, in this flow, failing to convert is not really an expected error
                                  -- suitable to be added to the fnd error stack. Hence checking the value of
                                  -- p_add_error_msg_flag before adding this error to the error stack.
                                  THEN
                                             FND_MESSAGE.SET_NAME('PA','PA_API_CONV_ERROR_AMG'); -- Bug 2257612
                                             FND_MESSAGE.SET_TOKEN('ATTR_NAME','Pm Task Assignment Reference');
                                             FND_MESSAGE.SET_TOKEN('ATTR_VALUE',p_pm_task_asgmt_reference);
                                             FND_MSG_PUB.add;

                                             RAISE FND_API.G_EXC_ERROR;

                                  END IF;

                          ELSE
                                x_pa_task_assignment_id := l_task_asgmt_id ;

                          END IF; -- IF  l_task_asgmt_id  IS NULL


                       ELSE
                             x_pa_task_assignment_id := l_task_asgmt_id ;

                       END IF; -- IF l_task_asgmt_id  IS NULL

                ELSE
                      --Update from BUG 3872176
                    /*   3.2 write a new cursor to return the assignment in the published version,
                         with rlm_id and task_id matching the record in the working version using the
                         given TARef.
                         3.3 execute the cursor sql and return the resource_assignment_id; or add
                         error to message stack if not found.
                    */
                      OPEN  c_task_asgmt_csr_pub_ver(l_struct_elem_version_id);
                      FETCH c_task_asgmt_csr_pub_ver INTO l_task_asgmt_id ;
                      CLOSE c_task_asgmt_csr_pub_ver;
                      --dbms_output.put_line('l_task_asgmt_id'||l_task_asgmt_id);
                      IF  l_task_asgmt_id  IS NULL
                      THEN

                                  IF FND_MSG_PUB.check_msg_level (FND_MSG_PUB.G_MSG_LVL_ERROR)
                                  AND p_add_error_msg_flag = 'Y'    -- Bug 3937017
                                  THEN
                                             FND_MESSAGE.SET_NAME('PA','PA_API_CONV_ERROR_AMG'); -- Bug 2257612
                                             FND_MESSAGE.SET_TOKEN('ATTR_NAME','Pm Task Assignment Reference');
                                             FND_MESSAGE.SET_TOKEN('ATTR_VALUE',p_pm_task_asgmt_reference);
                                             FND_MSG_PUB.add;

                                             RAISE FND_API.G_EXC_ERROR;

                                  END IF;
                      ELSE
                             x_pa_task_assignment_id := l_task_asgmt_id ;  --JRAJ.

                      END IF;
                END IF;
                --End Added by rtarway for BUG 3872176


     ELSE

                IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.G_MSG_LVL_ERROR)
                THEN
                     pa_interface_utils_pub.map_new_amg_msg
                      ( p_old_message_code => 'PA_TASK_ASGMT_REF_ID_MISSING'
                       ,p_msg_attribute    => 'CHANGE'
                       ,p_resize_flag      => 'N'
                       ,p_msg_context      => 'PROJ'
                       ,p_attribute1       => l_amg_segment1
                       ,p_attribute2       => ''
                       ,p_attribute3       => ''
                       ,p_attribute4       => ''
                       ,p_attribute5       => '');
                    END IF;

            RAISE FND_API.G_EXC_ERROR;

     END IF; -- If p_pa_task_id <>  PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM
   --dbms_output.put_line('l_task_asgmt_id'||l_task_asgmt_id);
EXCEPTION

    WHEN FND_API.G_EXC_ERROR
    THEN


        x_return_status := FND_API.G_RET_STS_ERROR;

    WHEN FND_API.G_EXC_UNEXPECTED_ERROR
    THEN


        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

    WHEN OTHERS THEN


        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

        IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
        THEN
            FND_MSG_PUB.add_exc_msg
                    ( p_pkg_name        => 'PA_TASK_ASSIGNMENT_UTILS'
                    , p_procedure_name  => l_api_name   );

        END IF;

END Convert_pm_taref_to_id;

end PA_TASK_ASSIGNMENTS_PUB;

/
