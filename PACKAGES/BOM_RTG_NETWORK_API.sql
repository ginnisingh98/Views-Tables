--------------------------------------------------------
--  DDL for Package BOM_RTG_NETWORK_API
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."BOM_RTG_NETWORK_API" AUTHID CURRENT_USER AS
/* $Header: BOMRNWKS.pls 120.2.12010000.2 2008/11/21 13:58:45 svagrawa ship $ */

TYPE Op_Record_Type	IS RECORD
	(	operation_seq_num		NUMBER,
		operation_sequence_id	NUMBER);

TYPE Op_Tbl_Type IS TABLE OF Op_Record_Type
	INDEX BY BINARY_INTEGER;

/*-------------------------------------------------------------------------
	Name
		get_all_prior_line_ops

	Description
		This PROCEDURE gets all the prior line opeartions from the current
		line operation including line operations on primary and alternate
		paths. Line Operations on Rework path and standalone line
		operations are ignored.

	Returns
		A pl/sql table of Op_Tbl_Type type as IN OUT NOCOPY parameter that includes
		a list of line operations.
+--------------------------------------------------------------------------*/
PROCEDURE get_all_prior_line_ops (
	p_rtg_sequence_id   IN  NUMBER,
	p_assy_item_id 		IN	NUMBER,
	p_org_id			IN	NUMBER,
	p_alt_rtg_desig		IN	VARCHAR2,
	p_curr_line_op		IN 	NUMBER,
	x_Op_Tbl			IN OUT NOCOPY Op_Tbl_Type );

/*-------------------------------------------------------------------------
    Name
        get_primary_prior_line_ops

    Description
        This PROCEDURE gets only the PRIMARY prior line opeartions from the
		current line operation. This includes line operations on the
		feeder lines.
		If the current line op is on the alternate path then this
		API gets all the previous line ops on the alternate path till
		it hits the primary path and then onwards gets all the
		line ops in the primary path only.
		The procedure looks at p_rtg_sequence_id parameter. If
		p_rtg_sequence_id is null then only it looks at
		p_assy_item_id,p_org_id,p_alt_rtg_desig to derive
		routing_sequence_id

    Returns
        A pl/sql table of Op_Tbl_Type type as IN OUT NOCOPY parameter that includes
        a list of line operations.
+--------------------------------------------------------------------------*/
PROCEDURE get_primary_prior_line_ops (
	p_rtg_sequence_id   IN  NUMBER,
    p_assy_item_id      IN  NUMBER,
    p_org_id            IN  NUMBER,
    p_alt_rtg_desig     IN  VARCHAR2,
    p_curr_line_op      IN  NUMBER,
    x_Op_Tbl     		 IN OUT NOCOPY  Op_Tbl_Type );

/*-------------------------------------------------------------------------
    Name
        get_all_line_ops

    Description
        This PROCEDURE gets all the line operations on the network for
		the routing. Standalone line operations are ignored.

    Returns
        A pl/sql table of Op_Tbl_Type type as IN OUT NOCOPY parameter that includes
        a list of line operations.
+--------------------------------------------------------------------------*/
PROCEDURE get_all_line_ops (
	p_rtg_sequence_id   IN  NUMBER,
    p_assy_item_id      IN  NUMBER,
    p_org_id            IN  NUMBER,
    p_alt_rtg_desig     IN  VARCHAR2 DEFAULT NULL,
    x_Op_Tbl     		 IN OUT NOCOPY  Op_Tbl_Type );

/*-------------------------------------------------------------------------
    Name
        get_all_primary_line_ops

    Description
        This PROCEDURE gets all the line operations that are on the
		primary path on the network for the routing. Line operations on
		the feeder lines are included. Standalone line operations are
		ignored.
		The procedure looks at p_rtg_sequence_id parameter. If
		p_rtg_sequence_id is null then only it looks at
		p_assy_item_id,p_org_id,p_alt_rtg_desig to derive
		routing_sequence_id

    Returns
        A pl/sql table of Op_Tbl_Type type as IN OUT NOCOPY parameter that includes
        a list of line operations.
+--------------------------------------------------------------------------*/
PROCEDURE get_all_primary_line_ops (
	p_rtg_sequence_id   IN  NUMBER,
    p_assy_item_id      IN  NUMBER,
    p_org_id            IN  NUMBER,
    p_alt_rtg_desig     IN  VARCHAR2,
    x_Op_Tbl     		 IN OUT NOCOPY  Op_Tbl_Type );

/*-------------------------------------------------------------------------
    Name
        get_all_next_line_ops

    Description
        This PROCEDURE gets all the next line opeartions from the current
        line operation including line operations on primary and alternate
        paths. Line Operations on Rework path and standalone line
        operations are ignored.

    Returns
        A pl/sql table of Op_Tbl_Type type as IN OUT NOCOPY parameter that includes
        a list of line operations.
+--------------------------------------------------------------------------*/
PROCEDURE get_all_next_line_ops (
	p_rtg_sequence_id   IN  NUMBER,
    p_assy_item_id      IN  NUMBER,
    p_org_id            IN  NUMBER,
    p_alt_rtg_desig     IN  VARCHAR2,
    p_curr_line_op      IN  NUMBER,
    x_Op_Tbl      		 IN OUT NOCOPY  Op_Tbl_Type );

/*-------------------------------------------------------------------------
    Name
        get_next_line_operation

    Description
        This FUNCTION returns the next line operation for the current
        line operation. Following Rules are used.
		- Get the next line operation on the primary path if primary
	      path exists on the current line operation to the next.
		- Get the next line operation on the alternate path if primary
		  path does not exist.
		- Get the lowest line operation if primary does not exist and
		  multiple alternates exist.

    Returns
        Returns Op_Seq_Num of the next line operation
+--------------------------------------------------------------------------*/
FUNCTION get_next_line_operation (
	p_rtg_sequence_id   IN  NUMBER,
    p_assy_item_id      IN  NUMBER,
    p_org_id            IN  NUMBER,
    p_alt_rtg_desig     IN  VARCHAR2,
    p_curr_line_op      IN  NUMBER ) RETURN NUMBER;

/*-------------------------------------------------------------------------
    Name
        check_last_line_op

    Description
      	This fucntion checks whether current line operation is the last
		operation on the network.

    Returns
        TRUE if the current operation is the last otherwise FALSE
+--------------------------------------------------------------------------*/
FUNCTION check_last_line_op (
	p_rtg_sequence_id   IN  NUMBER,
    p_assy_item_id      IN  NUMBER,
    p_org_id            IN  NUMBER,
    p_alt_rtg_desig     IN  VARCHAR2,
    p_curr_line_op      IN  NUMBER ) RETURN BOOLEAN;

/* Fixed for bug 7582458 - Removed WNPS */
PRAGMA RESTRICT_REFERENCES (get_all_line_ops, WNDS);
PRAGMA RESTRICT_REFERENCES (get_all_next_line_ops, WNDS);

END BOM_RTG_NETWORK_API;

/
