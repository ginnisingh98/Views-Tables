--------------------------------------------------------
--  DDL for Package Body IGI_IAC_XLA_EVENTS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IGI_IAC_XLA_EVENTS_PKG" as
/* $Header: igixlehb.pls 120.1.12010000.4 2009/08/10 06:32:14 gaprasad ship $   */
--===========================FND_LOG.START=====================================

g_state_level NUMBER	  ;
g_proc_level  NUMBER	  ;
g_event_level NUMBER	  ;
g_excep_level NUMBER	  ;
g_error_level NUMBER	  ;
g_unexp_level NUMBER	  ;
g_path        VARCHAR2(1000) ;

--===========================FND_LOG.END=====================================


FUNCTION create_revaluation_event
           (p_revaluation_id         IN NUMBER,
            p_event_id               IN OUT NOCOPY NUMBER
           ) return boolean IS

   l_reval_source_info  XLA_EVENTS_PUB_PKG.t_event_source_info;
   l_security_context XLA_EVENTS_PUB_PKG.t_security;
   l_event_type_code  varchar2(30);
   l_event_date       date;
   l_event_status     varchar2(30);
   l_valuation_method varchar2(30);
   l_book_type_code   varchar2(30);
   l_revaluation_date date;
   l_ledger_id             gl_sets_of_books.set_of_books_id%TYPE;
   l_chart_of_accounts_id  gl_sets_of_books.chart_of_accounts_id%TYPE;
   l_currency_code         gl_sets_of_books.currency_code%TYPE;
   l_precision             fnd_currencies.precision%TYPE;
   invalid_ledger          exception;
   l_path_name             varchar2(150) := g_path || 'create_revaluation_event';

BEGIN
   igi_iac_debug_pkg.debug_other_string(p_level => g_state_level,
   p_full_path => l_path_name,
   p_string => 'create_revaluation_event....Welcome... ');

   select book_type_code,revaluation_date
   into l_book_type_code,l_revaluation_date
   from igi_iac_revaluations
   where revaluation_id =p_revaluation_id;

   igi_iac_debug_pkg.debug_other_string(p_level => g_state_level,
   p_full_path => l_path_name,
   p_string => 'l_book_type_code = ' || l_book_type_code);

   -- Find the set_of_books_id and the currency code
   IF (igi_iac_common_utils.get_book_gl_info(l_book_type_code
                                            ,l_ledger_id
                                            ,l_chart_of_accounts_id
                                            ,l_currency_code
                                            ,l_precision))  THEN

       igi_iac_debug_pkg.debug_other_string(p_level => g_state_level,
	   p_full_path => l_path_name,
	   p_string => 'GL book info found for ledger_id = '||l_ledger_id);
    ELSE
       raise invalid_ledger;
    END IF;

   l_reval_source_info.application_id        := 140; --Assets
   l_reval_source_info.legal_entity_id       := NULL;
   l_reval_source_info.ledger_id             := l_ledger_id;
   l_reval_source_info.transaction_number    := to_char(p_revaluation_id);
   l_reval_source_info.source_id_int_1       := p_revaluation_id;
-- l_reval_source_info.source_id_int_2       := l_book_type_code;
   l_reval_source_info.source_id_char_1      := l_book_type_code; -- Bug 8624087
   l_reval_source_info.entity_type_code      := 'TRANSACTIONS';
   l_event_type_code                         := 'INFLATION_REVALUATION';
   l_valuation_method                        := l_book_type_code;
   l_event_date                              := sysdate; --l_revaluation_date;
   l_event_status                            := XLA_EVENTS_PUB_PKG.C_EVENT_UNPROCESSED;

   igi_iac_debug_pkg.debug_other_string(p_level => g_state_level,
   p_full_path => l_path_name,
   p_string => 'p_revaluation_id = ' || p_revaluation_id);

   igi_iac_debug_pkg.debug_other_string(p_level => g_state_level,
   p_full_path => l_path_name,
   p_string => 'Calling xla create event api.');

   -- Call XLA API
   p_event_id :=
     XLA_EVENTS_PUB_PKG.create_event
          (p_event_source_info   => l_reval_source_info,
           p_event_type_code     => l_event_type_code,
           p_event_date          => l_event_date,
           p_event_status_code   => l_event_status,
           p_event_number        => NULL,
           p_reference_info      => NULL,
           p_valuation_method    => l_valuation_method,
           p_security_context    => l_security_context);

   igi_iac_debug_pkg.debug_other_string(p_level => g_state_level,
   p_full_path => l_path_name,
   p_string => 'p_event_id = ' || p_event_id);

   igi_iac_debug_pkg.debug_other_string(p_level => g_state_level,
   p_full_path => l_path_name,
   p_string => 'create_revaluation_event....Bye... ');

   return true;

EXCEPTION
  WHEN invalid_ledger THEN
       igi_iac_debug_pkg.debug_other_string(p_level => g_state_level,
	   p_full_path => l_path_name,
	   p_string => 'GL book info not found for book = '|| l_book_type_code);
       igi_iac_debug_pkg.debug_unexpected_msg(p_full_path => l_path_name);
       return FALSE;

  WHEN OTHERS THEN
       igi_iac_debug_pkg.debug_other_string(p_level => g_state_level,
	   p_full_path => l_path_name,
	   p_string => 'Fatal Error = '|| sqlerrm);
       igi_iac_debug_pkg.debug_unexpected_msg(p_full_path => l_path_name);
       return FALSE;
END create_revaluation_event;


FUNCTION update_revaluation_event
           ( p_revaluation_id         IN NUMBER ) return boolean IS

   l_reval_source_info  XLA_EVENTS_PUB_PKG.t_event_source_info;
   l_security_context XLA_EVENTS_PUB_PKG.t_security;
   l_event_type_code  varchar2(30);
   l_event_date       date;
   l_event_status     varchar2(30);
   l_valuation_method varchar2(30);
   l_book_type_code   varchar2(30);
   l_revaluation_date date;
   l_ledger_id             gl_sets_of_books.set_of_books_id%TYPE;
   l_chart_of_accounts_id  gl_sets_of_books.chart_of_accounts_id%TYPE;
   l_currency_code         gl_sets_of_books.currency_code%TYPE;
   l_precision             fnd_currencies.precision%TYPE;
   invalid_ledger          exception;
   l_event_id          number;
   l_path_name             varchar2(150) := g_path || 'update_revaluation_event';
begin

   select book_type_code,revaluation_date,event_id
   into l_book_type_code,l_revaluation_date,l_event_id
   from igi_iac_revaluations
   where revaluation_id =p_revaluation_id;

   -- Find the set_of_books_id and the currency code
   IF (igi_iac_common_utils.get_book_gl_info(l_book_type_code
                                            ,l_ledger_id
                                            ,l_chart_of_accounts_id
                                            ,l_currency_code
                                            ,l_precision))  THEN

       igi_iac_debug_pkg.debug_other_string(p_level => g_state_level,
	   p_full_path => l_path_name,
	   p_string => 'GL book info found for ledger_id = '||l_ledger_id);
    ELSE
       raise invalid_ledger;
    END IF;

   l_reval_source_info.application_id        := 140; --Assets
   l_reval_source_info.legal_entity_id       := NULL;
   l_reval_source_info.ledger_id             := l_ledger_id;
   l_reval_source_info.transaction_number    := to_char(p_revaluation_id);
   l_reval_source_info.source_id_int_1       := p_revaluation_id;
-- l_reval_source_info.source_id_int_2       := l_book_type_code;
   l_reval_source_info.source_id_char_1      := l_book_type_code; -- Bug 8624087
   l_reval_source_info.entity_type_code      := 'TRANSACTIONS';
   l_event_type_code                         := 'INFLATION_REVALUATION';

   XLA_EVENTS_PUB_PKG.update_event
     (p_event_source_info            => l_reval_source_info,
      p_event_id                     => l_event_id,
      p_event_type_code              => l_event_type_code,
      p_event_date                   => null, --tbd
      p_event_status_code            => null, --tbd
      p_valuation_method             => l_book_type_code,
      p_security_context             => l_security_context);

  return true;

EXCEPTION
WHEN OTHERS THEN
       igi_iac_debug_pkg.debug_other_string(p_level => g_state_level,
	   p_full_path => l_path_name,
	   p_string => 'Fatal Error = '|| sqlerrm);
       igi_iac_debug_pkg.debug_unexpected_msg(p_full_path => l_path_name);
       return FALSE;

end update_revaluation_event;


FUNCTION delete_revaluation_event
           (p_revaluation_id         IN NUMBER) return boolean IS

   l_event_id         NUMBER;
   l_reval_source_info  XLA_EVENTS_PUB_PKG.t_event_source_info;
   l_security_context XLA_EVENTS_PUB_PKG.t_security;
   l_event_type_code  varchar2(30);
   l_event_date       date;
   l_event_status     varchar2(30);
   l_valuation_method varchar2(30);
   l_book_type_code   varchar2(30);
   l_revaluation_date date;
   l_ledger_id             gl_sets_of_books.set_of_books_id%TYPE;
   l_chart_of_accounts_id  gl_sets_of_books.chart_of_accounts_id%TYPE;
   l_currency_code         gl_sets_of_books.currency_code%TYPE;
   l_precision             fnd_currencies.precision%TYPE;
   invalid_ledger          exception;
   l_path_name             varchar2(150) := g_path || 'create_revaluation_event';

BEGIN

   select book_type_code,revaluation_date
   into l_book_type_code,l_revaluation_date
   from igi_iac_revaluations
   where revaluation_id =p_revaluation_id;

   -- Find the set_of_books_id and the currency code
   IF (igi_iac_common_utils.get_book_gl_info(l_book_type_code
                                            ,l_ledger_id
                                            ,l_chart_of_accounts_id
                                            ,l_currency_code
                                            ,l_precision))  THEN

       igi_iac_debug_pkg.debug_other_string(p_level => g_state_level,
	   p_full_path => l_path_name,
	   p_string => 'GL book info found for ledger_id = '||l_ledger_id);
    ELSE
       raise invalid_ledger;
    END IF;

   l_reval_source_info.application_id        := 140; --Assets
   l_reval_source_info.legal_entity_id       := NULL;
   l_reval_source_info.ledger_id             := l_ledger_id;
   l_reval_source_info.transaction_number    := to_char(p_revaluation_id);
   l_reval_source_info.source_id_int_1       := p_revaluation_id;
-- l_reval_source_info.source_id_int_2       := l_book_type_code;
   l_reval_source_info.source_id_char_1      := l_book_type_code; -- Bug 8624087
   l_reval_source_info.entity_type_code      := 'TRANSACTIONS';
   l_event_type_code                         := 'INFLATION_REVALUATION';
   l_valuation_method                        := l_valuation_method;

   XLA_EVENTS_PUB_PKG.delete_event
      (p_event_source_info            => l_reval_source_info,
       p_event_id                     => l_event_id,
       p_valuation_method             => l_book_type_code,
       p_security_context             => l_security_context);

   return true;

EXCEPTION
WHEN OTHERS THEN
       igi_iac_debug_pkg.debug_other_string(p_level => g_state_level,
	   p_full_path => l_path_name,
	   p_string => 'Fatal Error = '|| sqlerrm);
       igi_iac_debug_pkg.debug_unexpected_msg(p_full_path => l_path_name);
       return FALSE;

END delete_revaluation_event;

 BEGIN
 --===========================FND_LOG.START=====================================

    g_state_level :=	FND_LOG.LEVEL_STATEMENT;
    g_proc_level  :=	FND_LOG.LEVEL_PROCEDURE;
    g_event_level :=	FND_LOG.LEVEL_EVENT;
    g_excep_level :=	FND_LOG.LEVEL_EXCEPTION;
    g_error_level :=	FND_LOG.LEVEL_ERROR;
    g_unexp_level :=	FND_LOG.LEVEL_UNEXPECTED;
    g_path        := 'IGI.PLSQL.igixevtb.igi_iac_xla_events_pkg.';

--===========================FND_LOG.END=====================================

END IGI_IAC_XLA_EVENTS_PKG;


/
