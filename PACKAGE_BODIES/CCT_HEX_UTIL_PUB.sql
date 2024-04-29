--------------------------------------------------------
--  DDL for Package Body CCT_HEX_UTIL_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."CCT_HEX_UTIL_PUB" AS
/* $Header: cctphxub.pls 115.0 2003/03/14 20:01:20 svinamda noship $ */

G_PKG_NAME 	CONSTANT VARCHAR2(30) := 'CCT_HEX_UTIL_PUB';


FUNCTION DECNUM_TO_HEXCHAR
(
    p_dec_num IN NUMBER
)
RETURN VARCHAR2 IS
l_hex_num VARCHAR2(1);
BEGIN
    l_hex_num := '';
    if ((p_dec_num = 0) or ((p_dec_num > 0) and (p_dec_num < 10)))
        then
            l_hex_num := TO_CHAR(p_dec_num);
            --dbms_output.put_line('l_hex_num =  ' || l_hex_num);
    elsif (p_dec_num = 10) then l_hex_num := 'A';
    elsif (p_dec_num = 11) then l_hex_num := 'B';
    elsif (p_dec_num = 12) then l_hex_num := 'C';
    elsif (p_dec_num = 13) then l_hex_num := 'D';
    elsif (p_dec_num = 14) then l_hex_num := 'E';
    elsif (p_dec_num = 15) then l_hex_num := 'F';
    end if;
    --dbms_output.put_line('l_hex_num =  ' || l_hex_num);
    return l_hex_num;
END;


FUNCTION DEC_TO_HEX
(
    p_dec_num IN NUMBER
)
RETURN VARCHAR2 IS
l_hex_num VARCHAR2(2000);
l_quotient NUMBER;
l_remainder number;
BEGIN
    l_hex_num := '';
    l_quotient := p_dec_num;
    loop
        l_remainder := mod(l_quotient,16);
        --dbms_output.put_line('l_remainder := ' || l_remainder);
        l_quotient := trunc(l_quotient/16);
        --dbms_output.put_line('l_quotient :=' || l_quotient);
        l_hex_num := l_hex_num || decnum_to_hexchar(l_remainder);
        --dbms_output.put_line('l_hex_num :=' || l_hex_num);
        exit when (l_quotient = 0);
    end loop;
    return l_hex_num;
END;


END CCT_HEX_UTIL_PUB;

/
