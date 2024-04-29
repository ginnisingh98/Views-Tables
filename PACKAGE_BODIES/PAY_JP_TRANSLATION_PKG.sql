--------------------------------------------------------
--  DDL for Package Body PAY_JP_TRANSLATION_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PAY_JP_TRANSLATION_PKG" AS
/* $Header: pyjptrns.pkb 115.2 99/07/17 06:14:04 porting ship $ */
	FUNCTION user_name(
			p_lookup_type	IN VARCHAR2,
			p_lookup_code	IN VARCHAR2) RETURN VARCHAR2
	IS
		l_user_name	HR_LOOKUPS.MEANING%TYPE;
		CURSOR csr_user_name IS
			select	meaning
			from	hr_lookups
			where	lookup_type=p_lookup_type
			and	lookup_code=p_lookup_code;
	BEGIN
		open csr_user_name;
		fetch csr_user_name into l_user_name;
		if csr_user_name%NOTFOUND then
			l_user_name := NULL;
		end if;
		close csr_user_name;

		return l_user_name;
	END;
--
	FUNCTION element_name(
			p_system_name	IN VARCHAR2) RETURN VARCHAR2
	IS
		l_element_name	PAY_ELEMENT_TYPES_F.ELEMENT_NAME%TYPE;
	BEGIN
		l_element_name := user_name('JP_ELM_TL',p_system_name);

		return l_element_name;
	END element_name;
--
	FUNCTION input_value_name(
			p_system_element_name		IN VARCHAR2,
			p_system_input_value_name	IN VARCHAR2) RETURN VARCHAR2
	IS
		l_input_value_name	PAY_INPUT_VALUES_F.NAME%TYPE;
	BEGIN
		l_input_value_name := user_name(p_system_element_name,p_system_input_value_name);

		return l_input_value_name;
	END input_value_name;
--
	FUNCTION balance_name(
			p_system_name	IN VARCHAR2) RETURN VARCHAR2
	IS
		l_balance_name	PAY_BALANCE_TYPES.BALANCE_NAME%TYPE;
	BEGIN
		l_balance_name := user_name('JP_BAL_TL',p_system_name);

		return l_balance_name;
	END balance_name;
--
	FUNCTION dimension_name(
			p_system_name	IN VARCHAR2) RETURN VARCHAR2
	IS
		l_dimension_name	PAY_BALANCE_DIMENSIONS.DIMENSION_NAME%TYPE;
	BEGIN
		l_dimension_name := user_name('JP_DIM_TL',p_system_name);

		return l_dimension_name;
	END dimension_name;
END PAY_JP_TRANSLATION_PKG;

/
