--------------------------------------------------------
--  DDL for Package Body CS_CHMC_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."CS_CHMC_PKG" as
/*$Header: csxchmcb.pls 115.3.1158.2 2003/03/13 02:56:36 aseethep ship $*/

PROCEDURE convert_amount(
			p_from_currency		IN	varchar2,
			p_amount				IN	number,
			p_conversion_date		IN	date,
			p_conversion_type		IN	varchar2,
			p_user_rate			IN	number,
			x_converted_amount		OUT	number) IS
p_set_of_books_id				number;
s_to_currency 					varchar2(30);
s_conversion_date				date;
s_conversion_type				varchar2(30);
f_currency_code				varchar2(30);
result						number;
x_to_currency					varchar2(30);
INVALID_USER_CURRENCY_CODE		exception;
INVALID_MC_CONVERSION_TYPE		exception;
NO_RATE						exception;
INVALID_CURRENCY				exception;
INVALID_USER_RATE				exception;

BEGIN

-- get the set_of_books_id

p_set_of_books_id := fnd_profile.value('GL_SET_OF_BKS_ID');

-- Get functional currency using the set of books id.

		SELECT currency_code
		INTO f_currency_code
		FROM GL_SETS_OF_BOOKS
		WHERE set_of_books_id = p_set_of_books_id;

	IF f_currency_code is NULL THEN
		RAISE INVALID_USER_CURRENCY_CODE;
	ELSE
		s_to_currency := f_currency_code;
	END IF;

IF p_from_currency = s_to_currency THEN
	x_converted_amount:=p_amount;
	x_to_currency :=s_to_currency;
	return;
END IF;

IF p_conversion_date IS NULL THEN
		s_conversion_date := sysdate;
ELSE
		s_conversion_date := p_conversion_date;
END IF;

IF   p_conversion_type IS NULL THEN
	s_conversion_type:=fnd_profile.value('CS_MC_CONVERSION_TYPE');
	IF s_conversion_type IS NULL THEN
		RAISE INVALID_MC_CONVERSION_TYPE;
	END IF;
ELSE
	s_conversion_type := p_conversion_type;
END IF;

IF  s_conversion_type = 'User' THEN
    	IF p_user_rate IS NULL THEN
		RAISE INVALID_USER_RATE;
	END IF;
END IF;

-- call the gl package to convert the amount

result := gl_currency_api.convert_closest_amount_sql
	(p_from_currency,s_to_currency,s_conversion_date,s_conversion_type,
	 p_user_rate,p_amount,30);

IF result = -1 THEN
	RAISE NO_RATE;
ELSIF result = -2 THEN
	RAISE INVALID_CURRENCY;
END IF;

x_converted_amount := result;
x_to_currency:=s_to_currency;

EXCEPTION WHEN INVALID_USER_CURRENCY_CODE THEN
		fnd_message.set_name('CS','CS_INVALID_USER_CURRENCY_CODE');
		app_exception.raise_exception;
	  	WHEN INVALID_MC_CONVERSION_TYPE THEN
		fnd_message.set_name('CS','CS_INVALID_MC_CONVERSION_TYPE');
		app_exception.raise_exception;
	  	WHEN NO_RATE THEN
		fnd_message.set_name('CS','CS_NO_RATE');
		fnd_message.set_token('CODE1',p_from_currency);
		fnd_message.set_token('CODE2',s_to_currency);
		fnd_message.set_token('DATE',s_conversion_date);
		fnd_message.set_token('TYPE',s_conversion_type);
		app_exception.raise_exception;
	  	WHEN INVALID_CURRENCY THEN
		fnd_message.set_name('CS','CS_INVALID_CURRENCY');
		fnd_message.set_token('CODE1',p_from_currency);
		fnd_message.set_token('CODE2',s_to_currency);
		app_exception.raise_exception;
	  	WHEN INVALID_USER_RATE THEN
		fnd_message.set_name('CS','CS_INVALID_USER_RATE');
		app_exception.raise_exception;

END convert_amount;

END cs_chmc_pkg;

/
