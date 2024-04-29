--------------------------------------------------------
--  DDL for Package QA_VALIDATION_API
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."QA_VALIDATION_API" AUTHID CURRENT_USER AS
/* $Header: qltvalb.pls 120.6.12010000.3 2009/04/14 10:54:19 pdube ship $ */

--
-- Type Definitions
--

--
-- removed all the default values for record elements
-- per coding standard for better performance.
-- jezheng
-- Wed Nov 27 15:15:43 PST 2002
--

TYPE InfoRecord IS RECORD (
    id NUMBER,
    validation_flag VARCHAR2(100) ,
    treated BOOLEAN);

TYPE ErrorRecord IS RECORD (
    element_id NUMBER,
    error_code NUMBER);

TYPE DependencyRecord IS RECORD (
    element_id  NUMBER,
    parent NUMBER);

TYPE ElementRecord IS RECORD (
    id NUMBER,
    value VARCHAR2(2000),
    validation_flag VARCHAR2(100));

TYPE RowRecord IS RECORD (
    plan_id NUMBER,
    org_id  NUMBER,
    spec_id NUMBER,
    user_id NUMBER);

TYPE ConditionRecord IS RECORD (
    operator                    NUMBER,
    low_value_other             VARCHAR2(150),
    high_value_other            VARCHAR2(150),
    low_value_lookup            NUMBER,
    high_value_lookup           NUMBER);

TYPE ResultRecord IS RECORD (
    element_id          NUMBER,
    canonical_value     VARCHAR2(2000),
    id                  NUMBER,
    actual_datatype     NUMBER,
    message             VARCHAR2(2000));

-- Bug 5150287. SHKALYAN 02-Mar-2006.
-- Increased the column width of message from 500 to 2500.

Type MessageRecord IS RECORD (
    element_id  NUMBER,
    action_type NUMBER,
    message     VARCHAR2(2500));

TYPE ElementInfoArray  IS TABLE OF InfoRecord       INDEX BY BINARY_INTEGER;
TYPE ElementsArray     IS TABLE OF ElementRecord    INDEX BY BINARY_INTEGER;
TYPE ErrorArray        IS TABLE OF ErrorRecord      INDEX BY BINARY_INTEGER;
TYPE ResultRecordArray IS TABLE OF ResultRecord     INDEX BY BINARY_INTEGER;
TYPE DependencyArray   IS TABLE OF DependencyRecord INDEX BY BINARY_INTEGER;
TYPE MessageArray      IS TABLE OF MessageRecord    INDEX BY BINARY_INTEGER;

--
-- Constant Definition
--

not_enabled_error               NUMBER  := -1;
no_value_error                  NUMBER  := -2;
mandatory_error                 NUMBER  := -3;
not_revision_controlled_error   NUMBER  := -4;
mandatory_revision_error        NUMBER  := -5;
no_values_error                 NUMBER  := -6;
keyflex_error                   NUMBER  := -7;
id_not_found_error              NUMBER  := -8;
spec_limit_error                NUMBER  := -9;
immediate_action_error          NUMBER  := -10;
lower_limit_error               NUMBER  := -11;
upper_limit_error               NUMBER  := -12;
value_not_in_sql_error          NUMBER  := -13;
sql_validation_error            NUMBER  := -14;
date_conversion_error           NUMBER  := -15;
data_type_error                 NUMBER  := -16;
number_conversion_error         NUMBER  := -17;
not_locator_controlled_error    NUMBER  := -18;
no_data_found_error             NUMBER  := -19;
item_keyflex_error              NUMBER  := -20;
comp_item_keyflex_error         NUMBER  := -21;
locator_keyflex_error           NUMBER  := -22;
comp_locator_keyflex_error      NUMBER  := -23;
invalid_number_error            NUMBER  := -24;
invalid_date_error              NUMBER  := -25;
spec_error                      NUMBER  := -26;
reject_an_entry_error		NUMBER	:= -27;

-- Added the following fields to be used for Bill_Reference,Routing_Reference,To_locator
-- Key FlexField error messages. Bug 2686970.suramasw Wed Nov 27 05:12:52 PST 2002.

bill_reference_keyflex_error    NUMBER  := -28;
rtg_reference_keyflex_error     NUMBER  := -29;
to_locator_keyflex_error        NUMBER  := -30;

-- End Bug 2686970.


  -- Bug 3679762.Added the following field to be used for "missing assign a value target column"
  -- error message.This constant will be used in qa_ss_results.populate_message_table(qltssreb.plb),
  -- qa_results_pub.populate_message_table (qltpresb.plb) and qa_validation_api.init_message_map(qltvalb.plb)
  -- procedures as index to message array.It is also used in qa_validation_api.perform_immediate_actions
  -- (qltvalb.plb) as error code.
  -- srhariha. Wed Jun 16 06:54:06 PDT 2004.

missing_assign_column           NUMBER  := -31;

ok                              NUMBER  := 0;
unknown_error                   NUMBER  := -9999;


-- The following constants are defined to let the caller
-- of validate_row to sxpecify what level of validation
-- must be performed for an element.
--
-- For example:
--
-- row_elements_array(element id).validation_flag :=
--                              background_element || action_fired;
--
-- This says that this element is an invalid element but is a
-- part of a background transaction and all the immediate actions
-- are already fired.
--
-- As a result, the validation routine will validate the element
-- but will not perform any mandatory check on it, also will not
-- not do any immediate actions processing.
--
-- Please note that by default all elements are invalid.
-- In other words the caller does not have to set any flag
-- if he wants is a full validation on every element.


valid_element                   VARCHAR2(100)   := 'context';
invalid_element                 VARCHAR2(100)   := 'invalid';
background_element              VARCHAR2(100)   := 'background';
action_fired                    VARCHAR2(100)   := 'fired';
id_derived                      VARCHAR2(100)   := 'id_given';



-- rkaza. bug 3220767. 10/29/2003. Commenting the following block.
-- When coming from ss, we have to do the tz conversion in the middle tier.
-- because server side initializations required for tz conversion to work
-- on server side would not be done by ss tech stack as in forms.

/*
client_timezone                 VARCHAR2(100)   := 'client_tz';
server_timezone                 VARCHAR2(100)   := 'server_tz';
*/


--
--  Subroutines
--

INVALID_DATE            EXCEPTION;
INVALID_DATE_FORMAT     EXCEPTION;

PRAGMA EXCEPTION_INIT (INVALID_DATE, -1858);
PRAGMA EXCEPTION_INIT (INVALID_DATE_FORMAT, -1861);

--
-- 12.1 QWB Usability Improvements
-- Added a new parameter p_ssqr_operation
-- to indicate if the method is called through
-- the QWB application, in which case the
-- Online actions are not to be fired
--
FUNCTION validate_row (
    plan_id                    IN      NUMBER,
    spec_id                    IN      NUMBER,
    org_id                     IN      NUMBER,
    user_id                    IN      NUMBER,
    transaction_number         IN      NUMBER,
    transaction_id             IN      NUMBER,
    return_results_array       OUT     NOCOPY ResultRecordArray,
    message_array              OUT     NOCOPY MessageArray,
    row_elements               IN OUT  NOCOPY ElementsArray,
    p_ssqr_operation           IN      NUMBER DEFAULT NULL)
    RETURN ErrorArray;


--
-- Bug 3402251.  To fix this bug, it is required the row_elements
-- changed to an IN OUT NOCOPY param.
-- bso Mon Feb  9 21:38:43 PST 2004
--
--
-- 12.1 QWB Usabiltiy Improvements
-- Added a new parameter org_id for
-- online validations
--
FUNCTION validate_element (
    row_elements IN OUT NOCOPY ElementsArray,
    row_record IN RowRecord,
    element_id IN NUMBER,
    org_id     IN NUMBER,
    result_holder IN OUT NOCOPY ResultRecord)
    RETURN ErrorArray;

FUNCTION no_errors (error_Array IN ErrorArray)
    RETURN BOOLEAN;

FUNCTION get_error_message(error_code IN NUMBER)
    RETURN VARCHAR2;

-- Bug 2427337. new function introduced
-- rponnusa Tue Jun 25 06:15:48 PDT 2002
FUNCTION validate_comment (value IN VARCHAR2, result_holder IN OUT NOCOPY ResultRecord)
    RETURN NUMBER;


    --
    -- R12 Project MOAC 4637896
    -- Exposing several useful procedures for modularization.
    -- bso Sat Oct  1 16:03:53 PDT 2005
    --

    --
    -- Convert a canonical @-separated result string into the
    -- internal validation API ElementsArray format.
    --
    FUNCTION result_to_array(
        p_result IN VARCHAR2)
    RETURN qa_validation_api.ElementsArray;


    --
    -- Convert a canonical @-separated ID string and update
    -- an existing validation API ElementsArray with the new
    -- data.  ID strings are simply IDs for certain hardcoded
    -- elements where the ID value is already known so that
    -- it is more efficient to not re-validate.
    --
    FUNCTION id_to_array(
        p_result IN VARCHAR2,
        x_elements IN OUT NOCOPY qa_validation_api.ElementsArray)
        RETURN qa_validation_api.ElementsArray;


    --
    -- Set every element to have action fired flag on
    -- indicating online action has already been fired
    -- by the UI and no need to be refired during validation.
    -- In addition transaction type element is set to valid.
    --
    PROCEDURE set_validation_flag(
        x_elements IN OUT NOCOPY qa_validation_api.ElementsArray);


    --
    -- If validation is to be done for a transaction, then
    -- set the context elements to valid.  In addition, if
    -- the transaction is a background transaction, then
    -- set each element to have background_element flag.
    -- Finally, these elements are set to valid by default:
    --
    -- transaction type, lot number, serial number
    --
    -- Caller chould supply p_plan_transaction_id if possible.
    -- For backward compatibility, one can also specify
    -- p_plan_id + p_transaction_number, which is not 100%
    -- accurate because one be certain a plan is a background
    -- plan only by a given plan_transaction_id.
    --
    PROCEDURE set_validation_flag_txn(
        x_elements IN OUT NOCOPY qa_validation_api.ElementsArray,
        p_plan_id NUMBER,
        p_transaction_number NUMBER,
        p_plan_transaction_id NUMBER);

    -- End R12 Project MOAC 4637896

-- 12.1 QWB Usability Improvements
-- Procedure to De-reference the values for the HC elements
-- that depended on Non Quality tables for their values
PROCEDURE build_deref_string(p_plan_id        IN NUMBER,
                             p_collection_id  IN NUMBER,
                             p_occurrence     IN NUMBER,
                             p_charid_string  OUT NOCOPY VARCHAR2,
                             p_values_string  OUT NOCOPY VARCHAR2);

-- 12.1 QWB Usability Improvements
-- Method to do the online validations
-- This method would also make a call to the API
-- process_dependent_elements to do the dependent
-- elelemts processing
--
PROCEDURE perform_ssqr_validation (p_plan_id     IN VARCHAR2,
                                   p_org_id      IN VARCHAR2,
                                   p_spec_id     IN VARCHAR2,
                                   p_user_id     IN VARCHAR2 DEFAULT NULL,
                                   p_element_id  IN VARCHAR2,
                                   p_input_value IN VARCHAR2,
                                   result_string IN VARCHAR2,
                                   id_string     IN VARCHAR2,
                                   normalized_attr               OUT NOCOPY VARCHAR2,
                                   normalized_id_val             OUT NOCOPY VARCHAR2,
                                   message                       OUT NOCOPY VARCHAR2,
                                   dependent_elements            OUT NOCOPY VARCHAR2,
                                   disable_enable_flag_list      OUT NOCOPY VARCHAR2,
                                   disabled_dep_elem_vo_attr_lst OUT NOCOPY VARCHAR2);

-- 12.1 QWB Usability Improvements
-- method to get the sql string for ResultExportVO
FUNCTION get_export_vo_sql (p_plan_id in NUMBER) Return VARCHAR2;

-- 12.1 QWB Usability Improvements
-- Procedure to fire the online actions
-- on elements that have trigers defined
-- for the value not entered conditition
--
FUNCTION processNotEnteredActions (p_plan_id         IN NUMBER,
                                    p_spec_id        IN NUMBER,
                                    p_ssqr_operation IN NUMBER DEFAULT NULL,
                                    p_row_elements          IN OUT NOCOPY ElementsArray,
                                    p_return_results_array  IN OUT NOCOPY ResultRecordArray,
                                    message_array              OUT NOCOPY MessageArray)
     RETURN ErrorArray;

--
-- Bug 	7491253. 12.1.1 FP for Bug 6599571.Made this procedure public to
-- access it from qltdactb
-- skolluku
--
FUNCTION get_normalized_id (element_id IN NUMBER, value IN VARCHAR2, x_org_id IN NUMBER)
     RETURN NUMBER;
--
-- Bug 7716875. Will set the validation flag for elements
-- with sql validation to true.pdube Mon Apr 13 03:25:19 PDT 2009
FUNCTION set_validation_flag_sql_valid(p_char_id IN NUMBER) RETURN BOOLEAN;

END qa_validation_api;

/
