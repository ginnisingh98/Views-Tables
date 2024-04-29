--------------------------------------------------------
--  DDL for Package Body PA_RBS_ASGMT_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PA_RBS_ASGMT_PKG" AS
/* $Header: PARASGTB.pls 120.0 2005/06/03 13:33:52 appldev noship $*/

   -- Standard who
   g_last_updated_by         NUMBER(15) := FND_GLOBAL.USER_ID;
   g_last_update_date        DATE       := SYSDATE;
   g_creation_date           DATE       := SYSDATE;
   g_created_by              NUMBER(15) := FND_GLOBAL.USER_ID;
  -- g_last_update_login       NUMBER(15) := FND_GLOBAL.LOG_ID;

/**************************************************************
 * Procedure   : Insert_Row
 * Description : The purpose of this procedure is to
 *               Insert into the Pa_rbs_prj_assignments table
 *               the values passed as parameters from the
 *               PA_RBS_ASGMT_PVT pkg.
 ****************************************************************/
PROCEDURE Insert_Row(
   p_rbs_assignment_id    IN    NUMBER,
   p_rbs_header_id        IN    NUMBER,
   p_rbs_version_id       IN    NUMBER      DEFAULT NULL,
   p_project_id           IN    NUMBER,
   p_wp_usage_flag        IN    VARCHAR2    DEFAULT 'N',
   p_fp_usage_flag        IN    VARCHAR2    DEFAULT 'N',
   p_prog_rep_usage_flag  IN    VARCHAR2    DEFAULT 'N',
   p_primary_rep_flag     IN    VARCHAR2    DEFAULT 'N',
   x_return_status        OUT   NOCOPY      VARCHAR2  )
IS
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
     VALUES
         (p_rbs_assignment_id,
          p_project_id,
          p_rbs_version_id,
          p_rbs_header_id,
          'Y',
          p_wp_usage_flag,
          p_fp_usage_flag,
          p_prog_rep_usage_flag,
          p_primary_rep_flag,
          'ACTIVE',
          SYSDATE,
          FND_GLOBAL.USER_ID,
          SYSDATE,
          FND_GLOBAL.USER_ID,
          FND_GLOBAL.LOGIN_ID,
          1);
EXCEPTION
WHEN OTHERS THEN
    x_return_status :=  FND_API.G_RET_STS_UNEXP_ERROR;
    RETURN;
END Insert_Row;
/***************************/
/**************************************************************
 * Procedure   : Update_Row
 * Description : The purpose of this procedure is to
 *               Update the Pa_rbs_prj_assignments table
 *               the values passed as parameters from the
 *               PA_RBS_ASGMT_PVT pkg.
 ****************************************************************/
PROCEDURE Update_Row(
   p_rbs_prj_assignment_id  IN    NUMBER,
   p_wp_usage_flag        IN    VARCHAR2    DEFAULT 'N',
   p_fp_usage_flag        IN    VARCHAR2    DEFAULT 'N',
   p_prog_rep_usage_flag  IN    VARCHAR2    DEFAULT 'N',
   p_primary_rep_flag     IN    VARCHAR2    DEFAULT 'N',
   p_record_version_number IN   Number,
   x_return_status        OUT   NOCOPY      VARCHAR2  )
IS

BEGIN
   x_return_status := FND_API.G_RET_STS_SUCCESS;
   UPDATE pa_rbs_prj_assignments
   SET reporting_usage_flag       =    'Y',
       wp_usage_flag              =    p_wp_usage_flag,
       fp_usage_flag              =    p_fp_usage_flag,
       prog_rep_usage_flag        =    p_prog_rep_usage_flag,
       primary_reporting_rbs_flag =    p_primary_rep_flag,
       last_update_date           =    SYSDATE,
       last_updated_by            =    FND_GLOBAL.USER_ID,
       last_update_login          =    FND_GLOBAL.LOGIN_ID,
       record_version_number      = record_version_number +1
   WHERE Rbs_prj_assignment_id = p_rbs_prj_assignment_id
   AND   assignment_status     = 'ACTIVE'
   AND  NVL(record_version_number, 0) =
        NVL(p_record_version_number, 0);
   IF SQL%NOTFOUND THEN
      x_return_status :=  FND_API.G_RET_STS_UNEXP_ERROR;
      RETURN;
   END IF;
EXCEPTION
WHEN OTHERS THEN
    x_return_status :=  FND_API.G_RET_STS_UNEXP_ERROR;
    RETURN;
END Update_Row;

/**************************************************************
 * Procedure   : Delete_Row
 * Description : The purpose of this procedure is to
 *               delete the row in Pa_rbs_prj_assignments table
 *               based on the p_rbs_prj_assignment_id parameter
 *               passed from the Pa_rbs_asgmt_Pvt.Delete_Rbs_assignment
 *               procedure.
 ****************************************************************/
PROCEDURE Delete_Row(
   p_rbs_prj_assignment_id  IN    NUMBER,
   x_return_status          OUT   NOCOPY  VARCHAR2)
IS
BEGIN
    /***********************************************
     * Delete the record.
     **********************************************/
    DELETE FROM pa_rbs_prj_assignments
    WHERE RBS_PRJ_ASSIGNMENT_ID = p_rbs_prj_assignment_id;

    IF SQL%NOTFOUND THEN
      x_return_status :=  FND_API.G_RET_STS_UNEXP_ERROR;
      RETURN;
    END IF;
EXCEPTION
WHEN OTHERS THEN
    x_return_status :=  FND_API.G_RET_STS_UNEXP_ERROR;
    RETURN;
END Delete_Row;


END PA_RBS_ASGMT_PKG;

/
