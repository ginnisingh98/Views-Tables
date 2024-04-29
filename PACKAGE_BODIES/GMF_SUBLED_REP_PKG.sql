--------------------------------------------------------
--  DDL for Package Body GMF_SUBLED_REP_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."GMF_SUBLED_REP_PKG" AS
/* $Header: GMFDSURB.pls 120.1.12010000.2 2008/11/11 16:25:38 rpatangy ship $ */

/* FUNCTION BeforeReportTrigger(P_REFERENCE_NO     IN NUMBER,
                                P_LEGAL_ENTITY_ID  IN NUMBER,
                                P_LEDGER_ID        IN NUMBER,
                                P_COST_TYPE_ID     IN NUMBER,
                                P_FISCAL_YEAR      IN NUMBER,
                                P_PERIOD           IN NUMBER,
                                P_START_DATE       IN DATE,
                                P_END_DATE         IN DATE,
                                P_ENTITY_CODE      IN VARCHAR2,
                                P_EVENT_CLASS      IN VARCHAR2,
                                P_EVENT_TYPE       IN VARCHAR2) RETURN BOOLEAN IS  */
FUNCTION BeforeReportTrigger RETURN BOOLEAN IS
    l_where_clause  VARCHAR2(2000);
    l_event_type_all VARCHAR2(10);
  BEGIN
       --  Need to put a log message if reference no and legal entity al null

    l_where_clause := '1=2';
/*
       IF P_REFERENCE_NO IS NOT NULL THEN
          l_where_clause := ' sr.reference_no = :P_REFERENCE_NO' ;
       ELSE
          -- If there is no reference no then user need to pass below parameter values
         IF P_LEGAL_ENTITY_ID IS NOT NULL THEN
           l_where_clause := ' sr.legal_entity_id = :P_LEGAL_ENTITY_ID ' ;
         END IF; */
/*         IF P_LEDGER_ID IS NOT NULL THEN
           l_where_clause :=  l_where_clause ||' AND sr.ledger_id = :P_LEDGER_ID ' ;
         END IF;
         IF P_COST_TYPE_ID IS NOT NULL THEN
           l_where_clause := l_where_clause ||' AND sr.valuation_cost_type_id = P_COST_TYPE_ID ' ;
         END IF; */
   /*  There is no columns in extract_headers for fiscal_year and period.
         IF p_fiscal_year IS NOT NULL THEN
           l_where_clause := l_where_clause ||' AND ' || p_fiscal_year ;
         END IF;
         IF p_period IS NOT NULL THEN
           l_where_clause := l_where_clause ||' AND  ' || p_period ;
         END IF;
   */
--       END IF;  -- end for reference_no
/*
          -- Incase user changes the dates for report output
         IF l_where_clause IS NOT NULL AND P_START_DATE IS NOT NULL THEN
           l_where_clause := l_where_clause ||' AND sr.transaction_date >= ' || P_START_DATE ;
         END IF;
         IF l_where_clause IS NOT NULL AND P_END_DATE IS NOT NULL THEN
           l_where_clause := l_where_clause ||' AND sr.transaction_date <= ' || P_END_DATE ;
         END IF;
           -- If the entity code is null means all report runs for all entity codes
         IF l_where_clause IS NOT NULL AND P_ENTITY_CODE IS NOT NULL THEN
           l_where_clause :=l_where_clause ||' AND sr.entity_code = '||P_ENTITY_CODE;
         END IF;
         IF l_where_clause IS NOT NULL AND P_EVENT_CLASS IS NOT NULL THEN
           l_where_clause := l_where_clause ||' AND sr.event_class_code = ' || P_EVENT_CLASS ;
         END IF;
         IF l_where_clause IS NOT NULL AND P_EVENT_TYPE IS NOT NULL THEN
             -- event type passed as all then no need to add condition, query for all event types
              l_event_type_all := P_EVENT_CLASS||'_ALL';
            IF P_EVENT_TYPE <> l_event_type_all THEN
              l_where_clause := l_where_clause ||' AND sr.event_type_code = ' || P_EVENT_TYPE;
            END IF;
         END IF;
      */
         p_where_clause := l_where_clause;
--      RETURN p_where_clause;

     RETURN TRUE;
  END BeforeReportTrigger;

    -- get Legal entity name
  FUNCTION get_le_name(p_le_id IN NUMBER) RETURN VARCHAR2 IS
    l_le_name gmf_legal_entities.legal_entity_name%TYPE :='';

  BEGIN
    SELECT legal_entity_name INTO l_le_name FROM gmf_legal_entities
    WHERE legal_entity_id = p_le_id;

        RETURN l_le_name;

      EXCEPTION
         WHEN NO_DATA_FOUND THEN
         RETURN l_le_name;
  END get_le_name;

   -- Get Ledger name
  FUNCTION get_ledger_name(p_led_id IN NUMBER) RETURN VARCHAR2 IS
    l_ledger_name  gl_ledgers.name%TYPE :='';
  BEGIN
     SELECT name INTO l_ledger_name FROM gl_ledgers
     WHERE ledger_id = p_led_id;

        RETURN l_ledger_name;

      EXCEPTION
         WHEN NO_DATA_FOUND THEN
          RETURN l_ledger_name;
  END get_ledger_name;

   --get Cost type name
  FUNCTION get_cost_type(p_ct_id IN NUMBER) RETURN VARCHAR2 IS
    l_cost_type cm_mthd_mst.cost_mthd_code%TYPE :='';
  BEGIN
     SELECT cost_mthd_code INTO l_cost_type FROM cm_mthd_mst
     WHERE cost_type_id = p_ct_id;

        RETURN l_cost_type;

      EXCEPTION
         WHEN NO_DATA_FOUND THEN
          RETURN l_cost_type;
  END get_cost_type;

   -- get the organization code
 FUNCTION get_organization_code (p_org_id IN NUMBER, p_ref_no IN NUMBER) RETURN VARCHAR2 IS

   l_org_cd  mtl_parameters.organization_code%TYPE :='';
 BEGIN
    IF p_org_id IS NOT NULL THEN
      SELECT organization_code INTO l_org_cd FROM mtl_parameters WHERE organization_id = p_org_id;
    ELSIF p_ref_no IS NOT NULL THEN
       SELECT DISTINCT organization_code INTO l_org_cd FROM mtl_parameters mp, gmf_xla_extract_headers eh
       WHERE mp.organization_id = eh.organization_id AND eh.reference_no = p_ref_no;
    END IF;

     RETURN l_org_cd;

  EXCEPTION
    WHEN NO_DATA_FOUND THEN
       RETURN l_org_cd;
    WHEN TOO_MANY_ROWS THEN
       RETURN l_org_cd;

 END get_organization_code;

    -- get Item number and Description
  FUNCTION get_item_desc (p_item_id IN NUMBER, p_org_id IN NUMBER) RETURN VARCHAR2 IS
       l_ItemDesc  VARCHAR2(500) := '';
    BEGIN
      SELECT mif.item_number ||' - '||mif.description INTO l_ItemDesc
      FROM mtl_item_flexfields mif
      WHERE mif.inventory_item_id = p_item_id
        AND mif.organization_id   = p_org_id ;

        RETURN l_ItemDesc;
      EXCEPTION
         WHEN NO_DATA_FOUND THEN
          RETURN l_ItemDesc;
    END get_item_desc;

    -- get Organization name
   FUNCTION get_org_name (p_org_id IN NUMBER)
       RETURN  VARCHAR2  IS
       l_Orgname  VARCHAR2(300):= '';

    BEGIN

      SELECT name INTO l_Orgname FROM hr_all_organization_units WHERE organization_id = p_org_id;

      RETURN l_Orgname;

      EXCEPTION
         WHEN NO_DATA_FOUND THEN
          RETURN l_Orgname;
    END get_org_name;

     -- Get entity Code description
    FUNCTION get_entity_code_desc(p_entity_cd IN VARCHAR2) RETURN VARCHAR2 IS
     l_entity_code_desc xla_entity_types_vl.name%TYPE :='';
    BEGIN
      SELECT name INTO l_entity_code_desc FROM xla_entity_types_vl WHERE application_id =555 AND entity_code = p_entity_cd;

      RETURN l_entity_code_desc;

      EXCEPTION
         WHEN NO_DATA_FOUND THEN
          RETURN l_entity_code_desc;
    END get_entity_code_desc;

     -- Get event class description
    FUNCTION get_event_class_desc(p_entity_cd IN VARCHAR2, p_event_class_cd IN VARCHAR2) RETURN VARCHAR2 IS
      l_event_class_desc xla_entity_types_vl.name%TYPE :='';
    BEGIN
      SELECT name INTO l_event_class_desc FROM xla_event_classes_vl
      WHERE application_id =555 AND entity_code = p_entity_cd AND event_class_code = p_event_class_cd;

      RETURN l_event_class_desc;

      EXCEPTION
         WHEN NO_DATA_FOUND THEN
          RETURN l_event_class_desc;
    END get_event_class_desc;

     -- Get Event Type description
    FUNCTION get_event_type_desc(p_entity_cd IN VARCHAR2, p_event_class_cd IN VARCHAR2,p_event_type_cd IN VARCHAR2 )
    RETURN VARCHAR2 IS
      l_event_type_desc xla_entity_types_vl.name%TYPE :='';

    BEGIN
      SELECT name INTO l_event_type_desc FROM xla_event_types_vl
      WHERE application_id =555 AND entity_code = p_entity_cd AND event_class_code = p_event_class_cd AND event_type_code = p_event_type_cd;

      RETURN l_event_type_desc;
          EXCEPTION
         WHEN NO_DATA_FOUND THEN
          RETURN l_event_type_desc;
    END get_event_type_desc;

    FUNCTION get_where_clause RETURN VARCHAR2 IS
       l_where_clause VARCHAR2(2000);
    BEGIN
      RETURN l_where_clause;
    END get_where_clause;

END gmf_subled_rep_pkg;

/
