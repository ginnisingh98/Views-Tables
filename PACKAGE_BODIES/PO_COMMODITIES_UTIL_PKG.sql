--------------------------------------------------------
--  DDL for Package Body PO_COMMODITIES_UTIL_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PO_COMMODITIES_UTIL_PKG" AS
/*$Header: POXCMUTB.pls 115.1 2003/07/03 01:02:42 jazhang noship $ */

FUNCTION is_commodity_code_unique (
  p_comm_id IN NUMBER
, p_comm_code IN VARCHAR2
) RETURN VARCHAR2
IS

     l_dup po_commodities_b.commodity_id%TYPE;

     CURSOR po_comm_cur IS
	SELECT   commodity_id
	  FROM   po_commodities_b
	  WHERE  commodity_id <> p_comm_id
	  AND    upper(commodity_code) = upper(p_comm_code);

BEGIN

   IF p_comm_code IS NULL THEN
      RETURN 'N';
   END IF;

   OPEN po_comm_cur;
   FETCH po_comm_cur INTO l_dup;
   IF po_comm_cur%FOUND THEN
      CLOSE po_comm_cur;
      RETURN 'N';
   END IF;
   CLOSE po_comm_cur;

   RETURN 'Y';

END is_commodity_code_unique;

FUNCTION is_commodity_name_unique (
  p_comm_id IN NUMBER
, p_comm_name IN VARCHAR2
) RETURN VARCHAR2
IS

     l_dup po_commodities_vl.commodity_id%TYPE;

     CURSOR po_comm_cur IS
	SELECT   commodity_id
	  FROM   po_commodities_vl
	  WHERE  commodity_id <> p_comm_id
	  AND    upper(name) = upper(p_comm_name);

BEGIN

   IF p_comm_name IS NULL THEN
      RETURN 'N';
   END IF;

   OPEN po_comm_cur;
   FETCH po_comm_cur INTO l_dup;
   IF po_comm_cur%FOUND THEN
      CLOSE po_comm_cur;
      RETURN 'N';
   END IF;
   CLOSE po_comm_cur;

   RETURN 'Y';

END is_commodity_name_unique;

END PO_COMMODITIES_UTIL_PKG;

/
