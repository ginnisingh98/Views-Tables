--------------------------------------------------------
--  DDL for Package Body JL_BR_INSCRIPTION_NUMBER
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."JL_BR_INSCRIPTION_NUMBER" as
/* $Header: jlbrsicb.pls 120.2.12010000.1 2008/07/31 04:23:32 appldev ship $ */

/*----------------------------------------------------------------------------*
 |   PUBLIC FUNCTIONS/PROCEDURES  					      |
 *----------------------------------------------------------------------------*/

/*----------------------------------------------------------------------------*
 | PROCEDURE                                                                  |
 |    validate_inscription_number              			      	      |
 |                                                                            |
 | DESCRIPTION                                                                |
 |									      |
 | PARAMETERS                                                                 |
 |   INPUT                                                 		      |
 |      p_inscription_type      VARCHAR2   -- Inscription Type: CPF   = '1'   |
 |						                CGC   = '2'   |
 |								Other = '3'   |
 |      p_inscription_number    VARCHAR2   -- Inscription Number              |
 |      p_inscription_branch    VARCHAR2   -- Inscription Branch              |
 |      p_inscription_digit     VARCHAR2   -- Inscription Digit               |
 |									      |
 |   OUTPUT                                                		      |
 |      p_errbuf          	VARCHAR2 -- Error lookup code  	              |
 |					    (Lookup type = 		      |
 |					        'JLBR_INSCRIPTION_NUM_ERRORS')|
 |      p_retcode         	NUMBER   -- Return Code:		      |
 |					    0 = Validation Succeds            |
 |				           -1 = Validation Fails	      |
 |                                                                            |
 | HISTORY                                                                    |
 |      15-OCT-97   Marcia Toriyama    Created                                |
 *----------------------------------------------------------------------------*/
PROCEDURE validate_inscription_number (
 		        p_inscription_type      	IN     VARCHAR2,
                        p_inscription_number    	IN     VARCHAR2,
                        p_inscription_branch    	IN     VARCHAR2,
 		        p_inscription_digit     	IN     VARCHAR2,
			p_errbuf			IN OUT NOCOPY	VARCHAR2,
			p_retcode			IN OUT NOCOPY	NUMBER   ) IS

 l_control_digit_1 number;
 l_control_digit_2 number;
 l_control_digit_XX varchar2(2);

BEGIN

 IF p_inscription_type = '1'
 THEN
     /* Validate CPF */
     IF nvl(p_inscription_branch,'0000') <> '0000'
     THEN
        /* Inscription branch for CPF type should be NULL or zero */
 	p_errbuf := 'CPF_INSCRIPTION_BRANCH_ERR';
	p_retcode:= -1;
     ELSE
	/* Calculate two digit controls of inscription number CPF type */

 	l_control_digit_1 := (11 - mod(
   	(to_number(substr(p_inscription_number,9,1)) * 2   +
    	to_number(substr(p_inscription_number,8,1)) * 3   +
    	to_number(substr(p_inscription_number,7,1)) * 4   +
    	to_number(substr(p_inscription_number,6,1)) * 5   +
    	to_number(substr(p_inscription_number,5,1)) * 6   +
    	to_number(substr(p_inscription_number,4,1)) * 7   +
    	to_number(substr(p_inscription_number,3,1)) * 8   +
    	to_number(substr(p_inscription_number,2,1)) * 9   +
    	to_number(substr(p_inscription_number,1,1)) * 10),11));

 	IF l_control_digit_1 in ('11','10')
	THEN
    	    l_control_digit_1 := 0;
 	END IF;

 	l_control_digit_2 := (11 - mod((l_control_digit_1 * 2   +
    	to_number(substr(p_inscription_number,09,1)) * 3   +
    	to_number(substr(p_inscription_number,08,1)) * 4   +
    	to_number(substr(p_inscription_number,07,1)) * 5   +
    	to_number(substr(p_inscription_number,06,1)) * 6   +
    	to_number(substr(p_inscription_number,05,1)) * 7   +
    	to_number(substr(p_inscription_number,04,1)) * 8   +
    	to_number(substr(p_inscription_number,03,1)) * 9   +
    	to_number(substr(p_inscription_number,02,1)) * 10  +
    	to_number(substr(p_inscription_number,01,1)) * 11),11));

 	IF l_control_digit_2 in ('11','10')
	THEN
    	    l_control_digit_2 := 0;
 	END IF;

 	l_control_digit_XX := substr(to_char(l_control_digit_1),1,1) ||
		    	      substr(to_char(l_control_digit_2),1,1);

 	IF l_control_digit_XX <> p_inscription_digit
	THEN
	    /* Digit controls do not match */
	    p_errbuf := 'CPF_INSCRIPTION_NUMBER_ERR';
	    p_retcode:= -1;
	ELSE
 	    p_retcode:= 0;
 	END IF;
     END IF;

 ELSIF p_inscription_type = '2'
 THEN
	/* Calculate two digit controls of inscription number CGC type */

 	l_control_digit_1 := (11 - mod(
	   (to_number(substr(p_inscription_branch,4,1)) * 2 +
	    to_number(substr(p_inscription_branch,3,1)) * 3 +
	    to_number(substr(p_inscription_branch,2,1)) * 4 +
	    to_number(substr(p_inscription_branch,1,1)) * 5 +
	    to_number(substr(p_inscription_number,9,1)) * 6 +
	    to_number(substr(p_inscription_number,8,1)) * 7 +
	    to_number(substr(p_inscription_number,7,1)) * 8 +
	    to_number(substr(p_inscription_number,6,1)) * 9 +
	    to_number(substr(p_inscription_number,5,1)) * 2 +
	    to_number(substr(p_inscription_number,4,1)) * 3 +
	    to_number(substr(p_inscription_number,3,1)) * 4 +
	    to_number(substr(p_inscription_number,2,1))* 5),11));

	IF l_control_digit_1 in ('11','10')
	THEN
	    l_control_digit_1 := 0;
	END IF;

	l_control_digit_2 := (11 - mod(
	    ( (l_control_digit_1 * 2)   +
	    to_number(substr(p_inscription_branch,4,1)) * 3   +
	    to_number(substr(p_inscription_branch,3,1)) * 4   +
	    to_number(substr(p_inscription_branch,2,1)) * 5   +
	    to_number(substr(p_inscription_branch,1,1)) * 6   +
	    to_number(substr(p_inscription_number,9,1)) * 7   +
	    to_number(substr(p_inscription_number,8,1)) * 8   +
	    to_number(substr(p_inscription_number,7,1)) * 9   +
	    to_number(substr(p_inscription_number,6,1)) * 2   +
	    to_number(substr(p_inscription_number,5,1)) * 3   +
	    to_number(substr(p_inscription_number,4,1)) * 4   +
	    to_number(substr(p_inscription_number,3,1)) * 5   +
	    to_number(substr(p_inscription_number,2,1)) * 6),11));

	IF l_control_digit_2 in ('11','10')
	THEN
	    l_control_digit_2 := 0;
	END IF;

	l_control_digit_XX := substr(to_char(l_control_digit_1),1,1) ||
			      substr(to_char(l_control_digit_2),1,1);

	IF p_inscription_digit <> l_control_digit_XX
	THEN
	    p_errbuf := 'CGC_INSCRIPTION_NUMBER_ERR';
	    p_retcode:= -1;
	ELSE
 	    p_retcode:= 0;
 	END IF;
 ELSIF p_inscription_type = '3'
 THEN
 	    p_retcode:= 0;
 ELSE
	    p_errbuf := 'INSCRIPTION_TYPE_ERR';
	    p_retcode:= -1;
 END IF;

END validate_inscription_number;

END JL_BR_INSCRIPTION_NUMBER;

/
