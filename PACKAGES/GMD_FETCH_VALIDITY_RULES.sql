--------------------------------------------------------
--  DDL for Package GMD_FETCH_VALIDITY_RULES
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."GMD_FETCH_VALIDITY_RULES" AUTHID CURRENT_USER AS
/* $Header: GMDPVRFS.pls 120.2 2006/10/03 18:14:45 rajreddy noship $ */
/*#
 * This interface is used to fetch information reqd. by Validity Rules like
 * output ratio, ingredprod ratio, batchformula ratio, contributing qty,
 * input_ratio, uom_conversion_mesg etc.
 * This package defines and implements the procedures and datatypes
 * required to fetch the above mentioned information.
 * @rep:scope public
 * @rep:product GMD
 * @rep:lifecycle active
 * @rep:displayname Validity Rules Fetch package
 * @rep:compatibility S
 * @rep:category BUSINESS_ENTITY GMD_RECIPE_VALIDITY_RULE
 */




TYPE recipe_validity_tbl IS TABLE OF gmd_recipe_validity_rules%ROWTYPE
        INDEX BY BINARY_INTEGER;
/*#
 * Fetches the validity rules
 * This is a PL/SQL procedure is responsible for getting the
 * validity rules based on the input parameters
 * @param p_api_version API version field
 * @param p_init_msg_list Flag to check if message list intialized
 * @param p_recipe_id Recipe ID
 * @param p_item_id Item ID
 * @param p_organization_id Orgnanization ID of the Recipe owning organization
 * @param p_product_qty Product quantity
 * @param p_uom Unit of measure of product
 * @param p_recipe_use Recipe Use in production, planning, costing, regulatory or technical
 * @param p_total_input Total input Qty.
 * @param p_total_output Total output Qty.
 * @param p_status Not used at present
 * @param x_return_status  'S'-Success, 'E'-Error, 'U'-Unexpected Error
 * @param x_msg_count Number of msg's on message stack
 * @param x_msg_data Actual message data on message stack
 * @param x_return_code SQLCODE returned
 * @param X_recipe_validity_out Table structure of recipe validity rule table
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:displayname Get Validity Rules procedure
 * @rep:compatibility S
 */
PROCEDURE get_validity_rules(p_api_version         IN  NUMBER,
                             p_init_msg_list       IN  VARCHAR2 := FND_API.G_FALSE,
                             p_recipe_id           IN  NUMBER,
                             p_item_id             IN  NUMBER   := NULL,
                             p_organization_id     IN  NUMBER   := NULL,
                             p_product_qty         IN  NUMBER   := NULL,
                             p_uom                 IN  VARCHAR2 := NULL,
                             p_recipe_use          IN  VARCHAR2 := NULL,
                             p_total_input         IN  NUMBER,
                             p_total_output        IN  NUMBER,
                             p_status              IN  VARCHAR2 := NULL,
                             x_return_status       OUT NOCOPY VARCHAR2,
                             x_msg_count           OUT NOCOPY NUMBER,
                             x_msg_data            OUT NOCOPY VARCHAR2,
                             x_return_code         OUT NOCOPY NUMBER,
                             X_recipe_validity_out OUT NOCOPY recipe_validity_tbl);

/*#
 * Gets the output ratio
 * This is a PL/SQL procedure is responsible for determining the output ratio
 * which is the ratio of the batch output to the formula output when a total
 * output qty is used as the criteria for a validity rule
 * @param p_formula_id Formula ID
 * @param p_batch_output Batch output Qty.
 * @param p_yield_um Yield Unit of Measure
 * @param p_formula_output Formula output Qty.
 * @param x_return_status  'S'-Success, 'E'-Error, 'U'-Unexpected Error
 * @param X_output_ratio Output ratio returned
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:displayname Get Output Ratio procedure
 * @rep:compatibility S
 */
PROCEDURE get_output_ratio(p_formula_id     IN  NUMBER,
                           p_batch_output   IN  NUMBER,
                           p_yield_um       IN  VARCHAR2,
                           p_formula_output IN NUMBER,
                           x_return_status  OUT NOCOPY VARCHAR2,
                           X_output_ratio   OUT NOCOPY NUMBER);

/*#
 * Gets the Ingredient-Product ratio
 * This PL/SQL procedure is responsible for determining the ratio of the products to
 * ingredients while trying to determine validity rules based on total input qty.
 * @param p_formula_id Formula ID
 * @param p_yield_um Yield Unit of Measure
 * @param X_ingred_prod_ratio Ingredient-Product ratio returned
 * @param x_return_status  'S'-Success, 'E'-Error, 'U'-Unexpected Error
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:displayname Get Output Ratio procedure
 * @rep:compatibility S
 */
PROCEDURE get_ingredprod_ratio(p_formula_id        IN  NUMBER,
                               p_yield_um          IN  VARCHAR2,
                               X_ingred_prod_ratio OUT NOCOPY NUMBER,
                               x_return_status     OUT NOCOPY VARCHAR2);
/*#
 * Gets the Batch-Formula ratio
 * This PL/SQL procedure is responsible for determining the ratio of the batch input qty
 * to the formula input qty while determining validity rules based on total input qty.
 * @param p_formula_id Formula ID
 * @param p_batch_input Batch input Qty.
 * @param p_yield_um Yield Unit of Measure
 * @param p_formula_input Formula input Qty.
 * @param X_batchformula_ratio Batch-Formula ratio returned
 * @param X_return_status  'S'-Success, 'E'-Error, 'U'-Unexpected Error
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:displayname Get Batch-Formula Ratio procedure
 * @rep:compatibility S
 */
PROCEDURE get_batchformula_ratio(p_formula_id         IN  NUMBER,
                                 p_batch_input        IN  NUMBER,
                                 p_yield_um           IN  VARCHAR2,
                                 p_formula_input      IN  NUMBER,
                                 X_batchformula_ratio OUT NOCOPY NUMBER,
                                 X_return_status      OUT NOCOPY VARCHAR2);

/*#
 * Gets the Actual Contributing Quantity
 * This PL/SQL procedure is responsible for determining
 * the actual contributing qty of the formula.
 * @param p_formula_id Formula ID
 * @param p_recipe_id Recipe ID
 * @param p_batchformula_ratio Batch-Formula ratio
 * @param p_yield_um Yield Unit of Measure
 * @param X_contributing_qty Actual Contributing Quantity returned
 * @param X_return_status  'S'-Success, 'E'-Error, 'U'-Unexpected Error
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:displayname Get Contributing Quantity procedure
 * @rep:compatibility S
 */
PROCEDURE get_contributing_qty(p_formula_id          IN  NUMBER,
                               p_recipe_id           IN  NUMBER,
                               p_batchformula_ratio  IN  NUMBER,
                               p_yield_um            IN  VARCHAR2,
                               X_contributing_qty    OUT NOCOPY NUMBER,
                               X_return_status       OUT NOCOPY VARCHAR2);

/*#
 * Gets the input ratio
 * This PL/SQL procedure is responsible for determining
 * the actual ratio of product for the total input qty.
 * @param p_formula_id Formula ID
 * @param p_contributing_qty Actual Contributing Quantity
 * @param p_yield_um Yield Unit of Measure
 * @param p_formula_output Formula Output Qty.
 * @param X_output_ratio Ratio returned
 * @param X_return_status  'S'-Success, 'E'-Error, 'U'-Unexpected Error
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:displayname Get Input Ratio procedure
 * @rep:compatibility S
 */
PROCEDURE get_input_ratio(p_formula_id       IN  NUMBER,
                          p_contributing_qty IN  NUMBER,
                          p_yield_um         IN  VARCHAR2,
                          p_formula_output   IN  NUMBER,
                          X_output_ratio     OUT NOCOPY NUMBER,
                          X_return_status    OUT NOCOPY VARCHAR2);

/*#
 * Gets the UOM conversion error message
 * This PL/SQL procedure is responsible for showing
 * the message about uom conversion errors
 * @param p_item_id Item ID
 * @param p_from_um From Unit of measure
 * @param p_to_um To Unit of measure
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:displayname Get UOM Conversion Error message procedure
 * @rep:compatibility S
 */
PROCEDURE uom_conversion_mesg(p_item_id IN NUMBER,
                              p_from_um IN VARCHAR2,
                              p_to_um   IN VARCHAR2);
END gmd_fetch_validity_rules;

 

/
