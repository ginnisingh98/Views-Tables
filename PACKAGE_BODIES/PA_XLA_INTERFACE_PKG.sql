--------------------------------------------------------
--  DDL for Package Body PA_XLA_INTERFACE_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PA_XLA_INTERFACE_PKG" AS
--  $Header: PAXLAIFB.pls 120.67.12010000.7 2010/02/25 14:16:14 jravisha ship $


    Type TypeNum      is table of number index by binary_integer;
    Type TypeDate     is table of date index by binary_integer;
    Type TypeVarChar  is table of varchar2(30) index by binary_integer;
    Type TypeVarChar1  is table of varchar2(1) index by binary_integer;
    Type TypeVarChar2  is table of varchar2(2) index by binary_integer;
    Type TypeVarChar10  is table of varchar2(10) index by binary_integer;
    Type TypeVarchar240 is table of varchar2(240) index by binary_integer;
    Type TEventInfo35 is table of varchar2(35) index by varchar2(10);
    Type TEventInfo10 is table of varchar2(10) index by varchar2(10);

    -- Global variables for bulk collecting the data for accounting event creation.
    t_event_id                TypeNum;
    t_event_type_code         TypeVarChar;
    t_gl_date                 TypeDate;

    ---

    t_entity_id               TypeNum;
    t_line_type               TypeVarChar2;
    t_line_num                TypeNum;
    t_parent_line_num         TypeNum;
    t_line_num_reversed       TypeNum;
    t_orig_dist_line_id       TypeNum;
    t_parent_dist_line_id     TypeNum;
    t_cc_dist_line_id         TypeNum;
    t_dist_line_id_reversed   TypeNum;

    t_adjusted_item           TypeNum;
    t_transferred_from_item   TypeNum;
    t_historical_flag         TypeVarChar1;
    t_transaction_source      TypeVarChar;
    t_txn_type                TypeVarChar;
    t_payment_id              TypeNum;
    t_header_id               TypeNum;
    t_distribution_id         TypeNum;
    t_reversed_flag           TypeVarChar1;
    t_event_date              TypeDate;
    t_sr5                     TypeNum;                 -- System reference 5 from CDL
    t_orig_historic           TypeVarChar1;
    t_orig_line_num           TypeNum;
    t_orig_acct_source        TypeVarChar10;
    t_orig_tsc                TypeVarChar1;            -- Transfer status code
    t_acct_source             TypeVarChar10;
    t_pts_source              TypeVarChar10;           -- Transcation source
    t_cr_ccid                 TypeNum;
    t_orig_cr_ccid            TypeNum;

    -- following need initialization
    t_tsc                     TypeVarChar1;
    t_xfer_reject             TypeVarChar;
    t_get_data                TypeVarChar10;
    t_raise_event             TypeVarChar1;
    ---

    g_org_id	              Number;                  -- Operating unit
    g_ledger_id	              Number;                  -- Ledger id of oprating unit.
    g_legal_entity_id         Number;                  -- Legal entity id of operating unit
    g_calling_module          Varchar2(30);
    g_data_set_id             Number;                  -- Cincurrent request id, budget version id etc.
    g_imp_cr_ccid             Number;                  -- Default supplier cost credit account

    g_entity_code             Varchar2(30);
    g_project_org_id          pa_projects_all.org_id%type; -- Project operating unit.

    -- static global pl/sql tables for holding event type info
    g_tab_module              TEventInfo10;
    g_tab_event_type_code     TEventInfo35;

    -- global variables for debug purpose
    g_acct_source             VARCHAR2(30);
    g_prev_txn_source         VARCHAR2(30);
    g_debug_module            VARCHAR2(100);
    g_debug_mode              Varchar2(1);
    g_debug_level3            CONSTANT NUMBER := 3;
    g_debug_level5            CONSTANT NUMBER := 5;

    Type CostCurType is REF CURSOR;

    TYPE t_source_info is table of xla_events_pub_pkg.t_event_source_info index by binary_integer;
    tt_source_info  t_source_info;
    TYPE t_security_info is table of xla_events_pub_pkg.t_security index by binary_integer;
    tt_security_info t_security_info;

    -- procedure to populate SLA's array with info required for raising
    -- accounting events
    PROCEDURE POPULATE_COST_EVENT_ARRAY(x_rows_found out nocopy number);

    -- procedure for stamping event id returned from SLA on distribution
    -- lines and update transfer status code to 'A'
    PROCEDURE TIEBACK_COST_EVENT;

    -- procedure with declarations of cursors
    -- procedure will return a cursor based in calling module
    PROCEDURE OPEN_COST_CUR(p_cost_cursor     IN OUT NOCOPY CostCurType,
                            p_calling_module  IN VARCHAR2);

-- ---------------------------------------------------------------------------------+
-- ENCUMBRANCE RELATED CHANGES (Initalization): Start

    -- 1.0: Forward Declarations

    -- This procedure will derive the budget version to reverse (if any)
    -- It will also derive budget status code of the current budget version

    PROCEDURE GET_BVID_TO_REVERSE(p_budget_version_id       IN NUMBER,
   			          p_curr_budget_status_code OUT NOCOPY VARCHAR2,
                                  p_old_budget_version_id OUT NOCOPY NUMBER);

    -- This procedure will reset the event id information on the current budget
    -- and the budget being reversed

    PROCEDURE RESET_EVENT_ID (p_budget_version_id       IN NUMBER,
			      p_curr_budget_status_code IN VARCHAR2,
			      p_old_budget_version_id   IN NUMBER);

   -- This procedure will call XLA public API to delete draft
   -- events (if they were established earlier), called from "Reset_event_id"
   -- for budgets and "populate_enc_event_array" for funds check.

   PROCEDURE DELETE_XLA_EVENT_DATA(p_data_set_id1      IN NUMBER,
                                   p_data_set_id2      IN NUMBER,
                                   p_calling_module    IN VARCHAR2,
                                   p_events_to_delete  IN OUT NOCOPY VARCHAR2);

   -- This procedure builds the pl/sql array for event creation

   PROCEDURE POPULATE_ENC_EVENT_ARRAY;

   -- This procedure will populate xla_events_gt table

   --PROCEDURE POPULATE_ENC_EVENTS_GT (p_Source_Id_Int1    IN TypeNum,
   --                                  p_event_type_code   IN TypeVarChar,
   --                                  p_event_date        IN TypeDate,
   --                                  p_calling_module    IN Varchar2);

   -- This procedure will execute during commitment tieback processing

   PROCEDURE TIEBACK_ENC_EVENT;

  -- This procedure will execute during budget tieback processing

  PROCEDURE TIEBACK_BUDGET_EVENT;

    -- 2:0: Global variables
       g_event_type_code         xla_events.event_type_code%type;
       g_bvid_to_reverse         pa_budget_versions.budget_version_id%type;
       g_enc_create_events_flag  Varchar2(1);
       l_events_to_delete        Varchar2(1);

       t_transaction_date TypeDate;
       t_source_event_id  TypeNum;
       t_Source_Id_Int_1  TypeNum;
       t_Source_Id_Int_2  TypeNum;
       t_Source_Id_Int_3  TypeNum;
       t_Source_Id_Int_4  TypeNum;
       t_source_id_char_1 TypeVarChar;
       t_source_id_char_2 TypeVarChar;
       t_source_id_char_3 TypeVarChar;
       t_source_id_char_4 TypeVarChar;
       t_source_application_id TypeNum;
       t_application_id        TypeNum;
       t_legal_entity_id       TypeNum;
       t_ledger_id             TypeNum;
       t_security_org_id       TypeNum;
       t_entity_type_code      TypeVarChar;
       t_transaction_number    TypeVarChar240;
       t_bc_rev_event_id       TypeNum;

       TYPE t_reference_info is table of xla_events_pub_pkg.t_event_reference_info index by binary_integer;
       tt_reference_info  t_reference_info;

       t_reference_num_1  TypeVarChar;

-- ENCUMBRANCE RELATED CHANGES (Initalization): End

-- ---------------------------------------------------------------------------------+

FUNCTION GET_SOURCE(p_transaction_source varchar2,
                    p_payment_id number)
         return varchar2 IS
l_acct_source varchar2(30);
BEGIN

  if p_transaction_source is null then
     return 'PA';
  else
     select decode(predefined_flag,
                   'N', decode(posted_flag,
		               'N', 'PA',
			       'EXT'),
                   acct_source_code)
       into l_acct_source
       from pa_transaction_sources
      where transaction_source = p_transaction_source;

     if l_acct_source like 'AP%' then
        if p_payment_id is not null then
           l_acct_source := 'AP_PAY';
        end if;
        /* Bug 5374040 if p_transaction_source = 'AP DISCOUNTS' then
           l_acct_source := 'AP_INV';
        end if;
	*/
     end if;

     return l_acct_source;
  end if;
END GET_SOURCE;

-- procedure to initialize global variables and set debug context
PROCEDURE INIT(p_calling_module varchar2,
               p_data_set_id    number  ) IS

BEGIN
     g_debug_module := 'pa.plsql.PA_XLA_INTERFACE_PKG';
     g_debug_mode  := NVL(FND_PROFILE.value('PA_DEBUG_MODE'),'N');

     IF g_debug_mode = 'Y' THEN
	   pa_debug.set_curr_function(p_function   => 'create_events',
	                              p_debug_mode => g_debug_mode );
     END IF;

     IF g_debug_mode = 'Y' THEN
        pa_debug.g_err_stage:= 'Create Events API Start';
        pa_debug.write('create_events ' || g_debug_module, pa_debug.g_err_stage, g_debug_level5);
     END IF;

     select org_id, set_of_books_id, def_supplier_cost_cr_ccid
       into g_org_id, g_ledger_id, g_imp_cr_ccid
       from pa_implementations ;

     select to_number(org_information2)
       into g_legal_entity_id
       from hr_organization_information
      where organization_id = g_org_id
        and org_information_context = 'Operating Unit Information';

     g_calling_module := p_calling_module;
     g_data_set_id    := p_data_set_id;

     IF g_debug_mode = 'Y' THEN
        pa_debug.g_err_stage:= 'Parameter List: Calling Module: ' || g_calling_module || ', Dataset ID: ' ||
                                g_data_set_id;
        pa_debug.write('create_events ' || g_debug_module, pa_debug.g_err_stage, g_debug_level5);
     END IF;

     IF g_calling_module in ('USG', 'PJ', 'INV', 'WIP', 'LAB', 'SUPP', 'BTC', 'TBC', 'CC', 'BL', 'PC', 'Cost') THEN
        g_entity_code := 'EXPENDITURES';
     END IF;

     -- ----------------------------------------------------------------------- +
     -- Encumbrance changes  start.........................
     -- ----------------------------------------------------------------------- +
     -- If g_calling_module is 'CC_BUDGET' or 'CC_BUDGET_YEAR_END' , i.e. a CC
     -- budget then we will need to get the secondary ledger id
     -- When CC integration is carried out ..add code here ...

     -- Derive entity code for encumbrances ..
       IF g_calling_module in ('COST_BUDGET','CC_BUDGET','REVENUE_BUDGET',
                               'COST_BUDGET_YEAR_END','CC_BUDGET_YEAR_END') THEN
          g_entity_code := 'BUDGETS';

       END IF;
     -- ----------------------------------------------------------------------- +
     -- Encumbrance changes  end.........................
     -- ----------------------------------------------------------------------- +

     -- Build array of possible calling modules based on system linkage
     -- for Cost and by line type for Cross Charge.
     g_tab_module('ST')  := 'LAB';
     g_tab_module('OT')  := 'LAB';
     g_tab_module('USG') := 'USG';
     g_tab_module('INV') := 'INV';
     g_tab_module('PJ')  := 'PJ' ;
     g_tab_module('WIP') := 'WIP';
     g_tab_module('BTC') := 'BTC';
     g_tab_module('TBC') := 'TBC';
     g_tab_module('BL')  := 'BL' ;
     g_tab_module('PC')  := 'PC' ;
     g_tab_module('ER')  := 'ER' ;
     g_tab_module('VI')  := 'VI' ;

     -- Build array of event type codes based on calling modules possible
     g_tab_event_type_code('LAB')  := 'LABOR_COST_DIST';
     g_tab_event_type_code('USG')  := 'USG_COST_DIST';
     g_tab_event_type_code('INV')  := 'INVENTORY_COST_DIST';
     g_tab_event_type_code('PJ')   := 'MISC_COST_DIST';
     g_tab_event_type_code('WIP')  := 'WIP_COST_DIST';
     g_tab_event_type_code('BTC')  := 'BURDEN_COST_DIST';
     g_tab_event_type_code('TBC')  := 'TOT_BURDENED_COST_DIST';
     g_tab_event_type_code('BL')   := 'BL_DISTRIBUTION';
     g_tab_event_type_code('PC')   := 'PRVDR_RECVR_RECLASS';
     g_tab_event_type_code('ER')   := 'EXP_COST_DIST';
     g_tab_event_type_code('VI')   := 'SUPP_COST_DIST';

END INIT;

-- This is the main procedure which will be called by "Create Events for Cost/
-- Cross Charge" and cost side streamline processes for interface to GL to
-- raise accounting events in SLA and update the event id on the distributions.
-- Transfer status code is updated to 'A' if events are successfully raised.

PROCEDURE CREATE_EVENTS(p_calling_module  IN  VARCHAR2,
                        p_data_set_id     IN  NUMBER,
                        x_result_code    OUT NOCOPY VARCHAR2) is

l_application_id NUMBER;
l_rows_found     NUMBER;
l_event_status_code xla_events.event_status_code%TYPE;

BEGIN

  IF g_debug_mode = 'Y' THEN
     pa_debug.g_err_stage:= 'Create Events: Start';
     pa_debug.write('create_events ' || g_debug_module, pa_debug.g_err_stage, g_debug_level5);
  END IF;

  -- initialize global variables. check debug mode, get org_id
  -- and ledger_id. build pl/sql table of event type info.
  init(p_calling_module, p_data_set_id);

  l_application_id := 275;
  l_event_status_code := xla_events_pub_pkg.c_event_unprocessed;



 IF (g_entity_code = 'BUDGETS' or p_calling_module = 'FUNDS_CHECK') then
    -- -------------------------------------------------------------+
    -- ENCUMBRANCE ACCOUNTING
    -- -------------------------------------------------------------+

     -- -------------------------------------------------------------+
     -- E1. Select data for processing
     IF g_debug_mode = 'Y' THEN
        pa_debug.g_err_stage:= 'Create Events: Calling procedure Populate_enc_event_array';
        pa_debug.write('create_events ' || g_debug_module, pa_debug.g_err_stage, g_debug_level5);
     END IF;
     -- -------------------------------------------------------------+

      POPULATE_ENC_EVENT_ARRAY;

      -- -------------------------------------------------------------+
      -- E2. Check if there are events to be RAISED ..
         IF g_debug_mode = 'Y' THEN
            pa_debug.g_err_stage:= 'Create Events: Check if events exist for processing ..';
            pa_debug.write('create_events ' || g_debug_module,pa_debug.g_err_stage, g_debug_level5);
         END IF;
      -- -------------------------------------------------------------+
      If NOT t_event_date.EXISTS(1) then

         IF g_debug_mode = 'Y' THEN
             pa_debug.g_err_stage:= 'Create Events: No event exist for processing ..';
             pa_debug.write('create_events ' || g_debug_module,pa_debug.g_err_stage, g_debug_level5);
         END IF;

         goto noprocessing;

       End if;

      -- -------------------------------------------------------------+
      -- E3. Event Creation ..
      IF g_debug_mode = 'Y' THEN
         pa_debug.g_err_stage:= 'Create Events: Event(s) exist for processing ..';
         pa_debug.write('create_events ' || g_debug_module,pa_debug.g_err_stage, g_debug_level5);

         pa_debug.g_err_stage:= 'Create Events: FC: Calling xla_events_pkg.create_event';
         pa_debug.write('create_events ' || g_debug_module,pa_debug.g_err_stage, g_debug_level5);
      END IF;
      -- -------------------------------------------------------------+

        FOR i in t_event_date.FIRST..t_event_date.LAST LOOP
            t_event_id(i) := xla_events_pub_pkg.create_event
                             (p_event_source_info        => tt_source_info(i)
                             ,p_event_type_code          => t_event_type_code(i)
                             ,p_event_date               => t_event_date(i)
                             ,p_event_status_code        => l_event_status_code
                             ,p_event_number             => NULL
                             ,p_transaction_date         => t_transaction_date(i)
                             ,p_reference_info           => NULL -- tt_reference_info(i)
                             ,p_valuation_method         => NULL
           		     ,p_security_context         => tt_security_info(i)
                             ,p_budgetary_control_flag   => 'Y');

        END LOOP;

        -- -------------------------------------------------------------+
        -- E4. Stamp event_id on source table (pa_budget_lines for
        --     Budgets, pa_bc_packets for FC)
        IF g_debug_mode = 'Y' THEN
         pa_debug.g_err_stage:= 'Create Events: Tieback Processing';
         pa_debug.write('create_events ' || g_debug_module,pa_debug.g_err_stage, g_debug_level5);
        END IF;
        -- -------------------------------------------------------------+
        IF g_entity_code = 'BUDGETS' then

           TIEBACK_BUDGET_EVENT;

       ELSIF  p_calling_module = 'FUNDS_CHECK' then

           TIEBACK_ENC_EVENT;

       END IF;

       -- -------------------------------------------------------------+
       -- E5. Populate psa_bc_xla_events_gt with the new event_id's ...
        IF g_debug_mode = 'Y' THEN
         pa_debug.g_err_stage:= 'Create Events: FC: Populate psa_bc_xla_events_gt';
         pa_debug.write('create_events ' || g_debug_module,pa_debug.g_err_stage, g_debug_level5);

        -- Events that are being populated into psa_bc_xla_events_gt
         for x in t_event_id.FIRST..t_event_id.LAST loop
              pa_debug.write('create_events ' || g_debug_module,'Event id is:'||t_event_id(x), g_debug_level5);
         end loop;

        END IF;
        -- -------------------------------------------------------------+
        forall i in t_event_id.FIRST..t_event_id.LAST
           Insert into psa_bc_xla_events_gt(event_id,result_code)
           values(t_event_id(i),'XLA_ERROR');

        -- -------------------------------------------------------------+
        -- E6. Delete pl/sql table ..
        IF g_debug_mode = 'Y' THEN
         pa_debug.g_err_stage:= 'Create Events: Delete PL/sql table';
         pa_debug.write('create_events ' || g_debug_module,pa_debug.g_err_stage, g_debug_level5);
        END IF;
        -- -------------------------------------------------------------+
        tt_source_info.DELETE;
        t_event_type_code.DELETE;
        t_event_date.DELETE;
        t_transaction_date.DELETE;
        tt_security_info.DELETE;
        t_event_id.DELETE;
        t_source_id_int_1.DELETE;

 Else
    -- -------------------------------------------------------------+
    -- Create ACTUALs Accounting events
    -- -------------------------------------------------------------+



     IF g_debug_mode = 'Y' THEN
        pa_debug.g_err_stage:= 'Calling procedure populate_cost_event_array';
        pa_debug.write('create_events ' || g_debug_module, pa_debug.g_err_stage, g_debug_level5);
     END IF;

     -- derive the entity and event type details.
     -- populate SLA's array structure with required parameters



     populate_cost_event_array(l_rows_found);



     IF l_rows_found = 0 THEN

        goto noprocessing;
     END IF;

     IF g_debug_mode = 'Y' THEN
        pa_debug.g_err_stage:= 'Calling xla_events_pub_pkg to raise events';
        pa_debug.write('create_events ' || g_debug_module, pa_debug.g_err_stage, g_debug_level5);
     END IF;

     FOR i in t_entity_id.first..t_entity_id.last LOOP
       IF t_raise_event(i) = 'Y' THEN
             t_event_id(i) :=  xla_events_pub_pkg.create_event
                              (p_event_source_info  => tt_source_info(i)
                              ,p_event_type_code    => t_event_type_code(i)
                              ,p_event_date         => t_event_date(i)
                              ,p_event_status_code  => 'U'
                              ,p_event_number       => NULL
                              ,p_transaction_date   => NULL
                              ,p_reference_info     => NULL
                              ,p_valuation_method   => NULL
                              ,p_security_context   => tt_security_info(i));
       END IF;
     END LOOP;

     -- stamp event_id on distribution lines and update transfer status code
     tieback_cost_event;

     -- clear the pl/sql tables
     t_entity_id.delete;
     t_event_date.delete;
     t_txn_type.delete;
     t_event_id.delete;
     t_event_type_code.delete;
     g_tab_module.delete;
     g_tab_event_type_code.delete;

     IF g_debug_mode = 'Y' THEN
        pa_debug.g_err_stage:= 'Create Events API..End';
        pa_debug.write('create_events ' || g_debug_module,
                        pa_debug.g_err_stage, g_debug_level5);
     END IF;

End If; -- ENCUMBRANCE V/S ACTUAL ACCOUNTING Check

     x_result_code := 'Success';
<<NOPROCESSING>>
    x_result_code := 'Success';
    null;
END CREATE_EVENTS;

 -- procedure with declarations of cursors
 -- procedure will return a cursor based in calling module
PROCEDURE OPEN_COST_CUR(p_cost_cursor     IN OUT NOCOPY CostCurType,
                        p_calling_module  IN     VARCHAR2) IS
  BEGIN
    IF g_calling_module in ('CC', 'BL', 'PC') THEN
       open p_cost_cursor for
       select expenditure_item_id,
              cc_dist_line_id,
              adjusted_expenditure_item_id,
              transferred_from_exp_item_id,
              historical_flag,
              parent_dist_line_id,
              dist_line_id_reversed,
              line_type,
              gl_date,
              orig_historic,
              orig_dist_line_id,
              orig_acct_source
         from (
               select cdl.expenditure_item_id,
                      cdl.cc_dist_line_id cc_dist_line_id,
                      exp.adjusted_expenditure_item_id,
                      exp.transferred_from_exp_item_id,
                      NVL(exp.historical_flag, 'Y') historical_flag,
                      NULL parent_dist_line_id,
                      NULL dist_line_id_reversed,
                      cdl.line_type,
                      trunc(cdl.gl_date) gl_date,
                      NULL  orig_historic,
                      NULL orig_dist_line_id,
                      NULL orig_acct_source
                 from pa_cc_dist_lines_all cdl,
                      pa_expenditure_items_all exp
                where exp.expenditure_item_id = cdl.expenditure_item_id
                  and cdl.request_id = g_data_set_id
                  and cdl.transfer_status_code = 'X'
                  and cdl.dist_line_id_reversed is null
                  and exp.adjusted_expenditure_item_id is null
               UNION ALL
               select cdl.expenditure_item_id,
                      cdl.cc_dist_line_id cc_dist_line_id,
                      exp.adjusted_expenditure_item_id,
                      exp.transferred_from_exp_item_id,
                      NVL(exp.historical_flag, 'Y') historical_flag,
                      cdl.dist_line_id_reversed parent_dist_line_id,
                      NULL dist_line_id_reversed,
                      cdl.line_type line_type,
                      trunc(cdl.gl_date) gl_date,
                      nvl(pe.historical_flag, 'Y')  orig_historic,
                      cd.cc_dist_line_id orig_dist_line_id,
                      cd.acct_source_code orig_acct_source
                 from pa_cc_dist_lines_all cdl,
                      pa_expenditure_items_all exp,
                      pa_expenditure_items_all pe,
                      pa_cc_dist_lines_all cd
                where exp.expenditure_item_id = cdl.expenditure_item_id
                  and cdl.request_id = g_data_set_id
                  and cdl.transfer_status_code = 'X'
                  and exp.adjusted_expenditure_item_id is not null
                  and exp.adjusted_expenditure_item_id = pe.expenditure_item_id
                  and pe.expenditure_item_id = cd.expenditure_item_id
                  and cdl.dist_line_id_reversed = cd.cc_dist_line_id
                UNION ALL
               select cdl.expenditure_item_id,
                      cdl.cc_dist_line_id cc_dist_line_id,
                      exp.adjusted_expenditure_item_id,
                      exp.transferred_from_exp_item_id,
                      NVL(exp.historical_flag, 'Y') historical_flag,
                      NULL parent_dist_id,
                      cdl.dist_line_id_reversed dist_line_id_reversed,
                      cdl.line_type line_type,
                      trunc(cdl.gl_date) gl_date,
                      NULL orig_historic,
                      cd.cc_dist_line_id orig_dist_line_id,
                      cd.acct_source_code orig_acct_source
                 from pa_cc_dist_lines_all cdl,
                      pa_expenditure_items_all exp,
                      pa_cc_dist_lines_all cd
                where exp.expenditure_item_id = cdl.expenditure_item_id
                  and cdl.request_id = g_data_set_id
                  and cdl.transfer_status_code = 'X'
                  and cdl.dist_line_id_reversed is not null
                  and cdl.expenditure_item_id = cd.expenditure_item_id
                  and cdl.dist_line_id_reversed = cd.cc_dist_line_id)
          order by expenditure_item_id, cc_dist_line_id;
  ELSIF  g_calling_module in ('Cost', 'LAB', 'SUPP', 'USG', 'BTC',
                               'PJ', 'WIP', 'INV', 'TBC') THEN
       open p_cost_cursor for
       select expenditure_item_id,
              line_num,
              adjusted_expenditure_item_id,
              transferred_from_exp_item_id,
              transaction_source,
              historical_flag,
              parent_line_num,
              system_linkage_function,
              line_num_reversed,
              line_type,
              gl_date,
              document_payment_id,
              document_header_id,
              document_distribution_id,
              orig_historic,
              orig_line_num,
              orig_acct_source,
              orig_tsc,
              system_reference5,
              cr_code_combination_id,
              pts_source,
              orig_cr_ccid
         from (
               select cdl.expenditure_item_id,
                      cdl.line_num,
                      exp.adjusted_expenditure_item_id,
                      exp.transferred_from_exp_item_id,
                      exp.transaction_source,
                      NVL(exp.historical_flag, 'Y') historical_flag,
                             cdl.parent_line_num,
                      decode(cdl.line_type,
                             'C', 'TBC',
                             'D', 'TBC',
                             exp.system_linkage_function) system_linkage_function,
                      cdl.line_num_reversed,
                      decode(cdl.line_type, 'R', 'R', 'B') line_type,
                      trunc(cdl.gl_date) gl_date,
                      exp.document_payment_id,
                      exp.document_header_id,
                      exp.document_distribution_id,
                      NVL(exp.historical_flag, 'Y') orig_historic,
                      NULL orig_line_num,
                      NULL orig_acct_source,
                      NULL orig_tsc,
                      cdl.system_reference5,
                      cdl.cr_code_combination_id,
                      decode(pts.predefined_flag,
                             NULL, 'PA',
                             'N', decode(pts.posted_flag,
					'N', 'PA', 'EXT'),
                             pts.acct_source_code) pts_source,
                      cdl.cr_code_combination_id orig_cr_ccid
                 from pa_cost_distribution_lines_all cdl,
                      pa_expenditure_items_all exp,
                      pa_transaction_sources pts
                where exp.expenditure_item_id = cdl.expenditure_item_id
                  and exp.transaction_source = pts.transaction_source(+)
                  and cdl.request_id = g_data_set_id
                  and cdl.transfer_status_code = 'X'
		          and cdl.line_num_reversed is null
		          and ( exp.adjusted_expenditure_item_id is null or (     cdl.parent_line_num is null
									      and NVL(exp.historical_flag, 'Y') = 'Y'
									     )
			      )
               UNION ALL
               select cdl.expenditure_item_id,
                      cdl.line_num,
                      exp.adjusted_expenditure_item_id,
                      exp.transferred_from_exp_item_id,
                      exp.transaction_source,
                      NVL(exp.historical_flag, 'Y') historical_flag,
                      cdl.parent_line_num,
                      decode(cdl.line_type,
                             'C', 'TBC',
                             'D', 'TBC',
                             exp.system_linkage_function) system_linkage_function,
                      cdl.line_num_reversed,
                      decode(cdl.line_type, 'R', 'R', 'B') line_type,
                      trunc(cdl.gl_date) gl_date,
                      exp.document_payment_id ,
                      exp.document_header_id ,
                      exp.document_distribution_id ,
                      nvl(pe.historical_flag, 'Y')  orig_historic,
                      cd.line_num orig_line_num,
                      cd.acct_source_code orig_acct_source,
                      cd.transfer_status_code orig_tsc,
                      cdl.system_reference5,
                      cdl.cr_code_combination_id,
                      decode(pts.predefined_flag,
                             NULL, 'PA',
                             'N', decode(pts.posted_flag,
				         'N', 'PA',
					 'EXT'),
                             pts.acct_source_code) pts_source,
                      cd.cr_code_combination_id orig_cr_ccid
                 from pa_cost_distribution_lines_all cdl,
                      pa_expenditure_items_all exp,
                      pa_expenditure_items_all pe,
                      pa_cost_distribution_lines_all cd,
                      pa_transaction_sources pts
                where exp.expenditure_item_id = cdl.expenditure_item_id
                  and pe.transaction_source = pts.transaction_source(+)
                  and cdl.request_id = g_data_set_id
                  and cdl.transfer_status_code = 'X'
                  and exp.adjusted_expenditure_item_id is not null
                  and exp.adjusted_expenditure_item_id = pe.expenditure_item_id
                  and pe.expenditure_item_id = cd.expenditure_item_id
                  and cdl.parent_line_num = cd.line_num
               UNION ALL
               select cdl.expenditure_item_id,
                      cdl.line_num,
                      exp.adjusted_expenditure_item_id,
                      exp.transferred_from_exp_item_id,
                      exp.transaction_source,
                      NVL(exp.historical_flag, 'Y') historical_flag,
                      cdl.parent_line_num,
                      decode(cdl.line_type,
                             'C', 'TBC',
                             'D', 'TBC',
                             exp.system_linkage_function) system_linkage_function,
                      cdl.line_num_reversed,
                      decode(cdl.line_type, 'R', 'R', 'B') line_type,
                      trunc(cdl.gl_date) gl_date,
                      exp.document_payment_id ,
                      exp.document_header_id ,
                      exp.document_distribution_id ,
                      NULL orig_historic,
                      cd.line_num orig_line_num,
                      cd.acct_source_code orig_acct_source,
                      cd.transfer_status_code orig_tsc,
                      cdl.system_reference5,
                      cdl.cr_code_combination_id,
                      decode(pts.predefined_flag,
                             NULL, 'PA',
                             'N', decode(pts.posted_flag,
					'N', 'PA',
					'EXT'),
                             pts.acct_source_code) pts_source,
                      cd.cr_code_combination_id orig_cr_ccid
                 from pa_cost_distribution_lines_all cdl,
                      pa_expenditure_items_all exp,
                      pa_cost_distribution_lines_all cd,
                      pa_transaction_sources pts
                where exp.expenditure_item_id = cdl.expenditure_item_id
                  and exp.transaction_source = pts.transaction_source(+)
                  and cdl.request_id = g_data_set_id
                  and cdl.transfer_status_code = 'X'
                  and cdl.line_num_reversed is not null
                  and cdl.expenditure_item_id = cd.expenditure_item_id
                  and cdl.line_num_reversed = cd.line_num)
          order by expenditure_item_id, line_num;
  END IF;
END OPEN_COST_CUR;

 -- procedure to populate SLA's array with info required for raising
 -- accounting events

 PROCEDURE POPULATE_COST_EVENT_ARRAY(x_rows_found out nocopy number) is
  l_cursor              CostCurType;
  l_application_id      NUMBER;
  l_event_status_code   VARCHAR2(1);
  l_security_id_char_1  VARCHAR2(30);
  l_acct_source         varchar2(10);
  t_security_id_char_1  TypeVarChar;
  l_no_match            varchar2(1);
  l_cr_ccid             number;
  l_dr_slid             number;
  l_transfer_status_code varchar2(1);
  l_transaction_source   varchar2(30);

 BEGIN

   l_application_id    := 275;
   l_event_status_code := xla_events_pub_pkg.C_EVENT_UNPROCESSED;

   t_tsc := t_tsc;
   t_cr_ccid := t_cr_ccid;
   t_sr5 := t_sr5;
   t_raise_event := t_raise_event;

   -- Populate
   populate_acct_source;

   x_rows_found := t_entity_id.count;

   if x_rows_found = 0 then
      goto no_rows_found;
   end if;

   FOR i in t_entity_id.first..t_entity_id.last LOOP
     l_no_match := 'Y';
     if t_raise_event(i) is null and t_tsc(i) <> 'G' THEN
        FOR k in i..t_entity_id.last LOOP
           IF t_entity_id(k) = t_entity_id(i) AND
              t_line_type(k) = t_line_type(i) AND
              t_event_date(k)   = t_event_date(i) AND
              t_tsc(k) <> 'G' and i <> k THEN
                 t_raise_event(i) := 'Y';
                 t_raise_event(k) := 'N';
                 l_no_match := 'N';
           ELSE
              l_no_match := 'Y';
           END IF;
        END LOOP;
     END IF;
     IF t_tsc(i) <> 'G' AND l_no_match = 'Y' AND t_raise_event(i) is null THEN
        t_raise_event(i) := 'Y';
     END IF;
   END LOOP;

   FOR i in t_entity_id.first..t_entity_id.last LOOP
     IF t_raise_event(i) = 'Y' THEN

        IF g_calling_module = 'CC' THEN
           t_event_type_code(i) :=
             g_tab_event_type_code(g_tab_module(t_line_type(i)));
        ELSIF g_calling_module in ('Cost', 'LAB', 'CC', 'SUPP') THEN
             t_event_type_code(i) :=
               g_tab_event_type_code(g_tab_module(t_txn_type(i)));
        ELSE
           t_event_type_code(i) := g_tab_event_type_code(g_calling_module);
        END IF;
        IF t_adjusted_item(i) is not null THEN      -- change for reversing items.
           t_event_type_code(i) := t_event_type_code(i) ||'_ADJ';
        END IF;


	tt_source_info(i).source_application_id := 275;
        tt_source_info(i).application_id := 275;
        tt_source_info(i).ledger_id := g_ledger_id;
        tt_source_info(i).legal_entity_id := g_legal_entity_id;
        tt_source_info(i).entity_type_code := 'EXPENDITURES';
        tt_source_info(i).transaction_number := t_entity_id(i);
        tt_source_info(i).source_id_int_1 := t_entity_id(i);
        tt_security_info(i).security_id_int_1 := g_org_id;
     END IF;
   END LOOP;

  <<NO_ROWS_FOUND>>
     null;
END POPULATE_COST_EVENT_ARRAY;

 -- procedure for stamping event id returned from SLA on distribution
 -- lines and update transfer status code to 'A'
PROCEDURE TIEBACK_COST_EVENT IS
BEGIN
  FOR i in t_entity_id.first..t_entity_id.last LOOP
    IF t_event_id(i) is not null then
       FOR k in t_entity_id.first..t_entity_id.last LOOP
           IF t_entity_id(k) = t_entity_id(i) AND
              t_line_type(k) = t_line_type(i) AND
              t_event_date(k)   = t_event_date(i) AND
              t_tsc(k) <> 'G' THEN
                  t_event_id(k) := t_event_id(i);
           END IF;
       END LOOP;
    END IF;
  END LOOP;

  IF g_calling_module in ('Cost', 'LAB', 'USG', 'INV', 'WIP',
                        'BTC', 'TBC', 'PJ', 'SUPP') THEN

     FORALL i in t_entity_id.first..t_entity_id.last
         update pa_cost_distribution_lines_all
            set acct_event_id = decode(t_tsc(i), 'R', NULL, t_event_id(i)),
                acct_source_code = decode(t_tsc(i), 'R', NULL, t_acct_source(i)),
                transfer_status_code = decode(t_tsc(i), 'G', 'G', 'R', 'R', 'A'),
                transfer_rejection_reason = decode(t_tsc(i),
                                              'R',( SELECT meaning --bug 6033420
                                                    FROM pa_lookups
                                                    WHERE lookup_code   = 'PA_XLA_NOT_FINAL_ACCT'
                                                    AND lookup_type     = 'TRANSFER REJECTION REASON'),
                                              transfer_rejection_reason),
                transferred_date = trunc(sysdate),
                system_reference5 = decode(t_tsc(i), 'R', system_reference5,
		                           nvl(t_sr5(i), system_reference5)),
                cr_code_combination_id = decode(t_tsc(i), 'R', cr_code_combination_id,
		                                nvl(t_cr_ccid(i), cr_code_combination_id))
          where expenditure_item_id = t_entity_id(i)
            and transfer_status_code = 'X'
            and TRUNC(gl_date) = t_event_date(i) --Bug 5081153
            and line_num = t_line_num(i)
            and line_type = decode(t_line_type(i), 'B', line_type, t_line_type(i))
            and request_id = g_data_set_id;
  ELSIF g_calling_module in ('CC', 'PC', 'BL') THEN
      FORALL i in t_entity_id.first..t_entity_id.last
         update pa_cc_dist_lines_all
            set acct_event_id = t_event_id(i),
                acct_source_code = t_acct_source(i),
                transferred_date = trunc(sysdate),
                transfer_status_code = decode(t_tsc(i), 'G', 'G', 'A')
          where expenditure_item_id = t_entity_id(i)
            and cc_dist_line_id = t_cc_dist_line_id(i)
            and transfer_status_code = 'X'
            and request_id = g_data_set_id
            and line_type = t_line_type(i)
            and gl_date = t_event_date(i);
  END IF;

   -- this is to handle cases where lines are not picked up by create events
   -- because of some data inconsistency.

   if g_calling_module in ('Cost', 'LAB', 'USG', 'INV', 'WIP', 'BTC', 'TBC',
                           'PJ', 'SUPP') then
      update pa_cost_distribution_lines_all
         set transfer_status_code = 'R',
	     transfer_rejection_reason = 'Create Events API did not pick this line'
       where transfer_status_code = 'X'
         and request_id = g_data_set_id;
  elsif g_calling_module in ('CC', 'PC', 'BL') then
      update pa_cc_dist_lines_all
         set transfer_status_code = 'R',
	     transfer_rejection_code = 'Create Events API did not pick this line'
       where transfer_status_code = 'X'
         and request_id = g_data_set_id;
   end if;

end tieback_cost_event;

PROCEDURE POPULATE_ACCT_SOURCE IS

x_cr_ccid           number;
x_dr_sl_id          number;
l_cursor            CostCurType;
l_source_table      varchar2(3);
l_check_parent_acct boolean := FALSE;
l_ccid              number;
l_application_id    number;
l_distribution_id_1    number;
l_distribution_id_2    number;
l_distribution_type    varchar2(30);

FUNCTION check_plsql_table(p_orig_dist_line_id number)
 return varchar2 IS
l_acct_source varchar2(10);
BEGIN
   l_acct_source := NULL;
   for j in t_entity_id.first..t_entity_id.last loop
     if t_cc_dist_line_id(j) = p_orig_dist_line_id then
       -- l_acct_source := t_acct_source(j); -- bug8754630
          l_acct_source := t_orig_acct_source(j);
        exit;
     end if;
   end loop;
   return l_acct_source;
END CHECK_PLSQL_TABLE;

FUNCTION CHECK_PLSQL_TABLE(p_item number, p_line number)
 return varchar2 IS
l_acct_source varchar2(10);
BEGIN
   l_acct_source := NULL;
   for j in t_entity_id.first..t_entity_id.last loop
     if t_entity_id(j) = p_item and
        t_line_num(j) = p_line then
        --l_acct_source := t_acct_source(j); -- bug8754630
          l_acct_source := t_orig_acct_source(j);
        exit;
     end if;
   end loop;
   return l_acct_source;
END CHECK_PLSQL_TABLE;

BEGIN
   t_event_type_code := t_event_type_code;

   open_cost_cur(l_cursor, g_calling_module);

   if g_calling_module in ('Cost', 'LAB', 'SUPP', 'USG', 'BTC',
                               'PJ', 'WIP', 'INV', 'TBC') then
        fetch l_cursor bulk collect into
		t_entity_id,
		t_line_num,
                t_adjusted_item,
		t_transferred_from_item,
		t_transaction_source,
                t_historical_flag, t_parent_line_num, t_txn_type,
              t_line_num_reversed, t_line_type, t_event_date, t_payment_id,
              t_header_id, t_distribution_id,
              t_orig_historic, t_orig_line_num,
              t_orig_acct_source, t_orig_tsc, t_sr5, t_cr_ccid,
              t_pts_source, t_orig_cr_ccid;

   elsif g_calling_module in ('CC', 'BL', 'PC') then
        fetch l_cursor bulk collect into t_entity_id, t_cc_dist_line_id,
              t_adjusted_item, t_transferred_from_item, t_historical_flag,
              t_parent_dist_line_id, t_dist_line_id_reversed, t_line_type,
              t_event_date, t_orig_historic, t_orig_dist_line_id,
              t_orig_acct_source;
   end if;

   close l_cursor;

   if t_entity_id.count = 0 then
      return;
   end if;

if g_calling_module in ('CC', 'BL', 'PC') then
   for i in t_entity_id.first..t_entity_id.last loop
      t_tsc(i)             := 'A';
      t_raise_event(i)     := NULL;
      t_event_id(i)        := NULL;
      t_event_type_code(i) := NULL;

      if t_adjusted_item(i) is not null then
         t_acct_source(i) := nvl(t_orig_acct_source(i),
                                 check_plsql_table(t_parent_dist_line_id(i)));
         if t_acct_source(i) is null then
            t_acct_source(i) := 'UPG';
         end if;
      elsif t_dist_line_id_reversed(i) is null then
         t_acct_source(i):= 'PA';
      elsif t_dist_line_id_reversed(i) is not null then
         t_acct_source(i) := nvl(t_orig_acct_source(i),
                                 check_plsql_table(t_dist_line_id_reversed(i)));
         if t_acct_source(i) is null then
            t_acct_source(i) := 'UPG';
         end if;
      end if;
   end loop;
elsif g_calling_module in ('Cost', 'LAB', 'SUPP', 'USG', 'BTC',
                               'PJ', 'WIP', 'INV', 'TBC') then

   for i in t_entity_id.first..t_entity_id.last loop
      t_get_data(i)        := NULL;
      t_tsc(i)             := 'A';
      t_raise_event(i)     := NULL;
      t_event_id(i)        := NULL;
      t_event_type_code(i) := NULL;
      --t_original_accted(i) := NULL;

--
-- this is applicable to new, transferred and adjusting lines.
-- for new item, acct source is whatever is selected



   if t_line_num(i) = 1 then



      if t_transferred_from_item(i) is null and
         t_adjusted_item(i) is null then

            t_acct_source(i) := t_pts_source(i);

      elsif t_adjusted_item(i) is not null then

      -- 1. adjustment happened pre-R12, interfacing in R12
      -- 2. both parent and adjusting items in the same run
      -- 3. adjustment of R12 txn
      -- 4. adjustment of pre-R12 txn

      -- adjustment in R12 or both parent and adjusting items in the same run
         t_acct_source(i) := nvl(t_orig_acct_source(i),
                                 check_plsql_table(t_adjusted_item(i),
                                                   t_parent_line_num(i)));


	 if t_acct_source(i) is not null then
            if (t_pts_source(i) = 'RCV' or t_pts_source(i) like 'AP%') then

	       t_get_data(i) := t_pts_source(i);

            end if;
         else


	    if t_orig_acct_source(i) is null then

               t_acct_source(i) := t_pts_source(i);

               if (t_pts_source(i) = 'RCV' or t_pts_source(i) like 'AP%') then
		  t_get_data(i) := t_pts_source(i);
               end if;

               if t_orig_historic(i) = 'Y' then --and (t_acct_source(i) not  like 'AP%'
	                                        --and t_acct_source(i) <> 'RCV') then
		 t_acct_source(i) := 'UPG';
               end if;


               if t_acct_source(i) like 'AP%' and t_payment_id(i) is not null then
                  t_acct_source(i) := 'AP_PAY';
                 /* Bug 5374040 if t_transaction_source(i) = 'AP DISCOUNTS' then
                     t_acct_source(i) := 'AP_INV';
                  end if; */
               end if;

            end if;
         end if; -- acct source not null

	elsif t_transferred_from_item(i) is not null then

	/* Bug 5367462
	   There should be check adjusted_expenditure_item_id and then check for
	   transferred_from_exp_item_id as reversal of already adjusted EI will have both fields updated
	*/
	  -- New item as a result of adjustment interfacing now
          t_acct_source(i) := 'PA';

          if (t_pts_source(i) = 'RCV' or t_pts_source(i) like 'AP%') and
	      t_line_type(i) = 'R' then
	      t_get_data(i) := t_pts_source(i);
          end if;
      end if;  -- adjusted_item not null
   end if; -- line_num = 1
--
-- for adjustment and recosting cases, if original and new lines are being
-- interfaced together we want data to be ordered. Otherwise acct source
-- derived could be wrong.
--
if t_line_num(i) > 1 then
   if t_adjusted_item(i) is not null and
      t_parent_line_num(i) is not null then
   -- this is applicable to C and D lines for adjusting item
      t_acct_source(i) := nvl(t_orig_acct_source(i),
                              check_plsql_table(t_adjusted_item(i),
                                                t_parent_line_num(i)));
      -- adjustment of unupgraded txn
      if t_acct_source(i) is null then
         t_acct_source(i) := 'UPG';
      end if;
   elsif t_line_num_reversed(i) is null then
      t_acct_source(i) := 'PA';
      if (t_pts_source(i) = 'RCV' or t_pts_source(i) like 'AP%') and
          t_line_type(i) = 'R' then
	 t_get_data(i) := t_pts_source(i);
      end if;
   elsif t_line_num_reversed(i) is not null then
      t_acct_source(i) := nvl(t_orig_acct_source(i),
                              check_plsql_table(t_entity_id(i),
                                                t_line_num_reversed(i)));

      if t_acct_source(i) is null then
         t_acct_source(i) := t_pts_source(i);

         if (t_pts_source(i) = 'RCV' or t_pts_source(i) like 'AP%') and
	     t_line_type(i) = 'R' then
	    t_get_data(i) := t_pts_source(i);
         end if;

         if t_historical_flag(i) = 'Y' then --and (t_acct_source(i) not like 'AP%'
	                                    --and t_acct_source(i) <> 'RCV') then
               t_acct_source(i) := 'UPG';
         end if;

         if t_acct_source(i) like 'AP%' and t_payment_id(i) is not null then
            t_acct_source(i) := 'AP_PAY';
            /* Bug 5475269
	    if t_transaction_source(i) = 'AP DISCOUNTS' then
               t_acct_source(i) := 'AP_INV';
            end if;
	    */
         end if;

      end if;
   end if; -- line num reversed not null
end if; -- line_num > 1

end loop;
end if; -- g_calling_module
------------------------------------------------------------------------+
-- In re-costing scenario, if all the lines are interfacing together and
-- have the same gl_date then mark the original and reversing lines with
-- transfer_status_code of 'G'.
------------------------------------------------------------------------+

if g_calling_module in ('Cost', 'LAB', 'SUPP', 'USG', 'BTC',
                               'PJ', 'WIP', 'INV', 'TBC') then
   for i in t_entity_id.first..t_entity_id.last loop
      if t_line_num_reversed(i) is not null and t_tsc(i) <> 'G' then
         for k in t_entity_id.first..i loop
            if t_entity_id(k) = t_entity_id(i) and
               t_line_num(k) = t_line_num_reversed(i) and
               t_event_date(k) = t_event_date(i) and
               t_line_type(k) = t_line_type(i) and
               i <> k then
                  t_tsc(k) := 'G';
                  t_tsc(i) := 'G';
            end if;
         end loop;
      end if;
   end loop;

   for i in t_entity_id.first..t_entity_id.last loop
      if t_get_data(i) is not null then
         if t_get_data(i) like 'AP%' then
              t_cr_ccid(i) := g_imp_cr_ccid;
         elsif t_get_data(i) = 'RCV' then
            t_cr_ccid(i)  := g_imp_cr_ccid;
         end if;
      end if;
   end loop;

-- In case of adjustments, if the original doc is not accounted,
-- adjustment in Projects will not raise an event. CDLs will be
-- marked with rejection status.

   for i in t_entity_id.first..t_entity_id.last loop
     if t_adjusted_item(i) is not null then
        if t_acct_source(i) = 'PA' and t_line_type(i) = 'R' then
          l_application_id := 275;
          l_distribution_id_1 := t_adjusted_item(i);
          l_distribution_id_2 := t_parent_line_num(i);
          l_distribution_type := t_line_type(i);
	  l_check_parent_acct := FALSE; -- Bug 5105237
        end if;
     end if;
     if (t_adjusted_item(i) is not null or
         t_line_num_reversed(i) is not null) then
        if t_acct_source(i) = 'AP_INV' and t_adjusted_item(i) is not null then
          l_application_id := 200;
          l_distribution_id_1 := t_distribution_id(i);
          l_distribution_id_2 := NULL;
          l_distribution_type := 'AP_INV_DIST';
          l_check_parent_acct := TRUE;
        elsif t_acct_source(i) = 'AP_PAY' and t_adjusted_item(i) is not null then
          l_application_id := 200;
          l_distribution_id_1 := t_sr5(i);
          l_distribution_id_2 := NULL;
          l_distribution_type := 'AP_PMT_DIST';
          l_check_parent_acct := TRUE;
        elsif t_acct_source(i) = 'AP_APP' and t_adjusted_item(i) is not null then
          l_application_id := 200;
          l_distribution_id_1 := t_sr5(i);
          l_distribution_id_2 := NULL;
          l_distribution_type := 'AP_PREPAY';
          l_check_parent_acct := TRUE;
        elsif t_acct_source(i) = 'RCV' then -- for both adjusting item and reversing line
          l_application_id := 707;
          l_distribution_id_1 := t_sr5(i);
          l_distribution_id_2 := NULL;
          l_distribution_type := 'RCV_RECEIVING_SUB_LEDGER';
          l_check_parent_acct := TRUE;
        elsif t_acct_source(i) = 'INV' and t_line_num_reversed(i) is not null then
          l_application_id := 707;
          l_distribution_id_1 := t_sr5(i);
          l_distribution_id_2 := NULL;
          l_distribution_type := 'MTL_TRANSACTION_ACCOUNTS';
          l_check_parent_acct := TRUE;
        elsif t_acct_source(i) = 'WIP' and t_line_num_reversed(i) is not null then
          l_application_id := 707;
          l_distribution_id_1 := t_sr5(i);
          l_distribution_id_2 := NULL;
          l_distribution_type := 'WIP_TRANSACTION_ACCOUNTS';
          l_check_parent_acct := TRUE;
        end if;

        end if;

	if l_check_parent_acct then
	   begin
           l_ccid :=  pa_xla_interface_pkg.Get_Sla_Ccid( l_application_id
                                                        ,l_distribution_id_1
                                                        ,l_distribution_id_2
			                                ,l_distribution_type
                                                        ,'DEBIT'
                                                        ,g_ledger_id
                                                       );
          if l_ccid is null then
             t_tsc(i) := 'R';
	     t_raise_event(i) := 'N';
          end if;
          l_check_parent_acct := FALSE;
	  exception
	  when no_data_found then
	    t_tsc(i) := 'R';
	    t_raise_event(i) := 'N';
	    l_check_parent_acct := FALSE;
	  when too_many_rows then
	    l_check_parent_acct := FALSE;
          end;
       end if;
   end loop;

elsif g_calling_module in ('CC', 'BL', 'PC') then
   for i in t_entity_id.first..t_entity_id.last loop
      if t_dist_line_id_reversed(i) is not null and t_tsc(i) <> 'G' then
         for k in t_entity_id.first..i loop
            if t_entity_id(k) = t_entity_id(i) and
               t_cc_dist_line_id(k) = t_dist_line_id_reversed(i) and
               t_event_date(k) = t_event_date(i) and
               t_line_type(k) = t_line_type(i) and
               i <> k then
                  t_tsc(k) := 'G';
                  t_tsc(i) := 'G';
            end if;
         end loop;
      end if;
   end loop;
end if; -- g_calling_module

END POPULATE_ACCT_SOURCE;

-- ---------------------------------------------------------------------------------+
-- ENCUMBRANCE RELATED CHANGES STARTS HERE ...
-- ---------------------------------------------------------------------------------+

-- ---------------------------------------------------------------------------+
-- This procedure will derive the budget version id that needs to
-- be reversed. Case: Re-baseline, Year-end or Check funds
-- Out paramter: p_old_budget_version_id will be populated with this value
-- Procedure will also derive the budget status code of the current budget
-- Out parameter: p_curr_budget_status_code will be populated with this value
-- ---------------------------------------------------------------------------+
Procedure Get_bvid_to_reverse(p_budget_version_id       IN NUMBER,
   			      p_curr_budget_status_code OUT NOCOPY VARCHAR2,
                              p_old_budget_version_id   OUT NOCOPY NUMBER)
Is
 l_budget_type_code pa_budget_versions.budget_type_code%TYPE;
 l_project_id       pa_budget_versions.project_id%TYPE;
Begin

  IF g_debug_mode = 'Y' THEN
     pa_debug.g_err_stage:= 'Get_bvid_to_reverse';
     pa_debug.write('create_events ' || g_debug_module,pa_debug.g_err_stage, g_debug_level5);
  END IF;

 Select budget_type_code,budget_status_code,project_id
 into   l_budget_type_code,p_curr_budget_status_code,l_project_id
 from   pa_budget_versions
 where  budget_version_id = p_budget_version_id;

 If p_curr_budget_status_code in ('S','W') then

    -- Draft version is used during "check funds", so get the current
    -- baselined version for reversal
    -- S: for submitted budget and W: for working (before submitted)

  Begin
     Select budget_version_id
     into   p_old_budget_version_id
     from   pa_budget_versions
     where  project_id         = l_project_id
     and    budget_type_code   = l_budget_type_code
     and    budget_status_code = 'B'
     and    current_flag       = 'Y';
  Exception
    When no_data_found then
         p_old_budget_version_id := null;
         -- first time submit ...
  End;

 ElsIf p_curr_budget_status_code = 'B' then
    -- Baselined version is used during "baseline", so get the last
	-- baselined version for reversal

     Select MAX(budget_version_id)
     into   p_old_budget_version_id
     from   pa_budget_versions
     where  project_id         = l_project_id
     and    budget_type_code   = l_budget_type_code
     and    budget_status_code = 'B'
     and    current_flag       = 'N'
     and    budget_version_id  <> p_budget_version_id;

     -- Note: If p_old_budget_version_id is null means first time baseline ..
 End If;


  IF g_debug_mode = 'Y' THEN
     pa_debug.g_err_stage:= 'Get_bvid_to_reverse'||':l_budget_type_code:'||l_budget_type_code||
                            ':p_curr_budget_status_code:'||p_curr_budget_status_code;
     pa_debug.write('create_events ' || g_debug_module,pa_debug.g_err_stage, g_debug_level5);

     pa_debug.g_err_stage:= 'Get_bvid_to_reverse'||':Last baselined version:'||p_old_budget_version_id;
     pa_debug.write('create_events ' || g_debug_module,pa_debug.g_err_stage, g_debug_level5);
  END IF;

End Get_bvid_to_reverse;

-- ---------------------------------------------------------------------------+
-- This procedure will call XLA public API to delete draft
-- events (if they were established earlier), called from "Reset_event_id"
-- for budgets and "populate_enc_event_array" for funds check.
-- Parameters:
-- p_data_set_id1 : Current packet_id for Funds check and
--                  Last baselined version for Budgets
-- p_data_set_id2 : Draft budget version for budgets
-- p_calling_module : 'BUDGETS' or 'FUNDS_CHECK'
-- p_events_to_delete: 'Y' if there are events to delete ..
-- ---------------------------------------------------------------------------+
Procedure Delete_xla_event_data(p_data_set_id1      IN NUMBER,
                                p_data_set_id2      IN NUMBER,
                                p_calling_module    IN VARCHAR2,
                                p_events_to_delete  IN OUT NOCOPY VARCHAR2)
Is
Begin

 IF g_debug_mode = 'Y' THEN
    pa_debug.g_err_stage:= 'Delete_xla_event_data'||'Module:['||p_calling_module
             ||']packet_id or last baselined version['||p_data_set_id1
             ||']draft budget version['||p_data_set_id2||']';
    pa_debug.write('create_events ' || g_debug_module,pa_debug.g_err_stage, g_debug_level5);

    pa_debug.g_err_stage:= 'Delete_xla_event_data'||':Collect data for deleting reversing events';
    pa_debug.write('create_events ' || g_debug_module,pa_debug.g_err_stage, g_debug_level5);
 END IF;

 If p_calling_module = 'BUDGETS' then

      -- A. Select budget event data for clean up ..
        select txn.source_application_id,
               txn.application_id,
               txn.legal_entity_id,
               txn.ledger_id,
               txn.entity_code entity_type_code,
               txn.transaction_number,
               txn.source_id_int_1,
               txn.source_id_int_2,
               txn.source_id_int_3,
               txn.source_id_int_4,
               txn.source_id_char_1,
               txn.source_id_char_2,
               txn.source_id_char_3,
               txn.source_id_char_4,
               txn.security_id_int_1,
	           evt.event_id
         BULK COLLECT INTO
             t_source_application_id,
             t_application_id,
             t_legal_entity_id,
             t_ledger_id,
             t_entity_type_code,
             t_transaction_number,
             t_source_id_int_1,
             t_source_id_int_2,
             t_source_id_int_3,
             t_source_id_int_4,
             t_source_id_char_1,
             t_source_id_char_2,
             t_source_id_char_3,
             t_source_id_char_4,
             t_security_org_id,
             t_source_event_id
          from  xla_events evt,
                xla_transaction_entities txn
          where evt.entity_id = txn.entity_id
          and   evt.event_id in
                (Select distinct bc_rev_event_id
                 from   pa_budget_lines
                 where  budget_version_id = p_data_set_id1
                 and    bc_rev_event_id is not null
                 and    p_data_set_id1 is not null
                 UNION ALL
                 Select distinct bc_event_id
                 from   pa_budget_lines
                 where  budget_version_id = p_data_set_id2
                 and    bc_event_id is not null
                 and    p_data_set_id2 is not null
                 );
                 -- 1st select for last baselined and 2nd for draft budget

 Elsif p_calling_module = 'FUNDS_CHECK' then

     -- A. Select event data for clean up ..
        select txn.source_application_id,
               txn.application_id,
               txn.legal_entity_id,
               txn.ledger_id,
               txn.entity_code entity_type_code,
               txn.transaction_number,
               txn.source_id_int_1,
               txn.source_id_int_2,
               txn.source_id_int_3,
               txn.source_id_int_4,
               txn.source_id_char_1,
               txn.source_id_char_2,
               txn.source_id_char_3,
               txn.source_id_char_4,
               txn.security_id_int_1,
	       evt.event_id
         BULK COLLECT INTO
             t_source_application_id,
             t_application_id,
             t_legal_entity_id,
             t_ledger_id,
             t_entity_type_code,
             t_transaction_number,
             t_source_id_int_1,
             t_source_id_int_2,
             t_source_id_int_3,
             t_source_id_int_4,
             t_source_id_char_1,
             t_source_id_char_2,
             t_source_id_char_3,
             t_source_id_char_4,
             t_security_org_id,
             t_source_event_id
          from  xla_events evt,
                xla_transaction_entities txn
          where evt.entity_id = txn.entity_id
          and   evt.event_id in
                (select distinct pbc1.bc_event_id
                 from   pa_bc_packets pbc1
                 where  pbc1.packet_id <> p_data_set_id1
                 and   (pbc1.document_header_id,
                        pbc1.document_distribution_id,
                        pbc1.document_type) in
                         (select pbc2.document_header_id,
                                 pbc2.document_distribution_id,
                                 pbc2.document_type
                          from   pa_bc_packets pbc2
                          where  pbc2.packet_id     = p_data_set_id1
                          and    pbc2.status_code   = 'I'
                          and    pbc2.ext_bdgt_flag = 'Y')
                 and     pbc1.status_code in ('S','F','T','R')
                 and     pbc1.bc_event_id is not null)
           and  evt.event_status_code <> 'P';

 End If; --If p_calling_module = 'BUDGETS' then

  If t_source_event_id.exists(1) then

          -- B. Initalize out variable ..
          p_events_to_delete := 'Y';

          IF g_debug_mode = 'Y' THEN
             pa_debug.g_err_stage:= 'Delete_xla_event_data:'||t_source_event_id.COUNT||' event(s) to be deleted';
            pa_debug.write('create_events ' || g_debug_module,pa_debug.g_err_stage, g_debug_level5);
          END IF;

          -- C. Assign the values to pl/sql array

          for i in t_source_event_id.FIRST..t_source_event_id.LAST loop

             tt_source_info(i).source_application_id := t_source_application_id(i);
             tt_source_info(i).application_id        := t_application_id(i);
             tt_source_info(i).legal_entity_id       := t_legal_entity_id(i);
             tt_source_info(i).ledger_id             := t_ledger_id(i);
             tt_source_info(i).entity_type_code      := t_entity_type_code(i);
             tt_source_info(i).transaction_number    := t_transaction_number(i);
             tt_source_info(i).source_id_int_1       := t_source_id_int_1(i);
             tt_source_info(i).source_id_int_2       := t_source_id_int_2(i);
             tt_source_info(i).source_id_int_3       := t_source_id_int_3(i);
             tt_source_info(i).source_id_int_4       := t_source_id_int_4(i);
             tt_source_info(i).source_id_char_1      := t_source_id_char_1(i);
             tt_source_info(i).source_id_char_2      := t_source_id_char_2(i);
             tt_source_info(i).source_id_char_3      := t_source_id_char_3(i);
             tt_source_info(i).source_id_char_4      := t_source_id_char_4(i);
             tt_security_info(i).security_id_int_1   := t_security_org_id(i);

          end loop;

          -- D. Call XLA delete API

          IF g_debug_mode = 'Y' THEN
             pa_debug.g_err_stage:= 'Delete_xla_event_data:'||'Call xla_events_pub_pkg.delete_event';
            pa_debug.write('create_events ' || g_debug_module,pa_debug.g_err_stage, g_debug_level5);
          END IF;

          for i in t_source_event_id.FIRST..t_source_event_id.LAST loop
            XLA_EVENTS_PUB_PKG.DELETE_EVENT(p_event_source_info => tt_source_info(i)
                                           ,p_event_id          => t_source_event_id(i)
                                           ,p_valuation_method  => NULL
                                           ,p_security_context  => tt_security_info(i));
          end loop;

          -- E. Initalize pl/sql table
          IF g_debug_mode = 'Y' THEN
             pa_debug.g_err_stage:= 'Delete_xla_event_data:'||'initalize pl/sql table';
            pa_debug.write('create_events ' || g_debug_module,pa_debug.g_err_stage, g_debug_level5);
          END IF;

             t_source_application_id.DELETE;
             t_application_id.DELETE;
             t_legal_entity_id.DELETE;
             t_ledger_id.DELETE;
             t_entity_type_code.DELETE;
             t_transaction_number.DELETE;
             t_source_id_int_1.DELETE;
             t_source_id_int_2.DELETE;
             t_source_id_int_3.DELETE;
             t_source_id_int_4.DELETE;
             t_source_id_char_1.DELETE;
             t_source_id_char_2.DELETE;
             t_source_id_char_3.DELETE;
             t_source_id_char_4.DELETE;
             t_security_org_id.DELETE;
             t_source_event_id.DELETE;

     Else

          IF g_debug_mode = 'Y' THEN
             pa_debug.g_err_stage:= 'Delete_xla_event_data: No event to delete';
            pa_debug.write('create_events ' || g_debug_module,pa_debug.g_err_stage, g_debug_level5);
          END IF;

     End If;

End Delete_xla_event_data;

-- ---------------------------------------------------------------------------+
-- This procedure will reset the reversing event_id on pa_budget_versions.
-- This is required as re-baseline/Year-End can fail
-- it will also reset event_id on the draft budget as user can execute
-- "check funds"  multiple times.
-- ---------------------------------------------------------------------------+
Procedure Reset_event_id (p_budget_version_id       IN NUMBER,
			  p_curr_budget_status_code IN VARCHAR2,
			  p_old_budget_version_id   IN NUMBER)
Is
-- l_events_to_delete Varchar2(1);
Begin

  -- ----------------------------------------------------------------------------------------- +
  IF g_debug_mode = 'Y' THEN
     pa_debug.g_err_stage:= 'Reset_event_id'||':Current Budget Status:'||p_curr_budget_status_code||
                            ':Last baselined version:'||p_old_budget_version_id||
                            ':Current budget version:'||p_budget_version_id;
     pa_debug.write('create_events ' || g_debug_module,pa_debug.g_err_stage, g_debug_level5);

     pa_debug.g_err_stage:= 'Reset_event_id'||':Calling DELETE_XLA_EVENT_DATA';
     pa_debug.write('create_events ' || g_debug_module,pa_debug.g_err_stage, g_debug_level5);
  END IF;
  -- ----------------------------------------------------------------------------------------- +
  l_events_to_delete := 'N';

 If p_curr_budget_status_code in ('S','W') then
    -- CF, CF after baseline (p_old will be NULL ..before 1st baseline)

    DELETE_XLA_EVENT_DATA(p_data_set_id1      => p_old_budget_version_id,
                          p_data_set_id2      => p_budget_version_id,
                          p_calling_module    => 'BUDGETS',
                          p_events_to_delete  => l_events_to_delete);
 Else

   -- Baseline, re-baseline ..
    DELETE_XLA_EVENT_DATA(p_data_set_id1      => p_old_budget_version_id,
                          p_data_set_id2      => NULL,
                          p_calling_module    => 'BUDGETS',
                          p_events_to_delete  => l_events_to_delete);

 End If; --If p_curr_budget_status_code in ('S','W') then

 -- p_data_set_id1: last baselined version
 -- p_data_set_id2: Current draft or latest budget version (will not have events)

 If l_events_to_delete = 'Y' then

    If p_curr_budget_status_code in ('S','W') then
       -- ----------------------------------------------------------------------------------------- +
       -- Update draft budget's event_id to null
       IF g_debug_mode = 'Y' THEN
          pa_debug.g_err_stage:= 'Reset_event_id'||': Reset bc_event_id for p_budget_version_id:'||p_budget_version_id;
          pa_debug.write('create_events ' || g_debug_module,pa_debug.g_err_stage, g_debug_level5);
       END IF;
       -- ----------------------------------------------------------------------------------------- +

       Update pa_budget_lines
       set    bc_event_id       = NULL
       where  budget_version_id = p_budget_version_id;

   End If;

   If p_old_budget_version_id is not null then
      -- ----------------------------------------------------------------------------------------- +
      IF g_debug_mode = 'Y' THEN
         pa_debug.g_err_stage:= 'Reset_event_id'||':Reset bc_rev_event_id for p_old_budget_version_id:'||p_old_budget_version_id;
         pa_debug.write('create_events ' || g_debug_module,pa_debug.g_err_stage, g_debug_level5);
      END IF;
      -- ----------------------------------------------------------------------------------------- +

      Update pa_budget_lines
      set    bc_rev_event_id   = NULL
      where  budget_version_id = p_old_budget_version_id;

    End If;

 End If; -- If l_events_to_delete = 'Y' then

End Reset_event_id;

/*
-- ---------------------------------------------------------------------------+
-- This is the procedure that will get called to populate xla_events_gt
-- ---------------------------------------------------------------------------+
Procedure Populate_enc_events_gt (p_Source_Id_Int1    IN TypeNum,
                                  p_event_type_code   IN TypeVarChar,
                                  p_event_date        IN TypeDate,
                                  p_calling_module    IN Varchar2)
IS
 l_application_id      NUMBER;
 l_event_status_code   VARCHAR2(1);
 l_user_id             NUMBER;

Begin

   IF g_debug_mode = 'Y' THEN
     pa_debug.g_err_stage:= 'Populate_enc_events_gt'||':Calling Module:'||p_calling_module||
                            ' :Event count being inserted'||p_Source_Id_Int1.COUNT;
     pa_debug.write('create_events ' || g_debug_module,pa_debug.g_err_stage, g_debug_level5);
  END IF;

  -- 1. Set variables
   l_application_id    := 275;
   l_event_status_code := xla_events_pub_pkg.c_event_unprocessed;
   l_user_id           := fnd_global.user_id;
   g_enc_create_events_flag := 'Y'; -- accessed in create_events

  -- 2. Insert into xla_events_gt
  If p_calling_module = 'BUDGET' then

   forall i in p_Source_Id_Int1.first..p_Source_Id_Int1.last
   insert into xla_events_gt (  LINE_NUMBER,
                                ENTITY_ID,
                                APPLICATION_ID,
                                LEDGER_ID,
                                LEGAL_ENTITY_ID,
                                ENTITY_CODE,
                                TRANSACTION_NUMBER,
                                SOURCE_ID_INT_1,
                                SOURCE_ID_INT_2,
                                SOURCE_ID_INT_3,
                                SOURCE_ID_INT_4,
                                SOURCE_ID_CHAR_1,
                                SOURCE_ID_CHAR_2,
                                SOURCE_ID_CHAR_3,
                                SOURCE_ID_CHAR_4,
                                EVENT_ID,
                                EVENT_CLASS_CODE,
                                EVENT_TYPE_CODE,
                                EVENT_NUMBER,
                                EVENT_DATE,
                                EVENT_STATUS_CODE,
                                PROCESS_STATUS_CODE,
                                EVENT_CREATED_BY,
                                REFERENCE_NUM_1,
                                REFERENCE_NUM_2,
                                REFERENCE_NUM_3,
                                REFERENCE_NUM_4,
                                REFERENCE_CHAR_1,
                                REFERENCE_CHAR_2,
                                REFERENCE_CHAR_3,
                                REFERENCE_CHAR_4,
                                REFERENCE_DATE_1,
                                REFERENCE_DATE_2,
                                REFERENCE_DATE_3,
                                REFERENCE_DATE_4,
                                VALUATION_METHOD,
                                SECURITY_ID_INT_1,
                                SECURITY_ID_INT_2,
                                SECURITY_ID_INT_3,
                                SECURITY_ID_CHAR_1,
                                SECURITY_ID_CHAR_2,
                                SECURITY_ID_CHAR_3,
                                ON_HOLD_FLAG,
                                TRANSACTION_DATE,
                                BUDGETARY_CONTROL_FLAG)
                       values   (NULL,                   -- line number
                                 NULL,                   -- entity_id
                                 l_application_id,       -- application id
                                 g_ledger_id,            -- ledger id (set in init)
                                 NULL,                   -- legal entity id
                                 g_entity_code,          -- entity_code (set in init)
                                 NULL,                   -- transaction num
                                 p_Source_Id_Int1(i),    -- source_id_int_1
                                 NULL,                   -- source_id_int_2
                                 NULL,                   -- source_id_int_3
                                 NULL,                   -- source_id_int_4
                                 NULL,                   -- source_id_char_1
                                 NULL,                   -- source_id_char_2
                                 NULL,                   -- source_id_char_3
                                 NULL,                   -- source_id_char_4
                                 NULL,                   -- event_id
                                 NULL,                   -- EVENT_CLASS_CODE
                                 g_event_type_code,      -- EVENT_TYPE_CODE
                                 NULL,                   -- EVENT_NUMBER
                                 p_event_date(i),        -- EVENT_DATE
                                 l_event_status_code,    -- EVENT_STATUS_CODE
                                 NULL,                   -- PROCESS_STATUS_CODE
                                 l_user_id,              -- EVENT_CREATED_BY
                                 NULL,                   -- REFERENCE_NUM_1
                                 NULL,                   -- REFERENCE_NUM_2
                                 NULL,                   -- REFERENCE_NUM_3
                                 NULL,                   -- REFERENCE_NUM_4
                                 NULL,                   -- REFERENCE_CHAR_1
                                 NULL,                   -- REFERENCE_CHAR_2
                                 NULL,                   -- REFERENCE_CHAR_3
                                 NULL,                   -- REFERENCE_CHAR_4
                                 NULL,                   -- REFERENCE_DATE_1
                                 NULL,                   -- REFERENCE_DATE_2
                                 NULL,                   -- REFERENCE_DATE_3
                                 NULL,                   -- REFERENCE_DATE_4
                                 NULL,                   -- VALUATION_METHOD
                                 g_project_org_id,       -- SECURITY_ID_INT_1
                                 NULL,                   -- SECURITY_ID_INT_2
                                 NULL,                   -- SECURITY_ID_INT_3
                                 NULL,                   -- SECURITY_ID_CHAR_1
                                 NULL,                   -- SECURITY_ID_CHAR_2
                                 NULL,                   -- SECURITY_ID_CHAR_3
                                 NULL,                   -- ON_HOLD_FLAG
                                 NULL,                   -- TRANSACTION_DATE
                                  'Y');                  -- BUDGETARY_CONTROL_FLAG

  End If; -- If p_calling_module = 'BUDGET' then

End Populate_enc_events_gt;
*/
-- ---------------------------------------------------------------------------+
-- This procedure will select/identify encumbrance data (for budget baseline,
-- budget check funds,Year-end), Fund check - AP/PO/REQ, Interface - BTC/TBC
-- and populate xla_events_gt
-- ---------------------------------------------------------------------------+
Procedure Populate_enc_event_array
IS

 l_limit                   number(3);
 l_counter                 number(3);
 l_bvid_to_reverse         pa_budget_versions.budget_version_id%type;
 l_curr_budget_status_code pa_budget_versions.budget_status_code%type;
 l_burden_method           VARCHAR2(10);

 -- Following variables used to build transaction number for budget
 -- Transaction number: 'project number' - 'budget type' - 'budget version number'

 l_budget_type             pa_budget_types.budget_type%type;
 l_project_number          pa_projects_all.segment1%type;
 l_budget_version_number   pa_budget_versions.version_number%type;
 l_rev_budget_version_number pa_budget_versions.version_number%type;

Begin

   IF g_debug_mode = 'Y' THEN
     pa_debug.g_err_stage:= 'Populate_enc_event_array';
     pa_debug.write('create_events ' || g_debug_module,pa_debug.g_err_stage, g_debug_level5);
  END IF;

  -- -----------------------------------------------------------------------------------+
  -- 1. Set variables
  -- -----------------------------------------------------------------------------------+
  l_limit   := 500; -- Set l_limit for bulk processing
  l_counter := 0;
  g_enc_create_events_flag := 'N';

  -- -----------------------------------------------------------------------------------+
  -- 2. Derive Event type code (for budgets)
  -- -----------------------------------------------------------------------------------+
  If g_calling_module in ('COST_BUDGET','CC_BUDGET','REVENUE_BUDGET') then
     g_event_type_code := 'BUDGET_BASELINE';
  Elsif g_calling_module in ('COST_BUDGET_YEAR_END','CC_BUDGET_YEAR_END') then
     g_event_type_code := 'BGT_YR_END_ROLLOVER';
  End If;

  -- -----------------------------------------------------------------------------------+
  -- 3. Budget specific processing
  -- -----------------------------------------------------------------------------------+
  If  g_entity_code = 'BUDGETS' then

  -- 3A. Get current budget status code and also the budget version to reverse
      IF g_debug_mode = 'Y' THEN
         pa_debug.g_err_stage:= 'Populate_enc_event_array'||':Budget - Get_bvid_to_reverse';
         pa_debug.write('create_events ' || g_debug_module,pa_debug.g_err_stage, g_debug_level5);
      END IF;

     Get_bvid_to_reverse(p_budget_version_id       => g_data_set_id,
                         p_curr_budget_status_code => l_curr_budget_status_code,
                         p_old_budget_version_id   => l_bvid_to_reverse);

  -- 3B. Re-set event id (check funds/re-baseline failure)
      IF g_debug_mode = 'Y' THEN
         pa_debug.g_err_stage:= 'Populate_enc_event_array'||':Budget - Reset_event_id';
         pa_debug.write('create_events ' || g_debug_module,pa_debug.g_err_stage, g_debug_level5);
      END IF;

      Reset_event_id (p_budget_version_id       => g_data_set_id,
		      p_curr_budget_status_code => l_curr_budget_status_code,
                      p_old_budget_version_id   => l_bvid_to_reverse);

  -- 3C. Get org_id for the project
      IF g_debug_mode = 'Y' THEN
         pa_debug.g_err_stage:= 'Populate_enc_event_array'||':Budget - Get org_id';
         pa_debug.write('create_events ' || g_debug_module,pa_debug.g_err_stage, g_debug_level5);
      END IF;

         select pp.org_id,pp.segment1,
                pbv.version_number,pbt.budget_type
         into   g_project_org_id,l_project_number,
                l_budget_version_number,l_budget_type
         from   pa_projects_all pp,
                pa_budget_versions pbv,
                pa_budget_types pbt
         where  pbv.budget_version_id = g_data_set_id
         and    pp.project_id         = pbv.project_id
         and    pbt.budget_type_code  = pbv.budget_type_code;

         If l_bvid_to_reverse is not null then
             select pbv.version_number
             into   l_rev_budget_version_number
             from   pa_budget_versions pbv
             where  pbv.budget_version_id = l_bvid_to_reverse;
         End If;

  -- 3D. Process budgets
      IF g_debug_mode = 'Y' THEN
         pa_debug.g_err_stage:= 'Populate_enc_event_array'||':Budget - Processing events::g_data_set_id,l_bvid_to_reverse::'||
                                 g_data_set_id||':'||l_bvid_to_reverse;
         pa_debug.write('create_events ' || g_debug_module,pa_debug.g_err_stage, g_debug_level5);
      END IF;

      -- Note: g_data_set_id is for current version and l_bvid_to_reverse for reversing prev. baselined

     select distinct budget_version_id, start_date
     BULK COLLECT INTO t_source_id_int_1,t_event_date
     from   pa_budget_lines
     where  budget_version_id in (g_data_set_id,l_bvid_to_reverse);

     If  g_debug_mode = 'Y' THEN

         pa_debug.g_err_stage:= 'Populate_enc_event_array'||':Distinct budget record count is:'||t_source_id_int_1.COUNT;
         pa_debug.write('create_events ' || g_debug_module,pa_debug.g_err_stage, g_debug_level5);

     End If;

     for x in 1..t_source_id_int_1.COUNT loop

         t_source_application_id(x) := 275;
         t_application_id(x)        := 275;
         t_legal_entity_id(x)       := to_number(null);
         t_ledger_id(x)             := g_ledger_id;
         t_entity_type_code(x)      := g_entity_code;
         t_source_id_int_2(x)       := to_number(null);
         t_source_id_int_3(x)       := to_number(null);
         t_source_id_int_4(x)       := to_number(null);
         t_source_id_char_1(x)      := null;
         t_source_id_char_2(x)      := null;
         t_source_id_char_3(x)      := null;
         t_source_id_char_4(x)      := null;
         t_transaction_date(x)      := null;
         t_security_org_id(x)       := g_project_org_id;
         t_event_type_code(x)       := g_event_type_code;

         t_transaction_number(x)    := l_project_number||' - '||l_budget_type||' - ';

         If t_source_id_int_1(x) = g_data_set_id then
            t_transaction_number(x) := t_transaction_number(x) || l_budget_version_number;
         Elsif t_source_id_int_1(x) = l_bvid_to_reverse then
            t_transaction_number(x) := t_transaction_number(x) || l_rev_budget_version_number;
         End If;

     end loop;

  -- 3E. Set global variable
         g_bvid_to_reverse := l_bvid_to_reverse;

 End If;    -- Budget specific processing

  -- -----------------------------------------------------------------------------------+
  -- 4. Funds Check specific processing
  -- -----------------------------------------------------------------------------------+
  If g_calling_module = 'FUNDS_CHECK' then

     -- 4A: Clean up draft events created for the same document 'cause
     --      of Check funds action on the doc ..
     -- ----------------------------------------------------------------------------------------- +
     IF g_debug_mode = 'Y' THEN
        pa_debug.g_err_stage:= 'Populate_enc_event_array'||':Calling DELETE_XLA_EVENT_DATA';
        pa_debug.write('create_events ' || g_debug_module,pa_debug.g_err_stage, g_debug_level5);
     END IF;
     -- ----------------------------------------------------------------------------------------- +

     l_events_to_delete := 'N';

      DELETE_XLA_EVENT_DATA(p_data_set_id1      => g_data_set_id,
                            p_data_set_id2      => NULL,
                            p_calling_module    => 'FUNDS_CHECK',
                            p_events_to_delete  => l_events_to_delete);

      -- 4B. Get event related data ..
      IF g_debug_mode = 'Y' THEN
         pa_debug.g_err_stage:= 'Populate_enc_event_array'||':FC: Derive required data';
         pa_debug.write('create_events ' || g_debug_module,pa_debug.g_err_stage, g_debug_level5);
      END IF;

        select txn.source_application_id,
               txn.application_id,
               txn.legal_entity_id,
               txn.ledger_id,
               txn.entity_code entity_type_code,
               txn.transaction_number,
               txn.source_id_int_1,
               txn.source_id_int_2,
               txn.source_id_int_3,
               txn.source_id_int_4,
               txn.source_id_char_1,
               txn.source_id_char_2,
               txn.source_id_char_3,
               txn.source_id_char_4,
               evt.event_date,
               evt.transaction_date,
               txn.security_id_int_1,
	       evt.event_id,
               decode(evt.event_type_code,
                      'REQ_RESERVED','REQ_BURDEN_RESERVED',
                      'REQ_ADJUSTED','REQ_BURDEN_ADJUSTED',
                      'REQ_UNRESERVED','REQ_BURDEN_UNRESERVED',
                      'REQ_CANCELLED','REQ_BURDEN_CANCELLED',
                      'REQ_FINAL_CLOSED','REQ_BURDEN_FINAL_CLOSED',
                      'REQ_REJECTED','REQ_BURDEN_REJECTED',
                      'REQ_RETURNED','REQ_BURDEN_RETURNED',
                      'PO_PA_RESERVED','PO_BURDEN_RESERVED',
                      'PO_PA_ADJUSTED','PO_BURDEN_ADJUSTED',
                      'PO_PA_UNRESERVED','PO_BURDEN_UNRESERVED',
                      'PO_PA_CANCELLED','PO_BURDEN_CANCELLED',
                      'PO_PA_FINAL_CLOSED','PO_BURDEN_FINAL_CLOSED',
                      'PO_PA_REJECTED','PO_BURDEN_REJECTED',
                      'PO_PA_REOPEN_FINAL_MATCH','PO_BURDEN_REOPEN_FINAL_MATCH',
                      'PO_PA_INV_CANCELLED','PO_BURDEN_INV_CANCELLED',
                      'PO_PA_CR_MEMO_CANCELLED','PO_BURDEN_CR_MEMO_CANCELLED',
                      'RELEASE_RESERVED','REL_BURDEN_RESERVED',
                      'RELEASE_ADJUSTED','REL_BURDEN_ADJUSTED',
                      'RELEASE_UNRESERVED','REL_BURDEN_UNRESERVED',
                      'RELEASE_CANCELLED','REL_BURDEN_CANCELLED',
                      'RELEASE_FINAL_CLOSED','REL_BURDEN_FINAL_CLOSED',
                      'RELEASE_REJECTED','REL_BURDEN_REJECTED',
                      'RELEASE_REOPEN_FINAL_CLOSED','REL_BURDEN_REOPEN_FINAL_CLOSED',
                      'RELEASE_INV_CANCELLED','REL_BURDEN_INV_CANCELLED',
                      'RELEASE_CR_MEMO_CANCELLED','REL_BURDEN_CR_MEMO_CANCELLED',
                      'INVOICE VALIDATED','INVOICE_BURDEN_VALIDATED',
                      'INVOICE CANCELLED','INVOICE_BURDEN_CANCELLED',
                      'INVOICE ADJUSTED','INVOICE_BURDEN_ADJUSTED',
                      'CREDIT MEMO VALIDATED','INVOICE_BURDEN_VALIDATED',
                      'CREDIT MEMO CANCELLED','INVOICE_BURDEN_CANCELLED',
                      'CREDIT MEMO ADJUSTED','INVOICE_BURDEN_ADJUSTED',
                      'DEBIT MEMO VALIDATED','INVOICE_BURDEN_VALIDATED',
                      'DEBIT MEMO CANCELLED','INVOICE_BURDEN_CANCELLED',
                      'DEBIT MEMO ADJUSTED','INVOICE_BURDEN_ADJUSTED',
                      'PREPAYMENT VALIDATED','PREPAYMENT_VALIDATED_BURDEN',
                      'PREPAYMENT ADJUSTED','PREPAYMENT_ADJUSTED_BURDEN',
                      'PREPAYMENT CANCELLED','PREPAYMENT_CANCELLED_BURDEN',
                      'PREPAYMENT APPLIED','PREPAYMENT_APPLIED_BURDEN',
                      'PREPAYMENT UNAPPLIED','PREPAYMENT_UNAPPLIED_BURDEN',
                      'PREPAYMENT APPLICATION ADJ','PREPAY_APPLICATION_ADJ_BURDEN'
                      ) event_type_code,
                  evt.event_id
         BULK COLLECT INTO
             t_source_application_id,
             t_application_id,
             t_legal_entity_id,
             t_ledger_id,
             t_entity_type_code,
             t_transaction_number,
             t_source_id_int_1,
             t_source_id_int_2,
             t_source_id_int_3,
             t_source_id_int_4,
             t_source_id_char_1,
             t_source_id_char_2,
             t_source_id_char_3,
             t_source_id_char_4,
             t_event_date,
             t_transaction_date,
             t_security_org_id,
             t_source_event_id,
             t_event_type_code,
             t_reference_num_1
          from  xla_events evt,
                xla_transaction_entities txn
          where evt.entity_id = txn.entity_id
          and   evt.event_id in
                (select distinct source_event_id
                 from   pa_bc_packets
                 where  packet_id     = g_data_set_id
                 and    status_code   = 'I'
                 and    ext_bdgt_flag = 'Y'
                 --and    burden_method_code in ('S','D')
                 --and    bc_event_id is null
                );

  End If; -- Funds Check processing

  -- -----------------------------------------------------------------------------------+
  -- 5. Common Processing for FC and Budgeting
  -- -----------------------------------------------------------------------------------+

  -- A. Populate Source pl/sql table ..
      IF g_debug_mode = 'Y' THEN
         pa_debug.g_err_stage:= 'Populate_enc_event_array'||':FC: Populate source pl/sql table';
         pa_debug.write('create_events ' || g_debug_module,pa_debug.g_err_stage, g_debug_level5);
      END IF;

       If t_event_type_code.exists(1) then

          for i in t_event_type_code.FIRST..t_event_type_code.LAST loop

             tt_source_info(i).source_application_id := t_source_application_id(i);
             tt_source_info(i).application_id        := t_application_id(i);
             tt_source_info(i).legal_entity_id       := t_legal_entity_id(i);
             tt_source_info(i).ledger_id             := t_ledger_id(i);
             tt_source_info(i).entity_type_code      := t_entity_type_code(i);
             tt_source_info(i).transaction_number    := t_transaction_number(i);
             tt_source_info(i).source_id_int_1       := t_source_id_int_1(i);
             tt_source_info(i).source_id_int_2       := t_source_id_int_2(i);
             tt_source_info(i).source_id_int_3       := t_source_id_int_3(i);
             tt_source_info(i).source_id_int_4       := t_source_id_int_4(i);
             tt_source_info(i).source_id_char_1      := t_source_id_char_1(i);
             tt_source_info(i).source_id_char_2      := t_source_id_char_2(i);
             tt_source_info(i).source_id_char_3      := t_source_id_char_3(i);
             tt_source_info(i).source_id_char_4      := t_source_id_char_4(i);
             tt_security_info(i).security_id_int_1   := t_security_org_id(i);

             --If g_calling_module = 'FUNDS_CHECK' then
             --   tt_reference_info(i).reference_num_1    := t_reference_num_1(i);
             --Else
             --   tt_reference_info(i).reference_num_1    := '';
             --End If;

          end loop;


       -- B. Delete temp pl/sql table ..
             IF g_debug_mode = 'Y' THEN
                pa_debug.g_err_stage:= 'Populate_enc_event_array'||':FC: Delete temp. pl/sql table';
                pa_debug.write('create_events ' || g_debug_module,pa_debug.g_err_stage, g_debug_level5);
             END IF;

             t_source_application_id.DELETE;
             t_application_id.DELETE;
             t_legal_entity_id.DELETE;
             t_ledger_id.DELETE;
             t_entity_type_code.DELETE;
             t_transaction_number.DELETE;
             --t_source_id_int_1.DELETE; -- after tieback as its reqd. for budget tieback
             t_source_id_int_2.DELETE;
             t_source_id_int_3.DELETE;
             t_source_id_int_4.DELETE;
             t_source_id_char_1.DELETE;
             t_source_id_char_2.DELETE;
             t_source_id_char_3.DELETE;
             t_source_id_char_4.DELETE;
             t_security_org_id.DELETE;

             --If g_calling_module = 'FUNDS_CHECK' then
                t_reference_num_1.DELETE;
             --End If;

     End If; -- If t_event_type_code.exists(1) then

End Populate_enc_event_array;

-- -------------------------------------------------------------------+
-- This procedure will update event_id on the source tables
-- Called during budget processing ...
-- -------------------------------------------------------------------+
Procedure Tieback_budget_event
Is
Begin
   If t_event_id.EXISTS(1) then
      IF g_debug_mode = 'Y' THEN
         pa_debug.g_err_stage:= 'Tieback_budget_event: Process Start';
         pa_debug.write('create_events ' || g_debug_module,pa_debug.g_err_stage, g_debug_level5);
      END IF;

      forall i in t_source_id_int_1.FIRST..t_source_id_int_1.LAST
        Update pa_budget_lines
        set    bc_event_id          = t_event_id(i)
        where  budget_version_id    = t_source_id_int_1(i)
        and    start_date           = t_event_date(i)
        and    t_source_id_int_1(i) = g_data_set_id;

      If g_bvid_to_reverse is NOT NULL then

         forall i in t_source_id_int_1.FIRST..t_source_id_int_1.LAST
            Update pa_budget_lines
            set    bc_rev_event_id      = t_event_id(i)
            where  budget_version_id    = t_source_id_int_1(i)
            and    start_date           = t_event_date(i)
            and    t_source_id_int_1(i) = g_bvid_to_reverse;

       End If;

   End If; --If t_event_id.EXISTS(1) then

End Tieback_budget_event;

-- -------------------------------------------------------------------+
-- This procedure will update event_id on the source tables
-- Called during commitment processing ...
-- -------------------------------------------------------------------+
Procedure Tieback_enc_event
is
   PRAGMA AUTONOMOUS_TRANSACTION;
Begin

   If t_event_id.EXISTS(1) then
      IF g_debug_mode = 'Y' THEN
         pa_debug.g_err_stage:= 'Tieback_enc_event: Process FC';
         pa_debug.write('create_events ' || g_debug_module,pa_debug.g_err_stage, g_debug_level5);
      END IF;


      forall i in t_event_id.FIRST..t_event_id.LAST
             Update pa_bc_packets pb
             set    pb.bc_event_id      = t_event_id(i)
             where  pb.packet_id        = g_data_set_id
             and    pb.source_event_id  = t_source_event_id(i)
             and    pb.status_code      = 'I'
             and    pb.ext_bdgt_flag    = 'Y';
             --and    pb.burden_method_code in ('S','D')
             --and    pb.bc_event_id is null;

   End If; --If t_event_id.EXISTS(1) then

 COMMIT;

End tieback_enc_event;
-- ---------------------------------------------------------------------------------+
-- ENCUMBRANCE RELATED CHANGES ENDS HERE ...
-- ---------------------------------------------------------------------------------+

  /*
   * The following API is to be used by Post Accounting Programs.
   */

  FUNCTION Get_Post_Acc_Sla_Ccid(
                         P_Acct_Event_Id              IN PA_Cost_Distribution_Lines_All.Acct_Event_Id%TYPE
                        ,P_Transfer_Status_Code       IN PA_Cost_Distribution_Lines_All.Transfer_Status_Code%TYPE
                        ,P_Transaction_Source         IN PA_Expenditure_Items_All.Transaction_Source%TYPE
                        ,P_Historical_Flag            IN PA_Expenditure_Items_All.Historical_Flag%TYPE
                        ,P_Distribution_Id_1          IN XLA_Distribution_Links.Source_Distribution_Id_Num_1%TYPE
                        ,P_Distribution_Id_2          IN XLA_Distribution_Links.Source_Distribution_Id_Num_2%TYPE
                        ,P_Distribution_Type          IN VARCHAR2
                        ,P_Ccid                       IN PA_Cost_Distribution_Lines_All.Dr_Code_Combination_Id%TYPE DEFAULT NULL
                        ,P_Account_Type               IN VARCHAR2 DEFAULT 'DEBIT'
                        ,P_Ledger_Id                  IN PA_Implementations_All.Set_Of_Books_Id%TYPE
                       )
    RETURN NUMBER
    IS
	l_application_id               XLA_Distribution_Links.Application_Id%TYPE;
	l_ccid                         PA_Cost_Distribution_Lines_All.Dr_Code_Combination_Id%TYPE;
	l_Source_Distribution_Id_Num_1 XLA_Distribution_Links.Source_Distribution_Id_Num_1%TYPE;
	l_Source_Distribution_Id_Num_2 XLA_Distribution_Links.Source_Distribution_Id_Num_2%TYPE;
        l_predefined_flag              PA_Transaction_Sources.Predefined_Flag%TYPE;
        l_acct_source_code             PA_Transaction_Sources.Acct_Source_Code%TYPE;
	l_Program_Code                 Xla_Post_Acct_Progs_b.Program_Code%TYPE;
	l_acct_event_id                XLA_Events.Event_ID%TYPE;
	l_transfer_status_code         PA_Cost_Distribution_Lines_All.transfer_status_code%TYPE;
	l_sys_ref5                     PA_Cost_Distribution_Lines_All.system_reference5%TYPE;
	l_document_distribution_id     PA_Expenditure_Items_All.document_distribution_id%TYPE;
	l_document_payment_id          PA_Expenditure_Items_All.document_payment_id%TYPE;
	l_distribution_type            Xla_Distribution_Links.Source_Distribution_Type%TYPE;
	l_payment_dist_lookup_code     varchar2(15);
    BEGIN

	l_predefined_flag := NULL;
	l_acct_source_code := NULL;
	l_sys_ref5         := NULL;
	l_acct_event_id    := P_Acct_Event_Id;
	l_transfer_status_code := P_Transfer_status_code;
	l_ccid             := P_ccid;
	l_document_distribution_id := NULL;
	l_document_payment_id  := NULL;
	l_distribution_type := p_distribution_type;

	-- Asset Generation capitalizes on 'I' lines. Since 'I' lines do not get accounted
	-- get the attributes required for the parent line. Parent Line Number is passed to
	-- p_distribution_id_2.

	if p_distribution_type = 'I' then
	   select cd.acct_event_id,
	          cd.transfer_status_code,
		  cd.dr_code_combination_id,
	          cd.system_reference5, -- for RCV this holds rcv_subledger_id
		  pe.document_distribution_id,
		  pe.document_payment_id
	     into l_acct_event_id,
	          l_transfer_status_code,
		  l_ccid,
		  l_sys_ref5,
	          l_document_distribution_id,
		  l_document_payment_id
	     from pa_cost_distribution_lines_all cd,
	          pa_expenditure_items_all pe
            where cd.expenditure_item_id = pe.expenditure_item_id
	      and cd.expenditure_item_id = p_distribution_id_1
	      and cd.line_num = p_distribution_id_2;

	      l_distribution_type := 'R';
	end if;

        IF (P_Transaction_Source IS NOT NULL)
        THEN
	    SELECT ts.Predefined_Flag, ts.Acct_Source_Code
	      INTO l_predefined_flag
	          ,l_acct_source_code
	      FROM PA_Transaction_Sources ts
             WHERE Transaction_Source = P_Transaction_Source;

	     -- AP_PAY is determined based on payment_id field being populated on
	     -- EI. This is true for Case Basis Accounting and "AP Discounts" in
	     -- Accrual basis accounting.
	     if l_predefined_flag = 'Y' and l_acct_source_code like 'AP%' then
	        if p_distribution_id_2 is not null then
		   l_acct_source_code := 'AP_PAY';
		end if;
                /* bug 5374040 if P_Transaction_Source = 'AP DISCOUNTS' then
		   l_acct_source_code := 'AP_INV';
		  end if;
		*/
	     end if;
	END IF;

        /*
	 * Determine Application_Id.
	 */
        IF ( l_Transfer_Status_Code = 'A' AND l_Acct_Event_Id IS NOT NULL )
	THEN
	     l_application_id := 275;
        END IF;
        IF ( l_Transfer_Status_Code = 'A' AND l_Acct_Event_Id IS NULL )
	THEN
	       RETURN l_ccid;
        END IF;
        IF ( l_Transfer_Status_Code = 'V' AND l_predefined_flag = 'N' )
	THEN
	    RETURN l_Ccid;
        END IF;
        IF ( l_Transfer_Status_Code = 'V' AND P_Historical_Flag = 'Y' AND l_predefined_flag = 'Y' )
	THEN
	    RETURN l_Ccid;
        END IF;
        IF ( l_Transfer_Status_Code = 'V' AND P_Historical_Flag = 'N' AND l_predefined_flag = 'Y' )
	THEN
	    l_application_id :=
	    CASE l_acct_source_code
	        WHEN 'AP_INV' THEN 200
	        WHEN 'AP_PAY' THEN 200
	        WHEN 'AP_APP' THEN 200
		WHEN 'INV'    THEN 707
		WHEN 'WIP'    THEN 707
		WHEN 'RCV'    THEN 707
                ELSE 0
	    END;
	   -- Source Distribution Type is determined based on the acct_source_code value.
	   -- These values are used in the join with xla_distribution_links. This is
	   -- overriding the input parameter for distribution_type and is required only
	   -- in case of 'V' lines.
	   if l_acct_source_code = 'AP_PAY' then
	      l_distribution_type := 'AP_PMT_DIST';
           elsif l_acct_source_code = 'AP_INV' then
	      l_distribution_type := 'AP_INV_DIST';
           elsif l_acct_source_code = 'AP_APP' then
	      l_distribution_type := 'AP_PREPAY';
           elsif l_acct_source_code = 'RCV' then
	      l_distribution_type := 'RCV_RECEIVING_SUB_LEDGER';
	   elsif l_acct_source_code = 'INV' then
	      l_distribution_type := 'MTL_TRANSACTION_ACCOUNTS';
           elsif l_acct_source_code = 'WIP' then
	      l_distribution_type := 'WIP_TRANSACTION_ACCOUNTS';
	   end if;

        END IF;

	/*
	 * Determine the Distribution Identifiers.
	 */
	IF ( l_application_id = 275 )
	THEN
	    l_Source_Distribution_Id_Num_1 := P_Distribution_Id_1;
	    l_Source_Distribution_Id_Num_2 := P_Distribution_Id_2;
        END IF;

	IF ( l_acct_source_code = 'AP_INV' AND l_application_id = 200 )
	THEN
            l_Source_Distribution_Id_Num_1 := nvl(l_document_distribution_id, P_Distribution_Id_1);
        END IF;

	IF ( l_acct_source_code = 'AP_PAY' AND l_application_id = 200 )
	THEN
            l_Source_Distribution_Id_Num_1 := nvl(l_sys_ref5, P_Distribution_Id_1);
        END IF;

	IF ( l_acct_source_code IN ('INV', 'WIP') AND l_application_id = 707 )
	THEN
	    IF ( P_Account_Type = 'DEBIT' )
	    THEN
	        l_Source_Distribution_Id_Num_1 := nvl(l_sys_ref5, P_Distribution_Id_1);
            ELSE
	        l_Source_Distribution_Id_Num_1 := nvl(l_sys_ref5, P_Distribution_Id_1);
            END IF;
        END IF;

	IF ( l_acct_source_code = 'RCV'  AND l_application_id = 707 )
	THEN
	    IF ( P_Account_Type = 'DEBIT' )
	    THEN
	        l_Source_Distribution_Id_Num_1 := nvl(l_sys_ref5, P_Distribution_Id_1);
            ELSE
	        RETURN l_Ccid;
            END IF;
        END IF;

	IF ( P_Account_Type = 'DEBIT' )
	THEN
	    l_program_code := 'PA_POSTACCOUNTING_DEBIT';
        ELSE
	    l_program_code := 'PA_POSTACCOUNTING_CREDIT';
	END IF;

  SELECT code_combination_id
    into l_Ccid
    FROM xla_distribution_links xdl,
         xla_ae_headers aeh,
         xla_ae_lines ael,
         xla_acct_class_assgns xaca,
         xla_assignment_defns_b xad,
         xla_post_acct_progs_b xpap,
	 gl_ledgers gl
   WHERE xdl.source_distribution_id_num_1 = l_Source_Distribution_Id_Num_1
     AND NVL(xdl.source_distribution_id_num_2, -99) = to_number(NVL(l_Source_Distribution_Id_Num_2, -99)) /*Added to_number for bug 9407402*/
     AND xdl.source_distribution_type = l_distribution_type
     AND xdl.application_id = l_application_id
     AND xdl.ae_header_id =  aeh.ae_header_id
     AND xdl.ae_line_num = ael.ae_line_num
     AND xdl.ae_header_id = ael.ae_header_id
     AND aeh.application_id = ael.application_id
     AND ael.application_id = xdl.application_id
     AND aeh.balance_type_code = 'A'
     AND aeh.accounting_entry_status_code = 'F'
     AND aeh.ledger_id = P_Ledger_Id
     AND ael.accounting_class_code = xaca.accounting_class_code
     AND xaca.program_code = xad.program_code
     AND xaca.program_owner_code = xad.program_owner_code
     AND xad.program_code = xpap.program_code
     AND xpap.program_owner_code = 'S'
     AND xaca.assignment_code = xad.assignment_code
     AND xaca.assignment_owner_code = xad.assignment_owner_code
     AND (xad.ledger_id IS NULL OR xad.ledger_id = P_Ledger_Id)
     AND xad.enabled_flag = 'Y'
     AND gl.ledger_id = P_Ledger_Id
     AND xpap.program_code = DECODE ( xaca.accounting_class_code , 'DISCOUNT' ,
					DECODE( gl.sla_ledger_cash_basis_flag,
						'Y', DECODE ( P_Account_Type,
								'CREDIT', 'PA_POSTACCOUNTING_DEBIT',
								'DEBIT', ''
							     )
						,l_program_code )
				     ,l_program_code)
     	 /*
		Bug 5039683 For Cash Basis : Hard coded acc class 'Discount'
		and fetched from Debit side of post acc program 'PA_POSTACCOUNTING_DEBIT
		For R12+, this need be reverted out and create seperate post acc program
		for cash basis include 'Discount' in credit side and remove from Debit.
	 */
     AND xpap.application_id = 275
     and rownum = 1; -- Added for bug8496530

     RETURN l_ccid;
    EXCEPTION
        WHEN OTHERS THEN
            RAISE;
    END Get_Post_Acc_Sla_Ccid;

  /*
   * This function is used by the Extract Object View.
   */
  FUNCTION Get_Sla_Ccid( P_Application_Id    NUMBER
                        ,P_Distribution_Id_1 NUMBER
                        ,P_Distribution_Id_2 NUMBER
			,P_Distribution_Type XLA_Distribution_Links.SOURCE_DISTRIBUTION_TYPE%TYPE
                        ,P_Account_Type      VARCHAR2
                        ,P_Ledger_Id         NUMBER
                       )
  RETURN NUMBER
  IS
        l_Program_Code Xla_Post_Acct_Progs_b.Program_Code%TYPE;
	l_ccid         PA_Cost_Distribution_Lines_All.Dr_Code_Combination_Id%TYPE;
  BEGIN
      IF ( P_Account_Type = 'DEBIT' )
      THEN
          l_program_code := 'PA_POSTACCOUNTING_DEBIT';
      ELSE
          l_program_code := 'PA_POSTACCOUNTING_CREDIT';
      END IF;

      SELECT code_combination_id
        into l_ccid
        FROM XLA_Distribution_Links xdl,
             XLA_Ae_Headers aeh,
             XLA_Ae_Lines ael,
             XLA_Acct_Class_Assgns xaca,
             XLA_Assignment_Defns_b xad,
             XLA_Post_acct_Progs_b xpap,
	     gl_ledgers gl
       WHERE xdl.source_Distribution_id_num_1 = P_Distribution_Id_1
         AND NVL(xdl.source_Distribution_id_num_2, -99) = to_number(NVL(P_Distribution_Id_2 , -99)) /*Added to_number for bug 9407402*/
         AND xdl.Source_Distribution_Type = P_Distribution_Type
         AND xdl.application_id = P_Application_Id
         AND xdl.ae_header_id =  aeh.ae_header_id
         AND xdl.ae_line_num = ael.ae_line_num
         AND xdl.ae_header_id = ael.ae_header_id
         AND aeh.application_id = ael.application_id
         AND ael.application_id = xdl.application_id
         AND aeh.balance_type_code = 'A'
         AND aeh.accounting_entry_status_code = 'F'
         AND aeh.ledger_id = P_Ledger_Id
         AND ael.accounting_class_code = xaca.accounting_class_code
         AND xaca.program_code = xad.program_code
         AND xaca.program_owner_code = xad.program_owner_code
         AND xad.program_code = xpap.program_code
         AND xpap.program_owner_code = 'S'
         AND xaca.assignment_code = xad.assignment_code
         AND xaca.assignment_owner_code = xad.assignment_owner_code
         AND (xad.ledger_id IS NULL OR xad.ledger_id = P_Ledger_Id)
         AND xad.enabled_flag = 'Y'
	 AND gl.ledger_id = P_Ledger_Id
         AND xpap.program_code = DECODE ( xaca.accounting_class_code , 'DISCOUNT' ,
					DECODE( gl.sla_ledger_cash_basis_flag,
						'Y', DECODE ( P_Account_Type,
								'CREDIT', 'PA_POSTACCOUNTING_DEBIT',
								'DEBIT', ''
							     )
						,l_program_code )
				     ,l_program_code)
	 /*
		Bug 5039683 For Cash Basis : Hard coded acc class 'Discount'
		and fetched from Debit side of post acc program 'PA_POSTACCOUNTING_DEBIT
		For R12+, this need be reverted out and create seperate post acc program
		for cash basis include 'Discount' in credit side and remove from Debit.
	 */
         AND xpap.application_id = 275
         and rownum = 1; -- Added for bug8496530

	 RETURN l_ccid;

  EXCEPTION
      WHEN TOO_MANY_ROWS THEN
         RETURN NULL;   -- Process gracefully, create accounting will skip the transaction.
      WHEN NO_DATA_FOUND THEN
         RETURN NULL;   -- Process gracefully, create accounting will skip the transaction.
      WHEN OTHERS THEN
          RAISE;
  END Get_Sla_Ccid;


END PA_XLA_INTERFACE_PKG;

/
