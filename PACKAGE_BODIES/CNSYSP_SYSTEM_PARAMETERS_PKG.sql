--------------------------------------------------------
--  DDL for Package Body CNSYSP_SYSTEM_PARAMETERS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."CNSYSP_SYSTEM_PARAMETERS_PKG" as
-- $Header: cnsysp1b.pls 120.1 2005/06/12 23:59:39 appldev  $


/* ----------------------------------------------------------- */

PROCEDURE Populate_Fields (
                x_set_of_books_id               number,
                x_trx_rollup_method             varchar2,
                x_usage_flag                    varchar2,
                x_status                        varchar2,
                x_sob_name                      IN OUT  NOCOPY varchar2,
                x_sob_calendar                  IN OUT  NOCOPY varchar2,
                x_sob_period_type               IN OUT  NOCOPY varchar2,
                x_sob_currency                  IN OUT  NOCOPY varchar2,
                x_trx_rollup_method_string      IN OUT  NOCOPY varchar2,
                x_usage_string                  IN OUT  NOCOPY varchar2,
                x_status_string                 IN OUT  NOCOPY varchar2 ) IS


BEGIN

  if (X_set_of_books_id is not null) then
    SELECT name,
           period_set_name,
           accounted_period_type,
           currency_code
      INTO x_sob_name,
           x_sob_calendar,
           x_sob_period_type,
           x_sob_currency
      FROM gl_sets_of_books_v
     WHERE set_of_books_id = x_set_of_books_id;
  else
     x_sob_name        := NULL ;        -- AE 08-05-95
     x_sob_calendar    := NULL ;
     x_sob_period_type := NULL ;
     x_sob_currency    := NULL ;
  end if;


  if (x_trx_rollup_method is not null) then
    SELECT meaning
      INTO x_trx_rollup_method_string
      FROM cn_lookups
     WHERE LOOKUP_CODE = x_trx_rollup_method
       AND LOOKUP_TYPE = 'TRX_ROLLUP_METHOD';
  end if;

  if (x_usage_flag is not null) then
    SELECT meaning into x_usage_string
      FROM cn_lookups
     WHERE LOOKUP_CODE = x_usage_flag
       AND LOOKUP_TYPE = 'REPOSITORY_USAGE';
  end if;

  if (x_status is not null) then
    SELECT meaning into x_status_string
      FROM cn_lookups
     WHERE LOOKUP_CODE = x_status
       AND LOOKUP_TYPE = 'REPOSITORY_STATUS';
  end if;

end Populate_Fields;

/* ----------------------------------------------------------- */

PROCEDURE Populate_Fields_Dim_Hier (
                x_rev_class_dimension_id        IN OUT   NOCOPY number,
                x_rev_class_hierarchy_id        IN OUT   NOCOPY number,
                x_rev_class_hierarchy_name      IN OUT   NOCOPY varchar2,
                x_srp_rollup_dimension_id       IN OUT   NOCOPY number,
                x_srp_rollup_hierarchy_id       IN OUT   NOCOPY number,
                x_srp_rollup_hierarchy_name     IN OUT   NOCOPY varchar2) IS

BEGIN

  SELECT dim.dimension_id
    INTO x_rev_class_dimension_id
    FROM cn_dimensions dim,
         cn_objects obj
   WHERE dim.source_table_id = obj.object_id
     AND obj.name = 'CN_REVENUE_CLASSES' ;


/*  SELECT dim.dimension_id
    INTO x_srp_rollup_dimension_id
    FROM cn_dimensions dim,
         cn_objects obj
   WHERE dim.source_table_id = obj.object_id
     AND obj.name = 'CN_SALESREPS' ; */


  if (x_rev_class_hierarchy_id IS NOT NULL)  then
     SELECT name
       INTO x_rev_class_hierarchy_name
       FROM cn_head_hierarchies
      WHERE head_hierarchy_id = x_rev_class_hierarchy_id ;
  else
      x_rev_class_hierarchy_name := NULL ;
  end if;


/*  if (x_srp_rollup_hierarchy_id IS NOT NULL)  then
     SELECT name
       INTO x_srp_rollup_hierarchy_name
       FROM cn_head_hierarchies
      WHERE head_hierarchy_id = x_srp_rollup_hierarchy_id ;
  else
      x_srp_rollup_hierarchy_name := NULL ;
  end if; */
-- we do not use this any more.

EXCEPTION
  WHEN No_data_found THEN null;
end Populate_Fields_Dim_Hier;

/*  ----------------------------------------------------------- */

PROCEDURE set_defaults ( X_repository_id                number,
                        X_system_batch_size     IN OUT  NOCOPY number,
                        X_transfer_batch_size   IN OUT  NOCOPY number,
                        X_clawback_grace_days   IN OUT  NOCOPY number,
                        X_trx_rollup_method     IN OUT  NOCOPY varchar2,
                        X_srp_rollup_flag       IN OUT  NOCOPY varchar2) IS
BEGIN

  if (  X_system_batch_size is NULL or
        X_system_batch_size < 5000 ) then

          X_system_batch_size := 5000;

          update cn_repositories
             set system_batch_size = 5000
          where repository_id = X_repository_id;
   end if;

  if (X_transfer_batch_size is NULL or
      X_transfer_batch_size < 5000 ) then

        X_transfer_batch_size := 5000;

        update cn_repositories
           set transfer_batch_size = 5000
        where repository_id = X_repository_id;
  end if;

  if (X_clawback_grace_days is NULL or
      X_clawback_grace_days  < 0) then

        X_clawback_grace_days := 0;

        update cn_repositories
           set clawback_grace_days = 0
        where repository_id = X_repository_id;
  end if;

  if (X_trx_rollup_method is NULL) then

        X_trx_rollup_method := 'INV';

       update cn_repositories
           set trx_rollup_method = 'INV'
        where repository_id = X_repository_id;

  end if;

  if (X_srp_rollup_flag is NULL) then

        X_srp_rollup_flag := 'N';

       update cn_repositories
           set srp_rollup_flag = 'N'
        where repository_id = X_repository_id;

  end if;

END set_defaults;


/* ----------------------------------------------------------- */

/* Block off for we are not saving last SP. 12/30/94

procedure save_to_last_sp
                (X_repository_id        number) is

begin

  update cn_repositories
  set ( last_set_of_books_id,
        last_current_period,
        last_system_start_period,
        last_system_end_period,
        last_system_batch_size,
        last_transfer_batch_size,
        last_clawback_grace_days,
        last_trx_rollup_method,
        last_srp_rollup_flag ) =
        ( select set_of_books_id,
                 current_period,
                 system_start_period,
                 system_end_period,
                 system_batch_size,
                 transfer_batch_size,
                 clawback_grace_days,
                 trx_rollup_method,
                 srp_rollup_flag
          from cn_repositories
          where repository_id = X_repository_id )
  where repository_id = X_repository_id;

end save_to_last_sp;

12/30/94 */

/* ----------------------------------------------------------- */

/* Block off for we are not saving last SP. 12/30/94

procedure restore_from_last_sp
                (X_repository_id        number) is

begin

   update cn_repositories
  set ( set_of_books_id,
        current_period,
        system_start_period,
        system_end_period,
        system_batch_size,
        transfer_batch_size,
        clawback_grace_days,
        trx_rollup_method,
        srp_rollup_flag ) =
        ( select last_set_of_books_id,
                 last_current_period,
                 last_system_start_period,
                 last_system_end_period,
                 last_system_batch_size,
                 last_transfer_batch_size,
                 last_clawback_grace_days,
                 last_trx_rollup_method,
                 last_srp_rollup_flag
          from cn_repositories
          where repository_id = X_repository_id )
  where repository_id = X_repository_id;

end restore_from_last_sp;

12/30/94 */


/* ----------------------------------------------------------- */

END CNSYSP_system_parameters_PKG;

/
