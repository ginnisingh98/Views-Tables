--------------------------------------------------------
--  DDL for Package Body HZ_WORD_CONDITIONS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."HZ_WORD_CONDITIONS_PKG" as
/*$Header: ARHDQWCB.pls 120.3 2006/03/22 22:26:36 repuri noship $ */

-- This is the TCA seeded condition function and any future conditions we seed
-- will have their logic here
FUNCTION  tca_eval_condition_rec(
                                   p_input_str IN VARCHAR2,
                                   p_token_str IN VARCHAR2,
                                   p_repl_str  IN VARCHAR2,
                                   p_condition_id  IN NUMBER,
                                   p_user_spec_cond_val  IN VARCHAR2
	       		     	           )
RETURN VARCHAR2
IS
country_str varchar2(100);
sql_str varchar2(2000);
result_str varchar2(200);
adjusted_user_val varchar2(2000);
BEGIN
   CASE p_condition_id

     -- Start of String
     WHEN 1
     THEN
    -- the replacement does not make the original word go to null
	IF p_repl_str IS NOT NULL
	THEN
		IF p_input_str = p_token_str
		THEN
			return 'N' ;
		ELSE
            --DELIMITED or NON_DELIMITED
		    IF (p_input_str like p_token_str || ' %') OR (p_input_str like p_token_str || '%')
		    THEN
		    	return 'Y' ;
		    ELSE
		    	return 'N' ;
		    END IF;
		END IF;
     -- the replacement makes the original word go to null
    ELSE
		IF p_input_str = p_token_str
		THEN
			return 'N' ;
		ELSE
            --DELIMITED or NON_DELIMITED
		    IF ((p_input_str like p_token_str || ' %') OR (p_input_str like p_token_str || '%'))and replace(p_input_str,p_token_str, p_repl_str) IS NOT NULL
		    THEN
		    	return 'Y' ;
		    ELSE
		    	return 'N' ;
		    END IF;
		END IF;
    END IF ;

     -- End of String
     WHEN 2
     THEN
        -- the replacement does not make the original word go to null
       IF p_repl_str IS NOT NULL
       THEN
		IF p_input_str = p_token_str
		THEN
			return 'N' ;
		ELSE
            -- DELIMITED OR NON_DELIMITED
		    IF (p_input_str like '% ' || p_token_str ) OR (p_input_str like '%' || p_token_str )
		    THEN
		    	return 'Y' ;
		    ELSE
		    	return 'N' ;
		    END IF;
		END IF;
      -- the replacement makes the original word go to null
      ELSE
		IF p_input_str = p_token_str
		THEN
			return 'N' ;
		ELSE
            -- DELIMITED OR NON_DELIMITED
		    IF ((p_input_str like '% ' || p_token_str ) OR (p_input_str like '%' || p_token_str )) and replace(p_input_str,p_token_str, p_repl_str) IS NOT NULL
		    THEN
		    	return 'Y' ;
		    ELSE
		    	return 'N' ;
		    END IF;
		END IF;
	 END IF ;
     -- Country Equals
     WHEN 3
     THEN
        -- Only one user specified country
        IF ( instrb(p_user_spec_cond_val,',') = 0 )
        THEN
            IF ( get_gbl_condition_rec_value('PARTY_SITES', 'COUNTRY') = p_user_spec_cond_val )
            THEN
		          return 'Y' ;
	        ELSE
	              return 'N' ;
	        END IF ;
        -- Range of user specified countries
        ELSE
            country_str := get_gbl_condition_rec_value('PARTY_SITES', 'COUNTRY');

            adjusted_user_val := replace(p_user_spec_cond_val,',',''',''');

            adjusted_user_val :=  ''''||adjusted_user_val||'''';

            ----dbmsput.put_line(adjusted_user_val);

            sql_str := 'select ''Y'' from dual where ''' ||country_str ||''' IN ('||adjusted_user_val||')';

            ----dbmsput.put_line(sql_str);

            begin

            EXECUTE IMMEDIATE sql_str into result_str  ;

            ----dbmsput.put_line('result_str is ' || result_str );


            EXCEPTION
            WHEN OTHERS THEN
                 result_str := 'N';
            end ;

           return result_str ;


        END IF ;
          -- Country Equals
     WHEN 4
     THEN
        -- Only one user specified country
        IF ( instrb(p_user_spec_cond_val,',') = 0 )
        THEN
            IF ( get_gbl_condition_rec_value('PARTY_SITES', 'COUNTRY') <> p_user_spec_cond_val )
            THEN
		          return 'Y' ;
	        ELSE
	              return 'N'  ;
	        END IF ;
        -- Range of user specified countries
        ELSE
            country_str := get_gbl_condition_rec_value('PARTY_SITES', 'COUNTRY');

            adjusted_user_val := replace(p_user_spec_cond_val,',',''',''');

            adjusted_user_val :=  ''''||adjusted_user_val||'''';

            ----dbmsput.put_line(adjusted_user_val);

            sql_str := 'select ''Y'' from dual where ''' ||country_str ||''' NOT IN ('||adjusted_user_val||')';

            ------dbmsput.put_line(sql_str);

            begin

            EXECUTE IMMEDIATE sql_str into result_str  ;

            ----dbmsput.put_line('result_str is ' || result_str );


            EXCEPTION
            WHEN OTHERS THEN
                 result_str := 'N';
            end ;

            return result_str ;


        END IF ;

     -- If we get to this part of the CASE, we return an 'N' instead of erroring out
     ELSE
           return 'N' ;
  END CASE;

END ;

/*** This will be used to determine if this attribute is a condition attribute ***/
FUNCTION is_a_cond_attrib (p_attribute_id  IN  NUMBER )
RETURN BOOLEAN
IS
BEGIN

FOR att_cur in
    (select condition_id
     from hz_word_rpl_cond_attribs
     where assoc_cond_attrib_id = p_attribute_id
     and rownum < 2
     )
    LOOP

       return TRUE ;

    END LOOP ;

 return FALSE ;
END ;




/*** This will be used by search/staging  to populate the global condition record ***/
PROCEDURE set_gbl_condition_rec (p_attribute_id  IN  NUMBER, p_attribute_value IN VARCHAR2)
IS
BEGIN
  gbl_condition_rec(p_attribute_id) := p_attribute_value ;
END ;

/*** This will be used to return the value of  condition record  *****/
FUNCTION get_gbl_condition_rec_value( p_entity IN VARCHAR2, p_attribute_name IN VARCHAR2 )
RETURN VARCHAR2
IS
BEGIN
    FOR att_cur in
    (select attribute_id
     from hz_trans_attributes_vl
     where attribute_name = p_attribute_name
     and entity_name = p_entity)
    LOOP
       -- In the get we need to be careful
       -- since the attribute id may not exists as part of the global record
       -- if either the match rule does not have the attribute as part of its definition
       -- or the user does not even pass criteria at that level ( for example an entire
       -- party site search list may be empty).

       IF gbl_condition_rec.EXISTS(att_cur.attribute_id)
       THEN
            return gbl_condition_rec(att_cur.attribute_id) ;
       ELSE
            return null ;
       END IF ;
    END LOOP ;
    return null ;
END ;

/********* This will be a wrapper on top of the condition function, that would be used by
           HZ_TRANS_PKG, so that the user does not have to modify HZ_TRANS_PKG directly.
           A user who wants to seed a new condition function would call the condition function
           in the ELSE section of case or modify it in a way he/she sees fit.
*****************/

FUNCTION evaluate_condition (
           p_input_str           IN VARCHAR2,
           p_token_str           IN VARCHAR2,
           p_repl_str            IN VARCHAR2,
           p_condition_id        IN NUMBER,
           p_user_spec_cond_val  IN VARCHAR2
         )
RETURN BOOLEAN IS
  result_str             VARCHAR2(1) ;
  user_defined_proc_name VARCHAR2(600);
  sql_str                VARCHAR2(2000);
BEGIN
  -- This will address seeded conditions for all conditions that we ship
  -- For these call the tca seeded condition function
  IF p_condition_id < 10000 THEN
    result_str := tca_eval_condition_rec(
                    p_input_str,
                    p_token_str,
                    p_repl_str,
                    p_condition_id,
                    p_user_spec_cond_val
	       		  ) ;
    IF result_str = 'Y' THEN
      return TRUE;
    ELSE
      return FALSE;
    END IF ;
    -- This section is reserved for calling the user defined condition function dynamically
  ELSE
    BEGIN
      SELECT condition_function INTO user_defined_proc_name
      FROM HZ_WORD_RPL_CONDS_B
      WHERE condition_id = p_condition_id ;

      -- Fix for Bug 5007558. Using bind variables for the dynamic procedure input parameters.
      --dbms_output.put_line('user_defined_proc_name is ' || user_defined_proc_name);
      sql_str := 'select HZ_WORD_CONDITIONS_PKG.'||user_defined_proc_name||'(:p_input_str,:p_token_str,:p_repl_str, :p_condition_id,:p_user_spec_cond_val) from dual' ;
      --dbms_output.put_line('SQL string is ' || sql_str);
      EXECUTE IMMEDIATE sql_str INTO result_str USING p_input_str, p_token_str, p_repl_str, p_condition_id, p_user_spec_cond_val;
      --dbms_output.put_line('result_str after execute immediate is ' || result_str);
    EXCEPTION WHEN OTHERS THEN
      --dbms_output.put_line('in the exception section');
      --dbms_output.put_line('SQLERRM is - '||sqlerrm);
      result_str := 'N' ;
    END ;

    IF result_str = 'Y' THEN
      return TRUE;
    ELSE
      return FALSE;
    END IF ;
  END IF ;

  EXCEPTION WHEN OTHERS THEN
    FND_MESSAGE.SET_NAME('AR', 'HZ_DQM_API_ERROR');
    FND_MESSAGE.SET_TOKEN('PROC' ,'tca_eval_condition_rec');
    FND_MESSAGE.SET_TOKEN('ERROR' , SQLERRM);
    FND_MSG_PUB.ADD;
    RAISE FND_API.G_EXC_ERROR;
  END ;
END ;

/
