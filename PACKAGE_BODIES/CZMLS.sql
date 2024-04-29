--------------------------------------------------------
--  DDL for Package Body CZMLS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."CZMLS" as
/*	$Header: czmlsb.pls 115.11 2002/11/27 17:05:53 askhacha ship $ */

current_client_charset varchar2 (100);

-- CONSTANTS FOR WINDOWS CHARACTER SETS

cs_ascii constant number 					:= 0;
cs_windows_japan constant number 			:= to_number ('03A4', 'XXXXXX'); --  932
cs_windows_korea constant number 			:= to_number ('03B5', 'XXXXXX'); --  949
cs_windows_taiwan constant number 			:= to_number ('03B6', 'XXXXXX'); --  950
cs_windows_unicode constant number 			:= to_number ('04B0', 'XXXXXX'); -- 1200
cs_windows_windows_latin_ee constant number := to_number ('04E2', 'XXXXXX'); -- 1250

cs_windows_windows_cyrillic constant number := to_number ('04E3', 'XXXXXX'); -- 1251
cs_windows_windows_multilng_us constant number
											:= to_number ('04E4', 'XXXXXX'); -- 1252
cs_windows_greek constant number 			:= to_number ('04E5', 'XXXXXX'); -- 1253
cs_windows_turkish constant number 			:= to_number ('04E6', 'XXXXXX'); -- 1254

cs_windows_hebrew constant number 			:= to_number ('04E7', 'XXXXXX'); -- 1255
cs_windows_arabic constant number 			:= to_number ('04E8', 'XXXXXX'); -- 1256



-- CONSTANTS FOR WINDOWS LANGUAGE CODES

l_ascii constant number 			:= to_number ('0400', 'XXXXXX');
l_arabic constant number 			:= to_number ('0401', 'XXXXXX'); --  1025
l_bulgarian constant number 			:= to_number ('0402', 'XXXXXX');
l_catalan constant number 			:= to_number ('0403', 'XXXXXX');
l_traditional_chinese constant number 	:= to_number ('0404', 'XXXXXX');
l_czech constant number 			:= to_number ('0405', 'XXXXXX'); --  932
l_danish constant number 			:= to_number ('0406', 'XXXXXX'); --  932
l_german constant number 			:= to_number ('0407', 'XXXXXX'); --  932
l_greek constant number 			:= to_number ('0408', 'XXXXXX'); --  932
l_american constant number 			:= to_number ('0409', 'XXXXXX'); --  1033

l_castilian_spanish constant number 	:= to_number ('040A', 'XXXXXX'); --  932
l_finnish constant number 			:= to_number ('040B', 'XXXXXX'); --  932
l_french constant number 			:= to_number ('040C', 'XXXXXX'); --  932
l_hebrew constant number 			:= to_number ('040D', 'XXXXXX'); --  932
l_hungarian constant number 			:= to_number ('040E', 'XXXXXX'); --  932
l_icelandic constant number 			:= to_number ('040F', 'XXXXXX'); --  932
l_italian constant number 			:= to_number ('0410', 'XXXXXX'); --  932
l_japanese constant number 			:= to_number ('0411', 'XXXXXX'); --  932
l_korean constant number 			:= to_number ('0412', 'XXXXXX'); --  932
l_dutch constant number 			:= to_number ('0413', 'XXXXXX'); --  932
l_norwegian_bokmal constant number 		:= to_number ('0414', 'XXXXXX'); --  932
l_polish constant number 			:= to_number ('0415', 'XXXXXX'); --  932
l_brazilian_portuguese constant number 	:= to_number ('0416', 'XXXXXX'); --  932
l_rhaeto_romanic constant number 		:= to_number ('0417', 'XXXXXX'); --  932
l_romanian constant number 			:= to_number ('0418', 'XXXXXX'); --  932
l_russian constant number 			:= to_number ('0419', 'XXXXXX'); --  932
l_croato_serbian_latin constant number 	:= to_number ('041A', 'XXXXXX'); --  932
l_slovak constant number 			:= to_number ('041B', 'XXXXXX'); --  932
l_albanian constant number 			:= to_number ('041C', 'XXXXXX'); --  932
l_swedish constant number 			:= to_number ('041D', 'XXXXXX'); --  932
l_thai constant number 				:= to_number ('041E', 'XXXXXX'); --  932
l_turkish constant number 			:= to_number ('041F', 'XXXXXX'); --  932
l_urdu constant number 				:= to_number ('0420', 'XXXXXX'); --  932

l_bahasa constant number 			:= to_number ('0421', 'XXXXXX'); --  932
l_simplified_chinese constant number	:= to_number ('0804', 'XXXXXX'); --  932
l_swiss_german constant number 		:= to_number ('0807', 'XXXXXX'); --  932
l_english_uk constant number 			:= to_number ('0809', 'XXXXXX'); --  932
l_mexican_spanish constant number 		:= to_number ('080A', 'XXXXXX'); --  932
l_belgian_french constant number 		:= to_number ('080C', 'XXXXXX'); --  932
l_swiss_italian constant number 		:= to_number ('0810', 'XXXXXX'); --  932
l_belgian_dutch constant number 		:= to_number ('0813', 'XXXXXX'); --  932
l_norwegian_nynorsk constant number 	:= to_number ('0814', 'XXXXXX'); --  932
l_portuguese constant number 			:= to_number ('0816', 'XXXXXX'); --  949
l_serbo_croatian_cyrillic constant number	:= to_number ('081A', 'XXXXXX'); --  950
l_canadian_french constant number 		:= to_number ('0C0C', 'XXXXXX'); -- 1200
l_swiss_french constant number 		:= to_number ('100C', 'XXXXXX'); -- 1250


procedure Set_Windows_Client_Info (Code_Page in NUMBER, Language in NUMBER,
		OracleCharset in OUT NOCOPY VARCHAR2, db_client_language OUT NOCOPY VARCHAR2,
		db_base_language OUT NOCOPY VARCHAR2,  Status OUT NOCOPY NUMBER)

is
	temp_charset varchar2 (100);
begin
	Status := -1;

	begin
		select value into temp_charset from v$nls_valid_values
		where parameter = 'CHARACTERSET' and value like '%MSWIN' || TO_CHAR (Code_Page);
		current_client_charset := temp_charset;
	exception
		when NO_DATA_FOUND then
			if code_page = cs_windows_japan then
				current_client_charset := 'JA16SJIS';
			elsif code_page = cs_windows_unicode then
				current_client_charset := 'UTF8';
			elsif code_page = cs_windows_arabic then
				current_client_charset := 'AR8MSAWIN';
			else
				null; -- should raise an exception...
			end if;

	end;

	if (language is not null) then
		Status := check_language (language, db_client_language,db_base_language);
	end if;


	OracleCharset := current_client_charset;
end Set_Windows_Client_Info;

function client_charset return varchar2
is
begin
	return current_client_charset;
end client_charset;

function check_language(Language in number, db_client_language OUT NOCOPY VARCHAR2,
				db_base_language OUT NOCOPY VARCHAR2) return number

is
	temp_client_language varchar2(50);
	lang	 varchar2(1);
	temp_tablename varchar2(30);
	retstatus 	 number := -1;
begin

	if (Language = l_ascii) then
		temp_client_language := 'US';
	elsif (Language = l_arabic) then
		temp_client_language := 'AR';
	elsif (Language = l_bulgarian) then
		temp_client_language := 'BG';
	elsif (Language = l_catalan) then
		temp_client_language := 'CA';
	elsif (Language = l_traditional_chinese) then
		temp_client_language := 'ZHT';
	elsif (Language = l_czech) then
		temp_client_language := 'CS';
	elsif (Language = l_danish) then
		temp_client_language := 'DK';
	elsif (Language = l_german) then
		temp_client_language := 'D';
	elsif (Language = l_greek) then
		temp_client_language := 'EL';
	elsif (Language = l_american) then
		temp_client_language := 'US';
	elsif (Language = l_castilian_spanish) then
		temp_client_language := 'E';
	elsif (Language = l_finnish) then
		temp_client_language := 'SF';
	elsif (Language = l_french) then
		temp_client_language := 'F';
	elsif (Language = l_hebrew) then
		temp_client_language := 'IW';
	elsif (Language = l_hungarian) then
		temp_client_language := 'HU';
	elsif (Language = l_icelandic) then
		temp_client_language := 'IS';
	elsif (Language = l_italian) then
		temp_client_language := 'I';
	elsif (Language = l_japanese) then
		temp_client_language := 'JA';
	elsif (Language = l_korean) then
		temp_client_language := 'KO';
	elsif (Language = l_dutch) then
		temp_client_language := 'NL';
	elsif (Language = l_norwegian_bokmal) then
		temp_client_language := 'N';  -- ??
	elsif (Language = l_polish) then
		temp_client_language := 'PL';
	elsif (Language = l_brazilian_portuguese) then
		temp_client_language := 'PTB';
	elsif (Language = l_rhaeto_romanic) then
		temp_client_language := '';  -- ??
	elsif (Language = l_romanian) then
		temp_client_language := 'RO';
	elsif (Language = l_russian) then
		temp_client_language := 'RU';
	elsif (Language = l_croato_serbian_latin) then
		temp_client_language := 'HR';  -- ??
	elsif (Language = l_slovak) then
		temp_client_language := 'SK';
	elsif (Language = l_albanian) then
		temp_client_language := '';  -- ??
	elsif (Language = l_swedish) then
		temp_client_language := 'S';
	elsif (Language = l_thai) then
		temp_client_language := 'TH';
	elsif (Language = l_turkish) then
		temp_client_language := 'TR';
	elsif (Language = l_urdu) then
		temp_client_language := ''; -- ??
	elsif (Language = l_bahasa) then
		temp_client_language := '';  -- ??
	elsif (Language = l_simplified_chinese) then
		temp_client_language := 'ZHS';
	elsif (Language = l_swiss_german) then
		temp_client_language := 'D';  -- ??
	elsif (Language = l_english_uk) then
		temp_client_language := 'GB';
	elsif (Language = l_mexican_spanish) then
		temp_client_language := 'ESA';
	elsif (Language = l_belgian_french) then
		temp_client_language := 'F';  -- ??
	elsif (Language = l_swiss_italian) then
		temp_client_language := 'I';   -- ??
	elsif (Language = l_belgian_dutch) then
		temp_client_language := 'NL';  -- ??
	elsif (Language = l_norwegian_nynorsk) then
		temp_client_language := 'N';    -- ??
	elsif (Language = l_portuguese) then
		temp_client_language := 'PT';
	elsif (Language = l_serbo_croatian_cyrillic) then
		temp_client_language := 'HR';  -- ??
	elsif (Language = l_canadian_french) then
		temp_client_language := 'FRC';
	elsif (Language = l_swiss_french) then
		temp_client_language := 'F';
	else
		temp_client_language := null;
	end if;

      if (temp_client_language is not null) then
		select installed_flag, nls_language into lang, db_client_language from fnd_languages
		where language_code = temp_client_language;

		if (lang = 'B') then
			retstatus := 0;
			db_base_language := db_client_language;
		elsif (lang = 'I') then
			retstatus := 1;
		else
			retstatus := 2;
		end if;

		if (retstatus > 0) then
		select nls_language into db_base_language from fnd_languages
		where installed_flag = 'B';
		end if;
	end if;

	return retstatus;

exception
when others then
	retstatus := -1;
	return retstatus;

end check_language;

procedure Set_Oracle_Charset (to_charset in varchar2)
is
	temp_charset varchar2 (50);
begin
	select value into temp_charset
	from v$nls_valid_values
	where parameter = 'CHARACTERSET'
	and value = to_charset;
	current_client_charset := temp_charset;
end Set_Oracle_Charset;


begin
	select value into current_client_charset

	from v$nls_parameters
	where parameter = 'NLS_CHARACTERSET';
end czmls;

/
