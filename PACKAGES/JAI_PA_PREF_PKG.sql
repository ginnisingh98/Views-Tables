--------------------------------------------------------
--  DDL for Package JAI_PA_PREF_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."JAI_PA_PREF_PKG" AUTHID CURRENT_USER as
/* $Header: jai_pa_pref_pkg.pls 120.0.12000000.1 2007/10/24 18:20:36 rallamse noship $ */

/*----------------------------------------------------------------------------------------
Change History
S.No.   DATE         Description
------------------------------------------------------------------------------------------

1      24/04/1005    cbabu for bug#6012570 (5876390) Version: 120.0
                      Projects Billing Enh.
                      forward ported from R11i to R12

---------------------------------------------------------------------------------------- */

  procedure load_row
          (
             x_distribution_rule   varchar2
           , x_context_id          varchar2
           , x_owner               varchar2
           , x_preference          varchar2
           , x_last_update_date    varchar2
           , x_force_edits         varchar2
          );
 procedure insert_row
          (
             x_setup_preference_rec  in jai_pa_setup_preferences%rowtype
           , x_rowid                in out nocopy rowid
           , x_setup_preference_id  in out nocopy jai_pa_setup_preferences.setup_preference_id%type
           );
  procedure update_row
          ( x_setup_preference_rec   in    jai_pa_setup_preferences%rowtype
          );
  procedure delete_row
          (x_setup_preference_id   in  jai_pa_setup_preferences.setup_preference_id%type);

end  jai_pa_pref_pkg  ;
 

/
