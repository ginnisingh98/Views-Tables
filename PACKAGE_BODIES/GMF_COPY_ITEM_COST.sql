--------------------------------------------------------
--  DDL for Package Body GMF_COPY_ITEM_COST
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."GMF_COPY_ITEM_COST" AS
/* $Header: gmfcpicb.pls 120.12.12010000.6 2010/02/05 12:41:21 vpedarla ship $ */
/*****************************************************************************
 *  PACKAGE
 *    gmf_copy_item_cost
 *
 *  DESCRIPTION
 *    Copy Item Costs Package
 *
 *  CONTENTS
 *    PROCEDURE copy_item_cost ( ... )
 *
 *  HISTORY
 *    13-Oct-1999 Rajesh Seshadri
 *    21-Nov-2000 Uday Moogala - Bug# 1419482 Copy Cost Enhancement.
 *      Add last 6 new parameters.
 *    24-Jan-2002 Chetan Nagar - B2198228 Added paramter copy_to_upper_lvl
 *      for enhancement fix related to cost rollup (Ref. Bug 2116142).
 *    30/Oct/2002  R.Sharath Kumar    Bug# 2641405
 *      Added NOCOPY hint
 ******************************************************************************/


PROCEDURE end_copy (
        pi_errstat      IN VARCHAR2,
        pi_errmsg       IN VARCHAR2
        );

PROCEDURE copy_cost_dtl(
        pi_organization_id_from    IN cm_cmpt_dtl.organization_id%TYPE,
        pi_calendar_code_from      IN cm_cmpt_dtl.calendar_code%TYPE,
        pi_period_code_from        IN cm_cmpt_dtl.period_code%TYPE,
        pi_cost_type_id_from       IN cm_cmpt_dtl.cost_type_id%TYPE,
        pi_organization_id_to      IN cm_cmpt_dtl.organization_id%TYPE,
        pi_calendar_code_to        IN cm_cmpt_dtl.calendar_code%TYPE,
        pi_period_code_to          IN cm_cmpt_dtl.period_code%TYPE,
        pi_cost_type_id_to         IN cm_cmpt_dtl.cost_type_id%TYPE,
        pi_range_type              IN NUMBER,
        pi_from_range              IN VARCHAR2,
        pi_to_range                IN VARCHAR2,
        pi_incr_pct                IN NUMBER,
        pi_incr_decr_cost          IN NUMBER,
        pi_rem_repl                IN NUMBER,
        pi_all_periods_from        IN cm_cmpt_dtl.period_code%TYPE,
        pi_all_periods_to          IN cm_cmpt_dtl.period_code%TYPE,
        pi_all_org_id              IN gmf_legal_entities.legal_entity_id%TYPE,
        pi_copy_to_upper_lvl       IN NUMBER
        );




PROCEDURE copy_burden_dtl(
        pi_organization_id_from    IN cm_cmpt_dtl.organization_id%TYPE,
        pi_calendar_code_from      IN cm_cmpt_dtl.calendar_code%TYPE,
        pi_period_code_from        IN cm_cmpt_dtl.period_code%TYPE,
        pi_cost_type_id_from       IN cm_cmpt_dtl.cost_type_id%TYPE,
        pi_organization_id_to      IN cm_cmpt_dtl.organization_id%TYPE,
        pi_calendar_code_to        IN cm_cmpt_dtl.calendar_code%TYPE,
        pi_period_code_to          IN cm_cmpt_dtl.period_code%TYPE,
        pi_cost_type_id_to         IN cm_cmpt_dtl.cost_type_id%TYPE,
        pi_range_type              IN NUMBER,
        pi_from_range              IN VARCHAR2,
        pi_to_range                IN VARCHAR2,
        pi_rem_repl                IN NUMBER,
        pi_all_periods_from        IN cm_cmpt_dtl.period_code%TYPE,
        pi_all_periods_to          IN cm_cmpt_dtl.period_code%TYPE,
        pi_all_org_id              IN gmf_legal_entities.legal_entity_id%TYPE
        );




PROCEDURE delete_item_costs(
        pi_inventory_item_id    IN cm_cmpt_dtl.inventory_item_id%TYPE,
        pi_organization_id      IN cm_cmpt_dtl.organization_id%TYPE,
        pi_calendar_code        IN cm_cmpt_dtl.calendar_code%TYPE,
        pi_period_id            IN cm_cmpt_dtl.period_id%TYPE,
        pi_cost_type_id         IN cm_cmpt_dtl.cost_type_id%TYPE
        );


FUNCTION verify_frozen_costs(
        pi_inventory_item_id            IN cm_cmpt_dtl.inventory_item_id%TYPE,
        pi_organization_id      IN cm_cmpt_dtl.organization_id%TYPE,
        pi_calendar_code        IN cm_cmpt_dtl.calendar_code%TYPE,
        pi_period_id            IN cm_cmpt_dtl.period_id%TYPE,
        pi_cost_type_id IN cm_cmpt_dtl.cost_type_id%TYPE
        )
RETURN NUMBER;

-- added this procedure as part of bug 5567102
PROCEDURE verify_frozen_periods (p_period_id IN gmf_period_statuses.period_id%TYPE,
                                 p_period_code OUT NOCOPY gmf_period_statuses.period_code%TYPE,
                                 p_period_status OUT NOCOPY gmf_period_statuses.period_status%TYPE );

-- Added to check record exists in a frozen period, bug 5672543
FUNCTION check_rec_infrozen_period(p_organization_id   cm_cmpt_dtl.organization_id%TYPE,
                                   p_inventory_item_id cm_cmpt_dtl.inventory_item_id%TYPE,
                                   p_period_id         cm_cmpt_dtl.period_id%TYPE,
                                   p_cost_type_id      cm_cmpt_dtl.cost_type_id%TYPE)
RETURN BOOLEAN ;
FUNCTION verify_item_assigned_to_org(
        pi_inventory_item_id    IN cm_cmpt_dtl.inventory_item_id%TYPE,
        pi_organization_id      IN cm_cmpt_dtl.organization_id%TYPE
   )
RETURN NUMBER;

PROCEDURE delete_burden_costs(
        pi_organization_id    IN cm_cmpt_dtl.organization_id%TYPE,
        pi_period_id          IN cm_cmpt_dtl.period_id%TYPE,
        pi_cost_type_id       IN cm_cmpt_dtl.cost_type_id%TYPE,
        pi_range_type         IN NUMBER,
        pi_from_range         IN VARCHAR2,
        pi_to_range           IN VARCHAR2
        );

-- Static type indicators
G_ITEM          NUMBER := 1;
G_ITEMCC        NUMBER := 2;

-- WHO columns
g_user_id       NUMBER;
g_login_id      NUMBER;
g_prog_appl_id  NUMBER;
g_program_id    NUMBER;
g_request_id    NUMBER;
g_effid_copy    VARCHAR2(2) ;

/*****************************************************************************
 *  PROCEDURE
 *    copy_item_cost
 *
 *  DESCRIPTION
 *    Copy Item Costs Procedure
 *      Copies costs from the one set of orgn/cost calendar/period/cost method
 *      to another for the item OR item cost class range specified on the form.
 *
 *  INPUT PARAMETERS
 *      From and To organization_id/calendar/period/cost method
 *      Item from/to range
 *      Item cost class from/to range
 *      Increase or Decrease Cost Percentage
 *      Increase or Decrease Cost Amount
 *      Remove before copy or Replace during copy indicator
 *
 *  OUTPUT PARAMETERS
 *      po_errbuf               Completion message to the Concurrent Manager
 *      po_retcode              Return code to the Concurrent Manager
 *
 *  HISTORY
 *    13-Oct-1999 Rajesh Seshadri
 *    21-Nov-2000 Uday Moogala - Bug# 1419482 Copy Cost Enhancement.
 *
 *    24-Jan-2002 Chetan Nagar - B2198228 Added paramter copy_to_upper_lvl
 *      for enhancement fix related to cost rollup (Ref. Bug 2116142).
 ******************************************************************************/

PROCEDURE copy_item_cost
(
po_errbuf                     OUT  NOCOPY  VARCHAR2,
po_retcode                    OUT  NOCOPY  VARCHAR2,
pi_organization_id_from       IN   cm_cmpt_dtl.organization_id%TYPE,
pi_calendar_code_from         IN   cm_cmpt_dtl.calendar_code%TYPE,
pi_period_code_from           IN   cm_cmpt_dtl.period_code%TYPE,
pi_cost_type_id_from          IN   cm_cmpt_dtl.cost_type_id%TYPE,
pi_organization_id_to         IN   cm_cmpt_dtl.organization_id%TYPE,
pi_calendar_code_to           IN   cm_cmpt_dtl.calendar_code%TYPE,
pi_period_code_to             IN   cm_cmpt_dtl.period_code%TYPE,
pi_cost_type_id_to            IN   cm_cmpt_dtl.cost_type_id%TYPE,
pi_item_from                  IN   mtl_system_items_b_kfv.concatenated_segments%TYPE,
pi_item_to                    IN   mtl_system_items_b_kfv.concatenated_segments%TYPE,
pi_itemcc_from                IN   mtl_categories_b_kfv.concatenated_segments%TYPE,
pi_itemcc_to                  IN   mtl_categories_b_kfv.concatenated_segments%TYPE,
pi_incr_pct                   IN   VARCHAR2,
pi_incr_decr_cost             IN   VARCHAR2,
pi_rem_repl                   IN   VARCHAR2,
pi_all_periods_from           IN   cm_cmpt_dtl.period_code%TYPE,
pi_all_periods_to             IN   cm_cmpt_dtl.period_code%TYPE,
pi_all_org_id                 IN   gmf_legal_entities.legal_entity_id%TYPE,
pi_copy_to_upper_lvl          IN   VARCHAR2
)
IS

   l_from_range          VARCHAR2(32767);
   l_to_range            VARCHAR2(32767);
   l_range_type          NUMBER;
   l_effid_copy          VARCHAR2(4) ;

        l_rem_repl            NUMBER;
        l_incr_pct            NUMBER;
        l_incr_decr_cost      NUMBER;
        l_copy_to_upper_lvl   NUMBER;
        e_same_from_to        EXCEPTION;
        e_no_cost_rows        EXCEPTION;

BEGIN

        /* uncomment the call below to write to a local file */
        FND_FILE.PUT_NAMES('gmfcpic.log','gmfcpic.out','/appslog/opm_top/utl/opmm0dv/log');


        gmf_util.msg_log( 'GMF_CPIC_START' );

        gmf_util.msg_log( 'GMF_CPIC_SRCPARAM', nvl(to_char(pi_organization_id_from), ' '), nvl(pi_calendar_code_from, ' '), nvl(pi_period_code_from, ' '), nvl(to_char(pi_cost_type_id_from), ' ') );

        gmf_util.msg_log( 'GMF_CPIC_TGTPARAM', nvl(to_char(pi_organization_id_to), ' '), nvl(pi_calendar_code_to, ' '), nvl(pi_period_code_to, ' '), nvl(to_char(pi_cost_type_id_to), ' ') );

        gmf_util.msg_log( 'GMF_CPIC_ITEMRANGE', nvl(pi_item_from, ' '), nvl(pi_item_to, ' ') );
        gmf_util.msg_log( 'GMF_CPIC_ITEMCCRANGE', nvl(pi_itemcc_from, ' '), nvl(pi_itemcc_to, ' ') );

        gmf_util.msg_log( 'GMF_CPIC_INCPCT', nvl(pi_incr_pct, ' ') );
        gmf_util.msg_log( 'GMF_CPIC_INCCOST', nvl(pi_incr_decr_cost, ' ') );

        -- Bug# 1419482 Copy Cost Enhancement. Uday Moogala
        IF ( (pi_period_code_to IS NULL) AND                 -- all periods
             ((pi_all_periods_from IS NOT NULL) OR (pi_all_periods_to IS NOT NULL))
           ) THEN

            gmf_util.msg_log('GMF_CPIC_ALLPERIODS', nvl(pi_calendar_code_to, ' ') ) ;
            gmf_util.msg_log('GMF_CPIC_PERIODS_RANGE', nvl(pi_all_periods_from, ' '),
                              nvl(pi_all_periods_to, ' '), nvl(pi_calendar_code_to, ' ') ) ;
        END IF ;

         -- End Bug# 1419482

        l_rem_repl := 0;
        IF ( pi_rem_repl = '1' ) THEN   -- Remove before copy
            l_rem_repl := 1;
            gmf_util.msg_log( 'GMF_CPIC_OPTREM' );
        ELSE                            -- Replace before copy
            l_rem_repl := 0;
            gmf_util.msg_log( 'GMF_CPIC_OPTREP' );
        END IF;

        -- B2198228
        l_copy_to_upper_lvl := 0;
        IF ( pi_copy_to_upper_lvl = '1' ) THEN
            -- Copy lower level cost from source to upper level at target
            l_copy_to_upper_lvl := 1;
            gmf_util.msg_log( 'GMF_CPIC_TO_UPPER_YES' );
        ELSE
            l_copy_to_upper_lvl := 0;
            gmf_util.msg_log( 'GMF_CPIC_TO_UPPER_NO' );
        END IF;

        gmf_util.log;

        IF ( (pi_period_code_from = pi_period_code_to) AND
                (pi_cost_type_id_from = pi_cost_type_id_to) AND
                (pi_calendar_code_from = pi_calendar_code_to) AND
                (pi_organization_id_from = pi_organization_id_to) ) THEN

                gmf_util.msg_log( 'GMF_CP_SAME_FROMTO' );
                RAISE e_same_from_to;
        END IF;

        -- Determine what kind of where clause needs to be concatenated
        -- depending on what options were sent in
        l_from_range    := NULL;
        l_to_range      := NULL;
        l_range_type    := G_ITEM;

        IF ( (pi_item_from IS NOT NULL) OR (pi_item_to IS NOT NULL) ) THEN
                l_from_range    := pi_item_from;
                l_to_range      := pi_item_to;
                l_range_type    := G_ITEM;
           gmf_util.trace( 'Range : ' || l_from_range || ' - ' || l_to_range, 1 );
        ELSIF ( (pi_itemcc_from IS NOT NULL) OR (pi_itemcc_to IS NOT NULL) ) THEN
                l_from_range    := pi_itemcc_from;
                l_to_range      := pi_itemcc_to;
                l_range_type    := G_ITEMCC;
           gmf_util.trace( 'Range : ' || l_from_range || ' - ' || l_to_range, 1 );
        ELSE
                l_from_range    := pi_item_from;
                l_to_range      := pi_item_to;
                l_range_type    := G_ITEM;
      gmf_util.trace( 'Range : ' || l_from_range || ' - ' || l_to_range, 1 );
        END IF;

        -- Set the increase or decrease percentage and cost
        IF( pi_incr_pct IS NOT NULL ) THEN
                l_incr_pct := 1.0 + TO_NUMBER(pi_incr_pct)/100.0 ;
        ELSE
                l_incr_pct := 1.0;
        END IF;
        IF( pi_incr_decr_cost IS NOT NULL ) THEN
                l_incr_decr_cost := TO_NUMBER(pi_incr_decr_cost);
        ELSE
                l_incr_decr_cost := 0.0;
        END IF;

        gmf_util.trace( ' Incr pct = ' || l_incr_pct || ' Incr/Decr Cost = ' ||l_incr_decr_cost, 1 );

        -- Initialize WHO columns
        g_user_id       := FND_GLOBAL.USER_ID;
        g_login_id      := FND_GLOBAL.LOGIN_ID;
        g_prog_appl_id  := FND_GLOBAL.PROG_APPL_ID;
        g_program_id    := FND_GLOBAL.CONC_PROGRAM_ID;
        g_request_id    := FND_GLOBAL.CONC_REQUEST_ID;

        -- Bug# 1419482 Copy Cost Enhancement. Uday Moogala

        BEGIN
          g_effid_copy := FND_PROFILE.VALUE('GMF_CPIC_EFF') ;
          SELECT decode(g_effid_copy, 'Y', 'YES', 'N', 'NO', '')
            INTO l_effid_copy
            FROM dual ;
          gmf_util.msg_log('GMF_CPIC_EFFID', l_effid_copy ) ; --niyadav

        EXCEPTION
         WHEN OTHERS THEN
                l_effid_copy := 'N' ;
                gmf_util.msg_log('GMF_CPIC_EFFID', l_effid_copy) ;
   END ;

        -- End Bug# 1419482

      -- Houston, do you copy?
      copy_cost_dtl
      (
      pi_organization_id_from, pi_calendar_code_from,
      pi_period_code_from, pi_cost_type_id_from,
      pi_organization_id_to, pi_calendar_code_to,
      pi_period_code_to, pi_cost_type_id_to,
      l_range_type, l_from_range, l_to_range,
      l_incr_pct,l_incr_decr_cost,l_rem_repl,
      pi_all_periods_from, pi_all_periods_to,
      pi_all_org_id, l_copy_to_upper_lvl
      );
                -- Copy that, Roger!


        -- All is well
        po_retcode := 0;
        po_errbuf := NULL;
        end_copy( 'NORMAL', NULL );
        COMMIT;

        gmf_util.log;
        gmf_util.msg_log( 'GMF_CPIC_END' );

EXCEPTION
        WHEN e_no_cost_rows THEN
                po_retcode := 0;
                po_errbuf := NULL;
                end_copy( 'NORMAL', NULL );

        WHEN e_same_from_to THEN
                po_retcode := 0;
                po_errbuf := NULL;
                end_copy( 'NORMAL', NULL );

        WHEN utl_file.invalid_path then
                po_retcode := 3;
                po_errbuf := 'Invalid path - '||to_char(SQLCODE) || ' ' || SQLERRM;
                end_copy ('ERROR', NULL);

        WHEN utl_file.invalid_mode then
                po_retcode := 3;
                po_errbuf := 'Invalid Mode - '||to_char(SQLCODE) || ' ' || SQLERRM;
                end_copy ('ERROR', NULL);

        WHEN utl_file.invalid_filehandle then
                po_retcode := 3;
                po_errbuf := 'Invalid filehandle - '||to_char(SQLCODE) || ' ' || SQLERRM;
                end_copy ('ERROR', NULL);

        WHEN utl_file.invalid_operation then
                po_retcode := 3;
                po_errbuf := 'Invalid operation - '||to_char(SQLCODE) || ' ' || SQLERRM;
                end_copy ('ERROR', NULL);

        WHEN utl_file.write_error then
                po_retcode := 3;
                po_errbuf := 'Write error - '||to_char(SQLCODE) || ' ' || SQLERRM;
                end_copy ('ERROR', NULL);
        WHEN others THEN
                po_retcode := 3;
                po_errbuf := to_char(SQLCODE) || ' ' || SQLERRM;
                end_copy ('ERROR', po_errbuf);
END copy_item_cost;

/*****************************************************************************
 *  PROCEDURE
 *    copy_cost_dtl
 *
 *  DESCRIPTION
 *    Copies item costs from source to target period
 *
 *  INPUT PARAMETERS
 *    From: organization_id, calendar_code, period_code, cost_mthd_code
 *    To  : organization_id, calendar_code, period_code, cost_mthd_code
 *    Range_Type: whether item or itemcost_class was specified by user
 *    From_Range, To_Range : from/to range or item/itemcost_class
 *    Increase_percentage: % by which costs have to be increased before copy
 *    Increase/Decrease cost: increase or decrease of cost before copy
 *    Remove_or_Replace indicator: Either costs in target period have to be
 *      removed before copy starts or just replace the existing rows
 *
 *  HISTORY
 *    13-Oct-1999 Rajesh Seshadri
 *    09-Nov-1999 Rajesh Seshadri Bug 1069117 - The delete stmt should not be
 *      run again and again for the same item.  Otherwise it will write only
 *      the last component row that is selected for copy
 *    21-Nov-2000 Uday Moogala - Bug# 1419482 Copy Cost Enhancement :
 *       Copy to all periods and/or warehouses option
 *
 *    24-Jan-2002 Chetan Nagar - B2198228 Added paramter copy_to_upper_lvl
 *      for enhancement fix related to cost rollup (Ref. Bug 2116142).
 *    27-Oct-2006 prasad marada Bug 5567156, 5567102. Not allowing to delete/update
 *                              the cost for frozen periods.
 *    24-Apr-2007 Prasad Marada BUg 5672543 Added call to check records in frozen
 *                period. In a frozen period existing costs not be changed during a copy.
 *                But New costs can be added though,
 ******************************************************************************/

PROCEDURE copy_cost_dtl(
        pi_organization_id_from    IN cm_cmpt_dtl.organization_id%TYPE,
        pi_calendar_code_from      IN cm_cmpt_dtl.calendar_code%TYPE,
        pi_period_code_from        IN cm_cmpt_dtl.period_code%TYPE,
        pi_cost_type_id_from       IN cm_cmpt_dtl.cost_type_id%TYPE,
        pi_organization_id_to      IN cm_cmpt_dtl.organization_id%TYPE,
        pi_calendar_code_to        IN cm_cmpt_dtl.calendar_code%TYPE,
        pi_period_code_to          IN cm_cmpt_dtl.period_code%TYPE,
        pi_cost_type_id_to         IN cm_cmpt_dtl.cost_type_id%TYPE,
        pi_range_type              IN NUMBER,
        pi_from_range              IN VARCHAR2,
        pi_to_range                IN VARCHAR2,
        pi_incr_pct                IN NUMBER,
        pi_incr_decr_cost          IN NUMBER,
        pi_rem_repl                IN NUMBER,
        pi_all_periods_from        IN cm_cmpt_dtl.period_code%TYPE,
        pi_all_periods_to          IN cm_cmpt_dtl.period_code%TYPE,
        pi_all_org_id              IN gmf_legal_entities.legal_entity_id%TYPE,
        pi_copy_to_upper_lvl       IN NUMBER
        )
IS

        TYPE rectyp_cost_detail IS RECORD (
                cmpntcost_id                cm_cmpt_dtl.cmpntcost_id%TYPE,
                inventory_item_id           cm_cmpt_dtl.inventory_item_id%TYPE,
                cost_cmpntcls_id            cm_cmpt_dtl.cost_cmpntcls_id%TYPE,
                cost_analysis_code          cm_cmpt_dtl.cost_analysis_code%TYPE,
                cost_level                  cm_cmpt_dtl.cost_level%TYPE,
                cmpnt_cost                  cm_cmpt_dtl.cmpnt_cost%TYPE,
                burden_ind                  cm_cmpt_dtl.burden_ind%TYPE,
                total_qty                   cm_cmpt_dtl.total_qty%TYPE,
                rmcalc_type                 cm_cmpt_dtl.rmcalc_type%TYPE,
                fmeff_id                    cm_cmpt_dtl.fmeff_id%TYPE,
                text_code                   cm_cmpt_dtl.text_code%TYPE,
                attribute1                  cm_cmpt_dtl.attribute1%TYPE,
                attribute2                  cm_cmpt_dtl.attribute2%TYPE,
                attribute3                  cm_cmpt_dtl.attribute3%TYPE,
                attribute4                  cm_cmpt_dtl.attribute4%TYPE,
                attribute5                  cm_cmpt_dtl.attribute5%TYPE,
                attribute6                  cm_cmpt_dtl.attribute6%TYPE,
                attribute7                  cm_cmpt_dtl.attribute7%TYPE,
                attribute8                  cm_cmpt_dtl.attribute8%TYPE,
                attribute9                  cm_cmpt_dtl.attribute9%TYPE,
                attribute10                 cm_cmpt_dtl.attribute10%TYPE,
                attribute11                 cm_cmpt_dtl.attribute11%TYPE,
                attribute12                 cm_cmpt_dtl.attribute12%TYPE,
                attribute13                 cm_cmpt_dtl.attribute13%TYPE,
                attribute14                 cm_cmpt_dtl.attribute14%TYPE,
                attribute15                 cm_cmpt_dtl.attribute15%TYPE,
                attribute16                 cm_cmpt_dtl.attribute16%TYPE,
                attribute17                 cm_cmpt_dtl.attribute17%TYPE,
                attribute18                 cm_cmpt_dtl.attribute18%TYPE,
                attribute19                 cm_cmpt_dtl.attribute19%TYPE,
                attribute20                 cm_cmpt_dtl.attribute20%TYPE,
                attribute21                 cm_cmpt_dtl.attribute21%TYPE,
                attribute22                 cm_cmpt_dtl.attribute22%TYPE,
                attribute23                 cm_cmpt_dtl.attribute23%TYPE,
                attribute24                 cm_cmpt_dtl.attribute24%TYPE,
                attribute25                 cm_cmpt_dtl.attribute25%TYPE,
                attribute26                 cm_cmpt_dtl.attribute26%TYPE,
                attribute27                 cm_cmpt_dtl.attribute27%TYPE,
                attribute28                 cm_cmpt_dtl.attribute28%TYPE,
                attribute29                 cm_cmpt_dtl.attribute29%TYPE,
                attribute30                 cm_cmpt_dtl.attribute30%TYPE
        );

        TYPE curtyp_cost_detail IS REF CURSOR;
        cv_cost_detail  curtyp_cost_detail;

        TYPE curtyp_periods IS REF CURSOR;
        cv_periods      curtyp_periods;

        TYPE curtyp_org IS REF CURSOR;
        cv_org          curtyp_org;

        r_cost_detail           rectyp_cost_detail;


        l_sql_stmt              VARCHAR2(2000);
        l_sql_org               VARCHAR2(2000) ;
        l_sql_periods           VARCHAR2(2000) ;
        l_org_id                gmf_legal_entities.legal_entity_id%TYPE ;
        l_organization_id_from  cm_cmpt_dtl.organization_id%TYPE;
        l_organization_id_to    cm_cmpt_dtl.organization_id%TYPE;

        l_period_id_to          cm_cmpt_dtl.period_id%TYPE;

        l_from_range            VARCHAR2(32767);
        l_to_range              VARCHAR2(32767);

        l_rem_repl              NUMBER;
        l_incr_pct              NUMBER;
        l_incr_decr_cost        NUMBER;

        l_curr_inventory_item_id  cm_cmpt_dtl.inventory_item_id%TYPE;
        l_curr_organization_id    cm_cmpt_dtl.organization_id%TYPE;
        l_curr_period_code        cm_cmpt_dtl.period_code%TYPE;
        l_frozen_flag           NUMBER;
        l_assigned_flag         NUMBER;

        l_curr_inventory_item_id2  cm_cmpt_dtl.inventory_item_id%TYPE;
        l_curr_organization_id2    cm_cmpt_dtl.organization_id%TYPE;
        l_curr_period_code2        cm_cmpt_dtl.period_code%TYPE;

        l_cost_rows             NUMBER;
        l_cost_rows_upd         NUMBER;
        l_cost_rows_ins         NUMBER;
        l_cost_rows_skip        NUMBER;
         -- bug 5567102
        l_period_code   gmf_period_statuses.period_code%TYPE;
        l_period_status gmf_period_statuses.period_status%TYPE;

        l_copy_to_upper_lvl  NUMBER;

        pi_period_id_to      NUMBER;
        pi_period_id_from    NUMBER;

        --e_same_from_to     EXCEPTION;
        e_item_is_frozen     EXCEPTION;
        e_item_not_assigned  EXCEPTION;
        e_period_frozen      EXCEPTION;
        --e_no_cost_rows     EXCEPTION;



BEGIN

--finding the valus of period_id based upon the parameter values passed.

     if(pi_period_code_to is not null) then
        if(pi_organization_id_to is not null) then
          SELECT        gps.period_id
           INTO         pi_period_id_to
           FROM         gmf_period_statuses gps, hr_organization_information org
           WHERE    gps.PERIOD_CODE = pi_period_code_to
           AND      gps.CALENDAR_CODE = pi_calendar_code_to
           AND      gps.legal_entity_id = org.org_information2
           AND      org.organization_id =  pi_organization_id_to
           AND      org.org_information_context = 'Accounting Information'
           AND      gps.cost_type_id = pi_cost_type_id_to;
      else
          SELECT        period_id
           INTO         pi_period_id_to
           FROM         gmf_period_statuses
           WHERE    PERIOD_CODE = pi_period_code_to
           AND      CALENDAR_CODE = pi_calendar_code_to
           AND      legal_entity_id = pi_all_org_id
           AND      cost_type_id = pi_cost_type_id_to;
      end if;
    else
     pi_period_id_to := NULL;
    end if;

        SELECT  gps.period_id
        INTO    pi_period_id_from
        FROM    gmf_period_statuses gps, hr_organization_information org
        WHERE   gps.PERIOD_CODE = pi_period_code_from
        AND     gps.CALENDAR_CODE = pi_calendar_code_from
        AND     gps.legal_entity_id = org.org_information2
        AND     org.organization_id = pi_organization_id_from
        AND     org.org_information_context = 'Accounting Information'
        AND     gps.cost_type_id = pi_cost_type_id_from;


        -- Set the input values
        l_rem_repl              := pi_rem_repl;
        l_incr_pct              := pi_incr_pct;
        l_incr_decr_cost        := pi_incr_decr_cost;

        l_copy_to_upper_lvl     := pi_copy_to_upper_lvl;

--      l_sql_stmt := '';
        l_sql_stmt :=
           ' SELECT ' ||
                'cst.cmpntcost_id,' ||
                'cst.inventory_item_id,' ||
                'cst.cost_cmpntcls_id,' ||
                'cst.cost_analysis_code,' ||
                'cst.cost_level,' ||
                'cst.cmpnt_cost,' ||
                'cst.burden_ind,' ||
                'cst.total_qty,' ||
                'cst.rmcalc_type,' ||
                'cst.fmeff_id,' ||
                'cst.text_code,' ||
                'cst.attribute1,' ||
                'cst.attribute2,' ||
                'cst.attribute3,' ||
                'cst.attribute4,' ||
                'cst.attribute5,' ||
                'cst.attribute6,' ||
                'cst.attribute7,' ||
                'cst.attribute8,' ||
                'cst.attribute9,' ||
                'cst.attribute10,' ||
                'cst.attribute11,' ||
                'cst.attribute12,' ||
                'cst.attribute13,' ||
                'cst.attribute14,' ||
                'cst.attribute15,' ||
                'cst.attribute16,' ||
                'cst.attribute17,' ||
                'cst.attribute18,' ||
                'cst.attribute19,' ||
                'cst.attribute20,' ||
                'cst.attribute21,' ||
                'cst.attribute22,' ||
                'cst.attribute23,' ||
                'cst.attribute24,' ||
                'cst.attribute25,' ||
                'cst.attribute26,' ||
                'cst.attribute27,' ||
                'cst.attribute28,' ||
                'cst.attribute29,' ||
                'cst.attribute30 ' ||
        ' FROM ' ||
                'cm_cmpt_dtl cst' ||
        ' WHERE ' ||
                'cst.organization_id            = :b_organization_id AND ' ||
      'cst.period_id    = :b_period_id AND ' ||
                'cst.cost_type_id       = :b_cost_type_id '; -- AND ' ||
--              'cst.delete_mark        = 0 ';--AND ' ||  bug 5567156
--              'itm.delete_mark        = 0 ';

        -- Determine what kind of where clause needs to be concatenated
        -- depending on what options were sent in
        l_from_range    := NULL;
        l_to_range      := NULL;

        IF ( pi_range_type = G_ITEM ) THEN

                l_sql_stmt := l_sql_stmt ||
            ' AND exists ( '||
            ' select ''z'' from MTL_ITEM_FLEXFIELDS x'||
            ' where x.organization_id = cst.organization_id '||
            ' and x.item_number between :pi_from_range and :pi_to_range '||
            ' and x.inventory_item_id = cst.inventory_item_id )';

                l_from_range    := pi_from_range;
                l_to_range      := pi_to_range;

        ELSIF ( pi_range_type = G_ITEMCC ) THEN

                l_sql_stmt := l_sql_stmt ||
                    'AND EXISTS (select  ''X'' from mtl_default_category_sets mdc, mtl_category_sets mcs, mtl_item_categories y, mtl_categories_kfv z '||
                    ' where mdc.functional_area_id = 19 '||
                              ' and mdc.category_set_id = mcs.category_set_id '||
                              ' and mcs.category_set_id = y.category_set_id '||
                    ' and mcs.structure_id = z.structure_id '||
                    ' and y.inventory_item_id = cst.inventory_item_id '||
                    ' and y.organization_id = cst.organization_id '||
                    ' and y.category_id = z.category_id '||
                    ' and z.concatenated_segments >= nvl(:b_from_itemcc, z.concatenated_segments) '||
                    ' and z.concatenated_segments <= nvl(:b_to_itemcc, z.concatenated_segments))';

              l_from_range   := pi_from_range;
                l_to_range   := pi_to_range;
        END IF;

        -- Bug# 1419482 Copy Cost Enhancement. Uday Moogala

        l_sql_stmt := l_sql_stmt ||
                ' ORDER BY ' ||
                        'cst.cost_type_id, ' ||
                        'cst.inventory_item_id, ' ||
                        'cst.organization_id, ' ||
                        'cst.cost_cmpntcls_id, ' ||
                        'cst.cost_analysis_code, ' ||
                        'cst.cost_level ' ;


        gmf_util.trace( 'Range : ' || l_from_range || ' - ' || l_to_range, 0 );

        gmf_util.trace( 'Item details Query : ' || l_sql_stmt, 3 );


        -- get org_id for the target calendar


        IF (pi_organization_id_to IS NOT NULL) THEN

                l_sql_org := '' ;

        l_sql_org := 'SELECT :pi_organization_id_to '||' FROM  dual ' ;

        ELSE

                -- 'All Warehouse' option selected
                -- Build SQL to get target organization when from/to organization are not null.

                l_sql_org := '' ;

                l_sql_org :=
                'SELECT ' ||
                        'hoi.organization_id ' ||
                'FROM ' ||
                        'hr_organization_information hoi , mtl_parameters mp ' ||
                ' WHERE ' ||
                        'hoi.org_information2   = :pi_all_org_id  '||
         ' AND  hoi.org_information_context = ''Accounting Information'' '||
         ' AND  hoi.organization_id = mp.organization_id '||
         ' and  mp.process_enabled_flag = ''Y'' ' ;

                --
                -- We should AVOID copying on to source period and organization. So we should
                -- eliminate 'from organization' from the query only when copying to same period,
                -- same calendar and to all organizations. For all the other cases no need to check for
                -- this condition since from period is getting eliminated from all periods query.
                --

                IF ( (pi_calendar_code_from = pi_calendar_code_to) AND
                     (pi_period_id_to IS NOT NULL) AND
                     (pi_period_id_from = pi_period_id_to)
                   ) THEN
                 l_sql_org := l_sql_org  ||' AND hoi.organization_id <> :pi_organization_id_from ' ;

                END IF ;

       -- bug 5567528, pmarada added hoi as alias to orderby
                l_sql_org := l_sql_org || ' ORDER BY hoi.organization_id ' ;

        END If ;


        -- Build SQL to get target periods when From/To Periods are not null.

        IF (pi_period_id_to IS NOT NULL) THEN           -- copy to one period.

                l_sql_periods := 'SELECT :pi_period_id_to FROM  dual ' ;

        ELSE
                l_sql_periods := '' ;
         if(pi_organization_id_to is not null) then
           l_sql_periods :=  'SELECT  ' ||
                                     'c3.period_id ' ||
                            'FROM ' ||
                                     'gmf_period_statuses c3, gmf_period_statuses c2, gmf_period_statuses c1, hr_organization_information d ' ||
                            'WHERE ' ||
                                     'd.organization_id = :pi_organization_id_to AND '||
                                     'd.org_information_context = ''Accounting Information'' AND '||
                                     'c1.calendar_code = :pi_calendar_code_to AND ' ||
                                     'c1.period_code   = :pi_all_periods_from AND ' ||
                                     'c2.calendar_code = :pi_calendar_code_to AND ' ||
                                     'c2.period_code   = :pi_all_periods_to   AND ' ||
                                     'c3.calendar_code = :pi_calendar_code_to AND ' ||
                                     'c3.cost_type_id  = :pi_cost_type_id_to AND  ' ||
                                     'c2.cost_type_id  = c3.cost_type_id AND ' ||
                                     'c1.cost_type_id  = c2.cost_type_id AND ' ||
                                     'c3.legal_entity_id = d.org_information2 AND ' ||
                                     'c2.legal_entity_id = c3.legal_entity_id AND ' ||
                                     'c1.legal_entity_id = c2.legal_entity_id AND ' ||
                                     'c3.start_date >=   c1.start_date AND ' ||
                                     'c3.end_date <= c2.end_date AND ' ||
                                     'c3.period_status <> ''C'' ';
            else
                          l_sql_periods :=  'SELECT  ' ||
                                     'c3.period_id ' ||
                            'FROM ' ||
                                     'gmf_period_statuses c3, gmf_period_statuses c2, gmf_period_statuses c1 ' ||
                            'WHERE ' ||
                                     'c1.calendar_code = :pi_calendar_code_to AND ' ||
                                     'c1.period_code   = :pi_all_periods_from AND ' ||
                                     'c2.calendar_code = :pi_calendar_code_to AND ' ||
                                     'c2.period_code   = :pi_all_periods_to   AND ' ||
                                     'c3.calendar_code = :pi_calendar_code_to AND ' ||
                                     'c3.cost_type_id  = :pi_cost_type_id_to AND  ' ||
                                     'c2.cost_type_id  =  c3.cost_type_id AND ' ||
                                     'c1.cost_type_id  =  c2.cost_type_id AND ' ||
                                     'c3.legal_entity_id = :pi_all_org_id AND ' ||
                                     'c2.legal_entity_id = c3.legal_entity_id AND ' ||
                                     'c1.legal_entity_id = c2.legal_entity_id AND ' ||
                                     'c3.start_date >=   c1.start_date AND ' ||
                                     'c3.end_date <= c2.end_date AND ' ||
                                     'c3.period_status <> ''C'' ';
       end if;

  IF (pi_calendar_code_from = pi_calendar_code_to) THEN

                  l_sql_periods := l_sql_periods||'  AND c3.period_id <> :pi_period_id_from ';
                END IF ;

                l_sql_periods := l_sql_periods || ' ORDER BY c3.start_date' ;

        END IF ;  -- To Period code check

        gmf_util.trace( 'Org Query : ' || l_sql_org, 3 );
        gmf_util.trace( 'Periods Query : ' || l_sql_periods, 3 );

    IF (pi_period_id_to IS NOT NULL) THEN
         OPEN cv_periods FOR l_sql_periods
         USING pi_period_id_to;
    ELSIF (pi_calendar_code_from = pi_calendar_code_to) THEN
           if(pi_organization_id_to is not null) then
                OPEN cv_periods FOR l_sql_periods
                      USING pi_organization_id_to,
                        pi_calendar_code_to,
                             pi_all_periods_from,
                             pi_calendar_code_to,
                             pi_all_periods_to,
                        pi_calendar_code_to,
                        pi_cost_type_id_to,
                        pi_period_id_from;
            else
                OPEN cv_periods FOR l_sql_periods
                      USING pi_calendar_code_to,
                            pi_all_periods_from,
                            pi_calendar_code_to,
                            pi_all_periods_to,
                       pi_calendar_code_to,
                       pi_cost_type_id_to,
                       pi_all_org_id,
                       pi_period_id_from;

             end if;
       ELSIF (pi_calendar_code_from <> pi_calendar_code_to) THEN
           if(pi_organization_id_to is not null) then
                OPEN cv_periods FOR l_sql_periods
                      USING pi_organization_id_to,
                        pi_calendar_code_to,
                             pi_all_periods_from,
                             pi_calendar_code_to,
                             pi_all_periods_to,
                        pi_calendar_code_to,
                        pi_cost_type_id_to;
            else
                OPEN cv_periods FOR l_sql_periods
                      USING pi_calendar_code_to,
                            pi_all_periods_from,
                            pi_calendar_code_to,
                            pi_all_periods_to,
                       pi_calendar_code_to,
                       pi_cost_type_id_to,
                       pi_all_org_id;

             end if;
      END IF;


      /* end sschinch dt 05/2/03 bug 2934528 Bind variable fix */
     LOOP
          FETCH cv_periods INTO l_period_id_to ;
          EXIT WHEN cv_periods%NOTFOUND ;


          IF (pi_organization_id_to IS NOT NULL) THEN
         OPEN cv_org FOR l_sql_org
              USING pi_organization_id_to;
           ELSIF ((pi_calendar_code_from = pi_calendar_code_to) AND
                     (pi_period_id_to IS NOT NULL) AND
                     (pi_period_id_from = pi_period_id_to)) THEN
                OPEN cv_org FOR l_sql_org
                  USING  pi_all_org_id,
                     pi_organization_id_from;
                ELSE
                 OPEN cv_org FOR l_sql_org
                 USING  pi_all_org_id;

          END IF;

          LOOP

            FETCH cv_org INTO l_organization_id_to ;
            EXIT WHEN cv_org%NOTFOUND ;

            gmf_util.log;
            gmf_util.msg_log('GMF_CPIC_ALLWHSEPRD', l_organization_id_to,l_period_id_to) ;

            -- End Bug# 1419482

            l_curr_inventory_item_id    := -1;
            l_curr_organization_id      := -1 ;
            l_curr_period_code  := ' ';
            l_frozen_flag       := 0;
            l_assigned_flag     := 1;
            l_period_status     := 'O';   -- bug 5567102

            l_curr_inventory_item_id2   := -1;
            l_curr_organization_id2     := -1;
            l_curr_period_code2 := ' ';

            l_cost_rows         := 0;
            l_cost_rows_upd     := 0;
            l_cost_rows_ins     := 0;
            l_cost_rows_skip    := 0;

            OPEN cv_cost_detail FOR l_sql_stmt USING
                pi_organization_id_from,
                pi_period_id_from,
                pi_cost_type_id_from,
                l_from_range,
                l_to_range
            ;
            LOOP
                FETCH cv_cost_detail INTO r_cost_detail;
                EXIT WHEN cv_cost_detail%NOTFOUND;

                /**
                * Try update of cm_cmpt_dtl first
                * Update can fail for two reasons: either the row is not there
                * or, the row exists but is frozen (rollover_ind = 1)
                * If the costs are frozen in the target period then do not update the rows
                * in cm_cmpt_dtl nor delete them from cm_scst_led/cm_acst_led.
                * The item cost rows should be left untouched in the target period even if
                * one of the components is frozen.
                */

                -- Bug# 1419482 Copy Cost Enhancement. Uday Moogala

                gmf_util.trace('item id and costcomp id...'|| r_cost_detail.inventory_item_id || '-' || r_cost_detail.cmpntcost_id,0) ;
                gmf_util.trace( 'old cost = ' || r_cost_detail.cmpnt_cost , 3 );

                r_cost_detail.cmpnt_cost := r_cost_detail.cmpnt_cost * l_incr_pct + l_incr_decr_cost;
                        --Bug# 1584302 The above line is moved here from the inner most loop.

                gmf_util.trace( 'New cost = ' || r_cost_detail.cmpnt_cost , 3 );

                l_cost_rows     := l_cost_rows + 1;


                    <<process_cost_row>>
                    BEGIN
                        IF( (l_curr_inventory_item_id = r_cost_detail.inventory_item_id) AND
                            (l_frozen_flag = 1)) THEN
                                -- Skip rows for this item
                            gmf_util.trace( 'Skipping rows for Item ' || r_cost_detail.inventory_item_id ||
                                                ' Org ' || l_organization_id_to || ' period ' || l_period_id_to, 0 );
                            RAISE e_item_is_frozen;
                        END IF;

                        IF( (l_curr_inventory_item_id = r_cost_detail.inventory_item_id) AND
                            (l_assigned_flag = 0)) THEN
                             gmf_util.trace( 'Item ' || r_cost_detail.inventory_item_id ||
                                                ' is not assigned to the Org ' || l_organization_id_to, 0 );
                             RAISE e_item_not_assigned;
                        END IF;

                        IF (l_curr_inventory_item_id <> r_cost_detail.inventory_item_id) THEN

                                -- Update the current item_id
                                l_curr_inventory_item_id := r_cost_detail.inventory_item_id;

                                -- Find out if Item is frozen in the target period.
                                -- 1 if item is to be skipped, 0 if copy can proceed
                                l_frozen_flag := verify_frozen_costs(
                                                        l_curr_inventory_item_id, l_organization_id_to,
                                                        pi_calendar_code_to, l_period_id_to,
                                                        pi_cost_type_id_to );

                                gmf_util.trace( 'Verify_frozen: Item ' || r_cost_detail.inventory_item_id ||
                                                ' Organization ' || l_organization_id_to || ' period ' || l_period_id_to ||
                                                ' Status = ' || l_frozen_flag, 3 );

                                l_assigned_flag := verify_item_assigned_to_org(
                                                        l_curr_inventory_item_id, l_organization_id_to);

                                gmf_util.trace( 'Verify_item_assigned_to_org: Item ' || r_cost_detail.inventory_item_id ||
                                                ' Organization ' || l_organization_id_to ||
                                                ' Status = ' || l_assigned_flag, 3 );
                        END IF;

                        -- Item is frozen so skip this row for this item
                        IF( l_frozen_flag = 1 ) THEN
                            RAISE e_item_is_frozen;
                        END IF;

                        IF( l_assigned_flag = 0 ) THEN
                            gmf_util.trace( 'Item ' || r_cost_detail.inventory_item_id ||
                                            ' is not assigned to the Org ' || l_organization_id_to, 0 );
                                RAISE e_item_not_assigned;
                        END IF;

                        -- Copy logic here
                        gmf_util.trace( 'Copying cost row:' ||
                                'Cc_id = ' || r_cost_detail.cmpntcost_id ||
                                ' Cmpnt = ' || r_cost_detail.cost_cmpntcls_id ||
                                ' Ancd = ' || r_cost_detail.cost_analysis_code ||
                                ' Level = ' || r_cost_detail.cost_level ||
                                ' Cost = ' || r_cost_detail.cmpnt_cost , 0 );

                        /* Bug# 1584302: Moved the next 2 lines into 1st for loop.
                        *  r_cost_detail.cmpnt_cost := r_cost_detail.cmpnt_cost * l_incr_pct + l_incr_decr_cost;
                        *  gmf_util.trace( 'New cost = ' || r_cost_detail.cmpnt_cost , 3 );
                        */

                        /**
                        * RS B1069117 - Call the delete stmt only once for an item
                        */
                           -- start for bug 5567102, pmarada
                        IF( (l_curr_inventory_item_id2 = r_cost_detail.inventory_item_id) AND
                            (l_period_status = 'F') AND ( l_rem_repl = 1 )
                          ) THEN
                                -- Skip this row for this item
                                gmf_util.trace( 'Period ' || l_period_code ||
                                                  ' is Frozen. You can not Delete Frozen period cost.', 0  );
                                RAISE e_period_frozen;

                        END IF;  -- end for bug 5567102,pmarada

                        IF (l_curr_inventory_item_id2 <> r_cost_detail.inventory_item_id) THEN

                                l_curr_inventory_item_id2 := r_cost_detail.inventory_item_id;

                           IF( l_rem_repl = 1 ) THEN
                              -- start for bug 5567102, pmarada,
                              -- Don't allow to delete the Frozen period costs.
                              verify_frozen_periods(l_period_id_to, l_period_code, l_period_status);
                              IF l_period_status = 'F' THEN
                                -- For frozen period existing costs should not be changed during a copy.
                                -- But New costs can be added though for the item, Bug 5672543
                                IF (check_rec_infrozen_period(l_organization_id_to,
                                                              l_curr_inventory_item_id2,
                                                              l_period_id_to,
                                                              pi_cost_type_id_to
                                                             )) THEN
                                    gmf_util.trace( 'Period ' || l_period_code ||
                                                   ' is Frozen. You can not Delete Frozen period cost.', 0 );
                                    RAISE e_period_frozen;
                                 END IF;
                              END IF;   -- end for bug 5567102 pmarada
                                -- Delete the costs for the target parameters
                                delete_item_costs(
                                                r_cost_detail.inventory_item_id,
                                                l_organization_id_to,
                                                pi_calendar_code_to,
                                                l_period_id_to,
                                                pi_cost_type_id_to
                                                );
                          END IF;
                        END IF;

                        <<insert_or_update>>
                        DECLARE
                                CURSOR c_updins_cc_id(
                                        p_calendar_code         IN cm_cmpt_dtl.calendar_code%TYPE,
                                        p_period_id             IN cm_cmpt_dtl.period_id%TYPE,
                                        p_cost_type_id          IN cm_cmpt_dtl.cost_type_id%TYPE,
                                        p_organization_id       IN cm_cmpt_dtl.organization_id%TYPE,
                                        p_inventory_item_id     IN cm_cmpt_dtl.inventory_item_id%TYPE,
                                        p_cost_cmpntcls_id      IN cm_cmpt_dtl.cost_cmpntcls_id%TYPE,
                                        p_cost_analysis_code    IN cm_cmpt_dtl.cost_analysis_code%TYPE,
                                        p_cost_level            IN cm_cmpt_dtl.cost_level%TYPE
                                ) IS
                                        SELECT
                                                cmpntcost_id
                                        FROM
                                                cm_cmpt_dtl
                                        WHERE
                                                period_id          = p_period_id AND
                                                cost_type_id       = p_cost_type_id AND
                                                organization_id    = p_organization_id AND
                                                inventory_item_id  = p_inventory_item_id AND
                                                cost_cmpntcls_id   = p_cost_cmpntcls_id AND
                                                cost_analysis_code = p_cost_analysis_code AND
                                                cost_level         = p_cost_level;

                                l_updins_cc_id  cm_cmpt_dtl.cmpntcost_id%TYPE;
                                e_insert_row    EXCEPTION;
                        BEGIN

                                l_updins_cc_id := 0;
                                /* B2198228  - If l_copy_to_upper_lvl flag is set to 1 then
                                 *             always try to update, if we fail it will insert anyway */
                                /* IF( l_rem_repl = 1 ) THEN */
                                IF( l_rem_repl = 1 and l_copy_to_upper_lvl <> 1 ) THEN
                                   RAISE e_insert_row;
                                END IF;

                                -- Verify whether the period is frozen or not. bug 5567102 start, pmarada
                                -- if the period is frozen then don't update the cost.
                                verify_frozen_periods(l_period_id_to, l_period_code, l_period_status);
                                IF l_period_status = 'F' THEN
                                    gmf_util.trace( 'Period ' || l_period_code ||
                                                                  ' is Frozen. You can not Update Frozen period cost.', 0 );
                                                        RAISE e_period_frozen;
                                END IF;  -- end for bug 5567102 pmarada

                               /** There is a unique index on cm_cmpt_dtl on these columns
                                * and we expect only one row and only one row is fetched
                                * if not we have bigger problems, houston!
                                */
                                IF ( l_copy_to_upper_lvl = 1 ) THEN
                                        /* B2198228 Pass hard-coded level - 0 since we are going to copy
                                         * lower level cost from source to this level at target */
                                        OPEN c_updins_cc_id( pi_calendar_code_to, l_period_id_to,
                                                pi_cost_type_id_to, l_organization_id_to,
                                                r_cost_detail.inventory_item_id,
                                                r_cost_detail.cost_cmpntcls_id,
                                                r_cost_detail.cost_analysis_code,
                                                0
                                                );
                                ELSE
                                        OPEN c_updins_cc_id( pi_calendar_code_to, l_period_id_to,
                                                pi_cost_type_id_to, l_organization_id_to,
                                                r_cost_detail.inventory_item_id,
                                                r_cost_detail.cost_cmpntcls_id,
                                                r_cost_detail.cost_analysis_code,
                                                r_cost_detail.cost_level
                                                );
                                END IF;

                                FETCH c_updins_cc_id INTO l_updins_cc_id;
                                IF( c_updins_cc_id%FOUND ) THEN

                                        /**
                                        * Delete from scst_led, acst_led for the target parameters
                                        * Update brdn_dtl and set cmpntcost_id to null
                                        * Update cmpt_dtl
                                        */

                                        DELETE FROM
                                                cm_scst_led
                                        WHERE
                                                cmpntcost_id = l_updins_cc_id
                                        ;

                                        gmf_util.trace( SQL%ROWCOUNT || ' rows deleted from scst_led ', 1 );

                                        DELETE FROM
                                                cm_acst_led
                                        WHERE
                                                cmpntcost_id = l_updins_cc_id
                                        ;

                                        gmf_util.trace( SQL%ROWCOUNT || ' rows deleted from acst_led', 1 );

                                        UPDATE cm_brdn_dtl
                                        SET
                                                cmpntcost_id = NULL
                                        WHERE
                                                cmpntcost_id = l_updins_cc_id
                                        ;

                                        gmf_util.trace( SQL%ROWCOUNT || ' rows updated in brdn_dtl', 0);

                                        IF ( l_copy_to_upper_lvl = 1 and r_cost_detail.cost_level = 1 ) THEN
                                                -- B2198228 We have read cost from lower level at source and user
                                                -- wants to copy it to this level at target

                                                UPDATE
                                                        cm_cmpt_dtl
                                                SET
                                                        cmpntcost_id    = GEM5_CMPNT_COST_ID_S.NEXTVAL,
                                                        cmpnt_cost      = cmpnt_cost + r_cost_detail.cmpnt_cost,
                                                        burden_ind      = r_cost_detail.burden_ind,
                                                        rollover_ind    = 0,
                                                        total_qty       = 0,
                                                        costcalc_orig   = 4,            -- B2232752 copied specially from lower level to upper level
                                                        rmcalc_type     = 0,
                                                        rollup_ref_no   = NULL,
                                                        acproc_id       = NULL,
                                                        trans_cnt       = 1,
                                                        text_code       = NULL,
                                                        delete_mark     = 0,
                                                        last_update_date        = SYSDATE,
                                                        last_updated_by         = g_user_id,
                                                        last_update_login       = g_login_id,
                                                        request_id              = g_request_id,
                                                        program_application_id  = g_prog_appl_id,
                                                        program_id              = g_program_id,
                                                        program_update_date     = SYSDATE
                                                WHERE
                                                        cmpntcost_id    = l_updins_cc_id
                                                ;
                                        ELSE
                                                UPDATE
                                                        cm_cmpt_dtl
                                                SET
                                                        cmpntcost_id    = GEM5_CMPNT_COST_ID_S.NEXTVAL,
                                                        cmpnt_cost      = r_cost_detail.cmpnt_cost,
                                                        burden_ind      = r_cost_detail.burden_ind,
                                                        fmeff_id        = decode(g_effid_copy,          -- Bug# 1419482
                                                                                 'Y', r_cost_detail.fmeff_id,
                                                                                 NULL),
                                                        rollover_ind    = 0,
                                                        total_qty       = 0,
                                                        costcalc_orig = decode(l_copy_to_upper_lvl, 1, 4, 2), -- B2232752 copied specially from lower level to upper level
                                                        rmcalc_type     = 0,
                                                        rollup_ref_no   = NULL,
                                                        acproc_id       = NULL,
                                                        trans_cnt       = 1,
                                                        text_code       = NULL,
                                                        delete_mark     = 0,
                                                        last_update_date        = SYSDATE,
                                                        last_updated_by         = g_user_id,
                                                        last_update_login       = g_login_id,
                                                        request_id              = g_request_id,
                                                        program_application_id  = g_prog_appl_id,
                                                        program_id              = g_program_id,
                                                        program_update_date     = SYSDATE,
                                                        attribute1      = r_cost_detail.attribute1,
                                                        attribute2      = r_cost_detail.attribute2,
                                                        attribute3      = r_cost_detail.attribute3,
                                                        attribute4      = r_cost_detail.attribute4,
                                                        attribute5      = r_cost_detail.attribute5,
                                                        attribute6      = r_cost_detail.attribute6,
                                                        attribute7      = r_cost_detail.attribute7,
                                                        attribute8      = r_cost_detail.attribute8,
                                                        attribute9      = r_cost_detail.attribute9,
                                                        attribute10     = r_cost_detail.attribute10,
                                                        attribute11     = r_cost_detail.attribute11,
                                                        attribute12     = r_cost_detail.attribute12,
                                                        attribute13     = r_cost_detail.attribute13,
                                                        attribute14     = r_cost_detail.attribute14,
                                                        attribute15     = r_cost_detail.attribute15,
                                                        attribute16     = r_cost_detail.attribute16,
                                                        attribute17     = r_cost_detail.attribute17,
                                                        attribute18     = r_cost_detail.attribute18,
                                                        attribute19     = r_cost_detail.attribute19,
                                                        attribute20     = r_cost_detail.attribute20,
                                                        attribute21     = r_cost_detail.attribute21,
                                                        attribute22     = r_cost_detail.attribute22,
                                                        attribute23     = r_cost_detail.attribute23,
                                                        attribute24     = r_cost_detail.attribute24,
                                                        attribute25     = r_cost_detail.attribute25,
                                                        attribute26     = r_cost_detail.attribute26,
                                                        attribute27     = r_cost_detail.attribute27,
                                                        attribute28     = r_cost_detail.attribute28,
                                                        attribute29     = r_cost_detail.attribute29,
                                                        attribute30     = r_cost_detail.attribute30
                                                WHERE
                                                        cmpntcost_id    = l_updins_cc_id
                                                ;

                                                gmf_util.trace( ' row updated to cmpt_dtl', 0 );

                                        END IF; /* l_copy_to_upper_lvl = 1 */
                                ELSE    -- cursor not found
                                        -- update failed, try inserting the row into cm_cmpt_dtl
                                        RAISE e_insert_row;
                                END IF;         -- if row is found in target period

                                l_cost_rows_upd := l_cost_rows_upd + 1;

                                IF( c_updins_cc_id%ISOPEN ) THEN
                                        CLOSE c_updins_cc_id;
                                END IF;

                        EXCEPTION
                                WHEN e_insert_row THEN
                                        -- First close the open cursor
                                        IF( c_updins_cc_id%ISOPEN ) THEN
                                                CLOSE c_updins_cc_id;
                                        END IF;
                                        -- Attempt to insert the row
                                        INSERT INTO
                                        cm_cmpt_dtl(
                                                cmpntcost_id,
                                                inventory_item_id,
                                                organization_id,
                                                cost_cmpntcls_id,
                                                cost_analysis_code,
                                                cost_level,
                                                cmpnt_cost,
                                                burden_ind,
                                                fmeff_id,
                                                rollover_ind,
                                                total_qty,
                                                costcalc_orig,
                                                rmcalc_type,
                                                rollup_ref_no,
                                                acproc_id,
                                                trans_cnt,
                                                text_code,
                                                delete_mark,
                                                creation_date,
                                                created_by,
                                                last_update_date,
                                                last_updated_by,
                                                last_update_login,
                                                request_id,
                                                program_application_id,
                                                program_id,
                                                program_update_date,
                                                attribute1,
                                                attribute2,
                                                attribute3,
                                                attribute4,
                                                attribute5,
                                                attribute6,
                                                attribute7,
                                                attribute8,
                                                attribute9,
                                                attribute10,
                                                attribute11,
                                                attribute12,
                                                attribute13,
                                                attribute14,
                                                attribute15,
                                                attribute16,
                                                attribute17,
                                                attribute18,
                                                attribute19,
                                                attribute20,
                                                attribute21,
                                                attribute22,
                                                attribute23,
                                                attribute24,
                                                attribute25,
                                                attribute26,
                                                attribute27,
                                                attribute28,
                                                attribute29,
                                                attribute30,
                                                period_id,
                                                cost_type_id
                                                )
                                        VALUES (
                                                GEM5_CMPNT_COST_ID_S.NEXTVAL,
                                                r_cost_detail.inventory_item_id,
                                                l_organization_id_to,
                                                r_cost_detail.cost_cmpntcls_id,
                                                r_cost_detail.cost_analysis_code,
                                                decode(l_copy_to_upper_lvl, 1, 0, r_cost_detail.cost_level), -- B2198228
                                                r_cost_detail.cmpnt_cost,
                                                r_cost_detail.burden_ind,
                                                decode(g_effid_copy, 'Y', r_cost_detail.fmeff_id,  -- Bug# 1419482
                                                        NULL),          -- fmeff_id,
                                                0,                      -- rollover_ind,
                                                0,                      -- total_qty,
                                                decode(l_copy_to_upper_lvl, 1, 4, 2), -- B2232752 2,                    -- costcalc_orig,
                                                0,                      -- rmcalc_type,
                                                NULL,                   -- rollup_ref_no,
                                                NULL,                   -- acproc_id,
                                                1,                      -- trans_cnt,
                                                NULL,                   -- text_code,
                                                0,                      -- delete_mark,
                                                SYSDATE,                -- creation_date,
                                                g_user_id,              -- created_by,
                                                SYSDATE,                -- last_update_date,
                                                g_user_id,              -- last_updated_by,
                                                g_login_id,             -- last_update_login,
                                                g_request_id,           -- request_id,
                                                g_prog_appl_id,         -- program_application_id,
                                                g_program_id,           -- program_id,
                                                SYSDATE,                -- program_update_date,
                                                r_cost_detail.attribute1,
                                                r_cost_detail.attribute2,
                                                r_cost_detail.attribute3,
                                                r_cost_detail.attribute4,
                                                r_cost_detail.attribute5,
                                                r_cost_detail.attribute6,
                                                r_cost_detail.attribute7,
                                                r_cost_detail.attribute8,
                                                r_cost_detail.attribute9,
                                                r_cost_detail.attribute10,
                                                r_cost_detail.attribute11,
                                                r_cost_detail.attribute12,
                                                r_cost_detail.attribute13,
                                                r_cost_detail.attribute14,
                                                r_cost_detail.attribute15,
                                                r_cost_detail.attribute16,
                                                r_cost_detail.attribute17,
                                                r_cost_detail.attribute18,
                                                r_cost_detail.attribute19,
                                                r_cost_detail.attribute20,
                                                r_cost_detail.attribute21,
                                                r_cost_detail.attribute22,
                                                r_cost_detail.attribute23,
                                                r_cost_detail.attribute24,
                                                r_cost_detail.attribute25,
                                                r_cost_detail.attribute26,
                                                r_cost_detail.attribute27,
                                                r_cost_detail.attribute28,
                                                r_cost_detail.attribute29,
                                                r_cost_detail.attribute30,
                                                l_period_id_to,
                                                pi_cost_type_id_to
                                                );

                                        l_cost_rows_ins := l_cost_rows_ins + 1;
                                        gmf_util.trace( SQL%ROWCOUNT || ' rows inserted to cmpt_dtl', 0 );

                        END insert_or_update;

                EXCEPTION
                   WHEN e_item_is_frozen THEN
                        -- Just continue the loop
                        l_cost_rows_skip := l_cost_rows_skip + 1;
                        null;
         WHEN e_item_not_assigned THEN
            NULL;
         WHEN e_period_frozen THEN   -- bug 5567102
            NULL;
        END process_cost_row;
        END LOOP;       -- End of main cursor loop
             CLOSE cv_cost_detail;

             IF( l_cost_rows > 0 ) THEN
                gmf_util.msg_log( 'GMF_CP_ROWS_SELECTED', TO_CHAR(l_cost_rows) );
                gmf_util.msg_log( 'GMF_CP_ROWS_UPDINS', TO_CHAR(l_cost_rows_upd), TO_CHAR(l_cost_rows_ins) );
             ELSE
                gmf_util.msg_log( 'GMF_CP_NO_ROWS' );
             END IF;

             IF( l_cost_rows_skip > 0 ) THEN
                gmf_util.msg_log( 'GMF_CPIC_ROWS_FRZ', TO_CHAR(l_cost_rows_skip) );
             END IF;

          END LOOP ;    -- Organizations loop
          CLOSE cv_org;

        END LOOP ;      -- Periods loop
        CLOSE cv_periods;

        gmf_util.log;
        gmf_util.msg_log( 'GMF_CPIC_ITM_END' );
        gmf_util.log;

END copy_cost_dtl;


/*****************************************************************************
 *  PROCEDURE
 *    end_copy
 *
 *  DESCRIPTION
 *    Sets the concurrent manager completion status
 *
 *  INPUT PARAMETERS
 *    pi_errstat - Completion status, must be one of 'NORMAL', 'WARNING', or
 *      'ERROR'
 *    pi_errmsg - Completion message to be passed back
 *
 *  HISTORY
 *    13-Oct-1999 Rajesh Seshadri
 *
 ******************************************************************************/

PROCEDURE end_copy (
        pi_errstat IN VARCHAR2,
        pi_errmsg  IN VARCHAR2
        )
IS
        l_retval BOOLEAN;
BEGIN

        l_retval := fnd_concurrent.set_completion_status(pi_errstat,pi_errmsg);

END end_copy;

/*****************************************************************************
 *  PROCEDURE
 *    delete_item_costs
 *
 *  DESCRIPTION
 *    Deletes the child rows from cm_scst_led, cm_acst_led and sets
 *      cmpntcost_id to null in cm_brdn_dtl for the cost parameters passed
 *    NOTE: We do not have to worry about rollover_ind here since this procedure
 *      is not even called if the item is frozen in the target period.
 *
 *  INPUT PARAMETERS
 *    item_id, organization_id, calendar_code, period_code, cost_mthd_code
 *
 *  HISTORY
 *    13-Oct-1999 Rajesh Seshadri
 *
 ******************************************************************************/

PROCEDURE delete_item_costs(
        pi_inventory_item_id  IN cm_cmpt_dtl.inventory_item_id%TYPE,
        pi_organization_id    IN cm_cmpt_dtl.organization_id%TYPE,
        pi_calendar_code   IN cm_cmpt_dtl.calendar_code%TYPE,
        pi_period_id       IN cm_cmpt_dtl.period_id%TYPE,
        pi_cost_type_id    IN cm_cmpt_dtl.cost_type_id%TYPE
        )
IS
        CURSOR c_cc_id(
                p_inventory_item_id             IN cm_cmpt_dtl.inventory_item_id%TYPE,
                p_organization_id               IN cm_cmpt_dtl.organization_id%TYPE,
                p_calendar_code         IN cm_cmpt_dtl.calendar_code%TYPE,
                p_period_id             IN cm_cmpt_dtl.period_id%TYPE,
                p_cost_type_id  IN cm_cmpt_dtl.cost_type_id%TYPE
        )
        IS
                SELECT
                        cmpntcost_id
                FROM
                        cm_cmpt_dtl
                WHERE
                        inventory_item_id = p_inventory_item_id AND
                        organization_id = p_organization_id AND
                        period_id       = p_period_id AND
                        cost_type_id    = p_cost_type_id
                FOR UPDATE
                ;

BEGIN

        gmf_util.trace( 'Deleting dependent rows', 0 );
        gmf_util.trace( 'Item:' || pi_inventory_item_id || ' Org:' || pi_organization_id ||
                ' Cal:' || pi_calendar_code || ' Per:' || pi_period_id || ' Mthd:' ||
                pi_cost_type_id , 0 );

        FOR r_cc_id IN c_cc_id(
                pi_inventory_item_id, pi_organization_id, pi_calendar_code, pi_period_id, pi_cost_type_id
        ) LOOP

                -- Delete rows from acst_led
                DELETE FROM
                        cm_acst_led
                WHERE
                        cmpntcost_id    = r_cc_id.cmpntcost_id
                ;

                gmf_util.trace( SQL%ROWCOUNT || ' rows deleted from acst_led', 3 );

                -- Delete rows from scst_led
                DELETE FROM
                        cm_scst_led
                WHERE
                        cmpntcost_id    = r_cc_id.cmpntcost_id
                ;

                gmf_util.trace( SQL%ROWCOUNT || ' rows deleted from scst_led', 3 );

                -- Update brdn_dtl
                UPDATE
                        cm_brdn_dtl
                SET
                        cmpntcost_id    = NULL
                WHERE
                        cmpntcost_id    = r_cc_id.cmpntcost_id
                ;

                gmf_util.trace( SQL%ROWCOUNT || ' rows updated in brdn_dtl', 3 );

                -- Finally delete the row itself from cmpt_dtl
                DELETE FROM
                        cm_cmpt_dtl
                WHERE CURRENT OF c_cc_id
                ;

                gmf_util.trace( SQL%ROWCOUNT || ' rows deleted from cmpt_dtl', 3 );

        END LOOP;

END delete_item_costs;

/*****************************************************************************
 *  FUNCTION
 *    verify_frozen_costs
 *
 *  DESCRIPTION
 *    Verifies if the item costs are frozen in the copy-to period
 *
 *  INPUT PARAMETERS
 *    calendar_code, period_code, cost_mthd_code, organization_id, item
 *
 *  HISTORY
 *    13-Oct-1999 Rajesh Seshadri
 *
 ******************************************************************************/

FUNCTION verify_frozen_costs(
        pi_inventory_item_id            IN cm_cmpt_dtl.inventory_item_id%TYPE,
        pi_organization_id      IN cm_cmpt_dtl.organization_id%TYPE,
        pi_calendar_code        IN cm_cmpt_dtl.calendar_code%TYPE,
        pi_period_id            IN cm_cmpt_dtl.period_id%TYPE,
        pi_cost_type_id IN cm_cmpt_dtl.cost_type_id%TYPE
        )
RETURN NUMBER IS

        l_frozen_ind    NUMBER;
BEGIN
        gmf_util.trace( 'Entering verify_frozen_costs', 0 );

        l_frozen_ind := 0;
        SELECT nvl(max(rollover_ind),0) INTO l_frozen_ind
        FROM
                cm_cmpt_dtl
        WHERE period_id         = pi_period_id AND
              cost_type_id      = pi_cost_type_id AND
              organization_id   = pi_organization_id AND
              inventory_item_id = pi_inventory_item_id
        ;

        RETURN l_frozen_ind;

END verify_frozen_costs;
/*****************************************************************************
 *  Procedure
 *    verify_frozen_periods
 *
 *  DESCRIPTION
 *    Verifies if the period is frozen or not
 *
 *  INPUT PARAMETERS
 *    p_period_id period as input parameter and period_code and period_status are out parameters
 *
 *  HISTORY
 *    12-Oct-2006 pmarada, created for bug 5567102
 *
 ******************************************************************************/
PROCEDURE verify_frozen_periods (p_period_id IN gmf_period_statuses.period_id%TYPE,
                                 p_period_code OUT NOCOPY gmf_period_statuses.period_code%TYPE,
                                 p_period_status OUT NOCOPY gmf_period_statuses.period_status%TYPE )
   IS

   CURSOR cur_froz_periods (cp_period_id gmf_period_statuses.period_id%TYPE) IS
   SELECT  period_code, period_status FROM gmf_period_statuses
      WHERE period_id = cp_period_id;

    l_per_code   gmf_period_statuses.period_code%TYPE;
    l_per_status gmf_period_statuses.period_status%TYPE;

BEGIN
    gmf_util.trace( 'Entering verify_frozen_periods', 0 );
    OPEN cur_froz_periods (p_period_id);
    FETCH cur_froz_periods INTO  l_per_code, l_per_status;
    CLOSE cur_froz_periods;

     p_period_code := l_per_code  ;
     p_period_status := l_per_status ;

END verify_frozen_periods;

/*****************************************************************************
 *  Procedure
 *    check_rec_infrozen_period
 *
 *  DESCRIPTION
 *    Verifies if there exists any records for the frozen period.
 *    In Frozen period existing costs should not be changed during a copy.
 *    New costs can be added though.
 *
 *  INPUT PARAMETERS
 *     p_organization_id, p_inventory_item_id, p_period_id, p_cost-type_id
 *
 *  HISTORY
 *    24-Apr-2007 pmarada, created for bug 5672543
 *
 ******************************************************************************/
FUNCTION check_rec_infrozen_period(p_organization_id   cm_cmpt_dtl.organization_id%TYPE,
                                   p_inventory_item_id cm_cmpt_dtl.inventory_item_id%TYPE,
                                   p_period_id         cm_cmpt_dtl.period_id%TYPE,
                                   p_cost_type_id      cm_cmpt_dtl.cost_type_id%TYPE
                                  )
RETURN BOOLEAN IS

  CURSOR cur_check_rec (cp_organization_id   cm_cmpt_dtl.organization_id%TYPE,
                        cp_inventory_item_id cm_cmpt_dtl.inventory_item_id%TYPE,
                        cp_period_id     cm_cmpt_dtl.period_id%TYPE,
                        cp_cost_type_id  cm_cmpt_dtl.cost_type_id%TYPE) IS
  SELECT 'x' FROM cm_cmpt_dtl
  WHERE organization_id   = cp_organization_id
    AND inventory_item_id = cp_inventory_item_id
    AND period_id         = cp_period_id
    AND cost_type_id      = cp_cost_type_id;
    l_found VARCHAR2(1);
BEGIN

   OPEN cur_check_rec (p_organization_id, p_inventory_item_id, p_period_id, p_cost_type_id );
   FETCH cur_check_rec INTO l_found;
   CLOSE cur_check_rec;
   IF l_found IS NOT NULL THEN
      RETURN TRUE;
   ELSE
      RETURN FALSE;
   END IF;

END check_rec_infrozen_period;

/*****************************************************************************
 *  PROCEDURE
 *    copy_burden_costs
 *
 *  DESCRIPTION
 *      Copy Overhead Costs Procedure
 *      Copies overhead costs from the one set of orgn/cost calendar/period/cost
 *      method to another for the item OR item cost class range specified on the
 *      form.
 *  INPUT PARAMETERS
 *      From and To organization_id/calendar/period/cost method
 *      Item from/to range
 *      Item cost class from/to range
 *      Remove before copy or Replace during copy indicator
 *
 *  OUTPUT PARAMETERS
 *      po_errbuf               Completion message to the Concurrent Manager
 *      po_retcode              Return code to the Concurrent Manager
 *
 *  INPUT PARAMETERS
 *    calendar_code, period_code, cost_mthd_code, organization_id, item
 *
 *  HISTORY
 *    13-Oct-1999 Rajesh Seshadri
 *    21-Nov-2000 Uday Moogala - Bug# 1419482 Copy Cost Enhancement.
 *
 ******************************************************************************/



PROCEDURE copy_burden_cost
(
po_errbuf                                        OUT       NOCOPY       VARCHAR2,
po_retcode                                  OUT            NOCOPY       VARCHAR2,
pi_organization_id_from            IN           cm_cmpt_dtl.organization_id%TYPE,
pi_calendar_code_from              IN           cm_cmpt_dtl.calendar_code%TYPE,
pi_period_code_from                   IN                cm_cmpt_dtl.period_code%TYPE,
pi_cost_type_id_from                  IN                cm_cmpt_dtl.cost_type_id%TYPE,
pi_organization_id_to              IN           cm_cmpt_dtl.organization_id%TYPE,
pi_calendar_code_to                   IN                cm_cmpt_dtl.calendar_code%TYPE,
pi_period_code_to                        IN             cm_cmpt_dtl.period_code%TYPE,
pi_cost_type_id_to                    IN                cm_cmpt_dtl.cost_type_id%TYPE,
pi_item_from                             IN             mtl_item_flexfields.item_number%TYPE,
pi_item_to                                  IN          mtl_item_flexfields.item_number%TYPE,
pi_itemcc_from                           IN             mtl_categories_b_kfv.concatenated_segments%TYPE,
pi_itemcc_to                             IN             mtl_categories_b_kfv.concatenated_segments%TYPE,
pi_rem_repl                                 IN          VARCHAR2,
pi_all_periods_from                   IN                cm_cmpt_dtl.period_code%TYPE,
pi_all_periods_to                        IN             cm_cmpt_dtl.period_code%TYPE,
pi_all_org_id                            IN             gmf_legal_entities.legal_entity_id%TYPE
)

IS

   l_from_range          VARCHAR2(32767);
   l_to_range            VARCHAR2(32767);
   l_range_type          NUMBER;
   l_effid_copy          VARCHAR2(4) ;

        l_rem_repl                    NUMBER;
        e_same_from_to                EXCEPTION;
        e_no_cost_rows                EXCEPTION;

BEGIN
        /* uncomment the call below to write to a local file */

        FND_FILE.PUT_NAMES('gmfcpoc.log','gmfcpoc.out','/appslog/opm_top/utl/opmm0dv/log');


        gmf_util.msg_log( 'GMF_CPOC_START' );
        /*gmf_util.msg_log( 'GMF_CPOC_SRCPARAM', nvl(pi_organization_id_from, ' '), nvl(pi_calendar_code_from, ' '), nvl(pi_period_code_from, ' '), nvl(pi_cost_type_id_from, ' ') );

        gmf_util.msg_log( 'GMF_CPOC_TGTPARAM', nvl(pi_organization_id_to, ' '), nvl(pi_calendar_code_to, ' '), nvl(pi_period_code_to, ' '), nvl(pi_cost_type_id_to, ' ') );

        gmf_util.msg_log( 'GMF_CPOC_ITEMRANGE', nvl(pi_item_from, ' '), nvl(pi_item_to, ' ') );
        gmf_util.msg_log( 'GMF_CPOC_ITEMCCRANGE', nvl(pi_itemcc_from, ' '), nvl(pi_itemcc_to, ' ') );*/


        -- Bug# 1419482 Copy Cost Enhancement. Uday Moogala
   IF ( (pi_period_code_to IS NULL) AND                 -- all periods
             ((pi_all_periods_from IS NOT NULL) OR (pi_all_periods_to IS NOT NULL))
           ) THEN

                gmf_util.msg_log('GMF_CPOC_ALLPERIODS', nvl(pi_calendar_code_to, ' ') ) ;
                gmf_util.msg_log('GMF_CPOC_PERIODS_RANGE', nvl(pi_all_periods_from, ' '),
                                  nvl(pi_all_periods_to, ' '), nvl(pi_calendar_code_to, ' ') ) ;

        END IF ;

        -- End Bug# 1419482

        l_rem_repl := 0;
        IF ( pi_rem_repl = '1' ) THEN   -- Remove before copy
                l_rem_repl := 1;
                gmf_util.msg_log( 'GMF_CPOC_OPTREM' );
        ELSE                            -- Replace before copy
                l_rem_repl := 0;
                gmf_util.msg_log( 'GMF_CPOC_OPTREP' );
        END IF;

        gmf_util.log;

        IF ( (pi_period_code_from = pi_period_code_to) AND
                (pi_cost_type_id_from = pi_cost_type_id_to) AND
                (pi_calendar_code_from = pi_calendar_code_to) AND
                (pi_organization_id_from = pi_organization_id_to) ) THEN

                gmf_util.msg_log( 'GMF_CP_SAME_FROMTO' );
                RAISE e_same_from_to;
        END IF;

        -- Determine what kind of where clause needs to be concatenated
        -- depending on what options were sent in
        l_from_range    := NULL;
        l_to_range      := NULL;
        l_range_type    := G_ITEM;
   IF ( (pi_item_from IS NOT NULL) OR (pi_item_to IS NOT NULL) ) THEN
                l_from_range    := pi_item_from;
                l_to_range      := pi_item_to;
                l_range_type    := G_ITEM;
           gmf_util.trace( 'Range : ' || l_from_range || ' - ' || l_to_range, 0 );
        ELSIF ( (pi_itemcc_from IS NOT NULL) OR (pi_itemcc_to IS NOT NULL) ) THEN
                l_from_range    := pi_itemcc_from;
                l_to_range      := pi_itemcc_to;
                l_range_type    := G_ITEMCC;
           gmf_util.trace( 'Range : ' || l_from_range || ' - ' || l_to_range, 0 );
        ELSE
                l_from_range    := pi_item_from;
                l_to_range      := pi_item_to;
                l_range_type    := G_ITEM;
      gmf_util.trace( 'Range : ' || l_from_range || ' - ' || l_to_range, 0);
        END IF;


        -- Initialize WHO columns
        g_user_id       := FND_GLOBAL.USER_ID;
        g_login_id      := FND_GLOBAL.LOGIN_ID;
        g_prog_appl_id  := FND_GLOBAL.PROG_APPL_ID;
        g_program_id    := FND_GLOBAL.CONC_PROGRAM_ID;
        g_request_id    := FND_GLOBAL.CONC_REQUEST_ID;

      -- Houston, do you copy?
      copy_burden_dtl
      (
      pi_organization_id_from, pi_calendar_code_from,
      pi_period_code_from, pi_cost_type_id_from,
      pi_organization_id_to, pi_calendar_code_to,
      pi_period_code_to, pi_cost_type_id_to,
      l_range_type, l_from_range, l_to_range,
      l_rem_repl,
      pi_all_periods_from, pi_all_periods_to,
      pi_all_org_id
      );
                -- Copy that, Roger!

        -- All is well
        po_retcode := 0;
        po_errbuf := NULL;
   end_copy( 'NORMAL', NULL );
        COMMIT;


        gmf_util.log;
        gmf_util.msg_log( 'GMF_CPIC_END' );

EXCEPTION
        WHEN e_no_cost_rows THEN
                po_retcode := 0;
                po_errbuf := NULL;
                end_copy( 'NORMAL', NULL );

        WHEN e_same_from_to THEN
                po_retcode := 0;
                po_errbuf := NULL;
                end_copy( 'NORMAL', NULL );

        WHEN utl_file.invalid_path then
                po_retcode := 3;
                po_errbuf := 'Invalid path - '||to_char(SQLCODE) || ' ' || SQLERRM;
                end_copy ('ERROR', NULL);
        WHEN utl_file.invalid_mode then
                po_retcode := 3;
                po_errbuf := 'Invalid Mode - '||to_char(SQLCODE) || ' ' || SQLERRM;
                end_copy ('ERROR', NULL);
        WHEN utl_file.invalid_filehandle then
                po_retcode := 3;
                po_errbuf := 'Invalid filehandle - '||to_char(SQLCODE) || ' ' || SQLERRM;
                end_copy ('ERROR', NULL);
        WHEN utl_file.invalid_operation then
                po_retcode := 3;
                po_errbuf := 'Invalid operation - '||to_char(SQLCODE) || ' ' || SQLERRM;
                end_copy ('ERROR', NULL);
        WHEN utl_file.write_error then
                po_retcode := 3;
                po_errbuf := 'Write error - '||to_char(SQLCODE) || ' ' || SQLERRM;
                end_copy ('ERROR', NULL);
        WHEN others THEN
                po_retcode := 3;
                po_errbuf := to_char(SQLCODE) || ' ' || SQLERRM;
                end_copy ('ERROR', po_errbuf);

END copy_burden_cost;


/*****************************************************************************
 *  PROCEDURE
 *    copy_burden_dtl
 *
 *  DESCRIPTION
 *    Verifies if the item costs are frozen in the copy-to period
 *
 *  INPUT PARAMETERS
 *    calendar_code, period_code, cost_mthd_code, organization_id
 *
 *  HISTORY
 *    13-Oct-1999 Rajesh Seshadri
 *    21-Nov-2000 Uday Moogala - Bug# 1419482 Copy Cost Enhancement.
 *
 ******************************************************************************/


PROCEDURE copy_burden_dtl(
        pi_organization_id_from    IN cm_cmpt_dtl.organization_id%TYPE,
        pi_calendar_code_from      IN cm_cmpt_dtl.calendar_code%TYPE,
        pi_period_code_from           IN cm_cmpt_dtl.period_code%TYPE,
        pi_cost_type_id_from          IN cm_cmpt_dtl.cost_type_id%TYPE,
        pi_organization_id_to      IN cm_cmpt_dtl.organization_id%TYPE,
        pi_calendar_code_to           IN cm_cmpt_dtl.calendar_code%TYPE,
        pi_period_code_to                IN cm_cmpt_dtl.period_code%TYPE,
        pi_cost_type_id_to            IN cm_cmpt_dtl.cost_type_id%TYPE,
        pi_range_type                    IN NUMBER,
        pi_from_range                    IN VARCHAR2,
        pi_to_range                         IN VARCHAR2,
        pi_rem_repl                         IN NUMBER,
        pi_all_periods_from           IN cm_cmpt_dtl.period_code%TYPE,
        pi_all_periods_to                IN cm_cmpt_dtl.period_code%TYPE,
        pi_all_org_id               IN gmf_legal_entities.legal_entity_id%TYPE
        )

IS

        TYPE rectype_brdn_dtl IS RECORD(
                inventory_item_id                       cm_brdn_dtl.inventory_item_id%TYPE,
--              item_no                          mtl_system_items_b_kfv.concatenated_segments%TYPE,
                resources                        cm_brdn_dtl.resources%TYPE,
                cost_cmpntcls_id              cm_brdn_dtl.cost_cmpntcls_id%TYPE,
                cost_analysis_code         cm_brdn_dtl.cost_analysis_code%TYPE,
                burden_qty                       cm_brdn_dtl.burden_qty%TYPE,
                burden_usage                  cm_brdn_dtl.burden_usage%TYPE,
                burden_um                        cm_brdn_dtl.burden_um%TYPE,
                item_qty                            cm_brdn_dtl.item_qty%TYPE,
                item_um                          cm_brdn_dtl.item_um%TYPE,
                burden_factor                 cm_brdn_dtl.burden_factor%TYPE
        );
        r_brdn_dtl      rectype_brdn_dtl;

        TYPE curtyp_brdn_dtl IS REF CURSOR;
        cv_brdn_dtl     curtyp_brdn_dtl;

        TYPE curtyp_periods IS REF CURSOR;
        cv_periods      curtyp_periods;

        TYPE curtyp_org IS REF CURSOR;
        cv_org         curtyp_org;

        l_sql_stmt_b    VARCHAR2(2000);
        l_sql_org_b     VARCHAR2(2000);
        l_sql_periods_b VARCHAR2(2000);
        l_org_id        mtl_organizations.organization_id%TYPE ;

        l_period_id_to gmf_period_statuses.period_id%TYPE ;
        l_brdn_rows     NUMBER;
        l_brdn_rows_upd NUMBER;
        l_brdn_rows_ins NUMBER;

        l_organization_id_to cm_cmpt_dtl.organization_id%TYPE;

   pi_period_id_to    NUMBER;
   pi_period_id_from  NUMBER;
   l_sql_stmt         VARCHAR2(2000);
   stmtny  varchar2(4000);
   L_legal_entity_id_from number;
   L_legal_entity_id_to number;

   l_assigned_flag NUMBER;

BEGIN

    if(pi_period_code_to is not null) then
        if(pi_organization_id_to is not null) then
          SELECT        gps.period_id
           INTO         pi_period_id_to
           FROM         gmf_period_statuses gps, hr_organization_information org
           WHERE    gps.PERIOD_CODE = pi_period_code_to
           AND      gps.CALENDAR_CODE = pi_calendar_code_to
           AND      gps.legal_entity_id = org.org_information2
           AND      org.organization_id = pi_organization_id_to
           AND      org.org_information_context = 'Accounting Information'
           AND      gps.cost_type_id = pi_cost_type_id_to;
      else
          SELECT        period_id
           INTO         pi_period_id_to
           FROM         gmf_period_statuses
           WHERE    PERIOD_CODE = pi_period_code_to
           AND      CALENDAR_CODE = pi_calendar_code_to
           AND      legal_entity_id = pi_all_org_id
           AND      cost_type_id = pi_cost_type_id_to;
      end if;
    else
     pi_period_id_to := NULL;
    end if;

    SELECT      gps.period_id
    INTO        pi_period_id_from
    FROM        gmf_period_statuses gps, hr_organization_information org
    WHERE   gps.PERIOD_CODE = pi_period_code_from
    AND     gps.CALENDAR_CODE = pi_calendar_code_from
    AND     gps.legal_entity_id = org.org_information2
    and     org.organization_id = pi_organization_id_from
    AND     org.org_information_context = 'Accounting Information'
    AND     gps.cost_type_id = pi_cost_type_id_from;

    gmf_util.msg_log( 'GMF_CPIC_BUR_START' );
        gmf_util.log;

        IF ( (pi_period_code_to IS NULL) AND            -- all periods
             ((pi_all_periods_from IS NOT NULL) OR (pi_all_periods_to IS NOT NULL))
           ) THEN
             gmf_util.msg_log('GMF_CPBRD_PERIODS_RANGE', nvl(pi_all_periods_from, ' '),
                                  nvl(pi_all_periods_to, ' '), nvl(pi_calendar_code_to, ' ') ) ;
        END IF ;

        l_sql_stmt_b := '';
   l_sql_stmt_b :=
        ' SELECT ' ||
                ' bur.inventory_item_id, ' ||
      ' bur.resources, ' ||
                ' bur.cost_cmpntcls_id, ' ||
                ' bur.cost_analysis_code, ' ||
                ' bur.burden_qty, ' ||
                ' bur.burden_usage, ' ||
                ' bur.burden_uom, ' ||
                ' bur.item_qty, ' ||
                ' bur.item_uom, ' ||
                ' bur.burden_factor ' ||
        ' FROM ' ||
      ' cm_brdn_dtl bur ' ||
        ' WHERE ' ||
                ' bur.organization_id           = :b_organization_id AND ' ||
      ' bur.period_id   = :b_period_id AND ' ||
                ' bur.cost_type_id      = :b_cost_type_id  AND ' ||
    -- Bug: 9249016 Vpedarla uncommented the below line.
         ' bur.delete_mark    = 0 '; -- bug 5567156

        IF ( pi_range_type = G_ITEM ) THEN
      l_sql_stmt_b := l_sql_stmt_b ||
      ' AND exists ( '||
      ' select 1 from MTL_ITEM_FLEXFIELDS x'||
      ' where x.organization_id = bur.organization_id '||
      ' and x.item_number between :pi_from_range and :pi_to_range '||
      ' and x.inventory_item_id = bur.inventory_item_id )'||
      -- Bug: 8461556 Vpedarla added the below condition
      ' and bur.delete_mark = 0 ';

        ELSIF ( pi_range_type = G_ITEMCC ) THEN

                l_sql_stmt_b := l_sql_stmt_b ||
         'AND EXISTS (select  ''X'' from mtl_default_category_sets mdc, mtl_category_sets mcs, mtl_item_categories y, mtl_categories_kfv z
                                 where mdc.functional_area_id = 19
                                        and     mdc.category_set_id = mcs.category_set_id
                                           and  mcs.category_set_id = y.category_set_id
                                 and    mcs.structure_id =  z.structure_id
                                 and   y.inventory_item_id = bur.inventory_item_id
                                 and   y.organization_id = bur.organization_id
                                 and   y.category_id = z.category_id
                                 and   z.concatenated_segments >= nvl(:b_from_itemcc, z.concatenated_segments)
                                 and   z.concatenated_segments <= nvl(:b_to_itemcc, z.concatenated_segments))';

        ELSE
                gmf_util.msg_log( 'GMF_CPIC_UNKNOWN' );
                RETURN;
        END IF;

        l_sql_stmt_b := l_sql_stmt_b ||
                ' ORDER BY ' ||
                        'bur.organization_id, bur.inventory_item_id, ' ||
                        'bur.resources, bur.period_id, ' ||
                        'bur.cost_type_id, bur.cost_cmpntcls_id, bur.cost_analysis_code'
                 ;

        gmf_util.trace( 'Burden Sql Stmt: ' || l_sql_stmt_b, 3 );

        IF (pi_organization_id_to IS NOT NULL) THEN     -- copying to one organization

                l_sql_org_b := '' ;
                l_sql_org_b := 'SELECT :pi_organization_id_to FROM  dual '      ;

        ELSE

                -- 'All organizations' option selected
                -- Build SQL to get target organizations when from/to org are not null.

                l_sql_org_b := '' ;

           l_sql_org_b :=
                'SELECT ' ||
                        'hoi.organization_id ' ||
                'FROM ' ||
                        'hr_organization_information hoi , mtl_parameters mp ' ||
                ' WHERE ' ||
                        'hoi.org_information2   = :pi_all_org_id  '||
         ' AND  hoi.org_information_context = ''Accounting Information'' '||
         ' AND  hoi.organization_id = mp.organization_id '||
         ' and  mp.process_enabled_flag = ''Y'' ' ;

                --
                -- We should AVOID copying on to source period and organization. So we should
                -- eliminate 'from organization' from the query only when copying to same period,
                -- same calendar and to all organizations. For all the other cases no need to check for
                -- this condition since from period is getting eliminated from all periods query.
                --

                IF ( (pi_calendar_code_from = pi_calendar_code_to) AND
                     (pi_period_id_to IS NOT NULL) AND
                     (pi_period_id_from = pi_period_id_to)
                   ) THEN

                   l_sql_org_b := l_sql_org_b ||' AND hoi.organization_id <> :pi_organization_id_from ';

                END IF ;
               l_sql_org_b := l_sql_org_b || ' ORDER BY hoi.organization_id ' ;
       END IF ;




        -- Build SQL to get target periods when From/To Periods are not null.
        IF (pi_period_code_to IS NOT NULL) THEN         -- copy to one period.
      l_sql_periods_b :=  'SELECT :pi_period_id_to FROM dual ' ;
        ELSE
      l_sql_periods_b := '' ;
      if(pi_organization_id_to is not null) then
          l_sql_periods_b :=  'SELECT  ' ||
                                    'c3.period_id ' ||
                           'FROM ' ||
                                    'gmf_period_statuses c3, gmf_period_statuses c2, gmf_period_statuses c1, hr_organization_information d ' ||
                           'WHERE ' ||
                                    'd.organization_id = :pi_organization_id_to AND '||
                                    'd.org_information_context = ''Accounting Information'' AND '||
                                    'c1.calendar_code = :pi_calendar_code_to AND ' ||
                                    'c1.period_code   = :pi_all_periods_from AND ' ||
                                    'c2.calendar_code = :pi_calendar_code_to AND ' ||
                                    'c2.period_code   = :pi_all_periods_to   AND ' ||
                                    'c3.calendar_code = :pi_calendar_code_to AND ' ||
                                    'c3.cost_type_id  = :pi_cost_type_id_to AND  ' ||
                                    'c2.cost_type_id  = c3.cost_type_id AND ' ||
                                    'c1.cost_type_id  = c2.cost_type_id AND ' ||
                                    'c3.legal_entity_id = d.org_information2 AND ' ||
                                    'c2.legal_entity_id = c3.legal_entity_id AND ' ||
                                    'c1.legal_entity_id = c2.legal_entity_id AND ' ||
                                    'c3.start_date >=   c1.start_date AND ' ||
                                    'c3.end_date <= c2.end_date AND ' ||
                                    'c3.period_status <> ''C'' ';
           else
                         l_sql_periods_b :=  'SELECT  ' ||
                                    'c3.period_id ' ||
                           'FROM ' ||
                                    'gmf_period_statuses c3, gmf_period_statuses c2, gmf_period_statuses c1 ' ||
                           'WHERE ' ||
                                    'c1.calendar_code = :pi_calendar_code_to AND ' ||
                                    'c1.period_code   = :pi_all_periods_from AND ' ||
                                    'c2.calendar_code = :pi_calendar_code_to AND ' ||
                                    'c2.period_code   = :pi_all_periods_to   AND ' ||
                                    'c3.calendar_code = :pi_calendar_code_to AND ' ||
                                    'c3.cost_type_id  = :pi_cost_type_id_to AND  ' ||
                                    'c2.cost_type_id  =  c3.cost_type_id AND ' ||
                                    'c1.cost_type_id  =  c2.cost_type_id AND ' ||
                                    'c3.legal_entity_id = :pi_all_org_id AND ' ||
                                    'c2.legal_entity_id = c3.legal_entity_id AND ' ||
                                    'c1.legal_entity_id = c2.legal_entity_id AND ' ||
                                    'c3.start_date >=   c1.start_date AND ' ||
                                    'c3.end_date <= c2.end_date AND ' ||
                                    'c3.period_status <> ''C'' ';
      end if;

      IF (pi_calendar_code_from = pi_calendar_code_to) THEN
         l_sql_periods_b := l_sql_periods_b||' AND c3.period_id <> :pi_period_id_from ';
      END IF ;
      l_sql_periods_b := l_sql_periods_b || 'ORDER BY c3.start_date' ;
   END IF ;      -- To Period code check


     gmf_util.trace( 'Organization Query : ' || l_sql_org_b, 3 );
     gmf_util.trace( 'Periods Query : ' || l_sql_periods_b, 3 );

          -- End Bug# 1419482
        /* begin sschinch dt 05/2/03 bug 2934528 Bind variable fix */

     IF (pi_period_id_to IS NOT NULL) THEN
             OPEN cv_periods FOR l_sql_periods_b
              USING pi_period_id_to;
     ELSIF (pi_calendar_code_from = pi_calendar_code_to) THEN
           if(pi_organization_id_to is not null) then
                OPEN cv_periods FOR l_sql_periods_b
                      USING pi_organization_id_to,
                        pi_calendar_code_to,
                             pi_all_periods_from,
                             pi_calendar_code_to,
                             pi_all_periods_to,
                        pi_calendar_code_to,
                        pi_cost_type_id_to,
                        pi_period_id_from;
            else
                OPEN cv_periods FOR l_sql_periods_b
                      USING pi_calendar_code_to,
                            pi_all_periods_from,
                            pi_calendar_code_to,
                            pi_all_periods_to,
                       pi_calendar_code_to,
                       pi_cost_type_id_to,
                       pi_all_org_id,
                       pi_period_id_from;

             end if;
       ELSIF (pi_calendar_code_from <> pi_calendar_code_to) THEN
           if(pi_organization_id_to is not null) then
                OPEN cv_periods FOR l_sql_periods_b
                      USING pi_organization_id_to,
                        pi_calendar_code_to,
                             pi_all_periods_from,
                             pi_calendar_code_to,
                             pi_all_periods_to,
                        pi_calendar_code_to,
                        pi_cost_type_id_to;
            else
                OPEN cv_periods FOR l_sql_periods_b
                      USING pi_calendar_code_to,
                            pi_all_periods_from,
                            pi_calendar_code_to,
                            pi_all_periods_to,
                       pi_calendar_code_to,
                       pi_cost_type_id_to,
                       pi_all_org_id;

             end if;
       END IF;

          -- Loop through periods using l_sql_periods_b
    LOOP
            FETCH cv_periods INTO l_period_id_to ;
            EXIT WHEN cv_periods%NOTFOUND ;

      IF (pi_organization_id_to IS NOT NULL) THEN
         OPEN cv_org FOR l_sql_org_b
              USING pi_organization_id_to;
           ELSIF ((pi_calendar_code_from = pi_calendar_code_to) AND
                     (pi_period_id_to IS NOT NULL) AND
                     (pi_period_id_from = pi_period_id_to)) THEN
                OPEN cv_org FOR l_sql_org_b
                  USING  pi_all_org_id,
                     pi_organization_id_from;
                ELSE
                 OPEN cv_org FOR l_sql_org_b
                   USING  pi_all_org_id;

          END IF;
        LOOP
                FETCH cv_org INTO l_organization_id_to ;
                EXIT WHEN cv_org%NOTFOUND ;

                       IF( pi_rem_repl = 1 ) THEN
                                -- deleting whole range of items
                                delete_burden_costs(
                                        l_organization_id_to,
                                        l_period_id_to,
                                        pi_cost_type_id_to,
                                        pi_range_type,
                                        pi_from_range, pi_to_range
                                );
                       END IF;

                     gmf_util.log;
                     gmf_util.msg_log('GMF_CPBRD_ALLWHSEPRD', l_organization_id_to, l_period_id_to ) ;

                -- Copy the burden costs
                        l_brdn_rows     := 0;
                        l_brdn_rows_upd := 0;
                        l_brdn_rows_ins := 0;
                       gmf_util.trace('From: Organization-'||pi_organization_id_from||
                                        ' cal-'||pi_calendar_code_from||' prd-'||pi_period_code_from||
                                        ' mthd-'||pi_cost_type_id_from||'itemfrom-'||pi_from_range||
                                        ' item2-'||pi_to_range,0);

                OPEN cv_brdn_dtl FOR l_sql_stmt_b USING
                     pi_organization_id_from,
                     pi_period_id_from,
                     pi_cost_type_id_from,
                pi_from_range,
           pi_to_range;
   LOOP
         FETCH cv_brdn_dtl INTO r_brdn_dtl;
         EXIT WHEN cv_brdn_dtl%NOTFOUND;

         gmf_util.trace( 'Item = ' || r_brdn_dtl.inventory_item_id ||
                                ' Rsrc ' || r_brdn_dtl.resources ||
                                ' cmpt ' || r_brdn_dtl.cost_cmpntcls_id ||
                                ' ancd ' || r_brdn_dtl.cost_analysis_code ||
                                ' bqty ' || r_brdn_dtl.burden_qty ||
                                ' busg ' || r_brdn_dtl.burden_usage ||
                                ' buom ' || r_brdn_dtl.burden_um ||
                                ' iqty ' || r_brdn_dtl.item_qty ||
                                ' iuom ' || r_brdn_dtl.item_um ||
                                ' bfct ' || r_brdn_dtl.burden_factor
                                , 0);


                        l_brdn_rows := l_brdn_rows + 1;

                        -- try update first
                        <<insert_or_update_bur>>
                        DECLARE
                                e_insert_row_b  EXCEPTION;
                  e_item_not_assigned EXCEPTION;
               BEGIN
                  l_assigned_flag := verify_item_assigned_to_org(
                                                        r_brdn_dtl.inventory_item_id, l_organization_id_to);

                  gmf_util.trace( 'Verify_item_assigned_to_org: Item ' || r_brdn_dtl.inventory_item_id ||
                                                        ' Organization ' || l_organization_id_to ||
                                                        ' Status = ' || l_assigned_flag, 3 );
                  IF(l_assigned_flag = 0) THEN
                     gmf_util.trace( 'Item ' || r_brdn_dtl.inventory_item_id ||
                                                        ' is not assigned to Organization ' || l_organization_id_to, 0 );
                     RAISE e_item_not_assigned;
                  END IF;

                                IF( pi_rem_repl = 1 ) THEN
                                        RAISE e_insert_row_b;
                                END IF;

                        UPDATE
                                cm_brdn_dtl
                        SET
--                              burdenline_id   = GEM5_BURDENLINE_ID_S.NEXTVAL,
                                burden_qty      = r_brdn_dtl.burden_qty,
                                burden_usage    = r_brdn_dtl.burden_usage,
                                burden_uom      = r_brdn_dtl.burden_um,
                                item_qty        = r_brdn_dtl.item_qty,
                                item_uom                = r_brdn_dtl.item_um,
                                burden_factor   = r_brdn_dtl.burden_factor,
                                rollover_ind    = 0,
                                cmpntcost_id    = NULL,
                                trans_cnt       = 1,
                                delete_mark     = 0,
                                text_code       = NULL,
                                last_updated_by         = g_user_id,
                                last_update_login       = g_login_id,
                                last_update_date        = SYSDATE,
                                request_id              = g_request_id,
                                program_application_id  = g_prog_appl_id,
                                program_id              = g_program_id,
                                program_update_date     = SYSDATE
                        WHERE
                                organization_id     = l_organization_id_to AND
                                inventory_item_id               = r_brdn_dtl.inventory_item_id AND
                                resources       = r_brdn_dtl.resources AND
                                period_id   = l_period_id_to AND
                                cost_type_id    = pi_cost_type_id_to AND
                                cost_cmpntcls_id        = r_brdn_dtl.cost_cmpntcls_id AND
                                cost_analysis_code      = r_brdn_dtl.cost_analysis_code;

                        -- If update fails then try insert
                        IF( SQL%ROWCOUNT <= 0 ) THEN
                                RAISE e_insert_row_b;
                        END IF;

                        l_brdn_rows_upd := l_brdn_rows_upd + 1;

       EXCEPTION
          WHEN e_insert_row_b THEN
                        INSERT INTO
                                 cm_brdn_dtl(
                                        burdenline_id,
                                        organization_id,
                                        inventory_item_id,
                                        resources,
                                        cost_cmpntcls_id,
                                        cost_analysis_code,
                                        burden_qty,
                                        burden_usage,
                                        burden_uom,
                                        item_qty,
                                        item_uom,
                                        burden_factor,
                                        rollover_ind,
                                        cmpntcost_id,
                                        trans_cnt,
                                        delete_mark,
                                        text_code,
                                        created_by,
                                        creation_date,
                                        last_updated_by,
                                        last_update_login,
                                        last_update_date,
                                        request_id,
                                        program_application_id,
                                        program_id,
                                        program_update_date,
                                        period_id,
                                        cost_type_id)
                            VALUES (
                                        GEM5_BURDENLINE_ID_S.NEXTVAL,   -- burdenline_id
                                        l_organization_id_to,
                                        r_brdn_dtl.inventory_item_id,
                                        r_brdn_dtl.resources,
                                        r_brdn_dtl.cost_cmpntcls_id,
                                        r_brdn_dtl.cost_analysis_code,
                                        r_brdn_dtl.burden_qty,
                                        r_brdn_dtl.burden_usage,
                                        r_brdn_dtl.burden_um,
                                        r_brdn_dtl.item_qty,
                                        r_brdn_dtl.item_um,
                                        r_brdn_dtl.burden_factor,
                                        0,                      -- rollover_ind
                                        NULL,                   -- cmpntcost_id
                                        1,                      -- trans_cnt
                                        0,                      -- delete_mark
                                        NULL,                   -- text_code
                                        g_user_id,              -- created_by
                                        SYSDATE,                -- creation_date
                                        g_user_id,              -- last_updated_by
                                        g_login_id,             -- last_update_login
                                        SYSDATE ,       -- last_update_date
                                        g_request_id,
                                        g_prog_appl_id,         -- program_application_id
                                        g_program_id,           -- program_id
                                        SYSDATE,                -- program_update_date
               l_period_id_to,
               pi_cost_type_id_to
                                );
           l_brdn_rows_ins := l_brdn_rows_ins + 1;

        WHEN e_item_not_assigned THEN
           NULL;
      END insert_or_update_bur;
           END LOOP;
           CLOSE cv_brdn_dtl;

        IF( l_brdn_rows > 0 ) THEN
                gmf_util.msg_log( 'GMF_CP_ROWS_SELECTED', TO_CHAR(l_brdn_rows) );
                gmf_util.msg_log( 'GMF_CP_ROWS_UPDINS', TO_CHAR(l_brdn_rows_upd), TO_CHAR(l_brdn_rows_ins) );
        ELSE
                gmf_util.msg_log( 'GMF_CP_NO_ROWS' );
        END IF;

        END LOOP ;              -- organization loop
        CLOSE cv_org;
   END LOOP ;           -- periods loop
   CLOSE cv_periods;

      gmf_util.log;
      gmf_util.msg_log( 'GMF_CPIC_BUR_END' );

END copy_burden_dtl;

/*****************************************************************************
 *  PROCEDURE
 *    delete_burden_costs
 *
 *  DESCRIPTION
 *    Deletes the burden costs for the parameters passed
 *
 *  INPUT PARAMETERS
 *    organization_id, calendar, period, cost_mthd, item or itemcost_class range
 *
 *  HISTORY
 *    13-Oct-1999 Rajesh Seshadri
 *
 ******************************************************************************/

PROCEDURE delete_burden_costs(
        pi_organization_id              IN cm_cmpt_dtl.organization_id%TYPE,
   pi_period_id         IN cm_cmpt_dtl.period_id%TYPE,
        pi_cost_type_id IN cm_cmpt_dtl.cost_type_id%TYPE,
        pi_range_type           IN NUMBER,
        pi_from_range           IN VARCHAR2,
        pi_to_range             IN VARCHAR2
        )
IS
        l_del_stmt_b    VARCHAR2(2000);
        l_sub_qry_b     VARCHAR2(2000);

BEGIN
   fnd_file.put_line(fnd_file.log,'In delete_burden_costs');
        l_del_stmt_b    := '';
        l_sub_qry_b     := '';

        l_del_stmt_b :=
        ' DELETE FROM ' ||
                ' cm_brdn_dtl bur ' ||
        ' WHERE ' ||
                ' bur.organization_id           = :b_organization_id AND ' ||
      ' bur.period_id   = :b_period_id AND ' ||
                ' bur.cost_type_id      = :b_cost_type_id AND ' ||
                ' bur.inventory_item_id IN ( '
        ;

        l_sub_qry_b :=
                ' SELECT ' ||
                        ' itm.inventory_item_id ' ||
                ' FROM ' ||
                        ' mtl_system_items_b_kfv itm ' ||
            ' WHERE ' ||
                        ' 1 = 1';
  IF ( pi_range_type = G_ITEM ) THEN
        l_sub_qry_b := l_sub_qry_b ||
                        ' AND itm.concatenated_segments >= nvl(:b_from_item,itm.concatenated_segments) ' ||
                        ' AND itm.concatenated_segments <= nvl(:b_to_item,itm.concatenated_segments) ' ;

        ELSIF ( pi_range_type = G_ITEMCC ) THEN
   l_sub_qry_b := l_sub_qry_b ||
         ' AND EXISTS (select  ''X'' from mtl_default_category_sets mdc, mtl_category_sets mcs, mtl_item_categories y, mtl_categories_kfv z
                                 where  mdc.functional_area_id = 19
                                      and       mdc.category_set_id = mcs.category_set_id
                                      and       mcs.category_set_id = y.category_set_id
                                 and    mcs.structure_id = z.structure_id
                                 and   y.inventory_item_id = itm.inventory_item_id
                                 and   y.organization_id = itm.organization_id
                                 and   y.category_id = z.category_id
                                 and   z.concatenated_segments >= nvl(:b_from_itemcc, z.concatenated_segments)
                                 and   z.concatenated_segments <= nvl(:b_to_itemcc, z.concatenated_segments))';

        ELSE
                gmf_util.msg_log( 'GMF_CPIC_UNKNOWN' );
                RETURN;
        END IF;

        gmf_util.trace( 'Burden del sub-qry: ' || l_sub_qry_b, 3 );

        l_del_stmt_b := l_del_stmt_b || l_sub_qry_b || ' ) ' ;

        gmf_util.trace( ' Burden Del Stmt: ' || l_del_stmt_b, 3 );

BEGIN
        EXECUTE IMMEDIATE l_del_stmt_b USING
                pi_organization_id,
                pi_period_Id, pi_cost_type_id,
                pi_from_range, pi_to_range;
EXCEPTION
      WHEN OTHERS THEN
      fnd_file.put_line(fnd_file.log,'THE ERROR IS :'||SQLERRM);
END;
gmf_util.trace( SQL%ROWCOUNT || ' Rows deleted from Burden Details', 0);

END delete_burden_costs;

/*****************************************************************************
 *  FUNCTION
 *    verify_item_assigned_to_org
 *
 *  DESCRIPTION
 *    Verifies if the item is assigned to the org or not
 *
 *  INPUT PARAMETERS
 *    organization_id, item_id
 *
 *  HISTORY
 *    11 April 2006 Jahnavi Boppana
 *
 ******************************************************************************/

FUNCTION verify_item_assigned_to_org(
        pi_inventory_item_id            IN cm_cmpt_dtl.inventory_item_id%TYPE,
        pi_organization_id      IN cm_cmpt_dtl.organization_id%TYPE
        )
RETURN NUMBER IS
   l_assigned_ind       NUMBER;
BEGIN
        gmf_util.trace( 'Entering verify_item_assigned_to_org', 0 );

        l_assigned_ind := 0;
        SELECT count(1) INTO l_assigned_ind
        FROM
              mtl_system_items_b
        WHERE
              organization_id   = pi_organization_id AND
              inventory_item_id               = pi_inventory_item_id
        ;
  RETURN l_assigned_ind;

END verify_item_assigned_to_org;


END GMF_COPY_ITEM_COST ;

/
