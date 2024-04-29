--------------------------------------------------------
--  DDL for Package Body IGI_ITR_GL_INTERFACE_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IGI_ITR_GL_INTERFACE_PKG" AS
-- $Header: igiitrpb.pls 120.10.12010000.2 2008/08/04 13:03:56 sasukuma ship $
Cursor C_period(
    p_set_of_books_id IN igi_itr_charge_headers.set_of_books_id%type,
    p_period_name     IN igi_itr_charge_headers.it_period_name%type) IS
Select
    period_type,
    period_year,
    period_num
From gl_period_statuses
Where period_name = p_period_name
  And set_of_books_id = p_set_of_books_id
  And nvl(adjustment_period_flag,'N') = 'N'
  And application_id = (Select application_id
                        From fnd_application
                        Where application_short_name = 'SQLGL');

Cursor C_cat_name IS
Select user_je_category_name
From gl_je_categories
Where je_category_name = 'IGIITRCC';

Cursor C_source_name Is
Select user_je_source_name
From gl_je_sources
Where je_source_name = 'Internal Trading';

Cursor C_charge_lines(
    p_set_of_books_id   IN igi_itr_charge_headers.set_of_books_id%type,
    p_period_type       IN gl_period_statuses.period_type%type,
    p_start_period_year IN gl_period_statuses.period_year%type,
    p_start_period_num  IN gl_period_statuses.period_num%type,
    p_end_period_year   IN gl_period_statuses.period_year%type,
    p_end_period_num    IN gl_period_statuses.period_num%type) IS

--Bug 2885987. Modified to remove Multi Join Cartesian.

select
    h.it_header_id,
    l.it_service_line_id,
    l.it_line_num,
    decode(nvl(l.entered_dr,0),0,l.creation_code_combination_id,l.receiving_code_combination_id) ccid_dr,
    decode(nvl(l.entered_dr,0),0,l.entered_cr,l.entered_dr) amount,
    decode(nvl(l.entered_cr,0),0,l.creation_code_combination_id,l.receiving_code_combination_id) ccid_cr,
    l.encumbrance_flag,
    l.encumbered_amount,
    l.unencumbered_amount,
    p1.start_date gl_encumbered_date,
    h.it_period_name,
    h.currency_code,
    p1.period_num,
    p1.period_year,
    p1.quarter_num,
    h.name,   --shsaxena for bug 2948237
    l.description,
    l.charge_service_id,
    h.it_originator_id,
    ssv.name
from
    igi_itr_charge_headers h,
    igi_itr_charge_lines l,
    igi_itr_charge_service_ss_v ssv,
    gl_period_statuses p1
where p1.period_type = p_period_type
  and p1.set_of_books_id = p_set_of_books_id
  and nvl(p1.adjustment_period_flag,'N') = 'N'
  and p1.application_id = (select application_id
                           from fnd_application
                           where application_short_name = 'SQLGL')
  and (p1.period_year >= p_start_period_year
       and p1.period_year <= p_end_period_year)
  and (p1.period_num >= p_start_period_num
       and p1.period_num <= p_end_period_num)
  and h.it_period_name = p1.period_name
  and h.set_of_books_id = p1.set_of_books_id
  and l.it_header_id = h.it_header_id
  and l.status_flag = 'A'
  and nvl(l.posting_flag,'N') = 'N'
  and l.charge_service_id = ssv.charge_service_id;

Cursor C_current_period(
    p_set_of_books_id IN igi_itr_charge_headers.set_of_books_id%type ) IS
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

  l_debug_level number	:=	FND_LOG.G_CURRENT_RUNTIME_LEVEL;
  l_state_level number	:=	FND_LOG.LEVEL_STATEMENT;
  l_proc_level number	:=	FND_LOG.LEVEL_PROCEDURE;
  l_event_level number	:=	FND_LOG.LEVEL_EVENT;
  l_excep_level number	:=	FND_LOG.LEVEL_EXCEPTION;
  l_error_level number	:=	FND_LOG.LEVEL_ERROR;
  l_unexp_level number	:=	FND_LOG.LEVEL_UNEXPECTED;

Procedure Writelog(
    p_mesg       IN varchar2,
    p_debug_mode IN boolean ) IS
Begin
  If p_debug_mode Then
    fnd_file.put_line( fnd_file.log , p_mesg ) ;
  Else
    null;
  End if;
End Writelog;

Procedure Gl_Interface_Insert(
    p_status                   IN gl_interface.status%type,
    p_set_of_books_id          IN gl_interface.set_of_books_id%type,
    p_accounting_date          IN gl_interface.accounting_date%type,
    p_currency_code            IN gl_interface.currency_code%type,
    p_date_created             IN gl_interface.date_created%type,
    p_created_by               IN gl_interface.created_by%type,
    p_actual_flag              IN gl_interface.actual_flag%type,
    p_user_je_category_name    IN gl_interface.user_je_category_name%type,
    p_user_je_source_name      IN gl_interface.user_je_source_name%type,
    p_entered_dr               IN gl_interface.entered_dr%type,
    p_entered_cr               IN gl_interface.entered_cr%type,
    p_accounted_dr             IN gl_interface.accounted_dr%type,
    p_accounted_cr             IN gl_interface.accounted_cr%type,
    p_transaction_date         IN gl_interface.transaction_date%type,
    p_reference1               IN gl_interface.reference1%type,
    p_reference4               IN gl_interface.reference4%type,
    p_reference6               IN gl_interface.reference6%type,
    p_reference10              IN gl_interface.reference10%type,
    p_reference21              IN gl_interface.reference21%type,
    p_reference22              IN gl_interface.reference22%type,
    p_period_name              IN gl_interface.period_name%type,
    p_chart_of_accounts_id     IN gl_interface.chart_of_accounts_id%type,
    p_functional_currency_code IN gl_interface.functional_currency_code%type,
    p_code_combination_id      IN gl_interface.code_combination_id%type,
    p_group_id                 IN gl_interface.group_id%type);

PROCEDURE Init_Gl_Interface(
    p_int_control     IN OUT NOCOPY glcontrol,
    p_set_of_books_id IN     gl_sets_of_books.set_of_books_id%type);

PROCEDURE Insert_Control_Rec(
    p_int_control in glcontrol );

PROCEDURE Create_Actuals (
    errbuf            OUT NOCOPY varchar2,
    retcode           OUT NOCOPY number,
    p_set_of_books_id IN  igi_itr_charge_headers.set_of_books_id%type,
    p_start_period    IN  igi_itr_charge_headers.it_period_name%type,
    p_end_period      IN  igi_itr_charge_headers.it_period_name%type) IS
  l_int_control           glcontrol;
  l_chart_of_accounts_id  number;
  l_itr_enc_type_id       number;
  l_gl_user_id            number;
  l_current_period_name   igi_itr_charge_headers.it_period_name%type;
  l_current_period_num    gl_period_statuses.period_num%type;
  l_current_period_year   gl_period_statuses.period_year%type;
  l_current_quarter_num   gl_period_statuses.quarter_num%type;
  l_period_name           igi_itr_charge_headers.it_period_name%type;
  l_period_type           gl_period_statuses.period_type%type;
  l_start_period_year     gl_period_statuses.period_year%type;
  l_start_period_num      gl_period_statuses.period_num%type;
  l_end_period_year       gl_period_statuses.period_year%type;
  l_end_period_num        gl_period_statuses.period_num%type;
  l_it_header_id          igi_itr_charge_lines.it_header_id%type;
  l_it_service_line_id    igi_itr_charge_lines.it_service_line_id%type;
  l_it_line_num           igi_itr_charge_lines.it_line_num%type;
  l_ccid_dr               igi_itr_charge_lines.creation_code_combination_id%type;
  l_amount                igi_itr_charge_lines.entered_dr%type;
  l_ccid_cr               igi_itr_charge_lines.creation_code_combination_id%type;
  l_encumbrance_flag      igi_itr_charge_lines.encumbrance_flag%type;
  l_encumbered_amount     igi_itr_charge_lines.encumbered_amount%type;
  l_unencumbered_amount   igi_itr_charge_lines.unencumbered_amount%type;
  l_gl_encumbered_date    igi_itr_charge_lines.gl_encumbered_date%type;
  l_currency_code         igi_itr_charge_headers.currency_code%type;
  l_period_num            gl_period_statuses.period_num%type;
  l_period_year           gl_period_statuses.period_year%type;
  l_quarter_num           gl_period_statuses.quarter_num%type;
  l_charge_name           igi_itr_charge_headers.name%type;            --shsaxena for bug 294823
  l_description           igi_itr_charge_lines.description%type;
  l_reference_10          gl_interface.reference10%TYPE;               --shsaxena for bug 2948237
  l_charge_service_id     igi_itr_charge_lines.charge_service_id%type;
  l_originator_id         igi_itr_charge_headers.it_originator_id%type;
  l_service_name          igi_itr_service.name%type;
  l_status_code           varchar2(1);
  l_packet_id             number;
  l_fundschk_mode         varchar2(1);
  l_partial_reserv_flag   varchar2(1);
  l_return_code           varchar2(4);
  l_je_category_name      gl_je_categories.user_je_category_name%type;
  l_je_source_name        gl_je_sources.user_je_source_name%type;
  l_import_request_id     number;
  l_debug_loc	 	  varchar2(30) := 'Create_Actuals';
  l_debug_info	          varchar2(100);
  l_curr_calling_sequence varchar2(2000);

Begin
  --------------------------------------------------------------------
  l_curr_calling_sequence := 'IGI_ITR_GL_INTERFACE_PKG.'||l_debug_loc;
  -- Retrieve system variables to be used by fundschecker --
  --------------------------------------------------------------------
  IGI_ITR_FUNDS_CONTROL_PKG.Fundscheck_Init(
      l_chart_of_accounts_id,
      p_set_of_books_id,
      l_itr_enc_type_id,
      l_gl_user_id,
      l_curr_calling_sequence);

  --------------------------------------------------------
  l_debug_info := 'Open C_period cursor for start period';
  --------------------------------------------------------
  Open C_period(
      p_set_of_books_id,
      p_start_period);
  Fetch C_period into
      l_period_type,
      l_start_period_year,
      l_start_period_num;
  Close C_period;

  ------------------------------------------------------
  l_debug_info := 'Open C_period cursor for end period';
  ------------------------------------------------------
  Open C_period (
      p_set_of_books_id,
      p_end_period);
  Fetch C_period into
      l_period_type,
      l_end_period_year,
      l_end_period_num;
  Close C_period;

  -----------------------------------------
  l_debug_info := 'Open C_cat_name cursor';
  -----------------------------------------
  Open C_cat_name;
  Fetch C_cat_name into l_je_category_name;
  Close C_cat_name;

  -----------------------------------------
  l_debug_info := 'Open C_source_name cursor';
  -----------------------------------------
  Open C_source_name;
  Fetch C_source_name into l_je_source_name;
  Close C_source_name;

  --------------------------------------------------
  l_debug_info := 'Opening C_current_period Cursor';
  --------------------------------------------------
  Open C_current_period (p_set_of_books_id);
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

  ---------------------------------------------
  l_debug_info := 'Open C_charge_lines cursor';
  ---------------------------------------------
  Open C_charge_lines (
      p_set_of_books_id,
      l_period_type,
      l_start_period_year,
      l_start_period_num,
      l_end_period_year,
      l_end_period_num);
  Loop
      --------------------------------------------
      l_debug_info := 'Fetch from C_charge_lines';
      --------------------------------------------
      Fetch C_charge_lines Into
        l_it_header_id,
        l_it_service_line_id,
        l_it_line_num,
        l_ccid_dr,
        l_amount,
        l_ccid_cr,
        l_encumbrance_flag,
        l_encumbered_amount,
        l_unencumbered_amount,
        l_gl_encumbered_date,
        l_period_name,
        l_currency_code,
        l_period_num,
        l_period_year,
        l_quarter_num,
        l_charge_name,
        l_description,    --  shsaxena for bug 2948237
        l_charge_service_id,
        l_originator_id,
        l_service_name;
      Exit When C_charge_lines%notfound;

      -- ITR Encumbrance is Enabled

      If IGI_ITR_FUNDS_CONTROL_PKG.Encumbrance_Enabled(p_set_of_books_id)
         and l_encumbrance_flag = 'Y'
         and nvl(l_encumbered_amount,0) > 0
         and nvl(l_unencumbered_amount,0) = 0 Then
          l_status_code := 'P';
          --------------------------------------------------------
          -- Encumbrance enabled, setup GL Fundschecker parameters
          --------------------------------------------------------
          IGI_ITR_FUNDS_CONTROL_PKG.Setup_Gl_Fundschk_Params(
              l_packet_id,
              l_fundschk_mode,
              l_partial_reserv_flag,
              'A',  --Approval
              l_curr_calling_sequence);

          --------------------------------------------------------------
          -- Unencumbrance  the funds before creating the actual journal
          --------------------------------------------------------------
          IGI_ITR_FUNDS_CONTROL_PKG.Bc_Packets_Insert(
              l_packet_id,
              p_set_of_books_id,
              l_ccid_dr,
              l_amount,
              l_period_year,
              l_period_num,
              l_quarter_num,
              l_gl_user_id,
              l_itr_enc_type_id,
              l_it_service_line_id,
              l_charge_service_id,
              l_originator_id,
              'Internal Trading',
              'IGIITRCC',
              'E',
              l_period_name,
              l_currency_code,
              l_status_code, -- 'C'or 'P'
              'Y',  --l_reversal_flag,
              'R', --  l_status_flag,
              'Y', --l_prevent_encumbrance_flag,
              l_charge_name,--shsaxena for bug 2948237
         --   l_description,
              l_curr_calling_sequence);

          ---------------------------------------
          l_debug_info := 'Call GL_Fundschecker';
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
          l_debug_info := 'Process Return Code';
          --------------------------------------
          If (l_return_code in ('T', 'F', 'P')) Then
              -------------------------------------------------------------------------
              l_debug_info := 'Fundscheck failed, updating audit table - packet id';
              -------------------------------------------------------------------------
              null;
/*
              Update igi_itr_charge_lines_audit
              Set packet_id = l_packet_id
              Where it_header_id = l_it_header_id
                And it_service_line_id = l_it_service_line_id
                And reversal_flag = 'N';
*/
          Else
             -------------------------------------------------------------------------------
             l_debug_info := 'Updating Charge Lines and Audit tables - unencumbered amount';
             -------------------------------------------------------------------------------
             Update igi_itr_charge_lines
             Set unencumbered_amount = l_amount,
                 packet_id = l_packet_id
             Where it_header_id = l_it_header_id
               And it_service_line_id = l_it_service_line_id;

             Update igi_itr_charge_lines_audit
             Set unencumbered_amount = l_amount,
                 packet_id = l_packet_id
             Where it_header_id = l_it_header_id
               And it_service_line_id = l_it_service_line_id
               And reversal_flag = 'N';

             l_reference_10 := substr(l_charge_name || ' ' || l_it_line_num || ' ' || l_service_name,1,100);

             Gl_interface_insert(
                 'NEW',
                 p_set_of_books_id,
                 l_gl_encumbered_date,
                 l_currency_code,
                 sysdate,
                 l_gl_user_id,
                 'A',
                 l_je_category_name,
                 l_je_source_name,
                 l_amount,
                 NULL,
                 l_amount,
                 NULL,
                 l_gl_encumbered_date,
                 l_je_category_name,                -- reference1
                 l_charge_name,                     -- reference4   shsaxena for bug 2948237
               --l_description,                     -- reference4
                 l_je_source_name,                  -- reference6
                 l_reference_10,                    -- reference10  shsaxena for bug 2948237
              -- l_description || ' ' || l_it_line_num || ' ' || l_service_name, -- reference10
                 l_it_header_id,                    -- reference21
                 l_it_service_line_id,              -- reference22
                 l_period_name,
                 l_chart_of_accounts_id,
                 l_currency_code,
                 l_ccid_dr,
                 null );

             Gl_Interface_Insert(
                 'NEW',
                 p_set_of_books_id,
                 l_gl_encumbered_date,
                 l_currency_code,
                 sysdate,
                 l_gl_user_id,
                 'A',
                 l_je_category_name,
                 l_je_source_name,
                 NULL,
                 l_amount,
                 NULL,
                 l_amount,
                 l_gl_encumbered_date,
                 l_je_category_name,                -- reference1
                 l_charge_name,                       --reference4  shsaxena for bug 2948237
               --l_description,                     -- reference4
                 l_je_source_name,                  -- reference6
                 l_reference_10,                    -- reference10  --shsaxena  for bug 2948237
              -- l_description || ' ' || l_it_line_num || ' ' ||l_service_name, -- reference10
                 l_it_header_id,                    -- reference21
                 l_it_service_line_id,              -- reference22
                 l_period_name,
                 l_chart_of_accounts_id,
                 l_currency_code,
                 l_ccid_cr,
                 null);

             -----------------------------------------------------------------------
             l_debug_info := 'Updating Charge Lines and Audit Table - posting flag';
             -----------------------------------------------------------------------
             Update igi_itr_charge_lines
             Set posting_flag  = 'Y'
             Where it_header_id = l_it_header_id
               And it_service_line_id = l_it_service_line_id;

             Update igi_itr_charge_lines_audit
             Set posting_flag  = 'Y'
             Where it_header_id = l_it_header_id
               And reversal_flag = 'N';
          End If;

      Else  -- ITR Encumbrance is not enabled

/*
      --------------------------------------------------
      l_debug_info := 'Opening C_current_period Cursor';
      --------------------------------------------------
      Open C_current_period (p_set_of_books_id);
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
*/

         Gl_interface_insert(
             'NEW',
             p_set_of_books_id,
             l_gl_encumbered_date,
             l_currency_code,
             sysdate,
             l_gl_user_id,
             'A',
             l_je_category_name,
             l_je_source_name,
             l_amount,
             NULL,
             l_amount,
             NULL,
             l_gl_encumbered_date,
             l_je_category_name,                   -- reference1
             l_charge_name,                       --reference4   shsaxena for bug 2948237
            --l_description,                     -- reference4
             l_je_source_name,                   -- reference6
             l_reference_10,                     -- reference 10    --shsaxena  for bug 2948237
        --   l_description || ' ' || l_it_line_num || ' ' || l_service_name, -- reference10
             l_it_header_id,                    -- reference21
             l_it_service_line_id,              -- reference22
             l_period_name,
             l_chart_of_accounts_id,
             l_currency_code,
             l_ccid_dr,
             null );

         Gl_Interface_Insert(
             'NEW',
             p_set_of_books_id,
             l_gl_encumbered_date,
             l_currency_code,
             sysdate,
             l_gl_user_id,
             'A',
             l_je_category_name,
             l_je_source_name,
             NULL,
             l_amount,
             NULL,
             l_amount,
             l_gl_encumbered_date,
             l_je_category_name,                -- reference1
             l_charge_name,                      --reference4     shsaxena   for bug 2948237
           --l_description,                     -- reference4
             l_je_source_name,                  -- reference6
             l_reference_10,                     --shsaxena  for bug 2948237
           --l_description || ' ' || l_it_line_num || ' ' ||l_service_name, -- reference10
             l_it_header_id,                    -- reference21
             l_it_service_line_id,              -- reference22
             l_period_name,
             l_chart_of_accounts_id,
             l_currency_code,
             l_ccid_cr,
             null);

         -----------------------------------------------------------------------
         l_debug_info := 'Updating Charge Lines and Audit Table - posting flag';
         -----------------------------------------------------------------------
         Update igi_itr_charge_lines
         Set posting_flag  = 'Y'
         Where it_header_id = l_it_header_id
           And it_service_line_id = l_it_service_line_id;

         Update igi_itr_charge_lines_audit
         Set posting_flag  = 'Y'
         Where it_header_id = l_it_header_id
           And it_service_line_id = l_it_service_line_id
           And reversal_flag = 'N';
      End If;

  End Loop;
  Commit;


  Init_Gl_Interface(
     l_int_control,
     p_set_of_books_id);

  Insert_Control_Rec(l_int_control);

  ----------------------------------------------------
  l_debug_info := 'Submitting Journal Import Program';
  ----------------------------------------------------
  l_import_request_id := Fnd_Request.Submit_Request(
                             'SQLGL'
                            ,'GLLEZL'
                            ,NULL
                            ,NULL
                            ,FALSE
                            ,l_int_control.interface_run_id
                            ,p_set_of_books_id
                            ,'N'
                            ,NULL
                            ,NULL
                            ,'N'
                            ,'N');
Exception
  When Others Then
    If (SQLCODE <> -20001) Then
        FND_MESSAGE.SET_NAME('IGI','IGI_ITR_DEBUG');
        FND_MESSAGE.SET_TOKEN('ERROR',SQLERRM);
        FND_MESSAGE.SET_TOKEN('CALLING_SEQUENCE', l_curr_calling_sequence);
        FND_MESSAGE.SET_TOKEN('PARAMETERS', 'Set of Books Id = ' || to_char(p_set_of_books_id)
            ||', Period Start = '|| p_start_period
            ||', Period End = '|| p_end_period);
        FND_MESSAGE.SET_TOKEN('DEBUG_INFO',l_debug_info);
	IF ( l_unexp_level >=  l_debug_level) THEN
	       FND_MESSAGE.SET_NAME('IGI','IGI_LOGGING_UNEXP_ERROR');
               FND_MESSAGE.SET_TOKEN('CODE',SQLCODE);
               FND_MESSAGE.SET_TOKEN('MSG',  SQLERRM);
	       FND_LOG.MESSAGE (l_unexp_level,'igi.plsql.igiitrpb.IGI_ITR_GL_INTERFACE_PKG.Create_Actuals.msg1',TRUE);
         END IF;
    End If;
    APP_EXCEPTION.RAISE_EXCEPTION;
End Create_Actuals ;

Procedure Init_Gl_Interface(
    p_int_control     IN OUT NOCOPY glcontrol,
    p_set_of_books_id IN     gl_sets_of_books.set_of_books_id%type) IS
  l_debug_loc             varchar2(30) := 'Init_Gl_Interface';
  l_curr_calling_sequence varchar2(2000);
  l_debug_info            varchar2(100);
  l_int_control_old       glcontrol;
Begin
  --------------------------------------------------------------------
  l_curr_calling_sequence := 'IGI_ITR_GL_INTERFACE_PKG.'||l_debug_loc;
  l_debug_info := 'Initializing GL Interface control variables';
  --------------------------------------------------------------------

  /* ssemwal for NOCOPY */
  /* added l_int_control_old */

  l_int_control_old := p_int_control;

  Select gl_journal_import_s.Nextval,
    p_set_of_books_id,
    NULL, -- Narayanan said comment it (GL_INTERFACE_CONTROL_S.nextval,)
    'S',
    'Internal Trading'
  Into
    p_int_control.interface_run_id,
    p_int_control.set_of_books_id,
    p_int_control.group_id,
    p_int_control.status,
    p_int_control.je_source_name
  From sys.dual ;
Exception
  When Others Then
    p_int_control := l_int_control_old;
    If (SQLCODE <> -20001) Then
        FND_MESSAGE.SET_NAME('IGI','IGI_ITR_DEBUG');
        FND_MESSAGE.SET_TOKEN('ERROR',SQLERRM);
        FND_MESSAGE.SET_TOKEN('CALLING_SEQUENCE', l_curr_calling_sequence);
        FND_MESSAGE.SET_TOKEN('DEBUG_INFO',l_debug_info);
 	IF ( l_unexp_level >=  l_debug_level) THEN
	       FND_MESSAGE.SET_NAME('IGI','IGI_LOGGING_UNEXP_ERROR');
               FND_MESSAGE.SET_TOKEN('CODE',SQLCODE);
               FND_MESSAGE.SET_TOKEN('MSG',  SQLERRM);
	       FND_LOG.MESSAGE (l_unexp_level,'igi.plsql.igiitrpb.IGI_ITR_GL_INTERFACE_PKG.Init_Gl_Interface.msg2',TRUE);
         END IF;
    End If;
    APP_EXCEPTION.RAISE_EXCEPTION;
End Init_Gl_Interface;

PROCEDURE Insert_Control_Rec(
    p_int_control in glcontrol) IS
  l_debug_loc             varchar2(30) := 'Insert_Control_Rec';
  l_curr_calling_sequence varchar2(2000);
  l_debug_info            varchar2(100);
BEGIN
  --------------------------------------------------------------------
  l_curr_calling_sequence := 'IGI_ITR_GL_INTERFACE_PKG.'||l_debug_loc;
  l_debug_info := 'Inserting into gl_interface_control';
  --------------------------------------------------------------------
  Insert Into gl_interface_control(
    je_source_name,
    status,
    interface_run_id,
    group_id,
    set_of_books_id)
  Values(
    p_int_control.je_source_name,
    p_int_control.status,
    p_int_control.interface_run_id,
    p_int_control.group_id,
    p_int_control.set_of_books_id);
Exception
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
	       FND_LOG.MESSAGE (l_unexp_level,'igi.plsql.igiitrpb.IGI_ITR_GL_INTERFACE_PKG.Insert_Control_Rec.msg3',TRUE);
         END IF;
    EnD If;
    APP_EXCEPTION.RAISE_EXCEPTION;
End Insert_Control_Rec;

Procedure Gl_Interface_Insert(
    p_status                   IN gl_interface.status%type,
    p_set_of_books_id          IN gl_interface.set_of_books_id%type,
    p_accounting_date          IN gl_interface.accounting_date%type,
    p_currency_code            IN gl_interface.currency_code%type,
    p_date_created             IN gl_interface.date_created%type,
    p_created_by               IN gl_interface.created_by%type,
    p_actual_flag              IN gl_interface.actual_flag%type,
    p_user_je_category_name    IN gl_interface.user_je_category_name%type,
    p_user_je_source_name      IN gl_interface.user_je_source_name%type,
    p_entered_dr               IN gl_interface.entered_dr%type,
    p_entered_cr               IN gl_interface.entered_cr%type,
    p_accounted_dr             IN gl_interface.accounted_dr%type,
    p_accounted_cr             IN gl_interface.accounted_cr%type,
    p_transaction_date         IN gl_interface.transaction_date%type,
    p_reference1               IN gl_interface.reference1%type,
    p_reference4               IN gl_interface.reference4%type,
    p_reference6               IN gl_interface.reference6%type,
    p_reference10              IN gl_interface.reference10%type,
    p_reference21              IN gl_interface.reference21%type,
    p_reference22              IN gl_interface.reference22%type,
    p_period_name              IN gl_interface.period_name%type,
    p_chart_of_accounts_id     IN gl_interface.chart_of_accounts_id%type,
    p_functional_currency_code IN gl_interface.functional_currency_code%type,
    p_code_combination_id      IN gl_interface.code_combination_id%type,
    p_group_id                 IN gl_interface.group_id%type) IS
  l_debug_loc             varchar2(30) := 'GL_interface';
  l_curr_calling_sequence varchar2(2000);
  l_debug_info            varchar2(100);
Begin
  ----------------------------------------------------------------------
  l_curr_calling_sequence := 'IGI_ITR_GL_INTERFACE_PKG.' || l_debug_loc;
  l_debug_info := 'Inserting record into gl_interface';
  ----------------------------------------------------------------------
  Insert Into gl_interface(
      status,
      set_of_books_id,
      accounting_date,
      currency_code,
      date_created,
      created_by,
      actual_flag,
      user_je_category_name,
      user_je_source_name,
      entered_dr,
      entered_cr,
      accounted_dr,
      accounted_cr,
      transaction_date,
      reference1,
      reference4,
      reference6,
      reference10,
      reference21,
      reference22,
      period_name,
      chart_of_accounts_id,
      functional_currency_code,
      code_combination_id,
      group_id)
  Values(
      p_status,
      p_set_of_books_id,
      p_accounting_date,
      p_currency_code,
      p_date_created,
      p_created_by,
      p_actual_flag,
      p_user_je_category_name,
      p_user_je_source_name,
      p_entered_dr,
      p_entered_cr,
      p_accounted_dr,
      p_accounted_cr,
      p_transaction_date,
      p_reference1,
      p_reference4,
      p_reference6,
      p_reference10,
      p_reference21,
      p_reference22,
      p_period_name,
      p_chart_of_accounts_id,
      p_currency_code,
      p_code_combination_id,
      p_group_id );
Exception
  When Others Then
    If (SQLCODE <> -20001) Then
        FND_MESSAGE.SET_NAME('IGI','IGI_ITR_DEBUG');
        FND_MESSAGE.SET_TOKEN('ERROR',SQLERRM);
        FND_MESSAGE.SET_TOKEN('CALLING_SEQUENCE', l_curr_calling_sequence);
        FND_MESSAGE.SET_TOKEN('PARAMETERS', 'Status = ' || p_status
            ||', Set_of_books_id  = '|| to_char(p_set_of_books_id)
            ||', Accounting_date  = '|| to_char(p_accounting_date,'DD-MON-YYYY')
            ||', Currency Code  = '|| p_currency_code
            ||', Date Created = '|| to_char(p_date_created,'DD-MON-YYYY')
            ||', Created By = '|| to_char(p_created_by)
            ||', Actual flag = '|| p_actual_flag
            ||', User Je Category Name = '|| p_user_je_category_name
            ||', User Je Source Name = '|| p_user_je_source_name
            ||', Entered Dr = '|| to_char(p_entered_dr)
            ||', Entered Cr = '|| to_char(p_entered_cr)
            ||', Accounted Dr = '|| to_char(p_accounted_dr)
            ||', Accounted Cr = '|| to_char(p_accounted_cr)
            ||', Transaction Date  = '|| to_char(p_transaction_date,'DD-MON-YYYY')
            ||', Reference1 = '|| p_reference1
            ||', Reference4 = '|| p_reference4
            ||', Reference6 = '|| p_reference6
            ||', Reference10 = '|| p_reference10
            ||', Reference21 = '|| p_reference21
            ||', Reference22 = '|| p_reference22
            ||', Period Name = '|| p_period_name
            ||', Chart of Accounts Id = '|| to_char(p_chart_of_accounts_id)
            ||', Functional Currency Code = '|| p_currency_code
            ||', Code Combination Id = '|| to_char(p_code_combination_id)
            ||', Group Id = '|| to_char(p_group_id));
        FND_MESSAGE.SET_TOKEN('DEBUG_INFO',l_debug_info);
        IF ( l_unexp_level >=  l_debug_level) THEN
	       FND_MESSAGE.SET_NAME('IGI','IGI_LOGGING_UNEXP_ERROR');
               FND_MESSAGE.SET_TOKEN('CODE',SQLCODE);
               FND_MESSAGE.SET_TOKEN('MSG',  SQLERRM);
	       FND_LOG.MESSAGE (l_unexp_level,'igi.plsql.igiitrpb.IGI_ITR_GL_INTERFACE_PKG.Gl_Interface_Insert.msg4',TRUE);
         END IF;
    End If;
    APP_EXCEPTION.RAISE_EXCEPTION;
End Gl_Interface_Insert;

END IGI_ITR_GL_INTERFACE_PKG;

/
