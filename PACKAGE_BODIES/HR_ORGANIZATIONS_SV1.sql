--------------------------------------------------------
--  DDL for Package Body HR_ORGANIZATIONS_SV1
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."HR_ORGANIZATIONS_SV1" AS
/* $Header: POXPIOGB.pls 115.0 99/07/17 01:49:25 porting ship $ */

/*================================================================

  FUNCTION NAME: 	val_inv_organization_id()

==================================================================*/
 FUNCTION val_inv_organization_id(x_inv_organization_id IN NUMBER)
 RETURN BOOLEAN IS

   x_progress    varchar2(3) := null;
   x_temp        binary_integer := 0;

 BEGIN
   x_progress := '010';

   /* check to see if there are x_inv_organization_id exists in
      org_organization_definitions table */

   SELECT count(*)
     INTO x_temp
     FROM org_organization_definitions
    WHERE organization_id = x_inv_organization_id
      AND sysdate < nvl(disable_date, sysdate+1)
      AND inventory_enabled_flag = 'Y';

   IF x_temp = 0 THEN
      RETURN FALSE;  /* validation fails */
   ELSE
      RETURN TRUE;   /* validation success */
   END IF;

 EXCEPTION
   WHEN others THEN
        po_message_s.sql_error
        ('val_inv_organization_id', x_progress, sqlcode);
        raise;
 END val_inv_organization_id;


/*================================================================

  FUNCTION NAME: 	derive_organization_id()

==================================================================*/
FUNCTION  derive_organization_id(X_organization_code IN VARCHAR2)
                               return NUMBER IS

X_progress       varchar2(3)     := NULL;
X_organization_id_v number        := NULL;

BEGIN

 X_progress := '010';

 /* get the organization_id form org_organization_definitions
    table based on organization_code */

 SELECT organization_id
   INTO X_organization_id_v
   FROM org_organization_definitions
  WHERE organization_code = X_organization_code
    AND sysdate < nvl(disable_date, sysdate+1)
    AND inventory_enabled_flag = 'Y';

 RETURN X_organization_id_v;

EXCEPTION

   When no_data_found then
     RETURN NULL;
   When others then
     po_message_s.sql_error('derive_organization_id',X_progress, sqlcode);
   raise;

END derive_organization_id;
END HR_ORGANIZATIONS_SV1;

/
