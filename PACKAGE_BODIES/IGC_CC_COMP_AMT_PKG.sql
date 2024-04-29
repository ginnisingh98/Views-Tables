--------------------------------------------------------
--  DDL for Package Body IGC_CC_COMP_AMT_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IGC_CC_COMP_AMT_PKG" AS
/*$Header: IGCCCBAB.pls 120.5.12000000.1 2007/08/20 12:11:21 mbremkum ship $*/

FUNCTION COMPUTE_ACCT_BILLED_AMT_CURR(p_cc_acct_line_id NUMBER)
RETURN NUMBER
IS
	l_func_billed_amount    NUMBER := 0;
	l_cc_num                igc_cc_headers.cc_num%TYPE;
	l_cc_type               igc_cc_headers.cc_type%TYPE;
	l_org_id                igc_cc_headers.org_id%TYPE;
	l_cc_header_id          igc_cc_headers.cc_header_id%TYPE;
	l_cc_acct_line_num      igc_cc_acct_lines.cc_acct_line_num%TYPE;
BEGIN

	SELECT  cc_acct_line_num,   cc_header_id
	INTO    l_cc_acct_line_num, l_cc_header_id
	FROM    igc_cc_acct_lines
	WHERE   cc_acct_line_id     = p_cc_acct_line_id;

	SELECT  cc_num, org_id, cc_type
        INTO    l_cc_num, l_org_id, l_cc_type
	FROM    igc_cc_headers
	WHERE   cc_header_id = l_cc_header_id;

	IF ( (l_cc_type = 'S') OR (l_cc_type = 'R') )
	THEN
		BEGIN

			SELECT NVL(SUM(DECODE(apid.base_amount,NULL,apid.amount,apid.base_amount)),0)
				INTO l_func_billed_amount
			FROM
				ap_invoice_distributions_all apid,
               			po_distributions_all pod,
	        		po_line_locations_all pll,
	       	 		po_lines_all pol,
               		 	po_headers_all poh
			WHERE
				apid.po_distribution_id    = pod.po_distribution_id AND
				apid.LINE_TYPE_LOOKUP_CODE = 'ITEM' AND
				poh.segment1               = l_cc_num AND
				poh.type_lookup_code       = 'STANDARD' AND
				poh.org_id                 = l_org_id AND
				pol.po_header_id           = poh.po_header_id AND
				pol.line_num               = l_cc_acct_line_num AND
				pll.po_line_id             = pol.po_line_id AND
				pll.po_header_id           = pol.po_header_id AND
				pod.po_header_id           = pll.po_header_id AND
				pod.po_line_id             = pll.po_line_id AND
				pod.line_location_id       = pll.line_location_id ;
		EXCEPTION
			WHEN NO_DATA_FOUND
			THEN
				l_func_billed_amount := 0;
		END;

	ELSIF (l_cc_type = 'C')
	THEN
		BEGIN
                        -- Performance fixes. Replaced the following sql
                        -- with the one below.
                        /*
			SELECT NVL(SUM(NVL(cc_acct_func_billed_amt,0)),0)
			INTO l_func_billed_amount
			FROM igc_cc_acct_lines
			WHERE parent_acct_line_id = p_cc_acct_line_id;
                        */
			SELECT NVL(SUM(NVL(IGC_CC_COMP_AMT_PKG.COMPUTE_ACCT_FUNC_BILLED_AMT( ccal.cc_acct_line_id),0)),0)
			INTO l_func_billed_amount
			FROM igc_cc_acct_lines ccal
			WHERE ccal.parent_acct_line_id = p_cc_acct_line_id;
		EXCEPTION
			WHEN NO_DATA_FOUND
			THEN
				l_func_billed_amount := 0;
		END;
	END IF;

	RETURN(l_func_billed_amount);

END COMPUTE_ACCT_BILLED_AMT_CURR;

FUNCTION COMPUTE_PF_BILL_AMT_CURR(p_cc_det_pf_line_id  NUMBER,
			            p_cc_det_pf_line_num  NUMBER,
		                    p_cc_acct_line_id     NUMBER)
RETURN NUMBER
IS
	l_func_billed_amount    NUMBER := 0;
	l_cc_num                igc_cc_headers.cc_num%TYPE;
	l_cc_type               igc_cc_headers.cc_type%TYPE;
	l_org_id                igc_cc_headers.org_id%TYPE;
	l_cc_header_id          igc_cc_headers.cc_header_id%TYPE;
	l_cc_acct_line_num      igc_cc_acct_lines.cc_acct_line_num%TYPE;
BEGIN

	SELECT  cc_acct_line_num,   cc_header_id
	INTO    l_cc_acct_line_num, l_cc_header_id
	FROM    igc_cc_acct_lines
	WHERE   cc_acct_line_id     = p_cc_acct_line_id;

	SELECT  cc_num, org_id, cc_type
        INTO    l_cc_num, l_org_id, l_cc_type
	FROM    igc_cc_headers
	WHERE   cc_header_id = l_cc_header_id;

	IF ( (l_cc_type = 'S') OR (l_cc_type = 'R') )
	THEN

		BEGIN

			SELECT NVL(SUM(DECODE(apid.base_amount,NULL,apid.amount,apid.base_amount)),0)
				INTO l_func_billed_amount
			FROM
				ap_invoice_distributions_all apid,
               			po_distributions_all pod,
	        		po_line_locations_all pll,
	       	 		po_lines_all pol,
               		 	po_headers_all poh
			WHERE
				apid.po_distribution_id    = pod.po_distribution_id AND
				apid.LINE_TYPE_LOOKUP_CODE = 'ITEM' AND
				poh.segment1               = l_cc_num AND
				poh.type_lookup_code       = 'STANDARD' AND
				poh.org_id                 = l_org_id AND
				pol.po_header_id           = poh.po_header_id AND
				pol.line_num               = l_cc_acct_line_num AND
				pll.po_line_id             = pol.po_line_id AND
				pll.po_header_id           = pol.po_header_id AND
				pod.po_header_id           = pll.po_header_id AND
				pod.po_line_id             = pll.po_line_id AND
				pod.line_location_id       = pll.line_location_id AND
				pod.distribution_num       = p_cc_det_pf_line_num;
		EXCEPTION
			WHEN NO_DATA_FOUND
			THEN
				l_func_billed_amount := 0;
		END;
	ELSIF (l_cc_type = 'C')
	THEN
		BEGIN
			SELECT NVL(SUM(NVL(cc_det_pf_func_billed_amt,0)),0)
			INTO l_func_billed_amount
			FROM igc_cc_det_pf_v
			WHERE parent_det_pf_line_id = p_cc_det_pf_line_id;
		EXCEPTION
			WHEN NO_DATA_FOUND
			THEN
				l_func_billed_amount := 0;
		END;
	END IF;

	RETURN(l_func_billed_amount);

END COMPUTE_PF_BILL_AMT_CURR;

FUNCTION COMPUTE_PF_BILLED_AMT(p_cc_det_pf_line_id  NUMBER,
			       p_cc_det_pf_line_num  NUMBER,
		               p_cc_acct_line_id     NUMBER)
RETURN NUMBER
IS
	l_billed_amount         NUMBER := 0;
	l_cc_num                igc_cc_headers.cc_num%TYPE;
	l_cc_type               igc_cc_headers.cc_type%TYPE;
	l_org_id                igc_cc_headers.org_id%TYPE;
	l_cc_header_id          igc_cc_headers.cc_header_id%TYPE;
	l_cc_acct_line_num      igc_cc_acct_lines.cc_acct_line_num%TYPE;
	l_sob_id                igc_cc_headers.set_of_books_id%TYPE;
        l_currency_code         igc_cc_headers.currency_code%TYPE;
        l_func_currency_code    igc_cc_headers.currency_code%TYPE;
BEGIN

	SELECT  cc_acct_line_num,   cc_header_id
	INTO    l_cc_acct_line_num, l_cc_header_id
	FROM    igc_cc_acct_lines
	WHERE   cc_acct_line_id     = p_cc_acct_line_id;

	SELECT  cc_num, org_id, cc_type, set_of_books_id, currency_code
        INTO    l_cc_num, l_org_id, l_cc_type, l_sob_id, l_currency_code
	FROM    igc_cc_headers
	WHERE   cc_header_id = l_cc_header_id;

	SELECT currency_code
        INTO  l_func_currency_code
	FROM gl_sets_of_books
        WHERE set_of_books_id = l_sob_id;

	IF ( (l_cc_type = 'S') OR (l_cc_type = 'R') )
	THEN

		BEGIN

			SELECT  NVL(pod.amount_billed,0)
			INTO    l_billed_amount
			FROM
				po_headers_all poh,
				po_lines_all   pol,
				po_line_locations_all pll,
				po_distributions_all pod
			WHERE
				poh.segment1         = l_cc_num AND
				poh.type_lookup_code = 'STANDARD' AND
				poh.org_id           = l_org_id AND
				pol.po_header_id     = poh.po_header_id AND
				pol.line_num         = l_cc_acct_line_num AND
				pll.po_line_id       = pol.po_line_id AND
				pll.po_header_id     = pol.po_header_id AND
				pod.po_header_id     = pll.po_header_id AND
				pod.po_line_id       = pll.po_line_id AND
				pod.line_location_id = pll.line_location_id AND
				pod.distribution_num = p_cc_det_pf_line_num;
		EXCEPTION
			WHEN NO_DATA_FOUND
			THEN
				l_billed_amount := 0;
		END;
	ELSIF (l_cc_type = 'C')
	THEN

-- Bug # 1459569, 1520481.

		l_billed_amount := 0;

		IF (l_currency_code <> l_func_currency_code)
		THEN

			BEGIN
				SELECT NVL(SUM(NVL(cc_det_pf_billed_amt,0)),0)
				INTO l_billed_amount
				FROM igc_cc_det_pf_v
				WHERE parent_det_pf_line_id = p_cc_det_pf_line_id;
			EXCEPTION
				WHEN NO_DATA_FOUND
				THEN
					l_billed_amount := 0;
			END;

		END IF;

		IF (l_currency_code = l_func_currency_code)
		THEN

			BEGIN
			 SELECT NVL(SUM(NVL(COMPUTE_PF_BILL_AMT_CURR(det.cc_det_pf_line_id,
                	 det.cc_det_pf_line_num,det.cc_acct_line_id),0)),0)
                         INTO l_billed_amount
                	 FROM igc_cc_det_pf det
                 	 where parent_det_pf_line_id=p_cc_det_pf_line_id;
			EXCEPTION
				WHEN NO_DATA_FOUND
				THEN
					l_billed_amount := 0;
			END;

		END IF;


	END IF;

	RETURN(l_billed_amount);

END COMPUTE_PF_BILLED_AMT;

FUNCTION COMPUTE_ACCT_BILLED_AMT(p_cc_acct_line_id NUMBER)
RETURN NUMBER
IS
	l_billed_amount         NUMBER := 0;
	l_cc_num                igc_cc_headers.cc_num%TYPE;
	l_cc_type               igc_cc_headers.cc_type%TYPE;
	l_org_id                igc_cc_headers.org_id%TYPE;
	l_cc_header_id          igc_cc_headers.cc_header_id%TYPE;
	l_cc_acct_line_num      igc_cc_acct_lines.cc_acct_line_num%TYPE;
	l_sob_id                igc_cc_headers.set_of_books_id%TYPE;
        l_currency_code         igc_cc_headers.currency_code%TYPE;
        l_func_currency_code    igc_cc_headers.currency_code%TYPE;
BEGIN

	SELECT  cc_acct_line_num,   cc_header_id
	INTO    l_cc_acct_line_num, l_cc_header_id
	FROM    igc_cc_acct_lines
	WHERE   cc_acct_line_id     = p_cc_acct_line_id;

	SELECT  cc_num, org_id, cc_type, set_of_books_id, currency_code
        INTO    l_cc_num, l_org_id, l_cc_type, l_sob_id, l_currency_code
	FROM    igc_cc_headers
	WHERE   cc_header_id = l_cc_header_id;

	SELECT currency_code
        INTO  l_func_currency_code
	FROM gl_sets_of_books
        WHERE set_of_books_id = l_sob_id;


	IF ( (l_cc_type = 'S') OR (l_cc_type = 'R') )
	THEN
		BEGIN

			SELECT NVL(SUM(NVL(pod.amount_billed,0)),0)
			INTO l_billed_amount
			FROM
				po_headers_all poh,
				po_lines_all pol,
				po_line_locations_all pll,
				po_distributions_all pod
			WHERE
				poh.segment1 = l_cc_num AND
				poh.type_lookup_code = 'STANDARD' AND
				poh.org_id  = l_org_id AND
				pol.po_header_id = poh.po_header_id AND
				pol.line_num = l_cc_acct_line_num AND
				pll.po_line_id = pol.po_line_id AND
				pll.po_header_id = pol.po_header_id AND
				pod.po_header_id = pll.po_header_id AND
				pod.po_line_id = pll.po_line_id AND
				pod.line_location_id = pll.line_location_id ;
		EXCEPTION
			WHEN NO_DATA_FOUND
			THEN
				l_billed_amount := 0;
		END;

	ELSIF (l_cc_type = 'C')
	THEN

-- Bug # 1459569, 1520481.

		l_billed_amount := 0;

		IF (l_currency_code <> l_func_currency_code)
		THEN
			 BEGIN
                                -- Performance Tuning, replaced the following
                                -- sql with a direct select from the table
                                /*
				SELECT NVL(SUM(NVL(cc_acct_billed_amt,0)),0)
				INTO l_billed_amount
				FROM igc_cc_acct_lines_v
				WHERE parent_acct_line_id = p_cc_acct_line_id;
                                */
				SELECT NVL(SUM(NVL(IGC_CC_COMP_AMT_PKG.COMPUTE_ACCT_BILLED_AMT( ccal.cc_acct_line_id),0)),0)
				INTO l_billed_amount
				FROM igc_cc_acct_lines ccal
				WHERE ccal.parent_acct_line_id = p_cc_acct_line_id;
			EXCEPTION
				WHEN NO_DATA_FOUND
				THEN
					l_billed_amount := 0;
			END;
		END IF;

		IF (l_currency_code = l_func_currency_code)
		THEN
			 BEGIN
                                -- Performance Tuning. Replaced the following
                                -- sql with the one below.
                                /*
				SELECT NVL(SUM(NVL(cc_acct_func_billed_amt,0)),0)
				INTO l_billed_amount
				FROM igc_cc_acct_lines_v
				WHERE parent_acct_line_id = p_cc_acct_line_id;
				*/
				SELECT NVL(SUM(NVL(IGC_CC_COMP_AMT_PKG.COMPUTE_ACCT_BILLED_AMT_CURR( ccal.cc_acct_line_id),0)),0)
				INTO l_billed_amount
				FROM igc_cc_acct_lines ccal
				WHERE ccal.parent_acct_line_id = p_cc_acct_line_id;
			EXCEPTION
				WHEN NO_DATA_FOUND
				THEN
					l_billed_amount := 0;
			END;
		END IF;

	END IF;

	RETURN(l_billed_amount);

END COMPUTE_ACCT_BILLED_AMT;

FUNCTION COMPUTE_FUNCTIONAL_AMT ( p_cc_header_id NUMBER, p_cc_func_amt NUMBER)
RETURN NUMBER
IS
	l_cc_conversion_rate 	igc_cc_headers.conversion_rate%TYPE;
	l_cc_func_amt		igc_cc_acct_lines.cc_acct_func_amt%TYPE;
BEGIN
	BEGIN
		SELECT cc.conversion_rate
		INTO l_cc_conversion_rate
		FROM igc_cc_headers cc
		WHERE cc.cc_header_id = p_cc_header_id;
		EXCEPTION
			 WHEN NO_DATA_FOUND THEN
		             l_cc_conversion_rate := 1;
	END;

	l_cc_func_amt := NVL(p_cc_func_amt,0) * NVL(l_cc_conversion_rate,1);

        RETURN(l_cc_func_amt);

END COMPUTE_FUNCTIONAL_AMT;

FUNCTION COMPUTE_PF_FUNC_BILLED_AMT(p_cc_det_pf_line_id  NUMBER,
			            p_cc_det_pf_line_num  NUMBER,
		                    p_cc_acct_line_id     NUMBER)
RETURN NUMBER
IS
	l_func_billed_amount    NUMBER := 0;
	l_cc_num                igc_cc_headers.cc_num%TYPE;
	l_cc_type               igc_cc_headers.cc_type%TYPE;
	l_org_id                igc_cc_headers.org_id%TYPE;
	l_cc_header_id          igc_cc_headers.cc_header_id%TYPE;
	l_cc_acct_line_num      igc_cc_acct_lines.cc_acct_line_num%TYPE;
BEGIN

	SELECT  cc_acct_line_num,   cc_header_id
	INTO    l_cc_acct_line_num, l_cc_header_id
	FROM    igc_cc_acct_lines
	WHERE   cc_acct_line_id     = p_cc_acct_line_id;

	SELECT  cc_num, org_id, cc_type
        INTO    l_cc_num, l_org_id, l_cc_type
	FROM    igc_cc_headers
	WHERE   cc_header_id = l_cc_header_id;

	IF ( (l_cc_type = 'S') OR (l_cc_type = 'R') )
	THEN

		BEGIN

			SELECT NVL(SUM(DECODE(apid.base_amount,NULL,apid.amount,apid.base_amount)),0)
				INTO l_func_billed_amount
			FROM
				ap_invoice_distributions_all apid,
               			po_distributions_all pod,
	        		po_line_locations_all pll,
	       	 		po_lines_all pol,
               		 	po_headers_all poh
			WHERE
				apid.po_distribution_id    = pod.po_distribution_id AND
				poh.segment1               = l_cc_num AND
				poh.type_lookup_code       = 'STANDARD' AND
				poh.org_id                 = l_org_id AND
				pol.po_header_id           = poh.po_header_id AND
				pol.line_num               = l_cc_acct_line_num AND
				pll.po_line_id             = pol.po_line_id AND
				pll.po_header_id           = pol.po_header_id AND
				pod.po_header_id           = pll.po_header_id AND
				pod.po_line_id             = pll.po_line_id AND
				pod.line_location_id       = pll.line_location_id AND
				pod.distribution_num       = p_cc_det_pf_line_num;
		EXCEPTION
			WHEN NO_DATA_FOUND
			THEN
				l_func_billed_amount := 0;
		END;
	ELSIF (l_cc_type = 'C')
	THEN
		BEGIN
			SELECT NVL(SUM(NVL(cc_det_pf_func_billed_amt,0)),0)
			INTO l_func_billed_amount
			FROM igc_cc_det_pf_v
			WHERE parent_det_pf_line_id = p_cc_det_pf_line_id;
		EXCEPTION
			WHEN NO_DATA_FOUND
			THEN
				l_func_billed_amount := 0;
		END;
	END IF;

	RETURN(l_func_billed_amount);

END COMPUTE_PF_FUNC_BILLED_AMT;

FUNCTION COMPUTE_ACCT_FUNC_BILLED_AMT(p_cc_acct_line_id NUMBER)
RETURN NUMBER
IS
	l_func_billed_amount    NUMBER := 0;
	l_cc_num                igc_cc_headers.cc_num%TYPE;
	l_cc_type               igc_cc_headers.cc_type%TYPE;
	l_org_id                igc_cc_headers.org_id%TYPE;
	l_cc_header_id          igc_cc_headers.cc_header_id%TYPE;
	l_cc_acct_line_num      igc_cc_acct_lines.cc_acct_line_num%TYPE;
BEGIN

	SELECT  cc_acct_line_num,   cc_header_id
	INTO    l_cc_acct_line_num, l_cc_header_id
	FROM    igc_cc_acct_lines
	WHERE   cc_acct_line_id     = p_cc_acct_line_id;

	SELECT  cc_num, org_id, cc_type
        INTO    l_cc_num, l_org_id, l_cc_type
	FROM    igc_cc_headers
	WHERE   cc_header_id = l_cc_header_id;

	IF ( (l_cc_type = 'S') OR (l_cc_type = 'R') )
	THEN
		BEGIN

			SELECT NVL(SUM(DECODE(apid.base_amount,NULL,apid.amount,apid.base_amount)),0)
				INTO l_func_billed_amount
			FROM
				ap_invoice_distributions_all apid,
               			po_distributions_all pod,
	        		po_line_locations_all pll,
	       	 		po_lines_all pol,
               		 	po_headers_all poh
			WHERE
				apid.po_distribution_id    = pod.po_distribution_id AND
				poh.segment1               = l_cc_num AND
				poh.type_lookup_code       = 'STANDARD' AND
				poh.org_id                 = l_org_id AND
				pol.po_header_id           = poh.po_header_id AND
				pol.line_num               = l_cc_acct_line_num AND
				pll.po_line_id             = pol.po_line_id AND
				pll.po_header_id           = pol.po_header_id AND
				pod.po_header_id           = pll.po_header_id AND
				pod.po_line_id             = pll.po_line_id AND
				pod.line_location_id       = pll.line_location_id ;
		EXCEPTION
			WHEN NO_DATA_FOUND
			THEN
				l_func_billed_amount := 0;
		END;

	ELSIF (l_cc_type = 'C')
	THEN
		BEGIN
                        -- Performance fixes. Replaced the following sql
                        -- with the one below.
                        /*
			SELECT NVL(SUM(NVL(cc_acct_func_billed_amt,0)),0)
			INTO l_func_billed_amount
			FROM igc_cc_acct_lines
			WHERE parent_acct_line_id = p_cc_acct_line_id;
                        */
			SELECT NVL(SUM(NVL(IGC_CC_COMP_AMT_PKG.COMPUTE_ACCT_FUNC_BILLED_AMT( ccal.cc_acct_line_id),0)),0)
			INTO l_func_billed_amount
			FROM igc_cc_acct_lines ccal
			WHERE ccal.parent_acct_line_id = p_cc_acct_line_id;
		EXCEPTION
			WHEN NO_DATA_FOUND
			THEN
				l_func_billed_amount := 0;
		END;
	END IF;

	RETURN(l_func_billed_amount);

END COMPUTE_ACCT_FUNC_BILLED_AMT;



END IGC_CC_COMP_AMT_PKG;

/
