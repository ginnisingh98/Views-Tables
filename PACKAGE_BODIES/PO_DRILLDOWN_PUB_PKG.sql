--------------------------------------------------------
--  DDL for Package Body PO_DRILLDOWN_PUB_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PO_DRILLDOWN_PUB_PKG" AS
/* $Header: PO_DRILLDOWN_PUB_PKG.plb 120.2.12010000.4 2014/05/29 09:57:16 sbontala ship $ */
G_PACKAGE_NAME CONSTANT VARCHAR2(30) := 'PO_DRILLDOWN_PUB_PKG';

-- Logging global constants
D_PACKAGE_BASE CONSTANT VARCHAR2(100) := PO_LOG.get_package_base(G_PACKAGE_NAME);

-----------------------------------------------------------------------------
--Start of Comments
--Name: DRILLDOWN
--Pre-reqs:
--  This would work for commited transactions
--Modifies:
--  n/a
--Locks:
--  n/a
--Function:
--  Provides drilldown from Subledger journal entry/inquiry to the
--  PO Transactions.
--Parameters:
--IN:
--p_application_id
--  Subledger application internal identifier
--p_ledger_id
--  Event ledger identifier
--p_legal_entity_id
--  Legal entity identifier
--p_entity_code
--  Event entity internal code
--p_event_class_code
--  Event class internal code
--p_event_type_code
--  Event type internal code
--p_source_id_int_1
--  Generic system transaction identifiers
--p_source_id_int_2
--  Generic system transaction identifiers
--p_source_id_int_3
--  Generic system transaction identifiers
--p_source_id_int_4
--  Generic system transaction identifiers
--p_source_id_char_1
--  Generic system transaction identifiers
--p_source_id_char_2
--  Generic system transaction identifiers
--p_source_id_char_3
--  Generic system transaction identifiers
--p_source_id_char_4
--  Generic system transaction identifiers
--p_security_id_int_1
--  Generic system transaction identifiers
--p_security_id_int_2
--  Generic system transaction identifiers
--p_security_id_int_3
--  Generic system transaction identifiers
--p_security_id_char_1
--  Generic system transaction identifiers
--p_security_id_char_2
--  Generic system transaction identifiers
--p_security_id_char_3
--  Generic system transaction identifiers
--p_valuation_method
--  Valuation Method internal identifier
--IN/OUT:
--p_user_interface_type
--  Determines the user interface type. Possible values:
--  FORM - indicates that the source transaction is
--  displayed using an Oracle*Forms based user
--  interface
--  HTML- indicates that the source transaction is
--  displayed using HTML based user interface
--  NONE- Use if the drill down is not supported
--  for an event class or event type.
--p_function_name
--  Name of the Oracle Application Object Library function defined to open the
--  transaction form; used only if the page is a FORM page
--p_parameters
--  An Oracle Application Object Library Function can have its own arguments or
--  parameters. Subledger Accounting expectsdevelopers to return these arguments
--  via p_parameters. This string can take any number of parameters and you can
--  also use it to set some of the parameters dynamically.
--  The additional parameters must be passed in the appropriate format. For the
--  Oracle*Forms based UI the parameters must be space delimited
--  (for example, "param1=value1 param2=value2").
--  For the HTML based UI, the parameters must be separated with '&'
--  (for example,/OA_HTML/OA.jsp?OAFunc=function_name'&'||param1=value1||'&'||parma2||'&'||value2).
--
--Notes:
--  n/a
--End of Comments
-----------------------------------------------------------------------------
PROCEDURE DRILLDOWN(p_application_id      IN INTEGER,
                    p_ledger_id           IN INTEGER,
                    p_legal_entity_id     IN INTEGER DEFAULT NULL,
                    p_entity_code         IN VARCHAR2,
                    p_event_class_code    IN VARCHAR2,
                    p_event_type_code     IN VARCHAR2,
                    p_source_id_int_1     IN INTEGER DEFAULT NULL,
                    p_source_id_int_2     IN INTEGER DEFAULT NULL,
                    p_source_id_int_3     IN INTEGER DEFAULT NULL,
                    p_source_id_int_4     IN INTEGER DEFAULT NULL,
                    p_source_id_char_1    IN VARCHAR2 DEFAULT NULL,
                    p_source_id_char_2    IN VARCHAR2 DEFAULT NULL,
                    p_source_id_char_3    IN VARCHAR2 DEFAULT NULL,
                    p_source_id_char_4    IN VARCHAR2 DEFAULT NULL,
                    p_security_id_int_1   IN INTEGER DEFAULT NULL,
                    p_security_id_int_2   IN INTEGER DEFAULT NULL,
                    p_security_id_int_3   IN INTEGER DEFAULT NULL,
                    p_security_id_char_1  IN VARCHAR2 DEFAULT NULL,
                    p_security_id_char_2  IN VARCHAR2 DEFAULT NULL,
                    p_security_id_char_3  IN VARCHAR2 DEFAULT NULL,
                    p_valuation_method    IN VARCHAR2 DEFAULT NULL,
                    p_event_id            IN INTEGER DEFAULT NULL,
                    p_user_interface_type IN OUT NOCOPY VARCHAR2,
                    p_function_name       IN OUT NOCOPY VARCHAR2,
                    p_parameters          IN OUT NOCOPY VARCHAR2) IS
l_document_id NUMBER;
l_module_name CONSTANT VARCHAR2(100) := 'DRILLDOWN';
d_module_base CONSTANT VARCHAR2(100) := PO_LOG.get_subprogram_base( D_PACKAGE_BASE, l_module_name);
d_progress NUMBER;
l_global_agreement_flag PO_HEADERS_ALL.global_agreement_flag%type;
l_document_subtype PO_HEADERS_ALL.type_lookup_code%type;
l_bpa_header_id  PO_RELEASES_ALL.po_header_id%type;
l_federal_flag po_requisition_headers_all.FEDERAL_FLAG%type;
BEGIN
  d_progress :=0;
  IF (PO_LOG.d_proc) THEN
    PO_LOG.proc_begin(d_module_base);
    PO_LOG.proc_begin(d_module_base,'p_application_id',p_application_id);
    PO_LOG.proc_begin(d_module_base,'p_ledger_id',p_ledger_id);
    PO_LOG.proc_begin(d_module_base,'p_legal_entity_id',p_legal_entity_id);
    PO_LOG.proc_begin(d_module_base,'p_entity_code',p_entity_code);
    PO_LOG.proc_begin(d_module_base,'p_event_class_code',p_event_class_code);
    PO_LOG.proc_begin(d_module_base,'p_event_type_code',p_event_type_code);
    PO_LOG.proc_begin(d_module_base,'p_source_id_int_1',p_source_id_int_1);
    PO_LOG.proc_begin(d_module_base,'p_source_id_int_2',p_source_id_int_2);
    PO_LOG.proc_begin(d_module_base,'p_source_id_int_3',p_source_id_int_3);
    PO_LOG.proc_begin(d_module_base,'p_source_id_int_4',p_source_id_int_4);
    PO_LOG.proc_begin(d_module_base,'p_source_id_char_1',p_source_id_char_1);
    PO_LOG.proc_begin(d_module_base,'p_source_id_char_2',p_source_id_char_2);
    PO_LOG.proc_begin(d_module_base,'p_source_id_char_3',p_source_id_char_3);
    PO_LOG.proc_begin(d_module_base,'p_source_id_char_4',p_source_id_char_4);
    PO_LOG.proc_begin(d_module_base,'p_security_id_int_1',p_security_id_int_1);
    PO_LOG.proc_begin(d_module_base,'p_security_id_int_2',p_security_id_int_2);
    PO_LOG.proc_begin(d_module_base,'p_security_id_int_3',p_security_id_int_3);
    PO_LOG.proc_begin(d_module_base,'p_security_id_char_1',p_security_id_char_1);
    PO_LOG.proc_begin(d_module_base,'p_security_id_char_2',p_security_id_char_2);
    PO_LOG.proc_begin(d_module_base,'p_security_id_char_3',p_security_id_char_3);
    PO_LOG.proc_begin(d_module_base,'p_valuation_method',p_valuation_method);
    PO_LOG.proc_begin(d_module_base,'p_user_interface_type',p_user_interface_type);
    PO_LOG.proc_begin(d_module_base,'p_function_name',p_function_name);
    PO_LOG.proc_begin(d_module_base,'p_parameters',p_parameters);
  END IF;
  d_progress :=10;
  l_document_id :=p_source_id_int_1;
  d_progress :=20;
  IF (p_application_id = 201) THEN
    d_progress :=30;
    IF (p_event_class_code IN ('REQUISITION')) THEN
    d_progress :=35;
    Begin
      SELECT nvl(FEDERAL_FLAG,'N')
      INTO   l_federal_flag
      FROM po_requisition_headers_all
      WHERE requisition_header_id = p_source_id_int_1;
   Exception
      WHEN NO_DATA_FOUND Then
      l_federal_flag := 'N';
      WHEN OTHERS THEN
      l_federal_flag := 'N';
   End;
    d_progress :=36;
     IF l_federal_flag = 'Y' THEN
        p_user_interface_type := 'HTML';
        p_parameters          := '/OA_HTML/OA.jsp?OAFunc=ICX_POR_REQMGMT_DETAIL'||'&'||'reqHeaderId=' || to_char(l_document_id)||'&'||'porMode=viewOnly';
     ELSE
      p_user_interface_type := 'FORM'; -- Forms based UI
      p_function_name       := 'XLA_POXRQVRQ';
      p_parameters          := 'FORM_USAGE_MODE = GL_DRILLDOWN POXDOCON_ACCESS=N TRANSACTION_ID = '||to_char(l_document_id);
     END IF;
    ELSIF (p_event_class_code = 'PO_PA') THEN
      d_progress :=40;
      SELECT nvl(global_agreement_flag,'N'),
             type_lookup_code
      INTO   l_global_agreement_flag,
             l_document_subtype
      FROM po_headers_all
      WHERE po_header_id=p_source_id_int_1;
      d_progress :=50;
      IF(l_document_subtype ='STANDARD')THEN
        d_progress :=60;
        p_user_interface_type := 'HTML';
        p_parameters          := '/OA_HTML/OA.jsp?OAFunc=PO_ORDER'||'&'||'poHeaderId=' || to_char(l_document_id)||'&'||'poMode=viewOnly';
      ELSIF(l_document_subtype ='BLANKET' AND l_global_agreement_flag='Y')THEN
        d_progress :=70;
        p_user_interface_type := 'HTML';
        p_parameters          := '/OA_HTML/OA.jsp?OAFunc=PO_BLANKET'||'&'||'poHeaderId=' || to_char(l_document_id)||'&'||'poMode=viewOnly';
      ELSIF((l_document_subtype='BLANKET' AND l_global_agreement_flag='N')
             OR l_document_subtype='PLANNED')THEN
        d_progress :=80;
        p_user_interface_type := 'FORM'; -- Forms based UI
        p_function_name       := 'XLA_POXPOVPO';
        p_parameters          := 'FORM_USAGE_MODE = GL_DRILLDOWN ACCESS_LEVEL_CODE= VIEW_ONLY TRANSACTION_ID= ' || to_char(l_document_id) ;
      END IF;
    ELSIF (p_event_class_code = 'RELEASE') THEN
        d_progress :=90;
        select po_header_id
        into l_bpa_header_id
        from po_releases_all
        where po_release_id=l_document_id;
        d_progress :=100;
        p_user_interface_type := 'FORM'; -- Forms based UI
        p_function_name       := 'XLA_POXPOVPO';
        p_parameters          := 'FORM_USAGE_MODE = GL_DRILLDOWN ACCESS_LEVEL_CODE= VIEW_ONLY PO_RELEASE_ID= ' || to_char(l_document_id||' TRANSACTION_ID=' ||to_char(l_bpa_header_id));
    ELSE
      d_progress :=110;
      p_user_interface_type := 'NONE';
    END IF;

  END IF;

  IF (PO_LOG.d_proc) THEN
    PO_LOG.proc_end(d_module_base);
    PO_LOG.proc_end(d_module_base,'p_user_interface_type',p_user_interface_type);
    PO_LOG.proc_end(d_module_base,'p_function_name',p_function_name);
    PO_LOG.proc_end(d_module_base,'p_parameters',p_parameters);
  END IF;
EXCEPTION
WHEN OTHERS THEN
  IF (PO_LOG.d_exc) THEN
    PO_LOG.exc(d_module_base, d_progress, SQLCODE || SQLERRM);
    PO_LOG.exc(d_module_base,'p_user_interface_type',p_user_interface_type);
    PO_LOG.exc(d_module_base,'p_function_name',p_function_name);
    PO_LOG.exc(d_module_base,'p_parameters',p_parameters);
  END IF;
  RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
END DRILLDOWN;
-----------------------------------------------------------------------------
--<<Bug#18697086  Start>>--
--Added new overloading function passing event Id as extra paramter
-- This is required only in 12.2.4 , but XLA code is same for 12.1\12.2
--branch lines. Hence new procedure is required in 12.1.3 to avoid
-- signature change errors.
--Start of Comments
--Name: DRILLDOWN
--Pre-reqs:
--  This would work for commited transactions
--Modifies:
--  n/a
--Locks:
--  n/a
--Function:
--  Provides drilldown from Subledger journal entry/inquiry to the
--  PO Transactions.
--Parameters:
--IN:
--p_application_id
--  Subledger application internal identifier
--p_ledger_id
--  Event ledger identifier
--p_legal_entity_id
--  Legal entity identifier
--p_entity_code
--  Event entity internal code
--p_event_class_code
--  Event class internal code
--p_event_type_code
--  Event type internal code
--p_source_id_int_1
--  Generic system transaction identifiers
--p_source_id_int_2
--  Generic system transaction identifiers
--p_source_id_int_3
--  Generic system transaction identifiers
--p_source_id_int_4
--  Generic system transaction identifiers
--p_source_id_char_1
--  Generic system transaction identifiers
--p_source_id_char_2
--  Generic system transaction identifiers
--p_source_id_char_3
--  Generic system transaction identifiers
--p_source_id_char_4
--  Generic system transaction identifiers
--p_security_id_int_1
--  Generic system transaction identifiers
--p_security_id_int_2
--  Generic system transaction identifiers
--p_security_id_int_3
--  Generic system transaction identifiers
--p_security_id_char_1
--  Generic system transaction identifiers
--p_security_id_char_2
--  Generic system transaction identifiers
--p_security_id_char_3
--  Generic system transaction identifiers
--p_valuation_method
--  Valuation Method internal identifier
-- p_event_id
-- Event id of the transaction
--IN/OUT:
--p_user_interface_type
--  Determines the user interface type. Possible values:
--  FORM - indicates that the source transaction is
--  displayed using an Oracle*Forms based user
--  interface
--  HTML- indicates that the source transaction is
--  displayed using HTML based user interface
--  NONE- Use if the drill down is not supported
--  for an event class or event type.
--p_function_name
--  Name of the Oracle Application Object Library function defined to open the
--  transaction form; used only if the page is a FORM page
--p_parameters
--  An Oracle Application Object Library Function can have its own arguments or
--  parameters. Subledger Accounting expectsdevelopers to return these arguments
--  via p_parameters. This string can take any number of parameters and you can
--  also use it to set some of the parameters dynamically.
--  The additional parameters must be passed in the appropriate format. For the
--  Oracle*Forms based UI the parameters must be space delimited
--  (for example, "param1=value1 param2=value2").
--  For the HTML based UI, the parameters must be separated with '&'
--  (for example,/OA_HTML/OA.jsp?OAFunc=function_name'&'||param1=value1||'&'||parma2||'&'||value2).
--
--Notes:
--  n/a
--End of Comments
-----------------------------------------------------------------------------
PROCEDURE DRILLDOWN(p_application_id      IN INTEGER,
                    p_ledger_id           IN INTEGER,
                    p_legal_entity_id     IN INTEGER DEFAULT NULL,
                    p_entity_code         IN VARCHAR2,
                    p_event_class_code    IN VARCHAR2,
                    p_event_type_code     IN VARCHAR2,
                    p_source_id_int_1     IN INTEGER DEFAULT NULL,
                    p_source_id_int_2     IN INTEGER DEFAULT NULL,
                    p_source_id_int_3     IN INTEGER DEFAULT NULL,
                    p_source_id_int_4     IN INTEGER DEFAULT NULL,
                    p_source_id_char_1    IN VARCHAR2 DEFAULT NULL,
                    p_source_id_char_2    IN VARCHAR2 DEFAULT NULL,
                    p_source_id_char_3    IN VARCHAR2 DEFAULT NULL,
                    p_source_id_char_4    IN VARCHAR2 DEFAULT NULL,
                    p_security_id_int_1   IN INTEGER DEFAULT NULL,
                    p_security_id_int_2   IN INTEGER DEFAULT NULL,
                    p_security_id_int_3   IN INTEGER DEFAULT NULL,
                    p_security_id_char_1  IN VARCHAR2 DEFAULT NULL,
                    p_security_id_char_2  IN VARCHAR2 DEFAULT NULL,
                    p_security_id_char_3  IN VARCHAR2 DEFAULT NULL,
                    p_valuation_method    IN VARCHAR2 DEFAULT NULL,
                    p_user_interface_type IN OUT NOCOPY VARCHAR2,
                    p_function_name       IN OUT NOCOPY VARCHAR2,
                    p_parameters          IN OUT NOCOPY VARCHAR2) IS

l_event_id xla_events.event_id%TYPE:= NULL;
l_module_name CONSTANT VARCHAR2(100) := 'DRILLDOWN';
d_module_base CONSTANT VARCHAR2(100) := PO_LOG.get_subprogram_base( D_PACKAGE_BASE, l_module_name);
d_progress NUMBER;

BEGIN

d_progress := 10;

          DRILLDOWN(p_application_id      =>  p_application_id,
                    p_ledger_id           =>  p_ledger_id,
                    p_legal_entity_id     =>  p_legal_entity_id,
                    p_entity_code         =>  p_entity_code,
                    p_event_class_code    =>  p_event_class_code,
                    p_event_type_code     =>  p_event_type_code,
                    p_source_id_int_1     =>  p_source_id_int_1,
                    p_source_id_int_2     =>  p_source_id_int_2,
                    p_source_id_int_3     =>  p_source_id_int_3,
                    p_source_id_int_4     =>  p_source_id_int_4,
                    p_source_id_char_1    =>  p_source_id_char_1,
                    p_source_id_char_2    =>  p_source_id_char_2,
                    p_source_id_char_3    =>  p_source_id_char_3,
                    p_source_id_char_4    =>  p_source_id_char_4,
                    p_security_id_int_1   =>  p_security_id_int_1,
                    p_security_id_int_2   =>  p_security_id_int_2,
                    p_security_id_int_3   =>  p_security_id_int_3,
                    p_security_id_char_1  =>  p_security_id_char_1,
                    p_security_id_char_2  =>  p_security_id_char_2,
                    p_security_id_char_3  =>  p_security_id_char_3,
                    p_valuation_method    =>  p_valuation_method,
		    p_event_id            =>  l_event_id,
                    p_user_interface_type =>  p_user_interface_type,
                    p_function_name       =>  p_function_name,
                    p_parameters          =>  p_parameters
		    );
EXCEPTION
WHEN OTHERS THEN
  IF (PO_LOG.d_exc) THEN
    PO_LOG.exc(d_module_base, d_progress, SQLCODE || SQLERRM);
    PO_LOG.exc(d_module_base,'p_user_interface_type',p_user_interface_type);
    PO_LOG.exc(d_module_base,'p_function_name',p_function_name);
    PO_LOG.exc(d_module_base,'p_parameters',p_parameters);
  END IF;
  RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
END DRILLDOWN;
--<<Bug#18697086  END>>--
END PO_DRILLDOWN_PUB_PKG;

/
