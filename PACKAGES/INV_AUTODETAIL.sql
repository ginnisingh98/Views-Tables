--------------------------------------------------------
--  DDL for Package INV_AUTODETAIL
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."INV_AUTODETAIL" AUTHID CURRENT_USER AS
/* $Header: INVRSV4S.pls 120.0 2005/05/25 06:51:02 appldev noship $ */
--
-- Description
--   Create transaction suggestions api based on rules in mtl_picking_rules.
--
--   The output of this procedure is records in mtl_material_transactions_temp
--   , mtl_transaction_lots_temp, and mtl_serial_numbers_temp.
--
-- Notes
--   1. Integration with reservations
--      If table p_reservations passed by the calling is not empty, the
--      engine will detailing based on a combination of the info in the
--      move order line (the record that represents detailing request),
--      and the info in p_reservations. For example, a sales order line
--      can have two reservations, one for revision A in quantity of 10,
--      and one for revision B in quantity of 5, and the line quantity
--      can be 15; so when the pick release api calls the engine
--      p_reservations will have two records of the reservations. So
--      if the move order line based on the sales order line does not
--      specify a revision, the engine will merge the information from
--      move order line and p_reservations to create the input for
--      detailing as two records, one for revision A, and one for revision
--      B. Please see documentation for the pick release API for more
--      details.
--
--  2.  Serial Number Detailing in Picking
--      Currently the serial number detailing is quite simple. If the caller
--      gives a range (start, and end) serial numbers in the move order line
--      and pass p_suggest_serial as fnd_api.true, the engine will filter
--      the locations found from a rule, and suggest unused serial numbers
--      in the locator. If p_suggest_serial is passed as fnd_api.g_false
--      (default), the engine will not give serial numbers in the output.
--
-- Input Parameters
--   p_api_version_number   standard input parameter
--   p_init_msg_lst         standard input parameter
--   p_commit               standard input parameter
--   p_validation_level     standard input parameter
--   p_transaction_temp_id  equals to the move order line id
--                          for the detailing request
--   p_reservations         reservations for the demand source
--                          as the transaction source
--                          in the move order line.
--   p_suggest_serial       whether or not the engine should suggest
--                          serial numbers in the detailing
--
-- Output Parameters
--   x_return_status        standard output parameters
--   x_msg_count            standard output parameters
--   x_msg_data             standard output parameters
--
PROCEDURE create_suggestions
  (p_api_version           IN  NUMBER,
   p_init_msg_list         IN  VARCHAR2 DEFAULT fnd_api.g_false,
   p_commit                IN  VARCHAR2 DEFAULT fnd_api.g_false,
   p_validation_level      IN  NUMBER   DEFAULT fnd_api.g_valid_level_none,
   x_return_status         OUT NOCOPY VARCHAR2,
   x_msg_count             OUT NOCOPY NUMBER,
   x_msg_data              OUT NOCOPY VARCHAR2,
   p_transaction_temp_id   IN  NUMBER,
   p_reservations          IN  inv_reservation_global.mtl_reservation_tbl_type,
   p_suggest_serial        IN  VARCHAR2 DEFAULT fnd_api.g_false
   );
END inv_autodetail;

 

/
