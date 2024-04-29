--------------------------------------------------------
--  DDL for Package GMF_API_WRP
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."GMF_API_WRP" AUTHID CURRENT_USER AS
/*  $Header: GMFPWRPS.pls 120.3.12000000.1 2007/01/17 16:53:10 appldev ship $  */
PROCEDURE Create_Alloc_Def
( p_dir          IN VARCHAR2
, p_input_file   IN VARCHAR2
, p_output_file  IN VARCHAR2
, p_delimiter    IN VARCHAR2  DEFAULT ','
);

FUNCTION Create_Alloc_Def
( p_dir          IN VARCHAR2
, p_input_file   IN VARCHAR2
, p_output_file  IN VARCHAR2
, p_delimiter    IN VARCHAR2  DEFAULT ','
)
RETURN VARCHAR2;

PROCEDURE Update_Alloc_Def
( p_dir          IN VARCHAR2
, p_input_file   IN VARCHAR2
, p_output_file  IN VARCHAR2
, p_delimiter    IN VARCHAR2
);

FUNCTION Update_Alloc_Def
( p_dir          IN VARCHAR2
, p_input_file   IN VARCHAR2
, p_output_file  IN VARCHAR2
, p_delimiter    IN VARCHAR2
)
RETURN VARCHAR2;

PROCEDURE Delete_Alloc_def
( p_dir          IN VARCHAR2
, p_input_file   IN VARCHAR2
, p_output_file  IN VARCHAR2
, p_delimiter    IN VARCHAR2
) ;

FUNCTION Delete_Alloc_def
( p_dir          IN VARCHAR2
, p_input_file   IN VARCHAR2
, p_output_file  IN VARCHAR2
, p_delimiter    IN VARCHAR2
)
RETURN VARCHAR2 ;

PROCEDURE Create_Resource_Cost
( p_dir          IN VARCHAR2
, p_input_file   IN VARCHAR2
, p_output_file  IN VARCHAR2
, p_delimiter    IN VARCHAR2  DEFAULT ','
);

FUNCTION Create_Resource_Cost
( p_dir          IN VARCHAR2
, p_input_file   IN VARCHAR2
, p_output_file  IN VARCHAR2
, p_delimiter    IN VARCHAR2  DEFAULT ','
)
RETURN VARCHAR2;

PROCEDURE Update_Resource_Cost
( p_dir          IN VARCHAR2
, p_input_file   IN VARCHAR2
, p_output_file  IN VARCHAR2
, p_delimiter    IN VARCHAR2
);

FUNCTION Update_Resource_Cost
( p_dir          IN VARCHAR2
, p_input_file   IN VARCHAR2
, p_output_file  IN VARCHAR2
, p_delimiter    IN VARCHAR2
)
RETURN VARCHAR2;

PROCEDURE Delete_Resource_Cost
( p_dir          IN VARCHAR2
, p_input_file   IN VARCHAR2
, p_output_file  IN VARCHAR2
, p_delimiter    IN VARCHAR2
) ;

FUNCTION Delete_Resource_Cost
( p_dir          IN VARCHAR2
, p_input_file   IN VARCHAR2
, p_output_file  IN VARCHAR2
, p_delimiter    IN VARCHAR2
)
RETURN VARCHAR2 ;

PROCEDURE Get_Resource_Cost
( p_dir          IN VARCHAR2
, p_input_file   IN VARCHAR2
, p_output_file  IN VARCHAR2
, p_delimiter    IN VARCHAR2
) ;

FUNCTION Get_Resource_Cost
( p_dir          IN VARCHAR2
, p_input_file   IN VARCHAR2
, p_output_file  IN VARCHAR2
, p_delimiter    IN VARCHAR2
)
RETURN VARCHAR2 ;

PROCEDURE Create_Item_Cost
( p_dir          IN VARCHAR2
, p_input_file   IN VARCHAR2
, p_output_file  IN VARCHAR2
, p_delimiter    IN VARCHAR2  DEFAULT ','
);

FUNCTION Create_Item_Cost
( p_dir          IN VARCHAR2
, p_input_file   IN VARCHAR2
, p_output_file  IN VARCHAR2
, p_delimiter    IN VARCHAR2  DEFAULT ','
)
RETURN VARCHAR2;

PROCEDURE Update_Item_Cost
( p_dir          IN VARCHAR2
, p_input_file   IN VARCHAR2
, p_output_file  IN VARCHAR2
, p_delimiter    IN VARCHAR2
);

FUNCTION Update_Item_Cost
( p_dir          IN VARCHAR2
, p_input_file   IN VARCHAR2
, p_output_file  IN VARCHAR2
, p_delimiter    IN VARCHAR2
)
RETURN VARCHAR2;

PROCEDURE Delete_Item_Cost
( p_dir          IN VARCHAR2
, p_input_file   IN VARCHAR2
, p_output_file  IN VARCHAR2
, p_delimiter    IN VARCHAR2
) ;

FUNCTION Delete_Item_Cost
( p_dir          IN VARCHAR2
, p_input_file   IN VARCHAR2
, p_output_file  IN VARCHAR2
, p_delimiter    IN VARCHAR2
)
RETURN VARCHAR2 ;

PROCEDURE Get_Item_Cost
( p_dir          IN VARCHAR2
, p_input_file   IN VARCHAR2
, p_output_file  IN VARCHAR2
, p_delimiter    IN VARCHAR2
) ;

FUNCTION Get_Item_Cost
( p_dir          IN VARCHAR2
, p_input_file   IN VARCHAR2
, p_output_file  IN VARCHAR2
, p_delimiter    IN VARCHAR2
)
RETURN VARCHAR2 ;

PROCEDURE Process_ActualCost_Adjustment
( p_dir          IN VARCHAR2
, p_input_file   IN VARCHAR2
, p_output_file  IN VARCHAR2
, p_delimiter    IN VARCHAR2
, p_operation    IN VARCHAR2
);

FUNCTION Process_ActualCost_Adjustment
( p_dir          IN VARCHAR2
, p_input_file   IN VARCHAR2
, p_output_file  IN VARCHAR2
, p_delimiter    IN VARCHAR2
, p_operation    IN VARCHAR2
)
RETURN VARCHAR2;

PROCEDURE Call_ActualCost_API
(
  p_adjustment_rec      IN  OUT NOCOPY  GMF_ACTUAL_COST_ADJUSTMENT_PUB.ADJUSTMENT_REC_TYPE
, p_operation           IN              VARCHAR2
, x_status              OUT     NOCOPY  VARCHAR2
, x_count               OUT     NOCOPY  NUMBER
, x_data                OUT     NOCOPY  VARCHAR2
);

FUNCTION Get_ActualCost_Adjustment
( p_dir          IN VARCHAR2
, p_input_file   IN VARCHAR2
, p_output_file  IN VARCHAR2
, p_delimiter    IN VARCHAR2
)
RETURN VARCHAR2;

PROCEDURE Process_Burden_details
( p_dir          IN VARCHAR2
, p_input_file   IN VARCHAR2
, p_output_file  IN VARCHAR2
, p_delimiter    IN VARCHAR2
, p_operation    IN VARCHAR2
) ;

FUNCTION Process_Burden_details
( p_dir          IN VARCHAR2
, p_input_file   IN VARCHAR2
, p_output_file  IN VARCHAR2
, p_delimiter    IN VARCHAR2
, p_operation    IN VARCHAR2
)
RETURN VARCHAR2 ;

PROCEDURE Call_Burden_API
(
  p_burden_header    IN  GMF_BurdenDetails_PUB.Burden_Header_Rec_Type
, p_burden_detail    IN  GMF_BurdenDetails_PUB.Burden_Dtl_Tbl_Type
, p_operation        IN  VARCHAR2
, x_burdenline_ids   OUT NOCOPY GMF_BurdenDetails_PUB.Burdenline_Ids_Tbl_Type
, x_status           OUT NOCOPY VARCHAR2
, x_count            OUT NOCOPY NUMBER
, x_data             OUT NOCOPY VARCHAR2
) ;

PROCEDURE Get_Burden_details
( p_dir          IN VARCHAR2
, p_input_file   IN VARCHAR2
, p_output_file  IN VARCHAR2
, p_delimiter    IN VARCHAR2
) ;

FUNCTION Get_Burden_details
( p_dir          IN VARCHAR2
, p_input_file   IN VARCHAR2
, p_output_file  IN VARCHAR2
, p_delimiter    IN VARCHAR2
)
RETURN VARCHAR2 ;

PROCEDURE Process_LotCost_Adjustment
( p_dir          IN VARCHAR2
, p_input_file   IN VARCHAR2
, p_output_file  IN VARCHAR2
, p_delimiter    IN VARCHAR2
, p_operation    IN VARCHAR2
);

FUNCTION Process_LotCost_Adjustment
( p_dir          IN VARCHAR2
, p_input_file   IN VARCHAR2
, p_output_file  IN VARCHAR2
, p_delimiter    IN VARCHAR2
, p_operation    IN VARCHAR2
)
RETURN VARCHAR2;

PROCEDURE Call_LotCost_API
(
  p_header_rec            IN OUT        NOCOPY  GMF_LOTCOSTADJUSTMENT_PUB.Lc_Adjustment_Header_Rec_Type
, p_dtl_tbl               IN OUT        NOCOPY  GMF_LOTCOSTADJUSTMENT_PUB.Lc_Adjustment_Dtls_Tbl_Type
, p_operation             IN                    VARCHAR2
, x_status                OUT           NOCOPY  VARCHAR2
, x_count                 OUT           NOCOPY  NUMBER
, x_data                  OUT           NOCOPY  VARCHAR2
);

FUNCTION Get_LotCost_Adjustment
( p_dir          IN VARCHAR2
, p_input_file   IN VARCHAR2
, p_output_file  IN VARCHAR2
, p_delimiter    IN VARCHAR2
)
RETURN VARCHAR2;

FUNCTION Get_Field
( p_line         IN VARCHAR2
, p_delimiter    IN VARCHAR2
, p_field_no     IN NUMBER
)
RETURN VARCHAR2;

FUNCTION Get_Substring
( p_substring    IN VARCHAR2
)
RETURN VARCHAR2;

END GMF_API_WRP;

 

/
