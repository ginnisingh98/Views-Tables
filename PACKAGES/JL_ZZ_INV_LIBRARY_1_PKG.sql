--------------------------------------------------------
--  DDL for Package JL_ZZ_INV_LIBRARY_1_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."JL_ZZ_INV_LIBRARY_1_PKG" AUTHID CURRENT_USER AS
/* $Header: jlzzil1s.pls 115.3 99/07/16 03:15:18 porting ship  $ */


PROCEDURE get_global_description (flex_name          IN     VARCHAR2,
                                  context            IN     VARCHAR2,
                                  global_description IN OUT VARCHAR2,
                                  row_number         IN     NUMBER,
                                  Errcd              IN OUT NUMBER);


END JL_ZZ_INV_LIBRARY_1_PKG;

 

/
