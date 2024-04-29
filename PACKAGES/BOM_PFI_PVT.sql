--------------------------------------------------------
--  DDL for Package BOM_PFI_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."BOM_PFI_PVT" AUTHID CURRENT_USER AS
/* $Header: BOMVPFIS.pls 120.1 2005/06/21 05:30:17 appldev ship $ */

/****************************************************************************/
--        ---------------  Global constants  -----------------
--        ----------------------------------------------------

-- Product Family Category Set ID number
--
G_PF_Category_Set_ID	CONSTANT  NUMBER   :=  3	;

-- Item Categories key flexfield Product Family structure number
--
G_PF_Structure_ID	CONSTANT  NUMBER   :=  2	;

-- System Items key flexfield structure number
--
G_MSTK_Structure_ID	CONSTANT  NUMBER   :=  101	;

-- PF structure segments status values
--
G_PF_Segs_Status_OK		CONSTANT  NUMBER   :=  2 ;
G_PF_Segs_Status_Mismatch	CONSTANT  NUMBER   :=  1 ;
G_PF_Segs_Status_Undefined	CONSTANT  NUMBER   :=  0 ;

/****************************************************************************/

TYPE Create_Category_Rec_Type IS RECORD
(	item_id		NUMBER	,
	org_id		NUMBER
);

TYPE Create_Category_Tbl_Type IS TABLE OF Create_Category_Rec_Type
				 INDEX BY BINARY_INTEGER;

TYPE Delete_Category_Rec_Type IS RECORD
(	item_id		NUMBER	,
	org_id		NUMBER
);

TYPE Delete_Category_Tbl_Type IS TABLE OF Delete_Category_Rec_Type
				 INDEX BY BINARY_INTEGER;

TYPE Category_Assign_Rec_Type IS RECORD
(	item_id		NUMBER	,
	org_id		NUMBER	,
	pf_item_id	NUMBER
);

TYPE Category_Assign_Tbl_Type IS TABLE OF Category_Assign_Rec_Type
				 INDEX BY BINARY_INTEGER;


G_Create_Cat_Tbl	Create_Category_Tbl_Type ;
G_Cat_Create_Num	BINARY_INTEGER  :=  0	 ;

G_Delete_Cat_Tbl	Delete_Category_Tbl_Type ;
G_Cat_Num		BINARY_INTEGER  :=  0	 ;

G_Cat_Assign_Tbl	Category_Assign_Tbl_Type ;
G_Assign_Num		BINARY_INTEGER  :=  0	 ;

-- PF structure segments status
PF_Segs_Status		NUMBER  :=  2 ;

/****************************************************************************/

PROCEDURE Store_Cat_Create
( 	p_return_sts		IN OUT NOCOPY NUMBER			,
	p_return_err		IN OUT NOCOPY VARCHAR2		,
	p_item_id		IN	NUMBER			,
	p_org_id		IN	NUMBER			,
	p_Cat_Create_Num	IN OUT	NOCOPY BINARY_INTEGER		,
	p_Create_Cat_Tbl	IN OUT	NOCOPY Create_Category_Tbl_Type
);

/****************************************************************************/

PROCEDURE Create_PF_Category
( 	p_return_sts		IN OUT NOCOPY NUMBER			,
	p_return_err		IN OUT NOCOPY VARCHAR2		,
	p_Cat_Create_Num	IN OUT NOCOPY	BINARY_INTEGER		,
	p_Create_Cat_Tbl	IN OUT	NOCOPY Create_Category_Tbl_Type
);

/****************************************************************************/

PROCEDURE Store_Category
( 	p_return_sts		IN OUT NOCOPY NUMBER			,
	p_return_err		IN OUT NOCOPY VARCHAR2		,
	p_item_id		IN	NUMBER			,
	p_org_id		IN	NUMBER			,
	p_Cat_Num		IN OUT	NOCOPY BINARY_INTEGER		,
	p_Delete_Cat_Tbl	IN OUT	NOCOPY Delete_Category_Tbl_Type
);

/****************************************************************************/

PROCEDURE Delete_PF_Category
( 	p_return_sts		IN OUT NOCOPY NUMBER			,
	p_return_err		IN OUT NOCOPY VARCHAR2		,
	p_Cat_Num		IN OUT	NOCOPY BINARY_INTEGER		,
	p_Delete_Cat_Tbl	IN OUT	NOCOPY Delete_Category_Tbl_Type
);

/****************************************************************************/

PROCEDURE Store_Cat_Assign
( 	p_return_sts		IN OUT NOCOPY NUMBER				,
	p_return_err		IN OUT NOCOPY VARCHAR2			,
	p_item_id		IN	NUMBER				,
	p_org_id		IN	NUMBER				,
	p_pf_item_id		IN	NUMBER				,
	p_Assign_Num		IN OUT NOCOPY	BINARY_INTEGER			,
	p_Cat_Assign_Tbl	IN OUT NOCOPY	Category_Assign_Tbl_Type
);

/****************************************************************************/

PROCEDURE Assign_To_Category
( 	p_return_sts		IN OUT NOCOPY NUMBER				,
	p_return_err		IN OUT NOCOPY VARCHAR2			,
	p_Assign_Num		IN OUT NOCOPY	BINARY_INTEGER			,
 	p_Cat_Assign_Tbl	IN OUT NOCOPY	Category_Assign_Tbl_Type
);

/****************************************************************************/

PROCEDURE Remove_From_Category
( 	p_return_sts		IN OUT NOCOPY NUMBER		,
	p_return_err		IN OUT NOCOPY VARCHAR2	,
	p_item_id		IN	NUMBER		,
	p_org_id		IN	NUMBER
);

/****************************************************************************/

PROCEDURE Get_Category_ID
( 	p_return_sts		IN OUT NOCOPY NUMBER		,
	p_return_err		IN OUT NOCOPY VARCHAR2	,
	p_item_id		IN	NUMBER		,
	p_org_id		IN	NUMBER		,
	p_concat_segments	IN OUT NOCOPY VARCHAR2	,
	p_category_id		IN OUT NOCOPY NUMBER
);

/****************************************************************************/

PROCEDURE Get_Master_Org_ID
( 	p_return_sts		IN OUT NOCOPY NUMBER		,
	p_return_err		IN OUT NOCOPY VARCHAR2	,
	p_org_id		IN	NUMBER		,
	p_master_org_id		IN OUT NOCOPY NUMBER
);

/****************************************************************************/

FUNCTION Org_Is_Master
(	p_org_id	IN	NUMBER
)
RETURN	BOOLEAN;

/****************************************************************************/

PROCEDURE Check_PF_Segs;

/****************************************************************************/

FUNCTION PF_Segs_Undefined
RETURN	BOOLEAN;

/****************************************************************************/

END BOM_PFI_PVT;

 

/
