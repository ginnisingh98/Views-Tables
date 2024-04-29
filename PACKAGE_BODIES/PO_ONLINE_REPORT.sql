--------------------------------------------------------
--  DDL for Package Body PO_ONLINE_REPORT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PO_ONLINE_REPORT" AS
/* $Header: POXPOONB.pls 115.6 2002/11/25 22:40:04 sbull ship $ */

  -- Types :
  --

  -- Constants :
  -- This is used as a delimiter in the Debug Info String

  g_delim                   CONSTANT VARCHAR2(1) := '
';


  -- Private Global Variables :
  --

  -- Debug String

  g_dbug                    VARCHAR2(200) := null;


/* ----------------------------------------------------------------------- */
/*                                                                         */
/*                      Private Function Definition                        */
/*                                                                         */
/* ----------------------------------------------------------------------- */

  FUNCTION online_finsert(p_docid       IN     NUMBER,
                          p_doctyp      IN     VARCHAR2,
                          p_docsubtyp   IN     VARCHAR2,
                          p_lineid      IN     NUMBER,
                          p_shipid      IN     NUMBER,
                          p_message     IN     VARCHAR2,
                          p_reportid    IN     NUMBER,
                          p_numtokens   IN     NUMBER,
                          p_sqlstring   IN     VARCHAR2,
                          p_sequence    IN     NUMBER,
                          p_action_date IN     DATE,
                          p_return_code IN OUT NOCOPY VARCHAR2) RETURN BOOLEAN;


  FUNCTION online_sinsert(p_docid       IN     NUMBER,
                          p_doctyp      IN     VARCHAR2,
                          p_docsubtyp   IN     VARCHAR2,
                          p_lineid      IN     NUMBER,
                          p_shipid      IN     NUMBER,
                          p_message     IN     VARCHAR2,
                          p_reportid    IN     NUMBER,
                          p_numtokens   IN     NUMBER,
                          p_sqlstring   IN     VARCHAR2,
                          p_sequence    IN     NUMBER,
                          p_action_date IN     DATE,
                          p_return_code IN OUT NOCOPY VARCHAR2) RETURN BOOLEAN;


/* ----------------------------------------------------------------------- */
/*                                                                         */
/*   Determines how Multiple Inserts into the Online Reporting table are   */
/*   to be handled                                                         */
/*                                                                         */
/*   Multiple Inserts are handled differently for Messages with Tokens and */
/*   Messages without Tokens                                               */
/*                                                                         */
/*   For Messages with Tokens, Inserts are done using Array Fetch          */
/*                                                                         */
/*   For Messages without Tokens, Inserts are done using a Subquery        */
/*                                                                         */
/* ----------------------------------------------------------------------- */

  -- Parameters :

  -- p_docid : Header ID

  -- p_doctyp : Document Type

  -- p_docsubtyp : Document Subtype

  -- p_lineid : Line ID

  -- p_shipid : Shipment ID

  -- p_message : Message Name

  -- p_reportid : Online Reporting ID

  -- p_numtokens : Number of Tokens

  -- p_sqlstring : SQL String

  -- p_sequence : Sequence

  -- p_action_date : Action Date

  -- p_return_code : Return Code

  FUNCTION insert_many(p_docid       IN     NUMBER,
                       p_doctyp      IN     VARCHAR2,
                       p_docsubtyp   IN     VARCHAR2,
                       p_lineid      IN     NUMBER,
                       p_shipid      IN     NUMBER,
                       p_message     IN     VARCHAR2,
                       p_reportid    IN     NUMBER,
                       p_numtokens   IN     NUMBER,
                       p_sqlstring   IN     VARCHAR2,
                       p_sequence    IN     NUMBER,
                       p_action_date IN     DATE,
                       p_return_code IN OUT NOCOPY VARCHAR2) RETURN BOOLEAN IS

  BEGIN

    g_dbug := 'Starting Online Insert' || g_delim;

    if p_numtokens <> 0 then

      if not online_finsert(p_docid => p_docid,
                            p_doctyp => p_doctyp,
                            p_docsubtyp => p_docsubtyp,
                            p_lineid => p_lineid,
                            p_shipid => p_shipid,
                            p_message => p_message,
                            p_reportid => p_reportid,
                            p_numtokens => p_numtokens,
                            p_sqlstring => p_sqlstring,
                            p_sequence => p_sequence,
                            p_action_date => p_action_date,
                            p_return_code => p_return_code) then

        PO_MESSAGE_S.APP_ERROR(error_name => 'PO_ALL_TRACE_ERROR',
                               token1 => 'FILE',
                               value1 => 'PO_ONLINE_REPORT',
                               token2 => 'ERR_NUMBER',
                               value2 => '005',
                               token3 => 'SUBROUTINE',
                               value3 => 'INSERT_MANY()');
        return(FALSE);

      end if;

    else

      if not online_sinsert(p_docid => p_docid,
                            p_doctyp => p_doctyp,
                            p_docsubtyp => p_docsubtyp,
                            p_lineid => p_lineid,
                            p_shipid => p_shipid,
                            p_message => p_message,
                            p_reportid => p_reportid,
                            p_numtokens => p_numtokens,
                            p_sqlstring => p_sqlstring,
                            p_sequence => p_sequence,
                            p_action_date => p_action_date,
                            p_return_code => p_return_code) then

        PO_MESSAGE_S.APP_ERROR(error_name => 'PO_ALL_TRACE_ERROR',
                               token1 => 'FILE',
                               value1 => 'PO_ONLINE_REPORT',
                               token2 => 'ERR_NUMBER',
                               value2 => '010',
                               token3 => 'SUBROUTINE',
                               value3 => 'INSERT_MANY()');
        return(FALSE);

      end if;

    end if;

    return(TRUE);


  EXCEPTION

    WHEN OTHERS THEN

      PO_MESSAGE_S.SQL_ERROR(routine => 'PO_ONLINE_REPORT',
                             location => '015',
                             error_code => SQLCODE);

      return(FALSE);

  END insert_many;

/* ----------------------------------------------------------------------- */
/*                                                                         */
/*   Determines how Single Inserts into the Online Reporting table are     */
/*   to be handled                                                         */
/*                                                                         */
/* ----------------------------------------------------------------------- */

  -- Parameters :

  -- p_linenum : Line ID

  -- p_shipnum : Shipment ID

  -- p_distnum : Distribution ID

  -- p_message : Message Name

  -- p_reportid : Online Reporting ID

  -- p_sequence : Sequence

  -- p_return_code : Return Code

  FUNCTION insert_single(p_linenum     IN     NUMBER,
                         p_shipnum     IN     NUMBER,
                         p_distnum     IN     NUMBER,
                         p_message     IN     VARCHAR2,
                         p_reportid    IN     NUMBER,
                         p_sequence    IN     NUMBER,
                         p_return_code IN OUT NOCOPY VARCHAR2) RETURN BOOLEAN IS

    l_userid     po_lines.last_updated_by%TYPE;
    l_loginid    po_lines.last_update_login%TYPE;
    l_textline   po_online_report_text.text_line%TYPE;

    l_shipmsg    VARCHAR2(25);
    l_linemsg    VARCHAR2(25);
    l_tokennam1  VARCHAR2(10);
    l_tokennam2  VARCHAR2(10);
    l_tokennam3  VARCHAR2(10);
    l_tokennam4  VARCHAR2(10);

  BEGIN

    g_dbug := 'Starting Online Insert' || g_delim;


    -- Get User ID and Login ID

    l_userid := FND_GLOBAL.USER_ID;

    if l_userid = -1 then

      PO_MESSAGE_S.APP_ERROR(error_name => 'PO_ALL_TRACE_ERROR_WITH_MSG',
                             token1 => 'FILE',
                             value1 => 'PO_ONLINE_REPORT',
                             token2 => 'ERR_NUMBER',
                             value2 => '020',
                             token3 => 'SUBROUTINE',
                             value3 => 'INSERT_SINGLE()',
                             token4 => 'ERROR_MSG',
                             value4 => 'CANNOT FIND USER ID');
      return(FALSE);

    end if;

-- FRKHAN: BUG 747290 Get concurrent login id
-- if there is one else get login id

    if (FND_GLOBAL.CONC_LOGIN_ID >= 0) then
       l_loginid := FND_GLOBAL.CONC_LOGIN_ID;
    else
       l_loginid := FND_GLOBAL.LOGIN_ID;
    end if;

    if l_loginid = -1 then

      PO_MESSAGE_S.APP_ERROR(error_name => 'PO_ALL_TRACE_ERROR_WITH_MSG',
                             token1 => 'FILE',
                             value1 => 'PO_ONLINE_REPORT',
                             token2 => 'ERR_NUMBER',
                             value2 => '025',
                             token3 => 'SUBROUTINE',
                             value3 => 'INSERT_SINGLE()',
                             token4 => 'ERROR_MSG',
                             value4 => 'CANNOT FIND LAST LOGIN ID');
      return(FALSE);

    end if;


    -- Get Message from the Message Dictionary

    l_textline := FND_MESSAGE.GET_STRING('PO', p_message);


    -- Setup Headings for the Text Line that is displayed. Headings include
    -- Line #, Shipment #, if they are passed in. Perform Token Substitution
    -- for the Line and Shipment #s

    if ((p_linenum <> 0) and
        (p_shipnum <> 0)) then

      l_shipmsg := substr(FND_MESSAGE.GET_STRING('PO', 'PO_ZMVOR_SHIPMENT'), 1,
                          25);

      l_linemsg := substr(FND_MESSAGE.GET_STRING('PO', 'PO_ZMVOR_LINE'), 1, 25);

    end if;

    l_tokennam1 := '&' || 'LINE';
    l_tokennam2 := '&' || 'LINE1';
    l_tokennam3 := '&' || 'SHIP';
    l_tokennam4 := '&' || 'SHIP1';

    l_textline := replace(l_textline, l_tokennam1, l_linemsg);
    l_textline := replace(l_textline, l_tokennam2, p_linenum);
    l_textline := replace(l_textline, l_tokennam3, l_shipmsg);
    l_textline := replace(l_textline, l_tokennam4, p_shipnum);

    insert into po_online_report_text(online_report_id,
                                      last_update_login,
                                      last_updated_by,
                                      last_update_date,
                                      created_by,
                                      creation_date,
                                      line_num,
                                      shipment_num,
                                      distribution_num,
                                      sequence,
                                      text_line)
                              values (p_reportid,
                                      l_loginid,
                                      l_userid,
                                      sysdate,
                                      l_userid,
                                      sysdate,
                                      p_linenum,
                                      p_shipnum,
                                      p_distnum,
                                      p_sequence,
                                      l_textline);

    if not SQL%NOTFOUND then

      g_dbug := g_dbug ||
                'Inserted into Online Report table' || g_delim;

      if nvl(p_return_code, 'X') <> 'SUBMISSION_FAILED' then
        p_return_code := 'SUBMISSION_FAILED';
      end if;

    end if;

    return(TRUE);


  EXCEPTION

    WHEN OTHERS THEN

      PO_MESSAGE_S.SQL_ERROR(routine => 'PO_ONLINE_REPORT',
                             location => '030',
                             error_code => SQLCODE);

      return(FALSE);

  END insert_single;

/* ----------------------------------------------------------------------- */

  -- Insert into the Online Reporting table using Array Fetch

  FUNCTION online_finsert(p_docid       IN     NUMBER,
                          p_doctyp      IN     VARCHAR2,
                          p_docsubtyp   IN     VARCHAR2,
                          p_lineid      IN     NUMBER,
                          p_shipid      IN     NUMBER,
                          p_message     IN     VARCHAR2,
                          p_reportid    IN     NUMBER,
                          p_numtokens   IN     NUMBER,
                          p_sqlstring   IN     VARCHAR2,
                          p_sequence    IN     NUMBER,
                          p_action_date IN     DATE,
                          p_return_code IN OUT NOCOPY VARCHAR2) RETURN BOOLEAN IS

    l_docid      po_lines.line_num%TYPE;
    l_linenum    po_lines.line_num%TYPE;
    l_shipnum    po_line_locations.shipment_num%TYPE;
    l_distnum    po_distributions.distribution_num%TYPE;
    l_tokenval1  po_distributions.quantity_delivered%TYPE;
    l_tokenval2  po_line_locations.quantity%TYPE;
    l_userid     po_lines.last_updated_by%TYPE;
    l_loginid    po_lines.last_update_login%TYPE;
    l_textline   po_online_report_text.text_line%TYPE;

    l_tokennam1  VARCHAR2(10);
    l_tokennam2  VARCHAR2(10);
    l_message    VARCHAR2(2000);
    l_distmsg    VARCHAR2(25);
    l_shipmsg    VARCHAR2(25);
    l_linemsg    VARCHAR2(25);

    cur_insert   INTEGER;
    num_insert   INTEGER;

    l_found      BOOLEAN := FALSE;

  BEGIN

    if p_shipid <> 0 then

      l_docid := p_shipid;

    elsif p_lineid <> 0 then

      l_docid := p_lineid;

    else

      l_docid := p_docid;

    end if;

    g_dbug := g_dbug ||
              'Doc ID:' || l_docid || g_delim;


    -- Get User ID and Login ID

    l_userid := FND_GLOBAL.USER_ID;

    if l_userid = -1 then

      PO_MESSAGE_S.APP_ERROR(error_name => 'PO_ALL_TRACE_ERROR_WITH_MSG',
                             token1 => 'FILE',
                             value1 => 'PO_ONLINE_REPORT',
                             token2 => 'ERR_NUMBER',
                             value2 => '035',
                             token3 => 'SUBROUTINE',
                             value3 => 'ONLINE_FINSERT()',
                             token4 => 'ERROR_MSG',
                             value4 => 'CANNOT FIND USER ID');
      return(FALSE);

    end if;

-- FRKHAN: BUG 747290 Get concurrent login id
-- if there is one else get login id

    if (FND_GLOBAL.CONC_LOGIN_ID >= 0) then
       l_loginid := FND_GLOBAL.CONC_LOGIN_ID;
    else
       l_loginid := FND_GLOBAL.LOGIN_ID;
    end if;

    if l_loginid = -1 then

      PO_MESSAGE_S.APP_ERROR(error_name => 'PO_ALL_TRACE_ERROR_WITH_MSG',
                             token1 => 'FILE',
                             value1 => 'PO_ONLINE_REPORT',
                             token2 => 'ERR_NUMBER',
                             value2 => '040',
                             token3 => 'SUBROUTINE',
                             value3 => 'ONLINE_FINSERT()',
                             token4 => 'ERROR_MSG',
                             value4 => 'CANNOT FIND LAST LOGIN ID');
      return(FALSE);

    end if;


    -- Setup a portion of the displayed text line

    l_distmsg := substr(FND_MESSAGE.GET_STRING('PO', 'PO_ZMVOR_DISTRIBUTION'),
                        1, 25);

    l_shipmsg := substr(FND_MESSAGE.GET_STRING('PO', 'PO_ZMVOR_SHIPMENT'),
                        1, 25);

    l_linemsg := substr(FND_MESSAGE.GET_STRING('PO', 'PO_ZMVOR_LINE'), 1, 25);

    l_message := FND_MESSAGE.GET_STRING('PO', p_message);

    l_tokennam1 := '&' || 'QTY1';
    l_tokennam2 := '&' || 'QTY2';

    -- Setup the SQL Statement

    cur_insert := dbms_sql.open_cursor;
    dbms_sql.parse(cur_insert, p_sqlstring, dbms_sql.v7);

    dbms_sql.bind_variable(cur_insert, 'docid', l_docid);

    dbms_sql.define_column(cur_insert, 1, l_linenum);
    dbms_sql.define_column(cur_insert, 2, l_shipnum);
    dbms_sql.define_column(cur_insert, 3, l_distnum);
    dbms_sql.define_column(cur_insert, 4, l_tokenval1);
    dbms_sql.define_column(cur_insert, 5, l_tokenval2);

    num_insert := dbms_sql.execute(cur_insert);

    loop

      if dbms_sql.fetch_rows(cur_insert) > 0 then

        dbms_sql.column_value(cur_insert, 1, l_linenum);
        dbms_sql.column_value(cur_insert, 2, l_shipnum);
        dbms_sql.column_value(cur_insert, 3, l_distnum);
        dbms_sql.column_value(cur_insert, 4, l_tokenval1);
        dbms_sql.column_value(cur_insert, 5, l_tokenval2);

        l_message := replace(l_message, l_tokennam1, l_tokenval1);
        l_message := replace(l_message, l_tokennam2, l_tokenval2);

        if l_distnum >= 1 then

          if p_doctyp <> 'RELEASE' then
            l_textline := l_linemsg || l_linenum;
          end if;

          l_textline := l_textline ||
                        l_shipmsg || l_shipnum ||
                        l_distmsg || l_distnum || l_message;

        elsif l_shipnum >= 1 then

          if p_doctyp <> 'RELEASE' then
            l_textline := l_linemsg || l_linenum;
          end if;

          l_textline := l_textline ||
                        l_shipmsg || l_shipnum || l_message;

        elsif l_linenum >= 1 then
          l_textline := l_linemsg || l_linenum || l_message;
        else
          l_textline := l_message;
        end if;

        insert into po_online_report_text
                   (online_report_id,
                    last_update_login,
                    last_updated_by,
                    last_update_date,
                    created_by,
                    creation_date,
                    line_num,
                    shipment_num,
                    distribution_num,
                    sequence,
                    text_line)
            values (p_reportid,
                    l_loginid,
                    l_userid,
                    sysdate,
                    l_userid,
                    sysdate,
                    l_linenum,
                    l_shipnum,
                    l_distnum,
                    p_sequence,
                    l_textline);

        l_found := TRUE;

      else
        exit;
      end if;

    end loop;

    dbms_sql.close_cursor(cur_insert);

    if l_found then

      g_dbug := g_dbug ||
                'Inserted into Online Report table' || g_delim;

      if nvl(p_return_code, 'X') <> 'SUBMISSION_FAILED' then
        p_return_code := 'SUBMISSION_FAILED';
      end if;

    end if;

    return(TRUE);


  EXCEPTION

    WHEN OTHERS THEN

      if dbms_sql.is_open(cur_insert) then
        dbms_sql.close_cursor(cur_insert);
      end if;

      PO_MESSAGE_S.SQL_ERROR(routine => 'PO_ONLINE_REPORT',
                             location => '045',
                             error_code => SQLCODE);

      return(FALSE);

  END online_finsert;

/* ----------------------------------------------------------------------- */

  -- Insert into the Online Reporting table using Subquery

  FUNCTION online_sinsert(p_docid       IN     NUMBER,
                          p_doctyp      IN     VARCHAR2,
                          p_docsubtyp   IN     VARCHAR2,
                          p_lineid      IN     NUMBER,
                          p_shipid      IN     NUMBER,
                          p_message     IN     VARCHAR2,
                          p_reportid    IN     NUMBER,
                          p_numtokens   IN     NUMBER,
                          p_sqlstring   IN     VARCHAR2,
                          p_sequence    IN     NUMBER,
                          p_action_date IN     DATE,
                          p_return_code IN OUT NOCOPY VARCHAR2) RETURN BOOLEAN IS

    l_docid     po_lines.line_num%TYPE;
    l_userid    po_lines.last_updated_by%TYPE;
    l_loginid   po_lines.last_update_login%TYPE;
    l_textline  po_online_report_text.text_line%TYPE;

    l_distmsg   VARCHAR2(25);
    l_shipmsg   VARCHAR2(25);
    l_linemsg   VARCHAR2(25);

    sql_insert  VARCHAR2(1200);
    cur_insert  INTEGER;
    num_insert  INTEGER;

    l_found     BOOLEAN := FALSE;

  BEGIN

    if p_shipid <> 0 then

      l_docid := p_shipid;

    elsif p_lineid <> 0 then

      l_docid := p_lineid;

    else

      l_docid := p_docid;

    end if;

    g_dbug := g_dbug ||
              'Doc ID:' || l_docid || g_delim;


    -- Get User ID and Login ID

    l_userid := FND_GLOBAL.USER_ID;

    if l_userid = -1 then

      PO_MESSAGE_S.APP_ERROR(error_name => 'PO_ALL_TRACE_ERROR_WITH_MSG',
                             token1 => 'FILE',
                             value1 => 'PO_ONLINE_REPORT',
                             token2 => 'ERR_NUMBER',
                             value2 => '050',
                             token3 => 'SUBROUTINE',
                             value3 => 'ONLINE_SINSERT()',
                             token4 => 'ERROR_MSG',
                             value4 => 'CANNOT FIND USER ID');
      return(FALSE);

    end if;

-- FRKHAN: BUG 747290 Get concurrent login id
-- if there is one else get login id

    if (FND_GLOBAL.CONC_LOGIN_ID >= 0) then
       l_loginid := FND_GLOBAL.CONC_LOGIN_ID;
    else
       l_loginid := FND_GLOBAL.LOGIN_ID;
    end if;

    if l_loginid = -1 then

      PO_MESSAGE_S.APP_ERROR(error_name => 'PO_ALL_TRACE_ERROR_WITH_MSG',
                             token1 => 'FILE',
                             value1 => 'PO_ONLINE_REPORT',
                             token2 => 'ERR_NUMBER',
                             value2 => '055',
                             token3 => 'SUBROUTINE',
                             value3 => 'ONLINE_SINSERT()',
                             token4 => 'ERROR_MSG',
                             value4 => 'CANNOT FIND LAST LOGIN ID');
      return(FALSE);

    end if;


    -- Setup a portion of the displayed text line

    l_distmsg := substr(FND_MESSAGE.GET_STRING('PO', 'PO_ZMVOR_DISTRIBUTION'),
                        1, 25);

    l_shipmsg := substr(FND_MESSAGE.GET_STRING('PO', 'PO_ZMVOR_SHIPMENT'),
                        1, 25);

    l_linemsg := substr(FND_MESSAGE.GET_STRING('PO', 'PO_ZMVOR_LINE'), 1, 25);

    l_textline := FND_MESSAGE.GET_STRING('PO', p_message);


    -- Setup the SQL Statement

    sql_insert := 'insert into po_online_report_text ' ||
                         '(online_report_id, ' ||
                          'last_update_login, ' ||
                          'last_updated_by, ' ||
                          'last_update_date, ' ||
                          'created_by, ' ||
                          'creation_date, ' ||
                          'line_num, ' ||
                          'shipment_num, ' ||
                          'distribution_num, ' ||
                          'sequence, ' ||
                          'text_line) ';

    sql_insert := sql_insert ||
                  p_sqlstring;

    cur_insert := dbms_sql.open_cursor;
    dbms_sql.parse(cur_insert, sql_insert, dbms_sql.v7);

    dbms_sql.bind_variable(cur_insert, 'online_report_id', p_reportid);
    dbms_sql.bind_variable(cur_insert, 'last_update_login', l_loginid);
    dbms_sql.bind_variable(cur_insert, 'last_user_id', l_userid);
    dbms_sql.bind_variable(cur_insert, 'sequence', p_sequence);
    dbms_sql.bind_variable(cur_insert, 'msg_text', l_textline);
    dbms_sql.bind_variable(cur_insert, 'docid', l_docid);

    -- Conditional Bind Variables

    if INSTR(sql_insert, ':line_heading', 1) > 0 then
      dbms_sql.bind_variable(cur_insert, 'line_heading', l_linemsg);
    end if;

    if INSTR(sql_insert, ':ship_heading', 1) > 0 then
      dbms_sql.bind_variable(cur_insert, 'ship_heading', l_shipmsg);
    end if;

    if INSTR(sql_insert, ':dist_heading', 1) > 0 then
      dbms_sql.bind_variable(cur_insert, 'dist_heading', l_distmsg);
    end if;

    if INSTR(sql_insert, ':action_date', 1) > 0 then
      dbms_sql.bind_variable(cur_insert, 'action_date', p_action_date);
    end if;

    num_insert := dbms_sql.execute(cur_insert);

    dbms_sql.close_cursor(cur_insert);

    if num_insert <> 0 then

      g_dbug := g_dbug ||
                'Inserted ' || num_insert || ' Records from online_sinsert' ||
                g_delim;

      if nvl(p_return_code, 'X') <> 'SUBMISSION_FAILED' then
        p_return_code := 'SUBMISSION_FAILED';
      end if;

    end if;

    return(TRUE);


  EXCEPTION

    WHEN OTHERS THEN

      if dbms_sql.is_open(cur_insert) then
        dbms_sql.close_cursor(cur_insert);
      end if;

      PO_MESSAGE_S.SQL_ERROR(routine => 'PO_ONLINE_REPORT',
                             location => '060',
                             error_code => SQLCODE);

      return(FALSE);

  END online_sinsert;

/* ----------------------------------------------------------------------- */

  -- Get Debug Information

  -- This Module is used to retrieve Debug Information for the Routines. It
  -- prints Debug Information when run as a Batch Process from SQL*Plus. For
  -- the Debug Information to be printed on the Screen, the SQL*Plus parameter
  -- 'Serveroutput' should be set to 'ON'

  FUNCTION get_debug RETURN VARCHAR2 IS

  BEGIN

    return(g_dbug);

  END get_debug;

/* ----------------------------------------------------------------------- */

END PO_ONLINE_REPORT;


/
