--------------------------------------------------------
--  DDL for Package WMS_RE_COMMON_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."WMS_RE_COMMON_PVT" AUTHID CURRENT_USER AS
/* $Header: WMSVPPCS.pls 120.1 2005/06/07 12:17:49 appldev  $ */
-- File        : WMSVPPCS.pls
-- Content     : WMS_RE_Common_PVT package specification
-- Description : Common private procedures and functions internally used by
--               WMS strategy and rule API's.
--
--               Currently it manages the rule table
--               and the input line table (all plsql tables)
-- Notes       :
-- Modified    : 02/08/99 mzeckzer created

-- API name    : InitInputTable
-- Type        : Private
-- Function    : Creates and initializes internal table of input records to
--               process.
PROCEDURE InitInputTable;
--
-- API name    : InitInputPointer
-- Type        : Private
-- Function    : Initializes next pointer to the first available row in the
--               internal table of input records to process.
PROCEDURE InitInputPointer;
--
-- API name    : InitInputLine
-- Type        : Private
-- Function    : Creates a new line in the internal table of input records to
--               process and initializes all neccessary values.
-- [ Added the following new columns(s) in PROCEDURE InitInputLine
--   to support serial allocation for serial reserved items ]

PROCEDURE InitInputLine
  ( p_pp_transaction_temp_id  IN  NUMBER
   ,p_revision                IN  VARCHAR2
   ,p_lot_number              IN  VARCHAR2
   ,p_lot_expiration_date     IN  DATE
   ,p_from_subinventory_code  IN  VARCHAR2
   ,p_from_locator_id         IN  NUMBER
   ,p_from_cost_group_id      IN  NUMBER
   ,p_to_subinventory_code    IN  VARCHAR2
   ,p_to_locator_id           IN  NUMBER
   ,p_to_cost_group_id        IN  NUMBER
   ,p_transaction_quantity    IN  NUMBER
   ,p_secondary_quantity      IN  NUMBER  DEFAULT NULL
   ,p_grade_code              IN  VARCHAR2  DEFAULT NULL
   ,p_reservation_id          IN  NUMBER
   ,p_serial_number           IN  VARCHAR2 DEFAULT NULL  --- [ Added a new column - p_serial_number ]
   ,p_lpn_id		      IN  NUMBER
   );
--
-- API name    : GetCountInputLines
-- Type        : Private
-- Function    : Returns number of rows in the internal table of input
--               records to process.
FUNCTION GetCountInputLines RETURN INTEGER;
--
-- API name    : GetNextInputLine
-- Type        : Private
-- Function    : Returns all values of the next row in the internal table of
--               input records to process and sets the next pointer to the
--               next available row.
-- [ Added the following new columns(s) in PROCEDURE GetNextInputLine
--   to support serial allocation for serial reserved items ]

PROCEDURE GetNextInputLine
  ( x_pp_transaction_temp_id    OUT  NOCOPY NUMBER
   ,x_revision                  OUT  NOCOPY VARCHAR2
   ,x_lot_number                OUT  NOCOPY VARCHAR2
   ,x_lot_expiration_date       OUT  NOCOPY DATE
   ,x_from_subinventory_code    OUT  NOCOPY VARCHAR2
   ,x_from_locator_id           OUT  NOCOPY NUMBER
   ,x_from_cost_group_id        OUT  NOCOPY NUMBER
   ,x_to_subinventory_code      OUT  NOCOPY VARCHAR2
   ,x_to_locator_id             OUT  NOCOPY NUMBER
   ,x_to_cost_group_id          OUT  NOCOPY NUMBER
   ,x_transaction_quantity      OUT  NOCOPY NUMBER
   ,x_secondary_quantity        OUT  NOCOPY NUMBER
   ,x_grade_code                OUT  NOCOPY VARCHAR2
   ,x_reservation_id            OUT  NOCOPY NUMBER
   ,x_serial_number             OUT  NOCOPY VARCHAR2 --- [ Added a new column - p_serial_number ]
   ,x_lpn_id			OUT  NOCOPY NUMBER
   );
--
-- API name    : UpdateInputLine
-- Type        : Private
-- Function    : Updates the transaction quantity of the current row
--               in the internal table of input records to process
--               according to the provided value.
PROCEDURE UpdateInputLine
     ( p_transaction_quantity IN NUMBER
     , p_secondary_quantity   IN NUMBER  DEFAULT NULL
     );
--
-- API name    : DeleteInputLine
-- Type        : Private
-- Function    : Deletes the current row in the internal table of input
--               records to process.
PROCEDURE DeleteInputLine;
--
-- API name    : InitRulesTable
-- Type        : Private
-- Function    : Creates and initializes internal table of all rules member
--               of the actual wms strategy to execute.
PROCEDURE InitRulesTable;
--
-- API name    : InitRule
-- Type        : Private
-- Function    : Creates a new line in the internal table of strategy members
--               and initializes all neccessary values. Returns number of rows
--               created so far.
PROCEDURE InitRule
  ( p_rule_id                      IN   NUMBER
   ,p_partial_success_allowed_flag IN   VARCHAR2
   ,x_rule_counter                 OUT  NOCOPY NUMBER
   );
--
-- API name    : GetNextRule
-- Type        : Private
-- Function    : Returns all values of the next row in the internal table of
--               strategy members and sets the next pointer to the next
--               available row.
PROCEDURE GetNextRule
  ( x_rule_id                      OUT  NOCOPY NUMBER
   ,x_partial_success_allowed_flag OUT  NOCOPY VARCHAR2
   );
END WMS_RE_Common_PVT;

 

/
