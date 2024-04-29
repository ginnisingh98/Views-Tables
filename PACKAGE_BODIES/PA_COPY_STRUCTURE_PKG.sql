--------------------------------------------------------
--  DDL for Package Body PA_COPY_STRUCTURE_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PA_COPY_STRUCTURE_PKG" as
-- $Header: PAXCICPB.pls 120.1 2005/08/23 19:19:48 spunathi noship $


procedure check_structure(cp_structure IN     varchar2,
		 	  status       IN OUT NOCOPY number) is

-- local variables
dummy	     number;

begin

   status := 0;

   -- check pa_cost_plus_structures table

   SELECT 1 INTO dummy FROM sys.dual WHERE EXISTS
      (SELECT 1 FROM pa_cost_plus_structures
       WHERE    cost_plus_structure = cp_structure);

exception

   when OTHERS then
      -- there are at least one foreign key in details table
      status := SQLCODE;

end check_structure;


procedure check_existence(cp_structure IN     varchar2,
			 status       IN OUT NOCOPY number) is

-- local variables
dummy	     number;

begin

   status := 0;

   -- check pa_cost_base_v table

   /*
    * Performance related change:
    * The view pa_cost_base_v doesnot get merged here.
    * Instead of the view, the query now directly looks into the
    * base tables.
    */
   SELECT 1 INTO dummy FROM sys.dual WHERE NOT EXISTS
      (SELECT 1 FROM pa_cost_base_cost_codes
       WHERE    cost_plus_structure = cp_structure)
       AND NOT EXISTS
      (SELECT 1 FROM pa_cost_base_exp_types
       WHERE    cost_plus_structure = cp_structure)
       ;

exception

   when OTHERS then
      -- there are at least one foreign key in details table
      status := SQLCODE;

end check_existence;



--
--  PROCEDURE
--              copy_structure
--
--  PURPOSE
--              The objective of this procedure is to check whether the
--              cost plus structure has been used.  'Used' is defined as
--              there are costed expenditure items in this cost plus structure.
--
--  HISTORY
--
--   07-MAY-94      S Lee       Created
--

procedure copy_structure(source      IN varchar2,
                         destination IN varchar2,
                         status IN OUT NOCOPY number,
                         stage  IN OUT NOCOPY number)
is

-- cursor definition
   CURSOR icc_cursor
   IS
      SELECT cost_base,
             cost_base_type,
             ind_cost_code,
             precedence
      FROM pa_cost_base_cost_codes
      WHERE cost_plus_structure = source;

   CURSOR et_cursor
   IS
      SELECT cost_base,
             cost_base_type,
             expenditure_type
      FROM pa_cost_base_exp_types
      WHERE cost_plus_structure = source;

   -- Local variables
   cbicc_id        number;
   structure_type  varchar2(30);
   icc_precedence  number;

   -- Standard who
   x_last_updated_by            NUMBER(15);
   x_created_by                 NUMBER(15);
   x_last_update_login          NUMBER(15);


begin

   stage := 100;
   status := 0;

   --
   --  Standard who
   --

   x_created_by                 := FND_GLOBAL.USER_ID;
   x_last_updated_by            := FND_GLOBAL.USER_ID;
   x_last_update_login          := FND_GLOBAL.LOGIN_ID;

   SELECT cost_plus_structure_type
   INTO   structure_type
   FROM   pa_cost_plus_structures
   WHERE  cost_plus_structure = destination;

   if (structure_type = 'A') then
       icc_precedence := 1 ;
   else
       icc_precedence := NULL;
   end if;


   for icc_row in icc_cursor loop
       SELECT pa_cost_base_cost_codes_s.nextval into cbicc_id FROM sys.dual;

       INSERT INTO pa_cost_base_cost_codes
         (cost_base_cost_code_id,
          cost_plus_structure,
          cost_base,
          cost_base_type,
          ind_cost_code,
          precedence,
          last_update_date,
          last_updated_by,
          creation_date,
          created_by,
          last_update_login
         )
       VALUES
         (cbicc_id,
          destination,
          icc_row.cost_base,
          icc_row.cost_base_type,
          icc_row.ind_cost_code,
          NVL(icc_precedence,icc_row.precedence),
          SYSDATE,
          x_last_updated_by,
          SYSDATE,
          x_created_by,
          x_last_update_login);

   end loop;

   stage := 200;

   for et_row in et_cursor loop

       INSERT INTO pa_cost_base_exp_types
         (cost_plus_structure,
          cost_base,
          cost_base_type,
          expenditure_type,
          last_update_date,
          last_updated_by,
          creation_date,
          created_by,
          last_update_login
         )
       VALUES
         (destination,
          et_row.cost_base,
          et_row.cost_base_type,
          et_row.expenditure_type,
          SYSDATE,
          x_last_updated_by,
          SYSDATE,
          x_created_by,
          x_last_update_login);

   end loop;

   COMMIT;

exception
   WHEN OTHERS THEN
     status := SQLCODE;
end copy_structure;

end PA_COPY_STRUCTURE_PKG ;

/
