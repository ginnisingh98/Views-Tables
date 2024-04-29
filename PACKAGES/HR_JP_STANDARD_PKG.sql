--------------------------------------------------------
--  DDL for Package HR_JP_STANDARD_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."HR_JP_STANDARD_PKG" AUTHID CURRENT_USER AS
/* $Header: hrjpstnd.pkh 120.9 2006/12/05 07:44:22 ttagawa noship $ */
type t_varchar2_tbl is table of varchar2(4000) index by binary_integer;
-- |---------------------------------------------------------------------------|
-- |-------------------------------< hextochar >-------------------------------|
-- |---------------------------------------------------------------------------|
FUNCTION hextochar(
	p_src		IN VARCHAR2,
	p_src_cset	IN VARCHAR2) RETURN VARCHAR2 DETERMINISTIC;
-- |---------------------------------------------------------------------------|
-- |------------------------------< sjhextochar >------------------------------|
-- |---------------------------------------------------------------------------|
FUNCTION sjhextochar(
	p_src		IN VARCHAR2) RETURN VARCHAR2 DETERMINISTIC;
-- |---------------------------------------------------------------------------|
-- |-------------------------------< chartohex >-------------------------------|
-- |---------------------------------------------------------------------------|
FUNCTION chartohex(
	p_src		IN VARCHAR2,
	p_dest_cset	IN VARCHAR2) RETURN VARCHAR2 DETERMINISTIC;
-- |---------------------------------------------------------------------------|
-- |------------------------------< chartosjhex >------------------------------|
-- |---------------------------------------------------------------------------|
FUNCTION chartosjhex(
	p_src		IN VARCHAR2) RETURN VARCHAR2 DETERMINISTIC;
-- |---------------------------------------------------------------------------|
-- |------------------------------< translate2 >-------------------------------|
-- |---------------------------------------------------------------------------|
function translate2(
	p_str		in varchar2,
	p_old_chrs	in varchar2,
	p_new_chrs	in varchar2 default null) return varchar2 deterministic;
-- |---------------------------------------------------------------------------|
-- |---------------------------------< strip >---------------------------------|
-- |---------------------------------------------------------------------------|
function strip(
	p_str			in varchar2,
	p_chrs			in varchar2,
	p_replacement_chr	in varchar2 default null) return varchar2 deterministic;
-- |---------------------------------------------------------------------------|
-- |---------------------------< recursive_replace >---------------------------|
-- |---------------------------------------------------------------------------|
function recursive_replace(
	p_str		in varchar2,
	p_old_str	in varchar2,
	p_new_str	in varchar2 default null) return varchar2 deterministic;
-- |---------------------------------------------------------------------------|
-- |--------------------------------< round2 >---------------------------------|
-- |---------------------------------------------------------------------------|
function round2(
	p_num		in number,
	p_places	in number default 0) return number deterministic;
-- |---------------------------------------------------------------------------|
-- |------------------------------< is_integer >-------------------------------|
-- |---------------------------------------------------------------------------|
function is_integer(p_num in number) return varchar2 deterministic;
-- |---------------------------------------------------------------------------|
-- |------------------------------< is_hankaku >-------------------------------|
-- |---------------------------------------------------------------------------|
function is_hankaku(p_chr in varchar2) return boolean deterministic;
-- |---------------------------------------------------------------------------|
-- |------------------------------< is_zenkaku >-------------------------------|
-- |---------------------------------------------------------------------------|
function is_zenkaku(p_chr in varchar2) return boolean deterministic;
-- |---------------------------------------------------------------------------|
-- |------------------------------< to_hankaku >-------------------------------|
-- |---------------------------------------------------------------------------|
function to_hankaku(
	p_chr			in varchar2,
	p_replacement_chr	in varchar2) return varchar2 deterministic;
function to_hankaku(
	p_chr			in varchar2) return varchar2 deterministic;
-- |---------------------------------------------------------------------------|
-- |------------------------------< to_zenkaku >-------------------------------|
-- |---------------------------------------------------------------------------|
function to_zenkaku(
	p_chr			in varchar2,
	p_replacement_chr	in varchar2) return varchar2 deterministic;
function to_zenkaku(
	p_chr			in varchar2) return varchar2 deterministic;
-- |---------------------------------------------------------------------------|
-- |------------------------------< lower_kana >-------------------------------|
-- |---------------------------------------------------------------------------|
function lower_kana(p_chr in varchar2) return varchar2 deterministic;
-- |---------------------------------------------------------------------------|
-- |------------------------------< upper_kana >-------------------------------|
-- |---------------------------------------------------------------------------|
function upper_kana(p_chr in varchar2) return varchar2 deterministic;
-- |---------------------------------------------------------------------------|
-- |-----------------------------< upper_hankaku >-----------------------------|
-- |---------------------------------------------------------------------------|
function upper_hankaku(p_chr in varchar2) return varchar2 deterministic;
-- |---------------------------------------------------------------------------|
-- |-------------------------------< to_table >--------------------------------|
-- |---------------------------------------------------------------------------|
procedure to_table(
	p_str		in varchar2,
	p_lengthb	in binary_integer,
	p_str_tbl	out nocopy t_varchar2_tbl);
function to_table(
	p_str		in varchar2,
	p_lengthb	in binary_integer) return FND_TABLE_OF_VARCHAR2_4000 deterministic;
function get_index_at(
	p_varchar2_tbl	in hr_jp_standard_pkg.t_varchar2_tbl,
	p_index		in number) return varchar2 deterministic;
-- |---------------------------------------------------------------------------|
-- |------------------------------< to_jp_char >-------------------------------|
-- |---------------------------------------------------------------------------|
function to_jp_char(
	p_date		in date,
	p_date_format	in varchar2 default null) return varchar2 deterministic;
-- |---------------------------------------------------------------------------|
-- |------------------------------< to_jp_date >-------------------------------|
-- |---------------------------------------------------------------------------|
function to_jp_date(
	p_str		in varchar2,
	p_date_format	in varchar2 default null) return date deterministic;
-- |---------------------------------------------------------------------------|
-- |------------------------------< to_jis8_raw >------------------------------|
-- |---------------------------------------------------------------------------|
function to_jis8_raw(
	p_chr	in varchar2,
	p_ki	in raw default null,
	p_ko	in raw default null) return raw deterministic;
-- |---------------------------------------------------------------------------|
-- |--------------------------------< to_jis8 >--------------------------------|
-- |---------------------------------------------------------------------------|
function to_jis8(
	p_chr	in varchar2,
	p_ki	in raw default null,
	p_ko	in raw default null) return varchar2 deterministic;
-- |---------------------------------------------------------------------------|
-- |----------------------------------< gcd >----------------------------------|
-- |---------------------------------------------------------------------------|
function gcd(a integer, b integer) return integer deterministic;
-- |---------------------------------------------------------------------------|
-- |----------------------------------< lcm >----------------------------------|
-- |---------------------------------------------------------------------------|
function lcm(a integer, b integer) return integer deterministic;
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
	p_token_value5			in varchar2 default null) return varchar2;
*/
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
	p_token_value5			in varchar2 default null) return varchar2 deterministic;
--
END hr_jp_standard_pkg;

/
