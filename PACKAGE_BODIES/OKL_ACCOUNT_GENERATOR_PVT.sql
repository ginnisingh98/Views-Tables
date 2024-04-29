--------------------------------------------------------
--  DDL for Package Body OKL_ACCOUNT_GENERATOR_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OKL_ACCOUNT_GENERATOR_PVT" AS
/* $Header: OKLRAGTB.pls 120.9 2006/07/13 12:24:10 adagur noship $ */

/*-------------------------------------------------------------------------------
PACKAGE LEVEL VERIABLES
-------------------------------------------------------------------------------*/

G_ACC_STRUCTURE_NUMBER  NUMBER 	:= OKL_ACCOUNTING_UTIL.GET_CHART_OF_ACCOUNTS_ID;
G_USE_DEFAULT_ACCOUNT   VARCHAR2(30) 	:= 'N';


/*-------------------------------------------------------------------------------
Procedure to get the account generator rule form okl_acc_gen_rule and
okl_acc_gen_rul_lns table based on set of books id and org id
-------------------------------------------------------------------------------*/

PROCEDURE Get_Acc_Gen_Rules(p_ae_line_type 	IN VARCHAR2
			  ,x_return_status      OUT NOCOPY VARCHAR2
                          ,x_acc_rul_lns_tbl_type  OUT NOCOPY acc_rul_lns_tbl_type)
AS

  l_acc_rul_lns_tbl_type 	acc_rul_lns_tbl_type;
  l_RowCount 		NUMBER := 0;
  l_return_status     	VARCHAR2(1) := OKL_API.G_RET_STS_SUCCESS;
  l_ae_line_type_meaning	VARCHAR2(80);

-- Cursor which selects all the account generator rule lines for a ae line type.

-- Santonyr Bug 4134700
-- Changed tables to org striped views


  CURSOR 	acc_gen_rule_cur IS
  SELECT 	oagrl.id, oagrl.segment, oagrl.segment_number,
  		oagrl.agr_id, oagrl.source, oagrl.constants
  FROM 		okl_acc_gen_rules_v oagr, okl_acc_gen_rul_lns_v oagrl
  WHERE 	oagr.id = oagrl.agr_id
  AND 		ae_line_type = p_ae_line_type
  ORDER BY 	segment_number ASC;

  acc_gen_rule_rec  acc_gen_rule_cur%ROWTYPE;
BEGIN

-- Fetch the account generator rule lines

    OPEN acc_gen_rule_cur;
    LOOP
    FETCH acc_gen_rule_cur INTO acc_gen_rule_rec;
      l_RowCount := acc_gen_rule_cur%ROWCOUNT;
      IF acc_gen_rule_cur%NOTFOUND THEN
        IF l_RowCount = 0 THEN

-- Added by Santonyr on 18-Feb-2003. To fix the bug 2761958

          l_ae_line_type_meaning := okl_accounting_util.get_lookup_meaning
          		   (p_lookup_type => 'OKL_AE_LINE_TYPE',
          		   p_lookup_code => p_ae_line_type);

          Okl_Api.set_message(p_app_name     => g_app_name,
                            p_msg_name     => 'OKL_NO_RULE_LINES_SETUP',
                            p_token1       => 'AE_LINE_TYPE',
                            p_token1_value =>  NVL(l_ae_line_type_meaning, p_ae_line_type));

          RAISE G_EXCEPTION_ERROR;
        ELSE  -- (acc_gen_rule_cur%ROWCOUNT)
          EXIT;
        END IF; -- (acc_gen_rule_cur%ROWCOUNT)
      END IF; -- (acc_gen_rule_cur%NOTFOUND)

-- Populate the l_acc_rul_lns_tbl_type table type

    l_acc_rul_lns_tbl_type(l_RowCount).id := acc_gen_rule_rec.id;
    l_acc_rul_lns_tbl_type(l_RowCount).agr_id := acc_gen_rule_rec.agr_id;
    l_acc_rul_lns_tbl_type(l_RowCount).segment := acc_gen_rule_rec.segment;
    l_acc_rul_lns_tbl_type(l_RowCount).segment_number := acc_gen_rule_rec.segment_number;
    l_acc_rul_lns_tbl_type(l_RowCount).constants := acc_gen_rule_rec.constants;
    l_acc_rul_lns_tbl_type(l_RowCount).source := acc_gen_rule_rec.source;
   END LOOP;
   CLOSE acc_gen_rule_cur;


  x_acc_rul_lns_tbl_type := l_acc_rul_lns_tbl_type;
  x_return_status := l_return_status;

EXCEPTION
    WHEN G_EXCEPTION_ERROR THEN
      x_return_status := G_RET_STS_ERROR;
    WHEN G_EXCEPTION_UNEXPECTED_ERROR THEN
      x_return_status := G_RET_STS_UNEXP_ERROR;
    WHEN OTHERS THEN
      -- store SQL error message on message stack for caller
     x_return_status := G_RET_STS_UNEXP_ERROR;
     Okl_Api.SET_MESSAGE(p_app_name      => g_app_name,
                          p_msg_name     => g_unexpected_error,
                          p_token1       => g_sqlcode_token,
                          p_token1_value => SQLCODE,
                          p_token2       => g_sqlerrm_token,
                          p_token2_value => SQLERRM);
END Get_Acc_Gen_Rules;


/*
-------------------------------------------------------------------------------
function to get the segment value if account genertor rule is based on table
-------------------------------------------------------------------------------
*/

FUNCTION Get_Segment_Value(p_primary_key IN VARCHAR2
                          ,p_ae_line_type IN VARCHAR2
                          ,p_source_table IN VARCHAR2
                          ,p_segment IN VARCHAR2
			  ,x_return_status OUT NOCOPY VARCHAR2
                          )
RETURN VARCHAR2
AS
  l_select_string 	VARCHAR2(4000);
  l_primary_key_col OKL_AG_SOURCE_MAPS.PRIMARY_KEY_COLUMN%TYPE;
  l_column_name 	OKL_AG_SOURCE_MAPS.SELECT_COLUMN%TYPE;
  l_source_ccid 	NUMBER;
  l_segment_value 	VARCHAR2(50)  := NULL;
  l_select_clause	VARCHAR2(1000) := ' SELECT ';
  l_from_clause		VARCHAR2(1000) := ' FROM ';
  l_where_clause	VARCHAR2(1000) := ' WHERE ';
  l_equal_clause	VARCHAR2(10)  := ' = ';
  l_gl_table		VARCHAR2(50)  := ' GL_CODE_COMBINATIONS ' ;
  l_ccid_column		VARCHAR2(50)  := ' CODE_COMBINATION_ID ';
  l_return_status   VARCHAR2(1) := OKL_API.G_RET_STS_SUCCESS;
  l_primary_key_msg	VARCHAR2(100);
  l_ae_line_type_meaning	VARCHAR2(80);
  l_source_table_meaning	VARCHAR2(80);
  l_exec_mode		VARCHAR2(1) := NULL;


-- Cursor which selects the source mapping values

  CURSOR pk_cur IS
  SELECT select_column
  FROM 	 OKL_AG_SOURCE_MAPS
  WHERE  ae_line_type = p_ae_line_type
  AND    source = p_source_table;

  pk_rec pk_cur%ROWTYPE;

 TYPE source_csr IS REF CURSOR;
 source_rec source_csr;

BEGIN
  -- Validate if the primary key column value is null
  IF p_source_table IN ('FA_CATEGORY_BOOKS', 'MTL_SYSTEM_ITEMS_VL') THEN
    IF TRIM(SUBSTR(p_primary_key, 1, 50))IS NULL OR TRIM(SUBSTR(p_primary_key, 51, 100)) IS NULL THEN

-- Commented out by Santonyr on 22-Sep-2004 to fix bug 3901209.
/*
	Okl_Api.set_message(p_app_name     => g_app_name,
                        p_msg_name     => 'OKL_INV_SOURCE_OR_PK_IS_NULL'
                        );

*/
       G_USE_DEFAULT_ACCOUNT := 'Y';
       l_return_status := G_RET_STS_ERROR;
       RAISE G_EXCEPTION_ERROR;
    END IF;

  ELSE

  IF p_primary_key IS NULL THEN

-- Commented out by Santonyr on 22-Sep-2004 to fix bug 3901209.
/*
	Okl_Api.set_message(p_app_name     => g_app_name,
                        p_msg_name     => 'OKL_INV_SOURCE_OR_PK_IS_NULL'
                        );
*/
	G_USE_DEFAULT_ACCOUNT := 'Y';
       l_return_status := G_RET_STS_ERROR;
       RAISE G_EXCEPTION_ERROR;
     END IF;

  END IF;

  -- Fetch the source mappings

  OPEN pk_cur;
  FETCH pk_cur INTO l_column_name;
  IF pk_cur%NOTFOUND THEN

  -- Raise error if the source mapping has not been setup.

-- Added by Santonyr on 18-Feb-2003. To fix the bug 2761958

          l_ae_line_type_meaning := okl_accounting_util.get_lookup_meaning
          		   (p_lookup_type => 'OKL_AE_LINE_TYPE',
          		   p_lookup_code => p_ae_line_type);

          l_source_table_meaning := okl_accounting_util.get_lookup_meaning
          		   (p_lookup_type => 'OKL_ACC_GEN_SOURCE_TABLE',
          		   p_lookup_code => p_source_table);

      Okl_Api.set_message(p_app_name     => g_app_name,
                        p_msg_name     => 'OKL_NO_SOURCES_SETUP',
                        p_token1       => 'AE_LINE_TYPE',
                        p_token1_value =>  NVL(l_ae_line_type_meaning, p_ae_line_type),
                        p_token2       => 'SOURCE',
                        p_token2_value =>  NVL(l_source_table_meaning, p_source_table)
                        );
    l_return_status := G_RET_STS_ERROR;
    RAISE G_EXCEPTION_ERROR;
  END IF;
  CLOSE pk_cur;

-- Form the select statement to fetch the source ccid
  IF p_source_table = 'AP_VENDOR_SITES_V' THEN
  --    l_where_clause	:= l_where_clause || ' VENDOR_SITE_ID  = ' || TRIM(p_primary_key) ;
      l_where_clause	:= l_where_clause || ' VENDOR_SITE_ID  = ' || ' TRIM(:1) ';
  	l_exec_mode := '1';


    ELSIF p_source_table = 'AR_SITE_USES_V' THEN
  --    l_where_clause	:= l_where_clause || ' SITE_USE_ID  = ' || TRIM(p_primary_key) ;
      l_where_clause	:= l_where_clause || ' SITE_USE_ID  = ' || ' TRIM(:1) ';
  	l_exec_mode := '1';


    ELSIF p_source_table = 'FA_CATEGORY_BOOKS' THEN
  --    l_where_clause	:= l_where_clause || ' CATEGORY_ID  = ' || TRIM(SUBSTR(p_primary_key, 1, 50)) ||
  --	                   ' AND UPPER(BOOK_TYPE_CODE)  = ''' || UPPER(TRIM(SUBSTR(p_primary_key, 51, 100))) || '''';
      l_where_clause	:= l_where_clause || ' CATEGORY_ID  = ' || ' TRIM(SUBSTR(:1, 1, 50)) ' ||
  	                   ' AND UPPER(BOOK_TYPE_CODE)  = ' || ' UPPER(TRIM(SUBSTR(:1, 51, 100)))'  ;
  	l_exec_mode := '2';


    ELSIF p_source_table = 'FINANCIALS_SYSTEM_PARAMETERS' THEN
      l_where_clause	:= l_where_clause || ' ORG_ID  = ' || ' TRIM(:1) ' ; -- TRIM(p_primary_key) ;
  --    l_where_clause	:= l_where_clause || ' 1 = 1 ' ;
  	l_exec_mode := '1';

    ELSIF p_source_table = 'JTF_RS_SALESREPS_MO_V' THEN
  --    l_where_clause	:= l_where_clause || ' SALESREP_ID  = ' || TRIM(p_primary_key) ;
        l_where_clause	:= l_where_clause || ' SALESREP_ID  = ' || ' TRIM(:1) ' ;
  	l_exec_mode := '1';


    ELSIF p_source_table = 'MTL_SYSTEM_ITEMS_VL' THEN
  --    l_where_clause	:= l_where_clause || ' INVENTORY_ITEM_ID  = ' || TRIM(SUBSTR(p_primary_key, 1, 50)) ||
  --					     ' AND ORGANIZATION_ID  = ' ||  TRIM(SUBSTR(p_primary_key, 51, 100)) ;

        l_where_clause	:= l_where_clause || ' INVENTORY_ITEM_ID  = ' ||'  TRIM(SUBSTR(:1, 1, 50)) ' ||
        				     ' AND ORGANIZATION_ID  = ' ||  ' TRIM(SUBSTR(:1, 51, 100)) ' ;
  	l_exec_mode := '2';



    ELSIF p_source_table = 'RA_CUST_TRX_TYPES' THEN
  --    l_where_clause	:= l_where_clause || ' CUST_TRX_TYPE_ID  = ' || TRIM(p_primary_key) ;
        l_where_clause	:= l_where_clause || ' CUST_TRX_TYPE_ID  = ' || ' TRIM(:1) ';
	  l_exec_mode := '1';

  ELSE

   l_source_table_meaning := okl_accounting_util.get_lookup_meaning
          		   (p_lookup_type => 'OKL_ACC_GEN_SOURCE_TABLE',
          		   p_lookup_code => p_source_table);

    Okl_Api.set_message(p_app_name     => g_app_name,
                        p_msg_name      => 'OKL_INVALID_SOURCE',
                        p_token1       => 'SOURCE',
                        p_token1_value =>  NVL(l_source_table_meaning, p_source_table)
                        );
    RAISE G_EXCEPTION_ERROR;
  END IF;


  l_select_string := l_select_clause ||  l_column_name || l_from_clause || p_source_table || l_where_clause ;


--  OPEN source_rec FOR l_select_string;
    IF l_exec_mode = '1' THEN
          OPEN source_rec FOR l_select_string USING p_primary_key;
    ELSIF l_exec_mode = '2' THEN
          OPEN source_rec FOR l_select_string USING p_primary_key, p_primary_key;
    END IF;

  FETCH source_rec INTO l_source_ccid;
  IF source_rec%NOTFOUND THEN
    IF TRIM(SUBSTR(p_primary_key, 51)) IS NOT NULL THEN
      l_primary_key_msg := TRIM(SUBSTR(p_primary_key, 1, 50)) ||  ' , ' || TRIM(SUBSTR(p_primary_key, 51));
    ELSE
      l_primary_key_msg := TRIM(SUBSTR(p_primary_key, 1, 50)) ;
    END IF;


-- Added by Santonyr on 18-Feb-2003. To fix the bug 2761958

   l_ae_line_type_meaning := okl_accounting_util.get_lookup_meaning
          		   (p_lookup_type => 'OKL_AE_LINE_TYPE',
          		   p_lookup_code => p_ae_line_type);

   l_source_table_meaning := okl_accounting_util.get_lookup_meaning
          		   (p_lookup_type => 'OKL_ACC_GEN_SOURCE_TABLE',
          		   p_lookup_code => p_source_table);

    Okl_Api.set_message(p_app_name     => g_app_name,
                        p_msg_name      => 'OKL_NO_SOURCE_EXISTS',
                        p_token1       => 'SOURCE',
                        p_token1_value =>  NVL(l_source_table_meaning, p_source_table),
                        p_token2       => 'PRIMARY_KEY',
                        p_token2_value =>  l_primary_key_msg,
                        p_token3       => 'AE_LINE_TYPE',
                        p_token3_value =>  NVL(l_ae_line_type_meaning, p_ae_line_type)
                        );
    RAISE G_EXCEPTION_ERROR;
   ELSE
      IF l_source_ccid IS NULL THEN
        l_primary_key_msg := TRIM(SUBSTR(p_primary_key, 1, 50)) || ' , ' || TRIM(SUBSTR(p_primary_key, 51));

-- Added by Santonyr on 18-Feb-2003. To fix the bug 2761958

   l_ae_line_type_meaning := okl_accounting_util.get_lookup_meaning
          		   (p_lookup_type => 'OKL_AE_LINE_TYPE',
          		   p_lookup_code => p_ae_line_type);

   l_source_table_meaning := okl_accounting_util.get_lookup_meaning
          		   (p_lookup_type => 'OKL_ACC_GEN_SOURCE_TABLE',
          		   p_lookup_code => p_source_table);


        Okl_Api.set_message(p_app_name     => g_app_name,
                          p_msg_name      => 'OKL_NO_SOURCE_EXISTS',
                          p_token1       => 'SOURCE',
                          p_token1_value =>  NVL(l_source_table_meaning, p_source_table),
                          p_token2       => 'PRIMARY_KEY',
                          p_token2_value =>  l_primary_key_msg,
                          p_token3       => 'AE_LINE_TYPE',
                          p_token3_value =>  NVL(l_ae_line_type_meaning, p_ae_line_type)
                          );
        RAISE G_EXCEPTION_ERROR;
      END IF;
  END IF;
  CLOSE source_rec;


-- Form the select statement to fetch the segment value for the source ccid

--l_select_string := l_select_clause || p_segment || l_from_clause || l_gl_table ||
--		     ' WHERE '  || l_ccid_column || l_equal_clause  || l_source_ccid;

  l_select_string := l_select_clause || p_segment || l_from_clause || l_gl_table ||
  		     ' WHERE '  || l_ccid_column || l_equal_clause  || ':1';


--OPEN source_rec FOR l_select_string;
  OPEN source_rec FOR l_select_string USING l_source_ccid;

  FETCH source_rec INTO l_segment_value;
  CLOSE source_rec;

  x_return_status := l_return_status;
  RETURN l_segment_value;

EXCEPTION
    WHEN G_EXCEPTION_ERROR THEN
      x_return_status := G_RET_STS_ERROR;
      RETURN l_segment_value;
    WHEN G_EXCEPTION_UNEXPECTED_ERROR THEN
      x_return_status := G_RET_STS_UNEXP_ERROR;
      RETURN l_segment_value;
    WHEN OTHERS THEN
      -- store SQL error message on message stack for caller
     x_return_status := G_RET_STS_UNEXP_ERROR;
     Okl_Api.SET_MESSAGE(p_app_name      => g_app_name,
                          p_msg_name     => g_unexpected_error,
                          p_token1       => g_sqlcode_token,
                          p_token1_value => SQLCODE,
                          p_token2       => g_sqlerrm_token,
                          p_token2_value => SQLERRM);
     RETURN l_segment_value;

END get_segment_value;


/*-------------------------------------------------------------------------------
get concatenated segments based on rule
-------------------------------------------------------------------------------*/
FUNCTION concat_segments(p_ae_line_type IN VARCHAR2
                        ,p_set_of_books_id IN NUMBER
                        ,p_acc_rul_lns_tbl_type IN acc_rul_lns_tbl_type
                        ,p_primary_key_tbl IN primary_key_tbl
                        ,x_return_status OUT NOCOPY VARCHAR2)
RETURN VARCHAR2
AS
  l_segment_tbl Fnd_Flex_Ext.segmentarray;
  l_number_of_segments NUMBER;
  l_segment_seprator VARCHAR2(1);
  l_concat_segments VARCHAR2(1500) := NULL;
  l_primary_key VARCHAR2(100);
  l_return_status     	VARCHAR2(1) := OKL_API.G_RET_STS_SUCCESS;
  i NUMBER;

BEGIN
  l_number_of_segments := p_acc_rul_lns_tbl_type.COUNT;

  -- get the primary key column which is used to get the source value

  FOR i IN 1..l_number_of_segments LOOP
    IF p_acc_rul_lns_tbl_type(i).source IS NOT NULL THEN


      FOR j IN p_primary_key_tbl.first..p_primary_key_tbl.last LOOP
        IF UPPER(p_primary_key_tbl(j).source_table) = p_acc_rul_lns_tbl_type(i).source THEN
          l_primary_key := p_primary_key_tbl(j).primary_key_column;
        END IF;
      END LOOP;

  -- get all the segments in an array

      l_segment_tbl(i) := get_segment_value(p_primary_key => l_primary_key
                                           ,p_ae_line_type => p_ae_line_type
                                           ,p_source_table => p_acc_rul_lns_tbl_type(i).source
                                           ,p_segment => p_acc_rul_lns_tbl_type(i).segment
                   		           ,x_return_status => l_return_status );
	IF (l_return_status = G_RET_STS_UNEXP_ERROR) THEN
          RAISE G_EXCEPTION_UNEXPECTED_ERROR;
  	ELSIF (l_return_Status = G_RET_STS_ERROR) THEN
  	  RAISE G_EXCEPTION_ERROR;
	END IF;


    ELSE
      l_segment_tbl(i) := p_acc_rul_lns_tbl_type(i).constants;
    END IF;
  END LOOP;

  -- Get the segments separator

  l_segment_seprator := Fnd_Flex_Ext.get_delimiter(application_short_name => g_gl_app_short_name
                                     		   ,key_flex_code => g_acc_key_flex_code
			                           ,structure_number => g_acc_structure_number);

  -- Get the segments concatenated

  l_concat_segments := Fnd_Flex_Ext.concatenate_segments(n_segments => l_number_of_segments
				                         ,segments => l_segment_tbl
			                                 ,delimiter => l_segment_seprator);

  x_return_status := l_return_status;
  RETURN l_concat_segments;
EXCEPTION
    WHEN G_EXCEPTION_ERROR THEN
      x_return_status := G_RET_STS_ERROR;
      RETURN l_concat_segments;
    WHEN G_EXCEPTION_UNEXPECTED_ERROR THEN
      x_return_status := G_RET_STS_UNEXP_ERROR;
      RETURN l_concat_segments;
    WHEN OTHERS THEN
      -- store SQL error message on message stack for caller
     x_return_status := G_RET_STS_UNEXP_ERROR;
     Okl_Api.SET_MESSAGE(p_app_name      => g_app_name,
                          p_msg_name     => g_unexpected_error,
                          p_token1       => g_sqlcode_token,
                          p_token1_value => SQLCODE,
                          p_token2       => g_sqlerrm_token,
                          p_token2_value => SQLERRM);
     RETURN l_concat_segments;

END concat_segments;

/*-------------------------------------------------------------------------------
validate / create / get code combination id based on concatenated segment return
0 if creation / validation fails.
-------------------------------------------------------------------------------*/

FUNCTION get_code_combination_id(p_concate_segments IN VARCHAR2,
                                 x_return_status OUT NOCOPY VARCHAR2)
RETURN NUMBER
AS
  l_ccid 		NUMBER := -1;
  l_return_status     	VARCHAR2(1) := OKL_API.G_RET_STS_SUCCESS;
BEGIN

  -- get the ccid

  l_ccid := Fnd_Flex_Ext.get_ccid(application_short_name  => g_gl_app_short_name
		                  ,key_flex_code => g_acc_key_flex_code
		                  ,structure_number	=> g_acc_structure_number
		                  ,validation_date => FND_DATE.DATE_TO_CANONICAL(SYSDATE)
		                  ,concatenated_segments => p_concate_segments);

  x_return_status := l_return_status;
  RETURN l_ccid;

EXCEPTION
    WHEN G_EXCEPTION_ERROR THEN
      x_return_status := G_RET_STS_ERROR;
      RETURN l_ccid;
    WHEN G_EXCEPTION_UNEXPECTED_ERROR THEN
      x_return_status := G_RET_STS_UNEXP_ERROR;
      RETURN l_ccid;
    WHEN OTHERS THEN
      -- store SQL error message on message stack for caller
     x_return_status := G_RET_STS_UNEXP_ERROR;
     Okl_Api.SET_MESSAGE(p_app_name      => g_app_name,
                          p_msg_name     => g_unexpected_error,
                          p_token1       => g_sqlcode_token,
                          p_token1_value => SQLCODE,
                          p_token2       => g_sqlerrm_token,
                          p_token2_value => SQLERRM);
     RETURN l_ccid;

END get_code_combination_id;

/*-------------------------------------------------------------------------------
get ccid main function to get the ccid.
-------------------------------------------------------------------------------*/

-- Changed by Santonyr on 22-Sep-2004 to fix bug 3901209.
-- Added a new parameter 'p_ae_tmpt_line_id'.
-- If Account Generator fails due to lack of sources, it picks up the
-- default account code for the passed account template line and returns.

-- Changed the signature for bug 4157521

FUNCTION GET_CCID
(
  p_api_version          	IN NUMBER,
  p_init_msg_list        	IN VARCHAR2,
  x_return_status        	OUT NOCOPY VARCHAR2,
  x_msg_count            	OUT NOCOPY NUMBER,
  x_msg_data             	OUT NOCOPY VARCHAR2,
  p_acc_gen_wf_sources_rec       IN  acc_gen_wf_sources_rec,
  p_ae_line_type		IN okl_acc_gen_rules.ae_line_type%TYPE,
  p_primary_key_tbl		IN primary_key_tbl,
  p_ae_tmpt_line_id		IN NUMBER DEFAULT NULL
)
RETURN NUMBER
AS
  l_return_status     		VARCHAR2(1) := OKL_API.G_RET_STS_SUCCESS;
  l_api_name          		CONSTANT VARCHAR2(40) := 'GENERATE_ACCOUNT';
  l_api_version       		CONSTANT NUMBER       := 1.0;
  l_init_msg_list     		VARCHAR2(1);
  l_msg_count         		NUMBER;
  l_msg_data          		VARCHAR2(2000);
  l_acc_rul_lns_tbl_type 	acc_rul_lns_tbl_type;
  l_org_id 			NUMBER;
  l_set_of_books_id 		NUMBER;
  l_concat_segments 		VARCHAR2(1500);
  l_ccid 			NUMBER;
  l_acct_gen_use_workflow 	VARCHAR2(10);
  l_error_msg				VARCHAR2(1500);
  l_error_text				VARCHAR2(2000);


  -- Added by Santonyr on 22-Sep-2204 to fix bug 3901209.
  -- Cursor to get code combination id for a template line.

  CURSOR atl_csr(p_atl_id NUMBER) IS
  SELECT  ID,
  	  CODE_COMBINATION_ID
  FROM OKL_AE_TMPT_LNES
  WHERE id = p_atl_id;



BEGIN

  -- Set save point
  l_return_status := Okl_Api.START_ACTIVITY(l_api_name
                                               ,G_PKG_NAME
                                               ,l_init_msg_list
                                               ,l_api_version
                                               ,p_api_version
                                               ,'_PVT'
                                               ,l_return_status);
  IF (l_return_status = G_RET_STS_UNEXP_ERROR) THEN
    RAISE G_EXCEPTION_UNEXPECTED_ERROR;
  ELSIF (l_return_Status = G_RET_STS_ERROR) THEN
    RAISE G_EXCEPTION_ERROR;
  END IF;

  -- get the profile value to decide whether to use the workflow for generating the CCID

  l_acct_gen_use_workflow := NVL(FND_PROFILE.VALUE ('OKL_ACCT_GEN_USE_WORKFLOW'), 'N');

  -- If the l_acct_gen_use_workflow is 'No' then use the APIs to gnerate the CCID

  IF l_acct_gen_use_workflow = 'N' THEN

  -- Get the Org ID

    l_org_id := MO_GLOBAL.GET_CURRENT_ORG_ID();

  -- Get the Set Of Books ID
    l_set_of_books_id := Okl_Accounting_Util.get_set_of_books_id;

    -- Get the Account Genartor rules setup for the accounting line type

    Get_Acc_Gen_Rules(p_ae_line_type => p_ae_line_type
                   ,x_return_status => l_return_status
                   ,x_acc_rul_lns_tbl_type => l_acc_rul_lns_tbl_type);


    IF (l_return_status = G_RET_STS_UNEXP_ERROR) THEN
      RAISE G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_Status = G_RET_STS_ERROR) THEN
      RAISE G_EXCEPTION_ERROR;
    END IF;


    -- Get the segments concatenated

    -- Changed by Santonyr on 22-Sep-2004 to fix bug 3901209.

    -- Set the global variable to N before calling the API.

    G_USE_DEFAULT_ACCOUNT := 'N';

    l_concat_segments := concat_segments(p_ae_line_type => p_ae_line_type
                                      ,p_set_of_books_id => l_set_of_books_id
                                      ,p_acc_rul_lns_tbl_type => l_acc_rul_lns_tbl_type
                                      ,p_primary_key_tbl => p_primary_key_tbl
                   		      ,x_return_status => l_return_status );

    IF (l_return_status <> G_RET_STS_SUCCESS) AND
       (G_USE_DEFAULT_ACCOUNT = 'Y') THEN

       G_USE_DEFAULT_ACCOUNT := 'N';

       FOR atl_rec IN atl_csr (p_ae_tmpt_line_id) LOOP
         l_ccid := atl_rec.code_combination_id;
       END LOOP;

       IF l_ccid IS NULL THEN
	  Okl_Api.set_message(p_app_name     => g_app_name,
                        p_msg_name     => 'OKL_TMPT_LN_CCID_REQD' );
      	  l_return_status := G_RET_STS_ERROR;
      	  RAISE G_EXCEPTION_ERROR;
       ELSE
	  x_return_status := G_RET_STS_SUCCESS;
	  Okl_Api.end_activity(x_msg_count, x_msg_data);
	  RETURN l_ccid;
       END IF;

    END IF;


    IF (l_return_status = G_RET_STS_UNEXP_ERROR) THEN
      RAISE G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_Status = G_RET_STS_ERROR) THEN
      RAISE G_EXCEPTION_ERROR;
    END IF;

    -- get the code combination id using the concatednated segmeg

    l_ccid := get_code_combination_id(p_concate_segments => l_concat_segments
                   		    ,x_return_status => l_return_status  );

    IF (l_ccid = -1 OR l_ccid IS NULL ) THEN
      Okl_Api.set_message(p_app_name     => g_app_name,
                        p_msg_name     => 'OKL_ERROR_GEN_CCID' );
      l_return_status := G_RET_STS_ERROR;
      RAISE G_EXCEPTION_ERROR;

	ELSIF l_ccid = 0 THEN


      l_error_msg := fnd_message.get;
	  IF l_error_msg IS NOT NULL THEN
	    l_error_text := l_error_msg || ' ' || l_concat_segments;
	  ELSE
	    l_error_text := l_concat_segments;
	  END IF;


      Okl_Api.set_message(p_app_name     => g_app_name,
                          p_msg_name     => 'OKL_CODE_COMB_NOT_EXISTS',
			  p_token1	 => 'CONCATENATED_SEGMENTS',
			  p_token1_value => l_error_text );
      l_return_status := G_RET_STS_ERROR;
      RAISE G_EXCEPTION_ERROR;
    END IF;


    IF (l_return_status = G_RET_STS_UNEXP_ERROR) THEN
      RAISE G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_Status = G_RET_STS_ERROR) THEN
      RAISE G_EXCEPTION_ERROR;
    END IF;

  ELSE -- (If the l_acct_gen_use_workflow is 'Yes')
  -- If the l_acct_gen_use_workflow is 'Yes  then use the workflow process to gnerate the CCID

-- Changed the signature for bug 4157521

     l_ccid := OKL_ACC_GEN_WF_PVT.start_process
     		(p_acc_gen_wf_sources_rec      => p_acc_gen_wf_sources_rec,
  	   	p_ae_line_type      	  => p_ae_line_type,
  	   	p_primary_key_tbl 	  => p_primary_key_tbl,
  	   	p_ae_tmpt_line_id	  => p_ae_tmpt_line_id);

     IF (l_ccid = -1 OR l_ccid IS NULL ) THEN
        Okl_Api.set_message(p_app_name     => g_app_name,
                            p_msg_name     => 'OKL_ERROR_GEN_CCID_WF' );
        l_return_status := G_RET_STS_ERROR;
        RAISE G_EXCEPTION_ERROR;
    END IF;

  END IF;

  x_return_status := l_return_status;
  Okl_Api.end_activity(x_msg_count, x_msg_data);

  RETURN l_ccid;


  EXCEPTION
    WHEN G_EXCEPTION_ERROR THEN
       x_return_status := OKL_API.HANDLE_EXCEPTIONS(l_api_name
                                                     ,g_pkg_name
                                                     ,'OKL_API.G_RET_STS_ERROR'
                                                     ,x_msg_count
                                                     ,x_msg_data
                                                     ,'_PVT');
      RETURN l_ccid;
    WHEN G_EXCEPTION_UNEXPECTED_ERROR THEN
      x_return_status := OKL_API.HANDLE_EXCEPTIONS(l_api_name
                                                     ,g_pkg_name
                                                     ,'OKL_API.G_RET_STS_UNEXP_ERROR'
                                                     ,x_msg_count
                                                     ,x_msg_data
                                                     ,'_PVT');
      RETURN l_ccid;
    WHEN OTHERS THEN
      x_return_status := OKL_API.HANDLE_EXCEPTIONS(l_api_name
                                                      ,g_pkg_name
                                                      ,'OTHERS'
                                                      ,x_msg_count
                                                      ,x_msg_data
                                                      ,'_PVT');
      RETURN l_ccid;
END get_ccid;


END Okl_Account_Generator_Pvt;

/
