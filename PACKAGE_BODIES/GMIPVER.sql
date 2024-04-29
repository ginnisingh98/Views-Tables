--------------------------------------------------------
--  DDL for Package Body GMIPVER
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."GMIPVER" as
/* $Header: GMIPVERB.pls 115.0 2002/08/01 21:49:11 jsrivast noship $     */

/* ========================================================
   This package would be used to ascertain the OPM 11i
   patchset level.
   ======================================================== */
/* ========================================================
   This function would be return OPM 11i family pack on the
   installation .
   Returns:
	   0 -- Base 11i or undetermined
	   1 -- 11i.GMI.A
	   2--  11i.GMI.B
	   3--  11i.GMI.C
	   4--  11i.GMI.D
	   5--  11i.GMI.E
	   6--  11i.GMI.F
	   7--  11i.GMI.G
	   8--  11i.GMI.H
	   9--  11i.GMI.I
	  10--  11i.GMI.J
	  11--  11i.GMI.K
	  12--  11i.GMI.L
	  13--  11i.GMI.M
	  14--  11i.GMI.N
	  15--  11i.GMI.O
   ======================================================== */

FUNCTION get_opm_11i_family_pack RETURN NUMBER IS
  l_retval NUMBER := 0;
  l_count  NUMBER;
  BEGIN
    SELECT decode(substr(patch_level,-1,1),'A',1,'B',2,'C',3,'D',4,'E',5,'F',6,'G',7,'H',8,'I',9,'J',10,'K',11,'L',12,'M',13,'N',14,'O',15,0)
    INTO   l_retval
    FROM   fnd_product_installations
    WHERE  application_id = 551;
    IF (l_retval <> 0) THEN
      RETURN l_retval;
    END IF;
    SELECT count(1)
    INTO   l_count
    FROM   fnd_views
    WHERE  application_id   =     552
    and    view_name      like   'GMD_QC_TESTS_VL';
    IF (l_count = 1) THEN
      /* it should be J or above. we will only return for J */
       RETURN 10;
    END IF;
    SELECT count(1)
    INTO   l_count
    FROM   fnd_tables
    WHERE  application_id   =     551
    and    table_name      like   'GMI_ITEMS_XML_INTERFACE';
    IF (l_count = 1) THEN
      /* it should be I or above. we will only return for I */
       RETURN 9;
    END IF;
    /* Below check is for common receiving which was
       introduced in family pack H */
    IF (GML_PO_FOR_PROCESS.check_po_for_proc) THEN
      /* it should be H or above. we will only return for H */
       RETURN 8;
    END IF;
    SELECT count(1)
    INTO   l_count
    FROM   fnd_tables
    WHERE  application_id   =     551
    and    table_name      like   'GMI_CATEGORY_SETS';
    IF (l_count = 1) THEN
      /* it should be G or above. we will only return for G */
       RETURN 7;
    END IF;
    SELECT count(1)
    INTO   l_count
    FROM   fnd_views
    WHERE  application_id   =     550
    and    view_name      like   'SY_UOMS_MST_V';
    IF (l_count = 1) THEN
      /* it should be E/F or above. we will only return for F */
       RETURN 6;
    END IF;
    RETURN 0;
  EXCEPTION
    WHEN Others THEN
      Return 0;
  END get_opm_11i_family_pack;
END GMIPVER;

/
