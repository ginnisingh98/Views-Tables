--------------------------------------------------------
--  DDL for Package Body QA_SEQUENCE_API
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."QA_SEQUENCE_API" AS
/* $Header: qltseqb.pls 120.12.12010000.2 2008/11/12 13:21:17 rvalsan ship $ */

 -- Bug 5368983. Intoroducing debug logging in this API
 g_module_name CONSTANT VARCHAR2(60):= 'qa.plsql.qa_sequence_api';

 g_curr_plan_id             NUMBER;
 g_curr_parent_plan_id      NUMBER;

 --
 -- bug 5228667
 -- New Variable to detect if the ERES Txn
 -- has been resubmitted
 -- ntungare Thu Aug 17 03:26:40 PDT 2006
 --
 g_eres_resubmit_flg        BOOLEAN := FALSE;

 --
 -- bug 5955808
 -- New variable to indicate a Mobile Transaction
 -- ntungare Mon Jul 23 11:31:09 PDT 2007
 --
 g_mobile      BOOLEAN := FALSE;

 g_curr_plan_seq_char_ids   ID_TABLE;
 g_parent_plan_seq_char_ids ID_TABLE;
 g_parent_plan_seq_nos      ID_TABLE;

 --Bug 5114865
 -- Global array to hold the Seq Type elements
 -- ntungare Sun Apr  9 23:40:46 PDT 2006
 g_true_seq_gen_recids      ID_TABLE;

 ParentChild_Tab QA_PARENT_CHILD_PKG.ParentChildTabTyp;

 -- Bug 3160651. Code change start. rponnusa Thu Sep 25 02:24:28 PDT 2003

 Type MessageRecord IS RECORD (
      plan_name      VARCHAR2(40),
      element_prompt VARCHAR2(40),
      sequence_value VARCHAR2(40));

 TYPE MessageArray  IS TABLE OF MessageRecord INDEX BY BINARY_INTEGER;
 TYPE PROMPT_TABLE  IS TABLE OF VARCHAR2(40)  INDEX BY BINARY_INTEGER;

 g_message_array MessageArray;
 g_prompt_tab    PROMPT_TABLE;

 PROCEDURE get_all_char_prompt_info(p_plan_id NUMBER);

 PROCEDURE populate_message_array(p_char_id   NUMBER,
                                  p_seq_value VARCHAR2,
                                  p_plan_name VARCHAR2);

 -- Bug 3160651. Code change end. rponnusa Thu Sep 25 02:24:28 PDT 2003


 FUNCTION get_all_record_info(p_collection_id NUMBER,
                              p_txn_header_id NUMBER)  RETURN NUMBER;

 -- Bug 5335509. SHKALYAN 15-Jun-2006
 -- commenting this declaration out since this function
 -- needs to be called from external programs so, moved to specs.
/*
 FUNCTION get_sequence_default_value RETURN VARCHAR2;
*/

 FUNCTION get_eres_profile RETURN BOOLEAN;

 --
 -- bug 5228667
 -- Added the parameters plan id and occurrence as
 -- they would help in uniquely identifying a record
 -- in the qa_seq_audit_history table. This is important
 -- in case of a SR Txn wherein an EQR can be done while
 -- updating an SR wherein the same Collection id is reused
 -- This will ensure that the resubmission is not confused
 -- with any audit recs already existing for a collection id
 -- ntungare Thu Aug 17 03:31:39 PDT 2006
 --
 FUNCTION eres_resubmit(p_txn_header_id NUMBER,
                        p_collection_id NUMBER,
                        p_plan_id       NUMBER DEFAULT NULL,
                        p_occurrence    NUMBER DEFAULT NULL) RETURN BOOLEAN;

 PROCEDURE find_update_seq_in_collection(p_cur_record_indicator     NUMBER,
                                         p_seq_position             NUMBER,
                                         p_action                   NUMBER,
                                         p_seq_value  IN OUT NOCOPY VARCHAR2);

 -- Bug 3128040 rponnusa Thu Sep  4 05:52:20 PDT 2003
 -- new procedure added

 -- Bug 5368983
 -- Added a new flag. Provided a default value so it
 -- doesnt not impact existing calls
 -- saugupta Wed, 30 Aug 2006 06:03:10 -0700 PDT
 PROCEDURE gen_seq_for_currec_commit(p_plan_id               NUMBER,
                                     p_collection_id         NUMBER,
                                     p_occurrence            NUMBER,
                                     p_parent_plan_id        NUMBER,
                                     p_parent_collection_id  NUMBER,
                                     p_parent_occurrence     NUMBER,
                                     p_oa_txnint BOOLEAN DEFAULT NULL);

 -- Bug 5368983
 -- Added a new flag. Provided a default value so it
 -- doesnt not impact existing calls
 -- saugupta Wed, 30 Aug 2006 05:18:01 -0700 PDT
 PROCEDURE generate_seq_for_currec(p_plan_id               NUMBER,
                                   p_collection_id         NUMBER,
                                   p_occurrence            NUMBER,
                                   p_parent_plan_id        NUMBER,
                                   p_parent_collection_id  NUMBER,
                                   p_parent_occurrence     NUMBER,
                                   p_oa_txnint BOOLEAN DEFAULT NULL);


 PROCEDURE get_seq_value_for_pc_comb(p_plan_id               NUMBER,
                                     p_collection_id         NUMBER,
                                     p_occurrence            NUMBER,
                                     p_cur_rec_indicator     NUMBER,
                                     p_parent_plan_id        NUMBER,
                                     p_parent_collection_id  NUMBER,
                                     p_parent_occurrence     NUMBER,
                                     p_parent_rec_indicator  NUMBER);

 -- Bug 3128040 rponnusa Thu Sep  4 05:52:20 PDT 2003
 -- Renamed procedure generate_seq_for_pc_nocommit to
 -- generate_seq_for_pc

 -- Bug 5368983
 -- Added a new flag. Provided a default value so it
 -- doesnt not impact existing calls
 -- saugupta Wed, 30 Aug 2006 05:18:01 -0700 PDT

 PROCEDURE generate_seq_for_pc(p_plan_id       NUMBER,
                               p_collection_id NUMBER,
                               p_txn_header_id NUMBER,
                               p_oa_txnint BOOLEAN DEFAULT NULL);

 PROCEDURE get_plan_seq_ele_setup(p_plan_id        NUMBER,
                                  p_parent_plan_id NUMBER);

 PROCEDURE update_record(p_total_rec_count NUMBER);

 PROCEDURE get_all_rec_info_for_audit(p_plan_ids       DBMS_SQL.number_table,
                                      p_collection_ids DBMS_SQL.number_table,
                                      p_occurrences    DBMS_SQL.number_table);

 PROCEDURE audit_sequence_for_allchild(p_plan_id       NUMBER,
                                       p_collection_id NUMBER,
                                       p_occurrence    NUMBER);

 PROCEDURE audit_sequence_for_currec(p_plan_id               NUMBER,
                                     p_collection_id         NUMBER,
                                     p_occurrence            NUMBER,
                                     p_parent_plan_id        NUMBER,
                                     p_parent_collection_id  NUMBER,
                                     p_parent_occurrence     NUMBER);

 PROCEDURE audit_seq_for_eres(p_char_id           NUMBER,
                              p_seq_value         VARCHAR2,
                              p_cur_rec_indicator NUMBER);

 -- Bug 5368983
 -- Added a new method for sequence auditing for OA Txn Integ
 -- saugupta Wed, 30 Aug 2006 05:22:51 -0700 PDT
 --
 -- Bug 5955808
 -- Added a new parameter to take in the Module name
 -- to be set at the time of auditing the sequences
 -- ntungare Thu Jul 26 02:55:50 PDT 2007
 --
 PROCEDURE audit_seq_for_txnint(p_char_id           NUMBER,
                                p_seq_value         VARCHAR2,
                                p_cur_rec_indicator NUMBER,
                                p_module VARCHAR2 DEFAULT 'OATXNINT');
-- Get_Nextval function derives the next sequence number and updates
-- qa_chars with the next sequence number and commits it.
-- kabalakr


FUNCTION GET_NEXTVAL(p_char_id NUMBER) RETURN NUMBER IS

 PRAGMA AUTONOMOUS_TRANSACTION;

 -- l_seq_incr     NUMBER := 0;
    l_curr_val     NUMBER := 0;
 -- l_next_val     NUMBER := 0;

 --
 -- Bug 5118745.  Locking issue as reported by customer P1 5060289.
 -- In order to keep sequence generation as efficient as possible
 -- this procedure is reduced from 2 SQLs with a FOR UPDATE lock
 -- to one atomic SQL of equivalent semantics.  Locking is no longer
 -- required because we reduced 2 SQLs with 1 preventing database
 -- activities from happening in between.
 -- bso Tue Mar 28 12:35:36 PST 2006
 --
 -- CURSOR c IS SELECT sequence_nextval, sequence_increment
 --            FROM   qa_chars
 --            WHERE  char_id = p_char_id FOR UPDATE;
 --

BEGIN

 -- select the next sequnce from qa_chars.
 --
 -- OPEN c;
 -- FETCH c INTO l_curr_val, l_seq_incr;
 -- IF (c%NOTFOUND) THEN
 --   NULL;
 -- END IF;
 -- CLOSE c;
 --
 -- increment the sequence.
 -- l_next_val := l_curr_val+l_seq_incr;
 --
 -- update qa_chars with new sequence value.
 -- UPDATE qa_chars
 -- SET sequence_nextval = l_next_val
 -- WHERE char_id = p_char_id;

     -- Basically, we increase the sequence_nextval column
     -- by sequence_increment and return the sum in one shot.
     -- bso
     --
     -- Bug 5233797.  The previous RETURNING clause was
     -- RETURNING sequence_nextval + sequence_increment
     -- This is incorrect as sequence_nextval would have
     -- taken the new incremented value.  The semantics
     -- of this procedure is to return the old value before
     -- increment.  So change + to -
     -- bso Thu May 18 13:36:06 PDT 2006
     --

     UPDATE    qa_chars
     SET       sequence_nextval = sequence_nextval + sequence_increment
     WHERE     char_id = p_char_id
     RETURNING sequence_nextval - sequence_increment
     INTO      l_curr_val;

 COMMIT;

 RETURN l_curr_val;

END GET_NEXTVAL;



-- Get_Next_Seq function gets the next Sequence Number using
-- get_nextval function and prototypes the Sequence String into the
-- format that user views. It also takes care of the zero padding
-- logic.
-- kabalakr

FUNCTION GET_NEXT_SEQ(p_char_id NUMBER, p_commit BOOLEAN) RETURN VARCHAR2 IS

 l_next_seq     VARCHAR2(100);

 l_seq_pref     VARCHAR2(100);
 l_seq_suf      VARCHAR2(100);
 l_seq_sep      VARCHAR2(1);
 l_seq_len      NUMBER := 0;
 l_zero_pad     NUMBER := 0;

 l_next_val     VARCHAR2(100);
 l_zero         VARCHAR2(100);
 l_len          NUMBER := 0;

 i              NUMBER;

 CURSOR c IS  SELECT sequence_prefix, sequence_suffix, sequence_separator,
                     sequence_length, sequence_zero_pad
              FROM   qa_chars
              WHERE  char_id = p_char_id;
BEGIN

  -- Gapless Sequence Proj Start.
  -- rponnusa Wed Jul 30 04:52:45 PDT 2003

  -- get the next sequence.
  IF NVL(p_commit,TRUE) = FALSE THEN
    l_next_val := to_char(get_nextval_nocommit(p_char_id));
  ELSE
    l_next_val := to_char(GET_NEXTVAL(p_char_id));
  END IF;

  -- Gapless Sequence Proj End

 -- Get all the sequence data.
 OPEN c;
 FETCH c INTO l_seq_pref, l_seq_suf, l_seq_sep, l_seq_len, l_zero_pad;

 /*
 --  Gapless Sequence Proj
 -- comment out this code as it does not needed.

 IF (c%NOTFOUND) THEN
    NULL;
 END IF;
*/

 CLOSE c;

  -- If zero_pad the sequence if the flag is set.
  IF (l_zero_pad = 1) THEN
    l_len := LENGTH(l_next_val);
    l_len := l_seq_len - l_len ;

    FOR i in 1..l_len LOOP
    l_zero := l_zero || '0' ;
    END LOOP;

    l_next_val := l_zero || l_next_val ;

  END IF;

  -- Make the sequence here.
  l_next_seq := l_seq_pref || l_seq_sep || l_next_val || l_seq_sep || l_seq_suf ;
  RETURN l_next_seq;

END GET_NEXT_SEQ;

-- Max_Sequence is the Server Side constant. Its the maximum
-- number of sequences that can be defined.
-- kabalakr

FUNCTION MAX_SEQUENCE RETURN NUMBER IS

 l_max_seq_num  NUMBER := 15;

BEGIN

  RETURN l_max_seq_num;

END MAX_SEQUENCE;

-- Bug 2548710. Added following procedure
-- rponnusa Mon Nov 18 03:49:15 PST 2002

PROCEDURE FILL_SEQ_TABLE (p_char_id IN NUMBER,
                          p_count   IN NUMBER,
                          x_seq_table  OUT NOCOPY  QLTTRAWB.CHAR50_TABLE ) IS

-- This procedure is called from qlttrawb.plb
-- For sequence datatype, we need to generate distinct sequence value for each record.
-- First generate p_count distinct seq values, bundle it in seq table
-- and send it back to calling procedure.
-- p_count is the no. of records processed by the worker.
--

BEGIN
  -- we need to initialize the collection before actually use it.
  x_seq_table :=  QLTTRAWB.CHAR50_TABLE ();

  -- create the number of elements required for the collection.
  x_seq_table.EXTEND(p_count);

  FOR I IN 1..p_count LOOP
      x_seq_table(I) := QA_SEQUENCE_API.GET_NEXT_SEQ(p_char_id);
  END LOOP;

END FILL_SEQ_TABLE;

 -- Gapless Sequence Proj Start.
 -- rponnusa Wed Jul 30 04:52:45 PDT 200

 FUNCTION get_nextval_nocommit(p_char_id NUMBER) RETURN NUMBER IS

 -- This is function is same as fn GET_NEXTVAL except that
 -- autonomous txn is not used here.

     l_curr_val NUMBER := 0;

 BEGIN

     --
     -- Many cleanup done.  See comments in get_nextval.
     -- bso Tue Mar 28 13:26:01 PST 2006
     --
     -- Bug 5233797.  The previous RETURNING clause was
     -- RETURNING sequence_nextval + sequence_increment
     -- This is incorrect as sequence_nextval would have
     -- taken the new incremented value.  The semantics
     -- of this procedure is to return the old value before
     -- increment.  So change + to -
     -- bso Thu May 18 13:36:06 PDT 2006
     --

     UPDATE    qa_chars
     SET       sequence_nextval = sequence_nextval + sequence_increment
     WHERE     char_id = p_char_id
     RETURNING sequence_nextval - sequence_increment
     INTO      l_curr_val;

     RETURN l_curr_val;
 END get_nextval_nocommit;

 PROCEDURE generate_seq_for_Txn(p_collection_id             NUMBER,
                                p_return_status  OUT NOCOPY VARCHAR2) IS

  -- In eRecords scanario following things are done.

  -- 1. Sequence will always be generated before the parent txn commited
  --    in post-forms-commit for the FORM
  -- 2. While generating sequence, audit information captured with
  --    source code = 'EDR' and audit_type = 'CREATED' in qa_seq_audit_history table.
  -- 3. When user Rejects the entry , update qa_seq_audit_history table
  --    for audit_type = 'REJECTED' , source_id with eRes ID.
  -- 4. When user Accepts the txn, delete audit information from
  --    qa_seq_audit_history table
  -- 5. In case erecords are resubmitted, checking is done qa_seq_audit_history
  --    for the collection_id,occurrence. If record found, dont call sequence api.
  -- 6. QA_RESULT_GRP.enable is called when parent txn commited(after eRes).
  --    Api checks for eRes txn. If eRes then seq. api will not be called since
  --    seq. values generated already.


  -- this cursor finds out number of top level plans for which
  -- results been entered.

  CURSOR all_plan_cur IS
     SELECT distinct qr.plan_id
     FROM   qa_results qr
     WHERE  qr.collection_id = p_collection_id AND
     NOT EXISTS (SELECT 1 FROM qa_pc_results_relationship qprr
                 WHERE qprr.child_plan_id       = qr.plan_id AND
                       qprr.child_collection_id = qr.collection_id AND
                       qprr.child_occurrence    = qr.occurrence);

  -- use this cursor to make other user wait to get the lock on
  -- known char_id =1. This is to avoid concurrency problem. For
  -- Ex. user1, user2 simultanously trying to generate seq value.
  -- assume user1 got the lock on this table and process it. During
  -- this time, user2 will wait to acquire the lock (without that
  -- he cannt proceed). Once user1 completes the task and lock
  -- is released which can be obtained by user2.

  l_char_id         NUMBER;
  l_row_count       NUMBER;

  --
  -- Bug 5118745.  Locking issue as reported by customer P1 5060289.
  -- This cursor is not required.  It is conservatively used to give
  -- a nice-to-have feature for sequential numbering per collection
  -- during concurrent EQR.
  -- bso Tue Mar 28 12:19:04 PST 2006
  --
  -- CURSOR c IS
  --   SELECT char_id
  --   FROM qa_chars WHERE char_id = 1
  --   FOR UPDATE;

 BEGIN
   -- Bug 5118745.  Locking issue as reported by customer P1 5060289.
   -- IF NOT get_eres_profile() THEN
   -- -- unless user gets the lock on this table he can't get past this cursor.
   -- -- lock the row only in non eres case.
   --   OPEN c;
   --   FETCH c INTO l_char_id;
   --   CLOSE c;
   -- END IF;

   --  Initialize return status to success
   p_return_status := FND_API.G_RET_STS_SUCCESS;

   --
   -- Bug 5228667
   -- Commented out this check because although
   -- in case when an ERES is resubmitted the sequence
   -- is not to be regenerated, yet the sequence array
   -- needs to be populated with the values from the
   -- Audit Hist table where the generated seq would reside
   -- and this should be used while updating qa_results
   -- Without this, in case of a resubmission, the sequence
   -- value won't be copied to QA_RESULTS. This processing
   -- has been moved to the proc generate_seq_for_pc
   -- ntungare Thu Aug 17 03:40:02 PDT 2006
   --
   /*
   IF get_eres_profile() AND eres_resubmit(null,p_collection_id) THEN

      -- eRes is enabled and same records are resubmitted.
      -- dont do any processing.
      RETURN;
   END IF;
   */

   -- initialize fnd message table, this is used by self-service api
   fnd_msg_pub.initialize;

   -- Pack all the sequence values in the data collection into plsql table
   l_row_count := get_all_record_info(p_collection_id,null);

   IF l_row_count = 0 THEN
      RETURN;
   END IF;

   FOR plan_rec IN all_plan_cur LOOP

     -- Generate seq value or copy seq value from parent to child rec.
     -- this should be done for all the parent rec and its all child,
     -- grandchild.. records

     -- Bug 3128040 rponnusa Thu Sep  4 05:52:20 PDT 2003
     -- IF condition
     generate_seq_for_pc(plan_rec.plan_id,
                         p_collection_id,
                         null);

   END LOOP;

   -- Now use bulk update to update all seq. values into qa_results for all the
   -- records in the data collection

   update_record(l_row_count);

 EXCEPTION
   WHEN OTHERS THEN
     p_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
     fnd_message.set_name('QA', 'QA_SEQ_GENERATION_ERROR');
     fnd_msg_pub.add();

 END generate_seq_for_txn;


 PROCEDURE generate_seq_for_DDE(p_txn_header_id             NUMBER,
                                p_plan_id                   NUMBER,
                                p_return_status  OUT NOCOPY VARCHAR2) IS

  -- In direct data entry mode (eqr/uqr) txn_header_id is unique between saves.
  -- The generation of seq. should happen for each save. Collection ID
  -- cannot be used in this case, since it is same between saves.
  -- This procedure is the entry point for seq. api called from FORM

  -- use this cursor to make other user wait to get the lock on
  -- known row char_id =1. This is to avoid concurrency problem. For
  -- Ex. user1, user2 simultanously trying to generate seq value.
  -- assume user1 got the lock on this table and process it. During
  -- this time, user2 will wait to acquire the lock (without that
  -- he cannt proceed). Once user1 completes the task and lock
  -- is released which can be obtained by user2.

  l_char_id      NUMBER;
  l_row_count    NUMBER;

  --
  -- Bug 5118745.  Locking issue as reported by customer P1 5060289.
  -- This cursor is not required.  It is conservatively used to give
  -- a nice-to-have feature for sequential numbering per collection
  -- during concurrent EQR.
  -- bso Tue Mar 28 12:19:04 PST 2006
  --
  -- CURSOR c IS
  --    SELECT char_id
  --    FROM qa_chars WHERE char_id = 1
  --    FOR UPDATE;

 BEGIN
   -- Bug 5118745.  Locking issue as reported by customer P1 5060289.
   -- IF NOT get_eres_profile() THEN
   -- -- unless user gets the lock on this table he can't get past this cursor.
   -- -- lock the row only in non eres case.
   --   OPEN c;
   --   FETCH c INTO l_char_id;
   --   CLOSE c;
   -- END IF;

   --  Initialize return status to success
   p_return_status := FND_API.G_RET_STS_SUCCESS;

   IF get_eres_profile() AND eres_resubmit(p_txn_header_id,null) THEN

      -- eRes is enabled and same records are resubmitted.
      -- dont do any processing.
      RETURN;
   END IF;

   -- Pack all the sequence values in the data collection into plsql table
   l_row_count := get_all_record_info(null, p_txn_header_id);

   IF l_row_count = 0 THEN
      RETURN;
   END IF;

   -- Generate seq value or copy seq value from parent to child rec.
   -- this should be done for all the parent rec and its all child,
   -- grandchild.. records

   -- Bug 3128040 rponnusa Thu Sep  4 05:52:20 PDT 2003
   -- IF condition
   generate_seq_for_pc(p_plan_id,
                       null,
                       p_txn_header_id);

   -- Now use bulk update to update all seq. values into qa_results for all the
   -- records in the data collection

   update_record(l_row_count);

 EXCEPTION
   WHEN OTHERS THEN
     -- Bug 3160651. If any error happens, should return error

     p_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

 END generate_seq_for_DDE;

 FUNCTION get_all_record_info(p_collection_id NUMBER,
                               p_txn_header_id NUMBER)  RETURN NUMBER IS

   -- Pack all the parent,child,grand child record into the plsql table
   -- for the given coll id or txn header id.

   CURSOR coll_cur IS
     SELECT occurrence,collection_id,plan_id,txn_header_id,
            sequence1,sequence2,sequence3,
            sequence4,sequence5,sequence6,
            sequence7,sequence8,sequence9,
            sequence10,sequence11,sequence12,
            sequence13,sequence14,sequence15
     FROM   qa_results
     WHERE  collection_id = p_collection_id;

  CURSOR txn_cur IS
    SELECT occurrence,collection_id,plan_id,txn_header_id,
           sequence1,sequence2,sequence3,
           sequence4,sequence5,sequence6,
           sequence7,sequence8,sequence9,
           sequence10,sequence11,sequence12,
           sequence13,sequence14,sequence15
    FROM   qa_results
    WHERE  txn_header_id = p_txn_header_id;

  l_row_count NUMBER := 0;

 BEGIN
   IF p_collection_id IS NOT NULL THEN

      OPEN coll_cur;

      -- bulk fetch all the records into corresponding plsql tables
      -- this is called from transaction mode

      FETCH coll_cur BULK COLLECT INTO
            QLTTRAWB.g_occurrence_tab, QLTTRAWB.g_collection_id_tab,
            QLTTRAWB.g_plan_id_tab,    QLTTRAWB.g_txn_header_id_tab,
            QLTTRAWB.g_seq_tab1, QLTTRAWB.g_seq_tab2,  QLTTRAWB.g_seq_tab3,
            QLTTRAWB.g_seq_tab4, QLTTRAWB.g_seq_tab5,  QLTTRAWB.g_seq_tab6,
            QLTTRAWB.g_seq_tab7, QLTTRAWB.g_seq_tab8,  QLTTRAWB.g_seq_tab9,
            QLTTRAWB.g_seq_tab10,QLTTRAWB.g_seq_tab11, QLTTRAWB.g_seq_tab12,
            QLTTRAWB.g_seq_tab13,QLTTRAWB.g_seq_tab14, QLTTRAWB.g_seq_tab15;

      l_row_count := coll_cur%ROWCOUNT;
      CLOSE coll_cur;

   ELSIF p_txn_header_id IS NOT NULL THEN
      OPEN txn_cur;
      -- bulk fetch all the records into corresponding plsql tables
      -- this is called from direct data entry mode

      FETCH txn_cur BULK COLLECT INTO
            QLTTRAWB.g_occurrence_tab, QLTTRAWB.g_collection_id_tab,
            QLTTRAWB.g_plan_id_tab,    QLTTRAWB.g_txn_header_id_tab,
            QLTTRAWB.g_seq_tab1, QLTTRAWB.g_seq_tab2,  QLTTRAWB.g_seq_tab3,
            QLTTRAWB.g_seq_tab4, QLTTRAWB.g_seq_tab5,  QLTTRAWB.g_seq_tab6,
            QLTTRAWB.g_seq_tab7, QLTTRAWB.g_seq_tab8,  QLTTRAWB.g_seq_tab9,
            QLTTRAWB.g_seq_tab10,QLTTRAWB.g_seq_tab11, QLTTRAWB.g_seq_tab12,
            QLTTRAWB.g_seq_tab13,QLTTRAWB.g_seq_tab14, QLTTRAWB.g_seq_tab15;

      l_row_count := txn_cur%ROWCOUNT;
      CLOSE txn_cur;

   END IF;

   RETURN l_row_count;

 END get_all_record_info;

 -- Bug 5368983
 -- Added a new flag. Provided a default value so it
 -- does not impact existing calls
 -- saugupta Wed, 30 Aug 2006 05:18:01 -0700 PDT
 PROCEDURE generate_seq_for_pc(p_plan_id       NUMBER,
                               p_collection_id NUMBER,
                               p_txn_header_id NUMBER,
                               p_oa_txnint BOOLEAN DEFAULT NULL) IS

   -- Generate sequence for the parent record and all its child,grand children
   -- records.
   --
   -- bug 7552689
   -- Sequences are randomly generated if there are multiple records
   -- entered in the child plan. Hence, added child_occurrence as well
   -- to ensure proper ordering.

   CURSOR txn_cur IS
          SELECT 0             child_plan_id,
                 0             child_collection_id,
                 0             child_occurrence,
                 plan_id       parent_plan_id,
                 collection_id parent_collection_id,
                 occurrence    parent_occurrence,
                 0             levels
          FROM   qa_results qr
          WHERE  qr.plan_id       = p_plan_id AND
                 qr.collection_id = p_collection_id
          UNION ALL
          SELECT child_plan_id,
                 child_collection_id,
                 child_occurrence,
                 parent_plan_id,
                 parent_collection_id,
                 parent_occurrence,
                 level levels
          FROM   qa_pc_results_relationship r
          START WITH  r.parent_plan_id        = p_plan_id AND
                      r.parent_collection_id  = p_collection_id
          CONNECT BY PRIOR r.child_occurrence = r.parent_occurrence
          ORDER BY levels, parent_occurrence, child_occurrence;
          --
          -- Bug 5118745.  Locking issue as reported by customer P1 5060289.
          -- For better user experience, augmented order by with occurrence
          -- so that user does not see random ordering of sequences when
          -- entering multiple records in one collection.  No change to
          -- performance as the number of new records per collection is
          -- limited.
          -- bso Tue Mar 28 12:59:39 PST 2006
          --

   -- Bug 3283794. Modified dde_cur to select from
   -- qa_pc_results_relationship_v. rponnusa Thu Dec 18 21:28:55 PST 2003

/*   CURSOR dde_cur IS
          SELECT 0             child_plan_id,
                 0             child_collection_id,
                 0             child_occurrence,
                 plan_id       parent_plan_id,
                 collection_id parent_collection_id,
                 occurrence    parent_occurrence,
                 0 levels
          FROM   qa_results qr
          WHERE  qr.plan_id       = p_plan_id AND
                 qr.txn_header_id = p_txn_header_id
          UNION ALL
          SELECT child_plan_id,
                 child_collection_id,
                 child_occurrence,
                 parent_plan_id,
                 parent_collection_id,
                 parent_occurrence,
                 level levels
          FROM   qa_pc_results_relationship_v r
	  WHERE  r.child_txn_header_id        = p_txn_header_id
          START WITH  r.parent_plan_id        = p_plan_id
          CONNECT BY PRIOR r.child_occurrence = r.parent_occurrence
          ORDER BY levels; */

   -- Bug 3578477. Above commented CURSOR is not compatible with Oracle 8i
   -- To make it compatible removed the call to view qa_pc_results_relationship_v
   -- and replaced it with qa_pc_results_relationship table and changed the
   -- where condition of second select query.
   -- saugupta Tue, 20 Apr 2004 04:09:30 -0700 PDT

   --
   -- bug 7552689
   -- Sequences are randomly generated if there are multiple records
   -- entered in the child plan. Hence, added child_occurrence as well
   -- to ensure proper ordering.
   --
   CURSOR dde_cur IS
          -- bug 6450787
          -- Commenting the following cursor due to
          -- performance reasons.
          -- bhsankar Thu Oct  4 04:19:54 PDT 2007
          /* SELECT 0             child_plan_id,
                 0             child_collection_id,
                 0             child_occurrence,
                 plan_id       parent_plan_id,
                 collection_id parent_collection_id,
                 occurrence    parent_occurrence,
                 0 levels
          FROM   qa_results qr
          WHERE  qr.plan_id       = p_plan_id AND
                 qr.txn_header_id = p_txn_header_id
          UNION ALL
          SELECT child_plan_id,
                 child_collection_id,
                 child_occurrence,
                 parent_plan_id,
                 parent_collection_id,
                 parent_occurrence,
                 level levels
          FROM   qa_pc_results_relationship r
          WHERE p_txn_header_id =
              (SELECT qr.txn_header_id
               FROM qa_results qr
               WHERE  qr.plan_id = r.child_plan_id and
                      qr.collection_id = r.child_collection_id and
                      qr.occurrence = r.child_occurrence)
          START WITH  r.parent_plan_id        = p_plan_id
          CONNECT BY PRIOR r.child_occurrence = r.parent_occurrence
          ORDER BY levels, parent_occurrence; */

          -- bug 6450787
          -- Modified the cursor to use child_txn_header_id
          -- to improve the performance.
          -- bhsankar Thu Oct  4 04:19:54 PDT 2007
	  --
          --
          -- bug 7015532
          -- modified the cursor definition to correct the
          -- hierarchy initiation criteria. Commented out the
          -- plan id since in case of a P-C-G scenario the Txn
          -- Header Id generated for a new Grand Child would not
          -- be stamped against the topmost parent record.
          -- ntungare
          --
          SELECT 0             child_plan_id,
                 0             child_collection_id,
                 0             child_occurrence,
                 plan_id       parent_plan_id,
                 collection_id parent_collection_id,
                 occurrence    parent_occurrence,
                 0 levels
          FROM   qa_results qr
          WHERE  qr.plan_id       = p_plan_id AND
                 qr.txn_header_id = p_txn_header_id
          UNION ALL
          SELECT child_plan_id,
                 child_collection_id,
                 child_occurrence,
                 parent_plan_id,
                 parent_collection_id,
                 parent_occurrence,
                 level levels
          FROM   qa_pc_results_relationship r
          START WITH  --r.parent_plan_id      = p_plan_id AND
                      r.child_txn_header_id = p_txn_header_id
          CONNECT BY PRIOR r.child_occurrence = r.parent_occurrence
          ORDER BY levels, parent_occurrence, child_occurrence;

          --
          -- Bug 5118745.  Locking issue as reported by customer P1 5060289.
          -- For better user experience, augmented order by with occurrence
          -- so that user does not see random ordering of sequences when
          -- entering multiple records in one collection.  No change to
          -- performance as the number of new records per collection is
          -- limited.
          -- bso Tue Mar 28 12:59:39 PST 2006
          --


   -- Bug 3128040 rponnusa Thu Sep  4 05:52:20 PDT 2003
   l_eres_enabled         BOOLEAN;

 BEGIN
   -- Bug 3128040. Get the profile value
   l_eres_enabled := get_eres_profile();

   IF p_txn_header_id IS NOT NULL THEN

      -- for Direct data entry
      FOR rec IN dde_cur LOOP
        IF rec.levels = 0 THEN
           -- This is the top most parent record.

           -- Bug 3128040 rponnusa Thu Sep  4 05:52:20 PDT 2003
           -- Added eRes condition since we need intermediate commit before final eRes commit

           IF l_eres_enabled THEN
             gen_seq_for_currec_commit(rec.parent_plan_id,
                                       rec.parent_collection_id,
                                       rec.parent_occurrence,
                                       null,null,null);

           ELSE
             generate_seq_for_currec(rec.parent_plan_id,
                                     rec.parent_collection_id,
                                     rec.parent_occurrence,
                                     null,null,null);
           END IF;

        ELSE
           -- This is for any child or grandchild ... record
           -- Bug 3128040 rponnusa Thu Sep  4 05:52:20 PDT 2003
           -- Added eRes condition

           IF l_eres_enabled THEN
             gen_seq_for_currec_commit(rec.child_plan_id,
                                       rec.child_collection_id,
                                       rec.child_occurrence,
                                       rec.parent_plan_id,
                                       rec.parent_collection_id,
                                       rec.parent_occurrence);

           ELSE
             generate_seq_for_currec(rec.child_plan_id,
                                     rec.child_collection_id,
                                     rec.child_occurrence,
                                     rec.parent_plan_id,
                                     rec.parent_collection_id,
                                     rec.parent_occurrence);
           END IF;
        END IF;

     END LOOP;
   ELSE
      -- for txn data entry
      FOR rec IN txn_cur LOOP
        IF rec.levels = 0 THEN
           -- This is the top most parent record.

           -- Bug 3128040 rponnusa Thu Sep  4 05:52:20 PDT 2003
           -- Added eRes condition
           -- Bug 5368983. Added OA Txn Integartion condition.
           IF ( l_eres_enabled  OR p_oa_txnint ) THEN
             --
             -- bug 5228667
             -- Check if the Txn is a resubmission of the
             -- ERES. If it is then the Resubmission flag
             -- is set to TRUE
             -- ntungare Thu Aug 17 03:40:02 PDT 2006
             --
             If eres_resubmit(null,
                              rec.parent_collection_id,
                              rec.parent_plan_id,
                              rec.parent_occurrence) THEN

                g_eres_resubmit_flg := TRUE;
             END IF;
             gen_seq_for_currec_commit(rec.parent_plan_id,
                                       rec.parent_collection_id,
                                       rec.parent_occurrence,
                                       null,null,null,p_oa_txnint );

           ELSE
             generate_seq_for_currec(rec.parent_plan_id,
                                     rec.parent_collection_id,
                                     rec.parent_occurrence,
                                     null,null,null);
           END IF;


        ELSE
           -- This is for any child or grandchild ... record

           -- Bug 3128040 rponnusa Thu Sep  4 05:52:20 PDT 2003
           -- Added eRes condition

           -- Bug 5368983. Added OA Txn Integartion condition.
           IF ( l_eres_enabled OR p_oa_txnint ) THEN

             --
             -- bug 5228667
             -- Check if the Txn is a resubmission of the
             -- ERES. If it is then the Resubmission flag
             -- is set to TRUE
             -- ntungare Thu Aug 17 03:40:02 PDT 2006
             --
             If eres_resubmit(null,
                              rec.child_collection_id,
                              rec.child_plan_id,
                              rec.child_occurrence) THEN

                g_eres_resubmit_flg := TRUE;
             END IF;
             gen_seq_for_currec_commit(rec.child_plan_id,
                                       rec.child_collection_id,
                                       rec.child_occurrence,
                                       rec.parent_plan_id,
                                       rec.parent_collection_id,
                                       rec.parent_occurrence,
                                       p_oa_txnint);

           ELSE
             generate_seq_for_currec(rec.child_plan_id,
                                     rec.child_collection_id,
                                     rec.child_occurrence,
                                     rec.parent_plan_id,
                                     rec.parent_collection_id,
                                     rec.parent_occurrence);
           END IF;
        END IF;

        --
        -- Bug 5228667
        -- Resetting the Eres resubmisson.
        -- Check Flag
        -- ntungare Thu Aug 17 03:40:02 PDT 2006
        --
        g_eres_resubmit_flg := FALSE;

     END LOOP;
   END IF;

 END generate_seq_for_pc;

 -- Bug 5368983
 -- Added a new flag. Provided a default value so it
 -- does not impact existing calls
 -- saugupta Wed, 30 Aug 2006 06:06:20 -0700 PDT
 PROCEDURE gen_seq_for_currec_commit(p_plan_id               NUMBER,
                                     p_collection_id         NUMBER,
                                     p_occurrence            NUMBER,
                                     p_parent_plan_id        NUMBER,
                                     p_parent_collection_id  NUMBER,
                                     p_parent_occurrence     NUMBER,
                                     p_oa_txnint BOOLEAN DEFAULT NULL) IS
 PRAGMA AUTONOMOUS_TRANSACTION;

   -- Bug 3128040 rponnusa Thu Sep  4 05:52:20 PDT 2003

   -- In the ERES flow, we certainly don't want to commit the qa_results
   -- before the final commit.  So the autonomous commit should be used

   -- 1. user tries to save record in the form
   -- 2. sequences generated (HERE each generation is itself an
   --    autonomous txn:lock table, gen-sequence, add-to-audit, commit.)
   -- 3. qa_results table updated
   -- 4. eSignature obtained
   -- 5. commit

   -- step 2 is accomblished in this procedure.

   l_char_id NUMBER;

   --
   -- Bug 5118745.  Locking issue as reported by customer P1 5060289.
   -- This cursor is not required.  It is conservatively used to give
   -- a nice-to-have feature for sequential numbering per collection
   -- during concurrent EQR.
   -- bso Tue Mar 28 12:19:04 PST 2006
   --
   -- CURSOR c IS
   --   SELECT char_id
   --   FROM qa_chars WHERE char_id = 1
   --   FOR UPDATE;

 BEGIN
   -- unless user gets the lock on this table he can't get past this cursor.
   -- for eRes, lock the row within autonomous block. Reason is, the time between
   -- seq. generation and eres commit is too long, but we cannot have lock for so long
   -- since other users will wait. Here lock is relaased once block data committed
   -- thus avoids potential problem.

   -- Bug 5118745.  Locking issue as reported by customer P1 5060289.
   -- OPEN c;
   -- FETCH c INTO l_char_id;
   -- CLOSE c;

   -- Bug 5368983
   -- Added a new flag to the modified proc signature
   -- saugupta Wed, 30 Aug 2006 06:07:52 -0700 PDT
   generate_seq_for_currec(p_plan_id,
                           p_collection_id,
                           p_occurrence,
                           p_parent_plan_id,
                           p_parent_collection_id,
                           p_parent_occurrence,
                           p_oa_txnint);

   -- following commit statement will coming only the data in
   -- qa_seq_audit_history, qa_chars table. We should not commit
   -- records in qa_results;

   COMMIT;

 END gen_seq_for_currec_commit;

 --
 -- bug 5228667
 -- New function to get the sequence from the
 -- Seq Audit Hist Table. In case an ERES Txn
 -- is resubmitted, then the sequence should not
 -- be regenerated as it would already be present
 -- in the Audit Hist table. In this case this
 -- function would be used to fetch the val from
 -- the Audit table.
 -- ntungare Thu Aug 17 03:59:48 PDT 2006
 --
 FUNCTION get_eres_seq(p_plan_id        NUMBER,
                       p_collection_id  NUMBER,
                       p_occurrence     NUMBER,
                       p_char_id        NUMBER) RETURN VARCHAR2 AS

    CURSOR cur_seq_val IS
       SELECT sequence_value
         FROM qa_seq_audit_history
       WHERE plan_id = p_plan_id
         AND collection_id = p_collection_id
         AND occurrence    = p_occurrence
         AND char_id       = p_char_id;

    seq_val VARCHAR2(2000);
 BEGIN
    open cur_seq_val;
    fetch cur_seq_val into seq_val;
    close cur_seq_val;

    RETURN seq_val;
 END get_eres_seq;

 -- Bug 5368983
 -- Added a new flag. Provided a default value
 -- so it does not impact exeisting calls
 -- saugupta Wed, 30 Aug 2006 05:18:01 -0700 PDT

 PROCEDURE generate_seq_for_currec(p_plan_id               NUMBER,
                                   p_collection_id         NUMBER,
                                   p_occurrence            NUMBER,
                                   p_parent_plan_id        NUMBER,
                                   p_parent_collection_id  NUMBER,
                                   p_parent_occurrence     NUMBER,
                                   p_oa_txnint BOOLEAN default NULL) IS

   l_parent_rec_indicator NUMBER := -1;
   l_cur_rec_indicator    NUMBER := -1;
   l_char_id              NUMBER;
   l_seq_value            VARCHAR2(40);
   l_seq_default_value    VARCHAR2(40);
   l_eres_enabled         BOOLEAN;

   -- Bug 3160651 following cursor defined
   l_plan_name  VARCHAR2(40);

   CURSOR plan_cur(l_plan_id NUMBER) IS
     SELECT name FROM qa_plans
     WHERE  plan_id = l_plan_id;

   --Bug 5114865
   l_childUpdate_retval VARCHAR2(10);

   parentChildCntr   PLS_INTEGER := 1;

 BEGIN

   FOR i IN 1..QLTTRAWB.g_occurrence_tab.count LOOP

     -- Find out the position of parent and/or child record in the plsql table
     -- by looping through the G_OCCURRENCE and store it in rec. indicator.

     IF (p_parent_plan_id IS NOT NULL AND
         QLTTRAWB.g_occurrence_tab(i) = p_parent_occurrence) THEN

        l_parent_rec_indicator := i;

     ELSIF QLTTRAWB.g_occurrence_tab(i) = p_occurrence THEN -- for child record
        l_cur_rec_indicator := i;
     END IF;

   END LOOP;

   get_seq_value_for_pc_comb(p_plan_id,
                             p_collection_id,
                             p_occurrence,
                             l_cur_rec_indicator,
                             p_parent_plan_id,
                             p_parent_collection_id,
                             p_parent_occurrence,
                             l_parent_rec_indicator);

   -- Bug 3160651. rponnusa Thu Sep 25 02:24:28 PDT 2003
   OPEN plan_cur(p_plan_id);
   FETCH plan_cur INTO l_plan_name;
   CLOSE plan_cur;

   -- get all the seq. element prompt info. for the plan
   get_all_char_prompt_info(p_plan_id);


   -- Generate new seq. value for parent rec. sequence elements or for child rec.
   -- sequence element which doesnt  have any seq copy relation with parent rec.

   -- In the QLTTRAWB.g_seq_tab1..15 if any value is 'Automatic' means that new seq. number
   -- needs to be generated.

   -- For normal datacollection, generated only the sequence values for all the elements in
   -- the plan. But in eRes enabled txn, generated and capture the audit information at the
   -- same time.

   l_seq_default_value := get_sequence_default_value();
   l_eres_enabled      := get_eres_profile();

   IF NVL(QLTTRAWB.g_seq_tab1(l_cur_rec_indicator),' ') = l_seq_default_value THEN
      l_char_id   := g_curr_plan_seq_char_ids(1);

      --
      -- Bug 5228667
      -- in case the ERES request has been resubmitted in that
      -- case the seq value would already be generated and
      -- present in the qa_seq_audit_hist table. So it need not
      -- be generated again. The value just needs to be read
      -- from this table and populated in the array.
      -- ntungare Thu Aug 17 04:06:01 PDT 2006
      --
      --l_seq_value := get_next_seq(l_char_id,FALSE);
      If g_eres_resubmit_flg = TRUE
        THEN l_seq_value := get_eres_seq(p_plan_id,
                                         p_collection_id,
                                         p_occurrence,
                                         l_char_id);
        ELSE l_seq_value := get_next_seq(l_char_id,FALSE);
      End if;

      QLTTRAWB.g_seq_tab1(l_cur_rec_indicator) := l_seq_value;

      --
      -- Bug 5228667
      -- if ERES Txn is being resubmitted then the Seq
      -- Auditing need not be done as it would have been
      -- done earlier.
      -- ntungare Thu Aug 17 04:06:01 PDT 2006
      --
      IF (l_eres_enabled AND g_eres_resubmit_flg = FALSE) THEN
        audit_seq_for_eres(l_char_id,l_seq_value,l_cur_rec_indicator);
      -- Bug 5368983
      -- Added the call if the we are coming here from OA Txn Integ code
      -- added same call for all the sequence elements below from 1..15
      -- saugupta Wed, 30 Aug 2006 05:26:00 -0700 PDT
      ELSIF p_oa_txnint THEN
        audit_seq_for_txnint(l_char_id,l_seq_value,l_cur_rec_indicator);
      --
      -- bug 5955808
      -- Added for auditing the sequence generation in mobile application
      -- ntungare Thu Jul 26 02:55:50 PDT 2007
      --
      ELSIF g_mobile THEN
        audit_seq_for_txnint(l_char_id,l_seq_value,l_cur_rec_indicator, 'MOBILE');
      END IF;

      -- Bug 3160651.
      populate_message_array(l_char_id,l_seq_value,l_plan_name);

   END IF;


   IF NVL(QLTTRAWB.g_seq_tab2(l_cur_rec_indicator),' ') = l_seq_default_value THEN
      l_char_id   := g_curr_plan_seq_char_ids(2);

      --
      -- Bug 5228667
      -- in case the ERES request has been resubmitted in that
      -- case the seq value would already be generated and
      -- present in the qa_seq_audit_hist table. So it need not
      -- be generated again. The value just needs to be read
      -- from this table and populated in the array.
      -- ntungare Thu Aug 17 04:06:01 PDT 2006
      --
      --l_seq_value := get_next_seq(l_char_id,FALSE);
      If g_eres_resubmit_flg = TRUE
        THEN l_seq_value := get_eres_seq(p_plan_id,
                                         p_collection_id,
                                         p_occurrence,
                                         l_char_id);
        ELSE l_seq_value := get_next_seq(l_char_id,FALSE);
      End if;

      QLTTRAWB.g_seq_tab2(l_cur_rec_indicator) := l_seq_value;

      --
      -- Bug 5228667
      -- if ERES Txn is being resubmitted then the Seq
      -- Auditing need not be done as it would have been
      -- done earlier.
      -- ntungare Thu Aug 17 04:06:01 PDT 2006
      --
      IF (l_eres_enabled AND g_eres_resubmit_flg = FALSE) THEN
        audit_seq_for_eres(l_char_id,l_seq_value,l_cur_rec_indicator);
      ELSIF p_oa_txnint THEN
        audit_seq_for_txnint(l_char_id,l_seq_value,l_cur_rec_indicator);
      --
      -- bug 5955808
      -- Added for auditing the sequence generation in mobile application
      -- ntungare Thu Jul 26 02:55:50 PDT 2007
      --
      ELSIF g_mobile THEN
        audit_seq_for_txnint(l_char_id,l_seq_value,l_cur_rec_indicator, 'MOBILE');
      END IF;

      -- Bug 3160651.
      populate_message_array(l_char_id,l_seq_value,l_plan_name);
   END IF;

   IF NVL(QLTTRAWB.g_seq_tab3(l_cur_rec_indicator),' ') = l_seq_default_value THEN
      l_char_id   := g_curr_plan_seq_char_ids(3);

      --
      -- Bug 5228667
      -- in case the ERES request has been resubmitted in that
      -- case the seq value would already be generated and
      -- present in the qa_seq_audit_hist table. So it need not
      -- be generated again. The value just needs to be read
      -- from this table and populated in the array.
      -- ntungare Thu Aug 17 04:06:01 PDT 2006
      --
      --l_seq_value := get_next_seq(l_char_id,FALSE);
      If g_eres_resubmit_flg = TRUE
        THEN l_seq_value := get_eres_seq(p_plan_id,
                                         p_collection_id,
                                         p_occurrence,
                                         l_char_id);
        ELSE l_seq_value := get_next_seq(l_char_id,FALSE);
      End if;

      QLTTRAWB.g_seq_tab3(l_cur_rec_indicator) := l_seq_value;

      --
      -- Bug 5228667
      -- if ERES Txn is being resubmitted then the Seq
      -- Auditing need not be done as it would have been
      -- done earlier.
      -- ntungare Thu Aug 17 04:06:01 PDT 2006
      --
      IF (l_eres_enabled AND g_eres_resubmit_flg = FALSE) THEN
        audit_seq_for_eres(l_char_id,l_seq_value,l_cur_rec_indicator);
      ELSIF p_oa_txnint THEN
        audit_seq_for_txnint(l_char_id,l_seq_value,l_cur_rec_indicator);
      --
      -- bug 5955808
      -- Added for auditing the sequence generation in mobile application
      -- ntungare Thu Jul 26 02:55:50 PDT 2007
      --
      ELSIF g_mobile THEN
        audit_seq_for_txnint(l_char_id,l_seq_value,l_cur_rec_indicator, 'MOBILE');
      END IF;

      -- Bug 3160651.
      populate_message_array(l_char_id,l_seq_value,l_plan_name);

   END IF;

   IF NVL(QLTTRAWB.g_seq_tab4(l_cur_rec_indicator),' ') = l_seq_default_value THEN
      l_char_id   := g_curr_plan_seq_char_ids(4);

      --
      -- Bug 5228667
      -- in case the ERES request has been resubmitted in that
      -- case the seq value would already be generated and
      -- present in the qa_seq_audit_hist table. So it need not
      -- be generated again. The value just needs to be read
      -- from this table and populated in the array.
      -- ntungare Thu Aug 17 04:06:01 PDT 2006
      --
      --l_seq_value := get_next_seq(l_char_id,FALSE);
      If g_eres_resubmit_flg = TRUE
        THEN l_seq_value := get_eres_seq(p_plan_id,
                                         p_collection_id,
                                         p_occurrence,
                                         l_char_id);
        ELSE l_seq_value := get_next_seq(l_char_id,FALSE);
      End if;

      QLTTRAWB.g_seq_tab4(l_cur_rec_indicator) := l_seq_value;

      --
      -- Bug 5228667
      -- if ERES Txn is being resubmitted then the Seq
      -- Auditing need not be done as it would have been
      -- done earlier.
      -- ntungare Thu Aug 17 04:06:01 PDT 2006
      --
      IF (l_eres_enabled AND g_eres_resubmit_flg = FALSE) THEN
        audit_seq_for_eres(l_char_id,l_seq_value,l_cur_rec_indicator);
      ELSIF p_oa_txnint THEN
        audit_seq_for_txnint(l_char_id,l_seq_value,l_cur_rec_indicator);
      --
      -- bug 5955808
      -- Added for auditing the sequence generation in mobile application
      -- ntungare Thu Jul 26 02:55:50 PDT 2007
      --
      ELSIF g_mobile THEN
        audit_seq_for_txnint(l_char_id,l_seq_value,l_cur_rec_indicator, 'MOBILE');
      END IF;

      -- Bug 3160651.
      populate_message_array(l_char_id,l_seq_value,l_plan_name);

   END IF;

   IF NVL(QLTTRAWB.g_seq_tab5(l_cur_rec_indicator),' ') = l_seq_default_value THEN
      l_char_id   := g_curr_plan_seq_char_ids(5);

      --
      -- Bug 5228667
      -- in case the ERES request has been resubmitted in that
      -- case the seq value would already be generated and
      -- present in the qa_seq_audit_hist table. So it need not
      -- be generated again. The value just needs to be read
      -- from this table and populated in the array.
      -- ntungare Thu Aug 17 04:06:01 PDT 2006
      --
      --l_seq_value := get_next_seq(l_char_id,FALSE);
      If g_eres_resubmit_flg = TRUE
        THEN l_seq_value := get_eres_seq(p_plan_id,
                                         p_collection_id,
                                         p_occurrence,
                                         l_char_id);
        ELSE l_seq_value := get_next_seq(l_char_id,FALSE);
      End if;

      QLTTRAWB.g_seq_tab5(l_cur_rec_indicator) := l_seq_value;

      --
      -- Bug 5228667
      -- if ERES Txn is being resubmitted then the Seq
      -- Auditing need not be done as it would have been
      -- done earlier.
      -- ntungare Thu Aug 17 04:06:01 PDT 2006
      --
      IF (l_eres_enabled AND g_eres_resubmit_flg = FALSE) THEN
        audit_seq_for_eres(l_char_id,l_seq_value,l_cur_rec_indicator);
      ELSIF p_oa_txnint THEN
        audit_seq_for_txnint(l_char_id,l_seq_value,l_cur_rec_indicator);
      --
      -- bug 5955808
      -- Added for auditing the sequence generation in mobile application
      -- ntungare Thu Jul 26 02:55:50 PDT 2007
      --
      ELSIF g_mobile THEN
        audit_seq_for_txnint(l_char_id,l_seq_value,l_cur_rec_indicator, 'MOBILE');
      END IF;

      -- Bug 3160651.
      populate_message_array(l_char_id,l_seq_value,l_plan_name);

   END IF;

   IF NVL(QLTTRAWB.g_seq_tab6(l_cur_rec_indicator),' ') = l_seq_default_value THEN
      l_char_id   := g_curr_plan_seq_char_ids(6);

      --
      -- Bug 5228667
      -- in case the ERES request has been resubmitted in that
      -- case the seq value would already be generated and
      -- present in the qa_seq_audit_hist table. So it need not
      -- be generated again. The value just needs to be read
      -- from this table and populated in the array.
      -- ntungare Thu Aug 17 04:06:01 PDT 2006
      --
      --l_seq_value := get_next_seq(l_char_id,FALSE);
      If g_eres_resubmit_flg = TRUE
        THEN l_seq_value := get_eres_seq(p_plan_id,
                                         p_collection_id,
                                         p_occurrence,
                                         l_char_id);
        ELSE l_seq_value := get_next_seq(l_char_id,FALSE);
      End if;

      QLTTRAWB.g_seq_tab6(l_cur_rec_indicator) := l_seq_value;

      --
      -- Bug 5228667
      -- if ERES Txn is being resubmitted then the Seq
      -- Auditing need not be done as it would have been
      -- done earlier.
      -- ntungare Thu Aug 17 04:06:01 PDT 2006
      --
      IF (l_eres_enabled AND g_eres_resubmit_flg = FALSE) THEN
        audit_seq_for_eres(l_char_id,l_seq_value,l_cur_rec_indicator);
      ELSIF p_oa_txnint THEN
        audit_seq_for_txnint(l_char_id,l_seq_value,l_cur_rec_indicator);
      --
      -- bug 5955808
      -- Added for auditing the sequence generation in mobile application
      -- ntungare Thu Jul 26 02:55:50 PDT 2007
      --
      ELSIF g_mobile THEN
        audit_seq_for_txnint(l_char_id,l_seq_value,l_cur_rec_indicator, 'MOBILE');
      END IF;

      -- Bug 3160651.
      populate_message_array(l_char_id,l_seq_value,l_plan_name);

   END IF;

   IF NVL(QLTTRAWB.g_seq_tab7(l_cur_rec_indicator),' ') = l_seq_default_value THEN
      l_char_id   := g_curr_plan_seq_char_ids(7);

      --
      -- Bug 5228667
      -- in case the ERES request has been resubmitted in that
      -- case the seq value would already be generated and
      -- present in the qa_seq_audit_hist table. So it need not
      -- be generated again. The value just needs to be read
      -- from this table and populated in the array.
      -- ntungare Thu Aug 17 04:06:01 PDT 2006
      --
      --l_seq_value := get_next_seq(l_char_id,FALSE);
      If g_eres_resubmit_flg = TRUE
        THEN l_seq_value := get_eres_seq(p_plan_id,
                                         p_collection_id,
                                         p_occurrence,
                                         l_char_id);
        ELSE l_seq_value := get_next_seq(l_char_id,FALSE);
      End if;

      QLTTRAWB.g_seq_tab7(l_cur_rec_indicator) := l_seq_value;

      --
      -- Bug 5228667
      -- if ERES Txn is being resubmitted then the Seq
      -- Auditing need not be done as it would have been
      -- done earlier.
      -- ntungare Thu Aug 17 04:06:01 PDT 2006
      --
      IF (l_eres_enabled AND g_eres_resubmit_flg = FALSE) THEN
        audit_seq_for_eres(l_char_id,l_seq_value,l_cur_rec_indicator);
      ELSIF p_oa_txnint THEN
        audit_seq_for_txnint(l_char_id,l_seq_value,l_cur_rec_indicator);
      --
      -- bug 5955808
      -- Added for auditing the sequence generation in mobile application
      -- ntungare Thu Jul 26 02:55:50 PDT 2007
      --
      ELSIF g_mobile THEN
        audit_seq_for_txnint(l_char_id,l_seq_value,l_cur_rec_indicator, 'MOBILE');
      END IF;

      -- Bug 3160651.
      populate_message_array(l_char_id,l_seq_value,l_plan_name);

   END IF;

   IF NVL(QLTTRAWB.g_seq_tab8(l_cur_rec_indicator),' ') = l_seq_default_value THEN
      l_char_id   := g_curr_plan_seq_char_ids(8);

      --
      -- Bug 5228667
      -- in case the ERES request has been resubmitted in that
      -- case the seq value would already be generated and
      -- present in the qa_seq_audit_hist table. So it need not
      -- be generated again. The value just needs to be read
      -- from this table and populated in the array.
      -- ntungare Thu Aug 17 04:06:01 PDT 2006
      --
      --l_seq_value := get_next_seq(l_char_id,FALSE);
      If g_eres_resubmit_flg = TRUE
        THEN l_seq_value := get_eres_seq(p_plan_id,
                                         p_collection_id,
                                         p_occurrence,
                                         l_char_id);
        ELSE l_seq_value := get_next_seq(l_char_id,FALSE);
      End if;

      QLTTRAWB.g_seq_tab8(l_cur_rec_indicator) := l_seq_value;

      --
      -- Bug 5228667
      -- if ERES Txn is being resubmitted then the Seq
      -- Auditing need not be done as it would have been
      -- done earlier.
      -- ntungare Thu Aug 17 04:06:01 PDT 2006
      --
      IF (l_eres_enabled AND g_eres_resubmit_flg = FALSE) THEN
        audit_seq_for_eres(l_char_id,l_seq_value,l_cur_rec_indicator);
      ELSIF p_oa_txnint THEN
        audit_seq_for_txnint(l_char_id,l_seq_value,l_cur_rec_indicator);
      --
      -- bug 5955808
      -- Added for auditing the sequence generation in mobile application
      -- ntungare Thu Jul 26 02:55:50 PDT 2007
      --
      ELSIF g_mobile THEN
        audit_seq_for_txnint(l_char_id,l_seq_value,l_cur_rec_indicator, 'MOBILE');
      END IF;

      -- Bug 3160651.
      populate_message_array(l_char_id,l_seq_value,l_plan_name);

   END IF;

   IF NVL(QLTTRAWB.g_seq_tab9(l_cur_rec_indicator),' ') = l_seq_default_value THEN
      l_char_id   := g_curr_plan_seq_char_ids(9);

      --
      -- Bug 5228667
      -- in case the ERES request has been resubmitted in that
      -- case the seq value would already be generated and
      -- present in the qa_seq_audit_hist table. So it need not
      -- be generated again. The value just needs to be read
      -- from this table and populated in the array.
      -- ntungare Thu Aug 17 04:06:01 PDT 2006
      --
      --l_seq_value := get_next_seq(l_char_id,FALSE);
      If g_eres_resubmit_flg = TRUE
        THEN l_seq_value := get_eres_seq(p_plan_id,
                                         p_collection_id,
                                         p_occurrence,
                                         l_char_id);
        ELSE l_seq_value := get_next_seq(l_char_id,FALSE);
      End if;

      QLTTRAWB.g_seq_tab9(l_cur_rec_indicator) := l_seq_value;

      --
      -- Bug 5228667
      -- if ERES Txn is being resubmitted then the Seq
      -- Auditing need not be done as it would have been
      -- done earlier.
      -- ntungare Thu Aug 17 04:06:01 PDT 2006
      --
      IF (l_eres_enabled AND g_eres_resubmit_flg = FALSE) THEN
        audit_seq_for_eres(l_char_id,l_seq_value,l_cur_rec_indicator);
      ELSIF p_oa_txnint THEN
        audit_seq_for_txnint(l_char_id,l_seq_value,l_cur_rec_indicator);
      --
      -- bug 5955808
      -- Added for auditing the sequence generation in mobile application
      -- ntungare Thu Jul 26 02:55:50 PDT 2007
      --
      ELSIF g_mobile THEN
        audit_seq_for_txnint(l_char_id,l_seq_value,l_cur_rec_indicator, 'MOBILE');
      END IF;

      -- Bug 3160651.
      populate_message_array(l_char_id,l_seq_value,l_plan_name);

   END IF;

   IF NVL(QLTTRAWB.g_seq_tab10(l_cur_rec_indicator),' ') = l_seq_default_value THEN
      l_char_id   := g_curr_plan_seq_char_ids(10);

      --
      -- Bug 5228667
      -- in case the ERES request has been resubmitted in that
      -- case the seq value would already be generated and
      -- present in the qa_seq_audit_hist table. So it need not
      -- be generated again. The value just needs to be read
      -- from this table and populated in the array.
      -- ntungare Thu Aug 17 04:06:01 PDT 2006
      --
      --l_seq_value := get_next_seq(l_char_id,FALSE);
      If g_eres_resubmit_flg = TRUE
        THEN l_seq_value := get_eres_seq(p_plan_id,
                                         p_collection_id,
                                         p_occurrence,
                                         l_char_id);
        ELSE l_seq_value := get_next_seq(l_char_id,FALSE);
      End if;

      QLTTRAWB.g_seq_tab10(l_cur_rec_indicator) := l_seq_value;

      --
      -- Bug 5228667
      -- if ERES Txn is being resubmitted then the Seq
      -- Auditing need not be done as it would have been
      -- done earlier.
      -- ntungare Thu Aug 17 04:06:01 PDT 2006
      --
      IF (l_eres_enabled AND g_eres_resubmit_flg = FALSE) THEN
        audit_seq_for_eres(l_char_id,l_seq_value,l_cur_rec_indicator);
      ELSIF p_oa_txnint THEN
        audit_seq_for_txnint(l_char_id,l_seq_value,l_cur_rec_indicator);
      --
      -- bug 5955808
      -- Added for auditing the sequence generation in mobile application
      -- ntungare Thu Jul 26 02:55:50 PDT 2007
      --
      ELSIF g_mobile THEN
        audit_seq_for_txnint(l_char_id,l_seq_value,l_cur_rec_indicator, 'MOBILE');
      END IF;

      -- Bug 3160651.
      populate_message_array(l_char_id,l_seq_value,l_plan_name);

   END IF;


   IF NVL(QLTTRAWB.g_seq_tab11(l_cur_rec_indicator),' ') = l_seq_default_value THEN
      l_char_id   := g_curr_plan_seq_char_ids(11);

      --
      -- Bug 5228667
      -- in case the ERES request has been resubmitted in that
      -- case the seq value would already be generated and
      -- present in the qa_seq_audit_hist table. So it need not
      -- be generated again. The value just needs to be read
      -- from this table and populated in the array.
      -- ntungare Thu Aug 17 04:06:01 PDT 2006
      --
      --l_seq_value := get_next_seq(l_char_id,FALSE);
      If g_eres_resubmit_flg = TRUE
        THEN l_seq_value := get_eres_seq(p_plan_id,
                                         p_collection_id,
                                         p_occurrence,
                                         l_char_id);
        ELSE l_seq_value := get_next_seq(l_char_id,FALSE);
      End if;

      QLTTRAWB.g_seq_tab11(l_cur_rec_indicator) := l_seq_value;

      --
      -- Bug 5228667
      -- if ERES Txn is being resubmitted then the Seq
      -- Auditing need not be done as it would have been
      -- done earlier.
      -- ntungare Thu Aug 17 04:06:01 PDT 2006
      --
      IF (l_eres_enabled AND g_eres_resubmit_flg = FALSE) THEN
        audit_seq_for_eres(l_char_id,l_seq_value,l_cur_rec_indicator);
      ELSIF p_oa_txnint THEN
        audit_seq_for_txnint(l_char_id,l_seq_value,l_cur_rec_indicator);
      --
      -- bug 5955808
      -- Added for auditing the sequence generation in mobile application
      -- ntungare Thu Jul 26 02:55:50 PDT 2007
      --
      ELSIF g_mobile THEN
        audit_seq_for_txnint(l_char_id,l_seq_value,l_cur_rec_indicator, 'MOBILE');
      END IF;

      -- Bug 3160651.
      populate_message_array(l_char_id,l_seq_value,l_plan_name);

   END IF;

   IF NVL(QLTTRAWB.g_seq_tab12(l_cur_rec_indicator),' ') = l_seq_default_value THEN
      l_char_id   := g_curr_plan_seq_char_ids(12);

      --
      -- Bug 5228667
      -- in case the ERES request has been resubmitted in that
      -- case the seq value would already be generated and
      -- present in the qa_seq_audit_hist table. So it need not
      -- be generated again. The value just needs to be read
      -- from this table and populated in the array.
      -- ntungare Thu Aug 17 04:06:01 PDT 2006
      --
      --l_seq_value := get_next_seq(l_char_id,FALSE);
      If g_eres_resubmit_flg = TRUE
        THEN l_seq_value := get_eres_seq(p_plan_id,
                                         p_collection_id,
                                         p_occurrence,
                                         l_char_id);
        ELSE l_seq_value := get_next_seq(l_char_id,FALSE);
      End if;

      QLTTRAWB.g_seq_tab12(l_cur_rec_indicator) := l_seq_value;

      --
      -- Bug 5228667
      -- if ERES Txn is being resubmitted then the Seq
      -- Auditing need not be done as it would have been
      -- done earlier.
      -- ntungare Thu Aug 17 04:06:01 PDT 2006
      --
      IF (l_eres_enabled AND g_eres_resubmit_flg = FALSE) THEN
        audit_seq_for_eres(l_char_id,l_seq_value,l_cur_rec_indicator);
      ELSIF p_oa_txnint THEN
        audit_seq_for_txnint(l_char_id,l_seq_value,l_cur_rec_indicator);
      --
      -- bug 5955808
      -- Added for auditing the sequence generation in mobile application
      -- ntungare Thu Jul 26 02:55:50 PDT 2007
      --
      ELSIF g_mobile THEN
        audit_seq_for_txnint(l_char_id,l_seq_value,l_cur_rec_indicator, 'MOBILE');
      END IF;

      -- Bug 3160651.
      populate_message_array(l_char_id,l_seq_value,l_plan_name);

   END IF;

   IF NVL(QLTTRAWB.g_seq_tab13(l_cur_rec_indicator),' ') = l_seq_default_value THEN
      l_char_id   := g_curr_plan_seq_char_ids(13);

      --
      -- Bug 5228667
      -- in case the ERES request has been resubmitted in that
      -- case the seq value would already be generated and
      -- present in the qa_seq_audit_hist table. So it need not
      -- be generated again. The value just needs to be read
      -- from this table and populated in the array.
      -- ntungare Thu Aug 17 04:06:01 PDT 2006
      --
      --l_seq_value := get_next_seq(l_char_id,FALSE);
      If g_eres_resubmit_flg = TRUE
        THEN l_seq_value := get_eres_seq(p_plan_id,
                                         p_collection_id,
                                         p_occurrence,
                                         l_char_id);
        ELSE l_seq_value := get_next_seq(l_char_id,FALSE);
      End if;

      QLTTRAWB.g_seq_tab13(l_cur_rec_indicator) := l_seq_value;

      --
      -- Bug 5228667
      -- if ERES Txn is being resubmitted then the Seq
      -- Auditing need not be done as it would have been
      -- done earlier.
      -- ntungare Thu Aug 17 04:06:01 PDT 2006
      --
      IF (l_eres_enabled AND g_eres_resubmit_flg = FALSE) THEN
        audit_seq_for_eres(l_char_id,l_seq_value,l_cur_rec_indicator);
      ELSIF p_oa_txnint THEN
        audit_seq_for_txnint(l_char_id,l_seq_value,l_cur_rec_indicator);
      --
      -- bug 5955808
      -- Added for auditing the sequence generation in mobile application
      -- ntungare Thu Jul 26 02:55:50 PDT 2007
      --
      ELSIF g_mobile THEN
        audit_seq_for_txnint(l_char_id,l_seq_value,l_cur_rec_indicator, 'MOBILE');
      END IF;

      -- Bug 3160651.
      populate_message_array(l_char_id,l_seq_value,l_plan_name);

   END IF;

   IF NVL(QLTTRAWB.g_seq_tab14(l_cur_rec_indicator),' ') = l_seq_default_value THEN
      l_char_id   := g_curr_plan_seq_char_ids(14);

      --
      -- Bug 5228667
      -- in case the ERES request has been resubmitted in that
      -- case the seq value would already be generated and
      -- present in the qa_seq_audit_hist table. So it need not
      -- be generated again. The value just needs to be read
      -- from this table and populated in the array.
      -- ntungare Thu Aug 17 04:06:01 PDT 2006
      --
      --l_seq_value := get_next_seq(l_char_id,FALSE);
      If g_eres_resubmit_flg = TRUE
        THEN l_seq_value := get_eres_seq(p_plan_id,
                                         p_collection_id,
                                         p_occurrence,
                                         l_char_id);
        ELSE l_seq_value := get_next_seq(l_char_id,FALSE);
      End if;

      QLTTRAWB.g_seq_tab14(l_cur_rec_indicator) := l_seq_value;

      --
      -- Bug 5228667
      -- if ERES Txn is being resubmitted then the Seq
      -- Auditing need not be done as it would have been
      -- done earlier.
      -- ntungare Thu Aug 17 04:06:01 PDT 2006
      --
      IF (l_eres_enabled AND g_eres_resubmit_flg = FALSE) THEN
        audit_seq_for_eres(l_char_id,l_seq_value,l_cur_rec_indicator);
      ELSIF p_oa_txnint THEN
        audit_seq_for_txnint(l_char_id,l_seq_value,l_cur_rec_indicator);
      --
      -- bug 5955808
      -- Added for auditing the sequence generation in mobile application
      -- ntungare Thu Jul 26 02:55:50 PDT 2007
      --
      ELSIF g_mobile THEN
        audit_seq_for_txnint(l_char_id,l_seq_value,l_cur_rec_indicator, 'MOBILE');
      END IF;

      -- Bug 3160651.
      populate_message_array(l_char_id,l_seq_value,l_plan_name);

   END IF;

   IF NVL(QLTTRAWB.g_seq_tab15(l_cur_rec_indicator),' ') = l_seq_default_value THEN
      l_char_id   := g_curr_plan_seq_char_ids(15);

      --
      -- Bug 5228667
      -- in case the ERES request has been resubmitted in that
      -- case the seq value would already be generated and
      -- present in the qa_seq_audit_hist table. So it need not
      -- be generated again. The value just needs to be read
      -- from this table and populated in the array.
      -- ntungare Thu Aug 17 04:06:01 PDT 2006
      --
      --l_seq_value := get_next_seq(l_char_id,FALSE);
      If g_eres_resubmit_flg = TRUE
        THEN l_seq_value := get_eres_seq(p_plan_id,
                                         p_collection_id,
                                         p_occurrence,
                                         l_char_id);
        ELSE l_seq_value := get_next_seq(l_char_id,FALSE);
      End if;

      QLTTRAWB.g_seq_tab15(l_cur_rec_indicator) := l_seq_value;

      --
      -- Bug 5228667
      -- if ERES Txn is being resubmitted then the Seq
      -- Auditing need not be done as it would have been
      -- done earlier.
      -- ntungare Thu Aug 17 04:06:01 PDT 2006
      --
      IF (l_eres_enabled AND g_eres_resubmit_flg = FALSE) THEN
        audit_seq_for_eres(l_char_id,l_seq_value,l_cur_rec_indicator);
      ELSIF p_oa_txnint THEN
        audit_seq_for_txnint(l_char_id,l_seq_value,l_cur_rec_indicator);
      --
      -- bug 5955808
      -- Added for auditing the sequence generation in mobile application
      -- ntungare Thu Jul 26 02:55:50 PDT 2007
      --
      ELSIF g_mobile THEN
        audit_seq_for_txnint(l_char_id,l_seq_value,l_cur_rec_indicator, 'MOBILE');
      END IF;

      -- Bug 3160651.
      populate_message_array(l_char_id,l_seq_value,l_plan_name);

   END IF;

   --
   -- Bug 5114865
   -- Collect the indexes for the Seq Type elements
   -- to be read from the the QLTTRAWB.g_seq_tabX array
   -- ntungare Sun Apr  9 23:40:46 PDT 2006
   If g_curr_plan_seq_char_ids.COUNT <> 0
      THEN
           g_true_seq_gen_recids(NVL(g_true_seq_gen_recids.LAST,0)+1) := l_cur_rec_indicator;
   END IF;

   --
   -- Bug 5114865
   -- Gather the data for the PC relationships
   -- ntungare  Sun Apr  9 23:40:46 PDT 2006
   IF p_parent_plan_id IS NOT NULL THEN
      parentChildCntr := NVL(ParentChild_Tab.LAST,0)+1;
      ParentChild_Tab(parentChildCntr).parent_plan_id       := p_parent_plan_id;
      ParentChild_Tab(parentChildCntr).parent_collection_id := p_parent_collection_id;
      ParentChild_Tab(parentChildCntr).parent_occurrence    := p_parent_occurrence;
      ParentChild_Tab(parentChildCntr).child_plan_id        := p_plan_id;
      ParentChild_Tab(parentChildCntr).child_collection_id  := p_collection_id;
      ParentChild_Tab(parentChildCntr).child_occurrence     := p_occurrence;

    END IF;

 END generate_seq_for_currec;

 PROCEDURE get_seq_value_for_pc_comb(p_plan_id               NUMBER,
                                     p_collection_id         NUMBER,
                                     p_occurrence            NUMBER,
                                     p_cur_rec_indicator     NUMBER,
                                     p_parent_plan_id        NUMBER,
                                     p_parent_collection_id  NUMBER,
                                     p_parent_occurrence     NUMBER,
                                     p_parent_rec_indicator  NUMBER) IS

  -- First pack all the char_id of the seq. element in the plan into x_seq_char_ids
  -- If it is top level parent rec, then dont do anything.
  -- If it is child rec and copy relations exist then copy parent seq. value to child
  -- seq element in the QLTTRAWB.g_seq_tab1..15 table for the child rec.

  l_seq_value VARCHAR2(30);
  i           NUMBER;

 BEGIN
   IF ((g_curr_plan_id = p_plan_id AND p_parent_plan_id IS NULL) OR
       (g_curr_plan_id = p_plan_id AND
        g_curr_parent_plan_id = p_parent_plan_id)) THEN

       -- Current plan(if not parent-child plan) or Parent-Child setup
       -- information for the current plan was already stored. Do nothing
       NULL;
   ELSE
      -- get the plan setup or parent-child setup for the current plan

      get_plan_seq_ele_setup(p_plan_id,
                             p_parent_plan_id);

      g_curr_plan_id        := p_plan_id;
      g_curr_parent_plan_id := p_parent_plan_id;

   END IF;

   --
   -- bug 7015532
   -- Added a check to ensure that the P-C processing is done only
   -- if the parent Id is not null and also the parent record
   -- indicator is not equal to -1
   -- ntungare
   --
   IF (p_parent_plan_id IS NOT NULL AND
       p_parent_rec_indicator <> -1) THEN -- parent child combination exist

     -- loop thro' all the seq element in the child plan, check any copy relation
     -- exist with its parent plan. If exist then copy parent seq. element value
     -- to child seq. element
     i := g_curr_plan_seq_char_ids.FIRST;

     WHILE i IS NOT NULL LOOP

        IF g_parent_plan_seq_char_ids.EXISTS(i) THEN
          -- copy relation exists between parent,child seq. elements
          find_update_seq_in_collection(p_parent_rec_indicator,
                                        g_parent_plan_seq_nos(i),
                                        1,
                                        l_seq_value);

          find_update_seq_in_collection(p_cur_rec_indicator,
                                        i,
                                        2,
                                        l_seq_value);

        END IF;
        i := g_curr_plan_seq_char_ids.NEXT(i); -- get the subscript of next element
     END LOOP;
   END IF;

 END get_seq_value_for_pc_comb;

 PROCEDURE get_plan_seq_ele_setup(p_plan_id        NUMBER,
                                  p_parent_plan_id NUMBER) IS
  CURSOR plan_cur IS
         SELECT qc.char_id,substr(qpc.result_column_name,9,10) position
         FROM   qa_plan_chars qpc,
                qa_chars qc
         WHERE  qpc.plan_id = p_plan_id AND
                qpc.char_id = qc.char_id AND
                qpc.enabled_flag = 1 AND
                qc.datatype = 5;

  -- Bug 5114865
  -- Modified the Cursor to fetch only the Seq Type elements
  -- Relationships as the Seq-Char relationships would be
  -- handled in the Update_record procedure using the
  -- Update_Child proc
  -- ntungare Sun Apr  9 23:40:46 PDT 2006
  CURSOR pc_cur IS
         SELECT parent_char_id, substr(parent_database_column,9,10) parent_seq_position,
                child_char_id, substr(child_database_column,9,10) child_seq_position
         FROM   qa_pc_result_columns_v
         WHERE  parent_plan_id = p_parent_plan_id AND
                child_plan_id = p_plan_id AND
                element_relationship_type = 1 AND
                parent_dataType = 5 AND
                child_dataType = 5;

--                 EXISTS (SELECT 1
--                         FROM qa_chars
--                         WHERE char_id in (parent_char_id,child_char_id) AND
--                               datatype = 5);
 BEGIN
   -- reset all the collections used

   g_curr_plan_seq_char_ids.DELETE;
   g_parent_plan_seq_char_ids.DELETE;
   g_parent_plan_seq_nos.DELETE;

   FOR plan_rec IN plan_cur LOOP
      -- store the seq char_ID in collection index by the sequence position (1 to 15)

      g_curr_plan_seq_char_ids(plan_rec.position) := plan_rec.char_id;
   END LOOP;

   IF p_parent_plan_id IS NOT NULL THEN -- parent child combination exist

      FOR child_rec IN pc_cur LOOP

          -- store parent seq. element char_ID and its corresponding parent
          -- seq. position (between 1 to 15) in the collection. Both the collections
          -- are indexed by child seq. position

          -- Ex. if seq8 in parent plan copied to seq15 in child plan. Store seq15 char_ID
          -- in collection g_curr_plan_seq_char_ids at index 15 (this is done in plan_cur).
          -- similarly char_ID of seq8 stored in g_parent_plan_seq_char_ids at index 15
          -- and parent seq position ( 8 in this case) stored in g_parent_plan_seq_nos at index 15


          g_parent_plan_seq_char_ids(child_rec.child_seq_position) := child_rec.parent_char_id;
          g_parent_plan_seq_nos(child_rec.child_seq_position)      := child_rec.parent_seq_position;
      END LOOP;
   END IF;
 END get_plan_seq_ele_setup;


 PROCEDURE find_update_seq_in_collection(p_cur_record_indicator     NUMBER,
                                         p_seq_position             NUMBER,
                                         p_action                   NUMBER,
                                         p_seq_value  IN OUT NOCOPY VARCHAR2) IS
/*
  p_action:
    Holds value 1 Meaning get the seq value from parent record in plsql table
    Holds value 2 Meaning copy the seq value into child record in plsql table

  p_cur_record_indicator:
    Indicates the record postion in the plsql table that should be used to
    get or update the seq values from parent or child record respectively

  p_seq_position:
    Holds values from 1 to 15 to identify the result column name in qa_results

  p_seq_value inout variable:
    When p_action = 1 then parent seq value return back to calling procedure
    When p_action = 2 then parent seq value passed in
*/


 BEGIN

   IF p_seq_position = 1 THEN
     IF p_action = 1 THEN
        p_seq_value := QLTTRAWB.g_seq_tab1(p_cur_record_indicator);
     ELSE
        QLTTRAWB.g_seq_tab1(p_cur_record_indicator):= p_seq_value;
     END IF;


   ELSIF p_seq_position = 2 THEN
     IF p_action = 1 THEN
        p_seq_value := QLTTRAWB.g_seq_tab2(p_cur_record_indicator);
     ELSE
        QLTTRAWB.g_seq_tab2(p_cur_record_indicator):= p_seq_value;
     END IF;

   ELSIF p_seq_position = 3 THEN
     IF p_action = 1 THEN
        p_seq_value := QLTTRAWB.g_seq_tab3(p_cur_record_indicator);
     ELSE
        QLTTRAWB.g_seq_tab3(p_cur_record_indicator):= p_seq_value;
     END IF;

   ELSIF p_seq_position = 4 THEN
     IF p_action = 1 THEN
        p_seq_value := QLTTRAWB.g_seq_tab4(p_cur_record_indicator);
     ELSE
        QLTTRAWB.g_seq_tab4( p_cur_record_indicator):= p_seq_value;
     END IF;

   ELSIF p_seq_position = 5 THEN
     IF p_action = 1 THEN
        p_seq_value := QLTTRAWB.g_seq_tab5(p_cur_record_indicator);
     ELSE
        QLTTRAWB.g_seq_tab5(p_cur_record_indicator):= p_seq_value;
     END IF;

   ELSIF p_seq_position = 6 THEN
     IF p_action = 1 THEN
        p_seq_value := QLTTRAWB.g_seq_tab6(p_cur_record_indicator);
     ELSE
        QLTTRAWB.g_seq_tab6(p_cur_record_indicator):= p_seq_value;
     END IF;

   ELSIF p_seq_position = 7 THEN
     IF p_action = 1 THEN
        p_seq_value := QLTTRAWB.g_seq_tab7(p_cur_record_indicator);
     ELSE
        QLTTRAWB.g_seq_tab7(p_cur_record_indicator):= p_seq_value;
     END IF;

   ELSIF p_seq_position = 8 THEN
     IF p_action = 1 THEN
        p_seq_value := QLTTRAWB.g_seq_tab8(p_cur_record_indicator);
     ELSE
        QLTTRAWB.g_seq_tab8(p_cur_record_indicator):= p_seq_value;
     END IF;

   ELSIF p_seq_position = 9 THEN
     IF p_action = 1 THEN
        p_seq_value := QLTTRAWB.g_seq_tab9(p_cur_record_indicator);
     ELSE
        QLTTRAWB.g_seq_tab9(p_cur_record_indicator):= p_seq_value;
     END IF;

   ELSIF p_seq_position = 10 THEN
     IF p_action = 1 THEN
        p_seq_value := QLTTRAWB.g_seq_tab10(p_cur_record_indicator);
     ELSE
        QLTTRAWB.g_seq_tab10(p_cur_record_indicator):= p_seq_value;
     END IF;

   ELSIF p_seq_position = 11 THEN
     IF p_action = 1 THEN
        p_seq_value := QLTTRAWB.g_seq_tab11(p_cur_record_indicator);
     ELSE
        QLTTRAWB.g_seq_tab11(p_cur_record_indicator):= p_seq_value;
     END IF;

   ELSIF p_seq_position = 12 THEN
     IF p_action = 1 THEN
        p_seq_value := QLTTRAWB.g_seq_tab12(p_cur_record_indicator);
     ELSE
        QLTTRAWB.g_seq_tab12(p_cur_record_indicator):= p_seq_value;
     END IF;

   ELSIF p_seq_position = 13 THEN
     IF p_action = 1 THEN
        p_seq_value := QLTTRAWB.g_seq_tab13(p_cur_record_indicator);
     ELSE
        QLTTRAWB.g_seq_tab13(p_cur_record_indicator):= p_seq_value;
     END IF;


   ELSIF p_seq_position = 14 THEN
     IF p_action = 1 THEN
        p_seq_value := QLTTRAWB.g_seq_tab14(p_cur_record_indicator);
     ELSE
        QLTTRAWB.g_seq_tab14(p_cur_record_indicator):= p_seq_value;
     END IF;

   ELSIF p_seq_position = 15 THEN
     IF p_action = 1 THEN
        p_seq_value := QLTTRAWB.g_seq_tab15(p_cur_record_indicator);
     ELSE
        QLTTRAWB.g_seq_tab15(p_cur_record_indicator):= p_seq_value;
     END IF;
   END IF;

 END find_update_seq_in_collection;

 -- Bug 5114865
 -- New procedure to reset the Sequence
 -- Global Arrays to NULL
 -- nutngare Thu Mar 16 08:33:38 PST 2006
 --
 PROCEDURE reset_sequence_global_arrays AS
 BEGIN
    g_true_seq_gen_recids.delete;
    ParentChild_Tab.delete;
    QLTTRAWB.g_seq_tab1:= NULL;
    QLTTRAWB.g_seq_tab2:= NULL;
    QLTTRAWB.g_seq_tab3:= NULL;
    QLTTRAWB.g_seq_tab4:= NULL;
    QLTTRAWB.g_seq_tab5:= NULL;
    QLTTRAWB.g_seq_tab6:= NULL;
    QLTTRAWB.g_seq_tab7:= NULL;
    QLTTRAWB.g_seq_tab8:= NULL;
    QLTTRAWB.g_seq_tab9:= NULL;
    QLTTRAWB.g_seq_tab10:= NULL;
    QLTTRAWB.g_seq_tab11:= NULL;
    QLTTRAWB.g_seq_tab12:= NULL;
    QLTTRAWB.g_seq_tab13:= NULL;
    QLTTRAWB.g_seq_tab14:= NULL;
    QLTTRAWB.g_seq_tab15:= NULL;
    QLTTRAWB.g_plan_id_tab:= NULL;
    QLTTRAWB.g_collection_id_tab:= NULL;
    QLTTRAWB.g_occurrence_tab:= NULL;
    QLTTRAWB.g_txn_header_id_tab:= NULL;
 END reset_sequence_global_arrays;

 PROCEDURE update_record(p_total_rec_count NUMBER) IS

     l_childUpdate_retval  varchar2(10);
 BEGIN

   -- Bug 5114865
   -- Commented out the update below as the Udpate is
   -- now split between the seq Type elements
   -- and the seq->Char elem relations
   -- ntungare Sun Apr  9 23:43:06 PDT 2006

   -- Bulk update done once for all the records in collection

--    FORALL k IN 1..p_total_rec_count
--      UPDATE qa_results
--      SET sequence1 = QLTTRAWB.g_seq_tab1(k),
--          sequence2 = QLTTRAWB.g_seq_tab2(k),
--          sequence3 = QLTTRAWB.g_seq_tab3(k),
--          sequence4 = QLTTRAWB.g_seq_tab4(k),
--          sequence5 = QLTTRAWB.g_seq_tab5(k),
--          sequence6 = QLTTRAWB.g_seq_tab6(k),
--          sequence7 = QLTTRAWB.g_seq_tab7(k),
--          sequence8 = QLTTRAWB.g_seq_tab8(k),
--          sequence9 = QLTTRAWB.g_seq_tab9(k),
--          sequence10 = QLTTRAWB.g_seq_tab10(k),
--          sequence11 = QLTTRAWB.g_seq_tab11(k),
--          sequence12 = QLTTRAWB.g_seq_tab12(k),
--          sequence13 = QLTTRAWB.g_seq_tab13(k),
--          sequence14 = QLTTRAWB.g_seq_tab14(k),
--          sequence15 = QLTTRAWB.g_seq_tab15(k)
--      WHERE plan_id       = QLTTRAWB.g_plan_id_tab(k) AND
--            collection_id = QLTTRAWB.g_collection_id_tab(k) AND
--            occurrence    = QLTTRAWB.g_occurrence_tab(k);

     --
     -- Bug 5114865
     -- Updating the data for the Seq Type elements
     -- nutngare Sun Apr  9 23:43:06 PDT 2006
     --
     FOR k in 1..g_true_seq_gen_recids.COUNT
      LOOP
        UPDATE qa_results
        SET sequence1 = QLTTRAWB.g_seq_tab1(g_true_seq_gen_recids(k)),
            sequence2 = QLTTRAWB.g_seq_tab2(g_true_seq_gen_recids(k)),
            sequence3 = QLTTRAWB.g_seq_tab3(g_true_seq_gen_recids(k)),
            sequence4 = QLTTRAWB.g_seq_tab4(g_true_seq_gen_recids(k)),
            sequence5 = QLTTRAWB.g_seq_tab5(g_true_seq_gen_recids(k)),
            sequence6 = QLTTRAWB.g_seq_tab6(g_true_seq_gen_recids(k)),
            sequence7 = QLTTRAWB.g_seq_tab7(g_true_seq_gen_recids(k)),
            sequence8 = QLTTRAWB.g_seq_tab8(g_true_seq_gen_recids(k)),
            sequence9 = QLTTRAWB.g_seq_tab9(g_true_seq_gen_recids(k)),
            sequence10 = QLTTRAWB.g_seq_tab10(g_true_seq_gen_recids(k)),
            sequence11 = QLTTRAWB.g_seq_tab11(g_true_seq_gen_recids(k)),
            sequence12 = QLTTRAWB.g_seq_tab12(g_true_seq_gen_recids(k)),
            sequence13 = QLTTRAWB.g_seq_tab13(g_true_seq_gen_recids(k)),
            sequence14 = QLTTRAWB.g_seq_tab14(g_true_seq_gen_recids(k)),
            sequence15 = QLTTRAWB.g_seq_tab15(g_true_seq_gen_recids(k))
        WHERE plan_id       = QLTTRAWB.g_plan_id_tab(g_true_seq_gen_recids(k)) AND
              collection_id = QLTTRAWB.g_collection_id_tab(g_true_seq_gen_recids(k)) AND
              occurrence    = QLTTRAWB.g_occurrence_tab(g_true_seq_gen_recids(k));
     END LOOP;

     -- Bug 5114865
     -- Updating the data for the Seq->Char elem relations
     -- ntungare Sun Apr  9 23:43:06 PDT 2006
     If ParentChild_Tab.COUNT <> 0 THEN
          l_childUpdate_retval := QA_PARENT_CHILD_PKG.update_sequence_child
	                            (p_ParentChild_Tab => ParentChild_Tab);
     End If;

    -- Bug 5114865
    -- Resetting the global Arrays
    -- ntungare Sun Apr  9 23:43:06 PDT 2006
    reset_sequence_global_arrays;

 END update_record;

 FUNCTION get_sequence_default_value RETURN VARCHAR2 IS
 BEGIN

   fnd_message.set_name('QA','QA_SEQ_DEFAULT');
   RETURN fnd_message.get;

 END get_sequence_default_value;


 FUNCTION get_eres_profile   RETURN BOOLEAN IS

  l_eres_profile  VARCHAR2(3);
 BEGIN
   l_eres_profile :=  FND_PROFILE.VALUE('EDR_ERES_ENABLED');

   IF l_eres_profile = 'Y' THEN
      RETURN TRUE;
   ELSE
      RETURN FALSE;
   END IF;

 END get_eres_profile;

 --
 -- bug 5228667
 -- Added the parameters plan id and occurrence
 -- ntungare Thu Aug 17 05:06:15 PDT 2006
 --
 FUNCTION eres_resubmit(p_txn_header_id NUMBER,
                        p_collection_id NUMBER,
                        p_plan_id       NUMBER DEFAULT NULL,
                        p_occurrence    NUMBER DEFAULT NULL)
     RETURN BOOLEAN IS

  -- This procedure return true if any audit record found
  -- for the collection identified by txn_header_id or
  -- collection_id. This scanario happens when eRes resubmits
  -- the same record again. There is no need to generate seq again
  -- since it was generated already.

  l_count  NUMBER;

  CURSOR dde_cursor IS
     SELECT 1 FROM qa_seq_audit_history
     WHERE  txn_header_id = p_txn_header_id
        and (p_plan_id IS NULL OR plan_id = p_plan_id)
        and (p_occurrence IS NULL OR occurrence = p_occurrence);

  CURSOR txn_cursor IS
      SELECT 1 FROM qa_seq_audit_history
      WHERE collection_id = p_collection_id
        and  (p_plan_id IS NULL OR plan_id = p_plan_id)
        and  (p_occurrence IS NULL OR occurrence = p_occurrence);
 BEGIN
    IF p_txn_header_id IS NOT NULL THEN

       OPEN dde_cursor;
       FETCH dde_cursor INTO l_count;
       IF dde_cursor%NOTFOUND THEN
          l_count := 0;
       END IF;
       CLOSE dde_cursor;

    ELSIF p_collection_id IS NOT NULL THEN

       OPEN txn_cursor;
       FETCH txn_cursor INTO l_count;
       IF txn_cursor%NOTFOUND THEN
          l_count := 0;
       END IF;
       CLOSE txn_cursor;
    END IF;

    IF l_count > 0 THEN
       -- means that records are resubmitted. No need to
       -- generate seq again.
       RETURN TRUE;
    ELSE
       RETURN FALSE;
    END IF;

 END eres_resubmit;

 PROCEDURE audit_sequence_values(p_plan_id       NUMBER,
                                 p_collection_id NUMBER,
                                 p_occurrence    NUMBER,
                                 p_enabled_flag  VARCHAR2) IS

  l_child_plan_ids       DBMS_SQL.number_table;
  l_child_collection_ids DBMS_SQL.number_table;
  l_child_occurrences    DBMS_SQL.number_table;

   l_status VARCHAR2(1);
 BEGIN
   -- capture audit only if enabled child records are deleted.
   IF p_enabled_flag <> 'T' THEN
      RETURN;
   END IF;

   -- given the parent record information, find out all the child, grand child
   -- plan ID, coll ID and occurrence

   l_status := QA_PARENT_CHILD_PKG.get_descendants(p_plan_id,
                                                   p_collection_id,
                                                   p_occurrence,
                                                   l_child_plan_ids,
                                                   l_child_collection_ids,
                                                   l_child_occurrences);


   IF (l_status = 'T') THEN

      -- Important thing is, here auditing is not done for the parent record.
      -- This will be done by the client side code

      audit_sequence_values(l_child_plan_ids,
                            l_child_collection_ids,
                            l_child_occurrences,
                            p_plan_id,
                            p_collection_id,
                            p_occurrence);

   END IF;

 END audit_sequence_values;


 PROCEDURE audit_sequence_values(p_plan_ids             DBMS_SQL.number_table,
                                 p_collection_ids       DBMS_SQL.number_table,
                                 p_occurrences          DBMS_SQL.number_table,
                                 p_parent_plan_id       NUMBER,
                                 p_parent_collection_id NUMBER,
                                 p_parent_occurrence    NUMBER) IS

 -- This is overloaded procedure. This will be called when
 -- all the child, grandchild records (that will be deleted along
 -- with parent record ) occurrence, plan ID, coll ID are known.
 -- called from qa_parent_child_pkg

 BEGIN

   -- get all the child, grand child record into collection
   get_all_rec_info_for_audit(p_plan_ids,
                              p_collection_ids,
                              p_occurrences);

   audit_sequence_for_allchild(p_parent_plan_id,
                               p_parent_collection_id,
                               p_parent_occurrence);

   -- Bug 5114865
   -- Resetting the global Arrays
   -- nutngare Thu Mar 16 08:32:48 PST 2006
   reset_sequence_global_arrays;

 EXCEPTION
   WHEN OTHERS THEN
     Raise;
 END audit_sequence_values;

 PROCEDURE get_all_rec_info_for_audit(p_plan_ids       DBMS_SQL.number_table,
                                      p_collection_ids DBMS_SQL.number_table,
                                      p_occurrences    DBMS_SQL.number_table) IS

 -- This procedure is similar to create_recordgroup
 -- pack all the record information into collection

 l_count     NUMBER := 0;
 l_row_count NUMBER;
 i           NUMBER;

 BEGIN
   l_row_count := p_occurrences.COUNT;

   -- initialize all collection objects.
   QLTTRAWB.init_seq_table(l_row_count);

   i := p_occurrences.FIRST;
   WHILE i IS NOT NULL LOOP

     l_count := l_count + 1;

     SELECT occurrence,collection_id,plan_id,txn_header_id,
            sequence1,sequence2,sequence3,
            sequence4,sequence5,sequence6,
            sequence7,sequence8,sequence9,
            sequence10,sequence11,sequence12,
            sequence13,sequence14,sequence15
       INTO
            QLTTRAWB.g_occurrence_tab(l_count), QLTTRAWB.g_collection_id_tab(l_count),
            QLTTRAWB.g_plan_id_tab(l_count),    QLTTRAWB.g_txn_header_id_tab(l_count),
            QLTTRAWB.g_seq_tab1(l_count),  QLTTRAWB.g_seq_tab2(l_count),  QLTTRAWB.g_seq_tab3(l_count),
            QLTTRAWB.g_seq_tab4(l_count),  QLTTRAWB.g_seq_tab5(l_count),  QLTTRAWB.g_seq_tab6(l_count),
            QLTTRAWB.g_seq_tab7(l_count),  QLTTRAWB.g_seq_tab8(l_count),  QLTTRAWB.g_seq_tab9(l_count),
            QLTTRAWB.g_seq_tab10(l_count), QLTTRAWB.g_seq_tab11(l_count), QLTTRAWB.g_seq_tab12(l_count),
            QLTTRAWB.g_seq_tab13(l_count), QLTTRAWB.g_seq_tab14(l_count), QLTTRAWB.g_seq_tab15(l_count)
     FROM   qa_results
     WHERE  plan_id       = p_plan_ids(i) AND
            collection_id = p_collection_ids(i) AND
            occurrence    = p_occurrences(i);
     i := p_occurrences.NEXT(i);

  END LOOP;

 END get_all_rec_info_for_audit;

 PROCEDURE audit_sequence_for_allchild(p_plan_id       NUMBER,
                                       p_collection_id NUMBER,
                                       p_occurrence    NUMBER) IS

   -- Following cursor will not fetch parent record
   -- we are auditing only the child, grand child records.

   CURSOR enabled_child_cur IS
      SELECT child_plan_id,  child_collection_id, child_occurrence,
             parent_plan_id, parent_collection_id, parent_occurrence,
             level
      FROM   qa_pc_results_relationship r
      WHERE EXISTS (
                SELECT 1
                FROM qa_results qr
                WHERE qr.plan_id = r.child_plan_id AND
                      qr.collection_id = r.child_collection_id AND
                      qr.occurrence = r.child_occurrence AND
                      (qr.status IS NULL or qr.status=2) )
      START WITH r.parent_plan_id         = p_plan_id AND
                 r.parent_collection_id   = p_collection_id AND
                 r.parent_occurrence      = p_occurrence
      CONNECT BY PRIOR r.child_occurrence = r.parent_occurrence
      ORDER BY level;

 BEGIN

   FOR child_rec IN enabled_child_cur LOOP

      -- audit one record at a time
      audit_sequence_for_currec(child_rec.child_plan_id,
                                child_rec.child_collection_id,
                                child_rec.child_occurrence,
                                child_rec.parent_plan_id,
                                child_rec.parent_collection_id,
                                child_rec.parent_occurrence);

   END LOOP;

 END audit_sequence_for_allchild;

 PROCEDURE audit_sequence_for_currec(p_plan_id               NUMBER,
                                     p_collection_id         NUMBER,
                                     p_occurrence            NUMBER,
                                     p_parent_plan_id        NUMBER,
                                     p_parent_collection_id  NUMBER,
                                     p_parent_occurrence     NUMBER) IS

  -- This procedure will be called for normal deletion of parent records
  -- from FORM.

  i                   NUMBER;
  l_cur_rec_indicator NUMBER;
  l_seq_value         VARCHAR2(40);
  l_seq_default_value VARCHAR2(40);
  l_user_id  NUMBER;
  l_login_id NUMBER;
  l_date     DATE;

 BEGIN

   l_user_id  := fnd_global.user_id;
   l_login_id := fnd_global.login_id;
   l_date     := SYSDATE;

   FOR j IN 1..QLTTRAWB.g_occurrence_tab.count LOOP

     IF QLTTRAWB.g_occurrence_tab(j) = p_occurrence THEN
        l_cur_rec_indicator := j;
     END IF;
   END LOOP;

   get_plan_seq_ele_setup(p_plan_id,p_parent_plan_id);

   i := g_curr_plan_seq_char_ids.FIRST;

   l_seq_default_value := get_sequence_default_value();

   WHILE i IS NOT NULL LOOP

        IF NOT g_parent_plan_seq_char_ids.EXISTS(i) THEN -- No copy releation exist

          -- get sequence element value
          find_update_seq_in_collection(l_cur_rec_indicator,
                                        i,
                                        1,
                                        l_seq_value);
          -- capture audit only if seq. element contains pre generated
          -- sequence value
          IF (l_seq_value IS NOT NULL) AND  (l_seq_value <> l_seq_default_value ) THEN
             sequence_audit_log(
                             p_plan_id           => p_plan_id,
                             p_collection_id     => p_collection_id,
                             p_occurrence        => p_occurrence,
                             p_char_id           => g_curr_plan_seq_char_ids(i),
                             p_txn_header_id     => QLTTRAWB.g_txn_header_id_tab(l_cur_rec_indicator),
                             p_sequence_value    => l_seq_value,
                             p_user_id           => l_user_id,
                             p_source_code       => 'EQR',
                             p_source_id         => NULL,
                             p_audit_type        => 'DELETED',
                             p_audit_date        => l_date,
                             p_last_update_date  => l_date,
                             p_last_updated_by   => l_user_id,
                             p_creation_date     => l_date,
                             p_created_by        => l_user_id,
                             p_last_update_login => l_login_id);
          END IF;
        END IF;

        i := g_curr_plan_seq_char_ids.NEXT(i); -- get the next subscript

   END LOOP;
 END audit_sequence_for_currec;

 PROCEDURE audit_seq_for_eres(p_char_id           NUMBER,
                              p_seq_value         VARCHAR2,
                              p_cur_rec_indicator NUMBER) IS
  l_user_id  NUMBER;
  l_login_id NUMBER;
  l_date     DATE;
 BEGIN

   l_user_id  := fnd_global.user_id;
   l_login_id := fnd_global.login_id;
   l_date     := SYSDATE;

   sequence_audit_log(
               p_plan_id           => QLTTRAWB.g_plan_id_tab(p_cur_rec_indicator),
               p_collection_id     => QLTTRAWB.g_collection_id_tab(p_cur_rec_indicator),
               p_occurrence        => QLTTRAWB.g_occurrence_tab(p_cur_rec_indicator),
               p_char_id           => p_char_id,
               p_txn_header_id     => QLTTRAWB.g_txn_header_id_tab(p_cur_rec_indicator),
               p_sequence_value    => p_seq_value,
               p_user_id           => l_user_id,
               p_source_code       => 'EDR', -- ERES
               p_source_id         => NULL, -- eRes ID not generated at this time
               p_audit_type        => 'CREATED',
               p_audit_date        => l_date,
               p_last_update_date  => l_date,
               p_last_updated_by   => l_user_id,
               p_creation_date     => l_date,
               p_created_by        => l_user_id,
               p_last_update_login => l_login_id);

 END audit_seq_for_eres;

 PROCEDURE sequence_audit_log(p_plan_id           NUMBER,
                              p_collection_id     NUMBER,
                              p_occurrence        NUMBER,
                              p_char_id           NUMBER,
                              p_txn_header_id     NUMBER,
                              p_sequence_value    VARCHAR2,
                              p_user_id           NUMBER,
                              p_source_code       VARCHAR2,
                              p_source_id         NUMBER,
                              p_audit_type        VARCHAR2,
                              p_audit_date        DATE,
                              p_last_update_date  DATE,
                              p_last_updated_by   NUMBER,
                              p_creation_date     DATE,
                              p_created_by        NUMBER,
                              p_last_update_login NUMBER) IS

  l_rowid VARCHAR2(18) := NULL;

 BEGIN
  QA_SEQ_AUDIT_PKG.insert_row(
                       P_Rowid               => l_rowid,
                       P_Plan_Id             => p_plan_id,
                       P_Collection_Id       => p_collection_id,
                       P_Occurrence          => p_occurrence,
                       P_Char_Id             => p_char_id,
                       P_Txn_Header_Id       => p_txn_header_id,
                       P_Sequence_Value      => p_sequence_value,
                       P_User_Id             => p_user_id,
                       P_Source_Code         => p_source_code,
                       P_Source_Id           => p_source_id,
                       P_Audit_Type          => p_audit_type,
                       P_Audit_Date          => p_audit_date,
                       P_Last_Update_Date    => p_last_update_date,
                       P_Last_Updated_By     => p_last_updated_by,
                       P_Creation_Date       => p_creation_date,
                       P_Created_By          => p_created_by,
                       P_Last_Update_Login   => p_last_update_login);

 END sequence_audit_log;

 PROCEDURE delete_auditinfo_for_Txn(p_collection_id NUMBER) IS

 -- This procedure is called by eRecords in TXN Mode.
 -- For a txn if eRecords are enabled, sequence are generated before
 -- eRecord information shown to the user. At sequence generation, we
 -- are capturing audit info. for each sequence value generated.
 -- If eRecord is accepted then we need to delete the audit information
 -- that got captured at generation. If eRecords rejected by user then
 -- leave the audit info. as it was.
 BEGIN

   DELETE FROM qa_seq_audit_history
   WHERE collection_id = p_collection_id;
 EXCEPTION
   WHEN OTHERS THEN raise;

 END delete_auditinfo_for_Txn;

 PROCEDURE delete_auditinfo_for_DDE(p_txn_header_id NUMBER) IS

 -- This procedure is called by eRecords in DDE scanario and is
 -- similar to delete_audit_for_Txn(see this proc. for details).

 BEGIN

   DELETE FROM qa_seq_audit_history
   WHERE txn_header_id = p_txn_header_id;
 EXCEPTION
   WHEN OTHERS THEN raise;

 END delete_auditinfo_for_DDE;

 -- Gapless Sequence Proj End

 --Bug 3160651. Code change Start. rponnusa Thu Sep 25 02:24:28 PDT 2003

 PROCEDURE generate_seq_for_DDE(p_txn_header_id             NUMBER,
                                p_plan_id                   NUMBER,
                                p_return_status  OUT NOCOPY VARCHAR2,
                                x_message        OUT NOCOPY VARCHAR2) IS

  -- This is overloaded procedure. Called from self service EQR.
  -- Once the seq. numbers are generated, acknowledgement needs to
  -- shown with the newly generated seq. values,plan name,element prompt
  -- to the user. For this message string needs to be returned back to
  -- caller. The x_message string will take the format
  -- <plan_name> <char_prompt>=<value>@<plan_name> <char_prompt>=<value>@...

  i            NUMBER;
  l_separator  VARCHAR2(1) := ':';
  l_delimiter  VARCHAR2(1) := '@';

 BEGIN

   -- flush off any unnecessary values.
   g_message_array.DELETE;

   generate_seq_for_DDE(p_txn_header_id,
                        p_plan_id,
                        p_return_status);

   i := g_message_array.FIRST;
   WHILE i <= g_message_array.LAST LOOP

     -- loop thro' the array and formulate the msg. in required order.
     x_message := x_message || l_delimiter ||
                               g_message_array(i).plan_name || l_separator ||
                               g_message_array(i).element_prompt || '=' ||
                               g_message_array(i).sequence_value;

     i := g_message_array.NEXT(i);
   END LOOP;

   x_message := substr(x_message,2);  -- remove the starting '@' char.

 END generate_seq_for_DDE;

 PROCEDURE get_all_char_prompt_info(p_plan_id NUMBER) IS

  -- Pack all the sequence element 'prompt' names for the plan
  -- into global plsql table.

  CURSOR prompt_cur IS
    SELECT qpc.prompt,qpc.char_id
    FROM   qa_plan_chars qpc,
           qa_chars qc
    WHERE  qpc.plan_id = p_plan_id
    AND    qpc.char_id = qc.char_id
    AND    qc.datatype = 5;

 BEGIN
   -- delete all the existing values from the collection.
   g_prompt_tab.DELETE;

   FOR i IN prompt_cur LOOP
       g_prompt_tab(i.char_id) := i.prompt;
   END LOOP;
 END get_all_char_prompt_info;

 PROCEDURE populate_message_array(p_char_id   NUMBER,
                                  p_seq_value VARCHAR2,
                                  p_plan_name VARCHAR2) IS
   l_message_index  NUMBER;
 BEGIN
   l_message_index := g_message_array.count;

   g_message_array(l_message_index).plan_name  := p_plan_name;
   g_message_array(l_message_index).sequence_value := p_seq_value;
   g_message_array(l_message_index).element_prompt := g_prompt_tab(p_char_id);

 END populate_message_array;

 --Bug 3160651. Code change end. rponnusa Thu Sep 25 02:24:28 PDT 2003

  -- Bug 5368983. Generating Sequence Number for OA Txn Integration Flows.
  -- saugupta Fri, 01 Sep 2006 02:24:09 -0700 PDT
  PROCEDURE generate_seq_for_txninteg(p_collection_id IN NUMBER,
                                      p_return_status OUT nocopy VARCHAR2,
                                      x_message OUT nocopy VARCHAR2) IS

      CURSOR all_plan_cur IS
      SELECT DISTINCT qr.plan_id
      FROM qa_results qr
      WHERE qr.collection_id = p_collection_id
       AND NOT EXISTS
        (SELECT 1
         FROM qa_pc_results_relationship qprr
         WHERE qprr.child_plan_id = qr.plan_id
         AND qprr.child_collection_id = qr.collection_id
         AND qprr.child_occurrence = qr.occurrence);

      i NUMBER;
      l_row_count NUMBER;
      l_separator VARCHAR2(1) := ':';
      l_delimiter VARCHAR2(1) := '@';
      l_module constant VARCHAR2(200) := g_module_name || '.generate_seq_for_txninteg';

  BEGIN

    IF(fnd_log.level_procedure >= fnd_log.g_current_runtime_level) THEN
      fnd_log.string(fnd_log.level_procedure,   l_module,
                      'Generating sequence for collection_id = ' || p_collection_id);
    END IF;

    --  Initialize return status to success
    p_return_status := fnd_api.g_ret_sts_success;
    -- initialize fnd message table, this is used by self-service api
    fnd_msg_pub.initialize;

    -- flush off any unnecessary values from sequence message array
    g_message_array.DELETE;

    IF(fnd_log.level_statement >= fnd_log.g_current_runtime_level) THEN
      fnd_log.string(fnd_log.level_statement,   l_module,   'Calling get_all_record_info ');
    END IF;

    -- Pack all the sequence values in the data collection into plsql table
    l_row_count := get_all_record_info(p_collection_id,   NULL);

    IF l_row_count = 0 THEN
      RETURN;
    END IF;

    IF(fnd_log.level_statement >= fnd_log.g_current_runtime_level) THEN
      fnd_log.string(fnd_log.level_statement,   l_module,   'Looping through all the plans');
    END IF;

    FOR plan_rec IN all_plan_cur
    LOOP

      -- Generate seq value or copy seq value from parent to child rec.
      -- this should be done for all the parent rec and its all child,
      -- grandchild.. records

      IF(fnd_log.level_statement >= fnd_log.g_current_runtime_level) THEN
        fnd_log.string(fnd_log.level_statement,   l_module,
                          'Calling generate_seq_for_pc for plan_id = ' || plan_rec.plan_id);
      END IF;

      generate_seq_for_pc(plan_rec.plan_id,   p_collection_id,   NULL,   TRUE);

    END LOOP;

    -- loop thro' the array and formulate the msg. in required order.
    i := g_message_array.FIRST;
    WHILE i <= g_message_array.LAST
    LOOP
      x_message := x_message || l_delimiter || g_message_array(i).plan_name
                             || l_separator || g_message_array(i).element_prompt
                             || '=' || g_message_array(i).sequence_value;
      i := g_message_array.NEXT(i);
    END LOOP;

    -- remove the starting '@' char.
    x_message := SUBSTR(x_message,   2);


    IF(fnd_log.level_statement >= fnd_log.g_current_runtime_level) THEN
      fnd_log.string(fnd_log.level_statement,   l_module,
                      'Sequence message for Applicable Plans Page ' || x_message);
    END IF;

    -- Now use bulk update to update all seq. values into qa_results for all the
    -- records in the data collection
    update_record(l_row_count);

    IF(fnd_log.level_statement >= fnd_log.g_current_runtime_level) THEN
      fnd_log.string(fnd_log.level_statement,   l_module,
                      'Called update_record with row count ' || l_row_count);
    END IF;

  -- reflect the changes in inline region, so commit
  -- saugupta Wed, 05 Dec 2007 03:58:03 -0800 PDT
  commit;

  EXCEPTION
      WHEN others THEN
        p_return_status := fnd_api.g_ret_sts_unexp_error;
        fnd_message.set_name('QA',   'QA_SEQ_GENERATION_ERROR');
        fnd_msg_pub.ADD();

  END generate_seq_for_txninteg;

  -- Bug 5368983. Added for auditing sequence in OA Txn integ flows.
  -- saugupta Fri, 01 Sep 2006 02:33:22 -0700 PDT
  --
  -- Bug 5955808
  -- Added a new parameter to take in the Module name
  -- to be set at the time of auditing the sequences
  -- ntungare Thu Jul 26 02:55:50 PDT 2007
  --
  PROCEDURE audit_seq_for_txnint(p_char_id NUMBER,
                                 p_seq_value VARCHAR2,
                                 p_cur_rec_indicator NUMBER,
                                 p_module  VARCHAR2 DEFAULT 'OATXNINT') IS

    l_user_id NUMBER;
    l_login_id NUMBER;
    l_date DATE;
    l_module VARCHAR2(2000);

  BEGIN
    If p_module = 'MOBILE' THEN
       l_module := g_module_name || '.audit_seq_for_mobile';
    Else
       l_module := g_module_name || '.audit_seq_for_txnint';
    End If;

    l_user_id := fnd_global.user_id;
    l_login_id := fnd_global.login_id;
    l_date := sysdate;

    IF(fnd_log.level_statement >= fnd_log.g_current_runtime_level) THEN
      fnd_log.string(fnd_log.level_statement,   l_module,
                     'Auditing for char_id = ' || p_char_id
                     || ' Seq val = ' || p_seq_value);
    END IF;

    sequence_audit_log(
          p_plan_id => qlttrawb.g_plan_id_tab(p_cur_rec_indicator),
          p_collection_id => qlttrawb.g_collection_id_tab(p_cur_rec_indicator),
          p_occurrence => qlttrawb.g_occurrence_tab(p_cur_rec_indicator),
          p_char_id => p_char_id,
          p_txn_header_id => qlttrawb.g_txn_header_id_tab(p_cur_rec_indicator),
          p_sequence_value => p_seq_value,
          p_user_id => l_user_id,
          p_source_code => p_module,   -- OA Transaction Integration /Mobile
          p_source_id => NULL,  -- Parent transaction not committed till this time
          p_audit_type => 'CREATED',
          p_audit_date => l_date,
          p_last_update_date => l_date,
          p_last_updated_by => l_user_id,
          p_creation_date => l_date,
          p_created_by => l_user_id,
          p_last_update_login => l_login_id);

  END audit_seq_for_txnint;

  -- Bug 5368983. Code changes end

  --
  -- Bug 5955808
  -- New procedure to generate sequences in Mobile Txn
  -- This has an additonal message parameter that would
  -- return the generated message string to the calling
  -- Java program for displaying on the Mobile message
  -- page
  -- ntungare Mon Jul 23 11:10:18 PDT 2007
  --
  PROCEDURE generate_seq_for_txn(p_collection_id             NUMBER,
                                 p_return_status  OUT NOCOPY VARCHAR2,
                                 x_message        OUT NOCOPY VARCHAR2) IS

   -- This is overloaded procedure. Called from Mobile.
   -- Once the seq. numbers are generated, acknowledgement needs to
   -- shown with the newly generated seq. values,plan name,element prompt
   -- to the user. For this message string needs to be returned back to
   -- caller. The x_message string will take the format
   -- (cntr)<plan_name> [<char_prompt> (<value>,<value>) <char_prompt> (<value>,<value>)], (cntr)<plan_name> ..
   -- eg. (1)NT_P1 [NT_SEQ1(100,110) ,NT_SEQ2(11,12) ], (2)NT_P2 [NT_SEQ1(120) ,NT_SEQ2(13) ]

   i          VARCHAR2(200);
   j          BINARY_INTEGER;

   mesg_ctr   NUMBER := 1;
   plan_ctr   NUMBER := 1;

   prev_plan  VARCHAR2(200);

   Type seq_tab_typ is table of varchar2(2000) index by varchar2(200);
   seq_tab seq_tab_typ;

  BEGIN
    g_mobile := TRUE;

    -- flush off any unnecessary values.
    g_message_array.DELETE;

    generate_seq_for_txn(p_collection_id,
                         p_return_status);

    -- Formatting of the message string
    x_message := ' ';
    If  g_message_array.count <> 0 Then
       j := g_message_array.FIRST;

       seq_tab(g_message_array(j).element_prompt) := g_message_array(j).sequence_value;
       prev_plan := g_message_array(j).plan_name;
       x_message := '(' || plan_ctr || ')' || prev_plan || ' [';

       j := g_message_array.next(j);

       -- Looping through all the plans in the message array
       WHILE j <= g_message_array.LAST LOOP
         If (g_message_array(j).plan_name = prev_plan)
            then
               -- Cumulating the sequences over the elements
               If seq_tab.exists(g_message_array(j).element_prompt) THEN
                  seq_tab(g_message_array(j).element_prompt) := seq_tab(g_message_array(j).element_prompt) || ',' ||
                                                                g_message_array(j).sequence_value;
               ELSE
                  seq_tab(g_message_array(j).element_prompt) := g_message_array(j).sequence_value;
               END If;
            else
               If seq_tab.count <>0 then
               i := seq_tab.first;
               while i <= seq_tab.last
                 loop
                    -- Building message string
                    x_message := x_message || i || '(' || seq_tab(i) || ') ,';
                    i := seq_tab.next(i);
                 end loop;
               x_message := rtrim(x_message,',');
               seq_tab.delete;
               end If;
               prev_plan := g_message_array(j).plan_name;
               plan_ctr := plan_ctr +1;
               seq_tab(g_message_array(j).element_prompt) := g_message_array(j).sequence_value;
               x_message := x_message || '], (' || plan_ctr || ')' || prev_plan || ' [';
         end If;
         j := g_message_array.next(j);
       end Loop;

       If seq_tab.count <>0 then
         i := seq_tab.first;
         While i <= seq_tab.last
           Loop
              x_message := x_message || i || '(' || seq_tab(i) || ') ,';
              i := seq_tab.next(i);
           End Loop;

         x_message := rtrim(x_message,',') || ']';
       end If;
       x_message := 'Following Sequences were generated:' || x_message;
    end If;
  END generate_seq_for_txn;


END QA_SEQUENCE_API;

/
