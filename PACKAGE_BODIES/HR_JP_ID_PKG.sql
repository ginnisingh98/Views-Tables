--------------------------------------------------------
--  DDL for Package Body HR_JP_ID_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."HR_JP_ID_PKG" as
/* $Header: hrjpid.pkb 120.0 2005/05/30 20:58:09 appldev noship $ */
	TYPE UnqColRecTyp IS RECORD(
			name			VARCHAR2(255),
			value			VARCHAR2(255));
	TYPE UniColTbl IS TABLE OF UnqColRecTyp INDEX BY BINARY_INTEGER;
	TYPE RefCsr IS REF CURSOR;
	C_CHR_LF		CONSTANT VARCHAR2(5) := fnd_global.local_chr(10);
	g_bg_rec_cache		PER_BUSINESS_GROUPS%ROWTYPE;
	g_sql			VARCHAR2(32767);
--------------------------------------------------------------------------------
	FUNCTION LATEST_SQL RETURN VARCHAR2
--------------------------------------------------------------------------------
	IS
	BEGIN
		return g_sql;
	END;
--------------------------------------------------------------------------------
-- Internal Functions
--------------------------------------------------------------------------------
-- In case of DATETRACKED and DATED with p_effective_date is NULL,
-- this function returns multiple records(cursor variable).
-- If you want to return unique record with DATETRACKED and DATED,
-- pass p_effective_date with non-null value.
	FUNCTION CSR(
			p_base_table			IN VARCHAR2,
			p_unique_column_tbl		IN UniColTbl,
			p_date_track_type		IN VARCHAR2	DEFAULT 'NONE',--'DATETRACKED','DATED','NONE'
			p_effective_date		IN DATE		DEFAULT hr_api.g_sys) RETURN RefCsr
--------------------------------------------------------------------------------
	IS
		l_csr			RefCsr;
		l_id			NUMBER;
		l_index			NUMBER;
		l_where_prefix		VARCHAR2(10) := 'where	';
		l_operand		VARCHAR2(10);
	BEGIN
		g_sql	:= 'select * from ' || p_base_table;

		l_index := p_unique_column_tbl.first;
		while l_index is not NULL loop
			if p_unique_column_tbl(l_index).value is NULL then
				l_operand := ' is ';
			else
				l_operand := ' = ';
			end if;

			g_sql :=	g_sql || C_CHR_LF ||
					l_where_prefix || p_unique_column_tbl(l_index).name || l_operand || nvl(p_unique_column_tbl(l_index).value,'NULL');

			l_where_prefix := 'and	';
			l_index := p_unique_column_tbl.next(l_index);
		end loop;

		BEGIN
			-- In case of DATETRACKED and DATED with effective_date is NULL,
			-- it's possibly returns multiple records.
			if p_date_track_type = 'DATETRACKED' then
				if p_effective_date is not NULL then
					g_sql :=	g_sql || C_CHR_LF ||
							l_where_prefix || ':b_effective_date between effective_start_date and effective_end_date' || C_CHR_LF ||
							'order by effective_start_date';
					open l_csr for g_sql using p_effective_date;
				else
					g_sql :=	g_sql || C_CHR_LF ||
							'order by effective_start_date';
					open l_csr for g_sql;
				end if;
			elsif p_date_track_type = 'DATED' then
				if p_effective_date is not NULL then
					g_sql :=	g_sql || C_CHR_LF ||
							l_where_prefix || ':b_effective_date between date_from and nvl(date_to,:b_effective_date)' || C_CHR_LF ||
							'order by date_from';
					open l_csr for g_sql using p_effective_date,p_effective_date;
				else
					g_sql :=	g_sql || C_CHR_LF ||
							'order by date_from';
					open l_csr for g_sql;
				end if;
			else
				open l_csr for g_sql;
			end if;
		EXCEPTION
			when others then
				fnd_message.set_name('PER','HR_JP_INVALID_SQL_STATMENT');
				fnd_message.set_token('SQL',g_sql);
				fnd_message.raise_error;
		END;

		return l_csr;
	END;
--------------------------------------------------------------------------------
	FUNCTION csr_found_and_close(
			p_csr			IN RefCsr,
			p_error_when_not_exist	IN VARCHAR2 DEFAULT 'TRUE') RETURN BOOLEAN
--------------------------------------------------------------------------------
	IS
		l_found	BOOLEAN;
	BEGIN
		if p_csr%NOTFOUND then
			l_found := FALSE;
			if p_error_when_not_exist = 'TRUE' then
				close p_csr;
				fnd_message.set_name('PER','HR_JP_ID_NOT_FOUND');
				fnd_message.set_token('SQL',g_sql);
				fnd_message.raise_error;
			end if;
		else
			l_found := TRUE;
		end if;
		close p_csr;

		return l_found;
	END;
--------------------------------------------------------------------------------
	PROCEDURE unique_tbl_constructor(
			p_name				IN VARCHAR2,
			p_data_type			IN VARCHAR2,
			p_value				IN VARCHAR2,
			p_unique_column_tbl		IN OUT NOCOPY UniColTbl)
--------------------------------------------------------------------------------
	IS
		l_index	NUMBER := nvl(p_unique_column_tbl.last,0) + 1;
	BEGIN
		p_unique_column_tbl(l_index).name := p_name;
		if p_value is NULL then
			p_unique_column_tbl(l_index).value := NULL;
		else
			if p_data_type = 'T' then
				p_unique_column_tbl(l_index).value	:= '''' || p_value || '''';
			elsif p_data_type = 'D' then
				p_unique_column_tbl(l_index).value	:= 'to_date(''' || p_value || ''',''YYYY/MM/DD'')';
			else
				p_unique_column_tbl(l_index).value	:= p_value;
			end if;
		end if;
	END;
--------------------------------------------------------------------------------
	PROCEDURE bus_leg_constructor(
			p_business_group_id		IN NUMBER,
			p_legislation_code		IN VARCHAR2,
			p_unique_column_tbl		IN OUT NOCOPY UniColTbl)
--------------------------------------------------------------------------------
	IS
		l_legislation_code	VARCHAR2(2);
		PROCEDURE raise_error
		IS
		BEGIN
			fnd_message.set_name('PER','HR_JP_INVALID_ARGUMENT');
			fnd_message.set_token('PROCEDURE','hr_jp_id_pkg.construct_bus_leg_where_clause');
			fnd_message.raise_error;
		END;
	BEGIN
		if p_business_group_id = C_DEFAULT_BUS then
			-- p_business_group_id p_legislation_code description
			-- -------------------+------------------+------------------------
			-- DEFAULTED           DEFAULTED          Available for any BG, LG
			-- DEFAULTED           NULL               Error
			-- DEFAULTED           JP                 Available for BG in 'JP'
			-- -------------------+------------------+------------------------
			if p_legislation_code = C_DEFAULT_LEG then
				NULL;
			elsif p_legislation_code is NULL then
				raise_error;
			else
				unique_tbl_constructor('nvl(nvl(legislation_code,hr_jp_id_pkg.legislation_code(business_group_id,''FALSE'')),''' || p_legislation_code || ''')','T',p_legislation_code,p_unique_column_tbl);
			end if;
		elsif p_business_group_id is NULL then
			-- p_business_group_id p_legislation_code description
			-- -------------------+------------------+------------------------
			-- NULL                DEFAULTED          Error
			-- NULL                JP                 Available for LG='JP'
			-- NULL                NULL               As it is
			-- -------------------+------------------+------------------------
			if p_legislation_code = C_DEFAULT_LEG then
				raise_error;
			elsif p_legislation_code is not NULL then
				unique_tbl_constructor('business_group_id','N',to_char(p_business_group_id),p_unique_column_tbl);
				unique_tbl_constructor('nvl(legislation_code,''' || p_legislation_code || ''')','T',p_legislation_code,p_unique_column_tbl);
			else
				unique_tbl_constructor('business_group_id','N',to_char(p_business_group_id),p_unique_column_tbl);
				unique_tbl_constructor('legislation_code','T',p_legislation_code,p_unique_column_tbl);
			end if;
		else
			-- p_business_group_id p_legislation_code description
			-- -------------------+------------------+------------------------
			-- 101                 NULL               Available for BUG=101
			-- 101                 DEFAULTED          Available for BUG=101
			-- 101                 JP                 Error
			-- -------------------+------------------+------------------------
			if nvl(p_legislation_code,C_DEFAULT_LEG) = C_DEFAULT_LEG then
				l_legislation_code := legislation_code(p_business_group_id);
				unique_tbl_constructor('nvl(business_group_id,' || to_char(p_business_group_id) || ')','N',to_char(p_business_group_id),p_unique_column_tbl);
				unique_tbl_constructor('nvl(legislation_code,''' || l_legislation_code || ''')','T',l_legislation_code,p_unique_column_tbl);
			else
				raise_error;
			end if;
		end if;
	END;
--------------------------------------------------------------------------------
	FUNCTION CSR_WITH_BUS_LEG(
			p_base_table			IN VARCHAR2,
			p_unique_column			IN VARCHAR2,
			p_unique_column_data_type	IN VARCHAR2 DEFAULT 'T',
			p_unique_column_value		IN VARCHAR2,
			p_business_group_id		IN NUMBER	DEFAULT NULL,
			p_legislation_code		IN VARCHAR2	DEFAULT NULL,
			p_date_track_type		IN VARCHAR2	DEFAULT 'NONE',
			p_effective_date		IN DATE		DEFAULT hr_api.g_sys) RETURN RefCsr
--------------------------------------------------------------------------------
	IS
		l_unique_column_tbl	UniColTbl;
	BEGIN
		unique_tbl_constructor(p_unique_column,p_unique_column_data_type,p_unique_column_value,l_unique_column_tbl);
		bus_leg_constructor(p_business_group_id,p_legislation_code,l_unique_column_tbl);

		return csr(p_base_table,l_unique_column_tbl,p_date_track_type,p_effective_date);
	END;
--------------------------------------------------------------------------------
	FUNCTION CSR_WITH_BUS(
			p_base_table			IN VARCHAR2,
			p_unique_column			IN VARCHAR2,
			p_unique_column_data_type	IN VARCHAR2 DEFAULT 'T',
			p_unique_column_value		IN VARCHAR2,
			p_business_group_id		IN NUMBER,
			p_date_track_type		IN VARCHAR2	DEFAULT 'NONE',
			p_effective_date		IN DATE		DEFAULT hr_api.g_sys) RETURN RefCsr
--------------------------------------------------------------------------------
	IS
		l_unique_column_tbl	UniColTbl;
	BEGIN
		unique_tbl_constructor(p_unique_column,p_unique_column_data_type,p_unique_column_value,l_unique_column_tbl);
		if p_business_group_id is NULL then
			unique_tbl_constructor('business_group_id','N',to_char(p_business_group_id),l_unique_column_tbl);
		elsif p_business_group_id <> C_DEFAULT_BUS then
			unique_tbl_constructor('nvl(business_group_id,' || to_char(p_business_group_id) || ')','N',to_char(p_business_group_id),l_unique_column_tbl);
		end if;

		return csr(p_base_table,l_unique_column_tbl,p_date_track_type,p_effective_date);
	END;
--------------------------------------------------------------------------------
	FUNCTION keyflex_combination_id(
			p_appl_short_name		IN VARCHAR2,
			p_id_flex_code			IN VARCHAR2,
			p_id_flex_num			IN NUMBER,
			p_concatenated_segments		IN VARCHAR2,
			p_error_when_not_exist		IN VARCHAR2	DEFAULT 'TRUE') RETURN NUMBER
--------------------------------------------------------------------------------
	IS
		l_valid				BOOLEAN;
		l_keyflex_combination_id	NUMBER;
	BEGIN
		l_valid := fnd_flex_keyval.validate_segs(
					OPERATION		=> 'FIND_COMBINATION',
					APPL_SHORT_NAME		=> p_appl_short_name,
					KEY_FLEX_CODE		=> p_id_flex_code,
					STRUCTURE_NUMBER	=> p_id_flex_num,
					CONCAT_SEGMENTS		=> p_concatenated_segments,
					VALUES_OR_IDS		=> 'I');

		if l_valid then
			l_keyflex_combination_id := fnd_flex_keyval.combination_id;
		else
			if p_error_when_not_exist = 'TRUE' then
				fnd_message.raise_error;
			else
				l_keyflex_combination_id := NULL;
			end if;
		end if;

		return l_keyflex_combination_id;
	END;
--------------------------------------------------------------------------------
	FUNCTION business_group_rec(
			p_business_group_id		IN NUMBER,
			p_error_when_not_exist		IN VARCHAR2	DEFAULT 'TRUE') RETURN PER_BUSINESS_GROUPS%ROWTYPE
--------------------------------------------------------------------------------
	IS
		l_unique_column_tbl	UniColTbl;
		l_csr			RefCsr;
		l_rec			PER_BUSINESS_GROUPS%ROWTYPE;
	BEGIN
		if p_business_group_id is NULL then
			if p_error_when_not_exist = 'TRUE' then
				fnd_message.set_name('PER','HR_JP_ID_NOT_FOUND');
				fnd_message.raise_error;
			end if;

			return l_rec;
		else
			if g_bg_rec_cache.business_group_id = p_business_group_id then
				NULL;
			else
				unique_tbl_constructor('BUSINESS_GROUP_ID','N',to_char(p_business_group_id),l_unique_column_tbl);
				l_csr := csr('PER_BUSINESS_GROUPS',l_unique_column_tbl);
				fetch l_csr into l_rec;
				if not csr_found_and_close(l_csr,p_error_when_not_exist) then
					l_rec := NULL;
				end if;

				g_bg_rec_cache := l_rec;
			end if;
		end if;

		return g_bg_rec_cache;
	END;
--------------------------------------------------------------------------------
	FUNCTION legislation_code(
			p_business_group_id		IN NUMBER,
			p_error_when_not_exist		IN VARCHAR2	DEFAULT 'TRUE') RETURN VARCHAR2
--------------------------------------------------------------------------------
	IS
		l_rec	PER_BUSINESS_GROUPS%ROWTYPE;
	BEGIN
		l_rec := business_group_rec(p_business_group_id,p_error_when_not_exist);

		return l_rec.legislation_code;
	END;
--------------------------------------------------------------
	FUNCTION id_flex_num(
			p_business_group_id		IN NUMBER,
			p_id_flex_code			IN VARCHAR2,
			p_error_when_not_exist		IN VARCHAR2	DEFAULT 'TRUE') RETURN NUMBER
--------------------------------------------------------------------------------
	IS
--		POS	Position Key Flexfield(800)
--		GRD	Grade Key Flexfield(800)
--		JOB	Job Key Flexfield(800)
--		COST	Costing Key Flexfield(801)
--		GRP	People Group Key Flexfield(801)
		l_rec		PER_BUSINESS_GROUPS%ROWTYPE;
		l_id_flex_num	NUMBER;
	BEGIN
		l_rec := business_group_rec(p_business_group_id,p_error_when_not_exist);

		if p_id_flex_code = 'POS' then
			l_id_flex_num := to_number(l_rec.position_structure);
		elsif p_id_flex_code = 'GRD' then
			l_id_flex_num := to_number(l_rec.grade_structure);
		elsif p_id_flex_code = 'JOB' then
			l_id_flex_num := to_number(l_rec.job_structure);
		elsif p_id_flex_code = 'COST' then
			l_id_flex_num := to_number(l_rec.cost_allocation_structure);
		elsif p_id_flex_code = 'GRP' then
			l_id_flex_num := to_number(l_rec.people_group_structure);
		else
			fnd_message.set_name('PER','HR_JP_INVALID_PARAMETER');
			fnd_message.set_token('PROCEDURE','hr_jp_id_pkg.id_flex_num');
			fnd_message.set_token('PARAMETER',p_id_flex_code);
			fnd_message.raise_error;
		end if;

		return l_id_flex_num;
	END;
--------------------------------------------------------------------------------
	FUNCTION default_currency_code(
			p_business_group_id		IN NUMBER,
			p_error_when_not_exist		IN VARCHAR2	DEFAULT 'TRUE') RETURN VARCHAR2
--------------------------------------------------------------------------------
	IS
		l_rec	PER_BUSINESS_GROUPS%ROWTYPE;
	BEGIN
		l_rec := business_group_rec(p_business_group_id,p_error_when_not_exist);

		return l_rec.currency_code;
	END;
--------------------------------------------------------------------------------
	FUNCTION default_currency_code(
			p_legislation_code		IN VARCHAR2,
			p_error_when_not_exist		IN VARCHAR2	DEFAULT 'TRUE') RETURN VARCHAR2
--------------------------------------------------------------------------------
	IS
		l_currency_code	FND_CURRENCIES.CURRENCY_CODE%TYPE;
		CURSOR csr_currency_code IS
			select	currency_code
			from	fnd_currencies
			where	issuing_territory_code = p_legislation_code;
	BEGIN
		open csr_currency_code;
		fetch csr_currency_code into l_currency_code;
		if csr_currency_code%NOTFOUND then
			if p_error_when_not_exist = 'TRUE' then
				close csr_currency_code;
				fnd_message.set_name('PER','HR_JP_ID_NOT_FOUND');
				fnd_message.raise_error;
			end if;
		end if;
		close csr_currency_code;

		return l_currency_code;
	END;
--------------------------------------------------------------------------------
-- ID with BUSINESS_GROUP_ID and LEGISLATION_CODE
--------------------------------------------------------------------------------
	FUNCTION element_set_rec(
			p_element_set_name		IN VARCHAR2,
			p_business_group_id		IN NUMBER	DEFAULT NULL,
			p_legislation_code		IN VARCHAR2	DEFAULT NULL,
			p_error_when_not_exist		IN VARCHAR2	DEFAULT 'TRUE') RETURN PAY_ELEMENT_SETS%ROWTYPE
--------------------------------------------------------------------------------
	IS
		l_csr			RefCsr;
		l_rec			PAY_ELEMENT_SETS%ROWTYPE;
	BEGIN
		l_csr := csr_with_bus_leg('PAY_ELEMENT_SETS','ELEMENT_SET_NAME','T',p_element_set_name,p_business_group_id,p_legislation_code);
		fetch l_csr into l_rec;
		if not csr_found_and_close(l_csr,p_error_when_not_exist) then
			l_rec := NULL;
		end if;

		return l_rec;
	END;
--------------------------------------------------------------------------------
	FUNCTION element_set_id(
			p_element_set_name		IN VARCHAR2,
			p_business_group_id		IN NUMBER	DEFAULT NULL,
			p_legislation_code		IN VARCHAR2	DEFAULT NULL,
			p_error_when_not_exist		IN VARCHAR2	DEFAULT 'TRUE') RETURN NUMBER
--------------------------------------------------------------------------------
	IS
	BEGIN
		return element_set_rec(p_element_set_name,p_business_group_id,p_legislation_code,p_error_when_not_exist).element_set_id;
	END;
--------------------------------------------------------------------------------
	FUNCTION backpay_set_rec(
			p_backpay_set_name		IN VARCHAR2,
			p_business_group_id		IN NUMBER	DEFAULT NULL,
			p_legislation_code		IN VARCHAR2	DEFAULT NULL,
			p_error_when_not_exist		IN VARCHAR2	DEFAULT 'TRUE') RETURN PAY_BACKPAY_SETS%ROWTYPE
--------------------------------------------------------------------------------
	IS
		l_csr			RefCsr;
		l_rec			PAY_BACKPAY_SETS%ROWTYPE;
	BEGIN
		l_csr := csr_with_bus_leg('PAY_BACKPAY_SETS','BACKPAY_SET_NAME','T',p_backpay_set_name,p_business_group_id,p_legislation_code);
		fetch l_csr into l_rec;
		if not csr_found_and_close(l_csr,p_error_when_not_exist) then
			l_rec := NULL;
		end if;

		return l_rec;
	END;
--------------------------------------------------------------------------------
	FUNCTION backpay_set_id(
			p_backpay_set_name		IN VARCHAR2,
			p_business_group_id		IN NUMBER	DEFAULT NULL,
			p_legislation_code		IN VARCHAR2	DEFAULT NULL,
			p_error_when_not_exist		IN VARCHAR2	DEFAULT 'TRUE') RETURN NUMBER
--------------------------------------------------------------------------------
	IS
	BEGIN
		return backpay_set_rec(p_backpay_set_name,p_business_group_id,p_legislation_code,p_error_when_not_exist).backpay_set_id;
	END;
--------------------------------------------------------------------------------
	FUNCTION classification_rec(
			p_classification_name		IN VARCHAR2,
			p_business_group_id		IN NUMBER	DEFAULT NULL,
			p_legislation_code		IN VARCHAR2	DEFAULT NULL,
			p_error_when_not_exist		IN VARCHAR2	DEFAULT 'TRUE') RETURN PAY_ELEMENT_CLASSIFICATIONS%ROWTYPE
--------------------------------------------------------------------------------
	IS
		l_csr			RefCsr;
		l_rec			PAY_ELEMENT_CLASSIFICATIONS%ROWTYPE;
	BEGIN
		l_csr := csr_with_bus_leg('PAY_ELEMENT_CLASSIFICATIONS','CLASSIFICATION_NAME','T',p_classification_name,p_business_group_id,p_legislation_code);
		fetch l_csr into l_rec;
		if not csr_found_and_close(l_csr,p_error_when_not_exist) then
			l_rec := NULL;
		end if;

		return l_rec;
	END;
--------------------------------------------------------------------------------
	FUNCTION classification_id(
			p_classification_name		IN VARCHAR2,
			p_business_group_id		IN NUMBER	DEFAULT NULL,
			p_legislation_code		IN VARCHAR2	DEFAULT NULL,
			p_error_when_not_exist		IN VARCHAR2	DEFAULT 'TRUE') RETURN NUMBER
--------------------------------------------------------------------------------
	IS
	BEGIN
		return classification_rec(p_classification_name,p_business_group_id,p_legislation_code,p_error_when_not_exist).classification_id;
	END;
--------------------------------------------------------------------------------
	FUNCTION element_type_rec(
			p_element_name			IN VARCHAR2,
			p_business_group_id		IN NUMBER	DEFAULT NULL,
			p_legislation_code		IN VARCHAR2	DEFAULT NULL,
			p_effective_date		IN DATE		DEFAULT hr_api.g_sys,
			p_error_when_not_exist		IN VARCHAR2	DEFAULT 'TRUE') RETURN PAY_ELEMENT_TYPES_F%ROWTYPE
--------------------------------------------------------------------------------
	IS
		l_csr			RefCsr;
		l_rec			PAY_ELEMENT_TYPES_F%ROWTYPE;
	BEGIN
		l_csr := csr_with_bus_leg('PAY_ELEMENT_TYPES_F','ELEMENT_NAME','T',p_element_name,p_business_group_id,p_legislation_code,'DATETRACKED',p_effective_date);
		fetch l_csr into l_rec;
		if not csr_found_and_close(l_csr,p_error_when_not_exist) then
			l_rec := NULL;
		end if;

		return l_rec;
	END;
--------------------------------------------------------------------------------
	FUNCTION element_type_id(
			p_element_name			IN VARCHAR2,
			p_business_group_id		IN NUMBER	DEFAULT NULL,
			p_legislation_code		IN VARCHAR2	DEFAULT NULL,
			p_error_when_not_exist		IN VARCHAR2	DEFAULT 'TRUE') RETURN NUMBER
--------------------------------------------------------------------------------
	IS
	BEGIN
		return element_type_rec(p_element_name,p_business_group_id,p_legislation_code,NULL,p_error_when_not_exist).element_type_id;
	END;
--------------------------------------------------------------------------------
	FUNCTION balance_type_rec(
			p_balance_name			IN VARCHAR2,
			p_business_group_id		IN NUMBER	DEFAULT NULL,
			p_legislation_code		IN VARCHAR2	DEFAULT NULL,
			p_error_when_not_exist		IN VARCHAR2	DEFAULT 'TRUE') RETURN PAY_BALANCE_TYPES%ROWTYPE
--------------------------------------------------------------------------------
	IS
		l_csr			RefCsr;
		l_rec			PAY_BALANCE_TYPES%ROWTYPE;
	BEGIN
		l_csr := csr_with_bus_leg('PAY_BALANCE_TYPES','BALANCE_NAME','T',p_balance_name,p_business_group_id,p_legislation_code);
		fetch l_csr into l_rec;
		if not csr_found_and_close(l_csr,p_error_when_not_exist) then
			l_rec := NULL;
		end if;

		return l_rec;
	END;
--------------------------------------------------------------------------------
	FUNCTION balance_type_id(
			p_balance_name			IN VARCHAR2,
			p_business_group_id		IN NUMBER	DEFAULT NULL,
			p_legislation_code		IN VARCHAR2	DEFAULT NULL,
			p_error_when_not_exist		IN VARCHAR2	DEFAULT 'TRUE') RETURN NUMBER
--------------------------------------------------------------------------------
	IS
	BEGIN
		return balance_type_rec(p_balance_name,p_business_group_id,p_legislation_code,p_error_when_not_exist).balance_type_id;
	END;
--------------------------------------------------------------------------------
	FUNCTION balance_dimension_rec(
			p_dimension_name		IN VARCHAR2,
			p_business_group_id		IN NUMBER	DEFAULT NULL,
			p_legislation_code		IN VARCHAR2	DEFAULT NULL,
			p_error_when_not_exist		IN VARCHAR2	DEFAULT 'TRUE') RETURN PAY_BALANCE_DIMENSIONS%ROWTYPE
--------------------------------------------------------------------------------
	IS
		l_csr			RefCsr;
		l_rec			PAY_BALANCE_DIMENSIONS%ROWTYPE;
	BEGIN
		l_csr := csr_with_bus_leg('PAY_BALANCE_DIMENSIONS','DIMENSION_NAME','T',p_dimension_name,p_business_group_id,p_legislation_code);
		fetch l_csr into l_rec;
		if not csr_found_and_close(l_csr,p_error_when_not_exist) then
			l_rec := NULL;
		end if;

		return l_rec;
	END;
--------------------------------------------------------------------------------
	FUNCTION balance_dimension_id(
			p_dimension_name		IN VARCHAR2,
			p_business_group_id		IN NUMBER	DEFAULT NULL,
			p_legislation_code		IN VARCHAR2	DEFAULT NULL,
			p_error_when_not_exist		IN VARCHAR2	DEFAULT 'TRUE') RETURN NUMBER
--------------------------------------------------------------------------------
	IS
	BEGIN
		return balance_dimension_rec(p_dimension_name,p_business_group_id,p_legislation_code,p_error_when_not_exist).balance_dimension_id;
	END;
--------------------------------------------------------------------------------
	FUNCTION assignment_status_type_rec(
			p_user_status			IN VARCHAR2,
			p_business_group_id		IN NUMBER	DEFAULT NULL,
			p_legislation_code		IN VARCHAR2	DEFAULT NULL,
			p_error_when_not_exist		IN VARCHAR2	DEFAULT 'TRUE') RETURN PER_ASSIGNMENT_STATUS_TYPES%ROWTYPE
--------------------------------------------------------------------------------
	IS
		l_csr			RefCsr;
		l_rec			PER_ASSIGNMENT_STATUS_TYPES%ROWTYPE;
	BEGIN
		l_csr := csr_with_bus_leg('PER_ASSIGNMENT_STATUS_TYPES','USER_STATUS','T',p_user_status,p_business_group_id,p_legislation_code);
		fetch l_csr into l_rec;
		if not csr_found_and_close(l_csr,p_error_when_not_exist) then
			l_rec := NULL;
		end if;

		return l_rec;
	END;
--------------------------------------------------------------------------------
	FUNCTION assignment_status_type_id(
			p_user_status			IN VARCHAR2,
			p_business_group_id		IN NUMBER	DEFAULT NULL,
			p_legislation_code		IN VARCHAR2	DEFAULT NULL,
			p_error_when_not_exist		IN VARCHAR2	DEFAULT 'TRUE') RETURN NUMBER
--------------------------------------------------------------------------------
	IS
	BEGIN
		return assignment_status_type_rec(p_user_status,p_business_group_id,p_legislation_code,p_error_when_not_exist).assignment_status_type_id;
	END;
--------------------------------------------------------------------------------
	FUNCTION user_table_rec(
			p_user_table_name		IN VARCHAR2,
			p_business_group_id		IN NUMBER	DEFAULT NULL,
			p_legislation_code		IN VARCHAR2	DEFAULT NULL,
			p_error_when_not_exist		IN VARCHAR2	DEFAULT 'TRUE') RETURN PAY_USER_TABLES%ROWTYPE
--------------------------------------------------------------------------------
	IS
		l_csr			RefCsr;
		l_rec			PAY_USER_TABLES%ROWTYPE;
	BEGIN
		l_csr := csr_with_bus_leg('PAY_USER_TABLES','USER_TABLE_NAME','T',p_user_table_name,p_business_group_id,p_legislation_code);
		fetch l_csr into l_rec;
		if not csr_found_and_close(l_csr,p_error_when_not_exist) then
			l_rec := NULL;
		end if;

		return l_rec;
	END;
--------------------------------------------------------------------------------
	FUNCTION user_table_id(
			p_user_table_name		IN VARCHAR2,
			p_business_group_id		IN NUMBER	DEFAULT NULL,
			p_legislation_code		IN VARCHAR2	DEFAULT NULL,
			p_error_when_not_exist		IN VARCHAR2	DEFAULT 'TRUE') RETURN NUMBER
--------------------------------------------------------------------------------
	IS
	BEGIN
		return user_table_rec(p_user_table_name,p_business_group_id,p_legislation_code,p_error_when_not_exist).user_table_id;
	END;
--------------------------------------------------------------------------------
-- ID with BUSINESS_GROUP_ID
--------------------------------------------------------------------------------
	FUNCTION location_rec(
			p_location_code			IN VARCHAR2,
			p_business_group_id		IN NUMBER	DEFAULT NULL,
			p_error_when_not_exist		IN VARCHAR2	DEFAULT 'TRUE') RETURN HR_LOCATIONS_ALL%ROWTYPE
--------------------------------------------------------------------------------
	IS
		l_csr			RefCsr;
		l_rec			HR_LOCATIONS_ALL%ROWTYPE;
	BEGIN
		l_csr := csr_with_bus('HR_LOCATIONS_ALL','LOCATION_CODE','T',p_location_code,p_business_group_id);
		fetch l_csr into l_rec;
		if not csr_found_and_close(l_csr,p_error_when_not_exist) then
			l_rec := NULL;
		end if;

		return l_rec;
	END;
--------------------------------------------------------------------------------
	FUNCTION location_id(
			p_location_code			IN VARCHAR2,
			p_business_group_id		IN NUMBER	DEFAULT NULL,
			p_error_when_not_exist		IN VARCHAR2	DEFAULT 'TRUE') RETURN NUMBER
--------------------------------------------------------------------------------
	IS
	BEGIN
		return location_rec(p_location_code,p_business_group_id,p_error_when_not_exist).location_id;
	END;
--------------------------------------------------------------------------------
	FUNCTION organization_rec(
			p_name				IN VARCHAR2,
			p_business_group_id		IN NUMBER,
			p_error_when_not_exist		IN VARCHAR2	DEFAULT 'TRUE') RETURN HR_ALL_ORGANIZATION_UNITS%ROWTYPE
--------------------------------------------------------------------------------
	IS
		l_csr			RefCsr;
		l_rec			HR_ALL_ORGANIZATION_UNITS%ROWTYPE;
	BEGIN
		l_csr := csr_with_bus('HR_ALL_ORGANIZATION_UNITS','NAME','T',p_name,p_business_group_id);
		fetch l_csr into l_rec;
		if not csr_found_and_close(l_csr,p_error_when_not_exist) then
			l_rec := NULL;
		end if;

		return l_rec;
	END;
--------------------------------------------------------------------------------
	FUNCTION organization_id(
			p_name				IN VARCHAR2,
			p_business_group_id		IN NUMBER,
			p_error_when_not_exist		IN VARCHAR2	DEFAULT 'TRUE') RETURN NUMBER
--------------------------------------------------------------------------------
	IS
	BEGIN
		return organization_rec(p_name,p_business_group_id,p_error_when_not_exist).organization_id;
	END;
--------------------------------------------------------------------------------
	FUNCTION org_payment_method_rec(
			p_org_payment_method_name	IN VARCHAR2,
			p_business_group_id		IN NUMBER,
			p_effective_date		IN DATE		DEFAULT hr_api.g_sys,
			p_error_when_not_exist		IN VARCHAR2	DEFAULT 'TRUE') RETURN PAY_ORG_PAYMENT_METHODS_F%ROWTYPE
--------------------------------------------------------------------------------
	IS
		l_csr			RefCsr;
		l_rec			PAY_ORG_PAYMENT_METHODS_F%ROWTYPE;
	BEGIN
		l_csr := csr_with_bus('PAY_ORG_PAYMENT_METHODS_F','ORG_PAYMENT_METHOD_NAME','T',p_org_payment_method_name,p_business_group_id,'DATETRACKED',p_effective_date);
		fetch l_csr into l_rec;
		if not csr_found_and_close(l_csr,p_error_when_not_exist) then
			l_rec := NULL;
		end if;

		return l_rec;
	END;
--------------------------------------------------------------------------------
	FUNCTION org_payment_method_id(
			p_org_payment_method_name	IN VARCHAR2,
			p_business_group_id		IN NUMBER,
			p_error_when_not_exist		IN VARCHAR2	DEFAULT 'TRUE') RETURN NUMBER
--------------------------------------------------------------------------------
	IS
	BEGIN
		return org_payment_method_rec(p_org_payment_method_name,p_business_group_id,NULL,p_error_when_not_exist).org_payment_method_id;
	END;
--------------------------------------------------------------------------------
	FUNCTION payroll_rec(
			p_payroll_name			IN VARCHAR2,
			p_business_group_id		IN NUMBER,
			p_effective_date		IN DATE		DEFAULT hr_api.g_sys,
			p_error_when_not_exist		IN VARCHAR2	DEFAULT 'TRUE') RETURN PAY_ALL_PAYROLLS_F%ROWTYPE
--------------------------------------------------------------------------------
	IS
		l_csr			RefCsr;
		l_rec			PAY_ALL_PAYROLLS_F%ROWTYPE;
	BEGIN
		l_csr := csr_with_bus('PAY_ALL_PAYROLLS_F','PAYROLL_NAME','T',p_payroll_name,p_business_group_id,'DATETRACKED',p_effective_date);
		fetch l_csr into l_rec;
		if not csr_found_and_close(l_csr,p_error_when_not_exist) then
			l_rec := NULL;
		end if;

		return l_rec;
	END;
--------------------------------------------------------------------------------
	FUNCTION payroll_id(
			p_payroll_name			IN VARCHAR2,
			p_business_group_id		IN NUMBER,
			p_error_when_not_exist		IN VARCHAR2	DEFAULT 'TRUE') RETURN NUMBER
--------------------------------------------------------------------------------
	IS
	BEGIN
		return payroll_rec(p_payroll_name,p_business_group_id,NULL,p_error_when_not_exist).payroll_id;
	END;
--------------------------------------------------------------------------------
	FUNCTION consolidation_set_rec(
			p_consolidation_set_name	IN VARCHAR2,
			p_business_group_id		IN NUMBER,
			p_error_when_not_exist		IN VARCHAR2	DEFAULT 'TRUE') RETURN PAY_CONSOLIDATION_SETS%ROWTYPE
--------------------------------------------------------------------------------
	IS
		l_csr			RefCsr;
		l_rec			PAY_CONSOLIDATION_SETS%ROWTYPE;
	BEGIN
		l_csr := csr_with_bus('PAY_CONSOLIDATION_SETS','CONSOLIDATION_SET_NAME','T',p_consolidation_set_name,p_business_group_id);
		fetch l_csr into l_rec;
		if not csr_found_and_close(l_csr,p_error_when_not_exist) then
			l_rec := NULL;
		end if;

		return l_rec;
	END;
--------------------------------------------------------------------------------
	FUNCTION consolidation_set_id(
			p_consolidation_set_name	IN VARCHAR2,
			p_business_group_id		IN NUMBER,
			p_error_when_not_exist		IN VARCHAR2	DEFAULT 'TRUE') RETURN NUMBER
--------------------------------------------------------------------------------
	IS
	BEGIN
		return consolidation_set_rec(p_consolidation_set_name,p_business_group_id,p_error_when_not_exist).consolidation_set_id;
	END;
--------------------------------------------------------------------------------
	FUNCTION assignment_set_rec(
			p_assignment_set_name		IN VARCHAR2,
			p_business_group_id		IN NUMBER,
			p_error_when_not_exist		IN VARCHAR2	DEFAULT 'TRUE') RETURN HR_ASSIGNMENT_SETS%ROWTYPE
--------------------------------------------------------------------------------
	IS
		l_csr			RefCsr;
		l_rec			HR_ASSIGNMENT_SETS%ROWTYPE;
	BEGIN
		l_csr := csr_with_bus('HR_ASSIGNMENT_SETS','ASSIGNMENT_SET_NAME','T',p_assignment_set_name,p_business_group_id);
		fetch l_csr into l_rec;
		if not csr_found_and_close(l_csr,p_error_when_not_exist) then
			l_rec := NULL;
		end if;

		return l_rec;
	END;
--------------------------------------------------------------------------------
	FUNCTION assignment_set_id(
			p_assignment_set_name		IN VARCHAR2,
			p_business_group_id		IN NUMBER,
			p_error_when_not_exist		IN VARCHAR2	DEFAULT 'TRUE') RETURN NUMBER
--------------------------------------------------------------------------------
	IS
	BEGIN
		return assignment_set_rec(p_assignment_set_name,p_business_group_id,p_error_when_not_exist).assignment_set_id;
	END;
--------------------------------------------------------------------------------
	FUNCTION pay_basis_rec(
			p_name				IN VARCHAR2,
			p_business_group_id		IN NUMBER,
			p_error_when_not_exist		IN VARCHAR2	DEFAULT 'TRUE') RETURN PER_PAY_BASES%ROWTYPE
--------------------------------------------------------------------------------
	IS
		l_csr			RefCsr;
		l_rec			PER_PAY_BASES%ROWTYPE;
	BEGIN
		l_csr := csr_with_bus('PER_PAY_BASES','NAME','T',p_name,p_business_group_id);
		fetch l_csr into l_rec;
		if not csr_found_and_close(l_csr,p_error_when_not_exist) then
			l_rec := NULL;
		end if;

		return l_rec;
	END;
--------------------------------------------------------------------------------
	FUNCTION pay_basis_id(
			p_name				IN VARCHAR2,
			p_business_group_id		IN NUMBER,
			p_error_when_not_exist		IN VARCHAR2	DEFAULT 'TRUE') RETURN NUMBER
--------------------------------------------------------------------------------
	IS
	BEGIN
		return pay_basis_rec(p_name,p_business_group_id,p_error_when_not_exist).pay_basis_id;
	END;
--------------------------------------------------------------------------------
	FUNCTION person_type_rec(
			p_user_person_type		IN VARCHAR2,
			p_business_group_id		IN NUMBER,
			p_error_when_not_exist		IN VARCHAR2	DEFAULT 'TRUE') RETURN PER_PERSON_TYPES%ROWTYPE
--------------------------------------------------------------------------------
	IS
		l_csr			RefCsr;
		l_rec			PER_PERSON_TYPES%ROWTYPE;
	BEGIN
		l_csr := csr_with_bus('PER_PERSON_TYPES','USER_PERSON_TYPE','T',p_user_person_type,p_business_group_id);
		fetch l_csr into l_rec;
		if not csr_found_and_close(l_csr,p_error_when_not_exist) then
			l_rec := NULL;
		end if;

		return l_rec;
	END;
--------------------------------------------------------------------------------
	FUNCTION person_type_id(
			p_user_person_type		IN VARCHAR2,
			p_business_group_id		IN NUMBER,
			p_error_when_not_exist		IN VARCHAR2	DEFAULT 'TRUE') RETURN NUMBER
--------------------------------------------------------------------------------
	IS
	BEGIN
		return person_type_rec(p_user_person_type,p_business_group_id,p_error_when_not_exist).person_type_id;
	END;
--------------------------------------------------------------------------------
	FUNCTION emp_person_rec(
			p_employee_number		IN VARCHAR2,
			p_business_group_id		IN NUMBER,
			p_effective_date		IN DATE		DEFAULT hr_api.g_sys,
			p_error_when_not_exist		IN VARCHAR2	DEFAULT 'TRUE') RETURN PER_ALL_PEOPLE_F%ROWTYPE
--------------------------------------------------------------------------------
	IS
		l_csr			RefCsr;
		l_rec			PER_ALL_PEOPLE_F%ROWTYPE;
	BEGIN
		l_csr := csr_with_bus('PER_ALL_PEOPLE_F','EMPLOYEE_NUMBER','T',p_employee_number,p_business_group_id,'DATETRACKED',p_effective_date);
		fetch l_csr into l_rec;
		if not csr_found_and_close(l_csr,p_error_when_not_exist) then
			l_rec := NULL;
		end if;

		return l_rec;
	END;
--------------------------------------------------------------------------------
	FUNCTION emp_person_id(
			p_employee_number		IN VARCHAR2,
			p_business_group_id		IN NUMBER,
			p_error_when_not_exist		IN VARCHAR2	DEFAULT 'TRUE') RETURN NUMBER
--------------------------------------------------------------------------------
	IS
	BEGIN
		return emp_person_rec(p_employee_number,p_business_group_id,NULL,p_error_when_not_exist).person_id;
	END;
--------------------------------------------------------------------------------
	FUNCTION apl_person_rec(
			p_applicant_number		IN VARCHAR2,
			p_business_group_id		IN NUMBER,
			p_effective_date		IN DATE		DEFAULT hr_api.g_sys,
			p_error_when_not_exist		IN VARCHAR2	DEFAULT 'TRUE') RETURN PER_ALL_PEOPLE_F%ROWTYPE
--------------------------------------------------------------------------------
	IS
		l_csr			RefCsr;
		l_rec			PER_ALL_PEOPLE_F%ROWTYPE;
	BEGIN
		l_csr := csr_with_bus('PER_ALL_PEOPLE_F','APPLICANT_NUMBER','T',p_applicant_number,p_business_group_id,'DATETRACKED',p_effective_date);
		fetch l_csr into l_rec;
		if not csr_found_and_close(l_csr,p_error_when_not_exist) then
			l_rec := NULL;
		end if;

		return l_rec;
	END;
--------------------------------------------------------------------------------
	FUNCTION apl_person_id(
			p_applicant_number		IN VARCHAR2,
			p_business_group_id		IN NUMBER,
			p_error_when_not_exist		IN VARCHAR2	DEFAULT 'TRUE') RETURN NUMBER
--------------------------------------------------------------------------------
	IS
	BEGIN
		return apl_person_rec(p_applicant_number,p_business_group_id,NULL,p_error_when_not_exist).person_id;
	END;
--------------------------------------------------------------------------------
	FUNCTION emp_assignment_rec(
			p_assignment_number		IN VARCHAR2,
			p_business_group_id		IN NUMBER,
			p_effective_date		IN DATE		DEFAULT hr_api.g_sys,
			p_error_when_not_exist		IN VARCHAR2	DEFAULT 'TRUE') RETURN PER_ALL_ASSIGNMENTS_F%ROWTYPE
--------------------------------------------------------------------------------
	IS
		l_csr			RefCsr;
		l_rec			PER_ALL_ASSIGNMENTS_F%ROWTYPE;
	BEGIN
		l_csr := csr_with_bus('PER_ALL_ASSIGNMENTS_F','ASSIGNMENT_NUMBER','T',p_assignment_number,p_business_group_id,'DATETRACKED',p_effective_date);
		fetch l_csr into l_rec;
		if not csr_found_and_close(l_csr,p_error_when_not_exist) then
			l_rec := NULL;
		end if;

		return l_rec;
	END;
--------------------------------------------------------------------------------
	FUNCTION emp_assignment_id(
			p_assignment_number		IN VARCHAR2,
			p_business_group_id		IN NUMBER,
			p_error_when_not_exist		IN VARCHAR2	DEFAULT 'TRUE') RETURN NUMBER
--------------------------------------------------------------------------------
	IS
	BEGIN
		return emp_assignment_rec(p_assignment_number,p_business_group_id,NULL,p_error_when_not_exist).assignment_id;
	END;
--------------------------------------------------------------------------------
	FUNCTION rate_id(
			p_name				IN VARCHAR2,
			p_business_group_id		IN NUMBER,
			p_error_when_not_exist		IN VARCHAR2	DEFAULT 'TRUE') RETURN NUMBER
--------------------------------------------------------------------------------
	IS
		l_csr			RefCsr;
		l_rec			PAY_RATES%ROWTYPE;
	BEGIN
		l_csr := csr_with_bus('PAY_RATES','NAME','T',p_name,p_business_group_id);
		fetch l_csr into l_rec;
		if not csr_found_and_close(l_csr,p_error_when_not_exist) then
			l_rec := NULL;
		end if;

		return l_rec.rate_id;
	END;
--------------------------------------------------------------------------------
	FUNCTION job_rec(
			p_concatenated_segments		IN VARCHAR2,
			p_business_group_id		IN NUMBER,
			p_error_when_not_exist		IN VARCHAR2	DEFAULT 'TRUE') RETURN PER_JOBS%ROWTYPE
--------------------------------------------------------------------------------
	IS
		l_id_flex_num		NUMBER;
		l_job_definition_id	NUMBER;
		l_csr			RefCsr;
		l_rec			PER_JOBS%ROWTYPE;
	BEGIN
		l_id_flex_num := id_flex_num(p_business_group_id,'JOB');
		l_job_definition_id := keyflex_combination_id('PER','JOB',l_id_flex_num,p_concatenated_segments,p_error_when_not_exist);

		if l_job_definition_id is NULL then
			l_rec := NULL;
		else
			l_csr := csr_with_bus('PER_JOBS','JOB_DEFINITION_ID','N',to_char(l_job_definition_id),p_business_group_id);
			fetch l_csr into l_rec;
			if not csr_found_and_close(l_csr,p_error_when_not_exist) then
				l_rec := NULL;
			end if;
		end if;

		return l_rec;
	END;
--------------------------------------------------------------------------------
	FUNCTION job_id(
			p_concatenated_segments		IN VARCHAR2,
			p_business_group_id		IN NUMBER,
			p_error_when_not_exist		IN VARCHAR2	DEFAULT 'TRUE') RETURN NUMBER
--------------------------------------------------------------------------------
	IS
	BEGIN
		return job_rec(p_concatenated_segments,p_business_group_id,p_error_when_not_exist).job_id;
	END;
--------------------------------------------------------------------------------
	FUNCTION position_rec(
			p_concatenated_segments		IN VARCHAR2,
			p_business_group_id		IN NUMBER,
			p_error_when_not_exist		IN VARCHAR2	DEFAULT 'TRUE') RETURN PER_POSITIONS%ROWTYPE
--------------------------------------------------------------------------------
	IS
		l_id_flex_num			NUMBER;
		l_position_definition_id	NUMBER;
		l_csr				RefCsr;
		l_rec				PER_POSITIONS%ROWTYPE;
	BEGIN
		l_id_flex_num := id_flex_num(p_business_group_id,'POS');
		l_position_definition_id := keyflex_combination_id('PER','POS',l_id_flex_num,p_concatenated_segments,p_error_when_not_exist);

		if l_position_definition_id is NULL then
			l_rec := NULL;
		else
			l_csr := csr_with_bus('PER_POSITIONS','POSITION_DEFINITION_ID','N',to_char(l_position_definition_id),p_business_group_id);
			fetch l_csr into l_rec;
			if not csr_found_and_close(l_csr,p_error_when_not_exist) then
				l_rec := NULL;
			end if;
		end if;

		return l_rec;
	END;
--------------------------------------------------------------------------------
	FUNCTION position_id(
			p_concatenated_segments		IN VARCHAR2,
			p_business_group_id		IN NUMBER,
			p_error_when_not_exist		IN VARCHAR2	DEFAULT 'TRUE') RETURN NUMBER
--------------------------------------------------------------------------------
	IS
	BEGIN
		return position_rec(p_concatenated_segments,p_business_group_id,p_error_when_not_exist).position_id;
	END;
--------------------------------------------------------------------------------
	FUNCTION grade_rec(
			p_concatenated_segments		IN VARCHAR2,
			p_business_group_id		IN NUMBER,
			p_error_when_not_exist		IN VARCHAR2	DEFAULT 'TRUE') RETURN PER_GRADES%ROWTYPE
--------------------------------------------------------------------------------
	IS
		l_id_flex_num		NUMBER;
		l_grade_definition_id	NUMBER;
		l_csr			RefCsr;
		l_rec			PER_GRADES%ROWTYPE;
	BEGIN
		l_id_flex_num := id_flex_num(p_business_group_id,'GRD');
		l_grade_definition_id := keyflex_combination_id('PER','GRD',l_id_flex_num,p_concatenated_segments,p_error_when_not_exist);

		if l_grade_definition_id is NULL then
			l_rec := NULL;
		else
			l_csr := csr_with_bus('PER_GRADES','GRADE_DEFINITION_ID','N',to_char(l_grade_definition_id),p_business_group_id);
			fetch l_csr into l_rec;
			if not csr_found_and_close(l_csr,p_error_when_not_exist) then
				l_rec := NULL;
			end if;
		end if;

		return l_rec;
	END;
--------------------------------------------------------------------------------
	FUNCTION grade_id(
			p_concatenated_segments		IN VARCHAR2,
			p_business_group_id		IN NUMBER,
			p_error_when_not_exist		IN VARCHAR2	DEFAULT 'TRUE') RETURN NUMBER
--------------------------------------------------------------------------------
	IS
	BEGIN
		return grade_rec(p_concatenated_segments,p_business_group_id,p_error_when_not_exist).grade_id;
	END;
--------------------------------------------------------------------------------
-- ID with special case
--------------------------------------------------------------------------------
	FUNCTION input_value_rec(
			p_element_type_id		IN NUMBER,
			p_name				IN VARCHAR2,
			p_effective_date		IN DATE		DEFAULT hr_api.g_sys,
			p_error_when_not_exist		IN VARCHAR2	DEFAULT 'TRUE') RETURN PAY_INPUT_VALUES_F%ROWTYPE
--------------------------------------------------------------------------------
	IS
		l_unique_column_tbl	UniColTbl;
		l_csr			RefCsr;
		l_rec			PAY_INPUT_VALUES_F%ROWTYPE;
	BEGIN
		unique_tbl_constructor('ELEMENT_TYPE_ID','N',to_char(p_element_type_id),l_unique_column_tbl);
		unique_tbl_constructor('NAME','T',p_name,l_unique_column_tbl);

		l_csr := csr('PAY_INPUT_VALUES_F',l_unique_column_tbl,'DATETRACKED',p_effective_date);
		fetch l_csr into l_rec;
		if not csr_found_and_close(l_csr,p_error_when_not_exist) then
			l_rec := NULL;
		end if;

		return l_rec;
	END;
--------------------------------------------------------------------------------
	FUNCTION input_value_id(
			p_element_type_id		IN NUMBER,
			p_name				IN VARCHAR2,
			p_error_when_not_exist		IN VARCHAR2	DEFAULT 'TRUE') RETURN NUMBER
--------------------------------------------------------------------------------
	IS
	BEGIN
		return input_value_rec(p_element_type_id,p_name,NULL,p_error_when_not_exist).input_value_id;
	END;
--------------------------------------------------------------------------------
	FUNCTION input_value_rec(
			p_element_name			IN VARCHAR2,
			p_name				IN VARCHAR2,
			p_business_group_id		IN NUMBER	DEFAULT NULL,
			p_legislation_code		IN VARCHAR2	DEFAULT NULL,
			p_effective_date		IN DATE		DEFAULT hr_api.g_sys,
			p_error_when_not_exist		IN VARCHAR2	DEFAULT 'TRUE') RETURN PAY_INPUT_VALUES_F%ROWTYPE
--------------------------------------------------------------------------------
	IS
		l_element_type_id	NUMBER;
	BEGIN
		l_element_type_id := element_type_id(p_element_name,p_business_group_id,p_legislation_code,p_error_when_not_exist);

		return input_value_rec(l_element_type_id,p_name,p_effective_date,p_error_when_not_exist);
	END;
--------------------------------------------------------------------------------
	FUNCTION input_value_id(
			p_element_name			IN VARCHAR2,
			p_name				IN VARCHAR2,
			p_business_group_id		IN NUMBER	DEFAULT NULL,
			p_legislation_code		IN VARCHAR2	DEFAULT NULL,
			p_error_when_not_exist		IN VARCHAR2	DEFAULT 'TRUE') RETURN NUMBER
--------------------------------------------------------------------------------
	IS
	BEGIN
		return input_value_rec(p_element_name,p_name,p_business_group_id,p_legislation_code,NULL,p_error_when_not_exist).input_value_id;
	END;
--------------------------------------------------------------------------------
	FUNCTION defined_balance_rec(
			p_balance_type_id		IN NUMBER,
			p_balance_dimension_id		IN NUMBER,
			p_business_group_id		IN NUMBER	DEFAULT NULL,
			p_legislation_code		IN VARCHAR2	DEFAULT NULL,
			p_error_when_not_exist		IN VARCHAR2	DEFAULT 'TRUE') RETURN PAY_DEFINED_BALANCES%ROWTYPE
--------------------------------------------------------------------------------
	IS
		l_unique_column_tbl	UniColTbl;
		l_csr			RefCsr;
		l_rec			PAY_DEFINED_BALANCES%ROWTYPE;
	BEGIN
		unique_tbl_constructor('BALANCE_TYPE_ID','N',to_char(p_balance_type_id),l_unique_column_tbl);
		unique_tbl_constructor('BALANCE_DIMENSION_ID','N',to_char(p_balance_dimension_id),l_unique_column_tbl);
		bus_leg_constructor(p_business_group_id,p_legislation_code,l_unique_column_tbl);

		l_csr := csr('PAY_DEFINED_BALANCES',l_unique_column_tbl);
		fetch l_csr into l_rec;
		if not csr_found_and_close(l_csr,p_error_when_not_exist) then
			l_rec := NULL;
		end if;

		return l_rec;
	END;
--------------------------------------------------------------------------------
	FUNCTION defined_balance_id(
			p_balance_type_id		IN NUMBER,
			p_balance_dimension_id		IN NUMBER,
			p_business_group_id		IN NUMBER	DEFAULT NULL,
			p_legislation_code		IN VARCHAR2	DEFAULT NULL,
			p_error_when_not_exist		IN VARCHAR2	DEFAULT 'TRUE') RETURN NUMBER
--------------------------------------------------------------------------------
	IS
	BEGIN
		return defined_balance_rec(p_balance_type_id,p_balance_dimension_id,p_business_group_id,p_legislation_code,p_error_when_not_exist).defined_balance_id;
	END;
--------------------------------------------------------------------------------
	FUNCTION defined_balance_rec(
			p_balance_name			IN VARCHAR2,
			p_dimension_name		IN VARCHAR2,
			p_business_group_id		IN NUMBER	DEFAULT NULL,
			p_legislation_code		IN VARCHAR2	DEFAULT NULL,
			p_error_when_not_exist		IN VARCHAR2	DEFAULT 'TRUE') RETURN PAY_DEFINED_BALANCES%ROWTYPE
--------------------------------------------------------------------------------
	IS
		l_balance_type_id	NUMBER;
		l_balance_dimension_id	NUMBER;
	BEGIN
		l_balance_type_id	:= balance_type_id(p_balance_name,p_business_group_id,p_legislation_code,p_error_when_not_exist);
		l_balance_dimension_id	:= balance_dimension_id(p_dimension_name,p_business_group_id,p_legislation_code,p_error_when_not_exist);

		return defined_balance_rec(l_balance_type_id,l_balance_dimension_id,p_business_group_id,p_legislation_code,p_error_when_not_exist);
	END;
--------------------------------------------------------------------------------
	FUNCTION defined_balance_id(
			p_balance_name			IN VARCHAR2,
			p_dimension_name		IN VARCHAR2,
			p_business_group_id		IN NUMBER	DEFAULT NULL,
			p_legislation_code		IN VARCHAR2	DEFAULT NULL,
			p_error_when_not_exist		IN VARCHAR2	DEFAULT 'TRUE') RETURN NUMBER
--------------------------------------------------------------------------------
	IS
	BEGIN
		return defined_balance_rec(p_balance_name,p_dimension_name,p_business_group_id,p_legislation_code,p_error_when_not_exist).defined_balance_id;
	END;
--------------------------------------------------------------------------------
	FUNCTION balance_feed_rec(
			p_balance_type_id		IN NUMBER,
			p_input_value_id		IN NUMBER,
			p_business_group_id		IN NUMBER	DEFAULT NULL,
			p_legislation_code		IN VARCHAR2	DEFAULT NULL,
			p_effective_date		IN DATE		DEFAULT hr_api.g_sys,
			p_error_when_not_exist		IN VARCHAR2	DEFAULT 'TRUE') RETURN PAY_BALANCE_FEEDS_F%ROWTYPE
--------------------------------------------------------------------------------
	IS
		l_unique_column_tbl	UniColTbl;
		l_csr			RefCsr;
		l_rec			PAY_BALANCE_FEEDS_F%ROWTYPE;
	BEGIN
		unique_tbl_constructor('BALANCE_TYPE_ID','N',to_char(p_balance_type_id),l_unique_column_tbl);
		unique_tbl_constructor('INPUT_VALUE_ID','N',to_char(p_input_value_id),l_unique_column_tbl);
		bus_leg_constructor(p_business_group_id,p_legislation_code,l_unique_column_tbl);

		l_csr := csr('PAY_BALANCE_FEEDS_F',l_unique_column_tbl,'DATETRACKED',p_effective_date);
		fetch l_csr into l_rec;
		if not csr_found_and_close(l_csr,p_error_when_not_exist) then
			l_rec := NULL;
		end if;

		return l_rec;
	END;
--------------------------------------------------------------------------------
	FUNCTION balance_feed_id(
			p_balance_type_id		IN NUMBER,
			p_input_value_id		IN NUMBER,
			p_business_group_id		IN NUMBER	DEFAULT NULL,
			p_legislation_code		IN VARCHAR2	DEFAULT NULL,
			p_effective_date		IN DATE		DEFAULT hr_api.g_sys,
			p_error_when_not_exist		IN VARCHAR2	DEFAULT 'TRUE') RETURN NUMBER
--------------------------------------------------------------------------------
	IS
	BEGIN
		return balance_feed_rec(p_balance_type_id,p_input_value_id,p_business_group_id,p_legislation_code,p_effective_date,p_error_when_not_exist).balance_feed_id;
	END;
--------------------------------------------------------------------------------
	FUNCTION balance_feed_rec(
			p_balance_name			IN VARCHAR2,
			p_element_name			IN VARCHAR2,
			p_name				IN VARCHAR2,
			p_business_group_id		IN NUMBER	DEFAULT NULL,
			p_legislation_code		IN VARCHAR2	DEFAULT NULL,
			p_effective_date		IN DATE		DEFAULT hr_api.g_sys,
			p_error_when_not_exist		IN VARCHAR2	DEFAULT 'TRUE') RETURN PAY_BALANCE_FEEDS_F%ROWTYPE
--------------------------------------------------------------------------------
	IS
		l_balance_type_id	NUMBER;
		l_input_value_id	NUMBER;
	BEGIN
		l_balance_type_id	:= balance_type_id(p_balance_name,p_business_group_id,p_legislation_code,p_error_when_not_exist);
		l_input_value_id	:= input_value_id(p_element_name,p_name,p_business_group_id,p_legislation_code,p_error_when_not_exist);

		return balance_feed_rec(l_balance_type_id,l_input_value_id,p_business_group_id,p_legislation_code,p_effective_date,p_error_when_not_exist);
	END;
--------------------------------------------------------------------------------
	FUNCTION balance_feed_id(
			p_balance_name			IN VARCHAR2,
			p_element_name			IN VARCHAR2,
			p_name				IN VARCHAR2,
			p_business_group_id		IN NUMBER	DEFAULT NULL,
			p_legislation_code		IN VARCHAR2	DEFAULT NULL,
			p_effective_date		IN DATE		DEFAULT hr_api.g_sys,
			p_error_when_not_exist		IN VARCHAR2	DEFAULT 'TRUE') RETURN NUMBER
--------------------------------------------------------------------------------
	IS
	BEGIN
		return balance_feed_rec(p_balance_name,p_element_name,p_name,p_business_group_id,p_legislation_code,p_effective_date,p_error_when_not_exist).balance_feed_id;
	END;
--------------------------------------------------------------------------------
	FUNCTION business_group_rec(
			p_name				IN VARCHAR2,
			p_error_when_not_exist		IN VARCHAR2	DEFAULT 'TRUE') RETURN PER_BUSINESS_GROUPS%ROWTYPE
--------------------------------------------------------------------------------
	IS
		l_unique_column_tbl	UniColTbl;
		l_csr			RefCsr;
		l_rec			PER_BUSINESS_GROUPS%ROWTYPE;
	BEGIN
		if g_bg_rec_cache.name = p_name then
			NULL;
		else
			unique_tbl_constructor('NAME','T',p_name,l_unique_column_tbl);

			l_csr := csr('PER_BUSINESS_GROUPS',l_unique_column_tbl);
			fetch l_csr into l_rec;
			if not csr_found_and_close(l_csr,p_error_when_not_exist) then
				l_rec := NULL;
			end if;

			g_bg_rec_cache := l_rec;
		end if;

		return g_bg_rec_cache;
	END;
--------------------------------------------------------------------------------
	FUNCTION business_group_id(
			p_name				IN VARCHAR2,
			p_error_when_not_exist		IN VARCHAR2	DEFAULT 'TRUE') RETURN NUMBER
--------------------------------------------------------------------------------
	IS
	BEGIN
		return business_group_rec(p_name,p_error_when_not_exist).business_group_id;
	END;
--------------------------------------------------------------------------------
	FUNCTION formula_type_rec(
			p_formula_type_name		IN VARCHAR2,
			p_error_when_not_exist		IN VARCHAR2	DEFAULT 'TRUE') RETURN FF_FORMULA_TYPES%ROWTYPE
--------------------------------------------------------------------------------
	IS
		l_unique_column_tbl	UniColTbl;
		l_csr			RefCsr;
		l_rec			FF_FORMULA_TYPES%ROWTYPE;
	BEGIN
		unique_tbl_constructor('FORMULA_TYPE_NAME','T',p_formula_type_name,l_unique_column_tbl);

		l_csr := csr('FF_FORMULA_TYPES',l_unique_column_tbl);
		fetch l_csr into l_rec;
		if not csr_found_and_close(l_csr,p_error_when_not_exist) then
			l_rec := NULL;
		end if;

		return l_rec;
	END;
--------------------------------------------------------------------------------
	FUNCTION formula_type_id(
			p_formula_type_name		IN VARCHAR2,
			p_error_when_not_exist		IN VARCHAR2	DEFAULT 'TRUE') RETURN NUMBER
--------------------------------------------------------------------------------
	IS
	BEGIN
		return formula_type_rec(p_formula_type_name,p_error_when_not_exist).formula_type_id;
	END;
--------------------------------------------------------------------------------
	FUNCTION formula_rec(
			p_formula_name			IN VARCHAR2,
			p_formula_type_name		IN VARCHAR2,
			p_business_group_id		IN NUMBER	DEFAULT NULL,
			p_legislation_code		IN VARCHAR2	DEFAULT NULL,
			p_effective_date		IN DATE		DEFAULT hr_api.g_sys,
			p_error_when_not_exist		IN VARCHAR2	DEFAULT 'TRUE') RETURN FF_FORMULAS_F%ROWTYPE
--------------------------------------------------------------------------------
	IS
		l_formula_type_id	NUMBER;
		l_unique_column_tbl	UniColTbl;
		l_csr			RefCsr;
		l_rec			FF_FORMULAS_F%ROWTYPE;
	BEGIN
		l_formula_type_id := formula_type_id(p_formula_type_name,p_error_when_not_exist);
		unique_tbl_constructor('FORMULA_TYPE_ID','N',to_char(l_formula_type_id),l_unique_column_tbl);
		unique_tbl_constructor('FORMULA_NAME','T',p_formula_name,l_unique_column_tbl);
		bus_leg_constructor(p_business_group_id,p_legislation_code,l_unique_column_tbl);

		l_csr := csr('FF_FORMULAS_F',l_unique_column_tbl,'DATETRACKED',p_effective_date);
		fetch l_csr into l_rec;
		if not csr_found_and_close(l_csr,p_error_when_not_exist) then
			l_rec := NULL;
		end if;

		return l_rec;
	END;
--------------------------------------------------------------------------------
	FUNCTION formula_id(
			p_formula_name			IN VARCHAR2,
			p_formula_type_name		IN VARCHAR2,
			p_business_group_id		IN NUMBER	DEFAULT NULL,
			p_legislation_code		IN VARCHAR2	DEFAULT NULL,
			p_error_when_not_exist		IN VARCHAR2	DEFAULT 'TRUE') RETURN NUMBER
--------------------------------------------------------------------------------
	IS
	BEGIN
		return formula_rec(p_formula_name,p_formula_type_name,p_business_group_id,p_legislation_code,NULL,p_error_when_not_exist).formula_id;
	END;
--------------------------------------------------------------------------------
	FUNCTION function_rec(
			p_name				IN VARCHAR2,
			p_data_type			IN VARCHAR2,
			p_business_group_id		IN NUMBER	DEFAULT NULL,
			p_legislation_code		IN VARCHAR2	DEFAULT NULL,
			p_error_when_not_exist		IN VARCHAR2	DEFAULT 'TRUE') RETURN FF_FUNCTIONS%ROWTYPE
--------------------------------------------------------------------------------
	IS
		l_unique_column_tbl	UniColTbl;
		l_csr			RefCsr;
		l_rec			FF_FUNCTIONS%ROWTYPE;
	BEGIN
		unique_tbl_constructor('NAME','T',p_name,l_unique_column_tbl);
		unique_tbl_constructor('DATA_TYPE','T',p_data_type,l_unique_column_tbl);
		bus_leg_constructor(p_business_group_id,p_legislation_code,l_unique_column_tbl);

		l_csr := csr('FF_FUNCTIONS',l_unique_column_tbl);
		fetch l_csr into l_rec;
		if not csr_found_and_close(l_csr,p_error_when_not_exist) then
			l_rec := NULL;
		end if;

		return l_rec;
	END;
--------------------------------------------------------------------------------
	FUNCTION function_id(
			p_name				IN VARCHAR2,
			p_data_type			IN VARCHAR2,
			p_business_group_id		IN NUMBER	DEFAULT NULL,
			p_legislation_code		IN VARCHAR2	DEFAULT NULL,
			p_error_when_not_exist		IN VARCHAR2	DEFAULT 'TRUE') RETURN NUMBER
--------------------------------------------------------------------------------
	IS
	BEGIN
		return function_rec(p_name,p_data_type,p_business_group_id,p_legislation_code,p_error_when_not_exist).function_id;
	END;
--------------------------------------------------------------------------------
	FUNCTION status_processing_rule_rec(
			p_element_type_id		IN NUMBER,
			p_assignment_status_type_id	IN NUMBER	DEFAULT NULL,
			p_business_group_id		IN NUMBER	DEFAULT NULL,
			p_legislation_code		IN VARCHAR2	DEFAULT NULL,
			p_effective_date		IN DATE		DEFAULT hr_api.g_sys,
			p_error_when_not_exist		IN VARCHAR2	DEFAULT 'TRUE') RETURN PAY_STATUS_PROCESSING_RULES_F%ROWTYPE
--------------------------------------------------------------------------------
	IS
		l_unique_column_tbl	UniColTbl;
		l_csr			RefCsr;
		l_rec			PAY_STATUS_PROCESSING_RULES_F%ROWTYPE;
	BEGIN
		unique_tbl_constructor('ELEMENT_TYPE_ID','N',to_char(p_element_type_id),l_unique_column_tbl);
		unique_tbl_constructor('ASSIGNMENT_STATUS_TYPE_ID','N',to_char(p_assignment_status_type_id),l_unique_column_tbl);
		bus_leg_constructor(p_business_group_id,p_legislation_code,l_unique_column_tbl);

		l_csr := csr('PAY_STATUS_PROCESSING_RULES_F',l_unique_column_tbl,'DATETRACKED',p_effective_date);
		fetch l_csr into l_rec;
		if not csr_found_and_close(l_csr,p_error_when_not_exist) then
			l_rec := NULL;
		end if;

		return l_rec;
	END;
--------------------------------------------------------------------------------
	FUNCTION status_processing_rule_id(
			p_element_type_id		IN NUMBER,
			p_assignment_status_type_id	IN NUMBER	DEFAULT NULL,
			p_business_group_id		IN NUMBER	DEFAULT NULL,
			p_legislation_code		IN VARCHAR2	DEFAULT NULL,
			p_effective_date		IN DATE		DEFAULT hr_api.g_sys,
			p_error_when_not_exist		IN VARCHAR2	DEFAULT 'TRUE') RETURN NUMBER
--------------------------------------------------------------------------------
	IS
	BEGIN
		return status_processing_rule_rec(
				p_element_type_id,p_assignment_status_type_id,
				p_business_group_id,p_legislation_code,p_effective_date,p_error_when_not_exist).status_processing_rule_id;
	END;
--------------------------------------------------------------------------------
	FUNCTION formula_result_rule_rec(
			p_status_processing_rule_id	IN NUMBER,
			p_result_name			IN VARCHAR2,
			p_result_rule_type		IN VARCHAR2,
			p_element_type_id		IN NUMBER	DEFAULT NULL,
			p_input_value_id		IN NUMBER	DEFAULT NULL,
			p_business_group_id		IN NUMBER	DEFAULT NULL,
			p_legislation_code		IN VARCHAR2	DEFAULT NULL,
			p_effective_date		IN DATE		DEFAULT hr_api.g_sys,
			p_error_when_not_exist		IN VARCHAR2	DEFAULT 'TRUE') RETURN PAY_FORMULA_RESULT_RULES_F%ROWTYPE
--------------------------------------------------------------------------------
	IS
		l_unique_column_tbl	UniColTbl;
		l_csr			RefCsr;
		l_rec			PAY_FORMULA_RESULT_RULES_F%ROWTYPE;
	BEGIN
		unique_tbl_constructor('STATUS_PROCESSING_RULE_ID','N',to_char(p_status_processing_rule_id),l_unique_column_tbl);
		unique_tbl_constructor('RESULT_NAME','T',p_result_name,l_unique_column_tbl);
		unique_tbl_constructor('RESULT_RULE_TYPE','T',p_result_rule_type,l_unique_column_tbl);
		unique_tbl_constructor('ELEMENT_TYPE_ID + 0','N',to_char(p_element_type_id),l_unique_column_tbl);
		unique_tbl_constructor('INPUT_VALUE_ID + 0','N',to_char(p_input_value_id),l_unique_column_tbl);
		bus_leg_constructor(p_business_group_id,p_legislation_code,l_unique_column_tbl);

		l_csr := csr('PAY_FORMULA_RESULT_RULES_F',l_unique_column_tbl,'DATETRACKED',p_effective_date);
		fetch l_csr into l_rec;
		if not csr_found_and_close(l_csr,p_error_when_not_exist) then
			l_rec := NULL;
		end if;

		return l_rec;
	END;
--------------------------------------------------------------------------------
	FUNCTION formula_result_rule_id(
			p_status_processing_rule_id	IN NUMBER,
			p_result_name			IN VARCHAR2,
			p_result_rule_type		IN VARCHAR2,
			p_element_type_id		IN NUMBER	DEFAULT NULL,
			p_input_value_id		IN NUMBER	DEFAULT NULL,
			p_business_group_id		IN NUMBER	DEFAULT NULL,
			p_legislation_code		IN VARCHAR2	DEFAULT NULL,
			p_effective_date		IN DATE		DEFAULT hr_api.g_sys,
			p_error_when_not_exist		IN VARCHAR2	DEFAULT 'TRUE') RETURN NUMBER
--------------------------------------------------------------------------------
	IS
	BEGIN
		return formula_result_rule_rec(
				p_status_processing_rule_id,p_result_name,p_result_rule_type,p_element_type_id,p_input_value_id,
				p_business_group_id,p_legislation_code,p_effective_date,p_error_when_not_exist).formula_result_rule_id;
	END;
--------------------------------------------------------------------------------
	FUNCTION sub_classification_rule_rec(
			p_element_type_id		IN NUMBER,
			p_classification_id		IN NUMBER,
			p_business_group_id		IN NUMBER,
			p_legislation_code		IN VARCHAR2,
			p_effective_date		IN DATE		DEFAULT hr_api.g_sys,
			p_error_when_not_exist		IN VARCHAR2	DEFAULT 'TRUE') RETURN PAY_SUB_CLASSIFICATION_RULES_F%ROWTYPE
--------------------------------------------------------------------------------
	IS
		l_unique_column_tbl	UniColTbl;
		l_csr			RefCsr;
		l_rec			PAY_SUB_CLASSIFICATION_RULES_F%ROWTYPE;
	BEGIN
		unique_tbl_constructor('ELEMENT_TYPE_ID','N',to_char(p_element_type_id),l_unique_column_tbl);
		unique_tbl_constructor('CLASSIFICATION_ID','N',to_char(p_classification_id),l_unique_column_tbl);
		bus_leg_constructor(p_business_group_id,p_legislation_code,l_unique_column_tbl);

		l_csr := csr('PAY_SUB_CLASSIFICATION_RULES_F',l_unique_column_tbl,'DATETRACKED',p_effective_date);
		fetch l_csr into l_rec;
		if not csr_found_and_close(l_csr,p_error_when_not_exist) then
			l_rec := NULL;
		end if;

		return l_rec;
	END;
--------------------------------------------------------------------------------
	FUNCTION sub_classification_rule_id(
			p_element_type_id		IN NUMBER,
			p_classification_id		IN NUMBER,
			p_business_group_id		IN NUMBER,
			p_legislation_code		IN VARCHAR2,
			p_effective_date		IN DATE		DEFAULT hr_api.g_sys,
			p_error_when_not_exist		IN VARCHAR2	DEFAULT 'TRUE') RETURN NUMBER
--------------------------------------------------------------------------------
	IS
	BEGIN
		return sub_classification_rule_rec(
				p_element_type_id,p_classification_id,p_business_group_id,p_legislation_code,
				p_effective_date,p_error_when_not_exist).sub_classification_rule_id;
	END;
--------------------------------------------------------------------------------
	FUNCTION element_link_id(
			p_assignment_id			IN NUMBER,
			p_element_type_id		IN NUMBER,
			p_effective_date		IN DATE		DEFAULT hr_api.g_sys,
			p_error_when_not_exist		IN VARCHAR2	DEFAULT 'TRUE') RETURN NUMBER
--------------------------------------------------------------------------------
	IS
		l_element_link_id	NUMBER;
	BEGIN
		l_element_link_id := hr_entry_api.get_link(p_assignment_id,p_element_type_id,p_effective_date);

		if p_error_when_not_exist = 'TRUE' and l_element_link_id is NULL then
			fnd_message.set_name('PAY','HR_51271_ELE_NOT_ELIGIBLE');
			fnd_message.raise_error;
		end if;

		return l_element_link_id;
	END;
--------------------------------------------------------------------------------
	FUNCTION element_link_id(
			p_assignment_number		IN VARCHAR2,
			p_element_name			IN VARCHAR2,
			p_business_group_id		IN NUMBER,
			p_effective_date		IN DATE		DEFAULT hr_api.g_sys,
			p_error_when_not_exist		IN VARCHAR2	DEFAULT 'TRUE') RETURN NUMBER
--------------------------------------------------------------------------------
	IS
		l_assignment_id		NUMBER;
		l_element_type_id	NUMBER;
	BEGIN
		l_assignment_id		:= emp_assignment_id(p_assignment_number,p_business_group_id,p_error_when_not_exist);
		l_element_type_id	:= element_type_id(p_element_name,p_business_group_id,NULL,p_error_when_not_exist);

		return element_link_id(l_assignment_id,l_element_type_id,p_effective_date,p_error_when_not_exist);
	END;
--------------------------------------------------------------------------------
	FUNCTION org_information_rec(
			p_organization_id		IN NUMBER,
			p_org_information_context	IN VARCHAR2,
			p_org_information1		IN VARCHAR2	DEFAULT NULL,
			p_error_when_not_exist		IN VARCHAR2	DEFAULT 'TRUE') RETURN HR_ORGANIZATION_INFORMATION%ROWTYPE
--------------------------------------------------------------------------------
	IS
		l_unique_column_tbl	UniColTbl;
		l_csr			RefCsr;
		l_rec			HR_ORGANIZATION_INFORMATION%ROWTYPE;
	BEGIN
		unique_tbl_constructor('ORGANIZATION_ID','N',to_char(p_organization_id),l_unique_column_tbl);
		unique_tbl_constructor('ORG_INFORMATION_CONTEXT','T',p_org_information_context,l_unique_column_tbl);
		if p_org_information_context = 'CLASS' then
			unique_tbl_constructor('ORG_INFORMATION1','T',p_org_information1,l_unique_column_tbl);
		end if;

		l_csr := csr('HR_ORGANIZATION_INFORMATION',l_unique_column_tbl);
		fetch l_csr into l_rec;
		if not csr_found_and_close(l_csr,p_error_when_not_exist) then
			l_rec := NULL;
		end if;

		return l_rec;
	END;
--------------------------------------------------------------------------------
	FUNCTION org_information_id(
			p_organization_id		IN NUMBER,
			p_org_information_context	IN VARCHAR2,
			p_org_information1		IN VARCHAR2	DEFAULT NULL,
			p_error_when_not_exist		IN VARCHAR2	DEFAULT 'TRUE') RETURN NUMBER
--------------------------------------------------------------------------------
	IS
	BEGIN
		return org_information_rec(p_organization_id,p_org_information_context,p_org_information1,p_error_when_not_exist).org_information_id;
	END;
--------------------------------------------------------------------------------
	FUNCTION org_information_rec(
			p_name				IN VARCHAR2,
			p_org_information_context	IN VARCHAR2,
			p_org_information1		IN VARCHAR2	DEFAULT NULL,
			p_business_group_id		IN VARCHAR2,
			p_error_when_not_exist		IN VARCHAR2	DEFAULT 'TRUE') RETURN HR_ORGANIZATION_INFORMATION%ROWTYPE
--------------------------------------------------------------------------------
	IS
		l_organization_id	NUMBER;
	BEGIN
		l_organization_id := organization_id(p_name,p_business_group_id);

		return org_information_rec(l_organization_id,p_org_information_context,p_org_information1,p_error_when_not_exist);
	END;
--------------------------------------------------------------------------------
	FUNCTION org_information_id(
			p_name				IN VARCHAR2,
			p_org_information_context	IN VARCHAR2,
			p_org_information1		IN VARCHAR2	DEFAULT NULL,
			p_business_group_id		IN VARCHAR2,
			p_error_when_not_exist		IN VARCHAR2	DEFAULT 'TRUE') RETURN NUMBER
--------------------------------------------------------------------------------
	IS
	BEGIN
		return org_information_rec(p_name,p_org_information_context,p_org_information1,p_business_group_id,p_error_when_not_exist).org_information_id;
	END;
--------------------------------------------------------------------------------
	FUNCTION payment_defined_balance_rec(
			p_business_group_id		IN NUMBER,
			p_error_when_not_exist		IN VARCHAR2	DEFAULT 'TRUE') RETURN PAY_DEFINED_BALANCES%ROWTYPE
--------------------------------------------------------------------------------
	IS
		l_rec			PAY_DEFINED_BALANCES%ROWTYPE;
		l_legislation_code	VARCHAR2(2);
		CURSOR csr_payment_defined_balance_id IS
			select	pdb.*
			from	pay_balance_dimensions	pbd,
				pay_defined_balances	pdb,
				pay_balance_types	pbt
			where	pbt.assignment_remuneration_flag='Y'
			and	nvl(pbt.business_group_id,p_business_group_id)=p_business_group_id
			and	nvl(pbt.legislation_code,l_legislation_code)=l_legislation_code
			and	pdb.balance_type_id=pbt.balance_type_id
			and	nvl(pdb.business_group_id,p_business_group_id)=p_business_group_id
			and	nvl(pdb.legislation_code,l_legislation_code)=l_legislation_code
			and	pbd.balance_dimension_id=pdb.balance_dimension_id
			and	nvl(pbd.business_group_id,p_business_group_id)=p_business_group_id
			and	nvl(pbd.legislation_code,l_legislation_code)=l_legislation_code
			and	pbd.payments_flag='Y';
	BEGIN
		l_legislation_code :=  legislation_code(p_business_group_id);

		open csr_payment_defined_balance_id;
		fetch csr_payment_defined_balance_id into l_rec;
		if csr_payment_defined_balance_id%NOTFOUND then
			if p_error_when_not_exist = 'TRUE' then
				close csr_payment_defined_balance_id;

				fnd_message.set_name('PER','HR_JP_ID_NOT_FOUND');
				fnd_message.raise_error;
			else
				l_rec := NULL;
			end if;
		end if;
		close csr_payment_defined_balance_id;

		return l_rec;
	END;
--------------------------------------------------------------------------------
	FUNCTION payment_defined_balance_id(
			p_business_group_id		IN NUMBER,
			p_error_when_not_exist		IN VARCHAR2	DEFAULT 'TRUE') RETURN NUMBER
--------------------------------------------------------------------------------
	IS
	BEGIN
		return payment_defined_balance_rec(p_business_group_id,p_error_when_not_exist).defined_balance_id;
	END;
--------------------------------------------------------------------------------
	FUNCTION legislation_rule_mode(
			p_legislation_code		IN VARCHAR2,
			p_rule_type			IN VARCHAR2,
			p_error_when_not_exist		IN VARCHAR2	DEFAULT 'TRUE') RETURN VARCHAR2
--------------------------------------------------------------------------------
	IS
		l_unique_column_tbl	UniColTbl;
		l_csr			RefCsr;
		l_rec			PAY_LEGISLATION_RULES%ROWTYPE;
	BEGIN
		unique_tbl_constructor('LEGISLATION_CODE','T',p_legislation_code,l_unique_column_tbl);
		unique_tbl_constructor('RULE_TYPE','T',p_rule_type,l_unique_column_tbl);

		l_csr := csr('PAY_LEGISLATION_RULES',l_unique_column_tbl);
		fetch l_csr into l_rec;
		if not csr_found_and_close(l_csr,p_error_when_not_exist) then
			l_rec := NULL;
		end if;

		return l_rec.rule_mode;
	END;
--------------------------------------------------------------------------------
	FUNCTION payment_type_rec(
			p_payment_type_name		IN VARCHAR2,
			p_territory_code		IN VARCHAR2	DEFAULT NULL,
			p_error_when_not_exist		IN VARCHAR2	DEFAULT 'TRUE') RETURN PAY_PAYMENT_TYPES%ROWTYPE
--------------------------------------------------------------------------------
	IS
		l_unique_column_tbl	UniColTbl;
		l_csr			RefCsr;
		l_rec			PAY_PAYMENT_TYPES%ROWTYPE;
	BEGIN
		unique_tbl_constructor('PAYMENT_TYPE_NAME','T',p_payment_type_name,l_unique_column_tbl);
		if p_territory_code = C_DEFAULT_LEG then
			NULL;
		else
			unique_tbl_constructor('nvl(TERRITORY_CODE,''' || p_territory_code || ''')','T',p_territory_code,l_unique_column_tbl);
		end if;

		l_csr := csr('PAY_PAYMENT_TYPES',l_unique_column_tbl);
		fetch l_csr into l_rec;
		if not csr_found_and_close(l_csr,p_error_when_not_exist) then
			l_rec := NULL;
		end if;

		return l_rec;
	END;
--------------------------------------------------------------------------------
	FUNCTION payment_type_id(
			p_payment_type_name		IN VARCHAR2,
			p_territory_code		IN VARCHAR2	DEFAULT NULL,
			p_error_when_not_exist		IN VARCHAR2	DEFAULT 'TRUE') RETURN VARCHAR2
--------------------------------------------------------------------------------
	IS
	BEGIN
		return payment_type_rec(p_payment_type_name,p_territory_code,p_error_when_not_exist).payment_type_id;
	END;
--------------------------------------------------------------------------------
	FUNCTION grade_rule_rec(
			p_rate_id			IN NUMBER,
			p_grade_id			IN NUMBER,
--			p_rate_type			IN VARCHAR2,
			p_error_when_not_exist		IN VARCHAR2	DEFAULT 'TRUE') RETURN PAY_GRADE_RULES_F%ROWTYPE
--------------------------------------------------------------------------------
	IS
		l_unique_column_tbl	UniColTbl;
		l_csr			RefCsr;
		l_rec			PAY_GRADE_RULES_F%ROWTYPE;
	BEGIN
		unique_tbl_constructor('RATE_ID','N',to_char(p_rate_id),l_unique_column_tbl);
		unique_tbl_constructor('GRADE_OR_SPINAL_POINT_ID','N',to_char(p_grade_id),l_unique_column_tbl);
		-- Current version supports only 'GRADE'. 'SPINAL POINT' is not supported.
		unique_tbl_constructor('RATE_TYPE','T','G',l_unique_column_tbl);

		l_csr := csr('PAY_GRADE_RULES_F',l_unique_column_tbl);
		fetch l_csr into l_rec;
		if not csr_found_and_close(l_csr,p_error_when_not_exist) then
			l_rec := NULL;
		end if;

		return l_rec;
	END;
--------------------------------------------------------------------------------
	FUNCTION grade_rule_id(
			p_rate_id			IN NUMBER,
			p_grade_id			IN NUMBER,
--			p_rate_type			IN VARCHAR2,
			p_error_when_not_exist		IN VARCHAR2	DEFAULT 'TRUE') RETURN NUMBER
--------------------------------------------------------------------------------
	IS
	BEGIN
		return grade_rule_rec(p_rate_id,p_grade_id,p_error_when_not_exist).grade_rule_id;
	END;
--------------------------------------------------------------------------------
	FUNCTION flex_value_set_rec(
			p_flex_value_set_name		IN VARCHAR2,
			p_error_when_not_exist		IN VARCHAR2	DEFAULT 'TRUE') RETURN FND_FLEX_VALUE_SETS%ROWTYPE
--------------------------------------------------------------------------------
	IS
		l_unique_column_tbl	UniColTbl;
		l_csr			RefCsr;
		l_rec			FND_FLEX_VALUE_SETS%ROWTYPE;
	BEGIN
		unique_tbl_constructor('FLEX_VALUE_SET_NAME','T',p_flex_value_set_name,l_unique_column_tbl);

		l_csr := csr('FND_FLEX_VALUE_SETS',l_unique_column_tbl);
		fetch l_csr into l_rec;
		if not csr_found_and_close(l_csr,p_error_when_not_exist) then
			l_rec := NULL;
		end if;

		return l_rec;
	END;
--------------------------------------------------------------------------------
	FUNCTION flex_value_set_id(
			p_flex_value_set_name		IN VARCHAR2,
			p_error_when_not_exist		IN VARCHAR2	DEFAULT 'TRUE') RETURN NUMBER
--------------------------------------------------------------------------------
	IS
	BEGIN
		return flex_value_set_rec(p_flex_value_set_name,p_error_when_not_exist).flex_value_set_id;
	END;
--------------------------------------------------------------------------------
	FUNCTION flex_value_rec(
			p_flex_value_set_id		IN NUMBER,
			p_flex_value			IN VARCHAR2,
			p_error_when_not_exist		IN VARCHAR2	DEFAULT 'TRUE') RETURN FND_FLEX_VALUES%ROWTYPE
--------------------------------------------------------------------------------
	IS
		l_unique_column_tbl	UniColTbl;
		l_csr			RefCsr;
		l_rec			FND_FLEX_VALUES%ROWTYPE;
	BEGIN
		unique_tbl_constructor('FLEX_VALUE_SET_ID','N',to_char(p_flex_value_set_id),l_unique_column_tbl);
		unique_tbl_constructor('FLEX_VALUE','T',p_flex_value,l_unique_column_tbl);

		l_csr := csr('FND_FLEX_VALUES',l_unique_column_tbl);
		fetch l_csr into l_rec;
		if not csr_found_and_close(l_csr,p_error_when_not_exist) then
			l_rec := NULL;
		end if;

		return l_rec;
	END;
--------------------------------------------------------------------------------
	FUNCTION flex_value_id(
			p_flex_value_set_id		IN NUMBER,
			p_flex_value			IN VARCHAR2,
			p_error_when_not_exist		IN VARCHAR2	DEFAULT 'TRUE') RETURN NUMBER
--------------------------------------------------------------------------------
	IS
	BEGIN
		return flex_value_rec(p_flex_value_set_id,p_flex_value,p_error_when_not_exist).flex_value_id;
	END;
--------------------------------------------------------------------------------
	FUNCTION period_of_service_rec(
			p_employee_number		IN VARCHAR2,
			p_business_group_id		IN NUMBER,
			p_effective_date		IN DATE		DEFAULT hr_api.g_sys,
			p_error_when_not_exist		IN VARCHAR2	DEFAULT 'TRUE') RETURN PER_PERIODS_OF_SERVICE%ROWTYPE
--------------------------------------------------------------------------------
	IS
		l_rec	PER_PERIODS_OF_SERVICE%ROWTYPE;
		CURSOR csr_period_of_service IS
			select	pps.*
			from	per_periods_of_service	pps,
				per_all_people_f	pp
			where	pp.employee_number=p_employee_number
			and	pp.business_group_id=p_business_group_id
			and	p_effective_date
				between pp.effective_start_date and pp.effective_end_date
			and	pps.person_id=pp.person_id
			and	(	pps.date_start=(
						select	max(pps2.date_start)
						from	per_periods_of_service	pps2
						where	pps2.person_id=pp.person_id
						and	pps2.date_start <= pp.effective_end_date)
				);
	BEGIN
		open csr_period_of_service;
		fetch csr_period_of_service into l_rec;
		if csr_period_of_service%NOTFOUND then
			if p_error_when_not_exist = 'TRUE' then
				close csr_period_of_service;

				fnd_message.set_name('PER','HR_JP_PERSON_NOT_FOUND');
				fnd_message.set_token('EMPLOYEE_NUMBER',p_employee_number);
				fnd_message.raise_error;
			end if;
		end if;
		close csr_period_of_service;

		return l_rec;
	END;
--------------------------------------------------------------------------------
	FUNCTION element_entry_rec(
			p_assignment_id			IN VARCHAR2,
			p_element_type_id		IN VARCHAR2,
			p_entry_type			IN VARCHAR2	DEFAULT 'E',
			p_effective_date		IN DATE		DEFAULT hr_api.g_sys,
			p_error_when_not_exist		IN VARCHAR2	DEFAULT 'TRUE') RETURN PAY_ELEMENT_ENTRIES_F%ROWTYPE
--------------------------------------------------------------------------------
	IS
		l_rec			PAY_ELEMENT_ENTRIES_F%ROWTYPE;
		CURSOR csr_element_entry(
					p_assignment_id		NUMBER,
					p_element_type_id	NUMBER) IS
			select	pee.*
			from	pay_element_links_f	pel,
				pay_element_entries_f	pee
			where	pee.assignment_id=p_assignment_id
			and	pee.entry_type=p_entry_type
			and	p_effective_date
				between pee.effective_start_date and pee.effective_end_date
			and	pel.element_link_id=pee.element_link_id
			and	pel.element_type_id=p_element_type_id
			and	p_effective_date
				between pel.effective_start_date and pel.effective_end_date
			and	pee.entry_type='E'
			order by pee.element_entry_id;
	BEGIN
		open csr_element_entry(p_assignment_id,p_element_type_id);
		fetch csr_element_entry into l_rec;
		if csr_element_entry%NOTFOUND then
			if p_error_when_not_exist = 'TRUE' then
				close csr_element_entry;

				fnd_message.set_name('PER','HR_JP_ELEMENT_ENTRY_NOT_FOUND');
				fnd_message.raise_error;
			else
				l_rec := NULL;
			end if;
		end if;
		close csr_element_entry;

		return l_rec;
	END;
--------------------------------------------------------------------------------
	FUNCTION element_entry_rec(
			p_assignment_number		IN VARCHAR2,
			p_element_name			IN VARCHAR2,
			p_entry_type			IN VARCHAR2	DEFAULT 'E',
			p_business_group_id		IN NUMBER,
			p_effective_date		IN DATE		DEFAULT hr_api.g_sys,
			p_error_when_not_exist		IN VARCHAR2	DEFAULT 'TRUE') RETURN PAY_ELEMENT_ENTRIES_F%ROWTYPE
--------------------------------------------------------------------------------
	IS
		l_assignment_id		NUMBER := emp_assignment_id(p_assignment_number,p_business_group_id);
		l_element_type_id	NUMBER := element_type_id(p_element_name,p_business_group_id);
	BEGIN
		return element_entry_rec(l_assignment_id,l_element_type_id,p_entry_type,p_business_group_id,p_effective_date,p_error_when_not_exist);
	END;
--------------------------------------------------------------------------------
	FUNCTION address_rec(
		-- primary_flag has higher priority then address_type.
		-- If you pass both p_primary_flag = 'N' and p_address_type is NULL,
		-- record this function returns is inexact.
			p_person_id			IN NUMBER,
			p_primary_flag			IN VARCHAR2	DEFAULT 'Y',
			p_address_type			IN VARCHAR2	DEFAULT NULL,
			p_effective_date		IN DATE		DEFAULT hr_api.g_sys,
			p_error_when_not_exist		IN VARCHAR2	DEFAULT 'TRUE') RETURN PER_ADDRESSES%ROWTYPE
--------------------------------------------------------------------------------
	IS
		l_unique_column_tbl	UniColTbl;
		l_csr			RefCsr;
		l_rec			PER_ADDRESSES%ROWTYPE;
	BEGIN
		unique_tbl_constructor('PERSON_ID','N',to_char(p_person_id),l_unique_column_tbl);
		if p_primary_flag = 'Y' then
			unique_tbl_constructor('PRIMARY_FLAG','T',p_primary_flag,l_unique_column_tbl);
		else
			unique_tbl_constructor('ADDRESS_TYPE','T',p_address_type,l_unique_column_tbl);
		end if;
		l_csr := csr('PER_ADDRESSES',l_unique_column_tbl,'DATED',p_effective_date);
		fetch l_csr into l_rec;
		if l_csr%NOTFOUND then
			if p_error_when_not_exist = 'TRUE' then
				close l_csr;
				fnd_message.set_name('PER','HR_JP_ID_NOT_FOUND');
				fnd_message.set_token('SQL',g_sql);
				fnd_message.raise_error;
			else
				l_rec := NULL;
			end if;
		end if;
		close l_csr;

		return l_rec;
	END;
--------------------------------------------------------------------------------
	FUNCTION primary_address_rec(
		-- This function is valid when address_type is not NULL.
			p_person_id			IN NUMBER,
			p_effective_date		IN DATE		DEFAULT hr_api.g_sys,
			p_error_when_not_exist		IN VARCHAR2	DEFAULT 'TRUE') RETURN PER_ADDRESSES%ROWTYPE
--------------------------------------------------------------------------------
	IS
	BEGIN
		return address_rec(p_person_id,'Y',NULL,p_effective_date,p_error_when_not_exist);
	END;
--------------------------------------------------------------------------------
	FUNCTION address_rec(
		-- This function is valid when address_type is not NULL.
			p_person_id			IN NUMBER,
			p_address_type			IN VARCHAR2,
			p_effective_date		IN DATE		DEFAULT hr_api.g_sys,
			p_error_when_not_exist		IN VARCHAR2	DEFAULT 'TRUE') RETURN PER_ADDRESSES%ROWTYPE
--------------------------------------------------------------------------------
	IS
	BEGIN
		return address_rec(p_person_id,'N',p_address_type,p_effective_date,p_error_when_not_exist);
	END;
--------------------------------------------------------------------------------
	FUNCTION emp_primary_address_rec(
		-- This function is valid when address_type is not NULL.
			p_employee_number		IN VARCHAR2,
			p_business_group_id		IN NUMBER,
			p_effective_date		IN DATE		DEFAULT hr_api.g_sys,
			p_error_when_not_exist		IN VARCHAR2	DEFAULT 'TRUE') RETURN PER_ADDRESSES%ROWTYPE
--------------------------------------------------------------------------------
	IS
		l_person_id	NUMBER;
	BEGIN
		l_person_id := emp_person_id(p_employee_number,p_business_group_id);

		return primary_address_rec(l_person_id,p_effective_date,p_error_when_not_exist);
	END;
--------------------------------------------------------------------------------
	FUNCTION emp_address_rec(
		-- This function is valid when address_type is not NULL.
			p_employee_number		IN VARCHAR2,
			p_address_type			IN VARCHAR2,
			p_business_group_id		IN NUMBER,
			p_effective_date		IN DATE		DEFAULT hr_api.g_sys,
			p_error_when_not_exist		IN VARCHAR2	DEFAULT 'TRUE') RETURN PER_ADDRESSES%ROWTYPE
--------------------------------------------------------------------------------
	IS
		l_person_id	NUMBER;
	BEGIN
		l_person_id := emp_person_id(p_employee_number,p_business_group_id);

		return address_rec(l_person_id,p_address_type,p_effective_date,p_error_when_not_exist);
	END;
--------------------------------------------------------------------------------
	FUNCTION apl_primary_address_rec(
		-- This function is valid when address_type is not NULL.
			p_applicant_number		IN VARCHAR2,
			p_business_group_id		IN NUMBER,
			p_effective_date		IN DATE		DEFAULT hr_api.g_sys,
			p_error_when_not_exist		IN VARCHAR2	DEFAULT 'TRUE') RETURN PER_ADDRESSES%ROWTYPE
--------------------------------------------------------------------------------
	IS
		l_person_id	NUMBER;
	BEGIN
		l_person_id := apl_person_id(p_applicant_number,p_business_group_id);

		return primary_address_rec(l_person_id,p_effective_date,p_error_when_not_exist);
	END;
--------------------------------------------------------------------------------
	FUNCTION apl_address_rec(
		-- This function is valid when address_type is not NULL.
			p_applicant_number		IN VARCHAR2,
			p_address_type			IN VARCHAR2,
			p_business_group_id		IN NUMBER,
			p_effective_date		IN DATE		DEFAULT hr_api.g_sys,
			p_error_when_not_exist		IN VARCHAR2	DEFAULT 'TRUE') RETURN PER_ADDRESSES%ROWTYPE
--------------------------------------------------------------------------------
	IS
		l_person_id	NUMBER;
	BEGIN
		l_person_id := apl_person_id(p_applicant_number,p_business_group_id);

		return address_rec(l_person_id,p_address_type,p_effective_date,p_error_when_not_exist);
	END;
--------------------------------------------------------------------------------
	FUNCTION personal_payment_method_rec(
			p_assignment_id			IN NUMBER,
			p_priority			IN NUMBER,
			p_effective_date		IN DATE		DEFAULT hr_api.g_sys,
			p_error_when_not_exist		IN VARCHAR2	DEFAULT 'TRUE') RETURN PAY_PERSONAL_PAYMENT_METHODS_F%ROWTYPE
--------------------------------------------------------------------------------
	IS
		l_unique_column_tbl	UniColTbl;
		l_csr			RefCsr;
		l_rec			PAY_PERSONAL_PAYMENT_METHODS_F%ROWTYPE;
	BEGIN
		unique_tbl_constructor('ASSIGNMENT_ID','N',to_char(p_assignment_id),l_unique_column_tbl);
		unique_tbl_constructor('PRIORITY','N',to_char(p_priority),l_unique_column_tbl);
		l_csr := csr('PAY_PERSONAL_PAYMENT_METHODS_F',l_unique_column_tbl,'DATETRACKED',p_effective_date);
		fetch l_csr into l_rec;
		if l_csr%NOTFOUND then
			if p_error_when_not_exist = 'TRUE' then
				close l_csr;
				fnd_message.set_name('PER','HR_JP_ID_NOT_FOUND');
				fnd_message.set_token('SQL',g_sql);
				fnd_message.raise_error;
			else
				l_rec := NULL;
			end if;
		end if;
		close l_csr;

		return l_rec;
	END;
--------------------------------------------------------------------------------
	FUNCTION personal_payment_method_rec(
			p_assignment_number		IN VARCHAR2,
			p_priority			IN NUMBER,
			p_business_group_id		IN NUMBER,
			p_effective_date		IN DATE		DEFAULT hr_api.g_sys,
			p_error_when_not_exist		IN VARCHAR2	DEFAULT 'TRUE') RETURN PAY_PERSONAL_PAYMENT_METHODS_F%ROWTYPE
--------------------------------------------------------------------------------
	IS
		l_assignment_id		NUMBER;
	BEGIN
		l_assignment_id := emp_assignment_id(p_assignment_number,p_business_group_id);

		return personal_payment_method_rec(l_assignment_id,p_priority,p_effective_date,p_error_when_not_exist);
	END;
--------------------------------------------------------------------------------
	FUNCTION JP_BANK_REC(
			P_BANK_CODE			IN VARCHAR2,
			P_BRANCH_CODE			IN VARCHAR2,
			p_error_when_not_exist		IN VARCHAR2	DEFAULT 'TRUE') RETURN PER_JP_BANK_LOOKUPS%ROWTYPE
--------------------------------------------------------------------------------
	IS
		l_unique_column_tbl	UniColTbl;
		l_csr			RefCsr;
		l_rec			PER_JP_BANK_LOOKUPS%ROWTYPE;
	BEGIN
		unique_tbl_constructor('BANK_CODE','T',p_bank_code,l_unique_column_tbl);
		unique_tbl_constructor('BRANCH_CODE','T',p_branch_code,l_unique_column_tbl);
		l_csr := csr('PER_JP_BANK_LOOKUPS',l_unique_column_tbl);
		fetch l_csr into l_rec;
		if l_csr%NOTFOUND then
			if p_error_when_not_exist = 'TRUE' then
				close l_csr;
				fnd_message.set_name('PER','HR_JP_ID_NOT_FOUND');
				fnd_message.set_token('SQL',g_sql);
				fnd_message.raise_error;
			else
				l_rec := NULL;
			end if;
		end if;
		close l_csr;

		return l_rec;
	END;
--------------------------------------------------------------------------------
	FUNCTION element_link_rec(
			P_ELEMENT_TYPE_ID		IN NUMBER,
			P_ORGANIZATION_ID		IN NUMBER	DEFAULT NULL,
			P_PEOPLE_GROUP_ID		IN NUMBER	DEFAULT NULL,
			P_JOB_ID			IN NUMBER	DEFAULT NULL,
			P_POSITION_ID			IN NUMBER	DEFAULT NULL,
			P_GRADE_ID			IN NUMBER	DEFAULT NULL,
			P_LOCATION_ID			IN NUMBER	DEFAULT NULL,
			P_EMPLOYMENT_CATEGORY		IN VARCHAR2	DEFAULT NULL,
			P_PAYROLL_ID			IN NUMBER	DEFAULT NULL,
			P_LINK_TO_ALL_PAYROLLS_FLAG	IN VARCHAR2	DEFAULT 'N',
			P_PAY_BASIS_ID			IN NUMBER	DEFAULT NULL,
			P_BUSINESS_GROUP_ID		IN NUMBER,
			P_EFFECTIVE_DATE		IN DATE		DEFAULT hr_api.g_sys,
			P_ERROR_WHEN_NOT_EXIST		IN VARCHAR2	DEFAULT 'TRUE') RETURN PAY_ELEMENT_LINKS_F%ROWTYPE
--------------------------------------------------------------------------------
	IS
		l_unique_column_tbl	UniColTbl;
		l_csr			RefCsr;
		l_rec			PAY_ELEMENT_LINKS_F%ROWTYPE;
	BEGIN
		unique_tbl_constructor('ELEMENT_TYPE_ID','N',to_char(p_element_type_id),l_unique_column_tbl);
		unique_tbl_constructor('ORGANIZATION_ID','N',to_char(p_organization_id),l_unique_column_tbl);
		unique_tbl_constructor('PEOPLE_GROUP_ID','N',to_char(p_people_group_id),l_unique_column_tbl);
		unique_tbl_constructor('JOB_ID','N',to_char(p_job_id),l_unique_column_tbl);
		unique_tbl_constructor('POSITION_ID','N',to_char(p_position_id),l_unique_column_tbl);
		unique_tbl_constructor('GRADE_ID','N',to_char(p_grade_id),l_unique_column_tbl);
		unique_tbl_constructor('LOCATION_ID','N',to_char(p_location_id),l_unique_column_tbl);
		unique_tbl_constructor('EMPLOYMENT_CATEGORY','T',p_employment_category,l_unique_column_tbl);
		unique_tbl_constructor('PAYROLL_ID','N',to_char(p_payroll_id),l_unique_column_tbl);
		unique_tbl_constructor('LINK_TO_ALL_PAYROLLS_FLAG','T',p_link_to_all_payrolls_flag,l_unique_column_tbl);
		unique_tbl_constructor('PAY_BASIS_ID','N',to_char(p_pay_basis_id),l_unique_column_tbl);
		unique_tbl_constructor('BUSINESS_GROUP_ID + 0','N',to_char(p_business_group_id),l_unique_column_tbl);
		l_csr := csr('PAY_ELEMENT_LINKS_F',l_unique_column_tbl,'DATETRACKED',p_effective_date);
		fetch l_csr into l_rec;
		if l_csr%NOTFOUND then
			if p_error_when_not_exist = 'TRUE' then
				close l_csr;
				fnd_message.set_name('PER','HR_JP_ID_NOT_FOUND');
				fnd_message.set_token('SQL',g_sql);
				fnd_message.raise_error;
			else
				l_rec := NULL;
			end if;
		end if;
		close l_csr;

		return l_rec;
	END;
--------------------------------------------------------------------------------
	FUNCTION element_link_id(
			P_ELEMENT_TYPE_ID		IN NUMBER,
			P_ORGANIZATION_ID		IN NUMBER	DEFAULT NULL,
			P_PEOPLE_GROUP_ID		IN NUMBER	DEFAULT NULL,
			P_JOB_ID			IN NUMBER	DEFAULT NULL,
			P_POSITION_ID			IN NUMBER	DEFAULT NULL,
			P_GRADE_ID			IN NUMBER	DEFAULT NULL,
			P_LOCATION_ID			IN NUMBER	DEFAULT NULL,
			P_EMPLOYMENT_CATEGORY		IN VARCHAR2	DEFAULT NULL,
			P_PAYROLL_ID			IN NUMBER	DEFAULT NULL,
			P_LINK_TO_ALL_PAYROLLS_FLAG	IN VARCHAR2	DEFAULT 'N',
			P_PAY_BASIS_ID			IN NUMBER	DEFAULT NULL,
			P_BUSINESS_GROUP_ID		IN NUMBER,
			P_EFFECTIVE_DATE		IN DATE		DEFAULT hr_api.g_sys,
			P_ERROR_WHEN_NOT_EXIST		IN VARCHAR2	DEFAULT 'TRUE') RETURN NUMBER
--------------------------------------------------------------------------------
	IS
	BEGIN
		return element_link_rec(
				p_element_type_id,p_organization_id,p_people_group_id,p_job_id,p_position_id,
				p_grade_id,p_location_id,p_employment_category,p_payroll_id,p_link_to_all_payrolls_flag,
				p_pay_basis_id,p_business_group_id,p_effective_date,p_error_when_not_exist).element_link_id;
	END;
--------------------------------------------------------------------------------
	FUNCTION backpay_rule_rec(
			P_BACKPAY_SET_ID		IN NUMBER,
			P_DEFINED_BALANCE_ID		IN NUMBER,
			P_INPUT_VALUE_ID		IN NUMBER,
			P_ERROR_WHEN_NOT_EXIST		IN VARCHAR2	DEFAULT 'TRUE') RETURN PAY_BACKPAY_RULES%ROWTYPE
--------------------------------------------------------------------------------
	IS
		l_unique_column_tbl	UniColTbl;
		l_csr			RefCsr;
		l_rec			PAY_BACKPAY_RULES%ROWTYPE;
	BEGIN
		unique_tbl_constructor('BACKPAY_SET_ID','N',to_char(p_backpay_set_id),l_unique_column_tbl);
		unique_tbl_constructor('DEFINED_BALANCE_ID','N',to_char(p_defined_balance_id),l_unique_column_tbl);
		unique_tbl_constructor('INPUT_VALUE_ID','N',to_char(p_input_value_id),l_unique_column_tbl);
		l_csr := csr('PAY_BACKPAY_RULES',l_unique_column_tbl);
		fetch l_csr into l_rec;
		if l_csr%NOTFOUND then
			if p_error_when_not_exist = 'TRUE' then
				close l_csr;
				fnd_message.set_name('PER','HR_JP_ID_NOT_FOUND');
				fnd_message.set_token('SQL',g_sql);
				fnd_message.raise_error;
			else
				l_rec := NULL;
			end if;
		end if;
		close l_csr;

		return l_rec;
	END;
--------------------------------------------------------------------------------
	FUNCTION org_pay_method_usage_rec(
			P_PAYROLL_ID			IN NUMBER,
			P_ORG_PAYMENT_METHOD_ID		IN NUMBER,
			P_EFFECTIVE_DATE		IN DATE		DEFAULT hr_api.g_sys,
			P_ERROR_WHEN_NOT_EXIST		IN VARCHAR2	DEFAULT 'TRUE') RETURN PAY_ORG_PAY_METHOD_USAGES_F%ROWTYPE
--------------------------------------------------------------------------------
	IS
		l_unique_column_tbl	UniColTbl;
		l_csr			RefCsr;
		l_rec			PAY_ORG_PAY_METHOD_USAGES_F%ROWTYPE;
	BEGIN
		unique_tbl_constructor('PAYROLL_ID','N',to_char(p_payroll_id),l_unique_column_tbl);
		unique_tbl_constructor('ORG_PAYMENT_METHOD_ID','N',to_char(p_org_payment_method_id),l_unique_column_tbl);
		l_csr := csr('PAY_ORG_PAY_METHOD_USAGES_F',l_unique_column_tbl,'DATETRACKED',p_effective_date);
		fetch l_csr into l_rec;
		if l_csr%NOTFOUND then
			if p_error_when_not_exist = 'TRUE' then
				close l_csr;
				fnd_message.set_name('PER','HR_JP_ID_NOT_FOUND');
				fnd_message.set_token('SQL',g_sql);
				fnd_message.raise_error;
			else
				l_rec := NULL;
			end if;
		end if;
		close l_csr;

		return l_rec;
	END;
end;

/
