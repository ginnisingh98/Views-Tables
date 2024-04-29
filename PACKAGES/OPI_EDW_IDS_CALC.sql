--------------------------------------------------------
--  DDL for Package OPI_EDW_IDS_CALC
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OPI_EDW_IDS_CALC" AUTHID CURRENT_USER as
/*$Header: OPIMPPBS.pls 120.1 2005/06/07 03:30:31 appldev  $*/
PROCEDURE calc_prd_start_end ( p_from_date DATE,
			       p_to_date   DATE,
			       p_organization_id NUMBER,
			       x_status OUT NOCOPY  NUMBER  );

PROCEDURE cost_update_inventory (p_from_date DATE, p_to_date DATE,
				p_organization_id NUMBER, p_status OUT NOCOPY NUMBER);

End opi_edw_ids_calc;

 

/
