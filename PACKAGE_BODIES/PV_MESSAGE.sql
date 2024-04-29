--------------------------------------------------------
--  DDL for Package Body PV_MESSAGE
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PV_MESSAGE" as
/* $Header: pvxvmsgb.pls 115.6 2002/12/11 10:41:58 anubhavk ship $ */

    MSGNAME varchar2(30);
    MSGDATA varchar2(2000);
    MSGSET  boolean := FALSE;
    MSGAPP  varchar2(50);


    procedure SET_NAME(APPLICATION in varchar2, NAME in varchar2) is
    begin
        MSGAPP  := APPLICATION;
        MSGNAME := NAME;
        MSGDATA := '';
        MSGSET  := TRUE;
    end;


    procedure SET_TOKEN(TOKEN in varchar2,
                        VALUE in varchar2,
                        TRANSLATE in boolean default false) is
    FLAG  varchar2(1);
    begin
        if TRANSLATE then
            FLAG := 'Y';
        else
            FLAG := 'N';
        end if;
	/* Note that we are intentionally using chr(0) rather than */
        /* FND_GLOBAL.LOCAL_CHR() for a performance bug (982909) */
        MSGDATA := MSGDATA||FLAG||' '||TOKEN||' '||VALUE||' ';
    end set_token;

    /* This procedure is only to be called by the ATG; */
    /*  not for external use */
    procedure RETRIEVE(MSGOUT out nocopy varchar2) is
        OUT_VAL varchar2(2000);
    begin
        if MSGSET then
            /* Note that we are intentionally using chr(0) rather than */
            /* FND_GLOBAL.LOCAL_CHR() for a performance bug (982909) */
            OUT_VAL := MSGAPP||chr(0)||MSGNAME||chr(0)||MSGDATA;
            MSGSET := FALSE;
        else
            OUT_VAL := '';
        end if;

	MSGOUT := OUT_VAL;
    end;

    procedure CLEAR is
    begin
        msgset := FALSE;
    end;

    procedure RAISE_ERROR is
    begin
	/* Note that we are intentionally using chr(0) rather than */
        /* FND_GLOBAL.LOCAL_CHR() for a performance bug (982909) */
        raise_application_error(-20001,
                                MSGNAME||': '||replace(rtrim(MSGDATA,chr(0)),
                                chr(0), ', '));
    end;

    /*
    **	GET_STRING- get a particular translated message
    **       from the message dictionary database.
    **
    **  This is a one-call interface for when you just want to get a
    **  message without doing any token substitution.
    **  Returns NAMEIN (Msg name)  if the message cannot be found.
    */
    function GET_STRING(APPIN in varchar2,
	      NAMEIN in varchar2) return varchar2 is
        MSG  varchar2(2000) := NULL;
        cursor c1(NAME_ARG varchar2) is select message_text
            from fnd_new_messages m, fnd_application a
            where NAME_ARG = m.message_name
            and m.language_code = userenv('LANG')
            and APPIN = a.application_short_name
	    and m.application_id = a.application_id;
        cursor c2(NAME_ARG varchar2) is select message_text
            from fnd_new_messages m, fnd_application a
            where NAME_ARG = m.message_name
            and 'US' = m.language_code
            and APPIN = a.application_short_name
	    and m.application_id = a.application_id;
    begin
	/* get the message text out nocopy of the table */
        open c1(UPPER(NAMEIN));
        fetch c1 into MSG;
	if (c1%NOTFOUND) then
           open c2(UPPER(NAMEIN));
           fetch c2 into MSG;
           if (c2%NOTFOUND) then
              MSG := NAMEIN;
           end if;
           close c2;
        end if;
	close c1;
        /* double ampersands don't have anything to do with tokens, they */
        /* represent access keys.  So we translate them to single ampersands*/
        /* so that the access key code will recognize them. */
	MSG := substrb(REPLACE(MSG, '&&', '&'),1,2000);
	return MSG;
    end;

    /*
    **	GET_NUMBER- get the message number of a particular message.
    **
    **  This routine returns only the message number, given a message
    **  name.  This routine will be only used in rare cases; normally
    **  the message name will get displayed automatically by message
    **  dictionary when outputting a message on the client.
    **
    **  You should _not_ use this routine to construct a system for
    **  storing translated messages (along with numbers) on the server.
    **  If you need to store translated messages on a server for later
    **  display on a client, use the set_encoded/get_encoded routines
    **  to store the messages as untranslated, encoded messages.
    **
    **  If you don't know the name of the message on the stack, you
    **  can use get_encoded and parse_encoded to find it out.
    **
    **  Returns 0 if the message has no message number,
    **         or if its message number is zero.
    **       NULL if the message can't be found.
    */
    function GET_NUMBER(APPIN in varchar2,
	      NAMEIN in varchar2) return NUMBER is
        MSG_NUM NUMBER := NULL;
        cursor c1(NAME_ARG varchar2) is select message_number
            from fnd_new_messages m, fnd_application a
            where NAME_ARG = m.message_name
            and m.language_code = userenv('LANG')
            and APPIN = a.application_short_name
	    and m.application_id = a.application_id;
        cursor c2(NAME_ARG varchar2) is select message_number
            from fnd_new_messages m, fnd_application a
            where NAME_ARG = m.message_name
            and 'US' = m.language_code
            and APPIN = a.application_short_name
	    and m.application_id = a.application_id;
    begin
	/* get the message text out nocopy of the table */
        open c1(UPPER(NAMEIN));
        fetch c1 into MSG_NUM;
        if(MSG_NUM is NULL) then
           MSG_NUM := 0;
	end if;
	if (c1%NOTFOUND) then
           open c2(UPPER(NAMEIN));
           fetch c2 into MSG_NUM;
           if(MSG_NUM is NULL) then
              MSG_NUM := 0;
   	   end if;
           if (c2%NOTFOUND) then
              MSG_NUM := NULL;
           end if;
           close c2;
        end if;
	close c1;
	return MSG_NUM;
    end;



    /*
    **	GET- get a translated and token substituted message
    **       from the message dictionary database.
    **       Returns NULL if the message cannot be found.
    */
    function GET return varchar2 is
        MSG       varchar2(2000);
	TOK_NAM   varchar2(30);
	TOK_VAL   varchar2(2000);
	SRCH      varchar2(2000);
        FLAG      varchar2(1);
        POS       NUMBER;
	NEXTPOS   NUMBER;
	DATA_SIZE NUMBER;
	TSLATE    BOOLEAN;
    begin
        if (not MSGSET) then
            MSG := '';
            return MSG;
        end if;
	MSG := GET_STRING(MSGAPP, MSGNAME);
	if ((msg is NULL) OR (msg = '')) then
            MSG := MSGNAME;
	end if;
        POS := 1;
	DATA_SIZE := LENGTH(MSGDATA);
        while POS < DATA_SIZE loop
            FLAG := SUBSTR(MSGDATA, POS, 1);
            POS := POS + 2;
            /* Note that we are intentionally using chr(0) rather than */
            /* FND_GLOBAL.LOCAL_CHR() for a performance bug (982909) */
            NEXTPOS := INSTR(MSGDATA, chr(0), POS);
	    TOK_NAM := SUBSTR(MSGDATA, POS, NEXTPOS - POS);
            POS := NEXTPOS + 1;
            NEXTPOS := INSTR(MSGDATA, chr(0), POS);
            TOK_VAL := SUBSTR(MSGDATA, POS, NEXTPOS - POS);
            POS := NEXTPOS + 1;

            if (FLAG = 'Y') then  /* translated token */
                TOK_VAL := GET_STRING(MSGAPP, TOK_VAL);
            end if;
            SRCH := '&' || TOK_NAM;
            if (INSTR(MSG, SRCH) <> 0) then
                MSG := substrb(REPLACE(MSG, SRCH, TOK_VAL),1,2000);
            else
                /* try the uppercased version of the token name in case */
                /* the caller is (wrongly) passing a mixed case token name */
                /* Because now (July 99) all tokens in msg text should be */
                /* uppercase. */
                SRCH := '&' || UPPER(TOK_NAM);
                if (INSTR(MSG, SRCH) <> 0) then
                   MSG := substrb(REPLACE(MSG, SRCH, TOK_VAL),1,2000);
                else
                   MSG :=substrb(MSG||' ('||TOK_NAM||'='||TOK_VAL||')',1,2000);
              end if;
            end if;
        END LOOP;
        /* double ampersands don't have anything to do with tokens, they */
        /* represent access keys.  So we translate them to single ampersands*/
        /* so that the access key code will recognize them. */
	MSG := substrb(REPLACE(MSG, '&&', '&'),1,2000);
	MSGSET := FALSE;
	return MSG;
    end;

    function GET_ENCODED return varchar2 is
    begin
        if MSGSET then
            MSGSET := FALSE;
            /* Note that we are intentionally using chr(0) rather than */
            /* FND_GLOBAL.LOCAL_CHR() for a performance bug (982909) */
	    return  (MSGAPP|| ' '||MSGNAME|| ' '|| MSGDATA);
        else
            return ('');
        end if;
    end;


    /*
    ** SET_ENCODED- Set an encoded message onto the message stack
    */
    procedure SET_ENCODED(ENCODED_MESSAGE IN varchar2) is
        POS       NUMBER;
	NEXTPOS   NUMBER;
    begin
        POS := 1;

	/* Note that we are intentionally using chr(0) rather than */
        /* FND_GLOBAL.LOCAL_CHR() for a performance bug (982909) */
        NEXTPOS := INSTR(ENCODED_MESSAGE, chr(0), POS);
        MSGAPP := SUBSTR(ENCODED_MESSAGE, POS, NEXTPOS - POS);
        POS := NEXTPOS + 1;

        NEXTPOS := INSTR(ENCODED_MESSAGE, chr(0), POS);
        MSGNAME := SUBSTR(ENCODED_MESSAGE, POS, NEXTPOS - POS);
        POS := NEXTPOS + 1;

        MSGDATA := SUBSTR(ENCODED_MESSAGE, POS);

	if((MSGAPP is not null) and (MSGNAME is not null)) then
           MSGSET := TRUE;
	end if;
    end;


    /*
    ** PARSE_ENCODED- Parse the message name and application short name
    **                out nocopy of a message in "encoded" format.
    */
    procedure PARSE_ENCODED(ENCODED_MESSAGE IN varchar2,
			APP_SHORT_NAME  OUT NOCOPY varchar2,
			MESSAGE_NAME    OUT NOCOPY varchar2) is
        POS       NUMBER;
	NEXTPOS   NUMBER;
    begin
        null;
        POS := 1;

	/* Note that we are intentionally using chr(0) rather than */
        /* FND_GLOBAL.LOCAL_CHR() for a performance bug (982909) */
        NEXTPOS := INSTR(ENCODED_MESSAGE, chr(0), POS);
        APP_SHORT_NAME := SUBSTR(ENCODED_MESSAGE, POS, NEXTPOS - POS);
        POS := NEXTPOS + 1;

        NEXTPOS := INSTR(ENCODED_MESSAGE, chr(0), POS);
        MESSAGE_NAME := SUBSTR(ENCODED_MESSAGE, POS, NEXTPOS - POS);
        POS := NEXTPOS + 1;
    end;

end pv_message;

/
