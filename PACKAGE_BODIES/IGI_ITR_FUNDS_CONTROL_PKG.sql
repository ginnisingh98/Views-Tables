--------------------------------------------------------
--  DDL for Package Body IGI_ITR_FUNDS_CONTROL_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IGI_ITR_FUNDS_CONTROL_PKG" AS
-- $Header: igiitrhb.pls 120.10 2007/08/23 14:52:16 smannava ship $

------------------------------------------------------------------------
-- Cursor to be used in Funds_Control for both Fundschecker and Approval
------------------------------------------------------------------------

Cursor Fundscntrl_Itr_Cur(
    p_set_of_books_id    IN igi_itr_charge_headers.set_of_books_id%type,
    p_it_header_id       IN igi_itr_charge_headers.it_header_id%type,
    p_it_service_line_id IN igi_itr_charge_lines.it_service_line_id%type,
    p_parent_value       IN igi_itr_charge_lines.entered_dr%type) IS
Select
    A.rowid,
    A.it_service_line_id,
    decode(nvl(A.entered_dr,0),0,A.creation_code_combination_id,A.receiving_code_combination_id),
    decode(nvl(A.entered_dr,0),0,A.entered_cr,A.entered_dr) amount,
    P1.start_date gl_encumbered_date,
    H.it_period_name,
    H.currency_code,
    P1.period_num,
    P1.period_year,
    P1.quarter_num,
    A.reversal_flag,
    A.packet_id,
    H.name,
    A.description,
    A.charge_service_id,
    A.status_flag,
    A.prevent_encumbrance_flag,
    H.it_originator_id
From
    igi_itr_charge_headers H,
    igi_itr_charge_lines L,
    igi_itr_charge_lines_audit A,
    gl_period_statuses P1
Where H.it_header_id = p_it_header_id
  And L.it_header_id = H.it_header_id
  And A.it_header_id = L.it_header_id
  And L.it_service_line_id  = nvl(p_it_service_line_id, L.it_service_line_id)
  And A.it_service_line_id = L.it_service_line_id
  And (nvl(A.status_flag,'P') = 'F'
      Or (nvl(A.status_flag,'P') = 'L' and A.encumbrance_flag = 'Y' and nvl(A.unencumbered_amount,0) = 0)
      Or nvl(A.status_flag,'P') = 'P'
      Or nvl(A.status_flag,'P') = 'C'
      Or nvl(A.status_flag,'P') = 'U'
      Or nvl(A.status_flag,'P') = 'R'
      Or nvl(A.status_flag,'P') = 'J'
      Or (A.encumbrance_flag = 'Y' and nvl(A.prevent_encumbrance_flag,'N') = 'Y'))
  And nvl(A.reversal_flag,'N') = 'N'
  And H.set_of_books_id = p_set_of_books_id
  And H.it_period_name = P1.period_name
  And P1.set_of_books_id = H.set_of_books_id
  And NVL(P1.adjustment_period_flag,'N') = 'N'
  And P1.application_id = (Select F1.application_id
                           From fnd_application F1
                           Where F1.application_short_name = 'SQLGL');

   l_debug_level number	:=	FND_LOG.G_CURRENT_RUNTIME_LEVEL;
  l_state_level number	:=	FND_LOG.LEVEL_STATEMENT;
  l_proc_level number	:=	FND_LOG.LEVEL_PROCEDURE;
  l_event_level number	:=	FND_LOG.LEVEL_EVENT;
  l_excep_level number	:=	FND_LOG.LEVEL_EXCEPTION;
  l_error_level number	:=	FND_LOG.LEVEL_ERROR;
  l_unexp_level number	:=	FND_LOG.LEVEL_UNEXPECTED;
------------------------------------------------
-- Private (Non Public) Procedure Specifications
------------------------------------------------

Procedure Writelog(
    p_mesg       IN varchar2,
    p_debug_mode IN boolean ) IS
Begin
  If p_debug_mode Then
      fnd_file.put_line(fnd_file.log , p_mesg) ;
  Else
      null;
  End if;
End Writelog;

Procedure Process_Fundschk_Failure_Code(
    p_it_header_id 	       IN     igi_itr_charge_headers.it_header_id%type,
    p_it_service_line_id       IN     igi_itr_charge_lines.it_service_line_id%type,
    p_status_flag              IN     igi_itr_charge_lines.status_flag%type,
    p_prevent_encumbrance_flag IN     igi_itr_charge_lines.prevent_encumbrance_flag%type,
    p_packet_id 	       IN     igi_itr_charge_lines_audit.packet_id%type,
    p_return_message_name      IN OUT NOCOPY varchar2,
    p_called_by                IN     varchar2,
    p_rowid                    IN     varchar2,
    p_calling_sequence 	       IN     varchar2);

Procedure Itr_Enc_Update(
    p_it_header_id 	       IN igi_itr_charge_headers.it_header_id%type,
    p_it_service_line_id       IN igi_itr_charge_lines.it_service_line_id%type,
    p_status_flag              IN varchar2,
    p_prevent_encumbrance_flag IN varchar2,
    p_packet_id 	       IN number,
    p_fc_result_code           IN varchar2,
    p_rowid                    IN varchar2);

Procedure Get_Gl_Fundschk_Result_Code(
    p_packet_id      IN     number,
    p_fc_result_code IN OUT NOCOPY varchar2);

------------------------
-- Procedure Definitions
------------------------

--------------------------------------------------------------------
-- ENCUMBRANCE_ENABLED:  is a function that returns boolean. True if
--                       encumbrance is enabled, false otherwise.
--------------------------------------------------------------------

Function Encumbrance_Enabled(
    p_set_of_books_id IN igi_itr_charge_headers.set_of_books_id%type) Return Boolean IS
  l_enc_enabled           varchar2(1);
  l_debug_loc             varchar2(30) := 'Encumbrance_Enabled';
  l_curr_calling_sequence varchar2(2000);
  l_debug_info            varchar2(100);
Begin
  ----------------------------------------------------------------------
  l_curr_calling_sequence := 'IGI_ITR_FUNDS_CONTROL_PKG.'|| l_debug_loc;
  l_debug_info := 'Checking if encumbrance is enabled';
  ----------------------------------------------------------------------
  Select nvl(use_encumbrance_flag,'N')
  Into l_enc_enabled
  From igi_itr_charge_setup
  Where set_of_books_id = p_set_of_books_id;
  If (l_enc_enabled = 'Y') Then
      Return(TRUE);
  Else
      Return(FALSE);
  End If;
Exception
  When No_data_found Then
      Return(FALSE);
  When Others Then
    If (SQLCODE <> -20001) Then
	FND_MESSAGE.SET_NAME('IGI','IGI_ITR_DEBUG');
        FND_MESSAGE.SET_TOKEN('ERROR',SQLERRM);
        FND_MESSAGE.SET_TOKEN('CALLING_SEQUENCE', l_curr_calling_sequence);
        FND_MESSAGE.SET_TOKEN('DEBUG_INFO',l_debug_info);

         IF ( l_unexp_level >=  l_debug_level) THEN
               FND_MESSAGE.SET_NAME('IGI','IGI_LOGGING_UNEXP_ERROR');
               FND_MESSAGE.SET_TOKEN('CODE',SQLCODE);
               FND_MESSAGE.SET_TOKEN('MSG',  SQLERRM);
	       FND_LOG.MESSAGE (l_unexp_level,'igi.plsql.igiitrhb.IGI_ITR_FUNDS_CONTROL_PKG.Encumbrance_Enabled.msg1',TRUE);
         END IF;

    End If;
    APP_EXCEPTION.RAISE_EXCEPTION;
End Encumbrance_Enabled;

Procedure Setup_Gl_Fundschk_Params(
    p_packet_id   	IN OUT NOCOPY igi_itr_charge_lines_audit.packet_id%type,
    p_mode     	        IN OUT NOCOPY varchar2,
    p_partial_resv_flag IN OUT NOCOPY varchar2,
    p_called_by 	IN     varchar2,
    p_calling_sequence 	IN     varchar2) IS
  l_debug_loc	          varchar2(30) := 'Setup_Gl_Fundschk_Params';
  l_curr_calling_sequence varchar2(2000);
  l_debug_info		  varchar2(100);
  l_packet_id_old         igi_itr_charge_lines_audit.packet_id%type;
  l_mode_old              varchar2(1);
  l_partial_resv_flag_old varchar2(1);
Begin
  -----------------------------------------------------------------------------------------------
  l_curr_calling_sequence := 'IGI_ITR_FUNDS_CONTROL_PKG.'||l_debug_loc||'<-'||p_calling_sequence;
  l_debug_info := 'Call Get_Gl_Fundschk_Packet_id';
  -----------------------------------------------------------------------------------------------

  l_packet_id_old          := p_packet_id;
  l_mode_old               := p_mode;
  l_partial_resv_flag_old  := p_partial_resv_flag;

  Get_Gl_Fundschk_Packet_Id(p_packet_id);

  -------------------------------------------------------------------
  -- Init p_mode and p_partial_resv_flag depending on calling program
  -------------------------------------------------------------------
  If (p_called_by = 'A') Then          -- Reservation
      p_mode := 'R';                   -- reserve funds
      p_partial_resv_flag := 'N';      -- partial reservation not allowed
  Else                                 -- p_called_by = 'F' Fundschecker
      p_mode := 'C';                   -- check funds
      p_partial_resv_flag := 'Y';      -- partial reservation allowed
  End If;
Exception
  When Others Then
    p_packet_id         := l_packet_id_old;
    p_mode              := l_mode_old;
    p_partial_resv_flag := l_partial_resv_flag_old;
    If (SQLCODE <> -20001) Then
        FND_MESSAGE.SET_NAME('IGI','IGI_ITR_DEBUG');
        FND_MESSAGE.SET_TOKEN('ERROR',SQLERRM);
        FND_MESSAGE.SET_TOKEN('CALLING_SEQUENCE', l_curr_calling_sequence);
        FND_MESSAGE.SET_TOKEN('PARAMETERS', 'Called_by = '|| p_called_by
            ||', Packet Id = '|| to_char(p_packet_id)
            ||', Mode = '|| p_mode
            ||', Partial Reservation Flag = '|| p_partial_resv_flag);
        FND_MESSAGE.SET_TOKEN('DEBUG_INFO', l_debug_info);

	IF ( l_unexp_level >=  l_debug_level) THEN
	       FND_MESSAGE.SET_NAME('IGI','IGI_LOGGING_UNEXP_ERROR');
               FND_MESSAGE.SET_TOKEN('CODE',SQLCODE);
               FND_MESSAGE.SET_TOKEN('MSG',  SQLERRM);
	       FND_LOG.MESSAGE (l_unexp_level,'igi.plsql.igiitrhb.IGI_ITR_FUNDS_CONTROL_PKG.Setup_Gl_Fundschk_Params.msg2',TRUE);
         END IF;

    End If;
    APP_EXCEPTION.RAISE_EXCEPTION;
End Setup_Gl_Fundschk_Params;


Procedure Get_Gl_Fundschk_Packet_Id(
  p_packet_id IN OUT NOCOPY igi_itr_charge_lines_audit.packet_id%type) IS
  l_debug_loc             varchar2(30) := 'Get_Gl_Fundschk_Packet_Id';
  l_curr_calling_sequence varchar2(2000);
  l_debug_info            varchar2(100);
  l_packet_id_old         igi_itr_charge_lines_audit.packet_id%type;
Begin
  ---------------------------------------------------------------
  l_curr_calling_sequence := 'IGI_ITR_FUNDS_CONTROL_PKG.'||l_debug_loc;
  l_debug_info := 'Retrieve next packet id from gl_bc_packets_s';
  ---------------------------------------------------------------

  l_packet_id_old := p_packet_id;

  Select gl_bc_packets_s.nextval
  Into p_packet_id
  From sys.dual;
Exception
  When Others Then
    p_packet_id := l_packet_id_old;
    If (SQLCODE <> -20001) Then
        FND_MESSAGE.SET_NAME('IGI','IGI_ITR_DEBUG');
        FND_MESSAGE.SET_TOKEN('ERROR',SQLERRM);
        FND_MESSAGE.SET_TOKEN('CALLING_SEQUENCE', l_curr_calling_sequence);
        FND_MESSAGE.SET_TOKEN('DEBUG_INFO',l_debug_info);


	IF ( l_unexp_level >=  l_debug_level) THEN
	       FND_MESSAGE.SET_NAME('IGI','IGI_LOGGING_UNEXP_ERROR');
               FND_MESSAGE.SET_TOKEN('CODE',SQLCODE);
               FND_MESSAGE.SET_TOKEN('MSG',  SQLERRM);
	       FND_LOG.MESSAGE (l_unexp_level,'igi.plsql.igiitrhb.IGI_ITR_FUNDS_CONTROL_PKG.Get_Gl_Fundschk_Packet_Id.msg3',TRUE);
         END IF;

    End If;
    APP_EXCEPTION.RAISE_EXCEPTION;
End Get_Gl_Fundschk_Packet_Id;

PROCEDURE Funds_Check_Reserve(
    p_it_header_id	  IN     igi_itr_charge_headers.it_header_id%type,
    p_it_service_line_id  IN     igi_itr_charge_lines.it_service_line_id%type,
    p_set_of_books_id     IN     igi_itr_charge_headers.set_of_books_id%type,
    p_reversal_amount     IN     igi_itr_charge_lines.entered_dr%type,
    p_called_by           IN     varchar2, -- fundschecker(F)/approval(A)
    p_return_message_name IN OUT NOCOPY varchar2,
    p_calling_sequence    IN     varchar2) IS
  l_rowid                    varchar2(100);
  l_packet_id		     number;
  l_fundschk_mode	     varchar2(1);
  l_partial_reserv_flag	     varchar2(1);
  l_chart_of_accounts_id     number;
  l_itr_enc_type_id          number;
  l_gl_user_id               number;
  l_it_service_line_id       igi_itr_charge_lines_audit.it_service_line_id%type;
  l_ccid                     igi_itr_charge_lines_audit.receiving_code_combination_id%type;
  l_amount                   igi_itr_charge_lines_audit.entered_dr%type;
  l_gl_encumbered_date       igi_itr_charge_lines_audit.gl_encumbered_date%type;
  l_period_name              igi_itr_charge_headers.it_period_name%type;
  l_currency_code            igi_itr_charge_headers.currency_code%type;
  l_period_num               gl_period_statuses.period_num%type;
  l_period_year              gl_period_statuses.period_year%type;
  l_quarter_num              gl_period_statuses.quarter_num%type;
  l_current_period_name      igi_itr_charge_headers.it_period_name%type;
  l_current_period_num       gl_period_statuses.period_num%type;
  l_current_period_year      gl_period_statuses.period_year%type;
  l_current_quarter_num      gl_period_statuses.quarter_num%type;
  l_reversal_flag            igi_itr_charge_lines_audit.reversal_flag%type;
  l_old_packet_id            igi_itr_charge_lines_audit.packet_id%type;
  l_description              igi_itr_charge_lines_audit.description%type;
  l_charge_service_id        igi_itr_charge_lines_audit.charge_service_id%type;
  l_status_flag              igi_itr_charge_lines_audit.status_flag%type;
  l_prevent_encumbrance_flag igi_itr_charge_lines_audit.prevent_encumbrance_flag%type;
  l_it_originator_id         igi_itr_charge_headers.it_originator_id%type;
  l_debug_loc	 	     varchar2(30) := 'Funds_Check_Reserve';
  l_curr_calling_sequence    varchar2(2000);
  l_debug_info		     varchar2(100);
  l_return_code              varchar2(4);
  l_status_code              varchar2(1); -- used in GL BC PACKETS C[fundschecking]/P[Reservation]
  l_je_category_name      gl_je_categories.je_category_name%type := 'IGIITRCC';
  l_return_message_name_old  varchar2(30);
  l_charge_name              igi_itr_charge_headers.name%type;
/*
  Cursor C_cat_name IS
  Select je_category_name
  From gl_je_categories
  Where user_je_category_name = 'Cross Charges';
*/

  Cursor C_current_period IS
  Select
      period_name,
      period_num,
      period_year,
      quarter_num
  From gl_period_statuses
  Where trunc(sysdate) Between trunc(start_date) And trunc(end_date)
    And set_of_books_id = p_set_of_books_id
    And NVL(adjustment_period_flag,'N') = 'N'
    And application_id = (Select application_id
                          From fnd_application
                          Where application_short_name = 'SQLGL');
Begin
  -----------------------------------------------------------------------------------------------
  l_curr_calling_sequence := 'IGI_ITR_FUNDS_CONTROL_PKG.'||l_debug_loc||'<-'||p_calling_sequence;
  -----------------------------------------------------------------------------------------------

  l_return_message_name_old := p_return_message_name;

  If Encumbrance_Enabled (p_set_of_books_id) Then
      ----------------------------------------------------------
      -- Retrieve system variables to be used by fundschecker --
      ----------------------------------------------------------
      Fundscheck_Init(
          l_chart_of_accounts_id,
          p_set_of_books_id,
          l_itr_enc_type_id,
          l_gl_user_id,
          l_curr_calling_sequence);

/*
      -----------------------------------------
      l_debug_info := 'Open C_cat_name Cursor';
      -----------------------------------------
      Open C_cat_name;
      Fetch C_cat_name Into l_je_category_name;
      Close C_cat_name;
*/

      -------------------------------------------------
      l_debug_info := 'Open Fundscntrl_Itr_Cur Cursor';
      -------------------------------------------------
      Open Fundscntrl_Itr_Cur(
          p_set_of_books_id,
          p_it_header_id,
          p_it_service_line_id,
          p_reversal_amount);

      Loop
          ----------------------------------------------------------------
          l_debug_info := 'Fetch from Fundscntrl_Itr_Cur in Fundschecker';
          ----------------------------------------------------------------
          Fetch Fundscntrl_Itr_Cur Into
              l_rowid,
              l_it_service_line_id,
              l_ccid,
              l_amount,
              l_gl_encumbered_date,
              l_period_name,
              l_currency_code,
              l_period_num,
              l_period_year,
              l_quarter_num,
              l_reversal_flag,
              l_old_packet_id,
              l_charge_name,      --shsaxena for bug 2948237
              l_description,
              l_charge_service_id,
              l_status_flag,
              l_prevent_encumbrance_flag,
              l_it_originator_id;
          Exit When Fundscntrl_Itr_Cur%notfound;
          If p_called_by = 'F' Then
              l_status_code := 'C';
          Else
              l_status_code := 'P';
          End If;
          ------------------------------------------------------------
          -- Encumbrance enabled, setup gl_fundschecker parameters  --
          ------------------------------------------------------------
          Setup_Gl_Fundschk_Params(
              l_packet_id,
              l_fundschk_mode,
              l_partial_reserv_flag,
              p_called_by, -- 'FUNDSCHECK',
              l_curr_calling_sequence);

          If l_status_flag in ('R','J') Then
              -- insert reversal line
              -- based on assumption that a charge/payment cannot be modified
              Bc_Packets_Insert(
                  l_packet_id,
                  p_set_of_books_id,
                  l_ccid,
                  p_reversal_amount,
                  l_period_year,
                  l_period_num,
                  l_quarter_num,
                  l_gl_user_id,
                  l_itr_enc_type_id,
                  l_it_service_line_id,
                  l_charge_service_id,
                  l_it_originator_id,
                  'Internal Trading',
                  l_je_category_name,
                  'E',
                  l_period_name,
                  l_currency_code,
                  l_status_code, -- 'C'or 'P'
                  'Y', -- l_reversal_flag,
                  l_status_flag,
                  l_prevent_encumbrance_flag,
                  l_charge_name,--shsaxena for bug 2948237
            --    l_description,
                  l_curr_calling_sequence);
          End If;

          ----------------------------------------------------------------
          l_debug_info := 'Open C_current_period Cursor';
          ----------------------------------------------------------------
          Open C_current_period;
          Fetch C_current_period Into
              l_current_period_name,
              l_current_period_num,
              l_current_period_year,
              l_current_quarter_num;
          Close C_current_period;

          If (l_current_period_name = l_period_name And
              l_current_period_num  = l_period_num  And
              l_current_period_year = l_period_year And
              l_current_quarter_num = l_quarter_num) Then
              -- Current period gl_encumbered date is sysdate else the first date of the period
              l_gl_encumbered_date := sysdate;
          End if;

          Bc_Packets_Insert(l_packet_id,
              p_set_of_books_id,
              l_ccid,
              l_amount,
              l_period_year,
              l_period_num,
              l_quarter_num,
              l_gl_user_id,
              l_itr_enc_type_id,
              l_it_service_line_id,
              l_charge_service_id,
              l_it_originator_id,
              'Internal Trading',
              l_je_category_name,
              'E',
              l_period_name,
              l_currency_code,
              l_status_code, -- 'C'or 'P'
              l_reversal_flag,
              l_status_flag,
              l_prevent_encumbrance_flag,
              l_charge_name,   --shsaxena for bug 2948237
        --    l_description,
              l_curr_calling_sequence);

          ---------------------------------------
          l_debug_info := 'Call Gl_Fundschecker';
          ---------------------------------------
          /* Commented below code and added another call
      since the GL funds checker has changed in R12. Changed during r12 uptake for bug#602857
        /*   If (Not GL_FUNDS_CHECKER_PKG.glxfck(
              p_set_of_books_id,
              l_packet_id,
              l_fundschk_mode,
              l_partial_reserv_flag,
              'N',
              'N',
              NULL,
              NULL,
              l_return_code)) Then
              APP_EXCEPTION.Raise_Exception;
          End If; */
	If (Not PSA_FUNDS_CHECKER_PKG.GLXFCK(p_set_of_books_id,
              l_packet_id,
              l_fundschk_mode,
              'N',
              'N',
              NULL,
              NULL,
              'G',
              l_return_code)) Then
                APP_EXCEPTION.Raise_Exception;
          End If;
          --------------------------------------
          l_debug_info := 'Process_Return_Code';
          --------------------------------------
          If (l_return_code in ('T', 'F', 'P')) Then -- Fundscheck Failed
              Process_Fundschk_Failure_Code(
                  p_it_header_id,
                  l_it_service_line_id,
                  l_status_flag,
                  l_prevent_encumbrance_flag,
                  l_packet_id,
                  p_return_message_name,
                  p_called_by,
                  l_rowid,
                  p_calling_sequence);
          Else  -- Fundscheck Passed --
              If p_called_by = 'A' Then --Approval
                  -------------------------------------------
                  l_debug_info := 'Funds Reservation Passed';
                  -------------------------------------------
                  If l_status_flag in ('R','J') Then
                      -----------------------------------------------------------------------
                      l_debug_info := 'Rejection Lines Passed Updating Charge Lines'
                          || ' and Audit Tables ';
                      -- set the unencumbered amount = parent_value and the reversal flag = N
                      -----------------------------------------------------------------------
                      Update igi_itr_charge_lines
                      Set failed_funds_lookup_code  = 'N',
                          status_flag = 'N',
                          encumbrance_flag = 'Y',
                          encumbered_amount = l_amount,
                          gl_encumbered_date = l_gl_encumbered_date,
                          gl_encumbered_period_name = l_period_name,
                          unencumbered_amount = NULL,
                          packet_id = l_packet_id
                      Where it_header_id = p_it_header_id
                        And it_service_line_id = l_it_service_line_id;

                      Update igi_itr_charge_lines_audit
                      Set failed_funds_lookup_code = 'N',
                          status_flag = 'N',
                          encumbrance_flag = 'Y',
                          encumbered_amount = l_amount,
                          gl_encumbered_date = l_gl_encumbered_date,
                          gl_encumbered_period_name = l_period_name,
                          unencumbered_amount = NULL,
                          --packet_id = NULL
                          packet_id = l_packet_id
                      Where it_header_id = p_it_header_id
                        And it_service_line_id = l_it_service_line_id
                        And rowid = l_rowid;

                      Update igi_itr_charge_lines_audit
                      Set unencumbered_amount  = p_reversal_amount,
                          reversal_flag = 'O',
                          -- obselete so it doesn not get picked up in the cursor select again ,
                          -- problem in multiple modifications [N]
                          --packet_id = NULL
                          packet_id = l_packet_id
                      Where it_header_id = p_it_header_id
                        And it_service_line_id = l_it_service_line_id
                        And reversal_flag = 'Y';
                  Elsif l_status_flag = 'L' Then -- Cancellation
                      ------------------------------------------------------------
                      l_debug_info := 'Cancellation Passed, Updating Charge Lines'
                          || ' and Audit Tables ';
                      ------------------------------------------------------------
                      Update igi_itr_charge_lines
                      Set unencumbered_amount  = l_amount * -1,
                          encumbrance_flag = 'N',
                          gl_cancelled_date = l_gl_encumbered_date,
                          packet_id = l_packet_id
                      Where it_header_id = p_it_header_id
                        And it_service_line_id = l_it_service_line_id;

                      Update igi_itr_charge_lines_audit
                      Set unencumbered_amount  = l_amount * -1,
                          encumbrance_flag = 'N',
                          gl_cancelled_date = l_gl_encumbered_date,
                          --packet_id = NULL
                          packet_id = l_packet_id
                      Where it_header_id = p_it_header_id
                        And it_service_line_id = l_it_service_line_id
                        And rowid = l_rowid;
                  Elsif l_prevent_encumbrance_flag = 'Y' Then -- Unreservation
                      -------------------------------------------------------------
                      l_debug_info := 'Unreservation Passed, Updating Charge Lines'
                          || ' and Audit Tables ';
                      -------------------------------------------------------------
                      Update igi_itr_charge_lines
                      Set failed_funds_lookup_code  = 'N',
                          status_flag = 'U',
                          prevent_encumbrance_flag = 'N',
                          unencumbered_amount = l_amount,
                          packet_id = l_packet_id
                      Where it_header_id = p_it_header_id
                        And it_service_line_id = l_it_service_line_id;

                      Update igi_itr_charge_lines_audit
                      Set failed_funds_lookup_code  = 'N',
                          prevent_encumbrance_flag = 'N',
                          status_flag = 'U',
                          unencumbered_amount = l_amount,
                          --packet_id = NULL
                          packet_id = l_packet_id
                      Where it_header_id = p_it_header_id
                        And it_service_line_id = l_it_service_line_id
                        And rowid = l_rowid;
                  Else
                      ----------------------------------------------------------
                      l_debug_info := 'Reservation Passed, Updating Charge Lines'
                          || ' and Audit Tables ';
                      ----------------------------------------------------------
                      Update igi_itr_charge_lines
                      Set failed_funds_lookup_code  = 'N',
                          status_flag = 'N',
                          encumbrance_flag = 'Y',
                          encumbered_amount = l_amount,
                          gl_encumbered_date = l_gl_encumbered_date,
                          gl_encumbered_period_name = l_period_name,
                          unencumbered_amount = NULL,
                          packet_id = l_packet_id
                      Where it_header_id = p_it_header_id
                        And it_service_line_id = l_it_service_line_id;

                      Update igi_itr_charge_lines_audit
                      Set failed_funds_lookup_code = 'N',
                          status_flag = 'N',
                          encumbrance_flag = 'Y',
                          encumbered_amount = l_amount,
                          gl_encumbered_date = l_gl_encumbered_date,
                          gl_encumbered_period_name = l_period_name,
                          unencumbered_amount = NULL,
                          --packet_id = NULL
                          packet_id = l_packet_id
                      Where it_header_id = p_it_header_id
                        And it_service_line_id = l_it_service_line_id
                        And rowid = l_rowid;
                  End if;
              Else --Funds Checking
                  ----------------------------------------------------------
                  l_debug_info := 'Fundscheck Passed, Updating Charge Lines'
                      || ' and Audit Tables ';
                  ----------------------------------------------------------
                  Update igi_itr_charge_lines
                  Set status_flag = 'C',
                      failed_funds_lookup_code  = 'N',
                      packet_id = l_packet_id
                  Where it_header_id = p_it_header_id
                    And it_service_line_id = l_it_service_line_id;

                  Update igi_itr_charge_lines_audit
                  Set status_flag = 'C',
                      failed_funds_lookup_code = 'N',
                      --packet_id = NULL
                      packet_id = l_packet_id
                  Where it_header_id = p_it_header_id
                    And it_service_line_id = l_it_service_line_id
                    And rowid = l_rowid;
              End If;
              If (l_return_code = 'A') Then
                  p_return_message_name := 'IGI_ITR_FCK_PASSED_FUNDS_ADVIS';
              Else
                  p_return_message_name := 'IGI_ITR_FCK_PASSED_FUNDS_CHECK';
              End If;
          End If; -- Fundscheck Passed --
      End Loop;
      Close Fundscntrl_Itr_Cur;
      Commit;
  Else  -- Encumbrance is off --
      p_return_message_name := 'IGI_ITR_ALL_ENC_OFF';
  End If;
Exception
  When Others Then
    p_return_message_name := l_return_message_name_old;
    If (SQLCODE <> -20001) Then
        FND_MESSAGE.SET_NAME('IGI','IGI_ITR_DEBUG');
        FND_MESSAGE.SET_TOKEN('ERROR',SQLERRM);
        FND_MESSAGE.SET_TOKEN('CALLING_SEQUENCE', l_curr_calling_sequence);
        FND_MESSAGE.SET_TOKEN(
            'PARAMETERS','Charge Header Id  = '|| to_char(p_it_header_id)
            ||', Service Id = '|| to_char(l_it_service_line_id)
            ||', Set of Books Id = ' || to_char(p_set_of_books_id)
            ||', Reversal Amount = ' || to_char(p_reversal_amount)
            ||', Called By = ' || p_called_by );
        FND_MESSAGE.SET_TOKEN('DEBUG_INFO',l_debug_info);

	IF ( l_unexp_level >=  l_debug_level) THEN
               FND_MESSAGE.SET_NAME('IGI','IGI_LOGGING_UNEXP_ERROR');
               FND_MESSAGE.SET_TOKEN('CODE',SQLCODE);
               FND_MESSAGE.SET_TOKEN('MSG',  SQLERRM);
               FND_LOG.MESSAGE (l_unexp_level,'igi.plsql.igiitrhb.IGI_ITR_FUNDS_CONTROL_PKG.Funds_Check_Reserve.msg4',TRUE);
         END IF;

    End If;
    APP_EXCEPTION.RAISE_EXCEPTION;
End Funds_Check_Reserve;

Procedure Fundscheck_Init(
    p_chart_of_accounts_id IN OUT NOCOPY gl_sets_of_books.chart_of_accounts_id%type,
    p_set_of_books_id      IN     igi_itr_charge_headers.set_of_books_id%type,
    p_itr_enc_type_id 	   IN OUT NOCOPY igi_itr_charge_setup.encumbrance_type_id%type,
    p_gl_user_id           IN OUT NOCOPY number,
    p_calling_sequence 	   IN     varchar2) IS
  l_debug_loc	 	  varchar2(30) := 'Fundscheck_Init';
  l_curr_calling_sequence varchar2(2000);
  l_debug_info		  varchar2(100);
  l_chart_of_accounts_id_old gl_sets_of_books.chart_of_accounts_id%type;
  l_itr_enc_type_id_old      igi_itr_charge_setup.encumbrance_type_id%type;
  l_gl_user_id_old           number;
Begin
  -----------------------------------------------------------------------------------------------
  l_curr_calling_sequence := 'IGI_ITR_FUNDS_CONTROL_PKG.'||l_debug_loc||'<-'||p_calling_sequence;
  l_debug_info := 'Retrieving system parameters for fundschecker';
  -----------------------------------------------------------------------------------------------

  l_chart_of_accounts_id_old  := p_chart_of_accounts_id;
  l_itr_enc_type_id_old       := p_itr_enc_type_id;
  l_gl_user_id_old            := p_gl_user_id;

  Select
      nvl(gls.chart_of_accounts_id, -1),
      nvl(igi.encumbrance_type_id, -1)
  Into
      p_chart_of_accounts_id,
      p_itr_enc_type_id
  From
      igi_itr_charge_setup igi,
      gl_sets_of_books gls
  Where gls.set_of_books_id = p_set_of_books_id
    And igi.set_of_books_id(+) = gls.set_of_books_id;

  ----------------------------------------------------------------
  l_debug_info := 'Retrieving profile option user id';
  ----------------------------------------------------------------
  Fnd_profile.Get('USER_ID', p_gl_user_id);
Exception
  When Others Then
    p_chart_of_accounts_id := l_chart_of_accounts_id_old;
    p_itr_enc_type_id      := l_itr_enc_type_id_old;
    p_gl_user_id           := l_gl_user_id_old;
    If (SQLCODE <> -20001) Then
        FND_MESSAGE.SET_NAME('IGI','IGI_ITR_DEBUG');
        FND_MESSAGE.SET_TOKEN('ERROR',SQLERRM);
        FND_MESSAGE.SET_TOKEN('CALLING_SEQUENCE', l_curr_calling_sequence);
        FND_MESSAGE.SET_TOKEN('DEBUG_INFO',l_debug_info);

	IF ( l_unexp_level >=  l_debug_level) THEN
	       FND_MESSAGE.SET_NAME('IGI','IGI_LOGGING_UNEXP_ERROR');
               FND_MESSAGE.SET_TOKEN('CODE',SQLCODE);
               FND_MESSAGE.SET_TOKEN('MSG',  SQLERRM);
	       FND_LOG.MESSAGE (l_unexp_level,'igi.plsql.igiitrhb.IGI_ITR_FUNDS_CONTROL_PKG.Fundscheck_Init.msg5',TRUE);
         END IF;

    End If;
    APP_EXCEPTION.RAISE_EXCEPTION;
End Fundscheck_Init;

Procedure Bc_Packets_Insert(
    p_packet_id		       IN gl_bc_packets.packet_id%type,
    p_set_of_books_id 	       IN gl_bc_packets.ledger_id%type,
    p_ccid                     IN gl_bc_packets.code_combination_id%type,
    p_amount                   IN gl_bc_packets.entered_dr%type,
    p_period_year	       IN gl_bc_packets.period_year%type,
    p_period_num	       IN gl_bc_packets.period_num%type,
    p_quarter_num	       IN gl_bc_packets.quarter_num%type,
    p_gl_user		       IN gl_bc_packets.last_updated_by%type,
    p_enc_type_id	       IN gl_bc_packets.encumbrance_type_id%type,
    p_ref2		       IN gl_bc_packets.reference2%type,
    p_ref4	               IN gl_bc_packets.reference4%type,
    p_ref5	               IN gl_bc_packets.reference5%type,
    p_je_source		       IN gl_bc_packets.je_source_name%type,
    p_je_category	       IN gl_bc_packets.je_category_name%type,
    p_actual_flag	       IN gl_bc_packets.actual_flag%type,
    p_period_name	       IN gl_bc_packets.period_name%type,
    p_base_currency_code       IN gl_bc_packets.currency_code%type,
    p_status_code	       IN gl_bc_packets.status_code%type,
    p_reversal_flag	       IN igi_itr_charge_lines_audit.reversal_flag%type,
    p_status_flag              IN igi_itr_charge_lines.status_flag%type,
    p_prevent_encumbrance_flag IN igi_itr_charge_lines.prevent_encumbrance_flag%type,
    p_charge_name              IN igi_itr_charge_headers.name%type,   --shsaxena for bug 2948237
  --p_description              IN varchar2,
    p_calling_sequence 	       IN varchar2) IS PRAGMA AUTONOMOUS_TRANSACTION;
  l_ins_dr    		  number := NULL;
  l_ins_cr		  number := NULL;
  l_debug_loc	          varchar2(30) := 'Bc_Packets_Insert';
  l_curr_calling_sequence varchar2(2000);
  l_debug_info	          varchar2(100);
  l_charge_name           igi_itr_charge_headers.name%type;     --shsaxena for bug 2948237
  l_session_id            number := NULL;
  l_serial_id             number := NULL;
Begin

  ------------------------------------------------------------------------------------------------
  l_curr_calling_sequence := 'IGI_ITR_FUNDS_CONTROL_PKG.'||l_debug_loc||'<-'||p_calling_sequence;
  l_debug_info := 'Inserting record into gl_bc_packets';
  ------------------------------------------------------------------------------------------------
  -- Logic for switching
  If ((p_status_flag in ('R','J') and p_reversal_flag = 'Y') -- Modification and Reversal
          OR p_prevent_encumbrance_flag = 'Y') Then -- Unreservation then
      l_ins_cr := p_amount;
  Elsif p_status_flag = 'L' Then -- Cancellation
  	  l_ins_dr := p_amount * -1;
  Else
      l_ins_dr := p_amount;
  End If;

  /* Start of changes for bug#6028574  to insert into manadatory columns of gl_bc_packets introduced in r12. */
        BEGIN
          SELECT  s.audsid,  s.serial#   into l_session_id, l_serial_id
          FROM v$session s, v$process p
          WHERE s.paddr = p.addr
          AND   s.audsid = USERENV('SESSIONID');
        EXCEPTION
           WHEN OTHERS THEN
           raise;
       END;
     /* End of changes for bug#6028574 */

  Insert Into gl_bc_packets (
    packet_id,        ledger_id,     je_source_name,
    je_category_name, code_combination_id, actual_flag,
    period_name,      period_year,         period_num,
    quarter_num,      currency_code,       status_code,
    last_update_date, last_updated_by,     encumbrance_type_id,
    entered_dr,       entered_cr,          accounted_dr,
    accounted_cr,     reference2,          reference4,
    reference5,       je_line_description, session_id,
	 serial_id,        application_id)
  Values(
    p_packet_id,      p_set_of_books_id,    p_je_source,
    p_je_category,    p_ccid,               p_actual_flag,
    p_period_name,    p_period_year,        p_period_num,
    p_quarter_num,    p_base_currency_code, p_status_code,
    sysdate,          p_gl_user,            p_enc_type_id,
    l_ins_dr,         l_ins_cr,             l_ins_dr,
    l_ins_cr,         p_ref2,               p_ref4,
    p_ref5,           p_charge_name,	    l_session_id,
    l_serial_id,      101);           --shsaxena for bug 2948237      --   p_description);
	COMMIT;
Exception
  When Others Then
    If (SQLCODE <> -20001) Then
        FND_MESSAGE.SET_NAME('IGI','IGI_ITR_DEBUG');
        FND_MESSAGE.SET_TOKEN('ERROR',SQLERRM);
        FND_MESSAGE.SET_TOKEN('CALLING_SEQUENCE', l_curr_calling_sequence);
        FND_MESSAGE.SET_TOKEN('PARAMETERS', 'Packet Id = ' || to_char(p_packet_id)
            ||', Set_of_books_id  = '|| to_char(p_set_of_books_id)
            ||', Je_source = '|| p_je_source
            ||', Je_category = '|| p_je_category
            ||', CCID = '|| to_char(p_ccid)
            ||', Actual_flag = '|| p_actual_flag
            ||', Period_name = '|| p_period_name
            ||', Period_year = '|| to_char(p_period_year)
            ||', Period_num = '|| to_char(p_period_num)
            ||', Quarter_num = '|| to_char(p_quarter_num)
            ||', Base_currency_code = '|| p_base_currency_code
            ||', Status_code = '|| p_status_code
            ||', Gl_user = '|| to_char(p_gl_user)
            ||', Encumbrance Id  = '|| to_char(p_enc_type_id)
            ||', Entered Dr = '|| to_char(l_ins_dr)
            ||', Entered Cr = '|| to_char(l_ins_cr)
            ||', Ref 2 = '|| p_ref2
            ||', Ref 4 = '|| p_ref4
            ||', Ref 5 = '|| p_ref5
            ||', Status Flag = '|| p_status_flag
            ||', Prevent Encumbrance Flag = '|| p_prevent_encumbrance_flag
            ||', Reversal_flag = '|| p_reversal_flag);
        FND_MESSAGE.SET_TOKEN('DEBUG_INFO',l_debug_info);

	IF ( l_unexp_level >=  l_debug_level) THEN
	       FND_MESSAGE.SET_NAME('IGI','IGI_LOGGING_UNEXP_ERROR');
               FND_MESSAGE.SET_TOKEN('CODE',SQLCODE);
               FND_MESSAGE.SET_TOKEN('MSG',  SQLERRM);
	       FND_LOG.MESSAGE (l_unexp_level,'igi.plsql.igiitrhb.IGI_ITR_FUNDS_CONTROL_PKG.BC_Packets_Insert.msg6',TRUE);
         END IF;

    End If;
    APP_EXCEPTION.RAISE_EXCEPTION;
End BC_Packets_Insert;

Procedure Process_Fundschk_Failure_Code(
    p_it_header_id 	       IN     igi_itr_charge_headers.it_header_id%type,
    p_it_service_line_id       IN     igi_itr_charge_lines.it_service_line_id%type,
    p_status_flag              IN     igi_itr_charge_lines.status_flag%type,
    p_prevent_encumbrance_flag IN     igi_itr_charge_lines.prevent_encumbrance_flag%type,
    p_packet_id 	       IN     igi_itr_charge_lines_audit.packet_id%type,
    p_return_message_name      IN OUT NOCOPY varchar2,
    p_called_by                IN     varchar2,
    p_rowid                    IN     varchar2,
    p_calling_sequence 	       IN     varchar2) IS
  l_fc_result_code        varchar2(3);
  l_debug_loc	 	  varchar2(30) := 'Process_Fundschk_Failure_Code';
  l_curr_calling_sequence varchar2(2000);
  l_return_message_name_old varchar2(30);

Begin
  -----------------------------------------------------------------------------------------------
  l_curr_calling_sequence := 'IGI_ITR_FUNDS_CONTROL_PKG.'||l_debug_loc||'<-'||p_calling_sequence;
  -----------------------------------------------------------------------------------------------

  l_return_message_name_old  := p_return_message_name;

  Get_Gl_Fundschk_Result_Code(
      p_packet_id,
      l_fc_result_code);

  Itr_Enc_Update(
      p_it_header_id,
      p_it_service_line_id,
      p_status_flag,
      p_prevent_encumbrance_flag,
      p_packet_id,
      l_fc_result_code,
      p_rowid);

  If (l_fc_result_code in ('F00', 'F01', 'F02', 'F03', 'F04')) Then
      p_return_message_name := 'IGI_ITR_FCK_INSUFFICIENT_FUNDS';
  Elsif (l_fc_result_code = 'F20') Then
      p_return_message_name := 'IGI_ITR_FCK_ACCT_FLEX_UNDEFINE';
  Elsif (l_fc_result_code = 'F21') Then
      p_return_message_name := 'IGI_ITR_FCK_ACCT_FLEX_EXPIRED';
  Elsif (l_fc_result_code in ('F22', 'F23')) Then
      p_return_message_name := 'IGI_ITR_FCK_ACCT_FLEX_NO_POST'; --This message is not available
  Elsif (l_fc_result_code in ('F24', 'F25')) Then
      p_return_message_name := 'IGI_ITR_FCK_INCORRECT_CALENDAR';
  Elsif (l_fc_result_code in ('F26', 'F27')) Then
      p_return_message_name := 'IGI_ITR_FCK_BUDGET_UNDEFINED';
  ELSE -- return generic failure message --
      p_return_message_name := 'IGI_ITR_FCK_FAILED_FUNDSCHECK';
  End If;
Exception
  When Others Then
    p_return_message_name  := l_return_message_name_old;
        If (SQLCODE <> -20001) Then
        FND_MESSAGE.SET_NAME('IGI','IGI_ITR_DEBUG');
        FND_MESSAGE.SET_TOKEN('ERROR',SQLERRM);
        FND_MESSAGE.SET_TOKEN('CALLING_SEQUENCE', l_curr_calling_sequence);
        FND_MESSAGE.SET_TOKEN('PARAMETERS', 'ITR Header Id  = '|| to_char(p_it_header_id)
            ||', ITR Service Id = '|| to_char(p_it_service_line_id)
            ||', Status Flag ' || p_status_flag
            ||', Prevent Encumbrance Flag ' || p_prevent_encumbrance_flag
            ||', Packet_id = '|| to_char(p_packet_id));

	IF ( l_unexp_level >=  l_debug_level) THEN
	       FND_MESSAGE.SET_NAME('IGI','IGI_LOGGING_UNEXP_ERROR');
               FND_MESSAGE.SET_TOKEN('CODE',SQLCODE);
               FND_MESSAGE.SET_TOKEN('MSG',  SQLERRM);
	       FND_LOG.MESSAGE (l_unexp_level,'igi.plsql.igiitrhb.IGI_ITR_FUNDS_CONTROL_PKG.Process_Fundschk_Failure_Code.msg7',TRUE);
         END IF;

    End If;
    APP_EXCEPTION.RAISE_EXCEPTION;
End Process_Fundschk_Failure_Code;

Procedure Itr_Enc_Update(
    p_it_header_id 	       IN igi_itr_charge_headers.it_header_id%type,
    p_it_service_line_id       IN igi_itr_charge_lines.it_service_line_id%type,
    p_status_flag              IN varchar2,
    p_prevent_encumbrance_flag IN varchar2,
    p_packet_id 	       IN number,
    p_fc_result_code           IN varchar2,
    p_rowid                    IN varchar2) IS

  l_debug_loc             varchar2(30) := 'Itr_Enc_Update';
  l_curr_calling_sequence varchar2(2000);
  l_debug_info            varchar2(100);
Begin
  ---------------------------------------------------------------------
  l_curr_calling_sequence := 'IGI_ITR_FUNDS_CONTROL_PKG.'||l_debug_loc;
  ---------------------------------------------------------------------
  If (p_status_flag = 'L' or p_prevent_encumbrance_flag = 'Y') Then
      -------------------------------------------------------------------------------------------
      l_debug_info := 'Cancelled , Unreservation Lines , updating Charge Lines and Audit Tables';
      -------------------------------------------------------------------------------------------
      Update igi_itr_charge_lines
      Set failed_funds_lookup_code = 'Y',
          packet_id = p_packet_id
      Where it_header_id = p_it_header_id
        And it_service_line_id = p_it_service_line_id;

      Update igi_itr_charge_lines_audit
      Set failed_funds_lookup_code = 'Y',
          packet_id = p_packet_id
      Where it_header_id = p_it_header_id
        And it_service_line_id = p_it_service_line_id
        And rowid = p_rowid;
  Else
      -------------------------------------------------------------------------------------------
      l_debug_info := 'Updating Charge Lines and Audit Tables';
      -------------------------------------------------------------------------------------------
      Update igi_itr_charge_lines
      Set failed_funds_lookup_code = 'Y',
          status_flag = 'F',
          packet_id = p_packet_id
      Where it_header_id = p_it_header_id
        And it_service_line_id = p_it_service_line_id;

      Update igi_itr_charge_lines_audit
      Set failed_funds_lookup_code = 'Y',
          status_flag = 'F',
          packet_id = p_packet_id
      Where it_header_id = p_it_header_id
        And it_service_line_id = p_it_service_line_id
        And rowid = p_rowid;
  End if;
Exception
  When Others Then
    If (SQLCODE <> -20001) Then
        FND_MESSAGE.SET_NAME('IGI','IGI_ITR_DEBUG');
        FND_MESSAGE.SET_TOKEN('ERROR',SQLERRM);
        FND_MESSAGE.SET_TOKEN('CALLING_SEQUENCE', l_curr_calling_sequence);
        FND_MESSAGE.SET_TOKEN('PARAMETERS','Header Id  = '|| to_char(p_it_header_id)
            ||', Service Id = '|| to_char(p_it_service_line_id)
            ||', Packet_id = '|| to_char(p_packet_id)
            ||', Status Flag ' || p_status_flag
            ||', Prevent Encumbrance Flag ' || p_prevent_encumbrance_flag
            ||', Funds check code = ' || p_fc_result_code);
        FND_MESSAGE.SET_TOKEN('DEBUG_INFO',l_debug_info);

	IF ( l_unexp_level >=  l_debug_level) THEN
	       FND_MESSAGE.SET_NAME('IGI','IGI_LOGGING_UNEXP_ERROR');
               FND_MESSAGE.SET_TOKEN('CODE',SQLCODE);
               FND_MESSAGE.SET_TOKEN('MSG',  SQLERRM);
	       FND_LOG.MESSAGE (l_unexp_level,'igi.plsql.igiitrhb.IGI_ITR_FUNDS_CONTROL_PKG.Itr_Enc_Update.msg8',TRUE);
         END IF;

    End If;
    APP_EXCEPTION.RAISE_EXCEPTION;
End Itr_Enc_Update;

Procedure Get_Gl_Fundschk_result_code(
    p_packet_id      IN     number,
    p_fc_result_code IN OUT NOCOPY varchar2) IS
  l_debug_loc	          varchar2(30) := 'Get_Gl_Fundschk_Result_Code';
  l_curr_calling_sequence varchar2(2000);
  l_fc_result_code_old     varchar2(30);

Begin
  ---------------------------------------------------------------------
  l_curr_calling_sequence := 'IGI_ITR_FUNDS_CONTROL_PKG.'||l_debug_loc;
  ---------------------------------------------------------------------

  l_fc_result_code_old  := p_fc_result_code;

  Select l.lookup_code
  Into p_fc_result_code
  From gl_lookups l
  Where lookup_type = 'FUNDS_CHECK_RESULT_CODE'
    And Exists (Select 'x'
                From gl_bc_packets bc
                Where result_code like 'F%'
                  And bc.result_code = l.lookup_code
                  And packet_id = p_packet_id)
    And rownum = 1;
Exception
  When Others Then
    p_fc_result_code := l_fc_result_code_old;
    If (SQLCODE <> -20001) Then
        FND_MESSAGE.SET_NAME('IGI','IGI_ITR_DEBUG');
        FND_MESSAGE.SET_TOKEN('ERROR',SQLERRM);
        FND_MESSAGE.SET_TOKEN('CALLING_SEQUENCE', l_curr_calling_sequence);
        FND_MESSAGE.SET_TOKEN('PARAMETERS', 'Packet_id = '|| to_char(p_packet_id)
            || ', Fundschecker Result code = ' || p_fc_result_code);

	IF ( l_unexp_level >=  l_debug_level) THEN
	       FND_MESSAGE.SET_NAME('IGI','IGI_LOGGING_UNEXP_ERROR');
               FND_MESSAGE.SET_TOKEN('CODE',SQLCODE);
               FND_MESSAGE.SET_TOKEN('MSG',  SQLERRM);
	       FND_LOG.MESSAGE (l_unexp_level,'igi.plsql.igiitrhb.IGI_ITR_FUNDS_CONTROL_PKG.Get_Gl_Fundschk_Result_Code.msg9',TRUE);
         END IF;
    End If;
    APP_EXCEPTION.RAISE_EXCEPTION;
End Get_Gl_Fundschk_Result_Code;

END IGI_ITR_FUNDS_CONTROL_PKG;

/
