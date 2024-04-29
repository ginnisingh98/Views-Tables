--------------------------------------------------------
--  DDL for Package Body JG_ZZ_AMOUNT_IN_LETTERS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."JG_ZZ_AMOUNT_IN_LETTERS" AS
/* $Header: jgzztrlb.pls 115.8 2002/10/17 23:21:49 ashrivat ship $ */

----------------------------------------------------------------------
--procedure es_init is
----------------------------------------------------------------------
procedure sp_init is
begin
	 NumberList (0) :='cero';
	 NumberList (1) :='uno';
         NumberList (2) :='dos';
         NumberList (3) :='tres';
         NumberList (4) :='cuatro';
         NumberList (5) :='cinco';
         NumberList (6) :='seis';
         NumberList (7) :='siete';
         NumberList (8) :='ocho';
         NumberList (9) :='nueve';
         NumberList (10) :='diez';
         NumberList (11) :='once';
         NumberList (12) :='doce';
         NumberList (13) :='trece';
         NumberList (14) :='catorce';
         NumberList (15) :='quince';
         NumberList (16) :='dieciseis';
         NumberList (17) :='diecisiete';
         NumberList (18) :='dieciocho';
         NumberList (19) :='diecinueve';
         NumberList (20) :='veinte';
         NumberList (21) :='veintiuno';
         NumberList (22) :='veintidos';
         NumberList (23) :='veintitres';
         NumberList (24) :='veinticuatro';
         NumberList (25) :='veinticinco';
         NumberList (26) :='veintiseis';
         NumberList (27) :='veintisiete';
         NumberList (28) :='veintiocho';
         NumberList (29) :='veintinueve';
         NumberList (30) :='treinta';
         NumberList (31) :='treinta y uno';
         NumberList (32) :='treinta y dos';
         NumberList (33) :='treinta y tres';
         NumberList (34) :='treinta y cuatro';
         NumberList (35) :='treinta y cinco';
         NumberList (36) :='treinta y seis';
         NumberList (37) :='treinta y siete';
         NumberList (38) :='treinta y ocho';
         NumberList (39) :='treinta y nueve';
         NumberList (40) :='cuarenta';
         NumberList (41) :='cuarenta y uno';
         NumberList (42) :='cuarenta y dos';
         NumberList (43) :='cuarenta y tres';
         NumberList (44) :='cuarenta y cuatro';
         NumberList (45) :='cuarenta y cinco';
         NumberList (46) :='cuarenta y seis';
         NumberList (47) :='cuarenta y siete';
         NumberList (48) :='cuarenta y ocho';
         NumberList (49) :='cuarenta y nueve';
         NumberList (50) :='cincuenta';
         NumberList (51) :='cincuenta y uno';
         NumberList (52) :='cincuenta y dos';
         NumberList (53) :='cincuenta y tres';
         NumberList (54) :='cincuenta y cuatro';
         NumberList (55) :='cincuenta y cinco';
         NumberList (56) :='cincuenta y seis';
         NumberList (57) :='cincuenta y siete';
         NumberList (58) :='cincuenta y ocho';
         NumberList (59) :='cincuenta y nueve';
         NumberList (60) :='sesenta';
         NumberList (61) :='sesenta y uno';
         NumberList (62) :='sesenta y dos';
         NumberList (63) :='sesenta y tres';
         NumberList (64) :='sesenta y cuatro';
         NumberList (65) :='sesenta y cinco';
         NumberList (66) :='sesenta y seis';
         NumberList (67) :='sesenta y siete';
         NumberList (68) :='sesenta y ocho';
         NumberList (69) :='sesenta y nueve';
         NumberList (70) :='setanta';
         NumberList (71) :='setanta y uno';
         NumberList (72) :='setanta y dos';
         NumberList (73) :='setanta y tres';
         NumberList (74) :='setanta y cuatro';
         NumberList (75) :='setanta y cinco';
         NumberList (76) :='setanta y seis';
         NumberList (77) :='setanta y siete';
         NumberList (78) :='setanta y ocho';
         NumberList (79) :='setanta y nueve';
         NumberList (80) :='ochenta';
         NumberList (81) :='ochenta y uno';
         NumberList (82) :='ochenta y dos';
         NumberList (83) :='ochenta y tres';
         NumberList (84) :='ochenta y cuatro';
         NumberList (85) :='ochenta y cinco';
         NumberList (86) :='ochenta y seis';
         NumberList (87) :='ochenta y siete';
         NumberList (88) :='ochenta y ocho';
         NumberList (89) :='ochenta y nueve';
         NumberList (90) :='noventa';
         NumberList (91) :='noventa y uno';
         NumberList (92) :='noventa y dos';
         NumberList (93) :='noventa y tres';
         NumberList (94) :='noventa y cuatro';
         NumberList (95) :='noventa y cinco';
         NumberList (96) :='noventa y seis';
         NumberList (97) :='noventa y siete';
         NumberList (98) :='noventa y ocho';
         NumberList (99) :='noventa y nueve';
         ThousandList (1) := 'cien';
         ThousandList (2) := 'mil';
         ThousandList (3) := 'millon';
         ThousandList (4) := 'mil millon';
end;

----------------------------------------------------------------------
--procedure fr_init is
----------------------------------------------------------------------
procedure fr_init is
begin
	 NumberList (0) :='zero';
         NumberList (1) :='un';
         NumberList (2) :='deux';
         NumberList (3) :='trois';
         NumberList (4) :='quatre';
         NumberList (5) :='cinq';
         NumberList (6) :='six';
         NumberList (7) :='sept';
         NumberList (8) :='huit';
         NumberList (9) :='neuf';
         NumberList (10) :='dix';
         NumberList (11) :='onze';
         NumberList (12) :='douze';
         NumberList (13) :='treize';
         NumberList (14) :='quatorze';
         NumberList (15) :='quinze';
         NumberList (16) :='seize';
         NumberList (17) :='dix-sept';
         NumberList (18) :='dix-huit';
         NumberList (19) :='dix-neuf';
         NumberList (20) :='vingt';
         NumberList (21) :='vingt-et-un';
         NumberList (22) :='vingt-deux';
         NumberList (23) :='vingt-trois';
         NumberList (24) :='vingt-quatre';
         NumberList (25) :='vingt-cinq';
         NumberList (26) :='vingt-six';
         NumberList (27) :='vingt-sept';
         NumberList (28) :='vingt-huit';
         NumberList (29) :='vingt-neuf';
         NumberList (30) :='trente';
         NumberList (31) :='trente-et-un';
         NumberList (32) :='trente-deux';
         NumberList (33) :='trente-trois';
         NumberList (34) :='trente-quatre';
         NumberList (35) :='trente-cinq';
         NumberList (36) :='trente-six';
         NumberList (37) :='trente-sept';
         NumberList (38) :='trente-huit';
         NumberList (39) :='trente-neuf';
         NumberList (40) :='quarante';
         NumberList (41) :='quarante-et-un';
         NumberList (42) :='quarante-deux';
         NumberList (43) :='quarante-trois';
         NumberList (44) :='quarante-quatre';
         NumberList (45) :='quarante-cinq';
         NumberList (46) :='quarante-six';
         NumberList (47) :='quarante-sept';
         NumberList (48) :='quarante-huit';
         NumberList (49) :='quarante-neuf';
         NumberList (50) :='cinquante';
         NumberList (51) :='cinquante-et-un';
         NumberList (52) :='cinquante-deux';
         NumberList (53) :='cinquante-trois';
         NumberList (54) :='cinquante-quatre';
         NumberList (55) :='cinquante-cinq';
         NumberList (56) :='cinquante-six';
         NumberList (57) :='cinquante-sept';
         NumberList (58) :='cinquante-huit';
         NumberList (59) :='cinquante-neuf';
         NumberList (60) :='soixante';
         NumberList (61) :='soixante-et-un';
         NumberList (62) :='soixante-deux';
         NumberList (63) :='soixante-trois';
         NumberList (64) :='soixante-quatre';
         NumberList (65) :='soixante-cinq';
         NumberList (66) :='soixante-six';
         NumberList (67) :='soixante-sept';
         NumberList (68) :='soixante-huit';
         NumberList (69) :='soixante-neuf';
         NumberList (70) :='soixante-dix';
         NumberList (71) :='soixante et onze';
         NumberList (72) :='soixante-douze';
         NumberList (73) :='soixante-treize';
         NumberList (74) :='soixante-quatorze';
         NumberList (75) :='soixante-quinze';
         NumberList (76) :='soixante-seize';
         NumberList (77) :='soixante-dix-sept';
         NumberList (78) :='soixante-dix-huit';
         NumberList (79) :='soixante-dix-neuf';
         NumberList (80) :='quatre-vingt';
         NumberList (81) :='quatre-vingt-un';
         NumberList (82) :='quatre-vingt-deux';
         NumberList (83) :='quatre-vingt-trois';
         NumberList (84) :='quatre-vingt-quatre';
         NumberList (85) :='quatre-vingt-cinq';
         NumberList (86) :='quatre-vingt-six';
         NumberList (87) :='quatre-vingt-sept';
         NumberList (88) :='quatre-vingt-huit';
         NumberList (89) :='quatre-vingt-neuf';
         NumberList (90) :='quatre-vingt-dix';
         NumberList (91) :='quatre-vingt-onze';
         NumberList (92) :='quatre-vingt-douze';
         NumberList (93) :='quatre-vingt-treize';
         NumberList (94) :='quatre-vingt-quatorze';
         NumberList (95) :='quatre-vingt-quinze';
         NumberList (96) :='quatre-vingt-seize';
         NumberList (97) :='quatre-vingt-dix-sept';
         NumberList (98) :='quatre-vingt-dix-huit';
         NumberList (99) :='quatre-vingt-dix-neuf';
         ThousandList (1) := 'cent';
         ThousandList (2) := 'mille';
         ThousandList (3) := 'million';
         ThousandList (4) := 'milliard';
 end;

----------------------------------------------------------------------
--procedure it_init
----------------------------------------------------------------------

procedure it_init is

begin
	 NumberList (0) :='zero';
         NumberList (1) :='uno';
         NumberList (2) :='due';
         NumberList (3) :='tre';
         NumberList (4) :='quattro';
         NumberList (5) :='cinque';
         NumberList (6) :='sei';
         NumberList (7) :='sette';
         NumberList (8) :='otto';
         NumberList (9) :='nove';
         NumberList (10) :='dieci';
         NumberList (11) :='undici';
         NumberList (12) :='dodici';
         NumberList (13) :='tredici';
         NumberList (14) :='quattordici';
         NumberList (15) :='quindici';
         NumberList (16) :='sedici';
         NumberList (17) :='diciassette';
         NumberList (18) :='diciotto';
         NumberList (19) :='diciannove';
         NumberList (20) :='venti';
         NumberList (21) :='ventuno';
         NumberList (22) :='ventidue';
         NumberList (23) :='ventitre';
         NumberList (24) :='ventiquattro';
         NumberList (25) :='venticinque';
         NumberList (26) :='ventisei';
         NumberList (27) :='ventisette';
         NumberList (28) :='ventotto';
         NumberList (29) :='ventinove';
         NumberList (30) :='trenta';
         NumberList (31) :='trentuno';
         NumberList (32) :='trentadue';
         NumberList (33) :='trentatre';
         NumberList (34) :='trentaquattro';
         NumberList (35) :='trentacinque';
         NumberList (36) :='trentasei';
         NumberList (37) :='trentasette';
         NumberList (38) :='trentotto';
         NumberList (39) :='trentanove';
         NumberList (40) :='quaranta';
         NumberList (41) :='quarantuno' ;
         NumberList (42) :='quarantadue';
         NumberList (43) :='quarantatre';
         NumberList (44) :='quarantaquattro';
         NumberList (45) :='quarantacinque';
         NumberList (46) :='quarantasei';
         NumberList (47) :='quarantasette';
         NumberList (48) :='quarantotto';
         NumberList (49) :='quarantanove';
         NumberList (50) :='cinquanta';
         NumberList (51) :='cinquantuno';
         NumberList (52) :='cinquantadue';
         NumberList (53) :='cinquantatre';
         NumberList (54) :='cinquantaquattro';
         NumberList (55) :='cinquantacinque';
         NumberList (56) :='cinquantasei';
         NumberList (57) :='cinquantasette';
         NumberList (58) :='cinquantotto';
         NumberList (59) :='cinquantanove';
         NumberList (60) :='sessanta';
         NumberList (61) :='sessantuno';
         NumberList (62) :='sessantadue';
         NumberList (63) :='sessantatre';
         NumberList (64) :='sessantaquattro';
         NumberList (65) :='sessantacinque';
         NumberList (66) :='sessantasei';
         NumberList (67) :='sessantasette';
         NumberList (68) :='sessantotto';
         NumberList (69) :='sessantanove';
         NumberList (70) :='settanta ';
         NumberList (71) :='settantuno';
         NumberList (72) :='settantadue';
         NumberList (73) :='settantatre';
         NumberList (74) :='settantaquattro';
         NumberList (75) :='settantacinque';
         NumberList (76) :='settantasei';
         NumberList (77) :='settantasette';
         NumberList (78) :='settantotto';
         NumberList (79) :='settantanove';
         NumberList (80) :='ottanta';
         NumberList (81) :='ottantuno';
         NumberList (82) :='ottantadue';
         NumberList (83) :='ottantatre';
         NumberList (84) :='ottantaquattro';
         NumberList (85) :='ottantacinque';
         NumberList (86) :='ottantasei';
         NumberList (87) :='ottantasette';
         NumberList (88) :='ottantotto';
         NumberList (89) :='ottantanove';
         NumberList (90) :='novanta';
         NumberList (91) :='novantuno';
         NumberList (92) :='novantadue';
         NumberList (93) :='novantatre';
         NumberList (94) :='novantaquattro';
         NumberList (95) :='novantacinque';
         NumberList (96) :='novantasei';
         NumberList (97) :='novantasette';
         NumberList (98) :='novantotto';
         NumberList (99) :='novantanove';
         ThousandList (1) := 'cento';
         ThousandList (2) := 'mille';
         ThousandList (3) := 'milion';
         ThousandList (4) := 'miliard';
end;


----------------------------------------------------------------------
--function  hundreds ( p_nb_char IN VARCHAR2 ) return VARCHAR2 IS
----------------------------------------------------------------------

function  hundreds ( p_nb_char IN VARCHAR2 ) return VARCHAR2 IS
         v_in_number       VARCHAR2 (100);
         v_size            NUMBER;
         v_hundred         VARCHAR2(1);
         v_in_character    VARCHAR2(500) := '';

BEGIN

v_in_number := p_nb_char;

if length (v_in_number) = 3 then
v_hundred := substr ( v_in_number , 1,1 );
	if v_hundred not in ('0')  then
	v_in_character := NumberList(to_number( v_hundred))||' ';
	v_in_character := v_in_character || ThousandList(1) ||' ';
	end if;
v_in_number := substr ( v_in_number , 2 , 2 );
end if;

-- Remove the 0 on left side

v_in_number := ltrim ( v_in_number ,'0');
if v_in_number is not null then
v_in_character:=v_in_character||NumberList(to_number( v_in_number));
end if;
RETURN v_in_character;
END;

--------------------------------------------------------------------------------------------------
--function  litteral(p_number IN NUMBER, p_decimal IN BOOLEAN, p_lang IN VARCHAR2) return VARCHAR2
--------------------------------------------------------------------------------------------------

function  litteral ( p_number IN NUMBER , p_decimal IN BOOLEAN, p_lang IN VARCHAR2) return VARCHAR2 IS
         v_in_number        VARCHAR2 (100);
         v_box              VARCHAR2(3);
         v_in_character     VARCHAR2(500) := '';
         v_level            NUMBER := 1;
         v_length_max       NUMBER := 1;
         v_label            VARCHAR2(20);
BEGIN




-- initialization

	if (p_lang = 'FR') then

 		fr_init;

	elsif (p_lang = 'IT') then

		it_init;

	elsif (p_lang = 'ES') then


		sp_init;


	else


		raise_application_error(-20001,'Unknown language');

	end if;




--The string is cut in boxes of 3 numbers from the right.

v_in_number := ltrim(to_char(p_number),0);

if v_in_number is null then

v_in_character := NumberList(0);

else


	Loop
	v_length_max := 3 * v_level ;

	if v_length_max < length (v_in_number)then
	v_box := substr( v_in_number ,-v_length_max, 3);
	else
	v_box:= substr( v_in_number ,1,3-(v_length_max-length(v_in_number)));
	end if;

	if v_box is null then
	EXIT;
	end if;

	--At the fisrt level there is no label

	if v_level <> 1 then
		if ltrim(v_box ,'0')is not null then
		v_label := ThousandList(v_level) || ' ';
        	else
        	v_label := '';
		end if;
	end if;

	v_in_character:=hundreds(v_box)||' '||v_label|| v_in_character ;
	v_level := v_level + 1;
	end loop;

end if;

v_in_character := rtrim (rtrim(v_in_character, '-' ));
v_in_character := replace( v_in_character ,'  ',' ');

if p_lang = 'FR' then

  v_in_character := fr_exceptions(v_in_character);
  v_in_character := fr_plural(v_in_character);
  v_in_character := fr_currency(v_in_character, p_decimal);

elsif p_lang = 'IT' then

 v_in_character := it_exceptions(v_in_character);
 v_in_character := it_plural(v_in_character);

elsif p_lang = 'ES' then

 v_in_character := sp_exceptions(v_in_character);
 v_in_character := sp_plural(v_in_character);

end if;


RETURN v_in_character;
END;


-----------------------------------------------------------------------------------
-- function litteral_amount(p_number IN NUMBER, p_lang IN VARCHAR2) return VARCHAR2
-----------------------------------------------------------------------------------

function litteral_amount(p_number IN NUMBER, p_lang IN VARCHAR2) return VARCHAR2 IS

v_whole_part    NUMBER;
v_decimal_part  NUMBER;
v_in_character  VARCHAR2(250);

BEGIN

-- Separation in a whole part and a decimal part.
v_whole_part  :=  floor (p_number);
v_decimal_part := floor ((p_number - v_whole_part  )* 100 );



-- Verify the number is positive. Negative numbers get mucked up by the sign


    if p_number < 0 then

                raise_application_error(-20001,'Numerical value is less than zero :'|| p_number);

    end if;


if p_lang = 'FR' then

	if v_decimal_part <> 0 then
	v_in_character := litteral(v_whole_part, FALSE, p_lang)||' '|| litteral(v_decimal_part, TRUE, p_lang)|| '.' ;
	else
	v_in_character := litteral(v_whole_part, FALSE, p_lang)|| '.' ;
	end if;

elsif p_lang = 'IT' then


	if  v_decimal_part <> 0 then
        v_in_character:=litteral(v_whole_part, FALSE, p_lang)||'/'||to_char(v_decimal_part)|| '.' ;
        else
	v_in_character:=litteral(v_whole_part, FALSE, p_lang)|| '.' ;
	end if;



elsif  p_lang = 'ES'  then

	if  v_decimal_part <> 0 then
        v_in_character:=litteral(v_whole_part, FALSE, p_lang)||'/'||to_char(v_decimal_part)|| '.' ;
        else
	v_in_character:=litteral(v_whole_part, FALSE, p_lang)|| '.' ;
	end if;

else
      raise_application_error(-20001 , 'Unknown language :'||p_lang);

end if;


v_in_character := ltrim (v_in_character );
-- First letter with uppercase
v_in_character := upper(substr(v_in_character,1,1))||substr(v_in_character,2);

return v_in_character;

END;

----------------------------------------------------------------------
--function sp_exceptions (p_litteral IN VARCHAR2 ) return VARCHAR2
----------------------------------------------------------------------

function sp_exceptions (p_litteral IN VARCHAR2 ) return VARCHAR2 IS

v_in_character   VARCHAR2 (250);
v_pos            NUMBER;

BEGIN

v_in_character  := p_litteral;

--Build the string for the hundreds that have their own word in spanish

for i in 1..9
loop

if (i = 1) then

 v_in_character := replace(v_in_character, NumberList(i)||' cien', 'cien');

elsif instr(v_in_character, NumberList(i)||' cien') <>0 then

 v_in_character := replace(v_in_character, NumberList(i)||' cien', NumberList(i)||'cientos');

end if;

end loop;

v_in_character := replace(v_in_character,'cincocientos','quinientos');
v_in_character := replace(v_in_character,'sietecientos','setecientos');
v_in_character := replace(v_in_character,'nuevecientos','novecientos');

-- When the hundred is not multiplied and followed by a not null dizain/unit (ex : '123')
-- 'cien' should be 'ciento'

for i in 1..g_level
loop

v_pos := instr(v_in_character,'cien ',1,1) ;

if v_pos = 0 then
exit;
end if;

	--if there is not null dizain/unit
	if substr(v_in_character, v_pos + length('cien ') , 3) <> 'mil' then
	v_in_character := substr(v_in_character, 1, v_pos - 1)||'ciento '||substr(v_in_character, v_pos + length('cien '));
        end if;

end loop;

-- 'uno mil' should be 'un mil'
-- 'uno millon' should be 'un millon'
-- A string should not start whith 'un mil ' but with 'mil '

v_in_character := replace(v_in_character,'uno mil','un mil');

if  instr(v_in_character, 'un mil ') = 1 then
 v_in_character := replace(v_in_character,'un mil ','mil ');
end if;

-- 'millon' should be there only once

v_pos := instr(v_in_character, 'millon', 1, 2);

if v_pos <> 0 then
v_pos := instr(v_in_character, 'millon', 1, 1);
v_in_character := substr(v_in_character, 1 , v_pos - 1) || substr(v_in_character, v_pos + length('millon '));
end if;

return v_in_character;

END;

----------------------------------------------------------------------
--function it_exceptions (p_litteral IN VARCHAR2 ) return VARCHAR2
----------------------------------------------------------------------

function it_exceptions (p_litteral IN VARCHAR2 ) return VARCHAR2 IS

v_in_character   VARCHAR2 (250);
v_replace        BOOLEAN := FALSE;

BEGIN

-- No space between numbers in words in Italian

v_in_character  := p_litteral;
v_in_character  := replace (v_in_character, ' ');

-- 'unocento' should be 'cento'

v_in_character := replace ( v_in_character,'unocento', 'cento');

-- 'unomille' should be 'mille'

if instr(v_in_character, 'unomille') = 1 then
v_replace := TRUE;
end if;

for i in 3..g_level
loop

	if instr(v_in_character, ThousandList(i)||'unomille')<> 0 then
	v_replace := TRUE;
	end if;
end loop;

if v_replace then
v_in_character := replace(v_in_character, 'unomille' , 'mille') ;
end if;

-- 'unomilione' should be 'unmilione' and 'unomiliardo' should be 'unmiliardo'

if instr(v_in_character, 'unomili') = 1 then
v_in_character := replace(v_in_character, 'unomili', 'unmili') ;
end if;

return v_in_character;

END;

----------------------------------------------------------------------
--function it_plural (p_litteral IN VARCHAR2 ) return VARCHAR2
----------------------------------------------------------------------

function it_plural (p_litteral IN VARCHAR2 ) return VARCHAR2 IS

v_in_character   VARCHAR2 (250);
v_plural         BOOLEAN:= TRUE;

BEGIN

v_in_character := p_litteral;

for i in 2..g_level
loop

if (i = 2)  then
            if instr(v_in_character , ThousandList(i)) = 1 then
            v_plural  := FALSE;
            end if;

            for j in 3..g_level
            loop
	    	if instr(v_in_character, ThousandList(j)||'mille')<> 0 then
	    	v_plural := FALSE;
	    	end if;
	    end loop;

	    if v_plural then
	    v_in_character := replace (v_in_character, 'mille', 'mila');
	    end if;

else

	if instr(v_in_character, ThousandList(i)) <>0 then

		if instr(v_in_character, 'un'||ThousandList(i)) <>0 then

			if (i = 3) then
                        v_in_character := replace (v_in_character, ThousandList(i), ThousandList(i)||'e');
                        elsif (i= 4) then
			v_in_character := replace (v_in_character, ThousandList(i), ThousandList(i)||'o');
			end if;

		else

			v_in_character := replace (v_in_character, ThousandList(i), ThousandList(i)||'i');

		end if;

	end if;
end if;
end loop;

v_in_character := replace (v_in_character, 'tio', 'to');
v_in_character := replace (v_in_character, 'ao', 'o');
v_in_character := replace (v_in_character, 'iu', 'u');
v_in_character := replace (v_in_character, 'au', 'u');
v_in_character := replace (v_in_character, 'too', 'to');

return v_in_character;

END;

----------------------------------------------------------------------
--function fr_plural (p_litteral IN VARCHAR2 ) return VARCHAR2
----------------------------------------------------------------------

function fr_plural (p_litteral IN VARCHAR2 ) return VARCHAR2 IS
v_plural         VARCHAR2(12);
l_size_plural    NUMBER;
l_multiple       VARCHAR2 (250);
v_in_character   VARCHAR2 (250);
j                NUMBER;
i                NUMBER;
v_pos_multiple   NUMBER;
v_concat_s       BOOLEAN:= TRUE;

BEGIN

v_in_character := p_litteral;

-- Plural of 'quatre-vingt'

v_plural := NumberList(80);
l_size_plural:= length(v_plural);

if instr(substr(v_in_character ,-l_size_plural),v_plural)<> 0 then
 v_in_character := v_in_character ||'s';
end if;

-- Plural for each level

for i in 1..g_level
loop
v_plural := ThousandList(i);
l_size_plural:= length(v_plural);

  if (i = 1) then
    if instr(substr(v_in_character ,-l_size_plural),v_plural )<> 0 then
      --Check whether 'hundred' is multiplied
    l_multiple:=ltrim(rtrim(substr(v_in_character ,1,length(v_in_character)- l_size_plural)));
      if l_multiple is not null then

        for j in 1..g_level
          loop
          v_pos_multiple:=instr(l_multiple, ThousandList(j),-1 );
            if v_pos_multiple <> 0 and (length(l_multiple) - v_pos_multiple < 8) then
            v_concat_s :=  FALSE;
		end if;
          end loop;
         else
         v_concat_s :=  FALSE;
         end if;
      else
      v_concat_s :=  FALSE;
      end if;
      if v_concat_s then
      v_in_character := v_in_character ||'s';
      end if;
    elsif (i = 3) or (i = 4) then
      if substr(v_in_character, instr(v_in_character, v_plural) -3, 2)<>'un' then
      v_in_character := replace(v_in_character, v_plural , v_plural ||'s' );
      end if;
    end if;
  end loop;
return v_in_character;
END;
----------------------------------------------------------------------
--function sp_plural (p_litteral IN VARCHAR2 ) return VARCHAR2
----------------------------------------------------------------------

function sp_plural (p_litteral IN VARCHAR2 ) return VARCHAR2 IS

v_in_character   VARCHAR2 (250);
v_pos            NUMBER;
v_plural         BOOLEAN:= TRUE;

BEGIN

v_in_character := p_litteral;

-- Plural of milone

v_pos := instr(v_in_character, ThousandList(3));

 if v_pos > 3 then
 v_in_character := replace(v_in_character , ThousandList(3), ThousandList(3)||'es');
 end if;

return v_in_character;
END;

----------------------------------------------------------------------
--function fr_exceptions (p_litteral IN VARCHAR2) return VARCHAR2 IS
----------------------------------------------------------------------

function fr_exceptions (p_litteral IN VARCHAR2) return VARCHAR2 IS
         v_in_character    VARCHAR2(500);
         v_replace BOOLEAN := FALSE;

BEGIN

v_in_character := p_litteral;

-- 'un cent' should be 'cent'

	if instr(v_in_character, 'un cent') <> 0 then
	v_in_character := replace ( v_in_character, 'un cent', 'cent');
	end if;

-- 'un mille' should be 'mille'

if instr(v_in_character, 'un mille') = 1 then
v_replace := TRUE;
end if;

for i in 3..g_level
loop

	if instr(v_in_character, ThousandList(i)||' '||'un mille')<> 0 then
	v_replace := TRUE;
	end if;
end loop;

if v_replace then
v_in_character := replace(v_in_character, 'un mille' , 'mille') ;
end if;

return v_in_character ;
END;

----------------------------------------------------------------------
--function fr_currency (p_litteral IN VARCHAR2, p_decimal IN BOOLEAN) return VARCHAR2 IS
----------------------------------------------------------------------

function fr_currency (p_litteral IN VARCHAR2, p_decimal IN BOOLEAN) return VARCHAR2 IS
         v_article_l       VARCHAR2(3) := ' d''';
         v_article         BOOLEAN:= FALSE;
	 v_plural          BOOLEAN:= TRUE;
         v_in_character    VARCHAR2(250);

BEGIN

v_in_character := p_litteral;
-- Plural treatment
for i in 0..1
loop
if v_in_character = NumberList(i) then
v_plural := FALSE;
end if;
end loop;
if not p_decimal then
-- "Euros" should be prefixed by " d' " for amounts ending with million(s)/milliard(s).

	for i in 3..g_level
	loop

	        if  instr(v_in_character , ThousandList(i)|| 's' ) <> 0 then

                        if substr(v_in_character, instr(v_in_character, ThousandList(i)||'s'))=
                        ThousandList(i)||'s' then

                                       v_article := TRUE;

                        end if;

               elsif instr(v_in_character, ThousandList(i))<> 0 then

                     if substr(v_in_character, instr(v_in_character, ThousandList(i)))= ThousandList(i) then

                        v_article := TRUE;

                     end if;

              end if;

          end loop;

if v_article then
v_in_character := v_in_character || v_article_l ||'Euros';
else
if v_plural then
v_in_character := v_in_character ||' Euros';
else
v_in_character := v_in_character ||' Euro';
end if;
end if;
else
-- traitement decimal
if v_plural then
v_in_character := v_in_character ||' Cents';
else
v_in_character := v_in_character ||' Cent';
end if;
end if;
return v_in_character;
END;

END;


/
