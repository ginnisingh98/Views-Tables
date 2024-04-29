--------------------------------------------------------
--  DDL for Package QA_PARENT_CHILD_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."QA_PARENT_CHILD_PKG" AUTHID CURRENT_USER as
/* $Header: qapcs.pls 120.11.12010000.4 2010/02/08 11:25:45 ntungare ship $ */
TYPE ChildPlanArray IS TABLE OF NUMBER INDEX BY BINARY_INTEGER;

-- 5114865
-- New Global Record Type for the Parent Child
-- Relationship Columns
-- ntungare Wed Mar  8 08:59:12 PST 2006
Type g_parentchild_rectyp is record
    (parent_database_column VARCHAR2(2000),
     child_database_column  VARCHAR2(2000));

-- 5114865
-- Global Collection Type of the above Record Type
-- ntungare Wed Mar 22 01:11:28 PST 2006
Type g_parentchild_elementtab_type is table of g_parentchild_rectyp
    INDEX BY BINARY_INTEGER;

-- 5114865
-- New Record Type to related the Parent Child
-- Relationship records. This has the collection
-- Type defined above nested inside, to list
-- the elements copied at every P-C level
-- ntungare Wed Mar 22 01:11:28 PST 2006
--
TYPE ParentChildUpdtRecTyp IS RECORD
               (parent_plan_id       NUMBER,
                parent_collection_id NUMBER,
                parent_occurrence    NUMBER,
                child_plan_id        NUMBER,
                child_collection_id  NUMBER,
                child_occurrence     NUMBER,
                parentelement_tab    g_parentchild_elementtab_type);
 -- 5114865
 -- Array to hold the details of the P-C relationships
 -- for sequence Type of elements
 -- ntungare Sun Apr  9 23:46:50 PDT 2006
TYPE ParentChildTabTyp IS TABLE OF ParentChildUpdtRecTyp INDEX BY BINARY_INTEGER;

PROCEDURE parse_list(x_result IN VARCHAR2,
                        x_array OUT NOCOPY ChildPlanArray);

PROCEDURE insert_automatic_records(p_plan_id IN NUMBER,
                                   p_collection_id IN NUMBER,
                                   p_occurrence IN NUMBER,
                                   p_child_plan_ids IN VARCHAR2,
                                   p_relationship_type IN NUMBER,
                                   p_data_entry_mode IN NUMBER,
                                   p_criteria_values IN VARCHAR2,
                                   p_org_id IN NUMBER,
                                   p_spec_id in NUMBER,
                                   x_status OUT NOCOPY VARCHAR2,
                                   p_txn_header_id IN NUMBER DEFAULT NULL);

PROCEDURE enable_and_fire_actions(p_collection_id    NUMBER);

-- Gapless Sequence Proj. rponnusa Wed Jul 30 04:52:45 PDT 2003
-- Changed procedure signature
PROCEDURE delete_child_rows( p_plan_ids           IN dbms_sql.number_table,
                             p_collection_ids     IN dbms_sql.number_table,
                             p_occurrences        IN dbms_sql.number_table,
                             p_parent_plan_id        NUMBER,
                             p_parent_collection_id  NUMBER,
                             p_parent_occurrence     NUMBER,
                             p_enabled_flag          VARCHAR2);


PROCEDURE enable_fire_for_txn_hdr_id(p_txn_header_id NUMBER);

--
-- bug 5682448
-- New proc to enable the records and fire
-- the actions for all those enabled records
-- ntungare Wed Feb 21 07:06:20 PST 2007
--
PROCEDURE enable_fire_for_coll_id(p_txn_header_id IN NUMBER);

-- Gapless Sequence Proj. rponnusa Wed Jul 30 04:52:45 PDT 2003
-- Changed procedure signature
-- 12.1 QWB Usability Improvements
-- Added 2 new paramters to get a list of the Aggregated elements
-- and the aggregated values.
--
--
-- bug 7046071
-- Added a parameter p_ssqr_operation parameter to check if the
-- call is done from the OAF application or from Forms
-- In case of the OAF application, the COMMIT that is
-- executed in the aggregate_parent must not be called
-- ntungare
--
PROCEDURE relate(p_parent_plan_id IN NUMBER, p_parent_collection_id IN NUMBER,
                 p_parent_occurrence IN NUMBER, p_child_plan_id IN NUMBER,
                 p_child_collection_id IN NUMBER, p_child_occurrence IN NUMBER,
                 p_child_txn_header_id IN NUMBER DEFAULT NULL,x_agg_elements OUT NOCOPY VARCHAR2,
                 x_agg_val OUT NOCOPY VARCHAR2, p_ssqr_operation IN NUMBER DEFAULT NULL
                 );


FUNCTION commit_allowed(
                          p_plan_id          NUMBER,
                          p_collection_id    NUMBER,
                          p_occurrence       NUMBER,
                          p_child_plan_ids   VARCHAR2)   RETURN VARCHAR2;

-- Bug 5161719. SHKALYAN 13-Apr-2006
-- Added this overloaded commit_allowed method to return back to the caller
-- the list of child plan ids that are incomplete.
FUNCTION commit_allowed(
                          p_plan_id                         NUMBER,
                          p_collection_id                   NUMBER,
                          p_occurrence                      NUMBER,
                          p_child_plan_ids                  VARCHAR2,
                          x_incomplete_plan_ids  OUT NOCOPY VARCHAR2) RETURN VARCHAR2;

FUNCTION descendants_exist(p_plan_id NUMBER,
                           p_collection_id NUMBER,
                           p_occurrence NUMBER)
         RETURN VARCHAR2;

FUNCTION get_descendants(p_plan_id NUMBER, p_collection_id NUMBER,
                         p_occurrence NUMBER,
                         x_plan_ids OUT NOCOPY dbms_sql.number_table,
                         x_collection_ids OUT NOCOPY dbms_sql.number_table,
                         x_occurrences OUT NOCOPY dbms_sql.number_table)
         RETURN VARCHAR2;

FUNCTION get_disabled_descendants(p_plan_id NUMBER,
                             p_collection_id NUMBER,
                             p_occurrence NUMBER,
                             --p_enabled    NUMBER,
                             x_plan_ids OUT NOCOPY dbms_sql.number_table,
                             x_collection_ids OUT NOCOPY dbms_sql.number_table,
                             x_occurrences OUT NOCOPY dbms_sql.number_table)
         RETURN VARCHAR2;


FUNCTION evaluate_child_lov_criteria(p_plan_id          IN NUMBER,
                                       p_criteria_values  IN VARCHAR2,
                                       x_child_plan_ids  OUT NOCOPY VARCHAR2)
        RETURN VARCHAR2;

 FUNCTION eval_updateview_lov_criteria( p_plan_id          IN NUMBER,
                                        p_criteria_values  IN VARCHAR2,
                                        x_child_plan_ids  OUT NOCOPY VARCHAR2)
        RETURN VARCHAR2;

FUNCTION criteria_matched(p_plan_relationship_id IN NUMBER,
                            p_criteria_array qa_txn_grp.ElementsArray)
        RETURN VARCHAR2;

FUNCTION evaluate_criteria(p_plan_id            IN NUMBER,
                             p_criteria_values    IN VARCHAR2,
                             p_relationship_type  IN NUMBER,
                             p_data_entry_mode    IN NUMBER,
                             x_child_plan_ids     OUT NOCOPY VARCHAR2)
        RETURN VARCHAR2;

FUNCTION aggregate_functions(p_sql_string IN VARCHAR2,
                             p_occurrence IN NUMBER,
                             p_child_plan_id IN NUMBER,
                             x_value OUT NOCOPY NUMBER)
        RETURN VARCHAR2;

--
-- bug 5682448
-- added the Txn_header_id parameter
-- ntungare Wed Feb 21 07:25:10 PST 2007
--
FUNCTION aggregate_functions(p_sql_string IN VARCHAR2,
                             p_occurrence IN NUMBER,
                             p_child_plan_id IN NUMBER,
                             p_txn_header_id IN NUMBER,
                             x_value OUT NOCOPY NUMBER)
        RETURN VARCHAR2;

FUNCTION get_plan_name(p_plan_ids IN VARCHAR2 , x_plan_name OUT NOCOPY VARCHAR2)
        RETURN VARCHAR2;

FUNCTION find_parent(p_child_plan_id IN NUMBER, p_child_collection_id IN NUMBER,
                     p_child_occurrence IN NUMBER, x_parent_plan_id OUT NOCOPY NUMBER,
                     x_parent_collection_id OUT NOCOPY NUMBER,
                     x_parent_occurrence OUT NOCOPY NUMBER)
        RETURN VARCHAR2;

FUNCTION should_parent_spec_be_copied(p_parent_plan_id IN NUMBER,
                                      p_child_plan_id IN NUMBER)
        RETURN VARCHAR2;

FUNCTION is_parent_child_plan(p_plan_id NUMBER)
        RETURN VARCHAR2;

FUNCTION update_parent(p_parent_plan_id IN NUMBER,
                       p_parent_collection_id IN NUMBER,
                       p_parent_occurrence IN NUMBER,
                       p_child_plan_id IN NUMBER,
                       p_child_collection_id IN NUMBER,
                       p_child_occurrence IN NUMBER)
        RETURN VARCHAR2;

-- 12.1 QWB Usability Improvements
-- Overloaded the existing API and added 2 new parameters
-- to get a list of the aggreagted elements and the
-- aggregated values
--
--
-- bug 7046071
-- Added the parameter p_ssqr_operation parameter to check if the
-- call is done from the OAF application or from Forms
-- In case of the OAF application, the COMMIT that is
-- executed in the aggregate_parent must not be called
-- ntungare
--
FUNCTION update_parent(p_parent_plan_id IN NUMBER,
                       p_parent_collection_id IN NUMBER,
                       p_parent_occurrence IN NUMBER,
                       p_child_plan_id IN NUMBER,
                       p_child_collection_id IN NUMBER,
                       p_child_occurrence IN NUMBER,
                       x_agg_elements OUT NOCOPY VARCHAR2,
                       x_agg_val OUT NOCOPY VARCHAR2,
                       p_ssqr_operation IN NUMBER DEFAULT NULL)
        RETURN VARCHAR2;

FUNCTION update_child(p_parent_plan_id IN NUMBER,
                       p_parent_collection_id IN NUMBER,
                       p_parent_occurrence IN NUMBER,
                       p_child_plan_id IN NUMBER,
                       p_child_collection_id IN NUMBER,
                       p_child_occurrence IN NUMBER)
         RETURN VARCHAR2;

-- Bug 5114865
-- New function to handle the Copying
-- of sequences between Parent Child Plans
-- ntungare Wed Mar  8 08:57:24 PST 2006
--
FUNCTION update_sequence_child (p_ParentChild_Tab IN QA_PARENT_CHILD_PKG.ParentChildTabTyp)
         RETURN VARCHAR2;

PROCEDURE get_criteria_values(p_parent_plan_id IN NUMBER,
                              p_parent_collection_id IN NUMBER,
                              p_parent_occurrence IN NUMBER,
                              p_organization_id IN NUMBER,
                              x_criteria_values OUT NOCOPY VARCHAR2);

PROCEDURE insert_history_auto_rec(p_parent_plan_id IN NUMBER,
                                  p_txn_header_id IN NUMBER,
                                  p_relationship_type IN NUMBER,
                                  p_data_entry_mode IN NUMBER);

  -- Bug 3536025. Adding this new procedure insert_history_auto_QWB,
  -- which will be called from qltssreb.pls (Quality WorkBench) for
  -- inserting history/automatic child plans.Earlier it used
  -- insert_history_auto_rec() procedure.
  -- srhariha. Wed May 26 22:31:28 PDT 2004

/*
PROCEDURE insert_history_auto_rec_QWB(p_parent_plan_id IN NUMBER,
                                      p_txn_header_id IN NUMBER,
                                      p_relationship_type IN NUMBER,
                                      p_data_entry_mode IN NUMBER);
*/

-- Bug 3681815. Changing the signature of the procedure due to incorrect
-- number of rows getting created for automatic child plans.
-- saugupta Tue, 15 Jun 2004 04:08:38 -0700 PDT

PROCEDURE insert_history_auto_rec_QWB(p_plan_id           IN NUMBER,
                                      p_collection_id     IN NUMBER,
                                      p_occurrence        IN NUMBER,
                                      p_organization_id   IN NUMBER,
                                      p_txn_header_id     IN NUMBER,
                                      p_relationship_type IN NUMBER,
                                      p_data_entry_mode   IN NUMBER,
                                      x_status  OUT NOCOPY VARCHAR2);



FUNCTION is_parent_saved(p_plan_id  IN NUMBER,

                          p_collection_id IN NUMBER,
                          p_occurrence IN NUMBER)
        RETURN VARCHAR2;

FUNCTION update_all_children(p_parent_plan_id IN NUMBER,
                       p_parent_collection_id IN NUMBER,
                       p_parent_occurrence IN NUMBER)
        RETURN VARCHAR2;

 FUNCTION applicable_child_plans_eqr( p_plan_id          IN NUMBER ,
                                        p_criteria_values  IN VARCHAR2)
                                        RETURN VARCHAR2;

   --this function returns a string of the form
   --<plan_id>=<data_entry_mode>@<plan_id>=... representing all
   --child_plans which match the criteria values passed in
   FUNCTION applicable_child_plans(p_plan_id            IN NUMBER,
                                   p_criteria_values    IN VARCHAR2)
      RETURN VARCHAR2;


 FUNCTION is_context_element( p_plan_id IN NUMBER ,
                              p_char_id IN NUMBER,
                              p_parent_plan_id IN NUMBER,
                              p_txn_or_child_flag IN NUMBER)
                                        RETURN VARCHAR2;

 FUNCTION get_parent_vo_attribute_name(p_child_char_id IN NUMBER,
                                       p_plan_id IN NUMBER)
                                        RETURN VARCHAR2 ;

 --
 -- bug 8417775
 -- Overloaded the function to read the
 -- child plan id as well
 -- ntungare
 --
 FUNCTION get_parent_vo_attribute_name(p_child_char_id IN NUMBER,
                                       p_plan_id IN NUMBER,
                                       p_child_plan_id IN NUMBER)
                                        RETURN VARCHAR2 ;

 FUNCTION get_layout_mode (p_parent_plan_id IN NUMBER,
                           p_child_plan_id IN NUMBER)
                        RETURN NUMBER;


 FUNCTION ssqr_post_actions(p_txn_hdr_id IN NUMBER,
                            p_plan_id IN NUMBER,
                            p_transaction_number IN NUMBER,
                            x_sequence_string OUT NOCOPY VARCHAR2)
                           RETURN VARCHAR2;

 FUNCTION count_updated(p_plan_id IN NUMBER,
                        p_txn_header_id IN NUMBER) RETURN NUMBER;

 FUNCTION get_vud_allowed ( p_plan_id IN NUMBER)
    RETURN VARCHAR2 ;

 FUNCTION update_parent(p_parent_plan_id IN NUMBER,
                       p_parent_collection_id IN NUMBER,
                       p_parent_occurrence IN NUMBER,
                       p_child_plan_id IN NUMBER,
                       p_child_collection_id IN NUMBER,
                       p_child_occurrence IN NUMBER,
                       p_child_txn_hdr_id IN NUMBER)
        RETURN VARCHAR2 ;

 -- 12.1 QWB Usability Improvements project
 --
 FUNCTION update_parent(p_parent_plan_id IN NUMBER,
                       p_parent_collection_id IN NUMBER,
                       p_parent_occurrence IN NUMBER,
                       p_child_plan_id IN NUMBER,
                       p_child_collection_id IN NUMBER,
                       p_child_occurrence IN NUMBER,
                       p_child_txn_hdr_id IN NUMBER,
                       x_agg_elements OUT NOCOPY VARCHAR2,
                       x_agg_val OUT NOCOPY VARCHAR2)
        RETURN VARCHAR2 ;

 -- Added this new procedure for Bug 3646166.
 -- See package body for more details.suramasw.

 PROCEDURE DELETE_RELATIONSHIP_ROW(p_child_plan_id IN NUMBER,
                                   p_child_occurrence IN NUMBER);

  -- Bug 4343758
  -- R12 OAF Txn Integration Project
  -- shkalyan 05/13/2005.
  -- Function to delete a Result Row and and it's parent child relationship
  FUNCTION delete_row(
      p_plan_id          IN         NUMBER,
      p_collection_id    IN         NUMBER,
      p_occurrence       IN         NUMBER,
      p_enabled          IN         NUMBER := NULL) RETURN VARCHAR2;


   -- Bug 4345779. Audits Copy UI project.
   -- Code Review feedback incorporation. CR Ref 4.9.5, 4.9.6 and 4.9.7
   -- Modularization. Parent child API's must be defined in parent pkg.
   -- srhariha. Tue Jul 12 02:12:17 PDT 2005.

   --
   -- Parent-Child collections API. Operaters on collection of records.
   --


   --
   -- Creates relationship between given parent row and collection of
   -- child rows.
   --

   PROCEDURE create_relationship_for_coll
                                ( p_parent_plan_id NUMBER,
                                  p_parent_collection_id NUMBER,
                                  p_parent_occurrence NUMBER,
                                  p_child_plan_id NUMBER,
                                  p_child_collection_id NUMBER,
                                  p_org_id NUMBER);

   --
   -- Performs copy relationship between given parent row and collection of
   -- child rows.
   --

   PROCEDURE copy_from_parent_for_coll
                             ( p_parent_plan_id NUMBER,
                               p_parent_collection_id NUMBER,
                               p_parent_occurrence NUMBER,
                               p_child_plan_id NUMBER,
                               p_child_collection_id NUMBER,
                               p_org_id NUMBER);


   --
   -- Creates history for given collection
   --

   PROCEDURE create_history_for_coll
                          ( p_plan_id NUMBER,
                            p_collection_id NUMBER,
                            p_org_id NUMBER,
                            p_txn_header_id NUMBER);


  -- Bug 4502450. R12 Esig Status support in Multirow UQR
  -- saugupta Wed, 24 Aug 2005 08:40:09 -0700 PDT

  --
  -- get all the grand parents for the child plan
  --
  FUNCTION get_ancestors( p_child_plan_id IN NUMBER,
                        p_child_occurrence IN NUMBER,
                        p_child_collection_id IN NUMBER,
                        x_parent_plan_ids          OUT NOCOPY dbms_sql.number_table,
                        x_parent_collection_ids    OUT NOCOPY dbms_sql.number_table,
                        x_parent_occurrences       OUT NOCOPY dbms_sql.number_table)
      RETURN VARCHAR2;

  -- Bug 5435657
  -- New procedure to update the aggregate values
  -- on all the ancestors of the Plan_id passed,
  -- in case such a P-C relationship
  -- exists
  -- ntungare Wed Aug  2 20:53:40 PDT 2006
  --
  PROCEDURE update_all_ancestors(p_parent_plan_id       IN NUMBER,
                                 p_parent_collection_id IN NUMBER,
                                 p_parent_occurrence    IN NUMBER);

  --
  -- bug 6134920
  -- Added a new procedure to delete all the status
  -- 1 invalid child records, generated during an
  -- incomplete txn
  -- ntungare Tue Jul 10 23:05:24 PDT 2007
  --
  PROCEDURE delete_invalid_children(p_txn_header_id IN NUMBER);

  -- 12.1 QWB Usability Improvements
  -- New method to check if a Parent Plan record
  -- has any applicable child plan into which data can be
  -- entered.
  --
  FUNCTION has_enterable_child(p_plan_id in number,
                               p_collection_id in number,
                               p_occurrence in number)
   RETURN varchar2;

  -- 12.1 QWB Usability Improvements
  -- New method to check if there aare any updatable child records
  --
  FUNCTION child_exists_for_update(p_plan_id       IN NUMBER,
                                   p_collection_id IN NUMBER,
                                   p_occurrence    IN NUMBER)
    RETURN VARCHAR2;

  -- 12.1 QWB usability Improvements
  -- New method to get a count of child records
  -- present for any parent plan record
  --
  FUNCTION getChildCount(p_plan_id       IN NUMBER,
                         p_collection_id IN NUMBER,
                         p_occurrence    IN NUMBER)
    RETURN NUMBER;

  -- 12.1 Quality Inline Transaction INtegration
  -- New method to identify whether a plan has
  -- child plans associated with it or not
  --
  FUNCTION has_child(p_plan_id IN NUMBER)
    RETURN INTEGER;

-- 12.1 QWB Usability Improvements project
-- Function to update all the History
-- Child records corresponding to a parent record
FUNCTION update_hist_children(p_parent_plan_id IN NUMBER,
                       p_parent_collection_id IN NUMBER,
                       p_parent_occurrence IN NUMBER)
        RETURN VARCHAR2;

-- Bug 7436465.FP for Bug 7035041.pdube Fri Sep 26 03:46:20 PDT 2008
-- Inroduced a table type and a procedure to check if any child
-- record exists for parent record.
TYPE result_column_name_tab_typ IS TABLE OF qa_plan_chars.result_column_name%TYPE INDEX BY BINARY_INTEGER;
FUNCTION IF_CHILD_RECORD_EXISTS( p_plan_id IN NUMBER,
                                 p_collection_id IN NUMBER,
                                 p_occurrence IN NUMBER) RETURN result_column_name_tab_typ;


-- Bug 8546279.FP for 8446050.pdube
PROCEDURE get_deref_column(p_parent_result_column IN     VARCHAR2,
                            p_parent_plan_id       IN     NUMBER,
                            x_select_column        OUT NOCOPY VARCHAR2);

END QA_PARENT_CHILD_PKG;

/
