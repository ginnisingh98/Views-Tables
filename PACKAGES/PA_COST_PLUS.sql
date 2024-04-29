--------------------------------------------------------
--  DDL for Package PA_COST_PLUS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PA_COST_PLUS" AUTHID CURRENT_USER as
-- $Header: PAXCCPES.pls 120.7 2006/07/25 19:41:15 skannoji noship $
/*#
 * Oracle Projects provides a procedure you can use to call the Cost Plus Application Programming Interface.
 * @rep:scope public
 * @rep:product PA
 * @rep:lifecycle active
 * @rep:displayname  Cost Plus Applications Programming Interface (API)
 * @rep:compatibility S
 * @rep:category BUSINESS_ENTITY PA_PROJECT
 * @rep:category BUSINESS_ENTITY PA_PROJ_COST
 * @rep:doccd 120pjapi.pdf See the Oracle Projects API's, Client Extensions, and Open Interfaces Reference
*/

   TYPE precedence_tab_type IS TABLE OF pa_compiled_multipliers.precedence%TYPE
        INDEX BY BINARY_INTEGER;
   TYPE ind_cost_code_tab_type IS TABLE OF
	pa_compiled_multipliers.ind_cost_code%TYPE INDEX BY BINARY_INTEGER;
   TYPE multiplier_tab_type IS TABLE OF pa_ind_cost_multipliers.multiplier%TYPE
        INDEX BY BINARY_INTEGER;
   /*2933915*/
   TYPE org_tab_type is TABLE of pa_ind_cost_multipliers.organization_id%TYPE
   INDEX BY BINARY_INTEGER;
   /*2933915*/

   /* Bug 3786374 : The SQL retriving ind_rate_schedule_type exceeded apps execution threshold */
	g_sch_id					pa_ind_rate_schedules.ind_rate_sch_id%type;
	g_ind_rate_schedule_type	pa_ind_rate_schedules.ind_rate_schedule_type%type;

/* S.N. Bug 3938479 */

   g_rate_sch_rev_id   pa_ind_rate_sch_revisions.ind_rate_sch_revision_id%type;
   g_org_id            pa_ind_cost_multipliers.organization_id%type;
   g_org_override      NUMBER;

/* E.N. Bug 3938479 */


    procedure compile_org_rates(rate_sch_rev_id  IN number,
			    org_id 	     IN     Number,
                            org_struc_ver_id IN     Number,
                            start_org        IN     Number,
			    status 	     IN OUT NOCOPY number,
			    stage	     IN OUT NOCOPY number);

    procedure compile_org_hierarchy_rates(rate_sch_rev_id IN number,
                               org_id 	       IN number,
                               comp_type       IN varchar2,
			       status 	       IN OUT NOCOPY number,
			       stage	       IN OUT NOCOPY number);

    procedure new_organization(errbuf IN OUT NOCOPY varchar2,
                               retcode IN OUT NOCOPY varchar2,
			       organization_id IN varchar2);

    procedure compile_schedule(errbuf IN OUT NOCOPY varchar2,
                          retcode IN OUT NOCOPY varchar2,
                          sch_rev_id IN varchar2);

    procedure compile_all(errbuf IN OUT NOCOPY varchar2,
                          retcode IN OUT NOCOPY varchar2);

    /*
       Multi-Currency related changes :
       Two more parameters added: indirect_cost_acct
                                  indirect_cost_denom
     */
    procedure get_exp_item_indirect_cost(exp_item_id     IN     Number,
                                     schedule_type       IN     Varchar2,
                                     indirect_cost       IN OUT NOCOPY Number,
                                     indirect_cost_acct  IN OUT NOCOPY NUMBER,
                                     indirect_cost_denom IN OUT NOCOPY NUMBER,
                                     indirect_cost_project IN OUT NOCOPY NUMBER, /* ProjCurr changes*/
                                     rate_sch_rev_id     IN OUT NOCOPY Number,
                                     compiled_set_id     IN OUT NOCOPY Number,
                                     status              IN OUT NOCOPY Number,
                                     stage               IN OUT NOCOPY Number);

    procedure get_exp_item_burden_amount(exp_item_id  IN     Number,
                                     schedule_type    IN     Varchar2,
                                     burden_amount    IN OUT NOCOPY Number,
                                     rate_sch_rev_id  IN OUT NOCOPY Number,
                                     compiled_set_id  IN OUT NOCOPY Number,
                                     status           IN OUT NOCOPY Number,
                                     stage            IN OUT NOCOPY Number);

    procedure populate_indirect_cost(update_count  IN OUT NOCOPY Number);

    procedure get_indirect_cost_sum (org_id 	    	IN     number,
                               	     c_base 	    	IN     varchar2,
                                     rate_sch_rev_id    IN     number,
                                     direct_cost 	IN     number,
                                     precision          IN     number,
                                     indirect_cost_sum  IN OUT NOCOPY number,
			    	     status	    	IN OUT NOCOPY number,
			    	     stage	    	IN OUT NOCOPY number);

--    pragma RESTRICT_REFERENCES (get_indirect_cost_sum, WNDS, WNPS );

/*
    procedure get_detail_indirect_costs(exp_item_id IN Number,
                        schedule_type       IN     Varchar2,
                        ind_cost_code_num   IN OUT NOCOPY Number,
                        c_base  	    IN OUT NOCOPY Varchar2,
                        precedence          IN OUT NOCOPY precedence_tab_type,
                        ind_cost_code       IN OUT NOCOPY ind_cost_code_tab_type,
                        compiled_multiplier IN OUT NOCOPY multiplier_tab_type,
                        indirect_cost       IN OUT NOCOPY multiplier_tab_type,
                        status              IN OUT NOCOPY number,
                        stage               IN OUT NOCOPY number);
*/

    procedure view_indirect_cost(    transaction_id   IN     Number,
                                     transaction_type IN     Varchar2,
                                     task_id       IN     Number,
                                     effective_date   IN     Date,
                                     expenditure_type IN     Varchar2,
                                     organization_id  IN     Number,
                                     schedule_type    IN     Varchar2,
                                     direct_cost      IN     Number,
                                     indirect_cost    IN OUT NOCOPY Number,
                                     status           IN OUT NOCOPY Number,
                                     stage            IN OUT NOCOPY Number);
	/* Bug 3786374 : Caching introduced in get_revision_by_date and hence in this procedure also */
    --- pragma RESTRICT_REFERENCES (view_indirect_cost, WNDS, WNPS );


/*#
 * This procedure retrieves an amount based on your burden cost setup. You can
 * specify the burden schedule, effective date, expenditure type, and
 * organization, and retrieve the burden cost amount based on the criteria you specify.
 * @param burden_schedule_id The schedule ID of the burden schedule used to calculate the burden amount
 * @rep:paraminfo {@rep:required}
 * @param effective_date The date used to identify the burden schedule revision to calculate the burden amount
 * @rep:paraminfo {@rep:required}
 * @param expenditure_type The type of expenditure item used to find a cost base
 * @rep:paraminfo {@rep:required}
 * @param organization_id The ID of the organization used to find a multiplier
 * @rep:paraminfo {@rep:required}
 * @param raw_amount The raw amount for which the burden amount is calculated
 * @rep:paraminfo {@rep:required}
 * @param burden_amount The calculated burden amount
 * @rep:paraminfo {@rep:required}
 * @param burden_sch_rev_id The schedule revision ID of the burden schedule used to calculate the burden amount
 * @rep:paraminfo {@rep:required}
 * @param compiled_set_id  The ID of the active compiled set used to calculate the burden amount
 * @rep:paraminfo {@rep:required}
 * @param status The processing status of the procedure
 * @rep:paraminfo {@rep:required}
 * @param stage The exit stage of the procedure
 * @rep:paraminfo {@rep:required}
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:displayname Get Burden Amount
 * @rep:compatibility S
*/
    procedure get_burden_amount(burden_schedule_id   IN     Number,
                                effective_date       IN     Date,
                                expenditure_type     IN     Varchar2,
                                organization_id      IN     Number,
                                raw_amount           IN     Number,
                                burden_amount        IN OUT NOCOPY Number,
			        burden_sch_rev_id    IN OUT NOCOPY Number,
			        compiled_set_id      IN OUT NOCOPY Number,
                                status               IN OUT NOCOPY Number,
                                stage                IN OUT NOCOPY Number);

    /* added for bug#3117191 */
    procedure get_burden_amount1(--burden_schedule_id   IN     Number,
                                --effective_date       IN     Date,
                                expenditure_type     IN     Varchar2,
                                organization_id      IN     Number,
                                raw_amount           IN     Number,
                                burden_amount        IN OUT NOCOPY Number,
                                burden_sch_rev_id    IN OUT NOCOPY Number,
                                compiled_set_id      IN OUT NOCOPY Number,
                                status               IN OUT NOCOPY Number,
                                stage                IN OUT NOCOPY Number);
     /* end for bug#3117191 */

    procedure get_hierarchy_from_revision(p_sch_rev_id IN  number,
                              x_org_struc_ver_id    OUT NOCOPY number,
                              x_start_org           OUT NOCOPY number,
                              x_status              OUT NOCOPY number,
                              x_stage               OUT NOCOPY number);

    procedure find_rate_sch_rev_id(
                        transaction_id IN Number,
                        transaction_type IN Varchar2,
                        t_id            IN Number,
                        schedule_type   IN Varchar2,
                        exp_item_date   IN  Date,
                        sch_id          IN OUT NOCOPY Number,
                        rate_sch_rev_id IN OUT NOCOPY Number,
                        sch_fixed_date  IN OUT NOCOPY Date,
                        status          IN OUT NOCOPY Number,
                        stage           IN OUT NOCOPY Number);
	/* Bug# 3786374 Used Caching in get_revision_by_date. Hence in this procedure also. */
    --- pragma RESTRICT_REFERENCES (find_rate_sch_rev_id, WNDS, WNPS );

    procedure get_rate_sch_rev_id(exp_item_id IN Number,
                        schedule_type   IN     Varchar2,
                        rate_sch_rev_id IN OUT NOCOPY Number,
                        status          IN OUT NOCOPY Number,
                        stage           IN OUT NOCOPY Number);

    procedure get_cost_base(exp_type             IN     varchar2,
                            cp_structure  	 IN     varchar2,
                            c_base               IN OUT NOCOPY varchar2,
			    status	         IN OUT NOCOPY number,
			    stage	         IN OUT NOCOPY number);

--    pragma RESTRICT_REFERENCES (get_cost_base, WNDS, WNPS );

    procedure get_cost_plus_structure(rate_sch_rev_id   IN     Number,
                                   cp_structure         IN OUT NOCOPY Varchar2,
                                   status               IN OUT NOCOPY number,
                                   stage                IN OUT NOCOPY number);

--    pragma RESTRICT_REFERENCES (get_cost_plus_structure, WNDS, WNPS );

    procedure get_organization_id(exp_item_id    IN     Number,
                                   organization_id      IN OUT NOCOPY Number,
                                   status               IN OUT NOCOPY Number,
                                   stage                IN OUT NOCOPY Number);

    procedure get_compiled_set_id(rate_sch_rev_id    IN     Number,
                                  org_id    	     IN     Number,
 			          c_base             IN     Varchar2,        /*2933915*/
                                  compiled_set_id    IN OUT NOCOPY Number,
                                  status             IN OUT NOCOPY Number,
                                  stage              IN OUT NOCOPY Number);

--    pragma RESTRICT_REFERENCES (get_compiled_set_id, WNDS, WNPS );

    procedure get_revision_by_date(sch_id            IN     Number,
                                   sch_fixed_date    IN     Date,
                                   exp_item_date     IN     Date,
                                   rate_sch_rev_id   IN OUT NOCOPY Number,
                                   status            IN OUT NOCOPY Number,
                                   stage             IN OUT NOCOPY Number);

	/* Bug 3786374 : Used caching */
    --- pragma RESTRICT_REFERENCES (get_revision_by_date, WNDS, WNPS );

    procedure check_revision_used(rate_sch_rev_id IN number,
				  status IN OUT NOCOPY number,
			     	  stage	 IN OUT NOCOPY number);

    procedure check_structure_used(structure IN varchar2,
				  status IN OUT NOCOPY number,
			     	  stage	 IN OUT NOCOPY number);

    procedure copy_structure(source      IN 	varchar2,
			     destination IN 	varchar2,
			     status	 IN OUT NOCOPY number,
			     stage	 IN OUT NOCOPY number);

/*
    procedure copy_multipliers(source      IN     number,
                               destination IN     number,
                               status      IN OUT NOCOPY number,
                               stage       IN OUT NOCOPY number);
*/


    procedure mark_impacted_exp_items(rate_sch_rev_id      IN     number,
                                    status      IN OUT NOCOPY number,
                                    stage       IN OUT NOCOPY number);

    procedure mark_prev_rev_exp_items(compiled_set_id IN number,
                                  rev_type IN varchar2,
				  reason IN varchar2,
                                  l_start_date IN date,
                                  l_end_date IN date,
                                  status IN OUT NOCOPY number,
                                  stage  IN OUT NOCOPY number);

    /*S.N. Bug 4527736 Changed Procedure Signature.*/
    procedure add_adjustment_activity(
                                    --compiled_set_id IN number,
                                    --  p_cost_base       IN pa_cost_bases.cost_base%TYPE
                                    -- ,p_cost_plus_structure IN pa_cost_plus_structures.cost_plus_structure%TYPE,
                                 -- cost_adj_reason IN varchar2,
                                --  rev_adj_reason  IN varchar2,
                                --  inv_adj_reason  IN varchar2,
                                --  tp_adj_reason  IN varchar2,
                                   l_expenditure_item_id_tab IN PA_PLSQL_DATATYPES.IDTABTYP
                                  ,l_adj_type_tab IN PA_PLSQL_DATATYPES.Char30TabTyp
                                  ,status          IN OUT NOCOPY number
                                  ,stage           IN OUT NOCOPY number);
   /*E.N. Bug 4527736 Changed Procedure Signature.*/

    procedure disable_rate_sch_revision(rate_sch_rev_id  IN    number,
                                        ver_id           IN    number,                /*2933915*/
	                                org_id           IN    number,               /*2933915*/
                                        status      IN OUT NOCOPY number,
                                        stage       IN OUT NOCOPY number);

    procedure disable_sch_rev_org(rate_sch_rev_id  IN    number,
				  org_id      IN     number,
                                  status      IN OUT NOCOPY number,
                                  stage       IN OUT NOCOPY number);

    procedure get_indirect_cost_amounts (x_indirect_cost_costing IN OUT NOCOPY number,
                                     x_indirect_cost_revenue IN OUT NOCOPY number,
                                     x_indirect_cost_invoice IN OUT NOCOPY number,
                                     x_task_id               IN     number,
                                     x_gl_date               IN     date,
                                     x_expenditure_type      IN     varchar2,
                                     x_organization_id       IN     number,
                                     x_direct_cost           IN     number,
			    	     x_return_status	     IN OUT NOCOPY number,
			    	     x_stage	    	     IN OUT NOCOPY number);


    procedure get_ind_rate_sch_rev(x_ind_rate_sch_name      IN OUT NOCOPY varchar2,
                               x_ind_rate_sch_revision      IN OUT NOCOPY varchar2,
                               x_ind_rate_sch_revision_type IN OUT NOCOPY varchar2,
                               x_start_date_active          IN OUT NOCOPY date,
                               x_end_date_active            IN OUT NOCOPY date,
                               x_task_id                    IN     number,
                               x_gl_date                    IN     date,
                               x_detail_type_flag           IN     varchar2,
                               x_expenditure_type           IN     varchar2,
                               x_cost_base                  IN OUT NOCOPY varchar2,
                               x_ind_compiled_set_id        IN OUT NOCOPY number,
                               x_organization_id            IN     number,
			       x_return_status	            IN OUT NOCOPY number,
			       x_stage	    	            IN OUT NOCOPY number);

    /*
       Multi-Currency related changes :
       New Procedure added
     */
    PROCEDURE Get_Compiled_Multiplier( P_Org_Id               IN     NUMBER,
                                       P_C_Base               IN     VARCHAR2,
                                       P_Rate_Sch_Rev_Id      IN     NUMBER,
                                       P_Compiled_Multiplier  IN OUT NOCOPY NUMBER,
                                       P_Status               IN OUT NOCOPY NUMBER,
                                       P_Stage                IN OUT NOCOPY NUMBER );

     /*Bug# 2110452:To implement the same logic as is used in R10.7/R11.0 for
     burden cost calculation*/

   procedure get_indirect_cost_sum1 (org_id                    IN     number,
                                     c_base                    IN     varchar2,
                                     rate_sch_rev_id           IN     number,
                                     direct_cost               IN     number,
                                     direct_cost_denom         IN     number,
                                     direct_cost_acct          IN     number,
                                     direct_cost_project       IN     number,
                                     precision                 IN     number,
                                     indirect_cost_sum         IN OUT NOCOPY number,
                                     indirect_cost_denom_sum   IN OUT NOCOPY number,
                                     indirect_cost_acct_sum    IN OUT NOCOPY number,
                                     indirect_cost_project_sum IN OUT NOCOPY number,
                                     l_projfunc_currency_code  IN     varchar2,
                                     l_project_currency_code   IN     varchar2,
                                     l_acct_currency_code      IN     varchar2,
                                     l_denom_currency_code     IN     varchar2,
                                     status                    IN OUT NOCOPY number,
                                     stage                     IN OUT NOCOPY number);
/*End of changes for bug# 2110452*/

    FUNCTION Get_Mltplr_For_Compiled_Set( P_Ind_Compiled_Set_ID IN NUMBER)
      RETURN Number;

--    PRAGMA RESTRICT_REFERENCES (Get_Mltplr_For_Compiled_Set, WNDS, WNPS );

    FUNCTION check_for_explicit_multiplier(rate_sch_rev_id IN NUMBER,org_id IN NUMBER)  /*3016281*/
      RETURN NUMBER ;
 /**2933915 :Added two new procedures **/
procedure delete_rate_sch_revision(rate_sch_rev_id   IN    number,
                                    ver_id           IN    number,
                                    org_id           IN    number,
                                    status           IN OUT NOCOPY number,
                                    stage            IN OUT NOCOPY number) ;

procedure find_impacted_top_org(rate_sch_rev_id  IN    number,
                                ver_id           IN    number ,
				start_org        IN    number ,
                                org_tab          OUT   NOCOPY org_tab_type,
				status           IN OUT NOCOPY number) ;

 /*End of changes for 2933915*/
end PA_COST_PLUS ;

 

/
