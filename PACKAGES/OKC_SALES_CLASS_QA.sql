--------------------------------------------------------
--  DDL for Package OKC_SALES_CLASS_QA
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OKC_SALES_CLASS_QA" AUTHID CURRENT_USER AS
/* $Header: OKCRIQAS.pls 120.0 2005/05/25 19:20:24 appldev noship $ */



-------------------------------------------------------------------------------
-- Procedure:       validate_kto_integration
-- Version:         1.0
-- Purpose:          validate if any contract is fit for integration with Order mangement.
-- In Parameters:   p_chr_id       Contract for which to create order

-- Out Parameters:  x_return_status
--

PROCEDURE validate_kto_integration( p_chr_id     IN  okc_k_headers_b.ID%TYPE,
                                    x_return_status   OUT NOCOPY VARCHAR2
        	                      	);

Function is_jtf_source_table(  p_object_code    jtf_objects_b.object_code%type,
                                p_from_table    JTF_OBJECTS_B.from_table%type
                             )

return boolean ;



END OKC_SALES_CLASS_QA;

 

/
