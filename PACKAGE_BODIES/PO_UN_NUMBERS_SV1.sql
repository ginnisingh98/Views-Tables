--------------------------------------------------------
--  DDL for Package Body PO_UN_NUMBERS_SV1
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PO_UN_NUMBERS_SV1" AS
/* $Header: POXPIUNB.pls 120.0.12000000.1 2007/07/27 08:35:45 grohit noship $ */

/*================================================================

  FUNCTION NAME: 	val_un_number_id()

==================================================================*/
 FUNCTION val_un_number_id(x_un_number_id IN NUMBER) RETURN BOOLEAN
 IS

   x_progress   varchar2(3) := null;
   x_temp       binary_integer := 0;

 BEGIN
   x_progress := '010';

   /* check to see if x_un_number_id is valid in po_un_numbers_val_v */

   SELECT count(*)
     INTO x_temp
     FROM po_un_numbers_val_v
    WHERE un_number_id = x_un_number_id;

   IF x_temp = 0 THEN
      RETURN FALSE;   /* validation fails */
   ELSE
      RETURN TRUE;    /* validation succeeds */
   END IF;

 EXCEPTION
   WHEN others THEN
        po_message_s.sql_error
        ('val_un_number_id', x_progress, sqlcode);
        raise;
 END val_un_number_id;

/*================================================================

  FUNCTION NAME: 	derive_un_number_id()

==================================================================*/
FUNCTION  derive_un_number_id(X_un_number IN VARCHAR2)
                                   return NUMBER IS

    X_progress       varchar2(3)     := NULL;
    X_un_number_id_v  number      := NULL;

    /* get the group of un_number_id records */

    CURSOR c_un_number_id IS
    SELECT un_number_id
    FROM   po_un_numbers_val_v
    WHERE  un_number = X_un_number;

BEGIN

    X_progress := '010';

    OPEN c_un_number_id;
    FETCH c_un_number_id INTO  X_un_number_id_v;

    IF c_un_number_id%NOTFOUND then
       X_un_number_id_v := NULL;
    END IF;

    CLOSE c_un_number_id;

    RETURN X_un_number_id_v;

EXCEPTION
   WHEN OTHERS THEN
     po_message_s.sql_error('derive_un_number_id',X_progress, sqlcode);
   RAISE;

END derive_un_number_id;

END PO_UN_NUMBERS_SV1;

/
