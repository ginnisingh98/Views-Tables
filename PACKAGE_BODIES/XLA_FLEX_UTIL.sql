--------------------------------------------------------
--  DDL for Package Body XLA_FLEX_UTIL
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."XLA_FLEX_UTIL" AS
/* $Header: xlauflex.pkb 120.1 2004/02/13 22:55:21 weshen noship $ */

  CURSOR flex_segments_csr(p_chart_of_accounts_id NUMBER)
      IS
      SELECT segment_num, application_column_name
      FROM fnd_id_flex_segments
      WHERE application_id = 101
      AND   id_flex_code   = 'GL#'
      AND   enabled_flag   = 'Y'
      AND   id_flex_num    = p_chart_of_accounts_id
      ORDER BY segment_num;

FUNCTION getsegmentInfo(p_chartofaccountsid IN  NUMBER,
			p_segmentinfo       OUT NOCOPY t_segmentinfo
			) RETURN BOOLEAN IS
   CURSOR c_getsegmentnum(c_chartOfAccountsID NUMBER) IS
      SELECT  segment_num
	FROM fnd_id_flex_segments_vl
	WHERE application_id = 101
	AND   id_flex_code   = 'GL#'
	AND   enabled_flag   = 'Y'
	AND   id_flex_num    =  c_chartOfAccountsID
	ORDER BY segment_num;

l_segmentinfo XLA_FLEX_UTIL.t_segmentinfo;
l_rownum      NUMBER;
BEGIN
   l_rownum := 0;
   FOR segment_rec IN c_getsegmentnum(p_chartofaccountsid) LOOP
      l_rownum := l_rownum + 1;
      l_segmentinfo(segment_rec.segment_num).segment_num      := segment_rec.segment_num;
      l_segmentinfo(segment_rec.segment_num).segment_ordernum := l_rownum;
   END LOOP;
   p_segmentinfo := l_segmentinfo;
   RETURN(TRUE);
END getsegmentInfo;


FUNCTION get_flex_segment(p_chart_of_accounts_id IN NUMBER
                         ,p_segment_number IN NUMBER )
RETURN VARCHAR2;


/*===========================================================================+
 | PROCEDURE                                                                 |
 |    get_account_flex_info                                                  |
 |                                                                           |
 | DESCRIPTION                                                               |
 |    Gets accounting flexfield information based on the chart of accounts id|
 |    passed.                                                                |
 |                                                                           |
 | EXTERNAL PROCEDURES/FUNCTIONS ACCESSED                                    |
 |    xla_debug.print                                                        |
 |                                                                           |
 | ARGUMENTS    							     |
 |              p_chart_of_accounts_id    IN     NUMBER,		     |
 |              x_segment_delimiter       IN OUT NOCOPY VARCHAR2,		     |
 |              x_enabled_segment_count   IN OUT NOCOPY NUMBER,		     |
 |              x_segment_order_by        IN OUT NOCOPY VARCHAR2,		     |
 |              x_accseg_segment_num      IN OUT NOCOPY NUMBER,		     |
 |              x_accseg_app_col_name     IN OUT NOCOPY VARCHAR2,		     |
 |              x_accseg_left_prompt      IN OUT NOCOPY VARCHAR2,		     |
 |              x_balseg_segment_num      IN OUT NOCOPY NUMBER,		     |
 |              x_balseg_app_col_name     IN OUT NOCOPY VARCHAR2,		     |
 |              x_balseg_left_prompt      IN OUT NOCOPY VARCHAR2		     |
 |                                                                           |
 | NOTES                                                                     |
 |                                                                           |
 | MODIFICATION HISTORY                                                      |
 |     30-Oct-98  Mahesh Sabapathy    Created                                |
 |                                                                           |
 +===========================================================================*/
PROCEDURE get_account_flex_info (
		p_chart_of_accounts_id    IN     NUMBER,
                x_segment_delimiter       IN OUT NOCOPY VARCHAR2,
                x_enabled_segment_count   IN OUT NOCOPY NUMBER,
                x_segment_order_by        IN OUT NOCOPY VARCHAR2,
                x_accseg_segment_num      IN OUT NOCOPY NUMBER,
                x_accseg_app_col_name     IN OUT NOCOPY VARCHAR2,
                x_accseg_left_prompt      IN OUT NOCOPY VARCHAR2,
                x_balseg_segment_num      IN OUT NOCOPY NUMBER,
                x_balseg_app_col_name     IN OUT NOCOPY VARCHAR2,
                x_balseg_left_prompt      IN OUT NOCOPY VARCHAR2) IS

  dummy 	BOOLEAN := FALSE;

  l_seg_name 	VARCHAR2(30);
  l_value_set 	VARCHAR2(60);

BEGIN

    -- Identify the natural account and balancing segments
    dummy := get_segment_number(
                101, 'GL#', p_chart_of_accounts_id,
                'GL_ACCOUNT', x_accseg_segment_num);
    dummy := get_segment_number(
                101, 'GL#', p_chart_of_accounts_id,
                'GL_BALANCING', x_balseg_segment_num);

    -- Get the segment delimiter
    x_segment_delimiter := FND_FLEX_APIS.get_segment_delimiter( 101, 'GL#', p_chart_of_accounts_id);

    -- Count 'em up and string 'em together
    x_enabled_segment_count := 0;
    FOR segments_rec IN flex_segments_csr(p_chart_of_accounts_id) LOOP
      -- How many enabled segs are there?
      x_enabled_segment_count := flex_segments_csr%ROWCOUNT;

      -- Record the order by string
      IF flex_segments_csr%ROWCOUNT = 1 THEN
        x_segment_order_by      := segments_rec.application_column_name;
      ELSE
        x_segment_order_by      := x_segment_order_by||
                                   ','||
                                   segments_rec.application_column_name;
      END IF;

      -- If this is either the accseg or balseg, get more info
      IF    segments_rec.segment_num = x_accseg_segment_num THEN
        IF (FND_FLEX_APIS.get_segment_info(
              101, 'GL#', p_chart_of_accounts_id,
              segments_rec.segment_num, x_accseg_app_col_name,
              l_seg_name, x_accseg_left_prompt, l_value_set)) THEN
          null;
        END IF;
      ELSIF segments_rec.segment_num = x_balseg_segment_num THEN
        IF (FND_FLEX_APIS.get_segment_info(
              101, 'GL#', p_chart_of_accounts_id,
              segments_rec.segment_num, x_balseg_app_col_name,
              l_seg_name, x_balseg_left_prompt, l_value_set)) THEN
          null;
        END IF;
      END IF;
    END LOOP;

EXCEPTION
  WHEN OTHERS THEN
     	app_exception.raise_exception;
END get_account_flex_info;

/*===========================================================================+
 | FUNCTION                                                                  |
 |    get_ordered_account                                                    |
 |                                                                           |
 | DESCRIPTION                                                               |
 |    returns the account ordered by balancing segment, natural account and  |
 |    all other segments						     |
 |                                                                           |
 | EXTERNAL PROCEDURES/FUNCTIONS ACCESSED                                    |
 |                                                                           |
 | ARGUMENTS  : IN:  p_charts_of_accounts_id                                 |
 |                   p_table_alias                                           |
 |                                                                           |
 | NOTES                                                                     |
 |                                                                           |
 | MODIFICATION HISTORY                                                      |
 |     03-Nov-98  Dirk Stevens        Created                                |
 |                                                                           |
 +===========================================================================*/

FUNCTION get_ordered_account(
		p_chart_of_accounts_id IN NUMBER
	       ,p_table_alias          IN VARCHAR2 )
RETURN VARCHAR2
IS

  dummy 	BOOLEAN := FALSE;

  l_seg_name 	VARCHAR2(30);
  l_value_set 	VARCHAR2(60);

  l_segment_delimiter     VARCHAR2(30);
  l_enabled_segment_count NUMBER;

  l_accseg_segment_num    NUMBER;
  l_balseg_segment_num    NUMBER;

  return_value  VARCHAR2(2000);

BEGIN

    -- Identify the natural account and balancing segments
    dummy := get_segment_number(
                101, 'GL#', p_chart_of_accounts_id,
                'GL_ACCOUNT', l_accseg_segment_num);
    dummy := get_segment_number(
                101, 'GL#', p_chart_of_accounts_id,
                'GL_BALANCING', l_balseg_segment_num);

    -- Get the segment delimiter
    l_segment_delimiter := FND_FLEX_APIS.get_segment_delimiter( 101, 'GL#', p_chart_of_accounts_id);

    -- String balancing segment and natural account segment together
    return_value := p_table_alias||'.'||get_flex_segment(p_chart_of_accounts_id, l_balseg_segment_num);

    -- Concat the natural account segment
    return_value      := return_value||'||'''||l_segment_delimiter||'''||'||p_table_alias||'.'||get_flex_segment(p_chart_of_accounts_id, l_accseg_segment_num);

    -- Count the rest and string 'em together
    l_enabled_segment_count := 0;

    FOR segments_rec IN flex_segments_csr(p_chart_of_accounts_id) LOOP
      -- How many enabled segs are there?
      l_enabled_segment_count := flex_segments_csr%ROWCOUNT;


      IF ( ( segments_rec.segment_num <> l_accseg_segment_num)
         AND (segments_rec.segment_num <> l_balseg_segment_num) )
      THEN

         return_value      := return_value||'||'''||l_segment_delimiter||'''||'||p_table_alias||'.'||segments_rec.application_column_name;
      END IF;

    END LOOP;

    RETURN return_value;

EXCEPTION
  WHEN OTHERS THEN
     	app_exception.raise_exception;
END get_ordered_account;

FUNCTION get_flex_segment(p_chart_of_accounts_id IN NUMBER
                         ,p_segment_number IN NUMBER )
RETURN VARCHAR2
IS
 return_value VARCHAR2(250);

 CURSOR flex_segment_name_csr(p_chart_of_accounts_id NUMBER
                             ,p_segment_number NUMBER)
      IS
      SELECT application_column_name
      FROM fnd_id_flex_segments
      WHERE application_id = 101
      AND   id_flex_code   = 'GL#'
      AND   enabled_flag   = 'Y'
      AND   id_flex_num    = p_chart_of_accounts_id
      AND   segment_num = p_segment_number;

 flex_segment_name flex_segment_name_csr%ROWTYPE;

BEGIN

 OPEN flex_segment_name_csr(p_chart_of_accounts_id, p_segment_number);
 FETCH flex_segment_name_csr INTO flex_segment_name;
 return_value := flex_segment_name.application_column_name;
 CLOSE flex_segment_name_csr;

 RETURN return_value;

END get_flex_segment;

/*===========================================================================+
 | FUNCTION                                                                  |
 |    is_segment_dependent                                                   |
 |                                                                           |
 | DESCRIPTION                                                               |
 |    returns 'Y' if the segment is dependent                                |
 |                                                                           |
 | EXTERNAL PROCEDURES/FUNCTIONS ACCESSED                                    |
 |                                                                           |
 | ARGUMENTS  : IN:  segment                                                 |
 |                                                                           |
 | NOTES                                                                     |
 |                                                                           |
 | MODIFICATION HISTORY                                                      |
 |     15-Apr-99  Dirk Stevens        Created                                |
 |                                                                           |
 +===========================================================================*/

 FUNCTION is_segment_dependent(segment             IN NUMBER
                              ,p_ChartOfAccountsID IN NUMBER
                              ,p_flex_code         IN VARCHAR2
                              ,p_applicationID     IN NUMBER)
  RETURN VARCHAR2
 IS
  returnValue       VARCHAR2(240);

  l_dummy_flex_ret_value BOOLEAN;

  l_segment1_column VARCHAR2(240);
  l_seg_name        VARCHAR2(240);
  l_prompt          VARCHAR2(240);
  l_value_set_name  VARCHAR2(240);
  l_value_set_id    NUMBER;

  l_valueset        FND_VSET.VALUESET_R;
  l_format          FND_VSET.VALUESET_DR;

  CURSOR get_value_set_id_c(p_ValueSetName VARCHAR2) IS
  SELECT FLEX_VALUE_SET_ID
  FROM FND_FLEX_VALUE_SETS
  WHERE FLEX_VALUE_SET_NAME = p_ValueSetName;

 BEGIN

	l_dummy_flex_ret_value := FND_FLEX_APIS.GET_SEGMENT_INFO(
 					 p_applicationID
                                        ,p_flex_code
                                        ,p_ChartOfAccountsID
                                        ,segment
                                      	,l_segment1_column
                                      	,l_seg_name
                                      	,l_prompt
                                      	,l_value_set_name);

         -- Now we have the value set name, let's get the id
         -- Name should be unique

         OPEN get_value_set_id_c(l_value_set_name);
         FETCH get_value_set_id_c INTO l_value_set_id;
         CLOSE get_value_set_id_c;

         -- retrieve the dependency information

         FND_VSET.GET_VALUESET(l_value_set_id
                              ,l_valueset
                              ,l_format );

         RETURN l_valueset.validation_type;

 END is_segment_dependent;

/*===========================================================================+
 | PROCEDURE                                                                 |
 |    get_parent_segment                                                     |
 |                                                                           |
 | DESCRIPTION                                                               |
 |    Returns parent segment number and application column name for a        |
 |    given child segment number and structure id.                           |
 |                                                                           |
 | EXTERNAL PROCEDURES/FUNCTIONS ACCESSED                                    |
 |                                                                           |
 |                                                                           |
 | ARGUMENTS    							     |
 |              p_application_id      IN  NUMBER,		             |
 |              p_flex_code           IN  VARCHAR2                           |
 |              p_structure_id        IN  NUMBER                             |
 |              p_child_segment_num   IN  NUMBER                             |
 |              p_parent_segment_num  OUT NOCOPY NUMBER                             |
 |              p_parent_col_name     OUT NOCOPY VARCHAR                            |
 |                                                                           |
 |                                                                           |
 |                                                                           |
 | NOTES                                                                     |
 |                                                                           |
 | MODIFICATION HISTORY                                                      |
 |     03-Aug-00  Shishir Joshi    Created                                   |
 |                                                                           |
 +===========================================================================*/

 PROCEDURE get_parent_segment(p_application_id       IN  NUMBER
			      ,p_flex_code           IN  VARCHAR2
			      ,p_structure_id        IN  NUMBER
			      ,p_child_segment_num   IN  NUMBER
			      ,p_parent_segment_num  OUT NOCOPY NUMBER
			      ,p_parent_col_name     OUT NOCOPY VARCHAR2
			      ) IS
 BEGIN
    SELECT DECODE(V.PARENT_FLEX_VALUE_SET_ID,
		  NULL,SG.SEGMENT_Num , SG2.SEGMENT_num)   parent_seg_num,
           DECODE(V.PARENT_FLEX_VALUE_SET_ID,
		  NULL,NULL , SG2.application_column_name) parent_app_col_name
      INTO p_parent_segment_num,
           p_parent_col_name
    FROM   FND_ID_FLEXS K,
           FND_APPLICATION_VL A,
           FND_ID_FLEX_STRUCTURES_VL S,
           FND_ID_FLEX_SEGMENTS_VL SG,
           FND_FLEX_VALUE_SETS V,
           FND_ID_FLEX_SEGMENTS_VL SG2,
           FND_FLEX_VALIDATION_TABLES T
   WHERE K.APPLICATION_ID = A.APPLICATION_ID
   AND   K.APPLICATION_ID = S.APPLICATION_ID
   AND   K.ID_FLEX_CODE = S.ID_FLEX_CODE
   AND   S.ENABLED_FLAG = 'Y'
   AND   K.APPLICATION_ID = SG.APPLICATION_ID
   AND   K.ID_FLEX_CODE = SG.ID_FLEX_CODE
   AND   S.ID_FLEX_NUM = SG.ID_FLEX_NUM
   AND   SG.ENABLED_FLAG = 'Y'
   AND   SG.FLEX_VALUE_SET_ID = V.FLEX_VALUE_SET_ID
   AND   V.PARENT_FLEX_VALUE_SET_ID = SG2.FLEX_VALUE_SET_ID(+)
   AND   K.APPLICATION_ID = NVL(SG2.APPLICATION_ID, K.APPLICATION_ID)
   AND   K.ID_FLEX_CODE = NVL(SG2.ID_FLEX_CODE, K.ID_FLEX_CODE)
   AND   S.ID_FLEX_NUM = NVL(SG2.ID_FLEX_NUM, S.ID_FLEX_NUM)
   AND   NVL(SG2.ENABLED_FLAG, 'Y') = 'Y'
   AND   NVL(SG2.SEGMENT_NUM,0) = (SELECT NVL(MAX(SG3.SEGMENT_NUM),0)
				   FROM FND_ID_FLEX_SEGMENTS SG3
				   WHERE SG3.APPLICATION_ID = K.APPLICATION_ID
				   AND SG3.ID_FLEX_CODE = K.ID_FLEX_CODE
				   AND SG3.ID_FLEX_NUM = S.ID_FLEX_NUM
				   AND SG3.FLEX_VALUE_SET_ID = V.PARENT_FLEX_VALUE_SET_ID
				   AND SG3.SEGMENT_NUM < SG.SEGMENT_NUM
				   AND SG3.ENABLED_FLAG = 'Y')
   AND V.FLEX_VALUE_SET_ID = T.FLEX_VALUE_SET_ID(+)
   AND k.application_id    = p_application_id
   AND k.id_flex_code      = p_flex_code
   AND s.id_flex_num       = p_structure_id
   AND sg.segment_num      = p_child_segment_num;

 EXCEPTION
    WHEN OTHERS THEN
     	app_exception.raise_exception;
 END get_parent_segment;

/*===========================================================================+
 | FUNCTION                                                                  |
 |    get_segment_number                                                     |
 |                                                                           |
 | DESCRIPTION                                                               |
 |    Returns the segment number for given chart of accounts and qualifier.  |
 |    This function was added because fnd_flex_apis does not have an api to  |
 |    to return the segment number.                                          |
 |                                                                           |
 | EXTERNAL PROCEDURES/FUNCTIONS ACCESSED                                    |
 |                                                                           |
 |                                                                           |
 | ARGUMENTS    							     |
 |              p_application_id      IN  NUMBER,		             |
 |              p_flex_code           IN  VARCHAR2                           |
 |              p_structure_id        IN  NUMBER                             |
 |              p_flex_qual_name      IN  VARCHAR2                           |
 |              p_seg_num             OUT NOCOPY NUMBER                             |
 |                                                                           |
 |                                                                           |
 | NOTES                                                                     |
 |                                                                           |
 | MODIFICATION HISTORY                                                      |
 |    10-May-00   Dimple Shah      Created.                                  |
 |                                                                           |
 +===========================================================================*/

FUNCTION  get_segment_number(p_application_id      IN  NUMBER,
                             p_flex_code           IN  VARCHAR2,
                             p_structure_id        IN  NUMBER,
                             p_flex_qual_name      IN  VARCHAR2,
                             p_seg_num             OUT NOCOPY NUMBER)
RETURN BOOLEAN
IS
   l_seg_col      VARCHAR2(30);
   l_seg_num      NUMBER;
   dummy          BOOLEAN  := FALSE;
   return_value   BOOLEAN  := FALSE;

BEGIN
   dummy :=  fnd_flex_apis.get_segment_column(p_application_id, p_flex_code,
                                              p_structure_id,
                                              p_flex_qual_name,
                                              l_seg_col);

   FOR segments_rec in flex_segments_csr(p_structure_id) LOOP
       IF segments_rec.application_column_name = l_seg_col THEN
          p_seg_num  := segments_rec.segment_num;
          return_value := TRUE;
       ELSE
          return_value := FALSE;
       END IF;
   END LOOP;
   RETURN return_value;

EXCEPTION
   when others then
     app_exception.raise_exception;

END get_segment_number;

END XLA_FLEX_UTIL;

/
