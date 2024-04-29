--------------------------------------------------------
--  DDL for Package GL_COA_SEG_VAL_IMP_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."GL_COA_SEG_VAL_IMP_PUB" AUTHID CURRENT_USER AS
/* $Header: GLSVIPBS.pls 120.0.12010000.1 2009/12/16 11:53:13 sommukhe noship $ */
/***********************************************************************************************
Created By: Somnath Mukherjee
Date Created By: 01-AUG-2008
Purpose:            A public API to import data from external system to GL is declared along with
                    several PL-SQL table types to be used in the API.
Known limitations,enhancements,remarks:

Change History

Who         When           What

***********************************************************************************************/
-- Start of Comments
-- API Name               : Chart of Accounts Segment Values import
-- Type                   : Public
-- Pre-reqs               : None
-- Function               : Imports Chart of Accounts Segment Values from external System to General Ledger
-- Parameters
-- IN                       p_api_version
-- IN                       p_init_msg_list
-- IN                       p_commit
-- IN                       p_validation_level
-- OUT                      x_return_status
-- OUT                      x_msg_count
-- OUT                      x_msg_data
-- IN OUT                   p_gl_flex_values_tbl
--

-- OUT                      p_gl_flex_values_status
--                              This parameter returns the import status of Fnd Flex Values table


-- Version: Current Version  1.0
--          Previous Version
--          Initial Version  1.0
-- End of Comments



  /**********************fnd_flex_values Record Type ************/
TYPE gl_flex_values_rec_type IS RECORD (
value_set_name                  fnd_flex_value_sets.flex_value_set_name%TYPE ,
flex_value                      fnd_flex_values.flex_value%TYPE,
flex_desc                       fnd_flex_values_tl.description%TYPE,
parent_flex_value               fnd_flex_values.parent_flex_value_low%TYPE,
summary_flag                    fnd_flex_values.summary_flag%TYPE,
roll_up_group                   fnd_flex_hierarchies.hierarchy_code%TYPE,
hierarchy_level                 fnd_flex_values.hierarchy_level%TYPE,
allow_budgeting                 VARCHAR2(1),
allow_posting                   VARCHAR2(1),
account_type                    VARCHAR2(1),
reconcile                       VARCHAR2(1),
third_party_control_account     VARCHAR2(1),
enabled_flag                    fnd_flex_values.enabled_flag%TYPE,
effective_from                  DATE,
effective_to                    DATE,
msg_from                        NUMBER(6),
msg_to                          NUMBER(6),
status                          VARCHAR2(1),
interface_id                    NUMBER(15,0)
);
TYPE gl_flex_values_tbl_type IS TABLE OF gl_flex_values_rec_type INDEX BY BINARY_INTEGER;

TYPE gl_flex_values_nh_rec_type IS RECORD (
value_set_name                  fnd_flex_value_sets.flex_value_set_name%TYPE ,
parent_flex_value               fnd_flex_value_norm_hierarchy.parent_flex_value%TYPE,
range_attribute                 fnd_flex_value_norm_hierarchy.range_attribute%TYPE,
child_flex_value_low            fnd_flex_value_norm_hierarchy.child_flex_value_low%TYPE,
child_flex_value_high           fnd_flex_value_norm_hierarchy.child_flex_value_high%TYPE,
msg_from                        NUMBER(6),
msg_to                          NUMBER(6),
status                          VARCHAR2(1),
interface_id                    NUMBER(15,0)
);
TYPE gl_flex_values_nh_tbl_type IS TABLE OF gl_flex_values_nh_rec_type INDEX BY BINARY_INTEGER;

PROCEDURE coa_segment_val_imp (
p_api_version			      IN           NUMBER,
p_init_msg_list			      IN           VARCHAR2 DEFAULT FND_API.G_FALSE,
p_commit			      IN           VARCHAR2 DEFAULT FND_API.G_FALSE,
p_validation_level		      IN  NUMBER   DEFAULT FND_API.G_VALID_LEVEL_FULL,
x_return_status			      OUT NOCOPY   VARCHAR2,
x_msg_count			      OUT NOCOPY   NUMBER,
x_msg_data			      OUT NOCOPY   VARCHAR2,
p_gl_flex_values_obj_tbl	      IN OUT NOCOPY GL_FLEX_VALUES_OBJ_TBL,
p_gl_flex_values_nh_obj_tbl           IN OUT NOCOPY GL_FLEX_VALUES_NH_OBJ_TBL,
p_gl_flex_values_status		      OUT NOCOPY VARCHAR2,
p_gl_flex_values_nh_status	      OUT NOCOPY VARCHAR2

 ) ;



END gl_coa_seg_val_imp_pub;

/
