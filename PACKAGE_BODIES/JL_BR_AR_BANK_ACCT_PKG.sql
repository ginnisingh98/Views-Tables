--------------------------------------------------------
--  DDL for Package Body JL_BR_AR_BANK_ACCT_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."JL_BR_AR_BANK_ACCT_PKG" AS
/* $Header: jlbrslab.pls 120.44.12010000.10 2010/02/08 17:15:50 mkandula ship $ */

/*========================================================================
 | PRIVATE FUNCTION Create_SLA_Event
 |
 | DESCRIPTION
 |      Function to call SLA Create Event API for JLBR AR Bank Transfers
 |      It returns the EVENT_ID returned by SLA Create Event API
 |
 | CALLED FROM PROCEDURES/FUNCTIONS (local to this package body)
 |      a) Create_Event_Dists
 |
 | CALLS PROCEDURES/FUNCTIONS (local to this package body)
 |
 | PARAMETERS
 |
 | KNOWN ISSUES
 |
 | NOTES
 |
 | MODIFICATION HISTORY
 | Date                  Author            Description of Changes
 *=======================================================================*/

-- Define Package Level Debug Variable and Assign the Profile
  DEBUG_Var varchar2(1) := NVL(FND_PROFILE.value('AFLOG_ENABLED'), 'N');
  G_CURRENT_RUNTIME_LEVEL        NUMBER := FND_LOG.G_CURRENT_RUNTIME_LEVEL;
  G_LEVEL_STATEMENT     CONSTANT NUMBER := FND_LOG.LEVEL_STATEMENT;
  G_LEVEL_PROCEDURE     CONSTANT NUMBER := FND_LOG.LEVEL_PROCEDURE;
  G_LEVEL_EVENT         CONSTANT NUMBER := FND_LOG.LEVEL_EVENT;
  G_LEVEL_EXCEPTION     CONSTANT NUMBER := FND_LOG.LEVEL_EXCEPTION;
  G_LEVEL_ERROR         CONSTANT NUMBER := FND_LOG.LEVEL_ERROR;
  G_LEVEL_UNEXPECTED    CONSTANT NUMBER := FND_LOG.LEVEL_UNEXPECTED;

FUNCTION Create_SLA_Event (p_sla_event_type        IN VARCHAR2,
                           p_event_date            IN DATE,
                           p_bordero_type          IN VARCHAR2,
                           p_document_id           IN NUMBER,
                           p_occurrence_id         IN NUMBER,
                           p_ctrl_name             IN VARCHAR2,
                           p_trx_number            IN VARCHAR2,
                           p_bank_occurrence_type  IN VARCHAR2,
                           p_std_occurrence_code   IN VARCHAR2,
                           p_bordero_id            IN NUMBER,
                           p_payment_schedule_id   IN NUMBER)
         RETURN NUMBER IS

 l_event_source_info   xla_events_pub_pkg.t_event_source_info;
 l_event_id            NUMBER;
 l_org_id              NUMBER;
 l_security_context    xla_events_pub_pkg.t_security;
 l_reference_info      xla_events_pub_pkg.t_event_reference_info;
 l_category            VARCHAR2(30) := NULL;
 l_occurrence_id       NUMBER;
 l_event_number        NUMBER;


BEGIN
  IF (G_LEVEL_PROCEDURE >= G_CURRENT_RUNTIME_LEVEL ) THEN
	    FND_LOG.STRING(G_LEVEL_PROCEDURE, 'JL.plsql.JL_BR_AR_BANK_ACCT_PKG.Create_SLA_Event','Start FUNCTION Create_SLA_Event');
	    FND_LOG.STRING(G_LEVEL_PROCEDURE, 'JL.plsql.JL_BR_AR_BANK_ACCT_PKG.Create_SLA_Event','Parameters are :');
	    FND_LOG.STRING(G_LEVEL_PROCEDURE, 'JL.plsql.JL_BR_AR_BANK_ACCT_PKG.Create_SLA_Event','	p_sla_event_type'||p_sla_event_type);
	    FND_LOG.STRING(G_LEVEL_PROCEDURE, 'JL.plsql.JL_BR_AR_BANK_ACCT_PKG.Create_SLA_Event','	p_event_date'||p_event_date);
	    FND_LOG.STRING(G_LEVEL_PROCEDURE, 'JL.plsql.JL_BR_AR_BANK_ACCT_PKG.Create_SLA_Event','	p_bordero_type='||p_bordero_type);
	    FND_LOG.STRING(G_LEVEL_PROCEDURE, 'JL.plsql.JL_BR_AR_BANK_ACCT_PKG.Create_SLA_Event','	p_document_id='||p_document_id);
	    FND_LOG.STRING(G_LEVEL_PROCEDURE, 'JL.plsql.JL_BR_AR_BANK_ACCT_PKG.Create_SLA_Event','	p_occurrence_id='||p_occurrence_id);
	    FND_LOG.STRING(G_LEVEL_PROCEDURE, 'JL.plsql.JL_BR_AR_BANK_ACCT_PKG.Create_SLA_Event','	p_ctrl_name= '||p_ctrl_name);
	    FND_LOG.STRING(G_LEVEL_PROCEDURE, 'JL.plsql.JL_BR_AR_BANK_ACCT_PKG.Create_SLA_Event','	p_trx_number='||p_trx_number);
	    FND_LOG.STRING(G_LEVEL_PROCEDURE, 'JL.plsql.JL_BR_AR_BANK_ACCT_PKG.Create_SLA_Event','	p_bank_occurrence_type='||p_bank_occurrence_type);
	    FND_LOG.STRING(G_LEVEL_PROCEDURE, 'JL.plsql.JL_BR_AR_BANK_ACCT_PKG.Create_SLA_Event','	p_std_occurrence_code='||p_std_occurrence_code);
	    FND_LOG.STRING(G_LEVEL_PROCEDURE, 'JL.plsql.JL_BR_AR_BANK_ACCT_PKG.Create_SLA_Event','	p_bordero_id='||p_bordero_id);
	    FND_LOG.STRING(G_LEVEL_PROCEDURE, 'JL.plsql.JL_BR_AR_BANK_ACCT_PKG.Create_SLA_Event','	p_payment_schedule_id='||p_payment_schedule_id);
    END IF;

        l_event_source_info.application_id       := 222;

        SELECT ract.legal_entity_id,
               cd.org_id
          INTO l_event_source_info.legal_entity_id ,
               l_org_id
          FROM ra_customer_trx_all ract,
               jl_br_ar_collection_docs cd
         WHERE ract.customer_trx_id = cd.customer_trx_id
           AND ract.org_id         = cd.org_id
           AND cd.document_id      = p_document_id;

	  IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL ) THEN
    	    FND_LOG.STRING(G_LEVEL_STATEMENT, 'JL.plsql.JL_BR_AR_BANK_ACCT_PKG.Create_SLA_Event','Getting legal entity information '||l_event_source_info.legal_entity_id);
            FND_LOG.STRING(G_LEVEL_STATEMENT, 'JL.plsql.JL_BR_AR_BANK_ACCT_PKG.Create_SLA_Event','Getting org id information '||l_org_id);
	  END IF;

--
        SELECT set_of_books_id
          into l_event_source_info.ledger_id
          FROM ar_system_parameters_all
         WHERE org_id = l_org_id;

	 IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL ) THEN
    	    FND_LOG.STRING(G_LEVEL_STATEMENT, 'JL.plsql.JL_BR_AR_BANK_ACCT_PKG.Create_SLA_Event','Getting set of books information '||l_event_source_info.ledger_id);
	  END IF;
--
       BEGIN
        SELECT occurrence_id
          into l_occurrence_id
	from
         jl_br_ar_occurrence_docs_all oc,
         jl_br_ar_bank_occurrences bo
        WHERE
        document_id = p_document_id
        and bo.bank_occurrence_code = oc.bank_occurrence_code
        and bo.bank_occurrence_type = oc.bank_occurrence_type
        and bo.bank_party_id = oc.bank_party_id
        and bo.std_occurrence_code = 'REMITTANCE'
        and oc.occurrence_status = 'CONFIRMED';
        EXCEPTION
        WHEN OTHERS THEN
         fnd_file.put_line(fnd_file.log,'exception occured'||sqlerrm);
        END;

           IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL ) THEN
    	     FND_LOG.STRING(G_LEVEL_STATEMENT, 'JL.plsql.JL_BR_AR_BANK_ACCT_PKG.Create_SLA_Event','Getting occurence id information '||l_occurrence_id);
	   END IF;
	   /* ############### IF CONDITION############################# */

	   -- Bug#8248822 Added few more conditions

        IF (p_std_occurrence_code = 'AUTOMATIC_WRITE_OFF' or p_std_occurrence_code = 'REJECTED_ENTRY' or
		p_std_occurrence_code = 'WRITE_OFF_REQUISITION')
        or (p_sla_event_type = 'CANCEL_COLL_DOC' or p_sla_event_type = 'CANCEL_FACT_DOC')		THEN

	  IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL ) THEN
    	    FND_LOG.STRING(G_LEVEL_STATEMENT, 'JL.plsql.JL_BR_AR_BANK_ACCT_PKG.Create_SLA_Event','Inside condition where p_std_occurence code is AUTOMATIC_WRITE_OFF or REJECTED_ENTRY');
	  END IF;
	  SELECT rtrim(ract.trx_number||'-'||to_char(cd.terms_sequence_number)||':'||
               to_char(cd.document_id)||':'||bo.description)
               INTO
               l_event_source_info.transaction_number
        FROM   jl_br_ar_collection_docs cd,
               ra_customer_trx_all ract,
               jl_br_ar_bank_occurrences bo,
               jl_br_ar_occurrence_docs_all oc
         WHERE ract.customer_trx_id = cd.customer_trx_id
           AND ract.org_id         = cd.org_id
           AND cd.document_id      = p_document_id
           AND oc.document_id = cd.document_id
           AND oc.occurrence_id = l_occurrence_id
           And   bo.bank_occurrence_code = oc.bank_occurrence_code
           And   bo.bank_occurrence_type = oc.bank_occurrence_type
           And   bo.bank_party_id = oc.bank_party_id;
        l_event_source_info.entity_type_code     := 'JL_BR_AR_COLL_DOC_OCCS' ;
        l_event_source_info.source_id_int_1      := p_document_id;
        l_event_source_info.source_id_int_2      := l_occurrence_id;
        l_security_context.security_id_int_1     := l_org_id;

	IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL ) THEN
    	    FND_LOG.STRING(G_LEVEL_STATEMENT, 'JL.plsql.JL_BR_AR_BANK_ACCT_PKG.Create_SLA_Event','Getting transaction number information '||l_event_source_info.transaction_number);
	    FND_LOG.STRING(G_LEVEL_STATEMENT, 'JL.plsql.JL_BR_AR_BANK_ACCT_PKG.Create_SLA_Event','l_event_source_info.entity_type_code = '||l_event_source_info.entity_type_code);
	    FND_LOG.STRING(G_LEVEL_STATEMENT, 'JL.plsql.JL_BR_AR_BANK_ACCT_PKG.Create_SLA_Event','l_event_source_info.source_id_int_1 = '||l_event_source_info.source_id_int_1);
	    FND_LOG.STRING(G_LEVEL_STATEMENT, 'JL.plsql.JL_BR_AR_BANK_ACCT_PKG.Create_SLA_Event','l_event_source_info.source_id_int_2 = '||l_event_source_info.source_id_int_2);
	    FND_LOG.STRING(G_LEVEL_STATEMENT, 'JL.plsql.JL_BR_AR_BANK_ACCT_PKG.Create_SLA_Event','l_security_context.security_id_int_1 = '||l_security_context.security_id_int_1);
    	    FND_LOG.STRING(G_LEVEL_STATEMENT, 'JL.plsql.JL_BR_AR_BANK_ACCT_PKG.Create_SLA_Event','Calling procedure XLA_EVENTS_PUB_PKG.create_event ' );
	  END IF;
	l_event_id := XLA_EVENTS_PUB_PKG.create_event(
                 p_event_source_info => l_event_source_info                    ,
                 p_event_type_code   => p_sla_event_type                       ,
                 p_event_date        => p_event_date                           ,
                 p_event_status_code => XLA_EVENTS_PUB_PKG.C_EVENT_UNPROCESSED ,
                 p_event_number      => 2                                   ,
                 p_reference_info    => l_reference_info                       ,
                 p_valuation_method  => ''                                     ,
                 p_security_context  => l_security_context    );

          IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL ) THEN
    	    FND_LOG.STRING(G_LEVEL_STATEMENT, 'JL.plsql.JL_BR_AR_BANK_ACCT_PKG.Create_SLA_Event','Return l_event_id from XLA_EVENTS_PUB_PKG.create_event '||l_event_id );
	  END IF;
	  /* ############### ELSE PART ############################# */
       ELSE

	  IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL ) THEN
    	    FND_LOG.STRING(G_LEVEL_STATEMENT, 'JL.plsql.JL_BR_AR_BANK_ACCT_PKG.Create_SLA_Event','Inside Else condition of  p_std_occurence code ');
	  END IF;
          SELECT rtrim(ract.trx_number||'-'||to_char(cd.terms_sequence_number)||':'||
               to_char(cd.document_id)||':'||bo.description)
               INTO
               l_event_source_info.transaction_number
        FROM   jl_br_ar_collection_docs cd,
               ra_customer_trx_all ract,
               jl_br_ar_bank_occurrences bo,
               jl_br_ar_occurrence_docs_all oc
         WHERE ract.customer_trx_id = cd.customer_trx_id
           AND ract.org_id         = cd.org_id
           AND cd.document_id      = p_document_id
           AND oc.document_id = cd.document_id
           AND oc.occurrence_id = p_occurrence_id
           And   bo.bank_occurrence_code = oc.bank_occurrence_code
           And   bo.bank_occurrence_type = oc.bank_occurrence_type
           And   bo.bank_party_id = oc.bank_party_id;
        l_event_source_info.entity_type_code     := 'JL_BR_AR_COLL_DOC_OCCS' ;
        l_event_source_info.source_id_int_1      := p_document_id;
        l_event_source_info.source_id_int_2      := p_occurrence_id;
        l_security_context.security_id_int_1     := l_org_id;
        IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL ) THEN
    	    FND_LOG.STRING(G_LEVEL_STATEMENT, 'JL.plsql.JL_BR_AR_BANK_ACCT_PKG.Create_SLA_Event','Getting transaction number information '||l_event_source_info.transaction_number);
	    FND_LOG.STRING(G_LEVEL_STATEMENT, 'JL.plsql.JL_BR_AR_BANK_ACCT_PKG.Create_SLA_Event','l_event_source_info.entity_type_code = '||l_event_source_info.entity_type_code);
	    FND_LOG.STRING(G_LEVEL_STATEMENT, 'JL.plsql.JL_BR_AR_BANK_ACCT_PKG.Create_SLA_Event','l_event_source_info.source_id_int_1 = '||l_event_source_info.source_id_int_1);
	    FND_LOG.STRING(G_LEVEL_STATEMENT, 'JL.plsql.JL_BR_AR_BANK_ACCT_PKG.Create_SLA_Event','l_event_source_info.source_id_int_2 = '||l_event_source_info.source_id_int_2);
	    FND_LOG.STRING(G_LEVEL_STATEMENT, 'JL.plsql.JL_BR_AR_BANK_ACCT_PKG.Create_SLA_Event','l_security_context.security_id_int_1 = '||l_security_context.security_id_int_1);
    	    FND_LOG.STRING(G_LEVEL_STATEMENT, 'JL.plsql.JL_BR_AR_BANK_ACCT_PKG.Create_SLA_Event','Calling procedure XLA_EVENTS_PUB_PKG.create_event ' );
	  END IF;



        l_event_id := XLA_EVENTS_PUB_PKG.create_event(
                 p_event_source_info => l_event_source_info                    ,
                 p_event_type_code   => p_sla_event_type                       ,
                 p_event_date        => p_event_date                           ,
                 p_event_status_code => XLA_EVENTS_PUB_PKG.C_EVENT_UNPROCESSED ,
                 p_event_number      => 1                                  ,
                 p_reference_info    => l_reference_info                       ,
                 p_valuation_method  => ''                                     ,
                 p_security_context  => l_security_context    );
      END IF;

	    /* ############### END IF ############################# */
--
      IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL ) THEN
    	    FND_LOG.STRING(G_LEVEL_STATEMENT, 'JL.plsql.JL_BR_AR_BANK_ACCT_PKG.Create_SLA_Event','Return l_event_id from XLA_EVENTS_PUB_PKG.create_event '||l_event_id );
      END IF;
       return (l_event_id);
    EXCEPTION
      WHEN OTHERS THEN
       fnd_file.put_line(fnd_file.log,'exception occured'||sqlerrm);

END Create_SLA_Event;

/*========================================================================
 | PRIVATE PROCEDURE Create_Distribution
 |
 | DESCRIPTION
 |      Procedure to insert distribution in table JL_BR_AR_DISTRIBUTNS
 |
 | CALLED FROM PROCEDURES/FUNCTIONS (local to this package body)
 |      a) Create_Event_Dists
 |      b) Cancel_Reject_Distributions
 |
 | CALLS PROCEDURES/FUNCTIONS (local to this package body)
 |
 | PARAMETERS
 |
 | KNOWN ISSUES
 |
 | NOTES
 |
 | MODIFICATION HISTORY
 | Date                  Author            Description of Changes
 *=======================================================================*/

PROCEDURE Create_Distribution  (p_event_id                 IN NUMBER,
                                p_event_date               IN DATE,
                                p_document_id              IN NUMBER,
                                p_distr_type               IN VARCHAR2,
                                p_gl_date                  IN DATE,
                                p_entered_amt              IN NUMBER,
                                p_occurrence_id            IN NUMBER,
                                p_bank_occurrence_type     IN VARCHAR2,
                                p_bank_occurrence_code     IN VARCHAR2,
                                p_std_occurrence_code      IN VARCHAR2,
                                p_bordero_type             IN VARCHAR2,
                                p_org_id                   IN NUMBER,
                                p_entered_currency_code    IN VARCHAR2,
                                p_conversion_rate          IN NUMBER,
                                p_conversion_date          IN DATE,
                                p_conversion_rate_type     IN VARCHAR2,
                                p_acct_reversal_option     IN VARCHAR2,
                                p_reversed_dist_id         IN NUMBER,
                                p_reversed_dist_link_type  IN VARCHAR2,
                                p_prior_dist_id            IN NUMBER,
                                p_prior_dist_link_type     IN VARCHAR2,
                                p_dist_line_number         IN NUMBER) IS

l_count number;
BEGIN
   l_count :=0;
  IF (G_LEVEL_PROCEDURE >= G_CURRENT_RUNTIME_LEVEL ) THEN
   FND_LOG.STRING(G_LEVEL_PROCEDURE, 'JL.plsql.JL_BR_AR_BANK_ACCT_PKG.Create_Distribution','Start of create distribution function');
   FND_LOG.STRING(G_LEVEL_PROCEDURE, 'JL.plsql.JL_BR_AR_BANK_ACCT_PKG.Create_Distribution','Insertion into jl_br_ar_distributns table');
  END IF;
  Select count(*)
  into l_count
  from jl_br_ar_distributns
  where DOCUMENT_ID = p_document_id
    and DISTRIBUTION_TYPE = p_distr_type
    and STD_OCCURRENCE_CODE = p_std_occurrence_code
    and BORDERO_TYPE = p_bordero_type
    and BANK_OCCURRENCE_TYPE = p_bank_occurrence_type
	-- Bug#8248822 Bug in Reject Entry Bank Charges were not getting reversed
	and ACCOUNTING_REVERSAL_OPTION = p_acct_reversal_option
	-- Bug#8610977 Accouting issue for Mutiple Return Occurrences with same OCCURRENCE_TYPE
	AND OCCURRENCE_ID = p_occurrence_id;

    IF l_count > 0 then
      fnd_file.put_line(fnd_file.log,'Record already exists');
      return;
    ELSE
     insert into jl_br_ar_distributns
          (ORG_ID,
           DISTRIBUTION_ID,
           DOCUMENT_ID,
           DISTRIBUTION_TYPE,
           GL_DATE,
           ENTERED_AMT,
           ENTERED_CURRENCY_CODE,
           ACCTD_AMT,
           CONVERSION_RATE,
           CONVERSION_DATE,
           CONVERSION_RATE_TYPE,
           ACCOUNTING_REVERSAL_OPTION,
           REVERSED_DIST_ID,
           REVERSED_DIST_LINK_TYPE,
           PRIOR_DIST_ID,
           PRIOR_DIST_LINK_TYPE,
           DISTRIBUTION_LINK_TYPE,
           EVENT_ID,
           EVENT_DATE,
           OCCURRENCE_ID,
           BANK_OCCURRENCE_TYPE,
           BANK_OCCURRENCE_CODE,
           STD_OCCURRENCE_CODE,
           BORDERO_TYPE,
           DIST_LINE_NUMBER
          )
   values (p_org_id,                                 -- ORG_ID
           jl_br_ar_distributns_s.NEXTVAL,         -- DISTRIBUTION_ID
           p_document_id,                            -- DOCUMENT_ID
           p_distr_type,                             -- DISTRIBUTION_TYPE
           p_gl_date,                                -- GL_DATE
           p_entered_amt,                            -- ENTERED_AMT
           p_entered_currency_code,                  -- ENTERED_CURRENCY_CODE
           p_entered_amt * NVL(p_conversion_rate,1), -- ACCTD_AMT
           p_conversion_rate,                        -- CONVERSION_RATE
           p_conversion_date,                        -- CONVERSION_DATE
           p_conversion_rate_type,                   -- CONVERSION_RATE_TYPE
           p_acct_reversal_option,                   -- ACCOUNTING_REVERSAL_OPTION
           p_reversed_dist_id,                       -- REVERSED_DIST_ID
           p_reversed_dist_link_type,                -- REVERSED_DIST_LINK_TYPE
           p_prior_dist_id,                          -- PRIOR_DIST_ID
           p_prior_dist_link_type,                   -- PRIOR_DIST_LINK_TYPE
           'JLBR_AR_DIST',                           -- DISTRIBUTION_LINK_TYPE
           p_event_id,                               -- EVENT_ID
           p_event_date,                             -- EVENT_DATE
           p_occurrence_id,                          -- OCCURRENCE_ID
           p_bank_occurrence_type,                   -- BANK_OCCURRENCE_TYPE
           p_bank_occurrence_code,                   -- BANK_OCCURRENCE_CODE
           p_std_occurrence_code,                    -- STD_OCCURRENCE_CODE
           p_bordero_type,                           -- BORDERO_TYPE
           p_dist_line_number                        -- DIST_LINE_NUMBER
          );
      END IF;
	  IF (G_LEVEL_PROCEDURE >= G_CURRENT_RUNTIME_LEVEL ) THEN
	   FND_LOG.STRING(G_LEVEL_PROCEDURE, 'JL.plsql.JL_BR_AR_BANK_ACCT_PKG.Create_Distribution','Just after the Insertion into jl_br_ar_distributns table');
	   FND_LOG.STRING(G_LEVEL_PROCEDURE, 'JL.plsql.JL_BR_AR_BANK_ACCT_PKG.Create_Distribution','End of function');
	  END IF;

END Create_Distribution;

/*========================================================================
 | PRIVATE PROCEDURE Cancel_Reject_Distributions
 |
 | DESCRIPTION
 |      Procedure to insert distributions for cancel , rejection and write off
 |
 | CALLED FROM PROCEDURES/FUNCTIONS (local to this package body)
 |      a) Create_Event_Dists
 |
 | CALLS PROCEDURES/FUNCTIONS (local to this package body)
 |      a) Create_Distribution
 |
 | PARAMETERS
 |
 | KNOWN ISSUES
 |
 | NOTES
 |
 | MODIFICATION HISTORY
 | Date                  Author            Description of Changes
 *=======================================================================*/

PROCEDURE Cancel_Reject_Distributions (p_event_id                 IN     NUMBER,
                                       p_event_date               IN     DATE,
                                       p_gl_date                  IN     DATE,
                                       p_document_id              IN     NUMBER,
                                       p_occurrence_id            IN     NUMBER,
                                       p_bank_occurrence_type     IN     VARCHAR2,
                                       p_bank_occurrence_code     IN     VARCHAR2,
                                       p_std_occurrence_code      IN     VARCHAR2,
                                       p_bordero_type             IN     VARCHAR2,
                                       p_distribution_type        IN     VARCHAR2,
                                       p_dist_line_number         IN OUT NOCOPY NUMBER) IS
  cursor c_dist is
          SELECT ORG_ID,
              DISTRIBUTION_ID,
              DOCUMENT_ID,
              DISTRIBUTION_TYPE,
              GL_DATE,
              ENTERED_AMT,
              ENTERED_CURRENCY_CODE,
              ACCTD_AMT,
              CONVERSION_RATE,
              CONVERSION_DATE,
              CONVERSION_RATE_TYPE,
              ACCOUNTING_REVERSAL_OPTION,
              REVERSED_DIST_ID,
              REVERSED_DIST_LINK_TYPE,
              PRIOR_DIST_ID,
              PRIOR_DIST_LINK_TYPE,
              DISTRIBUTION_LINK_TYPE,
              EVENT_ID,
              EVENT_DATE,
              OCCURRENCE_ID,
              BANK_OCCURRENCE_TYPE,
              BANK_OCCURRENCE_CODE,
              STD_OCCURRENCE_CODE,
              BORDERO_TYPE,
              DIST_LINE_NUMBER
         FROM jl_br_ar_distributns
        WHERE document_id                = p_document_id
          AND std_occurrence_code        = 'REMITTANCE'
          AND accounting_reversal_option = 'N'
          AND distribution_type          = NVL(p_distribution_type,distribution_type);

  r_d    c_dist%ROWTYPE;

BEGIN
   IF (G_LEVEL_PROCEDURE >= G_CURRENT_RUNTIME_LEVEL ) THEN
     FND_LOG.STRING(G_LEVEL_PROCEDURE, 'JL.plsql.JL_BR_AR_BANK_ACCT_PKG.Cancel_Reject_Distributions','Start of procedure');
     FND_LOG.STRING(G_LEVEL_PROCEDURE, 'JL.plsql.JL_BR_AR_BANK_ACCT_PKG.Cancel_Reject_Distributions','Open cursor c_dist');
   END IF;
  open c_dist;
  LOOP
     fetch c_dist into r_d;
  EXIT WHEN c_dist%NOTFOUND;
     p_dist_line_number := p_dist_line_number + 1;

  IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL ) THEN
    	FND_LOG.STRING(G_LEVEL_STATEMENT, 'JL.plsql.JL_BR_AR_BANK_ACCT_PKG.Cancel_Reject_Distributions','Calling create distribution function');
  END IF;
     create_distribution (
                          p_event_id                => p_event_id,
                          p_event_date              => p_event_date,
                          p_document_id             => r_d.document_id,
                          p_distr_type              => r_d.distribution_type,
                          p_gl_date                 => p_gl_date,
                          p_entered_amt             => r_d.entered_amt * -1,
                          p_occurrence_id           => p_occurrence_id,
                          p_bank_occurrence_type    => p_bank_occurrence_type,
                          p_bank_occurrence_code    => p_bank_occurrence_code,
                          p_std_occurrence_code     => p_std_occurrence_code,
                          p_bordero_type            => p_bordero_type,
                          p_org_id                  => r_d.org_id,
                          p_entered_currency_code   => r_d.entered_currency_code,
                          p_conversion_rate         => r_d.conversion_rate,
                          p_conversion_date         => r_d.conversion_date,
                          p_conversion_rate_type    => r_d.conversion_rate_type,
                          p_acct_reversal_option    => 'Y',
                          p_reversed_dist_id        => r_d.distribution_id,
                          p_reversed_dist_link_type => r_d.distribution_link_type,
                          p_prior_dist_id           => NULL,
                          p_prior_dist_link_type    => NULL,
                          p_dist_line_number        => p_dist_line_number
                         );
  END LOOP;
  CLOSE c_dist;
  IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL ) THEN
    	FND_LOG.STRING(G_LEVEL_STATEMENT, 'JL.plsql.JL_BR_AR_BANK_ACCT_PKG.Cancel_Reject_Distributions','End of Cancel_Reject_Distributions procedure');
  END IF;
END Cancel_Reject_Distributions;

/*========================================================================
 | PUBLIC PROCEDURE Create_Event_Dists
 |
 | DESCRIPTION
 |      Main routine which creates SLA Event and distributions for
 |      JLBR AR Bank Transfer accounting. It returns EVENT_ID value
 |
 | CALLED FROM PROCEDURES/FUNCTIONS (local to this package body)
 |
 | CALLS PROCEDURES/FUNCTIONS (local to this package body)
 |      a) Create_SLA_Event
 |      b) Create_Distribution
 |      c) Cancel_Reject_Distributions
 |
 | PARAMETERS
 |
 | KNOWN ISSUES
 |
 | NOTES
 |
 | MODIFICATION HISTORY
 | Date                  Author            Description of Changes
 *=======================================================================*/

PROCEDURE Create_Event_Dists   (p_event_type_code       IN  VARCHAR2,
                                p_event_date            IN  DATE,
                                p_document_id           IN  NUMBER,
                                p_gl_date               IN  DATE,
                                p_occurrence_id         IN  NUMBER,
                                p_bank_occurrence_type  IN  VARCHAR2,
                                p_bank_occurrence_code  IN  VARCHAR2,
                                p_std_occurrence_code   IN  VARCHAR2,
                                p_bordero_type          IN  VARCHAR2,
                                p_endorsement_amt       IN  NUMBER,
                                p_bank_charges_amt      IN  NUMBER,
                                p_factoring_charges_amt IN  NUMBER,
                                p_event_id              OUT NOCOPY NUMBER) IS

  l_dist_exist         NUMBER  := 0;
  l_event_id           NUMBER;

  l_org_id                NUMBER;
  l_entered_currency_code VARCHAR2 (15);
  l_conversion_rate       NUMBER;
  l_conversion_date       DATE;
  l_conversion_rate_type  VARCHAR2 (30);
  l_dist_line_number      NUMBER;
  l_name                  VARCHAR2 (80);
  l_trx_number            VARCHAR2(30);
  l_bordero_id            NUMBER;
  l_payment_schedule_id   NUMBER;

  l_prior_dist_id         NUMBER;
  l_prior_dist_link_type  VARCHAR2 (30);

BEGIN

   /*--------------------------------------*/
   /* Ignore events that are not accounted */
   /*--------------------------------------*/
  IF (G_LEVEL_PROCEDURE >= G_CURRENT_RUNTIME_LEVEL ) THEN
     FND_LOG.STRING(G_LEVEL_PROCEDURE, 'JL.plsql.JL_BR_AR_BANK_ACCT_PKG.Create_Event_Dists','Start of procedure');
   END IF;

  if (p_event_type_code = 'CONFIRM_COLL_DOC' or p_event_type_code = 'CONFIRM_FACT_DOC' or
      p_event_type_code = 'APPLY_BANK_CHARGES_COLL_DOC' or p_event_type_code = 'APPLY_BANK_CHARGES_FACT_DOC' or
      p_event_type_code = 'PAY_COLL_DOC_AFTER_WRITE_OFF') and NVL(p_bank_charges_amt,0) = 0 then

     IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL ) THEN
       FND_LOG.STRING(G_LEVEL_STATEMENT, 'JL.plsql.JL_BR_AR_BANK_ACCT_PKG.Create_Event_Dists','Ignore events that are not accounted');
     END IF;

     p_event_id := NULL;
     RETURN;
  end if;

--
  select cd.org_id,
         ct.invoice_currency_code,
         ps.exchange_rate,
         ps.exchange_date,
         ps.exchange_rate_type,
         ct.trx_number,
         sc.name,
         bo.bordero_id,
         ps.payment_schedule_id
    into l_org_id,
         l_entered_currency_code,
         l_conversion_rate,
         l_conversion_date,
         l_conversion_rate_type,
         l_trx_number,
         l_name,
         l_bordero_id,
         l_payment_schedule_id
    from ra_customer_trx_all      ct,
         ar_payment_schedules_all ps,
         jl_br_ar_select_controls sc,
         jl_br_ar_borderos        bo,
         jl_br_ar_collection_docs cd
   where ct.customer_trx_id      = cd.customer_trx_id
     and ct.org_id               = cd.org_id
     and ps.payment_schedule_id  = cd.payment_schedule_id
     and ps.org_id               = cd.org_id
     and sc.selection_control_id = bo.selection_control_id
     and bo.bordero_id           = cd.bordero_id
     and cd.document_id          = p_document_id;
--
   /*--------------------*/
   /* Create SLA Event   */
   /*--------------------*/

    IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL ) THEN
    	    FND_LOG.STRING(G_LEVEL_STATEMENT, 'JL.plsql.JL_BR_AR_BANK_ACCT_PKG.Create_Event_Dists','l_org_id '||l_org_id);
	    FND_LOG.STRING(G_LEVEL_STATEMENT, 'JL.plsql.JL_BR_AR_BANK_ACCT_PKG.Create_Event_Dists','l_entered_currency_code = '||l_entered_currency_code);
	    FND_LOG.STRING(G_LEVEL_STATEMENT, 'JL.plsql.JL_BR_AR_BANK_ACCT_PKG.Create_Event_Dists','l_conversion_rate = '||l_conversion_rate);
	    FND_LOG.STRING(G_LEVEL_STATEMENT, 'JL.plsql.JL_BR_AR_BANK_ACCT_PKG.Create_Event_Dists','l_conversion_date = '||l_conversion_date);
	    FND_LOG.STRING(G_LEVEL_STATEMENT, 'JL.plsql.JL_BR_AR_BANK_ACCT_PKG.Create_Event_Dists','l_conversion_rate_type = '||l_conversion_rate_type);
	    FND_LOG.STRING(G_LEVEL_STATEMENT, 'JL.plsql.JL_BR_AR_BANK_ACCT_PKG.Create_Event_Dists','l_trx_number = '||l_conversion_rate_type);
	    FND_LOG.STRING(G_LEVEL_STATEMENT, 'JL.plsql.JL_BR_AR_BANK_ACCT_PKG.Create_Event_Dists','l_name = '||l_name);
	    FND_LOG.STRING(G_LEVEL_STATEMENT, 'JL.plsql.JL_BR_AR_BANK_ACCT_PKG.Create_Event_Dists','l_bordero_id = '||l_bordero_id);
	    FND_LOG.STRING(G_LEVEL_STATEMENT, 'JL.plsql.JL_BR_AR_BANK_ACCT_PKG.Create_Event_Dists','l_payment_schedule_id = '||l_payment_schedule_id);
    	    FND_LOG.STRING(G_LEVEL_STATEMENT, 'JL.plsql.JL_BR_AR_BANK_ACCT_PKG.Create_Event_Dists','Calling procedure Create_SLA_Event ' );
     END IF;


   l_event_id := Create_SLA_Event (
                          p_sla_event_type       => p_event_type_code,
                          p_event_date           => p_event_date,
                          p_bordero_type         => p_bordero_type,
                          p_document_id          => p_document_id,
                          p_occurrence_id        => p_occurrence_id,
                          p_ctrl_name            => l_name,
                          p_trx_number           => l_trx_number,
                          p_bank_occurrence_type => p_bank_occurrence_type,
                          p_std_occurrence_code  => p_std_occurrence_code,
                          p_bordero_id           => l_bordero_id,
                          p_payment_schedule_id  => l_payment_schedule_id
                                    );

   /*-----------------------*/
   /* Create Distributions  */
   /*-----------------------*/
--
  select NVL(max(dist_line_number),0)
    into l_dist_line_number
    from jl_br_ar_distributns
   where document_id = p_document_id;
--
   IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL ) THEN
    	    FND_LOG.STRING(G_LEVEL_STATEMENT, 'JL.plsql.JL_BR_AR_BANK_ACCT_PKG.Create_Event_Dists','l_dist_line_number = '||l_dist_line_number);
   END IF;

  if p_event_type_code = 'REMIT_COLL_DOC' or p_event_type_code = 'REMIT_FACT_DOC' then
     IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL ) THEN
    	    FND_LOG.STRING(G_LEVEL_STATEMENT, 'JL.plsql.JL_BR_AR_BANK_ACCT_PKG.Create_Event_Dists','Inside if condition where p_event_type_code = REMIT_COLL_DOC or REMIT_FACT_DOC');
     END IF;                                                                                   --- ENDORSEMENT

     l_dist_line_number := l_dist_line_number + 1;

      IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL ) THEN
    	    FND_LOG.STRING(G_LEVEL_STATEMENT, 'JL.plsql.JL_BR_AR_BANK_ACCT_PKG.Create_Event_Dists','Calling create_distribution');
     END IF;
     create_distribution (
                          p_event_id                => l_event_id,
                          p_event_date              => p_event_date,
                          p_document_id             => p_document_id,
                          p_distr_type              => 'JLBR_AR_ENDORSEMENT',
                          p_gl_date                 => p_gl_date,
                          p_entered_amt             => p_endorsement_amt,
                          p_occurrence_id           => p_occurrence_id,
                          p_bank_occurrence_type    => p_bank_occurrence_type,
                          p_bank_occurrence_code    => p_bank_occurrence_code,
                          p_std_occurrence_code     => p_std_occurrence_code,
                          p_bordero_type            => p_bordero_type,
                          p_org_id                  => l_org_id,
                          p_entered_currency_code   => l_entered_currency_code,
                          p_conversion_rate         => l_conversion_rate,
                          p_conversion_date         => l_conversion_date,
                          p_conversion_rate_type    => l_conversion_rate_type,
                          p_acct_reversal_option    => 'N',
                          p_reversed_dist_id        => NULL,
                          p_reversed_dist_link_type => NULL,
                          p_prior_dist_id           => NULL,
                          p_prior_dist_link_type    => NULL,
                          p_dist_line_number        => l_dist_line_number
                         );

     if NVL(p_bank_charges_amt,0) <> 0 then                                             --- BANK CHARGES
        IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL ) THEN
    	    FND_LOG.STRING(G_LEVEL_STATEMENT, 'JL.plsql.JL_BR_AR_BANK_ACCT_PKG.Create_Event_Dists','Calling create_distribution is p_bank_charges amount <>0');
        END IF;

	l_dist_line_number := l_dist_line_number + 1;
        create_distribution (
                          p_event_id                => l_event_id,
                          p_event_date              => p_event_date,
                          p_document_id             => p_document_id,
                          p_distr_type              => 'JLBR_AR_BANK_CHARGES',
                          p_gl_date                 => p_gl_date,
                          p_entered_amt             => p_bank_charges_amt,
                          p_occurrence_id           => p_occurrence_id,
                          p_bank_occurrence_type    => p_bank_occurrence_type,
                          p_bank_occurrence_code    => p_bank_occurrence_code,
                          p_std_occurrence_code     => p_std_occurrence_code,
                          p_bordero_type            => p_bordero_type,
                          p_org_id                  => l_org_id,
                          p_entered_currency_code   => l_entered_currency_code,
                          p_conversion_rate         => l_conversion_rate,
                          p_conversion_date         => l_conversion_date,
                          p_conversion_rate_type    => l_conversion_rate_type,
                          p_acct_reversal_option    => 'N',
                          p_reversed_dist_id        => NULL,
                          p_reversed_dist_link_type => NULL,
                          p_prior_dist_id           => NULL,
                          p_prior_dist_link_type    => NULL,
                          p_dist_line_number        => l_dist_line_number
                         );
     end if; -- p_bank_charges_amt

     if NVL(p_factoring_charges_amt,0) <> 0 then                                        --- FACTORING CHARGES
         IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL ) THEN
    	    FND_LOG.STRING(G_LEVEL_STATEMENT, 'JL.plsql.JL_BR_AR_BANK_ACCT_PKG.Create_Event_Dists','Calling create_distribution is FACTORING CHARGES amount <>0');
        END IF;
	l_dist_line_number := l_dist_line_number + 1;
        create_distribution (
                          p_event_id                => l_event_id,
                          p_event_date              => p_event_date,
                          p_document_id             => p_document_id,
                          p_distr_type              => 'JLBR_AR_FACTORING_CHARGES',
                          p_gl_date                 => p_gl_date,
                          p_entered_amt             => p_factoring_charges_amt,
                          p_occurrence_id           => p_occurrence_id,
                          p_bank_occurrence_type    => p_bank_occurrence_type,
                          p_bank_occurrence_code    => p_bank_occurrence_code,
                          p_std_occurrence_code     => p_std_occurrence_code,
                          p_bordero_type            => p_bordero_type,
                          p_org_id                  => l_org_id,
                          p_entered_currency_code   => l_entered_currency_code,
                          p_conversion_rate         => l_conversion_rate,
                          p_conversion_date         => l_conversion_date,
                          p_conversion_rate_type    => l_conversion_rate_type,
                          p_acct_reversal_option    => 'N',
                          p_reversed_dist_id        => NULL,
                          p_reversed_dist_link_type => NULL,
                          p_prior_dist_id           => NULL,
                          p_prior_dist_link_type    => NULL,
                          p_dist_line_number        => l_dist_line_number
                         );
     end if; -- p_factoring_charges_amt

  elsif p_event_type_code = 'CANCEL_COLL_DOC' or p_event_type_code = 'CANCEL_FACT_DOC' then
     IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL ) THEN
    	    FND_LOG.STRING(G_LEVEL_STATEMENT, 'JL.plsql.JL_BR_AR_BANK_ACCT_PKG.Create_Event_Dists','Inside else if cond.  p_event_type_code = CANCEL_COLL_DOC or p_event_type_code = CANCEL_FACT_DOC ');
     END IF;

     IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL ) THEN
    	    FND_LOG.STRING(G_LEVEL_STATEMENT, 'JL.plsql.JL_BR_AR_BANK_ACCT_PKG.Create_Event_Dists','Calling Cancel_Reject_Distributions function');
     END IF;
     Cancel_Reject_Distributions (
                          p_event_id                => l_event_id,
                          p_event_date              => p_event_date,
                          p_gl_date                 => p_gl_date,
                          p_document_id             => p_document_id,
                          p_occurrence_id           => p_occurrence_id,
                          p_bank_occurrence_type    => p_bank_occurrence_type,
                          p_bank_occurrence_code    => p_bank_occurrence_code,
                          p_std_occurrence_code     => p_std_occurrence_code,
                          p_bordero_type            => p_bordero_type,
                          p_distribution_type       => NULL,
                          p_dist_line_number        => l_dist_line_number
                         );

  elsif p_event_type_code = 'WRITE_OFF_COLL_DOC' then
    IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL ) THEN
    	    FND_LOG.STRING(G_LEVEL_STATEMENT, 'JL.plsql.JL_BR_AR_BANK_ACCT_PKG.Create_Event_Dists','Inside else if cond.  p_event_type_code = WRITE_OFF_COLL_DOC ');
     END IF;


     if NVL(p_bank_charges_amt,0) <> 0 then                                             --- BANK CHARGES
        IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL ) THEN
    	    FND_LOG.STRING(G_LEVEL_STATEMENT, 'JL.plsql.JL_BR_AR_BANK_ACCT_PKG.Create_Event_Dists','Calling create_distribution function if p_bank_charges_amt <> 0');
        END IF;
	l_dist_line_number := l_dist_line_number + 1;
        create_distribution (
                          p_event_id                => l_event_id,
                          p_event_date              => p_event_date,
                          p_document_id             => p_document_id,
                          p_distr_type              => 'JLBR_AR_BANK_CHARGES',
                          p_gl_date                 => p_gl_date,
                          p_entered_amt             => p_bank_charges_amt,
                          p_occurrence_id           => p_occurrence_id,
                          p_bank_occurrence_type    => p_bank_occurrence_type,
                          p_bank_occurrence_code    => p_bank_occurrence_code,
                          p_std_occurrence_code     => p_std_occurrence_code,
                          p_bordero_type            => p_bordero_type,
                          p_org_id                  => l_org_id,
                          p_entered_currency_code   => l_entered_currency_code,
                          p_conversion_rate         => l_conversion_rate,
                          p_conversion_date         => l_conversion_date,
                          p_conversion_rate_type    => l_conversion_rate_type,
                          p_acct_reversal_option    => 'N',
                          p_reversed_dist_id        => NULL,
                          p_reversed_dist_link_type => NULL,
                          p_prior_dist_id           => NULL,
                          p_prior_dist_link_type    => NULL,
                          p_dist_line_number        => l_dist_line_number
                         );
     end if; -- p_bank_charges_amt

     IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL ) THEN
    	    FND_LOG.STRING(G_LEVEL_STATEMENT, 'JL.plsql.JL_BR_AR_BANK_ACCT_PKG.Create_Event_Dists','Calling Cancel_Reject_Distributions function');
     END IF;
     Cancel_Reject_Distributions (
                          p_event_id                => l_event_id,
                          p_event_date              => p_event_date,
                          p_gl_date                 => p_gl_date,
                          p_document_id             => p_document_id,
                          p_occurrence_id           => p_occurrence_id,
                          p_bank_occurrence_type    => p_bank_occurrence_type,
                          p_bank_occurrence_code    => p_bank_occurrence_code,
                          p_std_occurrence_code     => p_std_occurrence_code,
                          p_bordero_type            => p_bordero_type,
                          p_distribution_type       => 'JLBR_AR_ENDORSEMENT',
                          p_dist_line_number        => l_dist_line_number
                         );

  elsif p_event_type_code = 'CONFIRM_COLL_DOC' or p_event_type_code = 'CONFIRM_FACT_DOC' or
        p_event_type_code = 'APPLY_BANK_CHARGES_COLL_DOC' or p_event_type_code = 'APPLY_BANK_CHARGES_FACT_DOC' or
        p_event_type_code = 'PAY_COLL_DOC_AFTER_WRITE_OFF' then
     IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL ) THEN
    	    FND_LOG.STRING(G_LEVEL_STATEMENT, 'JL.plsql.JL_BR_AR_BANK_ACCT_PKG.Create_Event_Dists','Inside else if cond. p_event_type_code, big condition');
     END IF;

     if NVL(p_bank_charges_amt,0) <> 0 then                                             --- BANK CHARGES
        l_dist_line_number := l_dist_line_number + 1;
        IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL ) THEN
    	    FND_LOG.STRING(G_LEVEL_STATEMENT, 'JL.plsql.JL_BR_AR_BANK_ACCT_PKG.Create_Event_Dists','Calling create_distribution function if p_bank_charges_amt <> 0');
        END IF;
	create_distribution (
                          p_event_id                => l_event_id,
                          p_event_date              => p_event_date,
                          p_document_id             => p_document_id,
                          p_distr_type              => 'JLBR_AR_BANK_CHARGES',
                          p_gl_date                 => p_gl_date,
                          p_entered_amt             => p_bank_charges_amt,
                          p_occurrence_id           => p_occurrence_id,
                          p_bank_occurrence_type    => p_bank_occurrence_type,
                          p_bank_occurrence_code    => p_bank_occurrence_code,
                          p_std_occurrence_code     => p_std_occurrence_code,
                          p_bordero_type            => p_bordero_type,
                          p_org_id                  => l_org_id,
                          p_entered_currency_code   => l_entered_currency_code,
                          p_conversion_rate         => l_conversion_rate,
                          p_conversion_date         => l_conversion_date,
                          p_conversion_rate_type    => l_conversion_rate_type,
                          p_acct_reversal_option    => 'N',
                          p_reversed_dist_id        => NULL,
                          p_reversed_dist_link_type => NULL,
                          p_prior_dist_id           => NULL,
                          p_prior_dist_link_type    => NULL,
                          p_dist_line_number        => l_dist_line_number
                         );
     end if; -- p_bank_charges_amt

  elsif p_event_type_code = 'FULLY_SETTLE_COLL_DOC' or p_event_type_code = 'FULLY_SETTLE_FACT_DOC' or
        p_event_type_code = 'PARTIALLY_SETTLE_FACT_DOC' OR p_event_type_code = 'PARTIALLY_SETTLE_COLL_DOC' then
      IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL ) THEN
    	    FND_LOG.STRING(G_LEVEL_STATEMENT, 'JL.plsql.JL_BR_AR_BANK_ACCT_PKG.Create_Event_Dists','Inside else if cond.  p_event_type_code = FULLY_SETTLE_COLL_DOC or FULLY_SETTLE_FACT_DOC or PARTIALLY_SETTLE_FACT_DOC or PARTIALLY_SETTLE_COLL_DOC');
     END IF;

                                                                                        --- ENDORSEMENT
        select distribution_id,
               distribution_link_type
          into l_prior_dist_id,
               l_prior_dist_link_type
          from jl_br_ar_distributns
         where std_occurrence_code = 'REMITTANCE'
           and document_id = p_document_id
           and accounting_reversal_option = 'N'
           and distribution_type = 'JLBR_AR_ENDORSEMENT';
        IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL ) THEN
    	    FND_LOG.STRING(G_LEVEL_STATEMENT, 'JL.plsql.JL_BR_AR_BANK_ACCT_PKG.Create_Event_Dists','distribution_id '||l_prior_dist_id);
	    FND_LOG.STRING(G_LEVEL_STATEMENT, 'JL.plsql.JL_BR_AR_BANK_ACCT_PKG.Create_Event_Dists','distribution_link_type = '||l_prior_dist_link_type);
	END IF;

        l_dist_line_number := l_dist_line_number + 1;

	IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL ) THEN
    	    FND_LOG.STRING(G_LEVEL_STATEMENT, 'JL.plsql.JL_BR_AR_BANK_ACCT_PKG.Create_Event_Dists','Calling create_distribution function if p_bank_charges_amt <> 0');
        END IF;
        create_distribution (
                          p_event_id                => l_event_id,
                          p_event_date              => p_event_date,
                          p_document_id             => p_document_id,
                          p_distr_type              => 'JLBR_AR_ENDORSEMENT',
                          p_gl_date                 => p_gl_date,
                          p_entered_amt             => p_endorsement_amt,
                          p_occurrence_id           => p_occurrence_id,
                          p_bank_occurrence_type    => p_bank_occurrence_type,
                          p_bank_occurrence_code    => p_bank_occurrence_code,
                          p_std_occurrence_code     => p_std_occurrence_code,
                          p_bordero_type            => p_bordero_type,
                          p_org_id                  => l_org_id,
                          p_entered_currency_code   => l_entered_currency_code,
                          p_conversion_rate         => l_conversion_rate,
                          p_conversion_date         => l_conversion_date,
                          p_conversion_rate_type    => l_conversion_rate_type,
                          p_acct_reversal_option    => 'N',
                          p_reversed_dist_id        => NULL,
                          p_reversed_dist_link_type => NULL,
                          p_prior_dist_id           => l_prior_dist_id,
                          p_prior_dist_link_type    => l_prior_dist_link_type,
                          p_dist_line_number        => l_dist_line_number
                         );

     if NVL(p_bank_charges_amt,0) <> 0 then                                             --- BANK CHARGES
        l_dist_line_number := l_dist_line_number + 1;
        IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL ) THEN
    	    FND_LOG.STRING(G_LEVEL_STATEMENT, 'JL.plsql.JL_BR_AR_BANK_ACCT_PKG.Create_Event_Dists','Calling create_distribution function if p_bank_charges_amt <> 0');
        END IF;

	create_distribution (
                          p_event_id                => l_event_id,
                          p_event_date              => p_event_date,
                          p_document_id             => p_document_id,
                          p_distr_type              => 'JLBR_AR_BANK_CHARGES',
                          p_gl_date                 => p_gl_date,
                          p_entered_amt             => p_bank_charges_amt,
                          p_occurrence_id           => p_occurrence_id,
                          p_bank_occurrence_type    => p_bank_occurrence_type,
                          p_bank_occurrence_code    => p_bank_occurrence_code,
                          p_std_occurrence_code     => p_std_occurrence_code,
                          p_bordero_type            => p_bordero_type,
                          p_org_id                  => l_org_id,
                          p_entered_currency_code   => l_entered_currency_code,
                          p_conversion_rate         => l_conversion_rate,
                          p_conversion_date         => l_conversion_date,
                          p_conversion_rate_type    => l_conversion_rate_type,
                          p_acct_reversal_option    => 'N',
                          p_reversed_dist_id        => NULL,
                          p_reversed_dist_link_type => NULL,
                          p_prior_dist_id           => NULL,
                          p_prior_dist_link_type    => NULL,
                          p_dist_line_number        => l_dist_line_number
                         );
     end if; -- p_bank_charges_amt

  elsif p_event_type_code = 'REJECT_COLL_DOC' or p_event_type_code = 'REJECT_FACT_DOC' then
     IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL ) THEN
    	    FND_LOG.STRING(G_LEVEL_STATEMENT, 'JL.plsql.JL_BR_AR_BANK_ACCT_PKG.Create_Event_Dists','Inside else if cond.  p_event_type_code = REJECT_COLL_DOC or REJECT_FACT_DOC');
     END IF;
     if NVL(p_bank_charges_amt,0) <> 0 then                                             --- BANK CHARGES
        l_dist_line_number := l_dist_line_number + 1;
        IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL ) THEN
    	    FND_LOG.STRING(G_LEVEL_STATEMENT, 'JL.plsql.JL_BR_AR_BANK_ACCT_PKG.Create_Event_Dists','Calling create_distribution function if p_bank_charges_amt <> 0');
        END IF;
	create_distribution (
                          p_event_id                => l_event_id,
                          p_event_date              => p_event_date,
                          p_document_id             => p_document_id,
                          p_distr_type              => 'JLBR_AR_BANK_CHARGES',
                          p_gl_date                 => p_gl_date,
                          p_entered_amt             => p_bank_charges_amt,
                          p_occurrence_id           => p_occurrence_id,
                          p_bank_occurrence_type    => p_bank_occurrence_type,
                          p_bank_occurrence_code    => p_bank_occurrence_code,
                          p_std_occurrence_code     => p_std_occurrence_code,
                          p_bordero_type            => p_bordero_type,
                          p_org_id                  => l_org_id,
                          p_entered_currency_code   => l_entered_currency_code,
                          p_conversion_rate         => l_conversion_rate,
                          p_conversion_date         => l_conversion_date,
                          p_conversion_rate_type    => l_conversion_rate_type,
                          p_acct_reversal_option    => 'N',
                          p_reversed_dist_id        => NULL,
                          p_reversed_dist_link_type => NULL,
                          p_prior_dist_id           => NULL,
                          p_prior_dist_link_type    => NULL,
                          p_dist_line_number        => l_dist_line_number
                         );
     end if; -- p_bank_charges_amt

     IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL ) THEN
    	    FND_LOG.STRING(G_LEVEL_STATEMENT, 'JL.plsql.JL_BR_AR_BANK_ACCT_PKG.Create_Event_Dists','Calling Cancel_Reject_Distributions function');
     END IF;
     Cancel_Reject_Distributions (
                          p_event_id                => l_event_id,
                          p_event_date              => p_event_date,
                          p_gl_date                 => p_gl_date,
                          p_document_id             => p_document_id,
                          p_occurrence_id           => p_occurrence_id,
                          p_bank_occurrence_type    => p_bank_occurrence_type,
                          p_bank_occurrence_code    => p_bank_occurrence_code,
                          p_std_occurrence_code     => p_std_occurrence_code,
                          p_bordero_type            => p_bordero_type,
                          p_distribution_type       => NULL,
                          p_dist_line_number        => l_dist_line_number
                         );

  end if;

  p_event_id := l_event_id;

   IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL ) THEN
    	    FND_LOG.STRING(G_LEVEL_STATEMENT, 'JL.plsql.JL_BR_AR_BANK_ACCT_PKG.Create_Event_Dists','End procedure Create_Event_Dists');
     END IF;
END Create_Event_Dists;



/*========================================================================
 | PUBLIC PROCEDURE Upgrade_Distributions
 |
 | DESCRIPTION
 |      Upgrades Distributions during downtime and on-demand upgrade
 |
 | CALLED FROM PROCEDURES/FUNCTIONS (local to this package body)
 |
 | CALLS PROCEDURES/FUNCTIONS (local to this package body)
 |
 | PARAMETERS
 |
 | KNOWN ISSUES
 |
 | NOTES
 |
 | MODIFICATION HISTORY
 | Date                  Author            Description of Changes
 *=======================================================================*/


PROCEDURE UPGRADE_DISTRIBUTIONS(
                       l_start_id     IN  number,
                       l_end_id       IN  number) IS
  Cursor c_dist is
  select tmp.distribution_id,
         tmp.document_id,
         decode(tmp.accounting_reversal_option, 'N', tmp.lagdist) prior_dist_id,
         decode(tmp.accounting_reversal_option, 'Y',
           decode(dist.std_occurrence_code, 'REMITTANCE', tmp.cancellagdist,tmp.lagdist)) rev_dist_id
  from (
   select distribution_id, document_id, ACCOUNTING_REVERSAL_OPTION,
        lag(distribution_id,1,to_number(NULL)) over (partition by document_id, distribution_type
	order by occurrence_id) lagdist,
        lag(distribution_id,1,to_number(NULL)) over (partition by document_id, occurrence_id, distribution_type
        order by accounting_reversal_option) cancellagdist
    from jl_rev_tmp) tmp,
    jl_br_ar_distributns_all dist
    where tmp.distribution_id = dist.distribution_id
    and (tmp.ACCOUNTING_REVERSAL_OPTION = 'Y'
    or dist.std_occurrence_code in ('FULL_SETTLEMENT', 'PARTIAL_SETTLEMENT')
       and dist.distribution_type = 'JLBR_AR_ENDORSEMENT');

  TYPE prior_rev_dist_rec IS RECORD(
    dist_id NUMBER_TBL_TYPE,
    document_id NUMBER_TBL_TYPE,
    prior_dist_id NUMBER_TBL_TYPE,
    rev_dist_id NUMBER_TBL_TYPE
  );

  pr_dist prior_rev_dist_rec;

  l_doc_id NUMBER;
  l_prior_dist_id NUMBER;

BEGIN
  IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL ) THEN
    	FND_LOG.STRING(G_LEVEL_STATEMENT, 'JL.plsql.JL_BR_AR_BANK_ACCT_PKG.UPGRADE_DISTRIBUTIONS','Start procedure UPGRADE_DISTRIBUTIONS');
        FND_LOG.STRING(G_LEVEL_STATEMENT, 'JL.plsql.JL_BR_AR_BANK_ACCT_PKG.UPGRADE_DISTRIBUTIONS','Insert into jl_br_ar_distributns_all ');
   END IF;

INSERT all
  WHEN 1=1 THEN
  INTO  jl_br_ar_distributns_all
   (
    ORG_ID  ,
    DISTRIBUTION_ID,
    DOCUMENT_ID ,
    DISTRIBUTION_LINK_TYPE,
    DISTRIBUTION_TYPE,
    GL_DATE,
    ENTERED_AMT ,
    ENTERED_CURRENCY_CODE,
    ACCTD_AMT ,
    CONVERSION_DATE ,
    CONVERSION_RATE ,
    CONVERSION_RATE_TYPE ,
    ACCOUNTING_REVERSAL_OPTION ,
    REVERSED_DIST_LINK_TYPE ,
    PRIOR_DIST_LINK_TYPE   ,
    EVENT_DATE ,
    OCCURRENCE_ID ,
    BANK_OCCURRENCE_CODE ,
    STD_OCCURRENCE_CODE,
    BORDERO_TYPE ,
    BANK_OCCURRENCE_TYPE,
    DIST_LINE_NUMBER
   )
   values (
    ORG_ID  ,
    jl_br_ar_distributns_s.NEXTVAL,
    DOCUMENT_ID ,
    'JLBR_AR_DIST',
    DISTRIBUTION_TYPE,
    GL_DATE,
    ENTERED_AMT ,
    ENTERED_CURRENCY_CODE,
    ENTERED_AMT ,
    CONVERSION_DATE ,
    CONVERSION_RATE ,
    CONVERSION_RATE_TYPE ,
    ACCOUNTING_REVERSAL_OPTION ,
    REVERSED_DIST_LINK_TYPE ,
    PRIOR_DIST_LINK_TYPE   ,
    EVENT_DATE ,
    OCCURRENCE_ID ,
    BANK_OCCURRENCE_CODE ,
    STD_OCCURRENCE_CODE,
    BORDERO_TYPE ,
    BANK_OCCURRENCE_TYPE,
    DIST_LINE_NUMBER
)
WHEN STD_OCCURRENCE_CODE IN ('REMITTANCE', 'FULL_SETTLEMENT', 'PARTIAL_SETTLEMENT',
                             'REJECTED_ENTRY', 'WRITE_OFF_REQUISITION', 'AUTOMATIC_WRITE_OFF')
THEN
into jl_rev_tmp (
distribution_id, document_id, occurrence_id, distribution_type, ACCOUNTING_REVERSAL_OPTION
)
values (
jl_br_ar_distributns_s.NEXTVAL, document_id, occurrence_id, distribution_type, ACCOUNTING_REVERSAL_OPTION
)
select
    X.ORG_ID  ,
    X.DOCUMENT_ID ,
    DECODE(MULTIPLIER,1,'JLBR_AR_ENDORSEMENT',2,'JLBR_AR_ENDORSEMENT',3,'JLBR_AR_BANK_CHARGES',
	       4,'JLBR_AR_BANK_CHARGES',5,'JLBR_AR_FACTORING_CHARGES',6,'JLBR_AR_FACTORING_CHARGES') distribution_type,
    nvl(DECODE(MULTIPLIER,2,X.OC_GL_DATE,4,X.OC_GL_DATE,6,X.OC_GL_DATE,
          DECODE(X.OCCURRENCE_STATUS, 'CANCELED', X.CSC_GL_DATE, X.OC_GL_DATE)),X.creation_date) gl_date,
    DECODE(MULTIPLIER,1,X.ENDORSEMENT_DEBIT_AMOUNT ,
          2, ( -1 * X.ENDORSEMENT_DEBIT_AMOUNT),
          3, X.BANK_CHARGES_DEBIT_AMOUNT,
          4, DECODE(X.STD_OCCURRENCE_CODE,'REJECTED_ENTRY',( -1 * X.REVERSE_CHARGES_DEB_AMOUNT),
                    ( -1 * X.BANK_CHARGES_DEBIT_AMOUNT)),
          5, X.FACTOR_INTEREST_CREDIT_AMOUNT,
          6, ( -1 * X.FACTOR_INTEREST_CREDIT_AMOUNT)) entered_amt,
    X.ENTERED_CURRENCY_CODE,
    PS.EXCHANGE_DATE CONVERSION_DATE,
    PS.EXCHANGE_RATE CONVERSION_RATE,
    PS.EXCHANGE_RATE_TYPE CONVERSION_RATE_TYPE,
    DECODE(MULTIPLIER,1,'N',2,'Y',3,'N',4,'Y',5,'N',6,'Y') ACCOUNTING_REVERSAL_OPTION,
    DECODE(MULTIPLIER,1,NULL,2,'JLBR_AR_DIST',3,NULL,4,'JLBR_AR_DIST',
                      5,NULL,6,'JLBR_AR_DIST') REVERSED_DIST_LINK_TYPE,
    DECODE(MULTIPLIER,1,DECODE(X.STD_OCCURRENCE_CODE, 'PARTIAL_SETTLEMENT', 'JLBR_AR_DIST',
    'FULL_SETTLEMENT', 'JLBR_AR_DIST', NULL),
	       NULL) PRIOR_DIST_LINK_TYPE,
    DECODE(MULTIPLIER,1,X.CREATION_DATE,3,X.CREATION_DATE,5,X.CREATION_DATE,
	       DECODE(X.OCCURRENCE_STATUS, 'CANCELED',X.LAST_UPDATE_DATE,X.CREATION_DATE)) EVENT_DATE,
    X.OCCURRENCE_ID ,
    X.BANK_OCCURRENCE_CODE ,
    X.STD_OCCURRENCE_CODE,
    X.BORDERO_TYPE ,
    X.BANK_OCCURRENCE_TYPE,
    ROW_NUMBER() OVER (PARTITION BY X.DOCUMENT_ID, X.OCCURRENCE_ID
                 ORDER BY MULTIPLIER) DIST_LINE_NUMBER
FROM
   (
-- start
select /*+ no_merge leading(oc) index(oc, jl_br_ar_occur_docs_n1) */
	oc.gl_date oc_gl_date, csc.gl_date csc_gl_date,
        nvl(oc.occurrence_status,'CONFIRMED') OCCURRENCE_STATUS,
	oc.endorsement_debit_amount, oc.bank_charges_debit_amount,
	oc.reverse_charges_deb_amount, oc.factor_interest_credit_amount,
	oc.endorsement_debit_ccid, oc.bank_charges_debit_ccid,
	oc.reverse_charges_deb_ccid, oc.factor_interest_credit_ccid,
	ract.invoice_currency_code entered_currency_code, oc.last_update_date,
	oc.creation_date, oc.occurrence_id, oc.bank_occurrence_code,
	bo.std_occurrence_code, b.bordero_type, bo.bank_occurrence_type,
	cd.document_id, oc.bank_party_id, oc.bordero_id, ract.customer_trx_id,
	csc.select_account_id, oc.flag_post_gl, oc.gl_date, cd.org_id,
	cd.payment_schedule_id
   from jl_br_ar_collection_docs_all cd,
	jl_br_ar_occurrence_docs_all oc,
        ra_customer_trx_all ract,
	jl_br_ar_bank_occurrences bo,
        jl_br_ar_select_accounts_all csc,
	jl_br_ar_borderos_all b
  where oc.document_id between l_start_id and l_end_id
    and nvl(oc.occurrence_status,'CONFIRMED') <> 'CREATED'
    and oc.document_id = cd.document_id
    and cd.customer_trx_id = ract.customer_trx_id
    and bo.bank_occurrence_code = oc.bank_occurrence_code
    and bo.bank_occurrence_type = oc.bank_occurrence_type
    and bo.bank_number = oc.bank_number
    and bo.bank_occurrence_type in ('REMITTANCE_OCCURRENCE', 'RETURN_OCCURRENCE')
    and bo.std_occurrence_code in ('REMITTANCE','WRITE_OFF_REQUISITION','CONFIRMED_ENTRY', 'REJECTED_ENTRY',
	'FULL_SETTLEMENT', 'PARTIAL_SETTLEMENT', 'PAYMENT_AFTER_WRITE_OFF',
	'AUTOMATIC_WRITE_OFF', 'BANK_CHARGES', 'REMITTANCE_CONFIRMATION',
	'REMITTANCE_REJECTION', 'OTHER_OCCURRENCES')
    and b.bordero_id = cd.bordero_id
    and b.bordero_type in ('COLLECTION', 'FACTORING')
    and csc.select_account_id = b.select_account_id
    and (nvl(oc.flag_post_gl, 'N') = 'N'
     or (oc.flag_post_gl = 'Y'
    and (exists (
	select 'Y'
	  from xla_upgrade_dates xud
	 where ract.set_of_books_id = xud.ledger_id
	   and ((oc.gl_date >= xud.start_date and oc.gl_date < xud.end_date)
            or (oc.gl_date IS NULL and oc.creation_date between xud.start_date and xud.end_date)
	    or (nvl(oc.occurrence_status,'CONFIRMED') <> 'CANCELED'
	   and oc.gl_date < xud.start_date
	   and bo.std_occurrence_code = 'REMITTANCE'
	   and exists (
	         select 'Y'
		 from jl_br_ar_occurrence_docs o
		 where o.document_id = oc.document_id
		  and (
                     (o.gl_date is NULL and oc.creation_date between xud.start_date and xud.end_date)
                     or (o.gl_date >= xud.start_date
                  and o.gl_date < xud.end_date))))))
	    or ((nvl(oc.occurrence_status,'CONFIRMED') <> 'CANCELED'
	   and bo.std_occurrence_code = 'REMITTANCE'
        and exists(select 'Y' from jl_br_ar_occurrence_docs_all o2 where o2.document_id = oc.document_id
                  and nvl(o2.flag_post_gl,'N') = 'N'))))
        ))) X,
	gl_row_multipliers grm,
        ar_payment_schedules_all ps
  where grm.multiplier < 7
    and ps.payment_schedule_id = x.payment_schedule_id
    and not exists (
	select /*+ use_nl_with_index(rerun, JL_BR_AR_DISTRIBUTNS_U2) */ null
	  from jl_br_ar_distributns_all rerun
	 where rerun.occurrence_id = x.occurrence_id
	   and rerun.distribution_type = decode (grm.multiplier, 1,
	       'JLBR_AR_ENDORSEMENT', 2, 'JLBR_AR_ENDORSEMENT', 3,
	       'JLBR_AR_BANK_CHARGES', 4, 'JLBR_AR_BANK_CHARGES', 5,
	       'JLBR_AR_FACTORING_CHARGES', 6, 'JLBR_AR_FACTORING_CHARGES')
	   and rerun.accounting_reversal_option = decode (grm.multiplier,
	       2, 'Y', 4, 'Y', 6, 'Y', 'N'))
  AND
    (multiplier = 1
    and std_occurrence_code in ('REMITTANCE','FULL_SETTLEMENT', 'PARTIAL_SETTLEMENT')
    and endorsement_debit_amount is not null
    and endorsement_debit_ccid is not null
     or multiplier = 2
    and endorsement_debit_amount is not null
    and endorsement_debit_ccid is not null
    and (occurrence_status = 'CANCELED' and std_occurrence_code = 'REMITTANCE'
    or std_occurrence_code in ('WRITE_OFF_REQUISITION','REJECTED_ENTRY', 'AUTOMATIC_WRITE_OFF'))
     or multiplier = 3
    and bank_charges_debit_amount is not null
    and bank_charges_debit_ccid is not null
     or multiplier = 4
    and (occurrence_status = 'CANCELED' and std_occurrence_code = 'REMITTANCE'
         and bank_charges_debit_amount is not null
         and bank_charges_debit_ccid is not null
    or std_occurrence_code = 'REJECTED_ENTRY'
        and reverse_charges_deb_amount is not null
        and reverse_charges_deb_ccid is not null)
     or multiplier = 5
    and bordero_type = 'FACTORING'
    and std_occurrence_code = 'REMITTANCE'
    and factor_interest_credit_amount is not null
    and factor_interest_credit_ccid is not null
     or multiplier = 6
    and bordero_type = 'FACTORING'
    and factor_interest_credit_amount is not null
    and factor_interest_credit_ccid is not null
    and (std_occurrence_code = 'REMITTANCE' and occurrence_status = 'CANCELED'
    or std_occurrence_code = 'REJECTED_ENTRY'))
     ;

   IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL ) THEN
        FND_LOG.STRING(G_LEVEL_STATEMENT, 'JL.plsql.JL_BR_AR_BANK_ACCT_PKG.UPGRADE_DISTRIBUTIONS',' After Insert into jl_br_ar_distributns_all. Opening cursor c_dist ');
   END IF;
   open c_dist;
   LOOP
     FETCH c_dist  BULK COLLECT INTO
     pr_dist.dist_id,
     pr_dist.document_id,
     pr_dist.prior_dist_id,
     pr_dist.rev_dist_id;

     EXIT WHEN c_dist%NOTFOUND;

   END LOOP;
   CLOSE c_dist;

-- Handle scenario where there can be more than one full settlement or partial settlement
-- for the same collection document
   IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL ) THEN
        FND_LOG.STRING(G_LEVEL_STATEMENT, 'JL.plsql.JL_BR_AR_BANK_ACCT_PKG.UPGRADE_DISTRIBUTIONS',' Handle scenario where there can be more than one full settlement or partial settlement for the same collection document');
   END IF;
     FOR i in nvl(pr_dist.dist_id.FIRST,0)..nvl(pr_dist.dist_id.LAST,-99)
     LOOP
       if pr_dist.prior_dist_id IS NOT NULL then
         if l_doc_id is NOT NULL and pr_dist.document_id(i) = l_doc_id then
            pr_dist.prior_dist_id(i) := l_prior_dist_id;
         end if;
         l_doc_id := pr_dist.document_id(i);
         l_prior_dist_id := pr_dist.prior_dist_id(i);
       end if;
     END LOOP;

     FORALL i in 1..nvl(pr_dist.dist_id.LAST,-99)

       update /*+ index(d, jl_br_ar_distributns_u1) */ jl_br_ar_distributns_all d
       set reversed_dist_id = pr_dist.rev_dist_id(i),
           prior_dist_id = pr_dist.prior_dist_id(i)
       where distribution_id = pr_dist.dist_id(i);

   IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL ) THEN
    	FND_LOG.STRING(G_LEVEL_STATEMENT, 'JL.plsql.JL_BR_AR_BANK_ACCT_PKG.UPGRADE_DISTRIBUTIONS','END procedure UPGRADE_DISTRIBUTIONS');
   END IF;
END UPGRADE_DISTRIBUTIONS;

/*========================================================================
 | PUBLIC PROCEDURE update_distributions
 |
 | DESCRIPTION
 |     Updates Prior Distribution Id for the distribution records
 |
 | CALLED FROM PROCEDURES/FUNCTIONS (local to this package body)
 |
 | CALLS PROCEDURES/FUNCTIONS (local to this package body)
 |
 | PARAMETERS
 |
 | KNOWN ISSUES
 |
 | NOTES
 |
 | MODIFICATION HISTORY
 | Date                  Author            Description of Changes
 *=======================================================================*/

PROCEDURE UPDATE_DISTRIBUTIONS(
                       l_start_rowid     IN rowid,
                       l_end_rowid       IN rowid) IS
BEGIN

------------------------------------------------------------------
/* Updating the prior and reversed distribution Ids             */
------------------------------------------------------------------
    IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL ) THEN
    	FND_LOG.STRING(G_LEVEL_STATEMENT, 'JL.plsql.JL_BR_AR_BANK_ACCT_PKG.UPDATE_DISTRIBUTIONS','Start procedure UPDATE_DISTRIBUTIONS');
        FND_LOG.STRING(G_LEVEL_STATEMENT, 'JL.plsql.JL_BR_AR_BANK_ACCT_PKG.UPDATE_DISTRIBUTIONS','Updating table jl_br_ar_distributns_all');
   END IF;
   UPDATE jl_br_ar_distributns_all d
   SET (prior_dist_id, reversed_dist_id) =
           ( SELECT decode(d.accounting_reversal_option, 'Y', NULL, d1.distribution_id),
                    decode(d.accounting_reversal_option, 'Y', d1.distribution_id, NULL)
             FROM  jl_br_ar_distributns_all d1,
                   jl_br_ar_occurrence_docs_all occ1
             WHERE d1.distribution_type = d.distribution_type
             AND   d1.std_occurrence_code = 'REMITTANCE'
             AND   d1.document_id = d.document_id
             AND   d1.occurrence_id = occ1.occurrence_id
             AND   occ1.occurrence_status <> 'CANCELED')
   WHERE ((d.accounting_reversal_option = 'Y'
           AND d.reversed_dist_id IS NULL)
         OR
          (d.std_occurrence_code in ('FULL_SETTLEMENT','PARTIAL_SETTLEMENT')
           AND d.distribution_type = 'JLBR_AR_ENDORSEMENT'
           AND d.prior_dist_id IS NULL))
   AND EXISTS(
              SELECT 1 FROM jl_br_ar_occurrence_docs_all occ
              WHERE occ.occurrence_id = d.occurrence_id
              AND   rowid >= l_start_rowid
              AND   rowid <= l_end_rowid
             );
IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL ) THEN
    	FND_LOG.STRING(G_LEVEL_STATEMENT, 'JL.plsql.JL_BR_AR_BANK_ACCT_PKG.UPDATE_DISTRIBUTIONS','END procedure UPDATE_DISTRIBUTIONS');
END IF;
END Update_Distributions;

/*========================================================================
 | PUBLIC PROCEDURE Upgrade_Occurrences
 |
 | DESCRIPTION
 |     Upgrades Posted or Yet to be Posted Occurrences to SLA tables
 |     Called from Downtime Upgrade Script
 |
 | CALLED FROM PROCEDURES/FUNCTIONS (local to this package body)
 |
 | CALLS PROCEDURES/FUNCTIONS (local to this package body)
 |
 | PARAMETERS
 |
 | KNOWN ISSUES
 |
 | NOTES
 |
 | MODIFICATION HISTORY
 | Date                  Author            Description of Changes
 *=======================================================================*/

PROCEDURE UPGRADE_OCCURRENCES(
                       l_table_owner  IN VARCHAR2,
                       l_table_name   IN VARCHAR2,
                       l_script_name  IN VARCHAR2,
                       l_worker_id    IN VARCHAR2,
                       l_num_workers  IN VARCHAR2,
                       l_batch_size   IN VARCHAR2,
                       l_batch_id     IN NUMBER,
                       l_action_flag  IN VARCHAR2) IS

l_return_status         VARCHAR2(30);

BEGIN
 IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL ) THEN
    	FND_LOG.STRING(G_LEVEL_STATEMENT, 'JL.plsql.JL_BR_AR_BANK_ACCT_PKG.UPGRADE_OCCURRENCES','Start procedure UPGRADE_OCCURRENCES');
END IF;

          UPGRADE_OCCURRENCES(
                       l_table_owner,
                       l_table_name,
                       l_script_name,
                       l_worker_id,
                       l_num_workers,
                       l_batch_size,
                       l_batch_id,
                       l_action_flag,
                       l_return_status);

IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL ) THEN
    	FND_LOG.STRING(G_LEVEL_STATEMENT, 'JL.plsql.JL_BR_AR_BANK_ACCT_PKG.UPGRADE_OCCURRENCES','END procedure UPGRADE_OCCURRENCES');
END IF;

END Upgrade_Occurrences;

/*========================================================================
 | PUBLIC PROCEDURE Upgrade_Occurrences
 |
 | DESCRIPTION
 |     Upgrades Posted or Yet to be Posted Occurrences to SLA tables
 |     Called directly from on-demand upgrade concurrent program
 |
 | CALLED FROM PROCEDURES/FUNCTIONS (local to this package body)
 |
 | CALLS PROCEDURES/FUNCTIONS (local to this package body)
 |
 | PARAMETERS
 |
 | KNOWN ISSUES
 |
 | NOTES
 |
 | MODIFICATION HISTORY
 | Date                  Author            Description of Changes
 *=======================================================================*/

PROCEDURE UPGRADE_OCCURRENCES(
                       l_table_owner  IN VARCHAR2,
                       l_table_name   IN VARCHAR2,
                       l_script_name  IN VARCHAR2,
                       l_worker_id    IN VARCHAR2,
                       l_num_workers  IN VARCHAR2,
                       l_batch_size   IN VARCHAR2,
                       l_batch_id     IN NUMBER,
                       l_action_flag  IN VARCHAR2,
                       x_return_status  OUT NOCOPY  VARCHAR2) IS

l_start_rowid         NUMBER;
l_end_rowid           NUMBER;
l_any_rows_to_process boolean;
l_rows_processed      number := 0;
Cursor c_events is Select row_id, event_id, cancel_event_id from (
Select row_id, event_id, lead(event_id)
                   over (partition by row_id order by
                   decode(event_type_code,'CANCEL_COLL_DOC',2,'CANCEL_FACT_DOC',2,1)) cancel_event_id,
row_number()
                   over (partition by row_id order by
                   decode(event_type_code,'CANCEL_COLL_DOC',2,'CANCEL_FACT_DOC',2,1)) r
                   from jl_remit3_gt) where r=1;

BEGIN
  IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL ) THEN
    	FND_LOG.STRING(G_LEVEL_STATEMENT, 'JL.plsql.JL_BR_AR_BANK_ACCT_PKG.UPGRADE_OCCURRENCES','Start procedure UPGRADE_OCCURRENCES');
  END IF;
  IF l_action_flag  = 'R' THEN
    x_return_status := FND_API.G_RET_STS_SUCCESS;
  END IF;

  /* ------ Initialize the rowid ranges ------ */
  ad_parallel_updates_pkg.initialize_id_range(
           ad_parallel_updates_pkg.ID_RANGE,
           l_table_owner,
           l_table_name,
           l_script_name,
           'document_id',
           l_worker_id,
           l_num_workers,
           l_batch_size, 0);

  /* ------ Get rowid ranges ------ */
  ad_parallel_updates_pkg.get_id_range(
           l_start_rowid,
           l_end_rowid,
           l_any_rows_to_process,
           l_batch_size,
           TRUE);

  WHILE ( l_any_rows_to_process = TRUE )
  LOOP

   l_rows_processed := 0;

-------------------------------------------------------------------
-- Create the distributions for on-demand upgrade only
-------------------------------------------------------------------
 IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL ) THEN
    	FND_LOG.STRING(G_LEVEL_STATEMENT, 'JL.plsql.JL_BR_AR_BANK_ACCT_PKG.Upgrade_Distributions','Calling procedure Upgrade_Distributions');
END IF;
  IF l_script_name <> 'jl120occ.sql' THEN

    Upgrade_Distributions(l_start_rowid,
                          l_end_rowid);

 /*   Update_Distributions(l_start_rowid,
                          l_end_rowid);
   */
   NULL;
  END IF;

-------------------------------------------------------------------
-- Create the transaction entities
-------------------------------------------------------------------
/* The following code was modified as per the performance team recommendation to include global temporary tables.
   It is currently commented out because xla_upgrade_dates table is not available in xbuild2.
   The xla team is planning to release the table for general use post xbuild2. */

   NULL;

   IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL ) THEN
    	FND_LOG.STRING(G_LEVEL_STATEMENT, 'JL.plsql.JL_BR_AR_BANK_ACCT_PKG.Upgrade_Distributions','Create the transaction entities, Insert into XLA_TRANSACTION_ENTITIES_UPG, jl_remit_gt,jl_cancel_gt');
   END IF;

  INSERT all
  WHEN (1 = 1) THEN
    INTO XLA_TRANSACTION_ENTITIES_UPG
  (
    ENTITY_ID,
    APPLICATION_ID,
    LEGAL_ENTITY_ID,
    ENTITY_CODE,
    CREATION_DATE,
    CREATED_BY,
    LAST_UPDATE_DATE,
    LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN,
    SOURCE_ID_INT_1,
    SECURITY_ID_INT_1,
    SOURCE_ID_INT_2,
    TRANSACTION_NUMBER,
    LEDGER_ID,
    SOURCE_APPLICATION_ID,
    UPG_BATCH_ID,
    UPG_SOURCE_APPLICATION_ID
    )
    values (
      xla_transaction_entities_s.nextval,
      222,
      legal_entity_id,
      'JL_BR_AR_COLL_DOC_OCCS',
      sysdate,
       2,
      sysdate,
       2,
      -2005,
      document_id,
      org_id,
      occurrence_id,
      transaction_number,
      set_of_books_id,
      '222',
      l_batch_id,
      222)
   WHEN (1 = 1) THEN
   INTO jl_remit_gt (
	entity_id,
	set_of_books_id,
	accounting_method,
	creation_date,
	gl_posted_date,
	last_update_date,
	flag_post_gl,
	std_occurrence_code,
	occurrence_status,
	oc_gl_date,
        event_type_code,
        event_date,
        event_status_code,
        process_status_code,
        trx_date,
        ACCOUNT_DATE,
        PERIOD_NAME,
        CATEGORY_NAME,
        JLBR_TRANSFER_TO_GL_FLAG,
        GL_TRANSFER_DATE,
        bordero_id,
        bordero_type,
        bank_occurrence_code,
        bank_occurrence_type,
        bank_party_id,
        customer_trx_id,
        document_id,
        bank_charges_credit_ccid,
        bank_charges_debit_ccid,
        endorsement_credit_ccid,
        endorsement_debit_ccid,
        factor_interest_credit_ccid,
        factor_interest_debit_ccid,
        occurrence_id,
        reverse_charges_cred_ccid,
        reverse_charges_deb_ccid,
        bill_to_customer_id,
        bill_to_site_use_id,
        trx_number,
        rid
        )
   VALUES (
	xla_transaction_entities_s.nextval,
	set_of_books_id,
	accounting_method,
	creation_date,
	gl_posted_date,
	last_update_date,
	flag_post_gl,
	std_occurrence_code,
	nvl(occurrence_status,'CONFIRMED'),
	oc_gl_date,
         (Decode(std_occurrence_code, 'REMITTANCE',
            decode(occurrence_status, 'CANCELED',decode(bordero_type,'COLLECTION', 'CANCEL_COLL_DOC', 'CANCEL_FACT_DOC'),
            decode(bordero_type,'COLLECTION', 'REMIT_COLL_DOC' ,'REMIT_FACT_DOC')), 'WRITE_OFF_REQUISITION', 'WRITE_OFF_COLL_DOC', 'CONFIRMED_ENTRY',
          decode(bordero_type,'COLLECTION', 'CONFIRM_COLL_DOC', 'CONFIRM_FACT_DOC'), 'REJECTED_ENTRY',
          decode(bordero_type,'COLLECTION', 'REJECT_COLL_DOC', 'REJECT_FACT_DOC'), 'FULL_SETTLEMENT',
          decode(bordero_type,'COLLECTION', 'FULLY_SETTLE_COLL_DOC', 'FULLY_SETTLE_FACT_DOC'), 'PARTIAL_SETTLEMENT',
          'PARTIALLY_SETTLE_COLL_DOC','PAYMENT_AFTER_WRITE_OFF', 'PAY_COLL_DOC_AFTER_WRITE_OFF',
          'AUTOMATIC_WRITE_OFF', 'WRITE_OFF_COLL_DOC', 'APPLY_BANK_CHARGES_COLL_DOC' )), -- event type code
         Decode(occurrence_status, 'CANCELED',last_update_date, creation_date), --event date
           decode(accounting_method,  'CASH', 'N', decode(nvl(flag_post_gl,'N'), 'N', 'U','P')) , -- event status
          decode(nvl(flag_post_gl,'N'), 'N', 'U','P') , -- processing status
          decode(occurrence_status,'CANCELED', nvl(cd_cancel_date,last_update_date),
                 nvl(occurrence_date,creation_date)), -- trx_date
          oc_gl_date, --account_date
          PERIOD_NAME,
          Decode(std_occurrence_code, 'REMITTANCE','Remittance', 'WRITE_OFF_REQUISITION', 'Write-off',
          'CONFIRMED_ENTRY','Confirmation', 'REJECTED_ENTRY', 'Rejection', 'FULL_SETTLEMENT', 'Bank Receipts',
          'PARTIAL_SETTLEMENT', 'Bank Receipts','PAYMENT_AFTER_WRITE_OFF', 'Bank Receipts',
          'AUTOMATIC_WRITE_OFF', 'Write-off', 'Bank Charges'), -- Category Name
          nvl(flag_post_gl,'N'), -- jl_br_transfer_to_gl_flag
          gl_posted_date, -- gl_transfer_date
          bordero_id,
          bordero_type,
          bank_occurrence_code,
          bank_occurrence_type,
          bank_party_id,
          customer_trx_id,
          document_id,
          bank_charges_credit_ccid,
          bank_charges_debit_ccid,
          endorsement_credit_ccid,
          endorsement_debit_ccid,
          factor_interest_credit_ccid  ,
          factor_interest_debit_ccid,
          occurrence_id,
          reverse_charges_cred_ccid  ,
          reverse_charges_deb_ccid  ,
          bill_to_customer_id,
          bill_to_site_use_id,
          trx_number,
          rid
             )
   WHEN (occurrence_status = 'CANCELED') THEN
   INTO jl_cancel_gt (
	entity_id,
	set_of_books_id,
	accounting_method,
	creation_date,
	gl_posted_date,
	last_update_date,
        flag_post_gl,
        std_occurrence_code,
        OCCURRENCE_STATUS,
	OC_gl_date,
        event_type_code,
        event_date,
        event_status_code,
        process_status_code,
        trx_date,
        ACCOUNT_DATE,
        PERIOD_NAME,
        CATEGORY_NAME,
        JLBR_TRANSFER_TO_GL_FLAG,
        GL_TRANSFER_DATE,
        bordero_id,
        bordero_type,
        bank_occurrence_code,
        bank_occurrence_type,
        bank_party_id,
        customer_trx_id,
        document_id,
        bank_charges_credit_ccid,
        bank_charges_debit_ccid,
        endorsement_credit_ccid,
        endorsement_debit_ccid,
        factor_interest_credit_ccid,
        factor_interest_debit_ccid,
        occurrence_id,
        reverse_charges_cred_ccid,
        reverse_charges_deb_ccid,
        bill_to_customer_id,
        bill_to_site_use_id,
        trx_number,
        rid
        )
   VALUES (
	xla_transaction_entities_s.nextval,
	set_of_books_id,
	accounting_method,
	creation_date,
	gl_posted_date,
	occurrence_date, -- last updated date
        nvl2(gl_posted_date,'Y','N'), -- flag_post_gl
        'REMITTANCE',
        'CANCELREMIT', -- Occ Status
	csc_gl_date, -- OC GL Date
        (Decode(bordero_type,'COLLECTION','REMIT_COLL_DOC' ,'REMIT_FACT_DOC')), --event type
        creation_date, -- event date
        decode(accounting_method,  'CASH', 'N', decode(decode(gl_posted_date,NULL,'N','Y'), 'N', 'U','P')) ,
        decode(decode(gl_posted_date,NULL,'N','Y'), 'N', 'U','P') ,
        nvl(occurrence_date,creation_date), --trx date
        csc_gl_date, -- account date
        csc_period_name,
        'Remittance', -- Category Name
        decode(gl_posted_date,NULL,'N','Y'), -- JL_BR_GL_TRANSFER_FLAG
        GL_POSTED_DATE, -- GL Transfer Date
        bordero_id,
        bordero_type,
        bank_occurrence_code,
        'REMITTANCE_OCCURRENCE',
        bank_party_id,
        customer_trx_id,
        document_id,
        bank_charges_credit_ccid,
        bank_charges_debit_ccid,
        endorsement_credit_ccid,
        endorsement_debit_ccid,
        factor_interest_credit_ccid,
        factor_interest_debit_ccid,
        occurrence_id,
        reverse_charges_cred_ccid,
        reverse_charges_deb_ccid,
        bill_to_customer_id,
        bill_to_site_use_id,
        trx_number ,
        RID
       )
SELECT
        X.legal_entity_id, X.org_id, X.set_of_books_id,
        X.transaction_number,
        X.cd_cancel_date,
        X.accounting_method,
        X.creation_date ,
        X.gl_posted_date ,
        X.last_update_date ,
        X.flag_post_gl ,
        X.std_occurrence_code ,
        X.occurrence_status ,
        X.oc_gl_date,
        X.occurrence_date ,
        X.csc_gl_date,
        per.period_name PERIOD_NAME,
        X.CSC_PERIOD_NAME,
        X.bordero_id ,
        X.bordero_type ,
        X.bank_occurrence_code ,
        X.bank_occurrence_type ,
        X.bank_party_id ,
        X.customer_trx_id ,
        X.document_id ,
        X.bank_charges_credit_ccid ,
        X.bank_charges_debit_ccid ,
        X.endorsement_credit_ccid ,
        X.endorsement_debit_ccid ,
        X.factor_interest_credit_ccid ,
        X.factor_interest_debit_ccid ,
        X.occurrence_id ,
        X.reverse_charges_cred_ccid ,
        X.reverse_charges_deb_ccid ,
        X.bill_to_customer_id ,
        X.bill_to_site_use_id ,
        X.trx_number ,
        X.RID
 FROM (SELECT /*+ leading(oc,cd,ract,xud) swap_join_inputs(xud) swap_join_inputs(sys) swap_join_inputs(bo) use_nl(b,csc) */
        ract.legal_entity_id, cd.org_id, sys.set_of_books_id,
        rtrim(ract.trx_number||'-'||to_char(cd.terms_sequence_number)||':'||to_char(cd.document_id)||':'||bo.description)
        transaction_number,
        cd.cancellation_date cd_cancel_date,
        sys.accounting_method accounting_method,
        oc.creation_date creation_date,
        oc.gl_posted_date gl_posted_date,
        oc.last_update_date last_update_date,
        oc.flag_post_gl flag_post_gl,
        bo.std_occurrence_code std_occurrence_code,
        oc.occurrence_status occurrence_status,
        nvl(oc.gl_date,oc.creation_date) oc_gl_date,
        nvl(oc.gl_date,oc.creation_date) accounting_date,
        oc.occurrence_date occurrence_date,
        csc.gl_date csc_gl_date,
        gsb.period_set_name period_set_name,
        gsb.accounted_period_type period_type,
        per1.period_name CSC_PERIOD_NAME,
        b.bordero_id BORDERO_ID,
        b.bordero_type BORDERO_TYPE,
        bo.bank_occurrence_code BANK_OCCURRENCE_CODE,
        bo.bank_occurrence_type BANK_OCCURRENCE_TYPE,
        bo.bank_party_id BANK_PARTY_ID,
        cd.customer_trx_id CUSTOMER_TRX_ID,
        cd.document_id DOCUMENT_ID,
        oc.bank_charges_credit_ccid BANK_CHARGES_CREDIT_CCID,
        oc.bank_charges_debit_ccid BANK_CHARGES_DEBIT_CCID,
        oc.endorsement_credit_ccid ENDORSEMENT_CREDIT_CCID,
        oc.endorsement_debit_ccid ENDORSEMENT_DEBIT_CCID,
        oc.factor_interest_credit_ccid FACTOR_INTEREST_CREDIT_CCID,
        oc.factor_interest_debit_ccid FACTOR_INTEREST_DEBIT_CCID,
        oc.occurrence_id OCCURRENCE_ID,
        oc.reverse_charges_cred_ccid REVERSE_CHARGES_CRED_CCID,
        oc.reverse_charges_deb_ccid REVERSE_CHARGES_DEB_CCID,
        ract.bill_to_customer_id BILL_TO_CUSTOMER_ID,
        ract.bill_to_site_use_id BILL_TO_SITE_USE_ID,
        ract.trx_number TRX_NUMBER ,
        oc.ROWID RID
      FROM
            jl_br_ar_occurrence_docs_all oc,
            jl_br_ar_collection_docs_all cd,
            ra_customer_trx_all ract,
            jl_br_ar_bank_occurrences bo,
            jl_br_ar_select_accounts_all csc,
            jl_br_ar_borderos_all b,
            ar_system_parameters_all sys,
            gl_date_period_map per1,
            gl_sets_of_books gsb
      WHERE oc.document_id between l_start_rowid and l_end_rowid
        AND nvl(oc.occurrence_status,'CONFIRMED') <> 'CREATED'
        And   bo.bank_occurrence_code = oc.bank_occurrence_code
        And   bo.bank_occurrence_type = oc.bank_occurrence_type
        And   bo.bank_number = oc.bank_number
        And   oc.document_id = cd.document_id
        And   cd.customer_trx_id = ract.customer_trx_id
        And   cd.bordero_id = b.bordero_id
        And   csc.select_account_id = b.select_account_id
        And   sys.org_id = cd.org_id
        And   gsb.set_of_books_id = ract.set_of_books_id
        And   gsb.period_set_name = per1.period_set_name
        AND   per1.period_type = gsb.accounted_period_type
        AND   per1.accounting_date = csc.gl_date
        and bo.std_occurrence_code in ('REMITTANCE','WRITE_OFF_REQUISITION','CONFIRMED_ENTRY', 'REJECTED_ENTRY',
            'FULL_SETTLEMENT', 'PARTIAL_SETTLEMENT', 'PAYMENT_AFTER_WRITE_OFF',
            'AUTOMATIC_WRITE_OFF', 'BANK_CHARGES', 'REMITTANCE_CONFIRMATION',
            'REMITTANCE_REJECTION', 'OTHER_OCCURRENCES')
        AND ((oc.endorsement_debit_ccid is not null and oc.endorsement_debit_amount is not null
             and bo.std_occurrence_code in ('REMITTANCE','FULL_SETTLEMENT','PARTIAL_SETTLEMENT',
                             'REJECTED_ENTRY','WRITE_OFF_REQUISITION','AUTOMATIC_WRITE_OFF'))
             OR (oc.bank_charges_debit_ccid is not null AND oc.bank_charges_Debit_amount is not null))
        and (nvl(oc.flag_post_gl, 'N') = 'N'
         or (oc.flag_post_gl = 'Y'
             and (exists (
               select 'Y'
               from xla_upgrade_dates xud
               where ract.set_of_books_id = xud.ledger_id
               and ((oc.gl_date >= xud.start_date and oc.gl_date < xud.end_date)
                or (oc.gl_date IS NULL and oc.creation_date between xud.start_date and xud.end_date)
                or (nvl(oc.occurrence_status,'CONFIRMED') <> 'CANCELED'
               and oc.gl_date < xud.start_date
               and bo.std_occurrence_code = 'REMITTANCE'
               and exists (
                     select 'Y'
                     from jl_br_ar_occurrence_docs o
                     where o.document_id = oc.document_id
                      and (
                         (o.gl_date is NULL and oc.creation_date between xud.start_date and xud.end_date)
                         or (o.gl_date >= xud.start_date
                      and o.gl_date < xud.end_date))))))
                or ((nvl(oc.occurrence_status,'CONFIRMED') <> 'CANCELED'
               and bo.std_occurrence_code = 'REMITTANCE'
            and exists(select 'Y' from jl_br_ar_occurrence_docs_all o2 where o2.document_id = oc.document_id
                      and nvl(o2.flag_post_gl,'N') = 'N'))))
        ))
        And not exists
            (SELECT 'Y' FROM
            xla_transaction_entities_upg xae
            WHERE xae.APPLICATION_ID = 222
            And   xae.ENTITY_CODE = 'JL_BR_AR_COLL_DOC_OCCS'
            And   xae.LEDGER_ID = ract.set_of_books_id
            And   nvl(xae.SOURCE_ID_INT_1,-99) = cd.document_id
            And   nvl(xae.SOURCE_ID_INT_2,-99) = oc.occurrence_id)) X
      LEFT OUTER JOIN gl_date_period_map per
      USING (period_set_name, period_type, accounting_date);

-------------------------------------------------------------------
-- Create the Journal Entry Events and Headers
-------------------------------------------------------------------

-- Rerunnability conditions (for checking if records already exist
-- are not added for Events, JE Headers, JE Lines and Dist Links
-- because it is assumed that if the data in transaction entities is not
-- present, then data in rest of the tables is also not present.
   IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL ) THEN
    	FND_LOG.STRING(G_LEVEL_STATEMENT, 'JL.plsql.JL_BR_AR_BANK_ACCT_PKG.Upgrade_Distributions','Create the Journal Entry Events and Headers. Inserting into xla_events, jl_remit1_gt,xla_ae_headers,jl_remit3_gt');
   END IF;

   INSERT ALL
   WHEN 1 = 1 THEN
   INTO xla_events
   (
    EVENT_ID,
    APPLICATION_ID,
    EVENT_TYPE_CODE,
    EVENT_DATE,
    ENTITY_ID,
    EVENT_STATUS_CODE,
    PROCESS_STATUS_CODE,
    EVENT_NUMBER,
    ON_HOLD_FLAG,
    CREATION_DATE,
    CREATED_BY,
    LAST_UPDATE_DATE,
    LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN,
    PROGRAM_UPDATE_DATE,
    PROGRAM_APPLICATION_ID,
    PROGRAM_ID,
    UPG_BATCH_ID,
    UPG_SOURCE_APPLICATION_ID,
    TRANSACTION_DATE
    )
    VALUES
    (
     xla_events_s.nextval ,
     222,
     EVENT_TYPE_CODE,
     EVENT_DATE,
     ENTITY_ID,
     EVENT_STATUS_CODE,
     PROCESS_STATUS_CODE,
     EVENT_NUMBER,
     'N',
     sysdate,
      2,
     Sysdate,
      2,
     -2005,
     Sysdate,
     222,
     -2005,
     l_batch_id,
     222,
     TRX_DATE
     )
    WHEN (JLBR_TRANSFER_TO_GL_FLAG = 'Y')  THEN
    INTO jl_remit1_gt
    (
     SET_OF_BOOKS_ID,
     ENTITY_ID,
     EVENT_TYPE_CODE,
     ACCOUNT_DATE,
     PERIOD_NAME,
     CATEGORY_NAME,
     JLBR_TRANSFER_TO_GL_FLAG,
     GL_TRANSFER_DATE,
     BORDERO_ID,
     BORDERO_TYPE,
     BANK_OCCURRENCE_CODE,
     BANK_OCCURRENCE_TYPE,
     BANK_PARTY_ID,
     STD_OCCURRENCE_CODE,
     CUSTOMER_TRX_ID,
     DOCUMENT_ID,
     BANK_CHARGES_CREDIT_CCID,
     BANK_CHARGES_DEBIT_CCID,
     ENDORSEMENT_CREDIT_CCID,
     ENDORSEMENT_DEBIT_CCID,
     FACTOR_INTEREST_CREDIT_CCID,
     FACTOR_INTEREST_DEBIT_CCID,
     OCCURRENCE_ID,
     OCCURRENCE_STATUS,
     BILL_TO_CUSTOMER_ID,
     BILL_TO_SITE_USE_ID,
     REVERSE_CHARGES_CRED_CCID,
     TRX_NUMBER,
     EVENT_ID,
     HEADER_ID
    )
    VALUES
    (
     SET_OF_BOOKS_ID,
     ENTITY_ID,
     EVENT_TYPE_CODE,
     ACCOUNT_DATE,
     PERIOD_NAME,
     CATEGORY_NAME,
     JLBR_TRANSFER_TO_GL_FLAG,
     GL_TRANSFER_DATE,
     BORDERO_ID,
     BORDERO_TYPE,
     BANK_OCCURRENCE_CODE,
     BANK_OCCURRENCE_TYPE,
     BANK_PARTY_ID,
     STD_OCCURRENCE_CODE,
     CUSTOMER_TRX_ID,
     DOCUMENT_ID,
     BANK_CHARGES_CREDIT_CCID,
     BANK_CHARGES_DEBIT_CCID,
     ENDORSEMENT_CREDIT_CCID,
     ENDORSEMENT_DEBIT_CCID,
     FACTOR_INTEREST_CREDIT_CCID,
     FACTOR_INTEREST_DEBIT_CCID,
     OCCURRENCE_ID,
     OCCURRENCE_STATUS,
     BILL_TO_CUSTOMER_ID,
     BILL_TO_SITE_USE_ID,
     REVERSE_CHARGES_CRED_CCID,
     TRX_NUMBER,
     xla_events_s.nextval,
     xla_ae_headers_s.nextval
    )
     WHEN JLBR_TRANSFER_TO_GL_FLAG = 'Y' THEN
     INTO xla_ae_headers
     (
     AE_HEADER_ID,
     APPLICATION_ID,
     LEDGER_ID,
     ENTITY_ID,
     EVENT_ID,
     EVENT_TYPE_CODE,
     ACCOUNTING_DATE,
     PERIOD_NAME,
     JE_CATEGORY_NAME,
     GL_TRANSFER_STATUS_CODE,
     GL_TRANSFER_DATE,
     ACCOUNTING_ENTRY_STATUS_CODE,
     ACCOUNTING_ENTRY_TYPE_CODE,
     AMB_CONTEXT_CODE,
     BALANCE_TYPE_CODE,
     CREATION_DATE,
     CREATED_BY,
     LAST_UPDATE_DATE,
     LAST_UPDATED_BY,
     LAST_UPDATE_LOGIN,
     PROGRAM_UPDATE_DATE,
     PROGRAM_APPLICATION_ID,
     PROGRAM_ID,
     UPG_BATCH_ID,
     UPG_SOURCE_APPLICATION_ID,
     ZERO_AMOUNT_FLAG
     )
     VALUES
     (
      xla_ae_headers_s.nextval,
      222,
      SET_OF_BOOKS_ID,
      ENTITY_ID,
      xla_events_s.currval ,
      EVENT_TYPE_CODE,
      ACCOUNT_DATE,
      PERIOD_NAME,
      CATEGORY_NAME,
      JLBR_TRANSFER_TO_GL_FLAG,
      GL_TRANSFER_DATE,
      'F',
      'STANDARD',
      'DEFAULT',
       'A',
       sysdate,
       2,
       sysdate,
       2,
       -2005,
       sysdate,
       222,
       -2005,
       l_batch_id,
       222,
       'N'
       )
     WHEN 1 = 1 THEN
     INTO jl_remit3_gt
     (
      ROW_ID,
      EVENT_TYPE_CODE,
      EVENT_ID
     )
     VALUES
     (
      RID,
      EVENT_TYPE_CODE,
      xla_events_s.nextval
      )
      SELECT
         SET_OF_BOOKS_ID,
         ENTITY_ID,
         EVENT_TYPE_CODE,
         ACCOUNT_DATE,
         PERIOD_NAME,
         CATEGORY_NAME,
         JLBR_TRANSFER_TO_GL_FLAG,
         GL_TRANSFER_DATE,
         BORDERO_ID,
         BORDERO_TYPE,
         BANK_OCCURRENCE_CODE,
         BANK_OCCURRENCE_TYPE,
         BANK_PARTY_ID,
         STD_OCCURRENCE_CODE,
         CUSTOMER_TRX_ID,
         DOCUMENT_ID,
         BANK_CHARGES_CREDIT_CCID,
         BANK_CHARGES_DEBIT_CCID,
         ENDORSEMENT_CREDIT_CCID,
         ENDORSEMENT_DEBIT_CCID,
         FACTOR_INTEREST_CREDIT_CCID,
         FACTOR_INTEREST_DEBIT_CCID,
         OCCURRENCE_ID,
         OCCURRENCE_STATUS,
         BILL_TO_CUSTOMER_ID,
         BILL_TO_SITE_USE_ID,
         REVERSE_CHARGES_CRED_CCID,
         TRX_NUMBER,
         TRX_DATE,
         PROCESS_STATUS_CODE,
         EVENT_STATUS_CODE,
         EVENT_DATE,
         1 EVENT_NUMBER,
         RID
       FROM
         jl_remit_gt
       UNION ALL
       SELECT
         SET_OF_BOOKS_ID,
         ENTITY_ID,
         EVENT_TYPE_CODE,
         ACCOUNT_DATE,
         PERIOD_NAME,
         CATEGORY_NAME,
         JLBR_TRANSFER_TO_GL_FLAG,
         GL_TRANSFER_DATE,
         BORDERO_ID,
         BORDERO_TYPE,
         BANK_OCCURRENCE_CODE,
         BANK_OCCURRENCE_TYPE,
         BANK_PARTY_ID,
         STD_OCCURRENCE_CODE,
         CUSTOMER_TRX_ID,
         DOCUMENT_ID,
         BANK_CHARGES_CREDIT_CCID,
         BANK_CHARGES_DEBIT_CCID,
         ENDORSEMENT_CREDIT_CCID,
         ENDORSEMENT_DEBIT_CCID,
         FACTOR_INTEREST_CREDIT_CCID,
         FACTOR_INTEREST_DEBIT_CCID,
         OCCURRENCE_ID,
         OCCURRENCE_STATUS,
         BILL_TO_CUSTOMER_ID,
         BILL_TO_SITE_USE_ID,
         REVERSE_CHARGES_CRED_CCID,
         TRX_NUMBER ,
         TRX_DATE,
         PROCESS_STATUS_CODE,
         EVENT_STATUS_CODE,
         EVENT_DATE,
         2 EVENT_NUMBER,
         RID
       FROM
         jl_cancel_gt;

------------------------------------------------------------------
-- Updating the event id and the cancel event id
------------------------------------------------------------------
 IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL ) THEN
    	FND_LOG.STRING(G_LEVEL_STATEMENT, 'JL.plsql.JL_BR_AR_BANK_ACCT_PKG.Upgrade_Distributions','Updating the event id and the cancel event id of table jl_br_ar_occurrence_docs_all');
   END IF;
   OPEN c_events;
     FETCH c_events  BULK COLLECT INTO
     JL_BR_AR_BANK_ACCT_PKG.trx_events.row_id,
     JL_BR_AR_BANK_ACCT_PKG.trx_events.event_id,
     JL_BR_AR_BANK_ACCT_PKG.trx_events.cancel_event_id
     ;

   CLOSE c_events;

   FORALL i in 1..nvl(JL_BR_AR_BANK_ACCT_PKG.trx_events.row_id.LAST,-99)

       UPDATE  jl_br_ar_occurrence_docs_all occ
       set event_id = JL_BR_AR_BANK_ACCT_PKG.trx_events.event_id(i)
       ,cancel_event_id = JL_BR_AR_BANK_ACCT_PKG.trx_events.cancel_event_id(i)
       where rowid = JL_BR_AR_BANK_ACCT_PKG.trx_events.row_id(i) ;
-------------------------------------------------------------------
-- Create the Journal Entry Lines
-------------------------------------------------------------------
  IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL ) THEN
    	FND_LOG.STRING(G_LEVEL_STATEMENT, 'JL.plsql.JL_BR_AR_BANK_ACCT_PKG.Upgrade_Distributions','Creating journal entries by inserting into xla_ae_lines, xla_distribution_links');
   END IF;

   INSERT ALL
   WHEN 1 = 1 THEN
   INTO xla_ae_lines
   (
     AE_HEADER_ID,
     AE_LINE_NUM,
     DISPLAYED_LINE_NUMBER,
     APPLICATION_ID,
     CODE_COMBINATION_ID,
     LEDGER_ID,
     ACCOUNTING_DATE,
     GL_TRANSFER_MODE_CODE,
     ACCOUNTED_CR ,
     ACCOUNTED_DR,
     ENTERED_CR,
     ENTERED_DR ,
     ACCOUNTING_CLASS_CODE,
     CURRENCY_CODE,
     CURRENCY_CONVERSION_DATE ,
     CURRENCY_CONVERSION_RATE ,
     CURRENCY_CONVERSION_TYPE ,
     DESCRIPTION,
     PARTY_ID ,
     PARTY_SITE_ID,
     PARTY_TYPE_CODE ,
     CONTROL_BALANCE_FLAG ,
     CREATION_DATE,
     CREATED_BY,
     LAST_UPDATE_DATE,
     LAST_UPDATED_BY,
     LAST_UPDATE_LOGIN  ,
     PROGRAM_UPDATE_DATE ,
     PROGRAM_APPLICATION_ID ,
     PROGRAM_ID ,
     UPG_BATCH_ID,
     UNROUNDED_ACCOUNTED_CR ,
     UNROUNDED_ACCOUNTED_DR,
     GAIN_OR_LOSS_FLAG,
     UNROUNDED_ENTERED_CR,
     UNROUNDED_ENTERED_DR
     )
     VALUES
     (
      HEADER_ID,
      LINE_NUM,
      LINE_NUM,
      222,
      CCID,
      SET_OF_BOOKS_ID,
      ACCOUNT_DATE,
      'D' ,
      ACCOUNTED_CR ,
      ACCOUNTED_DR,
      ENTERED_CR,
      ENTERED_DR ,
      ACCOUNTING_CLASS_CODE,
      CURRENCY_CODE,
      CONVERSION_DATE,
      CONVERSION_RATE,
      CONVERSION_RATE_TYPE,
      DESCRIPTION,
      PARTY_ID,
      PARTY_SITE_ID ,
      'C',
      CONTROL_BALANCE_FLAG,
      sysdate,
       2,
      sysdate,
       2,
      -2005,
      sysdate,
      222,
      -2005,
      100, --l_batch_id,
      UNROUNDED_ACCOUNTED_CR,
      UNROUNDED_ACCOUNTED_DR,
      'N' ,
      UNROUNDED_ENTERED_CR,
      UNROUNDED_ENTERED_DR
      )
      WHEN 1 = 1 THEN
      INTO xla_distribution_links
      (
      APPLICATION_ID,
      EVENT_ID,
      AE_HEADER_ID,
      AE_LINE_NUM,
      ACCOUNTING_LINE_CODE,
      ACCOUNTING_LINE_TYPE_CODE ,
      REF_AE_HEADER_ID,
      SOURCE_DISTRIBUTION_TYPE,
      SOURCE_DISTRIBUTION_ID_NUM_1 ,
      MERGE_DUPLICATE_CODE,
      TEMP_LINE_NUM,
      REF_EVENT_ID ,
      EVENT_CLASS_CODE,
      EVENT_TYPE_CODE,
      UPG_BATCH_ID  ,
      UNROUNDED_ENTERED_DR     ,
      UNROUNDED_ENTERED_CR     ,
      UNROUNDED_ACCOUNTED_CR   ,
      UNROUNDED_ACCOUNTED_DR
      )
      VALUES
      (
       222,
       EVENT_ID,
       HEADER_ID,
       LINE_NUM,
       ACCOUNTING_CLASS_CODE,
       'C',
       REF_HEADER_ID,
       'JLBR_AR_DIST',
       DISTRIBUTION_ID,
       'N',
       LINE_NUM,
       REF_EVENT_ID,
       EVENT_CLASS_CODE,
       EVENT_TYPE_CODE,
       100, --l_batch_id,
       ENTERED_AMOUNT,
       ENTERED_AMOUNT,
       ENTERED_AMOUNT,
       ENTERED_AMOUNT
       )
       SELECT
         jlje.HEADER_ID                  AS HEADER_ID,
         row_number() OVER (PARTITION BY  HEADER_ID  ORDER BY DISTRIBUTION_ID, MULTIPLIER) LINE_NUM,
         jlje.CCID                       AS CCID ,
         jlje.ACCOUNTING_CLASS_CODE      AS ACCOUNTING_CLASS_CODE ,
         jlje.ACCOUNT_DATE               AS ACCOUNT_DATE ,
         jlje.SET_OF_BOOKS_ID            AS SET_OF_BOOKS_ID,
         jlje.CURRENCY_CODE              AS CURRENCY_CODE ,
         jlje.CONVERSION_DATE            AS CONVERSION_DATE ,
         jlje.CONVERSION_RATE            AS CONVERSION_RATE ,
         jlje.CONVERSION_RATE_TYPE       AS CONVERSION_RATE_TYPE ,
         jlje.PARTY_ID                   AS PARTY_ID ,
         jlje.PARTY_SITE_ID              AS PARTY_SITE_ID  ,
         jlje.EVENT_ID                   AS EVENT_ID ,
         jlje.DISTRIBUTION_ID            AS DISTRIBUTION_ID ,
         jlje.EVENT_CLASS_CODE           AS EVENT_CLASS_CODE ,
         jlje.EVENT_TYPE_CODE            AS EVENT_TYPE_CODE ,
         jlje.ACCOUNTED_CR               AS ACCOUNTED_CR  ,
         jlje.ACCOUNTED_DR               AS ACCOUNTED_DR ,
         jlje.ENTERED_CR                 AS ENTERED_CR ,
         jlje.ENTERED_DR                 AS ENTERED_DR  ,
         jlje.UNROUNDED_ACCOUNTED_CR     AS UNROUNDED_ACCOUNTED_CR  ,
         jlje.UNROUNDED_ACCOUNTED_DR     AS UNROUNDED_ACCOUNTED_DR ,
         jlje.UNROUNDED_ENTERED_CR       AS UNROUNDED_ENTERED_CR ,
         jlje.UNROUNDED_ENTERED_DR       AS UNROUNDED_ENTERED_DR ,
         jlje.ENTERED_AMOUNT             AS ENTERED_AMOUNT,
         jlje.DESCRIPTION                AS DESCRIPTION,
         decode(gcc.reference3, 'Y', 'P', NULL)  AS CONTROL_BALANCE_FLAG,
         jlje.REF_HEADER_ID              AS REF_HEADER_ID ,
         jlje.REF_EVENT_ID               AS REF_EVENT_ID,
         jlje.multiplier AS MULTIPLIER
       FROM
       (SELECT  /*+ ordered use_hash(reftr2) no_expand use_nl_with_index(dist) */
         tr2.header_id  HEADER_ID,
         tr2.ACCOUNT_DATE ACCOUNT_DATE,
         tr2.SET_OF_BOOKS_ID SET_OF_BOOKS_ID,
         DECODE(grm.multiplier, 1 ,
           Decode(dist.distribution_type,
             'JLBR_AR_ENDORSEMENT', Decode( dist.accounting_reversal_option,'Y',
                                    TR2.endorsement_debit_ccid, TR2.endorsement_credit_ccid),
             'JLBR_AR_BANK_CHARGES', decode( dist.accounting_reversal_option,'Y',
                                           decode(dist.std_occurrence_code,'REJECTED_ENTRY',
                                              TR2.reverse_charges_cred_ccid, TR2.bank_charges_debit_ccid),
                                           TR2.bank_charges_credit_ccid),
             decode(dist.accounting_reversal_option,'Y', TR2.factor_interest_debit_ccid,
                    TR2.factor_interest_credit_ccid)),
          2, Decode(dist.distribution_type,
              'JLBR_AR_ENDORSEMENT', decode( dist.accounting_reversal_option,'Y',
                                     TR2.endorsement_credit_ccid, TR2.ENDORSEMENT_DEBIT_CCID),
              'JLBR_AR_BANK_CHARGES', decode( dist.accounting_reversal_option,'Y',
                                           decode(dist.std_occurrence_code, 'REJECTED_ENTRY',
                                              TR2.reverse_charges_deb_ccid, TR2.bank_charges_credit_ccid),
                                           TR2.bank_charges_debit_ccid),
              decode(dist.accounting_reversal_option,'Y', TR2.factor_interest_credit_ccid,
                     TR2.factor_interest_debit_ccid)))   CCID,
        Decode(dist.distribution_type,
                 'JLBR_AR_ENDORSEMENT', decode( TR2.bordero_type,'COLLECTION', 'REMITTANCE', 'FACTOR'),
                 decode(grm.multiplier,
                   1,decode(dist.accounting_reversal_option,'Y','BANK_CHARGES','CASH'),
                   2,decode(dist.accounting_reversal_option,'Y','CASH','BANK_CHARGES')))  ACCOUNTING_CLASS_CODE,
         dist.entered_currency_code CURRENCY_CODE,
         dist.CONVERSION_DATE  CONVERSION_DATE,
         dist.CONVERSION_RATE  CONVERSION_RATE,
         dist.CONVERSION_RATE_TYPE CONVERSION_RATE_TYPE,
         TR2.bill_to_customer_id PARTY_ID,
         TR2.bill_to_site_use_id PARTY_SITE_ID ,
         TR2.event_id EVENT_ID,
         TR2.OCCURRENCE_STATUS OCCURRENCE_STATUS,
         dist.distribution_id DISTRIBUTION_ID,
         dist.prior_dist_id PRIOR_DIST_ID,
         dist.reversed_dist_id REVERSED_DIST_ID,
         refTR2.header_id  REF_HEADER_ID,
         refTR2.event_id REF_EVENT_ID,
         decode(TR2.bordero_type,'COLLECTION','COLLECTION_OCC_DOCUMENT',
                                 'FACTORING_OCC_DOCUMENT') EVENT_CLASS_CODE,
         TR2.event_type_code EVENT_TYPE_CODE,
         decode(grm.multiplier,1,dist.acctd_amt,2,NULL)  ACCOUNTED_CR ,
         decode(grm.multiplier,1,NULL,2,dist.acctd_amt)  ACCOUNTED_DR,
         decode(grm.multiplier,1,dist.entered_amt,2,NULL)  ENTERED_CR,
         decode(grm.multiplier,1,NULL,2,dist.entered_amt) ENTERED_DR ,
         decode(grm.multiplier,1,dist.acctd_amt,2,NULL) UNROUNDED_ACCOUNTED_CR ,
         decode(grm.multiplier,1,NULL,2,dist.acctd_amt) UNROUNDED_ACCOUNTED_DR,
         decode(grm.multiplier,1,dist.entered_amt,2,NULL) UNROUNDED_ENTERED_CR,
         decode(grm.multiplier,1,NULL,2,dist.entered_amt) UNROUNDED_ENTERED_DR,
         dist.entered_amt  ENTERED_AMOUNT,
        decode(grm.multiplier,1,'Credito '||decode(dist.distribution_type,'JLBR_AR_ENDORSEMENT',
                     decode(TR2.std_occurrence_code,'REMITTANCE','Endosso para ','OTHER_DATA_CHANGING','Endosso para ','Titulo em '),'Banco Conta Movimento ') || decode(dist.distribution_type,'JLBR_AR_ENDORSEMENT',
                     decode(TR2.bordero_type,'COLLECTION','COBRANCA ','DESCONTO '), '')||
                     decode(TR2.occurrence_status,'CANCELED','- Cobranca Bancaria - Cancelamento','- Cobranca Bancaria - ')||
                     decode(TR2.occurrence_status,'CANCELED','Remittance',
                     decode(TR2.std_occurrence_code, 'REMITTANCE','Remittance',
                     'WRITE_OFF_REQUISITION', 'Write-off', 'CONFIRMED_ENTRY','Confirmation', 'REJECTED_ENTRY', 'Rejection', 'FULL_SETTLEMENT', 'Bank Receipts', 'PARTIAL_SETTLEMENT', 'Bank Receipts',
                     'PAYMENT_AFTER_WRITE_OFF', 'Bank Receipts', 'AUTOMATIC_WRITE_OFF', 'Write-off', 'Bank Charges' )) ||
                     ' - Invoice ' ||substr(TR2.trx_number,1,15),
           2,
          'Debito '||decode(dist.distribution_type,'JLBR_AR_ENDORSEMENT',
                     decode(TR2.std_occurrence_code,'REMITTANCE','Titulo em ','OTHER_DATA_CHANGING','Titulo em ','Endosso para '),' Despesas Financeiras e Bancarias') ||
                     decode(dist.distribution_type,'JLBR_AR_ENDORSEMENT',
                     decode(TR2.bordero_type,'COLLECTION','COBRANCA ','DESCONTO'),'')||
                     decode(TR2.occurrence_status,'CANCELED','- Cobranca Bancaria - Cancelamento','- Cobranca Bancaria - ')||
                     decode(TR2.occurrence_status,'CANCELED','Remittance',
                     decode(TR2.std_occurrence_code, 'REMITTANCE','Remittance',
                     'WRITE_OFF_REQUISITION', 'Write-off', 'CONFIRMED_ENTRY','Confirmation', 'REJECTED_ENTRY', 'Rejection', 'FULL_SETTLEMENT', 'Bank Receipts', 'PARTIAL_SETTLEMENT', 'Bank Receipts',
                     'PAYMENT_AFTER_WRITE_OFF', 'Bank Receipts', 'AUTOMATIC_WRITE_OFF', 'Write-off', 'Bank Charges' )) ||
                     ' - Invoice ' ||substr(TR2.trx_number,1,15))  DESCRIPTION,
       grm.multiplier MULTIPLIER
       FROM
         jl_remit1_gt TR2,
         jl_remit1_gt refTR2,
         jl_br_ar_distributns_all dist,
         gl_row_multipliers grm
         WHERE
         dist.occurrence_id = TR2.occurrence_id
         And dist.document_id = TR2.document_id
         AND refTR2.document_id = TR2.document_id
         AND grm.multiplier < 3
         And (refTR2.event_type_code IN('REMIT_COLL_DOC' ,'REMIT_FACT_DOC')
              AND refTR2.occurrence_status = 'CONFIRMED'
              AND TR2.std_occurrence_code IN ('WRITE_OFF_REQUISITION','REJECTED_ENTRY',
                                              'FULL_SETTLEMENT','PARTIAL_SETTLEMENT','AUTOMATIC_WRITE_OFF')
              AND EXISTS(SELECT 'Y' FROM jl_br_ar_distributns_all dist2
                         WHERE dist2.occurrence_id = refTR2.occurrence_id
                         AND (dist2.distribution_id = dist.prior_dist_id and dist.prior_dist_id is not null
                          or dist2.distribution_id = dist.reversed_dist_id and dist.reversed_dist_id is not null))
             OR refTR2.occurrence_id = TR2.occurrence_id
                AND dist.prior_dist_id is null
                and dist.reversed_dist_id is null
             OR refTR2.occurrence_id = TR2.occurrence_id
                and refTR2.event_type_code IN('REMIT_COLL_DOC' ,'REMIT_FACT_DOC')
                and refTR2.occurrence_status ='CANCELREMIT'
        )) jlje ,
         gl_code_combinations gcc
         WHERE gcc.code_combination_id = jlje.ccid;


         l_rows_processed := l_rows_processed + SQL%ROWCOUNT;

         ad_parallel_updates_pkg.processed_id_range(
                       l_rows_processed,
                       l_end_rowid);

         commit;

         ad_parallel_updates_pkg.get_id_range(
                       l_start_rowid,
                       l_end_rowid,
                       l_any_rows_to_process,
                       l_batch_size,
                       FALSE);

         l_rows_processed := 0 ;

  END LOOP ; /* end of WHILE loop */

EXCEPTION
  WHEN NO_DATA_FOUND THEN
    /*IF l_action_flag = 'R' THEN
       FND_MESSAGE.SET_NAME('FND', 'FND_GENERIC_MESSAGE');
       FND_MESSAGE.SET_TOKEN('MASSAGE' ,'Exception NO_DATA_FOUND in UPGRADE_OCCURRENCES ');
       FND_MSG_PUB.ADD;
       x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    ELSE
       RAISE;
    END IF;
*/
 NULL;

  WHEN OTHERS THEN
    IF l_action_flag = 'R' THEN
       FND_MESSAGE.SET_NAME('FND', 'FND_GENERIC_MESSAGE');
       FND_MESSAGE.SET_TOKEN('MASSAGE' ,'Exception OTHER in UPGRADE_OCCURRENCES '||SQLERRM);
       FND_MSG_PUB.ADD;
       x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    ELSE
      RAISE;
    END IF;

 IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL ) THEN
    	FND_LOG.STRING(G_LEVEL_STATEMENT, 'JL.plsql.JL_BR_AR_BANK_ACCT_PKG.Upgrade_Distributions','End procedure UPGRADE_OCCURRENCES');
   END IF;
END UPGRADE_OCCURRENCES;


/*========================================================================
 | PUBLIC PROCEDURE Update_Occurrences
 |
 | DESCRIPTION
 |     Upgrades Posted or Yet to be Posted Occurrences to SLA tables
 |     Called directly from on-demand upgrade concurrent program
 |
 | CALLED FROM PROCEDURES/FUNCTIONS (local to this package body)
 |
 | CALLS PROCEDURES/FUNCTIONS (local to this package body)
 |
 | PARAMETERS
 |
 | KNOWN ISSUES
 |
 | NOTES
 |
 | MODIFICATION HISTORY
 | Date                  Author            Description of Changes
 *=======================================================================*/

PROCEDURE UPDATE_OCCURRENCES(
                       l_table_owner  IN VARCHAR2,
                       l_table_name   IN VARCHAR2,
                       l_script_name  IN VARCHAR2,
                       l_worker_id    IN VARCHAR2,
                       l_num_workers  IN VARCHAR2,
                       l_batch_size   IN VARCHAR2,
                       l_batch_id     IN NUMBER,
                       l_action_flag  IN VARCHAR2,
                       x_return_status  OUT NOCOPY  VARCHAR2) IS

l_start_rowid         rowid;
l_end_rowid           rowid;
l_any_rows_to_process boolean;
l_rows_processed      number := 0;

BEGIN
  IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL ) THEN
    	FND_LOG.STRING(G_LEVEL_STATEMENT, 'JL.plsql.JL_BR_AR_BANK_ACCT_PKG.UPDATE_OCCURRENCES','Start procedure UPDATE_OCCURRENCES');
   END IF;
  IF l_action_flag  = 'R' THEN
    x_return_status := FND_API.G_RET_STS_SUCCESS;
  END IF;

  /* ------ Initialize the rowid ranges ------ */
  ad_parallel_updates_pkg.initialize_rowid_range(
           ad_parallel_updates_pkg.ROWID_RANGE,
           l_table_owner,
           l_table_name,
           l_script_name,
           l_worker_id,
           l_num_workers,
           l_batch_size, 0);

  /* ------ Get rowid ranges ------ */
  ad_parallel_updates_pkg.get_rowid_range(
           l_start_rowid,
           l_end_rowid,
           l_any_rows_to_process,
           l_batch_size,
           TRUE);

  WHILE ( l_any_rows_to_process = TRUE )
  LOOP

   l_rows_processed := 0;

-------------------------------------------------------------------
-- Update event_id for unposted occurrences and distributions
-- This will be used by Extract objects when Create Accounting
-- program of SLA is run for the non posted data
-------------------------------------------------------------------
  /*         UPDATE jl_br_ar_occurrence_docs_all oc
         SET event_id = decode(oc.gl_posted_date, NULL, (SELECT a.event_id
                               FROM xla_events a, xla_transaction_entities_upg c, ar_system_parameters_all sys
                               WHERE sys.org_id = oc.org_id
                               AND   a.entity_id = c.entity_id
                               AND   a.event_type_code NOT IN ('CANCEL_COLL_DOC', 'CANCEL_FACT_DOC')
                               AND   c.APPLICATION_ID = 222
                               AND   c.ENTITY_CODE = 'JL_BR_AR_COLL_DOC_OCCS'
                               AND   c.LEDGER_ID = sys.set_of_books_id
                               AND   c.SOURCE_ID_INT_1 = oc.document_id
                               AND   c.source_id_int_2 = oc.occurrence_id),NULL) ,
             cancel_event_id = decode(oc.occurrence_status, 'CANCELED',(SELECT a1.event_id
                                      FROM xla_events a1, xla_transaction_entities_upg c1, ar_system_parameters_all sys1
                                      WHERE sys1.org_id = oc.org_id
                                      AND   a1.entity_id = c1.entity_id
                                      AND   a1.event_type_code IN ('CANCEL_COLL_DOC', 'CANCEL_FACT_DOC')
                                      AND   c1.APPLICATION_ID = 222
                                      AND   c1.ENTITY_CODE = 'JL_BR_AR_COLL_DOC_OCCS'
                                      AND   c1.LEDGER_ID = sys1.set_of_books_id
                                      AND   c1.SOURCE_ID_INT_1 = oc.document_id
                                      AND   c1.source_id_int_2 = oc.occurrence_id),NULL)
          WHERE oc.rowid >= l_start_rowid
          AND   oc.rowid <= l_end_rowid
          AND   (oc.flag_post_gl = 'N' OR oc.flag_post_gl IS NULL)
          AND   oc.event_id IS NULL;

  */

   IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL ) THEN
    	FND_LOG.STRING(G_LEVEL_STATEMENT, 'JL.plsql.JL_BR_AR_BANK_ACCT_PKG.UPDATE_OCCURRENCES','Update table jl_br_ar_distributns_all');
        FND_LOG.STRING(G_LEVEL_STATEMENT, 'JL.plsql.JL_BR_AR_BANK_ACCT_PKG.UPDATE_OCCURRENCES','Update event_id for unposted occurrences and distributions');
	FND_LOG.STRING(G_LEVEL_STATEMENT, 'JL.plsql.JL_BR_AR_BANK_ACCT_PKG.UPDATE_OCCURRENCES','This will be used by Extract objects when Create Accounting program of SLA is run for the non posted data');
   END IF;
         UPDATE /*+ rowid(jlbr) */ jl_br_ar_distributns_all jlbr
         SET    event_id = decode(jlbr.accounting_reversal_option, 'Y',
                                     (SELECT a1.event_id
                                      FROM xla_events a1, xla_transaction_entities_upg c1, ar_system_parameters_all sys1,
                                           jl_br_ar_occurrence_docs_all oc1
                                      WHERE jlbr.occurrence_id = oc1.occurrence_id
                                      AND   sys1.org_id = oc1.org_id
                                      AND   a1.entity_id = c1.entity_id
                                      AND   ((a1.event_type_code IN ('CANCEL_COLL_DOC', 'CANCEL_FACT_DOC')
                                              AND oc1.occurrence_status = 'CANCELED')
                                            OR (oc1.occurrence_status <> 'CANCELED'))
                                      AND   c1.APPLICATION_ID = 222
                                      AND   c1.ENTITY_CODE = 'JL_BR_AR_COLL_DOC_OCCS'
                                      AND   c1.LEDGER_ID = sys1.set_of_books_id
                                      AND   nvl(c1.SOURCE_ID_INT_1,-99) = oc1.document_id
                                      AND   nvl(c1.source_id_int_2,-99) = oc1.occurrence_id),
                                     (SELECT a.event_id
                                      FROM xla_events a, xla_transaction_entities_upg c, ar_system_parameters_all sys
                                      WHERE sys.org_id = jlbr.org_id
                                      AND   a.entity_id = c.entity_id
                                      AND   a.event_type_code NOT IN ('CANCEL_COLL_DOC', 'CANCEL_FACT_DOC')
                                      AND   c.APPLICATION_ID = 222
                                      AND   c.ENTITY_CODE = 'JL_BR_AR_COLL_DOC_OCCS'
                                      AND   c.LEDGER_ID = sys.set_of_books_id
                                      AND   nvl(c.SOURCE_ID_INT_1,-99) = jlbr.document_id
                                      AND   nvl(c.source_id_int_2,-99) = jlbr.occurrence_id))
          WHERE jlbr.event_id IS NULL
          AND   jlbr.rowid >= l_start_rowid
          AND   jlbr.rowid <= l_end_rowid
          AND EXISTS (SELECT 'Y' from jl_br_ar_occurrence_docs_all occ
                      WHERE occ.occurrence_id = jlbr.occurrence_id
                      AND   (occ.flag_post_gl = 'N' OR occ.flag_post_gl IS NULL));

         l_rows_processed := l_rows_processed + SQL%ROWCOUNT;

         ad_parallel_updates_pkg.processed_rowid_range(
                       l_rows_processed,
                       l_end_rowid);

         commit;

         ad_parallel_updates_pkg.get_rowid_range(
                       l_start_rowid,
                       l_end_rowid,
                       l_any_rows_to_process,
                       l_batch_size,
                       FALSE);

         l_rows_processed := 0 ;

  END LOOP ; /* end of WHILE loop */

EXCEPTION
  WHEN NO_DATA_FOUND THEN
      IF (G_LEVEL_EXCEPTION >= G_CURRENT_RUNTIME_LEVEL ) THEN
          	FND_LOG.STRING(G_LEVEL_EXCEPTION, 'JL.plsql.JL_BR_AR_BANK_ACCT_PKG.UPDATE_OCCURRENCES','No data found in FUNCTION UPDATE_OCCURRENCES');
		NULL;
      END IF;
    IF l_action_flag = 'R' THEN
       FND_MESSAGE.SET_NAME('FND', 'FND_GENERIC_MESSAGE');
       FND_MESSAGE.SET_TOKEN('MASSAGE' ,'Exception NO_DATA_FOUND in UPGRADE_OCCURRENCES ');
       FND_MSG_PUB.ADD;
       x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    ELSE
       RAISE;
    END IF;

  WHEN OTHERS THEN
    IF l_action_flag = 'R' THEN
       IF (G_LEVEL_EXCEPTION >= G_CURRENT_RUNTIME_LEVEL ) THEN
          	FND_LOG.STRING(G_LEVEL_EXCEPTION, 'JL.plsql.JL_BR_AR_BANK_ACCT_PKG.UPDATE_OCCURRENCES','Exception in FUNCTION UPDATE_OCCURRENCES');
		NULL;
	END IF;
       FND_MESSAGE.SET_NAME('FND', 'FND_GENERIC_MESSAGE');
       FND_MESSAGE.SET_TOKEN('MASSAGE' ,'Exception OTHER in UPGRADE_OCCURRENCES '||SQLERRM);
       FND_MSG_PUB.ADD;
       x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

    ELSE
      RAISE;
    END IF;

  IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL ) THEN
    	FND_LOG.STRING(G_LEVEL_STATEMENT, 'JL.plsql.JL_BR_AR_BANK_ACCT_PKG.UPDATE_OCCURRENCES','End procedure UPDATE_OCCURRENCES');
   END IF;
END UPDATE_OCCURRENCES;


/*========================================================================
 | PUBLIC PROCEDURE Load_Occurrences_Header_Data
 |
 | DESCRIPTION
 |     Upgrades Posted or Yet to be Posted Occurrences to SLA tables
 |     Called directly from on-demand upgrade concurrent program
 |
 | CALLED FROM PROCEDURES/FUNCTIONS (local to this package body)
 |
 | CALLS PROCEDURES/FUNCTIONS (local to this package body)
 |
 | PARAMETERS
 |
 | KNOWN ISSUES
 |
 | NOTES
 |
 | MODIFICATION HISTORY
 | Date                  Author            Description of Changes
 *=======================================================================*/

PROCEDURE load_occurrences_header_data(p_application_id IN NUMBER) IS

l_application_id      NUMBER;

BEGIN
   IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL ) THEN
    	FND_LOG.STRING(G_LEVEL_STATEMENT, 'JL.plsql.JL_BR_AR_BANK_ACCT_PKG.load_occurrences_header_data','Start procedure load_occurrences_header_data');
   END IF;
       IF p_application_id IS NULL THEN
         l_application_id := 222;
       ELSE
         l_application_id := p_application_id;
       END IF;
     IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL ) THEN
    	FND_LOG.STRING(G_LEVEL_STATEMENT, 'JL.plsql.JL_BR_AR_BANK_ACCT_PKG.load_occurrences_header_data','l_application_id ='||l_application_id);
        FND_LOG.STRING(G_LEVEL_STATEMENT, 'JL.plsql.JL_BR_AR_BANK_ACCT_PKG.load_occurrences_header_data','Insert into AR_XLA_LINES_EXTRACT ');
      END IF;
       INSERT INTO AR_XLA_LINES_EXTRACT(
          EVENT_ID
         ,LEDGER_ID
         ,SET_OF_BOOKS_ID
         ,ORG_ID
         ,CUSTOMER_TRX_ID
         ,REMITTANCE_BANK_ACCT_ID
         ,PAYMENT_SCHEDULE_ID
         ,RECEIPT_METHOD_ID
         ,SALESREP_ID
         ,BILL_SITE_USE_ID
         ,PAYING_SITE_USE_ID
         ,SOLD_SITE_USE_ID
         ,SHIP_SITE_USE_ID
         ,BILL_CUSTOMER_ID
         ,PAYING_CUSTOMER_ID
         ,SOLD_CUSTOMER_ID
         ,SHIP_CUSTOMER_ID
         ,REMIT_ADDRESS_ID
         ,SELECT_FLAG
         ,LEVEL_FLAG
         ,PAIRED_CCID
         ,EVENT_CLASS_CODE
        )
       SELECT /*+INDEX (gt XLA_EVENTS_GT_U1)*/
          gt.event_id                   -- EVENT_ID
         ,trx.set_of_books_id           -- LEDGER_ID
         ,trx.set_of_books_id           -- SET_OF_BOOKS_ID
         ,trx.org_id                    -- ORG_ID
         ,cd.customer_trx_id            -- CUSTOMER_TRX_ID
         ,jlh.jlbr_bank_acct_use_id     -- REMITTANCE_BANK_ACCT_ID
         ,cd.payment_schedule_id        -- PAYMENT_SCHEDULE_ID
         ,jlh.jlbr_receipt_method_id    -- RECEIPT_METHOD_ID
         ,trx.primary_salesrep_id       -- SALESREP_ID
         ,trx.bill_to_site_use_id       -- BILL_SITE_USE_ID
         ,trx.paying_site_use_id        -- PAYING_SITE_USE_ID
         ,trx.sold_to_site_use_id       -- SOLD_SITE_USE_ID
         ,trx.ship_to_site_use_id       -- SHIP_SITE_USE_ID
         ,trx.bill_to_customer_id       -- BILL_CUSTOMER_ID
         ,trx.paying_customer_id        -- PAYING_CUSTOMER_ID
         ,trx.sold_to_customer_id       -- SOLD_CUSTOMER_ID
         ,trx.ship_to_customer_id       -- SHIP_CUSTOMER_ID
         ,trx.remit_to_address_id       -- REMIT_ADDRESS_ID
         ,'Y'                           -- SELECT_FLAG
         ,'H'                           -- LEVEL_FLAG
         ,ctlgd.code_combination_id     -- PAIRED_CCID
         ,'INVOICE'                     -- EVENT_CLASS_CODE
      FROM ra_customer_trx_all            trx,
           xla_events_gt                  gt,
           ra_cust_trx_line_gl_dist_all   ctlgd,
           jl_br_ar_collection_docs_all   cd,
           jl_br_ar_coll_occ_docs_h_v     jlh
     WHERE gt.entity_code            = 'JL_BR_AR_COLL_DOC_OCCS'
       AND gt.application_id         = l_application_id
       AND jlh.jlbr_document_id      = gt.source_id_int_1
       -- AND jlh.jlbr_occurrence_id    = gt.source_id_int_2  bug 8664016
       AND jlh.event_id              = gt.event_id   -- Bug 8647045
       AND cd.document_id            = gt.source_id_int_1 --jlh.jlbr_document_id for bug9304840
       AND trx.customer_trx_id       = cd.customer_trx_id
       AND trx.customer_trx_id       = ctlgd.customer_trx_id
       AND ctlgd.account_class       = 'REC'
       AND ctlgd.account_set_flag    = 'N';

EXCEPTION
  WHEN NO_DATA_FOUND THEN
    NULL;
  WHEN OTHERS THEN
     IF (G_LEVEL_EXCEPTION >= G_CURRENT_RUNTIME_LEVEL ) THEN
          	FND_LOG.STRING(G_LEVEL_EXCEPTION, 'JL.plsql.JL_BR_AR_BANK_ACCT_PKG.load_occurrences_header_data','Exception in FUNCTION load_occurrences_header_data');
		NULL;
	END IF;
    FND_MESSAGE.SET_NAME('FND', 'FND_GENERIC_MESSAGE');
    FND_MESSAGE.SET_TOKEN('MESSAGE' ,
         'Procedure :jl_br_ar_bank_acct_pkg.load_occurrences_header_data'||
         'Error     :'||SQLERRM);
    FND_MSG_PUB.ADD;

     IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL ) THEN
    	FND_LOG.STRING(G_LEVEL_STATEMENT, 'JL.plsql.JL_BR_AR_BANK_ACCT_PKG.load_occurrences_header_data','End of procedure');
      END IF;
END load_occurrences_header_data;


/*========================================================================
 | PUBLIC FUNCTION Check_If_Upgrade_Occs
 |
 | DESCRIPTION
 |      To be used only by the on-demand SLA upgrade program of AR to check
 |      if Brazilian Occurrences Upgrade is to be executed or not
 |
 | CALLED FROM PROCEDURES/FUNCTIONS (local to this package body)
 |
 | CALLS PROCEDURES/FUNCTIONS (local to this package body)
 |
 | PARAMETERS
 |
 | KNOWN ISSUES
 |
 | NOTES
 |
 | MODIFICATION HISTORY
 | Date                  Author            Description of Changes
 *=======================================================================*/

FUNCTION check_if_upgrade_occs RETURN BOOLEAN IS

     dummy NUMBER;

BEGIN
    IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL ) THEN
    	FND_LOG.STRING(G_LEVEL_STATEMENT, 'JL.plsql.JL_BR_AR_BANK_ACCT_PKG.check_if_upgrade_occs','Start of procedure check_if_upgrade_occs');
    END IF;
     SELECT 1 INTO dummy
     FROM ar_system_parameters_all
     WHERE global_attribute_category IS NOT NULL
     AND   global_attribute_category = 'JL.BR.ARXSYSPA.Additional Info'
     AND   rownum = 1;

      IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL ) THEN
    	FND_LOG.STRING(G_LEVEL_STATEMENT, 'JL.plsql.JL_BR_AR_BANK_ACCT_PKG.check_if_upgrade_occs','dummy='||dummy);
    END IF;
     RETURN TRUE;

     EXCEPTION
       WHEN NO_DATA_FOUND THEN
         RETURN FALSE;

END check_if_upgrade_occs;

/*========================================================================
 | PUBLIC PROCEDURE Upgrade_Mc_Occurrences
 |
 | DESCRIPTION
 |      Upgrades JL MRC records to SLA Archetecture
 |
 | CALLED FROM PROCEDURES/FUNCTIONS (local to this package body)
 |
 | CALLS PROCEDURES/FUNCTIONS (local to this package body)
 |
 | PARAMETERS
 |
 | KNOWN ISSUES
 |
 | NOTES
 |
 | MODIFICATION HISTORY
 | Date                  Author            Description of Changes
 | 21-SEP-2005           JVARKEY           Created
 | 29-SEP-2005           SSAKAMUR          Added overloaded version for
 |                                         on-demand upgrade
 *=======================================================================*/

-- Called directly from downtime upgrade script

PROCEDURE UPGRADE_MC_OCCURRENCES(
                       l_table_owner  IN VARCHAR2,
                       l_table_name   IN VARCHAR2,
                       l_script_name  IN VARCHAR2,
                       l_worker_id    IN VARCHAR2,
                       l_num_workers  IN VARCHAR2,
                       l_batch_size   IN VARCHAR2,
                       l_batch_id     IN NUMBER,
                       l_action_flag  IN VARCHAR2) IS

l_return_status         VARCHAR2(30);

BEGIN
 IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL ) THEN
    	FND_LOG.STRING(G_LEVEL_STATEMENT, 'JL.plsql.JL_BR_AR_BANK_ACCT_PKG.UPGRADE_MC_OCCURRENCES','Start of procedure UPGRADE_MC_OCCURRENCES');
    END IF;
          UPGRADE_MC_OCCURRENCES(
                       l_table_owner,
                       l_table_name,
                       l_script_name,
                       l_worker_id,
                       l_num_workers,
                       l_batch_size,
                       l_batch_id,
                       l_action_flag,
                       l_return_status);

END Upgrade_Mc_Occurrences;


-- Called Directly from on-demand upgrade program

PROCEDURE UPGRADE_MC_OCCURRENCES(
                       l_table_owner  IN VARCHAR2,
                       l_table_name   IN VARCHAR2,
                       l_script_name  IN VARCHAR2,
                       l_worker_id    IN VARCHAR2,
                       l_num_workers  IN VARCHAR2,
                       l_batch_size   IN VARCHAR2,
                       l_batch_id     IN NUMBER,
                       l_action_flag  IN VARCHAR2,
                       x_return_status  OUT NOCOPY  VARCHAR2) IS

l_start_rowid         rowid;
l_end_rowid           rowid;
l_any_rows_to_process boolean;
l_rows_processed      number := 0;

BEGIN
   IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL ) THEN
    	FND_LOG.STRING(G_LEVEL_STATEMENT, 'JL.plsql.JL_BR_AR_BANK_ACCT_PKG.UPGRADE_MC_OCCURRENCES','Start of procedure UPGRADE_MC_OCCURRENCES');
   END IF;
  IF l_action_flag  = 'R' THEN
    x_return_status := FND_API.G_RET_STS_SUCCESS;
  END IF;

  /* ------ Initialize the rowid ranges ------ */
  ad_parallel_updates_pkg.initialize_rowid_range(
           ad_parallel_updates_pkg.ROWID_RANGE,
           l_table_owner,
           l_table_name,
           l_script_name,
           l_worker_id,
           l_num_workers,
           l_batch_size, 0);

  /* ------ Get rowid ranges ------ */
  ad_parallel_updates_pkg.get_rowid_range(
           l_start_rowid,
           l_end_rowid,
           l_any_rows_to_process,
           l_batch_size,
           TRUE);

  WHILE ( l_any_rows_to_process = TRUE )
  LOOP

   l_rows_processed := 0;

 IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL ) THEN
    	FND_LOG.STRING(G_LEVEL_STATEMENT, 'JL.plsql.JL_BR_AR_BANK_ACCT_PKG.UPGRADE_MC_OCCURRENCES','Create the Journal Entry Headers, insert into XLA_AE_HEADERS, ');
    END IF;
--------------------------------------
-- Create the Journal Entry Headers --
--------------------------------------
   INSERT ALL
     WHEN 1 = 1 THEN
     INTO XLA_AE_HEADERS
     (
     AE_HEADER_ID,
     APPLICATION_ID,
     LEDGER_ID,
     ENTITY_ID,
     EVENT_ID,
     EVENT_TYPE_CODE,
     ACCOUNTING_DATE,
     PERIOD_NAME,
     JE_CATEGORY_NAME,
     GL_TRANSFER_STATUS_CODE,
     GL_TRANSFER_DATE,
     GROUP_ID,
     ACCOUNTING_ENTRY_STATUS_CODE,
     ACCOUNTING_ENTRY_TYPE_CODE,
     AMB_CONTEXT_CODE,
     PRODUCT_RULE_TYPE_CODE,
     PRODUCT_RULE_CODE,
     PRODUCT_RULE_VERSION,
     DESCRIPTION,
     BUDGET_VERSION_ID,
     FUNDS_STATUS_CODE,
     ENCUMBRANCE_TYPE_ID,
     BALANCE_TYPE_CODE,
     REFERENCE_DATE,
     COMPLETED_DATE,
     PACKET_ID,
     ACCOUNTING_BATCH_ID,
     DOC_SEQUENCE_ID,
     DOC_SEQUENCE_VALUE,
     DOC_CATEGORY_CODE,
     CLOSE_ACCT_SEQ_ASSIGN_ID,
     CLOSE_ACCT_SEQ_VERSION_ID,
     CLOSE_ACCT_SEQ_VALUE,
     COMPLETION_ACCT_SEQ_ASSIGN_ID,
     COMPLETION_ACCT_SEQ_VERSION_ID,
     COMPLETION_ACCT_SEQ_VALUE,
     ATTRIBUTE_CATEGORY,
     ATTRIBUTE1,
     ATTRIBUTE2,
     ATTRIBUTE3,
     ATTRIBUTE4,
     ATTRIBUTE5,
     ATTRIBUTE6,
     ATTRIBUTE7,
     ATTRIBUTE8,
     ATTRIBUTE9,
     ATTRIBUTE10,
     ATTRIBUTE11,
     ATTRIBUTE12,
     ATTRIBUTE13,
     ATTRIBUTE14,
     ATTRIBUTE15,
     CREATION_DATE,
     CREATED_BY,
     LAST_UPDATE_DATE,
     LAST_UPDATED_BY,
     LAST_UPDATE_LOGIN,
     PROGRAM_UPDATE_DATE,
     PROGRAM_APPLICATION_ID,
     PROGRAM_ID,
     REQUEST_ID,
     DOC_SEQUENCE_VERSION_ID,
     DOC_SEQUENCE_ASSIGN_ID,
     UPG_BATCH_ID,
     UPG_SOURCE_APPLICATION_ID,
     UPG_VALID_FLAG,
     ZERO_AMOUNT_FLAG,
     PARENT_AE_HEADER_ID,
     PARENT_AE_LINE_NUM
     )
     VALUES
     (
      xla_ae_headers_s.nextval,
      222,
      sob_id,
      entity_id,
      event_id,
      event_type_code,
      account_date,
      period_name,
      category_name,
      'Y',
      gl_transfer_date,
      null,
      'F',
      'STANDARD',
      'DEFAULT',
      null,
      null,
      null,
      null,
      null,
      null,
      null,
      'A',
      null,
      null,
      null,
      null,
      null,
      null,
      null,
      null,
      null,
      null,
      null,
      null,
      null,
      null,
      null,
      null,
      null,
      null,
      null,
      null,
      null,
      null,
      null,
      null,
      null,
      null,
      null,
      null,
      null,
      sysdate,
       2,
      sysdate,
       2,
      -2005,
      sysdate,
      222,
      -2005,
      null,
      null,
      null,
      batch_id,
      222,
      null,
      'N' ,
      null,
      null)
      SELECT
          l_batch_id          AS batch_id,
          sob_id              AS sob_id,
          entity_id           AS entity_id,
          event_id            AS event_id,
          event_type_code     AS event_type_code,
          account_date        AS account_date,
          period_name         AS period_name,
          category_name       AS category_name,
          gl_transfer_date    AS gl_transfer_date
      FROM
      (select /*+ ordered use_nl(mcod,cd,ct,lgr,map,gps,dist,ps,dl,hdr)
                  index(DL,XLA_DISTRIBUTION_LINKS_N1) index(HDR,XLA_AE_HEADERS_U1) */
          hdr.ae_header_id                                      ae_header_id,
          hdr.entity_id                                         entity_id,
          hdr.event_id                                          event_id,
          hdr.event_type_code                                   event_type_code,
          hdr.accounting_date                                   account_date,
          hdr.period_name                                       period_name,
          hdr.je_category_name                                  category_name,
          hdr.gl_transfer_date                                  gl_transfer_date,
          mcod.set_of_books_id                                  sob_id
       --
       from
          jl_br_ar_occurrence_docs_all od,
          jl_br_ar_mc_occ_docs mcod,
          jl_br_ar_collection_docs_all cd,
          ra_customer_trx_all ct,
          gl_ledgers lgr,
          gl_date_period_map map,
          gl_period_statuses gps,
          jl_br_ar_distributns_all dist,
          ar_mc_payment_schedules ps,
          xla_distribution_links dl,
          xla_ae_headers hdr
       --
       where od.rowid >= l_start_rowid
       and od.rowid <= l_end_rowid
       --
       and mcod.occurrence_id = od.occurrence_id
       and mcod.gl_posted_date is not null
       --
       and cd.document_id = od.document_id
       --
       and ct.customer_trx_id = cd.customer_trx_id
       --
       and lgr.ledger_id = ct.set_of_books_id
       --
       and map.period_set_name = lgr.period_set_name
       and map.period_type = lgr.accounted_period_type
       and (map.accounting_date = hdr.accounting_date
            OR (cd.document_status NOT IN ('CANCELED','PARTIALLY_RECEIVED','REFUSED','TOTALLY_RECEIVED','WRITTEN_OFF')
                AND hdr.event_type_code IN ('REMIT_COLL_DOC' ,'REMIT_FACT_DOC')
                AND od.occurrence_status <> 'CANCELED'))

       --
       and gps.application_id = 222
       and gps.period_name = map.period_name
       and gps.set_of_books_id = ct.set_of_books_id
       and gps.migration_status_code = 'P'
       --
       and dist.occurrence_id = od.occurrence_id
       --
       and ps.payment_schedule_id = cd.payment_schedule_id
       and ps.set_of_books_id = mcod.set_of_books_id
       --
       and dl.source_distribution_id_num_1 = dist.distribution_id
       and dl.source_distribution_type = 'JLBR_AR_DIST'
       and dl.application_id = 222
       --
       and hdr.ae_header_id = dl.ae_header_id
       and hdr.application_id = 222
       and hdr.ledger_id = ct.set_of_books_id
       --
       and NOT EXISTS(select 'Y' from xla_ae_headers hdr1
                      where hdr1.application_id = 222
                      and hdr1.ledger_id = mcod.set_of_books_id
                      and hdr1.entity_id = hdr.entity_id
                      and hdr1.event_id = hdr.event_id
                      and hdr1.event_type_code = hdr.event_type_code)
       --
       group by
         hdr.ae_header_id,
         hdr.entity_id,
         hdr.event_id,
         hdr.event_type_code,
         hdr.accounting_date,
         hdr.period_name,
         hdr.je_category_name,
         hdr.gl_transfer_date,
         mcod.set_of_books_id);

-----------------------------------------------------------
-- Create the Journal Entry Lines and Distribution Links --
-----------------------------------------------------------
    IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL ) THEN
    	FND_LOG.STRING(G_LEVEL_STATEMENT, 'JL.plsql.JL_BR_AR_BANK_ACCT_PKG.UPGRADE_MC_OCCURRENCES','Create the Journal Entry Lines and Distribution Links, insert into XLA_AE_LINES');
    END IF;
   INSERT ALL
   WHEN 1 = 1 THEN
   INTO XLA_AE_LINES
   (
     AE_HEADER_ID,
     AE_LINE_NUM,
     DISPLAYED_LINE_NUMBER,
     APPLICATION_ID,
     CODE_COMBINATION_ID,
     GL_TRANSFER_MODE_CODE,
     ACCOUNTED_CR ,
     ACCOUNTED_DR,
     ENTERED_CR,
     ENTERED_DR ,
     ACCOUNTING_CLASS_CODE,
     CURRENCY_CODE,
     CURRENCY_CONVERSION_DATE ,
     CURRENCY_CONVERSION_RATE ,
     CURRENCY_CONVERSION_TYPE ,
     DESCRIPTION,
     GL_SL_LINK_TABLE,
     GL_SL_LINK_ID   ,
     PARTY_ID ,
     PARTY_SITE_ID,
     PARTY_TYPE_CODE ,
     STATISTICAL_AMOUNT,
     USSGL_TRANSACTION_CODE,
     JGZZ_RECON_REF ,
     CONTROL_BALANCE_FLAG ,
     ANALYTICAL_BALANCE_FLAG ,
     ATTRIBUTE_CATEGORY,
     ATTRIBUTE1,
     ATTRIBUTE2,
     ATTRIBUTE3 ,
     ATTRIBUTE4 ,
     ATTRIBUTE5,
     ATTRIBUTE6,
     ATTRIBUTE7,
     ATTRIBUTE8 ,
     ATTRIBUTE9 ,
     ATTRIBUTE10 ,
     ATTRIBUTE11 ,
     ATTRIBUTE12,
     ATTRIBUTE13 ,
     ATTRIBUTE14,
     ATTRIBUTE15 ,
     CREATION_DATE,
     CREATED_BY,
     LAST_UPDATE_DATE,
     LAST_UPDATED_BY,
     LAST_UPDATE_LOGIN  ,
     PROGRAM_UPDATE_DATE ,
     PROGRAM_APPLICATION_ID ,
     PROGRAM_ID ,
     REQUEST_ID ,
     UPG_BATCH_ID,
     UPG_TAX_REFERENCE_ID1 ,
     UPG_TAX_REFERENCE_ID2 ,
     UPG_TAX_REFERENCE_ID3,
     UNROUNDED_ACCOUNTED_CR ,
     UNROUNDED_ACCOUNTED_DR,
     GAIN_OR_LOSS_FLAG,
     UNROUNDED_ENTERED_CR,
     UNROUNDED_ENTERED_DR ,
     SUBSTITUTED_CCID ,
     BUSINESS_CLASS_CODE)
     VALUES
     (
      header_id,
      line_num,
      line_num,
      222,
      ccid,
      'D' ,
      acctd_amount_cr ,
      acctd_amount_dr,
      amount_cr,
      amount_dr ,
      accounting_class_code,
      currency_code,
      conversion_date,
      conversion_rate,
      conversion_type,
      description,
      null,
      null,
      party_id,
      party_site_id ,
      'C',
      NULL ,
      NULL,
      NULL,
      control_balance_flag,
      NULL,
      NULL,
      NULL,
      NULL,
      NULL,
      NULL,
      NULL,
      NULL,
      NULL,
      NULL,
      NULL,
      NULL,
      NULL,
      NULL,
      NULL,
      NULL,
      NULL,
      sysdate,
       2,
      sysdate,
       2,
      -2005,
      sysdate,
      222,
      -2005,
      null,
      batch_id,
      null,
      null,
      null,
      acctd_amount_cr,
      acctd_amount_dr,
      'N' ,
      amount_cr,
      amount_dr,
      null,
      null
      )
      WHEN 1 = 1 THEN
      INTO XLA_DISTRIBUTION_LINKS
      (
      APPLICATION_ID,
      EVENT_ID,
      AE_HEADER_ID,
      AE_LINE_NUM,
      ACCOUNTING_LINE_CODE,
      ACCOUNTING_LINE_TYPE_CODE ,
      REF_AE_HEADER_ID,
      REF_TEMP_LINE_NUM,
      SOURCE_DISTRIBUTION_TYPE,
      SOURCE_DISTRIBUTION_ID_CHAR_1 ,
      SOURCE_DISTRIBUTION_ID_CHAR_2 ,
      SOURCE_DISTRIBUTION_ID_CHAR_3 ,
      SOURCE_DISTRIBUTION_ID_CHAR_4 ,
      SOURCE_DISTRIBUTION_ID_CHAR_5 ,
      SOURCE_DISTRIBUTION_ID_NUM_1 ,
      SOURCE_DISTRIBUTION_ID_NUM_2 ,
      SOURCE_DISTRIBUTION_ID_NUM_3 ,
      SOURCE_DISTRIBUTION_ID_NUM_4 ,
      SOURCE_DISTRIBUTION_ID_NUM_5 ,
      MERGE_DUPLICATE_CODE,
      TAX_LINE_REF_ID,
      TAX_SUMMARY_LINE_REF_ID ,
      TAX_REC_NREC_DIST_REF_ID,
      STATISTICAL_AMOUNT,
      TEMP_LINE_NUM,
      REF_EVENT_ID ,
      LINE_DEFINITION_OWNER_CODE,
      LINE_DEFINITION_CODE ,
      EVENT_CLASS_CODE,
      EVENT_TYPE_CODE,
      UPG_BATCH_ID  ,
      CALCULATE_ACCTD_AMTS_FLAG,
      CALCULATE_G_L_AMTS_FLAG  ,
      ROUNDING_CLASS_CODE      ,
      DOCUMENT_ROUNDING_LEVEL  ,
      UNROUNDED_ENTERED_DR     ,
      UNROUNDED_ENTERED_CR     ,
      DOC_ROUNDING_ENTERED_AMT ,
      DOC_ROUNDING_ACCTD_AMT   ,
      UNROUNDED_ACCOUNTED_DR   ,
      UNROUNDED_ACCOUNTED_CR
      )
      VALUES
      (
       222,
       event_id,
       header_id,
       line_num,
       accounting_class_code,
       'C',
       ref_header_id,
       null,
       'JLBR_AR_DIST',
       null,
       null,
       null ,
       null,
       null,
       distribution_id,
       null,
       null,
       null,
       null,
       'N',
       null,
       null,
       null,
       null,
       line_num,
       ref_event_id,
       null,
       null,
       event_class_code,
       event_type_code,
       batch_id,
       null,
       null,
       null,
       null,
       amount_dr,
       amount_cr,
       null,
       null,
       acctd_amount_dr,
       acctd_amount_cr
       )
   SELECT
       l_batch_id                    AS batch_id,
       header_id                     AS header_id,
       ref_header_id                 AS ref_header_id,
       distribution_id               AS distribution_id,
       event_id                      AS event_id,
       ref_event_id                  AS ref_event_id,
       ccid                          AS ccid,
       amount_dr                     AS amount_dr,
       amount_cr                     AS amount_cr,
       acctd_amount_dr               AS acctd_amount_dr,
       acctd_amount_cr               AS acctd_amount_cr,
       accounting_class_code         AS accounting_class_code,
       currency_code                 AS currency_code,
       conversion_rate               AS conversion_rate,
       conversion_date               AS conversion_date,
       conversion_type               AS conversion_type,
       description                   AS description,
       party_id                      AS party_id,
       party_site_id                 AS party_site_id,
       control_balance_flag          AS control_balance_flag,
       event_type_code               AS event_type_code,
       event_class_code              AS event_class_code,
       sob_id                        AS sob_id,
       RANK() OVER (PARTITION BY event_id, ref_header_id,sob_id
                    ORDER BY distribution_id, amount_dr) AS line_num
   FROM
   (select /*+ ordered use_nl(mcod,cd,ct,lgr,map,gps,dist,ps,dl,lin,hdr,hdr1,lgr1)
               index(DL,XLA_DISTRIBUTION_LINKS_N1) index(LIN,XLA_AE_LINES_U1) index(HDR,XLA_AE_HEADERS_U1) index(HDR1,XLA_AE_HEADERS_N2) */
          hdr1.ae_header_id              header_id,
          ref.ae_header_id               ref_header_id,
          ref.event_id                   ref_event_id,
          dist.distribution_id           distribution_id,
          dl.event_id                    event_id,
          lin.code_combination_id        ccid,
          dl.unrounded_entered_dr        amount_dr,
          dl.unrounded_entered_cr        amount_cr,
          decode(dl.unrounded_entered_dr,null,null,
                      gl_mc_currency_pkg.CurrRound(
                        dl.unrounded_entered_dr*NVL(ps.exchange_rate,1),
                                               lgr1.currency_code)) acctd_amount_dr,
          decode(dl.unrounded_entered_cr,null,null,
                      gl_mc_currency_pkg.CurrRound(
                        dl.unrounded_entered_cr*NVL(ps.exchange_rate,1),
                                               lgr1.currency_code)) acctd_amount_cr,
          lin.accounting_class_code      accounting_class_code,
          dist.entered_currency_code     currency_code,
          ps.exchange_rate               conversion_rate,
          ps.exchange_date               conversion_date,
          ps.exchange_rate_type          conversion_type,
          lin.description                description,
          lin.party_id                   party_id,
          lin.party_site_id              party_site_id,
          lin.control_balance_flag       control_balance_flag,
          dl.event_type_code             event_type_code,
          dl.event_class_code            event_class_code,
          mcod.set_of_books_id           sob_id
    --
    from
          jl_br_ar_occurrence_docs_all od,
          jl_br_ar_mc_occ_docs mcod,
          jl_br_ar_collection_docs_all cd,
          ra_customer_trx_all ct,
          gl_ledgers lgr,
          gl_date_period_map map,
          gl_period_statuses gps,
          jl_br_ar_distributns_all dist,
          ar_mc_payment_schedules ps,
          xla_distribution_links dl,
          xla_ae_lines lin,
          xla_ae_headers hdr,
          xla_ae_headers hdr1,
          xla_ae_headers ref,
          xla_ae_headers ref1,
          gl_ledgers lgr1
       --
    where od.rowid >= l_start_rowid
    and od.rowid <= l_end_rowid
    --
    and mcod.occurrence_id = od.occurrence_id
    and mcod.gl_posted_date is not null
    --
    and cd.document_id = od.document_id
    --
    and ct.customer_trx_id = cd.customer_trx_id
    --
    and lgr.ledger_id = ct.set_of_books_id
    --
    and map.period_set_name = lgr.period_set_name
    and map.period_type = lgr.accounted_period_type
    and (map.accounting_date = hdr.accounting_date
         OR (cd.document_status NOT IN ('CANCELED','PARTIALLY_RECEIVED','REFUSED','TOTALLY_RECEIVED','WRITTEN_OFF')
             AND hdr.event_type_code IN ('REMIT_COLL_DOC' ,'REMIT_FACT_DOC')
             AND od.occurrence_status <> 'CANCELED'))
    --
    and gps.application_id = 222
    and gps.period_name = map.period_name
    and gps.set_of_books_id = ct.set_of_books_id
    and gps.migration_status_code = 'P'
    --
    and dist.occurrence_id = od.occurrence_id
    --
    and ps.payment_schedule_id = cd.payment_schedule_id
    and ps.set_of_books_id = mcod.set_of_books_id
    --
    and dl.source_distribution_id_num_1 = dist.distribution_id
    and dl.source_distribution_type = 'JLBR_AR_DIST'
    and dl.application_id = 222
    --
    and lin.application_id = 222
    and lin.ae_header_id = dl.ae_header_id
    and lin.ae_line_num = dl.ae_line_num
    --
    and hdr.ae_header_id = lin.ae_header_id
    and hdr.application_id = 222
    and hdr.ledger_id = ct.set_of_books_id
    --
    and hdr1.application_id = 222
    and hdr1.ledger_id = mcod.set_of_books_id
    and hdr1.entity_id = hdr.entity_id
    and hdr1.event_id = hdr.event_id
    and hdr1.event_type_code = hdr.event_type_code
    --
    and lgr1.ledger_id = mcod.set_of_books_id
    --
    and ref.application_id = 222
    and ref.ledger_id = mcod.set_of_books_id
    and ref.entity_id = ref1.entity_id
    and ref.event_id = ref1.event_id
    and ref.event_type_code = ref1.event_type_code
    --
    and ref1.ae_header_id = dl.ref_ae_header_id
    --
    and NOT EXISTS(select 'Y' from xla_distribution_links dl2, xla_ae_headers hdr2
                   where dl2.application_id = 222
                   and dl2.source_distribution_id_num_1 = dist.distribution_id
                   and dl2.source_distribution_type = 'JLBR_AR_DIST'
                   and hdr2.ae_header_id = dl2.ae_header_id
                   and hdr2.application_id = 222
                   and hdr2.ledger_id = mcod.set_of_books_id)
    );

   l_rows_processed := SQL%ROWCOUNT;

   ad_parallel_updates_pkg.processed_rowid_range(
                       l_rows_processed,
                       l_end_rowid);

   commit;

   ad_parallel_updates_pkg.get_rowid_range(
                       l_start_rowid,
                       l_end_rowid,
                       l_any_rows_to_process,
                       l_batch_size,
                       FALSE);

   l_rows_processed := 0 ;

 END LOOP ; /* end of WHILE loop */

EXCEPTION
  WHEN NO_DATA_FOUND THEN
/*    IF l_action_flag = 'R' THEN
       FND_MESSAGE.SET_NAME('FND', 'FND_GENERIC_MESSAGE');
       FND_MESSAGE.SET_TOKEN('MASSAGE' ,'Exception NO_DATA_FOUND in UPGRADE_MC_OCCURRENCES ');
       FND_MSG_PUB.ADD;
       x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    ELSE
       RAISE;
    END IF;
*/
   NULL;

  WHEN OTHERS THEN
    IF l_action_flag = 'R' THEN
       FND_MESSAGE.SET_NAME('FND', 'FND_GENERIC_MESSAGE');
       FND_MESSAGE.SET_TOKEN('MASSAGE' ,'Exception OTHER in UPGRADE_MC_OCCURRENCES '||SQLERRM);
       FND_MSG_PUB.ADD;
       x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    ELSE
      RAISE;
    END IF;
    IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL ) THEN
    	FND_LOG.STRING(G_LEVEL_STATEMENT, 'JL.plsql.JL_BR_AR_BANK_ACCT_PKG.UPGRADE_MC_OCCURRENCES','End UPGRADE_MC_OCCURRENCES ');
    END IF;
END UPGRADE_MC_OCCURRENCES;

END JL_BR_AR_BANK_ACCT_PKG;

/
