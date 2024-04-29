--------------------------------------------------------
--  DDL for Package GMS_PA_API3
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."GMS_PA_API3" AUTHID CURRENT_USER AS
/* $Header: gmspax3s.pls 120.4 2008/01/24 08:59:51 prabsing ship $ */

      -- =====================
      -- Start of the comment
      -- API Name 	: grants_enabled
      -- Type		: Public
      -- Pre_reqs	: None
      -- Description	: Determine the grants implementations for a
      --                  operating unit. The value returned here is
      --                  from the cache.
      -- Parameters     : None
      -- Return Value   : 'Y' - Grants is implemented for a MO Org.
      --                  'N'- Grants is not implemented.
      --
      -- End of comments
      -- ===============

      FUNCTION grants_enabled return VARCHAR  ;
      --pjr12ir1 build issue resolved.
      --pragma RESTRICT_REFERENCES (grants_enabled, WNDS, WNPS );

      -- =====================
      -- Start of the comment
      -- API Name 	: override_rate_rev_id
      -- Type		: Public
      -- Pre_reqs	: None
      -- Description	: The purpose of this API is to determine
      --                  the schedule based on the award.
      -- Called from    : PA_COST_PLUS.find_rate_sch_rev_id
      -- Return Value   : None
      --
      -- Parameters     :
      -- IN             :
      --                  p_tran_item_id    Expenditure item id
      --                  p_tran_type       Transaction type
      --                  p_task_id         Task ID
      --                  p_schedule_type   Schedule Type
      --                  p_exp_item_date   Expenditure item date
      --OUT               x_sch_fixed_date  Schedule fixed date.
      --                  x_rate_sch_rev_id Revision ID
      --                  x_status          Status
      -- End of comments
      -- ===============

      PROCEDURE override_rate_rev_id(
                           p_tran_item_id          IN         number   DEFAULT NULL,
                           p_tran_type             IN         Varchar2 DEFAULT NULL,
                           p_task_id         	   IN         number   DEFAULT NULL,
                           p_schedule_type         IN         Varchar2 DEFAULT NULL,
                           p_exp_item_date         IN         Date     DEFAULT NULL,
                           x_sch_fixed_date        IN OUT nocopy Date,
                           x_rate_sch_rev_id 	   OUT nocopy number,
                           x_status                OUT nocopy number ) ;

         --- pragma RESTRICT_REFERENCES (override_rate_rev_id, WNDS, WNPS ); /* commented as per 3786374 */

      -- =====================
      -- Start of the comment
      -- API Name 	: commitments_changed
      -- Type		: Public
      -- Pre_reqs	: None
      -- Description	: The purpose of this API is to determine
      --                  the new manual encumbrances generated
      --                  since the last run of PSI process.
      -- Called from    : PA_CHECK_COMMITMENTS.COMMITMENTS_CHANGED
      -- Return Value   : Y
      --                  N
      --
      -- Parameters     :
      -- IN             :
      --                  p_project_id    Project ID value
      -- End of comments
      -- ===============
      -- REL12 commitments changed was removed.
      -- merged in pa_check_commitments (PAXCMTVB.pls)

      -- =====================
      -- Start of the comment
      -- API Name       : is_award_same
      -- Type           : Public
      -- Pre_reqs       : None
      -- Description    : The purpose of this API is to compare the award entered by the user in expenditure
      --                  entry form and the award for the reversal item found is same or not.
      -- Called from    : exp_items_private.check_matching_reversal
      -- Return Value   : Y
      --                  N
      --
      -- Parameters     :
      -- IN             :
      --                  expenditure_item_id  Item id of matching reversal item
      --                  award_number         Award Number entered in expenidture entry form.
      -- End of comments
      -- ===============
         FUNCTION is_award_same (P_expenditure_item_id IN NUMBER,P_award_number IN VARCHAR2 )
           RETURN VARCHAR2 ;

      -- =====================
      -- Start of the comment
      -- API Name       : create_cmt_txns
      -- Type           : Public
      -- Pre_reqs       : None
      -- Description    : The purpose of this API is to create commitment transactions
      --                  using the GMS view and called from the PSI process .
      -- Called from    : PA_TXN_ACCUMS.create_cmt_txns
      -- Return Value   : None
      --
      -- Parameters     :
      -- IN             :
      --                  p_start_project_id         Starting project id in the range.
      --                  p_end_project_id           Last project id in the range.
      --                  p_system_linkage_function  System Linkage function
      -- End of comments
      -- ===============
         PROCEDURE create_cmt_txns ( p_start_project_id     IN NUMBER,
				     p_end_project_id       IN NUMBER,
				     p_system_linkage_function IN VARCHAR2 ) ;

      -- =====================
      -- Start of the comment
      -- API Name       : is_project_type_sponsored
      -- Type           : Public
      -- Pre_reqs       : None
      -- Description    : The purpose of this API is to check if project type is
      --                  marked as sponsored in Grants Accounting.
      -- Called from    :  project type entry and project entry form
      -- Return Value   : Y - Yes
      --                  N - No
      --
      -- Parameters     :
      -- IN             :
      --                  p_project_type          varchar2
      -- End of comments
      -- ===============
         FUNCTION is_project_type_sponsored ( p_project_type     IN VARCHAR2 )
	 return varchar2 ;
	 PRAGMA RESTRICT_REFERENCES(is_project_type_sponsored , WNDS, WNPS) ;

      -- Bug 5726575
      -- =====================
      -- Start of the comment
      -- API Name       : mark_impacted_enc_items
      -- Type           : Public
      -- Pre_reqs       : None
      -- Description    : This procedure is called from
      --                  pa_cost_plus.mark_impacted_exp_items (PAXCCPEB.pls).
      --                  This procedure will mark all the burden impacted lines
      --                  in gms_encumbrance_items_all.
      --
      -- Called from    : pa_cost_plus.mark_impacted_exp_items
      -- Return Value   : None
      --
      -- Parameters     :
      -- IN             :p_ind_compiled_set_id
      --                 p_g_impacted_cost_bases
      --                 p_g_cp_structure
      --                 p_indirect_cost_code
      --                 p_rate_sch_rev_id
      --                 p_g_rate_sch_rev_id
      --                 p_g_org_id
      --                 p_g_org_override
      -- OUT            :errbuf
      --                 retcode
      -- End of comments
      -- ===============

      Procedure mark_impacted_enc_items (p_ind_compiled_set_id in number,
                                         p_g_impacted_cost_bases in varchar2,
                                         p_g_cp_structure in varchar2,
                                         p_indirect_cost_code in varchar2,
                                         p_rate_sch_rev_id in number,
                                         p_g_rate_sch_rev_id in number,
                                         p_g_org_id in number,
                                         p_g_org_override in number,
                                         errbuf OUT NOCOPY VARCHAR2,
                                         retcode OUT NOCOPY     VARCHAR2);

      -- Bug 5726575
      -- =====================
      -- Start of the comment
      -- API Name       : mark_prev_rev_enc_items
      -- Type           : Public
      -- Pre_reqs       : None
      -- Description    : This procedure is called from
      --                  pa_cost_plus.mark_prev_rev_exp_items (PAXCCPEB.pls).
      --                  This procedure will mark all the burden impacted lines
      --                  in gms_encumbrance_items_all.
      --
      -- Called from    : pa_cost_plus.mark_prev_rev_exp_items
      -- Return Value   : None
      --
      -- Parameters     :
      -- IN             :p_compiled_set_id
      --                 p_start_date
      --                 p_end_date
      --                 p_mode
      -- OUT            :errbuf
      --                 retcode
      -- End of comments
      -- ===============
      Procedure mark_prev_rev_enc_items (p_compiled_set_id in number,
                                         p_start_date in date,
                                         p_end_date in date,
                                         p_mode in varchar2,
                                         errbuf OUT NOCOPY VARCHAR2,
                                         retcode OUT NOCOPY     VARCHAR2);

      -- Bug 6761516
      -- =====================
      -- Start of the comment
      -- API Name       : mark_enc_items_for_recalc
      -- Type           : Public
      -- Pre_reqs       : None
      -- Description    : This procedure is called from
      --                  GMSAWEAW.fmb and GMSICOVR.fmb.
      --                  This procedure will mark all the associated encumbrance items for recalc
      --                  on insertion, uodation or deletion in Award Management Compliance Screen
      --                  or in Override Schedules Screen.
      --
      -- Called from    : GMSAWEAW.fmb and GMSICOVR.fmb
      -- Return Value   : None
      --
      -- Parameters     :
      -- IN             :p_ind_rate_sch_id
      --                 p_award_id
      --                 p_project_id
      --                 p_task_id
      --                 p_calling_form
      --                 p_event
      --                 p_idc_schedule_fixed_date
      -- OUT            :errbuf
      --                 retcode
      -- End of comments
      -- ===============
    Procedure mark_enc_items_for_recalc (p_ind_rate_sch_id in number,
                                         p_award_id in number,
                                         p_project_id in number,
                                         p_task_id in number,
                                         p_calling_form in varchar2,
                                         p_event in varchar2,
                                         p_idc_schedule_fixed_date in date,
                                         errbuf OUT NOCOPY VARCHAR2,
                                         retcode OUT NOCOPY     VARCHAR2);


      -- Bug 6761516
      -- =====================
      -- Start of the comment
      -- API Name 	: item_task_validate
      -- Type		: Public
      -- Pre_reqs	: None
      -- Description	: This function is called from mark_enc_items_for_recalc
      --                  to perform item validations.
      --                  1. If record being inserted/updated/deleted from overrides schedule
      --                     screen does not have task details, then this function returns 'N'
      --                     if any other override exists for same project, award ,top_task for
      --                     the task of enc. in picture combination, else returns 'Y'
      --                  2. If record being inserted/updated/deleted from overrides schedule
      --                     screen has task details, then just match the top task of the enc.
      --                     in picture with the task on the record.
      -- Parameters     : p_award_id number,
      --                  p_project_id number,
      --                  p_task_id number,
      --                  p_item_task_id number
      -- Return Value   : 'Y' - Encumbrance needs to be marked for recalc.
      --                  'N' - Encumbrance should not be marked for recalc.
      --
      -- End of comments
      -- ===============
    Function item_task_validate (p_award_id number,
                                 p_project_id number,
                                 p_task_id number,
                                 p_item_task_id number)
    return varchar2;

END gms_pa_api3;

/
