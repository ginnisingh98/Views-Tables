--------------------------------------------------------
--  DDL for Package Body WMS_BARCODE_STUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."WMS_BARCODE_STUB" AS
/* $Header: WMSBARCB.pls 115.2 2002/06/13 04:02:06 pkm ship        $ */


-- ---------------------------------------------------------------------------------------------------------
-- Function:	Start_Digit
--
-- Parameters:		        1) BarCode Type
--				2) BarCode font name
--
-- Description: This Function  assigns the Start Character for a specific barcode type
--
-- ---------------------------------------------------------------------------------------------------------

FUNCTION        Start_Digit(
                        p_barcode_type       IN      VARCHAR2,
                        p_barcode_font_name  IN      VARCHAR2
                        ) return VARCHAR2 IS
l_barcode_sub_type  VARCHAR2(20) := 'CODE A';
BEGIN
        IF p_barcode_type = 'CODE 39' THEN
                return '*';
        ELSIF p_barcode_type = 'CODE 128' THEN
                IF l_barcode_sub_type = 'CODE A' THEN
                        return '{';
                ELSIF l_barcode_sub_type = 'CODE B' THEN
                        return '|';
                ELSIF l_barcode_sub_type = 'CODE C' THEN
                        return '}';
                 -- can add code for any other type of barcodes here
                END IF;
        END IF;
END Start_digit;
-- ---------------------------------------------------------------------------------------------------------
-- Function:	   Stop_Digit
-- Parameters:		        1) BarCode Type
--				2) BarCode font name
--
-- Description: This Function  assigns the Stop Character for a barcode font
--
-- ---------------------------------------------------------------------------------------------------------

FUNCTION        Stop_Digit(
                        p_barcode_type       IN      VARCHAR2,
                        p_barcode_font_name  IN      VARCHAR2
                        ) return VARCHAR2 IS
l_barcode_sub_type  VARCHAR2(20) := 'CODE A';
BEGIN
        IF p_barcode_type = 'CODE 39' THEN
                return '*';
        ELSIF p_barcode_type = 'CODE 128' THEN
                return '~ ';
                -- can add code for any other type of barcodes here
        END IF;
END Stop_digit;

-- ---------------------------------------------------------------------------------------------------------
-- Function:	   CheckSum_Digit
-- Parameters:		        1) BarCode Type
--				2) BarCode font name
--                              3) Input Text which needs to be barcoded
--
-- Description: This Function  Calculates the Checksum for a given text and font and returns it
--
-- ---------------------------------------------------------------------------------------------------------

FUNCTION        Checksum_Digit(
                        p_barcode_type       IN      VARCHAR2,
                        p_barcode_font_name  IN      VARCHAR2,
                        p_barcode_text       IN      VARCHAR2
                        ) return NUMBER IS
l_barcode_sub_type  VARCHAR2(20) := 'CODE A';
BarCodeOut VARCHAR2(1) := '';
BarTextOut VARCHAR2(100) := '';
TempString VARCHAR2(100) := '';
CheckSum number;
barcode_text VARCHAR2(100):= RTrim(LTrim(p_barcode_text));
Total NUMBER;
ThisChar NUMBER;
CharValue NUMBER;
CheckSumValue NUMBER;
Weighting NUMBER;
CNT NUMBER;
BEGIN
        IF p_barcode_type = 'CODE 39' THEN
                return '';
        ELSIF p_barcode_type = 'CODE 128' THEN
/*-----------------------------------------------------------------------------------------------
 Convert input string to bar code 128 A or B or C format, Pass Subset 'CODE A','CODE B', 'CODE C'
 ------------------------------------------------------------------------------------------------*/

        -- Set up for the subset we are in
        IF l_barcode_sub_type IN ('CODE A','CODE B') then
                If l_barcode_sub_type = 'CODE A' Then
                        Total := 103;
                Else
                        Total := 104;
                End If;

                -- Calculate the checksum, mod 103 and build output string
                For II IN 1..length(barcode_text) loop
                        --Find the ASCII value of the current character
                        ThisChar := (ascii(substr(barcode_text,II,1)));
                        --Calculate the bar code 128 value
                        If ThisChar < 123 Then
                                CharValue := ThisChar - 32;
                        Else
                                CharValue := ThisChar - 70;
                        End If;
                        --add this value to sum for checksum work
                        Total := Total + (CharValue * II);
			/*
                        --Now work on output string, no spaces in TrueType fonts
                        If substr(barcode_text,II,1) = ' ' Then
                                BarTextOut := BarTextOut || Chr(174);
                        Else
                                BarTextOut := BarTextOut || substr(barcode_text,II,1);
                        End If; */
                end loop;

                -- Find the remainder when Sum is divided by 103
                CheckSumValue := Mod(Total,103);
                -- Translate that value to an ASCII character
                If CheckSumValue > 90 Then
                        CheckSum := (CheckSumValue + 70);
                ElsIf CheckSumValue > 0  Then
                        CheckSum := (CheckSumValue + 32);
                Else
                        CheckSum := (174);
                End If;

        ELSE
                -- generate barcode for Subset C
                -- Throw away non-numeric data
                TempString := '';
                For I in 1..length(barcode_text) loop
                        If ((ascii(substr(barcode_text, I, 1))) > 47 and (ascii(substr(barcode_text, I, 1))) < 58) Then
                                TempString := TempString || substr(barcode_text, I, 1);
                        End If;
                end loop;

                -- If not an even number of digits, add a leading 0
                If (Length(TempString) Mod 2) = 1 Then
                        TempString := '0' || TempString;
                End If;

                Total := 105;
                Weighting := 1;

                -- Calculate the checksum, mod 103 and build output string
                CNT := 1;
                while (CNT <= length(TempString)) loop
                        --Break string into pairs of digits and get value
                        CharValue := substr(TempString, CNT, 2);
                        --Multiply value times weighting and add to sum
                        Total := Total + (CharValue * Weighting);
                        Weighting := Weighting + 1;
			/*
                        --translate value to ASCII and save in BarTextOut
                        If CharValue < 90 Then
                                BarTextOut := BarTextOut || Chr(CharValue + 33);
                        ElsIf CharValue < 171 Then
                                BarTextOut := BarTextOut || Chr(CharValue + 71);
                        Else
                                BarTextOut := BarTextOut || Chr(CharValue + 76);
                        End If; */
                        CNT := CNT + 2;
                end loop;

                -- Find the remainder when Sum is divided by 103
                CheckSumValue := (Total Mod 103);
                -- Translate that value to an ASCII character
                If CheckSumValue < 90 Then
                        CheckSum := (CheckSumValue + 33);
                ElsIf CheckSumValue < 100 Then
                        CheckSum := (CheckSumValue + 71);
                Else
                        CheckSum := (CheckSumValue + 76);
                End If;

            End if;

                --BarCodeOut :=  CheckSum;

                --Return the string
                return(CheckSum);
        END IF;
END CheckSum_digit;

-- ---------------------------------------------------------------------------------------------------------
-- Function:	   Additional_CheckSum_Digit
-- Parameters:		        1) BarCode Type
--				2) BarCode font name
--                              3) Input Text which needs to be barcoded
--
-- Description: This Function  Calculates the Optional Second Checksum for a given text and font and returns it
--
-- ---------------------------------------------------------------------------------------------------------

FUNCTION        Additional_CheckSum_digit(
                        p_barcode_type       IN      VARCHAR2,
                        p_barcode_font_name  IN      VARCHAR2,
                        p_barcode_text       IN      VARCHAR2
                        ) return NUMBER IS
l_barcode_sub_type  VARCHAR2(20) := 'CODE A';
BEGIN
        -- add code here to generate additional checksum digits if the barcode type
        -- requires more than one checksum  digit
        return null;
END Additional_CheckSum_digit;

-- ---------------------------------------------------------------------------------------------------------
-- Function:	   Carriage_return
-- Parameters:		        1) BarCode Type
--				2) BarCode font name
--
-- Description: This Function returns the Carriage return string for a barcode font.
--
-- ---------------------------------------------------------------------------------------------------------

FUNCTION        Carriage_return(
                        p_barcode_type       IN      VARCHAR2,
                        p_barcode_font_name  IN      VARCHAR2
                        ) return VARCHAR2 IS
l_barcode_sub_type  VARCHAR2(20) := 'CODE A';
BEGIN
        IF p_barcode_type = 'CODE 39' THEN
                return '*'||fnd_global.local_chr(10)||fnd_global.local_chr(10)||'*';
        ELSIF p_barcode_type = 'CODE 128' THEN
                IF l_barcode_sub_type = 'CODE A' THEN
                        return 'm';
                ELSIF l_barcode_sub_type = 'CODE B' THEN
                        return (fnd_global.local_chr(171)||'m');
                ELSIF l_barcode_sub_type = 'CODE C' THEN
                        return fnd_global.local_chr(10);
                END IF;
        END IF;
END Carriage_return;


END WMS_BARCODE_STUB;

/
