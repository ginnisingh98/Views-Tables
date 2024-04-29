--------------------------------------------------------
--  DDL for Package Body JE_GR_STATUTORY
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."JE_GR_STATUTORY" as
/* $Header: jegrstab.pls 120.5.12010000.2 2009/12/04 10:38:11 rshergil ship $ */

/*------------------------------------------------------------------+
 | Package Cursor and Variables                                     |
 +------------------------------------------------------------------*/

/* The following cursor is used in procedures gl_sequence and gl_cutoff */

CURSOR	c_headers (c_posting_run_id NUMBER, c_last_batch_id NUMBER) IS
SELECT 	jh.je_batch_id,
    	jh.je_header_id,
    	doc.code,
        jh.ledger_id,
    	--jh.set_of_books_id,
    	jh.default_effective_date
--    	sob.global_attribute_category
   -- 	nvl(sob.global_attribute2, 'N'),
   -- 	nvl(sob.global_attribute3, 'N')
FROM
    	gl_sets_of_books 		sob,
    	fnd_doc_sequence_categories 	doc,
    	fnd_application 		a,
    	gl_je_headers 			jh,
    	gl_je_batches 			jb
WHERE
    	jb.actual_flag     		= 'A'				AND
    	jb.posting_run_id  		= c_posting_run_id              AND
    	jh.je_batch_id     		= jb.je_batch_id                AND
    	jb.status          		= 'I'                           AND
    	jh.je_batch_id  		> c_last_batch_id               AND
    	a.application_short_name 	= 'SQLGL'                       AND
    	doc.code                 	= jh.je_category                AND
    	doc.application_id       	= a.application_id              AND
    	sob.set_of_books_id      	= jh.ledger_id; --??
--
-- Fetch variables
--
v_pkg_batch_id              GL_JE_BATCHES.je_batch_id%TYPE;
v_pkg_header_id             GL_JE_HEADERS.je_header_id%TYPE;
v_pkg_trx_date              DATE;
v_pkg_last_batch_id         GL_JE_BATCHES.je_batch_id%TYPE := 0;
v_pkg_category_code         FND_DOC_SEQUENCE_CATEGORIES.code%TYPE;
v_pkg_cat_application_id    FND_DOC_SEQUENCE_CATEGORIES.application_id%TYPE;
v_pkg_ledger_id       GL_SETS_OF_BOOKS.set_of_books_id%TYPE; --??
--v_pkg_global_attribute      GL_SETS_OF_BOOKS.global_attribute1%TYPE;
v_pkg_sequence_ax_journals  VARCHAR2(150);
v_pkg_append_sequence	    VARCHAR2(150);

/*------------------------------------------------------------------+
 | PROCEDURE: get_cutoff                                            |
 |  DESCRIPTION                                                     |
 |      Get the cutoff rule for the given			    |
 |	SOB, category, application combination, once/session	    |
 | 	Once cached, return the days and violation response         |
 |  CALLED BY                                                       |
 |	check_cutoff						    |
 +------------------------------------------------------------------*/
PROCEDURE get_cutoff (p_ledger_id    IN     NUMBER, --??
                      p_category_code      IN     VARCHAR2,
                      p_cat_application_id IN     NUMBER,
                      p_cutoff_days        OUT NOCOPY    NUMBER,
                      p_violation_response OUT NOCOPY    VARCHAR2,
                      p_retcode            IN OUT NOCOPY NUMBER,
                      p_errmsg             IN OUT NOCOPY VARCHAR2) IS

CURSOR c_cutoff_rules IS
  SELECT	category_code,
		cat_application_id,
		set_of_books_id, --??
         	days,
		violation_response,
                enabled_flag
  FROM		je_gr_cutoff_rules;

idx                       BINARY_INTEGER;
v_pkg_category_code       FND_DOC_SEQUENCE_CATEGORIES.code%TYPE;
v_pkg_cat_application_id  FND_DOC_SEQUENCE_CATEGORIES.application_id%TYPE;
v_pkg_ledger_id     GL_SETS_OF_BOOKS.set_of_books_id%TYPE;
v_days                    JE_GR_CUTOFF_RULES.days%TYPE;
v_violation_response      JE_GR_CUTOFF_RULES.violation_response%TYPE;
v_enabled_flag		  JE_GR_CUTOFF_RULES.enabled_flag%TYPE;

BEGIN
  p_cutoff_days         := '';
  p_violation_response  := '';
  --
  -- first call to this function in this DB session - cache all rules into a global table
  --
  IF (g_idx <= 0) THEN
    OPEN	c_cutoff_rules;
    LOOP
      FETCH c_cutoff_rules INTO v_pkg_category_code,
				v_pkg_cat_application_id,
                                v_pkg_ledger_id, --??
				v_days,
                                v_violation_response,
				v_enabled_flag;

      EXIT when c_cutoff_rules%NOTFOUND;
      g_cutoff_rules(g_idx).category_code      := v_pkg_category_code;
      g_cutoff_rules(g_idx).cat_application_id := v_pkg_cat_application_id;
      g_cutoff_rules(g_idx).ledger_id    := v_pkg_ledger_id;--??

      IF (v_enabled_flag = 'N') THEN
  -- Bug 881630: Change the day range to a smaller one.
  --     g_cutoff_rules(g_idx).days               := 99999999;
         g_cutoff_rules(g_idx).days               := 99999;
      ELSE
         g_cutoff_rules(g_idx).days               := v_days;
      END IF;

      g_cutoff_rules(g_idx).violation_response := v_violation_response;
      g_idx := g_idx + 1;
    END LOOP;
    close c_cutoff_rules;
  end if;
  --
  -- Get rule info, the purpose of the routine
  --
  FOR idx in 0..g_idx-1 LOOP
    IF ((g_cutoff_rules(idx).category_code      = p_category_code)   AND
        (g_cutoff_rules(idx).ledger_id    = p_ledger_id) AND
        (g_cutoff_rules(idx).cat_application_id = p_cat_application_id)) THEN
      p_cutoff_days        := g_cutoff_rules(idx).days;
      p_violation_response := g_cutoff_rules(idx).violation_response;
      exit;
    END IF;
  END LOOP;

EXCEPTION
    WHEN OTHERS THEN p_retcode := -2;
END;

/*------------------------------------------------------------------+
 | PROCEDURE: gl_sequence                                           |
 |  DESCRIPTION                                                     |
 | 	The routine to get the sequence information and update that |
 | 	to all the journals					    |
 | 	Phases:							    |
 |		1. Get the sequential numbering option		    |
 |		2. Loop the Journals in the main cursor/c_headers   |
 |		3. IF seq. numbering is used, get the sequence      |
 |		4.a IF Sequence failure, update batch and header    |
 |			with error code				    |
 |		4.b IF Sequence failure, update batch and header    |
 |			with sequence number and name		    |
 |  CALLED BY                                                       |
 +------------------------------------------------------------------*/
PROCEDURE gl_sequence (p_posting_run_id    IN     NUMBER,
                       p_retcode           IN OUT NOCOPY NUMBER,
                       p_errmsg            IN OUT NOCOPY VARCHAR2) IS

/*v_sequence_numbering  		VARCHAR2(1);
v_seq_value           		NUMBER;
v_seq_val                       NUMBER;
v_method_code         		VARCHAR2(1)   := 'A'; /* Automatic entry methods only
v_db_seqname          		VARCHAR2(30);
v_sequence_id         		NUMBER;
v_sequence_name		  	VARCHAR2(30);
v_je_attribute_category  	VARCHAR2(30) := 'JE.GR.GLXJEENT.HEADER'; /* Greece only
V_sob_attribute_category 	VARCHAR2(30) := 'JE.GR.GLXSTBKS.BOOKS';  /* Greece only
v_sequence_journals   		BOOLEAN;
v_pkg_sequence_ax_gl_journals  BOOLEAN;
v_sobid                        varchar2(15);
v_je_header_id_flag              NUMBER  ;
v_je_header_id                   NUMBER  ;
*/

BEGIN
null;
/*v_pkg_last_batch_id := 0;
  OPEN c_headers (p_posting_run_id, v_pkg_last_batch_id);
  LOOP
    FETCH c_headers INTO 	v_pkg_batch_id,
  				v_pkg_header_id,
  				v_pkg_category_code,
                                v_pkg_ledger_id, --??
                                v_pkg_trx_date,
--**  				v_pkg_global_attribute;
  --**				v_pkg_sequence_ax_journals,
  --**				v_pkg_append_sequence;

    IF c_headers%NOTFOUND THEN
      exit;
    END IF;
    v_pkg_cat_application_id := 7002; /* European Localizations

   /* --Commented for Bug 1157174
    --  Determine if journal should be sequenced. If it is an AX journal (subledgers) and
    --  the set of books Global DFF states that those shouldn't be sequenced, set flag
    --  sequence_journals accordingly  NOTE: We select the code, that is not translated
    --
    IF (v_pkg_category_code in ('AR Subledger Entries', 'AP Subledger Entries',
       'IC Subledger Entries') AND   v_pkg_sequence_ax_journals = 'N') THEN
       v_sequence_journals := FALSE;
  ELSE
      v_sequence_journals := TRUE;
 END IF;


/*    --Get the flag whether ax sequences journals or not.

   -- FND_PROFILE.GET('GL_SET_OF_BKS_ID', v_sobid);
   -- v_pkg_sequence_ax_gl_journals:=  ax_setup_pkg.gl_sequencing(to_number(v_sobid));

   -- Bug 4750571 AX will be obsoleted in R12 - v_pkg_sequence_ax_gl_journals
   -- variable will always be FALSE so that package should assign the sequence

   -- v_pkg_sequence_ax_gl_journals:= FALSE;

   -- IF (v_pkg_category_code in ('AR Subledger Entries', 'AP Subledger Entries', 'IC Subledger Entries') AND
   --     (v_pkg_sequence_ax_gl_journals)) THEN


-- Re-inserted the code:

    IF (v_pkg_category_code in ('AR Subledger Entries', 'AP Subledger Entries',
       'IC Subledger Entries') AND   v_pkg_sequence_ax_journals = 'N') THEN
      v_sequence_journals := FALSE;
    ELSE
      v_sequence_journals := TRUE;
    END IF;


    IF ((v_pkg_global_attribute = v_sob_attribute_category) and (v_sequence_journals)) THEN
      BEGIN
    /* v_seq_value := FND_SEQNUM.GET_NEXT_SEQUENCE (v_pkg_cat_application_id,
  						     v_pkg_category_code,
                                 		     v_pkg_ledger_id, --??
  						     v_method_code,
  						     v_pkg_trx_date,
                                 		     v_db_seqname,
  						     v_sequence_id);
-- Replaced the get_next_sequence with get_seq_val
   v_seq_value := FND_SEQNUM.GET_SEQ_val (v_pkg_cat_application_id,
                                               v_pkg_category_code,
                                               v_pkg_ledger_id,--??
                                               v_method_code,
                                               v_pkg_trx_date,
                                               v_seq_val,
                                               v_sequence_id,
                                               'Y','Y');

      EXCEPTION
  	  WHEN no_data_found THEN null;
      END;
      --
      -- If no sequence value found
      --
      IF ((v_seq_value is NULL) or (v_sequence_id is NULL)) THEN
        --
        -- Set error status
        --
        UPDATE 	gl_je_batches
        SET 	status = '<'
        WHERE	je_batch_id = v_pkg_batch_id;

        UPDATE 	gl_je_headers
        SET	status = '<'
        WHERE	je_header_id = v_pkg_header_id;
        --
        -- Close cursor and re-open cursor to continue processing with next batch
  	--
        v_pkg_last_batch_id := v_pkg_batch_id;
  	CLOSE c_headers;
        OPEN c_headers (p_posting_run_id, v_pkg_last_batch_id);
      ELSE /* Found a sequence value
        SELECT 	name
        INTO    	v_sequence_name
        FROM 		fnd_document_sequences
        WHERE		doc_sequence_id = v_sequence_id;

-- Added this part to fix the bug 2700126

      begin
           v_je_header_id_flag :=0;
           select je_header_id into v_je_header_id
           from je_gr_je_header_sequence
           where je_header_id = v_pkg_header_id;
      exception
          when no_data_found then
              v_je_header_id_flag := 1;
      end;

      if v_je_header_id_flag  =1 then
        UPDATE	gl_je_headers
        SET		global_attribute_category = v_je_attribute_category,
                -- **  	global_attribute1 = v_sequence_name,
               --  **   	global_attribute2 = v_seq_val,
  		      	external_reference = DECODE(v_pkg_append_sequence,
                                                   'Y',  substr(v_seq_val     || ' ' ||
  						                v_sequence_name || ' ' ||
                                          	                external_reference , 1, 80),
  						   'N',  external_reference,
  						         external_reference)
        WHERE	je_header_id = v_pkg_header_id;

        INSERT 	INTO  je_gr_je_header_sequence  (je_header_id,
  						 doc_sequence_id,
  						 doc_sequence_value,
                        			 creation_date,
  						 created_by)
        VALUES					(v_pkg_header_id,
  						 v_sequence_id,
  						 v_seq_val,
                        			 sysdate,
  						 FND_GLOBAL.user_id);
      end if; -- end of modifications for the bug 2700126
    END IF; /* Check if sequence value was found
      --
      --  Initialize variables for next fetch
      --
      v_seq_value   := '';
      v_sequence_id := '';
      v_seq_val := '';
    END IF; /* If v_pkg_global_attribute
  END LOOP;
  CLOSE c_headers;

  p_retcode := 0;
  p_errmsg  := '';
EXCEPTION
  WHEN OTHERS THEN
    IF (c_headers%ISOPEN) THEN
      close c_headers;
    END IF;
    p_retcode := -2;
    p_errmsg  := 'SQL ERROR-ALERT';
*/
END;

/*------------------------------------------------------------------+
 | PROCEDURE: check_cutoff                                          |
 |  DESCRIPTION                                                     |
 | 	Procedure to figure out if the Cutoff is to be violated	    |
 |	If there is GDFF poiting to Greece, we validate		    |
 |  CALLED BY                                                       |
 |	gl_cutoff						    |
 +------------------------------------------------------------------*/
PROCEDURE check_cutoff (p_ledger_id    IN     NUMBER,
                        p_gldate             IN     DATE,
                        p_category_code      IN     VARCHAR2,
                        p_cat_application_id IN     NUMBER,
                        p_retcode            IN OUT NOCOPY NUMBER,
                        p_errmsg             IN OUT NOCOPY VARCHAR2) IS

v_cutoff_days           JE_GR_CUTOFF_RULES.days%TYPE := '';
v_violation_response    JE_GR_CUTOFF_RULES.violation_response%TYPE := '';
v_global                VARCHAR2(100) := '';
-- Bug 881630: Correct the definition of v_default_cutoff_days
-- v_default_cutoff_days   JE_GR_CUTOFF_RULES.violation_response%TYPE;
v_default_cutoff_days   JE_GR_CUTOFF_RULES.days%TYPE := '';

BEGIN
  p_retcode := 0;
  p_errmsg  := '';
  --
  --  The Greek Global DFF stores the default cutoff days in global_attribute1
  --
v_global:=JG_ZZ_SHARED_PKG.get_country(null, p_ledger_id);
/*SELECT 	global_attribute_category
	   	--to_number(nvl(global_attribute1, 15))**
  INTO 		v_global
	   	v_default_cutoff_days
  FROM		gl_sets_of_books
  WHERE		set_of_books_id = p_ledger_id;--??
*/
  IF (v_global = 'GR') THEN

    get_cutoff (	p_ledger_id,
			p_category_code,
			p_cat_application_id,
                  	v_cutoff_days,
			v_violation_response,
			p_retcode,
			p_errmsg);
v_default_cutoff_days:=to_number(fnd_profile.value('JEGR_DEF_CUTOFF_DAYS'));
-- p_retcode := -1;
    IF (p_retcode = 0) THEN
      IF (TRUNC(sysdate) - NVL(v_cutoff_days, v_default_cutoff_days) > p_gldate) THEN
	--
        -- If response = 'FAIL' or v_cutoff_days is NULL (no rule found,
        -- set of books default cutoff days was used)
	--
        IF (v_violation_response = 'FAIL' or nvl(v_cutoff_days, -9) = -9) THEN
          p_retcode := -1;
          p_errmsg  := 'JE_GR_CUTOFF_FAIL';
        ELSE /* violation response is warning */
          p_retcode := 1;
          p_errmsg  := 'JE_GR_CUTOFF_WARNING';
        END IF;
      END IF; /* cutoff > gl_date */
    END IF; /* retcode = 0 */
  END IF; /* v_global = ... */
EXCEPTION
  WHEN OTHERS THEN p_retcode := -2;
                   p_errmsg  := 'SQL ERROR-ALERT';
END;

/*------------------------------------------------------------------+
 | PROCEDURE: gl_cutoff                                             |
 |  DESCRIPTION                                                     |
 | 	The main procedure for cutoff violation			    |
 | 	Looks through all the batches, headers of the posting       |
 | 	Control id
 |  CALLED BY                                                       |
 +------------------------------------------------------------------*/
PROCEDURE gl_cutoff (p_posting_run_id IN     NUMBER,
                     p_retcode        IN OUT NOCOPY NUMBER,
                     p_errmsg         IN OUT NOCOPY VARCHAR2) IS
BEGIN
  v_pkg_last_batch_id  := 0;
  p_retcode   := 0;
  p_errmsg    := '';

  OPEN c_headers (p_posting_run_id, v_pkg_last_batch_id);
  LOOP
    FETCH c_headers into 	v_pkg_batch_id,
				v_pkg_header_id,
				v_pkg_category_code,
                          	v_pkg_ledger_id, --??
                          	v_pkg_trx_date;
--				v_pkg_global_attribute;
--				v_pkg_sequence_ax_journals,
--			  	v_pkg_append_sequence;
    IF (c_headers%NOTFOUND) THEN
      exit;
    END IF;
   p_retcode := 0;
   p_errmsg  := '';
    v_pkg_cat_application_id := 101; /* General Ledger */

    check_cutoff (	v_pkg_ledger_id, --??
			v_pkg_trx_date,
			v_pkg_category_code,
                     	v_pkg_cat_application_id,
			p_retcode,
			p_errmsg);
     --
     -- Check if cut off has been violated (retcode = -1)
     -- Set error status
     --

 IF (p_retcode < 0) THEN
       UPDATE 	gl_je_batches
       SET	status = '>'
       WHERE	je_batch_id = v_pkg_batch_id;

       UPDATE	gl_je_headers
       SET	status = '>'
       WHERE	je_header_id = v_pkg_header_id;
       --
       -- Close cursor and re-open cursor to continue processing with
       -- next batch
       --
       v_pkg_last_batch_id := v_pkg_batch_id;
       CLOSE c_headers;
       OPEN c_headers (p_posting_run_id,
		       v_pkg_last_batch_id);
     end if; /* p_retcode < 0 */
   END LOOP;
   close c_headers;
   -- p_retcode := 0;
   -- p_errmsg  := '';
EXCEPTION
   WHEN OTHERS THEN
     IF (c_headers%ISOPEN) THEN
       CLOSE c_headers;
     END IF;
     p_retcode := -3;
     p_errmsg  := 'SQL ERROR-ALERT';
END;

END JE_GR_STATUTORY;

/
