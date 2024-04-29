--------------------------------------------------------
--  DDL for Package Body PA_RBS_ASGMT_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PA_RBS_ASGMT_PVT" AS
/* $Header: PARASGVB.pls 120.1.12010000.2 2008/09/18 04:49:38 rballamu ship $*/

   -- Standard who
   g_last_updated_by         NUMBER(15) := FND_GLOBAL.USER_ID;
   g_last_update_date        DATE       := SYSDATE;
   g_creation_date           DATE       := SYSDATE;
   g_created_by              NUMBER(15) := FND_GLOBAL.USER_ID;
  -- g_last_update_login       NUMBER(15) := FND_GLOBAL.LOG_ID;

/**********************************************************
 * Function : Check_Primary_rep_flag
 * Parameter: p_project_id,p_rbs_header_id
 * Return   : Varchar2
 * Desc     : The purpose of this Function is to determine if
 *            The Value of the Primary reporting RBS flag can be set to
 *            'Y' or not. It checks to see if any other RBS asso.
 *            to the project have the flag set to 'Y' already.
 *            If yes then we shouldn't allow the user to create/Update
 *            the value for the flag to 'Y'.
 ******************************************************************/
 FUNCTION Check_Primary_rep_flag
          (p_project_id  IN NUMBER,
           p_rbs_header_id IN NUMBER)
  RETURN VARCHAR2
  IS
    l_primary_rep_exists Varchar2(1) := 'N';
  BEGIN
     BEGIN
        SELECT 'Y'
        INTO l_primary_rep_exists
        FROM dual
        WHERE EXISTS
              (SELECT rbs_prj_assignment_id
               FROM  pa_rbs_prj_assignments
               WHERE  project_id = p_project_id
               AND assignment_status = 'ACTIVE'
               AND primary_reporting_rbs_flag = 'Y'
               AND rbs_header_id <> p_rbs_header_id);
     EXCEPTION
     WHEN NO_DATA_FOUND THEN
          l_primary_rep_exists := 'N';
     WHEN OTHERS THEN
          l_primary_rep_exists := 'Y';
     END;

     RETURN l_primary_rep_exists;
END Check_Primary_rep_flag;

/**************************************************************
 * Procedure   : Create_RBS_Assignment
 * Description : The purpose of this procedure is to associate
 *               an RBS to a project for any of the 4 uasges:-
 *               Reporting, Financial Plan, Workplan and
 *               Program Reporting.
 *               Reporting is the Default Usage type for all the
 *               associations.
 *               This Package would take care of all the validations
 *               necessary and then call the PA_RBS_ASGMT_Pkg to
 *               do the insertion.
 *Called From    : PA_RBS_ASGMT_PUB.Create_RBS_Assignment
 ****************************************************************/
PROCEDURE Create_RBS_Assignment(
   p_rbs_header_id        IN    NUMBER,
   p_rbs_version_id       IN    NUMBER      DEFAULT NULL,
   p_project_id           IN    NUMBER,
   p_wp_usage_flag        IN    VARCHAR2    DEFAULT NULL,
   p_fp_usage_flag        IN    VARCHAR2    DEFAULT NULL,
   p_prog_rep_usage_flag  IN    VARCHAR2    DEFAULT NULL,
   p_primary_rep_flag     IN    VARCHAR2    DEFAULT 'N',
   x_return_status        OUT   NOCOPY      VARCHAR2  ,
   x_msg_count            OUT   NOCOPY      NUMBER    ,
   x_error_msg_data       OUT   NOCOPY      VARCHAR2)
IS
  --Declaration of Local Variables
  l_count                 Number;
  l_fp_assoc_id           Number(15);
  l_rbs_version_id        Number(15);
  l_exists_association    Varchar2(1);
  l_rbs_header_id         Number;
  l_return_status         Varchar2(30);
  l_rbs_prj_assignment_id Number(15);
  l_record_version_number Number;
  l_primary_assignment    Varchar2(1);
  l_wp_flag               Varchar2(1);
  l_fp_flag               Varchar2(1);
  l_prog_flag             Varchar2(1);
  l_msg_code              Number;
  l_sys_program_flag      Varchar2(1);
BEGIN
   x_msg_count := 0;
   x_return_status := FND_API.G_RET_STS_SUCCESS;

   -- Check to see if the flag parameters have been defaulted or passed
   -- in as Y or N.
   l_prog_flag := nvl(p_prog_rep_usage_flag, 'N');
   l_wp_flag := nvl(p_wp_usage_flag, 'N');
   l_fp_flag := nvl(p_fp_usage_flag, 'N');

  /******************************************
   * Check if the Header ID passed is a valid  in
   * the system. This is done by checking for the
   * header ID in the pa_rbs_headers_b table.
   ********************************************/
   BEGIN
      SELECT rbs_header_id
      INTO l_rbs_header_id
      FROM pa_rbs_headers_b
      WHERE rbs_header_id = p_rbs_header_id;
   EXCEPTION
   WHEN NO_DATA_FOUND THEN
      x_return_status := FND_API.G_RET_STS_ERROR;
      x_msg_count := x_msg_count + 1;
      --Need to get a message for this.
      x_error_msg_data := 'PA_INVALID_HEADER_ID';
      PA_UTILS.Add_Message ('PA', x_error_msg_data);
      Return;
   WHEN OTHERS THEN
      x_return_status := FND_API.G_RET_STS_ERROR;
      x_msg_count := x_msg_count + 1;
      x_error_msg_data := 'PA_INVALID_HEADER_ID';
      PA_UTILS.Add_Message ('PA', x_error_msg_data);
      Return;
   END;

  /************************************************
 * Check if a Value has been passed for the Version
 * ID parameter. If a value has been passed, then
 * Use that else call the API x and get the Version ID.
 * **************************************************/
--    IF p_rbs_version_id IS NULL THEN -- for bug 7376494
         l_rbs_version_id :=
               PA_RBS_UTILS.get_max_rbs_frozen_version(p_rbs_header_id);
    -- ELSE -- bug 7376494
      /********************************************
      * Check if the version ID passed corresponds to the
      * header_id passed.
      **************************************************/
    IF l_rbs_version_id IS NULL THEN  -- bug 7376494
       BEGIN

	IF p_rbs_version_id IS NOT NULL THEN
         SELECT rbs_version_id
         INTO l_rbs_version_id
         FROM pa_rbs_versions_b
         WHERE rbs_version_id = p_rbs_version_id
         AND   rbs_header_id = p_rbs_header_id
         AND status_code = 'FROZEN';
	ELSE
	 RAISE NO_DATA_FOUND;
	END IF;

      EXCEPTION
      WHEN NO_DATA_FOUND THEN
          x_return_status := FND_API.G_RET_STS_ERROR;
          x_msg_count := x_msg_count + 1;
          --Need to get a message for this.
          x_error_msg_data := 'PA_VER_NOT_CORR_HEADER';
          PA_UTILS.Add_Message ('PA', x_error_msg_data);
          RETURN;
      WHEN OTHERS THEN
         x_return_status :=  FND_API.G_RET_STS_UNEXP_ERROR;
         x_msg_count :=  x_msg_count + 1;
         RETURN;
      END;
    END IF;


  /************************************************
  * First check if the program reporting usage flag is set to 'Y'.
  * If so then check for the sys_program_flag of that project.
  * Raise error if it is 'N' coz it cannot be used for reporting
  * since its not a program.
  *************************************************/

  SELECT sys_program_flag
  INTO   l_sys_program_flag
  FROM   pa_projects_all
  WHERE  project_id = p_project_id;

 IF p_prog_rep_usage_flag = 'Y' AND l_sys_program_flag = 'N' THEN
	 x_return_status := FND_API.G_RET_STS_ERROR;
         x_msg_count := x_msg_count + 1;
         --Need to get a message for this.
         x_error_msg_data := 'PA_RBS_NOT_A_PROGRAM';
         PA_UTILS.Add_Message ('PA', x_error_msg_data);
         RETURN;
 END IF;


  /***********************************************
   * First check the primary reporting flag that is passed.
   * If the value is passed as 'Y' then check if for the RBS
   * header ID passed, any of the assignments have a value
   * of 'Y'. If yes then throw an error message and Return.
   ****************************************************/
 IF p_primary_rep_flag = 'Y' THEN
    IF Check_Primary_rep_flag(p_project_id,p_rbs_header_id) = 'Y' THEN
         x_return_status := FND_API.G_RET_STS_ERROR;
         x_msg_count := x_msg_count + 1;
         --Need to get a message for this.
         x_error_msg_data := 'PA_EXISTS_PRIM_REP';
         PA_UTILS.Add_Message ('PA', x_error_msg_data);
         RETURN;
    END IF;
 END IF;

 -- Bug 3712581 -- If the WP usage is Y, check whether another RBS
 -- association exists with WP usage as Y.  If it does, then make it N.

 IF l_wp_flag = 'Y' THEN

       UPDATE pa_rbs_prj_assignments
       SET    wp_usage_flag = 'N'
       WHERE  rbs_header_id    <> p_rbs_header_id
       AND    rbs_version_id   <> l_rbs_version_id
       AND    project_id        = p_project_id
       AND    wp_usage_flag     = 'Y'
       AND    assignment_status = 'ACTIVE';

 END IF;

  -- Bug 3712581 -- If the FP usage is Y, check whether another RBS
  -- association exists with FP usage as Y which is not used by any plan
  -- type or version.  If it does, then make it N.

-- hr_utility.trace_on(NULL, 'RMFP');
-- hr_utility.trace('start *********');
-- hr_utility.trace('l_rbs_version_id IS : ' || l_rbs_version_id);
-- hr_utility.trace('p_project_id IS : ' || p_project_id);
 IF l_fp_flag = 'Y' THEN

       BEGIN
       SELECT rpa.rbs_prj_assignment_id
       INTO   l_fp_assoc_id
       FROM   pa_rbs_prj_assignments rpa
       WHERE  rpa.project_id = p_project_id
       AND    rpa.fp_usage_flag = 'Y'
       AND    rpa.assignment_status = 'ACTIVE'
       -- AND    rpa.rbs_version_id <> l_rbs_version_id
       AND    rpa.rbs_version_id NOT IN (
                                 SELECT pfo.rbs_version_id
                                 FROM   pa_proj_fp_options pfo
                                 WHERE  pfo.project_id  = rpa.project_id
                                 AND    ((pfo.fin_plan_type_id <> (
                                            SELECT pt.fin_plan_type_id
                                              FROM pa_fin_plan_types_b pt
                                             WHERE use_for_workplan_flag = 'Y'))
                                         OR
                                         (pfo.fin_plan_type_id IS NULL)));

-- hr_utility.trace('l_fp_assoc_id IS : ' || l_fp_assoc_id);
       UPDATE pa_rbs_prj_assignments
       SET    fp_usage_flag = 'N'
       WHERE  rbs_prj_assignment_id = l_fp_assoc_id;

-- hr_utility.trace('done upd');
       EXCEPTION WHEN NO_DATA_FOUND THEN
          l_fp_assoc_id := null;
       END;

 END IF;

  /***********************************************
  * Check for existance of the RBS association for
  * the project. ie if the RBS passed already exists
  * for the project_id passed. Then we just need to
  * do an Update. Only if it does not exist do an
  * Insert.
  ************************************************/
   BEGIN
      SELECT 'Y'
      INTO l_exists_association
      FROM dual
      WHERE EXISTS
             (SELECT rbs_prj_assignment_id
              FROM pa_rbs_prj_assignments
              WHERE rbs_header_id = p_rbs_header_id
              AND rbs_version_id  = l_rbs_version_id
              AND project_id      = p_project_id
              AND assignment_status = 'ACTIVE');
   EXCEPTION
   WHEN NO_DATA_FOUND THEN
       l_exists_association := 'N';
   WHEN OTHERS THEN
       l_exists_association := 'Y';
   END;

   IF l_exists_association = 'Y' THEN
     /******************************************
     * If record already exists then derive
     * the corr rbs_prj_assignment_id and the
     * record_version_number and then pass those
     * to the Update_Row Procedure.
     ********************************************/
        BEGIN
           SELECT rbs_prj_assignment_id, record_version_number,
                  nvl(p_wp_usage_flag, wp_usage_flag),
                  nvl(p_fp_usage_flag, fp_usage_flag),
                  nvl(p_prog_rep_usage_flag, prog_rep_usage_flag)
           INTO l_rbs_prj_assignment_id, l_record_version_number,
                l_wp_flag, l_fp_flag, l_prog_flag
           FROM pa_rbs_prj_assignments
           WHERE project_id = p_project_id
           AND   rbs_header_id = p_rbs_header_id
           AND   rbs_version_id = l_rbs_version_id; -- changed 7376494 to pass on value of max frozen RBS version id
        EXCEPTION
        WHEN OTHERS THEN
           x_return_status :=  FND_API.G_RET_STS_UNEXP_ERROR;
           x_msg_count :=  x_msg_count + 1;
           RETURN;
       END;

     /************************************************
     * Call to PA_RBS_ASGMT_PKG.Update_Row procedure, which would
     * take care of Updation of the pa_rbs_prj_assignments
     * table.
     *****************************************************/
       PA_RBS_ASGMT_PKG.Update_Row(
           p_rbs_prj_assignment_id  => l_rbs_prj_assignment_id ,
           p_wp_usage_flag          => l_wp_flag,
           p_fp_usage_flag          => l_fp_flag,
           p_prog_rep_usage_flag    => l_prog_flag,
           p_primary_rep_flag       => p_primary_rep_flag,
           p_record_version_number  => l_record_version_number,
           x_return_status          => l_return_status  );

        IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
             x_return_status :=  FND_API.G_RET_STS_UNEXP_ERROR;
             x_msg_count :=  x_msg_count + 1;
             RETURN;
        END IF;
   ELSE
       /**************************************
       * Get the rbs Assignment ID from the sequence
       * PA_RBS_PRJ_ASSIGNMENTS_S
       ******************************************/
       SELECT PA_RBS_PRJ_ASSIGNMENTS_S.NEXTVAL
       INTO l_rbs_prj_assignment_id
       FROM DUAL;
     /************************************************
     * Call to PA_RBS_ASGMT_PKG.Insert_Row procedure, which would
     * take care of Insertion into the pa_rbs_prj_assignments
     * table.
     *****************************************************/
       BEGIN
          SELECT count(*)
          INTO l_count
          FROM pa_rbs_prj_assignments
          WHERE project_id = p_project_id
          AND assignment_status = 'ACTIVE' ;
       END;
       IF l_count = 0 THEN
           l_primary_assignment := 'Y';
       ELSE
           l_primary_assignment := p_primary_rep_flag;
       END IF;

       PA_RBS_ASGMT_PKG.Insert_Row(
              p_rbs_assignment_id    => l_rbs_prj_assignment_id,
              p_rbs_header_id        => p_rbs_header_id,
              p_rbs_version_id       => l_rbs_version_id,
              p_project_id           => p_project_id,
              p_wp_usage_flag        => l_wp_flag,
              p_fp_usage_flag        => l_fp_flag,
              p_prog_rep_usage_flag  => l_prog_flag,
              p_primary_rep_flag     => l_primary_assignment,
              x_return_status        => l_return_status);

      IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
           x_return_status :=  FND_API.G_RET_STS_UNEXP_ERROR;
           x_msg_count :=  x_msg_count + 1;
           RETURN;
      END IF;
     BEGIN
          PJI_FM_XBS_ACCUM_MAINT.RBS_PUSH
               (P_NEW_RBS_VERSION_ID => l_rbs_version_id,
                P_PROJECT_ID         => p_project_id,
                X_RETURN_STATUS      => l_return_status,
                x_msg_code           => l_msg_code);
      END;
      /****************************************************
      * Updating the Value of x_rbs_prj_assignment_id and
      * x_record_version_number after insertion.??
      ********************************************************/
   END IF;

   -- After Update or Insert, if the program reporting flag was Y, log event
   IF p_prog_rep_usage_flag = 'Y' THEN
      PJI_FM_XBS_ACCUM_MAINT.RBS_PUSH
                 (P_NEW_RBS_VERSION_ID => l_rbs_version_id,
                  P_PROJECT_ID         => p_project_id,
                  P_PROGRAM_FLAG       => p_prog_rep_usage_flag,
                  X_RETURN_STATUS      => l_return_status,
                  X_MSG_CODE           => l_msg_code);
   END IF;

   /* Add check to ensure that if only one association exists, then
    * the primary reporting flag is set to 'Y' */
   BEGIN
   SELECT count(*)
   INTO  l_count
   FROM  pa_rbs_prj_assignments
   WHERE project_id = p_project_id
   AND   assignment_status = 'ACTIVE'
   AND   primary_reporting_rbs_flag = 'Y';
   END;

   IF l_count = 0 THEN
      UPDATE pa_rbs_prj_assignments
      SET    primary_reporting_rbs_flag = 'Y'
      WHERE  project_id = p_project_id
      AND    assignment_status = 'ACTIVE'
      AND    rownum = 1;
   END IF;

END Create_RBS_Assignment;
/***************************/
/**************************************************************
 * Procedure   : Update_RBS_Assignment
 * Description : The purpose of this procedure is to update an associate
 *               of an RBS to a project for any of the 4 uasges:-
 *               Reporting, Financial Plan, Workplan and
 *               Program Reporting.
 *               Reporting is the Default Usage type for all the
 *               associations.
 *               This Package would take care of all the validations
 *               necessary and then call the PA_RBS_ASGMT_Pkg.Update_Row to
 *               do the Updation.
 *Called From    : PA_RBS_ASGMT_PUB.Update_RBS_Assignment
 ****************************************************************/
PROCEDURE Update_RBS_Assignment(
   p_rbs_prj_assignment_id  IN    NUMBER,
   p_wp_usage_flag        IN    VARCHAR2    DEFAULT 'N',
   p_fp_usage_flag        IN    VARCHAR2    DEFAULT 'N',
   p_prog_rep_usage_flag  IN    VARCHAR2    DEFAULT 'N',
   p_primary_rep_flag     IN    VARCHAR2    DEFAULT 'N',
   p_record_version_number IN   Number,
   p_set_as_primary        IN   Varchar2    DEFAULT 'N',
   x_return_status        OUT   NOCOPY      VARCHAR2 ,
   x_msg_count            OUT   NOCOPY      NUMBER,
   x_error_msg_data       OUT   NOCOPY      VARCHAR2   )
IS
  l_return_status Varchar2(30);
  l_project_id    Number;
  l_rbs_header_id Number;
  l_rbs_version_id Number;
  l_msg_code   Varchar2(30);
BEGIN
   x_msg_count := 0;
   x_return_status := FND_API.G_RET_STS_SUCCESS;
  /*************************************************
   * Derive the Project_id and RBS_header_id based on
   * the rbs_prj_assignment_id from the
   * pa_rbs_prj_assignments table. These values will then
   * be passed to the Check_Primary_rep_flag function
   **************************************************/
   BEGIN
     SELECT project_id,rbs_header_id,rbs_version_id
     INTO l_project_id,l_rbs_header_id,l_rbs_version_id
     FROM pa_rbs_prj_assignments
     WHERE rbs_prj_assignment_id = p_rbs_prj_assignment_id;
   EXCEPTION
   WHEN OTHERS THEN
      x_return_status :=  FND_API.G_RET_STS_UNEXP_ERROR;
      x_msg_count :=  x_msg_count + 1;
      RETURN;
   END;
   IF p_set_as_primary = 'Y' THEN
       BEGIN
         UPDATE pa_rbs_prj_assignments
         SET primary_reporting_rbs_flag = 'N'
         WHERE project_id = l_project_id
         AND primary_reporting_rbs_flag = 'Y'
         AND assignment_status = 'ACTIVE';
       END;
   END IF;
 /***********************************************
  * First check the primary reporting flag that is passed.
  * If the value is passed as 'Y' then check if for the RBS
  * header ID passed, any of the assignments have a value
  * of 'Y'. If yes then throw an error message and Return.
  ****************************************************/
 IF p_primary_rep_flag = 'Y' THEN
    IF Check_Primary_rep_flag(l_project_id,l_rbs_header_id) = 'Y' THEN
         x_return_status := FND_API.G_RET_STS_ERROR;
         x_msg_count := x_msg_count + 1;
         --Need to get a message for this.
         x_error_msg_data := 'PA_EXISTS_PRIM_REP';
         PA_UTILS.Add_Message ('PA', x_error_msg_data);
         RETURN;
    END IF;
 END IF;

  /******************************************************
   * Call to the Pa_rbs_Asgmt_pkg.Update_Row Procedure
   * Which would update the values in the table
   * pa_rbs_prj_asignemnts with the values passed.
   *****************************************************/
     Pa_Rbs_Asgmt_Pkg.Update_Row(
         p_rbs_prj_assignment_id  => p_rbs_prj_assignment_id ,
         p_wp_usage_flag        => p_wp_usage_flag,
         p_fp_usage_flag        => p_fp_usage_flag,
         p_prog_rep_usage_flag  => p_prog_rep_usage_flag,
         p_primary_rep_flag     => p_primary_rep_flag,
         p_record_version_number => p_record_version_number,
         x_return_status        => l_return_status  );

      IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
           x_return_status :=  FND_API.G_RET_STS_UNEXP_ERROR;
           x_msg_count :=  x_msg_count + 1;
           RETURN;
      END IF;
      IF p_prog_rep_usage_flag = 'Y' THEN
          PJI_FM_XBS_ACCUM_MAINT.RBS_PUSH
                (P_NEW_RBS_VERSION_ID => l_rbs_version_id,
                 P_PROJECT_ID         => l_project_id,
                 P_PROGRAM_FLAG       => p_prog_rep_usage_flag,
                 X_RETURN_STATUS      => l_return_status,
                 x_msg_code           => l_msg_code);
      END IF;
END Update_RBS_Assignment;

/**************************************************************
 * Procedure   : Delete_RBS_Assignment
 * Description : The purpose of this procedure is to Delete an associate
 *               of an RBS to a project for any of the 4 uasges:-
 *               This Package would take care of all the validations
 *               necessary and then call the PA_RBS_ASGMT_Pkg.Delete_Row to
 *               do the Remove operation.
 *               We cannot Remove any RBS that is being used for
 *               Workplan or Financial Plan.
 * Called From : PA_RBS_ASGMT_PUB.Delete_RBS_Assignment
 ****************************************************************/
PROCEDURE Delete_RBS_Assignment(
   p_rbs_prj_assignment_id  IN    NUMBER,
   x_return_status        OUT   NOCOPY      VARCHAR2,
   x_msg_count            OUT   NOCOPY      NUMBER,
   x_error_msg_data       OUT   NOCOPY      VARCHAR2   )
IS
  l_wp_usage_flag       Varchar2(1);
  l_fp_usage_flag       Varchar2(1);
  l_prog_rep_usage_flag Varchar2(1);
  l_project_id Number;
  l_rbs_version_id  Number;
  l_chk_prog  Number;
BEGIN
   /********************************************
 * This select is used to retrieve the wp_usage_flag,
 * fp_usage_flag and prog_rep_usage_flag
 * for the rbs_rpj_assignment_id passed, from the
 * pa_rbs_prj_assignments table.
 * We will then use these values to determine if Removal
 * of record is possible or not.
 * **********************************************/
   BEGIN
     SELECT WP_USAGE_FLAG, FP_USAGE_FLAG,
            PROG_REP_USAGE_FLAG,project_id,rbs_version_id
     INTO l_wp_usage_flag, l_fp_usage_flag,
          l_prog_rep_usage_flag,l_project_id,l_rbs_version_id
     FROM pa_rbs_prj_assignments
     WHERE RBS_PRJ_ASSIGNMENT_ID = p_rbs_prj_assignment_id;
   EXCEPTION
   WHEN OTHERS THEN
        x_return_status :=  FND_API.G_RET_STS_UNEXP_ERROR;
        x_msg_count :=  x_msg_count + 1;
        RETURN;
   END;
  /**************************************************
 * If the RBS is being used for Workplan or Financial
 * plan or Program reportinmg then we cannot remove the
 * record.
 * So we are only allowing removal of records for 'Reporting'.
 * **************************************************/
   IF (l_wp_usage_flag = 'Y' OR l_fp_usage_flag = 'Y')
   THEN
         x_return_status := FND_API.G_RET_STS_ERROR;
         x_msg_count := x_msg_count + 1;
         --Need to get a message for this.
         --If RBS used for WP FP it cannot be deleted.
         x_error_msg_data := 'PA_RBS_USED_WP_FP_PR';
         PA_UTILS.Add_Message ('PA', x_error_msg_data);
         RETURN;
   END IF;
   l_chk_prog := PJI_UTILS.CHECK_PROGRAM_RBS(
                       p_project_id => l_project_id,
                       p_rbs_version_id => l_rbs_version_id);
   IF  l_chk_prog = -1 THEN
         x_return_status := FND_API.G_RET_STS_ERROR;
         x_msg_count := x_msg_count + 1;
         --Need to get a message for this.
         --If RBS used for Prog Rep it cannot be deleted.
         x_error_msg_data := 'PA_RBS_USED_PROG_REP';
         PA_UTILS.Add_Message ('PA', x_error_msg_data);
         RETURN;
   END IF;


  PA_RBS_ASGMT_PKG.Delete_Row(
   p_rbs_prj_assignment_id  => p_rbs_prj_assignment_id,
   x_return_status          => x_return_status);

    IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
       x_return_status :=  FND_API.G_RET_STS_UNEXP_ERROR;
       x_msg_count :=  x_msg_count + 1;
       RETURN;
    END IF;

  -- Log an event for summarization purposes.
  PJI_FM_XBS_ACCUM_MAINT.RBS_DELETE (
    p_rbs_version_id => l_rbs_version_id
  , p_project_id     => l_project_id
  , x_return_status  => x_return_status
  , x_msg_code       => x_error_msg_data);

  IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
     x_msg_count :=  x_msg_count + 1;
     RETURN;
  END IF;

END Delete_RBS_Assignment;
/**************************************************
 * Procedure : Associate_Rbs_To_Program
 * Description : This API is used to associate an
 *               RBS to the list of project_ID's
 *               passed in as a table.
 *               We are going to set the program reporting
 *               flag = 'Y' and the reporting flag = 'Y'
 *               Rest of the flag's = 'N'
 **************************************************/
PROCEDURE Associate_Rbs_To_Program(
   p_rbs_header_id        IN    NUMBER,
   p_rbs_version_id       IN    NUMBER      DEFAULT NULL,
   p_project_id_tbl       IN    SYSTEM.PA_NUM_TBL_TYPE,
   x_return_status        OUT   NOCOPY   VARCHAR2)
IS
 l_rbs_version_id Number;
 l_exception Exception;
 l_exists_association Varchar2(1);
 l_rbs_prj_assignment_id Number;
 l_record_version_number Number;
 l_return_status Varchar2(30);
BEGIN
   x_return_status := Fnd_Api.G_Ret_Sts_Success;
   /***********************************************************
    * This check is done to determine that the mandatory values
    * ie p_rbs_header_id is passed in and there is atleast 1
    * project ID passed in.
    **********************************************************/
   IF (p_project_id_tbl.count = 0) OR (p_rbs_header_id IS NULL) THEN
        x_return_status := Fnd_Api.G_Ret_Sts_Unexp_Error;
        RETURN;
   END IF;
   /*******************************************************
    * If no value is passed for the p_rbs_version_id parameter
    * then derive it, with a call to function
    * PA_RBS_UTILS.get_max_rbs_frozen_version passing the
    * rbs_header_id value.
    ******************************************************/
   IF p_rbs_version_id IS NULL THEN
       l_rbs_version_id :=
           PA_RBS_UTILS.get_max_rbs_frozen_version(p_rbs_header_id);
   ELSE
    /*******************************************************
    * Do a check to determine that the version ID passed in
    * corr to the header ID passed in.
    *******************************************************/
    BEGIN
         SELECT rbs_version_id
         INTO l_rbs_version_id
         FROM pa_rbs_versions_b
         WHERE rbs_version_id = p_rbs_version_id
         AND   rbs_header_id = p_rbs_header_id
         AND status_code = 'FROZEN';
      EXCEPTION
      WHEN OTHERS THEN
         x_return_status :=  FND_API.G_RET_STS_UNEXP_ERROR;
         RETURN;
      END;
   END IF;
   /******************************************************
    * Delete all the associations in the pa_rbs_prj_assignments
    * table which corr to the rbs_header, version and project ID
    * passed in, Which are Obsolete.
    ******************************************************/
  /*FORALL i IN p_project_id_tbl.first .. p_project_id_tbl.last
      DELETE FROM pa_rbs_prj_assignments
      WHERE rbs_header_id = p_rbs_header_id
      AND   rbs_version_id = l_rbs_version_id
      AND   project_id = p_project_id_tbl(i)
      AND assignment_status = 'OBSOLETE';
*/

  FOR i IN p_project_id_tbl.first .. p_project_id_tbl.last
  LOOP
     /***********************************************
     * Check for existance of the RBS association for
     * the project. ie if the RBS passed already exists
     * for the project_id passed. Then we just need to
     * do an Update. Only if it does not exist do an
     * Insert.
     ************************************************/
      BEGIN
         SELECT 'Y'
         INTO l_exists_association
         FROM dual
         WHERE EXISTS
                (SELECT rbs_prj_assignment_id
                 FROM pa_rbs_prj_assignments
                 WHERE rbs_header_id = p_rbs_header_id
                 AND rbs_version_id  = l_rbs_version_id
                 AND project_id      = p_project_id_tbl(i)
                 AND assignment_status = 'ACTIVE');
      EXCEPTION
      WHEN NO_DATA_FOUND THEN
          l_exists_association := 'N';
      WHEN OTHERS THEN
          l_exists_association := 'Y';
      END;

      IF l_exists_association = 'Y' THEN
          /******************************************
          * If record already exists then derive
          * the corr rbs_prj_assignment_id and the
          * record_version_number and then pass those
          * to the Update_Row Procedure.
          ********************************************/
             BEGIN
                SELECT rbs_prj_assignment_id, record_version_number
                INTO l_rbs_prj_assignment_id, l_record_version_number
                FROM pa_rbs_prj_assignments
                WHERE project_id = p_project_id_tbl(i)
                AND   rbs_header_id = p_rbs_header_id
                AND   rbs_version_id = l_rbs_version_id;
             EXCEPTION
             WHEN OTHERS THEN
                x_return_status :=  FND_API.G_RET_STS_UNEXP_ERROR;
                RETURN;
             END;

            /************************************************
            * Call to PA_RBS_ASGMT_PKG.Update_Row procedure, which would
            * take care of Updation of the pa_rbs_prj_assignments
            * table.
            * We only need to set the value for the
            * reporting_usage flag = 'Y' and the prog_rep_usage_flag
            * = 'Y'
            *****************************************************/
               BEGIN
                      UPDATE pa_rbs_prj_assignments
                      SET reporting_usage_flag = 'Y',
                          prog_rep_usage_flag  = 'Y',
                          last_update_date = sysdate,
                          record_version_number = record_version_number + 1
                      WHERE  Rbs_prj_assignment_id = l_rbs_prj_assignment_id
                      AND    assignment_status     = 'ACTIVE'
                      AND    prog_rep_usage_flag = 'N'
                      AND    NVL(record_version_number, 0) =
                             NVL(l_record_version_number, 0);
               EXCEPTION
               WHEN OTHERS THEN
                    x_return_status :=  FND_API.G_RET_STS_UNEXP_ERROR;
                    RETURN;
               END;
    ELSE
          /**************************************
          * Get the rbs Assignment ID from the sequence
          * PA_RBS_PRJ_ASSIGNMENTS_S
          ******************************************/
          SELECT PA_RBS_PRJ_ASSIGNMENTS_S.NEXTVAL
          INTO l_rbs_prj_assignment_id
          FROM DUAL;

          PA_RBS_ASGMT_PKG.Insert_Row(
                p_rbs_assignment_id    => l_rbs_prj_assignment_id,
                p_rbs_header_id        => p_rbs_header_id,
                p_rbs_version_id       => l_rbs_version_id,
                p_project_id           => p_project_id_tbl(i),
                p_wp_usage_flag        => 'N',
                p_fp_usage_flag        => 'N',
                p_prog_rep_usage_flag  => 'Y',
                p_primary_rep_flag     => 'N',
                x_return_status        => l_return_status  );

          IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
               x_return_status :=  FND_API.G_RET_STS_UNEXP_ERROR;
               RETURN;
          END IF;

      END IF;

  END LOOP;
END Associate_Rbs_To_Program;

/*****************************************************
 * Procedure : Assign_New_Version
 * Description : This API is used to assign the
 *               new version number passed to all
 *               the Projects passed in as a table.
 *               Update the pa_rbs_prj_assignments
 *               table.
 ****************************************************/
PROCEDURE Assign_New_Version(
   p_rbs_new_version_id     IN  Number,
   p_project_id_tbl         IN  SYSTEM.PA_NUM_TBL_TYPE,
   x_return_status          OUT NOCOPY Varchar2)
IS
   l_rbs_header_id     Number;
BEGIN
     X_Return_Status := Fnd_Api.G_Ret_Sts_Success;
     BEGIN
        SELECT rbs_header_id
        INTO l_rbs_header_id
        FROM pa_rbs_versions_b
        WHERE rbs_version_id = p_rbs_new_version_id;
     EXCEPTION
     WHEN OTHERS THEN
        X_Return_Status := Fnd_Api.G_Ret_Sts_UNEXP_ERROR;
        Return;
     END;

     FORALL i IN p_project_id_tbl.FIRST.. p_project_id_tbl.LAST
        UPDATE pa_rbs_prj_assignments
        SET rbs_version_id = p_rbs_new_version_id
        WHERE project_id = p_project_id_tbl(i)
        AND rbs_header_id = l_rbs_header_id
        AND assignment_status = 'ACTIVE' ;
EXCEPTION
WHEN OTHERS THEN
     X_Return_Status := Fnd_Api.G_Ret_Sts_UNEXP_ERROR;
     Return;
END Assign_New_Version;

/*****************************************************
 * Procedure   : Copy_Project_Assignment
 * Description : This API is used to copy the
 *               RBS project assignments from the
 *               source project to the destination
 *               project.
 ****************************************************/
PROCEDURE Copy_Project_Assignment(
   p_rbs_src_project_id    IN         NUMBER,
   p_rbs_dest_project_id   IN         NUMBER,
   x_return_status         OUT NOCOPY Varchar2)
IS
BEGIN
    x_return_status := Fnd_Api.G_Ret_Sts_SUCCESS;
    IF p_rbs_src_project_id IS NULL OR p_rbs_dest_project_id IS NULL THEN
        X_Return_Status := Fnd_Api.G_Ret_Sts_UNEXP_ERROR;
        Return;
    END IF;

    BEGIN
       INSERT INTO pa_rbs_prj_assignments
        (RBS_PRJ_ASSIGNMENT_ID,
         PROJECT_ID,
         RBS_VERSION_ID,
         RBS_HEADER_ID,
         REPORTING_USAGE_FLAG,
         WP_USAGE_FLAG,
         FP_USAGE_FLAG,
         PROG_REP_USAGE_FLAG,
         PRIMARY_REPORTING_RBS_FLAG,
         ASSIGNMENT_STATUS,
         LAST_UPDATE_DATE,
         LAST_UPDATED_BY,
         CREATION_DATE,
         CREATED_BY,
         LAST_UPDATE_LOGIN,
         RECORD_VERSION_NUMBER)
       SELECT
         PA_RBS_PRJ_ASSIGNMENTS_S.NEXTVAL,
         p_rbs_dest_project_id,
         a.RBS_VERSION_ID,
         a.RBS_HEADER_ID,
         a.REPORTING_USAGE_FLAG,
         a.WP_USAGE_FLAG,
         a.FP_USAGE_FLAG,
         a.PROG_REP_USAGE_FLAG,
         a.PRIMARY_REPORTING_RBS_FLAG,
         a.ASSIGNMENT_STATUS,
         SYSDATE,
         FND_GLOBAL.USER_ID,
         SYSDATE,
         FND_GLOBAL.USER_ID,
         FND_GLOBAL.LOGIN_ID,
         1
       FROM pa_rbs_prj_assignments a
       WHERE a.project_id = p_rbs_src_project_id
       and (a.RBS_VERSION_ID,a.RBS_HEADER_ID)
            NOT IN (select rbs_version_id,rbs_header_id
                    from pa_rbs_prj_assignments
	       	    where project_id = p_rbs_dest_project_id);
     EXCEPTION
     WHEN OTHERS THEN
         X_Return_Status := Fnd_Api.G_Ret_Sts_UNEXP_ERROR;
         Return;
     END;

EXCEPTION
WHEN OTHERS THEN
     X_Return_Status := Fnd_Api.G_Ret_Sts_UNEXP_ERROR;
     Return;
END Copy_Project_Assignment;

END PA_RBS_ASGMT_PVT;

/
