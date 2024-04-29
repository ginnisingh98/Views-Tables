--------------------------------------------------------
--  DDL for Package PO_SOURCING2_SV
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PO_SOURCING2_SV" AUTHID CURRENT_USER as
/* $Header: POXSCS2S.pls 120.1.12010000.7 2013/10/03 08:54:34 inagdeo ship $ */

/*===========================================================================
  PACKAGE NAME:         PO_SOURCING2_SV

  DESCRIPTION:          This package contains the server side Supplier Item
                        Catalog and Sourcing Application Program Interfaces
                        (APIs).

  CLIENT/SERVER:        Server

  OWNER:                Liza Broadbent

  FUNCTION/PROCEDURE:   get_break_price()
                        get_release_quantity()
                        get_display_find_option()
                        get_default_results_option()
                        get_item_detail()

===========================================================================*/

/*===========================================================================
  FUNCTION NAME:        get_default_results_option

  DESCRIPTION:          Retrieves the PO: Default Supplier-Item Catalog Results
                        profile option.


  PARAMETERS:

  RETURN TYPE:          VARCHAR2

  DESIGN REFERENCES:

  ALGORITHM:

  NOTES:

  OPEN ISSUES:

  CLOSED ISSUES:

  CHANGE HISTORY:       Created         15-AUG-95       LBROADBE
===========================================================================*/
FUNCTION  get_default_results_option return VARCHAR2;

/*===========================================================================
  FUNCTION NAME:        get_display_find_option

  DESCRIPTION:          Retreives the PO: Display Find on Open Catalog profile
                        profile option.


  PARAMETERS:

  RETURN TYPE:          VARCHAR2

  DESIGN REFERENCES:

  ALGORITHM:

  NOTES:

  OPEN ISSUES:

  CLOSED ISSUES:

  CHANGE HISTORY:       Created         15-AUG-95       LBROADBE
===========================================================================*/
FUNCTION  get_display_find_option return VARCHAR2;

/*===========================================================================
  FUNCTION NAME:        get_break_price

  DESCRIPTION:          Returns the appropriate break price for a blanket
                        release shipment.  If no break price is available
                        (the order quantity is too small, there are no
                        matching price breaks, or the blanket line has no
                        price breaks) it returns the blanket line price.
  SERVICES FPJ : Also returns price break id if the price is from a price break


  PARAMETERS:

  RETURN TYPE:          NUMBER

  DESIGN REFERENCES:

  ALGORITHM:

  NOTES:

  OPEN ISSUES:

  CLOSED ISSUES:

  CHANGE HISTORY:       Created         01-NOV-95       LBROADBE
===========================================================================*/

PROCEDURE get_break_price(p_api_version      IN NUMBER,
                          p_order_quantity   IN NUMBER,
                          p_ship_to_org      IN NUMBER,
                          p_ship_to_loc      IN NUMBER,
                          p_po_line_id       IN NUMBER,
                          p_cum_flag         IN BOOLEAN,
                          p_need_by_date     IN DATE,               -- TIMEPHASED FPI
                          p_line_location_id IN NUMBER,
                          p_req_line_price IN NUMBER DEFAULT NULL,--bug 8845486
                          --Bug:8598002 renamed p_retro_pricing to p_pricing_call_src, to distinguish calls from retro and auto creation
                          p_pricing_call_src IN VARCHAR2 DEFAULT NULL, --<Enhanced Pricing: parameter to identify calls from retro/auto creation>
                          x_price_break_id   OUT NOCOPY NUMBER,     -- SERVICES FPJ
                          x_price            OUT NOCOPY NUMBER,     -- SERVICES FPJ
                          x_return_status    OUT NOCOPY VARCHAR2 );

--<Enhanced Pricing Start>
/*===========================================================================
  PROCEDURE NAME:        get_break_price

  DESCRIPTION:          Overloaded price break API

===========================================================================*/
  PROCEDURE get_break_price(p_order_quantity IN NUMBER,
                            p_ship_to_org IN NUMBER,
                            p_ship_to_loc IN NUMBER,
                            p_po_line_id IN NUMBER,
                            p_cum_flag IN BOOLEAN,
                            p_need_by_date IN DATE,
                            p_line_location_id IN NUMBER,
                            --Bug:8598002 renamed p_retro_pricing to p_pricing_call_src, to distinguish calls from retro and auto creation
                            p_pricing_call_src IN VARCHAR2 DEFAULT NULL, --<Enhanced Pricing: parameter to identify calls from retro/auto creation>
                            x_price OUT NOCOPY NUMBER,
                            x_base_unit_price OUT NOCOPY NUMBER
                           );
--<Enhanced Pricing End>

/*===========================================================================
  FUNCTION NAME:        get_break_price

  DESCRIPTION:          Overloaded price break API

===========================================================================*/
FUNCTION get_break_price(x_order_quantity IN NUMBER,
                         x_ship_to_org    IN NUMBER,
                         x_ship_to_loc    IN NUMBER,
                         x_po_line_id     IN NUMBER,
                         x_cum_flag       IN BOOLEAN,
                         p_need_by_date   IN DATE,   /* <TIMEPHASED FPI> */
                         x_line_location_id IN NUMBER DEFAULT NULL,
                         p_req_line_price IN NUMBER DEFAULT NULL, --bug 8845486
                         --Bug:8598002 renamed p_retro_pricing to p_pricing_call_src, to distinguish calls from retro and auto creation
                         p_pricing_call_src IN VARCHAR2 DEFAULT NULL --<Enhanced Pricing: parameter to identify calls from retro/auto creation>
                        )
                        return NUMBER;


-- <FPJ Advanced Price START>
PROCEDURE get_break_price(p_api_version         IN  NUMBER,
                          p_order_quantity      IN  NUMBER,
                          p_ship_to_org         IN  NUMBER,
                          p_ship_to_loc         IN  NUMBER,
                          p_po_line_id          IN  NUMBER,
                          p_cum_flag            IN  BOOLEAN,
                          p_need_by_date        IN  DATE,
                          p_line_location_id    IN  NUMBER,
                          p_contract_id         IN  NUMBER,
                          p_org_id              IN  NUMBER,
                          p_supplier_id         IN  NUMBER,
                          p_supplier_site_id    IN  NUMBER,
                          p_creation_date       IN  DATE,
                          p_order_header_id     IN  NUMBER,
                          p_order_line_id       IN  NUMBER,
                          p_line_type_id        IN  NUMBER,
                          p_item_revision       IN  VARCHAR2,
                          p_item_id             IN  NUMBER,
                          p_category_id         IN  NUMBER,
                          p_supplier_item_num   IN  VARCHAR2,
                          p_uom                 IN  VARCHAR2,
                          p_in_price            IN  NUMBER,
                          p_currency_code       IN  VARCHAR2,  -- Bug 3564863
                          --Bug:8598002 renamed p_retro_pricing to p_pricing_call_src, to distinguish calls from retro and auto creation
                          p_pricing_call_src    IN VARCHAR2 DEFAULT NULL, --<Enhanced Pricing: parameter to identify calls from retro/auto creation>
                          x_base_unit_price     OUT NOCOPY NUMBER,
                          x_price_break_id      OUT NOCOPY NUMBER,
                          x_price               OUT NOCOPY NUMBER,
                          x_return_status       OUT NOCOPY VARCHAR2,
                          p_req_line_price      IN NUMBER DEFAULT NULL  );  -- Bug 7154646
-- <FPJ Advanced Price END>
-- Bug# 4148430: Adding x_negotiated_by_preparer_flag.
PROCEDURE get_break_price(p_api_version         IN  NUMBER,
                          p_order_quantity      IN  NUMBER,
                          p_ship_to_org         IN  NUMBER,
                          p_ship_to_loc         IN  NUMBER,
                          p_po_line_id          IN  NUMBER,
                          p_cum_flag            IN  BOOLEAN,
                          p_need_by_date        IN  DATE,
                          p_line_location_id    IN  NUMBER,
                          p_contract_id         IN  NUMBER,
                          p_org_id              IN  NUMBER,
                          p_supplier_id         IN  NUMBER,
                          p_supplier_site_id    IN  NUMBER,
                          p_creation_date       IN  DATE,
                          p_order_header_id     IN  NUMBER,
                          p_order_line_id       IN  NUMBER,
                          p_line_type_id        IN  NUMBER,
                          p_item_revision       IN  VARCHAR2,
                          p_item_id             IN  NUMBER,
                          p_category_id         IN  NUMBER,
                          p_supplier_item_num   IN  VARCHAR2,
                          p_uom                 IN  VARCHAR2,
                          p_in_price            IN  NUMBER,
                          p_currency_code       IN  VARCHAR2,  -- Bug 3564863
                          --<Enhanced Pricing Start>
                          p_draft_id            IN  NUMBER DEFAULT NULL,
                          p_src_flag            IN  VARCHAR2 DEFAULT NULL,
                          p_doc_sub_type        IN  VARCHAR2 DEFAULT NULL,
                          --Bug:8598002 renamed p_retro_pricing to p_pricing_call_src, to distinguish calls from retro and auto creation
                          p_pricing_call_src    IN VARCHAR2 DEFAULT NULL, --<Enhanced Pricing: parameter to identify calls from retro/auto creation>
                          --<Enhanced Pricing End>
                          x_base_unit_price     OUT NOCOPY NUMBER,
                          x_price_break_id      OUT NOCOPY NUMBER,
                          x_price               OUT NOCOPY NUMBER,
                          -- Bug# 4148430
                          x_from_advanced_pricing OUT NOCOPY VARCHAR2,
                          x_return_status         OUT NOCOPY VARCHAR2,
                          p_req_line_price        IN NUMBER DEFAULT NULL );  -- Bug 7154646

/*===========================================================================
  FUNCTION NAME:        get_release_quantity

  DESCRIPTION:          Returns a) the quantity released to-date and b)
                        the appropriate price break org/location combination
                        that should be used to select the break price.


  PARAMETERS:

  RETURN TYPE:          NUMBER

  DESIGN REFERENCES:

  ALGORITHM:            Assume the following ship-to organization/location
                        combinations exist for a blanket line's price
                        breaks:

                        ORG     LOC     MAP TO QUANTIY VARIABLES
                        -----------     ------------------------
                        | A  |  X | --> release_quantity
                        -----------
                        | A  |  - | --> candidate_quantity
                        -----------
                        | -  |  - | --> all_rls_quantity
                        -----------
                        | A  |  E | --> subtract_quantity
                        -----------
                        | D  |  H | --> exclude_quantity
                        -----------

                        To find the quantity released for org A, loc X:

                        o Sum the quantity released against nonmatching
                          orgs (in this case D).  Store the result in
                          variable exclude_quantity.

                        o Sum the quantity released against org A, and
                          locations != X (in this case A, E).  Store
                          the result in variable subtract_quantity.

                        o Sum the quantity released against org A and a
                          NULL location.  Store the result in variable
                          candidate_quantity.  If we do not find an
                          exact org/loc match, this is the price break
                          org/loc combination we are interested in.

                          If a price break exists (with matching org and
                          null shipment), set x_match_type = 'ORG'.

                        o Sum the quantity released against org A, loc X.

                          If a price break exists (with matching org and
                          matching location), set x_match_type = 'ALL'
                          and exit the loop so we can return this qty.

                        o If there is a price break with a NULL org and
                          a NULL location, sum total quantity released
                          against the blanket line.  Store this result
                          in variable all_rls_quantity.  If x_match_type
                          is null, set x_match_type = 'NULL.'  If it is
                          not null, then it will equal 'ORG' which is a
                          closer match than a fully null price break (it
                          will never equal 'ALL' for this test since we
                          exit as soon as we find the exact match).

                        RESULT HIERARCHY
                        ----------------
                        If an exact match is found (org A, loc X) return
                        this exact release quantity and x_match_type of
                        'ALL.'

                        If a half-match exists, return an x_match_type of
                        'ORG.'  The release quantity in this case =
                        candidate_quantity - subtract_quantity.  If the
                        result is negative, set to 0.

                        If a null org/loc price break exists, return an
                        x_match_type of 'NULL.'  The release quantity in
                        this case = all_rls_quantity - candidate_quantity -
                        subtract_quantity - exclude_quantity.  If the
                        result is negative, set to 0.

                        Elsif no matching price breaks are found,
                        the x_match_type is 'NONE' and the release
                        quantity = 0.


  NOTES:                This is different from release 10 functionality
                        (which was incorrect).  The release 10 code for
                        AutoSource and Releases will need to be changed
                        for consistency.  Verified w/ kmiller.

  OPEN ISSUES:

  CLOSED ISSUES:

  CHANGE HISTORY:       Created         01-NOV-95       LBROADBE
===========================================================================*/
FUNCTION get_release_quantity(x_ship_to_org IN NUMBER,
                              x_ship_to_loc IN NUMBER,
                              x_po_line_id  IN NUMBER,
                              x_match_type  IN OUT NOCOPY VARCHAR2) return NUMBER;

/*===========================================================================
  FUNCTION NAME:        get_item_detail

  DESCRIPTION:

  PARAMETERS:           X_item_id           IN     NUMBER,
                        X_org_id            IN     NUMBER,
                        X_planned_item_flag IN OUT VARCHAR2,
                        X_list_price        IN OUT NUMBER,
                        X_primary_uom       IN OUT VARCHAR2

  RETURN VALUE:         BOOLEAN

  DESIGN REFERENCES:

  ALGORITHM:

  NOTES:

  OPEN ISSUES:

  CLOSED ISSUES:

  CHANGE HISTORY:       Created         15-AUG-95       LBROADBE
===========================================================================*/
FUNCTION get_item_detail(X_item_id           IN     NUMBER,
                         X_org_id            IN     NUMBER,
                         X_planned_item_flag IN OUT NOCOPY VARCHAR2,
                         X_list_price        IN OUT NOCOPY NUMBER,
                         X_primary_uom       IN OUT NOCOPY VARCHAR2) return BOOLEAN;



PROCEDURE update_line_price
(   p_po_line_id               IN   NUMBER
,   p_price                    IN   NUMBER
,   p_from_line_location_id    IN   NUMBER                    -- <SERVICES FPJ>
);

-- <FPJ Advanced Price START>
PROCEDURE update_line_price
(   p_po_line_id               IN   NUMBER
,   p_price                    IN   NUMBER
,   p_base_unit_price          IN   NUMBER
,   p_from_line_location_id    IN   NUMBER                    -- <SERVICES FPJ>
);
-- <FPJ Advanced Price END>


/*===========================================================================
  PROCEDURE NAME:       update_shipment_price

  DESCRIPTION:

  PARAMETERS:           p_price            IN NUMBER,
                        p_line_location_id IN NUMBER

  RETURN VALUE:         None

  DESIGN REFERENCES:

  ALGORITHM:

  NOTES:

  OPEN ISSUES:

  CLOSED ISSUES:

  CHANGE HISTORY:       Created         20-DEC-02       DAVIDNG
===========================================================================*/
PROCEDURE update_shipment_price(p_price            IN NUMBER,
                                p_line_location_id IN NUMBER);


/*===========================================================================
  PROCEDURE NAME:       get_min_shipment_num

  DESCRIPTION:

  PARAMETERS:           p_po_line_id       IN         NUMBER,
                        x_min_shipment_num OUT NOCOPY NUMBER

  RETURN VALUE:         None

  DESIGN REFERENCES:

  ALGORITHM:

  NOTES:

  OPEN ISSUES:

  CLOSED ISSUES:

  CHANGE HISTORY:       Created         20-DEC-02       DAVIDNG
===========================================================================*/
PROCEDURE get_min_shipment_num(p_po_line_id       IN         NUMBER,
                               x_min_shipment_num OUT NOCOPY NUMBER);


/*===========================================================================
  PROCEDURE NAME:       get_shipment_price

  DESCRIPTION:

  PARAMETERS:           p_po_line_id       IN         NUMBER,
                        p_from_line_id     IN         NUMBER,
                        p_min_shipment_num IN         NUMBER,
                        p_quantity         IN         NUMBER,
                        x_price            OUT NOCOPY NUMBER

  RETURN VALUE:         None

  DESIGN REFERENCES:

  ALGORITHM:

  NOTES:

  OPEN ISSUES:

  CLOSED ISSUES:

  CHANGE HISTORY:       Created         20-DEC-02       DAVIDNG
===========================================================================*/

PROCEDURE get_shipment_price
(   p_po_line_id                IN  NUMBER,
    p_from_line_id              IN  NUMBER,
    p_min_shipment_num          IN  NUMBER,
    p_quantity                  IN  NUMBER,
    x_price                     OUT NOCOPY NUMBER,
    x_from_line_location_id     OUT NOCOPY NUMBER);                 -- <SERVICES FPJ>

-- <FPJ Advanced Price START>
PROCEDURE get_shipment_price
(   p_po_line_id                IN  NUMBER,
    p_from_line_id              IN  NUMBER,
    p_min_shipment_num          IN  NUMBER,
    p_quantity                  IN  NUMBER,
    p_contract_id               IN  NUMBER,
    p_org_id                    IN  NUMBER,
    p_supplier_id               IN  NUMBER,
    p_supplier_site_id          IN  NUMBER,
    p_creation_date             IN  DATE,
    p_order_header_id           IN  NUMBER,
    p_order_line_id             IN  NUMBER,
    p_line_type_id              IN  NUMBER,
    p_item_revision             IN  VARCHAR2,
    p_item_id                   IN  NUMBER,
    p_category_id               IN  NUMBER,
    p_supplier_item_num         IN  VARCHAR2,
    p_uom                       IN  VARCHAR2,
    p_currency_code             IN  VARCHAR2,   -- Bug 3564863
    p_in_price                  IN  NUMBER,
    x_base_unit_price           OUT NOCOPY NUMBER,
    x_price                     OUT NOCOPY NUMBER,
    x_from_line_location_id     OUT NOCOPY NUMBER);                 -- <SERVICES FPJ>
-- <FPJ Advanced Price END>

--<PDOI Enhancement Bug#17063664>
PROCEDURE get_break_price
(
  p_api_version IN NUMBER,
  x_pricing_attributes_rec IN OUT NOCOPY PO_PDOI_TYPES.pricing_attributes_rec_type,
  x_return_status	OUT NOCOPY VARCHAR2
);

END PO_SOURCING2_SV;

/
