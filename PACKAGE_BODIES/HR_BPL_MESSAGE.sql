--------------------------------------------------------
--  DDL for Package Body HR_BPL_MESSAGE
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."HR_BPL_MESSAGE" AS
/* $Header: perbamsg.pkb 120.0 2005/05/31 16:40:26 appldev noship $ */

    MSGNAME varchar2(30);
    MSGDATA varchar2(32000);
    MSGSET  boolean := FALSE;
    MSGAPP  varchar2(50);
    g_mes_lng varchar2(10);

/*----------------------------------------------------*/
/* Updated versions of the SET_NAME procedure which   */
/* which allow the settng of the translating lang     */
/*----------------------------------------------------*/


procedure SET_NAME_PSN(APPLICATION in varchar2,
                   NAME in varchar2,
                   p_person_id in number) is
    begin
        MSGAPP  := APPLICATION;
        MSGNAME := NAME;
        MSGDATA := '';
        MSGSET  := TRUE;
    /* SET LANG*/
        g_mes_lng := hr_bpl_alert_recipient.get_psn_lng(p_person_id);

    end;

procedure SET_NAME_SUP(APPLICATION in varchar2,
                   NAME in varchar2,
                   p_assignment_id in number) is
    begin
        MSGAPP  := APPLICATION;
        MSGNAME := NAME;
        MSGDATA := '';
        MSGSET  := TRUE;
    /* SET LANG*/
        g_mes_lng := hr_bpl_alert_recipient.Get_asg_sup_lng(p_assignment_id);

    end;

procedure SET_NAME_PSUP(APPLICATION in varchar2,
                   NAME in varchar2,
                   p_assignment_id in number) is
    begin
        MSGAPP  := APPLICATION;
        MSGNAME := NAME;
        MSGDATA := '';
        MSGSET  := TRUE;
    /* SET LANG*/
        g_mes_lng := hr_bpl_alert_recipient.Get_pasg_sup_lng(p_assignment_id);

    end;

procedure SET_NAME_PSN_PSUP(APPLICATION in varchar2,
                   NAME in varchar2,
                   p_person_id in number) is
    begin
        MSGAPP  := APPLICATION;
        MSGNAME := NAME;
        MSGDATA := '';
        MSGSET  := TRUE;
    /* SET LANG*/
        g_mes_lng := hr_bpl_alert_recipient.get_psn_lng(p_person_id);

    end;

procedure SET_NAME(APPLICATION in varchar2,
                   NAME in varchar2,
                   p_business_group_id in number) is
    begin
        MSGAPP  := APPLICATION;
        MSGNAME := NAME;
        MSGDATA := '';
        MSGSET  := TRUE;
    /* SET LANG*/
        g_mes_lng := hr_bpl_alert_recipient.get_bg_lng(p_business_group_id);
    end;


/*----------------------------------------------------*/
/* Updated version of the GET_STRING function, which  */
/* allows the passing of a translation langauge       */
/*                                                    */
/*----------------------------------------------------*/


function GET_STRING_LNG_BG(APPIN in varchar2,
	                    NAMEIN in varchar2)
    return varchar2 is MSG varchar2(2000) := NULL;

     cursor c1(NAME_ARG varchar2) is
            select message_text
            from fnd_new_messages m, fnd_application a
            where NAME_ARG = m.message_name
            and m.language_code =  g_mes_lng
            and APPIN = a.application_short_name
	        and m.application_id = a.application_id;
      cursor c2(NAME_ARG varchar2) is
            select message_text
            from fnd_new_messages m, fnd_application a
            where NAME_ARG = m.message_name
            and 'US' = m.language_code
            and APPIN = a.application_short_name
	        and m.application_id = a.application_id;
    begin
       	/* get the message text out of the table */
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

/*----------------------------------------------------*/
/* Updated version of the GET function, which allows  */
/* the passing of a translation langauge              */
/*----------------------------------------------------*/

function GET return varchar2 is
        MSG       varchar2(2000);
	TOK_NAM   varchar2(30);
	TOK_VAL   varchar2(2000);
	SRCH      varchar2(2000);
        TTYPE     varchar2(1);
        POS       NUMBER;
	NEXTPOS   NUMBER;
	DATA_SIZE NUMBER;
    begin
        if (not MSGSET) then
            MSG := '';
            return MSG;
        end if;
	MSG := GET_STRING_LNG_BG(MSGAPP, MSGNAME);
	if ((msg is NULL) OR (msg = '')) then
            MSG := MSGNAME;
	end if;
        POS := 1;
	DATA_SIZE := LENGTH(MSGDATA);
        while POS < DATA_SIZE loop
            TTYPE := SUBSTR(MSGDATA, POS, 1);
            POS := POS + 2;
            /* Note that we are intentionally using chr(0) rather than */
            /* FND_GLOBAL.LOCAL_CHR() for a performance bug (982909) */
            NEXTPOS := INSTR(MSGDATA, chr(0), POS);
            if (NEXTPOS = 0) then /* For bug 1893617 */
              exit; /* Should never happen, but prevent spins on bad data*/
            end if;
	    TOK_NAM := SUBSTR(MSGDATA, POS, NEXTPOS - POS);
            POS := NEXTPOS + 1;
            NEXTPOS := INSTR(MSGDATA, chr(0), POS);
            if (NEXTPOS = 0) then /* For bug 1893617 */
              exit; /* Should never happen, but prevent spins on bad data*/
            end if;
            TOK_VAL := SUBSTR(MSGDATA, POS, NEXTPOS - POS);
            POS := NEXTPOS + 1;

            if (TTYPE = 'Y') then  /* translated token */
                TOK_VAL := GET_STRING_LNG_BG(MSGAPP, TOK_VAL); ---------------
            elsif (TTYPE = 'S') then  /* SQL query token */
                TOK_VAL := FETCH_SQL_TOKEN(TOK_VAL);
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


/* --------------------------------------------------*/
/* Required unchanged FND_MESSAGE Functions          */
/* SET_NAME PROCEDURE HAS BEEN UPDATEED              */
/*---------------------------------------------------*/
/*                                                              */
/*	FETCH_SQL_TOKEN- get the value for a SQL Query token        */
/*    **     This procedure is only to be called by the ATG     */
/*    **     not for external use                               */

    function FETCH_SQL_TOKEN(TOK_VAL in varchar2) return varchar2 is
      token_text  varchar2(2000);
    begin
      if ( UPPER(SUBSTR(TOK_VAL, 1, 6) ) = 'SELECT' ) then
        execute immediate TOK_VAL
           into token_text;
      else
        token_text :=
                'Parameter error in FND_MESSAGE.FETCH_SQL_TOKEN(Token SQL):  '
                || FND_GLOBAL.NEWLINE
                || 'TOK_VAL must begin with keyword SELECT';
      end if;
      return token_text;
    exception
      when others then
       token_text :=
                'SQL-Generic error in FND_MESSAGE.FETCH_SQL_TOKEN(Token SQL):  '
                || FND_GLOBAL.NEWLINE
                || SUBSTR(sqlerrm, 1, 1900);
       return token_text;
    end;

/*
**  ### OVERLOADED (new private version) ###
**
**	SET_TOKEN - define a message token with a value
**  Private:  This procedure is only to be called by the ATG
**            not for external use
**  Arguments:
**   token    - message token
**   value    - value to substitute for token
**   ttype    - type of token substitution:
**                 'Y' translated, or "Yes, translated"
**                 'N' constant, or "No, not translated"
**                 'S' SQL query
**
*/
procedure SET_TOKEN(TOKEN in varchar2,
                    VALUE in varchar2,
                    TTYPE in varchar2 default 'N') is
    tok_type varchar2(1);
    begin

        if ( TTYPE not in ('Y','N','S')) then
           tok_type := 'N';
        else
           tok_type := TTYPE;
        end if;

/* Note that we are intentionally using chr(0) rather than */
/* FND_GLOBAL.LOCAL_CHR() for a performance bug (982909) */
        MSGDATA := MSGDATA||tok_type||chr(0)||TOKEN||chr(0)||VALUE||chr(0);

    end set_token;

/*                                                      */
/*  ### OVERLOADED (original version) ###               */
/*  							*/
/*	SET_TOKEN - define a message token with a value,*/
/*              either constant or translated           */
/*  Public:  This procedure to be used by all           */
/*							*/
procedure SET_TOKEN(TOKEN in varchar2,
                    VALUE in varchar2,
                TRANSLATE in boolean default false) is
TTYPE varchar2(1);
    begin
        if TRANSLATE then
            TTYPE := 'Y';
        else
            TTYPE := 'N';
        end if;

        SET_TOKEN(TOKEN, VALUE, TTYPE);

    end set_token;

/*                                                                      */
/* SET_TOKEN_SQL - define a message token with a SQL query value        */
/*                                                                      */
/* Description:                                                         */
/*   Like SET_TOKEN, except here the value is a SQL statement which     */
/*   returns a single varchar2 value.  (e.g. A translated concurrent    */
/*   manager name.)  This statement is run when the message text is     */
/*   resolved, and the result is used in the token substitution.        */
/*                                                                      */
/* Arguments:                                                           */
/*   token - Token name                                                 */
/*   value - Token value.  A SQL statement                              */
/*                                                                      */

    procedure SET_TOKEN_SQL (TOKEN in varchar2,
                             VALUE in varchar2) is

    TTYPE  varchar2(1) := 'S';  -- SQL Query
    begin

        SET_TOKEN(TOKEN, VALUE, TTYPE );

    end set_token_sql;

    /* This procedure is only to be called by the ATG; */
    /*  not for external use */
    procedure RETRIEVE(MSGOUT out NOCOPY varchar2) is
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



end hr_bpl_message;

/
