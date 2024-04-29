--------------------------------------------------------
--  DDL for Package MODAL_DELETE
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."MODAL_DELETE" AUTHID CURRENT_USER as
/*$Header: BOMMDELS.pls 120.1 2005/06/21 05:24:29 appldev ship $*/

/* This function sends an error message to the Forms message line when
   an error occurs.  This function is called by Forms only */

FUNCTION DELETE_MANAGER(
                new_group_seq_id        IN NUMBER,
                name                    IN VARCHAR2,
                group_desc              IN VARCHAR2,
                org_id                  IN NUMBER,
                bom_or_eng              IN NUMBER,
                del_type                IN NUMBER,
                ent_bill_seq_id         IN NUMBER,
                ent_rtg_seq_id          IN NUMBER,
                ent_inv_item_id         IN NUMBER,
                ent_alt_designator      IN VARCHAR2,
                ent_comp_seq_id         IN NUMBER,
                ent_op_seq_id           IN NUMBER,
                user_id                 IN NUMBER
                   ) RETURN NUMBER;

/* This function returns an error message and an error code which is
   used by the Open Interface program to flag errors.  This function is
   called by the Open Inteface program only */

FUNCTION DELETE_MANAGER_OI(
                new_group_seq_id        IN NUMBER,
                name                    IN VARCHAR2,
                group_desc              IN VARCHAR2,
                org_id                  IN NUMBER,
                bom_or_eng              IN NUMBER,
                del_type                IN NUMBER,
                ent_bill_seq_id         IN NUMBER,
                ent_rtg_seq_id          IN NUMBER,
                ent_inv_item_id         IN NUMBER,
                ent_alt_designator      IN VARCHAR2,
                ent_comp_seq_id         IN NUMBER,
                ent_op_seq_id           IN NUMBER,
                user_id                 IN NUMBER,
		err_text	       IN OUT NOCOPY /* file.sql.39 change */ VARCHAR2
                   ) RETURN NUMBER;
/*
The %type declaration shown before is preffered but causes problems while the library
that calls this package compiles ) Once we support this functionality, we should
change this back

FUNCTION DELETE_MANAGER(
                new_group_seq_id        IN BOM_DELETE_GROUPS.DELETE_GROUP_SEQUENCE_ID%TYPE,
                name                    IN BOM_DELETE_GROUPS.DELETE_GROUP_NAME%TYPE,
                group_desc              IN BOM_DELETE_GROUPS.DESCRIPTION%TYPE,
                org_id                  IN BOM_DELETE_GROUPS.ORGANIZATION_ID%TYPE,
                bom_or_eng              IN BOM_DELETE_GROUPS.ENGINEERING_FLAG%TYPE,
                del_type                IN BOM_DELETE_GROUPS.DELETE_TYPE%TYPE,
                ent_bill_seq_id         IN BOM_DELETE_ENTITIES.BILL_SEQUENCE_ID%TYPE,
                ent_rtg_seq_id          IN BOM_DELETE_ENTITIES.ROUTING_SEQUENCE_ID%TYPE,
                ent_inv_item_id         IN BOM_DELETE_ENTITIES.INVENTORY_ITEM_ID%TYPE,
                ent_alt_designator      IN BOM_DELETE_ENTITIES.ALTERNATE_DESIGNATOR%TYPE,
                ent_comp_seq_id         IN BOM_DELETE_SUB_ENTITIES.COMPONENT_SEQUENCE_ID%TYPE,
                ent_op_seq_id           IN BOM_DELETE_SUB_ENTITIES.OPERATION_SEQUENCE_ID%TYPE,
                user_id                 IN BOM_DELETE_GROUPS.LAST_UPDATED_BY%TYPE
                   ) RETURN NUMBER;
*/
END MODAL_DELETE;

 

/
