--------------------------------------------------------
--  DDL for Package GL_EURO_USER_RATE_API
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."GL_EURO_USER_RATE_API" AUTHID CURRENT_USER AS
/* $Header: glusteus.pls 120.3 2005/05/05 01:44:50 kvora ship $ */
--
-- Package
--   gl_euro_user_rate_api
--
-- Purpose
--
--   This package will provide PL/SQL APIs for the following purposes:
--   o Determine if the customer is allowed to directly enter EMU -> OTHER
--     and OTHER -> EMU rates
--   o Determine if the current conversion type is User, the customer is not
--     allowed to directly enter EMU -> OTHER and OTHER -> EMU rates, and this
--     is such a situation
--   o Get the prompts to be used from EURO -> OTHER (or OTHER -> EURO),
--     EURO -> EMU, and EMU -> OTHER (or OTHER -> EMU) and the rate
--     from EURO -> EMU
--
-- History
--   20-MAY-99 	D J Ogg		Created
--

  --
  -- User defined exceptions for gl_euro_user_rate_api:
  -- o INVALID_CURRENCY - One of the two currencies is invalid.
  INVALID_CURRENCY 	EXCEPTION;
  INVALID_RELATION      EXCEPTION;

  --
  -- Function
  --   allow_direct_entry
  --
  -- Purpose
  -- 	Returns 'Y' if the customer is allowed to directly enter EMU -> OTHER
  --                and OTHER -> EMU rates
  --            'N' otherwise.
  --
  -- History
  --   20-MAY-99  D J Ogg 	Created
  --
  -- Arguments
  --   * None *
  FUNCTION allow_direct_entry  RETURN VARCHAR2;

  --
  -- Procedure
  --   is_cross_rate
  --
  -- Purpose
  -- 	Returns 'Y' if the current conversion type is User AND
  --                they are converting from EMU -> OTHER or OTHER -> EMU AND
  --                they are not allowed to enter EMU -> OTHER and
  --                OTHER -> EMU rates directly
  --    Returns 'N' Otherwise
  --
  -- History
  --   20-MAY-99  D J Ogg 	Created
  --
  -- Arguments
  --   x_from_currency		From currency
  --   x_to_currency 		To currency
  --   x_conversion_date	Conversion date
  --   x_conversion_type        Conversion Type
  --
  FUNCTION is_cross_rate(
		x_from_currency			VARCHAR2,
		x_to_currency			VARCHAR2,
		x_conversion_date		DATE,
                x_conversion_type               VARCHAR2 ) RETURN VARCHAR2;

  --
  -- Procedure
  --   get_prompts_and_rate
  --
  -- Purpose
  -- 	Returns the prompts to use for EURO -> OTHER (or OTHER -> EURO),
  --    EURO -> EMU, and EMU -> OTHER (or OTHER -> EMU) and the
  --    rate from EURO -> EMU
  --
  -- History
  --   20-MAY-99  D J Ogg 	Created
  --
  -- Arguments
  --   x_from_currency		From currency
  --   x_to_currency 		To currency
  --   x_conversion_date	Conversion date
  --   x_euro_to_other_prompt   EURO -> OTHER prompt
  --   x_euro_to_emu_prompt     EURO -> EMU prompt
  --   x_emu_to_other_prompt    EMU -> OTHER prompt
  --   x_euro_to_emu_rate       EURO -> EMU rate
  --
  PROCEDURE get_prompts_and_rate(
		x_from_currency			       VARCHAR2,
		x_to_currency			       VARCHAR2,
		x_conversion_date		       DATE,
                x_euro_to_other_prompt          IN OUT NOCOPY VARCHAR2,
                x_euro_to_emu_prompt            IN OUT NOCOPY VARCHAR2,
                x_emu_to_other_prompt           IN OUT NOCOPY VARCHAR2,
                x_euro_to_emu_rate              IN OUT NOCOPY NUMBER );

  --
  -- Procedure
  --   get_cross_rate
  --
  -- Purpose
  -- 	Given the EURO -> OTHER or OTHER -> EURO rate the user has entered
  --    and the EURO -> EMU rate, returns the EMU -> OTHER or OTHER -> EMU
  --    rate
  --
  -- History
  --   20-MAY-99  D J Ogg 	Created
  --
  -- Arguments
  --   x_from_currency		From currency
  --   x_to_currency 		To currency
  --   x_conversion_date        Conversion date
  --   x_euro_to_other_rate     EURO -> OTHER or OTHER -> EURO rate
  --   x_euro_to_emu_rate       EURO -> EMU rate
  --
  FUNCTION get_cross_rate(
		x_from_currency			VARCHAR2,
		x_to_currency			VARCHAR2,
                x_conversion_date               DATE,
                x_euro_to_other_rate            NUMBER,
                x_euro_to_emu_rate              NUMBER ) RETURN NUMBER;

 END gl_euro_user_rate_api;

 

/
