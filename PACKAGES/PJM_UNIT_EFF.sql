--------------------------------------------------------
--  DDL for Package PJM_UNIT_EFF
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PJM_UNIT_EFF" AUTHID CURRENT_USER AS
/* $Header: PJMUEFFS.pls 120.0.12010000.1 2008/07/30 04:24:46 appldev ship $ */
--
--  Name          : Enabled
--  Pre-reqs      : None
--  Function      : This function returns a Y/N indicator whether
--                  Model/Unit effectivity has been enabled or not
--
--
--  Parameters    :
--  IN            : None
--
--  Returns       : Y/N
--
FUNCTION Enabled
  RETURN VARCHAR2;


--
--  Name          : Allow_Cross_UnitNum_Issues
--  Pre-reqs      : None
--  Function      : This function returns a Y/N indicator whether
--                  Cross-Unit Number WIP Issues are allowed
--
--
--  Parameters    :
--  IN            : X_organization_id               NUMBER
--
--  Returns       : Y/N
--
FUNCTION Allow_Cross_UnitNum_Issues
( X_organization_id                IN     NUMBER DEFAULT NULL
) RETURN VARCHAR2;
PRAGMA RESTRICT_REFERENCES (Allow_Cross_UnitNum_Issues, WNDS, WNPS);


--
--  Name          : Unit_Effective_Item
--  Pre-reqs      : None
--  Function      : This function checks the effectivity control for
--                  the item
--
--
--  Parameters    :
--  IN            : X_item_id                       NUMBER
--                  X_organization_id               NUMBER
--
--  OUT           : None
--
--  Returns       : Y/N
--
FUNCTION Unit_Effective_Item
( X_item_id                        IN     NUMBER
, X_organization_id                IN     NUMBER
) RETURN VARCHAR2;


--
--  Name          : Set_Unit_Number
--  Pre-reqs      : None
--  Function      : This procedure sets the global variable
--                  Current_Unit_Number
--
--
--  Parameters    :
--  IN            : X_Unit_Number                   NUMBER
--
--  Returns       : None
--
PROCEDURE Set_Unit_Number
( X_Unit_Number                    IN     VARCHAR2
);


--
--  Name          : Current_Unit_Number
--  Pre-reqs      : None
--  Function      : This procedure gets the value in global variable
--                  G_Unit_Number
--
--
--  Parameters    :
--  IN            : None
--
--  Returns       : VARCHAR2
--
FUNCTION Current_Unit_Number
  RETURN VARCHAR2;
PRAGMA RESTRICT_REFERENCES (Current_Unit_Number, WNDS, WNPS);


--
--  Name          : Prev_Unit_Number
--  Pre-reqs      : None
--  Function      : This function returns the previous unit number in
--                  ascending order for the same end item
--
--
--  Parameters    :
--  IN            : X_Unit_Number                   NUMBER
--
--  Returns       : VARCHAR2
--
FUNCTION Prev_Unit_Number
( X_Unit_Number                    IN     VARCHAR2
) RETURN VARCHAR2;
PRAGMA RESTRICT_REFERENCES (Prev_Unit_Number, WNDS, WNPS);


--
--  Name          : Next_Unit_Number
--  Pre-reqs      : None
--  Function      : This function returns the next unit number in
--                  ascending order for the same end item
--
--
--  Parameters    :
--  IN            : X_Unit_Number                   NUMBER
--
--  Returns       : VARCHAR2
--
FUNCTION Next_Unit_Number
( X_Unit_Number                    IN     VARCHAR2
) RETURN VARCHAR2;
PRAGMA RESTRICT_REFERENCES (Next_Unit_Number, WNDS, WNPS);


--
--  Name          : WIP_Unit_Number
--  Pre-reqs      : None
--  Function      : This function returns the unit number on a discrete
--                  job or flow schedule
--
--
--  Parameters    :
--  IN            : X_wip_entity_id                 NUMBER
--                  X_organization_id               NUMBER
--
--  OUT           : None
--
--  Returns       : VARCHAR2
--
FUNCTION WIP_Unit_Number
( X_wip_entity_id                  IN     NUMBER
, X_organization_id                IN     NUMBER
) RETURN VARCHAR2;

FUNCTION WIP_Unit_Number_Cached
( X_wip_entity_id                  IN     NUMBER
, X_organization_id                IN     NUMBER
) RETURN VARCHAR2;


--
--  Name          : RCV_Unit_Number
--  Pre-reqs      : None
--  Function      : This function returns the unit number on a PO
--                  distribution or Internal Req distribution based on the
--                  receiving transaction
--
--
--  Parameters    :
--  IN            : X_rcv_transaction_id            NUMBER
--
--  OUT           : None
--
--  Returns       : VARCHAR2
--
FUNCTION RCV_Unit_Number
( X_rcv_transaction_id             IN     NUMBER
) RETURN VARCHAR2;


--
--  Name          : OE_Line_Unit_Number
--  Pre-reqs      : None
--  Function      : This function returns the unit number on a sales order
--                  line
--
--
--  Parameters    :
--  IN            : X_so_line_id                    NUMBER
--
--  OUT           : None
--
--  Returns       : VARCHAR2
--
FUNCTION OE_Line_Unit_Number
( X_so_line_id                     IN     NUMBER
) RETURN VARCHAR2;

FUNCTION OE_Line_Unit_Number_Cached
( X_so_line_id                     IN     NUMBER
) RETURN VARCHAR2;


--
--  Name          : RMA_Rcpt_Unit_Number
--  Pre-reqs      : None
--  Function      : This function returns the unit number on a RMA
--                  order line based on the receiving transaction
--
--
--  Parameters    :
--  IN            : X_rcv_transaction_id            NUMBER
--
--  OUT           : None
--
--  Returns       : VARCHAR2
--
FUNCTION RMA_Rcpt_Unit_Number
( X_rcv_transaction_id             IN     NUMBER
) RETURN VARCHAR2;


--
--  Name          : Validate_Serial
--  Pre-reqs      : None
--  Function      : This function validates the transaction serial numbers
--                  against the unit number on the transaction entity
--                  (e.g. WIP job)
--
--
--  Parameters    :
--  IN            : X_trx_source_type_id            NUMBER
--                  X_trx_action_id                 NUMBER
--                  X_item_id                       NUMBER
--                  X_organization_id               NUMBER
--                  X_serial_number                 VARCHAR2
--                  X_unit_number                   VARCHAR2
--
--  OUT           : X_error_code                    VARCHAR2
--
--  Returns       : Boolean
--
FUNCTION Validate_Serial
( X_trx_source_type_id             IN            NUMBER
, X_trx_action_id                  IN            NUMBER
, X_item_id                        IN            NUMBER
, X_organization_id                IN            NUMBER
, X_serial_number                  IN            VARCHAR2
, X_unit_number                    IN            VARCHAR2
, X_error_code                     OUT NOCOPY    VARCHAR2
) RETURN BOOLEAN;


--
--  Name          : Serial_UnitNum_Link
--  Pre-reqs      : None
--  Function      : This function links the transaction serial numbers
--                  to the unit number on the transaction entity
--                  (e.g. WIP job)
--
--
--  Parameters    :
--  IN            : X_transaction_id                NUMBER
--
--  OUT           : X_error_code                    VARCHAR2
--
--  Returns       : Boolean
--
FUNCTION Serial_UnitNum_Link
( X_transaction_id                 IN            NUMBER
, X_error_code                     OUT NOCOPY    VARCHAR2
) RETURN BOOLEAN;


--
--  Name          : Unit_Serial_History
--  Pre-reqs      : None
--  Function      : This function creates audit trail information for
--                  unit number changes to serial numbers
--
--
--  Parameters    :
--  IN            : X_serial_number                 VARCHAR2
--                  X_item_id                       NUMBER
--                  X_organization_id               NUMBER
--                  X_old_unit_number               VARCHAR2
--                  X_new_unit_number               VARCHAR2
--                  X_start_num                     NUMBER
--                  X_counts                        NUMBER
--
--  OUT           : X_error_code                    VARCHAR2
--
--  Returns       : Boolean
--
FUNCTION Unit_Serial_History
( X_serial_number                  IN            VARCHAR2
, X_item_id                        IN            NUMBER
, X_organization_id                IN            NUMBER
, X_old_unit_number                IN            VARCHAR2
, X_new_unit_number                IN            VARCHAR2
, X_error_code                     OUT NOCOPY    VARCHAR2
) return BOOLEAN;


--
--  Name          : OE_Attribute
--  Pre-reqs      : None
--  Function      : This function returns the attribute column in the
--                  SO_LINES descriptive flexfield that stores the unit
--                  number value.  The column name is captured in the
--                  profile PJM_UEFF_OE_ATTRIBUTE.
--
--
--  Parameters    :
--  IN            : None
--
--  Returns       : Boolean
--
FUNCTION OE_Attribute
  RETURN VARCHAR2;
PRAGMA RESTRICT_REFERENCES (OE_Attribute, WNDS, WNPS);


END;

/
