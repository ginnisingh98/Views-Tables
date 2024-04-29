--------------------------------------------------------
--  DDL for Package Body IGS_PS_VAL_TR
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IGS_PS_VAL_TR" AS
/* $Header: IGSPS57B.pls 115.5 2002/12/12 09:48:08 smvk ship $ */
  --
  -- Validate teaching responsibility percentage for the IGS_PS_UNIT version
  FUNCTION crsp_val_tr_perc(
  p_unit_cd IN VARCHAR2 ,
  p_version_number IN NUMBER ,
  p_message_name OUT NOCOPY VARCHAR2,
  p_b_lgcy_validator IN BOOLEAN )
  RETURN BOOLEAN AS

 /***********************************************************************************************
    Created By     :
    Date Created By:
    Purpose        :

    Known limitations,enhancements,remarks:
    Change History (in reverse chronological order)
    Who		When		What
    smvk      12-Dec-2002      Added a boolean parameter p_b_lgcy_validator to the function call crsp_val_tr_perc.
                               As a part of the Bug # 2696207
  ********************************************************************************************** */

  	gv_teach_respons	CHAR;
  	gv_unit_status		IGS_PS_UNIT_STAT.s_unit_status%TYPE;
  	CURSOR	gc_unit_status IS
  		SELECT	US.s_unit_status
  		FROM	IGS_PS_UNIT_VER UV,
  			IGS_PS_UNIT_STAT US
  		WHERE	UV.unit_cd = p_unit_cd AND
  			UV.version_number = p_version_number AND
  			UV.unit_status= US.unit_status;
  	CURSOR	gc_teach_respons_exists IS
  		SELECT	'x'
  		FROM	IGS_PS_TCH_RESP
  		WHERE	unit_cd = p_unit_cd AND
  			version_number = p_version_number;
      CURSOR  cur_user  IS
	  	SELECT 	SUM(percentage)
	  	  	FROM 	IGS_PS_TCH_RESP
	  	WHERE 	unit_cd 	= p_unit_cd AND
  		version_number 	= p_version_number;


      gv_percent IGS_PS_TCH_RESP.percentage%TYPE;

  BEGIN
  	-- finding the s_unit_status
  	OPEN  gc_unit_status;
  	FETCH gc_unit_status INTO gv_unit_status;
  	-- finding IGS_PS_TCH_RESP records
  	OPEN  gc_teach_respons_exists;
  	FETCH gc_teach_respons_exists INTO gv_teach_respons;
  	-- Find the sum of all percentages

      OPEN cur_user;
     FETCH  cur_user INTO gv_percent;
     IF cur_user%NOTFOUND THEN
       RAISE no_data_found ;
     END IF;
     CLOSE cur_user ;

  	-- when the percentage totals 100
  	IF gv_percent = 100.00 THEN
  		CLOSE gc_unit_status;
  		CLOSE gc_teach_respons_exists;
  		p_message_name := NULL;
  		RETURN TRUE;
  	ELSE
  		-- when the percentage doesn't total 100 and
  		-- if the IGS_PS_UNIT_STAT.s_unit_status is PLANNED
  		-- and no teaching responsibility records exist
  		IF (gv_unit_status = 'PLANNED' AND gc_teach_respons_exists%NOTFOUND) AND (NOT p_b_lgcy_validator) THEN
  			CLOSE gc_unit_status;
  			CLOSE gc_teach_respons_exists;
  			p_message_name := NULL;
  			RETURN TRUE;
  		ELSE
  			-- when the percentage doesn't total 100 and
  			-- if the IGS_PS_UNIT_STAT.s_unit_status is not PLANNED
  			-- or no teaching responsibility records exist
  			CLOSE gc_unit_status;
  			CLOSE gc_teach_respons_exists;
  			p_message_name := 'IGS_PS_TCHRESP_NOTTOTAL_100';
  			RETURN FALSE;
  		END IF;
  	END IF;
  EXCEPTION
      WHEN no_data_found THEN
      CLOSE cur_user;
  	WHEN OTHERS THEN
                IF cur_user%ISOPEN THEN
                   CLOSE cur_user;
		    END IF;
 		    Fnd_Message.Set_Name('IGS', 'IGS_GE_UNHANDLED_EXCEPTION');
 		    	Fnd_Message.Set_Token('NAME','IGS_PS_VAL_TR.crsp_val_tr_perc');
			IGS_GE_MSG_STACK.ADD;
			App_Exception.Raise_Exception;
  END crsp_val_tr_perc;

END IGS_PS_VAL_TR;

/
