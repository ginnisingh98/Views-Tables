--------------------------------------------------------
--  DDL for Package Body PO_FUNDS_CHECKER
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PO_FUNDS_CHECKER" AS
/* $Header: POXPOFCB.pls 115.8 2003/03/06 10:07:11 krsethur ship $ */

  -- Types :
  --

  -- Constants :
  -- This is used as a delimiter in the Debug Info String

  g_delim                   CONSTANT VARCHAR2(1) := '
';


  -- Private Global Variables :
  --

  -- Action

  g_action                  VARCHAR2(25);

  -- Packet ID

  g_packetid                gl_bc_packets.packet_id%TYPE;

  -- Funds Check Return Code

  g_return_code             VARCHAR2(1);

  -- Concurrent Processing of Funds Checker ?

  g_conc_flag               VARCHAR2(1);

  -- Set of Books ID

  g_sobid                   financials_system_parameters.set_of_books_id%TYPE;

  -- PO Mode

  g_pomode                  VARCHAR2(15);

  -- Funds Check Mode

  g_fcmode                  VARCHAR2(1);

  -- Funds Check Level

  g_fclevel                 VARCHAR2(15);

  -- Partial Reservation Allowed ?

  g_partial_resv_flag       VARCHAR2(1);

  -- Document Type

  g_doctyp                  VARCHAR2(25);

  -- Document Subtype

  g_docsubtyp               VARCHAR2(25);

  -- Header ID

  g_docid                   NUMBER;

  -- Line ID

  g_lineid                  NUMBER;

  -- Shipment ID

  g_shipid                  NUMBER;

  -- Dist ID

  g_distid                  NUMBER;

  -- Override Period

  g_override_period         VARCHAR2(25);

  -- Recreate Demand

  g_recreate_demand         VARCHAR2(1);

  -- User ID

  g_userid                  NUMBER;

  -- Login ID

  g_loginid                 NUMBER;

  -- SQL String for Inserting into Funds Checker Queue

  g_sql_insert              VARCHAR2(10000);

  -- Debug String
  -- FRKHAN bug 941171 9/14/99
  x_max_length          CONSTANT NUMBER := 32760;
  g_dbug                    VARCHAR2(32767) := null;


/* ----------------------------------------------------------------------- */
/*                                                                         */
/*                      Private Function Definition                        */
/*                                                                         */
/* ----------------------------------------------------------------------- */

  FUNCTION po_fc_init RETURN BOOLEAN;


  FUNCTION po_fc_sel(p_goodstmt IN OUT NOCOPY BOOLEAN) RETURN BOOLEAN;


  FUNCTION po_fc_selreq RETURN BOOLEAN;


  FUNCTION po_fc_selpo RETURN BOOLEAN;


  FUNCTION po_fc_selblnkrel RETURN BOOLEAN;


  FUNCTION po_fc_selschrel RETURN BOOLEAN;


  FUNCTION po_fc_run(p_packetid IN OUT NOCOPY NUMBER) RETURN BOOLEAN;


  FUNCTION po_rollup_enc RETURN BOOLEAN;


  FUNCTION po_rollup_req RETURN BOOLEAN;


  FUNCTION po_rollup_po RETURN BOOLEAN;


  FUNCTION po_rollup_blnkrel RETURN BOOLEAN;


  FUNCTION po_rollup_schrel RETURN BOOLEAN;


  FUNCTION po_fc_dist RETURN BOOLEAN;


  FUNCTION po_err_insert RETURN BOOLEAN;

/* ----------------------------------------------------------------------- */
/*                                                                         */
/*   Funds Control Action on an Entity                                     */
/*                                                                         */
/*   If Funds Check succeeds, update the Source Distributions; otherwise   */
/*   log errors in the Online Reporting table and purge the packet         */
/*                                                                         */
/* ----------------------------------------------------------------------- */

  -- Parameters :

  -- p_docid : Header ID

  -- p_doctyp : Document Type

  -- p_docsubtyp : Document Subtype

  -- p_lineid : Line ID

  -- p_shipid : Shipment ID

  -- p_distid : Distribution ID

  -- p_action : Action

  -- p_override_period : Override Period

  -- p_recreate_demand : Recreate Demand ?

  -- p_conc_flag : Concurrent Processing of Funds Checker

  -- p_return_code : Funds Checker Return Code

  FUNCTION po_funds_control(p_docid           IN     NUMBER,
                            p_doctyp          IN     VARCHAR2,
                            p_docsubtyp       IN     VARCHAR2,
                            p_lineid          IN     NUMBER,
                            p_shipid          IN     NUMBER,
                            p_distid          IN     NUMBER DEFAULT 0,
                            p_action          IN     VARCHAR2,
                            p_override_period IN     VARCHAR2 DEFAULT NULL,
                            p_recreate_demand IN     VARCHAR2 DEFAULT 'N',
                            p_conc_flag       IN     VARCHAR2 DEFAULT 'N',
                            p_return_code     IN OUT NOCOPY VARCHAR2) RETURN BOOLEAN IS

    l_fc_ok  BOOLEAN := FALSE;
    l_dummy  VARCHAR2(1);
    l_dummy2 VARCHAR2(1);
    l_min_acct_unit NUMBER;        -- Bug#2310026
    l_precision NUMBER;            -- Bug#2310026

    cursor pkt_po(packet_id NUMBER) is
      select distinct 'Y'
        from gl_bc_packets
       where exists
            (select 'Y'
               from gl_bc_packets
              where reference1 = 'PO'
                and reference5 is not null
                and packet_id = packet_id);

    cursor req_enc is
      select 'Y'
        from financials_system_parameters
       where req_encumbrance_flag = 'Y';

  BEGIN

    -- dbms_output.put_line('in funds control');
    -- FRKHAN BUG 941171 9/14/99
    IF LENGTH (g_dbug) < x_max_length THEN
       g_dbug := g_dbug ||
             'Starting PO Funds Checker:' || g_delim ||
             'Hdr:' || p_docid || g_delim ||
             'Type:' || p_doctyp || g_delim ||
             'Subtype:' || p_docsubtyp || g_delim ||
             'Line:' || p_lineid || g_delim ||
             'Ship:' || p_shipid || g_delim ||
             'Dist:' || p_distid || g_delim ||
             'Action:' || p_action || g_delim ||
             'Override Period:' || p_override_period || g_delim ||
             'Recreate Demand:' || p_recreate_demand || g_delim ||
             'Conc:' || p_conc_flag || g_delim;
    END IF;

    -- Setup Global Variables

    g_docid := p_docid;
    g_doctyp := p_doctyp;
    g_docsubtyp := p_docsubtyp;
    g_lineid := p_lineid;
    g_shipid := p_shipid;
    g_distid := p_distid;
    g_action := p_action;
    g_override_period := p_override_period;
    g_recreate_demand := p_recreate_demand;
    g_conc_flag := p_conc_flag;

    -- Check whether it is OK to invoke Funds Checker

    -- dbms_output.put_line('before po_fc_ok');

    if not po_fc_ok(p_doctyp => p_doctyp,
                    p_lineid => p_lineid,
                    p_shipid => p_shipid,
                    p_distid => p_distid,
                    p_action => p_action,
                    p_fc_ok => l_fc_ok) then

      -- dbms_output.put_line('funds control not ok');

      PO_MESSAGE_S.APP_ERROR(error_name => 'PO_ALL_TRACE_ERROR',
                             token1 => 'FILE',
                             value1 => 'PO_FUNDS_CHECKER',
                             token2 => 'ERR_NUMBER',
                             value2 => '005',
                             token3 => 'SUBROUTINE',
                             value3 => 'PO_FUNDS_CONTROL()');
      return(FALSE);

    end if;

    if not l_fc_ok then
      return(TRUE);
      -- dbms_output.put_line('not l_fc_ok');

    end if;


    -- Initialize for Funds Check

    -- dbms_output.put_line('init funds checker');

    if not po_fc_init then

      PO_MESSAGE_S.APP_ERROR(error_name => 'PO_ALL_TRACE_ERROR',
                             token1 => 'FILE',
                             value1 => 'PO_FUNDS_CHECKER',
                             token2 => 'ERR_NUMBER',
                             value2 => '010',
                             token3 => 'SUBROUTINE',
                             value3 => 'PO_FUNDS_CONTROL()');
      return(FALSE);

    end if;

    -- dbms_output.put_line('insert into gl_bc_packtets');

    -- Insert Records into gl_bc_packets

    if not po_fc_ins(p_docid => p_docid,
                     p_doctyp => g_doctyp,
                     p_docsubtyp => g_docsubtyp,
                     p_lineid => g_lineid,
                     p_shipid => g_shipid,
                     p_distid => g_distid,
                     p_action => g_action,
                     p_override_period => g_override_period,
                     p_recreate_demand => g_recreate_demand,
                     p_packetid => g_packetid) then

      PO_MESSAGE_S.APP_ERROR(error_name => 'PO_ALL_TRACE_ERROR',
                             token1 => 'FILE',
                             value1 => 'PO_FUNDS_CHECKER',
                             token2 => 'ERR_NUMBER',
                             value2 => '015',
                             token3 => 'SUBROUTINE',
                             value3 => 'PO_FUNDS_CONTROL()');

      -- dbms_output.put_line('insert failed into bc packets');

      return(FALSE);


    end if;

/* Bug#2310026 : Following logic will round the entered_dr, entered_cr,
accounted_dr, accounted_cr to the functional currency
precision/minimum accountable unit, by updating these fields
for all the records inserted in the previous step using the
packet_id. */

    SELECT FC.MINIMUM_ACCOUNTABLE_UNIT, FC.PRECISION
             INTO    l_min_acct_unit , l_precision
             FROM    GL_SETS_OF_BOOKS GLSOB,
                     FINANCIALS_SYSTEM_PARAMETERS FSP,
                     FND_CURRENCIES FC
             WHERE   GLSOB.set_of_books_id = FSP.set_of_books_id
             AND     FC.currency_code = GLSOB.currency_code;

IF (l_min_acct_unit is not null) THEN
        UPDATE GL_BC_PACKETS
        SET ENTERED_DR = ROUND(ENTERED_DR/l_min_acct_unit) * l_min_acct_unit ,
            ENTERED_CR = ROUND(ENTERED_CR/l_min_acct_unit) * l_min_acct_unit,
            ACCOUNTED_DR = ROUND(ACCOUNTED_DR/l_min_acct_unit ) * l_min_acct_unit ,
            ACCOUNTED_CR = ROUND(ACCOUNTED_CR/l_min_acct_unit) * l_min_acct_unit
        WHERE PACKET_ID = g_packetid;
ELSE
        UPDATE GL_BC_PACKETS
        SET ENTERED_DR = ROUND(ENTERED_DR,l_precision),
            ENTERED_CR = ROUND(ENTERED_CR,l_precision),
            ACCOUNTED_DR = ROUND(ACCOUNTED_DR,l_precision),
            ACCOUNTED_CR = ROUND(ACCOUNTED_CR,l_precision)
        WHERE PACKET_ID = g_packetid;
END IF;



    -- FRKHAN bug 941171
    IF LENGTH (g_dbug) < x_max_length THEN
       g_dbug := g_dbug ||
             'Packet:' || g_packetid || g_delim;
    END IF;

    -- If Packet includes a PO with backing requisition, Partial Reservation
    -- should not be allowed

    open pkt_po(g_packetid);

    fetch pkt_po
     into l_dummy;

    close pkt_po;

    open req_enc;

    fetch req_enc
     into l_dummy2;

    close req_enc;

    if ((l_dummy = 'Y') and
        (l_dummy2 = 'Y')) then
      g_partial_resv_flag := 'N';
    end if;


    -- Call Funds Checker
    -- dbms_output.put_line('call funds checker');


    if not GL_FUNDS_CHECKER_PKG.GLXFCK(p_sobid => g_sobid,
                                       p_packetid => g_packetid,
                                       p_mode => g_fcmode,
                                       p_partial_resv_flag => g_partial_resv_flag,
                                       p_conc_flag => g_conc_flag,
                                       p_return_code => g_return_code) then

      GL_FUNDS_CHECKER_PKG.GLXFPP(p_packetid => g_packetid);

      PO_MESSAGE_S.APP_ERROR(error_name => 'PO_ALL_TRACE_ERROR',
                             token1 => 'FILE',
                             value1 => 'PO_FUNDS_CHECKER',
                             token2 => 'ERR_NUMBER',
                             value2 => '020',
                             token3 => 'SUBROUTINE',
                             value3 => 'PO_FUNDS_CONTROL()');
      return(FALSE);

    end if;


    -- Check Return Code

    if ((g_return_code in ('A', 'S')) and
        (g_fcmode in ('R', 'A'))) then

      if not po_rollup_enc then

        PO_MESSAGE_S.APP_ERROR(error_name => 'PO_ALL_TRACE_ERROR',
                               token1 => 'FILE',
                               value1 => 'PO_FUNDS_CHECKER',
                               token2 => 'ERR_NUMBER',
                               value2 => '025',
                               token3 => 'SUBROUTINE',
                               value3 => 'PO_FUNDS_CONTROL()');
        return(FALSE);

      end if;

    end if;

    if ((g_return_code = 'P') and
        (g_fcmode in ('R', 'A'))) then

      if not po_rollup_enc then

        PO_MESSAGE_S.APP_ERROR(error_name => 'PO_ALL_TRACE_ERROR',
                               token1 => 'FILE',
                               value1 => 'PO_FUNDS_CHECKER',
                               token2 => 'ERR_NUMBER',
                               value2 => '030',
                               token3 => 'SUBROUTINE',
                               value3 => 'PO_FUNDS_CONTROL()');
        return(FALSE);

      end if;


      -- Insert into Errors table

      if not po_err_insert then

        PO_MESSAGE_S.APP_ERROR(error_name => 'PO_ALL_TRACE_ERROR',
                               token1 => 'FILE',
                               value1 => 'PO_FUNDS_CHECKER',
                               token2 => 'ERR_NUMBER',
                               value2 => '035',
                               token3 => 'SUBROUTINE',
                               value3 => 'PO_FUNDS_CONTROL()');
        return(FALSE);

      end if;

    end if;

    if g_return_code in ('T', 'F') then

      -- Insert into Errors table

      if not po_err_insert then

        PO_MESSAGE_S.APP_ERROR(error_name => 'PO_ALL_TRACE_ERROR',
                               token1 => 'FILE',
                               value1 => 'PO_FUNDS_CHECKER',
                               token2 => 'ERR_NUMBER',
                               value2 => '040',
                               token3 => 'SUBROUTINE',
                               value3 => 'PO_FUNDS_CONTROL()');
        return(FALSE);

      end if;

      GL_FUNDS_CHECKER_PKG.GLXFPP(p_packetid => g_packetid);
      return(TRUE);

    end if;

    return(TRUE);


  EXCEPTION

    WHEN OTHERS THEN

      if pkt_po%ISOPEN then
        close pkt_po;
      end if;

      if req_enc%ISOPEN then
        close req_enc;
      end if;

      PO_MESSAGE_S.SQL_ERROR(routine => 'PO_FUNDS_CHECKER',
                             location => '045',
                             error_code => SQLCODE);

      return(FALSE);

  END po_funds_control;

/* ----------------------------------------------------------------------- */
/*                                                                         */
/*   Check if it is OK to invoke Funds Checker                             */
/*                                                                         */
/* ----------------------------------------------------------------------- */

  -- Parameters :

  -- p_doctyp : Document Type

  -- p_lineid : Line ID

  -- p_shipid : Shipment ID

  -- p_distid : Distribution ID

  -- p_action : Action

  -- p_fc_ok : OK to invoke Funds Checker ?

  FUNCTION po_fc_ok(p_doctyp IN     VARCHAR2,
                    p_lineid IN     NUMBER,
                    p_shipid IN     NUMBER,
                    p_distid IN     NUMBER DEFAULT 0,
                    p_action IN     VARCHAR2,
                    p_fc_ok  IN OUT NOCOPY BOOLEAN) RETURN BOOLEAN IS

  BEGIN

    p_fc_ok := TRUE;

    if p_action not in ('RESERVE', 'APPROVE AND RESERVE', 'CANCEL',
                        'FINALLY CLOSE', 'CHECK FUNDS', 'RETURN', 'REJECT',
                        'UNENCUMBER REQ', 'LIQUIDATE REQ') then

      -- dbms_output.put_line('paction failed');

      p_fc_ok := FALSE;
      return(TRUE);

    end if;


    -- Check for Action if Distribution Num is entered

    if ((p_distid <> 0) and
        (p_action not in ('CHECK FUNDS', 'LIQUIDATE REQ'))) then

      -- dbms_output.put_line('second check failed');

      p_fc_ok := FALSE;
      return(TRUE);

    end if;


    -- Check for Action if Line Num is entered

    if (((p_lineid <> 0) or (p_shipid <> 0))and
         (p_action in ('RESERVE', 'RETURN', 'REJECT',
                       'APPROVE AND RESERVE'))) then

      -- dbms_output.put_line('3 check failed');

      p_fc_ok := FALSE;
      return(TRUE);

    end if;


    -- Check for Requisitions

    if ((p_action = 'RETURN') and
        (p_doctyp <> 'REQUISITION')) then

      -- dbms_output.put_line('4 check failed');
      p_fc_ok := FALSE;
      return(TRUE);

    end if;

    -- dbms_output.put_line('return true from po_fc_ok');

    return(TRUE);

  END po_fc_ok;

/* ----------------------------------------------------------------------- */
/*                                                                         */
/*   Insert into the Funds Checker queue                                   */
/*                                                                         */
/* ----------------------------------------------------------------------- */

  -- Parameters :

  -- p_doctyp : Header Type

  -- p_docsubtyp : Header Subtype

  -- p_lineid : Line ID

  -- p_shipid : Shipment ID

  -- p_distid : Distribution ID

  -- p_action : Action

  -- p_override_period : Override Period

  -- p_recreate_demand : Recreate Demand ?

  -- p_packetid : Funds Checker Queue Packet ID

  FUNCTION po_fc_ins(p_docid           IN     NUMBER,
                     p_doctyp          IN     VARCHAR2,
                     p_docsubtyp       IN     VARCHAR2,
                     p_lineid          IN     NUMBER,
                     p_shipid          IN     NUMBER,
                     p_distid          IN     NUMBER DEFAULT 0,
                     p_action          IN     VARCHAR2,
                     p_override_period IN     VARCHAR2,
                     p_recreate_demand IN     VARCHAR2,
                     p_packetid        IN OUT NOCOPY NUMBER) RETURN BOOLEAN IS

    l_goodstmt  BOOLEAN := FALSE;

  BEGIN

    -- Setup Global Variables

    if g_docid is null then
      g_docid := p_docid;
    end if;

    if g_doctyp is null then
      g_doctyp := p_doctyp;
    end if;

    if g_docsubtyp is null then
      g_docsubtyp := p_docsubtyp;
    end if;

    if g_lineid is null then
      g_lineid := p_lineid;
    end if;

    if g_shipid is null then
      g_shipid := p_shipid;
    end if;

    if g_distid is null then
      g_distid := p_distid;
    end if;

    if g_action is null then
      g_action := p_action;
    end if;

    if g_override_period is null then
      g_override_period := p_override_period;
    end if;

    if g_recreate_demand is null then
      g_recreate_demand := p_recreate_demand;
    end if;


    -- Insert Clause
    -- dbms_output.put_line('before setting up insert');

    g_sql_insert := 'insert into gl_bc_packets ' ||
                               '(packet_id, ' ||
                                'set_of_books_id, ' ||
                                'je_source_name, ' ||
                                'je_category_name, ' ||
                                'code_combination_id, ' ||
                                'actual_flag, ' ||
                                'period_name, ' ||
                                'period_year, ' ||
                                'period_num, ' ||
                                'quarter_num, ' ||
                                'currency_code, ' ||
                                'status_code, ' ||
                                'last_update_date, ' ||
                                'last_updated_by, ' ||
                                'budget_version_id, ' ||
                                'encumbrance_type_id, ' ||
                                'entered_dr, ' ||
                                'entered_cr, ' ||
                                'accounted_dr, ' ||
                                'accounted_cr, ' ||
                                'ussgl_transaction_code, ' ||
                                'reference1, ' ||
                                'reference2, ' ||
                                'reference3, ' ||
                                'reference4, ' ||
                                'reference5, ' ||
                                'je_line_description) ';


    -- Check Mode for Funds Check

    if g_pomode is null then

      -- dbms_output.put_line('g_pomode is null');

      if not po_fc_init then

	-- dbms_output.put_line('po-fc_init = false');

        PO_MESSAGE_S.APP_ERROR(error_name => 'PO_ALL_TRACE_ERROR',
                               token1 => 'FILE',
                               value1 => 'PO_FUNDS_CHECKER',
                               token2 => 'ERR_NUMBER',
                               value2 => '050',
                               token3 => 'SUBROUTINE',
                               value3 => 'PO_FC_INS()');

        return(FALSE);

      end if;

    end if;



    -- Check Level for Funds Check
    -- dbms_output.put_line('check level of funds control');

    if not po_fc_level(p_docid => p_docid,
                       p_lineid => p_lineid,
                       p_shipid => p_shipid,
                       p_distid => p_distid,
                       p_fclevel => g_fclevel) then

      PO_MESSAGE_S.APP_ERROR(error_name => 'PO_ALL_TRACE_ERROR',
                             token1 => 'FILE',
                             value1 => 'PO_FUNDS_CHECKER',
                             token2 => 'ERR_NUMBER',
                             value2 => '055',
                             token3 => 'SUBROUTINE',
                             value3 => 'PO_FC_INS()');

      -- dbms_output.put_line('fc level failed');

      return(FALSE);

    end if;


    -- Get Select Clause of the Insert Statement

    -- dbms_output.put_line('before get select clause');

    if not po_fc_sel(p_goodstmt => l_goodstmt) then

      PO_MESSAGE_S.APP_ERROR(error_name => 'PO_ALL_TRACE_ERROR',
                             token1 => 'FILE',
                             value1 => 'PO_FUNDS_CHECKER',
                             token2 => 'ERR_NUMBER',
                             value2 => '060',
                             token3 => 'SUBROUTINE',
                             value3 => 'PO_FC_INS()');
      return(FALSE);

    end if;


    -- Insert into the Funds Checker queue

    -- dbms_output.put_line('before insert into funds checker queue');

    if l_goodstmt then

      -- dbms_output.put_line('after l_goodstmt');

      if not po_fc_run(p_packetid => p_packetid) then


        PO_MESSAGE_S.APP_ERROR(error_name => 'PO_ALL_TRACE_ERROR',
                               token1 => 'FILE',
                               value1 => 'PO_FUNDS_CHECKER',
                               token2 => 'ERR_NUMBER',
                               value2 => '065',
                               token3 => 'SUBROUTINE',
                               value3 => 'PO_FC_INS()');
	-- dbms_output.put_line('po_fc_run return false');

        return(FALSE);

      end if;

    end if;

    return(TRUE);

  END po_fc_ins;

/* ----------------------------------------------------------------------- */
/*                                                                         */
/*   Check Level for Funds Check                                           */
/*                                                                         */
/* ----------------------------------------------------------------------- */

  -- Parameters :

  -- p_docid : Header ID

  -- p_lineid : Line ID

  -- p_shipid : Shipment ID

  -- p_distid : Distribution ID

  -- p_fclevel : Funds Check Level

  FUNCTION po_fc_level(p_docid   IN     NUMBER,
                       p_lineid  IN     NUMBER,
                       p_shipid  IN     NUMBER,
                       p_distid  IN     NUMBER DEFAULT 0,
                       p_fclevel IN OUT NOCOPY VARCHAR2) RETURN BOOLEAN IS

  BEGIN

    if p_distid <> 0 then
      p_fclevel := 'DISTRIBUTION';
    elsif p_shipid <> 0 then
      p_fclevel := 'SHIPMENT';
    elsif p_lineid <> 0 then
      p_fclevel := 'LINE';
    elsif p_docid <> 0 then
      p_fclevel := 'HEADER';
    else
      return(FALSE);
    end if;

    return(TRUE);

  END po_fc_level;

/* ----------------------------------------------------------------------- */

  -- Initialize for Funds Check

  FUNCTION po_fc_init RETURN BOOLEAN IS

    cursor pkt is
      select gl_bc_packets_s.nextval,
             fsp.set_of_books_id
        from financials_system_parameters fsp;

  BEGIN

    open pkt;

    fetch pkt
     into g_packetid, g_sobid;

    close pkt;


    -- Get Funds Check Mode from Action

    if g_action in ('RESERVE', 'APPROVE AND RESERVE', 'CHECK FUNDS') then
      g_pomode := 'RESERVE';
    elsif g_action in ('CANCEL', 'UNENCUMBER REQ') then
      g_pomode := 'REVERSE';
    elsif g_action in ('FINALLY CLOSE', 'RETURN', 'LIQUIDATE REQ') then
      g_pomode := 'LIQUIDATE';
    elsif g_action = 'REJECT' then
      g_pomode := 'REJECT';
    end if;

    if g_pomode = 'RESERVE' then

      if g_action = 'CHECK FUNDS' then
        g_fcmode := 'C';
      else
        g_fcmode := 'R';
      end if;

    else
      g_fcmode := 'A';
    end if;

    if g_pomode = 'REVERSE' then
      g_partial_resv_flag := 'N';
    else
      g_partial_resv_flag := 'Y';
    end if;

    return(TRUE);


  EXCEPTION

    WHEN OTHERS THEN

      if pkt%ISOPEN then
        close pkt;
      end if;

      PO_MESSAGE_S.SQL_ERROR(routine => 'PO_FUNDS_CHECKER',
                             location => '070',
                             error_code => SQLCODE);

      return(FALSE);

  END po_fc_init;

/* ----------------------------------------------------------------------- */

  -- Get Select Clause for Insert Statement

  FUNCTION po_fc_sel(p_goodstmt IN OUT NOCOPY BOOLEAN) RETURN BOOLEAN IS

  BEGIN

    p_goodstmt := FALSE;

    if g_doctyp = 'REQUISITION' then

      if not po_fc_selreq then

        PO_MESSAGE_S.APP_ERROR(error_name => 'PO_ALL_TRACE_ERROR',
                               token1 => 'FILE',
                               value1 => 'PO_FUNDS_CHECKER',
                               token2 => 'ERR_NUMBER',
                               value2 => '075',
                               token3 => 'SUBROUTINE',
                               value3 => 'PO_FC_SEL()');
        return(FALSE);

      end if;

    elsif g_doctyp = 'PO' then

      if not po_fc_selpo then

        PO_MESSAGE_S.APP_ERROR(error_name => 'PO_ALL_TRACE_ERROR',
                               token1 => 'FILE',
                               value1 => 'PO_FUNDS_CHECKER',
                               token2 => 'ERR_NUMBER',
                               value2 => '080',
                               token3 => 'SUBROUTINE',
                               value3 => 'PO_FC_SEL()');
        return(FALSE);

      end if;

    elsif g_doctyp = 'RELEASE' then

      if g_docsubtyp = 'BLANKET' then

        if not po_fc_selblnkrel then

          PO_MESSAGE_S.APP_ERROR(error_name => 'PO_ALL_TRACE_ERROR',
                                 token1 => 'FILE',
                                 value1 => 'PO_FUNDS_CHECKER',
                                 token2 => 'ERR_NUMBER',
                                 value2 => '085',
                                 token3 => 'SUBROUTINE',
                                 value3 => 'PO_FC_SEL()');
          return(FALSE);

        end if;

      elsif g_docsubtyp = 'SCHEDULED' then

        if not po_fc_selschrel then

          PO_MESSAGE_S.APP_ERROR(error_name => 'PO_ALL_TRACE_ERROR',
                                 token1 => 'FILE',
                                 value1 => 'PO_FUNDS_CHECKER',
                                 token2 => 'ERR_NUMBER',
                                 value2 => '090',
                                 token3 => 'SUBROUTINE',
                                 value3 => 'PO_FC_SEL()');
          return(FALSE);

        end if;

      else

        PO_MESSAGE_S.APP_ERROR(error_name => 'PO_ALL_TRACE_ERROR',
                               token1 => 'FILE',
                               value1 => 'PO_FUNDS_CHECKER',
                               token2 => 'ERR_NUMBER',
                               value2 => '095',
                               token3 => 'SUBROUTINE',
                               value3 => 'PO_FC_SEL()');
        return(FALSE);

      end if;

    else

      PO_MESSAGE_S.APP_ERROR(error_name => 'PO_ALL_TRACE_ERROR',
                             token1 => 'FILE',
                             value1 => 'PO_FUNDS_CHECKER',
                             token2 => 'ERR_NUMBER',
                             value2 => '100',
                             token3 => 'SUBROUTINE',
                             value3 => 'PO_FC_SEL()');
      return(FALSE);

    end if;

    p_goodstmt := TRUE;

    return(TRUE);


  EXCEPTION

    WHEN OTHERS THEN

      PO_MESSAGE_S.SQL_ERROR(routine => 'PO_FUNDS_CHECKER',
                             location => '105',
                             error_code => SQLCODE);

      return(FALSE);

  END po_fc_sel;

/* ----------------------------------------------------------------------- */

  -- Build Select Statement for Requisition

  -- Status Code is 'P' for Pending Funds Reservation and 'C' for Pending
  -- Funds Check

  -- Round the Entered Amounts to the precision of the Currency that they
  -- are in because the Unit Price could be specified with a larger precision

  -- Accounted DR and CR are the same as the Entered Amounts because there is
  -- no Currency Conversion for Requisitions

  FUNCTION po_fc_selreq RETURN BOOLEAN IS

    l_stmt  VARCHAR2(3000);

  BEGIN

    l_stmt := 'select :packet_id, ' ||
                     'glsob.set_of_books_id, ' ||
                     '''Purchasing'', ' ||
                     '''Requisitions'', ' ||
                     'pord.budget_account_id, ' ||
                     '''E'', ' ||
                     'glp.period_name, ' ||
                     'glp.period_year, ' ||
                     'glp.period_num, ' ||
                     'glp.quarter_num, ' ||
                     'glsob.currency_code, ' ||
                     ':status_code, ' ||
                     'sysdate, ' ||
                     ':user_id, ' ||
                     'null, ' ||
                     'fsp.req_encumbrance_type_id, ' ||
                     'decode(base_cur.minimum_accountable_unit, null, ' ||
                            'round((porl.unit_price + ' ||
                            'po_tax_sv.get_tax(''REQ'',PORD.distribution_id) ' ||
                            '/ PORD.req_line_quantity) * :dr_quantity, ' ||
                            'base_cur.precision), round((porl.unit_price + ' ||
                            'po_tax_sv.get_tax(''REQ'',PORD.distribution_id) ' ||
                            '/ PORD.req_line_quantity) * :dr_quantity / ' ||
                            'base_cur.minimum_accountable_unit) * ' ||
                            'base_cur.minimum_accountable_unit), ' ||
                     'decode(base_cur.minimum_accountable_unit, null, ' ||
                            'round((porl.unit_price + ' ||
                            'po_tax_sv.get_tax(''REQ'',PORD.distribution_id) ' ||
                            '/ PORD.req_line_quantity) * :cr_quantity, ' ||
                            'base_cur.precision), round((porl.unit_price + ' ||
                            'po_tax_sv.get_tax(''REQ'',PORD.distribution_id) ' ||
                            '/ PORD.req_line_quantity) * :cr_quantity / ' ||
                            'base_cur.minimum_accountable_unit) * ' ||
                            'base_cur.minimum_accountable_unit), ' ||
                     'decode(base_cur.minimum_accountable_unit, null, ' ||
                            'round((porl.unit_price + ' ||
                            'po_tax_sv.get_tax(''REQ'',PORD.distribution_id) ' ||
                            '/ PORD.req_line_quantity) * :dr_quantity, ' ||
                            'base_cur.precision), round((porl.unit_price + ' ||
                            'po_tax_sv.get_tax(''REQ'',PORD.distribution_id) ' ||
                            '/ PORD.req_line_quantity) * :dr_quantity / ' ||
                            'base_cur.minimum_accountable_unit) * ' ||
                            'base_cur.minimum_accountable_unit), ' ||
                     'decode(base_cur.minimum_accountable_unit, null, ' ||
                            'round((porl.unit_price + ' ||
                            'po_tax_sv.get_tax(''REQ'',PORD.distribution_id) ' ||
                            '/ PORD.req_line_quantity) * :cr_quantity, ' ||
                            'base_cur.precision), round((porl.unit_price + ' ||
                            'po_tax_sv.get_tax(''REQ'',PORD.distribution_id) ' ||
                            '/ PORD.req_line_quantity) * :cr_quantity / ' ||
                            'base_cur.minimum_accountable_unit) * ' ||
                            'base_cur.minimum_accountable_unit), ' ||
                     'pord.ussgl_transaction_code, ' ||
                     '''REQ'', ' ||
                     'porl.requisition_header_id, ' ||
                     'pord.distribution_id, ' ||
                     'prh.segment1, ' ||
                     'porl.reference_num, ' ||
                     'substr(porl.item_description, 1, 40) ' ||
                'from gl_periods glp, ' ||
                     'gl_sets_of_books glsob, ' ||
                     'financials_system_parameters fsp, ' ||
                     'fnd_currencies base_cur, ' ||
                     'po_req_distributions pord, ' ||
                     'po_requisition_lines porl, ' ||
                     'po_requisition_headers prh ' ||
               'where glsob.set_of_books_id = fsp.set_of_books_id ' ||
                 'and glp.period_set_name = glsob.period_set_name ' ||
                 'and glp.period_name = nvl(:override_period, pord.gl_encumbered_period_name) ' ||
                 'and base_cur.currency_code = glsob.currency_code ' ||
                 'and nvl(pord.encumbered_flag, ''N'') = '':encumbrance_state'' ' ||
                 'and nvl(porl.cancel_flag, ''N'') =  '':cancel_state'' ' ||
                 'and porl.line_location_id is null ' ||
                 'and :entity_level = :object_id ' ||
                 'and porl.requisition_line_id = pord.requisition_line_id ' ||
                 'and nvl(pord.prevent_encumbrance_flag, ''N'') = ''N'' ' ||
                 'and nvl(fsp.req_encumbrance_flag, ''N'') = ''Y'' ' ||
                 'and porl.requisition_header_id = prh.requisition_header_id';


    -- Substitute the tokens

    if g_pomode = 'RESERVE' then

      l_stmt := replace(l_stmt, ':dr_quantity', 'pord.req_line_quantity');
      l_stmt := replace(l_stmt, ':cr_quantity', '0');
      l_stmt := replace(l_stmt, ':encumbrance_state', 'N');
      l_stmt := replace(l_stmt, ':cancel_state', 'N');

    elsif g_pomode = 'REVERSE' then

      l_stmt := replace(l_stmt, ':dr_quantity', 'decode(porl.quantity_cancelled, null, -(pord.req_line_quantity), -(porl.quantity_cancelled * pord.req_line_quantity / porl.quantity))');
      l_stmt := replace(l_stmt, ':cr_quantity', '0');
      l_stmt := replace(l_stmt, ':encumbrance_state', 'Y');
      l_stmt := replace(l_stmt, ':cancel_state', 'I');

    elsif g_pomode = 'LIQUIDATE' then

      l_stmt := replace(l_stmt, ':dr_quantity', '0');
      l_stmt := replace(l_stmt, ':cr_quantity', '(pord.req_line_quantity - ((pord.req_line_quantity / porl.quantity) * porl.quantity_delivered))');
      l_stmt := replace(l_stmt, ':encumbrance_state', 'Y');
      l_stmt := replace(l_stmt, ':cancel_state', 'N');

    elsif g_pomode = 'REJECT' then

      l_stmt := replace(l_stmt, ':dr_quantity', '0');
      l_stmt := replace(l_stmt, ':cr_quantity', '(pord.req_line_quantity - ((pord.req_line_quantity / porl.quantity) * porl.quantity_delivered))');
      l_stmt := replace(l_stmt, ':encumbrance_state', 'Y');
      l_stmt := replace(l_stmt, ':cancel_state', 'N');

    end if;

    if g_fclevel = 'DISTRIBUTION' then

      l_stmt := replace(l_stmt, ':entity_level', 'pord.distribution_id');

    elsif g_fclevel = 'SHIPMENT' then

      l_stmt := replace(l_stmt, ':entity_level', '');

    elsif g_fclevel = 'LINE' then

      l_stmt := replace(l_stmt, ':entity_level', 'porl.requisition_line_id');

    elsif g_fclevel = 'HEADER' then

      l_stmt := replace(l_stmt, ':entity_level', 'prh.requisition_header_id');

    end if;

    g_sql_insert := g_sql_insert ||
                    l_stmt;

    return(TRUE);

  END po_fc_selreq;

/* ----------------------------------------------------------------------- */

  -- Build Select Statement for PO

  -- Status Code is 'P' for Pending Funds Reservation and 'C' for Pending
  -- Funds Check

  -- Round the Entered Amounts to the precision of the Currency that they
  -- are in because the Unit Price could be specified with a larger precision

  FUNCTION po_fc_selpo RETURN BOOLEAN IS

    l_stmt   VARCHAR2(4000);
    l_bstmt  VARCHAR2(3000);

  BEGIN
/* Bug#2181793 : Modified the l_stmt and the b_stmt to take account
of the tax portion also for encumbrance. similar modifications done in
the functions po_fc_selblnkrel and po_fc_selschrel */

/* Bug#2310026 :Entered_amount should be first rounded to entered_currency
precision/minimum_accountable_unit. This should be then multiplied with the
POD.rate to get the functional amount which should be rounded off to the
base currency precision. Accordingly, changed the BASE_CUR table to DOC_CUR
in the calculatation of the fields entered_dr, entered_cr, accounted_dr,
accounted_cr and moved the nvl(POD.rate) out of the round function. The
entered_amounts thus got are then multiplied with the nvl(POD.rate,1). This
amount should be rounded off to the functional currency precision. Now
incorporating the code to round this value to functional currency precision,
will require two more decode statements for each decode statement. Thus,
to avoid this, we multiply with the rate alone here. This functional amount
will be rounded to the functional currency precision/minimum accountable unit
after inserting the records in the gl_bc_packets in the procedure
po_funds_control after the call po_fc_ins(insertion of gl_bc_packet).

Similar changes made in the function po_fc_selblnkrel and po_fc_selschrel */

    l_stmt := 'select :packet_id, ' ||
                     'glsob.set_of_books_id, ' ||
                     '''Purchasing'', ' ||
                     '''Purchases'', ' ||
                     'pod.budget_account_id, ' ||
                     '''E'', ' ||
                     'glp.period_name, ' ||
                     'glp.period_year, ' ||
                     'glp.period_num, ' ||
                     'glp.quarter_num, ' ||
                     'glsob.currency_code, ' ||
                     ':status_code, ' ||
                     'sysdate, ' ||
                     ':user_id, ' ||
                     'null, ' ||
                     'fsp.purch_encumbrance_type_id, ' ||
                     'decode(doc_cur.minimum_accountable_unit, null, ' ||
                            'round((poll.price_override +  ' ||
                            'po_tax_sv.get_tax(''PO'',POD.po_distribution_id)'||
                            '/ POD.quantity_ordered) * :dr_quantity ' ||
                            ', doc_cur.precision) * nvl(pod.rate, 1) , ' ||
                            'round((poll.price_override  + ' ||
                            'po_tax_sv.get_tax(''PO'',POD.po_distribution_id)'||
                            '/ POD.quantity_ordered) * :dr_quantity' ||
                            ' / doc_cur.minimum_accountable_unit)  ' ||
                            ' * doc_cur.minimum_accountable_unit' ||
                            ' * nvl(pod.rate, 1) ), ' ||
                     'decode(doc_cur.minimum_accountable_unit, null, ' ||
                            'round((poll.price_override +  ' ||
                            'po_tax_sv.get_tax(''PO'',POD.po_distribution_id)'||
                            '/ POD.quantity_ordered) * :cr_quantity ' ||
                            ', doc_cur.precision) * nvl(pod.rate, 1) , ' ||
                            'round((poll.price_override  + ' ||
                            'po_tax_sv.get_tax(''PO'',POD.po_distribution_id)'||
                            '/ POD.quantity_ordered) * :cr_quantity' ||
                            ' / doc_cur.minimum_accountable_unit)  ' ||
                            ' * doc_cur.minimum_accountable_unit' ||
                            ' * nvl(pod.rate, 1) ), ' ||
                     'decode(doc_cur.minimum_accountable_unit, null, ' ||
                            'round((poll.price_override +  ' ||
                            'po_tax_sv.get_tax(''PO'',POD.po_distribution_id)'||
                            '/ POD.quantity_ordered) * :dr_quantity ' ||
                            ', doc_cur.precision) * nvl(pod.rate, 1) , ' ||
                            'round((poll.price_override  + ' ||
                            'po_tax_sv.get_tax(''PO'',POD.po_distribution_id)'||
                            '/ POD.quantity_ordered) * :dr_quantity' ||
                            ' / doc_cur.minimum_accountable_unit)  ' ||
                            ' * doc_cur.minimum_accountable_unit' ||
                            ' * nvl(pod.rate, 1) ), ' ||
                     'decode(doc_cur.minimum_accountable_unit, null, ' ||
                            'round((poll.price_override +  ' ||
                            'po_tax_sv.get_tax(''PO'',POD.po_distribution_id)'||
                            '/ POD.quantity_ordered) * :cr_quantity ' ||
                            ', doc_cur.precision) * nvl(pod.rate, 1) , ' ||
                            'round((poll.price_override  + ' ||
                            'po_tax_sv.get_tax(''PO'',POD.po_distribution_id)'||
                            '/ POD.quantity_ordered) * :cr_quantity' ||
                            ' / doc_cur.minimum_accountable_unit)  ' ||
                            ' * doc_cur.minimum_accountable_unit' ||
                            ' * nvl(pod.rate, 1) ), ' ||
                     'pod.ussgl_transaction_code, ' ||
                     '''PO'', ' ||
                     'poll.po_header_id, ' ||
                     'pod.po_distribution_id, ' ||
                     'poh.segment1, ' ||
                     'decode(pod.req_distribution_id, null, null, ' ||
                            'prh.segment1), ' ||
                     'substr(pol.item_description, 1, 40) ' ||
                'from gl_periods glp, ' ||
                     'gl_sets_of_books glsob, ' ||
                     'financials_system_parameters fsp, ' ||
                     'fnd_currencies doc_cur, ' ||
                     'po_distributions pod, ' ||
                     'po_line_locations poll, ' ||
                     'po_lines pol, ' ||
                     'po_headers poh, ' ||
                     'po_requisition_headers prh, ' ||
                     'po_requisition_lines porl, ' ||
                     'po_req_distributions pord ' ||
               'where glsob.set_of_books_id = fsp.set_of_books_id ' ||
                 'and glp.period_set_name = glsob.period_set_name ' ||
                 'and glp.period_name = nvl(:override_period, pod.gl_encumbered_period_name) ' ||
                 'and doc_cur.currency_code = poh.currency_code ' ||
                 'and poll.po_header_id = poh.po_header_id ' ||
                 'and poll.shipment_type in (''STANDARD'', ''PLANNED'') ' ||
                 'and pod.line_location_id = poll.line_location_id ' ||
                 'and pod.po_line_id = pol.po_line_id ' ||
                 'and nvl(pod.encumbered_flag, ''N'') = '':encumbrance_state'' ' ||
                 'and nvl(poll.cancel_flag, ''N'') = '':cancel_state'' ' ||
                 'and nvl(pod.prevent_encumbrance_flag, ''N'') = ''N'' ' ||
                 'and :entity_level = :object_id ' ||
                 'and pod.req_distribution_id = pord.distribution_id(+) ' ||
                 'and pord.requisition_line_id = porl.requisition_line_id(+) ' ||
                 'and porl.requisition_header_id = prh.requisition_header_id (+)';


    -- Statement to recreate Requisition Encumbrances

    l_bstmt := 'select :packet_id, ' ||
                      'glsob.set_of_books_id, ' ||
                      '''Purchasing'', ' ||
                      '''Requisitions'', ' ||
                      'pord.budget_account_id, ' ||
                      '''E'', ' ||
                      'glp.period_name, ' ||
                      'glp.period_year, ' ||
                      'glp.period_num, ' ||
                      'glp.quarter_num, ' ||
                      'glsob.currency_code, ' ||
                      ':status_code, ' ||
                      'sysdate, ' ||
                      ':user_id, ' ||
                      'null, ' ||
                      'fsp.req_encumbrance_type_id, ' ||
                      'decode(base_cur.minimum_accountable_unit, null, ' ||
                             'round((porl.unit_price + ' ||
                             'po_tax_sv.get_tax(''REQ'',PORD.distribution_id) '||
                             '/ PORD.req_line_quantity) * :dr_quantity, ' ||
                             'base_cur.precision), ' ||
                             'round((porl.unit_price + ' ||
                            'po_tax_sv.get_tax(''REQ'',PORD.distribution_id) '||
                             '/ PORD.req_line_quantity) * :dr_quantity / ' ||
                             'base_cur.minimum_accountable_unit) * ' ||
                             'base_cur.minimum_accountable_unit), ' ||
                      'decode(base_cur.minimum_accountable_unit, null, ' ||
                             'round((porl.unit_price + ' ||
                             'po_tax_sv.get_tax(''REQ'',PORD.distribution_id) '||
                             '/ PORD.req_line_quantity) * :cr_quantity, ' ||
                             'base_cur.precision), ' ||
                             'round((porl.unit_price + ' ||
                            'po_tax_sv.get_tax(''REQ'',PORD.distribution_id) '||
                             '/ PORD.req_line_quantity) * :cr_quantity / ' ||
                             'base_cur.minimum_accountable_unit) * ' ||
                             'base_cur.minimum_accountable_unit), ' ||
                      'decode(base_cur.minimum_accountable_unit, null, ' ||
                             'round((porl.unit_price + ' ||
                             'po_tax_sv.get_tax(''REQ'',PORD.distribution_id) '||
                             '/ PORD.req_line_quantity) * :dr_quantity, ' ||
                             'base_cur.precision), ' ||
                             'round((porl.unit_price + ' ||
                             'po_tax_sv.get_tax(''REQ'',PORD.distribution_id) '||
                             '/ PORD.req_line_quantity) * :dr_quantity / ' ||
                             'base_cur.minimum_accountable_unit) * ' ||
                             'base_cur.minimum_accountable_unit), ' ||
                      'decode(base_cur.minimum_accountable_unit, null, ' ||
                             'round((porl.unit_price + ' ||
                             'po_tax_sv.get_tax(''REQ'',PORD.distribution_id) '||
                             '/ PORD.req_line_quantity) * :cr_quantity, ' ||
                             'base_cur.precision), ' ||
                             'round((porl.unit_price + ' ||
                             'po_tax_sv.get_tax(''REQ'',PORD.distribution_id) '||
                             '/ PORD.req_line_quantity) * :cr_quantity / ' ||
                             'base_cur.minimum_accountable_unit) * ' ||
                             'base_cur.minimum_accountable_unit), ' ||
                      'pord.ussgl_transaction_code, ' ||
                      '''REQ'', ' ||
                      'porl.requisition_header_id, ' ||
                      'pord.distribution_id, ' ||
                      'prh.segment1, ' ||
                      'porl.reference_num, ' ||
                      'substr(porl.item_description, 1, 40) ' ||
                 'from gl_periods glp, ' ||
                      'gl_sets_of_books glsob, ' ||
                      'financials_system_parameters fsp, ' ||
                      'fnd_currencies base_cur, ' ||
                      'po_req_distributions pord, ' ||
                      'po_requisition_lines porl, ' ||
                      'po_requisition_headers prh, ' ||
                      'po_distributions pod, ' ||
                      'po_line_locations poll ' ||
                'where glsob.set_of_books_id = fsp.set_of_books_id ' ||
                  'and glp.period_set_name = glsob.period_set_name ' ||
                  'and glp.period_name = nvl(:override_period, pod.gl_encumbered_period_name) ' ||
                  'and base_cur.currency_code = glsob.currency_code ' ||
                  'and poll.shipment_type in (''STANDARD'', ''PLANNED'') ' ||
                  'and pod.line_location_id = poll.line_location_id ' ||
                  'and nvl(pod.encumbered_flag, ''N'') = '':encumbrance_state'' ' ||
                  'and nvl(poll.cancel_flag, ''N'') = '':cancel_state'' ' ||
                  'and nvl(pod.prevent_encumbrance_flag, ''N'') = ''N'' ' ||
                  'and :entity_level = :object_id ' ||
                  'and :backing_doc_join_column = pod.req_distribution_id ' ||
                  'and porl.requisition_line_id = pord.requisition_line_id ' ||
                  'and nvl(fsp.req_encumbrance_flag, ''N'') = ''Y'' ' ||
                  'and nvl(pord.prevent_encumbrance_flag, ''N'') = ''N'' ' ||
                  'and porl.requisition_header_id = prh.requisition_header_id ' ||
                  'and nvl(:recreate_demand, ''Y'') = ''Y''';


    -- Substitute the tokens

    if g_pomode = 'RESERVE' then

      l_stmt := replace(l_stmt, ':dr_quantity', 'pod.quantity_ordered');
      l_stmt := replace(l_stmt, ':cr_quantity', '0');
      l_stmt := replace(l_stmt, ':encumbrance_state', 'N');
      l_stmt := replace(l_stmt, ':cancel_state', 'N');

      l_bstmt := replace(l_bstmt, ':dr_quantity', '0');
      l_bstmt := replace(l_bstmt, ':cr_quantity', 'pord.req_line_quantity');
      l_bstmt := replace(l_bstmt, ':backing_doc_join_column', 'pord.distribution_id');
      l_bstmt := replace(l_bstmt, ':encumbrance_state', 'N');
      l_bstmt := replace(l_bstmt, ':cancel_state', 'N');

    elsif g_pomode = 'REVERSE' then

      l_stmt := replace(l_stmt, ':dr_quantity', '-(decode(nvl(poll.accrue_on_receipt_flag, ''N''), ''N'', (pod.quantity_ordered - nvl(pod.quantity_billed, 0)), ''Y'', (pod.quantity_ordered - nvl(pod.quantity_delivered, 0))))');
      l_stmt := replace(l_stmt, ':cr_quantity', '0');
      l_stmt := replace(l_stmt, ':encumbrance_state', 'Y');
      l_stmt := replace(l_stmt, ':cancel_state', 'I');

      l_bstmt := replace(l_bstmt, ':dr_quantity', '0');
      l_bstmt := replace(l_bstmt, ':cr_quantity',
			'(poll.price_override / porl.unit_price) * -(decode(nvl(poll.accrue_on_receipt_flag, ''N''), ''N'',
			(pod.quantity_ordered - nvl(pod.quantity_billed, 0)), ''Y'',
			(pod.quantity_ordered - nvl(pod.quantity_delivered, 0))))');
      l_bstmt := replace(l_bstmt, ':backing_doc_join_column', 'pord.source_req_distribution_id');
      l_bstmt := replace(l_bstmt, ':encumbrance_state', 'Y');
      l_bstmt := replace(l_bstmt, ':cancel_state', 'I');

    elsif g_pomode = 'LIQUIDATE' then

      l_stmt := replace(l_stmt, ':dr_quantity', '0');
      l_stmt := replace(l_stmt, ':cr_quantity', 'greatest(decode(nvl(poll.accrue_on_receipt_flag, ''N''), ''N'', (pod.quantity_ordered - nvl(pod.quantity_billed, 0)), ''Y'', (pod.quantity_ordered - nvl(pod.quantity_delivered, 0))), 0)');
      l_stmt := replace(l_stmt, ':encumbrance_state', 'Y');
      l_stmt := replace(l_stmt, ':cancel_state', 'N');

      l_bstmt := replace(l_bstmt, ':dr_quantity', '0');
      l_bstmt := replace(l_bstmt, ':cr_quantity', '0');
      l_bstmt := replace(l_bstmt, ':backing_doc_join_column', 'pord.distribution_id');
      l_bstmt := replace(l_bstmt, ':encumbrance_state', 'Y');
      l_bstmt := replace(l_bstmt, ':cancel_state', 'N');

    elsif g_pomode = 'REJECT' then

      l_stmt := replace(l_stmt, ':dr_quantity', '0');
      l_stmt := replace(l_stmt, ':cr_quantity', '(decode(nvl(poll.approved_flag, ''N''), ''Y'', 0, ''N'', 0, ''R'', (decode(nvl(poll.quantity_received, 0), 0, (decode(nvl(poll.quantity_billed, 0), 0, pod.quantity_ordered, 0)), 0))))');
      l_stmt := replace(l_stmt, ':encumbrance_state', 'Y');
      l_stmt := replace(l_stmt, ':cancel_state', 'N');

      l_bstmt := replace(l_bstmt, ':dr_quantity', '(decode(nvl(poll.approved_flag, ''N''), ''Y'', 0, ''N'', 0, ''R'', (decode(nvl(poll.quantity_received, 0), 0, (decode(nvl(poll.quantity_billed, 0), 0, pord.req_line_quantity, 0)), 0))))');
      l_bstmt := replace(l_bstmt, ':cr_quantity', '0');
      l_bstmt := replace(l_bstmt, ':backing_doc_join_column', 'pord.distribution_id');
      l_bstmt := replace(l_bstmt, ':encumbrance_state', 'Y');
      l_bstmt := replace(l_bstmt, ':cancel_state', 'N');

    end if;

    if g_fclevel = 'DISTRIBUTION' then

      l_stmt := replace(l_stmt, ':entity_level', 'pod.po_distribution_id');
      l_bstmt := replace(l_bstmt, ':entity_level', 'pod.po_distribution_id');

    elsif g_fclevel = 'SHIPMENT' then

      l_stmt := replace(l_stmt, ':entity_level', 'poll.line_location_id');
      l_bstmt := replace(l_bstmt, ':entity_level', 'poll.line_location_id');

    elsif g_fclevel = 'LINE' then

      l_stmt := replace(l_stmt, ':entity_level', 'poll.po_line_id');
      l_bstmt := replace(l_bstmt, ':entity_level', 'poll.po_line_id');

    elsif g_fclevel = 'HEADER' then

      l_stmt := replace(l_stmt, ':entity_level', 'poll.po_header_id');
      l_bstmt := replace(l_bstmt, ':entity_level', 'poll.po_header_id');

    end if;

    g_sql_insert := g_sql_insert ||
                    l_stmt || ' UNION ALL ' ||
                    l_bstmt;

    return(TRUE);

  END po_fc_selpo;

/* ----------------------------------------------------------------------- */

  -- Build Select Statement for Blanket PO backed by a Requisition

  -- Status Code is 'P' for Pending Funds Reservation and 'C' for Pending
  -- Funds Check

  -- Round the Entered Amounts to the precision of the Currency that they
  -- are in because the Unit Price could be specified with a larger precision

  FUNCTION po_fc_selblnkrel RETURN BOOLEAN IS

    l_stmt   VARCHAR2(4000);
    l_bstmt  VARCHAR2(3000);

  BEGIN

    l_stmt := 'select :packet_id, ' ||
                     'glsob.set_of_books_id, ' ||
                     '''Purchasing'', ' ||
                     '''Purchases'', ' ||
                     'pod.budget_account_id, ' ||
                     '''E'', ' ||
                     'glp.period_name, ' ||
                     'glp.period_year, ' ||
                     'glp.period_num, ' ||
                     'glp.quarter_num, ' ||
                     'glsob.currency_code, ' ||
                     ':status_code, ' ||
                     'sysdate, ' ||
                     ':user_id, ' ||
                     'null, ' ||
                     'fsp.purch_encumbrance_type_id, ' ||
                     'decode(doc_cur.minimum_accountable_unit, null, ' ||
                            'round((poll.price_override +  ' ||
                            'po_tax_sv.get_tax(''RELEASE'',POD.po_distribution_id)'||
                            '/ POD.quantity_ordered) * :dr_quantity ' ||
                            ', doc_cur.precision) * nvl(pod.rate, 1) , ' ||
                            'round((poll.price_override  + ' ||
                            'po_tax_sv.get_tax(''RELEASE'',POD.po_distribution_id)'||
                            '/ POD.quantity_ordered) * :dr_quantity' ||
                            ' / doc_cur.minimum_accountable_unit)  ' ||
                            ' * doc_cur.minimum_accountable_unit' ||
                            ' * nvl(pod.rate, 1) ), ' ||
                     'decode(doc_cur.minimum_accountable_unit, null, ' ||
                            'round((poll.price_override +  ' ||
                            'po_tax_sv.get_tax(''RELEASE'',POD.po_distribution_id)'||
                            '/ POD.quantity_ordered) * :cr_quantity ' ||
                            ', doc_cur.precision) * nvl(pod.rate, 1) , ' ||
                            'round((poll.price_override  + ' ||
                            'po_tax_sv.get_tax(''RELEASE'',POD.po_distribution_id)'||
                            '/ POD.quantity_ordered) * :cr_quantity' ||
                            ' / doc_cur.minimum_accountable_unit)  ' ||
                            ' * doc_cur.minimum_accountable_unit' ||
                            ' * nvl(pod.rate, 1) ), ' ||
                     'decode(doc_cur.minimum_accountable_unit, null, ' ||
                            'round((poll.price_override +  ' ||
                            'po_tax_sv.get_tax(''RELEASE'',POD.po_distribution_id)'||
                            '/ POD.quantity_ordered) * :dr_quantity ' ||
                            ', doc_cur.precision) * nvl(pod.rate, 1) , ' ||
                            'round((poll.price_override  + ' ||
                            'po_tax_sv.get_tax(''RELEASE'',POD.po_distribution_id)'||
                            '/ POD.quantity_ordered) * :dr_quantity' ||
                            ' / doc_cur.minimum_accountable_unit)  ' ||
                            ' * doc_cur.minimum_accountable_unit' ||
                            ' * nvl(pod.rate, 1) ), ' ||
                     'decode(doc_cur.minimum_accountable_unit, null, ' ||
                            'round((poll.price_override +  ' ||
                            'po_tax_sv.get_tax(''RELEASE'',POD.po_distribution_id)'||
                            '/ POD.quantity_ordered) * :cr_quantity ' ||
                            ', doc_cur.precision) * nvl(pod.rate, 1) , ' ||
                            'round((poll.price_override  + ' ||
                            'po_tax_sv.get_tax(''RELEASE'',POD.po_distribution_id)'||
                            '/ POD.quantity_ordered) * :cr_quantity' ||
                            ' / doc_cur.minimum_accountable_unit)  ' ||
                            ' * doc_cur.minimum_accountable_unit' ||
                            ' * nvl(pod.rate, 1) ), ' ||
                     'pod.ussgl_transaction_code, ' ||
                     '''PO'', ' ||
                     'poll.po_header_id, ' ||
                     'pod.po_distribution_id, ' ||
                     'poh.segment1, ' ||
                     'decode(pod.req_distribution_id, null, null, ' ||
                            'prh.segment1), ' ||
                     'substr(pol.item_description, 1, 40) ' ||
                'from gl_periods glp, ' ||
                     'gl_sets_of_books glsob, ' ||
                     'financials_system_parameters fsp, ' ||
                     'fnd_currencies doc_cur, ' ||
                     'po_distributions pod, ' ||
                     'po_line_locations poll, ' ||
                     'po_lines pol, ' ||
                     'po_releases por, ' ||
                     'po_headers poh, ' ||
                     'po_requisition_headers prh, ' ||
                     'po_requisition_lines porl, ' ||
                     'po_req_distributions pord ' ||
               'where glsob.set_of_books_id = fsp.set_of_books_id ' ||
                 'and glp.period_set_name = glsob.period_set_name ' ||
                 'and glp.period_name = nvl(:override_period, pod.gl_encumbered_period_name) ' ||
                 'and doc_cur.currency_code = poh.currency_code ' ||
                 'and poll.po_release_id = por.po_release_id ' ||
                 'and por.po_header_id = poh.po_header_id ' ||
                 'and poll.shipment_type = ''BLANKET'' ' ||
                 'and pod.line_location_id = poll.line_location_id ' ||
                 'and pod.po_line_id = pol.po_line_id ' ||
                 'and nvl(pod.encumbered_flag, ''N'') = '':encumbrance_state'' ' ||
                 'and nvl(poll.cancel_flag, ''N'') = '':cancel_state'' ' ||
                 'and nvl(pod.prevent_encumbrance_flag, ''N'') = ''N'' ' ||
                 'and :entity_level = :object_id ' ||
                 'and pod.req_distribution_id = pord.distribution_id(+) ' ||
                 'and pord.requisition_line_id = porl.requisition_line_id(+) ' ||
                 'and porl.requisition_header_id = prh.requisition_header_id (+)';


    -- Statement to recreate Requisition Encumbrances

    l_bstmt := 'select :packet_id, ' ||
                      'glsob.set_of_books_id, ' ||
                      '''Purchasing'', ' ||
                      '''Requisitions'', ' ||
                      'pord.budget_account_id, ' ||
                      '''E'', ' ||
                      'glp.period_name, ' ||
                      'glp.period_year, ' ||
                      'glp.period_num, ' ||
                      'glp.quarter_num, ' ||
                      'glsob.currency_code, ' ||
                      ':status_code, ' ||
                      'sysdate, ' ||
                      ':user_id, ' ||
                      'null, ' ||
                      'fsp.req_encumbrance_type_id, ' ||
                      'decode(base_cur.minimum_accountable_unit, null, ' ||
                             'round((porl.unit_price + ' ||
                           'po_tax_sv.get_tax(''REQ'',PORD.distribution_id) ' ||
                             '/ PORD.req_line_quantity) * :dr_quantity, ' ||
                             'base_cur.precision), ' ||
                             'round((porl.unit_price + ' ||
                           'po_tax_sv.get_tax(''REQ'',PORD.distribution_id) ' ||
                             '/ PORD.req_line_quantity) * :dr_quantity / ' ||
                             'base_cur.minimum_accountable_unit) * ' ||
                             'base_cur.minimum_accountable_unit), ' ||
                      'decode(base_cur.minimum_accountable_unit, null, ' ||
                             'round((porl.unit_price + ' ||
                           'po_tax_sv.get_tax(''REQ'',PORD.distribution_id) ' ||
                             '/ PORD.req_line_quantity) * :cr_quantity, ' ||
                             'base_cur.precision), ' ||
                             'round((porl.unit_price + ' ||
                           'po_tax_sv.get_tax(''REQ'',PORD.distribution_id) ' ||
                             '/ PORD.req_line_quantity) * :cr_quantity / ' ||
                             'base_cur.minimum_accountable_unit) * ' ||
                             'base_cur.minimum_accountable_unit), ' ||
                      'decode(base_cur.minimum_accountable_unit, null, ' ||
                             'round((porl.unit_price + ' ||
                           'po_tax_sv.get_tax(''REQ'',PORD.distribution_id) ' ||
                             '/ PORD.req_line_quantity) * :dr_quantity, ' ||
                             'base_cur.precision), ' ||
                             'round((porl.unit_price + ' ||
                           'po_tax_sv.get_tax(''REQ'',PORD.distribution_id) ' ||
                             '/ PORD.req_line_quantity) * :dr_quantity / ' ||
                             'base_cur.minimum_accountable_unit) * ' ||
                             'base_cur.minimum_accountable_unit), ' ||
                      'decode(base_cur.minimum_accountable_unit, null, ' ||
                             'round((porl.unit_price + ' ||
                           'po_tax_sv.get_tax(''REQ'',PORD.distribution_id) ' ||
                             '/ PORD.req_line_quantity) * :cr_quantity, ' ||
                             'base_cur.precision), ' ||
                             'round((porl.unit_price + ' ||
                           'po_tax_sv.get_tax(''REQ'',PORD.distribution_id) ' ||
                             '/ PORD.req_line_quantity) * :cr_quantity / ' ||
                             'base_cur.minimum_accountable_unit) * ' ||
                             'base_cur.minimum_accountable_unit), ' ||
                      'pord.ussgl_transaction_code, ' ||
                      '''REQ'', ' ||
                      'porl.requisition_header_id, ' ||
                      'pord.distribution_id, ' ||
                      'prh.segment1, ' ||
                      'porl.reference_num, ' ||
                      'substr(porl.item_description, 1, 40) ' ||
                 'from gl_periods glp, ' ||
                      'gl_sets_of_books glsob, ' ||
                      'financials_system_parameters fsp, ' ||
                      'fnd_currencies base_cur, ' ||
                      'po_req_distributions pord, ' ||
                      'po_requisition_lines porl, ' ||
                      'po_requisition_headers prh, ' ||
                      'po_distributions pod, ' ||
                      'po_line_locations poll ' ||
                'where glsob.set_of_books_id = fsp.set_of_books_id ' ||
                  'and glp.period_set_name = glsob.period_set_name ' ||
                  'and glp.period_name = nvl(:override_period, pod.gl_encumbered_period_name) ' ||
                  'and base_cur.currency_code = glsob.currency_code ' ||
                  'and poll.shipment_type = ''BLANKET'' ' ||
                  'and pod.line_location_id = poll.line_location_id ' ||
                  'and nvl(pod.encumbered_flag, ''N'') = '':encumbrance_state'' ' ||
                  'and nvl(poll.cancel_flag, ''N'') = '':cancel_state'' ' ||
                  'and nvl(pod.prevent_encumbrance_flag, ''N'') = ''N'' ' ||
                  'and :entity_level = :object_id ' ||
                  'and :backing_doc_join_column = pod.req_distribution_id ' ||
                  'and porl.requisition_line_id = pord.requisition_line_id ' ||
                  'and nvl(fsp.req_encumbrance_flag, ''N'') = ''Y'' ' ||
                  'and nvl(pord.prevent_encumbrance_flag, ''N'') = ''N'' ' ||
                  'and porl.requisition_header_id = prh.requisition_header_id ' ||
                  'and nvl(:recreate_demand, ''Y'') = ''Y''';


    -- Substitute the tokens

    if g_pomode = 'RESERVE' then

      l_stmt := replace(l_stmt, ':dr_quantity', 'pod.quantity_ordered');
      l_stmt := replace(l_stmt, ':cr_quantity', '0');
      l_stmt := replace(l_stmt, ':encumbrance_state', 'N');
      l_stmt := replace(l_stmt, ':cancel_state', 'N');

      l_bstmt := replace(l_bstmt, ':dr_quantity', '0');
      l_bstmt := replace(l_bstmt, ':cr_quantity', 'pord.req_line_quantity');
      l_bstmt := replace(l_bstmt, ':backing_doc_join_column', 'pord.distribution_id');
      l_bstmt := replace(l_bstmt, ':encumbrance_state', 'N');
      l_bstmt := replace(l_bstmt, ':cancel_state', 'N');

    elsif g_pomode = 'REVERSE' then

      l_stmt := replace(l_stmt, ':dr_quantity', '-(decode(nvl(poll.accrue_on_receipt_flag, ''N''), ''N'', (pod.quantity_ordered - nvl(pod.quantity_billed, 0)), ''Y'', (pod.quantity_ordered - nvl(pod.quantity_delivered, 0))))');
      l_stmt := replace(l_stmt, ':cr_quantity', '0');
      l_stmt := replace(l_stmt, ':encumbrance_state', 'Y');
      l_stmt := replace(l_stmt, ':cancel_state', 'I');

      l_bstmt := replace(l_bstmt, ':dr_quantity', '0');
      l_bstmt := replace(l_bstmt, ':cr_quantity',
			'poll.price_override / porl.unit_price * -(decode(nvl(poll.accrue_on_receipt_flag, ''N''), ''N'',
			(pod.quantity_ordered - nvl(pod.quantity_billed, 0)), ''Y'',
			(pod.quantity_ordered - nvl(pod.quantity_delivered, 0))))');
      l_bstmt := replace(l_bstmt, ':backing_doc_join_column', 'pord.source_req_distribution_id');
      l_bstmt := replace(l_bstmt, ':encumbrance_state', 'Y');
      l_bstmt := replace(l_bstmt, ':cancel_state', 'I');

    elsif g_pomode = 'LIQUIDATE' then

      l_stmt := replace(l_stmt, ':dr_quantity', '0');
      l_stmt := replace(l_stmt, ':cr_quantity', 'greatest(decode(nvl(poll.accrue_on_receipt_flag, ''N''), ''N'', (pod.quantity_ordered - nvl(pod.quantity_billed, 0)), ''Y'', (pod.quantity_ordered - nvl(pod.quantity_delivered, 0))), 0)');
      l_stmt := replace(l_stmt, ':encumbrance_state', 'Y');
      l_stmt := replace(l_stmt, ':cancel_state', 'N');

      l_bstmt := replace(l_bstmt, ':dr_quantity', '0');
      l_bstmt := replace(l_bstmt, ':cr_quantity', '0');
      l_bstmt := replace(l_bstmt, ':backing_doc_join_column', 'pord.distribution_id');
      l_bstmt := replace(l_bstmt, ':encumbrance_state', 'Y');
      l_bstmt := replace(l_bstmt, ':cancel_state', 'N');

    elsif g_pomode = 'REJECT' then

      l_stmt := replace(l_stmt, ':dr_quantity', '0');
      l_stmt := replace(l_stmt, ':cr_quantity', '(decode(nvl(poll.approved_flag, ''N''), ''Y'', 0, ''N'', 0, ''R'', (decode(nvl(poll.quantity_received, 0), 0, (decode(nvl(poll.quantity_billed, 0), 0, pod.quantity_ordered, 0)), 0))))');
      l_stmt := replace(l_stmt, ':encumbrance_state', 'Y');
      l_stmt := replace(l_stmt, ':cancel_state', 'N');

      l_bstmt := replace(l_bstmt, ':dr_quantity', '(decode(nvl(poll.approved_flag, ''N''), ''Y'', 0, ''N'', 0, ''R'', (decode(nvl(poll.quantity_received, 0), 0, (decode(nvl(poll.quantity_billed, 0), 0, pord.req_line_quantity, 0)), 0))))');
      l_bstmt := replace(l_bstmt, ':cr_quantity', '0');
      l_bstmt := replace(l_bstmt, ':backing_doc_join_column', 'pord.distribution_id');
      l_bstmt := replace(l_bstmt, ':encumbrance_state', 'Y');
      l_bstmt := replace(l_bstmt, ':cancel_state', 'N');

    end if;

    if g_fclevel = 'DISTRIBUTION' then

      l_stmt := replace(l_stmt, ':entity_level', 'pod.po_distribution_id');
      l_bstmt := replace(l_bstmt, ':entity_level', 'pod.po_distribution_id');

    elsif g_fclevel = 'SHIPMENT' then

      l_stmt := replace(l_stmt, ':entity_level', 'poll.line_location_id');
      l_bstmt := replace(l_bstmt, ':entity_level', 'poll.line_location_id');

    elsif g_fclevel = 'LINE' then

      l_stmt := replace(l_stmt, ':entity_level', 'poll.po_line_id');
      l_bstmt := replace(l_bstmt, ':entity_level', 'poll.po_line_id');

    elsif g_fclevel = 'HEADER' then

      l_stmt := replace(l_stmt, ':entity_level', 'poll.po_release_id');
      l_bstmt := replace(l_bstmt, ':entity_level', 'poll.po_release_id');

    end if;

    g_sql_insert := g_sql_insert ||
                    l_stmt || ' UNION ALL ' ||
                    l_bstmt;

    return(TRUE);

  END po_fc_selblnkrel;

/* ----------------------------------------------------------------------- */

  -- Build Select Statement for Scheduled Release backed by a Planned PO

  -- Status Code is 'P' for Pending Funds Reservation and 'C' for Pending
  -- Funds Check

  -- Round the Entered Amounts to the precision of the Currency that they
  -- are in because the Unit Price could be specified with a larger precision

  FUNCTION po_fc_selschrel RETURN BOOLEAN IS

    l_stmt   VARCHAR2(4500);
    l_bstmt  VARCHAR2(4500);

  BEGIN

    l_stmt := 'select :packet_id, ' ||
                     'glsob.set_of_books_id, ' ||
                     '''Purchasing'', ' ||
                     '''Purchases'', ' ||
                     'prd.budget_account_id, ' ||
                     '''E'', ' ||
                     'glp.period_name, ' ||
                     'glp.period_year, ' ||
                     'glp.period_num, ' ||
                     'glp.quarter_num, ' ||
                     'glsob.currency_code, ' ||
                     ':status_code, ' ||
                     'sysdate, ' ||
                     ':user_id, ' ||
                     'null, ' ||
                     'fsp.purch_encumbrance_type_id, ' ||
                     'decode(doc_cur.minimum_accountable_unit, null, ' ||
                            'round((prll.price_override +  ' ||
                            'po_tax_sv.get_tax(''RELEASE'',PRD.po_distribution_id)'||
                            '/ PRD.quantity_ordered) * :dr_quantity ' ||
                            ', doc_cur.precision) * nvl(prd.rate, 1) , ' ||
                            'round((prll.price_override  + ' ||
                            'po_tax_sv.get_tax(''RELEASE'',PRD.po_distribution_id)'||
                            '/ PRD.quantity_ordered) * :dr_quantity' ||
                            ' / doc_cur.minimum_accountable_unit)  ' ||
                            ' * doc_cur.minimum_accountable_unit' ||
                            ' * nvl(prd.rate, 1) ), ' ||
                     'decode(doc_cur.minimum_accountable_unit, null, ' ||
                            'round((prll.price_override +  ' ||
                            'po_tax_sv.get_tax(''RELEASE'',PRD.po_distribution_id)'||
                            '/ PRD.quantity_ordered) * :cr_quantity ' ||
                            ', doc_cur.precision) * nvl(prd.rate, 1) , ' ||
                            'round((prll.price_override  + ' ||
                            'po_tax_sv.get_tax(''RELEASE'',PRD.po_distribution_id)'||
                            '/ PRD.quantity_ordered) * :cr_quantity' ||
                            ' / doc_cur.minimum_accountable_unit)  ' ||
                            ' * doc_cur.minimum_accountable_unit' ||
                            ' * nvl(prd.rate, 1) ), ' ||
                     'decode(doc_cur.minimum_accountable_unit, null, ' ||
                            'round((prll.price_override +  ' ||
                            'po_tax_sv.get_tax(''RELEASE'',PRD.po_distribution_id)'||
                            '/ PRD.quantity_ordered) * :dr_quantity ' ||
                            ', doc_cur.precision) * nvl(prd.rate, 1) , ' ||
                            'round((prll.price_override  + ' ||
                            'po_tax_sv.get_tax(''RELEASE'',PRD.po_distribution_id)'||
                            '/ PRD.quantity_ordered) * :dr_quantity' ||
                            ' / doc_cur.minimum_accountable_unit)  ' ||
                            ' * doc_cur.minimum_accountable_unit' ||
                            ' * nvl(prd.rate, 1) ), ' ||
                     'decode(doc_cur.minimum_accountable_unit, null, ' ||
                            'round((prll.price_override +  ' ||
                            'po_tax_sv.get_tax(''RELEASE'',PRD.po_distribution_id)'||
                            '/ PRD.quantity_ordered) * :cr_quantity ' ||
                            ', doc_cur.precision) * nvl(prd.rate, 1) , ' ||
                            'round((prll.price_override  + ' ||
                            'po_tax_sv.get_tax(''RELEASE'',PRD.po_distribution_id)'||
                            '/ PRD.quantity_ordered) * :cr_quantity' ||
                            ' / doc_cur.minimum_accountable_unit)  ' ||
                            ' * doc_cur.minimum_accountable_unit' ||
                            ' * nvl(prd.rate, 1) ), ' ||
                     'prd.ussgl_transaction_code, ' ||
                     '''PO'', ' ||
                     'prll.po_header_id, ' ||
                     'prd.po_distribution_id, ' ||
                     'poh.segment1, ' ||
                     'decode(pod.req_distribution_id, null, null, ' ||
                            'prh.segment1), ' ||
                     'substr(pol.item_description, 1, 40) ' ||
                'from gl_periods glp, ' ||
                     'gl_sets_of_books glsob, ' ||
                     'financials_system_parameters fsp, ' ||
                     'fnd_currencies doc_cur, ' ||
                     'po_distributions prd, ' ||
                     'po_line_locations prll, ' ||
                     'po_lines pol, ' ||
                     'po_headers poh, ' ||
                     'po_releases por, ' ||
                     'po_distributions pod, ' ||
                     'po_requisition_headers prh, ' ||
                     'po_requisition_lines porl, ' ||
                     'po_req_distributions pord ' ||
               'where glsob.set_of_books_id = fsp.set_of_books_id ' ||
                 'and glp.period_set_name = glsob.period_set_name ' ||
                 'and glp.period_name = nvl(:override_period, prd.gl_encumbered_period_name) ' ||
                 'and doc_cur.currency_code = poh.currency_code ' ||
                 'and prll.po_release_id = por.po_release_id ' ||
                 'and por.po_header_id = poh.po_header_id ' ||
                 'and prll.shipment_type = ''SCHEDULED'' ' ||
                 'and prd.line_location_id = prll.line_location_id ' ||
                 'and prd.po_line_id = pol.po_line_id ' ||
                 'and nvl(prd.encumbered_flag, ''N'') = '':encumbrance_state'' ' ||
                 'and nvl(prll.cancel_flag, ''N'') = '':cancel_state'' ' ||
                 'and nvl(prd.prevent_encumbrance_flag, ''N'') = ''N'' ' ||
                 'and :entity_level = :object_id ' ||
                 'and prd.source_distribution_id = pod.po_distribution_id(+) ' ||
                 'and pod.req_distribution_id = pord.distribution_id(+) ' ||
                 'and pord.requisition_line_id = porl.requisition_line_id(+) ' ||
                 'and porl.requisition_header_id = prh.requisition_header_id (+)';


    -- Statement to recreate Planned PO Encumbrances

    l_bstmt := 'select :packet_id, ' ||
                      'glsob.set_of_books_id, ' ||
                      '''Purchasing'', ' ||
                      '''Purchases'', ' ||
                      'pod.budget_account_id, ' ||
                      '''E'', ' ||
                      'glp.period_name, ' ||
                      'glp.period_year, ' ||
                      'glp.period_num, ' ||
                      'glp.quarter_num, ' ||
                      'glsob.currency_code, ' ||
                      ':status_code, ' ||
                      'sysdate, ' ||
                      ':user_id, ' ||
                      'null, ' ||
                      'fsp.purch_encumbrance_type_id, ' ||
                     'decode(doc_cur.minimum_accountable_unit, null, ' ||
                            'round((poll.price_override +  ' ||
                            'po_tax_sv.get_tax(''PO'',POD.po_distribution_id)'||
                            '/ POD.quantity_ordered) * :dr_quantity ' ||
                            ', doc_cur.precision) * nvl(pod.rate, 1) , ' ||
                            'round((poll.price_override  + ' ||
                            'po_tax_sv.get_tax(''PO'',POD.po_distribution_id)'||
                            '/ POD.quantity_ordered) * :dr_quantity' ||
                            ' / doc_cur.minimum_accountable_unit)  ' ||
                            ' * doc_cur.minimum_accountable_unit' ||
                            ' * nvl(pod.rate, 1) ), ' ||
                     'decode(doc_cur.minimum_accountable_unit, null, ' ||
                            'round((poll.price_override +  ' ||
                            'po_tax_sv.get_tax(''PO'',POD.po_distribution_id)'||
                            '/ POD.quantity_ordered) * :cr_quantity ' ||
                            ', doc_cur.precision) * nvl(pod.rate, 1) , ' ||
                            'round((poll.price_override  + ' ||
                            'po_tax_sv.get_tax(''PO'',POD.po_distribution_id)'||
                            '/ POD.quantity_ordered) * :cr_quantity' ||
                            ' / doc_cur.minimum_accountable_unit)  ' ||
                            ' * doc_cur.minimum_accountable_unit' ||
                            ' * nvl(pod.rate, 1) ), ' ||
                     'decode(doc_cur.minimum_accountable_unit, null, ' ||
                            'round((poll.price_override +  ' ||
                            'po_tax_sv.get_tax(''PO'',POD.po_distribution_id)'||
                            '/ POD.quantity_ordered) * :dr_quantity ' ||
                            ', doc_cur.precision) * nvl(pod.rate, 1) , ' ||
                            'round((poll.price_override  + ' ||
                            'po_tax_sv.get_tax(''PO'',POD.po_distribution_id)'||
                            '/ POD.quantity_ordered) * :dr_quantity' ||
                            ' / doc_cur.minimum_accountable_unit)  ' ||
                            ' * doc_cur.minimum_accountable_unit' ||
                            ' * nvl(pod.rate, 1) ), ' ||
                     'decode(doc_cur.minimum_accountable_unit, null, ' ||
                            'round((poll.price_override +  ' ||
                            'po_tax_sv.get_tax(''PO'',POD.po_distribution_id)'||
                            '/ POD.quantity_ordered) * :cr_quantity ' ||
                            ', doc_cur.precision) * nvl(pod.rate, 1) , ' ||
                            'round((poll.price_override  + ' ||
                            'po_tax_sv.get_tax(''PO'',POD.po_distribution_id)'||
                            '/ POD.quantity_ordered) * :cr_quantity' ||
                            ' / doc_cur.minimum_accountable_unit)  ' ||
                            ' * doc_cur.minimum_accountable_unit' ||
                            ' * nvl(pod.rate, 1) ), ' ||
                      'pod.ussgl_transaction_code, ' ||
                      '''PO'', ' ||
                      'poll.po_header_id, ' ||
                      'pod.po_distribution_id, ' ||
                      'poh.segment1, ' ||
                      'decode(pod.req_distribution_id, null, null, ' ||
                             'prh.segment1), ' ||
                      'substr(porl.item_description, 1, 40) ' ||
                 'from gl_periods glp, ' ||
                      'gl_sets_of_books glsob, ' ||
                      'financials_system_parameters fsp, ' ||
                      'fnd_currencies doc_cur, ' ||
                      'po_distributions prd, ' ||
                      'po_line_locations prll, ' ||
                      'po_lines pol, ' ||
                      'po_headers poh, ' ||
                      'po_releases por, ' ||
                      'po_distributions pod, ' ||
                      'po_line_locations poll, ' ||
                      'po_requisition_headers prh, ' ||
                      'po_requisition_lines porl, ' ||
                      'po_req_distributions pord ' ||
                'where glsob.set_of_books_id = fsp.set_of_books_id ' ||
                  'and glp.period_set_name = glsob.period_set_name ' ||
                  'and glp.period_name = nvl(:override_period, pod.gl_encumbered_period_name) ' ||
                  'and doc_cur.currency_code = poh.currency_code ' ||
                  'and prll.po_release_id = por.po_release_id ' ||
                  'and por.po_header_id = poh.po_header_id ' ||
                  'and prll.shipment_type = ''SCHEDULED'' ' ||
                  'and prd.line_location_id = prll.line_location_id ' ||
                  'and nvl(prd.encumbered_flag, ''N'') = '':encumbrance_state'' ' ||
                  'and nvl(prll.cancel_flag, ''N'') = '':cancel_state'' ' ||
                  'and nvl(prd.prevent_encumbrance_flag, ''N'') = ''N'' ' ||
                  'and :entity_level = :object_id ' ||
                  'and pod.po_distribution_id = prd.source_distribution_id ' ||
                  'and poll.line_location_id = pod.line_location_id ' ||
                  'and pol.po_line_id = pod.po_line_id ' ||
                  'and pod.req_distribution_id = pord.distribution_id(+) ' ||
                  'and pord.requisition_line_id = porl.requisition_line_id(+) ' ||
                  'and porl.requisition_header_id = prh.requisition_header_id (+)';


    -- Substitute the tokens

    if g_pomode = 'RESERVE' then

      l_stmt := replace(l_stmt, ':dr_quantity', 'prd.quantity_ordered');
      l_stmt := replace(l_stmt, ':cr_quantity', '0');
      l_stmt := replace(l_stmt, ':encumbrance_state', 'N');
      l_stmt := replace(l_stmt, ':cancel_state', 'N');

      l_bstmt := replace(l_bstmt, ':dr_quantity', '0');
      l_bstmt := replace(l_bstmt, ':cr_quantity', 'prd.quantity_ordered');
      l_bstmt := replace(l_bstmt, ':encumbrance_state', 'N');
      l_bstmt := replace(l_bstmt, ':cancel_state', 'N');

    elsif g_pomode = 'REVERSE' then

      l_stmt := replace(l_stmt, ':dr_quantity', '-(decode(nvl(prll.accrue_on_receipt_flag, ''N''), ''N'', (prd.quantity_ordered - nvl(prd.quantity_billed, 0)), ''Y'', (prd.quantity_ordered - nvl(prd.quantity_delivered, 0))))');
      l_stmt := replace(l_stmt, ':cr_quantity', '0');
      l_stmt := replace(l_stmt, ':encumbrance_state', 'Y');
      l_stmt := replace(l_stmt, ':cancel_state', 'I');

      l_bstmt := replace(l_bstmt, ':dr_quantity', '0');
      l_bstmt := replace(l_stmt, ':cr_quantity', '-(decode(nvl(prll.accrue_on_receipt_flag, ''N''), ''N'', (prd.quantity_ordered - nvl(prd.quantity_billed, 0)), ''Y'', (prd.quantity_ordered - nvl(prd.quantity_delivered, 0))))');
      l_bstmt := replace(l_bstmt, ':encumbrance_state', 'Y');
      l_bstmt := replace(l_bstmt, ':cancel_state', 'I');

    elsif g_pomode = 'LIQUIDATE' then

      l_stmt := replace(l_stmt, ':dr_quantity', '0');
      l_stmt := replace(l_stmt, ':cr_quantity', 'greatest(decode(nvl(prll.accrue_on_receipt_flag, ''N''), ''N'', (prd.quantity_ordered - nvl(prd.quantity_billed, 0)), ''Y'', (prd.quantity_ordered - nvl(prd.quantity_delivered, 0))), 0)');
      l_stmt := replace(l_stmt, ':encumbrance_state', 'Y');
      l_stmt := replace(l_stmt, ':cancel_state', 'N');

      l_bstmt := replace(l_bstmt, ':dr_quantity', '0');
      l_bstmt := replace(l_bstmt, ':cr_quantity', '0');
      l_bstmt := replace(l_bstmt, ':encumbrance_state', 'Y');
      l_bstmt := replace(l_bstmt, ':cancel_state', 'N');

    elsif g_pomode = 'REJECT' then

      l_stmt := replace(l_stmt, ':dr_quantity', '0');
      l_stmt := replace(l_stmt, ':cr_quantity', 'decode(nvl(prll.approved_flag, ''N''), ''Y'', 0, ''N'', 0, ''R'', (decode(nvl(prll.quantity_received, 0), 0, (decode(nvl(prll.quantity_billed, 0), 0, prd.quantity_ordered, 0)), 0)))');
      l_stmt := replace(l_stmt, ':encumbrance_state', 'Y');
      l_stmt := replace(l_stmt, ':cancel_state', 'N');

      l_bstmt := replace(l_stmt, ':dr_quantity', 'decode(nvl(prll.approved_flag, ''N''), ''Y'', 0, ''N'', 0, ''R'', (decode(nvl(prll.quantity_received, 0), 0, (decode(nvl(prll.quantity_billed, 0), 0, prd.quantity_ordered, 0)), 0)))');
      l_bstmt := replace(l_bstmt, ':cr_quantity', '0');
      l_bstmt := replace(l_bstmt, ':encumbrance_state', 'Y');
      l_bstmt := replace(l_bstmt, ':cancel_state', 'N');

    end if;

    if g_fclevel = 'DISTRIBUTION' then

      l_stmt := replace(l_stmt, ':entity_level', 'prd.po_distribution_id');
      l_bstmt := replace(l_bstmt, ':entity_level', 'prd.po_distribution_id');

    elsif g_fclevel = 'SHIPMENT' then

      l_stmt := replace(l_stmt, ':entity_level', 'prll.line_location_id');
      l_bstmt := replace(l_bstmt, ':entity_level', 'prll.line_location_id');

    elsif g_fclevel = 'LINE' then

      l_stmt := replace(l_stmt, ':entity_level', 'prll.po_line_id');
      l_bstmt := replace(l_bstmt, ':entity_level', 'prll.po_line_id');

    elsif g_fclevel = 'HEADER' then

      l_stmt := replace(l_stmt, ':entity_level', 'prll.po_release_id');
      l_bstmt := replace(l_bstmt, ':entity_level', 'prll.po_release_id');

    end if;

    g_sql_insert := g_sql_insert ||
                    l_stmt || ' UNION ALL ' ||
                    l_bstmt;

    return(TRUE);

  END po_fc_selschrel;

/* ----------------------------------------------------------------------- */

  -- Insert into the Funds Checker queue

  FUNCTION po_fc_run(p_packetid IN OUT NOCOPY NUMBER) RETURN BOOLEAN IS

    l_objectid  NUMBER;
    l_userid    NUMBER;
    l_status    VARCHAR2(1);

    cur_insert  INTEGER;
    num_insert  INTEGER;

    cursor pkt_id is
      select gl_bc_packets_s.nextval
        from dual;

  BEGIN

    if g_fclevel = 'DISTRIBUTION' then

      l_objectid := g_distid;

    elsif g_fclevel = 'SHIPMENT' then

      l_objectid := g_shipid;

    elsif g_fclevel = 'LINE' then

      l_objectid := g_lineid;

    elsif g_fclevel = 'HEADER' then

      l_objectid := g_docid;

    end if;


    -- Get User ID

   g_userid := FND_GLOBAL.USER_ID;

/* DEBUG    g_userid := 1; */

    if g_userid = -1 then

      PO_MESSAGE_S.APP_ERROR(error_name => 'PO_ALL_TRACE_ERROR_WITH_MSG',
                             token1 => 'FILE',
                             value1 => 'PO_FUNDS_CHECKER',
                             token2 => 'ERR_NUMBER',
                             value2 => '110',
                             token3 => 'SUBROUTINE',
                             value3 => 'PO_FC_RUN()',
                             token4 => 'ERROR_MSG',
                             value4 => 'CANNOT GET USER ID');
      return(FALSE);

    end if;


    -- Get Login ID

-- FRKHAN: BUG 747290 Get concurrent login id
-- if there is one else get login id

    IF NVL(g_conc_flag,'N') = 'Y' THEN
       g_loginid := FND_GLOBAL.CONC_LOGIN_ID;
    ELSE
       g_loginid := FND_GLOBAL.LOGIN_ID;
    END IF;

/* DEBUG    g_loginid := 1; */


    if g_loginid = -1 then

      PO_MESSAGE_S.APP_ERROR(error_name => 'PO_ALL_TRACE_ERROR_WITH_MSG',
                             token1 => 'FILE',
                             value1 => 'PO_FUNDS_CHECKER',
                             token2 => 'ERR_NUMBER',
                             value2 => '115',
                             token3 => 'SUBROUTINE',
                             value3 => 'PO_FC_RUN()',
                             token4 => 'ERROR_MSG',
                             value4 => 'CANNOT GET LAST LOGIN ID');
      return(FALSE);

    end if;

    if g_action = 'CHECK FUNDS' then
      l_status := 'C';
      -- dbms_output.put_line('c');
    else
      l_status := 'P';
      -- dbms_output.put_line('p');
    end if;


    -- Get Packet ID

    open pkt_id;

    fetch pkt_id
     into g_packetid;

    close pkt_id;


    -- Execute the Dynamic SQL Insert Statement

    -- dbms_output.put_line('build dynamic sql');

    cur_insert := dbms_sql.open_cursor;
    dbms_sql.parse(cur_insert, g_sql_insert, dbms_sql.v7);

    dbms_sql.bind_variable(cur_insert, 'packet_id', g_packetid);
    dbms_sql.bind_variable(cur_insert, 'status_code', l_status);
    dbms_sql.bind_variable(cur_insert, 'user_id', g_userid);
    dbms_sql.bind_variable(cur_insert, 'override_period', g_override_period);
    dbms_sql.bind_variable(cur_insert, 'object_id', l_objectid);

    if INSTR(g_sql_insert, ':recreate_demand', 1) > 0 then
      dbms_sql.bind_variable(cur_insert, 'recreate_demand', g_recreate_demand);
    end if;

   -- dbms_output.put_line('before execute of sql statement'||cur_insert);

    num_insert := dbms_sql.execute(cur_insert);
    dbms_sql.close_cursor(cur_insert);

    -- dbms_output.put_line('inserted'||num_insert||' records in gl_bc');

    -- FRKHAN bug 941171
    IF LENGTH (g_dbug) < x_max_length THEN
       g_dbug := g_dbug ||
             'Inserted ' || num_insert || ' Records into gl_bc_packets' ||
              g_delim;
    END IF;
    p_packetid := g_packetid;

    return(TRUE);


  EXCEPTION

    WHEN OTHERS THEN

      -- dbms_output.put_line('exception handler');

      if pkt_id%ISOPEN then
        close pkt_id;
      end if;

      if dbms_sql.is_open(cur_insert) then
        dbms_sql.close_cursor(cur_insert);
      end if;

      PO_MESSAGE_S.SQL_ERROR(routine => 'PO_FUNDS_CHECKER',
                             location => '120',
                             error_code => SQLCODE);

      return(FALSE);

  END po_fc_run;

/* ----------------------------------------------------------------------- */

  -- Rollup encumbered_flag on the Distributions to po_line_locations and
  -- po_requisition_lines

  FUNCTION po_rollup_enc RETURN BOOLEAN IS

  BEGIN

    if g_doctyp = 'REQUISITION' then

      if not po_rollup_req then

        PO_MESSAGE_S.APP_ERROR(error_name => 'PO_ALL_TRACE_ERROR',
                               token1 => 'FILE',
                               value1 => 'PO_FUNDS_CHECKER',
                               token2 => 'ERR_NUMBER',
                               value2 => '125',
                               token3 => 'SUBROUTINE',
                               value3 => 'PO_ROLLUP_ENC()');
        return(FALSE);

      end if;

    elsif g_doctyp = 'PO' then

      if not po_rollup_po then

        PO_MESSAGE_S.APP_ERROR(error_name => 'PO_ALL_TRACE_ERROR',
                               token1 => 'FILE',
                               value1 => 'PO_FUNDS_CHECKER',
                               token2 => 'ERR_NUMBER',
                               value2 => '130',
                               token3 => 'SUBROUTINE',
                               value3 => 'PO_ROLLUP_ENC()');
        return(FALSE);

      end if;

    elsif g_doctyp = 'RELEASE' then

      if g_docsubtyp = 'BLANKET' then

        if not po_rollup_blnkrel then

          PO_MESSAGE_S.APP_ERROR(error_name => 'PO_ALL_TRACE_ERROR',
                                 token1 => 'FILE',
                                 value1 => 'PO_FUNDS_CHECKER',
                                 token2 => 'ERR_NUMBER',
                                 value2 => '135',
                                 token3 => 'SUBROUTINE',
                                 value3 => 'PO_ROLLUP_ENC()');
          return(FALSE);

        end if;

      elsif g_docsubtyp = 'SCHEDULED' then

        if not po_rollup_schrel then

          PO_MESSAGE_S.APP_ERROR(error_name => 'PO_ALL_TRACE_ERROR',
                                 token1 => 'FILE',
                                 value1 => 'PO_FUNDS_CHECKER',
                                 token2 => 'ERR_NUMBER',
                                 value2 => '140',
                                 token3 => 'SUBROUTINE',
                                 value3 => 'PO_ROLLUP_ENC()');
          return(FALSE);

        end if;

      else

        PO_MESSAGE_S.APP_ERROR(error_name => 'PO_ALL_TRACE_ERROR',
                               token1 => 'FILE',
                               value1 => 'PO_FUNDS_CHECKER',
                               token2 => 'ERR_NUMBER',
                               value2 => '145',
                               token3 => 'SUBROUTINE',
                               value3 => 'PO_ROLLUP_ENC()');
        return(FALSE);

      end if;

    else

      PO_MESSAGE_S.APP_ERROR(error_name => 'PO_ALL_TRACE_ERROR',
                             token1 => 'FILE',
                             value1 => 'PO_FUNDS_CHECKER',
                             token2 => 'ERR_NUMBER',
                             value2 => '150',
                             token3 => 'SUBROUTINE',
                             value3 => 'PO_ROLLUP_ENC()');
      return(FALSE);

    end if;

    return(TRUE);

  END po_rollup_enc;

/* ----------------------------------------------------------------------- */

  -- Rollup encumbered_flag for Requisitions

  FUNCTION po_rollup_req RETURN BOOLEAN IS

  BEGIN

    -- Preset encumbered_flag to 'Y' if Action is 'RESERVE', to 'N' if
    -- Action is 'REVERSE' or 'LIQUIDATE'

    if g_fclevel = 'HEADER' then

      update po_req_distributions
         set encumbered_flag = decode(g_fcmode, 'RESERVE', 'Y', 'N')
       where requisition_line_id in
            (select porl.requisition_line_id
               from po_requisition_lines porl
              where porl.requisition_header_id = g_docid
                and porl.line_location_id is null);
    -- FRKHAN bug 941171
    IF LENGTH (g_dbug) < x_max_length THEN
       g_dbug := g_dbug ||
               'Rolled up Encumbrance Flag for ' || SQL%ROWCOUNT || ' Requisitions' || g_delim;
    END IF;
    elsif g_fclevel = 'LINE' then

      update po_req_distributions
         set encumbered_flag = decode(g_fcmode, 'RESERVE', 'Y', 'N')
       where requisition_line_id = g_lineid;

    -- FRKHAN bug 941171
       IF LENGTH (g_dbug) < x_max_length THEN
          g_dbug := g_dbug ||
               'Rolled up Encumbrance Flag for ' || SQL%ROWCOUNT || ' Requisitions' || g_delim;
       END IF;
    end if;


    -- Update Distributions with Funds Check Results

    if not po_fc_dist then

      PO_MESSAGE_S.APP_ERROR(error_name => 'PO_ALL_TRACE_ERROR',
                             token1 => 'FILE',
                             value1 => 'PO_FUNDS_CHECKER',
                             token2 => 'ERR_NUMBER',
                             value2 => '155',
                             token3 => 'SUBROUTINE',
                             value3 => 'PO_ROLLUP_REQ()');
      return(FALSE);

    end if;


    -- Rollup Encumbrance State to Requisition Lines

    update po_requisition_lines porl
       set encumbered_flag =
          (select decode(count(pord.distribution_id), 0, 'Y', 'N')
             from po_req_distributions pord
            where pord.requisition_line_id = porl.requisition_line_id
              and pord.encumbered_flag = 'N')
     where porl.requisition_header_id = g_docid;
    -- FRKHAN bug 941171
    IF LENGTH (g_dbug) < x_max_length THEN
       g_dbug := g_dbug ||
               'Rolled up Encumbrance Flag for ' || SQL%ROWCOUNT || ' Requisition Lines' || g_delim;
    END IF;
    return(TRUE);


  EXCEPTION

    WHEN OTHERS THEN

      PO_MESSAGE_S.SQL_ERROR(routine => 'PO_FUNDS_CHECKER',
                             location => '160',
                             error_code => SQLCODE);

      return(FALSE);

  END po_rollup_req;

/* ----------------------------------------------------------------------- */

  -- Rollup encumbered_flag for PO

  FUNCTION po_rollup_po RETURN BOOLEAN IS

  BEGIN

    if g_fclevel = 'HEADER' then

      -- Preset encumbered_flag on Main Doc

      update po_distributions
         set encumbered_flag = decode(g_pomode, 'RESERVE', 'Y', 'REVERSE', 'N',
                                      'LIQUIDATE', 'N', 'REJECT',
                                      encumbered_flag, 'N')
       where po_header_id = g_docid;


      -- Preset encumbered_flag on Backing Doc

      if g_pomode in ('RESERVE', 'LIQUIDATE', 'REJECT') then

        update po_req_distributions
           set encumbered_flag = decode(g_pomode, 'RESERVE', 'N',
                                        'REVERSE', 'Y', encumbered_flag)
         where distribution_id in
              (select req_distribution_id
                 from po_distributions
                where po_header_id = g_docid);

      else

        if g_recreate_demand = 'Y' then

          update po_req_distributions
             set encumbered_flag = decode(g_pomode, 'RESERVE', 'N',
                                          'REVERSE', 'Y', encumbered_flag)
           where source_req_distribution_id in
                (select req_distribution_id
                   from po_distributions
                  where po_header_id = g_docid);

        end if;

      end if;

    elsif g_fclevel = 'LINE' then

      -- Preset encumbered_flag on Main Doc

      update po_distributions
         set encumbered_flag = decode(g_pomode, 'RESERVE', 'Y', 'REVERSE', 'N',
                                      'LIQUIDATE', 'N', 'REJECT',
                                      encumbered_flag, 'N')
       where po_line_id = g_lineid;


      -- Preset encumbered_flag on Backing Doc

      if g_pomode in ('RESERVE', 'LIQUIDATE', 'REJECT') then

        update po_req_distributions
           set encumbered_flag = decode(g_pomode, 'RESERVE', 'N',
                                        'REVERSE', 'Y', encumbered_flag)
         where distribution_id in
              (select req_distribution_id
                 from po_distributions
                where po_line_id = g_lineid);

      else

        if g_recreate_demand = 'Y' then

          update po_req_distributions
             set encumbered_flag = decode(g_pomode, 'RESERVE', 'N',
                                          'REVERSE', 'Y', encumbered_flag)
           where source_req_distribution_id in
                (select req_distribution_id
                   from po_distributions
                  where po_line_id = g_lineid);

        end if;

      end if;

    elsif g_fclevel = 'SHIPMENT' then

      -- Preset encumbered_flag on Main Doc

      update po_distributions
         set encumbered_flag = decode(g_pomode, 'RESERVE', 'Y', 'REVERSE', 'N',
                                      'LIQUIDATE', 'N', 'REJECT',
                                      encumbered_flag, 'N')
       where line_location_id = g_shipid;


      -- Preset encumbered_flag on Backing Doc

      if g_pomode in ('RESERVE', 'LIQUIDATE', 'REJECT') then

        update po_req_distributions
           set encumbered_flag = decode(g_pomode, 'RESERVE', 'N',
                                        'REVERSE', 'Y', encumbered_flag)
         where distribution_id in
              (select req_distribution_id
                 from po_distributions
                where line_location_id = g_shipid);

      else

        if g_recreate_demand = 'Y' then

          update po_req_distributions
             set encumbered_flag = decode(g_pomode, 'RESERVE', 'N',
                                          'REVERSE', 'Y', encumbered_flag)
           where source_req_distribution_id in
                (select req_distribution_id
                   from po_distributions
                  where line_location_id = g_shipid);

        end if;

      end if;

    end if;


    -- Update Distributions with Funds Check Results

    if not po_fc_dist then

      PO_MESSAGE_S.APP_ERROR('PO_ALL_TRACE_ERROR',
                             'FILE', 'PO_FUNDS_CHECKER',
                             'ERR_NUMBER', '165',
                             'SUBROUTINE', 'PO_ROLLUP_PO()');
      return(FALSE);

    end if;


    -- Rollup to Line Locations

    update po_line_locations poll
       set encumbered_flag =
          (select decode(count(pod.po_distribution_id), 0, 'Y', 'N')
             from po_distributions pod
            where pod.line_location_id = poll.line_location_id
              and pod.encumbered_flag = 'N')
     where poll.po_header_id = g_docid;


    -- Rollup to Requisition Lines on Backing Document

    if g_pomode in ('RESERVE', 'LIQUIDATE', 'REJECT') then

      update po_requisition_lines porl
         set encumbered_flag =
            (select decode(count(pord.distribution_id), 0, 'Y', 'N')
               from po_req_distributions pord
              where pord.requisition_line_id = porl.requisition_line_id
                and pord.encumbered_flag = 'N')
       where porl.requisition_line_id in
            (select prd.requisition_line_id
               from po_requisition_lines prl,
                    po_req_distributions prd,
                    po_distributions pod
              where prd.requisition_line_id = prl.requisition_line_id
                and prd.distribution_id = pod.req_distribution_id
                and pod.po_header_id = g_docid);

    else

      update po_requisition_lines porl
         set encumbered_flag =
            (select decode(count(pord.distribution_id), 0, 'Y', 'N')
               from po_req_distributions pord
              where pord.requisition_line_id = porl.requisition_line_id
                and pord.encumbered_flag = 'N')
       where porl.requisition_line_id in
            (select prd.requisition_line_id
               from po_requisition_lines prl,
                    po_req_distributions prd,
                    po_distributions pod
              where prd.requisition_line_id = prl.requisition_line_id
                and prd.source_req_distribution_id = pod.req_distribution_id
                and pod.po_header_id = g_docid);

    end if;

    return(TRUE);


  EXCEPTION

    WHEN OTHERS THEN

      PO_MESSAGE_S.SQL_ERROR(routine => 'PO_FUNDS_CHECKER',
                             location => '170',
                             error_code => SQLCODE);

      return(FALSE);

  END po_rollup_po;

/* ----------------------------------------------------------------------- */

  -- Rollup encumbered_flag for Blanket Release

  FUNCTION po_rollup_blnkrel RETURN BOOLEAN IS

  BEGIN

    if g_fclevel = 'HEADER' then

      -- Preset encumbered_flag on Main Doc

      update po_distributions
         set encumbered_flag = decode(g_pomode, 'RESERVE', 'Y', 'REVERSE', 'N',
                                      'LIQUIDATE', 'N', 'REJECT',
                                      encumbered_flag, 'N')
       where po_release_id = g_docid;


      -- Preset encumbered_flag on Backing Doc

      if g_pomode in ('RESERVE', 'LIQUIDATE', 'REJECT') then

        update po_req_distributions
           set encumbered_flag = decode(g_pomode, 'RESERVE', 'N',
                                        'REVERSE', 'Y', encumbered_flag)
         where distribution_id in
              (select req_distribution_id
                 from po_distributions
                where po_release_id = g_docid);

      else

        if g_recreate_demand = 'Y' then

          update po_req_distributions
             set encumbered_flag = decode(g_pomode, 'RESERVE', 'N',
                                          'REVERSE', 'Y', encumbered_flag)
           where source_req_distribution_id in
                (select req_distribution_id
                   from po_distributions
                  where po_release_id = g_docid);

        end if;

      end if;

    elsif g_fclevel = 'LINE' then

      -- Preset encumbered_flag on Main Doc

      update po_distributions
         set encumbered_flag = decode(g_pomode, 'RESERVE', 'Y', 'REVERSE', 'N',
                                      'LIQUIDATE', 'N', 'REJECT',
                                      encumbered_flag, 'N')
       where po_line_id = g_lineid;


      -- Preset encumbered_flag on Backing Doc

      if g_pomode in ('RESERVE', 'LIQUIDATE', 'REJECT') then

        update po_req_distributions
           set encumbered_flag = decode(g_pomode, 'RESERVE', 'N',
                                        'REVERSE', 'Y', encumbered_flag)
         where distribution_id in
              (select req_distribution_id
                 from po_distributions
                where po_line_id = g_lineid);

      else

        if g_recreate_demand = 'Y' then

          update po_req_distributions
             set encumbered_flag = decode(g_pomode, 'RESERVE', 'N',
                                          'REVERSE', 'Y', encumbered_flag)
           where source_req_distribution_id in
                (select req_distribution_id
                   from po_distributions
                  where po_line_id = g_lineid);

        end if;

      end if;

    elsif g_fclevel = 'SHIPMENT' then

      -- Preset encumbered_flag on Main Doc

      update po_distributions
         set encumbered_flag = decode(g_pomode, 'RESERVE', 'Y', 'REVERSE', 'N',
                                      'LIQUIDATE', 'N', 'REJECT',
                                      encumbered_flag, 'N')
       where line_location_id = g_shipid;


      -- Preset encumbered_flag on Backing Doc

      if g_pomode in ('RESERVE', 'LIQUIDATE', 'REJECT') then

        update po_req_distributions
           set encumbered_flag = decode(g_pomode, 'RESERVE', 'N',
                                        'REVERSE', 'Y', encumbered_flag)
         where distribution_id in
              (select req_distribution_id
                 from po_distributions
                where line_location_id = g_shipid);

      else

        if g_recreate_demand = 'Y' then

          update po_req_distributions
             set encumbered_flag = decode(g_pomode, 'RESERVE', 'N',
                                          'REVERSE', 'Y', encumbered_flag)
           where source_req_distribution_id in
                (select req_distribution_id
                   from po_distributions
                  where line_location_id = g_shipid);

        end if;

      end if;

    end if;


    -- Update Distributions with Funds Check Results

    if not po_fc_dist then

      PO_MESSAGE_S.APP_ERROR('PO_ALL_TRACE_ERROR',
                             'FILE', 'PO_FUNDS_CHECKER',
                             'ERR_NUMBER', '175',
                             'SUBROUTINE', 'PO_ROLLUP_BLNKREL()');
      return(FALSE);

    end if;


    -- Rollup to Line Locations

    update po_line_locations poll
       set encumbered_flag =
          (select decode(count(pod.po_distribution_id), 0, 'Y', 'N')
             from po_distributions pod
            where pod.line_location_id = poll.line_location_id
              and pod.encumbered_flag = 'N')
     where poll.po_release_id = g_docid;


    -- Rollup to Requisition Lines on Backing Document

    if g_pomode in ('RESERVE', 'LIQUIDATE', 'REJECT') then

      update po_requisition_lines porl
         set encumbered_flag =
            (select decode(count(pord.distribution_id), 0, 'Y', 'N')
               from po_req_distributions pord
              where pord.requisition_line_id = porl.requisition_line_id
                and pord.encumbered_flag = 'N')
       where porl.requisition_line_id in
            (select prd.requisition_line_id
               from po_requisition_lines prl,
                    po_req_distributions prd,
                    po_distributions pod
              where prd.requisition_line_id = prl.requisition_line_id
                and prd.distribution_id = pod.req_distribution_id
                and pod.po_release_id = g_docid);

    else

      update po_requisition_lines porl
         set encumbered_flag =
            (select decode(count(pord.distribution_id), 0, 'Y', 'N')
               from po_req_distributions pord
              where pord.requisition_line_id = porl.requisition_line_id
                and pord.encumbered_flag = 'N')
       where porl.requisition_line_id in
            (select prd.requisition_line_id
               from po_requisition_lines prl,
                    po_req_distributions prd,
                    po_distributions pod
              where prd.requisition_line_id = prl.requisition_line_id
                and prd.source_req_distribution_id = pod.req_distribution_id
                and pod.po_release_id = g_docid);

    end if;

    return(TRUE);


  EXCEPTION

    WHEN OTHERS THEN

      PO_MESSAGE_S.SQL_ERROR(routine => 'PO_FUNDS_CHECKER',
                             location => '180',
                             error_code => SQLCODE);

      return(FALSE);

  END po_rollup_blnkrel;

/* ----------------------------------------------------------------------- */

  -- Rollup encumbered_flag for Scheduled Release

  FUNCTION po_rollup_schrel RETURN BOOLEAN IS

  BEGIN

    if g_fclevel = 'HEADER' then

      -- Preset encumbered_flag on Main Doc

      update po_distributions
         set encumbered_flag = decode(g_pomode, 'RESERVE', 'Y', 'REVERSE', 'N',
                                      'LIQUIDATE', 'N', 'REJECT',
                                      encumbered_flag, 'N')
       where po_release_id = g_docid;


      -- Preset encumbered_flag on Backing Doc

      update po_distributions
         set encumbered_flag = decode(g_pomode, 'RESERVE', 'N',
                                      'REVERSE', 'Y', encumbered_flag)
       where po_distribution_id in
            (select po_distribution_id
               from po_distributions
              where po_release_id = g_docid);

    elsif g_fclevel = 'LINE' then

      -- Preset encumbered_flag on Main Doc

      update po_distributions
         set encumbered_flag = decode(g_pomode, 'RESERVE', 'Y', 'REVERSE', 'N',
                                      'LIQUIDATE', 'N', 'REJECT',
                                      encumbered_flag, 'N')
       where po_line_id = g_lineid;


      -- Preset encumbered_flag on Backing Doc

      update po_distributions
         set encumbered_flag = decode(g_pomode, 'RESERVE', 'N',
                                      'REVERSE', 'Y', encumbered_flag)
       where po_distribution_id in
            (select po_distribution_id
               from po_distributions
              where po_line_id = g_lineid);

    elsif g_fclevel = 'SHIPMENT' then

      -- Preset encumbered_flag on Main Doc

      update po_distributions
         set encumbered_flag = decode(g_pomode, 'RESERVE', 'Y', 'REVERSE', 'N',
                                      'LIQUIDATE', 'N', 'REJECT',
                                      encumbered_flag, 'N')
       where line_location_id = g_shipid;


      -- Preset encumbered_flag on Backing Doc

      update po_distributions
         set encumbered_flag = decode(g_pomode, 'RESERVE', 'N',
                                      'REVERSE', 'Y', encumbered_flag)
       where po_distribution_id in
            (select po_distribution_id
               from po_distributions
              where line_location_id = g_shipid);

    end if;


    -- Update Distributions with Funds Check Results

    if not po_fc_dist then

      PO_MESSAGE_S.APP_ERROR('PO_ALL_TRACE_ERROR',
                             'FILE', 'PO_FUNDS_CHECKER',
                             'ERR_NUMBER', '185',
                             'SUBROUTINE', 'PO_ROLLUP_SCHREL()');
      return(FALSE);

    end if;


    -- Rollup to Line Locations

    update po_line_locations poll
       set encumbered_flag =
          (select decode(count(pod.po_distribution_id), 0, 'Y', 'N')
             from po_distributions pod
            where pod.line_location_id = poll.line_location_id
              and pod.encumbered_flag = 'N')
     where poll.po_release_id = g_docid;


    -- Rollup to Requisition Lines on Backing Document

    update po_line_locations poll
       set encumbered_flag =
          (select decode(count(pod.po_distribution_id), 0, 'Y', 'N')
             from po_distributions pod
            where pod.line_location_id = poll.line_location_id
              and pod.encumbered_flag = 'N')
     where poll.line_location_id in
          (select pod.line_location_id
             from po_distributions pod,
                  po_distributions prd
            where pod.po_distribution_id = prd.source_distribution_id
              and prd.po_release_id = g_docid);

    return(TRUE);


  EXCEPTION

    WHEN OTHERS THEN

      PO_MESSAGE_S.SQL_ERROR(routine => 'PO_FUNDS_CHECKER',
                             location => '190',
                             error_code => SQLCODE);

      return(FALSE);

  END po_rollup_schrel;

/* ----------------------------------------------------------------------- */

  -- Update Distributions with Funds Check Results

  FUNCTION po_fc_dist RETURN BOOLEAN IS

/* Bug 968872 change the parameter name from packet_id
                     to dist_packet_id to make the real restrict condition
   Base Bug 826203 in 11.0 */

    cursor pkt(dist_packet_id NUMBER) is
      select glbp.reference1 doc_type,
             to_number(glbp.reference2) doc_id,
             to_number(glbp.reference3) dist_id,
             glbp.result_code,
             glbp.status_code,
             glbp.funds_check_level_code,
             glbp.accounted_dr,
             glbp.accounted_cr,
             glbp.automatic_encumbrance_flag
        from gl_bc_packets glbp
       where glbp.originating_rowid is null
         and glbp.packet_id = dist_packet_id
         and glbp.template_id is NULL
       order by packet_id, to_number(reference3);

  BEGIN

    -- Fetch Cursor Rows

    for c_pkt in pkt(g_packetid) loop

      -- Update encumbered_flag and encumbered_amount on the PO and REQ
      -- distributions if the Funds Check Return Code is 'Advisory',
      -- 'Success' or 'Partial' and the Status for that row in the Funds
      -- Checker queue is 'Approved'

      if g_return_code in ('A', 'S', 'P') then

        if c_pkt.doc_type = 'PO' then

          if c_pkt.status_code = 'A' then

            -- Update encumbered_flag if packet has passed

            update po_distributions
               set encumbered_flag =
                   decode(sign(c_pkt.accounted_dr - c_pkt.accounted_cr), 1, 'Y', 0, encumbered_flag, 'N')
             where po_distribution_id = c_pkt.dist_id;


            if c_pkt.automatic_encumbrance_flag = 'Y' then

              -- Update encumbered_amount if packet has passed

              update po_distributions
                 set encumbered_amount =
                     round((nvl(encumbered_amount, 0) + c_pkt.accounted_dr - c_pkt.accounted_cr), 3)
               where po_distribution_id = c_pkt.dist_id;

            end if;

          elsif c_pkt.status_code = 'R' then

            -- Update encumbered_flag if packet has failed

            update po_distributions
               set encumbered_flag =
                   decode(sign(c_pkt.accounted_dr - c_pkt.accounted_cr), 1, 'N', 0, encumbered_flag, 'Y')
             where po_distribution_id = c_pkt.dist_id;

          end if;

        elsif c_pkt.doc_type = 'REQ' then

          if c_pkt.status_code = 'A' then

            -- Update encumbered_flag if packet has passed

            update po_req_distributions
               set encumbered_flag =
                   decode(sign(c_pkt.accounted_dr - c_pkt.accounted_cr), 1, 'Y', 0, encumbered_flag, 'N')
             where distribution_id = c_pkt.dist_id;


            if c_pkt.automatic_encumbrance_flag = 'Y' then

              -- Update encumbered_amount if packet has passed

              update po_req_distributions
                 set encumbered_amount =
                     round((nvl(encumbered_amount, 0) + c_pkt.accounted_dr - c_pkt.accounted_cr), 3)
               where distribution_id = c_pkt.dist_id;

            end if;

          elsif c_pkt.status_code = 'R' then

            -- Update encumbered_flag if packet has failed

            update po_req_distributions
               set encumbered_flag =
                   decode(sign(c_pkt.accounted_dr - c_pkt.accounted_cr), 1, 'N', 0, encumbered_flag, 'Y')
             where distribution_id = c_pkt.dist_id;

          end if;

        end if;

      end if;


      -- Update failed_funds_lookup_code on the PO and REQ distributions if
      -- the Funds Check Return Code is 'Failure', 'Fatal' or 'Partial' and
      -- status_code for that row in the Funds Checker queue is 'Rejected',
      -- 'Failed Check' or 'Fatal'

      if g_return_code in ('T', 'F', 'P') then

        if ((c_pkt.doc_type = 'PO') and
            (c_pkt.status_code in ('R', 'F', 'T'))) then

          update po_distributions
             set failed_funds_lookup_code = c_pkt.result_code
           where po_distribution_id = c_pkt.dist_id;

        elsif ((c_pkt.doc_type = 'REQ') and
            (c_pkt.status_code in ('R', 'F', 'T'))) then

          update po_req_distributions
             set failed_funds_lookup_code = c_pkt.result_code
           where distribution_id = c_pkt.dist_id;

        end if;

      end if;

    end loop;

    return(TRUE);


  EXCEPTION

    WHEN OTHERS THEN

      PO_MESSAGE_S.SQL_ERROR(routine => 'PO_FUNDS_CHECKER',
                             location => '195',
                             error_code => SQLCODE);

      return(FALSE);

  END po_fc_dist;

/* ----------------------------------------------------------------------- */

  -- Insert errors into po_online_report_text

  FUNCTION po_err_insert RETURN BOOLEAN IS

    l_linemsg   VARCHAR2(25);
    l_shipmsg   VARCHAR2(25);
    l_distmsg   VARCHAR2(25);

    l_reportid  po_online_report_text.online_report_id%TYPE;

    cursor report_seq is
      select po_online_report_text_s.nextval
        from dual;

  BEGIN

    l_linemsg := FND_MESSAGE.GET_STRING('PO', 'PO_ZMVOR_LINE');
    l_shipmsg := FND_MESSAGE.GET_STRING('PO', 'PO_ZMVOR_SHIPMENT');
    l_distmsg := FND_MESSAGE.GET_STRING('PO', 'PO_ZMVOR_DISTRIBUTION');

    open report_seq;

    fetch report_seq
     into l_reportid;

    close report_seq;

    if g_doctyp = 'REQUISITION' then

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
                                 select l_reportid,
                                        g_loginid,
                                        g_userid,
                                        sysdate,
                                        g_userid,
                                        sysdate,
                                        prl.line_num,
                                        0,
                                        prd.distribution_num,
                                        rownum,
                                        l_linemsg || to_char(prl.line_num) ||
                                        ' ' || l_distmsg ||
                                        to_char(prd.distribution_num) || ' ' ||
                                        gll.meaning
                                   from gl_bc_packets gbp,
                                        gl_lookups gll,
                                        po_requisition_lines prl,
                                        po_req_distributions prd
                                  where gbp.packet_id = g_packetid
                                    and gbp.status_code in ('R', 'F', 'T')
                                    and gbp.result_code = gll.lookup_code
                                    and gll.lookup_type = 'FUNDS_CHECK_RESULT_CODE'
                                    and gbp.reference3 = prd.distribution_id
                                    and prd.requisition_line_id = prl.requisition_line_id;
    -- FRKHAN bug 941171
       IF LENGTH (g_dbug) < x_max_length THEN
          g_dbug := g_dbug ||
               'Inserted ' || SQL%ROWCOUNT || ' Records into po_online_report_text' || g_delim;
       END IF;
    elsif g_doctyp in ('PO', 'RELEASE') then

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
                                 select l_reportid,
                                        g_loginid,
                                        g_userid,
                                        sysdate,
                                        g_userid,
                                        sysdate,
                                        pol.line_num,
                                        poll.shipment_num,
                                        pod.distribution_num,
                                        rownum,
                                        l_linemsg || to_char(pol.line_num) ||
                                        ' ' || l_shipmsg ||
                                        to_char(poll.shipment_num) || ' ' ||
                                        l_distmsg ||
                                        to_char(pod.distribution_num) || ' ' ||
                                        gll.meaning
                                   from gl_bc_packets gbp,
                                        gl_lookups gll,
                                        po_lines pol,
                                        po_line_locations poll,
                                        po_distributions pod
                                  where gbp.packet_id = g_packetid
                                    and gbp.status_code in ('R', 'F', 'T')
                                    and gbp.result_code = gll.lookup_code
                                    and gll.lookup_type = 'FUNDS_CHECK_RESULT_CODE'
                                    and gbp.reference3 = pod.po_distribution_id
                                    and pod.po_line_id = pol.po_line_id
                                    and pod.line_location_id = poll.line_location_id;
    -- FRKHAN bug 941171
       IF LENGTH (g_dbug) < x_max_length THEN
          g_dbug := g_dbug ||
               'Inserted ' || SQL%ROWCOUNT || ' Records into po_online_report_text' || g_delim;
       END IF;
    end if;

    return(TRUE);


  EXCEPTION

    WHEN OTHERS THEN

      if report_seq%ISOPEN then
        close report_seq;
      end if;

      PO_MESSAGE_S.SQL_ERROR(routine => 'PO_FUNDS_CHECKER',
                             location => '200',
                             error_code => SQLCODE);

      return(FALSE);

  END po_err_insert;

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

END PO_FUNDS_CHECKER;


/
