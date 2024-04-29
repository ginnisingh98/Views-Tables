--------------------------------------------------------
--  DDL for Package Body CSE_UTILITY_GRP
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."CSE_UTILITY_GRP" AS
/* $Header: CSEGUTLB.pls 120.0 2006/01/03 11:06:14 brmanesh noship $ */

  FUNCTION is_ib_active RETURN BOOLEAN IS
    l_freeze_flag  VARCHAR2(1) := 'N';
  BEGIN
    EXECUTE IMMEDIATE 'select freeze_flag from csi_install_parameters' INTO l_freeze_flag;
    IF nvl(l_freeze_flag,'N') = 'N' THEN
      RETURN FALSE;
    ELSE
      RETURN TRUE;
    END IF;
  EXCEPTION
    WHEN OTHERS THEN
      RETURN FALSE;
  END is_ib_active;

  FUNCTION is_eib_active RETURN BOOLEAN IS
    l_active  BOOLEAN := FALSE;
    l_value VARCHAR2(1) := 'N';
  BEGIN
    IF is_ib_active THEN
      fnd_profile.get('CSE_EIB_COSTING_USED',l_value);
      IF nvl(l_value,'N') = 'Y' THEN
        l_Active := TRUE;
      END IF;
    END IF;
    RETURN l_active;
  EXCEPTION
    WHEN OTHERS THEN
      RETURN FALSE;
  END is_eib_active;

END cse_utility_grp;

/
