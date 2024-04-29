--------------------------------------------------------
--  DDL for Package WSMPCOGI
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."WSMPCOGI" AUTHID CURRENT_USER AS
/* $Header: WSMCOGIS.pls 120.0 2005/05/24 17:35:50 appldev noship $ */

/*===========================================================================
  PROCEDURE NAME:       get_bill_comp_sequence

  DESCRIPTION:          This routine is used to obtain a new
                        sequence for bill_sequence_id and
                        component_sequence_id.

  PARAMETERS:           x_result                IN OUT NOCOPY  NUMBER
                        x_error_code            IN OUT NOCOPY  NUMBER
                        x_error_msg             IN OUT NOCOPY  VARCHAR2

                        x_error_code :  0 - Successful.
                         Other values:    - SQL Error.
===========================================================================*/
PROCEDURE get_bill_comp_sequence (x_result      IN OUT NOCOPY NUMBER,
                                  x_error_code  IN OUT NOCOPY NUMBER,
                                  x_error_msg   IN OUT NOCOPY VARCHAR2);

/*===========================================================================
  PROCEDURE NAME:       get_coprod_count

  DESCRIPTION:          This routine returns the number of co-products
				in a co-product relationship.

  PARAMETERS:           x_co_product_group_id IN     NUMBER,
		        x_count		    IN OUT NOCOPY NUMBER,
                        x_error_code          IN OUT NOCOPY NUMBER,
                        x_error_msg           IN OUT NOCOPY VARCHAR2

                        x_error_code :  0 - Successful.
                         Other values:    - SQL Error.
===========================================================================*/
PROCEDURE get_coprod_count(x_co_product_group_id   IN     NUMBER,
			   x_count			   IN OUT NOCOPY NUMBER,
                           x_error_code            IN OUT NOCOPY NUMBER,
                           x_error_msg             IN OUT NOCOPY VARCHAR2);


/*===========================================================================
  FUNCTION NAME:	get_alternate_designator

  DESCRIPTION:		This function gets the alternate designator
                        used to create the bills associated with the co-products
                        belonging to a specific co-product relationship.

  PARAMETERS:		X_co_product_group_id	NUMBER
===========================================================================*/

FUNCTION get_alternate_designator
	(X_co_product_group_id   NUMBER) return varchar2;


/*****************************************************************
* Function      : Get_Component_Sequence_Id
* Parameters IN : Component unique index information
* Parameters OUT: Error Text
* Returns       : Component_Sequence_Id
* Purpose       : Function will query the component sequence id using
*                 alternate unique key information. If unsuccessfull
*                 function will return a NULL.
********************************************************************/
FUNCTION Get_Component_Sequence_Id(p_component_item_id IN NUMBER,
                            p_operation_sequence_num IN VARCHAR2,
                            p_effectivity_date       IN DATE,
                            p_bill_sequence_id       IN NUMBER,
                            x_err_text OUT NOCOPY VARCHAR2 )
RETURN NUMBER;

/*===========================================================================
  FUNCTION NAME:	get_item_name

  DESCRIPTION:		This function does a id to value conversion and
			returns the item name
===========================================================================*/
FUNCTION Get_Item_Name (p_inventory_item_id	IN NUMBER,
			p_organization_id	IN NUMBER,
                        x_error_code            IN OUT NOCOPY NUMBER,
                        x_error_msg             IN OUT NOCOPY VARCHAR2)
RETURN VARCHAR2;
--bug 4224811 commenting out the following pragma since it causes compilation errors. Also get_alternate_designator is not currently not used
--in our code
--PRAGMA RESTRICT_REFERENCES (get_alternate_designator,WNDS,RNPS,WNPS);

END;

 

/
