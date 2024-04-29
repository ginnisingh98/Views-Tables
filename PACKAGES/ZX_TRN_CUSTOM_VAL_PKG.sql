--------------------------------------------------------
--  DDL for Package ZX_TRN_CUSTOM_VAL_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."ZX_TRN_CUSTOM_VAL_PKG" AUTHID CURRENT_USER AS
/* $Header: zxccusvs.pls 120.0 2005/10/05 22:34:32 dbetanco ship $  */
--
/**************************************************************************
 *                                                                        *
 * Name       : Validate_TRN_Custom                                       *
 * Purpose    : Returns 1 if the user includes any custom validation      *
 *                                                                        *
 **************************************************************************/
FUNCTION VALIDATE_TRN_CUSTOM(p_trn               IN VARCHAR2,
                            p_trn_type          IN VARCHAR2,
                            p_check_unique_flag IN VARCHAR2,
                            p_country_code      IN  VARCHAR2,
                            p_return_status     OUT NOCOPY VARCHAR2,
                            p_error_buffer      OUT NOCOPY VARCHAR2)
   RETURN NUMBER;

END ZX_TRN_CUSTOM_VAL_PKG;

 

/
