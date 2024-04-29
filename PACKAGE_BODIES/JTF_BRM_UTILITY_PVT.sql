--------------------------------------------------------
--  DDL for Package Body JTF_BRM_UTILITY_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."JTF_BRM_UTILITY_PVT" AS
/* $Header: jtfvbutb.pls 115.8 2002/02/14 13:18:30 pkm ship     $ */

FUNCTION Attribute_Format
/************************************************************
** This function is used in the JTF_BRM_ATTR_VALUES_V view
** to retriev and format the workflow attribute value so
** it can be queried as a text item in the JTFBRWKB form
************************************************************/
( p_attribute_type       IN VARCHAR2
, p_text_value           IN VARCHAR2
, p_number_value         IN NUMBER
, p_date_value           IN DATE
, p_format               IN VARCHAR2
)RETURN VARCHAR2
IS
  CURSOR c_lookup
  (b_lookup_type  IN VARCHAR2
  ,b_lookup_code  IN VARCHAR2
  )IS SELECT meaning
      FROM   wf_lookups
      WHERE lookup_type = b_lookup_type
      AND   lookup_code = b_lookup_code;

  l_meaning  VARCHAR2(80);

  BEGIN
    IF (p_attribute_type = 'VARCHAR2')
    THEN
      RETURN p_text_value;
    ELSIF (p_attribute_type = 'NUMBER')
    THEN
      RETURN to_char(p_number_value);
    ELSIF (p_attribute_type = 'DATE')
    THEN
      /*********************************************************************
      ** If a format mask is defined in Workflow use it
      *********************************************************************/
      IF (p_format IS NOT NULL)
      THEN
        RETURN to_char(p_date_value,p_format);
      ELSE
        /*********************************************************************
        ** If no format mask is defined use the default APPS format
        *********************************************************************/
        RETURN to_char(p_date_value,'DD/MM/YYYY');
      END IF;
    ELSIF (p_attribute_type = 'LOOKUP')
    THEN
      /*********************************************************************
      ** go and lookup the meaning, so it can be displayed
      *********************************************************************/
      IF (c_lookup%ISOPEN)
      THEN
        CLOSE c_lookup;
      END IF;
      OPEN c_lookup(p_format
                   ,p_text_value
                   );
      FETCH c_lookup INTO l_meaning;
      IF (c_lookup%FOUND)
      THEN
        CLOSE c_lookup;
        RETURN l_meaning;
      ELSE
        CLOSE c_lookup;
        RETURN NULL;
      END IF;
    ELSE
      RETURN NULL;
    END IF;
  END Attribute_Format;


  FUNCTION Attribute_Code
  /************************************************************
  **
  ** - If an attribute lookup value is specified for the rule
  **   the LOOKUP_CODE will be returned.
  ** - If no attribute lookup value is specified for the rule
  **   the default value will be returned
  **
  ************************************************************/
  (p_rule_id               IN VARCHAR2
  ,p_wf_item_type          IN VARCHAR2
  ,p_wf_process_name       IN VARCHAR2
  ,p_wf_attribute_name     IN VARCHAR2
  )RETURN VARCHAR2
  IS

  CURSOR c_set
  ( b_rule_id              IN VARCHAR2
  , b_wf_item_type         IN VARCHAR2
  , b_wf_process_name      IN VARCHAR2
  , b_wf_attribute_name    IN VARCHAR2
  )IS SELECT val.wf_attribute_type    attribute_type
      ,      val.text_value           attribute_value
      FROM jtf_brm_wf_attr_values_v   val
      ,    jtf_brm_processes          pro
      WHERE pro.rule_id                = b_rule_id
      AND   pro.workflow_item_type     = b_wf_item_type
      AND   pro.process_id             = val.wf_process_id
      AND   pro.workflow_item_type     = val.wf_item_type
      AND   pro.workflow_process_name  = val.wf_process_name
      AND   val.wf_process_name        = b_wf_process_name
      AND   val.wf_attribute_name      = b_wf_attribute_name;

  CURSOR c_default
  ( b_wf_item_type         IN VARCHAR2
  , b_wf_process_name      IN VARCHAR2
  , b_wf_attribute_name    IN VARCHAR2
  )IS SELECT wf1.text_default    attribute_value
      FROM wf_activity_attributes_vl wf1
      WHERE wf1.activity_version = (SELECT max(wf2.activity_version)
                                    FROM wf_activity_attributes_vl wf2
                                    WHERE wf2.activity_item_type = wf1.activity_item_type
                                    AND   wf2.activity_name      = wf1.activity_name
                                    )
      AND wf1.activity_item_type = b_wf_item_type
      AND wf1.activity_name      = b_wf_process_name
      AND wf1.name               = b_wf_attribute_name;


  r_set     c_set%ROWTYPE;
  r_default c_default%ROWTYPE;

  BEGIN
    IF (c_set%ISOPEN)
    THEN
      CLOSE c_set;
    END IF;

    OPEN c_set(p_rule_id
              ,p_wf_item_type
              ,p_wf_process_name
              ,p_wf_attribute_name
              );
    FETCH c_set INTO r_set;
    IF (c_set%FOUND)
    THEN
      CLOSE c_set;
      IF (r_set.attribute_type = 'LOOKUP')
      THEN
        RETURN r_set.attribute_value;
      ELSE
        RETURN NULL;
      END IF;
    ELSE
      CLOSE c_set;
      IF (c_default%ISOPEN)
      THEN
        CLOSE c_default;
      END IF;
      OPEN c_default(p_wf_item_type
                    ,p_wf_process_name
                    ,p_wf_attribute_name
                    );
      FETCH c_default INTO r_default;
      IF (c_default%FOUND)
      THEN
        CLOSE c_default;
        RETURN r_default.attribute_value;
      ELSE
        CLOSE c_default;
        RETURN NULL;
      END IF;
    END IF;
  EXCEPTION
  WHEN OTHERS
  THEN
    RETURN NULL;
  END Attribute_Code;

  FUNCTION Attribute_Meaning
  /************************************************************
  **
  ** - If an attribute lookup value is specified for the rule
  **   the Meaning will be returned.
  ** - If no attribute lookup value is specified for the rule
  **   the default value will be returned
  **
  ************************************************************/
  (p_rule_id               IN VARCHAR2
  ,p_wf_item_type          IN VARCHAR2
  ,p_wf_process_name       IN VARCHAR2
  ,p_wf_attribute_name     IN VARCHAR2
  )RETURN VARCHAR2
  IS

  CURSOR c_set
  ( b_rule_id              IN VARCHAR2
  , b_wf_item_type         IN VARCHAR2
  , b_wf_process_name      IN VARCHAR2
  , b_wf_attribute_name    IN VARCHAR2
  )IS SELECT val.wf_attribute_type    attribute_type
      ,      val.text_value           attribute_value
      ,      wlu.meaning              attribute_meaning
      FROM jtf_brm_wf_attr_values_v   val
      ,    jtf_brm_processes          pro
      ,    wf_lookups                 wlu
      WHERE pro.rule_id                = b_rule_id
      AND   pro.workflow_item_type     = b_wf_item_type
      AND   pro.process_id             = val.wf_process_id
      AND   pro.workflow_item_type     = val.wf_item_type
      AND   pro.workflow_process_name  = val.wf_process_name
      AND   val.wf_process_name        = b_wf_process_name
      AND   val.wf_attribute_name      = b_wf_attribute_name
      AND   wlu.lookup_type            = val.wf_attribute_format
      AND   wlu.lookup_code            = val.text_value
      ;

  CURSOR c_default
  ( b_wf_item_type         IN VARCHAR2
  , b_wf_process_name      IN VARCHAR2
  , b_wf_attribute_name    IN VARCHAR2
  )IS SELECT wf1.text_default    attribute_value
      ,      wlu.meaning         attribute_meaning
      FROM wf_activity_attributes_vl wf1
      ,    wf_lookups                wlu
      WHERE wf1.activity_version = (SELECT max(wf2.activity_version)
                                    FROM wf_activity_attributes_vl wf2
                                    WHERE wf2.activity_item_type = wf1.activity_item_type
                                    AND   wf2.activity_name      = wf1.activity_name
                                    )
      AND wf1.activity_item_type = b_wf_item_type
      AND wf1.activity_name      = b_wf_process_name
      AND wf1.name               = b_wf_attribute_name
      AND wlu.lookup_type        = wf1.format
      AND wlu.LOOKUP_CODE        = wf1.text_default
      ;

  r_set     c_set%ROWTYPE;
  r_default c_default%ROWTYPE;

  BEGIN
    IF (c_set%ISOPEN)
    THEN
      CLOSE c_set;
    END IF;

    OPEN c_set(p_rule_id
              ,p_wf_item_type
              ,p_wf_process_name
              ,p_wf_attribute_name
              );
    FETCH c_set INTO r_set;
    IF (c_set%FOUND)
    THEN
      CLOSE c_set;
      IF (r_set.attribute_type = 'LOOKUP')
      THEN
        RETURN r_set.attribute_meaning;
      ELSE
        RETURN NULL;
      END IF;
    ELSE
      CLOSE c_set;
      IF (c_default%ISOPEN)
      THEN
        CLOSE c_default;
      END IF;
      OPEN c_default(p_wf_item_type
                    ,p_wf_process_name
                    ,p_wf_attribute_name
                    );
      FETCH c_default INTO r_default;
      IF (c_default%FOUND)
      THEN
        CLOSE c_default;
        RETURN r_default.attribute_meaning;
      ELSE
        CLOSE c_default;
        RETURN NULL;
      END IF;
    END IF;
  EXCEPTION
  WHEN OTHERS
  THEN
    RETURN NULL;
  END Attribute_Meaning;

END JTF_BRM_UTILITY_PVT;

/
