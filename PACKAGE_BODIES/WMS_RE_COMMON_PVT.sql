--------------------------------------------------------
--  DDL for Package Body WMS_RE_COMMON_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."WMS_RE_COMMON_PVT" AS
/* $Header: WMSVPPCB.pls 120.1 2005/06/07 12:18:50 appldev  $ */
-- File        : WMSVPPCS.pls
-- Content     : WMS_RE_Common_PVT package specification
-- Description : Common private procedures and functions internally used by
--               WMS strategy and rule API's.
--
--               Currently it manages the rule table
--               and the input line tables (all plsql tables)
-- Notes       :
-- Modified    : 02/08/99 mzeckzer created

-- API name    : InitInputTable
-- Type        : Private
-- Function    : Creates and initializes internal table of input records to
--               process.
--
-- Package global variable that stores the package name
g_pkg_name constant varchar2(30) := 'WMS_RE_Common_PVT';
--
-- Necessary variables for input parameters
-- [Added the following columns(s) in  'TYPE inp_rec_type IS RECORD..'
--  to support serial allocation based on serial reservation ]

TYPE inp_rec_type IS RECORD
  ( pp_transaction_temp_id  wms_transactions_temp.pp_transaction_temp_id%TYPE
   ,revision                wms_transactions_temp.revision%TYPE
   ,lot_number              wms_transactions_temp.lot_number%TYPE
   ,lot_expiration_date     wms_transactions_temp.lot_expiration_date%TYPE
   ,from_subinventory_code  wms_transactions_temp.from_subinventory_code%TYPE
   ,from_locator_id         wms_transactions_temp.from_locator_id%TYPE
   ,from_cost_group_id      wms_transactions_temp.from_cost_group_id%TYPE
   ,to_subinventory_code    wms_transactions_temp.to_subinventory_code%TYPE
   ,to_locator_id           wms_transactions_temp.to_locator_id%TYPE
   ,to_cost_group_id        wms_transactions_temp.to_cost_group_id%TYPE
   ,transaction_quantity    wms_transactions_temp.transaction_quantity%TYPE
   ,secondary_quantity      wms_transactions_temp.secondary_quantity%TYPE
   ,grade_code              wms_transactions_temp.grade_code%TYPE
   ,reservation_id          wms_transactions_temp.RESERVATION_ID%TYPE
   ,serial_number           wms_transactions_temp.serial_number%TYPE   ---- [ added new column - serial_number]
   ,lpn_id		    wms_transactions_temp.lpn_id%TYPE
   ,next_pointer            INTEGER
   );
TYPE inp_tbl_type IS TABLE OF inp_rec_type INDEX BY BINARY_INTEGER;
g_inp_tbl                 inp_tbl_type;
g_inp_counter             INTEGER;  -- size of g_inp_tbl
g_inp_pointer             INTEGER;  -- pointer to g_inp_tbl
g_inp_first               INTEGER;  -- first record pointer
g_inp_next                INTEGER;  -- next record pointer
g_inp_previous            INTEGER;  -- previous record pointer
--
-- Necessary variables for rules
TYPE rule_rec_type IS RECORD
  (  rule_id           wms_strategy_members.rule_id%TYPE
    ,partial_success_allowed_flag
                       wms_strategy_members.partial_success_allowed_flag%TYPE
     );
TYPE rule_tbl_type IS TABLE OF rule_rec_type INDEX BY BINARY_INTEGER;
g_rule_tbl                rule_tbl_type; -- rule table
g_rule_counter            INTEGER;       -- size of g_rule_tbl
g_rule_pointer            INTEGER;       -- record pointer to g_rule_tbl
-- API name    : InitInputTable
-- Type        : Private
-- Function    : Creates and initializes internal table of input records to
--               process.
PROCEDURE InitInputTable IS
BEGIN
   g_inp_tbl.DELETE;
   g_inp_counter  := 0;
   g_inp_first    := 0;
   g_inp_pointer  := 0;
   g_inp_next     := 0;
   g_inp_previous := 0;
END InitInputTable;
--
-- API name    : InitInputPointer
-- Type        : Private
-- Function    : Initializes next pointer to the first available row in the
--               internal table of input records to process.
PROCEDURE InitInputPointer IS
BEGIN
   g_inp_pointer  := 0;
   g_inp_next     := g_inp_first;
   g_inp_previous := 0;
END InitInputPointer;
--
-- API name    : InitInputLine
-- Type        : Private
-- Function    : Creates a new line in the internal table of input records to
--               process and initializes all neccessary values.
-- [ added the following column in PROCEDURE InitInputLine ]
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
   ,p_secondary_quantity      IN  NUMBER DEFAULT NULL
   ,p_grade_code              IN  VARCHAR2 DEFAULT NULL
   ,p_reservation_id          IN  NUMBER
   ,p_serial_number           IN  VARCHAR2 DEFAULT NULL  --- [ Added new column p_serial_number ]
   ,p_lpn_id		      IN  NUMBER
    )
  IS
BEGIN
   -- if first record, then save a pointer to it
   IF g_inp_counter = 0 THEN
      g_inp_first                                   := g_inp_counter + 1;
      -- if not, then update next pointer of previous record
    ELSE
      g_inp_tbl(g_inp_counter).next_pointer         := g_inp_counter + 1;
   END IF;
   -- insert actual record
   g_inp_counter                                   := g_inp_counter + 1;
   g_inp_tbl(g_inp_counter).pp_transaction_temp_id := p_pp_transaction_temp_id;
   g_inp_tbl(g_inp_counter).revision               := p_revision;
   g_inp_tbl(g_inp_counter).lot_number             := p_lot_number;
   g_inp_tbl(g_inp_counter).lot_expiration_date    := p_lot_expiration_date;
   g_inp_tbl(g_inp_counter).from_subinventory_code := p_from_subinventory_code;
   g_inp_tbl(g_inp_counter).from_locator_id        := p_from_locator_id;
   g_inp_tbl(g_inp_counter).from_cost_group_id     := p_from_cost_group_id;
   g_inp_tbl(g_inp_counter).to_subinventory_code   := p_to_subinventory_code;
   g_inp_tbl(g_inp_counter).to_locator_id          := p_to_locator_id;
   g_inp_tbl(g_inp_counter).to_cost_group_id       := p_to_cost_group_id;
   g_inp_tbl(g_inp_counter).transaction_quantity   := p_transaction_quantity;
   g_inp_tbl(g_inp_counter).secondary_quantity     := p_secondary_quantity;
   g_inp_tbl(g_inp_counter).grade_code             := p_grade_code;
   g_inp_tbl(g_inp_counter).reservation_id         := p_reservation_id;
   g_inp_tbl(g_inp_counter).lpn_id                 := p_lpn_id;
   g_inp_tbl(g_inp_counter).serial_number          := p_serial_number;
   ---[new code added g_inp_tbl(g_inp_counter).serial_number  := p_serial_number ]
   -- initialize the next pointer of the actual record
   g_inp_tbl(g_inp_counter).next_pointer           := 0;
END InitInputLine;
--
-- API name    : GetCountInputLines
-- Type        : Private
-- Function    : Returns number of rows in the internal table of input
--               records to process.
FUNCTION GetCountInputLines RETURN INTEGER IS
BEGIN
   RETURN g_inp_counter;
END GetCountInputLines;
--
-- API name    : GetNextInputLine
-- Type        : Private
-- Function    : Returns all values of the next row in the internal table of
--               input records to process and sets the next pointer to the
--               next available row.
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
   ,x_serial_number             OUT  NOCOPY VARCHAR2   -- [new column - x_serial_number]
   ,x_lpn_id			OUT  NOCOPY NUMBER
      ) IS
BEGIN
   g_inp_previous             := g_inp_pointer;
   g_inp_pointer              := g_inp_next;
   IF g_inp_pointer = 0 THEN
      x_pp_transaction_temp_id := NULL;
      x_revision               := NULL;
      x_lot_number             := NULL;
      x_lot_expiration_date    := NULL;
      x_from_subinventory_code := NULL;
      x_from_locator_id        := NULL;
      x_from_cost_group_id     := NULL;
      x_to_subinventory_code   := NULL;
      x_to_locator_id          := NULL;
      x_to_cost_group_id       := NULL;
      x_transaction_quantity   := NULL;
      x_secondary_quantity     := NULL;
      x_grade_code             := NULL;
      x_reservation_id         := NULL;
      x_serial_number          := NULL;
      --- [new code  x_serial_number  = NULL;]
      x_lpn_id                 := NULL;
    ELSE
      x_pp_transaction_temp_id
                               := g_inp_tbl(g_inp_pointer).pp_transaction_temp_id;
      x_revision               := g_inp_tbl(g_inp_pointer).revision;
      x_lot_number             := g_inp_tbl(g_inp_pointer).lot_number;
      x_lot_expiration_date    := g_inp_tbl(g_inp_pointer).lot_expiration_date;
      x_from_subinventory_code := g_inp_tbl(g_inp_pointer).from_subinventory_code;
      x_from_locator_id        := g_inp_tbl(g_inp_pointer).from_locator_id;
      x_from_cost_group_id     := g_inp_tbl(g_inp_pointer).from_cost_group_id;
      x_to_subinventory_code   := g_inp_tbl(g_inp_pointer).to_subinventory_code;
      x_to_locator_id          := g_inp_tbl(g_inp_pointer).to_locator_id;
      x_to_cost_group_id       := g_inp_tbl(g_inp_pointer).to_cost_group_id;
      x_transaction_quantity   := g_inp_tbl(g_inp_pointer).transaction_quantity;
      x_secondary_quantity     := g_inp_tbl(g_inp_pointer).secondary_quantity;
      x_grade_code             := g_inp_tbl(g_inp_pointer).grade_code;
      x_reservation_id         := g_inp_tbl(g_inp_pointer).reservation_id;
      x_serial_number          := g_inp_tbl(g_inp_pointer).serial_number;
      --- [ new code  x_serial_number  := g_inp_tbl(g_inp_pointer).serial_number; ]
      x_lpn_id                 := g_inp_tbl(g_inp_pointer).lpn_id;
      g_inp_next               := g_inp_tbl(g_inp_pointer).next_pointer;
   END IF;
END GetNextInputLine;
--
-- API name    : UpdateInputLine
-- Type        : Private
-- Function    : Updates the transaction quantity of the current row
--               in the internal table of input records to process
--               according to the provided value.
PROCEDURE UpdateInputLine (
  p_transaction_quantity IN NUMBER
 ,p_secondary_quantity IN NUMBER  DEFAULT NULL
) IS
BEGIN
   g_inp_tbl(g_inp_pointer).transaction_quantity := p_transaction_quantity;
   g_inp_tbl(g_inp_pointer).secondary_quantity := p_secondary_quantity;
END UpdateInputLine;
--
-- API name    : DeleteInputLine
-- Type        : Private
-- Function    : Deletes the current row in the internal table of input
--               records to process.
PROCEDURE DeleteInputLine IS
BEGIN
   -- delete first record
   IF g_inp_pointer = g_inp_first THEN
      g_inp_first := g_inp_next;
    ELSE
      -- delete any other record
      g_inp_tbl(g_inp_previous).next_pointer := g_inp_next;
   END IF;
   g_inp_counter := g_inp_counter - 1;
END DeleteInputLine;
--
-- API name    : InitRulesTable
-- Type        : Private
-- Function    : Creates and initializes internal table of all rules member
--               of the actual wms strategy to execute.
PROCEDURE InitRulesTable IS
BEGIN
   g_rule_tbl.delete;
   g_rule_counter := 0;
   g_rule_pointer := 0;
END InitRulesTable;
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
   ) IS
BEGIN
   g_rule_counter                     := g_rule_counter + 1;
   g_rule_tbl(g_rule_counter).rule_id := p_rule_id;
   g_rule_tbl(g_rule_counter).partial_success_allowed_flag
     := p_partial_success_allowed_flag;
    x_rule_counter                     := g_rule_counter;
END InitRule;
--
-- API name    : GetNextRule
-- Type        : Private
-- Function    : Returns all values of the next row in the internal table of
--               strategy members and sets the next pointer to the next
--               available row.
PROCEDURE GetNextRule
  ( x_rule_id                      OUT  NOCOPY NUMBER
   ,x_partial_success_allowed_flag OUT  NOCOPY VARCHAR2
   ) IS
BEGIN
   g_rule_pointer  := g_rule_pointer + 1;
    IF g_rule_pointer > g_rule_counter THEN
       x_rule_id                      := NULL;
       x_partial_success_allowed_flag := NULL;
     ELSE
       x_rule_id   := g_rule_tbl(g_rule_pointer).rule_id;
       x_partial_success_allowed_flag :=
	 g_rule_tbl(g_rule_pointer).partial_success_allowed_flag;
    END IF;
END GetNextRule;
END wms_re_common_pvt;

/
