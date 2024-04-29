--------------------------------------------------------
--  DDL for Package Body CN_WKSHT_BONUS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."CN_WKSHT_BONUS_PKG" AS
/* $Header: cntwbonb.pls 115.3 2001/10/29 17:17:23 pkm ship    $ */
--
-- Package Name
-- CN_WKSHT_BONUS_PKG
-- Purpose
--  Table Handler for CN_WORKSHEET_BONUSES
--  FORM 	CNSBPS
--  BLOCK	BONUSES
--
-- History
-- 26-May-99	Renu Chintalapati	Created
/*-------------------------------------------------------------------------*
 |
 |                             PRIVATE VARIABLES
 |
 *-------------------------------------------------------------------------*/
  g_program_type     VARCHAR2(30) := NULL;
/*-------------------------------------------------------------------------*
 |
 |                             PRIVATE ROUTINES
 |
 *-------------------------------------------------------------------------*/

/*-------------------------------------------------------------------------*
  -- Procedure Name
  --	Insert_row
  -- Purpose
  --    Main insert procedure
 *-------------------------------------------------------------------------*/
   PROCEDURE insert_row
   (x_payrun_id                 IN NUMBER
    ,x_salesrep_id              IN NUMBER
    ,x_quota_id                 IN NUMBER
    ,x_comp_plan_id             IN NUMBER
    ,x_amount                   IN NUMBER
    ,x_srp_plan_assign_id       IN NUMBER
    ,x_payment_worksheet_id     IN NUMBER
    ,x_created_by               IN NUMBER
    ,x_creation_date            IN DATE
  ) IS

   BEGIN

     INSERT INTO cn_worksheet_bonuses
       (payrun_id
	,salesrep_id
	,quota_id
	,comp_plan_id
	,amount
	,srp_plan_assign_id
	,payment_worksheet_id)
       VALUES
       (x_payrun_id
	,x_salesrep_id
	,x_quota_id
	,x_comp_plan_id
	,x_amount
	,x_srp_plan_assign_id
	,x_payment_worksheet_id);

   END Insert_row;

/*-------------------------------------------------------------------------*
  -- Procedure Name
  --	Lock_row
  -- Purpose
  --    Lock db row after form record is changed
  -- Notes
  --    Only called from the form
 *-------------------------------------------------------------------------*/
   PROCEDURE lock_row
   ( x_payment_worksheet_id          NUMBER
     ,x_quota_id                     NUMBER
     ,x_comp_plan_id                 NUMBER  ) IS

     CURSOR C IS
        SELECT *
          FROM cn_worksheet_bonuses
	  WHERE payment_worksheet_id = x_payment_worksheet_id
	  AND quota_id = x_quota_id
	  AND comp_plan_id = x_comp_plan_id
           FOR UPDATE NOWAIT;
     l_record C%ROWTYPE;

  BEGIN
     OPEN C;
     FETCH C INTO l_record;

     IF (C%NOTFOUND) then
        CLOSE C;
        fnd_message.Set_Name('FND', 'FORM_RECORD_DELETED');
        app_exception.raise_exception;
     END IF;
     CLOSE C;

  END Lock_row;

/*-------------------------------------------------------------------------
  -- Procedure Name
  --   Update Record
  -- Purpose
  --   To Update the bonus worksheet
  --
 -------------------------------------------------------------------------*/
PROCEDURE update_row (
		      x_payment_worksheet_id      NUMBER
		      ,x_quota_id                 NUMBER
		      ,x_comp_plan_id             NUMBER
		      ,x_amount                   NUMBER   	:= fnd_api.g_miss_num
		      ,x_last_updated_by          NUMBER
		      ,x_last_update_login       NUMBER
		      ,x_last_update_date         DATE
		      ) IS
	l_amount NUMBER;

	CURSOR C IS
	   SELECT *
	     FROM cn_worksheet_bonuses
	     WHERE payment_worksheet_id = x_payment_worksheet_id
	     AND quota_id = x_quota_id
	     AND comp_plan_id = x_comp_plan_id
	     FOR UPDATE;
	oldrow C%ROWTYPE;

  BEGIN
     OPEN C;
     FETCH C INTO oldrow;

     IF (C%NOTFOUND) then
	CLOSE C;
	fnd_message.Set_Name('FND', 'FORM_RECORD_DELETED');
	app_exception.raise_exception;
     END IF;
     CLOSE C;

     SELECT
       decode(x_amount,
	      fnd_api.g_miss_num, oldrow.amount,
	      Nvl(x_amount, 0))
       INTO
       l_amount
       FROM dual;

     UPDATE cn_worksheet_bonuses
       SET  amount =  l_amount,
       last_updated_by = x_last_updated_by,
       last_update_date = x_last_update_date,
       last_update_login = x_last_update_login
       WHERE payment_worksheet_id = x_payment_worksheet_id
       AND quota_id = x_quota_id
       AND comp_plan_id = x_comp_plan_id;



     IF (SQL%NOTFOUND) THEN
        RAISE NO_DATA_FOUND;
     END IF;

  END Update_row;

/*-------------------------------------------------------------------------*
  -- Procedure Name
  --	Delete_row
  -- Purpose
  --    Delete the bonus worksheet
 *-------------------------------------------------------------------------*/
  PROCEDURE Delete_row( x_payment_worksheet_id     NUMBER ) IS
  BEGIN

     DELETE FROM cn_worksheet_bonuses
       WHERE  payment_worksheet_id = x_payment_worksheet_id;
/*     IF (SQL%NOTFOUND) THEN
	RAISE NO_DATA_FOUND;
     END IF;*/

  END Delete_row;

END CN_WKSHT_BONUS_PKG;

/
