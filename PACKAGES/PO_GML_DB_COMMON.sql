--------------------------------------------------------
--  DDL for Package PO_GML_DB_COMMON
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PO_GML_DB_COMMON" AUTHID CURRENT_USER AS
/* $Header: GMLPOXCS.pls 115.4 2002/12/17 22:35:41 mchandak ship $ */
FUNCTION check_process_org(X_inventory_org_id IN NUMBER) RETURN VARCHAR2;
FUNCTION get_opm_uom_code(X_apps_unit_meas_lookup_code IN VARCHAR2) RETURN VARCHAR2;
FUNCTION get_apps_uom_code(X_opm_um_code IN VARCHAR2) RETURN VARCHAR2;
FUNCTION get_quantity_onhand( pitem_id IN NUMBER
                             ,plot_no  IN VARCHAR2
                             ,psublot_no IN VARCHAR2
                             ,porg_id    IN NUMBER
                             ,plocator_id IN NUMBER
                            ) RETURN NUMBER;

PROCEDURE create_inv_trans_opm(	P_interface_trx_id IN NUMBER,
				P_Line_Id IN  	NUMBER,
				X_Return_Status	IN OUT NOCOPY VARCHAR2) ;

PROCEDURE get_secondary_tran_qty ( p_transaction_id IN NUMBER,
				   p_secondary_available_qty IN OUT NOCOPY NUMBER);

PROCEDURE validate_quantity(
	x_opm_item_id		IN NUMBER,
	x_opm_dual_uom_type	IN NUMBER,
	x_quantity		IN NUMBER,
	x_opm_um_code		IN VARCHAR2,
	x_opm_secondary_uom	IN VARCHAR2,
       	x_secondary_quantity	IN OUT NOCOPY NUMBER );

PROCEDURE create_lot_specific_conversion(
        x_item_number		IN VARCHAR2,
        x_lot_number		IN VARCHAR2,
        x_sublot_number         IN VARCHAR2,
        x_from_uom	        IN VARCHAR2,
        x_to_uom     		IN VARCHAR2,
        x_type_factor		IN NUMBER,
        x_status		IN OUT NOCOPY VARCHAR2,
        x_data			IN OUT NOCOPY VARCHAR2);

--Bug 1968305 Trans date in ic_tran_pnd does not have time stamp
G_USE_CREATION_DATE 	VARCHAR2(3) := fnd_profile.value('GML_USE_CREATION_DATE');

END PO_GML_DB_COMMON;

 

/
