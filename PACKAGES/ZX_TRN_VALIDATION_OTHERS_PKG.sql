--------------------------------------------------------
--  DDL for Package ZX_TRN_VALIDATION_OTHERS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."ZX_TRN_VALIDATION_OTHERS_PKG" AUTHID CURRENT_USER as
/* $Header: zxctrnds.pls 120.1 2004/12/02 17:55:17 thwon noship $  */

procedure VALIDATE_TRN (p_country_code      IN VARCHAR2,
                        p_trn_value         IN VARCHAR2,
                        p_trn_type          IN VARCHAR2,
                        p_check_unique_flag IN VARCHAR2,
                        x_return_status     OUT NOCOPY VARCHAR2,
                        x_error_buffer      OUT NOCOPY VARCHAR2);

END ZX_TRN_VALIDATION_OTHERS_PKG;

 

/
