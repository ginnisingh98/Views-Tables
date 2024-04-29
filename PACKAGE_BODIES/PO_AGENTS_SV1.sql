--------------------------------------------------------
--  DDL for Package Body PO_AGENTS_SV1
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PO_AGENTS_SV1" AS
/* $Header: POXPIAGB.pls 120.0.12010000.1 2008/09/18 12:21:08 appldev noship $ */

/*===============================================================

   FUNCTION NAME : derive_agent_id()

================================================================*/

FUNCTION  derive_agent_id(X_agent_name  IN VARCHAR2)
return NUMBER IS

  X_progress        varchar2(3)     := NULL;
  X_agent_id_v      number        := NULL;

BEGIN

  X_progress := '010';

  /* get the agent_id by selecting employee_id from po_buyers_val_v
     based on the agent_name provided from input parameter */

  SELECT	 employee_id
  INTO		 X_agent_id_v
  FROM		 po_buyers_val_v
  WHERE		 full_name = X_agent_name;

  RETURN X_agent_id_v;

EXCEPTION

  WHEN no_data_found THEN
       RETURN NULL;
  WHEN others THEN
       po_message_s.sql_error('derive_agent_id',X_progress, sqlcode);
       raise;

END derive_agent_id;

/*================================================================

  FUNCTION NAME: 	val_agent_id()

==================================================================*/
 FUNCTION val_agent_id(x_agent_id  IN NUMBER)RETURN BOOLEAN
 IS

   x_progress   varchar2(3) := null;
   x_temp       binary_integer := 0;

 BEGIN
   x_progress := '010';

   /* check to see if the given agnet_id is a valid agent_id in
      po_buyers_val_v table */

   SELECT count(*)
     INTO x_temp
     FROM po_buyers_val_v
    WHERE employee_id  = X_agent_id;

   IF x_temp = 0 THEN
      RETURN FALSE;    /* validation fails */
   ELSE
      RETURN TRUE;     /* validation succeeds */
   END IF;

 EXCEPTION
   WHEN others THEN
        po_message_s.sql_error('val_agent_id', x_progress,sqlcode);
      raise;
 END val_agent_id;

END PO_AGENTS_SV1;

/
