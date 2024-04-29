--------------------------------------------------------
--  DDL for Package Body OKC_CONDITION_EVAL_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OKC_CONDITION_EVAL_PVT" as
/* $Header: OKCRCEVB.pls 120.3 2005/07/18 09:30:56 pnayani noship $ */

	--l_debug VARCHAR2(1) := 'Y';
	l_debug VARCHAR2(1) := NVL(FND_PROFILE.VALUE('AFLOG_ENABLED'),'N');

 /*----------------------------------------------------------------------------+
 |This package contains APIs for condition evaluation. It handles 4 major tasks|
 |1. Evaluates condition headers and lines for a given action.                 |
 |2.Creates condition occurrence and action attribute values for true          |
 |conditions.                                                                  |
 |3.Identify outcomes for true conditions.                                     |
 |4.Put the outcomes on the outcome queue.                                     |
 +----------------------------------------------------------------------------*/
--
-- Package Variables
--

-- This function takes the action attribute element name
-- and returns the corresponding aae_id

FUNCTION get_attribute_id (
    p_acn_id                IN  okc_actions_b.id%TYPE,
    p_element_name          IN  okc_action_attributes_b.element_name%TYPE
    )
    RETURN NUMBER
    IS
    CURSOR aae_cur IS
    SELECT  id,element_name
    FROM    okc_action_attributes_b
    WHERE   acn_id = p_acn_id;
    aae_rec  aae_cur%ROWTYPE;
    x_aae_id     NUMBER;

   --
   l_proc varchar2(72) := '  okc_condition_eval_pvt.'||'get_attribute_id';
   --

    BEGIN

    IF (l_debug = 'Y') THEN
       okc_debug.Set_Indentation(l_proc);
       okc_debug.log('10: Entering ',2);
    END IF;

      FOR aae_rec IN aae_cur LOOP
	IF UPPER(aae_rec.element_name) = UPPER(p_element_name) THEN
	   x_aae_id := aae_rec.id;
        END IF;
      END LOOP;

    IF (l_debug = 'Y') THEN
       okc_debug.log('1000: Leaving ',2);
       okc_debug.Reset_Indentation;
    END IF;


      RETURN(x_aae_id);
    END get_attribute_id;


-- R12 changed function to get counter reading instead of counter_grp_log_id
--This function accepts cnh_id,acn_id and returns counter_reading
  FUNCTION get_last_counter_reading(
    p_cnh_id IN okc_condition_headers_b.id%TYPE
   ,p_acn_id IN okc_actions_b.id%TYPE)
  RETURN NUMBER
  IS
  l_counter_reading   NUMBER ;
  l_aae_id    NUMBER;
  CURSOR aav_cur(X IN NUMBER)
  IS
  SELECT  aav.value
  FROM    okc_action_att_vals aav
	 ,okc_condition_occurs coe
  WHERE  coe.id = aav.coe_id
  AND    coe.cnh_id = p_cnh_id
  AND    aav.aae_id = X
  ORDER  BY coe.datetime desc;
  aav_rec aav_cur%ROWTYPE;

   --
   l_proc varchar2(72) := '  okc_condition_eval_pvt.'||'get_counter_reading';
   --

  BEGIN

    IF (l_debug = 'Y') THEN
       okc_debug.Set_Indentation(l_proc);
       okc_debug.log('10: Entering ',2);
    END IF;

  l_aae_id := get_attribute_id(p_acn_id,'COUNTER_READING');
         IF aav_cur%ISOPEN THEN
    	   CLOSE aav_cur;
         END IF;
  OPEN aav_cur(l_aae_id);
  FETCH aav_cur INTO aav_rec;
    IF aav_cur%NOTFOUND THEN

    IF (l_debug = 'Y') THEN
       okc_debug.log('100: Leaving ',2);
       okc_debug.Reset_Indentation;
    END IF;


      RETURN(l_counter_reading);
    ELSE
      l_counter_reading := aav_rec.value;

    IF (l_debug = 'Y') THEN
       okc_debug.log('200: Leaving ',2);
       okc_debug.Reset_Indentation;
    END IF;


      RETURN(l_counter_reading);
    END IF;
  CLOSE aav_cur;

    IF (l_debug = 'Y') THEN
       okc_debug.log('300: Leaving ',2);
       okc_debug.Reset_Indentation;
    END IF;


      RETURN(l_counter_reading);
  END;

-- This function accepts the counter_id and
-- returns the latest reading of the counter
   FUNCTION get_current_counter_val(
     p_counter_id          IN NUMBER)
   RETURN NUMBER
   IS
   l_counter_value  CSI_COUNTER_READINGS.counter_reading%TYPE ;
   CURSOR cv_cur
   IS
   select net_reading counter_reading
   from csi_counter_readings
   where counter_id = p_counter_id
   and nvl(disabled_flag,'N') = 'N'
   order by value_timestamp desc;
   /*SELECT cv.counter_reading
   FROM   okx_counter_values_v cv,
	  okx_counters_v c
   WHERE  cv.counter_id = c.counter_id
   AND    cv.counter_grp_log_id = p_counter_grp_log_id
   AND    (cv.counter_id = p_counter_id OR
	   c.created_from_counter_tmpl_id = p_counter_id);*/
   cv_rec  cv_cur%ROWTYPE;

   --
   l_proc varchar2(72) := '  okc_condition_eval_pvt.'||'get_current_counter_val';
   --

   BEGIN

    IF (l_debug = 'Y') THEN
       okc_debug.Set_Indentation(l_proc);
       okc_debug.log('10: Entering ',2);
    END IF;

         IF cv_cur%ISOPEN THEN
    	   CLOSE cv_cur;
         END IF;
   OPEN cv_cur;
   FETCH cv_cur INTO cv_rec;
     IF cv_cur%NOTFOUND THEN

    IF (l_debug = 'Y') THEN
       okc_debug.log('1000: Leaving ',2);
       okc_debug.Reset_Indentation;
    END IF;


       RETURN(l_counter_value);
     ELSE
       l_counter_value := cv_rec.counter_reading;

    IF (l_debug = 'Y') THEN
       okc_debug.log('2000: Leaving ',2);
       okc_debug.Reset_Indentation;
    END IF;


       RETURN(l_counter_value);
     END IF;
   CLOSE cv_cur;

    IF (l_debug = 'Y') THEN
       okc_debug.log('3000: Leaving ',2);
       okc_debug.Reset_Indentation;
    END IF;


       RETURN(l_counter_value);

   END;


-- This function takes the action attribute element name loops thro
-- message table and gives out the corresponding element value

FUNCTION get_attribute_value (
    p_element_name          IN  okc_action_attributes_b.element_name%TYPE,
    p_msg_tab               IN  okc_aq_pvt.msg_tab_typ
    )
    RETURN VARCHAR2
    IS
    x_element_value     VARCHAR2(32000);

   --
   l_proc varchar2(72) := '  okc_condition_eval_pvt.'||'get_attribute_value';
   --

    BEGIN

    IF (l_debug = 'Y') THEN
       okc_debug.Set_Indentation(l_proc);
       okc_debug.log('10: Entering ',2);
    END IF;

      IF p_element_name IS NOT NULL THEN
        FOR i IN 1..p_msg_tab.count LOOP
	  IF UPPER(p_element_name) = UPPER(p_msg_tab(i).element_name) THEN
	    x_element_value := p_msg_tab(i).element_value;
          END IF;
        END LOOP;
      END IF;

    IF (l_debug = 'Y') THEN
       okc_debug.log('1000: Leaving ',2);
       okc_debug.Reset_Indentation;
    END IF;


        RETURN(x_element_value);

END get_attribute_value;

-- This function takes the action id and msg table
-- and returns attribute value of date datatype which is
-- the date of intrest for that action

FUNCTION get_datetime (
    p_acn_id                IN  okc_actions_b.id%TYPE,
    p_msg_tab               IN  okc_aq_pvt.msg_tab_typ
    )
    RETURN DATE
    IS
    CURSOR aae_cur IS
    SELECT element_name,format_mask
    FROM   okc_action_attributes_b
    WHERE  acn_id = p_acn_id
    AND    data_type = 'DATE'
    AND    date_of_interest_yn = 'Y'
    AND    rownum = 1;
    aae_rec  aae_cur%ROWTYPE;
    x_datetime   DATE;
    x_char_datetime   VARCHAR2(20);
    -- The following format was introduced by msengupt
    l_decode_format_mask VARCHAR2(20) := 'DD-MON-YY';

   --
   l_proc varchar2(72) := '  okc_condition_eval_pvt.'||'get_datetime';
   --

    BEGIN

    IF (l_debug = 'Y') THEN
       okc_debug.Set_Indentation(l_proc);
       okc_debug.log('10: Entering ',2);
    END IF;

      OPEN aae_cur;
      FETCH aae_cur INTO aae_rec;
	IF aae_cur%NOTFOUND THEN
	  x_datetime := SYSDATE;
        ELSE
	  x_char_datetime := get_attribute_value(aae_rec.element_name,
					    p_msg_tab);
          IF aae_rec.format_mask IS NULL THEN
            x_datetime := to_date(x_char_datetime, l_decode_format_mask);
	  ELSE
	    x_datetime := to_date(x_char_datetime,aae_rec.format_mask);
	  END IF;
        END IF;
      CLOSE aae_cur;

    IF (l_debug = 'Y') THEN
       okc_debug.log('1000: Leaving ',2);
       okc_debug.Reset_Indentation;
    END IF;


      RETURN(x_datetime);
    END;

-- Builds function expression with parameters and parameter
-- values and returns the executable function for FEX in condition lines
 FUNCTION get_function_value (
   p_cnl_id                 IN  okc_condition_lines_b.id%TYPE,
   p_pdf_id                 IN  okc_process_defs_b.id%TYPE,
   p_msg_tab                IN  okc_aq_pvt.msg_tab_typ
   )
   RETURN VARCHAR2
   IS
   x_function_value    VARCHAR2(1);
   v_retval            VARCHAR2(1);
   l_string            VARCHAR2(32000);
   func_string            VARCHAR2(32000);
   CURSOR fep_cur IS
   select id
   from   okc_function_expr_params
   where cnl_id = p_cnl_id;
   fep_rec      fep_cur%ROWTYPE;
   CURSOR cnl_cur IS
   select pdf.package_name||'.'||pdf.procedure_name function_name
   from   okc_condition_lines_b cnl,
	  okc_process_defs_b pdf
   where  cnl.pdf_id = pdf.id
   and    cnl.id     = p_cnl_id
   and    UPPER(pdf.usage) = 'FUNCTION';
   cnl_rec     cnl_cur%ROWTYPE;
   CURSOR pdf_cur IS
   SELECT pdf.package_name||'.'||pdf.procedure_name function_name,
	  pdp.name parameter_name,
	  aae.element_name element_name,
	  pdp.default_value default_value,
	  decode(pdp.data_type,'CHAR','''',
	         'DATE','''',NULL) prefix_param,
	  fep.value fep_value
   FROM   okc_process_defs_b pdf,
	  okc_process_def_parameters_v pdp,
	  okc_function_expr_params fep,
	  okc_action_attributes_b aae
   WHERE  pdf.id     = p_pdf_id
   AND    pdp.pdf_id = pdf.id
   AND    pdp.id     = fep.pdp_id
   AND    fep.cnl_id = p_cnl_id
   AND    fep.aae_id = aae.id(+)
   AND    UPPER(pdf.usage)  = 'FUNCTION';
   pdf_rec       pdf_cur%ROWTYPE;
    bind_ctr      NUMBER := 0;
    TYPE bind_var_rec IS RECORD (ctr NUMBER,value VARCHAR2(100));
    TYPE bind_var_table IS TABLE OF bind_var_rec;
    bind_var_tab  bind_var_table:= bind_var_table();
    bind_cur   integer;
    i integer;
   BEGIN
	 ----------------------
         IF fep_cur%ISOPEN THEN
    	   CLOSE fep_cur;
         END IF;
	 ----------------------
     OPEN fep_cur;
     FETCH fep_cur INTO fep_rec;
       IF fep_cur%notfound THEN
       ------------------------
         IF cnl_cur%ISOPEN THEN
    	   CLOSE cnl_cur;
         END IF;
       ------------------------
	 OPEN cnl_cur;
	 FETCH cnl_cur INTO cnl_rec;
	   IF cnl_cur%FOUND THEN
	     l_string := cnl_rec.function_name;
           ELSE
	     x_function_value := 'F';

    IF (l_debug = 'Y') THEN
       okc_debug.log('1000: Leaving ',2);
       okc_debug.Reset_Indentation;
    END IF;


             RETURN(x_function_value);
           END IF;
         CLOSE cnl_cur;
       ELSE
         IF pdf_cur%ISOPEN THEN
    	   CLOSE pdf_cur;
         END IF;
         OPEN pdf_cur;
         FETCH pdf_cur INTO pdf_rec;
           IF pdf_cur%NOTFOUND THEN
	     x_function_value := 'F';

    IF (l_debug = 'Y') THEN
       okc_debug.log('2000: Leaving ',2);
       okc_debug.Reset_Indentation;
    END IF;


             RETURN(x_function_value);
           ELSE
	   ---** Bug#2934909 converting execute immediate into dbms_sql to bind input variables
	   -- ** as per new coding standards to avoid data security problems.
        		bind_var_tab.extend;
        		bind_ctr := bind_ctr+1;
             	l_string := pdf_rec.function_name || '('||pdf_rec.parameter_name||
						 '=> '||':'||bind_ctr;
        		bind_var_tab(bind_ctr).ctr := bind_ctr;
        		bind_var_tab(bind_ctr).value := replace(NVL(pdf_rec.fep_value,
		           	NVL(get_attribute_value( pdf_rec.element_name, p_msg_tab),
		            NVL(pdf_rec.default_value,' '))),'''','''''');
               LOOP
                 FETCH pdf_cur INTO pdf_rec;
	         IF pdf_cur%NOTFOUND THEN
	           EXIT;
                 ELSE
        		bind_var_tab.extend;
        		bind_ctr := bind_ctr+1;
	            l_string := l_string||','|| pdf_rec.parameter_name||
						 '=> '||':'||bind_ctr;
        		bind_var_tab(bind_ctr).ctr := bind_ctr;
        		bind_var_tab(bind_ctr).value := replace(NVL(pdf_rec.fep_value,
		           	NVL(get_attribute_value( pdf_rec.element_name, p_msg_tab),
		            NVL(pdf_rec.default_value,' '))),'''','''''');
                 END IF;
               END LOOP;
           l_string := ':retval := '||l_string||');';
            END IF;
          CLOSE pdf_cur;
       END IF;
     -- return T or F
	 IF l_string IS NOT NULL THEN
	    func_string := 'begin '||l_string||'  end;';
	   ---** Bug#2934909 converting execute immediate into dbms_sql to bind input variables
	   -- ** as per new coding standards to avoid data security problems.
        BEGIN
          	bind_cur := dbms_sql.open_cursor;
     		dbms_sql.parse(bind_cur, func_string, dbms_sql.native);
          	dbms_sql.bind_variable(bind_cur,'retval','A');
        		FOR  i IN 1.. bind_var_tab.COUNT LOOP
            		dbms_sql.bind_variable(bind_cur,to_char(bind_var_tab(i).ctr),bind_var_tab(i).value);
        		END LOOP;
            x_function_value := dbms_sql.execute(bind_cur);
			dbms_sql.variable_value(bind_cur,'retval',v_retval);
   			dbms_sql.close_cursor(bind_cur);
        END;
	   ---** Bug#2934909 END **----------
	   --EXECUTE IMMEDIATE func_string into x_function_value;

    IF (l_debug = 'Y') THEN
       okc_debug.log('3000: Leaving ',2);
       okc_debug.Reset_Indentation;
    END IF;

	   RETURN(v_retval);
    END IF;

    EXCEPTION
    WHEN OTHERS THEN
    -- close the cursor
     dbms_sql.close_cursor(bind_cur);
	   RETURN(v_retval);
       RAISE;

   END get_function_value;

 /* Master counters are not supported
    FUNCTION get_master_counter_value (
    p_counter_master_id            IN  NUMBER
    )
    RETURN VARCHAR2
    IS
    CURSOR counter_master_cur IS
    SELECT c.counter_id counter_id,
	   cv.counter_reading counter_reading
    FROM   okx_counter_values_v cv, okx_counters_v c
    WHERE  cv.counter_id = c.counter_id
    AND    c.ctr_val_max_seq_no = cv.seq_no
    AND    c.created_from_counter_tmpl_id = p_counter_master_id;
    x_counter_value      VARCHAR2(2000) ;
    counter_master_rec          counter_master_cur%ROWTYPE;

   --
   l_proc varchar2(72) := '  okc_condition_eval_pvt.'||'get_master_counter_value';
   --

  BEGIN

    IF (l_debug = 'Y') THEN
       okc_debug.Set_Indentation(l_proc);
       okc_debug.log('10: Entering ',2);
    END IF;

      FOR counter_master_rec IN counter_master_cur LOOP
	IF counter_master_cur%NOTFOUND THEN

    IF (l_debug = 'Y') THEN
       okc_debug.log('1000: Leaving ',2);
       okc_debug.Reset_Indentation;
    END IF;


	  RETURN(x_counter_value);
        ELSE
	  x_counter_value := counter_master_rec.counter_reading;
        END IF;
      END LOOP;

    IF (l_debug = 'Y') THEN
       okc_debug.log('2000: Leaving ',2);
       okc_debug.Reset_Indentation;
    END IF;


	RETURN (x_counter_value);
  END get_master_counter_value;*/
 -- this function returns latest counter reading.
  FUNCTION get_counter_value (
    p_counter_id            IN  NUMBER
    )
    RETURN VARCHAR2
    IS
    CURSOR counter_cur IS
   select net_reading counter_reading
   from csi_counter_readings
   where counter_id = p_counter_id
   and nvl(disabled_flag,'N') = 'N'
   order by value_timestamp desc;
    /*SELECT c.counter_id counter_id,
	   cv.counter_reading counter_reading
    FROM   okx_counter_values_v cv, okx_counters_v c
    WHERE  c.counter_id = cv.counter_id
    AND    c.ctr_val_max_seq_no = cv.seq_no
    AND    c.counter_id = p_counter_id;*/
    x_counter_value      VARCHAR2(2000) ;
    counter_rec          counter_cur%ROWTYPE;

   --
   l_proc varchar2(72) := '  okc_condition_eval_pvt.'||'get_counter_value';
   --

  BEGIN

    IF (l_debug = 'Y') THEN
       okc_debug.Set_Indentation(l_proc);
       okc_debug.log('10: Entering ',2);
    END IF;

      --FOR counter_rec IN counter_cur LOOP
   OPEN counter_cur;
   FETCH counter_cur INTO counter_rec;
	IF counter_cur%NOTFOUND THEN

            IF (l_debug = 'Y') THEN
                okc_debug.log('1000: Leaving ',2);
                okc_debug.Reset_Indentation;
            END IF;

	        RETURN(x_counter_value);
    ELSE
	  x_counter_value := counter_rec.counter_reading;
    END IF;
   CLOSE counter_cur;

    IF (l_debug = 'Y') THEN
       okc_debug.log('2000: Leaving ',2);
       okc_debug.Reset_Indentation;
    END IF;


	RETURN (x_counter_value);
  END get_counter_value;


-- This function evaluates the counter condition line and returns
-- a string of 'T = F/T' to be evaluated by condition lines procedure
  FUNCTION evaluate_counter_condition (
    p_cnl_id IN okc_condition_lines_b.id%TYPE
   ,p_previous_counter_value  IN  csi_counter_readings.counter_reading%TYPE
   ,p_current_counter_value  IN  csi_counter_readings.counter_reading%TYPE
   )
  RETURN VARCHAR2
  IS
  CURSOR cnl_cur
  IS
  SELECT left_counter_id
	 ,right_operand
	 ,tolerance
	 ,start_at
  FROM   okc_condition_lines_b cnl
  WHERE  id = p_cnl_id;
  cnl_rec  cnl_cur%ROWTYPE;
  l_value     NUMBER;
  l_string    VARCHAR2(20) := '''F'' = ''T''';


   --
   l_proc varchar2(72) := '  okc_condition_eval_pvt.'||'evaluate_counter_condition';
   --

  BEGIN

    IF (l_debug = 'Y') THEN
       okc_debug.Set_Indentation(l_proc);
       okc_debug.log('10: Entering ',2);
    END IF;

         IF cnl_cur%ISOPEN THEN
    	   CLOSE cnl_cur;
         END IF;
    OPEN cnl_cur;
    FETCH cnl_cur INTO cnl_rec;
      IF cnl_cur%FOUND THEN
        -- commented as master counters are not supported
        /*ELSIF cnl_rec.left_ctr_master_id IS NOT NULL THEN
          l_curr_val := get_master_counter_value(cnl_rec.left_ctr_master_id); */
            l_value := (((p_current_counter_value - NVL(p_previous_counter_value,
 				       cnl_rec.start_at))
		      - NVL(cnl_rec.tolerance,0)) / cnl_rec.right_operand);
        IF l_value > 1 THEN
	        l_string := '''T'' = ''T''';
        ELSE
	        l_string := '''F'' = ''T''';
        END IF;
      END IF;
    CLOSE cnl_cur;

    IF (l_debug = 'Y') THEN
       okc_debug.log('1000: Leaving ',2);
       okc_debug.Reset_Indentation;
    END IF;


    RETURN(l_string);
  END evaluate_counter_condition;

-- This function checks if the condition has been already evaluated
FUNCTION evaluated_once (p_cnh_id  IN NUMBER)
RETURN BOOLEAN IS

CURSOR coe_cur IS
SELECT 'X'
FROM   okc_condition_occurs coe
WHERE  coe.cnh_id = p_cnh_id;
coe_rec coe_cur%ROWTYPE;



   --
   l_proc varchar2(72) := '  okc_condition_eval_pvt.'||'evaluated_once';
   --

BEGIN

    IF (l_debug = 'Y') THEN
       okc_debug.Set_Indentation(l_proc);
       okc_debug.log('10: Entering ',2);
    END IF;


         IF coe_cur%ISOPEN THEN
    	   CLOSE coe_cur;
         END IF;
  OPEN coe_cur;
  FETCH coe_cur INTO coe_rec;
    IF coe_cur%FOUND THEN

    IF (l_debug = 'Y') THEN
       okc_debug.log('1000: Leaving ',2);
       okc_debug.Reset_Indentation;
    END IF;


      RETURN(TRUE);
    ELSE

    IF (l_debug = 'Y') THEN
       okc_debug.log('2000: Leaving ',2);
       okc_debug.Reset_Indentation;
    END IF;


      RETURN(FALSE);
    END IF;
  CLOSE coe_cur;

    IF (l_debug = 'Y') THEN
       okc_debug.log('3000: Leaving ',2);
       okc_debug.Reset_Indentation;
    END IF;


    RETURN(FALSE);

END;

 PROCEDURE evaluate_condition_lines(
     p_cnh_id            IN  okc_condition_headers_b.id%TYPE,
     p_msg_tab           IN  okc_aq_pvt.msg_tab_typ,
     p_init_msg_list     IN VARCHAR2 ,
     x_return_status     OUT NOCOPY VARCHAR2,
     x_msg_count         OUT NOCOPY NUMBER,
     x_msg_data          OUT NOCOPY VARCHAR2,
     x_status            OUT NOCOPY VARCHAR2
     )
    IS
    CURSOR cnl_cur IS
    SELECT cnl.id id,
	   cnl.pdf_id pdf_id,
	   cnl.aae_id aae_id,
	   aae.element_name element_name,
	   decode(aae.data_type,'CHAR','''',
	   'DATE','trunc(to_date('||'''',NULL) prefix_param_start,
	   decode(aae.data_type,'CHAR','''',
	   'DATE',''''||'))',NULL) prefix_param_end,
	   cnl.left_ctr_master_id left_ctr_master_id,
	   cnl.right_ctr_master_id right_ctr_master_id,
	   cnl.left_counter_id left_counter_id,
	   cnl.right_counter_id right_counter_id,
	   cnl.cnl_type cnl_type,
	   cnl.left_parenthesis left_parenthesis,
	   cnl.relational_operator relational_operator,
	   cnl.right_parenthesis right_parenthesis,
	   cnl.logical_operator logical_operator,
	   cnl.right_operand right_operand,
	   cnl.tolerance tolerance,
	   cnl.start_at start_at,
	   cnh.counter_group_id counter_group_id,
	   cnh.acn_id acn_id,
	   cnh.one_time_yn one_time_yn
    FROM   okc_condition_lines_b cnl,
	   okc_action_attributes_b aae,
	   okc_condition_headers_b cnh
    WHERE  cnl.cnh_id = p_cnh_id
    AND    cnl.cnh_id = cnh.id
    AND    cnl.aae_id = aae.id(+)
    ORDER  BY cnl.sortseq;
    cnl_rec     cnl_cur%ROWTYPE;

    l_api_name     CONSTANT VARCHAR2(30) := 'EVALUATE_CONDITION_LINES';
    l_string       VARCHAR2(32000);
    l_count        NUMBER := 1;
    l_return_status VARCHAR2(1);
    v_result       VARCHAR2(10);
    l_counter_group_log_id      NUMBER;
    l_previous_counter_val              NUMBER;
    v_quote       VARCHAR2(6) := '''';
    left_value    VARCHAR2(150);
    right_value    VARCHAR2(150);
    rel_op        VARCHAR2(50);
    bind_ctr      NUMBER := 0;
    TYPE bind_var_rec IS RECORD (ctr NUMBER,value VARCHAR2(100));
    TYPE bind_var_table IS TABLE OF bind_var_rec;
    bind_var_tab  bind_var_table := bind_var_table();
    b   integer;
    i integer;
    l_processed number;

   --
   l_proc varchar2(72) := '  okc_condition_eval_pvt.'||'evaluate_condition_lines';
   --

    BEGIN

    IF (l_debug = 'Y') THEN
       okc_debug.Set_Indentation(l_proc);
       okc_debug.log('10: Entering ',2);
    END IF;

      x_return_status := OKC_API.G_RET_STS_SUCCESS;
      x_status := 'TRUE';
         IF cnl_cur%ISOPEN THEN
    	   CLOSE cnl_cur;
         END IF;
      OPEN cnl_cur;
	LOOP
	  FETCH cnl_cur INTO cnl_rec;
	    IF cnl_cur%NOTFOUND THEN
	      EXIT;
            ELSE
	      IF cnl_rec.cnl_type = 'GEX' THEN
		 left_value := nvl(get_attribute_value(cnl_rec.element_name,
							p_msg_tab),'OKCNULL');
		  right_value := NVL(cnl_rec.right_operand,'OKCNULL');
		  IF UPPER(cnl_rec.relational_operator) = 'IS NULL' THEN
		    rel_op := '=';
	          ELSIF  UPPER(cnl_rec.relational_operator) = 'IS NOT NULL' THEN
		    rel_op := '<>';
                  ELSE  rel_op := cnl_rec.relational_operator;
		  END IF;
	   ---** Bug#2934909 converting execute immediate into dbms_sql to bind input variables
	   -- ** as per new coding standards to avoid data security problems.
        bind_var_tab.extend;
        bind_ctr := bind_ctr+1;
		l_string := l_string || cnl_rec.left_parenthesis;
        l_string :=l_string||':'||bind_ctr||rel_op;
        bind_var_tab(bind_ctr).ctr := bind_ctr;
        bind_var_tab(bind_ctr).value := replace(left_value,'''','''''');
        bind_var_tab.extend;
        bind_ctr := bind_ctr+1;
        l_string:=l_string||':'||bind_ctr||cnl_rec.right_parenthesis||NVL( cnl_rec.logical_operator,' ');
        bind_var_tab(bind_ctr).ctr := bind_ctr;
        bind_var_tab(bind_ctr).value := replace(right_value,'''','''''');

	      ELSIF cnl_rec.cnl_type = 'CEX' THEN
	      -------------------------------------------------------
	      -- commented out because template counter groups and counters
	      -- are not to be validated for this release
	      -------------------------------------------------------
                 /*IF cnl_rec.left_ctr_master_id IS NOT NULL THEN
		   IF cnl_rec.relational_operator = 'EVERY' THEN
		     l_counter_group_log_id := get_counter_group_log_id(
						 p_cnh_id,
						 cnl_rec.acn_id);
		     l_previous_counter_val := get_previous_counter_val(
						 l_counter_group_log_id,
						 cnl_rec.left_ctr_master_id);
		     l_string :=evaluate_counter_condition(
				  cnl_rec.id ,
				  l_previous_counter_val);
                   ELSE
		   l_string := l_string ||
		  	       cnl_rec.left_parenthesis ||
			       get_master_counter_value(
				 cnl_rec.left_ctr_master_id) ||
			       cnl_rec.relational_operator ||
			       NVL(cnl_rec.right_operand,
				   get_master_counter_value(
				     cnl_rec.right_ctr_master_id))||
			       cnl_rec.right_parenthesis ||
			       NVL ( cnl_rec.logical_operator,' ');
                   END IF;*/
		----------------------------------------------------
         IF cnl_rec.left_counter_id IS NOT NULL THEN
		   IF cnl_rec.relational_operator = 'EVERY' THEN
           -- In R12 counter_group_log_id is discontinued added new method call get_last_counter_reading
		     l_previous_counter_val:= get_last_counter_reading(
						 p_cnh_id,
						 cnl_rec.acn_id);
	   ---** Bug#2934909 converting execute immediate into dbms_sql to bind input variables
	   -- ** as per new coding standards to avoid data security problems.
		     l_string :=evaluate_counter_condition(
				  cnl_rec.id ,
				  l_previous_counter_val,
				  get_attribute_value('COUNTER_READING',p_msg_tab));
           ELSE
        			bind_var_tab.extend;
        			bind_ctr := bind_ctr+1;
					l_string := l_string || cnl_rec.left_parenthesis;
       			    l_string :=l_string||':'||bind_ctr||cnl_rec.relational_operator;
        			bind_var_tab(bind_ctr).ctr := bind_ctr;
        			bind_var_tab(bind_ctr).value := replace(get_attribute_value('COUNTER_READING',p_msg_tab)
															,'''','''''');
        			bind_var_tab.extend;
        			bind_ctr := bind_ctr+1;
        			l_string :=l_string||':'||bind_ctr||cnl_rec.right_parenthesis
								|| NVL ( cnl_rec.logical_operator,' ');
        			bind_var_tab(bind_ctr).ctr := bind_ctr;
        			bind_var_tab(bind_ctr).value := replace(NVL(cnl_rec.right_operand,                    											get_counter_value( cnl_rec.right_counter_id)) ,'''','''''');

           END IF;
         END IF;
-------------------------------------------------------------------------------------------
       ELSIF cnl_rec.cnl_type = 'FEX' THEN
		l_string := l_string ||
			    cnl_rec.left_parenthesis ||v_quote||
			    get_function_value (cnl_rec.id,
					        cnl_rec.pdf_id,
						p_msg_tab) ||
			    v_quote||' ='||v_quote||'T'||v_quote||
			    cnl_rec.right_parenthesis ||
			    NVL ( cnl_rec.logical_operator,' ');
              END IF;
            END IF;
	END LOOP;
      CLOSE cnl_cur;
	IF l_string is not null THEN
	l_string := 'BEGIN select ''X'' INTO :v_result from dual where '||l_string||'; END;';
	   ---** Bug#2934909 converting execute immediate into dbms_sql to bind input variables
	   -- ** as per new coding standards to avoid data security problems.
		BEGIN
    		 b := dbms_sql.open_cursor;
     		dbms_sql.parse(b, l_string, dbms_sql.native);
        	dbms_sql.bind_variable(b,':v_result',v_result,20);
        		FOR  i IN 1.. bind_var_tab.COUNT LOOP
            		dbms_sql.bind_variable(b,to_char(bind_var_tab(i).ctr),bind_var_tab(i).value);
        		END LOOP;
     				l_processed := dbms_sql.execute(b);
                    dbms_sql.variable_value(b,':v_result',v_result);

     	    dbms_sql.close_cursor(b);
              		--EXECUTE IMMEDIATE l_string INTO v_result;
	        		IF v_result = 'X' THEN
	          			x_status := 'TRUE';
                	ELSE x_status := 'FALSE';
	        		END IF;
        EXCEPTION
			WHEN NO_DATA_FOUND THEN
               -- bug#3192369
               dbms_sql.close_cursor(b);
			    x_status := 'FALSE';
	   	    WHEN others THEN
                 -- bug#3188367
                 dbms_sql.close_cursor(b);

				x_status := 'FALSE';
        END;
	   ---** Bug#2934909 converting execute immediate into dbms_sql ** END ** ----
	END IF;
		x_return_status := OKC_API.G_RET_STS_SUCCESS;

  	IF (l_debug = 'Y') THEN
     okc_debug.log('1000: Leaving ',2);
     okc_debug.Reset_Indentation;
  	END IF;

    EXCEPTION
      WHEN OTHERS THEN
	x_return_status := OKC_API.G_RET_STS_UNEXP_ERROR;

        IF (l_debug = 'Y') THEN
           okc_debug.log('2000: Leaving ',2);
           okc_debug.Reset_Indentation;
        END IF;

		RAISE;

    END evaluate_condition_lines;



  PROCEDURE build_outcome(
     p_cnh_tab           IN  okc_condition_eval_pvt.id_tab_type,
     p_msg_tab           IN  okc_aq_pvt.msg_tab_typ,
     p_init_msg_list     IN VARCHAR2 ,
     x_return_status     OUT NOCOPY VARCHAR2,
     x_msg_count         OUT NOCOPY NUMBER,
     x_msg_data          OUT NOCOPY VARCHAR2,
     x_sync_outcome_tab  OUT NOCOPY okc_condition_eval_pvt.outcome_tab_type
     )
     IS
     CURSOR oce_cur (x IN NUMBER) IS
     SELECT  oce.id oce_id,
             decode(pdf.pdf_type,'ALERT',pdf.message_name,
		    'SCRIPT',pdf.script_name,
		    'PPS',pdf.package_name||'.'||pdf.procedure_name,
		    'WPS',pdf.wf_name||'.'||pdf.wf_process_name,NULL) outcome,
	     pdf.pdf_type pdf_type,
	     pdf.name name,
	     pdp.id pdp_id,
	     pdp.name parameter,
	     decode(pdp.data_type,'CHAR','''',
		   'DATE','''',NULL) prefix_param,
	     nvl(pdp.default_value,
		 decode(pdp.data_type,
		        'CHAR'  ,'OKC_API.G_MISS_CHAR',
		        'NUMBER','OKC_API.G_MISS_NUM',
			'DATE'  ,'OKC_API.G_MISS_DATE',
			'OKC_API.G_MISS_CHAR')) default_value,
	     pdp.data_type datatype,
	     pdp.required_yn required_yn
     FROM    okc_outcomes_b oce,
	     okc_process_defs_v pdf,
	     okc_process_def_parameters_v pdp
     WHERE   oce.cnh_id =    p_cnh_tab(x).v_id
     AND     oce.pdf_id =    pdf.id
     AND     pdf.id     =    pdp.pdf_id(+)
     AND     UPPER(pdf.usage)  =    'OUTCOME'
     AND     UPPER(oce.enabled_yn) = 'Y'
     ORDER   BY outcome,parameter;
     oce_rec            oce_cur%ROWTYPE;

     l_oce_id     okc_outcomes_b.id%TYPE;
     l_pdp_id     okc_process_def_parms_b.id%TYPE;
     l_value      okc_outcome_arguments.value%TYPE;
     l_element_name  okc_action_attributes_b.element_name%TYPE;
     CURSOR oat_cur(l_oce_id IN NUMBER,
		    l_pdp_id IN NUMBER) IS
     SELECT oat.value value,aae.element_name element_name
     FROM   okc_outcome_arguments oat,
	    okc_action_attributes_b aae
     WHERE  oat.oce_id = l_oce_id
     AND    oat.pdp_id = l_pdp_id
     AND    oat.aae_id = aae.id(+);
     oat_rec  oat_cur%ROWTYPE;

     sync_index           NUMBER :=1;
     async_index          NUMBER :=1;
     l_msg_tab            okc_aq_pvt.msg_tab_typ;
     l_corrid_rec         okc_aq_pvt.corrid_rec_typ;
     p_cnh_id             okc_condition_headers_b.id%TYPE;
     l_string             VARCHAR2(32000);
     l_attr_value      okc_outcome_arguments.value%TYPE; --Bug 3731760
     v_oce_id             NUMBER :=0;
     sync_pdf_type        okc_process_defs_b.pdf_type%TYPE;
     async_pdf_type       okc_process_defs_b.pdf_type%TYPE;
    l_api_name            CONSTANT VARCHAR2(30) := 'BUILD_OUTCOME';
    l_msg_data            varchar2(1000);
    l_msg_count           number;
    l_return_status       varchar2(1);
    param_exist           number;
    no_param              number;

   --
   l_proc varchar2(72) := '  okc_condition_eval_pvt.'||'build_outcome';
   --

     BEGIN

    IF (l_debug = 'Y') THEN
       okc_debug.Set_Indentation(l_proc);
       okc_debug.log('10: Entering build outcome ',2);
    END IF;

      x_return_status := OKC_API.G_RET_STS_SUCCESS;
     x_sync_outcome_tab   := okc_condition_eval_pvt.outcome_tab_type();
     l_msg_tab    := okc_aq_pvt.msg_tab_typ();
     l_string := NULL;
       FOR i IN 1..p_cnh_tab.COUNT LOOP
         IF oce_cur%ISOPEN THEN
    	   CLOSE oce_cur;
         END IF;
         OPEN oce_cur(i) ;
	   LOOP
             FETCH oce_cur INTO oce_rec;
	     -- if last record then check if there is
	     -- outcome built by previous loop
	     -- add the outcome to sync_outcome_tab

                 IF oce_cur%NOTFOUND THEN
		      IF l_string IS NOT NULL THEN
			param_exist := instr(l_string,'=>',1,1);
			IF param_exist <> 0 THEN
			  l_string := l_string||');';
                        END IF;

                        x_sync_outcome_tab.extend;
                        x_sync_outcome_tab(sync_index).type := sync_pdf_type;
                        x_sync_outcome_tab(sync_index).name := l_string;
                        l_string := NULL;
			sync_index := sync_index+1;
                      ELSIF l_msg_tab.COUNT <> 0  AND
			    l_corrid_rec.corrid IS NOT NULL THEN
			-- put l_msg_tab and corrid_rec in the queue
	                okc_aq_pvt.send_message (
			    p_api_version   => 1.0
		           ,x_msg_count     => l_msg_count
		           ,x_msg_data      => l_msg_data
	                   ,x_return_status => l_return_status
	                   ,p_corrid_rec    => l_corrid_rec
	                   ,p_msg_tab       => l_msg_tab
			   ,p_queue_name    => okc_aq_pvt.g_outcome_queue_name);
			-- initialize l_msg_tab
                        l_msg_tab    := okc_aq_pvt.msg_tab_typ();
                      END IF;
                   EXIT;
                 ELSE

		   IF oat_cur%ISOPEN THEN
		     CLOSE oat_cur;
		   END IF;
		   OPEN oat_cur(oce_rec.oce_id,oce_rec.pdp_id) ;
		   FETCH oat_cur INTO oat_rec;
		     IF oat_cur%FOUND THEN
			l_value := oat_rec.value;
		        l_element_name := oat_rec.element_name;
		     ELSE
		        l_value := null;
		        l_element_name := null;
		     END IF;
		   CLOSE oat_cur;

                   -- if new outcome then add old outcome to sync_outcome_tab
		   -- initialize new string and index
		   IF v_oce_id <> oce_rec.oce_id THEN
		      IF l_string IS NOT NULL THEN
                        l_string := l_string||');';
                        x_sync_outcome_tab.extend;
                        x_sync_outcome_tab(sync_index).type := sync_pdf_type;
                        x_sync_outcome_tab(sync_index).name := l_string;
                        l_string := NULL;
			sync_index := sync_index+1;
                      ELSIF l_msg_tab.COUNT <> 0 AND
			    l_corrid_rec.corrid IS NOT NULL THEN
			-- put l_msg_tab and corrid_rec in the queue
	                okc_aq_pvt.send_message (
			  p_api_version     => 1.0
			  , x_msg_count     => l_msg_count
			  , x_msg_data      => l_msg_data
			  , x_return_status => l_return_status
			  , p_corrid_rec    => l_corrid_rec
			  , p_msg_tab       => l_msg_tab
			  , p_queue_name    => okc_aq_pvt.g_outcome_queue_name);
                      END IF;
			 -- store new outcome id in a local variable
			 -- build the new outcome string with first parameter
			 IF upper(oce_rec.pdf_type) IN ('ALERT','SCRIPT') THEN
			   IF NVL(oce_rec.parameter,'NO_VAL') = 'NO_VAL' THEN
			     l_string := oce_rec.outcome||';';
		             v_oce_id := oce_rec.oce_id;
			     sync_pdf_type := oce_rec.pdf_type;
                             x_sync_outcome_tab.extend;
                             x_sync_outcome_tab(sync_index).type:=sync_pdf_type;
                             x_sync_outcome_tab(sync_index).name := l_string;
                             l_string := NULL;
			     sync_index := sync_index+1;
               ELSE
    IF (l_debug = 'Y') THEN
       okc_debug.log('10: outcome: '||oce_rec.pdf_type,2);
    END IF;
			     sync_pdf_type := oce_rec.pdf_type;
	                     l_string := oce_rec.outcome||
			          '( '||oce_rec.parameter||
			          ' => '||
				  oce_rec.prefix_param||
			          NVL(l_value,
			            NVL(get_attribute_value(
					l_element_name,
				        p_msg_tab),
			            oce_rec.default_value))
				  ||oce_rec.prefix_param;
		                 v_oce_id := oce_rec.oce_id;
    IF (l_debug = 'Y') THEN
       okc_debug.log('10: l_string: '||l_string,2);
    END IF;
			     -- if any of the parameter values are missing
			     -- then raise exception
			     no_param := instr(l_string,'OKC_API',1,1);
			       IF no_param <> 0 AND
				  oce_rec.required_yn = 'Y' THEN
				 l_string := null;
			       OKC_API.SET_MESSAGE(
				p_app_name      => g_app_name
			       ,p_msg_name      => 'OKC_NO_PARAMS'
			       ,p_token1        => 'PROCESS'
			       ,p_token1_value  => oce_rec.outcome
			       ,p_token2        => 'PARAM'
			       ,p_token2_value  => oce_rec.parameter
			       );
	                    -- if parameter has no value then skip that outcome
				 WHILE v_oce_id = oce_rec.oce_id LOOP
				     v_oce_id := oce_rec.oce_id;
			             FETCH oce_cur INTO oce_rec;
				     IF oce_cur%NOTFOUND THEN
				       EXIT;
				     END IF;
                                 END LOOP;
                               END IF;
			     sync_pdf_type := oce_rec.pdf_type;
                           END IF;
			ELSE
  -- initialize l_msg_tab,async_index and assign new pdf_type to corrid_rec
                          l_corrid_rec.corrid := oce_rec.pdf_type;
                          l_msg_tab    := okc_aq_pvt.msg_tab_typ();
			  l_msg_tab.extend;
		          async_index := 1;
		          l_msg_tab(async_index).element_name := 'K_ID';
		          l_msg_tab(async_index).element_value:= get_attribute_value('K_ID',p_msg_tab);
			  l_msg_tab.extend;
		          async_index := async_index+1;
		          l_msg_tab(async_index).element_name := 'OCE_ID';
		          l_msg_tab(async_index).element_value:= oce_rec.oce_id;
			  --***************************
			  l_msg_tab.extend;
		          async_index := async_index+1;
		          l_msg_tab(async_index).element_name := 'NAME';
		          l_msg_tab(async_index).element_value
			  := UPPER(oce_rec.outcome);
			  -- if outcome name is missing then raise exception
			  IF l_msg_tab(async_index).element_value IS NULL THEN
			       OKC_API.SET_MESSAGE(
				p_app_name      => g_app_name
			       ,p_msg_name      => 'OKC_INVALID_PROCESS'
			       );
                          END IF;
			  -- append parameters to async_outcome_tab
			    l_msg_tab.extend;
		            async_index := async_index+1;
		            l_msg_tab(async_index).element_name
			    := 'PARAM_NAME';
		            l_msg_tab(async_index).element_value
			    := oce_rec.parameter;
			    l_msg_tab.extend;
		            async_index := async_index+1;
		            l_msg_tab(async_index).element_name
			    := 'PARAM_DATATYPE';
		            l_msg_tab(async_index).element_value
			    := oce_rec.datatype;
			    l_msg_tab.extend;
		            async_index := async_index+1;
		            l_msg_tab(async_index).element_name
			    := 'PARAM_VALUE';
		            l_msg_tab(async_index).element_value
			    := NVL(l_value,
			         NVL(get_attribute_value(l_element_name,
							 p_msg_tab),
			              oce_rec.default_value));
			  v_oce_id := oce_rec.oce_id;
			END IF;
		   ELSIF
     -- if the outcome is same as old outcome then append parameters to string
		     v_oce_id = oce_rec.oce_id THEN
			 IF oce_rec.pdf_type IN ('ALERT','SCRIPT') THEN

--Bug 3448425
l_attr_value:=NVL(l_value,NVL(get_attribute_value( l_element_name,p_msg_tab),oce_rec.default_value));
    IF (l_debug = 'Y') THEN
       okc_debug.log('10: l_attr_value: '||l_attr_value,2);
    END IF;
		           l_string := l_string||
				       ' , '||
				       oce_rec.parameter||
				       ' => '||
				       oce_rec.prefix_param||
                                        l_attr_value
				        ||oce_rec.prefix_param;
		           v_oce_id := oce_rec.oce_id;
			     -- if any of the parameter values are missing
			     -- then raise exception
			     no_param := instr(l_string,'OKC_API',1,1);

--Bug 3448425    	       IF no_param <> 0 AND
  IF (l_debug = 'Y') THEN
     okc_debug.log('1000: Build Outcome: '||l_attr_value,2);
  END IF;
                               IF l_attr_value like 'OKC_API.G_MISS%' AND
				  oce_rec.required_yn = 'Y' THEN
				 l_string := null;
			         OKC_API.SET_MESSAGE(
				   p_app_name      => g_app_name
			          ,p_msg_name      => 'OKC_NO_PARAMS'
			          ,p_token1        => 'PROCESS'
			          ,p_token1_value  => oce_rec.outcome
			          ,p_token2        => 'PARAM'
			          ,p_token2_value  => oce_rec.parameter
			          );
			       -- if parameter has no value then skip that
			       -- outcome
				 WHILE v_oce_id = oce_rec.oce_id LOOP
				     v_oce_id := oce_rec.oce_id;
			             FETCH oce_cur INTO oce_rec;
				     IF oce_cur%NOTFOUND THEN
				       EXIT;
				     END IF;
                                 END LOOP;
                               END IF;
			   sync_pdf_type := oce_rec.pdf_type;
                        ELSE
			  -- append parameters to async_outcome_tab
			    l_msg_tab.extend;
		            async_index := async_index+1;
		            l_msg_tab(async_index).element_name
			    := 'PARAM_NAME';
		            l_msg_tab(async_index).element_value
			    := oce_rec.parameter;
			    l_msg_tab.extend;
		            async_index := async_index+1;
		            l_msg_tab(async_index).element_name
			    := 'PARAM_DATATYPE';
		            l_msg_tab(async_index).element_value
			    := oce_rec.datatype;
			    l_msg_tab.extend;
		            async_index := async_index+1;
		            l_msg_tab(async_index).element_name
			    := 'PARAM_VALUE';
		            l_msg_tab(async_index).element_value
			    := NVL(l_value,
			         NVL(get_attribute_value(l_element_name,
							 p_msg_tab),
			              oce_rec.default_value));
     -- if any of the parameter values are missing then write message to
     -- okc_aqerrors table and stop further processing of that outcome
			    IF l_msg_tab(async_index).element_value IN
						('OKC_API.G_MISS_CHAR',
						 'OKC_API.G_MISS_NUM',
						 'OKC_API.G_MISS_DATE')
                                  AND oce_rec.required_yn = 'Y' THEN
			       OKC_API.SET_MESSAGE(
				p_app_name      => g_app_name
			       ,p_msg_name      => 'OKC_NO_PARAMS'
			       ,p_token1        => 'PROCESS'
			       ,p_token1_value  => oce_rec.outcome
			       ,p_token2        => 'PARAM'
			       ,p_token2_value  => oce_rec.parameter
			       );

                            END IF;
			  v_oce_id := oce_rec.oce_id;
                        END IF;
                    END IF;
                 END IF;
             END LOOP;
	 CLOSE oce_cur;
       END LOOP;
	x_return_status := OKC_API.G_RET_STS_SUCCESS;

  IF (l_debug = 'Y') THEN
     okc_debug.log('1000: Leaving Build outcome ',2);
     okc_debug.Reset_Indentation;
  END IF;

    EXCEPTION
      WHEN OTHERS THEN
	x_return_status := OKC_API.G_RET_STS_UNEXP_ERROR;

        IF (l_debug = 'Y') THEN
           okc_debug.log('2000: Leaving Build Outcome with error: '||sqlerrm,2);
           okc_debug.Reset_Indentation;
        END IF;

	RAISE;
     END build_outcome;


/** Release 12 code start
New API build_outcome added to invoke launch_outcome directly.
This API is used for KEXPIRE event. This will bypass the outcome queue **/


  PROCEDURE build_date_outcome(
     p_cnh_tab           IN  okc_condition_eval_pvt.id_tab_type,
     p_msg_tab           IN  okc_aq_pvt.msg_tab_typ,
     p_init_msg_list     IN VARCHAR2 ,
     x_return_status     OUT NOCOPY VARCHAR2,
     x_msg_count         OUT NOCOPY NUMBER,
     x_msg_data          OUT NOCOPY VARCHAR2
     )
     IS
     CURSOR oce_cur (x IN NUMBER) IS
     SELECT  oce.id oce_id,
             decode(pdf.pdf_type,'ALERT',pdf.message_name,
		    'SCRIPT',pdf.script_name,
		    'PPS',pdf.package_name||'.'||pdf.procedure_name,
		    'WPS',pdf.wf_name||'.'||pdf.wf_process_name,NULL) outcome,
	     pdf.pdf_type pdf_type,
	     pdf.name name,
	     pdp.id pdp_id,
	     pdp.name parameter,
	     decode(pdp.data_type,'CHAR','''',
		   'DATE','''',NULL) prefix_param,
	     nvl(pdp.default_value,
		 decode(pdp.data_type,
		        'CHAR'  ,'OKC_API.G_MISS_CHAR',
		        'NUMBER','OKC_API.G_MISS_NUM',
			'DATE'  ,'OKC_API.G_MISS_DATE',
			'OKC_API.G_MISS_CHAR')) default_value,
	     pdp.data_type datatype,
	     pdp.required_yn required_yn
     FROM    okc_outcomes_b oce,
	     okc_process_defs_v pdf,
	     okc_process_def_parameters_v pdp
     WHERE   oce.cnh_id =    p_cnh_tab(x).v_id
     AND     oce.pdf_id =    pdf.id
     AND     pdf.id     =    pdp.pdf_id(+)
     AND     UPPER(pdf.usage)  =    'OUTCOME'
     AND     UPPER(oce.enabled_yn) = 'Y'
     ORDER   BY outcome,parameter;
     oce_rec            oce_cur%ROWTYPE;

     l_oce_id     okc_outcomes_b.id%TYPE;
     l_pdp_id     okc_process_def_parms_b.id%TYPE;
     l_value      okc_outcome_arguments.value%TYPE;
     l_element_name  okc_action_attributes_b.element_name%TYPE;
     CURSOR oat_cur(l_oce_id IN NUMBER,
		    l_pdp_id IN NUMBER) IS
     SELECT oat.value value,aae.element_name element_name
     FROM   okc_outcome_arguments oat,
	    okc_action_attributes_b aae
     WHERE  oat.oce_id = l_oce_id
     AND    oat.pdp_id = l_pdp_id
     AND    oat.aae_id = aae.id(+);
     oat_rec  oat_cur%ROWTYPE;

     sync_index           NUMBER :=1;
     async_index          NUMBER :=1;
     l_msg_tab            okc_aq_pvt.msg_tab_typ;
     l_corrid_rec         okc_aq_pvt.corrid_rec_typ;
     p_cnh_id             okc_condition_headers_b.id%TYPE;
     l_string             VARCHAR2(32000);
     l_attr_value      okc_outcome_arguments.value%TYPE; --Bug 3731760
     v_oce_id             NUMBER :=0;
     sync_pdf_type        okc_process_defs_b.pdf_type%TYPE;
     async_pdf_type       okc_process_defs_b.pdf_type%TYPE;
    l_api_name            CONSTANT VARCHAR2(30) := 'BUILD_DATE_OUTCOME';
    l_msg_data            varchar2(1000);
    l_msg_count           number;
    l_return_status       varchar2(1);
    param_exist           number;
    no_param              number;

   --
   l_proc varchar2(72) := '  okc_condition_eval_pvt.'||'build_date_outcome';
   --

     BEGIN

    IF (l_debug = 'Y') THEN
       okc_debug.Set_Indentation(l_proc);
       okc_debug.log('10: Entering build date outcome ',2);
    END IF;
      x_return_status := OKC_API.G_RET_STS_SUCCESS;
     --x_sync_outcome_tab   := okc_condition_eval_pvt.outcome_tab_type();
     l_msg_tab    := okc_aq_pvt.msg_tab_typ();
     l_string := NULL;
       FOR i IN 1..p_cnh_tab.COUNT LOOP
         IF oce_cur%ISOPEN THEN
    	   CLOSE oce_cur;
         END IF;
         OPEN oce_cur(i) ;
	        LOOP
            FETCH oce_cur INTO oce_rec;
	     -- if last record then check if there is
	     -- outcome built by previous loop
	     -- add the outcome to sync_outcome_tab

           IF oce_cur%NOTFOUND THEN
              IF l_msg_tab.COUNT <> 0  AND
			     l_corrid_rec.corrid IS NOT NULL THEN
                    -- launch outcome
                    OKC_OUTCOME_INIT_PVT.Launch_outcome(
                         p_api_version     => 1,
                         p_init_msg_list   => OKC_API.G_FALSE,
                         p_corrid_rec      => l_corrid_rec,
                         p_msg_tab_typ     => l_msg_tab,
                         x_msg_count       => l_msg_count,
                         x_msg_data        => l_msg_data,
                         x_return_status   => l_return_status
                         );

			        -- initialize l_msg_tab
                    l_msg_tab    := okc_aq_pvt.msg_tab_typ();
               END IF;
                   EXIT;
           ELSE

		        IF oat_cur%ISOPEN THEN
		            CLOSE oat_cur;
		        END IF;
		        OPEN oat_cur(oce_rec.oce_id,oce_rec.pdp_id) ;
		        FETCH oat_cur INTO oat_rec;
		            IF oat_cur%FOUND THEN
			            l_value := oat_rec.value;
		                l_element_name := oat_rec.element_name;
		            ELSE
		                l_value := null;
		                l_element_name := null;
		            END IF;
		        CLOSE oat_cur;

           -- if new outcome then launch outcome
		   IF v_oce_id <> oce_rec.oce_id THEN
              IF l_msg_tab.COUNT <> 0 AND
			    l_corrid_rec.corrid IS NOT NULL THEN
                    -- launch outcome
                    OKC_OUTCOME_INIT_PVT.Launch_outcome(
                         p_api_version     => 1,
                         p_init_msg_list   => OKC_API.G_FALSE,
                         p_corrid_rec      => l_corrid_rec,
                         p_msg_tab_typ     => l_msg_tab,
                         x_msg_count       => l_msg_count,
                         x_msg_data        => l_msg_data,
                         x_return_status   => l_return_status
                         );
              END IF; --  l_msg_tab.COUNT <> 0

                        -- initialize l_msg_tab,async_index and assign new pdf_type to corrid_rec
                        l_corrid_rec.corrid := oce_rec.pdf_type;
                        l_msg_tab    := okc_aq_pvt.msg_tab_typ();
			            l_msg_tab.extend;
		                async_index := 1;
		                l_msg_tab(async_index).element_name := 'K_ID';
		                l_msg_tab(async_index).element_value:= get_attribute_value('K_ID',p_msg_tab);
			            l_msg_tab.extend;
		                async_index := async_index+1;
		                l_msg_tab(async_index).element_name := 'OCE_ID';
		                l_msg_tab(async_index).element_value:= oce_rec.oce_id;
			            --***************************
			            l_msg_tab.extend;
		                async_index := async_index+1;
		                l_msg_tab(async_index).element_name := 'NAME';
		                l_msg_tab(async_index).element_value := UPPER(oce_rec.outcome);

                    -- if outcome name is missing then raise exception
			        IF l_msg_tab(async_index).element_value IS NULL THEN
			            OKC_API.SET_MESSAGE(
				        p_app_name      => g_app_name
			            ,p_msg_name      => 'OKC_INVALID_PROCESS'
			            );
                    END IF;
			  -- append parameters to async_outcome_tab
			    l_msg_tab.extend;
		            async_index := async_index+1;
		            l_msg_tab(async_index).element_name
			    := 'PARAM_NAME';
		            l_msg_tab(async_index).element_value
			    := oce_rec.parameter;
			    l_msg_tab.extend;
		            async_index := async_index+1;
		            l_msg_tab(async_index).element_name
			    := 'PARAM_DATATYPE';
		            l_msg_tab(async_index).element_value
			    := oce_rec.datatype;
			    l_msg_tab.extend;
		            async_index := async_index+1;
		            l_msg_tab(async_index).element_name
			    := 'PARAM_VALUE';
		            l_msg_tab(async_index).element_value
			    := NVL(l_value,
			         NVL(get_attribute_value(l_element_name,
							 p_msg_tab),
			              oce_rec.default_value));
			  v_oce_id := oce_rec.oce_id;
            -- if the outcome is same as old outcome then append parameters to string
		   ELSIF v_oce_id = oce_rec.oce_id THEN
			  -- append parameters to async_outcome_tab
			    l_msg_tab.extend;
		            async_index := async_index+1;
		            l_msg_tab(async_index).element_name
			    := 'PARAM_NAME';
		            l_msg_tab(async_index).element_value
			    := oce_rec.parameter;
			    l_msg_tab.extend;
		            async_index := async_index+1;
		            l_msg_tab(async_index).element_name
			    := 'PARAM_DATATYPE';
		            l_msg_tab(async_index).element_value
			    := oce_rec.datatype;
			    l_msg_tab.extend;
		            async_index := async_index+1;
		            l_msg_tab(async_index).element_name
			    := 'PARAM_VALUE';
		            l_msg_tab(async_index).element_value
			    := NVL(l_value,
			         NVL(get_attribute_value(l_element_name,
							 p_msg_tab),
			              oce_rec.default_value));
     -- if any of the parameter values are missing then write message to
     -- okc_aqerrors table and stop further processing of that outcome
			    IF l_msg_tab(async_index).element_value IN
						('OKC_API.G_MISS_CHAR',
						 'OKC_API.G_MISS_NUM',
						 'OKC_API.G_MISS_DATE')
                   AND oce_rec.required_yn = 'Y' THEN
			       OKC_API.SET_MESSAGE(
				    p_app_name      => g_app_name
			       ,p_msg_name      => 'OKC_NO_PARAMS'
			       ,p_token1        => 'PROCESS'
			       ,p_token1_value  => oce_rec.outcome
			       ,p_token2        => 'PARAM'
			       ,p_token2_value  => oce_rec.parameter
			       );

                END IF;
			  v_oce_id := oce_rec.oce_id;
           END IF; -- v_oce_id = oce_rec.oce_id
          END IF;
         END LOOP;
	 CLOSE oce_cur;
       END LOOP;
	x_return_status := OKC_API.G_RET_STS_SUCCESS;

  IF (l_debug = 'Y') THEN
     okc_debug.log('1000: Leaving Build date outcome ',2);
     okc_debug.Reset_Indentation;
  END IF;

    EXCEPTION
      WHEN OTHERS THEN
	x_return_status := OKC_API.G_RET_STS_UNEXP_ERROR;

        IF (l_debug = 'Y') THEN
           okc_debug.log('2000: Leaving Build Date Outcome with error: '||sqlerrm,2);
           okc_debug.Reset_Indentation;
        END IF;

	RAISE;
     END build_date_outcome;

/**Release 12 code END **/


    PROCEDURE create_condition_occurrence (
		  p_cnh_tab           IN okc_condition_eval_pvt.id_tab_type,
		  p_datetime          IN DATE,
                  p_init_msg_list     IN VARCHAR2 ,
                  x_return_status     OUT NOCOPY VARCHAR2,
                  x_msg_count         OUT NOCOPY NUMBER,
                  x_msg_data          OUT NOCOPY VARCHAR2,
                  x_coev_tbl          OUT NOCOPY okc_coe_pvt.coev_tbl_type
		  )
    IS

    l_api_name      CONSTANT VARCHAR2(30) := 'CREATE_CONDITION_OCCURRENCE';
    l_api_version   NUMBER := 1.0;
    l_msg_data      varchar2(1000);
    l_msg_count     number;
    l_return_status varchar2(1);
    l_coe_tab       okc_condition_eval_pvt.id_tab_type;
    l_coev_tbl      okc_coe_pvt.coev_tbl_type;
    v_coev_tbl      okc_coe_pvt.coev_tbl_type;
    l_count         number := 1;
    l_task_id       jtf_tasks_b.task_id%TYPE;
    OKC_PROCESS_FAILED    EXCEPTION;

    CURSOR cnh_cur(x IN NUMBER) IS
    SELECT name,
	   tracked_yn,
	   task_owner_id,
	   dnz_chr_id
    FROM   OKC_CONDITION_HEADERS_V
    WHERE  id = x;
    cnh_rec    cnh_cur%ROWTYPE;

   --
   l_proc varchar2(72) := '  okc_condition_eval_pvt.'||'create_condition_occurrence';
   --

    BEGIN

    IF (l_debug = 'Y') THEN
       okc_debug.Set_Indentation(l_proc);
       okc_debug.log('10: Entering ',2);
    END IF;

      FOR i IN 1..p_cnh_tab.COUNT LOOP
        l_coev_tbl(l_count).cnh_id   := p_cnh_tab(i).v_id;
        l_coev_tbl(l_count).datetime := p_datetime;
        l_count := l_count + 1;
      END LOOP;

      OKC_CONDITIONS_PUB.create_cond_occurs(
	  p_api_version                  => l_api_version,
          p_init_msg_list                => OKC_API.G_FALSE,
	  x_return_status                => l_return_status,
	  x_msg_data                     => l_msg_data,
	  x_msg_count                    => l_msg_count,
          p_coev_tbl                     => l_coev_tbl,
	  x_coev_tbl                     => v_coev_tbl
	  );
      IF NVL(l_return_status,'X') <> OKC_API.G_RET_STS_SUCCESS THEN
	 OKC_API.SET_MESSAGE(
	   p_app_name      => g_app_name
	   ,p_msg_name      => 'OKC_PROCESS_FAILED'
	   ,p_token1        => 'SOURCE'
	   ,p_token1_value  => 'Condition Evaluator'
	   ,p_token2        => 'PROCESS'
	   ,p_token2_value  => 'Create condition occur'
	   );
	   RAISE OKC_PROCESS_FAILED;
      END IF;
     -- call Time Resolver for all condition occurrences
     IF NVL(l_return_status,'X') = OKC_API.G_RET_STS_SUCCESS AND
	v_coev_tbl.count <> 0 THEN
     FOR i IN 1..v_coev_tbl.COUNT LOOP
         IF cnh_cur%ISOPEN THEN
    	   CLOSE cnh_cur;
         END IF;
       OPEN cnh_cur(v_coev_tbl(i).cnh_id);
       FETCH cnh_cur INTO cnh_rec;
	 IF cnh_rec.dnz_chr_id IS NOT NULL THEN
           OKC_TIME_RES_PUB.Res_Time_Events(
	                    p_api_version    => l_api_version,
		            p_init_msg_list  => OKC_API.G_FALSE,
		            p_cnh_id         => v_coev_tbl(i).cnh_id,
			    p_coe_id         => v_coev_tbl(i).id,
			    p_date           => v_coev_tbl(i).datetime,
	                    x_return_status  => l_return_status);
           IF NVL(l_return_status,'X') <> OKC_API.G_RET_STS_SUCCESS THEN
	     OKC_API.SET_MESSAGE(
	       p_app_name      => g_app_name
	       ,p_msg_name      => 'OKC_PROCESS_FAILED'
	       ,p_token1        => 'SOURCE'
	       ,p_token1_value  => 'Condition Evaluator'
	       ,p_token2        => 'PROCESS'
	       ,p_token2_value  => 'Create resolved time values'
	       );
	     RAISE OKC_PROCESS_FAILED;
           END IF;
         END IF;
/**********************************************************************
-- bug 1757364
-- Task created moved to procedure create_action_att_vals in order to
-- retrieve the document source number
     -- create tasks for true conditions with tracked_yn = 'Y'
         IF UPPER(cnh_rec.tracked_yn) = 'Y' THEN
           OKC_TASK_PUB.create_condition_task(
	                p_api_version      => l_api_version,
		        p_init_msg_list    => OKC_API.G_FALSE,
			p_cond_occr_id     => v_coev_tbl(i).id,
		        p_condition_name   => cnh_rec.name,
			p_task_owner_id    => cnh_rec.task_owner_id,
			p_actual_end_date  => v_coev_tbl(i).datetime,
	                x_return_status    => l_return_status,
	                x_msg_count        => l_msg_count,
	                x_msg_data         => l_msg_data,
	                x_task_id          => l_task_id);

           IF NVL(l_return_status,'X') <> OKC_API.G_RET_STS_SUCCESS THEN
	     OKC_API.SET_MESSAGE(
	       p_app_name      => g_app_name
	      ,p_msg_name      => 'OKC_PROCESS_FAILED'
	      ,p_token1        => 'SOURCE'
	      ,p_token1_value  => 'Condition Evaluator'
	      ,p_token2        => 'PROCESS'
	      ,p_token2_value  => 'Create condition task'
	      );
	      RAISE OKC_PROCESS_FAILED;
           END IF;
         END IF;
-- bug 1757364 end!
***********************************************************************/
       CLOSE cnh_cur;
     END LOOP;
     END IF;
	x_coev_tbl := v_coev_tbl;
	x_return_status := OKC_API.G_RET_STS_SUCCESS;

  IF (l_debug = 'Y') THEN
     okc_debug.log('1000: Leaving ',2);
     okc_debug.Reset_Indentation;
  END IF;

    EXCEPTION
      WHEN OTHERS THEN
	x_return_status := OKC_API.G_RET_STS_UNEXP_ERROR;

        IF (l_debug = 'Y') THEN
           okc_debug.log('2000: Leaving ',2);
           okc_debug.Reset_Indentation;
        END IF;

	RAISE;
    END create_condition_occurrence;

    -- creates action attribute values for condition occurrence
    PROCEDURE create_action_att_values (
      p_init_msg_list    IN VARCHAR2 ,
      x_return_status    OUT NOCOPY VARCHAR2,
      x_msg_count        OUT NOCOPY NUMBER,
      x_msg_data         OUT NOCOPY VARCHAR2,
      p_acn_id           IN  okc_actions_b.id%TYPE,
      p_coev_tab         IN  okc_coe_pvt.coev_tbl_type,
      p_msg_tab          IN  okc_aq_pvt.msg_tab_typ,
      x_aavv_tbl         OUT NOCOPY okc_aav_pvt.aavv_tbl_type)

      IS
    l_aavv_tbl      okc_aav_pvt.aavv_tbl_type;
    v_aavv_tbl      okc_aav_pvt.aavv_tbl_type;
    l_api_name      CONSTANT VARCHAR2(30) := 'CREATE_ACTION_ATT_VALUES';
    l_api_version   NUMBER := 1.0;
    l_msg_data      varchar2(1000);
    l_msg_count     number;
    l_return_status varchar2(1);
    l_count         number :=1;
    OKC_PROCESS_FAILED    EXCEPTION;

    -- bug 1757364
    CURSOR cnh_cur(x IN NUMBER) IS
    SELECT name,
	   tracked_yn,
	   task_owner_id,
	   dnz_chr_id
    FROM   OKC_CONDITION_HEADERS_V
    WHERE  id = x;
    --
    cnh_rec        cnh_cur%ROWTYPE;
    l_task_id      jtf_tasks_b.task_id%TYPE;
    -- bug 1757364 end.

   --
   l_proc varchar2(72) := '  okc_condition_eval_pvt.'||'create_action_att_values';
   --

    BEGIN

    IF (l_debug = 'Y') THEN
       okc_debug.Set_Indentation(l_proc);
       okc_debug.log('10: Entering ',2);
    END IF;


      FOR outer_loop IN 1..p_coev_tab.count LOOP

        FOR inner_loop IN 1..p_msg_tab.count LOOP
	  l_aavv_tbl(l_count).coe_id := p_coev_tab(outer_loop).id;
	  l_aavv_tbl(l_count).aae_id := get_attribute_id(
					  p_acn_id,
					  p_msg_tab(inner_loop).element_name);
	  l_aavv_tbl(l_count).value  := p_msg_tab(inner_loop).element_value;
	  l_count := l_count+1;
        END LOOP;

      END LOOP;

      OKC_CONDITIONS_PUB.create_act_att_vals(
	  p_api_version                  => '1',
          p_init_msg_list                => OKC_API.G_FALSE,
	  x_return_status                => l_return_status,
	  x_msg_data                     => l_msg_data,
	  x_msg_count                    => l_msg_count,
          p_aavv_tbl                     => l_aavv_tbl,
	  x_aavv_tbl                     => v_aavv_tbl
	  );
           IF NVL(l_return_status,'X') <> OKC_API.G_RET_STS_SUCCESS THEN
	     OKC_API.SET_MESSAGE(
	       p_app_name      => g_app_name
	      ,p_msg_name      => 'OKC_PROCESS_FAILED'
	      ,p_token1        => 'SOURCE'
	      ,p_token1_value  => 'Condition Evaluator'
	      ,p_token2        => 'PROCESS'
	      ,p_token2_value  => 'Create action att values'
	      );
	   RAISE OKC_PROCESS_FAILED;
           END IF;
	x_return_status := OKC_API.G_RET_STS_SUCCESS;

-- bug 1757364
-- addded task creation to this procedure in order to retrieve document
-- source number from the action attribute values.
--
     IF NVL(l_return_status,'X') = OKC_API.G_RET_STS_SUCCESS AND p_coev_tab.count <> 0 THEN
     FOR i IN 1..p_coev_tab.COUNT LOOP
         IF cnh_cur%ISOPEN THEN
    	   CLOSE cnh_cur;
         END IF;
       OPEN cnh_cur(p_coev_tab(i).cnh_id);
       FETCH cnh_cur INTO cnh_rec;

     -- create tasks for true conditions with tracked_yn = 'Y'
         IF UPPER(cnh_rec.tracked_yn) = 'Y' THEN
           OKC_TASK_PUB.create_condition_task(
	                p_api_version      => l_api_version,
		        p_init_msg_list    => OKC_API.G_FALSE,
			p_cond_occr_id     => p_coev_tab(i).id,
		        p_condition_name   => cnh_rec.name,
			p_task_owner_id    => cnh_rec.task_owner_id,
			p_actual_end_date  => p_coev_tab(i).datetime,
	                x_return_status    => l_return_status,
	                x_msg_count        => l_msg_count,
	                x_msg_data         => l_msg_data,
	                x_task_id          => l_task_id);

           IF NVL(l_return_status,'X') <> OKC_API.G_RET_STS_SUCCESS THEN
	     OKC_API.SET_MESSAGE(
	       p_app_name      => g_app_name
	      ,p_msg_name      => 'OKC_PROCESS_FAILED'
	      ,p_token1        => 'SOURCE'
	      ,p_token1_value  => 'Condition Evaluator'
	      ,p_token2        => 'PROCESS'
	      ,p_token2_value  => 'Create condition task'
	      );
	      RAISE OKC_PROCESS_FAILED;
           END IF;
         END IF;
       CLOSE cnh_cur;
     END LOOP;
     END IF;
-- bug 1757364 end.

  IF (l_debug = 'Y') THEN
     okc_debug.log('1000: Leaving ',2);
     okc_debug.Reset_Indentation;
  END IF;

    EXCEPTION
      WHEN OTHERS THEN
	x_return_status := OKC_API.G_RET_STS_UNEXP_ERROR;

        IF (l_debug = 'Y') THEN
           okc_debug.log('2000: Leaving ',2);
           okc_debug.Reset_Indentation;
        END IF;

	RAISE;
    END create_action_att_values;


 -- Evaluate single plan
 PROCEDURE evaluate_plan_condition(
     p_api_version           IN NUMBER,
     p_init_msg_list         IN VARCHAR2 ,
     x_return_status         OUT NOCOPY VARCHAR2,
     x_msg_count             OUT NOCOPY NUMBER,
     x_msg_data              OUT NOCOPY VARCHAR2,
     p_cnh_id                IN  okc_condition_headers_b.id%TYPE,
     p_msg_tab               IN  okc_aq_pvt.msg_tab_typ,
     x_sync_outcome_tab      OUT NOCOPY okc_condition_eval_pvt.outcome_tab_type
    )
    IS
    l_status              VARCHAR2(10);
    l_cnh_tab             okc_condition_eval_pvt.id_tab_type;
    l_return_status       varchar2(1);
    l_api_name            CONSTANT VARCHAR2(30) := 'EVALUATE_PLAN_CONDITION';
    OKC_PROCESS_FAILED    EXCEPTION;
    --
    l_proc varchar2(72) := '  okc_condition_eval_pvt.'||'evaluate_plan_condition';
    --
    BEGIN
      l_cnh_tab   :=    okc_condition_eval_pvt.id_tab_type();
      x_sync_outcome_tab  := okc_condition_eval_pvt.outcome_tab_type();

      IF (l_debug = 'Y') THEN
       okc_debug.Set_Indentation(l_proc);
       okc_debug.log('10: Entering evaluate_plan_condition',2);
      END IF;

      l_return_status := OKC_API.START_ACTIVITY
                         (l_api_name
                         ,p_init_msg_list
                         ,'_PVT'
                         ,x_return_status);

       IF l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR THEN
         RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
       ELSIF l_return_status = OKC_API.G_RET_STS_ERROR THEN
         RAISE OKC_API.G_EXCEPTION_ERROR;
       END IF;

      -- evaluate the condition lines for p_cnh_id
      -- and return result as TRUE or FALSE
	           evaluate_condition_lines(   p_cnh_id
				  ,p_msg_tab
				  ,OKC_API.G_FALSE
                          ,x_return_status
                          ,x_msg_count
                          ,x_msg_data
				  ,l_status
				   );
          IF NVL(x_return_status,'X') <> OKC_API.G_RET_STS_SUCCESS THEN
			       OKC_API.SET_MESSAGE(
				    p_app_name      => g_app_name
			       ,p_msg_name      => 'OKC_PROCESS_FAILED'
			       ,p_token1        => 'SOURCE'
			       ,p_token1_value  => 'Condition Evaluator'
			       ,p_token2        => 'PROCESS'
			       ,p_token2_value  => 'Evaluate Condition Lines'
			       );
	    raise OKC_PROCESS_FAILED;
           END IF;

	IF l_status =  'TRUE' THEN
           l_cnh_tab.extend;
           l_cnh_tab(1).v_id:=p_cnh_id;

      IF (l_debug = 'Y') THEN
       okc_debug.log('10: before Build Outcome ',2);
      END IF;
      -- for the condition get the table of outcomes
           build_outcome( l_cnh_tab
		 ,p_msg_tab
                 ,OKC_API.G_FALSE
                 ,x_return_status
                 ,x_msg_count
                 ,x_msg_data
		 ,x_sync_outcome_tab
		  );
      IF (l_debug = 'Y') THEN
       okc_debug.log('10: after Build Outcome ',2);
      END IF;
            IF NVL(x_return_status,'X') <> OKC_API.G_RET_STS_SUCCESS THEN
 	       OKC_API.SET_MESSAGE(
			    	p_app_name      => g_app_name
			       ,p_msg_name      => 'OKC_PROCESS_FAILED'
			       ,p_token1        => 'SOURCE'
			       ,p_token1_value  => 'Condition Evaluator'
			       ,p_token2        => 'PROCESS'
			       ,p_token2_value  => 'Build Outcome'
			       );
	       raise OKC_PROCESS_FAILED;
             END IF;
          END IF;

   OKC_API.END_ACTIVITY( x_msg_count,x_msg_data);

   IF (l_debug = 'Y') THEN
     okc_debug.log('1000: Leaving evaluate_plan_condition ',2);
     okc_debug.Reset_Indentation;
   END IF;

   EXCEPTION

      WHEN OTHERS THEN
      IF (l_debug = 'Y') THEN
       okc_debug.log('10: error in evaluate_plan_conditionl: '||sqlerrm,2);
      END IF;
        IF x_sync_outcome_tab.count <> 0 THEN
	   x_sync_outcome_tab.delete;
        END IF;
	x_return_status :=OKC_API.HANDLE_EXCEPTIONS
					( l_api_name,
					  G_PKG_NAME,
					  'OTHERS',
					  x_msg_count,
					  x_msg_data,
					  '_PVT');

        IF (l_debug = 'Y') THEN
           okc_debug.log('2000: Leaving ',2);
           okc_debug.Reset_Indentation;
        END IF;


    END evaluate_plan_condition;

 -- ** SYNCRONOUS Condition Evaluation used by RelationShip Plan Application
 -- This procedure acts as a wrapper for other APIs in the package.
 -- This procedure first calls evaluate_condition_lines and gets back a table
 -- of TRUE condition header ids. This header id table and message table
 -- are passed to build_outcome which returns a table of outcomes.
 -- This table of outcomes are returned to Relationship Plan API

 PROCEDURE evaluate_condition(
     p_api_version           IN NUMBER,
     p_init_msg_list         IN VARCHAR2 ,
     x_return_status         OUT NOCOPY VARCHAR2,
     x_msg_count             OUT NOCOPY NUMBER,
     x_msg_data              OUT NOCOPY VARCHAR2,
     p_acn_id                IN  okc_actions_b.id%TYPE,
     p_msg_tab               IN  okc_aq_pvt.msg_tab_typ,
     x_sync_outcome_tab      OUT NOCOPY okc_condition_eval_pvt.outcome_tab_type
    )
    IS
    CURSOR cnh_cur IS
    SELECT id
    FROM   okc_condition_headers_b
    WHERE  acn_id = p_acn_id
    AND    dnz_chr_id is null
    AND    condition_valid_yn = 'Y'
    AND    template_yn = 'N'
    AND    trunc(date_active) <= trunc(SYSDATE)
    AND    NVL(trunc(date_inactive),trunc(SYSDATE)) >= trunc(SYSDATE);
    cnh_rec               cnh_cur%ROWTYPE;
    l_status              VARCHAR2(10);
    l_count               NUMBER := 1;
    l_cnh_tab             okc_condition_eval_pvt.id_tab_type;
    l_msg_data            varchar2(1000);
    l_msg_count           number;
    l_return_status       varchar2(1);
    x_coev_tbl            okc_coe_pvt.coev_tbl_type;
    l_coev_tbl            okc_coe_pvt.coev_tbl_type;
    x_aavv_tbl            okc_aav_pvt.aavv_tbl_type;
    l_api_name            CONSTANT VARCHAR2(30) := 'EVALUATE_CONDITION';
    i			  NUMBER;
    OKC_PROCESS_FAILED    EXCEPTION;
    l_datetime            DATE;

   --
   l_proc varchar2(72) := '  okc_condition_eval_pvt.'||'evaluate_condition';
   --

    BEGIN

    IF (l_debug = 'Y') THEN
       okc_debug.Set_Indentation(l_proc);
       okc_debug.log('10: Entering ',2);
    END IF;

      l_return_status := OKC_API.START_ACTIVITY
                         (l_api_name
                         ,p_init_msg_list
                         ,'_PVT'
                         ,x_return_status);

       IF l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR THEN
         RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
       ELSIF l_return_status = OKC_API.G_RET_STS_ERROR THEN
         RAISE OKC_API.G_EXCEPTION_ERROR;
       END IF;

      -- initializing and extending table type variables
      l_cnh_tab   :=    okc_condition_eval_pvt.id_tab_type();
      x_sync_outcome_tab  := okc_condition_eval_pvt.outcome_tab_type();
         IF cnh_cur%ISOPEN THEN
    	   CLOSE cnh_cur;
         END IF;

/*	--Added by suma
	--get contract id
	-- commented out for now as this is not relevent for Rel Plan actions
	-- look at standard evaluator for usage of l_k_id
        l_k_id := get_attribute_value('K_ID',p_msg_tab);
    */

      OPEN cnh_cur;
      LOOP
      FETCH cnh_cur INTO cnh_rec;
	    IF cnh_cur%NOTFOUND THEN
	        EXIT;
        ELSE
          -- for each condition header check if there are lines, evaluate them
	  -- and return result as TRUE or FALSE
	           evaluate_condition_lines(   cnh_rec.id
					      ,p_msg_tab
				          ,OKC_API.G_FALSE
                          ,x_return_status
                          ,x_msg_count
                          ,x_msg_data
					      ,l_status
					      );
          IF NVL(x_return_status,'X') <> OKC_API.G_RET_STS_SUCCESS THEN
			       OKC_API.SET_MESSAGE(
				p_app_name      => g_app_name
			       ,p_msg_name      => 'OKC_PROCESS_FAILED'
			       ,p_token1        => 'SOURCE'
			       ,p_token1_value  => 'Condition Evaluator'
			       ,p_token2        => 'PROCESS'
			       ,p_token2_value  => 'Evaluate Condition Lines'
			       );
	    raise OKC_PROCESS_FAILED;
          END IF;
	    -- build a table of cnh_ids for all ids that evaluate to true
	    IF l_status =  'TRUE' THEN
              l_cnh_tab.extend;
	      l_cnh_tab(l_count).v_id := cnh_rec.id;
	      l_count := l_count+1;
            END IF;

        END IF;
      END LOOP;
      CLOSE cnh_cur;

      -- If there are conditions that are true then
      -- for each condition get the table of outcomes
      IF l_cnh_tab.count <> 0 THEN
	            build_outcome( l_cnh_tab
		              ,p_msg_tab
                      ,OKC_API.G_FALSE
                      ,x_return_status
                      ,x_msg_count
                      ,x_msg_data
		              ,x_sync_outcome_tab
		      );
          IF NVL(x_return_status,'X') <> OKC_API.G_RET_STS_SUCCESS THEN
			       OKC_API.SET_MESSAGE(
				p_app_name      => g_app_name
			       ,p_msg_name      => 'OKC_PROCESS_FAILED'
			       ,p_token1        => 'SOURCE'
			       ,p_token1_value  => 'Condition Evaluator'
			       ,p_token2        => 'PROCESS'
			       ,p_token2_value  => 'Build Outcome'
			       );
	    raise OKC_PROCESS_FAILED;
          END IF;

      -- get the datetime which is date of intrest to create condition occurrence
         l_datetime := get_datetime(p_acn_id,
				    p_msg_tab);
         IF l_datetime IS NULL THEN
	    l_datetime := SYSDATE;
         END IF;
      -- create condition occurrence for true conditions
      create_condition_occurrence ( l_cnh_tab
				   ,l_datetime
				   ,OKC_API.G_FALSE
                                   ,x_return_status
                                   ,x_msg_count
                                   ,x_msg_data
				   , x_coev_tbl
				  );
               IF NVL(x_return_status,'X') <> OKC_API.G_RET_STS_SUCCESS THEN
		       OKC_API.SET_MESSAGE(
			p_app_name      => g_app_name
		       ,p_msg_name      => 'OKC_PROCESS_FAILED'
		       ,p_token1        => 'SOURCE'
		       ,p_token1_value  => 'Condition Evaluator'
		       ,p_token2        => 'PROCESS'
		       ,p_token2_value  => 'Create Condition Occurrence'
		       );
	         raise OKC_PROCESS_FAILED;
               END IF;
        l_coev_tbl := x_coev_tbl;
      -- create action attribute values for each condition occurrence
	create_action_att_values ( OKC_API.G_FALSE
					 ,x_return_status
					 ,x_msg_count
					 ,x_msg_data
					 ,p_acn_id
					 ,l_coev_tbl
					 ,p_msg_tab
					 ,x_aavv_tbl
					 );
                   IF NVL(x_return_status,'X') <> OKC_API.G_RET_STS_SUCCESS THEN
		       OKC_API.SET_MESSAGE(
			p_app_name      => g_app_name
		       ,p_msg_name      => 'OKC_PROCESS_FAILED'
		       ,p_token1        => 'SOURCE'
		       ,p_token1_value  => 'Condition Evaluator'
		       ,p_token2        => 'PROCESS'
		       ,p_token2_value  => 'Create action att values'
		       );
	             raise OKC_PROCESS_FAILED;
                   END IF;
      END IF;

      OKC_API.END_ACTIVITY( x_msg_count,
			    x_msg_data);

  IF (l_debug = 'Y') THEN
     okc_debug.log('1000: Leaving ',2);
     okc_debug.Reset_Indentation;
  END IF;

    EXCEPTION

      WHEN OTHERS THEN
        IF x_sync_outcome_tab.count <> 0 THEN
	   x_sync_outcome_tab.delete;
        END IF;
	x_return_status :=OKC_API.HANDLE_EXCEPTIONS
					( l_api_name,
					  G_PKG_NAME,
					  'OTHERS',
					  x_msg_count,
					  x_msg_data,
					  '_PVT');

        IF (l_debug = 'Y') THEN
           okc_debug.log('2000: Leaving ',2);
           okc_debug.Reset_Indentation;
        END IF;


    END evaluate_condition;


--  standard condition evaluator used for counter update
--  and other asynchronous actions. Invoked from DEQUEUE_EVENT
 -- This procedure acts as a wrapper for other APIs in the package.
 -- This procedure first calls evaluate_condition_lines and gets back a table
 -- of TRUE condition header ids. This header id table and message table
 -- are passed to build_outcome.
 PROCEDURE evaluate_condition(
     p_api_version           IN NUMBER,
     p_init_msg_list         IN VARCHAR2 ,
     x_return_status         OUT NOCOPY VARCHAR2,
     x_msg_count             OUT NOCOPY NUMBER,
     x_msg_data              OUT NOCOPY VARCHAR2,
     p_acn_id                IN  okc_actions_b.id%TYPE,
     p_msg_tab               IN  okc_aq_pvt.msg_tab_typ
    )
    IS
    -- cursor for conditions based on action that occured
    CURSOR cnh_cur(p_k_id IN NUMBER) IS
    SELECT cnh.id id,
	   cnh.one_time_yn one_time_yn,
	   acn.counter_action_yn counter_action_yn,
	   cnh.jtot_object_code jtot_object_code,
	   cnh.counter_group_id  counter_group_id
    FROM   okc_condition_headers_b cnh,
	   okc_actions_b acn
    WHERE  cnh.acn_id = acn.id
    AND    (cnh.dnz_chr_id = p_k_id or cnh.dnz_chr_id IS NULL)
    AND    cnh.condition_valid_yn = 'Y'
    AND    cnh.template_yn = 'N'
    AND    trunc(cnh.date_active) <= trunc(SYSDATE)
    AND    NVL(trunc(cnh.date_inactive),trunc(SYSDATE)) >= trunc(SYSDATE)
    AND    acn.id  =  p_acn_id;
    cnh_rec           cnh_cur%ROWTYPE;
    l_element_name  okc_action_attributes_b.element_name%TYPE:='CTR_GROUP_ID';
    l_status              VARCHAR2(10);
    l_count               NUMBER := 0;
    l_cnh_tab             okc_condition_eval_pvt.id_tab_type;
    l_msg_data            varchar2(1000);
    l_msg_count           number;
    l_return_status       varchar2(1);
    x_coev_tbl            okc_coe_pvt.coev_tbl_type;
    l_coev_tbl            okc_coe_pvt.coev_tbl_type;
    x_aavv_tbl            okc_aav_pvt.aavv_tbl_type;
    l_api_name            CONSTANT VARCHAR2(30) := 'EVALUATE_CONDITION';
    x_sync_outcome_tab    okc_condition_eval_pvt.outcome_tab_type;
    OKC_PROCESS_FAILED    EXCEPTION;
    i			  NUMBER;
    l_k_id		  NUMBER;
    l_datetime            DATE;

   --
   l_proc varchar2(72) := '  okc_condition_eval_pvt.'||'evaluate_condition';
   --

    BEGIN

    IF (l_debug = 'Y') THEN
       okc_debug.Set_Indentation(l_proc);
       okc_debug.log('10: Entering ',2);
    END IF;

      l_return_status := OKC_API.START_ACTIVITY
                         (l_api_name
                         ,p_init_msg_list
                         ,'_PVT'
                         ,x_return_status);

       IF l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR THEN
         RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
       ELSIF l_return_status = OKC_API.G_RET_STS_ERROR THEN
         RAISE OKC_API.G_EXCEPTION_ERROR;
       END IF;

	--Added by suma
	--get contract id
        l_k_id := get_attribute_value('K_ID',p_msg_tab);


      -- initializing and extending table type variables
      l_cnh_tab   :=    okc_condition_eval_pvt.id_tab_type();
      -- build the conditions table based on counter_action_yn
         IF cnh_cur%ISOPEN THEN
    	   CLOSE cnh_cur;
         END IF;
      OPEN cnh_cur(l_k_id);
      LOOP
      FETCH cnh_cur INTO cnh_rec;
	IF cnh_cur%NOTFOUND THEN
	  EXIT;
    ELSIF cnh_rec.counter_action_yn = 'Y' THEN
	      IF cnh_rec.one_time_yn = 'Y' THEN
	         IF evaluated_once(cnh_rec.id) THEN
		        l_status := 'FALSE';
             ELSE
	           IF cnh_rec.jtot_object_code  IS NOT NULL THEN
	              evaluate_condition_lines(cnh_rec.id
					      ,p_msg_tab
				          ,OKC_API.G_FALSE
                          ,x_return_status
                          ,x_msg_count
                          ,x_msg_data
					      ,l_status);

                   IF NVL(x_return_status,'X')<>OKC_API.G_RET_STS_SUCCESS THEN
		                OKC_API.SET_MESSAGE(
			            p_app_name      => g_app_name
		                ,p_msg_name      => 'OKC_PROCESS_FAILED'
		                ,p_token1        => 'SOURCE'
		                ,p_token1_value  => 'Condition Evaluator'
		                ,p_token2        => 'PROCESS'
		                ,p_token2_value  => 'Evaluate condition lines'
		                );
	                  raise OKC_PROCESS_FAILED;
                   END IF;
		       END IF;
             END IF;
	      ELSIF cnh_rec.one_time_yn = 'N' THEN
            -- for each condition header check if there are lines, evaluate them
	        -- and return result as TRUE or FALSE
	           evaluate_condition_lines(
                           cnh_rec.id
					      ,p_msg_tab
				          ,OKC_API.G_FALSE
                          ,x_return_status
                          ,x_msg_count
                          ,x_msg_data
					      ,l_status);

                   IF NVL(x_return_status,'X')<>OKC_API.G_RET_STS_SUCCESS THEN
		                OKC_API.SET_MESSAGE(
			                p_app_name      => g_app_name
		                    ,p_msg_name      => 'OKC_PROCESS_FAILED'
		                    ,p_token1        => 'SOURCE'
		                    ,p_token1_value  => 'Condition Evaluator'
		                    ,p_token2        => 'PROCESS'
		                    ,p_token2_value  => 'Evaluate condition lines'
		                    );
	                        raise OKC_PROCESS_FAILED;
                   END IF;
          END IF; -- one_time_yn
        ELSIF cnh_rec.counter_action_yn = 'N' THEN
	            evaluate_condition_lines( cnh_rec.id
				   ,p_msg_tab
				   ,OKC_API.G_FALSE
                   ,x_return_status
                   ,x_msg_count
                   ,x_msg_data
				   ,l_status
				   );
                   IF NVL(x_return_status,'X')<>OKC_API.G_RET_STS_SUCCESS THEN
		                OKC_API.SET_MESSAGE(
			            p_app_name      => g_app_name
		                ,p_msg_name      => 'OKC_PROCESS_FAILED'
		                ,p_token1        => 'SOURCE'
		                ,p_token1_value  => 'Condition Evaluator'
		                ,p_token2        => 'PROCESS'
		                ,p_token2_value  => 'Evaluate condition lines'
		                );
	                        raise OKC_PROCESS_FAILED;
                   END IF;
        END IF; -- counter_action_yn

	    -- build a table of cnh_ids for all ids that evaluate to true
	    IF l_status =  'TRUE' THEN
                l_cnh_tab.extend;
	            l_count := l_count+1;
	            l_cnh_tab(l_count).v_id := cnh_rec.id;
        END IF;

      END LOOP;
      CLOSE cnh_cur;

      -- If there are conditions that are true then
      -- for each condition get the table of outcomes

      IF l_cnh_tab.count <> 0 THEN
	        build_outcome( l_cnh_tab
		    ,p_msg_tab
            ,OKC_API.G_FALSE
            ,x_return_status
            ,x_msg_count
            ,x_msg_data
		    ,x_sync_outcome_tab
		    );
            IF NVL(x_return_status,'X') <> OKC_API.G_RET_STS_SUCCESS THEN
	            OKC_API.SET_MESSAGE(
		        p_app_name      => g_app_name
	            ,p_msg_name      => 'OKC_PROCESS_FAILED'
	            ,p_token1        => 'SOURCE'
	            ,p_token1_value  => 'Condition Evaluator'
	            ,p_token2        => 'PROCESS'
	            ,p_token2_value  => 'Build outcome'
	            );
	             raise OKC_PROCESS_FAILED;
            END IF;

      -- get the datetime which is date of intrest to create condition occurrence
         l_datetime := get_datetime(p_acn_id,
				    p_msg_tab);
         IF l_datetime IS NULL THEN
	        l_datetime := SYSDATE;
         END IF;
      -- create condition occurrence for true conditions
      create_condition_occurrence ( l_cnh_tab
				   ,l_datetime
				   ,OKC_API.G_FALSE
                   ,x_return_status
                   ,x_msg_count
                   ,x_msg_data
				   , x_coev_tbl
				    );
         IF NVL(x_return_status,'X') <> OKC_API.G_RET_STS_SUCCESS THEN
	       OKC_API.SET_MESSAGE(
		    p_app_name      => g_app_name
	       ,p_msg_name      => 'OKC_PROCESS_FAILED'
	       ,p_token1        => 'SOURCE'
	       ,p_token1_value  => 'Condition Evaluator'
	       ,p_token2        => 'PROCESS'
	       ,p_token2_value  => 'Create condition occurrence'
	       );
	     raise OKC_PROCESS_FAILED;
         END IF;
        l_coev_tbl := x_coev_tbl;
        -- create action attribute values for each condition occurrence
	    create_action_att_values ( OKC_API.G_FALSE
				 ,x_return_status
			     ,x_msg_count
				 ,x_msg_data
				 ,p_acn_id
				 ,l_coev_tbl
				 ,p_msg_tab
				 ,x_aavv_tbl
				 );
         IF NVL(x_return_status,'X') <> OKC_API.G_RET_STS_SUCCESS THEN
	       OKC_API.SET_MESSAGE(
		    p_app_name      => g_app_name
	       ,p_msg_name      => 'OKC_PROCESS_FAILED'
	       ,p_token1        => 'SOURCE'
	       ,p_token1_value  => 'Condition Evaluator'
	       ,p_token2        => 'PROCESS'
	       ,p_token2_value  => 'Create action att values'
	       );
	       raise OKC_PROCESS_FAILED;
         END IF;
      END IF; -- l_cnh_tab.count
      OKC_API.END_ACTIVITY( x_msg_count,
			    x_msg_data);

  IF (l_debug = 'Y') THEN
     okc_debug.log('1000: Leaving ',2);
     okc_debug.Reset_Indentation;
  END IF;

    EXCEPTION

      WHEN OTHERS THEN
	x_return_status :=OKC_API.HANDLE_EXCEPTIONS
					( l_api_name,
					  G_PKG_NAME,
					  'OTHERS',
					  x_msg_count,
					  x_msg_data,
					  '_PVT');

        IF (l_debug = 'Y') THEN
           okc_debug.log('2000: Leaving ',2);
           okc_debug.Reset_Indentation;
        END IF;

    END evaluate_condition;

--  ********** condition evaluator for Date based Actions
 PROCEDURE evaluate_date_condition(
     p_api_version           IN NUMBER,
     p_init_msg_list         IN VARCHAR2 ,
     x_return_status         OUT NOCOPY VARCHAR2,
     x_msg_count             OUT NOCOPY NUMBER,
     x_msg_data              OUT NOCOPY VARCHAR2,
     p_cnh_id                IN  okc_condition_headers_b.id%TYPE,
     p_msg_tab               IN  okc_aq_pvt.msg_tab_typ
    )
    IS
    -- cursor for conditions based on action that occured
    CURSOR cnh_cur IS
    SELECT cnh.id id,
	   cnh.acn_id acn_id,
	   cnh.one_time_yn one_time_yn
    FROM   okc_condition_headers_b cnh
    WHERE  cnh.condition_valid_yn = 'Y'
    AND    cnh.template_yn = 'N'
    AND    trunc(cnh.date_active) <= trunc(SYSDATE)
    AND    NVL(trunc(cnh.date_inactive),trunc(SYSDATE)) >= trunc(SYSDATE)
    AND    cnh.id  =  p_cnh_id;
    cnh_rec           cnh_cur%ROWTYPE;
    l_element_name  okc_action_attributes_b.element_name%TYPE:='CTR_GROUP_ID';
    l_status              VARCHAR2(10);
    l_count               NUMBER := 0;
    l_cnh_tab             okc_condition_eval_pvt.id_tab_type;
    l_msg_data            varchar2(1000);
    l_msg_count           number;
    l_return_status       varchar2(1);
    x_coev_tbl            okc_coe_pvt.coev_tbl_type;
    l_coev_tbl            okc_coe_pvt.coev_tbl_type;
    x_aavv_tbl            okc_aav_pvt.aavv_tbl_type;
    l_api_name            CONSTANT VARCHAR2(30) := 'EVALUATE_DATE_CONDITION';
    x_sync_outcome_tab    okc_condition_eval_pvt.outcome_tab_type;
    OKC_PROCESS_FAILED    EXCEPTION;
    l_datetime            DATE;

   --
   l_proc varchar2(72) := '  okc_condition_eval_pvt.'||'evaluate_date_condition';
   --

    BEGIN

    IF (l_debug = 'Y') THEN
       okc_debug.Set_Indentation(l_proc);
       okc_debug.log('10: Entering ',2);
    END IF;

      l_return_status := OKC_API.START_ACTIVITY
                         (l_api_name
                         ,p_init_msg_list
                         ,'_PVT'
                         ,x_return_status);

       IF l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR THEN
         RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
       ELSIF l_return_status = OKC_API.G_RET_STS_ERROR THEN
         RAISE OKC_API.G_EXCEPTION_ERROR;
       END IF;

      -- initializing and extending table type variables
      l_cnh_tab   :=    okc_condition_eval_pvt.id_tab_type();
      -- build the conditions table based on counter_action_yn
         IF cnh_cur%ISOPEN THEN
    	   CLOSE cnh_cur;
         END IF;
      OPEN cnh_cur;
      FETCH cnh_cur INTO cnh_rec;
	IF cnh_cur%FOUND THEN
	  evaluate_condition_lines( cnh_rec.id
				   ,p_msg_tab
				   ,OKC_API.G_FALSE
                                   ,x_return_status
                                   ,x_msg_count
                                   ,x_msg_data
				   ,l_status
				   );
                   IF NVL(x_return_status,'X')<>OKC_API.G_RET_STS_SUCCESS THEN
		       OKC_API.SET_MESSAGE(
			p_app_name      => g_app_name
		       ,p_msg_name      => 'OKC_PROCESS_FAILED'
		       ,p_token1        => 'SOURCE'
		       ,p_token1_value  => 'Condition Evaluator'
		       ,p_token2        => 'PROCESS'
		       ,p_token2_value  => 'Evaluate Condition Lines'
		       );
	             raise OKC_PROCESS_FAILED;
                   END IF;
        END IF;

	    -- build a table of cnh_ids for all ids that evaluate to true
	    IF l_status =  'TRUE' THEN
              l_cnh_tab.extend;
	      l_count := l_count+1;
	      l_cnh_tab(l_count).v_id := cnh_rec.id;
            END IF;


      -- If there are conditions that are true then
      -- for each condition get the table of outcomes
      IF l_cnh_tab.count <> 0 THEN
	        build_date_outcome( l_cnh_tab
		                ,p_msg_tab
                        ,OKC_API.G_FALSE
                        ,x_return_status
                        ,x_msg_count
                        ,x_msg_data
		                 );
        IF NVL(x_return_status,'X') <> OKC_API.G_RET_STS_SUCCESS THEN
	       OKC_API.SET_MESSAGE(
		    p_app_name      => g_app_name
	       ,p_msg_name      => 'OKC_PROCESS_FAILED'
	       ,p_token1        => 'SOURCE'
	       ,p_token1_value  => 'Condition Evaluator'
	       ,p_token2        => 'PROCESS'
	       ,p_token2_value  => 'Build Outcome'
	       );
	             raise OKC_PROCESS_FAILED;
        END IF;

      -- get the datetime which is date of intrest to create condition occurrence
         l_datetime := get_datetime(cnh_rec.acn_id,
				    p_msg_tab);
         IF l_datetime IS NULL THEN
	    l_datetime := SYSDATE;
         END IF;
      -- create condition occurrence for true conditions
      create_condition_occurrence ( l_cnh_tab
				   ,l_datetime
				   ,OKC_API.G_FALSE
                                   ,x_return_status
                                   ,x_msg_count
                                   ,x_msg_data
				   , x_coev_tbl
				  );
         IF NVL(x_return_status,'X') <> OKC_API.G_RET_STS_SUCCESS THEN
	       OKC_API.SET_MESSAGE(
		p_app_name      => g_app_name
	       ,p_msg_name      => 'OKC_PROCESS_FAILED'
	       ,p_token1        => 'SOURCE'
	       ,p_token1_value  => 'Condition Evaluator'
	       ,p_token2        => 'PROCESS'
	       ,p_token2_value  => 'Create condition occurrence'
	       );
	     raise OKC_PROCESS_FAILED;
         END IF;
        l_coev_tbl := x_coev_tbl;
      CLOSE cnh_cur;
      -- create action attribute values for each condition occurrence
	create_action_att_values ( OKC_API.G_FALSE
				 ,x_return_status
			         ,x_msg_count
				 ,x_msg_data
				 ,cnh_rec.acn_id
				 ,l_coev_tbl
				 ,p_msg_tab
				 ,x_aavv_tbl
				 );
         IF NVL(x_return_status,'X') <> OKC_API.G_RET_STS_SUCCESS THEN
	       OKC_API.SET_MESSAGE(
		p_app_name      => g_app_name
	       ,p_msg_name      => 'OKC_PROCESS_FAILED'
	       ,p_token1        => 'SOURCE'
	       ,p_token1_value  => 'Condition Evaluator'
	       ,p_token2        => 'PROCESS'
	       ,p_token2_value  => 'Create action att values'
	       );
	       raise OKC_PROCESS_FAILED;
         END IF;
      END IF;
      OKC_API.END_ACTIVITY( x_msg_count,
			    x_msg_data);

  IF (l_debug = 'Y') THEN
     okc_debug.log('1000: Leaving ',2);
     okc_debug.Reset_Indentation;
  END IF;

    EXCEPTION

      WHEN OTHERS THEN
	x_return_status :=OKC_API.HANDLE_EXCEPTIONS
					( l_api_name,
					  G_PKG_NAME,
					  'OTHERS',
					  x_msg_count,
					  x_msg_data,
					  '_PVT');

        IF (l_debug = 'Y') THEN
           okc_debug.log('2000: Leaving ',2);
           okc_debug.Reset_Indentation;
        END IF;

    END evaluate_date_condition;



END okc_condition_eval_pvt;

/
