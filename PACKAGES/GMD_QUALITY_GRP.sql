--------------------------------------------------------
--  DDL for Package GMD_QUALITY_GRP
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."GMD_QUALITY_GRP" AUTHID CURRENT_USER AS
/* $Header: GMDGQCMS.pls 120.1 2005/06/21 04:08:38 appldev ship $ */

-- Input Record Structure
TYPE inv_inp_rec_type IS RECORD
( organization_id       NUMBER
, inventory_item_id     NUMBER
, grade_code            VARCHAR2(150)
, parent_lot_number     VARCHAR2(80)
, lot_number            VARCHAR2(80)
, subinventory          VARCHAR2(10)
, locator_id            NUMBER
, test_id               NUMBER
, Plant_id              NUMBER Default NULL);

-- Output Record Structure
TYPE inv_val_out_rec_type IS RECORD
( Entity_Id             NUMBER        -- Could be result_id or spec_id
, Spec_id               NUMBER        -- Specification id
, Entity_Value          VARCHAR2(80)  -- format based on report Precision
, Entity_min_value      VARCHAR2(80)
, Entity_max_value      VARCHAR2(80)
, Level                 NUMBER
, Composite_ind         NUMBER);

-- Output Record Structure for fetch results tests
TYPE inv_rslt_out_rec_type IS RECORD
( Result_Id             NUMBER
, Spec_id               NUMBER
, result_value          VARCHAR2(80)
, Min_Value             VARCHAR2(80)
, Max_Value             VARCHAR2(80)
, Display_Precision     NUMBER
, Level                 NUMBER
, Composite_ind         NUMBER);

-- Output Record Structure for fetch spec tests
TYPE inv_spec_out_rec_type IS RECORD
( Spec_Id               NUMBER
, Target_Value          VARCHAR2(80)
, Min_Value             VARCHAR2(80)
, Max_Value             VARCHAR2(80)
, Display_Precision     NUMBER
, test_id               NUMBER
, Level                 NUMBER(5));

-- Output Record Structure for sampling events
TYPE  sampling_events_rec_type IS RECORD
( sampling_event_id     NUMBER
, sample_id             NUMBER
, event_spec_disp_id    NUMBER
, sample_active_cnt     NUMBER
, spec_id               NUMBER
, organization_id       NUMBER
, inventory_item_id     NUMBER
, parent_lot_number     VARCHAR2(80)
, lot_number            VARCHAR2(80)
, subinventory          VARCHAR2(10)
, locator_id            NUMBER
);

-- Table Structure for sampling events
TYPE sampling_events_tbl_type IS TABLE OF sampling_events_rec_type INDEX BY BINARY_INTEGER;


-- Start of comments
--      API name    : get_inv_test_value
--      Type        : Private
--      Function    :
--      Pre-reqs    : None.
--      Parameters  :
--      IN          : P_inv_test_inp_rec    IN      inv_inp_rec_type  (Required)
--
--      OUT         : x_return_status       OUT     VARCHAR2(1)
--                  : x_inv_test_out_rec    OUT     inv_inp_rec_type
--      HISTORY
--      20-Feb-2003  Shyam Sitaraman        Initial Implementation
--
-- End of comments
PROCEDURE get_inv_test_value
( P_inv_test_inp_rec    IN            inv_inp_rec_type
, x_inv_test_out_rec    OUT  NOCOPY   inv_val_out_rec_type
, x_return_status       OUT  NOCOPY   VARCHAR2
);


-- Start of comments
--      API name    : get_inv_result_test_value
--      Type        : Private
--      Function    :
--      Pre-reqs    : None.
--      Parameters  :
--      IN          : P_inv_rslt_inp_rec    IN      inv_inp_rec_type  (Required)
--
--      OUT         : x_return_status       OUT     VARCHAR2(1)
--                  : x_inv_rslt_out_rec    OUT     inv_val_out_rec_type
--      HISTORY
--      20-Feb-2003   Shyam Sitaraman        Initial Implementation
--
-- End of comments
PROCEDURE get_inv_result_test_value
( P_inv_rslt_inp_rec    IN            inv_inp_rec_type
, x_inv_rslt_out_rec    OUT  NOCOPY   inv_rslt_out_rec_type
, x_return_status       OUT  NOCOPY   VARCHAR2
);


-- Start of comments
--      API name    : get_appr_sampling_events
--      Type        : Private
--      Function    :
--      Pre-reqs    : None.
--      Parameters  :
--      IN          : P_inv_rslt_inp_rec    IN      inv_inp_rec_type  (Required)
--
--      OUT         : x_return_status       OUT     VARCHAR2(1)
--                  : x_sampling_events_tbl OUT     sampling_events_tbl_type
--
--      Version     : Initial version       1.0
--
--
--      Notes       : Retrieves 1 or more approved sampling events and specication
--                    for an item, based on the organization, lot, warehouse and
--                    location information.
--
--      HISTORY
--      20-Feb-2003   Shyam Sitaraman        Initial Implementation
--
-- End of comments
PROCEDURE get_appr_sampling_events
( p_inv_rslt_inp_rec    IN            inv_inp_rec_type
, x_sampling_events_tbl OUT  NOCOPY   sampling_events_tbl_type
, x_return_status       OUT  NOCOPY   VARCHAR2
);



-- Start of comments
--      API name    : get_inv_spec_test_value
--      Type        : Private
--      Function    :
--      Pre-reqs    : None.
--      Parameters  :
--      IN          : p_inv_spec_inp_rec    IN      inv_inp_rec_type  (Required)
--
--      OUT         : x_return_status       OUT     VARCHAR2(1)
--                  : x_inv_spec_out_rec    OUT     inv_spec_out_rec_type
--      HISTORY
--      20-Feb-2003   Shyam Sitaraman        Initial Implementation
--
-- End of comments
PROCEDURE get_inv_spec_test_value
( p_inv_spec_inp_rec    IN            inv_inp_rec_type
, x_inv_spec_out_rec    OUT  NOCOPY   inv_spec_out_rec_type
, x_return_status       OUT  NOCOPY   VARCHAR2
);



-- Start of comments
--      API name    : get_level
--      Type        : Private
--      Function    :
--      Pre-reqs    : None.
--      Parameters  :
--      IN          : p_inv_spec_inp_rec    IN      inv_inp_rec_type  (Required)
--                  : p_called_from         IN      VARCHAR2  Default 'RESULT'
--
--      OUT         : x_return_status       OUT     VARCHAR2(1)
--                  : x_level               OUT     NUMBER
--
--      Version     : Initial version       1.0
--
--
--      Notes       : Retrieves spec tests or result test levels
--
--      HISTORY
--      20-Feb-2003   Shyam Sitaraman        Initial Implementation
--
-- End of comments
PROCEDURE get_level
( p_inv_inp_rec         IN            inv_inp_rec_type
, p_called_from         IN            VARCHAR2
, x_level               OUT  NOCOPY   NUMBER
, x_return_status       OUT  NOCOPY   VARCHAR2
);


END;

 

/
