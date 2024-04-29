--------------------------------------------------------
--  DDL for Package Body IGI_IAC_DEBUG_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IGI_IAC_DEBUG_PKG" AS
/* $Header: igiiadeb.pls 120.5.12000000.1 2007/08/01 16:14:38 npandya ship $ */

/*=========================================================================+
 | Function Name:                                                          |
 |    debug                                                                |
 |                                                                         |
 | Description:                                                            |
 |    This function is for debug purpose  writes inmto temperaory file     |
 |    or writes to log or output file                                      |
 |                                                                         |
 +=========================================================================*/

    l_debug_log varchar2(255);
    l_debug_output varchar2(255);
    l_output_dir varchar2(255);
    chr_newline VARCHAR2(8);
    l_calling_function varchar2(250);
    l_debug_switch boolean;
    PROCEDURE debug(p_debug_type Number,p_debug IN VARCHAR2)
      IS
	 l_vc2       VARCHAR2(32000);
	 l_line_size NUMBER;
	 l_pos       NUMBER;

    BEGIN
        l_vc2       := p_debug || chr_newline;
        l_line_size  := 75;
       IF (l_debug_switch) THEN
            fnd_file.put_names(l_debug_log,l_debug_output,l_output_dir);
            fnd_file.put_line(fnd_file.output,p_debug);
       END IF;
       IF p_debug_type = 1 then
            Fnd_file.put_line(fnd_file.log,p_debug);
       ELSIF    p_debug_type = 2 then
            Fnd_file.put_line(fnd_file.output,p_debug);
       END IF;
    EXCEPTION
       WHEN OTHERS THEN
	  NULL;
    END debug;
    /*
    * BOOLTOCHAR
    *
    * A utility function to convert boolean values to char to print in
    * debug statements
    */
    FUNCTION BOOLTOCHAR(value IN BOOLEAN) RETURN VARCHAR2
    IS
    BEGIN
        IF (value) THEN
            RETURN 'TRUE';
        ELSE
            RETURN 'FALSE';
        END IF;
    END BOOLTOCHAR;


    /*
    * Set the debug mode on
    */
    PROCEDURE debug_on(p_calling_function varchar2) IS
    BEGIN
        l_debug_switch := FALSE;
        select substr(value,1,decode ((INSTR(value,',', 1, 1)-1),0,length(value),(INSTR(value,',', 1, 1)-1)))
               into l_output_dir
        from v$parameter
        where name like 'utl%';

        l_calling_function := P_calling_function;
        l_debug_log := P_calling_function || '.log';
        l_debug_output := P_calling_function || '.out';
        IF FND_PROFILE.VALUE('IGI_DEBUG_OPTION') = 'Y'  THEN
            l_debug_switch := TRUE;
        ELSE
            l_debug_switch := FALSE;
        END IF;
       EXCEPTION
       WHEN OTHERS THEN
	    NULL;
    END debug_on;

   /*
    * Set the debug mode off
    */
    PROCEDURE debug_off IS
    BEGIN
        If l_debug_switch then
            fnd_file.close;
        end if;
        l_debug_switch := FALSE;
    END debug_off;

-- ============================FND LOG START===============================


PROCEDURE debug_unexpected_msg(p_full_path IN VARCHAR2) IS
BEGIN
 	IF (FND_LOG.LEVEL_UNEXPECTED >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
	   	FND_MESSAGE.SET_NAME('IGI','IGI_LOGGING_UNEXP_ERROR');
     		FND_MESSAGE.SET_TOKEN('CODE',SQLCODE);
     		FND_MESSAGE.SET_TOKEN('MSG',  SQLERRM);
     		FND_LOG.MESSAGE (FND_LOG.LEVEL_UNEXPECTED,p_full_path, TRUE);
	END IF;
END;

PROCEDURE debug_other_msg(p_level IN NUMBER,
			  p_full_path IN VARCHAR2,

			  p_remove_from_stack IN BOOLEAN) IS


BEGIN
     	IF (p_level >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
		fnd_log.message(p_level,p_full_path,p_remove_from_stack);
        END IF;
END;

PROCEDURE debug_other_string(p_level IN NUMBER,
			     p_full_path IN VARCHAR2,
			     p_string IN VARCHAR2) IS
BEGIN

	IF (p_level >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
	   fnd_log.string(p_level,p_full_path,p_string);
	END IF;
END;


-- ============================FND LOG END ==================================

   -- Enter further code below as specified in the Package spec.
BEGIN
    chr_newline := fnd_global.newline;

END;


/
