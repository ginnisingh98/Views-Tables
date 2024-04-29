--------------------------------------------------------
--  DDL for Package Body IGR_VAL_EAPMPI
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IGR_VAL_EAPMPI" AS
/* $Header: IGSRT09B.pls 120.0 2005/06/02 03:54:13 appldev noship $ */
  -- To validate the indicated mailing date of an enquiry item.
  FUNCTION admp_val_eapmpi_dt(
  p_person_id IN NUMBER ,
  p_enquiry_appl_number IN NUMBER ,
  p_mailed_dt IN DATE ,
  p_message_name    OUT NOCOPY VARCHAR2)
  RETURN BOOLEAN IS
  BEGIN -- admp_val_eapmpi_dt
    -- Description: Validate the IGS_IN_APPLML_PKGITM.mailed_dt.
    -- * The mailed_dt must be >= to the IGS_IN_ENQUIRY_APPL.enquiry_dt.
  DECLARE
    v_ea_rec    IGR_I_APPL_ALL.enquiry_dt%TYPE;
    CURSOR  c_ea IS
        SELECT  ea.enquiry_dt
        FROM    IGR_I_APPL_ALL       ea
        WHERE   ea.person_id        = p_person_id AND
            ea.enquiry_appl_number  = p_enquiry_appl_number AND
            TRUNC(ea.enquiry_dt)    <= p_mailed_dt;
  BEGIN
    p_message_name := null;
    -- Validate input parameters
    IF (p_person_id IS NULL OR p_enquiry_appl_number IS NULL OR
         p_mailed_dt IS NULL) THEN
        RETURN TRUE;
    END IF;
    OPEN c_ea;
    FETCH c_ea INTO v_ea_rec;
    IF (c_ea%NOTFOUND) THEN
        CLOSE c_ea;
        p_message_name := 'IGS_AD_MAILDT_GE_ENQIRYDT';
        RETURN FALSE;
    END IF;
    CLOSE c_ea;
    IF p_mailed_dt > TRUNC(sysdate) THEN
        p_message_name := 'IGS_AD_MAILDT_GE_ENQIRYDT';
        RETURN FALSE;
    END IF;
    RETURN TRUE;
  EXCEPTION
    WHEN OTHERS THEN
    IF(c_ea%ISOPEN) THEN
        CLOSE c_ea;
    END IF;
  END;
  EXCEPTION
    WHEN OTHERS THEN
        FND_MESSAGE.SET_NAME('IGS','IGS_GE_UNHANDLED_EXP');
        FND_MESSAGE.SET_TOKEN('NAME','IGR_VAL_EAPMPI.admp_val_eapmpi_dt');
        IGS_GE_MSG_STACK.ADD;
  END admp_val_eapmpi_dt;

END IGR_VAL_EAPMPI;

/
