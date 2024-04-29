--------------------------------------------------------
--  DDL for Package Body OKS_UTIL_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OKS_UTIL_PUB" AS
/* $Header: OKSUTPRB.pls 120.6.12010000.2 2009/07/06 12:19:24 cgopinee ship $ */

 PROCEDURE GET_VALUESET_ID(P_FLEXFIELD_NAME IN VARCHAR2,
			   P_CONTEXT IN  VARCHAR2 ,
                           P_SEG  IN  VARCHAR2 ,
	      	   	   X_VSID  OUT NOCOPY NUMBER,
			   X_FORMAT_TYPE  OUT NOCOPY VARCHAR2,
                           X_VALIDATION_TYPE OUT NOCOPY VARCHAR2)IS
FLEXFIELD FND_DFLEX.DFLEX_R;
FLEXINFO FND_DFLEX.DFLEX_DR;
TEST_REC FND_VSET.VALUESET_R;
X_VALUESETID NUMBER;
TEST_FREC FND_VSET.VALUESET_DR;
CONTEXTS FND_DFLEX.CONTEXTS_DR;
I BINARY_INTEGER;
J BINARY_INTEGER;
SEGMENTS FND_DFLEX.SEGMENTS_DR;
BEGIN
 FND_DFLEX.GET_FLEXFIELD('QP',P_FLEXFIELD_NAME,FLEXFIELD,FLEXINFO);
 FND_DFLEX.GET_CONTEXTS(FLEXFIELD,CONTEXTS);
 FND_DFLEX.GET_SEGMENTS(FND_DFLEX.MAKE_CONTEXT(FLEXFIELD,P_CONTEXT),SEGMENTS,TRUE);
FOR J IN 1..SEGMENTS.NSEGMENTS LOOP
  IF SEGMENTS.SEGMENT_NAME(J) = P_SEG THEN
    X_VALUESETID := SEGMENTS.VALUE_SET(J);
  END IF;
END LOOP;
 IF X_VALUESETID IS NOT NULL THEN
FND_VSET.GET_VALUESET(X_VALUESETID,TEST_REC,TEST_FREC);
X_VSID :=X_VALUESETID;
X_FORMAT_TYPE :=TEST_FREC.FORMAT_TYPE;
X_VALIDATION_TYPE :=TEST_REC.VALIDATION_TYPE;
ELSE
X_VSID :=NULL;
X_FORMAT_TYPE :='C';
X_VALIDATION_TYPE :=NULL;

END IF;
END GET_VALUESET_ID;

FUNCTION context_exists(p_context        VARCHAR2,
                          p_context_dr     fnd_dflex.contexts_dr,
                          p_context_r  OUT NOCOPY fnd_dflex.context_r   )  RETURN BOOLEAN IS
  BEGIN
    IF (p_context_dr.ncontexts > 0) THEN
      FOR i IN 1..p_context_dr.ncontexts LOOP
        IF (p_context = p_context_dr.context_code(i)
           AND p_context_dr.is_enabled(i) = TRUE) THEN
          p_context_r.context_code := p_context_dr.context_code(i);
          RETURN TRUE;
        END IF;
      END LOOP;
      RETURN FALSE;
    ELSE
      RETURN FALSE;
    END IF;
 END Context_exists;

FUNCTION segment_exists(p_segment_name    IN   VARCHAR2,
                          p_segments_dr     IN   fnd_dflex.segments_dr,
					 p_check_enabled   IN   BOOLEAN := TRUE,
                          p_value_set_id    OUT NOCOPY  NUMBER,
                          p_precedence      OUT NOCOPY  NUMBER)  RETURN BOOLEAN IS
  BEGIN
    IF (p_segments_dr.nsegments > 0) THEN
      FOR i IN 1..p_segments_dr.nsegments LOOP
        IF p_check_enabled  then
            IF (p_segments_dr.application_column_name(i) = p_segment_name) and
		        p_segments_dr.is_enabled(i) THEN  ---added bu svdeshmu as per renga/jay's request.
                  p_value_set_id := p_segments_dr.value_set(i);
                  p_precedence := p_segments_dr.sequence(i);
                  RETURN TRUE;
            END IF;
        ELSE
            IF p_segments_dr.application_column_name(i) = p_segment_name  THEN
                  p_value_set_id := p_segments_dr.value_set(i);
                  p_precedence := p_segments_dr.sequence(i);
                  RETURN TRUE;
            END IF;
        END IF;

      END LOOP;
      RETURN FALSE;
    ELSE
      RETURN FALSE;
    END IF;
 END segment_exists;

-- =======================================================================
-- Function  value_exists
--   funtion type   Private
--   Returns  BOOLEAN
--   out parameters : None
--  DESCRIPTION
--    Searches for value if it exists in the value set list populated by
--    get_valueset call.
-- =======================================================================


 FUNCTION  value_exists(p_vsid IN NUMBER,p_value IN VARCHAR2)  RETURN BOOLEAN IS
   v_vset    fnd_vset.valueset_r;
   v_fmt     fnd_vset.valueset_dr;
   v_found  BOOLEAN;
   v_row    NUMBER;
   v_value  fnd_vset.value_dr;
 BEGIN
   fnd_vset.get_valueset(p_vsid, v_vset, v_fmt);
   fnd_vset.get_value_init(v_vset, TRUE);
   fnd_vset.get_value(v_vset, v_row, v_found, v_value);

   WHILE(v_found) LOOP
      IF (v_value.value = p_value) THEN
        fnd_vset.get_value_end(v_vset);
        RETURN TRUE;
      END IF;
      fnd_vset.get_value(v_vset, v_row, v_found, v_value);
   END LOOP;
   fnd_vset.get_value_end(v_vset);
   RETURN FALSE;
 END value_exists;


-- =======================================================================
-- Function  validate_num_date
--   funtion type   public
--   Returns  number
--   out parameters :
--  DESCRIPTION
--
--
-- =======================================================================

Function validate_num_date(p_datatype in varchar2
					   ,p_value in varchar2
					   )return number IS

x_error_code    NUMBER:= 0;
l_date       DATE;
l_number     NUMBER;
BEGIN
     IF p_datatype = 'N' THEN
	    l_number := fnd_number.canonical_to_number(p_value);
	 ELSIF p_datatype IN ('X', 'Y')  THEN
	    --l_date   := fnd_date.canonical_to_date(p_value);
	    l_date   := to_date(p_value,'FXYYYY/MM/DD HH24:MI:SS');
      END IF;
	 RETURN x_error_code;

EXCEPTION
      WHEN OTHERS THEN
		x_error_code := 9;
		RETURN x_error_code;
END validate_num_date;


/*********** Procedure to validate Flexfield **************/
PROCEDURE validate_oks_flexfield(flexfield_name         IN          VARCHAR2,
                                 context                IN          VARCHAR2,
                                 attribute              IN          VARCHAR2,
                                 value                  IN          VARCHAR2,
                                 application_short_name IN          VARCHAR2,
                                 context_flag           OUT NOCOPY  VARCHAR2,
                                 attribute_flag         OUT NOCOPY  VARCHAR2,
                                 value_flag             OUT NOCOPY  VARCHAR2,
                                 datatype               OUT NOCOPY  VARCHAR2,
                                 precedence   	        OUT NOCOPY  VARCHAR2,
                                 error_code    	        OUT NOCOPY  NUMBER ,
                                 check_enabled          IN          BOOLEAN := TRUE) IS

    CURSOR Cur_get_application_id(app_short_name VARCHAR2) IS
      SELECT application_id
      FROM   fnd_application
      WHERE  application_short_name = app_short_name;

    v_context_dr     fnd_dflex.contexts_dr;
    v_dflex_r        fnd_dflex.dflex_r;
    v_context_r      fnd_dflex.context_r;
    v_segments_dr    fnd_dflex.segments_dr;
    v_value_set_id   NUMBER;
    v_precedence     NUMBER;
    v_valueset_r     fnd_vset.valueset_r;
    v_format_dr      fnd_vset.valueset_dr;
    v_valueset_dr    fnd_vset.valueset_dr;
    v_dflex_dr       fnd_dflex.dflex_dr;
    v_flexfield_val_ind NUMBER DEFAULT 0;
    l_value 		VARCHAR2(150);
    l_id 		VARCHAR2(150);
  BEGIN
    context_flag  := 'N';
    attribute_flag := 'N';
    value_flag     := 'N';
    error_code     := 0;
    IF (flexfield_name IS NULL) THEN
      error_code := 1;  -- flexfield_name is not passed.
      RETURN;
    END IF;
    IF (context IS NULL) THEN
      error_code := 2;
      RETURN; -- context value is not passed
    END IF;
    IF (attribute IS NULL) THEN
       error_code := 3;
       RETURN;  -- attribute value is not passed.
    END IF;
    IF (value IS NULL) THEN
      error_code := 4;  -- value is not passed
      RETURN;
    END IF;
    IF (application_short_name IS NULL) THEN
      error_code := 5;  -- application short name is not passed
      RETURN;
    END IF;

    -- Get the application_id

    OPEN Cur_get_application_id(application_short_name);
    FETCH Cur_get_application_id INTO v_dflex_r.application_id;
    IF (Cur_get_application_id%NOTFOUND) THEN
      CLOSE Cur_get_application_id;
      error_code := 6;  -- Invalid application short name.
      RETURN;
    END IF;
    CLOSE Cur_get_application_id;

     -- check if flexfield name passed is a valid one or not.
     v_flexfield_val_ind:= 1;
     fnd_dflex.get_flexfield(application_short_name,flexfield_name,v_dflex_r,v_dflex_dr);

     -- Get the context listing for the flexfield
     fnd_dflex.get_contexts(v_dflex_r,v_context_dr);

     IF (context_exists(context,v_context_dr,v_context_r) = TRUE) THEN
         context_flag := 'Y';
     ELSE
        context_flag := 'N';
        error_code := 7;  -- Invalid context passed
       RETURN;
     END IF;

     v_context_r.flexfield := v_dflex_r;

     -- Get the enabled segments for the context selected.

    --fnd_dflex.get_segments(v_context_r,v_segments_dr,TRUE);
    fnd_dflex.get_segments(v_context_r,v_segments_dr,FALSE);

    IF (segment_exists(attribute,v_segments_dr,check_enabled,v_value_set_id,v_precedence) = TRUE) THEN
      IF (v_precedence IS NOT NULL) THEN
        precedence := v_precedence;
      END IF;
      attribute_flag := 'Y';
      IF (v_value_set_id IS NULL) THEN
        datatype := 'C';
        value_flag := 'Y';  -- If there is no valueset attached then just pass the validation.
        error_code := 0;
        RETURN;
      END IF;
    ELSE
      attribute_flag :='N';
      error_code := 8;   -- Invalid segment passed
      RETURN;
    END IF;

    -- Get value set information and validate the value passed.
    fnd_vset.get_valueset(v_value_set_id,v_valueset_r,v_valueset_dr);

    datatype := v_valueset_dr.format_type;

    -- check if there is any value set attached to the segment
    IF (v_value_set_id IS NULL or not g_validate_flag) THEN
      error_code := 0;
      value_flag := 'Y';
      RETURN;
    END IF;
    -- If Validation type is independent

    IF (v_valueset_r.validation_type = 'I') THEN
      IF (value_exists(v_value_set_id,value) = TRUE) THEN
        value_flag := 'Y';
        error_code := 0;   -- successfull
        RETURN;
      ELSE
        value_flag := 'N';
        error_code := 9;  -- Value does not exist.
      END IF;
    ELSIF (v_valueset_r.validation_type = 'F') THEN
      IF (value_exists_in_table(v_valueset_r.table_info,value,l_id,l_value) = TRUE) THEN
        value_flag := 'Y';
        error_code := 0;  -- Successfull
      ELSE
        value_flag := 'N';
        error_code := 9;  -- Value does not exist.
        RETURN;
      END IF;
    ELSIF (v_valueset_r.validation_type = 'N') or datatype in( 'N','X','Y') THEN
        --value_flag := 'Y';
        --error_code := 0;

     ---added for proper handling of dates/number in multilingual envs.
	---uncomment whenever needed(svdeshmu)
      error_code := validate_num_date(datatype,value);
	 If error_code = 0 then
       value_flag := 'Y';
	 else
       value_flag := 'N';
      End if;
    END IF;
  EXCEPTION
    WHEN NO_DATA_FOUND THEN
      IF (v_flexfield_val_ind = 1) THEN
        error_code := 10;
        RETURN;
      END IF;
  END  validate_oks_flexfield;

PROCEDURE GET_PROD_FLEX_PROPERTIES( PRIC_ATTRIBUTE_CONTEXT  IN VARCHAR2,
                                    PRIC_ATTRIBUTE  IN         VARCHAR2,
                                    PRIC_ATTR_VALUE IN         VARCHAR2,
                                    X_DATATYPE      OUT NOCOPY VARCHAR2,
                                    X_PRECEDENCE    OUT NOCOPY NUMBER,
                                    X_ERROR_CODE    OUT NOCOPY NUMBER)
IS

L_CONTEXT_FLAG                VARCHAR2(1);
L_ATTRIBUTE_FLAG              VARCHAR2(1);
L_VALUE_FLAG                  VARCHAR2(1);
L_DATATYPE                    VARCHAR2(1);
L_PRECEDENCE                  NUMBER;
L_ERROR_CODE                  NUMBER := 0;

BEGIN

    OKS_UTIL_PUB.VALIDATE_OKS_FLEXFIELD(FLEXFIELD_NAME         =>'QP_ATTR_DEFNS_PRICING'
			 ,CONTEXT                        =>PRIC_ATTRIBUTE_CONTEXT
			 ,ATTRIBUTE                      =>PRIC_ATTRIBUTE
			 ,VALUE                          =>PRIC_ATTR_VALUE
                ,APPLICATION_SHORT_NAME         => 'QP'
    			 ,CHECK_ENABLED			   =>FALSE
			 ,CONTEXT_FLAG                   =>L_CONTEXT_FLAG
			 ,ATTRIBUTE_FLAG                 =>L_ATTRIBUTE_FLAG
			 ,VALUE_FLAG                     =>L_VALUE_FLAG
			 ,DATATYPE                       =>L_DATATYPE
			 ,PRECEDENCE                      =>L_PRECEDENCE
			 ,ERROR_CODE                     =>L_ERROR_CODE
			 );

		X_DATATYPE := NVL(L_DATATYPE,'C');
		X_PRECEDENCE := NVL(L_PRECEDENCE,5000);

END GET_PROD_FLEX_PROPERTIES;


FUNCTION value_exists_in_table(p_table_r  fnd_vset.table_r,
                                 p_value    VARCHAR2,
						   x_id    OUT NOCOPY VARCHAR2,
						   x_value OUT NOCOPY VARCHAR2) RETURN BOOLEAN IS

    v_selectstmt   VARCHAR2(500) ;
    v_cursor_id    INTEGER;
    v_value        VARCHAR2(150);
    v_meaning	    VARCHAR2(240);
    v_id           VARCHAR2(150);
    v_retval       INTEGER;
    v_where_clause fnd_flex_validation_tables.additional_where_clause%type;
    v_cols	    VARCHAR2(1000);

  BEGIN
     v_cursor_id := DBMS_SQL.OPEN_CURSOR;

	if instr(upper(p_table_r.where_clause),'WHERE ') > 0 then
	--to include the id column name in the query

--included extra quotes for comparing varchar and num values in select
     v_where_clause := replace(UPPER(p_table_r.where_clause)
			,'WHERE '
			,'WHERE '||p_table_r.id_column_name||' = '''||p_value||''' AND ');

	else

	v_where_clause := 'WHERE '||p_table_r.id_column_name||' = '''||p_value||''' '||UPPER(p_table_r.where_clause);

	end if;

	v_cols := p_table_r.value_column_name;

-------------------
--changes made by spgopal for performance problem
--added out parameters to pass back id and value for given valueset id
-------------------

   IF (p_table_r.id_column_name IS NOT NULL) THEN

--
-- to_char() conversion function is defined only for
-- DATE and NUMBER datatypes.
--
	IF (p_table_r.id_column_type IN ('D', 'N')) THEN
																		v_cols := v_cols || ' , To_char(' || p_table_r.id_column_name || ')';
	ELSE
		v_cols := v_cols || ' , ' || p_table_r.id_column_name;
	END IF;
   ELSE
	v_cols := v_cols || ', NULL ';
   END IF;



       v_selectstmt := 'SELECT  '||v_cols||' FROM  '||p_table_r.table_name||' '||v_where_clause;

	  oe_debug_pub.add('select stmt'||v_selectstmt);

------------------

/*
	IF p_table_r.id_column_name is not null then

       v_selectstmt := 'SELECT  '||p_table_r.id_column_name||' FROM  '||p_table_r.table_name||' '||v_where_clause;

    ELSE

     v_selectstmt := 'SELECT  '||p_table_r.value_column_name||' FROM  '||p_table_r.table_name||' '||p_table_r.where_clause;

    END IF;
*/

    -- parse the query

     DBMS_SQL.PARSE(v_cursor_id,v_selectstmt,DBMS_SQL.V7);
	    oe_debug_pub.add('after parse');
     -- Bind the input variables
     DBMS_SQL.DEFINE_COLUMN(v_cursor_id,1,v_value,150);
     DBMS_SQL.DEFINE_COLUMN(v_cursor_id,2,v_id,150);
     v_retval := DBMS_SQL.EXECUTE(v_cursor_id);
     LOOP
       -- Fetch rows in to buffer and check the exit condition from  the loop
       IF( DBMS_SQL.FETCH_ROWS(v_cursor_id) = 0) THEN
          EXIT;
       END IF;
       -- Retrieve the rows from buffer into PLSQL variables
       DBMS_SQL.COLUMN_VALUE(v_cursor_id,1,v_value);
       DBMS_SQL.COLUMN_VALUE(v_cursor_id,2,v_id);


       IF v_id IS NULL AND (p_value = v_value) THEN
	    oe_debug_pub.add('id null, passing value'||p_value||','||v_value);
         DBMS_SQL.CLOSE_CURSOR(v_cursor_id);
	    x_id := v_id;
	    x_value := v_value;
         RETURN TRUE;
	  ELSIF (p_value = v_id) THEN
	    oe_debug_pub.add('id exists, passing id'||p_value||','||v_id);
         DBMS_SQL.CLOSE_CURSOR(v_cursor_id);
	    x_id := v_id;
	    x_value := v_value;
         RETURN TRUE;
	  ELSE
		Null;
	    oe_debug_pub.add('value does notmatch, continue search'||p_value||','||v_id);
       END IF;
    END LOOP;
    DBMS_SQL.CLOSE_CURSOR(v_cursor_id);
    RETURN FALSE;
 EXCEPTION
   WHEN OTHERS THEN

     DBMS_SQL.CLOSE_CURSOR(v_cursor_id);
     RETURN FALSE;
 END value_exists_in_table;

FUNCTION Get_OKS_Status RETURN VARCHAR2 IS

  l_status      VARCHAR2(1);
  l_industry    VARCHAR2(1);
  l_application_id       NUMBER := 661;
  l_retval      BOOLEAN;
  BEGIN


  IF G_PRODUCT_STATUS = FND_API.G_MISS_CHAR THEN

   l_retval := fnd_installation.get(l_application_id,l_application_id,
      						 l_status,l_industry);

        -- if l_status = 'I', OKS is fully installed. Advanced pricing functionalities
	   -- should be available.
        --if  l_status = 'S', OKS is shared ie Basic OKS is Installed.Only basic
        --pricing functionality should be available.
	   --if l_status = 'N', -- OKS not installled

   G_PRODUCT_STATUS := l_status;

  END IF;

   return G_PRODUCT_STATUS;

 END Get_OKS_Status;

FUNCTION Resp_Org_id RETURN NUMBER IS
Begin
 If fnd_profile.value('OKC_VIEW_K_BY_ORG') = 'Y' then
    return fnd_profile.value('ORG_ID');
 Else
    return null;
 End If;
End Resp_Org_id;

PROCEDURE UPDATE_CONTACTS_SALESGROUP
   ( ERRBUF            OUT      NOCOPY VARCHAR2,
     RETCODE           OUT      NOCOPY NUMBER,
     P_CONTRACT_ID     IN              NUMBER,
     P_GROUP_ID        IN              NUMBER)
   IS
--

  ---------------------------
  -- cursors to select contracts for given contract number
  -- and group
  ---------------------------
  --CP_CONTRACT_ID is not null
  --cp_group_id is not null
  CURSOR CONTRACT_HDR_1(cp_contract_id NUMBER
                       ,cp_group_id NUMBER)
  IS
  SELECT  hdr.id hdr_id, authoring_org_id org_id
  FROM    okc_k_headers_b hdr
  WHERE Hdr.scs_code in ('SERVICE', 'WARRANTY','SUBSCRIPTION')
  AND   Hdr.Template_yn = 'N'
  AND   exists (Select 'x' from OKC_K_GRPINGS  okg
              Where  okg.included_chr_id = hdr.id
              And    okg.cgp_parent_id= cp_group_id)
  AND   Hdr.id = CP_CONTRACT_ID;


  --CP_CONTRACT_ID is not null
  --cp_group_id is  null
  CURSOR CONTRACT_HDR_2(cp_contract_id NUMBER)
  IS
  SELECT  hdr.id hdr_id, authoring_org_id org_id
  FROM    okc_k_headers_b hdr
  WHERE Hdr.scs_code in ('SERVICE', 'WARRANTY','SUBSCRIPTION')
  AND   Hdr.Template_yn = 'N'
  AND   Hdr.id = CP_CONTRACT_ID;


  --CP_CONTRACT_ID is null
  --cp_group_id is  not null
  CURSOR CONTRACT_HDR_3(cp_group_id NUMBER)
  IS
  SELECT  hdr.id hdr_id, authoring_org_id org_id
  FROM    okc_k_headers_b hdr
  WHERE Hdr.scs_code in ('SERVICE', 'WARRANTY','SUBSCRIPTION')
  AND   Hdr.Template_yn = 'N'
  AND   exists (Select 'x' from OKC_K_GRPINGS  okg
              Where  okg.included_chr_id = hdr.id
              And    okg.cgp_parent_id= cp_group_id);

  --CP_CONTRACT_ID is null
  --cp_group_id is  null

  CURSOR CONTRACT_HDR_4
  IS
  SELECT  /*+ PARALLEL(HDR) */ hdr.id hdr_id, authoring_org_id org_id
  FROM    okc_k_headers_b HDR
  WHERE Hdr.scs_code in ('SERVICE', 'WARRANTY','SUBSCRIPTION')
  AND   Hdr.Template_yn =  'N';

  ----------------------------
  -- cursor to select vendor contacts salesrep
  ----------------------------
  CURSOR contacts_cur (cp_contract_id IN NUMBER)
  IS
  SELECT id , object1_id1 ,object1_id2, cpl_id, cro_code , start_date, last_update_date
  FROM  OKC_CONTACTS
  WHERE dnz_chr_id = cp_contract_id
  AND   jtot_object1_code   = 'OKX_SALEPERS'
 -- and cro_code = 'SALESPERSON' -- changed for bug#3564073
  AND   sales_group_id IS NULL;

  ---------------------------
  l_api_version     NUMBER := 1.0;
  l_init_msg_list   VARCHAR2(1) := OKC_API.G_FALSE;
  l_return_status   VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
  l_msg_count       NUMBER;
  l_msg_data        VARCHAR2(2000);
  l_ctcv_tbl_in   okc_contract_party_pub.ctcv_tbl_type;
  l_ctcv_tbl_out  okc_contract_party_pub.ctcv_tbl_type;

  l_hdr_rec       CONTRACT_HDR_1%rowtype;

  l_salesgrp_id   Number;
  l_org_id        NUmber;
  l_index        NUmber;


BEGIN
  OKC_CONTEXT.SET_OKC_ORG_CONTEXT;
  l_org_id := OKC_CONTEXT.GET_OKC_ORG_ID;

  FND_FILE.PUT_LINE(FND_FILE.LOG, 'Inside Upadte contacts salesgroup ='||to_char(p_contract_id));

    IF (p_contract_id is NOT NULL) AND (p_group_id is NOT NULL) THEN
      OPEN contract_hdr_1(p_contract_id,p_group_id);

    ELSIF (p_contract_id is  NULL) AND (p_group_id is  NULL) THEN
      OPEN contract_hdr_4;

    ELSIF (p_contract_id is NOT NULL) AND (p_group_id is  NULL) THEN
      OPEN contract_hdr_2(p_contract_id);


    ELSIF (p_contract_id is  NULL) AND (p_group_id is NOT NULL) THEN
      OPEN contract_hdr_3(p_group_id);

    END IF;

    LOOP
      IF contract_hdr_1%ISOPEN then
        FETCH     contract_hdr_1 INTO l_hdr_rec  ;
        EXIT WHEN contract_hdr_1%NOTFOUND ;
      ELSIF contract_hdr_2%ISOPEN then
        FETCH     contract_hdr_2 INTO l_hdr_rec  ;
        EXIT WHEN contract_hdr_2%NOTFOUND ;
      ELSIF contract_hdr_3%ISOPEN then
        FETCH     contract_hdr_3 INTO l_hdr_rec  ;
        EXIT WHEN contract_hdr_3%NOTFOUND ;
      ELSIF contract_hdr_4%ISOPEN then
        FETCH     contract_hdr_4 INTO l_hdr_rec  ;
        EXIT WHEN contract_hdr_4%NOTFOUND ;
      END IF ;

      -- set okc contex
      OKC_CONTEXT.SET_OKC_ORG_CONTEXT(p_chr_id => l_hdr_rec.hdr_id);

      for contacts_rec in contacts_cur(cp_contract_id => l_hdr_rec.hdr_id)
      loop
                FND_FILE.PUT_LINE(FND_FILE.LOG, 'Contract ID ='||l_hdr_rec.hdr_id);
                FND_FILE.PUT_LINE(FND_FILE.LOG, 'contact ='||contacts_rec.object1_id1);
        l_salesgrp_id := jtf_rs_integration_pub.get_default_sales_group
                       				         (p_salesrep_id => contacts_rec.object1_id1,
                       				          p_org_id      => l_hdr_rec.org_id,
                            			      p_date        => nvl(contacts_rec.start_date,contacts_rec.last_update_date)); -- sysdate replaced for DBI change request.

                                                FND_FILE.PUT_LINE(FND_FILE.LOG, 'defaultsalesgroup ='||to_char(l_salesgrp_id));

        l_ctcv_tbl_in(1).id := contacts_rec.id;
        l_ctcv_tbl_in(1).dnz_chr_id := l_hdr_rec.hdr_id;
        l_ctcv_tbl_in(1).object_version_number := okc_api.g_miss_NUM;
        l_ctcv_tbl_in(1).cpl_id            :=  contacts_rec.cpl_id;
        l_ctcv_tbl_in(1).cro_code          :=  contacts_rec.cro_code;
        l_ctcv_tbl_in(1).object1_id1 := contacts_rec.object1_id1;
        l_ctcv_tbl_in(1).object1_id2 := '#';
        l_ctcv_tbl_in(1).sales_group_id := l_salesgrp_id;

        okc_contract_party_pub.update_contact (
              p_api_version => l_api_version,
              p_init_msg_list => l_init_msg_list,
              x_return_status => l_return_status,
              x_msg_count => l_msg_count,
              x_msg_data => l_msg_data,
              p_ctcv_tbl => l_ctcv_tbl_in,
              x_ctcv_tbl => l_ctcv_tbl_out );


              FND_FILE.PUT_LINE(FND_FILE.LOG, 'return status ='||l_return_status);

         IF (l_return_status <> OKC_API.G_RET_STS_SUCCESS) THEN
           FOR i in 1..fnd_msg_pub.count_msg
           Loop
             fnd_msg_pub.get
                         (p_msg_index        => i,
                         p_encoded           => 'F',
                         p_data                 => l_msg_data,
                         p_msg_index_out => l_index
                         );
              FND_FILE.PUT_LINE(FND_FILE.LOG, 'error from okc_API ='||l_msg_data);
           End Loop;
	   l_return_status := l_return_status;
          -- commented out since program should continue even there is error.05/25/04
          -- RAISE G_EXCEPTION_HALT_VALIDATION;
         END IF;
       end loop;
      end loop;

      IF contract_hdr_1%ISOPEN THEN
        CLOSE contract_hdr_1;
      ELSIF contract_hdr_2%ISOPEN THEN
        CLOSE contract_hdr_2;
      ELSIF contract_hdr_3%ISOPEN THEN
        CLOSE contract_hdr_3;
      ELSIF contract_hdr_4%ISOPEN THEN
        CLOSE contract_hdr_4;
      END IF;

 EXCEPTION
    WHEN G_EXCEPTION_HALT_VALIDATION THEN
      NULL;
    WHEN OTHERS THEN
      -- store SQL error message on message stack for caller
      OKC_API.set_message(G_APP_NAME, G_UNEXPECTED_ERROR,G_SQLCODE_TOKEN,SQLCODE,G_SQLERRM_TOKEN,SQLERRM);
      -- notify caller of an UNEXPECTED error
      l_return_status := OKC_API.G_RET_STS_UNEXP_ERROR;
END update_contacts_salesgroup; -- Procedure

-- ===========================================================================
-- Function get_line_name
-- Input Parameters:
--   p_lty_code    : Line Type Code (lty_code from okc_line_styles_b)
--   p_object1_id1 : Object Id 1 (object1_id1 from okc_k_items)
--   p_object1_id2 : Object Id 2 (object1_id2 from okc_k_items)
-- Return Value:
--   Name of the line item (VARCHAR2)
-- This function returns the name of a covered level
-- with one of the line types:
--      COVER_CUST, COVER_ITEM, COVER_PROD, COVER_PTY,
--      COVER_SITE, COVER_SYS, INST_CTR
-- The Function doesn't validate the input.
-- For invalid inputs the function returns NULL.
-- The parameter p_object1_id2 is ignored for all line types except COVER_ITEM
-- This function can be extended to accept other line types
-- including top lines, in the future
-- Created: JAKURUVI 08/12/2005
-- Modified: JAKURUVI 03/13/2006: Changed parameter p_lse_id to p_lty_code
-- ===========================================================================
  FUNCTION get_line_name( p_lty_code IN VARCHAR2,
                          p_object1_id1 IN VARCHAR2,
                          p_object1_id2 IN VARCHAR2 ) RETURN VARCHAR2 IS
    -- Covered Items
    CURSOR itemcur IS
    SELECT concatenated_segments name
    FROM mtl_system_items_b_kfv
    WHERE inventory_item_id = to_number(p_object1_id1)
      and organization_id = to_number(p_object1_id2);

    -- Covered Products
    CURSOR prodcur IS
    SELECT concatenated_segments name
    FROM mtl_system_items_b_kfv mtl,
         csi_item_instances csi
    WHERE mtl.inventory_item_id = csi.inventory_item_id
      AND mtl.organization_id = csi.inv_master_organization_id
      AND csi.instance_id = to_number(p_object1_id1);

    -- Covered Parties
    CURSOR partycur IS
    SELECT party_name name
    FROM hz_parties
    WHERE party_id = to_number(p_object1_id1);

    -- Covered Sites
    CURSOR sitecur IS
    SELECT party_site_number||'-'||party_site_name name
    FROM hz_party_sites p
    WHERE party_site_id = to_number(p_object1_id1);

    -- Covered Systems
    CURSOR systemcur IS
    SELECT name
    FROM csi_systems_tl csi
    WHERE csi.system_id = to_number(p_object1_id1)
      AND csi.language = USERENV('LANG');

    -- Covered Customer Accounts
    CURSOR customercur IS
    SELECT NVL(ca.account_name, p.party_name) name
    FROM hz_cust_accounts ca,
         hz_parties p
    WHERE ca.party_id = p.party_id
      AND ca.cust_account_id = to_number(p_object1_id1);

    -- Usage Items(Counters)
    CURSOR ctrtypecur IS
    SELECT source_object_code, source_object_id
    FROM csi_counter_associations csi
    WHERE csi.counter_id = to_number(p_object1_id1);
    -- Covered Product Counters
    CURSOR cpctrcur(p_instance_id IN NUMBER) IS
    SELECT concatenated_segments name
    FROM mtl_system_items_b_kfv mtl,
         csi_item_instances csi
    WHERE mtl.inventory_item_id = csi.inventory_item_id
      AND mtl.organization_id = csi.inv_master_organization_id
      AND csi.instance_id = p_instance_id;
    -- Service Counters
    CURSOR svcctrcur(p_line_id IN NUMBER) IS
    SELECT concatenated_segments name
    FROM mtl_system_items_b_kfv mtl,
         okc_k_items item
    WHERE mtl.inventory_item_id = to_number(item.object1_id1)
      AND mtl.organization_id = to_number(item.object1_id2)
      AND item.cle_id = p_line_id;

  BEGIN
    IF p_lty_code = 'COVER_ITEM'   THEN --  Item
      FOR itemrec IN itemcur LOOP
        RETURN itemrec.name;
      END LOOP;
    ELSIF p_lty_code = 'COVER_PTY' THEN -- Party
      FOR partyrec IN partycur LOOP
        RETURN partyrec.name;
      END LOOP;
    ELSIF p_lty_code = 'COVER_PROD' THEN -- Product
      FOR prodrec IN prodcur LOOP
        RETURN prodrec.name;
      END LOOP;
    ELSIF p_lty_code = 'COVER_SITE' THEN -- Site
      FOR siterec IN sitecur LOOP
        RETURN siterec.name;
      END LOOP;
    ELSIF p_lty_code = 'COVER_SYS' THEN -- System
      FOR systemrec IN systemcur LOOP
        RETURN systemrec.name;
      END LOOP;
    ELSIF p_lty_code = 'COVER_CUST' THEN -- Customer
      FOR customerrec IN customercur LOOP
        RETURN customerrec.name;
      END LOOP;
    ELSIF p_lty_code = 'INST_CTR' THEN -- Usage Item(Counter)
      FOR ctrtyperec IN ctrtypecur LOOP
        IF ctrtyperec.source_object_code = 'CP' THEN -- Covered Product Counter
          FOR cpctrrec IN cpctrcur(ctrtyperec.source_object_id) LOOP
            RETURN cpctrrec.name;
          END LOOP;
        ELSIF ctrtyperec.source_object_code = 'CONTRACT_LINE' THEN -- Service Counter
          FOR svcctrrec IN svcctrcur(ctrtyperec.source_object_id) LOOP
            RETURN svcctrrec.name;
          END LOOP;
        END IF;
      END LOOP;
    END IF;
    RETURN NULL;
  EXCEPTION when OTHERS THEN
    RETURN NULL;
  END get_line_name;

  -- This function is an overloaded wrapper to the above function
  -- To be used if only the line id is known
  FUNCTION get_line_name( p_subline_id IN NUMBER ) RETURN VARCHAR2 IS
    CURSOR sublinecur IS
    SELECT lse.lty_code, item.object1_id1, item.object1_id2
    FROM okc_k_lines_b sle, okc_k_items item, okc_line_styles_b lse
    WHERE item.cle_id = sle.id
      AND lse.id = sle.lse_id
      AND sle.id = p_subline_id;
    l_name VARCHAR2(200);
  BEGIN
    FOR sublinerec IN sublinecur LOOP
      l_name := get_line_name
                   ( p_lty_code    => sublinerec.lty_code,
                     p_object1_id1 => sublinerec.object1_id1,
                     p_object1_id2 => sublinerec.object1_id2
                   );
      EXIT;
    END LOOP;
    RETURN l_name;
  EXCEPTION when OTHERS THEN
    RETURN NULL;
  END get_line_name;

-------
Procedure create_transaction_extension(P_Api_Version IN NUMBER
				      ,P_Init_Msg_List IN VARCHAR2
				      ,P_Header_ID IN NUMBER
				      ,P_Line_ID IN NUMBER
				      ,P_Source_Trx_Ext_ID IN NUMBER
				      ,P_Cust_Acct_ID IN NUMBER
		                      ,P_Bill_To_Site_Use_ID IN NUMBER
				      ,x_entity_id OUT NOCOPY NUMBER
				      ,x_msg_data OUT NOCOPY VARCHAR2
				      ,x_msg_count OUT NOCOPY NUMBER
				      ,x_return_status OUT NOCOPY VARCHAR2) IS

 l_api_name        CONSTANT VARCHAR2(30) := 'create_transaction_extension';
 l_module_name     VARCHAR2(256) := G_APP_NAME || '.plsql.' || G_PKG_NAME || '.' || l_api_name;

--Input parameters--
l_PayerContext_Rec	    IBY_FNDCPT_COMMON_PUB.PayerContext_rec_type;
l_Payer_Equivalency	    VARCHAR2(20);
l_Pmt_channel		    VARCHAR2(20);
l_instr_assignment	    NUMBER;
l_TrxnExtension_rec         IBY_FNDCPT_TRXN_PUB.TrxnExtension_rec_type;
l_ext_entity_tab        IBY_FNDCPT_COMMON_PUB.Id_tbl_type; --Used by copy_transaction_extension


--Output parameters--
l_response		    IBY_FNDCPT_COMMON_PUB.Result_rec_type;
l_entity_id		    NUMBER;

--Local Variables--
l_Authoring_Org_ID NUMBER;

l_Cust_Account_Site_ID NUMBER;
l_Cust_Account_ID	  NUMBER;
l_Party_ID	  NUMBER;

---Cursor to retrieve Account_Site_ID, Cust_Account_ID and Party_ID for Header
CURSOR GetAcctInfo IS
select
 cas.cust_account_id Cust_Account_ID
,ca.party_id Party_ID
from
 hz_cust_site_uses_all csu
,hz_cust_acct_sites_all cas
,hz_cust_accounts_all ca
where
csu.site_use_id = P_Bill_To_Site_Use_ID
and cas.cust_acct_site_id = csu.cust_acct_site_id
and ca.cust_account_id = cas.cust_account_id;

CURSOR GetCustAcctParty IS
select
 ca.party_id Party_ID
from
 hz_cust_accounts_all ca
where ca.cust_account_id = P_Cust_Acct_ID;

--Cursor to get Instrument_Assignment_ID
CURSOR GetInstrAssgnID IS
select
 instr_assignment_ID
/* Modified by cgopinee for PA DSS Enhancement */
/*,CARD_EXPIRYDATE */
 , card_expired_flag
from
IBY_TRXN_EXTENSIONS_V
where
trxn_extension_ID = P_Source_Trx_Ext_ID;

l_Instrument_Assignment_ID NUMBER;
/* Modified by cgopinee for PA DSS Enhancement */
/* l_CC_Expiry_Date	   DATE; */
l_CC_Expiry_Flag           VARCHAR2(10);

Begin
    l_ext_entity_tab.DELETE;
    l_ext_entity_tab(0) := P_Source_Trx_Ext_ID;

    IF (FND_LOG.level_procedure >= FND_LOG.g_current_runtime_level) THEN
      IF (FND_LOG.test(FND_LOG.level_procedure, l_module_name)) THEN
         FND_LOG.string(FND_LOG.level_procedure
                        ,l_module_name||'.Begin'
                        ,'P_Source_Trx_Ext_ID='||P_Source_Trx_Ext_ID
                       ||',P_Bill_To_Site_Use_ID='||P_Bill_To_Site_Use_ID
		       ||',P_Header_ID='||P_Header_ID
                       ||',P_Line_ID='||P_Line_ID
                         );
      END IF;
    END IF;

 OPEN GetInstrAssgnID;
 Fetch GetInstrAssgnID INTO l_Instrument_Assignment_ID,l_CC_Expiry_Flag;
 CLOSE GetInstrAssgnID;

 /* Modified by cgopinee for PA DSS Enhancement */
 /*
 IF ( to_number(to_char(l_CC_Expiry_Date,'YYYYMM')) <
     to_number(to_char(SYSDATE,'YYYYMM'))
   ) then*/

 IF NVL(l_CC_Expiry_Flag,'N') = 'Y'
 THEN
  x_entity_id := NULL;
  x_return_status := FND_API.G_RET_STS_SUCCESS;
 ELSE

 l_Authoring_Org_ID := okc_context.get_okc_org_id;
 l_Cust_Account_Site_ID := P_Bill_To_Site_Use_ID;

 IF (P_Cust_Acct_ID IS NULL) THEN
  OPEN GetAcctInfo;
  FETCH GetAcctInfo INTO
   l_Cust_Account_ID
  ,l_Party_ID;
  CLOSE GetAcctInfo;

 ELSIF (P_Cust_Acct_ID IS NOT NULL) THEN
  l_Cust_Account_ID := P_Cust_Acct_ID;

  OPEN GetCustAcctParty;
  FETCH GetCustAcctParty INTO l_Party_ID;
  CLOSE GetCustAcctParty;

 END IF;




 --Setting values for l_PayerContext_Rec--
-- l_PayerContext_Rec.Org_Type          := 'OPERATING_UNIT';
-- l_PayerContext_Rec.Org_Id            := l_Authoring_Org_ID;
-- l_PayerContext_Rec.Account_Site_Id   := l_Cust_Account_Site_ID;
 l_PayerContext_Rec.Payment_Function  := 'CUSTOMER_PAYMENT';
 l_PayerContext_Rec.Party_Id          := l_Party_ID;
 l_PayerContext_Rec.Cust_Account_Id   := l_Cust_Account_ID;

 --Setting values for l_TrxnExtension_rec--
 If (P_Header_ID IS NOT NULL and P_Line_ID IS NULL) then
  l_TrxnExtension_rec.order_id := P_Header_ID;
 Elsif (P_Header_ID IS NULL and P_Line_ID IS NOT NULL) then
  l_TrxnExtension_rec.order_id := P_Line_ID;
 End If;

 l_TrxnExtension_rec.originating_application_id := G_APP_ID;
 l_TrxnExtension_rec.Trxn_Ref_Number1 := to_char(SYSDATE,'ddmmyyyyhhmmssss');
-- hkamdar 17-Mar-2006 Commented for bug # 5095244. Equivalency of FULL needs to be passed when copying an
-- EXT WARR CONTRACT, CREATED FROM OM WITH CC INFO.
-- l_Payer_Equivalency := IBY_FNDCPT_COMMON_PUB.G_PAYER_EQUIV_UPWARD;
 l_Payer_Equivalency := IBY_FNDCPT_COMMON_PUB.G_PAYER_EQUIV_FULL;
-- End hkamdar for bug # 5095244
 l_Pmt_Channel      := 'CREDIT_CARD';
 l_instr_assignment := l_Instrument_Assignment_ID;

                IF (FND_LOG.level_statement >= FND_LOG.g_current_runtime_level) THEN
                 FND_LOG.string(FND_LOG.level_statement
                        ,l_module_name
                        ,'Org ID='||l_Authoring_Org_ID
		        ||'Party ID='||l_Party_ID
			||'Acct_Id ='||l_Cust_Account_ID
			||'Site_Id='||l_Cust_Account_Site_ID
                         );
                END IF;

     Begin

        IBY_FNDCPT_TRXN_PUB.Create_Transaction_Extension
                        (
                         p_api_version => P_api_version
			,p_init_msg_list => p_init_msg_list
			,p_commit => FND_API.G_FALSE
                        ,x_return_status => x_return_status
                        ,x_msg_count   => x_msg_count
                        ,x_msg_data    => x_msg_data
                        ,p_payer       => l_PayerContext_Rec
                        ,p_payer_equivalency => l_Payer_Equivalency
                        ,p_pmt_channel  => l_Pmt_channel
                        ,p_instr_assignment => l_instr_assignment
                        ,p_trxn_attribs     => l_TrxnExtension_rec
                        ,x_entity_id        => x_entity_id
                        ,x_response         => l_response
                         );

    /****
       IBY_FNDCPT_TRXN_PUB.Copy_Transaction_Extension
      (
       p_api_version        => p_api_version
      ,p_init_msg_list      => p_init_msg_list
      ,p_commit             => FND_API.G_FALSE
      ,x_return_status      => x_return_status
      ,x_msg_count          => x_msg_count
      ,x_msg_data           => x_msg_data
      ,p_payer              => l_PayerContext_Rec
      ,p_payer_equivalency  => l_Payer_Equivalency
      ,p_entities           => l_ext_entity_tab
      ,p_trxn_attribs       => l_TrxnExtension_rec
      ,x_entity_id          => x_entity_id
      ,x_response           => l_response
      );
    ****/



         IF (x_return_status = FND_API.g_ret_sts_unexp_error) THEN
           fnd_message.set_name (g_app_name, 'OKS_IBY_API_ERROR');
           fnd_message.set_token
                          ('IBY_API_NAME',
                           'IBY_FNDCPT_TRXN_PUB.Create_Transaction_Extension : '||l_response.result_code);
           fnd_message.set_token ('ERROR_DTLS', l_response.result_message);
           fnd_msg_pub.ADD;
           RAISE fnd_api.g_exc_unexpected_error;
         ELSIF (x_return_status = FND_API.g_ret_sts_error) THEN
           fnd_message.set_name (g_app_name, 'OKS_IBY_API_ERROR');
           fnd_message.set_token
                          ('IBY_API_NAME',
                           'IBY_FNDCPT_TRXN_PUB.Create_Transaction_Extension :'||l_response.result_code);
           fnd_message.set_token ('ERROR_DTLS', l_response.result_message);
           fnd_msg_pub.ADD;
           RAISE fnd_api.g_exc_error;
         END IF;




         IF (FND_LOG.level_statement >= FND_LOG.g_current_runtime_level) THEN
           FND_LOG.string(FND_LOG.level_statement
		        ,l_module_name
		        ,'After call to IBY_FNDCPT_TRXN_PUB.Create_Transaction_Extension'
			||',x_return_status='||x_return_status
			||',Result Code ='||l_response.result_code
			||',Result Category='||l_response.result_category
			||',Result Message='||l_response.result_message
                         );
         END IF;


         EXCEPTION
            WHEN OTHERS THEN
	        IF (FND_LOG.level_unexpected >= FND_LOG.g_current_runtime_level) THEN
                 FND_LOG.string(FND_LOG.level_unexpected
                        ,l_module_name||'.EXCEPTION'
                        ,'Exception in call to IBY_FNDCPT_TRXN_PUB.Create_Transaction_Extension, x_return_status ='||x_return_status
			 ||'SQLERRM ='||SQLERRM
                         );
                END IF;
          x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
          FND_MSG_PUB.add_exc_msg(g_pkg_name, 'IBY_FNDCPT_TRXN_PUB.Create_Transaction_Extension', substr(SQLERRM,1,240));
          RAISE;

    End;

 END IF; --End of IF Check for l_CC_Expiry_Date--------------------------------------

    IF (FND_LOG.level_procedure >= FND_LOG.g_current_runtime_level) THEN
      IF (FND_LOG.test(FND_LOG.level_procedure, l_module_name)) THEN
         FND_LOG.string(FND_LOG.level_procedure
                        ,l_module_name||'.End'
                        ,'x_return_status ='||x_return_status
                         );
      END IF;
    END IF;

         EXCEPTION
            WHEN OTHERS THEN
                IF (FND_LOG.level_unexpected >= FND_LOG.g_current_runtime_level) THEN
                 FND_LOG.string(FND_LOG.level_unexpected
                        ,l_module_name||'.EXCEPTION'
                        ,'General Exception in Create_Transaction_Exception, x_return_status ='||x_return_status
                         ||'SQLERRM ='||SQLERRM
                         );
                END IF;
          x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
          IF GetInstrAssgnID%ISOPEN then
           CLOSE GetInstrAssgnID;
          END IF;
          IF GetAcctInfo%ISOPEN then
           CLOSE GetAcctInfo;
          END IF;
          IF GetCustAcctParty%ISOPEN then
           CLOSE GetCustAcctParty;
          END IF;
          FND_MSG_PUB.add_exc_msg(g_pkg_name, l_api_name, substr(SQLERRM,1,240));
          RAISE;

End create_transaction_extension;



-------
END; -- Package Body OKS_UTIL_PUB

/
