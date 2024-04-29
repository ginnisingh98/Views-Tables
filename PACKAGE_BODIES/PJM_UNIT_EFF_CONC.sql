--------------------------------------------------------
--  DDL for Package Body PJM_UNIT_EFF_CONC
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PJM_UNIT_EFF_CONC" AS
/* $Header: PJMUEFCB.pls 115.11 2002/10/29 20:15:41 alaw ship $ */
--  ---------------------------------------------------------------------
--  Global Variables
--  ---------------------------------------------------------------------

--  ---------------------------------------------------------------------
--  Private Functions / Procedures
--  ---------------------------------------------------------------------


--  ---------------------------------------------------------------------
--  Public Functions / Procedures
--  ---------------------------------------------------------------------

--
--  Name          : Generate
--  Pre-reqs      : None
--  Function      : This function creates new unit numbers based on
--                  input parameters
--
--
--  Parameters    :
--  IN            : X_master_org_id                 NUMBER
--                  X_end_item_id                   NUMBER
--                  X_prefix                        VARCHAR2
--                  X_start_num                     NUMBER
--                  X_counts                        NUMBER
--                  X_numeric_width                 NUMBER
--
--  OUT           : ERRBUF                          VARCHAR2
--                  RETCODE                         NUMBER
--
--  Returns       : None
--
PROCEDURE Generate
( ERRBUF                           OUT NOCOPY    VARCHAR2
, RETCODE                          OUT NOCOPY    NUMBER
, X_master_org_id                  IN            NUMBER
, X_end_item_id                    IN            NUMBER
, X_prefix                         IN            VARCHAR2
, X_start_num                      IN            NUMBER
, X_counts                         IN            NUMBER
, X_numeric_width                  IN            NUMBER
) is
  i                      NUMBER;
  n                      NUMBER;
  L_pad_width            NUMBER;
  L_current_unit_number  VARCHAR2(30);
  L_end_num              NUMBER;
  L_user_id              NUMBER;
  L_login_id             NUMBER;
  L_request_id           NUMBER;
  L_prog_appl_id         NUMBER;
  L_prog_id              NUMBER;
BEGIN

   if ( PJM_UNIT_EFF.Enabled = 'N' ) then
      fnd_message.set_name('PJM','UEFF-Function Not Available');
      ERRBUF := fnd_message.get;
      PJM_CONC.new_line(1);
      PJM_CONC.put_line(ERRBUF);
      PJM_CONC.new_line(1);
      RETCODE := PJM_CONC.G_conc_failure;
      return;
   end if;

   PJM_CONC.new_line(1);
   PJM_CONC.put_line('[MASTER_ORG_ID] = ' || X_master_org_id);
   PJM_CONC.put_line('[END_ITEM_ID]   = ' || X_end_item_id);
   PJM_CONC.put_line('[PREFIX]        = ' || X_prefix);
   PJM_CONC.put_line('[START_NUM]     = ' || X_start_num);
   PJM_CONC.put_line('[COUNTS]        = ' || X_counts);
   PJM_CONC.put_line('[NUMERIC_WIDTH] = ' || X_numeric_width);
   PJM_CONC.new_line(1);

   --
   -- Calculate End_Num based on X_Start_Num and X_Counts
   --
   L_end_num   := X_start_Num + X_Counts - 1;

   if ( length(to_char(L_end_num)) > X_numeric_width ) then
      fnd_message.set_name('PJM','UEFF-Exc Unit Num Length');
      fnd_message.set_token('LEN1', to_char(L_end_num));
      fnd_message.set_token('LEN2', X_numeric_width);
      PJM_CONC.new_line(1);
      PJM_CONC.put_line(fnd_message.get);
      PJM_CONC.new_line(1);
      L_pad_width := length(to_char(L_end_num));
   else
      L_pad_width := X_numeric_width;
   end if;

   if nvl(length(X_prefix),0) + L_pad_width > 30 then
      fnd_message.set_name('PJM','UEFF-Max Unit Num Length');
      errbuf := fnd_message.get;
      PJM_CONC.new_line(1);
      PJM_CONC.put_line(errbuf);
      PJM_CONC.new_line(1);
      retcode := PJM_CONC.G_conc_failure;
      return;
   end if;

   L_user_id := fnd_global.user_id;
   L_login_id := fnd_global.conc_login_id;
   L_request_id := fnd_global.conc_request_id;
   L_prog_appl_id := fnd_global.prog_appl_id;
   L_prog_id := fnd_global.conc_program_id;

   PJM_CONC.new_line(1);
   PJM_CONC.put_line(fnd_message.get_string('PJM','CONC-UEFGN BEGIN'));
   PJM_CONC.new_line(1);

   n := 0;

   FOR i in X_start_num..L_end_num
   LOOP
      --
      -- Construct Unit Number from X_prefix and i
      --
      L_current_unit_number := X_prefix || lpad(to_char(i), L_pad_width, '0');

      BEGIN
         INSERT INTO pjm_unit_numbers
         ( unit_number
         , creation_date
         , created_by
         , last_update_date
         , last_updated_by
         , last_update_login
         , request_id
         , program_application_id
         , program_id
         , program_update_date
         , end_item_id
         , master_organization_id
         , prefix)
         SELECT L_current_unit_number
         ,      sysdate
         ,      L_user_id
         ,      sysdate
         ,      L_user_id
         ,      L_login_id
         ,      L_request_id
         ,      L_prog_appl_id
         ,      L_prog_id
         ,      sysdate
         ,      X_end_item_id
         ,      X_master_org_id
         ,      X_prefix
         FROM   dual;

         n := n + 1;

         fnd_message.set_name('PJM','CONC-UEFGN UNITNUM CREATED');
         fnd_message.set_token('UNIT', L_current_unit_number);
         PJM_CONC.put_line(fnd_message.get);

      EXCEPTION
         WHEN dup_val_on_index THEN
            fnd_message.set_name('PJM','CONC-UEFGN UNITNUM EXISTS');
            fnd_message.set_token('UNIT', L_current_unit_number);
            PJM_CONC.put_line(fnd_message.get);
         WHEN others THEN
            errbuf := sqlerrm;
            retcode := PJM_CONC.G_conc_failure;
            return;
      END;

   END LOOP;

   PJM_CONC.new_line(1);
   fnd_message.set_name('PJM','CONC-UEFGN DONE');
   fnd_message.set_token('NUM', n);
   PJM_CONC.put_line(fnd_message.get);
   PJM_CONC.new_line(1);

   retcode := PJM_CONC.G_conc_success;

END Generate;


END PJM_UNIT_EFF_CONC;

/
