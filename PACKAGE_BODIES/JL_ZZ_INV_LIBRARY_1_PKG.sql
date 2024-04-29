--------------------------------------------------------
--  DDL for Package Body JL_ZZ_INV_LIBRARY_1_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."JL_ZZ_INV_LIBRARY_1_PKG" AS
/* $Header: jlzzil1b.pls 115.4 99/07/16 03:15:12 porting ship  $ */

  PROCEDURE get_global_description (flex_name          IN     VARCHAR2,
                                    context            IN     VARCHAR2,
                                    global_description IN OUT VARCHAR2,
                                    row_number         IN     NUMBER,
                                    Errcd              IN OUT NUMBER) IS
  BEGIN
    Errcd := 0;
    SELECT SUBSTR (description, 1, 50)
    INTO   global_description
    FROM   fnd_descr_flex_contexts_vl
    WHERE  application_id = 7003
    AND    descriptive_flexfield_name  = flex_name
    AND    descriptive_flex_context_code = context
    AND    enabled_flag = 'Y'
    AND    rownum = row_number;
    EXCEPTION
      WHEN OTHERS THEN
        Errcd := SQLCODE;
  END get_global_description;


END JL_ZZ_INV_LIBRARY_1_PKG;

/
