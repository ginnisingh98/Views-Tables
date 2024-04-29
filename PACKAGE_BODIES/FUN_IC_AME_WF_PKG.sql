--------------------------------------------------------
--  DDL for Package Body FUN_IC_AME_WF_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."FUN_IC_AME_WF_PKG" AS
/* $Header: funicameab.pls 120.0 2004/10/13 12:58:17 bsilveir noship $ */


/* ---------------------------------------------------------------------------
Name      : get_attribute_value
Pre-reqs  : None.
Modifies  : None.
function  : This function returns the values for the intercompany  transaction
            attributes that are used within AME. These values are used when
            evaluating AME rules and conditions
Parameters:
    IN    : p_transaction_id - fun_trx_headers.trx_id
            p_dist_id        - fun_trx_dist_lines.dist_id
            p_attribute_name - Name of the attribute whose value is required.
    OUT   : Value of the attribute.
Notes     : None.
Testing   : This function can be tested using the 'Test' tab provided within AME
            setup pages
------------------------------------------------------------------------------*/
FUNCTION get_attribute_value
         (p_transaction_id      IN NUMBER,
          p_dist_id             IN NUMBER DEFAULT NULL,
          p_attribute_name      IN VARCHAR2)
RETURN VARCHAR2 IS

l_return_value	VARCHAR2(2000):= NULL;

BEGIN

   IF p_attribute_name   = 'BATCH_INITIATOR_NAME'
   THEN
       SELECT DISTINCT hz.party_name
       INTO   l_return_value
       FROM   hz_parties hz,
              fun_trx_batches btch,
              fun_trx_headers head
       WHERE  hz.party_id         = btch.initiator_id
       AND    btch.batch_id       = head.batch_id
       AND    head.trx_id         = p_transaction_id;

   ELSIF p_attribute_name = 'BATCH_FROM_LE_NAME'
   THEN
       SELECT DISTINCT xla.name
       INTO   l_return_value
       FROM   xle_firstparty_information_v xla,
              fun_trx_batches btch,
              fun_trx_headers head
       WHERE  xla.legal_entity_id = btch.from_le_id
       AND    btch.batch_id       = head.batch_id
       AND    head.trx_id         = p_transaction_id;

   ELSIF p_attribute_name = 'BATCH_FROM_LEDGER_NAME'
   THEN
       SELECT DISTINCT gl.name
       INTO   l_return_value
       FROM   gl_ledgers gl,
              fun_trx_batches btch,
              fun_trx_headers head
       WHERE  gl.ledger_id        = btch.from_ledger_id
       AND    btch.batch_id       = head.batch_id
       AND    head.trx_id         = p_transaction_id;

   ELSIF p_attribute_name = 'BATCH_TYPE_NAME'
   THEN
       SELECT DISTINCT tt.trx_type_name
       INTO   l_return_value
       FROM   fun_trx_types_tl tt,
              fun_trx_batches btch,
              fun_trx_headers head
       WHERE  tt.trx_type_id      = btch.trx_type_id
       AND    btch.batch_id       = head.batch_id
       AND    head.trx_id         = p_transaction_id;

   ELSIF p_attribute_name = 'HEADER_INITIATOR_NAME'
   THEN
       SELECT DISTINCT hz.party_name
       INTO   l_return_value
       FROM   hz_parties hz,
              fun_trx_headers head
       WHERE  hz.party_id         = head.initiator_id
       AND    head.trx_id         = p_transaction_id;

   ELSIF p_attribute_name = 'HEADER_RECIPIENT_NAME'
   THEN
       SELECT DISTINCT hz.party_name
       INTO   l_return_value
       FROM   hz_parties hz,
              fun_trx_headers head
       WHERE  hz.party_id         = head.recipient_id
       AND    head.trx_id         = p_transaction_id;

   ELSIF p_attribute_name = 'HEADER_TO_LE_NAME'
   THEN
       SELECT DISTINCT xla.name
       INTO   l_return_value
       FROM   xle_firstparty_information_v xla,
              fun_trx_headers head
       WHERE  xla.legal_entity_id = head.to_le_id
       AND    head.trx_id         = p_transaction_id;

   ELSIF p_attribute_name = 'HEADER_TO_LEDGER_NAME'
   THEN
       SELECT DISTINCT gl.name
       INTO   l_return_value
       FROM   gl_ledgers gl,
              fun_trx_headers head
       WHERE  gl.ledger_id        = head.to_ledger_id
       AND    head.trx_id         = p_transaction_id;

   ELSIF p_attribute_name = 'DIST_PARTY_NAME'
   THEN
       SELECT DISTINCT hz.party_name
       INTO   l_return_value
       FROM   hz_parties hz,
              fun_dist_lines dist
       WHERE  hz.party_id         = dist.party_id
       AND    dist.dist_id        = p_dist_id;

   END IF;

   RETURN l_return_value;

EXCEPTION
   -- Since these functions will be called from AME, just log the exception
   -- and return NULL.

   WHEN NO_DATA_FOUND
   THEN
       IF ( FND_LOG.LEVEL_UNEXPECTED >= FND_LOG.G_CURRENT_RUNTIME_LEVEL)
       THEN
           fnd_log.string(FND_LOG.LEVEL_UNEXPECTED,
                          'fun.plsql.fun_ic_ame_wf_pkg.get_attribute_values',
                          'No data found error occurred when getting '||
                          'attribute value '||p_attribute_name||
                          ' for transaction '||p_transaction_id);
       END IF;

       RETURN NULL;

   WHEN OTHERS
   THEN
       IF ( FND_LOG.LEVEL_UNEXPECTED >= FND_LOG.G_CURRENT_RUNTIME_LEVEL)
       THEN
           fnd_log.string(FND_LOG.LEVEL_UNEXPECTED,
                          'fun.plsql.fun_ic_ame_wf_pkg.get_attribute_values',
                          SQLERRM || ' Error occurred when getting '||
                          'attribute value '||p_attribute_name||
                          ' for transaction '||p_transaction_id);
       END IF;
       RETURN NULL;
END get_attribute_value;

/* ---------------------------------------------------------------------------
Name      : get_fun_dist_acct_flex
Pre-reqs  : None.
Modifies  : None.
Function  : This function will be called from within AME to get the value of
            the accounting flexfields qualifying segments enabling users to
            build rules based on them.
Parameters:
    IN    : p_seg_name       - Name of the Segment
                  Eg. GL_ACCOUNT, GL_BALANCING, FA_COST_CTR
            p_ccid           - Code Combination Id
            p_dist_id        - fun_trx_dist_lines.dist_id
            p_transaction_id - fun_trx_headers.trx_id
    OUT   : Value of the attribute.
Notes     : None.
Testing   : This function can be tested using the 'Test' tab provided within AME
            setup pages
------------------------------------------------------------------------------*/
FUNCTION get_fun_dist_acct_flex(p_seg_name IN VARCHAR2,
               P_ccid     IN NUMBER,
               p_dist_id  IN NUMBER,
               p_transaction_id IN NUMBER)
RETURN VARCHAR2
IS

l_segments                      FND_FLEX_EXT.SEGMENTARRAY;
l_result                        BOOLEAN;
l_chart_of_accounts_id          NUMBER;
l_num_segments                  NUMBER;
l_segment_num                   NUMBER;
l_seg_val                       VARCHAR2(50);

BEGIN
   SELECT chart_of_accounts_id
   INTO  l_chart_of_accounts_id
   FROM  gl_ledgers gl,
         fun_trx_headers head
   WHERE gl.ledger_id = head.to_ledger_id
   AND   head.trx_id  = p_transaction_id;

   l_result := fnd_flex_ext.get_segments(
                            'SQLGL',
                            'GL#',
                            l_chart_of_accounts_id,
                            p_ccid,
                            l_num_segments,
                            l_segments);

   l_result := fnd_flex_apis.get_qualifier_segnum(
                            101,
                            'GL#',
                            l_chart_of_accounts_id,
                            p_seg_name,
                            l_segment_num);

   l_seg_val := l_segments(l_segment_num);

   RETURN l_seg_val;

EXCEPTION
   -- Since these functions will be called from AME, just log the exception
   -- and return NULL.
   WHEN OTHERS
   THEN
       IF ( FND_LOG.LEVEL_UNEXPECTED >= FND_LOG.G_CURRENT_RUNTIME_LEVEL)
       THEN
           fnd_log.string(FND_LOG.LEVEL_UNEXPECTED,
                          'fun.plsql.fun_ic_ame_wf_pkg.get_fun_dist_acct_flex',
                          SQLERRM || ' Error occurred when getting '||
                          'segment value '||p_seg_name ||
                          ' for transaction ' || p_transaction_id);
       END IF;
       RETURN NULL;
END  get_fun_dist_acct_flex;

END fun_ic_ame_wf_pkg;


/
