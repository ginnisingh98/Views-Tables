--------------------------------------------------------
--  DDL for Package Body IGR_VAL_EPI
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IGR_VAL_EPI" AS
/* $Header: IGSRT12B.pls 120.0 2005/06/01 20:47:43 appldev noship $ */
  -- To validate the available mailing date of the enquiry package item.
  FUNCTION admp_val_epi_av_dt(
  p_available_ind IN VARCHAR2 DEFAULT 'N',
  p_available_dt IN DATE ,
  p_message_name    OUT NOCOPY VARCHAR2)
  RETURN BOOLEAN IS
    gv_other_detail     VARCHAR2(255);
  BEGIN
  DECLARE
    BEGIN
    p_message_name := null;
    -- Validate input parameters
    IF p_available_ind IS NULL OR p_available_dt IS NULL THEN
        RETURN TRUE;
    END IF;
    -- Validate that available_dt is not set if available_ind = Y
    IF (p_available_ind = 'Y' AND p_available_dt IS NOT NULL) THEN
        --p_message_num := 4751;
        p_message_name := 'IGS_AD_AVLDT_CANOT_AVLIND_SET';
        RETURN FALSE;
    ELSE
        RETURN TRUE;
    END IF;
  END;
  EXCEPTION
    WHEN OTHERS THEN
        FND_MESSAGE.SET_NAME('IGS','IGS_GE_UNHANDLED_EXP');
        FND_MESSAGE.SET_TOKEN('NAME','IGR_VAL_EPI.admp_val_epi_av_dt');
        IGS_GE_MSG_STACK.ADD;
        APP_EXCEPTION.RAISE_EXCEPTION;
  END admp_val_epi_av_dt;
  --
  -- Validate the Enquiry Package Item closed indicator.
  FUNCTION admp_val_epi_active(
  p_enquiry_package_item IN VARCHAR2 ,
  p_closed_ind  VARCHAR2 DEFAULT 'N',
  p_message_name    OUT NOCOPY VARCHAR2)
  RETURN BOOLEAN IS
    gv_other_detail     VARCHAR2(255);
  BEGIN -- admp_val_epi_active

  DECLARE
    v_eitpi_exists      VARCHAR2(1);
    v_eltpi_exists      VARCHAR2(1);
    v_cepi_exists       VARCHAR2(1);
  BEGIN
    p_message_name := null;
    --Check parameters.
    IF p_enquiry_package_item IS NULL OR
            p_closed_ind = 'N' THEN
        RETURN TRUE;
    END IF;
    RETURN TRUE;
  END;
  EXCEPTION
    WHEN OTHERS THEN
        FND_MESSAGE.SET_NAME('IGS','IGS_GE_UNHANDLED_EXP');
        FND_MESSAGE.SET_TOKEN('NAME','IGR_VAL_EPI.admp_val_epi_active');
        IGS_GE_MSG_STACK.ADD;
        APP_EXCEPTION.RAISE_EXCEPTION;
  END admp_val_epi_active;
  --
  -- Validate the Enquiry Package Item closed indicator.
  FUNCTION admp_val_epi_closed(
  p_package_item IN VARCHAR2 ,
  p_message_name    OUT NOCOPY VARCHAR2)
  RETURN BOOLEAN IS
    gv_other_detail     VARCHAR2(255);
  BEGIN -- check if the package_item is closed
  DECLARE
    CURSOR c_get_closed_ind (
        cp_package_item IGR_I_PKG_ITEMS_V.package_item%TYPE) IS
        SELECT  actual_avail_from_date,actual_avail_to_date
        FROM    igr_i_pkg_items_v
        WHERE   package_item = p_package_item;
        l_get_closed_ind_rec c_get_closed_ind%ROWTYPE;
  BEGIN
    p_message_name := null;
    -- Validate input parameters
    IF (p_package_item IS NULL)THEN
        RETURN TRUE;
    END IF;
    -- Validate if the enquiry Package item is closed
    OPEN c_get_closed_ind(p_package_item);
    FETCH c_get_closed_ind INTO l_get_closed_ind_rec;
    IF (c_get_closed_ind%NOTFOUND) THEN
        CLOSE c_get_closed_ind;
        RETURN TRUE;
    END IF;
    CLOSE c_get_closed_ind;
    IF ((SYSDATE < l_get_closed_ind_rec.actual_avail_from_date) OR (SYSDATE > l_get_closed_ind_rec.actual_avail_to_date )) THEN
        --p_message_num := 4270;
        p_message_name := 'IGS_AD_ENQ_PCKGITEM_CLOSED';
        RETURN FALSE;
    END IF;
    RETURN TRUE;
  END;
  EXCEPTION
    WHEN OTHERS THEN
        FND_MESSAGE.SET_NAME('IGS','IGS_GE_UNHANDLED_EXP');
        FND_MESSAGE.SET_TOKEN('NAME','IGR_VAL_EPI.admp_val_epi_closed');
        IGS_GE_MSG_STACK.ADD;
        APP_EXCEPTION.RAISE_EXCEPTION;
  END admp_val_epi_closed;
END IGR_VAL_EPI;

/
