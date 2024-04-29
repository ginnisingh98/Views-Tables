--------------------------------------------------------
--  DDL for Package Body GMILOTMP
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."GMILOTMP" AS
/* $Header: gmilotcb.pls 115.0 2003/04/24 21:01:58 jdiiorio noship $ */


FUNCTION  GET_MAX_AUDIT (pconversion_id          IN NUMBER)
RETURN NUMBER

IS

CURSOR get_max   IS
  SELECT max(conv_audit_id)
  FROM   gmi_item_Conv_audit
  WHERE  conversion_id = pconversion_id;

x_max number;

BEGIN
 OPEN get_max;
 FETCH get_max into x_max;
 CLOSE get_max;
 RETURN x_max;

END GET_MAX_AUDIT;

END GMILOTMP;

/
