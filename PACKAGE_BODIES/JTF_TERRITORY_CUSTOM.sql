--------------------------------------------------------
--  DDL for Package Body JTF_TERRITORY_CUSTOM
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."JTF_TERRITORY_CUSTOM" AS
/* $Header: jtfptrcb.pls 120.0 2005/06/02 18:20:49 appldev ship $ */
--    ---------------------------------------------------
--    Start of Comments
--    ---------------------------------------------------
--    PACKAGE NAME:   JTF_TERRITORY_CUSTOM
--    ---------------------------------------------------
--    PURPOSE
--      This package will contain all of the user defined function
--      that can be used in Territory assignment rules. This can be
--      used by customers to include complex processing as part of
--      Territory rules.
--
--    PROCEDURES:
--         (see below for specification)
--
--    NOTES
--      This package is publicly available for use
--
--    HISTORY
--      06/09/99    VNEDUNGA         Created
--      04/10/00    VNEDUNGA         Adding new validation routines
--      05/08/00    VNEDUNGA         Adding inventory ietem validation
--      06/19/00    VNEDUNGA         Adding check_partnership function call
--      07/24/00    JDOCHERT         Adding Chk_party_id function call
--                                   Adding Chk_comp_name_range function call
--      08/18/00    JDOCHERT         Changed functions that call AS and HZ schemas
--                                   to use dynamic SQl so that there are no dependencies
--      09/05/00    JDOCHERT         Updated SQl for check_account_Hierarchy to remove
--                                   extra ")" that was causing error
--      12/12/00    EIHSU            Added like condition for BETWEEN in comp_name_range comparison
--                                   as we want upper limit to be inclusive of all comp names like HIGH_VALUE_CHAR
--      10/05/01    jdochert         2035543 bug fix
--
--    End of Comments
--

  FUNCTION chk_party_id
     ( p_Party_Id      IN NUMBER,
       p_Terr_Id       IN NUMBER,
       p_Terr_Qual_Id  IN NUMBER) RETURN BOOLEAN
  AS
      l_dummy NUMBER;
  --
  BEGIN

      --dbms_output.put_line('chk_party_id '|| p_party_id || '  ' || p_terr_id || '   ' || p_terr_qual_id);

      Select 1
        into l_dummy
        from jtf_terr_values jtv
       where jtv.terr_qual_id = p_Terr_Qual_Id and
             (         ( jtv.COMPARISON_OPERATOR IN ('!=', '<>') and jtv.low_value_char_id <> p_party_id )
                    or ( jtv.COMPARISON_OPERATOR = '='  and jtv.low_value_char_id =  p_party_id )
              )
              and rownum < 2;

        RETURN TRUE;

  Exception
      When NO_DATA_FOUND Then
           return FALSE;
  --
  End chk_party_id;


  FUNCTION chk_comp_name_range
     ( p_company_name  IN VARCHAR2,
       p_Terr_Id       IN NUMBER,
       p_Terr_Qual_Id  IN NUMBER) RETURN BOOLEAN
  AS
      l_dummy NUMBER;
  --
  BEGIN

      --dbms_output.put_line('chk_comp_name_range '|| p_company_name || '  ' || p_terr_id || '   ' || p_terr_qual_id);

      Select 1
        into l_dummy
        from jtf_terr_values jtv
       where jtv.terr_qual_id = p_Terr_Qual_Id and
             (         ( jtv.COMPARISON_OPERATOR = '<'  and jtv.low_value_char <  p_company_name )
                    or ( jtv.COMPARISON_OPERATOR = '<=' and jtv.low_value_char <= p_company_name )
                    or ( jtv.COMPARISON_OPERATOR = '<>' and jtv.low_value_char <> p_company_name )
                    or ( jtv.COMPARISON_OPERATOR = '='  and jtv.low_value_char =  p_company_name )
                    or ( jtv.COMPARISON_OPERATOR = '>'  and jtv.low_value_char >  p_company_name )
                    or ( jtv.COMPARISON_OPERATOR = '>=' and jtv.low_value_char >= p_company_name )
                    or (     UPPER(jtv.COMPARISON_OPERATOR) = 'BETWEEN'
                         and (   (p_company_name between jtv.low_value_char and jtv.high_value_char )
                              or (p_company_name like jtv.high_value_char )
                             )
                       )
                    or ( UPPER(jtv.COMPARISON_OPERATOR) = 'LIKE' and  p_company_name like jtv.low_value_char )
                    or ( UPPER(jtv.COMPARISON_OPERATOR) = 'NOT BETWEEN' AND
                         (p_company_name not between jtv.low_value_char and jtv.high_value_char )
                       )
                    or ( UPPER(jtv.COMPARISON_OPERATOR) = 'NOT LIKE'    and p_company_name not like jtv.low_value_char  )
              )
              and rownum < 2;

        RETURN TRUE;

  Exception
      When NO_DATA_FOUND Then
           return FALSE;
  --
  End chk_comp_name_range;

  FUNCTION check_account_Hierarchy
     ( p_Hierarchy_Id  IN NUMBER,
       p_Terr_Id       IN NUMBER,
       p_Terr_Qual_Id  IN NUMBER) RETURN BOOLEAN
  AS

      query_str       VARCHAR2(1000);

      l_dummy NUMBER;
  BEGIN



      query_str :=
         ' SELECT 1 ' ||
         ' FROM jtf_terr_values jtv ' ||
         ' WHERE jtv.terr_qual_id = :p_terr_qual_id ' ||
         '   AND rownum < 2 ' ||
         '   AND :p_hierarchy_id IN (  ' ||
         '       SELECT hpr.subject_id ' ||
         '       FROM   hz_party_relationships hpr ' ||
         '       WHERE  hpr.party_relationship_type = ''SUBSIDIARY_OF'' ' ||
         '       START WITH hpr.object_id = jtv.low_value_char_id ' ||
         '       CONNECT BY hpr.object_id = PRIOR hpr.subject_id ' ||
         '       AND    hpr.party_relationship_type = ''SUBSIDIARY_OF'' ) ';

      EXECUTE IMMEDIATE query_str
      INTO l_dummy
      USING p_terr_qual_id, p_hierarchy_id ;

       return TRUE;
  Exception
      When NO_DATA_FOUND Then
           return FALSE;
  --
  END check_account_Hierarchy;


  -- Function check whether the party is a partner
  FUNCTION check_partnership
     ( p_Partner_Id    IN NUMBER,
       p_Terr_Id       IN NUMBER,
       p_Terr_Qual_Id  IN NUMBER) RETURN BOOLEAN
  AS

      query_str       VARCHAR2(1000);
      l_dummy         NUMBER;

  BEGIN

      query_str :=
         ' SELECT 1 ' ||
         ' FROM jtf_terr_values jtv ' ||
         '    , hz_party_relationships hpr ' ||
         ' WHERE jtv.terr_qual_id = :p_terr_qual_id ' ||
         '   AND hpr.subject_id = :p_partner_Id ' ||
         '   AND hpr.object_id = jtv.low_value_char_id ' ||
         '   AND hpr.party_relationship_type = ''PARTNER_OF'' ' ||
         '   AND rownum < 2 ';

      EXECUTE IMMEDIATE query_str
      INTO l_dummy
      USING p_terr_qual_id, p_partner_id ;

       return TRUE;
  Exception
      When NO_DATA_FOUND Then
           return FALSE;
  --
  END check_partnership;



  -- Check account classification
  FUNCTION check_account_classification
     ( p_Party_Id      IN NUMBER,
       p_Terr_Id       IN NUMBER,
       p_Terr_Qual_Id  IN NUMBER) RETURN BOOLEAN
  AS
        query_str       VARCHAR2(1000);

        l_dummy NUMBER;
  BEGIN

      query_str :=
         ' SELECT 1 ' ||
         ' FROM jtf_terr_values jtv ' ||
         '    , as_interests ai ' ||
         ' WHERE jtv.terr_qual_id = :p_terr_qual_id ' ||
         '   AND ai.customer_id = :p_Party_Id ' ||
         '   AND ai.interest_type_id = jtv.interest_type_id ' ||
         '   AND ( NVL(jtv.primary_interest_code_id, -1) = -1 ' ||
         '        OR ai.primary_interest_code_id = jtv.primary_interest_code_id ) ' ||
         '   AND ( NVL(jtv.secondary_interest_code_id, -1) = -1 ' ||
         '        OR ai.secondary_interest_code_id = jtv.secondary_interest_code_id ) ' ||
         '   AND ai.interest_use_code = ''COMPANY_CLASSIFICATION'' ' ||
         '   AND rownum < 2 ';

      EXECUTE IMMEDIATE query_str
      INTO l_dummy
      USING p_terr_qual_id, p_party_id ;

      return TRUE;
  Exception
      When NO_DATA_FOUND Then
           return FALSE;
  END check_account_classification;


  -- Check Oppor classification rule
  FUNCTION check_Oppor_classification
      ( p_Lead_Id       IN NUMBER,
        p_Terr_Id       IN NUMBER,
        p_Terr_Qual_Id  IN NUMBER) RETURN BOOLEAN
  AS
        query_str       VARCHAR2(1000);

        l_dummy NUMBER;
  BEGIN

      query_str :=
         ' SELECT 1 ' ||
         ' FROM jtf_terr_values jtv ' ||
         '    , as_interests ai ' ||
         ' WHERE jtv.terr_qual_id = :p_terr_qual_id ' ||
         '   AND ai.lead_id = :p_Lead_Id ' ||
         '   AND ai.interest_type_id = jtv.interest_type_id ' ||
         '   AND ( NVL(jtv.primary_interest_code_id, -1) = -1 ' ||
         '        OR ai.primary_interest_code_id = jtv.primary_interest_code_id ) '||
         '   AND ( NVL(jtv.secondary_interest_code_id, -1) = -1 ' ||
         '        OR ai.secondary_interest_code_id = jtv.secondary_interest_code_id ) ' ||
         '   AND ai.interest_use_code = ''LEAD_CLASSIFICATION'' ' ||
         '   AND rownum < 2 ';


      EXECUTE IMMEDIATE query_str
      INTO l_dummy
      USING p_terr_qual_id, p_lead_id ;


      return TRUE;
  Exception
      When NO_DATA_FOUND Then
           return FALSE;

  END check_Oppor_classification;


  -- Check Opportunity Expected purchase
  FUNCTION check_Oppor_Exp_Purchase
      ( p_Lead_Id       IN NUMBER,
        p_Terr_Id       IN NUMBER,
        p_Terr_Qual_Id  IN NUMBER) RETURN BOOLEAN
  AS
        query_str       VARCHAR2(1000);

        l_dummy NUMBER;
  BEGIN

       query_str :=
        ' SELECT 1 ' ||
         ' FROM jtf_terr_values jtv ' ||
         '    , as_lead_lines al ' ||
         ' WHERE jtv.terr_qual_id = :p_terr_qual_id ' ||
         ' AND al.lead_id = :p_Lead_Id ' ||
         ' AND al.interest_type_id = jtv.interest_type_id ' ||
         ' AND ( NVL(jtv.primary_interest_code_id, -1) = -1 ' ||
         '     OR al.primary_interest_code_id = jtv.primary_interest_code_id ) ' ||
         ' AND ( NVL(jtv.secondary_interest_code_id, -1) = -1 ' ||
         '     OR al.secondary_interest_code_id = jtv.secondary_interest_code_id) ' ||
         ' AND rownum < 2 ';

      EXECUTE IMMEDIATE query_str
      INTO l_dummy
      USING p_terr_qual_id, p_lead_id ;

      return TRUE;
  Exception
      When NO_DATA_FOUND Then
           return FALSE;
  END check_Oppor_Exp_Purchase;

  -- Check lead Expected purchase
  FUNCTION check_Lead_Exp_Purchase
      ( p_Sales_Lead_Id IN NUMBER,
        p_Terr_Id       IN NUMBER,
        p_Terr_Qual_Id  IN NUMBER) RETURN BOOLEAN
  AS
        query_str       VARCHAR2(1000);

       l_dummy NUMBER;
  BEGIN

      query_str :=
         ' SELECT 1 ' ||
         ' FROM jtf_terr_values jtv ' ||
         '    , as_sales_lead_lines asl ' ||
         ' WHERE jtv.terr_qual_id = :p_terr_qual_id ' ||
         '   AND asl.sales_lead_id = :p_Sales_Lead_Id ' ||
         '   AND asl.interest_type_id = jtv.interest_type_id ' ||
         '   AND ( NVL(jtv.primary_interest_code_id, -1) = -1 ' ||
         '       OR asl.primary_interest_code_id = jtv.primary_interest_code_id ) ' ||
         '   AND ( NVL(jtv.secondary_interest_code_id, -1) = -1 ' ||
         '       OR asl.secondary_interest_code_id = jtv.secondary_interest_code_id ) ' ||
         '   AND rownum < 2 ';

      EXECUTE IMMEDIATE query_str
      INTO l_dummy
      USING p_terr_qual_id, p_sales_lead_id ;

      return TRUE;
  EXCEPTION
      WHEN OTHERS THEN
           RETURN FALSE;
  END check_Lead_Exp_Purchase;
  --
  -- Check inventory item
  FUNCTION check_Inventory_Item
      ( p_Lead_Id       IN NUMBER,
        p_Terr_Id       IN NUMBER,
        p_Terr_Qual_Id  IN NUMBER) RETURN BOOLEAN
  AS
      query_str       VARCHAR2(1000);

      l_dummy NUMBER;

  BEGIN

      query_str :=
         ' SELECT 1 ' ||
         ' FROM jtf_terr_values jtv ' ||
         '    , as_lead_lines al ' ||
         ' WHERE jtv.terr_qual_id = :p_terr_qual_id ' ||
         '   AND al.Lead_id = :p_Lead_Id ' ||
         '   AND al.inventory_item_id = jtv.low_value_char_id ' ||
         '   AND rownum < 2 ';

      EXECUTE IMMEDIATE query_str
      INTO l_dummy
      USING p_terr_qual_id, p_lead_id ;

      return TRUE;
  Exception
      When NO_DATA_FOUND Then
           return FALSE;
  END check_Inventory_Item;
--

END JTF_TERRITORY_CUSTOM;

/
