--------------------------------------------------------
--  DDL for Package Body HRI_EDW_DIM_EVENTS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."HRI_EDW_DIM_EVENTS" AS
/* $Header: hriedevt.pkb 120.0 2005/05/29 07:08:13 appldev noship $ */

/******************************************************************************/
FUNCTION global_exists( p_user_event_type    IN VARCHAR2 )
              RETURN NUMBER IS

  CURSOR row_exists_cur IS
  SELECT 1
  FROM hri_edw_user_events
  WHERE user_event_type = 'GLOBAL_' || p_user_event_type;

  l_temp       NUMBER;

BEGIN

  OPEN row_exists_cur;
  FETCH row_exists_cur INTO l_temp;
  IF (row_exists_cur%NOTFOUND OR row_exists_cur%NOTFOUND IS NULL) THEN
    l_temp := 0;
  END IF;
  CLOSE row_exists_cur;

  RETURN l_temp;

END global_exists;

PROCEDURE update_global_enabled_flag( p_user_event_type       IN VARCHAR2
                                    , p_value                 IN VARCHAR2 )
IS

BEGIN

  UPDATE hri_edw_user_events
  SET global_enabled_flag = p_value
  WHERE user_event_type = p_user_event_type
  OR user_event_type = 'GLOBAL_' || p_user_event_type;

END update_global_enabled_flag;

PROCEDURE set_global( p_user_event_type      IN VARCHAR2
                    , p_value                IN NUMBER )
IS

  l_global_exists         NUMBER;

BEGIN

  l_global_exists := global_exists( p_user_event_type );

  IF (l_global_exists > 0) THEN
    UPDATE hri_edw_user_events
    SET global_threshold_value = p_value
    WHERE user_event_type = 'GLOBAL_' || p_user_event_type
    OR user_event_type = p_user_event_type;
  END IF;

  RETURN;

END set_global;


PROCEDURE add_global( p_user_event_type         IN VARCHAR2
                    , p_threshold_units         IN VARCHAR2
                    , p_global_threshold_value  IN NUMBER
                    , p_global_enabled_flag     IN VARCHAR2)
IS

  l_global_exists         NUMBER;

BEGIN

  l_global_exists := global_exists( p_user_event_type );

  IF (l_global_exists = 0) THEN
    INSERT INTO hri_edw_user_events
      ( user_event_id
      , user_event_type
      , threshold_units
      , global_threshold_value
      , global_enabled_flag)
    VALUES
      ( hri_edw_user_events_s.nextval
      , 'GLOBAL_' || p_user_event_type
      , p_threshold_units
      , p_global_threshold_value
      , p_global_enabled_flag);
  END IF;

  RETURN;

END add_global;

PROCEDURE enable_global( p_user_event_type      IN VARCHAR2 )
IS

  l_global_exists         NUMBER;

BEGIN

  l_global_exists := global_exists( p_user_event_type );

  IF (l_global_exists > 0) THEN
    update_global_enabled_flag( p_user_event_type, 'Y' );
  END IF;

END enable_global;


PROCEDURE disable_global( p_user_event_type      IN VARCHAR2 )
IS

  l_global_exists         NUMBER;

BEGIN

  l_global_exists := global_exists( p_user_event_type );

  IF (l_global_exists > 0) THEN
    update_global_enabled_flag( p_user_event_type, 'N' );
  END IF;

END disable_global;


PROCEDURE add_event( p_user_event_type      IN VARCHAR2
                   , p_event_code           IN VARCHAR2
                   , p_event_threshold      IN NUMBER )
IS

  l_global_threshold_value   NUMBER;
  l_global_enabled_flag      VARCHAR2(30);
  l_threshold_units          VARCHAR2(30);

  CURSOR global_values_cur IS
  SELECT glb.global_threshold_value
  ,glb.global_enabled_flag
  ,glb.threshold_units
  FROM hri_edw_user_events glb
  WHERE glb.user_event_type = 'GLOBAL_' || p_user_event_type
  AND NOT EXISTS (SELECT 1
                  FROM hri_edw_user_events evt
                  WHERE evt.user_event_type = p_user_event_type
                  AND evt.event_code = p_event_code);


BEGIN

  OPEN global_values_cur;
  FETCH global_values_cur INTO l_global_threshold_value,
  l_global_enabled_flag, l_threshold_units;
  IF (global_values_cur%NOTFOUND OR global_values_cur%NOTFOUND IS NULL) THEN
    CLOSE global_values_cur;
  ELSE
    INSERT INTO hri_edw_user_events
      ( user_event_id
      , user_event_type
      , event_code
      , threshold_value
      , threshold_units
      , global_threshold_value
      , global_enabled_flag)
    VALUES
      ( hri_edw_user_events_s.nextval
      , p_user_event_type
      , p_event_code
      , p_event_threshold
      , l_threshold_units
      , l_global_threshold_value
      , l_global_enabled_flag);
  END IF;

  RETURN;

END add_event;

PROCEDURE drop_event( p_user_event_type      IN VARCHAR2
                    , p_event_code           IN VARCHAR2)
IS

BEGIN

  DELETE FROM hri_edw_user_events
  WHERE user_event_type = p_user_event_type
  AND event_code = p_event_code;

  RETURN;

END drop_event;

PROCEDURE load_hrhy_row( p_event_id         IN NUMBER,
                         p_owner            IN VARCHAR2,
                         p_hierarchy        IN VARCHAR2,
                         p_level_number     IN NUMBER,
                         p_event_code       IN VARCHAR2,
                         p_parent_event_id  IN NUMBER,
                         p_reason_type      IN VARCHAR2,
                         p_user_event_type  IN VARCHAR2 )
IS

  l_event_code            VARCHAR2(30);
  l_parent_event_id       NUMBER;
  l_reason_type           VARCHAR2(30);
  l_user_event_type       VARCHAR2(30);

  CURSOR row_exists_cur IS
  SELECT
   event_code
  ,parent_event_id
  ,reason_type
  ,user_event_type
  FROM hri_edw_event_hrchys
  WHERE hierarchy = p_hierarchy
  AND level_number = p_level_number
  AND event_id = p_event_id;

BEGIN

  OPEN row_exists_cur;
  FETCH row_exists_cur INTO   l_event_code,
                              l_parent_event_id,
                              l_reason_type,
                              l_user_event_type;
  IF (row_exists_cur%NOTFOUND OR row_exists_cur%NOTFOUND IS NULL) THEN
    CLOSE row_exists_cur;
    INSERT INTO  hri_edw_event_hrchys
      ( event_id
      , hierarchy
      , level_number
      , event_code
      , parent_event_id
      , reason_type
      , user_event_type )
      values
        ( p_event_id
        , p_hierarchy
        , p_level_number
        , p_event_code
        , p_parent_event_id
        , p_reason_type
        , p_user_event_type );
  ELSE
    CLOSE row_exists_cur;
    UPDATE hri_edw_event_hrchys
    SET event_code      = p_event_code
      , parent_event_id = p_parent_event_id
      , reason_type     = p_reason_type
      , user_event_type = p_user_event_type
    WHERE hierarchy = p_hierarchy
    AND level_number = p_level_number
    AND event_id = p_event_id;
  END IF;

END load_hrhy_row;

PROCEDURE load_user_row( p_user_event_type  IN VARCHAR2,
                         p_event_code       IN VARCHAR2,
                         p_owner            IN VARCHAR2,
                         p_threshold_value  IN NUMBER,
                         p_threshold_units  IN VARCHAR2,
                         p_glbl_thr_value   IN NUMBER,
                         p_global_flag      IN VARCHAR2 )
IS

  l_user_event_type       VARCHAR2(30);
  l_event_code            VARCHAR2(30);
  l_threshold_value       NUMBER;
  l_threshold_units       VARCHAR2(30);
  l_glbl_thr_value        NUMBER;
  l_global_flag           VARCHAR2(30);

  CURSOR row_exists_cur IS
  SELECT
   user_event_type
  ,event_code
  ,threshold_value
  ,threshold_units
  ,global_threshold_value
  ,global_enabled_flag
  FROM hri_edw_user_events
  WHERE user_event_type = p_user_event_type
  AND (event_code = p_event_code OR event_code IS NULL);

BEGIN

  OPEN row_exists_cur;
  FETCH row_exists_cur INTO   l_user_event_type,
                              l_event_code,
                              l_threshold_value,
                              l_threshold_units,
                              l_glbl_thr_value,
                              l_global_flag;
  IF (row_exists_cur%NOTFOUND OR row_exists_cur%NOTFOUND IS NULL) THEN
    CLOSE row_exists_cur;
    INSERT INTO  hri_edw_user_events
      ( user_event_id
      , user_event_type
      , event_code
      , threshold_value
      , threshold_units
      , global_threshold_value
      , global_enabled_flag )
      values
        (  hri_edw_user_events_s.nextval
        ,  p_user_event_type
        ,  p_event_code
        ,  p_threshold_value
        ,  p_threshold_units
        ,  p_glbl_thr_value
        ,  p_global_flag );
  ELSE
    CLOSE row_exists_cur;
    UPDATE hri_edw_user_events
    SET threshold_value        = p_threshold_value
      , threshold_units        = p_threshold_units
      , global_threshold_value = p_glbl_thr_value
      , global_enabled_flag    = p_global_flag
    WHERE  user_event_type = p_user_event_type
    AND (event_code = p_event_code OR event_code IS NULL);
  END IF;

END load_user_row;

PROCEDURE load_cmbn_row( p_combination_id   IN NUMBER,
                         p_owner            IN VARCHAR2,
                         p_gain_event_id    IN NUMBER,
                         p_loss_event_id    IN NUMBER,
                         p_rec_event_id     IN NUMBER,
                         p_sep_event_id     IN NUMBER,
                         p_reason_type      IN VARCHAR2,
                         p_facts            IN VARCHAR2,
                         p_description      IN VARCHAR2 )
IS

  l_combination_id        NUMBER;
  l_gain_event_id         NUMBER;
  l_loss_event_id         NUMBER;
  l_rec_event_id          NUMBER;
  l_sep_event_id          NUMBER;
  l_reason_type           VARCHAR2(30);
  l_facts                 VARCHAR2(30);
  l_description           VARCHAR2(80);

  CURSOR row_exists_cur IS
  SELECT
   combination_id
  ,gain_event_id
  ,loss_event_id
  ,rec_event_id
  ,sep_event_id
  ,reason_type
  ,facts
  ,description
  FROM hri_edw_event_hrchy_cmbns
  WHERE combination_id = p_combination_id;

BEGIN

  OPEN row_exists_cur;
  FETCH row_exists_cur INTO   l_combination_id,
                              l_gain_event_id,
                              l_loss_event_id,
                              l_rec_event_id,
                              l_sep_event_id,
                              l_reason_type,
                              l_facts,
                              l_description;
  IF (row_exists_cur%NOTFOUND OR row_exists_cur%NOTFOUND IS NULL) THEN
    CLOSE row_exists_cur;
    INSERT INTO  hri_edw_event_hrchy_cmbns
      ( combination_id
      , gain_event_id
      , loss_event_id
      , rec_event_id
      , sep_event_id
      , reason_type
      , facts
      , description )
      values
        (  p_combination_id
        ,  p_gain_event_id
        ,  p_loss_event_id
        ,  p_rec_event_id
        ,  p_sep_event_id
        ,  p_reason_type
        ,  p_facts
        ,  p_description );
  ELSE
    CLOSE row_exists_cur;
    UPDATE hri_edw_event_hrchy_cmbns
    SET gain_event_id = p_gain_event_id
      , loss_event_id = p_loss_event_id
      , rec_event_id  = p_rec_event_id
      , sep_event_id  = p_sep_event_id
      , reason_type   = p_reason_type
      , facts         = p_facts
      , description   = p_description
    WHERE combination_id = p_combination_id;
  END IF;

END load_cmbn_row;


/******************************************************************************/

END hri_edw_dim_events;

/
