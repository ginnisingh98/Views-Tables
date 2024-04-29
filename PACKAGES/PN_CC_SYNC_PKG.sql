--------------------------------------------------------
--  DDL for Package PN_CC_SYNC_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PN_CC_SYNC_PKG" AUTHID CURRENT_USER as
  -- $Header: PNCCSYNS.pls 115.0 2003/11/15 02:17:48 vmmehta noship $


  -------------------------------------------------------------------
  -- Main procedure for cost center synchronization with HR
  -- ( Run as a Conc Process )
  -------------------------------------------------------------------

  PROCEDURE cc_sync_with_hr (
            errbuf                  OUT NOCOPY VARCHAR2,
            retcode                 OUT NOCOPY VARCHAR2,
            p_as_of_date            IN VARCHAR2,
            p_locn_type             IN pn_locations.location_type_lookup_code%TYPE,
            p_locn_code_from        IN pn_locations.location_code%TYPE,
            p_locn_code_to          IN pn_locations.location_code%TYPE,
            p_emp_cost_center       IN pn_space_assign_emp.cost_center_code%TYPE );


  -------------------------------------------------------------------
  -- For getting cost center on 'As of date' and full name from HR
  -------------------------------------------------------------------

  PROCEDURE get_cc_as_of_date ( p_employee_id  IN NUMBER,
                                p_column_name IN VARCHAR2 DEFAULT NULL,
                                p_as_of_date  IN DATE,
				p_emp_name    OUT NOCOPY VARCHAR2,
				p_cost_center OUT NOCOPY VARCHAR2
                              ) ;


END PN_CC_SYNC_PKG;

 

/
