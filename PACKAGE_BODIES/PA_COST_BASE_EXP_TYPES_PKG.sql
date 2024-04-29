--------------------------------------------------------
--  DDL for Package Body PA_COST_BASE_EXP_TYPES_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PA_COST_BASE_EXP_TYPES_PKG" as
-- $Header: PAXCICEB.pls 120.1 2005/08/23 19:19:37 spunathi noship $

-- constant
NO_DATA_FOUND_ERR constant number := 100;

------------------------------------------------------------------------------
procedure check_unique(cp_structure  IN     varchar2,
                       c_base_type   IN     varchar2,
                       exp_type      IN     varchar2,
                       status        IN OUT NOCOPY number)
is
dummy number;
begin

   status := 0;

   SELECT 1 INTO dummy FROM sys.dual WHERE NOT EXISTS
      (SELECT 1 FROM pa_cost_base_exp_types
       WHERE  cost_base_type = c_base_type
              AND cost_plus_structure = cp_structure
              AND expenditure_type = exp_type);

exception

   when NO_DATA_FOUND then
        status := NO_DATA_FOUND_ERR;

   when OTHERS then
        status := SQLCODE;

end check_unique;

------------------------------------------------------------------------------
--
--  PROCEDURE
--              check_structure_used
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

procedure check_structure_used(structure IN varchar2,
                               status IN OUT NOCOPY number,
                               stage  IN OUT NOCOPY number)
is
-- cursor definition

   CURSOR rev_cursor
   IS
      SELECT ind_rate_sch_revision_id
      FROM pa_ind_rate_sch_revisions
      WHERE cost_plus_structure = structure;

BEGIN

  status := 0;

  FOR rev_row IN rev_cursor LOOP

      pa_cost_plus.check_revision_used(rev_row.ind_rate_sch_revision_id,
                                       status,
                                       stage);

      if (status <> 0) then
          stage := 100;
          EXIT;
      end if;

  END LOOP;

EXCEPTION
  WHEN OTHERS THEN
  stage := 100;

END check_structure_used;

------------------------------------------------------------------------------
procedure get_description(exp_type IN varchar2, descpt IN OUT NOCOPY varchar2) is
begin

    SELECT description INTO descpt FROM pa_expenditure_types
    WHERE expenditure_type = exp_type;

exception
    when OTHERS then
       descpt := null;

end get_description;

end PA_COST_BASE_EXP_TYPES_PKG ;

/
