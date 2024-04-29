--------------------------------------------------------
--  DDL for Package Body GMF_ALLOC_PROCESS_PRIVATE
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."GMF_ALLOC_PROCESS_PRIVATE" AS
/* $Header: gmfalcpb.pls 115.5 2002/11/11 00:28:41 rseshadr ship $ */

   /*********************************************************************************
   *  FUNCTION
   *    get_company_acct_masks
   *
   *  DESCRIPTION
   *     Retrieves the masks of accounting units and accounts.
   *  INPUT PARAMETERS
   *     v_co_code
   *
   *  OUTPUT PARAMETERS
   *     P_deli_acct_mask
   *     P_deli_au_mask :=
   *     P_deli_comp :=
   *     P_deli_au_len :
   *     P_deli_acct_len
   *     P_deli_key_mask
   *
   *  RETURNS
   *           0  =  Sucessful
   *          -1  =  No Segments found
   *          -2  =  No delimeter found
   *          -3  =  No  Account unit segments found.
   *  HISTORY
   *     sukarna Reddy                12/15/97       Converted from jpl to PLSQL
   *     Manish Gupta                 02-MAR-99      Bug 841019
   *						     Commented Package DBMS_OUTPUT.
   *    Sukarna Reddy                21-JAN-01      Changed variable declarations to be
   *                                                of database column type.
   *    R.Sharath Kumar              30-Oct-2002    Bug# 2641405
   *                                                Added NOCOPY hint
   ************************************************************************************/


  FUNCTION get_company_acct_masks(V_co_code IN VARCHAR2) RETURN NUMBER IS
    x_au_deli_nm  	VARCHAR2(200) 	DEFAULT NULL;
    x_acct_deli_nm  	VARCHAR2(300) 	DEFAULT NULL;
    x_acct_deli  	VARCHAR2(2) 	DEFAULT NULL;
    x_au_deli  		VARCHAR2(2) 	DEFAULT NULL;
    x_gl_deli  		VARCHAR2(4) 	DEFAULT NULL;

    CURSOR Cur_seg_delimeter IS
      SELECT segment_delimiter
      FROM   gl_plcy_mst
      WHERE  co_code =  v_co_code;

    CURSOR Cur_segtypecnt(v_type IN NUMBER) IS
      SELECT COUNT(1)
      FROM   gl_plcy_seg
      WHERE  co_code  = v_co_code
             AND type = v_type;

    CURSOR Cur_segment_type(v_type IN NUMBER) IS
      SELECT segment_no,
             length,
             short_name
      FROM   gl_plcy_seg
      WHERE  co_code  = v_co_code
		     AND type = v_type
      ORDER BY 1 ASC;

    CURSOR Cur_segment_cnt IS
      SELECT COUNT(1)
      FROM   gl_plcy_seg
      WHERE  co_code = v_co_code;

    x_a           	      	NUMBER(8)     DEFAULT 0;	/* stores accts start position*/
    x_deli_au_len 	      	NUMBER(10)    DEFAULT 0;	/* sotres AU length*/
    x_deli_acct_len        	NUMBER(10)    DEFAULT 0;	/* stores accts length*/
    x_deli_comp  	      	VARCHAR2(4)   DEFAULT NULL;	/* stores company delimeter*/
    x_deli_key_mask 	   	VARCHAR2(500) DEFAULT NULL;	/* stores complete mask for key*/
    x_Count 		      	NUMBER(10)    DEFAULT 0;
    x_deli_au_mask 	      	gl_accu_mst.acctg_unit_no%TYPE  DEFAULT NULL; /* stores mask for AU*/
    x_deli_acct_mask 	   	gl_acct_mst.acct_no%TYPE         DEFAULT NULL;	/* stores mask for accts*/
    x_type0_cnt            	NUMBER(10)    DEFAULT 0;	/* stores no of segments for AU*/
    x_type1_cnt            	NUMBER(10)    DEFAULT 0; 	/* stores no of segments for accts*/
    x_seg_delimeter		    VARCHAR2(2);				/* stores the segment delimeter.*/

  BEGIN

    OPEN Cur_segment_cnt;
    FETCH Cur_segment_cnt INTO X_count;
    CLOSE Cur_segment_cnt;

    IF (X_count = 0) THEN
      RETURN(-1);
    END IF;

    OPEN  Cur_seg_delimeter;
    FETCH Cur_seg_delimeter INTO X_seg_delimeter;
    IF (Cur_seg_delimeter%NOTFOUND) THEN
      -- DBMS_OUTPUT.PUT_LINE('Delimeter not found');
      RETURN(-2);  /* Delimiter not found*/
    END IF;

    IF Cur_seg_delimeter%ISOPEN THEN
      CLOSE Cur_seg_delimeter;
    END IF;
    X_gl_deli := X_seg_delimeter;

    IF (X_gl_deli IS NULL) THEN
      X_gl_deli := '^';
    END IF;
    x_deli_au_len            := 0;
    x_deli_acct_len 	     := 0;
    x_deli_comp      	     := NULL;
    x_deli_key_mask  	     := NULL;
    x_deli_au_mask   	     := NULL;
    x_deli_acct_mask 	     := NULL;

  /* get the segments for the accounting units making sure they are in seg Order*/

    OPEN cur_segtypecnt(0);
    FETCH Cur_segtypecnt INTO X_count;
    CLOSE Cur_segtypecnt;
    x_type0_cnt := x_count;

    IF (x_count = 0) THEN
      RETURN(-3);
    END IF;

    FOR Cur_tmp_segtyp0 IN Cur_Segment_type(0) LOOP
      x_deli_au_len := x_deli_au_len + Cur_tmp_segtyp0.length + 1;
      x_type1_cnt   := Cur_Segment_type%ROWCOUNT;
    END LOOP;
    IF (x_deli_au_len > 0) THEN
      x_deli_au_len := x_deli_au_len - 1;
    END IF;

    FOR Cur_tmp_segtyp1 IN Cur_Segment_type(1) LOOP
      x_deli_acct_len := x_deli_acct_len + Cur_tmp_segtyp1.length + 1;
      x_type1_cnt     := Cur_Segment_type%ROWCOUNT;
    END LOOP;
    IF (x_deli_acct_len > 0) THEN
      x_deli_acct_len := X_deli_acct_len - 1;
    END IF;

    X_deli_comp := V_co_code;

  /* get the segments for the accounts making sure they are in seg order*/
    OPEN cur_segtypecnt(1);
    FETCH Cur_segtypecnt INTO x_count;
    CLOSE Cur_segtypecnt;
    x_type1_cnt := x_count;
    IF (x_count = 0) THEN
      RETURN(-1);
    END IF;
    FOR Cur_tmpseg_typ0 IN Cur_segment_type(0) LOOP
      FOR i IN 1..Cur_tmpseg_typ0.length LOOP
        x_deli_key_mask := x_deli_key_mask||' ';
      END LOOP;
      IF(x_type0_cnt > 1) AND
			(x_type0_cnt <> Cur_segment_type%ROWCOUNT)THEN
        x_deli_key_mask := x_deli_key_mask||x_gl_deli;
      END IF;
    END LOOP;

    x_deli_key_mask := x_deli_key_mask||'^';
    FOR Cur_tmpseg_typ1 IN Cur_segment_type(1) LOOP
      FOR i IN 1..Cur_tmpseg_typ1.length LOOP
        x_deli_key_mask := x_deli_key_mask||' ';
      END LOOP;
      IF (x_type1_cnt > 1) AND
	 (x_type1_cnt <> Cur_segment_type%ROWCOUNT) THEN
        x_deli_key_mask := x_deli_key_mask||x_gl_deli;
      END IF;
    END LOOP;
    x_a := x_deli_au_len + 2;

    -- B1043070 Changed substrb to substr, We need mask character and not byte
    -- P_deli_acct_mask := substrb(x_deli_key_mask, x_a, x_deli_acct_len);
    P_deli_acct_mask := substr(x_deli_key_mask, x_a, x_deli_acct_len);
    -- P_deli_au_mask := substrb(x_deli_key_mask, 1, x_deli_au_len);
    P_deli_au_mask := substr(x_deli_key_mask, 1, x_deli_au_len);
    P_deli_comp := x_deli_comp;
    P_deli_au_len := TO_CHAR(x_deli_au_len);
    P_deli_acct_len := TO_CHAR(x_deli_acct_len);
    P_deli_key_mask := x_deli_key_mask;
    RETURN(0);
  END get_company_acct_masks;


  /*********************************************************************************
   * FUNCTION
   *   format_string
   *
   *  DESCRIPTION
   *  Copy string and/or mask from string to output.
   *	 The result is returned in x_output.
   *
   *    Mask characters include
   *      ! = change to upper case
   *      # = number only, leave blank if not number
   *	  ^ = leave space
   *
   *  Any other character in the mask is assumed to be a literal
   *	 and will be used as a separator in the output string.
   *
   *  Example:
   *	   format_string '...xyz01234567890"   .   .   ^  .'
   *
   *    Would produce the result: "xyz.123.456 67.890"
   *
   *  INPUT PARAMETERS
   *    v_string
   *    v_mask
   *
   *  OUTPUT PARAMETERS
   *   <None>
   *
   *  RETURNS
   *    Formatted string.
   *
   *
   ***********************************************************************************/

  FUNCTION format_string (V_string IN OUT NOCOPY VARCHAR2, V_mask IN VARCHAR2) RETURN VARCHAR2 IS
    X_rvar  	VARCHAR2(9);
    i  		NUMBER(10);
    j  		NUMBER(10);
    k  		NUMBER(10);
    X_slen  	NUMBER(9);
    X_mlen  	NUMBER(9);
    X_punct  	VARCHAR2(250) 	DEFAULT NULL;
    X_output  	VARCHAR2(250) 	DEFAULT NULL;
    X_temp  	VARCHAR2(250) 	DEFAULT NULL;
    X_pos 	NUMBER(10) 	DEFAULT 0;
  BEGIN
    /* i index into output*/
    /* j index into string*/
    /* k index into mask*/
	 -- B1043070 No change for "length"
    X_slen := LENGTH(V_string);
    X_mlen := LENGTH(V_mask);
    -- B1043070: Changed instrb to instr, we need character position
    -- X_pos :=instrb(V_mask, '^', 1);
    X_pos :=instr(V_mask, '^', 1);
    /*  Step 1, get all the characters in the mask to remove from the input string*/

    i := 1;
    WHILE (i <= X_mlen) LOOP
      -- B1043070: Changed all substrb to substr, we need character comparision
      IF ((substr(V_mask, i, 1) <> ' ') AND
          (substr(V_mask, i, 1) <> '^') AND
	  (substr(V_mask, i, 1) <> '#') AND
          (substr(V_mask, i, 1) <> '!')) THEN
        X_punct := X_punct || substr(V_mask, i, 1);
      END IF;
      /* Step 2 remove the punctuation character(s) from the input string*/
      i := i + 1;
    END LOOP;
    j := 1;
    i := 1;
    WHILE (i <= X_slen) LOOP
      -- B1043070: Changed instrb to instr, we need character position
      -- B1043070: Changed substrb to substr, we need character
      -- X_rvar := instrb(X_punct, substrb(V_string, i, 1), 1);
      X_rvar := instr(X_punct, substr(V_string, i, 1), 1);
      IF (X_rvar = 0) THEN
        X_temp := X_temp || substr(V_string, i, 1);
      END IF;
      i := i + 1;
    END LOOP;
    IF X_temp IS NOT NULL THEN
      V_string := X_temp;
    END IF;
    j := 1;
    k := 1;
    i := 1;
    WHILE (i <= 255) LOOP
      IF (k <= X_mlen) THEN
        IF (substr(V_mask, k, 1) = ' ') THEN
          IF (j <= X_slen) THEN
            X_output := X_output||substr(V_string, j, 1);
            j := j + 1;
          ELSE
            X_output:= X_output||' ';
          END IF;
        ELSIF (substr(V_mask, k, 1) = '!') THEN
          IF (j <= X_slen) THEN
            X_output:= X_output||UPPER(substr(V_string, j, 1));
            j := j + 1;
          END IF;
        ELSIF (substr(V_mask, k, 1) = '#') THEN
          IF (j <= X_slen) THEN
            IF ((substr(V_string, j, 1) >= '0' AND substr(V_string, j, 1) <= '9')) THEN
              X_output:= X_output||substr(V_string, j, 1);
            ELSE
              X_output:= X_output||' ';
            END IF;
            j := j + 1;
          END IF;
        ELSIF (substr(V_mask, k, 1) = '^') THEN
          IF (j <= X_slen) THEN
            IF (substr(V_string, J, 1) = ' ') THEN
              j := j + 1;
            ELSE
              X_output:= X_output||' ';

            END IF;
          END IF;
        ELSE
          IF (k <> X_pos - 1) THEN
            X_output:= X_output||substr(V_mask, k, 1);
          END IF;
        END IF;
      ELSIF (j <= X_slen) THEN
        X_output:= X_output||substr(V_string, j, 1);
        j := j + 1;
      ELSE
        EXIT;
      END IF;
      k := k + 1;
      i := i + 1;
    END LOOP;
    RETURN(X_output);
  END format_string;
 END GMF_ALLOC_PROCESS_PRIVATE;

/
