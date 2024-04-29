--------------------------------------------------------
--  DDL for Package Body HR_JP_PARAMETERS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."HR_JP_PARAMETERS_PKG" as
/* $Header: hrjpparm.pkb 115.2 99/07/17 16:38:46 porting ship $ */
--------------------------------------------------------------------------------
	FUNCTION get_parameter_value(
			p_owner			IN VARCHAR2,
			p_parameter_name	IN VARCHAR2) RETURN VARCHAR2
--------------------------------------------------------------------------------
	IS
		l_parameter_value	HR_JP_PARAMETERS.PARAMETER_VALUE%TYPE;
		CURSOR csr_parameter_value IS
			select	parameter_value
			from	hr_jp_parameters
			where	owner=p_owner
			and	parameter_name=p_parameter_name;
	BEGIN
		open csr_parameter_value;
		fetch csr_parameter_value into l_parameter_value;
		if csr_parameter_value%NOTFOUND then
			l_parameter_value := NULL;
		end if;
		close csr_parameter_value;

		return l_parameter_value;
	END;
--------------------------------------------------------------------------------
	PROCEDURE put_parameter_value(
			p_owner			IN VARCHAR2,
			p_parameter_name	IN VARCHAR2,
			p_parameter_value	IN VARCHAR2)
--------------------------------------------------------------------------------
	IS
		l_rowid	ROWID;
		CURSOR csr_rowid IS
			select	rowid
			from	hr_jp_parameters
			where	owner=p_owner
			and	parameter_name=p_parameter_name
			for update nowait;
	BEGIN
		open csr_rowid;
		fetch csr_rowid into l_rowid;
		if csr_rowid%NOTFOUND then
			l_rowid := NULL;
		end if;
		close csr_rowid;

		if l_rowid is not NULL then
			update	hr_jp_parameters
			set	parameter_value=p_parameter_value
			where	rowid=l_rowid;
		else
			insert into HR_JP_PARAMETERS(
				OWNER,
				PARAMETER_NAME,
				PARAMETER_VALUE)
			values(	p_owner,
				p_parameter_name,
				p_parameter_value);
		end if;
	END;
end;

/
