--------------------------------------------------------
--  DDL for Package Body AMS_ACCESS_DENORM_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."AMS_ACCESS_DENORM_PVT" AS
 /* $Header: amsvdenb.pls 115.13 2004/06/16 10:49:19 vmodur ship $ */
 g_pkg_name   CONSTANT VARCHAR2(30):='AMS_access_denorm_PVT';
AMS_DEBUG_HIGH_ON boolean := FND_MSG_PUB.CHECK_MSG_LEVEL(FND_MSG_PUB.G_MSG_LVL_DEBUG_HIGH);
AMS_DEBUG_LOW_ON boolean := FND_MSG_PUB.CHECK_MSG_LEVEL(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW);
AMS_DEBUG_MEDIUM_ON boolean := FND_MSG_PUB.CHECK_MSG_LEVEL(FND_MSG_PUB.G_MSG_LVL_DEBUG_MEDIUM);

/* sunkumar: 02-10-03 overloaded insert resource to error_message also */

PROCEDURE insert_resource( p_resource_id    IN  NUMBER
                          , p_object_type    IN  VARCHAR2
                          , p_object_id      IN  NUMBER
                          , p_edit_metrics   IN  VARCHAR2
                          , x_return_status  OUT NOCOPY VARCHAR2
			  , x_msg_count      OUT NOCOPY NUMBER
                          , x_msg_data       OUT NOCOPY VARCHAR2
                          )
IS

l_api_name    CONSTANT VARCHAR2(30) := 'insert_resource';

BEGIN

  insert_resource( p_resource_id    =>  p_resource_id
                   , p_object_type    =>  p_object_type
                   , p_object_id      =>  p_object_id
                   , p_edit_metrics   =>  p_edit_metrics
		   );

  x_return_status := FND_API.G_RET_STS_SUCCESS;

EXCEPTION
    WHEN OTHERS THEN
          x_return_status := FND_API.g_ret_sts_unexp_error ;
          IF FND_MSG_PUB.check_msg_level (FND_MSG_PUB.g_msg_lvl_unexp_error)
          THEN
             FND_MSG_PUB.add_exc_msg (g_pkg_name, l_api_name);
          END IF;
          FND_MSG_PUB.count_and_get (
            p_encoded => FND_API.g_false,
            p_count   => x_msg_count,
            p_data    => x_msg_data
          );

END;



PROCEDURE insert_resource( p_resource_id    IN  NUMBER
                          , p_object_type    IN  VARCHAR2
                          , p_object_id      IN  NUMBER
                          , p_edit_metrics   IN  VARCHAR2
                          , x_return_status  OUT NOCOPY VARCHAR2
                          )
IS
BEGIN

  insert_resource( p_resource_id    =>  p_resource_id
                   , p_object_type    =>  p_object_type
                   , p_object_id      =>  p_object_id
                   , p_edit_metrics   =>  p_edit_metrics
                   );

  x_return_status := FND_API.G_RET_STS_SUCCESS;

EXCEPTION
  WHEN OTHERS THEN
    x_return_status := FND_API.G_RET_STS_ERROR;
END;



/* sunkumar: 02-10-03 overloaded update resource to add error_message also */
PROCEDURE update_resource( p_resource_id    IN  NUMBER
                          , p_object_type    IN  VARCHAR2
                          , p_object_id      IN  NUMBER
                          , p_edit_metrics   IN  VARCHAR2
                          , x_return_status  OUT NOCOPY VARCHAR2
			  , x_msg_count      OUT NOCOPY NUMBER
                          , x_msg_data       OUT NOCOPY VARCHAR2
                          )
IS

l_api_name    CONSTANT VARCHAR2(30) := 'update_resource';

BEGIN

    update_resource( p_resource_id    =>  p_resource_id
                   , p_object_type    =>  p_object_type
                   , p_object_id      =>  p_object_id
                   , p_edit_metrics   =>  p_edit_metrics
		   );

  x_return_status := FND_API.G_RET_STS_SUCCESS;

EXCEPTION
    WHEN OTHERS THEN
          x_return_status := FND_API.g_ret_sts_unexp_error ;
          IF FND_MSG_PUB.check_msg_level (FND_MSG_PUB.g_msg_lvl_unexp_error)
          THEN
             FND_MSG_PUB.add_exc_msg (g_pkg_name, l_api_name);
          END IF;
          FND_MSG_PUB.count_and_get (
            p_encoded => FND_API.g_false,
            p_count   => x_msg_count,
            p_data    => x_msg_data
          );

END;


PROCEDURE update_resource( p_resource_id    IN  NUMBER
                          , p_object_type    IN  VARCHAR2
                          , p_object_id      IN  NUMBER
                          , p_edit_metrics   IN  VARCHAR2
                          , x_return_status  OUT NOCOPY VARCHAR2
                          )
IS
BEGIN

  update_resource( p_resource_id    =>  p_resource_id
                  , p_object_type    =>  p_object_type
                  , p_object_id      =>  p_object_id
                  , p_edit_metrics   =>  p_edit_metrics
                  );

  x_return_status := FND_API.G_RET_STS_SUCCESS;

EXCEPTION
  WHEN OTHERS THEN
    x_return_status := FND_API.G_RET_STS_ERROR;
END;


/* sunkumar: 02-10-03 overloaded delete resource to add error_message also */
PROCEDURE  delete_resource( p_resource_id    IN  NUMBER
                          , p_object_type    IN  VARCHAR2
                          , p_object_id      IN  NUMBER
                          , p_edit_metrics   IN  VARCHAR2
                          , x_return_status  OUT NOCOPY VARCHAR2
			  , x_msg_count      OUT NOCOPY NUMBER
                          , x_msg_data       OUT NOCOPY VARCHAR2
                          )
IS

l_api_name    CONSTANT VARCHAR2(30) := 'delete_resource';

BEGIN

    delete_resource( p_resource_id    =>  p_resource_id
                   , p_object_type    =>  p_object_type
                   , p_object_id      =>  p_object_id
                   , p_edit_metrics   =>  p_edit_metrics
		   );

  x_return_status := FND_API.G_RET_STS_SUCCESS;

EXCEPTION
    WHEN OTHERS THEN
          x_return_status := FND_API.g_ret_sts_unexp_error ;
          IF FND_MSG_PUB.check_msg_level (FND_MSG_PUB.g_msg_lvl_unexp_error)
          THEN
             FND_MSG_PUB.add_exc_msg (g_pkg_name, l_api_name);
          END IF;
          FND_MSG_PUB.count_and_get (
            p_encoded => FND_API.g_false,
            p_count   => x_msg_count,
            p_data    => x_msg_data
          );

END;


PROCEDURE delete_resource( p_resource_id    IN  NUMBER
                          , p_object_type    IN  VARCHAR2
                          , p_object_id      IN  NUMBER
                          , p_edit_metrics   IN  VARCHAR2
                          , x_return_status  OUT NOCOPY VARCHAR2
                          )
IS
BEGIN

  delete_resource( p_resource_id    =>  p_resource_id
                   , p_object_type    =>  p_object_type
                   , p_object_id      =>  p_object_id
                   , p_edit_metrics   =>  p_edit_metrics
                   );

  x_return_status := FND_API.G_RET_STS_SUCCESS;
EXCEPTION
  WHEN OTHERS THEN
    x_return_status := FND_API.G_RET_STS_ERROR;
END;

PROCEDURE insert_resource( p_resource_id     IN  NUMBER
                         , p_object_type     IN  VARCHAR2
                         , p_object_id       IN  NUMBER
                         , p_edit_metrics    IN  VARCHAR2
                         )
IS
  l_user_id NUMBER := fnd_global.user_id;
  l_login_id NUMBER := fnd_global.conc_login_id;
  l_sysdate DATE := SYSDATE;
BEGIN

  INSERT INTO ams_act_access_denorm
         (  access_denorm_id
          , resource_id
          , edit_metrics_yn
          , object_type
          , object_id
          , source_code
          , creation_date
          , created_by
          , last_update_date
          , last_updated_by
          , last_update_login
          )
    SELECT  ams_act_access_denorm_s.nextval
          , p_resource_id
          , p_edit_metrics
          , p_object_type
          , p_object_id
          , ams_access_pvt.get_source_code(p_object_type,p_object_id)
          , l_sysdate
          , l_user_id
          , l_sysdate
          , l_user_id
          , l_login_id
    FROM dual
    WHERE NOT EXISTS (  SELECT 1
                        FROM ams_act_access_denorm
                        WHERE resource_id = p_resource_id
                          AND object_type = p_object_type
                          AND object_id   = p_object_id
                      );

  IF SQL%NOTFOUND THEN
    IF p_edit_metrics = 'Y' THEN
      UPDATE ams_act_access_denorm
        SET edit_metrics_yn = p_edit_metrics,
          last_updated_by = l_user_id,
          last_update_date = l_sysdate,
          last_update_login = l_login_id
      WHERE object_type = p_object_type
        AND object_id   = p_object_id
        AND resource_id = p_resource_id
        AND edit_metrics_yn = 'N' ;
    END IF;
  END IF;
END insert_resource;


PROCEDURE update_resource( p_resource_id     IN  NUMBER
                         , p_object_type     IN  VARCHAR2
                         , p_object_id       IN  NUMBER
                         , p_edit_metrics    IN  VARCHAR2
                         )
IS
  l_user_id NUMBER := fnd_global.user_id;
  l_login_id NUMBER := fnd_global.conc_login_id;
  l_sysdate DATE := SYSDATE;

  CURSOR what_is_edit_metrics(  c_resource_id IN NUMBER
                              , c_object_type IN VARCHAR2
                              , c_object_id IN NUMBER
                            )
  IS
    SELECT edit_metrics_yn
    FROM ams_act_access_denorm
    WHERE object_type = p_object_type
      AND object_id   = p_object_id
      AND resource_id = p_resource_id;

l_edit_metrics VARCHAR2(1);

BEGIN

IF p_edit_metrics = 'Y' THEN

 UPDATE ams_act_access_denorm
    SET edit_metrics_yn = p_edit_metrics
      , last_updated_by = l_user_id
      , last_update_date = l_sysdate
      , last_update_login = l_login_id
  WHERE object_type = p_object_type
    AND object_id   = p_object_id
    AND resource_id = p_resource_id
    AND edit_metrics_yn = 'N';

ELSIF p_edit_metrics = 'N' THEN

  OPEN what_is_edit_metrics( p_resource_id
                           , p_object_type
                           , p_object_id);
  FETCH what_is_edit_metrics INTO l_edit_metrics;
  CLOSE what_is_edit_metrics;

 IF l_edit_metrics <> 'N' THEN

 UPDATE ams_act_access_denorm aacd
    SET edit_metrics_yn = p_edit_metrics
    , last_updated_by = l_user_id
    , last_update_date = l_sysdate
    , last_update_login = l_login_id
  WHERE object_type = p_object_type
    AND object_id   = p_object_id
    AND resource_id = p_resource_id
    AND edit_metrics_yn = 'Y'
    AND not exists ( SELECT 1
                     FROM ams_act_access aac,
                          jtf_rs_groups_denorm jgd,
                          jtf_rs_group_members jgm
                     WHERE aac.arc_act_access_to_object = p_object_type
                       AND aac.act_access_to_object_id   = p_object_id
                       AND arc_user_or_role_type = 'GROUP'
                       AND user_or_role_id = jgd.parent_group_id
                       AND jgd.group_id  = jgm.group_id
                       AND jgd.start_date_active <= TRUNC(SYSDATE)
                       AND NVL(jgd.end_date_active,TRUNC(SYSDATE)) >= TRUNC(SYSDATE)
                       AND jgm.delete_flag='N'
                       AND jgm.resource_id = aacd.resource_id
                       AND aac.delete_flag = 'N'
                       AND aac.admin_flag='Y' );
  END IF;

 END IF;

END;

PROCEDURE delete_resource( p_resource_id     IN  NUMBER
                          , p_object_type     IN  VARCHAR2
                          , p_object_id       IN  NUMBER
                          , p_edit_metrics    IN  VARCHAR2
                          )
  IS
  l_user_id NUMBER := fnd_global.user_id;
  l_login_id NUMBER := fnd_global.conc_login_id;
  l_sysdate DATE := SYSDATE;

BEGIN

  DELETE FROM  AMS_ACT_ACCESS_DENORM aacd
  WHERE resource_id = p_resource_id
    AND object_type = p_object_type
    AND object_id   = p_object_id
    AND not exists (   SELECT 1
                     FROM ams_act_access aac,
                          jtf_rs_groups_denorm jgd,
                          jtf_rs_group_members jgm            -- INtroduce soft DELETE flag FOR resources.
                     WHERE aac.arc_act_access_to_object = p_object_type
                       AND aac.act_access_to_object_id   = p_object_id
                       AND arc_user_or_role_type = 'GROUP'
                       AND user_or_role_id = jgd.parent_group_id
                       AND jgd.group_id  = jgm.group_id
                       AND jgd.start_date_active <= TRUNC(SYSDATE)
                       AND NVL(jgd.end_date_active,TRUNC(SYSDATE)) >= TRUNC(SYSDATE)
                       AND jgm.resource_id = p_resource_id
                       AND jgm.delete_flag = 'N'
                       AND aac.delete_flag = 'N'
                    UNION ALL
                       SELECT 1
                         FROM ams_act_access
                        WHERE arc_act_access_to_object = p_object_type
                          AND act_access_to_object_id = p_object_id
                          AND arc_user_or_role_type = 'USER'
                          AND user_or_role_id   =  aacd.resource_id
                    );


  IF p_edit_metrics = 'Y' THEN
    UPDATE ams_act_access_denorm  aacd
       SET edit_metrics_yn = 'N'
        , last_updated_by = l_user_id
        , last_update_date = l_sysdate
        , last_update_login = l_login_id
     WHERE object_type = p_object_type
       AND object_id   = p_object_id
       AND resource_id = p_resource_id
       AND resource_id not IN (SELECT jgm.resource_id
                                FROM ams_act_access aac,
                                     jtf_rs_groups_denorm jgd,
                                     jtf_rs_group_members jgm
                               WHERE aac.arc_act_access_to_object = p_object_type
                                 AND aac.act_access_to_object_id   = p_object_id
                                 AND arc_user_or_role_type = 'GROUP'
                                 AND user_or_role_id = jgd.parent_group_id
                                 AND jgd.group_id  = jgm.group_id
                                 AND jgd.start_date_active <= TRUNC(SYSDATE)
                                 AND NVL(jgd.end_date_active,TRUNC(SYSDATE)) >= TRUNC(SYSDATE)
                                 AND jgm.delete_flag='N'
                                 AND jgm.resource_id = aacd.resource_id
                                 AND aac.delete_flag = 'N')
       AND edit_metrics_yn = 'Y' ;

   END IF;

 END;

PROCEDURE insert_group(  p_group_id      IN  NUMBER
                       , p_object_type   IN  VARCHAR2
                       , p_object_id     IN  NUMBER
                       , p_edit_metrics  IN  VARCHAR2
                       )
IS
  l_user_id NUMBER := fnd_global.user_id;
  l_login_id NUMBER := fnd_global.conc_login_id;
  l_sysdate DATE := SYSDATE;
BEGIN

-- If the resource already exists as part of another group or as user AND
-- if that group or user's edit metrics is 'N', update to 'Y'.

  IF p_edit_metrics = 'Y' THEN
    UPDATE ams_act_access_denorm aacd
    SET edit_metrics_yn = p_edit_metrics
      , last_updated_by = l_user_id
      , last_update_date = l_sysdate
      , last_update_login = l_login_id
    WHERE object_type = p_object_type
      AND object_id   = p_object_id
      AND resource_id IN  ( SELECT jgm.resource_id
                              FROM jtf_rs_groups_denorm jgd,
                                   jtf_rs_group_members jgm
                             WHERE jgd.parent_group_id = p_group_id
                               AND jgd.group_id = jgm.group_id
                               AND jgd.start_date_active <= TRUNC(SYSDATE)
                               AND NVL(jgd.end_date_active,TRUNC(SYSDATE)) >= TRUNC(SYSDATE)
                               AND jgm.delete_flag='N'
                          )
      AND edit_metrics_yn = 'N' ;
  END IF;

  -- insert if a resource in a group doesnot exist in the denorm
  INSERT INTO ams_act_access_denorm
         (  access_denorm_id
          , resource_id
          , edit_metrics_yn
          , object_type
          , object_id
          , source_code
          , creation_date
          , created_by
          , last_update_date
          , last_updated_by
          , last_update_login
          )
    SELECT ams_act_access_denorm_s.nextval
       , resource_id
       , p_edit_metrics
       , p_object_type
       , p_object_id
       , ams_access_pvt.get_source_code(p_object_type,p_object_id)
       , l_sysdate
       , l_user_id
       , l_sysdate
       , l_user_id
       , l_login_id
    FROM (
      SELECT DISTINCT resource_id
      FROM jtf_rs_groups_denorm jgd,
        jtf_rs_group_members jgm
      WHERE jgd.parent_group_id = p_group_id
        AND jgd.group_id = jgm.group_id
        AND jgd.start_date_active <= TRUNC(SYSDATE)
        AND NVL(jgd.end_date_active,TRUNC(SYSDATE)) >= TRUNC(SYSDATE)
        AND jgm.delete_flag='N'
        AND NOT EXISTS (  SELECT 1
                          FROM ams_act_access_denorm
                          WHERE resource_id = jgm.resource_id
                            AND object_type = p_object_type
                            AND object_id   = p_object_id)
                        );
end insert_group;


PROCEDURE update_group(  p_group_id       IN  NUMBER
                       , p_object_type   IN  VARCHAR2
                       , p_object_id     IN  NUMBER
                       , p_edit_metrics  IN  VARCHAR2
                       )
  IS
  l_user_id NUMBER := fnd_global.user_id;
  l_login_id NUMBER := fnd_global.conc_login_id;
  l_sysdate DATE := SYSDATE;

BEGIN

  IF p_edit_metrics = 'Y' THEN
    UPDATE ams_act_access_denorm aacd
    SET edit_metrics_yn = p_edit_metrics
      , last_updated_by = l_user_id
      , last_update_date = l_sysdate
      , last_update_login = l_login_id
    WHERE object_type = p_object_type
      AND object_id   = p_object_id
      AND edit_metrics_yn = 'N'
      AND EXISTS (  SELECT 1
                    FROM ams_act_access aac,
                      jtf_rs_groups_denorm jgd,
                      jtf_rs_group_members jgm
                    WHERE aac.arc_act_access_to_object = p_object_type
                      AND aac.act_access_to_object_id   = p_object_id
                      AND arc_user_or_role_type = 'GROUP'
                      AND user_or_role_id = p_group_id
                      AND user_or_role_id = jgd.parent_group_id
                      AND jgd.group_id  = jgm.group_id
                      AND jgd.start_date_active <= TRUNC(SYSDATE)
                      AND NVL(jgd.end_date_active,TRUNC(SYSDATE)) >= TRUNC(SYSDATE)
                      AND jgm.delete_flag='N'
                      AND jgm.resource_id = aacd.resource_id
                      AND aac.delete_flag = 'N'  );

  ELSIF p_edit_metrics = 'N' THEN
  -- individual owners allready in denorm,
  -- update entries if the resource is part of the group heirarchy
  --   AND the resource is not part of a group which has edit metrics as 'Y'
  -- added by VMODUR 13-MAR-2003
  -- The Owner may be part of the above groups and should not be updated
    UPDATE ams_act_access_denorm aacd
    SET edit_metrics_yn = p_edit_metrics
      , last_updated_by = l_user_id
      , last_update_date = l_sysdate
      , last_update_login = l_login_id
    WHERE object_type = p_object_type
      AND object_id   = p_object_id
      AND edit_metrics_yn = 'Y'
      /* Roliing back perf suggested change
      AND EXISTS (  SELECT 1
                    FROM ams_act_access aac,
                      jtf_rs_groups_denorm jgd,
                      jtf_rs_group_members jgm
                    WHERE aac.arc_act_access_to_object = p_object_type
                      AND aac.act_access_to_object_id   = p_object_id
                      AND arc_user_or_role_type = 'GROUP'
                      AND user_or_role_id = jgd.parent_group_id
                      AND jgd.group_id  = jgm.group_id
                      AND jgd.start_date_active <= TRUNC(SYSDATE)
                      AND NVL(jgd.end_date_active,TRUNC(SYSDATE)) >= TRUNC(SYSDATE)
                      AND jgm.delete_flag='N'
                      AND jgm.resource_id = aacd.resource_id
                      AND aac.delete_flag = 'N'
		      AND NVL(aac.admin_flag,'N')='N'          --anchaudh 21-MAR-03
                  )
*/
         AND EXISTS (  SELECT 1
                    FROM ams_act_access aac,
                      jtf_rs_groups_denorm jgd,
                      jtf_rs_group_members jgm
                    WHERE aac.arc_act_access_to_object = p_object_type
                      AND aac.act_access_to_object_id   = p_object_id
                      AND arc_user_or_role_type = 'GROUP'
                      AND user_or_role_id = jgd.parent_group_id
                      AND jgd.group_id  = jgm.group_id
                      AND jgd.start_date_active <= TRUNC(SYSDATE)
                      AND NVL(jgd.end_date_active,TRUNC(SYSDATE)) >= TRUNC(SYSDATE)
                      AND jgm.delete_flag='N'
                      AND jgm.resource_id = aacd.resource_id
                      AND aac.delete_flag = 'N'
                  )
      AND NOT EXISTS (  SELECT 1
                        FROM ams_act_access aac,
                          jtf_rs_groups_denorm jgd,
                          jtf_rs_group_members jgm
                        WHERE aac.arc_act_access_to_object = p_object_type
                          AND aac.act_access_to_object_id   = p_object_id
                          AND arc_user_or_role_type = 'GROUP'
                          AND user_or_role_id = jgd.parent_group_id
                          AND jgd.group_id  = jgm.group_id
                          AND jgd.start_date_active <= TRUNC(SYSDATE)
                          AND NVL(jgd.end_date_active,TRUNC(SYSDATE)) >= TRUNC(SYSDATE)
                          AND jgm.delete_flag='N'
                          AND jgm.resource_id = aacd.resource_id
                          AND aac.delete_flag = 'N'
                          AND aac.admin_flag='Y'
                      )
      AND NOT EXISTS (   SELECT 1
                         FROM ams_act_access aac
                        WHERE aac.act_access_to_object_id  = p_object_id
			  AND aac.arc_act_access_to_object = p_object_type
                          AND aac.user_or_role_id = aacd.resource_id
                          AND aac.arc_user_or_role_type = 'USER'
                          AND aac.delete_flag = 'N'
                          AND aac.admin_flag = 'Y'
                      );
  END IF;
END update_group;

PROCEDURE delete_group( p_group_id      IN  NUMBER
                      , p_object_type   IN  VARCHAR2
                      , p_object_id     IN  NUMBER
                      , p_edit_metrics  IN  VARCHAR2
                      )
  IS
  l_user_id NUMBER := fnd_global.user_id;
  l_login_id NUMBER := fnd_global.conc_login_id;
  l_sysdate DATE := SYSDATE;
 -- First DELETE groups
BEGIN
  -- Delete if resource belongs to the group that is being deleted
  -- AND it does not exist as part of any other group
  -- or exist as 'USER' FOR the object.
  DELETE FROM  ams_act_access_denorm aacd
  WHERE object_type = p_object_type
    AND object_id = p_object_id
    AND resource_id IN (  SELECT jgm.resource_id
                          FROM jtf_rs_groups_denorm jgd,
                            jtf_rs_group_members jgm
                          WHERE jgd.parent_group_id = p_group_id
                          AND jgd.group_id = jgm.group_id
                          AND jgd.start_date_active <= TRUNC(SYSDATE)
                          -- delete every group even if it was end dated earlier than SYSDATE - SVEERAVE 05/15/02
                          -- AND NVL(jgd.end_date_active,TRUNC(SYSDATE)) >= TRUNC(SYSDATE)
                          AND jgm.delete_flag='N' )
    AND NOT EXISTS ( SELECT 1
                     FROM ams_act_access aac,
                          jtf_rs_groups_denorm jgd,
                          jtf_rs_group_members jgm
                     WHERE aac.arc_act_access_to_object = p_object_type
                       AND aac.act_access_to_object_id   = p_object_id
                       AND arc_user_or_role_type = 'GROUP'
                       AND aac.delete_flag = 'N'
                       AND user_or_role_id = jgd.parent_group_id
                       AND jgd.group_id  = jgm.group_id
                       AND jgd.start_date_active <= TRUNC(SYSDATE)
                       AND NVL(jgd.end_date_active,TRUNC(SYSDATE)) >= TRUNC(SYSDATE)
                       AND jgm.delete_flag = 'N'
                       AND jgm.resource_id = aacd.resource_id
                     UNION ALL
                        SELECT 1
                        FROM ams_act_access
                        WHERE arc_act_access_to_object = p_object_type
                          AND act_access_to_object_id = p_object_id
                          AND arc_user_or_role_type = 'USER'
                          AND user_or_role_id   =  aacd.resource_id ) ;

-- If a group that is being deleted has edit metrics 'N',
-- we do not need to handle because it won't change any thing,
-- but if it is 'Y' that is being deleted
-- then we have to evaluate if resource belongs to another group but with edit_metrics_yn

  IF p_edit_metrics = 'Y' THEN

    UPDATE ams_act_access_denorm aacd
    SET edit_metrics_yn = 'N'
      , last_updated_by = l_user_id
      , last_update_date = l_sysdate
      , last_update_login = l_login_id
    WHERE object_type = p_object_type
      AND object_id   = p_object_id
      AND resource_id NOT IN (  SELECT jgm.resource_id
                                FROM ams_act_access aac,
                                  jtf_rs_groups_denorm jgd,
                                  jtf_rs_group_members jgm
                                WHERE aac.arc_act_access_to_object = p_object_type
                                  AND aac.act_access_to_object_id   = p_object_id
                                  AND arc_user_or_role_type = 'GROUP'
                                  AND user_or_role_id = jgd.parent_group_id
                                  AND jgd.group_id  = jgm.group_id
                                  AND jgd.start_date_active <= TRUNC(SYSDATE)
                                  AND NVL(jgd.end_date_active,TRUNC(SYSDATE)) >= TRUNC(SYSDATE)
                                  AND jgm.delete_flag='N'
                                  AND jgm.resource_id = aacd.resource_id
                                  AND aac.admin_flag = 'Y'
                                  AND aac.delete_flag = 'N'
                                UNION ALL
                                  SELECT user_or_role_id
                                  FROM ams_act_access
                                  WHERE arc_act_access_to_object = p_object_type
                                    AND act_access_to_object_id = p_object_id
                                    AND arc_user_or_role_type = 'USER'
                                    AND user_or_role_id   =  aacd.resource_id
                                    AND admin_flag = 'Y'
                              )
      AND edit_metrics_yn = 'Y';

 END IF;

end delete_group;


PROCEDURE refresh_group(  p_group_id      IN  NUMBER
                        , p_object_type   IN  VARCHAR2
                        , p_object_id     IN  NUMBER
                        , p_edit_metrics  IN  VARCHAR2
                      )
  IS
BEGIN
  -- add new resources which are not present in the denorm table.
  insert_group(  p_group_id     => p_group_id
               , p_object_type  => p_object_type
               , p_object_id    => p_object_id
               , p_edit_metrics => p_edit_metrics
              );
  -- update the edit metrics in the denorm table.
  update_group(  p_group_id     => p_group_id
               , p_object_type  => p_object_type
               , p_object_id    => p_object_id
               , p_edit_metrics => p_edit_metrics
              );
  -- delete the resources in the denorm table which are end-dated,
  -- or no longer present in the group.
  -- this deleted resource should not be part of any other active group or the user of
  -- the object.
  DELETE FROM  ams_act_access_denorm aacd
  WHERE aacd.object_type = p_object_type
    AND aacd.object_id = p_object_id
    AND NOT EXISTS (  SELECT 1                                               --anchaudh 21-MAR-03
                              FROM jtf_rs_groups_denorm jgd,
                                jtf_rs_group_members jgm
                              WHERE jgd.parent_group_id = p_group_id
                                AND jgd.group_id = jgm.group_id
                                AND jgd.start_date_active <= TRUNC(SYSDATE)
                                AND NVL(jgd.end_date_active,SYSDATE) >= TRUNC(SYSDATE)
                                AND jgm.delete_flag='N'
			        AND jgm.resource_id = aacd.resource_id)              --anchaudh 21-MAR-03
    AND NOT EXISTS ( SELECT 1
                     FROM ams_act_access aac,
                          jtf_rs_groups_denorm jgd,
                          jtf_rs_group_members jgm
                     WHERE aac.arc_act_access_to_object = p_object_type
                       AND aac.act_access_to_object_id   = p_object_id
                       AND arc_user_or_role_type = 'GROUP'
                       AND aac.delete_flag = 'N'
                       AND user_or_role_id = jgd.parent_group_id
                       AND jgd.group_id  = jgm.group_id
                       AND jgd.start_date_active <= TRUNC(SYSDATE)
                       AND NVL(jgd.end_date_active,TRUNC(SYSDATE)) >= TRUNC(SYSDATE)
                       AND jgm.delete_flag = 'N'
                       AND jgm.resource_id = aacd.resource_id)
     AND NOT EXISTS (                                                                           --anchaudh 21-MAR-03
                        SELECT 1
                        FROM ams_act_access
                        WHERE arc_act_access_to_object = p_object_type
                          AND act_access_to_object_id = p_object_id
                          AND arc_user_or_role_type = 'USER'
                          AND user_or_role_id   =  aacd.resource_id ) ;
END refresh_group;

PROCEDURE ams_object_denorm ( errbuf       OUT NOCOPY VARCHAR2
                            , retcode      OUT NOCOPY VARCHAR2
                            , p_object_id   IN NUMBER
                            , p_object_type IN VARCHAR2 )
 IS
  CURSOR cur_get_object_changes IS
  SELECT arc_user_or_role_type
        ,user_or_role_id
        ,act_access_to_object_id
        ,arc_act_access_to_object
        ,admin_flag
    FROM ams_act_access
   WHERE act_access_to_object_id = p_object_id
     AND arc_act_access_to_object = p_object_type
     AND arc_user_or_role_type = 'GROUP'
     AND delete_flag = 'N';

 l_user_id NUMBER  := fnd_global.user_id;
 l_login_id NUMBER := fnd_global.conc_login_id;
 l_sysdate DATE    := SYSDATE;

BEGIN

  DELETE FROM ams_act_access_denorm aacd
  WHERE aacd.object_type = p_object_type
    AND aacd.object_id   = p_object_id;

 INSERT INTO ams_act_access_denorm
         (
            access_denorm_id
          , resource_id
          , edit_metrics_yn
          , object_type
          , object_id
          , source_code
          , creation_date
          , created_by
          , last_update_date
          , last_updated_by
          , last_update_login
          )
 SELECT ams_act_access_denorm_s.nextval
        ,user_or_role_id
        ,admin_flag
        ,arc_act_access_to_object
        ,act_access_to_object_id
        ,ams_access_pvt.get_source_code(arc_act_access_to_object,act_access_to_object_id)
        ,l_sysdate
        ,l_user_id
        ,l_sysdate
        ,l_user_id
        ,l_login_id
 FROM  ams_act_access
 WHERE arc_act_access_to_object = p_object_type
   AND act_access_to_object_id = p_object_id
   AND arc_user_or_role_type = 'USER';

  FOR object_rec IN cur_get_object_changes LOOP

   insert_group( object_rec.user_or_role_id
                ,object_rec.arc_act_access_to_object
                ,object_rec.act_access_to_object_id
                ,object_rec.admin_flag
              );

  END LOOP;

  DELETE FROM ams_act_access
  WHERE arc_user_or_role_type = 'GROUP'
    AND arc_act_access_to_object = p_object_type
    AND act_access_to_object_id = p_object_id
    AND delete_flag = 'Y' ;

  RETCODE := 0;
EXCEPTION
WHEN OTHERS THEN
  RETCODE := 2;
  ERRBUF := SQLERRM;
END;

/*
  Modified to include an additional parameter to run in full mode.
  This concurrent program picks the groups associated with the object, and
  populates the resources in that group in the ams_act_access_denorm table.
  By default, it will pick only the groups which are modified after the most recent
  previous run date of conc. program.
  However, user can choose to run it in full mode, in which it will refresh every group
  from the object.
*/
PROCEDURE ams_access_denorm ( errbuf  OUT NOCOPY VARCHAR2
                            , retcode OUT NOCOPY VARCHAR2
                            , p_full_mode IN  VARCHAR2 := Fnd_Api.G_FALSE
                            )
IS
  l_user_id NUMBER  := fnd_global.user_id;
  l_login_id NUMBER := fnd_global.conc_login_id;
  l_sysdate DATE    := SYSDATE;
  l_last_run_date      DATE;
  l_program_application_id NUMBER := 530;
  l_concurrent_program_id  NUMBER;

  -- Get just the delta records for incremental mode
  CURSOR cur_get_access_changes (p_last_run_date DATE) IS
    SELECT user_or_role_id
       ,act_access_to_object_id
       ,arc_act_access_to_object
       ,admin_flag
       ,delete_flag
       ,creation_date
       ,last_update_date
    FROM ams_act_access
    WHERE arc_user_or_role_type = 'GROUP'
      AND last_update_date >= p_last_run_date;

  -- Get all the records needed for full mode.
  CURSOR cur_get_all_access IS
    SELECT user_or_role_id
       ,act_access_to_object_id
       ,arc_act_access_to_object
       ,admin_flag
       ,delete_flag
       ,creation_date
       ,last_update_date
    FROM ams_act_access
    WHERE arc_user_or_role_type = 'GROUP';

  CURSOR cur_get_conc_program_id IS
    SELECT concurrent_program_id
    FROM fnd_concurrent_programs
    WHERE application_id = 530
    AND concurrent_program_name = 'AMSADENO';

  CURSOR cur_get_latest_start_date IS
    SELECT max(actual_start_date)
    FROM fnd_concurrent_requests
    WHERE program_application_id = l_program_application_id
      AND concurrent_program_id =  l_concurrent_program_id
      AND status_code = 'C'
      AND phase_code = 'C';

  -- Used only once i.e the first time ever this concurrent program is run
  -- Commenting this as we cannot rely on this statement as last_update_date
  -- could be even changed while a new object is created.
  /*
  CURSOR cur_get_latest_run_date IS
    SELECT max(last_update_date)
      FROM ams_act_access_denorm;
  */
BEGIN

  OPEN cur_get_conc_program_id;
  FETCH cur_get_conc_program_id INTO l_concurrent_program_id;
  CLOSE cur_get_conc_program_id;
  -- Get the most recent conc. request, and use that to drive the delta.
  OPEN cur_get_latest_start_date ;
  FETCH cur_get_latest_start_date  INTO l_last_run_date;
  CLOSE cur_get_latest_start_date ;

  IF (l_last_run_date IS NULL) OR p_full_mode IN (Fnd_Api.G_TRUE, 'Y') THEN
    FOR l_all_access_rec IN cur_get_all_access LOOP
      IF (l_all_access_rec.delete_flag = 'Y')  THEN
        delete_group(  p_group_id     => l_all_access_rec.user_or_role_id
                     , p_object_type  => l_all_access_rec.arc_act_access_to_object
                     , p_object_id    => l_all_access_rec.act_access_to_object_id
                     , p_edit_metrics => l_all_access_rec.admin_flag
                     );
      ELSIF (l_all_access_rec.delete_flag = 'N') THEN
        refresh_group( p_group_id     => l_all_access_rec.user_or_role_id
                     , p_object_type  => l_all_access_rec.arc_act_access_to_object
                     , p_object_id    => l_all_access_rec.act_access_to_object_id
                     , p_edit_metrics => l_all_access_rec.admin_flag
                     );
      END IF;
    END LOOP;
  ELSE
    --l_last_run_date := SYSDATE  - 1000000;
    FOR access_rec IN cur_get_access_changes(l_last_run_date) LOOP
      IF ((access_rec.creation_date > l_last_run_date) AND (access_rec.delete_flag = 'N') ) THEN
        insert_group(  p_group_id     => access_rec.user_or_role_id
                     , p_object_type  => access_rec.arc_act_access_to_object
                     , p_object_id    => access_rec.act_access_to_object_id
                     , p_edit_metrics => access_rec.admin_flag
                     );
      ELSIF ( (access_rec.last_update_date > l_last_run_date) AND (access_rec.delete_flag = 'Y') ) THEN
        delete_group(  p_group_id     => access_rec.user_or_role_id
                     , p_object_type  => access_rec.arc_act_access_to_object
                     , p_object_id    => access_rec.act_access_to_object_id
                     , p_edit_metrics => access_rec.admin_flag
                     );

      ELSIF ( (access_rec.last_update_date > l_last_run_date) AND (access_rec.delete_flag = 'N') ) THEN
       --dbms_output.put_line('-- Only change that could have happened is that edit metrics could have changed.');
        update_group(  p_group_id     => access_rec.user_or_role_id
                     , p_object_type  => access_rec.arc_act_access_to_object
                     , p_object_id    => access_rec.act_access_to_object_id
                     , p_edit_metrics => access_rec.admin_flag
                    );
      END IF;
    END LOOP; -- for     FOR access_rec IN cur_get_access_changes(l_last_run_date) LOOP
  END IF; --  IF p_full_mode IN (Fnd_Api.G_TRUE, 'Y') THEN

  -- delete all the deleted group associations.
  DELETE ams_act_access
  WHERE arc_user_or_role_type = 'GROUP'
    AND delete_flag = 'Y' ;

  -- return the success code.
  retcode := 0;
EXCEPTION
WHEN OTHERS THEN
  ROLLBACK;
  RETCODE := 2;
  ERRBUF := SQLERRM;
END ams_access_denorm;
/*

PROCEDURE jtf_access_denorm ( errbuf OUT NOCOPY VARCHAR2
                            , retcode OUT NOCOPY VARCHAR2)
IS

 l_user_id NUMBER := fnd_global.user_id;
 l_login_id NUMBER := fnd_global.conc_login_id;
 l_sysdate DATE := sysdate;
 l_program_application_id NUMBER := 530;
 l_concurrent_program_id  NUMBER;

-- CURSOR to operate on groups that are DELETEd
CURSOR cur_get_object_grp_res( p_last_run_date DATE)  IS
  SELECT  act.act_access_to_object_id
        , act.arc_act_access_to_object
        , jrg.group_id
        , admin_flag
    FROM  ams_act_access act,
          JTF_RS_GROUPS_B jrg
   WHERE act.arc_user_or_role_type = 'GROUP'
     AND act.user_or_role_id= jrg.group_id
     AND  jrg.last_update_date >= p_last_run_date
     AND  jrg.end_date_active <= trunc(sysdate)
     AND  act.delete_flag = 'N';

-- CURSOR to operate on group relations that are created or DELETEd
CURSOR cur_get_obj_grp_relation_res( p_last_run_date DATE) IS
  SELECT jrg.group_id
         , jrg.start_date_active
         , act.act_access_to_object_id
         , act.arc_act_access_to_object
         , jrg.creation_date
         , jrg.last_update_date
         , jrg.end_date_active
        , act.admin_flag
    FROM ams_act_access act,
         jtf_rs_grp_relations jrg
   WHERE act.arc_user_or_role_type = 'GROUP'
     AND act.user_or_role_id= jrg.group_id
     AND jrg.last_update_date >= p_last_run_date
     AND act.delete_flag = 'N';

-- CURSOR to operate on group members that are created or DELETEd
CURSOR cur_get_object_res_groups( p_last_run_date DATE) IS
SELECT  aac.act_access_to_object_id
      , aac.arc_act_access_to_object
      , jgm.resource_id
      , jgm.delete_flag
      , jgm.creation_date
      , jgm.last_update_date
      ,aac.admin_flag
 FROM ams_act_access aac,
       jtf_rs_groups_denorm jrg,
       jtf_rs_group_members jgm
WHERE aac.arc_user_or_role_type =  'GROUP'
  AND aac.user_or_role_id= jrg.parent_group_id
  AND jrg.group_id = jgm.group_id
  AND jrg.start_date_active <= trunc(sysdate)
  AND nvl(jrg.end_date_active,trunc(sysdate)) >= trunc(sysdate)
  AND jgm.last_update_date >= p_last_run_date
  AND aac.delete_flag='N';

CURSOR cur_get_conc_program_id IS
SELECT concurrent_program_id
  FROM fnd_concurrent_programs
 WHERE application_id = 530
 AND concurrent_program_name = 'AMSJDENO';

CURSOR cur_get_latest_start_date IS
SELECT MAX(actual_start_date)
  FROM fnd_concurrent_requests
 WHERE program_application_id = l_program_application_id
   AND concurrent_program_id =  l_concurrent_program_id
   AND status_code = 'C'
   AND phase_code = 'C';

-- Used only once i.e the first time ever this concurrent program is run
CURSOR cur_get_latest_run_date IS
SELECT MAX(last_update_date)
  FROM ams_act_access_denorm;

l_last_run_date date;

BEGIN

OPEN cur_get_conc_program_id;
FETCH cur_get_conc_program_id INTO l_concurrent_program_id;
CLOSE cur_get_conc_program_id;

OPEN cur_get_latest_start_date;
FETCH cur_get_latest_start_date INTO l_last_run_date;
CLOSE cur_get_latest_start_date;

IF l_last_run_date is null THEN
OPEN cur_get_latest_run_date;
FETCH cur_get_latest_run_date INTO l_last_run_date;
CLOSE cur_get_latest_run_date;
END IF;
-- l_last_run_date := sysdate  - 1000000;
FOR grp_res_rec IN cur_get_object_grp_res(l_last_run_date) LOOP
    --dbms_output.put_line(' groups  ');

    delete_group( p_group_id      =>  grp_res_rec.group_id
                , p_object_type   => grp_res_rec.arc_act_access_to_object
                , p_object_id     => grp_res_rec.act_access_to_object_id
                , p_edit_metrics  => grp_res_rec.admin_flag
                );

END LOOP;

FOR grprel_res_rec IN cur_get_obj_grp_relation_res(l_last_run_date) LOOP
           --dbms_output.put_line(' group relations ');

 IF (     (grprel_res_rec.creation_date >= l_last_run_date )
      AND (nvl(grprel_res_rec.start_date_active,sysdate) <= sysdate)
      AND ( nvl(grprel_res_rec.end_date_active,sysdate) >= sysdate)
    )
 THEN
       --dbms_output.put_line(' insert group relations ');

   insert_group( p_group_id     => grprel_res_rec.group_id
               , p_object_type  => grprel_res_rec.arc_act_access_to_object
               , p_object_id    => grprel_res_rec.act_access_to_object_id
               , p_edit_metrics => grprel_res_rec.admin_flag
               );

 ELSIF ( nvl(grprel_res_rec.end_date_active,sysdate) <= sysdate ) THEN
       --dbms_output.put_line(' DELETE group relations ');

   delete_group( p_group_id     => grprel_res_rec.group_id
               , p_object_type  => grprel_res_rec.arc_act_access_to_object
               , p_object_id    => grprel_res_rec.act_access_to_object_id
               , p_edit_metrics => grprel_res_rec.admin_flag
               );

 END IF;


END LOOP;

FOR grpmembers_rec IN cur_get_object_res_groups(l_last_run_date) LOOP
          --dbms_output.put_line(' DELETE group members');
    IF ((grpmembers_rec.creation_date >= l_last_run_date )
        AND ( grpmembers_rec.delete_flag = 'N')   )
    THEN
          -- dbms_output.put_line(' insert group members');

      insert_resource( p_resource_id   =>  grpmembers_rec.resource_id
                     , p_object_type   =>  grpmembers_rec.arc_act_access_to_object
                     , p_object_id     =>  grpmembers_rec.act_access_to_object_id
                     , p_edit_metrics  =>  grpmembers_rec.admin_flag
                     );

    ELSIF ( (grpmembers_rec.delete_flag = 'Y') ) THEN
        --dbms_output.put_line(' DELETE group members');

      delete_resource( p_resource_id   =>  grpmembers_rec.resource_id
                     , p_object_type   =>  grpmembers_rec.arc_act_access_to_object
                     , p_object_id     =>  grpmembers_rec.act_access_to_object_id
                     , p_edit_metrics  =>  grpmembers_rec.admin_flag
                     );
    END IF;

END LOOP;
retcode := 0;
end;
*/

PROCEDURE jtf_access_denorm (  errbuf OUT NOCOPY VARCHAR2
                             , retcode OUT NOCOPY VARCHAR2
                            )
IS

  l_user_id NUMBER := fnd_global.user_id;
  l_login_id NUMBER := fnd_global.conc_login_id;
  l_sysdate DATE := SYSDATE;
  l_program_application_id NUMBER := 530;
  l_concurrent_program_id  NUMBER;

  -- CURSOR to operate on groups that are deleted
  CURSOR cur_get_del_grp(p_last_run_date DATE)  IS
    SELECT  act.act_access_to_object_id
          , act.arc_act_access_to_object
          , jrg.group_id
          , admin_flag
    FROM  ams_act_access act,
          jtf_rs_groups_b jrg
    WHERE act.arc_user_or_role_type = 'GROUP'
      AND act.user_or_role_id= jrg.group_id
      AND act.delete_flag = 'N'
--      AND  jrg.last_update_date >= p_last_run_date -- this will not pick any rows which are end dated in future.
      AND jrg.end_date_active IS NOT NULL
      AND jrg.end_date_active >= p_last_run_date -- added to pick only the rows which are ending after previous run.
      AND jrg.end_date_active <= TRUNC(SYSDATE) ;

  -- CURSOR to get group members that are created through new child group relationship
  -- or got created because of changing the start date of child relationship after previous run
  -- or got created manually in the main group or child group.
  -- Replaced the following cursor - Replace OR's with unions as suggested by Perf Team in
  -- Bug 3071312
  /*
  CURSOR cur_get_crt_res(p_last_run_date DATE) IS
    SELECT  aac.act_access_to_object_id
        , aac.arc_act_access_to_object
        , jgm.resource_id
        , jgm.last_update_date
        , aac.admin_flag
    FROM ams_act_access aac,
       jtf_rs_groups_denorm jrg,
       jtf_rs_group_members jgm
    WHERE
      ( aac.arc_user_or_role_type =  'GROUP'
        AND aac.user_or_role_id= jrg.parent_group_id
        AND aac.delete_flag='N'
        AND jgm.delete_flag = 'N'
        AND jrg.group_id = jgm.group_id
        AND jrg.start_date_active >= p_last_run_date
        AND jrg.start_date_active <= TRUNC(SYSDATE)
       )
      OR
      ( aac.arc_user_or_role_type =  'GROUP'
        AND aac.user_or_role_id= jrg.parent_group_id
        AND aac.delete_flag='N'
        AND jgm.delete_flag = 'N'
        AND jrg.group_id = jgm.group_id
        AND jrg.last_update_date > p_last_run_date
        AND jrg.start_date_active <= TRUNC(SYSDATE)
       )
      OR
      ( aac.arc_user_or_role_type =  'GROUP'
        AND aac.user_or_role_id= jrg.parent_group_id
        AND aac.delete_flag='N'
        AND jgm.delete_flag = 'N'
        AND jrg.group_id = jgm.group_id
        AND jgm.creation_date > p_last_run_date
      );
  */
  CURSOR cur_get_crt_res(p_last_run_date DATE) IS
    SELECT  aac.act_access_to_object_id
        , aac.arc_act_access_to_object
        , jgm.resource_id
        , jgm.last_update_date
        , aac.admin_flag
    FROM ams_act_access aac,
       jtf_rs_groups_denorm jrg,
       jtf_rs_group_members jgm
   WHERE
      ( aac.arc_user_or_role_type =  'GROUP'
        AND aac.user_or_role_id= jrg.parent_group_id
        AND aac.delete_flag='N'
        AND jgm.delete_flag = 'N'
        AND jrg.group_id = jgm.group_id
        AND jrg.start_date_active >= p_last_run_date
        AND jrg.start_date_active <= TRUNC(SYSDATE)
       )
 UNION
    SELECT  aac.act_access_to_object_id
        , aac.arc_act_access_to_object
        , jgm.resource_id
        , jgm.last_update_date
        , aac.admin_flag
    FROM ams_act_access aac,
       jtf_rs_groups_denorm jrg,
       jtf_rs_group_members jgm
   WHERE
      ( aac.arc_user_or_role_type =  'GROUP'
        AND aac.user_or_role_id= jrg.parent_group_id
        AND aac.delete_flag='N'
        AND jgm.delete_flag = 'N'
        AND jrg.group_id = jgm.group_id
        AND jrg.last_update_date > p_last_run_date
        AND jrg.start_date_active <= TRUNC(SYSDATE)
       )
  UNION
    SELECT  aac.act_access_to_object_id
        , aac.arc_act_access_to_object
        , jgm.resource_id
        , jgm.last_update_date
        , aac.admin_flag
    FROM ams_act_access aac,
       jtf_rs_groups_denorm jrg,
       jtf_rs_group_members jgm
   WHERE
      ( aac.arc_user_or_role_type =  'GROUP'
        AND aac.user_or_role_id= jrg.parent_group_id
        AND aac.delete_flag='N'
        AND jgm.delete_flag = 'N'
        AND jrg.group_id = jgm.group_id
        AND jgm.creation_date > p_last_run_date
      );

  -- CURSOR to get group members that are deleted by end-dating child group relationship
  -- or those changed end-date in the child group relationship after previous run
  -- or got deleted manually.
  -- Cursor replaced by those suggested by Perf Team as per Bug 3071312
  /*
  CURSOR cur_get_del_res(p_last_run_date DATE) IS
    SELECT  aac.act_access_to_object_id
        , aac.arc_act_access_to_object
        , jgm.resource_id
        , jgm.last_update_date
        , aac.admin_flag
    FROM ams_act_access aac,
       jtf_rs_groups_denorm jrg,
       jtf_rs_group_members jgm
    WHERE
      ( aac.arc_user_or_role_type =  'GROUP'
        AND aac.user_or_role_id= jrg.parent_group_id
        AND aac.delete_flag='N'
        AND jrg.group_id = jgm.group_id
        AND jrg.end_date_active IS NOT NULL
        AND jrg.end_date_active >= p_last_run_date
        AND jrg.end_date_active <= TRUNC(SYSDATE)
       )
      OR
      ( aac.arc_user_or_role_type =  'GROUP'
        AND aac.user_or_role_id= jrg.parent_group_id
        AND aac.delete_flag='N'
        AND jrg.group_id = jgm.group_id
        AND jrg.last_update_date > p_last_run_date
        AND jrg.end_date_active IS NOT NULL
        AND jrg.end_date_active <= TRUNC(SYSDATE)
       )
      OR
      ( aac.arc_user_or_role_type =  'GROUP'
        AND aac.user_or_role_id= jrg.parent_group_id
        AND aac.delete_flag='N'
        AND jgm.delete_flag = 'Y'
        AND jrg.group_id = jgm.group_id
        AND jgm.last_update_date >= p_last_run_date
      );
*/
  CURSOR cur_get_del_res(p_last_run_date DATE) IS
    SELECT  aac.act_access_to_object_id
        , aac.arc_act_access_to_object
        , jgm.resource_id
        , jgm.last_update_date
        , aac.admin_flag
    FROM ams_act_access aac,
       jtf_rs_groups_denorm jrg,
       jtf_rs_group_members jgm
    WHERE
      ( aac.arc_user_or_role_type =  'GROUP'
        AND aac.user_or_role_id= jrg.parent_group_id
        AND aac.delete_flag='N'
        AND jrg.group_id = jgm.group_id
        AND jrg.end_date_active IS NOT NULL
        AND jrg.end_date_active >= p_last_run_date
        AND jrg.end_date_active <= TRUNC(SYSDATE)
       )
    UNION
    SELECT  aac.act_access_to_object_id
        , aac.arc_act_access_to_object
        , jgm.resource_id
        , jgm.last_update_date
        , aac.admin_flag
    FROM ams_act_access aac,
       jtf_rs_groups_denorm jrg,
       jtf_rs_group_members jgm
    WHERE
      ( aac.arc_user_or_role_type =  'GROUP'
        AND aac.user_or_role_id= jrg.parent_group_id
        AND aac.delete_flag='N'
        AND jrg.group_id = jgm.group_id
        AND jrg.last_update_date > p_last_run_date
        AND jrg.end_date_active IS NOT NULL
        AND jrg.end_date_active <= TRUNC(SYSDATE)
       )
    UNION
    SELECT  aac.act_access_to_object_id
        , aac.arc_act_access_to_object
        , jgm.resource_id
        , jgm.last_update_date
        , aac.admin_flag
    FROM ams_act_access aac,
       jtf_rs_groups_denorm jrg,
       jtf_rs_group_members jgm
    WHERE
      ( aac.arc_user_or_role_type =  'GROUP'
        AND aac.user_or_role_id= jrg.parent_group_id
        AND aac.delete_flag='N'
        AND jgm.delete_flag = 'Y'
        AND jrg.group_id = jgm.group_id
        AND jgm.last_update_date >= p_last_run_date
      );

  CURSOR cur_get_conc_program_id IS
    SELECT concurrent_program_id
    FROM fnd_concurrent_programs
    WHERE concurrent_program_name = 'AMSJDENO';

  CURSOR cur_get_latest_start_date IS
    SELECT MAX(actual_start_date)
    FROM fnd_concurrent_requests
    WHERE program_application_id = l_program_application_id
      AND concurrent_program_id =  l_concurrent_program_id
      AND status_code = 'C'
      AND phase_code = 'C';

  -- Used only once i.e the first time ever this concurrent program is run
  -- Use the minimum last_update_date
  CURSOR cur_get_latest_run_date IS
    SELECT MIN(last_update_date)
    FROM ams_act_access_denorm;
  l_last_run_date DATE;

BEGIN

  OPEN cur_get_conc_program_id;
  FETCH cur_get_conc_program_id INTO l_concurrent_program_id;
  CLOSE cur_get_conc_program_id;

  OPEN cur_get_latest_start_date;
  FETCH cur_get_latest_start_date INTO l_last_run_date;
  CLOSE cur_get_latest_start_date;

  IF l_last_run_date IS NULL THEN
    OPEN cur_get_latest_run_date;
    FETCH cur_get_latest_run_date INTO l_last_run_date;
    CLOSE cur_get_latest_run_date;
  END IF;

  -- handle all the groups which are directly associated to the objects, and are deleted.
  FOR l_del_grp_rec IN cur_get_del_grp(l_last_run_date) LOOP
   --dbms_output.put_line(' groups  ');
    delete_group( p_group_id      => l_del_grp_rec.group_id
                , p_object_type   => l_del_grp_rec.arc_act_access_to_object
                , p_object_id     => l_del_grp_rec.act_access_to_object_id
                , p_edit_metrics  => l_del_grp_rec.admin_flag
                );
  END LOOP;

  -- create all the resources which are added manually in the main group or child group
  -- and, also create all the resources came via new child group relations.
  FOR l_crt_res_rec IN cur_get_crt_res(l_last_run_date) LOOP
    --dbms_output.put_line(' groups  ');
    insert_resource( p_resource_id   =>  l_crt_res_rec.resource_id
                   , p_object_type   =>  l_crt_res_rec.arc_act_access_to_object
                   , p_object_id     =>  l_crt_res_rec.act_access_to_object_id
                   , p_edit_metrics  =>  l_crt_res_rec.admin_flag
                   );
  END LOOP;

  -- delete all the resources which are deleted manually in the main group or child group
  -- and, also deleted because child group relationship is end-dated.
  FOR l_del_res_rec IN cur_get_del_res(l_last_run_date) LOOP
      --dbms_output.put_line(' DELETE group members');
      delete_resource( p_resource_id   =>  l_del_res_rec.resource_id
                     , p_object_type   =>  l_del_res_rec.arc_act_access_to_object
                     , p_object_id     =>  l_del_res_rec.act_access_to_object_id
                     , p_edit_metrics  =>  l_del_res_rec.admin_flag
                     );
  END LOOP;
  retcode := 0;
EXCEPTION
WHEN OTHERS THEN
  ROLLBACK;
  RETCODE := 2;
  ERRBUF := SQLERRM;
end jtf_access_denorm;
end ams_access_denorm_pvt;

/
