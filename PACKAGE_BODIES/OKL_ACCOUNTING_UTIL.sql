--------------------------------------------------------
--  DDL for Package Body OKL_ACCOUNTING_UTIL
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OKL_ACCOUNTING_UTIL" AS
/* $Header: OKLRAUTB.pls 120.14.12010000.4 2009/06/12 21:01:07 sechawla ship $ */

/**************************************************************************/

  PROCEDURE get_segment_array
    (p_concate_segments IN VARCHAR2,
	p_delimiter IN VARCHAR2,
	p_seg_array_type OUT NOCOPY seg_array_type)
  AS
    j INTEGER := 1;
    l_next_char VARCHAR2(1);
    l_seg_value VARCHAR2(100);
  BEGIN
    FOR i IN 1..LENGTH(p_concate_segments)
    LOOP
      l_next_char := SUBSTR(p_concate_segments, i,1);
      IF l_next_char = p_delimiter
      THEN
  	    p_seg_array_type(j) := l_seg_value;
  	    l_seg_value := NULL;
  	    j := j + 1;
      ELSE
        l_seg_value := l_seg_value || l_next_char;
      END IF;
    END LOOP;
    p_seg_array_type(j) := l_seg_value;
  END get_segment_array;

/**************************************************************************/

  FUNCTION get_concate_desc
    (p_chart_of_account_id IN NUMBER,
    p_concate_segments IN VARCHAR2)
  RETURN VARCHAR2
  AS
    CURSOR flex_segment_csr
    IS
    SELECT flex_value_set_id
	FROM fnd_id_flex_segments
    WHERE id_flex_num = p_chart_of_account_id
	AND application_id = 101
	AND id_flex_code = 'GL#'
    AND enabled_flag = 'Y'
    ORDER BY segment_num;

    i INTEGER := 1;
    l_delimiter VARCHAR2(1);
	l_seg_array OKL_ACCOUNTING_UTIL.seg_array_type;
	l_seg_desc VARCHAR2(2000);
	l_concate_desc gl_code_combinations_kfv.concatenated_segments%TYPE;
	l_parent_id fnd_flex_value_sets.parent_flex_value_set_id%TYPE;
	l_parent_value_low FND_FLEX_VALUES.PARENT_FLEX_VALUE_LOW%TYPE;

-- Changed by Santonyr on 13-May-2004
-- Fixed Bug Number 3628755

    TYPE segment_rec_type IS RECORD
     (segment_value 		fnd_flex_values_vl.flex_value%TYPE,
      flex_value_set_id     fnd_id_flex_segments.flex_value_set_id%TYPE
     );

    TYPE segment_table_type IS TABLE OF segment_rec_type INDEX BY BINARY_INTEGER;

	l_segment_table segment_table_type;
	l_segment_table_1 segment_table_type;


    CURSOR parent_flex_value_csr(l_flex_value_set_id NUMBER)
    IS
    SELECT parent_flex_value_set_id
    FROM fnd_flex_value_sets
    WHERE flex_value_set_id = l_flex_value_set_id;


--rkuttiya removed the INTO clause from this Cursor SELECT
--found during 12.1 Multi GAAP Test
    CURSOR parent_flex_value_desc_csr(
    	l_flex_value_set_id NUMBER,
    	l_segment_value VARCHAR2)
    IS
    SELECT description
    FROM fnd_flex_values_vl
    WHERE flex_value_set_id = l_flex_value_set_id
    AND flex_value = l_segment_value;


--rkuttiya removed the INTO clause from this Cursor SELECT
--found during Multi GAAP test
    CURSOR parent_flex_low_desc_csr(
    	l_flex_value_set_id NUMBER,
    	l_segment_value VARCHAR2,
    	l_parent_value_low VARCHAR2
    ) IS
    SELECT description
    FROM fnd_flex_values_vl
    WHERE flex_value_set_id = l_flex_value_set_id
    AND flex_value = l_segment_value
    AND parent_flex_value_low  = l_parent_value_low;

BEGIN

    l_delimiter := fnd_flex_apis.get_segment_delimiter(
                     x_application_id => 101,
 		             x_id_flex_code => 'GL#',
 	                 x_id_flex_num => p_chart_of_account_id);

    OKL_ACCOUNTING_UTIL.get_segment_array
      (p_concate_segments => p_concate_segments,
	  p_delimiter => l_delimiter,
	  p_seg_array_type => l_seg_array);

   FOR i IN l_seg_array.FIRST..l_seg_array.LAST LOOP
     l_segment_table(i).segment_value := l_seg_array(i);
   END LOOP;

   i := 1;
   FOR l_flex_segment_csr IN flex_segment_csr LOOP
     l_segment_table(i).flex_value_set_id := l_flex_segment_csr.flex_value_set_id;
	 i := i + 1;
   END LOOP;

	l_segment_table_1 := l_segment_table;

    FOR i IN l_segment_table.FIRST..l_segment_table.LAST LOOP

     OPEN parent_flex_value_csr(l_segment_table(i).flex_value_set_id) ;
     FETCH parent_flex_value_csr INTO l_parent_id;
     CLOSE parent_flex_value_csr;

     IF l_parent_id IS NULL THEN

       OPEN parent_flex_value_desc_csr(
       	l_segment_table(i).flex_value_set_id,
       	l_segment_table(i).segment_value);
       FETCH parent_flex_value_desc_csr INTO l_seg_desc;
       CLOSE parent_flex_value_desc_csr;

      ELSE

	FOR j IN l_segment_table_1.FIRST.. l_segment_table_1.LAST LOOP
	  IF l_parent_id = l_segment_table_1(j).flex_value_set_id THEN
	     l_parent_value_low := l_segment_table_1(j).segment_value;
	     EXIT;
	  END IF;
	END LOOP;

        IF l_parent_value_low IS NOT NULL THEN
            OPEN parent_flex_low_desc_csr(
	       	l_segment_table(i).flex_value_set_id,
	       	l_segment_table(i).segment_value,
	       	l_parent_value_low);
       	    FETCH parent_flex_low_desc_csr INTO l_seg_desc;
       	    CLOSE parent_flex_low_desc_csr;
	END IF;

      END IF;

      IF i = 1 THEN
	l_concate_desc := l_seg_desc;
      ELSE
	l_concate_desc := l_concate_desc || l_delimiter || l_seg_desc;
      END IF;

    END LOOP;

    RETURN l_concate_desc;

   EXCEPTION
     WHEN OTHERS THEN
	   RETURN(SQLERRM);

END get_concate_desc;

/**************************************************************************/

  FUNCTION validate_lookup_code
    (p_lookup_type IN VARCHAR2,
	p_lookup_code IN VARCHAR2,
	p_app_id IN NUMBER DEFAULT 540,
	p_view_app_id IN NUMBER DEFAULT 0)
  RETURN VARCHAR2
  AS
    l_found VARCHAR2(1);
    l_sysdate	DATE := G_SYSDATE;

    CURSOR lkup_csr IS
    SELECT '1'
    FROM fnd_lookup_values flv,
    	 fnd_lookup_types flt
    WHERE
    	flv.lookup_type = p_lookup_type
    AND flv.view_application_id = p_view_app_id
    AND flv.lookup_code = p_lookup_code
    AND flv.security_group_id = fnd_global.lookup_security_group(flv.lookup_type, flv.view_application_id)
    AND flv.LANGUAGE = USERENV('LANG')
    AND flv.enabled_flag = 'Y'
    AND TRUNC(NVL(flv.start_date_active, l_sysdate)) <= TRUNC(l_sysdate)
    AND TRUNC(NVL(flv.end_date_active, l_sysdate)) >= TRUNC(l_sysdate)
    AND flv.lookup_type = flt.lookup_type
    AND flv.view_application_id = flt.view_application_id
    AND flv.security_group_id = flt.security_group_id
    AND flt.application_id = p_app_id;

  BEGIN

    OPEN lkup_csr ;
    FETCH lkup_csr INTO l_found;
    CLOSE lkup_csr;

    IF l_found IS NOT NULL THEN
      RETURN Okl_Api.g_true;
    ELSE
      RETURN Okl_Api.g_false;
    END IF;

  EXCEPTION
    WHEN OTHERS THEN
	  RETURN Okl_Api.g_false;

  END validate_lookup_code;


/**************************************************************************/

  PROCEDURE get_error_message
    (p_msg_count OUT NOCOPY NUMBER,
	p_msg_text OUT NOCOPY VARCHAR2)
  IS
    l_msg_text VARCHAR2(1000);
  BEGIN
    p_msg_count := fnd_msg_pub.count_msg;
    FOR i IN 1..p_msg_count
    LOOP
      fnd_msg_pub.get
        (p_data => l_msg_text,
        p_msg_index_out => p_msg_count,
	    p_encoded => fnd_api.g_false,
	    p_msg_index => fnd_msg_pub.g_next
        );
	  IF i = 1 THEN
	    p_msg_text := l_msg_text;
	  ELSE
	    p_msg_text := p_msg_text || '--' || l_msg_text;
	  END IF;
    END LOOP;
  EXCEPTION
    WHEN OTHERS THEN
	  p_msg_text := SQLERRM;
  END get_error_message;

/**************************************************************************/

  PROCEDURE get_error_message(p_all_message OUT NOCOPY error_message_type)
  IS
    l_msg_text VARCHAR2(2000);
    l_msg_count NUMBER ;
  BEGIN
    l_msg_count := fnd_msg_pub.count_msg;
    FOR i IN 1..l_msg_count
	LOOP
      fnd_msg_pub.get
        (p_data => p_all_message(i),
        p_msg_index_out => l_msg_count,
	    p_encoded => fnd_api.g_false,
	    p_msg_index => fnd_msg_pub.g_next
        );
    END LOOP;
  EXCEPTION
    WHEN OTHERS THEN
	  NULL;
  END get_error_message;

/**************************************************************************/
  --Bug 4700150. SGIYER. Wrote new procedure as first msg is not printing using std
  -- fnd procedure above. fnd_msg_pub.g_next does not return first msg in stack.
  -- For below procedure, stack must be cleared if processing within a loop.
  PROCEDURE get_error_msg(p_all_message OUT NOCOPY error_message_type)
  IS
    l_msg_text VARCHAR2(2000);
    l_msg_count NUMBER ;
    l_msg_index_out NUMBER;
    l_counter NUMBER := 1;
  BEGIN
    l_msg_count := fnd_msg_pub.count_msg;

    FOR i IN 1..l_msg_count
	LOOP
      l_msg_text := NULL;
      IF i = 1 THEN
      fnd_msg_pub.get
        (p_data => l_msg_text,
        p_msg_index_out => l_msg_index_out,
	    p_encoded => fnd_api.g_false,
	    p_msg_index => fnd_msg_pub.g_first
        );
      ELSE
      fnd_msg_pub.get
        (p_data => l_msg_text,
        p_msg_index_out => l_msg_index_out,
	    p_encoded => fnd_api.g_false,
	    p_msg_index => fnd_msg_pub.g_next
        );
      END IF;
      IF l_msg_text IS NOT NULL THEN
        p_all_message(l_counter) := l_msg_text;
        l_counter := l_counter + 1;
      END IF;
    END LOOP;
  EXCEPTION
    WHEN OTHERS THEN
	  NULL;
  END get_error_msg;

/**************************************************************************/

  FUNCTION validate_currency_code(p_currency_code IN VARCHAR2)
  RETURN VARCHAR2
  AS
    l_found VARCHAR2(1);
    l_sysdate	DATE := G_SYSDATE;

  CURSOR curr_csr IS
  SELECT '1'
  FROM fnd_currencies_vl
  WHERE currency_code = p_currency_code
  AND ENABLED_FLAG = 'Y'
  AND TRUNC(NVL(start_date_active, l_sysdate)) <= TRUNC(l_sysdate)
  AND TRUNC(NVL(end_date_active, l_sysdate)) >= TRUNC(l_sysdate);

  BEGIN

  OPEN curr_csr;
  FETCH curr_csr INTO l_found;
  CLOSE curr_csr;

  IF l_found IS NOT NULL THEN
    RETURN Okl_Api.G_TRUE;
  ELSE
    RETURN Okl_Api.G_FALSE;
  END IF;

  EXCEPTION
    WHEN OTHERS THEN
	  RETURN Okl_Api.G_FALSE;
  END validate_currency_code;

/**************************************************************************/
/* rkuttiya modified for Multi GAAP project
 * 10-JUL-2008 Added new parameter p_ledger_id
 */
  FUNCTION validate_gl_ccid(p_ccid IN VARCHAR2,
                            p_ledger_id IN NUMBER DEFAULT NULL)
  RETURN VARCHAR2
  AS
        l_found VARCHAR2(1);
	l_chart_of_accounts_id NUMBER;
	l_sysdate	DATE := G_SYSDATE;

      CURSOR coa_csr(p_ledger_id IN NUMBER) IS
      SELECT chart_of_accounts_id
      FROM GL_LEDGERS_PUBLIC_V
      WHERE ledger_id = NVL(p_ledger_id,get_set_of_books_id);

      CURSOR ccid_csr (l_chart_of_accounts_id NUMBER) IS
      SELECT '1'
      FROM gl_code_combinations
      WHERE code_combination_id = p_ccid
      AND chart_of_accounts_id = l_chart_of_accounts_id
      AND ENABLED_FLAG = 'Y'
      AND TRUNC(NVL(start_date_active, l_sysdate)) <= TRUNC(l_sysdate)
      AND TRUNC(NVL(end_date_active, l_sysdate)) >= TRUNC(l_sysdate);

  BEGIN

        OPEN coa_csr(p_ledger_id);
        FETCH coa_csr INTO l_chart_of_accounts_id;
        CLOSE coa_csr;

        OPEN ccid_csr (l_chart_of_accounts_id);
        FETCH ccid_csr INTO l_found;
        CLOSE ccid_csr;

	IF l_found IS NOT NULL THEN
	  RETURN Okl_Api.G_TRUE;
	ELSE
	  RETURN Okl_Api.G_FALSE;
	END IF;

  EXCEPTION
    WHEN OTHERS THEN
	  RETURN Okl_Api.G_FALSE;
  END validate_gl_ccid;

/**************************************************************************/
--Added p_ledger_id argument as part of bug 5707866 by nikshah
--If p_ledger_id passed to the API is null then it considers ledger from primary representation.
--Otherwise, it considers the ledger id that is passed to it.
--Cursor changed to accept one parameter: l_ledger_id

  FUNCTION get_okl_period_status(p_period_name IN VARCHAR2, p_ledger_id IN NUMBER DEFAULT NULL)
  RETURN VARCHAR2
  AS
    l_period_status VARCHAR2(1);
    l_ledger_id NUMBER;

    CURSOR sts_csr (l_ledger_id NUMBER) IS
    SELECT closing_status
    FROM gl_period_statuses
    WHERE application_id = 540
    AND ledger_id = l_ledger_id
    AND period_name = p_period_name;

  BEGIN
        l_ledger_id := p_ledger_id;
	IF l_ledger_id IS NULL
	THEN
	  l_ledger_id := get_set_of_books_id;
	END IF;
        OPEN sts_csr (l_ledger_id);
        FETCH sts_csr INTO l_period_status;
        CLOSE sts_csr;

	RETURN l_period_status;

  EXCEPTION
    WHEN OTHERS THEN
	  RETURN(NULL);
  END get_okl_period_status;

/**************************************************************************/
--Added p_ledger_id argument as part of bug 5707866 by nikshah
--If p_ledger_id passed to the API is null then it considers ledger from primary representation.
--Otherwise, it considers the ledger id that is passed to it.
--Cursor changed to accept one parameter: l_ledger_id

  FUNCTION get_gl_period_status(p_period_name IN VARCHAR2, p_ledger_id IN NUMBER DEFAULT NULL)
  RETURN VARCHAR2
  AS
    l_period_status VARCHAR2(1);
    l_ledger_id NUMBER;

    CURSOR sts_csr (l_ledger_id NUMBER) IS
    SELECT closing_status
    FROM gl_period_statuses
    WHERE application_id = 101
    AND ledger_id = l_ledger_id
    AND period_name = p_period_name;


  BEGIN
        l_ledger_id := p_ledger_id;
	IF l_ledger_id IS NULL
	THEN
	  l_ledger_id := get_set_of_books_id;
	END IF;
        OPEN sts_csr (l_ledger_id);
        FETCH sts_csr INTO l_period_status;
        CLOSE sts_csr;

	RETURN l_period_status;
  EXCEPTION
    WHEN OTHERS THEN
	  RETURN(NULL);
  END get_gl_period_status;

/**************************************************************************/
--Added p_ledger_id argument as part of bug 5707866 by nikshah
--If p_ledger_id passed to the API is null then it considers ledger from primary representation.
--Otherwise, it considers the ledger id that is passed to it.
--Cursor changed to accept one parameter: l_ledger_id

  PROCEDURE get_period_info(p_date IN DATE,
  p_period_name OUT NOCOPY VARCHAR2,
  p_start_date OUT NOCOPY DATE,
  p_end_date OUT NOCOPY DATE, p_ledger_id IN NUMBER DEFAULT NULL)
  AS
    l_period_name VARCHAR2(15);
    l_period_set_name VARCHAR2(15);
    l_user_period_type VARCHAR2(15);
    l_ledger_id NUMBER;

    CURSOR prd_set_csr (l_ledger_id NUMBER) IS
    SELECT period_set_name, accounted_period_type
    FROM GL_LEDGERS_PUBLIC_V
    WHERE ledger_id = l_ledger_id;

    CURSOR prd_name_csr (l_period_set_name VARCHAR2, l_user_period_type VARCHAR2) IS
    SELECT period_name, start_date, end_date
    FROM gl_periods
    WHERE TRUNC(start_date) <= TRUNC(p_date)
    AND TRUNC(end_date) >= TRUNC(p_date)
    AND period_set_name = l_period_set_name
    AND period_type = l_user_period_type
-- Added by Santonyr on 24-Dec-2002 for the bug fix 2675596
    AND NVL(ADJUSTMENT_PERIOD_FLAG, 'N') = 'N';

  BEGIN
  l_ledger_id := p_ledger_id;
  IF l_ledger_id IS NULL
  THEN
    l_ledger_id := get_set_of_books_id;
  END IF;

  OPEN prd_set_csr(l_ledger_id);
  FETCH prd_set_csr INTO l_period_set_name, l_user_period_type;
  CLOSE prd_set_csr;

  OPEN prd_name_csr (l_period_set_name, l_user_period_type);
  FETCH prd_name_csr INTO p_period_name, p_start_date, p_end_date;
  CLOSE prd_name_csr;

  EXCEPTION
    WHEN OTHERS THEN
	  NULL;
  END get_period_info;

/**************************************************************************/
--Added p_ledger_id argument as part of bug 5707866 by nikshah
--If p_ledger_id passed to the API is null then it considers ledger from primary representation.
--Otherwise, it considers the ledger id that is passed to it.
--Cursor changed to accept one parameter: l_ledger_id

  PROCEDURE get_period_info(p_period_name IN VARCHAR2,
  p_start_date OUT NOCOPY DATE,
  p_end_date OUT NOCOPY DATE, p_ledger_id IN NUMBER DEFAULT NULL)
  AS
    l_period_name VARCHAR2(15);
    l_period_set_name VARCHAR2(15);
    l_user_period_type VARCHAR2(15);
    l_ledger_id NUMBER;

    CURSOR perd_set_csr(l_ledger_id NUMBER) IS
    SELECT period_set_name, accounted_period_type
    FROM GL_LEDGERS_PUBLIC_V
    WHERE ledger_id = l_ledger_id;

    CURSOR perd_dt_csr (l_period_set_name VARCHAR2, l_user_period_type VARCHAR2) IS
    SELECT start_date, end_date
    FROM gl_periods
    WHERE period_name = p_period_name
    AND period_set_name = l_period_set_name
    AND period_type = l_user_period_type;

  BEGIN
    l_ledger_id := p_ledger_id;
    IF l_ledger_id IS NULL
    THEN
      l_ledger_id := get_set_of_books_id;
    END IF;
    OPEN perd_set_csr(l_ledger_id);
    FETCH perd_set_csr INTO l_period_set_name, l_user_period_type;
    CLOSE perd_set_csr;

    OPEN perd_dt_csr(l_period_set_name, l_user_period_type);
    FETCH perd_dt_csr INTO p_start_date, p_end_date;
    CLOSE perd_dt_csr;

  EXCEPTION
    WHEN OTHERS THEN
	  NULL;
  END get_period_info;

/**************************************************************************/

  FUNCTION validate_source_id_table
    (p_source_id IN NUMBER,
	p_source_table IN VARCHAR2)
	RETURN VARCHAR2
	AS
	  l_source_table_status VARCHAR2(1);
	  TYPE ref_cursor IS REF CURSOR;
	  source_csr ref_cursor;
	  l_select_string VARCHAR2(500);
	  l_found VARCHAR2(1);
	BEGIN
	  l_source_table_status := validate_lookup_code
                                 (p_lookup_type => 'OKL_SOURCE_TABLE',
	                             p_lookup_code => p_source_table,
	                             p_app_id => 540,
	                             p_view_app_id => 0);

	  IF l_source_table_status = 'T'
	  THEN
	    l_select_string := ' SELECT ''1'' FROM ' || p_source_table || ' WHERE id = :l_id ' ;

          EXECUTE IMMEDIATE l_select_string
            INTO l_found
            USING p_source_id;
	  ELSE
	    RETURN okl_api.g_false;
	  END IF;
	  RETURN okl_api.g_true;
    EXCEPTION
	  WHEN OTHERS THEN
	    RETURN okl_api.g_false;
	END validate_source_id_table;

/**************************************************************************/
--Added p_ledger_id argument as part of bug 5707866 by nikshah
--If p_ledger_id passed to the API is null then it considers ledger from primary representation.
--Otherwise, it considers the ledger id that is passed to it.
--Cursor changed to accept one parameter: l_ledger_id

  PROCEDURE get_set_of_books
    (p_set_of_books_id OUT NOCOPY NUMBER,
	p_set_of_books_name OUT NOCOPY VARCHAR2, p_ledger_id IN NUMBER DEFAULT NULL)
  AS
    l_ledger_id NUMBER;
  BEGIN
    l_ledger_id := p_ledger_id;
    IF l_ledger_id IS NULL
    THEN
      l_ledger_id := get_set_of_books_id;
    END IF;
    p_set_of_books_id := l_ledger_id;
	p_set_of_books_name := get_set_of_books_name(p_set_of_books_id => l_ledger_id);
  END get_set_of_books;

/**************************************************************************/

/* rkuttiya modified on 10-JUl-2008
 * for Multi GAAP Project added new parameter p_representation_type
 */

  FUNCTION get_set_of_books_id(p_representation_type IN VARCHAR2 DEFAULT
'PRIMARY')
  RETURN NUMBER
  IS
    l_set_of_books_id NUMBER;

    CURSOR set_of_book_id
    IS
    SELECT set_of_books_id
    FROM OKL_SYS_ACCT_OPTS;

    CURSOR c_ledger_id IS
    SELECT ledger_id
    FROM okl_representations_v
    WHERE representation_type = 'SECONDARY';

  BEGIN
    IF p_representation_type = 'PRIMARY' THEN
       OPEN set_of_book_id;
       FETCH set_of_book_id INTO l_set_of_books_id;
       CLOSE set_of_book_id;
    ELSIF p_representation_type = 'SECONDARY' THEN
       OPEN c_ledger_id;
       FETCH c_ledger_id INTO l_set_of_books_id;
       CLOSE c_ledger_id;
    END IF;
    RETURN l_set_of_books_id;

  EXCEPTION
    WHEN OTHERS THEN
      RETURN NULL;
  END get_set_of_books_id;

/**************************************************************************/

  FUNCTION get_set_of_books_name(p_set_of_books_id IN NUMBER)
  RETURN VARCHAR2
  IS
    l_set_of_books_name VARCHAR2(30);

    CURSOR set_of_book_name IS
    SELECT name
    FROM GL_LEDGERS_PUBLIC_V
    WHERE ledger_id =  p_set_of_books_id;

  BEGIN

    OPEN set_of_book_name;
    FETCH set_of_book_name INTO l_set_of_books_name;
    CLOSE set_of_book_name;

    RETURN l_set_of_books_name;

  EXCEPTION
    WHEN OTHERS THEN
	  RETURN NULL;
  END get_set_of_books_name;

/**************************************************************************/

  FUNCTION round_amount
    (p_amount IN NUMBER,
     p_currency_code IN VARCHAR2)
  RETURN NUMBER
  AS
    l_rounding_rule VARCHAR2(30);
    l_precision NUMBER;
    l_rounded_amount NUMBER := 0;
    l_pos_dot NUMBER;
    l_to_add NUMBER := 1;
    l_sysdate	DATE := G_SYSDATE;

    CURSOR ael_csr IS
    SELECT ael_rounding_rule
    FROM OKL_SYS_ACCT_OPTS;

    CURSOR prec_csr IS
    SELECT PRECISION
    FROM fnd_currencies_vl
    WHERE currency_code = p_currency_code
    AND enabled_flag = 'Y'
    AND TRUNC(NVL(start_date_active, l_sysdate)) <= TRUNC(l_sysdate)
    AND TRUNC(NVL(end_date_active, l_sysdate)) >= TRUNC(l_sysdate);

  BEGIN

    OPEN ael_csr;
    FETCH ael_csr INTO l_rounding_rule;
    CLOSE ael_csr;

    OPEN prec_csr;
    FETCH prec_csr INTO l_precision;
    CLOSE prec_csr;

    IF (l_rounding_rule = 'UP') THEN
      l_pos_dot := INSTR(TO_CHAR(p_amount),'.') ;
      IF (l_pos_dot > 0) AND (SUBSTR(p_amount,l_pos_dot+l_precision+1,1) IS NOT NULL) THEN
        FOR i IN 1..l_precision LOOP
          l_to_add := l_to_add/10;
        END LOOP;
          l_rounded_amount := p_amount + l_to_add;
      ELSE
          l_rounded_amount := p_amount;
      END IF;
	  l_rounded_amount := TRUNC(l_rounded_amount,l_precision);
   	ELSIF l_rounding_rule = 'DOWN' THEN
	  l_rounded_amount := TRUNC(p_amount, l_precision);

	ELSIF  l_rounding_rule = 'NEAREST' THEN
	  l_rounded_amount := ROUND(p_amount, l_precision);
	END IF;

	RETURN l_rounded_amount;
  EXCEPTION
    WHEN OTHERS THEN
	  RETURN 0;
  END round_amount;

/******************************************************************************
  The Procedure accepts 3 values.
       Amount
       Currency Code
       Round Option(For rounding cross currency pass the value 'CC',for Streams
                    'STM' and for Accounting Lines 'AEL')
*******************************************************************************/

PROCEDURE round_amount
    (p_api_version      IN NUMBER,
     p_init_msg_list 	IN VARCHAR2,
     x_return_status    OUT NOCOPY VARCHAR2,
     x_msg_count 	OUT NOCOPY NUMBER,
     x_msg_data 	OUT NOCOPY VARCHAR2,
     p_amount 		IN NUMBER,
     p_currency_code 	IN VARCHAR2,
     p_round_option     IN VARCHAR2,
     x_rounded_amount	OUT NOCOPY NUMBER)

IS
    l_rounding_rule    VARCHAR2(30);
    l_precision NUMBER;
    l_rounded_amount NUMBER := 0;
    l_pos_dot NUMBER;
    l_to_add NUMBER := 1;
    l_sysdate	DATE := G_SYSDATE;

    l_init_msg_list    VARCHAR2(1) := OKL_API.G_FALSE;
    l_return_status    VARCHAR2(1) := OKL_API.G_RET_STS_SUCCESS;
    l_msg_count        NUMBER := 0;
    l_msg_data         VARCHAR2(2000);
    l_api_version      NUMBER := 1.0;

    CURSOR round_csr IS
    SELECT cc_rounding_rule,
           ael_rounding_rule,
           stm_rounding_rule
    FROM OKL_SYS_ACCT_OPTS;


    CURSOR prec_csr IS
    SELECT PRECISION
    FROM fnd_currencies_vl
    WHERE currency_code = p_currency_code
    AND enabled_flag = 'Y'
    AND TRUNC(NVL(start_date_active, l_sysdate)) <= TRUNC(l_sysdate)
    AND TRUNC(NVL(end_date_active, l_sysdate)) >= TRUNC(l_sysdate);

BEGIN

    x_return_status         := OKL_API.G_RET_STS_SUCCESS;

       IF (p_round_option ='CC') THEN
         FOR round_rec IN round_csr LOOP
           l_rounding_rule := round_rec.cc_rounding_rule;
         END LOOP;
       ELSIF (p_round_option ='STM') THEN
         FOR round_rec IN round_csr LOOP
           l_rounding_rule := round_rec.stm_rounding_rule;
         END LOOP;
       ELSIF (p_round_option = 'AEL') THEN
         FOR round_rec IN round_csr LOOP
           l_rounding_rule := round_rec.ael_rounding_rule;
         END LOOP;
       ELSE
         Okc_Api.SET_MESSAGE(p_app_name       => g_app_name
                            ,p_msg_name       => g_invalid_value
                            ,p_token1         => g_col_name_token
                            ,p_token1_value   => 'ROUND_OPTION');
         x_return_status := OKL_API.G_RET_STS_ERROR;
         RAISE OKL_API.G_EXCEPTION_ERROR;

       END IF;


       IF l_rounding_rule IS NULL THEN
       OKL_API.SET_MESSAGE(p_app_name     => g_app_name,
                          p_msg_name     => 'OKL_NO_ROUNDING_RULE');
       x_return_status := OKL_API.G_RET_STS_ERROR;
       RAISE OKL_API.G_EXCEPTION_ERROR;
     END IF;


    FOR prec_rec IN prec_csr LOOP
       l_precision := prec_rec.precision;
    END LOOP;

    IF l_precision IS NULL THEN
       OKL_API.SET_MESSAGE(p_app_name     => g_app_name,
                           p_msg_name     => 'OKL_NO_CURR_PRECISION',
                           p_token1         => 'CURRENCY_CODE',
                           p_token1_value   => p_currency_code);
       x_return_status := OKL_API.G_RET_STS_ERROR;
       RAISE OKL_API.G_EXCEPTION_ERROR;
     END IF;


    IF (l_rounding_rule = 'UP') THEN
      l_pos_dot := INSTR(TO_CHAR(p_amount),'.') ;
      IF (l_pos_dot > 0) AND (SUBSTR(p_amount,l_pos_dot+l_precision+1,1) IS NOT NULL) THEN
        FOR i IN 1..l_precision LOOP
          l_to_add := l_to_add/10;
        END LOOP;
          l_rounded_amount := p_amount + l_to_add;
      ELSE
          l_rounded_amount := p_amount;
      END IF;
	  l_rounded_amount := TRUNC(l_rounded_amount,l_precision);
   	ELSIF l_rounding_rule = 'DOWN' THEN
	  l_rounded_amount := TRUNC(p_amount, l_precision);

	ELSIF  l_rounding_rule = 'NEAREST' THEN
	  l_rounded_amount := ROUND(p_amount, l_precision);
	END IF;

	x_rounded_amount := l_rounded_amount;

EXCEPTION

  WHEN OKL_API.G_EXCEPTION_ERROR THEN
     x_return_status := OKL_API.G_RET_STS_ERROR ;

  WHEN OTHERS THEN
       OKL_API.SET_MESSAGE(p_app_name     => g_app_name,
                          p_msg_name     => 'OKL_ERROR_ROUNDING_AMT');
       x_return_status := OKL_API.G_RET_STS_UNEXP_ERROR;

END round_amount;





/**************************************************************************/

  FUNCTION get_curr_con_rate
    (p_from_curr_code IN VARCHAR2,
	p_to_curr_code IN VARCHAR2,
	p_con_date IN DATE,
	p_con_type IN VARCHAR2)
  RETURN NUMBER
  AS
  BEGIN

  RETURN (Gl_Currency_Api.get_rate_sql
    (x_from_currency => p_from_curr_code,
	x_to_currency => p_to_curr_code,
	x_conversion_date => p_con_date,
	x_conversion_type => p_con_type));

  EXCEPTION
    WHEN OTHERS THEN
	  RETURN 0;
  END get_curr_con_rate;

/**************************************************************************/


/*
Returns currency conversion rate
*/

PROCEDURE get_curr_con_rate
     (p_api_version      IN NUMBER,
     p_init_msg_list 	IN VARCHAR2,
     x_return_status    OUT NOCOPY VARCHAR2,
     x_msg_count 	OUT NOCOPY NUMBER,
     x_msg_data 	OUT NOCOPY VARCHAR2,
     p_from_curr_code 	IN VARCHAR2,
     p_to_curr_code 	IN VARCHAR2,
     p_con_date 	IN DATE,
     p_con_type 	IN VARCHAR2,
     x_conv_rate 	OUT NOCOPY NUMBER)

IS
    l_rate NUMBER;
BEGIN

 x_return_status         := OKL_API.G_RET_STS_SUCCESS;

 l_rate := Gl_Currency_Api.get_rate_sql
        (x_from_currency => p_from_curr_code,
	x_to_currency => p_to_curr_code,
	x_conversion_date => p_con_date,
	x_conversion_type => p_con_type);

  IF l_rate = -1 THEN
      OKL_API.SET_MESSAGE(p_app_name     => g_app_name,
                          p_msg_name     => 'OKL_NO_RATE_FOR_CONV',
                          p_token1        => 'FROM_CURR',
                          p_token1_value  => p_from_curr_code,
                          p_token2        => 'TO_CURR',
                          p_token2_value  => p_to_curr_code);
      x_return_status := OKL_API.G_RET_STS_ERROR;
      RAISE OKL_API.G_EXCEPTION_ERROR;
  END IF;

  IF l_rate = -2 THEN
      OKL_API.SET_MESSAGE(p_app_name     => g_app_name,
                          p_msg_name     => 'OKL_NO_CURR_FOR_CONV');
      x_return_status := OKL_API.G_RET_STS_ERROR;
      RAISE OKL_API.G_EXCEPTION_ERROR;
  END IF;

  x_conv_rate := l_rate;

EXCEPTION

  WHEN OKL_API.G_EXCEPTION_ERROR THEN
    x_return_status := OKL_API.G_RET_STS_ERROR ;

  WHEN OTHERS THEN
     x_return_status := OKL_API.G_RET_STS_UNEXP_ERROR;

END get_curr_con_rate;

/**************************************************************************/

/* rkuttiya modified 10-Jul-2008
 * Multi GAAP Project added new parametr p_ledger_id
 */

  PROCEDURE get_accounting_segment
    (p_segment_array OUT NOCOPY seg_num_name_type,
     p_ledger_id     IN NUMBER DEFAULT NULL)
  AS
	l_chart_of_accounts_id NUMBER;

	CURSOR coa_csr(p_ledger_id IN NUMBER) IS
	SELECT chart_of_accounts_id
	FROM GL_LEDGERS_PUBLIC_V
	WHERE ledger_id = NVL(p_ledger_id,get_set_of_books_id);

	CURSOR seg_csr (l_chart_of_accounts_id NUMBER) IS
	SELECT segment_num,
               application_column_name,
               form_left_prompt
	FROM fnd_id_flex_segments_vl
    	WHERE application_id = 101
	    AND id_flex_code = 'GL#'
	    AND enabled_flag = 'Y'
	    AND id_flex_num = l_chart_of_accounts_id;

  BEGIN

	OPEN coa_csr(p_ledger_id);
	FETCH coa_csr INTO l_chart_of_accounts_id;
	CLOSE coa_csr;

	OPEN seg_csr (l_chart_of_accounts_id);
	FETCH seg_csr BULK COLLECT INTO p_segment_array.seg_num,
					p_segment_array.seg_name,
					p_segment_array.seg_desc;
	CLOSE seg_csr;

  EXCEPTION
    WHEN OTHERS THEN
	  NULL;
  END get_accounting_segment;

/* rkuttiya modified 10-Jul-2008
 * Multi GAAP Project added new parameter p_ledgeR_id
 */

FUNCTION get_segment_desc(p_segment IN VARCHAR2,
                          p_ledger_id IN NUMBER DEFAULT NULL)
  RETURN VARCHAR2
AS

  l_chart_of_accounts_id NUMBER;
  l_segment_desc FND_ID_FLEX_SEGMENTS_VL.FORM_LEFT_PROMPT%TYPE;

	CURSOR coa_csr(p_ledger_id IN NUMBER) IS
	SELECT chart_of_accounts_id
	FROM GL_LEDGERS_PUBLIC_V
	WHERE ledger_id = NVL(p_ledger_id,get_set_of_books_id);

	CURSOR seg_csr (l_chart_of_accounts_id NUMBER) IS
	SELECT form_left_prompt
     	FROM fnd_id_flex_segments_vl
     	WHERE application_id = 101
     	AND   id_flex_code = 'GL#'
     	AND   enabled_flag = 'Y'
     	AND   id_flex_num = l_chart_of_accounts_id
     	AND   application_column_name = p_segment;

  BEGIN

  	OPEN coa_csr(p_ledger_id);
  	FETCH coa_csr INTO l_chart_of_accounts_id;
  	CLOSE coa_csr;

  	OPEN seg_csr (l_chart_of_accounts_id);
  	FETCH seg_csr INTO l_segment_desc;
  	CLOSE seg_csr;

   RETURN (l_segment_desc);

  EXCEPTION
    WHEN OTHERS THEN
       RETURN NULL;

END get_segment_desc;

/**************************************************************************/

  FUNCTION get_lookup_meaning
    (p_lookup_type IN VARCHAR2,
	p_lookup_code IN VARCHAR2,
	p_app_id IN NUMBER DEFAULT 540,
	p_view_app_id IN NUMBER DEFAULT 0)
  RETURN VARCHAR2
  AS
    l_meaning 		VARCHAR2(240);
    l_sysdate	DATE := G_SYSDATE;

    CURSOR lkup_csr IS
    SELECT meaning
    FROM fnd_lookup_values flv,
    	 fnd_lookup_types flt
    WHERE
    	flv.lookup_type = p_lookup_type
    AND flv.view_application_id = p_view_app_id
    AND flv.lookup_code = p_lookup_code
    AND flv.security_group_id = fnd_global.lookup_security_group(flv.lookup_type, flv.view_application_id)
    AND flv.LANGUAGE = USERENV('LANG')
    AND flv.enabled_flag = 'Y'
    AND TRUNC(NVL(flv.start_date_active, l_sysdate)) <= TRUNC(l_sysdate)
    AND TRUNC(NVL(flv.end_date_active, l_sysdate)) >= TRUNC(l_sysdate)
    AND flv.lookup_type = flt.lookup_type
    AND flv.view_application_id = flt.view_application_id
    AND flv.security_group_id = flt.security_group_id
    AND flt.application_id = p_app_id;

  BEGIN

    OPEN lkup_csr;
    FETCH lkup_csr INTO l_meaning;
    CLOSE lkup_csr;

    RETURN l_meaning;

  EXCEPTION
    WHEN OTHERS THEN
	  RETURN NULL;
  END get_lookup_meaning;

/**************************************************************************/

  FUNCTION get_lookup_meaning_lang
    (p_lookup_type IN VARCHAR2,
	p_lookup_code IN VARCHAR2,
	p_app_id IN NUMBER DEFAULT 540,
	p_view_app_id IN NUMBER DEFAULT 0,
    p_language IN VARCHAR2 DEFAULT USERENV('LANG'))
  RETURN VARCHAR2
  AS
    l_meaning 		VARCHAR2(240);
    l_sysdate	DATE := G_SYSDATE;

    CURSOR lkup_csr IS
    SELECT meaning
    FROM fnd_lookup_values flv,
    	 fnd_lookup_types flt
    WHERE
    	flv.lookup_type = p_lookup_type
    AND flv.view_application_id = p_view_app_id
    AND flv.lookup_code = p_lookup_code
    AND flv.security_group_id = fnd_global.lookup_security_group(flv.lookup_type, flv.view_application_id)
    AND flv.LANGUAGE = p_language
    AND flv.enabled_flag = 'Y'
    AND TRUNC(NVL(flv.start_date_active, l_sysdate)) <= TRUNC(l_sysdate)
    AND TRUNC(NVL(flv.end_date_active, l_sysdate)) >= TRUNC(l_sysdate)
    AND flv.lookup_type = flt.lookup_type
    AND flv.view_application_id = flt.view_application_id
    AND flv.security_group_id = flt.security_group_id
    AND flt.application_id = p_app_id;

  BEGIN

    OPEN lkup_csr;
    FETCH lkup_csr INTO l_meaning;
    CLOSE lkup_csr;

    RETURN l_meaning;

  EXCEPTION
    WHEN OTHERS THEN
	  RETURN NULL;
  END get_lookup_meaning_lang;

/**************************************************************************/

  FUNCTION validate_currency_con_type
  (p_currency_con_type IN VARCHAR2)
  RETURN VARCHAR2
  AS
	l_return VARCHAR2(1);

	CURSOR curr_csr IS
	SELECT '1'
	FROM gl_daily_conversion_types
	WHERE conversion_type = p_currency_con_type;

  BEGIN

       OPEN curr_csr;
       FETCH curr_csr INTO l_return;
       CLOSE curr_csr;

       IF l_return IS NOT NULL THEN
         RETURN okl_api.g_true;
       ELSE
         RETURN okl_api.g_false;
       END IF;

  EXCEPTION
	WHEN OTHERS THEN
	  RETURN okl_api.g_false;
  END validate_currency_con_type;

/**************************************************************************/
--Added p_ledger_id argument as part of bug 5707866 by nikshah
--If p_ledger_id passed to the API is null then it considers ledger from primary representation.
--Otherwise, it considers the ledger id that is passed to it.
--Cursor changed to accept one parameter: l_ledger_id
  FUNCTION get_func_curr_code (p_ledger_id IN NUMBER DEFAULT NULL)
  RETURN VARCHAR2 IS
	l_currency_code	VARCHAR2(15);
	l_ledger_id NUMBER;

	CURSOR curr_csr (l_ledger_id NUMBER) IS
	SELECT currency_code
    	FROM   GL_LEDGERS_PUBLIC_V
    	WHERE  ledger_id = l_ledger_id;

  BEGIN
    l_ledger_id := p_ledger_id;
    IF l_ledger_id IS NULL
    THEN
      l_ledger_id := get_set_of_books_id;
    END IF;

    OPEN curr_csr(l_ledger_id);
    FETCH curr_csr INTO l_currency_code;
    CLOSE curr_csr;

    RETURN l_currency_code;
  EXCEPTION
    WHEN OTHERS THEN
      RETURN NULL;
  END get_func_curr_code;

/*************************************************************************/
  FUNCTION validate_journal_category(p_category IN VARCHAR2)
  RETURN VARCHAR2
  IS
	l_found	VARCHAR2(1);

	CURSOR cat_csr IS
	SELECT '1'
    	FROM   gl_je_categories
    	WHERE  je_category_name = p_category;

  BEGIN

    OPEN cat_csr;
    FETCH cat_csr INTO l_found;
    CLOSE cat_csr;

    IF l_found IS NOT NULL THEN
      RETURN okl_api.g_true;
    ELSE
      RETURN okl_api.g_false;
    END IF;

  EXCEPTION
    WHEN OTHERS THEN
      RETURN okl_api.g_false;
  END validate_journal_category;

  /*************************************************************************/
  --Added p_ledger_id argument as part of bug 5707866 by nikshah
  --If p_ledger_id passed to the API is null then it considers ledger from primary representation.
  --Otherwise, it considers the ledger id that is passed to it.
  --Cursor changed to accept one parameter: l_ledger_id

  FUNCTION get_chart_of_accounts_id (p_ledger_id IN NUMBER DEFAULT NULL)
  RETURN NUMBER
  AS
    l_chart_of_accounts_id NUMBER;
    l_ledger_id NUMBER;

    CURSOR coa_csr (l_ledger_id NUMBER) IS
    SELECT chart_of_accounts_id
    FROM GL_LEDGERS_PUBLIC_V
    WHERE ledger_id = l_ledger_id;

  BEGIN
    l_ledger_id := p_ledger_id;
    IF l_ledger_id IS NULL
    THEN
      l_ledger_id := get_set_of_books_id;
    END IF;

    OPEN coa_csr(l_ledger_id);
    FETCH coa_csr INTO l_chart_of_accounts_id;
    CLOSE coa_csr;

    RETURN l_chart_of_accounts_id;

  EXCEPTION
    WHEN OTHERS THEN
	  RETURN -1;
  END get_chart_of_accounts_id;


-- mvasudev , 9/25/01
---------------------------------------------------------------------------
-- PROCEDURE check_overlaps
-- To avoid overlapping of dates with other versions of the same attribute-value
-- Applicable with any given attribute and its value
---------------------------------------------------------------------------
  PROCEDURE check_overlaps (
	p_id						IN NUMBER,
    p_attrib_tbl				IN overlap_attrib_tbl_type,
  	p_start_date_attribute_name	IN VARCHAR2 DEFAULT 'START_DATE',
  	p_start_date				IN DATE,
	p_end_date_attribute_name	IN VARCHAR2 DEFAULT 'END_DATE',
	p_end_date					IN DATE,
	p_view						IN VARCHAR2,
	x_return_status				OUT NOCOPY VARCHAR2,
	x_valid						OUT NOCOPY BOOLEAN)
  IS

    TYPE GenericCurTyp IS REF CURSOR;
	okl_all_overlaps_csr	GenericCurTyp;
	l_where_clause		VARCHAR2(500)	:= '';
	i				INTEGER	:= 0;
 	l_apostrophe	VARCHAR2(5)	:= '';
	l_sql_stmt		VARCHAR2(1000);
	l_check            VARCHAR2(1) := '?';
	l_row_found	   BOOLEAN := FALSE;
	l_col_names		VARCHAR2(50);
	l_start_date		DATE;
	l_end_date		DATE;

  G_UNEXPECTED_ERROR          CONSTANT VARCHAR2(200) := 'OKL_CONTRACTS_UNEXPECTED_ERROR';
  G_VERSION_OVERLAPS		  CONSTANT VARCHAR2(200) := 'OKL_VERSION_OVERLAPS';
  G_SQLERRM_TOKEN             CONSTANT VARCHAR2(200) := 'OKL_SQLERRM';
  G_SQLCODE_TOKEN             CONSTANT VARCHAR2(200) := 'OKL_SQLCODE';
  G_TABLE_TOKEN		  		  CONSTANT VARCHAR2(100) := 'OKL_TABLE_NAME';
  G_PARENT_TABLE_TOKEN		  CONSTANT VARCHAR2(100) := OKL_API.G_PARENT_TABLE_TOKEN;
  G_CHILD_TABLE_TOKEN		  CONSTANT VARCHAR2(100) := OKL_API.G_CHILD_TABLE_TOKEN;
  G_COL_NAME_TOKEN			  CONSTANT VARCHAR2(100) := OKL_API.G_COL_NAME_TOKEN;

  G_APP_NAME				  CONSTANT VARCHAR2(3)   :=  OKL_API.G_APP_NAME;

  FUNCTION format_date(p_date DATE) RETURN VARCHAR2
  IS
  l_str VARCHAR2(200);
  BEGIN

  -- Changed the format mask from DD-MM-RRRR to DD/MM/RRRR
  l_str := 'TO_DATE(' || '''' || TO_CHAR(p_date,'DD/MM/RRRR') || '''' || ',(' || '''' || 'DD/MM/RRRR' || '''' || '))';
  RETURN l_str;
  END;




  BEGIN
    x_valid := TRUE;
    x_return_status := OKL_API.G_RET_STS_SUCCESS;

	l_start_date := p_start_date;
	l_end_date := p_end_date;
	IF l_end_date IS NULL
	   THEN l_end_date := G_FINAL_DATE;
	END IF;

	i := p_attrib_tbl.FIRST;
    LOOP

  		IF p_attrib_tbl(i).attrib_type = G_VARCHAR2
		THEN
			l_apostrophe	:= '''';
  		ELSIF p_attrib_tbl(i).attrib_type = G_NUMBER
		THEN
			l_apostrophe	:= '';
		END IF;

			IF LENGTH(l_where_clause) > 0 THEN
				l_col_names := ', ';
			END IF;
		l_col_names := l_col_names || p_attrib_tbl(i).attribute;

		l_where_clause := l_where_clause || ' AND ' || p_attrib_tbl(i).attribute  || '='  || l_apostrophe || p_attrib_tbl(i).value || l_apostrophe ;

    EXIT WHEN (i = p_attrib_tbl.LAST);
    i := p_attrib_tbl.NEXT(i);
    END LOOP;

    -- Check for overlaps
	l_sql_stmt := 'SELECT ''1'' ' ||
				  'FROM ' || p_view ||
				  ' WHERE id <>  ' || p_id ||
                  l_where_clause ||
                  ' AND ( ' || format_date(l_start_date ) ||
				  ' BETWEEN ' || p_start_date_attribute_name || ' AND ' ||
				  ' NVL(' || p_end_date_attribute_name || ',' || format_date(g_final_date) || ') OR '
               	  || format_date(l_end_date) ||
				  ' BETWEEN ' || p_start_date_attribute_name || ' AND ' ||
				  ' NVL(' || p_end_date_attribute_name || ', ' || format_date(g_final_date) || ')) ' ||
				  ' UNION ALL ' ||
			   	  'SELECT ''2'' ' ||
				  'FROM ' || p_view ||
				  ' WHERE id <>  ' || p_id ||
                  l_where_clause ||
				  ' AND ' || format_date(l_start_date ) ||
				  ' <= ' || p_start_date_attribute_name ||
				  ' AND ' || format_date(l_end_date ) ||
				  ' >= NVL(' || p_end_date_attribute_name || ', ' || format_date(g_final_date) || ') ';

    OPEN okl_all_overlaps_csr
	FOR l_sql_stmt;
    FETCH okl_all_overlaps_csr INTO l_check;
    l_row_found := okl_all_overlaps_csr%FOUND;
    CLOSE okl_all_overlaps_csr;

    IF l_row_found = TRUE THEN
       	   OKL_API.SET_MESSAGE(p_app_name		=> G_APP_NAME,
						   p_msg_name		=> G_VERSION_OVERLAPS,
						   p_token1			=> G_TABLE_TOKEN,
						   p_token1_value	=> p_view,
						   p_token2			=> G_COL_NAME_TOKEN,
						   p_token2_value	=> l_col_names);
	   x_valid := FALSE;
       x_return_status := OKL_API.G_RET_STS_ERROR;
    END IF;


  EXCEPTION
	WHEN OTHERS THEN
		-- store SQL error message on message stack
		OKL_API.SET_MESSAGE(p_app_name	=>	G_APP_NAME,
							p_msg_name	=>	G_UNEXPECTED_ERROR,
							p_token1	=>	G_SQLCODE_TOKEN,
							p_token1_value	=>	SQLCODE,
							p_token2	=>	G_SQLERRM_TOKEN,
							p_token2_value	=>	SQLERRM);
	   x_valid := FALSE;
	   x_return_status := OKL_API.G_RET_STS_UNEXP_ERROR;

       IF (okl_all_overlaps_csr%ISOPEN) THEN
	   	  CLOSE okl_all_overlaps_csr;
       END IF;


  END check_overlaps;
-- mvasudev, end


-- mvasudev, 10/02/01
---------------------------------------------------------------------------
-- PROCEDURE get_version to calculate the new version number for the
-- entity to be created - with any attribute and its value to check with
---------------------------------------------------------------------------
  PROCEDURE get_version(
    p_attrib_tbl				IN overlap_attrib_tbl_type,
  	p_cur_version				   IN VARCHAR2,
	p_end_date_attribute_name	IN VARCHAR2 DEFAULT 'END_DATE',
	p_end_date					IN DATE,
	p_view						IN VARCHAR2,
  	x_return_status				   OUT NOCOPY VARCHAR2,
	x_new_version				   OUT NOCOPY VARCHAR2) IS

	  TYPE GenericCurTyp IS REF CURSOR;
	okl_all_laterversionsexist_csr	GenericCurTyp;
	l_where_clause		VARCHAR2(500)	:= '';
	i				INTEGER	:= 0;
 	l_apostrophe	VARCHAR2(5)	:= '';
    l_and			VARCHAR2(10) := ' WHERE ';
	l_sql_stmt		VARCHAR2(1000);
	l_check			VARCHAR2(1) := '?';
	l_row_not_found	BOOLEAN := FALSE;


  G_UNEXPECTED_ERROR          CONSTANT VARCHAR2(200) := 'OKL_CONTRACTS_UNEXPECTED_ERROR';
  G_SQLERRM_TOKEN             CONSTANT VARCHAR2(200) := 'OKL_SQLERRM';
  G_SQLCODE_TOKEN             CONSTANT VARCHAR2(200) := 'OKL_SQLCODE';
  G_TABLE_TOKEN		  		  CONSTANT VARCHAR2(100) := 'OKL_TABLE_NAME';
  G_PARENT_TABLE_TOKEN		  CONSTANT VARCHAR2(100) := OKL_API.G_PARENT_TABLE_TOKEN;
  G_CHILD_TABLE_TOKEN		  CONSTANT VARCHAR2(100) := OKL_API.G_CHILD_TABLE_TOKEN;
  G_COL_NAME_TOKEN			  CONSTANT VARCHAR2(100) := OKL_API.G_COL_NAME_TOKEN;

  G_APP_NAME				  CONSTANT VARCHAR2(3)   :=  OKL_API.G_APP_NAME;

  G_INIT_VERSION			  CONSTANT NUMBER := 1.0;
  G_VERSION_MAJOR_INCREMENT	  CONSTANT NUMBER := 1.0;
  G_VERSION_MINOR_INCREMENT	  CONSTANT NUMBER := 0.1;
  G_VERSION_FORMAT			  CONSTANT VARCHAR2(100) := 'FM999.0999';


  BEGIN
  	   IF p_cur_version = OKL_API.G_MISS_CHAR THEN
	   	  x_new_version := G_INIT_VERSION;
	   ELSE
    	i := p_attrib_tbl.FIRST;
        LOOP
      		IF p_attrib_tbl(i).attrib_type = G_VARCHAR2
    		THEN
    			l_apostrophe	:= '''';
      		ELSIF p_attrib_tbl(i).attrib_type = G_NUMBER
    		THEN
    			l_apostrophe	:= '';
    		END IF;

			IF LENGTH(l_where_clause) > 0 THEN
				l_and := ' AND ';
			ELSE
				l_and := ' WHERE ';
			END IF;

    		l_where_clause := l_where_clause || l_and || p_attrib_tbl(i).attribute  || '='  || l_apostrophe || p_attrib_tbl(i).value || l_apostrophe ;

        EXIT WHEN (i = p_attrib_tbl.LAST);
        i := p_attrib_tbl.NEXT(i);
        END LOOP;
          -- Check for future versions of the same pricing template
		  l_sql_stmt := 'SELECT ''1'' ' ||
		  	  		 	'FROM ' || p_view ||
						l_where_clause ||
			  			' AND NVL(' || p_end_date_attribute_name || ', ' ||
						'''' || OKL_API.G_MISS_DATE || '''' || ') > ' ||
						'''' || p_end_date || '''';

		  OPEN okl_all_laterversionsexist_csr
		  FOR l_sql_stmt;
    	  FETCH okl_all_laterversionsexist_csr INTO l_check;
    	  l_row_not_found := okl_all_laterversionsexist_csr%NOTFOUND;
    	  CLOSE okl_all_laterversionsexist_csr;

    	  IF l_row_not_found = TRUE THEN
  	   	   	 x_new_version := TO_CHAR(TO_NUMBER(p_cur_version, G_VERSION_FORMAT)
			                  + G_VERSION_MAJOR_INCREMENT, G_VERSION_FORMAT);
		  ELSE
		  	 x_new_version := TO_CHAR(TO_NUMBER(p_cur_version, G_VERSION_FORMAT)
			 			   	  + G_VERSION_MINOR_INCREMENT, G_VERSION_FORMAT);
    	  END IF;
	   END IF;

	   x_return_status := OKL_API.G_RET_STS_SUCCESS;
  EXCEPTION
	WHEN OTHERS THEN
		-- store SQL error message on message stack
		OKL_API.SET_MESSAGE(p_app_name	    =>	G_APP_NAME,
							p_msg_name		=>	G_UNEXPECTED_ERROR,
							p_token1		=>	G_SQLCODE_TOKEN,
							p_token1_value	=>	SQLCODE,
							p_token2		=>	G_SQLERRM_TOKEN,
							p_token2_value	=>	SQLERRM);
	   x_return_status := OKL_API.G_RET_STS_UNEXP_ERROR;

       IF (okl_all_laterversionsexist_csr%ISOPEN) THEN
	   	  CLOSE okl_all_laterversionsexist_csr;
       END IF;

  END get_version;
-- mvasudev, end

---------------------------------------------------------------------------
-- PROCEDURE okl_upper to convert a string in upper
---------------------------------------------------------------------------

FUNCTION okl_upper(p_string IN VARCHAR2)
RETURN VARCHAR2
IS
BEGIN
  IF USERENV('LANG') IN ('US', 'UK')
  THEN
    RETURN UPPER(p_string);
  ELSE
    RETURN p_string;
  END IF;
END okl_upper;

---------------------------------------------------------------------------
-- PROCEDURE get_concate_segments to get the concatenated segment values
-- based on CCID.
---------------------------------------------------------------------------

FUNCTION get_concat_segments(p_ccid IN NUMBER)
RETURN VARCHAR2
AS
  l_concatenated_segments VARCHAR2(1000);

  CURSOR ccid_csr IS
  SELECT concatenated_segments
  FROM gl_code_combinations_kfv
  WHERE code_combination_id = p_ccid;

BEGIN

  OPEN ccid_csr;
  FETCH ccid_csr INTO l_concatenated_segments;
  CLOSE ccid_csr;

  RETURN l_concatenated_segments;
EXCEPTION
  WHEN OTHERS THEN
    RETURN NULL;
END get_concat_segments;

---------------------------------------------------------------------------
-- PROCEDURE get_concate_desc to get the concatenated segment values
-- based on CCID.
---------------------------------------------------------------------------
FUNCTION get_concate_desc(p_code_combination_id IN NUMBER)
RETURN VARCHAR2
AS
  l_concatenated_segments VARCHAR2(100);
  l_chart_of_accounts_id NUMBER;
  l_concate_desc VARCHAR2(1000);

  CURSOR ccid_csr IS
  SELECT concatenated_segments, chart_of_accounts_id
  FROM gl_code_combinations_kfv
  WHERE code_combination_id = p_code_combination_id;

BEGIN
  OPEN ccid_csr;
  FETCH ccid_csr INTO l_concatenated_segments, l_chart_of_accounts_id;
  CLOSE ccid_csr;

  IF (l_concatenated_segments IS NOT NULL) AND
     (l_chart_of_accounts_id IS NOT NULL) THEN
      l_concate_desc := get_concate_desc
                      (p_chart_of_account_id => l_chart_of_accounts_id,
                      p_concate_segments => l_concatenated_segments);
  END IF;

  RETURN l_concate_desc;
EXCEPTION
  WHEN OTHERS THEN
    RETURN NULL;
END get_concate_desc;


---------------------------------------------------------------------------
-- get lookup meaning from fa lookup tables.
---------------------------------------------------------------------------

FUNCTION get_fa_lookup_meaning(p_lookup_type IN VARCHAR2
                              ,p_lookup_code IN VARCHAR2)
RETURN VARCHAR2
AS
  l_meaning VARCHAR2(240);
  l_sysdate	DATE := G_SYSDATE;

  CURSOR fa_lkup_csr IS
  SELECT meaning
  FROM fa_lookups fal
  WHERE fal.lookup_type = p_lookup_type
  AND fal.lookup_code = p_lookup_code
  AND fal.enabled_flag = 'Y'
  AND TRUNC(NVL(fal.start_date_active, l_sysdate)) <= TRUNC(l_sysdate)
  AND TRUNC(NVL(fal.end_date_active, l_sysdate)) >= TRUNC(l_sysdate);

  BEGIN

  OPEN fa_lkup_csr;
  FETCH fa_lkup_csr INTO l_meaning;
  CLOSE fa_lkup_csr;

  RETURN l_meaning;

EXCEPTION
  WHEN OTHERS THEN
    RETURN NULL;
END get_fa_lookup_meaning;

---------------------------------------------------------------------------
-- get the format mask for given currency code with profile options.
---------------------------------------------------------------------------

FUNCTION get_format_mask(p_currency_code IN VARCHAR2)
RETURN VARCHAR2
AS
  l_format_mask VARCHAR2(1000);
  l_field_width NUMBER := 60;
  l_precision NUMBER := 0;
  l_ext_precision NUMBER := 0;
  l_min_acct_unit NUMBER := 0;
  l_curr_separator BOOLEAN;
  l_curr_neg_format VARCHAR2(30);
  l_curr_pos_format VARCHAR2(30);
  l_mask VARCHAR2(100);
  l_whole_width NUMBER;
  l_decimal_width NUMBER;
  l_sign_width NUMBER;
  l_profl_val VARCHAR2(80);

  CURSOR cur_csr IS
  SELECT fc.precision, fc.extended_precision, fc.minimum_accountable_unit
  FROM fnd_currencies fc
  WHERE fc.currency_code = p_currency_code;

BEGIN

  OPEN cur_csr;
  FETCH cur_csr INTO l_precision, l_ext_precision, l_min_acct_unit;
  IF cur_csr%NOTFOUND THEN
     l_PRECISION := 0;
     l_ext_precision := 0;
     l_min_acct_unit := 0;
  END IF;
  CLOSE cur_csr;

  IF (fnd_profile.value('CURRENCY:THOUSANDS_SEPARATOR') = 'Y' ) THEN
    l_curr_separator := TRUE;
  ELSE
    l_curr_separator := FALSE;
  END IF;
  l_curr_neg_format := OKL_ACCOUNTING_UTIL.GET_LOOKUP_MEANING('CURRENCY:NEGATIVE_FORMAT', fnd_profile.value('CURRENCY:NEGATIVE_FORMAT'), 0, 0);
  l_curr_pos_format  := OKL_ACCOUNTING_UTIL.GET_LOOKUP_MEANING('CURRENCY:POSITIVE_FORMAT', fnd_profile.value('CURRENCY:POSITIVE_FORMAT'), 0, 0);

  IF (L_PRECISION > 0) THEN
    l_decimal_width := 1 + l_PRECISION;
  ELSE
    l_decimal_width := 0;
  END IF;

  IF (l_curr_neg_format = '<XXX>') THEN
    l_sign_width := 2;
  ELSE
    l_sign_width := 1;
  END IF;

  l_whole_width := l_field_width - l_decimal_width - l_sign_width - 1;

  IF (l_whole_width < 0) THEN
    l_format_mask := '';
  END IF;

  l_mask := '0' || l_mask;

  IF (l_whole_width > 1) THEN
    FOR i IN 2..l_whole_width LOOP
      IF (l_curr_separator) AND (MOD(i, 4) = 0) THEN
        IF (i < l_whole_width - 1) THEN
          l_mask := 'G' || l_mask;
        END IF;
      ELSIF (i <> l_whole_width) THEN
        l_mask := '9' || l_mask;
      END IF;
    END LOOP;
  END IF;

  IF (l_PRECISION > 0) THEN
    l_mask := l_mask || 'D';
    FOR i IN 1..l_PRECISION LOOP
      l_mask := l_mask || '0';
    END LOOP;
  END IF;

  l_mask := 'FM' || l_mask;

  IF (l_curr_neg_format = 'XXX-') THEN
    l_mask := l_mask || 'MI';
  ELSIF (l_curr_neg_format = '<XXX>') THEN
    l_mask := l_mask || 'PR';
  ELSIF (l_curr_pos_format = '+XXX') THEN
    l_mask := 'S' || l_mask;
  END IF;

  l_format_mask := l_mask;
  RETURN l_format_mask;

END GET_FORMAT_MASK;

---------------------------------------------------------------------------
-- format the amount according to profile options and currency code.
---------------------------------------------------------------------------

FUNCTION format_amount(p_amount IN NUMBER
                      ,p_currency_code IN VARCHAR2)
RETURN VARCHAR2
AS
  l_format_mask VARCHAR2(1000);
BEGIN
  l_format_mask := get_format_mask(p_currency_code);
  RETURN TO_CHAR(p_amount, l_format_mask);
END format_amount;

---------------------------------------------------------------------------
-- validate amount accoridng to currency code.
---------------------------------------------------------------------------

FUNCTION validate_amount(p_amount IN NUMBER
                        ,p_currency_code IN VARCHAR2)
RETURN NUMBER
AS
  l_precision NUMBER;
BEGIN
  BEGIN -- get currency info
    SELECT PRECISION
    INTO l_precision
    FROM fnd_currencies fc
    WHERE fc.currency_code = p_currency_code;
  EXCEPTION
    WHEN NO_DATA_FOUND THEN
      l_precision := 0;
  END; -- get currency info

  RETURN ROUND(p_amount, l_precision);
END validate_amount;


---------------------------------------------------------------------------
-- validate get_rule_meaning.
---------------------------------------------------------------------------
 FUNCTION get_rule_meaning(p_rule_code IN VARCHAR2)
  RETURN VARCHAR2
  AS
    cursor csr_get_rule_meaning(c_rule_code varchar2) IS
      SELECT meaning
      FROM OKC_RULE_DEFS_V rdef
      WHERE rdef.rule_code = c_rule_code;

/* cursor csr_get_rule_meaning(c_rule_code varchar2) IS
 SELECT meaning
    FROM fnd_lookup_types flt,
      fnd_lookup_values flv
    WHERE  flv.lookup_type = flt.lookup_type
    AND flv.security_group_id = flt.security_group_id
    AND flv.view_application_id = flt.view_application_id
    AND flv.LANGUAGE = USERENV('LANG')
    AND flv.security_group_id = fnd_global.lookup_security_group(flv.lookup_type, flv.view_application_id)
    AND flt.lookup_type = 'OKC_RULE_DEF'
    AND flv.lookup_code = c_rule_code
    AND flt.application_id = 510
    AND flv.view_application_id = 0
    AND ENABLED_FLAG = 'Y'
	AND NVL(start_date_active, G_SYSDATE) <= G_SYSDATE
	AND NVL(end_date_active, G_SYSDATE) >= G_SYSDATE;*/

    l_row_found       BOOLEAN := FALSE;
    l_meaning         VARCHAR2(240);
    x_return_status   VARCHAR2(2);

    BEGIN

      OPEN csr_get_rule_meaning(p_rule_code);
      FETCH csr_get_rule_meaning INTO l_meaning;
      l_row_found := csr_get_rule_meaning%FOUND;
      CLOSE csr_get_rule_meaning;

      IF l_row_found = FALSE THEN
             OKL_API.SET_MESSAGE(p_app_name       => G_APP_NAME,
                                 p_msg_name       => G_RULE_DEF_NOT_FOUND);
         x_return_status := OKL_API.G_RET_STS_ERROR;
      END IF;

      RETURN l_meaning;

  EXCEPTION
  WHEN OTHERS THEN
          -- store SQL error message on message stack
          OKL_API.SET_MESSAGE(p_app_name      =>  G_APP_NAME,
                              p_msg_name      =>  G_UNEXPECTED_ERROR,
                              p_token1        =>  G_SQLCODE_TOKEN,
                              p_token1_value  =>  SQLCODE,
                              p_token2        =>  G_SQLERRM_TOKEN,
                              p_token2_value  =>  SQLERRM);
             x_return_status := OKL_API.G_RET_STS_UNEXP_ERROR;

         IF (csr_get_rule_meaning%ISOPEN) THEN
                    CLOSE csr_get_rule_meaning;
         END IF;
  END get_rule_meaning;


/* ============================================================================
Added by Santonyr 06/20/2002
Function : Get_Message_Token

Parameters :
 p_region_code
 p_attribute_code
 p_application_id

Description : This Function gets the label for a particular AK attribute belongs
	      a particular region. This is called at the time of displaying a token
	      along with the message. It returns NULL if the region or the attribute
	      is not found.

 ============================================================================*/

FUNCTION Get_Message_Token
(
 p_region_code    IN ak_region_items.region_code%TYPE,
 p_attribute_code IN ak_region_items.attribute_code%TYPE,
 p_application_id IN fnd_application.application_id%TYPE DEFAULT 540
)
RETURN VARCHAR2
IS

l_attribute_label ak_attributes_tl.attribute_label_long%TYPE := NULL;

-- Cursor which selects the label of an attribute belongs to a region.

CURSOR  label_cur IS
SELECT  rit.attribute_label_long
FROM    ak_region_items ri, ak_region_items_tl rit
WHERE 	ri.region_code = p_region_code AND
	ri.attribute_code = p_attribute_code AND
	ri.region_application_id = p_application_id AND
	ri.attribute_application_id = p_application_id AND
	rit.language = USERENV('LANG')AND
	ri.region_code = rit.region_code AND
 	ri.attribute_code = rit.attribute_code AND
	ri.region_application_id = rit.region_application_id AND
	ri.attribute_application_id = rit.attribute_application_id ;

BEGIN

-- Open the cursor and fetch the value of the label and return it back.

  OPEN label_cur ;
  FETCH label_cur INTO l_attribute_label;
  CLOSE  label_cur;

  RETURN l_attribute_label;


EXCEPTION
    WHEN OTHERS THEN
      IF label_cur%ISOPEN THEN
        CLOSE label_cur;
     END IF;
    RETURN NULL;

END Get_Message_Token;

/* =====================================================================================
Function : cross_currency_round_amount
Added by Santonyr 18-Nov-2002

Parameters :
IN
 p_amount
 p_currency_code

 Description : This function rounds the amount passed to this function according to
 the cross currency rounding rule.

 ======================================================================================*/

FUNCTION cross_currency_round_amount
    (p_amount IN NUMBER,
	p_currency_code IN VARCHAR2)
  RETURN NUMBER
  AS
    l_rounding_rule VARCHAR2(30);
    l_precision NUMBER;
    l_rounded_amount NUMBER := 0;
	l_pos_dot NUMBER;
	l_to_add NUMBER := 1;
	l_sysdate	DATE := G_SYSDATE;
  BEGIN

	SELECT cc_rounding_rule INTO l_rounding_rule
	FROM OKL_SYS_ACCT_OPTS;

	SELECT PRECISION INTO l_precision
	FROM fnd_currencies_vl
	WHERE currency_code = p_currency_code
	AND enabled_flag = 'Y'
	AND TRUNC(NVL(start_date_active, l_sysdate)) <= TRUNC(l_sysdate)
	AND TRUNC(NVL(end_date_active, l_sysdate)) >= TRUNC(l_sysdate);

    IF (l_rounding_rule = 'UP') THEN
      l_pos_dot := INSTR(TO_CHAR(p_amount),'.') ;
      IF (l_pos_dot > 0) AND (SUBSTR(p_amount,l_pos_dot+l_precision+1,1) IS NOT NULL) THEN
        FOR i IN 1..l_precision LOOP
          l_to_add := l_to_add/10;
        END LOOP;
          l_rounded_amount := p_amount + l_to_add;
      ELSE
          l_rounded_amount := p_amount;
      END IF;
	  l_rounded_amount := TRUNC(l_rounded_amount,l_precision);
   	ELSIF l_rounding_rule = 'DOWN' THEN
	  l_rounded_amount := TRUNC(p_amount, l_precision);

	ELSIF  l_rounding_rule = 'NEAREST' THEN
	  l_rounded_amount := ROUND(p_amount, l_precision);
	END IF;

	RETURN l_rounded_amount;
  EXCEPTION
    WHEN OTHERS THEN
	  RETURN 0;
  END cross_currency_round_amount;

/******************************************************************************/

PROCEDURE cross_currency_round_amount
    (p_api_version      IN NUMBER,
     p_init_msg_list 	IN VARCHAR2,
     x_return_status    OUT NOCOPY VARCHAR2,
     x_msg_count 	OUT NOCOPY NUMBER,
     x_msg_data 	OUT NOCOPY VARCHAR2,
     p_amount 		IN NUMBER,
     p_currency_code 	IN VARCHAR2,
     x_rounded_amount	OUT NOCOPY NUMBER)

IS
    l_rounding_rule VARCHAR2(30);
    l_precision NUMBER;
    l_rounded_amount NUMBER := 0;
    l_pos_dot NUMBER;
    l_to_add NUMBER := 1;
    l_sysdate	DATE := G_SYSDATE;

    l_init_msg_list    VARCHAR2(1) := OKL_API.G_FALSE;
    l_return_status    VARCHAR2(1) := OKL_API.G_RET_STS_SUCCESS;
    l_msg_count        NUMBER := 0;
    l_msg_data         VARCHAR2(2000);
    l_api_version      NUMBER := 1.0;

    CURSOR rnd_rul_csr IS
    SELECT cc_rounding_rule
    FROM OKL_SYS_ACCT_OPTS;

    CURSOR prec_csr IS
    SELECT PRECISION
    FROM fnd_currencies_vl
    WHERE currency_code = p_currency_code
    AND enabled_flag = 'Y'
    AND TRUNC(NVL(start_date_active, l_sysdate)) <= TRUNC(l_sysdate)
    AND TRUNC(NVL(end_date_active, l_sysdate)) >= TRUNC(l_sysdate);

BEGIN

    x_return_status         := OKL_API.G_RET_STS_SUCCESS;

    FOR rnd_rul_rec IN rnd_rul_csr LOOP
      l_rounding_rule := rnd_rul_rec.cc_rounding_rule;
    END LOOP;

    IF l_rounding_rule IS NULL THEN
       OKL_API.SET_MESSAGE(p_app_name     => g_app_name,
                          p_msg_name     => 'OKL_NO_ROUNDING_RULE');
       x_return_status := OKL_API.G_RET_STS_ERROR;
       RAISE OKL_API.G_EXCEPTION_ERROR;
     END IF;


    FOR prec_rec IN prec_csr LOOP
       l_precision := prec_rec.precision;
    END LOOP;


    IF l_precision IS NULL THEN
       OKL_API.SET_MESSAGE(p_app_name     => g_app_name,
                           p_msg_name     => 'OKL_NO_CURR_PRECISION',
                           p_token1         => 'CURRENCY_CODE',
                           p_token1_value   => p_currency_code);
       x_return_status := OKL_API.G_RET_STS_ERROR;
       RAISE OKL_API.G_EXCEPTION_ERROR;
     END IF;


    IF (l_rounding_rule = 'UP') THEN
      l_pos_dot := INSTR(TO_CHAR(p_amount),'.') ;
      IF (l_pos_dot > 0) AND (SUBSTR(p_amount,l_pos_dot+l_precision+1,1) IS NOT NULL) THEN
        FOR i IN 1..l_precision LOOP
          l_to_add := l_to_add/10;
        END LOOP;
          l_rounded_amount := p_amount + l_to_add;
      ELSE
          l_rounded_amount := p_amount;
      END IF;
	  l_rounded_amount := TRUNC(l_rounded_amount,l_precision);
   	ELSIF l_rounding_rule = 'DOWN' THEN
	  l_rounded_amount := TRUNC(p_amount, l_precision);

	ELSIF  l_rounding_rule = 'NEAREST' THEN
	  l_rounded_amount := ROUND(p_amount, l_precision);
	END IF;

	x_rounded_amount := l_rounded_amount;

EXCEPTION

  WHEN OKL_API.G_EXCEPTION_ERROR THEN
     x_return_status := OKL_API.G_RET_STS_ERROR ;

  WHEN OTHERS THEN
       OKL_API.SET_MESSAGE(p_app_name     => g_app_name,
                          p_msg_name     => 'OKL_ERROR_ROUNDING_AMT');
       x_return_status := OKL_API.G_RET_STS_UNEXP_ERROR;

END cross_currency_round_amount;

/******************************************************************************/

/* =====================================================================================
Procedure : convert_to_functional_currency
Added by Santonyr 15-Nov-2002

Parameters :
IN
 p_khr_id
 p_to_currency
 p_transaction_date
 p_amount

 OUT
 x_contract_currency
 x_currency_conversion_type
 x_currency_conversion_rate
 x_currency_conversion_date
 x_converted_amount

 Description : This procedure converts the amount from contract currency to functional
		currency. And then returns the rounded amount. This also returns the
		currency conversion factors along.

 Assumptions : In this version of the API, we assume that the contract and
 the transaction currencies are same.
 ======================================================================================*/

PROCEDURE convert_to_functional_currency
(
 p_khr_id  		  	IN OKC_K_HEADERS_B.id%TYPE,
 p_to_currency   		IN fnd_currencies.currency_code%TYPE,
 p_transaction_date 		IN DATE,
 p_amount 			IN NUMBER,
 x_contract_currency		OUT NOCOPY OKC_K_HEADERS_B.currency_code%TYPE,
 x_currency_conversion_type	OUT NOCOPY OKL_K_HEADERS.currency_conversion_type%TYPE,
 x_currency_conversion_rate	OUT NOCOPY OKL_K_HEADERS.currency_conversion_rate%TYPE,
 x_currency_conversion_date	OUT NOCOPY OKL_K_HEADERS.currency_conversion_date%TYPE,
 x_converted_amount 		OUT NOCOPY NUMBER
)
AS

-- Cursor to select the currency conversion factors for the contract id passed
  CURSOR cntrct_cur IS
  SELECT CURRENCY_CODE,
		 CURRENCY_CONVERSION_TYPE,
		 CURRENCY_CONVERSION_RATE,
		 CURRENCY_CONVERSION_DATE
  FROM	 OKL_K_HEADERS_FULL_V
  WHERE	 ID = p_khr_id;

  l_func_currency VARCHAR2(15);
  l_contract_currency VARCHAR2(15);
  l_currency_conversion_type	VARCHAR2(30);
  l_currency_conversion_rate	NUMBER;
  l_currency_conversion_date	DATE;
  l_converted_amount			NUMBER;

BEGIN
-- Fetch the currency conversion factors from the contract cursor
  FOR cntrct_rec IN cntrct_cur LOOP
	 l_contract_currency := cntrct_rec.currency_code;
	 l_currency_conversion_type	:= cntrct_rec.currency_conversion_type;
	 l_currency_conversion_rate	:= cntrct_rec.currency_conversion_rate;
	 l_currency_conversion_date	:= cntrct_rec.currency_conversion_date;
  END LOOP;

-- Get the functional currency code using Accounting Util API if the passed
-- currency code is null

  l_func_currency := p_to_currency;
  IF l_func_currency IS NULL THEN
    l_func_currency := OKL_ACCOUNTING_UTIL.GET_FUNC_CURR_CODE;
  END IF;

-- Currency conversion rate is 1 if both the contract and functional
-- currencies are same
  IF l_func_currency = l_contract_currency THEN
   l_currency_conversion_rate := 1;
  ELSE

-- Get the currency conversion rate using get_curr_con_rate API if the
-- conversion type is not 'USER'

   IF UPPER(l_currency_conversion_type) <> 'USER' THEN
	 l_currency_conversion_date  := p_transaction_date;
  	 l_currency_conversion_rate := OKL_ACCOUNTING_UTIL.get_curr_con_rate
	 			       (p_from_curr_code => l_contract_currency,
					p_to_curr_code   => l_func_currency,
					p_con_date       => l_currency_conversion_date,
					p_con_type       => l_currency_conversion_type);
    END IF;  -- The type is not USER

  END IF; -- Functional and contract currencies are not same.

-- Calculate the converted amount
  l_converted_amount := p_amount * l_currency_conversion_rate;

-- Round the converted amount
--  l_converted_amount := OKL_ACCOUNTING_UTIL.CROSS_CURRENCY_ROUND_AMOUNT(l_converted_amount, l_contract_currency);

-- Populate the OUT parameters.
  x_converted_amount := l_converted_amount;
  x_contract_currency		 := l_contract_currency;
  x_currency_conversion_type  := l_currency_conversion_type;
  x_currency_conversion_rate  := l_currency_conversion_rate;
  x_currency_conversion_date  := l_currency_conversion_date;

EXCEPTION
    WHEN OTHERS THEN
      x_converted_amount := -1;

END convert_to_functional_currency;

/* =====================================================================================
Procedure : convert_to_functional_currency
Added by Santonyr 20-Dec-2002

Parameters :
IN
 p_khr_id
 p_to_currency
 p_transaction_date
 p_amount

 OUT
 x_return_status
 x_contract_currency
 x_currency_conversion_type
 x_currency_conversion_rate
 x_currency_conversion_date
 x_converted_amount

 Description : This overloaded procedure converts the amount from contract currency to
 		functional currency. And then returns the rounded amount. This also
 		returns the currency conversion factors and return_status along.
 ======================================================================================*/

PROCEDURE convert_to_functional_currency
(
 p_khr_id  		  	IN OKC_K_HEADERS_B.id%TYPE,
 p_to_currency   		IN fnd_currencies.currency_code%TYPE,
 p_transaction_date 		IN DATE,
 p_amount 			IN NUMBER,
 x_return_status		OUT NOCOPY VARCHAR2,
 x_contract_currency		OUT NOCOPY OKC_K_HEADERS_B.currency_code%TYPE,
 x_currency_conversion_type	OUT NOCOPY OKL_K_HEADERS.currency_conversion_type%TYPE,
 x_currency_conversion_rate	OUT NOCOPY OKL_K_HEADERS.currency_conversion_rate%TYPE,
 x_currency_conversion_date	OUT NOCOPY OKL_K_HEADERS.currency_conversion_date%TYPE,
 x_converted_amount 		OUT NOCOPY NUMBER
)
AS

-- Cursor to select the currency conversion factors for the contract id passed
  CURSOR cntrct_cur IS
  SELECT CURRENCY_CODE,
	 CURRENCY_CONVERSION_TYPE,
	 CURRENCY_CONVERSION_RATE,
	 CURRENCY_CONVERSION_DATE
  FROM	 OKL_K_HEADERS_FULL_V
  WHERE	 ID = p_khr_id;

  l_func_currency VARCHAR2(15);
  l_contract_currency VARCHAR2(15);
  l_currency_conversion_type	VARCHAR2(30);
  l_currency_conversion_rate	NUMBER;
  l_currency_conversion_date	DATE;
  l_converted_amount			NUMBER;
  l_return_status    VARCHAR2(1) := OKL_API.G_RET_STS_SUCCESS;
  l_init_msg_list    VARCHAR2(1) := OKL_API.G_FALSE;
  l_msg_count        NUMBER := 0;
  l_msg_data         VARCHAR2(2000);
  l_api_version	   NUMBER := 1.0;


BEGIN

  x_return_status         := OKL_API.G_RET_STS_SUCCESS;

-- Fetch the currency conversion factors from the contract cursor
  FOR cntrct_rec IN cntrct_cur LOOP
	 l_contract_currency := cntrct_rec.currency_code;
	 l_currency_conversion_type	:= cntrct_rec.currency_conversion_type;
	 l_currency_conversion_rate	:= cntrct_rec.currency_conversion_rate;
	 l_currency_conversion_date	:= cntrct_rec.currency_conversion_date;
  END LOOP;

  IF l_contract_currency IS NULL THEN
      OKL_API.SET_MESSAGE(p_app_name     => g_app_name,
                          p_msg_name     => 'OKL_NO_CONTRACT_FOR_CONV');
      x_return_status := OKL_API.G_RET_STS_ERROR;
      RAISE OKL_API.G_EXCEPTION_ERROR;
  END IF;


-- Get the functional currency code using Accounting Util API if the passed
-- currency code is null

  l_func_currency := p_to_currency;
  IF l_func_currency IS NULL THEN
    l_func_currency := OKL_ACCOUNTING_UTIL.GET_FUNC_CURR_CODE;
  END IF;

-- Currency conversion rate is 1 if both the contract and functional
-- currencies are same
  IF l_func_currency = l_contract_currency THEN
   l_currency_conversion_rate := 1;
  ELSE

-- Get the currency conversion rate using get_curr_con_rate API if the
-- conversion type is not 'USER'

   IF UPPER(l_currency_conversion_type) <> 'USER' THEN

	 l_currency_conversion_date  := p_transaction_date;

	 get_curr_con_rate
	 (p_api_version    => l_api_version,
	 p_init_msg_list 	=> l_init_msg_list,
	 x_return_status  => l_return_status,
	 x_msg_count 	=> l_msg_count,
	 x_msg_data 	=> l_msg_data,
	 p_from_curr_code => l_contract_currency,
	 p_to_curr_code   => l_func_currency,
     	 p_con_date       => l_currency_conversion_date,
     	 p_con_type       => l_currency_conversion_type,
     	 x_conv_rate      => l_currency_conversion_rate );




	  IF (l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
	    RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
	  ELSIF (l_return_status = OKL_API.G_RET_STS_ERROR) THEN
	    RAISE OKL_API.G_EXCEPTION_ERROR;
	  END IF;

    END IF;  -- The type is not USER

  END IF; -- Functional and contract currencies are not same.

-- Calculate the converted amount
  l_converted_amount := p_amount * l_currency_conversion_rate;

-- Round the converted amount
--  l_converted_amount := OKL_ACCOUNTING_UTIL.CROSS_CURRENCY_ROUND_AMOUNT(l_converted_amount, l_contract_currency);

-- Populate the OUT parameters.
  x_converted_amount := l_converted_amount;
  x_contract_currency		 := l_contract_currency;
  x_currency_conversion_type  := l_currency_conversion_type;
  x_currency_conversion_rate  := l_currency_conversion_rate;
  x_currency_conversion_date  := l_currency_conversion_date;

EXCEPTION

  WHEN OKL_API.G_EXCEPTION_ERROR THEN
     x_return_status := OKL_API.G_RET_STS_ERROR ;
  WHEN OKL_API.G_EXCEPTION_UNEXPECTED_ERROR THEN
     x_return_status := OKL_API.G_RET_STS_UNEXP_ERROR;
  WHEN OTHERS THEN
     x_return_status := OKL_API.G_RET_STS_UNEXP_ERROR;

END convert_to_functional_currency;


/* ============================================================================
Procedure : convert_to_contract_currency
Added by Santonyr 15-Nov-2002

Parameters :
IN
 p_khr_id
 p_from_currency
 p_transaction_date
 p_amount

 OUT
 x_contract_currency
 x_currency_conversion_type
 x_currency_conversion_rate
 x_currency_conversion_date
 x_converted_amount

 Description : This procedure converts the amount from functional currency to contract
	      currency. And then returns the rounded amount. This also returns the
	      currency conversion factors along.

 Assumptions : In this version of the API, we assume that the contract and
 the transaction currencies are same.
 ============================================================================*/


PROCEDURE convert_to_contract_currency
(
 p_khr_id  		  	IN OKC_K_HEADERS_B.id%TYPE,
 p_from_currency   		IN fnd_currencies.currency_code%TYPE,
 p_transaction_date 		IN DATE,
 p_amount 			IN NUMBER,
 x_contract_currency		OUT NOCOPY OKC_K_HEADERS_B.currency_code%TYPE,
 x_currency_conversion_type	OUT NOCOPY OKL_K_HEADERS.currency_conversion_type%TYPE,
 x_currency_conversion_rate	OUT NOCOPY OKL_K_HEADERS.currency_conversion_rate%TYPE,
 x_currency_conversion_date	OUT NOCOPY OKL_K_HEADERS.currency_conversion_date%TYPE,
 x_converted_amount 		OUT NOCOPY NUMBER
)
AS

-- Cursor to select the currency conversion factors for the contract id passed
  CURSOR cntrct_cur IS
  SELECT CURRENCY_CODE,
		 CURRENCY_CONVERSION_TYPE,
		 CURRENCY_CONVERSION_RATE,
		 CURRENCY_CONVERSION_DATE
  FROM	 OKL_K_HEADERS_FULL_V
  WHERE	 ID = p_khr_id;

  l_func_currency VARCHAR2(15);
  l_contract_currency VARCHAR2(15);
  l_currency_conversion_type	VARCHAR2(30);
  l_currency_conversion_rate	NUMBER;
  l_currency_conversion_date	DATE;
  l_converted_amount			NUMBER;

BEGIN

-- Fetch the currency conversion factors from the contract cursor
  FOR cntrct_rec IN cntrct_cur LOOP
	 l_contract_currency := cntrct_rec.currency_code;
	 l_currency_conversion_type	:= cntrct_rec.currency_conversion_type;
	 l_currency_conversion_rate	:= cntrct_rec.currency_conversion_rate;
	 l_currency_conversion_date	:= cntrct_rec.currency_conversion_date;
  END LOOP;

-- Get the functional currency code using Accounting Util API if the passed
-- currency code is null
  l_func_currency := p_from_currency;
  IF l_func_currency IS NULL THEN
    l_func_currency := OKL_ACCOUNTING_UTIL.GET_FUNC_CURR_CODE;
  END IF;

-- Currency conversion rate is 1 if both the contract and functional
-- currencies are same

  IF l_func_currency = l_contract_currency THEN
   l_currency_conversion_rate := 1;

  ELSE

   IF UPPER(l_currency_conversion_type) = 'USER' THEN
     l_currency_conversion_rate := 1/l_currency_conversion_rate;

   ELSE

-- Get the currency conversion rate using get_curr_con_rate API if the
-- conversion type is not 'USER'

	 l_currency_conversion_date  := p_transaction_date;
  	 l_currency_conversion_rate := OKL_ACCOUNTING_UTIL.get_curr_con_rate
	 			       (p_from_curr_code => l_func_currency,
				        p_to_curr_code   => l_contract_currency,
					p_con_date       => l_currency_conversion_date,
					p_con_type       => l_currency_conversion_type);

    END IF; -- The type is USER
  END IF; -- Functional and contract currencies are not same.


-- Calculate the converted amount
  l_converted_amount := p_amount * l_currency_conversion_rate;

-- Round the converted amount
--  l_converted_amount := OKL_ACCOUNTING_UTIL.CROSS_CURRENCY_ROUND_AMOUNT(l_converted_amount, l_contract_currency);

-- Populate the OUT parameters.
  x_converted_amount := l_converted_amount;
  x_contract_currency		 := l_contract_currency;
  x_currency_conversion_type  := l_currency_conversion_type;
  x_currency_conversion_rate  := l_currency_conversion_rate;
  x_currency_conversion_date  := l_currency_conversion_date;

EXCEPTION
    WHEN OTHERS THEN
      x_converted_amount := -1;

END convert_to_contract_currency;

/* ============================================================================
Procedure : convert_to_contract_currency
Added by Santonyr 20-Dec-2002

Parameters :
IN
 p_khr_id
 p_from_currency
 p_transaction_date
 p_amount

 OUT
 x_return_status
 x_contract_currency
 x_currency_conversion_type
 x_currency_conversion_rate
 x_currency_conversion_date
 x_converted_amount

 Description : This overloaded procedure converts the amount from functional currency
 	       to contract currency. And then returns the rounded amount. This also
 	       returns the currency conversion factors and return_status along.

 ============================================================================*/


PROCEDURE convert_to_contract_currency
(
 p_khr_id  		  	IN OKC_K_HEADERS_B.id%TYPE,
 p_from_currency   		IN fnd_currencies.currency_code%TYPE,
 p_transaction_date 		IN DATE,
 p_amount 			IN NUMBER,
 x_return_status		OUT NOCOPY VARCHAR2,
 x_contract_currency		OUT NOCOPY OKC_K_HEADERS_B.currency_code%TYPE,
 x_currency_conversion_type	OUT NOCOPY OKL_K_HEADERS.currency_conversion_type%TYPE,
 x_currency_conversion_rate	OUT NOCOPY OKL_K_HEADERS.currency_conversion_rate%TYPE,
 x_currency_conversion_date	OUT NOCOPY OKL_K_HEADERS.currency_conversion_date%TYPE,
 x_converted_amount 		OUT NOCOPY NUMBER
)
AS

-- Cursor to select the currency conversion factors for the contract id passed
  CURSOR cntrct_cur IS
  SELECT CURRENCY_CODE,
		 CURRENCY_CONVERSION_TYPE,
		 CURRENCY_CONVERSION_RATE,
		 CURRENCY_CONVERSION_DATE
  FROM	 OKL_K_HEADERS_FULL_V
  WHERE	 ID = p_khr_id;

  l_func_currency VARCHAR2(15);
  l_contract_currency VARCHAR2(15);
  l_currency_conversion_type	VARCHAR2(30);
  l_currency_conversion_rate	NUMBER;
  l_currency_conversion_date	DATE;
  l_converted_amount			NUMBER;
  l_init_msg_list    VARCHAR2(1) := OKL_API.G_FALSE;
  l_return_status    VARCHAR2(1) := OKL_API.G_RET_STS_SUCCESS;
  l_msg_count        NUMBER := 0;
  l_msg_data         VARCHAR2(2000);
  l_api_version	   NUMBER := 1.0;


BEGIN
    x_return_status         := OKL_API.G_RET_STS_SUCCESS;

-- Fetch the currency conversion factors from the contract cursor
  FOR cntrct_rec IN cntrct_cur LOOP
	 l_contract_currency := cntrct_rec.currency_code;
	 l_currency_conversion_type	:= cntrct_rec.currency_conversion_type;
	 l_currency_conversion_rate	:= cntrct_rec.currency_conversion_rate;
	 l_currency_conversion_date	:= cntrct_rec.currency_conversion_date;
  END LOOP;


  IF l_contract_currency IS NULL THEN
      OKL_API.SET_MESSAGE(p_app_name     => g_app_name,
                          p_msg_name     => 'OKL_NO_CONTRACT_FOR_CONV');
      x_return_status := OKL_API.G_RET_STS_ERROR;
      RAISE OKL_API.G_EXCEPTION_ERROR;
  END IF;


-- Get the functional currency code using Accounting Util API if the passed
-- currency code is null
  l_func_currency := p_from_currency;
  IF l_func_currency IS NULL THEN
    l_func_currency := OKL_ACCOUNTING_UTIL.GET_FUNC_CURR_CODE;
  END IF;

-- Currency conversion rate is 1 if both the contract and functional
-- currencies are same

  IF l_func_currency = l_contract_currency THEN
   l_currency_conversion_rate := 1;

  ELSE

   IF UPPER(l_currency_conversion_type) = 'USER' THEN
     l_currency_conversion_rate := 1/l_currency_conversion_rate;

   ELSE

-- Get the currency conversion rate using get_curr_con_rate API if the
-- conversion type is not 'USER'

	 l_currency_conversion_date  := p_transaction_date;
	 get_curr_con_rate
	 	 (p_api_version    => l_api_version,
	 	 p_init_msg_list   => l_init_msg_list,
	 	 x_return_status   => l_return_status,
	 	 x_msg_count 	   => l_msg_count,
	 	 x_msg_data  	   => l_msg_data,
	 	 p_from_curr_code => l_func_currency,
	 	 p_to_curr_code   => l_contract_currency,
	      	 p_con_date       => l_currency_conversion_date,
	      	 p_con_type       => l_currency_conversion_type,
	      	 x_conv_rate      => l_currency_conversion_rate );

	  IF (l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
	    RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
	  ELSIF (l_return_status = OKL_API.G_RET_STS_ERROR) THEN
	    RAISE OKL_API.G_EXCEPTION_ERROR;
	  END IF;

    END IF; -- The type is USER
  END IF; -- Functional and contract currencies are not same.


-- Calculate the converted amount
  l_converted_amount := p_amount * l_currency_conversion_rate;

-- Round the converted amount
--  l_converted_amount := OKL_ACCOUNTING_UTIL.CROSS_CURRENCY_ROUND_AMOUNT(l_converted_amount, l_contract_currency);

-- Populate the OUT parameters.
  x_converted_amount := l_converted_amount;
  x_contract_currency		 := l_contract_currency;
  x_currency_conversion_type  := l_currency_conversion_type;
  x_currency_conversion_rate  := l_currency_conversion_rate;
  x_currency_conversion_date  := l_currency_conversion_date;

EXCEPTION

  WHEN OKL_API.G_EXCEPTION_ERROR THEN
     x_return_status := OKL_API.G_RET_STS_ERROR ;
  WHEN OKL_API.G_EXCEPTION_UNEXPECTED_ERROR THEN
     x_return_status := OKL_API.G_RET_STS_UNEXP_ERROR;
  WHEN OTHERS THEN
     x_return_status := OKL_API.G_RET_STS_UNEXP_ERROR;

END convert_to_contract_currency;



/* ============================================================================
Procedure : cc_round_format_amount
Added by Santonyr 09-Dec-2002

Parameters :
IN
 p_currency_code
 p_amount

RETURN : Rounded and formatted amount

Description : This function returns the rounded and formatted amount
for a given amount and currency code using the cross currency rounding rule

============================================================================*/

FUNCTION cc_round_format_amount
    (p_amount IN NUMBER,
     p_currency_code IN VARCHAR2)

RETURN VARCHAR2

AS

l_rounded_amount NUMBER;
l_formatted_amount VARCHAR2(1000);

BEGIN

-- Round the amount.
l_rounded_amount := cross_currency_round_amount(
		p_amount => p_amount,
		p_currency_code => p_currency_code);

-- Format the amount
l_formatted_amount := format_amount(
		p_amount => l_rounded_amount,
                p_currency_code => p_currency_code) ;

RETURN l_formatted_amount;

EXCEPTION
    WHEN OTHERS THEN
      RETURN '-1';

END cc_round_format_amount;

/************************************************************************************/

PROCEDURE cc_round_format_amount
    (p_api_version      IN NUMBER,
     p_init_msg_list 	IN VARCHAR2,
     x_return_status    OUT NOCOPY VARCHAR2,
     x_msg_count 	OUT NOCOPY NUMBER,
     x_msg_data 	OUT NOCOPY VARCHAR2,
     p_amount 		IN NUMBER,
     p_currency_code 	IN VARCHAR2,
     x_formatted_amount OUT NOCOPY VARCHAR2)
IS

l_rounded_amount NUMBER;
l_formatted_amount VARCHAR2(1000);
l_return_status    VARCHAR2(1) := OKL_API.G_RET_STS_SUCCESS;

l_init_msg_list    VARCHAR2(1) := OKL_API.G_FALSE;
l_msg_count        NUMBER := 0;
l_msg_data         VARCHAR2(2000);
l_api_version	   NUMBER := 1.0;

BEGIN

x_return_status    := OKL_API.G_RET_STS_SUCCESS;
-- Round the amount.

   cross_currency_round_amount
    (p_api_version      => l_api_version,
     p_init_msg_list 	=> l_init_msg_list,
     x_return_status    => l_return_status,
     x_msg_count 	=> l_msg_count,
     x_msg_data 	=> l_msg_data,
     p_amount 		=> p_amount,
     p_currency_code 	=> p_currency_code,
     x_rounded_amount	=> l_rounded_amount);


    IF (l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKL_API.G_RET_STS_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;

  -- Format the amount
  l_formatted_amount := format_amount(
		p_amount => l_rounded_amount,
                p_currency_code => p_currency_code) ;

  IF l_formatted_amount IS NULL THEN
      OKL_API.SET_MESSAGE(p_app_name     => g_app_name,
                          p_msg_name     => 'OKL_ERROR_FORMAT_AMT');
    x_return_status := OKL_API.G_RET_STS_UNEXP_ERROR;
    RAISE OKL_API.G_EXCEPTION_ERROR;
  END IF;

  x_formatted_amount := l_formatted_amount;

EXCEPTION

  WHEN OKL_API.G_EXCEPTION_ERROR THEN
     x_return_status := OKL_API.G_RET_STS_ERROR ;
  WHEN OKL_API.G_EXCEPTION_UNEXPECTED_ERROR THEN
      x_return_status := OKL_API.G_RET_STS_UNEXP_ERROR;
  WHEN OTHERS THEN
      x_return_status := OKL_API.G_RET_STS_UNEXP_ERROR;

END cc_round_format_amount;

/************************************************************************************/

/* ============================================================================
Function : get_valid_gl_date
Added by Keerthi 10-Jan-2003
Modified by nikshah 22-Jan-2007

Parameters :
IN
 p_gl_date
 p_ledger_id

RETURN : DATE

Description : This function accepts a GL Date. It validates this GL Date. If
this Date  falls into an Open or future open period then the same date is
returned. If it does not, then it tries to find out a valid GL date  before this
Date or after this date. If none of the period is open then this returns a NULL.
Done as part of the bug 2738336

Added p_ledger_id argument as part of bug 5707866 by nikshah
If p_ledger_id passed to the API is null then it considers ledger from primary representation.
Otherwise, it considers the ledger id that is passed to it.
Two cursors changed to accept one parameter: l_ledger_id
Changed call to get_period_info and get_okl_period_status procedures to pass p_ledger_id parameter

============================================================================*/

FUNCTION get_valid_gl_date(p_gl_date IN DATE, p_ledger_id IN NUMBER DEFAULT NULL)
 RETURN DATE

AS

CURSOR bef_csr (l_ledger_id NUMBER) IS
SELECT MAX(end_date)
FROM gl_period_statuses
WHERE application_id = 540
AND ledger_id = l_ledger_id
AND closing_status IN ('F','O')
AND TRUNC(end_date) <= TRUNC(p_gl_date)
AND adjustment_period_flag = 'N' ;


CURSOR aft_csr (l_ledger_id NUMBER) IS
SELECT MIN(start_date)
FROM gl_period_statuses
WHERE application_id = 540
AND ledger_id = l_ledger_id
AND closing_status IN ('F','O')
AND TRUNC(start_date) >= TRUNC(p_gl_date)
AND adjustment_period_flag = 'N' ;

l_period_name gl_periods.period_name%TYPE;
l_start_date DATE;
l_end_date DATE;
l_dummy_date DATE := NULL;
l_period_status gl_period_statuses.closing_status%TYPE;
l_ledger_id NUMBER;




BEGIN
  l_ledger_id := p_ledger_id;
  IF l_ledger_id IS NULL
  THEN
    l_ledger_id := get_set_of_books_id;
  END IF;

  get_period_info
   (p_date => p_gl_date,
    p_period_name => l_period_name,
    p_start_date =>  l_start_date,
    p_end_date =>    l_end_date,
    p_ledger_id => l_ledger_id);

  l_period_status := get_okl_period_status(p_period_name => l_period_name, p_ledger_id => l_ledger_id);

  IF l_period_status IN ('F','O') THEN
      RETURN  p_gl_date;
  END IF;

  OPEN aft_csr(l_ledger_id);
  FETCH aft_csr INTO l_dummy_date;
  IF (l_dummy_date IS NULL) THEN
     CLOSE aft_csr;
     OPEN bef_csr(l_ledger_id);
     FETCH bef_csr INTO l_dummy_date;
     IF (l_dummy_date IS NULL) THEN
         CLOSE bef_csr;
         RETURN NULL;
     END IF;
     CLOSE bef_csr;
     RETURN l_dummy_date;
  END IF;
  CLOSE aft_csr;

  RETURN l_dummy_date;

END get_valid_gl_date;


-- Added by Santonyr 02-Aug-2004 for bug 3808697.
-- This function is to derive the transaction amount for each transaction from FA.

FUNCTION get_fa_trx_amount
  (p_book_type_code  IN VARCHAR2,
   p_asset_id        IN NUMBER,
   p_transaction_type IN VARCHAR2,
   p_transaction_header_id IN  NUMBER   )
RETURN NUMBER

IS

l_before_amount NUMBER := NULL;
l_after_amount  NUMBER := NULL;
l_trx_amount    NUMBER := NULL;

-- Cursor to get the asset amount after the transaction

CURSOR after_csr IS
SELECT bk.cost
FROM fa_books bk
WHERE bk.book_type_code = p_book_type_code
AND bk.asset_id = p_asset_id
AND bk.transaction_header_id_in =   p_transaction_header_id;

-- Cursor to get the asset amount before the transaction

CURSOR before_csr IS
SELECT bk.cost
FROM fa_books bk
WHERE bk.book_type_code = p_book_type_code
AND bk.asset_id = p_asset_id
AND bk.transaction_header_id_out =   p_transaction_header_id;


BEGIN

  -- Get the amount from the cursor

  FOR  after_rec IN after_csr LOOP
     l_after_amount := after_rec.cost;
  END LOOP;

    -- Get the amount from the cursor

  FOR  before_rec IN before_csr LOOP
     l_before_amount := before_rec.cost;
  END LOOP;

    -- Get the transaction amount based on the transaction.

 IF p_transaction_type = 'ADDITION' THEN
    RETURN  NVL(l_after_amount, 0) ;
 ELSE
  RETURN  NVL(l_after_amount, 0)  - NVL(l_before_amount, 0) ;
 END IF;

EXCEPTION
  WHEN OTHERS THEN
    RETURN NULL;

END get_fa_trx_amount;

-- Added by Santonyr 10-Oct-2004.
-- This function is returns if a OKL transaction is actual or draft..
-- Added p_khr_id by abhsaxen 22-Mar-2007 for bug 5660408

FUNCTION Get_Draft_Actual_Trx
  (p_trx_id IN NUMBER,
  p_source_table IN VARCHAR2,
  p_khr_id IN NUMBER )
RETURN VARCHAR2
IS

l_draft VARCHAR2(30);
l_status VARCHAR2(30);


CURSOR c_draft_csr IS
SELECT
  DIST.POST_TO_GL
FROM
  OKL_TXL_CNTRCT_LNS LN,
  OKL_TRNS_ACC_DSTRS DIST
WHERE
  LN.TCN_ID = p_trx_id
  AND LN.ID = DIST.SOURCE_ID
  AND DIST.SOURCE_TABLE = p_source_table
  AND DIST.POST_TO_GL = 'Y';


-- Added LN.DNZ_KHR_ID =p_khr_id and p_source_table  by abhsaxen 22-Mar-2007 for bug 5660408
CURSOR a_draft_csr IS
SELECT
  DIST.POST_TO_GL
FROM
  OKL_TXL_ASSETS_B LN,
  OKL_TRNS_ACC_DSTRS DIST
WHERE
      LN.TAS_ID = p_trx_id
  AND LN.DNZ_KHR_ID =p_khr_id
  AND LN.ID = DIST.SOURCE_ID
  AND DIST.SOURCE_TABLE = p_source_table
  AND DIST.POST_TO_GL = 'Y';

BEGIN

-- If the transaction is a contract transaction

IF p_source_table = 'OKL_TXL_CNTRCT_LNS' THEN

  OPEN c_draft_csr;
  FETCH c_draft_csr INTO l_draft;
  IF c_draft_csr%NOTFOUND THEN
    l_status := 'DRAFT';
  ELSE
    l_status := 'ACTUAL';
  END IF;
  CLOSE c_draft_csr;

-- If the transaction is an asset transaction

ELSIF p_source_table = 'OKL_TXL_ASSETS_B' THEN

  OPEN a_draft_csr;
  FETCH a_draft_csr INTO l_draft;
  IF a_draft_csr%NOTFOUND THEN
    l_status := 'DRAFT';
  ELSE
    l_status := 'ACTUAL';
  END IF;
  CLOSE a_draft_csr;


END IF;

RETURN l_status;

EXCEPTION
  WHEN OTHERS THEN
    IF a_draft_csr%ISOPEN THEN
      CLOSE a_draft_csr;
    END IF;

    IF c_draft_csr%ISOPEN THEN
      CLOSE c_draft_csr;
    END IF;

    RETURN NULL;

END Get_Draft_Actual_Trx;

-- Added by Santonyr 10-Dec-2004 for bug 4028662.
-- This function is to return the FA transaction date.

FUNCTION get_fa_trx_date
  (p_book_type_code  IN VARCHAR2)
RETURN DATE
IS

l_sysdate DATE := G_SYSDATE;
l_fa_trx_date DATE;

-- Cursor to fetch the fa trx date

CURSOR fa_date_csr IS
SELECT  GREATEST(calendar_period_open_date,
        LEAST(l_sysdate, calendar_period_close_date))
FROM    fa_deprn_periods
WHERE   book_type_code = p_book_type_code
AND     period_close_date IS NULL;

BEGIN

OPEN fa_date_csr;
FETCH fa_date_csr INTO l_fa_trx_date;
CLOSE fa_date_csr;

RETURN l_fa_trx_date;

EXCEPTION
  WHEN OTHERS THEN
    RETURN NULL;

END get_fa_trx_date;



-- Added by Santonyr 10-Dec-2004 for bug 4028662.
-- This procedure is to return the FA transaction date.

PROCEDURE get_fa_trx_date
  (p_book_type_code  IN VARCHAR2,
   x_return_status OUT NOCOPY VARCHAR2,
   x_fa_trx_date OUT NOCOPY DATE)

IS

l_fa_trx_date DATE;

BEGIN
  x_return_status         := Okl_Api.G_RET_STS_SUCCESS;

  l_fa_trx_date := Okl_Accounting_Util.get_fa_trx_date(p_book_type_code);

  IF l_fa_trx_date IS NULL THEN
     Okl_Api.SET_MESSAGE(p_app_name     => g_app_name,
                         p_msg_name     => 'OKL_NO_FA_TRX_DATE');
     RAISE Okl_Api.G_EXCEPTION_ERROR;
  END IF;

  x_fa_trx_date := l_fa_trx_date;

EXCEPTION
  WHEN Okl_Api.G_EXCEPTION_ERROR THEN
     x_return_status := Okl_Api.G_RET_STS_ERROR ;
  WHEN OTHERS THEN
     x_return_status := Okl_Api.G_RET_STS_UNEXP_ERROR;

END get_fa_trx_date;


-- Added by Santonyr 10-Dec-2004 for bug 4028662.
-- This procedure is to return the first FA transaction date for a contract.

FUNCTION get_fa_trx_start_date
  (p_asset_number IN VARCHAR2,
  p_corporate_book IN VARCHAR2,
  p_khr_id IN NUMBER,
  p_sts_code IN VARCHAR2)
RETURN DATE
IS

l_fa_date DATE;

CURSOR fa_trx_st_dt_csr IS
SELECT
  TXL.FA_TRX_DATE
FROM
  OKL_TXL_ASSETS_B txl,
  OKL_TRX_ASSETS TRX,
  OKL_TRX_TYPES_V TRY
WHERE
  TXL.ASSET_NUMBER = p_asset_number AND
  TXL.CORPORATE_BOOK = p_corporate_book AND
  TXL.DNZ_KHR_ID = p_khr_id  AND
  TXL.TAS_ID = TRX.ID AND
  TRX.TRY_ID = TRY.ID AND
  TRY.NAME IN ('Internal Asset Creation', 'Release');


BEGIN

IF p_sts_code IN ('NEW', 'INCOMPLETE', 'PASSED', 'COMPLETE', 'APPROVED','PENDING_APPROVAL') THEN
  RETURN Okl_Accounting_Util.g_final_date;
ELSE

  OPEN fa_trx_st_dt_csr;
  FETCH fa_trx_st_dt_csr INTO l_fa_date;
  CLOSE fa_trx_st_dt_csr;

  RETURN l_fa_date;
END IF;

EXCEPTION
 WHEN OTHERS THEN
   RETURN NULL;

END get_fa_trx_start_date;


-- Added by Santonyr 10-Dec-2004 for bug 4028662.
-- This procedure is to return the last FA transaction date for a contract.

FUNCTION get_fa_trx_end_date
  (p_asset_number IN VARCHAR2,
  p_corporate_book IN VARCHAR2,
  p_khr_id IN NUMBER)
RETURN DATE
IS

l_fa_date DATE;
l_fa_date_found DATE;

CURSOR fa_trx_end_dt_csr IS
SELECT
  MAX(TXL.FA_TRX_DATE)
FROM
  OKL_TXL_ASSETS_B txl,
  OKL_TRX_ASSETS TRX,
  OKL_TRX_TYPES_V TRY
WHERE
  TXL.ASSET_NUMBER = p_asset_number AND
  TXL.CORPORATE_BOOK = p_corporate_book AND
  TXL.DNZ_KHR_ID = p_khr_id  AND
  TXL.TAS_ID = TRX.ID AND
  TRX.TRY_ID = TRY.ID AND
  TRY.NAME IN ('Off Lease Amortization', 'Asset Disposition');

BEGIN

  OPEN fa_trx_end_dt_csr;
  FETCH fa_trx_end_dt_csr INTO l_fa_date;
  CLOSE fa_trx_end_dt_csr;

  RETURN l_fa_date;

  EXCEPTION
    WHEN OTHERS THEN
      RETURN NULL;

END get_fa_trx_end_date;

-- Added by nikshah 22-Jan-2007 for bug 5707866.
-- This procedure returns valuation method code

FUNCTION get_valuation_method_code( p_ledger_id  NUMBER DEFAULT NULL)
  RETURN VARCHAR2
  AS
    l_ledger_id NUMBER;
    l_val_meth_code GL_LEDGERS.SHORT_NAME%TYPE;

    CURSOR get_gl_short_name_csr(l_ledger_id NUMBER) IS
    SELECT short_name
    FROM gl_ledgers
    WHERE ledger_id = l_ledger_id;

  BEGIN
    l_ledger_id := p_ledger_id;
    IF l_ledger_id IS NULL
    THEN
      l_ledger_id := get_set_of_books_id;
    END IF;
    OPEN get_gl_short_name_csr (l_ledger_id);
    FETCH get_gl_short_name_csr INTO l_val_meth_code;
    CLOSE get_gl_short_name_csr;

    RETURN l_val_meth_code;

  EXCEPTION
    WHEN OTHERS THEN
      IF (get_gl_short_name_csr%ISOPEN) THEN
        CLOSE get_gl_short_name_csr;
      END IF;
	  RETURN(NULL);
END get_valuation_method_code;

-- Added by nikshah 08-Feb-2007 for bug 5707866.
-- This function returns account derivation option

FUNCTION get_account_derivation
  RETURN VARCHAR2
  AS
    l_acct_derv okl_sys_acct_opts.account_derivation%TYPE;

    CURSOR get_acct_derivation_csr
    IS
    SELECT account_derivation
    FROM okl_sys_acct_opts;
  BEGIN
    OPEN get_acct_derivation_csr;
    FETCH get_acct_derivation_csr INTO l_acct_derv;
    CLOSE get_acct_derivation_csr;
    RETURN l_acct_derv;
  EXCEPTION
    WHEN OTHERS THEN
      IF (get_acct_derivation_csr%ISOPEN) THEN
        CLOSE get_acct_derivation_csr;
      END IF;
      RETURN (NULL);
END get_account_derivation;

-- MGAAP 7263041
  FUNCTION get_fa_reporting_book( p_org_id  NUMBER DEFAULT NULL)
  RETURN VARCHAR2 IS
  l_org_id NUMBER;
  l_fa_reporting_book OKL_SYSTEM_PARAMS_ALL.RPT_PROD_BOOK_TYPE_CODE%TYPE;
  CURSOR c_fa_reporting_book(l_org_id NUMBER) IS
         SELECT RPT_PROD_BOOK_TYPE_CODE
         FROM   OKL_SYSTEM_PARAMS_ALL
         WHERE  ORG_ID = l_org_id;
  BEGIN
    IF (p_org_id is NULL OR
        p_org_id = OKL_API.G_MISS_NUM) THEN
      l_org_id := mo_global.get_current_org_id;
    ELSE
      l_org_id := p_org_id;
    END IF;
    FOR r IN c_fa_reporting_book(l_org_id)
    LOOP
      l_fa_reporting_book := r.RPT_PROD_BOOK_TYPE_CODE;
    END LOOP;
    return(l_fa_reporting_book);
  END get_fa_reporting_book;

  FUNCTION get_fa_reporting_book( p_kle_id  NUMBER ) RETURN VARCHAR2 IS
  l_org_id NUMBER;
  l_fa_reporting_book OKL_SYSTEM_PARAMS_ALL.RPT_PROD_BOOK_TYPE_CODE%TYPE;
  CURSOR c_org_id(l_kle_id NUMBER) IS
         SELECT a.authoring_org_id ORG_ID
         FROM   okc_k_headers_all_b a,
                okc_k_lines_b b
         WHERE  b.id = p_kle_id
         AND    b.dnz_chr_id = a.id;
  BEGIN
    FOR recindex IN c_org_id(p_kle_id)
    LOOP
      l_org_id := recindex.ORG_ID;
      l_fa_reporting_book := get_fa_reporting_book(p_org_id => l_org_id);
    END LOOP;
    RETURN(l_fa_reporting_book);
  END get_fa_reporting_book;

-- Start of comments
--
-- Procedure Name  : get_reporting_product
-- Description     : This procedure checks if there is a reporting product attached to the contract
-- Business Rules  :
-- Parameters      :  p_contract_id - Contract ID
-- Version         : 1.0
-- History         : SECHAWLA 09-mar-2009  MG Impact on Investor Agreement - Created
-- End of comments
   PROCEDURE get_reporting_product(p_api_version           IN  	NUMBER,
           		 	              p_init_msg_list         IN  	VARCHAR2,
           			              x_return_status         OUT 	NOCOPY VARCHAR2,
           			              x_msg_count             OUT 	NOCOPY NUMBER,
           			              x_msg_data              OUT 	NOCOPY VARCHAR2,
                                  p_contract_id 		  IN 	NUMBER,
                                  x_rep_product           OUT   NOCOPY VARCHAR2,
								  x_rep_product_id        OUT   NOCOPY NUMBER,
								  x_rep_deal_type         OUT   NOCOPY VARCHAR2 ) IS
  -- Get the financial product of the contract
  CURSOR l_get_fin_product(cp_khr_id IN NUMBER) IS
  SELECT a.start_date, a.contract_number, b.pdt_id
  FROM   okc_k_headers_b a, okl_k_headers b
  WHERE  a.id = b.id
  AND    a.id = cp_khr_id;
  SUBTYPE pdtv_rec_type IS OKL_SETUPPRODUCTS_PUB.pdtv_rec_type;
  SUBTYPE pdt_parameters_rec_type IS OKL_SETUPPRODUCTS_PUB.pdt_parameters_rec_type;
  l_fin_product_id          NUMBER;
  l_start_date              DATE;
  l_contract_number         VARCHAR2(120);
  lp_pdtv_rec               pdtv_rec_type;
  lp_empty_pdtv_rec         pdtv_rec_type;
  lx_pdt_parameter_rec      pdt_parameters_rec_type ;
  l_reporting_product       OKL_PRODUCTS_V.NAME%TYPE;
  l_reporting_product_id    NUMBER;
  lx_no_data_found          BOOLEAN;
  l_mg_rep_book             fa_book_controls.book_type_code%TYPE;
  mg_error                  EXCEPTION;
  l_rep_deal_type           okl_product_parameters_v.deal_type%TYPE;
  BEGIN
    -- get the financial product of the contract
    OPEN  l_get_fin_product(p_contract_id);
    FETCH l_get_fin_product INTO l_start_date, l_contract_number, l_fin_product_id;
    CLOSE l_get_fin_product;
    lp_pdtv_rec.id := l_fin_product_id;
    -- check if the fin product has a reporting product
    OKL_SETUPPRODUCTS_PUB.Getpdt_parameters( p_api_version                  => p_api_version,
  				  			               p_init_msg_list                => OKC_API.G_FALSE,
						                   x_return_status                => x_return_status,
							               x_no_data_found                => lx_no_data_found,
							               x_msg_count                    => x_msg_count,
							               x_msg_data                     => x_msg_data,
							               p_pdtv_rec                     => lp_pdtv_rec,
							               p_product_date                 => l_start_date,
							               p_pdt_parameter_rec            => lx_pdt_parameter_rec);
    IF x_return_status <> OKC_API.G_RET_STS_SUCCESS THEN
        -- Error getting financial product parameters for contract CONTRACT_NUMBER.
        OKC_API.set_message(  p_app_name      => 'OKL',
                           p_msg_name      => 'OKL_AM_FIN_PROD_PARAM_ERR',
                           p_token1        =>  'CONTRACT_NUMBER',
                           p_token1_value  =>  l_contract_number);
    ELSE
        x_rep_product := lx_pdt_parameter_rec.reporting_product;
        x_rep_product_id := lx_pdt_parameter_rec.reporting_pdt_id;

        IF x_rep_product IS NOT NULL AND x_rep_product <> OKC_API.G_MISS_CHAR THEN
            lp_pdtv_rec := lp_empty_pdtv_rec;
            lp_pdtv_rec.id := x_rep_product_id;

		    -- get the deal type of the reporting product
            OKL_SETUPPRODUCTS_PUB.Getpdt_parameters( p_api_version                  => p_api_version,
  				  			               p_init_msg_list                => OKC_API.G_FALSE,
						                   x_return_status                => x_return_status,
							               x_no_data_found                => lx_no_data_found,
							               x_msg_count                    => x_msg_count,
							               x_msg_data                     => x_msg_data,
							               p_pdtv_rec                     => lp_pdtv_rec,
							               p_product_date                 => l_start_date,
							               p_pdt_parameter_rec            => lx_pdt_parameter_rec);

            IF x_return_status <> OKC_API.G_RET_STS_SUCCESS THEN
                -- Error getting reporting product parameters for contract CONTRACT_NUMBER.
                OKC_API.set_message(  p_app_name      => 'OKL',
                                  p_msg_name      => 'OKL_AM_REP_PROD_PARAM_ERR',
                                  p_token1        => 'CONTRACT_NUMBER',
                                  p_token1_value  => l_contract_number);


            ELSE

                l_rep_deal_type := lx_pdt_parameter_rec.Deal_Type;
                IF l_rep_deal_type IS NULL OR l_rep_deal_type = OKC_API.G_MISS_CHAR THEN
                    --Deal Type not defined for Reporting product REP_PROD.
                    OKC_API.set_message(  p_app_name      => 'OKL',
                                 p_msg_name      => 'OKL_AM_NO_MG_DEAL_TYPE',
                                 p_token1        => 'REP_PROD',
                                 p_token1_value  => l_reporting_product);

                    x_return_status := OKL_API.G_RET_STS_ERROR;
                ELSE
                    x_rep_deal_type :=  l_rep_deal_type ;
                END IF;
            END IF;
        END IF;
    END IF;
  EXCEPTION
      WHEN OTHERS THEN
         IF l_get_fin_product%ISOPEN THEN
            CLOSE l_get_fin_product;
         END IF;
         OKL_API.set_message(p_app_name      => 'OKC',
                         p_msg_name      => g_unexpected_error,
                         p_token1        => g_sqlcode_token,
                         p_token1_value  => sqlcode,
                         p_token2        => g_sqlerrm_token,
                         p_token2_value  => sqlerrm);
          x_return_status := OKL_API.G_RET_STS_UNEXP_ERROR;
  END get_reporting_product;

END okl_accounting_util;

/
