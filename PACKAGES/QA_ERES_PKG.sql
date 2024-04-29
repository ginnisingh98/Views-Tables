--------------------------------------------------------
--  DDL for Package QA_ERES_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."QA_ERES_PKG" AUTHID CURRENT_USER as
   /* $Header: qaeress.pls 120.0.12000000.2 2007/10/16 13:13:37 skolluku ship $ */

   SUFFIXSTRING  CONSTANT VARCHAR2(7) := '_QAKM_Z';

   /*
    Mon May  5 18:03:19 2003, copied from QLTCORE.pld: collapses long comments' internal token
    representation to the one the user sees in the form.
   */
   FUNCTION Collapse_Msg_Tokens (p_msg VARCHAR2) RETURN VARCHAR2;

   /*
    Wed May  7 15:23:09 2003, copied in part from the qa_flex_util package, this function takes a
    category_id and category_set_id and retreives the category name and description.
    */
   FUNCTION get_category_name(p_category_id IN NUMBER, p_category_set_id IN NUMBER) RETURN VARCHAR2;
   FUNCTION get_category_desc(p_category_id IN NUMBER, p_category_set_id IN NUMBER) RETURN VARCHAR2;

   /*
    Thu May 29 15:53:39 2003, for AME params based on soft coded params we need to have a function to
    lookup a result column name based on qa_results row(identitied using plan_id, collection_id, occurrence)
    and a char_id.

    Note: this method does not handle multiple rows when occurrence is null.
    */
   FUNCTION get_result_column_value(p_plan_id           IN NUMBER,
                                    p_collection_id     IN NUMBER,
                                    p_occurrence        IN NUMBER,
                                    p_char_id           IN NUMBER) RETURN VARCHAR2;

   /*
    Fri Sep  5 11:28:16 2003, for the APPS.QA_ERES_WSH_DELIVERABLES_V view, we need to get the real released status name
    using some logic to decode the released_status.
   */
   FUNCTION decode_wsh_released_status(p_source_code            IN VARCHAR2,
                                       p_released_status        IN VARCHAR2,
                                       p_released_status_name   IN VARCHAR2,
                                       p_inv_interfaced_flag    IN VARCHAR2,
                                       p_oe_interfaced_flag     IN VARCHAR2) RETURN VARCHAR2;

   /*
    Fri Sep 19 18:45:44 2003, for the APPS.QA_ERES_RCV_TRANS_INTERFACE_V view, we need to get the hazard class from some
    transaction fields so this function masks the join complexity.
   */
   FUNCTION decode_po_hazard_class(p_interface_transaction_id   IN NUMBER) RETURN VARCHAR2;

   /*
    Fri Sep 19 18:45:44 2003, for the APPS.QA_ERES_RCV_TRANS_INTERFACE_V view, we need to get the un_number from some
    transaction fields so this function masks the join complexity.
   */
   FUNCTION decode_po_un_number(p_interface_transaction_id      IN NUMBER) RETURN VARCHAR2;

   /*
    Thu May  6 12:28:59 2004 - ilawler - bug #3599451

    For the Quality Result Creation ERES event, we need a function to handle AME attributes which may return more than
    one value.  The logic is that 'Per Row' will always return a single value.  'Per Collection' will return a value if
    there is only one distinct value for the column across all rows. If there are multiple values, it throws an exception.

    p_transaction_id  VARCHAR2  => Unparsed AME transactionId consisting of <plan_id>-<collection_id>-[<occurrence>].
                                   Occurrence is ommitted from the key when 'Per Collection' is selected.
    p_char_id         NUMBER    => Char_id of the collection element whose value we want

    RETURNS  VARCHAR2 representation of the data for char_id's corresponding column in qa_results_full_v
    */
   FUNCTION get_result_column_value(p_transaction_id    IN VARCHAR2,
                                    p_char_id           IN NUMBER) RETURN VARCHAR2;
   --
   -- bug 6266477
   -- Made this function public.
   -- skolluku Sun Oct 14 03:26:31 PDT 2007
   --
   FUNCTION get_result_column_name(p_plan_id           IN NUMBER,
                                   p_char_id           IN NUMBER) RETURN VARCHAR2;



END QA_ERES_PKG;

 

/
