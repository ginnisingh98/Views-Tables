--------------------------------------------------------
--  DDL for Package Body ZX_TDS_PROCESS_CEC_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."ZX_TDS_PROCESS_CEC_PVT" as
/* $Header: zxdilcecevalpvb.pls 120.17.12010000.2 2009/04/02 06:58:12 ssanka ship $ */

----------------------------
-- Constants
----------------------------
IDX_SHIP_FROM	CONSTANT NUMBER := 1;
IDX_SHIP_TO	CONSTANT NUMBER := 2;
IDX_POO		CONSTANT NUMBER := 3;
IDX_POA		CONSTANT NUMBER := 4;
IDX_BILL_TO	CONSTANT NUMBER := 5;
IDX_TRX		CONSTANT NUMBER := 6;
IDX_ITEM	CONSTANT NUMBER := 7;
IDX_TAX_CODE    CONSTANT NUMBER := 8;
STATS_INIT      CONSTANT NUMBER := 0;
STATS_TRUE      CONSTANT NUMBER := 1;
STATS_FALSE     CONSTANT NUMBER := -1;

EXP_ERROR_MESSAGE  EXCEPTION;

pr_flexfield				FND_DFLEX.DFLEX_R;
pr_flexinfo				FND_DFLEX.DFLEX_DR;
pr_segments                             FND_DFLEX.SEGMENTS_DR;
pr_contexts                             FND_DFLEX.CONTEXTS_DR;

pr_tax_rate                             NUMBER;
pr_do_not_use_this_tax_flag             BOOLEAN;
pr_do_not_use_this_group_flag           BOOLEAN;
pr_message_token			VARCHAR2(2500);

pr_action_rec_tbl action_rec_tbl_type;

-------------------------------------------------
-- Creating Table structure for Statistics info
------------------------------------------------
 TYPE pr_site_use_rec_type is RECORD(
    tax_classification    hz_cust_site_uses_all.tax_classification%type,
   cust_acct_site_id      hz_cust_site_uses_all.cust_acct_site_id%type,
   site_use_id            hz_cust_site_uses_all.site_use_id%type);

  pr_site_use_rec pr_site_use_rec_type;

  TYPE pr_site_loc_rec_type is RECORD(
        COUNTRY    HZ_LOCATIONS.COUNTRY%TYPE,
        STATE      HZ_LOCATIONS.STATE%TYPE,
        COUNTY     HZ_LOCATIONS.COUNTY%TYPE,
        PROVINCE   HZ_LOCATIONS.PROVINCE%TYPE,
        CITY       HZ_LOCATIONS.CITY%TYPE,
        CUST_ACCT_SITE_ID HZ_CUST_SITE_USES_ALL.CUST_ACCT_SITE_ID%TYPE);

  pr_site_loc_rec  pr_site_loc_rec_type;

  TYPE pr_org_loc_rec_type is RECORD(
        COUNTRY        HR_LOCATIONS_ALL.COUNTRY%TYPE,
        TOWN_OR_CITY   HR_LOCATIONS_ALL.TOWN_OR_CITY%TYPE,
        REGION_1       HR_LOCATIONS_ALL.REGION_1%TYPE,
        REGION_2       HR_LOCATIONS_ALL.REGION_2%TYPE,
        REGION_3       HR_LOCATIONS_ALL.REGION_3%TYPE,
        ADDRESS_LINE_1 HR_LOCATIONS_ALL.ADDRESS_LINE_1%TYPE,
        ADDRESS_LINE_2 HR_LOCATIONS_ALL.ADDRESS_LINE_2%TYPE,
        ADDRESS_LINE_3 HR_LOCATIONS_ALL.ADDRESS_LINE_3%TYPE,
        POSTAL_CODE   HR_LOCATIONS_ALL.POSTAL_CODE%TYPE,
        TELEPHONE_NUMBER_1   HR_LOCATIONS_ALL.TELEPHONE_NUMBER_1%TYPE,
        TELEPHONE_NUMBER_2   HR_LOCATIONS_ALL.TELEPHONE_NUMBER_2%TYPE,
        TELEPHONE_NUMBER_3   HR_LOCATIONS_ALL.TELEPHONE_NUMBER_3%TYPE,
        STYLE   HR_LOCATIONS_ALL.STYLE%TYPE,
        LOCATION_ID HR_LOCATIONS_ALL.LOCATION_ID%TYPE -- bug fix 4417523
 --       ORGANIZATION_ID  NUMBER
        );

  pr_org_loc_rec  pr_org_loc_rec_type;

TYPE pr_stats_rec_type is RECORD(
  country		NUMBER,
  state			NUMBER,
  county		NUMBER,
  city			NUMBER,
  province		NUMBER,
  fob			NUMBER,
  tax_classification 	NUMBER,
  type                  NUMBER,
  user_item_type	NUMBER,
  vat_reg_num		NUMBER,
  warehouse             NUMBER);

TYPE pr_stats_rec_tbl_type is TABLE of pr_stats_rec_type
  index by binary_integer;

pr_stats_rec_tbl pr_stats_rec_tbl_type;
pr_stats_default_rec  pr_stats_rec_type;

g_current_runtime_level      NUMBER;

g_level_statement       CONSTANT NUMBER   := FND_LOG.LEVEL_STATEMENT;
g_level_procedure       CONSTANT NUMBER   := FND_LOG.LEVEL_PROCEDURE;
g_level_unexpected      CONSTANT NUMBER   := FND_LOG.LEVEL_UNEXPECTED;

-- Parameters required for evaluating Constraint, Condition Set and Exception Set.
g_cec_ship_to_party_site_id     NUMBER;
g_cec_bill_to_party_site_id     NUMBER;
g_cec_ship_to_party_id          NUMBER;
g_cec_bill_to_party_id          NUMBER;
g_cec_poo_location_id           NUMBER;
g_cec_poa_location_id           NUMBER;
g_cec_trx_id                    NUMBER;
g_cec_trx_line_id               NUMBER;
g_cec_ledger_id                 NUMBER;
g_cec_internal_organization_id  NUMBER;
g_cec_so_organization_id        NUMBER;
g_cec_product_org_id            NUMBER;
g_cec_product_id                NUMBER;
g_cec_trx_type_id               NUMBER;
g_cec_trx_line_date             DATE;
g_cec_fob_point                 VARCHAR2(30);
g_cec_ship_to_site_use_id       NUMBER;
g_cec_bill_to_site_use_id       NUMBER;

-- bug fix 4417523
-- global cache variables for HR Address location
pg_column         VARCHAR2(150);
pg_classification VARCHAR2(80);

/*===========================================================================+
 | PROCEDURE                                                                 |
 |   init_stats_rec_tbl                                                      |
 |                                                                           |
 | DESCRIPTION                                                               |
 |   The purpose of this procedure is to initialize the pr_stats_rec_tbl     |
 |   nested table                                                            |
 | SCOPE - Private                                                           |
 |                                                                           |
 +===========================================================================*/

procedure init_stats_rec_tbl is
begin

      pr_stats_default_rec.country                  := 0;
      pr_stats_default_rec.state                    := 0;
      pr_stats_default_rec.county                   := 0;
      pr_stats_default_rec.city                     := 0;
      pr_stats_default_rec.province                 := 0;
      pr_stats_default_rec.fob                      := 0;
      pr_stats_default_rec.tax_classification       := 0;
      pr_stats_default_rec.type                     := 0;
      pr_stats_default_rec.user_item_type           := 0;
      pr_stats_default_rec.vat_reg_num              := 0;
      pr_stats_default_rec.warehouse                := 0;


      pr_stats_rec_tbl(IDX_SHIP_FROM)       := pr_stats_default_rec;
      pr_stats_rec_tbl(IDX_SHIP_TO)         := pr_stats_default_rec;
      pr_stats_rec_tbl(IDX_POO)             := pr_stats_default_rec;
      pr_stats_rec_tbl(IDX_POA)             := pr_stats_default_rec;
      pr_stats_rec_tbl(IDX_BILL_TO)         := pr_stats_default_rec;
      pr_stats_rec_tbl(IDX_TRX)             := pr_stats_default_rec;
      pr_stats_rec_tbl(IDX_ITEM)            := pr_stats_default_rec;
      pr_stats_rec_tbl(IDX_TAX_CODE)        := pr_stats_default_rec;


end;


/*===========================================================================+
 | PROCEDURE                                                                 |
 |   evaluate_cec_lines                                                      |
 |                                                                           |
 | DESCRIPTION                                                               |
 |   Evaluate Compiled Condition of Lines. If condition is evaluates to TRUE,|
 |   return TRUE, else FALSE.                                                |
 |                                                                           |
 | SCOPE - Private                                                           |
 |                                                                           |
 +===========================================================================*/
function evaluate_cec_lines (p_compiled_condition IN VARCHAR2) return BOOLEAN is

  l_cursor    INTEGER;
  l_ignore    INTEGER;

  l_temp      NUMBER;
  l_result    BOOLEAN;
  l_exception_result    BOOLEAN;

  l_and_condition VARCHAR2(2500);

begin

  g_current_runtime_level := FND_LOG.G_CURRENT_RUNTIME_LEVEL;


  IF (g_level_statement >= g_current_runtime_level ) THEN
     FND_LOG.STRING(g_level_statement,
                   'ZX.PLSQL.ZX_TDS_PROCESS_CEC_PVT.evaluate_cec_lines.BEGIN',
                   'ZX_TDS_PROCESS_CEC_PVT: evaluate_cec_lines(+)');

  END IF;

  l_temp              :=0;
  l_result            := FALSE;
  l_exception_result  := FALSE;

  if (p_compiled_condition is null) then
    l_result := TRUE;
  else
    BEGIN

    /* comment out for bug 4417523 begin: no need to execute the condition twice

      -- Replace 'OR' with 'AND' sot that all the functions in
      -- the conditions get called.
      l_and_condition := replace(upper(p_compiled_condition), ' OR ', ' AND ');

      -- First Execute with all "AND" only. Each function in the condition
      -- sets the global flag accordingly.
      IF (g_level_statement >= g_current_runtime_level ) THEN
         FND_LOG.STRING(g_level_statement,
                   'ZX.PLSQL.ZX_TDS_PROCESS_CEC_PVT.evaluate_cec_lines',
                   'Compiled Condition: ' || l_and_condition);
      END IF;

      EXECUTE IMMEDIATE  'BEGIN '|| l_and_condition ||'
          THEN :temp := 1; else :temp := 0; END IF; END;'  USING OUT l_temp ;

      IF (g_level_statement >= g_current_runtime_level ) THEN
         IF l_temp = 1 THEN
            FND_LOG.STRING(g_level_statement,
                    'ZX.PLSQL.ZX_TDS_PROCESS_CEC_PVT.evaluate_cec_lines', 'Condition is satisfied ');
         ELSE
            FND_LOG.STRING(g_level_statement,
                    'ZX.PLSQL.ZX_TDS_PROCESS_CEC_PVT.evaluate_cec_lines', 'Condition is NOT satisfied ');
         END IF;
      END IF;
     end comment out for bug 4417523 */
      --
      -- Now execute with original conditions to evaluate.
      --
      IF (g_level_statement >= g_current_runtime_level ) THEN
         FND_LOG.STRING(g_level_statement,
                   'ZX.PLSQL.ZX_TDS_PROCESS_CEC_PVT.evaluate_cec_lines',
                   'Compiled Condition: ' || p_compiled_condition);
      END IF;

      EXECUTE IMMEDIATE  'BEGIN '|| p_compiled_condition||
                       'THEN :temp := 1; ELSE :temp := 0;END IF; END;'  USING IN OUT l_temp ;

      IF (g_level_statement >= g_current_runtime_level ) THEN
         IF l_temp = 1 THEN
            FND_LOG.STRING(g_level_statement,
                    'ZX.PLSQL.ZX_TDS_PROCESS_CEC_PVT.evaluate_cec_lines', 'Condition is satisfied ');
         ELSE
            FND_LOG.STRING(g_level_statement,
                    'ZX.PLSQL.ZX_TDS_PROCESS_CEC_PVT.evaluate_cec_lines', 'Condition is NOT satisfied ');
         END IF;
      END IF;

    EXCEPTION
      WHEN OTHERS THEN
        IF (g_level_unexpected >= g_current_runtime_level ) THEN
            FND_LOG.STRING(g_level_unexpected,
                    'ZX.PLSQL.ZX_TDS_PROCESS_CEC_PVT.evaluate_cec_lines', 'Error Message: ' || sqlerrm);
        END IF;
        app_exception.raise_exception;
    END;
    if l_temp = 1 then
      l_result := TRUE;
    else
      l_result := FALSE;
    end if;
  end if;
  IF (g_level_statement >= g_current_runtime_level ) THEN

     FND_LOG.STRING(g_level_statement,
                   'ZX.PLSQL.ZX_TDS_PROCESS_CEC_PVT.evaluate_cec_lines.END',
                   'ZX_TDS_PROCESS_CEC_PVT: evaluate_cec_lines(-)');
  END IF;

  return l_result;
end evaluate_cec_lines;

/*===========================================================================+
 | PROCEDURE                                                                 |
 |   evaluate_cec_action                                                     |
 |                                                                           |
 | DESCRIPTION                                                               |
 |   Execute Compiled condition of Action.                                   |
 |                                                                           |
 | SCOPE - Private                                                           |
 |                                                                           |
 +===========================================================================*/
procedure evaluate_cec_action(p_compiled_action IN VARCHAR2,
                              p_type            IN VARCHAR2) is

  l_cursor    INTEGER;
  l_ignore    INTEGER;
  l_msg       VARCHAR2(60);

begin

  g_current_runtime_level := FND_LOG.G_CURRENT_RUNTIME_LEVEL;
  IF (g_level_statement >= g_current_runtime_level ) THEN
     FND_LOG.STRING(g_level_statement,
                   'ZX.PLSQL.ZX_TDS_PROCESS_CEC_PVT.evaluate_cec_action.BEGIN',
                   'ZX_TDS_PROCESS_CEC_PVT.evaluate_cec_action (+)');
  END IF;

  pr_do_not_use_this_tax_flag     := FALSE;
  pr_do_not_use_this_group_flag   := FALSE;

  if (p_compiled_action is not null) then
    BEGIN

      IF (g_level_statement >= g_current_runtime_level ) THEN
         FND_LOG.STRING(g_level_statement,
                       'ZX.PLSQL.ZX_TDS_PROCESS_CEC_PVT.evaluate_cec_action',
                       'Compiled Action: ' || p_compiled_action);
      END IF;

      IF (instr(p_compiled_action, 'ZX_TDS_PROCESS_CEC_PVT.USE_THIS_TAX_CODE(') >0) THEN
         IF (g_level_statement >= g_current_runtime_level ) THEN
            FND_LOG.STRING(g_level_statement,
                          'ZX.PLSQL.ZX_TDS_PROCESS_CEC_PVT.evaluate_cec_action',
                          'Use this Tax');
         END IF;
      ELSIF (instr(p_compiled_action, 'ZX_TDS_PROCESS_CEC_PVT.DO_NOT_USE_THIS_TAX_CODE(') >0) THEN
         IF (g_level_statement >= g_current_runtime_level ) THEN
            FND_LOG.STRING(g_level_statement,
                          'ZX.PLSQL.ZX_TDS_PROCESS_CEC_PVT.evaluate_cec_action',
                          'DO NOT use this Tax');
         END IF;
         pr_do_not_use_this_tax_flag := TRUE;

      ELSIF (instr(p_compiled_action, 'ZX_TDS_PROCESS_CEC_PVT.USE_THIS_TAX_GROUP(') >0) THEN
         IF (g_level_statement >= g_current_runtime_level ) THEN
            FND_LOG.STRING(g_level_statement,
                          'ZX.PLSQL.ZX_TDS_PROCESS_CEC_PVT.evaluate_cec_action',
                          'Use this Tax Condition Group');
         END IF;
      ELSIF (instr(p_compiled_action, 'ZX_TDS_PROCESS_CEC_PVT.DO_NOT_USE_THIS_TAX_GROUP(') >0) THEN
         IF (g_level_statement >= g_current_runtime_level ) THEN
            FND_LOG.STRING(g_level_statement,
                          'ZX.PLSQL.ZX_TDS_PROCESS_CEC_PVT.evaluate_cec_action',
                          'DO NOT use this Tax Condition Group');
         END IF;
         pr_do_not_use_this_group_flag := TRUE;

      ELSE
        EXECUTE IMMEDIATE 'BEGIN '||p_compiled_action||' END;' ;
      END IF;

      if(pr_message_token is not null) then
        app_exception.raise_exception;
      end if;
    EXCEPTION
      WHEN OTHERS THEN
         IF (g_level_statement >= g_current_runtime_level ) THEN
            FND_LOG.STRING(g_level_statement,
                          'ZX.PLSQL.ZX_TDS_PROCESS_CEC_PVT.evaluate_cec_action',
                          'Error Message: ' || sqlerrm);
         END IF;
         app_exception.raise_exception;
    END;
  end if;
  IF (g_level_statement >= g_current_runtime_level ) THEN

     FND_LOG.STRING(g_level_statement,
                   'ZX.PLSQL.ZX_TDS_PROCESS_CEC_PVT.evaluate_cec_action.END',
                   'ZX_TDS_PROCESS_CEC_PVT.evaluate_cec_action (-)');
  END IF;
end evaluate_cec_action;

/*===========================================================================+
 | FUNCTION                                                                  |
 |   create_compiled_lines                                                   |
 |                                                                           |
 | DESCRIPTION                                                               |
 |   Compile the Condition for Lines.                                        |
 |                                                                           |
 | SCOPE - Private                                                           |
 |                                                                           |
 +===========================================================================*/

function create_compiled_lines(p_cec_id IN NUMBER) return VARCHAR2 is

  l_compiled_line VARCHAR2(2500);
  l_end           VARCHAR2(1);

  CURSOR cec_csr (c_cec_id NUMBER) is
          select upper(tax_condition_clause)   tax_condition_clause,
		 upper(tax_condition_entity)   tax_condition_entity,
		 upper(tax_condition_field)    tax_condition_field,
		 upper(tax_condition_operator) tax_condition_operator,
		 upper(tax_condition_value)    tax_condition_value
            from ar_tax_condition_lines_all
           where tax_condition_id = c_cec_id
           order by display_order;

begin

  g_current_runtime_level := FND_LOG.G_CURRENT_RUNTIME_LEVEL;
  IF (g_level_statement >= g_current_runtime_level ) THEN
     FND_LOG.STRING(g_level_statement,
                   'ZX.PLSQL.ZX_TDS_PROCESS_CEC_PVT.create_compiled_lines.BEGIN',
                   'ZX_TDS_PROCESS_CEC_PVT.create_compiled_lines (+)');

  END IF;

  for cec_rec in cec_csr(p_cec_id) LOOP
    --
    -- IF, OR, AND
    --
    l_compiled_line := l_compiled_line || cec_rec.tax_condition_clause ||' ';
    --
    -- SHIP_FROM, SHIP_TO, POO, POA, ITEM, TRX, BILL_TO ...
    --
    if (cec_rec.tax_condition_entity is not null) then
      l_compiled_line := l_compiled_line ||
                          'ZX_TDS_PROCESS_CEC_PVT.'|| cec_rec.tax_condition_entity||'(';
      l_end := ')';
    end if;
    --
    -- COUNTRY, STATE, PROVINCE, CITY, TAX_CLASSIFICATION ...
    --
    if (cec_rec.tax_condition_field is not null) then
      l_compiled_line := l_compiled_line || ''''||cec_rec.tax_condition_field||''',';
    else
      l_compiled_line := l_compiled_line ||'NULL,';
    end if;
    --
    -- =, <, >, <=, >= ...
    --
    if (cec_rec.tax_condition_operator is not null) then
      l_compiled_line := l_compiled_line || ''''||cec_rec.tax_condition_operator||''',';
    else
      l_compiled_line := l_compiled_line ||'NULL,';
    end if;
    --
    -- ONTARIO, OTTAWA, JAPAN, ENGLAND, CA ...
    --
    if (cec_rec.tax_condition_value is not null) then
      l_compiled_line := l_compiled_line || ''''||cec_rec.tax_condition_value||'''';
    else
      l_compiled_line := l_compiled_line ||'NULL';
    end if;
    --
    l_compiled_line := l_compiled_line || l_end || ' ';
    --
    -- By Now l_compiled_line should look like
    -- IF SHIP_FROM('PROVINCE','=','ONTARIO')
    --
  end LOOP;

  IF (g_level_statement >= g_current_runtime_level ) THEN

     FND_LOG.STRING(g_level_statement,
                   'ZX.PLSQL.ZX_TDS_PROCESS_CEC_PVT.create_compiled_lines.END',
                   'ZX_TDS_PROCESS_CEC_PVT.create_compiled_lines (-)');
  END IF;
  return l_compiled_line;
end create_compiled_lines;

/*===========================================================================+
 | FUNCTION                                                                  |
 |   create_compiled_action                                                  |
 |                                                                           |
 | DESCRIPTION                                                               |
 |   Compile the condition for Actions.                                      |
 |                                                                           |
 | SCOPE - Private                                                           |
 |                                                                           |
 +===========================================================================*/

function create_compiled_action(p_cec_id       IN NUMBER,
                                p_action_type  IN VARCHAR2) return VARCHAR2 is

  l_compiled_action VARCHAR2(4000);
  l_end             VARCHAR2(2);

  CURSOR action_csr (c_cec_id NUMBER,
                     c_action_type  VARCHAR2) is
             select upper(tax_condition_action_code) tax_condition_action_code,
		    decode(upper(tax_condition_action_code),
                       'USER_MESSAGE',tax_condition_action_value,
                       'DEFAULT_TAX_CODE', tax_condition_action_value,
                       upper(tax_condition_action_value)) tax_condition_action_value
               from ar_tax_condition_actions_all
              where tax_condition_id = c_cec_id
                and tax_condition_action_type = c_action_type
              order by display_order;
   l_counter NUMBER;

begin

  g_current_runtime_level := FND_LOG.G_CURRENT_RUNTIME_LEVEL;
  IF (g_level_statement >= g_current_runtime_level ) THEN
     FND_LOG.STRING(g_level_statement,
                   'ZX.PLSQL.ZX_TDS_PROCESS_CEC_PVT.create_compiled_action.BEGIN',
                   'ZX_TDS_PROCESS_CEC_PVT.create_compiled_action (+)');

  END IF;
  l_counter := 1;
  pr_action_rec_tbl.delete;

  for action_rec in action_csr(p_cec_id, p_action_type)
  LOOP
    -- ERROR_MESSAGE, SYSTEM_ERROR, USE_TAX_CODE ...
    if (action_rec.tax_condition_action_code is not null) then
       l_compiled_action := l_compiled_action || 'ZX_TDS_PROCESS_CEC_PVT.'||
                           action_rec.tax_condition_action_code ||'(';
       l_end := ');';
    end if;

    pr_action_rec_tbl(l_counter).tax_condition_id   := p_cec_id;
    pr_action_rec_tbl(l_counter).action_type        := p_action_type;
    pr_action_rec_tbl(l_counter).action_code        := action_rec.tax_condition_action_code;
    pr_action_rec_tbl(l_counter).action_value       := action_rec.tax_condition_action_value;
    l_counter :=  l_counter + 1;

    if (action_rec.tax_condition_action_value is not null) then
      l_compiled_action := l_compiled_action ||
                           ''''||action_rec.tax_condition_action_value||'''';
    else
      l_compiled_action := l_compiled_action ||'NULL';
    end if;

    l_compiled_action := l_compiled_action || l_end;

  end LOOP;

  IF (g_level_statement >= g_current_runtime_level ) THEN

     FND_LOG.STRING(g_level_statement,
                   'ZX.PLSQL.ZX_TDS_PROCESS_CEC_PVT.create_compiled_action.END',
                   'ZX_TDS_PROCESS_CEC_PVT.create_compiled_action (-)');
  END IF;
  return l_compiled_action;
end create_compiled_action;

/*----------------------------------------------------------------------------*
 | FUNCTION                                                                   |
 |    get_hr_location                         			      	      |
 |                                                                            |
 | DESCRIPTION                                                                |
 |    This function gets the location information from HR_LOCATION_V          |
 |    Based on the input parameter p_classification, and the structure        |
 |    of 'Location Address' Flexfield,the function maps appropriate           |
 |    application_column_name to either county, state, county, province       |
 |    or city.                                                                |
 |                                                                            |
 | SCOPE - Private                                                            |
 |                                                                            |
 *----------------------------------------------------------------------------*/

FUNCTION get_hr_location (
        p_organization_id IN NUMBER,
        p_location_id    IN NUMBER,
        p_classification IN VARCHAR2)
        return VARCHAR2 is

   l_classification varchar2(30);
   l_column       VARCHAR2(30);
   l_column_value VARCHAR2(150);
   l_location_id  NUMBER;

   -- performance bug fix 4417523
       cursor c_loc_rec (c_location_id NUMBER)is
       select
              loc.COUNTRY,
              loc.TOWN_OR_CITY,
              loc.REGION_1,
              loc.REGION_2,
              loc.REGION_3,
              loc.ADDRESS_LINE_1,
              loc.ADDRESS_LINE_2,
              loc.ADDRESS_LINE_3,
              loc.POSTAL_CODE,
              loc.TELEPHONE_NUMBER_1,
              loc.TELEPHONE_NUMBER_2,
              loc.TELEPHONE_NUMBER_3,
              loc.STYLE,
              loc.LOCATION_ID
       from hr_locations_all loc,
            fnd_descr_flex_contexts fnd
       where loc.location_id = c_location_id
         AND loc.style = fnd.descriptive_flex_context_code
         AND fnd.application_id = 800   -- Application_short_name 'PER'
         AND fnd.descriptive_flexfield_name = 'Address Location'
         AND fnd.enabled_flag IN ('Y', 'y')
         AND NVL (loc.business_group_id, NVL (hr_general.get_business_group_id, -99)) =
          NVL (hr_general.get_business_group_id, NVL (loc.business_group_id, -99));

    cursor c_get_location_id(c_organization_id NUMBER) is
    select location_id
    from   hr_organization_units
    where  organization_id = c_organization_id;

BEGIN
  g_current_runtime_level := FND_LOG.G_CURRENT_RUNTIME_LEVEL;

  IF (g_level_statement >= g_current_runtime_level ) THEN
     FND_LOG.STRING(g_level_statement,
                   'ZX.PLSQL.ZX_TDS_PROCESS_CEC_PVT.get_hr_location.BEGIN',
                   'ZX_TDS_PROCESS_CEC_PVT.get_hr_location (+)');

  END IF;

  IF p_organization_id is not NULL then
     open c_get_location_id(p_organization_id);
     fetch c_get_location_id into l_location_id;
     close c_get_location_id;
  ELSE
     l_location_id := p_location_id;  -- when organization_id is NULL, we expect location_id to be passed.
                                      -- For POO, POA, the location_id is directly passed, so no need to use
                                      -- the cursor c_location_id.
  END IF;

  -- begin bug fix 4417523
  IF   NVL(pr_org_loc_rec.location_id, -1) <> NVL(l_location_id,-2) THEN

    open c_loc_rec(l_location_id);
    fetch c_loc_rec into pr_org_loc_rec;

    IF c_loc_rec%FOUND THEN
      -- Based on the address style, the columns in hr_locations_v are used to store
      -- different components of a locations's address. Hence, you have to call the
      -- descriptive flexfield API's to find out how the DFF 'Address Location' has
      -- been setup and pick up the correct column,which corresponds to the input
      -- parameter, p_classification. The function get_clocation_column
      -- performs this function.
      -- l_style :=  pr_org_loc_rec.style;

      l_column := upper(get_location_column(
                                  p_style => pr_org_loc_rec.style,
                                  p_classification => p_classification));

    END IF;

    pg_column := l_column;
    pg_classification := p_classification;

    CLOSE c_loc_rec;

  ELSE -- organization / location is found in cache

    IF pg_classification IS NULL OR pg_classification <> p_classification THEN

      IF (g_level_statement >= g_current_runtime_level ) THEN
        FND_LOG.STRING(g_level_statement,
                       'ZX.PLSQL.ZX_TDS_PROCESS_CEC_PVT.get_hr_location',
                       'Same organization but different classification');

      END IF;

      l_column := UPPER(get_location_column(
                                p_style => pr_org_loc_rec.style,
                                p_classification => p_classification));

      pg_column := l_column;
      pg_classification := p_classification;
    ELSE --Same organization and same classificationas cached

      IF (g_level_statement >= g_current_runtime_level ) THEN
        FND_LOG.STRING(g_level_statement,
                       'ZX.PLSQL.ZX_TDS_PROCESS_CEC_PVT.get_hr_location',
                       'Same organization and same classificationas cached: ');

      END IF;

      l_column := pg_column;
    END IF; -- IF pg_classification IS NULL OR pg_classification <> p_classification THEN

  END IF;  --IF NVL(pr_org_loc_rec.location_id, -1) <> NVL(l_location_id,-2) THEN

  IF (g_level_statement >= g_current_runtime_level ) THEN
     FND_LOG.STRING(g_level_statement,
                   'ZX.PLSQL.ZX_TDS_PROCESS_CEC_PVT.get_hr_location',
                   'l_column: '|| l_column);
  END IF;

--end bug fix 4417523

   if l_column = 'TOWN_OR_CITY' then
       l_column_value := pr_org_loc_rec.TOWN_OR_CITY;
   elsif l_column  = 'COUNTRY' then
       l_column_value := pr_org_loc_rec.COUNTRY;
   elsif l_column  = 'REGION_1' then
       l_column_value := pr_org_loc_rec.REGION_1;
   elsif l_column  = 'REGION_2' then
       l_column_value := pr_org_loc_rec.REGION_2;
   elsif l_column = 'REGION_3' then
       l_column_value := pr_org_loc_rec.REGION_3;
   elsif l_column = 'ADDRESS_LINE_1' then
       l_column_value := pr_org_loc_rec.ADDRESS_LINE_1;
   elsif l_column = 'ADDRESS_LINE_2' then
       l_column_value := pr_org_loc_rec.ADDRESS_LINE_2;
   elsif l_column = 'ADDRESS_LINE_3' then
       l_column_value := pr_org_loc_rec.ADDRESS_LINE_3;
   elsif l_column = 'POSTAL_CODE' then
       l_column_value := pr_org_loc_rec.POSTAL_CODE;
   elsif l_column = 'TELEPHONE_NUMBER_1' then
       l_column_value := pr_org_loc_rec.TELEPHONE_NUMBER_1;
   elsif l_column = 'TELEPHONE_NUMBER_2' then
       l_column_value := pr_org_loc_rec.TELEPHONE_NUMBER_2;
   elsif l_column = 'TELEPHONE_NUMBER_3' then
       l_column_value := pr_org_loc_rec.TELEPHONE_NUMBER_3;
   else
       IF (g_level_unexpected >= g_current_runtime_level ) THEN
          FND_LOG.STRING(g_level_unexpected,
                        'ZX.PLSQL.ZX_TDS_PROCESS_CEC_PVT.get_hr_location',
                        'Invalid Column');
       END IF;
   end if;

  IF (g_level_statement >= g_current_runtime_level ) THEN

     FND_LOG.STRING(g_level_statement,
                   'ZX.PLSQL.ZX_TDS_PROCESS_CEC_PVT.get_hr_location.END',
                   'ZX_TDS_PROCESS_CEC_PVT.get_hr_location (-)');
  END IF;

  return upper(l_column_value);

END get_hr_location;

/*----------------------------------------------------------------------------*
 | FUNCTION                                                                   |
 |    get_site_location                       			      	      |
 |                                                                            |
 | DESCRIPTION                                                                |
 |    This function gets the location information from RA_ADDRESSES           |
 |    and RA_SITE_USES based on input parameters p_site_use_id and            |
 |    p_classification                                                        |
 |                                                                            |
 | SCOPE - Private                                                            |
 |                                                                            |
 *----------------------------------------------------------------------------*/

FUNCTION get_site_location
            (p_site_use_id IN NUMBER,
             p_classification  IN VARCHAR2)

    return VARCHAR2 is

  l_location  VARCHAR2(150);

  cursor c_site_use_rec(c_site_use_id NUMBER) is
       select site.TAX_CLASSIFICATION,
              site.cust_acct_site_id,
              site.site_use_id
       from   HZ_CUST_SITE_USES_ALL site
       where  site.site_use_id = c_site_use_id;

  cursor c_site_loc_rec(c_address_id number) is
       select loc.COUNTRY,
              loc.STATE,
              loc.COUNTY,
              loc.PROVINCE,
              loc.CITY,
              acct_site.CUST_ACCT_SITE_ID
       from   HZ_PARTY_SITES PARTY_SITE,
           -- HZ_LOC_ASSIGNMENTS LOC_ASSIGN,
              HZ_LOCATIONS LOC,
              HZ_CUST_ACCT_SITES_ALL ACCT_SITE
       WHERE ACCT_SITE.PARTY_SITE_ID = PARTY_SITE.PARTY_SITE_ID AND
             LOC.LOCATION_ID = PARTY_SITE.LOCATION_ID AND
          -- LOC.LOCATION_ID = LOC_ASSIGN.LOCATION_ID AND
          -- NVL(ACCT_SITE.ORG_ID, -99) = NVL(LOC_ASSIGN.ORG_ID, -99) AND
             ACCT_SITE.CUST_ACCT_SITE_ID = c_address_id;

BEGIN

  g_current_runtime_level := FND_LOG.G_CURRENT_RUNTIME_LEVEL;

  IF (g_level_statement >= g_current_runtime_level ) THEN
     FND_LOG.STRING(g_level_statement,
                   'ZX.PLSQL.ZX_TDS_PROCESS_CEC_PVT.get_site_location.BEGIN',
                   'ZX_TDS_PROCESS_CEC_PVT.get_site_location (+)'||
                   'p_site_use_id= ' || p_site_use_id ||
                   'p_classification= ' || p_classification ||
                   'pr_site_use_rec.site_used_id= '||pr_site_use_rec.site_use_id) ;
  END IF;
  pr_site_use_rec := NULL; --Bug 5865500

  IF nvl(pr_site_use_rec.site_use_id,-1) <> nvl(p_site_use_id,-2) then

      pr_site_use_rec.TAX_CLASSIFICATION := NULL;
      pr_site_use_rec.cust_acct_site_id  := NULL;

      open c_site_use_rec(p_site_use_id);
      fetch c_site_use_rec into pr_site_use_rec;
      close c_site_use_rec;

  END IF;

  IF (g_level_statement >= g_current_runtime_level ) THEN

     FND_LOG.STRING(g_level_statement,
                   'ZX.PLSQL.ZX_TDS_PROCESS_CEC_PVT.get_site_location',
                   'pr_site_use_rec.cust_acct_site_id: '||pr_site_use_rec.cust_acct_site_id);
  END IF;

  IF nvl(pr_site_loc_rec.cust_acct_site_id, -1) <> nvl(pr_site_use_rec.cust_acct_site_id,-2) then

      pr_site_loc_rec.COUNTRY    := NULL;
      pr_site_loc_rec.STATE      := NULL;
      pr_site_loc_rec.COUNTY     := NULL;
      pr_site_loc_rec.PROVINCE   := NULL;
      pr_site_loc_rec.CITY       := NULL;
      pr_site_loc_rec.cust_acct_site_id := NULL;

      open c_site_loc_rec(pr_site_use_rec.cust_acct_site_id);
      fetch c_site_loc_rec into pr_site_loc_rec;
      close c_site_loc_rec;

      IF (g_level_statement >= g_current_runtime_level ) THEN
         FND_LOG.STRING(g_level_statement,
                       'ZX.PLSQL.ZX_TDS_PROCESS_CEC_PVT.get_site_location',
         	       'pr_site_loc_rec.COUNTRY'||pr_site_loc_rec.COUNTRY||' STATE '||pr_site_loc_rec.STATE||
                       ' PROVINCE '||pr_site_loc_rec.PROVINCE||
         	       ' CITY '||pr_site_loc_rec.CITY||
         	       ' COUNTY '||pr_site_loc_rec.COUNTY||
         	       ' TAX_CLASSIFICATION '||
                                pr_site_use_rec.TAX_CLASSIFICATION||
         	       ' cust_acct_site_id'||
                                pr_site_loc_rec.cust_acct_site_id);
      END IF;
  END IF;

  IF  upper(p_classification) = 'COUNTRY' then
    l_location := pr_site_loc_rec.COUNTRY;
  ELSIF upper(p_classification) = 'STATE' then
    l_location := pr_site_loc_rec.STATE;
   ELSIF upper(p_classification) = 'COUNTY' then
    l_location := pr_site_loc_rec.COUNTY;
  ELSIF upper(p_classification) = 'PROVINCE' then
    l_location := pr_site_loc_rec.PROVINCE;
  ELSIF upper(p_classification) = 'CITY' then
    l_location := pr_site_loc_rec.CITY;
  ELSIF upper(p_classification) = 'TAX_CLASSIFICATION' then
    l_location := pr_site_use_rec.TAX_CLASSIFICATION;
  ELSE
    IF (g_level_statement >= g_current_runtime_level ) THEN
       FND_LOG.STRING(g_level_statement,
                     'ZX.PLSQL.ZX_TDS_PROCESS_CEC_PVT.get_site_location',
    	             'Invalid value for p_classification');
    END IF;
  END IF;

  IF (g_level_statement >= g_current_runtime_level ) THEN

     FND_LOG.STRING(g_level_statement,
                   'ZX.PLSQL.ZX_TDS_PROCESS_CEC_PVT.get_site_location.END',
  	           'ZX_TDS_PROCESS_CEC_PVT.get_site_location (-)'||
  	           ' location: '||l_location);
  END IF;
  RETURN upper(l_location);

EXCEPTION
  when others then
        IF (g_level_statement >= g_current_runtime_level ) THEN
           FND_LOG.STRING(g_level_statement,
                         'ZX.PLSQL.ZX_TDS_PROCESS_CEC_PVT.get_site_location',
   	                 'Exception in Get Site Location: ' || SQLCODE ||' ; '||SQLERRM);
        END IF;
   system_message('Exception');
END get_site_location;


/*----------------------------------------------------------------------------*
 | FUNCTION                                                                   |
 |    compare_condition                                                       |
 |                                                                            |
 | DESCRIPTION                                                                |
 |    This function compares the condition based on calling function and      |
 |    and the condition value entered by user.                                |
 |                                                                            |
 | SCOPE - Private                                                            |
 |                                                                            |
 *----------------------------------------------------------------------------*/

FUNCTION compare_condition
            ( p_id                   IN NUMBER,
              P_calling_function     IN VARCHAR2,
              p_classification       IN VARCHAR2,
              p_operator             IN VARCHAR2,
              p_value                IN VARCHAR2)
              return BOOLEAN is

l_temp       varchar2(150);
l_value      varchar2(150);
l_index      NUMBER;

l_return_val NUMBER;

l_warehouse  VARCHAR2(60);
l_party_tax_profile_id NUMBER;
l_reg_number VARCHAR2(50);
l_count NUMBER;
l_pty_id NUMBER;

-- If p_classification is WAREHOUSE, get the Warehouse Name
--   which is the Organization Name,using the Warehouse id to evaluate the
--   condition

cursor warehouse_csr (
    l_set_of_books_id  IN ar_system_parameters.set_of_books_id%TYPE,
    l_org_id IN ar_system_parameters.org_id%TYPE )  is
       select      organization_name
       from        org_organization_definitions org
       where       l_set_of_books_id  = org.set_of_books_id
                   and org.operating_unit = l_org_id
                   and org.organization_id = g_cec_product_org_id;

 cursor get_vat_reg_num_site (c_site_use_id number) is
    SELECT ZP.PARTY_TAX_PROFILE_ID,Upper(SU.TAX_REFERENCE)
      FROM HZ_CUST_SITE_USES_ALL SU,
           HZ_CUST_ACCT_SITES_ALL CAS,
           HZ_PARTY_SITES PS,
           ZX_PARTY_TAX_PROFILE ZP
     WHERE SU.SITE_USE_ID = c_site_use_id AND
           SU.CUST_ACCT_SITE_ID = CAS.CUST_ACCT_SITE_ID AND
           CAS.PARTY_SITE_ID = PS.PARTY_SITE_ID AND
           ZP.PARTY_ID = PS.PARTY_SITE_ID AND
	   ZP.PARTY_TYPE_CODE = 'THIRD_PARTY_SITE';

 cursor get_vat_reg_num_cust (c_cust_id number) is
     SELECT ZP.PARTY_TAX_PROFILE_ID,Upper(PARTY.TAX_REFERENCE)
       FROM HZ_CUST_ACCOUNTS CA,
            HZ_PARTIES PARTY,
            ZX_PARTY_TAX_PROFILE ZP
      WHERE CA.CUST_ACCOUNT_ID = c_cust_id AND
            CA.PARTY_ID = PARTY.PARTY_ID AND
            PARTY.PARTY_ID = ZP.PARTY_ID AND
	    ZP.PARTY_TYPE_CODE = 'THIRD_PARTY';

BEGIN

  g_current_runtime_level := FND_LOG.G_CURRENT_RUNTIME_LEVEL;

  IF (g_level_statement >= g_current_runtime_level ) THEN
     FND_LOG.STRING(g_level_statement,
                   'ZX.PLSQL.ZX_TDS_PROCESS_CEC_PVT.compare_condition.BEGIN',
    	           'ZX_TDS_PROCESS_CEC_PVT.compare_condition (+)'||
    	           ' p_id = '||to_char(p_id)||
                     ' P_calling_function: '|| P_calling_function||
                     ' p_classification: '|| p_classification ||
                     ' p_operator: '||p_operator||
                     ' p_value: '||p_value);
  End If;

  l_return_val := 0;

    if (upper(p_operator) = 'NOT_FOUND') then
      --
      -- Find where it is called
      if (upper(p_calling_function) = 'BILL_TO') then
        l_index := IDX_BILL_TO;
      elsif (upper(p_calling_function) = 'SHIP_TO') then
        l_index := IDX_SHIP_TO;
      elsif (upper(p_calling_function) = 'SHIP_FROM') then
        l_index := IDX_SHIP_FROM;
      elsif (upper(p_calling_function) = 'POO') then
        l_index := IDX_POO;
      elsif (upper(p_calling_function) = 'POA') then
        l_index := IDX_POA;
      elsif (upper(p_calling_function) = 'TRX') then
        l_index := IDX_TRX;
      elsif (upper(p_calling_function) = 'ITEM') then
        l_index := IDX_ITEM;
      elsif (upper(p_calling_function) = 'TAX_CODE') then
        l_index := 0;
        l_return_val := 0;
      else
        l_index := 0;
      end if;

      if (l_index > 0) then
        if (upper(p_classification) = 'COUNTRY') then
          l_return_val := pr_stats_rec_tbl(l_index).country;
        elsif (upper(p_classification) = 'STATE') then
          l_return_val := pr_stats_rec_tbl(l_index).state;
        elsif (upper(p_classification) = 'COUNTY') then
          l_return_val := pr_stats_rec_tbl(l_index).county;
        elsif (upper(p_classification) = 'CITY') then
          l_return_val := pr_stats_rec_tbl(l_index).city;
        elsif (upper(p_classification) = 'PROVINCE') then
          l_return_val := pr_stats_rec_tbl(l_index).province;
        elsif (upper(p_classification) = 'FOB') then
          l_return_val := pr_stats_rec_tbl(l_index).fob;
        elsif (upper(p_classification) = 'TAX_CLASSIFICATION') then
          l_return_val := pr_stats_rec_tbl(l_index).tax_classification;
        elsif (upper(p_classification) = 'TYPE') then
          l_return_val := pr_stats_rec_tbl(l_index).type;
        elsif (upper(p_classification) = 'USER_ITEM_TYPE') then
          l_return_val := pr_stats_rec_tbl(l_index).user_item_type;
        elsif (upper(p_classification) = 'VAT_NUM') then
          l_return_val := pr_stats_rec_tbl(l_index).vat_reg_num;
        elsif (upper(p_classification) = 'WAREHOUSE') then
          l_return_val := pr_stats_rec_tbl(l_index).warehouse;
        else
          l_return_val := 0;
        end if;
      end if;
      --
      -- l_return_val STATS_INIT, STATS_TRUE means each function called in
      -- the condition evaluated to TRUE, STATS_FLASE means each function
      -- called in the condition evaluated to FALSE. Since this is for NOT_FOUND
      -- return TRUE when the function evaluated to FALSE,
      -- and FALSE when the function evaluated to TRUE.
      --
      if (l_return_val in (STATS_INIT, STATS_TRUE)) then
        return FALSE;
      else
        return TRUE;
      end if;
    end if;

    IF upper(p_calling_function) in ('BILL_TO','SHIP_TO') then

        IF (upper(p_classification) <> 'VAT_NUM') THEN
            l_temp := get_site_location( p_site_use_id => p_id,
                                      p_classification => p_classification);
            l_value := upper(p_value);

            IF (g_level_statement >= g_current_runtime_level) THEN
               FND_LOG.STRING(g_level_statement,
                             'ZX.PLSQL.ZX_TDS_PROCESS_CEC_PVT.compare_condition',
      	                     ' l_temp = '|| l_temp ||
                              ' l_value = ' || l_value);
            END IF;

            IF l_temp is null and l_value is NULL THEN
       	       return TRUE;
            ELSIF p_operator = '=' THEN
               return l_temp = l_value;
            ELSIF p_operator = '>' THEN
               return l_temp > l_value;
            ELSIF p_operator = '>=' THEN
               return l_temp >= l_value;
            ELSIF p_operator = '<' THEN
               return l_temp < l_value;
            ELSIF p_operator = '<=' THEN
               return l_temp <= l_value;
            ELSIF p_operator = '<>' AND l_temp IS NOT NULL THEN
               return l_temp <> l_value;
            ELSIF p_operator = '<>' AND l_temp IS NULL THEN
               return TRUE;
            ELSE
               return FALSE;
            END IF;
	ELSE
	    IF (g_level_statement >= g_current_runtime_level ) THEN
		FND_LOG.STRING(g_level_statement,'Calling Function: ',p_calling_function);
		FND_LOG.STRING(g_level_statement,'g_cec_bill_to_party_id: ',nvl(g_cec_bill_to_party_id,0));
		FND_LOG.STRING(g_level_statement,'g_cec_ship_to_party_id: ',nvl(g_cec_ship_to_party_id,0));
	    END IF;

	    BEGIN
		OPEN get_vat_reg_num_site(p_id);
		FETCH get_vat_reg_num_site INTO l_party_tax_profile_id,l_reg_number;
		CLOSE get_vat_reg_num_site;
	    EXCEPTION
		WHEN OTHERS THEN
			CLOSE get_vat_reg_num_site;
	    END;
	    IF l_reg_number IS NULL THEN
		IF l_party_tax_profile_id IS NOT NULL THEN

			SELECT COUNT(*) INTO l_count FROM ZX_REGISTRATIONS
			 WHERE PARTY_TAX_PROFILE_ID = l_party_tax_profile_id;

			IF l_count = 1 THEN
				SELECT REGISTRATION_NUMBER INTO l_reg_number
				  FROM ZX_REGISTRATIONS
				 WHERE PARTY_TAX_PROFILE_ID = l_party_tax_profile_id;
			ELSIF l_count > 1 THEN
			   BEGIN
				SELECT REGISTRATION_NUMBER INTO l_reg_number
				  FROM ZX_REGISTRATIONS
				 WHERE PARTY_TAX_PROFILE_ID = l_party_tax_profile_id
				   AND DEFAULT_REGISTRATION_FLAG = 'Y';
		           EXCEPTION
			        WHEN OTHERS THEN
				    NULL;
		           END;
			END IF;
		END IF;

		IF (g_level_statement >= g_current_runtime_level ) THEN
			FND_LOG.STRING(g_level_statement,'Value: ',nvl(l_reg_number,0));
		END IF;

		IF l_reg_number IS NULL THEN
		    IF upper(p_calling_function) = 'BILL_TO' THEN
			l_pty_id := g_cec_bill_to_party_id;
		    ELSE
			l_pty_id := g_cec_SHIP_to_party_id;
		    END IF;
		    IF (g_level_statement >= g_current_runtime_level ) THEN
			FND_LOG.STRING(g_level_statement,'Value: ',nvl(l_pty_id,0));
		    END IF;
		    BEGIN
			OPEN get_vat_reg_num_cust(l_pty_id);
			FETCH get_vat_reg_num_cust INTO l_party_tax_profile_id,l_reg_number;
			CLOSE get_vat_reg_num_cust;
		    EXCEPTION
			WHEN OTHERS THEN
				CLOSE get_vat_reg_num_cust;
		    END;

		    IF (g_level_statement >= g_current_runtime_level ) THEN
			FND_LOG.STRING(g_level_statement,'Value: ',nvl(l_reg_number,0));
		    END IF;

		    IF l_reg_number IS NULL THEN
		    	IF l_party_tax_profile_id IS NOT NULL THEN

				SELECT COUNT(*) INTO l_count FROM ZX_REGISTRATIONS
				 WHERE PARTY_TAX_PROFILE_ID = l_party_tax_profile_id;

				IF l_count = 1 THEN
					SELECT REGISTRATION_NUMBER INTO l_reg_number
					  FROM ZX_REGISTRATIONS
					 WHERE PARTY_TAX_PROFILE_ID = l_party_tax_profile_id;
				ELSIF l_count > 1 THEN
				    BEGIN
					SELECT REGISTRATION_NUMBER INTO l_reg_number
					  FROM ZX_REGISTRATIONS
					 WHERE PARTY_TAX_PROFILE_ID = l_party_tax_profile_id
					   AND DEFAULT_REGISTRATION_FLAG = 'Y';
				    EXCEPTION
				       WHEN OTHERS THEN
				         NULL;
				    END;
				END IF;
			END IF;
		    END IF;
		END IF;
	    END IF;

	    IF (g_level_statement >= g_current_runtime_level ) THEN
		FND_LOG.STRING(g_level_statement,'Value: ',nvl(l_reg_number,0));
	    END IF;

	    IF p_operator = 'IS' THEN
           	return l_reg_number IS NOT NULL;
            ELSIF p_operator = 'IS_NOT' THEN
		return l_reg_number IS NULL;
            ELSE
            	return FALSE;
 	    END IF;

    	    /*IF upper(p_calling_function) = 'BILL_TO' THEN

	       --+ nipatel commenting this call for the time being as ar_validate_vat is obsolete
               -- and we are internally discussing whether it can be replaced with ZX_TRN_VALIDATION_PKG
               --         AR_VALIDATE_VAT.AR_COORDINATE_VALIDATION(p_id,
	       --		g_cec_bill_to_party_id,l_temp);
	       NULL;

	    ELSE

             --+ nipatel commenting this call for the time being as ar_validate_vat is obsolete
             -- and we are internally discussing whether it can be replaced with ZX_TRN_VALIDATION_PKG
	     --            AR_VALIDATE_VAT.AR_COORDINATE_VALIDATION(p_id,
	     -- 		g_cec_ship_to_party_id,l_temp);
	       NULL;

	    END IF;


            IF p_operator = 'IS' THEN
           	return l_temp = 'P';
            ELSIF p_operator = 'IS_NOT' THEN
		return l_temp <> 'P';
            ELSE
            	return FALSE;
 	    END IF;*/
	END IF;

     ELSIF upper(p_calling_function) in ('SHIP_FROM','POO','POA')  THEN

         IF upper(p_calling_function) = 'SHIP_FROM' THEN
             l_temp := get_hr_location ( p_organization_id => p_id,
                                         p_location_id => NULL,
                                         p_classification => p_classification);
         ELSE  -- upper(p_calling_function)in ('POO','POA')
             l_temp := get_hr_location ( p_organization_id => NULL,
                                         p_location_id => p_id,
                                         p_classification => p_classification);
         END IF;

         l_value := upper(p_value);

         IF (g_level_statement >= g_current_runtime_level) THEN
            FND_LOG.STRING(g_level_statement,
                          'ZX.PLSQL.ZX_TDS_PROCESS_CEC_PVT.compare_condition',
      	                  ' l_temp = '|| l_temp ||
                           ' l_value = ' || l_value);
         END IF;

         IF upper(p_classification) = 'WAREHOUSE'  then
            IF (g_level_statement >= g_current_runtime_level) THEN
               FND_LOG.STRING(g_level_statement,
                         'ZX.PLSQL.ZX_TDS_PROCESS_CEC_PVT.compare_condition',
     	                 ' Calling Function is Ship From and p_classification is WAREHOUSE');
     	    END IF;

            open warehouse_csr(g_cec_ledger_id, g_cec_internal_organization_id);
            fetch warehouse_csr into l_warehouse;
            close warehouse_csr;

            l_temp := upper(l_warehouse);
         end if;

         IF l_temp is null and l_value is null  then
             return TRUE;
         ELSIF p_operator = '=' THEN
             return l_temp = l_value;
         ELSIF p_operator = '>' THEN
             return l_temp > l_value;
         ELSIF p_operator = '>=' THEN
             return l_temp >= l_value;
         ELSIF p_operator = '<' THEN
             return l_temp < l_value;
         ELSIF p_operator = '<=' THEN
             return l_temp <= l_value;
         ELSIF p_operator = '<>' AND l_temp IS NOT NULL THEN
             return l_temp <> l_value;
         ELSIF p_operator = '<>' AND l_temp IS NULL THEN
             return TRUE;
         ELSE
             return FALSE;
         END IF;

     ELSIF upper(p_calling_function) = 'TRX' THEN
         if (p_classification = 'FOB') then
           l_temp := upper(g_cec_fob_point);
           l_value := upper(p_value);

         elsif (p_classification = 'TYPE') THEN
           l_value := p_value;
           l_temp := to_char(g_cec_trx_type_id);

         else
           l_temp := NULL;
           l_value := NULL;
         end if;

         IF (g_level_statement >= g_current_runtime_level) THEN
            FND_LOG.STRING(g_level_statement,
                          'ZX.PLSQL.ZX_TDS_PROCESS_CEC_PVT.compare_condition',
      	                  ' l_temp = '|| l_temp ||
                           ' l_value = ' || l_value);
         END IF;

         IF l_temp is null and l_value is null  then
             return TRUE;
         ELSIF p_operator = '=' THEN
             return l_temp = l_value;
         ELSIF p_operator = '>' THEN
             return l_temp > l_value;
         ELSIF p_operator = '>=' THEN
             return l_temp >= l_value;
         ELSIF p_operator = '<' THEN
             return l_temp < l_value;
         ELSIF p_operator = '<=' THEN
             return l_temp <= l_value;
         ELSIF p_operator = '<>' AND l_temp IS NOT NULL THEN
             return l_temp <> l_value;
         ELSIF p_operator = '<>' AND l_temp IS NULL THEN
             return TRUE;
         ELSE
             return FALSE;
         END IF;
     ELSIF upper(p_calling_function) = 'ITEM' THEN
         if (p_classification = 'USER_ITEM_TYPE') then
           BEGIN
             l_value := upper(p_value);
             SELECT 	item_type
             INTO	l_temp
             FROM	MTL_SYSTEM_ITEMS
             WHERE      inventory_item_id = g_cec_product_id
               AND      organization_id =
 			nvl(g_cec_product_org_id, g_cec_so_organization_id);
             -- Open: SO_ORGANIZATION_ID doesn not have a mapping column in eBTax yet
           EXCEPTION
             WHEN NO_DATA_FOUND then
               l_temp  := NULL;
             WHEN TOO_MANY_ROWS then
	       l_temp := NULL;

             WHEN OTHERS then
               RAISE;
           END;
         else
           l_temp := NULL;
           l_value := NULL;
         end if;

         IF (g_level_statement >= g_current_runtime_level) THEN
            FND_LOG.STRING(g_level_statement,
                          'ZX.PLSQL.ZX_TDS_PROCESS_CEC_PVT.compare_condition',
      	                  ' l_temp = '|| l_temp ||
                           ' l_value = ' || l_value);
         END IF;

         IF l_temp is null and l_value is null  then
             return TRUE;
         ELSIF p_operator = '=' THEN
             return l_temp = l_value;
         ELSIF p_operator = '>' THEN
             return l_temp > l_value;
         ELSIF p_operator = '>=' THEN
             return l_temp >= l_value;
         ELSIF p_operator = '<' THEN
             return l_temp < l_value;
         ELSIF p_operator = '<=' THEN
             return l_temp <= l_value;
         ELSIF p_operator = '<>' AND l_temp IS NOT NULL THEN
             return l_temp <> l_value;
         ELSIF p_operator = '<>' AND l_temp IS NULL THEN
             return TRUE;
         ELSE
             return FALSE;
         END IF;
     ELSE
         return FALSE;
     END IF;
     IF (g_level_statement >= g_current_runtime_level ) THEN

         FND_LOG.STRING(g_level_statement,
                   'ZX.PLSQL.ZX_TDS_PROCESS_CEC_PVT.compare_condition.END',
    	           'ZX_TDS_PROCESS_CEC_PVT.compare_condition (-)');
     END IF;
END compare_condition;


/*----------------------------------------------------------------------------*
 | FUNCTION                                                                   |
 |    get_location_column                   			      	      |
 |                                                                            |
 | DESCRIPTION                                                                |
 |    This function gets the application column name based on                 |
 |     the input parameter p_classification, and the address style.           |
 |    Based on the context value of the  'Location Address' Flexfield,        |
 |    the function maps appropriate application_column_name to either         |
 |    county, state, county, province or city.                                |
 |                                                                            |
 | SCOPE - Private                                                            |
 |                                                                            |
 *----------------------------------------------------------------------------*/

FUNCTION get_location_column(p_style IN VARCHAR2,
                              p_classification IN VARCHAR2)
          return VARCHAR2  is

   i         BINARY_INTEGER;
--   l_style   hr_locations_v.style%type;  -- bug fix 4417523
   l_context NUMBER;
   l_column  VARCHAR2(150);

BEGIN

  g_current_runtime_level := FND_LOG.G_CURRENT_RUNTIME_LEVEL;

   IF (g_level_statement >= g_current_runtime_level ) THEN
      FND_LOG.STRING(g_level_statement,
                    'ZX.PLSQL.ZX_TDS_PROCESS_CEC_PVT.get_location_column.BEGIN',
                    'ZX_TDS_PROCESS_CEC_PVT.get_location_column (+)');

     END IF;
   fnd_dflex.get_flexfield(
          'PER',
          'Address Location',
           pr_flexfield,
           pr_flexinfo);

   /*
   --commented out for bug 4417523 begin, the following function is now
   --carried out in get_hr_location()
   l_style := p_style;

-- Get the context information from 'Address Location' Descriptive Flexfield
-- Select the context value which matches p_org_loc_rec.style

   fnd_dflex.get_contexts(pr_flexfield, pr_contexts);
   l_context := NULL;

   FOR i IN 1 .. pr_contexts.ncontexts LOOP
      IF(pr_contexts.is_enabled(i)) THEN
            if pr_contexts.context_code(i) = l_style then

               l_context := i;
            end if;
      END IF;
   END LOOP;

   IF l_context is NULL then
      IF (g_level_statement >= g_current_runtime_level ) THEN
         FND_LOG.STRING(g_level_statement,
                       'ZX.PLSQL.ZX_TDS_PROCESS_CEC_PVT.get_location_column',
      	               'No context which matches the style');

         FND_LOG.STRING(g_level_statement,
                       'ZX.PLSQL.ZX_TDS_PROCESS_CEC_PVT.get_location_column.END',
      	               'ZX_TDS_PROCESS_CEC_PVT.get_location_column (-)');
      END IF;
      return NULL;
   END IF;
  --commented out for bug 4417523 end*/

-- Select the segments which correspond to the selected context.
-- bug fix 4417523 replace pr_contexts.context_code(l_context) with p_style
--   fnd_dflex.get_segments(fnd_dflex.make_context(pr_flexfield,
--                             pr_contexts.context_code(l_context)),
--                          pr_segments,
--                          TRUE);
   fnd_dflex.get_segments(fnd_dflex.make_context(pr_flexfield,
                                                 p_style),
                          pr_segments,
                          TRUE);

-- Check if the segment name matches with the value of input parameter p_classification,
-- Otherwise write an error message and return null

   FOR i IN 1 .. pr_segments.nsegments LOOP

     IF  upper(pr_segments.segment_name(i)) = upper(p_classification) then

           l_column := pr_segments.application_column_name(i);
           IF (g_level_statement >= g_current_runtime_level ) THEN

              FND_LOG.STRING(g_level_statement,
                            'ZX.PLSQL.ZX_TDS_PROCESS_CEC_PVT.get_location_column',
           	            ' Segment name= '||pr_segments.segment_name(i)||
                             ' Column Name= '|| pr_segments.application_column_name(i)||
                             ' Description= '||pr_segments.description(i));
           END IF;
      END IF;

   END LOOP;

   IF l_column is NULL then
      IF (g_level_statement >= g_current_runtime_level ) THEN
         FND_LOG.STRING(g_level_statement,
                       'ZX.PLSQL.ZX_TDS_PROCESS_CEC_PVT.get_location_column',
      	               'No column  which matches the value of '||
                        'input parameter p_classification');
         FND_LOG.STRING(g_level_statement,
                       'ZX.PLSQL.ZX_TDS_PROCESS_CEC_PVT.get_location_column',
      	               'Get Location Column (-)');
      END IF;
   END IF;

   IF (g_level_statement >= g_current_runtime_level ) THEN

         FND_LOG.STRING(g_level_statement,
                       'ZX.PLSQL.ZX_TDS_PROCESS_CEC_PVT.get_location_column.END',
      	               'ZX_TDS_PROCESS_CEC_PVT.get_location_column (-)');
   END IF;
   RETURN l_column;

END get_location_column;

/*----------------------------------------------------------------------------*
 | PROCEDURE                                                                  |
 |    update_pr_stats_rec_tbl                                                 |
 |                                                                            |
 | DESCRIPTION                                                                |
 |    This function updates stats_rec_tbl with status of each condition to    |
 |    be compared.                                                            |
 |                                                                            |
 | SCOPE - Private                                                            |
 |                                                                            |
 *----------------------------------------------------------------------------*/

procedure update_pr_stats_rec_tbl(p_classification IN VARCHAR2,
                                  p_index          IN NUMBER,
                                  p_flag           IN BOOLEAN) is

begin

   g_current_runtime_level := FND_LOG.G_CURRENT_RUNTIME_LEVEL;
   IF (g_level_statement >= g_current_runtime_level ) THEN
      FND_LOG.STRING(g_level_statement,
                    'ZX.PLSQL.ZX_TDS_PROCESS_CEC_PVT.update_pr_stats_rec_tbl.BEGIN',
                    'ZX_TDS_PROCESS_CEC_PVT.update_pr_stats_rec_tbl (+)');
   END IF;

   if (p_flag) then
     if (upper(p_classification) = 'COUNTRY' and
         pr_stats_rec_tbl(p_index).country in (STATS_INIT, STATS_FALSE)) then
       pr_stats_rec_tbl(p_index).country := STATS_TRUE;

     elsif(upper(p_classification) = 'STATE' and
         pr_stats_rec_tbl(p_index).state in (STATS_INIT, STATS_FALSE)) then
       pr_stats_rec_tbl(p_index).state := STATS_TRUE;

     elsif(upper(p_classification) = 'COUNTY' and
         pr_stats_rec_tbl(p_index).county in (STATS_INIT, STATS_FALSE)) then
       pr_stats_rec_tbl(p_index).county := STATS_TRUE;

     elsif(upper(p_classification) = 'CITY' and
         pr_stats_rec_tbl(p_index).county in (STATS_INIT, STATS_FALSE)) then
       pr_stats_rec_tbl(p_index).city := STATS_TRUE;

     elsif(upper(p_classification) = 'PROVINCE' and
         pr_stats_rec_tbl(p_index).province in (STATS_INIT, STATS_FALSE)) then
       pr_stats_rec_tbl(p_index).province := STATS_TRUE;

     elsif(upper(p_classification) = 'FOB' and
         pr_stats_rec_tbl(p_index).fob in (STATS_INIT, STATS_FALSE)) then
       pr_stats_rec_tbl(p_index).fob := STATS_TRUE;

     elsif(upper(p_classification) = 'TAX_CLASSIFICATION' and
         pr_stats_rec_tbl(p_index).tax_classification in (STATS_INIT, STATS_FALSE)) then
       pr_stats_rec_tbl(p_index).tax_classification := STATS_TRUE;

     elsif(upper(p_classification) = 'TYPE' and
         pr_stats_rec_tbl(p_index).type in (STATS_INIT, STATS_FALSE)) then
       pr_stats_rec_tbl(p_index).type := STATS_TRUE;

     elsif(upper(p_classification) = 'USER_ITEM_TYPE' and
         pr_stats_rec_tbl(p_index).user_item_type in (STATS_INIT, STATS_FALSE)) then
       pr_stats_rec_tbl(p_index).user_item_type := STATS_TRUE;

     elsif(upper(p_classification) = 'VAT_NUM' and
         pr_stats_rec_tbl(p_index).vat_reg_num in (STATS_INIT, STATS_FALSE)) then
       pr_stats_rec_tbl(p_index).vat_reg_num := STATS_TRUE;

     elsif(upper(p_classification) = 'WAREHOUSE' and
        pr_stats_rec_tbl(p_index).warehouse in (STATS_INIT, STATS_FALSE)) then
        pr_stats_rec_tbl(p_index).warehouse := STATS_TRUE;
     end if;
   else
     if (upper(p_classification) = 'COUNTRY' and
         pr_stats_rec_tbl(p_index).country = STATS_INIT) then
       pr_stats_rec_tbl(p_index).country := STATS_FALSE;

     elsif(upper(p_classification) = 'STATE' and
         pr_stats_rec_tbl(p_index).state = STATS_INIT) then
       pr_stats_rec_tbl(p_index).state := STATS_FALSE;
     elsif(upper(p_classification) = 'COUNTY' and
         pr_stats_rec_tbl(p_index).county = STATS_INIT) then
       pr_stats_rec_tbl(p_index).county := STATS_FALSE;

     elsif(upper(p_classification) = 'CITY' and
         pr_stats_rec_tbl(p_index).city = STATS_INIT) then
       pr_stats_rec_tbl(p_index).city := STATS_FALSE;

     elsif(upper(p_classification) = 'PROVINCE' and
         pr_stats_rec_tbl(p_index).province = STATS_INIT) then
       pr_stats_rec_tbl(p_index).province := STATS_FALSE;

     elsif(upper(p_classification) = 'FOB' and
         pr_stats_rec_tbl(p_index).fob = STATS_INIT) then
       pr_stats_rec_tbl(p_index).fob := STATS_FALSE;

     elsif(upper(p_classification) = 'TAX_CLASSIFICATION' and
         pr_stats_rec_tbl(p_index).tax_classification = STATS_INIT) then
       pr_stats_rec_tbl(p_index).tax_classification := STATS_FALSE;

     elsif(upper(p_classification) = 'TYPE' and
         pr_stats_rec_tbl(p_index).type = STATS_INIT) then
       pr_stats_rec_tbl(p_index).type := STATS_FALSE;

     elsif(upper(p_classification) = 'USER_ITEM_TYPE' and
         pr_stats_rec_tbl(p_index).user_item_type = STATS_INIT) then
       pr_stats_rec_tbl(p_index).user_item_type := STATS_FALSE;

     elsif(upper(p_classification) = 'VAT_NUM' and
         pr_stats_rec_tbl(p_index).vat_reg_num = STATS_INIT) then
       pr_stats_rec_tbl(p_index).vat_reg_num := STATS_FALSE;

     elsif(upper(p_classification) = 'WAREHOUSE' and
         pr_stats_rec_tbl(p_index).warehouse = STATS_INIT) then
       pr_stats_rec_tbl(p_index).warehouse := STATS_FALSE;
     end if;
   end if;

   IF (g_level_statement >= g_current_runtime_level ) THEN
      FND_LOG.STRING(g_level_statement,
                    'ZX.PLSQL.ZX_TDS_PROCESS_CEC_PVT.update_pr_stats_rec_tbl.END',
                    'ZX_TDS_PROCESS_CEC_PVT.update_pr_stats_rec_tbl (-)');
   END IF;
end update_pr_stats_rec_tbl;

/*===========================================================================+
 | PROCEDURE                                                                 |
 |  dump_stats_rec                                                           |
 |                                                                           |
 | DESCRIPTION                                                               |
 |   dumps the image of pr_stats_rec_tbl(x)                                  |
 |                                                                           |
 | SCOPE - Private                                                           |
 |                                                                           |
 +===========================================================================*/
procedure dump_stats_rec(p_x in number) is

  l_x VARCHAR2(20);

begin

  g_current_runtime_level := FND_LOG.G_CURRENT_RUNTIME_LEVEL;
  IF (g_level_statement >= g_current_runtime_level) THEN
     FND_LOG.STRING(g_level_statement,
                   'ZX.PLSQL.ZX_TDS_PROCESS_CEC_PVT.dump_stats_rec.BEGIN',
                   ' ZX_TDS_PROCESS_CEC_PVT.dump_stats_rec (+)');

  END IF;

  if    (p_x = IDX_SHIP_FROM) then
      l_x := 'SHIP FROM';
  elsif (p_x = IDX_SHIP_TO) then
      l_x := 'SHIP TO';
  elsif (p_x = IDX_POO) then
      l_x := 'POO';
  elsif (p_x = IDX_POA) then
      l_x := 'POA';
  elsif (p_x = IDX_BILL_TO) then
      l_x := 'BILL TO';
  elsif (p_x = IDX_TRX) then
      l_x := 'TRX';
  elsif (p_x = IDX_ITEM) then
      l_x := 'ITEM';
  elsif (p_x = IDX_TAX_CODE) then
      l_x := 'TAX_CODE';
  end if;

  IF (g_level_statement >= g_current_runtime_level) THEN

     FND_LOG.STRING(g_level_statement,
                   'ZX.PLSQL.ZX_TDS_PROCESS_CEC_PVT.dump_stats_rec.END',
                   ' ZX_TDS_PROCESS_CEC_PVT.dump_stats_rec (-)');
  END IF;
end dump_stats_rec;

/*===========================================================================+
 | PROCEDURE                                                                 |
 |  dump_pr_stats_rec_tbl                                                    |
 |                                                                           |
 | DESCRIPTION                                                               |
 |   dumps the image of pr_stats_rec_tbl                                     |
 |                                                                           |
 | SCOPE - Private                                                           |
 |                                                                           |
 +===========================================================================*/
procedure dump_pr_stats_rec_tbl is

begin

  g_current_runtime_level := FND_LOG.G_CURRENT_RUNTIME_LEVEL;
  IF (g_level_statement >= g_current_runtime_level) THEN
     FND_LOG.STRING(g_level_statement,
                   'ZX.PLSQL.ZX_TDS_PROCESS_CEC_PVT.dump_pr_stats_rec_tbl.BEGIN',
                   ' ZX_TDS_PROCESS_CEC_PVT.dump_pr_stats_rec_tbl (+)');
  END IF;

  for i in IDX_SHIP_FROM .. IDX_TAX_CODE LOOP
    dump_stats_rec(i);
  end LOOP;

  IF (g_level_statement >= g_current_runtime_level) THEN
     FND_LOG.STRING(g_level_statement,
                   'ZX.PLSQL.ZX_TDS_PROCESS_CEC_PVT.dump_pr_stats_rec_tbl.END',
                   ' ZX_TDS_PROCESS_CEC_PVT.dump_pr_stats_rec_tbl (-)');
  END IF;
end dump_pr_stats_rec_tbl;

-------------------
-- Public Methods -
-------------------

/*----------------------------------------------------------------------------*
 |   The following functions                     			      |
 |          ship_to,                                                          |
 |          ship_from,                                                        |
 |          poo,                                                              |
 |          poa,                                                              |
 |          trx,                                                              |
 |          item                                                              |
 |          tax_code                                                          |
 |  call private function compare_condition which compares  the site          |
 |  location (obtained by calling get_site_location function with the         |
 |  parameter p_classification) with p_value using the operator p_operator    |
 |  and returns true or false based on the result.                            |
 *----------------------------------------------------------------------------*/

--  This function checks whether the condition (built using input parameters)
--  evaluates to TRUE or FALSE for a Ship To site (identified by tax_info_rec.
--  ship_to_site_use_id)
FUNCTION  tax_code
            (p_classification IN VARCHAR2 Default NULL,
             p_operator       IN VARCHAR2 Default NULL,
             p_value          IN VARCHAR2 DEFAULT NULL)
          return BOOLEAN is

  l_return_val BOOLEAN;

BEGIN

  g_current_runtime_level := FND_LOG.G_CURRENT_RUNTIME_LEVEL;
  l_return_val := FALSE;

  IF (g_level_statement >= g_current_runtime_level) THEN
    FND_LOG.STRING(g_level_statement,
                   'ZX.PLSQL.ZX_TDS_PROCESS_CEC_PVT.tax_code.BEGIN',
                   'ZX_TDS_PROCESS_CEC_PVT.tax_code (+)');
  END IF;

  l_return_val := compare_condition ( g_cec_ship_to_party_site_id,
                             'TAX_CODE',
                             p_classification,
                             p_operator,
                             p_value);
  if l_return_val = TRUE then
     IF (g_level_statement >= g_current_runtime_level ) THEN
        FND_LOG.STRING(g_level_statement,
                       'ZX.PLSQL.ZX_TDS_PROCESS_CEC_PVT.tax_code',
    	               'The condition Tax code '||p_classification||
                        p_operator||p_value||'  evaluates to TRUE');
     END IF;
  else
     IF (g_level_statement >= g_current_runtime_level ) THEN
        FND_LOG.STRING(g_level_statement,
                       'ZX.PLSQL.ZX_TDS_PROCESS_CEC_PVT.tax_code',
    	               'The condition Tax code '||p_classification||
                        p_operator||p_value||'  evaluates to FALSE');
     END IF;
  end if;
 -- Only when p_oprator is not NOT_FOUND, update pr_stats_rec_tbl.
 if (p_operator <> 'NOT_FOUND') then
   update_pr_stats_rec_tbl(p_classification => p_classification,
                           p_index => IDX_TAX_CODE,
                           p_flag => l_return_val);
   dump_stats_rec(IDX_TAX_CODE);  --for bug1833141
 end if;
 IF (g_level_statement >= g_current_runtime_level) THEN
    FND_LOG.STRING(g_level_statement,
                  'ZX.PLSQL.ZX_TDS_PROCESS_CEC_PVT.tax_code.END',
                  'ZX_TDS_PROCESS_CEC_PVT.tax_code (-)');
 END IF;
 return l_return_val;
END tax_code;

FUNCTION  ship_to
            (p_classification IN VARCHAR2 Default NULL,
             p_operator       IN VARCHAR2 Default NULL,
             p_value          IN VARCHAR2 DEFAULT NULL)
          return BOOLEAN is

  l_return_val BOOLEAN;

BEGIN

  g_current_runtime_level := FND_LOG.G_CURRENT_RUNTIME_LEVEL;
  l_return_val := FALSE;

 IF (g_level_statement >= g_current_runtime_level ) THEN
    FND_LOG.STRING(g_level_statement,
                   'ZX.PLSQL.ZX_TDS_PROCESS_CEC_PVT.ship_to.BEGIN',
                   'ZX_TDS_PROCESS_CEC_PVT.Ship_To (+)');
 END IF;

 l_return_val := compare_condition ( g_cec_ship_to_site_use_id,
                             'SHIP_TO',
                             p_classification,
                             p_operator,
                             p_value);
 if l_return_val = TRUE then
    IF (g_level_statement >= g_current_runtime_level ) THEN
        FND_LOG.STRING(g_level_statement,
                      'ZX.PLSQL.ZX_TDS_PROCESS_CEC_PVT.ship_to',
   	              'The condition Ship to '||p_classification||
                       p_operator||p_value||'  evaluates to TRUE');
    END IF;
 else
    IF (g_level_statement >= g_current_runtime_level ) THEN
        FND_LOG.STRING(g_level_statement,
                      'ZX.PLSQL.ZX_TDS_PROCESS_CEC_PVT.ship_to',
                      'The condition Ship to '||p_classification||
                       p_operator||p_value||'  evaluates to FALSE');
    END IF;
 end if;
 -- Only when p_oprator is not NOT_FOUND, update pr_stats_rec_tbl.
 if (p_operator <> 'NOT_FOUND') then
   update_pr_stats_rec_tbl(p_classification => p_classification,
                           p_index => IDX_SHIP_TO,
                           p_flag => l_return_val);
   dump_stats_rec(IDX_SHIP_TO);   --for bug1833141
 end if;
 IF (g_level_statement >= g_current_runtime_level ) THEN
    FND_LOG.STRING(g_level_statement,
                   'ZX.PLSQL.ZX_TDS_PROCESS_CEC_PVT.ship_to.END',
                   'ZX_TDS_PROCESS_CEC_PVT.Ship_To (-)');
 END IF;
 return l_return_val;
END ship_to;

----------------------------------------------------------------------------
--  This function checks whether the condition (built using input parameters)
--  evaluates to TRUE or FALSE for a point of Order Acceptance (identified
--  through tax_info_rec.ship_from_warehouse_id)

FUNCTION  ship_from
            (p_classification IN VARCHAR2 Default NULL,
             p_operator       IN VARCHAR2 Default NULL,
             p_value          IN VARCHAR2 DEFAULT NULL)
          return BOOLEAN is

 l_return_val BOOLEAN;

BEGIN

  g_current_runtime_level := FND_LOG.G_CURRENT_RUNTIME_LEVEL;
  l_return_val := FALSE;

 IF (g_level_statement >= g_current_runtime_level ) THEN
    FND_LOG.STRING(g_level_statement,
                   'ZX.PLSQL.ZX_TDS_PROCESS_CEC_PVT.ship_from.BEGIN',
                   'ZX_TDS_PROCESS_CEC_PVT.Ship_From(+)');
 END IF;

 l_return_val := compare_condition ( g_cec_product_org_id,
                             'SHIP_FROM',
                             p_classification,
                             p_operator,
                             p_value);
 if l_return_val = TRUE then
    IF (g_level_statement >= g_current_runtime_level ) THEN
       FND_LOG.STRING(g_level_statement,
                      'ZX.PLSQL.ZX_TDS_PROCESS_CEC_PVT.ship_from',
   	              'The condition Ship From '||p_classification||
                       p_operator||p_value||' evaluates to TRUE');
    END IF;
 else
    IF (g_level_statement >= g_current_runtime_level ) THEN
       FND_LOG.STRING(g_level_statement,
                      'ZX.PLSQL.ZX_TDS_PROCESS_CEC_PVT.ship_from',
                      'The condition Ship From '||p_classification||
                       p_operator||p_value||' evaluates to FALSE');
    END IF;
 end if;
 -- Only when p_oprator is not NOT_FOUND, update pr_stats_rec_tbl.
 if (p_operator <> 'NOT_FOUND') then
   update_pr_stats_rec_tbl(p_classification => p_classification,
                           p_index => IDX_SHIP_FROM,
                           p_flag => l_return_val);
   dump_stats_rec(IDX_SHIP_FROM);  --for bug1833141
 end if;
 IF (g_level_statement >= g_current_runtime_level ) THEN
    FND_LOG.STRING(g_level_statement,
                   'ZX.PLSQL.ZX_TDS_PROCESS_CEC_PVT.ship_from.END',
                   'ZX_TDS_PROCESS_CEC_PVT.Ship_From (-)');
 END IF;
 return l_return_val;
END ship_from;


-----------------------------------------------------------------------------
--  This function checks whether the condition (built using input parameters)
--  evaluates to TRUE or FALSE for a Bill To Site (identified through
--  tax_info_rec.bill_to_site_use_id)

FUNCTION  bill_to
            (p_classification IN VARCHAR2 Default NULL,
             p_operator       IN VARCHAR2 Default NULL,
             p_value          IN VARCHAR2 DEFAULT NULL)
          return BOOLEAN is

  l_return_val BOOLEAN;

BEGIN

  g_current_runtime_level := FND_LOG.G_CURRENT_RUNTIME_LEVEL;
  l_return_val := FALSE;

 IF (g_level_statement >= g_current_runtime_level ) THEN
    FND_LOG.STRING(g_level_statement,
                   'ZX.PLSQL.ZX_TDS_PROCESS_CEC_PVT.bill_to.BEGIN',
                   'ZX_TDS_PROCESS_CEC_PVT.bill_to (+)');
 END IF;

 l_return_val := compare_condition ( g_cec_bill_to_site_use_id,
                             'BILL_TO',
                             p_classification,
                             p_operator,
                             p_value);
 if l_return_val = TRUE then
    IF (g_level_statement >= g_current_runtime_level ) THEN
       FND_LOG.STRING(g_level_statement,
                     'ZX.PLSQL.ZX_TDS_PROCESS_CEC_PVT.bill_to',
   	             'The condition Bill to '||p_classification||
                      p_operator||p_value||' evaluates to TRUE');
    END IF;
 else
    IF (g_level_statement >= g_current_runtime_level ) THEN
       FND_LOG.STRING(g_level_statement,
                     'ZX.PLSQL.ZX_TDS_PROCESS_CEC_PVT.bill_to',
                     'The condition Bill to '||p_classification||
                      p_operator||p_value||' evaluates to FALSE');
    END IF;
 end if;
 -- Only when p_operator is not NOT_FOUND, update pr_stats_rec_tbl.
 if (p_operator <> 'NOT_FOUND') then
   update_pr_stats_rec_tbl(p_classification => p_classification,
                           p_index => IDX_BILL_TO,
                           p_flag => l_return_val);
   dump_stats_rec(IDX_BILL_TO);
 end if;
 IF (g_level_statement >= g_current_runtime_level ) THEN
    FND_LOG.STRING(g_level_statement,
                   'ZX.PLSQL.ZX_TDS_PROCESS_CEC_PVT.bill_to.END',
                   'ZX_TDS_PROCESS_CEC_PVT.bill_to (-)');
 END IF;
 return l_return_val;
END bill_to;

--------------------------------------------------------------------------
--  This function checks whether the condition (built using input parameters)
--  evaluates to TRUE or FALSE for a point of Order Origin (identified
--  through tax_info_rec.poo_id)

FUNCTION  poo
            (p_classification IN VARCHAR2 Default NULL,
             p_operator       IN VARCHAR2 Default NULL,
             p_value          IN VARCHAR2 DEFAULT NULL)
          return BOOLEAN is

  l_return_val BOOLEAN;

BEGIN

  g_current_runtime_level := FND_LOG.G_CURRENT_RUNTIME_LEVEL;
  l_return_val := FALSE;

 IF (g_level_statement >= g_current_runtime_level ) THEN
     FND_LOG.STRING(g_level_statement,
                   'ZX.PLSQL.ZX_TDS_PROCESS_CEC_PVT.poo.BEGIN',
                   'ZX_TDS_PROCESS_CEC_PVT.poo (+)');

 END IF;

 l_return_val := compare_condition ( g_cec_poo_location_id,
                             'POO',
                             p_classification,
                             p_operator,
                             p_value);
 if l_return_val = TRUE then
    IF (g_level_statement >= g_current_runtime_level ) THEN
        FND_LOG.STRING(g_level_statement,
                      'ZX.PLSQL.ZX_TDS_PROCESS_CEC_PVT.poo',
   	              'The condition POO '||p_classification||
                       p_operator||p_value||'  evaluates to TRUE');
    END IF;
 else
    IF (g_level_statement >= g_current_runtime_level ) THEN
        FND_LOG.STRING(g_level_statement,
                      'ZX.PLSQL.ZX_TDS_PROCESS_CEC_PVT.poo',
   	              'The condition POO '||p_classification||
                       p_operator||p_value||'  evaluates to FALSE');
    END IF;
 end if;
 -- Only when p_oprator is not NOT_FOUND, update pr_stats_rec_tbl.
 if (p_operator <> 'NOT_FOUND') then
   update_pr_stats_rec_tbl(p_classification => p_classification,
                           p_index => IDX_POO,
                           p_flag => l_return_val);
   dump_stats_rec(IDX_POO);   --for bug1833141
 end if;
 IF (g_level_statement >= g_current_runtime_level ) THEN
     FND_LOG.STRING(g_level_statement,
                   'ZX.PLSQL.ZX_TDS_PROCESS_CEC_PVT.poo',
                   'Point of Origin (-)');
     FND_LOG.STRING(g_level_statement,
                   'ZX.PLSQL.ZX_TDS_PROCESS_CEC_PVT.poo.END',
                   'ZX_TDS_PROCESS_CEC_PVT.poo (-)');
 END IF;
 return l_return_val;
END poo;

---------------------------------------------------------------------------
--  This function checks whether the condition (built using input parameters)
--  evaluates to TRUE or FALSE for a point of Order Acceptance (identified
--  through tax_info_rec.poa_id)

FUNCTION  poa
            (p_classification IN VARCHAR2 Default NULL,
             p_operator       IN VARCHAR2 Default NULL,
             p_value          IN VARCHAR2 DEFAULT NULL)
          return BOOLEAN is

  l_return_val BOOLEAN;

BEGIN

  g_current_runtime_level := FND_LOG.G_CURRENT_RUNTIME_LEVEL;
  l_return_val := FALSE;

 IF (g_level_statement >= g_current_runtime_level ) THEN
     FND_LOG.STRING(g_level_statement,
                   'ZX.PLSQL.ZX_TDS_PROCESS_CEC_PVT.poa.BEGIN',
                   'ZX_TDS_PROCESS_CEC_PVT.poa (+)');

 END IF;

 l_return_val := compare_condition ( g_cec_poa_location_id,
                             'POA',
                             p_classification,
                             p_operator,
                             p_value);
 if l_return_val = TRUE then
    IF (g_level_statement >= g_current_runtime_level ) THEN
        FND_LOG.STRING(g_level_statement,
                      'ZX.PLSQL.ZX_TDS_PROCESS_CEC_PVT.poa',
   	              'The condition POA '||p_classification||
                       p_operator||p_value||'  evaluates to TRUE');
    END IF;
 else
    IF (g_level_statement >= g_current_runtime_level ) THEN
        FND_LOG.STRING(g_level_statement,
                      'ZX.PLSQL.ZX_TDS_PROCESS_CEC_PVT.poa',
   	              'The condition POA '||p_classification||
                       p_operator||p_value||'  evaluates to FALSE');
    END IF;
 end if;

 if (p_operator <> 'NOT_FOUND') then
   update_pr_stats_rec_tbl(p_classification => p_classification,
                           p_index => IDX_POA,
                           p_flag => l_return_val);
   dump_stats_rec(IDX_POA);
 end if;
 IF (g_level_statement >= g_current_runtime_level ) THEN

     FND_LOG.STRING(g_level_statement,
                   'ZX.PLSQL.ZX_TDS_PROCESS_CEC_PVT.poa.END',
                   'ZX_TDS_PROCESS_CEC_PVT.poa (-)');
 END IF;
 return l_return_val;
END poa;

-------------------------------------------------------------------------
--  This function checks whether the condition (built using input parameters)
--  evaluates to TRUE or FALSE for an transaction (Identified by tax_info_rec.
--  customer_trx_id)

FUNCTION  trx
            (p_classification IN VARCHAR2 Default NULL,
             p_operator       IN VARCHAR2 Default NULL,
             p_value          IN VARCHAR2 DEFAULT NULL)
          return BOOLEAN is

  l_return_val BOOLEAN;

BEGIN

  g_current_runtime_level := FND_LOG.G_CURRENT_RUNTIME_LEVEL;
  l_return_val := FALSE;

 IF (g_level_statement >= g_current_runtime_level ) THEN
     FND_LOG.STRING(g_level_statement,
                   'ZX.PLSQL.ZX_TDS_PROCESS_CEC_PVT.trx.BEGIN',
                   'ZX_TDS_PROCESS_CEC_PVT.trx (+)');

 END IF;

 l_return_val := compare_condition (
                             g_cec_trx_id,
                             'TRX',
                             p_classification,
                             p_operator,
                             p_value);
 if l_return_val = TRUE then
    IF (g_level_statement >= g_current_runtime_level ) THEN
        FND_LOG.STRING(g_level_statement,
                      'ZX.PLSQL.ZX_TDS_PROCESS_CEC_PVT.trx',
   	              'The Trx condition evaluates to TRUE');
    END IF;
 else
    IF (g_level_statement >= g_current_runtime_level ) THEN
        FND_LOG.STRING(g_level_statement,
                      'ZX.PLSQL.ZX_TDS_PROCESS_CEC_PVT.trx',
                      'The Trx condition evaluates to FALSE');
    END IF;
 end if;
 -- Only when p_oprator is not NOT_FOUND, update pr_stats_rec_tbl.
 if (p_operator <> 'NOT_FOUND') then
   update_pr_stats_rec_tbl(p_classification => p_classification,
                           p_index => IDX_TRX,
                           p_flag => l_return_val);
   dump_stats_rec(IDX_TRX); --for bug1833141
 end if;
 IF (g_level_statement >= g_current_runtime_level ) THEN

     FND_LOG.STRING(g_level_statement,
                   'ZX.PLSQL.ZX_TDS_PROCESS_CEC_PVT.trx.END',
                   'ZX_TDS_PROCESS_CEC_PVT.trx (-)');
 END IF;

 return l_return_val;
END trx;

-------------------------------------------------------------------------
--  This function checks whether the condition (built using input parameters)
--  evaluates to TRUE or FALSE for an item (identified through a transaction
--  line)

FUNCTION  item (p_classification IN VARCHAR2 Default NULL,
                p_operator       IN VARCHAR2 Default NULL,
                p_value          IN VARCHAR2 DEFAULT NULL) return BOOLEAN is

  l_return_val BOOLEAN ;

BEGIN

  g_current_runtime_level := FND_LOG.G_CURRENT_RUNTIME_LEVEL;
 l_return_val := FALSE;

 IF (g_level_statement >= g_current_runtime_level ) THEN
    FND_LOG.STRING(g_level_statement,
                   'ZX.PLSQL.ZX_TDS_PROCESS_CEC_PVT.item.BEGIN',
                   'ZX_TDS_PROCESS_CEC_PVT.item (+)');
 END IF;


  l_return_val := compare_condition ( g_cec_trx_line_id,
                             'ITEM',
                             p_classification,
                             p_operator,
                             p_value);
 if l_return_val = TRUE then
    IF (g_level_statement >= g_current_runtime_level ) THEN
        FND_LOG.STRING(g_level_statement,
                   'ZX.PLSQL.ZX_TDS_PROCESS_CEC_PVT.item',
                   'Item Condition Evaluates to TRUE');
     END IF;
 else
    IF (g_level_statement >= g_current_runtime_level ) THEN
        FND_LOG.STRING(g_level_statement,
                   'ZX.PLSQL.ZX_TDS_PROCESS_CEC_PVT.item',
                   'Item Condition Evaluates to FALSE');
     END IF;
 end if;
 --
 -- Only when p_oprator is not NOT_FOUND, update pr_stats_rec_tbl.
 --
 if (p_operator <> 'NOT_FOUND') then
   --
   update_pr_stats_rec_tbl(p_classification => p_classification,
                           p_index => IDX_ITEM,
                           p_flag => l_return_val);
   --
   dump_stats_rec(IDX_ITEM); --for bug1833141
 end if;

 IF (g_level_statement >= g_current_runtime_level ) THEN
    FND_LOG.STRING(g_level_statement,
                   'ZX.PLSQL.ZX_TDS_PROCESS_CEC_PVT.item.END',
                   'ZX_TDS_PROCESS_CEC_PVT.item (-)');
 END IF;
 return l_return_val;
END item;

-------------------------------------------------------------------------
-- The procedure user_message puts the user supplied message on the message
-- stack

PROCEDURE user_message (p_msg IN VARCHAR2 default NULL) is
BEGIN

  g_current_runtime_level := FND_LOG.G_CURRENT_RUNTIME_LEVEL;

 IF (g_level_statement >= g_current_runtime_level ) THEN
    FND_LOG.STRING(g_level_statement,
                   'ZX.PLSQL.ZX_TDS_PROCESS_CEC_PVT.user_message.BEGIN',
                   'ZX_TDS_PROCESS_CEC_PVT.user_message (+)');
 END IF;
 if (p_msg is not null) then
   pr_message_token := p_msg;
 end if;
 IF (g_level_statement >= g_current_runtime_level ) THEN
    FND_LOG.STRING(g_level_statement,
                   'ZX.PLSQL.ZX_TDS_PROCESS_CEC_PVT.user_message.END',
                   'ZX_TDS_PROCESS_CEC_PVT.user_message (-)');
 END IF;

END user_message;

------------------------------------------------------------------------
-- The procedure system_message puts the user message, as well as the
-- Oracle error message on the message stack

PROCEDURE system_message (p_msg IN VARCHAR2 default NULL) is

BEGIN

  g_current_runtime_level := FND_LOG.G_CURRENT_RUNTIME_LEVEL;

 IF (g_level_statement >= g_current_runtime_level ) THEN
    FND_LOG.STRING(g_level_statement,
                   'ZX.PLSQL.ZX_TDS_PROCESS_CEC_PVT.system_message.BEGIN',
                   'ZX_TDS_PROCESS_CEC_PVT.system_message (+)');
 END IF;

 if (p_msg is not null) then
   pr_message_token := fnd_message.get_string('AR',p_msg);
   if(pr_message_token is null) then
     pr_message_token := 'System Error';
   end if;
 end if;

 IF (g_level_statement >= g_current_runtime_level ) THEN
    FND_LOG.STRING(g_level_statement,
                   'ZX.PLSQL.ZX_TDS_PROCESS_CEC_PVT.system_message.END',
                   'ZX_TDS_PROCESS_CEC_PVT.system_message (-)');
 END IF;

END system_message;

PROCEDURE apply_exception (p_exception IN VARCHAR2 default NULL) is
BEGIN

  g_current_runtime_level := FND_LOG.G_CURRENT_RUNTIME_LEVEL;

  IF (g_level_statement >= g_current_runtime_level ) THEN
    FND_LOG.STRING(g_level_statement,
                   'ZX.PLSQL.ZX_TDS_PROCESS_CEC_PVT.apply_exception.BEGIN',
                   'ZX_TDS_PROCESS_CEC_PVT.Apply_Exception (+)');
  END IF;
  -- set pr_tax_rate with p_exception.
  if (p_exception is not null) then
    pr_tax_rate := to_number(p_exception);
  end if;

  IF (g_level_statement >= g_current_runtime_level ) THEN
    FND_LOG.STRING(g_level_statement,
                   'ZX.PLSQL.ZX_TDS_PROCESS_CEC_PVT.apply_exception.END',
                   'ZX_TDS_PROCESS_CEC_PVT.Apply_Exception (-)');
  END IF;

END apply_exception;

PROCEDURE do_not_apply_exception (p_exception IN VARCHAR2 default NULL) is
BEGIN

  g_current_runtime_level := FND_LOG.G_CURRENT_RUNTIME_LEVEL;

  IF (g_level_statement >= g_current_runtime_level ) THEN
    FND_LOG.STRING(g_level_statement,
                   'ZX.PLSQL.ZX_TDS_PROCESS_CEC_PVT.do_not_apply_exception.BEGIN',
                   'ZX_TDS_PROCESS_CEC_PVT.Do_Not_Apply_Exception (+)');
  END IF;
  NULL;
  IF (g_level_statement >= g_current_runtime_level ) THEN
    FND_LOG.STRING(g_level_statement,
                   'ZX.PLSQL.ZX_TDS_PROCESS_CEC_PVT.do_not_apply_exception.END',
                   'ZX_TDS_PROCESS_CEC_PVT.Do_Not_Apply_Exception (-)');
  END IF;

END do_not_apply_exception;

PROCEDURE use_tax_code (p_tax_code IN VARCHAR2 default NULL) is
BEGIN

  g_current_runtime_level := FND_LOG.G_CURRENT_RUNTIME_LEVEL;

  IF (g_level_statement >= g_current_runtime_level ) THEN
    FND_LOG.STRING(g_level_statement,
                   'ZX.PLSQL.ZX_TDS_PROCESS_CEC_PVT.use_tax_code.BEGIN',
                   'ZX_TDS_PROCESS_CEC_PVT.use_tax_code (+)');
    FND_LOG.STRING(g_level_statement,
                   'ZX.PLSQL.ZX_TDS_PROCESS_CEC_PVT.use_tax_code.END',
                   'ZX_TDS_PROCESS_CEC_PVT.use_tax_code (-)');
  END IF;

END use_tax_code;

PROCEDURE use_this_tax_code (p_tax_code IN VARCHAR2 default NULL) is
BEGIN

  g_current_runtime_level := FND_LOG.G_CURRENT_RUNTIME_LEVEL;

  IF (g_level_statement >= g_current_runtime_level ) THEN
    FND_LOG.STRING(g_level_statement,
                   'ZX.PLSQL.ZX_TDS_PROCESS_CEC_PVT.use_this_tax_code.BEGIN',
                   'ZX_TDS_PROCESS_CEC_PVT.use_this_tax_code (+)');
    FND_LOG.STRING(g_level_statement,
                   'ZX.PLSQL.ZX_TDS_PROCESS_CEC_PVT.use_this_tax_code.END',
                   'ZX_TDS_PROCESS_CEC_PVT.use_this_tax_code (-)');
  END IF;

END use_this_tax_code;

PROCEDURE default_tax_code (p_tax_code IN VARCHAR2 default NULL) is
BEGIN

  g_current_runtime_level := FND_LOG.G_CURRENT_RUNTIME_LEVEL;

  IF (g_level_statement >= g_current_runtime_level ) THEN
    FND_LOG.STRING(g_level_statement,
                   'ZX.PLSQL.ZX_TDS_PROCESS_CEC_PVT.default_tax_code.BEGIN',
                   'ZX_TDS_PROCESS_CEC_PVT.default_tax_code (+)');
    FND_LOG.STRING(g_level_statement,
                   'ZX.PLSQL.ZX_TDS_PROCESS_CEC_PVT.default_tax_code.END',
                   'ZX_TDS_PROCESS_CEC_PVT.default_tax_code (-)');
  END IF;

END default_tax_code;

PROCEDURE use_this_tax_group (p_tax_group_code IN VARCHAR2 default NULL) is
BEGIN

  g_current_runtime_level := FND_LOG.G_CURRENT_RUNTIME_LEVEL;

  IF (g_level_statement >= g_current_runtime_level ) THEN
    FND_LOG.STRING(g_level_statement,
                   'ZX.PLSQL.ZX_TDS_PROCESS_CEC_PVT.use_this_tax_group.BEGIN',
                   'ZX_TDS_PROCESS_CEC_PVT.use_this_tax_group (+)');

    FND_LOG.STRING(g_level_statement,
                   'ZX.PLSQL.ZX_TDS_PROCESS_CEC_PVT.use_this_tax_group.END',
                   'ZX_TDS_PROCESS_CEC_PVT.use_this_tax_group (-)');
  END IF;

END use_this_tax_group;

PROCEDURE do_not_use_this_tax_code(p_param IN VARCHAR2 DEFAULT NULL) is
BEGIN

  g_current_runtime_level := FND_LOG.G_CURRENT_RUNTIME_LEVEL;

  IF (g_level_statement >= g_current_runtime_level ) THEN
    FND_LOG.STRING(g_level_statement,
                   'ZX.PLSQL.ZX_TDS_PROCESS_CEC_PVT.do_not_use_this_tax_code.BEGIN',
                   'ZX_TDS_PROCESS_CEC_PVT.do_not_use_this_tax_code (+)');
  END IF;
  pr_do_not_use_this_tax_flag := TRUE;
  IF (g_level_statement >= g_current_runtime_level ) THEN
    FND_LOG.STRING(g_level_statement,
                   'ZX.PLSQL.ZX_TDS_PROCESS_CEC_PVT.do_not_use_this_tax_code.END',
                   'ZX_TDS_PROCESS_CEC_PVT.do_not_use_this_tax_code (-)');
  END IF;

END do_not_use_this_tax_code;

PROCEDURE do_not_use_this_tax_group(p_param IN VARCHAR2 DEFAULT NULL) is
BEGIN

  g_current_runtime_level := FND_LOG.G_CURRENT_RUNTIME_LEVEL;

  IF (g_level_statement >= g_current_runtime_level ) THEN
    FND_LOG.STRING(g_level_statement,
                   'ZX.PLSQL.ZX_TDS_PROCESS_CEC_PVT.do_not_use_this_tax_group.BEGIN',
                   'ZX_TDS_PROCESS_CEC_PVT.do_not_use_this_tax_group (+)');

  END IF;
  pr_do_not_use_this_group_flag := TRUE;
  IF (g_level_statement >= g_current_runtime_level ) THEN

    FND_LOG.STRING(g_level_statement,
                   'ZX.PLSQL.ZX_TDS_PROCESS_CEC_PVT.do_not_use_this_tax_group.END',
                   'ZX_TDS_PROCESS_CEC_PVT.do_not_use_this_tax_group (-)');
  END IF;

END do_not_use_this_tax_group;

/*===========================================================================+
 | FUNCTION                                                                  |
 |   evaluate_cec                                                            |
 |                                                                           |
 | DESCRIPTION                                                               |
 |    This procedure evaluates Condition Set, Exception Set and Constraint   |
 |    defined in old GTE model for a given Tax Group based on the passed     |
 |    values like Condition Set Id, Exception Set Id and Constraint Id.      |
 |    The old Tax Groups model along with its associated Condition Set Id,   |
 |    Exception Set Id and Constraint Id is migrated into Tax Rules Model of |
 |    E-Business Tax during Defaulting Hierarchy Migration into Associated   |
 |    Condition Groups of Rules for Condition Set Id and Exception Set Id    |
 |    and into Condition Groups for Constraint Id.                           |
 |                                                                           |
 | SCOPE                                                                     |
 |    PUBLIC                                                                 |
 |                                                                           |
 +===========================================================================*/

PROCEDURE evaluate_cec (p_constraint_id               IN     NUMBER DEFAULT NULL,
                       p_condition_set_id             IN     NUMBER DEFAULT NULL,
                       p_exception_set_id             IN     NUMBER DEFAULT NULL,
                       p_cec_ship_to_party_site_id    IN     NUMBER,
                       p_cec_bill_to_party_site_id    IN     NUMBER,
                       p_cec_ship_to_party_id         IN     NUMBER,
                       p_cec_bill_to_party_id         IN     NUMBER,
                       p_cec_poo_location_id          IN     NUMBER,
                       p_cec_poa_location_id          IN     NUMBER,
                       p_cec_trx_id                   IN     NUMBER,
                       p_cec_trx_line_id              IN     NUMBER,
                       p_cec_ledger_id                IN     NUMBER,
                       p_cec_internal_organization_id IN     NUMBER,
                       p_cec_so_organization_id       IN     NUMBER,
                       p_cec_product_org_id           IN     NUMBER,
                       p_cec_product_id               IN     NUMBER,
                       p_cec_trx_type_id              IN     NUMBER,
                       p_cec_trx_line_date            IN     DATE,
                       p_cec_fob_point                IN     VARCHAR2,
		       p_cec_ship_to_site_use_id      IN     VARCHAR2,
                       p_cec_bill_to_site_use_id      IN     VARCHAR2,
                       p_cec_result                      OUT NOCOPY BOOLEAN,
                       p_action_rec_tbl                  OUT NOCOPY action_rec_tbl_type,
                       p_return_status                   OUT NOCOPY VARCHAR2,
                       p_error_buffer                    OUT NOCOPY VARCHAR2) is

  cursor loc_qualifier_csr(c_trx_date DATE) is
 	 select lookup_code
	 from ar_lookups
	 where LOOKUP_TYPE = 'ARTAXVDR_LOC_QUALIFIER'
	 and   enabled_flag = 'Y'
         and trunc(c_trx_date) between
         	trunc(start_date_active) and
         trunc(nvl(end_date_active, c_trx_date));

  l_amt_incl_tax_override VARCHAR2(1);

  l_index                 NUMBER;
  l_grp_index             NUMBER;

  l_vat_tax_id            NUMBER;
  l_tax_type              VARCHAR2(30);
  l_constraint_result     BOOLEAN;
  l_condition_result      BOOLEAN;
  l_exception_result      BOOLEAN;

  l_total_lines		  NUMBER;

  TYPE qualifier_tbl_type is TABLE of ar_lookups.lookup_code%TYPE index by binary_integer;
  l_qualifier_tbl	  qualifier_tbl_type;
  l_code_tax_type	  VARCHAR2(30);
  l_lookup_code		  ar_lookups.lookup_code%TYPE;
  l_tax_compiled_constraint VARCHAR2(2500);
  l_tax_compiled_condition  VARCHAR2(2500);
  l_tax_compiled_exception  VARCHAR2(2500);
  l_true_compiled_action    VARCHAR2(4000);
  l_false_compiled_action   VARCHAR2(4000);



BEGIN

  g_current_runtime_level := FND_LOG.G_CURRENT_RUNTIME_LEVEL;

  IF (g_level_statement >= g_current_runtime_level ) THEN
    FND_LOG.STRING(g_level_statement,
                   'ZX.PLSQL.ZX_TDS_PROCESS_CEC_PVT.evaluate_cec.BEGIN',
                   'ZX_TDS_PROCESS_CEC_PVT: evaluate_cec(+)');
  END IF;

  p_return_status := FND_API.G_RET_STS_SUCCESS;


  l_index                 := 0;
  l_grp_index             := 0;
  l_total_lines		  := 1;

  -- Initialize parameters required for processing constraint/condition set/exception set
  g_cec_ship_to_party_site_id := p_cec_ship_to_party_site_id;
  g_cec_bill_to_party_site_id := p_cec_bill_to_party_site_id;
  g_cec_ship_to_party_id := p_cec_ship_to_party_id;
  g_cec_bill_to_party_id := p_cec_bill_to_party_id;
  g_cec_poo_location_id := p_cec_poo_location_id;
  g_cec_poa_location_id := p_cec_poa_location_id;
  g_cec_trx_id := p_cec_trx_id;
  g_cec_trx_line_id := p_cec_trx_line_id;
  g_cec_ledger_id := p_cec_ledger_id;
  g_cec_internal_organization_id := p_cec_internal_organization_id;
  g_cec_so_organization_id := p_cec_so_organization_id;
  g_cec_product_org_id := p_cec_product_org_id;
  g_cec_product_id := p_cec_product_id;
  g_cec_trx_line_date := p_cec_trx_line_date;
  g_cec_trx_type_id := p_cec_trx_type_id;
  g_cec_fob_point := p_cec_fob_point;
  g_cec_ship_to_site_use_id  :=p_cec_ship_to_site_use_id;
  g_cec_bill_to_site_use_id  :=p_cec_bill_to_site_use_id;

  -- Evaluate Condition, Constraint, Exception
  -- In each call, we will have only one of condition_set_id, constraint_id or exception_set_id
  -- populated but these values will not be populated simultaneously.

  p_action_rec_tbl.delete;

  If p_constraint_id IS NOT NULL then

     l_tax_compiled_constraint := create_compiled_lines(p_constraint_id);
--   l_true_compiled_action := create_compiled_action(p_constraint_id, 'TRUE'); --Move this below to ensure one action
--   l_false_compiled_action := create_compiled_action(p_constraint_id, 'FALSE');--Move this below to ensure one action

     l_constraint_result := evaluate_cec_lines(l_tax_compiled_constraint);
     if (l_constraint_result) then
         l_true_compiled_action := create_compiled_action(p_constraint_id, 'TRUE');  --Bug 5691957
         evaluate_cec_action(l_true_compiled_action, 'CONSTRAINT');
      else
         l_false_compiled_action := create_compiled_action(p_constraint_id, 'FALSE');--Bug 5691957
         evaluate_cec_action(l_false_compiled_action, 'CONSTRAINT');
      end if;

  End If;


  If NVL(pr_do_not_use_this_group_flag, FALSE) then
     IF (g_level_statement >= g_current_runtime_level ) THEN
       FND_LOG.STRING(g_level_statement,
                      'ZX.PLSQL.ZX_TDS_PROCESS_CEC_PVT.evaluate_cec',
                      'Constraint Evaluated to False - Do not use the Condition Group');

     END IF;
     p_cec_result := false;
  End If;

  If not NVL(pr_do_not_use_this_group_flag, FALSE) then
    If p_condition_set_id is NULL and p_exception_set_id is null then
        p_cec_result := true;
    else
         -- Evaluate Condition Set
         l_condition_result := true;		-- bugfix 5572117
         if p_condition_set_id IS NOT NULL then
            l_tax_compiled_condition := create_compiled_lines(p_condition_set_id);
--          l_true_compiled_action := create_compiled_action(p_condition_set_id, 'TRUE');--Move this below to ensure one action
--          l_false_compiled_action := create_compiled_action(p_condition_set_id, 'FALSE');--Move this below to ensure one action

            l_condition_result := evaluate_cec_lines(l_tax_compiled_condition);
            if (l_condition_result) then
	      l_true_compiled_action := create_compiled_action(p_condition_set_id, 'TRUE'); --Bug 5691957
              evaluate_cec_action(l_true_compiled_action, 'CONDITION');
              p_cec_result := true;
            else
	      l_false_compiled_action := create_compiled_action(p_condition_set_id, 'FALSE'); --Bug 5691957
              evaluate_cec_action(l_false_compiled_action, 'CONDITION');
              p_cec_result := false;
            end if;

         end if;

         -- When Condition evaluates to TRUE, Evaluate Exception Set if it exists
         if p_exception_set_id IS NOT NULL and l_condition_result then
            l_tax_compiled_exception := create_compiled_lines(p_exception_set_id);
--          l_true_compiled_action := create_compiled_action(p_exception_set_id, 'TRUE');--Move this below to ensure one action
--          l_false_compiled_action := create_compiled_action(p_exception_set_id, 'FALSE');--Move this below to ensure one action

            if (evaluate_cec_lines(l_tax_compiled_exception)) then
   	       l_true_compiled_action := create_compiled_action(p_exception_set_id, 'TRUE');--Bug 5691957
               evaluate_cec_action( l_true_compiled_action, 'EXCEPTION');
                 p_cec_result := true;
            else
	       l_false_compiled_action := create_compiled_action(p_exception_set_id, 'FALSE');--Bug 5691957
               evaluate_cec_action( l_false_compiled_action, 'EXCEPTION');
               p_cec_result := false;
            end if;

         end if;
    End If;
  End If;

  p_action_rec_tbl := pr_action_rec_tbl;

  IF (g_level_statement >= g_current_runtime_level ) THEN
    FND_LOG.STRING(g_level_statement,
                   'ZX.PLSQL.ZX_TDS_PROCESS_CEC_PVT.evaluate_cec.END',
                   'ZX_TDS_PROCESS_CEC_PVT: evaluate_cec(-)');
  END IF;

exception
  when no_data_found then
    p_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

    raise;

  when others then
    p_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

    app_exception.raise_exception;

end evaluate_cec;

BEGIN
init_stats_rec_tbl;

END ZX_TDS_PROCESS_CEC_PVT;

/
