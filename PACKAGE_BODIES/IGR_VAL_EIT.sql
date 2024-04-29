--------------------------------------------------------
--  DDL for Package Body IGR_VAL_EIT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IGR_VAL_EIT" AS
/* $Header: IGSRT11B.pls 120.0 2005/06/01 18:19:51 appldev noship $ */

  -- Validate the Enquiry Information Type closed indicator.
  FUNCTION admp_val_eit_closed(
  p_enquiry_information_type IN VARCHAR2 ,
  p_message_name    OUT NOCOPY VARCHAR2)
  RETURN BOOLEAN IS
  BEGIN -- check if the enquiry_information_type is closed
    DECLARE
    v_closed_ind    CHAR;
    CURSOR c_get_closed_ind (
        cp_enquiry_information_type
        igr_i_info_types_v.information_type%TYPE) IS
        SELECT  'X'
        FROM    igr_i_info_types_v
        WHERE   information_type = p_enquiry_information_type
        AND sysdate > ACTUAL_AVAIL_TO_DATE;
    BEGIN
    p_message_name := null;
    -- Validate input parameters
    IF (p_enquiry_information_type IS NULL)THEN
        RETURN TRUE;
    END IF;
    -- Validate if the enquiry information item is closed
    OPEN c_get_closed_ind(p_enquiry_information_type);
    FETCH c_get_closed_ind INTO v_closed_ind;
    IF (c_get_closed_ind%NOTFOUND) THEN
        CLOSE c_get_closed_ind;
        RETURN TRUE;
    END IF;
    CLOSE c_get_closed_ind;
    IF (v_closed_ind = 'X') THEN
        p_message_name := 'IGS_AD_ENQ_INFOTYPE_CLOSED';
        RETURN FALSE;
    END IF;
    RETURN TRUE;
    END;
  EXCEPTION
    WHEN OTHERS THEN
        FND_MESSAGE.SET_NAME('IGS','IGS_GE_UNHANDLED_EXP');
        FND_MESSAGE.SET_TOKEN('NAME','IGR_VAL_EIT.admp_val_eit_closed');
        IGS_GE_MSG_STACK.ADD;
  END admp_val_eit_closed;
END IGR_VAL_EIT;

/
