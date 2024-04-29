--------------------------------------------------------
--  DDL for Package GMF_VALIDATIONS_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."GMF_VALIDATIONS_PVT" AUTHID CURRENT_USER AS
/* $Header: GMFVVALS.pls 120.5.12000000.2 2007/05/02 12:04:07 pmarada ship $ */
FUNCTION Validate_Calendar_Code
(
  p_Calendar_Code  IN cm_cldr_hdr.Calendar_Code%TYPE
)
RETURN BOOLEAN;

PROCEDURE Validate_Calendar_Code
(
  p_calendar_code    IN  cm_cldr_hdr.Calendar_Code%TYPE
, x_co_code          OUT NOCOPY cm_cldr_hdr.co_code%TYPE
, x_cost_mthd_code   OUT NOCOPY cm_cldr_hdr.cost_mthd_code%TYPE
) ;

PROCEDURE Validate_Period_Code
(
  p_Calendar_Code  IN  cm_cldr_hdr.Calendar_Code%TYPE
, p_Period_Code    IN  cm_cldr_dtl.Period_Code%TYPE
, x_Period_Status  OUT NOCOPY cm_cldr_dtl.Period_Status%TYPE
) ;

FUNCTION Validate_Cost_Mthd_Code
(
  p_cost_mthd_code  IN ic_item_mst.cost_mthd_code%TYPE
)
RETURN BOOLEAN;

PROCEDURE Validate_cost_mthd_code
(
  p_cost_mthd_code IN  cm_mthd_mst.cost_mthd_code%TYPE
, x_cost_type      OUT NOCOPY cm_mthd_mst.cost_type%TYPE
, x_rmcalc_type    OUT NOCOPY cm_mthd_mst.rmcalc_type%TYPE
, x_prodcalc_type  OUT NOCOPY cm_mthd_mst.prodcalc_type%TYPE
) ;

FUNCTION Validate_Cost_type_Code
(
p_cost_mthd_code  IN cm_mthd_mst.cost_mthd_code%TYPE
)
RETURN NUMBER;

FUNCTION Validate_Cost_type_Code
(
p_cost_mthd_code  IN cm_mthd_mst.cost_mthd_code%TYPE,
p_type            IN VARCHAR2
)
RETURN NUMBER;

FUNCTION Validate_Analysis_Code
(
  p_Cost_Analysis_Code  IN cm_alys_mst.Cost_Analysis_Code%TYPE
)
RETURN BOOLEAN;

FUNCTION Validate_Company_Code
(
  p_Company_Code  IN sy_orgn_mst.Co_Code%TYPE
)
RETURN BOOLEAN;

FUNCTION Validate_Orgn_Code
(
  p_Orgn_Code  IN sy_orgn_mst.Orgn_Code%TYPE
)
RETURN BOOLEAN;

FUNCTION Validate_Whse_Code
(
  p_whse_code  IN ic_whse_mst.whse_code%TYPE
)
RETURN BOOLEAN;

FUNCTION Validate_Item_Id
(
  p_Item_Id  IN ic_item_mst.Item_Id%TYPE
)
RETURN BOOLEAN;

PROCEDURE Validate_Item_Id
(
  p_Item_Id  IN ic_item_mst.Item_Id%TYPE
, x_Item_UM  OUT NOCOPY ic_item_mst.Item_UM%TYPE
);

FUNCTION Validate_Item_No
(
  p_Item_No  IN ic_item_mst.Item_No%TYPE
)
RETURN NUMBER;

PROCEDURE Validate_Item_No
(
  p_Item_No  IN  ic_item_mst.Item_No%TYPE
, x_Item_Id  OUT NOCOPY ic_item_mst.Item_Id%TYPE
, x_Item_UM  OUT NOCOPY ic_item_mst.Item_UM%TYPE
);

FUNCTION Validate_Itemcost_Class
(
  p_itemcost_class  IN ic_item_mst.itemcost_class%TYPE
)
RETURN BOOLEAN;

FUNCTION Validate_Cost_Cmpntcls_Id
(
  p_Cost_Cmpntcls_Id  IN cm_cmpt_mst.Cost_Cmpntcls_Id%TYPE
)
RETURN BOOLEAN;

PROCEDURE Validate_Cost_Cmpntcls_Id
(
  p_Cost_Cmpntcls_Id  IN  cm_cmpt_mst.Cost_Cmpntcls_Id%TYPE
, x_Cost_Cmpntcls_Id  OUT NOCOPY cm_cmpt_mst.Cost_Cmpntcls_Code%TYPE
, x_usage_ind         OUT NOCOPY cm_cmpt_mst.usage_ind%TYPE
);

FUNCTION Validate_Cost_Cmpntcls_Code
(
  p_Cost_Cmpntcls_Code  IN cm_cmpt_mst.Cost_Cmpntcls_Code%TYPE
)
RETURN NUMBER;

PROCEDURE Validate_Cost_Cmpntcls_Code
(
  p_Cost_Cmpntcls_Code  IN  cm_cmpt_mst.Cost_Cmpntcls_Code%TYPE
, x_Cost_Cmpntcls_Id     OUT NOCOPY cm_cmpt_mst.Cost_Cmpntcls_Id%TYPE
, x_Usage_Ind           OUT NOCOPY cm_cmpt_mst.Usage_Ind%TYPE
);

FUNCTION Validate_Gl_Class
(
  p_gl_class        IN ic_gled_cls.icgl_class%TYPE
)
RETURN BOOLEAN;

FUNCTION Validate_Fmeff_Id
(
  p_Fmeff_Id  IN fm_form_eff.Fmeff_Id%TYPE
)
RETURN BOOLEAN;

FUNCTION Validate_Resources
(
  p_Resources  IN cr_rsrc_mst.Resources%TYPE
)
RETURN BOOLEAN;

PROCEDURE Validate_Resources
(
  p_Resources        IN  cr_rsrc_mst.Resources%TYPE
, x_resource_um      OUT NOCOPY cr_rsrc_mst.std_usage_um%TYPE
, x_resource_um_type OUT NOCOPY sy_uoms_mst.um_type%TYPE
);

FUNCTION Validate_Alloc_Id
(
  p_Alloc_Id  IN gl_aloc_mst.Alloc_Id%TYPE
)
RETURN BOOLEAN;

FUNCTION Fetch_Alloc_Id
(
  p_Alloc_Code  IN gl_aloc_mst.Alloc_Code%TYPE
, p_co_code     IN sy_orgn_mst.co_code%TYPE
)
RETURN NUMBER;

PROCEDURE Validate_Basis_account_key
(
  p_Basis_account_key   IN  gl_aloc_bas.Basis_account_key%TYPE
, p_co_code           IN  sy_orgn_mst.co_code%TYPE
, p_basis_description OUT NOCOPY VARCHAR2
, p_return_status     OUT NOCOPY NUMBER
);

FUNCTION Validate_Usage_Um
(
  p_Usage_Um   IN sy_uoms_mst.Um_Code%TYPE
)
RETURN BOOLEAN;

PROCEDURE Validate_Usage_Um
(
  p_Usage_Um   IN sy_uoms_mst.Um_Code%TYPE
, x_Um_Type    OUT NOCOPY sy_uoms_mst.Um_Type%TYPE
);

FUNCTION VALIDATE_LOT_ID
(
p_item_id               IN              ic_item_mst.item_id%TYPE
, p_lot_no              IN              ic_lots_mst.lot_no%TYPE
, p_sublot_no           IN              ic_lots_mst.sublot_no%TYPE
)
RETURN NUMBER;

FUNCTION VALIDATE_LOT_ID
(
p_item_id               IN              ic_item_mst.item_id%TYPE
, p_lot_id              IN              ic_lots_mst.lot_id%TYPE
)
RETURN BOOLEAN;

FUNCTION VALIDATE_LOT_NO
(
p_item_id               IN              ic_item_mst.item_id%TYPE
, p_lot_no              IN              ic_lots_mst.lot_no%TYPE
, p_sublot_no           IN              ic_lots_mst.sublot_no%TYPE
)
RETURN BOOLEAN;

/* ANTHIYAG Added for Release 12.0 Start */
FUNCTION validate_legal_entity_id
(
p_legal_entity_id             IN          xle_entity_profiles.legal_entity_id%TYPE
)
RETURN BOOLEAN;

FUNCTION Validate_Cost_type_id
(
p_cost_type_id                IN          cm_mthd_mst.cost_type_id%TYPE
)
RETURN BOOLEAN;

FUNCTION Validate_Cost_type_id
(
p_cost_type_id                IN          cm_mthd_mst.cost_type_id%TYPE,
p_type                        IN          VARCHAR2
)
RETURN BOOLEAN;

/* sschinch commented. This is a duplicate function repeated again
FUNCTION Validate_cost_mthd_code
(
p_cost_mthd_code              IN          cm_mthd_mst.cost_mthd_code%TYPE
)
RETURN NUMBER;
*/

FUNCTION Validate_period_id
(
p_period_id                   IN          gmf_period_statuses.period_id%TYPE
)
RETURN BOOLEAN;

FUNCTION Validate_period_id
(
p_period_id                   IN          gmf_period_statuses.period_id%TYPE,
p_cost_type_id                OUT NOCOPY  gmf_period_statuses.cost_type_id%TYPE
)
RETURN BOOLEAN;

FUNCTION Validate_period_code
(
p_organization_id             IN          mtl_organizations.organization_id%TYPE,
p_calendar_code               IN          cm_cldr_hdr_b.calendar_code%TYPE,
p_period_code                 IN          cm_cldr_dtl.period_code%TYPE,
p_cost_type_id                IN          cm_mthd_mst.cost_type_id%TYPE
)
RETURN NUMBER;

FUNCTION Validate_organization_id
(
p_organization_id             IN          mtl_organizations.organization_id%TYPE
)
RETURN BOOLEAN;

FUNCTION Validate_Organization_code
(
p_organization_code           IN          mtl_parameters.organization_code%TYPE
)
RETURN NUMBER;

FUNCTION Validate_inventory_item_id
(
p_inventory_item_id           IN          mtl_system_items_b.inventory_item_id%TYPE,
p_organization_id             IN          mtl_organizations.organization_id%TYPE
)
RETURN BOOLEAN;

FUNCTION Validate_item_number
(
p_item_number                 IN          mtl_item_flexfields.item_number%TYPE,
p_organization_id             IN          mtl_organizations.organization_id%TYPE
)
RETURN NUMBER;

FUNCTION Validate_Lot_Number
(
p_lot_number                  IN          mtl_lot_numbers.lot_number%TYPE,
p_inventory_item_id           IN          mtl_system_items_b.inventory_item_id%TYPE,
p_organization_id             IN          mtl_organizations.organization_id%TYPE
)
RETURN BOOLEAN;

FUNCTION Validate_Lot_Cost_Mthd_Code
(
  p_cost_mthd_code  IN ic_item_mst.cost_mthd_code%TYPE
)
RETURN BOOLEAN;

FUNCTION Validate_Lot_Cost_Type
(
p_cost_mthd_code              IN          cm_mthd_mst.cost_mthd_code%TYPE
)
RETURN NUMBER;

FUNCTION Validate_Lot_Cost_type_id
(
p_cost_type_id                IN          cm_mthd_mst.cost_type_id%TYPE
)
RETURN BOOLEAN;

FUNCTION Fetch_Alloc_Id
(
  p_Alloc_Code  IN gl_aloc_mst.Alloc_Code%TYPE
, p_le_id     IN xle_entity_profiles.legal_entity_id%TYPE
)
RETURN NUMBER;

FUNCTION Validate_Basis_account_key
(
  p_Basis_account_key   IN  gl_aloc_bas.Basis_account_key%TYPE
, p_le_id     IN xle_entity_profiles.legal_entity_id%TYPE
)
RETURN NUMBER;

FUNCTION Validate_ACCOUNT_ID
(
  p_Basis_account_id  IN  gl_aloc_bas.Basis_account_id%TYPE
, p_le_id     IN xle_entity_profiles.legal_entity_id%TYPE
)
RETURN BOOLEAN;

FUNCTION Validate_same_class_Uom
(
  P_uom_code IN mtl_units_of_measure.uom_code%TYPE,
  p_inventory_item_id IN mtl_system_items_b.inventory_item_id%TYPE,
  p_organization_id IN mtl_system_items_b.organization_id%TYPE
) RETURN BOOLEAN;

/* ANTHIYAG Added for Release 12.0 End */

FUNCTION Validate_Usage_Uom
(
  P_usgae_uom IN mtl_units_of_measure.uom_code%TYPE
) RETURN BOOLEAN;

PROCEDURE validate_usage_uom (
   p_usage_uom IN   mtl_units_of_measure.uom_code%TYPE,
   p_usage_uom_class OUT NOCOPY mtl_units_of_measure.uom_class%TYPE
 );

PROCEDURE Validate_Resource
(
  p_Resources          IN  cr_rsrc_mst.Resources%TYPE
, x_resource_uom       OUT NOCOPY cr_rsrc_mst.std_usage_uom%TYPE
, x_resource_uom_class OUT NOCOPY mtl_units_of_measure.uom_class%TYPE
);

END GMF_validations_PVT;

 

/
