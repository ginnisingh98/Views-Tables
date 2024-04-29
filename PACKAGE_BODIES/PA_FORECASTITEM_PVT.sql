--------------------------------------------------------
--  DDL for Package Body PA_FORECASTITEM_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PA_FORECASTITEM_PVT" as
--/* $Header: PARFIGPB.pls 120.14.12010000.3 2009/12/28 11:07:45 vgovvala ship $ */

-- Procedure level variable declaration

-- Back end code run in self-service cannot use globals.
--g_TimelineProfileSetup  PA_TIMELINE_GLOB.TimelineProfileSetup;
--g_process_mode          VARCHAR2(30);
--AVAILABILITY_DURATION   NUMBER;

/** The follwing Api prints the message to
 *  different places . this is the centralized api
 *  created by Ranga Iyengar
 **/
P_DEBUG_MODE varchar2(1) := NVL(FND_PROFILE.value('PA_DEBUG_MODE'), 'N'); /* Added Debug Profile Option  variable initialization for bug#2674619 */

PROCEDURE print_message(p_msg  IN varchar2) IS
BEGIN
	--PA_FORECAST_ITEMS_UTILS.log_message(p_msg);
  if (p_msg is not null) then
    IF P_DEBUG_MODE = 'Y' THEN /* Added Debug Profile Option Check for bug#2674619 */
     pa_debug.write(x_module => 'pa.plsql.pa_forecastitem_pvt',
                    x_msg => p_msg,
                    x_log_level => 1);
	      pa_debug.write_file('print_message: ' || 'Log :'||p_msg);
	   END IF;
	   --r_msg('Log :'||p_msg);
	   --dbms_output.put_line('Log:'||p_msg);
  end if;
	Return;
EXCEPTION
	WHEN OTHERS THEN
		RAISE;
END print_message;

/*---------------------------------------------------------------------
|   Procedure  :   Create_Forecast_Item
|   Purpose    :   To create forecast item FOR an assignment
|   Parameters :   p_assignment_id  - Input Assignment ID
|                  p_start_date     - Start DATE FOR Forecast Item Generation
|                  p_end_date       - END DATE FOR Forecast Item Generation
|                  p_process_mode   - Mode of Processing.
|                    a) GENERATE    : New Generation
|                                     Also whenever schedule data changes
|                    b) RECALCULATE : Whenever
|                                    i)expenditure OU Changes
|                                   ii)expenditure organization Changes
|                                  iii)expenditure type Changes
|                                   iv)expenditure type class Changes
|                                    v)Borrowed flag Changes
|                    c) ERROR       : Regeneration of Errored forecast items
|                                     by previous generation
|                  x_return_status  -
|                  x_msg_count      -
|                  x_msg_data       -
|
+----------------------------------------------------------------------*/
       PROCEDURE Create_Forecast_Item(
                 p_assignment_id    IN      NUMBER,
                 p_start_date       IN      DATE DEFAULT NULL,
                 p_end_date         IN      DATE DEFAULT NULL,
                 p_process_mode     IN      VARCHAR2,
                 p_gen_res_fi_flag  IN      VARCHAR2 := 'Y',
                 x_return_status    OUT NOCOPY     VARCHAR2, /* Added the nocopy check for Bug 4537865 */
                 x_msg_count        OUT NOCOPY    NUMBER,/* Added the nocopy check for Bug 4537865 */
                 x_msg_data         OUT NOCOPY    VARCHAR2) IS /* Added the nocopy check for Bug 4537865 */

             TmpAsgnDtlRec     PA_FORECAST_GLOB.AsgnDtlRecord;
             TmpErrHdrTab      PA_FORECAST_GLOB.FIHdrTabTyp;

	           l_msg_index_out	            NUMBER;
             lv_res_start_date         DATE;
             lv_res_end_date           DATE;
             lv_return_status          VARCHAR2(30);

	     l_data VARCHAR2(2000); -- 4537865
             l_unassigned_fi_start_date  DATE;
             l_unassigned_fi_end_date DATE;
             g_TimelineProfileSetup  PA_TIMELINE_GLOB.TimelineProfileSetup;
             AVAILABILITY_DURATION   NUMBER;

             CURSOR c1 IS
               SELECT MAX(item_date) item_date
               FROM pa_forecast_items
               WHERE resource_id = TmpAsgnDtlRec.resource_id
               AND delete_flag = 'N'
               AND forecast_item_type = 'U';

             v_c1 c1%ROWTYPE;

       BEGIN

             TmpErrHdrTab.Delete;
             lv_return_status := FND_API.G_RET_STS_SUCCESS;
             PA_DEBUG.Init_err_stack(
                       'PA_FORECASTITEM_PVT.Create_Forecast_Item');


             Print_message('1 Calling Get_Assignment_Dtls');

             Get_Assignment_Dtls( p_assignment_id => p_assignment_id ,
                                  x_AsgnDtlRec    => TmpAsgnDtlRec,
                                  x_return_status => lv_return_status,
                                  x_msg_count     => x_msg_count,
                                  x_msg_data      => x_msg_data );

             IF (lv_return_status = FND_API.G_RET_STS_SUCCESS) THEN

                IF p_process_mode = 'ERROR' THEN

                   Print_message(
                          'Calling FI_Error_Process');

                   FI_Error_Process( p_AsgnDtlRec    => TmpAsgnDtlRec,
                                    p_process_mode  => p_process_mode,
                                    p_start_date    => p_start_date,
                                    p_end_date      => p_end_date,
                                    x_return_status => lv_return_status,
                                    x_msg_count     => x_msg_count,
                                    x_msg_data      => x_msg_data );

                ELSIF TmpAsgnDtlRec.assignment_type IN( 'OPEN_ASGMT')  THEN

                     Print_message(
                          'Calling Generate_Requirement_FI');

                     Generate_Requirement_FI(
                                    p_AsgnDtlRec    => TmpAsgnDtlRec,
                                    p_process_mode  => p_process_mode,
                                    p_start_date    => p_start_date,
                                    p_end_date      => p_end_date,
                                    p_ErrHdrTab     => TmpErrHdrTab,
                                    x_return_status => lv_return_status,
                                    x_msg_count     => x_msg_count,
                                    x_msg_data      => x_msg_data );
                ELSE

                     Print_message(
                          'Calling Generate_Assignment_FI');

                     Generate_Assignment_FI(
                                    p_AsgnDtlRec     => TmpAsgnDtlRec,
                                    p_process_mode   => p_process_mode,
                                    p_start_date     => p_start_date,
                                    p_end_date       => p_end_date,
                                    p_ErrHdrTab      => TmpErrHdrTab,
                                    x_res_start_date => lv_res_start_date,
                                    x_res_end_date   => lv_res_end_date,
                                    x_return_status  => lv_return_status,
                                    x_msg_count      => x_msg_count,
                                    x_msg_data       => x_msg_data );

                     IF lv_return_status = FND_API.G_RET_STS_SUCCESS THEN

                        IF (p_process_mode <> 'ERROR' ) THEN

                            Print_message(
                               'Calling Regenerate_Res_Unassigned_FI');

                            IF (p_gen_res_fi_flag = 'Y') then
                              Regenerate_Res_Unassigned_FI(
                                p_resource_id => TmpAsgnDtlRec.resource_id,
                                p_start_date  => lv_res_start_date,
                                p_end_date  => lv_res_end_date,
                                p_process_mode => p_process_mode,
                                p_ErrHdrTab   => TmpErrHdrTab,
                                x_return_status => lv_return_status,
                                x_msg_count  => x_msg_count,
                                x_msg_data   => x_msg_data );
                            END IF;

                          -- Generate Resource FI if the end_date of the current unassigned
                          -- FI is less than sysdate + availability_duration.
                          IF (lv_return_status = FND_API.G_RET_STS_SUCCESS) THEN

                            TmpErrHdrTab.DELETE;
                            OPEN c1;
                            FETCH c1 INTO v_c1;
                            IF c1%NOTFOUND THEN
                              l_unassigned_fi_start_date := sysdate;
                            ELSE
                              l_unassigned_fi_start_date := v_c1.item_date +1;
                            END IF;
                            CLOSE c1;     -- Bug 4696316

                            g_TimelineProfileSetup  := PA_TIMELINE_UTIL.get_timeline_profile_setup;
                            availability_duration   := nvl(g_TimelineProfileSetup.availability_duration,0);
                            l_unassigned_fi_end_date :=  ADD_MONTHS(sysdate, availability_duration * (12));
                            IF ((l_unassigned_fi_start_date <=
                                            l_unassigned_fi_end_date) AND
                               (availability_duration > 0)) THEN
                              Regenerate_Res_Unassigned_FI(
                                p_resource_id => TmpAsgnDtlRec.resource_id,
                                p_start_date  => l_unassigned_fi_start_date,
                                p_end_date  => l_unassigned_fi_end_date,
                                p_process_mode => p_process_mode,
                                p_ErrHdrTab   => TmpErrHdrTab,
                                x_return_status => lv_return_status,
                                x_msg_count  => x_msg_count,
                                x_msg_data   => x_msg_data );
                            END IF;

                          END IF;

                        END IF;

                     END IF;

                 END IF;

             END IF;

             x_return_status := lv_return_status;

             PA_DEBUG.Reset_Err_Stack;

       EXCEPTION

              WHEN OTHERS THEN
                  print_message('Failed in create forecast item api');
                  print_message('SQLCODE'||sqlcode||sqlerrm);

                   x_msg_count     := 1;
                   x_msg_data      := sqlerrm;
                   FND_MSG_PUB.add_exc_msg
                      (p_pkg_name   =>
                              'PA_FORECASTITEM_PVT.Create_Forecast_Item',
                       p_procedure_name => PA_DEBUG.G_Err_Stack);
                   x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

		               If x_msg_count = 1 THEN
				              pa_interface_utils_pub.get_messages
				                (p_encoded        => FND_API.G_TRUE,
					               p_msg_index      => 1,
					               p_msg_count      => x_msg_count,
					               p_msg_data       => x_msg_data,
					               p_data           => l_data, -- 4537865
					               p_msg_index_out  => l_msg_index_out );
						x_msg_data := l_data ; -- 4537865
		               End If;

                   Print_message(x_msg_data);

                   RAISE;

       END Create_Forecast_Item;

/*---------------------------------------------------------------------
|   Procedure  :   Create_Forecast_Item
|   Purpose    :   To create forecast item FOR Unassigned time of a resource
|   Parameters :   p_resource_id    - Input Resource ID
|                  p_start_date     - Start DATE FOR Forecast Item Generation
|                  p_end_date       - END DATE FOR Forecast Item Generation
|                  p_process_mode   - Mode of Processing.
|                    a) GENERATE    : New Generation
|                                     Also whenever schedule data changes
|                    b) RECALCULATE : Whenever
|                                    i)expenditure OU Changes
|                                   ii)expenditure organization Changes
|                                  iii)expenditure type Changes
|                                   iv)expenditure type class Changes
|                                    v)Borrowed flag Changes
|                  x_return_status  -
|                  x_msg_count      -
|                  x_msg_data       -
+----------------------------------------------------------------------*/
      PROCEDURE Create_Forecast_Item (
                p_resource_id    IN      NUMBER,
                p_start_date     IN     DATE, --Bug 1851096
                p_end_date       IN     DATE, --Bug 1851096
                p_process_mode   IN     VARCHAR2,
                x_return_status  OUT NOCOPY    VARCHAR2, /* Added the nocopy check for Bug 4537865 */
                x_msg_count      OUT NOCOPY     NUMBER, /* Added the nocopy check for Bug 4537865 */
                x_msg_data       OUT NOCOPY    VARCHAR2) IS /* Added the nocopy check for Bug 4537865 */

             lv_start_date    DATE;
             lv_end_date      DATE;
             TmpErrTab        PA_FORECAST_GLOB.FIHdrTabTyp;
             lv_return_status  VARCHAR2(30);
             l_msg_index_out  NUMBER;

	     l_data VARCHAR2(2000); -- 4537865
       BEGIN

             lv_return_status := FND_API.G_RET_STS_SUCCESS;

             TmpErrTab.Delete;

             PA_DEBUG.Init_err_stack(
                       'PA_FORECASTITEM_PVT.Create_Forecast_Item');
             lv_start_date := p_start_date;
             lv_end_date   := p_end_date;

             Print_message(
                          'Calling Regenerate_Res_Unassigned_FI');

             Regenerate_Res_Unassigned_FI(
                            p_resource_id   => p_resource_id,
                            p_start_date    => lv_start_date,
                            p_end_date      => lv_end_date,
                            p_process_mode  => p_process_mode,
                            p_ErrHdrTab     => TmpErrTab,
                            x_return_status => lv_return_status,
                            x_msg_count     => x_msg_count,
                            x_msg_data      => x_msg_data );

             PRINT_MESSAGE(x_return_status || ' ' || lv_return_status);
             PA_DEBUG.Reset_Err_Stack;
             PRINT_MESSAGE(x_return_status || ' ' || lv_return_status);

             x_return_status := lv_return_status;
             PRINT_MESSAGE(x_return_status || ' ' || lv_return_status);

       EXCEPTION

              WHEN OTHERS THEN
                  print_message('Failed in Create_forecast_item api');
                  print_message('SQLCODE'||sqlcode||sqlerrm);

                   x_msg_count     := 1;
                   x_msg_data      := sqlerrm;
                   x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
                   FND_MSG_PUB.add_exc_msg
                      (p_pkg_name   =>
                              'PA_FORECASTITEM_PVT.Create_Forecast_Item',
                       p_procedure_name => PA_DEBUG.G_Err_Stack);

		               If x_msg_count = 1 THEN
				              pa_interface_utils_pub.get_messages
				                (p_encoded        => FND_API.G_TRUE,
					               p_msg_index      => 1,
					               p_msg_count      => x_msg_count,
					               p_msg_data       => x_msg_data,
					               p_data           => l_data, -- 4537865
					               p_msg_index_out  => l_msg_index_out );
						x_msg_data := l_data ; -- 4537865
		               End If;

                   Print_message(x_msg_data);

                   RAISE;

       END Create_Forecast_Item;

/*---------------------------------------------------------------------
|   Procedure  :   Create_Forecast_Item
|   Purpose    :   To create forecast item FOR Unassigned time of a resource
|   Parameters :   p_person_id      - Input person ID
|                  p_start_date     - Start DATE FOR Forecast Item Generation
|                  p_end_date       - END DATE FOR Forecast Item Generation
|                  p_process_mode   - Mode of Processing.
|                    a) GENERATE    : New Generation
|                                     Also whenever schedule data changes
|                    b) RECALCULATE : Whenever
|                                    i)expenditure OU Changes
|                                   ii)expenditure organization Changes
|                                  iii)expenditure type Changes
|                                   iv)expenditure type class Changes
|                                    v)Borrowed flag Changes
|                  x_return_status  -
|                  x_msg_count      -
|                  x_msg_data       -
+----------------------------------------------------------------------*/
      PROCEDURE Create_Forecast_Item (
                p_person_id      IN      NUMBER,
                p_start_date     IN     DATE  DEFAULT NULL,
                p_end_date       IN     DATE  DEFAULT NULL,
                p_process_mode   IN     VARCHAR2,
                x_return_status  OUT NOCOPY    VARCHAR2, -- 4537865 Added Nocopy
                x_msg_count      OUT NOCOPY    NUMBER,  -- 4537865 Added Nocopy
                x_msg_data       OUT NOCOPY    VARCHAR2) IS  -- 4537865 Added Nocopy


             lv_res_start_date         DATE;
             lv_res_end_date           DATE;


             lv_start_date    DATE;
             lv_end_date      DATE;
             lv_resource_id   NUMBER;
             lv_lock_type     VARCHAR2(5);

             TmpAsgnDtlRec     PA_FORECAST_GLOB.AsgnDtlRecord;
             TmpErrHdrTab      PA_FORECAST_GLOB.FIHdrTabTyp;
             lv_AssignmentIdTab           PA_FORECAST_GLOB.NumberTabTyp;
             lv_AssignmentTypeTab         PA_FORECAST_GLOB.VCTabTyp;
             lv_StatusCodeTab             PA_FORECAST_GLOB.VCTabTyp;
             lv_StartDateTab              PA_FORECAST_GLOB.DateTabTyp;
             lv_EndDateTab                PA_FORECAST_GLOB.DateTabTyp;
             lv_SourceAssignmentIDTab     PA_FORECAST_GLOB.NumberTabTyp;
             lv_ProjectIDTab              PA_FORECAST_GLOB.NumberTabTyp;
             lv_ResourceIDTab             PA_FORECAST_GLOB.NumberTabTyp;
             lv_WorkTypeIDTab             PA_FORECAST_GLOB.NumberTabTyp;
             lv_ExpenditureOrgIDTab       PA_FORECAST_GLOB.NumberTabTyp;
             lv_ExpenditureOrgnIDTab      PA_FORECAST_GLOB.NumberTabTyp;
             lv_ExpenditureTypeTab        PA_FORECAST_GLOB.VCTabTyp;
             lv_ExpTypeClassTab           PA_FORECAST_GLOB.VCTabTyp;
             lv_FcstTpAmountTypeTab       PA_FORECAST_GLOB.VCTabTyp;

             TmpErrTab        PA_FORECAST_GLOB.FIHdrTabTyp;
             l_cannot_acquire_lock   EXCEPTION;
             l_cannot_release_lock   EXCEPTION;
             lv_return_status  VARCHAR2(30);
             lv_err_asg_id    NUMBER;

             lv_process_mode VARCHAR2(80);

						 -- 2275838: Removed union for performance.
             CURSOR asgmt_dtls(lv_resource_id NUMBER) IS
                 SELECT proj_asgn.assignment_id,
                        decode(proj_asgn.assignment_type,
                                  'OPEN_ASSIGNMENT', 'OPEN_ASGMT',
                                  'STAFFED_ASSIGNMENT', 'STAFFED_ASGMT',
                                  'STAFFED_ADMIN_ASSIGNMENT', 'STAFFED_ASGMT',
                                              'STAFFED_ASGMT'),
                        proj_asgn.status_code,proj_asgn.start_date,
                        proj_asgn.end_date, proj_asgn.source_assignment_id,
                        proj_asgn.project_id,  proj_asgn.resource_id,
                        proj_asgn.work_type_id,
                        NVL(proj_asgn.expenditure_org_id,-99)
                                         expenditure_org_id,
                        proj_asgn.expenditure_organization_id,
                        proj_asgn.expenditure_type,
                        proj_asgn.expenditure_type_class,
                        fcst_tp_amount_type
                 FROM   pa_project_assignments proj_asgn
                 WHERE  proj_asgn.resource_id = lv_resource_id
                 AND ( (lv_start_date BETWEEN proj_asgn.start_date AND
                                             proj_asgn.end_date)
                       OR (lv_end_date BETWEEN proj_asgn.start_date AND
                                              proj_asgn.end_date)
                       OR ( lv_start_date < proj_asgn.start_date AND
                            lv_end_date  > proj_asgn.end_date ));


       BEGIN

             lv_return_status := FND_API.G_RET_STS_SUCCESS;

             PA_DEBUG.Init_err_stack(
                       'PA_FORECASTITEM_PVT.Create_Forecast_Item');

             -- 2275838: Set process mode correctly.
             lv_process_mode := p_process_mode;
             if (p_process_mode = 'GENERATE_ASGMT') then
               lv_process_mode := 'GENERATE';
             end if;

						 -- 2275838: Removed union above and replaced with NVL.
             lv_start_date := NVL(p_start_date, TO_DATE('01/01/1950','MM/DD/YYYY'));
						 lv_end_date := NVL(p_end_date, TO_DATE('12/31/4712','MM/DD/YYYY'));

             print_message('lv_start_date: ' || lv_start_date);
             print_message('lv_end_date: ' || lv_end_date);

             lv_resource_id := PA_FORECAST_ITEMS_UTILS.get_resource_id(
                                   p_person_id);

             OPEN asgmt_dtls(lv_resource_id);

             LOOP

                -- fetching all the records and storing them
                -- corresponding to their tab type

                FETCH asgmt_dtls
                BULK COLLECT INTO lv_AssignmentIdTab,
                                  lv_AssignmentTypeTab,
                                  lv_StatusCodeTab ,
                                  lv_StartDateTab ,
                                  lv_EndDateTab ,
                                  lv_SourceAssignmentIDTab,
                                  lv_ProjectIDTab,
                                  lv_ResourceIDTab,
                                  lv_WorkTypeIDTab ,
                                  lv_ExpenditureOrgIDTab ,
                                  lv_ExpenditureOrgnIDTab ,
                                  lv_ExpenditureTypeTab ,
                                  lv_ExpTypeClassTab  ,
                                  lv_FcstTpAmountTypeTab
                                  LIMIT 200;


                IF lv_AssignmentIdTab.COUNT =0 THEN

                   EXIT;

                END IF;

                FOR i IN lv_AssignmentIdTab.FIRST..lv_AssignmentIdTab.LAST LOOP

-- Commenting out this logic: We must pass start date and end date of assignment to this
-- procedure because it has logic to delete assignment fis outside of the range.
/*
                        -- 2275838: Removed null check.
                        IF ( lv_StartDateTab(i) < lv_start_date ) THEN

                           lv_StartDateTab(i)  := lv_start_date;

                        END IF;

                        IF ( lv_EndDateTab(i) > lv_end_date ) THEN

                           lv_EndDateTab(i)  := lv_end_date;

                        END IF;
*/

                     -- 2275838: Removed locking code because it is taken
                     -- care of in generate_assignment_fi.

                     -- Call the Forecast Generation API.

                     TmpAsgnDtlRec.assignment_id   :=  lv_AssignmentIdTab(i);
                     TmpAsgnDtlRec.assignment_type :=  lv_AssignmentTypeTab(i);
                     TmpAsgnDtlRec.status_code     :=  lv_StatusCodeTab(i) ;
                     TmpAsgnDtlRec.start_date      :=  lv_StartDateTab(i) ;
                     TmpAsgnDtlRec.end_date        :=  lv_EndDateTab(i) ;
                     TmpAsgnDtlRec.source_assignment_id :=
                                           lv_SourceAssignmentIDTab(i);
                     TmpAsgnDtlRec.project_id      :=  lv_ProjectIDTab(i);
                     TmpAsgnDtlRec.resource_id     :=  lv_ResourceIDTab(i);
                     TmpAsgnDtlRec.work_type_id    :=  lv_WorkTypeIDTab(i);
                     TmpAsgnDtlRec.expenditure_org_id :=
                                                   lv_ExpenditureOrgIDTab(i);
                     TmpAsgnDtlRec.expenditure_organization_id :=
                                                   lv_ExpenditureOrgnIDTab(i);
                     TmpAsgnDtlRec.expenditure_type := lv_ExpenditureTypeTab(i);
                     TmpAsgnDtlRec.expenditure_type_class  :=
                                                   lv_ExpTypeClassTab(i);
                     TmpAsgnDtlRec.fcst_tp_amount_type   :=
                                                   lv_FcstTpAmountTypeTab(i);

                     Print_message(
                          'Calling Generate_Assignment_FI');

                     IF lv_return_status = FND_API.G_RET_STS_SUCCESS THEN

                         Generate_Assignment_FI(
                                    p_AsgnDtlRec     => TmpAsgnDtlRec,
                                    p_process_mode   => lv_process_mode,
                                    p_start_date     => lv_StartDateTab(i),
                                    p_end_date       => lv_EndDateTab(i),
                                    p_ErrHdrTab      => TmpErrHdrTab,
                                    x_res_start_date => lv_res_start_date,
                                    x_res_end_date   => lv_res_end_date,
                                    x_return_status  => lv_return_status,
                                    x_msg_count      => x_msg_count,
                                    x_msg_data       => x_msg_data );
                    END IF;

                END LOOP;

                lv_AssignmentIdTab.delete;
                lv_AssignmentIdTab.delete ;
                lv_AssignmentTypeTab.delete;
                lv_StatusCodeTab.delete ;
                lv_StartDateTab.delete ;
                lv_EndDateTab.delete ;
                lv_SourceAssignmentIDTab.delete;
                lv_ProjectIDTab.delete;
                lv_ResourceIDTab.delete;
                lv_WorkTypeIDTab.delete ;
                lv_ExpenditureOrgIDTab.delete ;
                lv_ExpenditureOrgnIDTab.delete ;
                lv_ExpenditureTypeTab.delete ;
                lv_ExpTypeClassTab.delete  ;
                lv_FcstTpAmountTypeTab.delete;
             END LOOP;

             CLOSE asgmt_dtls;

             -- 2275838: Do not generate unassigned time if GENERATE_ASGMT
             -- passed.
             IF (p_process_mode <> 'GENERATE_ASGMT' AND
                 lv_return_status = FND_API.G_RET_STS_SUCCESS) THEN

                 Print_message(
                          'Calling Regenerate_Res_Unassigned_FI');

                 Regenerate_Res_Unassigned_FI(
                            p_resource_id   => lv_resource_id,
                            p_start_date    => lv_start_date,
                            p_end_date      => lv_end_date,
                            p_process_mode  => lv_process_mode,
                            p_ErrHdrTab     => TmpErrTab,
                            x_return_status => lv_return_status,
                            x_msg_count     => x_msg_count,
                            x_msg_data      => x_msg_data );
             END IF;

             x_return_status := lv_return_status;

             PA_DEBUG.Reset_Err_Stack;

       EXCEPTION
              -- 2275838: Removed code to handle locking exception
              -- because locking occurs in sub procedures.
              WHEN OTHERS THEN
                  print_message('Failed in Create_forecast_item api');
                  print_message('SQLCODE'||sqlcode||sqlerrm);

                   x_msg_count     := 1;
                   x_msg_data      := sqlerrm;
                   x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
                   FND_MSG_PUB.add_exc_msg
                      (p_pkg_name   =>
                              'PA_FORECASTITEM_PVT.Create_Forecast_Item',
                       p_procedure_name => PA_DEBUG.G_Err_Stack);
                   Print_message(x_msg_data);

                   --RAISE;

       END Create_Forecast_Item;

/*---------------------------------------------------------------------
|   Procedure  :   Create_Forecast_Item
|   Purpose    :   To Re-create forecast item FOR Unassigned time of 1/many
|                  resource which have errored out IN previous generations
|   Parameters :   p_ErrHdrTab      - Table of Resource forecast items which
|                                     have errored out IN previous runs.
|                                     It has the format of pa_forecast_item
|                                     table
|                  p_process_mode   - Mode of Processing.
|                    a) ERROR       : Regeneration of Errored forecast items
|                                     by previous runs
|                  x_return_status  -
|                  x_msg_count      -
|                  x_msg_data       -
+----------------------------------------------------------------------*/
      PROCEDURE Create_Forecast_Item (
                p_ErrHdrTab      IN   PA_FORECAST_GLOB.FIHdrTabTyp,
                p_process_mode   IN   VARCHAR2,
                x_return_status  OUT NOCOPY VARCHAR2, -- 4537865 Added nocopy
                x_msg_count      OUT NOCOPY  NUMBER,	-- 4537865 Added nocopy
                x_msg_data       OUT NOCOPY VARCHAR2) IS -- 4537865 Added nocopy


             lv_return_status  VARCHAR2(30);
             l_msg_index_out NUMBER;

	     l_data VARCHAR2(2000); -- 4537865
       BEGIN

             lv_return_status := FND_API.G_RET_STS_SUCCESS;

             PA_DEBUG.Init_err_stack(
                       'PA_FORECASTITEM_PVT.Create_Forecast_Item');

             Print_message(
                          'Calling Resource_Unasg_Error_Process');

             Resource_Unasg_Error_Process(
                            p_ErrHdrTab     => p_ErrHdrTab,
                            p_process_mode  => p_process_mode,
                            x_return_status => lv_return_status,
                            x_msg_count     => x_msg_count,
                            x_msg_data      => x_msg_data );

             PA_DEBUG.Reset_Err_Stack;

             x_return_status := lv_return_status;

       EXCEPTION

              WHEN OTHERS THEN
                  print_message('Failed in Create_forecast_item api');
                  print_message('SQLCODE'||sqlcode||sqlerrm);

                   x_msg_count     := 1;
                   x_msg_data      := sqlerrm;
                   x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
                   FND_MSG_PUB.add_exc_msg
                      (p_pkg_name   =>
                              'PA_FORECASTITEM_PVT.Create_Forecast_Item',
                       p_procedure_name => PA_DEBUG.G_Err_Stack);
		               If x_msg_count = 1 THEN
				              pa_interface_utils_pub.get_messages
				                (p_encoded        => FND_API.G_TRUE,
					               p_msg_index      => 1,
					               p_msg_count      => x_msg_count,
					               p_msg_data       => x_msg_data,
					               p_data           => l_data, -- 4537865
					               p_msg_index_out  => l_msg_index_out );
						x_msg_data := l_data ; -- 4537865
		               End If;
                   Print_message(x_msg_data);
                   RAISE;

       END Create_Forecast_Item;


/* ---------------------------------------------------------------------
|   Procedure  :   Delete_Forecast_Item
|   Purpose    :   To delete all FI's for a given assignment_id
|   Parameters :   p_assignment_id   - Input assignment id
|                  x_return_status  -
|                  x_msg_count      -
|                  x_msg_data       -
+----------------------------------------------------------------------*/
       PROCEDURE Delete_Forecast_Item (
                p_assignment_id  IN   NUMBER,
                p_resource_id    IN   NUMBER,
                p_start_date     IN   DATE,
                p_end_date       IN   DATE,
                x_return_status  OUT  NOCOPY VARCHAR2, -- 4537865 Added nocopy
                x_msg_count      OUT  NOCOPY NUMBER,   -- 4537865 Added nocopy
                x_msg_data       OUT  NOCOPY VARCHAR2) IS  -- 4537865 Added nocopy

             TmpAsgnDtlRec     PA_FORECAST_GLOB.AsgnDtlRecord;
             TmpErrTab         PA_FORECAST_GLOB.FIHdrTabTyp;
             lv_process_mode   VARCHAR2(15);
             lv_start_date     DATE;
             lv_end_date     DATE;
             lv_return_status  VARCHAR2(30);
             lv_asg_count      NUMBER;
             l_msg_index_out   NUMBER;

	     l_data varchar2(2000); -- 4537865
       BEGIN

             lv_return_status := FND_API.G_RET_STS_SUCCESS;

             PA_DEBUG.Init_err_stack(
                       'PA_FORECASTITEM_PVT.Delete_Forecast_Item');

             SELECT count(*) into lv_asg_count
             FROM pa_project_assignments
             WHERE assignment_id = p_assignment_id;
/*
             Get_Assignment_Dtls( p_assignment_id => p_assignment_id ,
                                  x_AsgnDtlRec    => TmpAsgnDtlRec,
                                  x_return_status => lv_return_status,
                                  x_msg_count     => x_msg_count,
                                  x_msg_data      => x_msg_data );
*/

             print_message('lv_asg_count: ' || lv_asg_count);
             IF lv_asg_count = 0 THEN

                IF TmpAsgnDtlRec.assignment_id  IS NULL THEN

                   Print_message( 'Calling Delete_FI');

                   Delete_FI( p_assignment_id=>p_assignment_id,
                           x_return_status=>lv_return_status,
                           x_msg_count=>x_msg_count,
                           x_msg_data=> x_msg_data );
                   IF lv_return_status = FND_API.G_RET_STS_SUCCESS THEN

                      IF p_resource_id IS NOT NULL THEN

                         Print_message(
                             'Calling Regenerate_Res_Unassigned_FI');

                         lv_process_mode := 'GENERATE';
                         lv_start_date   := p_start_date;
                         lv_end_date     := p_end_date;

                         Regenerate_Res_Unassigned_FI(
                               p_resource_id   => p_resource_id,
                               p_start_date    => lv_start_date,
                               p_end_date      => lv_end_date,
                               p_process_mode  => lv_process_mode,
                               p_ErrHdrTab     => TmpErrTab,
                               x_return_status => lv_return_status,
                               x_msg_count     => x_msg_count,
                               x_msg_data      => x_msg_data );

                      END IF;

                   END IF;

                END IF;

             END IF;

             x_return_status := lv_return_status;

             PA_DEBUG.Reset_Err_Stack;

       EXCEPTION

              WHEN OTHERS THEN
                  print_message('Failed in delete_forecast_item api');
                  print_message('SQLCODE'||sqlcode||sqlerrm);

                   x_msg_count     := 1;
                   x_msg_data      := sqlerrm;
                   x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
                   FND_MSG_PUB.add_exc_msg
                      (p_pkg_name   =>
                              'PA_FORECASTITEM_PVT.Delete_Forecast_Item',
                       p_procedure_name => PA_DEBUG.G_Err_Stack);

		               If x_msg_count = 1 THEN
				              pa_interface_utils_pub.get_messages
				                (p_encoded        => FND_API.G_TRUE,
					               p_msg_index      => 1,
					               p_msg_count      => x_msg_count,
					               p_msg_data       => x_msg_data,
					               p_data           => l_data, -- 4537865
					               p_msg_index_out  => l_msg_index_out );
						x_msg_data := l_data ; -- 4537865
		               End If;
                   Print_message(x_msg_data);
                   RAISE;

       END Delete_Forecast_Item;


/* ---------------------------------------------------------------------
|   Procedure  :   Get_Assignment_Dtls
|   Purpose    :   To get Assignment details
|   Parameters :   p_assignment_id   - Input assignment id
|                  x_AsgnDtlRec      - Stores the details of assignment id
|                  x_return_status  -
|                  x_msg_count      -
|                  x_msg_data       -
+----------------------------------------------------------------------*/
       PROCEDURE Get_Assignment_Dtls(
                 p_assignment_id  IN    NUMBER,
                 x_AsgnDtlRec     OUT   NOCOPY PA_FORECAST_GLOB.AsgnDtlRecord, /* 2674619 - Nocopy change */
                 x_return_status  OUT   NOCOPY VARCHAR2, -- 4537865 Added nocopy
                 x_msg_count      OUT   NOCOPY NUMBER, -- 4537865 Added nocopy
                 x_msg_data       OUT   NOCOPY VARCHAR2) IS -- 4537865 Added nocopy

                 lv_return_status  VARCHAR2(30);
                 l_msg_index_out NUMBER;

		 l_data VARCHAR2(2000); -- 4537865
       BEGIN

              lv_return_status := FND_API.G_RET_STS_SUCCESS;

              PA_DEBUG.Init_err_stack(
                       'PA_FORECASTITEM_PVT.Get_Assignment_Dtls');

              Print_message(
                       'Entering Get_Assignment_Dtls: ' || p_assignment_id);

              -- 2196924: Adding case when p_asgn_id is null
              -- This may occur when there's no HR assignment for
              -- part of the resources time, but it is unlikely.
              -- This was changed for future support.
              if (p_assignment_id is null) then
                 x_AsgnDtlRec.assignment_id := null;
                 x_AsgnDtlRec.assignment_type := null;
                 x_AsgnDtlRec.status_code := null;
                 x_AsgnDtlRec.start_date := null;
                 x_AsgnDtlRec.end_date := null;
                 x_AsgnDtlRec.source_assignment_id := null;
                 x_AsgnDtlRec.project_id := -66;
                 x_AsgnDtlRec.resource_id := null;
                 x_AsgnDtlRec.work_type_id := null;
                 x_AsgnDtlRec.expenditure_org_id := -88;
                 x_AsgnDtlRec.expenditure_organization_id := -77;
                 x_AsgnDtlRec.expenditure_type := '-99';
                 x_AsgnDtlRec.expenditure_type_class := '-99';
                 x_AsgnDtlRec.fcst_tp_amount_type := '-99';
               else

              SELECT   assignment_id,assignment_type,
                       status_code,start_date, end_date,
                       source_assignment_id, project_id,  resource_id,
                       work_type_id,
                       NVL(expenditure_org_id,-99) expenditure_org_id,
                       expenditure_organization_id,
                       expenditure_type, expenditure_type_class,
                       fcst_tp_amount_type
              INTO     x_AsgnDtlRec
              FROM     pa_project_assignments
              WHERE    assignment_id = p_assignment_id;

              Print_message('x_AsgnDtlRec.resource_id: ' || x_AsgnDtlRec.resource_id);
              IF x_AsgnDtlRec.assignment_type = 'OPEN_ASSIGNMENT' THEN

                  Print_message(
                            x_AsgnDtlRec.assignment_type);

                   x_AsgnDtlRec.assignment_type := 'OPEN_ASGMT';

              ELSIF x_AsgnDtlRec.assignment_type in
                       ('STAFFED_ASSIGNMENT', 'STAFFED_ADMIN_ASSIGNMENT') THEN

                  Print_message(
                            x_AsgnDtlRec.assignment_type);

                   x_AsgnDtlRec.assignment_type  := 'STAFFED_ASGMT';
              END IF;

              END IF;

              Print_message(
                       'Leaving Get_Assignment_Dtls');

              PA_DEBUG.Reset_Err_Stack;

              x_return_status := lv_return_status;

       EXCEPTION

              WHEN OTHERS THEN
                  print_message('Failed in Get_assignemnt_dtls api');
                  print_message('SQLCODE'||sqlcode||sqlerrm);

                   x_msg_count     := 1;
                   x_msg_data      := sqlerrm;
                   x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
                   FND_MSG_PUB.add_exc_msg
                      (p_pkg_name   =>
                              'PA_FORECASTITEM_PVT.Get_Assignment_Dtls',
                       p_procedure_name => PA_DEBUG.G_Err_Stack);

		               If x_msg_count = 1 THEN
				              pa_interface_utils_pub.get_messages
				                (p_encoded        => FND_API.G_TRUE,
					               p_msg_index      => 1,
					               p_msg_count      => x_msg_count,
					               p_msg_data       => x_msg_data,
					               p_data           => l_data, -- 4537865
					               p_msg_index_out  => l_msg_index_out );
							x_msg_data := l_data ; -- 4537865
		               End If;

                   Print_message(x_msg_data);
                   RAISE;

       END Get_Assignment_Dtls;

/* ---------------------------------------------------------------------
|   Procedure  :   Get_Project_Dtls
|   Purpose    :   To get details of given project id
|   Parameters :   p_project_id         - Input Project ID
|                  x_project_org_id     - Project org ID
|                  x_project_orgn_id    - Project organization ID
|                  x_work_type_id       - Work type ID
|                  x_project_type_class - Project Type Class
|                  x_project_status_code - Project status code
|                  x_return_status  -
|                  x_msg_count      -
|                  x_msg_data       -
+----------------------------------------------------------------------*/
       PROCEDURE Get_Project_Dtls(
                 p_project_id           IN    NUMBER,
                 x_project_org_id       OUT NOCOPY   NUMBER, -- 4537865 Added nocopy
                 x_project_orgn_id      OUT NOCOPY  NUMBER, -- 4537865 Added nocopy
                 x_work_type_id         OUT NOCOPY  NUMBER, -- 4537865 Added nocopy
                 x_project_type_class   OUT NOCOPY  VARCHAR2, -- 4537865 Added nocopy
                 x_project_status_code  OUT NOCOPY  VARCHAR2, -- 4537865 Added nocopy
                 x_return_status        OUT NOCOPY  VARCHAR2, -- 4537865 Added nocopy
                 x_msg_count            OUT NOCOPY  NUMBER, -- 4537865 Added nocopy
                 x_msg_data             OUT NOCOPY  VARCHAR2) IS -- 4537865 Added nocopy

                 lv_return_status  VARCHAR2(30);
                 l_msg_index_out NUMBER;

		 l_data VARCHAR2(2000);
 BEGIN

             lv_return_status := FND_API.G_RET_STS_SUCCESS;

             PA_DEBUG.Init_err_stack(
                       'PA_FORECASTITEM_PVT.Get_Project_Dtls');

             Print_message('Entering Get_Project_Dtls: ' || p_project_id);

             -- 2196924: Adding case when p_project_id is null
             -- This will occur when there's no HR assignment for
             -- part of the resources time, so no unassigned time project
             -- because no ou.
             if (p_project_id = -66 or p_project_id is null) then
                 x_project_org_id := -88;
                 x_project_orgn_id := -77;
                 x_work_type_id := '-99';
                 x_project_type_class := '-99';
                 x_project_status_code := '-99';
             else

-- R12: MOAC Changes: removed nvl usage with org_id
             SELECT pr.org_id, pr.carrying_out_organization_id,
                    pr.work_type_id, pt.project_type_class_code,
                    pr.project_status_code
             INTO   x_project_org_id, x_project_orgn_id,
                    x_work_type_id, x_project_type_class,
                    x_project_status_code
             FROM   pa_projects_all pr, pa_project_types_all pt
             WHERE  pr.project_id = p_project_id
             AND    pt.org_id  = pr.org_id
             AND    pt.project_type =pr.project_type;

             end if;

             Print_message('Leaving Get_Project_Dtls');

             PA_DEBUG.Reset_Err_Stack;

             x_return_status := lv_return_status;

       EXCEPTION

              WHEN OTHERS THEN
		   print_message('Failed in Get_project_Dtls api');
		   Print_message('Sqlerr '||sqlcode||sqlerrm);

                   x_msg_count     := 1;
                   x_msg_data      := sqlerrm;
                   x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

		   -- 4537865
 		   x_project_org_id      := NULL ;
		   x_project_orgn_id     := NULL ;
 		   x_work_type_id        := NULL ;
 		   x_project_type_class  := NULL ;
 		   x_project_status_code := NULL ;

                   FND_MSG_PUB.add_exc_msg
                      (p_pkg_name   =>
                              'PA_FORECASTITEM_PVT.Get_Project_Dtls',
                       p_procedure_name => PA_DEBUG.G_Err_Stack);
		               If x_msg_count = 1 THEN
				              pa_interface_utils_pub.get_messages
				                (p_encoded        => FND_API.G_TRUE,
					               p_msg_index      => 1,
					               p_msg_count      => x_msg_count,
					               p_msg_data       => x_msg_data,
					               p_data           => l_data, -- 4537865
					               p_msg_index_out  => l_msg_index_out );
							x_msg_data := l_data ; -- 4537865
		               End If;
                   Print_message(x_msg_data);

                   RAISE;


       END Get_Project_Dtls;

/* ---------------------------------------------------------------------
|   Procedure  :   Generate_Requirement_FI
|   Purpose    :   To generate forecast items FOR requirement record
|   Parameters :   p_AsgnDtlRec     - Assignment Details FOR which
|                                     forecast item is to be generated
|                  p_process_mode   - Mode of Processing
|                    a) GENERATE    : New Generation
|                                     Also whenever schedule data changes
|                    b) RECALCULATE : Whenever
|                                    i)expenditure OU Changes
|                                   ii)expenditure organization Changes
|                                  iii)expenditure type Changes
|                                   iv)expenditure type class Changes
|                                    v)Borrowed flag Changes
|                    c) ERROR       : Regeneration of Errored forecast items
|                                     by previous generation
|                  p_start_date     - Start DATE FOR Forecast Item Generation
|                  p_end_date       - END DATE FOR Forecast Item Generation
|                  p_ErrHdrTab      -
|                    a)GENERATE/        : Dummy tab is passed
|                      RECALCULATE Mode
|                    b) ERROR Mode      : Contains all errored forecast item
|                                          Header records
|                  x_return_status  -
|                  x_msg_count      -
|                  x_msg_data       -
+----------------------------------------------------------------------*/


       PROCEDURE Generate_Requirement_FI(
                 p_AsgnDtlRec     IN   PA_FORECAST_GLOB.AsgnDtlRecord,
                 p_process_mode   IN   VARCHAR2,
                 p_start_date     IN   DATE,
                 p_end_date       IN   DATE,
                 p_ErrHdrTab      IN   PA_FORECAST_GLOB.FIHdrTabTyp,
                 x_return_status  OUT  NOCOPY VARCHAR2, -- 4537865 Added nocopy
                 x_msg_count      OUT  NOCOPY NUMBER, -- 4537865 Added nocopy
                 x_msg_data       OUT  NOCOPY VARCHAR2) IS  -- 4537865 Added nocopy


             lv_req_exist_flag      VARCHAR2(1) := 'N';
             TmpDbFIDtlTab          PA_FORECAST_GLOB.FIDtlTabTyp;
             TmpDbFIHdrTab          PA_FORECAST_GLOB.FIHdrTabTyp;
             TmpFIDtlInsTab         PA_FORECAST_GLOB.FIDtlTabTyp;
             TmpFIDtlUpdTab         PA_FORECAST_GLOB.FIDtlTabTyp;
             TmpFIHdrInsTab         PA_FORECAST_GLOB.FIHdrTabTyp;
             TmpFIHdrUpdTab         PA_FORECAST_GLOB.FIHdrTabTyp;
             TmpScheduleTab         PA_FORECAST_GLOB.SCHEDULETABTYP;
             TmpFIDayTab            PA_FORECAST_GLOB.FIDayTabTyp;
             lv_start_date          DATE ;
             lv_end_date            DATE ;
             l_msg_index_out        NUMBER;

	     l_data VARCHAR2(2000); -- 4537865
             -- Used to determine start_date AND end_date for
             -- Calculating resource unassigned time
             -- Not applicable IN this routine

             lv_old_start_date      DATE := NULL;
             lv_old_end_date        DATE := NULL;
             lv_res_start_date      DATE := NULL;
             lv_res_end_date        DATE := NULL;
             lv_err_msg             VARCHAR2(30);

             lv_return_status  VARCHAR2(30);

       BEGIN

             lv_return_status := FND_API.G_RET_STS_SUCCESS;

             PA_DEBUG.Init_err_stack( 'PA_FORECASTITEM_PVT.Generate_Requirement_FI');

             TmpDbFIDtlTab.Delete;
             TmpDbFIHdrTab.Delete;
             TmpFIDtlInsTab.Delete;
             TmpFIDtlUpdTab.Delete;
             TmpFIHdrInsTab.Delete;
             TmpFIHdrUpdTab.Delete;
             TmpScheduleTab.Delete;
             TmpFIDayTab.Delete;

             Print_message( 'Entering Generate_Requirement_FI');

             IF p_start_date IS NULL THEN

                lv_start_date := p_AsgnDtlRec.start_date;

             ELSE

                lv_start_date := p_start_date;

             END IF;

             IF p_end_date IS NULL THEN

                lv_end_date := p_AsgnDtlRec.end_date;

             ELSE

                lv_end_date := p_end_date;

             END IF;

             Print_message(
                   'Asgn_ID    - ' || p_asgndtlrec.assignment_id ||
                   ';   Start_Date - ' || lv_start_date ||
                   ';   End_Date   - ' || lv_end_date      );

             -- Find the requirement is new/modified
             IF (p_process_mode <> 'ERROR') THEN

                 Print_message( 'Req - Calling Chk_Requirement_FI_Exist');

                 lv_req_exist_flag := Chk_Requirement_FI_Exist( p_AsgnDtlRec.assignment_id);
             ELSE

                 lv_req_exist_flag := 'Y';

             END IF;

             IF lv_req_exist_flag = 'Y' THEN

                IF p_process_mode = 'GENERATE' THEN

                   -- Reverse forecast items Details FOR this assignment
                   -- which do not fall BETWEEN startdate AND END DATE

                   Print_message( 'Req - Calling Reverse_FI_Dtl');

                   Reverse_FI_Dtl(p_AsgnDtlRec.assignment_id, lv_start_date, lv_end_date,
                                  lv_return_status, x_msg_count, x_msg_data);

                   -- Reverse forecast items Header FOR this assignment
                   -- which do not fall BETWEEN startdate AND END DATE

                   Print_message( 'Req - Calling Reverse_FI_Hdr');

                   IF lv_return_status = FND_API.G_RET_STS_SUCCESS THEN

                      Reverse_FI_Hdr(p_AsgnDtlRec.assignment_id,
                                  lv_start_date, lv_end_date,
                                  lv_old_start_date, lv_old_end_date,
                                  lv_return_status, x_msg_count, x_msg_data);

                   END IF;

                END IF;

             END IF;


             IF lv_return_status = FND_API.G_RET_STS_SUCCESS THEN

                -- Get schedule data AND build day fI Records
                Print_message( 'Req - Calling Get_Assignment_Schedule');

                PA_FORECAST_ITEMS_UTILS.Get_assignment_Schedule(
                              p_AsgnDtlRec.assignment_id,
                              lv_start_date, lv_end_date,p_process_mode,
                              Tmpscheduletab,
                              lv_return_status, x_msg_count, x_msg_data);

                IF NVL(TmpScheduleTab.Count,0) = 0 THEN

                   lv_err_msg := 'No_Schedule_Records - Req';
                   RAISE NO_DATA_FOUND;

                END IF;

            END IF;


            IF lv_return_status = FND_API.G_RET_STS_SUCCESS THEN

                   Print_message( 'Req - Calling Initialize_Day_FI');

                   Initialize_Day_FI( TmpScheduleTab,
                                      p_process_mode,
                                      lv_start_date,
                                      lv_end_date,
                                      TmpFIDayTab ,
                                      lv_return_status , x_msg_count ,
                                      x_msg_data      );
            END IF;

            IF lv_return_status = FND_API.G_RET_STS_SUCCESS THEN

                     Print_message( 'Req - Calling Build_Day_FI');

                     Build_Day_FI   ( TmpScheduleTab,
                                      lv_start_date, lv_end_date ,
                                      TmpFIDayTab ,
                                      p_AsgnDtlRec.assignment_type,
                                      lv_return_status , x_msg_count ,
                                      x_msg_data      );
            END IF;


            TmpFIHdrInsTab.delete; -- Initialize
            TmpFIHdrUpdTab.delete; -- Initialize
            TmpFIDtlUpdTab.delete; -- Initialize
            TmpFIDtlUpdTab.delete; -- Initialize
            TmpDBFIHdrTab.delete;  -- Initialize
            TmpDBFIDtlTab.delete;  -- Initialize

            -- FI exists so day FI's built will have to be modified

            IF lv_req_exist_flag = 'Y' THEN

               lv_start_date := TmpFIDayTab(TmpFIDayTab.FIRST).item_date;
               lv_end_date :=   TmpFIDayTab(TmpFIDayTab.LAST).item_date;

               -- Get existing forecast items  FOR this assignment
               -- which fall BETWEEN startdate AND END DATE

               IF (p_process_mode <> 'ERROR') THEN

                  IF lv_return_status = FND_API.G_RET_STS_SUCCESS THEN

                         Print_message( 'Req - Calling Fetch_FI_Hdr');

                         Fetch_FI_Hdr (p_AsgnDtlRec.assignment_id,
                                             p_AsgnDtlRec.resource_id,
                                             lv_start_date, lv_end_date,
                                             TmpDBFIHdrTab,
                                             lv_return_status,
                                             x_msg_count, x_msg_data);
                  END IF;

               ELSE

                  TmpDBFIHdrTab := p_ErrHdrTab;

               END IF;

               -- Get existing forecast items detail FOR this
               -- assignment which fall BETWEEN startdate AND END DATE

               IF lv_return_status = FND_API.G_RET_STS_SUCCESS THEN

                  Print_message( 'Req - Calling Fetch_FI_Dtl');

                  Fetch_FI_Dtl ( p_AsgnDtlRec.assignment_id,
                                     p_AsgnDtlRec.resource_id,
                                     lv_start_date, lv_end_date,
                                     TmpDBFIDtlTab,
                                     lv_return_status,
                                     x_msg_count, x_msg_data);
               END IF;

            END IF;


            IF lv_return_status = FND_API.G_RET_STS_SUCCESS THEN

                   -- Build Forecast Item Header

                   Print_message( 'Calling Build_FI_Hdr_Req');

                   Build_FI_Hdr_Req(p_AsgnDtlRec, TmpDBFIHdrTab,
                                    TmpFIDayTab, TmpFIHdrInsTab,
                                    TmpFIHdrUpdTab, lv_return_status,
                                    x_msg_count, x_msg_data);
            END IF;


            -- Detail Processing Inputs : TmpFIDayTab, TmpDBFIDtlTab, p_asgndltrec
            -- TmpFIDayTab.Action_flag is updated by header process.
            -- IF action_flag = 'C'
                  -- check FOR change IN resource_type_code, person_billable_flag,
                     -- include IN forecast option, provisional_flag, work_type_id
                     -- If there is change mark  action_flag = 'RN';
            -- IF action_flag = 'DN'
                            --Header record has changed
                            -- Reverse detail record
                            -- Create new detail record with forecast_item_id
                            -- (generated by header record, saved IN TmpFIDayTab)
                            --  AND line_NUMBER = 1;
            -- IF action_flag = 'RN'
                            -- Change IN detail record values
                            -- Reverse detail record
                            -- create new detail record with same  forecast_item_id
                                    -- AND line_NUMBER = max(line_NUMBER) + 1;
            -- IF action_flag = 'N'
                            -- Create new detail record with forecast_item_id
                            -- (generated by header record, saved  IN TmpFIDayTab)
                            --  AND line_NUMBER = 1;

            IF lv_return_status = FND_API.G_RET_STS_SUCCESS THEN

                   Print_message( 'Calling Build_FI_Dtl_Req');

                   Build_FI_Dtl_Req(p_AsgnDtlRec, TmpDBFIDtlTab,
                                    TmpFIDayTab, TmpFIDtlInsTab,
                                    TmpFIDtlUpdTab,
                                    lv_return_status,
                                    x_msg_count, x_msg_data);
            END IF;

            IF lv_return_status = FND_API.G_RET_STS_SUCCESS THEN

                   IF NVL(TmpFIHdrInsTab.COUNT,0) > 0 THEN

                      Print_message( 'Calling PA_FORECAST_HDR_PKG.Insert_Rows');

                      PA_FORECAST_HDR_PKG.Insert_Rows(
                                                  TmpFIHdrInsTab,
                                                  lv_return_status,
                                                  x_msg_count,
                                                  x_msg_data);
                   END IF;

            END IF;

            IF lv_return_status = FND_API.G_RET_STS_SUCCESS THEN

                   IF NVL(TmpFIHdrUpdTab.COUNT,0) > 0 THEN

                      Print_message( 'Calling PA_FORECAST_HDR_PKG.Update_Rows');

                      PA_FORECAST_HDR_PKG.Update_Rows(TmpFIHdrUpdTab,
                                                      lv_return_status,
                                                      x_msg_count,
                                                      x_msg_data);

                    END IF;

            END IF;

            IF lv_return_status = FND_API.G_RET_STS_SUCCESS THEN

                   IF NVL(TmpFIDtlInsTab.COUNT,0) > 0 THEN

                      Print_message( 'Calling PA_FORECAST_DTLS_PKG.Insert_Rows');

                      PA_FORECAST_DTLS_PKG.Insert_Rows(TmpFIDtlInsTab,
                                                       lv_return_status,
                                                       x_msg_count,
                                                       x_msg_data);

                   END IF;

            END IF;

            IF lv_return_status = FND_API.G_RET_STS_SUCCESS THEN

                  IF NVL(TmpFIDtlUpdTab.COUNT,0) > 0 THEN

                     Print_message( 'Calling PA_FORECAST_DTLS_PKG.Update_Rows');

                     PA_FORECAST_DTLS_PKG.Update_Rows(TmpFIDtlUpdTab,
                                                      lv_return_status, x_msg_count, x_msg_data);

                  END IF;

            END IF;

            IF lv_return_status = FND_API.G_RET_STS_SUCCESS THEN

                  IF (p_process_mode = 'GENERATE') THEN

                     Print_message(
                                          'Calling PA_FORECAST_HDR_PKG.Update_Schedule_Rows');

                     PA_FORECAST_HDR_PKG.Update_Schedule_Rows( TmpScheduleTab,
                                                               lv_return_status,
                                                               x_msg_count,
                                                               x_msg_data);

                  END IF;

            END IF;

            Print_message(
                         'Leaving Generate_Requirement_FI');

            x_return_status := lv_return_status;

            PA_DEBUG.Reset_Err_Stack;

        EXCEPTION

             WHEN NO_DATA_FOUND THEN
                  print_message('Failed in Generate_requirement_FI api');
                  print_message('SQLCODE'||sqlcode||sqlerrm);

                IF lv_err_msg = 'No_Schedule_Records - Req' THEN

                    x_msg_count     := 1;
                    x_msg_data      := 'No Schedule Records for Req ';
                    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
                    FND_MSG_PUB.add_exc_msg
                        (p_pkg_name   =>
                                'PA_FORECASTITEM_PVT.Generate_Requirement_FI',
                         p_procedure_name => PA_DEBUG.G_Err_Stack);

		               If x_msg_count = 1 THEN
				              pa_interface_utils_pub.get_messages
				                (p_encoded        => FND_API.G_TRUE,
					               p_msg_index      => 1,
					               p_msg_count      => x_msg_count,
					               p_msg_data       => x_msg_data,
					               p_data           => l_data,
					               p_msg_index_out  => l_msg_index_out );
						       x_msg_data := l_data ; -- 4537865
		               End If;

                    Print_message(x_msg_data);

                    RAISE;

                ELSE

                  x_msg_count     := 1;
                  x_msg_data      := sqlerrm;
                  x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

                  FND_MSG_PUB.add_exc_msg
                      (p_pkg_name   =>
                              'PA_FORECASTITEM_PVT.Generate_Requirement_FI',
                       p_procedure_name => PA_DEBUG.G_Err_Stack);

		               If x_msg_count = 1 THEN
				              pa_interface_utils_pub.get_messages
				                (p_encoded        => FND_API.G_TRUE,
					               p_msg_index      => 1,
					               p_msg_count      => x_msg_count,
					               p_msg_data       => x_msg_data,
					               p_data           => l_data, -- 4537865
					               p_msg_index_out  => l_msg_index_out );
							x_msg_data := l_data ; -- 4537865
		               End If;
                  Print_message(x_msg_data);

                  RAISE;


               END IF;



             WHEN OTHERS THEN

                  x_msg_count     := 1;
                  x_msg_data      := sqlerrm;
                  x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

                  FND_MSG_PUB.add_exc_msg
                      (p_pkg_name   =>
                              'PA_FORECASTITEM_PVT.Generate_Requirement_FI',
                       p_procedure_name => PA_DEBUG.G_Err_Stack);

		               If x_msg_count = 1 THEN
				              pa_interface_utils_pub.get_messages
				                (p_encoded        => FND_API.G_TRUE,
					               p_msg_index      => 1,
					               p_msg_count      => x_msg_count,
					               p_msg_data       => x_msg_data,
					               p_data           => l_data , -- 4537865
					               p_msg_index_out  => l_msg_index_out );
							x_msg_data := l_data ; -- 4537865
		               End If;
                  Print_message(x_msg_data);

                  RAISE;


       END  Generate_Requirement_FI;
/* ---------------------------------------------------------------------
|   Function   :   Chk_Requirement_FI_Exist
|   Purpose    :   To check IF forecast item FOR requirement record exists
|   Parameters :   p_assignment_id  - Input Assignment ID
|                  p_FI_Type        - Forecast Item Type
|                                     'R' - Requirement
|                                     'A' - Assignment
+----------------------------------------------------------------------*/

       FUNCTION  Chk_Requirement_FI_Exist(
                     p_assignment_id  IN    NUMBER)

                 RETURN VARCHAR2 IS

             lv_exist_flag   VARCHAR2(1) := 'N';
	           l_msg_index_out	            NUMBER;

       BEGIN

             Print_message(
                         'Entering Chk_Requirement_FI_Exist');

             BEGIN
                   SELECT 'Y'
                   INTO lv_exist_flag
                   FROM DUAL
                   WHERE EXISTS (SELECT NULL
                                 FROM   pa_forecast_items
                                 WHERE  assignment_id = p_assignment_id
                                 AND    delete_flag = 'N');

             EXCEPTION

                   WHEN NO_DATA_FOUND THEN
                        lv_exist_flag   := 'N';

             END;

             Print_message(
                         'Leaving Chk_Requirement_FI_Exist');

             RETURN(lv_exist_flag);


       END Chk_Requirement_FI_Exist;

/* ---------------------------------------------------------------------
|   Procedure  :   Initialize_Day_FI
|   Purpose    :   To initialize forecast item DATEs that are to be built
|                  based on the schedule(requirement/assignment/resource) tab
|   Parameters :   p_ScheduleTab       - Schedule Record Table FOR
|                                       (requirement/assignment/resource)
|                  This tab will have
|                  i) GENERATE mode    : New/only those which have been modified
|                 ii) RECALCULATE mode : Those records which fall under the
|                                        given period
|                iii) ERROR mode       : Those records FOR which Forecast items
|                                         have errored out
|                  x_FIDayTab          - Initialzied item DATEs FOR which
|                                        forecast item is to be generated
|                  x_return_status     -
|                  x_msg_count         -
|                  x_msg_data          -
+----------------------------------------------------------------------*/

       PROCEDURE Initialize_Day_FI(
                 p_ScheduleTab       IN   PA_FORECAST_GLOB.SCHEDULETABTYP,
                 p_Process_Mode      IN   VARCHAR2,
                 p_Start_Date        IN   DATE,
                 p_End_Date          IN   DATE,
                 x_FIDayTab          OUT  NOCOPY PA_FORECAST_GLOB.FIDaytabtyp, /* 2674619 - Nocopy change */
                 x_return_status     OUT  NOCOPY VARCHAR2, -- 4537865 Added nocopy
                 x_msg_count         OUT  NOCOPY NUMBER, -- 4537865 Added nocopy
                 x_msg_data          OUT  NOCOPY VARCHAR2) IS -- 4537865 Added nocopy


	           l_msg_index_out	            NUMBER;
		   l_data VARCHAR2(2000); -- 4537865
             li_no_of_days         NUMBER;
             ld_temp_DATE          DATE;
             ld_act_start_date     DATE;
             ld_act_end_date       DATE;
             TmpFIDayTab           PA_FORECAST_GLOB.FIDayTabTyp;
             lv_index              NUMBER;
             lv_return_status      VARCHAR2(30);
             lv_proc_flag          VARCHAR2(1);

       BEGIN

             lv_return_status := FND_API.G_RET_STS_SUCCESS;

             PA_DEBUG.Init_err_stack(
                       'PA_FORECASTITEM_PVT.Initialize_Day_FI');
             TmpFIDayTab.Delete;

             Print_message('Entering Initialize_Day_FI');

             TmpFIDayTab.Delete;


             IF (p_process_mode IN ('ERROR', 'RECALCULATE')) THEN


                 li_no_of_days := trunc(p_end_date) - trunc(p_start_date) + 1;
                 ld_temp_DATE  := p_start_date;


                 FOR i IN 1 .. li_no_of_days LOOP
                     TmpFIDayTab(i).forecast_item_id := NULL;
                     TmpFIDayTab(i).item_date := ld_temp_DATE;
                     TmpFIDayTab(i).item_quantity := 0;
                     TmpFIDayTab(i).status_code := NULL;
                     TmpFIDayTab(i).project_org_id := NULL;
                     TmpFIDayTab(i).expenditure_org_id := NULL;
                     TmpFIDayTab(i).project_id := NULL;
                     TmpFIDayTab(i).resource_id := NULL;
                     TmpFIDayTab(i).expenditure_organization_id := NULL;
                     TmpFIDayTab(i).work_type_id := NULL;
                     TmpFIDayTab(i).person_billable_flag := 'N';
                     TmpFIDayTab(i).tp_amount_type := NULL;
                     TmpFIDayTab(i).provisional_flag := NULL;
                     TmpFIDayTab(i).include_in_forecast := NULL;
                     TmpFIDayTab(i).action_flag := 'N';
                     TmpFIDayTab(i).JOB_ID := NULL;
                     TmpFIDayTab(i).TP_AMOUNT_TYPE := NULL;
                     TmpFIDayTab(i).OVERPROVISIONAL_QTY := NULL;
                     TmpFIDayTab(i).OVER_PROV_CONF_QTY := NULL;
                     TmpFIDayTab(i).CONFIRMED_QTY := NULL;
                     TmpFIDayTab(i).PROVISIONAL_QTY := NULL;
                     TmpFIDayTab(i).asgmt_sys_status_code := NULL;
                     TmpFIDayTab(i).asgmt_confirmed_quantity := NULL;
                     TmpFIDayTab(i).asgmt_provisional_quantity := NULL;
                     TmpFIDayTab(i).capacity_quantity := NULL;
                     TmpFIDayTab(i).overcommitment_quantity :=  NULL;
                     TmpFIDayTab(i).availability_quantity :=  NULL;
                     TmpFIDayTab(i).overcommitment_flag := NULL;
                     TmpFIDayTab(i).availability_flag := NULL;
                     ld_temp_DATE := ld_temp_DATE + 1;
                 END LOOP;

             ELSE


                 lv_index := 1;

                 ld_temp_date := p_ScheduleTab(p_ScheduleTab.FIRST).start_date;

               If (nvl(p_scheduletab.count,0) > 0) then
                 FOR i IN p_ScheduleTab.FIRST..p_ScheduleTab.LAST LOOP

                     IF p_ScheduleTab.EXISTS(i) then
                     IF p_ScheduleTab(i).end_date < ld_temp_date THEN

                        lv_proc_flag := 'T';

                     ELSIF (p_ScheduleTab(i).start_date <= ld_temp_date)
                           AND (p_ScheduleTab(i).end_date >= ld_temp_date) THEN

                        ld_act_start_date := ld_temp_date;
                        ld_act_end_date := p_ScheduleTab(i).end_date;
                        lv_proc_flag := 'F';

                     ELSE

                        ld_act_start_date := p_ScheduleTab(i).start_date;
                        ld_act_end_date := p_ScheduleTab(i).end_date;
                        lv_proc_flag := 'F';

                     END IF;

                     IF lv_proc_flag = 'F' THEN

                        li_no_of_days := trunc(ld_act_end_date) -
                                            trunc(ld_act_start_date)  + 1;
                        li_no_of_days := trunc(li_no_of_days);
                        ld_temp_DATE := ld_act_start_date;

                        FOR j IN 1..li_no_of_days LOOP

                            TmpFIDayTab(lv_index).forecast_item_id := NULL;
                            TmpFIDayTab(lv_index).item_date := ld_temp_DATE;
                            TmpFIDayTab(lv_index).item_quantity := 0;
                            TmpFIDayTab(lv_index).status_code := NULL;
                            TmpFIDayTab(lv_index).project_org_id := NULL;
                            TmpFIDayTab(lv_index).project_id  := NULL;
                            TmpFIDayTab(lv_index).expenditure_org_id := NULL;
                            TmpFIDayTab(lv_index).resource_id := NULL;
                            TmpFIDayTab(lv_index).expenditure_organization_id := NULL;
                            TmpFIDayTab(lv_index).work_type_id := NULL;
                            TmpFIDayTab(lv_index).person_billable_flag := 'N';
                            TmpFIDayTab(lv_index).tp_amount_type := NULL;
                            TmpFIDayTab(lv_index).provisional_flag := NULL;
                            TmpFIDayTab(lv_index).action_flag := 'N';
                            TmpFIDayTab(lv_index).JOB_ID := NULL;
                            TmpFIDayTab(lv_index).OVERPROVISIONAL_QTY := NULL;
                            TmpFIDayTab(lv_index).OVER_PROV_CONF_QTY := NULL;
                            TmpFIDayTab(lv_index).CONFIRMED_QTY := NULL;
                            TmpFIDayTab(lv_index).PROVISIONAL_QTY := NULL;
                            TmpFIDayTab(lv_index).asgmt_sys_status_code := NULL;
                            TmpFIDayTab(lv_index).asgmt_confirmed_quantity := NULL;
                            TmpFIDayTab(lv_index).asgmt_provisional_quantity := NULL;
                            TmpFIDayTab(lv_index).capacity_quantity := NULL;
                            TmpFIDayTab(lv_index).overcommitment_quantity :=  NULL;
                            TmpFIDayTab(lv_index).availability_quantity :=  NULL;
                            TmpFIDayTab(lv_index).overcommitment_flag := NULL;
                            TmpFIDayTab(lv_index).availability_flag := NULL;
                            ld_temp_DATE := ld_temp_DATE + 1;
                            lv_index := lv_index + 1;

                        END LOOP;

                     END IF;
                 END IF;
                 END LOOP;
               end if;
             END IF;

             x_FIDayTab:= TmpFIDayTab;


             x_return_status := lv_return_status;

             PA_DEBUG.Reset_Err_Stack;

             Print_message('Leaving Initialize_Day_FI');

        EXCEPTION

             WHEN OTHERS THEN
                  print_message('Failed in Intialize_day_FI api');
                  print_message('SQLCODE'||sqlcode||sqlerrm);

                  x_msg_count     := 1;
                  x_msg_data      := sqlerrm;
                  x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

		               If x_msg_count = 1 THEN
				              pa_interface_utils_pub.get_messages
				                (p_encoded        => FND_API.G_TRUE,
					               p_msg_index      => 1,
					               p_msg_count      => x_msg_count,
					               p_msg_data       => x_msg_data,
					               p_data           => l_data , -- 4537865
					               p_msg_index_out  => l_msg_index_out );
						       x_msg_data := l_data ; -- 4537865
		               End If;

                  FND_MSG_PUB.add_exc_msg
                      (p_pkg_name   =>
                              'PA_FORECASTITEM_PVT.Initialize_Day_FI',
                       p_procedure_name => PA_DEBUG.G_Err_Stack);

                  Print_message(x_msg_data);

                  RAISE;


       END Initialize_Day_FI;

/* ---------------------------------------------------------------------
|   Procedure  :   Build_Day_FI
|   Purpose    :   To populate quantity, status_code onto forecast item DATEs
|                  FROM schedule tab
|   Parameters :   p_ScheduleTab       - Schedule Record Table for
|                                       (requirement/assignment/resource)
|                  This tab will have
|                  i) GENERATE mode    : New/only those which have been modified
|                 ii) RECALCULATE mode : Those records which fall under the
|                                        given period
|                iii) ERROR mode       : Those records FOR which Forecast items
|                                         have errored out
|                  p_start_date        - Start DATE FOR Forecast Item Generation
|                  p_end_date          - END DATE FOR Forecast Item Generation
|                  p_FIDayTab          - This tab will contain only those
|                                        item_dates FOR which forecasting is to
|                                        be done.
|                                        Item_quantity, Requirement/Assignment
|                                        status _code are populated FROM
|                                        Schedule Tab
|                  x_return_status     -
|                  x_msg_count         -
|                  x_msg_data          -
+----------------------------------------------------------------------*/

       PROCEDURE Build_Day_FI(
                 p_ScheduleTab     IN      PA_FORECAST_GLOB.SCHEDULETABTYP,
                 p_start_date      IN      DATE,
                 p_end_date        IN      DATE,
                 p_FIDayTab        IN OUT NOCOPY PA_FORECAST_GLOB.FIDaytabtyp, /* 2674619 - Nocopy change */
                 p_AsgType         IN      VARCHAR2,
                 x_return_status   OUT NOCOPY    VARCHAR2, -- 4537865 Added nocopy
                 x_msg_count       OUT NOCOPY    NUMBER, -- 4537865 Added nocopy
                 x_msg_data        OUT NOCOPY    VARCHAR2) IS -- 4537865 Added nocopy

	           l_msg_index_out	            NUMBER;
		   l_data VARCHAR2(2000); -- 4537865
             li_no_of_days      NUMBER := 0;
             li_status          VARCHAR2(5):= Null;
             ld_temp_DATE       DATE;
             li_current_pos     NUMBER;
             li_last_pos        NUMBER;
             lb_found           BOOLEAN := FALSE;
             lv_cancel_flag     VARCHAR2(3);
             lv_prov_flag       VARCHAR2(3);
             TmpFIDayTab        PA_FORECAST_GLOB.FIDaytabtyp;
             lv_return_status  VARCHAR2(30);
             li_cur_item_quantity NUMBER;
       BEGIN


             lv_return_status := FND_API.G_RET_STS_SUCCESS;
             Print_message('Entering Build_Day_FI');

             PA_DEBUG.Init_err_stack( 'PA_FORECASTITEM_PVT.Build_Day_FI');

             TmpFIDayTab.Delete;
             TmpFIDayTab := p_FIDayTab;


             li_no_of_days := trunc(p_end_date) - trunc(p_start_date) + 1;
             ld_temp_DATE  := p_start_date;

             FOR i IN 1 .. li_no_of_days LOOP
                 TmpFIDayTab(i).item_date := ld_temp_DATE;
                 TmpFIDayTab(i).item_quantity := 0;
                 TmpFIDayTab(i).action_flag := 'N';
                 TmpFIDayTab(i).expenditure_org_id := NULL;
                 TmpFIDayTab(i).project_id := NULL;
                 TmpFIDayTab(i).resource_id := NULL;
                 TmpFIDayTab(i).expenditure_organization_id := NULL;
                 TmpFIDayTab(i).project_org_id := NULL;
                 TmpFIDayTab(i).JOB_ID := NULL;
                 TmpFIDayTab(i).TP_AMOUNT_TYPE := NULL;
                 TmpFIDayTab(i).OVERPROVISIONAL_QTY := NULL;
                 TmpFIDayTab(i).OVER_PROV_CONF_QTY := NULL;
                 TmpFIDayTab(i).CONFIRMED_QTY := NULL;
                 TmpFIDayTab(i).PROVISIONAL_QTY := NULL;
                 TmpFIDayTab(i).asgmt_sys_status_code := NULL;
                 TmpFIDayTab(i).asgmt_confirmed_quantity := NULL;
                 TmpFIDayTab(i).asgmt_provisional_quantity := NULL;
                 TmpFIDayTab(i).capacity_quantity := NULL;
                 TmpFIDayTab(i).overcommitment_quantity :=  NULL;
                 TmpFIDayTab(i).availability_quantity :=  NULL;
                 TmpFIDayTab(i).overcommitment_flag := NULL;
                 TmpFIDayTab(i).availability_flag := NULL;
                 ld_temp_DATE := ld_temp_DATE + 1;
             END LOOP;

             li_current_pos := p_scheduletab.FIRST;
             li_last_pos := p_scheduletab.FIRST;

             Print_message('AsgType :'|| p_AsgType);

             Print_message('StatusCode :'||
                            p_scheduletab(li_current_pos).status_code);
             Print_message('After StatusCode');

             IF (p_AsgType = 'OPEN_ASGMT') THEN

                lv_cancel_flag := PA_ASSIGNMENT_UTILS.Is_Open_Asgmt_Cancelled (
                                     p_scheduletab(li_current_pos).status_code,
                                          p_AsgType);

                Print_message('CancelFlag:'||
                                                    lv_cancel_flag);

             ELSIF (p_AsgType = 'STAFFED_ASGMT') THEN

                lv_cancel_flag := PA_ASSIGNMENT_UTILS.Is_Staffed_Asgmt_Cancelled (
                                          p_scheduletab(li_current_pos).status_code,
                                          p_AsgType);

                Print_message('CancelFlag:'||
                                                    lv_cancel_flag);
             END IF;

             IF p_AsgType in ('OPEN_ASGMT', 'STAFFED_ASGMT')
                AND P_DEBUG_MODE = 'Y' THEN -- Bug 4355576

                lv_prov_flag := PA_ASSIGNMENT_UTILS.Is_Provisional_Status(
                                          p_scheduletab(li_current_pos).status_code,
                                          p_Asgtype);

                Print_message('ProvFlag:'|| lv_prov_flag);

             END IF;

             IF TmpFIDayTab.count <> 0 then

             FOR j IN TmpFIDayTab.FIRST..TmpFIDayTab.LAST LOOP

                 IF TmpFIDayTab.EXISTS(j) then
                 IF NVL(p_scheduletab.COUNT,0) <> 0 Then

                    lb_found := FALSE;

                    --print_message('Before p_scheduletab(li_last_pos).');
                    IF (trunc(TmpFIDayTab(j).item_date) NOT BETWEEN
                          trunc(p_scheduletab(li_last_pos).start_date) AND
                          trunc(p_scheduletab(li_last_pos).end_date)) THEN

--1993136                       li_last_pos := li_current_pos;
                        li_last_pos := p_scheduletab.first;

                       IF (p_AsgType = 'OPEN_ASGMT') THEN

                          lv_cancel_flag := PA_ASSIGNMENT_UTILS.Is_Open_Asgmt_Cancelled (
                                                    p_scheduletab(li_last_pos).status_code,
                                                    p_AsgType);

                          Print_message('CancelFlag:'||
                                                    lv_cancel_flag);

                       ELSIF (p_AsgType = 'STAFFED_ASGMT') THEN

                          lv_cancel_flag := PA_ASSIGNMENT_UTILS.Is_Staffed_Asgmt_Cancelled (
                                                    p_scheduletab(li_last_pos).status_code,
                                                    p_AsgType);

                           Print_message('CancelFlag:'||
                                                    lv_cancel_flag);

                       END IF;

                       IF p_AsgType in ('OPEN_ASGMT', 'STAFFED_ASGMT')
                          AND P_DEBUG_MODE = 'Y' THEN -- Bug 4355576

                          lv_prov_flag := PA_ASSIGNMENT_UTILS.Is_Provisional_Status(
                                                     p_scheduletab(li_last_pos).status_code,
                                                     p_Asgtype);

                           Print_message('ProvFlag:'||
                                                      lv_prov_flag);

                       END IF;

                    END IF;

                    IF (lv_cancel_flag = 'Y') THEN

                        TmpFIDayTab(j).action_flag := 'D';

                    END IF;


                    FOR i IN li_last_pos..p_scheduletab.LAST LOOP
                        IF p_scheduletab.exists(i) then
                        IF (trunc(TmpFIDayTab(j).item_date) BETWEEN
                              trunc(p_scheduletab(i).start_date) AND
                              trunc(p_scheduletab(i).end_date)) THEN

                            ld_temp_DATE := TmpFIDayTab(j).item_date;


                            IF TO_CHAR(ld_temp_DATE, 'DY','NLS_DATE_LANGUAGE=AMERICAN') = 'MON' THEN

                               li_cur_item_quantity := p_scheduletab(i).monday_hours;

                            ELSIF TO_CHAR(ld_temp_DATE, 'DY','NLS_DATE_LANGUAGE=AMERICAN') = 'TUE' THEN

                               li_cur_item_quantity := p_scheduletab(i).tuesday_hours;

                            ELSIF TO_CHAR(ld_temp_DATE, 'DY','NLS_DATE_LANGUAGE=AMERICAN') = 'WED' THEN

                               li_cur_item_quantity := p_scheduletab(i).wednesday_hours;

                            ELSIF TO_CHAR(ld_temp_DATE, 'DY','NLS_DATE_LANGUAGE=AMERICAN') = 'THU' THEN

                               li_cur_item_quantity := p_scheduletab(i).thursday_hours;

                            ELSIF TO_CHAR(ld_temp_DATE, 'DY','NLS_DATE_LANGUAGE=AMERICAN') = 'FRI' THEN

                               li_cur_item_quantity := p_scheduletab(i).friday_hours;

                            ELSIF TO_CHAR(ld_temp_DATE, 'DY','NLS_DATE_LANGUAGE=AMERICAN') = 'SAT' THEN

                               li_cur_item_quantity := p_scheduletab(i).saturday_hours;

                            ELSIF TO_CHAR(ld_temp_DATE, 'DY','NLS_DATE_LANGUAGE=AMERICAN') = 'SUN' THEN

                               li_cur_item_quantity := p_scheduletab(i).sunday_hours;

                            END IF;

                            TmpFIDayTab(j).item_quantity := TmpFIDayTab(j).item_quantity + li_cur_item_quantity;
                            TmpFIDayTab(j).asgmt_sys_status_code := p_scheduletab(i).system_status_code;
                            TmpFIDayTab(j).status_code := p_scheduletab(i).status_code;

                            --print_message('TmpFIDayTab(j).asgmt_sys_status_code: ' || TmpFIDayTab(j).asgmt_sys_status_code);

                            if (TmpFIDayTab(j).asgmt_sys_status_code = 'STAFFED_ASGMT_PROV') then
                                TmpFIDayTab(j).provisional_flag := 'Y';
                                TmpFIDayTab(j).asgmt_provisional_quantity :=
                                   NVL(TmpFIDayTab(j).asgmt_provisional_quantity,0) + li_cur_item_quantity;
                            elsif (TmpFIDayTab(j).asgmt_sys_status_code = 'STAFFED_ASGMT_CONF') then
                                TmpFIDayTab(j).provisional_flag := 'N';
                                TmpFIDayTab(j).asgmt_confirmed_quantity :=
                                   NVL(TmpFIDayTab(j).asgmt_confirmed_quantity,0) + li_cur_item_quantity;
                            else
                                TmpFIDayTab(j).provisional_flag := 'N';
                            end if;
/*
                            print_message('-------------------------------');
                            print_message('TmpFIDayTab(j).item_date: ' || TmpFIDayTab(j).item_date);
                            Print_Message('TmpFIDayTab(j).asgmt_confirmed_quantity: ' || TmpFIDayTab(j).asgmt_confirmed_quantity);
                            Print_Message('TmpFIDayTab(j).asgmt_provisional_quantity: ' || TmpFIDayTab(j).asgmt_provisional_quantity);
                            Print_Message('TmpFIDayTab(j).provisional_flag: ' || TmpFIDayTab(j).provisional_flag);
                            Print_Message('li_cur_item_quantity: ' || li_cur_item_quantity);
                            Print_message('StatusCode :'|| p_scheduletab(i).status_code);
                            Print_message('SystemStatusCode :'|| p_scheduletab(i).system_status_code);
                            Print_message('Schedule ID: ' || p_scheduletab(i).schedule_id);
                            Print_message('Start Date :'|| p_scheduletab(i).start_date);
                            Print_message('End Date :'|| p_scheduletab(i).end_date);
*/
                        END IF;

                        IF trunc(TmpFIDayTab(j).item_date) <
                                 trunc(p_scheduletab(i).start_date) THEN

                           lb_found := TRUE;
                           li_current_pos := i;

                        END IF;

                        EXIT WHEN lb_found;

                        END IF;
                    END LOOP;

                 END IF;
                 END IF;
             END LOOP;
             END IF;

             p_FIDayTab := TmpFIDayTab;

             Print_message('Leaving Build_Day_FI');

             PA_DEBUG.Reset_Err_Stack;

             x_return_status := lv_return_status;

        EXCEPTION

             WHEN OTHERS THEN
                  print_message('Failed in Build_Day_FI api');
                  print_message('SQLCODE'||sqlcode||sqlerrm);
                  x_msg_count     := 1;
                  x_msg_data      := sqlerrm;
                  x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

                  FND_MSG_PUB.add_exc_msg
                      (p_pkg_name   =>
                              'PA_FORECASTITEM_PVT.Build_Day_FI',
                       p_procedure_name => PA_DEBUG.G_Err_Stack);

		               If x_msg_count = 1 THEN
				              pa_interface_utils_pub.get_messages
				                (p_encoded        => FND_API.G_TRUE,
					               p_msg_index      => 1,
					               p_msg_count      => x_msg_count,
					               p_msg_data       => x_msg_data,
					               p_data           => l_data , -- 4537865
					               p_msg_index_out  => l_msg_index_out );
							x_msg_data := l_data ; -- 4537865
		               End If;
                  Print_message(x_msg_data);

                  RAISE;

       END Build_Day_FI;

/* ---------------------------------------------------------------------
|   Procedure  :   Reverse_FI_Hdr
|   Purpose    :   To reverse the existing forecast items (Requirement ,
|                  Assignment ) which do not fall IN the given DATE range.
|                  Also it will RETURN the start_date AND end_date of the
|                  previous run (existing IN the database)
|                  This is required FOR regenerating resource
|                  unassigned time
|   Parameters :   p_assignment_id  - Input Assignment ID
|                  p_start_date     - Current Start DATE FOR forecast item
|                  p_end_date       - Current END DATE FOR forecast item
|                  x_old_start_date - Previous Start DATE FOR forecast item
|                  x_old_end_date   - Previous END DATE FOR forecast item
|                  x_return_status     -
|                  x_msg_count         -
|                  x_msg_data          -
+----------------------------------------------------------------------*/
       PROCEDURE  Reverse_FI_Hdr(
                  p_assignment_id     IN     NUMBER,
                  p_start_date        IN     DATE,
                  p_end_date          IN     DATE,
                  x_old_start_date    IN OUT NOCOPY DATE, -- 4537865
                  x_old_end_date      IN OUT NOCOPY DATE, -- 4537865
                  x_return_status     OUT    NOCOPY VARCHAR2, -- 4537865
                  x_msg_count         OUT    NOCOPY NUMBER, -- 4537865
                  x_msg_data          OUT    NOCOPY VARCHAR2) IS -- 4537865

	           l_msg_index_out	            NUMBER;
		   l_data			    VARCHAR2(2000) ; -- 4537865
             forecast_item_id_tab                PA_FORECAST_GLOB.NumberTabTyp;
             forecast_item_type_tab              PA_FORECAST_GLOB.VCTabTyp;
             project_org_id_tab                  PA_FORECAST_GLOB.NumberTabTyp;
             expenditure_org_id_tab              PA_FORECAST_GLOB.NumberTabTyp;
             expenditure_orgn_id_tab             PA_FORECAST_GLOB.NumberTabTyp;
             project_organization_id_tab         PA_FORECAST_GLOB.NumberTabTyp;
             project_id_tab                      PA_FORECAST_GLOB.NumberTabTyp;
             project_type_class_tab              PA_FORECAST_GLOB.VCTabTyp;
             person_id_tab                       PA_FORECAST_GLOB.NumberTabTyp;
             resource_id_tab                     PA_FORECAST_GLOB.NumberTabTyp;
             borrowed_flag_tab                   PA_FORECAST_GLOB.VC1TabTyp;
             assignment_id_tab                   PA_FORECAST_GLOB.NumberTabTyp;
             item_date_tab                       PA_FORECAST_GLOB.DateTabTyp;
             item_uom_tab                        PA_FORECAST_GLOB.VCTabTyp;
             item_quantity_tab                   PA_FORECAST_GLOB.NumberTabTyp;
             pvdr_period_set_name_tab            PA_FORECAST_GLOB.VCTabTyp;
             pvdr_pa_period_name_tab             PA_FORECAST_GLOB.VCTabTyp;
             pvdr_gl_period_name_tab             PA_FORECAST_GLOB.VCTabTyp;
             rcvr_period_set_name_tab            PA_FORECAST_GLOB.VCTabTyp;
             rcvr_pa_period_name_tab             PA_FORECAST_GLOB.VCTabTyp;
             rcvr_gl_period_name_tab             PA_FORECAST_GLOB.VCTabTyp;
             global_exp_period_end_date_tab      PA_FORECAST_GLOB.DateTabTyp;
             expenditure_type_tab                PA_FORECAST_GLOB.VCTabTyp;
             expenditure_type_class_tab          PA_FORECAST_GLOB.VCTabTyp;
             cost_rejection_code_tab             PA_FORECAST_GLOB.VCTabTyp;
             rev_rejection_code_tab              PA_FORECAST_GLOB.VCTabTyp;
             tp_rejection_code_tab               PA_FORECAST_GLOB.VCTabTyp;
             burden_rejection_code_tab           PA_FORECAST_GLOB.VCTabTyp;
             other_rejection_code_tab            PA_FORECAST_GLOB.VCTabTyp;
             delete_flag_tab                     PA_FORECAST_GLOB.VC1TabTyp;
             error_flag_tab                      PA_FORECAST_GLOB.VC1TabTyp;
             provisional_flag_tab                PA_FORECAST_GLOB.VC1TabTyp;
             JOB_ID_tab           PA_FORECAST_GLOB.NumberTabTyp;
             TP_AMOUNT_TYPE_tab           PA_FORECAST_GLOB.VCTabTyp;
             OVERPROVISIONAL_QTY_tab           PA_FORECAST_GLOB.NumberTabTyp;
             OVER_PROV_CONF_QTY_tab           PA_FORECAST_GLOB.NumberTabTyp;
             CONFIRMED_QTY_tab           PA_FORECAST_GLOB.NumberTabTyp;
             PROVISIONAL_QTY_tab           PA_FORECAST_GLOB.NumberTabTyp;
             asgmt_sys_status_code_tab           PA_FORECAST_GLOB.VCTabTyp;
             capacity_quantity_tab               PA_FORECAST_GLOB.NumberTabTyp;
             overcommitment_quantity_tab         PA_FORECAST_GLOB.NumberTabTyp;
             availability_quantity_tab           PA_FORECAST_GLOB.NumberTabTyp;
             overcommitment_flag_tab             PA_FORECAST_GLOB.VC1TabTyp;
             availability_flag_tab               PA_FORECAST_GLOB.VC1TabTyp;

             TmpUpdTab                           PA_FORECAST_GLOB.FIHdrTabTyp;
             lv_return_status  VARCHAR2(30);

       BEGIN

             lv_return_status := FND_API.G_RET_STS_SUCCESS;

             Print_message('Entering Reverse_FI_Hdr');

             PA_DEBUG.Init_err_stack(
                       'PA_FORECASTITEM_PVT.Reverse_FI_Hdr');

             forecast_item_id_tab.delete;
             forecast_item_type_tab.delete;
             project_org_id_tab.delete;
             expenditure_org_id_tab.delete;
             expenditure_orgn_id_tab.delete;
             project_organization_id_tab.delete;
             project_id_tab.delete;
             project_type_class_tab.delete;
             person_id_tab.delete;
             resource_id_tab.delete;
             borrowed_flag_tab.delete;
             assignment_id_tab.delete;
             item_date_tab.delete;
             item_uom_tab.delete;
             item_quantity_tab.delete;
             pvdr_period_set_name_tab.delete;
             pvdr_pa_period_name_tab.delete;
             pvdr_gl_period_name_tab.delete;
             rcvr_period_set_name_tab.delete;
             rcvr_pa_period_name_tab.delete;
             rcvr_gl_period_name_tab.delete;
             global_exp_period_end_date_tab.delete;
             expenditure_type_tab.delete;
             expenditure_type_class_tab.delete;
             cost_rejection_code_tab.delete;
             rev_rejection_code_tab.delete;
             tp_rejection_code_tab.delete;
             burden_rejection_code_tab.delete;
             other_rejection_code_tab.delete;
             delete_flag_tab.delete;
             error_flag_tab.delete;
             provisional_flag_tab.delete;
             JOB_ID_tab.delete;
             TP_AMOUNT_TYPE_tab.delete;
             OVERPROVISIONAL_QTY_tab.delete;
             OVER_PROV_CONF_QTY_tab.delete;
             CONFIRMED_QTY_tab.delete;
             PROVISIONAL_QTY_tab.delete;
             asgmt_sys_status_code_tab.delete;
             capacity_quantity_tab.delete;
             overcommitment_quantity_tab.delete;
             availability_quantity_tab.delete;
             overcommitment_flag_tab.delete;
             availability_flag_tab.delete;

             TmpUpdtab.delete;

             SELECT   forecast_item_id, forecast_item_type,
                      project_org_id , expenditure_org_id,
                      project_organization_id, expenditure_organization_id ,
                      project_id, project_type_class, person_id ,
                      resource_id, borrowed_flag, assignment_id,
                      item_date, item_uom, item_quantity,
                      pvdr_period_set_name, pvdr_pa_period_name,
                      pvdr_gl_period_name, rcvr_period_set_name,
                      rcvr_pa_period_name, rcvr_gl_period_name,
                      global_exp_period_end_date, expenditure_type,
                      expenditure_type_class, cost_rejection_code,
                      rev_rejection_code, tp_rejection_code,
                      burden_rejection_code, other_rejection_code,
                      delete_flag, error_flag, provisional_flag,
                      JOB_ID,
                      TP_AMOUNT_TYPE,
                      OVERPROVISIONAL_QTY,
                      OVER_PROV_CONF_QTY,
                      CONFIRMED_QTY,
                      PROVISIONAL_QTY,
                      asgmt_sys_status_code, capacity_quantity,
                      overcommitment_quantity, availability_quantity,
                      overcommitment_flag, availability_flag
             BULK COLLECT INTO forecast_item_id_tab, forecast_item_type_tab,
                      project_org_id_tab, expenditure_org_id_tab,
                      project_organization_id_tab, expenditure_orgn_id_tab,
                      project_id_tab, project_type_class_tab, person_id_tab,
                      resource_id_tab, borrowed_flag_tab, assignment_id_tab,
                      item_date_tab, item_uom_tab, item_quantity_tab,
                      pvdr_period_set_name_tab, pvdr_pa_period_name_tab,
                      pvdr_gl_period_name_tab, rcvr_period_set_name_tab,
                      rcvr_pa_period_name_tab, rcvr_gl_period_name_tab,
                      global_exp_period_end_date_tab, expenditure_type_tab,
                      expenditure_type_class_tab, cost_rejection_code_tab,
                      rev_rejection_code_tab, tp_rejection_code_tab,
                      burden_rejection_code_tab, other_rejection_code_tab,
                      delete_flag_tab, error_flag_tab, provisional_flag_tab,
                      JOB_ID_tab,
                      TP_AMOUNT_TYPE_tab,
                      OVERPROVISIONAL_QTY_tab,
                      OVER_PROV_CONF_QTY_tab,
                      CONFIRMED_QTY_tab,
                      PROVISIONAL_QTY_tab,
                      asgmt_sys_status_code_tab, capacity_quantity_tab,
                      overcommitment_quantity_tab, availability_quantity_tab,
                      overcommitment_flag_tab, availability_flag_tab
             FROM     pa_forecast_items hdr
             WHERE    assignment_id = p_assignment_id
             AND      delete_flag = 'N'
             AND      (trunc(hdr.item_date) < trunc(p_start_date)
                       OR    trunc(hdr.item_date) > trunc(p_end_date))
             order by item_date, forecast_item_id ;


             IF nvl(forecast_item_id_tab.count,0) = 0 THEN

                x_return_status := lv_return_status;

                Print_message('Leaving Reverse_FI_Hdr');

                RETURN;

             END IF;
             -- Move to one table FROM multiple tables

             x_old_start_date := item_date_tab(item_date_tab.FIRST);
             x_old_end_date   := item_date_tab(item_date_tab.LAST);

             FOR j IN forecast_item_id_tab.FIRST..forecast_item_id_tab.LAST LOOP

                TmpUpdTab(j).forecast_item_id := forecast_item_id_tab(j);
                TmpUpdTab(j).forecast_item_type := forecast_item_type_tab(j);
                TmpUpdTab(j).project_org_id  := project_org_id_tab(j);
                TmpUpdTab(j).expenditure_org_id := expenditure_org_id_tab(j);
                TmpUpdTab(j).project_organization_id :=
                                         project_organization_id_tab(j);
                TmpUpdTab(j).expenditure_organization_id  :=
                                         expenditure_orgn_id_tab(j);
                TmpUpdTab(j).project_id := project_id_tab(j);
                TmpUpdTab(j).project_type_class := project_type_class_tab(j);
                TmpUpdTab(j).person_id  := person_id_tab(j);
                TmpUpdTab(j).resource_id := resource_id_tab(j);
                TmpUpdTab(j).borrowed_flag := borrowed_flag_tab(j);
                TmpUpdTab(j).assignment_id := assignment_id_tab(j);
                TmpUpdTab(j).item_date := item_date_tab(j);
                TmpUpdTab(j).item_uom := item_uom_tab(j);
                TmpUpdTab(j).item_quantity := 0;
                TmpUpdTab(j).pvdr_period_set_name :=
                                         pvdr_period_set_name_tab(j);
                TmpUpdTab(j).pvdr_pa_period_name := pvdr_pa_period_name_tab(j);
                TmpUpdTab(j).pvdr_gl_period_name := pvdr_gl_period_name_tab(j);
                TmpUpdTab(j).rcvr_period_set_name :=
                                         rcvr_period_set_name_tab(j);
                TmpUpdTab(j).rcvr_pa_period_name := rcvr_pa_period_name_tab(j);
                TmpUpdTab(j).rcvr_gl_period_name := rcvr_gl_period_name_tab(j);
                TmpUpdTab(j).global_exp_period_end_date :=
                                         global_exp_period_end_date_tab(j);
                TmpUpdTab(j).expenditure_type := expenditure_type_tab(j);
                TmpUpdTab(j).expenditure_type_class :=
                                         expenditure_type_class_tab(j);
                TmpUpdTab(j).cost_rejection_code := cost_rejection_code_tab(j);
                TmpUpdTab(j).rev_rejection_code := rev_rejection_code_tab(j);
                TmpUpdTab(j).tp_rejection_code := tp_rejection_code_tab(j);
                TmpUpdTab(j).burden_rejection_code :=
                                         burden_rejection_code_tab(j);
                TmpUpdTab(j).other_rejection_code :=
                                         other_rejection_code_tab(j);
                TmpUpdTab(j).delete_flag := 'Y';
                TmpUpdTab(j).error_flag := error_flag_tab(j);
                TmpUpdTab(j).provisional_flag := provisional_flag_tab(j);
                TmpUpdTab(j).JOB_ID := JOB_ID_tab(j);
                TmpUpdTab(j).TP_AMOUNT_TYPE := TP_AMOUNT_TYPE_tab(j);
                TmpUpdTab(j).OVERPROVISIONAL_QTY := OVERPROVISIONAL_QTY_tab(j);
                TmpUpdTab(j).OVER_PROV_CONF_QTY := OVER_PROV_CONF_QTY_tab(j);
                TmpUpdTab(j).CONFIRMED_QTY := CONFIRMED_QTY_tab(j);
                TmpUpdTab(j).PROVISIONAL_QTY := PROVISIONAL_QTY_tab(j);
                TmpUpdTab(j).asgmt_sys_status_code := asgmt_sys_status_code_tab(j);
                TmpUpdTab(j).capacity_quantity := capacity_quantity_tab(j);
                TmpUpdTab(j).overcommitment_quantity :=  overcommitment_quantity_tab(j);
                TmpUpdTab(j).availability_quantity :=  availability_quantity_tab(j);
                TmpUpdTab(j).overcommitment_flag := overcommitment_flag_tab(j);
                TmpUpdTab(j).availability_flag := availability_flag_tab(j);
             END LOOP;

             IF nvl(TmpUpdTab.COUNT,0) > 0 THEN

                Print_message('
                             Calling PA_FORECAST_HDR_PKG.Update_rows');

                PA_FORECAST_HDR_PKG.Update_Rows(
                                           TmpUpdTab,
                                           lv_return_status,
                                           x_msg_count,
                                           x_msg_data);

             END IF;



             Print_message('Leaving Reverse_FI_Hdr');

             x_return_status := lv_return_status;

             PA_DEBUG.Reset_Err_Stack;

       EXCEPTION

             WHEN OTHERS THEN
                  print_message('Failed in Reverse_FI_Hdr api');
                  print_message('SQLCODE'||sqlcode||sqlerrm);

                  x_msg_count     := 1;
                  x_msg_data      := sqlerrm;
                  x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

		  -- 4537865
		  x_old_start_date := NULL ;
		  x_old_end_date := NULL ;

                  FND_MSG_PUB.add_exc_msg
                      (p_pkg_name   =>
                              'PA_FORECASTITEM_PVT.Reverse_FI_Hdr',
                       p_procedure_name => PA_DEBUG.G_Err_Stack);

		               If x_msg_count = 1 THEN
				              pa_interface_utils_pub.get_messages
				                (p_encoded        => FND_API.G_TRUE,
					               p_msg_index      => 1,
					               p_msg_count      => x_msg_count,
					               p_msg_data       => x_msg_data,
					               p_data           => l_data, -- 4537865
					               p_msg_index_out  => l_msg_index_out );
						x_msg_data := l_data ; -- 4537865
		               End If;
                  Print_message(x_msg_data);

                  RAISE;

       END  Reverse_FI_Hdr;

/* ---------------------------------------------------------------------
|   Procedure  :   Reverse_FI_Dtl
|   Purpose    :   To reverse the existing forecast item details
|                  (Requirement , Assignment )which do not fall IN the
|                  given DATE range
|   Parameters :   p_assignment_id  - Input Assignment ID
|                  p_start_date     - Current Start DATE FOR forecast item
|                  p_end_date       - Current END DATE FOR forecast item
|                  x_return_status     -
|                  x_msg_count         -
|                  x_msg_data          -
+----------------------------------------------------------------------*/
       PROCEDURE  Reverse_FI_Dtl(
                  p_assignment_id  IN    NUMBER,
                  p_start_date     IN    DATE,
                  p_end_date       IN    DATE,
                  x_return_status  OUT NOCOPY   VARCHAR2, --4537865
                  x_msg_count      OUT NOCOPY  NUMBER, -- 4537865
                  x_msg_data       OUT NOCOPY  VARCHAR2) IS -- 4537865

	           l_msg_index_out	            NUMBER;

		   l_data  VARCHAR2(2000); --4537865
             forecast_item_id_tab            PA_FORECAST_GLOB.NumberTabTyp;
             amount_type_id_tab              PA_FORECAST_GLOB.NumberTabTyp;
             line_num_tab                    PA_FORECAST_GLOB.NumberTabTyp;
             resource_type_code_tab          PA_FORECAST_GLOB.VCTabTyp;
             person_billable_flag_tab        PA_FORECAST_GLOB.VC1TabTyp;
             item_date_tab                   PA_FORECAST_GLOB.DateTabTyp;
             item_UOM_tab                    PA_FORECAST_GLOB.VCTabTyp;
             item_quantity_tab               PA_FORECAST_GLOB.NumberTabTyp;
             expenditure_org_id_tab          PA_FORECAST_GLOB.NumberTabTyp;
             project_org_id_tab              PA_FORECAST_GLOB.NumberTabTyp;
             PJI_SUMMARIZED_FLAG_tab         PA_FORECAST_GLOB.VC1TabTyp;
             CAPACITY_QUANTITY_tab         PA_FORECAST_GLOB.NumberTabTyp;
             OVERCOMMITMENT_QTY_tab         PA_FORECAST_GLOB.NumberTabTyp;
             OVERPROVISIONAL_QTY_tab         PA_FORECAST_GLOB.NumberTabTyp;
             OVER_PROV_CONF_QTY_tab         PA_FORECAST_GLOB.NumberTabTyp;
             CONFIRMED_QTY_tab         PA_FORECAST_GLOB.NumberTabTyp;
             PROVISIONAL_QTY_tab         PA_FORECAST_GLOB.NumberTabTyp;
             JOB_ID_tab         PA_FORECAST_GLOB.NumberTabTyp;
             PROJECT_ID_tab         PA_FORECAST_GLOB.NumberTabTyp;
             RESOURCE_ID_tab         PA_FORECAST_GLOB.NumberTabTyp;
             EXP_ORGANIZATION_ID_tab         PA_FORECAST_GLOB.NumberTabTyp;
             pvdr_acct_curr_code_tab         PA_FORECAST_GLOB.VC15TabTyp;
             pvdr_acct_amount_tab            PA_FORECAST_GLOB.NumberTabTyp;
             rcvr_acct_curr_code_tab         PA_FORECAST_GLOB.VC15TabTyp;
             rcvr_acct_amount_tab            PA_FORECAST_GLOB.NumberTabTyp;
             proj_currency_code_tab          PA_FORECAST_GLOB.VC15TabTyp;
             proj_amount_tab                 PA_FORECAST_GLOB.NumberTabTyp;
             denom_currency_code_tab         PA_FORECAST_GLOB.VC15TabTyp;
             denom_amount_tab                PA_FORECAST_GLOB.NumberTabTyp;
             tp_amount_type_tab              PA_FORECAST_GLOB.VCTabTyp;
             billable_flag_tab               PA_FORECAST_GLOB.VC1TabTyp;
             forecast_summarized_code_tab    PA_FORECAST_GLOB.VCTabTyp;
             util_summarized_code_tab        PA_FORECAST_GLOB.VCTabTyp;
             work_type_id_tab                PA_FORECAST_GLOB.NumberTabTyp;
             resource_util_category_id_tab   PA_FORECAST_GLOB.NumberTabTyp;
             org_util_category_id_tab        PA_FORECAST_GLOB.NumberTabTyp;
             resource_util_weighted_tab      PA_FORECAST_GLOB.NumberTabTyp;
             org_util_weighted_tab           PA_FORECAST_GLOB.NumberTabTyp;
             provisional_flag_tab            PA_FORECAST_GLOB.VC1TabTyp;
             reversed_flag_tab               PA_FORECAST_GLOB.VC1TabTyp;
             net_zero_flag_tab               PA_FORECAST_GLOB.VC1TabTyp;
             reduce_capacity_flag_tab        PA_FORECAST_GLOB.VC1TabTyp;
             line_num_reversed_tab           PA_FORECAST_GLOB.NumberTabTyp;

             TmpRevTab                       PA_FORECAST_GLOB.FIDtlTabTyp;
             TmpUpdTab                       PA_FORECAST_GLOB.FIDtlTabTyp;
             l_rev_index                     NUMBER;
             lv_return_status                VARCHAR2(30);

       BEGIN

             lv_return_status := FND_API.G_RET_STS_SUCCESS;

             Print_message('Entering Reverse_FI_Dtl');

             PA_DEBUG.Init_err_stack(
                       'PA_FORECASTITEM_PVT.Reverse_FI_Dtl');

             forecast_item_id_tab.delete;
             amount_type_id_tab.delete;
             line_num_tab.delete;
             resource_type_code_tab.delete;
             person_billable_flag_tab.delete;
             item_date_tab.delete;
             item_UOM_tab.delete;
             item_quantity_tab.delete;
             expenditure_org_id_tab.delete;
             project_org_id_tab.delete;
             PJI_SUMMARIZED_FLAG_tab.delete;
             CAPACITY_QUANTITY_tab.delete;
             OVERCOMMITMENT_QTY_tab.delete;
             OVERPROVISIONAL_QTY_tab.delete;
             OVER_PROV_CONF_QTY_tab.delete;
             CONFIRMED_QTY_tab.delete;
             PROVISIONAL_QTY_tab.delete;
             JOB_ID_tab.delete;
             PROJECT_ID_tab.delete;
             RESOURCE_ID_tab.delete;
             EXP_ORGANIZATION_ID_tab.delete;
             pvdr_acct_curr_code_tab.delete;
             pvdr_acct_amount_tab.delete;
             rcvr_acct_curr_code_tab.delete;
             rcvr_acct_amount_tab.delete;
             proj_currency_code_tab.delete;
             proj_amount_tab.delete;
             denom_currency_code_tab.delete;
             denom_amount_tab.delete;
             tp_amount_type_tab.delete;
             billable_flag_tab.delete;
             forecast_summarized_code_tab.delete;
             util_summarized_code_tab.delete;
             work_type_id_tab.delete;
             resource_util_category_id_tab.delete;
             org_util_category_id_tab.delete;
             resource_util_weighted_tab.delete;
             org_util_weighted_tab.delete;
             provisional_flag_tab.delete;
             reversed_flag_tab.delete;
             net_zero_flag_tab.delete;
             reduce_capacity_flag_tab.delete;
             line_num_reversed_tab.delete;

             TmpRevTab.delete;
             TmpUpdTab.delete;

             SELECT dtl.forecast_item_id, dtl.amount_type_id,
                    dtl.line_num, dtl.resource_type_code,
                    dtl.person_billable_flag, dtl.item_UOM, dtl.item_date,
                    dtl.PJI_SUMMARIZED_FLAG,
                    dtl.CAPACITY_QUANTITY,
                    dtl.OVERCOMMITMENT_QTY,
                    dtl.OVERPROVISIONAL_QTY,
                    dtl.OVER_PROV_CONF_QTY,
                    dtl.CONFIRMED_QTY,
                    dtl.PROVISIONAL_QTY,
                    dtl.JOB_ID,
                    dtl.PROJECT_ID,
                    dtl.RESOURCE_ID,
                    dtl.EXPENDITURE_ORGANIZATION_ID,
                    dtl.item_quantity, dtl.expenditure_org_id,
                    dtl.project_org_id, dtl.pvdr_acct_curr_code,
                    dtl.pvdr_acct_amount, dtl.rcvr_acct_curr_code,
                    dtl.rcvr_acct_amount, dtl.proj_currency_code,
                    dtl.proj_amount, dtl.denom_currency_code, dtl.denom_amount,
                    dtl.tp_amount_type, dtl.billable_flag,
                    dtl.forecast_summarized_code, dtl.util_summarized_code,
                    dtl.work_type_id, dtl.resource_util_category_id,
                    dtl.org_util_category_id, dtl.resource_util_weighted,
                    dtl.org_util_weighted, dtl.provisional_flag,
                    dtl.reversed_flag, dtl.net_zero_flag,
                    dtl.reduce_capacity_flag, dtl.line_num_reversed
             BULK COLLECT INTO forecast_item_id_tab,amount_type_id_tab,
                    line_num_tab, resource_type_code_tab,
                    person_billable_flag_tab, item_UOM_tab, item_date_tab,
                    PJI_SUMMARIZED_FLAG_tab,
                    CAPACITY_QUANTITY_tab,
                    OVERCOMMITMENT_QTY_tab,
                    OVERPROVISIONAL_QTY_tab,
                    OVER_PROV_CONF_QTY_tab,
                    CONFIRMED_QTY_tab,
                    PROVISIONAL_QTY_tab,
                    JOB_ID_tab,
                    PROJECT_ID_tab,
                    RESOURCE_ID_tab,
                    EXP_ORGANIZATION_ID_tab,
                    item_quantity_tab, expenditure_org_id_tab,
                    project_org_id_tab, pvdr_acct_curr_code_tab,
                    pvdr_acct_amount_tab, rcvr_acct_curr_code_tab,
                    rcvr_acct_amount_tab, proj_currency_code_tab,
                    proj_amount_tab, denom_currency_code_tab, denom_amount_tab,
                    tp_amount_type_tab, billable_flag_tab,
                    forecast_summarized_code_tab, util_summarized_code_tab,
                    work_type_id_tab, resource_util_category_id_tab,
                    org_util_category_id_tab, resource_util_weighted_tab,
                    org_util_weighted_tab, provisional_flag_tab,
                    reversed_flag_tab, net_zero_flag_tab,
                    reduce_capacity_flag_tab, line_num_reversed_tab
             FROM   pa_forecast_item_details dtl, pa_forecast_items hdr
             WHERE  hdr.assignment_id = p_assignment_id
             AND    hdr.delete_flag   = 'N'
             AND    dtl.forecast_item_id = hdr.forecast_item_id
             AND    (dtl.item_date < trunc(p_start_date)
                     OR dtl.item_date > trunc(p_end_date) + 1 - (1/86400))
             AND    dtl.line_num =
                      (SELECT max(line_num)
                       FROM pa_forecast_item_details dtl1
                       WHERE dtl1.forecast_item_id = hdr.forecast_item_id)
             order by dtl.item_date, dtl.forecast_item_id ;

             IF nvl(forecast_item_id_tab.count,0) = 0 THEN

                x_return_status := lv_return_status;

                Print_message('Leaving Reverse_FI_Dtl');

                RETURN;

             END IF;

             -- Move to one table FROM multiple tables

             FOR j IN forecast_item_id_tab.FIRST..forecast_item_id_tab.LAST LOOP

                 TmpUpdTab(j).forecast_item_id := forecast_item_id_tab(j);
                 TmpUpdTab(j).amount_type_id :=amount_type_id_tab(j);
                 TmpUpdTab(j).line_num  := line_num_tab(j);
                 TmpUpdTab(j).resource_type_code := resource_type_code_tab(j);
                 TmpUpdTab(j).person_billable_flag :=
                                 person_billable_flag_tab(j);
                 TmpUpdTab(j).item_Uom := item_UOM_tab(j);
                 TmpUpdTab(j).item_date := item_date_tab(j);
                 TmpUpdTab(j).item_quantity := item_quantity_tab(j);
                 TmpUpdTab(j).expenditure_org_id := expenditure_org_id_tab(j);
                 TmpUpdTab(j).project_org_id := project_org_id_tab(j);
                 TmpUpdTab(j).pvdr_acct_curr_code := pvdr_acct_curr_code_tab(j);
                 TmpUpdTab(j).PJI_SUMMARIZED_FLAG := PJI_SUMMARIZED_FLAG_tab(j);
                 TmpUpdTab(j).CAPACITY_QUANTITY := CAPACITY_QUANTITY_tab(j);
                 TmpUpdTab(j).OVERCOMMITMENT_QTY := OVERCOMMITMENT_QTY_tab(j);
                 TmpUpdTab(j).OVERPROVISIONAL_QTY := OVERPROVISIONAL_QTY_tab(j);
                 TmpUpdTab(j).OVER_PROV_CONF_QTY := OVER_PROV_CONF_QTY_tab(j);
                 TmpUpdTab(j).CONFIRMED_QTY := CONFIRMED_QTY_tab(j);
                 TmpUpdTab(j).PROVISIONAL_QTY := PROVISIONAL_QTY_tab(j);
                 TmpUpdTab(j).JOB_ID := JOB_ID_tab(j);
                 TmpUpdTab(j).PROJECT_ID := PROJECT_ID_tab(j);
                 TmpUpdTab(j).RESOURCE_ID := RESOURCE_ID_tab(j);
                 TmpUpdTab(j).EXPENDITURE_ORGANIZATION_ID := EXP_ORGANIZATION_ID_tab(j);
                 TmpUpdTab(j).pvdr_acct_amount := pvdr_acct_amount_tab(j);
                 TmpUpdTab(j).rcvr_acct_curr_code :=
                                 rcvr_acct_curr_code_tab(j);
                 TmpUpdTab(j).rcvr_acct_amount := rcvr_acct_amount_tab(j);
                 TmpUpdTab(j).proj_currency_code := proj_currency_code_tab(j);
                 TmpUpdTab(j).proj_amount := proj_amount_tab(j);
                 TmpUpdTab(j).denom_currency_code := denom_currency_code_tab(j);
                 TmpUpdTab(j).denom_amount := denom_amount_tab(j);
                 TmpUpdTab(j).tp_amount_type := tp_amount_type_tab(j);
                 TmpUpdTab(j).billable_flag := billable_flag_tab(j);
                 TmpUpdTab(j).forecast_summarized_code :=
                                 forecast_summarized_code_tab(j);
                 TmpUpdTab(j).util_summarized_code :=
                                 util_summarized_code_tab(j);
                 TmpUpdTab(j).work_type_id := work_type_id_tab(j);
                 TmpUpdTab(j).resource_util_category_id :=
                                 resource_util_category_id_tab(j);
                 TmpUpdTab(j).org_util_category_id :=
                                 org_util_category_id_tab(j);
                 TmpUpdTab(j).resource_util_weighted :=
                                 resource_util_weighted_tab(j);
                 TmpUpdTab(j).org_util_weighted :=
                                 org_util_weighted_tab(j);
                 TmpUpdTab(j).provisional_flag := provisional_flag_tab(j);
                 TmpUpdTab(j).reversed_flag := reversed_flag_tab(j);
                 TmpUpdTab(j).net_zero_flag := net_zero_flag_tab(j);
                 TmpUpdTab(j).reduce_capacity_flag :=
                                           reduce_capacity_flag_tab(j);
                 TmpUpdTab(j).line_num_reversed := line_num_reversed_tab(j);

             END LOOP;

             l_rev_index := 1;

             IF (TmpUpdTab.count <> 0) then
             FOR j IN TmpUpdTab.FIRST..TmpUpdTab.LAST LOOP
                 IF (TmpUpdTab.EXISTS(j)) then

                 IF (NVL(TmpUpdTab(j).forecast_summarized_code,'Y') = 'Y'
                        OR NVL(TmpUpdTab(j).PJI_SUMMARIZED_FLAG,'Y') = 'Y'
                        OR  NVL(TmpUpdTab(j).util_summarized_code,'Y') = 'Y')
                       AND (
                             NVL(TmpUpdTab(j).CAPACITY_QUANTITY,0) > 0 OR
                             NVL(TmpUpdTab(j).OVERCOMMITMENT_QTY,0) > 0 OR
                             NVL(TmpUpdTab(j).OVERPROVISIONAL_QTY,0) > 0 OR
                             NVL(TmpUpdTab(j).OVER_PROV_CONF_QTY,0) > 0 OR
                             NVL(TmpUpdTab(j).CONFIRMED_QTY,0) > 0 OR
                             NVL(TmpUpdTab(j).PROVISIONAL_QTY,0) > 0 OR
                             TmpUpdTab(j).item_quantity > 0
                            ) THEN

                    TmpUpdTab(j).reversed_flag := 'Y';
                    TmpUpdTab(j).net_zero_flag := 'Y';

                    TmpRevTab(l_rev_index) := TmpUpdTab(j);
                    IF (NVL(TmpUpdTab(j).CAPACITY_QUANTITY,0) = 0) THEN
                       TmpRevTab(l_rev_index).CAPACITY_QUANTITY := NULL;
                    ELSE
                       TmpRevTab(l_rev_index).CAPACITY_QUANTITY :=
                          NVL(TmpUpdTab(j).CAPACITY_QUANTITY,0) * -1;
                    END IF;
                    IF (NVL(TmpUpdTab(j).OVERCOMMITMENT_QTY,0) = 0) THEN
                       TmpRevTab(l_rev_index).OVERCOMMITMENT_QTY := NULL;
                    ELSE
                       TmpRevTab(l_rev_index).OVERCOMMITMENT_QTY :=
                          NVL(TmpUpdTab(j).OVERCOMMITMENT_QTY,0) * -1;
                    END IF;
                    IF (NVL(TmpUpdTab(j).OVERPROVISIONAL_QTY,0) = 0) THEN
                       TmpRevTab(l_rev_index).OVERPROVISIONAL_QTY := NULL;
                    ELSE
                       TmpRevTab(l_rev_index).OVERPROVISIONAL_QTY :=
                          NVL(TmpUpdTab(j).OVERPROVISIONAL_QTY,0) * -1;
                    END IF;
                    IF (NVL(TmpUpdTab(j).OVER_PROV_CONF_QTY,0) = 0) THEN
                       TmpRevTab(l_rev_index).OVER_PROV_CONF_QTY := NULL;
                    ELSE
                       TmpRevTab(l_rev_index).OVER_PROV_CONF_QTY :=
                          NVL(TmpUpdTab(j).OVER_PROV_CONF_QTY,0) * -1;
                    END IF;
                    IF (NVL(TmpUpdTab(j).CONFIRMED_QTY,0) = 0) THEN
                       TmpRevTab(l_rev_index).CONFIRMED_QTY := NULL;
                    ELSE
                       TmpRevTab(l_rev_index).CONFIRMED_QTY :=
                          NVL(TmpUpdTab(j).CONFIRMED_QTY,0) * -1;
                    END IF;
                    IF (NVL(TmpUpdTab(j).PROVISIONAL_QTY,0) = 0) THEN
                       TmpRevTab(l_rev_index).PROVISIONAL_QTY := NULL;
                    ELSE
                       TmpRevTab(l_rev_index).PROVISIONAL_QTY :=
                          NVL(TmpUpdTab(j).PROVISIONAL_QTY,0) * -1;
                    END IF;
                    TmpRevTab(l_rev_index).item_quantity :=
                                  TmpUpdTab(j).item_quantity * -1;
                    TmpRevTab(l_rev_index).resource_util_weighted :=
                                  TmpUpdTab(j).resource_util_weighted * -1;
                    TmpRevTab(l_rev_index).org_util_weighted :=
                                  TmpUpdTab(j).org_util_weighted * -1;

                    IF NVL(TmpUpdTab(j).forecast_summarized_code,'Y') = 'Y' THEN

                       TmpRevTab(l_rev_index).forecast_summarized_code := 'N';

                    ELSE

                       TmpRevTab(l_rev_index).forecast_summarized_code :=
                               TmpUpdTab(j).forecast_summarized_code;
                    END IF;

                    IF NVL(TmpUpdTab(j).PJI_SUMMARIZED_FLAG,'Y') = 'Y' THEN
                      TmpRevTab(l_rev_index).PJI_SUMMARIZED_FLAG := 'N';
                    ELSE
                      TmpRevTab(l_rev_index).PJI_SUMMARIZED_FLAG :=
                              TmpUpdTab(j).PJI_SUMMARIZED_FLAG;
                    END IF;

                    IF NVL(TmpUpdTab(j).util_summarized_code,'Y') = 'Y' THEN

                       TmpRevTab(l_rev_index).util_summarized_code := 'N';

                    ELSE

                       TmpRevTab(l_rev_index).util_summarized_code :=
                               TmpUpdTab(j).util_summarized_code;

                    END IF;

                    TmpRevTab(l_rev_index).line_num_reversed :=
				   TmpUpdTab(j).line_num;  -- Added for bug 4244913
                                 --  TmpRevTab(j).line_num;   Commented for bug 4244913
                    TmpRevTab(l_rev_index).line_num :=
				   TmpUpdTab(j).line_num + 1; --  Added for bug 4244913
                                 --  TmpRevTab(j).line_num + 1;   Commented for bug 4244913
                    TmpRevTab(l_rev_index).net_zero_flag := 'Y';
                    l_rev_index := l_rev_index + 1;


                 ELSE

                    TmpUpdTab(j).CAPACITY_QUANTITY := NULL;
                    TmpUpdTab(j).OVERCOMMITMENT_QTY := NULL;
                    TmpUpdTab(j).OVERPROVISIONAL_QTY := NULL;
                    TmpUpdTab(j).OVER_PROV_CONF_QTY := NULL;
                    TmpUpdTab(j).CONFIRMED_QTY := NULL;
                    TmpUpdTab(j).PROVISIONAL_QTY := NULL;
                    TmpUpdTab(j).item_quantity := 0;
                    TmpUpdTab(j).org_util_weighted :=0;
                    TmpUpdTab(j).resource_util_weighted :=0;

                 END IF;

             END IF;
             END LOOP;
             end if;

             IF nvl(TmpRevTab.COUNT,0) > 0 THEN

                Print_message(
                             'Calling PA_FORECAST_DTLS_PKG.Insert_Rows');

                PA_FORECAST_DTLS_PKG.Insert_Rows(TmpRevTab,
                                                lv_return_status,
                                                x_msg_count,
                                                x_msg_data);

             END IF;

             IF lv_return_status = FND_API.G_RET_STS_SUCCESS THEN

                IF nvl(TmpUpdTab.COUNT,0) > 0 THEN

                    Print_message(
                             'Calling PA_FORECAST_DTLS_PKG.Update_Rows');

                    PA_FORECAST_DTLS_PKG.Update_Rows(TmpUpdTab,
                                                lv_return_status,
                                                x_msg_count,
                                                x_msg_data);

                END IF;

             END IF;

             PA_DEBUG.Reset_Err_Stack;

             Print_message('Leaving Reverse_FI_Dtl');

             x_return_status := lv_return_status;

       EXCEPTION

             WHEN OTHERS THEN
                  print_message('Failed in Reverse_FI_DTL api');
                  print_message('SQLCODE'||sqlcode||sqlerrm);

                  x_msg_count     := 1;
                  x_msg_data      := sqlerrm;
                  x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

                  FND_MSG_PUB.add_exc_msg
                      (p_pkg_name   =>
                              'PA_FORECASTITEM_PVT.Reverse_FI_Dtl',
                       p_procedure_name => PA_DEBUG.G_Err_Stack);

		               If x_msg_count = 1 THEN
				              pa_interface_utils_pub.get_messages
				                (p_encoded        => FND_API.G_TRUE,
					               p_msg_index      => 1,
					               p_msg_count      => x_msg_count,
					               p_msg_data       => x_msg_data,
					               p_data           => l_data, -- 4537865
					               p_msg_index_out  => l_msg_index_out );
							x_msg_data := l_data ; -- 4537865
		               End If;
                  Print_message(x_msg_data);

                  RAISE;


       END  Reverse_FI_Dtl;

/* ---------------------------------------------------------------------
|   Procedure  :   Fetch_FI_Hdr
|   Purpose    :   To get existing forecast items (Requirement , Assignment)
|                  FOR the given assignment ID which fall BETWEEN
|                  startdate AND END DATE
|   Parameters :   p_FI_Type        - Forecast Item Type
|                                     'R' - Requirement
|                                     'A' - Assignment
|                  p_assignment_id  - Input Assignment ID
|                  p_resource_id    - Input Resource ID
|                                     (only IF forecast item type is Assignment)
|                  p_start_date     - Current Start DATE FOR forecast item
|                  p_end_date       - Current END DATE FOR forecast item
|                  x_dbFIHdrTab     - Holds the data retrieved FROM the database
|                  x_return_status     -
|                  x_msg_count         -
|                  x_msg_data          -
+----------------------------------------------------------------------*/

       PROCEDURE  Fetch_FI_Hdr(
                  p_assignment_id    IN    NUMBER,
                  p_resource_id      IN    NUMBER,
                  p_start_date       IN    DATE,
                  p_end_date         IN    DATE,
                  x_dbFIHdrTab       OUT NOCOPY  PA_FORECAST_GLOB.FIHdrTabTyp, /* 2674619 - Nocopy change */
                  x_return_status  OUT NOCOPY   VARCHAR2, -- 4537865
                  x_msg_count      OUT NOCOPY  NUMBER, -- 4537865
                  x_msg_data       OUT NOCOPY  VARCHAR2) IS -- 4537865


	           l_msg_index_out	            NUMBER;
		 l_data VARCHAR2(2000) ;-- 4537865
             forecast_item_id_tab                PA_FORECAST_GLOB.NumberTabTyp;
             forecast_item_type_tab              PA_FORECAST_GLOB.VCTabTyp;
             project_org_id_tab                  PA_FORECAST_GLOB.NumberTabTyp;
             expenditure_org_id_tab              PA_FORECAST_GLOB.NumberTabTyp;
             expenditure_orgn_id_tab             PA_FORECAST_GLOB.NumberTabTyp;
             project_organization_id_tab         PA_FORECAST_GLOB.NumberTabTyp;
             project_id_tab                      PA_FORECAST_GLOB.NumberTabTyp;
             project_type_class_tab              PA_FORECAST_GLOB.VCTabTyp;
             person_id_tab                       PA_FORECAST_GLOB.NumberTabTyp;
             resource_id_tab                     PA_FORECAST_GLOB.NumberTabTyp;
             borrowed_flag_tab                   PA_FORECAST_GLOB.VC1TabTyp;
             assignment_id_tab                   PA_FORECAST_GLOB.NumberTabTyp;
             item_date_tab                       PA_FORECAST_GLOB.DateTabTyp;
             item_uom_tab                        PA_FORECAST_GLOB.VCTabTyp;
             item_quantity_tab                   PA_FORECAST_GLOB.NumberTabTyp;
             pvdr_period_set_name_tab            PA_FORECAST_GLOB.VCTabTyp;
             pvdr_pa_period_name_tab             PA_FORECAST_GLOB.VCTabTyp;
             pvdr_gl_period_name_tab             PA_FORECAST_GLOB.VCTabTyp;
             rcvr_period_set_name_tab            PA_FORECAST_GLOB.VCTabTyp;
             rcvr_pa_period_name_tab             PA_FORECAST_GLOB.VCTabTyp;
             rcvr_gl_period_name_tab             PA_FORECAST_GLOB.VCTabTyp;
             global_exp_period_end_date_tab      PA_FORECAST_GLOB.DateTabTyp;
             expenditure_type_tab                PA_FORECAST_GLOB.VCTabTyp;
             expenditure_type_class_tab          PA_FORECAST_GLOB.VCTabTyp;
             cost_rejection_code_tab             PA_FORECAST_GLOB.VCTabTyp;
             rev_rejection_code_tab              PA_FORECAST_GLOB.VCTabTyp;
             tp_rejection_code_tab               PA_FORECAST_GLOB.VCTabTyp;
             burden_rejection_code_tab           PA_FORECAST_GLOB.VCTabTyp;
             other_rejection_code_tab            PA_FORECAST_GLOB.VCTabTyp;
             delete_flag_tab                     PA_FORECAST_GLOB.VC1TabTyp;
             error_flag_tab                      PA_FORECAST_GLOB.VC1TabTyp;
             provisional_flag_tab                PA_FORECAST_GLOB.VC1TabTyp;
             JOB_ID_tab           PA_FORECAST_GLOB.NumberTabTyp;
             TP_AMOUNT_TYPE_tab           PA_FORECAST_GLOB.VCTabTyp;
             OVERPROVISIONAL_QTY_tab           PA_FORECAST_GLOB.NumberTabTyp;
             OVER_PROV_CONF_QTY_tab           PA_FORECAST_GLOB.NumberTabTyp;
             CONFIRMED_QTY_tab           PA_FORECAST_GLOB.NumberTabTyp;
             PROVISIONAL_QTY_tab           PA_FORECAST_GLOB.NumberTabTyp;
             asgmt_sys_status_code_tab           PA_FORECAST_GLOB.VCTabTyp;
             capacity_quantity_tab               PA_FORECAST_GLOB.NumberTabTyp;
             overcommitment_quantity_tab         PA_FORECAST_GLOB.NumberTabTyp;
             availability_quantity_tab           PA_FORECAST_GLOB.NumberTabTyp;
             overcommitment_flag_tab             PA_FORECAST_GLOB.VC1TabTyp;
             availability_flag_tab               PA_FORECAST_GLOB.VC1TabTyp;

             TmpHdrTab                           PA_FORECAST_GLOB.FIHdrTabTyp;

             lv_return_status                    VARCHAR2(30);

       BEGIN

             lv_return_status := FND_API.G_RET_STS_SUCCESS;

             Print_message('Entering Fetch_FI_Hdr');

             PA_DEBUG.Init_err_stack(
                       'PA_FORECASTITEM_PVT.Fetch_FI_Hdr');

             TmpHdrTab.delete;
             forecast_item_id_tab.delete;
             forecast_item_type_tab.delete;
             project_org_id_tab.delete;
             expenditure_org_id_tab.delete;
             expenditure_orgn_id_tab.delete;
             project_organization_id_tab.delete;
             project_id_tab.delete;
             project_type_class_tab.delete;
             person_id_tab.delete;
             resource_id_tab.delete;
             borrowed_flag_tab.delete;
             assignment_id_tab.delete;
             item_date_tab.delete;
             item_uom_tab.delete;
             item_quantity_tab.delete;
             pvdr_period_set_name_tab.delete;
             pvdr_pa_period_name_tab.delete;
             pvdr_gl_period_name_tab.delete;
             rcvr_period_set_name_tab.delete;
             rcvr_pa_period_name_tab.delete;
             rcvr_gl_period_name_tab.delete;
             global_exp_period_end_date_tab.delete;
             expenditure_type_tab.delete;
             expenditure_type_class_tab.delete;
             cost_rejection_code_tab.delete;
             rev_rejection_code_tab.delete;
             tp_rejection_code_tab.delete;
             burden_rejection_code_tab.delete;
             other_rejection_code_tab.delete;
             delete_flag_tab.delete;
             error_flag_tab.delete;
             provisional_flag_tab.delete;
             JOB_ID_tab.delete;
             TP_AMOUNT_TYPE_tab.delete;
             OVERPROVISIONAL_QTY_tab.delete;
             OVER_PROV_CONF_QTY_tab.delete;
             CONFIRMED_QTY_tab.delete;
             PROVISIONAL_QTY_tab.delete;
             asgmt_sys_status_code_tab.delete;
             capacity_quantity_tab.delete;
             overcommitment_quantity_tab.delete;
             availability_quantity_tab.delete;
             overcommitment_flag_tab.delete;
             availability_flag_tab.delete;


             SELECT forecast_item_id, forecast_item_type,
                    project_org_id , expenditure_org_id,
                    project_organization_id, expenditure_organization_id ,
                    project_id, project_type_class, person_id ,
                    resource_id, borrowed_flag, assignment_id,
                    item_date, item_uom, item_quantity,
                    pvdr_period_set_name, pvdr_pa_period_name,
                    pvdr_gl_period_name, rcvr_period_set_name,
                    rcvr_pa_period_name, rcvr_gl_period_name,
                    global_exp_period_end_date, expenditure_type,
                    expenditure_type_class, cost_rejection_code,
                    rev_rejection_code, tp_rejection_code,
                    burden_rejection_code, other_rejection_code,
                    delete_flag, error_flag, provisional_flag,
                    JOB_ID,
                    TP_AMOUNT_TYPE,
                    OVERPROVISIONAL_QTY,
                    OVER_PROV_CONF_QTY,
                    CONFIRMED_QTY,
                    PROVISIONAL_QTY,
                    asgmt_sys_status_code, capacity_quantity,
                    overcommitment_quantity, availability_quantity,
                    overcommitment_flag, availability_flag
             BULK COLLECT INTO forecast_item_id_tab, forecast_item_type_tab,
                    project_org_id_tab, expenditure_org_id_tab,
                    project_organization_id_tab, expenditure_orgn_id_tab,
                    project_id_tab, project_type_class_tab, person_id_tab,
                    resource_id_tab, borrowed_flag_tab, assignment_id_tab,
                    item_date_tab, item_uom_tab, item_quantity_tab,
                    pvdr_period_set_name_tab, pvdr_pa_period_name_tab,
                    pvdr_gl_period_name_tab, rcvr_period_set_name_tab,
                    rcvr_pa_period_name_tab, rcvr_gl_period_name_tab,
                    global_exp_period_end_date_tab, expenditure_type_tab,
                    expenditure_type_class_tab, cost_rejection_code_tab,
                    rev_rejection_code_tab, tp_rejection_code_tab,
                    burden_rejection_code_tab, other_rejection_code_tab,
                    delete_flag_tab, error_flag_tab, provisional_flag_tab,
                    JOB_ID_tab,
                    TP_AMOUNT_TYPE_tab,
                    OVERPROVISIONAL_QTY_tab,
                    OVER_PROV_CONF_QTY_tab,
                    CONFIRMED_QTY_tab,
                    PROVISIONAL_QTY_tab,
                    asgmt_sys_status_code_tab, capacity_quantity_tab,
                    overcommitment_quantity_tab, availability_quantity_tab,
                    overcommitment_flag_tab, availability_flag_tab
             FROM   pa_forecast_items
             WHERE  assignment_id = p_assignment_id
             AND    delete_flag   = 'N'
             AND    item_date BETWEEN trunc(p_start_date) AND
                                             trunc(p_end_date) + 1 - (1/86400)
             order by item_date, forecast_item_id ;

             IF nvl(forecast_item_id_tab.COUNT,0) = 0 THEN

                Print_message('NO DATA Leaving Fetch_FI_Hdr');
                x_return_status := lv_return_status;

                RETURN;

             END IF;

             -- Move to one table FROM multiple tables

             FOR j IN forecast_item_id_tab.FIRST..forecast_item_id_tab.LAST LOOP
                 TmpHdrTab(j).forecast_item_id := forecast_item_id_tab(j);
                 TmpHdrTab(j).forecast_item_type := forecast_item_type_tab(j);
                 TmpHdrTab(j).project_org_id  := project_org_id_tab(j);
                 TmpHdrTab(j).expenditure_org_id := expenditure_org_id_tab(j);
                 TmpHdrTab(j).project_organization_id :=
                                          project_organization_id_tab(j);
                 TmpHdrTab(j).expenditure_organization_id  :=
                                          expenditure_orgn_id_tab(j);
                 TmpHdrTab(j).project_id := project_id_tab(j);
                 TmpHdrTab(j).project_type_class := project_type_class_tab(j);
                 TmpHdrTab(j).person_id  := person_id_tab(j);
                 TmpHdrTab(j).resource_id := resource_id_tab(j);
                 TmpHdrTab(j).borrowed_flag := borrowed_flag_tab(j);
                 TmpHdrTab(j).assignment_id := assignment_id_tab(j);
                 TmpHdrTab(j).item_date := item_date_tab(j);
                 TmpHdrTab(j).item_uom := item_uom_tab(j);
                 TmpHdrTab(j).item_quantity := item_quantity_tab(j);
                 TmpHdrTab(j).pvdr_period_set_name :=
                                          pvdr_period_set_name_tab(j);
                 TmpHdrTab(j).pvdr_pa_period_name := pvdr_pa_period_name_tab(j);
                 TmpHdrTab(j).pvdr_gl_period_name := pvdr_gl_period_name_tab(j);
                 TmpHdrTab(j).rcvr_period_set_name :=
                                         rcvr_period_set_name_tab(j);
                 TmpHdrTab(j).rcvr_pa_period_name := rcvr_pa_period_name_tab(j);
                 TmpHdrTab(j).rcvr_gl_period_name := rcvr_gl_period_name_tab(j);
                 TmpHdrTab(j).global_exp_period_end_date :=
                                         global_exp_period_end_date_tab(j);
                 TmpHdrTab(j).expenditure_type := expenditure_type_tab(j);
                 TmpHdrTab(j).expenditure_type_class :=
                                         expenditure_type_class_tab(j);
                 TmpHdrTab(j).cost_rejection_code := cost_rejection_code_tab(j);
                 TmpHdrTab(j).rev_rejection_code := rev_rejection_code_tab(j);
                 TmpHdrTab(j).tp_rejection_code := tp_rejection_code_tab(j);
                 TmpHdrTab(j).burden_rejection_code :=
                                         burden_rejection_code_tab(j);
                 TmpHdrTab(j).other_rejection_code :=
                                         other_rejection_code_tab(j);
                 TmpHdrTab(j).delete_flag := delete_flag_tab(j);
                 TmpHdrTab(j).error_flag := error_flag_tab(j);
                 TmpHdrTab(j).provisional_flag := provisional_flag_tab(j);
                 TmpHdrTab(j).JOB_ID := JOB_ID_tab(j);
                 TmpHdrTab(j).TP_AMOUNT_TYPE := TP_AMOUNT_TYPE_tab(j);
                 TmpHdrTab(j).OVERPROVISIONAL_QTY := OVERPROVISIONAL_QTY_tab(j);
                 TmpHdrTab(j).OVER_PROV_CONF_QTY := OVER_PROV_CONF_QTY_tab(j);
                 TmpHdrTab(j).CONFIRMED_QTY := CONFIRMED_QTY_tab(j);
                 TmpHdrTab(j).PROVISIONAL_QTY := PROVISIONAL_QTY_tab(j);
                 TmpHdrTab(j).asgmt_sys_status_code := asgmt_sys_status_code_tab(j);
                 TmpHdrTab(j).capacity_quantity := capacity_quantity_tab(j);
                 TmpHdrTab(j).overcommitment_quantity :=  overcommitment_quantity_tab(j);
                 TmpHdrTab(j).availability_quantity :=  availability_quantity_tab(j);
                 TmpHdrTab(j).overcommitment_flag := overcommitment_flag_tab(j);
                 TmpHdrTab(j).availability_flag := availability_flag_tab(j);

             END LOOP;

             x_dbFIHdrTab := TmpHdrTab;

             --Print_message('!!!x_dbFIHdrTab(1).provisional_flag: ' || x_dbFIHdrTab(1).provisional_flag);
             --Print_message('!!!x_dbFIHdrTab(1).item_date: ' || x_dbFIHdrTab(1).provisional_flag);
             Print_message('Leaving Fetch_FI_Hdr');

             PA_DEBUG.Reset_Err_Stack;

             x_return_status := lv_return_status;

       EXCEPTION

              WHEN OTHERS THEN
                  print_message('Failed in Fetch_FI_Hdr api');
                  print_message('SQLCODE'||sqlcode||sqlerrm);

                  x_msg_count     := 1;
                  x_msg_data      := sqlerrm;
                  x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

                  FND_MSG_PUB.add_exc_msg
                      (p_pkg_name   =>
                              'PA_FORECASTITEM_PVT.Fetch_FI_Hdr',
                       p_procedure_name => PA_DEBUG.G_Err_Stack);

		               If x_msg_count = 1 THEN
				              pa_interface_utils_pub.get_messages
				                (p_encoded        => FND_API.G_TRUE,
					               p_msg_index      => 1,
					               p_msg_count      => x_msg_count,
					               p_msg_data       => x_msg_data,
					               p_data           => l_data , -- 4537865
					               p_msg_index_out  => l_msg_index_out );
						x_msg_data := l_data ; -- 4537865
		               End If;
                  Print_message(x_msg_data);

                  RAISE;


       END  Fetch_FI_Hdr;

/* ---------------------------------------------------------------------
|   Procedure  :   Fetch_FI_Dtl
|   Purpose    :   To get existing forecast item details
|                  (Requirement , Assignment)FOR the given assignment ID
|                  which fall BETWEEN startdate AND end date
|   Parameters :   p_FI_Type        - Forecast Item Type
|                                     'R' - Requirement
|                                     'A' - Assignment
|                  p_assignment_id  - Input Assignment ID
|                  p_resource_id    - Input Resource ID
|                                     (only IF forecast item type is Assignment)
|                  p_start_date     - Current Start DATE FOR forecast item
|                  p_end_date       - Current END DATE FOR forecast item
|                  x_dbFIDtlTab     - Holds the data retrieved FROM the database
|                  x_return_status     -
|                  x_msg_count         -
|                  x_msg_data          -
+----------------------------------------------------------------------*/
       PROCEDURE  Fetch_FI_Dtl(
                  p_assignment_id    IN    NUMBER,
                  p_resource_id      IN    NUMBER,
                  p_start_date       IN    DATE,
                  p_end_date         IN    DATE,
                  x_dbFIDtlTab       OUT   NOCOPY PA_FORECAST_GLOB.FIDtlTabTyp, /* 2674619 - Nocopy change */
                  x_return_status    OUT NOCOPY  VARCHAR2, -- 4537865
                  x_msg_count        OUT NOCOPY  NUMBER, -- 4537865
                  x_msg_data         OUT NOCOPY  VARCHAR2) IS -- 4537865

		   l_data VARCHAR2(2000) ; -- 4537865
	           l_msg_index_out	            NUMBER;
             forecast_item_id_tab            PA_FORECAST_GLOB.NumberTabTyp;
             amount_type_id_tab              PA_FORECAST_GLOB.NumberTabTyp;
             line_num_tab                    PA_FORECAST_GLOB.NumberTabTyp;
             resource_type_code_tab          PA_FORECAST_GLOB.VCTabTyp;
             person_billable_flag_tab        PA_FORECAST_GLOB.VC1TabTyp;
             item_date_tab                   PA_FORECAST_GLOB.DateTabTyp;
             item_UOM_tab                    PA_FORECAST_GLOB.VCTabTyp;
             item_quantity_tab               PA_FORECAST_GLOB.NumberTabTyp;
             expenditure_org_id_tab          PA_FORECAST_GLOB.NumberTabTyp;
             project_org_id_tab              PA_FORECAST_GLOB.NumberTabTyp;
             PJI_SUMMARIZED_FLAG_tab         PA_FORECAST_GLOB.VC1TabTyp;
             CAPACITY_QUANTITY_tab         PA_FORECAST_GLOB.NumberTabTyp;
             OVERCOMMITMENT_QTY_tab         PA_FORECAST_GLOB.NumberTabTyp;
             OVERPROVISIONAL_QTY_tab         PA_FORECAST_GLOB.NumberTabTyp;
             OVER_PROV_CONF_QTY_tab         PA_FORECAST_GLOB.NumberTabTyp;
             CONFIRMED_QTY_tab         PA_FORECAST_GLOB.NumberTabTyp;
             PROVISIONAL_QTY_tab         PA_FORECAST_GLOB.NumberTabTyp;
             JOB_ID_tab         PA_FORECAST_GLOB.NumberTabTyp;
             PROJECT_ID_tab         PA_FORECAST_GLOB.NumberTabTyp;
             RESOURCE_ID_tab         PA_FORECAST_GLOB.NumberTabTyp;
             EXP_ORGANIZATION_ID_tab         PA_FORECAST_GLOB.NumberTabTyp;
             pvdr_acct_curr_code_tab         PA_FORECAST_GLOB.VC15TabTyp;
             pvdr_acct_amount_tab            PA_FORECAST_GLOB.NumberTabTyp;
             rcvr_acct_curr_code_tab         PA_FORECAST_GLOB.VC15TabTyp;
             rcvr_acct_amount_tab            PA_FORECAST_GLOB.NumberTabTyp;
             proj_currency_code_tab          PA_FORECAST_GLOB.VC15TabTyp;
             proj_amount_tab                 PA_FORECAST_GLOB.NumberTabTyp;
             denom_currency_code_tab         PA_FORECAST_GLOB.VC15TabTyp;
             denom_amount_tab                PA_FORECAST_GLOB.NumberTabTyp;
             tp_amount_type_tab              PA_FORECAST_GLOB.VCTabTyp;
             billable_flag_tab               PA_FORECAST_GLOB.VC1TabTyp;
             forecast_summarized_code_tab    PA_FORECAST_GLOB.VCTabTyp;
             util_summarized_code_tab        PA_FORECAST_GLOB.VCTabTyp;
             work_type_id_tab                PA_FORECAST_GLOB.NumberTabTyp;
             resource_util_category_id_tab   PA_FORECAST_GLOB.NumberTabTyp;
             org_util_category_id_tab        PA_FORECAST_GLOB.NumberTabTyp;
             resource_util_weighted_tab      PA_FORECAST_GLOB.NumberTabTyp;
             org_util_weighted_tab           PA_FORECAST_GLOB.NumberTabTyp;
             provisional_flag_tab            PA_FORECAST_GLOB.VC1TabTyp;
             reversed_flag_tab               PA_FORECAST_GLOB.VC1TabTyp;
             net_zero_flag_tab               PA_FORECAST_GLOB.VC1TabTyp;
             reduce_capacity_flag_tab        PA_FORECAST_GLOB.VC1TabTyp;
             line_num_reversed_tab           PA_FORECAST_GLOB.NumberTabTyp;

             TmpDtlTab                       PA_FORECAST_GLOB.FIDtlTabTyp;

             lv_return_status  VARCHAR2(30);

       BEGIN

             lv_return_status := FND_API.G_RET_STS_SUCCESS;

             Print_message('Entering Fetch_FI_Dtl');

             PA_DEBUG.Init_err_stack(
                       'PA_FORECASTITEM_PVT.Fetch_FI_Dtl');

             TmpDtlTab.delete;
             forecast_item_id_tab.delete;
             amount_type_id_tab.delete;
             line_num_tab.delete;
             resource_type_code_tab.delete;
             person_billable_flag_tab.delete;
             item_date_tab.delete;
             item_UOM_tab.delete;
             item_quantity_tab.delete;
             expenditure_org_id_tab.delete;
             project_org_id_tab.delete;
             PJI_SUMMARIZED_FLAG_tab.delete;
             CAPACITY_QUANTITY_tab.delete;
             OVERCOMMITMENT_QTY_tab.delete;
             OVERPROVISIONAL_QTY_tab.delete;
             OVER_PROV_CONF_QTY_tab.delete;
             CONFIRMED_QTY_tab.delete;
             PROVISIONAL_QTY_tab.delete;
             JOB_ID_tab.delete;
             PROJECT_ID_tab.delete;
             RESOURCE_ID_tab.delete;
             EXP_ORGANIZATION_ID_tab.delete;
             pvdr_acct_curr_code_tab.delete;
             pvdr_acct_amount_tab.delete;
             rcvr_acct_curr_code_tab.delete;
             rcvr_acct_amount_tab.delete;
             proj_currency_code_tab.delete;
             proj_amount_tab.delete;
             denom_currency_code_tab.delete;
             denom_amount_tab.delete;
             tp_amount_type_tab.delete;
             billable_flag_tab.delete;
             forecast_summarized_code_tab.delete;
             util_summarized_code_tab.delete;
             work_type_id_tab.delete;
             resource_util_category_id_tab.delete;
             org_util_category_id_tab.delete;
             resource_util_weighted_tab.delete;
             org_util_weighted_tab.delete;
             provisional_flag_tab.delete;
             reversed_flag_tab.delete;
             net_zero_flag_tab.delete;
             reduce_capacity_flag_tab.delete;
             line_num_reversed_tab.delete;


             SELECT dtl.forecast_item_id, dtl.amount_type_id,
                    dtl.line_num, dtl.resource_type_code,
                    dtl.person_billable_flag, dtl.item_UOM, dtl.item_date,
                    dtl.PJI_SUMMARIZED_FLAG,
                    dtl.CAPACITY_QUANTITY,
                    dtl.OVERCOMMITMENT_QTY,
                    dtl.OVERPROVISIONAL_QTY,
                    dtl.OVER_PROV_CONF_QTY,
                    dtl.CONFIRMED_QTY,
                    dtl.PROVISIONAL_QTY,
                    dtl.JOB_ID,
                    dtl.PROJECT_ID,
                    dtl.RESOURCE_ID,
                    dtl.EXPENDITURE_ORGANIZATION_ID,
                    dtl.item_quantity, dtl.expenditure_org_id,
                    dtl.project_org_id, dtl.pvdr_acct_curr_code,
                    dtl.pvdr_acct_amount, dtl.rcvr_acct_curr_code,
                    dtl.rcvr_acct_amount, dtl.proj_currency_code,
                    dtl.proj_amount, dtl.denom_currency_code,
                    dtl.denom_amount, dtl.tp_amount_type, dtl.billable_flag,
                    dtl.forecast_summarized_code, dtl.util_summarized_code,
                    dtl.work_type_id, dtl.resource_util_category_id,
                    dtl.org_util_category_id, dtl.resource_util_weighted,
                    dtl.org_util_weighted, dtl.provisional_flag,
                    dtl.reversed_flag, dtl.net_zero_flag,
                    dtl.reduce_capacity_flag, dtl.line_num_reversed
             BULK COLLECT INTO forecast_item_id_tab,amount_type_id_tab,
                    line_num_tab, resource_type_code_tab,
                    person_billable_flag_tab, item_UOM_tab, item_date_tab,
                    PJI_SUMMARIZED_FLAG_tab,
                    CAPACITY_QUANTITY_tab,
                    OVERCOMMITMENT_QTY_tab,
                    OVERPROVISIONAL_QTY_tab,
                    OVER_PROV_CONF_QTY_tab,
                    CONFIRMED_QTY_tab,
                    PROVISIONAL_QTY_tab,
                    JOB_ID_tab,
                    PROJECT_ID_tab,
                    RESOURCE_ID_tab,
                    EXP_ORGANIZATION_ID_tab,
                    item_quantity_tab, expenditure_org_id_tab,
                    project_org_id_tab, pvdr_acct_curr_code_tab,
                    pvdr_acct_amount_tab, rcvr_acct_curr_code_tab,
                    rcvr_acct_amount_tab, proj_currency_code_tab,
                    proj_amount_tab, denom_currency_code_tab,
                    denom_amount_tab, tp_amount_type_tab, billable_flag_tab,
                    forecast_summarized_code_tab, util_summarized_code_tab,
                    work_type_id_tab, resource_util_category_id_tab,
                    org_util_category_id_tab, resource_util_weighted_tab,
                    org_util_weighted_tab, provisional_flag_tab,
                    reversed_flag_tab, net_zero_flag_tab,
                    reduce_capacity_flag_tab, line_num_reversed_tab
             FROM   pa_forecast_item_details dtl , pa_forecast_items hdr
             WHERE  hdr.assignment_id = p_assignment_id
             AND    hdr.delete_flag = 'N'
             AND    dtl.forecast_item_id = hdr.forecast_item_id
             AND    dtl.item_date BETWEEN trunc(p_start_date) AND
                                          trunc(p_end_date) + 1 - (1/86400)
             AND    dtl.line_num =
                       (SELECT max(line_num)
                        FROM pa_forecast_item_details dtl1
                        WHERE dtl1.forecast_item_id = hdr.forecast_item_id)
             order by dtl.item_date, dtl.forecast_item_id ;

             IF nvl(forecast_item_id_tab.COUNT,0) = 0 THEN

                Print_message('NO DATA Leaving Fetch_FI_Dtl');
                x_return_status := lv_return_status;

                RETURN;

             END IF;

             -- Move to one table FROM multiple tables

             FOR j IN forecast_item_id_tab.FIRST..forecast_item_id_tab.LAST LOOP

                 TmpDtlTab(j).forecast_item_id := forecast_item_id_tab(j);
                 TmpDtlTab(j).amount_type_id :=amount_type_id_tab(j);
                 TmpDtlTab(j).line_num := line_num_tab(j);
                 TmpDtlTab(j).resource_type_code := resource_type_code_tab(j);
                 TmpDtlTab(j).person_billable_flag :=
                                 person_billable_flag_tab(j);
                 TmpDtlTab(j).item_Uom := item_UOM_tab(j);
                 TmpDtlTab(j).item_date := item_date_tab(j);
                 TmpDtlTab(j).item_quantity := item_quantity_tab(j);
                 TmpDtlTab(j).expenditure_org_id := expenditure_org_id_tab(j);
                 TmpDtlTab(j).project_org_id := project_org_id_tab(j);
                 TmpDtlTab(j).pvdr_acct_curr_code := pvdr_acct_curr_code_tab(j);
                 TmpDtlTab(j).PJI_SUMMARIZED_FLAG := PJI_SUMMARIZED_FLAG_tab(j);
                 TmpDtlTab(j).CAPACITY_QUANTITY := CAPACITY_QUANTITY_tab(j);
                 TmpDtlTab(j).OVERCOMMITMENT_QTY := OVERCOMMITMENT_QTY_tab(j);
                 TmpDtlTab(j).OVERPROVISIONAL_QTY := OVERPROVISIONAL_QTY_tab(j);
                 TmpDtlTab(j).OVER_PROV_CONF_QTY := OVER_PROV_CONF_QTY_tab(j);
                 TmpDtlTab(j).CONFIRMED_QTY := CONFIRMED_QTY_tab(j);
                 TmpDtlTab(j).PROVISIONAL_QTY := PROVISIONAL_QTY_tab(j);
                 TmpDtlTab(j).JOB_ID := JOB_ID_tab(j);
                 TmpDtlTab(j).PROJECT_ID := PROJECT_ID_tab(j);
                 TmpDtlTab(j).RESOURCE_ID := RESOURCE_ID_tab(j);
                 TmpDtlTab(j).EXPENDITURE_ORGANIZATION_ID := EXP_ORGANIZATION_ID_tab(j);
                 TmpDtlTab(j).pvdr_acct_amount := pvdr_acct_amount_tab(j);
                 TmpDtlTab(j).rcvr_acct_curr_code :=
                                 rcvr_acct_curr_code_tab(j);
                 TmpDtlTab(j).rcvr_acct_amount := rcvr_acct_amount_tab(j);
                 TmpDtlTab(j).proj_currency_code := proj_currency_code_tab(j);
                 TmpDtlTab(j).proj_amount := proj_amount_tab(j);
                 TmpDtlTab(j).denom_currency_code := denom_currency_code_tab(j);
                 TmpDtlTab(j).denom_amount := denom_amount_tab(j);
                 TmpDtlTab(j).tp_amount_type := tp_amount_type_tab(j);
                 TmpDtlTab(j).billable_flag := billable_flag_tab(j);
                 TmpDtlTab(j).forecast_summarized_code :=
                                 forecast_summarized_code_tab(j);
                 TmpDtlTab(j).util_summarized_code :=
                                 util_summarized_code_tab(j);
                 TmpDtlTab(j).work_type_id := work_type_id_tab(j);
                 TmpDtlTab(j).resource_util_category_id :=
                                 resource_util_category_id_tab(j);
                 TmpDtlTab(j).org_util_category_id :=
                                 org_util_category_id_tab(j);
                 TmpDtlTab(j).resource_util_weighted :=
                                 resource_util_weighted_tab(j);
                 TmpDtlTab(j).org_util_weighted :=
                                 org_util_weighted_tab(j);
                 TmpDtlTab(j).provisional_flag := provisional_flag_tab(j);
                 TmpDtlTab(j).reversed_flag := reversed_flag_tab(j);
                 TmpDtlTab(j).net_zero_flag := net_zero_flag_tab(j);
                 TmpDtlTab(j).reduce_capacity_flag :=
                                             reduce_capacity_flag_tab(j);
                 TmpDtlTab(j).line_num_reversed := line_num_reversed_tab(j);

             END LOOP;

             x_dbFIDtlTab := TmpDtlTab;

             Print_message('Leaving Fetch_FI_Dtl');

             PA_DEBUG.Reset_Err_Stack;

             x_return_status := lv_return_status;

       EXCEPTION

              WHEN OTHERS THEN
                  print_message('Failed in Fetch_FI_Dtl api');
                  print_message('SQLCODE'||sqlcode||sqlerrm);

                  x_msg_count     := 1;
                  x_msg_data      := sqlerrm;
                  x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

                  FND_MSG_PUB.add_exc_msg
                      (p_pkg_name   =>
                              'PA_FORECASTITEM_PVT.Fetch_FI_Dtl',
                       p_procedure_name => PA_DEBUG.G_Err_Stack);

		               If x_msg_count = 1 THEN
				              pa_interface_utils_pub.get_messages
				                (p_encoded        => FND_API.G_TRUE,
					               p_msg_index      => 1,
					               p_msg_count      => x_msg_count,
					               p_msg_data       => x_msg_data,
					               p_data           => l_data , -- 4537865
					               p_msg_index_out  => l_msg_index_out );
							x_msg_data := l_data ;  -- 4537865
		               End If;
                  Print_message(x_msg_data);

                  RAISE;

       END  Fetch_FI_Dtl;

/* ---------------------------------------------------------------------
|   Procedure  :   Build_FI_Hdr_Req
|   Purpose    :   To create new/modified forecast item (Requirement) record
|                  FOR the item DATEs that are built IN the p_FIDayTab
|   Parameters :   p_AsgnDtlRec - Assignment details
|                  p_DBHdrTab   - Holds forecast item records which are
|                                 already existing
|                  p_FIDayTab   - Holds all item_dates,item_quantity,
|                                 status_code FOR the current run.
|                   i) action_flag component of this tab will be updated
|                      to indicate the following
|                      a) N  : New record - item_date does not exist
|                      b) DN : Delete AND create new -
|                                item DATE exists but expenditure OU/
|                                expenditure organization/expenditure type/
|                                expenditure type class/ borrowed flag has
|                                changed.
|                                Existing record is reversed(deleted) AND new
|                                record is created
|                      c) RN : Reverse AND create new -
|                              Quantity has changed.
|                              IN header : quantity is updated.
|                              IN detail :
|                                IF summarized existing line should be reversed
|                                   AND new line created
|                                IF not summarized existing line should be
|                                   updated to reflect new quantity
|                      d) C :  No change IN header
|                              Check FOR any changes IN detail record for
|                              person_billable_flag, provisional_flag,
|                              work_type OR resource_type
|                   ii) forecast_item_id component of this tab will be updated
|                       to hold the forecast_item_id FOR new record. Same will
|                       be used FOR detail record
|                  iii) project_org_id,expenditure_org_id,work_type_id,
|                       person_billable_flag, tp_amount_type : These values
|                       are required FOR detail record processing. These are
|                       also updated IN this tab.
|
|                  x_FIHdrInsTab - Will RETURN all forecast item records that
|                                  are new
|                  x_FIHdrUpdTab - Will RETURN all forecast item records that
|                                  are modified
|                  x_return_status     -
|                  x_msg_count         -
|                  x_msg_data          -
+----------------------------------------------------------------------*/
       PROCEDURE  Build_FI_Hdr_Req(
                  p_AsgnDtlRec    IN     PA_FORECAST_GLOB.AsgnDtlRecord,
                  p_DBHdrTab      IN     PA_FORECAST_GLOB.FIHdrTabTyp,
                  p_FIDayTab      IN OUT NOCOPY PA_FORECAST_GLOB.FIDayTabTyp, /* 2674619 - Nocopy change */
                  x_FIHdrInsTab   OUT    NOCOPY PA_FORECAST_GLOB.FIHdrTabTyp, /* 2674619 - Nocopy change */
                  x_FIHdrUpdTab   OUT    NOCOPY PA_FORECAST_GLOB.FIHdrTabTyp, /* 2674619 - Nocopy change */
                  x_return_status OUT    NOCOPY VARCHAR2, -- 4537865
                  x_msg_count     OUT    NOCOPY NUMBER, -- 4537865
                  x_msg_data      OUT    NOCOPY VARCHAR2) IS -- 4537865

		   l_data VARCHAR2(2000) ; -- 4537865
	           l_msg_index_out	            NUMBER;
             lv_project_id            NUMBER;
             lv_project_org_id        NUMBER;
             lv_project_orgn_id       NUMBER;
             lv_project_type_class    VARCHAR2(30);
             lv_project_status_code   VARCHAR2(30);
             lv_pvdr_period_set_name  VARCHAR2(30);
             lv_rcvr_period_set_name  VARCHAR2(30);
             lv_pvdr_pa_period_name   VARCHAR2(30):= NULL;

             ld_pvdrpa_startdate_tab  PA_FORECAST_GLOB.DateTabTyp;
             ld_pvdrpa_enddate_tab    PA_FORECAST_GLOB.DateTabTyp;
             lv_pvdrpa_name_tab       PA_FORECAST_GLOB.periodnametabtyp;
             lv_pvpa_index            NUMBER ;

             ld_pvdrgl_startdate_tab  PA_FORECAST_GLOB.DateTabTyp;
             ld_pvdrgl_enddate_tab    PA_FORECAST_GLOB.DateTabTyp;
             lv_pvdrgl_name_tab       PA_FORECAST_GLOB.periodnametabtyp;
             lv_pvgl_index            NUMBER ;

             ld_rcvrpa_startdate_tab  PA_FORECAST_GLOB.DateTabTyp;
             ld_rcvrpa_enddate_tab    PA_FORECAST_GLOB.DateTabTyp;
             lv_rcvrpa_name_tab       PA_FORECAST_GLOB.periodnametabtyp;
             lv_rcpa_index            NUMBER ;

             ld_rcvrgl_startdate_tab  PA_FORECAST_GLOB.DateTabTyp;
             ld_rcvrgl_enddate_tab    PA_FORECAST_GLOB.DateTabTyp;
             lv_rcvrgl_name_tab       PA_FORECAST_GLOB.periodnametabtyp;
             lv_rcgl_index            NUMBER ;


             lv_WeekDateRange_Tab     PA_FORECAST_GLOB.WeekDatesRangeFcTabTyp;
             lv_wk_index              NUMBER;

             lv_borrowed_flag         VARCHAR2(1) := 'N';
             lv_action_code           VARCHAR2(30);
             lv_include_in_forecast   VARCHAR2(1) := 'N';
             lv_forecast_item_id      NUMBER;
             lv_work_type_id          NUMBER;
             lv_error_flag            VARCHAR2(1) := 'N';
             lv_prev_index            NUMBER := 0;
             lv_rejection_code        VARCHAR2(30);

             d_in                     NUMBER := 1;
             TmpDayTab                PA_FORECAST_GLOB.FIDayTabTyp;
             TmpInsTab                PA_FORECAST_GLOB.FIHdrTabTyp;
             i_in                     NUMBER := 1;
             TmpUpdTab                PA_FORECAST_GLOB.FIHdrTabTyp;
             u_in                     NUMBER := 1;
             TmpHdrRec                PA_FORECAST_GLOB.FIHdrRecord;

             lv_return_status  VARCHAR2(30);
             lv_err_msg        VARCHAR2(30);
             lv_call_pos       VARCHAR2(50);
             tmp_status_code   VARCHAR2(30);

       BEGIN

             lv_return_status := FND_API.G_RET_STS_SUCCESS;

             Print_message('Entering Build_FI_Hdr_Req');

             PA_DEBUG.Init_err_stack(
                       'PA_FORECASTITEM_PVT.Build_FI_Hdr_Req');

             TmpDayTab.Delete;
             TmpInsTab.Delete;
             TmpUpdTab.Delete;
             ld_pvdrpa_startdate_tab.delete;
             ld_pvdrpa_enddate_tab.delete;
             lv_pvdrpa_name_tab.delete;
             ld_pvdrgl_startdate_tab.delete;
             ld_pvdrgl_enddate_tab.delete;
             lv_pvdrgl_name_tab.delete;
             ld_rcvrpa_startdate_tab.delete;
             ld_rcvrpa_enddate_tab.delete;
             lv_rcvrpa_name_tab.delete;
             ld_rcvrgl_startdate_tab.delete;
             ld_rcvrgl_enddate_tab.delete;
             lv_rcvrgl_name_tab.delete;


             TmpDayTab := p_FIDayTab;

             Print_message(
                                  'Req - Get_period_set_name (pvdr) ');

             lv_pvdr_period_set_name :=
                          PA_FORECAST_ITEMS_UTILS.get_period_set_name
                                      (p_AsgnDtlRec.expenditure_org_id);

             if lv_pvdr_period_set_name = 'NO_DATA_FOUND' THEN

                   lv_pvdr_period_set_name := '-99';
                   lv_rejection_code := 'PVDR_PRD_SET_NAME_NOT_FOUND';
                   lv_error_flag := 'Y';

             end if;

             Print_message(
                            'Req - Calling Get_Project_Dtls');


             Get_Project_Dtls (p_AsgnDtlRec.project_id, lv_project_org_id,
                               lv_project_orgn_id, lv_work_type_id,
                               lv_project_type_class, lv_project_status_code,
                               lv_return_status, x_msg_count, x_msg_data);

             IF lv_return_status <> FND_API.G_RET_STS_SUCCESS THEN

                lv_err_msg := 'No_Project_Record - Req';
                RAISE NO_DATA_FOUND;

             END IF;

             Print_message(
                                  'Req - Get_period_set_name (rcvr) ');

             Print_message('lv_project_org_id: ' || lv_project_org_id);
             lv_rcvr_period_set_name :=
                        PA_FORECAST_ITEMS_UTILS.get_period_set_name (
                                            lv_project_org_id);

             if lv_rcvr_period_set_name = 'NO_DATA_FOUND' THEN

                lv_rcvr_period_set_name := '-99';

                IF lv_rejection_code IS NULL THEN

                   lv_rejection_code := 'RCVR_PRD_SET_NAME_NOT_FOUND';

                END IF;

                lv_error_flag := 'Y';

             end if;


             Print_message(
                                  'Req - Get_pa_period_name (pvdr) ');

             PA_FORECAST_ITEMS_UTILS.get_pa_period_name(
                                      p_AsgnDtlRec.expenditure_org_id,
                                      p_AsgnDtlRec.start_date,
                                      p_AsgnDtlRec.end_date,
                                      ld_pvdrpa_startdate_tab,
                                      ld_pvdrpa_enddate_tab,
                                      lv_pvdrpa_name_tab);
             lv_pvpa_index := lv_pvdrpa_name_tab.FIRST;

             Print_message(
                                  'Req - Get_gl_period_name (pvdr) ');

             PA_FORECAST_ITEMS_UTILS.get_gl_period_name(
                                      p_AsgnDtlRec.expenditure_org_id,
                                      p_AsgnDtlRec.start_date,
                                      p_AsgnDtlRec.end_date,
                                      ld_pvdrgl_startdate_tab,
                                      ld_pvdrgl_enddate_tab,
                                      lv_pvdrgl_name_tab);
             lv_pvgl_index := lv_pvdrgl_name_tab.FIRST;

             Print_message(
                                  'Req - Get_pa_period_name (rcvr) ');
             Print_message('lv_project_org_id: ' || lv_project_org_id);
             PA_FORECAST_ITEMS_UTILS.get_pa_period_name(
                                      lv_project_org_id,
                                      p_AsgnDtlRec.start_date,
                                      p_AsgnDtlRec.end_date,
                                      ld_rcvrpa_startdate_tab,
                                      ld_rcvrpa_enddate_tab,
                                      lv_rcvrpa_name_tab);
             lv_rcpa_index := lv_rcvrpa_name_tab.FIRST;

             Print_message(
                                  'Req - Get_gl_period_name (rcvr) ');
             Print_message('lv_project_org_id: ' || lv_project_org_id);
             PA_FORECAST_ITEMS_UTILS.get_gl_period_name(
                                      lv_project_org_id,
                                      p_AsgnDtlRec.start_date,
                                      p_AsgnDtlRec.end_date,
                                      ld_rcvrgl_startdate_tab,
                                      ld_rcvrgl_enddate_tab,
                                      lv_rcvrgl_name_tab);
             lv_rcgl_index := lv_rcvrgl_name_tab.FIRST;


             Print_message(
                                  'Req - Get_week_dates_range_fc ');

             PA_FORECAST_ITEMS_UTILS.get_Week_Dates_Range_Fc(
                                      p_AsgnDtlRec.start_date,
                                      p_AsgnDtlRec.end_date,
                                      lv_WeekDateRange_Tab,
                                      x_return_status,
                                      x_msg_count,
                                      x_msg_data);
             lv_wk_index := lv_WeekDateRange_Tab.FIRST;

             lv_call_pos := 'Req : chk_borr';

             IF ((lv_project_org_id <> p_AsgnDtlRec.expenditure_org_id ) OR
                 (lv_project_orgn_id <>
                        p_AsgnDtlRec.expenditure_organization_id ))THEN

                    lv_borrowed_flag := 'Y';

             ELSE

                    lv_borrowed_flag := 'N';

             END IF;

             lv_call_pos := 'Req : bef_for';

             print_message('TmpDaytab.count: ' || TmpDaytab.count);
             if (TmpDaytab.count <> 0) then
             FOR i IN TmpDaytab.FIRST..TmpDaytab.LAST LOOP

                 IF TmpDaytab.EXISTS(i) then
                 lv_call_pos := 'Req : in_for';

                 lv_action_code := 'OPEN_ASGMT_PROJ_FORECASTING';

/* Bug No: 1967832 Added conditions before the call */

                 IF TmpDayTab(i).status_code = tmp_status_code
                 AND i>TmpDayTab.FIRST THEN

                    lv_include_in_forecast := lv_include_in_forecast;

                 ELSE
                    lv_include_in_forecast :=
                      pa_project_utils.check_prj_stus_action_allowed(
                                   TmpDayTab(i).status_code,
                                   lv_action_code);
                 tmp_status_code := TmpDayTab(i).status_code;

                 END IF;

                 TmpDayTab(i).include_in_forecast := lv_include_in_forecast;

/*
                 TmpDayTab(i).provisional_flag :=
                     PA_ASSIGNMENT_UTILS.Is_Provisional_Status(
                                          TmpDayTab(i).status_code,
                                          p_AsgnDtlRec.assignment_type);
*/

                 IF d_in <=  nvl(p_DbHdrTab.COUNT,0) THEN --Some Record Exists

                    lv_call_pos := 'Req : in_if 1';

                    IF trunc(TmpDayTab(i).item_date) <
                             trunc(p_DbHdrTab(d_in).item_date) THEN

                       -- This Item_date does not exist in Database
                       lv_call_pos := 'Req : in_if 2';

                       IF (TmpDayTab(i).action_flag = 'D') OR
                            (
                             NVL(TmpDayTab(i).CAPACITY_QUANTITY,0) = 0 AND
                             NVL(TmpDayTab(i).OVERCOMMITMENT_QTY,0) = 0 AND
-- Start fix for bug 2504222 (changed for consistency, not vital for fix)
                             NVL(TmpDayTab(i).OVERCOMMITMENT_QUANTITY,0) = 0 AND
-- End fix for bug 2504222
                             NVL(TmpDayTab(i).OVERPROVISIONAL_QTY,0) = 0 AND
                             NVL(TmpDayTab(i).OVER_PROV_CONF_QTY,0) = 0 AND
                             NVL(TmpDayTab(i).CONFIRMED_QTY,0) = 0 AND
                             NVL(TmpDayTab(i).PROVISIONAL_QTY,0) = 0 AND
                             TmpDayTab(i).item_quantity = 0
                             ) THEN

                          TmpDayTab(i).action_flag := 'I';

                       ELSE

                          TmpDayTab(i).action_flag := 'N';

                       END IF;

                    ELSIF trunc(TmpDayTab(i).item_date) =
                          trunc(p_DbHdrTab(d_in).item_date) THEN

                       -- This Item_date exists in Database
                       lv_call_pos := 'Req : in_else 2';

                       IF (TmpDayTab(i).action_flag = 'D') OR
                              (
                               NVL(TmpDayTab(i).CAPACITY_QUANTITY,0) = 0 AND
                               NVL(TmpDayTab(i).OVERCOMMITMENT_QTY,0) = 0 AND
-- Start fix for bug 2504222 (changed for consistency, not vital for fix)
                               NVL(TmpDayTab(i).OVERCOMMITMENT_QUANTITY,0) = 0 AND
-- End fix for bug 2504222
                               NVL(TmpDayTab(i).OVERPROVISIONAL_QTY,0) = 0 AND
                               NVL(TmpDayTab(i).OVER_PROV_CONF_QTY,0) = 0 AND
                               NVL(TmpDayTab(i).CONFIRMED_QTY,0) = 0 AND
                               NVL(TmpDayTab(i).PROVISIONAL_QTY,0) = 0 AND
                               TmpDayTab(i).item_quantity = 0
                               ) THEN

                          print_message('Req : in_if 3 : TmpUpdTab(u_in).error_flag := N');
                          lv_call_pos := 'Req : in_if 3';
                          TmpDayTab(i).action_flag := 'D';
                          TmpUpdTab(u_in) := p_DbHdrTab(d_in);
                          TmpUpdTab(u_in).CAPACITY_QUANTITY := NULL;
                          TmpUpdTab(u_in).OVERCOMMITMENT_QTY := NULL;
-- Start fix for bug 2504222 (changed for consistency, not vital for fix)
                          TmpUpdTab(u_in).OVERCOMMITMENT_QUANTITY := NULL;
-- End fix for bug 2504222
                          TmpUpdTab(u_in).OVERPROVISIONAL_QTY := NULL;
                          TmpUpdTab(u_in).OVER_PROV_CONF_QTY := NULL;
                          TmpUpdTab(u_in).CONFIRMED_QTY := NULL;
                          TmpUpdTab(u_in).PROVISIONAL_QTY := NULL;
                          TmpUpdTab(u_in).item_quantity := 0;
                          TmpUpdTab(u_in).delete_flag := 'Y';
                          TmpUpdTab(u_in).error_flag := 'N';
                          TmpUpdTab(u_in).other_rejection_code := NULL;
                          u_in := u_in + 1;

                       ELSIF p_DbHdrTab(d_in).error_flag = 'Y' THEN

                          print_message('Req : in_else 3');
                          lv_call_pos := 'Req : in_else 3';
                          -- Previous Run generated Error. Rerun

                          TmpDayTab(i).action_flag := 'E';
                          TmpDayTab(i).forecast_item_id :=
                                    p_DbHdrTab(d_in).forecast_item_id;

                       ELSIF ( (p_AsgnDtlRec.expenditure_org_id <>
                               p_DbHdrTab(d_in).expenditure_org_id) OR
                           (p_AsgnDtlRec.expenditure_organization_id <>
                               p_DbHdrTab(d_in).expenditure_organization_id) OR
                           (p_AsgnDtlRec.expenditure_type <>
                               p_DbHdrTab(d_in).expenditure_type) OR
                           (p_AsgnDtlRec.expenditure_type_class <>
                               p_DbHdrTab(d_in).expenditure_type_class) OR
                           (nvl(p_AsgnDtlRec.fcst_tp_amount_type,'Z') <>
                               nvl(p_DbHdrTab(d_in).tp_amount_type,'Z')) OR
                           (lv_borrowed_flag <> p_DbHdrTab(d_in).borrowed_flag) OR
                           (NVL(TmpDayTab(i).asgmt_sys_status_code,'Z') <> NVL(p_DbHdrTab(d_in).asgmt_sys_status_code,'Z'))
                          ) THEN

                          print_message('Req : in_else 3a');
                          lv_call_pos := 'Req : in_else 3a';
                          -- If any of above values differ,
                          -- existing record is to be deleted
                          -- and new record should be created

                          TmpDayTab(i).action_flag := 'DN';
                          TmpUpdTab(u_in) := p_DbHdrTab(d_in);
                          TmpUpdTab(u_in).CAPACITY_QUANTITY := NULL;
                          TmpUpdTab(u_in).OVERCOMMITMENT_QTY := NULL;
-- Start fix for bug 2504222 (changed for consistency, not vital for fix)
                          TmpUpdTab(u_in).OVERCOMMITMENT_QUANTITY := NULL;
-- End fix for bug 2504222
                          TmpUpdTab(u_in).OVERPROVISIONAL_QTY := NULL;
                          TmpUpdTab(u_in).OVER_PROV_CONF_QTY := NULL;
                          TmpUpdTab(u_in).CONFIRMED_QTY := NULL;
                          TmpUpdTab(u_in).PROVISIONAL_QTY := NULL;
                          TmpUpdTab(u_in).item_quantity := 0;
                          TmpUpdTab(u_in).delete_flag := 'Y';
                          u_in := u_in + 1;

                       ELSIF (
                              TmpDayTab(i).item_quantity <>
                                    p_DbHdrTab(d_in).item_quantity
                              ) THEN

                          print_message('Req : in_else 3b');
                          lv_call_pos := 'Req : in_else 3b';
                           -- Quantity has changed.
                           -- Existing detail record should be reversed
                           -- (if already summarized)and new record created
                           -- with same forecast item id and next line number
                           --  or updated ( if not summarized)
                           -- Summarization check is done in detail processing
                           -- In header, quantity is updated

                          TmpDayTab(i).action_flag := 'RN';
                          TmpDayTab(i).expenditure_org_id :=
                                      p_AsgnDtlRec.expenditure_org_id;
                          TmpDayTab(i).expenditure_organization_id :=
                                      p_AsgnDtlRec.expenditure_organization_id;
                          TmpDayTab(i).tp_amount_type :=
                                      p_AsgnDtlRec.fcst_tp_amount_type;
                          TmpDayTab(i).project_id :=
                                      p_AsgnDtlRec.project_id;
                          TmpDayTab(i).resource_id :=
                                      p_AsgnDtlRec.resource_id;
                          TmpDayTab(i).project_org_id := lv_project_org_id;
                          TmpUpdTab(u_in) := p_DbHdrTab(d_in);
                          TmpUpdTab(u_in).CAPACITY_QUANTITY :=
                                        TmpDayTab(i).CAPACITY_QUANTITY;
                          TmpUpdTab(u_in).OVERCOMMITMENT_QTY :=
                                        TmpDayTab(i).OVERCOMMITMENT_QTY;
-- Start fix for bug 2504222 (changed for consistency, not vital for fix)
                          TmpUpdTab(u_in).OVERCOMMITMENT_QUANTITY :=
                                        TmpDayTab(i).OVERCOMMITMENT_QUANTITY;
-- End fix for bug 2504222
                          TmpUpdTab(u_in).OVERPROVISIONAL_QTY :=
                                        TmpDayTab(i).OVERPROVISIONAL_QTY;
                          TmpUpdTab(u_in).OVER_PROV_CONF_QTY :=
                                        TmpDayTab(i).OVER_PROV_CONF_QTY;
                          TmpUpdTab(u_in).CONFIRMED_QTY :=
                                        TmpDayTab(i).CONFIRMED_QTY;
                          TmpUpdTab(u_in).PROVISIONAL_QTY :=
                                        TmpDayTab(i).PROVISIONAL_QTY;
                          TmpUpdTab(u_in).item_quantity :=
                                        TmpDayTab(i).item_quantity;
                          TmpUpdTab(u_in).asgmt_sys_status_code :=
                                        TmpDayTab(i).asgmt_sys_status_code;

                          u_in := u_in + 1;

                       ELSE

                          print_message('Req : in_else 3d');
                          lv_call_pos := 'Req : in_else 3d';
                          -- Detail record should be checked for any changes
                          -- in its values. No change in header

                          TmpDayTab(i).action_flag := 'C';
                          TmpDayTab(i).expenditure_org_id :=
                                       p_AsgnDtlRec.expenditure_org_id;
                          TmpDayTab(i).project_org_id := lv_project_org_id;
                          TmpDayTab(i).tp_amount_type := p_AsgnDtlRec.fcst_tp_amount_type;
                          TmpDayTab(i).project_id := p_AsgnDtlRec.project_id;
                          TmpDayTab(i).resource_id := p_AsgnDtlRec.resource_id;
                          TmpDayTab(i).EXPENDITURE_ORGANIZATION_ID := p_AsgnDtlRec.EXPENDITURE_ORGANIZATION_ID;

                       END IF;
                       d_in := d_in + 1;
                    END IF;

                 END IF;

                 lv_call_pos := 'Req : data create';
                 IF (TmpDayTab(i).action_flag IN ('N', 'DN','E') AND
                         (
                          NVL(TmpDayTab(i).CAPACITY_QUANTITY,0) > 0 OR
                          NVL(TmpDayTab(i).OVERCOMMITMENT_QTY,0) > 0 OR
-- Start fix for bug 2504222 (changed for consistency, not vital for fix)
                          NVL(TmpDayTab(i).OVERCOMMITMENT_QUANTITY,0) > 0 OR
-- End fix for bug 2504222
                          NVL(TmpDayTab(i).OVERPROVISIONAL_QTY,0) > 0 OR
                          NVL(TmpDayTab(i).OVER_PROV_CONF_QTY,0) > 0 OR
                          NVL(TmpDayTab(i).CONFIRMED_QTY,0) > 0 OR
                          NVL(TmpDayTab(i).PROVISIONAL_QTY,0) > 0 OR
                          TmpDayTab(i).item_quantity > 0
                          ))THEN

                    print_message('Req : in if data create');
                    lv_call_pos := 'Req : in if data create';
                    IF TmpDayTab(i).action_flag <> 'E' THEN

                         lv_forecast_item_id :=
                              PA_FORECAST_ITEMS_UTILS.get_next_forecast_item_id;

                         TmpDayTab(i).forecast_item_id := lv_forecast_item_id;

                    ELSE

                         lv_forecast_item_id := TmpDayTab(i).forecast_item_id;

                    END IF;

                    TmpHdrRec.forecast_item_id := lv_forecast_item_id;
                    TmpHdrRec.forecast_item_type := 'R';
                    TmpHdrRec.project_org_id := lv_project_org_id;
                    TmpDayTab(i).project_org_id := lv_project_org_id;
                    TmpDayTab(i).expenditure_org_id :=
                                         p_AsgnDtlRec.expenditure_org_id;
                    TmpDayTab(i).expenditure_organization_id :=
                                      p_AsgnDtlRec.expenditure_organization_id;
                    TmpDayTab(i).tp_amount_type :=
                                      p_AsgnDtlRec.fcst_tp_amount_type;
                    TmpDayTab(i).project_id :=
                                      p_AsgnDtlRec.project_id;
                    TmpDayTab(i).resource_id :=
                                      p_AsgnDtlRec.resource_id;
                    TmpHdrRec.expenditure_org_id :=
                                         p_AsgnDtlRec.expenditure_org_id;
                    TmpHdrRec.project_organization_id :=
                                         lv_project_orgn_id;
                    TmpHdrRec.expenditure_organization_id :=
                                   p_AsgnDtlRec.expenditure_organization_id;
                    TmpHdrRec.project_id := p_AsgnDtlRec.project_id;
                    TmpHdrRec.project_type_class := lv_project_type_class;
                    TmpHdrRec.person_id := NULL;
                    TmpHdrRec.resource_id := p_AsgnDtlRec.resource_id;
                    TmpHdrRec.borrowed_flag := lv_borrowed_flag;
                    TmpHdrRec.assignment_id := p_AsgnDtlRec.assignment_id;
                    TmpHdrRec.item_date := TmpDayTab(i).item_date;
                    TmpHdrRec.item_UOM := 'HOURS';
                    TmpHdrRec.item_quantity := TmpDayTab(i).item_quantity;
                    TmpHdrRec.pvdr_period_set_name :=
                                         lv_pvdr_period_set_name;
                    TmpHdrRec.asgmt_sys_status_code := TmpDayTab(i).asgmt_sys_status_code;
                    TmpHdrRec.capacity_quantity := null;
                    TmpHdrRec.OVERPROVISIONAL_QTY := NULL;
                    TmpHdrRec.OVER_PROV_CONF_QTY := NULL;
                    TmpHdrRec.CONFIRMED_QTY := NULL;
                    TmpHdrRec.PROVISIONAL_QTY := NULL;
                    TmpHdrRec.overcommitment_quantity := null;
                    TmpHdrRec.availability_quantity := null;
                    TmpHdrRec.overcommitment_flag := null;
                    TmpHdrRec.availability_flag := null;
                    TmpHdrRec.tp_amount_type := p_AsgnDtlRec.fcst_tp_amount_type;
                    print_message('lv_rejection_code := NULL');
                    lv_error_flag := 'N';
                    lv_rejection_code := NULL;

                    lv_call_pos := 'Req : pvdrpa';
                    IF (nvl(ld_pvdrpa_startdate_tab.count,0) = 0) THEN

                        lv_error_flag := 'Y';
                        lv_rejection_code := 'PVDR_PA_PRD_NAME_NOT_FOUND';

                    ELSIF (trunc(TmpHdrRec.item_date) NOT BETWEEN
                         trunc(ld_pvdrpa_startdate_tab(lv_pvpa_index)) AND
                         trunc(ld_pvdrpa_enddate_tab(lv_pvpa_index))) THEN

                       --print_message('JM:10');
                       lv_prev_index := lv_pvpa_index;

                       LOOP

                           IF lv_pvpa_index > nvl(ld_pvdrpa_startdate_tab.COUNT,0) THEN

                              lv_error_flag := 'Y';
                              lv_rejection_code := 'PVDR_PA_PRD_NAME_NOT_FOUND';

                           END IF;

                           EXIT WHEN lv_error_flag = 'Y' OR
                             ( (trunc(TmpHdrRec.item_date) >=
                             trunc(ld_pvdrpa_startdate_tab(lv_pvpa_index))) AND
                               (trunc(TmpHdrRec.item_date) <=
                                  trunc(ld_pvdrpa_enddate_tab(lv_pvpa_index))));

                           lv_pvpa_index := lv_pvpa_index + 1;
                           print_message('JM:11');

                       END LOOP;

                    END IF;

                    IF lv_error_flag = 'Y' THEN

                       lv_pvpa_index := lv_prev_index;
                       TmpHdrRec.pvdr_pa_period_name := '-99';

                    ELSE

                       TmpHdrRec.pvdr_pa_period_name :=
                                   lv_pvdrpa_name_tab(lv_pvpa_index);
                    END IF;

                    print_message('lv_error_flag := N');

                    lv_error_flag := 'N';

                    lv_call_pos := 'Req : pvdrgl';
                    IF (nvl(ld_pvdrgl_startdate_tab.count,0) = 0) THEN

                        lv_error_flag := 'Y';

                        IF (lv_rejection_code IS NULL) THEN

                            lv_rejection_code := 'PVDR_GL_PRD_NAME_NOT_FOUND';

                        END IF;

                    ELSIF (trunc(TmpHdrRec.item_date) NOT BETWEEN
                              trunc(ld_pvdrgl_startdate_tab(lv_pvgl_index)) AND
                              trunc(ld_pvdrgl_enddate_tab(lv_pvgl_index))) THEN

                        print_message('JM:11');
                        lv_prev_index := lv_pvgl_index;

                        LOOP

                           IF lv_pvgl_index > ld_pvdrgl_startdate_tab.COUNT THEN

                              lv_error_flag := 'Y';

                              IF (lv_rejection_code IS NULL) THEN

                                 lv_rejection_code :=
                                        'PVDR_GL_PRD_NAME_NOT_FOUND';

                              END IF;

                           END IF;

                           EXIT WHEN lv_error_flag = 'Y' OR
                             ((trunc(TmpHdrRec.item_date) >=
                             trunc(ld_pvdrgl_startdate_tab(lv_pvgl_index))) AND
                              (trunc(TmpHdrRec.item_date) <=
                             trunc(ld_pvdrgl_enddate_tab(lv_pvgl_index))));

                            print_message('JM:13');
                            lv_pvgl_index := lv_pvgl_index + 1;

                        END LOOP;

                    END IF;

                    IF lv_error_flag = 'Y' THEN

                       lv_pvgl_index := lv_prev_index;
                       TmpHdrRec.pvdr_gl_period_name := '-99';

                    ELSE

                       TmpHdrRec.pvdr_gl_period_name :=
                                  lv_pvdrgl_name_tab(lv_pvgl_index);

                    END IF;

                    TmpHdrRec.rcvr_period_set_name :=
                                 lv_rcvr_period_set_name;

                    print_message('lv_error_flag := N 15');
                    lv_error_flag := 'N';

                    lv_call_pos := 'Req : rcvrpa';
                    IF (ld_rcvrpa_startdate_tab.count = 0) THEN

                        lv_error_flag := 'Y';

                        IF (lv_rejection_code IS NULL) THEN

                            lv_rejection_code := 'RCVR_PA_PRD_NAME_NOT_FOUND';

                        END IF;

                    ELSIF (trunc(TmpHdrRec.item_date) NOT BETWEEN
                              trunc(ld_rcvrpa_startdate_tab(lv_rcpa_index)) AND
                              trunc(ld_rcvrpa_enddate_tab(lv_rcpa_index))) THEN

                       print_message('JM:14');
                       lv_prev_index := lv_rcpa_index;

                       LOOP
                           IF lv_rcpa_index > ld_rcvrpa_startdate_tab.COUNT THEN

                              lv_error_flag := 'Y';

                              IF (lv_rejection_code IS NULL) THEN

                                 lv_rejection_code :=
                                        'RCVR_PA_PRD_NAME_NOT_FOUND';

                              END IF;

                           END IF;

                           EXIT WHEN  lv_error_flag = 'Y' OR
                             ( (trunc(TmpHdrRec.item_date) >=
                              trunc(ld_rcvrpa_startdate_tab(lv_rcpa_index))) AND
                               (trunc(TmpHdrRec.item_date) <=
                              trunc(ld_rcvrpa_enddate_tab(lv_rcpa_index))));

                           print_message('JM:15');
                           lv_rcpa_index := lv_rcpa_index + 1;

                       END LOOP;

                    END IF;

                    IF lv_error_flag = 'Y' THEN

                       lv_rcpa_index := lv_prev_index;
                       TmpHdrRec.rcvr_pa_period_name := '-99';

                    ELSE

                       TmpHdrRec.rcvr_pa_period_name :=
                                  lv_rcvrpa_name_tab(lv_rcpa_index);
                    END IF;

                    print_message('lv_error_flag := N 20');
                    lv_error_flag := 'N';

                    lv_call_pos := 'Req : rcvrgl';
                    IF (ld_rcvrgl_startdate_tab.count = 0) THEN

                        lv_error_flag := 'Y';

                        IF (lv_rejection_code IS NULL) THEN

                            lv_rejection_code := 'RCVR_GL_PRD_NAME_NOT_FOUND';

                        END IF;

                    ELSIF (trunc(TmpHdrRec.item_date) NOT BETWEEN
                               trunc(ld_rcvrgl_startdate_tab(lv_rcgl_index)) AND
                               trunc(ld_rcvrgl_enddate_tab(lv_rcgl_index))) THEN

                       lv_prev_index := lv_rcgl_index;
                       print_message('JM:16');

                       LOOP
                           IF lv_rcgl_index > ld_rcvrgl_startdate_tab.COUNT THEN

                              lv_error_flag := 'Y';

                              IF (lv_rejection_code IS NULL) THEN

                                  lv_rejection_code :=
                                           'RCVR_GL_PRD_NAME_NOT_FOUND';

                              END IF;

                           END IF;

                           EXIT WHEN lv_error_flag = 'Y' OR
                              ( (trunc(TmpHdrRec.item_date) >=
                              trunc(ld_rcvrgl_startdate_tab(lv_rcgl_index))) AND
                                (trunc(TmpHdrRec.item_date) <=
                              trunc(ld_rcvrgl_enddate_tab(lv_rcgl_index))));

                            print_message('JM:17');
                            lv_rcgl_index := lv_rcgl_index + 1;

                       END LOOP;


                    END IF;

                    IF lv_error_flag = 'Y' THEN

                       lv_rcgl_index := lv_prev_index;
                       TmpHdrRec.rcvr_gl_period_name := '-99';

                    ELSE

                       TmpHdrRec.rcvr_gl_period_name :=
                                  lv_rcvrgl_name_tab(lv_rcgl_index);
                    END IF;


                    lv_call_pos := 'Req : wkdtrange';
                    IF (trunc(TmpHdrRec.item_date) NOT BETWEEN
                      trunc(lv_WeekDateRange_Tab(lv_wk_index).week_start_date)
                                         AND
                      trunc(lv_WeekDateRange_Tab(lv_wk_index).week_end_date))
                                                         THEN

                       print_message('JM:18');
                       lv_prev_index := lv_wk_index;

                       LOOP
                           IF lv_wk_index > lv_WeekDateRange_Tab.COUNT THEN

                              lv_error_flag := 'Y';
                              lv_wk_index := lv_prev_index;

                           END IF;
                           print_message('JM:19');

                           EXIT WHEN lv_error_flag = 'Y' OR
                           ((trunc(TmpHdrRec.item_date) >=
                            trunc(
                            lv_WeekDateRange_Tab(lv_wk_index).week_start_date))
                                                  AND
                            (trunc(TmpHdrRec.item_date) <=
                            trunc(
                            lv_WeekDateRange_Tab(lv_wk_index).week_end_date)));

                            lv_wk_index := lv_wk_index + 1;

                            print_message('JM:20');
                       END LOOP;

                    print_message('JM:21');
                    END IF;

                    print_message('JM:22');
                    TmpHdrRec.global_exp_period_end_date :=
                           lv_WeekDateRange_Tab(lv_wk_index).week_end_date;

                    TmpHdrRec.expenditure_type :=
                                   p_AsgnDtlRec.expenditure_type;
                    TmpHdrRec.expenditure_type_class :=
                                    p_AsgnDtlRec.expenditure_type_class;
                    TmpHdrRec.cost_rejection_code := NULL;
                    TmpHdrRec.rev_rejection_code  := NULL;
                    TmpHdrRec.Tp_rejection_code  := NULL;
                    TmpHdrRec.Burden_rejection_code  := NULL;
                    TmpHdrRec.Other_rejection_code  := lv_rejection_code;
                    TmpHdrRec.Delete_Flag  := 'N';
                    TmpHdrRec.Provisional_flag  :=
                                   TmpDayTab(i).provisional_flag;
                    TmpHdrRec.asgmt_sys_status_code := TmpDayTab(i).asgmt_sys_status_code;

                    IF (lv_rejection_code IS NOT NULL ) THEN

                       TmpHdrRec.Error_Flag  := 'Y';
                       TmpDayTab(i).Error_Flag := 'Y';

                    ELSE

                       print_message('TmpHdrRec.Error_Flag  := N 25');
                       TmpHdrRec.Error_Flag  := 'N';
                       TmpHdrRec.Other_rejection_code  := NULL;

                    END IF;

                    IF TmpDayTab(i).action_flag IN ('N','DN')  THEN

                       print_message('JM:23');
                       TmpInsTab(i_in) := TmpHdrRec;
                       i_in := i_in + 1;

                    ELSE

                       print_message('JM:24');
                       TmpDayTab(i).action_flag := 'RN';
                       TmpUpdTab(u_in) := TmpHdrRec;
                       u_in := u_in + 1;

                    END IF ;

                Print_message('***********');
                Print_message(
                    ' item_date :' || TmpHdrRec.item_date);
/*
                Print_message(
                    'fct_item_id:' || TmpHdrRec.forecast_item_id ||
                    ' fct_itm_typ:' || TmpHdrRec.forecast_item_type ||
                    ' prj_org_id:' || TmpHdrRec.project_org_id ||
                    ' exp_org_id:' || TmpHdrRec.expenditure_org_id||
                    chr(10)|| 'exp_orgn_id:' ||
                               TmpHdrRec.expenditure_organization_id ||
                    ' prj_orgn_id:' ||
                               TmpHdrRec.project_organization_id ||
                    ' prj_id:' || TmpHdrRec.project_id);

                Print_message(
                     'prj_typ_cls:' || TmpHdrRec.project_type_class ||
                     ' person_id:' || TmpHdrRec.person_id||
                     ' res_id:' || TmpHdrRec.resource_id ||
                     ' brw_flg:' || TmpHdrRec.borrowed_flag ||
                     ' asgn_id:' || TmpHdrRec.assignment_id ||
                     ' item_uom:' || TmpHdrRec.item_uom ||
                     ' itm_qty:' || TmpHdrRec.item_quantity);

                Print_message(
                    'pvd_set_nme:' || TmpHdrRec.pvdr_period_set_name ||
                    ' pvd_pa_name:' ||
                               TmpHdrRec.pvdr_pa_period_name ||
                    chr(10) || 'pvd_gl_name:' ||
                               TmpHdrRec.pvdr_gl_period_name ||
                    ' rcv_set_nme:' ||
                               TmpHdrRec.rcvr_period_set_name ||
                    chr(10) || 'rcv_pa_name:' ||
                               TmpHdrRec.rcvr_pa_period_name ||
                    ' rcv_gl_name:' ||
                               TmpHdrRec.rcvr_gl_period_name ||
                    chr(10) || 'glb_end_dt:' ||
                               TmpHdrRec.global_exp_period_end_date);

                Print_message(
                    'exp_type:' || TmpHdrRec.expenditure_type ||
                    ' exp_typ_cls:' ||
                               TmpHdrRec.expenditure_type_class ||
                    chr(10) || 'oth_rej_cde:' ||
                               TmpHdrRec.other_rejection_code ||
                    ' Del_flag:' || TmpHdrRec.delete_flag ||
                    ' Err_flag:' || TmpHdrRec.error_flag ||
                    ' Prv_flag:' || TmpHdrRec.provisional_flag);
*/

                 END IF;
             END IF;
             END LOOP;
             end if;

             x_FIHdrInsTab.Delete;
             x_FIHdrUpdTab.Delete;

             x_FIHdrInsTab := TmpInsTab;
             x_FIHdrUpdTab := TmpUpdTab;
             p_FIDayTab    := TmpDayTab;

             Print_message('Leaving Build_FI_Hdr_Req');

             PA_DEBUG.Reset_Err_Stack;

             x_return_status := lv_return_status;

        EXCEPTION


             WHEN NO_DATA_FOUND THEN
                  print_message('Failed in Build_FI_Hdr_Req api');
                  print_message('SQLCODE'||sqlcode||sqlerrm);

                  x_msg_count     := 1;
                  x_msg_data      := sqlerrm ;
                  x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

                  FND_MSG_PUB.add_exc_msg
                      (p_pkg_name   =>
                              'PA_FORECASTITEM_PVT.Build_FI_Hdr_Req',
                       p_procedure_name => PA_DEBUG.G_Err_Stack);

		               If x_msg_count = 1 THEN
				              pa_interface_utils_pub.get_messages
				                (p_encoded        => FND_API.G_TRUE,
					               p_msg_index      => 1,
					               p_msg_count      => x_msg_count,
					               p_msg_data       => x_msg_data,
					               p_data           => l_data , -- 4537865
					               p_msg_index_out  => l_msg_index_out );
						x_msg_data := l_data ; -- 4537865
		               End If;
                  Print_message(x_msg_data);
                  Print_message(lv_call_pos);

                  RAISE;


             WHEN OTHERS THEN

                  x_msg_count     := 1;
                  x_msg_data      := sqlerrm;
                  x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

                  FND_MSG_PUB.add_exc_msg
                      (p_pkg_name   =>
                              'PA_FORECASTITEM_PVT.Build_FI_Hdr_Req',
                       p_procedure_name => PA_DEBUG.G_Err_Stack);

		               If x_msg_count = 1 THEN
				              pa_interface_utils_pub.get_messages
				                (p_encoded        => FND_API.G_TRUE,
					               p_msg_index      => 1,
					               p_msg_count      => x_msg_count,
					               p_msg_data       => x_msg_data,
					               p_data           => l_data,
					               p_msg_index_out  => l_msg_index_out );
						x_msg_data := l_data ; -- 4537865
		               End If;
                  Print_message(x_msg_data);
                  Print_message(lv_call_pos);

                  RAISE;

       END Build_FI_Hdr_Req;

/* ---------------------------------------------------------------------
|   Procedure  :   Build_FI_Dtl_Req
|   Purpose    :   To create new/modified forecast item detail(Requirement)
|                  record FOR the item DATEs that are built IN the p_FIDayTab
|   Parameters :   p_AsgnDtlRec - Assignment details
|                  p_DBDtlTab   - Holds forecast item detail records which are
|                                 already existing
|                  p_FIDayTab   - Holds all item_dates,item_quantity,
|                                 status_code FOR the current run.
|                       action_flag component of this tab already indicates
|                       (By Header Processing) the following :
|                      a) N  : New record - item_date does not exist
|                      b) DN : Delete AND create new -
|                                item DATE exists but expenditure OU/
|                                expenditure organization/expenditure type/
|                                expenditure type class/ borrowed flag has
|                                changed.
|                                Existing record is reversed(deleted) AND new
|                                record is created
|                      c) RN : Reverse AND create new -
|                              Quantity has changed.
|                              IN header : quantity is updated.
|                              IN detail :
|                                IF summarized existing line should be reversed
|                                   AND new line created
|                                IF not summarized existing line should be
|                                   updated to reflect new quantity
|                      d) C :  No change IN header
|                              Check FOR any changes IN detail record for
|                              person_billable_flag, provisional_flag,
|                              work_type OR resource_type
|                  x_FIDtlInsTab - Will RETURN all forecast item detail records
|                                  that are new
|                  x_FIDtlUpdTab - Will RETURN all forecast item detail records
|                                  that are modified
|                  x_return_status     -
|                  x_msg_count         -
|                  x_msg_data          -
+----------------------------------------------------------------------*/

       PROCEDURE Build_FI_Dtl_Req(
                 p_AsgnDtlRec    IN     PA_FORECAST_GLOB.AsgnDtlRecord,
                 p_DBDtlTab      IN     PA_FORECAST_GLOB.FIDtlTabTyp,
                 p_FIDayTab      IN     PA_FORECAST_GLOB.FIDayTabTyp,
                 x_FIDtlInsTab   OUT    NOCOPY PA_FORECAST_GLOB.FIDtlTabTyp, /* 2674619 - Nocopy change */
                 x_FIDtlUpdTab   OUT    NOCOPY PA_FORECAST_GLOB.FIDtlTabTyp, /* 2674619 - Nocopy change */
                 x_return_status OUT    NOCOPY VARCHAR2, -- 4537865
                 x_msg_count     OUT    NOCOPY NUMBER, -- 4537865
                 x_msg_data      OUT    NOCOPY VARCHAR2) IS -- 4537865


	           l_msg_index_out	            NUMBER;
		  l_data VARCHAR2(2000) ; -- 4537865
             d_in                     NUMBER := 1; -- index FOR p_dbDtlTab;
             TmpDayTab                PA_FORECAST_GLOB.FIDayTabTyp;
             TmpInsTab                PA_FORECAST_GLOB.FIDtlTabTyp;
             i_in                     NUMBER := 1; -- index FOR TmpDayTab;
             TmpUpdTab                PA_FORECAST_GLOB.FIDtlTabTyp;
             u_in                     NUMBER := 1; -- index FOR TmpDayTab;
             TmpDtlRec                PA_FORECAST_GLOB.FIDtlRecord;

             lv_billable_flag         VARCHAR2(1);
             l_resutilweighted      NUMBER;
             l_orgutilweighted      NUMBER;
             l_resutilcategoryid      NUMBER;
             l_orgutilcategoryid      NUMBER;

             lv_inc_forecast_flag     VARCHAR2(3) := 'N';
             lv_inc_util_flag     VARCHAR2(3) := 'N';
             lv_provisional_flag      VARCHAR2(3);
             lv_next_line_num         NUMBER;
             lv_new_fcast_sum_code    VARCHAR2(1);
             lv_new_util_sum_code    VARCHAR2(1);
             lv_amount_type_id        NUMBER;
             l_ReduceCapacityFlag     VARCHAR2(1);
             lv_return_status  VARCHAR2(30);


       BEGIN
             lv_return_status := FND_API.G_RET_STS_SUCCESS;

             PA_DEBUG.Init_err_stack(
                       'PA_FORECASTITEM_PVT.Build_FI_Dtl_Req');

             Print_message( 'Entering Build_FI_Dtl_Req');

             TmpInsTab.Delete;
             TmpUpdTab.Delete;
             TmpDayTab.Delete;
             TmpDayTab := p_FIDayTab;

             Print_message(
                                  'Req - Get_work_type_details');

             PA_FORECAST_ITEMS_UTILS.get_work_type_details(
                                      p_AsgnDtlRec.work_type_id,
                                      lv_billable_flag,
                                      l_resutilweighted,
                                      l_orgutilweighted,
                                      l_resutilcategoryid,
                                      l_orgutilcategoryid,
                                      l_ReduceCapacityFlag);

             lv_amount_type_id := get_AmountTypeID;

             if (TmpDayTab.count <> 0) then
             FOR i IN TmpDayTab.FIRST..TmpDayTab.LAST LOOP
                 IF TmpDayTab.exists(i) then

                 lv_inc_forecast_flag := TmpDayTab(i).include_in_forecast;

                 lv_inc_util_flag := 'X';

                 IF lv_inc_forecast_flag IN ('NO', 'N') THEN

                    lv_new_fcast_sum_code := 'X';

                 ELSE

                    lv_new_fcast_sum_code := 'N';

                 END IF;

                 IF lv_inc_util_flag IN ('NO', 'N') THEN

                    lv_new_util_sum_code := 'X';

                 ELSE

                    lv_new_util_sum_code := 'N';

                 END IF;

                 lv_provisional_flag :=
                             TmpDayTab(i).provisional_flag;

                 lv_next_line_num    := 1;

                 IF d_in <= p_DBDtlTab.COUNT THEN

                    IF trunc(TmpDayTab(i).item_date) <
                              trunc(p_DBDtlTab(d_in).item_date) THEN

                       lv_next_line_num    := 1;

                       -- New record

                    ELSIF trunc(TmpDayTab(i).item_date) =
                               trunc(p_dbDtlTab(d_in).item_date) THEN
                       -- Record exists

                       IF TmpDayTab(i).action_flag  = 'C' THEN

                          -- Check IF there are changes in
                             -- provisional_flag, person_billable, resource_type
                             -- work_type_id, summarized_code

                          IF  (p_DBDtlTab(d_in).provisional_flag <>
                                  lv_provisional_flag) OR
                              (NVL(p_DBDtlTab(d_in).forecast_summarized_code,'Y')
                                          IN ('N', 'Y')
                                 AND lv_new_fcast_sum_code = 'X') OR
                              (p_DBDtlTab(d_in).forecast_summarized_code = 'X'
                                 AND lv_new_fcast_sum_code = 'N') OR
                              (NVL(p_DBDtlTab(d_in).PJI_SUMMARIZED_FLAG,'Y')
                                          IN ('N', 'Y')
                                 AND lv_new_util_sum_code = 'X') OR
                              (NVL(p_DBDtlTab(d_in).PJI_SUMMARIZED_FLAG,'Y') = 'X'
                                 AND lv_new_util_sum_code = 'N') OR

                              (NVL(p_DBDtlTab(d_in).util_summarized_code,'Y')
                                          IN ('N', 'Y')
                                 AND lv_new_util_sum_code = 'X') OR
                              (p_DBDtlTab(d_in).util_summarized_code = 'X'
                                 AND lv_new_util_sum_code = 'N') OR
                              (p_DBDtlTab(d_in).work_type_id <>
                                  p_AsgnDtlRec.work_type_id) THEN

                               TmpDayTab(i).action_flag := 'RN';

                          ELSE

                               TmpDayTab(i).action_flag := 'I';

                          END IF;

                       END IF;


                       IF TmpDayTab(i).action_flag  IN ('DN','D') THEN

                          -- Change IN header attribute values
                          -- update existing line FOR flags
                          -- Reverse detail line IF forecast/util
                              --summarization done
                          -- IF summ not done IN existing line;
                               -- item_quantity to zero
                               -- net_zero flag to Y
                               -- forecast/util summ_flag = 'X'
                          -- New line generation is done at the end

                          lv_next_line_num := 1;

                          IF NVL(p_DBDtlTab(d_in).forecast_summarized_code,'Y')
                                            IN ('N', 'X', 'E')
                             AND NVL(p_DBDtlTab(d_in).PJI_SUMMARIZED_FLAG,'Y')
                                            IN ('N', 'X', 'E')
                             AND NVL(p_DBDtlTab(d_in).util_summarized_code,'Y')
                                            IN ('N', 'X', 'E') THEN

                             TmpUpdTab(u_in) := p_dbDtlTab(d_in);
                             TmpUpdTab(u_in).forecast_summarized_code := 'X';
                             TmpUpdTab(u_in).PJI_SUMMARIZED_FLAG := 'X';
                             TmpUpdTab(u_in).util_summarized_code := 'X';
                             TmpUpdTab(u_in).CAPACITY_QUANTITY := NULL;
                             TmpUpdTab(u_in).OVERCOMMITMENT_QTY := NULL;
                             TmpUpdTab(u_in).OVERPROVISIONAL_QTY := NULL;
                             TmpUpdTab(u_in).OVER_PROV_CONF_QTY := NULL;
                             TmpUpdTab(u_in).CONFIRMED_QTY := NULL;
                             TmpUpdTab(u_in).PROVISIONAL_QTY := NULL;
                             TmpUpdTab(u_in).item_quantity := 0;
                             TmpUpdTab(u_in).org_util_weighted :=0;
                             TmpUpdTab(u_in).resource_util_weighted :=0;
                             u_in := u_in + 1;

                          ELSE

                             TmpUpdTab(u_in) := p_DBDtlTab(d_in);
                             IF (
                                 nvl(p_DBDtlTab(d_in).CAPACITY_QUANTITY,0) > 0 OR
                                 nvl(p_DBDtlTab(d_in).OVERCOMMITMENT_QTY,0) > 0 OR
                                 nvl(p_DBDtlTab(d_in).OVERPROVISIONAL_QTY,0) > 0 OR
                                 nvl(p_DBDtlTab(d_in).OVER_PROV_CONF_QTY,0) > 0 OR
                                 nvl(p_DBDtlTab(d_in).CONFIRMED_QTY,0) > 0 OR
                                 nvl(p_DBDtlTab(d_in).PROVISIONAL_QTY,0) > 0 OR
                                 nvl(p_DBDtlTab(d_in).item_quantity,0) > 0
                                 )THEN

                                -- Generate reverse line
                                TmpInsTab(i_in) := p_DBDtlTab(d_in);
                                TmpInsTab(i_in).line_num :=
                                           p_DBDtlTab(d_in).line_num + 1;
                                IF (NVL(TmpInsTab(i_in).CAPACITY_QUANTITY,0) = 0) THEN
                                   TmpInsTab(i_in).CAPACITY_QUANTITY := NULL;
                                ELSE
                                   TmpInsTab(i_in).CAPACITY_QUANTITY := NVL(TmpInsTab(i_in).CAPACITY_QUANTITY,0) * -1;
                                END IF;
                                IF (NVL(TmpInsTab(i_in).OVERCOMMITMENT_QTY,0) = 0) THEN
                                   TmpInsTab(i_in).OVERCOMMITMENT_QTY := NULL;
                                ELSE
                                   TmpInsTab(i_in).OVERCOMMITMENT_QTY := NVL(TmpInsTab(i_in).OVERCOMMITMENT_QTY,0) * -1;
                                END IF;
                                IF (NVL(TmpInsTab(i_in).OVERPROVISIONAL_QTY,0) = 0) THEN
                                   TmpInsTab(i_in).OVERPROVISIONAL_QTY := NULL;
                                ELSE
                                   TmpInsTab(i_in).OVERPROVISIONAL_QTY := NVL(TmpInsTab(i_in).OVERPROVISIONAL_QTY,0) * -1;
                                END IF;
                                IF (NVL(TmpInsTab(i_in).OVER_PROV_CONF_QTY,0) = 0) THEN
                                   TmpInsTab(i_in).OVER_PROV_CONF_QTY := NULL;
                                ELSE
                                   TmpInsTab(i_in).OVER_PROV_CONF_QTY := NVL(TmpInsTab(i_in).OVER_PROV_CONF_QTY,0) * -1;
                                END IF;
                                IF (NVL(TmpInsTab(i_in).CONFIRMED_QTY,0) = 0) THEN
                                   TmpInsTab(i_in).CONFIRMED_QTY := NULL;
                                ELSE
                                   TmpInsTab(i_in).CONFIRMED_QTY := NVL(TmpInsTab(i_in).CONFIRMED_QTY,0) * -1;
                                END IF;
                                IF (NVL(TmpInsTab(i_in).PROVISIONAL_QTY,0) = 0) THEN
                                   TmpInsTab(i_in).PROVISIONAL_QTY := NULL;
                                ELSE
                                   TmpInsTab(i_in).PROVISIONAL_QTY := NVL(TmpInsTab(i_in).PROVISIONAL_QTY,0) * -1;
                                END IF;
                                TmpInsTab(i_in).item_quantity :=
                                           TmpInsTab(i_in).item_quantity * -1;
                                TmpInsTab(i_in).resource_util_weighted :=
                                          TmpInsTab(i_in).resource_util_weighted * -1;
                                TmpInsTab(i_in).org_util_weighted :=
                                          TmpInsTab(i_in).org_util_weighted * -1;
                                TmpInsTab(i_in).reversed_flag := 'N';
                                TmpInsTab(i_in).line_num_reversed :=
                                           p_DBDtlTab(d_in).line_num;
                                TmpInsTab(i_in).net_zero_flag := 'Y';

                                IF NVL(p_DBDtlTab(d_in).forecast_summarized_code,'Y') =
                                                     'Y' THEN

                                   TmpInsTab(i_in).forecast_summarized_code :=
                                                       'N';

                                ELSE

                                   TmpInsTab(i_in).forecast_summarized_code :=
                                      p_DBDtlTab(d_in).forecast_summarized_code;

                                END IF;

                    IF NVL(p_DBDtlTab(d_in).PJI_SUMMARIZED_FLAG,'Y') = 'Y' THEN
                      TmpInsTab(i_in).PJI_SUMMARIZED_FLAG := 'N';
                    ELSE
                      TmpInsTab(i_in).PJI_SUMMARIZED_FLAG :=
                              p_DBDtlTab(d_in).PJI_SUMMARIZED_FLAG;
                    END IF;

                                IF NVL(p_DBDtlTab(d_in).util_summarized_code,'Y') = 'Y'
                                       THEN

                                   TmpInsTab(i_in).util_summarized_code := 'N';

                                ELSE

                                   TmpInsTab(i_in).util_summarized_code :=
                                      p_DBDtlTab(d_in).util_summarized_code;

                                END IF;

                                i_in := i_in + 1;


                                -- update line
                                TmpUpdTab(u_in).reversed_flag := 'Y';

                             END IF;
                             TmpUpdTab(u_in).net_zero_flag := 'Y';
                             u_in := u_in + 1;

                          END IF;

                       ELSIF TmpDayTab(i).action_flag  = 'RN' THEN

                          -- No change IN header
                          -- There is change IN item_quantity/provisional_flag/
                             -- include IN forecast/work_type_id
                          -- If summarization is not done
                          --   same line to be updated with new values
                          --   generated. Save forecast_item_id

                          IF NVL(p_DBDtlTab(d_in).forecast_summarized_code,'Y')
                                             IN ('N', 'X', 'E')
                             AND NVL(p_DBDtlTab(d_in).PJI_SUMMARIZED_FLAG,'Y')
                                            IN ('N', 'X', 'E')
                             AND NVL(p_DBDtlTab(d_in).util_summarized_code,'Y')
                                             IN ('N', 'X', 'E') THEN

                             TmpDayTab(i).action_flag := 'RU';
                             TmpDayTab(i).forecast_item_id :=
                                          p_dbDtlTab(d_in).forecast_item_id;
                             lv_next_line_num := p_DBDtlTab(d_in).line_num;

                          ELSE

                             TmpDayTab(i).forecast_item_id :=
                                       p_dbDtlTab(d_in).forecast_item_id;
                             TmpUpdTab(u_in) := p_DBDtlTab(d_in);

                             lv_next_line_num :=
                                           p_dbdtltab(d_in).line_num + 1;

                             IF (
                                 nvl(p_DBDtlTab(d_in).CAPACITY_QUANTITY,0) > 0 OR
                                 nvl(p_DBDtlTab(d_in).OVERCOMMITMENT_QTY,0) > 0 OR
                                 nvl(p_DBDtlTab(d_in).OVERPROVISIONAL_QTY,0) > 0 OR
                                 nvl(p_DBDtlTab(d_in).OVER_PROV_CONF_QTY,0) > 0 OR
                                 nvl(p_DBDtlTab(d_in).CONFIRMED_QTY,0) > 0 OR
                                 nvl(p_DBDtlTab(d_in).PROVISIONAL_QTY,0) > 0 OR
                                 nvl(p_dbdtltab(d_in).item_quantity,0) > 0
                                 )THEN

                                -- Generate Reverse Line
                                TmpInsTab(i_in) := p_DBDtlTab(d_in);
                                TmpInsTab(i_in).line_num := lv_next_line_num;
                                lv_next_line_num := lv_next_line_num + 1;
                                IF (NVL(TmpInsTab(i_in).CAPACITY_QUANTITY,0) = 0) THEN
                                   TmpInsTab(i_in).CAPACITY_QUANTITY := NULL;
                                ELSE
                                   TmpInsTab(i_in).CAPACITY_QUANTITY := NVL(TmpInsTab(i_in).CAPACITY_QUANTITY,0) * -1;
                                END IF;
                                IF (NVL(TmpInsTab(i_in).OVERCOMMITMENT_QTY,0) = 0) THEN
                                   TmpInsTab(i_in).OVERCOMMITMENT_QTY := NULL;
                                ELSE
                                   TmpInsTab(i_in).OVERCOMMITMENT_QTY := NVL(TmpInsTab(i_in).OVERCOMMITMENT_QTY,0) * -1;
                                END IF;
                                IF (NVL(TmpInsTab(i_in).OVERPROVISIONAL_QTY,0) = 0) THEN
                                   TmpInsTab(i_in).OVERPROVISIONAL_QTY := NULL;
                                ELSE
                                   TmpInsTab(i_in).OVERPROVISIONAL_QTY := NVL(TmpInsTab(i_in).OVERPROVISIONAL_QTY,0) * -1;
                                END IF;
                                IF (NVL(TmpInsTab(i_in).OVER_PROV_CONF_QTY,0) = 0) THEN
                                   TmpInsTab(i_in).OVER_PROV_CONF_QTY := NULL;
                                ELSE
                                   TmpInsTab(i_in).OVER_PROV_CONF_QTY := NVL(TmpInsTab(i_in).OVER_PROV_CONF_QTY,0) * -1;
                                END IF;
                                IF (NVL(TmpInsTab(i_in).CONFIRMED_QTY,0) = 0) THEN
                                   TmpInsTab(i_in).CONFIRMED_QTY := NULL;
                                ELSE
                                   TmpInsTab(i_in).CONFIRMED_QTY := NVL(TmpInsTab(i_in).CONFIRMED_QTY,0) * -1;
                                END IF;
                                IF (NVL(TmpInsTab(i_in).PROVISIONAL_QTY,0) = 0) THEN
                                   TmpInsTab(i_in).PROVISIONAL_QTY := NULL;
                                ELSE
                                   TmpInsTab(i_in).PROVISIONAL_QTY := NVL(TmpInsTab(i_in).PROVISIONAL_QTY,0) * -1;
                                END IF;
                                TmpInsTab(i_in).item_quantity :=
                                           p_DBDtlTab(d_in).item_quantity * -1;
                                TmpInsTab(i_in).resource_util_weighted :=
                                          p_DBDtlTab(d_in).resource_util_weighted * -1;
                                TmpInsTab(i_in).org_util_weighted :=
                                          p_DBDtlTab(d_in).org_util_weighted * -1;
                                TmpInsTab(i_in).reversed_flag := 'N';
                                TmpInsTab(i_in).line_num_reversed :=
                                           p_DBDtlTab(d_in).line_num;
                                TmpInsTab(i_in).net_zero_flag := 'Y';

                                IF NVL(p_DBDtlTab(d_in).forecast_summarized_code,'Y') =
                                                    'Y' THEN

                                   TmpInsTab(i_in).forecast_summarized_code :=
                                                        'N';
                                ELSE

                                   TmpInsTab(i_in).forecast_summarized_code :=
                                      p_DBDtlTab(d_in).forecast_summarized_code;

                                END IF;

                    IF NVL(p_DBDtlTab(d_in).PJI_SUMMARIZED_FLAG,'Y') = 'Y' THEN
                      TmpInsTab(i_in).PJI_SUMMARIZED_FLAG := 'N';
                    ELSE
                      TmpInsTab(i_in).PJI_SUMMARIZED_FLAG :=
                              p_DBDtlTab(d_in).PJI_SUMMARIZED_FLAG;
                    END IF;

                                IF NVL(p_DBDtlTab(d_in).util_summarized_code,'Y') = 'Y'
                                       THEN

                                   TmpInsTab(i_in).util_summarized_code := 'N';

                                ELSE

                                   TmpInsTab(i_in).util_summarized_code :=
                                      p_DBDtlTab(d_in).util_summarized_code;

                                END IF;

                                i_in := i_in + 1;
                                -- update Line
                                TmpUpdTab(u_in).reversed_flag := 'Y';

                             END IF;

                             TmpUpdTab(u_in).net_zero_flag := 'Y';
                             u_in := u_in + 1;


                          END IF;

                       END IF;

                       d_in := d_in + 1;

                    END IF;

                 END IF;

                 -- N New record/new line
                 -- DN Existing record has header changes
                      -- New record/new line
                 -- RN Existing record detail changes
                    -- The values are already summarized
                    -- Create new line
                 -- RU Existing record has detail changes
                    -- The values are not summarized
                    -- update existing line with new values
                 -- All attribute values are.FIRST generated IN Tmp_rec
                 -- IF action_flag is N,DN,RN copied to TmpInsTab
                 -- ELSE copied to TmpUpdTab

                 IF (TmpDayTab(i).action_flag IN ('N', 'DN', 'RN','RU')) AND
                      (
                       NVL(TmpDayTab(i).CAPACITY_QUANTITY,0) > 0 OR
                       NVL(TmpDayTab(i).OVERCOMMITMENT_QTY,0) > 0 OR
                       NVL(TmpDayTab(i).OVERPROVISIONAL_QTY,0) > 0 OR
                       NVL(TmpDayTab(i).OVER_PROV_CONF_QTY,0) > 0 OR
                       NVL(TmpDayTab(i).CONFIRMED_QTY,0) > 0 OR
                       NVL(TmpDayTab(i).PROVISIONAL_QTY,0) > 0 OR
                       TmpDayTab(i).item_quantity > 0
                       ) THEN

                    -- create new line
                    TmpDtlRec.forecast_item_id := TmpDayTab(i).forecast_item_id;
                    TmpDtlRec.amount_type_id := lv_amount_type_id;
                    TmpDtlRec.line_num := lv_next_line_num;
                    TmpDtlRec.resource_type_code := '99';
                    TmpDtlRec.person_billable_flag := 'N';
                    TmpDtlRec.item_date := TmpDayTab(i).item_date;
                    TmpDtlRec.expenditure_org_id :=
                                         TmpDayTab(i).expenditure_org_id;
                    TmpDtlRec.expenditure_organization_id :=
                                         TmpDayTab(i).expenditure_organization_id;
                    TmpDtlRec.project_id :=
                                         TmpDayTab(i).project_id;
                    TmpDtlRec.resource_id :=
                                         TmpDayTab(i).resource_id;

                    TmpDtlRec.project_org_id := TmpDayTab(i).project_org_id;
                    TmpDtlRec.item_uom := 'HOURS';
                    TmpDtlRec.CAPACITY_QUANTITY := TmpDayTab(i).CAPACITY_QUANTITY;
                    TmpDtlRec.OVERCOMMITMENT_QTY := TmpDayTab(i).OVERCOMMITMENT_QTY;
                    TmpDtlRec.OVERPROVISIONAL_QTY := TmpDayTab(i).OVERPROVISIONAL_QTY;
                    TmpDtlRec.OVER_PROV_CONF_QTY := TmpDayTab(i).OVER_PROV_CONF_QTY;
                    TmpDtlRec.CONFIRMED_QTY := TmpDayTab(i).CONFIRMED_QTY;
                    TmpDtlRec.PROVISIONAL_QTY := TmpDayTab(i).PROVISIONAL_QTY;
                    TmpDtlRec.item_quantity := TmpDayTab(i).item_quantity;
                    TmpDtlRec.pvdr_acct_curr_code := NULL;
                    TmpDtlRec.pvdr_acct_amount := NULL;
                    TmpDtlRec.rcvr_acct_curr_code := NULL;
                    TmpDtlRec.rcvr_acct_amount := NULL;
                    TmpDtlRec.proj_currency_code := NULL;
                    TmpDtlRec.proj_amount := NULL;
                    TmpDtlRec.denom_currency_code := NULL;
                    TmpDtlRec.denom_amount := NULL;
                    TmpDtlRec.tp_amount_type :=
                                  p_AsgnDtlRec.fcst_tp_amount_type;
                    TmpDtlRec.billable_flag := lv_billable_flag;
                    TmpDtlRec.forecast_summarized_code :=
                                   lv_new_fcast_sum_code ;
                    TmpDtlRec.PJI_SUMMARIZED_FLAG := lv_new_util_sum_code;
                    TmpDtlRec.util_summarized_code := lv_new_util_sum_code;

                    IF TmpDayTab(i).Error_flag = 'Y' THEN

                       TmpDtlRec.PJI_SUMMARIZED_FLAG := 'E';
                       TmpDtlRec.util_summarized_code := 'E';
                       TmpDtlRec.forecast_summarized_code := 'E';

                    END IF;

                    TmpDtlRec.work_type_id := p_AsgnDtlRec.work_type_id;

                    TmpDtlRec.resource_util_category_id :=
                                                l_resutilcategoryid;
                    TmpDtlRec.org_util_category_id :=
                                                l_orgutilcategoryid;
                    TmpDtlRec.resource_util_weighted :=
                                    TmpDayTab(i).item_quantity *
                                            l_resutilweighted/100;
                    TmpDtlRec.org_util_weighted :=
                          TmpDayTab(i).item_quantity *
                                 l_orgutilweighted/100;
                    TmpDtlRec.Reduce_Capacity_Flag := l_ReduceCapacityFlag;
                    TmpDtlRec.provisional_flag := lv_provisional_flag;
                    TmpDtlRec.reversed_flag := 'N';
                    TmpDtlRec.net_zero_flag := 'N';
                    TmpDtlRec.line_num_reversed := 0;

                    IF TmpDayTab(i).action_flag = 'RU' THEN

                       TmpUpdTab(u_in) := TmpDtlRec;
                       u_in := u_in + 1;

                    ELSE

                       TmpInsTab(i_in) := TmpDtlRec;
                       i_in := i_in + 1;

                    END IF;


/*
                 Print_message('***********');

                 Print_message(
                    'item_date:' || TmpDtlRec.item_date);

                 Print_message(
                    'fct_item_id:' || TmpDtlRec.forecast_item_id ||
                    ' amt_typ_id:' || TmpDtlRec.amount_type_id  ||
                    ' line_num:' || TmpDtlRec.line_num ||
                    chr(10) || 'Res_typ_cd  :' ||
                               TmpDtlRec.resource_type_code ||
                    ' per_bil_fl:' ||
                               TmpDtlRec.person_billable_flag ||
                    ' item_uom:' || TmpDtlRec.item_uom );

                 Print_message(
                    ' item_qty:' || TmpDtlRec.item_quantity ||
                    ' exp_org_id:' ||
                               TmpDtlRec.expenditure_org_id ||
                    ' prj_org_id:' ||
                               TmpDtlRec.project_org_id ||
                    ' tp_amt_typ:' || TmpDtlRec.tp_amount_type ||
                    chr(10) || 'bill_flag:' || TmpDtlRec.billable_flag ||
                    ' fcs_sum_cd:' ||
                               TmpDtlRec.forecast_summarized_code ||
                    ' utl_sum_cd:' ||
                               TmpDtlRec.util_summarized_code );

                 Print_message(
                    ' wrk_typ_id:' || TmpDtlRec.work_type_id ||
                    ' res_utl_id:' ||
                               TmpDtlRec.resource_util_category_id ||
                    ' org_utl_id:' ||
                               TmpDtlRec.org_util_category_id ||
                    ' res_utl_wt:' ||
                               TmpDtlRec.resource_util_weighted ||
                    chr(10) || 'org_utl_wt:' ||
                               TmpDtlRec.org_util_weighted ||
                    ' prv_flag:' || TmpDtlRec.provisional_flag ||
                    ' rev_flag:' || TmpDtlRec.reversed_flag ||
                    ' net_zer_fl:' || TmpDtlRec.net_zero_flag ||
                    ' ln_num_rev:' ||
                               TmpDtlRec.line_num_reversed);
*/

                 END IF;
             END IF;
             END LOOP;
             end if;

             x_FIDtlInsTab.Delete;
             x_FIDtlUpdTab.Delete;

             x_FIDtlInsTab := TmpInsTab;
             x_FIDtlUpdTab := TmpUpdTab;


             Print_message('Leaving Build_FI_Dtl_Req');

             PA_DEBUG.Reset_Err_Stack;

             x_return_status := lv_return_status;

        EXCEPTION

             WHEN OTHERS THEN
                  print_message('Failed in Build_FI_Dtl_Req api');
                  print_message('SQLCODE'||sqlcode||sqlerrm);

                  x_msg_count     := 1;
                  x_msg_data      := sqlerrm;
                  x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

                  FND_MSG_PUB.add_exc_msg
                      (p_pkg_name   =>
                              'PA_FORECASTITEM_PVT.Build_FI_Dtl_Req',
                       p_procedure_name => PA_DEBUG.G_Err_Stack);

		               If x_msg_count = 1 THEN
				              pa_interface_utils_pub.get_messages
				                (p_encoded        => FND_API.G_TRUE,
					               p_msg_index      => 1,
					               p_msg_count      => x_msg_count,
					               p_msg_data       => x_msg_data,
					               p_data           => l_data , -- 4537865
					               p_msg_index_out  => l_msg_index_out );
							x_msg_data := l_data ; -- 4537865
		               End If;
                  Print_message(x_msg_data);

                  RAISE;

        END Build_FI_Dtl_Req;

/* ---------------------------------------------------------------------
|   Procedure  :   Generate_Assignment_FI
|   Purpose    :   To generate forecast items FOR assignment record
|   Parameters :   p_AsgnDtlRec     - Assignment Details FOR which
|                                   forecast item is to be generated
|                  p_process_mode   - Mode of Processing
|                    a) GENERATE    : New Generation
|                                     Also whenever schedule data changes
|                    b) RECALCULATE : Whenever
|                                    i)expenditure OU Changes
|                                   ii)expenditure organization Changes
|                                  iii)expenditure type Changes
|                                   iv)expenditure type class Changes
|                                    v)Borrowed flag Changes
|                    c) ERROR       : Regeneration of Errored forecast items
|                                     by previous generation
|                  p_start_date     - Start DATE FOR Forecast Item Generation
|                  p_end_date       - END DATE FOR Forecast Item Generation
|                  p_ErrHdrTab      -
|                    a)GENERATE/        : Dummy tab is passed
|                      RECALCULATE Mode
|                    b) ERROR Mode      : Contains all errored forecast item
|                                          Header records
|                  x_return_status  -
|                  x_msg_count      -
|                  x_msg_data       -
+----------------------------------------------------------------------*/

       PROCEDURE  Generate_Assignment_FI(
                  p_AsgnDtlRec     IN   PA_FORECAST_GLOB.AsgnDtlRecord,
                  p_process_mode   IN   VARCHAR2,
                  p_start_date     IN   DATE,
                  p_end_date       IN   DATE,
                  p_ErrHdrTab      IN   PA_FORECAST_GLOB.FIHdrTabTyp,
                  x_res_start_date OUT NOCOPY  DATE, -- 4537865
                  x_res_end_date   OUT NOCOPY DATE, -- 4537865
                  x_return_status  OUT NOCOPY VARCHAR2, -- 4537865
                  x_msg_count      OUT NOCOPY NUMBER, -- 4537865
                  x_msg_data       OUT NOCOPY VARCHAR2) IS -- 4537865


	           l_msg_index_out	            NUMBER;
		 l_data varchar2(2000); -- 4537865
             lv_req_exist_flag      VARCHAR2(1) := 'N';
             lv_asgn_exist_flag     VARCHAR2(1) := 'N';
             TmpDBFIDtlTab          PA_FORECAST_GLOB.FIDtlTabTyp;
             TmpDBFIHdrTab          PA_FORECAST_GLOB.FIHdrTabTyp;
             TmpFIDtlInsTab         PA_FORECAST_GLOB.FIDtlTabTyp;
             TmpFIDtlUpdTab         PA_FORECAST_GLOB.FIDtlTabTyp;
             TmpFIHdrInsTab         PA_FORECAST_GLOB.FIHdrTabTyp;
             TmpFIHdrUpdTab         PA_FORECAST_GLOB.FIHdrTabTyp;
             TmpScheduleTab         PA_FORECAST_GLOB.SCHEDULETABTYP;
             TmpFIDayTab            PA_FORECAST_GLOB.FIDayTabTyp;
             TmpDumTab              PA_FORECAST_GLOB.FIHdrTabTyp;

             -- Used to determine start_date AND end_date for
             -- Calculating resource unassigned time

             lv_old_start_date      DATE := NULL;
             lv_old_end_date        DATE := NULL;
             lv_res_start_date      DATE := NULL;
             lv_res_end_date        DATE := NULL;
             lv_start_date          DATE;
             lv_end_date            DATE;

             lv_err_msg             VARCHAR2(30);

             lv_return_status       VARCHAR2(30);

	     lv_lock_type           VARCHAR2(5) := 'RES';
	     l_cannot_acquire_lock  EXCEPTION;
	     li_lock_status         NUMBER;

       cursor c_res_dates is
               select min(resource_effective_start_date),
                      max(resource_effective_end_date)
               from pa_resources_denorm
               where resource_id = p_AsgnDtlRec.resource_id;

       ld_res_asgn_start_date   DATE;
       ld_res_asgn_end_date     DATE;
       l_no_fis_to_create  EXCEPTION;
       BEGIN

             lv_return_status := FND_API.G_RET_STS_SUCCESS;

             Print_message( 'Entering Generate_Assignment_FI');

             TmpDBFIDtlTab.delete;
             TmpDBFIHdrTab.delete;
             TmpFIDtlInsTab.delete;
             TmpFIDtlUpdTab.delete;
             TmpFIHdrInsTab.delete;
             TmpFIHdrUpdTab.delete;
             TmpScheduleTab.delete;
             TmpFIDayTab.delete;
             TmpDumTab.delete;

             PA_DEBUG.Init_err_stack( 'PA_FORECASTITEM_PVT.Generate_Assignment_FI');

	     IF p_AsgnDtlRec.resource_id is NOT NULL then
             open c_res_dates;
             fetch c_res_dates into ld_res_asgn_start_date, ld_res_asgn_end_date;
             print_message('ld_res_asgn_start_date: ' || ld_res_asgn_start_date);
             print_message('ld_res_asgn_end_date: ' || ld_res_asgn_end_date);
             if c_res_dates%NOTFOUND or ld_res_asgn_start_date is null then
               print_message('Invalid resource. No FIs to create.');
               close c_res_dates;
               raise l_no_fis_to_create;
             end if;
             close c_res_dates;

             -- 2196924: Comment out this logic.
             -- Don't create FIs if resource is end dated.
             --if (ld_res_asgn_end_date < sysdate) then
             --  print_message('Resource is end dated. No FIs to create.');
             --  raise l_no_fis_to_create;
             --end if;

             -- 2196924: Comment out this logic.
             --if (p_start_date > ld_res_asgn_end_date) then
             --  print_message('Assignment is outside of HR assignment');
             --  raise l_no_fis_to_create;
             --end if;

             -- 2196924: Comment out this logic.
             --if (p_end_date < ld_res_asgn_start_date) then
             --  print_message('Assignment is outside of HR assignment');
             --  raise l_no_fis_to_create;
             --end if;

             	IF (PA_FORECAST_ITEMS_UTILS.Set_User_Lock(
                                     p_AsgnDtlRec.resource_id, 'RES') <> 0) THEN
                	RAISE l_cannot_acquire_lock;

             	END IF;
		Print_message('Resource locked for processing :'||p_AsgnDtlRec.resource_id);

	     End if;

             IF p_start_date IS NULL THEN

                lv_start_date := p_AsgnDtlRec.start_date;

             ELSE

                lv_start_date := p_start_date;

             END IF;

             IF p_end_date IS NULL THEN

                lv_end_date := p_AsgnDtlRec.end_date;

             ELSE

                lv_end_date := p_end_date;

             END IF;

             lv_old_start_date := lv_start_date;
             lv_old_end_date := lv_end_date;

             Print_message(
		   'Resource_id ='||p_asgndtlrec.resource_id||
                   'Asgn_ID    - ' || p_asgndtlrec.assignment_id ||
                   ';   Start_Date - ' || lv_start_date ||
                   ';   End_Date   - ' || lv_end_date      );


             IF (p_process_mode <> 'ERROR') THEN

                 Print_message(
                         'Asg - Calling Chk_Assignment_FI_Exist');


                 lv_asgn_exist_flag := Chk_Assignment_FI_Exist(
                                        p_AsgnDtlRec.assignment_id);

             ELSE

                 lv_asgn_exist_flag := 'Y';

             END IF;

             IF lv_asgn_exist_flag = 'N' THEN

                 -- Check IF source requirement exists

                 Print_message(
                         'Asg - Calling Chk_Requirement_FI_Exist');


                 lv_req_exist_flag := Chk_Requirement_FI_Exist(
                                        p_AsgnDtlRec.source_assignment_id);

                 -- If exists reverse assignment

                 IF lv_req_exist_flag = 'Y' THEN

                   Print_message(
                              'Calling Delete_FI');

                    Delete_FI(
                        p_assignment_id=>p_AsgnDtlRec.source_assignment_id,
                        x_return_status=>lv_return_status,
                        x_msg_count=>x_msg_count,
                        x_msg_data=>x_msg_data);

                 END IF;

             ELSE
                 -- Assignment exists so

                 IF p_process_mode = 'GENERATE' THEN

                    -- Reverse forecast items detail FOR this assignment
                    -- which do not fall BETWEEN startdate AND END DATE

                    Print_message(
                              'Asg - Calling Reverse_FI_Dtl');

                    Reverse_FI_Dtl(p_AsgnDtlRec.assignment_id,
                                   lv_start_date, lv_end_date,
                                   lv_return_status, x_msg_count, x_msg_data);

                    -- Reverse forecast items Header FOR this assignment
                    -- which do not fall BETWEEN startdate AND END DATE

                    IF lv_return_status = FND_API.G_RET_STS_SUCCESS THEN

                        Print_message( 'Asg - Calling Reverse_FI_Hdr');

                        Reverse_FI_Hdr(p_AsgnDtlRec.assignment_id,
                                       lv_start_date, lv_end_date,
                                       lv_old_start_date, lv_old_end_date,
                                       lv_return_status, x_msg_count, x_msg_data);
                    END IF;

                 END IF;

             END IF;

             IF (lv_old_start_date IS NULL) OR
                   (lv_start_date <= lv_old_start_date) THEN

                       x_res_start_date := lv_start_date;

             ELSE

                       x_res_start_date := lv_old_start_date;

             END  if;

             IF (lv_old_end_date IS NULL) OR
                       (lv_end_date >= lv_old_end_date) THEN

                x_res_end_date := lv_end_date;

             ELSE

                x_res_end_date := lv_old_end_date;

             END IF;

             TmpFIHdrInsTab.delete; -- Initialize

             -- Get schedule data AND build day fI Records


             IF lv_return_status = FND_API.G_RET_STS_SUCCESS THEN

                Print_message(
                       'Asg - Calling Get_Assignment_Schedule');

                PA_FORECAST_ITEMS_UTILS.Get_assignment_Schedule(
                              p_AsgnDtlRec.assignment_id,
                              lv_start_date,
                              lv_end_date,
                              p_process_mode,
                              Tmpscheduletab,
                              lv_return_status,
                              x_msg_count, x_msg_data);

                IF TmpScheduleTab.Count = 0 THEN

                   lv_err_msg := 'No_Schedule_Records - Asg';
                   RAISE NO_DATA_FOUND;

                END IF;

             END IF;


             IF lv_return_status = FND_API.G_RET_STS_SUCCESS THEN

                Print_message( 'Asg - Calling Initialize_Day_FI');

                Initialize_Day_FI   ( TmpScheduleTab,
                                      p_process_mode,
                                      lv_start_date,
                                      lv_end_date,
                                      TmpFIDayTab ,
                                      lv_return_status , x_msg_count , x_msg_data );
             END IF;

             IF lv_return_status = FND_API.G_RET_STS_SUCCESS THEN

                Print_message('Asg - Calling Build_Day_FI');

                Print_message('p_AsgnDtlRec: ' || p_AsgnDtlRec.resource_id || ' ' || p_AsgnDtlRec.assignment_id);

                Build_Day_FI   ( TmpScheduleTab , lv_start_date , lv_end_date ,
                              TmpFIDayTab ,p_AsgnDtlRec.assignment_type,
                              lv_return_status , x_msg_count , x_msg_data );
                Print_message('p_AsgnDtlRec: ' || p_AsgnDtlRec.resource_id || ' ' || p_AsgnDtlRec.assignment_id);



                TmpFIHdrUpdTab.delete; -- Initialize
                TmpFIDtlInsTab.delete; -- Initialize
                TmpFIDtlUpdTab.delete; -- Initialize
                TmpDBFIHdrTab.delete;  -- Initialize
                TmpDBFIDtlTab.delete;  -- Initialize

             END IF;

             IF lv_asgn_exist_flag = 'Y' AND -- Added and condition for bug 4320465
	       lv_return_status = FND_API.G_RET_STS_SUCCESS  THEN

                lv_start_date := TmpFIDayTab(TmpFIDayTab.FIRST).item_date;
                lv_end_date :=   TmpFIDayTab(TmpFIDayTab.LAST).item_date;

                 -- Get existing forecast items  FOR this assignment
                 -- which fall BETWEEN startdate AND END DATE

                 IF (p_process_mode <> 'ERROR') THEN

                   -- IF lv_return_status = FND_API.G_RET_STS_SUCCESS THEN  -- Moved above for Bug 4320465

                       Print_message( 'Asg - Calling Fetch_FI_Hdr');

                       Fetch_FI_Hdr ( p_AsgnDtlRec.assignment_id,
                                      p_AsgnDtlRec.resource_id,
                                      lv_start_date, lv_end_date,
                                      TmpDBFIHdrTab,
                                      lv_return_status,  x_msg_count, x_msg_data);
                    --END IF;    Bug 4320465

                 ELSE

                      TmpDBFIHdrTab := p_ErrHdrTab;

                 END IF;

                 IF lv_return_status = FND_API.G_RET_STS_SUCCESS THEN

                     -- Get existing forecast items detail FOR this assignment
                     -- which fall BETWEEN startdate AND END DATE

                     Print_message( 'Asg - Calling Fetch_FI_Dtl');

                     Fetch_FI_Dtl ( p_AsgnDtlRec.assignment_id,
                                    p_AsgnDtlRec.resource_id,
                                    lv_start_date, lv_end_date,
                                    TmpDBFIDtlTab,
                                    lv_return_status,  x_msg_count, x_msg_data);
                END IF;

             END IF;

             -- Header Processing
             -- Inputs : TmpFIDayTab, TmpDBFIHdrTab, p_asgndltrec
             -- Get new values FOR expenditure_ou,
             -- expenditure_organization, expenditure_type,
             -- expenditure_type_class, borrowed flag
             -- IF item_date exists
                   -- check above values with existing values
                   -- IF differs
                         -- update header FOR delete_flag
                         -- Create new forecast_item_header
                         -- Mark action_flag = 'DN';
                         -- Save new forecast_item_id IN TmpFIDayTab
                   -- ELSE
                         --  Check FOR qty change
                         -- IF differs
                               -- update item_quantity IN header with
                               -- new value
                               -- Mark action_flag = 'RN';
                         -- ELSE
                               -- Mark action_flag = 'C';
                               -- Meaning values FOR attributes associated
                               -- with detail table have to be checked for
                               -- change
             -- ELSE (item_date does not exist)
                   -- Create new forecast_item
                   -- Mark action_flag = 'N';

             IF lv_return_status = FND_API.G_RET_STS_SUCCESS THEN

                Print_message('Calling Build_FI_Hdr_Asg');

                Build_FI_Hdr_Asg(p_AsgnDtlRec, TmpDBFIHdrTab, TmpFIDayTab,
                              TmpFIHdrInsTab, TmpFIHdrUpdTab,
                              lv_return_status,  x_msg_count, x_msg_data);
             END IF;

                -- Detail Processing
                -- Inputs : TmpFIDayTab, TmpDBFIDtlTab, p_asgndltrec
                -- TmpFIDayTab.Action_flag is updated by header process.
                -- IF action_flag = 'C'
                   -- check FOR change IN resource_type_code,
                   -- person_billable_flag, include IN forecast option,
                   -- provisional_flag, work_type_id
                   -- If there is change mark action_flag = 'RN';
                -- IF action_flag = 'DN'
                   --Header record has changed
                   -- Reverse detail record
                   -- Create new detail record with forecast_item_id
                   -- (generated by header record, saved IN TmpFIDayTab)
                   --  AND line_NUMBER = 1;
                -- IF action_flag = 'RN'
                   -- Change IN detail record values
                   -- Reverse detail record
                   -- create new detail record with same forecast_item_id
                   -- AND line_NUMBER = max(line_NUMBER) + 1;
                -- IF action_flag = 'N'
                   -- Create new detail record with forecast_item_id
                   -- (generated by header record, saved IN TmpFIDayTab)
                   --  AND line_NUMBER = 1;

             IF lv_return_status = FND_API.G_RET_STS_SUCCESS THEN

                Print_message('Calling Build_FI_Dtl_Asg');

                Build_FI_Dtl_Asg(p_AsgnDtlRec, TmpDBFIDtlTab, TmpFIDayTab,
                              TmpFIDtlInsTab, TmpFIDtlUpdTab,
                              lv_return_status,  x_msg_count, x_msg_data);
             END IF;


             IF lv_return_status = FND_API.G_RET_STS_SUCCESS THEN

                IF TmpFIHdrInsTab.COUNT > 0 THEN

                   Print_message( 'Calling PA_FORECAST_HDR_PKG.Insert_Rows');

                   PA_FORECAST_HDR_PKG.Insert_Rows(TmpFIHdrInsTab,
                                                   lv_return_status,
                                                   x_msg_count,
                                                   x_msg_data);
                END IF;

             END IF;

             Print_message('lv_return_status: ' || lv_return_status);
             IF lv_return_status = FND_API.G_RET_STS_SUCCESS THEN
                Print_message('TmpFIHdrUpdTab.COUNT: ' || TmpFIHdrUpdTab.COUNT);

                IF TmpFIHdrUpdTab.COUNT > 0 THEN

                   Print_message( 'Calling PA_FORECAST_HDR_PKG.Update_Rows');

                   PA_FORECAST_HDR_PKG.Update_Rows(TmpFIHdrUpdTab,
                                                lv_return_status,
                                                x_msg_count,
                                                x_msg_data);
                END IF;

             END IF;

             IF lv_return_status = FND_API.G_RET_STS_SUCCESS THEN

                IF TmpFIDtlInsTab.COUNT > 0 THEN

                   Print_message( 'Calling PA_FORECAST_DTLS_PKG.Insert_Rows');

                   PA_FORECAST_DTLS_PKG.Insert_Rows(TmpFIDtlInsTab,
                                                    lv_return_status,
                                                    x_msg_count,
                                                    x_msg_data);
                END IF;

             END IF;

             IF lv_return_status = FND_API.G_RET_STS_SUCCESS THEN

                IF TmpFIDtlUpdTab.COUNT > 0 THEN

                   Print_message( 'Calling PA_FORECAST_DTLS_PKG.Update_Rows');

                   PA_FORECAST_DTLS_PKG.Update_Rows(TmpFIDtlUpdTab,
                                                    lv_return_status,
                                                    x_msg_count,
                                                    x_msg_data);
                END IF;

             END IF;

             IF lv_return_status = FND_API.G_RET_STS_SUCCESS THEN

                IF (p_process_mode = 'GENERATE') THEN

                   Print_message(
                         'Calling PA_FORECAST_HDR_PKG.Update_Schedule_Rows');

                   PA_FORECAST_HDR_PKG.Update_Schedule_Rows(
                                            TmpScheduleTab,
                                            lv_return_status,
                                            x_msg_count,
                                            x_msg_data);
                END IF;

             END IF;


             Print_message( 'Leaving Generate_Assignment_FI');

             PA_DEBUG.Reset_Err_Stack;

	     /** Release the lock once process is completed **/
	     li_lock_status := PA_FORECAST_ITEMS_UTILS.Release_User_lock(p_AsgnDtlRec.resource_id, 'RES');
	     Print_message('Resource lock released');

             x_return_status := lv_return_status;

	     return;

        EXCEPTION

             WHEN l_no_fis_to_create THEN
                  -- There are no FIs to create.
                  x_return_status := lv_return_status;
             WHEN l_cannot_acquire_lock THEN

                 Print_message(
                    'Unable to set lock for ' || p_AsgnDtlRec.resource_id);

                 x_msg_count     := 1;
                 x_msg_data      := 'Resource ID Lock Failure';
                 x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

		-- 4537865
		x_res_start_date := NULL ;
		x_res_end_date := NULL ;

                 FND_MSG_PUB.add_exc_msg
                     (p_pkg_name   =>
                             'PA_FORECASTITEM_PVT.Generate_Assignment',
                      p_procedure_name => PA_DEBUG.G_Err_Stack);

		               If x_msg_count = 1 THEN
				              pa_interface_utils_pub.get_messages
				                (p_encoded        => FND_API.G_TRUE,
					               p_msg_index      => 1,
					               p_msg_count      => x_msg_count,
					               p_msg_data       => x_msg_data,
					               p_data           => l_data , -- 4537865
					               p_msg_index_out  => l_msg_index_out );
						x_msg_data := l_data ; -- 4537865
		               End If;
                 Print_message(x_msg_data);
                 raise;

             WHEN NO_DATA_FOUND THEN

                IF lv_err_msg = 'No_Schedule_Records - Asg' THEN

                    x_msg_count     := 1;
                    x_msg_data      := 'No Schedule Records for Asg ';
                    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

		   -- 4537865
		  x_res_start_date := NULL ;
		  x_res_end_date := NULL ;

                    FND_MSG_PUB.add_exc_msg
                        (p_pkg_name   =>
                                'PA_FORECASTITEM_PVT.Generate_Assignment',
                         p_procedure_name => PA_DEBUG.G_Err_Stack);

		               If x_msg_count = 1 THEN
				              pa_interface_utils_pub.get_messages
				                (p_encoded        => FND_API.G_TRUE,
					               p_msg_index      => 1,
					               p_msg_count      => x_msg_count,
					               p_msg_data       => x_msg_data,
					               p_data           => l_data , -- 4537865
					               p_msg_index_out  => l_msg_index_out );
						 x_msg_data := l_data ; -- 4537865
		               End If;
                    Print_message(x_msg_data);

                    RAISE;

                ELSE

                  x_msg_count     := 1;
                  x_msg_data      := sqlerrm;
                  x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

		    -- 4537865
		   x_res_start_date := NULL ;
  	           x_res_end_date := NULL ;

                  FND_MSG_PUB.add_exc_msg
                      (p_pkg_name   =>
                              'PA_FORECASTITEM_PVT.Generate_Assignment_FI',
                       p_procedure_name => PA_DEBUG.G_Err_Stack);

		               If x_msg_count = 1 THEN
				              pa_interface_utils_pub.get_messages
				                (p_encoded        => FND_API.G_TRUE,
					               p_msg_index      => 1,
					               p_msg_count      => x_msg_count,
					               p_msg_data       => x_msg_data,
					               p_data           => l_data , -- 4537865
					               p_msg_index_out  => l_msg_index_out );
						x_msg_data := l_data ; -- 4537865
		               End If;
                  Print_message(x_msg_data);

                  RAISE;


               END IF;
		/** lock must be released once process completes or errors out **/
		li_lock_status := PA_FORECAST_ITEMS_UTILS.Release_User_lock(p_AsgnDtlRec.resource_id, 'RES');
		Print_message('Resource lock released ');

             WHEN OTHERS THEN
                  print_message('Failed in Generate_Assignemnt api');
                  print_message('SQLCODE'||sqlcode||sqlerrm);

                  x_msg_count     := 1;
                  x_msg_data      := sqlerrm;
                  x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

		  -- 4537865
		  x_res_start_date := NULL ;
		  x_res_end_date := NULL ;

                  FND_MSG_PUB.add_exc_msg
                      (p_pkg_name   =>
                              'PA_FORECASTITEM_PVT.Generate_Assignment_FI',
                       p_procedure_name => PA_DEBUG.G_Err_Stack);

		               If x_msg_count = 1 THEN
				              pa_interface_utils_pub.get_messages
				                (p_encoded        => FND_API.G_TRUE,
					               p_msg_index      => 1,
					               p_msg_count      => x_msg_count,
					               p_msg_data       => x_msg_data,
					               p_data           => l_data ,   -- 4537865
					               p_msg_index_out  => l_msg_index_out );
					       x_msg_data := l_data ; -- 4537865
		               End If;
                  Print_message(x_msg_data);

		/** lock must be released once process completes or errors out **/
		li_lock_status := PA_FORECAST_ITEMS_UTILS.Release_User_lock(p_AsgnDtlRec.resource_id, 'RES');
                Print_message('Resource lock released ');

                  RAISE;


       END Generate_Assignment_FI;

/* ---------------------------------------------------------------------
|   Function   :   Chk_Assignment_FI_Exist
|   Purpose    :   To check IF forecast item FOR assignment record exists
|   Parameters :   p_assignment_id  - Input Assignment ID
|                  p_resource_id    - Input Resource ID
+----------------------------------------------------------------------*/
       Function  Chk_Assignment_FI_Exist(
                 p_assignment_id  IN    NUMBER)

                           RETURN VARCHAR2 IS

             lv_exist_flag   VARCHAR2(1) := 'N';

       BEGIN

             Print_message( 'Entering Chk_Assignment_FI_Exist');

              BEGIN
                     SELECT 'Y'
                     INTO lv_exist_flag
                     FROM dual
                     WHERE exists (SELECT null
                                  FROM pa_forecast_items
                                  WHERE assignment_id = p_assignment_id
                                  AND delete_flag = 'N');

              EXCEPTION

                     WHEN NO_DATA_FOUND THEN
                          lv_exist_flag   := 'N';

              END;

              RETURN(lv_exist_flag);

             Print_message( 'Leaving Chk_Assignment_FI_Exist');

       END Chk_Assignment_FI_Exist;

/* ---------------------------------------------------------------------
|   Procedure  :   Delete_FI
|   Purpose    :   To delete all the forecast items FOR the given assignment
|                  Called when source requirement FI is to be deleted(reversed)
|                  when requirement or assignment record is deleted
|   Parameters :   p_assignment_id  - Input Assignment ID
|                  x_return_status     -
|                  x_msg_count         -
|                  x_msg_data          -
+----------------------------------------------------------------------*/
       PROCEDURE  Delete_FI(
                  p_assignment_id     IN   NUMBER,
                  x_return_status     OUT  NOCOPY VARCHAR2,  -- 4537865
                  x_msg_count         OUT  NOCOPY NUMBER,  -- 4537865
                  x_msg_data          OUT  NOCOPY VARCHAR2) IS  -- 4537865

             lv_return_status  VARCHAR2(30);
	     l_data 	VARCHAR2(2000);  -- 4537865
	           l_msg_index_out	            NUMBER;

       BEGIN

             lv_return_status := FND_API.G_RET_STS_SUCCESS;

             Print_message( 'Entering Delete_FI');

             PA_DEBUG.Init_err_stack( 'PA_FORECASTITEM_PVT.Delete_FI');

                   Delete_FI_Dtl( p_assignment_id=>p_assignment_id,
                           x_return_status=>lv_return_status,
                           x_msg_count=>x_msg_count,
                           x_msg_data=> x_msg_data );

             IF lv_return_status = FND_API.G_RET_STS_SUCCESS THEN

                   Delete_FI_Hdr( p_assignment_id=>p_assignment_id,
                           x_return_status=>lv_return_status,
                           x_msg_count=>x_msg_count,
                           x_msg_data=> x_msg_data );
             END IF;

             Print_message(
                         'Leaving Delete_FI');

             PA_DEBUG.Reset_Err_Stack;

             x_return_status := lv_return_status;

        EXCEPTION

             WHEN OTHERS THEN
                  print_message('Failed in Delete FI api');
                  print_message('SQLCODE'||sqlcode||sqlerrm);

                  x_msg_count     := 1;
                  x_msg_data      := sqlerrm;
                  x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

                  FND_MSG_PUB.add_exc_msg
                      (p_pkg_name   =>
                              'PA_FORECASTITEM_PVT.Delete_FI',
                       p_procedure_name => PA_DEBUG.G_Err_Stack);

		               If x_msg_count = 1 THEN
				              pa_interface_utils_pub.get_messages
				                (p_encoded        => FND_API.G_TRUE,
					               p_msg_index      => 1,
					               p_msg_count      => x_msg_count,
					               p_msg_data       => x_msg_data,
					               p_data           => l_data ,  -- 4537865
					               p_msg_index_out  => l_msg_index_out );
							x_msg_data := l_data ;   -- 4537865
		               End If;
                  Print_message(x_msg_data);

                  RAISE;

       END Delete_FI;

/* ---------------------------------------------------------------------
|   Procedure  :   Delete_FI_Hdr
|   Purpose    :   To reverse the existing forecast items (Requirement)
|                  when a resource is identified FOR a requirement
|   Parameters :   p_assignment_id  - Input Assignment ID
|                  x_return_status     -
|                  x_msg_count         -
|                  x_msg_data          -
+----------------------------------------------------------------------*/
       PROCEDURE  Delete_FI_Hdr(
                  p_assignment_id     IN    NUMBER,
                  x_return_status     OUT NOCOPY  VARCHAR2,  -- 4537865
                  x_msg_count         OUT NOCOPY   NUMBER,  -- 4537865
                  x_msg_data          OUT NOCOPY  VARCHAR2) IS  -- 4537865

		  l_data varchar2(2000) ;  -- 4537865

	           l_msg_index_out	            NUMBER;
             forecast_item_id_tab                PA_FORECAST_GLOB.NumberTabTyp;
             forecast_item_type_tab              PA_FORECAST_GLOB.VCTabTyp;
             project_org_id_tab                  PA_FORECAST_GLOB.NumberTabTyp;
             expenditure_org_id_tab              PA_FORECAST_GLOB.NumberTabTyp;
             expenditure_orgn_id_tab             PA_FORECAST_GLOB.NumberTabTyp;
             project_organization_id_tab         PA_FORECAST_GLOB.NumberTabTyp;
             project_id_tab                      PA_FORECAST_GLOB.NumberTabTyp;
             project_type_class_tab              PA_FORECAST_GLOB.VCTabTyp;
             person_id_tab                       PA_FORECAST_GLOB.NumberTabTyp;
             resource_id_tab                     PA_FORECAST_GLOB.NumberTabTyp;
             borrowed_flag_tab                   PA_FORECAST_GLOB.VC1TabTyp;
             assignment_id_tab                   PA_FORECAST_GLOB.NumberTabTyp;
             item_date_tab                       PA_FORECAST_GLOB.DateTabTyp;
             item_uom_tab                        PA_FORECAST_GLOB.VCTabTyp;
             item_quantity_tab                   PA_FORECAST_GLOB.NumberTabTyp;
             pvdr_period_set_name_tab            PA_FORECAST_GLOB.VCTabTyp;
             pvdr_pa_period_name_tab             PA_FORECAST_GLOB.VCTabTyp;
             pvdr_gl_period_name_tab             PA_FORECAST_GLOB.VCTabTyp;
             rcvr_period_set_name_tab            PA_FORECAST_GLOB.VCTabTyp;
             rcvr_pa_period_name_tab             PA_FORECAST_GLOB.VCTabTyp;
             rcvr_gl_period_name_tab             PA_FORECAST_GLOB.VCTabTyp;
             global_exp_period_end_date_tab      PA_FORECAST_GLOB.DateTabTyp;
             expenditure_type_tab                PA_FORECAST_GLOB.VCTabTyp;
             expenditure_type_class_tab          PA_FORECAST_GLOB.VCTabTyp;
             cost_rejection_code_tab             PA_FORECAST_GLOB.VCTabTyp;
             rev_rejection_code_tab              PA_FORECAST_GLOB.VCTabTyp;
             tp_rejection_code_tab               PA_FORECAST_GLOB.VCTabTyp;
             burden_rejection_code_tab           PA_FORECAST_GLOB.VCTabTyp;
             other_rejection_code_tab            PA_FORECAST_GLOB.VCTabTyp;
             delete_flag_tab                     PA_FORECAST_GLOB.VC1TabTyp;
             error_flag_tab                      PA_FORECAST_GLOB.VC1TabTyp;
             provisional_flag_tab                PA_FORECAST_GLOB.VC1TabTyp;
             JOB_ID_tab           PA_FORECAST_GLOB.NumberTabTyp;
             TP_AMOUNT_TYPE_tab           PA_FORECAST_GLOB.VCTabTyp;
             OVERPROVISIONAL_QTY_tab           PA_FORECAST_GLOB.NumberTabTyp;
             OVER_PROV_CONF_QTY_tab           PA_FORECAST_GLOB.NumberTabTyp;
             CONFIRMED_QTY_tab           PA_FORECAST_GLOB.NumberTabTyp;
             PROVISIONAL_QTY_tab           PA_FORECAST_GLOB.NumberTabTyp;
             asgmt_sys_status_code_tab           PA_FORECAST_GLOB.VCTabTyp;
             capacity_quantity_tab               PA_FORECAST_GLOB.NumberTabTyp;
             overcommitment_quantity_tab         PA_FORECAST_GLOB.NumberTabTyp;
             availability_quantity_tab           PA_FORECAST_GLOB.NumberTabTyp;
             overcommitment_flag_tab             PA_FORECAST_GLOB.VC1TabTyp;
             availability_flag_tab               PA_FORECAST_GLOB.VC1TabTyp;

             TmpUpdTab                           PA_FORECAST_GLOB.FIHdrTabTyp;

             lv_return_status                    VARCHAR2(30);

       BEGIN

             lv_return_status := FND_API.G_RET_STS_SUCCESS;

             Print_message( 'Entering Delete_FI_Hdr');

             TmpUpdTab.delete;
             forecast_item_id_tab.delete;
             forecast_item_type_tab.delete;
             project_org_id_tab.delete;
             expenditure_org_id_tab.delete;
             expenditure_orgn_id_tab.delete;
             project_organization_id_tab.delete;
             project_id_tab.delete;
             project_type_class_tab.delete;
             person_id_tab.delete;
             resource_id_tab.delete;
             borrowed_flag_tab.delete;
             assignment_id_tab.delete;
             item_date_tab.delete;
             item_uom_tab.delete;
             item_quantity_tab.delete;
             pvdr_period_set_name_tab.delete;
             pvdr_pa_period_name_tab.delete;
             pvdr_gl_period_name_tab.delete;
             rcvr_period_set_name_tab.delete;
             rcvr_pa_period_name_tab.delete;
             rcvr_gl_period_name_tab.delete;
             global_exp_period_end_date_tab.delete;
             expenditure_type_tab.delete;
             expenditure_type_class_tab.delete;
             cost_rejection_code_tab.delete;
             rev_rejection_code_tab.delete;
             tp_rejection_code_tab.delete;
             burden_rejection_code_tab.delete;
             other_rejection_code_tab.delete;
             delete_flag_tab.delete;
             error_flag_tab.delete;
             provisional_flag_tab.delete;
             JOB_ID_tab.delete;
             TP_AMOUNT_TYPE_tab.delete;
             OVERPROVISIONAL_QTY_tab.delete;
             OVER_PROV_CONF_QTY_tab.delete;
             CONFIRMED_QTY_tab.delete;
             PROVISIONAL_QTY_tab.delete;
             asgmt_sys_status_code_tab.delete;
             capacity_quantity_tab.delete;
             overcommitment_quantity_tab.delete;
             availability_quantity_tab.delete;
             overcommitment_flag_tab.delete;
             availability_flag_tab.delete;

             PA_DEBUG.Init_err_stack( 'PA_FORECASTITEM_PVT.Delete_FI_Hdr');

             SELECT   forecast_item_id, forecast_item_type,
                      project_org_id , expenditure_org_id,
                      project_organization_id, expenditure_organization_id ,
                      project_id, project_type_class, person_id ,
                      resource_id, borrowed_flag, assignment_id,
                      item_date, item_uom, item_quantity,
                      pvdr_period_set_name, pvdr_pa_period_name,
                      pvdr_gl_period_name, rcvr_period_set_name,
                      rcvr_pa_period_name, rcvr_gl_period_name,
                      global_exp_period_end_date, expenditure_type,
                      expenditure_type_class, cost_rejection_code,
                      rev_rejection_code, tp_rejection_code,
                      burden_rejection_code, other_rejection_code,
                      delete_flag, error_flag, provisional_flag,
                      JOB_ID,
                      TP_AMOUNT_TYPE,
                      OVERPROVISIONAL_QTY,
                      OVER_PROV_CONF_QTY,
                      CONFIRMED_QTY,
                      PROVISIONAL_QTY,
                      asgmt_sys_status_code, capacity_quantity,
                      overcommitment_quantity, availability_quantity,
                      overcommitment_flag, availability_flag
                              BULK COLLECT INTO forecast_item_id_tab, forecast_item_type_tab,
                      project_org_id_tab, expenditure_org_id_tab,
                      project_organization_id_tab, expenditure_orgn_id_tab,
                      project_id_tab, project_type_class_tab, person_id_tab,
                      resource_id_tab, borrowed_flag_tab, assignment_id_tab,
                      item_date_tab, item_uom_tab, item_quantity_tab,
                      pvdr_period_set_name_tab, pvdr_pa_period_name_tab,
                      pvdr_gl_period_name_tab, rcvr_period_set_name_tab,
                      rcvr_pa_period_name_tab, rcvr_gl_period_name_tab,
                      global_exp_period_end_date_tab, expenditure_type_tab,
                      expenditure_type_class_tab, cost_rejection_code_tab,
                      rev_rejection_code_tab, tp_rejection_code_tab,
                      burden_rejection_code_tab, other_rejection_code_tab,
                      delete_flag_tab, error_flag_tab, provisional_flag_tab,
                      JOB_ID_tab,
                      TP_AMOUNT_TYPE_tab,
                      OVERPROVISIONAL_QTY_tab,
                      OVER_PROV_CONF_QTY_tab,
                      CONFIRMED_QTY_tab,
                      PROVISIONAL_QTY_tab,
                      asgmt_sys_status_code_tab, capacity_quantity_tab,
                      overcommitment_quantity_tab, availability_quantity_tab,
                      overcommitment_flag_tab, availability_flag_tab
                     FROM   pa_forecast_items hdr
             WHERE  hdr.assignment_id = p_assignment_id
             AND    hdr.delete_flag = 'N'
             order by item_date, forecast_item_id ;

             IF forecast_item_id_tab.count = 0 THEN

                Print_message(
                          'Leaving Delete_FI_Hdr');

                x_return_status := lv_return_status;

                RETURN;

             END IF;

             -- Move to one table FROM multiple tables

             TmpUpdTab.Delete;

             FOR j IN forecast_item_id_tab.FIRST..forecast_item_id_tab.LAST LOOP

                TmpUpdTab(j).forecast_item_id := forecast_item_id_tab(j);
                TmpUpdTab(j).forecast_item_type := forecast_item_type_tab(j);
                TmpUpdTab(j).project_org_id  := project_org_id_tab(j);
                TmpUpdTab(j).expenditure_org_id := expenditure_org_id_tab(j);
                TmpUpdTab(j).project_organization_id :=
                                         project_organization_id_tab(j);
                TmpUpdTab(j).expenditure_organization_id  :=
                                         expenditure_orgn_id_tab(j);
                TmpUpdTab(j).project_id := project_id_tab(j);
                TmpUpdTab(j).project_type_class := project_type_class_tab(j);
                TmpUpdTab(j).person_id  := person_id_tab(j);
                TmpUpdTab(j).resource_id := resource_id_tab(j);
                TmpUpdTab(j).borrowed_flag := borrowed_flag_tab(j);
                TmpUpdTab(j).assignment_id := assignment_id_tab(j);
                TmpUpdTab(j).item_date := item_date_tab(j);
                TmpUpdTab(j).item_uom := item_uom_tab(j);
                TmpUpdTab(j).CAPACITY_QUANTITY := NULL;
                TmpUpdTab(j).OVERCOMMITMENT_QTY := NULL;
-- Start fix for bug 2504222 (changed for consistency, not vital for fix)
                TmpUpdTab(j).OVERCOMMITMENT_QUANTITY := NULL;
-- End fix for bug 2504222
                TmpUpdTab(j).OVERPROVISIONAL_QTY := NULL;
                TmpUpdTab(j).OVER_PROV_CONF_QTY := NULL;
                TmpUpdTab(j).CONFIRMED_QTY := NULL;
                TmpUpdTab(j).PROVISIONAL_QTY := NULL;
                TmpUpdTab(j).item_quantity := 0;
                TmpUpdTab(j).pvdr_period_set_name :=
                                         pvdr_period_set_name_tab(j);
                TmpUpdTab(j).pvdr_pa_period_name := pvdr_pa_period_name_tab(j);
                TmpUpdTab(j).pvdr_gl_period_name := pvdr_gl_period_name_tab(j);
                TmpUpdTab(j).rcvr_period_set_name :=
                                         rcvr_period_set_name_tab(j);
                TmpUpdTab(j).rcvr_pa_period_name := rcvr_pa_period_name_tab(j);
                TmpUpdTab(j).rcvr_gl_period_name := rcvr_gl_period_name_tab(j);
                TmpUpdTab(j).global_exp_period_end_date :=
                                         global_exp_period_end_date_tab(j);
                TmpUpdTab(j).expenditure_type := expenditure_type_tab(j);
                TmpUpdTab(j).expenditure_type_class :=
                                         expenditure_type_class_tab(j);
                TmpUpdTab(j).cost_rejection_code := cost_rejection_code_tab(j);
                TmpUpdTab(j).rev_rejection_code := rev_rejection_code_tab(j);
                TmpUpdTab(j).tp_rejection_code := tp_rejection_code_tab(j);
                TmpUpdTab(j).burden_rejection_code :=
                                         burden_rejection_code_tab(j);
                TmpUpdTab(j).other_rejection_code :=
                                         other_rejection_code_tab(j);
                TmpUpdTab(j).delete_flag := 'Y';
                TmpUpdTab(j).error_flag := error_flag_tab(j);
                TmpUpdTab(j).provisional_flag := provisional_flag_tab(j);
                TmpUpdTab(j).JOB_ID := JOB_ID_tab(j);
                TmpUpdTab(j).TP_AMOUNT_TYPE := TP_AMOUNT_TYPE_tab(j);
                TmpUpdTab(j).OVERPROVISIONAL_QTY := OVERPROVISIONAL_QTY_tab(j);
                TmpUpdTab(j).OVER_PROV_CONF_QTY := OVER_PROV_CONF_QTY_tab(j);
                TmpUpdTab(j).CONFIRMED_QTY := CONFIRMED_QTY_tab(j);
                TmpUpdTab(j).PROVISIONAL_QTY := PROVISIONAL_QTY_tab(j);
                TmpUpdTab(j).asgmt_sys_status_code := asgmt_sys_status_code_tab(j);
                TmpUpdTab(j).capacity_quantity := capacity_quantity_tab(j);
                TmpUpdTab(j).overcommitment_quantity :=  overcommitment_quantity_tab(j);
                TmpUpdTab(j).availability_quantity :=  availability_quantity_tab(j);
                TmpUpdTab(j).overcommitment_flag := overcommitment_flag_tab(j);
                TmpUpdTab(j).availability_flag := availability_flag_tab(j);

             END LOOP;

             IF TmpUpdTab.COUNT > 0 THEN

                Print_message(
                           'Calling PA_FORECAST_HDR_PKG.Update_Rows ');

                PA_FORECAST_HDR_PKG.Update_Rows(TmpUpdTab,
                                                lv_return_status,
                                                x_msg_count,
                                                x_msg_data);

             END IF;


             Print_message(
                         'Leaving Delete_FI_Hdr');

             PA_DEBUG.Reset_Err_Stack;

             x_return_status := lv_return_status;

       EXCEPTION

             WHEN OTHERS THEN
                  print_message('Failed in Delete_FI_Hdr api');
                  print_message('SQLCODE'||sqlcode||sqlerrm);

                  x_msg_count     := 1;
                  x_msg_data      := sqlerrm;
                  x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

                  FND_MSG_PUB.add_exc_msg
                      (p_pkg_name   =>
                              'PA_FORECASTITEM_PVT.Delete_FI_Hdr',
                       p_procedure_name => PA_DEBUG.G_Err_Stack);

		               If x_msg_count = 1 THEN
				              pa_interface_utils_pub.get_messages
				                (p_encoded        => FND_API.G_TRUE,
					               p_msg_index      => 1,
					               p_msg_count      => x_msg_count,
					               p_msg_data       => x_msg_data,
					               p_data           => l_data ,  -- 4537865
					               p_msg_index_out  => l_msg_index_out );
						x_msg_data := l_data ;  -- 4537865
		               End If;
                  Print_message(x_msg_data);

                  RAISE;

       END  Delete_FI_Hdr;

/* ---------------------------------------------------------------------
|   Procedure  :   Delete_FI_Dtl
|   Purpose    :   To reverse the existing forecast items detail(Requirement)
|                  when a resource is identified FOR a requirement
|   Parameters :   p_assignment_id  - Input Assignment ID
|                  x_return_status     -
|                  x_msg_count         -
|                  x_msg_data          -
+----------------------------------------------------------------------*/

       PROCEDURE  Delete_FI_Dtl(
                  p_assignment_id     IN NUMBER,
                  x_return_status     OUT NOCOPY   VARCHAR2,  -- 4537865
                  x_msg_count         OUT NOCOPY  NUMBER,  -- 4537865
                  x_msg_data          OUT NOCOPY  VARCHAR2) IS  -- 4537865

		   l_data varchar2(2000) ; -- 4537865
	           l_msg_index_out	            NUMBER;
             forecast_item_id_tab            PA_FORECAST_GLOB.NumberTabTyp;
             amount_type_id_tab              PA_FORECAST_GLOB.NumberTabTyp;
             line_num_tab                    PA_FORECAST_GLOB.NumberTabTyp;
             resource_type_code_tab          PA_FORECAST_GLOB.VCTabTyp;
             person_billable_flag_tab        PA_FORECAST_GLOB.VC1TabTyp;
             item_date_tab                   PA_FORECAST_GLOB.DateTabTyp;
             item_UOM_tab                    PA_FORECAST_GLOB.VCTabTyp;
             item_quantity_tab               PA_FORECAST_GLOB.NumberTabTyp;
             expenditure_org_id_tab          PA_FORECAST_GLOB.NumberTabTyp;
             project_org_id_tab              PA_FORECAST_GLOB.NumberTabTyp;
             PJI_SUMMARIZED_FLAG_tab         PA_FORECAST_GLOB.VC1TabTyp;
             CAPACITY_QUANTITY_tab         PA_FORECAST_GLOB.NumberTabTyp;
             OVERCOMMITMENT_QTY_tab         PA_FORECAST_GLOB.NumberTabTyp;
             OVERPROVISIONAL_QTY_tab         PA_FORECAST_GLOB.NumberTabTyp;
             OVER_PROV_CONF_QTY_tab         PA_FORECAST_GLOB.NumberTabTyp;
             CONFIRMED_QTY_tab         PA_FORECAST_GLOB.NumberTabTyp;
             PROVISIONAL_QTY_tab         PA_FORECAST_GLOB.NumberTabTyp;
             JOB_ID_tab         PA_FORECAST_GLOB.NumberTabTyp;
             PROJECT_ID_tab         PA_FORECAST_GLOB.NumberTabTyp;
             RESOURCE_ID_tab         PA_FORECAST_GLOB.NumberTabTyp;
             EXP_ORGANIZATION_ID_tab         PA_FORECAST_GLOB.NumberTabTyp;
             pvdr_acct_curr_code_tab         PA_FORECAST_GLOB.VC15TabTyp;
             pvdr_acct_amount_tab            PA_FORECAST_GLOB.NumberTabTyp;
             rcvr_acct_curr_code_tab         PA_FORECAST_GLOB.VC15TabTyp;
             rcvr_acct_amount_tab            PA_FORECAST_GLOB.NumberTabTyp;
             proj_currency_code_tab          PA_FORECAST_GLOB.VC15TabTyp;
             proj_amount_tab                 PA_FORECAST_GLOB.NumberTabTyp;
             denom_currency_code_tab         PA_FORECAST_GLOB.VC15TabTyp;
             denom_amount_tab                PA_FORECAST_GLOB.NumberTabTyp;
             tp_amount_type_tab              PA_FORECAST_GLOB.VCTabTyp;
             billable_flag_tab               PA_FORECAST_GLOB.VC1TabTyp;
             forecast_summarized_code_tab    PA_FORECAST_GLOB.VCTabTyp;
             util_summarized_code_tab        PA_FORECAST_GLOB.VCTabTyp;
             work_type_id_tab                PA_FORECAST_GLOB.NumberTabTyp;
             resource_util_category_id_tab   PA_FORECAST_GLOB.NumberTabTyp;
             org_util_category_id_tab        PA_FORECAST_GLOB.NumberTabTyp;
             resource_util_weighted_tab      PA_FORECAST_GLOB.NumberTabTyp;
             org_util_weighted_tab           PA_FORECAST_GLOB.NumberTabTyp;
             provisional_flag_tab            PA_FORECAST_GLOB.VC1TabTyp;
             reversed_flag_tab               PA_FORECAST_GLOB.VC1TabTyp;
             net_zero_flag_tab               PA_FORECAST_GLOB.VC1TabTyp;
             reduce_capacity_flag_tab        PA_FORECAST_GLOB.VC1TabTyp;
             line_num_reversed_tab           PA_FORECAST_GLOB.NumberTabTyp;

             TmpRevTab                       PA_FORECAST_GLOB.FIDtlTabTyp;
             TmpUpdTab                       PA_FORECAST_GLOB.FIDtlTabTyp;
             l_rev_index                     NUMBER;
             lv_return_status                VARCHAR2(30);

       BEGIN

             lv_return_status := FND_API.G_RET_STS_SUCCESS;

             Print_message( 'Entering Delete_FI_Dtl');

             PA_DEBUG.Init_err_stack( 'PA_FORECASTITEM_PVT.Delete_FI_Dtl');

             TmpRevTab.Delete;
             TmpUpdTab.Delete;
             forecast_item_id_tab.delete;
             amount_type_id_tab.delete;
             line_num_tab.delete;
             resource_type_code_tab.delete;
             person_billable_flag_tab.delete;
             item_date_tab.delete;
             item_UOM_tab.delete;
             item_quantity_tab.delete;
             expenditure_org_id_tab.delete;
             project_org_id_tab.delete;
             PJI_SUMMARIZED_FLAG_tab.delete;
             CAPACITY_QUANTITY_tab.delete;
             OVERCOMMITMENT_QTY_tab.delete;
             OVERPROVISIONAL_QTY_tab.delete;
             OVER_PROV_CONF_QTY_tab.delete;
             CONFIRMED_QTY_tab.delete;
             PROVISIONAL_QTY_tab.delete;
             JOB_ID_tab.delete;
             PROJECT_ID_tab.delete;
             RESOURCE_ID_tab.delete;
             EXP_ORGANIZATION_ID_tab.delete;
             pvdr_acct_curr_code_tab.delete;
             pvdr_acct_amount_tab.delete;
             rcvr_acct_curr_code_tab.delete;
             rcvr_acct_amount_tab.delete;
             proj_currency_code_tab.delete;
             proj_amount_tab.delete;
             denom_currency_code_tab.delete;
             denom_amount_tab.delete;
             tp_amount_type_tab.delete;
             billable_flag_tab.delete;
             forecast_summarized_code_tab.delete;
             util_summarized_code_tab.delete;
             work_type_id_tab.delete;
             resource_util_category_id_tab.delete;
             org_util_category_id_tab.delete;
             resource_util_weighted_tab.delete;
             org_util_weighted_tab.delete;
             provisional_flag_tab.delete;
             reversed_flag_tab.delete;
             net_zero_flag_tab.delete;
             reduce_capacity_flag_tab.delete;
             line_num_reversed_tab.delete;

             SELECT dtl.forecast_item_id, dtl.amount_type_id,
                    dtl.line_num, dtl.resource_type_code,
                    dtl.person_billable_flag, dtl.item_UOM, dtl.item_date,
                    dtl.PJI_SUMMARIZED_FLAG,
                    dtl.CAPACITY_QUANTITY,
                    dtl.OVERCOMMITMENT_QTY,
                    dtl.OVERPROVISIONAL_QTY,
                    dtl.OVER_PROV_CONF_QTY,
                    dtl.CONFIRMED_QTY,
                    dtl.PROVISIONAL_QTY,
                    dtl.JOB_ID,
                    dtl.PROJECT_ID,
                    dtl.RESOURCE_ID,
                    dtl.EXPENDITURE_ORGANIZATION_ID,
                    dtl.item_quantity, dtl.expenditure_org_id,
                    dtl.project_org_id, dtl.pvdr_acct_curr_code,
                    dtl.pvdr_acct_amount, dtl.rcvr_acct_curr_code,
                    dtl.rcvr_acct_amount, dtl.proj_currency_code,
                    dtl.proj_amount, dtl.denom_currency_code, dtl.denom_amount,
                    dtl.tp_amount_type, dtl.billable_flag,
                    dtl.forecast_summarized_code, dtl.util_summarized_code,
                    dtl.work_type_id, dtl.resource_util_category_id,
                    dtl.org_util_category_id, dtl.resource_util_weighted,
                    dtl.org_util_weighted, dtl.provisional_flag,
                    dtl.reversed_flag, dtl.net_zero_flag,
                    dtl.reduce_capacity_flag, dtl.line_num_reversed
             BULK COLLECT INTO forecast_item_id_tab,amount_type_id_tab,
                    line_num_tab, resource_type_code_tab,
                    person_billable_flag_tab, item_UOM_tab, item_date_tab,
                    PJI_SUMMARIZED_FLAG_tab,
                    CAPACITY_QUANTITY_tab,
                    OVERCOMMITMENT_QTY_tab,
                    OVERPROVISIONAL_QTY_tab,
                    OVER_PROV_CONF_QTY_tab,
                    CONFIRMED_QTY_tab,
                    PROVISIONAL_QTY_tab,
                    JOB_ID_tab,
                    PROJECT_ID_tab,
                    RESOURCE_ID_tab,
                    EXP_ORGANIZATION_ID_tab,
                    item_quantity_tab, expenditure_org_id_tab,
                    project_org_id_tab, pvdr_acct_curr_code_tab,
                    pvdr_acct_amount_tab, rcvr_acct_curr_code_tab,
                    rcvr_acct_amount_tab, proj_currency_code_tab,
                    proj_amount_tab, denom_currency_code_tab, denom_amount_tab,
                    tp_amount_type_tab, billable_flag_tab,
                    forecast_summarized_code_tab, util_summarized_code_tab,
                    work_type_id_tab, resource_util_category_id_tab,
                    org_util_category_id_tab, resource_util_weighted_tab,
                    org_util_weighted_tab, provisional_flag_tab,
                    reversed_flag_tab, net_zero_flag_tab,
                    reduce_capacity_flag_tab, line_num_reversed_tab
             FROM   pa_forecast_item_details dtl, pa_forecast_items hdr
             WHERE  hdr.assignment_id = p_assignment_id
             AND    hdr.delete_flag = 'N'
             AND    dtl.forecast_item_id = hdr.forecast_item_id
             AND    dtl.line_num =
                      (SELECT max(line_num)
                       FROM pa_forecast_item_details dtl1
                       WHERE dtl1.forecast_item_id = hdr.forecast_item_id AND trunc(dtl1.item_date) = trunc(hdr.item_date) ) -- 4918687 SQL ID 14905526
	     AND    trunc(dtl.item_date) = trunc(hdr.item_date) -- 4918687 SQL ID 14905526
             order by dtl.item_date, dtl.forecast_item_id ;

             IF forecast_item_id_tab.count = 0 THEN

                Print_message( 'Leaving Delete_FI_Dtl');

                x_return_status := lv_return_status;

                RETURN;

             END IF;

             TmpRevTab.Delete;
             TmpUpdTab.Delete;

             -- Move to one table FROM multiple tables

             FOR j IN forecast_item_id_tab.FIRST..forecast_item_id_tab.LAST LOOP

                 TmpUpdTab(j).forecast_item_id := forecast_item_id_tab(j);
                 TmpUpdTab(j).amount_type_id :=amount_type_id_tab(j);
                 TmpUpdTab(j).line_num := line_num_tab(j);
                 TmpUpdTab(j).resource_type_code := resource_type_code_tab(j);
                 TmpUpdTab(j).person_billable_flag :=
                                 person_billable_flag_tab(j);
                 TmpUpdTab(j).item_Uom := item_UOM_tab(j);
                 TmpUpdTab(j).item_date := item_date_tab(j);
                 TmpUpdTab(j).item_quantity := item_quantity_tab(j);
                 TmpUpdTab(j).expenditure_org_id := expenditure_org_id_tab(j);
                 TmpUpdTab(j).project_org_id := project_org_id_tab(j);
                 TmpUpdTab(j).pvdr_acct_curr_code := pvdr_acct_curr_code_tab(j);
                 TmpUpdTab(j).PJI_SUMMARIZED_FLAG := PJI_SUMMARIZED_FLAG_tab(j);
                 TmpUpdTab(j).CAPACITY_QUANTITY := CAPACITY_QUANTITY_tab(j);
                 TmpUpdTab(j).OVERCOMMITMENT_QTY := OVERCOMMITMENT_QTY_tab(j);
                 TmpUpdTab(j).OVERPROVISIONAL_QTY := OVERPROVISIONAL_QTY_tab(j);
                 TmpUpdTab(j).OVER_PROV_CONF_QTY := OVER_PROV_CONF_QTY_tab(j);
                 TmpUpdTab(j).CONFIRMED_QTY := CONFIRMED_QTY_tab(j);
                 TmpUpdTab(j).PROVISIONAL_QTY := PROVISIONAL_QTY_tab(j);
                 TmpUpdTab(j).JOB_ID := JOB_ID_tab(j);
                 TmpUpdTab(j).PROJECT_ID := PROJECT_ID_tab(j);
                 TmpUpdTab(j).RESOURCE_ID := RESOURCE_ID_tab(j);
                 TmpUpdTab(j).EXPENDITURE_ORGANIZATION_ID := EXP_ORGANIZATION_ID_tab(j);
                 TmpUpdTab(j).pvdr_acct_amount := pvdr_acct_amount_tab(j);
                 TmpUpdTab(j).rcvr_acct_curr_code :=
                                 rcvr_acct_curr_code_tab(j);
                 TmpUpdTab(j).rcvr_acct_amount := rcvr_acct_amount_tab(j);
                 TmpUpdTab(j).proj_currency_code := proj_currency_code_tab(j);
                 TmpUpdTab(j).proj_amount := proj_amount_tab(j);
                 TmpUpdTab(j).denom_currency_code := denom_currency_code_tab(j);
                 TmpUpdTab(j).denom_amount := denom_amount_tab(j);
                 TmpUpdTab(j).tp_amount_type := tp_amount_type_tab(j);
                 TmpUpdTab(j).billable_flag := billable_flag_tab(j);
                 TmpUpdTab(j).forecast_summarized_code :=
                                 forecast_summarized_code_tab(j);
                 TmpUpdTab(j).util_summarized_code :=
                                 util_summarized_code_tab(j);
                 TmpUpdTab(j).work_type_id := work_type_id_tab(j);
                 TmpUpdTab(j).resource_util_category_id :=
                                 resource_util_category_id_tab(j);
                 TmpUpdTab(j).org_util_category_id :=
                                 org_util_category_id_tab(j);
                 TmpUpdTab(j).resource_util_weighted :=
                                 resource_util_weighted_tab(j);
                 TmpUpdTab(j).org_util_weighted :=
                                 org_util_weighted_tab(j);
                 TmpUpdTab(j).provisional_flag := provisional_flag_tab(j);
                 TmpUpdTab(j).reversed_flag := 'Y';
                 TmpUpdTab(j).net_zero_flag := net_zero_flag_tab(j);
                 TmpUpdTab(j).reduce_capacity_flag :=
                                   reduce_capacity_flag_tab(j);
                 TmpUpdTab(j).line_num_reversed := line_num_reversed_tab(j);

             END LOOP;

             l_rev_index := 1;

             if (TmpUpdTab.count <> 0) then
             FOR j IN TmpUpdTab.FIRST..TmpUpdTab.LAST LOOP
                 IF TmpUpdTab.exists(j) then

                 IF (NVL(TmpUpdTab(j).forecast_summarized_code,'Y') = 'Y'
                        OR NVL(TmpUpdTab(j).PJI_SUMMARIZED_FLAG,'Y') = 'Y'
                        OR  NVL(TmpUpdTab(j).util_summarized_code,'Y') = 'Y' )
                        AND (
                              NVL(TmpUpdTab(j).CAPACITY_QUANTITY,0) > 0 OR
                              NVL(TmpUpdTab(j).OVERCOMMITMENT_QTY,0) > 0 OR
                              NVL(TmpUpdTab(j).OVERPROVISIONAL_QTY,0) > 0 OR
                              NVL(TmpUpdTab(j).OVER_PROV_CONF_QTY,0) > 0 OR
                              NVL(TmpUpdTab(j).CONFIRMED_QTY,0) > 0 OR
                              NVL(TmpUpdTab(j).PROVISIONAL_QTY,0) > 0 OR
                              TmpUpdTab(j).item_quantity > 0
                             ) THEN

                    TmpRevTab(l_rev_index) := TmpUpdTab(j);
                    IF (NVL(TmpUpdTab(j).CAPACITY_QUANTITY,0) = 0) THEN
                       TmpRevTab(l_rev_index).CAPACITY_QUANTITY := NULL;
                    ELSE
                       TmpRevTab(l_rev_index).CAPACITY_QUANTITY :=
                          NVL(TmpUpdTab(j).CAPACITY_QUANTITY,0) * -1;
                    END IF;
                    IF (NVL(TmpUpdTab(j).OVERCOMMITMENT_QTY,0) = 0) THEN
                       TmpRevTab(l_rev_index).OVERCOMMITMENT_QTY := NULL;
                    ELSE
                       TmpRevTab(l_rev_index).OVERCOMMITMENT_QTY :=
                          NVL(TmpUpdTab(j).OVERCOMMITMENT_QTY,0) * -1;
                    END IF;
                    IF (NVL(TmpUpdTab(j).OVERPROVISIONAL_QTY,0) = 0) THEN
                       TmpRevTab(l_rev_index).OVERPROVISIONAL_QTY := NULL;
                    ELSE
                       TmpRevTab(l_rev_index).OVERPROVISIONAL_QTY :=
                          NVL(TmpUpdTab(j).OVERPROVISIONAL_QTY,0) * -1;
                    END IF;
                    IF (NVL(TmpUpdTab(j).OVER_PROV_CONF_QTY,0) = 0) THEN
                       TmpRevTab(l_rev_index).OVER_PROV_CONF_QTY := NULL;
                    ELSE
                       TmpRevTab(l_rev_index).OVER_PROV_CONF_QTY :=
                          NVL(TmpUpdTab(j).OVER_PROV_CONF_QTY,0) * -1;
                    END IF;
                    IF (NVL(TmpUpdTab(j).CONFIRMED_QTY,0) = 0) THEN
                       TmpRevTab(l_rev_index).CONFIRMED_QTY := NULL;
                    ELSE
                       TmpRevTab(l_rev_index).CONFIRMED_QTY :=
                          NVL(TmpUpdTab(j).CONFIRMED_QTY,0) * -1;
                    END IF;
                    IF (NVL(TmpUpdTab(j).PROVISIONAL_QTY,0) = 0) THEN
                       TmpRevTab(l_rev_index).PROVISIONAL_QTY := NULL;
                    ELSE
                       TmpRevTab(l_rev_index).PROVISIONAL_QTY :=
                          NVL(TmpUpdTab(j).PROVISIONAL_QTY,0) * -1;
                    END IF;
                    TmpRevTab(l_rev_index).item_quantity :=
                                  TmpUpdTab(j).item_quantity * -1;
                    TmpRevTab(l_rev_index).resource_util_weighted :=
                                  TmpUpdTab(j).resource_util_weighted * -1;
                    TmpRevTab(l_rev_index).org_util_weighted :=
                                  TmpUpdTab(j).org_util_weighted * -1;

                    IF NVL(TmpUpdTab(j).forecast_summarized_code,'Y') = 'Y' THEN

                       TmpRevTab(l_rev_index).forecast_summarized_code := 'N';

                    ELSE

                       TmpRevTab(l_rev_index).forecast_summarized_code :=
                               TmpUpdTab(j).forecast_summarized_code;

                    END IF;

                    IF NVL(TmpUpdTab(j).PJI_SUMMARIZED_FLAG,'Y') = 'Y' THEN
                      TmpRevTab(l_rev_index).PJI_SUMMARIZED_FLAG := 'N';
                    ELSE
                      TmpRevTab(l_rev_index).PJI_SUMMARIZED_FLAG :=
                              TmpUpdTab(j).PJI_SUMMARIZED_FLAG;
                    END IF;

                    IF NVL(TmpUpdTab(j).util_summarized_code,'Y') = 'Y' THEN

                       TmpRevTab(l_rev_index).util_summarized_code := 'N';

                    ELSE

                       TmpRevTab(l_rev_index).util_summarized_code :=
                               TmpUpdTab(j).util_summarized_code;

                    END IF;

                    TmpRevTab(l_rev_index).line_num_reversed :=
                                  TmpUpdTab(j).line_num;  -- Bug 4244913
                    TmpRevTab(l_rev_index).line_num :=
                                  TmpUpdTab(j).line_num + 1;  -- Bug 4244913
                    TmpRevTab(l_rev_index).net_zero_flag := 'Y';
                    l_rev_index := l_rev_index + 1;

                    TmpUpdTab(j).net_zero_flag := 'Y';
                    TmpUpdTab(j).reversed_flag := 'Y';

                 ELSE

                    TmpUpdTab(j).CAPACITY_QUANTITY := NULL;
                    TmpUpdTab(j).OVERCOMMITMENT_QTY := NULL;
                    TmpUpdTab(j).OVERPROVISIONAL_QTY := NULL;
                    TmpUpdTab(j).OVER_PROV_CONF_QTY := NULL;
                    TmpUpdTab(j).CONFIRMED_QTY := NULL;
                    TmpUpdTab(j).PROVISIONAL_QTY := NULL;
                    TmpUpdTab(j).item_quantity := 0;
                    TmpUpdTab(j).org_util_weighted :=0;
                    TmpUpdTab(j).resource_util_weighted :=0;

                 END IF;
             end if;
             END LOOP;
             end if;

             IF TmpRevTab.COUNT > 0 THEN

                Print_message(
                           'Calling PA_FORECAST_DTLS_PKG.Insert_Rows ');

                PA_FORECAST_DTLS_PKG.Insert_Rows(TmpRevTab,
                                                lv_return_status,
                                                x_msg_count,
                                                x_msg_data);

             END IF;

             IF lv_return_status = FND_API.G_RET_STS_SUCCESS THEN

                IF TmpUpdTab.COUNT > 0 THEN

                   Print_message(
                           'Calling PA_FORECAST_DTLS_PKG.Update_Rows ');

                   PA_FORECAST_DTLS_PKG.Update_Rows(TmpUpdTab,
                                                lv_return_status,
                                                x_msg_count,
                                                x_msg_data);
                END IF;

             END IF;


             Print_message( 'Leaving Delete_FI_Dtl');

             PA_DEBUG.Reset_Err_Stack;

             x_return_status := lv_return_status;

       EXCEPTION

             WHEN OTHERS THEN
                  print_message('Failed in Delete FI Dtl api');
                  print_message('SQLCODE'||sqlcode||sqlerrm);

                  x_msg_count     := 1;
                  x_msg_data      := sqlerrm;
                  x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

                  FND_MSG_PUB.add_exc_msg
                      (p_pkg_name   =>
                              'PA_FORECASTITEM_PVT.Delete_FI_Dtl',
                       p_procedure_name => PA_DEBUG.G_Err_Stack);

		               If x_msg_count = 1 THEN
				              pa_interface_utils_pub.get_messages
				                (p_encoded        => FND_API.G_TRUE,
					               p_msg_index      => 1,
					               p_msg_count      => x_msg_count,
					               p_msg_data       => x_msg_data,
					               p_data           => l_data ,  -- 4537865
					               p_msg_index_out  => l_msg_index_out );
						x_msg_data := l_data ; -- 4537865
		               End If;
                  Print_message(x_msg_data);

                  RAISE;

       END  Delete_FI_Dtl;

/* ---------------------------------------------------------------------
|   Procedure  :   Delete_FI
|   Purpose    :   To delete all the forecast items FOR the given resource
|   Parameters :   p_resource_id
|                  x_return_status     -
|                  x_msg_count         -
|                  x_msg_data          -
+----------------------------------------------------------------------*/
       PROCEDURE  Delete_FI(
                  p_resource_id     IN   NUMBER,
                  x_return_status     OUT NOCOPY VARCHAR2, -- 4537865
                  x_msg_count         OUT NOCOPY NUMBER, -- 4537865
                  x_msg_data          OUT NOCOPY VARCHAR2) IS -- 4537865

             lv_return_status  VARCHAR2(30);

       BEGIN

             lv_return_status := FND_API.G_RET_STS_SUCCESS;

             Print_message( 'Entering Delete_FI');

             PA_DEBUG.Init_err_stack( 'PA_FORECASTITEM_PVT.Delete_FI');

             Delete_FI_Dtl(
                       p_resource_id => p_resource_id,
                       x_return_status => lv_return_status,
                       x_msg_count => x_msg_count,
                       x_msg_data => x_msg_data);

             IF lv_return_status = FND_API.G_RET_STS_SUCCESS THEN

                Delete_FI_Hdr(
                       p_resource_id => p_resource_id,
                       x_return_status => lv_return_status,
                       x_msg_count => x_msg_count,
                       x_msg_data => x_msg_data);

             END IF;

             Print_message(
                         'Leaving Delete_FI');

             PA_DEBUG.Reset_Err_Stack;

             x_return_status := lv_return_status;

        EXCEPTION

             WHEN OTHERS THEN
                  print_message('Failed in Delete FI api');
                  print_message('SQLCODE'||sqlcode||sqlerrm);

                  x_msg_count     := 1;
                  x_msg_data      := sqlerrm;
                  x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

                  FND_MSG_PUB.add_exc_msg
                      (p_pkg_name   =>
                              'PA_FORECASTITEM_PVT.Delete_FI',
                       p_procedure_name => PA_DEBUG.G_Err_Stack);

                  Print_message(x_msg_data);

                  --RAISE;

       END Delete_FI;

/* ---------------------------------------------------------------------
|   Procedure  :   Delete_FI_Hdr
|   Purpose    :   To reverse the existing forecast items
|   Parameters :   p_resource_id
|                  x_return_status
|                  x_msg_count
|                  x_msg_data
+----------------------------------------------------------------------*/
       PROCEDURE  Delete_FI_Hdr(
                  p_resource_id     IN    NUMBER,
                  x_return_status     OUT  NOCOPY VARCHAR2, -- 4537865
                  x_msg_count         OUT  NOCOPY NUMBER, -- 4537865
                  x_msg_data          OUT  NOCOPY VARCHAR2) IS -- 4537865


             forecast_item_id_tab                PA_FORECAST_GLOB.NumberTabTyp;
             forecast_item_type_tab              PA_FORECAST_GLOB.VCTabTyp;
             project_org_id_tab                  PA_FORECAST_GLOB.NumberTabTyp;
             expenditure_org_id_tab              PA_FORECAST_GLOB.NumberTabTyp;
             expenditure_orgn_id_tab             PA_FORECAST_GLOB.NumberTabTyp;
             project_organization_id_tab         PA_FORECAST_GLOB.NumberTabTyp;
             project_id_tab                      PA_FORECAST_GLOB.NumberTabTyp;
             project_type_class_tab              PA_FORECAST_GLOB.VCTabTyp;
             person_id_tab                       PA_FORECAST_GLOB.NumberTabTyp;
             resource_id_tab                     PA_FORECAST_GLOB.NumberTabTyp;
             borrowed_flag_tab                   PA_FORECAST_GLOB.VC1TabTyp;
             assignment_id_tab                   PA_FORECAST_GLOB.NumberTabTyp;
             item_date_tab                       PA_FORECAST_GLOB.DateTabTyp;
             item_uom_tab                        PA_FORECAST_GLOB.VCTabTyp;
             item_quantity_tab                   PA_FORECAST_GLOB.NumberTabTyp;
             pvdr_period_set_name_tab            PA_FORECAST_GLOB.VCTabTyp;
             pvdr_pa_period_name_tab             PA_FORECAST_GLOB.VCTabTyp;
             pvdr_gl_period_name_tab             PA_FORECAST_GLOB.VCTabTyp;
             rcvr_period_set_name_tab            PA_FORECAST_GLOB.VCTabTyp;
             rcvr_pa_period_name_tab             PA_FORECAST_GLOB.VCTabTyp;
             rcvr_gl_period_name_tab             PA_FORECAST_GLOB.VCTabTyp;
             global_exp_period_end_date_tab      PA_FORECAST_GLOB.DateTabTyp;
             expenditure_type_tab                PA_FORECAST_GLOB.VCTabTyp;
             expenditure_type_class_tab          PA_FORECAST_GLOB.VCTabTyp;
             cost_rejection_code_tab             PA_FORECAST_GLOB.VCTabTyp;
             rev_rejection_code_tab              PA_FORECAST_GLOB.VCTabTyp;
             tp_rejection_code_tab               PA_FORECAST_GLOB.VCTabTyp;
             burden_rejection_code_tab           PA_FORECAST_GLOB.VCTabTyp;
             other_rejection_code_tab            PA_FORECAST_GLOB.VCTabTyp;
             delete_flag_tab                     PA_FORECAST_GLOB.VC1TabTyp;
             error_flag_tab                      PA_FORECAST_GLOB.VC1TabTyp;
             provisional_flag_tab                PA_FORECAST_GLOB.VC1TabTyp;

             TmpUpdTab                           PA_FORECAST_GLOB.FIHdrTabTyp;

             lv_return_status                    VARCHAR2(30);

       BEGIN

             lv_return_status := FND_API.G_RET_STS_SUCCESS;

             Print_message( 'Entering Delete_FI_Hdr');

             TmpUpdTab.delete;
             forecast_item_id_tab.delete;
             forecast_item_type_tab.delete;
             project_org_id_tab.delete;
             expenditure_org_id_tab.delete;
             expenditure_orgn_id_tab.delete;
             project_organization_id_tab.delete;
             project_id_tab.delete;
             project_type_class_tab.delete;
             person_id_tab.delete;
             resource_id_tab.delete;
             borrowed_flag_tab.delete;
             assignment_id_tab.delete;
             item_date_tab.delete;
             item_uom_tab.delete;
             item_quantity_tab.delete;
             pvdr_period_set_name_tab.delete;
             pvdr_pa_period_name_tab.delete;
             pvdr_gl_period_name_tab.delete;
             rcvr_period_set_name_tab.delete;
             rcvr_pa_period_name_tab.delete;
             rcvr_gl_period_name_tab.delete;
             global_exp_period_end_date_tab.delete;
             expenditure_type_tab.delete;
             expenditure_type_class_tab.delete;
             cost_rejection_code_tab.delete;
             rev_rejection_code_tab.delete;
             tp_rejection_code_tab.delete;
             burden_rejection_code_tab.delete;
             other_rejection_code_tab.delete;
             delete_flag_tab.delete;
             error_flag_tab.delete;
             provisional_flag_tab.delete;

             PA_DEBUG.Init_err_stack( 'PA_FORECASTITEM_PVT.Delete_FI_Hdr');

             SELECT   forecast_item_id, forecast_item_type,
                      project_org_id , expenditure_org_id,
                      project_organization_id, expenditure_organization_id ,
                      project_id, project_type_class, person_id ,
                      resource_id, borrowed_flag, assignment_id,
                      item_date, item_uom, item_quantity,
                      pvdr_period_set_name, pvdr_pa_period_name,
                      pvdr_gl_period_name, rcvr_period_set_name,
                      rcvr_pa_period_name, rcvr_gl_period_name,
                      global_exp_period_end_date, expenditure_type,
                      expenditure_type_class, cost_rejection_code,
                      rev_rejection_code, tp_rejection_code,
                      burden_rejection_code, other_rejection_code,
                      delete_flag, error_flag, provisional_flag
             BULK COLLECT INTO forecast_item_id_tab, forecast_item_type_tab,
                      project_org_id_tab, expenditure_org_id_tab,
                      project_organization_id_tab, expenditure_orgn_id_tab,
                      project_id_tab, project_type_class_tab, person_id_tab,
                      resource_id_tab, borrowed_flag_tab, assignment_id_tab,
                      item_date_tab, item_uom_tab, item_quantity_tab,
                      pvdr_period_set_name_tab, pvdr_pa_period_name_tab,
                      pvdr_gl_period_name_tab, rcvr_period_set_name_tab,
                      rcvr_pa_period_name_tab, rcvr_gl_period_name_tab,
                      global_exp_period_end_date_tab, expenditure_type_tab,
                      expenditure_type_class_tab, cost_rejection_code_tab,
                      rev_rejection_code_tab, tp_rejection_code_tab,
                      burden_rejection_code_tab, other_rejection_code_tab,
                      delete_flag_tab, error_flag_tab, provisional_flag_tab
             FROM   pa_forecast_items hdr
             WHERE  hdr.resource_id = p_resource_id
             AND    hdr.delete_flag = 'N'
             AND    hdr.forecast_item_type = 'U'
             order by item_date, forecast_item_id ;

             IF forecast_item_id_tab.count = 0 THEN

                Print_message(
                          'Leaving Delete_FI_Hdr');

                x_return_status := lv_return_status;

                RETURN;

             END IF;

             -- Move to one table FROM multiple tables

             TmpUpdTab.Delete;

             FOR j IN forecast_item_id_tab.FIRST..forecast_item_id_tab.LAST LOOP

                TmpUpdTab(j).forecast_item_id := forecast_item_id_tab(j);
                TmpUpdTab(j).forecast_item_type := forecast_item_type_tab(j);
                TmpUpdTab(j).project_org_id  := project_org_id_tab(j);
                TmpUpdTab(j).expenditure_org_id := expenditure_org_id_tab(j);
                TmpUpdTab(j).project_organization_id :=
                                         project_organization_id_tab(j);
                TmpUpdTab(j).expenditure_organization_id  :=
                                         expenditure_orgn_id_tab(j);
                TmpUpdTab(j).project_id := project_id_tab(j);
                TmpUpdTab(j).project_type_class := project_type_class_tab(j);
                TmpUpdTab(j).person_id  := person_id_tab(j);
                TmpUpdTab(j).resource_id := resource_id_tab(j);
                TmpUpdTab(j).borrowed_flag := borrowed_flag_tab(j);
                TmpUpdTab(j).assignment_id := assignment_id_tab(j);
                TmpUpdTab(j).item_date := item_date_tab(j);
                TmpUpdTab(j).item_uom := item_uom_tab(j);
                TmpUpdTab(j).CAPACITY_QUANTITY := NULL;
                TmpUpdTab(j).OVERCOMMITMENT_QTY := NULL;
-- Start fix for bug 2504222 (changed for consistency, not vital for fix)
                TmpUpdTab(j).OVERCOMMITMENT_QUANTITY := NULL;
-- End fix for bug 2504222
                TmpUpdTab(j).OVERPROVISIONAL_QTY := NULL;
                TmpUpdTab(j).OVER_PROV_CONF_QTY := NULL;
                TmpUpdTab(j).CONFIRMED_QTY := NULL;
                TmpUpdTab(j).PROVISIONAL_QTY := NULL;
                TmpUpdTab(j).item_quantity := 0;
                TmpUpdTab(j).pvdr_period_set_name :=
                                         pvdr_period_set_name_tab(j);
                TmpUpdTab(j).pvdr_pa_period_name := pvdr_pa_period_name_tab(j);
                TmpUpdTab(j).pvdr_gl_period_name := pvdr_gl_period_name_tab(j);
                TmpUpdTab(j).rcvr_period_set_name :=
                                         rcvr_period_set_name_tab(j);
                TmpUpdTab(j).rcvr_pa_period_name := rcvr_pa_period_name_tab(j);
                TmpUpdTab(j).rcvr_gl_period_name := rcvr_gl_period_name_tab(j);
                TmpUpdTab(j).global_exp_period_end_date :=
                                         global_exp_period_end_date_tab(j);
                TmpUpdTab(j).expenditure_type := expenditure_type_tab(j);
                TmpUpdTab(j).expenditure_type_class :=
                                         expenditure_type_class_tab(j);
                TmpUpdTab(j).cost_rejection_code := cost_rejection_code_tab(j);
                TmpUpdTab(j).rev_rejection_code := rev_rejection_code_tab(j);
                TmpUpdTab(j).tp_rejection_code := tp_rejection_code_tab(j);
                TmpUpdTab(j).burden_rejection_code :=
                                         burden_rejection_code_tab(j);
                TmpUpdTab(j).other_rejection_code :=
                                         other_rejection_code_tab(j);
                TmpUpdTab(j).delete_flag := 'Y';
                TmpUpdTab(j).error_flag := error_flag_tab(j);
                TmpUpdTab(j).provisional_flag := provisional_flag_tab(j);

             END LOOP;

             IF TmpUpdTab.COUNT > 0 THEN

                Print_message(
                           'Calling PA_FORECAST_HDR_PKG.Update_Rows ');

                PA_FORECAST_HDR_PKG.Update_Rows(TmpUpdTab,
                                                lv_return_status,
                                                x_msg_count,
                                                x_msg_data);

             END IF;


             Print_message(
                         'Leaving Delete_FI_Hdr');

             PA_DEBUG.Reset_Err_Stack;

             x_return_status := lv_return_status;

       EXCEPTION

             WHEN NO_DATA_FOUND THEN

                  x_return_status := lv_return_status;

                  NULL;

             WHEN OTHERS THEN
                  print_message('Failed in Delete_FI_Hdr api');
                  print_message('SQLCODE'||sqlcode||sqlerrm);

                  x_msg_count     := 1;
                  x_msg_data      := sqlerrm;
                  x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

                  FND_MSG_PUB.add_exc_msg
                      (p_pkg_name   =>
                              'PA_FORECASTITEM_PVT.Delete_FI_Hdr',
                       p_procedure_name => PA_DEBUG.G_Err_Stack);

                  Print_message(x_msg_data);

                  --RAISE;

       END  Delete_FI_Hdr;


/* ---------------------------------------------------------------------
|   Procedure  :   Delete_FI_Dtl
|   Purpose    :   To reverse the existing forecast items detail(Requirement)
|                  when a resource is identified FOR a requirement
|   Parameters :   p_assignment_id  - Input Assignment ID
|                  x_return_status     -
|                  x_msg_count         -
|                  x_msg_data          -
+----------------------------------------------------------------------*/

       PROCEDURE  Delete_FI_Dtl(
                  p_resource_id     IN NUMBER,
                  x_return_status     OUT NOCOPY  VARCHAR2, -- 4537865
                  x_msg_count         OUT NOCOPY  NUMBER, -- 4537865
                  x_msg_data          OUT NOCOPY  VARCHAR2) IS -- 4537865


             forecast_item_id_tab            PA_FORECAST_GLOB.NumberTabTyp;
             amount_type_id_tab              PA_FORECAST_GLOB.NumberTabTyp;
             line_num_tab                    PA_FORECAST_GLOB.NumberTabTyp;
             resource_type_code_tab          PA_FORECAST_GLOB.VCTabTyp;
             person_billable_flag_tab        PA_FORECAST_GLOB.VC1TabTyp;
             item_date_tab                   PA_FORECAST_GLOB.DateTabTyp;
             item_UOM_tab                    PA_FORECAST_GLOB.VCTabTyp;
             item_quantity_tab               PA_FORECAST_GLOB.NumberTabTyp;
             expenditure_org_id_tab          PA_FORECAST_GLOB.NumberTabTyp;
             project_org_id_tab              PA_FORECAST_GLOB.NumberTabTyp;
             PJI_SUMMARIZED_FLAG_tab         PA_FORECAST_GLOB.VC1TabTyp;
             CAPACITY_QUANTITY_tab         PA_FORECAST_GLOB.NumberTabTyp;
             OVERCOMMITMENT_QTY_tab         PA_FORECAST_GLOB.NumberTabTyp;
             OVERPROVISIONAL_QTY_tab         PA_FORECAST_GLOB.NumberTabTyp;
             OVER_PROV_CONF_QTY_tab         PA_FORECAST_GLOB.NumberTabTyp;
             CONFIRMED_QTY_tab         PA_FORECAST_GLOB.NumberTabTyp;
             PROVISIONAL_QTY_tab         PA_FORECAST_GLOB.NumberTabTyp;
             JOB_ID_tab         PA_FORECAST_GLOB.NumberTabTyp;
             PROJECT_ID_tab         PA_FORECAST_GLOB.NumberTabTyp;
             RESOURCE_ID_tab         PA_FORECAST_GLOB.NumberTabTyp;
             EXP_ORGANIZATION_ID_tab         PA_FORECAST_GLOB.NumberTabTyp;
             pvdr_acct_curr_code_tab         PA_FORECAST_GLOB.VC15TabTyp;
             pvdr_acct_amount_tab            PA_FORECAST_GLOB.NumberTabTyp;
             rcvr_acct_curr_code_tab         PA_FORECAST_GLOB.VC15TabTyp;
             rcvr_acct_amount_tab            PA_FORECAST_GLOB.NumberTabTyp;
             proj_currency_code_tab          PA_FORECAST_GLOB.VC15TabTyp;
             proj_amount_tab                 PA_FORECAST_GLOB.NumberTabTyp;
             denom_currency_code_tab         PA_FORECAST_GLOB.VC15TabTyp;
             denom_amount_tab                PA_FORECAST_GLOB.NumberTabTyp;
             tp_amount_type_tab              PA_FORECAST_GLOB.VCTabTyp;
             billable_flag_tab               PA_FORECAST_GLOB.VC1TabTyp;
             forecast_summarized_code_tab    PA_FORECAST_GLOB.VCTabTyp;
             util_summarized_code_tab        PA_FORECAST_GLOB.VCTabTyp;
             work_type_id_tab                PA_FORECAST_GLOB.NumberTabTyp;
             resource_util_category_id_tab   PA_FORECAST_GLOB.NumberTabTyp;
             org_util_category_id_tab        PA_FORECAST_GLOB.NumberTabTyp;
             resource_util_weighted_tab      PA_FORECAST_GLOB.NumberTabTyp;
             org_util_weighted_tab           PA_FORECAST_GLOB.NumberTabTyp;
             provisional_flag_tab            PA_FORECAST_GLOB.VC1TabTyp;
             reversed_flag_tab               PA_FORECAST_GLOB.VC1TabTyp;
             net_zero_flag_tab               PA_FORECAST_GLOB.VC1TabTyp;
             reduce_capacity_flag_tab        PA_FORECAST_GLOB.VC1TabTyp;
             line_num_reversed_tab           PA_FORECAST_GLOB.NumberTabTyp;

             TmpRevTab                       PA_FORECAST_GLOB.FIDtlTabTyp;
             TmpUpdTab                       PA_FORECAST_GLOB.FIDtlTabTyp;
             l_rev_index                     NUMBER;
             lv_return_status                VARCHAR2(30);

       BEGIN

             lv_return_status := FND_API.G_RET_STS_SUCCESS;

             Print_message( 'Entering Delete_FI_Dtl');

             PA_DEBUG.Init_err_stack( 'PA_FORECASTITEM_PVT.Delete_FI_Dtl');

             TmpRevTab.Delete;
             TmpUpdTab.Delete;
             forecast_item_id_tab.delete;
             amount_type_id_tab.delete;
             line_num_tab.delete;
             resource_type_code_tab.delete;
             person_billable_flag_tab.delete;
             item_date_tab.delete;
             item_UOM_tab.delete;
             item_quantity_tab.delete;
             expenditure_org_id_tab.delete;
             project_org_id_tab.delete;
             PJI_SUMMARIZED_FLAG_tab.delete;
             CAPACITY_QUANTITY_tab.delete;
             OVERCOMMITMENT_QTY_tab.delete;
             OVERPROVISIONAL_QTY_tab.delete;
             OVER_PROV_CONF_QTY_tab.delete;
             CONFIRMED_QTY_tab.delete;
             PROVISIONAL_QTY_tab.delete;
             JOB_ID_tab.delete;
             PROJECT_ID_tab.delete;
             RESOURCE_ID_tab.delete;
             EXP_ORGANIZATION_ID_tab.delete;
             pvdr_acct_curr_code_tab.delete;
             pvdr_acct_amount_tab.delete;
             rcvr_acct_curr_code_tab.delete;
             rcvr_acct_amount_tab.delete;
             proj_currency_code_tab.delete;
             proj_amount_tab.delete;
             denom_currency_code_tab.delete;
             denom_amount_tab.delete;
             tp_amount_type_tab.delete;
             billable_flag_tab.delete;
             forecast_summarized_code_tab.delete;
             util_summarized_code_tab.delete;
             work_type_id_tab.delete;
             resource_util_category_id_tab.delete;
             org_util_category_id_tab.delete;
             resource_util_weighted_tab.delete;
             org_util_weighted_tab.delete;
             provisional_flag_tab.delete;
             reversed_flag_tab.delete;
             net_zero_flag_tab.delete;
             reduce_capacity_flag_tab.delete;
             line_num_reversed_tab.delete;

             SELECT dtl.forecast_item_id, dtl.amount_type_id,
                    dtl.line_num, dtl.resource_type_code,
                    dtl.person_billable_flag, dtl.item_UOM, dtl.item_date,
                    dtl.PJI_SUMMARIZED_FLAG,
                    dtl.CAPACITY_QUANTITY,
                    dtl.OVERCOMMITMENT_QTY,
                    dtl.OVERPROVISIONAL_QTY,
                    dtl.OVER_PROV_CONF_QTY,
                    dtl.CONFIRMED_QTY,
                    dtl.PROVISIONAL_QTY,
                    dtl.JOB_ID,
                    dtl.PROJECT_ID,
                    dtl.RESOURCE_ID,
                    dtl.EXPENDITURE_ORGANIZATION_ID,
                    dtl.item_quantity, dtl.expenditure_org_id,
                    dtl.project_org_id, dtl.pvdr_acct_curr_code,
                    dtl.pvdr_acct_amount, dtl.rcvr_acct_curr_code,
                    dtl.rcvr_acct_amount, dtl.proj_currency_code,
                    dtl.proj_amount, dtl.denom_currency_code, dtl.denom_amount,
                    dtl.tp_amount_type, dtl.billable_flag,
                    dtl.forecast_summarized_code, dtl.util_summarized_code,
                    dtl.work_type_id, dtl.resource_util_category_id,
                    dtl.org_util_category_id, dtl.resource_util_weighted,
                    dtl.org_util_weighted, dtl.provisional_flag,
                    dtl.reversed_flag, dtl.net_zero_flag,
                    dtl.reduce_capacity_flag, dtl.line_num_reversed
             BULK COLLECT INTO forecast_item_id_tab,amount_type_id_tab,
                    line_num_tab, resource_type_code_tab,
                    person_billable_flag_tab, item_UOM_tab, item_date_tab,
                    PJI_SUMMARIZED_FLAG_tab,
                    CAPACITY_QUANTITY_tab,
                    OVERCOMMITMENT_QTY_tab,
                    OVERPROVISIONAL_QTY_tab,
                    OVER_PROV_CONF_QTY_tab,
                    CONFIRMED_QTY_tab,
                    PROVISIONAL_QTY_tab,
                    JOB_ID_tab,
                    PROJECT_ID_tab,
                    RESOURCE_ID_tab,
                    EXP_ORGANIZATION_ID_tab,
                    item_quantity_tab, expenditure_org_id_tab,
                    project_org_id_tab, pvdr_acct_curr_code_tab,
                    pvdr_acct_amount_tab, rcvr_acct_curr_code_tab,
                    rcvr_acct_amount_tab, proj_currency_code_tab,
                    proj_amount_tab, denom_currency_code_tab, denom_amount_tab,
                    tp_amount_type_tab, billable_flag_tab,
                    forecast_summarized_code_tab, util_summarized_code_tab,
                    work_type_id_tab, resource_util_category_id_tab,
                    org_util_category_id_tab, resource_util_weighted_tab,
                    org_util_weighted_tab, provisional_flag_tab,
                    reversed_flag_tab, net_zero_flag_tab,
                    reduce_capacity_flag_tab, line_num_reversed_tab
             FROM   pa_forecast_item_details dtl, pa_forecast_items hdr
             WHERE  hdr.resource_id = p_resource_id
             AND    hdr.delete_flag = 'N'
             AND    hdr.forecast_item_type = 'U'
             AND    dtl.forecast_item_id = hdr.forecast_item_id
             AND    dtl.line_num =
                      (SELECT max(line_num)
                       FROM pa_forecast_item_details dtl1
                       WHERE dtl1.forecast_item_id = hdr.forecast_item_id AND trunc(dtl1.item_date) = trunc(hdr.item_date) ) -- 4918687 SQL ID 14905571
	     AND    trunc(dtl.item_date) = trunc(hdr.item_date) -- 4918687 SQL ID 14905571
             order by dtl.item_date, dtl.forecast_item_id ;

             IF forecast_item_id_tab.count = 0 THEN

                Print_message( 'Leaving Delete_FI_Dtl');

                x_return_status := lv_return_status;

                RETURN;

             END IF;

             TmpRevTab.Delete;
             TmpUpdTab.Delete;

             -- Move to one table FROM multiple tables

             FOR j IN forecast_item_id_tab.FIRST..forecast_item_id_tab.LAST LOOP

                 TmpUpdTab(j).forecast_item_id := forecast_item_id_tab(j);
                 TmpUpdTab(j).amount_type_id :=amount_type_id_tab(j);
                 TmpUpdTab(j).line_num := line_num_tab(j);
                 TmpUpdTab(j).resource_type_code := resource_type_code_tab(j);
                 TmpUpdTab(j).person_billable_flag :=
                                 person_billable_flag_tab(j);
                 TmpUpdTab(j).item_Uom := item_UOM_tab(j);
                 TmpUpdTab(j).item_date := item_date_tab(j);
                 TmpUpdTab(j).item_quantity := item_quantity_tab(j);
                 TmpUpdTab(j).expenditure_org_id := expenditure_org_id_tab(j);
                 TmpUpdTab(j).project_org_id := project_org_id_tab(j);
                 TmpUpdTab(j).pvdr_acct_curr_code := pvdr_acct_curr_code_tab(j);
                 TmpUpdTab(j).PJI_SUMMARIZED_FLAG := PJI_SUMMARIZED_FLAG_tab(j);
                 TmpUpdTab(j).CAPACITY_QUANTITY := CAPACITY_QUANTITY_tab(j);
                 TmpUpdTab(j).OVERCOMMITMENT_QTY := OVERCOMMITMENT_QTY_tab(j);
                 TmpUpdTab(j).OVERPROVISIONAL_QTY := OVERPROVISIONAL_QTY_tab(j);
                 TmpUpdTab(j).OVER_PROV_CONF_QTY := OVER_PROV_CONF_QTY_tab(j);
                 TmpUpdTab(j).CONFIRMED_QTY := CONFIRMED_QTY_tab(j);
                 TmpUpdTab(j).PROVISIONAL_QTY := PROVISIONAL_QTY_tab(j);
                 TmpUpdTab(j).JOB_ID := JOB_ID_tab(j);
                 TmpUpdTab(j).PROJECT_ID := PROJECT_ID_tab(j);
                 TmpUpdTab(j).RESOURCE_ID := RESOURCE_ID_tab(j);
                 TmpUpdTab(j).EXPENDITURE_ORGANIZATION_ID := EXP_ORGANIZATION_ID_tab(j);
                 TmpUpdTab(j).pvdr_acct_amount := pvdr_acct_amount_tab(j);
                 TmpUpdTab(j).rcvr_acct_curr_code :=
                                 rcvr_acct_curr_code_tab(j);
                 TmpUpdTab(j).rcvr_acct_amount := rcvr_acct_amount_tab(j);
                 TmpUpdTab(j).proj_currency_code := proj_currency_code_tab(j);
                 TmpUpdTab(j).proj_amount := proj_amount_tab(j);
                 TmpUpdTab(j).denom_currency_code := denom_currency_code_tab(j);
                 TmpUpdTab(j).denom_amount := denom_amount_tab(j);
                 TmpUpdTab(j).tp_amount_type := tp_amount_type_tab(j);
                 TmpUpdTab(j).billable_flag := billable_flag_tab(j);
                 TmpUpdTab(j).forecast_summarized_code :=
                                 forecast_summarized_code_tab(j);
                 TmpUpdTab(j).util_summarized_code :=
                                 util_summarized_code_tab(j);
                 TmpUpdTab(j).work_type_id := work_type_id_tab(j);
                 TmpUpdTab(j).resource_util_category_id :=
                                 resource_util_category_id_tab(j);
                 TmpUpdTab(j).org_util_category_id :=
                                 org_util_category_id_tab(j);
                 TmpUpdTab(j).resource_util_weighted :=
                                 resource_util_weighted_tab(j);
                 TmpUpdTab(j).org_util_weighted :=
                                 org_util_weighted_tab(j);
                 TmpUpdTab(j).provisional_flag := provisional_flag_tab(j);
                 TmpUpdTab(j).reversed_flag := 'Y';
                 TmpUpdTab(j).net_zero_flag := net_zero_flag_tab(j);
                 TmpUpdTab(j).reduce_capacity_flag :=
                                   reduce_capacity_flag_tab(j);
                 TmpUpdTab(j).line_num_reversed := line_num_reversed_tab(j);

             END LOOP;

             l_rev_index := 1;

             if (TmpUpdTab.count <> 0) then
             FOR j IN TmpUpdTab.FIRST..TmpUpdTab.LAST LOOP
                 IF TmpUpdTab.exists(j) then

                 IF (NVL(TmpUpdTab(j).forecast_summarized_code,'Y') = 'Y'
                        OR NVL(TmpUpdTab(j).PJI_SUMMARIZED_FLAG,'Y') = 'Y'
                        OR  NVL(TmpUpdTab(j).util_summarized_code,'Y') = 'Y')
                        AND (
                             NVL(TmpUpdTab(j).CAPACITY_QUANTITY,0) > 0 OR
                             NVL(TmpUpdTab(j).OVERCOMMITMENT_QTY,0) > 0 OR
                             NVL(TmpUpdTab(j).OVERPROVISIONAL_QTY,0) > 0 OR
                             NVL(TmpUpdTab(j).OVER_PROV_CONF_QTY,0) > 0 OR
                             NVL(TmpUpdTab(j).CONFIRMED_QTY,0) > 0 OR
                             NVL(TmpUpdTab(j).PROVISIONAL_QTY,0) > 0 OR
                             TmpUpdTab(j).item_quantity > 0
                             ) THEN

                    TmpRevTab(l_rev_index) := TmpUpdTab(j);
                    IF (NVL(TmpUpdTab(j).CAPACITY_QUANTITY,0) = 0) THEN
                       TmpRevTab(l_rev_index).CAPACITY_QUANTITY := NULL;
                    ELSE
                       TmpRevTab(l_rev_index).CAPACITY_QUANTITY :=
                          NVL(TmpUpdTab(j).CAPACITY_QUANTITY,0) * -1;
                    END IF;
                    IF (NVL(TmpUpdTab(j).OVERCOMMITMENT_QTY,0) = 0) THEN
                       TmpRevTab(l_rev_index).OVERCOMMITMENT_QTY := NULL;
                    ELSE
                       TmpRevTab(l_rev_index).OVERCOMMITMENT_QTY :=
                          NVL(TmpUpdTab(j).OVERCOMMITMENT_QTY,0) * -1;
                    END IF;
                    IF (NVL(TmpUpdTab(j).OVERPROVISIONAL_QTY,0) = 0) THEN
                       TmpRevTab(l_rev_index).OVERPROVISIONAL_QTY := NULL;
                    ELSE
                       TmpRevTab(l_rev_index).OVERPROVISIONAL_QTY :=
                          NVL(TmpUpdTab(j).OVERPROVISIONAL_QTY,0) * -1;
                    END IF;
                    IF (NVL(TmpUpdTab(j).OVER_PROV_CONF_QTY,0) = 0) THEN
                       TmpRevTab(l_rev_index).OVER_PROV_CONF_QTY := NULL;
                    ELSE
                       TmpRevTab(l_rev_index).OVER_PROV_CONF_QTY :=
                          NVL(TmpUpdTab(j).OVER_PROV_CONF_QTY,0) * -1;
                    END IF;
                    IF (NVL(TmpUpdTab(j).CONFIRMED_QTY,0) = 0) THEN
                       TmpRevTab(l_rev_index).CONFIRMED_QTY := NULL;
                    ELSE
                       TmpRevTab(l_rev_index).CONFIRMED_QTY :=
                          NVL(TmpUpdTab(j).CONFIRMED_QTY,0) * -1;
                    END IF;
                    IF (NVL(TmpUpdTab(j).PROVISIONAL_QTY,0) = 0) THEN
                       TmpRevTab(l_rev_index).PROVISIONAL_QTY := NULL;
                    ELSE
                       TmpRevTab(l_rev_index).PROVISIONAL_QTY :=
                          NVL(TmpUpdTab(j).PROVISIONAL_QTY,0) * -1;
                    END IF;
                    TmpRevTab(l_rev_index).item_quantity :=
                                  TmpUpdTab(j).item_quantity * -1;
                    TmpRevTab(l_rev_index).resource_util_weighted :=
                                  TmpUpdTab(j).resource_util_weighted * -1;
                    TmpRevTab(l_rev_index).org_util_weighted :=
                                  TmpUpdTab(j).org_util_weighted * -1;

                    IF NVL(TmpUpdTab(j).forecast_summarized_code,'Y') = 'Y' THEN

                       TmpRevTab(l_rev_index).forecast_summarized_code := 'N';

                    ELSE

                       TmpRevTab(l_rev_index).forecast_summarized_code :=
                               TmpUpdTab(j).forecast_summarized_code;

                    END IF;

                    IF NVL(TmpUpdTab(j).PJI_SUMMARIZED_FLAG,'Y') = 'Y' THEN
                      TmpRevTab(l_rev_index).PJI_SUMMARIZED_FLAG := 'N';
                    ELSE
                      TmpRevTab(l_rev_index).PJI_SUMMARIZED_FLAG :=
                              TmpUpdTab(j).PJI_SUMMARIZED_FLAG;
                    END IF;

                    IF NVL(TmpUpdTab(j).util_summarized_code,'Y') = 'Y' THEN

                       TmpRevTab(l_rev_index).util_summarized_code := 'N';

                    ELSE

                       TmpRevTab(l_rev_index).util_summarized_code :=
                               TmpUpdTab(j).util_summarized_code;

                    END IF;

                    TmpRevTab(l_rev_index).line_num_reversed :=
                                  TmpUpdTab(j).line_num;  -- Added for bug 4244913
				 -- TmpRevTab(j).line_num;   Commented for bug 4244913
                    TmpRevTab(l_rev_index).line_num :=
                                  TmpUpdTab(j).line_num + 1; -- Added for bug 4244913
				 -- TmpRevTab(j).line_num + 1;  Commented for bug 4244913
                    TmpRevTab(l_rev_index).net_zero_flag := 'Y';
                    l_rev_index := l_rev_index + 1;

                    TmpUpdTab(j).net_zero_flag := 'Y';
                    TmpUpdTab(j).reversed_flag := 'Y';

                 ELSE

                    TmpUpdTab(j).CAPACITY_QUANTITY := NULL;
                    TmpUpdTab(j).OVERCOMMITMENT_QTY := NULL;
                    TmpUpdTab(j).OVERPROVISIONAL_QTY := NULL;
                    TmpUpdTab(j).OVER_PROV_CONF_QTY := NULL;
                    TmpUpdTab(j).CONFIRMED_QTY := NULL;
                    TmpUpdTab(j).PROVISIONAL_QTY := NULL;
                    TmpUpdTab(j).item_quantity := 0;
                    TmpUpdTab(j).org_util_weighted :=0;
                    TmpUpdTab(j).resource_util_weighted :=0;

                 END IF;
                 END IF;
             END LOOP;
             END IF;

             IF TmpRevTab.COUNT > 0 THEN

                Print_message(
                           'Calling PA_FORECAST_DTLS_PKG.Insert_Rows ');

                PA_FORECAST_DTLS_PKG.Insert_Rows(TmpRevTab,
                                                lv_return_status,
                                                x_msg_count,
                                                x_msg_data);

             END IF;

             IF lv_return_status = FND_API.G_RET_STS_SUCCESS THEN

                IF TmpUpdTab.COUNT > 0 THEN

                   Print_message(
                           'Calling PA_FORECAST_DTLS_PKG.Update_Rows ');

                   PA_FORECAST_DTLS_PKG.Update_Rows(TmpUpdTab,
                                                lv_return_status,
                                                x_msg_count,
                                                x_msg_data);
                END IF;

             END IF;


             Print_message( 'Leaving Delete_FI_Dtl');

             PA_DEBUG.Reset_Err_Stack;

             x_return_status := lv_return_status;

       EXCEPTION

             WHEN NO_DATA_FOUND THEN

                  x_return_status := lv_return_status;

                  NULL;

             WHEN OTHERS THEN
                  print_message('Failed in Delete FI Dtl api');
                  print_message('SQLCODE'||sqlcode||sqlerrm);

                  x_msg_count     := 1;
                  x_msg_data      := sqlerrm;
                  x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

                  FND_MSG_PUB.add_exc_msg
                      (p_pkg_name   =>
                              'PA_FORECASTITEM_PVT.Delete_FI_Dtl',
                       p_procedure_name => PA_DEBUG.G_Err_Stack);

                  Print_message(x_msg_data);

                  --RAISE;

       END  Delete_FI_Dtl;


/* ---------------------------------------------------------------------
|   Procedure  :   Build_FI_Hdr_Asg
|   Purpose    :   To create new/modified forecast item (Assignment) record
|                  FOR the item DATEs that are built IN the p_FIDayTab
|   Parameters :   p_AsgnDtlRec - Assignment details
|                  p_DBHdrTab   - Holds forecast item records which are
|                                 already existing
|                  p_FIDayTab   - Holds all item_dates,item_quantity,
|                                 status_code FOR the current run.
|                   i) action_flag component of this tab will be updated
|                      to indicate the following
|                      a) N  : New record - item_date does not exist
|                      b) DN : Delete AND create new -
|                                item DATE exists but expenditure OU/
|                                expenditure organization/expenditure type/
|                                expenditure type class/ borrowed flag has
|                                changed.
|                                Existing record is reversed(deleted) AND new
|                                record is created
|                      c) RN : Reverse AND create new -
|                              Quantity has changed.
|                              IN header : quantity is updated.
|                              IN detail :
|                                IF summarized existing line should be reversed
|                                   AND new line created
|                                IF not summarized existing line should be
|                                   updated to reflect new quantity
|                      d) C :  No change IN header
|                              Check FOR any changes IN detail record for
|                              person_billable_flag, provisional_flag,
|                              work_type OR resource_type
|                   ii) forecast_item_id component of this tab will be updated
|                       to hold the forecast_item_id FOR new record. Same will
|                       be used FOR detail record
|                  iii) project_org_id,expenditure_org_id,work_type_id,
|                       person_billable_flag, tp_amount_type : These values
|                       are required FOR detail record processing. These are
|                       also updated IN this tab.
|
|                  x_FIHdrInsTab - Will RETURN all forecast item records that
|                                  are new
|                  x_FIHdrUpdTab - Will RETURN all forecast item records that
|                                  are modified
|                  x_return_status     -
|                  x_msg_count         -
|                  x_msg_data          -
+----------------------------------------------------------------------*/
       PROCEDURE  Build_FI_Hdr_Asg(
                  p_AsgnDtlRec    IN     PA_FORECAST_GLOB.AsgnDtlRecord,
                  p_DBHdrTab      IN     PA_FORECAST_GLOB.FIHdrTabTyp,
                  p_FIDayTab      IN OUT NOCOPY PA_FORECAST_GLOB.FIDayTabTyp, /* 2674619 - Nocopy change */
                  x_FIHdrInsTab   OUT    NOCOPY PA_FORECAST_GLOB.FIHdrTabTyp, /* 2674619 - Nocopy change */
                  x_FIHdrUpdTab   OUT    NOCOPY PA_FORECAST_GLOB.FIHdrTabTyp, /* 2674619 - Nocopy change */
                  x_return_status OUT    NOCOPY VARCHAR2, -- 4537865
                  x_msg_count     OUT    NOCOPY NUMBER, -- 4537865
                  x_msg_data      OUT    NOCOPY VARCHAR2) IS -- 4537865

	           l_msg_index_out	            NUMBER;
		   l_data varchar2(2000) ; -- 4537865
             lv_include_admin_proj_flag      VARCHAR2(5);
             lv_util_cal_method              VARCHAR2(30);
             lv_bill_unasg_proj_id           NUMBER;
             lv_bill_unasg_exp_type_class    VARCHAR2(30);
             lv_bill_unasg_exp_type          VARCHAR2(30);
             lv_nbill_unasg_proj_id          NUMBER;
             lv_nbill_unasg_exp_type_class   VARCHAR2(30);
             lv_nbill_unasg_exp_type         VARCHAR2(30);
             lv_default_tp_amount_type       VARCHAR2(30);


             lv_forecast_item_type           VARCHAR2(1);
             lv_project_id                   NUMBER;
             lv_person_id                    NUMBER;
             lv_project_org_id               NUMBER;
             lv_project_orgn_id              NUMBER;
             lv_project_type_class           VARCHAR2(30);
             lv_project_status_code          VARCHAR2(30);
             lv_pvdr_period_set_name         VARCHAR2(30):= NULL;
             lv_rcvr_period_set_name         VARCHAR2(30):= NULL;
             lv_pvdr_pa_period_name          VARCHAR2(30):= NULL;

             ld_resou_startdate_tab          PA_FORECAST_GLOB.DateTabTyp;
             ld_resou_enddate_tab            PA_FORECAST_GLOB.DateTabTyp;
             l_resou_tab                     PA_FORECAST_GLOB.NumberTabTyp;
             lv_res_index                    NUMBER;
             lv_resou                        NUMBER;

             ld_pvdrpa_startdate_tab         PA_FORECAST_GLOB.DateTabTyp;
             ld_pvdrpa_enddate_tab           PA_FORECAST_GLOB.DateTabTyp;
             lv_pvdrpa_name_tab              PA_FORECAST_GLOB.periodnametabtyp;
             lv_pvpa_index                   NUMBER ;
             lv_pvdrpa_name                  VARCHAR2(30);

             ld_pvdrgl_startdate_tab         PA_FORECAST_GLOB.DateTabTyp;
             ld_pvdrgl_enddate_tab           PA_FORECAST_GLOB.DateTabTyp;
             lv_pvdrgl_name_tab              PA_FORECAST_GLOB.periodnametabtyp;
             lv_pvgl_index                   NUMBER ;
             lv_pvdrgl_name                  VARCHAR2(30);

             ld_rcvrpa_startdate_tab         PA_FORECAST_GLOB.DateTabTyp;
             ld_rcvrpa_enddate_tab           PA_FORECAST_GLOB.DateTabTyp;
             lv_rcvrpa_name_tab              PA_FORECAST_GLOB.periodnametabtyp;
             lv_rcpa_index                   NUMBER ;
             lv_rcvrpa_name                  VARCHAR2(30);

             ld_rcvrgl_startdate_tab         PA_FORECAST_GLOB.DateTabTyp;
             ld_rcvrgl_enddate_tab           PA_FORECAST_GLOB.DateTabTyp;
             lv_rcvrgl_name_tab              PA_FORECAST_GLOB.periodnametabtyp;
             lv_rcgl_index                   NUMBER ;
             lv_rcvrgl_name                  VARCHAR2(30);

             ld_orgn_startdate_tab           PA_FORECAST_GLOB.DateTabTyp;
             ld_orgn_enddate_tab             PA_FORECAST_GLOB.DateTabTyp;
             l_orgn_tab                      PA_FORECAST_GLOB.NumberTabTyp;
             l_jobid_tab                     PA_FORECAST_GLOB.NumberTabTyp;
             lv_orgn_index                   NUMBER ;
             lv_resorgn                      NUMBER;

             lv_WeekDateRange_Tab     PA_FORECAST_GLOB.WeekDatesRangeFcTabTyp;
             lv_wk_index              NUMBER;

             lv_borrowed_flag                VARCHAR2(1) := 'N';
             lv_action_code                  VARCHAR2(30);
             lv_include_in_forecast          VARCHAR2(1) := 'N';
             lv_person_bill_flag             VARCHAR2(1);
             lv_forecast_item_id             NUMBER;
             lv_work_type_id                 NUMBER;
             --lv_exp_type                     VARCHAR2(30);
             --lv_exp_type_class               VARCHAR2(30);
             lv_error_flag                   VARCHAR2(1);
             lv_resource_id                  NUMBER;
             lv_rejection_code               VARCHAR2(30);
             lv_prev_index                   NUMBER;

             lv_ou_error                      VARCHAR2(1);
             lv_orgn_error                    VARCHAR2(1);

             TmpDayTab                       PA_FORECAST_GLOB.FIDayTabTyp;
             TmpInsTab                       PA_FORECAST_GLOB.FIHdrTabTyp;
             i_in                            NUMBER := 1;
             TmpUpdTab                       PA_FORECAST_GLOB.FIHdrTabTyp;
             u_in                            NUMBER := 1;
             d_in                            NUMBER := 1;
             TmpHdrRec                       PA_FORECAST_GLOB.FIHdrRecord;

             lv_err_msg                      VARCHAR2(30);
             lv_return_status                VARCHAR2(30);
             lv_call_pos                     VARCHAR2(50);
             tmp_person_id                   NUMBER;
             tmp_status_code                 VARCHAR2(30);
             lv_start_date                   DATE;
             lv_end_date                     DATE;

       BEGIN

             lv_return_status := FND_API.G_RET_STS_SUCCESS;

             Print_message('Entering Build_FI_Hdr_Asg: ' || p_AsgnDtlRec.resource_id || ' ' || p_AsgnDtlRec.assignment_id);

             PA_DEBUG.Init_err_stack(
                       'PA_FORECASTITEM_PVT.Build_FI_Hdr_Asg');

             TmpDayTab.Delete;
             TmpInsTab.Delete;
             TmpUpdTab.Delete;
             ld_resou_startdate_tab.Delete;
             ld_resou_enddate_tab.Delete;
             l_resou_tab.Delete;
             ld_pvdrpa_startdate_tab.Delete;
             ld_pvdrpa_enddate_tab.Delete;
             lv_pvdrpa_name_tab.Delete;
             ld_pvdrgl_startdate_tab.Delete;
             ld_pvdrgl_enddate_tab.Delete;
             lv_pvdrgl_name_tab.Delete;
             ld_rcvrpa_startdate_tab.Delete;
             ld_rcvrpa_enddate_tab.Delete;
             lv_rcvrpa_name_tab.Delete;
             ld_rcvrgl_startdate_tab.Delete;
             ld_rcvrgl_enddate_tab.Delete;
             lv_rcvrgl_name_tab.Delete;
             ld_orgn_startdate_tab.Delete;
             ld_orgn_enddate_tab.Delete;
             l_orgn_tab.Delete;
             l_jobid_tab.Delete;
             lv_WeekDateRange_Tab.Delete;

             TmpDayTab := p_FIDayTab;


             Print_message( 'Asg - Get_resource_ou');

             PA_FORECAST_ITEMS_UTILS.get_resource_ou(
                            p_AsgnDtlRec.resource_id,
                            p_AsgnDtlRec.start_date,
                            p_AsgnDtlRec.end_date,
                            ld_resou_startdate_tab,ld_resou_enddate_tab,
                            l_resou_tab);

             lv_res_index := l_resou_tab.FIRST;

             IF l_resou_tab.count > 0 THEN

                lv_resou := l_resou_tab(lv_res_index);

             ELSE

                lv_err_msg := 'ResOU_Not_Found';
                RAISE NO_DATA_FOUND;

             END IF;


             Print_message( 'Asg - Get_person_id');

             lv_person_id := PA_FORECAST_ITEMS_UTILS.get_person_id(
                                    p_AsgnDtlRec.resource_id);

             Print_message('Asg - Get_res_org_and_job');

             PA_FORECAST_ITEMS_UTILS.get_res_org_and_job(
                            lv_person_id, p_AsgnDtlRec.start_date,
                            p_AsgnDtlRec.end_date,
                            ld_orgn_startdate_tab, ld_orgn_enddate_tab,
                            l_orgn_tab, l_jobid_tab);

             lv_orgn_index := l_orgn_tab.FIRST;

             IF l_orgn_tab.count > 0 THEN

                lv_resorgn := l_orgn_tab(lv_orgn_index);

             ELSE

                lv_err_msg := 'Resorgn_Not_Found';
                RAISE NO_DATA_FOUND;

             END IF;

             Print_message('Calling Get_Project_Dtls');

             Get_Project_Dtls (p_AsgnDtlRec.project_id, lv_project_org_id,
                               lv_project_orgn_id, lv_work_type_id,
                               lv_project_type_class, lv_project_status_code,
                               lv_return_status, x_msg_count, x_msg_data);

             IF lv_return_status <> FND_API.G_RET_STS_SUCCESS THEN

                lv_err_msg := 'No_Project_Record - Asg';
                RAISE NO_DATA_FOUND;

             END IF;

             Print_message('Asg - Get_period_set_name (rcvr)');
             Print_message('lv_project_org_id: ' || lv_project_org_id);
             lv_rcvr_period_set_name :=
                    PA_FORECAST_ITEMS_UTILS.get_period_set_name (
                                   lv_project_org_id);

             if lv_rcvr_period_set_name = 'NO_DATA_FOUND' THEN

                lv_rcvr_period_set_name := '-99';
                lv_rejection_code := 'RCVR_PRD_SET_NAME_NOT_FOUND';
                lv_error_flag := 'Y';

             end if;


             Print_message(
                                  'Asg - Get_pa_period_name (rcvr)');

             Print_message('lv_project_org_id: ' || lv_project_org_id);
             PA_FORECAST_ITEMS_UTILS.get_pa_period_name(
                                       lv_project_org_id,
                                       p_AsgnDtlRec.start_date,
                                       p_AsgnDtlRec.end_date,
                                       ld_rcvrpa_startdate_tab,
                                       ld_rcvrpa_enddate_tab,
                                       lv_rcvrpa_name_tab);

             lv_rcpa_index := lv_rcvrpa_name_tab.FIRST;


             Print_message(
                                  'Asg - Get_gl_period_name (rcvr)');

             Print_message('lv_project_org_id: ' || lv_project_org_id);
             PA_FORECAST_ITEMS_UTILS.get_gl_period_name(
                                       lv_project_org_id,
                                       p_AsgnDtlRec.start_date,
                                       p_AsgnDtlRec.end_date,
                                       ld_rcvrgl_startdate_tab,
                                       ld_rcvrgl_enddate_tab,
                                       lv_rcvrgl_name_tab);

             lv_rcgl_index := lv_rcvrgl_name_tab.FIRST;

             Print_message(
                                  'Asg - Get_week_dates_range_fc ');

             PA_FORECAST_ITEMS_UTILS.get_Week_Dates_Range_Fc(
                                      p_AsgnDtlRec.start_date,
                                      p_AsgnDtlRec.end_date,
                                      lv_WeekDateRange_Tab,
                                      x_return_status,
                                      x_msg_count,
                                      x_msg_data);


             lv_wk_index := lv_WeekDateRange_Tab.FIRST;

             lv_call_pos := 'Asg : bef_for';

             if (TmpDaytab.count <> 0) then
             FOR i IN TmpDaytab.FIRST..TmpDaytab.LAST LOOP
                 if TmpDaytab.exists(i) then
                 lv_call_pos := 'Asg : chk per bill';
                 lv_ou_error := 'N';

                 lv_action_code := 'STAFFED_ASGMT_PROJ_FORECASTING';

/* Bug No:1967832. Added conditions before calling check_prj_stus_action allowed */
                 IF TmpDayTab(i).status_code=tmp_status_code
                 AND i>TmpDaytab.FIRST THEN

                    lv_include_in_forecast := lv_include_in_forecast;

                 ELSE

                 lv_include_in_forecast :=
                      pa_project_utils.check_prj_stus_action_allowed(
                                   TmpDayTab(i).status_code,
                                   lv_action_code);

                    tmp_status_code := TmpDayTab(i).status_code;

                 END IF;

                 TmpDayTab(i).include_in_forecast := lv_include_in_forecast;

/* Bug1967832 Remvoed the original call to check_person_billable function and added the conditions below.*/

                IF TRUNC(TmpDayTab(i).item_date) BETWEEN TRUNC(lv_start_date) and TRUNC(nvl(lv_end_date,TmpDayTab(i).item_date))
                  AND lv_person_id=tmp_person_id
                  AND i>TmpDaytab.FIRST  THEN

                      lv_person_bill_flag := lv_person_bill_flag;

                 ELSE

                    Check_Person_Billable(p_person_id			=> lv_person_id,
																					p_item_date			=> TmpDayTab(i).item_date,
																					x_start_date		=> lv_start_date,
                                          x_end_date			=> lv_end_date,
																					x_billable_flag	=> lv_person_bill_flag,
                                          x_return_status => lv_return_status,
                                          x_msg_count     => x_msg_count,
                                          x_msg_data      => x_msg_data);

                    tmp_person_id := lv_person_id;
                 END IF;


                 lv_error_flag := 'N';
                 lv_rejection_code := NULL;
/*
                 TmpDayTab(i).provisional_flag :=
                     PA_ASSIGNMENT_UTILS.Is_Provisional_Status(
                                         TmpDayTab(i).status_code,
                                         p_AsgnDtlRec.assignment_type);
*/
                 lv_error_flag := 'N';

                 lv_call_pos := 'Asg : resou ';
                 IF (ld_resou_startdate_tab.count = 0) THEN

                           lv_err_msg := 'ResOU_Not_Found';
                           RAISE NO_DATA_FOUND;


                 ELSIF ((lv_pvdr_period_set_name IS NULL) OR
                        (trunc(TmpDayTab(i).item_date) NOT BETWEEN
                          trunc(ld_resou_startdate_tab(lv_res_index)) AND
                          trunc(ld_resou_enddate_tab(lv_res_index)))) THEN

                    lv_prev_index := lv_res_index;

                    LOOP

                        IF lv_res_index > ld_resou_startdate_tab.COUNT THEN

                       --  lv_error_flag := 'Y';
                       --  lv_rejection_code := 'Resource_ou_not_found';
                           lv_err_msg := 'ResOU_Not_Found';
                           RAISE NO_DATA_FOUND;


                        END IF;


                        EXIT WHEN lv_error_flag = 'Y' OR
                              (trunc(TmpDayTab(i).item_date) >=
                                 trunc(ld_resou_startdate_tab(lv_res_index)) AND
                              trunc(TmpDayTab(i).item_date) <=
                              trunc(ld_resou_enddate_tab(lv_res_index)));

                        lv_res_index := lv_res_index + 1;

                    END LOOP;

                    IF lv_error_flag = 'Y' THEN

                       lv_res_index := lv_prev_index;
                       lv_ou_error := 'Y';
                       lv_resou := -99;
                       lv_pvdr_period_set_name := '-99';
                       lv_project_id              := -99;
                       lv_rcvr_period_set_name    := '-99';
                       lv_pvdrpa_name             := '-99';
                       lv_pvdrgl_name             := '-99';
                       lv_rcvrpa_name             := '-99';
                       lv_rcvrgl_name             := '-99';
                       --lv_exp_type                := '-99';
                       --lv_exp_type_class          := '-99';
/*
                       lv_project_org_id          := -99;
                       lv_project_orgn_id         := -99;
                       lv_work_type_id            := -99;
                       lv_project_type_class      := '-99';
*/


                    ELSE

                       lv_resou := l_resou_tab(lv_res_index);

                       Print_message(
                                  'Asg - Get_period_set_name (pvdr) ');

                       lv_pvdr_period_set_name :=
                            PA_FORECAST_ITEMS_UTILS.get_period_set_name(
                                         lv_resou);

                       if lv_pvdr_period_set_name = 'NO_DATA_FOUND' THEN
                          lv_pvdr_period_set_name := '-99';
                          lv_rejection_code := 'PVDR_PRD_SET_NAME_NOT_FOUND';
                          lv_error_flag := 'Y';

                       end if;


                    END IF;

                    IF lv_ou_error = 'N' then

                       Print_message(
                                  'Asg - Get_pa_period_name (pvdr)');

                       PA_FORECAST_ITEMS_UTILS.get_pa_period_name(
                                      lv_resou,
                                      p_AsgnDtlRec.start_date,
                                      p_AsgnDtlRec.end_date,
                                      ld_pvdrpa_startdate_tab,
                                      ld_pvdrpa_enddate_tab,
                                      lv_pvdrpa_name_tab);

                       lv_pvpa_index := lv_pvdrpa_name_tab.FIRST;

                       Print_message(
                                  'Asg - Get_gl_period_name (pvdr)');

                       PA_FORECAST_ITEMS_UTILS.get_gl_period_name(
                                      lv_resou,
                                      p_AsgnDtlRec.start_date,
                                      p_AsgnDtlRec.end_date,
                                      ld_pvdrgl_startdate_tab,
                                      ld_pvdrgl_enddate_tab,
                                      lv_pvdrgl_name_tab);

                       lv_pvgl_index := lv_pvdrgl_name_tab.FIRST;


                       Print_message(
                                  'Asg - Get_forecastoptions');

--                     dbms_output.put_line(l_resou_tab(lv_res_index));
                       PA_FORECAST_ITEMS_UTILS.get_forecastoptions(
                             lv_resou,
                        --     lv_include_admin_proj_flag, Bug 4576715
                             lv_util_cal_method,
                             lv_bill_unasg_proj_id,
                             lv_bill_unasg_exp_type_class,
                             lv_bill_unasg_exp_type,
                             lv_nbill_unasg_proj_id,
                             lv_nbill_unasg_exp_type_class,
                             lv_nbill_unasg_exp_type,
                             lv_default_tp_amount_type,
                             x_return_status, x_msg_count, x_msg_data);

                       IF lv_person_bill_flag = 'Y' THEN

                          lv_project_id     := lv_bill_unasg_proj_id;
                        --  lv_exp_type       := lv_bill_unasg_exp_type;
                        --  lv_exp_type_class := lv_bill_unasg_exp_type_class;

                       ELSE

                          lv_project_id     := lv_nbill_unasg_proj_id;
                        --  lv_exp_type       := lv_nbill_unasg_exp_type;
                        --  lv_exp_type_class :=
                        --                  lv_nbill_unasg_exp_type_class;

                       END IF;

                    END IF;

                 END IF;

                 lv_error_flag := 'N';

                 lv_call_pos := 'Asg : resorgn ';
                 IF (ld_orgn_enddate_tab.count = 0) THEN

                        lv_error_flag := 'Y';

                        IF (lv_rejection_code IS NULL) THEN

                           lv_err_msg := 'Resorgn_Not_Found';
                           RAISE NO_DATA_FOUND;

                        END IF;


                 ELSIF (trunc(TmpDayTab(i).item_date) NOT BETWEEN
                         trunc(ld_orgn_startdate_tab(lv_orgn_index)) AND
                         trunc(ld_orgn_enddate_tab(lv_orgn_index))) THEN

                    lv_prev_index := lv_orgn_index;

                    LOOP

                        IF lv_orgn_index > ld_orgn_startdate_tab.COUNT THEN

                           lv_error_flag := 'Y';


                           -- IF (lv_rejection_code IS NULL) THEN

                           --     lv_rejection_code := 'Exp orgn not found';

                            --END IF;

                           lv_err_msg := 'Resorgn_Not_Found';
                           RAISE NO_DATA_FOUND;

                        END IF;

                        EXIT WHEN lv_error_flag = 'Y'  OR
                               trunc(TmpDayTab(i).item_date) >=
                                trunc(ld_orgn_startdate_tab(lv_orgn_index)) AND
                               trunc(TmpDayTab(i).item_date) <=
                                trunc(ld_orgn_enddate_tab(lv_orgn_index));
                           lv_orgn_index := lv_orgn_index + 1;

                    END LOOP;

                 END IF;

                 IF lv_error_flag = 'Y' THEN

                       lv_orgn_index := lv_prev_index;
                       lv_resorgn := -99;
                       lv_orgn_error := 'Y';
                 ELSE

                       lv_resorgn := l_orgn_tab(lv_orgn_index);
                 END IF;


                 lv_call_pos := 'Asg : borr ';
                 IF ((lv_project_org_id <>lv_resou ) OR
                       (lv_project_orgn_id  <> lv_resorgn)) THEN

                    lv_borrowed_flag := 'Y';

                 ELSE

                       lv_borrowed_flag := 'N';

                 END IF;


                 IF d_in <=  p_DbHdrTab.COUNT THEN

                    lv_call_pos := 'Asg : in if 1 ';
                    IF trunc(TmpDayTab(i).item_date) <
                             trunc(p_DbHdrTab(d_in).item_date) THEN

                       lv_call_pos := 'Asg : in if 2 ';
                       IF (TmpDayTab(i).action_flag = 'D') OR
                            (
                             NVL(TmpDayTab(i).CAPACITY_QUANTITY,0) = 0 AND
                             NVL(TmpDayTab(i).OVERCOMMITMENT_QTY,0) = 0 AND
-- Start fix for bug 2504222 (changed for consistency, not vital for fix)
                             NVL(TmpDayTab(i).OVERCOMMITMENT_QUANTITY,0) = 0 AND
-- End fix for bug 2504222
                             NVL(TmpDayTab(i).OVERPROVISIONAL_QTY,0) = 0 AND
                             NVL(TmpDayTab(i).OVER_PROV_CONF_QTY,0) = 0 AND
                             NVL(TmpDayTab(i).CONFIRMED_QTY,0) = 0 AND
                             NVL(TmpDayTab(i).PROVISIONAL_QTY,0) = 0 AND
                             TmpDayTab(i).item_quantity = 0
                             ) THEN

                          TmpDayTab(i).action_flag := 'I';

                       ELSE

                          TmpDayTab(i).action_flag := 'N';

                       END IF;

                    ELSIF trunc(TmpDayTab(i).item_date) =
                          trunc(p_DbHdrTab(d_in).item_date) THEN

                       lv_call_pos := 'Asg : in else 2 ';
                       IF (TmpDayTab(i).action_flag = 'D') OR
                              (
                               NVL(TmpDayTab(i).CAPACITY_QUANTITY,0) = 0 AND
                               NVL(TmpDayTab(i).OVERCOMMITMENT_QTY,0) = 0 AND
-- Start fix for bug 2504222 (changed for consistency, not vital for fix)
                               NVL(TmpDayTab(i).OVERCOMMITMENT_QUANTITY,0) = 0 AND
-- End fix for bug 2504222
                               NVL(TmpDayTab(i).OVERPROVISIONAL_QTY,0) = 0 AND
                               NVL(TmpDayTab(i).OVER_PROV_CONF_QTY,0) = 0 AND
                               NVL(TmpDayTab(i).CONFIRMED_QTY,0) = 0 AND
                               NVL(TmpDayTab(i).PROVISIONAL_QTY,0) = 0 AND
                               TmpDayTab(i).item_quantity = 0
                               ) THEN

                          print_message('Asg : in if 3 ');
                          lv_call_pos := 'Asg : in if 3 ';
                          TmpDayTab(i).action_flag := 'D';
                          TmpUpdTab(u_in) := p_DbHdrTab(d_in);
                          TmpUpdTab(u_in).CAPACITY_QUANTITY := NULL;
                          TmpUpdTab(u_in).OVERCOMMITMENT_QTY := NULL;
-- Start fix for bug 2504222 (changed for consistency, not vital for fix)
                          TmpUpdTab(u_in).OVERCOMMITMENT_QUANTITY := NULL;
-- End fix for bug 2504222
                          TmpUpdTab(u_in).OVERPROVISIONAL_QTY := NULL;
                          TmpUpdTab(u_in).OVER_PROV_CONF_QTY := NULL;
                          TmpUpdTab(u_in).CONFIRMED_QTY := NULL;
                          TmpUpdTab(u_in).PROVISIONAL_QTY := NULL;
                          TmpUpdTab(u_in).item_quantity := 0;
                          TmpUpdTab(u_in).delete_flag := 'Y';
                          TmpUpdTab(u_in).error_flag := 'N';
                          TmpUpdTab(u_in).other_rejection_code := NULL;
                          u_in := u_in + 1;

                       ELSIF p_DbHdrTab(d_in).error_flag = 'Y' THEN
                          print_message('Asg : in else 3 ');
                          lv_call_pos := 'Asg : in else 3 ';
                          TmpDayTab(i).action_flag := 'E';
                          TmpDayTab(i).forecast_item_id :=
                                    p_DbHdrTab(d_in).forecast_item_id;

                       ELSIF ( (lv_resou <>
                               p_DbHdrTab(d_in).expenditure_org_id) OR
                            (lv_resorgn <>
                               p_DbHdrTab(d_in).expenditure_organization_id) OR
                            (p_AsgnDtlRec.expenditure_type <>
                               p_DbHdrTab(d_in).expenditure_type) OR
                            (p_AsgnDtlRec.expenditure_type_class <>
                               p_DbHdrTab(d_in).expenditure_type_class) OR
                           (nvl(p_AsgnDtlRec.fcst_tp_amount_type,'Z') <>
                               nvl(p_DbHdrTab(d_in).tp_amount_type,'Z')) OR
                            (lv_borrowed_flag <> p_DbHdrTab(d_in).borrowed_flag) OR
                            (NVL(TmpDayTab(i).asgmt_sys_status_code,'Z') <> NVL(p_DbHdrTab(d_in).asgmt_sys_status_code,'Z'))
                           ) THEN
                          print_message('Asg : in else 3a ');

                          lv_call_pos := 'Asg : in else 3a ';
                          TmpDayTab(i).action_flag := 'DN';
                          TmpUpdTab(u_in) := p_DbHdrTab(d_in);
                          TmpUpdTab(u_in).CAPACITY_QUANTITY := NULL;
                          TmpUpdTab(u_in).OVERCOMMITMENT_QTY := NULL;
-- Start fix for bug 2504222 (changed for consistency, not vital for fix)
                          TmpUpdTab(u_in).OVERCOMMITMENT_QUANTITY := NULL;
-- End fix for bug 2504222
                          TmpUpdTab(u_in).OVERPROVISIONAL_QTY := NULL;
                          TmpUpdTab(u_in).OVER_PROV_CONF_QTY := NULL;
                          TmpUpdTab(u_in).CONFIRMED_QTY := NULL;
                          TmpUpdTab(u_in).PROVISIONAL_QTY := NULL;
                          TmpUpdTab(u_in).item_quantity := 0;
                          TmpUpdTab(u_in).delete_flag := 'Y';
                          u_in := u_in + 1;

                       ELSIF (
                              NVL(TmpDayTab(i).CAPACITY_QUANTITY,0) <> NVL(p_DbHdrTab(d_in).CAPACITY_QUANTITY,0) OR
                              NVL(TmpDayTab(i).OVERCOMMITMENT_QUANTITY,0) <> NVL(p_DbHdrTab(d_in).OVERCOMMITMENT_QUANTITY,0) OR
                              NVL(TmpDayTab(i).AVAILABILITY_QUANTITY,0) <> NVL(p_DbHdrTab(d_in).AVAILABILITY_QUANTITY,0) OR
                              NVL(TmpDayTab(i).OVERPROVISIONAL_QTY,0) <> NVL(p_DbHdrTab(d_in).OVERPROVISIONAL_QTY,0) OR
                              NVL(TmpDayTab(i).OVER_PROV_CONF_QTY,0) <> NVL(p_DbHdrTab(d_in).OVER_PROV_CONF_QTY,0) OR
                              NVL(TmpDayTab(i).CONFIRMED_QTY,0) <> NVL(p_DbHdrTab(d_in).CONFIRMED_QTY,0) OR
                              NVL(TmpDayTab(i).PROVISIONAL_QTY,0) <> NVL(p_DbHdrTab(d_in).PROVISIONAL_QTY,0) OR
                              TmpDayTab(i).item_quantity <>
                                  p_DbHdrTab(d_in).item_quantity
                              ) THEN

                          print_message('Asg : in else 3b ');
                          lv_call_pos := 'Asg : in else 3b ';
                          TmpDayTab(i).action_flag := 'RN';
                          TmpDayTab(i).expenditure_organization_id :=
                                      p_AsgnDtlRec.expenditure_organization_id;
                          TmpDayTab(i).tp_amount_type :=
                                      p_AsgnDtlRec.fcst_tp_amount_type;
                          TmpDayTab(i).project_id :=
                                      p_AsgnDtlRec.project_id;
                          TmpDayTab(i).resource_id :=
                                      p_AsgnDtlRec.resource_id;
                          TmpDayTab(i).expenditure_org_id :=
                                       l_resou_tab(lv_res_index);
                          TmpDayTab(i).project_org_id := lv_project_org_id;
                          --TmpDayTab(i).tp_amount_type :=
                          --           lv_default_tp_amount_type;
                          TmpDayTab(i).person_billable_flag :=
                                     lv_person_bill_flag;
                          TmpUpdTab(u_in) := p_DbHdrTab(d_in);
                          TmpUpdTab(u_in).CAPACITY_QUANTITY :=
                                        TmpDayTab(i).CAPACITY_QUANTITY;
                          TmpUpdTab(u_in).OVERCOMMITMENT_QTY :=
                                        TmpDayTab(i).OVERCOMMITMENT_QTY;
-- Start fix for bug 2504222 (changed for consistency, not vital for fix)
                          TmpUpdTab(u_in).OVERCOMMITMENT_QUANTITY :=
                                        TmpDayTab(i).OVERCOMMITMENT_QUANTITY;
-- End fix for bug 2504222
                          TmpUpdTab(u_in).OVERPROVISIONAL_QTY :=
                                        TmpDayTab(i).OVERPROVISIONAL_QTY;
                          TmpUpdTab(u_in).OVER_PROV_CONF_QTY :=
                                        TmpDayTab(i).OVER_PROV_CONF_QTY;
                          TmpUpdTab(u_in).CONFIRMED_QTY :=
                                        TmpDayTab(i).CONFIRMED_QTY;
                          TmpUpdTab(u_in).PROVISIONAL_QTY :=
                                        TmpDayTab(i).PROVISIONAL_QTY;
                          TmpUpdTab(u_in).item_quantity :=
                                         TmpDayTab(i).item_quantity;
                          u_in := u_in + 1;

                       ELSE

                          print_message('Asg : in else 3c ');
                          lv_call_pos := 'Asg : in else 3c ';
                          TmpDayTab(i).action_flag := 'C';
                          TmpDayTab(i).expenditure_org_id :=
                                       l_resou_tab(lv_res_index);
                          TmpDayTab(i).expenditure_organization_id :=
                                      p_AsgnDtlRec.expenditure_organization_id;
                          TmpDayTab(i).tp_amount_type :=
                                      p_AsgnDtlRec.fcst_tp_amount_type;
                          TmpDayTab(i).project_id :=
                                      p_AsgnDtlRec.project_id;
                          TmpDayTab(i).resource_id :=
                                      p_AsgnDtlRec.resource_id;
                          TmpDayTab(i).project_org_id := lv_project_org_id;
                         -- TmpDayTab(i).tp_amount_type :=
                         --            lv_default_tp_amount_type;
                          TmpDayTab(i).person_billable_flag :=
                                     lv_person_bill_flag;

                       END IF;

                       d_in := d_in + 1;

                    END IF;

                 END IF;

                 lv_call_pos := 'Asg : data create ';
                 IF (TmpDayTab(i).action_flag IN ('N', 'DN','E') AND
                        (
                         NVL(TmpDayTab(i).CAPACITY_QUANTITY,0) > 0 OR
                         NVL(TmpDayTab(i).OVERCOMMITMENT_QTY,0) > 0 OR
-- Start fix for bug 2504222 (changed for consistency, not vital for fix)
                         NVL(TmpDayTab(i).OVERCOMMITMENT_QUANTITY,0) > 0 OR
-- End fix for bug 2504222
                         NVL(TmpDayTab(i).OVERPROVISIONAL_QTY,0) > 0 OR
                         NVL(TmpDayTab(i).OVER_PROV_CONF_QTY,0) > 0 OR
                         NVL(TmpDayTab(i).CONFIRMED_QTY,0) > 0 OR
                         NVL(TmpDayTab(i).PROVISIONAL_QTY,0) > 0 OR
                         TmpDayTab(i).item_quantity > 0
                         )
                     ) THEN

                    lv_call_pos := 'Asg : in if data create ';
                    IF TmpDayTab(i).action_flag <> 'E' THEN

                         lv_forecast_item_id :=
                              PA_FORECAST_ITEMS_UTILS.get_next_forecast_item_id;

                         TmpDayTab(i).forecast_item_id := lv_forecast_item_id;

                    ELSE

                         lv_forecast_item_id := TmpDayTab(i).forecast_item_id;

                    END IF;

                    TmpHdrRec.forecast_item_id := lv_forecast_item_id;
                   -- TmpDayTab(i).tp_amount_type := lv_default_tp_amount_type;
                    TmpDayTab(i).person_billable_flag := lv_person_bill_flag;
                    TmpDayTab(i).project_org_id := lv_project_org_id;
                    TmpDayTab(i).expenditure_org_id := lv_resou;
                    TmpDayTab(i).tp_amount_type := p_AsgnDtlRec.fcst_tp_amount_type;
                    TmpDayTab(i).project_id := p_AsgnDtlRec.project_id;
                    TmpDayTab(i).resource_id := p_AsgnDtlRec.resource_id;
                    TmpDayTab(i).expenditure_organization_id := lv_resorgn;

                    TmpHdrRec.tp_amount_type := p_AsgnDtlRec.fcst_tp_amount_type;
                    TmpHdrRec.forecast_item_type := 'A';
                    TmpHdrRec.project_org_id := lv_project_org_id;
                    TmpHdrRec.expenditure_org_id := lv_resou;
                    TmpHdrRec.project_organization_id :=
                                            lv_project_orgn_id;
                    TmpHdrRec.expenditure_organization_id := lv_resorgn;
                    TmpHdrRec.project_id := p_AsgnDtlRec.project_id;
                    TmpHdrRec.project_type_class := lv_project_type_class;
                    TmpHdrRec.person_id := lv_person_id;
                    TmpHdrRec.resource_id := p_AsgnDtlRec.resource_id;
                    TmpHdrRec.borrowed_flag := lv_borrowed_flag;
                    TmpHdrRec.assignment_id := p_AsgnDtlRec.assignment_id;
                    TmpHdrRec.item_date := TmpDayTab(i).item_date;
                    TmpHdrRec.item_UOM := 'HOURS';
                    TmpHdrRec.item_quantity := TmpDayTab(i).item_quantity;
                    TmpHdrRec.pvdr_period_set_name :=
                                         lv_pvdr_period_set_name;
                    TmpHdrRec.asgmt_sys_status_code := TmpDayTab(i).asgmt_sys_status_code;
                    TmpHdrRec.capacity_quantity := null;
                    TmpHdrRec.OVERPROVISIONAL_QTY := NULL;
                    TmpHdrRec.OVER_PROV_CONF_QTY := NULL;
                    TmpHdrRec.CONFIRMED_QTY := NULL;
                    TmpHdrRec.PROVISIONAL_QTY := NULL;
                    TmpHdrRec.overcommitment_quantity := null;
                    TmpHdrRec.availability_quantity := null;
                    TmpHdrRec.overcommitment_flag := null;
                    TmpHdrRec.availability_flag := null;
                    lv_error_flag := 'N';

                    lv_call_pos := 'Asg : pvdrpa ';
                    IF (ld_pvdrpa_startdate_tab.count = 0) THEN

                        lv_error_flag := 'Y';

                        IF (lv_rejection_code IS NULL) THEN

                            lv_rejection_code := 'PVDR_PA_PRD_NAME_NOT_FOUND';

                        END IF;

                    ELSIF (trunc(TmpHdrRec.item_date) NOT BETWEEN
                         trunc(ld_pvdrpa_startdate_tab(lv_pvpa_index)) AND
                         trunc(ld_pvdrpa_enddate_tab(lv_pvpa_index))) THEN

                       lv_prev_index := lv_pvpa_index;

                       LOOP

                           IF lv_pvpa_index > ld_pvdrpa_startdate_tab.COUNT THEN

                              lv_error_flag := 'Y';

                              IF (lv_rejection_code IS NULL) THEN

                                 lv_rejection_code :=
                                        'PVDR_PA_PRD_NAME_NOT_FOUND';

                              END IF;


                           END IF;

                           EXIT WHEN lv_error_flag = 'Y' OR
                              (trunc(TmpHdrRec.item_date) >=
                                trunc(ld_pvdrpa_startdate_tab(lv_pvpa_index))AND
                               trunc(TmpHdrRec.item_date) <=
                                trunc(ld_pvdrpa_enddate_tab(lv_pvpa_index)));

                           lv_pvpa_index := lv_pvpa_index + 1;

                       END LOOP;

                    END IF;

                    IF lv_error_flag = 'Y' THEN

                       lv_pvpa_index := lv_prev_index;
                       TmpHdrRec.pvdr_pa_period_name := '-99';

                    ELSE

                       TmpHdrRec.pvdr_pa_period_name :=
                                   lv_pvdrpa_name_tab(lv_pvpa_index);

                    END IF;

                    lv_error_flag := 'N';

                    lv_call_pos := 'Asg : pvdrgl ';
                    IF (ld_pvdrgl_startdate_tab.count = 0) THEN

                        lv_error_flag := 'Y';

                        IF (lv_rejection_code IS NULL) THEN

                            lv_rejection_code := 'PVDR_GL_PRD_NAME_NOT_FOUND';

                        END IF;


                    ELSIF (trunc(TmpHdrRec.item_date) NOT BETWEEN
                            trunc(ld_pvdrgl_startdate_tab(lv_pvgl_index)) AND
                            trunc(ld_pvdrgl_enddate_tab(lv_pvgl_index))) THEN

                        lv_prev_index := lv_pvgl_index;

                        LOOP

                           IF lv_pvgl_index > ld_pvdrgl_startdate_tab.COUNT THEN

                              lv_error_flag := 'Y';


                              IF (lv_rejection_code IS NULL) THEN

                                 lv_rejection_code :=
                                        'PVDR_GL_PRD_NAME_NOT_FOUND';

                              END IF;


                           END IF;

                           EXIT WHEN lv_error_flag = 'Y' OR
                             (trunc(TmpHdrRec.item_date) >=
                               trunc(ld_pvdrgl_startdate_tab(lv_pvgl_index)) AND
                              trunc(TmpHdrRec.item_date) <=
                               trunc(ld_pvdrgl_enddate_tab(lv_pvgl_index)));

                            lv_pvgl_index := lv_pvgl_index + 1;

                        END LOOP;

                    END IF;

                    IF lv_error_flag = 'Y' THEN

                       lv_pvgl_index := lv_prev_index;
                       TmpHdrRec.pvdr_gl_period_name := '-99';

                    ELSE

                       TmpHdrRec.pvdr_gl_period_name :=
                                   lv_pvdrgl_name_tab(lv_pvgl_index);

                    END IF;

                    TmpHdrRec.rcvr_period_set_name :=
                                 lv_rcvr_period_set_name;

                    lv_error_flag := 'N';

                    lv_call_pos := 'Asg : rcvrpa ';
                    IF (ld_rcvrpa_startdate_tab.count = 0) THEN

                        lv_error_flag := 'Y';

                        IF (lv_rejection_code IS NULL) THEN

                            lv_rejection_code := 'RCVR_PA_PRD_NAME_NOT_FOUND';

                        END IF;


                    ELSIF (trunc(TmpHdrRec.item_date) NOT BETWEEN
                            trunc(ld_rcvrpa_startdate_tab(lv_rcpa_index)) AND
                            trunc(ld_rcvrpa_enddate_tab(lv_rcpa_index))) THEN

                       lv_prev_index := lv_rcpa_index;

                       LOOP

                           IF lv_rcpa_index > ld_rcvrpa_startdate_tab.COUNT THEN

                              lv_error_flag := 'Y';

                              IF (lv_rejection_code IS NULL) THEN

                                 lv_rejection_code :=
                                        'RCVR_PA_PRD_NAME_NOT_FOUND';

                              END IF;

                           END IF;

                           EXIT WHEN  lv_error_flag = 'Y' OR
                            ( trunc(TmpHdrRec.item_date) >=
                               trunc(ld_rcvrpa_startdate_tab(lv_rcpa_index)) AND
                              trunc(TmpHdrRec.item_date) <=
                               trunc(ld_rcvrpa_enddate_tab(lv_rcpa_index)));

                           lv_rcpa_index := lv_rcpa_index + 1;

                       END LOOP;

                    END IF;

                    IF lv_error_flag = 'Y' THEN

                       lv_rcpa_index := lv_prev_index;
                       TmpHdrRec.rcvr_pa_period_name := '-99';

                    ELSE

                       TmpHdrRec.rcvr_pa_period_name :=
                                   lv_rcvrpa_name_tab(lv_rcpa_index);

                    END IF;

                    lv_error_flag := 'N';

                    lv_call_pos := 'Asg : rcvrgl ';
                    IF (ld_rcvrgl_startdate_tab.count = 0) THEN

                        lv_error_flag := 'Y';

                        IF (lv_rejection_code IS NULL) THEN

                            lv_rejection_code := 'RCVR_GL_PRD_NAME_NOT_FOUND';

                        END IF;

                    ELSIF (trunc(TmpHdrRec.item_date) NOT BETWEEN
                            trunc(ld_rcvrgl_startdate_tab(lv_rcgl_index)) AND
                            trunc(ld_rcvrgl_enddate_tab(lv_rcgl_index))) THEN

                       lv_prev_index := lv_rcgl_index;

                       LOOP

                           IF lv_rcgl_index > ld_rcvrgl_startdate_tab.COUNT THEN

                              lv_error_flag := 'Y';

                              IF (lv_rejection_code IS NULL) THEN

                                  lv_rejection_code :=
                                           'RCVR_GL_PRD_NAME_NOT_FOUND';

                              END IF;

                           END IF;

                           EXIT WHEN lv_error_flag = 'Y' OR
                            (trunc(TmpHdrRec.item_date) >=
                              trunc(ld_rcvrgl_startdate_tab(lv_rcgl_index)) AND
                             trunc(TmpHdrRec.item_date) <=
                              trunc(ld_rcvrgl_enddate_tab(lv_rcgl_index)));

                           lv_rcgl_index := lv_rcgl_index + 1;

                       END LOOP;

                    END IF;

                    IF lv_error_flag = 'Y' THEN

                       lv_rcgl_index := lv_prev_index;
                       TmpHdrRec.rcvr_gl_period_name := '-99';

                    ELSE

                       TmpHdrRec.rcvr_gl_period_name :=
                                   lv_rcvrgl_name_tab(lv_rcgl_index);

                    END IF;

                    lv_error_flag := 'N';

                    lv_call_pos := 'Asg : wkdate ';
                    IF (trunc(TmpHdrRec.item_date) NOT BETWEEN
                        trunc(
                         lv_WeekDateRange_Tab(lv_wk_index).week_start_date) AND
                        trunc(
                         lv_WeekDateRange_Tab(lv_wk_index).week_end_date))
                                                         THEN

                       lv_prev_index := lv_wk_index;

                       LOOP
                           IF lv_wk_index > lv_WeekDateRange_Tab.COUNT THEN

                              lv_error_flag := 'Y';

                           END IF;

                           EXIT WHEN lv_error_flag = 'Y' OR
                           ((trunc(TmpHdrRec.item_date) >=
                             trunc(
                             lv_WeekDateRange_Tab(lv_wk_index).week_start_date))
                                                  AND
                            (trunc(TmpHdrRec.item_date) <=
                             trunc(
                             lv_WeekDateRange_Tab(lv_wk_index).week_end_date)));

                            lv_wk_index := lv_wk_index + 1;

                       END LOOP;

                    END IF;

                    TmpHdrRec.global_exp_period_end_date :=
                           lv_WeekDateRange_Tab(lv_wk_index).week_end_date;

                    TmpHdrRec.expenditure_type :=
                                    p_AsgnDtlRec.expenditure_type;
                    TmpHdrRec.expenditure_type_class :=
                                    p_AsgnDtlRec.expenditure_type_class;
                    TmpHdrRec.cost_rejection_code := NULL;
                    TmpHdrRec.rev_rejection_code  := NULL;
                    TmpHdrRec.Tp_rejection_code  := NULL;
                    TmpHdrRec.Burden_rejection_code  := NULL;
                    TmpHdrRec.Other_rejection_code  := lv_rejection_code;
                    TmpHdrRec.Delete_Flag  := 'N';
                    TmpHdrRec.Provisional_flag  :=
                                   TmpDayTab(i).provisional_flag;
                    TmpHdrRec.asgmt_sys_status_code  :=
                                   TmpDayTab(i).asgmt_sys_status_code;
		    -- 4583893 : Added lv_resorgn = -77 check
                    IF (lv_rejection_code IS NOT NULL OR lv_resorgn = -77) THEN

                       TmpHdrRec.Error_Flag  := 'Y';
                       TmpDayTab(i).Error_Flag := 'Y';

                    ELSE

                       TmpHdrRec.Error_Flag  := 'N';

                    END IF;

                    IF TmpDayTab(i).action_flag IN ('N','DN')  THEN

                       TmpInsTab(i_in) := TmpHdrRec;
                       i_in := i_in + 1;

                    ELSE

                       TmpDayTab(i).action_flag := 'RN';
                       TmpUpdTab(u_in) := TmpHdrRec;
                       u_in := u_in + 1;

                    END IF ;

/*
                Print_message('***********');
                Print_message(
                    ' item_date :' || TmpHdrRec.item_date);

                Print_message(
                    'fct_item_id:' || TmpHdrRec.forecast_item_id ||
                    ' fct_itm_typ:' || TmpHdrRec.forecast_item_type ||
                    ' prj_org_id:' || TmpHdrRec.project_org_id ||
                    ' exp_org_id:' || TmpHdrRec.expenditure_org_id||
                    chr(10)|| 'exp_orgn_id:' ||
                               TmpHdrRec.expenditure_organization_id ||
                    ' prj_orgn_id:' ||
                               TmpHdrRec.project_organization_id ||
                    ' prj_id:' || TmpHdrRec.project_id);

                Print_message(
                     'prj_typ_cls:' || TmpHdrRec.project_type_class ||
                     ' person_id:' || TmpHdrRec.person_id||
                     ' res_id:' || TmpHdrRec.resource_id ||
                     ' brw_flg:' || TmpHdrRec.borrowed_flag ||
                     ' asgn_id:' || TmpHdrRec.assignment_id ||
                     ' item_uom:' || TmpHdrRec.item_uom ||
                     ' itm_qty:' || TmpHdrRec.item_quantity);

                Print_message(
                    'pvd_set_nme:' || TmpHdrRec.pvdr_period_set_name ||
                    ' pvd_pa_name:' ||
                               TmpHdrRec.pvdr_pa_period_name ||
                    chr(10) || 'pvd_gl_name:' ||
                               TmpHdrRec.pvdr_gl_period_name ||
                    ' rcv_set_nme:' ||
                               TmpHdrRec.rcvr_period_set_name ||
                    chr(10) || 'rcv_pa_name:' ||
                               TmpHdrRec.rcvr_pa_period_name ||
                    ' rcv_gl_name:' ||
                               TmpHdrRec.rcvr_gl_period_name ||
                    chr(10) || 'glb_end_dt:' ||
                               TmpHdrRec.global_exp_period_end_date);

                Print_message(
                    'exp_type:' || TmpHdrRec.expenditure_type ||
                    ' exp_typ_cls:' ||
                               TmpHdrRec.expenditure_type_class ||
                    chr(10) || 'oth_rej_cde:' ||
                               TmpHdrRec.other_rejection_code ||
                    ' Del_flag:' || TmpHdrRec.delete_flag ||
                    ' Err_flag:' || TmpHdrRec.error_flag ||
                    ' Prv_flag:' || TmpHdrRec.provisional_flag);
*/

                 END IF;
             end if;
             END LOOP;
             end if;

             x_FIHdrInsTab.Delete;
             x_FIHdrUpdTab.Delete;

             x_FIHdrInsTab := TmpInsTab;
             x_FIHdrUpdTab := TmpUpdTab;
             p_FIDayTab    := TmpDayTab;

             x_return_status := FND_API.G_RET_STS_SUCCESS;

             Print_message(
                   'Leaving Build_FI_Hdr_Asg');

             PA_DEBUG.Reset_Err_Stack;

             x_return_status := lv_return_status;

        EXCEPTION

             WHEN NO_DATA_FOUND THEN

                if lv_err_msg = 'ResOU_Not_Found' then

                  x_msg_count     := 1;
                  x_msg_data      := 'ResOU not found';
                  x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

                  FND_MSG_PUB.add_exc_msg
                      (p_pkg_name   =>
                              'PA_FORECASTITEM_PVT.Build_FI_Hdr_Asg',
                       p_procedure_name => PA_DEBUG.G_Err_Stack);

		               If x_msg_count = 1 THEN
				              pa_interface_utils_pub.get_messages
				                (p_encoded        => FND_API.G_TRUE,
					               p_msg_index      => 1,
					               p_msg_count      => x_msg_count,
					               p_msg_data       => x_msg_data,
					               p_data           => l_data , -- 4537865
					               p_msg_index_out  => l_msg_index_out );
						x_msg_data := l_data ; -- 4537865
		               End If;
                  Print_message(x_msg_data);
                  Print_message(lv_call_pos);

                  RAISE;

               elsif lv_err_msg = 'Resorgn_Not_Found' then
                  x_msg_count     := 1;
                  x_msg_data      := 'ResOrgn not found';
                  x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

                  FND_MSG_PUB.add_exc_msg
                      (p_pkg_name   =>
                              'PA_FORECASTITEM_PVT.Build_FI_Hdr_Asg',
                       p_procedure_name => PA_DEBUG.G_Err_Stack);

		               If x_msg_count = 1 THEN
				              pa_interface_utils_pub.get_messages
				                (p_encoded        => FND_API.G_TRUE,
					               p_msg_index      => 1,
					               p_msg_count      => x_msg_count,
					               p_msg_data       => x_msg_data,
					               p_data           => l_data , -- 4537865
					               p_msg_index_out  => l_msg_index_out );
						 x_msg_data := l_data ; -- 4537865
		               End If;
                  Print_message(x_msg_data);
                  Print_message(lv_call_pos);

                  RAISE;

               else

                  x_msg_count     := 1;
                  x_msg_data      := sqlerrm ;
                  x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

                  FND_MSG_PUB.add_exc_msg
                      (p_pkg_name   =>
                              'PA_FORECASTITEM_PVT.Build_FI_Hdr_Asg',
                       p_procedure_name => PA_DEBUG.G_Err_Stack);

		               If x_msg_count = 1 THEN
				              pa_interface_utils_pub.get_messages
				                (p_encoded        => FND_API.G_TRUE,
					               p_msg_index      => 1,
					               p_msg_count      => x_msg_count,
					               p_msg_data       => x_msg_data,
					               p_data           => l_data , -- 4537865
					               p_msg_index_out  => l_msg_index_out );
					 x_msg_data := l_data ; -- 4537865
		               End If;
                  Print_message(x_msg_data);
                  Print_message(lv_call_pos);

                  RAISE;

               end if;


             WHEN OTHERS THEN
                  print_message('Failed in Build_FI_Hdr_asg api');
                  print_message('SQLCODE'||sqlcode||sqlerrm);

                  x_msg_count     := 1;
                  x_msg_data      := sqlerrm;
                  x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

                  FND_MSG_PUB.add_exc_msg
                      (p_pkg_name   =>
                              'PA_FORECASTITEM_PVT.Build_FI_Hdr_Asg',
                       p_procedure_name => PA_DEBUG.G_Err_Stack);

		               If x_msg_count = 1 THEN
				              pa_interface_utils_pub.get_messages
				                (p_encoded        => FND_API.G_TRUE,
					               p_msg_index      => 1,
					               p_msg_count      => x_msg_count,
					               p_msg_data       => x_msg_data,
					               p_data           => l_data , -- 4537865
					               p_msg_index_out  => l_msg_index_out );
						  x_msg_data := l_data ; -- 4537865
		               End If;
                  Print_message(x_msg_data);
                  Print_message(lv_call_pos);

                  RAISE;


       END Build_FI_Hdr_Asg;

/* ---------------------------------------------------------------------
|   Procedure  :   Build_FI_Dtl_Asg
|   Purpose    :   To create new/modified forecast item detail(Assignment)
|                  record FOR the item DATEs that are built IN the p_FIDayTab
|   Parameters :   p_AsgnDtlRec - Assignment details
|                  p_DBDtlTab   - Holds forecast item detail records which are
|                                 already existing
|                  p_FIDayTab   - Holds all item_dates,item_quantity,
|                                 status_code FOR the current run.
|                       action_flag component of this tab already indicates
|                       (By Header Processing) the following :
|                      a) N  : New record - item_date does not exist
|                      b) DN : Delete AND create new -
|                                item DATE exists but expenditure OU/
|                                expenditure organization/expenditure type/
|                                expenditure type class/ borrowed flag has
|                                changed.
|                                Existing record is reversed(deleted) AND new
|                                record is created
|                      c) RN : Reverse AND create new -
|                              Quantity has changed.
|                              IN header : quantity is updated.
|                              IN detail :
|                                IF summarized existing line should be reversed
|                                   AND new line created
|                                IF not summarized existing line should be
|                                   updated to reflect new quantity
|                      d) C :  No change IN header
|                              Check FOR any changes IN detail record for
|                              person_billable_flag, provisional_flag,
|                              work_type OR resource_type
|                  x_FIDtlInsTab - Will RETURN all forecast item detail records
|                                  that are new
|                  x_FIDtlUpdTab - Will RETURN all forecast item detail records
|                                  that are modified
|                  x_return_status     -
|                  x_msg_count         -
|                  x_msg_data          -
+----------------------------------------------------------------------*/
       PROCEDURE Build_FI_Dtl_Asg(
                 p_AsgnDtlRec    IN     PA_FORECAST_GLOB.AsgnDtlRecord,
                 p_DBDtlTab      IN     PA_FORECAST_GLOB.FIDtlTabTyp,
                 p_FIDayTab      IN     PA_FORECAST_GLOB.FIDayTabTyp,
                 x_FIDtlInsTab   OUT    NOCOPY PA_FORECAST_GLOB.FIDtlTabTyp, /* 2674619 - Nocopy change */
                 x_FIDtlUpdTab   OUT    NOCOPY PA_FORECAST_GLOB.FIDtlTabTyp, /* 2674619 - Nocopy change */
                 x_return_status OUT    NOCOPY VARCHAR2, -- 4537865
                 x_msg_count     OUT    NOCOPY NUMBER,  -- 4537865
                 x_msg_data      OUT    NOCOPY VARCHAR2) IS  -- 4537865



	           l_msg_index_out	            NUMBER;
		   l_data varchar2(2000);  -- 4537865
             d_in                     NUMBER := 1; -- index FOR p_dbDtlTab;
             TmpDayTab                PA_FORECAST_GLOB.FIDayTabTyp;
             TmpInsTab                PA_FORECAST_GLOB.FIDtlTabTyp;
             i_in                     NUMBER := 1; -- index FOR TmpDayTab;
             TmpUpdTab                PA_FORECAST_GLOB.FIDtlTabTyp;
             u_in                     NUMBER := 1; -- index FOR TmpDayTab;
             TmpDtlRec                PA_FORECAST_GLOB.FIDtlRecord;

             lv_billable_flag         VARCHAR2(1);
             l_resutilweighted      NUMBER;
             l_orgutilweighted      NUMBER;
             l_resutilcategoryid      NUMBER;
             l_orgutilcategoryid      NUMBER;
             l_ReduceCapacityFlag     VARCHAR2(1);

             lv_inc_forecast_flag     VARCHAR2(3) := 'N';
             lv_inc_util_flag     VARCHAR2(3) := 'N';
             lv_provisional_flag      VARCHAR2(3);
             lv_next_line_num         NUMBER;
             lv_new_fcast_sum_code    VARCHAR2(1);
             lv_new_util_sum_code    VARCHAR2(1);
             lv_resource_type         VARCHAR2(30);
             lv_amount_type_id        NUMBER;
             lv_person_id             NUMBER;

             lv_return_status  VARCHAR2(30);
             tmp_person_id            NUMBER;
             lv_start_date            DATE;
             lv_end_date              DATE;

       BEGIN

             lv_return_status := FND_API.G_RET_STS_SUCCESS;

             PA_DEBUG.Init_err_stack(
                       'PA_FORECASTITEM_PVT.Build_FI_Dtl_Asg');

             TmpDayTab.Delete;
             TmpInsTab.Delete;
             TmpUpdTab.Delete;


             Print_message('entering build_fi_dtl_asg');

             TmpDayTab := p_FIDayTab;


             Print_message( 'Asg - Get_resource_type');

             lv_resource_type := PA_FORECAST_ITEMS_UTILS.get_resource_type(
                                     p_AsgnDtlRec.resource_id);

             lv_amount_type_id := get_AmountTypeID;

             lv_person_id := PA_FORECAST_ITEMS_UTILS.get_person_id(
                                    p_AsgnDtlRec.resource_id);

             Print_message('Asg - Get_work_type_details');
             PA_FORECAST_ITEMS_UTILS.get_work_type_details(
                                      p_AsgnDtlRec.work_type_id,
                                      lv_billable_flag,
                                      l_resutilweighted,
                                      l_orgutilweighted,
                                      l_resutilcategoryid,
                                      l_orgutilcategoryid,
                                      l_ReduceCapacityFlag);

             if (TmpDayTab.count <> 0) then
             FOR i IN TmpDayTab.FIRST..TmpDayTab.LAST LOOP
                 if TmpDayTab.exists(i) then
                 lv_inc_forecast_flag := TmpDayTab(i).include_in_forecast;

                 IF lv_inc_forecast_flag IN ('NO', 'N') THEN

                    lv_new_fcast_sum_code := 'X';

                 ELSE

                    lv_new_fcast_sum_code := 'N';

                 END IF;

/* Bug No: 1967832 Removed originial call to the function is-include_utilisation and added the following conditions. */

             IF TRUNC(TmpDayTab(i).item_date) BETWEEN TRUNC(lv_start_date) and TRUNC(nvl(lv_end_date,TmpDayTab(i).item_date))
                AND i>TmpDaytab.FIRST
                AND lv_person_id=tmp_person_id

                  THEN
                      lv_inc_util_flag := lv_inc_util_flag;
                 ELSE

                      Is_Include_Utilisation(p_person_id     => lv_person_id,
                                             p_item_date     => TmpDayTab(i).item_date,
                                             x_start_date    => lv_start_date,
                                             x_end_date      => lv_end_date,
                                             x_inc_util_flag => lv_inc_util_flag,
                                             x_return_status => lv_return_status,
                                             x_msg_count     => x_msg_count,
                                             x_msg_data      => x_msg_data);

                    tmp_person_id := lv_person_id;

                 END IF;


                 IF lv_inc_util_flag IN ('NO', 'N') THEN

                    lv_new_util_sum_code := 'X';

                 ELSE

                    lv_new_util_sum_code := 'N';

                 END IF;

                 lv_provisional_flag :=  TmpDayTab(i).provisional_flag;

                 lv_next_line_num := 1;

                 IF d_in <= p_DBDtlTab.COUNT THEN

                    IF trunc(TmpDayTab(i).item_date) <
                           trunc(p_DBDtlTab(d_in).item_date) THEN

                       -- New record
                       lv_next_line_num := 1;

                    ELSIF trunc(TmpDayTab(i).item_date) =
                              trunc(p_dbDtlTab(d_in).item_date) THEN

                       -- Record exists

                       IF TmpDayTab(i).action_flag  = 'C' THEN

                          -- Check IF there are changes in
                             -- person_billable, resource_type
                             -- work_type_id

                          print_message('p_DBDtlTab(d_in).provisional_flag: ' || p_DBDtlTab(d_in).provisional_flag);
                          print_message('lv_provisional_flag: ' || lv_provisional_flag);

                          IF  (p_DBDtlTab(d_in).provisional_flag <>
                                  lv_provisional_flag) OR
                              (NVL(p_DBDtlTab(d_in).forecast_summarized_code,'Y')
                                          IN ('N', 'Y')
                                 AND lv_new_fcast_sum_code = 'X') OR
                              (p_DBDtlTab(d_in).forecast_summarized_code = 'X'
                                 AND lv_new_fcast_sum_code = 'N') OR
                              (NVL(p_DBDtlTab(d_in).PJI_SUMMARIZED_FLAG,'Y')
                                          IN ('N', 'Y')
                                 AND lv_new_util_sum_code = 'X') OR
                              (p_DBDtlTab(d_in).PJI_SUMMARIZED_FLAG = 'X'
                                 AND lv_new_util_sum_code = 'N') OR

                              (NVL(p_DBDtlTab(d_in).util_summarized_code,'Y')
                                          IN ('N', 'Y')
                                 AND lv_new_util_sum_code = 'X') OR
                              (p_DBDtlTab(d_in).util_summarized_code = 'X'
                                 AND lv_new_util_sum_code = 'N') OR
                              (p_DBDtlTab(d_in).work_type_id <>
                                  p_AsgnDtlRec.work_type_id)  OR
                              (p_DBDtlTab(d_in).person_billable_flag <>
                                  TmpDayTab(i).person_billable_flag)  OR
                              (p_DBDtlTab(d_in).resource_type_code <>
                                  lv_resource_type) THEN

                               TmpDayTab(i).action_flag := 'RN';

                          ELSE

                               TmpDayTab(i).action_flag := 'I';

                          END IF;

                       END IF;


                       IF TmpDayTab(i).action_flag  IN ('DN', 'D') THEN

                          -- Change IN header attribute values
                          -- update existing line FOR flags
                          -- Reverse detail line IF forecast/util
                              --summarization done
                          -- IF summ not done IN existing line;
                               -- item_quantity to zero
                               -- net_zero flag to Y
                               -- forecast/util summ_flag = 'X'
                          -- New line generation is done at the end

                          lv_next_line_num := 1;

                          IF NVL(p_DBDtlTab(d_in).forecast_summarized_code,'Y')
                                             IN ('N', 'X', 'E')
                             AND NVL(p_DBDtlTab(d_in).PJI_SUMMARIZED_FLAG,'Y')
                                            IN ('N', 'X', 'E')
                             AND NVL(p_DBDtlTab(d_in).util_summarized_code,'Y')
                                             IN ('N', 'X', 'E') THEN

                             TmpUpdTab(u_in) := p_dbDtlTab(d_in);
                             TmpUpdTab(u_in).forecast_summarized_code := 'X';
                             TmpUpdTab(u_in).PJI_SUMMARIZED_FLAG := 'X';
                             TmpUpdTab(u_in).util_summarized_code := 'X';
                             TmpUpdTab(u_in).CAPACITY_QUANTITY := NULL;
                             TmpUpdTab(u_in).OVERCOMMITMENT_QTY := NULL;
                             TmpUpdTab(u_in).OVERPROVISIONAL_QTY := NULL;
                             TmpUpdTab(u_in).OVER_PROV_CONF_QTY := NULL;
                             TmpUpdTab(u_in).CONFIRMED_QTY := NULL;
                             TmpUpdTab(u_in).PROVISIONAL_QTY := NULL;
                             TmpUpdTab(u_in).item_quantity := 0;
                             TmpUpdTab(u_in).org_util_weighted :=0;
                             TmpUpdTab(u_in).resource_util_weighted :=0;
                             TmpUpdTab(u_in).net_zero_flag := 'Y';
                             u_in := u_in + 1;

                          ELSE

                             TmpUpdTab(u_in) := p_DBDtlTab(d_in);
                             IF (
                                 nvl(p_DBDtlTab(d_in).CAPACITY_QUANTITY,0) > 0 OR
                                 nvl(p_DBDtlTab(d_in).OVERCOMMITMENT_QTY,0) > 0 OR
                                 nvl(p_DBDtlTab(d_in).OVERPROVISIONAL_QTY,0) > 0 OR
                                 nvl(p_DBDtlTab(d_in).OVER_PROV_CONF_QTY,0) > 0 OR
                                 nvl(p_DBDtlTab(d_in).CONFIRMED_QTY,0) > 0 OR
                                 nvl(p_DBDtlTab(d_in).PROVISIONAL_QTY,0) > 0 OR
                                 nvl(p_DBDtlTab(d_in).item_quantity,0) > 0
                                 ) THEN

                                -- Generate reverse line
                                TmpInsTab(i_in) := p_DBDtlTab(d_in);
                                TmpInsTab(i_in).line_num :=
                                           p_DBDtlTab(d_in).line_num + 1;
                                IF (NVL(TmpInsTab(i_in).CAPACITY_QUANTITY,0) = 0) THEN
                                   TmpInsTab(i_in).CAPACITY_QUANTITY := NULL;
                                ELSE
                                   TmpInsTab(i_in).CAPACITY_QUANTITY := NVL(TmpInsTab(i_in).CAPACITY_QUANTITY,0) * -1;
                                END IF;
                                IF (NVL(TmpInsTab(i_in).OVERCOMMITMENT_QTY,0) = 0) THEN
                                   TmpInsTab(i_in).OVERCOMMITMENT_QTY := NULL;
                                ELSE
                                   TmpInsTab(i_in).OVERCOMMITMENT_QTY := NVL(TmpInsTab(i_in).OVERCOMMITMENT_QTY,0) * -1;
                                END IF;
                                IF (NVL(TmpInsTab(i_in).OVERPROVISIONAL_QTY,0) = 0) THEN
                                   TmpInsTab(i_in).OVERPROVISIONAL_QTY := NULL;
                                ELSE
                                   TmpInsTab(i_in).OVERPROVISIONAL_QTY := NVL(TmpInsTab(i_in).OVERPROVISIONAL_QTY,0) * -1;
                                END IF;
                                IF (NVL(TmpInsTab(i_in).OVER_PROV_CONF_QTY,0) = 0) THEN
                                   TmpInsTab(i_in).OVER_PROV_CONF_QTY := NULL;
                                ELSE
                                   TmpInsTab(i_in).OVER_PROV_CONF_QTY := NVL(TmpInsTab(i_in).OVER_PROV_CONF_QTY,0) * -1;
                                END IF;
                                IF (NVL(TmpInsTab(i_in).CONFIRMED_QTY,0) = 0) THEN
                                   TmpInsTab(i_in).CONFIRMED_QTY := NULL;
                                ELSE
                                   TmpInsTab(i_in).CONFIRMED_QTY := NVL(TmpInsTab(i_in).CONFIRMED_QTY,0) * -1;
                                END IF;
                                IF (NVL(TmpInsTab(i_in).PROVISIONAL_QTY,0) = 0) THEN
                                   TmpInsTab(i_in).PROVISIONAL_QTY := NULL;
                                ELSE
                                   TmpInsTab(i_in).PROVISIONAL_QTY := NVL(TmpInsTab(i_in).PROVISIONAL_QTY,0) * -1;
                                END IF;
                                TmpInsTab(i_in).item_quantity :=
                                           TmpInsTab(i_in).item_quantity * -1;
                                TmpInsTab(i_in).resource_util_weighted :=
                                          TmpInsTab(i_in).resource_util_weighted * -1;
                                TmpInsTab(i_in).org_util_weighted :=
                                          TmpInsTab(i_in).org_util_weighted * -1;
                                TmpInsTab(i_in).reversed_flag := 'N';
                                TmpInsTab(i_in).line_num_reversed :=
                                           p_DBDtlTab(d_in).line_num;
                                TmpInsTab(i_in).net_zero_flag := 'Y';

                                IF NVL(p_DBDtlTab(d_in).forecast_summarized_code,'Y') =
                                                     'Y' THEN

                                   TmpInsTab(i_in).forecast_summarized_code :=
                                                       'N';

                                ELSE

                                   TmpInsTab(i_in).forecast_summarized_code :=
                                      p_DBDtlTab(d_in).forecast_summarized_code;

                                END IF;

                    IF NVL(p_DBDtlTab(d_in).PJI_SUMMARIZED_FLAG,'Y') = 'Y' THEN
                      TmpInsTab(i_in).PJI_SUMMARIZED_FLAG := 'N';
                    ELSE
                      TmpInsTab(i_in).PJI_SUMMARIZED_FLAG :=
                              p_DBDtlTab(d_in).PJI_SUMMARIZED_FLAG;
                    END IF;

                                IF NVL(p_DBDtlTab(d_in).util_summarized_code,'Y') = 'Y'
                                       THEN

                                   TmpInsTab(i_in).util_summarized_code := 'N';

                                ELSE

                                   TmpInsTab(i_in).util_summarized_code :=
                                      p_DBDtlTab(d_in).util_summarized_code;

                                END IF;

                                i_in := i_in + 1;


                                -- update line
                                TmpUpdTab(u_in).reversed_flag := 'Y';

                             END IF;

                             TmpUpdTab(u_in).net_zero_flag := 'Y';
                             u_in := u_in + 1;

                          END IF;

                       ELSIF TmpDayTab(i).action_flag  = 'RN' THEN

                          -- No change IN header
                          -- There is change IN item_quantity/provisional_flag/
                             -- include IN forecast/work_type_id
                          -- If summarization is not done
                          --   same line to be updated with new values
                          --   generated. Save forecast_item_id

                          IF NVL(p_DBDtlTab(d_in).forecast_summarized_code,'Y')
                                             IN ('N', 'X', 'E')
                             AND NVL(p_DBDtlTab(d_in).PJI_SUMMARIZED_FLAG,'Y')
                                            IN ('N', 'X', 'E')
                             AND NVL(p_DBDtlTab(d_in).util_summarized_code,'Y')
                                             IN ('N', 'X', 'E') THEN

                             TmpDayTab(i).action_flag := 'RU';
                             TmpDayTab(i).forecast_item_id :=
                                          p_dbDtlTab(d_in).forecast_item_id;
                             lv_next_line_num := p_DBDtlTab(d_in).line_num;

                          ELSE

                             TmpDayTab(i).forecast_item_id :=
                                       p_dbDtlTab(d_in).forecast_item_id;

                             TmpUpdTab(u_in) := p_DBDtlTab(d_in);

                             lv_next_line_num :=
                                           p_DBDtlTab(d_in).line_num + 1;

                             IF (
                                 nvl(p_DBDtlTab(d_in).CAPACITY_QUANTITY,0) > 0 OR
                                 nvl(p_DBDtlTab(d_in).OVERCOMMITMENT_QTY,0) > 0 OR
                                 nvl(p_DBDtlTab(d_in).OVERPROVISIONAL_QTY,0) > 0 OR
                                 nvl(p_DBDtlTab(d_in).OVER_PROV_CONF_QTY,0) > 0 OR
                                 nvl(p_DBDtlTab(d_in).CONFIRMED_QTY,0) > 0 OR
                                 nvl(p_DBDtlTab(d_in).PROVISIONAL_QTY,0) > 0 OR
                                 nvl(p_dbdtltab(d_in).item_quantity,0) > 0
                                 ) THEN

                                -- Generate Reverse Line
                                TmpInsTab(i_in) := p_DBDtlTab(d_in);
                                TmpInsTab(i_in).line_num := lv_next_line_num;
                                lv_next_line_num := lv_next_line_num + 1;
                                IF (NVL(TmpInsTab(i_in).CAPACITY_QUANTITY,0) = 0) THEN
                                   TmpInsTab(i_in).CAPACITY_QUANTITY := NULL;
                                ELSE
                                   TmpInsTab(i_in).CAPACITY_QUANTITY := NVL(TmpInsTab(i_in).CAPACITY_QUANTITY,0) * -1;
                                END IF;
                                IF (NVL(TmpInsTab(i_in).OVERCOMMITMENT_QTY,0) = 0) THEN
                                   TmpInsTab(i_in).OVERCOMMITMENT_QTY := NULL;
                                ELSE
                                   TmpInsTab(i_in).OVERCOMMITMENT_QTY := NVL(TmpInsTab(i_in).OVERCOMMITMENT_QTY,0) * -1;
                                END IF;
                                IF (NVL(TmpInsTab(i_in).OVERPROVISIONAL_QTY,0) = 0) THEN
                                   TmpInsTab(i_in).OVERPROVISIONAL_QTY := NULL;
                                ELSE
                                   TmpInsTab(i_in).OVERPROVISIONAL_QTY := NVL(TmpInsTab(i_in).OVERPROVISIONAL_QTY,0) * -1;
                                END IF;
                                IF (NVL(TmpInsTab(i_in).OVER_PROV_CONF_QTY,0) = 0) THEN
                                   TmpInsTab(i_in).OVER_PROV_CONF_QTY := NULL;
                                ELSE
                                   TmpInsTab(i_in).OVER_PROV_CONF_QTY := NVL(TmpInsTab(i_in).OVER_PROV_CONF_QTY,0) * -1;
                                END IF;
                                IF (NVL(TmpInsTab(i_in).CONFIRMED_QTY,0) = 0) THEN
                                   TmpInsTab(i_in).CONFIRMED_QTY := NULL;
                                ELSE
                                   TmpInsTab(i_in).CONFIRMED_QTY := NVL(TmpInsTab(i_in).CONFIRMED_QTY,0) * -1;
                                END IF;
                                IF (NVL(TmpInsTab(i_in).PROVISIONAL_QTY,0) = 0) THEN
                                   TmpInsTab(i_in).PROVISIONAL_QTY := NULL;
                                ELSE
                                   TmpInsTab(i_in).PROVISIONAL_QTY := NVL(TmpInsTab(i_in).PROVISIONAL_QTY,0) * -1;
                                END IF;
                                TmpInsTab(i_in).item_quantity :=
                                           p_DBDtlTab(d_in).item_quantity * -1;
                                TmpInsTab(i_in).resource_util_weighted :=
                                          p_DBDtlTab(d_in).resource_util_weighted * -1;
                                TmpInsTab(i_in).org_util_weighted :=
                                          p_DBDtlTab(d_in).org_util_weighted * -1;
                                TmpInsTab(i_in).reversed_flag := 'N';
                                TmpInsTab(i_in).line_num_reversed :=
                                           p_DBDtlTab(d_in).line_num;
                                TmpInsTab(i_in).net_zero_flag := 'Y';

                                IF NVL(p_DBDtlTab(d_in).forecast_summarized_code,'Y') =
                                                    'Y' THEN

                                   TmpInsTab(i_in).forecast_summarized_code :=
                                                        'N';

                                ELSE

                                   TmpInsTab(i_in).forecast_summarized_code :=
                                      p_DBDtlTab(d_in).forecast_summarized_code;

                                END IF;

                    IF NVL(p_DBDtlTab(d_in).PJI_SUMMARIZED_FLAG,'Y') = 'Y' THEN
                      TmpInsTab(i_in).PJI_SUMMARIZED_FLAG := 'N';
                    ELSE
                      TmpInsTab(i_in).PJI_SUMMARIZED_FLAG :=
                              p_DBDtlTab(d_in).PJI_SUMMARIZED_FLAG;
                    END IF;

                                IF NVL(p_DBDtlTab(d_in).util_summarized_code,'Y') = 'Y'
                                       THEN

                                   TmpInsTab(i_in).util_summarized_code := 'N';

                                ELSE

                                   TmpInsTab(i_in).util_summarized_code :=
                                      p_DBDtlTab(d_in).util_summarized_code;

                                END IF;

                                i_in := i_in + 1;


                                -- update Line
                                TmpUpdTab(u_in).reversed_flag := 'Y';
                             END IF;

                             TmpUpdTab(u_in).net_zero_flag := 'Y';
                             u_in := u_in + 1;

                          END IF;

                       END IF;

                       d_in := d_in + 1;

                    END IF;

                 END IF;

                 -- N New record/new line
                 -- DN Existing record has header changes
                      -- New record/new line
                 -- RN Existing record detail changes
                    -- The values are already summarized
                    -- Create new line
                 -- RU Existing record has detail changes
                    -- The values are not summarized
                    -- update existing line with new values
                 -- All attribute values are.FIRST generated IN Tmp_rec
                 -- IF action_flag is N,DN,RN copied to TmpInsTab
                 -- ELSE copied to TmpUpdTab

                 IF (TmpDayTab(i).action_flag IN ('N', 'DN', 'RN','RU')) AND
                      (
                       NVL(TmpDayTab(i).CAPACITY_QUANTITY,0) > 0 OR
                       NVL(TmpDayTab(i).OVERCOMMITMENT_QTY,0) > 0 OR
                       NVL(TmpDayTab(i).OVERPROVISIONAL_QTY,0) > 0 OR
                       NVL(TmpDayTab(i).OVER_PROV_CONF_QTY,0) > 0 OR
                       NVL(TmpDayTab(i).CONFIRMED_QTY,0) > 0 OR
                       NVL(TmpDayTab(i).PROVISIONAL_QTY,0) > 0 OR
                       TmpDayTab(i).item_quantity > 0
                       ) THEN

                    -- create new line
                    TmpDtlRec.forecast_item_id := TmpDayTab(i).forecast_item_id;
                    TmpDtlRec.amount_type_id := lv_amount_type_id;
                    TmpDtlRec.line_num := lv_next_line_num;
                    TmpDtlRec.resource_type_code := lv_resource_type;
                    TmpDtlRec.person_billable_flag :=
                                         TmpDayTab(i).person_billable_flag;
                    TmpDtlRec.item_date := TmpDayTab(i).item_date;
                    TmpDtlRec.expenditure_org_id :=
                                         TmpDayTab(i).expenditure_org_id;
                    TmpDtlRec.project_org_id := TmpDayTab(i).project_org_id;

                    TmpDtlRec.project_id := TmpDayTab(i).project_id;
                    TmpDtlRec.resource_id := TmpDayTab(i).resource_id;
                    TmpDtlRec.EXPENDITURE_ORGANIZATION_ID := TmpDayTab(i).EXPENDITURE_ORGANIZATION_ID;

                    TmpDtlRec.item_uom := 'HOURS';
                    TmpDtlRec.CAPACITY_QUANTITY := TmpDayTab(i).CAPACITY_QUANTITY;
                    TmpDtlRec.OVERCOMMITMENT_QTY := TmpDayTab(i).OVERCOMMITMENT_QTY;
                    TmpDtlRec.OVERPROVISIONAL_QTY := TmpDayTab(i).OVERPROVISIONAL_QTY;
                    TmpDtlRec.OVER_PROV_CONF_QTY := TmpDayTab(i).OVER_PROV_CONF_QTY;
                    TmpDtlRec.CONFIRMED_QTY := TmpDayTab(i).CONFIRMED_QTY;
                    TmpDtlRec.PROVISIONAL_QTY := TmpDayTab(i).PROVISIONAL_QTY;
                    TmpDtlRec.item_quantity := TmpDayTab(i).item_quantity;
                    TmpDtlRec.pvdr_acct_curr_code := NULL;
                    TmpDtlRec.pvdr_acct_amount := NULL;
                    TmpDtlRec.rcvr_acct_curr_code := NULL;
                    TmpDtlRec.rcvr_acct_amount := NULL;
                    TmpDtlRec.proj_currency_code := NULL;
                    TmpDtlRec.proj_amount := NULL;
                    TmpDtlRec.denom_currency_code := NULL;
                    TmpDtlRec.denom_amount := NULL;
                    TmpDtlRec.tp_amount_type :=
                                   p_AsgnDtlRec.fcst_tp_amount_type;
                    TmpDtlRec.billable_flag := lv_billable_flag;
                    TmpDtlRec.forecast_summarized_code :=
                                             lv_new_fcast_sum_code ;
                    TmpDtlRec.PJI_SUMMARIZED_FLAG := lv_new_util_sum_code;
                    TmpDtlRec.util_summarized_code :=
                                             lv_new_util_sum_code ;

                    IF TmpDayTab(i).Error_flag = 'Y' THEN

                       TmpDtlRec.PJI_SUMMARIZED_FLAG := 'E';
                       TmpDtlRec.util_summarized_code := 'E';
                       TmpDtlRec.forecast_summarized_code := 'E';

                    END IF;

                    TmpDtlRec.work_type_id := p_AsgnDtlRec.work_type_id;
                    TmpDtlRec.resource_util_category_id :=
                                                l_resutilcategoryid;
                    TmpDtlRec.org_util_category_id :=
                                                l_orgutilcategoryid;
                    TmpDtlRec.resource_util_weighted :=
                          TmpDayTab(i).item_quantity *
                                 l_resutilweighted/100;
                    TmpDtlRec.org_util_weighted :=
                          TmpDayTab(i).item_quantity *
                                    l_orgutilweighted/100;
                    TmpDtlRec.Reduce_Capacity_Flag := l_ReduceCapacityFlag;
                    TmpDtlRec.provisional_flag := TmpDayTab(i).provisional_flag;
                    TmpDtlRec.reversed_flag := 'N';
                    TmpDtlRec.net_zero_flag := 'N';
                    TmpDtlRec.line_num_reversed := 0;

                    IF TmpDayTab(i).action_flag = 'RU' THEN

                       TmpUpdTab(u_in) := TmpDtlRec;
                       u_in := u_in + 1;

                    ELSE

                       TmpInsTab(i_in) := TmpDtlRec;
                       i_in := i_in + 1;

                    END IF;

/*
                 Print_message('***********');

                 Print_message(
                    'item_date:' || TmpDtlRec.item_date);

                 Print_message(
                    'fct_item_id:' || TmpDtlRec.forecast_item_id ||
                    ' amt_typ_id:' || TmpDtlRec.amount_type_id  ||
                    ' line_num:' || TmpDtlRec.line_num ||
                    chr(10) || 'Res_typ_cd  :' ||
                               TmpDtlRec.resource_type_code ||
                    ' per_bil_fl:' ||
                               TmpDtlRec.person_billable_flag ||
                    ' item_uom:' || TmpDtlRec.item_uom );

                 Print_message(
                    ' item_qty:' || TmpDtlRec.item_quantity ||
                    ' exp_org_id:' ||
                               TmpDtlRec.expenditure_org_id ||
                    ' prj_org_id:' ||
                               TmpDtlRec.project_org_id ||
                    ' tp_amt_typ:' || TmpDtlRec.tp_amount_type ||
                    chr(10) || 'bill_flag:' || TmpDtlRec.billable_flag ||
                    ' fcs_sum_cd:' ||
                               TmpDtlRec.forecast_summarized_code ||
                    ' utl_sum_cd:' ||
                               TmpDtlRec.util_summarized_code );

                 Print_message(
                    ' wrk_typ_id:' || TmpDtlRec.work_type_id ||
                    ' res_utl_id:' ||
                               TmpDtlRec.resource_util_category_id ||
                    ' org_utl_id:' ||
                               TmpDtlRec.org_util_category_id ||
                    ' res_utl_wt:' ||
                               TmpDtlRec.resource_util_weighted ||
                    chr(10) || 'org_utl_wt:' ||
                               TmpDtlRec.org_util_weighted ||
                    ' prv_flag:' || TmpDtlRec.provisional_flag ||
                    ' rev_flag:' || TmpDtlRec.reversed_flag ||
                    ' net_zer_fl:' || TmpDtlRec.net_zero_flag ||
                    ' ln_num_rev:' ||
                               TmpDtlRec.line_num_reversed);
*/

                 END IF;
             end if;
             END LOOP;
             end if;


             x_FIDtlInsTab.Delete;
             x_FIDtlUpdTab.Delete;

             x_FIDtlInsTab := TmpInsTab;
             x_FIDtlUpdTab := TmpUpdTab;


             Print_message('Leaving build_fi_dtl_asg');

             PA_DEBUG.Reset_Err_Stack;

             x_return_status := lv_return_status;

        EXCEPTION

             WHEN OTHERS THEN
                  print_message('Failed in Build_fi_dtl_asg api');
                  print_message('SQLCODE'||sqlcode||sqlerrm);

                  x_msg_count     := 1;
                  x_msg_data      := sqlerrm;
                  x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

                  FND_MSG_PUB.add_exc_msg
                      (p_pkg_name   =>
                              'PA_FORECASTITEM_PVT.Build_FI_Dtl_Asg',
                       p_procedure_name => PA_DEBUG.G_Err_Stack);

		               If x_msg_count = 1 THEN
				              pa_interface_utils_pub.get_messages
				                (p_encoded        => FND_API.G_TRUE,
					               p_msg_index      => 1,
					               p_msg_count      => x_msg_count,
					               p_msg_data       => x_msg_data,
					               p_data           => l_data,  -- 4537865
					               p_msg_index_out  => l_msg_index_out );
						x_msg_data := l_data ;  -- 4537865
		               End If;
                  Print_message(x_msg_data);

                  RAISE;

       END Build_FI_Dtl_Asg;
/** This Api refreshes the assignment plsql schedule table after deleting the records
 ** so that it donot cause no data found error
 */
PROCEDURE refresh_assgn_schedule_tab(p_TmpScheduleTab  IN  PA_FORECAST_GLOB.ScheduleTabTyp
                               ,x_TmpScheduleTab OUT NOCOPY PA_FORECAST_GLOB.ScheduleTabTyp) /* 2674619 - Nocopy change */
IS

	           l_msg_index_out	            NUMBER;
        l_counter    INTEGER :=0;
        l_dummy_TmpScheduleTab  PA_FORECAST_GLOB.ScheduleTabTyp;

BEGIN
        -- Bug 2137333: Added empty table check.
              IF p_TmpScheduleTab.COUNT > 0 THEN
                l_counter := 1;

                FOR i IN p_TmpScheduleTab.FIRST..p_TmpScheduleTab.LAST LOOP

                        IF p_TmpScheduleTab.EXISTS(i) then
                                l_dummy_TmpScheduleTab(l_counter) := p_TmpScheduleTab(i);
                                l_counter := l_counter + 1;
                        END IF;

                END LOOP;
                x_TmpScheduleTab.delete();
                x_TmpScheduleTab := l_dummy_TmpScheduleTab;

            END IF;

            Return;


END refresh_assgn_schedule_tab;

/** This Api refreshes the plsql schedule table after deleting the records
 ** so that it donot cause no data found error
 */
PROCEDURE refresh_schedule_tab(p_TmpScheduleTab  IN  PA_SCHEDULE_GLOB.ScheduleTabTyp
                               ,x_TmpScheduleTab OUT NOCOPY PA_SCHEDULE_GLOB.ScheduleTabTyp) /* 2674619 - Nocopy change */
IS

	           l_msg_index_out	            NUMBER;
        l_counter    INTEGER :=0;
        l_dummy_TmpScheduleTab  PA_SCHEDULE_GLOB.ScheduleTabTyp;

BEGIN
            IF p_TmpScheduleTab.COUNT > 0 then

                l_counter := 1;

                FOR i IN p_TmpScheduleTab.FIRST..p_TmpScheduleTab.LAST LOOP

                        IF p_TmpScheduleTab.EXISTS(i) then
                                l_dummy_TmpScheduleTab(l_counter) := p_TmpScheduleTab(i);
                                l_counter := l_counter + 1;
                        END IF;

                END LOOP;
                x_TmpScheduleTab.delete();
                x_TmpScheduleTab := l_dummy_TmpScheduleTab;

            END IF;

            Return;


END refresh_schedule_tab;


/* ---------------------------------------------------------------------
|   Procedure  :   Regenerate_Res_Unassigned_FI
|   Purpose    :   To generate forecast items FOR resource unassigned time
|   Parameters :   p_resource_id    - Input Resource ID
|                  p_start_date     - Start DATE FOR Forecast Item Generation
|                  p_end_date       - END DATE FOR Forecast Item Generation
|                  p_process_mode   - Mode of Processing.
|                    a) GENERATE    : New Generation
|                                     Also when schedule data changes FOR
|                                     any assignment
|                    b) RECALCULATE : Whenever
|                                    i)expenditure OU Changes
|                                   ii)expenditure organization Changes
|                                  iii)expenditure type Changes
|                                   iv)expenditure type class Changes
|                                    v)Borrowed flag Changes
|                    c) ERROR       : Regeneration of Errored forecast items
|                                     by previous run
|                  p_ErrHdrTab      -
|                    a)GENERATE/        : Dummy tab is passed
|                      RECALCULATE Mode
|                    b) ERROR Mode      : Contains all errored forecast item
|                                          Header records
|                  p_date_validation - This was introduced for data fix
|                    scripts.  If 'N', then we do not use the avail
|                    duration profile to trunc the date.
|                  x_return_status  -
|                  x_msg_count      -
|                  x_msg_data       -
+----------------------------------------------------------------------*/

       PROCEDURE Regenerate_Res_Unassigned_FI(
                 p_resource_id        IN    NUMBER,
                 p_start_date         IN    OUT NOCOPY DATE,  -- 4537865
                 p_end_date           IN    OUT NOCOPY DATE,  -- 4537865
                 p_process_mode       IN    VARCHAR2,
                 p_ErrHdrTab          IN    PA_FORECAST_GLOB.FIHdrTabTyp,
                 p_date_validation    IN   VARCHAR2 := 'Y',
                 x_return_status      OUT   NOCOPY VARCHAR2,  -- 4537865
                 x_msg_count          OUT   NOCOPY NUMBER,    -- 4537865
                 x_msg_data           OUT   NOCOPY VARCHAR2) IS  -- 4537865

	           l_msg_index_out	            NUMBER;
		   l_data varchar2(2000) ;  -- 4537865
             TmpScheduleTab          PA_SCHEDULE_GLOB.ScheduleTabTyp;
             TmpResScheduleTab       PA_FORECAST_GLOB.ScheduleTabTyp;
             TmpAsgnScheduleTab      PA_FORECAST_GLOB.ScheduleTabTyp;
             TmpResFIDayTab          PA_FORECAST_GLOB.FIDayTabTyp;
             TmpAsgnFIDayTab         PA_FORECAST_GLOB.FIDayTabTyp;
             TmpAvlFIDayTab          PA_FORECAST_GLOB.FIDayTabTyp;
             TmpDbFIDtlTab           PA_FORECAST_GLOB.FIDtlTabTyp;
             TmpDbFIHdrTab           PA_FORECAST_GLOB.FIHdrTabTyp;
             TmpFIDtlInsTab          PA_FORECAST_GLOB.FIDtlTabTyp;
             TmpFIDtlUpdTab          PA_FORECAST_GLOB.FIDtlTabTyp;
             TmpFIHdrInsTab          PA_FORECAST_GLOB.FIHdrTabTyp;
             TmpFIHdrUpdTab          PA_FORECAST_GLOB.FIHdrTabTyp;

             li_no_of_days           NUMBER;
             lv_asgn_type            VARCHAR2(30) := 'UN-ASSGN';
             lb_found                BOOLEAN := FALSE;
             li_rows                 NUMBER;
             li_lock_id              NUMBER;
             li_lock_status          NUMBER;
             lv_lock_type            VARCHAR2(5) := 'RES';
             li_asgn_qty             NUMBER;
             li_conf_asgn_qty             NUMBER;
             li_prov_asgn_qty             NUMBER;

             l_Cannot_Acquire_Lock   EXCEPTION;
             lv_err_msg              VARCHAR2(30);
             ld_start_date           DATE;
             ld_end_date             DATE;

             lv_return_status  VARCHAR2(30);

             g_TimelineProfileSetup  PA_TIMELINE_GLOB.TimelineProfileSetup;
             AVAILABILITY_DURATION   NUMBER;

             cursor c_res_dates is
               select min(resource_effective_start_date),
                      max(resource_effective_end_date)
               from pa_resources_denorm
               where resource_id = p_resource_id;

             ld_res_start_date   DATE;
             ld_res_end_date     DATE;
             l_no_fis_to_create  EXCEPTION;

     BEGIN

       lv_return_status := FND_API.G_RET_STS_SUCCESS;

       IF (PA_INSTALL.is_prm_licensed = 'Y' OR
           PA_INSTALL.is_utilization_implemented = 'Y') THEN

             PA_DEBUG.Init_err_stack(
                       'PA_FORECASTITEM_PVT.Regenerate_Res_Unassigned_FI');

/* 2196924: Don't need this logic, because fis should be created wven when resource
   records are missing.
             open c_res_dates;
             fetch c_res_dates into ld_res_start_date, ld_res_end_date;
             print_message('ld_res_start_date: ' || ld_res_start_date);
             print_message('ld_res_end_date: ' || ld_res_end_date);
             if c_res_dates%NOTFOUND or ld_res_start_date is null then
               print_message('Invalid resource. No FIs to create.');
               close c_res_dates;
               raise l_no_fis_to_create;
             end if;
             close c_res_dates;
*/

             -- 2196924: Comment out this logic
             -- Don't create FIs if resource is end dated.
             --if (ld_res_end_date < sysdate) then
             --  print_message('Resource is end dated. No FIs to create.');
             --  raise l_no_fis_to_create;
             --end if;

             g_TimelineProfileSetup  := PA_TIMELINE_UTIL.get_timeline_profile_setup;
             AVAILABILITY_DURATION   := NVL(g_TimelineProfileSetup.availability_duration,0);
             p_start_date := NVL(p_start_date, ADD_MONTHS(sysdate, -12));
             p_end_date := NVL(p_end_date, ADD_MONTHS(sysdate, availability_duration * (12)));
             print_message('p_start_date: ' || p_start_date);
             print_message('p_end_date: ' || p_end_date);

             if (p_date_validation='Y' AND
 		             p_start_date < ADD_MONTHS(sysdate, -12)) then
                p_start_date := ADD_MONTHS(sysdate, -12);
             end if;

             if (p_date_validation='Y' AND
                 p_end_date > ADD_MONTHS(sysdate, availability_duration * (12)))
             then
                p_end_date := ADD_MONTHS(sysdate, availability_duration * (12));
             end if;

             print_message('p_start_date: ' || p_start_date);
             print_message('p_end_date: ' || p_end_date);

             if (p_start_date > p_end_date or availability_duration = 0) then
               print_message('l_no_fis_to_create');
               raise l_no_fis_to_create;
             end if;

             print_message('p_start_date: ' || p_start_date);
             print_message('p_end_date: ' || p_end_date);

             TmpScheduleTab.delete;
             TmpResScheduleTab.delete;
             TmpAsgnScheduleTab.delete;
             TmpResFIDayTab.delete;
             TmpAsgnFIDayTab.delete;
             TmpAvlFIDayTab.delete;
             TmpDbFIDtlTab.delete;
             TmpDbFIHdrTab.delete;
             TmpFIDtlInsTab.delete;
             TmpFIDtlUpdTab.delete;
             TmpFIHdrInsTab.delete;
             TmpFIHdrUpdTab.delete;

             Print_message(
                         'Entering Regenerate_Res_Unassigned_FI');

             IF (PA_FORECAST_ITEMS_UTILS.Set_User_Lock(
                                     p_resource_id, 'RES') <> 0) THEN
                RAISE l_cannot_acquire_lock;

             END IF;

             Print_message( 'Calling Get_resource_schedule');


             print_message('p_start_date: ' || p_start_date);
             print_message('p_end_date: ' || p_end_date);

             PA_SCHEDULE_PVT.get_resource_schedule (
                           p_source_id      => p_resource_id,
                           p_source_type    => 'PA_RESOURCE_ID',
                           p_start_date     => p_start_date,
                           p_end_date       => p_end_date,
                           x_Sch_Record_Tab => TmpScheduleTab,
                           x_return_status  => lv_return_status,
                           x_msg_count      => x_msg_count,
                           x_msg_data       => x_msg_data);


             print_message('p_start_date: ' || p_start_date);
             print_message('p_end_date: ' || p_end_date);

             IF TmpScheduleTab.Count = 0 THEN

                lv_err_msg := 'No_Schedule_Records - Res';
                RAISE NO_DATA_FOUND;

             END IF;

/* 2196924: Commenting out because dates are handled above.
             IF p_start_date IS NULL THEN

                p_start_date := TmpScheduleTab( TmpScheduleTab.FIRST).start_date;

             END IF;


             IF p_start_date < ADD_MONTHS(sysdate,
                                           availability_duration * (-12))  THEN
                ld_start_date := ADD_MONTHS(sysdate,
                                           availability_duration * (-12));

             ELSE

                ld_start_date := p_start_date;

             END IF;

*/
            ld_start_date := p_start_date;
            ld_end_date := p_end_date;

             print_message('1 p_start_date: ' || p_start_date);
             print_message('1 p_end_date: ' || p_end_date);

            /*** Bug fix : 1993843 the following lines are commented and new if condition added
             **  avoid creating too many unavailable records.
             --IF p_start_date >=  sysdate THEN
             --   ld_end_date :=  ADD_MONTHS(p_start_date,
             --                               availability_duration * 12);
             --ELSE
             --    ld_end_date := ADD_MONTHS(sysdate, availability_duration * 12);
             --END IF;
             ***/

/*
             IF p_end_date >= ADD_MONTHS(sysdate,availability_duration * (12)) THEN
                ld_end_date :=  ADD_MONTHS(sysdate,availability_duration * 12);
             ELSE
                ld_end_date := nvl(p_end_date,ADD_MONTHS(sysdate, availability_duration * 12));
             END IF;
            -- end of bug fix : 1993843
*/

             IF TmpScheduleTab(TmpScheduleTab.FIRST).start_date < ld_start_date
                                                                         THEN
                p_start_date := ld_start_date;

                lb_found := FALSE;

                FOR i IN TmpScheduleTab.FIRST..TmpScheduleTab.LAST LOOP

                    IF TmpScheduleTab.exists(i) then
                    IF TmpScheduleTab(i).end_date >= p_start_date THEN

                       lb_found := TRUE;
                       li_rows :=i - 1;

                    END IF;

                    EXIT WHEN lb_found;
                end if;
                END LOOP;

                IF lb_found THEN

                   -- delete the no needed schedules

                      FOR i IN 1..li_rows LOOP

                          TmpScheduleTab.delete(i);

                      END LOOP;

                      TmpScheduleTab(TmpScheduleTab.FIRST).start_date :=
                                                  p_start_date;
                END IF;

             END IF;

             IF  TmpScheduleTab(TmpScheduleTab.LAST).end_date <= ld_end_date
                                                                       THEN

                 --p_end_date   := TmpScheduleTab( TmpScheduleTab.LAST).end_date;
                /** bug fix :1993478,1993843 if the schedule date is less than FI generation
                  * start and end date then assign the FI generation end date */
                IF ( TmpScheduleTab(TmpScheduleTab.LAST).end_date < ld_start_date ) then
                        p_end_date := ld_end_date;
                        print_message('2 p_start_date: ' || p_start_date);
                        print_message('2 p_end_date: ' || p_end_date);

                Else
                 p_end_date   := TmpScheduleTab( TmpScheduleTab.LAST).end_date;
                 print_message('3 p_start_date: ' || p_start_date);
                 print_message('3 p_end_date: ' || p_end_date);

                End if;
                /*** end of bug fix  **/


             ELSE

                p_end_date   := ld_end_date;
                 print_message('4 p_start_date: ' || p_start_date);
                 print_message('4 p_end_date: ' || p_end_date);


                lb_found := FALSE;

                FOR i IN TmpScheduleTab.FIRST..TmpScheduleTab.LAST LOOP

                    If TmpScheduleTab.exists(i) then
                    IF TmpScheduleTab(i).end_date >= p_end_date THEN

                       lb_found := TRUE;
                       li_rows :=i;

                    END IF;

                    EXIT WHEN lb_found;
                end if;
                END LOOP;

                IF lb_found THEN

                   -- delete the no needed schedules

                   IF li_rows <> TmpScheduleTab.LAST THEN


                      FOR i IN li_rows+1..TmpScheduleTab.LAST LOOP

                          TmpScheduleTab.delete(i);

                      END LOOP;

                   END IF;

                   TmpScheduleTab(TmpScheduleTab.LAST).end_date :=
                                                  p_end_date;
                END IF;

             END IF;
            /** Added for bug fix : 1993478 if the FI generation dates not falls with in
             *  schedule range dates then we need not generate FI for those records
             *  so delete the records from schedule tab
             **/

          IF TmpScheduleTab.COUNT > 0 then

            	--print_message('before refresh3 :'||TmpScheduleTab.first||'-'||
              --             TmpScheduleTab.last||'-'||TmpScheduleTab.count);

	     	lb_found := FALSE;

             	FOR i IN TmpScheduleTab.FIRST..TmpScheduleTab.LAST LOOP
              IF TmpScheduleTab.EXISTS(i) then
			--print_message('p_start_date='||p_start_date||'TmpScheduleTab(i).Start_date='||
				--TmpScheduleTab(i).Start_date||'TmpScheduleTab(i).end_date='||
				--TmpScheduleTab(i).end_date);

                  	If (trunc(p_start_date) NOT BETWEEN trunc(TmpScheduleTab(i).Start_date)
                    	and trunc(TmpScheduleTab(i).End_date)) AND
                   	(trunc(p_end_date) NOT BETWEEN trunc(TmpScheduleTab(i).Start_date)
                    	and trunc(TmpScheduleTab(i).End_date)) then

                            IF trunc(TmpScheduleTab(i).End_date) < trunc(p_start_date) and
                               trunc(TmpScheduleTab(i).End_date) < trunc(p_end_date)  then
                                print_message('deleteing the sch records');
                                TmpScheduleTab.delete(i);
                                lb_found := TRUE;

                            End if;
                	End if;
                  END IF;

             	END LOOP;

            End if;
            --print_message('before refresh3 :'||TmpScheduleTab.first||'-'||
			      --TmpScheduleTab.last||'-'||TmpScheduleTab.count);

	    IF lb_found THEN
            	/** referesh the plsql table after deleteing records  **/

            	refresh_schedule_tab(TmpScheduleTab,TmpScheduleTab);

            	--print_message('after refresh3 :'||TmpScheduleTab.first||'-'||
		          --TmpScheduleTab.last||'-'||TmpScheduleTab.count);
	    END IF;

	    If TmpScheduleTab.count = 0 then
	     	/** if the schedule tab is zero then release the lock and return **/
             	li_lock_status := PA_FORECAST_ITEMS_UTILS.Release_User_lock(p_resource_id, 'RES');
                Print_message('Resource lock released ');
		Return;
	    End if;

             -- Move TmpScheduleTab to TmpResScheduleTab
             -- as TmpScheduleTab datatype is PA_SCHEDULE_GLOB.scheduletabtyp
             -- Uniform datatype is required FOR subsequent procedure calls


             FOR i IN TmpScheduleTab.FIRST..TmpScheduleTab.LAST LOOP

                 if TmpScheduleTab.exists(i) then
                 TmpResScheduleTab(i).status_code :=
                                  TmpScheduleTab(i).assignment_status_code;
                 TmpResScheduleTab(i).start_date :=
                                  TmpScheduleTab(i).start_date;
                 TmpResScheduleTab(i).end_date :=
                                  TmpScheduleTab(i).end_date;
                 TmpResScheduleTab(i).monday_hours :=
                                  TmpScheduleTab(i).monday_hours;
                 TmpResScheduleTab(i).tuesday_hours :=
                                  TmpScheduleTab(i).tuesday_hours;
                 TmpResScheduleTab(i).wednesday_hours :=
                                  TmpScheduleTab(i).wednesday_hours;
                 TmpResScheduleTab(i).thursday_hours :=
                                  TmpScheduleTab(i).thursday_hours;
                 TmpResScheduleTab(i).friday_hours :=
                                  TmpScheduleTab(i).friday_hours;
                 TmpResScheduleTab(i).saturday_hours :=
                                  TmpScheduleTab(i).saturday_hours;
                 TmpResScheduleTab(i).sunday_hours :=
                                  TmpScheduleTab(i).sunday_hours;
                 TmpResScheduleTab(i).forecast_txn_version_number :=  0;
                 TmpResScheduleTab(i).forecast_txn_generated_flag := NULL;
                 TmpResScheduleTab(i).schedule_id :=
                                  TmpScheduleTab(i).schedule_id;
                 TmpResScheduleTab(i).system_status_code := NULL;
             end if;
             END LOOP;

             IF lv_return_status = FND_API.G_RET_STS_SUCCESS THEN

                Print_message( 'Res Avl - Calling Initialize_Day_FI');

                Initialize_Day_FI   ( TmpResScheduleTab,
                                   p_process_mode,
                                   p_start_date,
                                   p_end_date,
                                   TmpResFIDayTab ,
                                   lv_return_status , x_msg_count , x_msg_data);
                 print_message('5 p_start_date: ' || p_start_date);
                 print_message('5 p_end_date: ' || p_end_date);

             END IF;

             IF lv_return_status = FND_API.G_RET_STS_SUCCESS THEN

                -- Build Day FI

                Print_message( 'Res Avl - Calling Build_Day_FI');

                Build_Day_FI   ( TmpResScheduleTab , p_start_date, p_end_date,
                                 TmpResFIDayTab, lv_asgn_type, lv_return_status, x_msg_count, x_msg_data );
                 print_message('6 p_start_date: ' || p_start_date);
                 print_message('6 p_end_date: ' || p_end_date);
             END IF;

             IF lv_return_status = FND_API.G_RET_STS_SUCCESS THEN

                Print_message( 'Calling Get_Resource_Asgn_Schedule');

                PA_FORECAST_ITEMS_UTILS.Get_Resource_Asgn_Schedules (
                                          p_resource_id,
                                          p_start_date,
                                          p_end_date ,
                                          TmpAsgnScheduleTab,
                                          lv_return_status ,
                                          x_msg_count,
                                          x_msg_data);
                 print_message('7 p_start_date: ' || p_start_date);
                 print_message('7 p_end_date: ' || p_end_date);
             END IF;

		/** Bug : 1993136  **/

		IF TmpAsgnScheduleTab.Count > 0 THEN
			lb_found := False;

			FOR i IN TmpAsgnScheduleTab.first..TmpAsgnScheduleTab.last LOOP
        if TmpAsgnScheduleTab.exists(i) then
				print_message('TmpAsgnScheduleTab(i).start_date='||
						TmpAsgnScheduleTab(i).start_date||
						'TmpAsgnScheduleTab(i).end_date ='||
						TmpAsgnScheduleTab(i).end_date);

				IF TmpAsgnScheduleTab(i).start_date < p_start_date THEN
					TmpAsgnScheduleTab(i).start_date := p_start_date;
				END IF;

				-- Adjust the end date in Asgmt Scheudule
				IF TRUNC(TmpAsgnScheduleTab(i).start_date) > TRUNC(p_end_date) AND
				   TRUNC(TmpAsgnScheduleTab(i).end_date) > TRUNC(p_end_date) THEN

					print_message('deleteing TmpAsgnScheduleTab.delete');
					TmpAsgnScheduleTab.delete(i);
					lb_found := True;

				ELSIF TRUNC(TmpAsgnScheduleTab(I).end_date) > TRUNC(p_end_date) THEN
					TmpAsgnScheduleTab(i).end_date :=  p_end_date;
				END IF;
      end if;
			END LOOP;

			IF lb_found Then
				refresh_assgn_schedule_tab(TmpAsgnScheduleTab,TmpAsgnScheduleTab);
			End if;
		END IF;

		/** end of bug fix 1993136 **/


             IF lv_return_status = FND_API.G_RET_STS_SUCCESS THEN

                IF TmpAsgnScheduleTab.Count > 0 THEN

                   Print_message(
                            'Res Asg - Calling Initialize_Day_FI');

                   Initialize_Day_FI   ( TmpAsgnScheduleTab,
                                      p_process_mode,
                                      p_start_date,
                                      p_end_date,
                                      TmpAsgnFIDayTab ,
                                      lv_return_status , x_msg_count ,
                                      x_msg_data);
                END IF;

             END IF;

             IF lv_return_status = FND_API.G_RET_STS_SUCCESS THEN

                Print_message( 'Res Asg - Calling Build_Day_FI');

                IF TmpAsgnScheduleTab.Count > 0 THEN

                    Build_Day_FI   ( TmpAsgnScheduleTab ,
                                     p_start_date,
                                     p_end_date,
                                     TmpAsgnFIDayTab, lv_asgn_type,
                                     lv_return_status,
                                     x_msg_count,
                                     x_msg_data );
                END IF;

             END IF;
             -- Calculate resource availability hours i.e unassigned hours

--           dbms_output.put_line ('Res : ' ||
--                         TmpResFIDayTab(TmpResFIDayTab.FIRST).item_date);
--           dbms_output.put_line ('Res : ' ||
--                         TmpResFIDayTab(TmpResFIDayTab.LAST).item_date);
--           dbms_output.put_line ('Asgn : ' ||
--                         TmpResFIDayTab(TmpAsgnFIDayTab.FIRST).item_date);
--           dbms_output.put_line ('Asgn : ' ||
--                         TmpResFIDayTab(TmpAsgnFIDayTab.LAST).item_date);

             IF lv_return_status = FND_API.G_RET_STS_SUCCESS THEN

                li_no_of_days := trunc(p_end_date) - trunc(p_start_date) +1;

                if (TmpResFIDayTab.count <> 0) then
                FOR i IN TmpResFIDayTab.FIRST ..TmpResFIDayTab.LAST LOOP
                    if TmpResFIDayTab.exists(i) then


                    TmpAvlFIDayTab(i).item_date := TmpResFIDayTab(i).item_date;
                    TmpAvlFIDayTab(i).action_flag := 'N';

                    IF (i > TmpAsgnFIDayTab.COUNT) THEN

                       li_asgn_qty  := 0;
                       li_conf_asgn_qty := 0;
                       li_prov_asgn_qty := 0;
                    ELSE

                       li_asgn_qty  := TmpAsgnFIDayTab(i).item_quantity;
                       li_conf_asgn_qty := NVL(TmpAsgnFIDayTab(i).asgmt_confirmed_quantity,0);
                       li_prov_asgn_qty := NVL(TmpAsgnFIDayTab(i).asgmt_provisional_quantity,0);
                    END IF;

                    TmpAvlFIDayTab(i).item_quantity :=
                        NVL(TmpResFIDayTab(i).item_quantity,0) - li_asgn_qty;

                    IF TmpAvlFIDayTab(i).item_quantity < 0 THEN

                       TmpAvlFIDayTab(i).item_quantity := 0;

                    END IF;

                    TmpAvlFIDayTab(i).capacity_quantity := NVL(TmpResFIDayTab(i).item_quantity,0);

                    if (NVL(li_prov_asgn_qty,0) = 0) THEN
 		                   TmpAvlFIDayTab(i).provisional_qty := NULL;
                    else
                       TmpAvlFIDayTab(i).provisional_qty := li_prov_asgn_qty;
                    end if;

                    if (NVL(li_conf_asgn_qty,0) = 0) THEN
 		                   TmpAvlFIDayTab(i).confirmed_qty := NULL;
                    else
                       TmpAvlFIDayTab(i).confirmed_qty := li_conf_asgn_qty;
                    end if;

                    if (NVL(li_conf_asgn_qty,0) > NVL(TmpResFIDayTab(i).item_quantity,0)) then
                         TmpAvlFIDayTab(i).overcommitment_quantity := NVL(li_conf_asgn_qty,0) -
                                      NVL(TmpResFIDayTab(i).item_quantity,0);
                         TmpAvlFIDayTab(i).availability_quantity := 0;
                         TmpAvlFIDayTab(i).overcommitment_flag := 'Y';
                         TmpAvlFIDayTab(i).availability_flag := 'N';
                    elsif (NVL(li_conf_asgn_qty,0) < NVL(TmpResFIDayTab(i).item_quantity,0)) then
                         TmpAvlFIDayTab(i).availability_quantity := NVL(TmpResFIDayTab(i).item_quantity,0) -
                                      NVL(li_conf_asgn_qty,0);
                         TmpAvlFIDayTab(i).overcommitment_quantity := 0;
                         TmpAvlFIDayTab(i).overcommitment_flag := 'N';
                         TmpAvlFIDayTab(i).availability_flag := 'Y';
                    else
                         TmpAvlFIDayTab(i).availability_quantity := 0;
                         TmpAvlFIDayTab(i).overcommitment_quantity := 0;
                         TmpAvlFIDayTab(i).overcommitment_flag := 'N';
                         TmpAvlFIDayTab(i).availability_flag := 'N';
                    end if;

                    if (NVL(TmpAvlFIDayTab(i).overcommitment_quantity,0) = 0) then
                       TmpAvlFIDayTab(i).overcommitment_qty := null;
                    else
                       TmpAvlFIDayTab(i).overcommitment_qty := TmpAvlFIDayTab(i).overcommitment_quantity;
                    end if;

                    if (NVL(li_prov_asgn_qty,0) >
                           nvl(TmpAvlFIDayTab(i).capacity_quantity,0)) THEN
                       TmpAvlFIDayTab(i).OVERPROVISIONAL_QTY :=
                           NVL(li_prov_asgn_qty,0) -
                              NVL(TmpAvlFIDayTab(i).capacity_quantity,0);
	                  else
                       TmpAvlFIDayTab(i).OVERPROVISIONAL_QTY := NULL;
                    end if;

                    if (NVL(li_prov_asgn_qty,0) + NVL(li_conf_asgn_qty,0) >
                           nvl(TmpAvlFIDayTab(i).capacity_quantity,0)) THEN
                       TmpAvlFIDayTab(i).OVER_PROV_CONF_QTY :=
                           NVL(li_prov_asgn_qty,0) + NVL(li_conf_asgn_qty,0) -
                              NVL(TmpAvlFIDayTab(i).capacity_quantity,0);
	                  else
                       TmpAvlFIDayTab(i).OVER_PROV_CONF_QTY := NULL;
                    end if;

                end if;
                END LOOP;
                end if;

                -- Get existing forecast items detail FOR this resource
                -- which fall BETWEEN startdate AND END DATE

                TmpFIHdrInsTab.delete; -- Initialize
                TmpFIHdrUpdTab.delete; -- Initialize
                TmpFIDtlInsTab.delete; -- Initialize
                TmpFIDtlUpdTab.delete; -- Initialize
                TmpDBFIHdrTab.delete;  -- Initialize
                TmpDBFIDtlTab.delete;  -- Initialize


                IF p_process_mode <> 'ERROR' THEN

                   IF lv_return_status = FND_API.G_RET_STS_SUCCESS THEN

                      Print_message( 'Calling Fetch_FI_Hdr_Res');

                      Fetch_FI_Hdr_Res (p_resource_id,
                                     p_start_date, p_end_date,
                                     TmpDBFIHdrTab,
                                     lv_return_status,  x_msg_count, x_msg_data);
                   END IF;

                ELSE
                   print_message('JM:1000');
                   TmpDBFIHdrTab := p_ErrHdrTab;

                END IF;

             END IF;

             IF lv_return_status = FND_API.G_RET_STS_SUCCESS THEN

                Print_message( 'Calling Fetch_FI_Dtl_Res');

               /**  Bug fix : 1913377 call changed to  positional notation
			Fetch_FI_Dtl_Res (p_resource_id,
                               p_start_date,
                               p_end_date, TmpDbFIDtlTab,
                               lv_return_status,  x_msg_count, x_msg_data);
		***/

   		Fetch_FI_Dtl_Res(
                  p_resource_id      => p_resource_id
                  ,p_start_date      => p_start_date
                  ,p_end_date        => p_end_date
                  ,x_dbFIDtlTab      => TmpDbFIDtlTab
                  ,x_return_status   => lv_return_status
                  ,x_msg_count       => x_msg_count
                  ,x_msg_data        => x_msg_data );


             END IF;

             -- Header Processing
             -- Inputs : TmpFIDayTab, TmpDBFIHdrTab, p_resource_id
             -- Get new values FOR expenditure_ou,
             -- expenditure_organization, expenditure_type,
             -- expenditure_type_class, borrowed flag
             -- IF item_date exists
                   -- check above values with existing values
                   -- IF differs
                         -- update header FOR delete_flag
                         -- Create new forecast_item_header
                         -- Mark action_flag = 'DN';
                         -- Save new forecast_item_id IN TmpFIDayTab
                   -- ELSE
                         --  Check FOR qty change
                         -- IF differs
                               -- update item_quantity IN header with
                               -- new value
                               -- Mark action_flag = 'RN';
                         -- ELSE
                               -- Mark action_flag = 'C';
                               -- Meaning values FOR attributes associated
                               -- with detail table have to be checked for
                               -- change
             -- ELSE (item_date does not exist)
                   -- Create new forecast_item
                   -- Mark action_flag = 'N';

             IF lv_return_status = FND_API.G_RET_STS_SUCCESS THEN

                Print_message( 'Calling Build_FI_Hdr_Res');

                Build_FI_Hdr_Res(p_resource_id, p_start_date, p_end_date,
                              TmpAvlFIDayTab,TmpDBFIHdrTab,
                              TmpFIHdrInsTab, TmpFIHdrUpdTab,
                              lv_return_status,  x_msg_count, x_msg_data);

             END IF;

             -- Detail Processing
             -- Inputs : TmpFIDayTab, TmpDBFIDtlTab, p_resource_id
             -- TmpFIDayTab.Action_flag is updated by header process.
             -- IF action_flag = 'C'
                   -- check FOR change IN resource_type_code,
                   -- person_billable_flag, include IN forecast option,
                   -- provisional_flag, work_type_id
                   -- If there is change mark action_flag = 'RN';
             -- IF action_flag = 'DN'
                   --Header record has changed
                   -- Reverse detail record
                   -- Create new detail record with forecast_item_id
                   -- (generated by header record, saved IN TmpFIDayTab)
                   --  AND line_NUMBER = 1;
             -- IF action_flag = 'RN'
                   -- Change IN detail record values
                   -- Reverse detail record
                   -- create new detail record with same forecast_item_id
                   -- AND line_NUMBER = max(line_NUMBER) + 1;
             -- IF action_flag = 'N'
                   -- Create new detail record with forecast_item_id
                   -- (generated by header record, saved IN TmpFIDayTab)
                   --  AND line_NUMBER = 1;
             IF lv_return_status = FND_API.G_RET_STS_SUCCESS THEN

                Print_message( 'Calling Build_FI_Dtl_Res');

                Build_FI_Dtl_Res(p_resource_id, TmpDBFIDtlTab, TmpAvlFIDayTab,
                              TmpFIDtlInsTab, TmpFIDtlUpdTab,
                              lv_return_status,  x_msg_count, x_msg_data);

             END IF;

             IF lv_return_status = FND_API.G_RET_STS_SUCCESS THEN

                IF TmpFIHdrInsTab.COUNT > 0 THEN

                    Print_message( 'Calling PA_FORECAST_HDR_PKG.Insert_Rows');

                    PA_FORECAST_HDR_PKG.Insert_Rows(TmpFIHdrInsTab,
                                                    lv_return_status,
                                                    x_msg_count,
                                                    x_msg_data);
                END IF;

             END IF;

             IF lv_return_status = FND_API.G_RET_STS_SUCCESS THEN

                IF TmpFIHdrUpdTab.COUNT > 0 THEN

                   Print_message( 'Calling PA_FORECAST_HDR_PKG.Update_Rows');

                   PA_FORECAST_HDR_PKG.Update_Rows(TmpFIHdrUpdTab, lv_return_status,
                                                   x_msg_count, x_msg_data);
                   PRINT_MESSAGE(x_return_status || ' ' || lv_return_status);

                END IF;

             END IF;

             PRINT_MESSAGE(x_return_status || ' ' || lv_return_status);
             IF lv_return_status = FND_API.G_RET_STS_SUCCESS THEN

                IF TmpFIDtlInsTab.COUNT > 0 THEN

                   Print_message( 'Calling PA_FORECAST_DTLS_PKG.Insert_Rows');

                   PA_FORECAST_DTLS_PKG.Insert_Rows(TmpFIDtlInsTab, lv_return_status,
                                                x_msg_count,
                                                x_msg_data);
                   PRINT_MESSAGE(x_return_status || ' ' || lv_return_status);

                END IF;

             END IF;

             PRINT_MESSAGE(x_return_status || ' ' || lv_return_status);
             IF lv_return_status = FND_API.G_RET_STS_SUCCESS THEN

                IF TmpFIDtlUpdTab.COUNT > 0 THEN

                   Print_message( 'Calling PA_FORECAST_DTLS_PKG.Update_Rows');

                   PA_FORECAST_DTLS_PKG.Update_Rows(TmpFIDtlUpdTab,
                                                lv_return_status,
                                                x_msg_count,
                                                x_msg_data);
                   PRINT_MESSAGE(x_return_status || ' ' || lv_return_status);
                END IF;

             END IF;

         ----------------------------------------------------------------------------
         ----------------BEGIN AVAILABILITY SUMMARY TABLE POPULATION-----------------

         IF lv_return_status = FND_API.G_RET_STS_SUCCESS THEN

             Print_message( 'Calling PA_RESOURCE_PVT.update_res_availability');

             PA_RESOURCE_PVT.update_res_availability (
               p_resource_id   => p_resource_id,
               p_start_date    => p_start_date,
               p_end_date      => p_end_date,
               x_return_status => lv_return_status,
               x_msg_data      => x_msg_data,
               x_msg_count     => x_msg_count);

             PRINT_MESSAGE(x_return_status || ' ' || lv_return_status);

         END IF;

         ------------------END AVAILABILITY SUMMARY TABLE POPULATION-----------------
         ----------------------------------------------------------------------------

	     /** once the process is completed release the lock  **/
             li_lock_status := PA_FORECAST_ITEMS_UTILS.Release_User_lock(p_resource_id, 'RES');
             Print_message('Resource lock released ');

       END IF;

       Print_message('Leaving Regenerate_Res_Unassigned_FI');

       PRINT_MESSAGE(x_return_status || ' ' || lv_return_status);
       PA_DEBUG.Reset_Err_Stack;

       PRINT_MESSAGE(x_return_status || ' ' || lv_return_status);
       x_return_status := lv_return_status;

     EXCEPTION
             WHEN l_no_fis_to_create THEN
                  -- There are no FIs to create.
                  PA_DEBUG.Reset_Err_Stack;
                  x_return_status := lv_return_status;
		              -- release the lock
                  li_lock_status := PA_FORECAST_ITEMS_UTILS.Release_User_lock(p_resource_id, 'RES');
                  Print_message('Resource lock released ');

             WHEN NO_DATA_FOUND THEN

                IF lv_err_msg = 'No_Schedule_Records - Res' THEN

                    Print_message(
                             'NO schedule records');

                    x_msg_count     := 1;
                    x_msg_data      := 'No Schedule Records for Res ';
                    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

		    -- 4537865
		    p_start_date := NULL ;
		   p_end_date := NULL ;

                    FND_MSG_PUB.add_exc_msg
                        (p_pkg_name   =>
                           'PA_FORECASTITEM_PVT.Regenerate_Res_Unassigned_FI',
                         p_procedure_name => PA_DEBUG.G_Err_Stack);

		               If x_msg_count = 1 THEN
				              pa_interface_utils_pub.get_messages
				                (p_encoded        => FND_API.G_TRUE,
					               p_msg_index      => 1,
					               p_msg_count      => x_msg_count,
					               p_msg_data       => x_msg_data,
					               p_data           => l_data , -- 4537865
					               p_msg_index_out  => l_msg_index_out );
						x_msg_data := l_data ; -- 4537865
		               End If;
                    Print_message(x_msg_data);

                    RAISE;

                ELSE

                  x_msg_count     := 1;
                  x_msg_data      := sqlerrm;
                  x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

		  -- 4537865
		  p_start_date := NULL ;
		  p_end_date := NULL ;

                  FND_MSG_PUB.add_exc_msg
                      (p_pkg_name   =>
                          'PA_FORECASTITEM_PVT.Regenerate_Res_Unassigned_FI',
                       p_procedure_name => PA_DEBUG.G_Err_Stack);

		               If x_msg_count = 1 THEN
				              pa_interface_utils_pub.get_messages
				                (p_encoded        => FND_API.G_TRUE,
					               p_msg_index      => 1,
					               p_msg_count      => x_msg_count,
					               p_msg_data       => x_msg_data,
					               p_data           => l_data ,  -- 4537865
					               p_msg_index_out  => l_msg_index_out );
					 x_msg_data := l_data ; -- 4537865
		               End If;
                  Print_message(x_msg_data);

                  RAISE;

                END IF;
		/** lock should be released if the process fails **/
	        li_lock_status := PA_FORECAST_ITEMS_UTILS.Release_User_lock(p_resource_id, 'RES');
                Print_message('Resouce lock released ');

            WHEN l_cannot_acquire_lock THEN

                 Print_message(
                    'Unable to set lock for ' || to_char(p_resource_id));

                 x_msg_count     := 1;
                 x_msg_data      := 'Resource ID Lock Failure';
                 x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

		    -- 4537865
		 p_start_date := NULL ;
		 p_end_date := NULL ;

                 FND_MSG_PUB.add_exc_msg
                      (p_pkg_name   =>
                          'PA_FORECASTITEM_PVT.Regenerate_Res_Unassigned_FI',
                       p_procedure_name => PA_DEBUG.G_Err_Stack);

		               If x_msg_count = 1 THEN
				              pa_interface_utils_pub.get_messages
				                (p_encoded        => FND_API.G_TRUE,
					               p_msg_index      => 1,
					               p_msg_count      => x_msg_count,
					               p_msg_data       => x_msg_data,
					               p_data           => l_data,  -- 4537865
					               p_msg_index_out  => l_msg_index_out );
						       x_msg_data := l_data ; -- 4537865
		               End If;
                 Print_message(x_msg_data);

                 RAISE;


            WHEN OTHERS THEN

                  x_msg_count     := 1;
                  x_msg_data      := sqlerrm;
                  x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
		  /** release the lock if the process fails **/
                  li_lock_status := PA_FORECAST_ITEMS_UTILS.Release_User_lock(p_resource_id, 'RES');
                  Print_message('Resource lock released ');

		     -- 4537865
		   p_start_date := NULL ;
		    p_end_date := NULL ;

		               If x_msg_count = 1 THEN
				              pa_interface_utils_pub.get_messages
				                (p_encoded        => FND_API.G_TRUE,
					               p_msg_index      => 1,
					               p_msg_count      => x_msg_count,
					               p_msg_data       => x_msg_data,
					               p_data           => l_data,  -- 4537865
					               p_msg_index_out  => l_msg_index_out );
						     x_msg_data := l_data ; -- 4537865
		               End If;
                  FND_MSG_PUB.add_exc_msg
                      (p_pkg_name   =>
                          'PA_FORECASTITEM_PVT.Regenerate_Res_Unassigned_FI',
                       p_procedure_name => PA_DEBUG.G_Err_Stack);

                  RAISE;


       END  Regenerate_Res_Unassigned_FI;

/* ---------------------------------------------------------------------
|   Procedure  :   Fetch_FI_Hdr_Res
|   Purpose    :   To get existing forecast items (Resource Unassigned time)
|                  FOR the given resource ID which fall BETWEEN
|                  startdate AND END DATE
|   Parameters :   p_resource_id    - Input Resource ID
|                  p_start_date     - Current Start DATE FOR forecast item
|                  p_end_date       - Current END DATE FOR forecast item
|                  x_dbFIHdrTab     - Holds the data retrieved FROM the database
|                  x_return_status     -
|                  x_msg_count         -
|                  x_msg_data          -
+----------------------------------------------------------------------*/

       PROCEDURE  Fetch_FI_Hdr_Res(
                  p_resource_id      IN    NUMBER,
                  p_start_date       IN    DATE,
                  p_end_date         IN    DATE,
                  x_dbFIHdrTab       OUT   NOCOPY PA_FORECAST_GLOB.FIHdrTabTyp, /* 2674619 - Nocopy change */
                  x_return_status    OUT   NOCOPY VARCHAR2, -- 4537865
                  x_msg_count        OUT   NOCOPY NUMBER, -- 4537865
                  x_msg_data         OUT   NOCOPY VARCHAR2) IS -- 4537865


	           l_msg_index_out	            NUMBER;
		   l_data varchar2(2000); -- 4537865
             forecast_item_id_tab                PA_FORECAST_GLOB.NumberTabTyp;
             forecast_item_type_tab              PA_FORECAST_GLOB.VCTabTyp;
             project_org_id_tab                  PA_FORECAST_GLOB.NumberTabTyp;
             expenditure_org_id_tab              PA_FORECAST_GLOB.NumberTabTyp;
             expenditure_orgn_id_tab             PA_FORECAST_GLOB.NumberTabTyp;
             project_organization_id_tab         PA_FORECAST_GLOB.NumberTabTyp;
             project_id_tab                      PA_FORECAST_GLOB.NumberTabTyp;
             project_type_class_tab              PA_FORECAST_GLOB.VCTabTyp;
             person_id_tab                       PA_FORECAST_GLOB.NumberTabTyp;
             resource_id_tab                     PA_FORECAST_GLOB.NumberTabTyp;
             borrowed_flag_tab                   PA_FORECAST_GLOB.VC1TabTyp;
             assignment_id_tab                   PA_FORECAST_GLOB.NumberTabTyp;
             item_date_tab                       PA_FORECAST_GLOB.DateTabTyp;
             item_uom_tab                        PA_FORECAST_GLOB.VCTabTyp;
             item_quantity_tab                   PA_FORECAST_GLOB.NumberTabTyp;
             pvdr_period_set_name_tab            PA_FORECAST_GLOB.VCTabTyp;
             pvdr_pa_period_name_tab             PA_FORECAST_GLOB.VCTabTyp;
             pvdr_gl_period_name_tab             PA_FORECAST_GLOB.VCTabTyp;
             rcvr_period_set_name_tab            PA_FORECAST_GLOB.VCTabTyp;
             rcvr_pa_period_name_tab             PA_FORECAST_GLOB.VCTabTyp;
             rcvr_gl_period_name_tab             PA_FORECAST_GLOB.VCTabTyp;
             global_exp_period_end_date_tab      PA_FORECAST_GLOB.DateTabTyp;
             expenditure_type_tab                PA_FORECAST_GLOB.VCTabTyp;
             expenditure_type_class_tab          PA_FORECAST_GLOB.VCTabTyp;
             cost_rejection_code_tab             PA_FORECAST_GLOB.VCTabTyp;
             rev_rejection_code_tab              PA_FORECAST_GLOB.VCTabTyp;
             tp_rejection_code_tab               PA_FORECAST_GLOB.VCTabTyp;
             burden_rejection_code_tab           PA_FORECAST_GLOB.VCTabTyp;
             other_rejection_code_tab            PA_FORECAST_GLOB.VCTabTyp;
             delete_flag_tab                     PA_FORECAST_GLOB.VC1TabTyp;
             error_flag_tab                      PA_FORECAST_GLOB.VC1TabTyp;
             provisional_flag_tab                PA_FORECAST_GLOB.VC1TabTyp;
             JOB_ID_tab           PA_FORECAST_GLOB.NumberTabTyp;
             TP_AMOUNT_TYPE_tab           PA_FORECAST_GLOB.VCTabTyp;
             OVERPROVISIONAL_QTY_tab           PA_FORECAST_GLOB.NumberTabTyp;
             OVER_PROV_CONF_QTY_tab           PA_FORECAST_GLOB.NumberTabTyp;
             CONFIRMED_QTY_tab           PA_FORECAST_GLOB.NumberTabTyp;
             PROVISIONAL_QTY_tab           PA_FORECAST_GLOB.NumberTabTyp;
             asgmt_sys_status_code_tab           PA_FORECAST_GLOB.VCTabTyp;
             capacity_quantity_tab               PA_FORECAST_GLOB.NumberTabTyp;
             overcommitment_quantity_tab         PA_FORECAST_GLOB.NumberTabTyp;
             availability_quantity_tab           PA_FORECAST_GLOB.NumberTabTyp;
             overcommitment_flag_tab             PA_FORECAST_GLOB.VC1TabTyp;
             availability_flag_tab               PA_FORECAST_GLOB.VC1TabTyp;

             TmpHdrTab                           PA_FORECAST_GLOB.FIHdrTabTyp;

             lv_return_status                    VARCHAR2(30);

       BEGIN

             lv_return_status := FND_API.G_RET_STS_SUCCESS;

             Print_message('Entering Fetch_FI_Hdr_Res');

             PA_DEBUG.Init_err_stack( 'PA_FORECASTITEM_PVT.Fetch_FI_Hdr_Res');

             TmpHdrTab.delete;
             forecast_item_id_tab.delete;
             forecast_item_type_tab.delete;
             project_org_id_tab.delete;
             expenditure_org_id_tab.delete;
             expenditure_orgn_id_tab.delete;
             project_organization_id_tab.delete;
             project_id_tab.delete;
             project_type_class_tab.delete;
             person_id_tab.delete;
             resource_id_tab.delete;
             borrowed_flag_tab.delete;
             assignment_id_tab.delete;
             item_date_tab.delete;
             item_uom_tab.delete;
             item_quantity_tab.delete;
             pvdr_period_set_name_tab.delete;
             pvdr_pa_period_name_tab.delete;
             pvdr_gl_period_name_tab.delete;
             rcvr_period_set_name_tab.delete;
             rcvr_pa_period_name_tab.delete;
             rcvr_gl_period_name_tab.delete;
             global_exp_period_end_date_tab.delete;
             expenditure_type_tab.delete;
             expenditure_type_class_tab.delete;
             cost_rejection_code_tab.delete;
             rev_rejection_code_tab.delete;
             tp_rejection_code_tab.delete;
             burden_rejection_code_tab.delete;
             other_rejection_code_tab.delete;
             delete_flag_tab.delete;
             error_flag_tab.delete;
             provisional_flag_tab.delete;
             JOB_ID_tab.delete;
             TP_AMOUNT_TYPE_tab.delete;
             OVERPROVISIONAL_QTY_tab.delete;
             OVER_PROV_CONF_QTY_tab.delete;
             CONFIRMED_QTY_tab.delete;
             PROVISIONAL_QTY_tab.delete;
             asgmt_sys_status_code_tab.delete;
             capacity_quantity_tab.delete;
             overcommitment_quantity_tab.delete;
             availability_quantity_tab.delete;
             overcommitment_flag_tab.delete;
             availability_flag_tab.delete;

             SELECT   forecast_item_id, forecast_item_type,
                      project_org_id , expenditure_org_id,
                      project_organization_id, expenditure_organization_id ,
                      project_id, project_type_class, person_id ,
                      resource_id, borrowed_flag, assignment_id,
                      item_date, item_uom, item_quantity,
                      pvdr_period_set_name, pvdr_pa_period_name,
                      pvdr_gl_period_name, rcvr_period_set_name,
                      rcvr_pa_period_name, rcvr_gl_period_name,
                      global_exp_period_end_date, expenditure_type,
                      expenditure_type_class, cost_rejection_code,
                      rev_rejection_code, tp_rejection_code,
                      burden_rejection_code, other_rejection_code,
                      delete_flag, error_flag, provisional_flag,
                      JOB_ID,
                      TP_AMOUNT_TYPE,
                      OVERPROVISIONAL_QTY,
                      OVER_PROV_CONF_QTY,
                      CONFIRMED_QTY,
                      PROVISIONAL_QTY,
                      asgmt_sys_status_code, capacity_quantity,
                      overcommitment_quantity, availability_quantity,
                      overcommitment_flag, availability_flag
             BULK COLLECT INTO forecast_item_id_tab, forecast_item_type_tab,
                      project_org_id_tab, expenditure_org_id_tab,
                      project_organization_id_tab, expenditure_orgn_id_tab,
                      project_id_tab, project_type_class_tab, person_id_tab,
                      resource_id_tab, borrowed_flag_tab, assignment_id_tab,
                      item_date_tab, item_uom_tab, item_quantity_tab,
                      pvdr_period_set_name_tab, pvdr_pa_period_name_tab,
                      pvdr_gl_period_name_tab, rcvr_period_set_name_tab,
                      rcvr_pa_period_name_tab, rcvr_gl_period_name_tab,
                      global_exp_period_end_date_tab, expenditure_type_tab,
                      expenditure_type_class_tab, cost_rejection_code_tab,
                      rev_rejection_code_tab, tp_rejection_code_tab,
                      burden_rejection_code_tab, other_rejection_code_tab,
                      delete_flag_tab, error_flag_tab, provisional_flag_tab,
                      JOB_ID_tab,
                      TP_AMOUNT_TYPE_tab,
                      OVERPROVISIONAL_QTY_tab,
                      OVER_PROV_CONF_QTY_tab,
                      CONFIRMED_QTY_tab,
                      PROVISIONAL_QTY_tab,
                      asgmt_sys_status_code_tab, capacity_quantity_tab,
                      overcommitment_quantity_tab, availability_quantity_tab,
                      overcommitment_flag_tab, availability_flag_tab
             FROM   pa_forecast_items
             WHERE  resource_id = p_resource_id
             AND    forecast_item_type = 'U'
             AND    delete_flag   = 'N'
           /* Commented for bug3998166
             AND    trunc(item_date) BETWEEN trunc(p_start_date) AND
                                             trunc(p_end_date) */
             AND    item_date BETWEEN trunc(p_start_date) AND
                                      (trunc(p_end_date)+ 0.99999)
             order by item_date, forecast_item_id ;


             IF forecast_item_id_tab.COUNT = 0 THEN

                Print_message('Leaving Fetch_FI_Hdr_Res');

                x_return_status := lv_return_status;

                RETURN;

             END IF;

              -- Move to one table FROM multiple tables

             FOR j IN forecast_item_id_tab.FIRST..forecast_item_id_tab.LAST LOOP

                 TmpHdrTab(j).forecast_item_id := forecast_item_id_tab(j);
                 TmpHdrTab(j).forecast_item_type := forecast_item_type_tab(j);
                 TmpHdrTab(j).project_org_id  := project_org_id_tab(j);
                 TmpHdrTab(j).expenditure_org_id := expenditure_org_id_tab(j);
                 TmpHdrTab(j).project_organization_id :=
                                          project_organization_id_tab(j);
                 TmpHdrTab(j).expenditure_organization_id  :=
                                          expenditure_orgn_id_tab(j);
                 TmpHdrTab(j).project_id := project_id_tab(j);
                 TmpHdrTab(j).project_type_class := project_type_class_tab(j);
                 TmpHdrTab(j).person_id  := person_id_tab(j);
                 TmpHdrTab(j).resource_id := resource_id_tab(j);
                 TmpHdrTab(j).borrowed_flag := borrowed_flag_tab(j);
                 TmpHdrTab(j).assignment_id := assignment_id_tab(j);
                 TmpHdrTab(j).item_date := item_date_tab(j);
                 TmpHdrTab(j).item_uom := item_uom_tab(j);
                 TmpHdrTab(j).item_quantity := item_quantity_tab(j);
                 TmpHdrTab(j).pvdr_period_set_name :=
                                          pvdr_period_set_name_tab(j);
                 TmpHdrTab(j).pvdr_pa_period_name := pvdr_pa_period_name_tab(j);
                 TmpHdrTab(j).pvdr_gl_period_name := pvdr_gl_period_name_tab(j);
                 TmpHdrTab(j).rcvr_period_set_name :=
                                          rcvr_period_set_name_tab(j);
                 TmpHdrTab(j).rcvr_pa_period_name := rcvr_pa_period_name_tab(j);
                 TmpHdrTab(j).rcvr_gl_period_name := rcvr_gl_period_name_tab(j);
                 TmpHdrTab(j).global_exp_period_end_date :=
                                         global_exp_period_end_date_tab(j);
                 TmpHdrTab(j).expenditure_type := expenditure_type_tab(j);
                 TmpHdrTab(j).expenditure_type_class :=
                                          expenditure_type_class_tab(j);
                 TmpHdrTab(j).cost_rejection_code := cost_rejection_code_tab(j);
                 TmpHdrTab(j).rev_rejection_code := rev_rejection_code_tab(j);
                 TmpHdrTab(j).tp_rejection_code := tp_rejection_code_tab(j);
                 TmpHdrTab(j).burden_rejection_code :=
                                          burden_rejection_code_tab(j);
                 TmpHdrTab(j).other_rejection_code :=
                                          other_rejection_code_tab(j);
                 TmpHdrTab(j).delete_flag := delete_flag_tab(j);
                 TmpHdrTab(j).error_flag := error_flag_tab(j);
                 TmpHdrTab(j).provisional_flag := provisional_flag_tab(j);
                 TmpHdrTab(j).JOB_ID := JOB_ID_tab(j);
                 TmpHdrTab(j).TP_AMOUNT_TYPE := TP_AMOUNT_TYPE_tab(j);
                 TmpHdrTab(j).OVERPROVISIONAL_QTY := OVERPROVISIONAL_QTY_tab(j);
                 TmpHdrTab(j).OVER_PROV_CONF_QTY := OVER_PROV_CONF_QTY_tab(j);
                 TmpHdrTab(j).CONFIRMED_QTY := CONFIRMED_QTY_tab(j);
                 TmpHdrTab(j).PROVISIONAL_QTY := PROVISIONAL_QTY_tab(j);
                 TmpHdrTab(j).asgmt_sys_status_code := asgmt_sys_status_code_tab(j);
                 TmpHdrTab(j).capacity_quantity := capacity_quantity_tab(j);
                 TmpHdrTab(j).overcommitment_quantity :=  overcommitment_quantity_tab(j);
                 TmpHdrTab(j).availability_quantity :=  availability_quantity_tab(j);
                 TmpHdrTab(j).overcommitment_flag := overcommitment_flag_tab(j);
                 TmpHdrTab(j).availability_flag := availability_flag_tab(j);

             END LOOP;

             x_dbFIHdrTab := TmpHdrTab;


             Print_message('Leaving Fetch_FI_Hdr_Res');

             PA_DEBUG.Reset_Err_Stack;

             x_return_status := lv_return_status;


       EXCEPTION

              WHEN OTHERS THEN
                  print_message('Failed in Fetch_FI_Hdr_Res api');
                  print_message('SQLCODE'||sqlcode||sqlerrm);

                  x_msg_count     := 1;
                  x_msg_data      := sqlerrm;
                  x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

                  FND_MSG_PUB.add_exc_msg
                      (p_pkg_name   =>
                              'PA_FORECASTITEM_PVT.Fetch_FI_Hdr_Res',
                       p_procedure_name => PA_DEBUG.G_Err_Stack);

		               If x_msg_count = 1 THEN
				              pa_interface_utils_pub.get_messages
				                (p_encoded        => FND_API.G_TRUE,
					               p_msg_index      => 1,
					               p_msg_count      => x_msg_count,
					               p_msg_data       => x_msg_data,
					               p_data           => l_data , -- 4537865
					               p_msg_index_out  => l_msg_index_out );
						x_msg_data := l_data ; -- 4537865
		               End If;
                  Print_message(x_msg_data);

                  RAISE;


       END  Fetch_FI_Hdr_Res;


/* ---------------------------------------------------------------------
|   Procedure  :   Fetch_FI_Dtl_Res
|   Purpose    :   To get existing forecast item details
|                  (Resource Unassigned time)FOR the given resource ID
|                  which fall BETWEEN startdate AND END DATE
|   Parameters :   p_resource_id    - Input Resource ID
|                  p_start_date     - Current Start DATE FOR forecast item
|                  p_end_date       - Current END DATE FOR forecast item
|                  x_dbFIHdrTab     - Holds the data retrieved FROM the database
|                  x_return_status     -
|                  x_msg_count         -
|                  x_msg_data          -
+----------------------------------------------------------------------*/
       PROCEDURE  Fetch_FI_Dtl_Res(
                  p_resource_id     IN    NUMBER,
                  p_start_date       IN    DATE,
                  p_end_date         IN    DATE,
                  x_dbFIDtlTab       OUT   NOCOPY PA_FORECAST_GLOB.FIDtlTabTyp, /* 2674619 - Nocopy change */
                  x_return_status  OUT  NOCOPY  VARCHAR2, -- 4537865
                  x_msg_count      OUT  NOCOPY NUMBER, -- 4537865
                  x_msg_data       OUT  NOCOPY VARCHAR2) IS -- 4537865



	           l_msg_index_out	            NUMBER;
		   l_data varchar2(2000); -- 4537865

             forecast_item_id_tab            PA_FORECAST_GLOB.NumberTabTyp;
             amount_type_id_tab              PA_FORECAST_GLOB.NumberTabTyp;
             line_num_tab                    PA_FORECAST_GLOB.NumberTabTyp;
             resource_type_code_tab          PA_FORECAST_GLOB.VCTabTyp;
             person_billable_flag_tab        PA_FORECAST_GLOB.VC1TabTyp;
             item_date_tab                   PA_FORECAST_GLOB.DateTabTyp;
             item_UOM_tab                    PA_FORECAST_GLOB.VCTabTyp;
             item_quantity_tab               PA_FORECAST_GLOB.NumberTabTyp;
             expenditure_org_id_tab          PA_FORECAST_GLOB.NumberTabTyp;
             project_org_id_tab              PA_FORECAST_GLOB.NumberTabTyp;
             PJI_SUMMARIZED_FLAG_tab         PA_FORECAST_GLOB.VC1TabTyp;
             CAPACITY_QUANTITY_tab         PA_FORECAST_GLOB.NumberTabTyp;
             OVERCOMMITMENT_QTY_tab         PA_FORECAST_GLOB.NumberTabTyp;
             OVERPROVISIONAL_QTY_tab         PA_FORECAST_GLOB.NumberTabTyp;
             OVER_PROV_CONF_QTY_tab         PA_FORECAST_GLOB.NumberTabTyp;
             CONFIRMED_QTY_tab         PA_FORECAST_GLOB.NumberTabTyp;
             PROVISIONAL_QTY_tab         PA_FORECAST_GLOB.NumberTabTyp;
             JOB_ID_tab         PA_FORECAST_GLOB.NumberTabTyp;
             PROJECT_ID_tab         PA_FORECAST_GLOB.NumberTabTyp;
             RESOURCE_ID_tab         PA_FORECAST_GLOB.NumberTabTyp;
             EXP_ORGANIZATION_ID_tab         PA_FORECAST_GLOB.NumberTabTyp;
             pvdr_acct_curr_code_tab         PA_FORECAST_GLOB.VC15TabTyp;
             pvdr_acct_amount_tab            PA_FORECAST_GLOB.NumberTabTyp;
             rcvr_acct_curr_code_tab         PA_FORECAST_GLOB.VC15TabTyp;
             rcvr_acct_amount_tab            PA_FORECAST_GLOB.NumberTabTyp;
             proj_currency_code_tab          PA_FORECAST_GLOB.VC15TabTyp;
             proj_amount_tab                 PA_FORECAST_GLOB.NumberTabTyp;
             denom_currency_code_tab         PA_FORECAST_GLOB.VC15TabTyp;
             denom_amount_tab                PA_FORECAST_GLOB.NumberTabTyp;
             tp_amount_type_tab              PA_FORECAST_GLOB.VCTabTyp;
             billable_flag_tab               PA_FORECAST_GLOB.VC1TabTyp;
             forecast_summarized_code_tab    PA_FORECAST_GLOB.VCTabTyp;
             util_summarized_code_tab        PA_FORECAST_GLOB.VCTabTyp;
             work_type_id_tab                PA_FORECAST_GLOB.NumberTabTyp;
             resource_util_category_id_tab   PA_FORECAST_GLOB.NumberTabTyp;
             org_util_category_id_tab        PA_FORECAST_GLOB.NumberTabTyp;
             resource_util_weighted_tab      PA_FORECAST_GLOB.NumberTabTyp;
             org_util_weighted_tab           PA_FORECAST_GLOB.NumberTabTyp;
             provisional_flag_tab            PA_FORECAST_GLOB.VC1TabTyp;
             reversed_flag_tab               PA_FORECAST_GLOB.VC1TabTyp;
             net_zero_flag_tab               PA_FORECAST_GLOB.VC1TabTyp;
             reduce_capacity_flag_tab        PA_FORECAST_GLOB.VC1TabTyp;
             line_num_reversed_tab           PA_FORECAST_GLOB.NumberTabTyp;

             TmpDtlTab                       PA_FORECAST_GLOB.FIDtlTabTyp;

             lv_return_status                VARCHAR2(30);
             g_process_mode          VARCHAR2(30);
       BEGIN

             lv_return_status := FND_API.G_RET_STS_SUCCESS;

             Print_message('Entering Fetch_FI_Dtl_Res');

             PA_DEBUG.Init_err_stack(
                       'PA_FORECASTITEM_PVT.Fetch_FI_Dtl_Res');

             TmpDtlTab.delete;
             forecast_item_id_tab.delete;
             amount_type_id_tab.delete;
             line_num_tab.delete;
             resource_type_code_tab.delete;
             person_billable_flag_tab.delete;
             item_date_tab.delete;
             item_UOM_tab.delete;
             item_quantity_tab.delete;
             expenditure_org_id_tab.delete;
             project_org_id_tab.delete;
             PJI_SUMMARIZED_FLAG_tab.delete;
             CAPACITY_QUANTITY_tab.delete;
             OVERCOMMITMENT_QTY_tab.delete;
             OVERPROVISIONAL_QTY_tab.delete;
             OVER_PROV_CONF_QTY_tab.delete;
             CONFIRMED_QTY_tab.delete;
             PROVISIONAL_QTY_tab.delete;
             JOB_ID_tab.delete;
             PROJECT_ID_tab.delete;
             RESOURCE_ID_tab.delete;
             EXP_ORGANIZATION_ID_tab.delete;
             pvdr_acct_curr_code_tab.delete;
             pvdr_acct_amount_tab.delete;
             rcvr_acct_curr_code_tab.delete;
             rcvr_acct_amount_tab.delete;
             proj_currency_code_tab.delete;
             proj_amount_tab.delete;
             denom_currency_code_tab.delete;
             denom_amount_tab.delete;
             tp_amount_type_tab.delete;
             billable_flag_tab.delete;
             forecast_summarized_code_tab.delete;
             util_summarized_code_tab.delete;
             work_type_id_tab.delete;
             resource_util_category_id_tab.delete;
             org_util_category_id_tab.delete;
             resource_util_weighted_tab.delete;
             org_util_weighted_tab.delete;
             provisional_flag_tab.delete;
             reversed_flag_tab.delete;
             net_zero_flag_tab.delete;
             reduce_capacity_flag_tab.delete;
             line_num_reversed_tab.delete;

             SELECT dtl.forecast_item_id, dtl.amount_type_id,
                    dtl.line_num, dtl.resource_type_code,
                    dtl.person_billable_flag, dtl.item_UOM,
                    dtl.item_date, dtl.item_quantity,
                    dtl.PJI_SUMMARIZED_FLAG,
                    dtl.CAPACITY_QUANTITY,
                    dtl.OVERCOMMITMENT_QTY,
                    dtl.OVERPROVISIONAL_QTY,
                    dtl.OVER_PROV_CONF_QTY,
                    dtl.CONFIRMED_QTY,
                    dtl.PROVISIONAL_QTY,
                    dtl.JOB_ID,
                    dtl.PROJECT_ID,
                    dtl.RESOURCE_ID,
                    dtl.EXPENDITURE_ORGANIZATION_ID,
                    dtl.expenditure_org_id, dtl.project_org_id,
                    dtl.pvdr_acct_curr_code, dtl.pvdr_acct_amount,
                    dtl.rcvr_acct_curr_code, dtl.rcvr_acct_amount,
                    dtl.proj_currency_code, dtl.proj_amount,
                    dtl.denom_currency_code, dtl.denom_amount,
                    dtl.tp_amount_type, dtl.billable_flag,
                    dtl.forecast_summarized_code, dtl.util_summarized_code,
                    dtl.work_type_id, dtl.resource_util_category_id,
                    dtl.org_util_category_id, dtl.resource_util_weighted,
                    dtl.org_util_weighted, dtl.provisional_flag,
                    dtl.reversed_flag, dtl.net_zero_flag,
                    dtl.reduce_capacity_flag, dtl.line_num_reversed
             BULK COLLECT INTO forecast_item_id_tab,amount_type_id_tab,
                    line_num_tab, resource_type_code_tab,
                    person_billable_flag_tab, item_UOM_tab,
                    item_date_tab, item_quantity_tab,
                    PJI_SUMMARIZED_FLAG_tab,
                    CAPACITY_QUANTITY_tab,
                    OVERCOMMITMENT_QTY_tab,
                    OVERPROVISIONAL_QTY_tab,
                    OVER_PROV_CONF_QTY_tab,
                    CONFIRMED_QTY_tab,
                    PROVISIONAL_QTY_tab,
                    JOB_ID_tab,
                    PROJECT_ID_tab,
                    RESOURCE_ID_tab,
                    EXP_ORGANIZATION_ID_tab,
                    expenditure_org_id_tab, project_org_id_tab,
                    pvdr_acct_curr_code_tab, pvdr_acct_amount_tab,
                    rcvr_acct_curr_code_tab, rcvr_acct_amount_tab,
                    proj_currency_code_tab, proj_amount_tab,
                    denom_currency_code_tab, denom_amount_tab,
                    tp_amount_type_tab, billable_flag_tab,
                    forecast_summarized_code_tab, util_summarized_code_tab,
                    work_type_id_tab, resource_util_category_id_tab,
                    org_util_category_id_tab, resource_util_weighted_tab,
                    org_util_weighted_tab, provisional_flag_tab,
                    reversed_flag_tab, net_zero_flag_tab,
                    reduce_capacity_flag_tab, line_num_reversed_tab
             FROM   pa_forecast_item_details dtl, pa_forecast_items hdr
             WHERE  hdr.resource_id = p_resource_id
             AND    hdr.delete_flag = 'N'
             AND    hdr.forecast_item_type = 'U'
		/***Addeded the following condition to fix the bug : 1913377
		 *  when this api called in process ERROR mode it should pick
                 *  only the header records which are marked as error it should not
                 *  pick all the records
	         **/
	     AND    ( nvl(g_process_mode,'GENERATE') <>  'ERROR'
                         OR
                     (hdr.error_flag = 'Y' AND nvl(g_process_mode,'GENERATE') = 'ERROR')
		     )
		/** end of bug fix ***/
             AND    hdr.item_date BETWEEN trunc(p_start_date) AND
                                                 trunc(p_end_date) -- bug 9032134
             AND    dtl.forecast_item_id = hdr.forecast_item_id
             AND    dtl.line_num = (
                         SELECT max(line_num)
                         FROM pa_forecast_item_details dtl1
                         WHERE dtl1.forecast_item_id = hdr.forecast_item_id)
             order by hdr.resource_id,dtl.item_date, dtl.forecast_item_id ;

             IF forecast_item_id_tab.COUNT = 0 THEN

                Print_message('Leaving Fetch_FI_Dtl_Res');

                x_return_status := lv_return_status;

                RETURN;

             END IF;

             -- Move to one table FROM multiple tables

             FOR j IN forecast_item_id_tab.FIRST..forecast_item_id_tab.LAST LOOP

                 TmpDtlTab(j).forecast_item_id := forecast_item_id_tab(j);
                 TmpDtlTab(j).amount_type_id :=amount_type_id_tab(j);
                 TmpDtlTab(j).line_num := line_num_tab(j);
                 TmpDtlTab(j).resource_type_code := resource_type_code_tab(j);
                 TmpDtlTab(j).person_billable_flag :=
                                 person_billable_flag_tab(j);
                 TmpDtlTab(j).item_Uom := item_UOM_tab(j);
                 TmpDtlTab(j).item_date := item_date_tab(j);
                 TmpDtlTab(j).item_quantity := item_quantity_tab(j);
                 TmpDtlTab(j).expenditure_org_id := expenditure_org_id_tab(j);
                 TmpDtlTab(j).project_org_id := project_org_id_tab(j);
                 TmpDtlTab(j).pvdr_acct_curr_code :=
                                 pvdr_acct_curr_code_tab(j);
                 TmpDtlTab(j).PJI_SUMMARIZED_FLAG := PJI_SUMMARIZED_FLAG_tab(j);
                 TmpDtlTab(j).CAPACITY_QUANTITY := CAPACITY_QUANTITY_tab(j);
                 TmpDtlTab(j).OVERCOMMITMENT_QTY := OVERCOMMITMENT_QTY_tab(j);
                 TmpDtlTab(j).OVERPROVISIONAL_QTY := OVERPROVISIONAL_QTY_tab(j);
                 TmpDtlTab(j).OVER_PROV_CONF_QTY := OVER_PROV_CONF_QTY_tab(j);
                 TmpDtlTab(j).CONFIRMED_QTY := CONFIRMED_QTY_tab(j);
                 TmpDtlTab(j).PROVISIONAL_QTY := PROVISIONAL_QTY_tab(j);
                 TmpDtlTab(j).JOB_ID := JOB_ID_tab(j);
                 TmpDtlTab(j).PROJECT_ID := PROJECT_ID_tab(j);
                 TmpDtlTab(j).RESOURCE_ID := RESOURCE_ID_tab(j);
                 TmpDtlTab(j).EXPENDITURE_ORGANIZATION_ID := EXP_ORGANIZATION_ID_tab(j);
                 TmpDtlTab(j).pvdr_acct_amount := pvdr_acct_amount_tab(j);
                 TmpDtlTab(j).rcvr_acct_curr_code :=
                                 rcvr_acct_curr_code_tab(j);
                 TmpDtlTab(j).rcvr_acct_amount := rcvr_acct_amount_tab(j);
                 TmpDtlTab(j).proj_currency_code := proj_currency_code_tab(j);
                 TmpDtlTab(j).proj_amount := proj_amount_tab(j);
                 TmpDtlTab(j).denom_currency_code := denom_currency_code_tab(j);
                 TmpDtlTab(j).denom_amount := denom_amount_tab(j);
                 TmpDtlTab(j).tp_amount_type := tp_amount_type_tab(j);
                 TmpDtlTab(j).billable_flag := billable_flag_tab(j);
                 TmpDtlTab(j).forecast_summarized_code :=
                                 forecast_summarized_code_tab(j);
                 TmpDtlTab(j).util_summarized_code :=
                                 util_summarized_code_tab(j);
                 TmpDtlTab(j).work_type_id := work_type_id_tab(j);
                 TmpDtlTab(j).resource_util_category_id :=
                                 resource_util_category_id_tab(j);
                 TmpDtlTab(j).org_util_category_id :=
                                 org_util_category_id_tab(j);
                 TmpDtlTab(j).resource_util_weighted :=
                                 resource_util_weighted_tab(j);
                 TmpDtlTab(j).org_util_weighted :=
                                 org_util_weighted_tab(j);
                 TmpDtlTab(j).provisional_flag := provisional_flag_tab(j);
                 TmpDtlTab(j).reversed_flag := reversed_flag_tab(j);
                 TmpDtlTab(j).net_zero_flag := net_zero_flag_tab(j);
                 TmpDtlTab(j).reduce_capacity_flag :=
                                     reduce_capacity_flag_tab(j);
                 TmpDtlTab(j).line_num_reversed := line_num_reversed_tab(j);

             END LOOP;

             x_dbFIDtlTab := TmpDtlTab;

             Print_message('Leaving Fetch_FI_Dtl_Res');

             PA_DEBUG.Reset_Err_Stack;

             x_return_status := lv_return_status;

       EXCEPTION

              WHEN OTHERS THEN
                  print_message('Failed in Fetch_FI_Dtl_Res api');
                  print_message('SQLCODE'||sqlcode||sqlerrm);

                  x_msg_count     := 1;
                  x_msg_data      := sqlerrm;
                  x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

                  FND_MSG_PUB.add_exc_msg
                      (p_pkg_name   =>
                              'PA_FORECASTITEM_PVT.Fetch_FI_Dtl_Res',
                       p_procedure_name => PA_DEBUG.G_Err_Stack);

		               If x_msg_count = 1 THEN
				              pa_interface_utils_pub.get_messages
				                (p_encoded        => FND_API.G_TRUE,
					               p_msg_index      => 1,
					               p_msg_count      => x_msg_count,
					               p_msg_data       => x_msg_data,
					               p_data           => l_data, -- 4537865
					               p_msg_index_out  => l_msg_index_out );
							x_msg_data := l_data ; -- 4537865
		               End If;
                  Print_message(x_msg_data);

                  RAISE;


       END  Fetch_FI_Dtl_Res;

/* ---------------------------------------------------------------------
|   Procedure  :   Build_FI_Hdr_Res
|   Purpose    :   To create new/modified forecast item
|                  (Resource Unassigned Time) record
|                  FOR the item DATEs that are built IN the p_FIDayTab
|   Parameters :   p_resource_id    - Input Resource ID
|                  p_start_date     - Current Start DATE FOR forecast item
|                  p_end_date       - Current END DATE FOR forecast item
|                  p_FIDayTab   - Holds all item_dates,item_quantity,
|                                 status_code FOR the current run.
|                   i) action_flag component of this tab will be updated
|                      to indicate the following
|                      a) N  : New record - item_date does not exist
|                      b) DN : Delete AND create new -
|                                item DATE exists but expenditure OU/
|                                expenditure organization/expenditure type/
|                                expenditure type class/ borrowed flag has
|                                changed.
|                                Existing record is reversed(deleted) AND new
|                                record is created
|                      c) RN : Reverse AND create new -
|                              Quantity has changed.
|                              IN header : quantity is updated.
|                              IN detail :
|                                IF summarized existing line should be reversed
|                                   AND new line created
|                                IF not summarized existing line should be
|                                   updated to reflect new quantity
|                      d) C :  No change IN header
|                              Check FOR any changes IN detail record for
|                              person_billable_flag, provisional_flag,
|                              work_type OR resource_type
|                   ii) forecast_item_id component of this tab will be updated
|                       to hold the forecast_item_id FOR new record. Same will
|                       be used FOR detail record
|                  iii) project_org_id,expenditure_org_id,work_type_id,
|                       person_billable_flag, tp_amount_type : These values
|                       are required FOR detail record processing. These are
|                       also updated IN this tab.
|                  p_DBHdrTab   - Holds forecast item records which are
|                                 already existing
|
|                  x_FIHdrInsTab - Will RETURN all forecast item records that
|                                  are new
|                  x_FIHdrUpdTab - Will RETURN all forecast item records that
|                                  are modified
|                  x_return_status     -
|                  x_msg_count         -
|                  x_msg_data          -
+----------------------------------------------------------------------*/
       PROCEDURE  Build_FI_Hdr_Res(
                  p_resource_id    IN  NUMBER,
                  p_start_date     IN  DATE,
                  p_end_date       IN  DATE,
                  p_FIDayTab   IN OUT  NOCOPY PA_FORECAST_GLOB.FIDayTabTyp, /* 2674619 - Nocopy change */
                  p_DBHdrTab       IN  PA_FORECAST_GLOB.FIHDRTabTyp,
                  x_FIHdrInsTab    OUT NOCOPY PA_FORECAST_GLOB.FIHdrTabTyp, /* 2674619 - Nocopy change */
                  x_FIHdrUpdTab    OUT NOCOPY PA_FORECAST_GLOB.FIHdrTabTyp, /* 2674619 - Nocopy change */
                  x_return_status  OUT NOCOPY VARCHAR2, -- 4537865
                  x_msg_count      OUT NOCOPY NUMBER, -- 4537865
                  x_msg_data       OUT NOCOPY VARCHAR2) IS  -- 4537865

		  l_data varchar2(2000); -- 4537865
	           l_msg_index_out	            NUMBER;
             lv_include_admin_proj_flag       VARCHAR2(5);
             lv_util_cal_method               VARCHAR2(30);
             lv_bill_unasg_proj_id            NUMBER;
             lv_bill_unasg_exp_type_class     VARCHAR2(30);
             lv_bill_unasg_exp_type           VARCHAR2(30);
             lv_nbill_unasg_proj_id           NUMBER;
             lv_nbill_unasg_exp_type_class    VARCHAR2(30);
             lv_nbill_unasg_exp_type          VARCHAR2(30);
             lv_default_tp_amount_type        VARCHAR2(30);

             lv_forecast_item_type            VARCHAR2(1);
             lv_project_id                    NUMBER;
             lv_person_id                     NUMBER;
             lv_project_org_id                NUMBER;
             lv_project_orgn_id               NUMBER;
             lv_project_type_class            VARCHAR2(30);
             lv_project_status_code           VARCHAR2(30);
             lv_pvdr_period_set_name          VARCHAR2(30):= NULL;
             lv_rcvr_period_set_name          VARCHAR2(30):= NULL;
             lv_pvdr_pa_period_name           VARCHAR2(30):= NULL;

             ld_resou_startdate_tab           PA_FORECAST_GLOB.DateTabTyp;
             ld_resou_enddate_tab             PA_FORECAST_GLOB.DateTabTyp;
             l_resou_tab                      PA_FORECAST_GLOB.NumberTabTyp;
             lv_res_index                     NUMBER ;
             lv_resou                         NUMBER;

             ld_pvdrpa_startdate_tab          PA_FORECAST_GLOB.DateTabTyp;
             ld_pvdrpa_enddate_tab            PA_FORECAST_GLOB.DateTabTyp;
             lv_pvdrpa_name_tab               PA_FORECAST_GLOB.periodnametabtyp;
             lv_pvpa_index                    NUMBER ;
             lv_pvdrpa_name                   VARCHAR2(30);

             ld_pvdrgl_startdate_tab          PA_FORECAST_GLOB.DateTabTyp;
             ld_pvdrgl_enddate_tab            PA_FORECAST_GLOB.DateTabTyp;
             lv_pvdrgl_name_tab               PA_FORECAST_GLOB.periodnametabtyp;
             lv_pvgl_index                    NUMBER ;
             lv_pvdrgl_name                   VARCHAR2(30);

             ld_rcvrpa_startdate_tab          PA_FORECAST_GLOB.DateTabTyp;
             ld_rcvrpa_enddate_tab            PA_FORECAST_GLOB.DateTabTyp;
             lv_rcvrpa_name_tab               PA_FORECAST_GLOB.periodnametabtyp;
             lv_rcpa_index                    NUMBER ;
             lv_rcvrpa_name                   VARCHAR2(30);

             ld_rcvrgl_startdate_tab          PA_FORECAST_GLOB.DateTabTyp;
             ld_rcvrgl_enddate_tab            PA_FORECAST_GLOB.DateTabTyp;
             lv_rcvrgl_name_tab               PA_FORECAST_GLOB.periodnametabtyp;
             lv_rcgl_index                    NUMBER ;
             lv_rcvrgl_name                   VARCHAR2(30);

             ld_orgn_startdate_tab            PA_FORECAST_GLOB.DateTabTyp;
             ld_orgn_enddate_tab              PA_FORECAST_GLOB.DateTabTyp;
             l_orgn_tab                       PA_FORECAST_GLOB.NumberTabTyp;
             l_jobid_tab                      PA_FORECAST_GLOB.NumberTabTyp;
             lv_orgn_index                    NUMBER ;
             lv_resorgn                       NUMBER;
             lv_jobid                         NUMBER;

             lv_WeekDateRange_Tab     PA_FORECAST_GLOB.WeekDatesRangeFcTabTyp;
             lv_wk_index              NUMBER;

             lv_borrowed_flag                 VARCHAR2(1) := 'N';
             lv_action_code                   VARCHAR2(30);
             lv_include_in_forecast           VARCHAR2(1) := 'N';
             lv_person_bill_flag              VARCHAR2(1);
             lv_forecast_item_id              NUMBER;
             lv_work_type_id                  NUMBER;
             lv_exp_type                      VARCHAR2(30);
             lv_exp_type_class                VARCHAR2(30);
             lv_error_flag                    VARCHAR2(3);
             lv_rejection_code                VARCHAR2(30);
             lv_prev_index                    NUMBER;

             lv_ou_error                      VARCHAR2(1);
             lv_orgn_error                    VARCHAR2(1);

             TmpDayTab                        PA_FORECAST_GLOB.FIDayTabTyp;
             TmpInsTab                        PA_FORECAST_GLOB.FIHdrTabTyp;
             i_in                             NUMBER := 1;
             TmpUpdTab                        PA_FORECAST_GLOB.FIHdrTabTyp;
             u_in                             NUMBER := 1;
             d_in                             NUMBER := 1;
             TmpHdrRec                        PA_FORECAST_GLOB.FIHdrRecord;

             lv_err_msg                       VARCHAR2(30);

             lv_return_status                 VARCHAR2(30);
             lv_call_pos                     VARCHAR2(50);
             tmp_person_id                    NUMBER;
             tmp_status_code                  VARCHAR2(30);
             lv_start_date                    DATE;
             lv_end_date                      DATE;
              -- bug#6911723 start
             g_TimelineProfileSetup  PA_TIMELINE_GLOB.TimelineProfileSetup;
             AVAILABILITY_DURATION   NUMBER;
             ld_res_strt_date DATE ;
             RES_AVAIL_DUR_EXCP EXCEPTION;
             -- bug#6911723 end


       BEGIN

             lv_return_status := FND_API.G_RET_STS_SUCCESS;

             Print_message('Entering Build_FI_Hdr_Res');

             PA_DEBUG.Init_err_stack(
                       'PA_FORECASTITEM_PVT.Build_FI_Hdr_Res');

              --bug#6911723 start
               SELECT Max(resource_effective_start_date)
               INTO ld_res_strt_date
               FROM pa_resources_denorm
               WHERE resource_id=p_resource_id;

               g_TimelineProfileSetup  := PA_TIMELINE_UTIL.get_timeline_profile_setup;
               availability_duration   := g_TimelineProfileSetup.availability_duration;

               IF ld_res_strt_date > p_end_date THEN
               RAISE RES_AVAIL_DUR_EXCP;
               END IF ;
               -- bug#6911723 end

             TmpDayTab.Delete;
             TmpInsTab.Delete;
             TmpUpdTab.Delete;

             ld_resou_startdate_tab.delete;
             ld_resou_enddate_tab.delete;
             l_resou_tab.delete;
             ld_pvdrpa_startdate_tab.delete;
             ld_pvdrpa_enddate_tab.delete;
             lv_pvdrpa_name_tab.delete;
             ld_pvdrgl_startdate_tab.delete;
             ld_pvdrgl_enddate_tab.delete;
             lv_pvdrgl_name_tab.delete;
             ld_rcvrpa_startdate_tab.delete;
             ld_rcvrpa_enddate_tab.delete;
             lv_rcvrpa_name_tab.delete;
             ld_rcvrgl_startdate_tab.delete;
             ld_rcvrgl_enddate_tab.delete;
             lv_rcvrgl_name_tab.delete;
             ld_orgn_startdate_tab.delete;
             ld_orgn_enddate_tab.delete;
             l_orgn_tab.delete;
             l_jobid_tab.delete;
             lv_WeekDateRange_Tab.delete;

             TmpDayTab := p_FIDayTab;

             Print_message(
                        'Res - Get_resource_ou ');

             PA_FORECAST_ITEMS_UTILS.get_resource_ou(
                           p_resource_id,p_start_date, p_end_date,
                           ld_resou_startdate_tab,ld_resou_enddate_tab,
                           l_resou_tab);

             lv_res_index := l_resou_tab.FIRST;

             IF l_resou_tab.count > 0 THEN

                lv_resou := l_resou_tab(lv_res_index);

             ELSE

                lv_err_msg := 'ResOU_Not_Found';
                RAISE NO_DATA_FOUND;

             END IF;


             Print_message( 'Res - Get_Person_id ');

             lv_person_id :=
                       PA_FORECAST_ITEMS_UTILS.get_person_id(p_resource_id);


             Print_message(
                        'Res - Get_res_org_and_job ');

             PA_FORECAST_ITEMS_UTILS.get_res_org_and_job(
                            lv_person_id, p_start_date, p_end_date,
                            ld_orgn_startdate_tab, ld_orgn_enddate_tab,
                            l_orgn_tab, l_jobid_tab);

             lv_orgn_index := l_orgn_tab.FIRST;

             IF l_orgn_tab.count > 0 THEN

                lv_resorgn := l_orgn_tab(lv_orgn_index);
                lv_jobid := l_jobid_tab(lv_orgn_index);
             ELSE

                lv_err_msg := 'Resorgn_Not_Found';
                RAISE NO_DATA_FOUND;

             END IF;

             Print_message(
                        'Res - Get_week_dates_range_fc ');

             PA_FORECAST_ITEMS_UTILS.get_Week_Dates_Range_Fc(
                                      p_start_date,
                                      p_end_date,
                                      lv_WeekDateRange_Tab,
                                      lv_return_status,
                                      x_msg_count,
                                      x_msg_data);
             lv_wk_index := lv_WeekDateRange_Tab.FIRST;

             lv_call_pos := 'Res : bef_for';

             if (TmpDaytab.count <> 0) then
             FOR i IN TmpDaytab.FIRST..TmpDaytab.LAST LOOP
                 if TmpDaytab.exists(i) then

                 lv_rejection_code := NULL;

                 lv_call_pos := 'Res : chk per bill';

/* Bug1967832 Remvoed the original call to check_person_billable function and added the conditions below.*/

                 IF TRUNC(TmpDayTab(i).item_date) BETWEEN TRUNC(lv_start_date) and TRUNC(nvl(lv_end_date,TmpDayTab(i).item_date))
                 	AND i>TmpDaytab.FIRST
                  AND lv_person_id=tmp_person_id

                  THEN
                      lv_person_bill_flag := lv_person_bill_flag;
                 ELSE


                    Check_Person_Billable(p_person_id			=> lv_person_id,
																					p_item_date			=> TmpDayTab(i).item_date,
																					x_start_date		=> lv_start_date,
                                          x_end_date			=> lv_end_date,
																					x_billable_flag	=> lv_person_bill_flag,
                                          x_return_status => lv_return_status,
                                          x_msg_count     => x_msg_count,
                                          x_msg_data      => x_msg_data);
                    tmp_person_id := lv_person_id;

                 END IF;

                 lv_ou_error := 'N';

                 lv_error_flag := 'N';

                 lv_call_pos := 'Res : resou ';
                 IF (ld_resou_startdate_tab.count = 0) THEN

                       --  lv_error_flag := 'Y';
                       --  lv_rejection_code := 'Resource_ou_not_found';

                           lv_err_msg := 'ResOU_Not_Found';
                           RAISE NO_DATA_FOUND;

                 ELSIF ((lv_pvdr_period_set_name IS NULL) OR
                         (trunc(TmpDayTab(i).item_date)  NOT BETWEEN
                           trunc(ld_resou_startdate_tab(lv_res_index)) AND
                            trunc(ld_resou_enddate_tab(lv_res_index)))) THEN

                    lv_prev_index := lv_res_index;

                    LOOP

                        IF lv_res_index > ld_resou_startdate_tab.COUNT THEN

                         --  lv_error_flag := 'Y';
                         --  lv_rejection_code := 'Resource_ou_not_found';

                           lv_err_msg := 'ResOU_Not_Found';
                           RAISE NO_DATA_FOUND;

                        END IF;


                        EXIT WHEN lv_error_flag = 'Y' OR
                                trunc(TmpDayTab(i).item_date) >=
                                 trunc(ld_resou_startdate_tab(lv_res_index)) AND
                                trunc(TmpDayTab(i).item_date) <=
                                 trunc(ld_resou_enddate_tab(lv_res_index));

                        lv_res_index := lv_res_index + 1;

                    END LOOP;

                    IF lv_error_flag = 'Y' THEN

                       lv_res_index := lv_prev_index;
                       lv_ou_error := 'Y';
                       lv_resou := -99;
                       lv_pvdr_period_set_name := '-99';
                       lv_project_id              := -99;
                       lv_project_org_id          := -99;
                       lv_project_orgn_id         := -99;
                       lv_work_type_id            := -99;
                       lv_project_type_class      := '-99';
                       lv_rcvr_period_set_name    := '-99';
                       lv_pvdrpa_name             := '-99';
                       lv_pvdrgl_name             := '-99';
                       lv_rcvrpa_name             := '-99';
                       lv_rcvrgl_name             := '-99';
                       lv_exp_type                := '-99';
                       lv_exp_type_class          := '-99';


                    ELSE

                       lv_resou := l_resou_tab(lv_res_index);

                       Print_message(
                                  'Res - Get_period_set_name (pvdr) ');

                       lv_pvdr_period_set_name :=
                            PA_FORECAST_ITEMS_UTILS.get_period_set_name(
                                         lv_resou);

                       if lv_pvdr_period_set_name = 'NO_DATA_FOUND' THEN

                          lv_pvdr_period_set_name := '-99';
                          lv_rejection_code := 'PVDR_PRD_SET_NAME_NOT_FOUND';
                          lv_error_flag := 'Y';

                       end if;


                    END IF;


                    IF lv_ou_error = 'N' THEN

                        Print_message(
                                  'Res - Get_pa_period_name (pvdr) ');

                        PA_FORECAST_ITEMS_UTILS.get_pa_period_name(
                                      lv_resou,p_start_date,
                                      p_end_date,
                                      ld_pvdrpa_startdate_tab,
                                      ld_pvdrpa_enddate_tab,
                                      lv_pvdrpa_name_tab);

                        lv_pvpa_index := lv_pvdrpa_name_tab.FIRST;

                        IF lv_pvdrpa_name_tab.count > 0 THEN

                           lv_pvdrpa_name := lv_pvdrpa_name_tab(lv_pvpa_index);

                        END IF;


                        Print_message(
                                  'Res - Get_gl_period_name (pvdr) ');

                        PA_FORECAST_ITEMS_UTILS.get_gl_period_name(
                                      lv_resou,p_start_date,
                                      p_end_date,
                                      ld_pvdrgl_startdate_tab,
                                      ld_pvdrgl_enddate_tab,
                                      lv_pvdrgl_name_tab);

                        lv_pvgl_index := lv_pvdrgl_name_tab.FIRST;

                        IF lv_pvdrgl_name_tab.count > 0 THEN

                           lv_pvdrgl_name := lv_pvdrgl_name_tab(lv_pvgl_index);

                        END IF;


                        Print_message(
                                  'Res - Get_forecastoptions ');

                        PA_FORECAST_ITEMS_UTILS.get_forecastoptions(
                          lv_resou,
                       --   lv_include_admin_proj_flag, Bug 4576715
                          lv_util_cal_method,
                          lv_bill_unasg_proj_id,
                          lv_bill_unasg_exp_type_class,
                          lv_bill_unasg_exp_type,
                          lv_nbill_unasg_proj_id,
                          lv_nbill_unasg_exp_type_class,
                          lv_nbill_unasg_exp_type,
                          lv_default_tp_amount_type,
                          lv_return_status, x_msg_count, x_msg_data);

		/* Added the code for bug 3011242*/
                        IF lv_return_status <> FND_API.G_RET_STS_SUCCESS THEN
			 x_return_status := lv_return_status;
                          return;
                        END IF;
               /* Code addition for the bug 3011242 ends*/
/*
                        Print_message('foptions ::' ||
                          'org:' || l_resou_tab(lv_res_index) ||
                          ' adm:'|| lv_include_admin_proj_flag ||
                          ' utl:'|| lv_util_cal_method ||
                          ' b_prjid:'|| lv_bill_unasg_proj_id);

                        Print_message('foptions ::' ||
                          ' b_exp_cls:'|| lv_bill_unasg_exp_type_class ||
                          ' b_exp_typ:'|| lv_bill_unasg_exp_type ||
                          ' nb_prjid:'|| lv_nbill_unasg_proj_id);

                        Print_message('foptions ::' ||
                          ' nb_exp_cls:'|| lv_nbill_unasg_exp_type_class ||
                          ' nb_exp_typ:'|| lv_nbill_unasg_exp_type ||
                          ' tp_amt_typ:'|| lv_default_tp_amount_type);
*/
                        print_message('After Get_forecastoptions');

                        IF lv_person_bill_flag = 'Y' Then
                           print_message('Inside IF lv_person_bill_flag = Y');

                           lv_project_id     := lv_bill_unasg_proj_id;
                           lv_exp_type       := lv_bill_unasg_exp_type;
                           lv_exp_type_class := lv_bill_unasg_exp_type_class;

                        ELSE

                           print_message('Inside ELSE lv_person_bill_flag = Y');
                           lv_project_id     := lv_nbill_unasg_proj_id;
                           lv_exp_type       := lv_nbill_unasg_exp_type;
                           lv_exp_type_class := lv_nbill_unasg_exp_type_class;

                        END IF;

                        lv_call_pos := 'Res : proj ';

                        Print_message(
                            'Res - Calling get_project_dtls ');

                        Get_Project_Dtls (lv_project_id, lv_project_org_id,
                                lv_project_orgn_id, lv_work_type_id,
                                lv_project_type_class,lv_project_status_code,
                                lv_return_status, x_msg_count, x_msg_data);

                        IF lv_return_status <> FND_API.G_RET_STS_SUCCESS THEN
                           lv_err_msg := 'No_Project_Record - Res';
                           RAISE NO_DATA_FOUND;

                        END IF;

                        Print_message(
                            'Res - Get_Period_set_name (rcvr) ');

             Print_message('lv_project_org_id: ' || lv_project_org_id);
                        lv_rcvr_period_set_name :=
                            PA_FORECAST_ITEMS_UTILS.get_period_set_name (
                                                  lv_project_org_id);

                       if lv_rcvr_period_set_name = 'NO_DATA_FOUND' THEN

                          lv_rcvr_period_set_name := '-99';
                          lv_rejection_code := 'RCVR_PRD_SET_NAME_NOT_FOUND';
                          lv_error_flag := 'Y';

                       end if;

                        Print_message(
                            'Res - Get_PA_Period_name (rcvr) ');

             Print_message('lv_project_org_id: ' || lv_project_org_id);
                        PA_FORECAST_ITEMS_UTILS.get_pa_period_name(
                                      lv_project_org_id,
                                      p_start_date,
                                      p_end_date,
                                      ld_rcvrpa_startdate_tab,
                                      ld_rcvrpa_enddate_tab,
                                      lv_rcvrpa_name_tab);

                        lv_rcpa_index := lv_rcvrpa_name_tab.FIRST;

                        IF lv_rcvrpa_name_tab.count > 0 THEN

                           lv_rcvrpa_name := lv_rcvrpa_name_tab(lv_rcpa_index);

                        END IF;


                        Print_message(
                            'Res - Get_gl_Period_name (rcvr) ');

             Print_message('lv_project_org_id: ' || lv_project_org_id);
                        PA_FORECAST_ITEMS_UTILS.get_gl_period_name(
                                      lv_project_org_id,
                                      p_start_date,
                                      p_end_date,
                                      ld_rcvrgl_startdate_tab,
                                      ld_rcvrgl_enddate_tab,
                                      lv_rcvrgl_name_tab);

                        lv_rcgl_index := lv_rcvrgl_name_tab.FIRST;

                        IF lv_rcvrgl_name_tab.count > 0 THEN

                           lv_rcvrgl_name := lv_rcvrgl_name_tab(lv_rcgl_index);

                        END IF;


                    END IF;

                 END IF;

                 lv_error_flag := 'N';

                 lv_call_pos := 'Res : resorgn ';

                 IF (ld_orgn_enddate_tab.count = 0) THEN
                        print_message('if ld_orgn_enddate_tab.count = 0');
                        lv_error_flag := 'Y';

--                      IF (lv_rejection_code IS NULL) THEN

--                         lv_rejection_code := 'Exp orgn not found';

--                      END IF;


                        lv_err_msg := 'Resorgn_Not_Found';
                        RAISE NO_DATA_FOUND;


                 ELSIF (trunc(TmpDayTab(i).item_date) NOT BETWEEN
                         trunc(ld_orgn_startdate_tab(lv_orgn_index)) AND
                          trunc(ld_orgn_enddate_tab(lv_orgn_index))) THEN


                    print_message('else trunc(TmpDayTab(i)...: ' || TmpDayTab(i).item_date);
                    print_message('ld_orgn_startdate_tab(lv_orgn_index): ' || ld_orgn_startdate_tab(lv_orgn_index));
                    print_message('ld_orgn_enddate_tab(lv_orgn_index): ' || ld_orgn_enddate_tab(lv_orgn_index));
                    print_message('lv_prev_index: ' || lv_prev_index);
                    print_message('lv_orgn_index: ' || lv_orgn_index);
                    print_message('ld_orgn_startdate_tab.FIRST: ' || ld_orgn_startdate_tab.FIRST);
                    print_message('ld_orgn_startdate_tab.LAST: ' || ld_orgn_startdate_tab.LAST);
                    print_message('ld_orgn_startdate_tab.COUNT: ' || ld_orgn_startdate_tab.COUNT);
                    print_message('lv_error_flag: ' || lv_error_flag);

                    lv_prev_index := lv_orgn_index;

                    LOOP

                        IF lv_orgn_index > ld_orgn_startdate_tab.COUNT THEN

                           lv_error_flag := 'Y';

--                         IF (lv_rejection_code IS NULL) THEN

--                             lv_rejection_code := 'Exp orgn not found';

--                         END IF;

                          lv_err_msg := 'Resorgn_Not_Found';
                          RAISE NO_DATA_FOUND;

                        END IF;

                        print_message('TmpDayTab(i).item_date: ' || TmpDayTab(i).item_date);
                        print_message('ld_orgn_startdate_tab(lv_orgn_index): ' || ld_orgn_startdate_tab(lv_orgn_index));
                        print_message('ld_orgn_enddate_tab(lv_orgn_index): ' || ld_orgn_enddate_tab(lv_orgn_index));
                        EXIT WHEN lv_error_flag = 'Y'  OR
                             (trunc(TmpDayTab(i).item_date) >=
                                trunc(ld_orgn_startdate_tab(lv_orgn_index)) AND
                              trunc(TmpDayTab(i).item_date) <=
                                trunc(ld_orgn_enddate_tab(lv_orgn_index)));

                           lv_orgn_index := lv_orgn_index + 1;

                    END LOOP;

                 END IF;


                 IF lv_error_flag = 'Y' THEN

                       print_message('IF lv_error_flag = Y');
                       lv_orgn_index := lv_prev_index;
                       lv_resorgn := -99;
                       lv_jobid := -99;
                       lv_orgn_error := 'Y';

                 ELSE
                       print_message('else IF lv_error_flag = Y');
                       lv_resorgn := l_orgn_tab(lv_orgn_index);
                       lv_jobid := l_jobid_tab(lv_orgn_index);

                 END IF;


                 lv_call_pos := 'Res : Borr ';
                 IF ((lv_project_org_id <>lv_resou ) OR
                      (lv_project_orgn_id  <> lv_resorgn)) THEN

                    lv_borrowed_flag := 'Y';

                 ELSE

                    lv_borrowed_flag := 'N';

                 END IF;

                 lv_action_code := 'STAFFED_ASGMT_PROJ_FORECASTING';

/* Bug No:1967832. Added conditions before calling check_prj_stus_action_allowed.*/

		 --Added nvl in IF condition for bug 4380573.
		IF nvl(TmpDayTab(i).status_code, 'NULL') = tmp_status_code
                 AND i>TmpDayTab.FIRST THEN
                     lv_include_in_forecast := lv_include_in_forecast;
                 ELSE
                     lv_include_in_forecast :=
                      pa_project_utils.check_prj_stus_action_allowed(
                                   TmpDayTab(i).status_code,
                                   lv_action_code);

		     /* Commented this for bug 4380573
                     tmp_status_code := TmpDayTab(i).status_code; */

		     --Added nvl for bug 4380573
		     tmp_status_code := nvl(TmpDayTab(i).status_code, 'NULL');

                 END IF;

                 TmpDayTab(i).include_in_forecast := lv_include_in_forecast;

                 --print_message('JM: 100');
                 IF d_in <=  p_DbHdrTab.COUNT THEN

                    --print_message('JM: 101');
                    lv_call_pos := 'Res : in if 1 ';

                    IF trunc(TmpDayTab(i).item_date) <
                               trunc(p_DbHdrTab(d_in).item_date) THEN

                       --print_message('JM: 102');
                       lv_call_pos := 'Res : in if 2 ';


-- Data Model Merge: Only leave out if all quantity columns are 0.
                       --IF (TmpDayTab(i).item_quantity = 0 ) THEN
                       IF (NVL(TmpDayTab(i).item_quantity,0) = 0 AND
                           NVL(TmpDayTab(i).OVERPROVISIONAL_QTY,0) = 0 AND
                           NVL(TmpDayTab(i).OVER_PROV_CONF_QTY,0) = 0 AND
                           NVL(TmpDayTab(i).CONFIRMED_QTY,0) = 0 AND
                           NVL(TmpDayTab(i).PROVISIONAL_QTY,0) = 0 AND
                           NVL(TmpDayTab(i).capacity_quantity,0) = 0 AND
                           NVL(TmpDayTab(i).availability_quantity,0) = 0 AND
                           NVL(TmpDayTab(i).overcommitment_quantity,0) = 0) THEN

                          --print_message('JM: 103');
                          TmpDayTab(i).action_flag := 'I';

                       ELSE

                          --print_message('JM: 104');
                          TmpDayTab(i).action_flag := 'N';

                       END IF;

                    print_message('JM: 105');
                    ELSIF trunc(TmpDayTab(i).item_date) =
                                trunc(p_DbHdrTab(d_in).item_date) THEN

                      --print_message('JM: 106');
                      --print_message('TmpDayTab(i).item_date: ' || TmpDayTab(i).item_date);
                      print_message('NVL(TmpDayTab(i).capacity_quantity,-99): ' || NVL(TmpDayTab(i).capacity_quantity,-99));
                      print_message('NVL(p_DbHdrTab(d_in).capacity_quantity,-99): ' || NVL(p_DbHdrTab(d_in).capacity_quantity,-99));
                      print_message('NVL(TmpDayTab(i).availability_quantity,-99): ' || NVL(TmpDayTab(i).availability_quantity,-99));
                      print_message('NVL(p_DbHdrTab(d_in).availability_quantity,-99): ' || NVL(p_DbHdrTab(d_in).availability_quantity,-99));
                      print_message('NVL(TmpDayTab(i).overcommitment_quantity,-99): ' || NVL(TmpDayTab(i).overcommitment_quantity,-99));
                      print_message('NVL(p_DbHdrTab(d_in).overcommitment_quantity,-99): ' || NVL(p_DbHdrTab(d_in).overcommitment_quantity,-99));

                       lv_call_pos := 'Res : in else 2 ';
                       print_message('nvl(lv_default_tp_amount_type,Z): ' || nvl(lv_default_tp_amount_type,'Z'));
                       print_message('nvl(p_DbHdrTab(d_in).tp_amount_type,Z): ' ||  nvl(p_DbHdrTab(d_in).tp_amount_type,'Z'));

-- Data Model Merge: Only delete if all quantity columns are 0.
                       IF (NVL(TmpDayTab(i).item_quantity,0) = 0 AND
                           NVL(TmpDayTab(i).OVERPROVISIONAL_QTY,0) = 0 AND
                           NVL(TmpDayTab(i).OVER_PROV_CONF_QTY,0) = 0 AND
                           NVL(TmpDayTab(i).CONFIRMED_QTY,0) = 0 AND
                           NVL(TmpDayTab(i).PROVISIONAL_QTY,0) = 0 AND
                           NVL(TmpDayTab(i).capacity_quantity,0) = 0 AND
                           NVL(TmpDayTab(i).availability_quantity,0) = 0 AND
                           NVL(TmpDayTab(i).overcommitment_quantity,0) = 0) THEN

                          --print_message('JM: 107');
                          lv_call_pos := 'Res : in if 3 ';
                          TmpDayTab(i).action_flag := 'D';
                          TmpUpdTab(u_in) := p_DbHdrTab(d_in);
                          TmpUpdTab(u_in).CAPACITY_QUANTITY := NULL;
                          TmpUpdTab(u_in).OVERCOMMITMENT_QTY := NULL;
-- Start fix for bug 2504222 (need to null out all columns related to quantity)
                          TmpUpdTab(u_in).OVERCOMMITMENT_QUANTITY := NULL;
                          TmpUpdTab(u_in).OVERCOMMITMENT_FLAG := NULL;
                          TmpUpdTab(u_in).AVAILABILITY_FLAG := NULL;
                          TmpUpdTab(u_in).AVAILABILITY_QUANTITY := NULL;
-- End fix for bug 2504222
                          TmpUpdTab(u_in).OVERPROVISIONAL_QTY := NULL;
                          TmpUpdTab(u_in).OVER_PROV_CONF_QTY := NULL;
                          TmpUpdTab(u_in).CONFIRMED_QTY := NULL;
                          TmpUpdTab(u_in).PROVISIONAL_QTY := NULL;
                          TmpUpdTab(u_in).item_quantity := 0;
                          TmpUpdTab(u_in).delete_flag := 'Y';
                          TmpUpdTab(u_in).error_flag := 'N';
                          TmpUpdTab(u_in).other_rejection_code := NULL;
                          u_in := u_in + 1;

                          --print_message('JM: 108');
                       ELSIF p_DbHdrTab(d_in).error_flag = 'Y' THEN

                          --print_message('JM: 109');
                          lv_call_pos := 'Res : in else 3 ';
                          TmpDayTab(i).action_flag := 'E';
                          TmpDayTab(i).forecast_item_id :=
                                    p_DbHdrTab(d_in).forecast_item_id;

                       ELSIF ( (NVL(lv_resou,0) <>
                               NVL(p_DbHdrTab(d_in).expenditure_org_id,0)) OR
                            (NVL(lv_resorgn,0) <>
                                NVL(p_DbHdrTab(d_in).expenditure_organization_id,0)) OR
                            (NVL(lv_jobid,0) <>
                                NVL(p_DbHdrTab(d_in).job_id,0)) OR
                            (lv_exp_type <>
                                p_DbHdrTab(d_in).expenditure_type) OR
                            (lv_exp_type_class <>
                               p_DbHdrTab(d_in).expenditure_type_class) OR
                           (nvl(lv_default_tp_amount_type,'Z') <>
                               nvl(p_DbHdrTab(d_in).tp_amount_type,'Z')) OR
                            (lv_borrowed_flag <> p_DbHdrTab(d_in).borrowed_flag)

                          ) THEN

                          print_message('JM: 110');
                          lv_call_pos := 'Res : in else 3a ';
                          TmpDayTab(i).action_flag := 'DN';
                          TmpUpdTab(u_in) := p_DbHdrTab(d_in);
                          TmpUpdTab(u_in).CAPACITY_QUANTITY := NULL;
                          TmpUpdTab(u_in).OVERCOMMITMENT_QTY := NULL;
-- Start fix for bug 2504222 (need to null out all columns related to quantity)
                          TmpUpdTab(u_in).OVERCOMMITMENT_QUANTITY := NULL;
                          TmpUpdTab(u_in).AVAILABILITY_QUANTITY := NULL;
                          TmpUpdTab(u_in).AVAILABILITY_FLAG := NULL;
                          TmpUpdTab(u_in).OVERCOMMITMENT_FLAG := NULL;
-- End fix for bug 2504222
                          TmpUpdTab(u_in).OVERPROVISIONAL_QTY := NULL;
                          TmpUpdTab(u_in).OVER_PROV_CONF_QTY := NULL;
                          TmpUpdTab(u_in).CONFIRMED_QTY := NULL;
                          TmpUpdTab(u_in).PROVISIONAL_QTY := NULL;
                          TmpUpdTab(u_in).item_quantity := 0;
                          TmpUpdTab(u_in).delete_flag := 'Y';
                          u_in := u_in + 1;

                       ELSIF (
                              NVL(TmpDayTab(i).CAPACITY_QUANTITY,0) <> NVL(p_DbHdrTab(d_in).CAPACITY_QUANTITY,0) OR
                              NVL(TmpDayTab(i).OVERPROVISIONAL_QTY,0) <> NVL(p_DbHdrTab(d_in).OVERPROVISIONAL_QTY,0) OR
                              NVL(TmpDayTab(i).OVER_PROV_CONF_QTY,0) <> NVL(p_DbHdrTab(d_in).OVER_PROV_CONF_QTY,0) OR
                              NVL(TmpDayTab(i).CONFIRMED_QTY,0) <> NVL(p_DbHdrTab(d_in).CONFIRMED_QTY,0) OR
                              NVL(TmpDayTab(i).PROVISIONAL_QTY,0) <> NVL(p_DbHdrTab(d_in).PROVISIONAL_QTY,0) OR
                              NVL(TmpDayTab(i).OVERCOMMITMENT_QUANTITY,0) <> NVL(p_DbHdrTab(d_in).OVERCOMMITMENT_QUANTITY,0) OR
                              NVL(TmpDayTab(i).AVAILABILITY_QUANTITY,0) <> NVL(p_DbHdrTab(d_in).AVAILABILITY_QUANTITY,0) OR
                              TmpDayTab(i).item_quantity <>
                                  p_DbHdrTab(d_in).item_quantity
                              ) THEN

                          --print_message('JM: 111');
                          lv_call_pos := 'Res : in else 3b ';
                          TmpDayTab(i).action_flag := 'RN';
                          TmpDayTab(i).expenditure_org_id :=
                                       lv_resou;
                          TmpDayTab(i).project_org_id := lv_project_org_id;
                          TmpDayTab(i).work_type_id := lv_work_type_id;
                          TmpDayTab(i).tp_amount_type :=
                                         lv_default_tp_amount_type;
                          TmpDayTab(i).person_billable_flag :=
                                          lv_person_bill_flag;
                          TmpDayTab(i).job_id := lv_jobid;
                          TmpDayTab(i).project_id := lv_project_id;
                          TmpDayTab(i).resource_id := p_resource_id;
                          TmpDayTab(i).expenditure_organization_id := lv_resorgn;

                          TmpUpdTab(u_in) := p_DbHdrTab(d_in);
                          TmpUpdTab(u_in).CAPACITY_QUANTITY :=
                                        TmpDayTab(i).CAPACITY_QUANTITY;
                          TmpUpdTab(u_in).OVERCOMMITMENT_QTY :=
                                        TmpDayTab(i).OVERCOMMITMENT_QTY;
-- Start fix for bug 2504222 (important part of bug fix, values were not
-- set properly previously
                          TmpUpdTab(u_in).OVERCOMMITMENT_QUANTITY :=
                                        TmpDayTab(i).OVERCOMMITMENT_QUANTITY;
                          TmpUpdTab(u_in).AVAILABILITY_QUANTITY :=
                                        TmpDayTab(i).AVAILABILITY_QUANTITY;
                          TmpUpdTab(u_in).AVAILABILITY_FLAG :=
                                        TmpDayTab(i).AVAILABILITY_FLAG;
                          TmpUpdTab(u_in).OVERCOMMITMENT_FLAG :=
                                        TmpDayTab(i).OVERCOMMITMENT_FLAG;
-- End fix for bug 2504222
                          TmpUpdTab(u_in).OVERPROVISIONAL_QTY :=
                                        TmpDayTab(i).OVERPROVISIONAL_QTY;
                          TmpUpdTab(u_in).OVER_PROV_CONF_QTY :=
                                        TmpDayTab(i).OVER_PROV_CONF_QTY;
                          TmpUpdTab(u_in).CONFIRMED_QTY :=
                                        TmpDayTab(i).CONFIRMED_QTY;
                          TmpUpdTab(u_in).PROVISIONAL_QTY :=
                                        TmpDayTab(i).PROVISIONAL_QTY;
                          TmpUpdTab(u_in).item_quantity :=
                                         TmpDayTab(i).item_quantity;
                          u_in := u_in + 1;

                       ELSE

                          --print_message('JM: 112');
                          lv_call_pos := 'Res : in else 3c ';
                          TmpDayTab(i).action_flag := 'C';
                          TmpDayTab(i).expenditure_org_id :=
                                       lv_resou;
                          TmpDayTab(i).project_org_id := lv_project_org_id;
                          TmpDayTab(i).work_type_id := lv_work_type_id;
                          TmpDayTab(i).tp_amount_type :=
                                         lv_default_tp_amount_type;
                          TmpDayTab(i).person_billable_flag :=
                                          lv_person_bill_flag;
                          TmpDayTab(i).job_id := lv_jobid;
                          TmpDayTab(i).project_id := lv_project_id;
                          TmpDayTab(i).resource_id := p_resource_id;
                          TmpDayTab(i).expenditure_organization_id := lv_resorgn;
                       END IF;

                       d_in := d_in + 1;

                    END IF;

                 END IF;

                 --print_message('JM: 113');
                 lv_call_pos := 'Res : data create ';

-- Data Model Merge: Only leave out if all quantity columns are 0.
                 IF (TmpDayTab(i).action_flag IN ('N', 'DN','E') AND
                            (NVL(TmpDayTab(i).item_quantity,0) > 0 OR
                             NVL(TmpDayTab(i).OVERPROVISIONAL_QTY,0) > 0 OR
                             NVL(TmpDayTab(i).OVER_PROV_CONF_QTY,0) > 0 OR
                             NVL(TmpDayTab(i).CONFIRMED_QTY,0) > 0 OR
                             NVL(TmpDayTab(i).PROVISIONAL_QTY,0) > 0 OR
                             NVL(TmpDayTab(i).capacity_quantity,0) > 0 OR
                             NVL(TmpDayTab(i).availability_quantity,0) > 0 OR
                             NVL(TmpDayTab(i).overcommitment_quantity,0) > 0))  THEN

                    --print_message('JM: 114');
                    lv_call_pos := 'Res : in if data create ';

                    --print_message('JM: 115');
                    IF TmpDayTab(i).action_flag <> 'E' THEN

                         lv_forecast_item_id :=
                              PA_FORECAST_ITEMS_UTILS.get_next_forecast_item_id;

                         TmpDayTab(i).forecast_item_id := lv_forecast_item_id;

                    ELSE

                         --print_message('JM: 116');
                         lv_forecast_item_id := TmpDayTab(i).forecast_item_id;

                    END IF;

                    --print_message('JM: 117');
                    TmpHdrRec.forecast_item_id := lv_forecast_item_id;
                    TmpDayTab(i).work_type_id := lv_work_type_id;
                    TmpDayTab(i).tp_amount_type := lv_default_tp_amount_type;
                    TmpDayTab(i).person_billable_flag := lv_person_bill_flag;
                    TmpDayTab(i).project_org_id := lv_project_org_id;
                    TmpDayTab(i).expenditure_org_id := lv_resou;
                    TmpDayTab(i).job_id := lv_jobid;
                    TmpDayTab(i).project_id := lv_project_id;
                    TmpDayTab(i).resource_id := p_resource_id;
                    TmpDayTab(i).expenditure_organization_id := lv_resorgn;
                    TmpHdrRec.forecast_item_id := lv_forecast_item_id;
                    TmpHdrRec.forecast_item_type := 'U';
                    TmpHdrRec.project_org_id := lv_project_org_id;
                    TmpHdrRec.expenditure_org_id := lv_resou;
                    TmpHdrRec.project_organization_id :=
                                            lv_project_orgn_id;
                    TmpHdrRec.expenditure_organization_id := lv_resorgn;
                    TmpHdrRec.project_id := lv_project_id;
                    TmpHdrRec.project_type_class := lv_project_type_class;
                    TmpHdrRec.person_id := lv_person_id;
                    TmpHdrRec.resource_id := p_resource_id;
                    TmpHdrRec.borrowed_flag := lv_borrowed_flag;
                    TmpHdrRec.assignment_id := NULL;
                    TmpHdrRec.item_date := TmpDayTab(i).item_date;
                    TmpHdrRec.item_UOM := 'HOURS';
                    TmpHdrRec.item_quantity := TmpDayTab(i).item_quantity;
                    TmpHdrRec.pvdr_period_set_name :=
                                         lv_pvdr_period_set_name;
                    TmpHdrRec.JOB_ID := lv_jobid;
                    TmpHdrRec.TP_AMOUNT_TYPE := lv_default_tp_amount_type;
                    TmpHdrRec.asgmt_sys_status_code := NULL;
                    TmpHdrRec.capacity_quantity := TmpDayTab(i).capacity_quantity;
                    TmpHdrRec.OVERPROVISIONAL_QTY := TmpDayTab(i).OVERPROVISIONAL_QTY;
                    TmpHdrRec.OVER_PROV_CONF_QTY := TmpDayTab(i).OVER_PROV_CONF_QTY;
                    TmpHdrRec.CONFIRMED_QTY := TmpDayTab(i).CONFIRMED_QTY;
                    TmpHdrRec.PROVISIONAL_QTY := TmpDayTab(i).PROVISIONAL_QTY;
                    TmpHdrRec.overcommitment_quantity := TmpDayTab(i).overcommitment_quantity;
                    TmpHdrRec.availability_quantity := TmpDayTab(i).availability_quantity;
                    TmpHdrRec.overcommitment_flag := TmpDayTab(i).overcommitment_flag;
                    TmpHdrRec.availability_flag := TmpDayTab(i).availability_flag;
                    lv_error_flag := 'N';

                    lv_call_pos := 'Res : pvdrpa ';
                    IF (ld_pvdrpa_startdate_tab.count = 0) THEN

                        print_message('JM: 118');
                        lv_error_flag := 'Y';

                        IF (lv_rejection_code IS NULL) THEN

                            lv_rejection_code := 'PVDR_PA_PRD_NAME_NOT_FOUND';

                        END IF;


                    ELSIF (trunc(TmpHdrRec.item_date) NOT BETWEEN
                         trunc(ld_pvdrpa_startdate_tab(lv_pvpa_index)) AND
                         trunc(ld_pvdrpa_enddate_tab(lv_pvpa_index))) THEN

                       --print_message('JM: 119');
                       lv_prev_index := lv_pvpa_index;

                       LOOP

                           IF lv_pvpa_index > ld_pvdrpa_startdate_tab.COUNT THEN

                              --print_message('JM: 120');
                              lv_error_flag := 'Y';


                              IF (lv_rejection_code IS NULL) THEN

                                 print_message('JM: 121');
                                 lv_rejection_code :=
                                        'PVDR_PA_PRD_NAME_NOT_FOUND';

                              END IF;

                           END IF;

                           EXIT WHEN lv_error_flag = 'Y' OR
                            (trunc(TmpHdrRec.item_date) >=
                              trunc(ld_pvdrpa_startdate_tab(lv_pvpa_index)) AND
                             trunc(TmpHdrRec.item_date) <=
                              trunc(ld_pvdrpa_enddate_tab(lv_pvpa_index)));

                           lv_pvpa_index := lv_pvpa_index + 1;

                       END LOOP;

                    END IF;

                    IF lv_error_flag = 'Y' THEN

                       --print_message('JM: 122');
                       lv_pvpa_index := lv_prev_index;
                       TmpHdrRec.pvdr_pa_period_name := '-99';

                    ELSE

                       print_message('JM: 123');
                       TmpHdrRec.pvdr_pa_period_name :=
                                   lv_pvdrpa_name_tab(lv_pvpa_index);

                    END IF;

                    lv_error_flag := 'N';

                    lv_call_pos := 'Res : pvdrgl ';
                    IF (ld_pvdrgl_startdate_tab.count = 0) THEN

                        print_message('JM: 124');
                        lv_error_flag := 'Y';

                        IF (lv_rejection_code IS NULL) THEN

                             print_message('JM: 125');
                            lv_rejection_code := 'PVDR_GL_PRD_NAME_NOT_FOUND';

                        END IF;


                    ELSIF (trunc(TmpHdrRec.item_date) NOT BETWEEN
                            trunc(ld_pvdrgl_startdate_tab(lv_pvgl_index)) AND
                            trunc(ld_pvdrgl_enddate_tab(lv_pvgl_index))) THEN

                       --print_message('JM: 126');
                       lv_prev_index := lv_pvgl_index;

                       LOOP

                          IF lv_pvgl_index > ld_pvdrgl_startdate_tab.COUNT THEN

                             print_message('JM: 127');
                             lv_error_flag := 'Y';

                              IF (lv_rejection_code IS NULL) THEN

                                 print_message('JM: 128');
                                 lv_rejection_code :=
                                        'PVDR_GL_PRD_NAME_NOT_FOUND';

                              END IF;

                          END IF;

                          EXIT WHEN lv_error_flag = 'Y' OR
                            ( trunc(TmpHdrRec.item_date) >=
                              trunc(ld_pvdrgl_startdate_tab(lv_pvgl_index)) AND
                              trunc(TmpHdrRec.item_date) <=
                                trunc( ld_pvdrgl_enddate_tab(lv_pvgl_index)));

                           lv_pvgl_index := lv_pvgl_index + 1;

                       END LOOP;

                    END IF;

                    IF lv_error_flag = 'Y' THEN

                       print_message('JM: 129');
                       lv_pvgl_index := lv_prev_index;
                       TmpHdrRec.pvdr_gl_period_name := '-99';

                    ELSE

                       print_message('JM: 130');
                       TmpHdrRec.pvdr_gl_period_name :=
                                   lv_pvdrgl_name_tab(lv_pvgl_index);

                    END IF;

                    TmpHdrRec.rcvr_period_set_name :=
                                  lv_rcvr_period_set_name;

                    lv_error_flag := 'N';

                    lv_call_pos := 'Res : rcvrpa ';
                    IF (ld_rcvrpa_startdate_tab.count = 0) THEN

                        print_message('JM: 131');
                        lv_error_flag := 'Y';

                        IF (lv_rejection_code IS NULL) THEN

                            print_message('JM: 132');
                            lv_rejection_code := 'RCVR_PA_PRD_NAME_NOT_FOUND';

                        END IF;

                        print_message('JM: 133');
                    ELSIF (trunc(TmpHdrRec.item_date) NOT BETWEEN
                           trunc(ld_rcvrpa_startdate_tab(lv_rcpa_index)) AND
                           trunc(ld_rcvrpa_enddate_tab(lv_rcpa_index))) THEN

                       lv_prev_index := lv_rcpa_index;

                        print_message('JM: 134');
                       LOOP

                           IF lv_rcpa_index > ld_rcvrpa_startdate_tab.COUNT THEN

                              lv_error_flag := 'Y';
                              print_message('lv_rcpa_index > ld_rcvrpa_startdate_tab.COUNT');
                              print_message(lv_rejection_code);
                              IF (lv_rejection_code IS NULL) THEN
                                 print_message('RCVR_PA_PRD_NAME_NOT_FOUND');
                                 lv_rejection_code :=
                                        'RCVR_PA_PRD_NAME_NOT_FOUND';

                              END IF;

                           END IF;

                           EXIT WHEN  lv_error_flag = 'Y' OR
                            ( trunc(TmpHdrRec.item_date) >=
                              trunc(ld_rcvrpa_startdate_tab(lv_rcpa_index)) AND
                              trunc(TmpHdrRec.item_date) <=
                              trunc(ld_rcvrpa_enddate_tab(lv_rcpa_index)));

                           lv_rcpa_index := lv_rcpa_index + 1;

                       END LOOP;

                    END IF;

                    IF lv_error_flag = 'Y' THEN

                       lv_rcpa_index := lv_prev_index;
                       TmpHdrRec.rcvr_pa_period_name := '-99';

                    ELSE

                       TmpHdrRec.rcvr_pa_period_name :=
                                   lv_rcvrpa_name_tab(lv_rcpa_index);

                    END IF;

                    lv_error_flag := 'N';

                    lv_call_pos := 'Res : rcvrgl ';
                    IF (ld_rcvrgl_startdate_tab.count = 0) THEN

                        lv_error_flag := 'Y';

                        IF (lv_rejection_code IS NULL) THEN

                            lv_rejection_code := 'RCVR_GL_PRD_NAME_NOT_FOUND';

                        END IF;

                    ELSIF (trunc(TmpHdrRec.item_date) NOT BETWEEN
                           trunc(ld_rcvrgl_startdate_tab(lv_rcgl_index)) AND
                           trunc(ld_rcvrgl_enddate_tab(lv_rcgl_index))) THEN

                       lv_prev_index := lv_rcgl_index;

                       LOOP

                           IF lv_rcgl_index > ld_rcvrgl_startdate_tab.COUNT THEN

                              lv_error_flag := 'Y';

                              IF (lv_rejection_code IS NULL) THEN

                                  lv_rejection_code :=
                                           'RCVR_GL_PRD_NAME_NOT_FOUND';

                              END IF;

                           END IF;

                           EXIT WHEN lv_error_flag = 'Y' OR
                            (trunc(TmpHdrRec.item_date) >=
                              trunc(ld_rcvrgl_startdate_tab(lv_rcgl_index)) AND
                              trunc(TmpHdrRec.item_date) <=
                              trunc(ld_rcvrgl_enddate_tab(lv_rcgl_index)));

                           lv_rcgl_index := lv_rcgl_index + 1;

                       END LOOP;

                    END IF;

                    IF lv_error_flag = 'Y' THEN

                       lv_rcgl_index := lv_prev_index;
                       TmpHdrRec.rcvr_gl_period_name := '-99';

                    ELSE

                       TmpHdrRec.rcvr_gl_period_name :=
                                  lv_rcvrgl_name_tab(lv_rcgl_index);

                    END IF;

                    lv_error_flag := 'N';

                    lv_call_pos := 'Res : wkdtrang ';
                    IF (trunc(TmpHdrRec.item_date) NOT BETWEEN
                         trunc(
                         lv_WeekDateRange_Tab(lv_wk_index).week_start_date) AND
                         trunc(
                         lv_WeekDateRange_Tab(lv_wk_index).week_end_date))
                                                         THEN

                       lv_prev_index := lv_wk_index;

                       LOOP
                           IF lv_wk_index > lv_WeekDateRange_Tab.COUNT THEN

                              lv_error_flag := 'Y';

                           END IF;

                           EXIT WHEN lv_error_flag = 'Y' OR
                           ((trunc(TmpHdrRec.item_date) >=
                             trunc(
                             lv_WeekDateRange_Tab(lv_wk_index).week_start_date))
                                                  AND
                            (trunc(TmpHdrRec.item_date) <=
                             trunc(
                             lv_WeekDateRange_Tab(lv_wk_index).week_end_date)));

                            lv_wk_index := lv_wk_index + 1;

                       END LOOP;

                    END IF;

                    TmpHdrRec.global_exp_period_end_date :=
                           lv_WeekDateRange_Tab(lv_wk_index).week_end_date;

                    TmpHdrRec.expenditure_type := lv_exp_type;
                    TmpHdrRec.expenditure_type_class := lv_exp_type_class;
                    TmpHdrRec.provisional_flag := 'N';
                    TmpHdrRec.cost_rejection_code := NULL;
                    TmpHdrRec.rev_rejection_code  := NULL;
                    TmpHdrRec.Tp_rejection_code  := NULL;
                    TmpHdrRec.Burden_rejection_code  := NULL;
                    TmpHdrRec.capacity_quantity := TmpDayTab(i).capacity_quantity;
                    TmpHdrRec.OVERPROVISIONAL_QTY := TmpDayTab(i).OVERPROVISIONAL_QTY;
                    TmpHdrRec.OVER_PROV_CONF_QTY := TmpDayTab(i).OVER_PROV_CONF_QTY;
                    TmpHdrRec.CONFIRMED_QTY := TmpDayTab(i).CONFIRMED_QTY;
                    TmpHdrRec.PROVISIONAL_QTY := TmpDayTab(i).PROVISIONAL_QTY;
                    TmpHdrRec.overcommitment_quantity := TmpDayTab(i).overcommitment_quantity ;
                    TmpHdrRec.availability_quantity := TmpDayTab(i).availability_quantity;
                    TmpHdrRec.overcommitment_flag := TmpDayTab(i).overcommitment_flag;
                    TmpHdrRec.availability_flag := TmpDayTab(i).availability_flag;

                    TmpHdrRec.Other_rejection_code  := lv_rejection_code;
                    TmpHdrRec.Delete_Flag  := 'N';
		    -- 4583893 : Added lv_resorgn = -77 check
                    IF (lv_rejection_code IS NOT NULL OR lv_resorgn = -77) THEN

                       TmpHdrRec.Error_Flag  := 'Y';
                       TmpDayTab(i).Error_Flag := 'Y';

                    ELSE

                       TmpHdrRec.Error_Flag  := 'N';

                    END IF;

                    IF TmpDayTab(i).action_flag IN ('N','DN')  THEN

                       TmpInsTab(i_in) := TmpHdrRec;
                       i_in := i_in + 1;

                    ELSE

                       TmpDayTab(i).action_flag := 'RN';
                       TmpUpdTab(u_in) := TmpHdrRec;
                       u_in := u_in + 1;

                    END IF ;


/*
                Print_message('***********');
                Print_message(
                    ' item_date :' || TmpHdrRec.item_date);

                Print_message(
                    'fct_item_id:' || TmpHdrRec.forecast_item_id ||
                    ' fct_itm_typ:' || TmpHdrRec.forecast_item_type ||
                    ' prj_org_id:' || TmpHdrRec.project_org_id ||
                    ' exp_org_id:' || TmpHdrRec.expenditure_org_id||
                    chr(10)|| 'exp_orgn_id:' ||
                               TmpHdrRec.expenditure_organization_id ||
                    ' prj_orgn_id:' ||
                               TmpHdrRec.project_organization_id ||
                    ' prj_id:' || TmpHdrRec.project_id);

                Print_message(
                     'prj_typ_cls:' || TmpHdrRec.project_type_class ||
                     ' person_id:' || TmpHdrRec.person_id||
                     ' res_id:' || TmpHdrRec.resource_id ||
                     ' brw_flg:' || TmpHdrRec.borrowed_flag ||
                     ' asgn_id:' || TmpHdrRec.assignment_id ||
                     ' item_uom:' || TmpHdrRec.item_uom ||
                     ' itm_qty:' || TmpHdrRec.item_quantity);

                Print_message(
                    'pvd_set_nme:' || TmpHdrRec.pvdr_period_set_name ||
                    ' pvd_pa_name:' ||
                               TmpHdrRec.pvdr_pa_period_name ||
                    chr(10) || 'pvd_gl_name:' ||
                               TmpHdrRec.pvdr_gl_period_name ||
                    ' rcv_set_nme:' ||
                               TmpHdrRec.rcvr_period_set_name ||
                    chr(10) || 'rcv_pa_name:' ||
                               TmpHdrRec.rcvr_pa_period_name ||
                    ' rcv_gl_name:' ||
                               TmpHdrRec.rcvr_gl_period_name ||
                    chr(10) || 'glb_end_dt:' ||
                               TmpHdrRec.global_exp_period_end_date);

                Print_message(
                    'exp_type:' || TmpHdrRec.expenditure_type ||
                    ' exp_typ_cls:' ||
                               TmpHdrRec.expenditure_type_class ||
                    chr(10) || 'oth_rej_cde:' ||
                               TmpHdrRec.other_rejection_code ||
                    ' Del_flag:' || TmpHdrRec.delete_flag ||
                    ' Err_flag:' || TmpHdrRec.error_flag ||
                    ' Prv_flag:' || TmpHdrRec.provisional_flag);
*/

                 END IF;
             end if;
             END LOOP;
             end if;


             p_FIDayTab    := TmpDayTab;
             x_FIHdrInsTab := TmpInsTab;
             x_FIHdrUpdTab := TmpUpdTab;

             Print_message('Leaving Build_FI_Hdr_Res');

             PA_DEBUG.Reset_Err_Stack;

             x_return_status := lv_return_status;

        EXCEPTION
        --bug#6911723 start
        WHEN RES_AVAIL_DUR_EXCP THEN
               PA_MESSAGE_UTILS.save_messages(
                             p_request_id     =>   PA_R_PROJECT_RESOURCES_PVT.G_request_id
                                ,p_source_Type1   =>  'RESOURCE_PULL'
                                ,p_source_Type2   =>  'PARCPRJR'
                                ,p_context1       =>  NULL
                                ,p_context2       =>  NULL
                                ,p_context3       =>  NULL
                                ,p_context4       =>  NULL
                                ,p_context5       =>  NULL
                                ,p_context10      =>  'PA_RES_NOT_PULLED'
                                ,p_date_context1  =>  NULL
                                ,p_date_context2  =>  NULL
                                ,p_use_fnd_msg    =>  'Y'
                                ,p_commit         =>  FND_API.G_FALSE  --p_commit
                                ,x_return_status  =>  lv_return_status);

    PA_UTILS.Add_Message(
                               p_app_short_name => 'PA'
                              ,p_msg_name       => 'PA_RES_NOT_PULLED');


                               x_msg_count     := 1;
                  x_msg_data      := 'PA_RES_NOT_PULLED';
                  x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

                  If x_msg_count = 1 THEN
				              pa_interface_utils_pub.get_messages
				                (p_encoded        => FND_API.G_TRUE,
					               p_msg_index      => 1,
					               p_msg_count      => x_msg_count,
					               p_msg_data       => x_msg_data,
					               p_data           => l_data , -- 4537865
					               p_msg_index_out  => l_msg_index_out );
						x_msg_data := l_data ; -- 4537865
		               End If;
                  Print_message(x_msg_data);
                  Print_message(lv_call_pos);
            -- bug#6911723 end


             WHEN NO_DATA_FOUND THEN

                if lv_err_msg = 'ResOU_Not_Found' then

                  x_msg_count     := 1;
                  x_msg_data      := 'ResOU not found';
                  x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

                  FND_MSG_PUB.add_exc_msg
                      (p_pkg_name   =>
                              'PA_FORECASTITEM_PVT.Build_FI_Hdr_Res',
                       p_procedure_name => PA_DEBUG.G_Err_Stack);

		               If x_msg_count = 1 THEN
				              pa_interface_utils_pub.get_messages
				                (p_encoded        => FND_API.G_TRUE,
					               p_msg_index      => 1,
					               p_msg_count      => x_msg_count,
					               p_msg_data       => x_msg_data,
					               p_data           => l_data , -- 4537865
					               p_msg_index_out  => l_msg_index_out );
						x_msg_data := l_data ; -- 4537865
		               End If;
                  Print_message(x_msg_data);
                  Print_message(lv_call_pos);

                  RAISE;

               elsif lv_err_msg = 'Resorgn_Not_Found' then
                  x_msg_count     := 1;
                  x_msg_data      := 'ResOrgn not found';
                  x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

                  FND_MSG_PUB.add_exc_msg
                      (p_pkg_name   =>
                              'PA_FORECASTITEM_PVT.Build_FI_Hdr_Res',
                       p_procedure_name => PA_DEBUG.G_Err_Stack);

		               If x_msg_count = 1 THEN
				              pa_interface_utils_pub.get_messages
				                (p_encoded        => FND_API.G_TRUE,
					               p_msg_index      => 1,
					               p_msg_count      => x_msg_count,
					               p_msg_data       => x_msg_data,
					               p_data           => l_data, -- 4537865
					               p_msg_index_out  => l_msg_index_out );
						x_msg_data := l_data ; -- 4537865
		               End If;
                  Print_message(x_msg_data);
                  Print_message(lv_call_pos);

                  RAISE;

               else

                  x_msg_count     := 1;
                  x_msg_data      := sqlerrm ;
                  x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

                  FND_MSG_PUB.add_exc_msg
                      (p_pkg_name   =>
                              'PA_FORECASTITEM_PVT.Build_FI_Hdr_Res',
                       p_procedure_name => PA_DEBUG.G_Err_Stack);

		               If x_msg_count = 1 THEN
				              pa_interface_utils_pub.get_messages
				                (p_encoded        => FND_API.G_TRUE,
					               p_msg_index      => 1,
					               p_msg_count      => x_msg_count,
					               p_msg_data       => x_msg_data,
					               p_data           => l_data, -- 4537865
					               p_msg_index_out  => l_msg_index_out );
						 x_msg_data := l_data ; -- 4537865
		               End If;
                  Print_message(x_msg_data);
                  Print_message(lv_call_pos);

                  RAISE;

               end if;

             WHEN OTHERS THEN
                  print_message('Failed in Build_FI_Hdr_Res api');
                  print_message('SQLCODE'||sqlcode||sqlerrm);

                  x_msg_count     := 1;
                  x_msg_data      := sqlerrm;
                  x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

                  FND_MSG_PUB.add_exc_msg
                      (p_pkg_name   =>
                              'PA_FORECASTITEM_PVT.Build_FI_Hdr_Res',
                       p_procedure_name => PA_DEBUG.G_Err_Stack);

		               If x_msg_count = 1 THEN
				              pa_interface_utils_pub.get_messages
				                (p_encoded        => FND_API.G_TRUE,
					               p_msg_index      => 1,
					               p_msg_count      => x_msg_count,
					               p_msg_data       => x_msg_data,
					               p_data           => l_data, -- 4537865
					               p_msg_index_out  => l_msg_index_out );
							  x_msg_data := l_data ; -- 4537865
		               End If;
                  Print_message(x_msg_data);

                  RAISE;

       END Build_FI_Hdr_Res;


/* ---------------------------------------------------------------------
|   Procedure  :   Build_FI_Dtl_Res
|   Purpose    :   To create new/modified forecast item details
|                  (Resource Unassigned Time) record
|                  FOR the item DATEs that are built IN the p_FIDayTab
|   Parameters :   p_resource_id    - Input Resource ID
|                  p_start_date     - Current Start DATE FOR forecast item
|                  p_end_date       - Current END DATE FOR forecast item
|                  p_DBDtlTab   - Holds forecast item detail records which are
|                                 already existing
|                  p_FIDayTab   - Holds all item_dates,item_quantity,
|                                 status_code FOR the current run.
|                       action_flag component of this tab already indicates
|                       (By Header Processing) the following :
|                      a) N  : New record - item_date does not exist
|                      b) DN : Delete AND create new -
|                                item DATE exists but expenditure OU/
|                                expenditure organization/expenditure type/
|                                expenditure type class/ borrowed flag has
|                                changed.
|                                Existing record is reversed(deleted) AND new
|                                record is created
|                      c) RN : Reverse AND create new -
|                              Quantity has changed.
|                              IN header : quantity is updated.
|                              IN detail :
|                                IF summarized existing line should be reversed
|                                   AND new line created
|                                IF not summarized existing line should be
|                                   updated to reflect new quantity
|                      d) C :  No change IN header
|                              Check FOR any changes IN detail record for
|                              person_billable_flag, provisional_flag,
|                              work_type OR resource_type
|                  x_FIDtlInsTab - Will RETURN all forecast item detail records
|                                  that are new
|                  x_FIDtlUpdTab - Will RETURN all forecast item detail records
|                                  that are modified
|                  x_return_status     -
|                  x_msg_count         -
|                  x_msg_data          -
+----------------------------------------------------------------------*/
       PROCEDURE Build_FI_Dtl_Res(
                 p_resource_id   IN     NUMBER,
                 p_DBDtlTab      IN     PA_FORECAST_GLOB.FIDtlTabTyp,
                 p_FIDayTab      IN     PA_FORECAST_GLOB.FIDayTabTyp,
                 x_FIDtlInsTab   OUT    NOCOPY PA_FORECAST_GLOB.FIDtlTabTyp, /* 2674619 - Nocopy change */
                 x_FIDtlUpdTab   OUT    NOCOPY PA_FORECAST_GLOB.FIDtlTabTyp, /* 2674619 - Nocopy change */
                 x_return_status OUT    NOCOPY VARCHAR2,  -- 4537865
                 x_msg_count     OUT    NOCOPY NUMBER,  -- 4537865
                 x_msg_data      OUT    NOCOPY VARCHAR2) IS  -- 4537865


	           l_msg_index_out	            NUMBER;
		  l_data varchar2(2000);  -- 4537865
             d_in                        NUMBER := 1; -- index FOR p_dbDtlTab;
             TmpDayTab                   PA_FORECAST_GLOB.FIDayTabTyp;
             TmpInsTab                   PA_FORECAST_GLOB.FIDtlTabTyp;
             i_in                        NUMBER := 1; -- index FOR TmpDayTab;
             TmpUpdTab                   PA_FORECAST_GLOB.FIDtlTabTyp;
             u_in                        NUMBER := 1; -- index FOR TmpDayTab;
             TmpDtlRec                   PA_FORECAST_GLOB.FIDtlRecord;

             lv_billable_flag            VARCHAR2(3);
             l_resutilweighted         NUMBER;
             l_orgutilweighted         NUMBER;
             l_resutilcategoryid         NUMBER;
             l_orgutilcategoryid         NUMBER;
             l_ReduceCapacityFlag     VARCHAR2(1);

             lv_inc_forecast_flag        VARCHAR2(3) := 'N';
             lv_inc_util_flag        VARCHAR2(3) := 'N';
             lv_provisional_flag         VARCHAR2(3);
             lv_next_line_num            NUMBER;
             lv_new_fcast_sum_code       VARCHAR2(1);
             lv_new_util_sum_code       VARCHAR2(1);
             lv_resource_type            VARCHAR2(30);
             lv_amount_type_id        NUMBER;
             lv_person_id        NUMBER;

             lv_return_status         VARCHAR2(30);
             tmp_person_id            VARCHAR2(30);
             lv_start_date            DATE;
             lv_end_date              DATE;
	     l_worktype_cache	      NUMBER;      -- Added for bug 5552078

       BEGIN
             lv_return_status := FND_API.G_RET_STS_SUCCESS;

             Print_message('Entering Build_FI_Dtl_Res');

             PA_DEBUG.Init_err_stack(
                       'PA_FORECASTITEM_PVT.Build_FI_Dtl_Res');

             TmpDayTab.Delete;
             TmpInsTab.Delete;
             TmpUpdTab.Delete;
	     l_worktype_cache := -1;     -- Added for Bug 5552078

             TmpDayTab := p_FIDayTab;


             Print_message(
                                  'Res - Get_resource_type');

             lv_resource_type := PA_FORECAST_ITEMS_UTILS.get_resource_type(
                                    p_resource_id);

             lv_amount_type_id := get_AmountTypeID;

             lv_person_id := PA_FORECAST_ITEMS_UTILS.get_person_id(
                                    p_resource_id);


             if (TmpDayTab.count <> 0) then
             FOR i IN TmpDayTab.FIRST..TmpDayTab.LAST LOOP
                 if TmpDayTab.exists(i) then
                 lv_inc_forecast_flag := TmpDayTab(i).include_in_forecast;

                 IF lv_inc_forecast_flag IN ('NO', 'N') THEN

                    lv_new_fcast_sum_code := 'X';

                 ELSE

                    lv_new_fcast_sum_code := 'N';

                 END IF;


/*
                 lv_new_fcast_sum_code := 'N';
*/

/* Bug No: 1967832 Removed original call to the function is_include_utilisation and added the followign conditions. */


                 IF TRUNC(TmpDayTab(i).item_date) BETWEEN TRUNC(lv_start_date) and TRUNC(nvl(lv_end_date,TmpDayTab(i).item_date))
                    AND i>TmpDaytab.FIRST
                    AND lv_person_id=tmp_person_id THEN

                      lv_inc_util_flag := lv_inc_util_flag;
                 ELSE

                    Is_Include_Utilisation(p_person_id     => lv_person_id,
                                           p_item_date     => TmpDayTab(i).item_date,
																				   x_start_date    => lv_start_date,
                                           x_end_date      => lv_end_date,
																					 x_inc_util_flag => lv_inc_util_flag,
                                           x_return_status => lv_return_status,
                                           x_msg_count     => x_msg_count,
                                           x_msg_data      => x_msg_data);
                    tmp_person_id := lv_person_id;

                 END IF;

                 IF lv_inc_util_flag IN ('NO', 'N') THEN

                    lv_new_util_sum_code := 'X';

                 ELSE

                    lv_new_util_sum_code := 'N';

                 END IF;

                 lv_provisional_flag := NULL;


--               Print_message(
--                                'Res - Get_work_type_details ');

		-- Added IF condition for Bug 5552078
		-- If the work_type_id is same as the previous loop iteration then no need to fetch it from the database. NVL check added since work_type_id may be passed as null
			-- IF (nvl(TmpDayTab(i).work_type_id, -99) <> nvl(l_worktype_cache, -99)) THEN
			IF (nvl(TmpDayTab(i).work_type_id, -199) <> nvl(l_worktype_cache, -199)) THEN --Bug 6202828 Changed the nvl value from -99 to -199
			Print_message('PA_FORECASTITEM_PVT.Build_FI_Dtl_Res : TmpDayTab(i).work_type_id not same as the previous value, get from the database');
			PA_FORECAST_ITEMS_UTILS.get_work_type_details(
					       TmpDayTab(i).work_type_id,
					       lv_billable_flag,
					       l_resutilweighted,
					       l_orgutilweighted,
					       l_resutilcategoryid,
					       l_orgutilcategoryid,
					       l_ReduceCapacityFlag);
		END IF;
		l_worktype_cache := TmpDayTab(i).work_type_id;
		-- End of changes for Bug 5552078

                 lv_next_line_num := 1;


                 IF d_in <= p_DBDtlTab.COUNT THEN


                    IF trunc(TmpDayTab(i).item_date) <
                             trunc(p_DBDtlTab(d_in).item_date) THEN

                       -- New record
                       lv_next_line_num := 1;

                    ELSIF trunc(TmpDayTab(i).item_date) =
                                trunc(p_dbDtlTab(d_in).item_date) THEN
                       -- Record exists

                       IF TmpDayTab(i).action_flag  = 'C' THEN

                          -- Check IF there are changes in
                             -- person_billable, resource_type
                             -- work_type_id
                          IF ((NVL(p_DBDtlTab(d_in).forecast_summarized_code,'Y')
                                          IN ('N', 'Y')
                                 AND lv_new_fcast_sum_code = 'X') OR
                              (p_DBDtlTab(d_in).forecast_summarized_code = 'X'
                                 AND lv_new_fcast_sum_code = 'N') OR
                              (NVL(p_DBDtlTab(d_in).PJI_SUMMARIZED_FLAG,'Y')
                                          IN ('N', 'Y')
                                 AND lv_new_util_sum_code = 'X') OR
                              (p_DBDtlTab(d_in).PJI_SUMMARIZED_FLAG = 'X'
                                 AND lv_new_util_sum_code = 'N') OR

                              (NVL(p_DBDtlTab(d_in).util_summarized_code,'Y')
                                          IN ('N', 'Y')
                                 AND lv_new_util_sum_code = 'X') OR
                              (p_DBDtlTab(d_in).util_summarized_code = 'X'
                                 AND lv_new_util_sum_code = 'N') OR
                              (NVL(p_DBDtlTab(d_in).work_type_id,-99) <>
                                  NVL(TmpDayTab(i).work_type_id,-99)) OR
                              (nvl(p_DBDtlTab(d_in).JOB_ID,-99) <>
                                  NVL(TmpDayTab(i).JOB_ID,-99))  OR
                              (NVL(p_DBDtlTab(d_in).person_billable_flag,'Z') <>
                                  NVL(TmpDayTab(i).person_billable_flag,'Z')) OR
                              (NVL(p_DBDtlTab(d_in).resource_type_code,'Z') <>
                                  NVL(lv_resource_type,'Z'))) THEN

                             TmpDayTab(i).action_flag := 'RN';

                          ELSE

                              TmpDayTab(i).action_flag := 'I';

                          END IF;

                       END IF;


                       IF TmpDayTab(i).action_flag  in ('DN', 'D') THEN

                          -- Change IN header attribute values
                          -- update existing line FOR flags
                          -- Reverse detail line IF forecast/util
                              --summarization done
                          -- IF summ not done IN existing line;
                              -- item_quantity to zero
                              -- net_zero flag to Y
                              -- forecast/util summ_flag = 'X'
                          -- New line generation is done at the end

                          lv_next_line_num := 1;

                          IF NVL(p_DBDtlTab(d_in).forecast_summarized_code,'Y')
                                            IN ('N', 'X', 'E')
                             AND NVL(p_DBDtlTab(d_in).PJI_SUMMARIZED_FLAG,'Y')
                                            IN ('N', 'X', 'E')
                             AND NVl(p_DBDtlTab(d_in).util_summarized_code,'Y')
                                            IN ('N', 'X', 'E') THEN

                             TmpUpdTab(u_in) := p_dbDtlTab(d_in);
                             TmpUpdTab(u_in).forecast_summarized_code := 'X';
                             TmpUpdTab(u_in).PJI_SUMMARIZED_FLAG := 'X';
                             TmpUpdTab(u_in).util_summarized_code := 'X';
                             TmpUpdTab(u_in).CAPACITY_QUANTITY := NULL;
                             TmpUpdTab(u_in).OVERCOMMITMENT_QTY := NULL;
                             TmpUpdTab(u_in).OVERPROVISIONAL_QTY := NULL;
                             TmpUpdTab(u_in).OVER_PROV_CONF_QTY := NULL;
                             TmpUpdTab(u_in).CONFIRMED_QTY := NULL;
                             TmpUpdTab(u_in).PROVISIONAL_QTY := NULL;
                             TmpUpdTab(u_in).item_quantity := 0;
                             TmpUpdTab(u_in).org_util_weighted :=0;
                             TmpUpdTab(u_in).resource_util_weighted :=0;
                             TmpUpdTab(u_in).net_zero_flag := 'Y';
                             u_in := u_in + 1;

                          ELSE

                             TmpUpdTab(u_in) := p_DBDtlTab(d_in);

                             IF (
                                 p_DBDtlTab(d_in).CAPACITY_QUANTITY > 0 OR
                                 p_DBDtlTab(d_in).OVERCOMMITMENT_QTY > 0 OR
                                 p_DBDtlTab(d_in).OVERPROVISIONAL_QTY > 0 OR
                                 p_DBDtlTab(d_in).OVER_PROV_CONF_QTY > 0 OR
                                 p_DBDtlTab(d_in).CONFIRMED_QTY > 0 OR
                                 p_DBDtlTab(d_in).PROVISIONAL_QTY > 0 OR
                                 p_DBDtlTab(d_in).item_quantity > 0
                                 ) THEN

                                -- Generate reverse line
                                TmpInsTab(i_in) := p_DBDtlTab(d_in);
                                TmpInsTab(i_in).line_num :=
                                           p_DBDtlTab(d_in).line_num + 1;
                                IF (NVL(TmpInsTab(i_in).CAPACITY_QUANTITY,0) = 0) THEN
                                   TmpInsTab(i_in).CAPACITY_QUANTITY := NULL;
                                ELSE
                                   TmpInsTab(i_in).CAPACITY_QUANTITY := NVL(TmpInsTab(i_in).CAPACITY_QUANTITY,0) * -1;
                                END IF;
                                IF (NVL(TmpInsTab(i_in).OVERCOMMITMENT_QTY,0) = 0) THEN
                                   TmpInsTab(i_in).OVERCOMMITMENT_QTY := NULL;
                                ELSE
                                   TmpInsTab(i_in).OVERCOMMITMENT_QTY := NVL(TmpInsTab(i_in).OVERCOMMITMENT_QTY,0) * -1;
                                END IF;
                                IF (NVL(TmpInsTab(i_in).OVERPROVISIONAL_QTY,0) = 0) THEN
                                   TmpInsTab(i_in).OVERPROVISIONAL_QTY := NULL;
                                ELSE
                                   TmpInsTab(i_in).OVERPROVISIONAL_QTY := NVL(TmpInsTab(i_in).OVERPROVISIONAL_QTY,0) * -1;
                                END IF;
                                IF (NVL(TmpInsTab(i_in).OVER_PROV_CONF_QTY,0) = 0) THEN
                                   TmpInsTab(i_in).OVER_PROV_CONF_QTY := NULL;
                                ELSE
                                   TmpInsTab(i_in).OVER_PROV_CONF_QTY := NVL(TmpInsTab(i_in).OVER_PROV_CONF_QTY,0) * -1;
                                END IF;
                                IF (NVL(TmpInsTab(i_in).CONFIRMED_QTY,0) = 0) THEN
                                   TmpInsTab(i_in).CONFIRMED_QTY := NULL;
                                ELSE
                                   TmpInsTab(i_in).CONFIRMED_QTY := NVL(TmpInsTab(i_in).CONFIRMED_QTY,0) * -1;
                                END IF;
                                IF (NVL(TmpInsTab(i_in).PROVISIONAL_QTY,0) = 0) THEN
                                   TmpInsTab(i_in).PROVISIONAL_QTY := NULL;
                                ELSE
                                   TmpInsTab(i_in).PROVISIONAL_QTY := NVL(TmpInsTab(i_in).PROVISIONAL_QTY,0) * -1;
                                END IF;
                                TmpInsTab(i_in).item_quantity :=
                                           TmpInsTab(i_in).item_quantity * -1;
                                TmpInsTab(i_in).resource_util_weighted :=
                                          TmpInsTab(i_in).resource_util_weighted * -1;
                                TmpInsTab(i_in).org_util_weighted :=
                                          TmpInsTab(i_in).org_util_weighted * -1;
                                TmpInsTab(i_in).reversed_flag := 'N';
                                TmpInsTab(i_in).line_num_reversed :=
                                           p_DBDtlTab(d_in).line_num;
                                TmpInsTab(i_in).net_zero_flag := 'Y';

                                IF NVL(p_DBDtlTab(d_in).forecast_summarized_code,'Y') =
                                                     'Y' THEN

                                   TmpInsTab(i_in).forecast_summarized_code :=
                                                       'N';

                                ELSE

                                   TmpInsTab(i_in).forecast_summarized_code :=
                                      p_DBDtlTab(d_in).forecast_summarized_code;

                                END IF;

                    IF NVL(p_DBDtlTab(d_in).PJI_SUMMARIZED_FLAG,'Y') = 'Y' THEN
                      TmpInsTab(i_in).PJI_SUMMARIZED_FLAG := 'N';
                    ELSE
                      TmpInsTab(i_in).PJI_SUMMARIZED_FLAG :=
                              p_DBDtlTab(d_in).PJI_SUMMARIZED_FLAG;
                    END IF;

                                IF NVL(p_DBDtlTab(d_in).util_summarized_code,'Y') = 'Y'
                                       THEN

                                   TmpInsTab(i_in).util_summarized_code := 'N';

                                ELSE

                                   TmpInsTab(i_in).util_summarized_code :=
                                      p_DBDtlTab(d_in).util_summarized_code;

                                END IF;

                                i_in := i_in + 1;

                                -- update line
                                TmpUpdTab(u_in).reversed_flag := 'Y';

                             END IF;

                             TmpUpdTab(u_in).net_zero_flag := 'Y';
                             u_in := u_in + 1;

                          END IF;

                       ELSIF TmpDayTab(i).action_flag  = 'RN' THEN

                          -- No change IN header
                          -- There is change IN item_quantity/provisional_flag/
                             -- include IN forecast/work_type_id
                          -- If summarization is not done
                          --   same line to be updated with new values
                          --   generated. Save forecast_item_id

                          IF NVL(p_DBDtlTab(d_in).forecast_summarized_code,'Y')
                                            IN ('N', 'X', 'E')
                             AND NVL(p_DBDtlTab(d_in).PJI_SUMMARIZED_FLAG,'Y')
                                            IN ('N', 'X', 'E')
                             AND NVL(p_DBDtlTab(d_in).util_summarized_code,'Y')
                                            IN ('N', 'X', 'E') THEN

                             TmpDayTab(i).action_flag := 'RU';
                             TmpDayTab(i).forecast_item_id :=
                                          p_dbDtlTab(d_in).forecast_item_id;
                             lv_next_line_num := p_DBDtlTab(d_in).line_num;

                          ELSE

                             TmpDayTab(i).forecast_item_id :=
                                      p_dbDtlTab(d_in).forecast_item_id;

                             TmpUpdTab(u_in) := p_DBDtlTab(d_in);

                             lv_next_line_num :=
                                          p_DBDtlTab(d_in).line_num + 1;

                             IF (
                                 nvl(p_DBDtlTab(d_in).CAPACITY_QUANTITY,0) > 0 OR
                                 nvl(p_DBDtlTab(d_in).OVERCOMMITMENT_QTY,0) > 0 OR
                                 nvl(p_DBDtlTab(d_in).OVERPROVISIONAL_QTY,0) > 0 OR
                                 nvl(p_DBDtlTab(d_in).OVER_PROV_CONF_QTY,0) > 0 OR
                                 nvl(p_DBDtlTab(d_in).CONFIRMED_QTY,0) > 0 OR
                                 nvl(p_DBDtlTab(d_in).PROVISIONAL_QTY,0) > 0 OR
                                 nvl(p_dbdtltab(d_in).item_quantity,0) > 0
                                 )THEN

                                -- Generate Reverse Line
                                TmpInsTab(i_in) := p_DBDtlTab(d_in);
                                TmpInsTab(i_in).line_num := lv_next_line_num;
                                lv_next_line_num := lv_next_line_num + 1;
                                IF (NVL(TmpInsTab(i_in).CAPACITY_QUANTITY,0) = 0) THEN
                                   TmpInsTab(i_in).CAPACITY_QUANTITY := NULL;
                                ELSE
                                   TmpInsTab(i_in).CAPACITY_QUANTITY := NVL(TmpInsTab(i_in).CAPACITY_QUANTITY,0) * -1;
                                END IF;
                                IF (NVL(TmpInsTab(i_in).OVERCOMMITMENT_QTY,0) = 0) THEN
                                   TmpInsTab(i_in).OVERCOMMITMENT_QTY := NULL;
                                ELSE
                                   TmpInsTab(i_in).OVERCOMMITMENT_QTY := NVL(TmpInsTab(i_in).OVERCOMMITMENT_QTY,0) * -1;
                                END IF;
                                IF (NVL(TmpInsTab(i_in).OVERPROVISIONAL_QTY,0) = 0) THEN
                                   TmpInsTab(i_in).OVERPROVISIONAL_QTY := NULL;
                                ELSE
                                   TmpInsTab(i_in).OVERPROVISIONAL_QTY := NVL(TmpInsTab(i_in).OVERPROVISIONAL_QTY,0) * -1;
                                END IF;
                                IF (NVL(TmpInsTab(i_in).OVER_PROV_CONF_QTY,0) = 0) THEN
                                   TmpInsTab(i_in).OVER_PROV_CONF_QTY := NULL;
                                ELSE
                                   TmpInsTab(i_in).OVER_PROV_CONF_QTY := NVL(TmpInsTab(i_in).OVER_PROV_CONF_QTY,0) * -1;
                                END IF;
                                IF (NVL(TmpInsTab(i_in).CONFIRMED_QTY,0) = 0) THEN
                                   TmpInsTab(i_in).CONFIRMED_QTY := NULL;
                                ELSE
                                   TmpInsTab(i_in).CONFIRMED_QTY := NVL(TmpInsTab(i_in).CONFIRMED_QTY,0) * -1;
                                END IF;
                                IF (NVL(TmpInsTab(i_in).PROVISIONAL_QTY,0) = 0) THEN
                                   TmpInsTab(i_in).PROVISIONAL_QTY := NULL;
                                ELSE
                                   TmpInsTab(i_in).PROVISIONAL_QTY := NVL(TmpInsTab(i_in).PROVISIONAL_QTY,0) * -1;
                                END IF;
                                TmpInsTab(i_in).item_quantity :=
                                          p_DBDtlTab(d_in).item_quantity * -1;
                                TmpInsTab(i_in).resource_util_weighted :=
                                          p_DBDtlTab(d_in).resource_util_weighted * -1;
                                TmpInsTab(i_in).org_util_weighted :=
                                          p_DBDtlTab(d_in).org_util_weighted * -1;
                                TmpInsTab(i_in).reversed_flag := 'N';
                                TmpInsTab(i_in).line_num_reversed :=
                                          p_DBDtlTab(d_in).line_num;
                                TmpInsTab(i_in).net_zero_flag := 'Y';

                                IF NVL(p_DBDtlTab(d_in).forecast_summarized_code,'Y') =
                                                   'Y' THEN

                                   TmpInsTab(i_in).forecast_summarized_code :=
                                                       'N';
                                ELSE

                                   TmpInsTab(i_in).forecast_summarized_code :=
                                     p_DBDtlTab(d_in).forecast_summarized_code;

                                END IF;

                    IF NVL(p_DBDtlTab(d_in).PJI_SUMMARIZED_FLAG,'Y') = 'Y' THEN
                      TmpInsTab(i_in).PJI_SUMMARIZED_FLAG := 'N';
                    ELSE
                      TmpInsTab(i_in).PJI_SUMMARIZED_FLAG :=
                              p_DBDtlTab(d_in).PJI_SUMMARIZED_FLAG;
                    END IF;

                                IF NVL(p_DBDtlTab(d_in).util_summarized_code,'Y') = 'Y'
                                      THEN

                                   TmpInsTab(i_in).util_summarized_code := 'N';

                                ELSE

                                   TmpInsTab(i_in).util_summarized_code :=
                                     p_DBDtlTab(d_in).util_summarized_code;

                                END IF;

                                i_in := i_in + 1;

                                -- update Line
                                TmpUpdTab(u_in).reversed_flag := 'Y';

                             END IF;

                             TmpUpdTab(u_in).net_zero_flag := 'Y';
                             u_in := u_in + 1;

                          END IF;

                       END IF;

                       d_in := d_in + 1;

                    END IF;

                 END IF;

                 -- N New record/new line
                 -- DN Existing record has header changes
                     -- New record/new line
                 -- RN Existing record detail changes
                   -- The values are already summarized
                   -- Create new line
                 -- RU Existing record has detail changes
                   -- The values are not summarized
                   -- update existing line with new values
                 -- All attribute values are.FIRST generated IN Tmp_rec
                 -- IF action_flag is N,DN,RN copied to TmpInsTab
                 -- ELSE copied to TmpUpdTab

-- Start bug fix 2148257
-- Remove item_quantity check because of new capacity records.
--                IF (TmpDayTab(i).action_flag IN ('N', 'DN', 'RN','RU')  AND
--                       TmpDayTab(i).item_quantity > 0 ) THEN
                  IF (TmpDayTab(i).action_flag IN ('N', 'DN', 'RN','RU')  AND
                           (NVL(TmpDayTab(i).item_quantity,0) > 0 OR
                             NVL(TmpDayTab(i).OVERPROVISIONAL_QTY,0) > 0 OR
                             NVL(TmpDayTab(i).OVER_PROV_CONF_QTY,0) > 0 OR
                             NVL(TmpDayTab(i).CONFIRMED_QTY,0) > 0 OR
                             NVL(TmpDayTab(i).PROVISIONAL_QTY,0) > 0 OR
                             NVL(TmpDayTab(i).capacity_quantity,0) > 0 OR
                             NVL(TmpDayTab(i).availability_quantity,0) > 0 OR
                             NVL(TmpDayTab(i).overcommitment_quantity,0) > 0)) THEN
-- End bug fix 2148257

                    -- create new line
                    TmpDtlRec.forecast_item_id := TmpDayTab(i).forecast_item_id;
                    TmpDtlRec.amount_type_id := lv_amount_type_id;
                    TmpDtlRec.line_num := lv_next_line_num;
                    TmpDtlRec.resource_type_code := lv_resource_type;
                    TmpDtlRec.person_billable_flag :=
                                           TmpDayTab(i).person_billable_flag;
                    TmpDtlRec.item_date := TmpDayTab(i).item_date;
                    TmpDtlRec.expenditure_org_id :=
                                        TmpDayTab(i).expenditure_org_id;
                    TmpDtlRec.job_id :=
                                        TmpDayTab(i).job_id;
                    TmpDtlRec.project_id :=
                                        TmpDayTab(i).project_id;
                    TmpDtlRec.resource_id :=
                                        TmpDayTab(i).resource_id;
                    TmpDtlRec.expenditure_organization_id :=
                                        TmpDayTab(i).expenditure_organization_id;
                    TmpDtlRec.project_org_id := TmpDayTab(i).project_org_id;
                    TmpDtlRec.item_uom := 'HOURS';
                    TmpDtlRec.CAPACITY_QUANTITY := TmpDayTab(i).CAPACITY_QUANTITY;
                    TmpDtlRec.OVERCOMMITMENT_QTY := TmpDayTab(i).OVERCOMMITMENT_QTY;
                    TmpDtlRec.OVERPROVISIONAL_QTY := TmpDayTab(i).OVERPROVISIONAL_QTY;
                    TmpDtlRec.OVER_PROV_CONF_QTY := TmpDayTab(i).OVER_PROV_CONF_QTY;
                    TmpDtlRec.CONFIRMED_QTY := TmpDayTab(i).CONFIRMED_QTY;
                    TmpDtlRec.PROVISIONAL_QTY := TmpDayTab(i).PROVISIONAL_QTY;
                    TmpDtlRec.item_quantity := TmpDayTab(i).item_quantity;
                    TmpDtlRec.pvdr_acct_curr_code := NULL;
                    TmpDtlRec.pvdr_acct_amount := NULL;
                    TmpDtlRec.rcvr_acct_curr_code := NULL;
                    TmpDtlRec.rcvr_acct_amount := NULL;
                    TmpDtlRec.proj_currency_code := NULL;
                    TmpDtlRec.proj_amount := NULL;
                    TmpDtlRec.denom_currency_code := NULL;
                    TmpDtlRec.denom_amount := NULL;
                    TmpDtlRec.tp_amount_type := TmpDayTab(i).tp_amount_type;
                    TmpDtlRec.billable_flag := lv_billable_flag;
                    TmpDtlRec.forecast_summarized_code :=
                                  lv_new_fcast_sum_code ;
                    TmpDtlRec.PJI_SUMMARIZED_FLAG := lv_new_util_sum_code;
                    TmpDtlRec.util_summarized_code :=
                                  lv_new_util_sum_code ;

                    IF TmpDayTab(i).Error_flag = 'Y' THEN

                       TmpDtlRec.PJI_SUMMARIZED_FLAG := 'E';
                       TmpDtlRec.util_summarized_code := 'E';
                       TmpDtlRec.forecast_summarized_code := 'E';

                    END IF;

                    TmpDtlRec.work_type_id := TmpDayTab(i).work_type_id;
                    TmpDtlRec.resource_util_category_id :=
                                                l_resutilcategoryid;
                    TmpDtlRec.org_util_category_id :=
                                                l_orgutilcategoryid;
                    TmpDtlRec.resource_util_weighted :=
                          TmpDayTab(i).item_quantity *
                                    l_resutilweighted/100;
                    TmpDtlRec.org_util_weighted :=
                          TmpDayTab(i).item_quantity *
                                       l_orgutilweighted/100;
                    TmpDtlRec.Reduce_Capacity_Flag := l_ReduceCapacityFlag;
                    TmpDtlRec.provisional_flag := 'N';
                    TmpDtlRec.reversed_flag := 'N';
                    TmpDtlRec.net_zero_flag := 'N';
                    TmpDtlRec.line_num_reversed := 0;

                    IF TmpDayTab(i).action_flag = 'RU' THEN

                       TmpUpdTab(u_in) := TmpDtlRec;
                       u_in := u_in + 1;

                    ELSE

                       TmpInsTab(i_in) := TmpDtlRec;
                       i_in := i_in + 1;

                    END IF;

/*
                 Print_message('***********');

                 Print_message(
                    'item_date:' || TmpDtlRec.item_date);

                 Print_message(
                    'fct_item_id:' || TmpDtlRec.forecast_item_id ||
                    ' amt_typ_id:' || TmpDtlRec.amount_type_id  ||
                    ' line_num:' || TmpDtlRec.line_num ||
                    chr(10) || 'Res_typ_cd  :' ||
                               TmpDtlRec.resource_type_code ||
                    ' per_bil_fl:' ||
                               TmpDtlRec.person_billable_flag ||
                    ' item_uom:' || TmpDtlRec.item_uom );

                 Print_message(
                    ' item_qty:' || TmpDtlRec.item_quantity ||
                    ' exp_org_id:' ||
                               TmpDtlRec.expenditure_org_id ||
                    ' prj_org_id:' ||
                               TmpDtlRec.project_org_id ||
                    ' tp_amt_typ:' || TmpDtlRec.tp_amount_type ||
                    chr(10) || 'bill_flag:' || TmpDtlRec.billable_flag ||
                    ' fcs_sum_cd:' ||
                               TmpDtlRec.forecast_summarized_code ||
                    ' utl_sum_cd:' ||
                               TmpDtlRec.util_summarized_code );

                 Print_message(
                    ' wrk_typ_id:' || TmpDtlRec.work_type_id ||
                    ' res_utl_id:' ||
                               TmpDtlRec.resource_util_category_id ||
                    ' org_utl_id:' ||
                               TmpDtlRec.org_util_category_id ||
                    ' res_utl_wt:' ||
                               TmpDtlRec.resource_util_weighted ||
                    chr(10) || 'org_utl_wt:' ||
                               TmpDtlRec.org_util_weighted ||
                    ' prv_flag:' || TmpDtlRec.provisional_flag ||
                    ' rev_flag:' || TmpDtlRec.reversed_flag ||
                    ' net_zer_fl:' || TmpDtlRec.net_zero_flag ||
                    ' ln_num_rev:' ||
                               TmpDtlRec.line_num_reversed);
*/

                 END IF;
             end if;
             END LOOP;
             end if;


             x_FIDtlInsTab := TmpInsTab;
             x_FIDtlUpdTab := TmpUpdTab;

             Print_message('Leaving Build_FI_Dtl_Res');

             x_return_status := FND_API.G_RET_STS_SUCCESS;

             PA_DEBUG.Reset_Err_Stack;

             x_return_status := lv_return_status;

        EXCEPTION

             WHEN OTHERS THEN
		  Print_message('Failed in Build_FI_Dtl_Res api');
		  Print_message('SQLERR '||sqlcode||sqlerrm);

                  x_msg_count     := 1;
                  x_msg_data      := sqlerrm;
                  x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

                  FND_MSG_PUB.add_exc_msg
                      (p_pkg_name   =>
                              'PA_FORECASTITEM_PVT.Build_FI_Dtl_Res',
                       p_procedure_name => PA_DEBUG.G_Err_Stack);

		               If x_msg_count = 1 THEN
				              pa_interface_utils_pub.get_messages
				                (p_encoded        => FND_API.G_TRUE,
					               p_msg_index      => 1,
					               p_msg_count      => x_msg_count,
					               p_msg_data       => x_msg_data,
					               p_data           => l_data,  -- 4537865
					               p_msg_index_out  => l_msg_index_out );
						x_msg_data := l_data ;  -- 4537865
		               End If;
                  Print_message(x_msg_data);


                  RAISE;


       END Build_FI_Dtl_Res;

/* ---------------------------------------------------------------------
|   Procedure  :   Resource_Unasg_Error_Process
|   Purpose    :   To process errored out records (by previous run)of
|                  resource unassigned time
|   Parameters :   p_ErrHdrTab  - Table of Resource forecast items which
|                                 have errored out IN previous runs.
|                                 It has the format of pa_forecast_item
|                                 table
|                  p_process_mode   - Mode of Processing.
|                    a) ERROR       : Regeneration of Errored forecast items
|                                     by previous runs
|                  x_return_status  -
|                  x_msg_count      -
|                  x_msg_data       -
+----------------------------------------------------------------------*/
       PROCEDURE Resource_Unasg_Error_Process(
                 p_ErrHdrTab     IN     PA_FORECAST_GLOB.FIHdrTabTyp,
                 p_process_mode  IN     VARCHAR2,
                 x_return_status OUT   NOCOPY  VARCHAR2,  -- 4537865
                 x_msg_count     OUT   NOCOPY  NUMBER,  -- 4537865
                 x_msg_data      OUT   NOCOPY VARCHAR2) IS   -- 4537865

	           l_msg_index_out	            NUMBER;
		   l_data varchar2(2000);  -- 4537865
             lv_prev_resource_id   NUMBER;
             lv_next_date      DATE;
             lv_start_date     DATE;
             lv_end_date       DATE;
             TmpHdrTab         PA_FORECAST_GLOB.FIHdrTabTyp;
             lv_ind            NUMBER;

             lv_return_status  VARCHAR2(30);

       BEGIN

             lv_return_status := FND_API.G_RET_STS_SUCCESS;

             Print_message(
                   'Entering Resource_Unasg_Error_Process');

             PA_DEBUG.Init_err_stack(
                       'PA_FORECASTITEM_PVT.Resource_Unasg_Error_Process');

             lv_prev_resource_id := p_ErrHdrTab(p_ErrHdrTab.FIRST).resource_id;
             lv_next_date := p_ErrHdrTab(p_ErrHdrTab.FIRST).item_date ;
             lv_start_date := p_ErrHdrTab(p_ErrHdrTab.FIRST).item_date ;
             lv_ind := 1;

             TmpHdrTab.Delete;

             if (p_ErrHdrTab.count <> 0) then
             FOR i IN p_ErrHdrTab.FIRST..p_ErrHdrTab.LAST LOOP
                 if p_ErrHdrTab.exists(i) then

                 IF ((lv_prev_resource_id <> p_ErrHdrTab(i).resource_id) OR
                    (trunc(p_ErrHdrTab(i).item_date) <>
                                   trunc(lv_next_date) )) THEN

                     lv_end_date := lv_next_date - 1;

                     Print_message(
                             'Calling Regenerate_Res_Unassigned_FI');

                     IF lv_return_status = FND_API.G_RET_STS_SUCCESS THEN

                        Regenerate_Res_Unassigned_FI(
                              p_resource_id => lv_prev_resource_id,
                              p_start_date  => lv_start_date,
                              p_end_date  => lv_end_date,
                              p_process_mode => p_process_mode,
                              p_ErrHdrTab   => TmpHdrTab,
                              x_return_status => lv_return_status,
                              x_msg_count  => x_msg_count,
                              x_msg_data   => x_msg_data );
                     END IF;

                     lv_prev_resource_id := p_ErrHdrTab(i).resource_id;
                     lv_start_date   := p_ErrHdrTab(i).item_date;
                     lv_next_date    := p_ErrHdrTab(i).item_date;
                     TmpHdrTab.delete;
                     lv_ind := 1;

                 END IF;

                 TmpHdrTab(lv_ind) := p_ErrHdrTab(i);
                 lv_ind := lv_ind + 1;
                 lv_next_date    := lv_next_date + 1;
             end if;
             END LOOP;
             end if;

             -- Do FOR.LAST record.LAST set of records
             lv_end_date := p_ErrHdrTab(p_ErrHdrTab.LAST).item_date;

             IF lv_return_status = FND_API.G_RET_STS_SUCCESS THEN

                Print_message( 'Calling Regenerate_Res_Unassigned_FI 2 ');

                Regenerate_Res_Unassigned_FI(
                        p_resource_id => lv_prev_resource_id,
                        p_start_date  => lv_start_date,
                        p_end_date  => lv_end_date,
                        p_process_mode => p_process_mode,
                        p_ErrHdrTab   => TmpHdrTab,
                        x_return_status => lv_return_status,
                        x_msg_count  => x_msg_count,
                        x_msg_data   => x_msg_data );
             END IF;


             Print_message(
                   'Leaving Resource_Unasg_Error_Process');

             PA_DEBUG.Reset_Err_Stack;

             x_return_status := lv_return_status;

        EXCEPTION

             WHEN OTHERS THEN
                  Print_message('Failed in Resource_Unasg_Error_Process api');
                  Print_message('SQLERR '||sqlcode||sqlerrm);

                  x_msg_count     := 1;
                  x_msg_data      := sqlerrm;
                  x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

                  FND_MSG_PUB.add_exc_msg
                      (p_pkg_name   =>
                          'PA_FORECASTITEM_PVT.Resource_Unasg_Error_Process',
                       p_procedure_name => PA_DEBUG.G_Err_Stack);

		               If x_msg_count = 1 THEN
				              pa_interface_utils_pub.get_messages
				                (p_encoded        => FND_API.G_TRUE,
					               p_msg_index      => 1,
					               p_msg_count      => x_msg_count,
					               p_msg_data       => x_msg_data,
					               p_data           => l_data,  -- 4537865
					               p_msg_index_out  => l_msg_index_out );
						x_msg_data := l_data ;  -- 4537865
		               End If;
                  Print_message(x_msg_data);


                  RAISE;

       END Resource_Unasg_Error_Process;

/* ---------------------------------------------------------------------
|   Procedure  :   FI_Error_Process
|   Purpose    :   To process errored out records (by previous run)of
|                  Requirement/Assignment Forecast Item
|   Parameters :   p_AsgnDtlRec    - Details of the assignment FOR which
|                                    forecast item is to be re-generated
|                    a) ERROR       : Regeneration of Errored forecast items
|                                     by previous runs
|                  x_return_status  -
|                  x_msg_count      -
|                  x_msg_data       -
+----------------------------------------------------------------------*/

       PROCEDURE FI_Error_Process(
                 p_AsgnDtlRec    IN   PA_FORECAST_GLOB.AsgnDtlRecord,
                 p_Process_Mode  IN   VARCHAR2,
                 p_start_date    IN   DATE,
                 p_end_date      IN   DATE,
                 x_return_status OUT NOCOPY VARCHAR2,  -- 4537865
                 x_msg_count     OUT NOCOPY NUMBER,  -- 4537865
                 x_msg_data      OUT NOCOPY VARCHAR2) IS  -- 4537865

		  l_data varchar2(2000);  -- 4537865
	           l_msg_index_out	            NUMBER;
             TmpErrHdrTab                        PA_FORECAST_GLOB.FIHdrTabtyp;

             forecast_item_id_tab                PA_FORECAST_GLOB.NumberTabTyp;
             forecast_item_type_tab              PA_FORECAST_GLOB.VCTabTyp;
             project_org_id_tab                  PA_FORECAST_GLOB.NumberTabTyp;
             expenditure_org_id_tab              PA_FORECAST_GLOB.NumberTabTyp;
             expenditure_orgn_id_tab             PA_FORECAST_GLOB.NumberTabTyp;
             project_organization_id_tab         PA_FORECAST_GLOB.NumberTabTyp;
             project_id_tab                      PA_FORECAST_GLOB.NumberTabTyp;
             project_type_class_tab              PA_FORECAST_GLOB.VCTabTyp;
             person_id_tab                       PA_FORECAST_GLOB.NumberTabTyp;
             resource_id_tab                     PA_FORECAST_GLOB.NumberTabTyp;
             borrowed_flag_tab                   PA_FORECAST_GLOB.VC1TabTyp;
             assignment_id_tab                   PA_FORECAST_GLOB.NumberTabTyp;
             item_date_tab                       PA_FORECAST_GLOB.DateTabTyp;
             item_uom_tab                        PA_FORECAST_GLOB.VCTabTyp;
             item_quantity_tab                   PA_FORECAST_GLOB.NumberTabTyp;
             pvdr_period_set_name_tab            PA_FORECAST_GLOB.VCTabTyp;
             pvdr_pa_period_name_tab             PA_FORECAST_GLOB.VCTabTyp;
             pvdr_gl_period_name_tab             PA_FORECAST_GLOB.VCTabTyp;
             rcvr_period_set_name_tab            PA_FORECAST_GLOB.VCTabTyp;
             rcvr_pa_period_name_tab             PA_FORECAST_GLOB.VCTabTyp;
             rcvr_gl_period_name_tab             PA_FORECAST_GLOB.VCTabTyp;
             global_exp_period_end_date_tab      PA_FORECAST_GLOB.DateTabTyp;
             expenditure_type_tab                PA_FORECAST_GLOB.VCTabTyp;
             expenditure_type_class_tab          PA_FORECAST_GLOB.VCTabTyp;
             cost_rejection_code_tab             PA_FORECAST_GLOB.VCTabTyp;
             rev_rejection_code_tab              PA_FORECAST_GLOB.VCTabTyp;
             tp_rejection_code_tab               PA_FORECAST_GLOB.VCTabTyp;
             burden_rejection_code_tab           PA_FORECAST_GLOB.VCTabTyp;
             other_rejection_code_tab            PA_FORECAST_GLOB.VCTabTyp;
             delete_flag_tab                     PA_FORECAST_GLOB.VC1TabTyp;
             error_flag_tab                      PA_FORECAST_GLOB.VC1TabTyp;
             provisional_flag_tab                PA_FORECAST_GLOB.VC1TabTyp;
             JOB_ID_tab           PA_FORECAST_GLOB.NumberTabTyp;
             TP_AMOUNT_TYPE_tab           PA_FORECAST_GLOB.VCTabTyp;
             OVERPROVISIONAL_QTY_tab           PA_FORECAST_GLOB.NumberTabTyp;
             OVER_PROV_CONF_QTY_tab           PA_FORECAST_GLOB.NumberTabTyp;
             CONFIRMED_QTY_tab           PA_FORECAST_GLOB.NumberTabTyp;
             PROVISIONAL_QTY_tab           PA_FORECAST_GLOB.NumberTabTyp;
             asgmt_sys_status_code_tab           PA_FORECAST_GLOB.VCTabTyp;
             capacity_quantity_tab               PA_FORECAST_GLOB.NumberTabTyp;
             overcommitment_quantity_tab         PA_FORECAST_GLOB.NumberTabTyp;
             availability_quantity_tab           PA_FORECAST_GLOB.NumberTabTyp;
             overcommitment_flag_tab             PA_FORECAST_GLOB.VC1TabTyp;
             availability_flag_tab               PA_FORECAST_GLOB.VC1TabTyp;

             lv_prev_asgn_id                     NUMBER;
             lv_next_date                        DATE;
             lv_start_date                       DATE;
             lv_end_date                         DATE;
             TmpHdrTab                           PA_FORECAST_GLOB.FIHdrTabTyp;
             lv_ind                              NUMBER;

             lv_dmy_start_date                   DATE;
             lv_dmy_end_date                     DATE;

             lv_return_status  VARCHAR2(30);

       BEGIN

             lv_return_status := FND_API.G_RET_STS_SUCCESS;

             Print_message ( 'Entering FI_Error_Process');

             PA_DEBUG.Init_err_stack( 'PA_FORECASTITEM_PVT.FI_Error_Process');

             forecast_item_id_tab.delete;
             forecast_item_type_tab.delete;
             project_org_id_tab.delete;
             expenditure_org_id_tab.delete;
             expenditure_orgn_id_tab.delete;
             project_organization_id_tab.delete;
             project_id_tab.delete;
             project_type_class_tab.delete;
             person_id_tab.delete;
             resource_id_tab.delete;
             borrowed_flag_tab.delete;
             assignment_id_tab.delete;
             item_date_tab.delete;
             item_uom_tab.delete;
             item_quantity_tab.delete;
             pvdr_period_set_name_tab.delete;
             pvdr_pa_period_name_tab.delete;
             pvdr_gl_period_name_tab.delete;
             rcvr_period_set_name_tab.delete;
             rcvr_pa_period_name_tab.delete;
             rcvr_gl_period_name_tab.delete;
             global_exp_period_end_date_tab.delete;
             expenditure_type_tab.delete;
             expenditure_type_class_tab.delete;
             cost_rejection_code_tab.delete;
             rev_rejection_code_tab.delete;
             tp_rejection_code_tab.delete;
             burden_rejection_code_tab.delete;
             other_rejection_code_tab.delete;
             delete_flag_tab.delete;
             error_flag_tab.delete;
             provisional_flag_tab.delete;
             JOB_ID_tab.delete;
             TP_AMOUNT_TYPE_tab.delete;
             OVERPROVISIONAL_QTY_tab.delete;
             OVER_PROV_CONF_QTY_tab.delete;
             CONFIRMED_QTY_tab.delete;
             PROVISIONAL_QTY_tab.delete;
             asgmt_sys_status_code_tab.delete;
             capacity_quantity_tab.delete;
             overcommitment_quantity_tab.delete;
             availability_quantity_tab.delete;
             overcommitment_flag_tab.delete;
             availability_flag_tab.delete;

             SELECT   forecast_item_id, forecast_item_type,
                      project_org_id , expenditure_org_id,
                      project_organization_id, expenditure_organization_id ,
                      project_id, project_type_class, person_id ,
                      resource_id, borrowed_flag, assignment_id,
                      item_date, item_uom, item_quantity,
                      pvdr_period_set_name, pvdr_pa_period_name,
                      pvdr_gl_period_name, rcvr_period_set_name,
                      rcvr_pa_period_name, rcvr_gl_period_name,
                      global_exp_period_end_date, expenditure_type,
                      expenditure_type_class, cost_rejection_code,
                      rev_rejection_code, tp_rejection_code,
                      burden_rejection_code, other_rejection_code,
                      delete_flag, error_flag, provisional_flag,
                      JOB_ID,
                      TP_AMOUNT_TYPE,
                      OVERPROVISIONAL_QTY,
                      OVER_PROV_CONF_QTY,
                      CONFIRMED_QTY,
                      PROVISIONAL_QTY,
                      asgmt_sys_status_code, capacity_quantity,
                      overcommitment_quantity, availability_quantity,
                      overcommitment_flag, availability_flag
             BULK COLLECT INTO forecast_item_id_tab, forecast_item_type_tab,
                      project_org_id_tab, expenditure_org_id_tab,
                      project_organization_id_tab, expenditure_orgn_id_tab,
                      project_id_tab, project_type_class_tab, person_id_tab,
                      resource_id_tab, borrowed_flag_tab, assignment_id_tab,
                      item_date_tab, item_uom_tab, item_quantity_tab,
                      pvdr_period_set_name_tab, pvdr_pa_period_name_tab,
                      pvdr_gl_period_name_tab, rcvr_period_set_name_tab,
                      rcvr_pa_period_name_tab, rcvr_gl_period_name_tab,
                      global_exp_period_end_date_tab, expenditure_type_tab,
                      expenditure_type_class_tab, cost_rejection_code_tab,
                      rev_rejection_code_tab, tp_rejection_code_tab,
                      burden_rejection_code_tab, other_rejection_code_tab,
                      delete_flag_tab, error_flag_tab, provisional_flag_tab,
                      JOB_ID_tab,
                      TP_AMOUNT_TYPE_tab,
                      OVERPROVISIONAL_QTY_tab,
                      OVER_PROV_CONF_QTY_tab,
                      CONFIRMED_QTY_tab,
                      PROVISIONAL_QTY_tab,
                      asgmt_sys_status_code_tab, capacity_quantity_tab,
                      overcommitment_quantity_tab, availability_quantity_tab,
                      overcommitment_flag_tab, availability_flag_tab
             FROM   pa_forecast_items
             WHERE  assignment_id = p_AsgnDtlRec.assignment_id
             AND    delete_flag   = 'N'
             AND    error_flag    = 'Y'
             /*  Modified for bug 3998166
	     AND    trunc(item_date) BETWEEN trunc(p_start_date) AND
                                             trunc(p_end_date)        */
             AND    item_date BETWEEN trunc(p_start_date) AND
                                      (trunc(p_end_date)+ 0.99999)
             order by item_date, forecast_item_id ;


             IF forecast_item_id_tab.COUNT = 0 THEN

                 Print_message ( 'Leaving FI_Error_Process');
                 x_return_status := lv_return_status;

                RETURN;

             END IF;

             -- Move to one table FROM multiple tables

             FOR j IN forecast_item_id_tab.FIRST..forecast_item_id_tab.LAST LOOP


                 TmpErrHdrTab(j).forecast_item_id := forecast_item_id_tab(j);
                 TmpErrHdrTab(j).forecast_item_type :=
                                         forecast_item_type_tab(j);
                 TmpErrHdrTab(j).project_org_id  := project_org_id_tab(j);
                 TmpErrHdrTab(j).expenditure_org_id :=
                                         expenditure_org_id_tab(j);
                 TmpErrHdrTab(j).project_organization_id :=
                                          project_organization_id_tab(j);
                 TmpErrHdrTab(j).expenditure_organization_id  :=
                                          expenditure_orgn_id_tab(j);
                 TmpErrHdrTab(j).project_id := project_id_tab(j);
                 TmpErrHdrTab(j).project_type_class :=
                                          project_type_class_tab(j);
                 TmpErrHdrTab(j).person_id  := person_id_tab(j);
                 TmpErrHdrTab(j).resource_id := resource_id_tab(j);
                 TmpErrHdrTab(j).borrowed_flag := borrowed_flag_tab(j);
                 TmpErrHdrTab(j).assignment_id := assignment_id_tab(j);
                 TmpErrHdrTab(j).item_date := item_date_tab(j);
                 TmpErrHdrTab(j).item_uom := item_uom_tab(j);
                 TmpErrHdrTab(j).item_quantity := item_quantity_tab(j);
                 TmpErrHdrTab(j).pvdr_period_set_name :=
                                          pvdr_period_set_name_tab(j);
                 TmpErrHdrTab(j).pvdr_pa_period_name :=
                                          pvdr_pa_period_name_tab(j);
                 TmpErrHdrTab(j).pvdr_gl_period_name :=
                                          pvdr_gl_period_name_tab(j);
                 TmpErrHdrTab(j).rcvr_period_set_name :=
                                          rcvr_period_set_name_tab(j);
                 TmpErrHdrTab(j).rcvr_pa_period_name :=
                                          rcvr_pa_period_name_tab(j);
                 TmpErrHdrTab(j).rcvr_gl_period_name :=
                                          rcvr_gl_period_name_tab(j);
                 TmpErrHdrTab(j).global_exp_period_end_date :=
                                          global_exp_period_end_date_tab(j);
                 TmpErrHdrTab(j).expenditure_type := expenditure_type_tab(j);
                 TmpErrHdrTab(j).expenditure_type_class :=
                                          expenditure_type_class_tab(j);
                 TmpErrHdrTab(j).cost_rejection_code :=
                                          cost_rejection_code_tab(j);
                 TmpErrHdrTab(j).rev_rejection_code :=
                                          rev_rejection_code_tab(j);
                 TmpErrHdrTab(j).tp_rejection_code := tp_rejection_code_tab(j);
                 TmpErrHdrTab(j).burden_rejection_code :=
                                          burden_rejection_code_tab(j);
                 TmpErrHdrTab(j).other_rejection_code :=
                                          other_rejection_code_tab(j);
                 TmpErrHdrTab(j).delete_flag := delete_flag_tab(j);
                 TmpErrHdrTab(j).error_flag := error_flag_tab(j);
                 TmpErrHdrTab(j).provisional_flag := provisional_flag_tab(j);
                 TmpErrHdrTab(j).JOB_ID := JOB_ID_tab(j);
                 TmpErrHdrTab(j).TP_AMOUNT_TYPE := TP_AMOUNT_TYPE_tab(j);
                 TmpErrHdrTab(j).OVERPROVISIONAL_QTY := OVERPROVISIONAL_QTY_tab(j);
                 TmpErrHdrTab(j).OVER_PROV_CONF_QTY := OVER_PROV_CONF_QTY_tab(j);
                 TmpErrHdrTab(j).CONFIRMED_QTY := CONFIRMED_QTY_tab(j);
                 TmpErrHdrTab(j).PROVISIONAL_QTY := PROVISIONAL_QTY_tab(j);
                 TmpErrHdrTab(j).asgmt_sys_status_code := asgmt_sys_status_code_tab(j);
                 TmpErrHdrTab(j).capacity_quantity := capacity_quantity_tab(j);
                 TmpErrHdrTab(j).overcommitment_quantity :=  overcommitment_quantity_tab(j);
                 TmpErrHdrTab(j).availability_quantity :=  availability_quantity_tab(j);
                 TmpErrHdrTab(j).overcommitment_flag := overcommitment_flag_tab(j);
                 TmpErrHdrTab(j).availability_flag := availability_flag_tab(j);

             END LOOP;

             lv_next_date := TmpErrHdrTab(TmpErrHdrTab.FIRST).item_date ;
             lv_start_date := TmpErrHdrTab(TmpErrHdrTab.FIRST).item_date ;
             lv_ind := 1;

             if (TmpErrHdrTab.count <> 0) then
             FOR i IN TmpErrHdrTab.FIRST..TmpErrHdrTab.LAST LOOP
                 if TmpErrHdrTab.exists(i) then

                 IF ( trunc(TmpErrHdrTab(i).item_date) <>
                            trunc(lv_next_date) ) THEN

                    lv_end_date := lv_next_date - 1;

                    IF p_AsgnDtlRec.assignment_type = 'OPEN_ASGMT' THEN


                       IF lv_return_status = FND_API.G_RET_STS_SUCCESS THEN

                          Print_message ( 'Calling Generate_Requirement_FI ');

                          Generate_Requirement_FI(
                                    p_AsgnDtlRec    => p_AsgnDtlRec,
                                    p_start_date    => lv_start_date,
                                    p_end_date      => lv_end_date,
                                    p_process_mode  => p_process_mode,
                                    p_ErrHdrTab     => TmpHdrTab,
                                    x_return_status => lv_return_status,
                                    x_msg_count     => x_msg_count,
                                    x_msg_data      => x_msg_data );
                       END IF;

                    ELSE

                       IF lv_return_status = FND_API.G_RET_STS_SUCCESS THEN

                           Print_message ( 'Calling Generate_Assignment_FI ');

                           Generate_Assignment_FI(
                                    p_AsgnDtlRec     => p_AsgnDtlRec,
                                    p_start_date     => lv_start_date,
                                    p_end_date       => lv_end_date,
                                    p_process_mode   => p_process_mode,
                                    p_ErrHdrTab      => TmpHdrTab,
                                    x_res_start_date => lv_dmy_start_date,
                                    x_res_end_date   => lv_dmy_end_date,
                                    x_return_status  => lv_return_status,
                                    x_msg_count      => x_msg_count,
                                    x_msg_data       => x_msg_data );
                       END IF;

                    END IF;

                    lv_start_date   := TmpErrHdrTab(i).item_date;
                    lv_next_date    := TmpErrHdrTab(i).item_date;
                    TmpHdrTab.delete;
                    lv_ind := 1;

                 END IF;

                 TmpHdrTab(lv_ind) := TmpErrHdrTab(i);
                 lv_ind := lv_ind + 1;
                 lv_next_date    := lv_next_date + 1;
             end if;
             END LOOP;
             end if;

             -- Do FOR.LAST record.LAST set of records
             lv_end_date := TmpErrHdrTab(TmpErrHdrTab.LAST).item_date;

             IF p_AsgnDtlRec.assignment_type = 'OPEN_ASGMT' THEN

                IF lv_return_status = FND_API.G_RET_STS_SUCCESS THEN

                   Print_message ( 'Calling Generate_Requirement_FI ');

                   Generate_Requirement_FI(
                          p_AsgnDtlRec    => p_AsgnDtlRec,
                          p_start_date    => lv_start_date,
                          p_end_date      => lv_end_date,
                          p_process_mode  => p_process_mode,
                          p_ErrHdrTab     => TmpHdrTab,
                          x_return_status => lv_return_status,
                          x_msg_count     => x_msg_count,
                          x_msg_data      => x_msg_data );
                END IF;

             ELSE

                IF lv_return_status = FND_API.G_RET_STS_SUCCESS THEN

                   Print_message ( 'Calling Generate_Assignment_FI ');

                   Generate_Assignment_FI(
                         p_AsgnDtlRec    =>p_AsgnDtlRec,
                         p_start_date    => lv_start_date,
                         p_end_date      => lv_end_date,
                         p_process_mode  => p_process_mode,
                         p_ErrHdrTab     => TmpHdrTab,
                         x_res_start_date => lv_dmy_start_date,
                         x_res_end_date   => lv_dmy_end_date,
                         x_return_status => lv_return_status,
                         x_msg_count     => x_msg_count,
                         x_msg_data      => x_msg_data );
                END IF;

             END IF;


             Print_message (
                     'Leaving FI_Error_Process');

             PA_DEBUG.Reset_Err_Stack;

             x_return_status := lv_return_status;

       EXCEPTION

             WHEN OTHERS THEN
		  print_message('Failed in FI_Error_Process api');
		  print_message('SQLCODE'||sqlcode||sqlerrm);
                  x_msg_count     := 1;
                  x_msg_data      := sqlerrm;
                  x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

                  FND_MSG_PUB.add_exc_msg
                      (p_pkg_name   =>
                              'PA_FORECASTITEM_PVT.FI_Error_Process',
                       p_procedure_name => PA_DEBUG.G_Err_Stack);

		               If x_msg_count = 1 THEN
				              pa_interface_utils_pub.get_messages
				                (p_encoded        => FND_API.G_TRUE,
					               p_msg_index      => 1,
					               p_msg_count      => x_msg_count,
					               p_msg_data       => x_msg_data,
					               p_data           => l_data,  -- 4537865
					               p_msg_index_out  => l_msg_index_out );
							x_msg_data := l_data ;
		               End If;
                  Print_message(x_msg_data);

                  RAISE;


       END FI_Error_Process;


/* ---------------------------------------------------------------------
|   Procedure  :   Regenrate_Asgn_Req
|   Purpose    :   It will generate the forecast item for those records
|                  which has got error out in the first generation and
|                  will generate for those items also which has process
|                  mode as 'ERROR'
|   Parameters                   Type           Required  Description
|   p_orgz_id                    NUMBER         YES       Orgn id
|   p_start_date                 DATE           YES       Start date
|   p_end_date                   DATE           YES       End date
|   p_process_mode               VARCHAR2       YES       Process mode i.e.
|                                                         'ERROR'
+----------------------------------------------------------------------*/
       PROCEDURE Regenrate_Asgn_Req(
                 p_orgz_id            IN      NUMBER,
                 p_start_date        IN      DATE,
                 p_end_date          IN      DATE,
                 p_process_mode      IN      VARCHAR2,
                 x_return_status     OUT  NOCOPY   VARCHAR2,  -- 4537865
                 x_msg_count         OUT  NOCOPY   NUMBER,  -- 4537865
                 x_msg_data          OUT  NOCOPY   VARCHAR2) IS  -- 4537865

             -- This cursor will store all the record according to
             -- the process mode i.e. ERROR or RECALCULATE

             /* Bug 4918687 SQL ID 14905697 CURSOR asgmt_dtls IS
                 SELECT proj_asgn.assignment_id,'ERROR'l_process_mode,
                        proj_asgn.start_date,proj_asgn.end_date
                 FROM   pa_project_assignments proj_asgn
                 WHERE  proj_asgn.expenditure_organization_id = p_orgz_id
                 AND    proj_asgn.template_flag = 'N'
                 AND    p_start_date IS NOT NULL
                 AND    p_end_date   IS NOT NULL
                 AND    EXISTS ( SELECT null
                                FROM pa_forecast_items frcst_itms
                                WHERE proj_asgn.assignment_id =
                                          frcst_itms.assignment_id
                                AND   frcst_itms.delete_flag  = 'N'
                                AND   frcst_itms.error_flag =
                                      DECODE(p_process_mode,'ERROR','Y',
                                              frcst_itms.error_flag)
                                AND   trunc(frcst_itms.item_date) BETWEEN
                                      trunc(p_start_date)  AND
                                      trunc(p_end_date))

                 UNION
                 SELECT proj_asgn.assignment_id,'ERROR'l_process_mode,
                        proj_asgn.start_date,proj_asgn.end_date
                 FROM   pa_project_assignments proj_asgn
                 WHERE  proj_asgn.expenditure_organization_id = p_orgz_id
                 AND    proj_asgn.template_flag = 'N'
                 AND    p_start_date IS NOT NULL
                 AND    p_end_date IS NULL
                 AND    EXISTS ( SELECT null
                                 FROM   pa_forecast_items frcst_itms
                                 WHERE  proj_asgn.assignment_id =
                                               frcst_itms.assignment_id
                                 AND    frcst_itms.delete_flag  = 'N'
                                 AND    frcst_itms.error_flag =
                                 DECODE (p_process_mode,'ERROR','Y',
                                                 frcst_itms.error_flag)
                                 AND   trunc(frcst_itms.item_date) >=
                                         trunc(p_start_date)  )
                 UNION
                 SELECT proj_asgn.assignment_id,'ERROR'l_process_mode,
                        proj_asgn.start_date,proj_asgn.end_date
                 FROM   pa_project_assignments proj_asgn
                 WHERE  proj_asgn.expenditure_organization_id = p_orgz_id
                 AND    proj_asgn.template_flag = 'N'
                 AND    p_start_date IS  NULL
                 AND    p_end_date   IS NOT NULL
                 AND    EXISTS ( SELECT null
                                 FROM   pa_forecast_items frcst_itms
                                 WHERE  proj_asgn.assignment_id =
                                        frcst_itms.assignment_id
                                 AND    frcst_itms.delete_flag  = 'N'
                                 AND    frcst_itms.error_flag =
                                 DECODE (p_process_mode,'ERROR','Y',
                                          frcst_itms.error_flag)
                                 AND   trunc(frcst_itms.item_date) <=
                                         trunc(p_end_date))
                 UNION
                 SELECT proj_asgn.assignment_id,'ERROR'l_process_mode,
                        proj_asgn.start_date,proj_asgn.end_date
                 FROM   pa_project_assignments proj_asgn
                 WHERE  proj_asgn.expenditure_organization_id = p_orgz_id
                 AND    proj_asgn.template_flag = 'N'
                 AND    p_start_date IS NULL
                 AND    p_end_date   IS NULL
                 AND    EXISTS ( SELECT null
                                   FROM pa_forecast_items frcst_itms
                                   WHERE proj_asgn.assignment_id =
                                             frcst_itms.assignment_id
                                   AND   frcst_itms.delete_flag  = 'N'
                                   AND   frcst_itms.error_flag =
                                   DECODE(p_process_mode,'ERROR','Y',
                                           frcst_itms.error_flag))
                 UNION
                 SELECT proj_asgn.assignment_id,'GENERATE'l_process_mode,
                        proj_asgn.start_date,proj_asgn.end_date
                 FROM   pa_project_assignments proj_asgn
                 WHERE  proj_asgn.expenditure_organization_id = p_orgz_id
                 AND    proj_asgn.template_flag = 'N'
                 AND  EXISTS (  SELECT NULL
                                FROM pa_schedules psch
                                WHERE proj_asgn.assignment_id  =
                                             psch.assignment_id
                                AND  psch.forecast_txn_generated_flag = 'N');
		 */

	     CURSOR asgmt_dtls IS
	     SELECT proj_asgn.assignment_id,'ERROR'l_process_mode,
		    proj_asgn.start_date,proj_asgn.end_date
	     FROM   pa_project_assignments proj_asgn
   	     WHERE  proj_asgn.expenditure_organization_id = p_orgz_id
	       AND  proj_asgn.template_flag = 'N'
	       AND  ( EXISTS ( SELECT null
				FROM pa_forecast_items frcst_itms
				WHERE proj_asgn.assignment_id = frcst_itms.assignment_id
				  AND frcst_itms.delete_flag  = 'N'
				  AND frcst_itms.error_flag = DECODE(p_process_mode,'ERROR','Y',frcst_itms.error_flag)
				  AND (  (p_start_date IS NOT NULL AND p_end_date IS NOT NULL AND trunc(frcst_itms.item_date) BETWEEN
				      trunc(p_start_date)  AND trunc(p_end_date))
				   OR ( p_start_date IS NOT NULL AND p_end_date IS NULL AND trunc(frcst_itms.item_date) >= trunc(p_start_date))
				   OR ( p_start_date IS NULL AND p_end_date IS NOT NULL AND trunc(frcst_itms.item_date) <= trunc(p_end_date))
				   OR ( p_start_date IS NULL AND p_end_date IS NULL )  )
		    )
	       OR   EXISTS ( SELECT NULL
			       FROM pa_schedules psch
			     WHERE  proj_asgn.assignment_id  = psch.assignment_id
				AND psch.forecast_txn_generated_flag = 'N')
                    );

             l_StartDateTab          PA_FORECAST_GLOB.DateTabTyp;
             l_EndDateTab            PA_FORECAST_GLOB.DateTabTyp;
             l_AssignmentIdTab       PA_FORECAST_GLOB.NumberTabTyp;
             l_processModeTab        PA_FORECAST_GLOB.VCTabTyp;
             l_x_return_status       VARCHAR2(50);
             l_x_msg_count           NUMBER;
             l_x_msg_data            VARCHAR2(50);
             l_cannot_acquire_lock   EXCEPTION;
             lv_lock_type            VARCHAR2(5);

             lv_return_status  VARCHAR2(30);
	           l_msg_index_out	            NUMBER;
             l_lock_status NUMBER;
		l_data varchar2(2000);  -- 4537865
       BEGIN
             -- l_process_mode     := p_process_mode;

             lv_return_status := FND_API.G_RET_STS_SUCCESS;

             Print_message('Entering Regenrate_Asgn_Req');

             PA_DEBUG.Init_err_stack(
                       'PA_FORECASTITEM_PVT.Regenrate_Asgn_Req');

             OPEN asgmt_dtls;

             LOOP

                -- fetching the all the records and storing them
                -- corresponding to their tab type

                FETCH asgmt_dtls
                BULK COLLECT INTO l_AssignmentIdTab,
                                  l_processModeTab,
                                  l_StartDateTab,
                                  l_EndDateTab LIMIT 200;

                IF l_AssignmentIdTab.COUNT =0 THEN

                   EXIT;

                END IF;

                FOR i IN l_AssignmentIdTab.FIRST..l_AssignmentIdTab.LAST LOOP

                     IF (p_start_date IS NOT NULL) THEN

                        IF ( l_StartDateTab(i) > p_start_date ) THEN

                           l_StartDateTab(i)  := p_start_date;

                        END IF;

                     END IF;

                     IF (p_end_date IS NOT NULL ) THEN

                        IF ( l_EndDateTab(i) > p_end_date ) THEN

                           l_EndDateTab(i)  := p_end_date;

                        END IF;

                     END IF;

                     BEGIN

                        -- Locking the processed assignment id so that it
                        -- should be in sink if the same time same assignment id
                        -- is going to be used for processing
                        lv_lock_type := 'ASGMT';

                        IF (PA_FORECAST_ITEMS_UTILS.Set_User_Lock
                                (l_AssignmentIdTab(i), 'ASG') <> 0) THEN

                           RAISE l_cannot_acquire_lock;

                        END IF;

                        -- Call the Forecast Generation API.

                       Print_message(
                            'Calling forecast item Regenrate_Asgn_Req');

                        PA_FORECASTITEM_PVT.Create_Forecast_Item(
                                     p_assignment_id  => l_AssignmentIdTab(i),
                                     p_start_date     => l_StartDateTab(i)   ,
                                     p_end_date       => l_EndDateTab(i)     ,
                                     p_process_mode   => l_processModeTab(i) ,
                                     x_return_status  => l_x_return_status,
                                     x_msg_count      => l_x_msg_count,
                                     x_msg_data       => l_x_msg_data );

                        l_lock_status := PA_FORECAST_ITEMS_UTILS.Release_User_Lock
                                (l_AssignmentIdTab(i), 'ASG');
                       -- This commit is safe: called from a report.
                        commit;

                     EXCEPTION

                         WHEN l_cannot_acquire_lock THEN

                              Print_message(
                                'Unable to set lock for ' ||
                                     to_char(l_AssignmentIdTab(i)));
                              x_msg_count     := 1;
                              x_msg_data      := 'Assignment ID Lock Failure';
                              x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

                              FND_MSG_PUB.add_exc_msg
                                    (p_pkg_name   =>
                              'PA_FORECASTITEM_PVT.Regenrate_Asgn_Req',
                                     p_procedure_name => PA_DEBUG.G_Err_Stack);

		               If x_msg_count = 1 THEN
				              pa_interface_utils_pub.get_messages
				                (p_encoded        => FND_API.G_TRUE,
					               p_msg_index      => 1,
					               p_msg_count      => x_msg_count,
					               p_msg_data       => x_msg_data,
					               p_data           => l_data,  -- 4537865
					               p_msg_index_out  => l_msg_index_out );
						x_msg_data := l_data ;  -- 4537865
		               End If;
                               Print_message(x_msg_data);

                               RAISE;


                     END;

                END LOOP;

                l_AssignmentIdTab.delete;
                l_StartDateTab.delete;
                l_EndDateTab.delete;

             END LOOP;

             CLOSE asgmt_dtls;

             Print_message('Leaving Regenrate_Asgn_Req');

             PA_DEBUG.Reset_Err_Stack;

       EXCEPTION

           WHEN OTHERS THEN
                  print_message('Failed in Regenrate_Asgn_Req api');
                  print_message('SQLCODE'||sqlcode||sqlerrm);

                x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
                x_msg_count     := 1;
                x_msg_data      := SQLERRM;

                FND_MSG_PUB.add_exc_msg
                   (p_pkg_name   => 'PA_FORECASTITEM_PVT.Regenrate_Asgn_Req',
                    p_procedure_name => PA_DEBUG.G_Err_Stack);

		               If x_msg_count = 1 THEN
				              pa_interface_utils_pub.get_messages
				                (p_encoded        => FND_API.G_TRUE,
					               p_msg_index      => 1,
					               p_msg_count      => x_msg_count,
					               p_msg_data       => x_msg_data,
					               p_data           => l_data,  -- 4537865
					               p_msg_index_out  => l_msg_index_out );
						x_msg_data := l_data ;  -- 4537865
		               End If;
                Print_message(x_msg_data);

                RAISE;

       END Regenrate_Asgn_Req;



/* ---------------------------------------------------------------------
|   Procedure  :   Regenrate_Unassigned
|   Purpose    :   It will calculate the resource unassigned time
|                  for the passed org id and got error out in previous
|                  generation
|   Input parameters
|   Parameters          Type      Required    Description
|   p_orgz_id           NUMBER         YES   Orgn id
|   p_start_date        DATE           YES    Start date
|   p_end_date          DATE           YES    End date
|   p_process_mode      VARCHAR2       YES    Process mode i.e. 'RECALCULATE'
|                                             OR 'ERROR'
| Out parameters
+----------------------------------------------------------------------*/

       PROCEDURE Regenrate_Unassigned(
                 p_orgz_id            IN      NUMBER,
                 p_start_date        IN      DATE,
                 p_end_date          IN      DATE,
                 p_process_mode      IN      VARCHAR2,
                 x_return_status     OUT     NOCOPY VARCHAR2,  -- 4537865
                 x_msg_count         OUT     NOCOPY NUMBER,  -- 4537865
                 x_msg_data          OUT     NOCOPY VARCHAR2) IS  -- 4537865

             -- select all errored out resource record for the input
             -- organization

	           l_msg_index_out	            NUMBER;
		   l_data varchar2(2000);  -- 4537865
             CURSOR unasgn_tim IS
                 SELECT forecast_item_id, forecast_item_type,
                        project_org_id , expenditure_org_id,
                        project_organization_id, expenditure_organization_id ,
                        project_id, project_type_class, person_id ,
                        resource_id, borrowed_flag, assignment_id,
                        item_date, item_uom, item_quantity,
                        pvdr_period_set_name, pvdr_pa_period_name,
                        pvdr_gl_period_name, rcvr_period_set_name,
                        rcvr_pa_period_name, rcvr_gl_period_name,
                        global_exp_period_end_date, expenditure_type,
                        expenditure_type_class, cost_rejection_code,
                        rev_rejection_code, tp_rejection_code,
                        burden_rejection_code, other_rejection_code,
                        delete_flag, error_flag, provisional_flag,
                        JOB_ID,
                        TP_AMOUNT_TYPE,
                        OVERPROVISIONAL_QTY,
                        OVER_PROV_CONF_QTY,
                        CONFIRMED_QTY,
                        PROVISIONAL_QTY,
                        asgmt_sys_status_code, capacity_quantity,
                        overcommitment_quantity, availability_quantity,
                        overcommitment_flag, availability_flag
                 FROM   pa_forecast_items frcst_itms
                 WHERE  frcst_itms.expenditure_organization_id = p_orgz_id
                 AND    frcst_itms.error_flag          = 'Y'
                 AND    frcst_itms.forecast_item_type  = 'U'
                 AND    frcst_itms.delete_flag  = 'N'
                 AND    ( trunc(frcst_itms.item_date) BETWEEN
                            trunc(p_start_date) AND trunc(p_end_date))
                 AND    p_start_date IS NOT NULL
                 AND    p_end_date   IS NOT NULL
                 UNION
                 SELECT forecast_item_id, forecast_item_type,
                        project_org_id , expenditure_org_id,
                        project_organization_id, expenditure_organization_id ,
                        project_id, project_type_class, person_id ,
                        resource_id, borrowed_flag, assignment_id,
                        item_date, item_uom, item_quantity,
                        pvdr_period_set_name, pvdr_pa_period_name,
                        pvdr_gl_period_name, rcvr_period_set_name,
                        rcvr_pa_period_name, rcvr_gl_period_name,
                        global_exp_period_end_date, expenditure_type,
                        expenditure_type_class, cost_rejection_code,
                        rev_rejection_code, tp_rejection_code,
                        burden_rejection_code, other_rejection_code,
                        delete_flag, error_flag, provisional_flag,
                        JOB_ID,
                        TP_AMOUNT_TYPE,
                        OVERPROVISIONAL_QTY,
                        OVER_PROV_CONF_QTY,
                        CONFIRMED_QTY,
                        PROVISIONAL_QTY,
                        asgmt_sys_status_code, capacity_quantity,
                        overcommitment_quantity, availability_quantity,
                        overcommitment_flag, availability_flag
                 FROM   pa_forecast_items frcst_itms
                 WHERE  frcst_itms.expenditure_organization_id = p_orgz_id
                 AND    frcst_itms.error_flag          = 'Y'
                 AND    frcst_itms.forecast_item_type  = 'U'
                 AND    frcst_itms.delete_flag  = 'N'
                 AND    p_start_date IS NOT NULL
                 AND    p_end_date IS NULL
                 AND    trunc(frcst_itms.item_date) >= trunc(p_start_date)
                 UNION
                 SELECT forecast_item_id, forecast_item_type,
                        project_org_id , expenditure_org_id,
                        project_organization_id, expenditure_organization_id ,
                        project_id, project_type_class, person_id ,
                        resource_id, borrowed_flag, assignment_id,
                        item_date, item_uom, item_quantity,
                        pvdr_period_set_name, pvdr_pa_period_name,
                        pvdr_gl_period_name, rcvr_period_set_name,
                        rcvr_pa_period_name, rcvr_gl_period_name,
                        global_exp_period_end_date, expenditure_type,
                        expenditure_type_class, cost_rejection_code,
                        rev_rejection_code, tp_rejection_code,
                        burden_rejection_code, other_rejection_code,
                        delete_flag, error_flag, provisional_flag,
                        JOB_ID,
                        TP_AMOUNT_TYPE,
                        OVERPROVISIONAL_QTY,
                        OVER_PROV_CONF_QTY,
                        CONFIRMED_QTY,
                        PROVISIONAL_QTY,
                        asgmt_sys_status_code, capacity_quantity,
                        overcommitment_quantity, availability_quantity,
                        overcommitment_flag, availability_flag
                 FROM   pa_forecast_items frcst_itms
                 WHERE  frcst_itms.expenditure_organization_id = p_orgz_id
                 AND    frcst_itms.error_flag          = 'Y'
                 AND    frcst_itms.forecast_item_type  = 'U'
                 AND    frcst_itms.delete_flag  = 'N'
                 AND    p_start_date IS NULL
                 AND    p_end_date IS NOT NULL
                 AND    trunc(frcst_itms.item_date) <= trunc(p_end_date)
                 UNION
                 SELECT forecast_item_id, forecast_item_type,
                        project_org_id , expenditure_org_id,
                        project_organization_id, expenditure_organization_id ,
                        project_id, project_type_class, person_id ,
                        resource_id, borrowed_flag, assignment_id,
                        item_date, item_uom, item_quantity,
                        pvdr_period_set_name, pvdr_pa_period_name,
                        pvdr_gl_period_name, rcvr_period_set_name,
                        rcvr_pa_period_name, rcvr_gl_period_name,
                        global_exp_period_end_date, expenditure_type,
                        expenditure_type_class, cost_rejection_code,
                        rev_rejection_code, tp_rejection_code,
                        burden_rejection_code, other_rejection_code,
                        delete_flag, error_flag, provisional_flag,
                        JOB_ID,
                        TP_AMOUNT_TYPE,
                        OVERPROVISIONAL_QTY,
                        OVER_PROV_CONF_QTY,
                        CONFIRMED_QTY,
                        PROVISIONAL_QTY,
                        asgmt_sys_status_code, capacity_quantity,
                        overcommitment_quantity, availability_quantity,
                        overcommitment_flag, availability_flag
                 FROM   pa_forecast_items frcst_itms
                 WHERE  frcst_itms.expenditure_organization_id = p_orgz_id
                 AND    frcst_itms.error_flag          = 'Y'
                 AND    frcst_itms.forecast_item_type  = 'U'
                 AND    frcst_itms.delete_flag  = 'N'
                 AND    p_start_date IS  NULL
                 AND    p_end_date   IS  NULL
                 order by resource_id, item_date, forecast_item_id ;


             forecast_item_id_tab                PA_FORECAST_GLOB.NumberTabTyp;
             forecast_item_type_tab              PA_FORECAST_GLOB.VCTabTyp;
             project_org_id_tab                  PA_FORECAST_GLOB.NumberTabTyp;
             expenditure_org_id_tab              PA_FORECAST_GLOB.NumberTabTyp;
             expenditure_orgn_id_tab             PA_FORECAST_GLOB.NumberTabTyp;
             project_organization_id_tab         PA_FORECAST_GLOB.NumberTabTyp;
             project_id_tab                      PA_FORECAST_GLOB.NumberTabTyp;
             project_type_class_tab              PA_FORECAST_GLOB.VCTabTyp;
             person_id_tab                       PA_FORECAST_GLOB.NumberTabTyp;
             resource_id_tab                     PA_FORECAST_GLOB.NumberTabTyp;
             borrowed_flag_tab                   PA_FORECAST_GLOB.VC1TabTyp;
             assignment_id_tab                   PA_FORECAST_GLOB.NumberTabTyp;
             item_date_tab                       PA_FORECAST_GLOB.DateTabTyp;
             item_uom_tab                        PA_FORECAST_GLOB.VCTabTyp;
             item_quantity_tab                   PA_FORECAST_GLOB.NumberTabTyp;
             pvdr_period_set_name_tab            PA_FORECAST_GLOB.VCTabTyp;
             pvdr_pa_period_name_tab             PA_FORECAST_GLOB.VCTabTyp;
             pvdr_gl_period_name_tab             PA_FORECAST_GLOB.VCTabTyp;
             rcvr_period_set_name_tab            PA_FORECAST_GLOB.VCTabTyp;
             rcvr_pa_period_name_tab             PA_FORECAST_GLOB.VCTabTyp;
             rcvr_gl_period_name_tab             PA_FORECAST_GLOB.VCTabTyp;
             global_exp_period_end_date_tab      PA_FORECAST_GLOB.DateTabTyp;
             expenditure_type_tab                PA_FORECAST_GLOB.VCTabTyp;
             expenditure_type_class_tab          PA_FORECAST_GLOB.VCTabTyp;
             cost_rejection_code_tab             PA_FORECAST_GLOB.VCTabTyp;
             rev_rejection_code_tab              PA_FORECAST_GLOB.VCTabTyp;
             tp_rejection_code_tab               PA_FORECAST_GLOB.VCTabTyp;
             burden_rejection_code_tab           PA_FORECAST_GLOB.VCTabTyp;
             other_rejection_code_tab            PA_FORECAST_GLOB.VCTabTyp;
             delete_flag_tab                     PA_FORECAST_GLOB.VC1TabTyp;
             error_flag_tab                      PA_FORECAST_GLOB.VC1TabTyp;
             provisional_flag_tab                PA_FORECAST_GLOB.VC1TabTyp;
             JOB_ID_tab           PA_FORECAST_GLOB.NumberTabTyp;
             TP_AMOUNT_TYPE_tab           PA_FORECAST_GLOB.VCTabTyp;
             OVERPROVISIONAL_QTY_tab           PA_FORECAST_GLOB.NumberTabTyp;
             OVER_PROV_CONF_QTY_tab           PA_FORECAST_GLOB.NumberTabTyp;
             CONFIRMED_QTY_tab           PA_FORECAST_GLOB.NumberTabTyp;
             PROVISIONAL_QTY_tab           PA_FORECAST_GLOB.NumberTabTyp;
             asgmt_sys_status_code_tab           PA_FORECAST_GLOB.VCTabTyp;
             capacity_quantity_tab               PA_FORECAST_GLOB.NumberTabTyp;
             overcommitment_quantity_tab         PA_FORECAST_GLOB.NumberTabTyp;
             availability_quantity_tab           PA_FORECAST_GLOB.NumberTabTyp;
             overcommitment_flag_tab             PA_FORECAST_GLOB.VC1TabTyp;
             availability_flag_tab               PA_FORECAST_GLOB.VC1TabTyp;

             l_forecast_item_hdr_tab             PA_FORECAST_GLOB.FIHdrTabTyp;
             l_x_return_status                   VARCHAR2(50);
             l_x_msg_count                       NUMBER;
             l_x_msg_data                        VARCHAR2(50);
             l_process_mode                      VARCHAR2(50);

             lv_return_status  VARCHAR2(30);

       BEGIN

             lv_return_status := FND_API.G_RET_STS_SUCCESS;

             --     l_process_mode     := p_process_mode;

             PA_DEBUG.Init_err_stack( 'PA_FORECASTITEM_PVT.Regenrate_Unassigned');

             l_process_mode     := 'ERROR';

             Print_message( 'Entering Regenrate_Unassigned');

             OPEN unasgn_tim;

             LOOP

                Print_message( 'in loop Regenrate_Unassigned');

                FETCH unasgn_tim
                BULK COLLECT INTO
                      forecast_item_id_tab, forecast_item_type_tab,
                      project_org_id_tab, expenditure_org_id_tab,
                      project_organization_id_tab, expenditure_orgn_id_tab,
                      project_id_tab, project_type_class_tab, person_id_tab,
                      resource_id_tab, borrowed_flag_tab, assignment_id_tab,
                      item_date_tab, item_uom_tab, item_quantity_tab,
                      pvdr_period_set_name_tab, pvdr_pa_period_name_tab,
                      pvdr_gl_period_name_tab, rcvr_period_set_name_tab,
                      rcvr_pa_period_name_tab, rcvr_gl_period_name_tab,
                      global_exp_period_end_date_tab, expenditure_type_tab,
                      expenditure_type_class_tab, cost_rejection_code_tab,
                      rev_rejection_code_tab, tp_rejection_code_tab,
                      burden_rejection_code_tab, other_rejection_code_tab,
                      delete_flag_tab, error_flag_tab, provisional_flag_tab,
                      JOB_ID_tab,
                      TP_AMOUNT_TYPE_tab,
                      OVERPROVISIONAL_QTY_tab,
                      OVER_PROV_CONF_QTY_tab,
                      CONFIRMED_QTY_tab,
                      PROVISIONAL_QTY_tab,
                      asgmt_sys_status_code_tab, capacity_quantity_tab,
                      overcommitment_quantity_tab, availability_quantity_tab,
                      overcommitment_flag_tab, availability_flag_tab
                      LIMIT 200;

                IF forecast_item_id_tab.COUNT =0 THEN

                   EXIT;

                END IF;

                FOR j IN forecast_item_id_tab.FIRST..forecast_item_id_tab.LAST
                LOOP

                    l_forecast_item_hdr_tab(j).forecast_item_id            :=
                                              forecast_item_id_tab(j);
                    l_forecast_item_hdr_tab(j).forecast_item_type          :=
                                              forecast_item_type_tab(j);
                    l_forecast_item_hdr_tab(j).project_org_id              :=
                                              project_org_id_tab(j);
                    l_forecast_item_hdr_tab(j).expenditure_org_id          :=
                                              expenditure_org_id_tab(j);
                    l_forecast_item_hdr_tab(j).project_organization_id     :=
                                              project_organization_id_tab(j);
                    l_forecast_item_hdr_tab(j).expenditure_organization_id :=
                                              expenditure_orgn_id_tab(j);
                    l_forecast_item_hdr_tab(j).project_id                  :=
                                              project_id_tab(j);
                    l_forecast_item_hdr_tab(j).project_type_class          :=
                                              project_type_class_tab(j);
                    l_forecast_item_hdr_tab(j).person_id                   :=
                                              person_id_tab(j);
                    l_forecast_item_hdr_tab(j).resource_id                 :=
                                              resource_id_tab(j);
                    l_forecast_item_hdr_tab(j).borrowed_flag               :=
                                              borrowed_flag_tab(j);
                    l_forecast_item_hdr_tab(j).assignment_id               :=
                                              assignment_id_tab(j);
                    l_forecast_item_hdr_tab(j).item_date                   :=
                                              item_date_tab(j);
                    l_forecast_item_hdr_tab(j).item_uom                    :=
                                              item_uom_tab(j);
                    l_forecast_item_hdr_tab(j).item_quantity               :=
                                              item_quantity_tab(j);
                    l_forecast_item_hdr_tab(j).pvdr_period_set_name        :=
                                              pvdr_period_set_name_tab(j);
                    l_forecast_item_hdr_tab(j).pvdr_pa_period_name         :=
                                              pvdr_pa_period_name_tab(j);
                    l_forecast_item_hdr_tab(j).pvdr_gl_period_name         :=
                                              pvdr_gl_period_name_tab(j);
                    l_forecast_item_hdr_tab(j).rcvr_period_set_name        :=
                                              rcvr_period_set_name_tab(j);
                    l_forecast_item_hdr_tab(j).rcvr_pa_period_name         :=
                                              rcvr_pa_period_name_tab(j);
                    l_forecast_item_hdr_tab(j).rcvr_gl_period_name         :=
                                              rcvr_gl_period_name_tab(j);
                    l_forecast_item_hdr_tab(j).global_exp_period_end_date  :=
                                              global_exp_period_end_date_tab(j);
                    l_forecast_item_hdr_tab(j).expenditure_type            :=
                                              expenditure_type_tab(j);
                    l_forecast_item_hdr_tab(j).expenditure_type_class      :=
                                              expenditure_type_class_tab(j);
                    l_forecast_item_hdr_tab(j).cost_rejection_code         :=
                                              cost_rejection_code_tab(j);
                    l_forecast_item_hdr_tab(j).rev_rejection_code          :=
                                              rev_rejection_code_tab(j);
                    l_forecast_item_hdr_tab(j).burden_rejection_code       :=
                                              burden_rejection_code_tab(j);
                    l_forecast_item_hdr_tab(j).tp_rejection_code           :=
                                              tp_rejection_code_tab(j);
                    l_forecast_item_hdr_tab(j).other_rejection_code        :=
                                              other_rejection_code_tab(j);
                    l_forecast_item_hdr_tab(j).delete_flag                 :=
                                              delete_flag_tab(j);
                    l_forecast_item_hdr_tab(j).error_flag                  :=
                                              error_flag_tab(j);
                    l_forecast_item_hdr_tab(j).provisional_flag            :=
                                              provisional_flag_tab(j);
                    l_forecast_item_hdr_tab(j).JOB_ID := JOB_ID_tab(j);
                    l_forecast_item_hdr_tab(j).TP_AMOUNT_TYPE := TP_AMOUNT_TYPE_tab(j);
                    l_forecast_item_hdr_tab(j).OVERPROVISIONAL_QTY := OVERPROVISIONAL_QTY_tab(j);
                    l_forecast_item_hdr_tab(j).OVER_PROV_CONF_QTY := OVER_PROV_CONF_QTY_tab(j);
                    l_forecast_item_hdr_tab(j).CONFIRMED_QTY := CONFIRMED_QTY_tab(j);
                    l_forecast_item_hdr_tab(j).PROVISIONAL_QTY := PROVISIONAL_QTY_tab(j);
                    l_forecast_item_hdr_tab(j).asgmt_sys_status_code := asgmt_sys_status_code_tab(j);
                    l_forecast_item_hdr_tab(j).capacity_quantity := capacity_quantity_tab(j);
                    l_forecast_item_hdr_tab(j).overcommitment_quantity :=  overcommitment_quantity_tab(j);
                    l_forecast_item_hdr_tab(j).availability_quantity :=  availability_quantity_tab(j);
                    l_forecast_item_hdr_tab(j).overcommitment_flag := overcommitment_flag_tab(j);
                    l_forecast_item_hdr_tab(j).availability_flag := availability_flag_tab(j);

                END LOOP;

                BEGIN
                      -- Call the Forecast Generation API.
                      Print_message(
                           'calling create forecast_item from unasg');

                      PA_FORECASTITEM_PVT.create_forecast_item(
                             p_ErrHdrTab           => l_forecast_item_hdr_tab,
                             p_process_mode        => l_process_mode,
                             x_return_status       => l_x_return_status,
                             x_msg_count           => l_x_msg_count,
                             x_msg_data            => l_x_msg_data );


                END;

                l_forecast_item_hdr_tab.delete;
                forecast_item_id_tab.delete;
                forecast_item_type_tab.delete;
                project_org_id_tab.delete;
                expenditure_org_id_tab.delete;
                project_organization_id_tab.delete;
                expenditure_orgn_id_tab.delete;
                project_id_tab.delete;
                project_type_class_tab.delete;
                person_id_tab.delete;
                resource_id_tab.delete;
                borrowed_flag_tab.delete;
                assignment_id_tab.delete;
                item_date_tab.delete;
                item_uom_tab.delete;
                item_quantity_tab.delete;
                pvdr_period_set_name_tab.delete;
                pvdr_pa_period_name_tab.delete;
                pvdr_gl_period_name_tab.delete;
                rcvr_period_set_name_tab.delete;
                rcvr_pa_period_name_tab.delete;
                rcvr_gl_period_name_tab.delete;
                global_exp_period_end_date_tab.delete;
                expenditure_type_tab.delete;
                expenditure_type_class_tab.delete;
                cost_rejection_code_tab.delete;
                rev_rejection_code_tab.delete;
                tp_rejection_code_tab.delete;
                burden_rejection_code_tab.delete;
                other_rejection_code_tab.delete;
                delete_flag_tab.delete;
                error_flag_tab.delete;
                provisional_flag_tab.delete;
                JOB_ID_tab.delete;
                TP_AMOUNT_TYPE_tab.delete;
                OVERPROVISIONAL_QTY_tab.delete;
                OVER_PROV_CONF_QTY_tab.delete;
                CONFIRMED_QTY_tab.delete;
                PROVISIONAL_QTY_tab.delete;
                asgmt_sys_status_code_tab.delete;
                capacity_quantity_tab.delete;
                overcommitment_quantity_tab.delete;
                availability_quantity_tab.delete;
                overcommitment_flag_tab.delete;
                availability_flag_tab.delete;

             END LOOP;

             Print_message(
                           'Leaving Regenrate_Unassigned');

             CLOSE unasgn_tim;

             PA_DEBUG.Reset_Err_Stack;

             x_return_status := lv_return_status;

       EXCEPTION

           WHEN OTHERS THEN
                  print_message('Failed in Regenerate_unassigned api');
                  print_message('SQLCODE'||sqlcode||sqlerrm);

                x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
                x_msg_count     := 1;
                x_msg_data      := SQLERRM;

                FND_MSG_PUB.add_exc_msg
                      (p_pkg_name   =>
                              'PA_FORECASTITEM_PVT.Regenrate_Unassigned',
                       p_procedure_name => PA_DEBUG.G_Err_Stack);

		               If x_msg_count = 1 THEN
				              pa_interface_utils_pub.get_messages
				                (p_encoded        => FND_API.G_TRUE,
					               p_msg_index      => 1,
					               p_msg_count      => x_msg_count,
					               p_msg_data       => x_msg_data,
					               p_data           => l_data,  -- 4537865
					               p_msg_index_out  => l_msg_index_out );
						x_msg_data := l_data ; -- 4537865
		               End If;
                Print_message(x_msg_data);

                RAISE;

       END Regenrate_Unassigned;

/***This Api is called from Process forecast exceptions concurrent process
 *  for the given organization , start date and end date it picks up
 *  all the errored forecast records and process
 **/
PROCEDURE regenrate_orgz_forecast(
                 p_orgz_id            IN      NUMBER,
                 p_start_date        IN      DATE,
                 p_end_date          IN      DATE,
                 p_process_mode      IN      VARCHAR2,
                 x_return_status     OUT NOCOPY    VARCHAR2, -- 4537865
                 x_msg_count         OUT NOCOPY    NUMBER, -- 4537865
                 x_msg_data          OUT NOCOPY    VARCHAR2) IS -- 4537865

	           l_msg_index_out	            NUMBER;
		   l_data varchar2(2000); -- 4537865
             l_orgz_id                 NUMBER;
             l_start_date             DATE;
             l_end_date               DATE;
             l_process_mode           VARCHAR2(15);
             l_x_return_status        VARCHAR2(50);
             l_x_msg_count            NUMBER;
             l_x_msg_data             VARCHAR(50);
	     l_debug_mode             VARCHAR2(100);

            g_process_mode          VARCHAR2(30);
       BEGIN

	fnd_profile.get('PA_DEBUG_MODE',l_debug_mode);
        l_debug_mode := NVL(l_debug_mode, 'N');

        PA_DEBUG.SET_PROCESS( x_process        => 'PLSQL'
                      	     ,x_write_file     => 'LOG'
                             ,x_debug_mode     => l_debug_mode
                            );


             l_x_return_status := FND_API.G_RET_STS_SUCCESS;
             l_orgz_id       := p_orgz_id;
             l_start_date   := p_start_date;
             l_end_date     := p_end_date;
             l_process_mode := p_process_mode;

	    /** Added global variable g_process_mode to access it in Fetch_FI_Dtl_Res api **/
	     g_process_mode := p_process_mode;

             Print_message( 'Entering regenrate_orgz_forecast');

             PA_DEBUG.Init_err_stack(
                       'PA_FORECASTITEM_PVT.Regenrate_orgz_forecast');

             Regenrate_Asgn_Req(p_orgz_id         => l_orgz_id,
                                p_start_date     => l_start_date,
                                p_end_date       => l_end_date,
                                p_process_mode   => l_process_mode,
                                x_return_status  => l_x_return_status,
                                x_msg_count      => l_x_msg_count,
                                x_msg_data       => l_x_msg_data) ;

             Print_message( 'calling  Regenrate_Unassigned');

             Regenrate_Unassigned(p_orgz_id         => l_orgz_id,
                                  p_start_date     => l_start_date,
                                  p_end_date       => l_end_date,
                                  p_process_mode   => l_process_mode,
                                  x_return_status  => l_x_return_status,
                                  x_msg_count      => l_x_msg_count,
                                  x_msg_data       => l_x_msg_data) ;

             Print_message( 'Leaving regenrate_orgz_forecast');

	     /** Reset the global param to null **/
		g_process_mode := Null;

             PA_DEBUG.Reset_Err_Stack;

       EXCEPTION

           WHEN OTHERS THEN
		  g_process_mode := null;
                  print_message('Failed in Regenrate_orgz_forecast api');
                  print_message('SQLCODE'||sqlcode||sqlerrm);

                x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
                x_msg_count     := 1;
                x_msg_data      := SQLERRM;

                FND_MSG_PUB.add_exc_msg
                      (p_pkg_name   =>
                              'PA_FORECASTITEM_PVT.regenrate_orgz_forecast',
                       p_procedure_name => PA_DEBUG.G_Err_Stack);

		               If x_msg_count = 1 THEN
				              pa_interface_utils_pub.get_messages
				                (p_encoded        => FND_API.G_TRUE,
					               p_msg_index      => 1,
					               p_msg_count      => x_msg_count,
					               p_msg_data       => x_msg_data,
					               p_data           => l_data, -- 4537865
					               p_msg_index_out  => l_msg_index_out );
						x_msg_data := l_data ; -- 4537865
		               End If;
                Print_message(x_msg_data);

                RAISE;


       END regenrate_orgz_forecast;

/* ---------------------------------------------------------------------
|   Function   :   Is_Include_Forecast
|   Purpose    :   To check IF Project is to be included for forecast item
|                  Summarization
|   Parameters :   p_project_id  - Input Project ID
+----------------------------------------------------------------------*/

       FUNCTION Is_include_Forecast (p_project_status_code   IN  VARCHAR2,
                                     p_action_code           IN  VARCHAR2)
                RETURN VARCHAR2 IS

             lv_include_flag VARCHAR2(1);

       BEGIN
             lv_include_flag := pa_project_utils.check_prj_stus_action_allowed(
                                   p_project_status_code,
                                   p_action_code);

                RETURN (lv_include_flag);

       END Is_Include_Forecast;

/* ---------------------------------------------------------------------
|   Function   :   Get_AmountTypeID
|   Purpose    :   To get amount type id for a given
|   Parameters :   p_project_id  - Input Project ID
+----------------------------------------------------------------------*/

       FUNCTION Get_AmountTypeID
                RETURN NUMBER IS

       BEGIN

                RETURN (41);

       END Get_AmountTypeID;

/* Bug No: 1967832 changed check_person_billable and is_include_utilisation
into procedures. */

/* ---------------------------------------------------------------------
|   Procedure  :	Check_Person_Billable
|   Purpose    :  To check whether a person is billable or not
|   Parameters :  p_person_id  - Input Person ID
|                 p_item_date  - Input item date
|                 x_Start_Date - Output Start Date
|                 x_End_Date   - Output End Date
|                 x_billable_flag - Output of whether the person is billable
|
+----------------------------------------------------------------------*/
    Procedure Check_Person_Billable(p_person_id     IN  NUMBER,
                                    p_item_date     IN  DATE,
                                    x_Start_Date    OUT NOCOPY DATE, -- 4537865
                                    x_End_Date      OUT NOCOPY Date, -- 4537865
                                    x_billable_flag OUT NOCOPY VARCHAR2, -- 4537865
                                    x_return_status OUT NOCOPY VARCHAR2, -- 4537865
                                    x_msg_count     OUT NOCOPY NUMBER, -- 4537865
                                    x_msg_data      OUT NOCOPY VARCHAR2) IS  -- 4537865

     L_MSG_INDEX_OUT NUMBER;
	l_data varchar2(2000);
     l_StartDateTab PA_FORECAST_GLOB.DateTabTyp;
     l_EndDateTab PA_FORECAST_GLOB.DateTabTyp;
     l_BillableFlagTab  PA_FORECAST_GLOB.VC1TabTyp;
     l_found_flag VARCHAR2(1) := 'N';
     l_close_start_date DATE;
     l_close_end_date DATE;

    BEGIN

    -- 2196924: Added logic so it wouldn't raise NO_DATA_FOUND
    -- Changed procedure completely. Please use source area to see old version.
    BEGIN

		SELECT billable_flag,
			rou.resource_effective_start_date,
			NVL(rou.resource_effective_end_date,p_item_date)
		BULK COLLECT INTO
			l_BillableFlagTab,l_StartDateTab,l_EndDateTab
		FROM pa_resources_denorm rou
		WHERE rou.person_id= p_person_id
    ORDER BY rou.resource_effective_start_date;

	  EXCEPTION
	  WHEN NO_DATA_FOUND THEN
      PA_FORECASTITEM_PVT.print_message('NO_DATA_FOUND ok, exception not raised');
    END;

    if (l_StartDateTab.count = 0) then
       x_Start_Date := TO_DATE('01/01/1950','MM/DD/YYYY');
       x_End_Date := TO_DATE('12/31/4000','MM/DD/YYYY');
       x_billable_flag := 'N';
       l_found_flag := 'Y';
    elsif (p_item_date < l_StartDateTab(l_StartDateTab.first)) then
       x_Start_Date := TO_DATE('01/01/1950','MM/DD/YYYY');
       x_End_Date := l_StartDateTab(l_StartDateTab.first)-1;
       x_billable_flag := 'N';
       l_found_flag := 'Y';
    elsif (p_item_date > l_EndDateTab(l_EndDateTab.last)) then
       x_Start_Date := l_EndDateTab(l_EndDateTab.last)+1;
       x_End_Date :=  TO_DATE('12/31/4000','MM/DD/YYYY');
       x_billable_flag := 'N';
       l_found_flag := 'Y';
    else
       <<l_date_loop>>
       for i IN l_StartDateTab.first .. l_StartDateTab.last LOOP
          if (p_item_date >= l_StartDateTab(i) AND
              p_item_date <= l_EndDateTab(i)) THEN
             l_found_flag := 'Y';
             x_Start_Date := l_StartDateTab(i);
             x_End_Date := l_EndDateTab(i);
             x_billable_flag := l_BillableFlagTab(i);
             l_found_flag := 'Y';
             exit l_date_loop;
          end if;

          if (l_EndDateTab(i) < p_item_date) then
             l_close_start_date := l_EndDateTab(i) + 1;
             -- We can rely that there is an i+1 record because
             -- p_item_date must be between the min and max to go into
             -- this loop.
             l_close_end_date := l_StartDateTab(i+1) - 1;
          end if;

       end loop;
    end if;

    if (l_found_flag = 'N') then
       x_Start_Date := l_close_start_date;
       x_End_Date := l_close_end_date;
       x_billable_flag := 'N';
    end if;

    x_return_status :=FND_API.G_RET_STS_SUCCESS;

EXCEPTION

   WHEN OTHERS THEN
      x_msg_count     := 1;
      x_msg_data      := sqlerrm;

	-- 4537865
      x_start_date := NULL ;
      x_End_date := NULL ;
      x_billable_flag := NULL ;

      FND_MSG_PUB.add_exc_msg
      (p_pkg_name   => 'PA_FORECASTITEM_PVT.Check_Person_Billable',
       p_procedure_name => PA_DEBUG.G_Err_Stack);
       x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

		               If x_msg_count = 1 THEN
				              pa_interface_utils_pub.get_messages
				                (p_encoded        => FND_API.G_TRUE,
					               p_msg_index      => 1,
					               p_msg_count      => x_msg_count,
					               p_msg_data       => x_msg_data,
					               p_data           => l_data, -- 4537865
					               p_msg_index_out  => l_msg_index_out );
						x_msg_data :=	l_data ; -- 4537865
		               End If;
       PA_FORECAST_ITEMS_UTILS.log_message(x_msg_data);
       raise;
END Check_Person_Billable;

/* ---------------------------------------------------------------------
|   PROCEDURE  :   Is_Include_Utilisation
|   Purpose    :   To check IF Project/person is to be included for
|                  util item Summarization
|   Parameters :   p_person_id  - Input person ID
|                  p_item_date  - date
|                  x_Start_Date - Output Start Date
|                  x_End_Date   - Output End Date
|                  x_inc_util_flag  - Flag for whether include for util or not
|
+----------------------------------------------------------------------*/

     Procedure Is_Include_Utilisation (p_person_id     IN  NUMBER,
                                       p_item_date     IN  DATE,
                                       x_Start_Date    OUT NOCOPY DATE, -- 4537865
                                       x_End_Date      OUT NOCOPY DATE, -- 4537865
                                       x_inc_util_flag OUT NOCOPY VARCHAR2, -- 4537865
                                       x_return_status OUT NOCOPY VARCHAR2, -- 4537865
                                       x_msg_count     OUT NOCOPY NUMBER, -- 4537865
                                       x_msg_data      OUT NOCOPY VARCHAR2) IS -- 4537865

	l_data varchar2(2000); -- 4537865
      lv_util_flag   VARCHAR2(1);
	    lv_start_date  DATE;
	    lv_end_date    DATE;
	           l_msg_index_out	            NUMBER;

     l_StartDateTab PA_FORECAST_GLOB.DateTabTyp;
     l_EndDateTab PA_FORECAST_GLOB.DateTabTyp;
     l_UtilFlagTab  PA_FORECAST_GLOB.VC1TabTyp;
     l_found_flag VARCHAR2(1) := 'N';
     l_close_start_date DATE;
     l_close_end_date DATE;

     BEGIN
     -- 2196924: Added logic so it wouldn't raise NO_DATA_FOUND
     -- Changed procedure completely. Please use source area to see old version

    BEGIN

		SELECT utilization_flag,
			rou.resource_effective_start_date,
			NVL(rou.resource_effective_end_date,p_item_date)
		BULK COLLECT INTO
			l_UtilFlagTab,l_StartDateTab,l_EndDateTab
		FROM pa_resources_denorm rou
		WHERE rou.person_id= p_person_id
    ORDER BY rou.resource_effective_start_date;

	  EXCEPTION
	  WHEN NO_DATA_FOUND THEN
      PA_FORECASTITEM_PVT.print_message('NO_DATA_FOUND ok, exception not raised');
    END;

    if (l_StartDateTab.count = 0) then
       x_Start_Date := TO_DATE('01/01/1950','MM/DD/YYYY');
       x_End_Date := TO_DATE('12/31/4000','MM/DD/YYYY');
       x_inc_util_flag := 'N';
       l_found_flag := 'Y';
    elsif (p_item_date < l_StartDateTab(l_StartDateTab.first)) then
       x_Start_Date := TO_DATE('01/01/1950','MM/DD/YYYY');
       x_End_Date := l_StartDateTab(l_StartDateTab.first)-1;
       x_inc_util_flag := 'N';
       l_found_flag := 'Y';
    elsif (p_item_date > l_EndDateTab(l_EndDateTab.last)) then
       x_Start_Date := l_EndDateTab(l_EndDateTab.last)+1;
       x_End_Date :=  TO_DATE('12/31/4000','MM/DD/YYYY');
       x_inc_util_flag := 'N';
       l_found_flag := 'Y';
    else
       <<l_date_loop>>
       for i IN l_StartDateTab.first .. l_StartDateTab.last LOOP
          if (p_item_date >= l_StartDateTab(i) AND
              p_item_date <= l_EndDateTab(i)) THEN
             l_found_flag := 'Y';
             x_Start_Date := l_StartDateTab(i);
             x_End_Date := l_EndDateTab(i);
             x_inc_util_flag := l_UtilFlagTab(i);
             l_found_flag := 'Y';
             exit l_date_loop;
          end if;

          if (l_EndDateTab(i) < p_item_date) then
             l_close_start_date := l_EndDateTab(i) + 1;
             -- We can rely that there is an i+1 record because
             -- p_item_date must be between the min and max to go into
             -- this loop.
             l_close_end_date := l_StartDateTab(i+1) - 1;
          end if;

       end loop;
    end if;

    if (l_found_flag = 'N') then
       x_Start_Date := l_close_start_date;
       x_End_Date := l_close_end_date;
       x_inc_util_flag := 'N';
    end if;

    x_return_status :=FND_API.G_RET_STS_SUCCESS;

     EXCEPTION

       WHEN OTHERS THEN
         x_msg_count     := 1;
         x_msg_data      := sqlerrm;
         FND_MSG_PUB.add_exc_msg
         (p_pkg_name   => 'PA_FORECASTITEM_PVT.Is_Include_Utilisation',
          p_procedure_name => PA_DEBUG.G_Err_Stack);
          x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

	-- 4537865
	x_start_date := NULL ;
	x_end_date := NULL ;
	x_inc_util_flag := NULL ;

		               If x_msg_count = 1 THEN
				              pa_interface_utils_pub.get_messages
				                (p_encoded        => FND_API.G_TRUE,
					               p_msg_index      => 1,
					               p_msg_count      => x_msg_count,
					               p_msg_data       => x_msg_data,
					               p_data           => l_data , -- 4537865
					               p_msg_index_out  => l_msg_index_out );
						x_msg_data := l_data ;  -- 4537865
		               End If;
          PA_FORECAST_ITEMS_UTILS.log_message(x_msg_data);
          raise;


   END Is_Include_Utilisation;


   PROCEDURE copy_requirement_fi (
                 p_requirement_id_tbl      IN   PA_ASSIGNMENTS_PUB.assignment_id_tbl_type,
                 p_requirement_source_id   IN   NUMBER,
                 x_return_status          OUT  NOCOPY VARCHAR2,  -- 4537865
                 x_msg_count              OUT  NOCOPY NUMBER,  -- 4537865
                 x_msg_data               OUT  NOCOPY VARCHAR2)  -- 4537865
   IS

	           l_msg_index_out	            NUMBER;
		   l_data varchar2(2000);  -- 4537865
   li_new_forecast_item_id NUMBER;
   ld_start_date DATE;
   ld_end_date   DATE;
   li_source_hdr_first_index NUMBER;
   li_source_hdr_last_index NUMBER;
   li_source_dtl_first_index NUMBER;
   li_source_dtl_last_index NUMBER;
   li_counter_source_hdr NUMBER;
   li_counter_source_dtl NUMBER;
   li_hdr_ins_count NUMBER := 1;
   li_dtl_ins_count NUMBER := 1;

   lt_SourceFIHdrTab PA_FORECAST_GLOB.FIHdrTabTyp;
   lt_SourceFIDtlTab PA_FORECAST_GLOB.FIDtlTabTyp;

   lt_FIHdrInsTab PA_FORECAST_GLOB.FIHdrTabTyp;
   lt_FIDtlInsTab PA_FORECAST_GLOB.FIDtlTabTyp;

   BEGIN
      print_message('Entering copy_requirement_fi');

	 -- 4537865
	-- Initialize x_return_status to Success
	x_return_status := FND_API.G_RET_STS_SUCCESS ;

      if (p_requirement_id_tbl.count = 0) then
         Print_message('Leaving copy_requirement_fi');
         RETURN;
      end if;

      select start_date, end_date
      into ld_start_date, ld_end_date
      from pa_project_assignments
      where assignment_id = p_requirement_source_id;

      print_message('Start calling fetch_fi_hdr');
      Fetch_FI_Hdr(
            p_assignment_id => p_requirement_source_id,
            p_resource_id => null,
            p_start_date => ld_start_date,
            p_end_date => ld_end_date,
            x_dbFIHdrTab => lt_SourceFIHdrTab,
            x_return_status => x_return_status,
            x_msg_count => x_msg_count,
            x_msg_data => x_msg_data);
      print_message('End calling fetch_fi_hdr');

      if (lt_SourceFIHdrTab.count = 0) then
         Print_message('Leaving copy_requirement_fi');
         RETURN;
      end if;

      print_message('Start calling fetch_fi_dtl');
      Fetch_FI_Dtl(
            p_assignment_id => p_requirement_source_id,
            p_resource_id => null,
            p_start_date => ld_start_date,
            p_end_date => ld_end_date,
            x_dbFIDtlTab => lt_SourceFIDtlTab,
            x_return_status => x_return_status,
            x_msg_count => x_msg_count,
            x_msg_data => x_msg_data);
      print_message('End calling fetch_fi_dtl');

      if (lt_SourceFIDtlTab.count = 0) then
         Print_message('Leaving copy_requirement_fi');
         RETURN;
      end if;

      li_source_hdr_first_index := NVL(lt_SourceFIHdrTab.first,0);
      li_source_hdr_last_index := NVL(lt_SourceFIHdrTab.last,-1);
      li_source_dtl_first_index := NVL(lt_SourceFIDtlTab.first, 0);
      li_source_dtl_last_index := NVL(lt_SourceFIDtlTab.last, -1);

      print_message('Start requirement tbl loop');
      FOR l_counter IN p_requirement_id_tbl.FIRST .. p_requirement_id_tbl.LAST  LOOP
         li_counter_source_hdr := li_source_hdr_first_index;
         li_counter_source_dtl := li_source_dtl_first_index;

         print_message('Start source hdr record loop');
         FOR li_counter_source_hdr IN li_source_hdr_first_index .. li_source_hdr_last_index LOOP

            lt_FIHdrInsTab(li_hdr_ins_count) := lt_SourceFIHdrTab(li_counter_source_hdr);

            select pa_forecast_items_s.NEXTVAL
              into li_new_forecast_item_id
              from dual;

            lt_FIHdrInsTab(li_hdr_ins_count).forecast_item_id := li_new_forecast_item_id;
            lt_FIHdrInsTab(li_hdr_ins_count).assignment_id := p_requirement_id_tbl(l_counter).assignment_id;

            if (li_counter_source_dtl <= li_source_dtl_last_index AND
                lt_SourceFIHdrTab(li_counter_source_hdr).forecast_item_id =
                            lt_SourceFIDtlTab(li_counter_source_dtl).forecast_item_id) then

               lt_FIDtlInsTab(li_dtl_ins_count) := lt_SourceFIDtlTab(li_counter_source_dtl);
               lt_FIDtlInsTab(li_dtl_ins_count).forecast_item_id := li_new_forecast_item_id;
               lt_FIDtlInsTab(li_dtl_ins_count).line_num := 1;
               lt_FIDtlInsTab(li_dtl_ins_count).reversed_flag := 'N';
               lt_FIDtlInsTab(li_dtl_ins_count).net_zero_flag := 'N';
               lt_FIDtlInsTab(li_dtl_ins_count).line_num_reversed := 0;

               if (NVL(lt_SourceFIDtlTab(li_counter_source_dtl).forecast_summarized_code,'Y') = 'Y') then
                  lt_FIDtlInsTab(li_dtl_ins_count).forecast_summarized_code := 'Y';
               else
                  lt_FIDtlInsTab(li_dtl_ins_count).forecast_summarized_code :=
                      lt_SourceFIDtlTab(li_counter_source_dtl).forecast_summarized_code;
               end if;


               if (NVL(lt_SourceFIDtlTab(li_counter_source_dtl).PJI_SUMMARIZED_FLAG,'Y') = 'Y') then
                  lt_FIDtlInsTab(li_dtl_ins_count).PJI_SUMMARIZED_FLAG := 'Y';
               else
                  lt_FIDtlInsTab(li_dtl_ins_count).PJI_SUMMARIZED_FLAG :=
                      lt_SourceFIDtlTab(li_counter_source_dtl).PJI_SUMMARIZED_FLAG;
               end if;

               if (NVL(lt_SourceFIDtlTab(li_counter_source_dtl).util_summarized_code,'Y') = 'Y') then
                  lt_FIDtlInsTab(li_dtl_ins_count).util_summarized_code := 'Y';
               else
                  lt_FIDtlInsTab(li_dtl_ins_count).util_summarized_code :=
                      lt_SourceFIDtlTab(li_counter_source_dtl).util_summarized_code;
               end if;
               li_dtl_ins_count := li_dtl_ins_count + 1;
               li_counter_source_dtl := li_counter_source_dtl + 1;
            end if;
            li_hdr_ins_count := li_hdr_ins_count + 1;
         END LOOP;
         print_message('End source hdr record loop');

      END LOOP;
      print_message('End requirement tbl loop');

      if (nvl(lt_FIHdrInsTab.count,0) <> 0) then
         print_message('Start calling PA_FORECAST_HDR_PKG.Insert_Rows');
                      PA_FORECAST_HDR_PKG.Insert_Rows(
                                                  lt_FIHdrInsTab,
                                                  x_return_status,
                                                  x_msg_count,
                                                  x_msg_data);
         print_message('End calling PA_FORECAST_HDR_PKG.Insert_Rows');
      end if;

      if (nvl(lt_FIDtlInsTab.count,0) <> 0) then
         print_message('Start calling PA_FORECAST_DTLS_PKG.Insert_Rows');
                      PA_FORECAST_DTLS_PKG.Insert_Rows(
                                                  lt_FIDtlInsTab,
                                                  x_return_status,
                                                  x_msg_count,
                                                  x_msg_data);
         print_message('End calling PA_FORECAST_DTLS_PKG.Insert_Rows');
      end if;

   EXCEPTION
     WHEN OTHERS THEN
     x_msg_count     := 1;
     x_msg_data      := sqlerrm;
     x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
     FND_MSG_PUB.add_exc_msg(p_pkg_name => 'PA_FORECASTITEM_PVT',
       p_procedure_name => 'Copy_Requirement_FI');
		               If x_msg_count = 1 THEN
				              pa_interface_utils_pub.get_messages
				                (p_encoded        => FND_API.G_TRUE,
					               p_msg_index      => 1,
					               p_msg_count      => x_msg_count,
					               p_msg_data       => x_msg_data,
					               p_data           => l_data,  -- 4537865
					               p_msg_index_out  => l_msg_index_out );
						x_msg_data := l_data ;  -- 4537865
		               End If;
     RAISE;
   END copy_requirement_fi;

BEGIN
null;
-- Back end code run in self-service cannot use globals.
--g_TimelineProfileSetup  := PA_TIMELINE_UTIL.get_timeline_profile_setup;
--AVAILABILITY_DURATION   := g_TimelineProfileSetup.availability_duration;
--g_process_mode          VARCHAR2(30);

END;

/
