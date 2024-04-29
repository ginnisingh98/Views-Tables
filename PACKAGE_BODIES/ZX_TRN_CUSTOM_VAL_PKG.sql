--------------------------------------------------------
--  DDL for Package Body ZX_TRN_CUSTOM_VAL_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."ZX_TRN_CUSTOM_VAL_PKG" AS
 /* $Header: zxccusvb.pls 120.1 2005/10/06 00:13:40 dbetanco ship $  */
--
FUNCTION VALIDATE_TRN_CUSTOM(p_trn               IN VARCHAR2,
                             p_trn_type          IN VARCHAR2,
                             p_check_unique_flag IN VARCHAR2,
                             p_country_code      IN  VARCHAR2,
                             p_return_status     OUT NOCOPY VARCHAR2,
                             p_error_buffer      OUT NOCOPY VARCHAR2)
   RETURN NUMBER
   AS
BEGIN
-- Please enter all custom code below this line.
-- Begin Custom Code

-- output parameters
-- p_return_status := FND_API.G_RET_STS_SUCCESS;
-- p_error_buffer  := NULL;
-- Returning zero
   Return(0);
-- End Custom Code

END VALIDATE_TRN_CUSTOM;
END ZX_TRN_CUSTOM_VAL_PKG;

/
