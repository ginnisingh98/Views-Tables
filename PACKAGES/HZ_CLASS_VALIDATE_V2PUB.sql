--------------------------------------------------------
--  DDL for Package HZ_CLASS_VALIDATE_V2PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."HZ_CLASS_VALIDATE_V2PUB" AUTHID CURRENT_USER AS
/*$Header: ARH2CLVS.pls 120.3.12000000.2 2007/10/01 15:10:27 manjayar ship $ */
/*---------------------------------------------------------
  -- Component for every entities in classification module-
  ---------------------------------------------------------*/
PROCEDURE check_existence_class_category
-- Check if the class_Category exists
 (p_class_category     IN     VARCHAR2,
  x_return_status      IN OUT NOCOPY VARCHAR2);

FUNCTION is_valid_delimiter(p_class_category in varchar2, p_delimiter in
varchar2) return varchar2;

FUNCTION is_valid_class_code_meaning(p_class_category in varchar2, p_meaning in
varchar2) return varchar2;

/*
FUNCTION result_caller
(pack   VARCHAR2,
 comp   VARCHAR2,
 code0  VARCHAR2 DEFAULT NULL,
 code1  VARCHAR2 DEFAULT NULL,
 code2  VARCHAR2 DEFAULT NULL,
 code3  VARCHAR2 DEFAULT NULL,
 code4  VARCHAR2 DEFAULT NULL,
 code5  VARCHAR2 DEFAULT NULL,
 code6  VARCHAR2 DEFAULT NULL,
 code7  VARCHAR2 DEFAULT NULL,
 code8  VARCHAR2 DEFAULT NULL,
 code9  VARCHAR2 DEFAULT NULL,
 date0  DATE DEFAULT NULL,
 date1  DATE DEFAULT NULL,
 date2  DATE DEFAULT NULL,
 date3  DATE DEFAULT NULL,
 date4  DATE DEFAULT NULL,
 date5  DATE DEFAULT NULL,
 date6  DATE DEFAULT NULL,
 date7  DATE DEFAULT NULL,
 text   VARCHAR2 DEFAULT NULL)
RETURN VARCHAR2;
*/

/* --Bug 3962783
procedure check_err(
	x_return_status    IN  VARCHAR2
);
*/

PROCEDURE check_start_end_active_dates(
          p_start_date_active   IN DATE,
          p_end_date_active     IN DATE,
          x_return_status       IN OUT NOCOPY VARCHAR2);


/*--------------------------------------
 -- Validation for Hz_Class_Categories -
 ---------------------------------------*/
FUNCTION exist_code_ass_not_node
-- This function answer to the question:
-- Return 'Y'  if the category has one or more Non-Leaf-node Class Codes associated with instances of entities
--             active for to_date
--        'N'  otherwise
( p_class_category IN VARCHAR2)
RETURN VARCHAR2;

FUNCTION exist_reverse_relation
-- Return 'Y' if the entered sub-code was defined as the parent-code of the entered class-code within that category
--            for active periods
--        'N' otherwise
( p_class_category IN VARCHAR2,
  p_class_code     IN VARCHAR2,
  p_sub_class_code IN VARCHAR2,
  p_start_date_active IN DATE,
  p_end_date_active   IN DATE)
RETURN VARCHAR2;

FUNCTION is_all_code_one_parent_only
-- Return Y if all class codes inside a category have no more than one parent for the current and futur period
--        N otherwise
(p_class_category     VARCHAR2,
 x_class_code         IN OUT NOCOPY VARCHAR2,
 x_class_code2        IN OUT NOCOPY VARCHAR2,
 x_sub_class_code     IN OUT NOCOPY VARCHAR2,
 x_start_date_active  IN OUT NOCOPY DATE,
 x_end_date_active    IN OUT NOCOPY DATE,
 x_start_date_active2 IN OUT NOCOPY DATE,
 x_end_date_active2   IN OUT NOCOPY DATE )
RETURN VARCHAR2;

FUNCTION is_all_inst_less_one_code
-- Return Y if all the instances of 1 entity has 0 to 1 code assigned
--          for 1 category, 1 content active to day or in the futur.
--        N otherwise
( p_class_category      VARCHAR2,
  x_owner_table         IN OUT NOCOPY VARCHAR2,
  x_owner_table_id      IN OUT NOCOPY VARCHAR2,
  x_content_source_type IN OUT NOCOPY VARCHAR2,
  x_class_code          IN OUT NOCOPY VARCHAR2,
  x_class_code2         IN OUT NOCOPY VARCHAR2,
  x_start_date_active   IN OUT NOCOPY DATE,
  x_end_date_active     IN OUT NOCOPY DATE,
  x_start_date_active2  IN OUT NOCOPY DATE,
  x_end_date_active2    IN OUT NOCOPY DATE )
RETURN VARCHAR2;

FUNCTION exist_class_category
-- Return Y if the class category exists
--        N otherwise
(p_class_category  VARCHAR2 )
RETURN VARCHAR2;

/*===========================================================================+
 | PROCEDURE                                                                 |
 |              validate_class_category                                      |
 | DESCRIPTION                                                               |
 | SCOPE - PRIVATE                                                           |
 | EXETERNAL PROCEDURES/FUNCTIONS ACCESSED                                   |
 | ARGUMENTS  : IN:     p_class_cat_rec                                      |
 |                      create_update_flag                                   |
 |          IN/ OUT:    x_return_status                                      |
 | RETURNS    : NONE                                                         |
 | NOTES                                                                     |
 | MODIFICATION HISTORY                                                      |
 |    Young Li   22-JUN-00  Created                                          |
 +===========================================================================*/
procedure validate_class_category(
 p_class_cat_rec      IN     HZ_CLASSIFICATION_V2PUB.CLASS_CATEGORY_REC_TYPE,
 create_update_flag   IN     VARCHAR2,
 x_return_status	    IN OUT NOCOPY VARCHAR2
);


/*-----------------------------------------
 -- Validation for Hz_Class_Category_Uses -
 ------------------------------------------*/
FUNCTION existence_couple_clacat_owntab
-- Return 'Y' if the couple exits
--        'N' otherwise
 ( p_create_update_flag IN     VARCHAR2,
   p_class_category     IN     VARCHAR2,
   p_owner_table        IN     VARCHAR2 )
RETURN VARCHAR2;

/*===========================================================================+
 | PROCEDURE                                                                 |
 |              validate_class_category_use                                  |
 | DESCRIPTION                                                               |
 | SCOPE - PRIVATE                                                           |
 | EXTERNAL PROCEDURES/FUNCTIONS ACCESSED                                    |
 | ARGUMENTS  : IN:                                                          |
 |                      hz_classification_V2PUB.class_category_use_rec_type  |
 |                      create_update_flag                                   |
 |          IN/ OUT:                                                         |
 |                      x_return_status                                      |
 | RETURNS    : NONE                                                         |
 | MODIFICATION HISTORY                                                      |
 |    Herve Yu   18-JUN-01  Created                                          |
 +===========================================================================*/
PROCEDURE validate_class_category_use(
  p_in_rec           IN     hz_classification_V2PUB.class_category_use_rec_type,
  create_update_flag IN     VARCHAR2,
  x_return_status    IN OUT NOCOPY VARCHAR2 );


/*-------------------------------------------
 -- Validation for Hz_Class_Code_Assignment -
 --------------------------------------------*/
FUNCTION date_betw_value_dates
-- Return 'Y'  if p_date_active is between the active dates of the particular Class Code
--        'N'  otherwise
( p_class_category        IN VARCHAR2,
  p_class_code            IN VARCHAR2,
  p_start_date_active     IN DATE )
RETURN VARCHAR2;

FUNCTION instance_already_assigned
-- Return 'Y'  If for ( 1 entity, 1 instance, 1 category , 1 content source, 1 period ),
--               we find at least 1 code different
-- Return 'N'  otherwise
( p_start_date_active   DATE,
  p_end_date_active     DATE,
  p_owner_table_name    VARCHAR2,
  p_owner_table_id      VARCHAR2,
  p_class_category      VARCHAR2,
  p_content_source_type VARCHAR2,
  x_class_code          IN OUT NOCOPY VARCHAR2,
  x_start_date_active   IN OUT NOCOPY DATE,
  x_end_date_active     IN OUT NOCOPY DATE)
RETURN VARCHAR2;

FUNCTION is_leaf_node_category
-- Return 'Y'  if the Class Category entered has its ALLOW_LEAF_NODE_ONLY_FLAG to Y
--        'N' otherwise
( p_class_category IN VARCHAR2)
RETURN VARCHAR2;

FUNCTION is_categ_multi_assig
-- Return 'Y' if the category has its allow_multi_assign_flag to Y
--        'N' otherwise
( p_class_category VARCHAR2)
RETURN VARCHAR2;

FUNCTION is_assig_record_id_valid
 -- Returns Y If the Record ID in the owner table associated with the category is valid
 --           and x_reason will content 'Table.column=value is valid against category.'
 -- Otherwise N and x_reason will content the message name to display
 --             HZ_API_USE_TAB_CAT if there is no usage between the category and the table
 --             HZ_API_CLA_CAT_WHERE if the value cannot be validate against the where_clause
 --             Standard Oracle error message otherwise
( p_owner_table_name IN VARCHAR2,
  p_owner_table_id   IN VARCHAR2,
  p_class_category   IN VARCHAR2,
  x_reason           IN OUT NOCOPY VARCHAR2,
  x_column_name      IN OUT NOCOPY VARCHAR2)
RETURN VARCHAR2;


FUNCTION sql_valid
--  Returns   1) Y if the statement retrieve at least 1 value
--               And x_result will contain this value.
--            2) N if the statement retrieve non value
--               And x_result will contain 'NON_VALUE'
--            3) N if the statement falls into Error
--               And x_result contain the standard Oracle message
( i_str     IN VARCHAR2,
  x_result  IN OUT NOCOPY VARCHAR2 )
RETURN VARCHAR2;

FUNCTION sql_str_build
-- Returns   1) Y if it successfully construct the statement
--              And x_statement will contain the statement
--              And x_column_name will contain the column_name
--           2) N if it fails in constructing the statement
--              And x_statement will contain the reason
( p_owner_table_name IN VARCHAR2,
  p_owner_table_id   IN VARCHAR2,
  p_class_category   IN VARCHAR2,
  x_column_name      IN OUT NOCOPY VARCHAR2,
  x_statement        IN OUT NOCOPY VARCHAR2)
RETURN VARCHAR2;

function exist_pk_code_assign
-- Return 'Y' if one code_assignment_id is found for
--              1 owner_table,
--              1 owner_table_id
--              1 category
--              1 code
--              1 source content type
--              1 start date active
--         'N' otherwise
(p_owner_table_name     varchar2,
 p_owner_table_id       varchar2,
 p_class_category       varchar2,
 p_class_code           varchar2,
 p_content_source_type  varchar2,
 p_start_date_active    date,
 x_id            in out NOCOPY varchar2,
 x_end_date      in out NOCOPY date)
return varchar2;

function exist_prim_assign
( create_update_flag    varchar2,
  p_class_category      varchar2,
  p_owner_table_name    varchar2,
  p_owner_table_id      varchar2,
  p_content_source_type varchar2,
  p_start_date_active   date,
  p_end_date_active     date,
  x_class_code          in out NOCOPY varchar2,
  x_start_date          in out NOCOPY date,
  x_end_date            in out NOCOPY date )
return varchar2;

function exist_same_code_assign
( create_update_flag    varchar2,
  p_class_category      varchar2,
  p_class_code          varchar2,
  p_owner_table_name    varchar2,
  p_owner_table_id      varchar2,
  p_content_source_type varchar2,
  p_start_date_active   date,
  p_end_date_active     date,
  x_class_code          in out NOCOPY varchar2,
  x_start_date          in out NOCOPY date,
  x_end_date            in out NOCOPY date )
return varchar2;

function exist_second_assign_same_code
( create_update_flag    varchar2,
  p_class_category      varchar2,
  p_class_code          varchar2,
  p_owner_table_name    varchar2,
  p_owner_table_id      varchar2,
  p_content_source_type varchar2,
  p_start_date_active   date,
  p_end_date_active     date,
  x_class_code          in out NOCOPY varchar2,
  x_start_date          in out NOCOPY date,
  x_end_date            in out NOCOPY date )
return varchar2;

procedure cre_upd_code_ass_com
( p_create_update_flag  varchar2,
  p_class_category      varchar2,
  p_class_code          varchar2,
  p_owner_table_name    varchar2,
  p_owner_table_id      varchar2,
  p_content_source_type varchar2,
  p_primary_flag        varchar2,
  p_start_date_active   date,
  p_end_date_active     date ,
  x_return_status    IN OUT NOCOPY VARCHAR2);


/*===========================================================================+
 | PROCEDURE                                                                 |
 |              validate_code_assignment                                     |
 | DESCRIPTION                                                               |
 | SCOPE - PRIVATE                                                           |
 | ARGUMENTS  : IN:     p_in_rec                                             |
 |                      create_update_flag                                   |
 |          IN/ OUT:    x_return_status                                      |
 | RETURNS    : NONE                                                         |
 | MODIFICATION HISTORY                                                      |
 |    Young Li   22-JUN-00  Created                                          |
 |    Herve Yu   24-JAN-01  Modify  => MULTI_ASSIGNMENT_FLAG                 |
 |                                                                           |
 +===========================================================================*/
procedure validate_code_assignment(
 p_in_rec            IN     HZ_CLASSIFICATION_V2PUB.CODE_ASSIGNMENT_REC_TYPE,
 create_update_flag  IN     VARCHAR2,
 x_return_status     IN OUT NOCOPY VARCHAR2
);


/*-------------------------------------------
 -- Validation for Hz_Class_Code_Relations  -
 --------------------------------------------*/
TYPE gen_rec IS RECORD( class_code        VARCHAR2(30),
                        sub_class_code    VARCHAR2(30),
                        start_date_active DATE,
                        end_date_active   DATE,
                        generation        NUMBER);

TYPE gen_list IS TABLE OF gen_rec INDEX BY BINARY_INTEGER;

FUNCTION parent_code
-- Return Y if the class code in the class category has already one parent
--        N otherwise
( p_class_category    VARCHAR2,
  p_class_code        VARCHAR2,
  p_start_date_active DATE,
  p_end_date_active   DATE,
  x_child_code        IN OUT NOCOPY VARCHAR2,
  x_start_date_active IN OUT NOCOPY DATE,
  x_end_date_active   IN OUT NOCOPY DATE)
RETURN VARCHAR2;

FUNCTION child_code
-- Return Y if the p_class_code in the p_class_category for that period has one or more parent
--        N otherwise
(p_class_category    VARCHAR2,
 p_class_code        VARCHAR2,
 p_start_date_active DATE,
 p_end_date_active   DATE,
 x_parent_code       IN OUT NOCOPY VARCHAR2,
 x_start_date_active IN OUT NOCOPY DATE,
 x_end_date_active   IN OUT NOCOPY DATE)
RETURN VARCHAR2;

FUNCTION is_categ_multi_parent
-- Return 'Y' if the category has its allow_multi_parent_flag to Y
--        'N' otherwise
( p_class_category VARCHAR2)
RETURN VARCHAR2;

FUNCTION previous_generation
-- Return a Gen_List fill with the parents class_code of the in_tab(i).class_code
--                   i rang from 1 to the dimension of tab. All the parent codes
--                   of all the class codes contained in in_tab will be returned in Gen_list
--       Parameter : The array containing the class_codes
--                   The Class Category in which we want to find the parent codes
--                   The duration during which we want to search. Every parent code which relation
--                       with the class codes contained in in_tab is out NOCOPY of range will no more be
--                       considered as a parent.
--
(in_tab            in gen_list,
 in_class_category in varchar2,
 in_date_start     in date,
 in_date_end       in date default null,
 in_generation     in number)
RETURN gen_list;

FUNCTION next_generation
-- Return a Gen_List fill with the sub_class_code of the in_tab(i).class_code
--                   i rang from 1 to the dimension of tab. All the sub codes
--                   of all the class codes contained in in_tab will be returned in Gen_list
--       Parameter : The array containing the class_codes
--                   The Class Category in which we want to find the sub codes
--                   The duration during which we want to search. Every sub code which relation
--                       with the class codes contained in in_tab is out NOCOPY of range will no more be
--                       considered as a child.
(in_tab            in gen_list,
 in_class_category in varchar2,
 in_date_start     in date,
 in_date_end       in date default null,
 in_generation     in number)
RETURN gen_list;

FUNCTION tab_concatenated
-- Return a Gen_List concatenated from
--          in_tab1 and
--          in_tab2
( in_tab1  in gen_list,
  in_tab2  in gen_list)
RETURN gen_list;

FUNCTION exist_rec_in_list_poc
-- Return 'Y' if the Gen_Rec is in the Gen_List depending on a def of existence
--            if in_poc = 'CODE' will be considered as existence those Records which Class_Code is the same
--            if in_poc = 'SUB'  will be considered as existence those Records which Sub_Class_Code is the same
--        'N' Otherwise
(in_tab  in gen_list,
 in_rec  in gen_rec,
 in_poc  in VARCHAR2)
RETURN VARCHAR2;

FUNCTION tab_normal_poc
-- Return a Gen_Rec which is a sub set of the in_tab to avoid redundancies
--        Redundoncies depend on the def of existence in_poc ['CODE','SUB']
(in_tab  in gen_list,
 in_poc  in VARCHAR2)
RETURN gen_list;

FUNCTION set_of_parents
-- Return a Gen_List of all the ancestor of a given Class Code
(in_class_category in varchar2,
 in_class_code     in varchar2,
 in_date_start     in date,
 in_date_end       in date default null)
RETURN  gen_list;

FUNCTION set_of_children
-- Return a Gen_list with all the decendants of a given Sub Class Code
(in_class_category in varchar2,
 in_sub_class_code in varchar2,
 in_date_start     in date,
 in_date_end       in date default null)
RETURN  gen_list;

FUNCTION is_cod1_ancest_cod2
-- Return 'Y' if cod1 is ancestor of cod2
--        'N' otherwise
(in_class_category in varchar2,
 in_class_code_1   in varchar2,
 in_class_code_2   in varchar2,
 in_date_start     in date,
 in_date_end       in date default null)
RETURN varchar2;

FUNCTION is_cod1_descen_cod2
-- Return 'Y' if cod1 is descendant of cod2
--        'N' otherwise
(in_class_category in varchar2,
 in_class_code_1   in varchar2,
 in_class_code_2   in varchar2,
 in_date_start     in date,
 in_date_end       in date default null)
RETURN varchar2;

Function exist_pk_relation
-- Return 'Y' if the relation Already exists
--        'N' otherwise
( p_class_category varchar2,
  p_class_code     varchar2,
  p_sub_class_code varchar2,
  p_start_date_active date,
  x_end_date_active in out NOCOPY date)
return varchar2;

Function exist_overlap_relation
-- returns 'Y' if it exists a relation which overlap the one we entered
--         'N' otehrwise
( p_create_update_flag varchar2,
  p_class_category  varchar2,
  p_class_code      varchar2,
  p_sub_class_code  varchar2,
  p_start_date_active date,
  p_end_date_active   date,
  x_start_date_active in out NOCOPY date,
  x_end_date_active   in out NOCOPY date  )
Return varchar2;

/*===========================================================================+
 | PROCEDURE                                                                 |
 |              validate_class_code_relation                                 |
 | DESCRIPTION                                                               |
 |              Validates class_code_relation. Checks for:                   |
 |                      lookup types                                         |
 |                      mandatory columns                                    |
 | EXETERNAL PROCEDURES/FUNCTIONS ACCESSED                                   |
 | ARGUMENTS  : IN:                                                          |
 |                      p_in_rec                                             |
 |                      create_update_flag                                   |
 |              OUT:                                                         |
 |          IN/ OUT:                                                         |
 |						x_return_status              |
 | MODIFICATION HISTORY                                                      |
 |    Young Li   22-JUN-00  Created                                          |
 |    Herve Yu   23-JAN-01  add use of exist_reverse_relation                |
 +===========================================================================*/
procedure validate_class_code_relation(
 p_in_rec            IN      HZ_CLASSIFICATION_V2PUB.CLASS_CODE_RELATION_REC_TYPE,
 create_update_flag  IN      VARCHAR2,
 x_return_status     IN OUT NOCOPY  VARCHAR2
);

FUNCTION is_overlap
-- Returns 'Y' if period [s1,e1] overlaps [s2,e2]
--         'N' otherwise
--         NULL indicates infinite for END dates
(s1 DATE,
 e1 DATE,
 s2 DATE,
 e2 DATE)
RETURN VARCHAR2;

 -----------------------------------------------------------------
   /**
    * PROCEDURE chk_exist_cls_catgry_type_code
    *
    * DESCRIPTION
    *     This procedure is used to check existing record for class category type,
    *     class code, security group id, application id, and language combination
    *     which are difined in FND_LOOKUP_VALUES_U1.
    *
    * ARGUMENTS
    *   IN:
    *     p_class_category_type          Related to class category type column
    *     p_class_category_code          Related to class code column
    *     p_security_group_id            Rleated to security group id column
    *     p_view_application_id          Related to application id column
    *
    *   IN/OUT:
    *     x_return_status                Return status after the call. The status can
    *                                    be FND_API.G_RET_STS_ERROR (error)
    *
    * NOTES
    *
    * CREATION/MODIFICATION HISTORY
    *
    *   09-20-2007    Manivannan J       o Created for Bug 6158794.
    */
   -----------------------------------------------------------------


   PROCEDURE chk_exist_cls_catgry_type_code
   (
     p_class_category_type IN     VARCHAR2,
     p_class_category_code IN     VARCHAR2,
     p_security_group_id   IN     NUMBER,
     p_view_application_id IN     NUMBER,
     x_return_status       IN OUT NOCOPY VARCHAR2);

   -----------------------------------------------------------------
   /**
    * PROCEDURE chk_exist_clas_catgry_typ_mng
    *
    * DESCRIPTION
    *     This procedure is used to check existing record for class category type
    *     , class meaning, security group id, application id, and language combination
    *     which are difined in FND_LOOKUP_VALUES_U2.
    *
    * ARGUMENTS
    *   IN:
    *     p_class_category_type          Related to class category type column
    *     p_class_category_meaning       Related to class meaning column
    *     p_security_group_id            Rleated to security group id column
    *     p_view_application_id          Related to application id column
    *
    *   IN/OUT:
    *     x_return_status                Return status after the call. The status can
    *                                    be FND_API.G_RET_STS_ERROR (error)
    *
    * NOTES
    *
    * CREATION/MODIFICATION HISTORY
    *
    *   09-20-2007    Manivannan J       o Created for Bug 6158794.
    */
   -----------------------------------------------------------------


   PROCEDURE chk_exist_clas_catgry_typ_mng
   (
     p_class_category_type    IN     VARCHAR2,
     p_class_category_meaning IN     VARCHAR2,
     p_security_group_id      IN     NUMBER,
     p_view_application_id    IN     NUMBER,
     x_return_status          IN OUT NOCOPY VARCHAR2);

END hz_class_validate_v2pub;

 

/
