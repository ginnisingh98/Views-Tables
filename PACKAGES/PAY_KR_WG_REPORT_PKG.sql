--------------------------------------------------------
--  DDL for Package PAY_KR_WG_REPORT_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PAY_KR_WG_REPORT_PKG" AUTHID CURRENT_USER AS
/* $Header: pykrwgrp.pkh 115.4 2003/05/30 07:26:49 nnaresh noship $ */

  ---------------------------------------------------------------------------------
  /*                    FUNCTION processing_type                                 */
  --                    ------------------------
  -- This function returns the Processing Type of a court order.
  --
  ---------------------------------------------------------------------------------
  FUNCTION processing_type (p_element_entry_id   IN   NUMBER)
  RETURN VARCHAR2;
  --====================================================================================



  -------------------------------------------------------------------------------
  /*                       FUNCTION Obligation_exists                         */
  --                       --------------------------
  -- This function returns TRUE if Obligation Release exists for a court ordery.
  --
  -------------------------------------------------------------------------------
  FUNCTION Obligation_exists (p_element_entry_id   IN   pay_element_entries_f.element_entry_id%TYPE
                             ,p_effective_date     IN   DATE  DEFAULT NULL)
  RETURN BOOLEAN;
  --====================================================================================



  ------------------------------------------------------------------------------------
  /*                       FUNCTION get_element_entry_id                            */
  --                       -----------------------------
  -- This function returns the element_entry_id for a attachment sequence number.
  -- Bug 2856663 : Added parameter p_assignment_id
  ------------------------------------------------------------------------------------
  FUNCTION get_element_entry_id (p_assignment_id       IN   per_assignments_f.assignment_id%type
			        ,p_attachment_seq_no   IN   VARCHAR2)
  RETURN NUMBER;
  --====================================================================================



  ------------------------------------------------------------------------------------
  /*                       FUNCTION get_attach_seq_no                               */
  --                       ---------------------------
  -- This function returns the attachment sequence number for a element_entry_id.
  --
  ------------------------------------------------------------------------------------
  FUNCTION get_attach_seq_no(p_element_entry_id    IN   pay_element_entries_f.element_entry_id%TYPE)
  RETURN VARCHAR2;
  --====================================================================================



  ---------------------------------------------------------------------------------
  /*                    FUNCTION prev_case_attachment_seq_no                     */
  --                    ------------------------------------
  -- This function returns the attachment sequence number of the previous case for
  -- a Actual Attachment court order.
  --
  ---------------------------------------------------------------------------------
  FUNCTION prev_case_attachment_seq_no (p_element_entry_id    IN   NUMBER)
  RETURN VARCHAR2;
  --====================================================================================



  --------------------------------------------------------------------------------------
  /*                    Function wage_garnishment_exists                              */
    --                  --------------------------------
    -- returns 'TRUE' if there are any active 'Court Orders' against this assignment
    -- returns 'FALSE' if there are no active 'Court Orders' against this assignment
    --
  --------------------------------------------------------------------------------------
  FUNCTION wage_garnishment_exists (p_assignment_id     IN    per_assignments_f.assignment_id%TYPE
                                   ,p_effective_date    IN    date  DEFAULT  NULL)
  RETURN BOOLEAN;
  --====================================================================================



  --------------------------------------------------------------------------------------
  /*             Function paid_amount_this_run  (for single creditor)                 */
    --           ----------------------------------------------------
    -- returns the  amount that was deducted from  payroll in this payroll run  for a creditor
    --
  --------------------------------------------------------------------------------------
  FUNCTION paid_amount_this_run (p_assignment_action_id   IN   pay_assignment_actions.assignment_action_id%TYPE
                                ,p_element_entry_id       IN   pay_element_entries_f.element_entry_id%TYPE )
  RETURN NUMBER;
  --====================================================================================




  --------------------------------------------------------------------------------------
  /*             Function paid_amount_this_run  (for all creditors)                   */
    --           ----------------------------------------------------
    -- returns the total amount that was deducted from the payroll for this assignment
    -- in this payroll run
    -- total_paid_amount = Balance WG_DEDUCTIONS_ASG_RUN
    --
  --------------------------------------------------------------------------------------
  FUNCTION paid_amount_this_run (p_assignment_action_id   IN   pay_assignment_actions.assignment_action_id%TYPE)
  RETURN NUMBER;
  --====================================================================================




  --------------------------------------------------------------------------------------
  /*                       Function attachment_total_base                             */
    --                     ------------------------------
    -- This function will return Attachment Total Base for a court order.
    --
  --------------------------------------------------------------------------------------
  FUNCTION attachment_total_base (p_element_entry_id  IN   pay_element_entries_f.element_entry_id%TYPE
                                 ,p_effective_date    IN   DATE  DEFAULT  NULL)
  RETURN NUMBER;
  --====================================================================================




  --------------------------------------------------------------------------------------
  /*                       Function real_attachment_total                             */
    --                     ------------------------------
    -- This function will return Real Attachment Total for a case number.
    --
  --------------------------------------------------------------------------------------
  FUNCTION real_attachment_total ( p_assignment_id      IN   per_assignments_f.assignment_id%TYPE
                                  ,p_element_entry_id   IN   pay_element_entries_f.element_entry_id%TYPE
                                  ,p_effective_date     IN   DATE  DEFAULT  NULL)
  RETURN NUMBER;
  --====================================================================================




  --------------------------------------------------------------------------------------
  /*                               Function unpaid_debt                               */
    --                             --------------------
    -- This function will return unpaid debt amount for a court order.
    -- unpaid debt = real_attachment_total - paid_amount
    --
  --------------------------------------------------------------------------------------
  FUNCTION unpaid_debt(p_assignment_id     IN    per_assignments_f.assignment_id%TYPE
                      ,p_element_entry_id  IN    pay_element_entries_f.element_entry_id%TYPE
                      ,p_effective_date    IN    DATE  DEFAULT NULL)
  RETURN NUMBER;
  --====================================================================================




  --------------------------------------------------------------------------------------
  /*                     Function paid_amount (for single creditor)                   */
    --                   ------------------------------------------
    -- This function will return total paid amount for a creditor.
    --
    -- For Provisional attachment :
    -- IF obligation_exists THEN
    --    paid_amount = 0
    -- ELSE
    --    paid_amount =  Balance WG_DEDUCTIONS_ASG_WG_ITD
    --
    --
    -- For Actual Attachments :
    --    paid_amount = paid_amount for this court order
    --                + paid_amount for previous case court order
    --
  --------------------------------------------------------------------------------------
  FUNCTION paid_amount (p_assignment_id       IN   per_assignments_f.assignment_id%TYPE
                       ,p_element_entry_id    IN   pay_element_entries_f.element_entry_id%TYPE
                       ,p_effective_date      IN   DATE   DEFAULT  NULL)
  RETURN NUMBER;
  --====================================================================================




  --------------------------------------------------------------------------------------
  /*                 Function paid_interest_this_run (for single creditor)            */
    --               -----------------------------------------------------
    -- This function returns the Interest Amount this run for a creditor.
    --
  --------------------------------------------------------------------------------------
  FUNCTION paid_interest_this_run (p_assignment_action_id    IN pay_assignment_actions.assignment_action_id%TYPE
                                  ,p_element_entry_id        IN pay_element_entries_f.element_entry_id%TYPE)
  RETURN NUMBER;
  --====================================================================================




  --------------------------------------------------------------------------------------
  /*                 Function paid_interest_this_run (for all creditors)              */
    --               ---------------------------------------------------
    -- This function returns the total Interest Amount this run for all creditors.
    -- paid_interest_this_run = WG_PAID_INTEREST_ASG_RUN
    --
  --------------------------------------------------------------------------------------
  FUNCTION paid_interest_this_run (p_assignment_action_id IN   pay_assignment_actions.assignment_action_id%TYPE)
  RETURN NUMBER;
  --====================================================================================




  --------------------------------------------------------------------------------------
  /*                    Function paid_interest (for single creditor)                  */
    --                  --------------------------------------------
    -- This function returns the total Interets Paid for this creditor till date.
    -- paid_interest = WG_PAID_INTEREST_ASG_WG_ITD
    --
  --------------------------------------------------------------------------------------
  FUNCTION paid_interest (p_assignment_id    IN   per_assignments_f.assignment_id%TYPE
                         ,p_element_entry_id IN   pay_element_entries_f.element_entry_id%TYPE
                         ,p_effective_date   IN   DATE  DEFAULT  NULL)
  RETURN NUMBER;
  --====================================================================================

END pay_kr_wg_report_pkg;

 

/
