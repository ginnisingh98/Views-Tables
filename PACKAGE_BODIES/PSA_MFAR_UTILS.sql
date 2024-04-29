--------------------------------------------------------
--  DDL for Package Body PSA_MFAR_UTILS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PSA_MFAR_UTILS" AS
/* $Header: PSAMFUTB.pls 120.12 2006/09/13 14:06:36 agovil ship $ */


--
-- Private procedures/functions/variables
--

--===========================FND_LOG.START=====================================
g_state_level NUMBER	:=	FND_LOG.LEVEL_STATEMENT;
g_proc_level  NUMBER	:=	FND_LOG.LEVEL_PROCEDURE;
g_event_level NUMBER	:=	FND_LOG.LEVEL_EVENT;
g_excep_level NUMBER	:=	FND_LOG.LEVEL_EXCEPTION;
g_error_level NUMBER	:=	FND_LOG.LEVEL_ERROR;
g_unexp_level NUMBER	:=	FND_LOG.LEVEL_UNEXPECTED;
g_path        VARCHAR2(50)  := 'PSA.PLSQL.PSAMFUTB.PSA_MFAR_UTILS.';
--===========================FND_LOG.END=======================================

FUNCTION GET_MAPPED_ACCOUNT (p_transaction_type	    IN VARCHAR2,
			         p_natural_account      IN VARCHAR2,
			         p_set_of_books_id      IN NUMBER,
			         p_chart_of_accounts_id IN NUMBER )
RETURN VARCHAR2;

l_org_id NUMBER;


--
-- ## This procedure will called when ccid details have to be
-- ## inserted into a PL/SQL Table.
--

PROCEDURE insert_ccid (p_ccid         IN NUMBER,
                       p_segment_info IN FND_FLEX_EXT.SEGMENTARRAY,
                       p_num_segments IN NUMBER)
IS
    l_count number := 0;
    l_segment_info FND_FLEX_EXT.SEGMENTARRAY;

    -- ========================= FND LOG ===========================
       l_full_path VARCHAR2(1000) := g_path || 'insert_ccid.';
    -- ========================= FND LOG ===========================

BEGIN
    l_count := nvl(ccid_info.count,0) + 1;
    l_segment_info := p_segment_info;

  -- ========================= FND LOG ===========================
     psa_utils.debug_other_string(g_state_level,l_full_path,' Inside insert_ccid ');
     psa_utils.debug_other_string(g_state_level,l_full_path,' PARAMETERS: ');
     psa_utils.debug_other_string(g_state_level,l_full_path,' =========== ');
     psa_utils.debug_other_string(g_state_level,l_full_path,' p_ccid         --> ' || p_ccid);
    psa_utils.debug_other_string(g_state_level,l_full_path,' p_num_segments  --> ' || p_num_segments);
     FOR i IN (p_num_segments+1)..30
     LOOP
        l_segment_info(i) := NULL;
     END LOOP;

     ccid_info(l_count).segment1 := l_segment_info(1);
     ccid_info(l_count).segment2 := l_segment_info(2);
     ccid_info(l_count).segment3 := l_segment_info(3);
     ccid_info(l_count).segment4 := l_segment_info(4);
     ccid_info(l_count).segment5 := l_segment_info(5);
     ccid_info(l_count).segment6 := l_segment_info(6);
     ccid_info(l_count).segment7 := l_segment_info(7);
     ccid_info(l_count).segment8 := l_segment_info(8);
     ccid_info(l_count).segment9 := l_segment_info(9);
     ccid_info(l_count).segment10 := l_segment_info(10);
     ccid_info(l_count).segment11 := l_segment_info(11);
     ccid_info(l_count).segment12 := l_segment_info(12);
     ccid_info(l_count).segment13 := l_segment_info(13);
     ccid_info(l_count).segment14 := l_segment_info(14);
     ccid_info(l_count).segment15 := l_segment_info(15);
     ccid_info(l_count).segment16 := l_segment_info(16);
     ccid_info(l_count).segment17 := l_segment_info(17);
     ccid_info(l_count).segment18 := l_segment_info(18);
     ccid_info(l_count).segment19 := l_segment_info(19);
     ccid_info(l_count).segment20 := l_segment_info(20);
     ccid_info(l_count).segment21 := l_segment_info(21);
     ccid_info(l_count).segment22 := l_segment_info(22);
     ccid_info(l_count).segment23 := l_segment_info(23);
     ccid_info(l_count).segment24 := l_segment_info(24);
     ccid_info(l_count).segment25 := l_segment_info(25);
     ccid_info(l_count).segment26 := l_segment_info(26);
     ccid_info(l_count).segment27 := l_segment_info(27);
     ccid_info(l_count).segment28 := l_segment_info(28);
     ccid_info(l_count).segment29 := l_segment_info(29);
     ccid_info(l_count).segment30 := l_segment_info(30);
    FOR i IN 1..30 LOOP
        psa_utils.debug_other_string(g_state_level,l_full_path,' segment'||i||'   --> ' ||l_segment_info(i) );
    END LOOP;

     psa_utils.debug_other_string(g_state_level,l_full_path,' p_num_segments   --> ' || p_num_segments );
  -- ========================= FND LOG ===========================

--    l_count := nvl(ccid_info.count,0) + 1;

  -- ========================= FND LOG ===========================
     psa_utils.debug_other_string(g_state_level,l_full_path,' l_count -> ' || l_count);
  -- ========================= FND LOG ===========================

    ccid_info(l_count).ccid     := p_ccid;
    ccid_info(l_count).number_of_segments := p_num_segments;

    -- ========================= FND LOG ===========================
       psa_utils.debug_other_string(g_state_level,l_full_path,' END - insert ccid ');
    -- ========================= FND LOG ===========================

 EXCEPTION
    WHEN OTHERS THEN
         -- ========================= FND LOG ===========================
            psa_utils.debug_other_string(g_excep_level,l_full_path,'EXCEPTION - OTHERS : ERROR IN PSA_MFAR_UTILS.insert_ccid');
            psa_utils.debug_other_string(g_excep_level,l_full_path, sqlcode || sqlerrm);
            psa_utils.debug_unexpected_msg(l_full_path);
         -- ========================= FND LOG ===========================
	  APP_EXCEPTION.RAISE_EXCEPTION;

End insert_ccid;

/* ================================ IS_CCID_EXISTS ============================= */

--
-- ## This function will check whether the ccid exists in the PL/SQL table
-- ## if it exists then this will return TRUE, Otherwise FALSE
-- ## It also return ccid and the segment details if it exist in the table
--

Function is_ccid_exists(x_ccid               IN OUT  NOCOPY NUMBER,
                        x_segment_info       IN OUT  NOCOPY FND_FLEX_EXT.SEGMENTARRAY,
                        x_number_of_segments OUT NOCOPY NUMBER) return BOOLEAN
IS

    l_count NUMBER;
    l_no_match NUMBER;
    l_segment_info FND_FLEX_EXT.SEGMENTARRAY;

    -- ========================= FND LOG ===========================
       l_full_path VARCHAR2(100) := g_path || 'is_ccid_exists.';
    -- ========================= FND LOG ===========================

BEGIN

  -- ========================= FND LOG ===========================
     psa_utils.debug_other_string(g_state_level,l_full_path,' Inside is_ccid_exists ');
     psa_utils.debug_other_string(g_state_level,l_full_path,' PARAMETERS: ');
     psa_utils.debug_other_string(g_state_level,l_full_path,' =========== ');
     psa_utils.debug_other_string(g_state_level,l_full_path,' x_ccid           --> ' || x_ccid);
     FOR I IN 1..x_segment_info.count
     LOOP
       psa_utils.debug_other_string(g_state_level,l_full_path,' x_segment_info   --> ' || x_segment_info(I) );
     END LOOP;
     psa_utils.debug_other_string(g_state_level,l_full_path,' x_number_of_segments   --> ' || x_number_of_segments );
  -- ========================= FND LOG ===========================

  l_count := ccid_info.count;

  -- ========================= FND LOG ===========================
     psa_utils.debug_other_string(g_state_level,l_full_path,' l_count -> ' || l_count);
  -- ========================= FND LOG ===========================

  IF x_ccid IS NOT NULL THEN

     -- ========================= FND LOG ===========================
        psa_utils.debug_other_string(g_state_level,l_full_path,' x_ccid IS NOT NULL ');
     -- ========================= FND LOG ===========================

     FOR I IN 1..l_count
     LOOP

       -- ========================= FND LOG ===========================
          psa_utils.debug_other_string(g_state_level,l_full_path, nvl(ccid_info(I).ccid,-1) || '=' || x_ccid);
       -- ========================= FND LOG ===========================

       IF nvl(ccid_info(I).ccid,-1) = x_ccid THEN
          IF ccid_info(I).segment1 IS NOT NULL THEN x_segment_info(1) := ccid_info(I).segment1; END IF;
          IF ccid_info(I).segment2 IS NOT NULL THEN x_segment_info(2) := ccid_info(I).segment2; END IF;
          IF ccid_info(I).segment3 IS NOT NULL THEN x_segment_info(3) := ccid_info(I).segment3; END IF;
          IF ccid_info(I).segment4 IS NOT NULL THEN x_segment_info(4) := ccid_info(I).segment4; END IF;
          IF ccid_info(I).segment5 IS NOT NULL THEN x_segment_info(5) := ccid_info(I).segment5; END IF;
          IF ccid_info(I).segment6 IS NOT NULL THEN x_segment_info(6) := ccid_info(I).segment6; END IF;
          IF ccid_info(I).segment7 IS NOT NULL THEN x_segment_info(7) := ccid_info(I).segment7; END IF;
          IF ccid_info(I).segment8 IS NOT NULL THEN x_segment_info(8) := ccid_info(I).segment8; END IF;
          IF ccid_info(I).segment9 IS NOT NULL THEN x_segment_info(9) := ccid_info(I).segment9; END IF;
          IF ccid_info(I).segment10 IS NOT NULL THEN x_segment_info(10) := ccid_info(I).segment10; END IF;
          IF ccid_info(I).segment11 IS NOT NULL THEN x_segment_info(11) := ccid_info(I).segment11; END IF;
          IF ccid_info(I).segment12 IS NOT NULL THEN x_segment_info(12) := ccid_info(I).segment12; END IF;
          IF ccid_info(I).segment13 IS NOT NULL THEN x_segment_info(13) := ccid_info(I).segment13; END IF;
          IF ccid_info(I).segment14 IS NOT NULL THEN x_segment_info(14) := ccid_info(I).segment14; END IF;
          IF ccid_info(I).segment15 IS NOT NULL THEN x_segment_info(15) := ccid_info(I).segment15; END IF;
          IF ccid_info(I).segment16 IS NOT NULL THEN x_segment_info(16) := ccid_info(I).segment16; END IF;
          IF ccid_info(I).segment17 IS NOT NULL THEN x_segment_info(17) := ccid_info(I).segment17; END IF;
          IF ccid_info(I).segment18 IS NOT NULL THEN x_segment_info(18) := ccid_info(I).segment18; END IF;
          IF ccid_info(I).segment19 IS NOT NULL THEN x_segment_info(19) := ccid_info(I).segment19; END IF;
          IF ccid_info(I).segment20 IS NOT NULL THEN x_segment_info(20) := ccid_info(I).segment20; END IF;
          IF ccid_info(I).segment21 IS NOT NULL THEN x_segment_info(21) := ccid_info(I).segment21; END IF;
          IF ccid_info(I).segment22 IS NOT NULL THEN x_segment_info(22) := ccid_info(I).segment22; END IF;
          IF ccid_info(I).segment23 IS NOT NULL THEN x_segment_info(23) := ccid_info(I).segment23; END IF;
          IF ccid_info(I).segment24 IS NOT NULL THEN x_segment_info(24) := ccid_info(I).segment24; END IF;
          IF ccid_info(I).segment25 IS NOT NULL THEN x_segment_info(25) := ccid_info(I).segment25; END IF;
          IF ccid_info(I).segment26 IS NOT NULL THEN x_segment_info(26) := ccid_info(I).segment26; END IF;
          IF ccid_info(I).segment27 IS NOT NULL THEN x_segment_info(27) := ccid_info(I).segment27; END IF;
          IF ccid_info(I).segment28 IS NOT NULL THEN x_segment_info(28) := ccid_info(I).segment28; END IF;
          IF ccid_info(I).segment29 IS NOT NULL THEN x_segment_info(29) := ccid_info(I).segment29; END IF;
          IF ccid_info(I).segment30 IS NOT NULL THEN x_segment_info(30) := ccid_info(I).segment30; END IF;

          x_number_of_segments := ccid_info(I).number_of_segments;

         -- ========================= FND LOG ===========================
            psa_utils.debug_other_string(g_state_level,l_full_path,' x_number_of_segments -> ' || x_number_of_segments);
            FOR I IN 1..x_number_of_segments
            LOOP
              psa_utils.debug_other_string(g_state_level,l_full_path,' x_segment_info   --> ' || x_segment_info(I) );
            END LOOP;
            psa_utils.debug_other_string(g_state_level,l_full_path,'RETURN -> TRUE');
         -- ========================= FND LOG ===========================

          RETURN TRUE;

       END IF;

     END LOOP;

     -- ========================= FND LOG ===========================
        psa_utils.debug_other_string(g_state_level,l_full_path,' RETURN -> FALSE');
     -- ========================= FND LOG ===========================
     RETURN FALSE;

   ELSE

     -- ========================= FND LOG ===========================
        psa_utils.debug_other_string(g_state_level,l_full_path,' x_ccid IS NULL ');
     -- ========================= FND LOG ===========================

     l_segment_info := x_segment_info;

     -- ========================= FND LOG ===========================
        psa_utils.debug_other_string(g_state_level,l_full_path,' Number of segments : '||l_segment_info.count);
     -- ========================= FND LOG ===========================

       FOR J IN (x_segment_info.count + 1)..30
       LOOP
            l_segment_info(J) := NULL;
       END LOOP;

     FOR I IN 1..ccid_info.count
     LOOP
        l_no_match := 0;

       IF ((l_segment_info(1) IS NOT NULL AND ccid_info(I).segment1 <> l_segment_info(1))
       OR (l_segment_info(2) IS NOT NULL AND ccid_info(I).segment2 <> l_segment_info(2))
       OR (l_segment_info(3) IS NOT NULL AND ccid_info(I).segment3 <> l_segment_info(3))
       OR (l_segment_info(4) IS NOT NULL AND ccid_info(I).segment4 <> l_segment_info(4))
       OR (l_segment_info(5) IS NOT NULL AND ccid_info(I).segment5 <> l_segment_info(5))
       OR (l_segment_info(6) IS NOT NULL AND ccid_info(I).segment6 <> l_segment_info(6))
       OR (l_segment_info(7) IS NOT NULL AND ccid_info(I).segment7 <> l_segment_info(7))
       OR (l_segment_info(8) IS NOT NULL AND ccid_info(I).segment8 <> l_segment_info(8))
       OR (l_segment_info(9) IS NOT NULL AND ccid_info(I).segment9 <> l_segment_info(9))
       OR (l_segment_info(10) IS NOT NULL AND ccid_info(I).segment10 <> l_segment_info(10))
       OR (l_segment_info(11) IS NOT NULL AND ccid_info(I).segment11 <> l_segment_info(11))
       OR (l_segment_info(12) IS NOT NULL AND ccid_info(I).segment12 <> l_segment_info(12))
       OR (l_segment_info(13) IS NOT NULL AND ccid_info(I).segment13 <> l_segment_info(13))
       OR (l_segment_info(14) IS NOT NULL AND ccid_info(I).segment14 <> l_segment_info(14))
       OR (l_segment_info(15) IS NOT NULL AND ccid_info(I).segment15 <> l_segment_info(15))
       OR (l_segment_info(16) IS NOT NULL AND ccid_info(I).segment16 <> l_segment_info(16))
       OR (l_segment_info(17) IS NOT NULL AND ccid_info(I).segment17 <> l_segment_info(17))
       OR (l_segment_info(18) IS NOT NULL AND ccid_info(I).segment18 <> l_segment_info(18))
       OR (l_segment_info(19) IS NOT NULL AND ccid_info(I).segment19 <> l_segment_info(19))
       OR (l_segment_info(20) IS NOT NULL AND ccid_info(I).segment20 <> l_segment_info(20))
       OR (l_segment_info(21) IS NOT NULL AND ccid_info(I).segment21 <> l_segment_info(21))
       OR (l_segment_info(22) IS NOT NULL AND ccid_info(I).segment22 <> l_segment_info(22))
       OR (l_segment_info(23) IS NOT NULL AND ccid_info(I).segment23 <> l_segment_info(23))
       OR (l_segment_info(24) IS NOT NULL AND ccid_info(I).segment24 <> l_segment_info(24))
       OR (l_segment_info(25) IS NOT NULL AND ccid_info(I).segment25 <> l_segment_info(25))
       OR (l_segment_info(26) IS NOT NULL AND ccid_info(I).segment26 <> l_segment_info(26))
       OR (l_segment_info(27) IS NOT NULL AND ccid_info(I).segment27 <> l_segment_info(27))
       OR (l_segment_info(28) IS NOT NULL AND ccid_info(I).segment28 <> l_segment_info(28))
       OR (l_segment_info(29) IS NOT NULL AND ccid_info(I).segment29 <> l_segment_info(29))
       OR (l_segment_info(30) IS NOT NULL AND ccid_info(I).segment30 <> l_segment_info(30))) THEN
            l_no_match := 1;
       END IF;

       IF l_no_match = 0 THEN
            x_ccid := ccid_info(I).ccid;

           -- ========================= FND LOG ===========================
               psa_utils.debug_other_string(g_state_level,l_full_path, ' x_ccid -> ' || x_ccid);
               psa_utils.debug_other_string(g_state_level,l_full_path, ' RETURN -> TRUE');
           -- ========================= FND LOG ===========================

           RETURN TRUE;

       END IF;

     End Loop;

   -- ========================= FND LOG ===========================
      psa_utils.debug_other_string(g_state_level,l_full_path, ' RETURN -> FALSE');
   -- ========================= FND LOG ===========================

   RETURN FALSE;

   END IF;

   RETURN FALSE;

 EXCEPTION
    WHEN OTHERS THEN
         -- ========================= FND LOG ===========================
            psa_utils.debug_other_string(g_excep_level,l_full_path,'EXCEPTION - OTHERS : ERROR IN PSA_MFAR_UTILS.is_ccid_exists');
            psa_utils.debug_other_string(g_excep_level,l_full_path,'RETURN -> FALSE');
            psa_utils.debug_other_string(g_excep_level,l_full_path, sqlcode || sqlerrm);
            psa_utils.debug_unexpected_msg(l_full_path);
         -- ========================= FND LOG ===========================
	 RETURN FALSE;

END  is_ccid_exists;

/* ================================== OVERRIDE_SEGMENTS ================================= */

FUNCTION override_segments
		(p_primary_ccid			IN  NUMBER,
		 p_override_ccid		IN  NUMBER,
		 p_set_of_books_id		IN  NUMBER,
		 p_trx_type			    IN  VARCHAR2,
		 P_ccid		 		   OUT NOCOPY NUMBER)
RETURN BOOLEAN IS

  l_primary_segments	 	FND_FLEX_EXT.SEGMENTARRAY;
  l_override_segments	 	FND_FLEX_EXT.SEGMENTARRAY;
  l_segments		 	    FND_FLEX_EXT.SEGMENTARRAY;
  l_chart_of_accounts_id 	NUMBER;
  l_num_segments	 	    NUMBER;
  l_natural_account		    GL_CODE_COMBINATIONS.SEGMENT1%TYPE;
  l_mapped_account		    GL_CODE_COMBINATIONS.SEGMENT1%TYPE;
  l_primary_account 		GL_CODE_COMBINATIONS.SEGMENT1%TYPE;
  l_fndflex_message         VARCHAR2(3000);
  l_ccid                    NUMBER;
  l_conc_segments           VARCHAR2(800);
  l_combination_exists      BOOLEAN;

  GET_SEGMENTS_EXCEP          EXCEPTION;
  GET_QUALIFIER_SEGNUM_EXCEP  EXCEPTION;
  GET_COMBINATION_ID_EXCEP    EXCEPTION;

  -- ========================= FND LOG ===========================
     l_full_path VARCHAR2(100) := g_path || 'override_segments';
  -- ========================= FND LOG ===========================

BEGIN

  -- ========================= FND LOG ===========================
     psa_utils.debug_other_string(g_state_level,l_full_path,' Inside override_segments ');
     psa_utils.debug_other_string(g_state_level,l_full_path,' PARAMETERS: ');
     psa_utils.debug_other_string(g_state_level,l_full_path,' =========== ');
     psa_utils.debug_other_string(g_state_level,l_full_path,' p_primary_ccid    --> ' || p_primary_ccid);
     psa_utils.debug_other_string(g_state_level,l_full_path,' p_override_ccid   --> ' || p_override_ccid );
     psa_utils.debug_other_string(g_state_level,l_full_path,' p_set_of_books_id --> ' || p_set_of_books_id );
     psa_utils.debug_other_string(g_state_level,l_full_path,' p_trx_type        --> ' || p_trx_type);
     psa_utils.debug_other_string(g_state_level,l_full_path,' g_chart_of_accounts_id --> ' || g_chart_of_accounts_id);

  -- ========================= FND LOG ===========================

  -- Get Chart of Accounts ID
  IF g_chart_of_accounts_id IS NULL THEN

     SELECT chart_of_accounts_id
     INTO   g_chart_of_accounts_id
     FROM   gl_sets_of_books
     WHERE  set_of_books_id = p_set_of_books_id;

     -- ========================= FND LOG ===========================
        psa_utils.debug_other_string(g_state_level,l_full_path,' g_chart_of_accounts_id --> ' || g_chart_of_accounts_id);
        psa_utils.debug_other_string(g_state_level,l_full_path,' Getting org details ');
     -- ========================= FND LOG ===========================

     PSA_MF_ORG_DETAILS (g_org_details);

     -- ========================= FND LOG ===========================
        psa_utils.debug_other_string(g_state_level,l_full_path,' Calling FND_FLEX_APIS.GET_QUALIFIER_SEGNUM - balancing segment');


     -- ========================= FND LOG ===========================

     -- Get balancing segment number
     IF (NOT FND_FLEX_APIS.GET_QUALIFIER_SEGNUM(
                                                  APPL_ID                => 101,
                                                  KEY_FLEX_CODE          => 'GL#',
                                                  STRUCTURE_NUMBER       => g_chart_of_accounts_id,
                                                  FLEX_QUAL_NAME         => 'GL_BALANCING',
                                                  SEGMENT_NUMBER         => g_bal_acct_seg_num))  -- OUT
     THEN
         -- ========================= FND LOG ===========================
            psa_utils.debug_other_string(g_state_level,l_full_path,' g_bal_acct_seg_num --> ' || g_bal_acct_seg_num );
            psa_utils.debug_other_string(g_state_level,l_full_path,' Raising GET_QUALIFIER_SEGNUM_EXCEP ');
         -- ========================= FND LOG ===========================
         RAISE GET_QUALIFIER_SEGNUM_EXCEP;
     ELSE
         -- ========================= FND LOG ===========================
            psa_utils.debug_other_string(g_state_level,l_full_path,' g_bal_acct_seg_num --> ' || g_bal_acct_seg_num );
         -- ========================= FND LOG ===========================
     END IF;

     -- ========================= FND LOG ===========================
        psa_utils.debug_other_string(g_state_level,l_full_path,' Calling FND_FLEX_APIS.GET_QUALIFIER_SEGNUM - natural account ');
     -- ========================= FND LOG ===========================

     -- Get natural account segment number
     IF (NOT FND_FLEX_APIS.GET_QUALIFIER_SEGNUM(   APPL_ID                => 101,
                                                   KEY_FLEX_CODE          => 'GL#',
                                                   STRUCTURE_NUMBER       => g_chart_of_accounts_id,
                                                   FLEX_QUAL_NAME         => 'GL_ACCOUNT',
                                                   SEGMENT_NUMBER         => g_nat_acct_seg_num))  THEN   -- OUT
         -- ========================= FND LOG ===========================
            psa_utils.debug_other_string(g_state_level,l_full_path,' g_nat_acct_seg_num --> ' || g_nat_acct_seg_num );
            psa_utils.debug_other_string(g_state_level,l_full_path,' Raising GET_QUALIFIER_SEGNUM_EXCEP ');
         -- ========================= FND LOG ===========================
         RAISE GET_QUALIFIER_SEGNUM_EXCEP;
     ELSE
         -- ========================= FND LOG ===========================
            psa_utils.debug_other_string(g_state_level,l_full_path,' g_nat_acct_seg_num --> ' || g_nat_acct_seg_num );
         -- ========================= FND LOG ===========================
     END IF;

    END IF; -- end if for chart of accounts id is null

    -- ========================= FND LOG ===========================
       psa_utils.debug_other_string(g_state_level,l_full_path,' Calling FND_FLEX_EXT.GET_SEGMENTS - primary segment array');
    -- ========================= FND LOG ===========================

    -- Get Primary segment array
    l_ccid := P_primary_ccid;

    -- ========================= FND LOG ===========================
       psa_utils.debug_other_string(g_state_level,l_full_path,'  l_ccid -> ' || l_ccid);
    -- ========================= FND LOG ===========================

    IF NOT (is_ccid_exists (l_ccid, l_primary_segments, l_num_segments)) THEN

       -- ========================= FND LOG ===========================
          psa_utils.debug_other_string(g_state_level,l_full_path,' is_ccid_exists -> FALSE' );
       -- ========================= FND LOG ===========================

       IF (NOT FND_FLEX_EXT.GET_SEGMENTS(
                                          APPLICATION_SHORT_NAME  => 'SQLGL',
                                          KEY_FLEX_CODE           => 'GL#',
                                          STRUCTURE_NUMBER        => g_chart_of_accounts_id,
                                          COMBINATION_ID          => P_primary_ccid,
                                          N_SEGMENTS              => l_num_segments,                -- OUT
                                          SEGMENTS                => l_primary_segments)) Then      -- OUT

           -- ========================= FND LOG ===========================
              psa_utils.debug_other_string(g_state_level,l_full_path,' l_num_segments --> ' || l_num_segments);
              psa_utils.debug_other_string(g_state_level,l_full_path,' Raising GET_SEGMENTS_EXCEP ');
           -- ========================= FND LOG ===========================
           RAISE GET_SEGMENTS_EXCEP;
        ELSE
           -- ========================= FND LOG ===========================
              psa_utils.debug_other_string(g_state_level,l_full_path,' l_num_segments --> ' || l_num_segments);
              FOR i IN 1..l_num_segments LOOP
                  psa_utils.debug_other_string(g_state_level,l_full_path,' l_primary_segments(i) --> ' || l_primary_segments(i));
              END LOOP;
          -- ========================= FND LOG ===========================
          insert_ccid(l_ccid, l_primary_segments, l_num_segments);

        END IF;

    ELSE
       -- ========================= FND LOG ===========================
          psa_utils.debug_other_string(g_state_level,l_full_path,' is_ccid_exists -> TRUE' );
       -- ========================= FND LOG ===========================
    END IF;

    -- ========================= FND LOG ===========================
       psa_utils.debug_other_string(g_state_level,l_full_path,' Calling FND_FLEX_EXT.GET_SEGMENTS - override segment array ');
    -- ========================= FND LOG ===========================

    -- Get Override segment array
    l_ccid := P_override_ccid ;

    -- ========================= FND LOG ===========================
       psa_utils.debug_other_string(g_state_level,l_full_path,' l_ccid -> ' || l_ccid );
    -- ========================= FND LOG ===========================

    IF NOT (is_ccid_exists (l_ccid, l_override_segments, l_num_segments)) THEN

       -- ========================= FND LOG ===========================
          psa_utils.debug_other_string(g_state_level,l_full_path,' is_ccid_exists -> FALSE' );
       -- ========================= FND LOG ===========================

       IF (NOT FND_FLEX_EXT.GET_SEGMENTS(
                                      APPLICATION_SHORT_NAME  => 'SQLGL',
                                      KEY_FLEX_CODE           => 'GL#',
                                      STRUCTURE_NUMBER        => g_chart_of_accounts_id,
                                      COMBINATION_ID          => P_override_ccid,
                                      N_SEGMENTS              => l_num_segments,                    -- OUT
                                      SEGMENTS                => l_override_segments)) Then         -- OUT

          -- ========================= FND LOG ===========================
             psa_utils.debug_other_string(g_state_level,l_full_path,' l_num_segments --> ' || l_num_segments);
             psa_utils.debug_other_string(g_state_level,l_full_path,' Raising GET_SEGMENTS_EXCEP ');
          -- ========================= FND LOG ===========================
          RAISE GET_SEGMENTS_EXCEP;
       ELSE
          -- ========================= FND LOG ===========================
             psa_utils.debug_other_string(g_state_level,l_full_path,' l_num_segments --> ' || l_num_segments);
             FOR i IN 1..l_num_segments LOOP
                 psa_utils.debug_other_string(g_state_level,l_full_path,' l_override_segments(i) --> '
                                              || l_override_segments(i));
             END LOOP;
          -- ========================= FND LOG ===========================
          insert_ccid(l_ccid, l_override_segments, l_num_segments);
       END IF;

     ELSE
       -- ========================= FND LOG ===========================
          psa_utils.debug_other_string(g_state_level,l_full_path,' is_ccid_exists -> TRUE' );
       -- ========================= FND LOG ===========================
     END IF;


     -- ========================= FND LOG ===========================
         psa_utils.debug_other_string(g_state_level,l_full_path,' g_org_details.allocation_method  --> '
                                      || g_org_details.allocation_method );
     -- ========================= FND LOG ===========================

	IF g_org_details.allocation_method = 'BAL' THEN

	   -- Override balancing segment
	   FOR i IN 1..l_num_segments LOOP
	     IF (i = g_bal_acct_seg_num) THEN
		  l_segments(i) := l_override_segments(i);
	     ELSE
		  l_segments(i) := l_primary_segments(i);
	     END IF;
             -- ========================= FND LOG ===========================
                psa_utils.debug_other_string(g_state_level,l_full_path,' l_segments(i) --> ' || l_segments(i) );
             -- ========================= FND LOG ===========================
	   END LOOP;

	ELSIF g_org_details.allocation_method = 'ACC' THEN

           -- Override natural account segment
	   l_segments := l_override_segments;
	   l_primary_account := l_primary_segments (g_nat_acct_seg_num);
	   l_segments (g_nat_acct_seg_num) := l_primary_account;
           -- ========================= FND LOG ===========================
              psa_utils.debug_other_string(g_state_level,l_full_path,' l_primary_account --> ' || l_primary_account);
              psa_utils.debug_other_string(g_state_level,l_full_path,' l_segments (l_nat_acct_seg_num) --> '
                                           || l_segments (g_nat_acct_seg_num) );
           -- ========================= FND LOG ===========================
	END IF;

	--
	--  Check account mapping
	--

        -- ========================= FND LOG ===========================
           psa_utils.debug_other_string(g_state_level,l_full_path,' p_trx_type  --> ' || p_trx_type );
        -- ========================= FND LOG ===========================

	IF p_trx_type IN ('TRX', 'RCT', 'ADJ', 'MISC') THEN

           -- ========================= FND LOG ===========================
              psa_utils.debug_other_string(g_state_level,l_full_path,' g_org_details.mapping_required  --> '
                                           || g_org_details.mapping_required );
           -- ========================= FND LOG ===========================

	   IF g_org_details.mapping_required = 'Y' THEN

	      --
	      -- Get account FROM mapping table
	      --
	      l_natural_account := l_override_segments (g_nat_acct_seg_num);
	      l_mapped_account  := GET_MAPPED_ACCOUNT (p_trx_type, l_natural_account, p_set_of_books_id, g_chart_of_accounts_id);

              -- ========================= FND LOG ===========================
                 psa_utils.debug_other_string(g_state_level,l_full_path,' l_natural_account --> ' || l_natural_account );
                 psa_utils.debug_other_string(g_state_level,l_full_path,' l_mapped_account  --> ' || l_mapped_account  );
              -- ========================= FND LOG ===========================

	      --
	      -- Override natural account using mapped account
	      --

	      IF l_natural_account <> l_mapped_account THEN
	         l_segments (g_nat_acct_seg_num) := l_mapped_account;
                 -- ========================= FND LOG ===========================
                    psa_utils.debug_other_string(g_state_level,l_full_path,' l_segments (g_nat_acct_seg_num)  --> '
                                                 || l_segments (g_nat_acct_seg_num) );
                 -- ========================= FND LOG ===========================
	      END IF;
	   END IF;
	END IF;

     -- ========================= FND LOG ===========================
         psa_utils.debug_other_string(g_state_level,l_full_path,' Calling FND_FLEX_EXT.GET_COMBINATION_ID - overridden segments' );
     -- ========================= FND LOG ===========================

     --
     -- Get ccid for overridden segments
     --

    IF NOT (is_ccid_exists (p_ccid, l_segments, l_num_segments)) THEN

       -- ========================= FND LOG ===========================
          psa_utils.debug_other_string(g_state_level,l_full_path,' is_ccid_exists -> FALSE' );

     FOR  I IN 1..l_segments.count
     LOOP
       psa_utils.debug_other_string(g_state_level,l_full_path,' l_segment_info   --> ' || l_segments(I) );

     END LOOP;
 psa_utils.debug_other_string(g_state_level,l_full_path,'l_chart_of_acI :'||g_chart_of_acCOUNTS_ID);

psa_utils.debug_other_string(g_state_level,l_full_path,'L_NUM_SEG'||l_segments.count);


       IF (NOT FND_FLEX_EXT.GET_COMBINATION_ID(
				APPLICATION_SHORT_NAME         => 'SQLGL',
				KEY_FLEX_CODE                  => 'GL#',
				STRUCTURE_NUMBER               => g_chart_of_accounts_id,
				VALIDATION_DATE                => SYSDATE,
				N_SEGMENTS                     => l_segments.count,
				SEGMENTS                       => l_segments,
				COMBINATION_ID                 => P_ccid)) Then                 -- OUT

           -- ========================= FND LOG ===========================
              psa_utils.debug_other_string(g_state_level,l_full_path,' P_ccid --> ' || P_ccid );
              psa_utils.debug_other_string(g_state_level,l_full_path,' Raising GET_COMBINATION_ID_EXCEP ');
           -- ========================= FND LOG ===========================
           RAISE GET_COMBINATION_ID_EXCEP;
      ELSE
           -- ========================= FND LOG ===========================
              psa_utils.debug_other_string(g_state_level,l_full_path,' P_ccid --> ' || P_ccid );
           -- ========================= FND LOG ===========================
           insert_ccid(p_ccid, l_segments, l_segments.count);
      END IF;
    ELSE
       -- ========================= FND LOG ===========================
          psa_utils.debug_other_string(g_state_level,l_full_path,' is_ccid_exists -> TRUE' );
       -- ========================= FND LOG ===========================
    END IF;

    -- ========================= FND LOG ===========================
       psa_utils.debug_other_string(g_state_level,l_full_path,' RETURNING TRUE ');
    -- ========================= FND LOG ===========================

    RETURN TRUE;

EXCEPTION

      WHEN GET_SEGMENTS_EXCEP THEN
           -- ========================= FND LOG ===========================
              psa_utils.debug_other_string(g_state_level,l_full_path,' EXCEPTION - GET_SEGMENTS_EXCEP in override_segments');
           -- ========================= FND LOG ===========================
              RETURN FALSE;

      WHEN GET_QUALIFIER_SEGNUM_EXCEP THEN
           -- ========================= FND LOG ===========================
              psa_utils.debug_other_string(g_state_level,l_full_path,' EXCEPTION - GET_QUALIFIER_SEGNUM_EXCEP in override_segments');
           -- ========================= FND LOG ===========================
	     RETURN FALSE;

	WHEN GET_COMBINATION_ID_EXCEP THEN
           -- ========================= FND LOG ===========================
              psa_utils.debug_other_string(g_state_level,l_full_path,' EXCEPTION- GET_COMBINATION_ID_EXCEP in override_segments');
           -- ========================= FND LOG ===========================
        BEGIN
            IF g_segment_delimiter IS NULL THEN
                g_segment_delimiter := fnd_flex_apis.get_segment_delimiter(
                                                    x_application_id => 101,
			                                        x_id_flex_code => 'GL#',
			                                        x_id_flex_num => g_chart_of_accounts_id);
            END IF;

            FOR i IN 1..l_segments.count LOOP
                IF (i = l_segments.count) THEN
                    l_conc_segments := l_conc_segments || l_segments(i);
                ELSE
                    l_conc_segments := l_conc_segments || l_segments(i) || g_segment_delimiter;
                END IF;
            END LOOP;

            l_combination_exists := FALSE;
            IF g_invalid_combinations.count > 0 THEN
                FOR i IN 1..g_invalid_combinations.count LOOP
                    IF (g_invalid_combinations(i).combination = l_conc_segments) THEN
                        l_combination_exists := TRUE;
                        EXIT;
                    END IF;
                END LOOP;
            END IF;

            IF NOT l_combination_exists THEN
                g_invalid_index := g_invalid_combinations.count + 1;
                g_invalid_combinations(g_invalid_index).combination := l_conc_segments;
                g_invalid_combinations(g_invalid_index).error_message := fnd_message.get;
            END IF;
            /* Next 2 lines of code is required to continue the processing */
            p_ccid := p_primary_ccid;
            RETURN TRUE;
            EXCEPTION
                WHEN OTHERS THEN
                -- ========================= FND LOG ===========================
                psa_utils.debug_other_string(g_state_level,l_full_path,' EXCEPTION in GET_COMBINATION_ID_EXCEP in override_segments');
                -- ========================= FND LOG ===========================
                RETURN FALSE;
        END;

	     RETURN FALSE;

	WHEN OTHERS THEN
         -- ========================= FND LOG ===========================
            psa_utils.debug_other_string(g_excep_level,l_full_path,'EXCEPTION - OTHERS : ERROR IN PSA_MFAR_UTILS.override_segments');
            psa_utils.debug_other_string(g_excep_level,l_full_path, sqlcode || sqlerrm);
            psa_utils.debug_unexpected_msg(l_full_path);
         -- ========================= FND LOG ===========================

	  APP_EXCEPTION.RAISE_EXCEPTION;

END override_segments;

/* ========================== INSERT_DISTRIBUTIONS_LOG ===================== */

PROCEDURE INSERT_DISTRIBUTIONS_LOG (p_error_id	      IN NUMBER,
				    p_activity 	      IN VARCHAR2,
				    p_customer_trx_id IN NUMBER,
				    p_activity_id     IN NUMBER,
				    p_error_message   IN VARCHAR2) AS

	PRAGMA AUTONOMOUS_TRANSACTION;

	l_last_updated_by	PSA_MF_DISTRIBUTIONS_LOG.LAST_UPDATED_BY%TYPE;
	l_last_update_login	PSA_MF_DISTRIBUTIONS_LOG.LAST_UPDATE_LOGIN%TYPE;

BEGIN

    	 l_last_updated_by := FND_GLOBAL.USER_ID;

	 IF l_last_updated_by IS NULL THEN
	      l_last_updated_by := -1;
	 END IF;

	 l_last_update_login := FND_GLOBAL.LOGIN_ID;

	 IF l_last_update_login IS NULL THEN
		l_last_update_login := -1;
	 END IF;

	 INSERT INTO PSA_MF_DISTRIBUTIONS_LOG ( ERROR_ID,
						ACTIVITY,
						CUSTOMER_TRX_ID,
						LAST_UPDATE_DATE,
						LAST_UPDATED_BY,
						LAST_UPDATE_LOGIN,
						CREATED_BY,
						CREATED_DATE,
						ACTIVITY_ID,
						ERROR_MESSAGE)
 				VALUES (p_error_id,
					p_activity,
					p_customer_trx_id,
					SYSDATE,
					l_last_updated_by,
					l_last_update_login,
					l_last_update_login,
					SYSDATE,
					p_activity_id,
					p_error_message);

	 COMMIT;

END INSERT_DISTRIBUTIONS_LOG;

/* ========================== GET_MAPPED_ACCOUNT ===================== */

FUNCTION GET_MAPPED_ACCOUNT (p_transaction_type	    IN VARCHAR2,
			     p_natural_account      IN VARCHAR2,
			     p_set_of_books_id      IN NUMBER,
			     p_chart_of_accounts_id IN NUMBER )
	 RETURN VARCHAR2 IS


 CURSOR c_account_code IS
	 SELECT  SUBSTR(v.compiled_value_attributes,5,1) account_code
	   FROM  gl_sets_of_books     b,
	         fnd_flex_values      v,
	         fnd_id_flex_segments s
	  WHERE  v.flex_value_set_id    = s.flex_value_set_id
	    AND  v.flex_value           = p_natural_account
	    AND  b.set_of_books_id      = p_set_of_books_id
	    AND  b.chart_of_accounts_id = p_chart_of_accounts_id
	    AND  (s.application_id, s.id_flex_code, s.id_flex_num, s.application_column_name) =
	              (SELECT application_id, id_flex_code, id_flex_num, application_column_name
	                 FROM fnd_segment_attribute_values a
	                WHERE id_flex_code           = 'GL#'
	                  AND segment_attribute_type = 'GL_ACCOUNT'
	                  AND attribute_value        = 'Y'
			  AND id_flex_num            = b.chart_of_accounts_id
	                  AND application_id =
	                                 (SELECT application_id
	                                    FROM fnd_application
	                                   WHERE application_short_name = 'SQLGL'));


 CURSOR c_mapped_account (c_lookup_code    IN VARCHAR2,
                          c_source_account IN VARCHAR2) IS
	SELECT b.target_account mapped_account
	  FROM PSA_MF_ACCT_MAP_HEADER_ALL A,
	       PSA_MF_ACCOUNT_MAPPING_ALL B
	 WHERE a.psa_acct_mapping_id	= b.psa_acct_mapping_id
	   AND a.org_id                	= l_org_id
	   AND a.document_code		= p_transaction_type
	   AND a.lookup_code            = c_lookup_code
	   AND b.source_account         = c_source_account
  	   AND trunc(sysdate) 		>= trunc(b.start_date_active)
	   AND trunc(sysdate) 		<= trunc(nvl(b.end_date_active,sysdate));

 l_account_code		fnd_flex_values.compiled_value_attributes%TYPE;
 l_mapped_account       PSA_MF_ACCOUNT_MAPPING_ALL.target_account%TYPE;

  -- ========================= FND LOG ===========================
  l_full_path VARCHAR2(100) := g_path || 'get_mapped_account';
  -- ========================= FND LOG ===========================

BEGIN

  -- ========================= FND LOG ===========================
     psa_utils.debug_other_string(g_state_level,l_full_path,' Inside get_mapped_account');
     psa_utils.debug_other_string(g_state_level,l_full_path,' PARAMETERS: ');
     psa_utils.debug_other_string(g_state_level,l_full_path,' =========== ');
     psa_utils.debug_other_string(g_state_level,l_full_path,' p_transaction_type     --> ' || p_transaction_type);
     psa_utils.debug_other_string(g_state_level,l_full_path,' p_natural_account      --> ' || p_natural_account);
     psa_utils.debug_other_string(g_state_level,l_full_path,' p_set_of_books_id      --> ' || p_set_of_books_id );
     psa_utils.debug_other_string(g_state_level,l_full_path,' p_chart_of_accounts_id --> ' || p_chart_of_accounts_id );
  -- ========================= FND LOG ===========================

     OPEN  c_account_code;
     FETCH c_account_code INTO l_account_code;
     CLOSE c_account_code;

  -- ========================= FND LOG ===========================
     psa_utils.debug_other_string(g_state_level,l_full_path,' l_account_code --> ' || l_account_code);
  -- ========================= FND LOG ===========================

     OPEN  c_mapped_account (l_account_code,
                             p_natural_account);
     FETCH c_mapped_account INTO l_mapped_account;
     CLOSE c_mapped_account;

  -- ========================= FND LOG ===========================
     psa_utils.debug_other_string(g_state_level,l_full_path,' l_mapped_account --> ' || l_mapped_account);
     psa_utils.debug_other_string(g_state_level,l_full_path,' returning --> ' || nvl(l_mapped_account,p_natural_account));
  -- ========================= FND LOG ===========================

     RETURN nvl(l_mapped_account,p_natural_account);

END GET_MAPPED_ACCOUNT;


/* =========================== PSA_MF_ORG_DETAILS ========================== */

PROCEDURE psa_mf_org_details (l_org_details OUT NOCOPY psa_implementation_all%rowtype)
IS

 CURSOR c_org_details (c_org_id NUMBER)
 IS
   SELECT *
   FROM psa_implementation_all
   WHERE org_id = c_org_id;

  -- ========================= FND LOG ===========================
  l_full_path VARCHAR2(100) := g_path || 'psa_mf_org_details';
  -- ========================= FND LOG ===========================

BEGIN

  -- ========================= FND LOG ===========================
     psa_utils.debug_other_string(g_state_level,l_full_path,' Inside PSA_MF_ORG_DETAILS ');
  -- ========================= FND LOG ===========================

     FND_PROFILE.GET ('ORG_ID', l_org_id);

  -- ========================= FND LOG ===========================
     psa_utils.debug_other_string(g_state_level,l_full_path,' l_org_id --> ' || l_org_id);
  -- ========================= FND LOG ===========================

     OPEN  c_org_details (l_org_id);
     FETCH c_org_details INTO l_org_details;
     CLOSE c_org_details;

  -- ========================= FND LOG ===========================
     psa_utils.debug_other_string(g_state_level,l_full_path,' Out of PSA_MF_ORG_DETAILS ');
  -- ========================= FND LOG ===========================

END psa_mf_org_details ;


/* =========================== get_ar_sob_id ========================== */

FUNCTION get_ar_sob_id RETURN number
IS
  l_ar_sob_id ar_system_parameters.set_of_books_id%TYPE;

  -- ========================= FND LOG ===========================
  l_full_path VARCHAR2(100) := g_path || 'get_ar_sob_id';
  -- ========================= FND LOG ===========================

BEGIN

  -- ========================= FND LOG ===========================
     psa_utils.debug_other_string(g_state_level,l_full_path,' Inside get_ar_sob_id ');
  -- ========================= FND LOG ===========================

  SELECT set_of_books_id
  INTO   l_ar_sob_id
  FROM   ar_system_parameters;

  -- ========================= FND LOG ===========================
     psa_utils.debug_other_string(g_state_level,l_full_path,' l_ar_sob_id --> ' || l_ar_sob_id);
     psa_utils.debug_other_string(g_state_level,l_full_path,' Out of get_ar_sob_id ');
  -- ========================= FND LOG ===========================

  RETURN l_ar_sob_id;

END get_ar_sob_id ;

/* =========================== get_rec_ccid ========================== */

FUNCTION get_rec_ccid (p_applied_trx_id IN NUMBER,
                       p_trx_id         IN NUMBER)
RETURN  NUMBER
is
  CURSOR c_prev_trx_id
  IS
     SELECT previous_customer_trx_id
     FROM   ra_customer_trx_all
     WHERE  customer_trx_id = p_trx_id;

  l_ret_code_combination   NUMBER(15);
  l_prev_trx_id            NUMBER(15);
  l_customer_trx_id        NUMBER(15);

  -- ========================= FND LOG ===========================
  l_full_path VARCHAR2(100) := g_path || 'get_rec_ccid';
  -- ========================= FND LOG ===========================

BEGIN

  -- ========================= FND LOG ===========================
     psa_utils.debug_other_string(g_state_level,l_full_path,' Inside get_rec_ccid ');
     psa_utils.debug_other_string(g_state_level,l_full_path,' PARAMETERS: ');
     psa_utils.debug_other_string(g_state_level,l_full_path,' =========== ');
     psa_utils.debug_other_string(g_state_level,l_full_path,' p_applied_trx_id  --> ' || p_applied_trx_id );
     psa_utils.debug_other_string(g_state_level,l_full_path,' p_trx_id          --> ' || p_trx_id         );
  -- ========================= FND LOG ===========================

  IF p_applied_trx_id IS NOT NULL THEN

      OPEN c_prev_trx_id;
      FETCH c_prev_trx_id INTO l_prev_trx_id;
      CLOSE c_prev_trx_id;

  -- ========================= FND LOG ===========================
     psa_utils.debug_other_string(g_state_level,l_full_path,' l_prev_trx_id  --> ' || l_prev_trx_id);
  -- ========================= FND LOG ===========================

      IF l_prev_trx_id IS NULL THEN           -- on account credit memo. RETURN trx_id's A/c
         l_customer_trx_id := p_trx_id;
      ELSE
         l_customer_trx_id := p_applied_trx_id;
      END IF;

  -- ========================= FND LOG ===========================
     psa_utils.debug_other_string(g_state_level,l_full_path,' l_customer_trx_id --> ' || l_customer_trx_id );
  -- ========================= FND LOG ===========================

  ELSE
      l_customer_trx_id := p_trx_id;
  -- ========================= FND LOG ===========================
     psa_utils.debug_other_string(g_state_level,l_full_path,' ELSE l_customer_trx_id --> ' || l_customer_trx_id );
  -- ========================= FND LOG ===========================
  END IF;


  SELECT code_combination_id
  INTO  l_ret_code_combination
  FROM  ra_cust_trx_line_gl_dist_all
  WHERE customer_trx_id = l_customer_trx_id
  AND   account_class = 'REC'
  AND   account_set_flag = 'N';

  -- ========================= FND LOG ===========================
     psa_utils.debug_other_string(g_state_level,l_full_path,' l_ret_code_combination --> ' || l_ret_code_combination);
  -- ========================= FND LOG ===========================

  RETURN l_ret_code_combination;

END get_rec_ccid;

/* =========================== get_rec_ccid ========================== */

FUNCTION get_coa (sob_id in number)
RETURN number
IS
  l_ret_coa_id  NUMBER(15);

  -- ========================= FND LOG ===========================
  l_full_path VARCHAR2(100) := g_path || 'get_coa';
  -- ========================= FND LOG ===========================

BEGIN

  -- ========================= FND LOG ===========================
     psa_utils.debug_other_string(g_state_level,l_full_path,' Inside get_coa ');
     psa_utils.debug_other_string(g_state_level,l_full_path,' PARAMETERS: ');
     psa_utils.debug_other_string(g_state_level,l_full_path,' =========== ');
     psa_utils.debug_other_string(g_state_level,l_full_path,' sob_id  --> ' || sob_id );
  -- ========================= FND LOG ===========================

  SELECT chart_of_accounts_id
  INTO   l_ret_coa_id
  FROM   gl_sets_of_books
  WHERE  set_of_books_id = sob_id;

  -- ========================= FND LOG ===========================
     psa_utils.debug_other_string(g_state_level,l_full_path,' RETURN l_ret_coa_id --> ' || l_ret_coa_id);
  -- ========================= FND LOG ===========================

  RETURN l_ret_coa_id;

END;

/* =========================== get_rec_ccid ========================== */

FUNCTION get_user_category_name (cat_name IN VARCHAR2)
RETURN VARCHAR2
IS

  l_user_cat_name  VARCHAR2(25);
  -- ========================= FND LOG ===========================
  l_full_path VARCHAR2(100) := g_path || 'get_user_category_name';
  -- ========================= FND LOG ===========================

BEGIN

  -- ========================= FND LOG ===========================
     psa_utils.debug_other_string(g_state_level,l_full_path,' Inside get_user_category_name ');
     psa_utils.debug_other_string(g_state_level,l_full_path,' PARAMETERS: ');
     psa_utils.debug_other_string(g_state_level,l_full_path,' =========== ');
     psa_utils.debug_other_string(g_state_level,l_full_path,' cat_name --> ' || cat_name );
  -- ========================= FND LOG ===========================

  SELECT user_je_category_name
  INTO   l_user_cat_name
  FROM   gl_je_categories
  WHERE  je_category_name = cat_name;

  -- ========================= FND LOG ===========================
     psa_utils.debug_other_string(g_state_level,l_full_path,' RETURN l_user_cat_name --> ' || l_user_cat_name);
  -- ========================= FND LOG ===========================

  RETURN l_user_cat_name;

END get_user_category_name;

FUNCTION accounting_method
RETURN VARCHAR2
IS
  -- ========================= FND LOG ===========================
  l_full_path VARCHAR2(100) := g_path || 'accounting_method';
  -- ========================= FND LOG ===========================

BEGIN

  -- ========================= FND LOG ===========================
     psa_utils.debug_other_string(g_state_level,l_full_path,' RETURN accounting_method  --> ' || arp_global.sysparam.accounting_method);
  -- ========================= FND LOG ===========================
  RETURN arp_global.sysparam.accounting_method;

END accounting_method;

END PSA_MFAR_UTILS;

/
