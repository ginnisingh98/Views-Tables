--------------------------------------------------------
--  DDL for Package Body GMF_UTILITIES_GRP
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."GMF_UTILITIES_GRP" AS
/*  $Header: gmfputlb.pls 120.2.12010000.2 2009/11/11 19:34:23 rpatangy ship $ */

--****************************************************************************************************
--*                                                                                                  *
--* Oracle Process Manufacturing                                                                     *
--* ============================                                                                     *
--*                                                                                                  *
--* Package GMF_UTILITIES_GRP                                                                        *
--* ---------------------------                                                                      *
--* This package contains the common utility functions                                                      *
--* For individual procedures' descriptions, see the                                                 *
--* description in front of each one.                                                                *
--*                                                                                                  *
--*                                                                                                  *
--* HISTORY                                                                                          *
--* =======                                                                                          *
--* 8-Sep -2005   Jahnavi Boppana    created                                                         *
--* 01-Oct-2005   Prasad Marada   Added get organization, get item methods                           *
--*                                                                                                  *
--****************************************************************************************************

/*=========================================================
  FUNCTION : GET_ACCOUNT_DESC

  DESCRIPTION
    This function will return the account description for the
    account_id and legal_entity_id passed
  AUTHOR : Jahnavi Boppana  INVCONV  August 2005
 ==========================================================*/


 FUNCTION GET_ACCOUNT_DESC(P_ACCOUNT IN VARCHAR2,
                           P_LEGAL_ENTITY_ID IN NUMBER,
                           P_FLAG IN VARCHAR2) RETURN VARCHAR2 IS
    ACCOUNT_DESC VARCHAR2(2000);
    ACCOUNT_KEY  VARCHAR2(1000);
  BEGIN
      IF P_FLAG = 'I' THEN
        ACCOUNT_KEY  := GET_ACCOUNT_CODE(TO_NUMBER(p_account), p_legal_entity_id);
      ELSIF P_FLAG = 'C' THEN
        account_key := P_ACCOUNT;
      END IF;
      ACCOUNT_DESC := GET_ACCOUNT_DESC(P_ACCOUNT_KEY => account_key, p_legal_entity_id => p_legal_entity_id);
      RETURN (ACCOUNT_DESC);
 END GET_ACCOUNT_DESC;


/*=========================================================
  FUNCTION : GET_ACCOUNT_DESC

  DESCRIPTION
    This function will return the account description for the
    account_id and legal_entity_id passed
  AUTHOR : Jahnavi Boppana  INVCONV  August 2005
 ==========================================================*/


   FUNCTION GET_ACCOUNT_DESC(P_ACCOUNT_ID IN NUMBER, P_LEGAL_ENTITY_ID IN NUMBER) RETURN VARCHAR2 IS
      ACCOUNT_DESC VARCHAR2(2000);
      ACCOUNT_KEY  VARCHAR2(1000);
   BEGIN
      ACCOUNT_KEY  := GET_ACCOUNT_CODE(p_account_id, p_legal_entity_id);
      ACCOUNT_DESC := GET_ACCOUNT_DESC(account_key, p_legal_entity_id);
      RETURN (ACCOUNT_DESC);
   END GET_ACCOUNT_DESC;

   /*=========================================================
  FUNCTION : GET_ACCOUNT_CODE

  DESCRIPTION
    This function will return the account code for the
    account_id and legal_entity_id passed
  AUTHOR : Jahnavi Boppana  INVCONV  August 2005
 ==========================================================*/

   FUNCTION GET_ACCOUNT_CODE(P_ACCOUNT_ID IN NUMBER, P_LEGAL_ENTITY_ID IN NUMBER) RETURN VARCHAR2 IS
      account_code VARCHAR2(1000);
      l_chart_of_accounts_id NUMBER(15);
      l_delimiter         varchar2(5);
      l_sql_stmt VARCHAR2(2000);

      TYPE t_seg_num IS TABLE OF FND_ID_FLEX_SEGMENTS.APPLICATION_COLUMN_NAME%TYPE INDEX BY BINARY_INTEGER;

      CURSOR segments(chart_of_accounts_id NUMBER) IS SELECT
                                 application_column_name
                                FROM
                                   fnd_id_flex_segments f
                                 WHERE
                                   f.id_flex_num = chart_of_accounts_id and
                                   f.application_id = 101          AND
                                   f.id_flex_code = 'GL#'           AND
                                   f.enabled_flag         = 'Y'
                                 ORDER BY    f.segment_num;
      l_seg_num   t_seg_num;

   BEGIN
      SELECT chart_of_accounts_id INTO l_chart_of_accounts_id FROM gmf_legal_entities
         WHERE legal_entity_id = p_legal_entity_id;
      l_delimiter := fnd_flex_ext.get_delimiter('SQLGL','GL#', l_chart_of_accounts_id);
      OPEN segments(l_chart_of_accounts_id);
      FETCH segments  bulk collect INTO l_seg_num;
      CLOSE segments;

      l_sql_stmt := 'SELECT ';
      FOR i  IN l_seg_num.first .. l_seg_num.last  LOOP
         IF i = l_seg_num.first THEN
            l_sql_stmt := l_sql_stmt||l_seg_num(i);
         ELSE
         l_sql_stmt := l_sql_stmt||'||'''||l_delimiter||'''||'||l_seg_num(i);
         END IF;
      END LOOP;

      l_sql_stmt := l_sql_stmt||' from gl_code_combinations where code_combination_id = '||
                     p_account_id||' and chart_of_accounts_id = '||l_chart_of_accounts_id;
      dbms_output.put_line(l_sql_stmt);

      EXECUTE IMMEDIATE l_sql_stmt INTO account_code;
      RETURN(ACCOUNT_CODE);
   END GET_ACCOUNT_CODE;


   /*=========================================================
  FUNCTION : GET_LEGAL_ENTITY

  DESCRIPTION
    This function will return the legal entity name for the
    legal_entity_id passed
  AUTHOR : Jahnavi Boppana  INVCONV  August 2005
 ==========================================================*/

 FUNCTION get_legal_entity(p_legal_entity_id IN NUMBER)
 RETURN VARCHAR2 IS

   CURSOR cp_legal_entity (cp_legal_entity_id gmf_legal_entities.legal_entity_id%TYPE) IS
   SELECT legal_entity_name FROM gmf_legal_entities
   WHERE legal_entity_id = cp_legal_entity_id;

   l_legal_entity_name gmf_legal_entities.legal_entity_name%TYPE := NULL;

 BEGIN
   OPEN cp_legal_entity(p_legal_entity_id);
   FETCH cp_legal_entity INTO l_legal_entity_name;
   CLOSE cp_legal_entity;

   RETURN(l_legal_entity_name);

 END get_legal_entity;

 /*=========================================================
  FUNCTION : GET_ORGANIZATION_NAME

  DESCRIPTION
    This function will return the organization name for the
    organization id passed
  AUTHOR : Jahnavi Boppana  INVCONV  August 2005
 ==========================================================*/


FUNCTION get_organization_name (p_organization_id IN NUMBER)
  RETURN VARCHAR2 IS

  CURSOR cur_organization (cp_organization_id hr_organization_units.organization_id%TYPE) IS
  SELECT name FROM hr_organization_units
  WHERE organization_id = cp_organization_id;

  l_organization_name hr_organization_units.name%TYPE;
 BEGIN
   OPEN cur_organization(p_organization_id);
   FETCH cur_organization INTO l_organization_name;
   CLOSE cur_organization;

   RETURN(l_organization_name);
 END get_organization_name;


/*=========================================================
  FUNCTION : GET_ORGANIZATION_CODE

  DESCRIPTION
    This function will return the organization code for the
    organization id passed
  AUTHOR : Jahnavi Boppana  INVCONV  August 2005
 ==========================================================*/
   FUNCTION get_organization_code(p_organization_id IN NUMBER)
      RETURN VARCHAR2 IS
      CURSOR cur_org_code (cp_org_id mtl_parameters.organization_id%TYPE) IS
      SELECT organization_code FROM mtl_parameters
      WHERE organization_id = cp_org_id;

     l_organization_code mtl_parameters.organization_code%TYPE;
   BEGIN

      OPEN cur_org_code (p_organization_id);
      FETCH cur_org_code INTO l_organization_code;
      CLOSE cur_org_code;

      RETURN(l_organization_code);
   END get_organization_code;

/*=========================================================
  FUNCTION : GET_ACCOUNT_DESC

  DESCRIPTION
    This function will return the account description for the
    account code and legal entity id passed
  AUTHOR : Jahnavi Boppana  INVCONV  August 2005
 ==========================================================*/


   FUNCTION GET_ACCOUNT_DESC(P_ACCOUNT_KEY IN VARCHAR2, P_LEGAL_ENTITY_ID IN NUMBER)RETURN VARCHAR2 IS
   TYPE t_segments is table of varchar2(240) INDEX BY BINARY_INTEGER;
   source_accounts     t_segments;

   x_description       VARCHAR2(4000) default '';
   l_account_desc    VARCHAR2(2000) default '';
   l_account_key    VARCHAR2(1000) default '';
   l_delimiter         varchar2(5);
   l_startdate        DATE;
   l_enddate         DATE;
   l_sobname         VARCHAR2(100);
   l_segmentname     VARCHAR2(100);
   l_segmentnum      NUMBER;
   l_segmentval      VARCHAR2(100);
   l_row_to_fetch    NUMBER;
   l_statuscode      NUMBER;
   l_segmentuom      VARCHAR2(100);
   l_start         NUMBER DEFAULT 1;
   l_end           NUMBER DEFAULT 0;
   l_deli_process  NUMBER DEFAULT 0;
   l_acct_no          VARCHAR2(32767);
   l_account_value VARCHAR2(32767);
   l_chart_of_accounts_id NUMBER(15);
   n number;

   function description
   (
   p_segment_num number,
   p_segment_value varchar2,
   p_chart_of_accounts_id NUMBER
   ) return varchar2
   is
       cursor cur_description
       (
       p_segment_num number,
       p_segment_value varchar2,
       p_chart_of_accounts_id NUMBER
       )
       is
       SELECT          VAL.description
       FROM            fnd_id_flex_segments FND,
                       fnd_flex_values_vl   VAL
       WHERE           FND.id_flex_num = p_chart_of_accounts_id
       AND             FND.segment_num          = NVL(p_segment_num, FND.segment_num)
       AND             FND.enabled_flag         = 'Y'
       AND             FND.flex_value_set_id    = VAL.flex_value_set_id
       AND             VAL.enabled_flag         = 'Y'
       AND             VAL.flex_value           = NVL(p_segment_value, VAL.flex_value)
       AND             NVL(VAL.description,' ') = NVL(null, NVL(VAL.description,' '))
       AND             VAL.summary_flag = 'N'
       AND             fnd.id_flex_code = 'GL#';

       l_description fnd_flex_values_vl.description%TYPE;
       begin
           open cur_description(p_segment_num, p_segment_value, p_chart_of_accounts_id);
           fetch cur_description into l_description;
           close cur_description;
           return l_description;
       end description;
   BEGIN
      SELECT chart_of_accounts_id INTO l_chart_of_accounts_id FROM gmf_legal_entities
         WHERE legal_entity_id = p_legal_entity_id;
      l_delimiter := fnd_flex_ext.get_delimiter('SQLGL','GL#', l_chart_of_accounts_id);
      n := lengthb(p_account_key) - lengthb(replace(p_account_key, l_delimiter,null));
     for i in 1..n+1 loop
         source_accounts(i) := null;
     end loop;
        l_deli_process := 1;

   l_start := 1;
   l_acct_no := p_account_KEY;
   FOR i IN 1..n+1 LOOP
     IF (l_deli_process <= n) THEN
       l_end := instr(l_acct_no,l_delimiter,1);
       l_account_value := SUBSTR(l_acct_no,l_start,l_end - 1);
       l_acct_no := SUBSTR(l_acct_no,l_end+1);
       source_accounts(i) := l_account_value;
       l_deli_process := l_deli_process + 1;
     ELSE
         l_account_value := SUBSTR(l_acct_no,l_start);
         source_accounts(i) := l_account_value;
     END IF;
   END LOOP;

   FOR i in 1..SOURCE_ACCOUNTS.COUNT  LOOP
               l_segmentval    := source_accounts(i);
               x_description    := description(i, l_segmentval,l_chart_of_accounts_id);

               IF i = 1 THEN
                   l_account_desc := x_description;
               ELSE
                   l_account_desc := l_account_desc || l_delimiter || x_description;
               END IF;

   END LOOP;
   RETURN l_account_desc;

 END GET_ACCOUNT_DESC;

/*=========================================================
  FUNCTION : get_item_number

  DESCRIPTION: function will return the item number for the
    Item id and organization id
  History
  Creted by : Prasad Marada  28-sep-2005
  Who   Date   Comment
 ==========================================================*/
 FUNCTION get_item_number (p_inventory_item_id IN NUMBER,
                           p_organization_id IN NUMBER) RETURN VARCHAR2 IS

  CURSOR cur_item_number (cp_inventory_item_id mtl_item_flexfields.inventory_item_id%TYPE,
                          cp_organization_id mtl_item_flexfields.organization_id%TYPE) IS
  SELECT item_number FROM mtl_item_flexfields
  WHERE inventory_item_id = cp_inventory_item_id
    AND organization_id = cp_organization_id;

    l_item_number VARCHAR2(2000);

 BEGIN

    OPEN cur_item_number (p_inventory_item_id, p_organization_id );
    FETCH cur_item_number INTO l_item_number;
    CLOSE cur_item_number;

    RETURN(l_item_number);

 END get_item_number;

/*=========================================================
  FUNCTION : get_cost_category

  DESCRIPTION: function will return the cost category for the
    cost category id and organization id
  History
  Creted by : Prasad Marada  28-sep-2005
  Who   Date   Comment
 ==========================================================*/
 FUNCTION get_cost_category(p_category_id IN NUMBER )  RETURN VARCHAR2 IS

 CURSOR cur_cost_category (cp_cost_category_id mtl_categories_kfv.category_id%TYPE) IS
 SELECT concatenated_segments FROM mtl_categories_kfv
 WHERE category_id = cp_cost_category_id;

 l_cost_category VARCHAR2(2000);

 BEGIN
  OPEN cur_cost_category (p_category_id);
  FETCH cur_cost_category INTO l_cost_category;
  CLOSE cur_cost_category;

  RETURN (l_cost_category);

 END get_cost_category;

  FUNCTION BEFOREREPORT RETURN BOOLEAN IS
  retrieval_cursor        VARCHAR2(4096);
  BEGIN
 /* B9100153 GMD FORMULA SECURITY FUNCTIONALITY, Disable the security  */

    retrieval_cursor := ' begin gmd_p_fs_context.set_additional_attr;  end; ' ;
    EXECUTE IMMEDIATE retrieval_cursor ;

    RETURN (TRUE);
  END BEFOREREPORT;


END GMF_UTILITIES_GRP;

/
