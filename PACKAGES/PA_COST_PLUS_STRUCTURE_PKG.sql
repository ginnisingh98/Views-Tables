--------------------------------------------------------
--  DDL for Package PA_COST_PLUS_STRUCTURE_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PA_COST_PLUS_STRUCTURE_PKG" AUTHID CURRENT_USER as
--  $Header: PAXCISTS.pls 115.0 99/07/16 15:22:38 porting ship $

   procedure check_unique(cp_structure IN varchar2, status IN OUT number);

   procedure check_references(cp_structure IN varchar2, status IN OUT number);

   procedure check_revision(cp_structure IN varchar2, status IN OUT number);

   procedure check_schedule(cp_structure IN varchar2, status IN OUT number);

   procedure check_bcc(cp_structure IN varchar2, status IN OUT number);

   procedure check_default(status  IN OUT number);

   procedure clear_default(cp_structure IN varchar2, status IN OUT number);

   procedure update_precedence(cp_structure IN varchar2, status IN OUT number);

   procedure cascade_delete(cp_structure IN varchar2);

   procedure cascade_update(old_cp_structure IN varchar2,
			    new_cp_structure IN varchar2);

end PA_COST_PLUS_STRUCTURE_PKG ;

 

/
