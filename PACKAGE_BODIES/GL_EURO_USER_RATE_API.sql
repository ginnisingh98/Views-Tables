--------------------------------------------------------
--  DDL for Package Body GL_EURO_USER_RATE_API
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."GL_EURO_USER_RATE_API" AS
/* $Header: glusteub.pls 120.3 2005/05/05 01:44:44 kvora ship $ */


  ---
  --- PUBLIC FUNCTIONS
  ---

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
  FUNCTION allow_direct_entry  RETURN VARCHAR2 IS
  BEGIN
    RETURN(nvl(fnd_profile.value('GL_ALLOW_USER_RATE_BETWEEN_EMU_AND_NONEMU'),
           'Y'));
  END allow_direct_entry;

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
                x_conversion_type               VARCHAR2 ) RETURN VARCHAR2 IS
    x_relationship  VARCHAR2(50);
    x_fixed_rate    BOOLEAN;
  BEGIN
    IF (gl_euro_user_rate_api.allow_direct_entry <> 'N') THEN
      RETURN('N');
    END IF;

    IF (x_conversion_type <> 'User') THEN
      RETURN('N');
    END IF;

    gl_currency_api.get_relation(
      x_from_currency,
      x_to_currency,
      trunc(x_conversion_date),
      x_fixed_rate,
      x_relationship);

    IF (x_relationship IN ('EMU-OTHER', 'OTHER-EMU')) THEN
      RETURN('Y');
    ELSE
      RETURN('N');
    END IF;
  EXCEPTION
    WHEN gl_currency_api.INVALID_CURRENCY THEN
      RAISE INVALID_CURRENCY;
  END is_cross_rate;


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
                x_euro_to_emu_rate              IN OUT NOCOPY NUMBER ) IS
    x_relationship  VARCHAR2(50);
    x_fixed_rate    BOOLEAN;
    euro_code       VARCHAR2(15);
  BEGIN
    gl_currency_api.get_relation(
      x_from_currency,
      x_to_currency,
      trunc(x_conversion_date),
      x_fixed_rate,
      x_relationship);

    euro_code := gl_currency_api.get_euro_code;

    IF (x_relationship = 'EMU-OTHER') THEN
      fnd_message.set_name('SQLGL', 'GL_GLXFCMDR_CURRENCY');
      fnd_message.set_token('CURRENCY1', euro_code);
      fnd_message.set_token('CURRENCY2', x_to_currency);
      x_euro_to_other_prompt := substrb(fnd_message.get, 1, 30);

      fnd_message.set_name('SQLGL', 'GL_GLXFCMDR_CURRENCY');
      fnd_message.set_token('CURRENCY1', euro_code);
      fnd_message.set_token('CURRENCY2', x_from_currency);
      x_euro_to_emu_prompt := substrb(fnd_message.get, 1, 30);

      fnd_message.set_name('SQLGL', 'GL_GLXFCMDR_CURRENCY');
      fnd_message.set_token('CURRENCY1', x_from_currency);
      fnd_message.set_token('CURRENCY2', x_to_currency);
      x_emu_to_other_prompt := substrb(fnd_message.get, 1, 30);

      x_euro_to_emu_rate := gl_currency_api.get_rate(
                               euro_code,
                               x_from_currency,
                               trunc(x_conversion_date),
                               NULL);

    ELSIF (x_relationship = 'OTHER-EMU') THEN
      fnd_message.set_name('SQLGL', 'GL_GLXFCMDR_CURRENCY');
      fnd_message.set_token('CURRENCY1', x_from_currency);
      fnd_message.set_token('CURRENCY2', euro_code);
      x_euro_to_other_prompt := substrb(fnd_message.get, 1, 30);

      fnd_message.set_name('SQLGL', 'GL_GLXFCMDR_CURRENCY');
      fnd_message.set_token('CURRENCY1', euro_code);
      fnd_message.set_token('CURRENCY2', x_to_currency);
      x_euro_to_emu_prompt := substrb(fnd_message.get, 1, 30);

      fnd_message.set_name('SQLGL', 'GL_GLXFCMDR_CURRENCY');
      fnd_message.set_token('CURRENCY1', x_from_currency);
      fnd_message.set_token('CURRENCY2', x_to_currency);
      x_emu_to_other_prompt := substrb(fnd_message.get, 1, 30);

      x_euro_to_emu_rate := gl_currency_api.get_rate(
                               euro_code,
                               x_to_currency,
                               trunc(x_conversion_date),
                               NULL);
    ELSE
      RAISE INVALID_RELATION;
    END IF;
  EXCEPTION
    WHEN gl_currency_api.INVALID_CURRENCY THEN
      RAISE INVALID_CURRENCY;
  END get_prompts_and_rate;

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
                x_euro_to_emu_rate              NUMBER ) RETURN NUMBER IS
    x_relationship  VARCHAR2(50);
    x_fixed_rate    BOOLEAN;
  BEGIN
    gl_currency_api.get_relation(
      x_from_currency,
      x_to_currency,
      trunc(x_conversion_date),
      x_fixed_rate,
      x_relationship);

    IF (x_relationship = 'EMU-OTHER') THEN
      RETURN (x_euro_to_other_rate / x_euro_to_emu_rate);
    ELSIF (x_relationship = 'OTHER-EMU') THEN
      RETURN (x_euro_to_other_rate * x_euro_to_emu_rate);
    ELSE
      RAISE INVALID_RELATION;
    END IF;
  EXCEPTION
    WHEN gl_currency_api.INVALID_CURRENCY THEN
      RAISE INVALID_CURRENCY;
  END get_cross_rate;

END gl_euro_user_rate_api;


/
