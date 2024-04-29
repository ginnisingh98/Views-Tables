--------------------------------------------------------
--  DDL for Package Body PA_PT_CO_IMPL_STATUSES_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PA_PT_CO_IMPL_STATUSES_PKG" AS
/* $Header: PAFPCOIB.pls 120.1 2005/08/19 16:25:31 mwasowic noship $ */

g_module_name   VARCHAR2(100) := 'pa.plsql.PA_PT_CO_IMPL_STATUSES_PKG';

/*==================================================================
   API for inserting into the table
 ==================================================================*/
PROCEDURE INSERT_ROW (
      p_pt_co_impl_statuses_id          IN       pa_pt_co_impl_statuses.pt_co_impl_statuses_id%TYPE,
      p_fin_plan_type_id                IN       pa_pt_co_impl_statuses.fin_plan_type_id%TYPE,
      p_ci_type_id                      IN       pa_pt_co_impl_statuses.ci_type_id%TYPE,
      p_version_type                    IN       pa_pt_co_impl_statuses.version_type%TYPE,
      p_status_code                     IN       pa_pt_co_impl_statuses.status_code%TYPE,
      p_impl_default_flag               IN       pa_pt_co_impl_statuses.impl_default_flag%TYPE,
      x_row_id                          OUT      NOCOPY ROWID, --File.Sql.39 bug 4440895
      x_return_status                   OUT      NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
      x_msg_count                       OUT      NOCOPY NUMBER, --File.Sql.39 bug 4440895
      x_msg_data                        OUT      NOCOPY VARCHAR2) --File.Sql.39 bug 4440895
IS

BEGIN

      x_return_status := FND_API.G_RET_STS_SUCCESS;

      INSERT
      INTO  PA_PT_CO_IMPL_STATUSES (
            pt_co_impl_statuses_id,
            fin_plan_type_id,
            ci_type_id,
            version_type,
            status_code,
            impl_default_flag,
            record_version_number,
            creation_date,
            created_by,
            last_update_login,
            last_updated_by,
            last_update_date)
            VALUES(
            p_pt_co_impl_statuses_id,
            p_fin_plan_type_id,
            p_ci_type_id,
            p_version_type,
            p_status_code,
            p_impl_default_flag,
            1,
            sysdate,
            fnd_global.user_id,
            fnd_global.login_id,
            fnd_global.user_id,
            sysdate)
            RETURNING ROWID INTO x_row_id;

EXCEPTION
      WHEN OTHERS THEN
            x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
            x_msg_count     := 1;
            x_msg_data      := SQLERRM;
            FND_MSG_PUB.add_exc_msg( p_pkg_name         =>
'PA_PT_CO_IMPL_STATUSES_PKG',
                                     p_procedure_name   => 'INSERT_ROW');
            RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

END Insert_Row;

/*==================================================================
   API for updating records of the table
 ==================================================================*/
PROCEDURE UPDATE_ROW (
      p_pt_co_impl_statuses_id           IN       pa_pt_co_impl_statuses.pt_co_impl_statuses_id%TYPE,
      p_fin_plan_type_id                 IN       pa_pt_co_impl_statuses.fin_plan_type_id%TYPE,
      p_ci_type_id                       IN       pa_pt_co_impl_statuses.ci_type_id%TYPE,
      p_version_type                     IN       pa_pt_co_impl_statuses.version_type%TYPE,
      p_status_code                      IN       pa_pt_co_impl_statuses.status_code%TYPE,
      p_impl_default_flag                IN       pa_pt_co_impl_statuses.impl_default_flag%TYPE,
      p_record_version_number            IN       pa_pt_co_impl_statuses.record_version_number%TYPE,
      p_lock_row                         IN       VARCHAR2,
      x_return_status                    OUT      NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
      x_msg_count                        OUT      NOCOPY NUMBER, --File.Sql.39 bug 4440895
      x_msg_data                         OUT      NOCOPY VARCHAR2) --File.Sql.39 bug 4440895

IS
      l_record_version_number            NUMBER;

      l_debug_mode                       VARCHAR2(1);
      l_debug_level3                     CONSTANT NUMBER := 3;
      l_module_name                      VARCHAR2(100) := 'UPDATE_ROW' || g_module_name;
      l_return_status                    VARCHAR2(30);
      l_msg_count                        NUMBER;
      l_msg_index_out                    NUMBER;
      l_data                             VARCHAR2(2000);
      l_msg_data                         VARCHAR2(2000);

BEGIN

     x_return_status := FND_API.G_RET_STS_SUCCESS;

     l_debug_mode    := NVL(FND_PROFILE.value('PA_DEBUG_MODE'),'N');

     IF l_debug_mode = 'Y' THEN
           pa_debug.set_curr_function( p_function   => 'UPDATE_ROW',
                                       p_debug_mode => l_debug_mode );
     END IF;
     IF l_debug_mode = 'Y' THEN
            pa_debug.g_err_stage:= 'Entering UPDATE_ROW ';
            pa_debug.write(l_module_name,pa_debug.g_err_stage,
                                  l_debug_level3);
     END IF;

     IF l_debug_mode = 'Y' THEN
            pa_debug.g_err_stage:= 'The Co Impl Id : ' || p_pt_co_impl_statuses_id;
            pa_debug.write(l_module_name,pa_debug.g_err_stage,
                                  l_debug_level3);
     END IF;

     IF p_pt_co_impl_statuses_id IS NOT NULL THEN

            IF p_lock_row = 'Y' THEN
                 /* Calling Lock_Row */
                 IF l_debug_mode = 'Y' THEN
                      pa_debug.g_err_stage:= 'Calling Lock_Row when p_pt_co_impl_statuses_id is not null';
                      pa_debug.write(l_module_name,pa_debug.g_err_stage,
                                        l_debug_level3);
                 END IF;

                 Lock_Row(p_row_id                   => null,
                          p_pt_co_impl_statuses_id   => p_pt_co_impl_statuses_id,
                          p_record_version_number    => p_record_version_number,
                          p_fin_plan_type_id         => null,
                          p_ci_type_id               => null,
                          p_version_type             => null,
                          p_status_code              => null,
                          x_return_status            => l_return_status,
                          x_msg_count                => l_msg_count,
                          x_msg_data                 => l_msg_data);

                 IF l_return_status <>  FND_API.G_RET_STS_SUCCESS THEN
                       IF l_debug_mode = 'Y' THEN
                            pa_debug.g_err_stage:= 'Error in Lock_Row';
                            pa_debug.write(l_module_name,pa_debug.g_err_stage,l_debug_level3);
                       END IF;
                       RAISE PA_FP_CONSTANTS_PKG.Invalid_Arg_Exc;
                 END IF;
            END IF;

            IF l_debug_mode = 'Y' THEN
                 pa_debug.g_err_stage:= 'Updating with p_pt_co_impl_statuses_id';
                 pa_debug.write(l_module_name,pa_debug.g_err_stage,
                                        l_debug_level3);
            END IF;

            UPDATE PA_PT_CO_IMPL_STATUSES
            SET
            pt_co_impl_statuses_id  = DECODE (p_pt_co_impl_statuses_id, FND_API.G_MISS_NUM,
                                              NULL, NVL(p_pt_co_impl_statuses_id, pt_co_impl_statuses_id)),
            fin_plan_type_id        = DECODE (p_fin_plan_type_id, FND_API.G_MISS_NUM, NULL,
                                                                  NVL(p_fin_plan_type_id, fin_plan_type_id)),
            ci_type_id              = DECODE (p_ci_type_id, FND_API.G_MISS_NUM, NULL,
                                                                  NVL(p_ci_type_id, ci_type_id)),
            version_type            = DECODE (p_version_type, FND_API.G_MISS_CHAR, NULL,
                                                                  NVL(p_version_type, version_type)),
            status_code             = DECODE (p_status_code, FND_API.G_MISS_NUM, NULL,
                                                                  NVL(p_status_code, status_code)),
            impl_default_flag       = DECODE (p_impl_default_flag, FND_API.G_MISS_CHAR, NULL,
                                                                  NVL(p_impl_default_flag, impl_default_flag)),
            record_version_number   = p_record_version_number + 1,
            last_update_date        = SYSDATE,
            last_updated_by         = FND_GLOBAL.USER_ID,
            last_update_login       = FND_GLOBAL.LOGIN_ID
            WHERE pt_co_impl_statuses_id = p_pt_co_impl_statuses_id;

     ELSE
            IF p_lock_row = 'Y' THEN
                 /* Calling Lock_Row */
                 IF l_debug_mode = 'Y' THEN
                       pa_debug.g_err_stage:= 'Calling Lock_Row when p_pt_co_impl_statuses_id is null';
                       pa_debug.write(l_module_name,pa_debug.g_err_stage,
                                             l_debug_level3);
                 END IF;

                 Lock_Row(p_row_id                   => null,
                          p_pt_co_impl_statuses_id   => null,
                          p_record_version_number    => p_record_version_number,
                          p_fin_plan_type_id         => p_fin_plan_type_id,
                          p_ci_type_id               => p_ci_type_id,
                          p_version_type             => p_version_type,
                          p_status_code              => p_status_code,
                          x_return_status            => l_return_status,
                          x_msg_count                => l_msg_count,
                          x_msg_data                 => l_msg_data);

                  IF l_return_status <>  FND_API.G_RET_STS_SUCCESS THEN
                       IF l_debug_mode = 'Y' THEN
                            pa_debug.g_err_stage:= 'Error in Lock_Row';
                            pa_debug.write(l_module_name,pa_debug.g_err_stage,l_debug_level3);
                       END IF;
                       RAISE PA_FP_CONSTANTS_PKG.Invalid_Arg_Exc;
                  END IF;
            END IF;

            IF l_debug_mode = 'Y' THEN
                  pa_debug.g_err_stage:= 'Updating without p_pt_co_impl_statuses_id';
                  pa_debug.write(l_module_name,pa_debug.g_err_stage,
                                        l_debug_level3);
            END IF;

            UPDATE PA_PT_CO_IMPL_STATUSES
            SET
            pt_co_impl_statuses_id  = DECODE (p_pt_co_impl_statuses_id, FND_API.G_MISS_NUM,
                                              NULL, NVL(p_pt_co_impl_statuses_id, pt_co_impl_statuses_id)),
            fin_plan_type_id        = DECODE (p_fin_plan_type_id, FND_API.G_MISS_NUM, NULL,
                                                                  NVL(p_fin_plan_type_id, fin_plan_type_id)),
            ci_type_id              = DECODE (p_ci_type_id, FND_API.G_MISS_NUM, NULL,
                                                                  NVL(p_ci_type_id, ci_type_id)),
            version_type            = DECODE (p_version_type, FND_API.G_MISS_CHAR, NULL,
                                                                  NVL(p_version_type, version_type)),
            status_code             = DECODE (p_status_code, FND_API.G_MISS_CHAR, NULL,
                                                                  NVL(p_status_code, status_code)),
            impl_default_flag       = DECODE (p_impl_default_flag, FND_API.G_MISS_CHAR, NULL,
                                                                  NVL(p_impl_default_flag, impl_default_flag)),
            record_version_number   = nvl(p_record_version_number,record_version_number) + 1,
            last_update_login       = FND_GLOBAL.LOGIN_ID,
            last_updated_by         = FND_GLOBAL.USER_ID,
            last_update_date        = SYSDATE
            WHERE  fin_plan_type_id = p_fin_plan_type_id
            AND    ci_type_id       = p_ci_type_id
            AND    version_type     = DECODE(p_version_type,
                                           PA_FP_CONSTANTS_PKG.G_ELEMENT_TYPE_BOTH, version_type,
                                           Nvl(p_version_type,version_type))
            AND    status_code      = Nvl (p_status_code, status_code);

     END IF;

     IF SQL%NOTFOUND THEN
           PA_UTILS.Add_Message ( p_app_short_name => 'PA'
                                 ,p_msg_name       => 'PA_XC_RECORD_CHANGED');
           x_return_status := FND_API.G_RET_STS_ERROR;
     END IF;

     IF l_debug_mode = 'Y' THEN
            pa_debug.reset_curr_function;
     END IF;

     l_msg_count := FND_MSG_PUB.count_msg;

     IF l_msg_count > 0 THEN
            IF l_msg_count = 1 THEN
                   PA_INTERFACE_UTILS_PUB.get_messages
                      (p_encoded        => FND_API.G_TRUE,
                       p_msg_index      => 1,
                       p_msg_count      => l_msg_count,
                       p_msg_data       => l_msg_data,
                       p_data           => l_data,
                       p_msg_index_out  => l_msg_index_out);
                       x_msg_data       := l_data;
                       x_msg_count      := l_msg_count;
            ELSE
                   x_msg_count := l_msg_count;
            END IF;
            RETURN;
     END IF;

     IF l_debug_mode = 'Y' THEN
            pa_debug.g_err_stage:= 'Leaving UPDATE_ROW ';
            pa_debug.write(l_module_name,pa_debug.g_err_stage,
                                  l_debug_level3);
     END IF;

EXCEPTION
     WHEN PA_FP_CONSTANTS_PKG.Invalid_Arg_Exc THEN
            x_return_status := FND_API.G_RET_STS_ERROR;

            IF l_debug_mode = 'Y' THEN
                  pa_debug.reset_curr_function;
            END IF;

            FND_MSG_PUB.add_exc_msg( p_pkg_name        => 'PA_PT_CO_IMPL_STATUSES_PKG' ,
                                     p_procedure_name  => 'Update_Row');

     WHEN OTHERS THEN
            x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
            x_msg_count     := 1;
            x_msg_data      := SQLERRM;
            FND_MSG_PUB.add_exc_msg( p_pkg_name         => 'PA_PT_CO_IMPL_STATUSES_PKG',
                                     p_procedure_name   => 'Update_Row');
            RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

END UPDATE_ROW;

/*==================================================================
   API for deleting records of the table
 ==================================================================*/
PROCEDURE DELETE_ROW (
      p_pt_co_impl_statuses_id           IN       pa_pt_co_impl_statuses.pt_co_impl_statuses_id%TYPE,
      p_fin_plan_type_id                 IN       pa_pt_co_impl_statuses.fin_plan_type_id%TYPE,
      p_ci_type_id                       IN       pa_pt_co_impl_statuses.ci_type_id%TYPE,
      p_version_type                     IN       pa_pt_co_impl_statuses.version_type%TYPE,
      p_status_code                      IN       pa_pt_co_impl_statuses.status_code%TYPE,
      p_record_version_number            IN       pa_pt_co_impl_statuses.record_version_number%TYPE,
      p_lock_row                         IN       VARCHAR2,
      x_return_status                    OUT      NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
      x_msg_count                        OUT      NOCOPY NUMBER, --File.Sql.39 bug 4440895
      x_msg_data                         OUT      NOCOPY VARCHAR2) --File.Sql.39 bug 4440895
IS
      l_debug_mode                       VARCHAR2(1);
      l_debug_level3                     CONSTANT NUMBER := 3;
      l_module_name                      VARCHAR2(100) := 'UPDATE_ROW' || g_module_name;
      l_return_status                    VARCHAR2(30);
      l_msg_count                        NUMBER;
      l_msg_index_out                    NUMBER;
      l_data                             VARCHAR2(2000);
      l_msg_data                         VARCHAR2(2000);
BEGIN

      x_return_status := FND_API.G_RET_STS_SUCCESS;

      IF p_pt_co_impl_statuses_id IS NOT NULL THEN
            IF p_lock_row = 'Y' THEN
                  /* Calling Lock_Row */
                  IF l_debug_mode = 'Y' THEN
                       pa_debug.g_err_stage:= 'Calling Lock_Row when p_pt_co_impl_statuses_id is not null';
                       pa_debug.write(l_module_name,pa_debug.g_err_stage,
                                            l_debug_level3);
                  END IF;

                  Lock_Row(p_row_id                   => null,
                           p_pt_co_impl_statuses_id   => p_pt_co_impl_statuses_id,
                           p_record_version_number    => p_record_version_number,
                           p_fin_plan_type_id         => null,
                           p_ci_type_id               => null,
                           p_version_type             => null,
                           p_status_code              => null,
                           x_return_status            => l_return_status,
                           x_msg_count                => l_msg_count,
                           x_msg_data                 => l_msg_data);

                  IF l_return_status <>  FND_API.G_RET_STS_SUCCESS THEN
                        IF l_debug_mode = 'Y' THEN
                             pa_debug.g_err_stage:= 'Error in Lock_Row';
                             pa_debug.write(l_module_name,pa_debug.g_err_stage,l_debug_level3);
                        END IF;
                        RAISE PA_FP_CONSTANTS_PKG.Invalid_Arg_Exc;
                  END IF;
            END IF;

            IF l_debug_mode = 'Y' THEN
                  pa_debug.g_err_stage:= 'Calling Delte_Row ';
                  pa_debug.write(l_module_name,pa_debug.g_err_stage,
                                        l_debug_level3);
            END IF;

            DELETE
            FROM     pa_pt_co_impl_statuses
            WHERE    pt_co_impl_statuses_id = p_pt_co_impl_statuses_id;

            IF l_debug_mode = 'Y' THEN
                  pa_debug.g_err_stage:= 'Row Deleted';
                  pa_debug.write(l_module_name,pa_debug.g_err_stage,
                                        l_debug_level3);
            END IF;

      ELSE
            IF p_lock_row = 'Y' THEN
                  /* Calling Lock_Row */
                  IF l_debug_mode = 'Y' THEN
                        pa_debug.g_err_stage:= 'Calling Lock_Row when p_pt_co_impl_statuses_id is null';
                        pa_debug.write(l_module_name,pa_debug.g_err_stage,
                                               l_debug_level3);
                  END IF;

                  Lock_Row(p_row_id                   => null,
                           p_pt_co_impl_statuses_id   => null,
                           p_record_version_number    => p_record_version_number,
                           p_fin_plan_type_id         => p_fin_plan_type_id,
                           p_ci_type_id               => p_ci_type_id,
                           p_version_type             => p_version_type,
                           p_status_code              => p_status_code,
                           x_return_status            => l_return_status,
                           x_msg_count                => l_msg_count,
                           x_msg_data                 => l_msg_data);

                  IF l_return_status <>  FND_API.G_RET_STS_SUCCESS THEN
                        IF l_debug_mode = 'Y' THEN
                              pa_debug.g_err_stage:= 'Error in Lock_Row';
                              pa_debug.write(l_module_name,pa_debug.g_err_stage,l_debug_level3);
                        END IF;
                        RAISE PA_FP_CONSTANTS_PKG.Invalid_Arg_Exc;
                  END IF;
            END IF;

            IF l_debug_mode = 'Y' THEN
                  pa_debug.g_err_stage:= 'Calling Delte_Row ';
                  pa_debug.write(l_module_name,pa_debug.g_err_stage,
                                        l_debug_level3);
            END IF;

            DELETE
            FROM     pa_pt_co_impl_statuses
            WHERE    fin_plan_type_id = p_fin_plan_type_id
            AND      ci_type_id = p_ci_type_id
            AND      version_type = DECODE(p_version_type,
                                           PA_FP_CONSTANTS_PKG.G_ELEMENT_TYPE_BOTH, version_type,
                                           Nvl(p_version_type,version_type))
            AND      status_code = Nvl (p_status_code, status_code);

            IF l_debug_mode = 'Y' THEN
                  pa_debug.g_err_stage:= 'Row Deleted';
                  pa_debug.write(l_module_name,pa_debug.g_err_stage,
                                        l_debug_level3);
            END IF;
      END IF;

      IF (SQL%NOTFOUND) THEN
            PA_UTILS.Add_Message ( p_app_short_name => 'PA',
                                   p_msg_name       => 'PA_XC_RECORD_CHANGED');
            x_return_status := FND_API.G_RET_STS_ERROR;
      END IF;

EXCEPTION
      WHEN OTHERS THEN
            x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
            x_msg_count     := 1;
            x_msg_data      := SQLERRM;
            FND_MSG_PUB.add_exc_msg( p_pkg_name         => 'PA_PT_CO_IMPL_STATUSES_PKG',
                                     p_procedure_name   => 'DELETE_ROW');
            RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

END DELETE_ROW;

/*==================================================================
   API for locking records of the table
 ==================================================================*/
PROCEDURE LOCK_ROW (
      p_row_id                          IN       ROWID,
      p_pt_co_impl_statuses_id          IN       pa_pt_co_impl_statuses.pt_co_impl_statuses_id%TYPE,
      p_record_version_number           IN       pa_pt_co_impl_statuses.record_version_number%TYPE,
      p_fin_plan_type_id                IN       pa_pt_co_impl_statuses.fin_plan_type_id%TYPE,
      p_ci_type_id                      IN       pa_pt_co_impl_statuses.ci_type_id%TYPE,
      p_version_type                    IN       pa_pt_co_impl_statuses.version_type%TYPE,
      p_status_code                     IN       pa_pt_co_impl_statuses.status_code%TYPE,
      x_return_status                   OUT      NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
      x_msg_count                       OUT      NOCOPY NUMBER, --File.Sql.39 bug 4440895
      x_msg_data                        OUT      NOCOPY VARCHAR2) --File.Sql.39 bug 4440895

IS
      l_row_id                          ROWID;

      l_debug_mode                       VARCHAR2(1);
      l_debug_level3                     CONSTANT NUMBER := 3;
      l_module_name                      VARCHAR2(100) := 'UPDATE_ROW' || g_module_name;

      CURSOR lock_rows_crs
      IS
      SELECT  ROWID
      FROM    pa_pt_co_impl_statuses
      WHERE   fin_plan_type_id = p_fin_plan_type_id
      AND     ci_type_id = p_ci_type_id
      AND     version_type = DECODE(p_version_type,
                                    PA_FP_CONSTANTS_PKG.G_ELEMENT_TYPE_BOTH, version_type,
                                    Nvl(p_version_type,version_type))
      AND     status_code = Nvl (p_status_code, status_code)
      FOR     UPDATE NOWAIT;

      l_row_id_rec                      lock_rows_crs%ROWTYPE;

BEGIN
      x_return_status := FND_API.G_RET_STS_SUCCESS;

      IF p_pt_co_impl_statuses_id IS NOT NULL THEN
            IF l_debug_mode = 'Y' THEN
                  pa_debug.g_err_stage:= 'Lockin Row when p_pt_co_impl_statuses_id is not null';
                  pa_debug.write(l_module_name,pa_debug.g_err_stage,
                                        l_debug_level3);
            END IF;

            SELECT  ROWID
            INTO    l_row_id
            FROM    pa_pt_co_impl_statuses
            WHERE   pt_co_impl_statuses_id = p_pt_co_impl_statuses_id
            AND     record_version_number  = Nvl(p_record_version_number, record_version_number)
            FOR     UPDATE NOWAIT;

            IF l_debug_mode = 'Y' THEN
                  pa_debug.g_err_stage:= 'Row Locked when p_pt_co_impl_statuses_id is not null';
                  pa_debug.write(l_module_name,pa_debug.g_err_stage,
                                        l_debug_level3);
            END IF;
      ELSE
            IF l_debug_mode = 'Y' THEN
                  pa_debug.g_err_stage:= 'Locking Row when p_pt_co_impl_statuses_id is null';
                  pa_debug.write(l_module_name,pa_debug.g_err_stage,
                                        l_debug_level3);
            END IF;

            OPEN lock_rows_crs;

            LOOP
                  FETCH lock_rows_crs INTO l_row_id_rec;
                  EXIT WHEN lock_rows_crs%NOTFOUND;
            END LOOP;

            CLOSE lock_rows_crs;

      END IF;

EXCEPTION
      WHEN OTHERS THEN
             x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
             x_msg_count     := 1;
             x_msg_data      := SQLERRM;
             FND_MSG_PUB.add_exc_msg( p_pkg_name         => 'PA_PT_CO_IMPL_STATUSES_PKG',
                                      p_procedure_name   => 'LOCK_ROW');
             RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

END Lock_Row;

END PA_PT_CO_IMPL_STATUSES_PKG;

/
