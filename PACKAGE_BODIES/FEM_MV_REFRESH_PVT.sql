--------------------------------------------------------
--  DDL for Package Body FEM_MV_REFRESH_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."FEM_MV_REFRESH_PVT" AS
/* $Header: FEMVMVREFRESHB.pls 120.3 2008/02/20 06:50:58 jcliving noship $ */

  G_PKG_NAME CONSTANT VARCHAR2(30):= 'FEM_MV_Refresh_Pvt' ;

  -- Global variables.
  g_debug_msg                  VARCHAR2(2000) := NULL    ;
  g_user_id                    NUMBER         := 0       ;
  g_sys_date                   DATE           := SYSDATE ;

/*===========================================================================+
 |                             PROCEDURE pd                                  |
 +===========================================================================*/
-- API to print debug information used during development.
PROCEDURE pd( p_message IN VARCHAR2) IS
BEGIN
  NULL ;
  --DBMS_OUTPUT.Put_Line(p_message) ;
END pd ;
/*---------------------------------------------------------------------------*/


/*===========================================================================+
 |                         PROCEDURE Register_MV                             |
 +===========================================================================*/
-- API to register an MV.
PROCEDURE Register_MV
(
  p_api_version             IN         NUMBER,
  p_init_msg_list           IN         VARCHAR2 := FND_API.G_FALSE,
  p_commit                  IN         VARCHAR2 := FND_API.G_FALSE,
  x_return_status           OUT NOCOPY VARCHAR2,
  x_msg_count               OUT NOCOPY NUMBER,
  x_msg_data                OUT NOCOPY VARCHAR2,
  --
  p_mv_name                 IN         VARCHAR2,
  p_base_table_name         IN         VARCHAR2,
  p_refresh_group_sequence  IN         NUMBER   := NULL
)
IS

  l_api_name            CONSTANT     VARCHAR2(30)   := 'Register_MV';
  l_api_version         CONSTANT     NUMBER         :=  1.0;
  l_return_status                    VARCHAR2(1);
  l_msg_count                        NUMBER;
  l_msg_data                         VARCHAR2(2000);
  --
  l_object_found_flag                VARCHAR2(30);
  --
  CURSOR l_object_exists_csr
         ( c_object_name     VARCHAR2,
           c_object_type     VARCHAR2)
  IS
  SELECT 'Y'
  FROM   user_objects
  WHERE  object_name =  c_object_name
  AND    object_type =  c_object_type ;

BEGIN

  SAVEPOINT Register_MV_Pvt ;
  IF NOT FND_API.Compatible_API_Call ( l_api_version,
				       p_api_version,
				       l_api_name,
				       G_PKG_NAME )
  THEN
    RAISE FND_API.G_EXC_UNEXPECTED_ERROR ;
  END IF ;
  --
  IF FND_API.to_Boolean ( p_init_msg_list ) THEN
    FND_MSG_PUB.initialize ;
  END IF ;
  x_return_status := FND_API.G_RET_STS_SUCCESS ;

  --
  -- Validate input parameters. Note we do not validate if the base table
  -- is indeed being used by the MV or not.
  --
  l_object_found_flag := 'N' ;
  OPEN  l_object_exists_csr ( p_mv_name , 'MATERIALIZED VIEW' ) ;
  FETCH l_object_exists_csr INTO l_object_found_flag ;
  CLOSE l_object_exists_csr ;

  IF l_object_found_flag = 'N' THEN
    FND_MESSAGE.Set_Name('FND', 'FEM_MV_INVALID_MV_NAME') ;
    FND_MSG_PUB.Add;
    RAISE FND_API.G_EXC_ERROR;
  END IF ;

  l_object_found_flag := 'N' ;
  OPEN  l_object_exists_csr ( p_base_table_name , 'SYNONYM' ) ;
  FETCH l_object_exists_csr INTO l_object_found_flag ;
  CLOSE l_object_exists_csr ;

  IF l_object_found_flag = 'N' THEN
    FND_MESSAGE.Set_Name('FND', 'FEM_MV_INVALID_BASE_TABLE_NAME') ;
    FND_MSG_PUB.Add;
    RAISE FND_API.G_EXC_ERROR;
  END IF ;
  --
  -- End validating input parameters.
  --

  -- We will take an UPSERT approach to update MV repository table.
  MERGE INTO fem_mv_refresh_objects s
     USING ( SELECT p_mv_name                mv_name               ,
                    p_base_table_name        base_table_name       ,
                    p_refresh_group_sequence refresh_group_sequence
             FROM   dual ) t
     ON ( s.mv_name = t.mv_name )
     WHEN MATCHED THEN
       UPDATE SET s.refresh_group_sequence =
                  NVL(t.refresh_group_sequence, s.refresh_group_sequence),
                  s.base_table_name        = t.base_table_name           ,
                  s.last_updated_by        = g_user_id                   ,
                  s.last_update_date       = g_sys_date                  ,
                  s.last_update_login      = g_user_id
     WHEN NOT MATCHED THEN
       INSERT (   s.mv_name               ,
                  s.refresh_group_sequence,
                  s.base_table_name       ,
                  s.created_by            ,
                  s.creation_date         ,
                  s.last_updated_by       ,
                  s.last_update_date      ,
                  s.last_update_login
              )
              VALUES
              (   t.mv_name                        ,
                  NVL(t.refresh_group_sequence, 10),
                  t.base_table_name                ,
                  g_user_id                        ,
                  g_sys_date                       ,
                  g_user_id                        ,
                  g_sys_date                       ,
                  g_user_id
              ) ;

  IF FND_API.To_Boolean ( p_commit ) THEN
    COMMIT WORK ;
  END IF ;
  FND_MSG_PUB.Count_And_Get ( p_count => x_msg_count,
			      p_data  => x_msg_data ) ;
EXCEPTION

  WHEN OTHERS THEN
    --
    ROLLBACK TO Register_MV_Pvt ;
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
    --
    IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) THEN
      FND_MSG_PUB.Add_Exc_Msg ( G_PKG_NAME,
				l_api_name) ;
    END IF ;
    --
    FND_MSG_PUB.Count_And_Get ( p_count => x_msg_count,
				p_data  => x_msg_data ) ;
END Register_MV ;
/*---------------------------------------------------------------------------*/


/*===========================================================================+
 |                         PROCEDURE Unregister_MV                           |
 +===========================================================================*/
-- API to unregister an MV.
PROCEDURE Unregister_MV
(
  p_api_version             IN         NUMBER,
  p_init_msg_list           IN         VARCHAR2 := FND_API.G_FALSE,
  p_commit                  IN         VARCHAR2 := FND_API.G_FALSE,
  x_return_status           OUT NOCOPY VARCHAR2,
  x_msg_count               OUT NOCOPY NUMBER,
  x_msg_data                OUT NOCOPY VARCHAR2,
  --
  p_mv_name                 IN         VARCHAR2
)
IS

  l_api_name            CONSTANT     VARCHAR2(30)   := 'Unregister_MV';
  l_api_version         CONSTANT     NUMBER         :=  1.0;
  l_return_status                    VARCHAR2(1);
  l_msg_count                        NUMBER;
  l_msg_data                         VARCHAR2(2000);

BEGIN

  SAVEPOINT Unregister_MV_Pvt ;
  IF NOT FND_API.Compatible_API_Call ( l_api_version,
                                       p_api_version,
                                       l_api_name,
                                       G_PKG_NAME )
  THEN
    RAISE FND_API.G_EXC_UNEXPECTED_ERROR ;
  END IF ;
  --
  IF FND_API.to_Boolean ( p_init_msg_list ) THEN
    FND_MSG_PUB.initialize ;
  END IF ;
  x_return_status := FND_API.G_RET_STS_SUCCESS ;

  -- Remove the MV from the repository table.
  DELETE fem_mv_refresh_objects
  WHERE  mv_name = p_mv_name ;

  IF SQL%ROWCOUNT <= 0 THEN
    FND_MESSAGE.Set_Name('FND', 'FEM_MV_INVALID_MV_NAME') ;
    FND_MSG_PUB.Add;
    RAISE FND_API.G_EXC_ERROR;
  END IF ;

  IF FND_API.To_Boolean ( p_commit ) THEN
    COMMIT WORK ;
  END IF ;
  --
  FND_MSG_PUB.Count_And_Get ( p_count => x_msg_count,
                              p_data  => x_msg_data ) ;
EXCEPTION

  WHEN OTHERS THEN
    --
    ROLLBACK TO Unregister_MV_Pvt ;
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
    --
    IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) THEN
      FND_MSG_PUB.Add_Exc_Msg ( G_PKG_NAME,
                                l_api_name) ;
    END IF ;
    --
    FND_MSG_PUB.Count_And_Get ( p_count => x_msg_count,
                                p_data  => x_msg_data ) ;
END Unregister_MV;
/*---------------------------------------------------------------------------*/


/*===========================================================================+
 |                      PROCEDURE Refresh_MV_CP                              |
 +===========================================================================*/
-- This is the execution file for the concurrent program 'Refresh MV'.
PROCEDURE Refresh_MV_CP
(
  errbuf                    OUT NOCOPY VARCHAR2  ,
  retcode                   OUT NOCOPY VARCHAR2  ,
  --
  p_base_table_name         IN         VARCHAR2
)
IS

  l_api_name                CONSTANT   VARCHAR2(30) := 'Refresh_MV_CP';
  l_return_status                      VARCHAR2(1) ;
  l_msg_count                          NUMBER ;
  l_msg_data                           VARCHAR2(2000) ;

BEGIN

  retcode := 2 ;
  FEM_MV_Refresh_Pvt.Refresh_MV
  (
    p_api_version     => 1.0,
    p_init_msg_list   => FND_API.G_TRUE,
    p_commit          => FND_API.G_FALSE,
    x_return_status   => l_return_status,
    x_msg_count       => l_msg_count,
    x_msg_data        => l_msg_data,
    --
    p_base_table_name => p_base_table_name
  ) ;
  --
  IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
    RAISE FND_API.G_EXC_ERROR;
  END IF ;

  retcode := 0 ;
  COMMIT WORK  ;

EXCEPTION

  WHEN OTHERS THEN
    IF FND_MSG_PUB.Check_Msg_Level( FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR ) THEN
      FND_MSG_PUB.Add_Exc_Msg( G_PKG_NAME ,
                               l_api_name  ) ;
    END IF ;

    -- Print the error message stack.
    FND_MSG_PUB.Count_And_Get ( p_count => l_msg_count,
                                p_data  => l_msg_data ) ;
    FOR i IN 1..l_msg_count
    LOOP
      FND_MSG_PUB.Get( p_msg_index     => i  ,
                       p_encoded       => FND_API.G_FALSE     ,
                       p_data          => l_msg_data          ,
                       p_msg_index_out => l_msg_count
                   );
      FEM_ENGINES_PKG.User_Message ( p_msg_text => l_msg_data ) ;
    END LOOP;

END Refresh_MV_CP ;
/*---------------------------------------------------------------------------*/


/*===========================================================================+
 |                          PROCEDURE Refresh_MV                             |
 +===========================================================================*/
-- API to refresh MVs.
PROCEDURE Refresh_MV
(
  p_api_version             IN         NUMBER,
  p_init_msg_list           IN         VARCHAR2 := FND_API.G_FALSE,
  p_commit                  IN         VARCHAR2 := FND_API.G_FALSE,
  x_return_status           OUT NOCOPY VARCHAR2,
  x_msg_count               OUT NOCOPY NUMBER,
  x_msg_data                OUT NOCOPY VARCHAR2,
  --
  p_base_table_name         IN         VARCHAR2
)
IS

  l_api_name            CONSTANT     VARCHAR2(30)   := 'Refresh_MV';
  l_api_version         CONSTANT     NUMBER         :=  1.0;
  l_return_status                    VARCHAR2(1);
  l_msg_count                        NUMBER;
  l_msg_data                         VARCHAR2(2000);
  --
  l_mv_list                          VARCHAR2(2000);
  l_last_refresh_group_sequence      NUMBER;

BEGIN

  -- No savepoints applicable as refresh seems to perform an implicit commit.
  IF NOT FND_API.Compatible_API_Call ( l_api_version,
                                       p_api_version,
                                       l_api_name,
                                       G_PKG_NAME )
  THEN
    RAISE FND_API.G_EXC_UNEXPECTED_ERROR ;
  END IF ;
  --
  IF FND_API.to_Boolean ( p_init_msg_list ) THEN
    FND_MSG_PUB.initialize ;
  END IF ;
  x_return_status := FND_API.G_RET_STS_SUCCESS ;

  FND_FILE.Put_Line( FND_FILE.LOG, 'The following is the parameter list:') ;
  FND_FILE.Put_Line( FND_FILE.LOG, 'p_base_table_name: ' || p_base_table_name );

  -- Initialize the local variables.
  l_last_refresh_group_sequence := NULL ;
  l_mv_list                     := NULL ;

  --
  -- Get all MVs that meet given base table name. We will collect them into a
  -- comma separated list by refresh group sequence for refresh submission.
  --
  FOR l_mv_rec IN
  (
    SELECT mv_name, refresh_group_sequence
    FROM   fem_mv_refresh_objects
    WHERE  base_table_name = NVL(p_base_table_name, base_table_name)
    ORDER BY refresh_group_sequence
  )
  LOOP

    IF l_last_refresh_group_sequence IS NULL THEN

      l_mv_list := l_mv_rec.mv_name ;

    ELSIF l_mv_rec.refresh_group_sequence = l_last_refresh_group_sequence THEN

      l_mv_list := l_mv_list || ',' || l_mv_rec.mv_name ;

    ELSE

      --pd( 'Procesing: ' || l_mv_list ) ;
      DBMS_MVIEW.REFRESH
      ( list                 => l_mv_list,
        method               => 'C',
        rollback_seg         => '',
        push_deferred_rpc    => TRUE,
        refresh_after_errors => TRUE,
        purge_option         => 0,
        parallelism          => 0,
        heap_size            => 0,
        atomic_refresh       => FALSE
      ) ;
      l_mv_list := l_mv_rec.mv_name ;

    END IF ;

    l_last_refresh_group_sequence := l_mv_rec.refresh_group_sequence ;

  END LOOP ;
  -- End processing MVs.

  -- Refresh the very last group of MVs left out due to loop exiting.
  IF l_mv_list IS NOT NULL THEN

    --pd( 'Processing last group: ' || l_mv_list ) ;
    DBMS_MVIEW.REFRESH
    ( list                 => l_mv_list,
      method               => 'C',
      rollback_seg         => '',
      push_deferred_rpc    => TRUE,
      refresh_after_errors => TRUE,
      purge_option         => 0,
      parallelism          => 0,
      heap_size            => 0,
      atomic_refresh       => FALSE
    ) ;

  END IF ;

  IF FND_API.To_Boolean ( p_commit ) THEN
    COMMIT WORK ;
  END IF ;
  --
  FND_MSG_PUB.Count_And_Get ( p_count => x_msg_count,
                              p_data  => x_msg_data ) ;
EXCEPTION

  WHEN OTHERS THEN
    --
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
    IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) THEN
      FND_MSG_PUB.Add_Exc_Msg ( G_PKG_NAME,
                                l_api_name) ;
    END IF ;
    --
    FND_MSG_PUB.Count_And_Get ( p_count => x_msg_count,
                                p_data  => x_msg_data ) ;
END Refresh_MV;
/*---------------------------------------------------------------------------*/


END FEM_MV_Refresh_Pvt ;

/
