--------------------------------------------------------
--  DDL for Package Body QP_ENTITY_SECURITY
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."QP_ENTITY_SECURITY" AS
/* $Header: QPXVSECB.pls 120.0 2005/06/02 01:31:08 appldev noship $ */

FUNCTION ENABLED RETURN varchar2 IS
BEGIN
IF qp_code_control.get_code_release_level > '110508' THEN
  IF fnd_profile.value('QP_Entity_Security_ENABLED') = 'Y' THEN
    RETURN 'Y';
  END IF;
END IF;
RETURN 'N';
END;

END QP_ENTITY_SECURITY;

/
