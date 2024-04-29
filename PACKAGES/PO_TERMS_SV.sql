--------------------------------------------------------
--  DDL for Package PO_TERMS_SV
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PO_TERMS_SV" AUTHID CURRENT_USER AS
/* $Header: POXPOTES.pls 115.7 2003/12/03 20:17:09 bao ship $*/

-- <GC FPJ START>
-- Define a record that includes terms and conditions to be compared in
-- compare_terms_conditions procedure

-- bug3225062 START

G_COMPARISON_SCOPE_GLOBAL CONSTANT VARCHAR2(10) := 'GLOBAL';
G_COMPARISON_SCOPE_LOCAL  CONSTANT VARCHAR2(10) := 'LOCAL';
G_COMPARISON_SCOPE_ALL    CONSTANT VARCHAR2(10) := 'ALL';


TYPE terms_and_cond_rec_type IS RECORD (
  terms_id                  PO_HEADERS_ALL.terms_id%TYPE,
  fob_lookup_code           PO_HEADERS_ALL.fob_lookup_code%TYPE,
  freight_terms_lookup_code PO_HEADERS_ALL.freight_terms_lookup_code%TYPE,
  note_to_vendor            PO_HEADERS_ALL.note_to_vendor%TYPE,
  note_to_receiver          PO_HEADERS_ALL.note_to_receiver%TYPE,
  shipping_control          PO_HEADERS_ALL.shipping_control%TYPE,    -- <INBOUND LOGISTICS FPJ>
  pay_on_code               PO_HEADERS_ALL.pay_on_code%TYPE,
  bill_to_location_id       PO_HEADERS_ALL.bill_to_location_id%TYPE,
  ship_to_location_id       PO_HEADERS_ALL.ship_to_location_id%TYPE,
  ship_via_lookup_code      PO_HEADERS_ALL.ship_via_lookup_code%TYPE
);

TYPE terms_cond_comp_rec_type IS RECORD (
  terms_id_eq               VARCHAR2(1),
  fob_lookup_code_eq        VARCHAR2(1),
  freight_terms_lookup_code_eq VARCHAR2(1),
  note_to_vendor_eq         VARCHAR2(1),
  note_to_receiver_eq       VARCHAR2(1),
  shipping_control_eq       VARCHAR2(1),
  pay_on_code_eq            VARCHAR2(1),
  bill_to_location_id_eq    VARCHAR2(1),
  ship_to_location_id_eq    VARCHAR2(1),
  ship_via_lookup_code_eq   VARCHAR2(1)
);

-- bug3225062 END

-- <GC FPJ END>



/*===========================================================================
  FUNCTION NAME:	val_payment_terms

  DESCRIPTION:		This is a cover routine to val_ap_terms allowing for
			standard calling:  id in, boolean return result.
			Ultimately, this will become the standard validation
			function for payment terms.


  PARAMETERS:		X_ap_terms_id IN NUMBER

  RETURN TYPE:		BOOLEAN

  DESIGN REFERENCES:

  ALGORITHM:

  NOTES:

  OPEN ISSUES:

  CLOSED ISSUES:

  CHANGE HISTORY:	Created 	14-AUG-95	LBROADBE
===========================================================================*/
FUNCTION val_payment_terms(X_ap_terms_id IN NUMBER) return BOOLEAN;

/*===========================================================================
  FUNCTION NAME:	val_fob_code

  DESCRIPTION:		This is a cover routine to val_fob allowing for
			standard calling:  code in, boolean return result.
			Ultimately, this will become the standard validation
			function for the fob code.


  PARAMETERS:		X_fob_lookup_code IN VARCHAR2

  RETURN TYPE:		BOOLEAN

  DESIGN REFERENCES:

  ALGORITHM:

  NOTES:

  OPEN ISSUES:

  CLOSED ISSUES:

  CHANGE HISTORY:	Created 	14-AUG-95	LBROADBE
===========================================================================*/
FUNCTION val_fob_code(X_fob_lookup_code IN VARCHAR2) return BOOLEAN;

/*===========================================================================
  FUNCTION NAME:	val_ship_via

  DESCRIPTION:		This is a cover routine to val_freight_carrier allowing for
			standard calling:  code in, boolean return result.
			Ultimately, this will become the standard validation
			function for the ship via code.


  PARAMETERS:		X_ship_via_code IN VARCHAR2,
			X_org_id	IN NUMBER

  RETURN TYPE:		BOOLEAN

  DESIGN REFERENCES:

  ALGORITHM:

  NOTES:

  OPEN ISSUES:

  CLOSED ISSUES:

  CHANGE HISTORY:	Created 	14-AUG-95	LBROADBE
===========================================================================*/
FUNCTION val_ship_via(X_ship_via_code IN VARCHAR2,
		      X_org_id	      IN NUMBER) return BOOLEAN;

/*===========================================================================
  FUNCTION NAME:	val_freight_code

  DESCRIPTION:		This is a cover routine to val_freight_terms allowing for
			standard calling:  code in, boolean return result.
			Ultimately, this will become the standard validation
			function for freight code.


  PARAMETERS:		X_freight_terms_code IN NUMBER

  RETURN TYPE:		BOOLEAN

  DESIGN REFERENCES:

  ALGORITHM:

  NOTES:

  OPEN ISSUES:

  CLOSED ISSUES:

  CHANGE HISTORY:	Created 	14-AUG-95	LBROADBE
===========================================================================*/
FUNCTION val_freight_code(X_freight_terms_code IN VARCHAR2) return BOOLEAN;

/*===========================================================================
  PROCEDURE NAME:	val_ap_terms()

  DESCRIPTION: This procedure decides if the given payment_terms_id
                   is valid (ie., if it is still an active lookupcode)

  PARAMETERS:

  DESIGN REFERENCES:	../POXPOMPO.doc

  ALGORITHM:

  NOTES:

  OPEN ISSUES:

  CLOSED ISSUES:

  CHANGE HISTORY:  Sudha Iyer         04/95
===========================================================================*/

PROCEDURE val_ap_terms(X_temp_terms_id IN number, X_res_terms_id IN OUT NOCOPY number);

/*===========================================================================
  PROCEDURE NAME:	get_terms_name()

  DESCRIPTION: 		This procedure gets the terms name for a specific
			terms id.

  PARAMETERS:

  DESIGN REFERENCES:	../POXPOMPO.doc
			../POXSCERQ.dd

  ALGORITHM:

  NOTES:

  OPEN ISSUES:

  CLOSED ISSUES:

  CHANGE HISTORY:  	12/14/95	MSNYDER		Created.
===========================================================================*/

PROCEDURE get_terms_name (X_terms_id IN number,
			  X_terms_name IN OUT NOCOPY varchar2);

/*===========================================================================
  PROCEDURE NAME:	derive_payment_terms_info()

  DESCRIPTION: 		This procedure derives the missing components of the
                        payment terms record based on the components that
                        have values

  PARAMETERS:           p_pay_record IN OUT RCV_SHIPMENT_HEADER_SV.PayRecType

  DESIGN REFERENCES:

  ALGORITHM:

  NOTES:                uses dbms_sql to generate WHERE clause based on the
                        components that have values

  OPEN ISSUES:

  CLOSED ISSUES:

  CHANGE HISTORY:  	10/25/96	Raj Bhakta		Created.
===========================================================================*/

 PROCEDURE derive_payment_terms_info(
            p_pay_record IN OUT NOCOPY RCV_SHIPMENT_HEADER_SV.PayRecType);

/*===========================================================================
  PROCEDURE NAME:	validate_payment_terms_info()

  DESCRIPTION: 		This procedure validates the payment terms record based
                        on the components that have values. It applies business
                        rules and retuen error status and error messages based
                        on the success and failure of the business rules.

  PARAMETERS:           p_pay_record IN OUT RCV_SHIPMENT_HEADER_SV.PayRecType

  DESIGN REFERENCES:

  ALGORITHM:

  NOTES:                uses dbms_sql to generate WHERE clause based on the
                        components that have values

  OPEN ISSUES:

  CLOSED ISSUES:

  CHANGE HISTORY:  	10/25/96	Raj Bhakta		Created.
===========================================================================*/

 PROCEDURE validate_payment_terms_info(
            p_pay_record IN OUT NOCOPY RCV_SHIPMENT_HEADER_SV.PayRecType);


/*===========================================================================
  PROCEDURE NAME:   validate_freight_carrier_info()

  DESCRIPTION:      This procedure validates the freight carrier record and
                    returns error status and error messages based on
                    business rules.

  PARAMETERS:       p_carrier_rec IN OUT RCV_SHIPMENT_HEADER_SV.FreightRecType

  DESIGN REFERENCES:

  ALGORITHM:

  NOTES:

  OPEN ISSUES:

  CLOSED ISSUES:

  CHANGE HISTORY:  Raj Bhakta 10/29/96  Created
===========================================================================*/

PROCEDURE validate_freight_carrier_info(
          p_carrier_rec IN OUT NOCOPY rcv_shipment_header_sv.FreightRecType);

PROCEDURE get_global_terms_conditions                              -- <2699404>
(   p_po_header_id    IN         PO_HEADERS_ALL.po_header_id%TYPE
,   x_terms_id        OUT NOCOPY PO_HEADERS_ALL.terms_id%TYPE
,   x_fob_lookup_code OUT NOCOPY PO_HEADERS_ALL.fob_lookup_code%TYPE
,   x_freight_terms   OUT NOCOPY PO_HEADERS_ALL.freight_terms_lookup_code%TYPE
,   x_supplier_note   OUT NOCOPY PO_HEADERS_ALL.note_to_vendor%TYPE
,   x_receiver_note   OUT NOCOPY PO_HEADERS_ALL.note_to_receiver%TYPE
,   x_shipping_control OUT NOCOPY PO_HEADERS_ALL.shipping_control%TYPE    -- <INBOUND LOGISTICS FPJ>
);

PROCEDURE get_local_terms_conditions                               -- <2699404>
(   p_po_header_id    IN         PO_HEADERS_ALL.po_header_id%TYPE
,   x_pay_on_code     OUT NOCOPY PO_HEADERS_ALL.pay_on_code%TYPE
,   x_bill_to_id      OUT NOCOPY PO_HEADERS_ALL.bill_to_location_id%TYPE
,   x_ship_to_id      OUT NOCOPY PO_HEADERS_ALL.ship_to_location_id%TYPE
,   x_ship_via_code   OUT NOCOPY PO_HEADERS_ALL.ship_via_lookup_code%TYPE
);

-- <GC FPJ START>

--bug3225062
PROCEDURE compare_terms_conditions
(  p_comparison_scope     IN         VARCHAR2,
   p_terms_rec1           IN         terms_and_cond_rec_type,
   p_terms_rec2           IN         terms_and_cond_rec_type,
   x_same_terms           OUT NOCOPY VARCHAR2,
   x_comparison_result    OUT NOCOPY terms_cond_comp_rec_type
);

--bug3225062
PROCEDURE set_terms_comparison_msg
(  p_ref_doc_type         IN         VARCHAR2,
   p_comparison_scope     IN         VARCHAR2,
   p_terms_rec1           IN         terms_and_cond_rec_type,
   p_terms_rec2           IN         terms_and_cond_rec_type,
   p_comparison_result    IN         terms_cond_comp_rec_type
);

-- <GC FPJ END>

END PO_TERMS_SV;

 

/
