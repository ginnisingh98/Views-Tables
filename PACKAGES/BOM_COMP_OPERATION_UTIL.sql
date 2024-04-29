--------------------------------------------------------
--  DDL for Package BOM_COMP_OPERATION_UTIL
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."BOM_COMP_OPERATION_UTIL" AUTHID CURRENT_USER AS
/* $Header: BOMUCOPS.pls 120.0.12010000.2 2010/02/03 17:16:42 umajumde ship $ */
/****************************************************************************
--
--  Copyright (c) 1996 Oracle Corporation, Redwood Shores, CA, USA
--  All rights reserved.
--
--  FILENAME
--
--      BOMUCOPS.pls
--
--  DESCRIPTION
--
--      Spec of package BOM_Comp_Operation_Util
--
--  NOTES
--
--  HISTORY
--
--  21-AUG-2001	Refai Farook	Initial Creation
--
****************************************************************************/

--  Function Query_Row

PROCEDURE Query_Row
(   p_component_sequence_id         IN  NUMBER
,   p_additional_operation_seq_num     IN  NUMBER
,   x_bom_comp_ops_rec		    IN OUT NOCOPY Bom_Bo_Pub.Bom_Comp_Ops_Rec_Type
,   x_bom_comp_ops_Unexp_Rec	    IN OUT NOCOPY Bom_Bo_Pub.Bom_Comp_Ops_Unexp_Rec_Type
,   x_return_status                 IN OUT NOCOPY VARCHAR2
);

--added for bug 7713832
FUNCTION Common_CompSeqIdCO( p_comp_seq_id NUMBER)
RETURN NUMBER;

PROCEDURE Perform_Writes
(  p_bom_comp_ops_rec          IN  Bom_Bo_Pub.Bom_Comp_Ops_Rec_Type
 , p_bom_comp_ops_unexp_rec    IN  Bom_Bo_Pub.Bom_Comp_Ops_Unexp_Rec_Type
 , x_Mesg_Token_Tbl            IN OUT NOCOPY Error_Handler.Mesg_Token_Tbl_Type
 , x_Return_Status             IN OUT NOCOPY VARCHAR2
);


END BOM_Comp_Operation_Util;

/
