--------------------------------------------------------
--  DDL for Package Body GL_FUNDS_CHECKER_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."GL_FUNDS_CHECKER_PKG" AS
/* $Header: glfbcfcb.pls 120.30 2005/07/08 14:58:14 tpradhan ship $ */

  -- Types :
  --

  -- SegNamArray contains all Active Segments

  TYPE SegNamArray IS TABLE OF VARCHAR2(9) INDEX BY BINARY_INTEGER;

  -- TokNameArray contains names of all tokens

  TYPE TokNameArray IS TABLE OF VARCHAR2(15) INDEX BY BINARY_INTEGER;

  -- TokValArray contains values for all tokens

  TYPE TokValArray IS TABLE OF VARCHAR2(1000) INDEX BY BINARY_INTEGER;


  -- Constants :
  -- This is used as a delimiter in the Debug Info String

  g_delim               CONSTANT VARCHAR2(1) := '[';


  -- Private Global Variables :
  --

  -- Packet ID for the Packet being processed

  g_packet_id           gl_bc_packets.packet_id%TYPE;


  -- Funds Check Return Code for the Packet processed. Valid Return Codes
  -- are : 'S' for Success, 'A' for Advisory, 'F' for Failure, 'P' for Partial,
  -- and 'T' for Fatal

  g_return_code         gl_bc_packets.result_code%TYPE;

  -- Message Token Name

  msg_tok_names         TokNameArray;

  -- Message Token Value

  msg_tok_val           TokValArray;

  -- Number of Message Tokens

  g_no_msg_tokens       NUMBER;

  -- Debug String

  g_dbug                VARCHAR2(2000);

/* ----------------------------------------------------------------------- */
/*                                                                         */
/*                      Private Function Definition                        */
/*                                                                         */
/* ----------------------------------------------------------------------- */

  -- Bug 4481546, commented out the function glxfuf
/*
  FUNCTION glxfuf(p_sobid             IN  NUMBER,
	          p_packetid          IN  NUMBER,
	          p_mode              IN  VARCHAR2,
	          p_partial_resv_flag IN  VARCHAR2,
	          p_override          IN  VARCHAR2,
	          p_conc_flag         IN  VARCHAR2,
	          p_user_id           IN  NUMBER,
	          p_user_resp_id      IN  NUMBER) RETURN BOOLEAN;
*/

  PROCEDURE message_token(tokname IN VARCHAR2,
                          tokval  IN VARCHAR2);


  PROCEDURE add_message(appname IN VARCHAR2,
                        msgname IN VARCHAR2);


/* ------------------------------------------------------------------------- */
/*                                                                           */
/*  Funds Check API for any process that needs to perform Funds Check and/or */
/*  Funds Reservation                                                        */
/*                                                                           */
/*  This routine returns TRUE if successful; otherwise, it returns FALSE     */
/*                                                                           */
/*  In case of failure, this routine will populate the global Message Stack  */
/*  using FND_MESSAGE. The calling routine will retrieve the message from    */
/*  the Stack                                                                */
/*                                                                           */
/*  When invoked from a Concurrent Process, the calling process has to       */
/*  initialize values for User ID, User Responsibility ID, Calling           */
/*  Application ID and Login ID. These values should be initialized, in the  */
/*  Global Stack by invoking FND_GLOBAL, prior to calling Funds Checker      */
/*                                                                           */
/*  External Packages which are being invoked include :                      */
/*                                                                           */
/*            FND_GLOBAL                                                     */
/*            FND_PROFILE                                                    */
/*            FND_INSTALLATION                                               */
/*            FND_MESSAGE                                                    */
/*            FND_FLEX_EXT                                                   */
/*            FND_FLEX_APIS                                                  */
/*                                                                           */
/*  GL Tables which are being used include :                                 */
/*                                                                           */
/*            GL_BC_PACKETS                                                  */
/*            GL_BC_PACKET_ARRIVAL_ORDER                                     */
/*            GL_BC_OPTIONS                                                  */
/*            GL_BC_OPTION_DETAILS                                           */
/*            GL_BC_PERIOD_MAP                                               */
/*            GL_BC_DUAL                                                     */
/*            GL_BC_DUAL2                                                    */
/*            GL_CONCURRENCY_CONTROL                                         */
/*            GL_PERIOD_STATUSES                                             */
/*            GL_LOOKUPS                                                     */
/*            GL_USSGL_TRANSACTION_CODES                                     */
/*            GL_USSGL_ACCOUNT_PAIRS                                         */
/*            GL_BALANCES                                                    */
/*            GL_BUDGETS                                                     */
/*            GL_BUDGET_VERSIONS                                             */
/*            GL_BUDGET_ASSIGNMENTS                                          */
/*            GL_BUDGET_PERIOD_RANGES                                        */
/*            GL_JE_BATCHES                                                  */
/*            GL_JE_HEADERS                                                  */
/*            GL_JE_LINES                                                    */
/*            GL_SETS_OF_BOOKS                                               */
/*            GL_CODE_COMBINATIONS                                           */
/*            GL_ACCOUNT_HIERARCHIES                                         */
/*                                                                           */
/*  AOL Tables which are being used include :                                */
/*                                                                           */
/*            FND_USER                                                       */
/*            FND_APPLICATION                                                */
/*            FND_RESPONSIBILITY                                             */
/*            FND_PROFILE_OPTION_VALUES                                      */
/*            FND_PRODUCT_INSTALLATIONS                                      */
/*                                                                           */
/* ------------------------------------------------------------------------- */

  -- Parameters :

  -- p_sobid : Set of Books ID

  -- p_packetid : Packet ID

  -- p_mode : Funds Checker Operation Mode. Defaults to 'C' (Checking)

  -- p_partial_resv_flag : Whether Partial Reservation is allowed for the
  --                       Packet. Defaults to 'N' (No)

  -- p_override : Whether to Override in case of Funds Reservation failure
  --              because of lack of Funds. Defaults to 'N' (No)

  -- p_conc_flag : Whether invoked from a Concurrent Process. Defaults to
  --               'N' (No)

  -- p_user_id : User ID for Override (from AP AutoApproval)

  -- p_user_resp_id : User Responsibility ID for Override (from AP AutoApproval)

  -- p_return_code : Return Status for the Packet

  FUNCTION glxfck(p_sobid             IN  NUMBER,
                  p_packetid          IN  NUMBER,
                  p_mode              IN  VARCHAR2 DEFAULT 'C',
                  p_partial_resv_flag IN  VARCHAR2 DEFAULT 'N',
                  p_override          IN  VARCHAR2 DEFAULT 'N',
                  p_conc_flag         IN  VARCHAR2 DEFAULT 'N',
                  p_user_id           IN  NUMBER DEFAULT NULL,
                  p_user_resp_id      IN  NUMBER DEFAULT NULL,
                  p_return_code       OUT NOCOPY VARCHAR2) RETURN BOOLEAN IS

    others  EXCEPTION;

  BEGIN

    g_packet_id := p_packetid;

    -- Bug 4481546, added NOT to the condition below
    IF NOT PSA_FUNDS_CHECKER_PKG.glxfck
		 (p_sobid             ,
                  p_packetid          ,
                  p_mode              ,
                  p_partial_resv_flag ,
                  p_override          ,
                  p_conc_flag         ,
                  p_user_id           ,
                  p_user_resp_id      ,
                  p_return_code       ) then

       goto fatal_error;

    END IF;

    p_return_code := g_return_code;

    return(TRUE);


    <<fatal_error>>
    g_dbug := g_dbug ||
              'Fatal Error' || g_delim;
/*
    if not glxfuf
	    	(p_sobid            ,
		 p_packetid          ,
		 p_mode              ,
		 p_partial_resv_flag ,
		 p_override          ,
		 p_conc_flag         ,
		 p_user_id           ,
		 p_user_resp_id      ) then
      raise others;

    end if;
*/
    return(FALSE);


  EXCEPTION

    WHEN OTHERS THEN

      message_token('PROCEDURE', 'Funds Checker');
      message_token('EVENT', SQLERRM);
      add_message('SQLGL', 'GL_UNHANDLED_EXCEPTION');

      return(FALSE);

  END glxfck;

/* ------------------------------------------------------------------------- */

  -- Purge Packets after Funds Check

  -- This Module provides a way for any external Funds Check implementation
  -- to rollback Funds Reserved after the Funds Checker call. This must be
  -- called before any commit that would otherwise confirm the final Funds
  -- Check Status of the packet

  -- This Module deletes all transaction lines of a packet in gl_bc_packets and
  -- the associated Arrival Order record in gl_bc_packet_arrival_order

  -- This Module also deletes the corresponding records for a packet being
  -- Unreserved

  -- This Function is invoked by any Module that needs to purge all packet
  -- related information after the Funds Checker call


  -- Parameters :

  -- p_packetid : Packet ID

  -- p_packetid_ursvd : Unreservation Packet ID. Defaults to 0

  PROCEDURE glxfpp(p_packetid       IN NUMBER,
                   p_packetid_ursvd IN NUMBER DEFAULT 0) IS

  BEGIN

    -- Delete Packet Transactions

    delete from gl_bc_packets bp
     where bp.packet_id in (p_packetid, p_packetid_ursvd);


    -- Delete Packet Arrival Order Record

    delete from gl_bc_packet_arrival_order ao
     where ao.packet_id in (p_packetid, p_packetid_ursvd);


  EXCEPTION

    WHEN OTHERS THEN

      message_token('PROCEDURE', 'Funds Checker');
      message_token('EVENT', SQLERRM);
      add_message('SQLGL', 'GL_UNHANDLED_EXCEPTION');

  END glxfpp;

/* ------------------------------------------------------------------------- */

  -- Update Status Code for Transactions to Fatal

  -- Updates Status Code for all transactions in the Packet to 'T'; it also
  -- updates affect_funds_flag in gl_bc_packet_arrival_order to 'N' so that
  -- the available Funds calculation of packets arriving later is not affected
  -- in case an irrecoverable error halts Funds Check. SQLs for updating the
  -- columns are not guaranteed to succeed in many drastic cases. However, this
  -- step tries to ensure that the current packet does not affect the Funds
  -- Available calculation for packets arriving later

  -- The final cleanup is done by the Sweeper program, which deletes all packets
  -- with Status 'T', as well as all packets with Status 'P' (Pending) which are
  -- older than a specific (relatively long) time interval. This remedies for
  -- cases where the update could not be done in this Module

  -- Bug 4481546, commented out the function glxfuf since it should not be used.
/*
  FUNCTION glxfuf(p_sobid            IN  NUMBER,
	          p_packetid          IN  NUMBER,
	          p_mode              IN  VARCHAR2,
	          p_partial_resv_flag IN  VARCHAR2,
	          p_override          IN  VARCHAR2,
	          p_conc_flag         IN  VARCHAR2,
	          p_user_id           IN  NUMBER,
	          p_user_resp_id      IN  NUMBER) RETURN BOOLEAN IS

	others		EXCEPTION;
	p_sql_err_msg 	VARCHAR2(200);

  BEGIN

    -- Update Status Code for the Packet Transactions

    update gl_bc_packets bp
       set bp.status_code = 'T'
     where bp.packet_id = g_packet_id;

    g_dbug := g_dbug ||
              'Updated Status for ' || SQL%ROWCOUNT || ' Trans to Fatal' ||
              g_delim;


    -- Update Affect Funds Flag

    update gl_bc_packet_arrival_order ao
       set ao.affect_funds_flag = 'N'
     where ao.packet_id = g_packet_id;

    if PSA_FUNDS_CHECKER_PKG.glzfrs_public
    		    ('Z'                 ,
	             p_sobid            ,
		     p_packetid          ,
		     p_mode              ,
		     p_partial_resv_flag ,
		     p_override          ,
		     p_conc_flag         ,
		     p_user_id           ,
		     p_user_resp_id      ,
		     p_sql_err_msg       ) then
	    raise others;
    end if;

    return(TRUE);


  EXCEPTION

    WHEN OTHERS THEN

      message_token('PROCEDURE', 'Funds Checker');
      message_token('EVENT', SQLERRM);
      add_message('SQLGL', 'GL_UNHANDLED_EXCEPTION');

      return(FALSE);

  END glxfuf;
*/
/* ------------------------------------------------------------------------- */

  -- Add Token and Value to the Message Token array

  PROCEDURE message_token(tokname IN VARCHAR2,
                          tokval  IN VARCHAR2) IS

  BEGIN

    if g_no_msg_tokens is null then
      g_no_msg_tokens := 1;
    else
      g_no_msg_tokens := g_no_msg_tokens + 1;
    end if;

    msg_tok_names(g_no_msg_tokens) := tokname;
    msg_tok_val(g_no_msg_tokens) := tokval;

  END message_token;

/* ----------------------------------------------------------------------- */

  -- Sets the Message Stack

  PROCEDURE add_message(appname IN VARCHAR2,
                        msgname IN VARCHAR2) IS

    i  BINARY_INTEGER;

  BEGIN

    if ((appname is not null) and
        (msgname is not null)) then

      FND_MESSAGE.SET_NAME(appname, msgname);

      if g_no_msg_tokens is not null then

        for i in 1..g_no_msg_tokens loop
          FND_MESSAGE.SET_TOKEN(msg_tok_names(i), msg_tok_val(i));
        end loop;

      end if;

    end if;

    -- Clear Message Token stack

    g_no_msg_tokens := 0;

  END add_message;

/* ----------------------------------------------------------------------- */

  -- Get Debug Information

  -- This Module is used to retrieve Debug Information for Funds Checker. It
  -- prints Debug Information when run as a Batch Process from SQL*Plus. For
  -- the Debug Information to be printed on the Screen, the SQL*Plus parameter
  -- 'Serveroutput' should be set to 'ON'

  FUNCTION get_debug RETURN VARCHAR2 IS

  BEGIN

    return(g_dbug);

  END get_debug;


/* ----------------------------------------------------------------------- */

END GL_FUNDS_CHECKER_PKG;

/
