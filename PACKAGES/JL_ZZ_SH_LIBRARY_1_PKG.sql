--------------------------------------------------------
--  DDL for Package JL_ZZ_SH_LIBRARY_1_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."JL_ZZ_SH_LIBRARY_1_PKG" AUTHID CURRENT_USER AS
/* $Header: jlzzwl1s.pls 120.4 2005/12/03 01:12:21 pla ship $ */


Procedure get_vat_count(sitevat        IN  Varchar2,
                        tot_rec        IN OUT NOCOPY Number,
                        row_number     IN Number,
                        errcd          IN OUT NOCOPY Number);

Procedure get_translated_label
    (p_lookup_code   IN            Varchar2,
     p_label            OUT NOCOPY Varchar2,
     p_errcd            OUT NOCOPY Number);
END JL_ZZ_SH_LIBRARY_1_PKG;

 

/
