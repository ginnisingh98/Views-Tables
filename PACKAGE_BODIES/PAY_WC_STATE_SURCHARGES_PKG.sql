--------------------------------------------------------
--  DDL for Package Body PAY_WC_STATE_SURCHARGES_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PAY_WC_STATE_SURCHARGES_PKG" as
/* $Header: pywss01t.pkb 115.1 99/07/17 06:50:51 porting ship  $ */

  PROCEDURE Insert_Row(X_Rowid                   IN OUT VARCHAR2,
                       X_Surcharge_Id                   IN OUT NUMBER,
                       X_State_Code                     VARCHAR2,
                       X_Add_To_Rt                      VARCHAR2,
                       X_Name                           VARCHAR2,
                       X_Position                       VARCHAR2,
                       X_Rate                           NUMBER
  ) IS
    CURSOR C IS SELECT rowid FROM PAY_WC_STATE_SURCHARGES
                 WHERE surcharge_id = X_Surcharge_Id;
      CURSOR C2 IS SELECT pay_wc_state_surcharges_s.nextval FROM sys.dual;
   BEGIN
--
-- check if unique
--
check_unique( x_surcharge_id,
	      x_state_code,
              x_name,
	      x_position );
--
check_position( p_state_code => x_state_code,
		p_position    => x_position,
		p_event      => 'INSERT');
--
      if (X_Surcharge_Id is NULL) then
        OPEN C2;
        FETCH C2 INTO X_Surcharge_Id;
        CLOSE C2;
      end if;

       INSERT INTO PAY_WC_STATE_SURCHARGES(
              surcharge_id,
              state_code,
              add_to_rt,
              name,
              position,
              rate
             ) VALUES (
              X_Surcharge_Id,
              X_State_Code,
              X_Add_To_Rt,
              X_Name,
              X_Position,
              X_Rate
             );

    OPEN C;
    FETCH C INTO X_Rowid;
    if (C%NOTFOUND) then
      CLOSE C;
      Raise NO_DATA_FOUND;
    end if;
    CLOSE C;
  END Insert_Row;


  PROCEDURE Lock_Row(X_Rowid                            VARCHAR2,
                     X_Surcharge_Id                     NUMBER,
                     X_State_Code                       VARCHAR2,
                     X_Add_To_Rt                        VARCHAR2,
                     X_Name                             VARCHAR2,
                     X_Position                         VARCHAR2,
                     X_Rate                             NUMBER
  ) IS
    CURSOR C IS
        SELECT *
        FROM   PAY_WC_STATE_SURCHARGES
        WHERE  rowid = X_Rowid
        FOR UPDATE of Surcharge_Id NOWAIT;
    Recinfo C%ROWTYPE;


  BEGIN
    OPEN C;
    FETCH C INTO Recinfo;
    if (C%NOTFOUND) then
      CLOSE C;
      FND_MESSAGE.Set_Name('FND', 'FORM_RECORD_DELETED');
      APP_EXCEPTION.Raise_Exception;
    end if;
    CLOSE C;
Recinfo.state_code := RTRIM(Recinfo.state_code);
Recinfo.add_to_rt := RTRIM(Recinfo.add_to_rt);
Recinfo.name := RTRIM(Recinfo.name);
Recinfo.position := RTRIM(Recinfo.position);
    if (
               (Recinfo.surcharge_id =  X_Surcharge_Id)
           AND (Recinfo.state_code =  X_State_Code)
           AND (Recinfo.add_to_rt =  X_Add_To_Rt)
           AND (Recinfo.name =  X_Name)
           AND (Recinfo.position =  X_Position)
           AND (Recinfo.rate =  X_Rate)
      ) then
      return;
      else
      FND_MESSAGE.Set_Name('FND', 'FORM_RECORD_CHANGED');
      APP_EXCEPTION.Raise_Exception;
    end if;
  END Lock_Row;



  PROCEDURE Update_Row(X_Rowid                          VARCHAR2,
                       X_Surcharge_Id                   NUMBER,
                       X_State_Code                     VARCHAR2,
                       X_Add_To_Rt                      VARCHAR2,
                       X_Name                           VARCHAR2,
                       X_Position                       VARCHAR2,
                       X_Rate                           NUMBER
  ) IS
  BEGIN
--
-- check if unique
--
check_unique( x_surcharge_id,
	      x_state_code,
              x_name,
	      x_position );
--
check_position( p_state_code => x_state_code,
		p_position    => x_position,
		p_event      => 'UPDATE');
--
    UPDATE PAY_WC_STATE_SURCHARGES
    SET
       surcharge_id                    =     X_Surcharge_Id,
       state_code                      =     X_State_Code,
       add_to_rt                       =     X_Add_To_Rt,
       name                            =     X_Name,
       position                        =     X_Position,
       rate                            =     X_Rate
    WHERE rowid = X_Rowid;

    if (SQL%NOTFOUND) then
      Raise NO_DATA_FOUND;
    end if;
  END Update_Row;
  PROCEDURE Delete_Row(X_Rowid VARCHAR2) IS
  BEGIN
    DELETE FROM PAY_WC_STATE_SURCHARGES
    WHERE rowid = X_Rowid;

    if (SQL%NOTFOUND) then
      Raise NO_DATA_FOUND;
    end if;
  END Delete_Row;

PROCEDURE check_unique (p_surcharge_id NUMBER,
			p_state_code   VARCHAR2,
			p_name         VARCHAR2,
			p_position     VARCHAR2 ) IS
--
-- declare cursor
--
CURSOR chk_name IS
SELECT
	'N'
FROM
	pay_wc_state_surcharges wss
WHERE
	wss.name	= p_name	AND
	wss.state_code	= p_state_code	AND
	(wss.surcharge_id <> p_surcharge_id
	OR
	 p_surcharge_id IS NULL);
--
CURSOR chk_position IS
SELECT
	'N'
FROM
	pay_wc_state_surcharges wss
WHERE
	wss.state_code	= p_state_code	AND
	wss.position	= p_position	AND
	(wss.surcharge_id <> p_surcharge_id
	OR
	 p_surcharge_id IS NULL);
--
-- declare local variables
--
  l_unique VARCHAR2(1) := 'Y';
--
BEGIN
--
OPEN  chk_name;
FETCH chk_name INTO l_unique;
CLOSE chk_name;
--
IF (l_unique = 'N')
THEN
     hr_utility.set_message(801, 'PAY_7362_WC_NAME_NOT_UNIQUE');
     hr_utility.raise_error;
END IF;
--
OPEN  chk_position;
FETCH chk_position INTO l_unique;
CLOSE chk_position;
--
IF (l_unique = 'N')
THEN
     hr_utility.set_message(801, 'PAY_7363_WC_POS_NOT_UNIQUE');
     hr_utility.raise_error;
END IF;
--
END check_unique;

PROCEDURE check_position ( p_state_code VARCHAR2,
                           p_position   VARCHAR2,
			   p_event      VARCHAR2 ) IS
--
-- declare local variables
--
   l_position_exists VARCHAR2(1) := 'N';
   l_position     VARCHAR2(30);
--
-- declare cursor
--
CURSOR chk_position IS
SELECT
	'Y'
FROM
	pay_wc_state_surcharges wss
WHERE
	wss.position	= l_position	AND
	wss.state_code	= p_state_code;
--
BEGIN
--
IF (p_event = 'DELETE')
THEN
     IF(p_position = 'POST_EXP_MOD_1')
     THEN
         l_position := 'POST_EXP_MOD_2';
         --
         OPEN  chk_position;
         FETCH chk_position INTO l_position_exists;
         CLOSE chk_position;
         --
         IF (l_position_exists = 'Y')
         THEN
              hr_utility.set_message(801, 'PAY_7365_WC_DEL_POS_2_FIRST');
              hr_utility.raise_error;
         END IF;
     END IF;
     --
ELSIF (p_event IN ('INSERT', 'UPDATE') )
THEN
     IF(p_position = 'POST_EXP_MOD_2')
     THEN
         l_position := 'POST_EXP_MOD_1';
         --
         OPEN  chk_position;
         FETCH chk_position INTO l_position_exists;
         CLOSE chk_position;
         IF (l_position_exists = 'N')
         THEN
              hr_utility.set_message(801, 'PAY_7364_WC_WC_INS_POS_1_FIRST');
              hr_utility.raise_error;
         END IF;
     END IF;
     --
ELSE
     hr_utility.raise_error;
END IF;
--
END check_position;


END PAY_WC_STATE_SURCHARGES_PKG;

/
