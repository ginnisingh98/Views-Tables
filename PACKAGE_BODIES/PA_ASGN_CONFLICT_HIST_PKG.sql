--------------------------------------------------------
--  DDL for Package Body PA_ASGN_CONFLICT_HIST_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PA_ASGN_CONFLICT_HIST_PKG" as
/* $Header: PARGASNB.pls 120.1.12010000.4 2010/03/23 10:24:34 amehrotr ship $ */

--
-- Procedure            : Insert_rows
-- Purpose              : Create Rows in PA_ASSIGNMENT_CONFLICT_HIST.
--
PROCEDURE insert_rows
      ( p_conflict_group_id                IN Number := NULL                ,
        p_assignment_id                    IN Number                        ,
        p_conflict_assignment_id           IN Number                        ,
        p_resolve_conflict_action_code     IN VARCHAR2                      ,
        p_intra_txn_conflict_flag          IN VARCHAR2                      ,
        p_processed_flag                   IN VARCHAR2 := 'N'               ,
        p_self_conflict_flag               IN VARCHAR2                      ,
        x_return_status              OUT  NOCOPY VARCHAR2                          , --File.Sql.39 bug 4440895
        x_msg_count                  OUT  NOCOPY NUMBER                            , --File.Sql.39 bug 4440895
        x_msg_data                   OUT  NOCOPY VARCHAR2 ) --File.Sql.39 bug 4440895
IS

BEGIN
  INSERT INTO pa_assignment_conflict_hist
      ( conflict_group_id ,
        assignment_id           ,
        conflict_assignment_id  ,
        resolve_conflicts_action_code  ,
        intra_txn_conflict_flag ,
        processed_flag          ,
        self_conflict_flag      ,
        creation_date           ,
        created_by              ,
        last_update_date        ,
        last_updated_by          ,
        last_update_login       )
 VALUES
	(nvl(p_conflict_group_id, pa_assignment_conflict_hist_s.nextval),
        p_assignment_id           ,
        p_conflict_assignment_id  ,
        p_resolve_conflict_action_code    ,
        p_intra_txn_conflict_flag ,
        p_processed_flag          ,
        p_self_conflict_flag      ,
        sysdate                      ,
        fnd_global.user_id           ,
        sysdate                      ,
        fnd_global.user_id           ,
        fnd_global.login_id          );

  x_return_status := FND_API.G_RET_STS_SUCCESS;
EXCEPTION
 WHEN OTHERS THEN
  x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
 FND_MSG_PUB.add_exc_msg( p_pkg_name         => 'PA_ASGN_CONFLICT_HIST_PKG',
                          p_procedure_name   => 'insert_rows');
 raise;

END insert_rows;


--
-- Procedure     : Insert_rows (Overloaded)
-- Purpose       : Create Rows in PA_ASSIGNMENT_CONFLICT_HIST for a single
--                 assigment with a table of conflicting assignments.
--
PROCEDURE insert_rows
      ( p_conflict_group_id                IN NUMBER := NULL                ,
        p_assignment_id                    IN NUMBER                        ,
        p_conflict_assignment_id_tbl       IN PA_PLSQL_DATATYPES.NumTabTyp  ,
        p_resolve_conflict_action_code     IN VARCHAR2                      ,
        p_intra_txn_conflict_flag_tbl      IN SYSTEM.PA_VARCHAR2_1_TBL_TYPE:=NULL,
        p_processed_flag                   IN VARCHAR2 := 'N'               ,
        x_conflict_group_id                OUT NOCOPY NUMBER                       , --File.Sql.39 bug 4440895
        x_return_status              OUT  NOCOPY VARCHAR2                          , --File.Sql.39 bug 4440895
        x_msg_count                  OUT  NOCOPY NUMBER                            , --File.Sql.39 bug 4440895
        x_msg_data                   OUT  NOCOPY VARCHAR2 ) --File.Sql.39 bug 4440895
IS
  l_conflict_group_id NUMBER := p_conflict_group_id;
BEGIN

  IF p_conflict_group_id IS NULL THEN
    SELECT pa_assignment_conflict_hist_s.nextval
    INTO l_conflict_group_id
    FROM dual;
  END IF;
  x_conflict_group_id := l_conflict_group_id;

  IF p_conflict_assignment_id_tbl.COUNT > 0 THEN
    IF p_intra_txn_conflict_flag_tbl IS NULL THEN
      FORALL j IN p_conflict_assignment_id_tbl.FIRST .. p_conflict_assignment_id_tbl.LAST
        INSERT INTO pa_assignment_conflict_hist
        ( conflict_group_id ,
        assignment_id           ,
        conflict_assignment_id  ,
        resolve_conflicts_action_code  ,
        intra_txn_conflict_flag ,
        processed_flag          ,
        self_conflict_flag      ,
        creation_date           ,
        created_by              ,
        last_update_date        ,
        last_updated_by          ,
        last_update_login       )
     VALUES
	   (  l_conflict_group_id       ,
        p_assignment_id           ,
        p_conflict_assignment_id_tbl(j)  ,
        p_resolve_conflict_action_code    ,
        'N' ,
        p_processed_flag          ,
        decode((p_assignment_id - p_conflict_assignment_id_tbl(j)), 0, 'Y', 'N'),
        sysdate                      ,
        fnd_global.user_id           ,
        sysdate                      ,
        fnd_global.user_id           ,
        fnd_global.login_id          );

    ELSE
      FORALL j IN p_conflict_assignment_id_tbl.FIRST .. p_conflict_assignment_id_tbl.LAST
        INSERT INTO pa_assignment_conflict_hist
        ( conflict_group_id ,
        assignment_id           ,
        conflict_assignment_id  ,
        resolve_conflicts_action_code  ,
        intra_txn_conflict_flag ,
        processed_flag          ,
        self_conflict_flag      ,
        creation_date           ,
        created_by              ,
        last_update_date        ,
        last_updated_by         ,
        last_update_login       )
     VALUES
	   (  l_conflict_group_id              ,
        p_assignment_id                  ,
        p_conflict_assignment_id_tbl(j)  ,
        p_resolve_conflict_action_code   ,
        p_intra_txn_conflict_flag_tbl(j) ,
        p_processed_flag          ,
        decode((p_assignment_id - p_conflict_assignment_id_tbl(j)), 0, 'Y', 'N'),
        sysdate                      ,
        fnd_global.user_id           ,
        sysdate                      ,
        fnd_global.user_id           ,
        fnd_global.login_id          );

    END IF;
  END IF;

   x_return_status := FND_API.G_RET_STS_SUCCESS;
EXCEPTION
 WHEN OTHERS THEN
  x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
 FND_MSG_PUB.add_exc_msg( p_pkg_name         => 'PA_ASGN_CONFLICT_HIST_PKG',
                          p_procedure_name   => 'insert_rows');
 raise;

END insert_rows;


--
-- Procedure            : update_rows (overloaded)
-- Purpose              : Update rows in pa_assignment_conflict_hist with
--                        p_resolve_conflict_action_code only. This is
--                        overloaded procedure.
--
PROCEDURE update_rows
      ( p_conflict_group_id                IN Number                        ,
        p_assignment_id                    IN Number                        ,
        p_conflict_assignment_id           IN Number                        ,
        p_resolve_conflict_action_code     IN VARCHAR2                      ,
        x_return_status              OUT  NOCOPY VARCHAR2          , --File.Sql.39 bug 4440895
        x_msg_count                  OUT  NOCOPY NUMBER            , --File.Sql.39 bug 4440895
        x_msg_data                   OUT  NOCOPY VARCHAR2 ) --File.Sql.39 bug 4440895
IS

BEGIN

  UPDATE PA_ASSIGNMENT_CONFLICT_HIST
  SET
      resolve_conflicts_action_code = p_resolve_conflict_action_code,
      last_update_date              = sysdate,
      last_updated_by               = fnd_global.user_id,
      last_update_login             = fnd_global.login_id
  WHERE conflict_group_id        = p_conflict_group_id
  AND   assignment_id            = p_assignment_id
  AND   conflict_assignment_id   = p_conflict_assignment_id;

  x_return_status := FND_API.G_RET_STS_SUCCESS;

EXCEPTION
 WHEN OTHERS THEN
  x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
 FND_MSG_PUB.add_exc_msg( p_pkg_name           => 'PA_ASGN_CONFLICT_HIST_PKG',
                           p_procedure_name     => 'update_rows');
 raise;

END update_rows;


--
-- Procedure            : update_rows (overloaded)
-- Purpose              : Update rows in pa_assignment_conflict_hist with
--                        p_resolve_conflict_action_code only for the whole
--                        conflict group. This is overloaded procedure. This
--                        is called from the Resource Overcommitment page.
PROCEDURE update_rows
      ( p_conflict_group_id                IN Number                        ,
        p_resolve_conflict_action_code     IN VARCHAR2                      ,
        x_return_status              OUT  NOCOPY VARCHAR2          , --File.Sql.39 bug 4440895
        x_msg_count                  OUT  NOCOPY NUMBER            , --File.Sql.39 bug 4440895
        x_msg_data                   OUT  NOCOPY VARCHAR2 ) --File.Sql.39 bug 4440895
IS

BEGIN

  UPDATE PA_ASSIGNMENT_CONFLICT_HIST
  SET
      resolve_conflicts_action_code = p_resolve_conflict_action_code,
      last_update_date              = sysdate,
      last_updated_by               = fnd_global.user_id,
      last_update_login             = fnd_global.login_id
  WHERE conflict_group_id        = p_conflict_group_id;

  x_return_status := FND_API.G_RET_STS_SUCCESS;

EXCEPTION
 WHEN OTHERS THEN
  x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
 FND_MSG_PUB.add_exc_msg( p_pkg_name           => 'PA_ASGN_CONFLICT_HIST_PKG',
                           p_procedure_name     => 'update_rows');
 raise;

END update_rows;


--
-- Procedure            : update_rows (overloaded)
-- Purpose              : Update rows in pa_assignment_conflict_hist with
--                        p_resolve_conflict_action_code only for the whole
--                        conflict group. This is overloaded procedure. This
--                        is called from the View Conflicts page.
PROCEDURE update_rows
      ( p_conflict_group_id                IN Number                        ,
        p_assignment_id_arr                IN SYSTEM.PA_NUM_TBL_TYPE       ,
        p_action_code_arr                  IN SYSTEM.PA_VARCHAR2_30_TBL_TYPE      ,
        x_return_status              OUT  NOCOPY VARCHAR2          , --File.Sql.39 bug 4440895
        x_msg_count                  OUT  NOCOPY NUMBER            , --File.Sql.39 bug 4440895
        x_msg_data                   OUT  NOCOPY VARCHAR2 ) --File.Sql.39 bug 4440895
IS

BEGIN

  IF p_assignment_id_arr.COUNT > 0 THEN
    FORALL j IN p_assignment_id_arr.FIRST .. p_assignment_id_arr.LAST
      UPDATE pa_assignment_conflict_hist
      SET
         resolve_conflicts_action_code = p_action_code_arr(j),
         last_update_date              = sysdate,
         last_updated_by               = fnd_global.user_id,
         last_update_login             = fnd_global.login_id
         WHERE conflict_group_id       = p_conflict_group_id
         AND assignment_id             = p_assignment_id_arr(j);

  END IF;

x_return_status := FND_API.G_RET_STS_SUCCESS;

EXCEPTION
 WHEN OTHERS THEN
  x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
 FND_MSG_PUB.add_exc_msg( p_pkg_name           => 'PA_ASGN_CONFLICT_HIST_PKG',
                           p_procedure_name     => 'update_rows');
 raise;

END update_rows;


--
-- Procedure            : update_rows (overloaded)
-- Purpose              : Update rows in pa_assignment_conflict_hist with
--                        p_processed_flag  only. This is an overloaded
--                        procedure.
--
PROCEDURE update_rows
      ( p_conflict_group_id                IN Number                        ,
        p_assignment_id                    IN Number                        ,
        p_processed_flag                   IN VARCHAR2                      ,
        x_return_status              OUT  NOCOPY VARCHAR2          , --File.Sql.39 bug 4440895
        x_msg_count                  OUT  NOCOPY NUMBER            , --File.Sql.39 bug 4440895
        x_msg_data                   OUT  NOCOPY VARCHAR2 ) --File.Sql.39 bug 4440895
IS

BEGIN

  UPDATE PA_ASSIGNMENT_CONFLICT_HIST
  SET
      processed_flag                = p_processed_flag,
      last_update_date              = sysdate,
      last_updated_by               = fnd_global.user_id,
      last_update_login             = fnd_global.login_id
  WHERE conflict_group_id        = p_conflict_group_id
  AND   assignment_id            = p_assignment_id;

  x_return_status := FND_API.G_RET_STS_SUCCESS;

EXCEPTION
 WHEN OTHERS THEN
  x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
 FND_MSG_PUB.add_exc_msg( p_pkg_name           => 'PA_ASGN_CONFLICT_HIST_PKG',
                           p_procedure_name     => 'update_rows');
 raise;

END update_rows;


--
-- Procedure            : delete_rows
-- Purpose              : Deletes rows in PA_ASSIGNMENT_CONFLICT_HIST.
--
-- Parameters           :
--
PROCEDURE delete_rows
        ( p_conflict_group_id          IN NUMBER,
          p_assignment_id              IN NUMBER,
          p_conflict_assignment_id     IN NUMBER,
          x_return_status              OUT  NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
          x_msg_count                  OUT  NOCOPY NUMBER, --File.Sql.39 bug 4440895
          x_msg_data                   OUT  NOCOPY VARCHAR2 ) --File.Sql.39 bug 4440895
IS

BEGIN

  DELETE FROM PA_ASSIGNMENT_CONFLICT_HIST
     WHERE conflict_group_id        = p_conflict_group_id
     AND   assignment_id            = p_assignment_id
     AND   conflict_assignment_id   = p_conflict_assignment_id;

  x_return_status := FND_API.G_RET_STS_SUCCESS;

EXCEPTION
 WHEN OTHERS THEN
  x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
 FND_MSG_PUB.add_exc_msg( p_pkg_name           => 'PA_ASGN_CONFLCIT_HIST_PKG',
                           p_procedure_name     => 'delete_rows');
 raise;

END delete_rows;


--
-- Procedure            : delete_conflict_rows -- bug 7118933
-- Purpose              : Deletes rows in PA_ASSIGNMENT_CONFLICT_HIST.
--
-- Parameters           :
--
PROCEDURE delete_rows
        ( p_assignment_id              IN NUMBER,
          x_return_status              OUT  NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
          x_msg_count                  OUT  NOCOPY NUMBER, --File.Sql.39 bug 4440895
          x_msg_data                   OUT  NOCOPY VARCHAR2 ) --File.Sql.39 bug 4440895
IS

BEGIN

  DELETE FROM PA_ASSIGNMENT_CONFLICT_HIST          -- Bug 9356152
     WHERE assignment_id            = p_assignment_id
     OR CONFLICT_ASSIGNMENT_ID      = p_assignment_id;

  x_return_status := FND_API.G_RET_STS_SUCCESS;

EXCEPTION
 WHEN OTHERS THEN
  x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
 FND_MSG_PUB.add_exc_msg( p_pkg_name           => 'PA_ASGN_CONFLCIT_HIST_PKG',
                           p_procedure_name     => 'delete_conflict_rows');
 raise;

END delete_rows;


END PA_ASGN_CONFLICT_HIST_PKG;

/
