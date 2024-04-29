--------------------------------------------------------
--  DDL for Package IGI_EXP_APPROVAL_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IGI_EXP_APPROVAL_PKG" AUTHID CURRENT_USER AS
   -- $Header: igiexas.pls 120.4.12000000.2 2007/09/21 07:09:10 dvjoshi ship $
   --


   --
   -- Procedure
   --   Frame_table_header
   -- Purpose
   --   It will frame the HTML table.
   -- History
   --   01-Jan-2004 Rgopalan Initial Version
   --
   PROCEDURE Frame_table_header (p_html_tag  OUT NOCOPY VARCHAR2);

   --
   -- Procedure
   --   Create_du_list
   -- Purpose
   --   It will append the details to HTML table
   -- History
   --   01-Jan-2004 Rgopalan Initial Version
   --
   PROCEDURE Create_du_list (document_id  IN            VARCHAR2,
				    display_type  IN            VARCHAR2,
				    document      IN OUT NOCOPY CLOB,
				    document_type IN OUT NOCOPY VARCHAR2);

   --
   -- Procedure
   --   Selector
   -- Purpose
   --   Chooses the process to run when the workflow is invoked
   -- History
   --   22-Nov-2001 S Brewer    Initial Version
   --
   PROCEDURE Selector( itemtype   IN  VARCHAR2,
                       itemkey    IN  VARCHAR2,
                       actid      IN  NUMBER,
                       funcmode   IN  VARCHAR2,
                       resultout  OUT NOCOPY VARCHAR2
                     );

   --
   -- Procedure
   --   start_approval_workflow
   -- Purpose
   --   Creates and starts an instance of the workflow.
   -- History
   --   22-Nov-2001 S Brewer    Initial Version
   --
   PROCEDURE start_approval_workflow(p_tu_id               IN NUMBER
                                    ,p_tu_order_number     IN VARCHAR2
                                    ,p_tu_transmitter_name IN VARCHAR2
                                    ,p_tu_transmitter_id   IN NUMBER);

   --
   -- Procedure
   --   is_tu_trans_employee
   -- Purpose
   --   Checks that the tu transmitter has been set up as an
   --   employee
   -- History
   --   22-Nov-2001 S Brewer    Initial Version
   --
   PROCEDURE is_tu_trans_employee ( itemtype IN  VARCHAR2,
                                    itemkey  IN  VARCHAR2,
                                    actid    IN  NUMBER,
                                    funcmode IN  VARCHAR2,
                                    result   OUT NOCOPY VARCHAR2);

   --
   -- Procedure
   --   emp_has_position
   -- Purpose
   --   Check that the TU transmitter is assigned to a position
   -- History
   --   22-Nov-2001 S Brewer    Initial Version
   --
   PROCEDURE emp_has_position     ( itemtype IN  VARCHAR2,
                                    itemkey  IN  VARCHAR2,
                                    actid    IN  NUMBER,
                                    funcmode IN  VARCHAR2,
                                    result   OUT NOCOPY VARCHAR2);

   --
   -- Procedure
   --   position_in_hierarchy
   -- Purpose
   -- History
   --   22-Nov-2001 S Brewer    Initial Version
   --
   PROCEDURE position_in_hierarchy( itemtype IN  VARCHAR2,
                                    itemkey  IN  VARCHAR2,
                                    actid    IN  NUMBER,
                                    funcmode IN  VARCHAR2,
                                    result   OUT NOCOPY VARCHAR2);

   --
   -- Procedure
   --   is_position_gt_final_pos
   -- Purpose
   -- History
   --   22-Nov-2001 S Brewer    Initial Version
   --
   PROCEDURE is_position_gt_final_pos( itemtype IN  VARCHAR2,
                                       itemkey  IN  VARCHAR2,
                                       actid    IN  NUMBER,
                                       funcmode IN  VARCHAR2,
                                       result   OUT NOCOPY VARCHAR2);

   --
   -- Procedure
   --   update_tu_status_to_avl
   -- Purpose
   -- History
   --   22-Nov-2001 S Brewer    Initial Version
   --
   PROCEDURE update_tu_status_to_avl( itemtype IN  VARCHAR2,
                                      itemkey  IN  VARCHAR2,
                                      actid    IN  NUMBER,
                                      funcmode IN  VARCHAR2,
                                      result   OUT NOCOPY VARCHAR2);

   --
   -- Procedure
   --   update_dus_to_in_a_tu
   -- Purpose
   -- History
   --   22-Nov-2001 S Brewer    Initial Version
   --
   PROCEDURE update_dus_to_in_a_tu( itemtype IN  VARCHAR2,
                                    itemkey  IN  VARCHAR2,
                                    actid    IN  NUMBER,
                                    funcmode IN  VARCHAR2,
                                    result   OUT NOCOPY VARCHAR2);

   --
   -- Procedure
   --   build_user_list
   -- Purpose
   -- History
   --   22-Nov-2001 S Brewer    Initial Version
   --
   PROCEDURE build_user_list      ( itemtype IN  VARCHAR2,
                                    itemkey  IN  VARCHAR2,
                                    actid    IN  NUMBER,
                                    funcmode IN  VARCHAR2,
                                    result   OUT NOCOPY VARCHAR2);

   --
   -- Procedure
   --   check_user_position
   -- Purpose
   -- History
   --   22-Nov-2001 S Brewer    Initial Version
   --
   PROCEDURE check_user_position  ( itemtype IN  VARCHAR2,
                                    itemkey  IN  VARCHAR2,
                                    actid    IN  NUMBER,
                                    funcmode IN  VARCHAR2,
                                    result   OUT NOCOPY VARCHAR2);

   --
   -- Procedure
   --   set_pos_as_auth
   -- Purpose
   -- History
   --   22-Nov-2001 S Brewer    Initial Version
   --
   PROCEDURE set_pos_as_auth      ( itemtype IN  VARCHAR2,
                                    itemkey  IN  VARCHAR2,
                                    actid    IN  NUMBER,
                                    funcmode IN  VARCHAR2,
                                    result   OUT NOCOPY VARCHAR2);

   --
   -- Procedure
   --   set_chosen_user_as_auth
   -- Purpose
   -- History
   --   22-Nov-2001 S Brewer    Initial Version
   --
   PROCEDURE set_chosen_user_as_auth( itemtype IN  VARCHAR2,
                                      itemkey  IN  VARCHAR2,
                                      actid    IN  NUMBER,
                                      funcmode IN  VARCHAR2,
                                      result   OUT NOCOPY VARCHAR2);

   --
   -- Procedure
   --   is_auth_allowed_return
   -- Purpose
   -- History
   --   22-Nov-2001 S Brewer    Initial Version
   --
   PROCEDURE is_auth_allowed_return( itemtype IN  VARCHAR2,
                                     itemkey  IN  VARCHAR2,
                                     actid    IN  NUMBER,
                                     funcmode IN  VARCHAR2,
                                     result   OUT NOCOPY VARCHAR2);

   --
   -- Procedure
   --   set_curr_auth_to_responder
   -- Purpose
   -- History
   --   22-Nov-2001 S Brewer    Initial Version
   --
   PROCEDURE set_curr_auth_to_responder( itemtype IN  VARCHAR2,
                                         itemkey  IN  VARCHAR2,
                                         actid    IN  NUMBER,
                                         funcmode IN  VARCHAR2,
                                         result   OUT NOCOPY VARCHAR2);

   --
   -- Procedure
   --   add_auth_to_history
   -- Purpose
   -- History
   --   22-Nov-2001 S Brewer    Initial Version
   --
   PROCEDURE add_auth_to_history  ( itemtype IN  VARCHAR2,
                                    itemkey  IN  VARCHAR2,
                                    actid    IN  NUMBER,
                                    funcmode IN  VARCHAR2,
                                    result   OUT NOCOPY VARCHAR2);

   --
   -- Procedure
   --   set_current_position_to_subord
   -- Purpose
   -- History
   --   22-Nov-2001 S Brewer    Initial Version
   --
   PROCEDURE set_current_position_to_subord( itemtype IN  VARCHAR2,
                                             itemkey  IN  VARCHAR2,
                                             actid    IN  NUMBER,
                                             funcmode IN  VARCHAR2,
                                             result   OUT NOCOPY VARCHAR2);

   --
   -- Procedure
   --   set_current_auth_to_prev_auth
   -- Purpose
   -- History
   --   22-Nov-2001 S Brewer    Initial Version
   --
   PROCEDURE set_current_auth_to_prev_auth( itemtype IN  VARCHAR2,
                                            itemkey  IN  VARCHAR2,
                                            actid    IN  NUMBER,
                                            funcmode IN  VARCHAR2,
                                            result   OUT NOCOPY VARCHAR2);

   --
   -- Procedure
   --   reset_du_statuses
   -- Purpose
   -- History
   --   22-Nov-2001 S Brewer    Initial Version
   --
   PROCEDURE reset_du_statuses    ( itemtype IN  VARCHAR2,
                                    itemkey  IN  VARCHAR2,
                                    actid    IN  NUMBER,
                                    funcmode IN  VARCHAR2,
                                    result   OUT NOCOPY VARCHAR2);

   --
   -- Procedure
   --   check_dus_actioned
   -- Purpose
   -- History
   --   22-Nov-2001 S Brewer    Initial Version
   --
   PROCEDURE check_dus_actioned   ( itemtype IN  VARCHAR2,
                                    itemkey  IN  VARCHAR2,
                                    actid    IN  NUMBER,
                                    funcmode IN  VARCHAR2,
                                    result   OUT NOCOPY VARCHAR2);

   --
   -- Procedure
   --   set_dus_to_atr
   -- Purpose
   -- History
   --   22-Nov-2001 S Brewer    Initial Version
   --
   PROCEDURE set_dus_to_atr       ( itemtype IN  VARCHAR2,
                                    itemkey  IN  VARCHAR2,
                                    actid    IN  NUMBER,
                                    funcmode IN  VARCHAR2,
                                    result   OUT NOCOPY VARCHAR2);

   --
   -- Procedure
   --   list_any_dus_on_hold
   -- Purpose
   -- History
   --   22-Nov-2001 S Brewer    Initial Version
   --
   PROCEDURE list_any_dus_on_hold ( itemtype IN  VARCHAR2,
                                    itemkey  IN  VARCHAR2,
                                    actid    IN  NUMBER,
                                    funcmode IN  VARCHAR2,
                                    result   OUT NOCOPY VARCHAR2);

   --
   -- Procedure
   --   get_next_du_on_hold
   -- Purpose
   -- History
   --   22-Nov-2001 S Brewer    Initial Version
   --
   PROCEDURE get_next_du_on_hold  ( itemtype IN  VARCHAR2,
                                    itemkey  IN  VARCHAR2,
                                    actid    IN  NUMBER,
                                    funcmode IN  VARCHAR2,
                                    result   OUT NOCOPY VARCHAR2);

   --
   -- Procedure
   --   remove_dus_on_hold
   -- Purpose
   -- History
   --   22-Nov-2001 S Brewer    Initial Version
   --
   PROCEDURE remove_dus_on_hold   ( itemtype IN  VARCHAR2,
                                    itemkey  IN  VARCHAR2,
                                    actid    IN  NUMBER,
                                    funcmode IN  VARCHAR2,
                                    result   OUT NOCOPY VARCHAR2);

   --
   -- Procedure
   --   list_any_rejected_dus
   -- Purpose
   -- History
   --   22-Nov-2001 S Brewer    Initial Version
   --
   PROCEDURE list_any_rejected_dus( itemtype IN  VARCHAR2,
                                    itemkey  IN  VARCHAR2,
                                    actid    IN  NUMBER,
                                    funcmode IN  VARCHAR2,
                                    result   OUT NOCOPY VARCHAR2);

   --
   -- Procedure
   --   get_next_rejected_du
   -- Purpose
   -- History
   --   22-Nov-2001 S Brewer    Initial Version
   --
   PROCEDURE get_next_rejected_du ( itemtype IN  VARCHAR2,
                                    itemkey  IN  VARCHAR2,
                                    actid    IN  NUMBER,
                                    funcmode IN  VARCHAR2,
                                    result   OUT NOCOPY VARCHAR2);

   --
   -- Procedure
   --   rem_trx_from_rej_dus
   -- Purpose
   -- History
   --   22-Nov-2001 S Brewer    Initial Version
   --
   PROCEDURE rem_trx_from_rej_dus ( itemtype IN  VARCHAR2,
                                    itemkey  IN  VARCHAR2,
                                    actid    IN  NUMBER,
                                    funcmode IN  VARCHAR2,
                                    result   OUT NOCOPY VARCHAR2);

   --
   -- Procedure
   --   is_legal_num_req
   -- Purpose
   -- History
   --   22-Nov-2001 S Brewer    Initial Version
   --
   PROCEDURE is_legal_num_req     ( itemtype IN  VARCHAR2,
                                    itemkey  IN  VARCHAR2,
                                    actid    IN  NUMBER,
                                    funcmode IN  VARCHAR2,
                                    result   OUT NOCOPY VARCHAR2);

   --
   -- Procedure
   --   apply_tu_legal_num
   -- Purpose
   -- History
   --   22-Nov-2001 S Brewer    Initial Version
   --
   PROCEDURE apply_tu_legal_num   ( itemtype IN  VARCHAR2,
                                    itemkey  IN  VARCHAR2,
                                    actid    IN  NUMBER,
                                    funcmode IN  VARCHAR2,
                                    result   OUT NOCOPY VARCHAR2);

   --
   -- Procedure
   --   apply_du_legal_num
   -- Purpose
   -- History
   --   22-Nov-2001 S Brewer    Initial Version
   --
   PROCEDURE apply_du_legal_num   ( itemtype IN  VARCHAR2,
                                    itemkey  IN  VARCHAR2,
                                    actid    IN  NUMBER,
                                    funcmode IN  VARCHAR2,
                                    result   OUT NOCOPY VARCHAR2);

   --
   -- Procedure
   --   set_tu_status
   -- Purpose
   -- History
   --   22-Nov-2001 S Brewer    Initial Version
   --
   PROCEDURE set_tu_status        ( itemtype IN  VARCHAR2,
                                    itemkey  IN  VARCHAR2,
                                    actid    IN  NUMBER,
                                    funcmode IN  VARCHAR2,
                                    result   OUT NOCOPY VARCHAR2);

   --
   -- Procedure
   --   get_parent_position
   -- Purpose
   -- History
   --   22-Nov-2001 S Brewer    Initial Version
   --
   PROCEDURE get_parent_position  ( itemtype IN  VARCHAR2,
                                    itemkey  IN  VARCHAR2,
                                    actid    IN  NUMBER,
                                    funcmode IN  VARCHAR2,
                                    result   OUT NOCOPY VARCHAR2);

   --
   -- Procedure
   --   get_next_incomplete_du
   -- Purpose
   -- History
   --   22-Nov-2001 S Brewer    Initial Version
   --
   PROCEDURE get_next_incomplete_du(itemtype IN  VARCHAR2,
                                    itemkey  IN  VARCHAR2,
                                    actid    IN  NUMBER,
                                    funcmode IN  VARCHAR2,
                                    result   OUT NOCOPY VARCHAR2);

   --
   -- Procedure
   --   process_transactions
   -- Purpose
   -- History
   --   22-Nov-2001 S Brewer    Initial Version
   --
   PROCEDURE process_transactions ( itemtype IN  VARCHAR2,
                                    itemkey  IN  VARCHAR2,
                                    actid    IN  NUMBER,
                                    funcmode IN  VARCHAR2,
                                    result   OUT NOCOPY VARCHAR2);

   --
   -- Procedure
   --   set_du_to_complete
   -- Purpose
   -- History
   --   22-Nov-2001 S Brewer    Initial Version
   --
   PROCEDURE set_du_to_complete   ( itemtype IN  VARCHAR2,
                                    itemkey  IN  VARCHAR2,
                                    actid    IN  NUMBER,
                                    funcmode IN  VARCHAR2,
                                    result   OUT NOCOPY VARCHAR2);

   --
   -- Procedure
   --   put_failed_du_on_hold
   -- Purpose
   -- History
   --   22-Nov-2001 S Brewer    Initial Version
   --
   PROCEDURE put_failed_du_on_hold( itemtype IN  VARCHAR2,
                                    itemkey  IN  VARCHAR2,
                                    actid    IN  NUMBER,
                                    funcmode IN  VARCHAR2,
                                    result   OUT NOCOPY VARCHAR2);

   --
   -- Procedure
   --   check_dus_completed
   -- Purpose
   -- History
   --   22-Nov-2001 S Brewer    Initial Version
   --
   PROCEDURE check_dus_completed  ( itemtype IN  VARCHAR2,
                                    itemkey  IN  VARCHAR2,
                                    actid    IN  NUMBER,
                                    funcmode IN  VARCHAR2,
                                    result   OUT NOCOPY VARCHAR2);

   --
   -- Procedure
   --   any_dus_with_trx_fail
   -- Purpose
   -- History
   --   22-Nov-2001 S Brewer    Initial Version
   --
   PROCEDURE any_dus_with_trx_fail( itemtype IN  VARCHAR2,
                                    itemkey  IN  VARCHAR2,
                                    actid    IN  NUMBER,
                                    funcmode IN  VARCHAR2,
                                    result   OUT NOCOPY VARCHAR2);

   --
   -- Procedure
   --   remove_all_on_hold_dus
   -- Purpose
   -- History
   --   22-Nov-2001 S Brewer    Initial Version
   --
   PROCEDURE remove_all_on_hold_dus(itemtype IN  VARCHAR2,
                                    itemkey  IN  VARCHAR2,
                                    actid    IN  NUMBER,
                                    funcmode IN  VARCHAR2,
                                    result   OUT NOCOPY VARCHAR2);

   --
   -- Procedure
   --   check_for_complete_dus
   -- Purpose
   -- History
   --   22-Nov-2001 S Brewer    Initial Version
   --
   PROCEDURE check_for_complete_dus( itemtype IN  VARCHAR2,
                                    itemkey  IN  VARCHAR2,
                                    actid    IN  NUMBER,
                                    funcmode IN  VARCHAR2,
                                    result   OUT NOCOPY VARCHAR2);

   --
   -- Procedure
   --   build_prep_list_of_com_dus
   -- Purpose
   -- History
   --   22-Nov-2001 S Brewer    Initial Version
   --
   PROCEDURE build_prep_list_of_com_dus( itemtype IN  VARCHAR2,
                                         itemkey  IN  VARCHAR2,
                                         actid    IN  NUMBER,
                                         funcmode IN  VARCHAR2,
                                         result   OUT NOCOPY VARCHAR2);


   --
   -- Procedure
   --   get_next_prep
   -- Purpose
   -- History
   --   22-Nov-2001 S Brewer    Initial Version
   --
   PROCEDURE get_next_prep        ( itemtype IN  VARCHAR2,
                                    itemkey  IN  VARCHAR2,
                                    actid    IN  NUMBER,
                                    funcmode IN  VARCHAR2,
                                    result   OUT NOCOPY VARCHAR2);

   --
   -- Procedure
   --   remove_prep_from_list
   -- Purpose
   -- History
   --   22-Nov-2001 S Brewer    Initial Version
   --
   PROCEDURE remove_prep_from_list( itemtype IN  VARCHAR2,
                                    itemkey  IN  VARCHAR2,
                                    actid    IN  NUMBER,
                                    funcmode IN  VARCHAR2,
                                    result   OUT NOCOPY VARCHAR2);

   --
   -- Procedure
   --   set_tu_to_complete
   -- Purpose
   -- History
   --   22-Nov-2001 S Brewer    Initial Version
   --
   PROCEDURE set_tu_to_complete   ( itemtype IN  VARCHAR2,
                                    itemkey  IN  VARCHAR2,
                                    actid    IN  NUMBER,
                                    funcmode IN  VARCHAR2,
                                    result   OUT NOCOPY VARCHAR2);


-- OPSF(I) EXP Bug 2415293  S Brewer 11-JUL-2002 Start(1)
-- Added new procedures does_tu_have_legal_num and
-- remove_rej_dus_from_tu  and get_next_rejected_legal_du

   --
   -- Procedure
   --   does_tu_have_legal_num
   -- Purpose
   -- History
   --   11-Jul-2002 S Brewer    Initial Version
   --
   PROCEDURE does_tu_have_legal_num( itemtype IN  VARCHAR2,
                                     itemkey  IN  VARCHAR2,
                                     actid    IN  NUMBER,
                                     funcmode IN  VARCHAR2,
                                     result   OUT NOCOPY VARCHAR2);


   --
   -- Procedure
   --   remove_rej_dus_from_tu
   -- Purpose
   -- History
   --   11-Jul-2002 S Brewer    Initial Version
   --
   PROCEDURE remove_rej_dus_from_tu( itemtype IN  VARCHAR2,
                                     itemkey  IN  VARCHAR2,
                                     actid    IN  NUMBER,
                                     funcmode IN  VARCHAR2,
                                     result   OUT NOCOPY VARCHAR2);

   --
   -- Procedure
   --   get_next_rejected_legal_du
   -- Purpose
   -- History
   --   11-Jul-2002 S Brewer    Initial Version
   --
   PROCEDURE get_next_rejected_legal_du( itemtype IN  VARCHAR2,
                                         itemkey  IN  VARCHAR2,
                                         actid    IN  NUMBER,
                                         funcmode IN  VARCHAR2,
                                         result   OUT NOCOPY VARCHAR2);

-- OPSF(I) EXP Bug 2415293  S Brewer 11-JUL-2002 End(1)


-- OPSF(I) EXP Bug 2379693  S Brewer 16-JUL-2002 Start(1)
-- Added new procedure is_transmitter_final_apprv

   --
   -- Procedure
   --   is_transmitter_final_apprv
   -- Purpose
   -- History
   --   16-Jul-2002 S Brewer    Initial Version
   --
   PROCEDURE is_transmitter_final_apprv( itemtype IN  VARCHAR2,
                                         itemkey  IN  VARCHAR2,
                                         actid    IN  NUMBER,
                                         funcmode IN  VARCHAR2,
                                         result   OUT NOCOPY VARCHAR2);

-- OPSF(I) EXP Bug 2379693  S Brewer 16-JUL-2002 End(1)

END igi_exp_approval_pkg;

 

/
