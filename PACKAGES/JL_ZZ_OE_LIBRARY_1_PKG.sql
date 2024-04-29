--------------------------------------------------------
--  DDL for Package JL_ZZ_OE_LIBRARY_1_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."JL_ZZ_OE_LIBRARY_1_PKG" AUTHID CURRENT_USER AS
/* $Header: jlzzol1s.pls 120.1 2005/06/28 19:43:27 vsidhart noship $ */


PROCEDURE get_context_name1 (cntry_code         IN             VARCHAR2,
                             form_code          IN             VARCHAR2,
                             global_description IN OUT NOCOPY  VARCHAR2,
                             row_number         IN             NUMBER,
                             Errcd              IN OUT NOCOPY  NUMBER);

PROCEDURE get_global_attribute3 (p_order_type_id IN          NUMBER,
                                 def_val       IN OUT NOCOPY VARCHAR2,
                                 row_number    IN            NUMBER,
                                 Errcd         IN OUT NOCOPY NUMBER);

END JL_ZZ_OE_LIBRARY_1_PKG;

 

/
