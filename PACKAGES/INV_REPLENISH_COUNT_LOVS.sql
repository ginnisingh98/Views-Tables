--------------------------------------------------------
--  DDL for Package INV_REPLENISH_COUNT_LOVS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."INV_REPLENISH_COUNT_LOVS" AUTHID CURRENT_USER AS
  /* $Header: INVRPCLS.pls 120.1 2006/04/13 06:26:37 aalex noship $ */

  /**  Package   : INV_REPLENISH_COUNT_LOVS<br>
    *  File        : INVRPCLS.pls<br>
    *  Content     :<br>
    *  Description :<br>
    *  Notes       :<br>
    *  Modified    : Mon Aug 25 12:17:54 GMT+05:30 2003<br>
    *
    *  Package Specification inv_replenish_count_lovs<p>
    *  This file contains Replenishment Count LOVS being used by the
    *  mobile WMS/INV applications. <br>It is being called from java
    *  LOV beans to populate the LOV. <br>
    *
    **/
  TYPE t_genref IS REF CURSOR;

  /**
   * This procedure returns valid Replenishment Count Names for counting in mobile.<p>
   * @param   x_replenish_count_lov   Returns LOV rows as a reference cursor<br>
   * @param   p_replenish_count       Restricts LOV SQL to the user input Count Name<br>
   * @param   p_organization_id       Organization ID<br>
   * @param   p_subinventory          Subinventory Code<br>
   **/
  PROCEDURE get_replenish_count_lov(
    x_replenish_count_lov OUT NOCOPY t_genref
  , p_replenish_count     IN VARCHAR2
  , p_organization_id     IN NUMBER
  , p_subinventory        IN VARCHAR2
  );

  /**
   *  This procedure returns valid Subinventories which have atleast one Min Max planned or
   *  PAR level planned item defined in the Item subinventories form.<p>
   *  @param  x_replenish_count_subs_lov  Returns LOV rows as a reference cursor<br>
   *  @param  p_subinventory              Subinventory Code<br>
   *  @param  p_organization_id           Organization ID<br>
   **/
  PROCEDURE get_replenish_count_subs_lov(
    x_replenish_count_subs_lov OUT NOCOPY t_genref
  , p_subinventory             IN VARCHAR2
  , p_organization_id          IN NUMBER
  );

  /**
   *  This procedure returns all the locators which have
   *  Item-Locator relationship defined in the Item subinventories form.<p>
   *  @param  x_replenish_count_locator_kff    Returns LOV rows as a reference cursor<br>
   *  @param  p_locator                        Restricts LOV SQL to this user input Locator<br>
   *  @param  p_replenish_header_id            Replenishment Count Header ID<br>
   *  @param  p_organization_id                Organization ID<br>
   *  @param  p_subinventory                   Subinventory Code<br>
   *  @param  p_qty_tracked                    Quantity Tracked  Subinventory<br>
   **/
  PROCEDURE get_replenish_count_locs_kff(
    x_replenish_count_locator_kff OUT NOCOPY t_genref
  , p_locator                     IN VARCHAR2
  , p_replenish_header_id         IN NUMBER
  , p_organization_id             IN NUMBER
  , p_subinventory                IN VARCHAR2
  , p_qty_tracked                 IN NUMBER
  );

  PROCEDURE get_replenish_count_locs_kff(
    x_replenish_count_locator_kff OUT NOCOPY t_genref
  , p_locator                     IN VARCHAR2
  , p_replenish_header_id         IN NUMBER
  , p_organization_id             IN NUMBER
  , p_subinventory                IN VARCHAR2
  , p_qty_tracked                 IN NUMBER
  , p_alias                       IN VARCHAR2
  );

  /**
   *  This procedure returns all the items which have Item-Subinventory or
   *  Item-Locator relationship defined in the Item subinventories form.<p>
   *  @param  x_replenish_count_items_lov    Returns LOV rows as a reference cursor<br>
   *  @param  p_item                         Restricts LOV SQL to this user input Item<br>
   *  @param  p_replenish_header_id          Replenishment Count Header ID<br>
   *  @param  p_organization_id              Organization ID<br>
   *  @param  p_subinventory                 Subinventory Code<br>
   *  @param  p_locator_id                   Locator Id<br>
   *  @param  p_qty_tracked                  Quantity Tracked  Subinventory<br>
   **/
  PROCEDURE get_replenish_count_items_lov(
    x_replenish_count_items_lov OUT NOCOPY t_genref
  , p_item                      IN VARCHAR2
  , p_replenish_header_id       IN NUMBER
  , p_organization_id           IN NUMBER
  , p_subinventory              IN VARCHAR2
  , p_locator_id                IN NUMBER
  , p_qty_tracked               IN NUMBER
  );

  /**
   *  This procedure returns the Replenishment Count Types allowed for the passed in
   *  input combination of Item, Subinventory and Locator.<p>
   *  @param   x_replenish_count_types_lov  Returns LOV rows as a reference cursor<br>
   *  @param   p_count_type                 Count Type<br>
   *  @param   p_qty_tracked                Quantity Tracked  Subinventory<br>
   *  @param   p_inventory_planning_level   Planning Level of the Subinventory<br>
   *  @param   p_par_level                  PAR level for the Locator Item.<p>
   **/
  /**---------------------------------------------------------------------<br>
   *      Parameters                          value passed<br>
   * ---------------------------------------------------------------------<br>
   *     p_quantity_tracked            1(Check) 1        2       2 <br>
   *<br>
   *     p_inventory_planning_level    1(PAR)   2(Sub)   1       2<br>
   *<br>
   *     p_par_level                   -       NULL      -       NOT NULL<br>
   * ---------------------------------------------------------------------<br>
   *    Count Types Returned     Order Qty Order Qty Onhand Qty Onhand Qty<br>
   *                                                  Order Qty Order Qty<br>
   *----------------------------------------------------------------------*/
  PROCEDURE get_replenish_count_types_lov(
    x_replenish_count_types_lov OUT NOCOPY t_genref
  , p_count_type                IN VARCHAR2
  , p_qty_tracked               IN NUMBER
  , p_inventory_planning_level  IN NUMBER
  , p_par_level                 IN NUMBER
  );
END inv_replenish_count_lovs;

 

/
