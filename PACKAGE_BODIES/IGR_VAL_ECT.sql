--------------------------------------------------------
--  DDL for Package Body IGR_VAL_ECT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IGR_VAL_ECT" AS
/* $Header: IGSRT10B.pls 120.0 2005/06/01 13:46:41 appldev noship $ */
  -- Validate the Enquiry Characteristic Type closed indicator.
  FUNCTION admp_val_ect_closed(
  p_enquiry_characteristic_type IN VARCHAR2 ,
  p_message_name    OUT NOCOPY VARCHAR2)
  RETURN BOOLEAN IS
  BEGIN -- check if the enquiry_characteristic_type is closed
    DECLARE
    v_closed_ind    CHAR;
    CURSOR c_get_closed_ind (
        cp_enquiry_characteristic_type
        IGR_I_E_CHARTYP.enquiry_characteristic_type%TYPE) IS
--          IGS_IN_ENQ_CHAR_TYPE.enquiry_characteristic_type%TYPE) IS
        SELECT  closed_ind
--          FROM    IGS_IN_ENQ_CHAR_TYPE
        FROM    IGR_I_E_CHARTYP
        WHERE   enquiry_characteristic_type = p_enquiry_characteristic_type;
    BEGIN
    p_message_name := null;
    -- Validate input parameters
    IF (p_enquiry_characteristic_type IS NULL)THEN
        RETURN TRUE;
    END IF;
    -- Validate if the enquiry characteristic type is closed
    OPEN c_get_closed_ind(p_enquiry_characteristic_type);
    FETCH c_get_closed_ind INTO v_closed_ind;
    IF (c_get_closed_ind%NOTFOUND) THEN
        CLOSE c_get_closed_ind;
        RETURN TRUE;
    END IF;
    CLOSE c_get_closed_ind;
    IF (v_closed_ind = 'Y') THEN
        p_message_name := 'IGS_AD_ENQ_CHARACTERISTIC';
        RETURN FALSE;
    END IF;
    RETURN TRUE;
    END;
  EXCEPTION
    WHEN OTHERS THEN
        FND_MESSAGE.SET_NAME('IGS','IGS_GE_UNHANDLED_EXP');
        FND_MESSAGE.SET_TOKEN('NAME','IGR_VAL_ECT.admp_val_ect_closed');
        IGS_GE_MSG_STACK.ADD;
  END admp_val_ect_closed;
END IGR_VAL_ECT;

/
