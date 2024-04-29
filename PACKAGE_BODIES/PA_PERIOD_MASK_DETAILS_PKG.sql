--------------------------------------------------------
--  DDL for Package Body PA_PERIOD_MASK_DETAILS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PA_PERIOD_MASK_DETAILS_PKG" AS
--$Header: PAFPPMDB.pls 120.2 2007/02/06 10:04:30 dthakker noship $
PROCEDURE INSERT_ROW(
  x_rowid                 IN OUT NOCOPY ROWID,
  x_period_mask_id        IN pa_period_mask_details.period_mask_id%type,
  x_num_of_periods        IN pa_period_mask_details.num_of_periods%type,
  x_anchor_period_flag    IN pa_period_mask_details.anchor_period_flag%type,
  x_from_anchor_start     IN pa_period_mask_details.from_anchor_start%type,
  x_from_anchor_end       IN pa_period_mask_details.from_anchor_end%type,
  x_from_anchor_position  IN pa_period_mask_details.from_anchor_position%type,
  x_creation_date         IN pa_period_mask_details.creation_date%type,
  x_created_by            IN pa_period_mask_details.created_by%type,
  x_last_update_login     IN pa_period_mask_details.last_update_login%type,
  x_last_updated_by       IN pa_period_mask_details.last_updated_by%type,
  x_last_update_date      IN pa_period_mask_details.last_update_date%type
) IS

  l_period_mask_id pa_period_mask_details.period_mask_id%type;


  CURSOR C IS SELECT ROWID FROM PA_PERIOD_MASK_DETAILS
    WHERE period_mask_id = l_period_mask_id;

  cn_rowid 				  ROWID;

BEGIN
  cn_rowid := x_rowid;

  SELECT x_period_mask_id
  INTO   l_period_mask_id
  FROM   DUAL;

  INSERT INTO PA_PERIOD_MASK_DETAILS(
    period_mask_id,
    num_of_periods,
    anchor_period_flag,
    from_anchor_start,
    from_anchor_end,
    from_anchor_position,
    creation_date,
    created_by,
    last_update_login,
    last_updated_by,
    last_update_date
  ) VALUES (
    l_period_mask_id,
    X_NUM_OF_PERIODS,
    X_ANCHOR_PERIOD_FLAG,
    X_FROM_ANCHOR_START,
    X_FROM_ANCHOR_END,
    X_FROM_ANCHOR_POSITION,
    x_creation_date,
    x_created_by,
    x_last_update_login,
    x_last_updated_by,
    x_last_update_date
  );

  EXCEPTION
     WHEN OTHERS THEN
  	 	x_rowid := cn_rowid;
        RAISE;

END INSERT_ROW;

PROCEDURE LOCK_ROW(
  X_PERIOD_MASK_ID IN pa_period_mask_details.period_mask_id%type,
  X_from_anchor_position IN pa_period_mask_details.from_anchor_position%type
 ) IS
  CURSOR c IS SELECT
       period_mask_id,
       num_of_periods,
       anchor_period_flag,
       from_anchor_start,
       from_anchor_end,
       from_anchor_position,
       creation_date,
       created_by,
       last_update_login,
       last_updated_by,
       last_update_date
    FROM pa_period_mask_details
    WHERE period_mask_id = x_period_mask_id
    AND from_anchor_position = x_from_anchor_position
    FOR UPDATE OF period_mask_id  NOWAIT;

  recinfo c%ROWTYPE;

BEGIN

  OPEN c;
  FETCH c INTO recinfo;
  IF (c%NOTFOUND) THEN
    CLOSE c;
    fnd_message.set_name('FND', 'FORM_RECORD_DELETED');
    app_exception.raise_exception;
  END IF;
  CLOSE c;

  RETURN;

END LOCK_ROW;

PROCEDURE UPDATE_ROW(
     x_period_mask_id        IN pa_period_mask_details.period_mask_id%type,
     x_num_of_periods        IN pa_period_mask_details.num_of_periods%type,
     x_anchor_period_flag    IN pa_period_mask_details.anchor_period_flag%type,
     x_from_anchor_start     IN pa_period_mask_details.from_anchor_start%type,
     x_from_anchor_end       IN pa_period_mask_details.from_anchor_end%type,
     x_from_anchor_position  IN pa_period_mask_details.from_anchor_position%type,
     x_creation_date         IN pa_period_mask_details.creation_date%type,
     x_created_by            IN pa_period_mask_details.created_by%type,
     x_last_update_login     IN pa_period_mask_details.last_update_login%type,
     x_last_updated_by       IN pa_period_mask_details.last_updated_by%type,
     x_last_update_date      IN pa_period_mask_details.last_update_date%type
) IS
BEGIN

  UPDATE pa_period_mask_details
   SET   num_of_periods       = X_NUM_OF_PERIODS,
         anchor_period_flag   = X_ANCHOR_PERIOD_FLAG,
         from_anchor_start    = X_FROM_ANCHOR_START,
         from_anchor_end      = X_FROM_ANCHOR_END,
         from_anchor_position = X_FROM_ANCHOR_POSITION,
         creation_date        = X_CREATION_DATE,
         created_by           = X_CREATED_BY,
         last_update_login    = X_LAST_UPDATE_LOGIN,
         last_updated_by      = X_LAST_UPDATED_BY,
         last_update_date     = X_LAST_UPDATE_DATE
   WHERE period_mask_id = X_PERIOD_MASK_ID
   AND from_anchor_position = X_FROM_ANCHOR_POSITION;

  IF (SQL%NOTFOUND) THEN
    RAISE no_data_found;
  END IF;

END UPDATE_ROW;

PROCEDURE DELETE_ROW(
  X_PERIOD_MASK_ID IN pa_period_mask_details.period_mask_id%type,
  X_from_anchor_position IN pa_period_mask_details.from_anchor_position%type
) IS
BEGIN
  DELETE FROM PA_PERIOD_MASK_DETAILS
  WHERE period_mask_id  = X_PERIOD_MASK_ID AND
  from_anchor_position = x_from_anchor_position;

  IF (SQL%NOTFOUND) THEN
    RAISE no_data_found;
  END IF;

end DELETE_ROW;



PROCEDURE LOAD_ROW(

   x_period_mask_id        IN  pa_period_mask_details.period_mask_id%type,
   x_num_of_periods        IN  pa_period_mask_details.num_of_periods%type,
   x_anchor_period_flag    IN pa_period_mask_details.anchor_period_flag%type,
   x_from_anchor_start     IN pa_period_mask_details.from_anchor_start%type,
   x_from_anchor_end       IN pa_period_mask_details.from_anchor_end%type,
   x_from_anchor_position  IN pa_period_mask_details.from_anchor_position%type,
   x_creation_date         IN pa_period_mask_details.creation_date%type,
   x_created_by            IN pa_period_mask_details.created_by%type,
   x_last_update_login     IN pa_period_mask_details.last_update_login%type,
   x_last_updated_by       IN pa_period_mask_details.last_updated_by%type,
   x_last_update_date      IN pa_period_mask_details.last_update_date%type,
   x_owner                 IN varchar2)
IS

 X_ROWID ROWID;

BEGIN

  PA_PERIOD_MASK_DETAILS_PKG.UPDATE_ROW(
    X_PERIOD_MASK_ID                    =>    X_PERIOD_MASK_ID ,
    X_NUM_OF_PERIODS                    =>    X_NUM_OF_PERIODS,
    X_ANCHOR_PERIOD_FLAG                =>    X_ANCHOR_PERIOD_FLAG,
    X_FROM_ANCHOR_START                 =>    X_FROM_ANCHOR_START,
    X_FROM_ANCHOR_END                   =>    X_FROM_ANCHOR_END,
    X_FROM_ANCHOR_POSITION              =>    X_FROM_ANCHOR_POSITION,
    x_creation_date                     =>    x_creation_date,
    x_created_by                        =>    x_created_by,
    x_last_update_login                 =>    x_last_update_login,
    x_last_updated_by                   =>    x_last_updated_by,
    x_last_update_date                  =>    x_last_update_date);


  EXCEPTION
     WHEN no_data_found then
        PA_PERIOD_MASK_DETAILS_PKG.INSERT_ROW(
          X_ROWID                           =>  X_ROWID ,
          X_PERIOD_MASK_ID                  =>  X_PERIOD_MASK_ID,
          X_NUM_OF_PERIODS                  =>  X_NUM_OF_PERIODS,
          X_ANCHOR_PERIOD_FLAG              =>  X_ANCHOR_PERIOD_FLAG,
          X_FROM_ANCHOR_START               =>  X_FROM_ANCHOR_START,
          X_FROM_ANCHOR_END                 =>  X_FROM_ANCHOR_END,
          X_FROM_ANCHOR_POSITION            =>  X_FROM_ANCHOR_POSITION,
          x_creation_date                   =>  x_creation_date,
          x_created_by                      =>  x_created_by,
          x_last_update_login               =>  x_last_update_login,
          x_last_updated_by                 =>  x_last_updated_by,
          x_last_update_date                =>  x_last_update_date
       );

END LOAD_ROW;


END PA_PERIOD_MASK_DETAILS_PKG;

/
