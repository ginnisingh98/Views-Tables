--------------------------------------------------------
--  DDL for Package Body HR_JP_STANDARD_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."HR_JP_STANDARD_PKG" AS
/* $Header: hrjpstnd.pkb 120.9 2006/12/05 07:44:51 ttagawa noship $ */
--
-- Constants
--
c_nls_lang		CONSTANT VARCHAR2(92) := userenv('LANGUAGE');
c_cset			CONSTANT VARCHAR2(30) := substr(c_nls_lang, instr(c_nls_lang, '.') + 1);
--
type t_hankaku is record(
	upper_alphabet	varchar2(255) := 'ABCDEFGHIJKLMNOPQRSTUVWXYZ',
	lower_alphabet	varchar2(255) := 'abcdefghijklmnopqrstuvwxyz',
	number		varchar2(255) := '0123456789',
	symbol		varchar2(255) := ' !"#$%&''()*+,-./:;<=>?@[\]^_`{|}~',
	kana		varchar2(255) := sjhextochar('B6B7B8B9BABBBCBDBEBFC0C1C3C4C5C6C7C8C9CACBCCCDCECFD0D1D2D3D7D8D9DADBDCA6DD'),
	upper_kana	varchar2(255) := sjhextochar('B1B2B3B4B5D4D5D6C2'),
	lower_kana	varchar2(255) := sjhextochar('A7A8A9AAABACADAEAF'),
	voiced_kana	varchar2(255) := sjhextochar('B3DEB6DEB7DEB8DEB9DEBADEBBDEBCDEBDDEBEDEBFDEC0DEC1DEC2DEC3DEC4DECADECBDECCDECDDECEDECADFCBDFCCDFCDDFCEDF'),
	jp_symbol	varchar2(255) := sjhextochar('A1A2A3A4A5B0DEDF'));
type t_zenkaku is record(
	upper_alphabet	varchar2(255) := sjhextochar('8260826182628263826482658266826782688269826A826B826C826D826E826F8270827182728273827482758276827782788279'),
	lower_alphabet	varchar2(255) := sjhextochar('828182828283828482858286828782888289828A828B828C828D828E828F8290829182928293829482958296829782988299829A'),
	number		varchar2(255) := sjhextochar('824F825082518252825382548255825682578258'),
	symbol		varchar2(255) := sjhextochar('814081498168819481908193819581668169816A8196817B8143817C8144815E8146814781838181818481488197816D818F816E814F8151814D816F816281708150'),
	kana		varchar2(255) := sjhextochar('834A834C834E83508352835483568358835A835C835E8360836583678369836A836B836C836D836E837183748377837A837D837E8380838183828389838A838B838C838D838F83928393'),
	upper_kana	varchar2(255) := sjhextochar('834183438345834783498384838683888363'),
	lower_kana	varchar2(255) := sjhextochar('834083428344834683488383838583878362'),
	voiced_kana	varchar2(255) := sjhextochar('8394834B834D834F83518353835583578359835B835D835F8361836483668368836F837283758378837B8370837383768379837C'),
	jp_symbol	varchar2(255) := sjhextochar('81428175817681418145815B814A814B'));
l_hankaku_dummy		t_hankaku;
l_zenkaku_dummy		t_zenkaku;
c_hankaku		constant t_hankaku := l_hankaku_dummy;
c_zenkaku		constant t_zenkaku := l_zenkaku_dummy;
-- |---------------------------------------------------------------------------|
-- |-------------------------------< hextochar >-------------------------------|
-- |---------------------------------------------------------------------------|
-- This function returns converted character in DB character set from
-- hexadecimal value(p_src) in p_src_cset character set as source.
-- When p_src_cset is invalid or NULL, VALUE_ERROR is raised.
--
FUNCTION hextochar(
	p_src		IN VARCHAR2,
	p_src_cset	IN VARCHAR2) RETURN VARCHAR2
IS
	l_raw		RAW(2000);
	l_src_lang	VARCHAR2(91);
BEGIN
	--
	-- utl_raw.convert fails when l_raw is null.
	--
	if p_src is NULL then
		return NULL;
	else
		--
		-- Convert raw value to DB character set and return value with casted to varchar2.
		--
		l_raw		:= hextoraw(p_src);
		l_src_lang	:= 'AMERICAN_AMERICA.' || p_src_cset;
		return utl_raw.cast_to_varchar2(utl_raw.convert(l_raw, c_nls_lang, l_src_lang));
	end if;
END hextochar;
-- |---------------------------------------------------------------------------|
-- |------------------------------< sjhextochar >------------------------------|
-- |---------------------------------------------------------------------------|
-- This function is wrapper of hextochar function with hexadicimal in SJIS.
--
FUNCTION sjhextochar(p_src IN VARCHAR2) RETURN VARCHAR2
IS
BEGIN
	return hextochar(p_src, 'JA16SJIS');
END sjhextochar;
-- |---------------------------------------------------------------------------|
-- |-------------------------------< chartohex >-------------------------------|
-- |---------------------------------------------------------------------------|
-- This function returns converted character in destination character set
-- (p_dest_cset) from character(p_src) in DB character set as source.
-- When p_dest_cset is invalid or NULL, VALUE_ERROR is raised.
--
FUNCTION chartohex(
	p_src		IN VARCHAR2,
	p_dest_cset	IN VARCHAR2) RETURN VARCHAR2
IS
	l_raw		RAW(2000);
	l_dest_lang	VARCHAR2(91);
BEGIN
	--
	-- utl_raw.convert fails when l_raw is null.
	--
	if p_src is NULL then
		return NULL;
	else
		--
		-- Convert raw value to DB character set and return value with casted to varchar2.
		--
		l_raw		:= utl_raw.cast_to_raw(p_src);
		l_dest_lang	:= 'AMERICAN_AMERICA.' || p_dest_cset;
		return rawtohex(utl_raw.convert(l_raw, l_dest_lang, c_nls_lang));
	end if;
END chartohex;
-- |---------------------------------------------------------------------------|
-- |------------------------------< chartosjhex >------------------------------|
-- |---------------------------------------------------------------------------|
-- This function is wrapper of chartohex function with hexadicimal in SJIS.
--
FUNCTION chartosjhex(p_src IN VARCHAR2) RETURN VARCHAR2
IS
BEGIN
	return chartohex(p_src, 'JA16SJIS');
END chartosjhex;
-- |---------------------------------------------------------------------------|
-- |------------------------------< translate2 >-------------------------------|
-- |---------------------------------------------------------------------------|
function translate2(
	p_str		in varchar2,
	p_old_chrs	in varchar2,
	p_new_chrs	in varchar2 default null) return varchar2
is
	l_str		varchar2(32767);
	l_new_chrs	varchar2(32767);
begin
	if p_str is not null and p_old_chrs is not null then
		if p_new_chrs is null then
			l_new_chrs := substr(p_old_chrs, 1, 1);
			--
			if l_new_chrs <> p_old_chrs then
				l_str := translate(p_str, p_old_chrs, l_new_chrs);
				--
				if l_str is not null then
					l_str := replace(l_str, l_new_chrs);
				end if;
			else
				l_str := replace(p_str, l_new_chrs);
			end if;
		else
			l_str := translate(p_str, p_old_chrs, p_new_chrs);
		end if;
		--
		return l_str;
	else
		return p_str;
	end if;
end translate2;
-- |---------------------------------------------------------------------------|
-- |---------------------------------< strip >---------------------------------|
-- |---------------------------------------------------------------------------|
function strip(
	p_str			in varchar2,
	p_chrs			in varchar2,
	p_replacement_chr	in varchar2 default null) return varchar2
is
	l_str		varchar2(32767);
	l_old_chrs	varchar2(32767);
	--
	function new_replacement_chrs(p_old_chrs in varchar2) return varchar2
	is
		l_new_chrs	varchar2(32767);
	begin
		if p_old_chrs is not null and p_replacement_chr is not null then
			if length(p_replacement_chr) > 1 then
				fnd_message.set_name('PER', 'HR_JP_INVALID_REPLACEMENT_CHR');
				fnd_message.set_token('REPLACEMENT_CHR', p_replacement_chr);
				fnd_message.raise_error;
			end if;
			--
			for i in 1..length(p_old_chrs) loop
				l_new_chrs := l_new_chrs || p_replacement_chr;
			end loop;
		end if;
		--
		return l_new_chrs;
	end new_replacement_chrs;
begin
	if p_str is not null then
		if p_chrs is not null then
			l_old_chrs := translate2(p_str, p_chrs);
			--
			if l_old_chrs is not null then
				l_str := translate2(p_str, l_old_chrs, new_replacement_chrs(l_old_chrs));
			else
				l_str := p_str;
			end if;
		else
			if p_replacement_chr is not null then
				l_str := new_replacement_chrs(p_str);
			end if;
		end if;
	end if;
	--
	return l_str;
end strip;
-- |---------------------------------------------------------------------------|
-- |---------------------------< recursive_replace >---------------------------|
-- |---------------------------------------------------------------------------|
--
-- Pay attention not to go into infinite loop
--
function recursive_replace(
	p_str		in varchar2,
	p_old_str	in varchar2,
	p_new_str	in varchar2 default null) return varchar2
is
	l_str		varchar2(32767);
	l_str2		varchar2(32767);
begin
	if p_str is not null and p_old_str is not null then
		l_str2 := p_str;
		loop
			l_str := replace(l_str2, p_old_str, p_new_str);
			if l_str is null or l_str = l_str2 then
				exit;
			else
				l_str2 := l_str;
			end if;
		end loop;
		--
		return l_str;
	else
		return p_str;
	end if;
end recursive_replace;
-- |---------------------------------------------------------------------------|
-- |--------------------------------< round2 >---------------------------------|
-- |---------------------------------------------------------------------------|
function round2(
	p_num		in number,
	p_places	in number default 0) return number
is
	l_num	number;
	l_pow	number;
begin
	if p_num is not null and p_places is not null then
		l_pow := power(10, trunc(p_places));
		--
		if p_num >= 0 then
			l_num := ceil(p_num * l_pow - 0.5) / l_pow;
		else
			l_num := floor(p_num * l_pow + 0.5) / l_pow;
		end if;
		--
		return l_num;
	else
		return null;
	end if;
end round2;
-- |---------------------------------------------------------------------------|
-- |------------------------------< is_integer >-------------------------------|
-- |---------------------------------------------------------------------------|
function is_integer(p_num in number) return varchar2
is
	l_is_integer	varchar2(1) := 'Y';
begin
	if p_num is not null then
		if floor(p_num) <> p_num then
			l_is_integer := 'N';
		end if;
	end if;
	--
	return l_is_integer;
end is_integer;
-- |---------------------------------------------------------------------------|
-- |------------------------------< is_hankaku >-------------------------------|
-- |---------------------------------------------------------------------------|
function is_hankaku(p_chr in varchar2) return boolean
is
	l_is_hankaku	boolean := true;
	l_chr		varchar2(32767);
begin
	if p_chr is not null then
		if p_chr <> rpad(p_chr, length(p_chr)) then
			l_is_hankaku := false;
		end if;
/*
		l_chr := translate(p_chr,
				' '				||
				c_hankaku.upper_alphabet	||
				c_hankaku.lower_alphabet	||
				c_hankaku.number		||
				c_hankaku.symbol		||
				c_hankaku.kana			||
				c_hankaku.upper_kana		||
				c_hankaku.lower_kana		||
				c_hankaku.jp_symbol, ' ');
		if replace(l_chr, ' ') is not null then
			l_is_hankaku := false;
		end if;
*/
	end if;
	--
	return l_is_hankaku;
end is_hankaku;
-- |---------------------------------------------------------------------------|
-- |------------------------------< is_zenkaku >-------------------------------|
-- |---------------------------------------------------------------------------|
function is_zenkaku(p_chr in varchar2) return boolean
is
	l_is_zenkaku	boolean := true;
	l_chr		varchar2(32767);
begin
	if p_chr is not null then
		if p_chr <> rpad(p_chr, length(p_chr) * 2) then
			l_is_zenkaku := false;
		end if;
	end if;
	--
	return l_is_zenkaku;
end is_zenkaku;
-- |---------------------------------------------------------------------------|
-- |------------------------------< to_hankaku >-------------------------------|
-- |---------------------------------------------------------------------------|
function to_hankaku(
	p_chr			in varchar2,
	p_replacement_chr	in varchar2) return varchar2
is
	l_str		varchar2(32767);
	l_old_str	varchar2(8);
	l_new_str	varchar2(8);
	l_old_chrs	varchar2(32767);
	l_new_chrs	varchar2(32767);
	l_length	number;
	l_index		number;
begin
	if p_chr is not null then
		l_str := translate(p_chr,
				c_zenkaku.upper_alphabet	||
				c_zenkaku.lower_alphabet	||
				c_zenkaku.number		||
				c_zenkaku.symbol		||
				c_zenkaku.kana			||
				c_zenkaku.upper_kana		||
				c_zenkaku.lower_kana		||
				c_zenkaku.jp_symbol,
				c_hankaku.upper_alphabet	||
				c_hankaku.lower_alphabet	||
				c_hankaku.number		||
				c_hankaku.symbol		||
				c_hankaku.kana			||
				c_hankaku.upper_kana		||
				c_hankaku.lower_kana		||
				c_hankaku.jp_symbol);
		--
		-- Replace Voiced Letters
		--
		for i in 1..length(c_zenkaku.voiced_kana) loop
			l_old_str := substr(c_zenkaku.voiced_kana, i, 1);
			l_new_str := substr(c_hankaku.voiced_kana, i * 2 - 1, 2);
			l_str := replace(l_str, l_old_str, l_new_str);
		end loop;
		--
		if p_replacement_chr is null or p_replacement_chr <> hr_api.g_varchar2 then
			if not is_hankaku(l_str) then
				--
				-- In most cases, length(l_src) will be very small number,
				-- which will not cause performance issue.
				--
				l_old_chrs := translate2(l_str,
						c_hankaku.upper_alphabet	||
						c_hankaku.lower_alphabet	||
						c_hankaku.number		||
						c_hankaku.symbol		||
						c_hankaku.kana			||
						c_hankaku.upper_kana		||
						c_hankaku.lower_kana		||
						c_hankaku.jp_symbol);
				--
				l_length := length(l_old_chrs);
				l_index := 1;
				while l_index <= l_length loop
					if is_hankaku(substr(l_old_chrs, l_index, 1)) then
						l_old_str := substr(l_old_chrs, 1, l_index - 1) || substr(l_old_chrs, l_index + 1);
						l_length := l_length - 1;
					else
						l_index := l_index + 1;
					end if;
				end loop;
				--
				if p_replacement_chr is not null then
					if length(p_replacement_chr) > 1 or not is_hankaku(p_replacement_chr) then
						fnd_message.set_name('PER', 'HR_JP_INVALID_REPLACEMENT_CHR');
						fnd_message.set_token('REPLACEMENT_CHR', p_replacement_chr);
						fnd_message.raise_error;
					end if;
					l_new_chrs := rpad(p_replacement_chr, l_length, p_replacement_chr);
					l_str := translate(l_str, l_old_chrs, l_new_chrs);
				else
					l_str := translate2(l_str, l_old_chrs);
				end if;
			end if;
		end if;
	end if;
	--
	return l_str;
end to_hankaku;
--
function to_hankaku(
	p_chr			in varchar2) return varchar2
is
begin
	return to_hankaku(p_chr, hr_api.g_varchar2);
end to_hankaku;
-- |---------------------------------------------------------------------------|
-- |------------------------------< to_zenkaku >-------------------------------|
-- |---------------------------------------------------------------------------|
function to_zenkaku(
	p_chr			in varchar2,
	p_replacement_chr	in varchar2) return varchar2
is
	l_str		varchar2(32767);
	l_old_str	varchar2(8);
	l_new_str	varchar2(8);
	l_length	number;
	l_index		number;
begin
	if p_chr is not null then
		l_str := p_chr;
		--
		-- Replace Voiced Letters "at first".
		--
		for i in 1..length(c_zenkaku.voiced_kana) loop
			l_old_str := substr(c_hankaku.voiced_kana, i * 2 - 1, 2);
			l_new_str := substr(c_zenkaku.voiced_kana, i, 1);
			l_str := replace(l_str, l_old_str, l_new_str);
		end loop;
		--
		l_str := translate(l_str,
				c_hankaku.upper_alphabet	||
				c_hankaku.lower_alphabet	||
				c_hankaku.number		||
				c_hankaku.symbol		||
				c_hankaku.kana			||
				c_hankaku.upper_kana		||
				c_hankaku.lower_kana		||
				c_hankaku.jp_symbol,
				c_zenkaku.upper_alphabet	||
				c_zenkaku.lower_alphabet	||
				c_zenkaku.number		||
				c_zenkaku.symbol		||
				c_zenkaku.kana			||
				c_zenkaku.upper_kana		||
				c_zenkaku.lower_kana		||
				c_zenkaku.jp_symbol);
		--
		if p_replacement_chr is null or p_replacement_chr <> hr_api.g_varchar2 then
			if not is_zenkaku(l_str) then
				--
				-- It is very rare case to get into this if statement,
				-- so we can ignore the performance.
				--
				if p_replacement_chr is not null then
					if length(p_replacement_chr) > 1 or not is_zenkaku(p_replacement_chr) then
						fnd_message.set_name('PER', 'HR_JP_INVALID_REPLACEMENT_CHR');
						fnd_message.set_token('REPLACEMENT_CHR', p_replacement_chr);
						fnd_message.raise_error;
					end if;
				end if;
				--
				l_length := length(l_str);
				l_index := 1;
				while l_index <= l_length loop
					if not is_zenkaku(substr(l_str, l_index, 1)) then
						l_str := substr(l_str, 1, l_index - 1) || p_replacement_chr || substr(l_str, l_index + 1);
						--
						if p_replacement_chr is null then
							l_length := l_length - 1;
						else
							l_index := l_index + 1;
						end if;
					else
						l_index := l_index + 1;
					end if;
				end loop;
			end if;
		end if;
	end if;
	--
	return l_str;
end to_zenkaku;
--
function to_zenkaku(
	p_chr			in varchar2) return varchar2
is
begin
	return to_zenkaku(p_chr, hr_api.g_varchar2);
end to_zenkaku;
-- |---------------------------------------------------------------------------|
-- |------------------------------< upper_kana >-------------------------------|
-- |---------------------------------------------------------------------------|
function upper_kana(p_chr in varchar2) return varchar2
is
begin
	return translate(p_chr,
			c_hankaku.lower_kana	||
			c_zenkaku.lower_kana,
			c_hankaku.upper_kana	||
			c_zenkaku.upper_kana);
end upper_kana;
-- |---------------------------------------------------------------------------|
-- |------------------------------< lower_kana >-------------------------------|
-- |---------------------------------------------------------------------------|
function lower_kana(p_chr in varchar2) return varchar2
is
begin
	return translate(p_chr,
			c_hankaku.upper_kana	||
			c_zenkaku.upper_kana,
			c_hankaku.lower_kana	||
			c_zenkaku.lower_kana);
end lower_kana;
-- |---------------------------------------------------------------------------|
-- |-----------------------------< upper_hankaku >-----------------------------|
-- |---------------------------------------------------------------------------|
function upper_hankaku(p_chr in varchar2) return varchar2
is
begin
	--
	-- UPPER function converts both Hankaku and Zenkaku apphabet characters.
	-- This function converts only Hankaku characters, so us "translate"
	-- instead of "upper".
	--
	return translate(p_chr,
			c_hankaku.lower_kana || 'abcdefghijklmnopqrstuvwxyz',
			c_hankaku.upper_kana || 'ABCDEFGHIJKLMNOPQRSTUVWXYZ');
end upper_hankaku;
-- |---------------------------------------------------------------------------|
-- |-------------------------------< to_table >--------------------------------|
-- |---------------------------------------------------------------------------|
procedure to_table(
	p_str		in varchar2,
	p_lengthb	in binary_integer,
	p_str_tbl	out nocopy t_varchar2_tbl)
is
	l_posb		number := 1;
	l_pos		number := 1;
	l_str		varchar2(4000);
	l_str_dummy	varchar2(32767);
	l_length	number;
	l_index		number := 0;
begin
	if p_str is not null and p_lengthb > 0 then
		while l_posb <= lengthb(p_str) loop
			l_str := substrb(p_str, l_posb, p_lengthb);
			l_length := length(l_str);
			l_str_dummy := substr(p_str, l_pos, l_length);
			--
			if l_str <> l_str_dummy then
				for i in reverse 0..(l_length - 1) loop
					l_str := substr(l_str, 1, i);
					l_str_dummy := substr(l_str_dummy, 1, i);
					--
					if l_str = l_str_dummy then
						exit;
					end if;
				end loop;
			end if;
			--
			if l_str is null then
				exit;
			end if;
			--
			l_index := l_index + 1;
			p_str_tbl(l_index) := l_str;
			l_posb := l_posb + lengthb(l_str);
			l_pos := l_pos + length(l_str);
		end loop;
	end if;
end to_table;
--
function to_table(
	p_str		in varchar2,
	p_lengthb	in binary_integer) return FND_TABLE_OF_VARCHAR2_4000
is
	l_temp_tbl	t_varchar2_tbl;
	l_count		number;
	l_str_tbl	FND_TABLE_OF_VARCHAR2_4000;
begin
	if p_str is not null then
		to_table(p_str, p_lengthb, l_temp_tbl);
		--
		l_count := l_temp_tbl.count;
		if l_count > 0 then
			l_str_tbl := FND_TABLE_OF_VARCHAR2_4000();
			l_str_tbl.extend(l_count);
			--
			for i in 1..l_count loop
				l_str_tbl(i) := l_temp_tbl(i);
			end loop;
		end if;
	end if;
	--
	return l_str_tbl;
end to_table;
--
function get_index_at(
	p_varchar2_tbl	in hr_jp_standard_pkg.t_varchar2_tbl,
	p_index		in number) return varchar2
is
begin
	if p_varchar2_tbl.exists(p_index) then
		return p_varchar2_tbl(p_index);
	else
		return null;
	end if;
end get_index_at;
-- |---------------------------------------------------------------------------|
-- |------------------------------< to_jp_char >-------------------------------|
-- |---------------------------------------------------------------------------|
function to_jp_char(
	p_date		in date,
	p_date_format	in varchar2 default null) return varchar2
is
	l_str		varchar2(255);
begin
	--
	-- PL/SQL "to_char" has bug which does not work with "NLS" parameters.
	-- We here use ORACLE "to_char" as a workaround.
	--
	if p_date is not null then
		if p_date_format is not null then
			select	to_char(p_date, p_date_format, 'NLS_CALENDAR=''Japanese Imperial''')
			into	l_str
			from	dual;
		else
			select	to_char(p_date, sys_context('USERENV', 'NLS_DATE_FORMAT'), 'NLS_CALENDAR=''Japanese Imperial''')
			into	l_str
			from	dual;
		end if;
	end if;
	--
	return l_str;
end to_jp_char;
-- |---------------------------------------------------------------------------|
-- |------------------------------< to_jp_date >-------------------------------|
-- |---------------------------------------------------------------------------|
function to_jp_date(
	p_str		in varchar2,
	p_date_format	in varchar2 default null) return date
is
	l_date		date;
begin
	--
	-- PL/SQL "to_char" has bug which does not work with "NLS" parameters.
	-- We here use ORACLE "to_char" as a workaround.
	--
	if p_str is not null then
		if p_date_format is not null then
			select	to_date(p_str, p_date_format, 'NLS_CALENDAR=''Japanese Imperial''')
			into	l_date
			from	dual;
		else
			select	to_date(p_str, sys_context('USERENV', 'NLS_DATE_FORMAT'), 'NLS_CALENDAR=''Japanese Imperial''')
			into	l_date
			from	dual;
		end if;
	end if;
	--
	return l_date;
end to_jp_date;
-- |---------------------------------------------------------------------------|
-- |------------------------------< to_jis8_raw >------------------------------|
-- |---------------------------------------------------------------------------|
-- This function supports JIS-X0208 characters
--   JIS 524 Non-kanji characters
--   JIS 1st level 2965 Kanji characters
--   JIS 2nd level 3390 Kanji characters
function to_jis8_raw(
	p_chr	in varchar2,
	p_ki	in raw,
	p_ko	in raw) return raw
is
	l_jisraw	raw(32767);
	l_sjhex		varchar2(4);
	l_high		number;
	l_low		number;
	--
	-- <SJIS 1st byte>
	-- 0x81(129) - 0x9F(159) (31 chars)
	-- 0xE0(224) - 0xFC(252) (29 chars)  --> 0xE0(224) - 0xEF(239) (16 chars)
	--                                       0xF0(240) - 0xFC(252) (13 chars)
	--
	-- <SJIS 2nd byte>
	-- 0x40(64)  - 0x7E(126) (63 chars)
	-- 0x80(128) - 0xFC(252) (125 chars) --> 0x80(128) - 0x9E(158) (31 chars)
	--                                       0x9F(159) - 0xFC(252) (94 chars)
	--
	-- <JIS8 1st/2nd byte>
	-- 0x21(33)  - 0x7E(126) (94 chars)  --> 0x21(33)  - 0x5F(95)  (63 chars)
	--                                       0x60(96)  - 0x7E(126) (31 chars)
	--
	-- <Conversion Table from SJIS to JIS8>
	-- <1st byte>
	-- 0x81(129) - 0x9F(159) (31 chars) --> 0x21(33)  - 0x5E(94)  (62 chars)
	-- 0xE0(224) - 0xEF(239) (16 chars) --> 0x5F(95)  - 0x7E(126) (32 chars)
	-- 0xF0(240) - 0xFC(252) (13 chars) --> 0x7F(127) - 0x98(152) (26 chars)*
	--
	-- <2nd byte>
	-- 0x40(64)  - 0x7E(126) --> 0x21(33) - 0x5F(95)  (63 chars)
	-- 0x80(128) - 0x9E(158) --> 0x60(96) - 0x7E(126) (31 chars)
	-- 0x9F(159) - 0xFC(252) --> 0x21(33) - 0x7E(126) (94 chars)
	--
	l_ki		boolean := false;
--	c_shift_in	constant raw(3) := hextoraw('1B2442');
--	c_shift_out	constant raw(3) := hextoraw('1B2842');
	--
	procedure ki
	is
	begin
		if not l_ki then
			l_jisraw := l_jisraw || p_ki;
			l_ki := true;
		end if;
	end ki;
	--
	procedure ko
	is
	begin
		if l_ki then
			l_jisraw := l_jisraw || p_ko;
			l_ki := false;
		end if;
	end ko;
begin
	if p_chr is not null then
		for i in 1..length(p_chr) loop
			l_sjhex := chartosjhex(substr(p_chr, i, 1));
--			dbms_output.put_line(l_sjhex);
			--
			if l_sjhex is not null then
				if length(l_sjhex) > 2 then
					l_high := to_number(substr(l_sjhex, 1, 2), 'XX');
					l_low  := to_number(substr(l_sjhex, 3), 'XX');
					--
					if ((l_high between 129 and 159) or (l_high between 224 and 239))
--					if ((l_high between 129 and 159) or (l_high between 224 and 252))
					and ((l_low between 64 and 126) or (l_low between 128 and 252)) then
						if l_high <= 159 then
							if l_low <= 158 then
								l_high := l_high * 2 - 225;
							else
								l_high := l_high * 2 - 224;
							end if;
						else
							if l_low <= 158 then
								l_high := l_high * 2 - 353;
							else
								l_high := l_high * 2 - 352;
							end if;
						end if;
						--
						if l_low <= 126 then
							l_low := l_low - 31;
						elsif l_low <= 158 then
							l_low := l_low - 32;
						else
							l_low := l_low - 126;
						end if;
					else
						--
						-- Unconvertable Kanji Characters.
						-- Converted multibyte "?" (0x21 0x29)
						--
						l_high := 33;
						l_low  := 41;
					end if;
					--
					ki;
					--
					l_jisraw := l_jisraw ||
						    hextoraw(lpad(to_char(l_high, 'FMXX'), 2, '0')) ||
						    hextoraw(lpad(to_char(l_low, 'FMXX'), 2, '0'));
				else
					ko;
					--
					l_jisraw := l_jisraw || hextoraw(l_sjhex);
				end if;
			end if;
		end loop;
		--
		if l_jisraw is not null then
			ko;
		end if;
		--
--		dbms_output.put_line(rawtohex(l_jisraw));
	end if;
	--
	return l_jisraw;
end to_jis8_raw;
-- |---------------------------------------------------------------------------|
-- |--------------------------------< to_jis8 >--------------------------------|
-- |---------------------------------------------------------------------------|
function to_jis8(
	p_chr	in varchar2,
	p_ki	in raw,
	p_ko	in raw) return varchar2
is
begin
	return utl_raw.cast_to_varchar2(to_jis8_raw(p_chr, p_ki, p_ko));
end to_jis8;
-- |---------------------------------------------------------------------------|
-- |----------------------------------< gcd >----------------------------------|
-- |---------------------------------------------------------------------------|
--
-- greatest common divisor
--
function gcd(a integer, b integer) return integer
is
	l_a	integer;
	l_b	integer;
begin
	if a is not null and b is not null then
		if a = 0 or b = 0 then
			l_a := 0;
		else
			l_a := abs(a);
			l_b := abs(b);
			--
			while (l_a <> l_b) loop
				if l_a > l_b then
					l_a := l_a - l_b;
				else
					l_b := l_b - l_a;
				end if;
			end loop;
		end if;
	end if;
	--
	return l_a;
end gcd;
-- |---------------------------------------------------------------------------|
-- |----------------------------------< lcm >----------------------------------|
-- |---------------------------------------------------------------------------|
--
-- least common multiple
--
function lcm(a integer, b integer) return integer
is
	l_lcm	integer;
begin
	if a is not null and b is not null then
		if a = 0 or b = 0 then
			l_lcm := 0;
		else
			l_lcm := a * b / gcd(a, b);
		end if;
	end if;
	--
	return l_lcm;
end lcm;
-- |---------------------------------------------------------------------------|
-- |------------------------------< get_message >------------------------------|
-- |---------------------------------------------------------------------------|
/*
function get_message(
	p_application_short_name	in varchar2,
	p_message_name			in varchar2,
	p_token_name1			in varchar2 default null,
	p_token_value1			in varchar2 default null,
	p_token_name2			in varchar2 default null,
	p_token_value2			in varchar2 default null,
	p_token_name3			in varchar2 default null,
	p_token_value3			in varchar2 default null,
	p_token_name4			in varchar2 default null,
	p_token_value4			in varchar2 default null,
	p_token_name5			in varchar2 default null,
	p_token_value5			in varchar2 default null) return varchar2
is
	procedure set_token(
		p_token_name	in varchar2,
		p_token_value	in varchar2)
	is
	begin
		if p_token_name is not null then
			fnd_message.set_token(p_token_name, p_token_value);
		end if;
	end set_token;
begin
	fnd_message.set_name(p_application_short_name, p_message_name);
	set_token(p_token_name1, p_token_value1);
	set_token(p_token_name2, p_token_value2);
	set_token(p_token_name3, p_token_value3);
	set_token(p_token_name4, p_token_value4);
	set_token(p_token_name5, p_token_value5);
	--
	return fnd_message.get;
end get_message;
*/
--
function get_message(
	p_application_short_name	in varchar2,
	p_message_name			in varchar2,
	p_language_code			in varchar2,
	p_token_name1			in varchar2 default null,
	p_token_value1			in varchar2 default null,
	p_token_name2			in varchar2 default null,
	p_token_value2			in varchar2 default null,
	p_token_name3			in varchar2 default null,
	p_token_value3			in varchar2 default null,
	p_token_name4			in varchar2 default null,
	p_token_value4			in varchar2 default null,
	p_token_name5			in varchar2 default null,
	p_token_value5			in varchar2 default null) return varchar2
is
	l_language_code		fnd_new_messages.language_code%type;
	l_message_text		fnd_new_messages.message_text%type;
	l_not_found		boolean := false;
	--
	cursor csr_message_text(cp_language_code in varchar2) is
		select	message_text
		from	fnd_application		a,
			fnd_new_messages	m
		where	a.application_short_name = p_application_short_name
		and	m.application_id = a.application_id
		and	m.message_name = p_message_name
		and	m.language_code = cp_language_code;
	--
	procedure replace_token(
		p_message_text		in out nocopy varchar2,
		p_token_name		in varchar2,
		p_token_value		in varchar2)
	is
		l_token_name		varchar2(2000);
	begin
		if p_message_text is not null and p_token_name is not null then
			l_token_name := '&' || p_token_name;
			--
			if instr(p_message_text, l_token_name) > 0 then
				p_message_text := replace(p_message_text, l_token_name, p_token_value);
			end if;
		end if;
	end replace_token;
begin
	if p_language_code is not null then
		l_language_code := p_language_code;
	else
		l_language_code := userenv('LANG');
	end if;
	--
	open csr_message_text(l_language_code);
	fetch csr_message_text into l_message_text;
	if csr_message_text%notfound then
		l_not_found := true;
	end if;
	close csr_message_text;
	--
	if l_not_found then
		open csr_message_text('US');
		fetch csr_message_text into l_message_text;
		close csr_message_text;
	end if;
	--
	if l_message_text is not null then
		replace_token(l_message_text, p_token_name1, p_token_value1);
		replace_token(l_message_text, p_token_name2, p_token_value2);
		replace_token(l_message_text, p_token_name3, p_token_value3);
		replace_token(l_message_text, p_token_name4, p_token_value4);
		replace_token(l_message_text, p_token_name5, p_token_value5);
	end if;
	--
	return l_message_text;
end get_message;
--
END hr_jp_standard_pkg;

/
